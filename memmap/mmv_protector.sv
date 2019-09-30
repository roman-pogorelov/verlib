/*
    // The protector against an unsafe MemoryMapped slave
    mmv_protector
    #(
        .AWIDTH         (), // Address bus width
        .DWIDTH         (), // Data bus width
        .MAXPENDRD      (), // The maximum number of pending read transactions
        .BUSYTIMEOUT    (), // The number of clock cycles during which 'busy' from a slave can be asserted
        .RVALTIMEOUT    ()  // The number of clock cycles during which 'rval' from a slave is expected
    )
    the_mmv_protector
    (
        // Reset and clock
        .rst            (), // i
        .clk            (), // i

        // MemoryMapped slave interface
        .s_addr         (), // i  [AWIDTH - 1 : 0]
        .s_wreq         (), // i
        .s_wdat         (), // i  [DWIDTH - 1 : 0]
        .s_rreq         (), // i
        .s_rdat         (), // o  [DWIDTH - 1 : 0]
        .s_rval         (), // o
        .s_busy         (), // o

        // MemoryMapped master interface
        .m_addr         (), // o  [AWIDTH - 1 : 0]
        .m_wreq         (), // o
        .m_wdat         (), // o  [DWIDTH - 1 : 0]
        .m_rreq         (), // o
        .m_rdat         (), // i  [DWIDTH - 1 : 0]
        .m_rval         (), // i
        .m_busy         (), // i

        // Status signals
        .busy_timeout   (), // o
        .rval_timeout   (), // o
        .rval_is_odd    ()  // o
    ); // the_mmv_protector
*/


