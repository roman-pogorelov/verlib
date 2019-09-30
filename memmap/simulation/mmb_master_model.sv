/*
    //------------------------------------------------------------------------------------
    //      Модель ведущего устройства интерфейса MemoryMapped с пакетным доступом,
    //      реализующая непрерывную генерацию случайных транзакций
    mmb_master_model
    #(
        .DWIDTH     (), // Разрядность данных
        .AWIDTH     (), // Разрядность адреса
        .BWIDTH     ()  // Разрядность размера пакета
    )
    the_mmb_master_model
    (
        // Тактирование и сброс
        .reset      (), // i
        .clk        (), // i

        // Интерфейс MemoryMapped (ведомый)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_bcnt     (), // o  [BWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_mmb_master_model
*/

module mmb_master_model
#(
    parameter int unsigned          DWIDTH  = 8,    // Разрядность данных
    parameter int unsigned          AWIDTH  = 32,   // Разрядность адреса
    parameter int unsigned          BWIDTH  = 32    // Разрядность размера пакета
)
(
    // Тактирование и сброс
    input  logic                    reset,
    input  logic                    clk,

    // Интерфейс MemoryMapped (ведомый)
    output logic [AWIDTH - 1 : 0]   m_addr,
    output logic [BWIDTH - 1 : 0]   m_bcnt,
    output logic                    m_wreq,
    output logic [DWIDTH - 1 : 0]   m_wdat,
    output logic                    m_rreq,
    input  logic [DWIDTH - 1 : 0]   m_rdat,
    input  logic                    m_rval,
    input  logic                    m_busy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                   request       = 0;
    logic                   reqtype       = 0;
    logic [AWIDTH - 1 : 0]  address       = 0;
    logic [BWIDTH - 1 : 0]  burstcnt      = 0;
    logic [BWIDTH - 1 : 0]  wburstcnt     = 0;
    logic [DWIDTH - 1 : 0]  wrdata        = 0;
    logic                   wrenable      = 0;
    logic [AWIDTH - 1 : 0]  rdReqQueue[$] = {};

    //------------------------------------------------------------------------------------
    //      Моделирование процесса случайного доступа
    always @(posedge reset, posedge clk)
        if (reset) begin
            request   = 0;
            reqtype   = 0;
            address   = 0;
            burstcnt  = 0;
            wburstcnt = 0;
            wrdata    = 0;
        end
        else begin
            if (request) begin
                if (~m_busy) begin
                    if (reqtype) begin
                        if (wrenable) begin
                            wburstcnt--;
                            if (wburstcnt == 0)
                                request = '0;
                        end
                    end
                    else begin
                        request = '0;
                    end
                end
            end

            if (~request) begin
                request   = $random;
                reqtype   = $random;
                address   = $random;
                burstcnt  = $random;
                wburstcnt = burstcnt;
                wrdata    = $random;
            end
        end

    //------------------------------------------------------------------------------------
    //      Признак разрешения транзакции записи
    always @(posedge reset, posedge clk)
        if (reset)
            wrenable <= 0;
        else if (wrenable & request & reqtype & m_busy)
            wrenable <= wrenable;
        else
            wrenable <= $random;

    //------------------------------------------------------------------------------------
    //      Выходные сигналы интерфейса ведущего
    assign m_addr =  address;
    assign m_bcnt =  burstcnt;
    assign m_wdat =  wrdata;
    assign m_wreq =  reqtype & request & wrenable;
    assign m_rreq = ~reqtype & request;

    //------------------------------------------------------------------------------------
    //      Логирование прохождения запросов транзакций
    always @(posedge clk) begin
        if (m_wreq & ~m_busy) begin
            $display("%8d %m -> WR REQUEST: address = 0x%x, count = 0x%x, data = 0x%x", $time, m_addr, m_bcnt, m_wdat);
        end
        else if (m_rreq & ~m_busy) begin
            automatic logic [AWIDTH - 1 : 0] addr;
            automatic logic [BWIDTH - 1 : 0] bcnt;
            $display("%8d %m -> RD REQUEST: address = 0x%x, count = 0x%x", $time, m_addr, m_bcnt);
            addr = m_addr;
            bcnt = m_bcnt;
            do begin
                rdReqQueue.push_front(addr);
                addr++;
                bcnt--;
            end
            while (bcnt != 0);
        end
    end

    //------------------------------------------------------------------------------------
    //      Логирование и верификация ответов на транзакции чтения
    always @(posedge clk) begin
        if (m_rval) begin
            if (rdReqQueue.size() != 0) begin
                automatic logic [AWIDTH - 1 : 0] addr;
                addr = rdReqQueue.pop_back();
                $display("%8d %m <- RD RESPONSE: address = 0x%x, data = 0x%x", $time, addr, m_rdat);
            end
            else begin
                $display("%8d %m -> ERROR: unexpected read response has been received by the master", $time);
            end
        end
    end

endmodule: mmb_master_model