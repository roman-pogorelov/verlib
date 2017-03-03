/*
    //------------------------------------------------------------------------------------
    //      Модуль синхронизации передачи запроса между двумя асинхронными доменами
    //      на основе механизма взаимного подтверждения
    handshake_synchronizer
    #(
        .EXTRA_STAGES   ()  // Количество дополнительных ступеней цепи синхронизации
    )
    the_handshake_synchronizer
    (
        // Сброс и тактирование домена источника
        .src_reset      (), // i
        .src_clk        (), // i
        
        // Сброс и тактирование домена приемника
        .dst_reset      (), // i
        .dst_clk        (), // i
        
        // Интерфейс домена источника
        .src_req        (), // i
        .src_rdy        (), // o
        
        // Интерфейс домена приемника
        .dst_req        (), // o
        .dst_ack        ()  // i
    ); // the_handshake_synchronizer
*/

module handshake_synchronizer
#(
    parameter int unsigned  EXTRA_STAGES = 0    // Количество дополнительных ступеней цепи синхронизации
)
(
    // Сброс и тактирование домена источника
    input  logic            src_reset,
    input  logic            src_clk,
    
    // Сброс и тактирование домена приемника
    input  logic            dst_reset,
    input  logic            dst_clk,
    
    // Интерфейс домена источника
    input  logic            src_req,
    output logic            src_rdy,
    
    // Интерфейс домена приемника
    output logic            dst_req,
    input  logic            dst_ack
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic   src_req_reg;
    logic   src_rdy_reg;
    logic   src_ack_sig;
    logic   dst_req_reg;
    logic   dst_ack_reg;
    logic   dst_req_sig;
    
    //------------------------------------------------------------------------------------
    //      Модуль синхронизации сигнала на последовательной триггерной цепочке
    ff_synchronizer
    #(
        .WIDTH          (1),            // Разрядность синхронизируемой шины
        .EXTRA_STAGES   (EXTRA_STAGES), // Количество дополнительных ступеней цепи синхронизации
        .RESET_VALUE    (1'b0)          // Значение по умолчанию для ступеней цепи синхронизации
    )
    src2dst_sync
    (
        // Сброс и тактирование
        .reset          (dst_reset),    // i
        .clk            (dst_clk),      // i
        
        // Асинхронный входной сигнал
        .async_data     (src_req_reg), // i  [WIDTH - 1 : 0]
        
        // Синхронный выходной сигнал
        .sync_data      (dst_req_sig)  // o  [WIDTH - 1 : 0]
    ); // src2dst_sync
    
    //------------------------------------------------------------------------------------
    //      Модуль синхронизации сигнала на последовательной триггерной цепочке
    ff_synchronizer
    #(
        .WIDTH          (1),            // Разрядность синхронизируемой шины
        .EXTRA_STAGES   (EXTRA_STAGES), // Количество дополнительных ступеней цепи синхронизации
        .RESET_VALUE    (1'b0)          // Значение по умолчанию для ступеней цепи синхронизации
    )
    dst2src_sync
    (
        // Сброс и тактирование
        .reset          (src_reset),    // i
        .clk            (src_clk),      // i
        
        // Асинхронный входной сигнал
        .async_data     (dst_ack_reg),  // i  [WIDTH - 1 : 0]
        
        // Синхронный выходной сигнал
        .sync_data      (src_ack_sig)   // o  [WIDTH - 1 : 0]
    ); // dst2src_sync
    
    //------------------------------------------------------------------------------------
    //      Регистр запроса домена источника
    initial src_req_reg = '0;
    always @(posedge src_reset, posedge src_clk)
        if (src_reset)
            src_req_reg <= '0;
        else if (src_req_reg)
            src_req_reg <= ~src_ack_sig;
        else
            src_req_reg <= src_req & src_rdy;
    
    //------------------------------------------------------------------------------------
    //      Регистр занятости домена источника
    initial src_rdy_reg = '1;
    always @(posedge src_reset, posedge src_clk)
        if (src_reset)
            src_rdy_reg <= '1;
        else if (src_rdy_reg)
            src_rdy_reg <= ~src_req;
        else
            src_rdy_reg <= ~src_req_reg & ~src_ack_sig;
    assign src_rdy = src_rdy_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр запроса домена приемника
    initial dst_req_reg = '0;
    always @(posedge dst_reset, posedge dst_clk)
        if (dst_reset)
            dst_req_reg <= '0;
        else if (dst_req_reg)
            dst_req_reg <= ~dst_ack;
        else
            dst_req_reg <= dst_req_sig & ~dst_ack_reg;
    assign dst_req = dst_req_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр подтверждения домена приемника
    initial dst_ack_reg = '0;
    always @(posedge dst_reset, posedge dst_clk)
        if (dst_reset)
            dst_ack_reg <= '0;
        else if (dst_ack_reg)
            dst_ack_reg <= dst_req_sig;
        else
            dst_ack_reg <= dst_req_reg & dst_ack;
    
endmodule: handshake_synchronizer