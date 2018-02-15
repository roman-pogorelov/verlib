vlog -work work ../../ps_head_separator.sv
vlog -work work ps_head_separator_tb.sv
vopt work.ps_head_separator_tb +acc -o ps_head_separator_tb_opt -L altera_mf_ver
vsim work.ps_head_separator_tb_opt
do wave.do
run 30001ps
