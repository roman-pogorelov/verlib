/*
    //------------------------------------------------------------------------------------
    //      Модуль выделения "головы" пакета потокового интерфейса PacketStream
    ps_head_extractor
    #(
        .DWIDTH         (), // Разрядность потока
        .LWIDTH         ()  // Разрядность шины установки длины заголовка
    )
    the_ps_head_extractor
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Интерфейс управления
        .extract        (), // i                    // Разрешение выделения "головы"
        .length         (), // i  [LWIDTH - 1 : 0]  // Длина "головы" (0 соотвествует 2^LWIDTH)
        
        // Потоковый интерфейс выдачи заголовка
        .h_dat          (), // o  [DWIDTH - 1 : 0]
        .h_val          (), // o
        .h_eop          (), // o
        .h_rdy          (), // i
        
        // Входной потоковый интерфейс
        .i_dat          (), // i  [DWIDTH - 1 : 0]
        .i_val          (), // i
        .i_eop          (), // i
        .i_rdy          (), // o
        
        // Выходной потоковый интерфейс
        .o_dat          (), // o  [DWIDTH - 1 : 0]
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ps_head_extractor
*/

module ps_head_extractor
#(
    parameter                       DWIDTH = 8, // Разрядность потока
    parameter                       LWIDTH = 3  // Разрядность шины установки длины заголовка
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic                    extract,    // Разрешение выделения "головы"
    input  logic [LWIDTH - 1 : 0]   length,     // Длина "головы" (0 соотвествует 2^LWIDTH)
    
    // Потоковый интерфейс выдачи заголовка
    output logic [DWIDTH - 1 : 0]   h_dat,
    output logic                    h_val,
    output logic                    h_eop,
    input  logic                    h_rdy,
    
    // Входной потоковый интерфейс
    input  logic [DWIDTH - 1 : 0]   i_dat,
    input  logic                    i_val,
    input  logic                    i_eop,
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                           sop_reg;
    logic [LWIDTH - 1 : 0]          len_cnt;
    logic                           count_h_eop_reg;
    logic                           count_h_eop;
    logic                           hdr_done_reg;
    logic                           hdr_done;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака начала пакета
    initial sop_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            sop_reg <= '1;
        else if (i_val & i_rdy)
            sop_reg <= i_eop;
        else
            sop_reg <= sop_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов, прошедших через входной интерфейс
    always @(posedge reset, posedge clk)
        if (reset)
            len_cnt <= '0;
        else if (i_val & i_rdy)
            if (sop_reg)
                if (extract)
                    len_cnt <= length - 1'b1;
                else
                    len_cnt <= '0;
            else
                len_cnt <= len_cnt - |len_cnt;
        else
            len_cnt <= len_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр "подсчитанного" признака конца пакета заголовка
    always @(posedge reset, posedge clk)
        if (reset)
            count_h_eop_reg <= '0;
        else if (i_val & i_rdy)
            count_h_eop_reg <= ~i_eop & (sop_reg ? extract & (length == 2) : len_cnt == 2);
        else
            count_h_eop_reg <= count_h_eop_reg;
    
    //------------------------------------------------------------------------------------
    //      "Подсчитанный" признак конца пакета заголовка
    assign count_h_eop = sop_reg ? extract & (length == 1) : count_h_eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака окончания заголовка
    always @(posedge reset, posedge clk)
        if (reset)
            hdr_done_reg <= '0;
        else if (i_val & i_rdy)
            if (hdr_done_reg)
                hdr_done_reg <= ~i_eop;
            else
                hdr_done_reg <= ~i_eop & (sop_reg ? ~extract | (length == 1) : count_h_eop_reg);
        else
            hdr_done_reg <= hdr_done_reg;
    
    //------------------------------------------------------------------------------------
    //      Обобщенный признак окончания прохождения заголовка
    assign hdr_done = sop_reg ? ~extract : hdr_done_reg;
    
    //------------------------------------------------------------------------------------
    //      Сквозная трансляция данных в оба направления
    assign o_dat = i_dat;
    assign h_dat = i_dat;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов управления потоками
    assign i_rdy =  hdr_done ? o_rdy : h_rdy;
    assign o_val =  hdr_done & i_val;
    assign h_val = ~hdr_done & i_val;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования признаков конца пакета
    assign o_eop =  hdr_done & i_eop;
    assign h_eop = ~hdr_done & (i_eop | count_h_eop);
    
endmodule // ps_head_extractor