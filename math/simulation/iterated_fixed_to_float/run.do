vlog -reportprogress 300 -work work ../../iterated_fixed_to_float.sv
vlog -reportprogress 300 -work work iterated_fixed_to_float_tb.sv
vopt work.iterated_fixed_to_float_tb +acc -o iterated_fixed_to_float_tb_opt

vsim work.iterated_fixed_to_float_tb_opt

do wave.do

run 30001ps
