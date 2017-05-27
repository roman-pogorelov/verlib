vlog -reportprogress 300 -work work ../../mm_arbitrator.sv
vopt work.mm_arbitrator +acc -o mm_arbitrator_opt
vsim work.mm_arbitrator_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

change {s_addr[0]} 'h01
change {s_addr[1]} 'h02
force  s_wreq 0
change {s_wdat[0]} 'h10
change {s_wdat[1]} 'h20
force  s_rreq 0

force m_rdat 'h66
force m_rdyn 1

run 30001ps
