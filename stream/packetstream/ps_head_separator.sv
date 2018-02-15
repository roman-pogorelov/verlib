/*
    //------------------------------------------------------------------------------------
    //      Модуль выделения "головы" пакета потокового интерфейса PacketStream
    //      и выдачи его в параллельном виде в течение прохождения всего пакета
    ps_head_separator
    #(
        .WIDTH          (), // Разрядность потока
        .LENGTH         (), // Длина заголовка (LENGTH > 1)
        .RAMTYPE        ()  // Тип внутренней памяти для реализации буфера
    )
    the_ps_head_separator
    (
        // Тактирование и сброс
        .reset          (), // i
        .clk            (), // i
        
        // Входной потоковый интерфейс
        .i_dat          (), // i  [WIDTH - 1 : 0]
        .i_val          (), // i
        .i_eop          (), // i
        .i_rdy          (), // o
        
        // Выходной потоковый интерфейс
        .o_hdr          (), // o  [LENGTH - 1 : 0][WIDTH - 1 : 0] Параллельное представление заголовка
        .o_len          (), // o                                  Длина заголовка минус 1
        .o_dat          (), // o
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ps_head_separator
*/

module ps_head_separator
#(
    parameter int unsigned                          WIDTH   = 8,        // Разрядность потока
    parameter int unsigned                          LENGTH  = 4,        // Длина заголовка (LENGTH > 1)
    parameter                                       RAMTYPE = "AUTO"    // Тип внутренней памяти для реализации буфера
)
(
    // Тактирование и сброс
    input  logic                                    reset,
    input  logic                                    clk,
    
    // Входной потоковый интерфейс
    input  logic [WIDTH - 1 : 0]                    i_dat,
    input  logic                                    i_val,
    input  logic                                    i_eop,
    output logic                                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [LENGTH - 1 : 0][WIDTH - 1 : 0]    o_hdr,  // Параллельное представление заголовка
    output logic [$clog2(LENGTH) - 1 : 0]           o_len,  // Длина заголовка минус 1
    output logic [WIDTH - 1 : 0]                    o_dat,
    output logic                                    o_val,
    output logic                                    o_eop,
    input  logic                                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [LENGTH - 1 : 0][WIDTH - 1 : 0]   header;
    logic [$clog2(LENGTH + 1) - 1 : 0]      header_cnt;
    logic                                   header_end_reg;
    logic                                   header_early_end_reg;
    //
    logic                                   stream_val;
    logic                                   stream_rdy;
    logic                                   header_val;
    logic                                   header_rdy;
    
    //------------------------------------------------------------------------------------
    //      Заголовок пакета в параллельном виде
    generate
        if (LENGTH > 1) begin: compound_header
            //------------------------------------------------------------------------------------
            //      Регистр накопления заголовка
            logic [LENGTH - 2 : 0][WIDTH - 1 : 0] header_reg;
            always @(posedge reset, posedge clk)
                if (reset)
                    header_reg <= '0;
                else if (i_val & i_rdy)
                    if (i_eop)
                        header_reg <= '0;
                    else if (LENGTH > 2)
                        header_reg <= {i_dat, header_reg[LENGTH - 2 : 1]};
                    else
                        header_reg <= i_dat;
                else
                    header_reg <= header_reg;
            assign header = {i_dat, header_reg};
        end
        else begin: unary_header
            assign header = i_dat;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Счетчик слов заголовка
    always @(posedge reset, posedge clk)
        if (reset)
            header_cnt <= '0;
        else if (i_val & i_rdy)
            if (i_eop)
                header_cnt <= '0;
            else
                header_cnt <= header_cnt + (header_cnt != LENGTH);
        else
            header_cnt <= header_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака конца заголовка
    initial header_end_reg = (LENGTH > 1) ? 1'b0 : 1'b1;
    always @(posedge reset, posedge clk)
        if (reset)
            header_end_reg <= (LENGTH > 1) ? 1'b0 : 1'b1;
        else if (i_val & i_rdy)
            if (LENGTH > 1)
                header_end_reg <= header_cnt == (LENGTH - 2);
            else
                header_end_reg <= i_eop;
        else
            header_end_reg <= header_end_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр контроля преждевременного конца заголовка
    initial header_early_end_reg = (LENGTH > 1) ? 1'b1 : 1'b0;
    always @(posedge reset, posedge clk)
        if (reset)
            header_early_end_reg <= (LENGTH > 1) ? 1'b1 : 1'b0;
        else if (LENGTH > 1)
            if (header_early_end_reg)
                header_early_end_reg <= ~(i_val & i_rdy & ~i_eop & (header_cnt == (LENGTH - 2)));
            else
                header_early_end_reg <= i_val & i_rdy & i_eop;
        else
            header_early_end_reg <= 1'b0;
    
    //------------------------------------------------------------------------------------
    //      Одноклоковый FIFO буфер для потокового интерфейса PacketStream
    //      на ядре от Altera
    ps_alt_scfifo
    #(
        .DWIDTH             (WIDTH),                // Разрядность потока
        .DEPTH              (LENGTH + 2),           // Глубина FIFO
        .RAMTYPE            (RAMTYPE)               // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    stream_fifo
    (
        // Сброс и тактирование
        .reset              (reset),                // i
        .clk                (clk),                  // i
        
        // Входной потоковый интерфейс
        .i_dat              (i_dat),                // i  [DWIDTH - 1 : 0]
        .i_val              (i_val & header_rdy),   // i
        .i_eop              (i_eop),                // i
        .i_rdy              (stream_rdy),           // o
        
        // Выходной потоковый интерфейс
        .o_dat              (o_dat),                // o  [DWIDTH - 1 : 0]
        .o_val              (stream_val),           // o
        .o_eop              (o_eop),                // o
        .o_rdy              (o_rdy & header_val)    // i
    ); // stream_fifo
    
    //------------------------------------------------------------------------------------
    //      Одноклоковый FIFO буфер для потокового интерфейса DataStream
    //      на ядре от Altera
    ds_alt_scfifo
    #(
        .DWIDTH             (WIDTH*LENGTH + $clog2(LENGTH)),    // Разрядность потока
        .DEPTH              (LENGTH + 2),                       // Глубина FIFO
        .RAMTYPE            (RAMTYPE)                           // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    header_fifo
    (
        // Сброс и тактирование
        .reset              (reset),                            // i
        .clk                (clk),                              // i
        
        // Входной потоковый интерфейс
        .i_dat              ({                                  // i  [DWIDTH - 1 : 0]
                                header,
                                header_cnt[$clog2(LENGTH) - 1 : 0]
                            }),
        .i_val              (                                    // i
                                i_val & stream_rdy & 
                                ((header_early_end_reg & i_eop) | header_end_reg)
                            ),
        .i_rdy              (header_rdy),                       // o
        
        // Выходной потоковый интерфейс
        .o_dat              ({                                  // o  [DWIDTH - 1 : 0]
                                o_hdr,
                                o_len
                            }),
        .o_val              (header_val),                       // o
        .o_rdy              (o_rdy & stream_val & o_eop)        // i
    ); // header_fifo
    
    //------------------------------------------------------------------------------------
    //      Выходные сигналы потоковых интерфейсов
    assign i_rdy = stream_rdy & header_rdy;
    assign o_val = stream_val & header_val;
    
endmodule // ps_head_separator