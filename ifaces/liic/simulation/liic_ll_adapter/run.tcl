vlog -work work ../../liic_ll_adapter.sv
vopt work.liic_ll_adapter +acc -o liic_ll_adapter_opt
vsim work.liic_ll_adapter_opt

do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force ll_linkup 0

force ll_i_dat 0
force ll_i_val 0
force ll_i_sop 0
force ll_i_eop 0

force ll_o_rdy 0

force usr_i_dat 0
force usr_i_val 0
force usr_i_eop 0

force usr_o_rdy 0

run 30001ps
