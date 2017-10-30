/*
    //------------------------------------------------------------------------------------
    //      Модуль тестирования памяти со случайным доступом маршевым алгоритмом March C-
    mmv_ram_march_c_tester
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     ()  // Разрядность данных (должна быть степенью двойки)
    )
    the_mmv_ram_march_c_tester
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейс управления
        .clear      (), // i  Синхронный сброс
        .start      (), // i  Запуск теста
        .ready      (), // o  Готовность к запуску теста
        .fault      (), // o  Одиночный импульс индикации ошибки
        .done       (), // o  Одиночный импульс окончания теста
        
        // Тестирующий интерфейс ведущего
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_mmv_ram_march_c_tester
*/

module mmv_ram_march_c_tester
#(
    parameter int unsigned          AWIDTH  = 8,    // Разрядность адреса
    parameter int unsigned          DWIDTH  = 8     // Разрядность данных (должна быть степенью двойки)
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic                    clear,  // Синхронный сброс
    input  logic                    start,  // Запуск теста
    output logic                    ready,  // Готовность к запуску теста
    output logic                    fault,  // Одиночный импульс индикации ошибки
    output logic                    done,   // Одиночный импульс окончания теста
    
    // Тестирующий интерфейс ведущего
    output logic [AWIDTH - 1 : 0]   m_addr,
    output logic                    m_wreq,
    output logic [DWIDTH - 1 : 0]   m_wdat,
    output logic                    m_rreq,
    input  logic [DWIDTH - 1 : 0]   m_rdat,
    input  logic                    m_rval,
    input  logic                    m_busy
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned         PASSNUM = $clog2(DWIDTH);   // Количество проходов
    
    //------------------------------------------------------------------------------------
    //      Функция формирования массива тестовых шаблонов
    logic [$clog2(DWIDTH) : 0][DWIDTH - 1 : 0]  pattern;
    generate
        genvar i;
        for (i = 0; i <= $clog2(DWIDTH); i++) begin: pattern_generation
            if (i == 0)
                assign pattern[i] = {DWIDTH{1'b0}};
            else
                assign pattern[i] = {2**($clog2(DWIDTH) - i){{2**(i - 1){1'b0}}, {2**(i - 1){1'b1}}}};
        end // pattern_generation
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [$clog2(DWIDTH) : 0][DWIDTH - 1 : 0]  wpat_dat_reg;
    logic                                       wpat_inv_reg;
    logic [AWIDTH - 1 : 0]                      addr_inc_cnt;
    logic [AWIDTH - 1 : 0]                      addr_dec_cnt;
    logic                                       addr_sel_reg;
    logic [$clog2(PASSNUM) - 1 : 0]             wpass_cnt;
    //
    logic [$clog2(DWIDTH) : 0][DWIDTH - 1 : 0]  rpat_dat_reg;
    logic                                       rpat_inv_reg;
    logic [AWIDTH - 1 : 0]                      rd_ack_cnt;
    logic [$clog2(PASSNUM) - 1 : 0]             rpass_cnt;
    //
    logic                                       done_reg;
    logic                                       fault_reg;
    
    //------------------------------------------------------------------------------------
    //      Кодирование состояний конечного автоматов запросов
    enum logic [11 : 0] {
        st_req_idle     = 12'b000_0_0_00_00_00_0,
        st_req_init_w   = 12'b000_0_0_10_01_01_1,
        st_req_pass_r0  = 12'b000_0_0_00_00_10_1,
        st_req_pass_w0  = 12'b001_0_0_10_01_01_1,
        st_req_pass_r1  = 12'b001_0_0_00_00_10_1,
        st_req_pass_w1  = 12'b000_0_0_10_11_01_1,
        st_req_pass_r2  = 12'b010_0_0_00_00_10_1,
        st_req_pass_w2  = 12'b010_0_0_10_01_01_1,
        st_req_pass_r3  = 12'b011_0_0_00_00_10_1,
        st_req_pass_w3  = 12'b000_0_0_01_11_01_1,
        st_req_loop_r0  = 12'b100_0_0_00_00_10_1,
        st_req_loop_w0  = 12'b001_0_0_10_11_01_1,
        st_req_loop_r1  = 12'b101_0_0_00_00_10_1,
        st_req_loop_w1  = 12'b010_0_0_10_11_01_1,
        st_req_loop_r2  = 12'b110_0_0_00_00_10_1,
        st_req_loop_w2  = 12'b000_0_1_01_11_01_1,
        st_req_fin_r    = 12'b000_0_0_00_01_10_1,
        st_req_wait     = 12'b000_1_0_00_00_00_1
    } req_state;
    wire [11 : 0] req_st;
    assign req_st = req_state;
    
    //------------------------------------------------------------------------------------
    //      Управляющие воздействия конечного автомата запросов
    assign ready         = ~req_st[0];
    assign m_wreq        =  req_st[1];
    assign m_rreq        =  req_st[2];
    wire   addr_cnt_ena  =  req_st[3];
    wire   addr_swp_ena  =  req_st[4];
    wire   wpat_upd_ena  =  req_st[5];
    wire   wpat_inv_ena  =  req_st[6];
    wire   wpass_cnt_ena =  req_st[7];
    wire   wait_ack      =  req_st[8];
    
    //------------------------------------------------------------------------------------
    //      Кодирование состояний конечного автомата анализа ответов на чтение
    enum logic [6 : 0] {
        st_ack_idle     = 7'b000_0_0_0_0,
        st_ack_init     = 7'b000_0_1_0_1,
        st_ack_pass0    = 7'b001_0_1_0_1,
        st_ack_pass1    = 7'b010_0_1_0_1,
        st_ack_pass2    = 7'b011_0_1_0_1,
        st_ack_pass3    = 7'b000_0_0_1_1,
        st_ack_loop0    = 7'b100_0_1_0_1,
        st_ack_loop1    = 7'b101_0_1_0_1,
        st_ack_loop2    = 7'b000_1_0_1_1
    } ack_state;
    wire [6 : 0] ack_st;
    assign ack_st = ack_state;
    
    //------------------------------------------------------------------------------------
    //      Управляющие воздействия конечного автомата анализа ответов на чтение
    wire ack_busy      = ack_st[0];
    wire rpat_upd_ena  = ack_st[1];
    wire rpat_inv_ena  = ack_st[2];
    wire rpass_cnt_ena = ack_st[3];
    
    //------------------------------------------------------------------------------------
    //      Логика переходов конечного автомата запросов
    always @(posedge reset, posedge clk)
        if (reset)
            req_state <= st_req_idle;
        else if (clear)
            req_state <= st_req_idle;
        else case (req_state)
            st_req_idle:
                if (start)
                    req_state <= st_req_init_w;
                else
                    req_state <= st_req_idle;
                
            st_req_init_w:
                if (~m_busy & (addr_dec_cnt == 0))
                    req_state <= st_req_pass_r0;
                else
                    req_state <= st_req_init_w;
                
            st_req_pass_r0:
                if (~m_busy)
                    req_state <= st_req_pass_w0;
                else
                    req_state <= st_req_pass_r0;
                
            st_req_pass_w0:
                if (~m_busy)
                    if (addr_dec_cnt == 0)
                        req_state <= st_req_pass_r1;
                    else
                        req_state <= st_req_pass_r0;
                else
                    req_state <= st_req_pass_w0;
                
            st_req_pass_r1:
                if (~m_busy)
                    req_state <= st_req_pass_w1;
                else
                    req_state <= st_req_pass_r1;
                
            st_req_pass_w1:
                if (~m_busy)
                    if (addr_dec_cnt == 0)
                        req_state <= st_req_pass_r2;
                    else
                        req_state <= st_req_pass_r1;
                else
                    req_state <= st_req_pass_w1;
                
            st_req_pass_r2:
                if (~m_busy)
                    req_state <= st_req_pass_w2;
                else
                    req_state <= st_req_pass_r2;
                
            st_req_pass_w2:
                if (~m_busy)
                    if (addr_dec_cnt == 0)
                        req_state <= st_req_pass_r3;
                    else
                        req_state <= st_req_pass_r2;
                else
                    req_state <= st_req_pass_w2;
                
            st_req_pass_r3:
                if (~m_busy)
                    req_state <= st_req_pass_w3;
                else
                    req_state <= st_req_pass_r3;
                
            st_req_pass_w3:
                if (~m_busy)
                    if (addr_dec_cnt == 0)
                        req_state <= st_req_loop_r0;
                    else
                        req_state <= st_req_pass_r3;
                else
                    req_state <= st_req_pass_w3;
                
            st_req_loop_r0:
                if (~m_busy)
                    req_state <= st_req_loop_w0;
                else
                    req_state <= st_req_loop_r0;
                
            st_req_loop_w0:
                if (~m_busy)
                    if (addr_dec_cnt == 0)
                        req_state <= st_req_loop_r1;
                    else
                        req_state <= st_req_loop_r0;
                else
                    req_state <= st_req_loop_w0;
                
            st_req_loop_r1:
                if (~m_busy)
                    req_state <= st_req_loop_w1;
                else
                    req_state <= st_req_loop_r1;
                
            st_req_loop_w1:
                if (~m_busy)
                    if (addr_dec_cnt == 0)
                        req_state <= st_req_loop_r2;
                    else
                        req_state <= st_req_loop_r1;
                else
                    req_state <= st_req_loop_w1;
                
            st_req_loop_r2:
                if (~m_busy)
                    req_state <= st_req_loop_w2;
                else
                    req_state <= st_req_loop_r2;
                
            st_req_loop_w2:
                if (~m_busy)
                    if (addr_dec_cnt == 0)
                        if (wpass_cnt == (PASSNUM - 1))
                            req_state <= st_req_fin_r;
                        else
                            req_state <= st_req_loop_r0;
                    else
                        req_state <= st_req_loop_r2;
                else
                    req_state <= st_req_loop_w2;
                
            st_req_fin_r:
                if (~m_busy & (addr_dec_cnt == 0))
                    req_state <= st_req_wait;
                else
                    req_state <= st_req_fin_r;
                
            st_req_wait:
                if (ack_busy)
                    req_state <= st_req_wait;
                else
                    req_state <= st_req_idle;
                
            default:
                req_state <= st_req_idle;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Логика переходов конечного автомата анализа ответов на чтение
    always @(posedge reset, posedge clk)
        if (reset)
            ack_state <= st_ack_idle;
        else if (clear)
            ack_state <= st_ack_idle;
        else case (ack_state)
            st_ack_idle:
                if (start)
                    ack_state <= st_ack_init;
                else
                    ack_state <= st_ack_idle;
            
            st_ack_init:
                if (m_rval & (rd_ack_cnt == 0))
                    ack_state <= st_ack_pass0;
                else
                    ack_state <= st_ack_init;
            
            st_ack_pass0:
                if (m_rval & (rd_ack_cnt == 0))
                    ack_state <= st_ack_pass1;
                else
                    ack_state <= st_ack_pass0;
            
            st_ack_pass1:
                if (m_rval & (rd_ack_cnt == 0))
                    ack_state <= st_ack_pass2;
                else
                    ack_state <= st_ack_pass1;
            
            st_ack_pass2:
                if (m_rval & (rd_ack_cnt == 0))
                    ack_state <= st_ack_pass3;
                else
                    ack_state <= st_ack_pass2;
            
            st_ack_pass3:
                if (m_rval & (rd_ack_cnt == 0))
                    ack_state <= st_ack_loop0;
                else
                    ack_state <= st_ack_pass3;
            
            st_ack_loop0:
                if (m_rval & (rd_ack_cnt == 0))
                    ack_state <= st_ack_loop1;
                else
                    ack_state <= st_ack_loop0;
            
            st_ack_loop1:
                if (m_rval & (rd_ack_cnt == 0))
                    ack_state <= st_ack_loop2;
                else
                    ack_state <= st_ack_loop1;
            
            st_ack_loop2:
                if (m_rval & (rd_ack_cnt == 0))
                    if (rpass_cnt == (PASSNUM - 1))
                        ack_state <= st_ack_idle;
                    else
                        ack_state <= st_ack_loop0;
                else
                    ack_state <= st_ack_loop2;
            
            default:
                ack_state <= st_ack_idle;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр записываемых шаблонов
    always @(posedge reset, posedge clk)
        if (reset)
            wpat_dat_reg <= pattern;
        else if (ready)
            wpat_dat_reg <= pattern;
        else if (wpat_upd_ena & ~m_busy & (addr_dec_cnt == 0))
            wpat_dat_reg <= {wpat_dat_reg[0], wpat_dat_reg[$clog2(DWIDTH) : 1]};
        else
            wpat_dat_reg <= wpat_dat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр инверсии текущего шаблона записи
    always @(posedge reset, posedge clk)
        if (reset)
            wpat_inv_reg <= '0;
        else if (ready)
            wpat_inv_reg <= '0;
        else
            wpat_inv_reg <= wpat_inv_reg ^ (wpat_inv_ena & ~m_busy & (addr_dec_cnt == 0));
    
    //------------------------------------------------------------------------------------
    //      Формирование записываемых шаблонов
    assign m_wdat = {DWIDTH{wpat_inv_reg}} ^ wpat_dat_reg[0];
    
    //------------------------------------------------------------------------------------
    //      Увеличивающийся счетчик адреса
    initial addr_inc_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            addr_inc_cnt <= '0;
        else if (ready)
            addr_inc_cnt <= '0;
        else
            addr_inc_cnt <= addr_inc_cnt + (addr_cnt_ena & ~m_busy);
    
    //------------------------------------------------------------------------------------
    //      Уменьшающийся счетчик адреса
    initial addr_dec_cnt = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            addr_dec_cnt <= '1;
        else if (ready)
            addr_dec_cnt <= '1;
        else
            addr_dec_cnt <= addr_dec_cnt - (addr_cnt_ena & ~m_busy);
    
    //------------------------------------------------------------------------------------
    //      Регистр выбора активного счетчика адреса
    always @(posedge reset, posedge clk)
        if (reset)
            addr_sel_reg <= '0;
        else if (ready)
            addr_sel_reg <= '0;
        else
            addr_sel_reg <= addr_sel_reg ^ (addr_swp_ena & ~m_busy & (addr_dec_cnt == 0));
    
    //------------------------------------------------------------------------------------
    //      Переключение счетчиков адреса
    assign m_addr = addr_sel_reg ? addr_dec_cnt : addr_inc_cnt;
    
    //------------------------------------------------------------------------------------
    //      Счетчик проходов (по записи)
    always @(posedge reset, posedge clk)
        if (reset)
            wpass_cnt <= '0;
        else if (ready)
            wpass_cnt <= '0;
        else
            wpass_cnt <= wpass_cnt + (wpass_cnt_ena & ~m_busy & (addr_dec_cnt == 0));
    
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр анализируемых шаблонов
    always @(posedge reset, posedge clk)
        if (reset)
            rpat_dat_reg <= pattern;
        else if (~ack_busy)
            rpat_dat_reg <= pattern;
        else if (rpat_upd_ena & m_rval & (rd_ack_cnt == 0))
            rpat_dat_reg <= {rpat_dat_reg[0], rpat_dat_reg[$clog2(DWIDTH) : 1]};
        else
            rpat_dat_reg <= rpat_dat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр инверсии текущего анализируемого шаблона
    always @(posedge reset, posedge clk)
        if (reset)
            rpat_inv_reg <= '0;
        else if (~ack_busy)
            rpat_inv_reg <= '0;
        else
            rpat_inv_reg <= rpat_inv_reg ^ (rpat_inv_ena & m_rval & (rd_ack_cnt == 0));
    
    //------------------------------------------------------------------------------------
    //      Счетчик ответов на чтение
    initial rd_ack_cnt = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            rd_ack_cnt <= '1;
        else if (~ack_busy)
            rd_ack_cnt <= '1;
        else
            rd_ack_cnt <= rd_ack_cnt - m_rval;
    
    //------------------------------------------------------------------------------------
    //      Счетчик проходов (по чтению)
    always @(posedge reset, posedge clk)
        if (reset)
            rpass_cnt <= '0;
        else if (~ack_busy)
            rpass_cnt <= '0;
        else
            rpass_cnt <= rpass_cnt + (rpass_cnt_ena & m_rval & (rd_ack_cnt == 0));
    
    //------------------------------------------------------------------------------------
    //      Регистр одиночного импульса окончания теста
    always @(posedge reset, posedge clk)
        if (reset)
            done_reg <= '0;
        else if (ready)
            done_reg <= '0;
        else
            done_reg <= wait_ack & ~ack_busy;
    assign done = done_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр одиночного импульса индикации ошибки
    always @(posedge reset, posedge clk)
        if (reset)
            fault_reg <= '0;
        else if (ready)
            fault_reg <= '0;
        else
            fault_reg <= ack_busy & m_rval & (m_rdat != (rpat_dat_reg[0] ^ {DWIDTH{rpat_inv_reg}}));
    assign fault = fault_reg;
    
endmodule: mmv_ram_march_c_tester