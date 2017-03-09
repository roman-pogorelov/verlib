`timescale  1ns / 1ps

module iterated_signed_divider_tb();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam              NWIDTH = 8; // Разрядность числителя
    localparam              DWIDTH = 6; // Разрядность знаменателя
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                   reset;
    logic                   clk;
    logic                   start;
    logic                   ready;
    logic                   done;
    logic [NWIDTH - 1 : 0]  numerator, n;
    logic [DWIDTH - 1 : 0]  denominator, d;
    logic [NWIDTH - 1 : 0]  quotient;
    logic [DWIDTH - 1 : 0]  remainder;
    int                     fd;
    
    //------------------------------------------------------------------------------------
    //      Сброс
    initial begin
        #00 reset = '1;
        #15 reset = '0;
    end
    
    //------------------------------------------------------------------------------------
    //      Тактирование
    initial clk = '1;
    always  clk = #05 ~clk;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        start = 0;
        numerator = {1'b1, {NWIDTH - 1{1'b0}}};
        denominator = {1'b1, {DWIDTH - 1{1'b0}}};;
    end
    
    //------------------------------------------------------------------------------------
    //      Тестирование
    initial begin
        fd = $fopen("result.txt", "w");
        if (!fd) begin
            $display("Иди на хуй, тупое лезгинское ебло!!!");
        end
        #100;
        @(posedge clk);
        start = 1;
        while(1) begin
            @(posedge clk);
            while(~ready) @(posedge clk);
            
            if ($signed(n) == $signed(d)*$signed(quotient) + $signed(remainder))
                $fwrite(fd, "Тест прошел!    %d = %d * %d + %d\n", $signed(n), $signed(d), $signed(quotient), $signed(remainder));
            else
                $fwrite(fd, "Тест НЕ прошел! %d != %d * %d + %d\n", $signed(n), $signed(d), $signed(quotient), $signed(remainder));
            
            n = numerator;
            d = denominator;
            
            denominator++;
            if (denominator == {1'b1, {DWIDTH - 1{1'b0}}})
                numerator++;
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Модуль деления знаковых целых чисел в дополнительном коде
    iterated_signed_divider
    #(
        .NWIDTH         (NWIDTH),       // Разрядность числителя
        .DWIDTH         (DWIDTH)        // Разрядность знаменателя
    )
    the_iterated_signed_divider
    (
        // Сброс и тактирование
        .reset          (reset),        // i
        .clk            (clk),          // i
        
        // Интерфейс управления
        .start          (start),        // i
        .ready          (ready),        // o
        .done           (done),         // o
        
        // Интерфейс входных данных
        .numerator      (numerator),    // i  [NWIDTH - 1 : 0]
        .denominator    (denominator),  // i  [DWIDTH - 1 : 0]
        
        // Интерфейс выходных данных
        .quotient       (quotient),     // o  [NWIDTH - 1 : 0]
        .remainder      (remainder)     // o  [DWIDTH - 1 : 0]
    ); // the_iterated_signed_divider

endmodule // iterated_signed_divider_tb