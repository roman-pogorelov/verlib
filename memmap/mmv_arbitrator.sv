/*
    //------------------------------------------------------------------------------------
    //      Арбитр доступа нескольких ведущих интерфейса MemoryMapped с произвольной 
    //      латентностью чтения к одному ведомому
    mmv_arbitrator
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     (), // Разрядность данных
        .MASTERS    (), // Количество подключаемых ведущих
        .RDPENDS    (), // Максимальное количество незавершенных транзакций чтения
        .SCHEME     (), // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
        .RAMTYPE    ()  // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    the_mmv_arbitrator
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейсы ведомых (подключаются к ведущим)
        .s_addr     (), // i  [MASTERS - 1 : 0][AWIDTH - 1 : 0]
        .s_wreq     (), // i  [MASTERS - 1 : 0]
        .s_wdat     (), // i  [MASTERS - 1 : 0][DWIDTH - 1 : 0]
        .s_rreq     (), // i  [MASTERS - 1 : 0]
        .s_rdat     (), // o  [MASTERS - 1 : 0][DWIDTH - 1 : 0]
        .s_rval     (), // o  [MASTERS - 1 : 0]
        .s_busy     (), // o  [MASTERS - 1 : 0]
        
        // Интерфейс ведущего (подключается к ведомому)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i  [DWIDTH - 1 : 0]
        .m_busy     ()  // i
    ); // the_mmv_arbitrator
*/

