/*
    // Unit of rounding to the nearest integer which truncates both
    // the least significant bits and the most significant bits
    float_rounder
    #(
        .IWIDTH     (), // Input data width
        .OWIDTH     (), // Output data width
        .SIGNREP    (), // Sign representation
        .PIPELINE   ()  // Latency in clock cycles
    )
    the_float_rounder
    (
        // Reset and clock
        .rst        (), // i
        .clk        (), // i

        // Clock enable
        .clkena     (), // i

        // Offset of output MSB from input MSB
        .offset     (), // i  [$clog2(IWIDTH - OWIDTH + 1) - 1 : 0]

        // Input data
        .i_data     (), // i  [IWIDTH - 1 : 0]

        // Output data
        .o_data     ()  // o  [OWIDTH - 1 : 0]
    ); // the_float_rounder
*/


module float_rounder
#(
    parameter int unsigned                              IWIDTH   = 16,          // Input data width
    parameter int unsigned                              OWIDTH   = 10,          // Output data width
    parameter                                           SIGNREP  = "SIGNED",    // Sign representation
    parameter int unsigned                              PIPELINE = 1            // Latency in clock cycles
)
(
    // Reset and clock
    input  logic                                        rst,
    input  logic                                        clk,

    // Clock enable
    input  logic                                        clkena,

    // Offset of output MSB from input MSB
    input  logic [$clog2(IWIDTH - OWIDTH + 1) - 1 : 0]  offset,

    // Input data
    input  logic [IWIDTH - 1 : 0]                       i_data,

    // Output data
    output logic [OWIDTH - 1 : 0]                       o_data
);
    // Constant declaration
    localparam int unsigned FIX_PIPELINE = PIPELINE > 0 ? PIPELINE - 1 : 0;


    // Signals declaration
    logic [2*IWIDTH - OWIDTH - 1 : 0]           data_extended;
    logic [IWIDTH - OWIDTH : 0][IWIDTH - 1 : 0] data_array;
    logic [IWIDTH - 1 : 0]                      data_selected;
    logic [IWIDTH - 1 : 0]                      data_to_round;


    // Input data word extended with zeros
    assign data_extended[2*IWIDTH - OWIDTH - 1 : IWIDTH - OWIDTH] = i_data;
    assign data_extended[IWIDTH - OWIDTH - 1 : 0] = '0;


    // Data array each element of which is an input word shifted at the different number of bits
    generate
        genvar i;
        for (i = 0; i < (IWIDTH - OWIDTH + 1); i++) begin: data_array_generation
            assign data_array[IWIDTH - OWIDTH - i] = data_extended[IWIDTH + i - 1 : i];
        end
    endgenerate


    // Selected element of the data array
    assign data_selected = data_array[offset];


    // Data to round word logic depending on the PIPELINE parameter
    generate

        if (PIPELINE > 0) begin

            logic [IWIDTH - 1 : 0] data_to_round_reg;
            always @(posedge rst, posedge clk) begin
                if (rst)
                    data_to_round_reg <= '0;
                else if (clkena)
                    data_to_round_reg <= data_selected;
                else
                    data_to_round_reg <= data_to_round_reg;
            end
            assign data_to_round = data_to_round_reg;

        end

        else begin
            assign data_to_round = data_selected;
        end

    endgenerate


    // Unit of rounding to the nearest integer which truncates
    // the least significant bits
    fixed_rounder
    #(
        .IWIDTH     (IWIDTH),           // Input data width
        .OWIDTH     (OWIDTH),           // Output data width
        .SIGNREP    (SIGNREP),          // Sign representation
        .PIPELINE   (FIX_PIPELINE)      // Latency in clock cycles
    )
    the_fixed_rounder
    (
        // Reset and clock
        .rst        (rst),              // i
        .clk        (clk),              // i

        // Clock enable
        .clkena     (clkena),           // i

        // Input data
        .i_data     (data_to_round),    // i  [IWIDTH - 1 : 0]

        // Output data
        .o_data     (o_data)            // o  [OWIDTH - 1 : 0]
    ); // the_fixed_rounder


endmodule // float_rounder
