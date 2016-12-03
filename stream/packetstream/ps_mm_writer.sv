/*
    //------------------------------------------------------------------------------------
    //      Модуль записи пакета потокового интерфейса PacketStream в память,
    //      доступную через интерфейс Avalon MM
    ps_mm_writer
    #(
        .DWIDTH             (), // Разрядность данных
        .AWIDTH             (), // Разрядность адреса
        .SYMBOLS            ()  // Количество символов
    )
    the_ps_mm_writer
    (
        // Сброс и тактирование
        .reset              (), // i
        .clk                (), // i
        
        // Интерфейс задания стартового адреса
        .address            (), // i  [AWIDTH - 1 : 0]
        
        // Входной потоковый интерфейс
        .i_dat              (), // i  [DWIDTH - 1 : 0]
        .i_mty              (), // i  [$clog2(SYMBOLS) - 1 : 0]
        .i_val              (), // i
        .i_eop              (), // i
        .i_rdy              (), // o
        
        // Интерфейс Avalon-MM-Master
        .avm_address        (), // o  [AWIDTH - 1 : 0]
        .avm_byteenable     (), // o  [SYMBOLS - 1 : 0]
        .avm_write          (), // o
        .avm_writedata      (), // o  [DWIDTH - 1 : 0]
        .avm_waitrequest    ()  // i
    ); // the_ps_mm_writer
*/

module ps_mm_writer
#(
    parameter int unsigned                  DWIDTH  = 8,    // Разрядность данных
    parameter int unsigned                  AWIDTH  = 8,    // Разрядность адреса
    parameter int unsigned                  SYMBOLS = 4     // Количество символов
)
(
    // Сброс и тактирование
    input  logic                            reset,
    input  logic                            clk,
    
    // Интерфейс задания стартового адреса
    input  logic [AWIDTH - 1 : 0]           address,
    
    // Входной потоковый интерфейс
    input  logic [DWIDTH - 1 : 0]           i_dat,
    input  logic [$clog2(SYMBOLS) - 1 : 0]  i_mty,
    input  logic                            i_val,
    input  logic                            i_eop,
    output logic                            i_rdy,
    
    // Интерфейс Avalon-MM-Master
    output logic [AWIDTH - 1 : 0]           avm_address,
    output logic [SYMBOLS - 1 : 0]          avm_byteenable,
    output logic                            avm_write,
    output logic [DWIDTH - 1 : 0]           avm_writedata,
    input  logic                            avm_waitrequest
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [DWIDTH - 1 : 0]                  s_dat;
    logic                                   s_val;
    logic                                   s_sop;
    logic                                   s_eop;
    logic                                   s_rdy;
    //
    logic [AWIDTH - 1 : 0]                  addr_cnt;
    logic [SYMBOLS - 1 : 0]                 mty_one_hote;
    logic [SYMBOLS - 1 : 0]                 be_reversed;
    
    
    //------------------------------------------------------------------------------------
    //      Модуль добавления признака начала пакета потокового интерфейса PacketStream
    ps_sop_creator
    #(
        .WIDTH      (DWIDTH)    // Разрядность потока
    )
    the_ps_sop_creator
    (
        // Сброс и тактирование
        .reset      (reset),    // i
        .clk        (clk),      // i
        
        // Входной потоковый интерфейс
        .i_dat      (i_dat),    // i  [WIDTH - 1 : 0]
        .i_val      (i_val),    // i
        .i_eop      (i_eop),    // i
        .i_rdy      (i_rdy),    // o
        
        // Выходной потоковый интерфейс
        .o_dat      (s_dat),    // o  [WIDTH - 1 : 0]
        .o_val      (s_val),    // o
        .o_sop      (s_sop),    // o
        .o_eop      (s_eop),    // o
        .o_rdy      (s_rdy)     // i
    ); // the_ps_sop_creator
    
    //------------------------------------------------------------------------------------
    //      Счетчик адреса
    always @(posedge reset, posedge clk)
        if (reset)
            addr_cnt <= '0;
        else if (s_val & s_rdy)
            addr_cnt <= (s_sop ? address : addr_cnt) + 1'b1;
        else
            addr_cnt <= addr_cnt;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования адреса интерфейса Avalon-MM-Master
    assign avm_address   = s_sop ? address : addr_cnt;
    
    //------------------------------------------------------------------------------------
    //      Сквозная трансляция сигналов
    assign avm_write = s_val;
    assign avm_writedata = s_dat;
    assign s_rdy = ~avm_waitrequest;
    
    //------------------------------------------------------------------------------------
    //      Преобразователь двоичного кода в позиционный
    binary2onehot
    #(
        .BIN_WIDTH  ($clog2(SYMBOLS))   // Разрядность входа двоичного кода
    )
    the_binary2onehot
    (
        .binary     (i_mty),            // i  [BIN_WIDTH - 1 : 0]
        .onehot     (mty_one_hote)      // o  [2**BIN_WIDTH - 1 : 0]
    ); // the_binary2onehot
    
    //------------------------------------------------------------------------------------
    //      "Отраженный" сигнал разрешения байт
    assign be_reversed = ~((mty_one_hote - 1'b1) & {SYMBOLS{i_eop}});
    
    //------------------------------------------------------------------------------------
    //      Модуль реверса (зеркалирования) разрядов произвольной параллельной шины
    bitreverser
    #(
        .WIDTH      (SYMBOLS)           // Разрядность
    )
    be_bitreverser
    (
        // Входные данные
        .i_dat      (be_reversed),      // i  [WIDTH - 1 : 0] 
        
        // Выходные данные
        .o_dat      (avm_byteenable)    // o  [WIDTH - 1 : 0]
    ); // be_bitreverser
    
endmodule // ps_mm_writer