/*
    // Single clock PacketStream buffer based on standard Altera IP
    ps_alt_scfifo
    #(
        .DWIDTH             (), // Stream width
        .DEPTH              (), // Buffer (FIFO) depth
        .RAMTYPE            ()  // RAM blocks type ("MLAB", "M20K", ...)
    )
    the_ps_alt_scfifo
    (
        // Reset and clock
        .reset              (), // i
        .clk                (), // i

        // Inbound stream
        .i_dat              (), // i  [DWIDTH - 1 : 0]
        .i_val              (), // i
        .i_eop              (), // i
        .i_rdy              (), // o

        // Outbound stream
        .o_dat              (), // o  [DWIDTH - 1 : 0]
        .o_val              (), // o
        .o_eop              (), // o
        .o_rdy              ()  // i
    ); // the_ps_alt_scfifo
*/


module ps_alt_scfifo
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
    input  logic                    i_eop,
    output logic                    i_rdy,

    // Outbound stream
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    // Signals declaration
    logic                           fifo_empty;
    logic                           fifo_full;


    // Altera's single clock FIFO IP core
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


    // Handshake signals logic
    assign i_rdy = ~fifo_full;
    assign o_val = ~fifo_empty;


endmodule // ps_alt_scfifo