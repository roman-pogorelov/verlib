/*
    //------------------------------------------------------------------------------------
    //      Asynchronous FIFO
    afifo
    #(
        .WIDTH          (), // Data width (WIDTH > 0)
        .DEPTH          (), // FIFO depth (DEPTH > 1)
        .PROGFULL       (), // Threshold of programmable full flag (wr_progfull = 1 if used >= PROGFULL)
        .PROGEMPTY      (), // Threshold of programmable empty flag (rd_progempty = 1 if used < PROGEMPTY)
        .SHOWAHEAD      (), // "Show ahead" mode selection ("ON, "OFF")
        .RAMTYPE        (), // RAM resource type ("AUTO", "MLAB", "M10K, "LOGIC", ...)
        .ESYNCSTAGES    ()  // Number of extra stages in a synchronization circuit
    )
    the_afifo
    (
        // Asynchronous reset
        .rst            (), // i
        
        // Wrire side
        .wr_clk         (), // i
        .wr_data        (), // i  [WIDTH - 1 : 0]
        .wr_req         (), // i
        .wr_empty       (), // o
        .wr_full        (), // o
        .wr_progfull    (), // o
        .wr_used        (), // o  [$clog2(DEPTH + 1) - 1 : 0]
        
        // Read side
        .rd_clk         (), // i
        .rd_data        (), // o  [WIDTH - 1 : 0]
        .rd_req         (), // i
        .rd_empty       (), // o
        .rd_full        (), // o
        .rd_progempty   (), // o
        .rd_used        ()  // o  [$clog2(DEPTH + 1) - 1 : 0]
    ); // the_afifo
*/

