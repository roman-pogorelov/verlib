vlog -work work ps_head_pass_tb.sv
vopt work.ps_head_pass_tb +acc -o ps_head_pass_tb_opt
vsim work.ps_head_pass_tb_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

run 30001ps
