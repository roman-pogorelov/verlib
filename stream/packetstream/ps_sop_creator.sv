/*
    //------------------------------------------------------------------------------------
    //      ������ ���������� �������� ������ ������ ���������� ���������� PacketStream
    ps_sop_creator
    #(
        .WIDTH      ()  // ����������� ������
    )
    the_ps_sop_creator
    (
        // ����� � ������������
        .reset      (), // i
        .clk        (), // i
        
        // ������� ��������� ���������
        .i_dat      (), // i  [WIDTH - 1 : 0]
        .i_val      (), // i
        .i_eop      (), // i
        .i_rdy      (), // o
        
        // �������� ��������� ���������
        .o_dat      (), // o  [WIDTH - 1 : 0]
        .o_val      (), // o
        .o_sop      (), // o
        .o_eop      (), // o
        .o_rdy      ()  // i
    ); // the_ps_sop_creator
*/

module ps_sop_creator
#(
    parameter int unsigned          WIDTH = 8   // ����������� ������
)
(
    // ����� � ������������
    input  logic                    reset,
    input  logic                    clk,
    
    // ������� ��������� ���������
    input  logic [WIDTH - 1 : 0]    i_dat,
    input  logic                    i_val,
    input  logic                    i_eop,
    output logic                    i_rdy,
    
    // �������� ��������� ���������
    output logic [WIDTH - 1 : 0]    o_dat,
    output logic                    o_val,
    output logic                    o_sop,
    output logic                    o_eop,
    input  logic                    o_rdy
);
    //------------------------------------------------------------------------------------
    //      ������� �������� ������ ������
    logic sop_reg;
    initial sop_reg = '1;
    always @(posedge reset, posedge clk)
        if (reset)
            sop_reg <= '1;
        else if (i_val & i_rdy)
            sop_reg <= i_eop;
        else
            sop_reg <= sop_reg;
    assign o_sop = sop_reg;
    
    //------------------------------------------------------------------------------------
    //      �������� ���������� �������
    assign o_dat = i_dat;
    assign o_val = i_val;
    assign o_eop = i_eop;
    assign i_rdy = o_rdy;
    
endmodule // ps_sop_creator