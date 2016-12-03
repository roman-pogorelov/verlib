/*
    //------------------------------------------------------------------------------------
    //      Модуль "расширения" разрядности потокового интерфейса PacketStream
    ps_width_expander
    #(
        .WIDTH      (), // Разрядность входного потока
        .COUNT      ()  // Количество слов разрядности WIDTH в выходном потоке
    )
    the_ps_width_expander
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [COUNT*WIDTH - 1 : 0]  
        .o_mty      (), // o  [$clog2(COUNT) - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_width_expander
*/

module ps_width_expander
#(
    parameter int unsigned                  WIDTH = 4,  // Разрядность входного потока
    parameter int unsigned                  COUNT = 8   // Количество слов разрядности WIDTH в выходном потоке
)
(
    // Сброс и тактирование
    input  logic                            reset,
    input  logic                            clk,
    
    // Входной потоковый интерфейс
    input  logic [WIDTH - 1 : 0]            i_dat,
    input  logic                            i_val,
    input  logic                            i_eop,
    output logic                            i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [COUNT*WIDTH - 1 : 0]      o_dat,
    output logic [$clog2(COUNT) - 1 : 0]    o_mty,
    output logic                            o_val,
    output logic                            o_eop,
    input  logic                            o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam logic [$clog2(COUNT) - 1 : 0] MAX_MTY = COUNT[$clog2(COUNT) - 1 : 0] - 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [$clog2(COUNT) - 1 : 0]           word_cnt;
    logic                                   last_word_reg;
    logic                                   accum_abort;
    logic [MAX_MTY - 1 : 0]                 pos_reg;
    logic [MAX_MTY - 1 : 0]                 mask_reg;
    logic [(COUNT - 1)*WIDTH - 1 : 0]       accum_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов входного потока
    initial word_cnt <= MAX_MTY;
    always @(posedge reset, posedge clk)
        if (reset)
            word_cnt <= MAX_MTY;
        else if (i_val & i_rdy)
            if (accum_abort)
                word_cnt <= MAX_MTY;
            else
                word_cnt <= word_cnt - 1'b1;
        else
            word_cnt <= word_cnt;
    assign o_mty = word_cnt;
    
    //------------------------------------------------------------------------------------
    //      Признак прохождения последнего слова при накоплении
    initial last_word_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            last_word_reg <= '0;
        else if (i_val & i_rdy)
            last_word_reg <= (word_cnt == 1) & ~i_eop;
        else
            last_word_reg <= last_word_reg;
    
    //------------------------------------------------------------------------------------
    //      Индикатор необходимости окончить накопление
    assign accum_abort = i_eop | last_word_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр позиции активного накопителя
    generate
        // Для трех и более слов в выходном потоке
        if (MAX_MTY > 1) begin
            initial pos_reg = {{MAX_MTY - 1{1'b0}}, 1'b1};
            always @(posedge reset, posedge clk)
                if (reset)
                    pos_reg <= {{MAX_MTY - 1{1'b0}}, 1'b1};
                else if (i_val & i_rdy)
                    if (accum_abort)
                        pos_reg <= {{MAX_MTY - 1{1'b0}}, 1'b1};
                    else
                        pos_reg <= {pos_reg[MAX_MTY - 2 : 0], 1'b0};
                else
                    pos_reg <= pos_reg;
        end
        // Простейший случай для двух слов в выходном потоке
        else begin
            assign pos_reg = 1'b1;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Регистр маски регистров накопителей, содержащих достоверные данные
    initial mask_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            mask_reg <= '0;
        else if (i_val & i_rdy)
            if (accum_abort)
                mask_reg <= '0;
            else if (MAX_MTY > 1)
                mask_reg <= {mask_reg[MAX_MTY - 2 : 0], 1'b1};
            else
                mask_reg <= 1'b1;
        else
            mask_reg <= mask_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр накопления данных
    generate
        genvar i;
        for (i = 0; i < MAX_MTY; i++) begin: accum_reg_gen
            initial accum_reg[(i + 1)*WIDTH - 1 : i*WIDTH] = '0;
            always @(posedge reset, posedge clk)
                if (reset)
                    accum_reg[(i + 1)*WIDTH - 1 : i*WIDTH] <= '0;
                else if (i_val & i_rdy & pos_reg[i])
                    accum_reg[(i + 1)*WIDTH - 1 : i*WIDTH] <= i_dat;
                else
                    accum_reg[(i + 1)*WIDTH - 1 : i*WIDTH] <= accum_reg[(i + 1)*WIDTH - 1 : i*WIDTH];
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Логика формирования данных выходного потока
    generate
        genvar j;
        for (j = 0; j < MAX_MTY; j++) begin: o_dat_gen
            assign o_dat[(j + 1)*WIDTH - 1 : j*WIDTH] = mask_reg[j] ? accum_reg[(j + 1)*WIDTH - 1 : j*WIDTH] : i_dat;
        end
        assign o_dat[COUNT*WIDTH - 1 : (COUNT - 1)*WIDTH] = i_dat;
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов управления потоками
    assign i_rdy = o_rdy | ~accum_abort;
    assign o_val = i_val &  accum_abort;
    
    //------------------------------------------------------------------------------------
    //      Сквозная трансляция признака конца пакета
    assign o_eop = i_eop;
    
endmodule // ps_width_expander