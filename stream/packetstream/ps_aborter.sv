/*
    //------------------------------------------------------------------------------------
    //      Модуль принудительного прерывания пакета потокового интерфейса PacketStream
    ps_aborter
    #(
        .WIDTH      ()  // Разрядность потока
    )
    the_ps_aborter
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Запрос на принудительное прерывание
        .abort      (), // i
        
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
    ); // the_ps_aborter
*/

module ps_aborter
#(
    parameter int unsigned          WIDTH = 8   // Разрядность потока
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Запрос на принудительное прерывание
    input  logic                    abort,
    
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
    logic [WIDTH - 1 : 0]           buf_dat_reg;
    logic                           buf_eop_reg;
    logic                           buf_state_reg;
    logic                           abort_hold_reg;
    logic                           abort_request;
    
    //------------------------------------------------------------------------------------
    //      Регистр буфера данных
    always @(posedge reset, posedge clk)
        if (reset)
            buf_dat_reg <= '0;
        else if (i_val & i_rdy)
            buf_dat_reg <= i_dat;
        else
            buf_dat_reg <= buf_dat_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака конца пакета
    always @(posedge reset, posedge clk)
        if (reset)
            buf_eop_reg <= '0;
        else if (i_val & i_rdy)
            buf_eop_reg <= i_eop;
        else
            buf_eop_reg <= buf_eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр состояния буферов
    always @(posedge reset, posedge clk)
        if (reset)
            buf_state_reg <= '0;
        // Если буфер занят
        else if (buf_state_reg)
            buf_state_reg <= ~((buf_eop_reg | abort_request) & ~i_val & o_rdy);
        // Если буфер свободен
        else
            buf_state_reg <= i_val;
    
    //------------------------------------------------------------------------------------
    //      Регистр удержания запроса на прерывание пакета
    always @(posedge reset, posedge clk)
        if (reset)
            abort_hold_reg <= '0;
        // Если уже удерживается
        else if (abort_hold_reg)
            abort_hold_reg <= ~(~abort & o_rdy);
        // Если до этого момента не удерживался
        else
            abort_hold_reg <= abort & buf_state_reg & ~o_rdy;
    
    //------------------------------------------------------------------------------------
    //      Запрос на прерывание пакета с учетом удержания
    assign abort_request = abort | abort_hold_reg;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов потоковых интерфейсов
    assign i_rdy = o_rdy | ~buf_state_reg;
    assign o_dat = buf_dat_reg;
    assign o_val = buf_state_reg & (i_val | buf_eop_reg | abort_request);
    assign o_eop = buf_state_reg & (buf_eop_reg | abort_request);
    
endmodule // ps_aborter