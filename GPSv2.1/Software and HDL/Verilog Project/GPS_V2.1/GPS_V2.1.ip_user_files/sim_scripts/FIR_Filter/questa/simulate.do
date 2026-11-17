onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib FIR_Filter_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {FIR_Filter.udo}

run 1000ns

quit -force
