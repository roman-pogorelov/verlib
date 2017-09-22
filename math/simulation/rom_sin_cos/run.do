vlog -work work ../../rom_sin_cos.sv
vlog -work work rom_sin_cos_tb.sv
vopt work.rom_sin_cos_tb +acc -o rom_sin_cos_tb_opt
vsim work.rom_sin_cos_tb_opt

do wave.do
run 30001ps