module afifo
#(
    parameter int unsigned                      WIDTH       = 8,        // Data width (WIDTH > 0)
    parameter int unsigned                      DEPTH       = 8,        // FIFO depth must be a power of two (2, 4, 8, ...)
    parameter int unsigned                      PROGFULL    = 0,        // Threshold of programmable full flag (wr_progfull = 1 if used >= PROGFULL)
    parameter int unsigned                      PROGEMPTY   = 0,        // Threshold of programmable empty flag (rd_progempty = 1 if used < PROGEMPTY)
    parameter                                   SHOWAHEAD   = "ON",     // "Show ahead" mode selection ("ON, "OFF")
    parameter                                   RAMTYPE     = "AUTO",   // RAM resource type ("AUTO", "MLAB", "M10K, "LOGIC", ...)
    parameter int unsigned                      ESYNCSTAGES = 0         // Number of extra stages in a synchronization circuit
)
(
    // Asynchronous reset
    input  logic                                rst,
    
    // Wrire side
    input  logic                                wr_clk,
    input  logic [WIDTH - 1 : 0]                wr_data,
    input  logic                                wr_req,
    output logic                                wr_empty,
    output logic                                wr_full,
    output logic                                wr_progfull,
    output logic [$clog2(DEPTH + 1) - 1 : 0]    wr_used,
    
    // Read side
    input  logic                                rd_clk,
    output logic [WIDTH - 1 : 0]                rd_data,
    input  logic                                rd_req,
    output logic                                rd_empty,
    output logic                                rd_full,
    output logic                                rd_progempty,
    output logic [$clog2(DEPTH + 1) - 1 : 0]    rd_used
);
    // Constant declarations
    localparam int unsigned CWIDTH =$clog2(DEPTH);  // Counters width
    
    
    // Memory block declarations
    (* ramstyle = RAMTYPE *) reg [WIDTH - 1 : 0] buffer [(2**CWIDTH) - 1 : 0];
    
    
    // Signal declarations
    logic                   wr_rst;
    logic                   rd_rst;
    //
    logic                   wr_ena;
    logic                   rd_ena;
    //
    logic [CWIDTH : 0]      wr_cnt;
    logic [CWIDTH : 0]      wr_cnt_next;
    logic [CWIDTH - 1 : 0]  wr_addr;
    logic [CWIDTH : 0]      wr_gray_cnt;
    logic [CWIDTH : 0]      wr_gray_cnt_next;
    logic [CWIDTH : 0]      wr_gray_ptr;
    //
    logic [CWIDTH : 0]      rd_cnt;
    logic [CWIDTH : 0]      rd_cnt_next;
    logic [CWIDTH - 1 : 0]  rd_addr;
    logic [CWIDTH : 0]      rd_gray_cnt;
    logic [CWIDTH : 0]      rd_gray_cnt_next;
    logic [CWIDTH : 0]      rd_gray_ptr;
    //
    logic                   wr_empty_reg;
    logic                   wr_full_reg;
    logic                   rd_empty_reg;
    logic                   rd_full_reg;
    //
    logic [CWIDTH : 0]      wr_used_reg;
    logic [CWIDTH : 0]      rd_used_reg;
    
    
    // Binary to gray conversion
    function automatic logic [CWIDTH : 0] bin2gray(input logic [CWIDTH : 0] bin);
        bin2gray = {1'b0, bin[CWIDTH : 1]} ^ bin;
    endfunction
    
    
    // Gray to binary conversion
    function automatic logic [CWIDTH : 0] gray2bin(input logic [CWIDTH : 0] gray);
        gray2bin[CWIDTH] = gray[CWIDTH];
        for (int i = CWIDTH - 1; i >= 0; i--)
            gray2bin[i] = gray2bin[i + 1] ^ gray[i];
    endfunction
    
    
    //------------------------------------------------------------------------------------
    //      Synchronizer of an asynchronous reset (preset) signal
    areset_synchronizer
    #(
        .EXTRA_STAGES   (ESYNCSTAGES),  // Number of extra stages
        .ACTIVE_LEVEL   (1'b1)          // Active level of a reset (preset) signal
    )
    wr_areset_synchronizer
    (
        // Clock
        .clk            (wr_clk),       // i
        
        // Asynchronous reset (preset)
        .areset         (rst),          // i
        
        // Synchronous reset (preset)
        .sreset         (wr_rst)        // o
    ); // wr_areset_synchronizer
    
    
    //------------------------------------------------------------------------------------
    //      Synchronizer of an asynchronous reset (preset) signal
    areset_synchronizer
    #(
        .EXTRA_STAGES   (ESYNCSTAGES),  // Number of extra stages
        .ACTIVE_LEVEL   (1'b1)          // Active level of a reset (preset) signal
    )
    rd_areset_synchronizer
    (
        // Clock
        .clk            (rd_clk),       // i
        
        // Asynchronous reset (preset)
        .areset         (rst),          // i
        
        // Synchronous reset (preset)
        .sreset         (rd_rst)        // o
    ); // rd_areset_synchronizer
    
    
    // Write and read strobes
    assign wr_ena = wr_req & ~wr_full;
    assign rd_ena = rd_req & ~rd_empty;
    
    
    // Write address counter
    initial wr_cnt = '0;
    always @(posedge wr_rst, posedge wr_clk)
        if (wr_rst)
            wr_cnt <= '0;
        else
            wr_cnt <= wr_cnt_next;
    assign wr_cnt_next = wr_cnt + wr_ena;
    assign wr_addr = wr_cnt[CWIDTH - 1 : 0];
    
    
    // Write gray counter
    initial wr_gray_cnt = '0;
    always @(posedge wr_rst, posedge wr_clk)
        if (wr_rst)
            wr_gray_cnt <= '0;
        else
            wr_gray_cnt <= wr_gray_cnt_next;
    assign wr_gray_cnt_next = bin2gray(wr_cnt_next);
    
    //------------------------------------------------------------------------------------
    //      Flipflop synchronizer
    ff_synchronizer
    #(
        .WIDTH          (CWIDTH + 1),           // Data width
        .EXTRA_STAGES   (ESYNCSTAGES),          // Number of extra stages in synchronization circuit
        .RESET_VALUE    ({CWIDTH + 1{1'b0}})    // Value after reset
    )
    wr2rd_synchronizer
    (
        // Сброс и тактирование
        .reset          (rd_rst),               // i
        .clk            (rd_clk),               // i
        
        // Асинхронный входной сигнал
        .async_data     (wr_gray_cnt),          // i  [WIDTH - 1 : 0]
        
        // Синхронный выходной сигнал
        .sync_data      (rd_gray_ptr)           // o  [WIDTH - 1 : 0]
    ); // wr2rd_synchronizer
    
    
    // Read address counter
    initial rd_cnt = '0;
    always @(posedge rd_rst, posedge rd_clk)
        if (rd_rst)
            rd_cnt <= '0;
        else
            rd_cnt <= rd_cnt_next;
    assign rd_cnt_next = rd_cnt + rd_ena;
    assign rd_addr = rd_cnt[CWIDTH - 1 : 0];
    
    
    // Read gray counter
    initial rd_gray_cnt = '0;
    always @(posedge rd_rst, posedge rd_clk)
        if (rd_rst)
            rd_gray_cnt <= '0;
        else
            rd_gray_cnt <= rd_gray_cnt_next;
    assign rd_gray_cnt_next = bin2gray(rd_cnt_next);
    
    
    //------------------------------------------------------------------------------------
    //      Flipflop synchronizer
    ff_synchronizer
    #(
        .WIDTH          (CWIDTH + 1),           // Data width
        .EXTRA_STAGES   (ESYNCSTAGES),          // Number of extra stages in synchronization circuit
        .RESET_VALUE    ({CWIDTH + 1{1'b0}})    // Value after reset
    )
    rd2wr_synchronizer
    (
        // Сброс и тактирование
        .reset          (wr_rst),               // i
        .clk            (wr_clk),               // i
        
        // Асинхронный входной сигнал
        .async_data     (rd_gray_cnt),          // i  [WIDTH - 1 : 0]
        
        // Синхронный выходной сигнал
        .sync_data      (wr_gray_ptr)           // o  [WIDTH - 1 : 0]
    ); // rd2wr_synchronizer
    
    
    // Write empty flag register
    initial wr_empty_reg = '1;
    always @(posedge wr_rst, posedge wr_clk)
        if (wr_rst)
            wr_empty_reg <= '1;
        else
            wr_empty_reg <= (wr_gray_cnt_next == wr_gray_ptr);
    assign wr_empty = wr_empty_reg;
    
    
    // Write full flag register
    initial wr_full_reg = '0;
    always @(posedge wr_rst, posedge wr_clk)
        if (wr_rst)
            wr_full_reg <= '0;
        else
            wr_full_reg <= (wr_gray_cnt_next == ({~wr_gray_ptr[CWIDTH : CWIDTH - 1], wr_gray_ptr[CWIDTH - 2 : 0]}));
    assign wr_full = wr_full_reg;
    
    
    // Programmable write full flag
    generate
        
        // Programmable full flag is always 1
        if (PROGFULL == 0) begin: wr_progfull_is_always_1
            assign wr_progfull = 1'b1;
        end
        
        // Extra logic is needed to assert the programmable full flag
        else if (PROGFULL < DEPTH) begin: wr_progfull_is_extra_logic
            
            // Programmable full flag register
            logic wr_progfull_reg;
            initial wr_progfull_reg = '0;
            always @(posedge wr_rst, posedge wr_clk)
                if (wr_rst)
                    wr_progfull_reg <= '0;
                else
                    wr_progfull_reg <= ((wr_cnt_next - gray2bin(wr_gray_ptr)) >= PROGFULL);
            
            assign wr_progfull = wr_progfull_reg;
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
    
    
    // Read epmty flag register
    initial rd_empty_reg = '1;
    always @(posedge rd_rst, posedge rd_clk)
        if (rd_rst)
            rd_empty_reg <= '1;
        else
            rd_empty_reg <= (rd_gray_cnt_next == rd_gray_ptr);
    assign rd_empty = rd_empty_reg;
    
    
    // Read full flag register
    initial rd_full_reg = '0;
    always @(posedge rd_rst, posedge rd_clk)
        if (rd_rst)
            rd_full_reg <= '0;
        else
            rd_full_reg <= (rd_gray_cnt_next == ({~rd_gray_ptr[CWIDTH : CWIDTH - 1], rd_gray_ptr[CWIDTH - 2 : 0]}));
    assign rd_full = rd_full_reg;
    
    
    // Programmable read empty flag
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
            logic rd_progempty_reg;
            initial rd_progempty_reg = 1'b1;
            always @(posedge rd_rst, posedge rd_clk)
                if (rd_rst)
                    rd_progempty_reg <= '1;
                else
                    rd_progempty_reg <= ((gray2bin(rd_gray_ptr) - rd_cnt_next) < PROGEMPTY);
            assign rd_progempty = rd_progempty_reg;
            
        end
        
        // Programmable empty flag is always 1
        else begin: rd_progempty_is_always_1
            assign rd_progempty = 1'b1;
        end
        
    endgenerate
    
    
    // Count of words on the write side
    initial wr_used_reg = '0;
    always @(posedge wr_rst, posedge wr_clk)
        if (wr_rst)
            wr_used_reg <= '0;
        else
            wr_used_reg <= wr_cnt_next - gray2bin(wr_gray_ptr);
    assign wr_used = wr_used_reg[$clog2(DEPTH + 1) - 1 : 0];
    
    
    // Count of words on the read side
    initial rd_used_reg = '0;
    always @(posedge rd_rst, posedge rd_clk)
        if (rd_rst)
            rd_used_reg <= '0;
        else
            rd_used_reg <= gray2bin(rd_gray_ptr) - rd_cnt_next;
    assign rd_used = rd_used_reg[$clog2(DEPTH + 1) - 1 : 0];
    
    
    // FIFO memory buffer
    always @(posedge wr_clk)
        if (wr_ena) begin
            buffer[wr_addr] <= wr_data;
        end
    
    
    // Data to read
    generate
        // "Show ahead" mode - the data becomes available before rd_req is asserted
        if (SHOWAHEAD == "ON") begin: show_ahead_mode
            assign rd_data = buffer[rd_addr];
        end
        
        // Normal mode - the data becomes available after rd_req is asserted
        else begin: normal_mode
            
            // Data read register
            logic [WIDTH - 1 : 0] rd_data_reg;
            initial rd_data_reg <= '0;
            always @(posedge rd_rst, posedge rd_clk)
                if (rd_rst)
                    rd_data_reg <= '0;
                else if (rd_req)
                    rd_data_reg <= buffer[rd_addr];
                else
                    rd_data_reg <= rd_data_reg;
            assign rd_data = rd_data_reg;
            
        end
    endgenerate
    
endmodule: afifo