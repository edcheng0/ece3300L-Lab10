## Constraints for morse_top on Nexys A7-100T / Nexys 4 DDR.
## Copy-checked from memory of Digilent's master XDC - compare with your board's file if Vivado complains.

set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports CLK100MHZ]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK100MHZ]

set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports CPU_RESETN]   ;# red reset button (active low)
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports BTNC]         ;# center button = Morse key "b"

## Seven-segment display (active low)
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]     ;# CA
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]     ;# CB
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]     ;# CC
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]     ;# CD
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]     ;# CE
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]     ;# CF
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]     ;# CG
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports dp]           ;# DP

set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports {an[3]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {an[4]}]
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports {an[5]}]
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports {an[6]}]
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports {an[7]}]

## LEDs: LED0 = dot, LED1 = dash, LED2 = lg, LED3 = wg
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports {LED[0]}]
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports {LED[1]}]
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports {LED[2]}]
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports {LED[3]}]
