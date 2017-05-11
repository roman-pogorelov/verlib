/*
    //------------------------------------------------------------------------------------
    //      Модуль устранения дребезга контактов входного асинхронного сигнала
    debouncer
    #(
        .STABLE_TIME    (), // Временной промежуток, после которого сигнал признается стабильным
        .EXTRA_STAGES   (), // Количество дополнительных ступеней цепи синхронизации
        .RESET_VALUE    ()  // Значение по умолчанию для ступеней цепи синхронизации
    )
    the_debouncer
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Асинхронный дребезжащий входной сигнал
        .bounce         (), // i
        
        // Синхронный стабильный выходной сигнал
        .stable         ()  // o
    ); // the_debouncer
*/
module debouncer
#(
    parameter int unsigned      STABLE_TIME  = 8,   // Временной промежуток, после которого сигнал признается стабильным
    parameter int unsigned      EXTRA_STAGES = 0,   // Количество дополнительных ступеней цепи синхронизации
    parameter logic             RESET_VALUE  = 0    // Значение по умолчанию для ступеней цепи синхронизации
)
(
    // Сброс и тактирование
    input  logic                reset,
    input  logic                clk,
    
    // Асинхронный дребезжащий входной сигнал
    input  logic                bounce,
    
    // Синхронный стабильный выходной сигнал
    output logic                stable
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned     CWIDTH = $clog2(STABLE_TIME);
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                       bounce_sync;
    logic [CWIDTH - 1 : 0]      stable_cnt;
    logic                       stable_reg;
    
    //------------------------------------------------------------------------------------
    //      Модуль синхронизации сигнала на последовательной триггерной цепочке
    ff_synchronizer
    #(
        .WIDTH          (1),            // Разрядность синхронизируемой шины
        .EXTRA_STAGES   (EXTRA_STAGES), // Количество дополнительных ступеней цепи синхронизации
        .RESET_VALUE    (RESET_VALUE)   // Значение по умолчанию для ступеней цепи синхронизации
    )
    the_ff_synchronizer
    (
        // Сброс и тактирование
        .reset          (reset),        // i
        .clk            (clk),          // i
        
        // Асинхронный входной сигнал
        .async_data     (bounce),       // i  [WIDTH - 1 : 0]
        
        // Синхронный выходной сигнал
        .sync_data      (bounce_sync)   // o  [WIDTH - 1 : 0]
    ); // the_ff_synchronizer
    
    //------------------------------------------------------------------------------------
    //      Счетчик временного интервала анализа входного сигнала
    always @(posedge reset, posedge clk)
        if (reset)
            stable_cnt <= '0;
        else if (bounce_sync != stable_reg)
            if (stable_cnt == (STABLE_TIME - 1))
                stable_cnt <= '0;
            else
                stable_cnt <= stable_cnt + 1'b1;
        else
            stable_cnt <= '0;
    
    //------------------------------------------------------------------------------------
    //      Регистр стабильного значения выходного сигнала
    initial stable_reg = RESET_VALUE;
    always @(posedge reset, posedge clk)
        if (reset)
            stable_reg <= RESET_VALUE;
        else
            stable_reg <= ((bounce_sync != stable_reg) & (stable_cnt == (STABLE_TIME - 1))) ^ stable_reg;
    assign stable = stable_reg;
    
endmodule: debouncer