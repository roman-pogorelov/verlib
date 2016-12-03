/*
    //------------------------------------------------------------------------------------
    //      Цепь последовательно соединенных регистров
    regchain
    #(
        parameter int unsigned                          WIDTH    = 16,      // Разрядность каждого регистра
        parameter int unsigned                          LENGTH   = 64       // Количество регистров в цепочке
    )
    the_regchain
    (
        // Сброс и тактирование
        input  logic                                    reset,
        input  logic                                    clk,
        
        // Разрешение тактирования
        input  logic                                    clkena,
        
        // Вход первого регистра
        input  logic [WIDTH - 1 : 0]                    idat,
        
        // Выход последнего регистра
        output logic [WIDTH - 1 : 0]                    odat,
        
        // Выходы всех регистров
        output logic [LENGTH - 1 : 0][WIDTH - 1 : 0]    taps
    ); // the_regchain
*/
module regchain
#(
    parameter int unsigned                          WIDTH    = 16,      // Разрядность каждого регистра
    parameter int unsigned                          LENGTH   = 64       // Количество регистров в цепочке
)
(
    // Сброс и тактирование
    input  logic                                    reset,
    input  logic                                    clk,
    
    // Разрешение тактирования
    input  logic                                    clkena,
    
    // Вход первого регистра
    input  logic [WIDTH - 1 : 0]                    idat,
    
    // Выход последнего регистра
    output logic [WIDTH - 1 : 0]                    odat,
    
    // Выходы всех регистров
    output logic [LENGTH - 1 : 0][WIDTH - 1 : 0]    taps
);
    //------------------------------------------------------------------------------------
    //      Описание цепочки регистров
    reg [LENGTH - 1 : 0][WIDTH - 1 : 0] sr;
    generate
        genvar i;
        for (i = 0; i < LENGTH; i++) begin: sr_gen
            always @(posedge reset, posedge clk)
                if (reset)
                    sr[i] <= '0;
                else if (clkena)
                    sr[i] <= i ? sr[i - 1] : idat;
                else
                    sr[i] <= sr[i];
            assign taps[i] = sr[i];
        end
    endgenerate
    assign odat = sr[LENGTH - 1];
    
endmodule // regchain