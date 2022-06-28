onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /serialtransmitter_tb/U_0/clock
add wave -noupdate /serialtransmitter_tb/U_0/reset
add wave -noupdate -divider Tester
add wave -noupdate /serialtransmitter_tb/U_0/address
add wave -noupdate /serialtransmitter_tb/U_0/data
add wave -noupdate /serialtransmitter_tb/U_0/startSending
add wave -noupdate -divider Tx
add wave -noupdate /serialtransmitter_tb/U_1/U_2/p_addr
add wave -noupdate /serialtransmitter_tb/U_1/U_2/p_data
add wave -noupdate /serialtransmitter_tb/U_1/U_2/state
add wave -noupdate /serialtransmitter_tb/U_1/dataOut
add wave -noupdate /serialtransmitter_tb/U_1/send
add wave -noupdate /serialtransmitter_tb/U_1/sendBusy
add wave -noupdate /serialtransmitter_tb/U_1/crc_done
add wave -noupdate /serialtransmitter_tb/U_1/CRC
add wave -noupdate -divider Output
add wave -noupdate /serialtransmitter_tb/U_0/busySending
add wave -noupdate /serialtransmitter_tb/U_0/TxD
add wave -noupdate /serialtransmitter_tb/U_0/rs232RxByte
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {501444469 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 280
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {1933347007 ps}
