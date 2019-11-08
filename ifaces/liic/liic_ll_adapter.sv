/*
    // The adapter to connect the user layer and the link layer
    // protecting against a loss of the linkup
    liic_ll_adapter
    #(
        .WIDTH      ()  // Stream width
    )
    the_liic_ll_adapter
    (
        // Reset and clock
        .rst        (), // i
        .clk        (), // i

        // Link layer linkup indicator
        .ll_linkup  (), // o

        // Status signals
        .ll_i_lost  (), // o
        .ll_o_lost  (), // o

        // Link layer inbound stream
        .ll_i_dat   (), // i  [WIDTH - 1 : 0]
        .ll_i_val   (), // i
        .ll_i_sop   (), // i
        .ll_i_eop   (), // i
        .ll_i_rdy   (), // o

        // Link layer outbound stream
        .ll_o_dat   (), // o  [WIDTH - 1 : 0]
        .ll_o_val   (), // o
        .ll_o_sop   (), // o
        .ll_o_eop   (), // o
        .ll_o_rdy   (), // i

        // User layer inbound stream
        .usr_i_dat  (), // i  [WIDTH - 1 : 0]
        .usr_i_val  (), // i
        .usr_i_eop  (), // i
        .usr_i_rdy  (), // o

        // User layer outbound stream
        .usr_o_dat  (), // o  [WIDTH - 1 : 0]
        .usr_o_val  (), // o
        .usr_o_eop  (), // o
        .usr_o_rdy  ()  // i
    ); // the_liic_ll_adapter
*/


