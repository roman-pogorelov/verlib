/*
    //------------------------------------------------------------------------------------
    //      Арбитр доступа нескольких ведущих интерфейса MemoryMapped к одному ведомому
    mm_arbitrator
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     (), // Разрядность данных
        .MASTERS    (), // Количество подключаемых ведущих
        .SCHEME     ()  // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
    )
    the_mm_arbitrator
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейсы ведомых (подключаются с ведущим)
        .s_addr     (), // i  [MASTERS - 1 : 0][AWIDTH - 1 : 0]
        .s_wreq     (), // i  [MASTERS - 1 : 0]
        .s_wdat     (), // i  [MASTERS - 1 : 0][DWIDTH - 1 : 0]
        .s_rreq     (), // i  [MASTERS - 1 : 0]
        .s_rdat     (), // o  [MASTERS - 1 : 0][DWIDTH - 1 : 0]
        .s_busy     (), // o  [MASTERS - 1 : 0]
        
        // Интерфейс ведущего (подключается с ведомому)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_busy     ()  // i
    ); // the_mm_arbitrator
*/

module mm_arbitrator
#(
    parameter int unsigned                          AWIDTH  = 8,    // Разрядность адреса
    parameter int unsigned                          DWIDTH  = 8,    // Разрядность данных
    parameter int unsigned                          MASTERS = 2,    // Количество подключаемых ведущих (MASTERS > 1)
    parameter string                                SCHEME  = "RR"  // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
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
    output logic [MASTERS - 1 : 0]                  s_busy,
    
    // Интерфейс ведущего (подключается с ведомому)
    output logic [AWIDTH - 1 : 0]                   m_addr,
    output logic                                    m_wreq,
    output logic [DWIDTH - 1 : 0]                   m_wdat,
    output logic                                    m_rreq,
    input  logic [DWIDTH - 1 : 0]                   m_rdat,
    input  logic                                    m_busy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [MASTERS - 1 : 0]                         request;
    logic [MASTERS - 1 : 0]                         grant;
    
    //------------------------------------------------------------------------------------
    //      Сигналы запроса доступа со стороны ведущих
    assign request = s_wreq | s_rreq;
    
    //------------------------------------------------------------------------------------
    //      Арбитр доступа нескольких абонентов к одному ресурсу
    arbitrator
    #(
        .REQS           (MASTERS),  // Количество абонентов (REQS > 1)
        .SCHEME         (SCHEME)    // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
    )
    the_arbitrator
    (
        // Сброс и тактирование
        .reset          (reset),    // i
        .clk            (clk),      // i
        
        // Вектор запросов на обслуживание
        .req            (request),  // i  [REQS - 1 : 0]
        
        // Готовность обработать запрос
        .rdy            (~m_busy),  // i
        
        // Вектор гранта на обслуживание
        .gnt            (grant),    // o  [REQS - 1 : 0]
        
        // Номер порта, получившего грант
        .num            (  )        // o  [$clog2(REQS) - 1 : 0]
    ); // the_arbitrator
    
    //------------------------------------------------------------------------------------
    //      Коммутация сигнала отсутствия готовности
    assign s_busy = ~grant | {MASTERS{m_busy}};
    
    //------------------------------------------------------------------------------------
    //      Разветвление данных чтения от ведомого ко всем ведущим
    assign s_rdat = {MASTERS{m_rdat}};
    
    //------------------------------------------------------------------------------------
    //      Коммутация сигналов управления доступом
    assign m_wreq = |(s_wreq & grant);
    assign m_rreq = |(s_rreq & grant);
    
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
    
endmodule: mm_arbitrator
