/*
    //------------------------------------------------------------------------------------
    //      Модуль тестирования шины адреса памяти со случайным доступом
    mmv_ram_ab_tester
    #(
        .AWIDTH     (), // Разрядность адреса
        .DWIDTH     (), // Разрядность данных
        .RDPENDS    ()  // Максимальное количество незавершенных транзакций чтения
    )
    the_mmv_ram_ab_tester
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейс управления
        .clear      (), // i  Синхронный сброс
        .start      (), // i  Запуск теста
        .ready      (), // o  Готовность к запуску теста
        .fault      (), // o  Одиночный импульс индикации ошибки
        .done       (), // o  Одиночный импульс окончания теста
        
        // Тестирующий интерфейс ведущего
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_mmv_ram_ab_tester
*/

module mmv_ram_ab_tester
#(
    parameter int unsigned          AWIDTH  = 8,    // Разрядность адреса
    parameter int unsigned          DWIDTH  = 8,    // Разрядность данных
    parameter int unsigned          RDPENDS = 2     // Максимальное количество незавершенных транзакций чтения
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс управления
    input  logic                    clear,  // Синхронный сброс
    input  logic                    start,  // Запуск теста
    output logic                    ready,  // Готовность к запуску теста
    output logic                    fault,  // Одиночный импульс индикации ошибки
    output logic                    done,   // Одиночный импульс окончания теста
    
    // Тестирующий интерфейс ведущего
    output logic [AWIDTH - 1 : 0]   m_addr,
    output logic                    m_wreq,
    output logic [DWIDTH - 1 : 0]   m_wdat,
    output logic                    m_rreq,
    input  logic [DWIDTH - 1 : 0]   m_rdat,
    input  logic                    m_rval,
    input  logic                    m_busy
);

endmodule: mmv_ram_ab_tester