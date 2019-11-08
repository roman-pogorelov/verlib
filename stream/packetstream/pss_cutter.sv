/*
    // PacketStream w/ SOP cutter
    pss_cutter
    #(
        .WIDTH  ()  // Stream width
    )
    the_pss_cutter
    (
        // Reset and clock
        .rst    (), // i
        .clk    (), // i

        // Control input to cut the stream
        .cut    (), // i

        // Losing indicator
        .lost   (), // o

        // Inbound packet stream
        .i_dat  (), // i  [WIDTH - 1 : 0]
        .i_val  (), // i
        .i_sop  (), // i
        .i_eop  (), // i
        .i_rdy  (), // o

        // Outbound packet stream
        .o_dat  (), // o  [WIDTH - 1 : 0]
        .o_val  (), // o
        .o_sop  (), // o
        .o_eop  (), // o
        .o_rdy  ()  // i
    ); // the_pss_cutter
*/


module pss_cutter
#(
    parameter int unsigned          WIDTH = 8   // Stream width
)
(
    // Reset and clock
    input  logic                    rst,
    input  logic                    clk,

    // Control input to cut the stream
    input  logic                    cut,

    // Losing indicator
    output logic                    lost,

    // Inbound packet stream
    input  logic [WIDTH - 1 : 0]    i_dat,
    input  logic                    i_val,
    input  logic                    i_sop,
    input  logic                    i_eop,
    output logic                    i_rdy,

    // Outbound packet stream
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    output logic                    o_sop,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    // Signals declaration
    logic   cut_reg;
    logic   cutting;
    logic   lost_reg;


    // Cut register
    always @(posedge rst, posedge clk) begin
        if (rst)
            cut_reg <= 1'b0;
        else if (cut_reg)
            cut_reg <= ~(~cut & i_val & i_sop);
        else
            cut_reg <= cut;
    end


    // Stream cutting logic
    assign cutting = cut | (cut_reg & ~i_sop);


    // Losing register
    always @(posedge rst, posedge clk) begin
        if (rst)
            lost_reg <= 1'b0;
        else
            lost_reg <= i_val & cutting;
    end
    assign lost = lost_reg;


    // Interface connection logic
    assign o_dat = i_dat;
    assign o_sop = i_sop;
    assign o_eop = i_eop;
    assign o_val = i_val & ~cutting;
    assign i_rdy = o_rdy |  cutting;


endmodule: pss_cutter