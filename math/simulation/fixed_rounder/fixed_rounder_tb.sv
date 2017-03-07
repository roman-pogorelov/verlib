`timescale  1ns / 1ps
module fixed_rounder_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned IWIDTH   = 6;  // Разрядность входных данных
    localparam int unsigned OWIDTH   = 3;  // Разрядность выходных данных
    localparam int unsigned PIPELINE = 2;  // Глубина конвейеризации
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                       reset;
    logic                       clk;
    logic                       clkena;
    logic                       i_signed;
    logic [IWIDTH - 1 : 0]      i_data;
    logic                       o_signed;
    logic [OWIDTH - 1 : 0]      o_data;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        reset       = 1;
        clk         = 1;
        clkena      = 1;
        i_signed    = 'x;
        i_data      = 'x;
    end
    
    //------------------------------------------------------------------------------------
    //      Сброс
    initial #15 reset = 0;
    
    //------------------------------------------------------------------------------------
    //      Тактирование
    always clk = #05 ~clk;
    
    //------------------------------------------------------------------------------------
    //      Модуль округления чисел в формате с фиксированной точкой методом
    //      "до ближайшего целого". 
    fixed_rounder
    #(
        .IWIDTH     (IWIDTH),   // Разрядность входных данных
        .OWIDTH     (OWIDTH),   // Разрядность выходных данных
        .PIPELINE   (PIPELINE)  // Глубина конвейеризации
    )
    the_fixed_rounder
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Разрешение тактирования
        .clkena     (clkena),   // i
        
        // Входные данные
        .i_signed   (i_signed), // i                    // Признак знакового представления
        .i_data     (i_data),   // i  [IWIDTH - 1 : 0]
        
        // Выходные данные
        .o_signed   (o_signed), // o
        .o_data     (o_data)    // o  [OWIDTH - 1 : 0]
    ); // the_fixed_rounder
    
    //------------------------------------------------------------------------------------
    //      Процесс тестирования
    initial begin
        #100;
        @(posedge clk);
        for (int i = 0; i < 2**IWIDTH; i++) begin
            i_signed = 1;
            i_data = i;
            @(posedge clk);
        end
        i_signed = 'x;
        i_data = 'x;
    end
    
endmodule: fixed_rounder_tb