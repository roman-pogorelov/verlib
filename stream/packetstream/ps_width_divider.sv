/*
    //------------------------------------------------------------------------------------
    //      Модуль "сужения" разрядности потокового интерфейса PacketStream
    ps_width_divider
    #(
        .WIDTH      (), // Разрядность выходного потока
        .COUNT      ()  // Количество слов разрядности WIDTH во входном потоке (COUNT > 1)
    )
    the_ps_width_divider
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [COUNT*WIDTH - 1 : 0]
        .i_mty      (), // i  [$clog2(COUNT) - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_width_divider
*/

module ps_width_divider
#(
    parameter int unsigned                  WIDTH = 4,  // Разрядность выходного потока
    parameter int unsigned                  COUNT = 8   // Количество слов разрядности WIDTH во входном потоке (COUNT > 1)
)
(
    // Сброс и тактирование
    input  logic                            reset,
    input  logic                            clk,
    
    // Входной потоковый интерфейс
    input  logic [COUNT*WIDTH - 1 : 0]      i_dat,
    input  logic [$clog2(COUNT) - 1 : 0]    i_mty,
    input  logic                            i_val,
    input  logic                            i_eop,
    output logic                            i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]            o_dat,
    output logic                            o_val,
    output logic                            o_eop,
    input  logic                            o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam logic [$clog2(COUNT) - 1 : 0] MAX_MTY = COUNT[$clog2(COUNT) - 1 : 0] - 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [$clog2(COUNT) - 1 : 0]           wodr_cnt;
    logic                                   shift_done_reg;
    logic [(COUNT - 1)*WIDTH - 1 : 0]       shift_data_reg;
    logic                                   eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов выходного потока
    initial wodr_cnt <= '0;
    always @(posedge reset, posedge clk)
        if (reset)
            wodr_cnt <= '0;
        else if (o_val & o_rdy)
            if (wodr_cnt == 0)
                // Если нет признака конца пакета или i_mty не корректен
                if (~i_eop | (i_mty > MAX_MTY))
                    wodr_cnt <= MAX_MTY;
                // Если есть признак конца пакета и i_mty корректен
                else
                    wodr_cnt <= MAX_MTY - i_mty;
            else
                wodr_cnt <= wodr_cnt - 1'b1;
        else
            wodr_cnt <= wodr_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака окончания сдвига
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
    
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр данных
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
    
    //------------------------------------------------------------------------------------
    //      Регистр признака конца пакета входного потока
    initial eop_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            eop_reg <= '0;
        else if (i_val & i_rdy)
            eop_reg <= i_eop;
        else
            eop_reg <= eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов управления потоками
    assign i_rdy = o_rdy &  shift_done_reg;
    assign o_val = i_val | ~shift_done_reg;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования данных выходного потока
    assign o_dat = shift_done_reg ? i_dat : shift_data_reg[WIDTH - 1 : 0];
    
    //------------------------------------------------------------------------------------
    //      Логика формирования признака конца пакета
    assign o_eop = shift_done_reg ? ((i_mty >= MAX_MTY) & i_eop) : ((wodr_cnt == 1) & eop_reg);
    
endmodule // ps_width_divider