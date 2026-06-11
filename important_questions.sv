
//Q: Explain about FIFO, Clk generation, State machine

	/*
	

		Answer: 

		A FIFO is a memory buffer where the first data written is the first one read out—just like a queue.
		🛠 Use Cases:
			•	Data buffering between modules running at different speeds.
			•	Clock Domain Crossing (CDC) using asynchronous FIFO.
			•	Prevent data loss when producer and consumer are not synchronized.
		🧩 Main Components:
			•	Write pointer: Tracks where to write.
			•	Read pointer: Tracks where to read.
			•	Memory array: Stores the data.
			•	Full/empty flags: Show FIFO status.
		🔁 Types:
			•	Synchronous FIFO: Same clock for read and write.
			•	Asynchronous FIFO: Different clocks (uses Gray code for pointer synchronization).


		Clock generation is the process of producing clock signals for synchronous digital designs.
		🛠 In Testbenches:
		You often write a simple block like this in SystemVerilog:
		bit clk;

		initial clk = 0;
		always #5 clk = ~clk; // 100 MHz clock (10ns period)
		🧩 Use Cases:
			•	Driving the DUT (Device Under Test) in simulations.
			•	Controlling timing and synchronization in testbenches.


		A state machine is a model of computation with a finite number of states and defined transitions based on inputs.
		📦 Types:
			1.	Moore Machine: Output depends only on state
			2.	Mealy Machine: Output depends on state + input

	*/
	module moore_fsm(input logic clk, reset, data_in, output logic seq_detected);
		typedef enum logic [1:0] {IDLE, S1, S10, S101} state_t;
		state_t state, next_state;
	
		always_ff @(posedge clk or posedge reset) begin
			if (reset)
				state <= IDLE;
			else
				state <= next_state;
		end
	
		always_comb begin
			case (state)
				IDLE: next_state = data_in ? S1 : IDLE;
				S1:   next_state = data_in ? S1 : S10;
				S10:  next_state = data_in ? S101 : IDLE;
				S101: next_state = data_in ? S1 : IDLE;
				default: next_state = IDLE;
			endcase
		end
	
		assign seq_detected = (state == S101);
	endmodule

	//detect 110
	module mealy_fsm(input logic clk, reset, data_in, output logic seq_detected);
		typedef enum logic [1:0] {IDLE, S1, S11} state_t;
		state_t state, next_state;
	
		always_ff @(posedge clk or posedge reset) begin
			if (reset)
				state <= IDLE;
			else
				state <= next_state;
		end
	
		always_comb begin
			case (state)
				IDLE: next_state = data_in ? S1 : IDLE;
				S1:   next_state = data_in ? S11 : IDLE;
				S11:  next_state = data_in ? S11 : IDLE;
				default: next_state = IDLE;
			endcase
		end
	
		assign seq_detected = (state == S11 && !data_in);
	endmodule

	/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Q: How does I2C manage situations where a device needs more time to process data before the next clock pulse?

	/*

		Answer:

		I2C supports clock stretching, where the slave holds the SCL line low to delay the next clock pulse. 
		The master waits until the slave releases the line, allowing communication to proceed safely. 
		This ensures proper synchronization and prevents data corruption, especially when the slave needs extra time to process data.

		Entire UVM code is written inside i2c_protocol.sv file.

		[Sequencer] 
		↓
		[Driver]  ───►  [DUT]  ◄──── [Slave Driver]
		↓                  ↑
		[Predictor]       [Monitor]
		↓                  ↓
		(expected txn)      (actual txn)
		↓                  ↓
		└──────▶  [Scoreboard] ◀──────┘
	*/

	/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Q: Describe fully how a processor works in as much detail as possible
	/*
		A:
		🧠 What is a Processor?
			•	A processor (CPU) is the brain of a computer.
			•	Executes instructions in a sequence to perform tasks.
			•	Handles arithmetic, logic, control, and data movement operations.

		⸻

		🧱 Main Components of a Processor
			•	Program Counter (PC) – Holds the address of the current instruction.
			•	Instruction Memory – Stores the machine code (program).
			•	Instruction Decoder – Decodes fetched instructions.
			•	Register File – Temporary storage for fast operand access.
			•	ALU (Arithmetic Logic Unit) – Performs arithmetic and logic operations.
			•	Control Unit – Generates control signals based on the instruction type.
			•	Data Memory – Stores/retrieves data for load/store operations.
			•	Clock – Drives all sequential logic and synchronizes operations.

		⸻

		🔁 Instruction Cycle (5 Stages in a RISC Pipeline)
			1.	Instruction Fetch (IF)
			•	Fetch instruction from memory at the address in PC.
			•	Increment PC (PC = PC + 4 for 32-bit instructions).
			2.	Instruction Decode (ID)
			•	Decode the instruction into opcode, registers, etc.
			•	Read source registers from the register file.
			•	Generate control signals.
			3.	Execute (EX)
			•	ALU performs arithmetic/logic operation.
			•	For branches: compute condition and branch target.
			•	For memory: calculate effective address.
			4.	Memory Access (MEM)
			•	If it’s a load: read from data memory.
			•	If it’s a store: write to data memory.
			5.	Write Back (WB)
			•	Write ALU result or loaded data back to the destination register.

		⸻

		📦 Example Instruction: add $t0, $t1, $t2
			•	IF: Fetch add instruction.
			•	ID: Decode: opcode = add, src1 = $t1, src2 = $t2, dest = $t0.
			•	EX: ALU computes $t1 + $t2.
			•	WB: Result is written to $t0.

		⸻

		🔄 Pipelining (Parallel Execution)
			•	Overlaps different stages of multiple instructions.
			•	Increases throughput (1 instruction per cycle after pipeline fills).
			•	5-stage pipeline: IF → ID → EX → MEM → WB.

		⸻

		⛔ Hazards in Pipelines
			1.	Data Hazards – When an instruction depends on a result not yet written.
			•	Solved by: forwarding or stalls.
			2.	Control Hazards – From branches or jumps.
			•	Solved by: branch prediction or flushing.
			3.	Structural Hazards – Two instructions need the same hardware.
			•	Solved by: duplicating resources or stalls.

		⸻

		🧩 Advanced Processor Features

		🔹 Superscalar Execution  
			•	Multiple instructions are fetched, decoded, and execute per cycle.

		🔹 Out-of-Order Execution
			•	Instructions are executed as soon as operands are ready (not in strict order).
			•	Uses:
			•	Reservation stations
			•	Reorder buffer
			•	Register renaming

		🔹 Branch Prediction
			•	Predicts the outcome of branches to avoid pipeline stalls.
			•	Uses:
			•	Static/dynamic predictors
			•	History-based tables

		⸻

		⚙️ Cache Hierarchy
			•	Fast memory to reduce latency in data access.
			•	Levels:
			•	L1: Smallest & fastest (per core).
			•	L2: Larger, slower.
			•	L3: Shared among cores, biggest and slowest.
			•	Types:
			•	Instruction cache
			•	Data cache
			•	Unified cache

		⸻

		🧠 Virtual Memory & MMU
			•	Programs use virtual addresses.
			•	MMU (Memory Management Unit) translates virtual → physical addresses.
			•	Supports:
			•	Process isolation
			•	Demand paging
			•	Protection
	*/

		/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Q:What are all run-phases and in detail discussion about it


