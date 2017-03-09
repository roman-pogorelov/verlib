vlog -reportprogress 300 ../../add_tree.sv
vopt work.add_tree +acc -o add_tree_opt
vsim work.add_tree_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force clkena 1

force i_signed 1'bx

change {i_data[0]} 'hx
change {i_data[1]} 'hx
change {i_data[2]} 'hx
change {i_data[3]} 'hx
change {i_data[4]} 'hx

run 30001ps

