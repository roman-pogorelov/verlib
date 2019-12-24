/*
    // Fixed-point to trivial float-point converter
    fix2tfp
    #(
        .TFP_WIDTH  (), // Width of trivial float-point data
        .EXP_WIDTH  (), // Width of exponent field in trivial float-point data
        .SIGNREP    (), // Sign representation ("SIGNED" or "UNSIGNED")
        .PIPELINE   ()  // Latency in clock cycles
    )
    the_fix2tfp
    (
        // Reset and clock
        .rst        (), // i
        .clk        (), // i

        // Clock enable
        .clkena     (), // i

        // Input fixed-point data
        .fix_data   (), // i  [TFP_WIDTH - EXP_WIDTH + 2**EXP_WIDTH - 2 : 0]

        // Output trivial float-point data
        .tfp_data   ()  // o  [TFP_WIDTH - 1 : 0]
    ); // the_fix2tfp
*/


module fix2tfp
#(
    parameter int unsigned              TFP_WIDTH = 8,                                          // Width of trivial float-point data
    parameter int unsigned              EXP_WIDTH = 3,                                          // Width of exponent field in trivial float-point data
    parameter int unsigned              FIX_WIDTH = TFP_WIDTH - EXP_WIDTH + 2**EXP_WIDTH - 1,   // Width of trivial fixed-point data
    parameter                           SIGNREP   = "SIGNED",                                   // Sign representation ("SIGNED" or "UNSIGNED")
    parameter int unsigned              PIPELINE  = 4                                           // Latency in clock cycles
)
(
    // Reset and clock
    input  logic                        rst,
    input  logic                        clk,

    // Clock enable
    input  logic                        clkena,

    // Input fixed-point data
    input  logic [FIX_WIDTH - 1 : 0]    fix_data,

    // Output trivial float-point data
    output logic [TFP_WIDTH - 1 : 0]    tfp_data
);
    // Constants declaration
    localparam int unsigned RND_PIPELINE = PIPELINE > 0 ? PIPELINE - 1 : 0;
    localparam int unsigned MIN_EXP = 0;
    localparam int unsigned MAX_EXP = 2**EXP_WIDTH - 1;


    // Signals declaration
    logic [EXP_WIDTH - 1 : 0]               off;
    logic [EXP_WIDTH - 1 : 0]               exp;
    logic                                   is_highest;
    //
    logic [EXP_WIDTH - 1 : 0]               offset_to_round;
    logic [FIX_WIDTH - 1 : 0]               data_to_round;
    //
    logic [TFP_WIDTH - EXP_WIDTH - 1 : 0]   mantissa;
    logic [EXP_WIDTH - 1 : 0]               exponent;


    // Look for the highest significant bit
    always_comb begin
        automatic int i = MIN_EXP;
        automatic int j = MAX_EXP;
        off = MAX_EXP[EXP_WIDTH - 1 : 0];
        exp = MIN_EXP[EXP_WIDTH - 1 : 0];
        for (i = MIN_EXP; i < MAX_EXP; i++) begin
            if (SIGNREP == "SIGNED")
                is_highest = fix_data[FIX_WIDTH - 1] != fix_data[FIX_WIDTH - 2 - i];
            else
                is_highest = fix_data[FIX_WIDTH - 1 - i];
            if (is_highest) begin
                off = i[EXP_WIDTH - 1 : 0];
                exp = j[EXP_WIDTH - 1 : 0];
                break;
            end
            j = j - 1;
        end
    end


    // Pipeline generation logic
    generate

        if (PIPELINE > 0) begin

            // Offset register
            logic [EXP_WIDTH - 1 : 0] off_reg;
            always @(posedge rst, posedge clk) begin
                if (rst)
                    off_reg <= '0;
                else if (clkena)
                    off_reg <= off;
                else
                    off_reg <= off_reg;
            end
            assign offset_to_round = off_reg;

            // Data to round register
            logic [FIX_WIDTH - 1 : 0] data_to_round_reg;
            always @(posedge rst, posedge clk) begin
                if (rst)
                    data_to_round_reg <= '0;
                else if (clkena)
                    data_to_round_reg <= fix_data;
                else
                    data_to_round_reg <= data_to_round_reg;
            end
            assign data_to_round = data_to_round_reg;

            // Exponent register
            logic [PIPELINE - 1 : 0][EXP_WIDTH - 1 : 0] exp_reg;
            always @(posedge rst, posedge clk) begin
                if (rst)
                    exp_reg <= '0;
                else if (clkena)
                    if (PIPELINE > 1)
                        exp_reg <= {exp_reg[PIPELINE - 2 : 0], exp};
                    else
                        exp_reg <= exp;
                else
                    exp_reg <= exp_reg;
            end
            assign exponent = exp_reg[PIPELINE - 1];

        end

        else begin
            assign offset_to_round = off;
            assign data_to_round = fix_data;
            assign exponent = exp;
        end

    endgenerate


    // Unit of rounding to the nearest integer which truncates both
    // the least significant bits and the most significant bits
    float_rounder
    #(
        .IWIDTH     (FIX_WIDTH),                // Input data width
        .OWIDTH     (TFP_WIDTH - EXP_WIDTH),    // Output data width
        .SIGNREP    (SIGNREP),                  // Sign representation
        .PIPELINE   (RND_PIPELINE)              // Latency in clock cycles
    )
    the_float_rounder
    (
        // Reset and clock
        .rst        (rst),                      // i
        .clk        (clk),                      // i

        // Clock enable
        .clkena     (clkena),                   // i

        // Offset of output MSB from input MSB
        .offset     (offset_to_round),          // i  [$clog2(IWIDTH - OWIDTH + 1) - 1 : 0]

        // Input data
        .i_data     (data_to_round),            // i  [IWIDTH - 1 : 0]

        // Output data
        .o_data     (mantissa)                  // o  [OWIDTH - 1 : 0]
    ); // the_float_rounder


    // Output trivial float-point data
    assign tfp_data = {mantissa, exponent};


endmodule: fix2tfp