/*
    // PacketStream downsizing width converter
    ps_width_divider
    #(
        .WIDTH      (), // Inbound stream width
        .COUNT      ()  // Inbound to outbound stream width ration
    )
    the_ps_width_divider
    (
        // Reset and clock
        .reset      (), // i
        .clk        (), // i

        // Inbound stream
        .i_dat      (), // i  [COUNT*WIDTH - 1 : 0]
        .i_mty      (), // i  [$clog2(COUNT) - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o

        // Outbound stream
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_width_divider
*/


module ps_width_divider
#(
    parameter int unsigned                  WIDTH = 4,  // Inbound stream width
    parameter int unsigned                  COUNT = 8   // Inbound to outbound stream width ration
)
(
    // Reset and clock
    input  logic                            reset,
    input  logic                            clk,

    // Inbound stream
    input  logic [COUNT*WIDTH - 1 : 0]      i_dat,
    input  logic [$clog2(COUNT) - 1 : 0]    i_mty,
    input  logic                            i_val,
    input  logic                            i_eop,
    output logic                            i_rdy,

    // Outbound stream
    output logic [WIDTH - 1 : 0]            o_dat,
    output logic                            o_val,
    output logic                            o_eop,
    input  logic                            o_rdy
);
    // Constants declaration
    localparam logic [$clog2(COUNT) - 1 : 0] MAX_MTY = COUNT[$clog2(COUNT) - 1 : 0] - 1'b1;


    // Signals declaration
    logic [$clog2(COUNT) - 1 : 0]           wodr_cnt;
    logic                                   shift_done_reg;
    logic [(COUNT - 1)*WIDTH - 1 : 0]       shift_data_reg;
    logic                                   eop_reg;


    // Inbound words counter
    initial wodr_cnt <= '0;
    always @(posedge reset, posedge clk)
        if (reset)
            wodr_cnt <= '0;
        else if (o_val & o_rdy)
            if (wodr_cnt == 0)
                // i_mty is incorrect if i_eop isn't active
                if (~i_eop | (i_mty > MAX_MTY))
                    wodr_cnt <= MAX_MTY;
                // i_mty is correct if i_eop is active
                else
                    wodr_cnt <= MAX_MTY - i_mty;
            else
                wodr_cnt <= wodr_cnt - 1'b1;
        else
            wodr_cnt <= wodr_cnt;


    // Shift done register
    initial shift_done_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            shift_done_reg = '1;
        else if (o_val & o_rdy)
            if (shift_done_reg)
                shift_done_reg <= ~((wodr_cnt == 0) & ((i_mty < MAX_MTY) | ~i_eop));
            else
                shift_done_reg <= (wodr_cnt == 1);
        else
            shift_done_reg <= shift_done_reg;


    // Shift register
    initial shift_data_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            shift_data_reg <= '0;
        else if (o_val & o_rdy)
            if (shift_done_reg)
                shift_data_reg <= i_dat[COUNT*WIDTH - 1 : WIDTH];
            else if (COUNT > 2)
                shift_data_reg <= {{WIDTH{1'b0}}, shift_data_reg[(COUNT - 1)*WIDTH - 1 : WIDTH]};
            else
                shift_data_reg <= shift_data_reg;
        else
            shift_data_reg <= shift_data_reg;


    // EOP register
    initial eop_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            eop_reg <= '0;
        else if (i_val & i_rdy)
            eop_reg <= i_eop;
        else
            eop_reg <= eop_reg;


    // Handshake signals logic
    assign i_rdy = o_rdy &  shift_done_reg;
    assign o_val = i_val | ~shift_done_reg;


    // Outbound data logic
    assign o_dat = shift_done_reg ? i_dat[WIDTH - 1 : 0] : shift_data_reg[WIDTH - 1 : 0];


    // Outbound EOP logic
    assign o_eop = shift_done_reg ? ((i_mty >= MAX_MTY) & i_eop) : ((wodr_cnt == 1) & eop_reg);


endmodule // ps_width_divider