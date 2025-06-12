`ifndef SPN_SEQUENCE_SV
`define SPN_SEQUENCE_SV
import spn_cu_pkg::operation_t;

class spn_base_sequence extends uvm_sequence#(spn_seq_item); 
  `uvm_object_utils(spn_base_sequence)
  rand int num_transactions = 10;

  function new(string name = "spn_base_sequence");
    super.new(name);
    uvm_config_db#(int)::get(null, "", "num_transactions", num_transactions);
        
  endfunction : new

  // ==========================================================================
  
  constraint num_trans_c {
      num_transactions inside {[1:100]};
    }
  
  // ==========================================================================
  // Create, Randomize and Send the item to driver via the sequencer
  virtual task body();
      `uvm_do(req)
  endtask : body
endclass

//=========================================================================

// Single parameterized sequence for all operations
class spn_sequence extends spn_base_sequence;
  `uvm_object_utils(spn_sequence)
  
  rand operation_t target_opcode;
  
  // ==========================================================================

  function new(string name = "spn_sequence");
    super.new(name);
  endfunction : new

  // ==========================================================================
  
  virtual task body();
    repeat(num_transactions) begin
      `uvm_do_with(req, {req.opcode == target_opcode;})
    end
  endtask : body

endclass

//=========================================================================

class spn_sequence_combination extends spn_base_sequence;
  `uvm_object_utils(spn_sequence_combination)
  
  // Default values
  int encrypt_transactions = 10;
  int decrypt_transactions = 10;
  int noop_transactions = 10;
  int undefined_transactions = 10;
  
  function new(string name = "spn_sequence_combination");
    super.new(name);
  endfunction : new
  
  // ==========================================================================

  virtual task body();
    spn_sequence encrypt_seq;
    spn_sequence decrypt_seq;
    spn_sequence noop_seq;
    spn_sequence undefined_seq;
    
    repeat(num_transactions) begin
      // Create encrypt sequence
      encrypt_seq = spn_sequence::type_id::create("encrypt_seq");
      encrypt_seq.target_opcode = encrypt;
      encrypt_seq.num_transactions = 1;
      
      // Create decrypt sequence  
      decrypt_seq = spn_sequence::type_id::create("decrypt_seq");
      decrypt_seq.target_opcode = decrypt;
      decrypt_seq.num_transactions = 1;
      
      // Create no-op sequence
      noop_seq = spn_sequence::type_id::create("noop_seq");
      noop_seq.target_opcode = no_op;
      noop_seq.num_transactions = 1;
      
      // Create undefined sequence
      undefined_seq = spn_sequence::type_id::create("undefined_seq");
      undefined_seq.target_opcode = undefined;
      undefined_seq.num_transactions = 1; 

      encrypt_seq.start(m_sequencer);
      decrypt_seq.start(m_sequencer);
      noop_seq.start(m_sequencer);
      undefined_seq.start(m_sequencer);

    end
  endtask : body

endclass

//=========================================================================

class spn_sequence_encryption_decryption extends spn_base_sequence;
  `uvm_object_utils(spn_sequence_encryption_decryption)

  function new(string name = "spn_sequence_encryption_decryption");
    super.new(name);
  endfunction : new
  
  virtual task body();
    spn_sequence encrypt_seq;
    spn_sequence decrypt_seq;
    repeat(num_transactions) begin
      // Create encrypt sequence
      encrypt_seq = spn_sequence::type_id::create("encrypt_seq");
      encrypt_seq.target_opcode = encrypt;
      encrypt_seq.num_transactions = 1;  // One encrypt operation
      
      // Create decrypt sequence
      decrypt_seq = spn_sequence::type_id::create("decrypt_seq");  
      decrypt_seq.target_opcode = decrypt;
      decrypt_seq.num_transactions = 1;  // One decrypt operation
      
      // Execute back-to-back
      encrypt_seq.start(m_sequencer);
      decrypt_seq.start(m_sequencer);
    end
  endtask : body

endclass

//=========================================================================

