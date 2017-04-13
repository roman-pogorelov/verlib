/*
    //------------------------------------------------------------------------------------
    //      Модуль итерационного перевода знакового целого произвольной разрядности
    //      в число с плавающей точкой одинарной точности
    iterated_fixed_to_float
    #(
        .WIDTH      ()  // Разрядность входных данных (знакового целого)
    )
    the_iterated_fixed_to_float
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейс управления
        .start      (), // i
        .ready      (), // o
        .done       (), // o
        
        // Интерфейс входных данных
        .fixed      (), // i  [WIDTH - 1 : 0]
        
        // Интерфейс выходных данных
        .float      ()  // o  [31 : 0]
    ); // the_iterated_fixed_to_float
*/

module iterated_fixed_to_float
#(
    parameter int unsigned          WIDTH = 8   // Разрядность входных данных (знакового целого)
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
    input  logic [WIDTH - 1 : 0]    fixed,
    
    // Интерфейс выходных данных
    output logic [31 : 0]           float
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned         EXP_INIT = 127 + WIDTH - 1; // Инициализационное значение порядка
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                           state_reg;
    logic                           sign_bit_reg;
    logic [WIDTH - 1 : 0]           significand_reg;
    logic [7 : 0]                   exponent_reg;
    logic                           done_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр текущего состояния
    always @(posedge reset, posedge clk)
        if (reset)
            state_reg <= '0;
        else if (state_reg)
            state_reg <= ~significand_reg[WIDTH - 2];
        else
            state_reg <= start & |fixed[WIDTH - 2 : 0];
    
    //------------------------------------------------------------------------------------
    //      Регистр знакового бита мантиссы
    always @(posedge reset, posedge clk)
        if (reset)
            sign_bit_reg <= '0;
        else if (~state_reg & start)
            sign_bit_reg <= fixed[WIDTH - 1];
        else
            sign_bit_reg <= sign_bit_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр значащей части (мантиссы) в беззнаковом представлении
    always @(posedge reset, posedge clk)
        if (reset)
            significand_reg <= '0;
        else if (~state_reg & start)
            significand_reg <= (fixed ^ {WIDTH{fixed[WIDTH - 1]}}) + fixed[WIDTH - 1];
        else if (state_reg)
            significand_reg <= {significand_reg[WIDTH - 2 : 0], 1'b0};
        else
            significand_reg <= significand_reg;
    
    //------------------------------------------------------------------------------------
    //      Регист порядка
    always @(posedge reset, posedge clk)
        if (reset)
            exponent_reg <= '0;
        else if (~state_reg & start)
            if (|fixed[WIDTH - 1 : 0])
                exponent_reg <= EXP_INIT[7 : 0];
            else
                exponent_reg <= '0;
        else
            exponent_reg <= exponent_reg - state_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр индикации завершения работы
    always @(posedge reset, posedge clk)
        if (reset)
            done_reg <= '0;
        else
            done_reg <= (~state_reg & start & ~|fixed[WIDTH - 2 : 0]) | (state_reg & significand_reg[WIDTH - 2]);
    
    //------------------------------------------------------------------------------------
    //      Формирование выходного значения в зависимости от разрядности входного
    generate
        if (WIDTH >= 24)
            assign float = {sign_bit_reg, exponent_reg, significand_reg[WIDTH - 2 : WIDTH - 24]};
        else
            assign float = {sign_bit_reg, exponent_reg, significand_reg[WIDTH - 2 : 0], {24 - WIDTH{1'b0}}};
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Признак готовности и индикатор завершения работы
    assign ready = ~state_reg;
    assign done  =  done_reg;
    
    
endmodule // iterated_fixed_to_float