vlog -reportprogress 300 -work work ../../ps_mmb_buffer.sv
vlog -reportprogress 300 -work work ps_mmb_buffer_tb.sv
vopt work.ps_mmb_buffer_tb +acc -o ps_mmb_buffer_tb_opt -L altera_mf_ver
vsim -fsmdebug work.ps_mmb_buffer_tb_opt
do wave.do
run 30001ps
