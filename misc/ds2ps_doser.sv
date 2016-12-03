/*
    //------------------------------------------------------------------------------------
    //      Модуль формирования пакетов заданной длины потокового интерфейса
    //      PacketStream из потока DataStream (формирование каждого пакета инициируется
    //      установкой сигнала ctrl_run)
    ds2ps_doser
    #(
        .DWIDTH         (), // Разрядность потоковых интерфейсов
        .CWIDTH         ()  // Разрядность интерфейса установки количества слов
    )
    the_ds2ps_doser
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Интерфейс управления
        .ctrl_amount    (), // i  [CWIDTH - 1 : 0]
        .ctrl_run       (), // i
        .ctrl_abort     (), // i
        
        // Интерфейс статуса
        .stat_left      (), // o  [CWIDTH - 1 : 0]
        .stat_busy      (), // o
        .stat_done      (), // o
        
        // Входной потоковый интерфейс
        .i_dat          (), // i  [DWIDTH - 1 : 0]
        .i_val          (), // i
        .i_rdy          (), // o
        
        // Выходной потоковый интерфейс
        .o_dat          (), // o  [DWIDTH - 1 : 0]
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ds2ps_doser
*/

module ds2ps_doser
#(
    parameter int unsigned          DWIDTH = 8,     // Разрядность потоковых интерфейсов
    parameter int unsigned          CWIDTH = 8      // Разрядность интерфейса установки количества слов
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic [CWIDTH - 1 : 0]   ctrl_amount,
    input  logic                    ctrl_run,
    input  logic                    ctrl_abort,
    
    // Интерфейс статуса
    output logic [CWIDTH - 1 : 0]   stat_left,
    output logic                    stat_busy,
    output logic                    stat_done,
    
    // Входной потоковый интерфейс
    input  logic [DWIDTH - 1 : 0]   i_dat,
    input  logic                    i_val,
    output logic                    i_rdy,
    
    // Выходной потоковый интерфейс
    output logic [DWIDTH - 1 : 0]   o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      Описание регистров
    logic [CWIDTH - 1 : 0]          amount_cnt;
    logic [DWIDTH - 1 : 0]          dat_reg;

    //------------------------------------------------------------------------------------
    //      Описание состояний и управляющих сигналов конечного автомата
    enum logic [4 : 0] {
        st_idle     = 5'b00000,  // Бездействие
        st_begin    = 5'b00011,  // Прием первого слова
        st_passing  = 5'b00111,  // Трансляция слов
        st_finish   = 5'b01101,  // Передача последнего слова
        st_dummy    = 5'b10001   // Пустое состояние для отработки нулевой длины
    } state;
    wire [4 : 0] st;
    assign st = state;
    wire fsm_busy   = st[0];    // Занятость
    wire fsm_rcvena = st[1];    // Разрешение приема
    wire fsm_tsmena = st[2];    // Разрешение передачи
    wire fsm_last   = st[3];    // Последнее слово
    wire fsm_dummy  = st[4];    // Пустышка
    
    //------------------------------------------------------------------------------------
    //      Логика переходов конечного автомата
    always @(posedge reset, posedge clk)
        if (reset)
            state <= st_idle;
        else case (state)
            st_idle:
                if (ctrl_run)
                    if (ctrl_amount == 0)
                        state <= st_dummy;
                    else
                        state <= st_begin;
                else
                    state <= st_idle;
                    
            st_begin:
                if (ctrl_abort)
                    if (i_val)
                        state <= st_finish;
                    else
                        state <= st_dummy;
                else if (i_val)
                    if (amount_cnt == 1)
                        state <= st_finish;
                    else
                        state <= st_passing;
                else
                    state <= st_begin;
            
            st_passing:
                if (ctrl_abort | (i_val & o_rdy & (amount_cnt == 1)))
                    state <= st_finish;
                else
                    state <= st_passing;
            
            st_finish:
                if (o_rdy)
                    state <= st_idle;
                else
                    state <= st_finish;
            
            st_dummy:
                state <= st_idle;
            
            default:
                state <= st_idle;
        endcase
    
    //------------------------------------------------------------------------------------
    //      Счетчик количества принятых слов
    always @(posedge reset, posedge clk)
        if (reset)
            amount_cnt <= '0;
        else if (fsm_busy)
            amount_cnt <= amount_cnt - (i_val & i_rdy);
        else if (ctrl_run)
            amount_cnt <= ctrl_amount;
        else
            amount_cnt <= amount_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр буферизации слов данных
    always @(posedge reset, posedge clk)
        if (reset)
            dat_reg <= '0;
        else if (i_val & i_rdy)
            dat_reg <= i_dat;
        else
            dat_reg <= dat_reg;
    assign o_dat = dat_reg;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования сигналов управления потоками
    assign i_rdy = fsm_rcvena & (~fsm_tsmena | o_rdy);
    assign o_val = fsm_tsmena & (~fsm_rcvena | i_val);
    assign o_eop = fsm_last;
    
    //------------------------------------------------------------------------------------
    //      Статусные сигналы
    assign stat_left = amount_cnt;
    assign stat_busy = fsm_busy;
    assign stat_done = fsm_dummy | (fsm_last & o_rdy);
    
endmodule // ds2ps_doser