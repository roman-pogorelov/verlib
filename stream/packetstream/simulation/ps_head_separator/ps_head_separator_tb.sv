`timescale  1ns / 1ps
module ps_head_separator_tb ();
    
    //------------------------------------------------------------------------------------
    //      Объявление констант
    localparam int unsigned                 WIDTH   = 8;        // Разрядность потока
    localparam int unsigned                 LENGTH  = 2;        // Длина заголовка
    localparam                              RAMTYPE = "AUTO";   // Тип внутренней памяти для реализации буфера
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                                   reset;
    logic                                   clk;
    //
    logic [WIDTH - 1 : 0]                   i_dat;
    logic                                   i_val;
    logic                                   i_eop;
    logic                                   i_rdy;
    //
    logic [LENGTH - 1 : 0][WIDTH - 1 : 0]   o_hdr;
    logic [$clog2(LENGTH) - 1 : 0]          o_len;
    logic [WIDTH - 1 : 0]                   o_dat;
    logic                                   o_val;
    logic                                   o_eop;
    logic                                   o_rdy;
    //
    int                                     i_counter;
    int                                     o_counter;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        i_dat = 0;
        i_val = 0;
        i_eop = 0;
        o_rdy = 1;
    end
    
    //------------------------------------------------------------------------------------
    //      Сброс
    initial begin
        #00 reset = 1;
        #15 reset = 0;
    end
    
    //------------------------------------------------------------------------------------
    //      Тактирование
    initial clk = 1;
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
        i_dat = 0;
        i_val = 0;
    end
    
    //------------------------------------------------------------------------------------
    //      Модуль выделения "головы" пакета потокового интерфейса PacketStream
    //      и выдачи его в параллельном виде в течение прохождения всего пакета
    ps_head_separator
    #(
        .WIDTH          (WIDTH),    // Разрядность потока
        .LENGTH         (LENGTH),   // Длина заголовка
        .RAMTYPE        (RAMTYPE)   // Тип внутренней памяти для реализации буфера
    )
    DUT
    (
        // Тактирование и сброс
        .reset          (reset),    // i
        .clk            (clk),      // i
        
        // Входной потоковый интерфейс
        .i_dat          (i_dat),    // i  [WIDTH - 1 : 0]
        .i_val          (i_val),    // i
        .i_eop          (i_eop),    // i
        .i_rdy          (i_rdy),    // o
        
        // Выходной потоковый интерфейс
        .o_hdr          (o_hdr),    // o  [LENGTH - 1 : 0][WIDTH - 1 : 0] Параллельное представление заголовка
        .o_len          (o_len),    // o                                  Длина заголовка минус 1
        .o_dat          (o_dat),    // o
        .o_val          (o_val),    // o
        .o_eop          (o_eop),    // o
        .o_rdy          (o_rdy)     // i
    ); // DUT

endmodule: ps_head_separator_tb