class spn_sequence_key_corner_cases extends spn_base_sequence;
  `uvm_object_utils(spn_sequence_key_corner_cases)
  
  function new(string name = "spn_sequence_key_corner_cases");
    super.new(name);
  endfunction
  
  virtual task body();
    // All zeros key
    req = spn_seq_item::type_id::create("req");
    req.opcode = encrypt;
    req.symmetric_secret_key = 32'h00000000;
    req.data_in = 16'hAAAA;
    start_item(req);
    finish_item(req);
    
    // All ones key
    req = spn_seq_item::type_id::create("req");
    req.opcode = encrypt;
    req.symmetric_secret_key = 32'hFFFFFFFF;
    req.data_in = 16'h5555;
    start_item(req);
    finish_item(req);
    
    // Alternating pattern keys
    req = spn_seq_item::type_id::create("req");
    req.opcode = encrypt;
    req.symmetric_secret_key = 32'hAAAAAAAA;
    req.data_in = 16'h1234;
    start_item(req);
    finish_item(req);
    
    req = spn_seq_item::type_id::create("req");
    req.opcode = encrypt;
    req.symmetric_secret_key = 32'h55555555;
    req.data_in = 16'h1234;
    start_item(req);
    finish_item(req);
  endtask
endclass

//=========================================================================

class spn_sequence_data_patterns extends spn_base_sequence;
  `uvm_object_utils(spn_sequence_data_patterns)
  
  function new(string name = "spn_sequence_data_patterns");
    super.new(name);
  endfunction
  
  virtual task body();
    // All zeros data
    req = spn_seq_item::type_id::create("req");
    req.opcode = encrypt;
    req.symmetric_secret_key = 32'h12345678;
    req.data_in = 16'h0000;
    start_item(req);
    finish_item(req);
    
    
    // All ones data
    req = spn_seq_item::type_id::create("req");
    req.opcode = encrypt;
    req.symmetric_secret_key = 32'h12345678;
    req.data_in = 16'hFFFF;
    start_item(req);
    finish_item(req);
    
    
    // Walking ones
    for (int i = 0; i < 16; i++) begin
      req = spn_seq_item::type_id::create("req");
      req.opcode = encrypt;
      req.symmetric_secret_key = 32'h12345678;
      req.data_in = (16'h1 << i);
      start_item(req);
      finish_item(req);
    end
    
    // Walking zeros
    for (int i = 0; i < 16; i++) begin
      req = spn_seq_item::type_id::create("req");
      req.opcode = encrypt;
      req.symmetric_secret_key = 32'h12345678;
      req.data_in = ~(16'h1 << i);
      start_item(req);
      finish_item(req);
    end
  endtask
endclass

//=========================================================================

class spn_sequence_rapid_changes extends spn_base_sequence;
  `uvm_object_utils(spn_sequence_rapid_changes)
  
  function new(string name = "spn_sequence_rapid_changes");
    super.new(name);
  endfunction
  
  virtual task body();
    // Rapid opcode changes
    repeat(5) begin
      `uvm_do_with(req, {
        req.opcode dist {encrypt := 1, decrypt := 1, no_op := 1, undefined := 1};
      })
    end
    
    // Burst of same operation
    repeat(5) begin
      `uvm_do_with(req, {req.opcode == encrypt;})
    end
    
    // Immediate switch to different operation
    repeat(5) begin
      `uvm_do_with(req, {req.opcode == decrypt;})
    end
  endtask
endclass

//=========================================================================

class spn_sequence_undefined_stress extends spn_base_sequence;
  `uvm_object_utils(spn_sequence_undefined_stress)
  
  function new(string name = "spn_sequence_undefined_stress");
    super.new(name);
  endfunction
  
  virtual task body();
    // Multiple undefined operations
    repeat(5) begin
      `uvm_do_with(req, {req.opcode == undefined;})
    end
    
    // Undefined followed by valid operation
    `uvm_do_with(req, {req.opcode == undefined;})
    `uvm_do_with(req, {req.opcode == encrypt;})
    
    // Valid operation followed by undefined
    `uvm_do_with(req, {req.opcode == encrypt;})
    `uvm_do_with(req, {req.opcode == undefined;})
    
    // Alternating undefined and valid
    repeat(5) begin
      `uvm_do_with(req, {req.opcode == undefined;})
      `uvm_do_with(req, {req.opcode == encrypt;})
    end
  endtask
endclass

//=========================================================================

class spn_sequence_boundary_values extends spn_base_sequence;
  `uvm_object_utils(spn_sequence_boundary_values)
  
  function new(string name = "spn_sequence_boundary_values");
    super.new(name);
  endfunction
  
  virtual task body();
    // Test with minimum values
    req = spn_seq_item::type_id::create("req");
    req.opcode = encrypt;
    req.symmetric_secret_key = 32'h00000000;
    req.data_in = 16'h0000;
    start_item(req);
    finish_item(req);
    
    
    // Test with maximum values
    req = spn_seq_item::type_id::create("req");
    req.opcode = encrypt;
    req.symmetric_secret_key = 32'hFFFFFFFF;
    req.data_in = 16'hFFFF;
    start_item(req);
    finish_item(req);
    
  endtask
endclass

//=========================================================================

class spn_sequence_same_key_diff_data extends spn_base_sequence;
  `uvm_object_utils(spn_sequence_same_key_diff_data)
  
  rand logic [31:0] fixed_key;
  
  function new(string name = "spn_sequence_same_key_diff_data");
    super.new(name);
  endfunction
  
  virtual task body();
    if (!this.randomize()) begin
      `uvm_error(get_type_name(), "Failed to randomize key")
    end
    
    // Test multiple data patterns with same key
    repeat(5) begin
      `uvm_do_with(req, {
        req.opcode == encrypt;
        req.symmetric_secret_key == fixed_key;
        // Let data_in randomize
      })
    end
    
    // Same for decrypt
    repeat(5) begin
      `uvm_do_with(req, {
        req.opcode == decrypt;
        req.symmetric_secret_key == fixed_key;
        // Let data_in randomize
      })
    end
  endtask
endclass

//=========================================================================

class spn_sequence_corner_cases extends spn_base_sequence;
  `uvm_object_utils(spn_sequence_corner_cases)
  
  function new(string name = "spn_sequence_corner_cases");
    super.new(name);
  endfunction
  
  virtual task body();
    spn_sequence_key_corner_cases key_corner;
    spn_sequence_data_patterns data_patterns;
    spn_sequence_rapid_changes rapid_changes;
    spn_sequence_undefined_stress undefined_stress;
    spn_sequence_boundary_values boundary_values;
    spn_sequence_same_key_diff_data same_key_diff_data;
    
    `uvm_info(get_type_name(), "Starting comprehensive corner case testing", UVM_LOW);
    repeat(num_transactions) begin
      // Key corner cases
      key_corner = spn_sequence_key_corner_cases::type_id::create("key_corner");
      key_corner.num_transactions = 1; // One transaction per corner case
      key_corner.start(m_sequencer);
      
      // Data patterns
      data_patterns = spn_sequence_data_patterns::type_id::create("data_patterns");
      data_patterns.num_transactions = 1; // One transaction per pattern
      data_patterns.start(m_sequencer);
      
      // Rapid changes
      rapid_changes = spn_sequence_rapid_changes::type_id::create("rapid_changes");
      rapid_changes.num_transactions = 1; // One transaction per rapid change
      rapid_changes.start(m_sequencer);
      
      // Undefined operations stress
      undefined_stress = spn_sequence_undefined_stress::type_id::create("undefined_stress");
      undefined_stress.num_transactions = 1; // One transaction per stress case
      undefined_stress.start(m_sequencer);
      
      // Boundary values
      boundary_values = spn_sequence_boundary_values::type_id::create("boundary_values");
      boundary_values.num_transactions = 1; // One transaction per boundary value
      boundary_values.start(m_sequencer);
      
      // Same key different data
      same_key_diff_data = spn_sequence_same_key_diff_data::type_id::create("same_key_diff_data");
      same_key_diff_data.num_transactions = 1; // One transaction per data pattern
      same_key_diff_data.start(m_sequencer);
    end
    `uvm_info(get_type_name(), "Comprehensive corner case testing completed", UVM_LOW);
  endtask
endclass



`endif // SPN_SEQUENCE_SV