/*

KEY NOTES:

Runtime phases are tasks (can consume time).
All components execute phases in parallel.
Controlled using objections.

pre_reset_phase
reset_phase
post_reset_phase

pre_configure_phase
configure_phase
post_configure_phase

pre_main_phase
main_phase
post_main_phase

pre_shutdown_phase
shutdown_phase
post_shutdown_phase

Also commonly used:

run_phase


Important Concept

All runtime phases execute in parallel across components.

Example:

driver main_phase
monitor main_phase
scoreboard main_phase

all run simultaneously.

Detailed Discussion of Each Phase
1. pre_reset_phase

Executed before reset is asserted.

Typical Usage
initialize signals
prepare interfaces
stop previous traffic
Example
task pre_reset_phase(uvm_phase phase);
    vif.valid <= 0;
    vif.data  <= 0;
endtask

2. reset_phase

Actual DUT reset occurs here.

Typical Usage
assert reset
clear queues
initialize DUT state
Example
task reset_phase(uvm_phase phase);

    phase.raise_objection(this);

    vif.reset <= 1;
    repeat(5) @(posedge vif.clk);
    vif.reset <= 0;

    phase.drop_objection(this);

endtask

Why We Used Objections Here

During reset:

we wait for 5 clock cycles
simulation time is advancing

So we raise an objection to keep the phase alive.

After reset finishes:

we drop the objection
UVM knows this component is done


What Happens Without Objections?
Problem:

UVM may end reset_phase instantly
next phase may start early
reset sequence may not complete correctly


3. post_reset_phase

Executed after reset deassertion.

Typical Usage
wait for DUT stabilization
protocol initialization
idle cycles
4. pre_configure_phase

Preparation before configuration.

Typical Usage
initialize config structures
prepare register values

Usually lightly used.

5. configure_phase

DUT configuration happens here.

Typical Usage
register programming
CSR writes
mode setup
Example
task configure_phase(uvm_phase phase);

    regmodel.ctrl.write(status, 32'h1);

endtask
6. post_configure_phase

Executed after configuration.

Typical Usage
wait until DUT accepts configuration
protocol settling
7. pre_main_phase

Preparation before main traffic.

Typical Usage
initialize sequences
start clocks
synchronize environments
8. main_phase

Main verification activity happens here.

This is one of the most important phases.

Typical Usage
run sequences
generate traffic
stress testing
protocol testing
Example
task main_phase(uvm_phase phase);

    phase.raise_objection(this);

    my_seq.start(env.agent.seqr);

    phase.drop_objection(this);

endtask
9. post_main_phase

Executed after main traffic completes.

Typical Usage
drain remaining packets
flush FIFOs
final checking
10. pre_shutdown_phase

Preparation before shutdown.

Typical Usage
stop generators
disable new transactions

11. shutdown_phase

Controlled DUT shutdown.

Typical Usage
stop clocks
power-down sequences
final scoreboard comparison

12. post_shutdown_phase

Final cleanup phase.

Typical Usage
reporting
final logs
resource cleanup

Traditional run_phase

Before phase-domain runtime phases became common, UVM mainly used:

task run_phase(uvm_phase phase);

This phase still exists and is widely used.

Difference Between run_phase and main_phase
run_phase	main_phase
Old style	Phase-domain style
Entire runtime	Specific runtime stage
Simpler	More structured
Most common in smaller TBs	Preferred in complex TBs
Objections in Runtime Phases

Runtime phases end when all objections are dropped.

Example
phase.raise_objection(this);

#100ns;

phase.drop_objection(this);

Without objections:

simulation may end immediately.
Runtime Phase Synchronization

UVM uses:

phase scheduler
objections
phase jumping
domain synchronization

to coordinate components.
	*/

	/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Q: Different between a task and function in SV

	/*
		✅ Function
			•	Must return a value.
			•	Cannot have timing controls like #, @, or wait.
			•	Executes in zero simulation time.
			•	Used for pure computations (e.g., arithmetic, logic).
			•	Only allows input arguments.
			•	Cannot be forked or run in parallel.
			•	Can be called inside expressions (e.g., if (my_func(x))).

		⸻

		✅ Task
			•	Does not return a value (can use output or inout ports instead).
			•	Can contain timing controls (#10, @(posedge clk), etc.).
			•	Can consume simulation time.
			•	Used for protocol modeling, interface operations, or delayed actions.
			•	Supports input, output, and inout arguments.
			•	Can be called concurrently using fork...join.
	*/

	/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Q: design question - design a system to identify if input bitstream is divisible by 5 - taking a 16bit stream

	//best approach
	module div_by_5_checker (input logic clk,reset,bit_in,last,output logic div_by_5);

  	logic [2:0] rem; //max value is 4 (since num is 5)

	always_ff @(posedge clk) begin
		if (reset) begin
			rem <= 0;
		end
		else begin
			rem <= (rem*2 + bit_in) % 5;
		end
	end

	assign div_by_5 = (last && rem == 0);
endmodule

	/////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
