`ifndef SPN_SEQUENCE_SV
`define SPN_SEQUENCE_SV
import spn_cu_pkg::operation_t;

class spn_base_sequence extends uvm_sequence#(spn_seq_item); 
  `uvm_object_utils(spn_base_sequence)
  rand int num_transactions = 10;

  function new(string name = "spn_base_sequence");
    super.new(name);
    if (!uvm_config_db#(int)::get(null, "", "num_transactions", num_transactions)) 
            `uvm_info(get_type_name(), $sformatf("Using default num_transactions: %0d", num_transactions), UVM_LOW);
        
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
    `uvm_info(get_type_name(), 
      $sformatf("Starting %0d transactions with opcode %s", 
                num_transactions, target_opcode.name()), UVM_LOW);
    
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

  virtual task pre_body();
    super.pre_body();
    
      // Get configuration from config DB
    if (!uvm_config_db#(int)::get(null, get_full_name(), "encrypt_transactions", encrypt_transactions)) begin
      `uvm_info(get_type_name(), "Using default encrypt_transactions", UVM_LOW);
    end
    
    if (!uvm_config_db#(int)::get(null, get_full_name(), "decrypt_transactions", decrypt_transactions)) begin
      `uvm_info(get_type_name(), "Using default decrypt_transactions", UVM_LOW);
    end
    
    if (!uvm_config_db#(int)::get(null, get_full_name(), "noop_transactions", noop_transactions)) begin
      `uvm_info(get_type_name(), "Using default noop_transactions", UVM_LOW);
    end
    
    if (!uvm_config_db#(int)::get(null, get_full_name(), "undefined_transactions", undefined_transactions)) begin
      `uvm_info(get_type_name(), "Using default undefined_transactions", UVM_LOW);
    end
  endtask : pre_body

  
  // ==========================================================================

  virtual task body();
    spn_sequence encrypt_seq;
    spn_sequence decrypt_seq;
    spn_sequence noop_seq;
    spn_sequence undefined_seq;
    
    // Create encrypt sequence
    encrypt_seq = spn_sequence::type_id::create("encrypt_seq");
    encrypt_seq.target_opcode = encrypt;
    encrypt_seq.num_transactions = encrypt_transactions;
    
    // Create decrypt sequence  
    decrypt_seq = spn_sequence::type_id::create("decrypt_seq");
    decrypt_seq.target_opcode = decrypt;
    decrypt_seq.num_transactions = decrypt_transactions;
    
    // Create no-op sequence
    noop_seq = spn_sequence::type_id::create("noop_seq");
    noop_seq.target_opcode = no_op;
    noop_seq.num_transactions = noop_transactions;
    
    // Create undefined sequence
    undefined_seq = spn_sequence::type_id::create("undefined_seq");
    undefined_seq.target_opcode = undefined;
    undefined_seq.num_transactions = undefined_transactions;
    
    // Execute sequences in order
    `uvm_info(get_type_name(), "Starting combination sequence with encrypt operations", UVM_LOW);
    encrypt_seq.start(m_sequencer);
    
    `uvm_info(get_type_name(), "Starting combination sequence with decrypt operations", UVM_LOW);
    decrypt_seq.start(m_sequencer);
    
    `uvm_info(get_type_name(), "Starting combination sequence with no-op operations", UVM_LOW);
    noop_seq.start(m_sequencer);
    
    `uvm_info(get_type_name(), "Starting combination sequence with undefined operations", UVM_LOW);
    undefined_seq.start(m_sequencer);
    
    `uvm_info(get_type_name(), "Combination sequence completed", UVM_LOW);
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
    `uvm_do_with(req, {
      req.opcode == encrypt;
      req.symmetric_secret_key == 32'h00000000;
      req.data_in == 16'hAAAA;
    })
    
    // All ones key
    `uvm_do_with(req, {
      req.opcode == encrypt;
      req.symmetric_secret_key == 32'hFFFFFFFF;
      req.data_in == 16'h5555;
    })
    
    // Alternating pattern keys
    `uvm_do_with(req, {
      req.opcode == encrypt;
      req.symmetric_secret_key == 32'hAAAAAAAA;
      req.data_in == 16'h1234;
    })
    
    `uvm_do_with(req, {
      req.opcode == encrypt;
      req.symmetric_secret_key == 32'h55555555;
      req.data_in == 16'h1234;
    })
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
    `uvm_do_with(req, {
      req.opcode == encrypt;
      req.data_in == 16'h0000;
      req.symmetric_secret_key == 32'h12345678;
    })
    
    // All ones data
    `uvm_do_with(req, {
      req.opcode == encrypt;
      req.data_in == 16'hFFFF;
      req.symmetric_secret_key == 32'h12345678;
    })
    
    // Walking ones
    for (int i = 0; i < 16; i++) begin
      `uvm_do_with(req, {
        req.opcode == encrypt;
        req.data_in == (16'h1 << i);
        req.symmetric_secret_key == 32'h12345678;
      })
    end
    
    // Walking zeros
    for (int i = 0; i < 16; i++) begin
      `uvm_do_with(req, {
        req.opcode == encrypt;
        req.data_in == ~(16'h1 << i);
        req.symmetric_secret_key == 32'h12345678;
      })
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
    repeat(10) begin
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
    `uvm_do_with(req, {
      req.opcode == encrypt;
      req.data_in == 16'h0000;
      req.symmetric_secret_key == 32'h00000000;
    })
    
    // Test with maximum values
    `uvm_do_with(req, {
      req.opcode == encrypt;
      req.data_in == 16'hFFFF;
      req.symmetric_secret_key == 32'hFFFFFFFF;
    })
    
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
    
    // Key corner cases
    key_corner = spn_sequence_key_corner_cases::type_id::create("key_corner");
    key_corner.start(m_sequencer);
    
    // Data patterns
    data_patterns = spn_sequence_data_patterns::type_id::create("data_patterns");
    data_patterns.start(m_sequencer);
    
    // Rapid changes
    rapid_changes = spn_sequence_rapid_changes::type_id::create("rapid_changes");
    rapid_changes.start(m_sequencer);
    
    // Undefined operations stress
    undefined_stress = spn_sequence_undefined_stress::type_id::create("undefined_stress");
    undefined_stress.start(m_sequencer);
    
    // Boundary values
    boundary_values = spn_sequence_boundary_values::type_id::create("boundary_values");
    boundary_values.start(m_sequencer);
    
    // Same key different data
    same_key_diff_data = spn_sequence_same_key_diff_data::type_id::create("same_key_diff_data");
    same_key_diff_data.start(m_sequencer);
    
    `uvm_info(get_type_name(), "Comprehensive corner case testing completed", UVM_LOW);
  endtask
endclass



`endif // SPN_SEQUENCE_SV