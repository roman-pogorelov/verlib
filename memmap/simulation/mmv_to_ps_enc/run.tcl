vlog -reportprogress 300 -work work ../../mmv_to_ps_enc.sv
vopt work.mmv_to_ps_enc +acc -o mmv_to_ps_enc_opt
vsim -fsmdebug work.mmv_to_ps_enc_opt
do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force s_addr 0
force s_wreq 0
force s_wdat 0
force s_rreq 0

force i_dat 0
force i_val 0
force i_eop 0
force o_rdy 1

run 30001ps