/*
    //------------------------------------------------------------------------------------
    //      Линия задержки на регистрах
    delayline
    #(
        .WIDTH              (), // Разрядность линии задержки   (WIDTH   >  0)
        .LATENCY            ()  // Величина задержки            (LATENCY >= 0)
    )
    the_delayline
    (
        // Сброс и тактирование
        .reset              (), // i
        .clk                (), // i
        
        // Разрешение тактирования
        .clkena             (), // i
        
        // Входная шина
        .data               (), // i  [WIDTH - 1 : 0]
        
        // Выходная шина
        .q                  ()  // o  [WIDTH - 1 : 0]
    ); // the_delayline
*/

module delayline
#(
    parameter                       WIDTH   = 19,   // Разрядность линии задержки   (WIDTH   >  0)
    parameter                       LATENCY = 2     // Величина задержки            (LATENCY >= 0)
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Разрешение тактирования
    input  logic                    clkena,
    
    // Входная шина
    input  logic [WIDTH - 1 : 0]    data,
    
    // Выходная шина
    output logic [WIDTH - 1 : 0]    q
);
    //------------------------------------------------------------------------------------
    //      Генерация структуры модуля в зависимости от значения LATENCY
    generate
        // Ненулевая задержка
        if (LATENCY) begin
            logic [LATENCY*WIDTH - 1 : 0] delay_reg;
            always @(posedge reset, posedge clk)
                if (reset)
                    delay_reg <= '0;
                else if (clkena)
                    if (LATENCY == 1)
                        delay_reg <= data;
                    else
                        delay_reg <= {delay_reg[(LATENCY - 1)*WIDTH -1 : 0], data};
                else
                    delay_reg <= delay_reg;
            assign q = delay_reg[LATENCY*WIDTH - 1 : (LATENCY - 1)*WIDTH];
        end
        // Нулевая задержка
        else begin
            assign q = data;
        end
    endgenerate

endmodule // delayline
