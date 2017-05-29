/*
    //------------------------------------------------------------------------------------
    //      Модуль фрагментации и упаковки фрагментов пакетов потокового 
    //      интерфейса PacketStream
    ps_fragmenter_packer
    #(
        .WIDTH      (), // Разрядность потока
        .LENGTH     (), // Максимальная длина фрагмента без учета заголовка
        .RAMTYPE    ()  // Тип блоков встроенной памяти ("MLAB" "M20K" ...)
    )
    the_ps_fragmenter_packer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
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
    ); // the_ps_fragmenter_packer
*/

module ps_fragmenter_packer
#(
    parameter int unsigned                  WIDTH  = 8,         // Разрядность потока
    parameter int unsigned                  LENGTH = 16,        // Максимальная длина фрагмента без учета заголовка
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
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]            o_dat,
    output logic                            o_val,
    output logic                            o_eop,
    input  logic                            o_rdy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [WIDTH - 1 : 0]                   fragm_hdr;
    logic [$clog2(LENGTH) - 1 : 0]          fragm_len;
    logic                                   fragm_fin;
    logic [WIDTH - 1 : 0]                   fragm_dat;
    logic                                   fragm_val;
    logic                                   fragm_eop;
    logic                                   fragm_rdy;
    //
    logic [WIDTH - 1 : 0]                   pack_dat;
    logic                                   pack_val;
    logic                                   pack_eop;
    logic                                   pack_rdy;
    
    //------------------------------------------------------------------------------------
    //      Модуль фрагментации пакетов потокового интерфейса PacketStream
    ps_fragmenter
    #(
        .WIDTH      (WIDTH),        // Разрядность потока
        .LENGTH     (LENGTH),       // Максимальная длина фрагмента
        .RAMTYPE    (RAMTYPE)       // Тип блоков встроенной памяти ("MLAB" "M20K" ...)
    )
    input_fragmenter
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Входной потоковый интерфейс
        .i_dat      (i_dat),        // i  [WIDTH - 1 : 0]
        .i_val      (i_val),        // i
        .i_eop      (i_eop),        // i
        .i_rdy      (i_rdy),        // o
        
        // Длина фрагмента минус один (актуальна в течение
        // передачи всего выходного пакета)
        .o_len      (fragm_len),    // o  [$clog2(LENGTH) - 1 : 0]
        
        // Признак последнего фрагмента пакета (актуален
        // в течение передачи всего выходного пакета)
        .o_fin      (fragm_fin),    // o
        
        // Выходной потоковый интерфейс
        .o_dat      (fragm_dat),    // o  [WIDTH - 1 : 0]
        .o_val      (fragm_val),    // o
        .o_eop      (fragm_eop),    // o
        .o_rdy      (fragm_rdy)     // i
    ); // input_fragmenter
    
    //------------------------------------------------------------------------------------
    //      Формирование заголовка фрагмента c проверкой на возможность передачи длины
    //      заголовка в одном слове потока
    generate
        if (WIDTH > $clog2(LENGTH)) begin
            assign fragm_hdr = {
                fragm_fin,                          // Признак последнего фрагмента пакета
                {WIDTH - $clog2(LENGTH) - 1{1'b0}}, // Заполнение неиспользуемых разрядов нулями
                fragm_len                           // Длина фрагмента минус один
            };
        end
        else begin
            initial $error("WIDTH = %0d, LENGTH = %0d. WIDTH must be greater then ($clog2(LENGTH) + 1)", WIDTH, LENGTH);
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Модуль вставки "головы" пакета потокового интерфейса PacketStream
    ps_head_inserter
    #(
        .WIDTH          (WIDTH)         // Разрядность потока
    )
    fragment_header_inserter
    (
        // Сброс и тактирование
        .reset          (reset),        // i
        .clk            (clk),          // i
        
        // Разрешение вставки заголовка
        .insert         (1'b1),         // i
        
        // Потоковый интерфейс выдачи заголовка
        .h_dat          (fragm_hdr),    // i  [WIDTH - 1 : 0]
        .h_val          (fragm_val),    // i
        .h_eop          (1'b1),         // i
        .h_rdy          (  ),           // o
        
        // Входной потоковый интерфейс
        .i_dat          (fragm_dat),    // i  [WIDTH - 1 : 0]
        .i_val          (fragm_val),    // i
        .i_eop          (fragm_eop),    // i
        .i_rdy          (fragm_rdy),    // o
        
        // Выходной потоковый интерфейс
        .o_dat          (pack_dat),     // o  [WIDTH - 1 : 0]
        .o_val          (pack_val),     // o
        .o_eop          (pack_eop),     // o
        .o_rdy          (pack_rdy)      // i
    ); // fragment_header_inserter
    
    //------------------------------------------------------------------------------------
    //      Буфер потокового интерфейса PacketStream на двух регистрах, лишенный
    //      комбинационных связей между входами и выходами
    ps_twinreg_buffer
    #(
        .WIDTH      (WIDTH)     // Разрядность потока
    )
    output_buffer
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Входной потоковый интерфейс
        .i_dat      (pack_dat), // i  [WIDTH - 1 : 0]
        .i_val      (pack_val), // i
        .i_eop      (pack_eop), // i
        .i_rdy      (pack_rdy), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (o_dat),    // o  [WIDTH - 1 : 0]
        .o_val      (o_val),    // o
        .o_eop      (o_eop),    // o
        .o_rdy      (o_rdy)     // i
    ); // output_buffer
    
endmodule: ps_fragmenter_packer