/*
    //------------------------------------------------------------------------------------
    //      Генератор периодического сигнала
    periodicgen
    #(
        .LTIME      (), // Интервал времени пребывания в состоянии "0" (LTIME > 0)
        .HTIME      (), // Интервал времени пребывания в состоянии "1" (HTIME > 0)
        .INIT       ()  // Начальное состояние (после сброса) (1'b0 | 1'b1)
    )
    the_periodicgen
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Выход
        .out        ()  // o
    ); // the_periodicgen
*/

module periodicgen
#(
    parameter int unsigned  LTIME = 8,      // Интервал времени пребывания в состоянии "0" (LTIME > 0)
    parameter int unsigned  HTIME = 16,     // Интервал времени пребывания в состоянии "1" (HTIME > 0)
    parameter logic         INIT  = 1'b1    // Начальное состояние (после сброса) (1'b0 | 1'b1)
)
(
    // Сброс и тактирование
    input  logic            reset,
    input  logic            clk,
    
    // Разрешение тактирования
    input  logic            clkena,
    
    // Выход
    output logic            out
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    parameter int unsigned  MAXTIME = HTIME > LTIME ? HTIME : LTIME;
    parameter int unsigned  WIDTH   = MAXTIME > 1 ? $clog2(MAXTIME) : 1;
    parameter int unsigned  LMAX    = LTIME > 0 ? LTIME - 1 : 0;
    parameter int unsigned  HMAX    = HTIME > 0 ? HTIME - 1 : 0;
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [WIDTH - 1 : 0]   time_cnt;
    logic                   out_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик временных промежутков
    initial time_cnt = INIT ? HMAX[WIDTH - 1 : 0] : LMAX[WIDTH - 1 : 0];
    always @(posedge reset, posedge clk)
        if (reset)
            time_cnt <= INIT ? HMAX[WIDTH - 1 : 0] : LMAX[WIDTH - 1 : 0];
        else if (clkena)
            if (time_cnt == 0)
                time_cnt <= out_reg ? LMAX[WIDTH - 1 : 0] : HMAX[WIDTH - 1 : 0];
            else
                time_cnt <= time_cnt - 1'b1;
        else
            time_cnt <= time_cnt;
    
    //------------------------------------------------------------------------------------
    //      Выходной триггер
    initial out_reg = INIT;
    always @(posedge reset, posedge clk)
        if (reset)
            out_reg <= INIT;
        else if (clkena)
            out_reg <= out_reg ^ (time_cnt == 0);
        else
            out_reg <= out_reg;
    assign out = out_reg;
    
endmodule: periodicgen