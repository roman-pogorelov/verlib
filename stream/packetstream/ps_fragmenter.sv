/*
    //------------------------------------------------------------------------------------
    //      Модуль фрагментации пакетов потокового интерфейса PacketStream
    ps_fragmenter
    #(
        .WIDTH      (), // Разрядность потока
        .LENGTH     (), // Максимальная длина фрагмента
        .RAMTYPE    ()  // Тип блоков встроенной памяти ("MLAB" "M20K" ...)
    )
    the_ps_fragmenter
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o
        
        // Длина фрагмента минус один (актуальна в течение
        // передачи всего выходного пакета)
        .o_len      (), // o  [$clog2(LENGTH) - 1 : 0]
        
        // Признак последнего фрагмента пакета (актуален
        // в течение передачи всего выходного пакета)
        .o_fin      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_fragmenter
*/

module ps_fragmenter
#(
    parameter int unsigned                  WIDTH  = 8,         // Разрядность потока
    parameter int unsigned                  LENGTH = 8,         // Максимальная длина фрагмента
    parameter                               RAMTYPE = "AUTO"    // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
)
(
    // Сброс и тактирование
    input  logic                            reset,
    input  logic                            clk,
    
    // Входной потоковый интерфейс
    input  logic [WIDTH - 1 : 0]            i_dat,
    input  logic                            i_val,
    input  logic                            i_eop,
    output logic                            i_rdy,
    
    // Длина фрагмента минус один (актуальна в течение
    // передачи всего выходного пакета)
    output logic [$clog2(LENGTH) - 1 : 0]   o_len,
    
    // Признак последнего фрагмента пакета (актуален
    // в течение передачи всего выходного пакета)
    output logic                            o_fin,
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]            o_dat,
    output logic                            o_val,
    output logic                            o_eop,
    input  logic                            o_rdy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [$clog2(LENGTH) - 1 : 0]          len_cnt;
    logic                                   i_eof;
    
    //------------------------------------------------------------------------------------
    //      Счетчик длины входного пакета
    always @(posedge reset, posedge clk)
        if (reset)
            len_cnt <= '0;
        else if (i_val & i_rdy)
            if (i_eop | i_eof)
                len_cnt <= '0;
            else
                len_cnt <= len_cnt + 1'b1;
        else
            len_cnt <= len_cnt;
    
    //------------------------------------------------------------------------------------
    //      Признак окончания фрагмента входного пакета
    assign i_eof = (len_cnt == (LENGTH - 1));
    
    //------------------------------------------------------------------------------------
    //      Одноклоковый FIFO буфер для потокового интерфейса PacketStream
    //      на ядре от Altera
    ps_alt_scfifo
    #(
        .DWIDTH             (WIDTH),            // Разрядность потока
        .DEPTH              (LENGTH + 2),       // Глубина FIFO
        .RAMTYPE            (RAMTYPE)           // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    dat_buffer
    (
        // Сброс и тактирование
        .reset              (reset),            // i
        .clk                (clk),              // i
        
        // Входной потоковый интерфейс
        .i_dat              (i_dat),            // i  [DWIDTH - 1 : 0]
        .i_val              (i_val),            // i
        .i_eop              (i_eop | i_eof),    // i
        .i_rdy              (i_rdy),            // o
        
        // Выходной потоковый интерфейс
        .o_dat              (o_dat),            // o  [DWIDTH - 1 : 0]
        .o_val              (  ),               // o
        .o_eop              (o_eop),            // o
        .o_rdy              (o_val & o_rdy)     // i
    ); // dat_buffer
    
    //------------------------------------------------------------------------------------
    //      Одноклоковый FIFO буфер для потокового интерфейса PacketStream
    //      на ядре от Altera
    ps_alt_scfifo
    #(
        .DWIDTH             ($clog2(LENGTH)),                   // Разрядность потока
        .DEPTH              (LENGTH + 2),                       // Глубина FIFO
        .RAMTYPE            (RAMTYPE)                           // Тип блоков встроенной памяти ("MLAB", "M20K", ...)
    )
    len_buffer
    (
        // Сброс и тактирование
        .reset              (reset),                            // i
        .clk                (clk),                              // i
        
        // Входной потоковый интерфейс
        .i_dat              (len_cnt),                          // i  [DWIDTH - 1 : 0]
        .i_val              (i_val & i_rdy &(i_eop | i_eof)),   // i
        .i_eop              (i_eop),                            // i
        .i_rdy              (  ),                               // o
        
        // Выходной потоковый интерфейс
        .o_dat              (o_len),                            // o  [DWIDTH - 1 : 0]
        .o_val              (o_val),                            // o
        .o_eop              (o_fin),                            // o
        .o_rdy              (o_rdy & o_eop)                     // i
    ); // len_buffer
    
endmodule: ps_fragmenter