/*
    //------------------------------------------------------------------------------------
    //      Древовидный конвейерный сумматор с латентностью clog2(INPUTS)
    add_tree
    #(
        .WIDTH      (), // Разрядность входных данных
        .INPUTS     ()  // Количество входов (слагаемых)
    )
    the_add_tree
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Входные данные
        .i_signed   (), // i
        .i_data     (), // i  [INPUTS - 1 : 0][WIDTH - 1 : 0]
        
        // Выходные данные
        .o_signed   (), // o
        .o_data     ()  // o  [WIDTH + $clog2(INPUTS) - 1 : 0]
    ); // the_add_tree
*/

module add_tree
#(
    parameter int unsigned                          WIDTH   = 8,                // Разрядность входных данных
    parameter int unsigned                          INPUTS  = 5                 // Количество входов (слагаемых)
)
(
    // Сброс и тактирование
    input  logic                                    reset,
    input  logic                                    clk,
    
    // Разрешение тактирования
    input  logic                                    clkena,
    
    // Входные данные
    input  logic                                    i_signed,
    input  logic [INPUTS - 1 : 0][WIDTH - 1 : 0]    i_data,
    
    // Выходные данные
    output logic                                    o_signed,
    output logic [WIDTH + $clog2(INPUTS) - 1 : 0]   o_data
);
    generate
        if (INPUTS > 1) begin
            //------------------------------------------------------------------------------------
            //      Выход ступени древовидного конвейерного сумматора    
            logic [(INPUTS + 1)/2 - 1 : 0][WIDTH : 0]   layer_o_data;
            logic                                       layer_o_signed;

            //------------------------------------------------------------------------------------
            //      Ступень древовидного конвейерного сумматора    
            add_tree_layer
            #(
                .WIDTH      (WIDTH),            // Разрядность входных данных
                .INPUTS     (INPUTS)            // Количество входов (слагаемых)
            )
            the_add_tree_layer
            (
                // Сброс и тактирование
                .reset      (reset),            // i
                .clk        (clk),              // i
                
                // Разрешение тактирования
                .clkena     (clkena),           // i
                
                // Входные данные
                .i_signed   (i_signed),         // i
                .i_data     (i_data),           // i  [INPUTS - 1 : 0][WIDTH - 1 : 0]
                
                // Выходные данные
                .o_signed   (layer_o_signed),   // o
                .o_data     (layer_o_data)      // o  [OUTPUTS - 1 : 0][WIDTH : 0]
            ); // the_add_tree_layer

            //------------------------------------------------------------------------------------
            //      Древовидный конвейерный сумматор
            add_tree
            #(
                .WIDTH      (WIDTH + 1),        // Разрядность входных данных
                .INPUTS     ((INPUTS + 1) / 2)  // Количество входов (слагаемых)
            )
            add_tree_recursion
            (
                // Сброс и тактирование
                .reset      (reset),            // i
                .clk        (clk),              // i
                
                // Разрешение тактирования
                .clkena     (clkena),           // i
                
                // Входные данные
                .i_signed    (layer_o_signed),  // i
                .i_data      (layer_o_data),    // i  [INPUTS - 1 : 0][WIDTH - 1 : 0]
                
                // Выходные данные
                .o_signed    (o_signed),        // o
                .o_data      (o_data)           // o  [WIDTH + $clog2(INPUTS) - 1 : 0]
            ); // add_tree_recursion
        end
        else begin
            assign o_data = i_data;
            assign o_signed = i_signed;
        end
    endgenerate

endmodule: add_tree

/*
    //------------------------------------------------------------------------------------
    //      Ступень древовидного конвейерного сумматора
    add_tree_layer
    #(
        .WIDTH      (), // Разрядность входных данных
        .INPUTS     ()  // Количество входов (слагаемых)
    )
    the_add_tree_layer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Входные данные
        .i_signed   (), // i
        .i_data     (), // i  [INPUTS - 1 : 0][WIDTH - 1 : 0]
        
        // Выходные данные
        .o_signed   (), // o
        .o_data     ()  // o  [OUTPUTS - 1 : 0][WIDTH : 0]
    ); // the_add_tree_layer
*/

module add_tree_layer
#(
    parameter int unsigned                          WIDTH   = 8,                // Разрядность входных данных
    parameter int unsigned                          INPUTS  = 5,                // Количество входов (слагаемых)
    parameter int unsigned                          OUTPUTS = (INPUTS + 1)/2    // Количество выходов (частных сумм) 
)
(
    // Сброс и тактирование
    input  logic                                    reset,
    input  logic                                    clk,
    
    // Разрешение тактирования
    input  logic                                    clkena,
    
    // Входные данные
    input  logic                                    i_signed,
    input  logic [INPUTS - 1 : 0][WIDTH - 1 : 0]    i_data,
    
    // Выходные данные
    output logic                                    o_signed,
    output logic [OUTPUTS - 1 : 0][WIDTH : 0]       o_data
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [OUTPUTS - 1 : 0][WIDTH : 0]              sum;        // Частные суммы
    logic [OUTPUTS - 1 : 0][WIDTH : 0]              sum_reg;    // Регистры частных сумм
    logic                                           signed_reg; // Регистр признака знакового представления
    
    generate
        genvar i;
        for (i = 0 ; i < OUTPUTS; i++) begin: sumreg_gen
            //------------------------------------------------------------------------------------
            //      Частные суммы
            if ((i == (OUTPUTS - 1)) & INPUTS[0])
                assign sum[i] = {i_signed ? i_data[2*i][WIDTH - 1] : 1'b0, i_data[2*i]};
            else
                assign sum[i] = {i_signed ? i_data[2*i][WIDTH - 1] : 1'b0, i_data[2*i]} + {i_signed ? i_data[2*i + 1][WIDTH - 1] : 1'b0, i_data[2*i + 1]};
            
            //------------------------------------------------------------------------------------
            //      Регистры частных сумм
            always @(posedge reset, posedge clk)
                if (reset)
                    sum_reg[i] <= '0;
                else if (clkena)
                    sum_reg[i] <= sum[i];
                else
                    sum_reg[i] <= sum_reg[i];

            //------------------------------------------------------------------------------------
            //      Выходные данные
            assign o_data[i] = sum_reg[i];
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Регистр признака знакового представления
    always @(posedge reset, posedge clk)
        if (reset)
            signed_reg <= '0;
        else if (clkena)
            signed_reg <= i_signed;
        else
            signed_reg <= signed_reg;
    assign o_signed = signed_reg;
endmodule: add_tree_layer
