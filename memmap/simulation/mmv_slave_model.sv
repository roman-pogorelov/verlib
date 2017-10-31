/*
    //------------------------------------------------------------------------------------
    //      Модель ведомого устройства интерфейса  MemoryMapped с произвольной
    //      латентностью чтения. Значение параметра MODE определяет режим работы:
    //          MODE = "RANDOM"  -  записываемые значения игнорируются,
    //                              при чтении генерируются случайные данные;
    //          MODE = "MEMORY"  -  модуль работает в режиме памяти со случайным
    //                              доступом.
    mmv_slave_model
    #(
        .DWIDTH     (), // Разрядность данных
        .AWIDTH     (), // Разрядность адреса
        .RDDELAY    (), // Задержка выдачи данных при чтении (RDDELAY > 0)
        .MODE       ()  // Режим работы ("RANDOM" | "MEMORY")
    )
    the_mmv_slave_model
    (
        // Тактирование и сброс
        .reset      (), // i 
        .clk        (), // i
        
        // Интерфейс MemoryMapped (ведомый)
        .s_addr     (), // i  [AWIDTH - 1 : 0]
        .s_wreq     (), // i
        .s_wdat     (), // i  [DWIDTH - 1 : 0]
        .s_rreq     (), // i
        .s_rdat     (), // o  [DWIDTH - 1 : 0]
        .s_rval     (), // o
        .s_busy     ()  // o
    ); // mmv_slave_model
*/

module mmv_slave_model
#(
    parameter int unsigned          DWIDTH  = 8,        // Разрядность данных
    parameter int unsigned          AWIDTH  = 32,       // Разрядность адреса
    parameter int unsigned          RDDELAY = 2,        // Задержка выдачи данных при чтении (RDDELAY > 0)
    parameter string                MODE    = "RANDOM"  // Режим работы ("RANDOM" | "MEMORY")
)
(
    // Тактирование и сброс
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс MemoryMapped (ведомый)
    input  logic [AWIDTH - 1 : 0]   s_addr,
    input  logic                    s_wreq,
    input  logic [DWIDTH - 1 : 0]   s_wdat,
    input  logic                    s_rreq,
    output logic [DWIDTH - 1 : 0]   s_rdat,
    output logic                    s_rval,
    output logic                    s_busy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [DWIDTH - 1 : 0]                  read_value;
    logic [RDDELAY - 1 : 0][DWIDTH - 1 : 0] rdat_delayline;
    logic [RDDELAY - 1 : 0]                 rval_delayline;
    logic                                   waiting_request;
    logic [AWIDTH + DWIDTH + 1 : 0]         waiting_command;
    logic [AWIDTH + DWIDTH + 1 : 0]         current_command;
    
    //------------------------------------------------------------------------------------
    //      Формирование сигнала s_busy случайным образом
    initial s_busy = '0;
    always @(posedge reset, posedge clk)
        if (reset)
            s_busy <= '0;
        else
            s_busy <= $random;
    
    //------------------------------------------------------------------------------------
    //      Формирование считываемого значения
    generate
        // Режим памяти со случайным доступом
        if (MODE == "MEMORY") begin: memory_implementation
            logic [2**AWIDTH - 1 : 0][DWIDTH - 1 : 0] mem;
            initial mem = 'x;
            always @(posedge reset, posedge clk)
                if (reset)
                    mem <= 'x;
                else if (s_wreq & ~s_busy)
                    mem[s_addr] <= s_wdat;
                else
                    mem <= mem;
            assign read_value = mem[s_addr];
        end
        
        // Режим чтения случайных значений
        else begin: random_implementation
            always @(posedge reset, posedge clk)
                if (reset)
                    read_value <= '0;
                else
                    read_value <= $random;
                end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Линия задержки данных при чтении
    always @(posedge reset, posedge clk)
        if (reset)
            rdat_delayline <= 'x;
        else if (RDDELAY > 1)
            rdat_delayline <= {rdat_delayline[RDDELAY - 2 : 0], ((s_rreq & ~s_busy) ? read_value : {DWIDTH{1'bx}})};
        else
            rdat_delayline <= (s_rreq & ~s_busy) ? read_value : {DWIDTH{1'bx}};
    assign s_rdat = rdat_delayline[RDDELAY - 1];
    
    //------------------------------------------------------------------------------------
    //      Линия задержки признака достоверности читаемых данных
    always @(posedge reset, posedge clk)
        if (reset)
            rval_delayline <= '0;
        else if (RDDELAY > 1)
            rval_delayline <= {rval_delayline[RDDELAY - 2 : 0], (s_rreq & ~s_busy)};
        else
            rval_delayline <= (s_rreq & ~s_busy);
    assign s_rval = rval_delayline[RDDELAY - 1];
    
    //------------------------------------------------------------------------------------
    //      Признак наличия запроса, ожидающего обработки
    always @(posedge reset, posedge clk)
        if (reset)
            waiting_request <= '0;
        else if (waiting_request)
            waiting_request <= s_busy;
        else
            waiting_request <= (s_wreq | s_rreq) & s_busy;
    
    //------------------------------------------------------------------------------------
    //      Текущая команда
    assign current_command = {s_addr, s_wdat, s_wreq, s_rreq};
    
    //------------------------------------------------------------------------------------
    //      Команда, ожидающая обработки
    always @(posedge reset, posedge clk)
        if (reset)
            waiting_command <= '0;
        else if (waiting_request)
            waiting_command <= waiting_command;
        else
            waiting_command <= current_command;
    
    //------------------------------------------------------------------------------------
    //      Проверка на одновременную установку сигналов s_rreq и s_wreq
    always @(posedge clk)
        if (s_rreq & s_wreq) begin
            $display("%8d %m -> ERROR: ведущий одновременно установил запрос и на чтение и на запись", $time);
        end
        
    //------------------------------------------------------------------------------------
    //      Проверка на удержание команды при неготовности ее принять
    always @(posedge clk)
        if (waiting_request & (waiting_command != current_command)) begin
            $display("%8d %m -> ERROR: ошибка удержания команды ведущим при неготовности ее выполнить ведомым", $time);
        end
    
    //------------------------------------------------------------------------------------
    //      Логирование прохождения запросов транзакций
    always @(posedge clk)
        if (~s_busy) begin
            if (s_wreq & ~s_rreq) begin
                $display("%8d %m <- WR REQUEST: address = 0x%x, data = 0x%x", $time, s_addr, s_wdat);
            end
            else if (~s_wreq & s_rreq) begin
                $display("%8d %m <- RD REQUEST: address = 0x%x", $time, s_addr);
            end
        end
    
endmodule // mmv_slave_model