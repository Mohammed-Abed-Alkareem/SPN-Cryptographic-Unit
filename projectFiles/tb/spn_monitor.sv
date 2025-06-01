`define MONITOR_IF vif.DRIVER.driver_cb 
class spn_monitor extends uvm_monitor;

  virtual spn_if vif;

  uvm_analysis_port #(spn_seq_item) mon_analysis_port;


  `uvm_component_utils(spn_monitor)

  function new (string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Creating spn_monitor: %s", name), UVM_LOW);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_analysis_port = new("mon_analysis_port", this);

    if(!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  

  virtual task run_phase(uvm_phase phase);
    spn_seq_item trans_collected;
    super.run_phase(phase);
    forever begin
      trans_collected = new
      trans_collected.opcode = vif.MONITOR.opcode;
      trans_collected.data_in = vif.MONITOR.data_in;
      trans_collected.symmetric_secret_key = vif.MONITOR.symmetric_secret_key;
      @(MONITOR_IF);
      trans_collected.data_out = vif.MONITOR.data_out;
      trans_collected.valid = vif.MONITOR.valid;
      `uvm_info(get_type_name(), $sformatf("Monitor Collecting Transaction and sending to scoreboard: %s", trans_collected.convert2string()), UVM_LOW);
      mon_analysis_port.write(trans_collected);
    end 
    
  endtask : run_phase

endclass : spn_monitor
