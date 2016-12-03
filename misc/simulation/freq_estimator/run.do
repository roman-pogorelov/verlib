vlog -work work ../../freq_estimator.sv
vopt work.freq_estimator +acc -o freq_estimator_opt
vsim work.freq_estimator_opt

do wave.do

force refclk 1 0ns, 0 5ns -r 10ns
force estclk 1 0ns, 0 2.5ns -r 5ns

run 30001ps
