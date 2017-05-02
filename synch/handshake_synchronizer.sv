/*
    //------------------------------------------------------------------------------------
    //      Модуль синхронизации передачи запроса между двумя асинхронными доменами
    //      на основе механизма взаимного подтверждения
    handshake_synchronizer
    #(
        .EXTRA_STAGES   (), // Количество дополнительных ступеней цепи синхронизации
        .HANDSHAKE_TYPE ()  // Схема взаимного подтверждения (2 - с двумя фазами, 4 - с четырьмя фазами)
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
        .dst_rdy        ()  // i
    ); // the_handshake_synchronizer
*/

module handshake_synchronizer
#(
    parameter int unsigned  EXTRA_STAGES    = 0,    // Количество дополнительных ступеней цепи синхронизации
    parameter int unsigned  HANDSHAKE_TYPE  = 2     // Схема взаимного подтверждения (2 - с двумя фазами, 4 - с четырьмя фазами)
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
    input  logic            dst_rdy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic   src_req_reg;
    logic   src_rdy_reg;
    logic   src_rdy_sig;
    logic   dst_req_reg;
    logic   dst_rdy_reg;
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
        .async_data     (dst_rdy_reg),  // i  [WIDTH - 1 : 0]
        
        // Синхронный выходной сигнал
        .sync_data      (src_rdy_sig)   // o  [WIDTH - 1 : 0]
    ); // dst2src_sync
    
    //------------------------------------------------------------------------------------
    //      Синтез логики работы в зависимости от схемы взаимного подтверждения
    generate
        
        // Схема с четырьмя фазами взаимного подтверждения:
        //      1) установка запрос источника
        //      2) установка готовности приемника
        //      3) сброс запроса источника
        //      4) сброс готовности приемника
        if (HANDSHAKE_TYPE == 4) begin: four_phase_handshake_implementation
            
            //------------------------------------------------------------------------------------
            //      Регистр запроса домена источника
            initial src_req_reg = '0;
            always @(posedge src_reset, posedge src_clk)
                if (src_reset)
                    src_req_reg <= '0;
                else if (src_req_reg)
                    src_req_reg <= ~src_rdy_sig;
                else
                    src_req_reg <= src_req & src_rdy;
            
            //------------------------------------------------------------------------------------
            //      Регистр готовности домена источника
            initial src_rdy_reg = '1;
            always @(posedge src_reset, posedge src_clk)
                if (src_reset)
                    src_rdy_reg <= '1;
                else if (src_rdy_reg)
                    src_rdy_reg <= ~src_req;
                else
                    src_rdy_reg <= ~src_req_reg & ~src_rdy_sig;
            
            //------------------------------------------------------------------------------------
            //      Регистр запроса домена приемника
            initial dst_req_reg = '0;
            always @(posedge dst_reset, posedge dst_clk)
                if (dst_reset)
                    dst_req_reg <= '0;
                else if (dst_req_reg)
                    dst_req_reg <= ~dst_rdy;
                else
                    dst_req_reg <= dst_req_sig & ~dst_rdy_reg;
            
            //------------------------------------------------------------------------------------
            //      Регистр готовности домена приемника
            initial dst_rdy_reg = '0;
            always @(posedge dst_reset, posedge dst_clk)
                if (dst_reset)
                    dst_rdy_reg <= '0;
                else if (dst_rdy_reg)
                    dst_rdy_reg <= dst_req_sig;
                else
                    dst_rdy_reg <= dst_req_reg & dst_rdy;
        end
        
        // Схема с двумя фазами взаимного подтверждения:
        //      1) установка запрос источника
        //      2) установка готовности приемника
        else begin: two_phase_handshake_implementation
            
            //------------------------------------------------------------------------------------
            //      Регистр запроса домена источника
            initial src_req_reg = '0;
            always @(posedge src_reset, posedge src_clk)
                if (src_reset)
                    src_req_reg <= '0;
                else
                    src_req_reg <= (src_req & src_rdy) ^ src_req_reg;
            
            //------------------------------------------------------------------------------------
            //      Регистр готовности домена источника
            initial src_rdy_reg = '1;
            always @(posedge src_reset, posedge src_clk)
                if (src_reset)
                    src_rdy_reg <= '1;
                else if (src_rdy_reg)
                    src_rdy_reg <= ~src_req;
                else
                    src_rdy_reg <= src_rdy_sig == src_req_reg;
            
            //------------------------------------------------------------------------------------
            //      Регистр запроса домена приемника
            initial dst_req_reg = '0;
            always @(posedge dst_reset, posedge dst_clk)
                if (dst_reset)
                    dst_req_reg <= '0;
                else if (dst_req_reg)
                    dst_req_reg <= ~dst_rdy;
                else
                    dst_req_reg <= dst_req_sig != dst_rdy_reg;
            
            //------------------------------------------------------------------------------------
            //      Регистр готовности домена приемника
            initial dst_rdy_reg = '0;
            always @(posedge dst_reset, posedge dst_clk)
                if (dst_reset)
                    dst_rdy_reg <= '0;
                else
                    dst_rdy_reg <= (dst_req & dst_rdy) ^ dst_rdy_reg;
            
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Назначение выходных сигналов
    assign dst_req = dst_req_reg;
    assign src_rdy = src_rdy_reg;
    
endmodule: handshake_synchronizer