/*
    //------------------------------------------------------------------------------------
    //      Модуль тестирования шины адреса памяти со случайным доступом
    mmv_ram_ab_tester
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     (), // Разрядность данных
        .RDPENDS    ()  // Максимальное количество незавершенных транзакций чтения
    )
    the_mmv_ram_ab_tester
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейс управления
        .clear      (), // i  Синхронный сброс
        .start      (), // i  Запуск теста
        .ready      (), // o  Готовность к запуску теста
        .fault      (), // o  Одиночный импульс индикации ошибки
        .done       (), // o  Одиночный импульс окончания теста
        
        // Тестирующий интерфейс ведущего
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_mmv_ram_ab_tester
*/

module mmv_ram_ab_tester
#(
    parameter int unsigned          AWIDTH  = 8,    // Разрядность адреса
    parameter int unsigned          DWIDTH  = 8,    // Разрядность данных
    parameter int unsigned          RDPENDS = 2     // Максимальное количество незавершенных транзакций чтения
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic                    clear,  // Синхронный сброс
    input  logic                    start,  // Запуск теста
    output logic                    ready,  // Готовность к запуску теста
    output logic                    fault,  // Одиночный импульс индикации ошибки
    output logic                    done,   // Одиночный импульс окончания теста
    
    // Тестирующий интерфейс ведущего
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
    logic [DWIDTH - 1 : 0]          pattern;
    logic [DWIDTH - 1 : 0]          antipattern;
    logic [AWIDTH - 1 : 0]          req0_addr_reg;
    logic [AWIDTH - 1 : 0]          req1_addr_reg;
    
    //------------------------------------------------------------------------------------
    //      Кодирование состояний конечного автомата запросов записи/чтения
    enum logic [8 : 0] {
        st_idle     = 9'b0_0_00_00_00_0,
        st_w1_all_p = 9'b0_0_11_01_01_1,
        st_w1_nul_n = 9'b1_0_10_01_01_1,
        st_r1_all_p = 9'b1_0_11_01_10_1,
        st_w1_nul_p = 9'b0_0_01_01_01_1,
        st_w2_cur_n = 9'b1_1_01_01_01_1,
        st_r2_nul_p = 9'b0_0_10_01_10_1,
        st_r2_all_p = 9'b0_0_11_01_10_1,
        st_w2_cur_p = 9'b0_1_10_11_01_1,
        st_wait     = 9'b0_0_00_00_00_1
    } req_state;
    wire [8 : 0] req_st;
    assign req_st = req_state;
    
    //------------------------------------------------------------------------------------
    //      Управляющие воздействия автомата запросов записи/чтения
    assign       ready               = ~req_st[0];
    assign       m_wreq              =  req_st[1];
    assign       m_rreq              =  req_st[2];
    wire [1 : 0] req_fsm_addr_ena    =  req_st[4 : 3];
    wire [1 : 0] req_fsm_addr_mode   =  req_st[6 : 5];
    wire         req_fsm_addr_switch =  req_st[7];
    wire         req_fsm_data_switch =  req_st[8];
    
    //------------------------------------------------------------------------------------
    //      Кодирование состояний конечного автомата анализа ответов на чтение
    
    //------------------------------------------------------------------------------------
    //      Логика переходов управляющего автомата запросов записи/чтения
    always @(posedge reset, posedge clk)
        if (reset)
            req_state <= st_idle;
        else if (clear)
            req_state <= st_idle;
        else case (req_state)
            st_idle:
                if (start)
                    req_state <= st_w1_all_p;
                else
                    req_state <= st_idle;
            
            st_w1_all_p:
                if (~m_busy & req0_addr_reg[AWIDTH - 1])
                    req_state <= st_w1_nul_n;
                else
                    req_state <= st_w1_all_p;
            
            st_w1_nul_n:
                if (~m_busy)
                    req_state <= st_r1_all_p;
                else
                    req_state <= st_w1_nul_n;
            
            st_r1_all_p:
                if (~m_busy & req0_addr_reg[AWIDTH - 1])
                    req_state <= st_w1_nul_p;
                else
                    req_state <= st_r1_all_p;
            
            st_w1_nul_p:
                if (~m_busy)
                    req_state <= st_w2_cur_n;
                else
                    req_state <= st_w1_nul_p;
            
            st_w2_cur_n:
                if (~m_busy)
                    req_state <= st_r2_nul_p;
                else
                    req_state <= st_w2_cur_n;
            
            st_r2_nul_p:
                if (~m_busy)
                    req_state <= st_r2_all_p;
                else
                    req_state <= st_r2_nul_p;
            
            st_r2_all_p:
                if (~m_busy & req0_addr_reg[AWIDTH - 1])
                    req_state <= st_w2_cur_p;
                else
                    req_state <= st_r2_all_p;
            
            st_w2_cur_p:
                if (~m_busy)
                    if (req1_addr_reg[AWIDTH - 1])
                        req_state <= st_wait;
                    else
                        req_state <= st_w2_cur_n;
                else
                    req_state <= st_w2_cur_p;
            
            st_wait: // TODO: Ожидать готовности от конечного автомата проверки
                req_state <= st_idle;
            
            default:
                req_state <= st_idle;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Формирование шаблона и анти шаблона
    always_comb begin
        for (int i = 0; i < DWIDTH; i++) begin
            pattern[i] = i[0];
            antipattern[i] = ~i[0];
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Регистр #0 адреса запроса
    always @(posedge reset, posedge clk)
        if (reset)
            req0_addr_reg <= '0;
        else if (ready | clear)
            req0_addr_reg <= {{AWIDTH - 1{1'b0}}, 1'b1};
        else if (req_fsm_addr_ena[0] & ~m_busy)
            case (req_fsm_addr_mode)
                2'b01:
                    req0_addr_reg <= {AWIDTH{1'b0}};
                2'b10:
                    req0_addr_reg <= {{AWIDTH - 1{1'b0}}, 1'b1};
                default:
                    req0_addr_reg <= {req0_addr_reg[AWIDTH - 2 : 0], 1'b0};
            endcase
        else
            req0_addr_reg <= req0_addr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр #1 адреса запроса
    always @(posedge reset, posedge clk)
        if (reset)
            req1_addr_reg <= '0;
        else if (ready | clear)
            req1_addr_reg <= {{AWIDTH - 1{1'b0}}, 1'b1};
        else if (req_fsm_addr_ena[1] & ~m_busy)
            req1_addr_reg <= {req1_addr_reg[AWIDTH - 2 : 0], req1_addr_reg[AWIDTH - 1]};
        else
            req1_addr_reg <= req1_addr_reg;
    
    //------------------------------------------------------------------------------------
    //      Переключение шин адреса и данных для записи
    assign m_addr = req_fsm_addr_switch ? req1_addr_reg : req0_addr_reg;
    assign m_wdat = req_fsm_data_switch ? antipattern : pattern;
    
endmodule: mmv_ram_ab_tester