vlog -work work ../../liic_ll_resetter.sv
vopt work.liic_ll_resetter +acc -o liic_ll_resetter_opt
vsim -fsmdebug work.liic_ll_resetter_opt

do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force ll_linkup 0

run 30001ps