vlog -work work ../../alt_rom_sin_two_arg.sv
vlog -work work alt_rom_sin_two_arg_tb.sv
vopt work.alt_rom_sin_two_arg_tb +acc -o alt_rom_sin_two_arg_tb_opt -L altera_mf_ver
vsim work.alt_rom_sin_two_arg_tb_opt

do wave.do

run 1000000ns
