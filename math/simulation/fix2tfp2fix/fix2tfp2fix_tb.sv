`timescale  1ns / 1ps
module fix2tfp2fix_tb ();


    // Constants declaration
    localparam int unsigned TFP_WIDTH = 8;                                          // Width of trivial float-point data
    localparam int unsigned EXP_WIDTH = 3;                                          // Width of exponent field in trivial float-point data
    localparam int unsigned FIX_WIDTH = TFP_WIDTH - EXP_WIDTH + 2**EXP_WIDTH - 1;   // Width of trivial fixed-point data
    localparam              SIGNREP   = "SIGNED";                                   // Sign representation ("SIGNED" or "UNSIGNED")
    localparam int unsigned PIPELINE  = 0;                                          // Latency in clock cycles


    // Signals declaration
    logic                                       rst;
    logic                                       clk;
    logic                                       clkena;
    logic [FIX_WIDTH - 1 : 0]                   inp_data;
    logic [FIX_WIDTH - 1 : 0]                   out_data;
    logic [TFP_WIDTH - 1 : 0]                   tfp_data;


    // Initialization
    initial begin
        rst    = 1;
        clk    = 1;
        clkena = 1;
        inp_data = 'x;
    end


    // Reset
    initial #15 rst = 0;


    // Clock
    always clk = #05 ~clk;


    // Fixed-point to trivial float-point converter
    fix2tfp
    #(
        .TFP_WIDTH  (TFP_WIDTH),    // Width of trivial float-point data
        .EXP_WIDTH  (EXP_WIDTH),    // Width of exponent field in trivial float-point data
        .SIGNREP    (SIGNREP),      // Sign representation ("SIGNED" or "UNSIGNED")
        .PIPELINE   (PIPELINE)      // Latency in clock cycles
    )
    the_fix2tfp
    (
        // Reset and clock
        .rst        (rst),          // i
        .clk        (clk),          // i

        // Clock enable
        .clkena     (clkena),       // i

        // Input fixed-point data
        .fix_data   (inp_data),     // i  [TFP_WIDTH - EXP_WIDTH + 2**EXP_WIDTH - 2 : 0]

        // Output trivial float-point data
        .tfp_data   (tfp_data)      // o  [TFP_WIDTH - 1 : 0]
    ); // the_fix2tfp


    // Trivial float-point to fixed-point converter
    tfp2fix
    #(
        .TFP_WIDTH  (TFP_WIDTH),    // Width of trivial float-point data
        .EXP_WIDTH  (EXP_WIDTH),    // Width of exponent field in trivial float-point data
        .SIGNREP    (SIGNREP),      // Sign representation ("SIGNED" or "UNSIGNED")
        .PIPELINE   (PIPELINE)      // Latency in clock cycles
    )
    the_tfp2fix
    (
        // Reset and clock
        .rst        (rst),          // i
        .clk        (clk),          // i

        // Clock enable
        .clkena     (clkena),       // i

        // Input trivial float-point data
        .tfp_data   (tfp_data),     // i  [TFP_WIDTH - 1 : 0]

        // Output fixed-point data
        .fix_data   (out_data)      // o  [TFP_WIDTH - EXP_WIDTH + 2**EXP_WIDTH - 2 : 0]
    ); // the_tfp2fix


    // Testing logic
    initial begin
        #100;
        @(posedge clk);
        for (int i = 0; i < 2**FIX_WIDTH; i++) begin
            inp_data = i;
            @(posedge clk);
        end
        inp_data = 'x;
    end


endmodule: fix2tfp2fix_tb