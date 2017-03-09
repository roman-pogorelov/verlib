vlog -work work ../../iterated_signed_divider.sv
vlog -work work iterated_signed_divider_tb.sv
vopt work.iterated_signed_divider_tb +acc -o iterated_signed_divider_tb_opt
vsim -fsmdebug work.iterated_signed_divider_tb_opt

do wave.do

run 30001ps
