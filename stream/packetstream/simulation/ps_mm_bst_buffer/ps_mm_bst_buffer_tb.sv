`timescale  1ns / 1ps
module ps_mm_bst_buffer_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned         DWIDTH      = 8;        // Разрядность потоковых интерфейсов
    localparam int unsigned         AWIDTH      = 6;        // Разрядность адреса интерфейса MemoryMapped
    localparam int unsigned         BWIDTH      = 4;        // Разрядность шины размера пакетного доступа
    localparam int unsigned         SEGLEN      = 32;       // Максимальная длина фрагментации потокового интерфейса
    localparam int unsigned         ERATIO      = 8;        // Отношение разрядности интерфейса MemoryMapped к разрядности потока
    localparam                      RAMTYPE     = "AUTO";   // Тип ресурса для реализации внутренних буферов
    localparam int unsigned         RDLATENCY   = 5;        // Задержка при выполнении операции чтения
    localparam int unsigned         PACKETS     = 20;       // Общее количество пакетов при тестировании
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                           reset;
    logic                           clk;
    //
    logic [DWIDTH - 1 : 0]          i_dat;
    logic                           i_val;
    logic                           i_eop;
    logic                           i_rdy;
    //
    logic [DWIDTH - 1 : 0]          o_dat;
    logic                           o_val;
    logic                           o_eop;
    logic                           o_rdy;
    //
    logic [AWIDTH - 1 : 0]          m_addr;
    logic [BWIDTH - 1 : 0]          m_bcnt;
    logic                           m_wreq;
    logic [ERATIO*DWIDTH - 1 : 0]   m_wdat;
    logic                           m_rreq;
    logic [ERATIO*DWIDTH - 1 : 0]   m_rdat;
    logic                           m_rval;
    logic                           m_busy;
    //
    int                             i_word_cnt;
    int                             o_word_cnt;
    int                             i_pack_cnt;
    int                             o_pack_cnt;
    int                             wreq_word_cnt;
    int                             rreq_word_cnt;
    int                             rack_word_cnt;
    //
    logic [$clog2(SEGLEN) : 0]      packSizeQueue[$];
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        reset  = '1;
        clk    = '1;
        i_dat  = '0;
        i_val  = '0;
        i_eop  = '0;
    end
    
    //------------------------------------------------------------------------------------
    //      Сброс
    initial #15 reset = '0;
    
    //------------------------------------------------------------------------------------
    //      Тактирование
    always clk = #5 ~clk;
    
    //------------------------------------------------------------------------------------
    //      Формирование сигнала o_rdy выходного потокового интерфейса
    initial o_rdy = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            o_rdy = '0;
        else
            o_rdy <= $random;
    
    //------------------------------------------------------------------------------------
    //      Модуль буферизации потокового интерфейса PacketStream в память с интерфейсом
    //      MemoryMapped с пакетным доступом
    ps_mm_bst_buffer
    #(
        .DWIDTH     (DWIDTH),   // Разрядность потоковых интерфейсов
        .AWIDTH     (AWIDTH),   // Разрядность адреса интерфейса MemoryMapped
        .BWIDTH     (BWIDTH),   // Разрядность шины размера пакетного доступа
        .SEGLEN     (SEGLEN),   // Максимальная длина фрагментации потокового интерфейса
        .ERATIO     (ERATIO),   // Отношение разрядности интерфейса MemoryMapped к разрядности потока
        .RAMTYPE    (RAMTYPE)   // Тип ресурса для реализации внутренних буферов
    )
    the_ps_mm_bst_buffer
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Входной потоковый интерфейс
        .i_dat      (i_dat),    // i  [DWIDTH - 1 : 0]
        .i_val      (i_val),    // i
        .i_eop      (i_eop),    // i
        .i_rdy      (i_rdy),    // o
        
        // Выходной потоковый интерфейс
        .o_dat      (o_dat),    // o  [DWIDTH - 1 : 0]
        .o_val      (o_val),    // o
        .o_eop      (o_eop),    // o
        .o_rdy      (o_rdy),    // i
        
        // Интерфейс MemoryMapped (ведущий)
        .m_addr     (m_addr),   // o  [AWIDTH - 1 : 0]
        .m_bcnt     (m_bcnt),   // o  [BWIDTH - 1 : 0]
        .m_wreq     (m_wreq),   // o
        .m_wdat     (m_wdat),   // o  [ERATIO*DWIDTH - 1 : 0]
        .m_rreq     (m_rreq),   // o
        .m_rdat     (m_rdat),   // i  [ERATIO*DWIDTH - 1 : 0]
        .m_rval     (m_rval),   // i
        .m_busy     (m_busy)    // i
    ); // the_ps_mm_bst_buffer
    
    //------------------------------------------------------------------------------------
    //      Модель памяти с пакетным доступом по интерфейсу AvalonMM
    avl_vlb_memory_model
    #(
        .DWIDTH             (ERATIO*DWIDTH),    // Разрядность данных
        .AWIDTH             (AWIDTH),           // Разрядность адреса
        .BWIDTH             (BWIDTH),           // Разрядность шины управления пакетным доступом
        .RDLATENCY          (RDLATENCY)         // Задержка при выполнении операции чтения
    )
    the_avl_vlb_memory_model
    (
        // Сброс и тактирование
        .reset              (reset),            // i
        .clk                (clk),              // i
        
        // Интерфейс Avalon MM slave
        .avs_address        (m_addr),           // i  [AWIDTH - 1 : 0]
        .avs_burstcount     (m_bcnt),           // i  [BWIDTH - 1 : 0]
        .avs_write          (m_wreq),           // i
        .avs_writedata      (m_wdat),           // i  [DWIDTH - 1 : 0]
        .avs_read           (m_rreq),           // i
        .avs_readdata       (m_rdat),           // o  [DWIDTH - 1 : 0]
        .avs_readdatavalid  (m_rval),           // o
        .avs_waitrequest    (m_busy)            // o
    ); // the_avl_vlb_memory_model
    
    //------------------------------------------------------------------------------------
    //      Процесс передачи
    initial begin
        #100;
        @(posedge clk);
        for (int packet = 0; packet < PACKETS; packet++) begin
            automatic logic [$clog2(SEGLEN) : 0] packLen = $random;
            packSizeQueue.push_front(packLen);
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
    //      Процесс проверки приема
    initial begin
        automatic logic [DWIDTH - 1 : 0] data;
        data = 0;
        while (1) begin
            @(posedge clk);
            if (o_val & o_rdy) begin
                if (o_dat != data) begin
                    $error("Выходное значение не соответствует ожидаемому.");
                end
                if (o_eop) begin
                    if (o_dat != packSizeQueue.pop_back()) begin
                        $error("Длина выходного пакета не соотвествует длине входного.");
                    end
                end
                data = o_eop ? 0 : data + 1;
            end
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Счетчик входных слов
    initial i_word_cnt = 0;
    always @(posedge clk)
        i_word_cnt <= i_word_cnt + (i_val & i_rdy);
    
    //------------------------------------------------------------------------------------
    //      Счетчик выходных слов
    initial o_word_cnt = 0;
    always @(posedge clk)
        o_word_cnt <= o_word_cnt + (o_val & o_rdy);
    
    //------------------------------------------------------------------------------------
    //      Счетчик входных пакетов
    initial i_pack_cnt = 0;
    always @(posedge clk)
        i_pack_cnt <= i_pack_cnt + (i_val & i_rdy & i_eop);
    
    //------------------------------------------------------------------------------------
    //      Счетчик выходных пакетов
    initial o_pack_cnt = 0;
    always @(posedge clk)
        o_pack_cnt <= o_pack_cnt + (o_val & o_rdy & o_eop);
    
    //------------------------------------------------------------------------------------
    //      Счетчик запросов на запись
    initial wreq_word_cnt = 0;
    always @(posedge clk)
        wreq_word_cnt <= wreq_word_cnt + (m_wreq & ~m_busy);
    
    //------------------------------------------------------------------------------------
    //      Счетчик запросов на чтение
    initial rreq_word_cnt = 0;
    always @(posedge clk)
        if (m_rreq & ~m_busy)
            rreq_word_cnt <= rreq_word_cnt + m_bcnt;
        else
            rreq_word_cnt <= rreq_word_cnt;
    
    //------------------------------------------------------------------------------------
    //      Счетчик ответов на запрос чтения
    initial rack_word_cnt = 0;
    always @(posedge clk)
        rack_word_cnt <= rack_word_cnt + m_rval;
    
endmodule: ps_mm_bst_buffer_tb