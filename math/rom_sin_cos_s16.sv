module rom_sin_cos_s16
(
    // Сброс и тактирование
    input  logic            reset,
    input  logic            clk,
    
    // Разрешение тактирования
    input  logic            clkena,
    
    // Значение аргумента
    input  logic [15 : 0]   arg,
    
    // Значения sin(arg), cos(arg)
    output logic [15 : 0]   sin,
    output logic [15 : 0]   cos
);
    
    
    
    //------------------------------------------------------------------------------------
    //      Генерация файла значений sin(x) в интервале [0 : PI/2)
    
    // synthesis translate_off
    localparam int unsigned ARGWIDTH    = $size(arg) - 2;
    localparam int unsigned FUNCWIDTH   = $size(sin) - 1;
    localparam real         PI2         = 1.57079632679489661923;
    logic [FUNCWIDTH - 1 : 0] sinlut [2**ARGWIDTH - 1 : 0];
    initial begin
        for (int i = 0; i < 2**ARGWIDTH; i++) begin
            sinlut[i] = int'($sin(real'(i) / real'(2**ARGWIDTH) * PI2) * real'(2**FUNCWIDTH - 1));
        end
        $writememh("sin-1st-quadrant-13-15.txt", sinlut);
    end
    // synthesis translate_on
    
endmodule: rom_sin_cos_s16