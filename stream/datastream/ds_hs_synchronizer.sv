/*
    //------------------------------------------------------------------------------------
    //      Модуль синхронизации интерфейса DataStream между двумя доменами
    //      тактирования на основе механизма взаимного подтверждения
    ds_hs_synchronizer
    #(
        .WIDTH      (), // Разрядность потока
        .ESTAGES    (), // Количество дополнительных ступеней цепи синхронизации
        .HSTYPE     ()  // Схема взаимного подтверждения (2 - с двумя фазами 4 - с четырьмя фазами)
    )
    the_ds_hs_synchronizer
    (
        // Сброс и тактирование входного потокового интерфейса
        .i_reset    (), // i
        .i_clk      (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o
        
        // Сброс и тактирование выходного потокового интерфейса
        .o_reset    (), // i
        .o_clk      (), // i
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_rdy      ()  // i
    ); // the_ds_hs_synchronizer
*/

module ds_hs_synchronizer
#(
    parameter int unsigned          WIDTH   = 8,    // Разрядность потока
    parameter int unsigned          ESTAGES = 0,    // Количество дополнительных ступеней цепи синхронизации
    parameter int unsigned          HSTYPE  = 2     // Схема взаимного подтверждения (2 - с двумя фазами, 4 - с четырьмя фазами)
)
(
    // Сброс и тактирование входного потокового интерфейса
    input  logic                    i_reset,
    input  logic                    i_clk,
    
    // Входной потоковый интерфейс
    input  logic [WIDTH - 1 : 0]    i_dat,
    input  logic                    i_val,
    output logic                    i_rdy,
    
    // Сброс и тактирование выходного потокового интерфейса
    input  logic                    o_reset,
    input  logic                    o_clk,
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов с учетом требований синтеза и проверки Altera
    (* altera_attribute = {"-name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -from [get_keepers {*ds_hs_synchronizer:*|i2o_data_hold_reg[*]}]\" "} *) reg [WIDTH - 1 : 0] i2o_data_hold_reg;
    
    //------------------------------------------------------------------------------------
    //      Модуль синхронизации передачи запроса между двумя асинхронными доменами
    //      на основе механизма взаимного подтверждения
    handshake_synchronizer
    #(
        .EXTRA_STAGES   (ESTAGES),  // Количество дополнительных ступеней цепи синхронизации
        .HANDSHAKE_TYPE (HSTYPE)    // Схема взаимного подтверждения (2 - с двумя фазами, 4 - с четырьмя фазами)
    )
    ctrl_synchronizer
    (
        // Сброс и тактирование домена источника
        .src_reset      (i_reset),  // i
        .src_clk        (i_clk),    // i
        
        // Сброс и тактирование домена приемника
        .dst_reset      (o_reset),  // i
        .dst_clk        (o_clk),    // i
        
        // Интерфейс домена источника
        .src_req        (i_val),    // i
        .src_rdy        (i_rdy),    // o
        
        // Интерфейс домена приемника
        .dst_req        (o_val),    // o
        .dst_rdy        (o_rdy)     // i
    ); // ctrl_synchronizer
    
    //------------------------------------------------------------------------------------
    //      Регистр удержания данных при передаче в другой домен тактирования
    always @(posedge i_reset, posedge i_clk)
        if (i_reset)
            i2o_data_hold_reg <= '0;
        else if (i_val & i_rdy)
            i2o_data_hold_reg <= i_dat;
        else
            i2o_data_hold_reg <= i2o_data_hold_reg;
    assign o_dat = i2o_data_hold_reg;
    
endmodule: ds_hs_synchronizer