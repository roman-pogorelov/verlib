/*
    // PacketStream interface arbiter
    ps_arbitrator
    #(
        .WIDTH          (), // Stream width
        .SINKS          (), // The number of inbound streams
        .SCHEME         ()  // Arbitration scheme ("RR" - round-robin, "FP" - fixed priorities)
    )
    the_ps_arbitrator
    (
        // Reset and clock
        .reset          (), // i
        .clk            (), // i

        // Inbound streams
        .i_dat          (), // i  [SINKS - 1 : 0][WIDTH - 1 : 0]
        .i_val          (), // i  [SINKS - 1 : 0]
        .i_eop          (), // i  [SINKS - 1 : 0]
        .i_rdy          (), // o  [SINKS - 1 : 0]

        // Outbound stream
        .o_dat          (), // o  [WIDTH - 1 : 0]
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ps_arbitrator
*/


module ps_arbitrator
#(
    parameter int unsigned                          WIDTH   = 8,    // Stream width
    parameter int unsigned                          SINKS   = 2,    // The number of inbound streams
    parameter string                                SCHEME  = "RR"  // Arbitration scheme ("RR" - round-robin, "FP" - fixed priorities)
)
(
    // Reset and clock
    input  logic                                    reset,
    input  logic                                    clk,

    // Inbound streams
    input  logic [SINKS - 1 : 0][WIDTH - 1 : 0]     i_dat,
    input  logic [SINKS - 1 : 0]                    i_val,
    input  logic [SINKS - 1 : 0]                    i_eop,
    output logic [SINKS - 1 : 0]                    i_rdy,

    // Outbound stream
    output logic [WIDTH - 1 : 0]                    o_dat,
    output logic                                    o_val,
    output logic                                    o_eop,
    input  logic                                    o_rdy
);
    // Signals declaration
    logic [SINKS - 1 : 0]                           active_pos;
    logic [$clog2(SINKS) - 1 : 0]                   active_num;


    // Single resource arbiter
    arbitrator
    #(
        .REQS           (SINKS),            // The number of requesters (REQS > 1)
        .SCHEME         (SCHEME)            // Arbitration scheme ("RR" - round-robin, "FP" - fixed priorities)
    )
    the_arbitrator
    (
        // Reset and clock
        .reset          (reset),            // i
        .clk            (clk),              // i

        // Requests vector
        .req            (i_val),            // i  [REQS - 1 : 0]

        // Ready to process a request
        .rdy            (o_rdy & o_eop),    // i

        // Grants vector
        .gnt            (active_pos),       // o  [REQS - 1 : 0]

        // Index of port having the grant
        .num            (active_num)        // o  [$clog2(REQS) - 1 : 0]
    ); // the_arbitrator


    // Inbound streams multiplexing
    assign o_dat = i_dat[active_num];
    assign o_val = i_val[active_num];
    assign o_eop = i_eop[active_num];
    assign i_rdy = active_pos & {SINKS{o_rdy}};


endmodule // ps_arbitrator