Q: Can you describe your process for IP verification? 
	If a new IP is incorporated into your design, how do you go about verifying it?

	/*
		1. 🔍 Understand the IP Specification
			•	Read the IP’s functional spec, interface protocols (e.g., AXI, APB), registers, timing diagrams, and state machines.
			•	Clarify:
			•	What does the IP do?
			•	What are the inputs/outputs?
			•	What are the configuration and operational modes?

		“I start by thoroughly understanding the specification to know what needs to be tested, and what kind of corner cases could arise.”

		⸻

		2. 🛠️ Set Up the Testbench Environment
			•	Decide the verification methodology (e.g., UVM).
			•	Build or reuse:
			•	Interfaces (with virtual interfaces)
			•	Drivers, monitors, sequencers, agents
			•	Scoreboard
			•	Reference model (for checking expected behavior)
			•	Connect everything in the environment (env) and test layer.

		“I create modular agents for each interface and build a layered UVM environment to drive, monitor, and validate behavior.”

		⸻

		3. 🧪 Write Testcases
			•	Start with basic sanity tests (reset, read/write config registers).
			•	Gradually add:
			•	Directed tests (specific use cases)
			•	Constrained-random tests (broader scenarios)
			•	Corner cases (e.g., back-to-back transfers, interrupts, resets mid-transaction)
			•	Illegal scenarios (what if a control signal toggles unexpectedly?)

		“I begin with directed tests to ensure stability, then scale to constrained-random for coverage.”

		⸻

		4. ✅ Assertions and Protocol Checks
			•	Add SystemVerilog assertions (SVA) to check:
			•	Handshake signals
			•	Timing relations
			•	Protocol violations (e.g., burst length, response latency)
			•	Use interface protocol checkers if available (e.g., Synopsys, Cadence VIP).

		“I insert protocol assertions to validate timing and handshake behavior and catch bugs early.”

		⸻

		5. 📊 Functional and Code Coverage
			•	Enable:
			•	Functional coverage: coverpoints and cross-coverage (on config fields, state transitions, etc.)
			•	Code coverage: line, branch, toggle (ensure RTL is exercised)

		“I use coverage data to drive further test writing and ensure no logic is left unverified.”

		⸻

		6. 🧼 Regression and Debugging
			•	Build a regression suite of tests.
			•	Automate runs with makefiles, scripts, or CI systems.
			•	Use waveform viewers, logs, and assertions for debugging.

		“I run regressions to ensure stability after any change and track bugs with waveforms and logs.”

		⸻

		7. 📦 Integration Readiness
			•	Ensure IP is plug-and-play for SoC level
			•	Create checklists:
			•	Interface compliance
			•	Config register maps
			•	Interrupt behavior
			•	Low-power modes (if applicable)
	*/

		/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Q: soft vs hard constraints

	/*
		✅ Hard Constraints
		•	Must be satisfied during randomization.
		•	Cannot be overridden.
		•	Randomization fails if they can’t be satisfied.
		•	Used to enforce strict rules.

		⸻

		🌿 Soft Constraints
			•	Provide default values.
			•	Can be overridden by:
			•	Hard constraints
			•	Manually assigned values
			•	Only apply if no other value is set.
			•	Useful for configurable or reusable components.
	*/

	/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Q: RISC vs CISC

	/*
		✅ RISC (Reduced Instruction Set Computer)
		•	Uses simple, fixed-length instructions.
		•	Executes most instructions in one clock cycle.
		•	Emphasizes hardware simplicity, shifts complexity to software.
		•	Requires more instructions per task, but each is fast.
		•	Uses load/store architecture — only registers are used in computation, memory is accessed separately.

		🧠 Examples: ARM, MIPS, RISC-V

		⸻

		⚙️ CISC (Complex Instruction Set Computer)
			•	Uses complex, variable-length instructions.
			•	A single instruction can perform multiple operations (e.g., load + add + store).
			•	Emphasizes fewer lines of assembly code.
			•	Instructions may take multiple clock cycles.
			•	Memory operations can be part of instructions (e.g., arithmetic with memory operands).

		🧠 Examples: x86, Intel 8086
	*/

	/////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
Q: virtual function vs normal function

	virtual function is meant for runtime polymorphism resolved during runtime
	normal function is resolved during compile time
*/

	/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Q: simulation based vs formal verification

	/*
		✅ Simulation-Based Verification

		🔹 What it is:
			•	Runs testcases (usually in UVM) to stimulate the design and check output.
			•	Verifies specific scenarios over time.

		🔧 How it works:
			•	You write testbenches and run sequences to check behavior.
			•	Use tools like ModelSim, VCS, or Xcelium.

		✅ Pros:
			•	Easy to write and visualize with waveforms.
			•	Great for verifying typical and corner-case behavior.
			•	Supports large designs and real-world scenarios.

		❌ Cons:
			•	Only covers what you test — might miss unintended bugs.
			•	Time-consuming with long simulations or regressions.
			•	Coverage-dependent: you need to monitor how much of the design was exercised.

		⸻

		🧠 Formal Verification

		🔹 What it is:
			•	Uses mathematical proofs and static analysis to verify that design properties are always true (or false).
			•	No testbench needed — you write properties/assertions.

		🔧 How it works:
			•	Tools explore all possible input combinations and states exhaustively.
			•	Uses tools like JasperGold, OneSpin, Questa Formal.

		✅ Pros:
			•	Finds corner-case bugs that simulation might miss.
			•	Exhaustive: proves properties hold for all inputs and paths.
			•	Fast and effective for small to medium-sized blocks, especially control logic.

		❌ Cons:
			•	Doesn’t scale easily to large SoC designs.
			•	Requires formal-friendly coding and well-written properties.
			•	More abstract — not as intuitive as simulation.
	*/

	/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Q: design a matrix in spiral manner

	/*
		#include <iostream>
		#include <vector>
		using namespace std;

		void printSpiral(vector<vector<int>>& matrix) {
			int top = 0;
			int bottom = matrix.size() - 1;
			int left = 0;
			int right = matrix[0].size() - 1;

			while (top <= bottom && left <= right) {
				// Left to right
				for (int i = left; i <= right; ++i)
					cout << matrix[top][i] << " ";
				top++;

				// Top to bottom
				for (int i = top; i <= bottom; ++i)
					cout << matrix[i][right] << " ";
				right--;

				// Right to left
				if (top <= bottom) {
					for (int i = right; i >= left; --i)
						cout << matrix[bottom][i] << " ";
					bottom--;
				}

				// Bottom to top
				if (left <= right) {
					for (int i = bottom; i >= top; --i)
						cout << matrix[i][left] << " ";
					left++;
				}
			}
			cout << endl;
		}
	*/


//Q: only two bits should be flipped

class bit_flip_constraint;
	rand bit [31:0] curr_val;
		 bit [31:0] prev_val;
  
	constraint flip_two_bits {
	  $countones(curr_val ^ prev_val) == 2;
	}
endclass


//Q: how to determine the strobe bit based on the aligned address or not 

if((awaddr % bytes_per_beat) == 0) begin
	for(int j = 0; j < bytes_per_beat; j++) begin
		strobe_bit = (offset_bit + j) % data_size_in_bytes;
		wstrb[strobe_bit] = 1'b1;
	end
	end
	//unaligned address
	else begin
		for(int j = 0; j < aligned_addr + bytes_per_beat; j++) begin
			strobe_bit = (offset_bit+j)%data_size_in_bytes;
			wtrb[strobe_bit] = 1'b1;
		end
	
