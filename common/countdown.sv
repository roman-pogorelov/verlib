/*
    //------------------------------------------------------------------------------------
    //      Таймер обратного отсчета
    countdown
    #(
        .WIDTH          ()  // Разрядность счетчика
    )
    the_countdown
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Разрешение тактирования
        .clkena         (), // i
        
        // Управляющие сигналы
        .ctrl_time      (), // i  [WIDTH - 1 : 0]
        .ctrl_run       (), // i
        .ctrl_abort     (), // i
        
        // Статусные сигналы
        .stat_left      (), // o  [WIDTH - 1 : 0]
        .stat_busy      (), // o
        .stat_done      ()  // o
    ); // the_countdown
*/

module countdown
#(
    parameter int unsigned          WIDTH = 8   // Разрядность счетчика
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Разрешение тактирования
    input  logic                    clkena,
    
    // Управляющие сигналы
    input  logic [WIDTH - 1 : 0]    ctrl_time,
    input  logic                    ctrl_run,
    input  logic                    ctrl_abort,
    
    // Статусные сигналы
    output logic [WIDTH - 1 : 0]    stat_left,
    output logic                    stat_busy,
    output logic                    stat_done
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [WIDTH - 1 : 0]           time_cnt;
    logic                           busy_reg;
    logic                           done_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик тактов
    always @(posedge reset, posedge clk)
        if (reset)
            time_cnt <= '0;
        else if (clkena)
            if (busy_reg)
                time_cnt <= time_cnt - (time_cnt != 0);
            else if (ctrl_run)
                time_cnt <= ctrl_time;
            else
                time_cnt <= time_cnt;
        else
            time_cnt <= time_cnt;
    assign stat_left = time_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр активности отсчитывания интервала
    always @(posedge reset, posedge clk)
        if (reset)
            busy_reg <= '0;
        else if (clkena)
            if (busy_reg)
                busy_reg <= ~(ctrl_abort | (time_cnt == 0));
            else
                busy_reg <= ctrl_run;
        else
            busy_reg <= busy_reg;
    assign stat_busy = busy_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр окончания счета
    always @(posedge reset, posedge clk)
        if (reset)
            done_reg <= '0;
        else
            done_reg <= clkena & (busy_reg ? ((time_cnt == 1) & ~ctrl_abort) : ((ctrl_time == 0) & ctrl_run));
    assign stat_done = done_reg;
    
endmodule // countdown