/*
    //------------------------------------------------------------------------------------
    //      Модуль округления чисел в формате с фиксированной точкой методом
    //      "до ближайшего целого". 
    fixed_rounder
    #(
        .IWIDTH     (), // Разрядность входных данных
        .OWIDTH     (), // Разрядность выходных данных
        .PIPELINE   ()  // Глубина конвейеризации
    )
    the_fixed_rounder
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Входные данные
        .i_signed   (), // i                    // Признак знакового представления
        .i_data     (), // i  [IWIDTH - 1 : 0]
        
        // Выходные данные
        .o_signed   (), // o
        .o_data     ()  // o  [OWIDTH - 1 : 0]
    ); // the_fixed_rounder
*/

module fixed_rounder
#(
    parameter int unsigned          IWIDTH   = 16,  // Разрядность входных данных
    parameter int unsigned          OWIDTH   = 10,  // Разрядность выходных данных
    parameter int unsigned          PIPELINE = 1    // Глубина конвейеризации
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Разрешение тактирования
    input  logic                    clkena,
    
    // Входные данные
    input  logic                    i_signed,       // Признак знакового представления
    input  logic [IWIDTH - 1 : 0]   i_data,
    
    // Выходные данные
    output logic                    o_signed,
    output logic [OWIDTH - 1 : 0]   o_data
);

    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int signed  WIDTH_DIFF = IWIDTH - OWIDTH;

    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                   u_addbit;
    logic                   s_addbit;
    logic [OWIDTH - 1 : 0]  truncated;
    logic                   result_signed;
    logic [OWIDTH - 1 : 0]  result;
    
    //------------------------------------------------------------------------------------
    //      Разряд округления для беззнакового представления
    generate
        if (WIDTH_DIFF > 0)
            assign u_addbit = i_data[WIDTH_DIFF - 1] & ~(&i_data[IWIDTH - 1 : WIDTH_DIFF]);
        else
            assign u_addbit = 1'b0;
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Разряд округления для знакового представления
    generate
        if (WIDTH_DIFF > 0) begin
            if (WIDTH_DIFF > 1)
                assign s_addbit = i_data[WIDTH_DIFF - 1] & ((~i_data[IWIDTH - 1] & ~(&i_data[IWIDTH - 2 : WIDTH_DIFF])) | (i_data[IWIDTH - 1] & (|i_data[WIDTH_DIFF - 2 : 0])));
            else
                assign s_addbit = i_data[WIDTH_DIFF - 1] &   ~i_data[IWIDTH - 1] & ~(&i_data[IWIDTH - 2 : WIDTH_DIFF]);
        end
        else begin
            assign s_addbit = 1'b0;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Значение, полученное путем отбрасывания разрядов
    generate
        if (WIDTH_DIFF < 0) begin
            assign truncated = {i_data, {-WIDTH_DIFF{1'b0}}};
        end
        else begin
            assign truncated = i_data[IWIDTH - 1 : WIDTH_DIFF];
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Округление с учетом различной глубины конвейеризации
    generate
        // Конвейеризация отсутствует
        if (PIPELINE == 0) begin: no_pipeline
            assign result = truncated + (i_signed ? s_addbit : u_addbit);
            assign result_signed = i_signed;
        end
        
        // Конвейер с глубиной в одну ступень
        else if (PIPELINE == 1) begin: one_stage_pipeline
            logic                   signed_reg;
            logic [OWIDTH - 1 : 0]  data_reg;
            
            // Регистр выходного признака знакового представления
            always @(posedge reset, posedge clk)
                if (reset)
                    signed_reg <= '0;
                else if (clkena)
                    signed_reg <= i_signed;
                else
                    signed_reg <= signed_reg;
            assign result_signed = signed_reg;
            
            // Регистр округленных данных
            always @(posedge reset, posedge clk)
                if (reset)
                    data_reg <= '0;
                else if (clkena)
                    data_reg <= truncated + (i_signed ? s_addbit : u_addbit);
                else
                    data_reg <= data_reg;
            assign result = data_reg;
        end
        
        // Конвейер с глубиной в две ступени
        else if (PIPELINE == 2) begin: two_stages_pipeline
            logic [1 : 0]                   signed_reg;
            logic                           addbit_reg;
            logic [1 : 0][OWIDTH - 1 : 0]   data_reg;
            
            // Регистр выходного признака знакового представления
            always @(posedge reset, posedge clk)
                if (reset)
                    signed_reg <= '0;
                else if (clkena)
                    signed_reg <= {signed_reg[0], i_signed};
                else
                    signed_reg <= signed_reg;
            assign result_signed = signed_reg[1];
            
            // Регистр разряда округления
            always @(posedge reset, posedge clk)
                if (reset)
                    addbit_reg <= '0;
                else if (clkena)
                    addbit_reg <= i_signed ? s_addbit : u_addbit;
                else
                    addbit_reg <= addbit_reg;
            
            // Регистр округленных данных
            always @(posedge reset, posedge clk)
                if (reset)
                    data_reg <= '0;
                else if (clkena)
                    data_reg <= {data_reg[0] + addbit_reg, truncated};
                else
                    data_reg <= data_reg;
            assign result = data_reg[1];
        end
        
        // Конвейер с глубиной в три ступени
        else begin: three_stages_pipeline
            logic [2 : 0]                   signed_reg;
            logic                           u_addbit_reg;
            logic                           s_addbit_reg;
            logic                           addbit_reg;
            logic [2 : 0][OWIDTH - 1 : 0]   data_reg;
            
            // Регистр выходного признака знакового представления
            always @(posedge reset, posedge clk)
                if (reset)
                    signed_reg <= '0;
                else if (clkena)
                    signed_reg <= {signed_reg[1 : 0], i_signed};
                else
                    signed_reg <= signed_reg;
            assign result_signed = signed_reg[2];
            
            // Регистр разряда округления округления для беззнакового представления
            always @(posedge reset, posedge clk)
                if (reset)
                    u_addbit_reg <= '0;
                else if (clkena)
                    u_addbit_reg <= u_addbit;
                else
                    u_addbit_reg <= u_addbit_reg;
            
            // Регистр разряда округления округления для знакового представления
            always @(posedge reset, posedge clk)
                if (reset)
                    s_addbit_reg <= '0;
                else if (clkena)
                    s_addbit_reg <= s_addbit;
                else
                    s_addbit_reg <= s_addbit_reg;
            
            // Регистр разряда округления
            always @(posedge reset, posedge clk)
                if (reset)
                    addbit_reg <= '0;
                else if (clkena)
                    addbit_reg <= signed_reg[0] ? s_addbit_reg : u_addbit_reg;
                else
                    addbit_reg <= addbit_reg;
            
            // Регистр округленных данных
            always @(posedge reset, posedge clk)
                if (reset)
                    data_reg <= '0;
                else if (clkena)
                    data_reg <= {data_reg[1] + addbit_reg, data_reg[0], truncated};
                else
                    data_reg <= data_reg;
            assign result = data_reg[2];
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Дополнительные ступени по выходу
    generate
        if (PIPELINE > 3) begin: extra_stages
            logic [PIPELINE - 4 : 0]                    signed_reg;
            logic [PIPELINE - 4 : 0][OWIDTH - 1 : 0]    data_reg;
            
            // Регистр выходного признака знакового представления
            always @(posedge reset, posedge clk)
                if (reset)
                    signed_reg <= '0;
                else if (clkena)
                    if (PIPELINE > 4)
                        signed_reg <= {signed_reg[PIPELINE - 5 : 0], result_signed};
                    else
                        signed_reg <= result_signed;
                else
                    signed_reg <= signed_reg;
            assign o_signed = signed_reg[PIPELINE - 4];
            
            // Регистр выходных данных
            always @(posedge reset, posedge clk)
                if (reset)
                    data_reg <= '0;
                else if (clkena)
                    if (PIPELINE > 4)
                        data_reg <= {data_reg[PIPELINE - 5 : 0], result};
                    else
                        data_reg <= result;
                else
                    data_reg <= data_reg;
            assign o_data = data_reg[PIPELINE - 4];
        end
        else begin: no_extra_stages
            assign o_signed = result_signed;
            assign o_data = result;
        end
    endgenerate
    
endmodule // fixed_rounder
