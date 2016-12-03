`timescale  1ns / 1ps

module ps_width_conv_tb();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam                      WIDTH = 8;
    localparam                      COUNT = 16;
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                           reset;
    logic                           clk;
    //
    logic [WIDTH - 1 : 0]           i_dat;
    logic                           i_val;
    logic                           i_eop;
    logic                           i_rdy;
    //
    logic [WIDTH - 1 : 0]           o_dat;
    logic                           o_val;
    logic                           o_eop;
    logic                           o_rdy;
    //
    logic [COUNT*WIDTH - 1 : 0]     wide_dat;
    logic [$clog2(COUNT) - 1 : 0]   wide_mty;
    logic                           wide_val;
    logic                           wide_eop;
    logic                           wide_rdy;
    //
    int                             i_counter;
    int                             o_counter;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        reset = '1;
        clk = '0;
        i_dat = '0;
        i_val = '0;
        i_eop = '0;
        o_rdy = '1;
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
    //      Модуль "расширения" разрядности потокового интерфейса PacketStream
    ps_width_expander
    #(
        .WIDTH      (WIDTH),        // Разрядность входного потока
        .COUNT      (COUNT)         // Количество слов разрядности WIDTH в выходном потоке
    )
    the_ps_width_expander
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Входной потоковый интерфейс
        .i_dat      (i_dat),        // i  [WIDTH - 1 : 0]
        .i_val      (i_val),        // i
        .i_eop      (i_eop),        // i
        .i_rdy      (i_rdy),        // o
        
        // Выходной потоковый интерфейс
        .o_dat      (wide_dat),     // o  [COUNT*WIDTH - 1 : 0]  
        .o_mty      (wide_mty),     // o  [$clog2(COUNT) - 1 : 0]
        .o_val      (wide_val),     // o
        .o_eop      (wide_eop),     // o
        .o_rdy      (wide_rdy)      // i
    ); // the_ps_width_expander
    
    //------------------------------------------------------------------------------------
    //      Модуль "сужения" разрядности потокового интерфейса PacketStream
    ps_width_divider
    #(
        .WIDTH      (WIDTH),        // Разрядность выходного потока
        .COUNT      (COUNT)         // Количество слов разрядности WIDTH во входном потоке (COUNT > 1)
    )
    the_ps_width_divider
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Входной потоковый интерфейс
        .i_dat      (wide_dat),     // i  [COUNT*WIDTH - 1 : 0]
        .i_mty      (wide_mty),     // i  [$clog2(COUNT) - 1 : 0]
        .i_val      (wide_val),     // i
        .i_eop      (wide_eop),     // i
        .i_rdy      (wide_rdy),     // o
        
        // Выходной потоковый интерфейс
        .o_dat      (o_dat),        // o  [WIDTH - 1 : 0]
        .o_val      (o_val),        // o
        .o_eop      (o_eop),        // o
        .o_rdy      (o_rdy)         // i
    ); // the_ps_width_divider
    
endmodule // ps_width_conv_tb