`timescale  1ns / 1ps


module mmv_to_ps_to_mmv_tb ();


    // Constants declaration
    localparam int unsigned     WIDTH   = 8;    // Width of address and data
    localparam int unsigned     MAXRD   = 8;    // The maximum number of pending read transactions
    localparam int unsigned     RDLAT   = 24;   // Read latency of MemoryMapped slave


    // Signals description
    logic                       rst;
    logic                       clk;
    //
    logic [WIDTH - 1 : 0]       m_addr;
    logic                       m_wreq;
    logic [WIDTH - 1 : 0]       m_wdat;
    logic                       m_rreq;
    logic [WIDTH - 1 : 0]       m_rdat;
    logic                       m_rval;
    logic                       m_busy;
    //
    logic [WIDTH - 1 : 0]       s_addr;
    logic                       s_wreq;
    logic [WIDTH - 1 : 0]       s_wdat;
    logic                       s_rreq;
    logic [WIDTH - 1 : 0]       s_rdat;
    logic                       s_rval;
    logic                       s_busy;
    //
    logic [WIDTH - 1 : 0]       req_dat;
    logic                       req_val;
    logic                       req_eop;
    logic                       req_rdy;
    //
    logic [WIDTH - 1 : 0]       ack_dat;
    logic                       ack_val;
    logic                       ack_eop;
    logic                       ack_rdy;


    // Reset
    initial begin
        rst = #0ps     1'b1;
        rst = #10001ps 1'b0;
    end


    // Clock
    initial clk = 1'b1;
    always  clk = #5ns ~clk;


    //------------------------------------------------------------------------------------
    //      Модель ведущего устройства интерфейса MemoryMapped с произвольной
    //      латентностью чтения, реализующая непрерывную генерацию случайных транзакций
    mmv_master_model
    #(
        .DWIDTH     (WIDTH),    // Разрядность данных
        .AWIDTH     (WIDTH)     // Разрядность адреса
    )
    the_mmv_master_model
    (
        // Тактирование и сброс
        .reset      (rst),      // i
        .clk        (clk),      // i

        // Интерфейс MemoryMapped (ведомый)
        .m_addr     (m_addr),   // o  [AWIDTH - 1 : 0]
        .m_wreq     (m_wreq),   // o
        .m_wdat     (m_wdat),   // o  [DWIDTH - 1 : 0]
        .m_rreq     (m_rreq),   // o
        .m_rdat     (m_rdat),   // i  [DWIDTH - 1 : 0]
        .m_rval     (m_rval),   // i
        .m_busy     (m_busy)    // i
    ); // the_mmv_master_model


    // The module to encode transactions of MemoryMapped interface with
    // variable latency to packets of PacketStream interface
    mmv_to_ps_enc
    #(
        .WIDTH      (WIDTH)     // Address and data width
    )
    the_mmv_to_ps_enc
    (
        // Reset and clock
        .rst        (rst),      // i
        .clk        (clk),      // i

        // MemoryMapped slave interface
        .s_addr     (m_addr),   // i  [WIDTH - 1 : 0]
        .s_wreq     (m_wreq),   // i
        .s_wdat     (m_wdat),   // i  [WIDTH - 1 : 0]
        .s_rreq     (m_rreq),   // i
        .s_rdat     (m_rdat),   // o  [WIDTH - 1 : 0]
        .s_rval     (m_rval),   // o
        .s_busy     (m_busy),   // o

        // Inbound stream
        .i_dat      (ack_dat),  // i  [WIDTH - 1 : 0]
        .i_val      (ack_val),  // i
        .i_eop      (ack_eop),  // i
        .i_rdy      (ack_rdy),  // o

        // Outbound stream
        .o_dat      (req_dat),  // o  [WIDTH - 1 : 0]
        .o_val      (req_val),  // o
        .o_eop      (req_eop),  // o
        .o_rdy      (req_rdy)   // i
    ); // the_mmv_to_ps_enc


    // The module to decode transactions of MemoryMapped interface with
    // variable latency from packets of PacketStream interface
    mmv_from_ps_dec
    #(
        .WIDTH      (WIDTH),    // Width of address and data
        .MAXRD      (MAXRD)     // The maximum number of pending read transactions
    )
    the_mmv_from_ps_dec
    (
        // Reset and clock
        .rst        (rst),      // i
        .clk        (clk),      // i

        // MemoryMapped master interface
        .m_addr     (s_addr),   // o  [WIDTH - 1 : 0]
        .m_wreq     (s_wreq),   // o
        .m_wdat     (s_wdat),   // o  [WIDTH - 1 : 0]
        .m_rreq     (s_rreq),   // o
        .m_rdat     (s_rdat),   // i  [WIDTH - 1 : 0]
        .m_rval     (s_rval),   // i
        .m_busy     (s_busy),   // i

        // Inbound stream
        .i_dat      (req_dat),  // i  [WIDTH - 1 : 0]
        .i_val      (req_val),  // i
        .i_eop      (req_eop),  // i
        .i_rdy      (req_rdy),  // o

        // Outbound stream
        .o_dat      (ack_dat),  // o  [WIDTH - 1 : 0]
        .o_val      (ack_val),  // o
        .o_eop      (ack_eop),  // o
        .o_rdy      (ack_rdy)   // i
    ); // the_mmv_from_ps_dec


    //------------------------------------------------------------------------------------
    //      Модель ведомого устройства интерфейса  MemoryMapped с произвольной
    //      латентностью чтения. Значение параметра MODE определяет режим работы:
    //          MODE = "RANDOM"  -  записываемые значения игнорируются,
    //                              при чтении генерируются случайные данные;
    //          MODE = "MEMORY"  -  модуль работает в режиме памяти со случайным
    //                              доступом.
    mmv_slave_model
    #(
        .DWIDTH     (WIDTH),    // Разрядность данных
        .AWIDTH     (WIDTH),    // Разрядность адреса
        .RDDELAY    (RDLAT),    // Задержка выдачи данных при чтении (RDDELAY > 0)
        .MODE       ("RANDOM")  // Режим работы ("RANDOM" | "MEMORY")
    )
    the_mmv_slave_model
    (
        // Тактирование и сброс
        .reset      (rst),      // i
        .clk        (clk),      // i

        // Интерфейс MemoryMapped (ведомый)
        .s_addr     (s_addr),   // i  [AWIDTH - 1 : 0]
        .s_wreq     (s_wreq),   // i
        .s_wdat     (s_wdat),   // i  [DWIDTH - 1 : 0]
        .s_rreq     (s_rreq),   // i
        .s_rdat     (s_rdat),   // o  [DWIDTH - 1 : 0]
        .s_rval     (s_rval),   // o
        .s_busy     (s_busy)    // o
    ); // mmv_slave_model


endmodule: mmv_to_ps_to_mmv_tb
