import spn_cu_pkg::operation_t;
class spn_base_sequence extends uvm_sequence#(spn_seq_item); 
  `uvm_object_utils(spn_sequence)

  function new(string name = "spn_sequence");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence: %s", name), UVM_LOW);
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
    //repeat(10) begin  
            `uvm_do_with(req, {req.opcode == encrypt;})
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
      //repeat(10) begin
        `uvm_do_with(req, {req.opcode == decrypt;})
      //end
  endtask
endclass

//=========================================================================

class spn_sequence_noop extends spn_base_sequence;

  `uvm_object_utils(spn_sequence_decrypt)

  function new(string name = "spn_sequence_noop");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_noop: %s", name), UVM_LOW);
  endfunction
  
  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
      //repeat(10) begin
        `uvm_do_with(req, {req.opcode == no_op;})
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
      //repeat(10) begin
        `uvm_do_with(req, {req.opcode == undefined;})
      //end
  endtask
endclass

//=========================================================================

class spn_sequence_encryption_decryption extends spn_base_sequence;

  `uvm_object_utils(spn_sequence_undefined)

  function new(string name = "spn_sequence_undefined");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequence_undefined: %s", name), UVM_LOW);
  endfunction
  
  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
      //repeat(10) begin
        `uvm_do_with(req, {req.opcode == encrypt;})
        `uvm_do_with(req, {req.opcode == decrypt;})
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
  

  spn_sequence_noop noop_seq;
  spn_sequence_undefined undefined_seq;
  spn_sequence_encryption_decryption enc_dec_seq;
  virtual task body();
    encrypt_seq = spn_sequence_encrypt::type_id::create("encrypt_seq");
    decrypt_seq = spn_sequence_decrypt::type_id::create("decrypt_seq");
    noop_seq = spn_sequence_noop::type_id::create("noop_seq");
    undefined_seq = spn_sequence_undefined::type_id::create("undefined_seq");
    enc_dec_seq = spn_sequence_encryption_decryption::type_id::create("enc_dec_seq");

    `uvm_do(encrypt_seq)
    `uvm_do(decrypt_seq)
    `uvm_do(noop_seq)
    `uvm_do(undefined_seq)
    `uvm_do(enc_dec_seq)
  endtask

  
endclass

