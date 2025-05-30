//-------------------------------------------------------------------------
//						mem_write_read_test - www.verificationguide.com 
//-------------------------------------------------------------------------
class spn_test extends spn_model_base_test;

  `uvm_component_utils(spn_test)
  
  //---------------------------------------
  // sequence instance 
  //--------------------------------------- 
  spn_sequence seq;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "spn_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the sequence
    seq = spn_sequence::type_id::create("seq");
  endfunction : build_phase
  
  //---------------------------------------
  // run_phase - starting the test
  //---------------------------------------
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
      seq.start(env.spn_agnt.sequencer);
    phase.drop_objection(this);
    
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);
  endtask : run_phase
  
endclass : spn_test