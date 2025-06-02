class spn_driver extends uvm_driver #(spn_seq_item);
  `uvm_component_utils(spn_driver)

  virtual spn_if vif;

  function new (string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    spn_seq_item req;
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  // ------------------------------------------------------------------
  virtual task drive (spn_seq_item req);
    //--------------------------------------------------------- align to edge
    @(vif.DRIVER.driver_cb);

    // present request
    vif.DRIVER.driver_cb.opcode               <= req.opcode;
    vif.DRIVER.driver_cb.data_in              <= req.data_in;
    vif.DRIVER.driver_cb.symmetric_secret_key <= req.symmetric_secret_key;

    `uvm_info(get_type_name(),
              $sformatf("Driving item: %s", req.convert2string()), UVM_LOW);

    //------------------------------------------------ wait for correct VALID
    unique case (req.opcode)
      2'b01 : wait (vif.DRIVER.driver_cb.valid == 2'b01); // encryption done
      2'b10 : wait (vif.DRIVER.driver_cb.valid == 2'b10); // decryption done
      default : wait (vif.DRIVER.driver_cb.valid == 2'b00 ||
                       vif.DRIVER.driver_cb.valid == 2'b11);
    endcase

    // give DUT one quiet cycle before next request (optional, but nice)
    @(vif.DRIVER.driver_cb);
  endtask
endclass
