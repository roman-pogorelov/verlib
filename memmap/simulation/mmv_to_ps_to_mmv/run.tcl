vlog -reportprogress 300 -work work ../../mmv_to_ps_enc.sv
vlog -reportprogress 300 -work work ../../mmv_from_ps_dec.sv
vlog -reportprogress 300 -work work mmv_to_ps_to_mmv_tb.sv
vopt work.mmv_to_ps_to_mmv_tb +acc -o mmv_to_ps_to_mmv_tb_opt -L altera_mf_ver
vsim -fsmdebug work.mmv_to_ps_to_mmv_tb_opt
do wave.do
run 30001ps