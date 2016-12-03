vlog -work work ../../onehot2binary.sv
vopt work.onehot2binary +acc -o onehot2binary_opt
vsim work.onehot2binary_opt

do wave.do

force onehot 0

run 30001ps