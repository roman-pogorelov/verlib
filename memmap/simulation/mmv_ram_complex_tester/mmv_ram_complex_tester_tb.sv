`timescale  1ns / 1ps
module mmv_ram_complex_tester_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned                     MAWIDTH = 8;        // Разрядность шины адреса памяти
    localparam int unsigned                     MDWIDTH = 8;        // Разрядность шины данных (должна быть степенью двойки)
    localparam int unsigned                     CDWIDTH = 16;       // Разрядность шины данных интерфейса управления
    localparam int unsigned                     RDDELAY = 16;       // Задержка выдачи данных при чтении (RDDELAY > 0)
    localparam string                           MODE    = "MEMORY"; // Режим работы ("RANDOM" | "MEMORY")
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                   reset;
    logic                   clk;
    //
    logic [2 : 0]           ctl_addr;
    logic                   ctl_wreq;
    logic [CDWIDTH - 1 : 0] ctl_wdat;
    logic                   ctl_rreq;
    logic [CDWIDTH - 1 : 0] ctl_rdat;
    logic                   ctl_rval;
    //
    logic [MAWIDTH - 1 : 0] m_addr;
    logic                   m_wreq;
    logic [MDWIDTH - 1 : 0] m_wdat;
    logic [MDWIDTH - 1 : 0] m_wdat_affected;
    logic                   m_rreq;
    logic [MDWIDTH - 1 : 0] m_rdat;
    logic                   m_rval;
    logic                   m_busy;
    
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
        ctl_addr = 0;
        ctl_wreq = 0;
        ctl_wdat = 0;
        ctl_rreq = 0;
    end
    
    //------------------------------------------------------------------------------------
    //      Запуск теста памяти
    initial begin
        #50001ps;
        ctl_wreq = 1;
        #10000ps;
        ctl_wreq = 0;
    end
    
    //------------------------------------------------------------------------------------
    //      Имитация ошибки доступа к одной ячейке
    assign m_wdat_affected = (m_addr == 56) ? {m_wdat[MDWIDTH - 1 : 1], m_wdat[1]} : m_wdat;
    
    //------------------------------------------------------------------------------------
    //      Модуль комплексного тестирования памяти со случайным доступом
    mmv_ram_complex_tester
    #(
        .MAWIDTH    (MAWIDTH),      // Разрядность шины адреса памяти
        .MDWIDTH    (MDWIDTH),      // Разрядность шины данных (должна быть степенью двойки)
        .CDWIDTH    (CDWIDTH)       // Разрядность шины данных интерфейса управления
    )
    the_mmv_ram_complex_tester
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Интерфейс управления (латентность по чтению - 1 такт)
        .ctl_addr   (ctl_addr),     // i  [2 : 0]
        .ctl_wreq   (ctl_wreq),     // i
        .ctl_wdat   (ctl_wdat),     // i  [CDWIDTH - 1 : 0]
        .ctl_rreq   (ctl_rreq),     // i
        .ctl_rdat   (ctl_rdat),     // o  [CDWIDTH - 1 : 0]
        .ctl_rval   (ctl_rval),     // o
        
        // Тестирующий интерфейс ведущего
        .m_addr     (m_addr),       // o  [MAWIDTH - 1 : 0]
        .m_wreq     (m_wreq),       // o
        .m_wdat     (m_wdat),       // o  [MDWIDTH - 1 : 0]
        .m_rreq     (m_rreq),       // o
        .m_rdat     (m_rdat),       // i  [MDWIDTH - 1 : 0]
        .m_rval     (m_rval),       // i
        .m_busy     (m_busy)        // i
    ); // the_mmv_ram_complex_tester
    
    //------------------------------------------------------------------------------------
    //      Модель ведомого устройства интерфейса  MemoryMapped с произвольной
    //      латентностью чтения, реализующую случайную обработку приходящих транзакций
    mmv_slave_model
    #(
        .DWIDTH     (MDWIDTH),          // Разрядность данных
        .AWIDTH     (MAWIDTH),          // Разрядность адреса
        .RDDELAY    (RDDELAY),          // Задержка выдачи данных при чтении (RDDELAY > 0)
        .MODE       (MODE)              // Режим работы ("RANDOM" | "MEMORY")
    )
    the_mmv_slave_model
    (
        // Тактирование и сброс
        .reset      (reset),            // i 
        .clk        (clk),              // i
        
        // Интерфейс MemoryMapped (ведомый)
        .s_addr     (m_addr),           // i  [AWIDTH - 1 : 0]
        .s_wreq     (m_wreq),           // i
        .s_wdat     (m_wdat_affected),  // i  [DWIDTH - 1 : 0]
        .s_rreq     (m_rreq),           // i
        .s_rdat     (m_rdat),           // o  [DWIDTH - 1 : 0]
        .s_rval     (m_rval),           // o
        .s_busy     (m_busy)            // o
    ); // mmv_slave_model
    
endmodule: mmv_ram_complex_tester_tb