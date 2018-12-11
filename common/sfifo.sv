/*
    //------------------------------------------------------------------------------------
    //      Synchronous FIFO
    sfifo
    #(
        .WIDTH          (), // Data width (WIDTH > 0)
        .DEPTH          (), // FIFO depth (DEPTH > 1)
        .PROGFULL       (), // Threshold of programmable full flag (wr_progfull = 1 if used >= PROGFULL)
        .PROGEMPTY      (), // Threshold of programmable empty flag (rd_progempty = 1 if used < PROGEMPTY)
        .SHOWAHEAD      (), // "Show ahead" mode selection ("ON, "OFF")
        .RAMTYPE        ()  // RAM resource type ("AUTO", "MLAB", "M10K, "LOGIC", ...)
    )
    the_sfifo
    (
        // Asynchronous reset and clock
        .rst            (), // i
        .clk            (), // i
        
        // Synchronous reset
        .clear          (), // i
        
        // Used words count
        .used           (), // o  [$clog2(DEPTH + 1) - 1 : 0]
        
        // Wrire side
        .wr_data        (), // i  [WIDTH - 1 : 0]
        .wr_req         (), // i
        .wr_full        (), // o
        .wr_progfull    (), // o
        
        // Read side
        .rd_data        (), // o  [WIDTH - 1 : 0]
        .rd_req         (), // i
        .rd_empty       (), // o
        .rd_progempty   ()  // o
    ); // the_sfifo
*/

