# Konfekt Computer

Konfekt is an FPGA computer designed by Lone Dynamics Corporation.

![Konfekt Computer](https://github.com/machdyne/konfekt/blob/20e7b2df0abfc4bb9a4910a4b1d3275f0849353b/konfekt.png)

This repo contains schematics, PCB layouts, pinouts, a 3D-printable case, example gateware and documentation.

Find more information on the [Konfekt product page](https://machdyne.com/product/konfekt-computer/).

## Programming Konfekt

Konfekt has a JTAG interface and ships with a [DFU bootloader](https://github.com/machdyne/tinydfu-bootloader) that allows the included flash [MMOD](https://machdyne.com/product/mmod) to be programmed over the USB-C port.

### DFU

The DFU bootloader is available for 5 seconds after power-on, issuing a DFU command during this period will stop the boot process until the DFU device is detached. If no command is received the boot process will continue and the user gateware will be loaded.

Install [dfu-util](http://dfu-util.sourceforge.net) (Debian/Ubuntu):

```
$ sudo apt install dfu-util
```

Update the user gateware on the flash MMOD:

```
$ sudo dfu-util -a 0 -D image.bit
```

Detach the DFU device and continue the boot process:

```
$ sudo dfu-util -a 0 -e
```

It is possible to update the bootloader itself using DFU but you shouldn't attempt this unless you have a JTAG programmer (or another method to program the MMOD) available, in case you need to restore the bootloader.

### JTAG

These examples assume you're using a "USB Blaster" JTAG cable, see the header pinout below. You will need to have [openFPGALoader](https://github.com/trabucayre/openFPGALoader) installed.

Program the configuration SRAM:

```
openFPGALoader -c usb-blaster image.bit
```

Program the flash MMOD:

```
openFPGALoader -f -c usb-blaster images/bootloader/tinydfu_konfekt.bit
```

## Blinky 

Building the blinky example requires [Yosys](https://github.com/YosysHQ/yosys), [nextpnr-ecp5](https://github.com/YosysHQ/nextpnr) and [Project Trellis](https://github.com/YosysHQ/prjtrellis).

Assuming they are installed, you can simply type `make` to build the gateware, which will be written to output/blinky.bin. You can then use [openFPGALoader](https://github.com/trabucayre/openFPGALoader) or dfu-util to write the gateware to the device.

## Linux

See the [Kakao Linux](https://github.com/machdyne/kakao) repo for the latest instructions.

### Prebuilt Images

Copy the files from the `images/linux` directory to the root directory of a FAT-formatted MicroSD card.

Konfekt ships with LiteX gateware on the user gateware section of the MMOD that is compatible with these images. After several seconds the Linux penguin should appear on the screen (HDMI) followed by a login prompt.

### Building Linux

Please follow the setup instructions in the [linux-on-litex-vexriscv](https://github.com/litex-hub/linux-on-litex-vexriscv) repo and then:

1. Build the Linux-capable gateware:

```
$ cd linux-on-litex-vexriscv
$ ./make.py --board konfekt --uart-baudrate 115200 --dcache-size 128 --icache-size 128 --build

$ ls build/konfekt
```

2. Write the gateware to the MMOD using USB DFU:

```
$ sudo dfu-util -a 0 -D build/konfekt/gateware/konfekt.bit
```

3. Copy the device tree binary `build/konfekt/konfekt.dtb` to a FAT-formatted MicroSD card.

4. Build the Linux kernel and root filesystem:

```
$ cd ..
$ git clone http://github.com/buildroot/buildroot
$ cd buildroot
$ make BR2_EXTERNAL=../linux-on-litex-vexriscv/buildroot/ litex_vexriscv_usbhost_defconfig
```

Optionally customize the kernel and buildroot packages:

```
$ make menuconfig
```

Build the kernel and rootfs:

```
$ make
$ ls output/images
```

5. Copy the `Image` and `rootfs.cpio` files from output/images to the MicroSD card.

6. Copy the OpenSBI binary (included in this repo as `konfekt/images/linux/opensbi.bin`) to the MicroSD card. Alternatively, you can build this binary by following [these instructions](https://github.com/litex-hub/linux-on-litex-vexriscv#-generating-the-opensbi-binary-optional).

7. Copy `konfekt/images/linux/boot.json` to the MicroSD card.

8. Power-cycle Konfekt. After Linux has finished booting you should see a login prompt on the HDMI display.

## LiteX

### Installing LiteX

If you haven't yet installed LiteX please see the [LiteX quick start guide](https://github.com/enjoy-digital/litex#quick-start-guide) for details on installing LiteX.

### Building Custom Gateware

Build the LiteX gateware:

```
$ cd litex-boards/litex_boards/targets
$ ./machdyne_konfekt.py --cpu-type=vexriscv --cpu-variant=lite --sys-clk-freq 40000000 --uart-baudrate 1000000 --uart-name serial --build
```

Program the LiteX gateware to SRAM over JTAG:

```
$ ./machdyne_konfekt.py --cable usb-blaster --load
```

Or program the LiteX gateware to flash over DFU:

```
$ sudo dfu-util -a 0 -D build/machdyne_konfekt/gateware/machdyne_konfekt.bit
```

## JTAG Header

The 3.3V JTAG header can be used to program the FPGA SRAM as well as the MMOD flash memory. It can also be used to provide power (5V) to the board.

```
1 2
3 4
5 6
```

| Pin | Signal |
| --- | ------ |
| 1 | TCK |
| 2 | TDI |
| 3 | TDO |
| 4 | TMS |
| 5 | 5V0 |
| 6 | GND |

## Resources

 * [fpga-dac audio player](https://github.com/machdyne/fpga-dac)

## Board Revisions

| Revision | Notes |
| -------- | ----- |
| V0 | Initial version |

## License

The contents of this repo are released under the [Lone Dynamics Open License](LICENSE.md) with the following exceptions:

- The KiCad design files contain parts of the [kicad-pmod](https://github.com/mithro/kicad-pmod) library which is released under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0.html).

- The KiCad design files may contain symbols and footprints released under other licenses; please contact us if we've failed to give proper attribution.

Note: You can use these designs for commercial purposes but we ask that instead of producing exact clones, that you either replace our trademarks and logos with your own or add your own next to ours.
