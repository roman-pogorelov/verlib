/*
    // PacketStream interface slicer
    ps_slicer
    #(
        .WIDTH      (), // Stream width
        .LENGTH     ()  // Slice length
    )
    the_ps_slicer
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
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_slicer
*/


module ps_slicer
#(
    parameter int unsigned          WIDTH   = 8,    // Stream width
    parameter int unsigned          LENGTH  = 4     // Slice length
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
    output logic                    o_eop,
    input  logic                    o_rdy
);
    // Signals declaration
    logic   slice_eop;


    // Slicing logic
    generate
        if (LENGTH > 1) begin: not_single_len_slices

            // Slice length counter
            logic [$clog2(LENGTH) - 1 : 0] slice_len_cnt;
            always @(posedge rst, posedge clk) begin
                if (rst)
                    slice_len_cnt <= '0;
                else if (i_val & i_rdy)
                    if (i_eop)
                        slice_len_cnt <= '0;
                    else if (LENGTH != (2**$clog2(LENGTH)))
                        if (slice_len_cnt == (LENGTH - 1))
                            slice_len_cnt <= '0;
                        else
                            slice_len_cnt <= slice_len_cnt + 1'b1;
                    else
                        slice_len_cnt <= slice_len_cnt + 1'b1;
                else
                    slice_len_cnt <= slice_len_cnt;
            end


            // Slice EOP register
            logic slice_eop_reg;
            always @(posedge rst, posedge clk) begin
                if (rst)
                    slice_eop_reg <= '0;
                else if (i_val & i_rdy)
                    slice_eop_reg <= (slice_len_cnt == (LENGTH - 2)) & ~i_eop;
                else
                    slice_eop_reg <= slice_eop_reg;
            end
            assign slice_eop = slice_eop_reg;

        end // not_single_len_slices

        else begin: single_len_slices
            assign slice_eop = 1'b1;
        end

    endgenerate


    // Stream translation logic
    assign o_dat = i_dat;
    assign o_val = i_val;
    assign o_eop = i_eop | slice_eop;
    assign i_rdy = o_rdy;


endmodule: ps_slicer