/*
    //------------------------------------------------------------------------------------
    //      Арбитр потокового интерфейса PacketStream
    ps_arbitrator
    #(
        .WIDTH          (), // Разрядность потока
        .SINKS          (), // Количество входных интерфейсов (более 1-го)
        .SCHEME         ()  // Схема арбитража ("RR" - циклическая "FP" - фиксированная)
    )
    the_ps_arbitrator
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Входные потоковые интерфейсы
        .i_dat          (), // i  [SINKS - 1 : 0][WIDTH - 1 : 0]
        .i_val          (), // i  [SINKS - 1 : 0]
        .i_eop          (), // i  [SINKS - 1 : 0]
        .i_rdy          (), // o  [SINKS - 1 : 0]
        
        // Выходной потоковый интерфейс
        .o_dat          (), // o  [WIDTH - 1 : 0]
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ps_arbitrator
*/
module ps_arbitrator
#(
    parameter int unsigned                          WIDTH   = 8,    // Разрядность потока
    parameter int unsigned                          SINKS   = 2,    // Количество входных интерфейсов (более 1-го)
    parameter string                                SCHEME  = "RR"  // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
)
(
    // Сброс и тактирование
    input  logic                                    reset,
    input  logic                                    clk,
    
    // Входные потоковые интерфейсы
    input  logic [SINKS - 1 : 0][WIDTH - 1 : 0]     i_dat,
    input  logic [SINKS - 1 : 0]                    i_val,
    input  logic [SINKS - 1 : 0]                    i_eop,
    output logic [SINKS - 1 : 0]                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]                    o_dat,
    output logic                                    o_val,
    output logic                                    o_eop,
    input  logic                                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [SINKS - 1 : 0]                           active_pos;     // Позиционный код активного мастера от арбитра
    logic [$clog2(SINKS) - 1 : 0]                   active_num;     // Номер активного мастера от арбитра
    
    //------------------------------------------------------------------------------------
    //      Арбитр доступа нескольких абонентов к одному ресурсу
    arbitrator
    #(
        .REQS           (SINKS),            // Количество абонентов (REQS > 1)
        .SCHEME         (SCHEME)            // Схема арбитража ("RR" - циклическая, "FP" - фиксированная)
    )
    the_arbitrator
    (
        // Сброс и тактирование
        .reset          (reset),            // i
        .clk            (clk),              // i
        
        // Вектор запросов на обслуживание
        .req            (i_val),            // i  [REQS - 1 : 0]
        
        // Готовность обработать запрос
        .rdy            (o_rdy & o_eop),    // i
        
        // Вектор гранта на обслуживание
        .gnt            (active_pos),       // o  [REQS - 1 : 0]
        
        // Номер порта, получившего грант
        .num            (active_num)        // o  [$clog2(REQS) - 1 : 0]
    ); // the_arbitrator
    
    //------------------------------------------------------------------------------------
    //      Мультиплексирование выбранного арбитром канала
    assign o_dat = i_dat[active_num];
    assign o_val = i_val[active_num];
    assign o_eop = i_eop[active_num];
    assign i_rdy = active_pos & {SINKS{o_rdy}};
    
endmodule // ps_arbitrator