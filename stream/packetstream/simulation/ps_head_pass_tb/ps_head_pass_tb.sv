`timescale  1ns / 1ps

module ps_head_pass_tb();

    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam                      DWIDTH = 8;
    localparam                      LWIDTH = 4;
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                           reset;
    logic                           clk;
    //
    logic                           headon;
    logic [LWIDTH - 1 : 0]          length;
    //
    logic [DWIDTH - 1 : 0]          i_dat;
    logic                           i_val;
    logic                           i_eop;
    logic                           i_rdy;
    //
    logic [DWIDTH - 1 : 0]          o_dat;
    logic                           o_val;
    logic                           o_eop;
    logic                           o_rdy;
    //
    logic [DWIDTH - 1 : 0]          h_dat;
    logic                           h_val;
    logic                           h_eop;
    logic                           h_rdy;
    //
    logic [DWIDTH - 1 : 0]          d_dat;
    logic                           d_val;
    logic                           d_eop;
    logic                           d_rdy;
    //
    int                             i_counter;
    int                             o_counter;
    int                             h_counter;
    int                             d_counter;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        reset = '1;
        clk = '0;
        i_dat = '0;
        i_val = '0;
        i_eop = '0;
        o_rdy = '1;
        headon = '0;
        length = 'd4;
    end
    
    //------------------------------------------------------------------------------------
    //      Сброс
    initial #15 reset = '0;
    
    //------------------------------------------------------------------------------------
    //      Тактирование
    always clk = #5 ~clk;
    
    //------------------------------------------------------------------------------------
    //      Счетчик входных данных
    always @(posedge clk)
        if (i_val & i_rdy)
            i_counter <= i_counter + 1;
        else
            i_counter <= i_counter;
    
    //------------------------------------------------------------------------------------
    //      Счетчик входных данных
    always @(posedge clk)
        if (o_val & o_rdy)
            o_counter <= o_counter + 1;
        else
            o_counter <= o_counter;
    
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов заголовков
    always @(posedge clk)
        if (h_val & h_rdy)
            h_counter <= h_counter + 1;
        else
            h_counter <= h_counter;
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов "обезглавленных" данных
    always @(posedge clk)
        if (d_val & d_rdy)
            d_counter <= d_counter + 1;
        else
            d_counter <= d_counter;
    
    
    //------------------------------------------------------------------------------------
    //      Формирование сигнала o_rdy
    always @(posedge clk)
       #1ps o_rdy = $random | reset;
    
    //------------------------------------------------------------------------------------
    //      Процесс передачи
    initial begin
        #100;
        @(posedge clk);
        for (int i = 1; i <= 100; i++) begin
            i_val = $random;
            i_dat = i;
            @(posedge clk);
            if (~(i_rdy & i_val)) i--;
        end
        i_dat = '0;
        i_val = '0;
    end
    
    //------------------------------------------------------------------------------------
    //      Модуль выделения "головы" пакета потокового интерфейса PacketStream
    ps_head_extractor
    #(
        .DWIDTH         (DWIDTH),       // Разрядность потока
        .LWIDTH         (LWIDTH)        // Разрядность шины установки длины заголовка
    )
    the_ps_head_extractor
    (
        // Сброс и тактирование
        .reset          (reset),        // i
        .clk            (clk),          // i
        
        // Интерфейс управления
        .extract        (headon),       // i                    // Разрешение выделения "головы"
        .length         (length),       // i  [LWIDTH - 1 : 0]  // Длина "головы" (0 соотвествует 2^LWIDTH)
        
        // Потоковый интерфейс выдачи заголовка
        .h_dat          (h_dat),        // o  [DWIDTH - 1 : 0]
        .h_val          (h_val),        // o
        .h_eop          (h_eop),        // o
        .h_rdy          (h_rdy),        // i
        
        // Входной потоковый интерфейс
        .i_dat          (i_dat),        // i  [DWIDTH - 1 : 0]
        .i_val          (i_val),        // i
        .i_eop          (i_eop),        // i
        .i_rdy          (i_rdy),        // o
        
        // Выходной потоковый интерфейс
        .o_dat          (d_dat),        // o  [DWIDTH - 1 : 0]
        .o_val          (d_val),        // o
        .o_eop          (d_eop),        // o
        .o_rdy          (d_rdy)         // i
    ); // the_ps_head_extractor
    
    //------------------------------------------------------------------------------------
    //      Модуль вставки "головы" пакета потокового интерфейса PacketStream
    ps_head_inserter
    #(
        .WIDTH          (DWIDTH)        // Разрядность потока
    )
    the_ps_head_inserter
    (
        // Сброс и тактирование
        .reset          (reset),        // i
        .clk            (clk),          // i
        
        // Разрешение вставки заголовка
        .insert         (headon),       // i
        
        // Потоковый интерфейс выдачи заголовка
        .h_dat          (h_dat),        // i  [WIDTH - 1 : 0]
        .h_val          (h_val),        // i
        .h_eop          (h_eop),        // i
        .h_rdy          (h_rdy),        // o
        
        // Входной потоковый интерфейс
        .i_dat          (d_dat),        // i  [WIDTH - 1 : 0]
        .i_val          (d_val),        // i
        .i_eop          (d_eop),        // i
        .i_rdy          (d_rdy),        // o
        
        // Выходной потоковый интерфейс
        .o_dat          (o_dat),        // o  [WIDTH - 1 : 0]
        .o_val          (o_val),        // o
        .o_eop          (o_eop),        // o
        .o_rdy          (o_rdy)         // i
    ); // the_ps_head_inserter
    
endmodule // ps_head_pass_tb