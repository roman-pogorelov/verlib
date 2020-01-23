/*
    // DataStream interface fanout
    ds_fanout
    #(
        .WIDTH      (), // Stream width
        .SOURCES    ()  // The number of outbound streams
    )
    the_ds_fanout
    (
        // Reset and clock
        .reset      (), // i  Do not use
        .clk        (), // i  Do not use

        // Active outbound streams selection
        .active     (), // i  [SOURCES - 1 : 0]

        // Inbound stream
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o

        // Outbound streams
        .o_dat      (), // o  [SOURCES - 1 : 0][WIDTH - 1 : 0]
        .o_val      (), // o  [SOURCES - 1 : 0]
        .o_rdy      ()  // i  [SOURCES - 1 : 0]
    ); // the_ds_fanout
*/

module ds_fanout
#(
    parameter int unsigned                          WIDTH   = 8,    // Stream width
    parameter int unsigned                          SOURCES = 2     // The number of outbound streams
)
(
    // Reset and clock
    input  logic                                    reset,
    input  logic                                    clk,

    // Active outbound streams selection
    input  logic [SOURCES - 1 : 0]                  active,

    // Inbound stream
    input  logic [WIDTH - 1 : 0]                    i_dat,
    input  logic                                    i_val,
    output logic                                    i_rdy,

    // Outbound streams
    output logic [SOURCES - 1 : 0][WIDTH - 1 : 0]   o_dat,
    output logic [SOURCES - 1 : 0]                  o_val,
    input  logic [SOURCES - 1 : 0]                  o_rdy
);
    // General logic
    generate
        genvar i, j;
        logic [SOURCES - 1 : 0][SOURCES - 1 : 0] mask;
        for (i = 0; i < SOURCES; i++) begin: fanout_gen
            for (j = 0; j < SOURCES; j++) begin: mask_gen
                assign mask[i][j] = (i == j);
            end
            assign o_dat[i] = i_dat;
            assign o_val[i] = i_val & active[i] & (&(o_rdy | mask[i] | ~active));
        end
    endgenerate


    // Inbound readiness logic
    assign i_rdy = &(o_rdy | ~active);


endmodule // ds_fanout