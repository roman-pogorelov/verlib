/*
    //------------------------------------------------------------------------------------
    //      Модуль "расширения" разрядности потокового интерфейса DataStream
    ds_width_expander
    #(
        .IWIDTH     (), // Разрядность входного потокового интерфейса
        .FACTOR     ()  // Коэффициент расширения разрядности (FACTOR > 1)
    )
    the_ds_width_expander
    (
        // Асинхронный сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [IWIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [IWIDTH*FACTOR - 1 : 0]
        .o_val      (), // o
        .o_rdy      ()  // i
    ); // the_ds_width_expander
*/

module ds_width_expander
#(
    parameter int unsigned                  IWIDTH = 8,     // Разрядность входного потокового интерфейса
    parameter int unsigned                  FACTOR = 2      // Коэффициент расширения разрядности (FACTOR > 1)
)
(
    // Асинхронный сброс и тактирование
    input  logic                            reset,
    input  logic                            clk,
    
    // Входной потоковый интерфейс
    input  logic [IWIDTH - 1 : 0]           i_dat,
    input  logic                            i_val,
    output logic                            i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [IWIDTH*FACTOR - 1 : 0]    o_dat,
    output logic                            o_val,
    input  logic                            o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [$clog2(FACTOR) - 1 : 0]          i_word_cnt;     // Счетчик слов входного потокового интерфейса
    logic                                   accum_done_reg; // Регистр признака окончания накопления
    logic [IWIDTH*(FACTOR - 1) - 1 : 0]     accum_data_reg; // Регистр накопления данных
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов входного потокового интерфейса
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
    
    //------------------------------------------------------------------------------------
    //      Регистр признака окончания накопления
    initial accum_done_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            accum_done_reg <= '0;
        else if (i_val & i_rdy)
            accum_done_reg <= (i_word_cnt == FACTOR - 2);
        else
            accum_done_reg <= accum_done_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр данных
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
    
    //------------------------------------------------------------------------------------
    //      Формирование сигналов потоковых интерфейсов
    assign i_rdy = o_rdy | ~accum_done_reg;
    assign o_dat = {i_dat, accum_data_reg};
    assign o_val = i_val & accum_done_reg;
    
endmodule // ds_width_expander
