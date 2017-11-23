`timescale  1ns / 1ps
module mmv_to_mmb_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned     AWIDTH  = 4;        // Разрядность адреса
    localparam int unsigned     DWIDTH  = 8;        // Разрядность данных
    localparam int unsigned     BWIDTH  = 4;        // Разрядность размера пакета
    localparam int unsigned     RDPENDS = 2;        // Максимальное количество незавершенных транзакций чтения
    localparam                  RAMTYPE = "AUTO";   // Тип блоков встроенной памяти ("MLAB"; "M20K"; ...)
    localparam int unsigned     RDDELAY = 4;        // Задержка выдачи данных при чтении (RDDELAY > 0)
    localparam string           MODE    = "RANDOM"; // Режим работы ("RANDOM" | "MEMORY")
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                       reset;
    logic                       clk;
    //
    logic [AWIDTH - 1 : 0]      s_addr;
    logic                       s_wreq;
    logic [DWIDTH - 1 : 0]      s_wdat;
    logic                       s_rreq;
    logic [DWIDTH - 1 : 0]      s_rdat;
    logic                       s_rval;
    logic                       s_busy;
    //
    logic [AWIDTH - 1 : 0]      m_addr;
    logic [BWIDTH - 1 : 0]      m_bcnt;
    logic                       m_wreq;
    logic [DWIDTH - 1 : 0]      m_wdat;
    logic                       m_rreq;
    logic [DWIDTH - 1 : 0]      m_rdat;
    logic                       m_rval;
    logic                       m_busy;
    
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
    /*
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        s_addr = 0;
        s_wreq = 0;
        s_wdat = 0;
        s_rreq = 0;
    end
    */
    
    //------------------------------------------------------------------------------------
    //      Модель ведущего устройства интерфейса MemoryMapped с произвольной
    //      латентностью чтения, реализующая непрерывную генерацию случайных транзакций
    mmv_master_model
    #(
        .DWIDTH     (DWIDTH),   // Разрядность данных
        .AWIDTH     (AWIDTH)    // Разрядность адреса
    )
    the_mmv_master_model
    (
        // Тактирование и сброс
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Интерфейс MemoryMapped (ведомый)
        .m_addr     (s_addr),   // o  [AWIDTH - 1 : 0]
        .m_wreq     (s_wreq),   // o
        .m_wdat     (s_wdat),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (s_rreq),   // o
        .m_rdat     (s_rdat),   // i  [DWIDTH - 1 : 0]
        .m_rval     (s_rval),   // i
        .m_busy     (s_busy)    // i
    ); // the_mmv_master_model
    
    
    //------------------------------------------------------------------------------------
    //      Модуль преобразования интерфейса MemoryMapped с произвольной латентностью
    //      чтения в интерфейс MemoryMapped с пакетным доступом
    mmv_to_mmb
    #(
        .AWIDTH     (AWIDTH),   // Разрядность адреса
        .DWIDTH     (DWIDTH),   // Разрядность данных
        .BWIDTH     (BWIDTH),   // Разрядность размера пакета
        .RAMTYPE    (RAMTYPE)   // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    the_mmv_to_mmb
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Интерфейсы ведомых (подключаются к ведущим)
        .s_addr     (s_addr),   // i  [AWIDTH - 1 : 0]
        .s_wreq     (s_wreq),   // i
        .s_wdat     (s_wdat),   // i  [DWIDTH - 1 : 0]
        .s_rreq     (s_rreq),   // i
        .s_rdat     (s_rdat),   // o  [DWIDTH - 1 : 0]
        .s_rval     (s_rval),   // o
        .s_busy     (s_busy),   // o
        
        // Интерфейс ведущего (подключается к ведомому)
        .m_addr     (m_addr), // o  [AWIDTH - 1 : 0]
        .m_bcnt     (m_bcnt), // o  [BWIDTH - 1 : 0]
        .m_wreq     (m_wreq), // o
        .m_wdat     (m_wdat), // o  [DWIDTH - 1 : 0]
        .m_rreq     (m_rreq), // o
        .m_rdat     (m_rdat), // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval), // i
        .m_busy     (m_busy)  // i
    ); // the_mmv_to_mmb
    
    //------------------------------------------------------------------------------------
    //      Модель ведомого устройства интерфейса MemoryMapped с пакетным доступом.
    //      Значение параметра MODE определяет режим работы:
    //          MODE = "RANDOM"  -  записываемые значения игнорируются,
    //                              при чтении генерируются случайные данные;
    //          MODE = "MEMORY"  -  модуль работает в режиме памяти со случайным
    //                              доступом.
    mmb_slave_model
    #(
        .DWIDTH     (DWIDTH),   // Разрядность данных
        .AWIDTH     (AWIDTH),   // Разрядность адреса
        .BWIDTH     (BWIDTH),   // Разрядность размера пакета
        .RDDELAY    (RDDELAY),  // Задержка выдачи данных при чтении (RDDELAY > 0)
        .RDPENDS    (RDPENDS),  // Максимальное количество незавершенных чтений
        .MODE       (MODE)      // Режим работы ("RANDOM" | "MEMORY")
    )
    the_mmb_slave_model
    (
        // Тактирование и сброс
        .reset      (reset),    // i 
        .clk        (clk),      // i
        
        // Интерфейс MemoryMapped (ведомый)
        .s_addr     (m_addr),   // i  [AWIDTH - 1 : 0]
        .s_bcnt     (m_bcnt),   // i  [BWIDTH - 1 : 0]
        .s_wreq     (m_wreq),   // i
        .s_wdat     (m_wdat),   // i  [DWIDTH - 1 : 0]
        .s_rreq     (m_rreq),   // i
        .s_rdat     (m_rdat),   // o  [DWIDTH - 1 : 0]
        .s_rval     (m_rval),   // o
        .s_busy     (m_busy)    // o
    ); // the_mmb_slave_model
    
endmodule: mmv_to_mmb_tb