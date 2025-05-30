//-------------------------------------------------------------------------
//						spn_driver 
//-------------------------------------------------------------------------

`define DRIV_IF vif.DRIVER.driver_cb

class spn_driver extends uvm_driver #(spn_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual spn_if vif;
  `uvm_component_utils(spn_driver)
    
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if(!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task drive();

    @(posedge vif.DRIVER.clk); // < ---- adjust the timing

    // Drive the request to the interface
    `DRIV_IF.opcode <= req.opcode;
    `DRIV_IF.data_in <= req.data_in;
    `DRIV_IF.symmetric_secret_key <= req.symmetric_secret_key;
    `DRIV_IF.data_out <= req.data_out;
    `DRIV_IF.valid <= req.valid;

    `uvm_info(get_type_name(), $sformatf("Driving item: %s", req.convert2string()), UVM_LOW);

  endtask : drive
endclass : spn_driver