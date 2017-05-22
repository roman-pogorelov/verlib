vlog -reportprogress 300 -work work ../../pipelined_fixed_isqrt.sv
vopt work.pipelined_fixed_isqrt +acc -o pipelined_fixed_isqrt_opt
vsim work.pipelined_fixed_isqrt_opt
#vopt work.pipelined_fixed_isqrt__approximator +acc -o pipelined_fixed_isqrt__approximator_opt
#vsim work.pipelined_fixed_isqrt__approximator_opt
#vopt work.pipelined_fixed_isqrt__scaler +acc -o pipelined_fixed_isqrt__scaler_opt
#vsim work.pipelined_fixed_isqrt__scaler_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns
force clkena 1
force radical 'h0001

run 30001ps