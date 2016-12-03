/*
    //------------------------------------------------------------------------------------
    //      Буфер потокового интерфейса PacketStream на двух регистрах, лишенный
    //      комбинационных связей между входами и выходами
    ps_twinreg_buffer
    #(
        .WIDTH      ()  // Разрядность потока
    )
    the_ps_twinreg_buffer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_twinreg_buffer
*/

module ps_twinreg_buffer
#(
    parameter int unsigned          WIDTH = 8   // Разрядность потока
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
    logic [WIDTH - 1 : 0]           i_dat_reg;  // Регистр данных входной ступени
    logic [WIDTH - 1 : 0]           o_dat_reg;  // Регистр данных выходной ступени
    logic                           i_eop_reg;  // Регистр признака конца пакета входной ступени
    logic                           o_eop_reg;  // Регистр признака конца пакета выходной ступени
    logic                           i_val_reg;  // Регистр признака достоверности входной ступени
    logic                           o_val_reg;  // Регистр признака достоверности выходной ступени
    
    //------------------------------------------------------------------------------------
    //      Регистр данных входной ступени
    always @(posedge reset, posedge clk)
        if (reset)
            i_dat_reg <= '0;
        else if (~i_val_reg)
            i_dat_reg <= i_dat;
        else
            i_dat_reg <= i_dat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр данных выходной ступени
    always @(posedge reset, posedge clk)
        if (reset)
            o_dat_reg <= '0;
        else if (~o_val_reg | o_rdy)
            o_dat_reg <= i_val_reg ? i_dat_reg : i_dat;
        else
            o_dat_reg <= o_dat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака конца пакета входной ступени
    always @(posedge reset, posedge clk)
        if (reset)
            i_eop_reg <= '0;
        else if (~i_val_reg)
            i_eop_reg <= i_eop;
        else
            i_eop_reg <= i_eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака конца пакета выходной ступени
    always @(posedge reset, posedge clk)
        if (reset)
            o_eop_reg <= '0;
        else if (~o_val_reg | o_rdy)
            o_eop_reg <= i_val_reg ? i_eop_reg : i_eop;
        else
            o_eop_reg <= o_eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака достоверности входной ступени
    always @(posedge reset, posedge clk)
        if (reset)
            i_val_reg <= '0;
        else if (~i_val_reg | ~o_val_reg | o_rdy)
            i_val_reg <= ~(~o_val_reg | o_rdy) & i_val;
        else
            i_val_reg <= i_val_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака достоверности выходной ступени
    always @(posedge reset, posedge clk)
        if (reset)
            o_val_reg <= '0;
        else if (~o_val_reg | o_rdy)
            o_val_reg <= i_val_reg | i_val;
        else
            o_val_reg <= o_val_reg;
    
    //------------------------------------------------------------------------------------
    //      Формирование выходных сигналов
    assign o_dat =  o_dat_reg;
    assign o_val =  o_val_reg;
    assign o_eop =  o_eop_reg;
    assign i_rdy = ~i_val_reg;
    
endmodule // ps_twinreg_buffer