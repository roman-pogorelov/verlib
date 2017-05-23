/*
    //------------------------------------------------------------------------------------
    //      Модуль генерации трафика потокового интерфейса PacketStream
    ps_traffic_generator
    #(
        .WIDTH      ()  // Разрядность
    )
    the_ps_traffic_generator
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейс управления
        .ctrl_addr  (), // i  [1 : 0]
        .ctrl_wreq  (), // i
        .ctrl_wdat  (), // i  [WIDTH - 1 : 0]
        .ctrl_rreq  (), // i
        .ctrl_rdat  (), // o  [WIDTH - 1 : 0]
        
        // Выходной потоковый интерфейс
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_traffic_generator
*/
module ps_traffic_generator
#(
    parameter int unsigned          WIDTH = 8   // Разрядность
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic [1 : 0]            ctrl_addr,
    input  logic                    ctrl_wreq,
    input  logic [WIDTH - 1 : 0]    ctrl_wdat,
    input  logic                    ctrl_rreq,
    output logic [WIDTH - 1 : 0]    ctrl_rdat,
    
    // Выходной потоковый интерфейс
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam logic [1 : 0]        DATA_REG_ADDR   = 2'h0;     // Адрес регистра данных
    localparam logic [1 : 0]        INCR_REG_ADDR   = 2'h1;     // Адрес регистра инкремента данных
    localparam logic [1 : 0]        LENGTH_REG_ADDR = 2'h2;     // Адрес регистра длины пакета
    localparam logic [1 : 0]        AMOUNT_REG_ADDR = 2'h3;     // Адрес регистра общего количества генерируемых слов
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [WIDTH - 1 : 0]           data_reg;
    logic [WIDTH - 1 : 0]           incr_reg;
    logic [WIDTH - 1 : 0]           len_reg;
    logic [WIDTH - 1 : 0]           len_cnt;
    logic [WIDTH - 1 : 0]           amount_cnt;
    logic                           val_reg;
    logic                           eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр данных
    always @(posedge reset, posedge clk)
        if (reset)
            data_reg <= '0;
        else if (ctrl_wreq & (ctrl_addr == DATA_REG_ADDR))
            data_reg <= ctrl_wdat;
        else if (o_val & o_rdy)
            data_reg <= data_reg + incr_reg;
        else
            data_reg <= data_reg;
    assign o_dat = data_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр инкремента данных
    always @(posedge reset, posedge clk)
        if (reset)
            incr_reg <= '0;
        else if (ctrl_wreq & (ctrl_addr == INCR_REG_ADDR))
            incr_reg <= ctrl_wdat;
        else
            incr_reg <= incr_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр длины пакета
    always @(posedge reset, posedge clk)
        if (reset)
            len_reg <= '0;
        else if (ctrl_wreq & (ctrl_addr == LENGTH_REG_ADDR))
            len_reg <= ctrl_wdat;
        else
            len_reg <= len_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик длины пакета
    always @(posedge reset, posedge clk)
        if (reset)
            len_cnt <= '0;
        // Загрузка по началу генерации
        else if (ctrl_wreq & (ctrl_addr == AMOUNT_REG_ADDR))
            len_cnt <= len_reg - 1'b1;
        // Декремент при генерации
        else if (o_val & o_rdy)
            if (len_cnt == 0)
                len_cnt <= len_reg - 1'b1;
            else
                len_cnt <= len_cnt - 1'b1;
        else
            len_cnt <= len_cnt;
    
    //------------------------------------------------------------------------------------
    //      Счетчик общего количества генерируемых слов
    always @(posedge reset, posedge clk)
        if (reset)
            amount_cnt <= '0;
        else if (ctrl_wreq & (ctrl_addr == AMOUNT_REG_ADDR))
            amount_cnt <= ctrl_wdat;
        else if (o_val & o_rdy)
            amount_cnt <= amount_cnt - (amount_cnt != 0);
        else
            amount_cnt <= amount_cnt;
    
    //------------------------------------------------------------------------------------
    //      Чтение регистров по интерфейсу управления
    always_comb case (ctrl_addr)
        INCR_REG_ADDR:      ctrl_rdat = incr_reg;
        LENGTH_REG_ADDR:    ctrl_rdat = len_reg;
        AMOUNT_REG_ADDR:    ctrl_rdat = amount_cnt;
        default:            ctrl_rdat = data_reg;
    endcase
    
    //------------------------------------------------------------------------------------
    //      Регистр разрешения генерации
    always @(posedge reset, posedge clk)
        if (reset)
            val_reg <= '0;
        // Остановка генерации
        else if (val_reg)
            val_reg <= ~((o_rdy & (amount_cnt == 1)) | (ctrl_wreq & (ctrl_addr == AMOUNT_REG_ADDR) & (ctrl_wdat == 0)));
        // Запуск генерации
        else
            val_reg <= ctrl_wreq & (ctrl_addr == AMOUNT_REG_ADDR) & (ctrl_wdat != 0);
    assign o_val = val_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака конца пакета
    always @(posedge reset, posedge clk)
        if (reset)
            eop_reg <= '0;
        // По запуску генерации
        else if (ctrl_wreq & (ctrl_addr == AMOUNT_REG_ADDR))
            eop_reg <= (ctrl_wdat == 1) | (len_reg == 1);
        // В процессе генерации
        else if (o_val & o_rdy)
            eop_reg <= (amount_cnt == 2) | (len_cnt == 1) | (len_reg == 1);
        // В остальных случаях
        else
            eop_reg <= eop_reg;
    assign o_eop = eop_reg;
endmodule: ps_traffic_generator