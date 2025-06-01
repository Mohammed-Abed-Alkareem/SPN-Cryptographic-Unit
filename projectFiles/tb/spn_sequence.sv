`ifndef SPN_SEQUENCE_SV
`define SPN_SEQUENCE_SV
import spn_cu_pkg::operation_t;
class spn_base_sequence extends uvm_sequence#(spn_seq_item); 
  `uvm_object_utils(spn_base_sequence)

  function new(string name = "spn_base_sequence");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_base_sequence: %s", name), UVM_LOW);
  endfunction
  
  `uvm_declare_p_sequencer(spn_sequencer)
  
  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
    spn_seq_item req;
    repeat(10) begin
      req = spn_seq_item::type_id::create("req");
      start_item(req);
      req.randomize();
      `uvm_info(get_type_name(), $sformatf("Sending item: %s", req.convert2string()), UVM_LOW);
      finish_item(req);
    end 
  endtask
endclass

//=========================================================================

class spn_sequence_encrypt extends spn_base_sequence;

  `uvm_object_utils(spn_sequence_encrypt)

  function new(string name = "spn_sequence_encrypt");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_encrypt: %s", name), UVM_LOW);
  endfunction

  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
    spn_seq_item req;
    //repeat(10) begin  
      req = spn_seq_item::type_id::create("req");
      start_item(req);
      req.randomize() with {req.opcode == encrypt;};
      `uvm_info(get_type_name(), $sformatf("Sending encrypt item: %s", req.convert2string()), UVM_LOW);
      finish_item(req);
    //end
  endtask
endclass

//=========================================================================

class spn_sequence_decrypt extends spn_base_sequence;

  `uvm_object_utils(spn_sequence_decrypt)

  function new(string name = "spn_sequence_decrypt");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_decrypt: %s", name), UVM_LOW);
  endfunction
  
  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
    spn_seq_item req;
    //repeat(10) begin
      req = spn_seq_item::type_id::create("req");
      start_item(req);
      req.randomize() with {req.opcode == decrypt;};
      `uvm_info(get_type_name(), $sformatf("Sending decrypt item: %s", req.convert2string()), UVM_LOW);
      finish_item(req);
    //end
  endtask
endclass

//=========================================================================

class spn_sequence_noop extends spn_base_sequence;

  `uvm_object_utils(spn_sequence_noop)

  function new(string name = "spn_sequence_noop");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_noop: %s", name), UVM_LOW);
  endfunction
  
  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
    spn_seq_item req;
    //repeat(5) begin
      req = spn_seq_item::type_id::create("req");
      start_item(req);
      req.randomize() with {req.opcode == no_op;};
      `uvm_info(get_type_name(), $sformatf("Sending noop item: %s", req.convert2string()), UVM_LOW);
      finish_item(req);
    //end
  endtask
endclass

//=========================================================================

class spn_sequence_undefined extends spn_base_sequence;

  `uvm_object_utils(spn_sequence_undefined)

  function new(string name = "spn_sequence_undefined");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_undefined: %s", name), UVM_LOW);
  endfunction
  
  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
    spn_seq_item req;
    //repeat(5) begin
      req = spn_seq_item::type_id::create("req");
      start_item(req);
      req.randomize() with {req.opcode == undefined;};
      `uvm_info(get_type_name(), $sformatf("Sending undefined item: %s", req.convert2string()), UVM_LOW);
      finish_item(req);
    //end
  endtask
endclass

//=========================================================================

class spn_sequence_encryption_decryption extends spn_base_sequence;

  `uvm_object_utils(spn_sequence_encryption_decryption)

  function new(string name = "spn_sequence_encryption_decryption");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_encryption_decryption: %s", name), UVM_LOW);
  endfunction
  
  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
    spn_seq_item req;
    
    // Send encrypt request
    req = spn_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with {req.opcode == encrypt;};
    `uvm_info(get_type_name(), $sformatf("Sending encrypt item: %s", req.convert2string()), UVM_LOW);
    finish_item(req);
    
    // Send decrypt request  
    req = spn_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with {req.opcode == decrypt;};
    `uvm_info(get_type_name(), $sformatf("Sending decrypt item: %s", req.convert2string()), UVM_LOW);
    finish_item(req);
  endtask
endclass

//=========================================================================

class spn_sequence_reset extends spn_base_sequence;

  `uvm_object_utils(spn_sequence_reset)

  function new(string name = "spn_sequence_reset");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_reset: %s", name), UVM_LOW);
  endfunction
  
  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
    spn_seq_item req;
    //repeat(5) begin
      req = spn_seq_item::type_id::create("req");
      start_item(req);
      req.randomize() with {req.opcode == no_op;};
      `uvm_info(get_type_name(), $sformatf("Sending reset item: %s", req.convert2string()), UVM_LOW);
      finish_item(req);
    //end 
  endtask
endclass

//=========================================================================

class spn_sequence_combination extends spn_base_sequence;
  
  `uvm_object_utils(spn_sequence_combination)
  
  function new(string name = "spn_sequence_combination");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_combination: %s", name), UVM_LOW);
  endfunction
  
  virtual task body();
    spn_sequence_encrypt encrypt_seq;
    spn_sequence_decrypt decrypt_seq;
    spn_sequence_noop noop_seq;
    spn_sequence_undefined undefined_seq;
    spn_sequence_encryption_decryption enc_dec_seq;
    
    encrypt_seq = spn_sequence_encrypt::type_id::create("encrypt_seq");
    decrypt_seq = spn_sequence_decrypt::type_id::create("decrypt_seq");
    noop_seq = spn_sequence_noop::type_id::create("noop_seq");
    undefined_seq = spn_sequence_undefined::type_id::create("undefined_seq");
    enc_dec_seq = spn_sequence_encryption_decryption::type_id::create("enc_dec_seq");

    encrypt_seq.start(m_sequencer);
    decrypt_seq.start(m_sequencer);
    noop_seq.start(m_sequencer);
    undefined_seq.start(m_sequencer);
    enc_dec_seq.start(m_sequencer);
  endtask
  
endclass
`endif // SPN_SEQUENCE_SV