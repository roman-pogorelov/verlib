/*
    // Trivial float-point to fixed-point converter
    tfp2fix
    #(
        .TFP_WIDTH  (), // Width of trivial float-point data
        .EXP_WIDTH  (), // Width of exponent field in trivial float-point data
        .PIPELINE   ()  // Latency in clock cycles
    )
    the_tfp2fix
    (
        // Reset and clock
        .rst        (), // i
        .clk        (), // i

        // Clock enable
        .clkena     (), // i

        // Input trivial float-point data
        .tfp_data   (), // i  [TFP_WIDTH - 1 : 0]

        // Output fixed-point data
        .fix_data   ()  // o  [TFP_WIDTH - EXP_WIDTH + 2**EXP_WIDTH - 2 : 0]
    ); // the_tfp2fix
*/


module tfp2fix
#(
    parameter int unsigned              TFP_WIDTH = 8,                                          // Width of trivial float-point data
    parameter int unsigned              EXP_WIDTH = 3,                                          // Width of exponent field in trivial float-point data
    parameter int unsigned              FIX_WIDTH = TFP_WIDTH - EXP_WIDTH + 2**EXP_WIDTH - 1,   // Width of trivial fixed-point data
    parameter int unsigned              PIPELINE  = 1                                           // Latency in clock cycles
)
(
    // Reset and clock
    input  logic                        rst,
    input  logic                        clk,

    // Clock enable
    input  logic                        clkena,

    // Input trivial float-point data
    input  logic [TFP_WIDTH - 1 : 0]    tfp_data,

    // Output fixed-point data
    output logic [FIX_WIDTH - 1 : 0]    fix_data
);
    // Signals declaration
    logic [FIX_WIDTH - 1 : 0]   emantissa;
    logic [EXP_WIDTH - 1 : 0]   exponent;
    logic [FIX_WIDTH - 1 : 0]   fixvalue;


    // Extended mantissa
    assign emantissa = {{2**EXP_WIDTH{tfp_data[TFP_WIDTH - 1]}}, tfp_data[TFP_WIDTH - 2 : EXP_WIDTH]};


    // Exponent field
    assign exponent = tfp_data[EXP_WIDTH - 1 : 0];


    // Fixed-point value
    assign fixvalue = emantissa << exponent;


    // Output logic depending on the PIPELINE parameter
    generate

        if (PIPELINE > 0) begin

            logic [PIPELINE - 1 : 0][FIX_WIDTH - 1 : 0] fix_data_reg;
            always @(posedge rst, posedge clk) begin
                if (rst)
                    fix_data_reg <= '0;
                else if (clkena)
                    if (PIPELINE > 1)
                        fix_data_reg <= {fix_data_reg[PIPELINE - 2 : 0], fixvalue};
                    else
                        fix_data_reg <= fixvalue;
                else
                    fix_data_reg <= fix_data_reg;
            end
            assign fix_data = fix_data_reg[PIPELINE - 1];

        end

        else begin
            assign fix_data = fixvalue;
        end

    endgenerate

endmodule: tfp2fix