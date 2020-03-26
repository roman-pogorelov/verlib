/*
    // Iterated signed integer divider
    iterated_signed_divider
    #(
        .NWIDTH         (), // Numerator width
        .DWIDTH         ()  // Denominator width
    )
    the_iterated_signed_divider
    (
        // Reset and clock
        .reset          (), // i
        .clk            (), // i

        // Control interface
        .start          (), // i
        .ready          (), // o
        .done           (), // o

        // Input data interface
        .numerator      (), // i  [NWIDTH - 1 : 0]
        .denominator    (), // i  [DWIDTH - 1 : 0]

        // Output data interface
        .quotient       (), // o  [NWIDTH - 1 : 0]
        .remainder      ()  // o  [DWIDTH - 1 : 0]
    ); // the_iterated_signed_divider
*/


module iterated_signed_divider
#(
    parameter int unsigned          NWIDTH = 8, // Numerator width
    parameter int unsigned          DWIDTH = 6  // Denominator width
)
(
    // Reset and clock
    input  logic                    reset,
    input  logic                    clk,

    // Control interface
    input  logic                    start,
    output logic                    ready,
    output logic                    done,

    // Input data interface
    input  logic [NWIDTH - 1 : 0]   numerator,
    input  logic [DWIDTH - 1 : 0]   denominator,

    // Output data interface
    output logic [NWIDTH - 1 : 0]   quotient,
    output logic [DWIDTH - 1 : 0]   remainder
);
    // Signals declaration
    logic                           correction;
    logic                           done_reg;
    logic [$clog2(NWIDTH) - 1 : 0]  work_cnt;
    logic [DWIDTH - 1 : 0]          denominator_reg;
    logic [DWIDTH - 1 : 0]          new_remainder;
    logic [DWIDTH - 1 : 0]          remainder_reg;
    logic [NWIDTH - 1 : 0]          quotient_reg;


    // FSM encoding
    enum logic [1 : 0] {
        st_idleness     = 2'b00,
        st_working      = 2'b01,
        st_correction   = 2'b11
    } state;
    wire [1 : 0] st;
    assign st = state;


    // FSM transition logic
    always @(posedge reset, posedge clk)
        if (reset)
            state <= st_idleness;
        else case (state)
            st_idleness:
                if (start)
                    state <= st_working;
                else
                    state <= st_idleness;

            st_working:
                if (work_cnt == (NWIDTH - 1))
                    state <= st_correction;
                else
                    state <= st_working;

            st_correction:
                state <= st_idleness;

            default:
                state <= st_idleness;
        endcase


    // FSM driven signals
    assign ready = ~st[0];
    assign correction = st[1];


    // Done register
    always @(posedge reset, posedge clk)
        if (reset)
            done_reg <= '0;
        else
            done_reg <= correction;
    assign done = done_reg;


    // Division cycles counter
    always @(posedge reset, posedge clk)
        if (reset)
            work_cnt <= '0;
        else if (ready)
            work_cnt <= '0;
        else
            work_cnt <= work_cnt + 1'b1;


    // Denominator register
    always @(posedge reset, posedge clk)
        if (reset)
            denominator_reg <= '0;
        else if (ready & start)
            denominator_reg <= denominator;
        else
            denominator_reg <= denominator_reg;


    // Remainder logic
    always_comb begin
        // Correction
        if (correction)
            // Remainder is negative
            if (remainder_reg[DWIDTH - 1])
                // Denominator is negative
                if (denominator_reg[DWIDTH - 1])
                    new_remainder = remainder_reg - denominator_reg;
                // Denominator is positive
                else
                    new_remainder = remainder_reg + denominator_reg;
            // Remainder is positive
            else
                new_remainder = remainder_reg;
        // Remainder and denominator have different signs
        else if (remainder_reg[DWIDTH - 1] ^ denominator_reg[DWIDTH - 1])
            new_remainder = {remainder_reg[DWIDTH - 2 : 0], quotient_reg[NWIDTH - 1]} + denominator_reg;
        // Remainder and denominator have equal signs
        else
            new_remainder = {remainder_reg[DWIDTH - 2 : 0], quotient_reg[NWIDTH - 1]} - denominator_reg;
    end


    // Remainder register
    always @(posedge reset, posedge clk)
        if (reset)
            remainder_reg <= '0;
        else if (ready)
            if (start)
                remainder_reg <= {DWIDTH{numerator[NWIDTH - 1]}};
            else
                remainder_reg <= remainder_reg;
        else
            remainder_reg <= new_remainder;
    assign remainder = remainder_reg;


    // Quotient accumulation register
    always @(posedge reset, posedge clk)
        if (reset)
            quotient_reg <= '0;
        else if (ready)
            if (start)
                quotient_reg <= numerator;
            else
                quotient_reg <= quotient_reg;
        else if (correction)
            quotient_reg <= quotient_reg + denominator_reg[DWIDTH - 1];
        else
            quotient_reg <= {quotient_reg[NWIDTH - 2 : 0], ~(new_remainder[DWIDTH - 1] ^ denominator_reg[DWIDTH - 1])};
    assign quotient = quotient_reg;


endmodule: iterated_signed_divider