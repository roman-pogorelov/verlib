/*
    // DataStream multiplexer
    ds_mux
    #(
        .WIDTH      (), // Stream width
        .INPUTS     ()  // The number of inbound streams
    )
    the_ds_mux
    (
        // Reset and clock
        .reset      (), // i  Do not use
        .clk        (), // i  Do not use

        // Active inbound interface selection
        .select     (), // i  [$clog2(INPUTS) - 1 : 0]

        // Inbound streams
        .i_dat      (), // i  [INPUTS - 1 : 0][WIDTH - 1 : 0]
        .i_val      (), // i  [INPUTS - 1 : 0]
        .i_rdy      (), // o  [INPUTS - 1 : 0]

        // Outbound stream
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_rdy      ()  // i
    ); // the_ds_mux
*/


module ds_mux
#(
    parameter int unsigned                          WIDTH   = 8,    // Stream width
    parameter int unsigned                          INPUTS  = 2     // The number of inbound streams
)
(
    // Reset and clock
    input  logic                                    reset,
    input  logic                                    clk,

    // Active inbound interface selection
    input  logic [$clog2(INPUTS) - 1 : 0]           select,

    // Inbound streams
    input  logic [INPUTS - 1 : 0][WIDTH - 1 : 0]    i_dat,
    input  logic [INPUTS - 1 : 0]                   i_val,
    output logic [INPUTS - 1 : 0]                   i_rdy,

    // Outbound stream
    output logic [WIDTH - 1 : 0]                    o_dat,
    output logic                                    o_val,
    input  logic                                    o_rdy
);
    // Signals declaration
    logic [INPUTS - 1 : 0]                          select_pos;


    // One-hot code of a selected stream
    always_comb begin
        select_pos = {INPUTS{1'b0}};
        select_pos[select] = 1'b1;
    end


    // Readiness of inbound streams
    assign i_rdy = select_pos & {INPUTS{o_rdy}};


    // Outbound stream signals logic
    assign o_dat = i_dat[select];
    assign o_val = i_val[select];


endmodule // ds_mux