class spn_monitor extends uvm_monitor;
  `uvm_component_utils(spn_monitor)

  virtual spn_if vif;
  uvm_analysis_port #(spn_seq_item) mon_analysis_port;

  function new (string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_analysis_port = new("mon_analysis_port", this);
    if (!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ",
                           get_full_name(), ".vif"});
  endfunction

  // ---------------------------------------------------------------
  task run_phase(uvm_phase phase);
    spn_seq_item pkt;
    forever begin
      // forward result only when VALID matches the opcode
      @(vif.MONITOR.monitor_cb iff
          ((vif.MONITOR.monitor_cb.opcode == 2'b01 &&
            vif.MONITOR.monitor_cb.valid  == 2'b01) ||
           (vif.MONITOR.monitor_cb.opcode == 2'b10 &&
            vif.MONITOR.monitor_cb.valid  == 2'b10)));

      pkt = new;
      pkt.opcode               = vif.MONITOR.monitor_cb.opcode;
      pkt.data_in              = vif.MONITOR.monitor_cb.data_in;
      pkt.symmetric_secret_key = vif.MONITOR.monitor_cb.symmetric_secret_key;
      pkt.data_out             = vif.MONITOR.monitor_cb.data_out;
      pkt.valid                = vif.MONITOR.monitor_cb.valid;

      `uvm_info(get_type_name(),
                $sformatf("Monitor to scoreboard: %s", pkt.convert2string()),
                UVM_LOW);
      mon_analysis_port.write(pkt);
    end
  endtask
endclass
