/*
    // Link independent interconnect: upstream link
    liic_up_link
    #(
        .ST_WIDTH       (), // Stream interfaces width
        .CS_WIDTH       (), // Control/status interface width
        .MM_MAXPENDRD   (), // The maximum number of pending read transactions for MemoryMapped slave interface
        .MM_BUSYTIMEOUT (), // The number of clock cycles during which 'busy' from a MemoryMapped slave can be asserted
        .MM_RVALTIMEOUT (), // The number of clock cycles during which 'rval' from a MemoryMapped slave can miss
        .LL_RSTLENGTH   (), // Duration of link layer reset in clock cycles
        .LL_RSTPERIOD   (), // The period of cyclic link layer resetting in clock cycles
        .CLK_FREQUENCY  ()  // Clock frequency in Hz
    )
    the_liic_up_link
    (
        // Reset and clock
        .rst            (), // i
        .clk            (), // i

        // Control/status interface
        .cs_addr        (), // i  [3 : 0]
        .cs_wreq        (), // i
        .cs_wdat        (), // i  [CS_WIDTH - 1 : 0]
        .cs_rreq        (), // i
        .cs_rdat        (), // o  [CS_WIDTH - 1 : 0]
        .cs_rval        (), // o
        .cs_busy        (), // o

        // MemoryMapped master interface
        .mm_addr        (), // o  [ST_WIDTH - 1 : 0]
        .mm_wreq        (), // o
        .mm_wdat        (), // o  [ST_WIDTH - 1 : 0]
        .mm_rreq        (), // o
        .mm_rdat        (), // i  [ST_WIDTH - 1 : 0]
        .mm_rval        (), // i
        .mm_busy        (), // i

        // Inbound packet stream
        .st_i_dat       (), // i  [ST_WIDTH - 1 : 0]
        .st_i_val       (), // i
        .st_i_eop       (), // i
        .st_i_rdy       (), // o

        // Outbound packet stream
        .st_o_dat       (), // o  [ST_WIDTH - 1 : 0]
        .st_o_val       (), // o
        .st_o_eop       (), // o
        .st_o_rdy       (), // i

        // Link layer linkup indicator
        .ll_linkup      (), // i

        // Link layer reset output
        .ll_reset       (), // o

        // Link layer high priority inbound stream
        .llhp_i_dat     (), // i  [ST_WIDTH - 1 : 0]
        .llhp_i_val     (), // i
        .llhp_i_sop     (), // i
        .llhp_i_eop     (), // i
        .llhp_i_rdy     (), // o

        // Link layer high priority outbound stream
        .llhp_o_dat     (), // o  [ST_WIDTH - 1 : 0]
        .llhp_o_val     (), // o
        .llhp_o_sop     (), // o
        .llhp_o_eop     (), // o
        .llhp_o_rdy     (), // i

        // Link layer low priority inbound stream
        .lllp_i_dat     (), // i  [ST_WIDTH - 1 : 0]
        .lllp_i_val     (), // i
        .lllp_i_sop     (), // i
        .lllp_i_eop     (), // i
        .lllp_i_rdy     (), // o

        // Link layer low priority outbound stream
        .lllp_o_dat     (), // o  [ST_WIDTH - 1 : 0]
        .lllp_o_val     (), // o
        .lllp_o_sop     (), // o
        .lllp_o_eop     (), // o
        .lllp_o_rdy     ()  // i
    ); // the_liic_up_link
*/


