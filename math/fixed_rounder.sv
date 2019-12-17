/*
    // Unit of rounding to the nearest integer which truncates
    // the least significant bits
    fixed_rounder
    #(
        .IWIDTH     (), // Input data width
        .OWIDTH     (), // Output data width
        .SIGNREP    (), // Sign representation
        .PIPELINE   ()  // Latency in clock cycles
    )
    the_fixed_rounder
    (
        // Reset and clock
        .rst        (), // i
        .clk        (), // i

        // Clock enable
        .clkena     (), // i

        // Input data
        .i_data     (), // i  [IWIDTH - 1 : 0]

        // Output data
        .o_data     ()  // o  [OWIDTH - 1 : 0]
    ); // the_fixed_rounder
*/


module fixed_rounder
#(
    parameter int unsigned          IWIDTH   = 16,          // Input data width
    parameter int unsigned          OWIDTH   = 10,          // Output data width
    parameter                       SIGNREP  = "SIGNED",    // Sign representation
    parameter int unsigned          PIPELINE = 1            // Latency in clock cycles
)
(
    // Reset and clock
    input  logic                    rst,
    input  logic                    clk,

    // Clock enable
    input  logic                    clkena,

    // Input data
    input  logic [IWIDTH - 1 : 0]   i_data,

    // Output data
    output logic [OWIDTH - 1 : 0]   o_data
);

    // Constants declaration
    localparam int signed  WIDTH_DIFF = IWIDTH - OWIDTH;


    // Signals declaration
    logic                   addbit;
    logic [OWIDTH - 1 : 0]  result;
    logic [OWIDTH - 1 : 0]  truncated;


    // Additional bit as a result of rounding procedure
    generate

        if (SIGNREP == "SIGNED") begin: signed_representation
            if (WIDTH_DIFF > 0) begin
                if (WIDTH_DIFF > 1)
                    assign addbit = i_data[WIDTH_DIFF - 1] & ((~i_data[IWIDTH - 1] & ~(&i_data[IWIDTH - 2 : WIDTH_DIFF])) | (i_data[IWIDTH - 1] & (|i_data[WIDTH_DIFF - 2 : 0])));
                else
                    assign addbit = i_data[WIDTH_DIFF - 1] &   ~i_data[IWIDTH - 1] & ~(&i_data[IWIDTH - 2 : WIDTH_DIFF]);
            end
            else begin
                assign addbit = 1'b0;
            end
        end // signed_representation

        else begin: unsigned_representation
            if (WIDTH_DIFF > 0)
                assign addbit = i_data[WIDTH_DIFF - 1] & ~(&i_data[IWIDTH - 1 : WIDTH_DIFF]);
            else
                assign addbit = 1'b0;
        end // unsigned_representation

    endgenerate


    // Truncated part of input data
    generate

        if (WIDTH_DIFF < 0) begin
            assign truncated = {i_data, {-WIDTH_DIFF{1'b0}}};
        end

        else begin
            assign truncated = i_data[IWIDTH - 1 : WIDTH_DIFF];
        end

    endgenerate


    // Rounding logic depending on selected latency
    generate

        // No latency
        if (PIPELINE == 0) begin: no_pipeline
            assign result = truncated + addbit;
        end

        // One cycle latency
        else if (PIPELINE == 1) begin: one_stage_pipeline

            // Output data register
            logic [OWIDTH - 1 : 0]  data_reg;
            always @(posedge rst, posedge clk)
                if (rst)
                    data_reg <= '0;
                else if (clkena)
                    data_reg <= truncated + addbit;
                else
                    data_reg <= data_reg;
            assign result = data_reg;

        end

        // Two and more cycles latency
        else begin: two_stages_pipeline

            // Additional bit register
            logic addbit_reg;
            always @(posedge rst, posedge clk)
                if (rst)
                    addbit_reg <= '0;
                else if (clkena)
                    addbit_reg <= addbit;
                else
                    addbit_reg <= addbit_reg;

            // Output data register
            logic [1 : 0][OWIDTH - 1 : 0] data_reg;
            always @(posedge rst, posedge clk)
                if (rst)
                    data_reg <= '0;
                else if (clkena)
                    data_reg <= {data_reg[0] + addbit_reg, truncated};
                else
                    data_reg <= data_reg;
            assign result = data_reg[1];

        end

    endgenerate


    // Output extra stages
    generate

        if (PIPELINE > 2) begin: extra_stages

            // Регистр выходных данных
            logic [PIPELINE - 3 : 0][OWIDTH - 1 : 0] data_reg;
            always @(posedge rst, posedge clk)
                if (rst)
                    data_reg <= '0;
                else if (clkena)
                    if (PIPELINE > 3)
                        data_reg <= {data_reg[PIPELINE - 4 : 0], result};
                    else
                        data_reg <= result;
                else
                    data_reg <= data_reg;
            assign o_data = data_reg[PIPELINE - 3];
        end

        else begin: no_extra_stages
            assign o_data = result;
        end

    endgenerate

endmodule // fixed_rounder
