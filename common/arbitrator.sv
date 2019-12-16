/*
    // Single resource arbiter
    arbitrator
    #(
        .REQS           (), // The number of requesters (REQS > 1)
        .SCHEME         ()  // Arbitration scheme ("RR" - round-robin, "FP" - fixed priorities)
    )
    the_arbitrator
    (
        // Reset and clock
        .reset          (), // i
        .clk            (), // i

        // Requests vector
        .req            (), // i  [REQS - 1 : 0]

        // Ready to process a request
        .rdy            (), // i

        // Grants vector
        .gnt            (), // o  [REQS - 1 : 0]

        // Index of port having the grant
        .num            ()  // o  [$clog2(REQS) - 1 : 0]
    ); // the_arbitrator
*/


module arbitrator
#(
    parameter int unsigned              REQS    = 4,    // The number of requesters (REQS > 1)
    parameter string                    SCHEME  = "FP"  // Arbitration scheme ("RR" - round-robin, "FP" - fixed priorities)
)
(
    // Reset and clock
    input  logic                        reset,
    input  logic                        clk,

    // Requests vector
    input  logic [REQS - 1 : 0]         req,

    // Ready to process a request
    input  logic                        rdy,

    // Grants vector
    output logic [REQS - 1 : 0]         gnt,

    // Index of port having the grant
    output logic [$clog2(REQS) - 1 : 0] num
);
    // Signals declaration
    logic [REQS - 1 : 0]                top_priority;
    logic [REQS - 1 : 0]                top_priority_reg;
    logic [2*REQS - 1 : 0]              gnt_double;
    logic [REQS - 1 : 0]                act_gnt;
    logic [REQS - 1 : 0]                pnd_gnt_reg;
    logic                               pnd_req_reg;


    // Arbitration scheme selection
    generate
        // Round-robin scheme
        if (SCHEME == "RR")
            assign top_priority = top_priority_reg;
        // Fixed priorities
        else
            assign top_priority = {{(REQS - 1){1'b0}}, 1'b1};
    endgenerate


    // Top priority register
    always @(posedge reset, posedge clk)
        if (reset)
            top_priority_reg <= {{(REQS - 1){1'b0}}, 1'b1};
        else if (|req & rdy)
            top_priority_reg <= {gnt[REQS - 2 : 0], gnt[REQS - 1]};
        else
            top_priority_reg <= top_priority_reg;


    // Double grant register
    assign gnt_double = {req, req} & ({~req, ~req} + {{REQS{1'b0}}, top_priority});


    // Actual grant
    assign act_gnt = gnt_double[2*REQS - 1 : REQS] | gnt_double[REQS - 1 : 0];


    // Pending grant register
    always @(posedge reset, posedge clk)
        if (reset)
            pnd_gnt_reg <= '0;
        else if (~pnd_req_reg & |req & ~rdy)
            pnd_gnt_reg <= act_gnt;
        else
            pnd_gnt_reg <= pnd_gnt_reg;


    // Pending request flag register
    always @(posedge reset, posedge clk)
        if (reset)
            pnd_req_reg <= '0;
        else if (pnd_req_reg)
            pnd_req_reg <= ~rdy;
        else
            pnd_req_reg <= |req & ~rdy;


    // Grants vector
    assign gnt = pnd_req_reg ? pnd_gnt_reg : act_gnt;


    // One hot to binary converter
    onehot2binary
    #(
        .WIDTH      (REQS)  // One hot bus width
    )
    gnt2num_conv
    (
        .onehot     (gnt),  // i  [WIDTH - 1 : 0]
        .binary     (num)   // o  [$clog2(WIDTH) - 1 : 0]
    ); // gnt2num_conv


endmodule // arbitrator