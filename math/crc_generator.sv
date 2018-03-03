module crc_generator
#(
    parameter int unsigned              DATAWIDTH   = 8,        // Разрядность данных
    parameter int unsigned              CRCWIDTH    = 16,       // Разрядность CRC
    parameter logic [CRCWIDTH - 1 : 0]  POLYNOMIAL  = 16'h8005, // Порождающий полином
    parameter logic [CRCWIDTH - 1 : 0]  INITCRC     = 16'hFFFF  // Начальное значение
)
(
    // Сброс и тактирование
    input  logic                        reset,
    input  logic                        clk,
    
    // Разрешение тактирования
    input  logic                        clkena,
    
    // Признак инициализации 
    input  logic                        init,
    
    // Интерфейс входных данных
    input  logic [DATAWIDTH - 1 : 0]    data,
    
    // Интерфейс рассчитанной контрольной суммы
    output logic [CRCWIDTH - 1 : 0]     crc_old,
    output logic [CRCWIDTH - 1 : 0]     crc_new
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [CRCWIDTH - 1 : 0]            crc_reg;
    
    //------------------------------------------------------------------------------------
    //      Расчет нового значения CRC
    function automatic logic [CRCWIDTH - 1 : 0] crc_calc(input  logic [CRCWIDTH - 1 : 0] crc, input logic [DATAWIDTH - 1 : 0] data);
        for (int i = 0; i < DATAWIDTH; i++) begin
            for (int j = 0; j < CRCWIDTH; j++) begin
                if (j == 0) begin
                    crc_calc[j] = POLYNOMIAL[j] ? crc[CRCWIDTH - 1] ^ data[DATAWIDTH - 1 - i] : 1'b0;
                end
                else begin
                    crc_calc[j] = POLYNOMIAL[j] ? crc[j - 1] ^ crc[CRCWIDTH - 1] ^ data[DATAWIDTH - 1 - i] : crc[j - 1];
                end
            end
            crc = crc_calc;
        end
    endfunction
    
    //------------------------------------------------------------------------------------
    //      Новое значение контрольной суммы
    assign crc_new = crc_calc(crc_reg, data);
    
    //------------------------------------------------------------------------------------
    //      Регистр накопления контрольной суммы
    initial crc_reg = INITCRC;
    always @(posedge reset, posedge clk)
        if (reset)
            crc_reg <= INITCRC;
        else if (clkena)
            if (init)
                crc_reg <= INITCRC;
            else
                crc_reg <= crc_new;
        else
            crc_reg <= crc_reg;
    assign crc_old = crc_reg;
    
endmodule: crc_generator