module mmv_arbitrator
#(
    parameter int unsigned                          AWIDTH  = 8,        // Разрядность адреса
    parameter int unsigned                          DWIDTH  = 8,        // Разрядность данных
    parameter int unsigned                          MASTERS = 2,        // Количество подключаемых ведущих (MASTERS > 1)
    parameter int unsigned                          RDPENDS = 2,        // Максимальное количество незавершенных транзакций чтения
    parameter string                                SCHEME  = "RR",     // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
    parameter                                       RAMTYPE = "AUTO"    // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
)
(
    // Сброс и тактирование
    input  logic                                    reset,
    input  logic                                    clk,
    
    // Интерфейсы ведомых (подключаются с ведущим)
    input  logic [MASTERS - 1 : 0][AWIDTH - 1 : 0]  s_addr,
    input  logic [MASTERS - 1 : 0]                  s_wreq,
    input  logic [MASTERS - 1 : 0][DWIDTH - 1 : 0]  s_wdat,
    input  logic [MASTERS - 1 : 0]                  s_rreq,
    output logic [MASTERS - 1 : 0][DWIDTH - 1 : 0]  s_rdat,
    output logic [MASTERS - 1 : 0]                  s_rval,
    output logic [MASTERS - 1 : 0]                  s_busy,
    
    // Интерфейс ведущего (подключается с ведомому)
    output logic [AWIDTH - 1 : 0]                   m_addr,
    output logic                                    m_wreq,
    output logic [DWIDTH - 1 : 0]                   m_wdat,
    output logic                                    m_rreq,
    input  logic [DWIDTH - 1 : 0]                   m_rdat,
    input  logic                                    m_rval,
    input  logic                                    m_busy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [MASTERS - 1 : 0]                         request;
    logic [MASTERS - 1 : 0]                         grant;
    logic [MASTERS - 1 : 0]                         read_position;
    logic                                           read_enable;
    logic                                           read_valid;
    
    //------------------------------------------------------------------------------------
    //      Сигналы запроса доступа со стороны ведущих
    assign request = s_wreq | s_rreq;
    
    //------------------------------------------------------------------------------------
    //      Арбитр доступа нескольких абонентов к одному ресурсу
    arbitrator
    #(
        .REQS           (MASTERS),                              // Количество абонентов (REQS > 1)
        .SCHEME         (SCHEME)                                // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
    )
    the_arbitrator
    (
        // Сброс и тактирование
        .reset          (reset),                                // i
        .clk            (clk),                                  // i
        
        // Вектор запросов на обслуживание
        .req            (request),                              // i  [REQS - 1 : 0]
        
        // Готовность обработать запрос
        .rdy            (~m_busy & (~m_rreq | read_enable)),    // i
        
        // Вектор гранта на обслуживание
        .gnt            (grant),                                // o  [REQS - 1 : 0]
        
        // Номер порта, получившего грант
        .num            (  )                                    // o  [$clog2(REQS) - 1 : 0]
    ); // the_arbitrator
    
    //------------------------------------------------------------------------------------
    //      Коммутация сигнала отсутствия готовности
    assign s_busy = ~grant | {MASTERS{m_busy}} | (s_rreq & ~{MASTERS{read_enable}});
    
    //------------------------------------------------------------------------------------
    //      Разветвление данных чтения от ведомого ко всем ведущим
    assign s_rdat = {MASTERS{m_rdat}};
    
    //------------------------------------------------------------------------------------
    //      Коммутация сигналов управления доступом
    assign m_wreq = |(s_wreq & grant);
    assign m_rreq = |(s_rreq & grant) & read_enable;
    
    //------------------------------------------------------------------------------------
    //      Коммутация шины адреса
    always_comb begin
        for (int i = 0; i < AWIDTH; i++) begin
            logic [MASTERS - 1 : 0] addr_comm;
            for (int j = 0; j < MASTERS; j++) begin
                addr_comm[j] = s_addr[j][i] & grant[j];
            end
            m_addr[i] = |addr_comm;
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Коммутация шины данных на запись
    always_comb begin
        for (int i = 0; i < DWIDTH; i++) begin
            logic [MASTERS - 1 : 0] wdat_comm;
            for (int j = 0; j < MASTERS; j++) begin
                wdat_comm[j] = s_wdat[j][i] & grant[j];
            end
            m_wdat[i] = |wdat_comm;
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Генерация буфера коммутаций чтения необходимой длины
    generate
        if (RDPENDS > 1) begin: rd_direction_fifo_generation
            //------------------------------------------------------------------------------------
            //      Одноклоковый FIFO буфер для потокового интерфейса DataStream
            //      на ядре от Altera
            ds_alt_scfifo
            #(
                .DWIDTH             (MASTERS),          // Разрядность потока
                .DEPTH              (RDPENDS),          // Глубина FIFO
                .RAMTYPE            (RAMTYPE)           // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
            )
            rd_direction_fifo
            (
                // Сброс и тактирование
                .reset              (reset),            // i
                .clk                (clk),              // i
                
                // Входной потоковый интерфейс
                .i_dat              (grant),            // i  [DWIDTH - 1 : 0]
                .i_val              (m_rreq & ~m_busy), // i
                .i_rdy              (read_enable),      // o
                
                // Выходной потоковый интерфейс
                .o_dat              (read_position),    // o  [DWIDTH - 1 : 0]
                .o_val              (read_valid),       // o
                .o_rdy              (m_rval)            // i
            ); // rd_direction_fifo
        end
        else begin: rd_direction_onereg_generation
            //------------------------------------------------------------------------------------
            //      Буфер на одной регистровой ступени для потокового интерфейса DataStream
            ds_onereg_buffer
            #(
                .WIDTH      (MASTERS)           // Разрядность потокового интерфейса
            )
            rd_direction_onereg_buffer
            (
                // Сброс и тактирование
                .reset      (reset),            // i
                .clk        (clk),              // i
                
                // Входной потоковый интерфейс
                .i_dat      (grant),            // i [WIDTH - 1 : 0]
                .i_val      (m_rreq & ~m_busy), // i
                .i_rdy      (read_enable),      // o
                
                // Выходной потоковый интерфейс
                .o_dat      (read_position),    // o [WIDTH - 1 : 0]
                .o_val      (read_valid),       // o
                .o_rdy      (m_rval)            // i
            ); // rd_direction_onereg_buffer
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Коммутация сигналов подтверждения считываемых данных
    assign s_rval = read_position & {MASTERS{read_valid}} & {MASTERS{m_rval}};
    
endmodule: mmv_arbitrator