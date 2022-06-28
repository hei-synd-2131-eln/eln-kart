onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gray60 -label Clock /stepperMotorController_tb/clock
add wave -noupdate -color Gray60 -label nReset /stepperMotorController_tb/reset
add wave -noupdate -color Turquoise -label Info /stepperMotorController_tb/I_tester/testInfo
add wave -noupdate -divider Kart
add wave -noupdate -color Gold -label testMode /stepperMotorController_tb/testMode
add wave -noupdate -color Gold -label stepperEnd /stepperMotorController_tb/stepperEnd
add wave -noupdate -color Gold -label {hwControl - Clockwise} /stepperMotorController_tb/I_tester/hwOrientation(1)
add wave -noupdate -color Gold -label {hwcontrol - Sensor left} /stepperMotorController_tb/I_tester/hwOrientation(2)
add wave -noupdate -color Gold -label {hwControl - End switch} /stepperMotorController_tb/hwOrientation(3)
add wave -noupdate -color Gold -label {hwControl - Restart} /stepperMotorController_tb/hwOrientation(4)
add wave -noupdate -divider Coils
add wave -noupdate -color {Blue Violet} -label Coil1 /stepperMotorController_tb/coil1
add wave -noupdate -color {Blue Violet} -label Coil2 /stepperMotorController_tb/coil2
add wave -noupdate -color {Blue Violet} -label Coil3 /stepperMotorController_tb/coil3
add wave -noupdate -color {Blue Violet} -label Coil4 /stepperMotorController_tb/coil4
add wave -noupdate -divider Insides
add wave -noupdate /stepperMotorController_tb/I_stepper/targetAngle
add wave -noupdate /stepperMotorController_tb/I_stepper/actual
add wave -noupdate /stepperMotorController_tb/I_stepper/reached
add wave -noupdate /stepperMotorController_tb/I_stepper/stepperEndOr
add wave -noupdate /stepperMotorController_tb/I_stepper/stepEn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1222590000 ps} 0} {{Cursor 2} {50186241 ps} 0} {{Cursor 3} {336503573154 ps} 0} {{Cursor 4} {490085031 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 215
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
configure wave -timelineunits ms
update
WaveRestoreZoom {336441218455 ps} {337050767450 ps}
run 500 ms
