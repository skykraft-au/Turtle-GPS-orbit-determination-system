## Clock Signals
set_property -dict { PACKAGE_PIN G4   IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -period 10.000 -name sys_clk_pin -add [get_ports clk]

## IO
set_property -dict { PACKAGE_PIN B5   IOSTANDARD LVCMOS33 } [get_ports { I0 }];
set_property -dict { PACKAGE_PIN C5   IOSTANDARD LVCMOS33 } [get_ports { I1 }];
set_property -dict { PACKAGE_PIN A4   IOSTANDARD LVCMOS33 } [get_ports { Q0 }];
set_property -dict { PACKAGE_PIN F3   IOSTANDARD LVCMOS33 } [get_ports { Q1 }];
set_property -dict { PACKAGE_PIN D1   IOSTANDARD LVCMOS33 } [get_ports { ADC_CLK }];
set_property -dict { PACKAGE_PIN D3   IOSTANDARD LVCMOS33 } [get_ports { MAX_SCLK }];
set_property -dict { PACKAGE_PIN E2   IOSTANDARD LVCMOS33 } [get_ports { MAX_SDATA }];
set_property -dict { PACKAGE_PIN E4   IOSTANDARD LVCMOS33 } [get_ports { MAX_CSN }];
set_property -dict { PACKAGE_PIN L12  IOSTANDARD LVCMOS33 } [get_ports { LORA_RESET }];
set_property -dict { PACKAGE_PIN M5   IOSTANDARD LVCMOS33 } [get_ports { LORA_SDATA }];
set_property -dict { PACKAGE_PIN P2   IOSTANDARD LVCMOS33 } [get_ports { LORA_CSN }];
set_property -dict { PACKAGE_PIN P4   IOSTANDARD LVCMOS33 } [get_ports { LORA_MISO }];
set_property -dict { PACKAGE_PIN P5   IOSTANDARD LVCMOS33 } [get_ports { LORA_SCLK }];
set_property -dict { PACKAGE_PIN H13  IOSTANDARD LVCMOS33 } [get_ports { DIO0 }];
set_property -dict { PACKAGE_PIN M1  IOSTANDARD LVCMOS33 } [get_ports { LED }];

## Configuration options, can be used for all designs
set_property BITSTREAM.CONFIG.CONFIGRATE 3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

