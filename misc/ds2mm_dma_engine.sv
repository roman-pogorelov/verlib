/*
    //------------------------------------------------------------------------------------
    //      DMA-движок, забирающий данные с потокового интерфейса и записывающий
    //      их в произвольную память с интерфейсом Avalon MM
    ds2mm_dma_engine
    #(
        .MAWIDTH        (), // Разрядность адреса интерфейса Avalon MM Master
        .SDWIDTH        (), // Разрядность потокового интерфейса
        .CSWIDTH        (), // Разрядность интерфейса управления статуса
        .FACTOR         ()  // Отношение разрядности интерфейса Avalon MM Master к разрядности потока
    )
    the_ds2mm_dma_engine
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Интерфейс управления/статуса
        .csr_address    (), // i  [2 : 0]
        .csr_write      (), // i
        .csr_writedata  (), // i  [CSWIDTH - 1 : 0]
        .csr_read       (), // i
        .csr_readdata   (), // o  [CSWIDTH - 1 : 0]
        
        // Входной потоковый интерфейс
        .i_dat          (), // i  [SDWIDTH - 1 : 0]
        .i_val          (), // i
        .i_rdy          (), // o
        
        // Интерфейс Avalon MM Master
        .wr_address     (), // o  [MAWIDTH - 1 : 0]
        .wr_byteenable  (), // o  [MBYTES - 1 : 0]
        .wr_write       (), // o
        .wr_writedata   (), // o  [MDWIDTH - 1 : 0]
        .wr_waitrequest (), // i
        
        // Интерфейс генерации прерывания
        .irq            ()  // o
    ); // ds2mm_dma_engine
*/

