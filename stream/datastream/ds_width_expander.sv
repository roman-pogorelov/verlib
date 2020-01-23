/*
    // DataStream upsizing width converter
    ds_width_expander
    #(
        .IWIDTH     (), // Inbound stream width
        .FACTOR     ()  // Outbound to inbound stream width ration (FACTOR > 1)
    )
    the_ds_width_expander
    (
        // Reset and clock
        .reset      (), // i
        .clk        (), // i

        // Inbound stream
        .i_dat      (), // i  [IWIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o

        // Outbound stream
        .o_dat      (), // o  [IWIDTH*FACTOR - 1 : 0]
        .o_val      (), // o
        .o_rdy      ()  // i
    ); // the_ds_width_expander
*/

module ds_width_expander
#(
    parameter int unsigned                  IWIDTH = 8,     // Inbound stream width
    parameter int unsigned                  FACTOR = 2      // Outbound to inbound stream width ration (FACTOR > 1)
)
(
    // Reset and clock
    input  logic                            reset,
    input  logic                            clk,

    // Inbound stream
    input  logic [IWIDTH - 1 : 0]           i_dat,
    input  logic                            i_val,
    output logic                            i_rdy,

    // Outbound stream
    output logic [IWIDTH*FACTOR - 1 : 0]    o_dat,
    output logic                            o_val,
    input  logic                            o_rdy
);
    // Signals declaration
    logic [$clog2(FACTOR) - 1 : 0]          i_word_cnt;
    logic                                   accum_done_reg;
    logic [IWIDTH*(FACTOR - 1) - 1 : 0]     accum_data_reg;


    // Inbound words counter
    initial i_word_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            i_word_cnt <= '0;
        else if (i_val & i_rdy)
            if (accum_done_reg)
                i_word_cnt <= '0;
            else
                i_word_cnt <= i_word_cnt + 1'b1;
        else
            i_word_cnt <= i_word_cnt;


    // Ending accumulation register
    initial accum_done_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            accum_done_reg <= '0;
        else if (i_val & i_rdy)
            accum_done_reg <= (i_word_cnt == FACTOR - 2);
        else
            accum_done_reg <= accum_done_reg;


    // Data register
    initial accum_data_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            accum_data_reg <= '0;
        else if (i_val & i_rdy)
            if (FACTOR > 2)
                accum_data_reg <= {i_dat, accum_data_reg[IWIDTH*(FACTOR - 1) - 1 : IWIDTH]};
            else
                accum_data_reg <= i_dat;
        else
            accum_data_reg <= accum_data_reg;


    // Output signals logic
    assign i_rdy = o_rdy | ~accum_done_reg;
    assign o_dat = {i_dat, accum_data_reg};
    assign o_val = i_val & accum_done_reg;


endmodule // ds_width_expander
