/*
    //------------------------------------------------------------------------------------
    //      Модуль тестирования шины данных памяти со случайным доступом
    mmv_ram_db_tester
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     (), // Разрядность данных
        .RDPENDS    ()  // Максимальное количество незавершенных транзакций чтения
    )
    the_mmv_ram_db_tester
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
    ); // the_mmv_ram_db_tester
*/

module mmv_ram_db_tester
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
    //      Описание констант
    localparam int unsigned RPWIDTH = $clog2(RDPENDS + 1);
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [DWIDTH - 1 : 0]          wdat_reg;
    logic [DWIDTH - 1 : 0]          rdat_reg;
    logic [RPWIDTH - 1 : 0]         rd_pend_cnt;
    logic                           done_reg;
    logic                           fault_reg;
    
    //------------------------------------------------------------------------------------
    //      Кодирование состояний конечного автомата
    enum logic [3 : 0] {
        st_idle = 4'b0000,
        st_wreq = 4'b0011,
        st_rreq = 4'b0101,
        st_wait = 4'b1001
    } state;
    wire [3 : 0] st;
    assign st = state;
    
    //------------------------------------------------------------------------------------
    //      Выходные воздействия конечного автомата
    assign ready    = ~st[0];
    assign m_wreq   =  st[1];
    assign m_rreq   =  st[2];
    wire   fsm_work =  st[0];
    wire   fsm_wait =  st[3];
    
    //------------------------------------------------------------------------------------
    //      Логика переходов конечного автомата
    always @(posedge reset, posedge clk)
        if (reset)
            state <= st_idle;
        else if (clear)
            state <= st_idle;
        else case (state)
            
            // Бездействие
            st_idle:
                if (start)
                    state <= st_wreq;
                else
                    state <= st_idle;
            
            // Генерация запроса на запись
            st_wreq:
                if (m_busy)
                    state <= st_wreq;
                else
                    state <= st_rreq;
            
            // Генерация запроса на чтение
            st_rreq:
                if (m_busy)
                    state <= st_rreq;
                else if (wdat_reg[0])
                    state <= st_wait;
                else
                    state <= st_wreq;
            
            // Ожидание выполнения незавершенных запросов на чтение
            st_wait:
                if (rd_pend_cnt == 0)
                    state <= st_idle;
                else
                    state <= st_wait;
            
            // Запрещенные состояния
            default:
                state <= st_idle;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Установка адреса в 0 для всего теста
    assign m_addr = {AWIDTH{1'b0}};
    
    //------------------------------------------------------------------------------------
    //      Регистр записываемых данных
    initial wdat_reg = {{DWIDTH - 1{1'b0}}, 1'b1};
    always @(posedge reset, posedge clk)
        if (reset)
            wdat_reg <= {{DWIDTH - 1{1'b0}}, 1'b1};
        else if (clear)
            wdat_reg <= {{DWIDTH - 1{1'b0}}, 1'b1};
        else if (m_wreq & ~m_busy)
            wdat_reg <= {wdat_reg[DWIDTH - 2 : 0], wdat_reg[DWIDTH - 1]};
        else
            wdat_reg <= wdat_reg;
    assign m_wdat = wdat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр опорных данных для проверки чтения
    initial rdat_reg = {{DWIDTH - 1{1'b0}}, 1'b1};
    always @(posedge reset, posedge clk)
        if (reset)
            rdat_reg <= {{DWIDTH - 1{1'b0}}, 1'b1};
        else if (clear)
            rdat_reg <= {{DWIDTH - 1{1'b0}}, 1'b1};
        else if (fsm_work & m_rval)
            rdat_reg <= {rdat_reg[DWIDTH - 2 : 0], rdat_reg[DWIDTH - 1]};
        else
            rdat_reg <= rdat_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик незавершенных транзакций чтения
    always @(posedge reset, posedge clk)
        if (reset)
            rd_pend_cnt <= '0;
        else if (clear)
            rd_pend_cnt <= '0;
        else if ((m_rreq & ~m_busy) & ~m_rval)
            rd_pend_cnt <= rd_pend_cnt + 1'b1;
        else if (~(m_rreq & ~m_busy) & m_rval & fsm_work)
            rd_pend_cnt <= rd_pend_cnt - 1'b1;
        else
            rd_pend_cnt <= rd_pend_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр одиночного импульса окончания теста
    always @(posedge reset, posedge clk)
        if (reset)
            done_reg <= '0;
        else if (clear)
            done_reg <= '0;
        else
            done_reg <= fsm_wait & (rd_pend_cnt == 0);
    assign done = done_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр одиночного импульса индикации ошибки
    always @(posedge reset, posedge clk)
        if (reset)
            fault_reg <= '0;
        else if (clear)
            fault_reg <= '0;
        else
            fault_reg <= fsm_work & m_rval & (m_rdat != rdat_reg);
    assign fault = fault_reg;
    
endmodule: mmv_ram_db_tester