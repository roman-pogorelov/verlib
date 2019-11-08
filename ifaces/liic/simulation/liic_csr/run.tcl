vlog -work work ../../liic_csr.sv
vopt work.liic_csr +acc -o liic_csr_opt -debugdb
vsim -debugDB work.liic_csr_opt

do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force ll_linkup 0
force ll_hpi_rcvd 0
force ll_hpi_lost 0
force ll_hpo_sent 0
force ll_hpo_lost 0
force ll_lpi_rcvd 0
force ll_lpi_lost 0
force ll_lpo_sent 0
force ll_lpo_lost 0
force mm_busy_timeout 0
force mm_rval_timeout 0
force mm_rval_is_odd 0
force cs_addr 0
force cs_wreq 0
force cs_wdat 0
force cs_rreq 0

run 30001ps
