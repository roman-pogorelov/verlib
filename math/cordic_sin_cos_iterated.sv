/*
    //------------------------------------------------------------------------------------
    //      Модуль итерационного вычисления тригонометрических функций sin(x), cos(x)
    //      с использованием CORDIC-алгоритма
    cordic_sin_cos_iterated
    #(
        .WIDTH      (), // Разрядность (1 < WIDTH <= 64)
        .ARGRANGE   (), // Диапазон аргумента: "PI2" - [-PI/2 : PI/2), "PI" - [-PI : PI)
        .RAMTYPE    ()  // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
    )
    the_cordic_sin_cos_iterated
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейс управления
        .start      (), // i
        .ready      (), // o
        .done       (), // o
        
        // Значение аргумента [-PI ; PI)
        .arg        (), // i  [WIDTH - 1 : 0]
        
        // Выходные значения синуса и косинуса
        .sin        (), // o  [WIDTH - 1 : 0]
        .cos        ()  // o  [WIDTH - 1 : 0]
    ); // the_cordic_sin_cos_iterated
*/

`include "cordic_defines.svh"

module cordic_sin_cos_iterated
#(
    parameter int unsigned          WIDTH       = 16,       // Разрядность (1 < WIDTH <= 64)
    parameter string                ARGRANGE    = "PI2",    // Диапазон аргумента: "PI2" - [-PI/2 : PI/2), "PI" - [-PI : PI)
    parameter string                RAMTYPE     = "MLAB"    // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic                    start,
    output logic                    ready,
    output logic                    done,
    
    // Значение аргумента [-PI ; PI)
    input  logic [WIDTH - 1 : 0]    arg,
    
    // Выходные значения синуса и косинуса
    output logic [WIDTH - 1 : 0]    sin,
    output logic [WIDTH - 1 : 0]    cos
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned                 ADDWIDTH    = $clog2(WIDTH) + 2;
    localparam int unsigned                 COREWIDTH   = WIDTH + ADDWIDTH;
    localparam int unsigned                 MAXITER     = WIDTH - 2;
    localparam logic [COREWIDTH - 1 : 0]    INITVAL     = {CORDIC_GAIN[MAXITER][63 : 64 - WIDTH], {ADDWIDTH{1'b0}}};

    //------------------------------------------------------------------------------------
    //      Описание блоков памяти с учетом атрибутов Altera
    (* ramstyle = RAMTYPE *) reg [COREWIDTH - 1 : 0] lookup_table [WIDTH - 2 : 0];
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                               state_reg;
    logic                               done_reg;
    logic [$clog2(COREWIDTH) - 1 : 0]   iteration_cnt;
    logic [COREWIDTH - 1 : 0]           init_x;
    logic [COREWIDTH - 1 : 0]           init_y;
    logic [COREWIDTH - 1 : 0]           init_z;
    logic [COREWIDTH - 1 : 0]           alpha;
    logic [COREWIDTH - 1 : 0]           core_x;
    logic [COREWIDTH - 1 : 0]           core_y;
    logic [COREWIDTH - 1 : 0]           core_z;
    logic                               clkena;
    
    //------------------------------------------------------------------------------------
    //      Инициализация таблицы элементарных углов поворота
    initial begin
        for (int i = 0; i < WIDTH - 1; i++) begin
            lookup_table[i] = CORDIC_LUT[i][63 : 64 - COREWIDTH] + ((COREWIDTH < 64) ? CORDIC_LUT[i][64 - COREWIDTH - 1] : 1'b0);
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Регистр текущего состояния:
    //          1 - бездействие (готовность)
    //          0 - работа (отсутствие готовности)
    initial state_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            state_reg <= '1;
        else if (state_reg)
            state_reg <= ~start;
        else
            state_reg <= (iteration_cnt == MAXITER);
    assign ready = state_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака окончания вычисления
    initial done_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            done_reg <= '0;
        else
            done_reg <= ~state_reg & (iteration_cnt == MAXITER);
    assign done = done_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик итераций
    initial iteration_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            iteration_cnt <= '0;
        else if (state_reg)
            iteration_cnt <= '0;
        else
            iteration_cnt <= iteration_cnt + 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Начальные значения координат и угла поворота
    assign init_x = INITVAL;
    assign init_y = '0;
    assign init_z = {arg, {ADDWIDTH{1'b0}}};
    
    //------------------------------------------------------------------------------------
    //      Текущий элементарный угол поворота
    assign alpha = lookup_table[iteration_cnt];
    
    //------------------------------------------------------------------------------------
    //      Разрешение тактирования вычислительного ядра
    assign clkena = start | ~state_reg;
    
    //------------------------------------------------------------------------------------
    //      Вычислительное ядро, выполняющее одну итерацию CORDIC-алгоритма
    cordic_core
    #(
        .WIDTH      (COREWIDTH)         // Разрядность
    )
    the_cordic_core
    (
        // Сброс и тактирование
        .reset      (reset),            // i
        .clk        (clk),              // i
        
        // Разрешение тактирования
        .clkena     (clkena),           // i
        
        // Параметры управления
        .init       (state_reg),        // i
        .loop       (~state_reg),       // i
        .shift      (iteration_cnt),    // i  [WIDTH - 1 : 0]
        .alpha      (alpha),            // i  [WIDTH - 1 : 0]
        
        // Входные данные
        .i_x        (init_x),           // i  [WIDTH - 1 : 0]
        .i_y        (init_y),           // i  [WIDTH - 1 : 0]
        .i_z        (init_z),           // i  [WIDTH - 1 : 0]
        
        // Выходные данные
        .o_x        (core_x),           // o  [WIDTH - 1 : 0]
        .o_y        (core_y),           // o  [WIDTH - 1 : 0]
        .o_z        (core_z)            // o  [WIDTH - 1 : 0]
    ); // the_cordic_core
    
    //------------------------------------------------------------------------------------
    //      Формирование значение sin(x) и cos(x)
    assign cos = core_x[COREWIDTH - 1 : ADDWIDTH];
    assign sin = core_y[COREWIDTH - 1 : ADDWIDTH];
    
endmodule: cordic_sin_cos_iterated
