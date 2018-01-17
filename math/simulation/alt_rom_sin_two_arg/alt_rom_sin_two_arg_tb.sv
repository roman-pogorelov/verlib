`timescale  1ns / 1ps
module alt_rom_sin_two_arg_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned WIDTH   = 16;               // Разрядность
    parameter               HEXFILE = "sin-lut.hex";    // HEX-файл с предварительно расчитанный таблицей синусов

    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                   reset;
    logic                   clk;
    logic                   clkena;
    logic                   mode0;
    logic                   mode1;
    logic [WIDTH - 1 : 0]   arg0;
    logic [WIDTH - 1 : 0]   arg1;
    logic [WIDTH - 1 : 0]   func0;
    logic [WIDTH - 1 : 0]   func1;
    
    //------------------------------------------------------------------------------------
    //      Сброс
    initial begin
        #00 reset = '1;
        #15 reset = '0;
    end
    
    //------------------------------------------------------------------------------------
    //      Тактирование
    initial clk = '1;
    always  clk = #05 ~clk;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        clkena  = 1;
        arg0    = 0;
        arg1    = 0;
        mode0   = 1;
        mode1   = 1;
    end
    
    //------------------------------------------------------------------------------------
    //      Модуль табличного вычисления значений функций sin(x) и cos(x) двух
    //      независимых аргументов с описанием блоков памяти через мега-функцию Altera
    //          func0 = sin(arg0), если mode0 = 0;
    //          func0 = cos(arg0), если mode0 = 1;
    //          func1 = sin(arg1), если mode1 = 0;
    //          func1 = cos(arg1), если mode1 = 1;
    //      Латентность модуля - 4 такта
    alt_rom_sin_two_arg
    #(
        .WIDTH      (WIDTH),        // Разрядность
        .HEXFILE    (HEXFILE)       // HEX-файл с предварительно расчитанный таблицей синусов
    )
    the_alt_rom_sin_two_arg
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Разрешение тактирования
        .clkena     (clkena),       // i
        
        // Значение аргументов
        .arg0       (arg0),         // i  [WIDTH - 1 : 0]
        .arg1       (arg1),         // i  [WIDTH - 1 : 0]
        
        // Значения режимов
        .mode0      (mode0),        // i
        .mode1      (mode1),        // i
        
        // Значения тригонометрических функций
        .func0      (func0),        // o  [WIDTH - 1 : 0]
        .func1      (func1)         // o  [WIDTH - 1 : 0]
    ); // the_alt_rom_sin_two_arg
    
    //------------------------------------------------------------------------------------
    //      Тестирование
    initial begin
        #100;
        while(1) begin
            @(posedge clk);
            arg0 = arg0 + clkena;
            arg1 = arg1 + 10 * clkena;
        end
    end
    
endmodule: alt_rom_sin_two_arg_tb
