/*
    // The module to encode transactions of MemoryMapped interface with
    // variable latency to packets of PacketStream interface
    mmv_to_ps_enc
    #(
        .WIDTH      ()  // Address and data width
    )
    the_mmv_to_ps_enc
    (
        // Reset and clock
        .rst        (), // i
        .clk        (), // i

        // MemoryMapped slave interface
        .s_addr     (), // i  [WIDTH - 1 : 0]
        .s_wreq     (), // i
        .s_wdat     (), // i  [WIDTH - 1 : 0]
        .s_rreq     (), // i
        .s_rdat     (), // o  [WIDTH - 1 : 0]
        .s_rval     (), // o
        .s_busy     (), // o

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
    ); // the_mmv_to_ps_enc
*/


module mmv_to_ps_enc
#(
    parameter int unsigned          WIDTH = 8   // Address and data width
)
(
    // Reset and clock
    input  logic                    rst,
    input  logic                    clk,

    // MemoryMapped slave interface
    input  logic [WIDTH - 1 : 0]    s_addr,
    input  logic                    s_wreq,
    input  logic [WIDTH - 1 : 0]    s_wdat,
    input  logic                    s_rreq,
    output logic [WIDTH - 1 : 0]    s_rdat,
    output logic                    s_rval,
    output logic                    s_busy,

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
    logic [WIDTH - 1 : 0]   pack_header;
    //
    logic [WIDTH - 1 : 0]   enc_dat;
    logic                   enc_val;
    logic                   enc_eop;
    logic                   enc_rdy;
    //
    logic                   busy;
    logic                   busy_next;
    logic                   i_sop;
    logic                   res_val;


    // Outbound packet header
    assign pack_header = '{
        PACK_TYPE_BIT:  REQ_PACK_TYPE,
        WREQ_TYPE_BIT:  s_wreq,
        RREQ_TYPE_BIT:  s_rreq,
        default:        1'b0
    };


    // FSM encoding
    (* syn_encoding = "gray" *) enum int unsigned {
        st_wait_for_req,
        st_send_rd_addr,
        st_send_wr_addr,
        st_send_wr_data
    } cstate, nstate;


    // FSM current state register
    initial cstate = st_wait_for_req;
    always @(posedge rst, posedge clk) begin
        if (rst)
            cstate <= st_wait_for_req;
        else
            cstate <= nstate;
    end


    // FSM next state logic
    always_comb begin

        // Defaults
        enc_dat = pack_header;
        enc_val = s_wreq | s_rreq;
        enc_eop = 1'b0;
        busy_next = 1'b1;

        // Transitions logic
        case (cstate)

            st_wait_for_req: begin
                if (s_wreq & enc_rdy) begin
                    nstate = st_send_wr_addr;
                end
                else if (s_rreq & enc_rdy) begin
                    busy_next = 1'b0;
                    nstate = st_send_rd_addr;
                end
                else begin
                    nstate = st_wait_for_req;
                end
            end

            st_send_rd_addr: begin
                enc_dat = s_addr;
                enc_val = 1'b1;
                enc_eop = 1'b1;
                if (enc_rdy) begin
                    nstate = st_wait_for_req;
                end
                else begin
                    busy_next = 1'b0;
                    nstate = st_send_rd_addr;
                end
            end

            st_send_wr_addr: begin
                enc_dat = s_addr;
                enc_val = 1'b1;
                enc_eop = 1'b0;
                if (enc_rdy) begin
                    busy_next = 1'b0;
                    nstate = st_send_wr_data;
                end
                else begin
                    nstate = st_send_wr_addr;
                end
            end

            st_send_wr_data: begin
                enc_dat = s_wdat;
                enc_val = 1'b1;
                enc_eop = 1'b1;
                if (enc_rdy) begin
                    nstate = st_wait_for_req;
                end
                else begin
                    busy_next = 1'b0;
                    nstate = st_send_wr_data;
                end
            end

            default: begin
                nstate = st_wait_for_req;
            end

        endcase
    end


    // Busy register
    initial busy = 1'b1;
    always @(posedge rst, posedge clk) begin
        if (rst)
            busy <= 1'b1;
        else
            busy <= busy_next;
    end


    // MemoryMapped busy logic
    assign s_busy = busy | ~enc_rdy;


    // Register based PacketStream buffer with no combinational
    // links between inputs and outputs
    ps_twinreg_buffer
    #(
        .WIDTH      (WIDTH)     // Stream width
    )
    out_buffer
    (
        // Reset and clock
        .reset      (rst),      // i
        .clk        (clk),      // i

        // Inbound stream
        .i_dat      (enc_dat),  // i  [WIDTH - 1 : 0]
        .i_val      (enc_val),  // i
        .i_eop      (enc_eop),  // i
        .i_rdy      (enc_rdy),  // o

        // Outbound stream
        .o_dat      (o_dat),    // o  [WIDTH - 1 : 0]
        .o_val      (o_val),    // o
        .o_eop      (o_eop),    // o
        .o_rdy      (o_rdy)     // i
    ); // out_buffer


    // SOP flag register for inbound stream
    initial i_sop = 1'b1;
    always @(posedge rst, posedge clk) begin
        if (rst)
            i_sop <= 1'b1;
        else if (i_val & i_rdy)
            i_sop <= i_eop;
        else
            i_sop <= i_sop;
    end


    // Response valid packet register
    always @(posedge rst, posedge clk) begin
        if (rst)
            res_val <= 1'b0;
        else if (i_val & i_rdy & i_eop)
            res_val <= 1'b0;
        else if (i_val & i_rdy & i_sop)
            res_val <= (i_dat[PACK_TYPE_BIT] == RES_PACK_TYPE);
        else
            res_val <= res_val;
    end


    // Inbound stream interface is always ready to receive data
    assign i_rdy = 1'b1;


    // MemoryMapped read path logic
    assign s_rdat = i_dat;
    assign s_rval = i_val & res_val;


endmodule: mmv_to_ps_enc