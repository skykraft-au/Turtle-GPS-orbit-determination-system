# Overview
The Turtle GPS is an open-source, cost-effective, low-power, and low-weight solution to orbit determination. The device resolves the issues faced by standard tracking methods such as radar while democratising space by making tracking cooperative and community-based. The device satisfies CoCom regulations by being post-processed and non-continuous; instead, it beacons GPS data over LoRa packets at specified intervals.

The device is highly configurable through the FPGA Verilog code; see the configuration section below for more information.

Further development on the device is needed; the community is welcome to contribute to this. Information on directions for this development can be found in the Todo section below.

## Note regarding Turtle GPS v2.0
Note that the Turtle GPS v2.0 does not work by default, as there are issues regarding the flash and power supply components on the board; these issues are resolved in version 2.1. If you wish to use version 2.0, you will need to resolve these issues. The key issues and solutions are as follows:
- There are missing pull-up resistors on pins 1, 3, and 7 of the Flash memory; these should be 10 kΩ.
- The pull-up resistors on the M0, M1, and M2 pins on the underside of the FPGA are 10 kΩ, but they should be 1 kΩ to initiate the correct startup configuration.
- A few issues exist in the lower half of the power supply, including incorrect placement of the boost converter, sensitive output of the first 3.3 V LDO, and insufficient current rating in both the diode and boost converter. To resolve this, I recommend bypassing this section by powering the board with 3.3 V through test point 3.
- The done indicator pin from the FPGA should be a pull-up and not a pull-down.

# Todo
- GPS v2.1: Resolve issues with v2.0, update FPGA clock to an LVCMOS TCXO, tune LoRa RF path to between 401 MHz and 403 MHz.
- Update code to default the LoRa frequency to 401 MHz to 403 MHz and cascade the FIR to allow for a sharper cutoff to be attained with the limited FPGA resources.
- Program LoRa receiving capabilities into the FPGA to allow for remote shutdown with a unique user-defined code.
- Optimise size, weight, and performance of the device
- Test in orbit
- Set up a public website for uploading and processing of data
- Add satellite ID code generator and logger to the website

# Configuration of the Device
By default, the packets transmitted over LoRa are 512 bits wide and include a unique, user-defined satellite ID Code, packet index, user-defined bits, and the actual data.
| Number of Bits | Bit Locations | Purpose |
| -------------- | ------------- | ------- |
| 24 | \[512:489\] | Satellite ID Code |
| 12 | \[488:477\] | Packet Index |
| 28 | \[476:449\] | User-defined bits |
| 448 | \[448:0\] | GPS IQ Data |

The user-defined bits can be configured by changing the value of the respective register in the Verilog code. The configuration of the MAX2771 GNSS Receiver and the LoRa SX1276 can be changed by adjusting the values of their respective configuration registers in the MAX_Driver and LORA_Driver Verilog modules, respectively.

The total transmission size, as well as the sample size and whether samples are continuous or not, can all be configured through the value of the GPS_Config register in the GPS_Top Verilog module. Comments are included in the code to assist users with this.

# Licensing

This repository contains material under multiple licenses.

## Hardware

The hardware design files are licensed under CERN-OHL-P v2.

This includes:
- GPS v2.0/KiCad PCB/

## HDL and Software

The HDL and software source code are licensed under the MIT License.

This includes:
- GPS v2.0/Software and HDL/

## Documentation

Documentation, diagrams, and images are licensed under
Creative Commons Attribution 4.0 International (CC BY 4.0).

This includes:
- GPS v2.0/BoM/

A copy of each license is available in the licenses/ directory.
