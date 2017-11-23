/*
    //------------------------------------------------------------------------------------
    //      Модель ведущего устройства интерфейса MemoryMapped с произвольной
    //      латентностью чтения, реализующая непрерывную генерацию случайных транзакций
    mmv_master_model
    #(
        .DWIDTH     (), // Разрядность данных
        .AWIDTH     ()  // Разрядность адреса
    )
    the_mmv_master_model
    (
        // Тактирование и сброс
        .reset      (), // i
        .clk        (), // i
        
        // Интерфейс MemoryMapped (ведомый)
        .m_addr     (), // o  [AWIDTH - 1 : 0]
        .m_wreq     (), // o
        .m_wdat     (), // o  [DWIDTH - 1 : 0]
        .m_rreq     (), // o
        .m_rdat     (), // i  [DWIDTH - 1 : 0]
        .m_rval     (), // i
        .m_busy     ()  // i
    ); // the_mmv_master_model
*/

module mmv_master_model
#(
    parameter int unsigned          DWIDTH  = 8,    // Разрядность данных
    parameter int unsigned          AWIDTH  = 32    // Разрядность адреса
)
(
    // Тактирование и сброс
    input  logic                    reset,
    input  logic                    clk,
    
    // Интерфейс MemoryMapped (ведомый)
    output logic [AWIDTH - 1 : 0]   m_addr,
    output logic                    m_wreq,
    output logic [DWIDTH - 1 : 0]   m_wdat,
    output logic                    m_rreq,
    input  logic [DWIDTH - 1 : 0]   m_rdat,
    input  logic                    m_rval,
    input  logic                    m_busy
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic                   request;
    logic                   reqtype;
    logic [AWIDTH - 1 : 0]  rdReqQueue[$];
    
    //------------------------------------------------------------------------------------
    //      Моделирование процесса случайного доступа
    initial begin
        request = '0;
        reqtype = '0;
        m_addr  = '0;
        m_wdat  = '0;
    end
    always @(posedge reset, posedge clk)
        if (reset) begin
            request = '0;
            reqtype = '0;
            m_addr  = '0;
            m_wdat  = '0;
        end
        else begin
            if (request) begin
                if (~m_busy) begin
                    request = '0;
                end
            end
            if (~request) begin
                request = $random;
                reqtype = $random;
                m_addr  = $random;
                m_wdat  = $random;
            end
        end
    assign m_wreq =  reqtype & request;
    assign m_rreq = ~reqtype & request;
    
    //------------------------------------------------------------------------------------
    //      Логирование прохождения запросов транзакций
    always @(posedge clk) begin
        if (m_wreq & ~m_busy) begin
            $display("%8d %m -> WR REQUEST: address = 0x%x, data = 0x%x", $time, m_addr, m_wdat);
        end
        else if (m_rreq & ~m_busy) begin
            $display("%8d %m -> RD REQUEST: address = 0x%x", $time, m_addr);
            rdReqQueue.push_front(m_addr);
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
                $display("%8d %m -> ERROR: ведомый прислал ответ на чтение, которого не запрашивал ведущий", $time, m_addr);
            end
        end
    end
    
endmodule: mmv_master_model