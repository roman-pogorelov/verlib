/*
    // Double clock DataStream buffer based on standard Altera IP
    ds_alt_dcfifo
    #(
        .DWIDTH             (), // Stream width
        .DEPTH              (), // Buffer (FIFO) depth
        .RAMTYPE            ()  // RAM blocks type ("MLAB", "M20K", ...)
    )
    the_ds_alt_dcfifo
    (
        // Reset and clocks
        .reset              (), // i
        .i_clk              (), // i
        .o_clk              (), // i

        // Inbound stream
        .i_dat              (), // i  [DWIDTH - 1 : 0]
        .i_val              (), // i
        .i_rdy              (), // o

        // Outbound stream
        .o_dat              (), // o  [DWIDTH - 1 : 0]
        .o_val              (), // o
        .o_rdy              ()  // i
    ); // the_ds_alt_dcfifo
*/

module ds_alt_dcfifo
#(
    parameter                       DWIDTH  = 8,        // Stream width
    parameter                       DEPTH   = 8,        // Buffer (FIFO) depth
    parameter                       RAMTYPE = "AUTO"    // RAM blocks type ("MLAB", "M20K", ...)
)
(
    // Reset and clocks
    input  logic                    reset,
    input  logic                    i_clk,
    input  logic                    o_clk,

    // Inbound stream
    input  logic [DWIDTH - 1 : 0]   i_dat,
    input  logic                    i_val,
    output logic                    i_rdy,

    // Outbound stream
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    input  logic                    o_rdy
);
    // Signals declaration
    logic                           fifo_rdempty;
    logic                           fifo_wrfull;


    // Altera's double clock FIFO IP core
    (* altera_attribute = {"-name SDC_STATEMENT \"set_false_path -through [get_pins -compatibility_mode {*dcfifo*|dffpipe*:rdaclr|dffe*clrn}] -to [get_registers {*dcfifo*|dffpipe*:rdaclr|dffe*}]\"; -name SDC_STATEMENT \"set_false_path -through [get_pins -compatibility_mode {*dcfifo*|dffpipe*:wraclr|dffe*clrn}] -to [get_registers {*dcfifo*|dffpipe*:wraclr|dffe*}]\""} *) dcfifo
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


    // Handshake signals logic
    assign i_rdy = ~fifo_wrfull;
    assign o_val = ~fifo_rdempty;


endmodule // ds_alt_dcfifo