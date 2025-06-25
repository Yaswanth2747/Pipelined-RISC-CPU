This folder contains the final submission for the Course project EE309 Microprocessors and Computer Organisation.

Please note that this folder contains a folder named \Codes, in that folder you can find our final code for proc.vhd for both multicycle "mainMulticycProc.txt" and pipelined version "mainPipelineProc.txt", just copy paste them in proc.vhd file while you run this in Quartus Prime. Also datapath and all the involved components like ring buffer are the same for both multicycle and pipelined versions, we have redesinged our baseline multicycle such that it will work even with our pipelined datapath.
Only difference comes for the Program Counter Component, for pipeline use "PC_component_Pipeline.txt" and for multicycle use "PC_component_Multicycle.txt" in PC_Component.vhd

Again, except for proc.vhd and PC_Component.vhd, all other components can be used for both Multicycle and Pipeline.

Also testbenches work for both too. We have included three test benches without any Hazards to start-off with, thank you. :)