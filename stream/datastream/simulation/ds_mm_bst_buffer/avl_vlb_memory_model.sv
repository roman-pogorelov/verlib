/*
    //------------------------------------------------------------------------------------
    //      Модель памяти с пакетным доступом по интерфейсу AvalonMM
    avl_vlb_memory_model
    #(
        .DWIDTH             (), // Разрядность данных
        .AWIDTH             (), // Разрядность адреса
        .BWIDTH             (), // Разрядность шины управления пакетным доступом
        .RDLATENCY          ()  // Задержка при выполнении операции чтения
    )
    the_avl_vlb_memory_model
    (
        // Сброс и тактирование
        .reset              (), // i
        .clk                (), // i
        
        // Интерфейс Avalon MM slave
        .avs_address        (), // i  [AWIDTH - 1 : 0]
        .avs_burstcount     (), // i  [BWIDTH - 1 : 0]
        .avs_write          (), // i
        .avs_writedata      (), // i  [DWIDTH - 1 : 0]
        .avs_read           (), // i
        .avs_readdata       (), // o  [DWIDTH - 1 : 0]
        .avs_readdatavalid  (), // o
        .avs_waitrequest    ()  // o
    ); // the_avl_vlb_memory_model
*/

module avl_vlb_memory_model
#(
    parameter                           DWIDTH    = 8,  // Разрядность данных
    parameter                           AWIDTH    = 8,  // Разрядность адреса
    parameter                           BWIDTH    = 8,  // Разрядность шины управления пакетным доступом
    parameter                           RDLATENCY = 4   // Задержка при выполнении операции чтения
)
(
    // Сброс и тактирование
    input  logic                        reset,
    input  logic                        clk,
    
    // Интерфейс Avalon MM slave
    input  logic [AWIDTH - 1 : 0]       avs_address,
    input  logic [BWIDTH - 1 : 0]       avs_burstcount,
    input  logic                        avs_write,
    input  logic [DWIDTH - 1 : 0]       avs_writedata,
    input  logic                        avs_read,
    output logic [DWIDTH - 1 : 0]       avs_readdata,
    output logic                        avs_readdatavalid,
    output logic                        avs_waitrequest
);
    
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [2**AWIDTH - 1 : 0][DWIDTH - 1 : 0]   memory;         // Массив ячеек памяти
    logic [AWIDTH - 1 : 0]                      address;        // Адрес начального адреса пакета
    int                                         burstcount;     // Текущая длина пакета
    int                                         index;          // Индексная переменная
    logic [DWIDTH - 1 : 0]                      readdata;       // Шина чтения данных
    logic                                       readdatavalid;  // Признак достоверности читаемых данных
    logic                                       rdburstwait;    // Ожидание при пакетном чтении
    
    //------------------------------------------------------------------------------------
    //      Инициализация
    initial begin
        memory = '0;
        readdata = 'X;
        readdatavalid = '0;
        avs_waitrequest = '1;
        rdburstwait = '1;
    end
    
    //------------------------------------------------------------------------------------
    //      Основная логика работы
    always @(posedge clk) begin
        
        
        // Сброс данных чтения
        readdata = 'X;
        readdatavalid = '0;
        
        
        // Транзакция записи
        if (avs_write & ~avs_read & ~avs_waitrequest) begin
            //
            // Пакетная транзакция чтения с некорректно установленной длиной
            if ((avs_burstcount > 2**(BWIDTH - 1)) || (avs_burstcount == 0)) begin
                $fatal("Установлен запрос на запись с недопустимой длиной пакета.");
            end
            //
            // Пакетная транзакция
            else if (avs_burstcount > 1) begin
                index = 1;
                address = avs_address;
                burstcount = avs_burstcount;
                memory[address] = avs_writedata;
                address++;
                while (index < burstcount) begin
                    @(posedge clk);
                    if (avs_read) begin
                        $fatal("Установлен запрос на чтение при незаконченной операции пакетной записи.");
                    end
                    else if (avs_write & ~avs_waitrequest) begin
                        memory[address] = avs_writedata;
                        address++;
                        index++;
                    end
                    avs_waitrequest = $random;
                end
                // $display("Пакетная транзакция записи выполнена.");
            end
            //
            // Одиночная транзакция
            else begin
                memory[avs_address] = avs_writedata;
                // $display("Одиночная транзакция записи выполнена.");
            end
        end
        
        
        // Транзакция чтения
        else if (~avs_write & avs_read & ~avs_waitrequest) begin
            //
            // Пакетная транзакция чтения с некорректно установленной длиной
            if ((avs_burstcount > 2**(BWIDTH - 1)) || (avs_burstcount == 0)) begin
                $fatal("Установлен запрос на чтение с недопустимой длиной пакета.");
            end
            //
            // Пакетная транзакция
            if (avs_burstcount > 1) begin
                index = 1;
                address = avs_address;
                burstcount = avs_burstcount;
                readdata = memory[address];
                readdatavalid = '1;
                avs_waitrequest = '1;
                address++;
                while (index < burstcount) begin
                    @(posedge clk);
                    if (~rdburstwait) begin
                        readdata = memory[address];
                        readdatavalid = '1;
                        address++;
                        index++;
                    end
                    else begin
                        readdata = 'X;
                        readdatavalid = '0;
                    end
                    rdburstwait = $random;
                end
                // $display("Пакетная транзакция чтения выполнена.");
            end
            //
            // Одиночная транзакция
            else begin
                readdata = memory[avs_address];
                readdatavalid = '1;
                // $display("Одиночная транзакция чтения выполнена.");
            end
        end
        
        // Обработка недопустимого сочетания запросов
        else if (avs_write & avs_read) begin
            $fatal("Одновременная установка запросов на запись и чтение.");
        end
        
        // Формирование случайного запроса на ожидание
        avs_waitrequest = $random;
    end
    
    //------------------------------------------------------------------------------------
    //      Генерация линии задержки при чтении
    generate
        
        // Линия задержки не нулевой длины
        if (RDLATENCY) begin
            logic [RDLATENCY - 1 : 0][DWIDTH - 1 : 0]   rddata_buffer;
            logic [RDLATENCY - 1 : 0]                   rdvalid_buffer;
            
            initial begin
                rddata_buffer = 'X;
                rdvalid_buffer = '0;
            end
            
            always @(posedge reset, posedge clk)
                if (reset) begin
                    rddata_buffer = 'X;
                    rdvalid_buffer = '0;
                end
                else begin
                    // Линия задержки в одну ступень
                    if (RDLATENCY == 1) begin
                        rddata_buffer = readdata;
                        rdvalid_buffer = readdatavalid;
                    end
                    // Линия задержки длинной более одного
                    else begin
                        rddata_buffer[0] = readdata;
                        rddata_buffer[RDLATENCY - 1 : 1] = rddata_buffer[RDLATENCY - 2 : 0];
                        rdvalid_buffer[0] = readdatavalid;
                        rdvalid_buffer[RDLATENCY - 1 : 1] = rdvalid_buffer[RDLATENCY - 2 : 0];
                    end
                end
            
            assign avs_readdata = rddata_buffer[RDLATENCY - 1];
            assign avs_readdatavalid = rdvalid_buffer[RDLATENCY - 1];
        end
        
        // Линия задержки нулевой длины
        else begin
            assign avs_readdata = readdata;
            assign avs_readdatavalid = readdatavalid;
        end
    endgenerate
    
endmodule // avl_vlb_memory_model