end

offset_bit = awaddr % data_size_in_bytes;
aligned_addr = awaddr - (awaddr % bytes_per_beat); //nearest aligned address
//assume data_size_in_bytes is 8 and bytes_per_beat is 4 - awsize = 2


/////////////////////////////////////////////////////////////////////////////
//clocking blocks and modports
/*
 	What is a Clocking Block? (Quick Recap)

	In SystemVerilog, a clocking block is used to:
	•	Synchronize signal access (driving and sampling) with a specific clock edge (e.g., posedge aclk).
	•	Avoid race conditions between testbench components and DUT.
	•	Provide clarity on direction (input/output) and timing (when a signal should be driven/sampled).
	
	why do we need modports then:

	You can’t just use a clocking block out of nowhere.
	This is where modports come in.
	modport master_mod(clocking master_drv);
	Anyone using master_mod has access to the master_drv clocking block.
	
	modports can be used either by declaring individual signals with direction, or by binding to a clocking block to bundle timing and direction together.

	You use modports to formally define who sees what.
    You use clocking blocks to control when and how signals are seen.

	 Clocking blocks ≠ visible outside interface
     Modports = “gatekeepers” that expose clocking blocks to the outside world

*/

	modport master_mod(clocking master_drv);

	clocking master_drv @(posedge clk);
		input awready;
		output awaddr, awvalid, awcahche, awprot, awlock;
	endclocking

///////////////////////////////////////////////////////////////////////////////////////

//Functional coverage

/*
	Covergroup: A container for collecting functional coverage.
	•	Coverpoint: Focuses on a single signal/variable. Tracks whether its possible values (bins) are hit.
	•	Explicit bins:
		•	Used when signal value range is large or non-uniform.
		•	Can group values into ranges or exclude some (with ignore_bins).
		•	Allows more meaningful coverage metrics than default auto-binning.
	•	Crosses: Track combinations of multiple coverpoints — useful for scenarios where interaction matters (e.g., opcode vs state).

	.   Let’s say you’re verifying a processor pipeline and want to know:
	•	opcode of the instruction (e.g., ADD, LOAD, BRANCH)
	•	state of the pipeline (e.g., IDLE, FETCH, EXECUTE)
		Now your simulator will generate a 2D coverage matrix:
		•	Rows: opcode values
		•	Columns: state values
		•	Each cell: “Was this (opcode, state) combo hit?”
	I use ignore_bins in cross coverage to clean up coverage reports and focus only on meaningful or legal scenarios — especially in protocols where partial handshakes are irrelevant
*/

///////////////////////////////////////////////////////////////////////////////////////

//subscriber

/*
		•	You can just log, but you can do a lot more if needed.
		•	If you only care about checking correctness → use a scoreboard.
		•	If you care about observability, logging(Printing or recording transactions), storing tx into queue, and collect coverage → use a subscriber.

		“A uvm_subscriber already has an analysis_export inside, so it can directly connect to a monitor’s analysis port without declaring any ports. 
		That makes it really lightweight and easy for coverage or logging.

		On the other hand, a uvm_scoreboard is a plain uvm_component, so I have to explicitly declare uvm_analysis_imp or 
		use a uvm_tlm_analysis_fifo to collect DUT outputs or predicted data. 
		That gives me more control for modeling expected vs actual comparisons.
	
		why is subscriber not preferred choice for scoreboard?

		A uvm_subscriber can perform simple checking, but it is primarily intended for observation, coverage, and logging.
		because It provides a single built-in analysis export and write() interface.
		A scoreboard is better suited for functional checking because it often requires multiple anaysis export or multiple transaction streams,
		queues, reference models, and expected-versus-actual comparisons.
		While a subscriber can be extended to do these tasks, a scoreboard is the more appropriate and scalable architecture

*/

class my_sub extends uvm_subscriber #(packet);
	`uvm_component_utils(my_sub)

	//function new

	int txn_count = 0;
	packet master0_q[$];
	packet master1_q[$];

	//coverage group
	covergroup cov;
		option.per_instance = 1;

		coverpoint tr.src;
		coverpoint tr.dest;

		cross tr.src, tr.dest;
	endgroup

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cov = new();
	endfunction

	virtual function void write(packet tr);
		txn_count++;
		//1. Log transaction
		`uvm_info("SUBSCRIBER", $sformatf("Transaction count: %0d", txn_count), UVM_MEDIUM);

		//2. Store in queue based on src
		case(tr.src)
			2'b00: master0_q.push_back(tr);
			2'b01: master1_q.push_back(tr);
			default: `uvm_info("SUBSCRIBER", $sformatf("Unknown src: %0d", tr.src), UVM_MEDIUM);
		endcase

		//3. collect coverage
		cov.sample(tr);

		//4. small correctness verification like size
		if(tr.data.size() != tr.length) begin
			`uvm_error()
		end

		 // 5. Latency calculation
		time latency = $time - tr.created_time;
		`uvm_info("SUBSCRIBER", $sformatf("Latency: %0t", latency), UVM_LOW)

		// Summary report
		function void report_phase(uvm_phase phase);
			`uvm_info("SUBSCRIBER", $sformatf("Total transactions: %0d", txn_count), UVM_LOW)
			`uvm_info("SUBSCRIBER", $sformatf("Master0 transactions: %0d", master0_q.size()), UVM_LOW)
			`uvm_info("SUBSCRIBER", $sformatf("Master1 transactions: %0d", master1_q.size()), UVM_LOW)
		endfunction
	endfunction
endclass

///////////////////////////////////////////////////////////////////////////////////////

//Q: difference between new[] and new()
/*
	new[] - is used to allocate memory for a dynamic array in SystemVerilog. 
			It can also be used to resize a dynamic array. 
			Using new[size](old_array) resizes the array while copying the existing elements into the new array.
	new() - constructor function used to create object of a class
*/

//Q: Assume the array is having a fixed size of 5 how to make it to store 8 values without missing the old values in static array

int arr[];
arr = new[5];        // allocate

arr = new[10];       // resize, old data lost

arr = new[10](arr);  // resize, old data preserved

transaction tr;
tr = new();

/////////////////////////////////////////////////////////////////////////////////////

//Q: Shallow copy vs deep copy with example

//u can understand the deep copy and shallow copy as there aren't coping but they are two different ways in creating the second object
//if u create the second object as for example tr2=new tr1; now the handlers only in object1 will get copied inised object1,if u create it in normal way like tr2=new();u will get two completely different objects even there r handlers.

