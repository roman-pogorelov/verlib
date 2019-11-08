/*
    // PacketStream w/o SOP to PacketStream w/ SOP converter
    ps_to_pss
    #(
        .WIDTH      ()  // Stream width
    )
    the_ps_to_pss
    (
        // Reset and clock
        .rst        (), // i
        .clk        (), // i

        // Inbound stream
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o

        // Outbound stream
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_sop      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_to_pss
*/


module ps_to_pss
#(
    parameter int unsigned          WIDTH = 8   // Stream width
)
(
    // Reset and clock
    input  logic                    rst,
    input  logic                    clk,

    // Inbound stream
    input  logic [WIDTH - 1 : 0]    i_dat,
    input  logic                    i_val,
    input  logic                    i_eop,
    output logic                    i_rdy,

    // Outbound stream
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    output logic                    o_sop,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    // Signals declaration
    logic   sop_reg;


    // SOP register
    initial sop_reg = 1'b1;
    always @(posedge rst, posedge clk) begin
        if (rst)
            sop_reg <= 1'b1;
        else if (i_val & i_rdy)
            sop_reg <= i_eop;
        else
            sop_reg <= sop_reg;
    end
    assign o_sop = sop_reg;


    // Direct connection logic
    assign o_dat = i_dat;
    assign o_val = i_val;
    assign o_eop = i_eop;
    assign i_rdy = o_rdy;


endmodule // ps_to_pss