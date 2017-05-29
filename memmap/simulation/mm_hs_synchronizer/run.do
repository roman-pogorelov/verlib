vlog -reportprogress 300 -work work ../../mm_hs_synchronizer.sv 
vopt work.mm_hs_synchronizer +acc -o mm_hs_synchronizer_opt
vsim work.mm_hs_synchronizer_opt

do wave.do

force s_reset 1 0ns, 0 15ns
force s_clk 1 0ns, 0 5ns -r 10ns

force s_addr 0
force s_wreq 0
force s_wdat 0
force s_rreq 0

force m_reset 1 0ns, 0 9ns
force m_clk 1 0ns, 0 3ns -r 6ns

force m_rdat 0
force m_busy 1

run 30001ps
