onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /serialreceiver_tb/clock
add wave -noupdate /serialreceiver_tb/reset
add wave -noupdate -divider Tester
add wave -noupdate /serialreceiver_tb/U_1/rs232OmitByte
add wave -noupdate /serialreceiver_tb/U_1/busCRC
add wave -noupdate /serialreceiver_tb/U_1/rs232Command
add wave -noupdate /serialreceiver_tb/U_1/rs232RxByte
add wave -noupdate -divider Rx
add wave -noupdate /serialreceiver_tb/RxD
add wave -noupdate /serialreceiver_tb/U_0/dataValid
add wave -noupdate /serialreceiver_tb/U_0/dataOut
add wave -noupdate -divider CRC
add wave -noupdate /serialreceiver_tb/U_0/U_0/resetCRC
add wave -noupdate /serialreceiver_tb/U_0/U_0/CRC
add wave -noupdate /serialreceiver_tb/U_0/U_0/crc_done
add wave -noupdate -divider {Frame Controller}
add wave -noupdate /serialreceiver_tb/U_0/U_5/state
add wave -noupdate /serialreceiver_tb/U_0/U_5/calc_CRC
add wave -noupdate /serialreceiver_tb/U_0/U_5/watchdogRunning
add wave -noupdate /serialreceiver_tb/U_0/U_5/watchdogCnt
add wave -noupdate /serialreceiver_tb/U_0/U_5/watchdogError
add wave -noupdate /serialreceiver_tb/U_0/U_5/watchdogTarget
add wave -noupdate /serialreceiver_tb/U_0/U_5/flushFrame
add wave -noupdate /serialreceiver_tb/U_0/U_5/resetCRC
add wave -noupdate /serialreceiver_tb/U_0/U_5/registerFrame
add wave -noupdate -divider {Frame composer}
add wave -noupdate /serialreceiver_tb/U_0/U_3/flush
add wave -noupdate /serialreceiver_tb/U_0/frame
add wave -noupdate /serialreceiver_tb/U_0/frameValid
add wave -noupdate -divider Output
add wave -noupdate /serialreceiver_tb/U_0/newData
add wave -noupdate /serialreceiver_tb/U_0/address
add wave -noupdate /serialreceiver_tb/U_0/data
add wave -noupdate /serialreceiver_tb/U_0/badCRC
add wave -noupdate /serialreceiver_tb/U_0/watchdogError
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6118279 ps} 0}
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
WaveRestoreZoom {0 ps} {3520190993 ps}
