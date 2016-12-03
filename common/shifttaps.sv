/*
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр на памяти с множественными ответвлениями
    shifttaps
    #(
        .WIDTH      (), // Разрядность
        .DISTANCE   (), // Растояние между двумя ответвлениями
        .COUNT      (), // Количество ответвлений
        .RAMTYPE    ()  // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
    )
    the_shifttaps
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Вход
        .idat       (), // i  [WIDTH - 1 : 0]
        
        // Выход
        .odat       (), // o  [WIDTH - 1 : 0]
        
        // Ответвления
        .taps       ()  // o  [COUNT*WIDTH - 1 : 0]
    ); // the_shifttaps
*/
module shifttaps
#(
    parameter int unsigned              WIDTH    = 16,      // Разрядность
    parameter int unsigned              DISTANCE = 64,      // Растояние между двумя ответвлениями
    parameter int unsigned              COUNT    = 101,     // Количество ответвлений
    parameter string                    RAMTYPE  = "MLAB"   // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
)
(
    // Сброс и тактирование
    input  logic                        reset,
    input  logic                        clk,
    
    // Разрешение тактирования
    input  logic                        clkena,
    
    // Вход
    input  logic [WIDTH - 1 : 0]        idat,
    
    // Выход
    output logic [WIDTH - 1 : 0]        odat,
    
    // Ответвления
    output logic [COUNT*WIDTH - 1 : 0]  taps
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [COUNT - 1 : 0][WIDTH - 1 : 0] taps_int;
    
    //------------------------------------------------------------------------------------
    //      Генерация необходимого количества сдвиговых регистров
    generate
        genvar i;
        for (i = 0; i < COUNT; i++) begin: taps_gen
            
            //------------------------------------------------------------------------------------
            //      Сдвиговый регистр с одним ответвлением в конце
            one_shifttap
            #(
                .WIDTH      (WIDTH),        // Разрядность
                .LENGTH     (DISTANCE),     // Растояние между двумя ответвлениями
                .RAMTYPE    (RAMTYPE)       // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
            )
            the_one_shifttap
            (
                // Сброс и тактирование
                .reset      (reset),
                .clk        (clk),
                
                // Разрешение тактирования
                .clkena     (clkena),
                
                // Вход
                .idat       (i ? taps_int[i - 1] : idat),
                
                // Выход
                .odat       (taps_int[i])
            ); // the_one_shifttap
            
            //------------------------------------------------------------------------------------
            //      Ответвления
            assign taps[(i + 1)*WIDTH - 1 : i*WIDTH] = taps_int[i];
        end
        
        //------------------------------------------------------------------------------------
        //      Выход
        assign odat = taps_int[COUNT - 1];
    endgenerate
    
endmodule // shifttaps

/*
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр на памяти с одним ответвлением в конце
    one_shifttap
    #(
        .WIDTH      (), // Разрядность
        .LENGTH     (), // Растояние между двумя ответвлениями
        .RAMTYPE    ()  // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
    )
    the_one_shifttap
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Вход
        .idat       (), // i  [WIDTH - 1 : 0]
        
        // Выход
        .odat       ()  // o  [WIDTH - 1 : 0]
    ); // the_one_shifttap
*/
module one_shifttap
#(
    parameter int unsigned              WIDTH    = 16,      // Разрядность
    parameter int unsigned              LENGTH   = 64,      // Растояние между двумя ответвлениями
    parameter string                    RAMTYPE  = "AUTO"   // Тип ресурса ("AUTO", "M10K, "LOGIC", ...)
)
(
    // Сброс и тактирование
    input  logic                        reset,
    input  logic                        clk,
    
    // Разрешение тактирования
    input  logic                        clkena,
    
    // Вход
    input  logic [WIDTH - 1 : 0]        idat,
    
    // Выход
    output logic [WIDTH - 1 : 0]        odat
);
    //------------------------------------------------------------------------------------
    //      Атрибут, задающий тип ресурса памяти Altera
    localparam string RAMSTYLE = {"no_rw_check, ", RAMTYPE};
    
    //------------------------------------------------------------------------------------
    //      Описание блока памяти с учетом атрибутов Altera
    (* ramstyle = RAMSTYLE *) reg [WIDTH - 1 : 0] sr [LENGTH - 1 : 0];
    
    //------------------------------------------------------------------------------------
    //      Блок памяти
    always @(posedge clk)
        if (clkena) begin
            for (int i = 0; i < LENGTH; i++) begin
                sr[i] <= i ? sr[i - 1] : idat;
            end
        end
    assign odat = sr[LENGTH - 1];
    
endmodule // one_shifttap