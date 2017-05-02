vlog -reportprogress 300 -work work ../../handshake_synchronizer.sv
vopt work.handshake_synchronizer +acc -o handshake_synchronizer_opt
vsim work.handshake_synchronizer_opt

do wave.do

force src_reset 1 0ns, 0 15ns
force src_clk 1 0ns, 0 5ns -r 10ns
force dst_reset 1 0ns, 0 30ns
force dst_clk 1 0ns, 0 10ns -r 20ns
force src_req 0
force dst_rdy 1

run 30001ps