/*
    // Single clock DataStream buffer based on standard Altera IP
    ds_alt_scfifo
    #(
        .DWIDTH             (), // Stream width
        .DEPTH              (), // Buffer (FIFO) depth
        .RAMTYPE            ()  // RAM blocks type ("MLAB", "M20K", ...)
    )
    the_ds_alt_scfifo
    (
        // Reset and clock
        .reset              (), // i
        .clk                (), // i

        // Inbound stream
        .i_dat              (), // i  [DWIDTH - 1 : 0]
        .i_val              (), // i
        .i_rdy              (), // o

        // Inbound stream
        .o_dat              (), // o  [DWIDTH - 1 : 0]
        .o_val              (), // o
        .o_rdy              ()  // i
    ); // the_ds_alt_scfifo
*/


module ds_alt_scfifo
#(
    parameter                       DWIDTH  = 8,        // Stream width
    parameter                       DEPTH   = 8,        // Buffer (FIFO) depth
    parameter                       RAMTYPE = "AUTO"    // RAM blocks type ("MLAB", "M20K", ...)
)
(
    // Reset and clock
    input  logic                    reset,
    input  logic                    clk,

    // Inbound stream
    input  logic [DWIDTH - 1 : 0]   i_dat,
    input  logic                    i_val,
    output logic                    i_rdy,

    // Outbound stream
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    input  logic                    o_rdy
);
    // Signal declaration
    logic   fifo_empty;
    logic   fifo_full;


    // Altera's single clock FIFO IP core
    scfifo
    #(
        .add_ram_output_register    ("OFF"),
        .lpm_hint                   ({"RAM_BLOCK_TYPE=", RAMTYPE}),
        .lpm_numwords               (DEPTH),
        .lpm_showahead              ("ON"),
        .lpm_type                   ("scfifo"),
        .lpm_width                  (DWIDTH),
        .lpm_widthu                 ($clog2(DEPTH)),
        .overflow_checking          ("ON"),
        .underflow_checking         ("ON"),
        .use_eab                    ("ON")
    )
    the_scfifo
    (
        .aclr                       (reset),
        .clock                      (clk),
        .data                       (i_dat),
        .rdreq                      (o_rdy & ~fifo_empty),
        .wrreq                      (i_val & ~fifo_full),
        .empty                      (fifo_empty),
        .full                       (fifo_full),
        .q                          (o_dat),
        .almost_empty               ( ),
        .almost_full                ( ),
        .sclr                       ( ),
        .usedw                      ( )
    ); // the_scfifo


    // Handshake signals logic
    assign i_rdy = ~fifo_full;
    assign o_val = ~fifo_empty;


endmodule // ds_alt_scfifo