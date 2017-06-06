/*
    //------------------------------------------------------------------------------------
    //      Одноклоковая очередь FIFO
    sfifo
    #(
        .WIDTH          (), // Разрядность
        .DEPTH          (), // Глубина буфера (DEPTH > 1)
        .RAMTYPE        ()  // Тип ресурса ("AUTO", "MLAB", "M10K, "LOGIC", ...)
    )
    the_sfifo
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Синхронный сброс (очистка буфера)
        .clear          (), // i
        
        // Количество элементов в буфере
        .used           (), // o  [$clog2(DEPTH + 1) - 1 : 0]
        
        // Интерфейс записи
        .wr_data        (), // i  [WIDTH - 1 : 0]
        .wr_req         (), // i
        .wr_full        (), // o
        
        // Интерфейс чтения
        .rd_data        (), // o  [WIDTH - 1 : 0]
        .rd_ack         (), // i
        .rd_empty       ()  // o
    ); // the_sfifo
*/

module sfifo
#(
    parameter int unsigned                      WIDTH       = 8,        // Разрядность потока
    parameter int unsigned                      DEPTH       = 8,        // Глубина буфера (DEPTH > 1)
    parameter string                            RAMTYPE     = "AUTO"    // Тип ресурса ("AUTO", "MLAB", "M10K, "LOGIC", ...)
)
(
    // Сброс и тактирование
    input  logic                                reset,
    input  logic                                clk,
    
    // Синхронный сброс (очистка буфера)
    input  logic                                clear,
    
    // Количество элементов в буфере
    output logic [$clog2(DEPTH + 1) - 1 : 0]    used,
    
    // Интерфейс записи
    input  logic [WIDTH - 1 : 0]                wr_data,
    input  logic                                wr_req,
    output logic                                wr_full,
    
    // Интерфейс чтения
    output logic [WIDTH - 1 : 0]                rd_data,
    input  logic                                rd_ack,
    output logic                                rd_empty
);
    //------------------------------------------------------------------------------------
    //      Атрибут, задающий тип ресурса памяти Altera
    localparam string RAMSTYLE = {"no_rw_check, ", RAMTYPE};
    
    //------------------------------------------------------------------------------------
    //      Описание блока памяти с учетом атрибутов Altera
    (* ramstyle = RAMSTYLE *) reg [WIDTH - 1 : 0] buffer [DEPTH - 1 : 0];
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                                   wr_ena;
    logic                                   rd_ena;
    logic [$clog2(DEPTH) - 1 : 0]           wr_cnt;
    logic [$clog2(DEPTH) - 1 : 0]           rd_cnt;
    logic [$clog2(DEPTH) - 1 : 0]           used_cnt;
    logic                                   full_reg;
    logic                                   empty_reg;
    
    //------------------------------------------------------------------------------------
    //      Признаки разрешения записи и чтения
    assign wr_ena = wr_req & ~wr_full;
    assign rd_ena = rd_ack & ~rd_empty;
    
    //------------------------------------------------------------------------------------
    //      Счетчик адреса записи
    initial wr_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            wr_cnt <= '0;
        else if (clear)
            wr_cnt <= '0;
        else if (wr_ena)
            wr_cnt <= (wr_cnt == DEPTH - 1) ? '0 : wr_cnt + 1'b1;
        else
            wr_cnt <= wr_cnt;
    
    //------------------------------------------------------------------------------------
    //      Счетчик адреса чтения
    initial rd_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            rd_cnt <= '0;
        else if (clear)
            rd_cnt <= '0;
        else if (rd_ena)
            rd_cnt <= (rd_cnt == DEPTH - 1) ? '0 : rd_cnt + 1'b1;
        else
            rd_cnt <= rd_cnt;
    
    //------------------------------------------------------------------------------------
    //      Счетчик использованных слов буфера
    initial used_cnt = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            used_cnt <= '0;
        else if (clear)
            used_cnt <= '0;
        else if (wr_ena & ~rd_ena)
            used_cnt <= used_cnt + 1'b1;
        else if (~wr_ena & rd_ena)
            used_cnt <= used_cnt - 1'b1;
        else
            used_cnt <= used_cnt;
    
    //------------------------------------------------------------------------------------
    //      Количество элементов в буфере
    generate
        if (2**$clog2(DEPTH) == DEPTH) begin: depth_is_two_to_power
            assign used = {full_reg, used_cnt};
        end
        else begin: depth_isnt_two_to_power
            assign used = used_cnt;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Регистр признака "полноты" FIFO
    initial full_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            full_reg <= '0;
        else if (clear)
            full_reg <= '0;
        else if (full_reg)
            full_reg <= ~rd_ack;
        else
            full_reg <= (used_cnt == DEPTH - 1) & wr_ena & ~rd_ena;
    assign wr_full = full_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака пустоты FIFO
    initial empty_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            empty_reg <= '1;
        else if (clear)
            empty_reg <= '1;
        else if (empty_reg)
            empty_reg <= ~wr_req;
        else
            empty_reg <= (used_cnt == 1) & ~wr_ena & rd_ena;
    assign rd_empty = empty_reg;
    
    //------------------------------------------------------------------------------------
    //      Блок памяти буфера
    always @(posedge clk)
        if (wr_ena) begin
            buffer[wr_cnt] <= wr_data;
        end
    assign rd_data = buffer[rd_cnt];
    
endmodule // sfifo