
//-------------------------------------------------------------------------
//						spn_sequencer
//-------------------------------------------------------------------------

class spn_sequencer extends uvm_sequencer#(spn_seq_item);

  `uvm_component_utils(spn_sequencer) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
  
    super.new(name,parent);
    `uvm_info(get_type_name(), $sformatf("Creating spn_sequencer: %s", name), UVM_MEDIUM)
  endfunction
  
endclass