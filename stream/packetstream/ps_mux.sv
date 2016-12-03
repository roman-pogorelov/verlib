/*
    //------------------------------------------------------------------------------------
    //      Мультиплексор потокового интерфейса PacketStream
    ps_mux
    #(
        .WIDTH      (), // Разрядность потока
        .SINKS      ()  // Количество входных интерфейсов (SINKS > 1)
    )
    the_ps_mux
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Шина выбора активного входа
        .select     (), // i  [$clog2(SINKS) - 1 : 0]
        
        // Входные потоковые интерфейсы
        .i_dat      (), // i  [SINKS - 1 : 0][WIDTH - 1 : 0]
        .i_val      (), // i  [SINKS - 1 : 0]
        .i_eop      (), // i  [SINKS - 1 : 0]
        .i_rdy      (), // o  [SINKS - 1 : 0]
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_mux
*/

module ps_mux
#(
    parameter int unsigned                          WIDTH = 8,  // Разрядность потока
    parameter int unsigned                          SINKS = 2   // Количество входных интерфейсов (более 1-го)
)
(
    // Сброс и тактирование
    input  logic                                    reset,
    input  logic                                    clk,
    
    // Шина выбора активного входа
    input  logic [$clog2(SINKS) - 1 : 0]            select,
    
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
    //      Описание сигналов
    logic [SINKS - 1 : 0]                           select_pos;     // Позиционный код выбираемого канала
    logic [$clog2(SINKS) - 1 : 0]                   selected;       // Индекс выбранного входа
    logic [SINKS - 1 : 0]                           selected_pos;   // Позиционный код выбранного канала
    //
    logic [WIDTH - 1 : 0]                           keep_dat;       // Входной потоковый интерфейс модуля
    logic                                           keep_val;       // захвата и удержания параметров пакета
    logic                                           keep_eop;       // на все время его прохождения
    logic                                           keep_rdy;       //
    
    //------------------------------------------------------------------------------------
    //      Позиционный код выбираемого канала
    always_comb begin
        select_pos = {SINKS{1'b0}};
        select_pos[select] = 1'b1;
    end
    
    //------------------------------------------------------------------------------------
    //      Модуль захвата и удержания параметров пакета на все время его прохождения
    ps_param_keeper
    #(
        .DWIDTH         (WIDTH),                // Разрядность потока
        .PWIDTH         (SINKS + $clog2(SINKS)) // Разрядность интерфейса параметров
    )
    select_keeper
    (
        // Сброс и тактирование
        .reset          (reset),    // i
        .clk            (clk),      // i
        
        // Входной интерфейс управления параметрами пакета
        .desired_param  ({          // i  [PWIDTH - 1 : 0]
                            select,
                            select_pos
                        }),
        
        // Выходной интерфейс управления параметрами пакета
        // (с фиксацией на время прохождения всего пакета)
        .agreed_param   ({          // o  [PWIDTH - 1 : 0]
                            selected,
                            selected_pos
                        }),
        
        // Входной потоковый интерфейс
        .i_dat          (keep_dat), // i  [DWIDTH - 1 : 0]
        .i_val          (keep_val), // i
        .i_eop          (keep_eop), // i
        .i_rdy          (keep_rdy), // o
        
        // Выходной потоковый интерфейс
        .o_dat          (o_dat),    // o  [DWIDTH - 1 : 0]
        .o_val          (o_val),    // o
        .o_eop          (o_eop),    // o
        .o_rdy          (o_rdy)     // i
    ); // select_keeper
    
    //------------------------------------------------------------------------------------
    //      Логика мультиплексирования
    assign keep_dat = i_dat[selected];
    assign keep_val = i_val[selected];
    assign keep_eop = i_eop[selected];
    assign i_rdy    = {SINKS{keep_rdy}} & selected_pos;
    
endmodule // ps_mux