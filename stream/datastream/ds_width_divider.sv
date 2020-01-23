/*
    // DataStream downsizing width converter
    ds_width_divider
    #(
        .IWIDTH     (), // Inbound stream width
        .FACTOR     ()  // Inbound to outbound stream width ration
    )
    the_ds_width_divider
    (
        // Reset and clock
        .reset      (), // i
        .clk        (), // i

        // Inbound stream
        .i_dat      (), // i  [IWIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o

        // Outbound stream
        .o_dat      (), // o  [IWIDTH/FACTOR - 1 : 0]
        .o_val      (), // o
        .o_rdy      ()  // i
    ); // the_ds_width_divider
*/


module ds_width_divider
#(
    parameter int unsigned                  IWIDTH = 16,    // Inbound stream width
    parameter int unsigned                  FACTOR = 4      // Inbound to outbound stream width ration
)
(
    // Reset and clock
    input  logic                            reset,
    input  logic                            clk,

    // Входной потоковый интерфейс
    input  logic [IWIDTH - 1 : 0]           i_dat,
    input  logic                            i_val,
    output logic                            i_rdy,

    // Выходной потоковый интерфейс
    output logic [IWIDTH/FACTOR - 1 : 0]    o_dat,
    output logic                            o_val,
    input  logic                            o_rdy
);
    // Signals declaration
    logic [$clog2(FACTOR) - 1 : 0]          o_word_cnt;
    logic                                   shift_done_reg;
    logic [IWIDTH - IWIDTH/FACTOR - 1 : 0]  shift_data_reg;


    // Inbound word counter
    initial o_word_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            o_word_cnt <= '0;
        else if (o_val & o_rdy)
            if (o_word_cnt == FACTOR - 1)
                o_word_cnt <= '0;
            else
                o_word_cnt <= o_word_cnt + 1'b1;
        else
            o_word_cnt <= o_word_cnt;


    // Shift ending register
    initial shift_done_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            shift_done_reg <= '1;
        else if (o_val & o_rdy)
            shift_done_reg <= (o_word_cnt == FACTOR - 1);
        else
            shift_done_reg <= shift_done_reg;


    // Data register
    initial shift_data_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            shift_data_reg <= '0;
        else if (o_val & o_rdy)
            if (shift_done_reg)
                shift_data_reg <= i_dat[IWIDTH - 1 : IWIDTH/FACTOR];
            else if (FACTOR > 2)
                shift_data_reg <= {{IWIDTH/FACTOR{1'b0}}, shift_data_reg[IWIDTH - IWIDTH/FACTOR - 1 : IWIDTH/FACTOR]};
            else
                shift_data_reg <= shift_data_reg;
        else
            shift_data_reg <= shift_data_reg;


    // Output signals logic
    assign i_rdy = o_rdy & shift_done_reg;
    assign o_dat = shift_done_reg ? i_dat[IWIDTH/FACTOR - 1 : 0] : shift_data_reg[IWIDTH/FACTOR - 1 : 0];
    assign o_val = i_val | ~shift_done_reg;


endmodule // ds_width_divider
