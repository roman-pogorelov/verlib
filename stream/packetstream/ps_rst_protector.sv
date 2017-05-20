/*
    //------------------------------------------------------------------------------------
    //      Модуль защиты потока в состоянии сброса (удаляет пакеты входного потока)
    ps_rst_protector
    #(
        .WIDTH      ()  // Разрядность потока
    )
    the_ps_rst_protector
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
    ); // the_ps_rst_protector
*/
module ps_rst_protector
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
    //      Объявление сигналов
    logic                           rst_state;
    
    //------------------------------------------------------------------------------------
    //      Регистр состояния сброса
    initial rst_state = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            rst_state <= '1;
        else
            rst_state <= '0;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов потоковых интерфейсов
    assign i_rdy = o_rdy |  rst_state;
    assign o_val = i_val & ~rst_state;
    assign o_dat = i_dat;
    assign o_eop = i_eop;
    
endmodule: ps_rst_protector