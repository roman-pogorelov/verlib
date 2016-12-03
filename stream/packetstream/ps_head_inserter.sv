/*
    //------------------------------------------------------------------------------------
    //      Модуль вставки "головы" пакета потокового интерфейса PacketStream
    ps_head_inserter
    #(
        .WIDTH          ()  // Разрядность потока
    )
    the_ps_head_inserter
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Разрешение вставки заголовка
        .insert         (), // i
        
        // Потоковый интерфейс выдачи заголовка
        .h_dat          (), // i  [WIDTH - 1 : 0]
        .h_val          (), // i
        .h_eop          (), // i
        .h_rdy          (), // o
        
        // Входной потоковый интерфейс
        .i_dat          (), // i  [WIDTH - 1 : 0]
        .i_val          (), // i
        .i_eop          (), // i
        .i_rdy          (), // o
        
        // Выходной потоковый интерфейс
        .o_dat          (), // o  [WIDTH - 1 : 0]
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ps_head_inserter
*/

module ps_head_inserter
#(
    parameter                       WIDTH = 8   // Разрядность потока
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Разрешение вставки заголовка
    input  logic                    insert,
    
    // Входной потоковый заголовка
    input  logic [WIDTH - 1 : 0]    h_dat,
    input  logic                    h_val,
    input  logic                    h_eop,
    output logic                    h_rdy,
    
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
    logic                           sop_reg;
    logic                           head_inserted_reg;
    logic                           head_inserted;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака начала пакета
    initial sop_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            sop_reg <= '1;
        else if (o_val & o_rdy)
            sop_reg <= o_eop;
        else
            sop_reg <= sop_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака окончания вставки заголовка
    always @(posedge reset, posedge clk)
        if (reset)
            head_inserted_reg <= '0;
        else if (o_val & o_rdy)
            if (head_inserted_reg)
                head_inserted_reg <= ~o_eop;
            else
                head_inserted_reg <= sop_reg ? (~insert | h_eop) : h_eop;
        else
            head_inserted_reg <= head_inserted_reg;
    
    //------------------------------------------------------------------------------------
    //      Признак окончания вставки заголовка
    assign head_inserted = sop_reg ? ~insert : head_inserted_reg;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов управления потоками
    assign h_rdy = ~head_inserted & o_rdy;
    assign i_rdy =  head_inserted & o_rdy;
    assign o_val =  head_inserted ? i_val : h_val;
    
    //------------------------------------------------------------------------------------
    //      Переключение источников данных
    assign o_dat =  head_inserted ? i_dat : h_dat;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования признака конца пакета на выходе
    assign o_eop =  head_inserted & i_eop;
    
endmodule // ps_head_inserter