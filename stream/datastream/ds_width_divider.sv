/*
    //------------------------------------------------------------------------------------
    //      Модуль "сужения" разрядности потокового интерфейса DataStream
    ds_width_divider
    #(
        .IWIDTH     (), // Разрядность входного потокового интерфейса
        .FACTOR     ()  // Отношение разрядности входного потокового интерфейса к разрядности выходного
    )
    the_ds_width_divider
    (
        // Асинхронный сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [IWIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [IWIDTH/FACTOR - 1 : 0]
        .o_val      (), // o
        .o_rdy      ()  // i
    ); // the_ds_width_divider
*/

module ds_width_divider
#(
    parameter int unsigned                  IWIDTH = 16,    // Разрядность входного потокового интерфейса
    parameter int unsigned                  FACTOR = 4      // Отношение разрядности входного потокового интерфейса к разрядности выходного
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
    output logic [IWIDTH/FACTOR - 1 : 0]    o_dat,
    output logic                            o_val,
    input  logic                            o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [$clog2(FACTOR) - 1 : 0]          o_word_cnt;     // Счетчик слов выходного потокового интерфейса
    logic                                   shift_done_reg; // Регистр признака окончания сдвига данных
    logic [IWIDTH - IWIDTH/FACTOR - 1 : 0]  shift_data_reg; // Регистр сдвига данных
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов выходного потокового интерфейса
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
    
    //------------------------------------------------------------------------------------
    //      Регистр признака окончания сдвига данных
    initial shift_done_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            shift_done_reg <= '1;
        else if (o_val & o_rdy)
            shift_done_reg <= (o_word_cnt == FACTOR - 1);
        else
            shift_done_reg <= shift_done_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр данных
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
    
    //------------------------------------------------------------------------------------
    //      Формирование сигналов потоковых интерфейсов
    assign i_rdy = o_rdy & shift_done_reg;
    assign o_dat = shift_done_reg ? i_dat[IWIDTH/FACTOR - 1 : 0] : shift_data_reg[IWIDTH/FACTOR - 1 : 0];
    assign o_val = i_val | ~shift_done_reg;
    
endmodule // ds_width_divider
