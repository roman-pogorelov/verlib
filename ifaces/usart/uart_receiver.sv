/*
    //------------------------------------------------------------------------------------
    //      UART-приемник с выходным потоковым интерфейсом и динамически 
    //      перестраиваемыми параметрами
    uart_receiver
    #(
        .BDWIDTH            ()  // Разрядность делителя
    )
    the_uart_receiver
    (
        // Сброс и тактирование
        .reset              (), // i
        .clk                (), // i
        
        // Интерфейс управления
        .ctrl_init          (), // i                    Инициализация (синхронный сброс)
        .ctrl_baud_divisor  (), // i  [BDWIDTH - 1 : 0] Значение делителя
        .ctrl_stop_bits     (), // i                    Количество стоп-бит: 0 - один бит, 1 - два бита
        .ctrl_parity_ena    (), // i                    Признак использования контроля паритета чет/нечет
        .ctrl_parity_type   (), // i                    Типа контроля паритета: 0 - чет, 1 - нечет
        
        // Интерфейс статусных сигналов
        .stat_err_parity    (), // o                    Признак ошибки паритета чет/нечет
        .stat_err_start     (), // o                    Признак ошибки приема старт-бита
        .stat_err_stop      (), // o                    Признак ошибки приема стоп-бита
        
        // Выходной потоковый интерфейс без возможности остановки
        .rx_data            (), // o  [7 : 0]
        .rx_valid           (), // o
        
        // Линия приема UART
        .uart_rxd           ()  // i
    ); // the_uart_receiver
*/

