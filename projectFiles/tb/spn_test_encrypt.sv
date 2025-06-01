`include "spn_sequence.sv"
class spn_encrypt_test extends spn_base_test;

  `uvm_component_utils(spn_test)

  spn_sequence_encrypt seq;

  function new(string name = "spn_encrypt_test",uvm_component parent = null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the sequence
    seq = spn_sequence_encrypt::type_id::create("seq");
  endfunction : build_phase


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
      seq.start(env.spn_agnt.sequencer);
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : spn_test