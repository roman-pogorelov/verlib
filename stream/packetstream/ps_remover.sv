/*
    // PacketStream packet remover
    ps_remover
    #(
        .WIDTH          ()  // Stream width
    )
    the_ps_remover
    (
        // Reset and clock
        .reset          (), // i
        .clk            (), // i

        // Removing control
        .remove         (), // i

        // Status signals
        .wremoved       (), // o
        .premoved       (), // o

        // Inbound stream
        .i_dat          (), // i  [WIDTH - 1 : 0]
        .i_val          (), // i
        .i_eop          (), // i
        .i_rdy          (), // o

        // Outbound stream
        .o_dat          (), // o  [WIDTH - 1 : 0]
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ps_remover
*/


module ps_remover
#(
    parameter int unsigned          WIDTH   = 8     // Stream width
)
(
    // Reset and clock
    input  logic                    reset,
    input  logic                    clk,

    // Removing control
    input  logic                    remove,

    // Status signals
    output logic                    wremoved,
    output logic                    premoved,

    // Inbound stream
    input  logic [WIDTH - 1 : 0]    i_dat,
    input  logic                    i_val,
    input  logic                    i_eop,
    output logic                    i_rdy,

    // Outbound stream
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    // Signals declaration
    logic                           removing;
    //
    logic [WIDTH - 1 : 0]           keep_dat;
    logic                           keep_val;
    logic                           keep_eop;
    logic                           keep_rdy;


    // PacketStream parameter keeper
    ps_param_keeper
    #(
        .DWIDTH         (WIDTH),    // Stream width
        .PWIDTH         (1)         // Parameters bus width
    )
    remove_request_keeper
    (
        // Reset and clock
        .reset          (reset),    // i
        .clk            (clk),      // i

        // Input packet's parameters bus
        .desired_param  (remove),   // i  [PWIDTH - 1 : 0]

        // Output packet's parameters bus
        // (it is held during the whole packet)
        .agreed_param   (removing), // o  [PWIDTH - 1 : 0]

        // Inbound stream
        .i_dat          (i_dat),    // i  [DWIDTH - 1 : 0]
        .i_val          (i_val),    // i
        .i_eop          (i_eop),    // i
        .i_rdy          (i_rdy),    // o

        // Outbound stream
        .o_dat          (keep_dat), // o  [DWIDTH - 1 : 0]
        .o_val          (keep_val), // o
        .o_eop          (keep_eop), // o
        .o_rdy          (keep_rdy)  // i
    ); // remove_request_keeper


    // Removing logic
    assign o_dat = keep_dat;
    assign o_eop = keep_eop & ~removing;
    assign o_val = keep_val & ~removing;
    assign keep_rdy = o_rdy | removing;


    // Status signals
    assign wremoved = removing & keep_val;
    assign premoved = wremoved & keep_eop;


endmodule // ps_remover