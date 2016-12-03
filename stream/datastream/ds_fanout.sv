/*
    //------------------------------------------------------------------------------------
    //      Модуль разветвления потокового интерфейса DataStream
    //      (полностью комбинационный)
    ds_fanout
    #(
        .WIDTH      (), // Разрядность потока
        .SOURCES    ()  // Количество выходных интерфейсов
    )
    the_ds_fanout
    (
        // Сброс и тактирование
        .reset      (), // i  Не используется
        .clk        (), // i  Не используется
        
        // Управление активными выходами (позиционный код)
        .active     (), // i  [SOURCES - 1 : 0]
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o
        
        // Выходные потоковые интерфейсы
        .o_dat      (), // o  [SOURCES - 1 : 0][WIDTH - 1 : 0]
        .o_val      (), // o  [SOURCES - 1 : 0]
        .o_rdy      ()  // i  [SOURCES - 1 : 0]
    ); // the_ds_fanout
*/

module ds_fanout
#(
    parameter int unsigned                          WIDTH   = 8,    // Разрядность потока
    parameter int unsigned                          SOURCES = 2     // Количество выходных интерфейсов
)
(
    // Сброс и тактирование
    input  logic                                    reset,          // Не используется
    input  logic                                    clk,            // Не используется
    
    // Управление активными выходами (позиционный код)
    input  logic [SOURCES - 1 : 0]                  active,
    
    // Входной потоковый интерфейс
    input  logic [WIDTH - 1 : 0]                    i_dat,
    input  logic                                    i_val,
    output logic                                    i_rdy,
    
    // Выходные потоковые интерфейсы
    output logic [SOURCES - 1 : 0][WIDTH - 1 : 0]   o_dat,
    output logic [SOURCES - 1 : 0]                  o_val,
    input  logic [SOURCES - 1 : 0]                  o_rdy
);
    //------------------------------------------------------------------------------------
    //      Генерация сигналов выходных потоковых интерфейсов
    generate
        genvar i, j;
        logic [SOURCES - 1 : 0][SOURCES - 1 : 0] mask;
        for (i = 0; i < SOURCES; i++) begin: fanout_gen
            for (j = 0; j < SOURCES; j++) begin: mask_gen
                assign mask[i][j] = (i == j);
            end
            assign o_dat[i] = i_dat;
            assign o_val[i] = i_val & active[i] & (&(o_rdy | mask[i] | ~active));
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Формирование сигнала i_rdy
    assign i_rdy = &(o_rdy | ~active);
    
endmodule // ds_fanout