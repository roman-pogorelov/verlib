`timescale  1ns / 1ps
module mmv_ram_ab_tester_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned                     AWIDTH  = 8;        // Разрядность адреса
    localparam int unsigned                     DWIDTH  = 8;        // Разрядность данных
    localparam int unsigned                     RDDELAY = 16;       // Задержка выдачи данных при чтении (RDDELAY > 0)
    localparam string                           MODE    = "MEMORY"; // Режим работы ("RANDOM" | "MEMORY")
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                   reset;
    logic                   clk;
    //
    logic                   clear;
    logic                   start;
    logic                   ready;
    logic                   fault;
    logic                   done;
    //
    logic [AWIDTH - 1 : 0]  m_addr;
    logic                   m_wreq;
    logic [DWIDTH - 1 : 0]  m_wdat;
    logic                   m_rreq;
    logic [DWIDTH - 1 : 0]  m_rdat;
    logic                   m_rval;
    logic                   m_busy;
    //
    logic [AWIDTH - 1 : 0]  m_addr_affected;
    
    
    //------------------------------------------------------------------------------------
    //      Сброс
    initial begin
        reset = '1;
        #10001ps;
        reset = '0;
    end
    
    //------------------------------------------------------------------------------------
    //      Тактирование
    initial clk = '1;
    always  clk = #5 ~clk;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        clear = 0;
        start = 0;
    end
    
    //------------------------------------------------------------------------------------
    //      Запуск теста памяти
    initial begin
        #50001ps;
        start = 1;
        #10000ps;
        start = 0;
    end
    
    //------------------------------------------------------------------------------------
    //      Модуль тестирования шины данных памяти со случайным доступом
    mmv_ram_ab_tester
    #(
        .AWIDTH     (AWIDTH),   // Разрядность адреса
        .DWIDTH     (DWIDTH)    // Разрядность данных
    )
    the_mmv_ram_ab_tester
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Интерфейс управления
        .clear      (clear),    // i  Синхронный сброс
        .start      (start),    // i  Запуск теста
        .ready      (ready),    // o  Готовность к запуску теста
        .fault      (fault),    // o  Одиночный импульс индикации ошибки
        .done       (done),     // o  Одиночный импульс окончания теста
        
        // Тестирующий интерфейс ведущего
        .m_addr     (m_addr),   // o  [AWIDTH - 1 : 0]
        .m_wreq     (m_wreq),   // o
        .m_wdat     (m_wdat),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (m_rreq),   // o
        .m_rdat     (m_rdat),   // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),   // i
        .m_busy     (m_busy)    // i
    ); // the_mmv_ram_ab_tester
    
    //------------------------------------------------------------------------------------
    //      Моделирование неисправности линии адреса
    assign m_addr_affected = {m_addr[7 : 7], m_addr[5], m_addr[5 : 0]};
    
    
    //------------------------------------------------------------------------------------
    //      Модель ведомого устройства интерфейса  MemoryMapped с произвольной
    //      латентностью чтения, реализующую случайную обработку приходящих транзакций
    mmv_slave_model
    #(
        .DWIDTH     (DWIDTH),           // Разрядность данных
        .AWIDTH     (AWIDTH),           // Разрядность адреса
        .RDDELAY    (RDDELAY),          // Задержка выдачи данных при чтении (RDDELAY > 0)
        .MODE       (MODE)              // Режим работы ("RANDOM" | "MEMORY")
    )
    the_mmv_slave_model
    (
        // Тактирование и сброс
        .reset      (reset),            // i 
        .clk        (clk),              // i
        
        // Интерфейс MemoryMapped (ведомый)
        .s_addr     (m_addr_affected),  // i  [AWIDTH - 1 : 0]
        .s_wreq     (m_wreq),           // i
        .s_wdat     (m_wdat),           // i  [DWIDTH - 1 : 0]
        .s_rreq     (m_rreq),           // i
        .s_rdat     (m_rdat),           // o  [DWIDTH - 1 : 0]
        .s_rval     (m_rval),           // o
        .s_busy     (m_busy)            // o
    ); // mmv_slave_model
    
endmodule: mmv_ram_ab_tester_tb