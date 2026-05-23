import uvm_pkg::*;
`include "uvm_macros.svh"

/*1. Write a UVM testbench that implements a producer and a
consumer using TLM blocking ports. Ensure that the producer
generates 10 integer values, and the consumer retrieves and
logs them.
*/
class producer extends uvm_component;
	
	uvm_blocking_put_port #(int) put_port;

	`uvm_component_utils(producer)

	function new(string name="",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase();
		super.build_phase(phase);
		put_port=new("put_port",this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		
		int data;

		phase.raise_objection(this);

		for (int i = 0; i < 10; i++) begin
			data=i;
			put_port.put(data);
			`uvm_info("PRODUCER",$sformatf("sending data: %0d",data),UVM_LOW)
			#10;
		end

		phase.drop_objection(this);
	endtask : run_phase
endclass : producer

class consumer extends uvm_component;
	
	uvm_blocking_put_imp #(int,consumer) put_export;

	`uvm_component_utils(consumer)

	function new(string name="",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		put_export=new("put_export",this);
	endfunction : build_phase

	task put(int data);
		`uvm_info("CONSUMER",$sformatf("Received data: %0d",data),UVM_LOW)
	endtask : put

endclass : consumer

class my_env extends uvm_env;

	producer p;

	consumer c;
	
	`uvm_component_utils(my_env)

	function new(string name="",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		p= producer::type_id::create("p",this);
		c= consumer::type_id::create("c",this);

	endfunction : build_phase

	virtual function void connect_phase(umv_phase phase);
		p.put_port.connect(c.put_export);
	endfunction : connect_phase
endclass : my_env

class test extends uvm_test;

	my_env env;

	`uvm_component_utils(test)

	function new(string name="",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.builf_phase(phase);
		env = my_env::type_id::create("my_env",this);
	endfunction : build_phase
	
endclass : test

module top;
	intial begin
		run_test("test");
	end
endmodule : top

/*
2. Create a UVM environment where a producer sends data to
two subscribers using analysis ports. Implement the producer to
broadcast 10 data values and verify that both subscribers
receive the data correctly.
*/
class producer extends uvm_component;
	
	uvm_analysis_port #(int) ap;

	`uvm_component_utils(producer)

	function new(string name="",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase();
		super.build_phase(phase);
		ap=new("ap",this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		
		int data;

		phase.raise_objection(this);

		for (int i = 0; i < 10; i++) begin
			data=i;
			ap.write(data);
			`uvm_info("PRODUCER",$sformatf("sending data: %0d",data),UVM_LOW)
			#10;
		end

		phase.drop_objection(this);
	endtask : run_phase
endclass : producer

class subscriber1 extends uvm_subscriber#(int);

	`uvm_component_utils(subscriber1)

	function new(string name="",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		put_export=new("put_export",this);
	endfunction : build_phase

	function void write(int data);
		`uvm_info("subscriber1",$sformatf("Received data: %0d",data),UVM_LOW)
	 		
	 endfunction : write 
endclass : subscriber1

class subscriber2 extends uvm_subscriber#(int);

	`uvm_component_utils(subscriber2)

	function new(string name="",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		put_export=new("put_export",this);
	endfunction : build_phase

	function void write(int data);
		`uvm_info("subscriber2",$sformatf("Received data: %0d",data),UVM_LOW)
	 		
	 endfunction : write 
endclass : subscriber2

class my_env extends uvm_env;

   producer    p;
   subscriber1 s1;
   subscriber2 s2;

   `uvm_component_utils(my_env)

   function new(string name="my_env",
                uvm_component parent=null);

      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      p  = producer   ::type_id::create("p",  this);
      s1 = subscriber1::type_id::create("s1", this);
      s2 = subscriber2::type_id::create("s2", this);

   endfunction

   function void connect_phase(uvm_phase phase);

      // connect producer to BOTH subscribers

      p.ap.connect(s1.analysis_export);

      p.ap.connect(s2.analysis_export);

   endfunction

endclass

class my_test extends uvm_test;
	my_env env;
	`uvm_component_utils(my_test)

   function new(string name="my_test",uvm_component parent=null);
		super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      env = my_env::type_id::create("env", this);

   endfunction

endclass : my_test

module top;

   initial begin
      run_test("my_test");
   end

endmodule

/*
3. Demonstrate how to use the UVM factory mechanism to
override a base sequence with an extended sequence in a
testbench. Ensure that the overridden sequence runs during
the simulation.
*/
class base_seq extends uvm_sequence#(uvm_sequence_item);
	`uvm_object_utils(base_seq)
	function new(string name);
		super.new(name);
	endfunction : new
	task body();
		`uvm_info("BASE_SEQ","running base sequence",UVM_LOW)
	endtask : body
endclass : base_seq

class ext_seq extends base_seq;
	`uvm_object_utils(ext_seq)
	function new(string name);
		super.new(name);
	endfunction : new
	task body();
		`uvm_info("EXT_SEQ","running extended sequence",UVM_LOW)
	endtask : body
endclass : ext_seq

class my_sequencer extends uvm_sequencer#(uvm_sequence_item);
	`uvm_component_utils(my_sequencer)
	function new(string name="",uvm_component parent);
		super.new(name,parent);
	endfunction : new

endclass : my_sequencer

class my_env extends uvm_env;

   my_sequencer seqr;

   `uvm_component_utils(my_env)

   function new(string name="my_env",uvm_component parent=null);

      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);

      super.build_phase(phase);
      seqr= my_sequencer::type_id::create("seqr",this);

   endfunction

endclass

class my_test extends uvm_test;

	my_env env;

	base_seq seq;

	`uvm_component_utils(my_test)

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		
		super.build_phase(phase);
		
		env= my_env::type_id::create("my_env",this);

		base_seq::type_id::set_type_override(ext_seq::get_type());
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);

		seq=base_seq::type_id::create("seq");

		seq.start(env.seqr);

		phase.drop_objection(this);
	endtask : run_phase
endclass : my_test

module top;

   initial begin
      run_test("my_test");
   end

endmodule
/*
4. Implement a UVM testbench where an agent retrieves its
configuration settings from the UVM configuration database.
Set the configuration to specify a data
_
width parameter and
log its value in the agent.
*/

class agent_config extends uvm_object;
	
	int data_width;

	`uvm_object_utils(agent_config)

	function new(string name="");
		super.new(name);
	endfunction : new

endclass : agent_config

class my_agent extends uvm_component;

	agent_config cfg;
	
	`uvm_component_utils(my_agent)

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if (!uvm_config_db#()::get(this, "", "agent_cfg",cfg )) begin
			`uvm_fata("AGENT","failed to get configuration.")
		end

		`uvm_info("AGENT",$sformatf("DATA WIDTH :%0d",cfg.data_width),UVM_LOW)

	endfunction : build_phase

endclass : my_agent

class my_env extends uvm_env;

	my_agent agent;

	`uvm_component_utils(my_env)

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		agent = my_agent::type_id::create("agent",this);
	endfunction : build_phase

	
endclass : my_env

class my_test extends uvm_test;

	my_env env;

	agent_config cfg;

	`uvm_component_utils(my_test)
	
	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		
		super.build_phase(phase);

		env= my_env::type_id::create("env",this);

		cfg.data_width=30;

		uvm_config_db#(agent_config)::set(this, "env.agent", "agent_cfg",cfg );

	endfunction : build_phase

endclass : my_test

module top;

   initial begin
      run_test("my_test");
   end

endmodule
/*
6. In UVM, how would you implement phase jumping to skip
directly to the shutdown phase from the run phase? Provide a
complete example.
*/
class my_test extends uvm_test;

	`uvm_component_utils(my_test)

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);

		`uvm_info("test","inside run phase",UVM_LOW)
		#20ns;

		phase.jump(uvm_shutdown_phase::get());

		phase.drop_objection(this);
	endtask : run_phase

	task shutdown_phase(uvm_phase phase);
		`uvm_info("test","inside shutdown_phase",UVM_LOW)
	endtask : shutdown_phase
endclass : my_test

/*
7. Write a UVM virtual sequence that coordinates two agents.
Each agent must execute a child sequence. Use a fork-join
construct to run the child sequences in parallel.
*/
class seq_agent1 extends uvm_sequence#(uvm_sequence_item);

	`uvm_object_utils(seq_agent1)

	function new(string name);
		super.new(name);
	endfunction : new

	task body();
		`uvm_info("SEQ_AGENT1","running sequence on agent1",UVM_LOW)
		#20ns;
		`uvm_info("SEQ_AGENT1","finished sequence on agent1",UVM_LOW)

	endtask : body
	
endclass : seq_agent1
class seq_agent2 extends uvm_sequence#(uvm_sequence_item);

	`uvm_object_utils(seq_agent2)

	function new(string name);
		super.new(name);
	endfunction : new

	task body();
		`uvm_info("SEQ_AGENT2","running sequence on agent2",UVM_LOW)
		#20ns;
		`uvm_info("SEQ_AGENT2","finished sequence on agent2",UVM_LOW)

	endtask : body
	
endclass : seq_agent2

class virtual_sequencer extends uvm_sequencer;
	
	uvm_sequencer seqr1;

	uvm_sequencer seqr2;

	`uvm_component_utils(virtual_sequencer)

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new

endclass : virtual_sequencer

class virtual_sequence extends uvm_sequence;
	
	seq_agent1 seq1;

	seq_agent2 seq2;

	`uvm_declare_p_sequencer(virtual_sequencer)

	`uvm_object_utils(virtual_sequence)

	function new(string name);
		super.new(name);
	endfunction : new

	task body();

		seq1 = seq_agent1::type_id::create("seq1");
		
		seq2 = seq_agent1::type_id::create("seq2");
	fork
		seq1.start(virtual_sequencer.seqr1);
		seq2.start(virtual_sequencer.seqr2);
	join

	`uvm_info("virtual_sequence","both child sequences completed",UVM_LOW)
	endtask : body

endclass : virtual_sequence

class my_agent extends uvm_component;

	uvm_sequencer#(uvm_sequence_item) seqr;
	
	`uvm_component_utils(my_agent)

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seqr = uvm_sequencer(uvm_sequence_item)::type_id::create("seqr",this);
	endfunction : build_phase

endclass : my_agent

class my_env extends uvm_env;

	my_agent agent1;
	my_agent agent2;
	virtual_sequencer vseqr;

	`uvm_component_utils(my_env)

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		agent1 = my_agent::type_id::create("agent1",this);
		agent2 = my_agent::type_id::create("agent2",this);
		vseqr = virtual_sequencer::type_id::create("vseqr",this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		vseqr.seqr1 = agent1.seqr;
		vseqr.seqr2 = agent2.seqr;
	endfunction : connect_phase
endclass : my_env

class my_test extends uvm_test;

	my_env env;

	virtual_sequence vseq;

	`uvm_component_utils(my_test)
	
	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		
		super.build_phase(phase);

		env= my_env::type_id::create("env",this);


	endfunction : build_phase

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		vseq=virtual_sequence::type_id::create("vseq");
		vseq.start(env.vseqr);
		phase.drop_objection(this);
	endtask : run_phase
endclass : my_test

module top;

   initial begin
      run_test("my_test");
   end

endmodule
/*
8. Design a scoreboard in UVM that compares incoming data
with a predefined golden reference using an analysis FIFO. Log
a mismatch if the data does not match the golden reference.
*/
class scoreboard extends uvm_scoreboard;
	
	`uvm_analysis_tlm_fifo#(my_transaaction) fifo;

	my_transaaction tr;


	bit [7:0] golden_model[$];
	`uvm_component_utils(scoreboard)
	
	function new(string name,uvm_component parent);
		super.new(name,parent);

	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		fifo=new("fifo",this);

		golden_model.pop_back(8'h11);
		golden_model.pop_back(8'h89);
		golden_model.pop_back(8'h13);
		golden_model.pop_back(8'h67);
		golden_model.pop_back(8'h12);

	endfunction : build_phase

	task run_phase(uvm_phase phase);
		bit [7:0] expected_data;
		forever begin
			fifo.get(tr);

			expected_data=golden_model.pop_front();

			 if(tr.data == expected_data) begin

            `uvm_info("SCOREBOARD",$sformatf("MATCH : DUT=%0h GOLDEN=%0h",tr.data,expected_data),UVM_LOW)

         end
         else begin

            `uvm_error("SCOREBOARD",$sformatf("MISMATCH : DUT=%0h GOLDEN=%0h",tr.data,expected_data))

         end

      end
	endtask : run_phase

endclass : scoreboard

/*
11. Write a UVM sequence that generates randomized
transactions. The sequence should randomize a transaction
item and send it to the sequencer. Ensure the randomization
is controlled via a random seed and log the transaction data.
*/

class random_sequence extends uvm_sequence#(packet_transaction);
        `uvm_object_utils(random_sequence)

        function new(string name = "random_sequence");
            super.new(name);
        endfunction

        task body();
            packet_transaction tr;
            tr = packet_transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize());
            finish_item(tr);
        endtask
    endclass

    class top_test extends uvm_test;
        `uvm_component_utils(top_test)

        function new(string name = "top_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            random_sequence seq;
            seq = random_sequence::type_id::create("seq");
            seq.start(env.agent.seqr);
        endtask
endclass
/*
17. Write a UVM testbench that demonstrates the reuse and
chaining of sequences. Sequence A should start after Sequence B completion.
*/

class my_item extends uvm_sequence_item;

   rand bit [7:0] data;

   `uvm_object_utils(my_item)

   function new(string name="my_item");
      super.new(name);
   endfunction

endclass

class seq_B extends uvm_sequence #(my_item);

   `uvm_object_utils(seq_B)

   function new(string name="seq_B");
      super.new(name);
   endfunction


   task body();

      `uvm_info("SEQ_B","Starting Sequence B",UVM_LOW)

      repeat(3) begin

         my_item req;

         req = my_item::type_id::create("req");

         start_item(req);

         assert(req.randomize());

         finish_item(req);

         `uvm_info("SEQ_B",$sformatf("Generated data = %0d",req.data),UVM_LOW)

      end

      `uvm_info("SEQ_B","Sequence B completed",UVM_LOW)

   endtask

endclass

class seq_A extends uvm_sequence #(my_item);

   `uvm_object_utils(seq_A)

   function new(string name="seq_A");
      super.new(name);
   endfunction


   task body();

      `uvm_info("SEQ_A","Starting Sequence A",UVM_LOW)

      repeat(3) begin

         my_item req;

         req = my_item::type_id::create("req");

         start_item(req);

         assert(req.randomize());

         finish_item(req);

         `uvm_info("SEQ_A",$sformatf("Generated data = %0d",req.data),UVM_LOW)

      end

      `uvm_info("SEQ_A","Sequence A completed",UVM_LOW)

   endtask

endclass

class chained_seq extends uvm_sequence #(my_item);

   seq_A a_seq;
   seq_B b_seq;

   `uvm_object_utils(chained_seq)

   function new(string name="chained_seq");
      super.new(name);
   endfunction


   task body();

      b_seq = seq_B::type_id::create("b_seq");

      a_seq = seq_A::type_id::create("a_seq");

      `uvm_info("CHAINED_SEQ","Starting Sequence B",UVM_LOW)

      b_seq.start(m_sequencer);


      `uvm_info("CHAINED_SEQ","Sequence B done -> Starting A",UVM_LOW)

      a_seq.start(m_sequencer);

      `uvm_info("CHAINED_SEQ","Chained sequence completed",UVM_LOW)

   endtask

endclass

class my_sequencer extends uvm_sequencer #(my_item);

   `uvm_component_utils(my_sequencer)

   function new(string name="my_sequencer",uvm_component parent=null);

      super.new(name,parent);

   endfunction

endclass

class my_driver extends uvm_driver #(my_item);

   `uvm_component_utils(my_driver)

   function new(string name="my_driver",uvm_component parent=null);

      super.new(name,parent);

   endfunction


   task run_phase(uvm_phase phase);

      my_item req;

      forever begin

         seq_item_port.get_next_item(req);

         `uvm_info("DRIVER",$sformatf("Driving data = %0d",req.data),UVM_LOW)
         seq_item_port.item_done();

      end

   endtask

endclass

class my_agent extends uvm_agent;

   my_driver    drv;
   my_sequencer seqr;

   `uvm_component_utils(my_agent)

   function new(string name="my_agent",uvm_component parent=null);

      super.new(name,parent);

   endfunction


   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      drv  = my_driver   ::type_id::create("drv",  this);

      seqr = my_sequencer::type_id::create("seqr", this);

   endfunction


   function void connect_phase(uvm_phase phase);

      drv.seq_item_port.connect(seqr.seq_item_export);

   endfunction

endclass

class my_env extends uvm_env;

   my_agent agt;

   `uvm_component_utils(my_env)

   function new(string name="my_env",uvm_component parent=null);

      super.new(name,parent);

   endfunction


   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      agt = my_agent::type_id::create("agt", this);

   endfunction

endclass

class my_test extends uvm_test;

   my_env env;

   chained_seq cseq;

   `uvm_component_utils(my_test)

   function new(string name="my_test",uvm_component parent=null);

      super.new(name,parent);

   endfunction


   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      env = my_env::type_id::create("env", this);

   endfunction


   task run_phase(uvm_phase phase);

      phase.raise_objection(this);

      cseq = chained_seq::type_id::create("cseq");

      cseq.start(env.agt.seqr);

      phase.drop_objection(this);

   endtask

endclass

module top;

   initial begin
      run_test("my_test");
   end

endmodule

/*
18. Write a UVM testbench that implements an analysis FIFO
for passing data between components. The producer generates
data, and the consumer retrieves it using an analysis FIFO.
*/

`include "uvm_macros.svh"
import uvm_pkg::*;


//----------------------------------------------------
// PRODUCER
//----------------------------------------------------

class producer extends uvm_component;

   //-------------------------------------------------
   // ANALYSIS PORT
   //-------------------------------------------------

   uvm_analysis_port #(int) ap;

   `uvm_component_utils(producer)

   function new(string name="producer",
                uvm_component parent=null);

      super.new(name,parent);

   endfunction


   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      ap = new("ap", this);

   endfunction


   //-------------------------------------------------
   // GENERATE DATA
   //-------------------------------------------------

   task run_phase(uvm_phase phase);

      int data;

      repeat(10) begin

         data = $urandom_range(0,100);

         `uvm_info("PRODUCER",
                   $sformatf(
                   "Generated data = %0d",
                   data),
                   UVM_LOW)

         //---------------------------------------------
         // SEND DATA THROUGH ANALYSIS PORT
         //---------------------------------------------

         ap.write(data);

         #10;

      end

   endtask

endclass


//----------------------------------------------------
// CONSUMER
//----------------------------------------------------

class consumer extends uvm_component;

   //-------------------------------------------------
   // ANALYSIS FIFO
   //-------------------------------------------------

   uvm_tlm_analysis_fifo #(int) fifo;

   `uvm_component_utils(consumer)

   function new(string name="consumer",
                uvm_component parent=null);

      super.new(name,parent);

   endfunction


   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      fifo = new("fifo", this);

   endfunction


   //-------------------------------------------------
   // RECEIVE DATA
   //-------------------------------------------------

   task run_phase(uvm_phase phase);

      int recv_data;

      forever begin

         //---------------------------------------------
         // GET DATA FROM FIFO
         //---------------------------------------------

         fifo.get(recv_data);

         `uvm_info("CONSUMER",
                   $sformatf(
                   "Received data = %0d",
                   recv_data),
                   UVM_LOW)

      end

   endtask

endclass


//----------------------------------------------------
// ENVIRONMENT
//----------------------------------------------------

class my_env extends uvm_env;

   producer prod;
   consumer cons;

   `uvm_component_utils(my_env)

   function new(string name="my_env",
                uvm_component parent=null);

      super.new(name,parent);

   endfunction


   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      prod = producer::type_id::create("prod", this);

      cons = consumer::type_id::create("cons", this);

   endfunction


   function void connect_phase(uvm_phase phase);

      //------------------------------------------------
      // CONNECT ANALYSIS PORT TO FIFO
      //------------------------------------------------

      prod.ap.connect(cons.fifo.analysis_export);

   endfunction

endclass


//----------------------------------------------------
// TEST
//----------------------------------------------------

class my_test extends uvm_test;

   my_env env;

   `uvm_component_utils(my_test)

   function new(string name="my_test",
                uvm_component parent=null);

      super.new(name,parent);

   endfunction


   function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      env = my_env::type_id::create("env", this);

   endfunction


   task run_phase(uvm_phase phase);

      phase.raise_objection(this);

      #200;

      phase.drop_objection(this);

   endtask

endclass


//----------------------------------------------------
// TOP
//----------------------------------------------------

module top;

   initial begin
      run_test("my_test");
   end

endmodule

//How to control sequence execution order using arbitration
class high_seq extends uvm_sequence;

    task body();
        `uvm_info()
    endtask
endclass

class low_seq extends uvm_sequence;

    task body();
        `uvm_info()
    endtask
endclass

class arb_test extends uvm_test;

    high_seq s1;
    low_seq s2;

    virtual task run_phase(uvm_phase phase);
        s1 = high_seq::type_id::create("s1");
        s2 = low_seq::type_id::create("s2");

        fork 
            begin
                s1.set_priority(200);
                s1.start(seqr);
            end
            begin
                s2.set_priority(100);
                s2.start(seqr);
            end   
        join
    endtask
endclass