module liic_ll_adapter
#(
    parameter int unsigned          WIDTH = 8   // Stream width
)
(
    // Reset and clock
    input  logic                    rst,
    input  logic                    clk,

    // Link layer linkup indicator
    input  logic                    ll_linkup,

    // Status signals
    output logic                    ll_i_lost,
    output logic                    ll_o_lost,

    // Link layer inbound stream
    input  logic [WIDTH - 1 : 0]    ll_i_dat,
    input  logic                    ll_i_val,
    input  logic                    ll_i_sop,
    input  logic                    ll_i_eop,
    output logic                    ll_i_rdy,

    // Link layer outbound stream
    output logic [WIDTH - 1 : 0]    ll_o_dat,
    output logic                    ll_o_val,
    output logic                    ll_o_sop,
    output logic                    ll_o_eop,
    input  logic                    ll_o_rdy,

    // User layer inbound stream
    input  logic [WIDTH - 1 : 0]    usr_i_dat,
    input  logic                    usr_i_val,
    input  logic                    usr_i_eop,
    output logic                    usr_i_rdy,

    // User layer outbound stream
    output logic [WIDTH - 1 : 0]    usr_o_dat,
    output logic                    usr_o_val,
    output logic                    usr_o_eop,
    input  logic                    usr_o_rdy
);
    // Signals declaration
    logic                   ll_linkup_fall;
    //
    logic [WIDTH - 1 : 0]   lli_cut_dat;
    logic                   lli_cut_val;
    logic                   lli_cut_sop;
    logic                   lli_cut_eop;
    logic                   lli_cut_rdy;
    //
    logic [WIDTH - 1 : 0]   lli_abort_dat;
    logic                   lli_abort_val;
    logic                   lli_abort_eop;
    logic                   lli_abort_rdy;
    //
    logic [WIDTH - 1 : 0]   llo_buf_dat;
    logic                   llo_buf_val;
    logic                   llo_buf_eop;
    logic                   llo_buf_rdy;
    //
    logic [WIDTH - 1 : 0]   llo_pss_dat;
    logic                   llo_pss_val;
    logic                   llo_pss_sop;
    logic                   llo_pss_eop;
    logic                   llo_pss_rdy;


    // Signal edge detector
    edgedetector
    #(
        .INIT           (1'b0)  // Initial register state (1'b0 | 1'b1)
    )
    linkup_edgedetector
    (
        // Reset and clock
        .reset          (rst),
        .clk            (clk),

        // Input signal
        .i_pulse        (ll_linkup),

        // Edge indicators
        .o_rise         (  ),
        .o_fall         (ll_linkup_fall),
        .o_either       (  )
    ); // linkup_edgedetector


    // PacketStream w/ SOP cutter
    pss_cutter
    #(
        .WIDTH  (WIDTH)         // Stream width
    )
    lli_cutter
    (
        // Reset and clock
        .rst    (rst),          // i
        .clk    (clk),          // i

        // Control input to cut the stream
        .cut    (~ll_linkup),   // i

        // Losing indicator
        .lost   (ll_i_lost),    // o

        // Inbound packet stream
        .i_dat  (ll_i_dat),     // i  [WIDTH - 1 : 0]
        .i_val  (ll_i_val),     // i
        .i_sop  (ll_i_sop),     // i
        .i_eop  (ll_i_eop),     // i
        .i_rdy  (ll_i_rdy),     // o

        // Outbound packet stream
        .o_dat  (lli_cut_dat),  // o  [WIDTH - 1 : 0]
        .o_val  (lli_cut_val),  // o
        .o_sop  (lli_cut_sop),  // o
        .o_eop  (lli_cut_eop),  // o
        .o_rdy  (lli_cut_rdy)   // i
    ); // lli_cutter


    // Forced PacketStream interrupter
    ps_aborter
    #(
        .WIDTH      (WIDTH)             // Stream width
    )
    lli_aborter
    (
        // Reset and clock
        .reset      (rst),              // i
        .clk        (clk),              // i

        // Abort request
        .abort      (ll_linkup_fall),   // i

        // Inbound stream
        .i_dat      (lli_cut_dat),      // i  [WIDTH - 1 : 0]
        .i_val      (lli_cut_val),      // i
        .i_eop      (lli_cut_eop),      // i
        .i_rdy      (lli_cut_rdy),      // o

        // Outbound stream
        .o_dat      (lli_abort_dat),    // o  [WIDTH - 1 : 0]
        .o_val      (lli_abort_val),    // o
        .o_eop      (lli_abort_eop),    // o
        .o_rdy      (lli_abort_rdy)     // i
    ); // lli_aborter


    // Register based PacketStream buffer with no combinational links
    // between stream interfaces
    ps_twinreg_buffer
    #(
        .WIDTH      (WIDTH)             // Stream width
    )
    lli_buffer
    (
        // Reset and clock
        .reset      (rst),              // i
        .clk        (clk),              // i

        // Inbound stream
        .i_dat      (lli_abort_dat),    // i  [WIDTH - 1 : 0]
        .i_val      (lli_abort_val),    // i
        .i_eop      (lli_abort_eop),    // i
        .i_rdy      (lli_abort_rdy),    // o

        // Outbound stream
        .o_dat      (usr_o_dat),        // o  [WIDTH - 1 : 0]
        .o_val      (usr_o_val),        // o
        .o_eop      (usr_o_eop),        // o
        .o_rdy      (usr_o_rdy)         // i
    ); // lli_buffer


    // Register based PacketStream buffer with no combinational links
    // between stream interfaces
    ps_twinreg_buffer
    #(
        .WIDTH      (WIDTH)         // Stream width
    )
    llo_buffer
    (
        // Reset and clock
        .reset      (rst),          // i
        .clk        (clk),          // i

        // Inbound stream
        .i_dat      (usr_i_dat),    // i  [WIDTH - 1 : 0]
        .i_val      (usr_i_val),    // i
        .i_eop      (usr_i_eop),    // i
        .i_rdy      (usr_i_rdy),    // o

        // Outbound stream
        .o_dat      (llo_buf_dat),  // o  [WIDTH - 1 : 0]
        .o_val      (llo_buf_val),  // o
        .o_eop      (llo_buf_eop),  // o
        .o_rdy      (llo_buf_rdy)   // i
    ); // llo_buffer


    // PacketStream w/o SOP to PacketStream w/ SOP converter
    ps_to_pss
    #(
        .WIDTH      (WIDTH)         // Stream width
    )
    llo_ps_to_pss
    (
        // Reset and clock
        .rst        (rst),          // i
        .clk        (clk),          // i

        // Inbound stream
        .i_dat      (llo_buf_dat),  // i  [WIDTH - 1 : 0]
        .i_val      (llo_buf_val),  // i
        .i_eop      (llo_buf_eop),  // i
        .i_rdy      (llo_buf_rdy),  // o

        // Outbound stream
        .o_dat      (llo_pss_dat),  // o  [WIDTH - 1 : 0]
        .o_val      (llo_pss_val),  // o
        .o_sop      (llo_pss_sop),  // o
        .o_eop      (llo_pss_eop),  // o
        .o_rdy      (llo_pss_rdy)   // i
    ); // llo_ps_to_pss


    // PacketStream w/ SOP cutter
    pss_cutter
    #(
        .WIDTH  (WIDTH)         // Stream width
    )
    llo_cutter
    (
        // Reset and clock
        .rst    (rst),          // i
        .clk    (clk),          // i

        // Control input to cut the stream
        .cut    (~ll_linkup),   // i

        // Losing indicator
        .lost   (ll_o_lost),    // o

        // Inbound packet stream
        .i_dat  (llo_pss_dat),  // i  [WIDTH - 1 : 0]
        .i_val  (llo_pss_val),  // i
        .i_sop  (llo_pss_sop),  // i
        .i_eop  (llo_pss_eop),  // i
        .i_rdy  (llo_pss_rdy),  // o

        // Outbound packet stream
        .o_dat  (ll_o_dat),     // o  [WIDTH - 1 : 0]
        .o_val  (ll_o_val),     // o
        .o_sop  (ll_o_sop),     // o
        .o_eop  (ll_o_eop),     // o
        .o_rdy  (ll_o_rdy)      // i
    ); // llo_cutter


endmodule: liic_ll_adapter