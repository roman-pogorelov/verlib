vlog -work work ../../crc_calculator.sv
vlog -work work ./crc_calculator_tb.sv
vopt work.crc_calculator_tb +acc -o crc_calculator_tb_opt
vsim work.crc_calculator_tb_opt
do wave.do
run 30001ps