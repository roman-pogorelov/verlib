/*
    //------------------------------------------------------------------------------------
    //      Модуль оценки произвольной частоты тактирования по известной опорной
    freq_estimator
    #(
        .PERIOD         (), // Период замеров в тактах refclk (PERIOD > 0)
        .FACTOR         ()  // Максимально возможное отношение estclk/refclk
    )
    the_freq_estimator
    (
        // Опорное тактирование
        .refclk         (), // i
        
        // Оцениваемое тактирование
        .estclk         (), // i
        
        // Оценка частоты тактирования estclk
        .frequency      ()  // o  [$clog2(FACTOR*PERIOD) - 1 : 0]
    ); // the_freq_estimator
*/

module freq_estimator
#(
    parameter int unsigned                          PERIOD = 1000,  // Период замеров в тактах refclk (PERIOD > 0)
    parameter int unsigned                          FACTOR = 2      // Максимально возможное отношение estclk/refclk
)
(
    // Опорное тактирование
    input  logic                                    refclk,
    
    // Оцениваемое тактирование
    input  logic                                    estclk,
    
    // Оценка частоты тактирования estclk
    output logic [$clog2(FACTOR*PERIOD) - 1 : 0]    frequency
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [$clog2(PERIOD) - 1 : 0]                  ref_tick_cnt;
    logic                                           ref_stb_reg;
    logic [$clog2(FACTOR*PERIOD) - 1 : 0]           est_tick_cnt;
    logic [1 : 0][$clog2(FACTOR*PERIOD) - 1 : 0]    est_tick_sync_reg;
    logic [$clog2(FACTOR*PERIOD) - 1 : 0]           est_tick_curr;
    logic [$clog2(FACTOR*PERIOD) - 1 : 0]           est_tick_prev_reg;
    logic [$clog2(FACTOR*PERIOD) - 1 : 0]           freq_est_reg;
    
    
    //------------------------------------------------------------------------------------
    //      Опорный счетчик
    initial ref_tick_cnt = '0;
    always @(posedge refclk)
        if (ref_tick_cnt == PERIOD - 1)
            ref_tick_cnt <= '0;
        else
            ref_tick_cnt <= ref_tick_cnt + 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Регистр строба опорного счетчика
    initial ref_stb_reg = '0;
    always @(posedge refclk)
        ref_stb_reg <= (ref_tick_cnt == PERIOD - 1);
    
    //------------------------------------------------------------------------------------
    //      Счетчик оценивания
    initial est_tick_cnt = '0;
    always @(posedge estclk)
        est_tick_cnt <= est_tick_cnt + 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Цепочка регистров ре-синхронизации счетчика оценивания
    initial est_tick_sync_reg = '0;
    always @(posedge refclk)
        est_tick_sync_reg <= {est_tick_sync_reg[0], est_tick_cnt};
    
    //------------------------------------------------------------------------------------
    //      Текущее значение счетчика оценивания
    assign est_tick_curr = est_tick_sync_reg[1];
    
    //------------------------------------------------------------------------------------
    //      Регистр предыдущего значения счетчика оценивания
    initial est_tick_prev_reg = '0;
    always @(posedge refclk)
        if (ref_stb_reg)
            est_tick_prev_reg <= est_tick_curr;
        else
            est_tick_prev_reg <= est_tick_prev_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр оценивания частоты тактирования
    initial freq_est_reg = '0;
    always @(posedge refclk)
        if (ref_stb_reg)
            freq_est_reg <= est_tick_curr - est_tick_prev_reg;
        else
            freq_est_reg <= freq_est_reg;
    assign frequency = freq_est_reg;
    
endmodule // freq_estimator