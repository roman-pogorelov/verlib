vlog -work work ../../mmb_arbitrator.sv
vlog -work work ../../mmb_reg_buffer.sv
vlog -work work ../mmb_master_model.sv
vlog -work work ../mmb_slave_model.sv
vlog -work work ./mmb_arbitrator_tb.sv
vopt work.mmb_arbitrator_tb +acc -o mmb_arbitrator_tb_opt -L altera_mf_ver
vsim work.mmb_arbitrator_tb_opt
do wave.do
run 20001ps
