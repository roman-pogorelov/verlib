/*
    //------------------------------------------------------------------------------------
    //      USRT-приемник с выходным потоковым интерфейсом и динамически 
    //      перестраиваемыми параметрами
    usrt_receiver
    the_usrt_receiver
    (
        // Сброс и тактирование
        .reset              (), // i
        .clk                (), // i
        
        // Интерфейс управления
        .ctrl_init          (), // i    Инициализация (синхронный сброс)
        .ctrl_stop_bits     (), // i    Количество стоп-бит: 0 - один бит, 1 - два бита
        .ctrl_parity_ena    (), // i    Признак использования контроля паритета чет/нечет
        .ctrl_parity_type   (), // i    Типа контроля паритета: 0 - чет, 1 - нечет
        
        // Интерфейс статусных сигналов
        .stat_begin         (), // o    Признак начала приема
        .stat_err_parity    (), // o    Признак ошибки паритета чет/нечет
        .stat_err_stop      (), // o    Признак ошибки приема стоп-бита
        
        // Выходной потоковый интерфейс без возможности остановки
        .rx_data            (), // o  [7 : 0]
        .rx_valid           (), // o
        
        // Линия приема USRT
        .usrt_rxd           ()  // i
    ); // the_usrt_receiver
*/

module usrt_receiver
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic                    ctrl_init,          // Инициализация (синхронный сброс)
    input  logic                    ctrl_stop_bits,     // Количество стоп-бит: 0 - один бит, 1 - два бита
    input  logic                    ctrl_parity_ena,    // Признак использования контроля паритета чет/нечет
    input  logic                    ctrl_parity_type,   // Типа контроля паритета: 0 - чет, 1 - нечет
    
    // Интерфейс статусных сигналов
    output logic                    stat_begin,         // Признак начала приема
    output logic                    stat_err_parity,    // Признак ошибки паритета чет/нечет
    output logic                    stat_err_stop,      // Признак ошибки приема стоп-бита
    
    // Выходной потоковый интерфейс без возможности остановки
    output logic [7 : 0]            rx_data,
    output logic                    rx_valid,
    
    // Линия приема USRT
    input  logic                    usrt_rxd
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                           stopbits_reg;       // Регистр количества стоп-бит
    logic                           parityena_reg;      // Регистр признака использования контроля паритета
    logic                           paritytype_reg;     // Регистр типа контролируемого паритета
    logic [3 : 0]                   pendbit_cnt;        // Счетчик разрядов, ожидающихся по приему
    logic                           activity;           // Индикатор активности приема
    logic                           last_bit;           // Индикатор приема последнего разряда
    logic [10 : 0]                  shift_reg;          // Сдвиговый регистр
    logic                           valid_reg;          // Регистр признака достоверности данных
    logic                           begin_reg;          // Регистр признака начала приема
    logic                           err_parity_reg;     // Регистр ошибки паритета чет/нечет
    logic                           err_stop_reg;       // Регистр ошибки приема стоп-бита
    
    //------------------------------------------------------------------------------------
    //      Регистр количества стоп-бит
    always @(posedge reset, posedge clk)
        if (reset)
            stopbits_reg <= '0;
        else if (ctrl_init)
            stopbits_reg <= '0;
        else if (~activity)
            stopbits_reg <= ctrl_stop_bits;
        else
            stopbits_reg <= stopbits_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака использования контроля паритета
    always @(posedge reset, posedge clk)
        if (reset)
            parityena_reg <= '0;
        else if (ctrl_init)
            parityena_reg <= '0;
        else if (~activity)
            parityena_reg <= ctrl_parity_ena;
        else
            parityena_reg <= parityena_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр типа контролируемого паритета
    always @(posedge reset, posedge clk)
        if (reset)
            paritytype_reg <= '0;
        else if (ctrl_init)
            paritytype_reg <= '0;
        else if (~activity)
            paritytype_reg <= ctrl_parity_type;
        else
            paritytype_reg <= paritytype_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик разрядов, ожидающихся по приему
    always @(posedge reset, posedge clk)
        if (reset)
            pendbit_cnt <= '0;
        else if (ctrl_init)
            pendbit_cnt <= '0;
        // Прием не активен
        else if (~activity)
            // Пришел старт-бит
            if (~usrt_rxd)
                // Один стоп-бит и нет контроля паритета
                if (~ctrl_stop_bits & ~ctrl_parity_ena)
                    pendbit_cnt <= 4'd9;
                // Два стоп-бита и есть контроль паритета
                else if (ctrl_stop_bits & ctrl_parity_ena)
                    pendbit_cnt <= 4'd11;
                // Остальные случаи
                else 
                    pendbit_cnt <= 4'd10;
            // Старт бит не пришел
            else
                pendbit_cnt <= '0;
        // Прием активен
        else
            pendbit_cnt <= pendbit_cnt - 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Индикатор активности приема
    assign activity = |pendbit_cnt;
    
    //------------------------------------------------------------------------------------
    //      Индикатор приема последнего разряда
    assign last_bit = (pendbit_cnt == 1);
    
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр
    always @(posedge reset, posedge clk)
        if (reset)
            shift_reg <= '0;
        else if (ctrl_init)
            shift_reg <= '0;
        // Идет прием
        else if (activity)
            // Последний бит
            if (last_bit)
                // Один стоп-бит и нет контроля паритета
                if (~stopbits_reg & ~parityena_reg)
                    shift_reg <= {2'b00, usrt_rxd, shift_reg[10 : 3]};
                // Два стоп-бита и есть контроль паритета
                else if (stopbits_reg & parityena_reg)
                    shift_reg <= {usrt_rxd, shift_reg[10 : 1]};
                // Остальные случаи
                else
                    shift_reg <= {1'b0, usrt_rxd, shift_reg[10 : 2]};
            // Не последний бит
            else
                shift_reg <= {usrt_rxd, shift_reg[10 : 1]};
        // Хранение принятого ранее значения
        else
            shift_reg <= shift_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака достоверности данных
    always @(posedge reset, posedge clk)
        if (reset)
            valid_reg <= '0;
        else if (ctrl_init)
            valid_reg <= '0;
        else
            valid_reg <= last_bit;
    
    //------------------------------------------------------------------------------------
    //      Выходной потоковый интерфейс без возможности остановки
    assign rx_data = shift_reg[7 : 0];
    assign rx_valid = valid_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака начала приема
    always @(posedge reset, posedge clk)
        if (reset)
            begin_reg <= '0;
        else if (ctrl_init)
            begin_reg <= '0;
        else
            begin_reg <= ~activity & ~usrt_rxd;
    assign stat_begin = begin_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр ошибки паритета чет/нечет
    always @(posedge reset, posedge clk)
        if (reset)
            err_parity_reg <= '0;
        else if (ctrl_init)
            err_parity_reg <= '0;
        else if (last_bit & parityena_reg)
            // Два стоп-бита
            if (stopbits_reg)
                err_parity_reg <= ^shift_reg[9 : 1] ^ paritytype_reg;
            // Один стоп-бит
            else
                err_parity_reg <= ^shift_reg[10 : 2] ^ paritytype_reg;
        else
            err_parity_reg <= '0;
    assign stat_err_parity = err_parity_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр ошибки приема стоп-бита
    always @(posedge reset, posedge clk)
        if (reset)
            err_stop_reg <= '0;
        else if (ctrl_init)
            err_stop_reg <= '0;
        else if (last_bit)
            // Два стоп-бита
            if (stopbits_reg)
                err_stop_reg <= ~(usrt_rxd & shift_reg[10]);
            // Один стоп-бит
            else
                err_stop_reg <= ~usrt_rxd;
        else
            err_stop_reg <= '0;
    assign stat_err_stop = err_stop_reg;
    
endmodule // usrt_receiver