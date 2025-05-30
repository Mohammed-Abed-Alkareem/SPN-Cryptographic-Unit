
//=========================================================================
// spn_sequence - random stimulus 
//=========================================================================
class spn_sequence extends uvm_sequence#(spn_seq_item);
 
  `uvm_object_utils(spn_sequence)
  
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "spn_sequence");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence: %s", name), UVM_LOW);
  endfunction
  
  `uvm_declare_p_sequencer(spn_sequencer)
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
    repeat(10) begin
    req = spn_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();

    `uvm_info(get_type_name(), $sformatf("Sending item: %s", req.convert2string()), UVM_LOW);

    send_request(req);
    wait_for_item_done();
   end 
  endtask
endclass
//=========================================================================

class spn_sequence_encrypt extends spn_sequence;

  `uvm_object_utils(spn_sequence_encrypt)

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "spn_sequence_encrypt");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_encrypt: %s", name), UVM_LOW);
  endfunction

  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();

      `uvm_do_with(req,{req.opcode == spn_seq_item::ENCRYPT;})
  endtask
endclass

//=========================================================================

class spn_sequence_decrypt extends spn_sequence;

  `uvm_object_utils(spn_sequence_decrypt)

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "spn_sequence_decrypt");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_decrypt: %s", name), UVM_LOW);
  endfunction

  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();

      `uvm_do_with(req,{req.opcode == spn_seq_item::DECRYPT;})
  endtask
endclass

