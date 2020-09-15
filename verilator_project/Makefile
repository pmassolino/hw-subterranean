.PHONY: clean

# Empty (no trace)
# FST - Enables FST
# Otherwise anyhting will enable VCD
DUMP_TRACE_FORMAT=FST

VERILATOR=verilator
VERILATOR_FLAGS=--cc
VERILATOR_FLAGS+=-Wall
VERILATOR_FLAGS+=-Wno-UNUSED

VERILATOR_CPP=g++
VERILATOR_CPP_WARNINGS=-Wparentheses
VERILATOR_CPP_INCLUDE_FOLDER=/usr/local/share/verilator/include
VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION=$(VERILATOR_CPP_INCLUDE_FOLDER)/verilated.cpp

VERILATOR_CPP_DEFINES=
VERILATOR_CPP_LINK_OPTIONS=

ifdef DUMP_TRACE_FORMAT
ifeq ($(DUMP_TRACE_FORMAT), FST)
VERILATOR_FLAGS+=--trace-fst
VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION+=$(VERILATOR_CPP_INCLUDE_FOLDER)/verilated_fst_c.cpp
VERILATOR_CPP_DEFINES+=-DDUMP_TRACE_ON -DDUMP_TRACE_FST
VERILATOR_CPP_LINK_OPTIONS+=-lz
else
VERILATOR_FLAGS+=--trace
VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION+=$(VERILATOR_CPP_INCLUDE_FOLDER)/verilated_vcd_c.cpp
VERILATOR_CPP_DEFINES+=-DDUMP_TRACE_ON
endif
endif

VERILOG_SOURCE_FOLDER=../verilog_source

SUBTERRANEAN_ROUND_SOURCE=\
	$(VERILOG_SOURCE_FOLDER)/subterranean_round.v

SUBTERRANEAN_ROUNDS_SIMPLE_1_SOURCE=\
	$(SUBTERRANEAN_ROUND_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/subterranean_rounds_simple_1.v

SUBTERRANEAN_ROUNDS_SIMPLE_2_SOURCE=\
	$(SUBTERRANEAN_ROUND_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/subterranean_rounds_simple_2.v

SUBTERRANEAN_ROUNDS_SIMPLE_4_SOURCE=\
	$(SUBTERRANEAN_ROUND_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/subterranean_rounds_simple_4.v

SUBTERRANEAN_STREAM_1_LWC_SOURCE=\
	$(SUBTERRANEAN_ROUNDS_SIMPLE_1_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/subterranean_stream_state_machine.v\
	$(VERILOG_SOURCE_FOLDER)/subterranean_stream.v

SUBTERRANEAN_ROUNDS_SIMPLE_1_LWC_SOURCE=\
	$(SUBTERRANEAN_STREAM_1_LWC_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/subterranean_lwc_buffer_in.v\
	$(VERILOG_SOURCE_FOLDER)/subterranean_lwc_buffer_out.v\
	$(VERILOG_SOURCE_FOLDER)/subterranean_lwc_state_machine.v\
	$(VERILOG_SOURCE_FOLDER)/subterranean_lwc.v

tb_subterranean_stream: $(SUBTERRANEAN_STREAM_1_LWC_SOURCE) tb_subterranean_stream.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module subterranean_stream $(SUBTERRANEAN_STREAM_1_LWC_SOURCE) tb_subterranean_stream.cpp
	make -C obj_dir -f Vsubterranean_stream.mk
	@echo "Building a Verilator-based simulation for $(@)"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		$(@).cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vsubterranean_stream__ALL.a \
		-o $(@)

tb_subterranean_lwc: $(SUBTERRANEAN_ROUNDS_SIMPLE_1_LWC_SOURCE) tb_subterranean_lwc.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module subterranean_lwc $(SUBTERRANEAN_ROUNDS_SIMPLE_1_LWC_SOURCE) tb_subterranean_lwc.cpp
	make -C obj_dir -f Vsubterranean_lwc.mk
	@echo "Building a Verilator-based simulation for $(@)"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		$(@).cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vsubterranean_lwc__ALL.a \
		-o $(@)

clean:
	@echo "Cleaning up..."
	rm -r -f obj_dir
	rm -r -f tb_subterranean_lwc
	rm -r -f tb_subterranean_lwc.vcd
	rm -r -f tb_subterranean_lwc.fst
	rm -r -f tb_subterranean_lwc.fst.hier
	rm -r -f tb_subterranean_stream
	rm -r -f tb_subterranean_stream.vcd
	rm -r -f tb_subterranean_stream.fst
	rm -r -f tb_subterranean_stream.fst.hier
	@echo "Cleaning done."