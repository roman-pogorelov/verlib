/*
    //------------------------------------------------------------------------------------
    //      UART-передатчик с входным потоковым интерфейсом и динамически 
    //      перестраиваемыми параметрами
    uart_transmitter
    #(
        .BDWIDTH            ()  // Разрядность делителя
    )
    the_uart_transmitter
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
        
        // Входной потоковый интерфейс
        .tx_data            (), // i  [7 : 0]
        .tx_valid           (), // i
        .tx_ready           (), // o
        
        // Линия передачи UART
        .uart_txd           ()  // o
    ); // the_uart_transmitter
*/

module uart_transmitter
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
    
    // Входной потоковый интерфейс
    input  logic [7 : 0]            tx_data,
    input  logic                    tx_valid,
    output logic                    tx_ready,
    
    // Линия передачи UART
    output logic                    uart_txd
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [BDWIDTH - 1 : 0]         bauddiv_reg;        // Регистр значения делителя
    logic [BDWIDTH - 1 : 0]         bauddiv_cnt;        // Счетчик тактов на передачу одного разряда
    logic                           next_bit;           // Разрешение перехода к следующему разряду
    logic [3 : 0]                   pendbit_cnt;        // Счетчик разрядов, ожидающих передачи
    logic                           no_pend_bit;        // Признак отсутствия разрядов, ожидающих передачу
    logic [11 : 0]                  shift_reg;          // Сдвиговый регистр
    logic                           busy_reg;           // Регистр занятости передатчика
    
    //------------------------------------------------------------------------------------
    //      Регистр значения делителя
    always @(posedge reset, posedge clk)
        if (reset)
            bauddiv_reg <= '0;
        else if (ctrl_init)
            bauddiv_reg <= '0;
        // Захват
        else if (tx_ready & tx_valid)
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
        // Удерживание в нуле
        else if (tx_ready | (bauddiv_cnt == bauddiv_reg))
            bauddiv_cnt <= '0;
        // Инкремент
        else
            bauddiv_cnt <= bauddiv_cnt + 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Разрешение перехода к следующему разряду
    assign next_bit = (bauddiv_cnt == bauddiv_reg);
    
    //------------------------------------------------------------------------------------
    //      Счетчик разрядов, ожидающих передачи
    always @(posedge reset, posedge clk)
        if (reset)
            pendbit_cnt <= '0;
        else if (ctrl_init)
            pendbit_cnt <= '0;
        // Захват
        else if (tx_ready & tx_valid)
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
        else if (next_bit & ~no_pend_bit)
            pendbit_cnt <= pendbit_cnt - 1'b1;
        // Ожидание
        else
            pendbit_cnt <= pendbit_cnt;
    
    //------------------------------------------------------------------------------------
    //      Признак отсутствия разрядов, ожидающих передачу
    assign no_pend_bit = (pendbit_cnt == 0);
    
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр
    initial shift_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            shift_reg <= '1;
        else if (ctrl_init)
            shift_reg <= '1;
        // Захват
        else if (tx_ready & tx_valid)
            shift_reg <= {
                            2'b11,                                              // Стоп-биты
                            (^tx_data ^ ctrl_parity_type) | ~ctrl_parity_ena,   // Бит паритета чет/нечет
                            tx_data,                                            // Передаваемый байт
                            1'b0                                                // Старт-бит
                         };
        // Сдвиг
        else if (~tx_ready & next_bit)
            shift_reg <= {1'b1, shift_reg[11 : 1]};
        // Ожидание
        else
            shift_reg <= shift_reg;
    
    //------------------------------------------------------------------------------------
    //      Линия передачи UART
    assign uart_txd = shift_reg[0];
    
    //------------------------------------------------------------------------------------
    //      Регистр готовности передатчика
    always @(posedge reset, posedge clk)
        if (reset)
            busy_reg <= '0;
        else if (ctrl_init)
            busy_reg <= '0;
        else if (busy_reg)
            busy_reg <= ~(next_bit & no_pend_bit & ~tx_valid);
        else
            busy_reg <= tx_valid;
    
    //------------------------------------------------------------------------------------
    //      Сигнал готовности передатчика
    assign tx_ready = ~busy_reg | (next_bit & no_pend_bit);
    
endmodule // uart_transmitter