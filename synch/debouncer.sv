/*
    // Generator of a clear output from a bouncing input
    debouncer
    #(
        .STABLE_TIME    (), // The period of time after that an input is considered as stable
        .EXTRA_STAGES   (), // The number of extra stages
        .RESET_VALUE    ()  // The sync stages default value
    )
    the_debouncer
    (
        // Reset and clock
        .reset          (), // i
        .clk            (), // i

        // Bouncing input
        .bounce         (), // i

        // Clean output
        .stable         ()  // o
    ); // the_debouncer
*/


module debouncer
#(
    parameter int unsigned      STABLE_TIME  = 8,   // The period of time after that an input is considered as stable
    parameter int unsigned      EXTRA_STAGES = 0,   // The number of extra stages
    parameter logic             RESET_VALUE  = 0    // The sync stages default value
)
(
    // Reset and clock
    input  logic                reset,
    input  logic                clk,

    // Bouncing input
    input  logic                bounce,

    // Clean output
    output logic                stable
);
    // Constants declarations
    localparam int unsigned     CWIDTH = $clog2(STABLE_TIME);


    // Signals declarations
    logic                       bounce_sync;
    logic [CWIDTH - 1 : 0]      stable_cnt;
    logic                       stable_reg;


    // FlipFlop synchronizer
    ff_synchronizer
    #(
        .WIDTH          (1),            // Synchronized bus width
        .EXTRA_STAGES   (EXTRA_STAGES), // The number of extra stages
        .RESET_VALUE    (RESET_VALUE)   // The sync stages default value
    )
    the_ff_synchronizer
    (
        // Reset and clock
        .reset          (reset),        // i
        .clk            (clk),          // i

        // Asynchronous input
        .async_data     (bounce),       // i  [WIDTH - 1 : 0]

        // Synchronous output
        .sync_data      (bounce_sync)   // o  [WIDTH - 1 : 0]
    ); // the_ff_synchronizer


    // The counter of stabilization time
    always @(posedge reset, posedge clk)
        if (reset)
            stable_cnt <= '0;
        else if (bounce_sync != stable_reg)
            if (stable_cnt == (STABLE_TIME - 1))
                stable_cnt <= '0;
            else
                stable_cnt <= stable_cnt + 1'b1;
        else
            stable_cnt <= '0;


    // The register of a clean output
    initial stable_reg = RESET_VALUE;
    always @(posedge reset, posedge clk)
        if (reset)
            stable_reg <= RESET_VALUE;
        else
            stable_reg <= ((bounce_sync != stable_reg) & (stable_cnt == (STABLE_TIME - 1))) ^ stable_reg;
    assign stable = stable_reg;


endmodule: debouncer