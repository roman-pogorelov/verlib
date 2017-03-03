/*
    //------------------------------------------------------------------------------------
    //      Одноклоковый FIFO буфер для потокового интерфейса PacketStream
    //      на ядре от Altera
    ps_alt_scfifo
    #(
        .DWIDTH             (), // Разрядность потока
        .DEPTH              (), // Глубина FIFO
        .RAMTYPE            ()  // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    the_ps_alt_scfifo
    (
        // Сброс и тактирование
        .reset              (), // i
        .clk                (), // i
        
        // Входной потоковый интерфейс
        .i_dat              (), // i  [DWIDTH - 1 : 0]
        .i_val              (), // i
        .i_eop              (), // i
        .i_rdy              (), // o
        
        // Выходной потоковый интерфейс
        .o_dat              (), // o  [DWIDTH - 1 : 0]
        .o_val              (), // o
        .o_eop              (), // o
        .o_rdy              ()  // i
    ); // the_ps_alt_scfifo
*/

module ps_alt_scfifo
#(
    parameter                       DWIDTH  = 8,        // Разрядность потока
    parameter                       DEPTH   = 8,        // Глубина FIFO
    parameter                       RAMTYPE = "AUTO"    // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Входной потоковый интерфейс
    input  logic [DWIDTH - 1 : 0]   i_dat,
    input  logic                    i_val,
    input  logic                    i_eop,
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                           fifo_empty;
    logic                           fifo_full;
    
    //------------------------------------------------------------------------------------
    //      Одноклоковое FIFO на ядре от Altera
    scfifo
    #(
        .add_ram_output_register    ("OFF"),
        .lpm_hint                   ({"RAM_BLOCK_TYPE=", RAMTYPE}),
        .lpm_numwords               (DEPTH),
        .lpm_showahead              ("ON"),
        .lpm_type                   ("scfifo"),
        .lpm_width                  (DWIDTH + 1),
        .lpm_widthu                 ($clog2(DEPTH)),
        .overflow_checking          ("ON"),
        .underflow_checking         ("ON"),
        .use_eab                    ("ON")
    )
    the_scfifo
    (
        .aclr                       (reset),
        .clock                      (clk),
        .data                       ({i_dat, i_eop}),
        .rdreq                      (o_rdy & ~fifo_empty),
        .wrreq                      (i_val & ~fifo_full),
        .empty                      (fifo_empty),
        .full                       (fifo_full),
        .q                          ({o_dat, o_eop}),
        .almost_empty               ( ),
        .almost_full                ( ),
        .sclr                       ( ),
        .usedw                      ( )
    ); // the_scfifo
    
    //------------------------------------------------------------------------------------
    //      Формирование сигналов i_rdy и o_val
    assign i_rdy = ~fifo_full;
    assign o_val = ~fifo_empty;
    
endmodule // ps_alt_scfifo