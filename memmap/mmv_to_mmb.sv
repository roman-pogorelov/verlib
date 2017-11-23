/*
    //------------------------------------------------------------------------------------
    //      Модуль преобразования интерфейса MemoryMapped с произвольной латентностью
    //      чтения в интерфейс MemoryMapped с пакетным доступом
    mmv_to_mmb
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     (), // Разрядность данных
        .BWIDTH     (), // Разрядность размера пакета
        .RAMTYPE    ()  // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    the_mmv_to_mmb
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейсы ведомых (подключаются к ведущим)
        .s_addr     (), // i  [AWIDTH - 1 : 0]
        .s_wreq     (), // i
        .s_wdat     (), // i  [DWIDTH - 1 : 0]
        .s_rreq     (), // i
        .s_rdat     (), // o  [DWIDTH - 1 : 0]
        .s_rval     (), // o
        .s_busy     (), // o
        
        // Интерфейс ведущего (подключается к ведомому)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_bcnt     (), // o  [BWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_mmv_to_mmb
*/

module mmv_to_mmb
#(
    parameter int unsigned          AWIDTH  = 8,        // Разрядность адреса
    parameter int unsigned          DWIDTH  = 8,        // Разрядность данных
    parameter int unsigned          BWIDTH  = 4,        // Разрядность размера пакета
    parameter                       RAMTYPE = "AUTO"    // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейсы ведомых (подключаются к ведущим)
    input  logic [AWIDTH - 1 : 0]   s_addr,
    input  logic                    s_wreq,
    input  logic [DWIDTH - 1 : 0]   s_wdat,
    input  logic                    s_rreq,
    output logic [DWIDTH - 1 : 0]   s_rdat,
    output logic                    s_rval,
    output logic                    s_busy,
    
    // Интерфейс ведущего (подключается к ведомому)
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
    //      Объявление сигналов
    logic [AWIDTH - 1 : 0]          seq_addr;
    logic [BWIDTH - 1 : 0]          seq_slen;
    logic                           seq_last;
    logic                           seq_wreq;
    logic [DWIDTH - 1 : 0]          seq_wdat;
    logic                           seq_rreq;
    logic                           seq_busy;
    //
    logic                           cmd_fifo_rdy;
    logic                           dat_fifo_rdy;
    //
    logic                           request;
    logic                           reqtype;
    logic                           lastwr;
    
    //------------------------------------------------------------------------------------
    //      Модуль выделения участок транзакций с последовательным доступом (доступом с
    //      последовательным изменением адреса) интерфейса MemoryMapped с произвольной
    //      латентностью чтения.
    //      Специфичные сигналы:
    //          m_slen - текущая длина участка транзакций с последовательным доступом
    //          m_last - индикатор последней транзакции в участке
    mmv_sequencer
    #(
        .AWIDTH     (AWIDTH),       // Разрядность адреса
        .DWIDTH     (DWIDTH),       // Разрядность данных
        .BWIDTH     (BWIDTH)        // Разрядность счетчика размера последовательного доступа
    )
    the_mmv_sequencer
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Интерфейсы ведомых (подключаются к ведущим)
        .s_addr     (s_addr),       // i  [AWIDTH - 1 : 0]
        .s_wreq     (s_wreq),       // i
        .s_wdat     (s_wdat),       // i  [DWIDTH - 1 : 0]
        .s_rreq     (s_rreq),       // i
        .s_rdat     (s_rdat),       // o  [DWIDTH - 1 : 0]
        .s_rval     (s_rval),       // o
        .s_busy     (s_busy),       // o
        
        // Интерфейс ведущего (подключается к ведомому)
        .m_addr     (seq_addr),     // o  [AWIDTH - 1 : 0]
        .m_slen     (seq_slen),     // o  [BWIDTH - 1 : 0]
        .m_last     (seq_last),     // o
        .m_wreq     (seq_wreq),     // o
        .m_wdat     (seq_wdat),     // o  [DWIDTH - 1 : 0]
        .m_rreq     (seq_rreq),     // o
        .m_rdat     (m_rdat),       // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),       // i
        .m_busy     (seq_busy)      // i
    ); // the_mmv_sequencer
    
    //------------------------------------------------------------------------------------
    //      Одноклоковый FIFO буфер для потокового интерфейса DataStream
    //      на ядре от Altera
    ds_alt_scfifo
    #(
        .DWIDTH             (AWIDTH + BWIDTH + 1),  // Разрядность потока
        .DEPTH              (2**BWIDTH + 1),        // Глубина FIFO
        .RAMTYPE            (RAMTYPE)               // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    command_fifo
    (
        // Сброс и тактирование
        .reset              (reset),                                                // i
        .clk                (clk),                                                  // i
        
        // Входной потоковый интерфейс
        .i_dat              ({seq_addr, seq_slen, seq_wreq}),                       // i  [DWIDTH - 1 : 0]
        .i_val              (seq_last & (seq_rreq | (seq_wreq & dat_fifo_rdy))),    // i
        .i_rdy              (cmd_fifo_rdy),                                         // o
        
        // Выходной потоковый интерфейс
        .o_dat              ({m_addr, m_bcnt, reqtype}),                            // o  [DWIDTH - 1 : 0]
        .o_val              (request),                                              // o
        .o_rdy              (~m_busy & (~reqtype | lastwr))                         // i
    ); // command_fifo
    
    //------------------------------------------------------------------------------------
    //      Одноклоковый FIFO буфер для потокового интерфейса DataStream
    //      на ядре от Altera
    ds_alt_scfifo
    #(
        .DWIDTH             (DWIDTH + 1),       // Разрядность потока
        .DEPTH              (2**BWIDTH + 1),    // Глубина FIFO
        .RAMTYPE            (RAMTYPE)           // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    wrdata_fifo
    (
        // Сброс и тактирование
        .reset              (reset),                                    // i
        .clk                (clk),                                      // i
        
        // Входной потоковый интерфейс
        .i_dat              ({seq_last, seq_wdat}),                     // i  [DWIDTH - 1 : 0]
        .i_val              (seq_wreq & (cmd_fifo_rdy | ~seq_last)),    // i
        .i_rdy              (dat_fifo_rdy),                             // o
        
        // Выходной потоковый интерфейс
        .o_dat              ({lastwr, m_wdat}),                         // o  [DWIDTH - 1 : 0]
        .o_val              (  ),                                       // o
        .o_rdy              (~m_busy & m_wreq)                          // i
    ); // wrdata_fifo
    
    //------------------------------------------------------------------------------------
    //      Сигнал готовности seq_busy
    assign seq_busy = (seq_wreq & ~dat_fifo_rdy) |                          // неготовность при отсутствии места в FIFO данных для записи
                      ((seq_wreq | seq_rreq) & seq_last & ~cmd_fifo_rdy);   // неготовность при отсутствии места в FIFO команд
    
    //------------------------------------------------------------------------------------
    //      Запросные сигналы интерфейса ведущего
    assign m_wreq = request &  reqtype;
    assign m_rreq = request & ~reqtype;
    