/*
	Shallow:
	•	Only one nested object exists in memory.
	•	Only the instance handles (references) are copied — not the actual nested object.
	•	This means:
		Any changes made to the nested object via the copied object (e.g., tr2.err_tr) will also reflect in the original object (e.g., tr1.err_tr), and vice versa.
	•	Why?
		Because both tr1.err_tr and tr2.err_tr are pointing to the same object in memory.

	transaction tr1, tr2;
		tr1 = new();
		tr2 = new tr1; //we are directly copying the entire handle so both point to same object

	To truly separate the nested object, a deep copy must be used 
	where a new object is created and values are copied manually.

	✅ Deep Copy
	•	A new nested object is created in memory.
	•	All values — including those inside nested objects — are copied manually, not just the handles.
	•	This means:
		Any changes made to the nested object in the copied object (e.g., tr2.err_tr) will NOT affect the original object (e.g., tr1.err_tr), and vice versa.
	•	Why?
		Because tr1.err_tr and tr2.err_tr are pointing to different objects in memory.
	
		transaction tr1, tr2;
		tr1 = new();
		tr2 = new();
		tr2.deep_copy(tr1);
	
	•	deep is an independent clone, so it stays unchanged.
*/

//shallow copy example
class error_trans;
	bit [31:0] err_data;
	bit error;
	
	function new(bit [31:0] err_data, bit error);
	  this.err_data = err_data;
	  this.error = error;
	endfunction
endclass
  
