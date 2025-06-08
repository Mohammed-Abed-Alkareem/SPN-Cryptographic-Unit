class spn_seq_item extends uvm_sequence_item;
  `uvm_object_utils(spn_seq_item)

  rand bit  [1:0]    opcode;
  rand bit  [15:0]   data_in;
  rand bit  [31:0]   symmetric_secret_key;
  bit       [15:0]   data_out;
  bit       [1:0]    valid;

  // ============================================================

  function new(string name = "spn_seq_item");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("\n\n----------------------------------\nCreating spn_seq_item: %s", name), UVM_LOW);
  endfunction : new

  // ============================================================

  // convert2string function for printing sequence item contents
  function string convert2string();
    return $sformatf("opcode=0x%0h data_in=0x%0h symmetric_secret_key=0x%0h data_out=0x%0h valid=0x%0h",
                    opcode, data_in, symmetric_secret_key, data_out, valid);
  endfunction : convert2string

  
endclass