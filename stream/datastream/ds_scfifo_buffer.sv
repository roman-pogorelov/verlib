/*
    //------------------------------------------------------------------------------------
    //      Буфер на основе одноклоковго FIFO для потокового интерфейса DataStream
    ds_scfifo_buffer
    #(
        .WIDTH          (), // Разрядность
        .DEPTH          (), // Глубина буфера (DEPTH > 1)
        .RAMTYPE        ()  // Тип ресурса ("AUTO", "MLAB", "M10K, "LOGIC", ...)
    )
    the_ds_scfifo_buffer
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Синхронный сброс (очистка буфера)
        .clear          (), // i
        
        // Количество элементов в буфере
        .used           (), // o  [$clog2(DEPTH + 1) - 1 : 0]
        
        // Входной потоковый интерфейс
        .i_dat          (), // i  [WIDTH - 1 : 0]
        .i_val          (), // i
        .i_rdy          (), // o
        
        // Выходной потоковый интерфейс
        .o_dat          (), // o  [WIDTH - 1 : 0]
        .o_val          (), // o
        .o_rdy          ()  // i
    ); // the_ds_scfifo_buffer
*/

module ds_scfifo_buffer
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
    
    // Входной потоковый интерфейс
    input  logic [WIDTH - 1 : 0]                i_dat,
    input  logic                                i_val,
    output logic                                i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]                o_dat,
    output logic                                o_val,
    input  logic                                o_rdy
);
    //------------------------------------------------------------------------------------
    //      Атрибут, задающий тип ресурса памяти Altera
    localparam string RAMSTYLE = {"no_rw_check, ", RAMTYPE};
    
    //------------------------------------------------------------------------------------
    //      Описание блока памяти с учетом атрибутов Altera
    (* ramstyle = RAMSTYLE *) reg [WIDTH - 1 : 0] buffer [DEPTH - 1 : 0];
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                                   wr_ena;         // Признак разрешения записи
    logic                                   rd_ena;         // Признак разрешения чтения
    logic [$clog2(DEPTH) - 1 : 0]           wr_cnt;         // Счетчик адреса записи
    logic [$clog2(DEPTH) - 1 : 0]           rd_cnt;         // Счетчик адреса чтения
    logic [$clog2(DEPTH) - 1 : 0]           used_cnt;       // Счетчик использованных слов буфера
    logic                                   wr_rdy_reg;     // Регистр готовности к записи
    logic                                   rd_val_reg;     // Регистр возможности чтения
    
    //------------------------------------------------------------------------------------
    //      Признаки разрешения записи и чтения
    assign wr_ena = i_val & i_rdy;
    assign rd_ena = o_val & o_rdy;
    
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
            assign used = {~wr_rdy_reg, used_cnt};
        end
        else begin: depth_isnt_two_to_power
            assign used = used_cnt;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Регистр готовности к записи
    initial wr_rdy_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            wr_rdy_reg <= '1;
        else if (clear)
            wr_rdy_reg <= '1;
        else if (wr_rdy_reg)
            wr_rdy_reg <= ~((used == DEPTH - 1) & wr_ena & ~rd_ena);
        else
            wr_rdy_reg <= o_rdy;
    assign i_rdy = wr_rdy_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр возможности чтения
    initial rd_val_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            rd_val_reg <= '0;
        else if (clear)
            rd_val_reg <= '0;
        else if (rd_val_reg)
            rd_val_reg <= ~((used == 1) & ~wr_ena & rd_ena);
        else
            rd_val_reg <= i_val;
    assign o_val = rd_val_reg;
    
    //------------------------------------------------------------------------------------
    //      Блок памяти буфера
    always @(posedge clk)
        if (wr_ena) begin
            buffer[wr_cnt] <= i_dat;
        end
    assign o_dat = buffer[rd_cnt];
    
endmodule // ds_scfifo_buffer