`timescale  1ns / 1ps
module mmv_arbitrator_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned                     AWIDTH  = 8;        // Разрядность адреса
    localparam int unsigned                     DWIDTH  = 8;        // Разрядность данных
    localparam int unsigned                     MASTERS = 3;        // Количество подключаемых ведущих (MASTERS > 1)
    localparam int unsigned                     RDPENDS = 2;        // Максимальное количество незавершенных транзакций чтения
    localparam string                           SCHEME  = "RR";     // Схема арбитража ("RR" - циклическая; "FP" - фиксированная)
    localparam                                  RAMTYPE = "AUTO";   // Тип блоков встроенной памяти ("MLAB"; "M20K"; ...)
    localparam int unsigned                     RDDELAY = 4;        // Задержка выдачи данных при чтении (RDDELAY > 0)
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                                       reset;
    logic                                       clk;
    //
    logic [MASTERS - 1 : 0][AWIDTH - 1 : 0]     s_addr;
    logic [MASTERS - 1 : 0]                     s_wreq;
    logic [MASTERS - 1 : 0][DWIDTH - 1 : 0]     s_wdat;
    logic [MASTERS - 1 : 0]                     s_rreq;
    logic [MASTERS - 1 : 0][DWIDTH - 1 : 0]     s_rdat;
    logic [MASTERS - 1 : 0]                     s_rval;
    logic [MASTERS - 1 : 0]                     s_busy;
    //
    logic [AWIDTH - 1 : 0]                      m_addr;
    logic                                       m_wreq;
    logic [DWIDTH - 1 : 0]                      m_wdat;
    logic                                       m_rreq;
    logic [DWIDTH - 1 : 0]                      m_rdat;
    logic                                       m_rval;
    logic                                       m_busy;
    
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
    //      Модель ведущего устройства интерфейса MemoryMapped с произвольной
    //      латентностью чтения, реализующая непрерывную генерацию случайных транзакций
    mmv_master_model
    #(
        .DWIDTH     (DWIDTH),           // Разрядность данных
        .AWIDTH     (AWIDTH)            // Разрядность адреса
    )
    the_mmv_master_model [MASTERS - 1 : 0]
    (
        // Тактирование и сброс
        .reset      ({MASTERS{reset}}), // i
        .clk        ({MASTERS{clk}}),   // i
        
        // Интерфейс MemoryMapped (ведомый)
        .m_addr     (s_addr),           // o  [AWIDTH - 1 : 0]
        .m_wreq     (s_wreq),           // o
        .m_wdat     (s_wdat),           // o  [DWIDTH - 1 : 0]
        .m_rreq     (s_rreq),           // o
        .m_rdat     (s_rdat),           // i  [DWIDTH - 1 : 0]
        .m_rval     (s_rval),           // i
        .m_busy     (s_busy)            // i
    ); // the_mmv_master_model
    
    //------------------------------------------------------------------------------------
    //      Арбитр доступа нескольких ведущих интерфейса MemoryMapped с произвольной 
    //      латентностью чтения к одному ведомому
    mmv_arbitrator
    #(
        .AWIDTH     (AWIDTH),   // Разрядность адреса
        .DWIDTH     (DWIDTH),   // Разрядность данных
        .MASTERS    (MASTERS),  // Количество подключаемых ведущих
        .RDPENDS    (RDPENDS),  // Максимальное количество незавершенных транзакций чтения
        .SCHEME     (SCHEME),   // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
        .RAMTYPE    (RAMTYPE)   // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    dut
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Интерфейсы ведомых (подключаются к ведущим)
        .s_addr     (s_addr),   // i  [MASTERS - 1 : 0][AWIDTH - 1 : 0]
        .s_wreq     (s_wreq),   // i  [MASTERS - 1 : 0]
        .s_wdat     (s_wdat),   // i  [MASTERS - 1 : 0][DWIDTH - 1 : 0]
        .s_rreq     (s_rreq),   // i  [MASTERS - 1 : 0]
        .s_rdat     (s_rdat),   // o  [MASTERS - 1 : 0][DWIDTH - 1 : 0]
        .s_rval     (s_rval),   // o  [MASTERS - 1 : 0]
        .s_busy     (s_busy),   // o  [MASTERS - 1 : 0]
        
        // Интерфейс ведущего (подключается к ведомому)
        .m_addr     (m_addr),   // o  [AWIDTH - 1 : 0]
        .m_wreq     (m_wreq),   // o
        .m_wdat     (m_wdat),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (m_rreq),   // o
        .m_rdat     (m_rdat),   // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),   // i  [DWIDTH - 1 : 0]
        .m_busy     (m_busy)    // i
    ); // dut
    
    //------------------------------------------------------------------------------------
    //      Модель ведомого устройства интерфейса  MemoryMapped с произвольной
    //      латентностью чтения, реализующую случайную обработку приходящих транзакций
    mmv_slave_model
    #(
        .DWIDTH     (DWIDTH),   // Разрядность данных
        .AWIDTH     (AWIDTH),   // Разрядность адреса
        .RDDELAY    (RDDELAY)   // Задержка выдачи данных при чтении (RDDELAY > 0)
    )
    the_mmv_slave_model
    (
        // Тактирование и сброс
        .reset      (reset),    // i 
        .clk        (clk),      // i
        
        // Интерфейс MemoryMapped (ведомый)
        .s_addr     (m_addr),   // i  [AWIDTH - 1 : 0]
        .s_wreq     (m_wreq),   // i
        .s_wdat     (m_wdat),   // i  [DWIDTH - 1 : 0]
        .s_rreq     (m_rreq),   // i
        .s_rdat     (m_rdat),   // o  [DWIDTH - 1 : 0]
        .s_rval     (m_rval),   // o
        .s_busy     (m_busy)    // o
    ); // mmv_slave_model
    
endmodule: mmv_arbitrator_tb