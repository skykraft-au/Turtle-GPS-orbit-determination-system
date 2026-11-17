# Overview
The Turtle GPS is an open-source, cost-effective, low-power, and low-weight solution to orbit determination. The device resolves the issues faced by standard tracking methods such as radar while democratising space by making tracking cooperative and community-based. The device satisfies CoCom regulations by being post-processed and non-continuous; instead, it beacons GPS data over LoRa packets at specified intervals.

The device is highly configurable through the FPGA Verilog code; see the configuration section below for more information.

Further development on the device is needed; the community is welcome to contribute to this. Information on directions for this development can be found in the Todo section below.

[!WARNING] Turtle GPS v2.0 contains known hardware issues in the flash programming and power supply circuitry which prevent correct operation in the default configuration. These issues are corrected in Turtle GPS v2.1. See GPS v2.0/KNOWN_ISSUES.md for more information. 

# Usage of the Device
## QuickStart Guide for Testing
Once the PCB is fully assembled, the HF MMCX line can be connected to a passive or active GPS antenna. If it is active, in the case of v2.1, the onboard bias tee can power it, otherwise an external bias tee is required. The Turtle GPS should be connected to a 3.3 V power supply, either a small solar panel, a benchtop power supply, or a Lithium-Ion battery. The output can either be connected to an antenna which transmits to a LoRa receiver or directly connected to the receiver with a coaxial cable and a 3 dB attenuator. The LoRa receiver could be setup with a module like the SX1278 RA-02, connected to a microcontroller configured to receive the data packets.

If the Flash has not been programmed, the JTAG header should be connected to a computer over a digilent JTAG-HS3 programming cable or similar. Then, Vivado should be used to compile a bitstream in the relevant project found in this repository. A memory config file using QSPI should be created in Vivado, from this bitstream before being used to write the Flash memory over the JTAG, again with Vivado.

Once programmed, upon being powered the Turtle GPS will begin receiving and transmitting packets of data, following a pseudo-random delay for the first cycle. This delay was implemented to prevent continuous transmission on a tumbling satellite. The packets received over LoRa should be processed with a computer as they are essentially just IQ data from the GPS signal, not processed position or time data.

## Configuration of the Device
By default, the packets transmitted over LoRa are 512 bits wide and include a unique, user-defined satellite ID Code, packet index, user-defined bits, and the actual data.
| Number of Bits | Bit Locations | Purpose |
| -------------- | ------------- | ------- |
| 24 | \[511:488\] | Satellite ID Code |
| 12 | \[487:476\] | Packet Index |
| 28 | \[475:448\] | User-defined bits |
| 448 | \[447:0\] | GPS IQ Data |

The user-defined bits can be configured by changing the value of the respective register in the Verilog code. The configuration of the MAX2771 GNSS Receiver and the LoRa SX1276 can be changed by adjusting the values of their respective configuration registers in the MAX_Driver and LORA_Driver Verilog modules, respectively.

The total transmission size, as well as the sample size and whether samples are continuous or not, can all be configured through the value of the GPS_Config register in the GPS_Top Verilog module. Comments are included in the code to assist users with this.

# Changelog
## Most Recent Version (Turtle GPS v2.1)
- Fixes including 10 kOhm pull-up resistors on Flash Pins, lowered pull up resistance to 1 kOhm on mode pin pullup to prevent metastable behaviour on boot, boost converter swapped to MAX8575, done pin pulled up instead of down, and swapped the power supply diode to B130-13-F for higher current capability.
- Swapped LDOs in the power supply for availability, and lower supply noise.
- Made MMCX connectors side mounted instead of front mounted.
- Swapped power header for the M80-8420245 side-mounted Harwin connector.
- Added an L1 SAW Filter to the RF path around the MAX2771 digitiser.
- Updated LoRa RF path to handle frequencies between 400 and 440 MHz.
- Added a 3.3 V Bias Tee to the GNSS RF input path to allow for an active antenna to be directly connected.
- Moved bulk capacitors to the front of the board allowing direct mounting of the PCB to a satellite chassis with a thin (~0.3 mm) thermally conductive layer.
- Changed Flash to S25FL128LAGMFI010 due to part availability.
- Changed LoRa TCXO to TX21-M010S-32.000-X-R due to part avilability.
- Organised KiCAD Schematic into five distinct sections and added 3D models to components.
- Swapped LoRa clock enable voltage divider for a single pull-up resistor.
- Added voltage divider to the relay in the RF path to better match datasheet requirements.
- Reworked trace length matching for the JTAG, and the Flash memory.
- Updated version number and date.

## Note regarding the Turtle GPS v2.0
The Turtle GPS v2.0 does not work by default, as there are issues regarding the flash and power supply components on the board; these issues are resolved in version 2.1.

# Todo
- Update code to default the LoRa frequency to 401 MHz to 403 MHz and cascade the FIR (or implement a CIC) to allow for a sharper cutoff to be attained with the limited FPGA resources.
- Program LoRa receiving capabilities into the FPGA to allow for remote shutdown with a unique user-defined code.
- Optimise size, weight, and performance of the device
- Test in orbit
- Set up a public website for uploading and processing of data
- Add satellite ID code generator and logger to the website

# Licensing

This repository contains material under multiple licenses.

The Turtle GPS was conceived of by Craig Benson and implemented by Dino Colling as part of work conducted for, and licenced by, Skykraft Pty Ltd.

Copyright © Skykraft Pty Ltd. All rights are licensed as described below.

## Hardware

The hardware design files are licensed under CERN-OHL-P v2.

This includes:
- GPS v2.0/KiCad PCB/
- GPS v2.1/KiCad PCB/

## HDL and Software

The HDL and software source code are licensed under the MIT License.

This includes:
- GPS v2.0/Software and HDL/
- GPS v2.1/Software and HDL/

## Documentation

Documentation, diagrams, and images are licensed under
Creative Commons Attribution 4.0 International (CC BY 4.0).

This includes:
- GPS v2.0/BoM/
- GPS v2.1/BoM/

A copy of each license is available in the licenses/ directory.
