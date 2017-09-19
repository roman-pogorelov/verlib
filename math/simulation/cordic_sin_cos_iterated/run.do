vlog -work work ../../cordic_core.sv
vlog -work work +incdir+../.. ../../cordic_sin_cos_iterated.sv
vopt work.cordic_sin_cos_iterated +acc -o cordic_sin_cos_iterated_opt
vsim work.cordic_sin_cos_iterated_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force start 0
force arg 'h4000

run 30001ps