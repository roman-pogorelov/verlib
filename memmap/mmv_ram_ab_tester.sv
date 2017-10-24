/*
    //------------------------------------------------------------------------------------
    //      Модуль тестирования шины адреса памяти со случайным доступом
    mmv_ram_ab_tester
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     ()  // Разрядность данных
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
    parameter int unsigned          DWIDTH  = 8     // Разрядность данных
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
    logic [$clog2(AWIDTH) - 1 : 0]  ack0_cnt;
    logic [$clog2(AWIDTH) - 1 : 0]  ack1_cnt;
    logic                           rd_inv_reg;
    logic [DWIDTH - 1 : 0]          test_data;
    logic                           done_reg;
    logic                           fault_reg;
    
    //------------------------------------------------------------------------------------
    //      Кодирование состояний конечного автомата запросов записи/чтения
    enum logic [9 : 0] {
        st_req_idle = 10'b0_0_0_00_00_00_0,
        st_w1_all_p = 10'b0_0_0_11_01_01_1,
        st_w1_nul_n = 10'b0_1_0_10_01_01_1,
        st_r1_all_p = 10'b0_1_0_11_01_10_1,
        st_w1_nul_p = 10'b0_0_0_01_01_01_1,
        st_w2_cur_n = 10'b0_1_1_01_01_01_1,
        st_r2_nul_p = 10'b0_0_0_10_01_10_1,
        st_r2_all_p = 10'b0_0_0_11_01_10_1,
        st_w2_cur_p = 10'b0_0_1_10_11_01_1,
        st_wait_ack = 10'b1_0_0_00_00_00_1
    } req_state;
    wire [9 : 0] req_st;
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
    wire         req_fsm_wait_ack    =  req_st[9];
    
    //------------------------------------------------------------------------------------
    //      Кодирование состояний конечного автомата анализа ответов на чтение
    enum logic [2 : 0] {
        st_ack_idle = 3'b000,
        st_chk1_all = 3'b011,
        st_chk2_nul = 3'b001,
        st_chk2_all = 3'b111
    } ack_state;
    wire [2 : 0] ack_st;
    assign ack_st = ack_state;
    
    //------------------------------------------------------------------------------------
    //      Управляющие воздействия автомата анализа ответов на чтение
    wire ack_fsm_ready = ~ack_st[0];
    wire ack0_cnt_ena  =  ack_st[1];
    wire ack1_cnt_ena  =  ack_st[2];
    
    //------------------------------------------------------------------------------------
    //      Логика переходов конечного автомата запросов записи/чтения
    always @(posedge reset, posedge clk)
        if (reset)
            req_state <= st_req_idle;
        else if (clear)
            req_state <= st_req_idle;
        else case (req_state)
            st_req_idle:
                if (start)
                    req_state <= st_w1_all_p;
                else
                    req_state <= st_req_idle;
            
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
                        req_state <= st_wait_ack;
                    else
                        req_state <= st_w2_cur_n;
                else
                    req_state <= st_w2_cur_p;
            
            st_wait_ack:
                if (ack_fsm_ready)
                    req_state <= st_req_idle;
                else
                    req_state <= st_wait_ack;
            
            default:
                req_state <= st_req_idle;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Логика переходов конечного автомата анализа ответов на чтение
    always @(posedge reset, posedge clk)
        if (reset)
            ack_state <= st_ack_idle;
        else if (clear)
            ack_state <= st_ack_idle;
        else case (ack_state)
            st_ack_idle:
                if (start)
                    ack_state <= st_chk1_all;
                else
                    ack_state <= st_ack_idle;
            
            st_chk1_all:
                if (m_rval & (ack0_cnt == (AWIDTH - 1)))
                    ack_state <= st_chk2_nul;
                else
                    ack_state <= st_chk1_all;
            
            st_chk2_nul:
                if (m_rval)
                    ack_state <= st_chk2_all;
                else
                    ack_state <= st_chk2_nul;
            
            st_chk2_all:
                if (m_rval & (ack0_cnt == (AWIDTH - 1)))
                    if (ack1_cnt == (AWIDTH - 1))
                        ack_state <= st_ack_idle;
                    else
                        ack_state <= st_chk2_nul;
                else
                    ack_state <= st_chk2_all;
            
            default:
                ack_state <= st_ack_idle;
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
    
    //------------------------------------------------------------------------------------
    //      Счетчик #0 ответов на чтение
    initial ack0_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            ack0_cnt <= '0;
        else if (clear)
            ack0_cnt <= '0;
        else if (ack0_cnt_ena & m_rval)
            if (ack0_cnt == (AWIDTH - 1))
                ack0_cnt <= '0;
            else
                ack0_cnt <= ack0_cnt + 1'b1;
        else
            ack0_cnt <= ack0_cnt;
    
    //------------------------------------------------------------------------------------
    //      Счетчик #1 ответов на чтение
    initial ack1_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            ack1_cnt <= '0;
        else if (clear)
            ack1_cnt <= '0;
        else if (ack1_cnt_ena & m_rval & (ack0_cnt == (AWIDTH - 1)))
            if (ack1_cnt == (AWIDTH - 1))
                ack1_cnt <= '0;
            else
                ack1_cnt <= ack1_cnt + 1'b1;
        else
            ack1_cnt <= ack1_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр управления инверсией читаемых данных
    initial rd_inv_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            rd_inv_reg <= '1;
        else if (clear)
            rd_inv_reg <= '1;
        else if (ack1_cnt_ena & m_rval)
            rd_inv_reg <= (ack1_cnt - ack0_cnt) == 1;
        else
            rd_inv_reg <= rd_inv_reg;
    
    //------------------------------------------------------------------------------------
    //      Логика модификации проверяемых данных
    assign test_data = {DWIDTH{rd_inv_reg & ack1_cnt_ena}} ^ m_rdat;
    
    //------------------------------------------------------------------------------------
    //      Регистр одиночного импульса окончания теста
    always @(posedge reset, posedge clk)
        if (reset)
            done_reg <= '0;
        else if (clear)
            done_reg <= '0;
        else
            done_reg <= req_fsm_wait_ack & ack_fsm_ready;
    assign done = done_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр одиночного импульса индикации ошибки
    always @(posedge reset, posedge clk)
        if (reset)
            fault_reg <= '0;
        else if (clear)
            fault_reg <= '0;
        else
            fault_reg <= ~ack_fsm_ready & m_rval & (test_data != pattern);
    assign fault = fault_reg;
    
endmodule: mmv_ram_ab_tester