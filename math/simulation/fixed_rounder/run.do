vlog -reportprogress 300 -work work ../../fixed_rounder.sv
vlog -reportprogress 300 -work work fixed_rounder_tb.sv
vopt work.fixed_rounder_tb +acc -o fixed_rounder_tb_opt
vsim work.fixed_rounder_tb_opt

do wave.do

run 30001ps
