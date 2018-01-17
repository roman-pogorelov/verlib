/*
    //------------------------------------------------------------------------------------
    //      Модуль табличного вычисления значений функций sin(x) и cos(x) двух
    //      независимых аргументов с описанием блоков памяти через мега-функцию Altera
    //          func0 = sin(arg0), если mode0 = 0;
    //          func0 = cos(arg0), если mode0 = 1;
    //          func1 = sin(arg1), если mode1 = 0;
    //          func1 = cos(arg1), если mode1 = 1;
    //      Латентность модуля - 4 такта
    alt_rom_sin_two_arg
    #(
        .WIDTH      (), // Разрядность
        .HEXFILE    ()  // HEX-файл с предварительно расчитанный таблицей синусов
    )
    the_alt_rom_sin_two_arg
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Значение аргументов
        .arg0       (), // i  [WIDTH - 1 : 0]
        .arg1       (), // i  [WIDTH - 1 : 0]
        
        // Значения режимов
        .mode0      (), // i
        .mode1      (), // i
        
        // Значения тригонометрических функций
        .func0      (), // o  [WIDTH - 1 : 0]
        .func1      ()  // o  [WIDTH - 1 : 0]
    ); // the_alt_rom_sin_two_arg
*/

module alt_rom_sin_two_arg
#(
    parameter int unsigned          WIDTH   = 16,           // Разрядность
    parameter                       HEXFILE = "sin-lut.hex" // HEX-файл с предварительно расчитанный таблицей синусов
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Разрешение тактирования
    input  logic                    clkena,
    
    // Значение аргументов
    input  logic [WIDTH - 1 : 0]    arg0,
    input  logic [WIDTH - 1 : 0]    arg1,
    
    // Значение режимов
    input  logic                    mode0,
    input  logic                    mode1,
    
    // Значения тригонометрических функций
    output logic [WIDTH - 1 : 0]    func0,
    output logic [WIDTH - 1 : 0]    func1
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned AWIDTH  = WIDTH - 2;                    // Разрядность адреса таблицы синусов
    localparam int unsigned FWIDTH  = WIDTH - 1;                    // Разрядность значений в таблице синусов
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [AWIDTH - 1 : 0]  func0_addr_reg;
    logic [AWIDTH - 1 : 0]  func1_addr_reg;
    logic [2 : 0]           mode0_reg;
    logic [2 : 0]           mode1_reg;
    logic [2 : 0]           func0_sign_reg;
    logic [2 : 0]           func1_sign_reg;
    logic [2 : 0]           func0_corr_reg;
    logic [2 : 0]           func1_corr_reg;
    logic [FWIDTH - 1 : 0]  func0_value;
    logic [FWIDTH - 1 : 0]  func1_value;
    logic [WIDTH - 1 : 0]   func0_reg;
    logic [WIDTH - 1 : 0]   func1_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр адреса значения функции #0
    always @(posedge reset, posedge clk)
        if (reset)
            func0_addr_reg <= '0;
        else if (clkena)
            if (mode0)
                func0_addr_reg <= ({AWIDTH{~arg0[AWIDTH]}} ^ arg0[AWIDTH - 1 : 0]) + {{AWIDTH - 1{1'b0}}, ~arg0[AWIDTH]};
            else
                func0_addr_reg <= ({AWIDTH{arg0[AWIDTH]}} ^ arg0[AWIDTH - 1 : 0]) + {{AWIDTH - 1{1'b0}}, arg0[AWIDTH]};
        else
            func0_addr_reg <= func0_addr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр адреса значения функции #1
    always @(posedge reset, posedge clk)
        if (reset)
            func1_addr_reg <= '0;
        else if (clkena)
            if (mode1)
                func1_addr_reg <= ({AWIDTH{~arg1[AWIDTH]}} ^ arg1[AWIDTH - 1 : 0]) + {{AWIDTH - 1{1'b0}}, ~arg1[AWIDTH]};
            else
                func1_addr_reg <= ({AWIDTH{arg1[AWIDTH]}} ^ arg1[AWIDTH - 1 : 0]) + {{AWIDTH - 1{1'b0}}, arg1[AWIDTH]};
        else
            func1_addr_reg <= func1_addr_reg;
    
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
        .init_file                  (HEXFILE),
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
        .address_a                  (func0_addr_reg),
        .address_b                  (func1_addr_reg),
        .addressstall_a             (~clkena),
        .addressstall_b             (~clkena),
        .clocken0                   (clkena),
        .data_a                     ({FWIDTH{1'b0}}),
        .data_b                     ({FWIDTH{1'b0}}),
        .wren_a                     (1'b0),
        .wren_b                     (1'b0),
        .q_a                        (func0_value),
        .q_b                        (func1_value)
    ); // sin_lut_rom
    
    //------------------------------------------------------------------------------------
    //      Регистр режима вычисления функции #0
    always @(posedge reset, posedge clk)
        if (reset)
            mode0_reg <= '0;
        else if (clkena)
            mode0_reg <= {mode0_reg[$high(mode0_reg) - 1 : 0], mode0};
        else
            mode0_reg <= mode0_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр режима вычисления функции #1
    always @(posedge reset, posedge clk)
        if (reset)
            mode1_reg <= '0;
        else if (clkena)
            mode1_reg <= {mode1_reg[$high(mode1_reg) - 1 : 0], mode1};
        else
            mode1_reg <= mode1_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр знака функции #0
    always @(posedge reset, posedge clk)
        if (reset)
            func0_sign_reg <= '0;
        else if (clkena)
            if (mode0)
                func0_sign_reg <=
                {
                    func0_sign_reg[$high(func0_sign_reg) - 1 : 0],
                    ((arg0[AWIDTH + 1 : AWIDTH] == 2'b01) & (arg0[AWIDTH - 1 : 0] != 0)) | (arg0[AWIDTH + 1 : AWIDTH] == 2'b10)
                };
            else
                func0_sign_reg <=
                {
                    func0_sign_reg[$high(func0_sign_reg) - 1 : 0],
                    arg0[AWIDTH + 1] & (arg0[AWIDTH : 0] != 0)
                };
        else
            func0_sign_reg <= func0_sign_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр знака функции #0
    always @(posedge reset, posedge clk)
        if (reset)
            func1_sign_reg <= '0;
        else if (clkena)
            if (mode1)
                func1_sign_reg <=
                {
                    func1_sign_reg[$high(func1_sign_reg) - 1 : 0],
                    ((arg1[AWIDTH + 1 : AWIDTH] == 2'b01) & (arg1[AWIDTH - 1 : 0] != 0)) | (arg1[AWIDTH + 1 : AWIDTH] == 2'b10)
                };
            else
                func1_sign_reg <=
                {
                    func1_sign_reg[$high(func1_sign_reg) - 1 : 0],
                    arg1[AWIDTH + 1] & (arg1[AWIDTH : 0] != 0)
                };
        else
            func1_sign_reg <= func1_sign_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака коррекции значения функции #0
    always @(posedge reset, posedge clk)
        if (reset)
            func0_corr_reg <= '0;
        else if (clkena)
            if (mode0)
                func0_corr_reg <=
                {
                    func0_corr_reg[$high(func0_corr_reg) - 1 : 0],
                    ~arg0[AWIDTH] & (arg0[AWIDTH - 1 : 0] == 0)
                };
            else
                func0_corr_reg <=
                {
                    func0_corr_reg[$high(func0_corr_reg) - 1 : 0],
                    arg0[AWIDTH] & (arg0[AWIDTH - 1 : 0] == 0)
                };
        else
            func0_corr_reg <= func0_corr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака коррекции значения функции #1
    always @(posedge reset, posedge clk)
        if (reset)
            func1_corr_reg <= '0;
        else if (clkena)
            if (mode1)
                func1_corr_reg <=
                {
                    func1_corr_reg[$high(func1_corr_reg) - 1 : 0],
                    ~arg1[AWIDTH] & (arg1[AWIDTH - 1 : 0] == 0)
                };
            else
                func1_corr_reg <=
                {
                    func1_corr_reg[$high(func1_corr_reg) - 1 : 0],
                    arg1[AWIDTH] & (arg1[AWIDTH - 1 : 0] == 0)
                };
        else
            func1_corr_reg <= func1_corr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр выходного значения функции #0
    always @(posedge reset, posedge clk)
        if (reset)
            func0_reg <= '0;
        else if (clkena)
            if (mode0_reg[$high(mode0_reg)])
                func0_reg <=
                {
                    func0_sign_reg[$high(func0_sign_reg)],
                    ((func0_value | {FWIDTH{func0_corr_reg[$high(func0_corr_reg)]}}) ^ {FWIDTH{func0_sign_reg[$high(func0_sign_reg)]}}) + {{FWIDTH - 1{1'b0}}, func0_sign_reg[$high(func0_sign_reg)]}
                };
            else
                func0_reg <=
                {
                    func0_sign_reg[$high(func0_sign_reg)],
                    ((func0_value | {FWIDTH{func0_corr_reg[$high(func0_corr_reg)]}}) ^ {FWIDTH{func0_sign_reg[$high(func0_sign_reg)]}}) + {{FWIDTH - 1{1'b0}}, func0_sign_reg[$high(func0_sign_reg)]}
                };
        else
            func0_reg <= func0_reg;
    assign func0 = func0_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр выходного значения функции #1
    always @(posedge reset, posedge clk)
        if (reset)
            func1_reg <= '0;
        else if (clkena)
            if (mode1_reg[$high(mode1_reg)])
                func1_reg <=
                {
                    func1_sign_reg[$high(func1_sign_reg)],
                    ((func1_value | {FWIDTH{func1_corr_reg[$high(func1_corr_reg)]}}) ^ {FWIDTH{func1_sign_reg[$high(func1_sign_reg)]}}) + {{FWIDTH - 1{1'b0}}, func1_sign_reg[$high(func1_sign_reg)]}
                };
            else
                func1_reg <=
                {
                    func1_sign_reg[$high(func1_sign_reg)],
                    ((func1_value | {FWIDTH{func1_corr_reg[$high(func1_corr_reg)]}}) ^ {FWIDTH{func1_sign_reg[$high(func1_sign_reg)]}}) + {{FWIDTH - 1{1'b0}}, func1_sign_reg[$high(func1_sign_reg)]}
                };
        else
            func1_reg <= func1_reg;
    assign func1 = func1_reg;
    
endmodule: alt_rom_sin_two_arg