endmodule: mmv_to_mmb


/*
    //------------------------------------------------------------------------------------
    //      Модуль выделения участок транзакций с последовательным доступом (доступом с
    //      последовательным изменением адреса) интерфейса MemoryMapped с произвольной
    //      латентностью чтения.
    //      Специфичные сигналы:
    //          m_slen - текущая длина участка транзакций с последовательным доступом
    //          m_last - индикатор последней транзакции в участке
    mmv_sequencer
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     (), // Разрядность данных
        .BWIDTH     ()  // Разрядность счетчика размера последовательного доступа
    )
    the_mmv_sequencer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейсы ведомых (подключаются к ведущим)
        .s_addr     (), // i  [AWIDTH - 1 : 0]
        .s_wreq     (), // i
        .s_wdat     (), // i  [DWIDTH - 1 : 0]
        .s_rreq     (), // i
        .s_rdat     (), // o  [DWIDTH - 1 : 0]
        .s_rval     (), // o
        .s_busy     (), // o
        
        // Интерфейс ведущего (подключается к ведомому)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_slen     (), // o  [BWIDTH - 1 : 0]
        .m_last     (), // o
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_mmv_sequencer
*/
module mmv_sequencer
#(
    parameter int unsigned          AWIDTH  = 8,        // Разрядность адреса
    parameter int unsigned          DWIDTH  = 8,        // Разрядность данных
    parameter int unsigned          BWIDTH  = 3         // Разрядность счетчика размера последовательного доступа
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейсы ведомых (подключаются к ведущим)
    input  logic [AWIDTH - 1 : 0]   s_addr,
    input  logic                    s_wreq,
    input  logic [DWIDTH - 1 : 0]   s_wdat,
    input  logic                    s_rreq,
    output logic [DWIDTH - 1 : 0]   s_rdat,
    output logic                    s_rval,
    output logic                    s_busy,
    
    // Интерфейс ведущего (подключается к ведомому)
    output logic [AWIDTH - 1 : 0]   m_addr,
    output logic [BWIDTH - 1 : 0]   m_slen,
    output logic                    m_last,
    output logic                    m_wreq,
    output logic [DWIDTH - 1 : 0]   m_wdat,
    output logic                    m_rreq,
    input  logic [DWIDTH - 1 : 0]   m_rdat,
    input  logic                    m_rval,
    input  logic                    m_busy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [AWIDTH - 1 : 0]                      saddr_reg;
    logic [AWIDTH - 1 : 0]                      naddr_reg;
    logic                                       wreq_reg;
    logic [DWIDTH - 1 : 0]                      wdat_reg;
    logic                                       rreq_reg;
    logic                                       seq_detect;
    logic                                       last;
    logic [BWIDTH - 1 : 0]                      len_cnt;
    logic                                       maxlen_reg;
    logic [AWIDTH + DWIDTH + BWIDTH + 2 : 0]    pipeline_reg;
    
    //------------------------------------------------------------------------------------
    //      Сквозная трансляция сигнала занятости
    assign s_busy = m_busy;
    
    //------------------------------------------------------------------------------------
    //      Сквозная трансляция ответов чтения
    assign s_rdat = m_rdat;
    assign s_rval = m_rval;
    
    //------------------------------------------------------------------------------------
    //      Регистр начального адреса транзакции
    always @(posedge reset, posedge clk)
        if (reset)
            saddr_reg <= '0;
        else if (~m_busy & last)
            saddr_reg <= s_addr;
        else
            saddr_reg <= saddr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр следующего ожидаемого адреса транзакции
    always @(posedge reset, posedge clk)
        if (reset)
            naddr_reg <= '0;
        else if (~m_busy)
            naddr_reg <= s_addr + 1'b1;
        else
            naddr_reg <= naddr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регист запроса транзакции записи
    always @(posedge reset, posedge clk)
        if (reset)
            wreq_reg <= '0;
        else if (~m_busy)
            wreq_reg <= s_wreq;
        else
            wreq_reg <= wreq_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр записываемых данных
    always @(posedge reset, posedge clk)
        if (reset)
            wdat_reg <= '0;
        else if (~m_busy)
            wdat_reg <= s_wdat;
        else
            wdat_reg <= wdat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр запроса транзакции чтения
    always @(posedge reset, posedge clk)
        if (reset)
            rreq_reg <= '0;
        else if (~m_busy)
            rreq_reg <= s_rreq;
        else
            rreq_reg <= rreq_reg;
    
    //------------------------------------------------------------------------------------
    //      Признак обнаружения последовательного доступа
    assign seq_detect = ((s_wreq & wreq_reg) | (s_rreq & rreq_reg)) & (naddr_reg == s_addr);
    
    //------------------------------------------------------------------------------------
    //      Счетчик длины последовательного доступа
    initial len_cnt = {{BWIDTH - 1{1'b0}}, 1'b1};
    always @(posedge reset, posedge clk)
        if (reset)
            len_cnt <= {{BWIDTH - 1{1'b0}}, 1'b1};
        else if (~m_busy)
            if (seq_detect)
                len_cnt <= len_cnt + 1'b1;
            else
                len_cnt <= {{BWIDTH - 1{1'b0}}, 1'b1};
        else
            len_cnt <= len_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака достижения максимально возможной длины
    always @(posedge reset, posedge clk)
        if (reset)
            maxlen_reg <= '0;
        else if (~m_busy)
            maxlen_reg <= (&len_cnt) & seq_detect;
        else
            maxlen_reg <= maxlen_reg;
    
    //------------------------------------------------------------------------------------
    //      Признак прохождения последней команды последовательного доступа
    assign last = ~seq_detect | maxlen_reg;
    
    //------------------------------------------------------------------------------------
    //      Выходная регистровая ступень
    initial pipeline_reg = {{AWIDTH + BWIDTH{1'b0}}, 1'b1, {DWIDTH + 2{1'b0}}};
    always @(posedge reset, posedge clk)
        if (reset)
            pipeline_reg <= {{AWIDTH + BWIDTH{1'b0}}, 1'b1, {DWIDTH + 2{1'b0}}};
        else if (~m_busy)
            pipeline_reg <= {
                saddr_reg,  // адрес начала последовательного доступа
                len_cnt,    // текущая длина последовательного доступа
                last,       // признак последней транзакции
                wreq_reg,   // запрос на запись
                wdat_reg,   // данные на запись
                rreq_reg    // запрос на чтение
            };
        else
            pipeline_reg <= pipeline_reg;
    
    //------------------------------------------------------------------------------------
    //      Выходные сигналы интерфейса ведущего
    assign {
        m_addr,
        m_slen,
        m_last,
        m_wreq,
        m_wdat,
        m_rreq
    } = pipeline_reg;
    
endmodule: mmv_sequencer