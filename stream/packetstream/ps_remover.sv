/*
    //------------------------------------------------------------------------------------
    //      Модуль удаления пакетов потокового интерфейса PacketStream
    ps_remover
    #(
        .WIDTH          ()  // Разрядность потока
    )
    the_ps_remover
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Управление удалением
        .remove         (), // i
        
        // Статусные сигналы удаления
        .wremoved       (), // o
        .premoved       (), // o
        
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
    ); // the_ps_remover
*/

module ps_remover
#(
    parameter int unsigned          WIDTH   = 8     // Разрядность потока
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Управление удалением
    input  logic                    remove,
    
    // Статусные сигналы удаления
    output logic                    wremoved,
    output logic                    premoved,
    
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
    logic                           removing;   // Признак разрешения удаления
    //
    logic [WIDTH - 1 : 0]           keep_dat;   // Выходной потоковый интерфейс модуля 
    logic                           keep_val;   // удержания параметров пакета на все
    logic                           keep_eop;   // время его прохождения
    logic                           keep_rdy;   //
    
    //------------------------------------------------------------------------------------
    //      Модуль захвата и удержания параметров пакета на все время его прохождения
    ps_param_keeper
    #(
        .DWIDTH         (WIDTH),    // Разрядность потока
        .PWIDTH         (1)         // Разрядность интерфейса параметров
    )
    remove_request_keeper
    (
        // Сброс и тактирование
        .reset          (reset),    // i
        .clk            (clk),      // i
        
        // Входной интерфейс управления параметрами пакета
        .desired_param  (remove),   // i  [PWIDTH - 1 : 0]
        
        // Выходной интерфейс управления параметрами пакета
        // (с фиксацией на время прохождения всего пакета)
        .agreed_param   (removing), // o  [PWIDTH - 1 : 0]
        
        // Входной потоковый интерфейс
        .i_dat          (i_dat),    // i  [DWIDTH - 1 : 0]
        .i_val          (i_val),    // i
        .i_eop          (i_eop),    // i
        .i_rdy          (i_rdy),    // o
        
        // Выходной потоковый интерфейс
        .o_dat          (keep_dat), // o  [DWIDTH - 1 : 0]
        .o_val          (keep_val), // o
        .o_eop          (keep_eop), // o
        .o_rdy          (keep_rdy)  // i
    ); // remove_request_keeper
    
    //------------------------------------------------------------------------------------
    //      Логика удаления
    assign o_dat = keep_dat;
    assign o_eop = keep_eop & ~removing;
    assign o_val = keep_val & ~removing;
    assign keep_rdy = o_rdy | removing;
    
    //------------------------------------------------------------------------------------
    //      Статусные сигналы удаления
    assign wremoved = removing & keep_val;
    assign premoved = wremoved & keep_eop;
    
endmodule // ps_remover