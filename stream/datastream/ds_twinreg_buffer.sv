/*
    //------------------------------------------------------------------------------------
    //      Буфер потокового интерфейса DataStream на двух регистрах, лишенный
    //      комбинационных связей между входами и выходами
    ds_twinreg_buffer
    #(
        .WIDTH      ()  // Разрядность потокового интерфейса
    )
    the_ds_twinreg_buffer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_rdy      ()  // i
    ); // the_ds_twinreg_buffer
*/

module ds_twinreg_buffer
#(
    parameter int unsigned          WIDTH = 8   // Разрядность потокового интерфейса
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
    logic [WIDTH - 1 : 0]           i_dat_reg;      // Регистр данных входной ступени
    logic [WIDTH - 1 : 0]           o_dat_reg;      // Регистр данных выходной ступени
    logic                           i_val_reg;      // Регистр признака достоверности входной ступени
    logic                           o_val_reg;      // Регистр признака достоверности выходной ступени
    
    //------------------------------------------------------------------------------------
    //      Регистр данных входной ступени
    initial i_dat_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            i_dat_reg <= '0;
        else if (~i_val_reg)
            i_dat_reg <= i_dat;
        else
            i_dat_reg <= i_dat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр данных выходной ступени
    initial o_dat_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            o_dat_reg <= '0;
        else if (~o_val_reg | o_rdy)
            o_dat_reg <= i_val_reg ? i_dat_reg : i_dat;
        else
            o_dat_reg <= o_dat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака достоверности входной ступени
    initial i_val_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            i_val_reg <= '0;
        else if (~i_val_reg | ~o_val_reg | o_rdy)
            i_val_reg <= ~(~o_val_reg | o_rdy) & i_val;
        else
            i_val_reg <= i_val_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака достоверности выходной ступени
    initial o_val_reg = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            o_val_reg <= '0;
        else if (~o_val_reg | o_rdy)
            o_val_reg <= i_val_reg | i_val;
        else
            o_val_reg <= o_val_reg;
    
    //------------------------------------------------------------------------------------
    //      Формирование выходных сигналов потоковых интерфейсов
    assign o_dat =  o_dat_reg;
    assign o_val =  o_val_reg;
    assign i_rdy = ~i_val_reg;
    
endmodule // ds_twinreg_buffer