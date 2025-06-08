class spn_base_test extends uvm_test;
  `uvm_component_utils(spn_base_test)
  
  spn_model_env env;
  virtual spn_if vif;

  function new(string name = "spn_base_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction : new

  // ============================================================

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the envrionment
    env = spn_model_env::type_id::create("env", this);    
    // Get the virtual interface from the config DB
    if (!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
      `uvm_fatal("TEST", "Did not get vif")
    // Set the virtual interface in the config DB for other components
    uvm_config_db#(virtual spn_if)::set(this, "*", "vif", vif);
  endfunction : build_phase

  // ============================================================

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    //print's the topology
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  // ============================================================

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    
    svr = uvm_report_server::get_server();
    if(svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
      `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
      `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
      `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
      end
    else begin
      `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
      `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
      `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end

  endfunction : report_phase

endclass :spn_base_test
