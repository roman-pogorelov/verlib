onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mm_arbitrator/reset
add wave -noupdate /mm_arbitrator/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mm_arbitrator/s_addr
add wave -noupdate -radix hexadecimal /mm_arbitrator/s_wreq
add wave -noupdate -radix hexadecimal /mm_arbitrator/s_wdat
add wave -noupdate -radix hexadecimal /mm_arbitrator/s_rreq
add wave -noupdate -radix hexadecimal /mm_arbitrator/s_rdat
add wave -noupdate -radix hexadecimal /mm_arbitrator/s_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mm_arbitrator/m_addr
add wave -noupdate /mm_arbitrator/m_wreq
add wave -noupdate -radix hexadecimal /mm_arbitrator/m_wdat
add wave -noupdate /mm_arbitrator/m_rreq
add wave -noupdate -radix hexadecimal /mm_arbitrator/m_rdat
add wave -noupdate /mm_arbitrator/m_busy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19 ns} 0}
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
WaveRestoreZoom {0 ns} {384 ns}
