`timescale  1ns / 1ps
module rom_sin_cos_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned WIDTH   = 16;       // Разрядность
    localparam string       RAMTYPE = "AUTO";   // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)

    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                   reset;
    logic                   clk;
    logic                   clkena;
    logic [WIDTH - 1 : 0]   arg;
    logic [WIDTH - 1 : 0]   sin;
    logic [WIDTH - 1 : 0]   cos;
    
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
        arg     = 0;
    end
    
    //------------------------------------------------------------------------------------
    //      Модуль табличного вычисления значений функций sin(x) и cos(x)
    rom_sin_cos
    #(
        .WIDTH      (WIDTH),    // Разрядность
        .RAMTYPE    (RAMTYPE)   // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
    )
    the_rom_sin_cos
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Разрешение тактирования
        .clkena     (clkena),   // i
        
        // Значение аргумента
        .arg        (arg),      // i  [WIDTH - 1 : 0]
        
        // Значения sin(arg), cos(arg)
        .sin        (sin),      // o  [WIDTH - 1 : 0]
        .cos        (cos)       // o  [WIDTH - 1 : 0]
    ); // the_rom_sin_cos
    
    //------------------------------------------------------------------------------------
    //      Тестирование
    initial begin
        #100;
        while(1) begin
            @(posedge clk);
            arg = arg + 1;
        end
    end
    
endmodule: rom_sin_cos_tb