transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/mux2.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/SE9.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/SE6.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/ring_buffer.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/proc.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/ALU.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/datapath.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/Register_File.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/TR1.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/TR2.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/TR3.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/TR4.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/mux4.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/mux2x1_3bit.vhd}
vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/PC_Component.vhd}

vcom -93 -work work {C:/Users/yaswa/OneDrive/Desktop/Micro CPU Main/EE309-Spring25-Pipelined-Processor-main/src/testbench.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 1000 ns
