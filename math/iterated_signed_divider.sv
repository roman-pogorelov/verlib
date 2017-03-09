/*
    //------------------------------------------------------------------------------------
    //      Модуль итерационного деления знаковых целых чисел в дополнительном коде
    iterated_signed_divider
    #(
        .NWIDTH         (), // Разрядность числителя
        .DWIDTH         ()  // Разрядность знаменателя
    )
    the_iterated_signed_divider
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Интерфейс управления
        .start          (), // i
        .ready          (), // o
        .done           (), // o
        
        // Интерфейс входных данных
        .numerator      (), // i  [NWIDTH - 1 : 0]
        .denominator    (), // i  [DWIDTH - 1 : 0]
        
        // Интерфейс выходных данных
        .quotient       (), // o  [NWIDTH - 1 : 0]
        .remainder      ()  // o  [DWIDTH - 1 : 0]
    ); // the_iterated_signed_divider
*/

module iterated_signed_divider
#(
    parameter int unsigned          NWIDTH = 8, // Разрядность числителя
    parameter int unsigned          DWIDTH = 6  // Разрядность знаменателя
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic                    start,
    output logic                    ready,
    output logic                    done,
    
    // Интерфейс входных данных
    input  logic [NWIDTH - 1 : 0]   numerator,
    input  logic [DWIDTH - 1 : 0]   denominator,
    
    // Интерфейс выходных данных
    output logic [NWIDTH - 1 : 0]   quotient,
    output logic [DWIDTH - 1 : 0]   remainder
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                           correction;         // Признак выполнения коррекции результата
    logic                           done_reg;           // Регистр импульса готовности результата
    logic [$clog2(NWIDTH) - 1 : 0]  work_cnt;           // Счетчик итераций рабочего цикла
    logic [DWIDTH - 1 : 0]          denominator_reg;    // Регистр делителя
    logic [DWIDTH - 1 : 0]          new_remainder;      // Новое значение частного остатка
    logic [DWIDTH - 1 : 0]          remainder_reg;      // Регистр частного остатка
    logic [NWIDTH - 1 : 0]          quotient_reg;       // Регистр накопления частного
    
    //------------------------------------------------------------------------------------
    //      Состояния FSM
    enum logic [1 : 0] {
        st_idleness     = 2'b00,
        st_working      = 2'b01,
        st_correction   = 2'b11
    } state;
    wire [1 : 0] st;
    assign st = state;
    
    //------------------------------------------------------------------------------------
    //      Логика переходов FSM
    always @(posedge reset, posedge clk)
        if (reset)
            state <= st_idleness;
        else case (state)
            st_idleness:
                if (start)
                    state <= st_working;
                else
                    state <= st_idleness;
            
            st_working:
                if (work_cnt == (NWIDTH - 1))
                    state <= st_correction;
                else
                    state <= st_working;
            
            st_correction:
                state <= st_idleness;
            
            default:
                state <= st_idleness;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Управляющие сигналы FSM
    assign ready = ~st[0];
    assign correction = st[1];
    
    //------------------------------------------------------------------------------------
    //      Регистр импульса готовности результата
    always @(posedge reset, posedge clk)
        if (reset)
            done_reg <= '0;
        else
            done_reg <= correction;
    assign done = done_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик итераций рабочего цикла
    always @(posedge reset, posedge clk)
        if (reset)
            work_cnt <= '0;
        else if (ready)
            work_cnt <= '0;
        else
            work_cnt <= work_cnt + 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Регистр делителя
    always @(posedge reset, posedge clk)
        if (reset)
            denominator_reg <= '0;
        else if (ready & start)
            denominator_reg <= denominator;
        else
            denominator_reg <= denominator_reg;
    
    //------------------------------------------------------------------------------------
    //      Новое значение частного остатка
    always_comb begin
        // Коррекция остатка
        if (correction)
            // Остаток отрицательный
            if (remainder_reg[DWIDTH - 1])
                // Делитель отрицательный
                if (denominator_reg[DWIDTH - 1])
                    new_remainder = remainder_reg - denominator_reg;
                // Делитель положительный
                else
                    new_remainder = remainder_reg + denominator_reg;
            // Остаток положительный
            else
                new_remainder = remainder_reg;
        // Знаки частного остатка и делителя разные
        else if (remainder_reg[DWIDTH - 1] ^ denominator_reg[DWIDTH - 1])
            new_remainder = {remainder_reg[DWIDTH - 2 : 0], quotient_reg[NWIDTH - 1]} + denominator_reg;
        // Знаки частного остатка и делителя совпадают
        else
            new_remainder = {remainder_reg[DWIDTH - 2 : 0], quotient_reg[NWIDTH - 1]} - denominator_reg;
    end
    
    //------------------------------------------------------------------------------------
    //      Регистр частного остатка
    always @(posedge reset, posedge clk)
        if (reset)
            remainder_reg <= '0;
        else if (ready)
            if (start)
                remainder_reg <= {DWIDTH{numerator[NWIDTH - 1]}};
            else
                remainder_reg <= remainder_reg;
        else
            remainder_reg <= new_remainder;
    assign remainder = remainder_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр накопления частного
    always @(posedge reset, posedge clk)
        if (reset)
            quotient_reg <= '0;
        else if (ready)
            if (start)
                quotient_reg <= numerator;
            else
                quotient_reg <= quotient_reg;
        else if (correction)
            quotient_reg <= quotient_reg + denominator_reg[DWIDTH - 1];
        else
            quotient_reg <= {quotient_reg[NWIDTH - 2 : 0], ~(new_remainder[DWIDTH - 1] ^ denominator_reg[DWIDTH - 1])};
    assign quotient = quotient_reg;
    
endmodule: iterated_signed_divider