/*
    //------------------------------------------------------------------------------------
    //      Модуль буферизации потокового интерфейса DataStream в память с интерфейсом
    //      MemoryMapped с пакетным доступом
    ds_mmb_buffer
    #(
        .DWIDTH     (), // Разрядность данных
        .AWIDTH     (), // Разрядность адреса
        .BWIDTH     (), // Разрядность шины размера пакетного доступа
        .IDEPTH     (), // Размер входного буфера
        .ODEPTH     (), // Размер выходного буфера
        .RAMTYPE    ()  // Тип ресурса для реализации входного и выходного буфера
    )
    the_ds_mmb_buffer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [DWIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [DWIDTH - 1 : 0]
        .o_val      (), // o
        .o_rdy      (), // i
        
        // Интерфейс MemoryMapped (ведущий)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_bcnt     (), // o  [BWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_ds_mmb_buffer
*/

module ds_mmb_buffer
#(
    parameter int unsigned              DWIDTH  = 8,        // Разрядность данных
    parameter int unsigned              AWIDTH  = 8,        // Разрядность адреса
    parameter int unsigned              BWIDTH  = 4,        // Разрядность шины размера пакетного доступа
    parameter int unsigned              IDEPTH  = 8,        // Размер входного буфера
    parameter int unsigned              ODEPTH  = 8,        // Размер выходного буфера
    parameter                           RAMTYPE = "AUTO"    // Тип ресурса для реализации входного и выходного буфера
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Входной потоковый интерфейс
    input  logic [DWIDTH - 1 : 0]   i_dat,
    input  logic                    i_val,
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    input  logic                    o_rdy,
    
    // Интерфейс MemoryMapped (ведущий)
    output logic [AWIDTH - 1 : 0]   m_addr,
    output logic [BWIDTH - 1 : 0]   m_bcnt,
    output logic                    m_wreq,
    output logic [DWIDTH - 1 : 0]   m_wdat,
    output logic                    m_rreq,
    input  logic [DWIDTH - 1 : 0]   m_rdat,
    input  logic                    m_rval,
    input  logic                    m_busy
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned CAPACITY = 2**AWIDTH;                               // Общий размер буфера
    localparam int unsigned MAXBURST = 2**(BWIDTH - 1);                         // Максимальный размер пакетного доступа
    localparam int unsigned ISIZE    = MAXBURST > IDEPTH ? MAXBURST : IDEPTH;   // Размер входного буфера FIFO
    localparam int unsigned OSIZE    = MAXBURST > ODEPTH ? MAXBURST : ODEPTH;   // Размер выходного буфера FIFO
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [AWIDTH : 0]                  used_cnt;
    logic [AWIDTH : 0]                  free_cnt;
    logic                               wr_full_reg;
    logic                               rd_empty_reg;
    logic [$clog2(OSIZE + 1) - 1 : 0]   rd_free_cnt;
    logic                               rd_stop_reg;
    //
    logic [AWIDTH - 1 : 0]              rd_addr_cnt;
    logic [AWIDTH - 1 : 0]              wr_addr_cnt;
    logic [BWIDTH - 1 : 0]              rd_bcnt_max;
    logic [BWIDTH - 1 : 0]              wr_bcnt_max;
    logic [BWIDTH - 1 : 0]              rd_bcnt_reg;
    logic [BWIDTH - 1 : 0]              wr_bcnt_reg;
    logic [BWIDTH - 1 : 0]              wr_bcnt_cnt;
    //
    logic                               ififo_rdreq;
    logic                               ififo_wrreq;
    logic                               ififo_empty;
    logic                               ififo_full;
    logic [$clog2(ISIZE + 1) - 1 : 0]   ififo_used;
    //
    logic                               ofifo_rdreq;
    logic                               ofifo_wrreq;
    logic                               ofifo_empty;
    logic                               ofifo_full;
    logic [$clog2(OSIZE + 1) - 1 : 0]   ofifo_used;
    
    //------------------------------------------------------------------------------------
    //      Описание состояний конечного автомата
    enum logic [2 : 0] {
        st_rd_idle = 3'b000,    // Бездействие после чтения (приоритет записи)
        st_rd_exec = 3'b001,    // Выполнение чтения
        st_wr_idle = 3'b100,    // Бездействие после записи (приоритет чтения)
        st_wr_exec = 3'b110     // Выполнение записи
    } state;
    wire [2 : 0] st;
    assign st = state;
    
    //------------------------------------------------------------------------------------
    //      Выходные сигналы конечного автомата 
    wire fsm_rd_req = st[0];
    wire fsm_wr_req = st[1];
    wire fsm_rw_sel = st[2];
    
    //------------------------------------------------------------------------------------
    //      Логика переходов конечного автомата
    always @(posedge reset, posedge clk)
        if (reset)
            state <= st_rd_idle;
        else case (state)
            // Бездействие после чтения (приоритет записи)
            st_rd_idle:
                if (~wr_full_reg & ~ififo_empty)
                    state <= st_wr_exec;
                else if (~rd_empty_reg & ~rd_stop_reg)
                    state <= st_rd_exec;
                else
                    state <= st_rd_idle;
            
            // Выполнение чтения
            st_rd_exec:
                if (~m_busy)
                    if (~wr_full_reg & ~ififo_empty)
                        state <= st_wr_exec;
                    else
                        state <= st_rd_idle;
                else
                    state <= st_rd_exec;
            
            // Бездействие после записи (приоритет чтения)
            st_wr_idle:
                if (~rd_empty_reg & ~rd_stop_reg)
                    state <= st_rd_exec;
                else if (~wr_full_reg & ~ififo_empty)
                    state <= st_wr_exec;
                else
                    state <= st_wr_idle;
            
            // Выполнение записи
            st_wr_exec:
                if (~m_busy & (wr_bcnt_cnt == 1))
                    if (~rd_empty_reg & ~rd_stop_reg)
                        state <= st_rd_exec;
                    else
                        state <= st_wr_idle;
                else
                    state <= st_wr_exec;
            
            // Остальные случаи (при нормальной работе произойти не могут)
            default:
                state <= st_rd_idle;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Одноклоковое FIFO на ядре от Altera
    scfifo
    #(
        .add_ram_output_register    ("OFF"),
        .lpm_hint                   ({"RAM_BLOCK_TYPE=", RAMTYPE}),
        .lpm_numwords               (ISIZE),
        .lpm_showahead              ("ON"),
        .lpm_type                   ("scfifo"),
        .lpm_width                  (DWIDTH),
        .lpm_widthu                 ($clog2(ISIZE)),
        .overflow_checking          ("ON"),
        .underflow_checking         ("ON"),
        .use_eab                    ("ON")
    )
    istream_buffer
    (
        .aclr                       (reset),
        .clock                      (clk),
        .data                       (i_dat),
        .rdreq                      (ififo_rdreq),
        .wrreq                      (ififo_wrreq),
        .empty                      (ififo_empty),
        .full                       (ififo_full),
        .q                          (m_wdat),
        .almost_empty               (  ),
        .almost_full                (  ),
        .sclr                       (  ),
        .usedw                      (ififo_used[$clog2(ISIZE) - 1 : 0])
    ); // istream_buffer
    
    //------------------------------------------------------------------------------------
    //      Установка старшего разряда ififo_used для длины кратной степени 2-ки
    generate
        if (2**$clog2(ISIZE) == ISIZE) begin
            assign ififo_used[$clog2(ISIZE + 1) - 1] = ififo_full;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов управления FIFO входного буфера
    assign ififo_rdreq = ~ififo_empty & fsm_wr_req & ~m_busy;
    assign ififo_wrreq = ~ififo_full  & i_val;
    
    //------------------------------------------------------------------------------------
    //      Одноклоковое FIFO на ядре от Altera
    scfifo
    #(
        .add_ram_output_register    ("OFF"),
        .lpm_hint                   ({"RAM_BLOCK_TYPE=", RAMTYPE}),
        .lpm_numwords               (OSIZE),
        .lpm_showahead              ("ON"),
        .lpm_type                   ("scfifo"),
        .lpm_width                  (DWIDTH),
        .lpm_widthu                 ($clog2(OSIZE)),
        .overflow_checking          ("ON"),
        .underflow_checking         ("ON"),
        .use_eab                    ("ON")
    )
    ostream_buffer
    (
        .aclr                       (reset),
        .clock                      (clk),
        .data                       (m_rdat),
        .rdreq                      (ofifo_rdreq),
        .wrreq                      (ofifo_wrreq),
        .empty                      (ofifo_empty),
        .full                       (ofifo_full),
        .q                          (o_dat),
        .almost_empty               (  ),
        .almost_full                (  ),
        .sclr                       (  ),
        .usedw                      (ofifo_used[$clog2(OSIZE) - 1 : 0])
    ); // ostream_buffer
    
    //------------------------------------------------------------------------------------
    //      Установка старшего разряда ofifo_used для длины кратной степени 2-ки
    generate
        if (2**$clog2(ISIZE) == ISIZE) begin
            assign ofifo_used[$clog2(ISIZE + 1) - 1] = ofifo_full;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов управления FIFO выходного буфера
    assign ofifo_rdreq = ~ofifo_empty & o_rdy;
    assign ofifo_wrreq = ~ofifo_full  & m_rval;
    
    //------------------------------------------------------------------------------------
    //      Счетчик количества использованных слов буфера
    initial used_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            used_cnt <= '0;
        else if (m_wreq & ~m_busy)
            used_cnt <= used_cnt + 1'b1;
        else if (m_rreq & ~m_busy)
            used_cnt <= used_cnt - rd_bcnt_reg;
        else
            used_cnt <= used_cnt;
    
    //------------------------------------------------------------------------------------
    //      Счетчик количества свободных слов буфера
    initial free_cnt = CAPACITY[AWIDTH : 0];
    always @(posedge reset, posedge clk)
        if (reset)
            free_cnt <= CAPACITY[AWIDTH : 0];
        else if (m_rreq & ~m_busy)
            free_cnt <= free_cnt + rd_bcnt_reg;
        else if (m_wreq & ~m_busy)
            free_cnt <= free_cnt - 1'b1;
        else
            free_cnt <= free_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака "полноты" буфера
    initial wr_full_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            wr_full_reg <= '0;
        else if (wr_full_reg)
            wr_full_reg <= ~(m_rreq & ~m_busy);
        else
            wr_full_reg <= (used_cnt == {AWIDTH{1'b1}}) & m_wreq & ~m_busy;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака пустоты буфера
    initial rd_empty_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            rd_empty_reg <= '1;
        else if (rd_empty_reg)
            rd_empty_reg <= ~(m_wreq & ~m_busy);
        else
            rd_empty_reg <= ~(used_cnt > rd_bcnt_reg) & m_rreq & ~m_busy;
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов в выходном буфере, доступных для выполнения запросов чтения
    initial rd_free_cnt = OSIZE[$clog2(OSIZE + 1) - 1 : 0];
    always @(posedge reset, posedge clk)
        if (reset)
            rd_free_cnt <= OSIZE[$clog2(OSIZE + 1) - 1 : 0];
        else
            rd_free_cnt <= rd_free_cnt - (rd_bcnt_reg & {BWIDTH{m_rreq & ~m_busy}}) + (o_val & o_rdy);
    
    //------------------------------------------------------------------------------------
    //      Регистр остановки чтения при превышении количества незавершенных операций
    initial rd_stop_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            rd_stop_reg <= '0;
        else if (rd_stop_reg)
            rd_stop_reg <= ~(o_val & o_rdy);
        else
            rd_stop_reg <= ~(rd_free_cnt > rd_bcnt_reg) & m_rreq & ~m_busy & ~(o_val & o_rdy);
    
    //------------------------------------------------------------------------------------
    //      Счетчик адреса чтения
    initial rd_addr_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            rd_addr_cnt <= '0;
        else if (m_rreq & ~m_busy)
            rd_addr_cnt <= rd_addr_cnt + rd_bcnt_reg;
        else
            rd_addr_cnt <= rd_addr_cnt;
    
    //------------------------------------------------------------------------------------
    //      Счетчик адреса записи
    initial wr_addr_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            wr_addr_cnt <= '0;
        else if (m_wreq & ~m_busy & (wr_bcnt_cnt == 1))
            wr_addr_cnt <= wr_addr_cnt + wr_bcnt_reg;
        else
            wr_addr_cnt <= wr_addr_cnt;
    
    //------------------------------------------------------------------------------------
    //      Максимальные значения длин пакетного доступа исходя из текущего состояния
    //      входного и выходного буферов
    assign rd_bcnt_max = rd_free_cnt > MAXBURST ? MAXBURST[BWIDTH - 1 : 0] : rd_free_cnt[BWIDTH - 1 : 0];
    assign wr_bcnt_max = ififo_used  > MAXBURST ? MAXBURST[BWIDTH - 1 : 0] : ififo_used[BWIDTH - 1 : 0];
    
    //------------------------------------------------------------------------------------
    //      Регистр размера пакетного чтения
    initial rd_bcnt_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            rd_bcnt_reg <= '0;
        else if (~m_rreq)
            if (used_cnt > rd_bcnt_max)
                rd_bcnt_reg <= rd_bcnt_max;
            else
                rd_bcnt_reg <= used_cnt[BWIDTH - 1 : 0];
        else
            rd_bcnt_reg <= rd_bcnt_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр размера пакетной записи
    initial wr_bcnt_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            wr_bcnt_reg <= '0;
        else if (~m_wreq)
            if (free_cnt > wr_bcnt_max)
                wr_bcnt_reg <= wr_bcnt_max;
            else
                wr_bcnt_reg <= free_cnt[BWIDTH - 1 : 0];
        else
            wr_bcnt_reg <= wr_bcnt_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов пакетной записи
    initial wr_bcnt_cnt ='0;
    always @(posedge reset, posedge clk)
        if (reset)
            wr_bcnt_cnt <= '0;
        else if (~m_wreq)
            if (free_cnt > wr_bcnt_max)
                wr_bcnt_cnt <= wr_bcnt_max;
            else
                wr_bcnt_cnt <= free_cnt[BWIDTH - 1 : 0];
        else
            wr_bcnt_cnt <= wr_bcnt_cnt - {{BWIDTH - 1{1'b0}}, ~m_busy};
    
    //------------------------------------------------------------------------------------
    //      Логика формирования выходных сигналов потоковых интерфейсов
    assign i_rdy = ~ififo_full;
    assign o_val = ~ofifo_empty;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования выходных сигналов интерфейса MemoryMapped
    assign m_addr = fsm_rw_sel ? wr_addr_cnt : rd_addr_cnt;
    assign m_bcnt = fsm_rw_sel ? wr_bcnt_reg : rd_bcnt_reg;
    assign m_wreq = fsm_wr_req;
    assign m_rreq = fsm_rd_req;
    
endmodule: ds_mmb_buffer