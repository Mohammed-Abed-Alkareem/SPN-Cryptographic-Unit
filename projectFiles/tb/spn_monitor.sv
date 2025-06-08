class spn_monitor extends uvm_monitor;
  `uvm_component_utils(spn_monitor)

  virtual spn_if vif;
  uvm_analysis_port #(spn_seq_item) mon_analysis_port;

  function new (string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // ============================================================

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the analysis port
    mon_analysis_port = new("mon_analysis_port", this);
    // Get the virtual interface from the config DB
    if (!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ",
                          get_full_name(), ".vif"});
  endfunction : build_phase

  // ============================================================

  task run_phase(uvm_phase phase);
    spn_seq_item trans_collected;
    logic [1:0] prev_valid = 2'b00;
    forever begin
      @(vif.MONITOR.monitor_cb);
      // Detect rising edge of valid (from 00 to non-00)
      if (prev_valid == 2'b00 && vif.MONITOR.monitor_cb.valid != 2'b00) begin
        trans_collected = new;
        trans_collected.opcode               = vif.MONITOR.monitor_cb.opcode;
        trans_collected.data_in              = vif.MONITOR.monitor_cb.data_in;
        trans_collected.symmetric_secret_key = vif.MONITOR.monitor_cb.symmetric_secret_key;
        trans_collected.data_out             = vif.MONITOR.monitor_cb.data_out;
        trans_collected.valid                = vif.MONITOR.monitor_cb.valid;

        `uvm_info(get_type_name(),
                  $sformatf("Monitor to scoreboard: %s", trans_collected.convert2string()),
                  UVM_LOW);
        mon_analysis_port.write(trans_collected);
      end
      prev_valid = vif.MONITOR.monitor_cb.valid;
    end
endtask : run_phase

endclass
