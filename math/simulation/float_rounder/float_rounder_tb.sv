`timescale  1ns / 1ps
module float_rounder_tb ();


    // Constants declaration
    parameter int unsigned          IWIDTH   = 7;           // Input data width
    parameter int unsigned          OWIDTH   = 4;           // Output data width
    parameter                       SIGNREP  = "UNSIGNED";  // Sign representation
    parameter int unsigned          PIPELINE = 3;           // Latency in clock cycles


    // Signals declaration
    logic                                       rst;
    logic                                       clk;
    logic                                       clkena;
    logic [$clog2(IWIDTH - OWIDTH + 1) - 1 : 0] offset;
    logic [IWIDTH - 1 : 0]                      i_data;
    logic [OWIDTH - 1 : 0]                      o_data;
    logic [OWIDTH - 1 : 0]                      r_data;



    // Initialization
    initial begin
        rst    = 1;
        clk    = 1;
        clkena = 1;
        offset = 3;
        i_data = 'x;
    end


    // Reset
    initial #15 rst = 0;


    // Clock
    always clk = #05 ~clk;


    // Unit of rounding to the nearest integer which truncates both
    // the least significant bits and the most significant bits
    float_rounder
    #(
        .IWIDTH     (IWIDTH),   // Input data width
        .OWIDTH     (OWIDTH),   // Output data width
        .SIGNREP    (SIGNREP),  // Sign representation
        .PIPELINE   (PIPELINE)  // Latency in clock cycles
    )
    the_float_rounder
    (
        // Reset and clock
        .rst        (rst),      // i
        .clk        (clk),      // i

        // Clock enable
        .clkena     (clkena),   // i

        // Offset of output MSB from input MSB
        .offset     (offset),   // i  [$clog2(IWIDTH - OWIDTH + 1) - 1 : 0]

        // Input data
        .i_data     (i_data),   // i  [IWIDTH - 1 : 0]

        // Output data
        .o_data     (o_data)    // o  [OWIDTH - 1 : 0]
    ); // the_float_rounder


    //------------------------------------------------------------------------------------
    //      Модуль масштабирования данных с округлением
    scaler
    #(
        .IWIDTH             (IWIDTH),   // Разрядность входных данных (должна быть больше разрядности выходных!!!)
        .OWIDTH             (OWIDTH),   // Разрядность выходных данных
        .REPRESENTATION     (SIGNREP),  // Представление данных ("SIGNED" | "UNSIGNED")
        .PIPELINE           (PIPELINE)  // Глубина линии задержки (не менее 1!!!)
    )
    the_scaler
    (
        // Тактирование и сброс
        .reset              (rst),      // i
        .clk                (clk),      // i

        // Разрешение тактирования
        .clkena             (clkena),   // i

        // Интерфейс управления масштабированием
        .ctrl_scale         (offset),   // i  [$clog2(IWIDTH - OWIDTH + 1) - 1 : 0]

        // Интерфейс входных данных
        .i_data             (i_data),   // i  [IWIDTH - 1 : 0]

        // Интерфейс выходных данных
        .o_data             (r_data)    // o  [OWIDTH - 1 : 0]
    ); // the_scaler


    // Testing logic
    initial begin
        #100;
        @(posedge clk);
        for (int i = 0; i < 2**IWIDTH; i++) begin
            i_data = i;
            @(posedge clk);
        end
        i_data = 'x;
    end


endmodule: float_rounder_tb