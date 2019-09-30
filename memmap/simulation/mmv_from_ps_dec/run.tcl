vlog -reportprogress 300 -work work ../../mmv_from_ps_dec.sv
vopt work.mmv_from_ps_dec +acc -o mmv_from_ps_dec_opt -L altera_mf_ver
vsim -fsmdebug work.mmv_from_ps_dec_opt
do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force m_rdat 0
force m_rval 0
force m_busy 1

force i_dat 0
force i_val 0
force i_eop 0
force o_rdy 1

run 30001ps