module uart_receiver
#(
    parameter                       BDWIDTH = 8         // Разрядность делителя
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic                    ctrl_init,          // Инициализация (синхронный сброс)
    input  logic [BDWIDTH - 1 : 0]  ctrl_baud_divisor,  // Значение делителя
    input  logic                    ctrl_stop_bits,     // Количество стоп-бит: 0 - один бит, 1 - два бита
    input  logic                    ctrl_parity_ena,    // Признак использования контроля паритета чет/нечет
    input  logic                    ctrl_parity_type,   // Типа контроля паритета: 0 - чет, 1 - нечет
    
    // Интерфейс статусных сигналов
    output logic                    stat_err_parity,    // Признак ошибки паритета чет/нечет
    output logic                    stat_err_start,     // Признак ошибки приема старт-бита
    output logic                    stat_err_stop,      // Признак ошибки приема стоп-бита
    
    // Выходной потоковый интерфейс без возможности остановки
    output logic [7 : 0]            rx_data,
    output logic                    rx_valid,
    
    // Линия приема UART
    input  logic                    uart_rxd
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [2 : 0]                   sync_stage;         // Ступень синхронизации на частоту тактирования
    logic                           uart_rxd_sync;      // Синхронизированная линия приема UART
    logic                           rxd_fall;           // Импульс перехода линии приема UART из 1 в 0
    logic [BDWIDTH - 1 : 0]         bauddiv_reg;        // Регистр значения делителя
    logic [BDWIDTH - 1 : 0]         bauddiv_cnt;        // Счетчик тактов на передачу одного разряда
    logic                           stopbits_reg;       // Регистр количества стоп-бит
    logic                           parityena_reg;      // Регистр признака использования контроля паритета
    logic                           paritytype_reg;     // Регистр типа контролируемого паритета
    logic                           latch_bit;          // Разрешение на захват разряда
    logic [3 : 0]                   pendbit_cnt;        // Счетчик разрядов, ожидающихся по приему
    logic [11 : 0]                  shift_reg;          // Сдвиговый регистр
    logic                           activity_reg;       // Регистр активности приема
    logic                           valid_reg;          // Регистр признака достоверности данных
    logic                           err_parity_reg;     // Регистр ошибки паритета чет/нечет
    logic                           err_start_reg;      // Регистр ошибки приема старт-бита
    logic                           err_stop_reg;       // Регистр ошибки приема стоп-бита
    
    //------------------------------------------------------------------------------------
    //      Ступень синхронизации на частоту тактирования
    initial sync_stage <= '1;
    always @(posedge reset, posedge clk)
        if (reset)
            sync_stage <= '1;
        else if (ctrl_init)
            sync_stage <= '1;
        else
            sync_stage <= {uart_rxd, sync_stage[2 : 1]};
    
    //------------------------------------------------------------------------------------
    //      Синхронизированная линия приема UART
    assign uart_rxd_sync = sync_stage[1];
    
    //------------------------------------------------------------------------------------
    //      Импульс перехода линии приема UART из 1 в 0
    assign rxd_fall = ~sync_stage[1] & sync_stage[0];
    
    //------------------------------------------------------------------------------------
    //      Регистр значения делителя
    always @(posedge reset, posedge clk)
        if (reset)
            bauddiv_reg <= '0;
        else if (ctrl_init)
            bauddiv_reg <= '0;
        // Захват
        else if (~activity_reg)
            bauddiv_reg <= ctrl_baud_divisor - 1'b1;
        // Хранение
        else
            bauddiv_reg <= bauddiv_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик тактов на передачу одного разряда
    always @(posedge reset, posedge clk)
        if (reset)
            bauddiv_cnt <= '0;
        else if (ctrl_init)
            bauddiv_cnt <= '0;
        // Установка половинного значения счетчика по каждому "падающему" фронту
        else if (rxd_fall)
            bauddiv_cnt <= {1'b0, bauddiv_reg[BDWIDTH - 1 : 1]} + 1'b1;
        // Инкремент при активности приема
        else if (activity_reg)
            if (bauddiv_cnt == bauddiv_reg)
                bauddiv_cnt <= '0;
            else
                bauddiv_cnt <= bauddiv_cnt + 1'b1;
        // Удерживание в нуле во всех остальных случаях
        else
            bauddiv_cnt <= '0;
    
    //------------------------------------------------------------------------------------
    //      Регистр количества стоп-бит
    always @(posedge reset, posedge clk)
        if (reset)
            stopbits_reg <= '0;
        else if (ctrl_init)
            stopbits_reg <= '0;
        else if (~activity_reg)
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
        else if (~activity_reg)
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
        else if (~activity_reg)
            paritytype_reg <= ctrl_parity_type;
        else
            paritytype_reg <= paritytype_reg;
    
    //------------------------------------------------------------------------------------
    //      Разрешение на захват разряда
    assign latch_bit = (bauddiv_cnt == bauddiv_reg);
    
    //------------------------------------------------------------------------------------
    //      Счетчик разрядов, ожидающихся по приему
    always @(posedge reset, posedge clk)
        if (reset)
            pendbit_cnt <= '0;
        else if (ctrl_init)
            pendbit_cnt <= '0;
        // Захват
        else if (~activity_reg)
            // Один стоп-бит и нет контроля паритета
            if (~ctrl_stop_bits & ~ctrl_parity_ena)
                pendbit_cnt <= 4'd9;
            // Два стоп-бита и есть контроль паритета
            else if (ctrl_stop_bits & ctrl_parity_ena)
                pendbit_cnt <= 4'd11;
            // Остальные случаи
            else 
                pendbit_cnt <= 4'd10;
        // Декремент
        else if (latch_bit & |pendbit_cnt)
            pendbit_cnt <= pendbit_cnt - 1'b1;
        // Ожидание
        else
            pendbit_cnt <= pendbit_cnt;
    
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр
    always @(posedge reset, posedge clk)
        if (reset)
            shift_reg <= '0;
        else if (ctrl_init)
            shift_reg <= '0;
        // Сдвиг
        else if (activity_reg & latch_bit)
            // Последний бит
            if (~|pendbit_cnt)
                // Один стоп-бит и нет контроля паритета
                if (~stopbits_reg & ~parityena_reg)
                    shift_reg <= {2'b00, uart_rxd_sync, shift_reg[11 : 3]};
                // Два стоп-бита и есть контроль паритета
                else if (stopbits_reg & parityena_reg)
                    shift_reg <= {uart_rxd_sync, shift_reg[11 : 1]};
                // Остальные случаи
                else
                    shift_reg <= {1'b0, uart_rxd_sync, shift_reg[11 : 2]};
            // Не последний бит
            else
                shift_reg <= {uart_rxd_sync, shift_reg[11 : 1]};
        // Хранение
        else
            shift_reg <= shift_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр активности приема
    always @(posedge reset, posedge clk)
        if (reset)
            activity_reg <= '0;
        else if (ctrl_init)
            activity_reg <= '0;
        else if (activity_reg)
            activity_reg <= ~(latch_bit & ~|pendbit_cnt);
        else
            activity_reg <= rxd_fall;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака достоверности данных
    always @(posedge reset, posedge clk)
        if (reset)
            valid_reg <= '0;
        else if (ctrl_init)
            valid_reg <= '0;
        else
            valid_reg <= (activity_reg & latch_bit & ~|pendbit_cnt);
    
    //------------------------------------------------------------------------------------
    //      Выходной потоковый интерфейс без возможности остановки
    assign rx_data = shift_reg[8 : 1];
    assign rx_valid = valid_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр ошибки паритета чет/нечет
    always @(posedge reset, posedge clk)
        if (reset)
            err_parity_reg <= '0;
        else if (ctrl_init)
            err_parity_reg <= '0;
        else if (activity_reg & latch_bit & ~|pendbit_cnt & parityena_reg)
            // Два стоп-бита
            if (stopbits_reg)
                err_parity_reg <= ^shift_reg[10 : 2] ^ paritytype_reg;
            // Один стоп-бит
            else
                err_parity_reg <= ^shift_reg[11 : 3] ^ paritytype_reg;
        else
            err_parity_reg <= '0;
    assign stat_err_parity = err_parity_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр ошибки приема старт-бита
    always @(posedge reset, posedge clk)
        if (reset)
            err_start_reg <= '0;
        else if (ctrl_init)
            err_start_reg <= '0;
        else if (activity_reg & latch_bit & ~|pendbit_cnt)
            // Один стоп-бит и нет контроля паритета
            if (~stopbits_reg & ~parityena_reg)
                err_start_reg <= shift_reg[3];
            // Два стоп-бита и есть контроль паритета
            else if (stopbits_reg & parityena_reg)
                err_start_reg <= shift_reg[1];
            // Остальные случаи
            else
                err_start_reg <= shift_reg[2];
        else
            err_start_reg <= '0;
    assign stat_err_start = err_start_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр ошибки приема стоп-бита
    always @(posedge reset, posedge clk)
        if (reset)
            err_stop_reg <= '0;
        else if (ctrl_init)
            err_stop_reg <= '0;
        else if (activity_reg & latch_bit & ~|pendbit_cnt)
            // Два стоп-бита
            if (stopbits_reg)
                err_stop_reg <= ~(uart_rxd_sync & shift_reg[11]);
            // Один стоп-бит
            else
                err_stop_reg <= ~uart_rxd_sync;
        else
            err_stop_reg <= '0;
    assign stat_err_stop = err_stop_reg;
    
endmodule // uart_receiver