/*
    //------------------------------------------------------------------------------------
    //      Модуль синхронизации интерфейса MemoryMapped между двумя доменами
    //      тактирования на основе механизма взаимного подтверждения
    mm_hs_synchronizer
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     (), // Разрядность данных
        .ESTAGES    (), // Количество дополнительных ступеней цепи синхронизации
        .HSTYPE     ()  // Схема взаимного подтверждения (2 - с двумя фазами, 4 - с четырьмя фазами)
    )
    the_mm_hs_synchronizer
    (
        // Сброс и тактирование интерфейса ведомого
        .s_reset    (), // i
        .s_clk      (), // i
        
        // Интерфейс ведомого (подключается к ведущему)
        .s_addr     (), // i  [AWIDTH - 1 : 0]
        .s_wreq     (), // i
        .s_wdat     (), // i  [DWIDTH - 1 : 0]
        .s_rreq     (), // i
        .s_rdat     (), // o  [DWIDTH - 1 : 0]
        .s_busy     (), // o
        
        // Сброс и тактирование интерфейса ведущего
        .m_reset    (), // i
        .m_clk      (), // i
        
        // Интерфейс ведущего (подключается к ведомому)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_busy     ()  // i
    ); // the_mm_hs_synchronizer
*/

//------------------------------------------------------------------------------------
//      Требования для синтеза и проверки временных соотношений Altera
`define ALT_ATTR_S2M "-name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -from [get_keepers {*mm_hs_synchronizer:*|s2m_hld_reg[*]}]\" "
`define ALT_ATTR_M2S "-name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -from [get_keepers {*mm_hs_synchronizer:*|m2s_hld_reg[*]}]\" "

module mm_hs_synchronizer
#(
    parameter int unsigned          AWIDTH  = 8,    // Разрядность адреса
    parameter int unsigned          DWIDTH  = 8,    // Разрядность данных
    parameter int unsigned          ESTAGES = 0,    // Количество дополнительных ступеней цепи синхронизации
    parameter int unsigned          HSTYPE  = 2     // Схема взаимного подтверждения (2 - с двумя фазами, 4 - с четырьмя фазами)
)
(
    // Сброс и тактирование интерфейса ведомого
    input  logic                    s_reset,
    input  logic                    s_clk,
    
    // Интерфейс ведомого (подключается с ведущему)
    input  logic [AWIDTH - 1 : 0]   s_addr,
    input  logic                    s_wreq,
    input  logic [DWIDTH - 1 : 0]   s_wdat,
    input  logic                    s_rreq,
    output logic [DWIDTH - 1 : 0]   s_rdat,
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
    input  logic                    m_busy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                           s_request;
    logic                           hs_src_rdy;
    logic                           hs_dst_req;
    logic                           npending_reg;
    //
    (* altera_attribute = {`ALT_ATTR_S2M} *) reg [AWIDTH + DWIDTH + 1 : 0] s2m_hld_reg;
    (* altera_attribute = {`ALT_ATTR_M2S} *) reg [DWIDTH - 1 : 0]          m2s_hld_reg;
    
    //------------------------------------------------------------------------------------
    //      Сигнал произвольного доступа (запись или чтение)
    assign s_request = s_wreq | s_rreq;
    
    //------------------------------------------------------------------------------------
    //      Модуль синхронизации передачи запроса между двумя асинхронными доменами
    //      на основе механизма взаимного подтверждения
    handshake_synchronizer
    #(
        .EXTRA_STAGES   (ESTAGES),                  // Количество дополнительных ступеней цепи синхронизации
        .HANDSHAKE_TYPE (HSTYPE)                    // Схема взаимного подтверждения (2 - с двумя фазами, 4 - с четырьмя фазами)
    )
    ctrl_synchronizer
    (
        // Сброс и тактирование домена источника
        .src_reset      (s_reset),                  // i
        .src_clk        (s_clk),                    // i
        
        // Сброс и тактирование домена приемника
        .dst_reset      (m_reset),                  // i
        .dst_clk        (m_clk),                    // i
        
        // Интерфейс домена источника
        .src_req        (s_request & npending_reg), // i
        .src_rdy        (hs_src_rdy),               // o
        
        // Интерфейс домена приемника
        .dst_req        (hs_dst_req),               // o
        .dst_rdy        (~m_busy)                   // i
    ); // ctrl_synchronizer
    
    //------------------------------------------------------------------------------------
    //      Регистр отсутствия незавершенной транзакции
    initial npending_reg = '1;
    always @(posedge s_reset, posedge s_clk)
        if (s_reset)
            npending_reg <= '1;
        else if (npending_reg)
            npending_reg <= ~(s_request & hs_src_rdy);
        else
            npending_reg <= hs_src_rdy;
    
    //------------------------------------------------------------------------------------
    //      Регистр удержания адреса, записываемых данных и сигналов управления при
    //      передаче в другой домен тактирования
    always @(posedge s_reset, posedge s_clk)
        if (s_reset)
            s2m_hld_reg <= '0;
        else if (s_request & npending_reg & hs_src_rdy)
            s2m_hld_reg <= {
                s_addr,
                s_wdat,
                s_wreq,
                s_rreq
            };
        else
            s2m_hld_reg <= s2m_hld_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр удержания читаемых данных при передаче в другой домен тактирования
    always @(posedge m_reset, m_clk)
        if (m_reset)
            m2s_hld_reg <= '0;
        else if (hs_dst_req & ~m_busy)
            m2s_hld_reg <= m_rdat;
        else
            m2s_hld_reg <= m2s_hld_reg;
    
    //------------------------------------------------------------------------------------
    //      Формирование выходных сигналов ведомого
    assign s_rdat = m2s_hld_reg;
    assign s_busy = npending_reg | ~hs_src_rdy;
    
    //------------------------------------------------------------------------------------
    //      Формирование выходных сигналов ведущего
    assign m_addr = s2m_hld_reg[AWIDTH + DWIDTH + 1 : DWIDTH + 2];
    assign m_wdat = s2m_hld_reg[DWIDTH + 1 : 2];
    assign m_wreq = s2m_hld_reg[1] & hs_dst_req;
    assign m_rreq = s2m_hld_reg[0] & hs_dst_req;
    
endmodule: mm_hs_synchronizer
