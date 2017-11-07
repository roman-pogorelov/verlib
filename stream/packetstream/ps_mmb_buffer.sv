/*
    //------------------------------------------------------------------------------------
    //      Модуль буферизации потокового интерфейса PacketStream в память с интерфейсом
    //      MemoryMapped с пакетным доступом
    ps_mmb_buffer
    #(
        .DWIDTH     (), // Разрядность потоковых интерфейсов
        .AWIDTH     (), // Разрядность адреса интерфейса MemoryMapped
        .BWIDTH     (), // Разрядность шины размера пакетного доступа
        .SEGLEN     (), // Максимальная длина фрагментации потокового интерфейса
        .ERATIO     (), // Отношение разрядности интерфейса MemoryMapped к разрядности потока
        .RAMTYPE    ()  // Тип ресурса для реализации внутренних буферов
    )
    the_ps_mmb_buffer
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс
        .i_dat      (), // i  [DWIDTH - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [DWIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      (), // i
        
        // Интерфейс MemoryMapped (ведущий)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_bcnt     (), // o  [BWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [ERATIO*DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [ERATIO*DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_ps_mmb_buffer
*/

module ps_mmb_buffer
#(
    parameter int unsigned                  DWIDTH  = 8,        // Разрядность потоковых интерфейсов
    parameter int unsigned                  AWIDTH  = 8,        // Разрядность адреса интерфейса MemoryMapped
    parameter int unsigned                  BWIDTH  = 4,        // Разрядность шины размера пакетного доступа
    parameter int unsigned                  SEGLEN  = 8,        // Максимальная длина фрагментации потокового интерфейса
    parameter int unsigned                  ERATIO  = 2,        // Отношение разрядности интерфейса MemoryMapped к разрядности потока
    parameter                               RAMTYPE = "AUTO"    // Тип ресурса для реализации внутренних буферов
)
(
    // Сброс и тактирование
    input  logic                            reset,
    input  logic                            clk,
    
    // Входной потоковый интерфейс
    input  logic [DWIDTH - 1 : 0]           i_dat,
    input  logic                            i_val,
    input  logic                            i_eop,
    output logic                            i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [DWIDTH - 1 : 0]           o_dat,
    output logic                            o_val,
    output logic                            o_eop,
    input  logic                            o_rdy,
    
    // Интерфейс MemoryMapped (ведущий)
    output logic [AWIDTH - 1 : 0]           m_addr,
    output logic [BWIDTH - 1 : 0]           m_bcnt,
    output logic                            m_wreq,
    output logic [ERATIO*DWIDTH - 1 : 0]    m_wdat,
    output logic                            m_rreq,
    input  logic [ERATIO*DWIDTH - 1 : 0]    m_rdat,
    input  logic                            m_rval,
    input  logic                            m_busy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [DWIDTH - 1 : 0]                  i_pack_dat;
    logic                                   i_pack_val;
    logic                                   i_pack_eop;
    logic                                   i_pack_rdy;
    //
    logic [DWIDTH - 1 : 0]                  o_pack_dat;
    logic                                   o_pack_val;
    logic                                   o_pack_rdy;
    //
    logic [ERATIO*DWIDTH - 1 : 0]           s2m_dat;
    logic                                   s2m_val;
    logic                                   s2m_rdy;
    //
    logic [ERATIO*DWIDTH - 1 : 0]           m2s_dat;
    logic                                   m2s_val;
    logic                                   m2s_rdy;
    
    //------------------------------------------------------------------------------------
    //      Модуль фрагментации и упаковки фрагментов пакетов потокового 
    //      интерфейса PacketStream
    ps_fragmenter_packer
    #(
        .WIDTH      (DWIDTH),       // Разрядность потока
        .LENGTH     (SEGLEN - 1),   // Максимальная длина фрагмента без учета заголовка
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
        .o_dat      (i_pack_dat),   // o  [WIDTH - 1 : 0]
        .o_val      (i_pack_val),   // o
        .o_eop      (i_pack_eop),   // o
        .o_rdy      (i_pack_rdy)    // i
    ); // the_ps_fragmenter_packer
    
    //------------------------------------------------------------------------------------
    //      Расширение разрядности при ERATIO > 1
    generate
        if (ERATIO > 1) begin: width_expand_implementation
            //------------------------------------------------------------------------------------
            //      Модуль "расширения" разрядности потокового интерфейса PacketStream
            ps_width_expander
            #(
                .WIDTH      (DWIDTH),       // Разрядность входного потока
                .COUNT      (ERATIO)        // Количество слов разрядности WIDTH в выходном потоке
            )
            the_ps_width_expander
            (
                // Сброс и тактирование
                .reset      (reset),        // i
                .clk        (clk),          // i
                
                // Входной потоковый интерфейс
                .i_dat      (i_pack_dat),   // i  [WIDTH - 1 : 0]
                .i_val      (i_pack_val),   // i
                .i_eop      (i_pack_eop),   // i
                .i_rdy      (i_pack_rdy),   // o
                
                // Выходной потоковый интерфейс
                .o_dat      (s2m_dat),      // o  [COUNT*WIDTH - 1 : 0]  
                .o_mty      (  ),           // o  [$clog2(COUNT) - 1 : 0]
                .o_val      (s2m_val),      // o
                .o_eop      (  ),           // o
                .o_rdy      (s2m_rdy)       // i
            ); // the_ps_width_expander
        end
        else begin: no_width_expand_implementation
            assign s2m_dat = i_pack_dat;
            assign s2m_val = i_pack_val;
            assign i_pack_rdy = s2m_rdy;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Модуль буферизации потокового интерфейса DataStream в память с интерфейсом
    //      MemoryMapped с пакетным доступом
    ds_mmb_buffer
    #(
        .DWIDTH     (ERATIO*DWIDTH),        // Разрядность данных
        .AWIDTH     (AWIDTH),               // Разрядность адреса
        .BWIDTH     (BWIDTH),               // Разрядность шины размера пакетного доступа
        .IDEPTH     (SEGLEN/ERATIO + 2),    // Размер входного буфера
        .ODEPTH     (SEGLEN/ERATIO + 2),    // Размер выходного буфера
        .RAMTYPE    (RAMTYPE)               // Тип ресурса для реализации входного и выходного буфера
    )
    the_ds_mmb_buffer
    (
        // Сброс и тактирование
        .reset      (reset),                // i
        .clk        (clk),                  // i
        
        // Входной потоковый интерфейс
        .i_dat      (s2m_dat),              // i  [DWIDTH - 1 : 0]
        .i_val      (s2m_val),              // i
        .i_rdy      (s2m_rdy),              // o
        
        // Выходной потоковый интерфейс
        .o_dat      (m2s_dat),              // o  [DWIDTH - 1 : 0]
        .o_val      (m2s_val),              // o
        .o_rdy      (m2s_rdy),              // i
        
        // Интерфейс MemoryMapped (ведущий)
        .m_addr     (m_addr),               // o  [AWIDTH - 1 : 0]
        .m_bcnt     (m_bcnt),               // o  [BWIDTH - 1 : 0]
        .m_wreq     (m_wreq),               // o
        .m_wdat     (m_wdat),               // o  [DWIDTH - 1 : 0]
        .m_rreq     (m_rreq),               // o
        .m_rdat     (m_rdat),               // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),               // i
        .m_busy     (m_busy)                // i
    ); // the_ds_mmb_buffer
    
    //------------------------------------------------------------------------------------
    //      Сужение разрядности при ERATIO > 1
    generate
        if (ERATIO > 1) begin: width_divide_implementation
            //------------------------------------------------------------------------------------
            //      Модуль "сужения" разрядности потокового интерфейса DataStream
            ds_width_divider
            #(
                .IWIDTH     (ERATIO*DWIDTH),    // Разрядность входного потокового интерфейса
                .FACTOR     (ERATIO)            // Отношение разрядности входного потокового интерфейса к разрядности выходного
            )
            the_ds_width_divider
            (
                // Асинхронный сброс и тактирование
                .reset      (reset),            // i
                .clk        (clk),              // i
                
                // Входной потоковый интерфейс
                .i_dat      (m2s_dat),          // i  [IWIDTH - 1 : 0]
                .i_val      (m2s_val),          // i
                .i_rdy      (m2s_rdy),          // o
                
                // Выходной потоковый интерфейс
                .o_dat      (o_pack_dat),       // o  [IWIDTH/FACTOR - 1 : 0]
                .o_val      (o_pack_val),       // o
                .o_rdy      (o_pack_rdy)        // i
            ); // the_ds_width_divider
        end
        else begin: no_width_divide_implementation
            assign o_pack_dat = m2s_dat;
            assign o_pack_val = m2s_val;
            assign m2s_rdy = o_pack_rdy;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Модуль распаковывания упакованных фрагментов потокового интерфейса
    //      PacketStream
    ps_defragmenter_unpacker
    #(
        .WIDTH      (DWIDTH),       // Разрядность потока
        .ALIGN      (ERATIO)        // Шаг выравнивания длины фрагмента
    )
    ps_defragmenter_unpacker
    (
        // Сброс и тактирование
        .reset      (reset),        // i
        .clk        (clk),          // i
        
        // Входной потоковый интерфейс DataStream
        .i_dat      (o_pack_dat),   // i  [WIDTH - 1 : 0]
        .i_val      (o_pack_val),   // i
        .i_rdy      (o_pack_rdy),   // o
        
        // Выходной потоковый интерфейс PacketStream
        .o_dat      (o_dat),        // o  [WIDTH - 1 : 0]
        .o_val      (o_val),        // o
        .o_eop      (o_eop),        // o
        .o_rdy      (o_rdy)         // i
    ); // ps_defragmenter_unpacker
    
endmodule: ps_mmb_buffer