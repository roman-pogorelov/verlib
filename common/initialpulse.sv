/*
    // Start-up pulse generator
    initialpulse
    #(
        .LEN    (), // Pulse length
        .POL    ()  // Active level
    )
    the_initialpulse
    (
        // Clock
        .clk    (), // i

        // Start-up pulse
        .pulse  ()  // o
    ); // the_initialpulse
*/


module initialpulse
#(
    parameter int unsigned  LEN = 10,   // Pulse length
    parameter logic         POL = 1'b1  // Active level
)
(
    // Clock
    input  logic            clk,

    // Start-up pulse
    output logic            pulse
);
    // Constants declaration
    localparam int unsigned CWIDTH = LEN < 1 ? 1 : $clog2(LEN + 1);


    // Signals declaration
    logic [CWIDTH - 1 : 0]  delay_cnt;
    logic                   pulse_reg;


    // Delay counter
    initial delay_cnt = LEN[CWIDTH - 1 : 0];
    always @(posedge clk)
        delay_cnt <= delay_cnt - (delay_cnt != 0);


    // Pulse register
    initial pulse_reg = POL;
    always @(posedge clk)
        pulse_reg <= (LEN == 0) ? ~POL : (delay_cnt != 0) ^ (~POL);
    assign pulse = pulse_reg;


endmodule: initialpulse