module ds2mm_dma_engine
#(
    parameter int unsigned          MAWIDTH = 8,                // Разрядность адреса интерфейса Avalon MM Master
    parameter int unsigned          SDWIDTH = 16,               // Разрядность потокового интерфейса
    parameter int unsigned          CSWIDTH = 32,               // Разрядность интерфейса управления статуса
    parameter int unsigned          FACTOR  = 2,                // Отношение разрядности интерфейса Avalon MM Master к разрядности потока
    parameter int unsigned          MDWIDTH = FACTOR*SDWIDTH,   // Разрядности интерфейса Avalon MM Master
    parameter int unsigned          SBYTES  = SDWIDTH/8,        // Количество байт на шине данных входного потокового интерфейса
    parameter int unsigned          MBYTES  = FACTOR*SBYTES     // Количество байт на шине данных интерфейса Avalon MM Master
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления/статуса
    input  logic [2 : 0]            csr_address,
    input  logic                    csr_write,
    input  logic [CSWIDTH - 1 : 0]  csr_writedata,
    input  logic                    csr_read,
    output logic [CSWIDTH - 1 : 0]  csr_readdata,
    
    // Входной потоковый интерфейс
    input  logic [SDWIDTH - 1 : 0]  i_dat,
    input  logic                    i_val,
    output logic                    i_rdy,
    
    // Интерфейс Avalon MM Master
    output logic [MAWIDTH - 1 : 0]  wr_address,
    output logic [MBYTES - 1 : 0]   wr_byteenable,
    output logic                    wr_write,
    output logic [MDWIDTH - 1 : 0]  wr_writedata,
    input  logic                    wr_waitrequest,
    
    // Интерфейс генерации прерывания
    output logic                    irq
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam                      ADDR_EXTRA_BITS = MAWIDTH > CSWIDTH ? MAWIDTH - CSWIDTH : CSWIDTH - MAWIDTH;
    //
    localparam logic [2 : 0]        ADDRESS_REG     = 3'h0; // Адрес регистра начального адреса
    localparam logic [2 : 0]        AMOUNT_REG      = 3'h1; // Адрес регистра количества слов для передачи
    localparam logic [2 : 0]        AMOUNT_LEFT_CNT = 3'h2; // Адрес счетчика оставшихся для передачи слов
    localparam logic [2 : 0]        TIMEOUT_REG     = 3'h3; // Адрес регистра таймаута принудительной остановки движка DMA
    localparam logic [2 : 0]        TIME_LEFT_CNT   = 3'h4; // Адрес счетчика тактов, оставшихся до принудительной остановки движка DMA
    localparam logic [2 : 0]        CTRL_STAT_REG   = 3'h5; // Адрес регистра управления/статуса
    localparam logic [2 : 0]        IRQ_ENA_REG     = 3'h6; // Адрес регистра разрешения прерываний
    localparam logic [2 : 0]        IRQ_STAT_REG    = 3'h7; // Адрес регистра статуса прерываний
    //
    localparam int unsigned         DMA_START_BIT   = 00;   // Номер разряда запуска движка DMA
    localparam int unsigned         DMA_STOP_BIT    = 01;   // Номер разряда остановки движка DMA
    localparam int unsigned         DMA_BUSY_BIT    = 02;   // Номер разряда признака занятости движка DMA
    localparam int unsigned         TIMER_START_BIT = 04;   // Номер разряда запуска таймера
    localparam int unsigned         TIMER_STOP_BIT  = 05;   // Номер разряда остановки таймера
    localparam int unsigned         TIMER_BUSY_BIT  = 06;   // Номер разряда признака зависимости таймера
    localparam int unsigned         IRQ_ENA_BIT     = 00;   // Номер разряда разрешения генерации прерываний
    localparam int unsigned         IRQ_STATE_BIT   = 00;   // Номер разряда текущего состояния прерывания
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [MAWIDTH - 1 : 0]         addr_reg;
    logic [MAWIDTH - 1 : 0]         addr_cnt;
    //
    logic [CSWIDTH - 1 : 0]         dma_amount_reg;
    logic                           dma_start_reg;
    logic                           dma_stop_reg;
    logic [CSWIDTH - 1 : 0]         dma_left;
    logic                           dma_busy;
    logic                           dma_done;
    //
    logic [CSWIDTH - 1 : 0]         time_reg;
    logic                           time_start_reg;
    logic                           time_stop_reg;
    logic [CSWIDTH - 1 : 0]         time_left;
    logic                           time_busy;
    logic                           time_done;
    //
    logic                           irq_ena_reg;
    logic                           irq_reg;
    //
    logic [CSWIDTH - 1 : 0]         common_stat;
    logic [CSWIDTH - 1 : 0]         irq_ena_stat;
    logic [CSWIDTH - 1 : 0]         irq_stat;
    //
    logic [SDWIDTH - 1 : 0]         from_doser_dat;
    logic                           from_doser_val;
    logic                           from_doser_eop;
    logic                           from_doser_rdy;
    //
    logic [MDWIDTH - 1 : 0]         from_expan_dat;
    logic                           from_expan_val;
    logic                           from_expan_eop;
    logic                           from_expan_rdy;
    //
    logic [FACTOR - 1 : 0]          wordenable;
    
    //------------------------------------------------------------------------------------
    //      Регистр адреса
    always @(posedge reset, posedge clk)
        if (reset)
            addr_reg <= '0;
        else if (csr_write & (csr_address == ADDRESS_REG))
            addr_reg <= (MAWIDTH > CSWIDTH) ? {{ADDR_EXTRA_BITS{1'b0}}, csr_writedata} : csr_writedata[MAWIDTH - 1 : 0];
        else
            addr_reg <= addr_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик адреса
    always @(posedge reset, posedge clk)
        if (reset)
            addr_cnt <= '0;
        else if (dma_busy)
            addr_cnt <= addr_cnt + (wr_write & ~wr_waitrequest);
        else
            addr_cnt <= addr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр количества слов для передачи
    always @(posedge reset, posedge clk)
        if (reset)
            dma_amount_reg <= '0;
        else if (csr_write & (csr_address == AMOUNT_REG))
            dma_amount_reg <= csr_writedata;
        else
            dma_amount_reg <= dma_amount_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр запуска движка DMA
    always @(posedge reset, posedge clk)
        if (reset)
            dma_start_reg <= '0;
        else
            dma_start_reg <= csr_write & (csr_address == CTRL_STAT_REG) & csr_writedata[DMA_START_BIT];
    
    //------------------------------------------------------------------------------------
    //      Регистр остановки движка DMA
    always @(posedge reset, posedge clk)
        if (reset)
            dma_stop_reg <= '0;
        else
            dma_stop_reg <= (csr_write & (csr_address == CTRL_STAT_REG) & csr_writedata[DMA_STOP_BIT]);
    
    //------------------------------------------------------------------------------------
    //      Регистр значения таймаута остановки движка DMA
    always @(posedge reset, posedge clk)
        if (reset)
            time_reg <= '0;
        else if (csr_write & (csr_address == TIMEOUT_REG))
            time_reg <= csr_writedata;
        else
            time_reg <= time_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр запуска таймера
    always @(posedge reset, posedge clk)
        if (reset)
            time_start_reg <= '0;
        else
            time_start_reg <= csr_write & (csr_address == CTRL_STAT_REG) & csr_writedata[TIMER_START_BIT];
    
    //------------------------------------------------------------------------------------
    //      Регистр остановки таймера
    always @(posedge reset, posedge clk)
        if (reset)
            time_stop_reg <= '0;
        else
            time_stop_reg <= csr_write & (csr_address == CTRL_STAT_REG) & csr_writedata[TIMER_STOP_BIT];
    
    //------------------------------------------------------------------------------------
    //      Регистр разрешения прерываний
    always @(posedge reset, posedge clk)
        if (reset)
            irq_ena_reg <= '0;
        else if (csr_write & (csr_address == IRQ_ENA_REG))
            irq_ena_reg <= csr_writedata[IRQ_ENA_BIT];
        else
            irq_ena_reg <= irq_ena_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр прерывания
    always @(posedge reset, posedge clk)
        if (reset)
            irq_reg <= '0;
        else if (irq_reg)
            irq_reg <= ~(csr_write & (csr_address == IRQ_STAT_REG) & ~csr_writedata[IRQ_STATE_BIT]);
        else
            irq_reg <= irq_ena_reg & dma_done;
    assign irq = irq_reg;
    
    //------------------------------------------------------------------------------------
    //      Формирование статусных слов, доступных при чтении
    assign common_stat   = '{
                                DMA_BUSY_BIT:   dma_busy,
                                TIMER_BUSY_BIT: time_busy,
                                default:        1'b0
                            };
    assign irq_ena_stat  = '{
                                IRQ_ENA_BIT:    irq_ena_reg,
                                default:        1'b0
                            };
    assign irq_stat      = '{
                                IRQ_STATE_BIT:  irq_reg,
                                default:        1'b0
                            };
    
    //------------------------------------------------------------------------------------
    //      Мультиплексирование регистров интерфейса управления/статуса
    always_comb case (csr_address)
        
        // Адрес регистра количества слов для передачи
        AMOUNT_REG:
            csr_readdata =  dma_amount_reg;
        
        // Адрес счетчика оставшихся для передачи слов
        AMOUNT_LEFT_CNT:
            csr_readdata =  dma_left;
        
        // Адрес регистра таймаута принудительной остановки движка DMA
        TIMEOUT_REG:
            csr_readdata =  time_reg;
        
        // Адрес счетчика тактов, оставшихся до принудительной остановки движка DMA
        TIME_LEFT_CNT:
            csr_readdata =  time_left;
        
        // Адрес регистра управления/статуса
        CTRL_STAT_REG:
            csr_readdata =  common_stat;
        
        // Адрес регистра разрешения прерываний
        IRQ_ENA_REG:
            csr_readdata =  irq_ena_stat;
        
        // Адрес регистра статуса прерываний
        IRQ_STAT_REG:
            csr_readdata =  irq_stat;
        
        // Адрес регистра начального адреса
        default:
            csr_readdata = (CSWIDTH > MAWIDTH) ? {{ADDR_EXTRA_BITS{1'b0}}, addr_reg} : addr_cnt[CSWIDTH - 1 : 0];
        
    endcase
    
    //------------------------------------------------------------------------------------
    //      Таймер обратного отсчета
    countdown
    #(
        .WIDTH          (CSWIDTH)                   // Разрядность счетчика
    )
    abort_timer
    (
        // Сброс и тактирование
        .reset          (reset),                    // i
        .clk            (clk),                      // i
        
        // Разрешение тактирования
        .clkena         (1'b1),                     // i
        
        // Управляющие сигналы
        .ctrl_time      (time_reg),                 // i  [WIDTH - 1 : 0]
        .ctrl_run       (time_start_reg),           // i
        .ctrl_abort     (time_stop_reg | dma_done), // i
        
        // Статусные сигналы
        .stat_left      (time_left),                // o  [WIDTH - 1 : 0]
        .stat_busy      (time_busy),                // o
        .stat_done      (time_done)                 // o

    ); // abort_timer
    
    //------------------------------------------------------------------------------------
    //      Модуль формирования пакетов заданной длины потокового интерфейса
    //      PacketStream из потока DataStream (формирование каждого пакета инициируется
    //      установкой сигнала ctrl_run)
    ds2ps_doser
    #(
        .DWIDTH         (SDWIDTH),                  // Разрядность потоковых интерфейсов
        .CWIDTH         (CSWIDTH)                   // Разрядность интерфейса установки количества слов
    )
    the_ds2ps_doser
    (
        // Сброс и тактирование
        .reset          (reset),                    // i
        .clk            (clk),                      // i
        
        // Интерфейс управления
        .ctrl_amount    (dma_amount_reg),           // i  [CWIDTH - 1 : 0]
        .ctrl_run       (dma_start_reg),            // i
        .ctrl_abort     (dma_stop_reg | time_done), // i
        
        // Интерфейс статуса
        .stat_left      (dma_left),                 // o  [CWIDTH - 1 : 0]
        .stat_busy      (dma_busy),                 // o
        .stat_done      (dma_done),                 // o
        
        // Входной потоковый интерфейс
        .i_dat          (i_dat),                    // i  [DWIDTH - 1 : 0]
        .i_val          (i_val),                    // i
        .i_rdy          (i_rdy),                    // o
        
        // Выходной потоковый интерфейс
        .o_dat          (from_doser_dat),            // o  [DWIDTH - 1 : 0]
        .o_val          (from_doser_val),            // o
        .o_eop          (from_doser_eop),            // o
        .o_rdy          (from_doser_rdy)             // i
    ); // the_ds2ps_doser
    
    //------------------------------------------------------------------------------------
    //      Различные реализации в зависимости от значения коэффициента расширения
    //      разрядности FACTOR
    generate
        // Реализация с расширением разрядности
        if (FACTOR > 1) begin: expander_gen
            logic [$clog2(FACTOR) - 1 : 0]  from_expan_mty;
            logic [FACTOR - 1 : 0]          from_expan_mty_oh;
            logic [FACTOR - 1 : 0]          wordenable_reversed;
            
            //------------------------------------------------------------------------------------
            //      Модуль "расширения" разрядности потокового интерфейса PacketStream
            ps_width_expander
            #(
                .WIDTH      (SDWIDTH),          // Разрядность входного потока
                .COUNT      (FACTOR)            // Количество слов разрядности WIDTH в выходном потоке
            )
            the_ps_width_expander
            (
                // Сброс и тактирование
                .reset      (reset),            // i
                .clk        (clk),              // i
                
                // Входной потоковый интерфейс
                .i_dat      (from_doser_dat),   // i  [WIDTH - 1 : 0]
                .i_val      (from_doser_val),   // i
                .i_eop      (from_doser_eop),   // i
                .i_rdy      (from_doser_rdy),   // o
                
                // Выходной потоковый интерфейс
                .o_dat      (from_expan_dat),   // o  [COUNT*WIDTH - 1 : 0]  
                .o_mty      (from_expan_mty),   // o  [$clog2(COUNT) - 1 : 0]
                .o_val      (from_expan_val),   // o
                .o_eop      (from_expan_eop),   // o
                .o_rdy      (from_expan_rdy)    // i
            ); // the_ps_width_expander
            
            //------------------------------------------------------------------------------------
            //      Преобразователь двоичного кода в позиционный
            binary2onehot
            #(
                .BIN_WIDTH  ($clog2(FACTOR))    // Разрядность входа двоичного кода
            )
            mty_binary2onehot
            (
                .binary     (from_expan_mty),   // i  [BIN_WIDTH - 1 : 0]
                .onehot     (from_expan_mty_oh) // o  [2**BIN_WIDTH - 1 : 0]
            ); // mty_binary2onehot
            
            //------------------------------------------------------------------------------------
            //      "Отраженный" сигнал разрешения слов
            assign wordenable_reversed = ~((from_expan_mty_oh - 1'b1) & {FACTOR{from_expan_eop}});
            
            //------------------------------------------------------------------------------------
            //      Модуль реверса (зеркалирования) разрядов произвольной параллельной шины
            bitreverser
            #(
                .WIDTH      (FACTOR)                // Разрядность
            )
            wordenable_bitreverser
            (
                // Входные данные
                .i_dat      (wordenable_reversed),  // i  [WIDTH - 1 : 0] 
                
                // Выходные данные
                .o_dat      (wordenable)            // o  [WIDTH - 1 : 0]
            ); // be_bitreverser            
        end
        
        // Сквозная трансляция без расширения разрядности
        else begin: no_expander_gen
            assign from_expan_dat = from_doser_dat;
            assign from_expan_val = from_doser_val;
            assign from_expan_eop = from_doser_eop;
            assign from_doser_rdy = from_expan_rdy;
            assign wordenable     = '1;
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      "Растягивание" сигнала разрешения слов в сигнал разрешения байт
    generate
        genvar i;
        for (i = 0; i < FACTOR; i++) begin: byteenable_gen
            assign wr_byteenable[(i + 1)*SBYTES - 1 : i*SBYTES] = {SBYTES{wordenable[i]}};
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Стыковка с интерфейсом Avalon MM Master
    assign wr_address     =  addr_cnt;
    assign wr_write       =  from_expan_val;
    assign wr_writedata   =  from_expan_dat;
    assign from_expan_rdy = ~wr_waitrequest;
    
endmodule // ds2mm_dma_engine