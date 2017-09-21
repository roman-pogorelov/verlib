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
    
    
    //------------------------------------------------------------------------------------
    //      Кодирование состояний FSM
    enum logic [2 : 0] {
        st_idle  = 3'b000,
        st_read  = 3'b011,
        st_write = 3'b101
    } state;
    wire [2 : 0]
    
    
    
    
    
    //------------------------------------------------------------------------------------
    //      Одноклоковый FIFO буфер для потокового интерфейса DataStream
    //      на ядре от Altera
    ds_alt_scfifo
    #(
        .DWIDTH             (DWIDTH),       // Разрядность потока
        .DEPTH              (2**BWIDTH),    // Глубина FIFO
        .RAMTYPE            (RAMTYPE)       // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    wdata_fifo
    (
        // Сброс и тактирование
        .reset              (reset),        // i
        .clk                (clk),          // i
        
        // Входной потоковый интерфейс
        .i_dat              (s_wdat),       // i  [DWIDTH - 1 : 0]
        .i_val              (), // i
        .i_rdy              (  ),           // o
        
        // Выходной потоковый интерфейс
        .o_dat              (m_wdat),       // o  [DWIDTH - 1 : 0]
        .o_val              (  ),           // o
        .o_rdy              ()  // i
    ); // wdata_fifo

endmodule: mmv_to_mmb