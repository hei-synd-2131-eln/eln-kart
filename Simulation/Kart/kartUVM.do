onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gray70 /kartcontroller_full_tb/clock
add wave -noupdate -color Gray70 /kartcontroller_full_tb/reset
add wave -noupdate /kartcontroller_full_tb/I_tester/I_transReader/target
add wave -noupdate /kartcontroller_full_tb/I_tester/I_transReader/info
add wave -noupdate -expand -group Transactions -color {Medium Aquamarine} /kartcontroller_full_tb/I_tester/transactionIn
add wave -noupdate -expand -group Transactions -color {Medium Aquamarine} -radix hexadecimal -childformat {{/kartcontroller_full_tb/I_tester/uartTransaction(11) -radix hexadecimal}} -subitemconfig {/kartcontroller_full_tb/I_tester/uartTransaction(1) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(2) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(3) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(4) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(5) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(6) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(7) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(8) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(9) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(10) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(11) {-color {Medium Aquamarine} -height 15 -radix hexadecimal} /kartcontroller_full_tb/I_tester/uartTransaction(12) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(13) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(14) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(15) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(16) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(17) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(18) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(19) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(20) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(21) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(22) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(23) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(24) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(25) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(26) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(27) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(28) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(29) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(30) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(31) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(32) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(33) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(34) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(35) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(36) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(37) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(38) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(39) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(40) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(41) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(42) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(43) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(44) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(45) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(46) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(47) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(48) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(49) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(50) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(51) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(52) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(53) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(54) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(55) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(56) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(57) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(58) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(59) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(60) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(61) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(62) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(63) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(64) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(65) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(66) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(67) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(68) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(69) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(70) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(71) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(72) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(73) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(74) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(75) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(76) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(77) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(78) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(79) {-color {Medium Aquamarine} -height 15} /kartcontroller_full_tb/I_tester/uartTransaction(80) {-color {Medium Aquamarine} -height 15}} /kartcontroller_full_tb/I_tester/uartTransaction
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider Router
add wave -noupdate /kartcontroller_full_tb/I_Kart/U_txRouter/dcMotorSendRequest
add wave -noupdate /kartcontroller_full_tb/I_Kart/U_txRouter/sensorsSendRequest
add wave -noupdate /kartcontroller_full_tb/I_Kart/U_txRouter/stepperSendRequest
add wave -noupdate /kartcontroller_full_tb/I_Kart/I_stepperController/stepperDataToSend
add wave -noupdate /kartcontroller_full_tb/I_Kart/I_stepperController/stepperAddressToSend
add wave -noupdate -group Tx /kartcontroller_full_tb/I_Kart/U_txRouter/data
add wave -noupdate -group Tx /kartcontroller_full_tb/I_Kart/U_txRouter/address
add wave -noupdate -group Tx -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/I_uartController/TxD
add wave -noupdate -expand -group Rx -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/badCRC
add wave -noupdate -expand -group Rx -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/watchdogError
add wave -noupdate -expand -group Rx /kartcontroller_full_tb/I_Kart/addressIn
add wave -noupdate -expand -group Rx /kartcontroller_full_tb/I_Kart/dataIn
add wave -noupdate -expand -group Rx -color Gold /kartcontroller_full_tb/I_Kart/I_uartController/RxD
add wave -noupdate -group Frame /kartcontroller_full_tb/I_Kart/I_uartController/I_receiver/flushFrame
add wave -noupdate -group Frame /kartcontroller_full_tb/I_Kart/I_uartController/I_receiver/resetCRC
add wave -noupdate -group Frame /kartcontroller_full_tb/I_Kart/I_uartController/I_receiver/crc_done
add wave -noupdate -group Frame /kartcontroller_full_tb/I_Kart/I_uartController/I_receiver/CRC
add wave -noupdate -group Frame /kartcontroller_full_tb/I_Kart/I_uartController/I_receiver/frameValid
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider Modules
add wave -noupdate -group DC /kartcontroller_full_tb/I_Kart/I_dcMotorController/I_regs/bankData
add wave -noupdate -group DC -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/pwm
add wave -noupdate -group DC -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/forwards
add wave -noupdate -group DC /kartcontroller_full_tb/I_Kart/I_dcMotorController/prescaler
add wave -noupdate -group DC /kartcontroller_full_tb/I_Kart/I_dcMotorController/speed
add wave -noupdate -group Stepper /kartcontroller_full_tb/I_Kart/I_stepperController/I_registers/bankData
add wave -noupdate -group Stepper /kartcontroller_full_tb/I_Kart/I_stepperController/clockDivider
add wave -noupdate -group Stepper /kartcontroller_full_tb/I_Kart/I_stepperController/stepEn
add wave -noupdate -group Stepper -radix decimal /kartcontroller_full_tb/I_Kart/I_stepperController/targetAngle
add wave -noupdate -group Stepper -radix decimal /kartcontroller_full_tb/I_Kart/I_stepperController/actual
add wave -noupdate -group Stepper /kartcontroller_full_tb/I_Kart/I_stepperController/reached
add wave -noupdate -group Stepper /kartcontroller_full_tb/I_Kart/I_stepperController/I_angleControl/I_phases/phaseCounter
add wave -noupdate -group Stepper -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/coil1
add wave -noupdate -group Stepper -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/coil2
add wave -noupdate -group Stepper -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/coil3
add wave -noupdate -group Stepper -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/coil4
add wave -noupdate -group Stepper -color Gold /kartcontroller_full_tb/I_Kart/stepperEnd
add wave -noupdate -group Stepper -color Gold /kartcontroller_full_tb/I_tester/I_stepper/testMode
add wave -noupdate -group Sensors /kartcontroller_full_tb/I_Kart/I_sensorsController/I_regs/bankData
add wave -noupdate -group Sensors -color Gold /kartcontroller_full_tb/testMode
add wave -noupdate -group Sensors -color Gold /kartcontroller_full_tb/I_Kart/endSwitches
add wave -noupdate -group Sensors -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/leds
add wave -noupdate -group Sensors -group Hall /kartcontroller_full_tb/I_Kart/I_sensorsController/I_regs/U_2/pulse250us
add wave -noupdate -group Sensors -group Hall /kartcontroller_full_tb/I_Kart/I_sensorsController/zeroPos
add wave -noupdate -group Sensors -group Hall /kartcontroller_full_tb/I_Kart/I_sensorsController/I_regs/hallReg
add wave -noupdate -group Sensors -group Hall /kartcontroller_full_tb/I_Kart/I_sensorsController/I_regs/U_2/sendHall
add wave -noupdate -group Sensors -group Hall -color Gold /kartcontroller_full_tb/I_Kart/hallPulses
add wave -noupdate -group Sensors -group Hall /kartcontroller_full_tb/I_Kart/I_sensorsController/hallCount
add wave -noupdate -group Sensors -group Ranger -color {Medium Orchid} /kartcontroller_full_tb/I_Kart/distanceStart
add wave -noupdate -group Sensors -group Ranger -color Gold /kartcontroller_full_tb/I_Kart/distancePulse
add wave -noupdate -group Sensors -group Ranger /kartcontroller_full_tb/I_Kart/I_sensorsController/rangerDistance
add wave -noupdate -group Sensors -group Ranger /kartcontroller_full_tb/I_Kart/I_sensorsController/I_range/rangerState
add wave -noupdate -group Sensors -group Battery /kartcontroller_full_tb/I_tester/batterySClOut
add wave -noupdate -group Sensors -group Battery -color Gold /kartcontroller_full_tb/I_tester/batterySDaIn
add wave -noupdate -group Sensors -group Battery /kartcontroller_full_tb/I_tester/I_sensors/batt_reader/conf_reg
add wave -noupdate -group Sensors -group Battery /kartcontroller_full_tb/I_tester/I_sensors/batteryChipAddrIn
add wave -noupdate -group Sensors -group Battery /kartcontroller_full_tb/I_tester/I_sensors/batteryChipIsSel
add wave -noupdate -group Sensors -group Battery /kartcontroller_full_tb/I_tester/I_sensors/batteryRegister
add wave -noupdate -group Sensors -group Battery /kartcontroller_full_tb/I_tester/I_sensors/batteryWriteIn
add wave -noupdate -group Sensors -group Battery /kartcontroller_full_tb/I_Kart/I_sensorsController/battery250uv
add wave -noupdate -group Sensors -group Battery /kartcontroller_full_tb/I_Kart/I_sensorsController/current250uA
add wave -noupdate -group CReg /kartcontroller_full_tb/I_Kart/hwOrientation
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {141892023181 ps} 0} {{Cursor 3} {181885691926 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 527
configure wave -valuecolwidth 120
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
WaveRestoreZoom {141446621886 ps} {144134388322 ps}
run 500 ms
