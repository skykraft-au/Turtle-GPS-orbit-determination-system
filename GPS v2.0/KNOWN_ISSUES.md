# Known Issues
The Turtle GPS v2.0 does not work by default, as there are issues regarding the flash and power supply components on the board; these issues are resolved in version 2.1. If you wish to use version 2.0, you will need to resolve these issues. The key issues and solutions are as follows:
- There are missing pull-up resistors on pins 1, 3, and 7 of the Flash memory; these should be 10 kΩ.
- The pull-up resistors on the M0, M1, and M2 pins on the underside of the FPGA are 10 kΩ, but they should be 1 kΩ to initiate the correct startup configuration.
- A few issues exist in the lower half of the power supply, including incorrect placement of the boost converter, sensitive output of the first 3.3 V LDO, and insufficient current rating in both the diode and boost converter. To resolve this, I recommend bypassing this section by powering the board with 3.3 V through test point 3.
- The done indicator pin from the FPGA should be a pull-up and not a pull-down.
