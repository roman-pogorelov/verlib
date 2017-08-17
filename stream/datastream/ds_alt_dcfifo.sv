/*
    //------------------------------------------------------------------------------------
    //      Двухклоковый FIFO буфер для потокового интерфейса DataStream
    //      на ядре от Altera
    ds_alt_dcfifo
    #(
        .DWIDTH             (), // Разрядность потока
        .DEPTH              (), // Глубина FIFO
        .RAMTYPE            ()  // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    the_ds_alt_dcfifo
    (
        // Сброс и тактирование
        .reset              (), // i
        .i_clk              (), // i
        .o_clk              (), // i
        
        // Входной потоковый интерфейс
        .i_dat              (), // i  [DWIDTH - 1 : 0]
        .i_val              (), // i
        .i_rdy              (), // o
        
        // Выходной потоковый интерфейс
        .o_dat              (), // o  [DWIDTH - 1 : 0]
        .o_val              (), // o
        .o_rdy              ()  // i
    ); // the_ds_alt_dcfifo
*/

module ds_alt_dcfifo
#(
    parameter                       DWIDTH  = 8,        // Разрядность потока
    parameter                       DEPTH   = 8,        // Глубина FIFO
    parameter                       RAMTYPE = "AUTO"    // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    i_clk,
    input  logic                    o_clk,
    
    // Входной потоковый интерфейс
    input  logic [DWIDTH - 1 : 0]   i_dat,
    input  logic                    i_val,
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                           fifo_rdempty;
    logic                           fifo_wrfull;
    
    //------------------------------------------------------------------------------------
    //      Двухклоковое FIFO на ядре от Altera
    dcfifo
    #(
        .lpm_hint               ({"RAM_BLOCK_TYPE=", RAMTYPE}),
        .lpm_numwords           (DEPTH),
        .lpm_showahead          ("ON"),
        .lpm_type               ("dcfifo"),
        .lpm_width              (DWIDTH),
        .lpm_widthu             ($clog2(DEPTH)),
        .overflow_checking      ("ON"),
        .rdsync_delaypipe       (4),
        .read_aclr_synch        ("ON"),
        .underflow_checking     ("ON"),
        .use_eab                ("ON"),
        .write_aclr_synch       ("ON"),
        .wrsync_delaypipe       (4)
    )
    the_dcfifo
    (
        .aclr                   (reset),
        .wrclk                  (i_clk),
        .wrreq                  (i_val & ~fifo_wrfull),
        .data                   (i_dat),
        .wrfull                 (fifo_wrfull),
        .rdclk                  (o_clk),
        .rdreq                  (o_rdy & ~fifo_rdempty),
        .q                      (o_dat),
        .rdempty                (fifo_rdempty),
        .rdfull                 (  ),
        .rdusedw                (  ),
        .wrempty                (  ),
        .wrusedw                (  )
    ); // the_dcfifo

    //------------------------------------------------------------------------------------
    //      Формирование сигналов i_rdy и o_val
    assign i_rdy = ~fifo_wrfull;
    assign o_val = ~fifo_rdempty;
    
endmodule // ds_alt_dcfifo