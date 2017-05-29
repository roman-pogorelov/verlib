vlog -reportprogress 300 -work work ../../ps_fragmenter_packer.sv
vlog -reportprogress 300 -work work ../../ps_defragmenter_unpacker.sv
vlog -reportprogress 300 -work work ps_packer_unpacker_tb.sv
vopt work.ps_packer_unpacker_tb +acc -o ps_packer_unpacker_tb_opt -L altera_mf_ver
vsim -fsmdebug work.ps_packer_unpacker_tb_opt

do wave.do

run 30001ps

