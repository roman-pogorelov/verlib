vlog -reportprogress 300 -work work ../../fixed_rounder.sv
vlog -reportprogress 300 -work work ../../float_rounder.sv
vlog -reportprogress 300 -work work float_rounder_tb.sv
vopt work.float_rounder_tb +acc -o float_rounder_tb_opt
vsim work.float_rounder_tb_opt
do wave.do
run 30001ps
