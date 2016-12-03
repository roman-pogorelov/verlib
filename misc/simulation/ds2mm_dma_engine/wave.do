onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ds2mm_dma_engine/MAWIDTH
add wave -noupdate -radix unsigned /ds2mm_dma_engine/SDWIDTH
add wave -noupdate -radix unsigned /ds2mm_dma_engine/FACTOR
add wave -noupdate -radix unsigned /ds2mm_dma_engine/MDWIDTH
add wave -noupdate -radix unsigned /ds2mm_dma_engine/MBYTES
add wave -noupdate -radix unsigned /ds2mm_dma_engine/CSWIDTH
add wave -noupdate -radix unsigned /ds2mm_dma_engine/ADDR_EXTRA_BITS
add wave -noupdate -divider <NULL>
add wave -noupdate /ds2mm_dma_engine/reset
add wave -noupdate /ds2mm_dma_engine/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Cadet Blue} -radix hexadecimal /ds2mm_dma_engine/csr_address
add wave -noupdate -color {Cadet Blue} /ds2mm_dma_engine/csr_write
add wave -noupdate -color {Cadet Blue} -radix hexadecimal /ds2mm_dma_engine/csr_writedata
add wave -noupdate -color {Cadet Blue} /ds2mm_dma_engine/csr_read
add wave -noupdate -color {Cadet Blue} -radix hexadecimal /ds2mm_dma_engine/csr_readdata
add wave -noupdate -divider <NULL>
add wave -noupdate -color Salmon -radix hexadecimal /ds2mm_dma_engine/i_dat
add wave -noupdate -color Salmon /ds2mm_dma_engine/i_val
add wave -noupdate -color Salmon /ds2mm_dma_engine/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /ds2mm_dma_engine/wr_address
add wave -noupdate -color {Dark Orchid} -radix hexadecimal -childformat {{{/ds2mm_dma_engine/wr_byteenable[1]} -radix hexadecimal} {{/ds2mm_dma_engine/wr_byteenable[0]} -radix hexadecimal}} -subitemconfig {{/ds2mm_dma_engine/wr_byteenable[1]} {-color {Dark Orchid} -height 15 -radix hexadecimal} {/ds2mm_dma_engine/wr_byteenable[0]} {-color {Dark Orchid} -height 15 -radix hexadecimal}} /ds2mm_dma_engine/wr_byteenable
add wave -noupdate -color {Dark Orchid} /ds2mm_dma_engine/wr_write
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /ds2mm_dma_engine/wr_writedata
add wave -noupdate -color {Dark Orchid} /ds2mm_dma_engine/wr_waitrequest
add wave -noupdate -divider <NULL>
add wave -noupdate /ds2mm_dma_engine/irq
add wave -noupdate -divider <NULL>
add wave -noupdate -color Goldenrod -radix hexadecimal /ds2mm_dma_engine/addr_reg
add wave -noupdate -color Goldenrod -radix hexadecimal /ds2mm_dma_engine/dma_amount_reg
add wave -noupdate -color Goldenrod -radix hexadecimal /ds2mm_dma_engine/dma_left
add wave -noupdate -color Goldenrod -radix hexadecimal /ds2mm_dma_engine/time_reg
add wave -noupdate -color Goldenrod -radix hexadecimal /ds2mm_dma_engine/time_left
add wave -noupdate -color Goldenrod -radix hexadecimal /ds2mm_dma_engine/common_stat
add wave -noupdate -color Goldenrod -radix hexadecimal /ds2mm_dma_engine/irq_ena_stat
add wave -noupdate -color Goldenrod -radix hexadecimal /ds2mm_dma_engine/irq_stat
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ds2mm_dma_engine/addr_cnt
add wave -noupdate /ds2mm_dma_engine/dma_start_reg
add wave -noupdate /ds2mm_dma_engine/dma_stop_reg
add wave -noupdate /ds2mm_dma_engine/dma_busy
add wave -noupdate /ds2mm_dma_engine/dma_done
add wave -noupdate /ds2mm_dma_engine/time_start_reg
add wave -noupdate /ds2mm_dma_engine/time_stop_reg
add wave -noupdate /ds2mm_dma_engine/time_busy
add wave -noupdate /ds2mm_dma_engine/time_done
add wave -noupdate /ds2mm_dma_engine/irq_ena_reg
add wave -noupdate /ds2mm_dma_engine/irq_reg
add wave -noupdate -radix hexadecimal /ds2mm_dma_engine/from_doser_dat
add wave -noupdate /ds2mm_dma_engine/from_doser_val
add wave -noupdate /ds2mm_dma_engine/from_doser_eop
add wave -noupdate /ds2mm_dma_engine/from_doser_rdy
add wave -noupdate -radix hexadecimal /ds2mm_dma_engine/from_expan_dat
add wave -noupdate /ds2mm_dma_engine/from_expan_val
add wave -noupdate /ds2mm_dma_engine/from_expan_eop
add wave -noupdate /ds2mm_dma_engine/from_expan_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {105 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {30 ns} {234 ns}
