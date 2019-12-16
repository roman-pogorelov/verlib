/*
    // PacketStream parameter keeper
    ps_param_keeper
    #(
        .DWIDTH         (), // Stream width
        .PWIDTH         ()  // Parameters bus width
    )
    the_ps_param_keeper
    (
        // Reset and clock
        .reset          (), // i
        .clk            (), // i

        // Input packet's parameters bus
        .desired_param  (), // i  [PWIDTH - 1 : 0]

        // Output packet's parameters bus
        // (it is held during the whole packet)
        .agreed_param   (), // o  [PWIDTH - 1 : 0]

        // Inbound stream
        .i_dat          (), // i  [DWIDTH - 1 : 0]
        .i_val          (), // i
        .i_eop          (), // i
        .i_rdy          (), // o

        // Outbound stream
        .o_dat          (), // o  [DWIDTH - 1 : 0]
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ps_param_keeper
*/


module ps_param_keeper
#(
    parameter int unsigned          DWIDTH = 8,     // Stream width
    parameter int unsigned          PWIDTH = 8      // Parameters bus width
)
(
    // Reset and clock
    input  logic                    reset,
    input  logic                    clk,

    // Input packet's parameters bus
    input  logic [PWIDTH - 1 : 0]   desired_param,

    // Output packet's parameters bus
    // (it is held during the whole packet)
    output logic [PWIDTH - 1 : 0]   agreed_param,

    // Inbound stream
    input  logic [DWIDTH - 1 : 0]   i_dat,
    input  logic                    i_val,
    input  logic                    i_eop,
    output logic                    i_rdy,

    // Outbound stream
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    // Signals declaration
    logic                           sop_reg;
    logic [PWIDTH - 1 : 0]          param_reg;


    // Start of packet register
    initial sop_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            sop_reg <= '1;
        else if (i_val & i_rdy)
            sop_reg <= i_eop;
        else
            sop_reg <= sop_reg;


    // Parameters keeping register
    always @(posedge reset, posedge clk)
        if (reset)
            param_reg <= '0;
        else if (i_val & i_rdy & sop_reg)
            param_reg <= desired_param;
        else
            param_reg <= param_reg;


    // Output packet's parameters bus
    // (it is held during the whole packet)
    assign agreed_param = sop_reg ? desired_param : param_reg;


    // Transparent stream translation
    assign i_rdy = o_rdy;
    assign o_dat = i_dat;
    assign o_val = i_val;
    assign o_eop = i_eop;


endmodule // ps_param_keeper