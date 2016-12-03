vlog -work work ../../ds2mm_dma_engine.sv
vopt work.ds2mm_dma_engine +acc -o ds2mm_dma_engine_opt
vsim -fsmdebug work.ds2mm_dma_engine_opt

do wave.do
force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force csr_address 0
force csr_write 0
force csr_writedata 0
force csr_read 0

force i_dat 0
force i_val 0

force wr_waitrequest 0

run 30001ps