module sfifo
#(
    parameter int unsigned                      WIDTH       = 8,        // Data width (WIDTH > 0)
    parameter int unsigned                      DEPTH       = 8,        // FIFO depth (DEPTH > 1)
    parameter int unsigned                      PROGFULL    = 0,        // Threshold of programmable full flag (wr_progfull = 1 if used >= PROGFULL)
    parameter int unsigned                      PROGEMPTY   = 0,        // Threshold of programmable empty flag (rd_progempty = 1 if used < PROGEMPTY)
    parameter                                   SHOWAHEAD   = "ON",     // "Show ahead" mode selection ("ON, "OFF")
    parameter                                   RAMTYPE     = "AUTO"    // RAM resource type ("AUTO", "MLAB", "M10K, "LOGIC", ...)
)
(
    // Asynchronous reset and clock
    input  logic                                rst,
    input  logic                                clk,
    
    // Synchronous reset
    input  logic                                clear,
    
    // Used words count
    output logic [$clog2(DEPTH + 1) - 1 : 0]    used,
    
    // Wrire side
    input  logic [WIDTH - 1 : 0]                wr_data,
    input  logic                                wr_req,
    output logic                                wr_full,
    output logic                                wr_progfull,
    
    // Read side
    output logic [WIDTH - 1 : 0]                rd_data,
    input  logic                                rd_req,
    output logic                                rd_empty,
    output logic                                rd_progempty
);
    
    
    // Memory block declarations
    (* ramstyle = RAMTYPE *) reg [WIDTH - 1 : 0] buffer [DEPTH - 1 : 0];
    
    
    // Signal declarations
    logic                               wr_ena;
    logic                               rd_ena;
    logic [$clog2(DEPTH) - 1 : 0]       wr_cnt;
    logic [$clog2(DEPTH) - 1 : 0]       rd_cnt;
    logic [$clog2(DEPTH + 1) - 1 : 0]   used_cnt;
    logic                               full_reg;
    logic                               empty_reg;
    
    
    // Write and read strobes
    assign wr_ena = wr_req & ~wr_full;
    assign rd_ena = rd_req & ~rd_empty;
    
    
    // Write address counter
    initial wr_cnt = '0;
    always @(posedge rst, posedge clk)
        if (rst)
            wr_cnt <= '0;
        else if (clear)
            wr_cnt <= '0;
        else if (wr_ena)
            wr_cnt <= (wr_cnt == (DEPTH - 1)) ? '0 : wr_cnt + 1'b1;
        else
            wr_cnt <= wr_cnt;
    
    
    // Read address counter
    initial rd_cnt = '0;
    always @(posedge rst, posedge clk)
        if (rst)
            rd_cnt <= '0;
        else if (clear)
            rd_cnt <= '0;
        else if (rd_ena)
            rd_cnt <= (rd_cnt == (DEPTH - 1)) ? '0 : rd_cnt + 1'b1;
        else
            rd_cnt <= rd_cnt;
    
    
    // Used words counter
    initial used_cnt = '0;
    always @(posedge rst, posedge clk)
        if (rst)
            used_cnt <= '0;
        else if (clear)
            used_cnt <= '0;
        else if (wr_ena & ~rd_ena)
            used_cnt <= used_cnt + 1'b1;
        else if (~wr_ena & rd_ena)
            used_cnt <= used_cnt - 1'b1;
        else
            used_cnt <= used_cnt;
    assign used = used_cnt;
    
    
    // Full flag register
    initial full_reg = '0;
    always @(posedge rst, posedge clk)
        if (rst)
            full_reg <= '0;
        else if (clear)
            full_reg <= '0;
        else if (full_reg)
            full_reg <= ~rd_req;
        else
            full_reg <= (used_cnt == (DEPTH - 1)) & wr_ena & ~rd_ena;
    assign wr_full = full_reg;
    
    
    // Programmable full flag
    generate
        
        // Programmable full flag is always 1
        if (PROGFULL == 0) begin: wr_progfull_is_always_1
            assign wr_progfull = 1'b1;
        end
        
        // Extra logic is needed to assert the programmable full flag
        else if (PROGFULL < DEPTH) begin: wr_progfull_is_extra_logic
            
            // Programmable full flag register
            logic progfull_reg;
            initial progfull_reg = '0;
            always @(posedge rst, posedge clk)
                if (rst)
                    progfull_reg <= '0;
                else if (clear)
                    progfull_reg <= '0;
                else if (progfull_reg)
                    progfull_reg <= ~((used_cnt == PROGFULL) & ~wr_ena & rd_ena);
                else
                    progfull_reg <= (used_cnt == (PROGFULL - 1)) & wr_ena & ~rd_ena;
            
            assign wr_progfull = progfull_reg;
        end
        
        // Programmable full flag is the same as the full flag
        else if (PROGFULL == DEPTH) begin: wr_progfull_is_wr_full
            assign wr_progfull = wr_full;
        end
        
        // Programmable full flag is always 0
        else begin: wr_progfull_is_always_0
            assign wr_progfull = 1'b0;
        end
        
    endgenerate
    
    
    // Empty flag register
    initial empty_reg = '1;
    always @(posedge rst, posedge clk)
        if (rst)
            empty_reg <= '1;
        else if (clear)
            empty_reg <= '1;
        else if (empty_reg)
            empty_reg <= ~wr_req;
        else
            empty_reg <= (used_cnt == 1) & ~wr_ena & rd_ena;
    assign rd_empty = empty_reg;
    
    
    // Programmable empty flag
    generate
        
        // Programmable empty flag is always 0
        if (PROGEMPTY == 0) begin: rd_progempty_is_always_0
            assign rd_progempty = 1'b0;
        end
        
        // Programmable empty flag is the same as the empty flag
        else if (PROGEMPTY == 1) begin: rd_progempty_is_rd_empty
            assign rd_progempty = rd_empty;
        end
        
        // Extra logic is needed to assert the programmable empty flag
        else if (PROGEMPTY <= DEPTH) begin: rd_progempty_is_extra_logic
            
            // Programmable empty flag register
            logic progempty_reg;
            initial progempty_reg = 1'b1;
            always @(posedge rst, posedge clk)
                if (rst)
                    progempty_reg <= '1;
                else if (clear)
                    progempty_reg <= '1;
                else if (progempty_reg)
                    progempty_reg <= ~((used_cnt == (PROGEMPTY - 1)) & wr_ena & ~rd_ena);
                else
                    progempty_reg <= (used_cnt == PROGEMPTY) & ~wr_ena & rd_ena;
            assign rd_progempty = progempty_reg;
            
        end
        
        // Programmable empty flag is always 1
        else begin: rd_progempty_is_always_1
            assign rd_progempty = 1'b1;
        end
        
    endgenerate
    
    
    // FIFO memory buffer
    always @(posedge clk)
        if (wr_ena) begin
            buffer[wr_cnt] <= wr_data;
        end
    
    
    // Data to read
    generate
        // "Show ahead" mode - the data becomes available before rd_req is asserted
        if (SHOWAHEAD == "ON") begin: show_ahead_mode
            assign rd_data = buffer[rd_cnt];
        end
        
        // Normal mode - the data becomes available after rd_req is asserted
        else begin: normal_mode
            
            // Data read register
            logic [WIDTH - 1 : 0] rd_data_reg;
            initial rd_data_reg <= '0;
            always @(posedge rst, posedge clk)
                if (rst)
                    rd_data_reg <= '0;
                else if (clear)
                    rd_data_reg <= '0;
                else if (rd_req)
                    rd_data_reg <= buffer[rd_cnt];
                else
                    rd_data_reg <= rd_data_reg;
            
            assign rd_data = rd_data_reg;
        end
    endgenerate
    
    
endmodule // sfifo