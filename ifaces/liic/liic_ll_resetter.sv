/*
    // Link layer reset generator
    liic_ll_resetter
    #(
        .LENGTH     (), // Duration of link layer reset in clock cycles
        .PERIOD     ()  // The period of link layer reset repetition in clock cycles
    )
    the_liic_ll_resetter
    (
        // Reset and clock
        .rst        (), // i
        .clk        (), // i

        // Link layer linkup indicator
        .ll_linkup  (), // i

        // Link layer reset output
        .ll_reset   ()  // o
    ); // the_liic_ll_resetter
*/


module liic_ll_resetter
#(
    parameter int unsigned  LENGTH  = 5,    // Duration of link layer reset in clock cycles
    parameter int unsigned  PERIOD  = 25    // The period of link layer reset repetition in clock cycles
)
(
    // Reset and clock
    input  logic            rst,
    input  logic            clk,

    // Link layer linkup indicator
    input  logic            ll_linkup,

    // Link layer reset output
    output logic            ll_reset
);
    // Constants declaration
    localparam int unsigned MAXTIME = PERIOD > LENGTH ? PERIOD : LENGTH + 1;


    // Signals declaration
    logic                           reset_reg;
    logic                           reset_next;
    //
    logic [$clog2(MAXTIME) - 1 : 0] time_cnt;
    logic                           time_clr;


    // FSM encoding
    (* syn_encoding = "gray" *) enum int unsigned {
        st_issue_reset,
        st_wait_for_linkup,
        st_do_nothing
    } cstate, nstate;


    // FSM current state register
    initial cstate = st_issue_reset;
    always @(posedge rst, posedge clk) begin
        if (rst)
            cstate <= st_issue_reset;
        else
            cstate <= nstate;
    end


    // Reset register
    initial reset_reg = 1'b1;
    always @(posedge rst, posedge clk) begin
        if (rst)
            reset_reg <= 1'b1;
        else
            reset_reg <= reset_next;
    end
    assign ll_reset = reset_reg;


    // FSM next state logic
    always_comb begin

        // Defaults
        reset_next = 1'b0;
        time_clr = 1'b1;

        // Transitions logic
        case (cstate)
            st_issue_reset: begin
                time_clr = 1'b0;
                if (time_cnt == (LENGTH - 1)) begin
                    nstate = st_wait_for_linkup;
                end
                else begin
                    reset_next = 1'b1;
                    nstate = st_issue_reset;
                end
            end

            st_wait_for_linkup: begin
                if (ll_linkup) begin
                    nstate = st_do_nothing;
                end
                else if (time_cnt >= (PERIOD - 1)) begin
                    reset_next = 1'b1;
                    nstate = st_issue_reset;
                end
                else begin
                    time_clr = 1'b0;
                    nstate = st_wait_for_linkup;
                end
            end

            st_do_nothing: begin
                if (ll_linkup) begin
                    nstate = st_do_nothing;
                end
                else begin
                    reset_next = 1'b1;
                    nstate = st_issue_reset;
                end
            end

            default: begin
                reset_next = 1'b1;
                nstate = st_issue_reset;
            end
        endcase
    end


    // The clock cycles counter
    always @(posedge rst, posedge clk) begin
        if (rst)
            time_cnt <= '0;
        else if (time_clr)
            time_cnt <= '0;
        else
            time_cnt <= time_cnt + 1'b1;
    end


endmodule: liic_ll_resetter