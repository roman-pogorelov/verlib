/*
    //------------------------------------------------------------------------------------
    //      Модуль защиты от прохождения пакетов без признака начала
    ps_sop_protector
    #(
        .WIDTH      ()  // Разрядность потока
    )
    the_ps_sop_protector
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_sop      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_sop      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_sop_protector
*/

module ps_sop_protector
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
    input  logic                    i_sop,
    input  logic                    i_eop,
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    output logic                    o_sop,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                           pass_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр разрешения прохождения потока
    always @(posedge reset, posedge clk)
        if (reset)
            pass_reg <= '0;
        else if (pass_reg)
            pass_reg <= ~(i_val & i_eop & o_rdy);
        else
            pass_reg <= i_val & i_sop & ~i_eop & o_rdy;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов потоковых интерфейсов
    assign i_rdy = o_rdy | (~pass_reg & ~i_sop);
    assign o_val = i_val & ( pass_reg |  i_sop);
    assign o_dat = i_dat;
    assign o_sop = i_sop;
    assign o_eop = i_eop;
    
endmodule: ps_sop_protector