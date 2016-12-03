vlog -work work ../../ds2ps_doser.sv
vopt work.ds2ps_doser +acc -o ds2ps_doser_opt
vsim -fsmdebug work.ds2ps_doser_opt

do wave.do
force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force ctrl_amount 'd12
force ctrl_run 0
force ctrl_abort 0

force i_dat 0
force i_val 0
force o_rdy 0

run 30001ps
