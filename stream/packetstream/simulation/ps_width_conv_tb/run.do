vlog -work work ps_width_conv_tb.sv
vopt work.ps_width_conv_tb +acc -o ps_width_conv_tb_opt
vsim work.ps_width_conv_tb_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

run 30001ps
