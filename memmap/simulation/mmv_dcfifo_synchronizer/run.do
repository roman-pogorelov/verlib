vlog -work work ../../mmv_dcfifo_synchronizer.sv
vopt work.mmv_dcfifo_synchronizer +acc -o mmv_dcfifo_synchronizer_opt -L altera_mf_ver
vsim work.mmv_dcfifo_synchronizer_opt

do wave.do

force s_reset 1 0ns, 0 10ns
force s_clk 1 0ns, 0 5ns -r 10ns

force s_addr 0
force s_wreq 0
force s_wdat 0
force s_rreq 0

force m_reset 1 0ns, 0 20ns
force m_clk 1 0ns, 0 10ns -r 20ns

force m_rdat 0
force m_rval 0
force m_busy 1

run 30001ps