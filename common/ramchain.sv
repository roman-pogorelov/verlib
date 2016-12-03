module ramchain
#(
    parameter int unsigned                          WIDTH    = 16,      // Разрядность ячейки памяти
    parameter int unsigned                          LENGTH   = 64,      // Количество ячеек памяти в цепочке
    parameter string                                RAMTYPE  = "AUTO"   // Тип ресурса памяти ("AUTO", "M10K, "LOGIC", ...)
)
(
    // Тактирование
    input  logic                                    clk,
    
    // Разрешение тактирования
    input  logic                                    clkena,
    
    // Вход первой ячейки памяти
    input  logic [WIDTH - 1 : 0]                    idat,
    
    // Выход последней ячейки памяти
    output logic [WIDTH - 1 : 0]                    odat,
    
    // Выходы всех ячеек памяти
    output logic [LENGTH - 1 : 0][WIDTH - 1 : 0]    taps
);
    //------------------------------------------------------------------------------------
    //      Атрибут, задающий тип ресурса памяти Altera
    localparam string RAMSTYLE = {"no_rw_check, ", RAMTYPE};
    
    //------------------------------------------------------------------------------------
    //      Описание блока памяти с учетом атрибутов Altera
    (* ramstyle = RAMSTYLE *) reg [WIDTH - 1 : 0] sr [LENGTH - 1 : 0];
    generate
        genvar i;
        for (i = 0; i < LENGTH; i++) begin: sr_gen
            always @(posedge clk)
                if (clkena) begin
                    sr[i] <= i ? sr[i - 1] : idat;
                end
            assign taps[i] = sr[i];
        end
    endgenerate
    assign odat = sr[LENGTH - 1];
    
endmodule // ramchain