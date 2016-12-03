/*
    //------------------------------------------------------------------------------------
    //      Модуль разветвления потокового интерфейса PacketStream
    ps_splitter
    #(
        .WIDTH          (), // Разрядность потока
        .SOURCES        ()  // Количество выходных интерфейсов
    )
    the_ps_splitter
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Включение выходных интерфейсов
        .active         (), // i  [SOURCES - 1 : 0]
        
        // Входной потоковый интерфейс
        .i_dat          (), // i  [WIDTH - 1 : 0]
        .i_val          (), // i
        .i_eop          (), // i
        .i_rdy          (), // o
        
        // Выходные потоковые интерфейсы
        .o_dat          (), // o  [SOURCES - 1 : 0][WIDTH - 1 : 0]
        .o_val          (), // o  [SOURCES - 1 : 0]
        .o_eop          (), // o  [SOURCES - 1 : 0]
        .o_rdy          ()  // i  [SOURCES - 1 : 0]
    ); // the_ps_splitter
*/

module ps_splitter
#(
    parameter int unsigned                          WIDTH   = 8,    // Разрядность потока
    parameter int unsigned                          SOURCES = 4     // Количество выходных интерфейсов
)
(
    // Сброс и тактирование
    input  logic                                    reset,
    input  logic                                    clk,
    
    // Включение выходных интерфейсов
    input  logic [SOURCES - 1 : 0]                  active,
    
    // Входной потоковый интерфейс
    input  logic [WIDTH - 1 : 0]                    i_dat,
    input  logic                                    i_val,
    input  logic                                    i_eop,
    output logic                                    i_rdy,
    
    // Выходные потоковые интерфейсы
    output logic [SOURCES - 1 : 0][WIDTH - 1 : 0]   o_dat,
    output logic [SOURCES - 1 : 0]                  o_val,
    output logic [SOURCES - 1 : 0]                  o_eop,
    input  logic [SOURCES - 1 : 0]                  o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [SOURCES - 1 : 0]                         int_active; // Промежуточные сигналы для стыковки
    logic [WIDTH - 1 : 0]                           int_dat;    // с модулем захвата и удержания параметров
    logic                                           int_val;    // пакета на все время его прохождения
    logic                                           int_eop;    //
    logic                                           int_rdy;    //
    
    //------------------------------------------------------------------------------------
    //      Модуль захвата и удержания параметров пакета на все время его прохождения
    ps_param_keeper
    #(
        .DWIDTH         (WIDTH),        // Разрядность потока
        .PWIDTH         (SOURCES)       // Разрядность интерфейса параметров
    )
    active_keeper
    (
        // Сброс и тактирование
        .reset          (reset),        // i
        .clk            (clk),          // i
        
        // Входной интерфейс управления параметрами пакета
        .desired_param  (active),       // i  [PWIDTH - 1 : 0]
        
        // Выходной интерфейс управления параметрами пакета
        // (с фиксацией на время прохождения всего пакета)
        .agreed_param   (int_active),   // o  [PWIDTH - 1 : 0]
        
        // Входной потоковый интерфейс
        .i_dat          (i_dat),        // i  [DWIDTH - 1 : 0]
        .i_val          (i_val),        // i
        .i_eop          (i_eop),        // i
        .i_rdy          (i_rdy),        // o
        
        // Выходной потоковый интерфейс
        .o_dat          (int_dat),      // o  [DWIDTH - 1 : 0]
        .o_val          (int_val),      // o
        .o_eop          (int_eop),      // o
        .o_rdy          (int_rdy)       // i
    ); // active_keeper
    
    //------------------------------------------------------------------------------------
    //      Генерация выходных сигналов потоковых интерфейсов
    generate
        genvar i, j;
        logic [SOURCES - 1 : 0][SOURCES - 1 : 0] mask;
        for (i = 0; i < SOURCES; i++) begin: splitter_gen
            for (j = 0; j < SOURCES; j++) begin: mask_gen
                assign mask[i][j] = (i == j);
            end
            assign o_dat[i] = int_dat;
            assign o_val[i] = int_val & int_active[i] & (&(o_rdy | mask[i] | ~int_active));
            assign o_eop[i] = int_eop;
        end
    endgenerate
    assign int_rdy = &(o_rdy | ~int_active);
    
endmodule // ps_splitter