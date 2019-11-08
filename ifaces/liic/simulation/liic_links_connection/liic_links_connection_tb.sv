`timescale  1ns / 1ps

module liic_links_connection_tb ();


    // Constant declaration
    localparam int unsigned         ST_WIDTH        = 8;    // Stream interfaces width
    localparam int unsigned         CS_WIDTH        = 8;    // Control/status interface width
    localparam int unsigned         MM_MAXPENDRD    = 8;    // The maximum number of pending read transactions for MemoryMapped slave interface
    localparam int unsigned         MM_BUSYTIMEOUT  = 128;  // The number of clock cycles during which 'busy' from a MemoryMapped slave can be asserted
    localparam int unsigned         MM_RVALTIMEOUT  = 128;  // The number of clock cycles during which 'rval' from a MemoryMapped slave can miss
    localparam int unsigned         LL_RSTLENGTH    = 5;    // Duration of link layer reset in clock cycles
    localparam int unsigned         LL_RSTPERIOD    = 25;   // The period of cyclic link layer resetting in clock cycles
    localparam int unsigned         CLK_FREQUENCY   = 2000; // Clock frequency in Hz


    // Signals declaration
    logic                           rst;
    logic                           clk;
    //
    logic [3 : 0]                   dcs_addr;
    logic                           dcs_wreq;
    logic [CS_WIDTH - 1 : 0]        dcs_wdat;
    logic                           dcs_rreq;
    logic [CS_WIDTH - 1 : 0]        dcs_rdat;
    logic                           dcs_rval;
    logic                           dcs_busy;
    //
    logic [3 : 0]                   ucs_addr;
    logic                           ucs_wreq;
    logic [CS_WIDTH - 1 : 0]        ucs_wdat;
    logic                           ucs_rreq;
    logic [CS_WIDTH - 1 : 0]        ucs_rdat;
    logic                           ucs_rval;
    logic                           ucs_busy;
    //
    logic [ST_WIDTH - 1 : 0]        dmm_addr;
    logic                           dmm_wreq;
    logic [ST_WIDTH - 1 : 0]        dmm_wdat;
    logic                           dmm_rreq;
    logic [ST_WIDTH - 1 : 0]        dmm_rdat;
    logic                           dmm_rval;
    logic                           dmm_busy;
    //
    logic [ST_WIDTH - 1 : 0]        umm_addr;
    logic                           umm_wreq;
    logic [ST_WIDTH - 1 : 0]        umm_wdat;
    logic                           umm_rreq;
    logic [ST_WIDTH - 1 : 0]        umm_rdat;
    logic                           umm_rval;
    logic                           umm_busy;
    //
    logic [ST_WIDTH - 1 : 0]        dst_i_dat;
    logic                           dst_i_val;
    logic                           dst_i_eop;
    logic                           dst_i_rdy;
    //
    logic [ST_WIDTH - 1 : 0]        dst_o_dat;
    logic                           dst_o_val;
    logic                           dst_o_eop;
    logic                           dst_o_rdy;
    //
    logic [ST_WIDTH - 1 : 0]        ust_i_dat;
    logic                           ust_i_val;
    logic                           ust_i_eop;
    logic                           ust_i_rdy;
    //
    logic [ST_WIDTH - 1 : 0]        ust_o_dat;
    logic                           ust_o_val;
    logic                           ust_o_eop;
    logic                           ust_o_rdy;
    //
    logic                           ll_d_linkup;
    logic                           ll_u_linkup;
    //
    logic                           ll_d_reset;
    logic                           ll_u_reset;
    //
    logic [ST_WIDTH - 1 : 0]        llhp_d2u_dat;
    logic                           llhp_d2u_val;
    logic                           llhp_d2u_sop;
    logic                           llhp_d2u_eop;
    logic                           llhp_d2u_rdy;
    //
    logic [ST_WIDTH - 1 : 0]        llhp_u2d_dat;
    logic                           llhp_u2d_val;
    logic                           llhp_u2d_sop;
    logic                           llhp_u2d_eop;
    logic                           llhp_u2d_rdy;
    //
    logic [ST_WIDTH - 1 : 0]        lllp_d2u_dat;
    logic                           lllp_d2u_val;
    logic                           lllp_d2u_sop;
    logic                           lllp_d2u_eop;
    logic                           lllp_d2u_rdy;
    //
    logic [ST_WIDTH - 1 : 0]        lllp_u2d_dat;
    logic                           lllp_u2d_val;
    logic                           lllp_u2d_sop;
    logic                           lllp_u2d_eop;
    logic                           lllp_u2d_rdy;


    // Reset generation
    initial begin
        rst = #0ps     1'b1;
        rst = #10001ps 1'b0;
    end


    // Clock generation
    initial clk = 1'b1;
    always  clk = #5ns ~clk;


    // Misc initialization
    initial begin
        dcs_addr    = 0;
        dcs_wreq    = 0;
        dcs_wdat    = 0;
        dcs_rreq    = 0;
        //
        ucs_addr    = 0;
        ucs_wreq    = 0;
        ucs_wdat    = 0;
        ucs_rreq    = 0;
        //
        dmm_addr    = 0;
        dmm_wreq    = 0;
        dmm_wdat    = 0;
        dmm_rreq    = 0;
        //
        umm_rdat    = 0;
        umm_rval    = 0;
        umm_busy    = 0;
        //
        dst_i_dat   = 0;
        dst_i_val   = 0;
        dst_i_eop   = 0;
        //
        dst_o_rdy   = 1;
        //
        ust_i_dat   = 0;
        ust_i_val   = 0;
        ust_i_eop   = 0;
        //
        ust_o_rdy   = 1;
        //
        ll_d_linkup = 0;
        ll_u_linkup = 0;
    end


    // Link independent interconnect: downstream link
    liic_dn_link
    #(
        .ST_WIDTH       (ST_WIDTH),         // Stream interfaces width
        .CS_WIDTH       (CS_WIDTH),         // Control/status interface width
        .MM_MAXPENDRD   (MM_MAXPENDRD),     // The maximum number of pending read transactions for MemoryMapped slave interface
        .MM_BUSYTIMEOUT (MM_BUSYTIMEOUT),   // The number of clock cycles during which 'busy' from a MemoryMapped slave can be asserted
        .MM_RVALTIMEOUT (MM_RVALTIMEOUT),   // The number of clock cycles during which 'rval' from a MemoryMapped slave can miss
        .LL_RSTLENGTH   (LL_RSTLENGTH),     // Duration of link layer reset in clock cycles
        .LL_RSTPERIOD   (LL_RSTPERIOD),     // The period of cyclic link layer resetting in clock cycles
        .CLK_FREQUENCY  (CLK_FREQUENCY)     // Clock frequency in Hz
    )
    the_liic_dn_link
    (
        // Reset and clock
        .rst            (rst),              // i
        .clk            (clk),              // i

        // Control/status interface
        .cs_addr        (dcs_addr),         // i  [3 : 0]
        .cs_wreq        (dcs_wreq),         // i
        .cs_wdat        (dcs_wdat),         // i  [CS_WIDTH - 1 : 0]
        .cs_rreq        (dcs_rreq),         // i
        .cs_rdat        (dcs_rdat),         // o  [CS_WIDTH - 1 : 0]
        .cs_rval        (dcs_rval),         // o
        .cs_busy        (dcs_busy),         // o

        // MemoryMapped slave interface
        .mm_addr        (dmm_addr),         // i  [ST_WIDTH - 1 : 0]
        .mm_wreq        (dmm_wreq),         // i
        .mm_wdat        (dmm_wdat),         // i  [ST_WIDTH - 1 : 0]
        .mm_rreq        (dmm_rreq),         // i
        .mm_rdat        (dmm_rdat),         // o  [ST_WIDTH - 1 : 0]
        .mm_rval        (dmm_rval),         // o
        .mm_busy        (dmm_busy),         // o

        // Inbound packet stream
        .st_i_dat       (dst_i_dat),        // i  [ST_WIDTH - 1 : 0]
        .st_i_val       (dst_i_val),        // i
        .st_i_eop       (dst_i_eop),        // i
        .st_i_rdy       (dst_i_rdy),        // o

        // Outbound packet stream
        .st_o_dat       (dst_o_dat),        // o  [ST_WIDTH - 1 : 0]
        .st_o_val       (dst_o_val),        // o
        .st_o_eop       (dst_o_eop),        // o
        .st_o_rdy       (dst_o_rdy),        // i

        // Link layer linkup indicator
        .ll_linkup      (ll_d_linkup),      // i

        // Link layer reset output
        .ll_reset       (ll_d_reset),       // o

        // Link layer high priority inbound stream
        .llhp_i_dat     (llhp_u2d_dat),     // i  [ST_WIDTH - 1 : 0]
        .llhp_i_val     (llhp_u2d_val),     // i
        .llhp_i_sop     (llhp_u2d_sop),     // i
        .llhp_i_eop     (llhp_u2d_eop),     // i
        .llhp_i_rdy     (llhp_u2d_rdy),     // o

        // Link layer high priority outbound stream
        .llhp_o_dat     (llhp_d2u_dat),     // o  [ST_WIDTH - 1 : 0]
        .llhp_o_val     (llhp_d2u_val),     // o
        .llhp_o_sop     (llhp_d2u_sop),     // o
        .llhp_o_eop     (llhp_d2u_eop),     // o
        .llhp_o_rdy     (llhp_d2u_rdy),     // i

        // Link layer low priority inbound stream
        .lllp_i_dat     (lllp_u2d_dat),     // i  [ST_WIDTH - 1 : 0]
        .lllp_i_val     (lllp_u2d_val),     // i
        .lllp_i_sop     (lllp_u2d_sop),     // i
        .lllp_i_eop     (lllp_u2d_eop),     // i
        .lllp_i_rdy     (lllp_u2d_rdy),     // o

        // Link layer low priority outbound stream
        .lllp_o_dat     (lllp_d2u_dat),     // o  [ST_WIDTH - 1 : 0]
        .lllp_o_val     (lllp_d2u_val),     // o
        .lllp_o_sop     (lllp_d2u_sop),     // o
        .lllp_o_eop     (lllp_d2u_eop),     // o
        .lllp_o_rdy     (lllp_d2u_rdy)      // i
    ); // the_liic_dn_link


    // Link independent interconnect: upstream link
    liic_up_link
    #(
        .ST_WIDTH       (ST_WIDTH),         // Stream interfaces width
        .CS_WIDTH       (CS_WIDTH),         // Control/status interface width
        .MM_MAXPENDRD   (MM_MAXPENDRD),     // The maximum number of pending read transactions for MemoryMapped slave interface
        .MM_BUSYTIMEOUT (MM_BUSYTIMEOUT),   // The number of clock cycles during which 'busy' from a MemoryMapped slave can be asserted
        .MM_RVALTIMEOUT (MM_RVALTIMEOUT),   // The number of clock cycles during which 'rval' from a MemoryMapped slave can miss
        .LL_RSTLENGTH   (LL_RSTLENGTH),     // Duration of link layer reset in clock cycles
        .LL_RSTPERIOD   (LL_RSTPERIOD),     // The period of cyclic link layer resetting in clock cycles
        .CLK_FREQUENCY  (CLK_FREQUENCY)     // Clock frequency in Hz
    )
    the_liic_up_link
    (
        // Reset and clock
        .rst            (rst),              // i
        .clk            (clk),              // i

        // Control/status interface
        .cs_addr        (ucs_addr),         // i  [3 : 0]
        .cs_wreq        (ucs_wreq),         // i
        .cs_wdat        (ucs_wdat),         // i  [CS_WIDTH - 1 : 0]
        .cs_rreq        (ucs_rreq),         // i
        .cs_rdat        (ucs_rdat),         // o  [CS_WIDTH - 1 : 0]
        .cs_rval        (ucs_rval),         // o
        .cs_busy        (ucs_busy),         // o

        // MemoryMapped master interface
        .mm_addr        (umm_addr),         // o  [ST_WIDTH - 1 : 0]
        .mm_wreq        (umm_wreq),         // o
        .mm_wdat        (umm_wdat),         // o  [ST_WIDTH - 1 : 0]
        .mm_rreq        (umm_rreq),         // o
        .mm_rdat        (umm_rdat),         // i  [ST_WIDTH - 1 : 0]
        .mm_rval        (umm_rval),         // i
        .mm_busy        (umm_busy),         // i

        // Inbound packet stream
        .st_i_dat       (ust_i_dat),        // i  [ST_WIDTH - 1 : 0]
        .st_i_val       (ust_i_val),        // i
        .st_i_eop       (ust_i_eop),        // i
        .st_i_rdy       (ust_i_rdy),        // o

        // Outbound packet stream
        .st_o_dat       (ust_o_dat),        // o  [ST_WIDTH - 1 : 0]
        .st_o_val       (ust_o_val),        // o
        .st_o_eop       (ust_o_eop),        // o
        .st_o_rdy       (ust_o_rdy),        // i

        // Link layer linkup indicator
        .ll_linkup      (ll_u_linkup),      // i

        // Link layer reset output
        .ll_reset       (ll_u_reset),       // o

        // Link layer high priority inbound stream
        .llhp_i_dat     (llhp_d2u_dat),     // i  [ST_WIDTH - 1 : 0]
        .llhp_i_val     (llhp_d2u_val),     // i
        .llhp_i_sop     (llhp_d2u_sop),     // i
        .llhp_i_eop     (llhp_d2u_eop),     // i
        .llhp_i_rdy     (llhp_d2u_rdy),     // o

        // Link layer high priority outbound stream
        .llhp_o_dat     (llhp_u2d_dat),     // o  [ST_WIDTH - 1 : 0]
        .llhp_o_val     (llhp_u2d_val),     // o
        .llhp_o_sop     (llhp_u2d_sop),     // o
        .llhp_o_eop     (llhp_u2d_eop),     // o
        .llhp_o_rdy     (llhp_u2d_rdy),     // i

        // Link layer low priority inbound stream
        .lllp_i_dat     (lllp_d2u_dat),     // i  [ST_WIDTH - 1 : 0]
        .lllp_i_val     (lllp_d2u_val),     // i
        .lllp_i_sop     (lllp_d2u_sop),     // i
        .lllp_i_eop     (lllp_d2u_eop),     // i
        .lllp_i_rdy     (lllp_d2u_rdy),     // o

        // Link layer low priority outbound stream
        .lllp_o_dat     (lllp_u2d_dat),     // o  [ST_WIDTH - 1 : 0]
        .lllp_o_val     (lllp_u2d_val),     // o
        .lllp_o_sop     (lllp_u2d_sop),     // o
        .lllp_o_eop     (lllp_u2d_eop),     // o
        .lllp_o_rdy     (lllp_u2d_rdy)      // i
    ); // the_liic_up_link


endmodule: liic_links_connection_tb