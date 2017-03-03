vlog -reportprogress 300 -work work ../../single_pulse_synchronizer.sv
vopt work.single_pulse_synchronizer +acc -o single_pulse_synchronizer_opt
vsim work.single_pulse_synchronizer_opt

do wave.do

force src_reset 1 0ns, 0 15ns
force src_clk 1 0ns, 0 5ns -r 10ns
force dst_reset 1 0ns, 0 30ns
force dst_clk 1 0ns, 0 10ns -r 20ns
force src_pulse 0

run 30001ps
