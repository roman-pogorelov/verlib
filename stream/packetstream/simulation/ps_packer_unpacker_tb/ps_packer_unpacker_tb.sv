`timescale  1ns / 1ps
module ps_packer_unpacker_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam              WIDTH   = 8;
    localparam              LENGTH  = 16;
    localparam              RAMTYPE = "AUTO";
    localparam              ALIGN   = 8;
    //
    localparam              PACKETS = 50;
    localparam              LWIDTH  = 7;
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                       reset;
    logic                       clk;
    //
    logic [WIDTH - 1 : 0]       i_dat;
    logic                       i_val;
    logic                       i_eop;
    logic                       i_rdy;
    //
    logic [WIDTH - 1 : 0]       pack_dat;
    logic                       pack_val;
    logic                       pack_eop;
    logic                       pack_rdy;
    //
    logic [WIDTH - 1 : 0]       unpack_dat;
    logic                       unpack_val;
    logic                       unpack_rdy;
    //
    logic [ALIGN*WIDTH - 1 : 0] ds_dat;
    logic                       ds_val;
    logic                       ds_rdy;
    //
    logic [WIDTH - 1 : 0]       o_dat;
    logic                       o_val;
    logic                       o_eop;
    logic                       o_rdy;
    //
    int                         i_word_cnt;
    int                         o_word_cnt;
    int                         i_pack_cnt;
    int                         o_pack_cnt;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        reset = '1;
        clk   = '1;
        i_dat = '0;
        i_val = '0;
        i_eop = '0;
        o_rdy = '1;
    end
    
    //------------------------------------------------------------------------------------
    //      Сброс
    initial #15 reset = '0;
    
    //------------------------------------------------------------------------------------
    //      Тактирование
    always clk = #5 ~clk;
    
    //------------------------------------------------------------------------------------
    //      Счетчик входных данных
    always @(posedge clk)
        i_word_cnt <= i_word_cnt + (i_val & i_rdy);
    
    //------------------------------------------------------------------------------------
    //      Счетчик выходных данных
    always @(posedge clk)
        o_word_cnt <= o_word_cnt + (o_val & o_rdy);
    
    //------------------------------------------------------------------------------------
    //      Счетчик входных пакетов
    always @(posedge clk)
        i_pack_cnt <= i_pack_cnt + (i_val & i_rdy & i_eop);
    
    //------------------------------------------------------------------------------------
    //      Счетчик выходных пакетов
    always @(posedge clk)
        o_pack_cnt <= o_pack_cnt + (o_val & o_rdy & o_eop);
    
    //------------------------------------------------------------------------------------
    //      Формирование сигнала o_rdy
    always @(posedge clk)
       #1ps o_rdy = $random | reset;
    
    //------------------------------------------------------------------------------------
    //      Процесс передачи
    initial begin
        #100;
        @(posedge clk);
        for (int packet = 0; packet < PACKETS; packet++) begin
            automatic logic [LWIDTH - 1 : 0] packLen = $random;
            for (int data = 0; data < packLen + 1; data++) begin
                i_val = i_val | $random;
                i_dat = data;
                i_eop = (data == packLen);
                @(posedge clk);
                if (i_val & i_rdy)
                    i_val = 1'b0;
                else
                    data = data - 1;
            end
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Модуль фрагментации и упаковки фрагментов пакетов потокового 
    //      интерфейса PacketStream
    ps_fragmenter_packer
    #(
        .WIDTH      (WIDTH),        // Разрядность потока
        .LENGTH     (LENGTH),       // Максимальная длина фрагмента без учета заголовка
        .RAMTYPE    (RAMTYPE)       // Тип блоков встроенной памяти ("MLAB" "M20K" ...)
    )
    the_ps_fragmenter_packer
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Входной потоковый интерфейс
        .i_dat      (i_dat),        // i  [WIDTH - 1 : 0]
        .i_val      (i_val),        // i
        .i_eop      (i_eop),        // i
        .i_rdy      (i_rdy),        // o
        
        // Выходной потоковый интерфейс
        .o_dat      (pack_dat),     // o  [WIDTH - 1 : 0]
        .o_val      (pack_val),     // o
        .o_eop      (pack_eop),     // o
        .o_rdy      (pack_rdy)      // i
    ); // the_ps_fragmenter_packer
    
    generate
        if (ALIGN > 1) begin: width_expansion
            //------------------------------------------------------------------------------------
            //      Модуль "расширения" разрядности потокового интерфейса PacketStream
            ps_width_expander
            #(
                .WIDTH      (WIDTH),    // Разрядность входного потока
                .COUNT      (ALIGN)     // Количество слов разрядности WIDTH в выходном потоке
            )
            the_ps_width_expander
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
                .o_dat      (ds_dat),   // o  [COUNT*WIDTH - 1 : 0]  
                .o_mty      (  ),       // o  [$clog2(COUNT) - 1 : 0]
                .o_val      (ds_val),   // o
                .o_eop      (  ),       // o
                .o_rdy      (ds_rdy)    // i
            ); // the_ps_width_expander
            
            //------------------------------------------------------------------------------------
            //      Модуль "сужения" разрядности потокового интерфейса DataStream
            ds_width_divider
            #(
                .IWIDTH     (WIDTH*ALIGN),  // Разрядность входного потокового интерфейса
                .FACTOR     (ALIGN)         // Отношение разрядности входного потокового интерфейса к разрядности выходного
            )
            the_ds_width_divider
            (
                // Асинхронный сброс и тактирование
                .reset      (reset),        // i
                .clk        (clk),          // i
                
                // Входной потоковый интерфейс
                .i_dat      (ds_dat),       // i  [IWIDTH - 1 : 0]
                .i_val      (ds_val),       // i
                .i_rdy      (ds_rdy),       // o
                
                // Выходной потоковый интерфейс
                .o_dat      (unpack_dat),   // o  [IWIDTH/FACTOR - 1 : 0]
                .o_val      (unpack_val),   // o
                .o_rdy      (unpack_rdy)    // i
            ); // the_ds_width_divider
            
        end
        else begin: no_width_expansion
            assign ds_dat = pack_dat;
            assign ds_val = pack_val;
            assign pack_rdy = ds_rdy;
            assign unpack_dat = ds_dat;
            assign unpack_val = ds_val;
            assign ds_rdy = unpack_rdy;
        end 
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Модуль распаковывания упакованных фрагментов потокового интерфейса
    //      PacketStream
    ps_defragmenter_unpacker
    #(
        .WIDTH      (WIDTH),        // Разрядность потока
        .ALIGN      (ALIGN)         // Шаг выравнивания длины фрагмента
    )
    ps_defragmenter_unpacker
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Входной потоковый интерфейс DataStream
        .i_dat      (unpack_dat),   // i  [WIDTH - 1 : 0]
        .i_val      (unpack_val),   // i
        .i_rdy      (unpack_rdy),   // o
        
        // Выходной потоковый интерфейс PacketStream
        .o_dat      (o_dat),        // o  [WIDTH - 1 : 0]
        .o_val      (o_val),        // o
        .o_eop      (o_eop),        // o
        .o_rdy      (o_rdy)         // i
    ); // ps_defragmenter_unpacker
    
endmodule: ps_packer_unpacker_tb