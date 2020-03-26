/*
    // Register based DataStream buffer with no combinational links
    // between stream interfaces
    ds_twinreg_buffer
    #(
        .WIDTH      ()  // Stream width
    )
    the_ds_twinreg_buffer
    (
        // Reset and clock
        .reset      (), // i
        .clk        (), // i

        // Inbound stream
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o

        // Outbound stream
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_rdy      ()  // i
    ); // the_ds_twinreg_buffer
*/


module ds_twinreg_buffer
#(
    parameter int unsigned          WIDTH = 8   // Stream width
)
(
    // Reset and clock
    input  logic                    reset,
    input  logic                    clk,

    // Inbound stream
    input  logic [WIDTH - 1 : 0]    i_dat,
    input  logic                    i_val,
    output logic                    i_rdy,

    // Outbound stream
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    input  logic                    o_rdy
);
    // Signals declaration
    logic [WIDTH - 1 : 0]           i_dat_reg;
    logic [WIDTH - 1 : 0]           o_dat_reg;
    logic                           i_val_reg;
    logic                           o_val_reg;


    // The data register of the input stage
    initial i_dat_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            i_dat_reg <= '0;
        else if (~i_val_reg)
            i_dat_reg <= i_dat;
        else
            i_dat_reg <= i_dat_reg;


    // The data register of the output stage
    initial o_dat_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            o_dat_reg <= '0;
        else if (~o_val_reg | o_rdy)
            o_dat_reg <= i_val_reg ? i_dat_reg : i_dat;
        else
            o_dat_reg <= o_dat_reg;


    // The validness register of the input stage
    initial i_val_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            i_val_reg <= '0;
        else if (~i_val_reg | ~o_val_reg | o_rdy)
            i_val_reg <= ~(~o_val_reg | o_rdy) & i_val;
        else
            i_val_reg <= i_val_reg;


    // The validation register of the output stage
    initial o_val_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            o_val_reg <= '0;
        else if (~o_val_reg | o_rdy)
            o_val_reg <= i_val_reg | i_val;
        else
            o_val_reg <= o_val_reg;


    // Output signals logic
    assign o_dat =  o_dat_reg;
    assign o_val =  o_val_reg;
    assign i_rdy = ~i_val_reg;


endmodule // ds_twinreg_buffer