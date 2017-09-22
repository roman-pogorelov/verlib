vlog -work work ../../alt_rom_sin_cos.sv
vlog -work work alt_rom_sin_cos_tb.sv
vsim work.alt_rom_sin_cos_tb -L altera_mf_ver

do wave.do

run 1000000ns
