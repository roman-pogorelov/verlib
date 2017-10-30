/*
    //------------------------------------------------------------------------------------
    //      Модуль комплексного тестирования памяти со случайным доступом
    mmv_ram_complex_tester
    #(
        .MAWIDTH    (), // Разрядность шины адреса памяти
        .MDWIDTH    (), // Разрядность шины данных (должна быть степенью двойки)
        .CDWIDTH    ()  // Разрядность шины данных интерфейса управления
    )
    the_mmv_ram_complex_tester
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейс управления (латентность по чтению - 1 такт)
        .ctl_addr   (), // i  [2 : 0]
        .ctl_wreq   (), // i
        .ctl_wdat   (), // i  [CDWIDTH - 1 : 0]
        .ctl_rreq   (), // i
        .ctl_rdat   (), // o  [CDWIDTH - 1 : 0]
        .ctl_rval   (), // o
        
        // Тестирующий интерфейс ведущего
        .m_addr     (), // o  [MAWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [MDWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [MDWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_mmv_ram_complex_tester
*/

module mmv_ram_complex_tester
#(
    parameter int unsigned          MAWIDTH = 8,    // Разрядность шины адреса памяти
    parameter int unsigned          MDWIDTH = 8,    // Разрядность шины данных (должна быть степенью двойки)
    parameter int unsigned          CDWIDTH = 8     // Разрядность шины данных интерфейса управления
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления (латентность по чтению - 1 такт)
    input  logic [2 : 0]            ctl_addr,
    input  logic                    ctl_wreq,
    input  logic [CDWIDTH - 1 : 0]  ctl_wdat,
    input  logic                    ctl_rreq,
    output logic [CDWIDTH - 1 : 0]  ctl_rdat,
    output logic                    ctl_rval,
    
    // Тестирующий интерфейс ведущего
    output logic [MAWIDTH - 1 : 0]  m_addr,
    output logic                    m_wreq,
    output logic [MDWIDTH - 1 : 0]  m_wdat,
    output logic                    m_rreq,
    input  logic [MDWIDTH - 1 : 0]  m_rdat,
    input  logic                    m_rval,
    input  logic                    m_busy
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam logic [2 : 0]        CONTROL_REG   = 3'h0;   // Адрес регистра управления
    localparam logic [2 : 0]        STATUS_REG    = 3'h1;   // Адрес регистра статуса
    localparam logic [2 : 0]        RESET_REG     = 3'h2;   // Адрес регистра программного сброса
    localparam logic [2 : 0]        DATAB_ERR_CNT = 3'h3;   // Адрес счетчика ошибок тестирования шины данных
    localparam logic [2 : 0]        ADDRB_ERR_CNT = 3'h4;   // Адрес счетчика ошибок тестирования шины адреса
    localparam logic [2 : 0]        MARCH_ERR_CNT = 3'h5;   // Адрес счетчика ошибок маршевого теста
    localparam logic [2 : 0]        WRITE_REQ_CNT = 3'h6;   // Адрес счетчика запросов на запись
    localparam logic [2 : 0]        READ_REQ_CNT  = 3'h7;   // Адрес счетчика запросов на чтение
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                           start_reg;
    logic                           soft_reset_reg;
    logic                           fault_reg;
    //
    logic                           datab_ready;
    logic                           addrb_ready;
    logic                           march_ready;
    logic                           datab_fault;
    logic                           addrb_fault;
    logic                           march_fault;
    //
    logic [3 : 0][MAWIDTH - 1 : 0]  tester_addr;
    logic [3 : 0]                   tester_wreq;
    logic [3 : 0][MDWIDTH - 1 : 0]  tester_wdat;
    logic [3 : 0]                   tester_rreq;
    //
    logic                           buf_busy;
    logic                           buf_csel_reg;
    logic [MAWIDTH - 1 : 0]         buf_addr_reg;
    logic                           buf_wreq_reg;
    logic [MDWIDTH - 1 : 0]         buf_wdat_reg;
    logic                           buf_rreq_reg;
    //
    logic [CDWIDTH - 1 : 0]         datab_err_cnt;
    logic [CDWIDTH - 1 : 0]         addrb_err_cnt;
    logic [CDWIDTH - 1 : 0]         march_err_cnt;
    logic [CDWIDTH - 1 : 0]         write_req_cnt;
    logic [CDWIDTH - 1 : 0]         read_req_cnt;
    //
    logic [CDWIDTH - 1 : 0]         rdat_reg;
    logic                           rval_reg;
    
    //------------------------------------------------------------------------------------
    //      Кодирование состояний конечного автомата
    enum logic [6 : 0] {
        st_idle        = 7'b0_000_00_0,
        st_datab_run   = 7'b0_001_01_1,
        st_datab_wait  = 7'b0_000_01_1,
        st_datab_check = 7'b1_000_01_1,
        st_addrb_run   = 7'b0_010_10_1,
        st_addrb_wait  = 7'b0_000_10_1,
        st_addrb_check = 7'b1_000_10_1,
        st_march_run   = 7'b0_100_11_1,
        st_march_wait  = 7'b0_000_11_1,
        st_march_check = 7'b1_000_11_1
    } state;
    wire [6 : 0] st;
    assign st = state;
    
    //------------------------------------------------------------------------------------
    //      Управляющие воздействия конечного автомата
    wire         fsm_busy       = st[0];
    wire [1 : 0] tester_select  = st[2 : 1];
    wire         datab_start    = st[3];
    wire         addrb_start    = st[4];
    wire         march_start    = st[5];
    
    //------------------------------------------------------------------------------------
    //      Логика переходов конечного автомата
    always @(posedge reset, posedge clk)
        if (reset)
            state <= st_idle;
        else if (soft_reset_reg)
            state <= st_idle;
        else case (state)
            st_idle:
                if (start_reg)
                    state <= st_datab_run;
                else
                    state <= st_idle;
            
            st_datab_run:
                state <= st_datab_wait;
            
            st_datab_wait:
                if (datab_ready)
                    state <= st_datab_check;
                else
                    state <= st_datab_wait;
            
            st_datab_check:
                if (fault_reg)
                    state <= st_idle;
                else
                    state <= st_addrb_run;
            
            st_addrb_run:
                state <= st_addrb_wait;
            
            st_addrb_wait:
                if (addrb_ready)
                    state <= st_addrb_check;
                else
                    state <= st_addrb_wait;
            
            st_addrb_check:
                if (fault_reg)
                    state <= st_idle;
                else
                    state <= st_march_run;
            
            st_march_run:
                state <= st_march_wait;
            
            st_march_wait:
                if (march_ready)
                    state <= st_march_check;
                else
                    state <= st_march_wait;
            
            st_march_check:
                state <= st_idle;
            
            default:
                state <= st_idle;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Регистр запуска тестирования
    always @(posedge reset, posedge clk)
        if (reset)
            start_reg <= '0;
        else
            start_reg <= (ctl_wreq & (ctl_addr == CONTROL_REG));
    
    //------------------------------------------------------------------------------------
    //      Регистр программного сброса
    always @(posedge reset, posedge clk)
        if (reset)
            soft_reset_reg <= '0;
        else
            soft_reset_reg <= (ctl_wreq & (ctl_addr == RESET_REG));
    
    //------------------------------------------------------------------------------------
    //      Регистр признака хотябы одной ошибки
    always @(posedge reset, posedge clk)
        if (reset)
            fault_reg <= '0;
        else if (soft_reset_reg | (~fsm_busy & start_reg))
            fault_reg <= '0;
        else
            fault_reg <= fault_reg | datab_fault | addrb_fault | march_fault;
    
    //------------------------------------------------------------------------------------
    //      Терминирование линий запроса в отсутствии теста
    assign tester_addr[0] = '0;
    assign tester_wreq[0] = '0;
    assign tester_wdat[0] = '0;
    assign tester_rreq[0] = '0;
    
    //------------------------------------------------------------------------------------
    //      Модуль тестирования шины данных памяти со случайным доступом
    mmv_ram_db_tester
    #(
        .AWIDTH     (MAWIDTH),          // Разрядность адреса
        .DWIDTH     (MDWIDTH)           // Разрядность данных
    )
    data_bus_tester
    (
        // Сброс и тактирование
        .reset      (reset),            // i
        .clk        (clk),              // i
        
        // Интерфейс управления
        .clear      (soft_reset_reg),   // i  Синхронный сброс
        .start      (datab_start),      // i  Запуск теста
        .ready      (datab_ready),      // o  Готовность к запуску теста
        .fault      (datab_fault),      // o  Одиночный импульс индикации ошибки
        .done       (  ),               // o  Одиночный импульс окончания теста
        
        // Тестирующий интерфейс ведущего
        .m_addr     (tester_addr[1]),   // o  [AWIDTH - 1 : 0]
        .m_wreq     (tester_wreq[1]),   // o
        .m_wdat     (tester_wdat[1]),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (tester_rreq[1]),   // o
        .m_rdat     (m_rdat),           // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),           // i
        .m_busy     (buf_busy)          // i
    ); // data_bus_tester
    
    //------------------------------------------------------------------------------------
    //      Модуль тестирования шины адреса памяти со случайным доступом
    mmv_ram_ab_tester
    #(
        .AWIDTH     (MAWIDTH),          // Разрядность адреса
        .DWIDTH     (MDWIDTH)           // Разрядность данных
    )
    address_bus_tester
    (
        // Сброс и тактирование
        .reset      (reset),            // i
        .clk        (clk),              // i
        
        // Интерфейс управления
        .clear      (soft_reset_reg),   // i  Синхронный сброс
        .start      (addrb_start),      // i  Запуск теста
        .ready      (addrb_ready),      // o  Готовность к запуску теста
        .fault      (addrb_fault),      // o  Одиночный импульс индикации ошибки
        .done       (  ),               // o  Одиночный импульс окончания теста
        
        // Тестирующий интерфейс ведущего
        .m_addr     (tester_addr[2]),   // o  [AWIDTH - 1 : 0]
        .m_wreq     (tester_wreq[2]),   // o
        .m_wdat     (tester_wdat[2]),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (tester_rreq[2]),   // o
        .m_rdat     (m_rdat),           // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),           // i
        .m_busy     (buf_busy)          // i
    ); // address_bus_tester
    
    //------------------------------------------------------------------------------------
    //      Модуль тестирования памяти со случайным доступом маршевым алгоритмом March C-
    mmv_ram_march_c_tester
    #(
        .AWIDTH     (MAWIDTH),          // Разрядность адреса
        .DWIDTH     (MDWIDTH)           // Разрядность данных (должна быть степенью двойки)
    )
    march_c_tester
    (
        // Сброс и тактирование
        .reset      (reset),            // i
        .clk        (clk),              // i
        
        // Интерфейс управления
        .clear      (soft_reset_reg),   // i  Синхронный сброс
        .start      (march_start),      // i  Запуск теста
        .ready      (march_ready),      // o  Готовность к запуску теста
        .fault      (march_fault),      // o  Одиночный импульс индикации ошибки
        .done       (  ),               // o  Одиночный импульс окончания теста
        
        // Тестирующий интерфейс ведущего
        .m_addr     (tester_addr[3]),   // o  [AWIDTH - 1 : 0]
        .m_wreq     (tester_wreq[3]),   // o
        .m_wdat     (tester_wdat[3]),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (tester_rreq[3]),   // o
        .m_rdat     (m_rdat),           // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),           // i
        .m_busy     (buf_busy)          // i
    ); // march_c_tester
    
    //------------------------------------------------------------------------------------
    //      Признак занятости выходного буфера
    assign buf_busy = buf_csel_reg & m_busy;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака активной транзакции выходного буфера
    always @(posedge reset, posedge clk)
        if (reset)
            buf_csel_reg <= '0;
        else if (soft_reset_reg)
            buf_csel_reg <= '0;
        else if (~buf_busy)
            buf_csel_reg <= tester_wreq[tester_select] | tester_rreq[tester_select];
        else
            buf_csel_reg <= buf_csel_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр адреса транзакции выходного буфера
    always @(posedge reset, posedge clk)
        if (reset)
            buf_addr_reg <= '0;
        else if (soft_reset_reg)
            buf_addr_reg <= '0;
        else if (~buf_busy)
            buf_addr_reg <= tester_addr[tester_select];
        else
            buf_addr_reg <= buf_addr_reg;
    assign m_addr = buf_addr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр запроса на запись выходного буфера
    always @(posedge reset, posedge clk)
        if (reset)
            buf_wreq_reg <= '0;
        else if (soft_reset_reg)
            buf_wreq_reg <= '0;
        else if (~buf_busy)
            buf_wreq_reg <= tester_wreq[tester_select];
        else
            buf_wreq_reg <= buf_wreq_reg;
    assign m_wreq = buf_wreq_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр записываемых данных выходного буфера
    always @(posedge reset, posedge clk)
        if (reset)
            buf_wdat_reg <= '0;
        else if (soft_reset_reg)
            buf_wdat_reg <= '0;
        else if (~buf_busy)
            buf_wdat_reg <= tester_wdat[tester_select];
        else
            buf_wdat_reg <= buf_wdat_reg;
    assign m_wdat = buf_wdat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр запроса на чтение выходного буфера
    always @(posedge reset, posedge clk)
        if (reset)
            buf_rreq_reg <= '0;
        else if (soft_reset_reg)
            buf_rreq_reg <= '0;
        else if (~buf_busy)
            buf_rreq_reg <= tester_rreq[tester_select];
        else
            buf_rreq_reg <= buf_rreq_reg;
    assign m_rreq = buf_rreq_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик ошибок тестирования шины данных
    always @(posedge reset, posedge clk)
        if (reset)
            datab_err_cnt <= '0;
        else if (soft_reset_reg | (~fsm_busy & start_reg))
            datab_err_cnt <= '0;
        else if (ctl_wreq & (ctl_addr == DATAB_ERR_CNT))
            datab_err_cnt <= ctl_wdat;
        else
            datab_err_cnt <= datab_err_cnt + datab_fault;
    
    //------------------------------------------------------------------------------------
    //      Счетчик ошибок тестирования шины адреса
    always @(posedge reset, posedge clk)
        if (reset)
            addrb_err_cnt <= '0;
        else if (soft_reset_reg | (~fsm_busy & start_reg))
            addrb_err_cnt <= '0;
        else if (ctl_wreq & (ctl_addr == ADDRB_ERR_CNT))
            addrb_err_cnt <= ctl_wdat;
        else
            addrb_err_cnt <= addrb_err_cnt + addrb_fault;
    
    //------------------------------------------------------------------------------------
    //      Счетчик ошибок маршевого теста
    always @(posedge reset, posedge clk)
        if (reset)
            march_err_cnt <= '0;
        else if (soft_reset_reg | (~fsm_busy & start_reg))
            march_err_cnt <= '0;
        else if (ctl_wreq & (ctl_addr == MARCH_ERR_CNT))
            march_err_cnt <= ctl_wdat;
        else
            march_err_cnt <= march_err_cnt + march_fault;
    
    //------------------------------------------------------------------------------------
    //      Счетчик запросов на запись
    always @(posedge reset, posedge clk)
        if (reset)
            write_req_cnt <= '0;
        else if (soft_reset_reg | (~fsm_busy & start_reg))
            write_req_cnt <= '0;
        else if (ctl_wreq & (ctl_addr == WRITE_REQ_CNT))
            write_req_cnt <= ctl_wdat;
        else
            write_req_cnt <= write_req_cnt + (m_wreq & ~m_busy);
    
    //------------------------------------------------------------------------------------
    //      Счетчик запросов на чтение
    always @(posedge reset, posedge clk)
        if (reset)
            read_req_cnt <= '0;
        else if (soft_reset_reg | (~fsm_busy & start_reg))
            read_req_cnt <= '0;
        else if (ctl_wreq & (ctl_addr == READ_REQ_CNT))
            read_req_cnt <= ctl_wdat;
        else
            read_req_cnt <= read_req_cnt + (m_rreq & ~m_busy);
    
    //------------------------------------------------------------------------------------
    //      Регистр читаемых данных
    always @(posedge reset, posedge clk)
        if (reset)
            rdat_reg <= '0;
        else case (ctl_addr)
            // Адрес регистра управления
            CONTROL_REG:
                rdat_reg <= {{CDWIDTH - 2{1'b0}}, tester_select};
            
            // Адрес регистра статуса
            STATUS_REG:
                rdat_reg <= {{CDWIDTH - 1{1'b0}}, fault_reg};
            
            // Адрес счетчика ошибок тестирования шины данных
            DATAB_ERR_CNT:
                rdat_reg <= datab_err_cnt;
            
            // Адрес счетчика ошибок тестирования шины адреса
            ADDRB_ERR_CNT:
                rdat_reg <= addrb_err_cnt;
            
            // Адрес счетчика ошибок маршевого теста
            MARCH_ERR_CNT:
                rdat_reg <= march_err_cnt;
            
            // Адрес счетчика запросов на запись
            WRITE_REQ_CNT:
                rdat_reg <= write_req_cnt;
            
            // Адрес счетчика запросов на чтение
            READ_REQ_CNT:
                rdat_reg <= read_req_cnt;
            
            // Остальные регистры
            default:
                rdat_reg <= {CDWIDTH{1'b0}};
        endcase
    assign ctl_rdat = rdat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака достоверности читаемых данных
    always @(posedge reset, posedge clk)
        if (reset)
            rval_reg <= '0;
        else
            rval_reg <= ctl_rreq;
    assign ctl_rval = rval_reg;
    
endmodule // mmv_ram_complex_tester