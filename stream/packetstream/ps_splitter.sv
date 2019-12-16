/*
    // PacketStream interface splitter
    ps_splitter
    #(
        .WIDTH          (), // Stream width
        .SOURCES        ()  // The number of outbound streams
    )
    the_ps_splitter
    (
        // Reset and clock
        .reset          (), // i
        .clk            (), // i

        // Outbound streams activation
        .active         (), // i  [SOURCES - 1 : 0]

        // Inbound stream
        .i_dat          (), // i  [WIDTH - 1 : 0]
        .i_val          (), // i
        .i_eop          (), // i
        .i_rdy          (), // o

        // Outbound streams
        .o_dat          (), // o  [SOURCES - 1 : 0][WIDTH - 1 : 0]
        .o_val          (), // o  [SOURCES - 1 : 0]
        .o_eop          (), // o  [SOURCES - 1 : 0]
        .o_rdy          ()  // i  [SOURCES - 1 : 0]
    ); // the_ps_splitter
*/


module ps_splitter
#(
    parameter int unsigned                          WIDTH   = 8,    // Stream width
    parameter int unsigned                          SOURCES = 4     // The number of outbound streams
)
(
    // Reset and clock
    input  logic                                    reset,
    input  logic                                    clk,

    // Outbound streams activation
    input  logic [SOURCES - 1 : 0]                  active,

    // Inbound stream
    input  logic [WIDTH - 1 : 0]                    i_dat,
    input  logic                                    i_val,
    input  logic                                    i_eop,
    output logic                                    i_rdy,

    // Outbound streams
    output logic [SOURCES - 1 : 0][WIDTH - 1 : 0]   o_dat,
    output logic [SOURCES - 1 : 0]                  o_val,
    output logic [SOURCES - 1 : 0]                  o_eop,
    input  logic [SOURCES - 1 : 0]                  o_rdy
);
    // Signals declaration
    logic [SOURCES - 1 : 0]                         int_active;
    logic [WIDTH - 1 : 0]                           int_dat;
    logic                                           int_val;
    logic                                           int_eop;
    logic                                           int_rdy;


    // PacketStream parameter keeper
    ps_param_keeper
    #(
        .DWIDTH         (WIDTH),        // Stream width
        .PWIDTH         (SOURCES)       // Parameters bus width
    )
    active_keeper
    (
        // Reset and clock
        .reset          (reset),        // i
        .clk            (clk),          // i

        // Input packet's parameters bus
        .desired_param  (active),       // i  [PWIDTH - 1 : 0]

        // Output packet's parameters bus
        // (it is held during the whole packet)
        .agreed_param   (int_active),   // o  [PWIDTH - 1 : 0]

        // Inbound stream
        .i_dat          (i_dat),        // i  [DWIDTH - 1 : 0]
        .i_val          (i_val),        // i
        .i_eop          (i_eop),        // i
        .i_rdy          (i_rdy),        // o

        // Outbound stream
        .o_dat          (int_dat),      // o  [DWIDTH - 1 : 0]
        .o_val          (int_val),      // o
        .o_eop          (int_eop),      // o
        .o_rdy          (int_rdy)       // i
    ); // active_keeper


    // Outbound streams generation
    generate
        genvar i, j;
        logic [SOURCES - 1 : 0][SOURCES - 1 : 0] mask;
        for (i = 0; i < SOURCES; i++) begin: splitter_gen
            for (j = 0; j < SOURCES; j++) begin: mask_gen
                assign mask[i][j] = (i == j);
            end
            assign o_dat[i] = int_dat;
            assign o_val[i] = int_val & int_active[i] & (&(o_rdy | mask[i] | ~int_active));
            assign o_eop[i] = int_eop;
        end
    endgenerate
    assign int_rdy = &(o_rdy | ~int_active);

endmodule // ps_splitter