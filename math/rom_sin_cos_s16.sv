/*
    //------------------------------------------------------------------------------------
    //      Модуль табличного вычисления значений функций sin(x) и cos(x)
    rom_sin_cos
    #(
        .WIDTH      (), // Разрядность
        .RAMTYPE    ()  // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
    )
    the_rom_sin_cos
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Значение аргумента
        .arg        (), // i  [WIDTH - 1 : 0]
        
        // Значения sin(arg), cos(arg)
        .sin        (), // o  [WIDTH - 1 : 0]
        .cos        ()  // o  [WIDTH - 1 : 0]
    ); // the_rom_sin_cos
*/

`define ROMNAME "sin-1st-quadrant.txt"

module rom_sin_cos
#(
    parameter int unsigned          WIDTH   = 8,        // Разрядность
    parameter string                RAMTYPE = "AUTO"    // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Разрешение тактирования
    input  logic                    clkena,
    
    // Значение аргумента
    input  logic [WIDTH - 1 : 0]    arg,
    
    // Значения sin(arg), cos(arg)
    output logic [WIDTH - 1 : 0]    sin,
    output logic [WIDTH - 1 : 0]    cos
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned AWIDTH  = WIDTH - 2;                    // Разрядность адреса таблицы синусов
    localparam int unsigned FWIDTH  = WIDTH - 1;                    // Разрядность значений в таблице синусов
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [AWIDTH - 1 : 0]  sin_addr_reg;
    logic [AWIDTH - 1 : 0]  cos_addr_reg;
    logic                   sin_sign_reg;
    logic                   cos_sign_reg;
    logic                   sin_corr_reg;
    logic                   cos_corr_reg;
    logic [FWIDTH - 1 : 0]  sin_value;
    logic [FWIDTH - 1 : 0]  cos_value;
    logic [WIDTH - 1 : 0]   sin_reg;
    logic [WIDTH - 1 : 0]   cos_reg;
    
    //------------------------------------------------------------------------------------
    //      Описание блока памяти с учетом атрибутов Altera
    (* ramstyle = RAMTYPE *) reg [FWIDTH - 1 : 0] lut [2**AWIDTH - 1 : 0];
    initial $readmemh(`ROMNAME, lut);
    
    //------------------------------------------------------------------------------------
    //      Регистр адреса значения синуса
    always @(posedge reset, posedge clk)
        if (reset)
            sin_addr_reg <= '0;
        else if (clkena)
            sin_addr_reg <= ({AWIDTH{arg[AWIDTH]}} ^ arg[AWIDTH - 1 : 0]) + {{AWIDTH - 1{1'b0}}, arg[AWIDTH]};
        else
            sin_addr_reg <= sin_addr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр адреса значения косинуса
    always @(posedge reset, posedge clk)
        if (reset)
            cos_addr_reg <= '0;
        else if (clkena)
            cos_addr_reg <= ({AWIDTH{~arg[AWIDTH]}} ^ arg[AWIDTH - 1 : 0]) + {{AWIDTH - 1{1'b0}}, ~arg[AWIDTH]};
        else
            cos_addr_reg <= cos_addr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр знака синуса
    always @(posedge reset, posedge clk)
        if (reset)
            sin_sign_reg <= '0;
        else if (clkena)
            sin_sign_reg <= arg[AWIDTH + 1] & (arg[AWIDTH : 0] != 0);
        else
            sin_sign_reg <= sin_sign_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр знака синуса
    always @(posedge reset, posedge clk)
        if (reset)
            cos_sign_reg <= '0;
        else if (clkena)
            cos_sign_reg <= ((arg[AWIDTH + 1 : AWIDTH] == 2'b01) & (arg[AWIDTH - 1 : 0] != 0)) | (arg[AWIDTH + 1 : AWIDTH] == 2'b10);
        else
            cos_sign_reg <= cos_sign_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака коррекции значения синуса
    always @(posedge reset, posedge clk)
        if (reset)
            sin_corr_reg <= '0;
        else if (clkena)
            sin_corr_reg <= arg[AWIDTH] & (arg[AWIDTH - 1 : 0] == 0);
        else
            sin_corr_reg <= sin_corr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака коррекции значения косинуса
    always @(posedge reset, posedge clk)
        if (reset)
            cos_corr_reg <= '0;
        else if (clkena)
            cos_corr_reg <= ~arg[AWIDTH] & (arg[AWIDTH - 1 : 0] == 0);
        else
            cos_corr_reg <= cos_corr_reg;
    
    //------------------------------------------------------------------------------------
    //      Табличные значения синуса и косинуса
    assign sin_value = lut[sin_addr_reg];
    assign cos_value = lut[cos_addr_reg];
    
    //------------------------------------------------------------------------------------
    //      Регистр выходного значения синуса
    always @(posedge reset, posedge clk)
        if (reset)
            sin_reg <= '0;
        else if (clkena)
            sin_reg <= {sin_sign_reg, ((sin_value | {FWIDTH{sin_corr_reg}}) ^ {FWIDTH{sin_sign_reg}}) + {{FWIDTH - 1{1'b0}}, sin_sign_reg}};
        else
            sin_reg <= sin_reg;
    assign sin = sin_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр выходного значения косинуса
    always @(posedge reset, posedge clk)
        if (reset)
            cos_reg <= '0;
        else if (clkena)
            cos_reg <= {cos_sign_reg, ((cos_value | {FWIDTH{cos_corr_reg}}) ^ {FWIDTH{cos_sign_reg}}) + {{FWIDTH - 1{1'b0}}, cos_sign_reg}};
        else
            cos_reg <= cos_reg;
    assign cos = cos_reg;
    
    //------------------------------------------------------------------------------------
    //      Генерация файла значений sin(x) в интервале [0 : PI/2)
    // synthesis translate_off
    localparam real PI2 = 1.57079632679489661923;
    logic [FWIDTH - 1 : 0] wrlut [2**AWIDTH - 1 : 0];
    initial begin
        for (int i = 0; i < 2**AWIDTH; i++) begin
            wrlut[i] = int'($sin(real'(i) / real'(2**AWIDTH) * PI2) * real'(2**FWIDTH - 1));
        end
        $writememh(`ROMNAME, wrlut);
    end
    // synthesis translate_on
    
endmodule: rom_sin_cos