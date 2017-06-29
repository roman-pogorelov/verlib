vlog -reportprogress 300 -work work ../../mmv_arbitrator.sv
vlog -reportprogress 300 -work work ../mmv_master_model.sv
vlog -reportprogress 300 -work work ../mmv_slave_model.sv
vlog -reportprogress 300 -work work mmv_arbitrator_tb.sv
vopt work.mmv_arbitrator_tb +acc -o mmv_arbitrator_tb_opt -L altera_mf_ver
vsim work.mmv_arbitrator_tb_opt

do wave.do

run 30001ps