onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color White /steppermotorregisters_tb/clock
add wave -noupdate -color White /steppermotorregisters_tb/reset
add wave -noupdate /steppermotorregisters_tb/U_1/testInfo
add wave -noupdate -divider Rx
add wave -noupdate -color Yellow -radix binary /steppermotorregisters_tb/addressIn
add wave -noupdate -color Yellow /steppermotorregisters_tb/dataIn
add wave -noupdate -color Yellow /steppermotorregisters_tb/regWr
add wave -noupdate -divider {Tx Manager}
add wave -noupdate -color Cyan -radix binary -childformat {{/steppermotorregisters_tb/stepperAddressToSend(7) -radix binary} {/steppermotorregisters_tb/stepperAddressToSend(6) -radix binary} {/steppermotorregisters_tb/stepperAddressToSend(5) -radix binary} {/steppermotorregisters_tb/stepperAddressToSend(4) -radix binary} {/steppermotorregisters_tb/stepperAddressToSend(3) -radix binary} {/steppermotorregisters_tb/stepperAddressToSend(2) -radix binary} {/steppermotorregisters_tb/stepperAddressToSend(1) -radix binary} {/steppermotorregisters_tb/stepperAddressToSend(0) -radix binary}} -subitemconfig {/steppermotorregisters_tb/stepperAddressToSend(7) {-color Cyan -height 15 -radix binary} /steppermotorregisters_tb/stepperAddressToSend(6) {-color Cyan -height 15 -radix binary} /steppermotorregisters_tb/stepperAddressToSend(5) {-color Cyan -height 15 -radix binary} /steppermotorregisters_tb/stepperAddressToSend(4) {-color Cyan -height 15 -radix binary} /steppermotorregisters_tb/stepperAddressToSend(3) {-color Cyan -height 15 -radix binary} /steppermotorregisters_tb/stepperAddressToSend(2) {-color Cyan -height 15 -radix binary} /steppermotorregisters_tb/stepperAddressToSend(1) {-color Cyan -height 15 -radix binary} /steppermotorregisters_tb/stepperAddressToSend(0) {-color Cyan -height 15 -radix binary}} /steppermotorregisters_tb/stepperAddressToSend
add wave -noupdate -color Cyan /steppermotorregisters_tb/stepperDataToSend
add wave -noupdate /steppermotorregisters_tb/stepperSendRequest
add wave -noupdate -color Yellow /steppermotorregisters_tb/stepperSendAuth
add wave -noupdate -divider {Register Bank}
add wave -noupdate /kart/REG_ADDR_MSB_NB_BITS
add wave -noupdate /kart/REG_ADDR_MAXNBREG_BITS
add wave -noupdate /kart/REG_ADDR_GET_BIT_POSITION
add wave -noupdate /kart/REG_ADDR_MSB_NB_BITS
add wave -noupdate -divider {Register Manager}
add wave -noupdate /steppermotorregisters_tb/U_0/loadRegister
add wave -noupdate /steppermotorregisters_tb/U_0/readRegister
add wave -noupdate -divider Registers
add wave -noupdate -color Cyan /steppermotorregisters_tb/clockDivider
add wave -noupdate -color Cyan /steppermotorregisters_tb/targetAngle
add wave -noupdate -divider Angle
add wave -noupdate /steppermotorregisters_tb/U_0/sendActualAngle
add wave -noupdate -color Yellow /steppermotorregisters_tb/actualAngle
add wave -noupdate -divider Stepper
add wave -noupdate -color Yellow /steppermotorregisters_tb/reached
add wave -noupdate /steppermotorregisters_tb/U_0/sendReached
add wave -noupdate -color Yellow /steppermotorregisters_tb/stepperEnd
add wave -noupdate /steppermotorregisters_tb/U_0/sendStepperEnd
add wave -noupdate /steppermotorregisters_tb/U_0/sendHW
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {34330753 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 338
configure wave -valuecolwidth 190
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
WaveRestoreZoom {23207022 ps} {58557525 ps}
