//-------------------------------------------------------------------------
//						spn_monitor
//-------------------------------------------------------------------------

class spn_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual spn_if vif;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(spn_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
	spn_seq_item trans_collected;

  `uvm_component_utils(spn_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
    `uvm_info(get_type_name(), $sformatf("Creating spn_monitor: %s", name), UVM_LOW);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.MONITOR.clk);  // < ---- adjust the timing

        trans_collected.opcode = vif.MONITOR.opcode;
        trans_collected.data_in = vif.MONITOR.data_in;
        trans_collected.symmetric_secret_key = vif.MONITOR.symmetric_secret_key;
        trans_collected.data_out = vif.MONITOR.data_out;
        trans_collected.valid = vif.MONITOR.valid;

        `uvm_info(get_type_name(), $sformatf("Monitor Collecting Transaction and sending to scoreboard: %s", trans_collected.convert2string()), UVM_LOW);
	      item_collected_port.write(trans_collected);
      end 
    
  endtask : run_phase

endclass : spn_monitor
