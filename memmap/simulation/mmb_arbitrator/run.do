vlog -work work ../../mmb_arbitrator.sv
vlog -work work ../../mmb_reg_buffer.sv
vlog -work work ./mmb_arbitrator_tb.sv
vsim work.mmb_arbitrator_tb -L altera_mf_ver
do wave.do
run 30001ps
