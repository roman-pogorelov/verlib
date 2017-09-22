/*
    //------------------------------------------------------------------------------------
    //      Модуль табличного вычисления значений функций sin(x) и cos(x) с
    //      описанием блоков памяти через мега-функцию Altera
    alt_rom_sin_cos
    #(
        .WIDTH      (), // Разрядность
        .HEXNAME    ()  // HEX-файл с предварительно расчитанный таблицей синусов
    )
    the_alt_rom_sin_cos
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Значение аргумента
        .arg        (), // i  [WIDTH - 1 : 0]
        
        // Значения функций с латентностью 4 такта
        .sin        (), // o  [WIDTH - 1 : 0]
        .cos        ()  // o  [WIDTH - 1 : 0]
    ); // the_alt_rom_sin_cos
*/

module alt_rom_sin_cos
#(
    parameter int unsigned          WIDTH   = 16,           // Разрядность
    parameter                       HEXNAME = "sin-lut.hex" // HEX-файл с предварительно расчитанный таблицей синусов
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Разрешение тактирования
    input  logic                    clkena,
    
    // Значение аргумента
    input  logic [WIDTH - 1 : 0]    arg,
    
    // Значения функций с латентностью 4 такта
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
    logic [2 : 0]           sin_sign_reg;
    logic [2 : 0]           cos_sign_reg;
    logic [2 : 0]           sin_corr_reg;
    logic [2 : 0]           cos_corr_reg;
    logic [FWIDTH - 1 : 0]  sin_value;
    logic [FWIDTH - 1 : 0]  cos_value;
    logic [WIDTH - 1 : 0]   sin_reg;
    logic [WIDTH - 1 : 0]   cos_reg;
    
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
    //      Блок памяти с таблицей синусов
    altsyncram
    #(
        .address_reg_b              ("CLOCK0"),
        .clock_enable_input_a       ("NORMAL"),
        .clock_enable_input_b       ("NORMAL"),
        .clock_enable_output_a      ("NORMAL"),
        .clock_enable_output_b      ("NORMAL"),
        .indata_reg_b               ("CLOCK0"),
        .init_file                  (HEXNAME),
        .lpm_type                   ("altsyncram"),
        .numwords_a                 (2**AWIDTH),
        .numwords_b                 (2**AWIDTH),
        .operation_mode             ("BIDIR_DUAL_PORT"),
        .outdata_aclr_a             ("CLEAR0"),
        .outdata_aclr_b             ("CLEAR0"),
        .outdata_reg_a              ("CLOCK0"),
        .outdata_reg_b              ("CLOCK0"),
        .power_up_uninitialized     ("FALSE"),
        .widthad_a                  (AWIDTH),
        .widthad_b                  (AWIDTH),
        .width_a                    (FWIDTH),
        .width_b                    (FWIDTH),
        .width_byteena_a            (1),
        .width_byteena_b            (1),
        .wrcontrol_wraddress_reg_b  ("CLOCK0")
    )
    sin_lut_rom
    (
        .aclr0                      (reset),
        .clock0                     (clk),
        .address_a                  (sin_addr_reg),
        .address_b                  (cos_addr_reg),
        .addressstall_a             (~clkena),
        .addressstall_b             (~clkena),
        .clocken0                   (clkena),
        .data_a                     ({FWIDTH{1'b0}}),
        .data_b                     ({FWIDTH{1'b0}}),
        .wren_a                     (1'b0),
        .wren_b                     (1'b0),
        .q_a                        (sin_value),
        .q_b                        (cos_value)
    ); // sin_lut_rom
    
    //------------------------------------------------------------------------------------
    //      Регистр знака синуса
    always @(posedge reset, posedge clk)
        if (reset)
            sin_sign_reg <= '0;
        else if (clkena)
            sin_sign_reg <=
            {
                sin_sign_reg[$high(sin_sign_reg) - 1 : 0],
                arg[AWIDTH + 1] & (arg[AWIDTH : 0] != 0)
            };
        else
            sin_sign_reg <= sin_sign_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр знака синуса
    always @(posedge reset, posedge clk)
        if (reset)
            cos_sign_reg <= '0;
        else if (clkena)
            cos_sign_reg <=
            {
                cos_sign_reg[$high(cos_sign_reg) - 1 : 0],
                ((arg[AWIDTH + 1 : AWIDTH] == 2'b01) & (arg[AWIDTH - 1 : 0] != 0)) | (arg[AWIDTH + 1 : AWIDTH] == 2'b10)
            };
        else
            cos_sign_reg <= cos_sign_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака коррекции значения синуса
    always @(posedge reset, posedge clk)
        if (reset)
            sin_corr_reg <= '0;
        else if (clkena)
            sin_corr_reg <=
            {
                sin_corr_reg[$high(sin_corr_reg) - 1 : 0],
                arg[AWIDTH] & (arg[AWIDTH - 1 : 0] == 0)
            };
        else
            sin_corr_reg <= sin_corr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака коррекции значения косинуса
    always @(posedge reset, posedge clk)
        if (reset)
            cos_corr_reg <= '0;
        else if (clkena)
            cos_corr_reg <=
            {
                cos_corr_reg[$high(cos_corr_reg) - 1 : 0],
                ~arg[AWIDTH] & (arg[AWIDTH - 1 : 0] == 0)
            };
        else
            cos_corr_reg <= cos_corr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр выходного значения синуса
    always @(posedge reset, posedge clk)
        if (reset)
            sin_reg <= '0;
        else if (clkena)
            sin_reg <=
            {
                sin_sign_reg[$high(sin_sign_reg)],
                ((sin_value | {FWIDTH{sin_corr_reg[$high(sin_corr_reg)]}}) ^ {FWIDTH{sin_sign_reg[$high(sin_sign_reg)]}}) + {{FWIDTH - 1{1'b0}}, sin_sign_reg[$high(sin_sign_reg)]}
            };
        else
            sin_reg <= sin_reg;
    assign sin = sin_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр выходного значения косинуса
    always @(posedge reset, posedge clk)
        if (reset)
            cos_reg <= '0;
        else if (clkena)
            cos_reg <=
            {
                cos_sign_reg[$high(cos_sign_reg)],
                ((cos_value | {FWIDTH{cos_corr_reg[$high(cos_corr_reg)]}}) ^ {FWIDTH{cos_sign_reg[$high(cos_sign_reg)]}}) + {{FWIDTH - 1{1'b0}}, cos_sign_reg[$high(cos_sign_reg)]}
            };
        else
            cos_reg <= cos_reg;
    assign cos = cos_reg;
    
endmodule: alt_rom_sin_cos