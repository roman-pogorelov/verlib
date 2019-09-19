vlog -work work ../../mmv_protector.sv
vopt work.mmv_protector +acc -o mmv_protector_opt -L altera_mf_ver
vsim work.mmv_protector_opt
do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns
force s_addr 0
force s_wreq 0
force s_wdat 0
force s_rreq 0
force m_rdat 0
force m_rval 0
force m_busy 1

run 30001ps