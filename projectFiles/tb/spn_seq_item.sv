class spn_seq_item extends uvm_sequence_item;

  randc bit [1:0]    opcode;
  rand bit  [15:0]   data_in;
  rand bit  [31:0]   symmetric_secret_key;
  bit       [15:0]   data_out;
  bit       [1:0]    valid;

  `uvm_object_utils_begin(spn_seq_item)
    `uvm_field_int(opcode,UVM_ALL_ON)
    `uvm_field_int(data_in,UVM_ALL_ON)
    `uvm_field_int(symmetric_secret_key,UVM_ALL_ON)
    `uvm_field_int(data_out,UVM_ALL_ON)
    `uvm_field_int(valid,UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "spn_seq_item");
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("Creating spn_seq_item: %s", name), UVM_LOW);
  endfunction

  // to_string function for printing sequence item contents
  function string convert2string();
    return $sformatf("opcode=0x%0h data_in=0x%0h symmetric_secret_key=0x%0h data_out=0x%0h valid=0x%0h",
                    opcode, data_in, symmetric_secret_key, data_out, valid);
  endfunction
  
  // opcode: 00=nop, 01=enc, 10=dec, 11=undefined 
  constraint opcode_distribution {
    opcode dist { 
      2'b00 := 1; // nop
      2'b01 := 3; // enc
      2'b10 := 3; // dec
      2'b11 := 1; // undefined
    }
  }

  // // Constrain the key to be nonzero
  // constraint symmetric_secret_key_c {
  //   symmetric_secret_key != 0;
  // }  
endclass