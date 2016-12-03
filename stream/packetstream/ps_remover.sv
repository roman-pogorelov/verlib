/*
    //------------------------------------------------------------------------------------
    //      ������ �������� ������� ���������� ���������� PacketStream
    ps_remover
    #(
        .WIDTH          ()  // ����������� ������
    )
    the_ps_remover
    (
        // ����� � ������������
        .reset          (), // i
        .clk            (), // i
        
        // ���������� ���������
        .remove         (), // i
        
        // ��������� ������� ��������
        .wremoved       (), // o
        .premoved       (), // o
        
        // ������� ��������� ���������
        .i_dat          (), // i  [WIDTH - 1 : 0]
        .i_val          (), // i
        .i_eop          (), // i
        .i_rdy          (), // o
        
        // �������� ��������� ���������
        .o_dat          (), // o  [WIDTH - 1 : 0]
        .o_val          (), // o
        .o_eop          (), // o
        .o_rdy          ()  // i
    ); // the_ps_remover
*/

module ps_remover
#(
    parameter int unsigned          WIDTH   = 8     // ����������� ������
)
(
    // ����� � ������������
    input  logic                    reset,
    input  logic                    clk,
    
    // ���������� ���������
    input  logic                    remove,
    
    // ��������� ������� ��������
    output logic                    wremoved,
    output logic                    premoved,
    
    // ������� ��������� ���������
    input  logic [WIDTH - 1 : 0]    i_dat,
    input  logic                    i_val,
    input  logic                    i_eop,
    output logic                    i_rdy,
    
    // �������� ��������� ���������
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      �������� ��������
    logic                           removing;   // ������� ���������� ��������
    //
    logic [WIDTH - 1 : 0]           keep_dat;   // �������� ��������� ��������� ������ 
    logic                           keep_val;   // ��������� ���������� ������ �� ���
    logic                           keep_eop;   // ����� ��� �����������
    logic                           keep_rdy;   //
    
    //------------------------------------------------------------------------------------
    //      ������ ������� � ��������� ���������� ������ �� ��� ����� ��� �����������
    ps_param_keeper
    #(
        .DWIDTH         (WIDTH),    // ����������� ������
        .PWIDTH         (1)         // ����������� ���������� ����������
    )
    remove_request_keeper
    (
        // ����� � ������������
        .reset          (reset),    // i
        .clk            (clk),      // i
        
        // ������� ��������� ���������� ����������� ������
        .desired_param  (remove),   // i  [PWIDTH - 1 : 0]
        
        // �������� ��������� ���������� ����������� ������
        // (� ��������� �� ����� ����������� ����� ������)
        .agreed_param   (removing), // o  [PWIDTH - 1 : 0]
        
        // ������� ��������� ���������
        .i_dat          (i_dat),    // i  [DWIDTH - 1 : 0]
        .i_val          (i_val),    // i
        .i_eop          (i_eop),    // i
        .i_rdy          (i_rdy),    // o
        
        // �������� ��������� ���������
        .o_dat          (keep_dat), // o  [DWIDTH - 1 : 0]
        .o_val          (keep_val), // o
        .o_eop          (keep_eop), // o
        .o_rdy          (keep_rdy)  // i
    ); // remove_request_keeper
    
    //------------------------------------------------------------------------------------
    //      ������ ��������
    assign o_dat = keep_dat;
    assign o_eop = keep_eop & ~removing;
    assign o_val = keep_val & ~removing;
    assign keep_rdy = o_rdy | removing;
    
    //------------------------------------------------------------------------------------
    //      ��������� ������� ��������
    assign wremoved = removing & keep_val;
    assign premoved = wremoved & keep_eop;
    
endmodule // ps_remover