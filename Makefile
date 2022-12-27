blinky_konfekt:
	mkdir -p output
	yosys -q -p "synth_ecp5 -top blinky -json output/blinky_konfekt.json" rtl/blinky_konfekt.v
	nextpnr-ecp5 --12k --package CABGA256 --lpf konfekt_v0.lpf --json output/blinky_konfekt.json --textcfg output/konfekt_blinky_out.config
	ecppack -v --compress --freq 2.4 output/konfekt_blinky_out.config --bit output/konfekt.bit

prog:
	openFPGALoader -c usb-blaster output/konfekt.bit
