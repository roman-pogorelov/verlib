/*
    //------------------------------------------------------------------------------------
    //      Модуль включения/выключения трафика интерфейса PacketStream
    ps_switch
    #(
        .WIDTH      ()  // Разрядность потока
    )
    the_ps_switch
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Выключение
        .turnoff    (), // i
        
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
    ); // the_ps_switch
*/

module ps_switch
#(
    parameter int unsigned          WIDTH   = 8     // Разрядность потока
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Выключение
    input  logic                    turnoff,
    
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
    logic                           sop_reg;        // Регистр признака начала пакета
    logic                           closed;         // Признак запрета прохождения трафика
    
    //------------------------------------------------------------------------------------
    //      Регистр признака начала пакета
    initial sop_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            sop_reg <= '1;
        else if (i_val & i_rdy)
            sop_reg <= i_eop;
        else
            sop_reg <= sop_reg;
    
    //------------------------------------------------------------------------------------
    //      Признак запрета прохождения трафика
    assign closed = sop_reg & turnoff;
    
    //------------------------------------------------------------------------------------
    //      Логика включения/выключения
    assign o_dat = i_dat;
    assign o_val = i_val & ~closed;
    assign o_eop = i_eop & ~closed;
    assign i_rdy = o_rdy & ~closed;
    
endmodule // ps_switch