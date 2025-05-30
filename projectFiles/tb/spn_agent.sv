//-------------------------------------------------------------------------
//						spn_agent 
//-------------------------------------------------------------------------

`include "spn_seq_item.sv"
`include "spn_sequencer.sv"
`include "spn_sequence.sv"
`include "spn_driver.sv"
`include "spn_monitor.sv"

class spn_agent extends uvm_agent;

  //---------------------------------------
  // component instances
  //---------------------------------------
  spn_driver    driver;
  spn_sequencer sequencer;
  spn_monitor   monitor;

  `uvm_component_utils(spn_agent)
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = spn_monitor::type_id::create("monitor", this);

    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      driver    = spn_driver::type_id::create("driver", this);
      sequencer = spn_sequencer::type_id::create("sequencer", this);
    end
  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : spn_agent