/*
    //------------------------------------------------------------------------------------
    //      Ре-синхронизатор интерфейса MemoryMapped с произвольной латентностью чтения
    mmv_dcfifo_synchronizer
    #(
        .AWIDTH         (), // Разрядность адреса
        .DWIDTH         (), // Разрядность данных
        .CMDLEN         (), // Длина FIFO ре-синхронизации комманд
        .READLEN        (), // Длина FIFO ре-синхронизации ответов на команды чтения
        .RAMTYPE        ()  // Тип блоков встроенной памяти ("MLAB" "M20K" ...)
    )
    the_mmv_dcfifo_synchronizer
    (
        // Сброс и тактирование интерфейса ведомого
        .s_reset        (), // i
        .s_clk          (), // i
        
        // Интерфейс ведомого (подключаются с ведущему)
        .s_addr         (), // i  [AWIDTH - 1 : 0]
        .s_wreq         (), // i
        .s_wdat         (), // i  [DWIDTH - 1 : 0]
        .s_rreq         (), // i
        .s_rdat         (), // o  [DWIDTH - 1 : 0]
        .s_rval         (), // o
        .s_busy         (), // o
        
        // Сброс и тактирование интерфейса ведущего
        .m_reset        (), // i
        .m_clk          (), // i
        
        // Интерфейс ведущего (подключается с ведомому)
        .m_addr         (), // o  [AWIDTH - 1 : 0]
        .m_wreq         (), // o
        .m_wdat         (), // o  [DWIDTH - 1 : 0]
        .m_rreq         (), // o
        .m_rdat         (), // i  [DWIDTH - 1 : 0]
        .m_rval         (), // i
        .m_busy         ()  // i
    ); // the_mmv_dcfifo_synchronizer
*/

module mmv_dcfifo_synchronizer
#(
    parameter int unsigned          AWIDTH  = 8,        // Разрядность адреса
    parameter int unsigned          DWIDTH  = 8,        // Разрядность данных
    parameter int unsigned          CMDLEN  = 8,        // Длина FIFO ре-синхронизации комманд
    parameter int unsigned          READLEN = 8,        // Длина FIFO ре-синхронизации ответов на команды чтения
    parameter                       RAMTYPE = "AUTO"    // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
)
(
    // Сброс и тактирование интерфейса ведомого
    input  logic                    s_reset,
    input  logic                    s_clk,
    
    // Интерфейс ведомого (подключаются с ведущему)
    input  logic [AWIDTH - 1 : 0]   s_addr,
    input  logic                    s_wreq,
    input  logic [DWIDTH - 1 : 0]   s_wdat,
    input  logic                    s_rreq,
    output logic [DWIDTH - 1 : 0]   s_rdat,
    output logic                    s_rval,
    output logic                    s_busy,
    
    // Сброс и тактирование интерфейса ведущего
    input  logic                    m_reset,
    input  logic                    m_clk,
    
    // Интерфейс ведущего (подключается с ведомому)
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
    localparam int unsigned CWIDTH = $clog2(READLEN + 1);
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [CWIDTH - 1 : 0]          s_rd_pend_cnt;
    logic                           s_rd_disable_reg;
    logic                           s_cmd_fifo_rdy;
    logic                           m_areq;
    logic                           m_type;
    
    //------------------------------------------------------------------------------------
    //      Счетчик незавершенных транзакций чтения со стороны интерфейса ведомого
    initial s_rd_pend_cnt = '0;
    always @(posedge s_reset, posedge s_clk)
        if (s_reset)
            s_rd_pend_cnt <= '0;
        else if ( (s_rreq & ~s_busy) & ~s_rval)
            s_rd_pend_cnt <= s_rd_pend_cnt + 1'b1;
        else if (~(s_rreq & ~s_busy) &  s_rval)
            s_rd_pend_cnt <= s_rd_pend_cnt - 1'b1;
        else
            s_rd_pend_cnt <= s_rd_pend_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр запрета прохождения запросов на чтение
    initial s_rd_disable_reg = '0;
    always @(posedge s_reset, posedge s_clk)
        if (s_reset)
            s_rd_disable_reg <= '0;
        else if (s_rd_disable_reg)
            s_rd_disable_reg <= ~s_rval;
        else
            s_rd_disable_reg <= (s_rd_pend_cnt == (READLEN - 1)) & (s_rreq & ~s_busy) & ~s_rval;
    
    //------------------------------------------------------------------------------------
    //      Признак занятости интерфейса ведомого
    assign s_busy = ~s_cmd_fifo_rdy | (s_rreq & s_rd_disable_reg);
    
    //------------------------------------------------------------------------------------
    //      Двухклоковый FIFO буфер для потокового интерфейса DataStream
    //      на ядре от Altera
    ds_alt_dcfifo
    #(
        .DWIDTH             (AWIDTH + DWIDTH + 1),                      // Разрядность потока
        .DEPTH              (CMDLEN),                                   // Глубина FIFO
        .RAMTYPE            (RAMTYPE)                                   // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    command_dcfifo
    (
        // Сброс и тактирование
        .reset              (s_reset),                                  // i
        .i_clk              (s_clk),                                    // i
        .o_clk              (m_clk),                                    // i
        
        // Входной потоковый интерфейс
        .i_dat              ({                                          // i  [DWIDTH - 1 : 0]
                                s_addr,
                                s_wdat,
                                s_wreq
                            }),
        .i_val              (s_wreq | (s_rreq & ~s_rd_disable_reg)),    // i
        .i_rdy              (s_cmd_fifo_rdy),                           // o
        
        // Выходной потоковый интерфейс
        .o_dat              ({                                          // o  [DWIDTH - 1 : 0]
                                m_addr,
                                m_wdat,
                                m_type
                            }),
        .o_val              (m_areq),                                   // o
        .o_rdy              (~m_busy)                                   // i
    ); // command_dcfifo
    
    //------------------------------------------------------------------------------------
    //      Запросные сигналы интерфейса ведущего
    assign m_wreq =  m_type & m_areq;
    assign m_rreq = ~m_type & m_areq;
    
    //------------------------------------------------------------------------------------
    //      Двухклоковый FIFO буфер для потокового интерфейса DataStream
    //      на ядре от Altera
    ds_alt_dcfifo
    #(
        .DWIDTH             (DWIDTH),   // Разрядность потока
        .DEPTH              (READLEN),  // Глубина FIFO
        .RAMTYPE            (RAMTYPE)   // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    rdata_dcfifo
    (
        // Сброс и тактирование
        .reset              (m_reset),  // i
        .i_clk              (m_clk),    // i
        .o_clk              (s_clk),    // i
        
        // Входной потоковый интерфейс
        .i_dat              (m_rdat),   // i  [DWIDTH - 1 : 0]
        .i_val              (m_rval),   // i
        .i_rdy              (  ),       // o
        
        // Выходной потоковый интерфейс
        .o_dat              (s_rdat),   // o  [DWIDTH - 1 : 0]
        .o_val              (s_rval),   // o
        .o_rdy              (1'b1)      // i
    ); // rdata_dcfifo
    
endmodule: mmv_dcfifo_synchronizer