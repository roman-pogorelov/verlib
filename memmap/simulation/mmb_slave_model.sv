/*
    //------------------------------------------------------------------------------------
    //      Модель ведомого устройства интерфейса MemoryMapped с пакетным доступом.
    //      Значение параметра MODE определяет режим работы:
    //          MODE = "RANDOM"  -  записываемые значения игнорируются,
    //                              при чтении генерируются случайные данные;
    //          MODE = "MEMORY"  -  модуль работает в режиме памяти со случайным
    //                              доступом.
    mmb_slave_model
    #(
        .DWIDTH     (), // Разрядность данных
        .AWIDTH     (), // Разрядность адреса
        .BWIDTH     (), // Разрядность размера пакета
        .RDDELAY    (), // Задержка выдачи данных при чтении (RDDELAY > 0)
        .RDPENDS    (), // Максимальное количество незавершенных чтений
        .MODE       ()  // Режим работы ("RANDOM" | "MEMORY")
    )
    the_mmb_slave_model
    (
        // Тактирование и сброс
        .reset      (), // i 
        .clk        (), // i
        
        // Интерфейс MemoryMapped (ведомый)
        .s_addr     (), // i  [AWIDTH - 1 : 0]
        .s_bcnt     (), // i  [BWIDTH - 1 : 0]
        .s_wreq     (), // i
        .s_wdat     (), // i  [DWIDTH - 1 : 0]
        .s_rreq     (), // i
        .s_rdat     (), // o  [DWIDTH - 1 : 0]
        .s_rval     (), // o
        .s_busy     ()  // o
    ); // mmb_slave_model
*/

