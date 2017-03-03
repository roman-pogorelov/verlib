/*
    //------------------------------------------------------------------------------------
    //      Буфер на одной регистровой ступени для потокового интерфейса PacketStream
    ps_onereg_buffer
    #(
        .WIDTH      ()  // Разрядность потокового интерфейса
    )
    the_ps_onereg_buffer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_onereg_buffer
*/

module ps_onereg_buffer
#(
    parameter int unsigned          WIDTH = 8       // Разрядность потокового интерфейса
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Входной потоковый интерфейс
    input  logic [WIDTH - 1 : 0]    i_dat,
    input  logic                    i_val,
    input  logic                    i_eop,
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);  
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [WIDTH - 1 : 0]           dat_reg;    // Регистр данных
    logic                           val_reg;    // Регистр признака достоверности
    logic                           eop_reg;    // Регистр признака конца пакета
    
    //------------------------------------------------------------------------------------
    //      Регистр данных
    initial dat_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            dat_reg = '0;
        else if (i_rdy)
            dat_reg <= i_dat;
        else
            dat_reg <= dat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака достоверности
    initial val_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            val_reg <= '0;
        else if (i_rdy)
            val_reg <= i_val;
        else
            val_reg <= val_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака конца пакета
    initial eop_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            eop_reg <= '0;
        else if (i_rdy)
            eop_reg <= i_eop;
        else
            eop_reg <= eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Выходные сигналы потоковых интерфейсов
    assign i_rdy = o_rdy | ~val_reg;
    assign o_dat = dat_reg;
    assign o_val = val_reg;
    assign o_eop = eop_reg;
    
endmodule // ps_onereg_buffer