module liic_up_link
#(
    parameter int unsigned          ST_WIDTH        = 8,    // Stream interfaces width
    parameter int unsigned          CS_WIDTH        = 8,    // Control/status interface width
    parameter int unsigned          MM_MAXPENDRD    = 8,    // The maximum number of pending read transactions for MemoryMapped slave interface
    parameter int unsigned          MM_BUSYTIMEOUT  = 128,  // The number of clock cycles during which 'busy' from a MemoryMapped slave can be asserted
    parameter int unsigned          MM_RVALTIMEOUT  = 128,  // The number of clock cycles during which 'rval' from a MemoryMapped slave can miss
    parameter int unsigned          LL_RSTLENGTH    = 4,    // Duration of link layer reset in clock cycles
    parameter int unsigned          LL_RSTPERIOD    = 128,  // The period of cyclic link layer resetting in clock cycles
    parameter int unsigned          CLK_FREQUENCY   = 100   // Clock frequency in Hz
)
(
    // Reset and clock
    input  logic                    rst,
    input  logic                    clk,

    // Control/status interface
    input  logic [3 : 0]            cs_addr,
    input  logic                    cs_wreq,
    input  logic [CS_WIDTH - 1 : 0] cs_wdat,
    input  logic                    cs_rreq,
    output logic [CS_WIDTH - 1 : 0] cs_rdat,
    output logic                    cs_rval,
    output logic                    cs_busy,

    // MemoryMapped master interface
    output logic [ST_WIDTH - 1 : 0] mm_addr,
    output logic                    mm_wreq,
    output logic [ST_WIDTH - 1 : 0] mm_wdat,
    output logic                    mm_rreq,
    input  logic [ST_WIDTH - 1 : 0] mm_rdat,
    input  logic                    mm_rval,
    input  logic                    mm_busy,

    // Inbound packet stream
    input  logic [ST_WIDTH - 1 : 0] st_i_dat,
    input  logic                    st_i_val,
    input  logic                    st_i_eop,
    output logic                    st_i_rdy,

    // Outbound packet stream
    output logic [ST_WIDTH - 1 : 0] st_o_dat,
    output logic                    st_o_val,
    output logic                    st_o_eop,
    input  logic                    st_o_rdy,

    // Link layer linkup indicator
    input  logic                    ll_linkup,

    // Link layer reset output
    output logic                    ll_reset,

    // Link layer high priority inbound stream
    input  logic [ST_WIDTH - 1 : 0] llhp_i_dat,
    input  logic                    llhp_i_val,
    input  logic                    llhp_i_sop,
    input  logic                    llhp_i_eop,
    output logic                    llhp_i_rdy,

    // Link layer high priority outbound stream
    output logic [ST_WIDTH - 1 : 0] llhp_o_dat,
    output logic                    llhp_o_val,
    output logic                    llhp_o_sop,
    output logic                    llhp_o_eop,
    input  logic                    llhp_o_rdy,

    // Link layer low priority inbound stream
    input  logic [ST_WIDTH - 1 : 0] lllp_i_dat,
    input  logic                    lllp_i_val,
    input  logic                    lllp_i_sop,
    input  logic                    lllp_i_eop,
    output logic                    lllp_i_rdy,

    // Link layer low priority outbound stream
    output logic [ST_WIDTH - 1 : 0] lllp_o_dat,
    output logic                    lllp_o_val,
    output logic                    lllp_o_sop,
    output logic                    lllp_o_eop,
    input  logic                    lllp_o_rdy
);
    // Signals declaration
    logic                           linkup;
    //
    logic [ST_WIDTH - 1 : 0]        from_dec_addr;
    logic                           from_dec_wreq;
    logic [ST_WIDTH - 1 : 0]        from_dec_wdat;
    logic                           from_dec_rreq;
    logic [ST_WIDTH - 1 : 0]        from_dec_rdat;
    logic                           from_dec_rval;
    logic                           from_dec_busy;
    //
    logic [ST_WIDTH - 1 : 0]        dec_i_dat;
    logic                           dec_i_val;
    logic                           dec_i_eop;
    logic                           dec_i_rdy;
    //
    logic [ST_WIDTH - 1 : 0]        dec_o_dat;
    logic                           dec_o_val;
    logic                           dec_o_eop;
    logic                           dec_o_rdy;
    //
    logic                           mm_busy_timeout;
    logic                           mm_rval_timeout;
    logic                           mm_rval_is_odd;
    //
    logic                           hpi_rcvd;
    logic                           hpi_lost;
    logic                           hpo_sent;
    logic                           hpo_lost;
    logic                           lpi_rcvd;
    logic                           lpi_lost;
    logic                           lpo_sent;
    logic                           lpo_lost;


    // FlipFlop synchronizer
    ff_synchronizer
    #(
        .WIDTH          (1),            // Synchronized bus width
        .EXTRA_STAGES   (1),            // The number of extra stages
        .RESET_VALUE    (1'b0)          // The sync stages default value
    )
    the_ff_synchronizer
    (
        // Reset and clock
        .reset          (rst),          // i
        .clk            (clk),          // i

        // Asynchronous input
        .async_data     (ll_linkup),    // i  [WIDTH - 1 : 0]

        // Synchronous output
        .sync_data      (linkup)        // o  [WIDTH - 1 : 0]
    ); // the_ff_synchronizer


    // Link layer reset generator
    liic_ll_resetter
    #(
        .LENGTH     (LL_RSTLENGTH),     // Duration of link layer reset in clock cycles
        .PERIOD     (LL_RSTPERIOD)      // The period of link layer reset repetition in clock cycles
    )
    the_liic_ll_resetter
    (
        // Reset and clock
        .rst        (rst),              // i
        .clk        (clk),              // i

        // Link layer linkup indicator
        .ll_linkup  (linkup),           // i

        // Link layer reset output
        .ll_reset   (ll_reset)          // o
    ); // the_liic_ll_resetter


    // The adapter to connect the user layer and the link layer
    // protecting against a loss of the linkup
    liic_ll_adapter
    #(
        .WIDTH      (ST_WIDTH)      // Stream width
    )
    hp_ll_adapter
    (
        // Reset and clock
        .rst        (rst),          // i
        .clk        (clk),          // i

        // Link layer linkup indicator
        .ll_linkup  (linkup),       // o

        // Status signals
        .ll_i_lost  (hpi_lost),     // o
        .ll_o_lost  (hpo_lost),     // o

        // Link layer inbound stream
        .ll_i_dat   (llhp_i_dat),   // i  [WIDTH - 1 : 0]
        .ll_i_val   (llhp_i_val),   // i
        .ll_i_sop   (llhp_i_sop),   // i
        .ll_i_eop   (llhp_i_eop),   // i
        .ll_i_rdy   (llhp_i_rdy),   // o

        // Link layer outbound stream
        .ll_o_dat   (llhp_o_dat),   // o  [WIDTH - 1 : 0]
        .ll_o_val   (llhp_o_val),   // o
        .ll_o_sop   (llhp_o_sop),   // o
        .ll_o_eop   (llhp_o_eop),   // o
        .ll_o_rdy   (llhp_o_rdy),   // i

        // User layer inbound stream
        .usr_i_dat  (dec_o_dat),    // i  [WIDTH - 1 : 0]
        .usr_i_val  (dec_o_val),    // i
        .usr_i_eop  (dec_o_eop),    // i
        .usr_i_rdy  (dec_o_rdy),    // o

        // User layer outbound stream
        .usr_o_dat  (dec_i_dat),    // o  [WIDTH - 1 : 0]
        .usr_o_val  (dec_i_val),    // o
        .usr_o_eop  (dec_i_eop),    // o
        .usr_o_rdy  (dec_i_rdy)     // i
    ); // hp_ll_adapter


    // The adapter to connect the user layer and the link layer
    // protecting against a loss of the linkup
    liic_ll_adapter
    #(
        .WIDTH      (ST_WIDTH)      // Stream width
    )
    lp_ll_adapter
    (
        // Reset and clock
        .rst        (rst),          // i
        .clk        (clk),          // i

        // Link layer linkup indicator
        .ll_linkup  (linkup),       // o

        // Status signals
        .ll_i_lost  (lpi_lost),     // o
        .ll_o_lost  (lpo_lost),     // o

        // Link layer inbound stream
        .ll_i_dat   (lllp_i_dat),   // i  [WIDTH - 1 : 0]
        .ll_i_val   (lllp_i_val),   // i
        .ll_i_sop   (lllp_i_sop),   // i
        .ll_i_eop   (lllp_i_eop),   // i
        .ll_i_rdy   (lllp_i_rdy),   // o

        // Link layer outbound stream
        .ll_o_dat   (lllp_o_dat),   // o  [WIDTH - 1 : 0]
        .ll_o_val   (lllp_o_val),   // o
        .ll_o_sop   (lllp_o_sop),   // o
        .ll_o_eop   (lllp_o_eop),   // o
        .ll_o_rdy   (lllp_o_rdy),   // i

        // User layer inbound stream
        .usr_i_dat  (st_i_dat),     // i  [WIDTH - 1 : 0]
        .usr_i_val  (st_i_val),     // i
        .usr_i_eop  (st_i_eop),     // i
        .usr_i_rdy  (st_i_rdy),     // o

        // User layer outbound stream
        .usr_o_dat  (st_o_dat),     // o  [WIDTH - 1 : 0]
        .usr_o_val  (st_o_val),     // o
        .usr_o_eop  (st_o_eop),     // o
        .usr_o_rdy  (st_o_rdy)      // i
    ); // lp_ll_adapter


    // Receiving and sending indicators
    assign hpi_rcvd = llhp_i_val & llhp_i_rdy;
    assign hpo_sent = llhp_o_val & llhp_o_rdy;
    assign lpi_rcvd = lllp_i_val & lllp_i_rdy;
    assign lpo_sent = lllp_o_val & lllp_o_rdy;


    // Control/status registers module
    liic_csr
    #(
        .WIDTH              (CS_WIDTH),         // Control/status interface width
        .CLKFREQ            (CLK_FREQUENCY)     // Clock frequency in Hz
    )
    the_liic_csr
    (
        // Reset and clock
        .rst                (rst),              // i
        .clk                (clk),              // i

        // Signals under monitoring
        .ll_linkup          (linkup),           // i
        .ll_hpi_rcvd        (hpi_rcvd),         // i
        .ll_hpi_lost        (hpi_lost),         // i
        .ll_hpo_sent        (hpo_sent),         // i
        .ll_hpo_lost        (hpo_lost),         // i
        .ll_lpi_rcvd        (lpi_rcvd),         // i
        .ll_lpi_lost        (lpi_lost),         // i
        .ll_lpo_sent        (lpo_sent),         // i
        .ll_lpo_lost        (lpo_lost),         // i
        .mm_busy_timeout    (mm_busy_timeout),  // i
        .mm_rval_timeout    (mm_rval_timeout),  // i
        .mm_rval_is_odd     (mm_rval_is_odd),   // i

        // Control/status interface
        .cs_addr            (cs_addr),          // i  [3 : 0]
        .cs_wreq            (cs_wreq),          // i
        .cs_wdat            (cs_wdat),          // i  [WIDTH - 1 : 0]
        .cs_rreq            (cs_rreq),          // i
        .cs_rdat            (cs_rdat),          // o  [WIDTH - 1 : 0]
        .cs_rval            (cs_rval),          // o
        .cs_busy            (cs_busy)           // o
    ); // the_liic_csr


    // The protector against an unsafe MemoryMapped slave
    mmv_protector
    #(
        .AWIDTH         (ST_WIDTH),         // Address bus width
        .DWIDTH         (ST_WIDTH),         // Data bus width
        .MAXPENDRD      (MM_MAXPENDRD),     // The maximum number of pending read transactions
        .BUSYTIMEOUT    (MM_BUSYTIMEOUT),   // The number of clock cycles during which 'busy' from a slave can be asserted
        .RVALTIMEOUT    (MM_RVALTIMEOUT)    // The number of clock cycles during which 'rval' from a slave is expected
    )
    the_mmv_protector
    (
        // Reset and clock
        .rst            (rst),              // i
        .clk            (clk),              // i

        // MemoryMapped slave interface
        .s_addr         (from_dec_addr),    // i  [AWIDTH - 1 : 0]
        .s_wreq         (from_dec_wreq),    // i
        .s_wdat         (from_dec_wdat),    // i  [DWIDTH - 1 : 0]
        .s_rreq         (from_dec_rreq),    // i
        .s_rdat         (from_dec_rdat),    // o  [DWIDTH - 1 : 0]
        .s_rval         (from_dec_rval),    // o
        .s_busy         (from_dec_busy),    // o

        // MemoryMapped master interface
        .m_addr         (mm_addr),          // o  [AWIDTH - 1 : 0]
        .m_wreq         (mm_wreq),          // o
        .m_wdat         (mm_wdat),          // o  [DWIDTH - 1 : 0]
        .m_rreq         (mm_rreq),          // o
        .m_rdat         (mm_rdat),          // i  [DWIDTH - 1 : 0]
        .m_rval         (mm_rval),          // i
        .m_busy         (mm_busy),          // i

        // Status signals
        .busy_timeout   (mm_busy_timeout),  // o
        .rval_timeout   (mm_rval_timeout),  // o
        .rval_is_odd    (mm_rval_is_odd)    // o
    ); // the_mmv_protector


    // The module to decode transactions of MemoryMapped interface with
    // variable latency from packets of PacketStream interface
    mmv_from_ps_dec
    #(
        .WIDTH      (ST_WIDTH),         // Width of address and data
        .MAXRD      (MM_MAXPENDRD)      // The maximum number of pending read transactions
    )
    the_mmv_from_ps_dec
    (
        // Reset and clock
        .rst        (rst),              // i
        .clk        (clk),              // i

        // MemoryMapped master interface
        .m_addr     (from_dec_addr),    // o  [WIDTH - 1 : 0]
        .m_wreq     (from_dec_wreq),    // o
        .m_wdat     (from_dec_wdat),    // o  [WIDTH - 1 : 0]
        .m_rreq     (from_dec_rreq),    // o
        .m_rdat     (from_dec_rdat),    // i  [WIDTH - 1 : 0]
        .m_rval     (from_dec_rval),    // i
        .m_busy     (from_dec_busy),    // i

        // Inbound stream
        .i_dat      (dec_i_dat),        // i  [WIDTH - 1 : 0]
        .i_val      (dec_i_val),        // i
        .i_eop      (dec_i_eop),        // i
        .i_rdy      (dec_i_rdy),        // o

        // Outbound stream
        .o_dat      (dec_o_dat),        // o  [WIDTH - 1 : 0]
        .o_val      (dec_o_val),        // o
        .o_eop      (dec_o_eop),        // o
        .o_rdy      (dec_o_rdy)         // i
    ); // the_mmv_from_ps_dec


endmodule: liic_up_link