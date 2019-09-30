/*
    // The module to decode transactions of MemoryMapped interface with
    // variable latency from packets of PacketStream interface
    mmv_from_ps_dec
    #(
        .WIDTH      (), // Width of address and data
        .MAXRD      ()  // The maximum number of pending read transactions
    )
    the_mmv_from_ps_dec
    (
        // Reset and clock
        .rst        (), // i
        .clk        (), // i

        // MemoryMapped master interface
        .m_addr     (), // o  [WIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [WIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [WIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     (), // i

        // Inbound stream
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o

        // Outbound stream
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_mmv_from_ps_dec
*/


module mmv_from_ps_dec
#(
    parameter int unsigned          WIDTH   = 8,    // Width of address and data
    parameter int unsigned          MAXRD   = 8     // The maximum number of pending read transactions
)
(
    // Reset and clock
    input  logic                    rst,
    input  logic                    clk,

    // MemoryMapped master interface
    output logic [WIDTH - 1 : 0]    m_addr,
    output logic                    m_wreq,
    output logic [WIDTH - 1 : 0]    m_wdat,
    output logic                    m_rreq,
    input  logic [WIDTH - 1 : 0]    m_rdat,
    input  logic                    m_rval,
    input  logic                    m_busy,

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
    // Constants declaration
    localparam int unsigned PACK_TYPE_BIT   = 0;    // "Packet type" bit position
    localparam int unsigned WREQ_TYPE_BIT   = 1;    // "Write request type" bit position
    localparam int unsigned RREQ_TYPE_BIT   = 2;    // "Read request type" bit position
    //
    localparam logic        REQ_PACK_TYPE   = 1'b0; // Request packet type
    localparam logic        RES_PACK_TYPE   = 1'b1; // Response packet type


    // Signals declaration
    logic [WIDTH - 1 : 0]               enc_dat;
    logic                               enc_val;
    logic                               enc_eop;
    logic                               enc_rdy;
    //
    logic [WIDTH - 1 : 0]               dec_addr;
    logic                               dec_wreq;
    logic [WIDTH - 1 : 0]               dec_wdat;
    logic                               dec_rreq;
    logic [WIDTH - 1 : 0]               dec_rdat;
    logic                               dec_rval;
    logic                               dec_busy;
    //
    logic [$clog2(MAXRD + 1) - 1 : 0]   rdlim_cnt;
    logic                               stop_reading;
    //
    logic                               wreq_reg;
    logic                               rreq_reg;
    logic                               request_set;
    //
    logic [WIDTH - 1 : 0]               address_reg;
    logic                               address_set;
    //
    logic [WIDTH - 1 : 0]               fifo_rddata;
    logic                               fifo_rdreq;
    logic                               fifo_empty;
    logic                               fifo_full;
    logic [$clog2(MAXRD) - 1 : 0]       fifo_usedw;
    logic [$clog2(MAXRD + 1) - 1 : 0]   fifo_used;
    //
    logic [WIDTH - 1 : 0]               resp_pack_header;
    logic                               resp_payload_reg;


    // FSM encoding
    (* syn_encoding = "gray" *) enum int unsigned {
        st_decode_header,
        st_latch_address,
        st_issue_request,
        st_wrong_packet,
        st_wait_for_fifo
    } cstate, nstate;


    // FSM current state register
    initial cstate = st_decode_header;
    always @(posedge rst, posedge clk) begin
        if (rst)
            cstate <= st_decode_header;
        else
            cstate <= nstate;
    end


    // FSM next state logic
    always_comb begin

        // Defaults
        request_set = 1'b0;
        address_set = 1'b0;
        dec_addr = wreq_reg ? address_reg : enc_dat;
        dec_wreq = 1'b0;
        dec_wdat = enc_dat;
        dec_rreq = 1'b0;
        enc_rdy = 1'b1;

        // Transitions logic
        case (cstate)

            st_decode_header: begin
                request_set = 1'b1;
                if (enc_val & ~enc_eop) begin
                    if (enc_dat[PACK_TYPE_BIT] == REQ_PACK_TYPE) begin
                        if (enc_dat[RREQ_TYPE_BIT] & stop_reading) begin
                            nstate = st_wait_for_fifo;
                        end
                        else if (enc_dat[WREQ_TYPE_BIT]) begin
                            nstate = st_latch_address;
                        end
                        else begin
                            nstate = st_issue_request;
                        end
                    end
                    else begin
                        nstate = st_wrong_packet;
                    end
                end
                else begin
                    nstate = st_decode_header;
                end
            end

            st_latch_address: begin
                address_set = 1'b1;
                if (enc_val) begin
                    if (enc_eop) begin
                        nstate = st_decode_header;
                    end
                    else begin
                        nstate = st_issue_request;
                    end
                end
                else begin
                    nstate = st_latch_address;
                end
            end

            st_issue_request: begin
                dec_wreq = wreq_reg & enc_val & enc_eop;
                dec_rreq = rreq_reg & enc_val & enc_eop;
                enc_rdy = enc_eop ? ~dec_busy : 1'b1;
                if (enc_val & enc_eop & ~dec_busy) begin
                    nstate = st_decode_header;
                end
                else if (enc_val & ~enc_eop) begin
                    nstate = st_wrong_packet;
                end
                else begin
                    nstate = st_issue_request;
                end
            end

            st_wrong_packet: begin
                if (enc_val & enc_eop) begin
                    nstate = st_decode_header;
                end
                else begin
                    nstate = st_wrong_packet;
                end
            end

            st_wait_for_fifo: begin
                enc_rdy = 1'b0;
                if (stop_reading) begin
                    nstate = st_wait_for_fifo;
                end
                else if (wreq_reg) begin
                    nstate = st_latch_address;
                end
                else begin
                    nstate = st_issue_request;
                end
            end

            default: begin
                nstate = st_decode_header;
            end

        endcase
    end


    // Register based PacketStream buffer with no combinational
    // links between inputs and outputs
    ps_twinreg_buffer
    #(
        .WIDTH      (WIDTH)     // Stream width
    )
    inp_ps_buffer
    (
        // Reset and clock
        .reset      (rst),      // i
        .clk        (clk),      // i

        // Inbound stream
        .i_dat      (i_dat),    // i  [WIDTH - 1 : 0]
        .i_val      (i_val),    // i
        .i_eop      (i_eop),    // i
        .i_rdy      (i_rdy),    // o

        // Outbound stream
        .o_dat      (enc_dat),  // o  [WIDTH - 1 : 0]
        .o_val      (enc_val),  // o
        .o_eop      (enc_eop),  // o
        .o_rdy      (enc_rdy)   // i
    ); // inp_ps_buffer


    // Register based MemoryMapped with variable latency buffer
    // with no combinational links between inputs and outputs
    mmv_reg_buffer
    #(
        .AWIDTH     (WIDTH),    // Address width
        .DWIDTH     (WIDTH)     // Data width
    )
    out_mmv_buffer
    (
        // Reset and clock
        .reset      (rst),      // i
        .clk        (clk),      // i

        // MemoryMapped slave interface
        .s_addr     (dec_addr), // i  [AWIDTH - 1 : 0]
        .s_wreq     (dec_wreq), // i
        .s_wdat     (dec_wdat), // i  [DWIDTH - 1 : 0]
        .s_rreq     (dec_rreq), // i
        .s_rdat     (dec_rdat), // o  [DWIDTH - 1 : 0]
        .s_rval     (dec_rval), // o
        .s_busy     (dec_busy), // o

        // MemoryMapped master interface
        .m_addr     (m_addr),   // o  [AWIDTH - 1 : 0]
        .m_wreq     (m_wreq),   // o
        .m_wdat     (m_wdat),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (m_rreq),   // o
        .m_rdat     (m_rdat),   // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),   // i
        .m_busy     (m_busy)    // i
    ); // out_mmv_buffer


    // Pending read transactions limit counter
    initial rdlim_cnt = MAXRD[$clog2(MAXRD + 1) - 1 : 0];
    always @(posedge rst, posedge clk) begin
        if (rst)
            rdlim_cnt <= MAXRD[$clog2(MAXRD + 1) - 1 : 0];
        else if ((dec_rreq & ~dec_busy) & ~dec_rval)
            rdlim_cnt <= rdlim_cnt - 1'b1;
        else if (~(dec_rreq & ~dec_busy) & dec_rval)
            rdlim_cnt <= rdlim_cnt + 1'b1;
        else
            rdlim_cnt <= rdlim_cnt;
    end


    // Stop reading logic
    assign stop_reading = $unsigned(fifo_used) >= $unsigned(rdlim_cnt);


    // The register to latch write request
    always @(posedge rst, posedge clk) begin
        if (rst)
            wreq_reg <= '0;
        else if (request_set)
            wreq_reg <= enc_dat[WREQ_TYPE_BIT];
        else
            wreq_reg <= wreq_reg;
    end

    // The register to latch read request
    always @(posedge rst, posedge clk) begin
        if (rst)
            rreq_reg <= '0;
        else if (request_set)
            rreq_reg <= enc_dat[RREQ_TYPE_BIT];
        else
            rreq_reg <= rreq_reg;
    end


    // The register to latch an address
    always @(posedge rst, posedge clk) begin
        if (rst)
            address_reg <= '0;
        else if (address_set)
            address_reg <= enc_dat;
        else
            address_reg <= address_reg;
    end


    // Altera single clock FIFO
    scfifo
    #(
        .add_ram_output_register    ("OFF"),
        .lpm_hint                   ("RAM_BLOCK_TYPE=AUTO"),
        .lpm_numwords               (MAXRD),
        .lpm_showahead              ("ON"),
        .lpm_type                   ("scfifo"),
        .lpm_width                  (WIDTH),
        .lpm_widthu                 ($clog2(MAXRD)),
        .overflow_checking          ("ON"),
        .underflow_checking         ("ON"),
        .use_eab                    ("ON")
    )
    responses_buffer
    (
        .aclr                       (rst),
        .clock                      (clk),
        .data                       (dec_rdat),
        .rdreq                      (fifo_rdreq),
        .wrreq                      (dec_rval),
        .empty                      (fifo_empty),
        .full                       (fifo_full),
        .q                          (fifo_rddata),
        .almost_empty               (  ),
        .almost_full                (  ),
        .sclr                       (  ),
        .usedw                      (fifo_usedw)
    ); // responses_buffer


    // The number of used items within FIFO
    assign fifo_used = (MAXRD == 2**$clog2(MAXRD)) ? {fifo_full, fifo_usedw} : fifo_usedw;


    // The register indicating payload of outbound packets
    always @(posedge rst, posedge clk) begin
        if (rst)
            resp_payload_reg <= 1'b0;
        else
            resp_payload_reg <= resp_payload_reg ^ (~fifo_empty & o_rdy);
    end


    // Response packet header
    assign resp_pack_header = '{
        PACK_TYPE_BIT:  RES_PACK_TYPE,
        default:        1'b0
    };


    // Outbound stream logic
    assign o_dat = resp_payload_reg ? fifo_rddata : resp_pack_header;
    assign o_val = ~fifo_empty;
    assign o_eop = resp_payload_reg;


    // FIFO read request logic
    assign fifo_rdreq = resp_payload_reg & o_rdy;


endmodule: mmv_from_ps_dec