/*
    //------------------------------------------------------------------------------------
    //      Буфер на одной регистровой ступени для потокового интерфейса DataStream
    ds_onereg_buffer
    #(
        .WIDTH              ()  // Разрядность потокового интерфейса
    )
    the_ds_onereg_buffer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_rdy      ()  // i
    ); // the_ds_onereg_buffer
*/

module ds_onereg_buffer
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
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    input  logic                    o_rdy
);  
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [WIDTH - 1 : 0]           dat_reg;    // Регистр данных
    logic                           val_reg;    // Регистр признака достоверности
    
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
    //      Выходные сигналы потоковых интерфейсов
    assign i_rdy = o_rdy | ~val_reg;
    assign o_dat = dat_reg;
    assign o_val = val_reg;
    
endmodule // ds_onereg_buffer