module mmb_slave_model
#(
    parameter int unsigned          DWIDTH  = 8,        // Разрядность данных
    parameter int unsigned          AWIDTH  = 32,       // Разрядность адреса
    parameter int unsigned          BWIDTH  = 8,        // Разрядность размера пакета
    parameter int unsigned          RDDELAY = 2,        // Задержка выдачи данных при чтении (RDDELAY > 0)
    parameter int unsigned          RDPENDS = 2,        // Максимальное количество незавершенных чтений
    parameter string                MODE    = "RANDOM"  // Режим работы ("RANDOM" | "MEMORY")
)
(
    // Тактирование и сброс
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс MemoryMapped (ведомый)
    input  logic [AWIDTH - 1 : 0]   s_addr,
    input  logic [BWIDTH - 1 : 0]   s_bcnt,
    input  logic                    s_wreq,
    input  logic [DWIDTH - 1 : 0]   s_wdat,
    input  logic                    s_rreq,
    output logic [DWIDTH - 1 : 0]   s_rdat,
    output logic                    s_rval,
    output logic                    s_busy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [2**AWIDTH - 1 : 0][DWIDTH - 1 : 0]   mem = 'x;
    //
    logic [RDDELAY - 1 : 0][DWIDTH - 1 : 0]     rdat_delayline  = 'x;
    logic [RDDELAY - 1 : 0]                     rval_delayline  = '0;
    logic                                       waiting_request = '0;
    logic [AWIDTH + DWIDTH + BWIDTH + 1 : 0]    waiting_command = '0;
    logic [AWIDTH + DWIDTH + BWIDTH + 1 : 0]    current_command;
    //
    logic [AWIDTH - 1 : 0]                      waddress   = 0;
    logic [AWIDTH - 1 : 0]                      raddress   = 0;
    logic [BWIDTH - 1 : 0]                      windex     = 0;
    logic [BWIDTH - 1 : 0]                      rindex     = 0;
    logic                                       wburst     = 0;
    logic [AWIDTH + BWIDTH - 1 : 0]             rdqueue[$] = {};
    logic                                       rdena      = 0;
    logic [DWIDTH - 1 : 0]                      rdvalue    = 'x;
    logic                                       rdvalid    = 0;
    
    //------------------------------------------------------------------------------------
    //      Формирование сигнала s_busy случайным образом
    initial s_busy = 0;
    always @(posedge reset, posedge clk)
        if (reset)
            s_busy <= 0;
        else
            s_busy <= $random | (rdqueue.size() >= RDPENDS);
    
    //------------------------------------------------------------------------------------
    //      Логика обработки запросов транзакций
    always @(posedge reset, posedge clk) begin
        if (reset) begin
            waddress = 0;
            windex   = 0;
            wburst   = 0;
            rdqueue  = {};
        end
        else if (~s_busy) begin
            // Транзакция записи
            if (s_wreq & ~s_rreq) begin
                // Начало пакета
                if (~wburst) begin
                    waddress = s_addr;
                    windex   = s_bcnt - 1;
                end
                // Продолжение пакета
                else begin
                    waddress++;
                    windex--;
                end
                wburst = (windex != 0);
                $display("%8d %m <- WR REQUEST: address = 0x%x, data = 0x%x", $time, waddress, s_wdat);
                if (MODE == "MEMORY") begin
                    mem[waddress] = s_wdat;
                end
            end
            // Транзакция чтения
            else if (~s_wreq & s_rreq) begin
                $display("%8d %m <- RD REQUEST: address = 0x%x, count = 0x%x", $time, s_addr, s_bcnt);
                rdqueue.push_front({s_addr, s_bcnt});
            end
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Формирование сигнала rdena случайным образом
    always @(posedge reset, posedge clk)
        if (reset)
            rdena <= 0;
        else
            rdena <= $random;
    
    //------------------------------------------------------------------------------------
    //      Логика формирования ответов на запросы чтения
    always @(posedge reset, posedge clk)
        if (reset) begin
            raddress = 0;
            rindex   = 0;
            rdvalue  = 'x;
            rdvalid  = 0;
        end
        // Если чтение разрешено и очередь запросов не пуста
        else if (rdena & (rdqueue.size() > 0)) begin
            {raddress, rindex} = rdqueue.pop_back();
            rdvalid = 1;
            if (MODE == "MEMORY")
                rdvalue = mem[raddress];
            else
                rdvalue = $random;
            raddress++;
            rindex--;
            // Если слово не последнее, возвращаем команду в очередь
            if (rindex != 0) begin
                rdqueue.push_back({raddress, rindex});
            end
        end
        else begin
            rdvalue = 'x;
            rdvalid = 0;
        end
    
    //------------------------------------------------------------------------------------
    //      Линия задержки данных при чтении
    always @(posedge reset, posedge clk)
        if (reset)
            rdat_delayline <= 'x;
        else if (RDDELAY > 1)
            rdat_delayline <= {rdat_delayline[RDDELAY - 2 : 0], rdvalue};
        else
            rdat_delayline <= rdvalue;
    assign s_rdat = rdat_delayline[RDDELAY - 1];
    
    //------------------------------------------------------------------------------------
    //      Линия задержки признака достоверности читаемых данных
    always @(posedge reset, posedge clk)
        if (reset)
            rval_delayline <= '0;
        else if (RDDELAY > 1)
            rval_delayline <= {rval_delayline[RDDELAY - 2 : 0], rdvalid};
        else
            rval_delayline <= rdvalid;
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
    assign current_command = {s_addr, s_bcnt, s_wdat, s_wreq, s_rreq};
    
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
    always @(posedge clk) begin
        if (s_rreq & s_wreq) begin
            $display("%8d %m -> ERROR: ведущий одновременно установил запрос и на чтение и на запись", $time);
        end
    end
        
    //------------------------------------------------------------------------------------
    //      Проверка на удержание команды при неготовности ее принять
    always @(posedge clk) begin
        if (waiting_request & (waiting_command != current_command)) begin
            $display("%8d %m -> ERROR: ошибка удержания команды ведущим при неготовности ее выполнить ведомым", $time);
        end
    end
    
    //------------------------------------------------------------------------------------
    //      Проверка на установку сигнала s_rreq при незаконченной записи
    always @(posedge clk) begin
        if (wburst & s_rreq) begin
            $display("%8d %m -> ERROR: ведущий установил запрос на чтение при незаконченной пакетной записи", $time);
        end
    end
    
endmodule // mmb_slave_model