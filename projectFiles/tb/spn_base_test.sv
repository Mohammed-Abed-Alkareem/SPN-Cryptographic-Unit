`include "spn_env.sv"
class spn_base_test extends uvm_test;
  `uvm_component_utils(spn_model_base_test)
  
  spn_model_env env;
  virtual spn_if vif;

  function new(string name = "spn_model_base_test",uvm_component parent = null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the env
    env = spn_model_env::type_id::create("env", this);

    // Get the virtual interface from the config DB
    if (!uvm_config_db#(virtual spn_if)::get(this, "", "spn_vif", vif))
      `uvm_fatal("TEST", "Did not get vif")
    
      uvm_config_db#(virtual spn_if)::set(this, "*spn_agent.*", "spn_vif", vif);
  endfunction : build_phase
  

  virtual function void end_of_elaboration();
    //print's the topology
    print_topology();
  endfunction

  
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
    
  endfunction 

endclass :spn_model_base_test
