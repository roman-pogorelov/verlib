vlog -work work liic_links_connection_tb.sv
vlog -work work ../../liic_dn_link.sv
vlog -work work ../../liic_up_link.sv
vlog -work work ../../liic_ll_adapter.sv
vlog -work work ../../liic_ll_resetter.sv
vlog -work work ../../liic_csr.sv
vopt work.liic_links_connection_tb +acc -o liic_links_connection_tb_opt -L altera_mf_ver
vsim work.liic_links_connection_tb_opt
do wave.do
run 30001ps
