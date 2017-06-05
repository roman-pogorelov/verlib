vlog -reportprogress 300 -work work ../../ps_mm_bst_buffer.sv
vlog -reportprogress 300 -work work ps_mm_bst_buffer_tb.sv
vopt work.ps_mm_bst_buffer_tb +acc -o ps_mm_bst_buffer_tb_opt -L altera_mf_ver
vsim -fsmdebug work.ps_mm_bst_buffer_tb_opt
do wave.do
run 30001ps
