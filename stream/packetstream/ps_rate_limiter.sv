/*
    //------------------------------------------------------------------------------------
    //      Модуль ограничения скорости потока интерфейса PacketStream (вставляет
    //      паузы заданной длины между смежными пакетами)
    ps_rate_limiter
    #(
        .DWIDTH     (), // Разрядность потока
        .CWIDTH     ()  // Разрядность шины управления задержкой
    )
    the_ps_rate_limiter
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Управление задержкой вставляемой между пакетами
        .delay      (), // i  [CWIDTH - 1 : 0]
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [DWIDTH - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [DWIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_rate_limiter
*/

module ps_rate_limiter
#(
    parameter int unsigned          DWIDTH = 8, // Разрядность потока
    parameter int unsigned          CWIDTH = 8  // Разрядность шины управления задержкой
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Управление задержкой, вставляемой между пакетами
    input  logic [CWIDTH - 1 : 0]   delay,
    
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
    //      Объявление сигналов
    logic [CWIDTH - 1 : 0]          del_cnt;
    logic                           ena_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик тактов задержки, вставляемой между пакетами
    always @(posedge reset, posedge clk)
        if (reset)
            del_cnt <= '0;
        else if (del_cnt == 0)
            if (i_val & i_eop & i_rdy)
                del_cnt <= delay;
            else
                del_cnt <= '0;
        else
            del_cnt <= del_cnt - 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Регистр разрешения прохождения пакета
    initial ena_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            ena_reg <= '1;
        // Если поток пока не блокирован
        else if (ena_reg)
            ena_reg <= ~(i_val & i_eop & i_rdy & (delay != 0));
        // Если поток уже заблокирован
        else
            ena_reg <= (del_cnt == 1);
    
    //------------------------------------------------------------------------------------
    //      Логика блокировки потока
    assign o_dat = i_dat;
    assign o_eop = i_eop;
    assign o_val = i_val & ena_reg;
    assign i_rdy = o_rdy & ena_reg;
    
endmodule: ps_rate_limiter