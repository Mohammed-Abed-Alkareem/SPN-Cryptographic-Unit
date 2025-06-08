class spn_model_env extends uvm_env;
  `uvm_component_utils(spn_model_env)

  spn_agent      spn_agnt;
  spn_scoreboard spn_scb;
  

  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(),
      $sformatf("Creating spn_model_env: %s", name), UVM_MEDIUM)
  endfunction : new

  // ============================================================

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the Agent and Scoreboard
    spn_agnt = spn_agent::type_id::create("spn_agnt", this);
    spn_scb  = spn_scoreboard::type_id::create("spn_scb", this);
  endfunction : build_phase

  // ============================================================

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Connect the monitor to the scoreboard
    spn_agnt.monitor.mon_analysis_port.connect(spn_scb.scb_analysis_imp);
  endfunction : connect_phase

endclass : spn_model_env