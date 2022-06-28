onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /txfifo_tb/clock
add wave -noupdate /txfifo_tb/reset
add wave -noupdate -divider Tester
add wave -noupdate /txfifo_tb/load
add wave -noupdate /txfifo_tb/data
add wave -noupdate /txfifo_tb/address
add wave -noupdate -divider FIFO
add wave -noupdate /txfifo_tb/full
add wave -noupdate /txfifo_tb/empty
add wave -noupdate /txfifo_tb/read
add wave -noupdate /txfifo_tb/U_2/address
add wave -noupdate /txfifo_tb/U_2/data
add wave -noupdate -divider Tx
add wave -noupdate /txfifo_tb/U_2/busySending
add wave -noupdate /txfifo_tb/U_2/TxD
add wave -noupdate -divider Output
add wave -noupdate /txfifo_tb/U_1/rs232RxByte
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate /txfifo_tb/U_1/testInfo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7522768311 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 280
configure wave -valuecolwidth 218
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {3429946335 ps} {9854563144 ps}
