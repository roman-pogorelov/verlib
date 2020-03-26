/*
    // Delay line
    delayline
    #(
        .WIDTH              (), // Data width (WIDTH > 0)
        .LATENCY            ()  // Latency value (LATENCY >= 0)
    )
    the_delayline
    (
        // Reset and clock
        .reset              (), // i
        .clk                (), // i

        // Clock enable
        .clkena             (), // i

        // Input bus
        .data               (), // i  [WIDTH - 1 : 0]

        // Output bus
        .q                  ()  // o  [WIDTH - 1 : 0]
    ); // the_delayline
*/


module delayline
#(
    parameter int unsigned          WIDTH   = 19,   // Data width (WIDTH > 0)
    parameter int unsigned          LATENCY = 2     // Latency value (LATENCY >= 0)
)
(
    // Reset and clock
    input  logic                    reset,
    input  logic                    clk,

    // Clock enable
    input  logic                    clkena,

    // Input bus
    input  logic [WIDTH - 1 : 0]    data,

    // Output bus
    output logic [WIDTH - 1 : 0]    q
);
    // Select implementation depending on a latency value
    generate

        // A latency is more than 1
        if (LATENCY > 1) begin
            logic [LATENCY - 1 : 0][WIDTH - 1 : 0] delay_reg;
            always @(posedge reset, posedge clk) begin
                if (reset)
                    delay_reg <= '0;
                else if (clkena)
                    delay_reg <= {delay_reg[LATENCY - 2 : 0], data};
                else
                    delay_reg <= delay_reg;
            end
            assign q = delay_reg[LATENCY - 1];
        end

        // A latency is equal to 1
        else if (LATENCY == 1) begin
            logic [WIDTH - 1 : 0] delay_reg;
            always @(posedge reset, posedge clk) begin
                if (reset)
                    delay_reg <= '0;
                else if (clkena)
                    delay_reg <= data;
                else
                    delay_reg <= delay_reg;
            end
            assign q = delay_reg;
        end

        // A latency is equal to 0
        else begin
            assign q = data;
        end

    endgenerate

endmodule // delayline