module mmv_protector
#(
    parameter int unsigned          AWIDTH      = 8,    // Address bus width
    parameter int unsigned          DWIDTH      = 8,    // Data bus width
    parameter int unsigned          MAXPENDRD   = 8,    // The maximum number of pending read transactions
    parameter int unsigned          BUSYTIMEOUT = 8,    // The number of clock cycles during which 'busy' from a slave can be asserted
    parameter int unsigned          RVALTIMEOUT = 8     // The number of clock cycles during which 'rval' from a slave is expected
)
(
    // Reset and clock
    input  logic                    rst,
    input  logic                    clk,

    // MemoryMapped slave interface
    input  logic [AWIDTH - 1 : 0]   s_addr,
    input  logic                    s_wreq,
    input  logic [DWIDTH - 1 : 0]   s_wdat,
    input  logic                    s_rreq,
    output logic [DWIDTH - 1 : 0]   s_rdat,
    output logic                    s_rval,
    output logic                    s_busy,

    // MemoryMapped master interface
    output logic [AWIDTH - 1 : 0]   m_addr,
    output logic                    m_wreq,
    output logic [DWIDTH - 1 : 0]   m_wdat,
    output logic                    m_rreq,
    input  logic [DWIDTH - 1 : 0]   m_rdat,
    input  logic                    m_rval,
    input  logic                    m_busy,

    // Status signals
    output logic                    busy_timeout,
    output logic                    rval_timeout,
    output logic                    rval_is_odd
);
    // Constant declaration
    localparam int unsigned             BUSYCW   = $clog2(BUSYTIMEOUT);     // Width of the 'busy' timeout counter
    localparam int unsigned             RVALCW   = $clog2(RVALTIMEOUT);     // Width of the 'rval' timeout counter
    localparam logic [DWIDTH - 1 : 0]   ERRRDVAL = {DWIDTH{1'b1}};          // Value that will be read if fault occurs during reading
    localparam                          RAMTYPE  = "AUTO";                  // RAM type of FIFO


    // Signals declaration
    logic [BUSYCW - 1 : 0]  busy_timeout_cnt;
    logic                   busy_interrupt_reg;
    logic                   busy_timeout_reg;
    logic [RVALCW - 1 : 0]  timestamp_cnt;
    logic [RVALCW - 1 : 0]  rreq_timestamp;
    logic                   rreq_fifo_empty;
    logic                   rreq_fifo_full;
    logic                   forced_rval;
    logic [DWIDTH - 1 : 0]  rdat_pipe_reg;
    logic                   rval_pipe_reg;
    logic                   rval_timeout_reg;
    logic                   rval_is_odd_reg;


    // The 'busy' timeout counter
    always @(posedge rst, posedge clk) begin
        if (rst)
            busy_timeout_cnt <= '0;
        else if ((m_wreq | m_rreq) & m_busy)
            if (BUSYTIMEOUT != 2**BUSYCW)
                if (busy_timeout_cnt == (BUSYTIMEOUT - 1))
                    busy_timeout_cnt <= '0;
                else
                    busy_timeout_cnt <= busy_timeout_cnt + 1'b1;
            else
                busy_timeout_cnt <= busy_timeout_cnt + 1'b1;
        else
            busy_timeout_cnt <= '0;
    end


    // The 'busy' interrupt register
    initial busy_interrupt_reg = 1'b1;
    always @(posedge rst, posedge clk) begin
        if (rst)
            busy_interrupt_reg <= 1'b1;
        else
            busy_interrupt_reg <= ~((m_wreq | m_rreq) & m_busy & (busy_timeout_cnt == (BUSYTIMEOUT - 1)));
    end


    // The 'busy' timeout register
    always @(posedge rst, posedge clk) begin
        if (rst)
            busy_timeout_reg <= 1'b0;
        else
            busy_timeout_reg <= (m_wreq | m_rreq) & m_busy & ~busy_interrupt_reg;
    end


    // The time stamp counter
    always @(posedge rst, posedge clk) begin
        if (rst)
            timestamp_cnt <= '0;
        else if (RVALTIMEOUT != 2**RVALCW)
            if (timestamp_cnt == (RVALTIMEOUT - 1))
                timestamp_cnt <= '0;
            else
                timestamp_cnt <= timestamp_cnt + 1'b1;
        else
            timestamp_cnt <= timestamp_cnt + 1'b1;
    end


    // Altera single clock (synchronous) FIFO
    scfifo
    #(
        .add_ram_output_register    ("OFF"),
        .lpm_hint                   ({"RAM_BLOCK_TYPE=", RAMTYPE}),
        .lpm_numwords               (MAXPENDRD),
        .lpm_showahead              ("ON"),
        .lpm_type                   ("scfifo"),
        .lpm_width                  (RVALCW),
        .lpm_widthu                 ($clog2(MAXPENDRD)),
        .overflow_checking          ("ON"),
        .underflow_checking         ("ON"),
        .use_eab                    ("ON")
    )
    rreq_fifo
    (
        .aclr                       (rst),
        .clock                      (clk),
        .data                       (timestamp_cnt),
        .rdreq                      (forced_rval | m_rval),
        .wrreq                      (s_rreq & ~s_busy),
        .empty                      (rreq_fifo_empty),
        .full                       (rreq_fifo_full),
        .q                          (rreq_timestamp),
        .almost_empty               (  ),
        .almost_full                (  ),
        .sclr                       (  ),
        .usedw                      (  )
    ); // rreq_fifo


    // Forced 'rval' logic
    assign forced_rval = ~rreq_fifo_empty & (rreq_timestamp == timestamp_cnt);


    // The 'rdat' pipeline register
    always @(posedge rst, posedge clk) begin
        if (rst)
            rdat_pipe_reg <= '0;
        else
            rdat_pipe_reg <= (forced_rval & ~m_rval) ? ERRRDVAL : m_rdat;
    end


    // The 'rval' pipeline register
    always @(posedge rst, posedge clk) begin
        if (rst)
            rval_pipe_reg <= 1'b0;
        else
            rval_pipe_reg <= (forced_rval | m_rval) & ~rreq_fifo_empty;
    end


    // The 'rval' timeout register
    always @(posedge rst, posedge clk) begin
        if (rst)
            rval_timeout_reg <= 1'b0;
        else
            rval_timeout_reg <= forced_rval & ~m_rval;
    end


    // The register to indicate that odd 'rval' has been detected
    always @(posedge rst, posedge clk) begin
        if (rst)
            rval_is_odd_reg <= 1'b0;
        else
            rval_is_odd_reg <= m_rval & rreq_fifo_empty;
    end


    // MemoryMapped interfaces signals logic
    assign m_addr = s_addr;
    assign m_wreq = s_wreq & ~rreq_fifo_full;
    assign m_wdat = s_wdat;
    assign m_rreq = s_rreq & ~rreq_fifo_full;
    assign s_rdat = rdat_pipe_reg;
    assign s_rval = rval_pipe_reg;
    assign s_busy = (m_busy & busy_interrupt_reg) | rreq_fifo_full;


    // Status signals logic
    assign busy_timeout = busy_timeout_reg;
    assign rval_timeout = rval_timeout_reg;
    assign rval_is_odd = rval_is_odd_reg;


endmodule: mmv_protector