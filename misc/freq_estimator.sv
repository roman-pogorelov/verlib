/*
    // Clock frequency estimator
    freq_estimator
    #(
        .PERIOD         (), // Duration of estimation in refclk cycles (PERIOD > 0)
        .FACTOR         ()  // The maximum estclk to refclk ration
    )
    the_freq_estimator
    (
        // Reference clock
        .refclk         (), // i

        // Estimable clock
        .estclk         (), // i

        // Estimated clock frequency
        .frequency      ()  // o  [$clog2(FACTOR*PERIOD) - 1 : 0]
    ); // the_freq_estimator
*/


module freq_estimator
#(
    parameter int unsigned                          PERIOD = 1000,  // Период замеров в тактах refclk (PERIOD > 0)
    parameter int unsigned                          FACTOR = 2      // Максимально возможное отношение estclk/refclk
)
(
    // Reference clock
    input  logic                                    refclk,

    // Estimable clock
    input  logic                                    estclk,

    // Estimated clock frequency
    output logic [$clog2(FACTOR*PERIOD) - 1 : 0]    frequency
);
    // Signals declaration
    logic [$clog2(PERIOD) - 1 : 0]                  ref_tick_cnt;
    logic                                           ref_stb_reg;
    logic [$clog2(FACTOR*PERIOD) - 1 : 0]           est_tick_cnt;
    logic [$clog2(FACTOR*PERIOD) - 1 : 0]           est_tick_curr;
    logic [$clog2(FACTOR*PERIOD) - 1 : 0]           est_tick_prev_reg;
    logic [$clog2(FACTOR*PERIOD) - 1 : 0]           freq_est_reg;


    // Declaration of signals with some Altera's constraints
    (*altera_attribute = "-name SDC_STATEMENT \"set_false_path -from [get_registers {*freq_estimator:*|est_tick_cnt[*]}] -to [get_registers {*freq_estimator:*|est_tick_sync_reg[0][*]}]\""*) reg [1 : 0][$clog2(FACTOR*PERIOD) - 1 : 0] est_tick_sync_reg;


    // Reference counter
    initial ref_tick_cnt = '0;
    always @(posedge refclk)
        if (ref_tick_cnt == PERIOD - 1)
            ref_tick_cnt <= '0;
        else
            ref_tick_cnt <= ref_tick_cnt + 1'b1;


    // The register of reference strobe
    initial ref_stb_reg = '0;
    always @(posedge refclk)
        ref_stb_reg <= (ref_tick_cnt == PERIOD - 1);


    // Estimable counter
    initial est_tick_cnt = '0;
    always @(posedge estclk)
        est_tick_cnt <= est_tick_cnt + 1'b1;


    // Synchronization chain
    initial est_tick_sync_reg = '0;
    always @(posedge refclk)
        est_tick_sync_reg <= {est_tick_sync_reg[0], est_tick_cnt};


    // Current value of estimable counter
    assign est_tick_curr = est_tick_sync_reg[1];


    // The register of previous value of estimable counter
    initial est_tick_prev_reg = '0;
    always @(posedge refclk)
        if (ref_stb_reg)
            est_tick_prev_reg <= est_tick_curr;
        else
            est_tick_prev_reg <= est_tick_prev_reg;


    // The register of estimated clock frequency
    initial freq_est_reg = '0;
    always @(posedge refclk)
        if (ref_stb_reg)
            freq_est_reg <= est_tick_curr - est_tick_prev_reg;
        else
            freq_est_reg <= freq_est_reg;
    assign frequency = freq_est_reg;

endmodule: freq_estimator