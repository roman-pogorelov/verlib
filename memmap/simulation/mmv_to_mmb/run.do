vlog -work work ../../mmv_to_mmb.sv
vlog -work work mmv_to_mmb_tb.sv
vopt work.mmv_to_mmb_tb +acc -o mmv_to_mmb_tb_opt -L altera_mf_ver
vsim work.mmv_to_mmb_tb_opt
do wave.do
run 30001ps