class spn_driver extends uvm_driver #(spn_seq_item);
  `uvm_component_utils(spn_driver)

  virtual spn_if vif;

  function new (string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // ============================================================

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Get the virtual interface from the config DB
    if(!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    spn_seq_item req;
    super.run_phase(phase);
    forever begin
      // Set bus to a default idle state before getting the next item
      vif.DRIVER.driver_cb.opcode <= 2'b00; // no_op

      // Wait for the next item from the sequencer
      seq_item_port.get_next_item(req);
      // Drive the request to the interface
      drive(req);
      // Indicate that the item has been processed
      seq_item_port.item_done();
    end
  endtask : run_phase

  // ============================================================
  
  virtual task drive (spn_seq_item req);

    // Wait for the clocking block event to drive inputs
    @(vif.DRIVER.driver_cb);

    // Drive the request to the interface
    vif.DRIVER.driver_cb.opcode               <= req.opcode;
    vif.DRIVER.driver_cb.data_in              <= req.data_in;
    vif.DRIVER.driver_cb.symmetric_secret_key <= req.symmetric_secret_key;

    `uvm_info(get_type_name(),
              $sformatf("Driving item: %s", req.convert2string()), UVM_LOW);

    // Wait one clock cycle. This allows the pipelined DUT to process the inputs.
    // The result will be available on the interface on the following clock edge.
    // This also prevents the driver from sending back-to-back transactions
    // that would corrupt the DUT's pipeline state.
    @(vif.DRIVER.driver_cb);

  endtask : drive

endclass