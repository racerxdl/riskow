ROOTDIR       := $(realpath .)
TESTGEN       := $(shell cd testdata; find . -name '*.py')
SOURCES       := $(shell find . -name '*.v' -not -name '*_tb.v')
TB_SOURCES    := $(shell find . -name '*_tb.v')
TB_DSN        := $(TB_SOURCES:%.v=%.dsn)
TB_DSN_RES    := $(TB_SOURCES:%.v=%.dsn.result)
VCD_FILES     := $(shell find . -name '*.vcd')
GENERATED_MEM := $(shell find testdata -name '*.mem')
MODULES       := $(shell grep -r '^module' --include '*.v' . | awk '{ print $$2 }'  | cut -d';' -f1 |grep -v Test)
YOSYS_SCRIPT  := syn.ys

DOCKER=docker

PWD = $(shell pwd)
DOCKERARGS = run --rm -v $(PWD):/src -w /src
#
GHDL      = $(DOCKER) $(DOCKERARGS) hdlc/ghdl ghdl
GHDLSYNTH = $(GHDL)
YOSYS     = $(DOCKER) $(DOCKERARGS) hdlc/yosys yosys
NEXTPNR   = $(DOCKER) $(DOCKERARGS) hdlc/nextpnr:ecp5 nextpnr-ecp5
ECPPACK   = $(DOCKER) $(DOCKERARGS) hdlc/prjtrellis ecppack
OPENOCD   = $(DOCKER) $(DOCKERARGS) --device /dev/bus/usb ghdl/synth:prog openocd
IVERILOG  = $(DOCKER) $(DOCKERARGS) racerxdl/icarus iverilog
VVP  			= $(DOCKER) $(DOCKERARGS) racerxdl/icarus vvp

# V6.1
#LPF=constraints/ecp5-hub-5a-75b-v6.1.lpf
# V7.0
# LPF=constraints/ecp5-hub-5a-75b-v7.0.lpf
# V7.0 I5
LPF=constraints/ecp5-i5-7.0.lpf

# CABGA381 on V6.1 or i5 7.0
PACKAGE=CABGA381
# CABGA256 on V7.0
# PACKAGE=CABGA256
# Maybe --timing-allow-fail
NEXTPNR_FLAGS=--ignore-loops --25k --freq 25 --speed 6 --write top-post-route.json --lpf-allow-unconstrained
OPENOCD_JTAG_CONFIG=openocd/ft232.cfg
OPENOCD_DEVICE_CONFIG=openocd/LFE5UM5G-25F.cfg

all : top.svf

testdata:
	@echo "Generating test data"
	@cd testdata; for test in $(TESTGEN); do echo "	Running $$test"; python3 $$test; cd ..; done
	@cd testdata && $(MAKE) clean && $(MAKE) testmem

%.dsn.result: %.dsn testdata
	@echo "Running $(@:%.dsn.result=%.dsn) -> $@"
	@$(VVP) $(@:%.dsn.result=%.dsn) | tee $@
	@!(cat $@ | grep -q NOK) || (echo "Test $@ failed $$?"; exit 1)

%.dsn: %.v
	@echo "Generating $< -> $@"
	@$(IVERILOG) -DSIMULATION -g2012 -o $@ $< $(SOURCES)

test: testdata $(TB_DSN) $(TB_DSN_RES)
	@for test in $<; do echo "Running test $$test"; done
# 	echo "test $<"

stat:
	@set -e
	@mkdir -p stats
	@mkdir -p tmp
	@for module in $(MODULES); do echo "Processing $$module"; $(YOSYS) -p "synth_ecp5 -top $$module; tee -a stats/$$module.txt stat" $(SOURCES) 2>&1 1>>/dev/null; done
	@set +e

artifacts: test top.svf
	@echo "Composing artifacts"
	@mkdir -p artifacts
	@tar -cvjpf artifacts.tar.bz2 top.svf $(shell find . -name *.vcd);

$(YOSYS_SCRIPT):
	@echo "" > $(YOSYS_SCRIPT)
	@for file in $(SOURCES);	do echo "read_verilog $$file" >> $(YOSYS_SCRIPT); done
	@echo "synth_ecp5 -retime -top top" >> $(YOSYS_SCRIPT)
	@echo "tee -a fullmodule.txt stat" >> $(YOSYS_SCRIPT)

top.json : $(YOSYS_SCRIPT) $(SOURCE)
	@$(YOSYS) -s $< -o $@

top.config : top.json $(LPF)
	@$(NEXTPNR) --json $< --lpf $(LPF) --textcfg $@ $(NEXTPNR_FLAGS) --package $(PACKAGE)

top.svf : top.config
	@$(ECPPACK) --svf top.svf $< $@

top.bit : top.config
	$(ECPPACK) --bit $@ $<

prog: top.svf
	@$(OPENOCD) -f $(OPENOCD_JTAG_CONFIG) -f $(OPENOCD_DEVICE_CONFIG) -c "transport select jtag; init; svf $<; exit"

clean:
	@rm -f work-obj08.cf *.bit *.json *.svf *.config syn.ys $(TB_DSN) $(VCD_FILES) $(TB_DSN_RES) $(GENERATED_MEM)

.PHONY: clean prog testdata
.PRECIOUS: top.json top_out.config top.bit