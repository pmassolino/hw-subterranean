# Subterranean2.0
This is the hardware implementation of Subterranean2.0 AEAD/Hash cipher.
Subterranean2.0 is a Round 2 candidate for the NIST Lightweight Cryptography (LWC).

The Hardware implementation is compatible with the hardware LWC API from https://cryptography.gmu.edu/athena/index.php?id=LWC
The implementation done in Verilog and doesn't use any files provided by the LWC API.

### Folder structure  
- *data_test*  
	All the necessary KAT files are here for the testbenches.
- *icarus_project*  
	It has the Makefile to run the verilog testbenches.
- *python_source*  
	The Python source code of Subterranean2.0 as reference code.
- *verilator_project*  
	It has the Makefile to run the Verilator (C++) testbenches and the testbenches themselves.
- *verilog_source*  
	All RTL and testbenches in Verilog.
- *yosys_synth*  
	The scripts to run Yosys for synthesis results.
		
#### Verilog files
- *subterranean_lwc.v subterranean_lwc_state_machine.v*  
	The first is the top level of the LWC API architecture and the respective state machine.
- *subterranean_lwc_buffer_in.v subterranean_lwc_buffer_out.v*  
	The buffers used in LWC architecture.
- *subterranean_round.v*  
	The basic permutation of Subterranean2.0, only the combinatorial of the of round function.
- *subterranean_rounds_simple_1.v, subterranean_rounds_simple_2.v, subterranean_rounds_simple_4.v*  
	The basic simple version of Subterranean2.0, it can basically perform a duplex.
	The number shows how many rounds it can execute per clock cycle.
- *subterranean_rounds_simple_1_axi4_lite.v*  
	The basic version extended with a AXI4-Lite interface.
	It is made as proof of concept for a HW/SW codesign of Subterranean2.0
- *subterranean_stream.v, subterranean_stream_state_machine.v*  
	The stream version of Subterranean2.0, it can perform the entire AEAD and Hash,
	just the messages have to be carefully timed.
- *tb_subterranean_lwc.v*  
	This is a Verilog testbench for the top level API.
	It is preferable to use the Verilator ones, since this one can be very slow.
- *tb_subterranean_round.v*  
	Testbench for subterranean_round.v, thus only 1 round.
- *tb_subterranean_rounds_simple_1.v, tb_subterranean_rounds_simple_2.v, tb_subterranean_rounds_simple_4.v*  
	Testbench for the AEAD/Hash of Subterranean2.0 on top of the duplex off subterranean_rounds_simple_.v
- *tb_subterranean_rounds_simple_1_axi4_lite.v*  
	Testbench for the AXI4-Lite interface

#### Verilator testbenches
- *tb_subterranean_lwc.cpp*  
	Testbench for the full LWC API. This should be used, since Verilator usually can perform better than Icarus.
- *tb_subterranean_stream.cpp*  
	Testbench for the stream version of the circuit.

### Reference

While the Subterranean2.0 LWC API hardware doesn't have a specific paper, you can cite the ToSC paper which has the rounds implementation.  
	
Joan Daemen, Pedro Maat C. Massolino, Alireza Mehrdad, and Yann Rotella. "The Subterranean 2.0 Cipher Suite". IACR Transactions on Symmetric Cryptology, 2020(S1), 262-294. [doi:10.13154/tosc.v2020.iS1.262-294](https://doi.org/10.13154/tosc.v2020.iS1.262-294) [Paper](https://tosc.iacr.org/index.php/ToSC/article/view/8622) 
