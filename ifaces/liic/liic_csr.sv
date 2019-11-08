/*
    // Control/status registers module
    liic_csr
    #(
        .WIDTH              (), // Control/status interface width
        .CLKFREQ            ()  // Clock frequency in Hz
    )
    the_liic_csr
    (
        // Reset and clock
        .rst                (), // i
        .clk                (), // i

        // Signals under monitoring
        .ll_linkup          (), // i
        .ll_hpi_rcvd        (), // i
        .ll_hpi_lost        (), // i
        .ll_hpo_sent        (), // i
        .ll_hpo_lost        (), // i
        .ll_lpi_rcvd        (), // i
        .ll_lpi_lost        (), // i
        .ll_lpo_sent        (), // i
        .ll_lpo_lost        (), // i
        .mm_busy_timeout    (), // i
        .mm_rval_timeout    (), // i
        .mm_rval_is_odd     (), // i

        // Control/status interface
        .cs_addr            (), // i  [3 : 0]
        .cs_wreq            (), // i
        .cs_wdat            (), // i  [WIDTH - 1 : 0]
        .cs_rreq            (), // i
        .cs_rdat            (), // o  [WIDTH - 1 : 0]
        .cs_rval            (), // o
        .cs_busy            ()  // o
    ); // the_liic_csr
*/


