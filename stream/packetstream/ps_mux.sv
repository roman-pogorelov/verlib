/*
    //------------------------------------------------------------------------------------
    //      ������������� ���������� ���������� PacketStream
    ps_mux
    #(
        .WIDTH      (), // ����������� ������
        .SINKS      ()  // ���������� ������� ����������� (SINKS > 1)
    )
    the_ps_mux
    (
        // ����� � ������������
        .reset      (), // i
        .clk        (), // i
        
        // ���� ������ ��������� �����
        .select     (), // i  [$clog2(SINKS) - 1 : 0]
        
        // ������� ��������� ����������
        .i_dat      (), // i  [SINKS - 1 : 0][WIDTH - 1 : 0]
        .i_val      (), // i  [SINKS - 1 : 0]
        .i_eop      (), // i  [SINKS - 1 : 0]
        .i_rdy      (), // o  [SINKS - 1 : 0]
        
        // �������� ��������� ���������
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_mux
*/

module ps_mux
#(
    parameter int unsigned                          WIDTH = 8,  // ����������� ������
    parameter int unsigned                          SINKS = 2   // ���������� ������� ����������� (����� 1-��)
)
(
    // ����� � ������������
    input  logic                                    reset,
    input  logic                                    clk,
    
    // ���� ������ ��������� �����
    input  logic [$clog2(SINKS) - 1 : 0]            select,
    
    // ������� ��������� ����������
    input  logic [SINKS - 1 : 0][WIDTH - 1 : 0]     i_dat,
    input  logic [SINKS - 1 : 0]                    i_val,
    input  logic [SINKS - 1 : 0]                    i_eop,
    output logic [SINKS - 1 : 0]                    i_rdy,
    
    // �������� ��������� ���������
    output logic [WIDTH - 1 : 0]                    o_dat,
    output logic                                    o_val,
    output logic                                    o_eop,
    input  logic                                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      �������� ��������
    logic [SINKS - 1 : 0]                           select_pos;     // ����������� ��� ����������� ������
    logic [$clog2(SINKS) - 1 : 0]                   selected;       // ������ ���������� �����
    logic [SINKS - 1 : 0]                           selected_pos;   // ����������� ��� ���������� ������
    //
    logic [WIDTH - 1 : 0]                           keep_dat;       // ������� ��������� ��������� ������
    logic                                           keep_val;       // ������� � ��������� ���������� ������
    logic                                           keep_eop;       // �� ��� ����� ��� �����������
    logic                                           keep_rdy;       //
    
    //------------------------------------------------------------------------------------
    //      ����������� ��� ����������� ������
    always_comb begin
        select_pos = {SINKS{1'b0}};
        select_pos[select] = 1'b1;
    end
    
    //------------------------------------------------------------------------------------
    //      ������ ������� � ��������� ���������� ������ �� ��� ����� ��� �����������
    ps_param_keeper
    #(
        .DWIDTH         (WIDTH),                // ����������� ������
        .PWIDTH         (SINKS + $clog2(SINKS)) // ����������� ���������� ����������
    )
    select_keeper
    (
        // ����� � ������������
        .reset          (reset),    // i
        .clk            (clk),      // i
        
        // ������� ��������� ���������� ����������� ������
        .desired_param  ({          // i  [PWIDTH - 1 : 0]
                            select,
                            select_pos
                        }),
        
        // �������� ��������� ���������� ����������� ������
        // (� ��������� �� ����� ����������� ����� ������)
        .agreed_param   ({          // o  [PWIDTH - 1 : 0]
                            selected,
                            selected_pos
                        }),
        
        // ������� ��������� ���������
        .i_dat          (keep_dat), // i  [DWIDTH - 1 : 0]
        .i_val          (keep_val), // i
        .i_eop          (keep_eop), // i
        .i_rdy          (keep_rdy), // o
        
        // �������� ��������� ���������
        .o_dat          (o_dat),    // o  [DWIDTH - 1 : 0]
        .o_val          (o_val),    // o
        .o_eop          (o_eop),    // o
        .o_rdy          (o_rdy)     // i
    ); // select_keeper
    
    //------------------------------------------------------------------------------------
    //      ������ �������������������
    assign keep_dat = i_dat[selected];
    assign keep_val = i_val[selected];
    assign keep_eop = i_eop[selected];
    assign i_rdy    = {SINKS{keep_rdy}} & selected_pos;
    
endmodule // ps_mux