/*
    //------------------------------------------------------------------------------------
    //      Вычислительное ядро, выполняющее одну итерацию CORDIC-алгоритма
    cordic_core
    #(
        .WIDTH      ()  // Разрядность
    )
    the_cordic_core
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Параметры управления
        .init       (), // i
        .loop       (), // i
        .shift      (), // i  [WIDTH - 1 : 0]
        .alpha      (), // i  [WIDTH - 1 : 0]
        
        // Входные данные
        .i_x        (), // i  [WIDTH - 1 : 0]
        .i_y        (), // i  [WIDTH - 1 : 0]
        .i_z        (), // i  [WIDTH - 1 : 0]
        
        // Выходные данные
        .o_x        (), // o  [WIDTH - 1 : 0]
        .o_y        (), // o  [WIDTH - 1 : 0]
        .o_z        ()  // o  [WIDTH - 1 : 0]
    ); // the_cordic_core
*/

module cordic_core
#(
    parameter int unsigned                  WIDTH = 8   // Разрядность
)
(
    // Сброс и тактирование
    input  logic                            reset,
    input  logic                            clk,
    
    // Разрешение тактирования
    input  logic                            clkena,
    
    // Параметры управления
    input  logic                            init,
    input  logic                            loop,
    input  logic [$clog2(WIDTH) - 1 : 0]    shift,
    input  logic [WIDTH - 1 : 0]            alpha,
    
    // Входные данные
    input  logic [WIDTH - 1 : 0]            i_x,
    input  logic [WIDTH - 1 : 0]            i_y,
    input  logic [WIDTH - 1 : 0]            i_z,
    
    // Выходные данные
    output logic [WIDTH - 1 : 0]            o_x,
    output logic [WIDTH - 1 : 0]            o_y,
    output logic [WIDTH - 1 : 0]            o_z
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [WIDTH - 1 : 0]           x;
    logic [WIDTH - 1 : 0]           y;
    logic [WIDTH - 1 : 0]           z;
    logic                           selector;
    logic [WIDTH - 1 : 0]           x_shifted;
    logic [WIDTH - 1 : 0]           y_shifted;
    logic [WIDTH - 1 : 0]           x_reg;
    logic [WIDTH - 1 : 0]           y_reg;
    logic [WIDTH - 1 : 0]           z_reg;
    
    //------------------------------------------------------------------------------------
    //      Мультиплексирование входных и накопленных значений
    assign x = loop ? x_reg : i_x;
    assign y = loop ? y_reg : i_y;
    assign z = loop ? z_reg : i_z;
    
    //------------------------------------------------------------------------------------
    //      Сигнал выбора  текущего направления поворота
    assign selector = z[WIDTH - 1];
    
    //------------------------------------------------------------------------------------
    //      Сдвинутые значения входных координат
    assign x_shifted = $signed(x) >>> shift;
    assign y_shifted = $signed(y) >>> shift;
    
    //------------------------------------------------------------------------------------
    //      Регист следующего значения X-координаты
    always @(posedge reset, posedge clk)
        if (reset)
            x_reg <= '0;
        else if (clkena)
            //x_reg <= x + ((selector ? +y_shifted : -y_shifted) & {WIDTH{~init}});
            if (init)
                x_reg <= i_x;
            else
                x_reg <= x + (selector ? +y_shifted : -y_shifted);
        else
            x_reg <= x_reg;
    assign o_x = x_reg;
    
    //------------------------------------------------------------------------------------
    //      Регист следующего значения Y-координаты
    always @(posedge reset, posedge clk)
        if (reset)
            y_reg <= '0;
        else if (clkena)
            //y_reg <= y + ((selector ? -x_shifted : +x_shifted) & {WIDTH{~init}});
            if (init)
                y_reg <= i_y;
            else
                y_reg <= y + (selector ? -x_shifted : +x_shifted);
        else
            y_reg <= y_reg;
    assign o_y = y_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр следующего значения угла поворота
    always @(posedge reset, posedge clk)
        if (reset)
            z_reg <= '0;
        else if (clkena)
            //z_reg <= z + ((selector ? +alpha : -alpha) & {WIDTH{~init}});
            if (init)
                z_reg <= i_z;
            else
                z_reg <= z + (selector ? +alpha : -alpha);
        else
            z_reg <= z_reg;
    assign o_z = z_reg;
    
endmodule: cordic_core