class transaction;
	bit [31:0] data;
	int id;
	error_trans err_tr;
	
	function new();
	  data = 100;
	  id = 1;
	  err_tr = new(32'hFFFF_FFFF, 1);
	endfunction
	
	function void display();
	  $display("transaction: data = %0d, id = %0d", data, id);
	  $display("error_trans: err_data = %0h, error = %0d\n", err_tr.err_data, err_tr.error);
	endfunction
  	endclass
  
  	module shallow_copy_example;
	transaction tr1, tr2;
	
	initial begin
	  tr1 = new();
	  $display("Calling display method using tr1");
	  tr1.display();
	  
	  tr2 = new tr1;
	  $display("After shallow copy tr1 --> tr2");
	  $display("Calling display method using tr2");
	  tr2.display();
	  $display("--------------------------------");
	  
	  tr1.data = 200;
	  tr1.id = 2;
	  tr1.err_tr.err_data = 32'h1234;
	  tr1.err_tr.error = 0;
	  
	  $display("Calling display method using tr1");
	  tr1.display();
	  $display("Calling display method using tr2");
	  tr2.display();
	  
	end
endmodule

  //output:
  	/*
		Calling display method using tr1
		transaction: data = 100, id = 1
		error_trans: err_data = ffffffff, error = 1

		After shallow copy tr1 --> tr2
		Calling display method using tr2
		transaction: data = 100, id = 1
		error_trans: err_data = ffffffff, error = 1

		--------------------------------
		Calling display method using tr1
		transaction: data = 200, id = 2
		error_trans: err_data = 1234, error = 0

		Calling display method using tr2
		transaction: data = 100, id = 1
		error_trans: err_data = 1234, error = 0
	*/

class error_trans;
		bit [31:0] err_data;
		bit error;
		
		function new(bit [31:0] err_data, bit error);
		  this.err_data = err_data;
		  this.error = error;
		endfunction
	  endclass
	  
	  class transaction;
		bit [31:0] data;
		int id;
		error_trans err_tr;
		
		function new();
		  data = 100;
		  id = 1;
		  err_tr = new(32'hFFFF_FFFF, 1);
		endfunction
		
		function void display();
		  $display("transaction: data = %0d, id = %0d", data, id);
		  $display("error_trans: err_data = %0h, error = %0d\n", err_tr.err_data, err_tr.error);
		endfunction
		
		function deep_copy(transaction tr);
		  this.data = tr.data;
		  this.id = tr.id;
		  this.err_tr.err_data = tr.err_tr.err_data;
		  this.err_tr.error = tr.err_tr.error;
		endfunction
	  endclass
	  
	  module deep_copy_example;
		transaction tr1, tr2;
		
		initial begin
		  tr1 = new();
		  $display("Calling display method using tr1");
		  tr1.display();
		  
		  tr2 = new();
		  tr2.deep_copy(tr1);
		  $display("After deep copy tr1 --> tr2");
		  $display("Calling display method using tr2");
		  tr2.display();
		  $display("--------------------------------");
		  
		  tr1.data = 200;
		  tr1.id = 2;
		  tr1.err_tr.err_data = 32'h1234;
		  tr1.err_tr.error = 0;
		  
		  $display("Calling display method using tr1");
		  tr1.display();
		  $display("Calling display method using tr2");
		  tr2.display();
		  
		end
endmodule

/*
	Calling display method using tr1
	transaction: data = 100, id = 1
	error_trans: err_data = ffffffff, error = 1

	After deep copy tr1 --> tr2
	Calling display method using tr2
	transaction: data = 100, id = 1
	error_trans: err_data = ffffffff, error = 1

	--------------------------------
	Calling display method using tr1
	transaction: data = 200, id = 2
	error_trans: err_data = 1234, error = 0

	Calling display method using tr2
	transaction: data = 100, id = 1
	error_trans: err_data = ffffffff, error = 1
*/



///////////////////////////////////////////////////////////////////////////////////////

//Q: how does OOP concept add benefit in verification

/*
	Object oriented programming introduce the concept of class and object in systmverilog 
	that provides : inheritance, polymorphism, data encapsulation and hiding, code readability
*/

/////////////////////////////////////////////////////////////////////////////////////

//Q: what are super and this keywords

/*
	super - generally used in child class or derived class to refer to the class members of its base class
	this - refers to properties or methods of the current class 
*/

/////////////////////////////////////////////////////////////////////////////////////////

//polymorphism example

	//Both base and child class should have the same number of arguments otherwise, a compilation error is expected.

	class parent_trans;
		bit [31:0] data;
		int id;
		
		function void display();
			$display("Base: Value of data = %0h and id = %0h", data, id);
		endfunction
		endclass

		class child_trans extends parent_trans;
		function void display();
			$display("Child: Value of data = %0h and id = %0h", data, id);
		endfunction  
		endclass

		module class_example;
		initial begin
			parent_trans p_tr;
			child_trans c_tr;
			c_tr = new();
			
			p_tr = c_tr;
			p_tr.data = 5;
			p_tr.id = 1;
			p_tr.display();
		end
		endmodule

		//output: Base: Value of data = 5 and id = 1

		class parent_trans;
		bit [31:0] data;
		int id;
		
		virtual function void display();
			$display("Base: Value of data = %0d and id = %0d", data, id);
		endfunction
		endclass

		class child_trans extends parent_trans;
		bit [31:0] data;
		int id;
		function void display();
			$display("Child: Value of data = %0d and id = %0d", data, id);
		endfunction  
		endclass

		module class_example;
		initial begin
			parent_trans p_tr;
			child_trans c_tr;
			c_tr = new();
			
			p_tr = c_tr;
			c_tr.data = 10;
			c_tr.id = 2;
			
			p_tr.data = 5;
			p_tr.id = 1;
			p_tr.display();
		end
	endmodule

	//output: Child: Value of data = 10 and id = 2


////////////////////////////////////////////////////////////////////////////////////////

//Q: scope resolution operator example

//The scope resolution operator (::) is used to access class-scoped members such as static variables,
// static methods, enum values, and package members. In this example, transaction::id and transaction::disp() access
// the static variable and static function that belong to the transaction class rather than any specific object instance.
//The scope resolution operator (::) is used to access enum literals that are defined inside a class, package, or other scope. For example, if an enum is declared inside class transaction,
// values such as IDLE or BUSY can be referenced as transaction::IDLE and transaction::BUSY.
	class transaction;

			bit [31:0] data;
			static int id;

			static function disp(int id);
				$display("Value of id = %0d", id);
			endfunction
		endclass

		module example;
			initial begin
				transaction tr = new();
				transaction::id = 5;
				transaction::disp(transaction::id);
			end
	endmodule

////////////////////////////////////////////////////////////////////////////////////////

//Q: Abstract class
	/*
		An abstract class in SystemVerilog is a class that contains at least one pure virtual method. 
		It acts as a base or template class and cannot be instantiated. Child classes must implement the pure virtual methods. 
		This is useful for enforcing interface consistency and enabling polymorphism.
	*/
	virtual class parent_trans;
		bit [31:0] data;
		int id;
		
		pure virtual function void display();
	  endclass
	  
	  class child_trans extends parent_trans;
		function void display();
		  $display("Child: Value of data = %0h and id = %0h", data, id);
		endfunction  
	  endclass
	  
	  module class_example;
		initial begin
		  parent_trans p_tr;
		  child_trans c_tr;
		  c_tr = new();
		  
		  p_tr = c_tr;
		  p_tr.data = 5;
		  p_tr.id = 1;
		  p_tr.display();
		end
	endmodule

////////////////////////////////////////////////////////////////////////////////////////

//Q: Virtual function

	class parent_trans;
		bit [31:0] data;
		int id;
		
		virtual function void display();
		  $display("Base: Value of data = %0d and id = %0d", data, id);
		endfunction
	  endclass
	  
	  class child_trans extends parent_trans;
		bit [31:0] data;
		int id;
		function void display();
		  $display("Child: Value of data = %0d and id = %0d", data, id);
		endfunction  
	  endclass
	  
	  module class_example;
		initial begin
		  parent_trans p_tr;
		  child_trans c_tr;
		  c_tr = new();
		  
		  p_tr = c_tr;
		  c_tr.data = 10;
		  c_tr.id = 2;
		  
		  p_tr.data = 5;
		  p_tr.id = 1;
		  p_tr.display();
		end
	endmodule

	//output: Child: Value of data = 10 and id = 2

//////////////////////////////////////////////////////////////////////////////


//Q: Difference between virtual and physical interface

	/*
	physical interface has all the signals, clocking blocks and modports which are basically static in nature.
	This will help in connecting our testbench with the DUT. But Testbench is dynamic in nature
	In order to connect this static and dynamic parts we use a virtual interface which is basically a handler.
	So now our testbench can driver and sample the signals without being fixed to the static signals.
	*/

//////////////////////////////////////////////////////////////////////////////

//Q: abstract class vs virtual class

	/*
		A virtual class is a base class used for polymorphism and cannot be instantiated. 
		If the virtual class contains pure virtual functions/tasks,it behaves like an abstract class 
		because derived classes are forced to implement those methods before they can be instantiated.
	*/

//////////////////////////////////////////////////////////////////////////////


//Q: Code coverage vs functional coverage 
	/*
		For code coverage, I don’t need to add anything in the code itself, but I must enable it in the simulator using options like -cm in VCS. 
		For functional coverage, I need to write covergroups, define coverpoints and crosses, and sample them during simulation.

		Code coverage deals with covering design code metrics. 
		It tells how many lines of code have been exercised w.r.t. block, expression, FSM, signal toggling.

		Functional coverage deals with covering design functionality or feature metrics. 
		It is a user-defined metric that tells about how much design specification or functionality has been exercised.

		Types of Code Coverage:

		Block coverage – To check how many lines of code have been covered.
		Expression coverage – To check whether all combinations of inputs have been driven to cover expression completely.
		FSM coverage – To check whether all state transitions are covered.
		Toggle coverage – To check whether all bits in variables have changed their states.
	*/

///////////////////////////////////////////////////////////////////////////////////

//Q: Types of array?

    /*
		Fixed size array: Array size is fixed here like in static array
		Dynamic size array: An array whose size can be changed during run time.
		Associative array: Associative array is used when size is not known. Dict format using key value pair storage.
			It doesn't preserve the order of storage. accessing element of this is O(1).
			
		dynamic array:

		int array[];
		array = new[5];
		array = new[8] (array);
	*/
	
	//static array (fixed size):
	module fixed_array_example;
			int arr[5];

			initial begin
				foreach(arr[i])
					arr[i] = i*10;
				
				//display the values
				$display("Fixed-Size array");
				foreach(arr[i])
					$display("arr[%0d] = %0d",i, arr[i]);
			end
		endmodule

		//Dynamic array: size is not known at compile time. you can allocate the space using new[]

		module dynamic_array_example;
			int dyn_array[];

			initial begin
				dyn_array = new[4];

				foreach(dyn_array[i])
					dyn_array[i] = i + 1;
				
				$display("Dynamic Array");
				foreach(dyn_array[i])
					$display("dyn_arr[%0d] = %0d", i, dyn_array[i]);
			end
		endmodule

		//Associative array: like distionary uses key value pair
		module associative_array;
			int associative_array[string]; //associative array with string keys

			initial begin
				associative_array["one"] = 1;
				associative_array["two"] = 2;
				associative_array["three"] = 3;

				$display("Associative array")
				foreach(associative_array[key])
					$display("%s, %0d", key, associative_array[key]);
			end
		endmodule

		//Associative array operations:

		module assoc_array_methods;
			int assoc_arr[string];

			initial begin
				assoc_arr["one"] = 1;
				assoc_arr["two"] = 2;
				assoc_arr["three"] = 3;

				foreach(assoc_arr[key])
					$display("assoc_arr[%s] = %0d",key, assoc_arr[key]);

				//check if a key exist
				if(assoc_arr.exists("one"))
					$display("", assoc_arr["one"]);
				else
					$display("Key 'One' does not exist");
				
				//delete a key
				assoc_arr.delete("one");
			end
	endmodule
//////////////////////////////////////////////////////////////////////

//function in constraint example

class seq_item;
	rand bit [5:0] value;
	rand bit sel;

	constraint c1 {
		value == get_values(sel);
	}

	function bit [5:0] get_values(bit sel);
		return (sel == 0) ? 20: 10;
	endfunction
	endclass

	module tb;
	seq_item seq;
	initial begin
		seq = new();
		seq.randomize();
	end
endmodule

///////////////////////////////////////////////////////////////////////

//Q: skew in clocking blocks

	//input #2 means input can be sampled 2ns before the clock edge
	//output #3 means output can be sampled 3ns after the clock edge
	clocking cb @(negedge clk);
		default input #2 output #3;
		 input ...
		 output ...
	endclocking
///////////////////////////////////////////////////////////////////////

//Q: Assertions:

	/*
		Assertions are like conditional checks.
		Types: Immediate assertions, Concurrent assertions.
		Immediate assertions: These are the assertions that checks at the current simulation time
		Concurrent assertions: these are the assertions that checks the sequence of events spread over multiple clock cycles.
		
	*/

///////////////////////////////////////////////////////////////////////

//Q: Difference between $strobe, $monitor , $write ,and $display

	/*
		$display: to display the messeages or expressions immedietly in the 
				Active Region
		$monitor: to monitor the signal in real time (upon the signal changes)
				Postpone Region
		$write: similar to display but will not append the new line.
				Active region
		$strobe: To display the messages(strings) or expressios at the end of current time slot
				Postpone Region

	*/

///////////////////////////////////////////////////////////////////////


//Q: Transition bins

	module func_coverage;
		
		covergroup c_group:
			//single value transition
			coverpoint data {
				bins b1 = (2 => 5);
				bins b2 = (2 => 10);
				bins b3 = (3 => 8);
			}

			//sequence of transitions
			coverpoint data {
				bins b1 = (2 => 5 => 6);
				bins b2 = (2 => 10 => 12);
				bins b3 = (3 => 8 => 9 => 10);
			}

			//set of transitions
			coverpoint data {
				bins b1[] = (2,3 => 4, 5);
			}
			//It creates 4 bins: 2 => 4, 2=> 5, 3 => 4, 3 => 5

			//consecutive repetition
			coverpoint data {
				bins b1[] = (4[*3]);
			}
			//4[*3] is equivalent to 4 => 4 => 4

			//range of repetition
			coverpoint data {
				bins b1[] = (4[*2:4]);
			}
			//4[*2:4] is equivalent to 4 => 4, 4 => 4 => 4, 4 => 4 => 4 => 4

			//ignore bins
			coverpoint addr {
				ignore_bins b1 = {1,10, 12};
				ignore_bins b2 = (2 => 3 => 9);
			}
		endgroup
	endmodule

//Q: Pre Randomize vs Post Randomize

	/*
		pre randomize: It is used to do an activity just before randomization. 
		This may involve disabling constraint for a particular variable

		Post randomize: It is used to do an activity after randomization. 
		This may involve printing randomized values of a class variable. 
		Override the randomized value of a class variable.

	*/
	class seq_item;
		rand bit [7:0] val1;
		rand bit [7:0] val2;
	   
		constraint val1_c {val1 > 100; val1 < 200;}
		constraint val2_c {val2 > 5; val2 < 8;}
		
		function void pre_randomize();
		  $display("Inside pre_randomize");
		  val2_c.constraint_mode(0);
		endfunction
		
		function void post_randomize();
		  $display("Inside post_randomize");
		  //you can perform push_back to queue or assign values to array using a for or foreach
		  $display("val1 = %0d, val2 = %0d", this.val1, this.val2);
		endfunction
		
	  endclass
	  
	  module constraint_example;
		seq_item item;
		
		initial begin
		  item = new();
		  item.randomize();
		end
	endmodule

//Q: Bidirectional constraints

	/*
		Bidirectional constraints are used to specify a relationship between two or more variables or signals 
		where one variable value has a dependency on other variables.
	*/

//Q: is it possible to override existing constraints
	/*
		Inline constraint: An inline constraint is written on calling a randomize() method using the “with” keyword.
		
		Inheritance : Constraint blocks for a parent class can be overridden by its child class. 
		Thus, the inherited class can modify constraints based on the requirement.
		 To do the same, constraint block nomenclature must be the same.
	*/

	//inline constraint
	//but u should not conflict the overriden constraints.if u want to conflict u should use soft keyword
	class seq_item;
		rand bit [7:0] val1, val2;
	   
		constraint val1_c {val1 > 100; val1 < 200;}
		constraint val2_c {val2 > 5; val2 < 80;}
	  endclass
	  
	  module constraint_example;
		seq_item item;
		
		initial begin
		  item = new();
		  
		  repeat(5) begin
			item.randomize();
			$display("Before inline constraint: val1 = %0d, val2 = %0d", item.val1, item.val2);
				 
			item.randomize() with {val1 > 150; val1 < 160;};
			item.randomize() with {val2 inside {[10:15]};};
			$display("After inline constraint: val1 = %0d, val2 = %0d", item.val1, item.val2);
		  end
		end
	endmodule

	//inheritance
	class parent;
		rand bit [5:0] value;
		constraint value_c {value > 0; value < 10;}
	  endclass
	  
	  class child extends parent;
		constraint value_c {value inside {[10:30]};}
	  endclass
	  
	  module constraint_inh;
		parent p;
		child c;
		
		initial begin
		  p = new();
		  c = new();
		  repeat(3) begin
			p.randomize();
			$display("Parent class: value = %0d", p.value);
		  end
		  
		  repeat(3) begin
			c.randomize();
			$display("Child class: value = %0d", c.value);
		  end
		end
	endmodule

//Q: DPI, export and import
	/*
		allows users to establish communication between external language and SystemVerilog.
		Basically you can call the functions and tasks from the external language.
		•	import "DPI-C" — calling a C function from SystemVerilog
		•	export "DPI-C" — calling a SystemVerilog function from C
	*/

	//clang file
	#include <stdio.h>

	void addition(int a, int b)
	{
	    printf("C: Addition of %d and %d is %d\n",a, b, a+b);
	}


	//sv file
	module tb;

	   import "DPI-C" function void addition(int a, int b);

	   initial begin

	      $display("SV: Before calling C function");

	      addition(3,4);

	      $display("SV: After calling C function");

   		end

endmodule

		//////////////Export example
		//clang file

		#include <stdio.h>

			/* SV function prototype */
			extern void addition(int a, int b);

			void c_caller(int a, int b)
			{
			    printf("C: Calling SV function\n");

			    addition(a,b);

			    printf("C: Returned from SV function\n");
			}

		//sv file

module tb;

		   export "DPI-C" function addition;

		   import "DPI-C" function void c_caller(int a, int b);

		   function void addition(int a, int b);

		      $display("SV: Addition of %0d and %0d is %0d",
		               a, b, a+b);

		   endfunction

		   initial begin
		      c_caller(3,4);
		   end

endmodule


//Q: Implication operator

	/*
		It is used to check the condition of antecedent and consequent(RHS)
		- Overlapping Implecation (|->), same clock edge evaluation
		- Non-Overlapping Implecation (|=>), N=next clock cycle evaluaiton
	*/

//Q: What all bins are generated by the following code

	coverpoint addr {
		bins b1 = {1, 10, 12};
			bins b2[] = {[2:9], 11};
			bins b3[4] = {0:8};
	}
	//Total 14 bins= b1 - 1 bin, b2 - 9 bins, b3 - 4 bins

//Q: randc functionality in systemVerilog

	module tb;
		bit [2:0] data; //0-7 values can be represented
		bit [7:0] mask = 0;

		function bit [2:0] my_randc;
			while(1) begin
				data = $random;
				if(!mask[data]) begin
					mask[data] = 1;
					return data;
				end
				else if(&mask) begin
					mask = 0;
					mask[data] = 1;
					break;
				end
			end
			return data;
		endfunction

		initial begin
			repeat(3) begin
				$display("data = %0d", my_randc());
			end
		end
	endmodule

//Q: randomization without using rand and randc

	std::randomize(value) with {
		value inside {5, 10, 15, 20};
	};

//Q: Functionality of interrupts

	covergroup cg;
		option.per_instance = 1;

		coverpoint intr {
			bins b1 = (0 => 1 => 0);
		}
	endgroup

//Q: Code coverage is 100% but functional coverage is low

/*
	100% code coverage means every line and branch was executed, but it doesn't 
	mean the stimulus has covered all the intended functionality.
	corner cases might be missing.

	If you have a signal of large size and it covers wide range of values
	but the design may not support certain values.
	so functional coverage implemented for a feature but those
	are not supported by the design now.
*/

//Dut
module mux2x1(input logic sel, input logic a, b, output logic y);
	always_comb begin
	  if (sel)
		y = b;
	  else
		y = a;
	end
  endmodule

  initial begin
	a = 1; b = 0;
	sel = 0; #10;
	sel = 1; #10;
  end
  covergroup mux_cov;
	coverpoint sel;
	coverpoint a;
	coverpoint b;
	cross sel, a, b;
endgroup

module alu(input logic [1:0] op, input logic [7:0] a, b, output logic [7:0] result);
	always_comb begin
	  case (op)
		2'b00: result = a + b;
		2'b01: result = a - b;
		default: result = 8'hFF; // unsupported ops
	  endcase
	end
  endmodule

  initial begin
	a = 10; b = 5;
	op = 2'b00; #10;
	op = 2'b01; #10;
  end

  covergroup alu_cov;
	coverpoint op {
	  bins add = {2'b00};
	  bins sub = {2'b01};
	  bins mul = {2'b10};  // Not supported in DUT
	  bins div = {2'b11};  // Not supported in DUT
	}
endgroup

//Q: Code coverage is low but functional coverage is 100%

/*
	Functional coverage is 100% means either you might have missed
	to cover certain features inside the covergroup
	or 
	If all the funtional coverage is properly implemented we can
	improve the code coverage by adding new stimulus or updating existing 
	stimulus because at the moment all the lines or branches of the code
	is not executed.
*/


module mux4x1(input logic [1:0] sel, input logic [3:0] in, output logic out);
	always_comb begin
	  case (sel)
		2'b00: out = in[0];
		2'b01: out = in[1];
		2'b10: out = in[2];
		2'b11: out = in[3];  // 👈 This case might never execute
	  endcase
	end
  endmodule

  covergroup mux_cov;
	coverpoint sel {
	  bins all_sel[] = {[0:2]};  // Only covering sel = 0, 1, 2
	}
  endgroup

  initial begin
	repeat (10) begin
	  sel = $urandom_range(0, 2);  // 👈 Never sets sel = 3
	end
end

//Q: glitch detection assertion
// 	Glitch Detection Concept

// We say:

// "If signal changes again too quickly,
// it is probably a glitch."

// Compare With Edge-Specific Events
// Event	Triggers On
// @(signal)	any change
// @(posedge signal)	only 0 → 1
// @(negedge signal)	only 1 → 0
// For Glitch Detection

// We usually want:

// every transition

// because glitches can be:

// short HIGH pulse
// short LOW pulse

// So both edges matter.

	time min_duration = 50ns;
	realtime first_change;

	assert property (@(signal) (1, first_change = $real_time) |=>/* means at the next transition of the signal*/ ($real_time - first_change) >= min_duration);

	/*Good Case

First change:

100ns

Second change:

180ns

Difference:

80ns

Check:

80ns >= 50ns

TRUE ✅

No glitch.

Glitch Case

First change:

100ns

Second change:

120ns

Difference:

20ns

Check:

20ns >= 50ns

FALSE ❌

Glitch detected.*/

//Q: Virtual sequence and virtual sequencer
	// Virtual Sequence:A sequence that controls other sequences across multiple sequencers.
	// Virtual Sequencer:A sequencer that contains handles to multiple physical sequencers.

//Q:  Synchronous FIFO vs ASynchronous FIFO


	//Synchronous FIFO uses one clock for both read/write,
//while asynchronous FIFO uses separate clocks and requires
//Gray-code pointer synchronization for safe CDC operation.


//Q: write coverpoint where only even header and odd payload should be covered

rand bit [7:0]  payload;
rand bit [15:0] header;

covergroup cg;
	coverpoint:payload{
		bins even_payload[] = {[0:256] } with (item %2 = 0);
	}
	coverpoint:header{
		bins odd_header[] = {[0:65536] } with (item % 2 = 1);
	}
endgroup : cg


//Q: How do you print all indexes of an associative array?
string idx;

if (aa.first(idx))
   do
      $display("Index=%s", idx);
   while (aa.next(idx));
