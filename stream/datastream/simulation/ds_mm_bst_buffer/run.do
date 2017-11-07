vlog -reportprogress 300 -work work ../../ds_mmb_buffer.sv
vlog -reportprogress 300 -work work avl_vlb_memory_model.sv
vlog -reportprogress 300 -work work ds_mmb_buffer_tb.sv
vopt work.ds_mmb_buffer_tb +acc -o ds_mmb_buffer_tb_opt -L altera_mf_ver
vsim work.ds_mmb_buffer_tb_opt

do wave.do

run 30001ps