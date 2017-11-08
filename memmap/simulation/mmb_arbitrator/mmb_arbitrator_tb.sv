`timescale  1ns / 1ps
module mmb_arbitrator_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned                 AWIDTH      = 8;        // Разрядность адреса
    localparam int unsigned                 DWIDTH      = 8;        // Разрядность данных
    localparam int unsigned                 BWIDTH      = 4;        // Разрядность размера пакета
    localparam int unsigned                 MASTERS     = 2;        // Количество подключаемых ведущих (MASTERS > 1)
    localparam int unsigned                 RDPENDS     = 1;        // Максимальное количество незавершенных транзакций чтения
    localparam string                       SCHEME      = "RR";     // Схема арбитража ("RR" - циклическая; "FP" - фиксированная)
    localparam                              RAMTYPE     = "AUTO";   // Тип блоков встроенной памяти ("MLAB"; "M20K"; ...)
    localparam int unsigned                 RDDELAY     = 8;        // Задержка выдачи данных при чтении (RDDELAY > 0)
    localparam string                       MODE        = "MEMORY"; // Режим работы ("RANDOM" | "MEMORY")
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                                   reset;
    logic                                   clk;
    //
    logic [MASTERS - 1 : 0][AWIDTH - 1 : 0] s_addr;
    logic [MASTERS - 1 : 0][BWIDTH - 1 : 0] s_bcnt;
    logic [MASTERS - 1 : 0]                 s_wreq;
    logic [MASTERS - 1 : 0][DWIDTH - 1 : 0] s_wdat;
    logic [MASTERS - 1 : 0]                 s_rreq;
    logic [MASTERS - 1 : 0][DWIDTH - 1 : 0] s_rdat;
    logic [MASTERS - 1 : 0]                 s_rval;
    logic [MASTERS - 1 : 0]                 s_busy;
    //
    logic [AWIDTH - 1 : 0]                  b_addr;
    logic [BWIDTH - 1 : 0]                  b_bcnt;
    logic                                   b_wreq;
    logic [DWIDTH - 1 : 0]                  b_wdat;
    logic                                   b_rreq;
    logic [DWIDTH - 1 : 0]                  b_rdat;
    logic                                   b_rval;
    logic                                   b_busy;
    //
    logic [AWIDTH - 1 : 0]                  m_addr;
    logic [BWIDTH - 1 : 0]                  m_bcnt;
    logic                                   m_wreq;
    logic [DWIDTH - 1 : 0]                  m_wdat;
    logic                                   m_rreq;
    logic [DWIDTH - 1 : 0]                  m_rdat;
    logic                                   m_rval;
    logic                                   m_busy;
    
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
        s_addr = 0;
        s_bcnt = 0;
        s_wreq = 0;
        s_wdat = 0;
        s_rreq = 0;
    end
    
    //------------------------------------------------------------------------------------
    //      Арбитр доступа нескольких ведущих интерфейса MemoryMapped с пакетным
    //      доступом к одному ведомому
    mmb_arbitrator
    #(
        .AWIDTH     (AWIDTH),       // Разрядность адреса
        .DWIDTH     (DWIDTH),       // Разрядность данных
        .BWIDTH     (BWIDTH),       // Разрядность размера пакета
        .MASTERS    (MASTERS),      // Количество подключаемых ведущих
        .RDPENDS    (RDPENDS),      // Максимальное количество незавершенных транзакций чтения
        .SCHEME     (SCHEME),       // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
        .RAMTYPE    (RAMTYPE)       // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    the_mmb_arbitrator
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Интерфейсы ведомых (подключаются к ведущим)
        .s_addr     (s_addr),       // i  [MASTERS - 1 : 0][AWIDTH - 1 : 0]
        .s_bcnt     (s_bcnt),       // i  [MASTERS - 1 : 0][BWIDTH - 1 : 0]
        .s_wreq     (s_wreq),       // i  [MASTERS - 1 : 0]
        .s_wdat     (s_wdat),       // i  [MASTERS - 1 : 0][DWIDTH - 1 : 0]
        .s_rreq     (s_rreq),       // i  [MASTERS - 1 : 0]
        .s_rdat     (s_rdat),       // o  [MASTERS - 1 : 0][DWIDTH - 1 : 0]
        .s_rval     (s_rval),       // o  [MASTERS - 1 : 0]
        .s_busy     (s_busy),       // o  [MASTERS - 1 : 0]
        
        // Интерфейс ведущего (подключается к ведомому)
        .m_addr     (b_addr),       // o  [AWIDTH - 1 : 0]
        .m_bcnt     (b_bcnt),       // o  [BWIDTH - 1 : 0]
        .m_wreq     (b_wreq),       // o
        .m_wdat     (b_wdat),       // o  [DWIDTH - 1 : 0]
        .m_rreq     (b_rreq),       // o
        .m_rdat     (b_rdat),       // i  [DWIDTH - 1 : 0]
        .m_rval     (b_rval),       // i  [DWIDTH - 1 : 0]
        .m_busy     (b_busy)        // i
    ); // the_mmb_arbitrator
    
    //------------------------------------------------------------------------------------
    //      Регистровый буфер интерфейса MemoryMapped с пакетным доступом, лишенный
    //      комбинационных связей между входами и выходами
    mmb_reg_buffer
    #(
        .AWIDTH     (AWIDTH),   // Разрядность адреса
        .DWIDTH     (DWIDTH),   // Разрядность данных
        .BWIDTH     (BWIDTH)    // Разрядность размера пакета
    )
    the_mmb_reg_buffer
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Интерфейсы ведомого (подключаются с ведущему)
        .s_addr     (b_addr),   // i  [AWIDTH - 1 : 0]
        .s_bcnt     (b_bcnt),   // i  [BWIDTH - 1 : 0]
        .s_wreq     (b_wreq),   // i
        .s_wdat     (b_wdat),   // i  [DWIDTH - 1 : 0]
        .s_rreq     (b_rreq),   // i
        .s_rdat     (b_rdat),   // o  [DWIDTH - 1 : 0]
        .s_rval     (b_rval),   // o
        .s_busy     (b_busy),   // o
        
        // Интерфейс ведущего (подключается с ведомому)
        .m_addr     (m_addr),   // o  [AWIDTH - 1 : 0]
        .m_bcnt     (m_bcnt),   // o  [BWIDTH - 1 : 0]
        .m_wreq     (m_wreq),   // o
        .m_wdat     (m_wdat),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (m_rreq),   // o
        .m_rdat     (m_rdat),   // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),   // i
        .m_busy     (m_busy)    // i
    ); // the_mmb_reg_buffer
    
    //------------------------------------------------------------------------------------
    //      Модель ведомого устройства интерфейса  MemoryMapped с пакетным доступом.
    //      Значение параметра MODE определяет режим работы:
    //          MODE = "RANDOM"  -  записываемые значения игнорируются,
    //                              при чтении генерируются случайные данные;
    //          MODE = "MEMORY"  -  модуль работает в режиме памяти со случайным
    //                              доступом.
    mmb_slave_model
    #(
        .DWIDTH     (DWIDTH),       // Разрядность данных
        .AWIDTH     (AWIDTH),       // Разрядность адреса
        .BWIDTH     (BWIDTH),       // Разрядность размера пакета
        .RDDELAY    (RDDELAY),      // Задержка выдачи данных при чтении (RDDELAY > 0)
        .RDPENDS    (RDPENDS),      // Максимальное количество незавершенных чтений
        .MODE       (MODE)          // Режим работы ("RANDOM" | "MEMORY")
    )
    the_mmb_slave_model
    (
        // Тактирование и сброс
        .reset      (reset),        // i 
        .clk        (clk),          // i
        
        // Интерфейс MemoryMapped (ведомый)
        .s_addr     (m_addr),       // i  [AWIDTH - 1 : 0]
        .s_bcnt     (m_bcnt),       // i  [BWIDTH - 1 : 0]
        .s_wreq     (m_wreq),       // i
        .s_wdat     (m_wdat),       // i  [DWIDTH - 1 : 0]
        .s_rreq     (m_rreq),       // i
        .s_rdat     (m_rdat),       // o  [DWIDTH - 1 : 0]
        .s_rval     (m_rval),       // o
        .s_busy     (m_busy)        // o
    ); // mmb_slave_model
    
endmodule: mmb_arbitrator_tb