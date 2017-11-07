`timescale  1ns / 1ps
module ds_mmb_buffer_tb ();
    
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned     DWIDTH      = 8;        // Разрядность данных
    localparam int unsigned     AWIDTH      = 6;        // Разрядность адреса
    localparam int unsigned     BWIDTH      = 4;        // Разрядность шины размера пакетного доступа
    localparam int unsigned     IDEPTH      = 16;       // Размер входного буфера
    localparam int unsigned     ODEPTH      = 16;       // Размер выходного буфера
    localparam                  RAMTYPE     = "AUTO";   // Тип ресурса для реализации входного и выходного буфера
    localparam int unsigned     RDLATENCY   = 5;        // Задержка при выполнении операции чтения
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic                       reset;
    logic                       clk;
    //
    logic [DWIDTH - 1 : 0]      i_dat;
    logic                       i_val;
    logic                       i_rdy;
    //
    logic [DWIDTH - 1 : 0]      o_dat;
    logic                       o_val;
    logic                       o_rdy;
    //
    logic [AWIDTH - 1 : 0]      m_addr;
    logic [BWIDTH - 1 : 0]      m_bcnt;
    logic                       m_wreq;
    logic [DWIDTH - 1 : 0]      m_wdat;
    logic                       m_rreq;
    logic [DWIDTH - 1 : 0]      m_rdat;
    logic                       m_rval;
    logic                       m_busy;
    //
    int                         i_word_cnt;
    int                         o_word_cnt;
    int                         wreq_word_cnt;
    int                         rreq_word_cnt;
    int                         rack_word_cnt;
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        reset  = '1;
        clk    = '1;
        i_dat  = '0;
        i_val  = '0;
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
    //      Модуль буферизации потокового интерфейса DataStream в память с интерфейсом
    //      MemoryMapped с пакетным доступом
    ds_mmb_buffer
    #(
        .DWIDTH     (DWIDTH),   // Разрядность данных
        .AWIDTH     (AWIDTH),   // Разрядность адреса
        .BWIDTH     (BWIDTH),   // Разрядность шины размера пакетного доступа
        .IDEPTH     (IDEPTH),   // Размер входного буфера
        .ODEPTH     (ODEPTH),   // Размер выходного буфера
        .RAMTYPE    (RAMTYPE)   // Тип ресурса для реализации входного и выходного буфера
    )
    the_ds_mmb_buffer
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Входной потоковый интерфейс
        .i_dat      (i_dat),    // i  [DWIDTH - 1 : 0]
        .i_val      (i_val),    // i
        .i_rdy      (i_rdy),    // o
        
        // Выходной потоковый интерфейс
        .o_dat      (o_dat),    // o  [DWIDTH - 1 : 0]
        .o_val      (o_val),    // o
        .o_rdy      (o_rdy),    // i
        
        // Интерфейс MemoryMapped (ведущий)
        .m_addr     (m_addr),   // o  [AWIDTH - 1 : 0]
        .m_bcnt     (m_bcnt),   // o  [BWIDTH - 1 : 0]
        .m_wreq     (m_wreq),   // o
        .m_wdat     (m_wdat),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (m_rreq),   // o
        .m_rdat     (m_rdat),   // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),   // i
        .m_busy     (m_busy)    // i
    ); // the_ds_mmb_buffer
    
    //------------------------------------------------------------------------------------
    //      Модель памяти с пакетным доступом по интерфейсу AvalonMM
    avl_vlb_memory_model
    #(
        .DWIDTH             (DWIDTH),   // Разрядность данных
        .AWIDTH             (AWIDTH),   // Разрядность адреса
        .BWIDTH             (BWIDTH),   // Разрядность шины управления пакетным доступом
        .RDLATENCY          (RDLATENCY) // Задержка при выполнении операции чтения
    )
    the_avl_vlb_memory_model
    (
        // Сброс и тактирование
        .reset              (reset),    // i
        .clk                (clk),      // i
        
        // Интерфейс Avalon MM slave
        .avs_address        (m_addr),   // i  [AWIDTH - 1 : 0]
        .avs_burstcount     (m_bcnt),   // i  [BWIDTH - 1 : 0]
        .avs_write          (m_wreq),   // i
        .avs_writedata      (m_wdat),   // i  [DWIDTH - 1 : 0]
        .avs_read           (m_rreq),   // i
        .avs_readdata       (m_rdat),   // o  [DWIDTH - 1 : 0]
        .avs_readdatavalid  (m_rval),   // o
        .avs_waitrequest    (m_busy)    // o
    ); // the_avl_vlb_memory_model
    
    //------------------------------------------------------------------------------------
    //      Процесс передачи
    initial begin
        #100;
        @(posedge clk);
        for (int data = 0; data < 2**(AWIDTH + 1); data++) begin
            i_val = i_val | $random;
            i_dat = data;
            @(posedge clk);
            if (i_val & i_rdy)
                i_val = 1'b0;
            else
                data = data - 1;
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Процесс проверки приема
    initial begin
        for (int data = 0; data < 2**(AWIDTH + 1); data++) begin
            @(posedge clk);
            if (o_val & o_rdy) begin
                if (o_dat != data) begin
                    $error("Принятое значение не соответствует ожидаемому.");
                end
            end
            else begin
                data = data - 1;
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
    
endmodule: ds_mmb_buffer_tb