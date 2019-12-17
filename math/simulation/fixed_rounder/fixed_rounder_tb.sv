`timescale  1ns / 1ps
module fixed_rounder_tb ();


    // Constants declaration
    parameter int unsigned          IWIDTH   = 7;           // Input data width
    parameter int unsigned          OWIDTH   = 4;           // Output data width
    parameter                       SIGNREP  = "UNSIGNED";  // Sign representation
    parameter int unsigned          PIPELINE = 3;           // Latency in clock cycles


    // Signals declaration
    logic                       rst;
    logic                       clk;
    logic                       clkena;
    logic [IWIDTH - 1 : 0]      i_data;
    logic [OWIDTH - 1 : 0]      o_data;
    logic [OWIDTH - 1 : 0]      r_data;


    // Initialization
    initial begin
        rst    = 1;
        clk    = 1;
        clkena = 1;
        i_data = 'x;
    end


    // Reset
    initial #15 rst = 0;


    // Clock
    always clk = #05 ~clk;


    // Unit of rounding to the nearest integer
    fixed_rounder
    #(
        .IWIDTH     (IWIDTH),   // Input data width
        .OWIDTH     (OWIDTH),   // Output data width
        .SIGNREP    (SIGNREP),  // Sign representation
        .PIPELINE   (PIPELINE)  // Latency in clock cycles
    )
    the_fixed_rounder
    (
        // Reset and clock
        .rst        (rst),      // i
        .clk        (clk),      // i

        // Clock enable
        .clkena     (clkena),   // i

        // Input data
        .i_data     (i_data),   // i  [IWIDTH - 1 : 0]

        // Output data
        .o_data     (o_data)    // o  [OWIDTH - 1 : 0]
    ); // the_fixed_rounder


    //------------------------------------------------------------------------------------
    //      Модуль округления по правилу "к ближайшему целому" "COMPNAME"
    rounder
    #(
        .IWIDTH             (IWIDTH),   // Разрядность входных данных
        .OWIDTH             (OWIDTH),   // Разрядность выходных данных
        .REPRESENTATION     (SIGNREP),  // Представление данных ("SIGNED" | "UNSIGNED")
        .PIPELINE           (PIPELINE)  // Глубина линии задержки
    )
    COMPNAME
    (
        .reset              (rst),      // Асинхронный сброс
        .clk                (clk),      // Тактирование
        .clk_ena            (clkena),   // Разрешение тактирования
        .data_in            (i_data),   // Входные данные
        .data_out           (r_data)    // Выходные данные
    ); // COMPNAME


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


endmodule: fixed_rounder_tb