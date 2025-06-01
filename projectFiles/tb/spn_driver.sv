class spn_driver extends uvm_driver #(spn_seq_item);

  virtual spn_if vif;
  `uvm_component_utils(spn_driver)
    

  function new (string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    spn_seq_item req;
    super.run_phase(phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask : run_phase
  virtual task drive(spn_seq_item req);
  
    @(vif.DRIVER.driver_cb);

    // Drive the request to the interface
    vif.DRIVER.driver_cb.opcode <= req.opcode;
    vif.DRIVER.driver_cb.data_in <= req.data_in;
    vif.DRIVER.driver_cb.symmetric_secret_key <= req.symmetric_secret_key;

    `uvm_info(get_type_name(), $sformatf("Driving item: %s", req.convert2string()), UVM_LOW);
    
    // Wait for DUT to process the transaction (give it two more clock cycle)
    @(vif.DRIVER.driver_cb);
    @(vif.DRIVER.driver_cb);
    
    // For no-op operations, add small delay to let the system settle
    if(req.opcode == 2'b00) begin
      repeat(2) @(vif.DRIVER.driver_cb);
    end
    
  endtask : drive
  
endclass : spn_driver