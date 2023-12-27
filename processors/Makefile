# DIR's
SRCDIR 		:= source
TBDIR 		:= testbench
INCL 		:= include
WORKDIR 	:= work
SCRDIR 		:= scripts

# source files
# FETCH_UNIT_DEF 			:= include/core_types.vh
# FETCH_UNIT_RTL_FILES 	:= source/fetch_unit.sv
# FETCH_UNIT_TB 			:= testbench/fetch_unit_tb.sv
CORE_DEF				:= include/core_types.vh
DESIGN_RTL_FILES		:= source/*.sv

# others hard defined
SIMTIME := -all

# # view waveform in graphical mode and load do file if there is one
# FETCH_UNIT_DOFILE		= fetch_unit
# FETCH_UNIT_WAVDO		= do $(SCRDIR)/$(FETCH_UNIT_DOFILE).do
# FETCH_UNIT_SIMDO		= "view objects; $(FETCH_UNIT_WAVDO); run $(SIMTIME);" -onfinish stop

# Compiler/simulator options
VSIMOPTS := -lib $(WORKDIR)
VLOGOPTS := -sv -work $(WORKDIR) -incr -vopt # +define+SYNTHESIS
# VLOGOPTS_DPI := -sv -work $(WORKDIR) -dpiheader dpi_header_file.h -dpicpppath /usr/bin/g++ -ccflags "-std=c++11 -Wall -Wextra -Wfatal-errors" +define+UTIL_DPI +define+FLOAT_DPI
# VLOGOPTS_DPI_CPP := -work $(WORKDIR) -dpicpppath /usr/bin/g++ -ccflags "-std=c++11 -Wall -Wextra -Wfatal-errors"

# compile_fetch_unit: $(WORKDIR)
# 		@vlog $(VLOGOPTS) +incdir+$(INCL) $(FETCH_UNIT_DEF)
# 		@vlog $(VLOGOPTS) +incdir+$(INCL) $(FETCH_UNIT_RTL_FILES)
# 		@vlog $(VLOGOPTS) +incdir+$(INCL) $(FETCH_UNIT_TB)

# fetch_unit.wav: compile_fetch_unit
# 		vsim $(VSIMOPTS) -gui \
# 		fetch_unit_tb \
# 		-coverage -voptargs=+acc \
# 		-do $(FETCH_UNIT_SIMDO)

# fetch_unit.sim: compile_fetch_unit
# 		vsim $(VSIMOPTS) -c \
# 		fetch_unit_tb \
# 		-coverage \
# 		-do "run $(SIMTIME);"

compile_designs: $(WORKDIR)
	@vlog $(VLOGOPTS) +incdir+$(INCL) $(CORE_DEF)
	@vlog $(VLOGOPTS) +incdir+$(INCL) $(DESIGN_RTL_FILES)

all.wav: compile_designs
	echo "NOT FILLED IN YET"

all.sim: compile_designs
	echo "NOT FILLED IN YET"

%.wav: $(WORKDIR)
	@vlog $(VLOGOPTS) +incdir+$(INCL) $(CORE_DEF)
	@vlog $(VLOGOPTS) +incdir+$(INCL) $(SRCDIR)/$*.sv
	@vlog $(VLOGOPTS) +incdir+$(INCL) $(TBDIR)/$*_tb.sv
	vsim $(VSIMOPTS) -gui \
	$*_tb \
	-coverage -voptargs=+acc \
	-do "view objects; do $(SCRDIR)/$*.do; run $(SIMTIME);" -onfinish stop

%.sim: $(WORKDIR)
	@vlog $(VLOGOPTS) +incdir+$(INCL) $(CORE_DEF)
	@vlog $(VLOGOPTS) +incdir+$(INCL) $(SRCDIR)/$*.sv
	@vlog $(VLOGOPTS) +incdir+$(INCL) $(TBDIR)/$*_tb.sv
	vsim $(VSIMOPTS) -c \
	$*_tb \
	-coverage \
	-do "run $(SIMTIME);"

$(WORKDIR):
	@vlib $(WORKDIR)

clean: 
	rm -rf work $(WORKDIR) transcript *.vstf 
	rm *.wlf
