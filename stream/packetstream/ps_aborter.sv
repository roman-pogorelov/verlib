/*
    // Forced PacketStream interrupter
    ps_aborter
    #(
        .WIDTH      ()  // Stream width
    )
    the_ps_aborter
    (
        // Reset and clock
        .reset      (), // i
        .clk        (), // i

        // Abort request
        .abort      (), // i

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
    ); // the_ps_aborter
*/


module ps_aborter
#(
    parameter int unsigned          WIDTH = 8   // Stream width
)
(
    // Reset and clock
    input  logic                    reset,
    input  logic                    clk,

    // Abort request
    input  logic                    abort,

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
    logic [WIDTH - 1 : 0]           buf_dat_reg;
    logic                           buf_eop_reg;
    logic                           buf_state_reg;
    logic                           abort_hold_reg;
    logic                           abort_request;


    // Data buffer register
    always @(posedge reset, posedge clk)
        if (reset)
            buf_dat_reg <= '0;
        else if (i_val & i_rdy)
            buf_dat_reg <= i_dat;
        else
            buf_dat_reg <= buf_dat_reg;


    // EOP buffer register
    always @(posedge reset, posedge clk)
        if (reset)
            buf_eop_reg <= '0;
        else if (i_val & i_rdy)
            buf_eop_reg <= i_eop;
        else
            buf_eop_reg <= buf_eop_reg;


    // The state register
    always @(posedge reset, posedge clk)
        if (reset)
            buf_state_reg <= '0;
        // buffer is busy
        else if (buf_state_reg)
            buf_state_reg <= ~((buf_eop_reg | abort_request) & ~i_val & o_rdy);
        // buffer is free
        else
            buf_state_reg <= i_val;


    // Abort request holding register
    always @(posedge reset, posedge clk)
        if (reset)
            abort_hold_reg <= '0;
        // already is held
        else if (abort_hold_reg)
            abort_hold_reg <= ~(~abort & o_rdy);
        // has not held yet
        else
            abort_hold_reg <= abort & buf_state_reg & ~o_rdy;


    // Extended abort request
    assign abort_request = abort | abort_hold_reg;


    // Outbound stream logic
    assign i_rdy = o_rdy | ~buf_state_reg;
    assign o_dat = buf_dat_reg;
    assign o_val = buf_state_reg & (i_val | buf_eop_reg | abort_request);
    assign o_eop = buf_state_reg & (buf_eop_reg | abort_request);


endmodule // ps_aborter