`timescale  1ns / 1ps
module crc_calculator_tb ();
    
    //------------------------------------------------------------------------------------
    //      Объявление констант
    localparam int unsigned                 DATAWIDTH   = 8;        // Разрядность данных
    localparam int unsigned                 CRCWIDTH    = 16;       // Разрядность CRC
    localparam logic [CRCWIDTH - 1 : 0]     POLYNOMIAL  = 16'h8005; // Порождающий полином
    localparam logic [CRCWIDTH - 1 : 0]     INIT        = 16'h0000; // Порождающий полином
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                       reset;
    logic                       clk;
    logic [DATAWIDTH - 1 : 0]   data;
    logic [DATAWIDTH - 1 : 0]   data_rev;
    logic                       clkena;
    logic [CRCWIDTH - 1 : 0]    crc_reg;
    logic [CRCWIDTH - 1 : 0]    crc_new;
    logic [CRCWIDTH - 1 : 0]    crc_new_rev;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        data        = '0;
        clkena      = '0;
    end
    
    //------------------------------------------------------------------------------------
    //      Сброс
    initial begin
        #00 reset = 1;
        #15 reset = 0;
    end
    
    //------------------------------------------------------------------------------------
    //      Тактирование
    initial clk = '1;
    always  clk = #05 ~clk;
    
    //------------------------------------------------------------------------------------
    //      Реверсирование данных
    always_comb begin
        for (int i = 0; i < DATAWIDTH; i++) begin
            data_rev[i] = data[$high(data) - i];
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Регистр накопления значения CRC
    initial crc_reg = INIT;
    always @(posedge reset, posedge clk)
        if (reset)
            crc_reg <= INIT;
        else if (clkena)
            crc_reg <= crc_new;
        else
            crc_reg <= crc_reg;
    
    //------------------------------------------------------------------------------------
    //      Модуль вычисления значения значения контрольной суммы CRC
    crc_calculator
    #(
        .DATAWIDTH  (DATAWIDTH),    // Разрядность данных
        .CRCWIDTH   (CRCWIDTH),     // Разрядность CRC
        .POLYNOMIAL (POLYNOMIAL)    // Порождающий полином
    )
    the_crc_calculator
    (
        // Входные данные
        .i_dat      (data_rev),     // i  [DATAWIDTH - 1 : 0]
        
        // Входное (текущее) значение CRC
        .i_crc      (crc_reg),      // i  [CRCWIDTH - 1 : 0]
        
        // Выходное (расчитанное) значение CRC
        .o_crc      (crc_new)       // o  [CRCWIDTH - 1 : 0]
    ); // the_crc_calculator
    
    //------------------------------------------------------------------------------------
    //      Реверсирование CRC
    always_comb begin
        for (int i = 0; i < CRCWIDTH; i++) begin
            crc_new_rev[i] = crc_new[$high(crc_new) - i];
        end
    end
    
endmodule: crc_calculator_tb