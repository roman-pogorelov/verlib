/*
    //------------------------------------------------------------------------------------
    //      Модуль захвата и удержания параметров пакета на все время его прохождения
    ps_param_keeper
    #(
        .DWIDTH         (), // Разрядность потока
        .PWIDTH         ()  // Разрядность интерфейса параметров
    )
    the_ps_param_keeper
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Входной интерфейс управления параметрами пакета
        .desired_param  (), // i  [PWIDTH - 1 : 0]
        
        // Выходной интерфейс управления параметрами пакета
        // (с фиксацией на время прохождения всего пакета)
        .agreed_param   (), // o  [PWIDTH - 1 : 0]
        
        // Входной потоковый интерфейс
        .i_dat          (), // i  [DWIDTH - 1 : 0]
        .i_val          (), // i
        .i_eop          (), // i
        .i_rdy          (), // o
        
        // Выходной потоковый интерфейс
        .o_dat          (), // o  [DWIDTH - 1 : 0]
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ps_param_keeper
*/

module ps_param_keeper
#(
    parameter int unsigned          DWIDTH = 8,     // Разрядность потока
    parameter int unsigned          PWIDTH = 8      // Разрядность интерфейса параметров
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Входной интерфейс управления параметрами пакета
    input  logic [PWIDTH - 1 : 0]   desired_param,
    
    // Выходной интерфейс управления параметрами пакета
    // (с фиксацией на время прохождения всего пакета)
    output logic [PWIDTH - 1 : 0]   agreed_param,
    
    // Входной потоковый интерфейс
    input  logic [DWIDTH - 1 : 0]   i_dat,
    input  logic                    i_val,
    input  logic                    i_eop,
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                           sop_reg;        // Регистр признака начала пакета
    logic [PWIDTH - 1 : 0]          param_reg;      // Регистр сохранения параметров пакета
    
    //------------------------------------------------------------------------------------
    //      Регистр признака начала пакета
    initial sop_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            sop_reg <= '1;
        else if (i_val & i_rdy)
            sop_reg <= i_eop;
        else
            sop_reg <= sop_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр сохранения параметров пакета
    always @(posedge reset, posedge clk)
        if (reset)
            param_reg <= '0;
        else if (i_val & i_rdy & sop_reg)
            param_reg <= desired_param;
        else
            param_reg <= param_reg;
    
    //------------------------------------------------------------------------------------
    //      Выходной интерфейс управления параметрами пакета (с фиксацией на время 
    //      прохождения всего пакета)
    assign agreed_param = sop_reg ? desired_param : param_reg;
    
    //------------------------------------------------------------------------------------
    //      Сквозная трансляция потоковых интерфейсов
    assign i_rdy = o_rdy;
    assign o_dat = i_dat;
    assign o_val = i_val;
    assign o_eop = i_eop;
    
endmodule // ps_param_keeper