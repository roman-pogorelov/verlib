/*
    //------------------------------------------------------------------------------------
    //      Регистровый буфер интерфейса MemoryMapped с произвольной латентностью
    //      чтения, лишенный комбинационных связей между входами и выходами
    mmv_reg_buffer
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     ()  // Разрядность данных
    )
    the_mmv_reg_buffer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейсы ведомого (подключаются с ведущему)
        .s_addr     (), // i  [AWIDTH - 1 : 0]
        .s_wreq     (), // i
        .s_wdat     (), // i  [DWIDTH - 1 : 0]
        .s_rreq     (), // i
        .s_rdat     (), // o  [DWIDTH - 1 : 0]
        .s_rval     (), // o
        .s_busy     (), // o
        
        // Интерфейс ведущего (подключается с ведомому)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_mmv_reg_buffer
*/

module mmv_reg_buffer
#(
    parameter int unsigned          AWIDTH  = 8,    // Разрядность адреса
    parameter int unsigned          DWIDTH  = 8     // Разрядность данных
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейсы ведомого (подключаются с ведущему)
    input  logic [AWIDTH - 1 : 0]   s_addr,
    input  logic                    s_wreq,
    input  logic [DWIDTH - 1 : 0]   s_wdat,
    input  logic                    s_rreq,
    output logic [DWIDTH - 1 : 0]   s_rdat,
    output logic                    s_rval,
    output logic                    s_busy,
    
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
    //      Объявление сигналов
    logic                           s_ready;
    logic                           m_request;
    logic                           m_wreq_int;
    logic                           m_rreq_int;
    logic [DWIDTH - 1 : 0]          s_rdat_reg;
    logic                           s_rval_reg;
    
    //------------------------------------------------------------------------------------
    //      Сигнал занятости интерфейса ведомого
    assign s_busy = ~s_ready;
    
    //------------------------------------------------------------------------------------
    //      Буфер потокового интерфейса DataStream на двух регистрах, лишенный
    //      комбинационных связей между входами и выходами
    ds_twinreg_buffer
    #(
        .WIDTH      (DWIDTH + AWIDTH + 2)   // Разрядность потокового интерфейса
    )
    the_ds_twinreg_buffer
    (
        // Сброс и тактирование
        .reset      (reset),                // i
        .clk        (clk),                  // i
        
        // Входной потоковый интерфейс
        .i_dat      ({                      // i  [WIDTH - 1 : 0]
                        s_addr,
                        s_wreq,
                        s_rreq,
                        s_wdat
                    }),
        .i_val      (s_wreq | s_rreq),      // i
        .i_rdy      (s_ready),              // o
        
        // Выходной потоковый интерфейс
        .o_dat      ({                      // o  [WIDTH - 1 : 0]
                        m_addr,
                        m_wreq_int,
                        m_rreq_int,
                        m_wdat
                    }),
        .o_val      (m_request),            // o
        .o_rdy      (~m_busy)               // i
    ); // the_ds_twinreg_buffer
    
    //------------------------------------------------------------------------------------
    //      Запросные сигналы интерфейса ведущего
    assign m_wreq = m_wreq_int & m_request;
    assign m_rreq = m_rreq_int & m_request;
    
    //------------------------------------------------------------------------------------
    //      Регистровая ступень читаемых данных
    always @(posedge reset, posedge clk)
        if (reset)
            s_rdat_reg <= '0;
        else
            s_rdat_reg <= m_rdat;
    assign s_rdat = s_rdat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистровая ступень строба читаемых данных
    always @(posedge reset, posedge clk)
        if (reset)
            s_rval_reg <= '0;
        else
            s_rval_reg <= m_rval;
    assign s_rval = s_rval_reg;
    
endmodule:mmv_reg_buffer