module liic_csr
#(
    parameter int unsigned          WIDTH   = 8,    // Control/status interface width
    parameter int unsigned          CLKFREQ = 2000  // Clock frequency in Hz
)
(
    // Reset and clock
    input  logic                    rst,
    input  logic                    clk,

    // Signals under monitoring
    input  logic                    ll_linkup,
    input  logic                    ll_hpi_rcvd,
    input  logic                    ll_hpi_lost,
    input  logic                    ll_hpo_sent,
    input  logic                    ll_hpo_lost,
    input  logic                    ll_lpi_rcvd,
    input  logic                    ll_lpi_lost,
    input  logic                    ll_lpo_sent,
    input  logic                    ll_lpo_lost,
    input  logic                    mm_busy_timeout,
    input  logic                    mm_rval_timeout,
    input  logic                    mm_rval_is_odd,

    // Control/status interface
    input  logic [3 : 0]            cs_addr,
    input  logic                    cs_wreq,
    input  logic [WIDTH - 1 : 0]    cs_wdat,
    input  logic                    cs_rreq,
    output logic [WIDTH - 1 : 0]    cs_rdat,
    output logic                    cs_rval,
    output logic                    cs_busy
);
    // Constants declaration
    localparam logic [3 : 0]    RESERVED_REG        = 4'h0;
    localparam logic [3 : 0]    LINK_STATUS_REG     = 4'h1;
    localparam logic [3 : 0]    LINK_ESTABLISH_CNT  = 4'h2;
    localparam logic [3 : 0]    LINK_DURATION_CNT   = 4'h3;
    localparam logic [3 : 0]    HPI_RCVD_CNT        = 4'h4;
    localparam logic [3 : 0]    HPI_LOST_CNT        = 4'h5;
    localparam logic [3 : 0]    HPO_SENT_CNT        = 4'h6;
    localparam logic [3 : 0]    HPO_LOST_CNT        = 4'h7;
    localparam logic [3 : 0]    LPI_RCVD_CNT        = 4'h8;
    localparam logic [3 : 0]    LPI_LOST_CNT        = 4'h9;
    localparam logic [3 : 0]    LPO_SENT_CNT        = 4'hA;
    localparam logic [3 : 0]    LPO_LOST_CNT        = 4'hB;
    localparam logic [3 : 0]    MM_STATUS_REG       = 4'hC;
    localparam logic [3 : 0]    MM_BUSYTIMEOUT_CNT  = 4'hD;
    localparam logic [3 : 0]    MM_RVALTIMEOUT_CNT  = 4'hE;
    localparam logic [3 : 0]    MM_ODDRVAL_CNT      = 4'hF;
    //
    localparam int unsigned     LINKUP_BIT          = 0;
    localparam int unsigned     MM_BUSYTIMEOUT_BIT  = 0;
    localparam int unsigned     MM_RVALTIMEOUT_BIT  = 1;
    localparam int unsigned     MM_ODDRVAL_BIT      = 2;
    //
    localparam int unsigned     MSCYCLES = CLKFREQ > 1000 ? CLKFREQ / 1000 : 1;


    // Signals declaration
    logic                   linkup_reg;
    logic                   linkup_rise;
    logic                   ms_strobe;
    //
    logic [WIDTH - 1 : 0]   link_establish_cnt;
    logic [WIDTH - 1 : 0]   link_duration_cnt;
    logic [WIDTH - 1 : 0]   hpi_rcvd_cnt;
    logic [WIDTH - 1 : 0]   hpi_lost_cnt;
    logic [WIDTH - 1 : 0]   hpo_sent_cnt;
    logic [WIDTH - 1 : 0]   hpo_lost_cnt;
    logic [WIDTH - 1 : 0]   lpi_rcvd_cnt;
    logic [WIDTH - 1 : 0]   lpi_lost_cnt;
    logic [WIDTH - 1 : 0]   lpo_sent_cnt;
    logic [WIDTH - 1 : 0]   lpo_lost_cnt;
    logic [WIDTH - 1 : 0]   mm_busytimeout_cnt;
    logic [WIDTH - 1 : 0]   mm_rvaltimeout_cnt;
    logic [WIDTH - 1 : 0]   mm_oddrval_cnt;
    //
    logic                   mm_busytimeout_reg;
    logic                   mm_rvaltimeout_reg;
    logic                   mm_oddrval_reg;
    //
    logic [WIDTH - 1 : 0]   cs_rdat_reg;
    logic                   cs_rval_reg;


    // Linkup delay register
    always @(posedge rst, posedge clk) begin
        if (rst)
            linkup_reg <= 1'b0;
        else
            linkup_reg <= ll_linkup;
    end


    // Linkup rising indicator
    assign linkup_rise = ll_linkup & ~linkup_reg;


    // Control/status interface is always ready
    assign cs_busy = 1'b0;


    // Millisecond strobe
    generate

        // if clock frequency is greater than 1kHz
        if (MSCYCLES > 1) begin: ms_strob_gen
            logic [$clog2(MSCYCLES) - 1 : 0] ms_cnt;
            logic ms_reg;

            // The counter of clock cycles within 1 millisecond
            always @(posedge rst, posedge clk) begin
                if (rst)
                    ms_cnt <= '0;
                else if (MSCYCLES != 2**$clog2(MSCYCLES))
                    if (ms_cnt == (MSCYCLES - 1))
                        ms_cnt <= '0;
                    else
                        ms_cnt <= ms_cnt + 1'b1;
                else
                    ms_cnt <= ms_cnt + 1'b1;
            end

            // One millisecond strobe register
            always @(posedge rst, posedge clk) begin
                if (rst)
                    ms_reg <= 1'b0;
                else
                    ms_reg <= (ms_cnt == (MSCYCLES - 2));
            end
            assign ms_strobe = ms_reg;

        end // ms_strob_gen

        // if clock frequency is equal or less than 1kHz
        else begin: no_ms_strobe
            assign ms_strobe = 1'b1;
        end

    endgenerate


    // The link establishment counter
    always @(posedge rst, posedge clk) begin
        if (rst)
            link_establish_cnt <= '0;
        else if (cs_wreq & (cs_addr == LINK_ESTABLISH_CNT))
            link_establish_cnt <= cs_wdat;
        else
            link_establish_cnt <= link_establish_cnt + linkup_rise;
    end


    // The link duration counter
    always @(posedge rst, posedge clk) begin
        if (rst)
            link_duration_cnt <= '0;
        else if (ll_linkup)
            link_duration_cnt <= link_duration_cnt + ms_strobe;
        else
            link_duration_cnt <= '0;
    end


    // The counter of received words of inbound high priority interface
    always @(posedge rst, posedge clk) begin
        if (rst)
            hpi_rcvd_cnt <= '0;
        else if (cs_wreq & (cs_addr == HPI_RCVD_CNT))
            hpi_rcvd_cnt <= cs_wdat;
        else
            hpi_rcvd_cnt <= hpi_rcvd_cnt + ll_hpi_rcvd;
    end


    // The counter of lost words of inbound high priority interface
    always @(posedge rst, posedge clk) begin
        if (rst)
            hpi_lost_cnt <= '0;
        else if (cs_wreq & (cs_addr == HPI_LOST_CNT))
            hpi_lost_cnt <= cs_wdat;
        else
            hpi_lost_cnt <= hpi_lost_cnt + ll_hpi_lost;
    end


    // The counter of sent words of outbound high priority interface
    always @(posedge rst, posedge clk) begin
        if (rst)
            hpo_sent_cnt <= '0;
        else if (cs_wreq & (cs_addr == HPO_SENT_CNT))
            hpo_sent_cnt <= cs_wdat;
        else
            hpo_sent_cnt <= hpo_sent_cnt + ll_hpo_sent;
    end


    // The counter of lost words of outbound high priority interface
    always @(posedge rst, posedge clk) begin
        if (rst)
            hpo_lost_cnt <= '0;
        else if (cs_wreq & (cs_addr == HPO_LOST_CNT))
            hpo_lost_cnt <= cs_wdat;
        else
            hpo_lost_cnt <= hpo_lost_cnt + ll_hpo_lost;
    end


    // The counter of received words of inbound low priority interface
    always @(posedge rst, posedge clk) begin
        if (rst)
            lpi_rcvd_cnt <= '0;
        else if (cs_wreq & (cs_addr == LPI_RCVD_CNT))
            lpi_rcvd_cnt <= cs_wdat;
        else
            lpi_rcvd_cnt <= lpi_rcvd_cnt + ll_lpi_rcvd;
    end


    // The counter of lost words of inbound low priority interface
    always @(posedge rst, posedge clk) begin
        if (rst)
            lpi_lost_cnt <= '0;
        else if (cs_wreq & (cs_addr == LPI_LOST_CNT))
            lpi_lost_cnt <= cs_wdat;
        else
            lpi_lost_cnt <= lpi_lost_cnt + ll_lpi_lost;
    end


    // The counter of sent words of outbound low priority interface
    always @(posedge rst, posedge clk) begin
        if (rst)
            lpo_sent_cnt <= '0;
        else if (cs_wreq & (cs_addr == LPO_SENT_CNT))
            lpo_sent_cnt <= cs_wdat;
        else
            lpo_sent_cnt <= lpo_sent_cnt + ll_lpo_sent;
    end


    // The counter of lost words of outbound low priority interface
    always @(posedge rst, posedge clk) begin
        if (rst)
            lpo_lost_cnt <= '0;
        else if (cs_wreq & (cs_addr == LPO_LOST_CNT))
            lpo_lost_cnt <= cs_wdat;
        else
            lpo_lost_cnt <= lpo_lost_cnt + ll_lpo_lost;
    end


    // The counter of "busy" timeout events
    always @(posedge rst, posedge clk) begin
        if (rst)
            mm_busytimeout_cnt <= '0;
        else if (cs_wreq & (cs_addr == MM_BUSYTIMEOUT_CNT))
            mm_busytimeout_cnt <= cs_wdat;
        else
            mm_busytimeout_cnt <= mm_busytimeout_cnt + mm_busy_timeout;
    end


    // The counter of "rval" timeout events
    always @(posedge rst, posedge clk) begin
        if (rst)
            mm_rvaltimeout_cnt <= '0;
        else if (cs_wreq & (cs_addr == MM_RVALTIMEOUT_CNT))
            mm_rvaltimeout_cnt <= cs_wdat;
        else
            mm_rvaltimeout_cnt <= mm_rvaltimeout_cnt + mm_rval_timeout;
    end


    // The counter of odd "rval"
    always @(posedge rst, posedge clk) begin
        if (rst)
            mm_oddrval_cnt <= '0;
        else if (cs_wreq & (cs_addr == MM_ODDRVAL_CNT))
            mm_oddrval_cnt <= cs_wdat;
        else
            mm_oddrval_cnt <= mm_oddrval_cnt + mm_rval_is_odd;
    end


    // The "busy" timeout flag register
    always @(posedge rst, posedge clk) begin
        if (rst)
            mm_busytimeout_reg <= 1'b0;
        else if (cs_wreq & (cs_addr == MM_STATUS_REG))
            mm_busytimeout_reg <= cs_wdat[MM_BUSYTIMEOUT_BIT];
        else
            mm_busytimeout_reg <= mm_busytimeout_reg | mm_busy_timeout;
    end


    // The "rval" timeout flag register
    always @(posedge rst, posedge clk) begin
        if (rst)
            mm_rvaltimeout_reg <= 1'b0;
        else if (cs_wreq & (cs_addr == MM_STATUS_REG))
            mm_rvaltimeout_reg <= cs_wdat[MM_RVALTIMEOUT_BIT];
        else
            mm_rvaltimeout_reg <= mm_rvaltimeout_reg | mm_rval_timeout;
    end


    // The odd "rval" flag register
    always @(posedge rst, posedge clk) begin
        if (rst)
            mm_oddrval_reg <= 1'b0;
        else if (cs_wreq & (cs_addr == MM_STATUS_REG))
            mm_oddrval_reg <= cs_wdat[MM_ODDRVAL_BIT];
        else
            mm_oddrval_reg <= mm_oddrval_reg | mm_rval_is_odd;
    end


    // Control/status interface read data register
    always @(posedge rst, posedge clk) begin
        if (rst)
            cs_rdat_reg <= '0;
        else case (cs_addr)
            LINK_STATUS_REG:    cs_rdat_reg <= '{
                                    LINKUP_BIT: ll_linkup,
                                    default:    1'b0
                                };
            LINK_ESTABLISH_CNT: cs_rdat_reg <= link_establish_cnt;
            LINK_DURATION_CNT:  cs_rdat_reg <= link_duration_cnt;
            HPI_RCVD_CNT:       cs_rdat_reg <= hpi_rcvd_cnt;
            HPI_LOST_CNT:       cs_rdat_reg <= hpi_lost_cnt;
            HPO_SENT_CNT:       cs_rdat_reg <= hpo_sent_cnt;
            HPO_LOST_CNT:       cs_rdat_reg <= hpo_lost_cnt;
            LPI_RCVD_CNT:       cs_rdat_reg <= lpi_rcvd_cnt;
            LPI_LOST_CNT:       cs_rdat_reg <= lpi_lost_cnt;
            LPO_SENT_CNT:       cs_rdat_reg <= lpo_sent_cnt;
            LPO_LOST_CNT:       cs_rdat_reg <= lpo_lost_cnt;
            MM_STATUS_REG:      cs_rdat_reg <= '{
                                    MM_BUSYTIMEOUT_BIT: mm_busytimeout_reg,
                                    MM_RVALTIMEOUT_BIT: mm_rvaltimeout_reg,
                                    MM_ODDRVAL_BIT:     mm_oddrval_reg,
                                    default:            1'b0
                                };
            MM_BUSYTIMEOUT_CNT: cs_rdat_reg <= mm_busytimeout_cnt;
            MM_RVALTIMEOUT_CNT: cs_rdat_reg <= mm_rvaltimeout_cnt;
            MM_ODDRVAL_CNT:     cs_rdat_reg <= mm_oddrval_cnt;
            default:            cs_rdat_reg <= '0;
        endcase
    end
    assign cs_rdat = cs_rdat_reg;


    // Control/status interface read valid register
    always @(posedge rst, posedge clk) begin
        if (rst)
            cs_rval_reg <= 1'b0;
        else
            cs_rval_reg <= cs_rreq;
    end
    assign cs_rval = cs_rval_reg;


endmodule: liic_csr