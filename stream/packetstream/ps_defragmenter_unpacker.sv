/*
    //------------------------------------------------------------------------------------
    //      Модуль распаковывания упакованных фрагментов потокового интерфейса
    //      PacketStream
    ps_defragmenter_unpacker
    #(
        .WIDTH      (), // Разрядность потока
        .ALIGN      ()  // Шаг выравнивания длины фрагмента
    )
    ps_defragmenter_unpacker
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Входной потоковый интерфейс DataStream
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_rdy      (), // o
        
        // Выходной потоковый интерфейс PacketStream
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // ps_defragmenter_unpacker
*/
module ps_defragmenter_unpacker
#(
    parameter int unsigned          WIDTH = 8,  // Разрядность потока
    parameter int unsigned          ALIGN = 2   // Шаг выравнивания длины фрагмента
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Входной потоковый интерфейс DataStream
    input  logic [WIDTH - 1 : 0]    i_dat,
    input  logic                    i_val,
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс PacketStream
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned ALIGN_WIDTH         = ALIGN > 1 ? $clog2(ALIGN) : 1;
    localparam int unsigned MAX_ALIGN_CNT       = ALIGN - 1;
    localparam int unsigned INIT_MAX_ALIGN_CNT  = ALIGN - 2;
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [WIDTH - 2 : 0]           len_cnt;
    logic [ALIGN_WIDTH - 1 : 0]     align_cnt;
    logic                           fin_reg;
    logic                           eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Описание состояний конечного автомата
    enum logic [1 : 0] {
        st_init  = 2'b00,   // Инициализация - разбор заголовка
        st_pass  = 2'b11,   // Пропускание данных
        st_align = 2'b01    // Выравнивание по границе из ALIGN слов
    } state;
    wire [1 : 0] st;
    assign st = state;
    
    //------------------------------------------------------------------------------------
    //      Выходные сигналы конечного автомата
    wire fsm_init = ~st[0];
    wire fsm_pass =  st[1];
    
    //------------------------------------------------------------------------------------
    //      Логика переходов конечного автомата
    always @(posedge reset, posedge clk)
        if (reset)
            state <= st_init;
        else case (state)
            // Инициализация - разбор заголовка
            st_init:
                if (i_val)
                    state <= st_pass;
                else
                    state <= st_init;
            
            // Пропускание данных
            st_pass:
                if (i_val & o_rdy & (len_cnt == 0))
                    if (align_cnt == 0)
                        state <= st_init;
                    else
                        state <= st_align;
                else
                    state <= st_pass;
            
            // Выравнивание по границе из ALIGN слов
            st_align:
                if (align_cnt == 0)
                    state <= st_init;
                else
                    state <= st_align;
            
            // Остальные случаи
            default:
                state <= st_init;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Счетчик длины фрагмента
    always @(posedge reset, posedge clk)
        if (reset)
            len_cnt <= '0;
        else if (fsm_init & i_val)
            len_cnt <= i_dat[WIDTH - 2 : 0];
        else
            len_cnt <= len_cnt - (fsm_pass & i_val & o_rdy);
    
    //------------------------------------------------------------------------------------
    //      Счетчик длины шага выравнивания
    generate
        if (ALIGN > 1) begin: align_cnt_generation
            always @(posedge reset, posedge clk)
                if (reset)
                    align_cnt <= '0;
                else if (fsm_init & i_val)
                    align_cnt <= INIT_MAX_ALIGN_CNT[ALIGN_WIDTH - 1 : 0];
                else if (i_val & (~fsm_pass | o_rdy))
                    if (align_cnt == 0)
                        align_cnt <= MAX_ALIGN_CNT[ALIGN_WIDTH - 1 : 0];
                    else
                        align_cnt <= align_cnt - 1'b1;
                else
                    align_cnt <= align_cnt;
        end
        else begin: no_align_cnt_generation
            assign align_cnt = 1'b0;
        end
    endgenerate

    
    //------------------------------------------------------------------------------------
    //      Регистр признака последнего фрагмента
    always @(posedge reset, posedge clk)
        if (reset)
            fin_reg <= '0;
        else if (fsm_init & i_val)
            fin_reg <= i_dat[WIDTH - 1];
        else
            fin_reg <= fin_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр признака конца пакета
    always @(posedge reset, posedge clk)
        if (reset)
            eop_reg <= '0;
        else if (fsm_init & i_val)
            eop_reg <= i_dat[WIDTH - 1] & (i_dat[WIDTH - 2 : 0] == 0);
        else if (fsm_pass & i_val & o_rdy)
            eop_reg <= fin_reg & (len_cnt == 1);
        else
            eop_reg <= eop_reg;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования выходных сигналов потоковых интерфейсов
    assign i_rdy = o_rdy | ~fsm_pass;
    assign o_val = i_val &  fsm_pass;
    assign o_dat = i_dat;
    assign o_eop = eop_reg;
    
endmodule: ps_defragmenter_unpacker