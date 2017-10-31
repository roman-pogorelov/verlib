vlog -work work ../../mmv_ram_march_c_tester.sv
vlog -work work ../mmv_slave_model.sv
vlog -work work mmv_ram_march_c_tester_tb.sv
vopt work.mmv_ram_march_c_tester_tb +acc -o mmv_ram_march_c_tester_tb_opt
vsim -fsmdebug work.mmv_ram_march_c_tester_tb_opt

do wave.do

run 15000001ps