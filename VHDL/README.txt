# Description of code written as comments
# Insructions to start simulation and generate waveform:
change testbench as per RAM, ROM, MAC module. keep all testbenches and files in same directory. navigate to the directory via command prompt
# for overall design
	ghdl -a overall_design.vhdl
	ghdl -a tb_overall_design.vhdl
	ghdl -e tb_overall_design
	ghdl -r tb_overall_design --vcd=overall_design.vcd
	gtkwave overall_design.vcd
# for part_d entity
	ghdl -a part_d.vhdl
	ghdl -a tb_part_d.vhdl
	ghdl -e tb_part_d
	ghdl -r tb_part_d --vcd=part_d.vcd
	gtkwave part_d.vcd
## Dependencies
1. ghdl
2. gtkwave

links for generation of ASM chart and circuit diagram:
1. https://app.creately.com/diagram/gabc1FJR6gR/edit
2. https://app.creately.com/diagram/glRT0yy4LKG/edit