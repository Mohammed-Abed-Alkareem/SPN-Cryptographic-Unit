//-------------------------------------------------------------------------
//						spn_env 
//-------------------------------------------------------------------------

`include "spn_agent.sv"
`include "spn_scoreboard.sv"

class spn_model_env extends uvm_env;
  
  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
 spn_agent      spn_agnt;
  spn_scoreboard spn_scb;
  
  `uvm_component_utils(spn_model_env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Creating spn_model_env: %s", name), UVM_MEDIUM)
  endfunction : new

  //---------------------------------------
  // build_phase - crate the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    spn_agnt = spn_agent::type_id::create("spn_agnt", this);
    spn_scb  = spn_scoreboard::type_id::create("spn_scb", this);
  endfunction : build_phase
  
  //---------------------------------------
  // connect_phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    spn_agnt.monitor.item_collected_port.connect(spn_scb.item_collected_export);
  endfunction : connect_phase

endclass : spn_model_env