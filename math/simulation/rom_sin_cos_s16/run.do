vlog -work work ../../rom_sin_cos_s16.sv
vopt work.rom_sin_cos_s16 +acc -o rom_sin_cos_s16_opt
vsim work.rom_sin_cos_s16_opt