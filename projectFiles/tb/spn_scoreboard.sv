class spn_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp#(spn_seq_item, spn_scoreboard) scb_analysis_imp;
  `uvm_component_utils(spn_scoreboard)

  spn_seq_item pkt_qu[$];
  SPNReferenceModel ref_model;

  // ============================================================

  function new (string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Creating spn_scoreboard: %s", name), UVM_LOW)
  endfunction : new

  // ============================================================

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the analysis port
    scb_analysis_imp = new("scb_analysis_imp", this);
    // Instantiate the reference model
    ref_model = new();
  endfunction: build_phase
  
  // ============================================================

  virtual function void write(spn_seq_item pkt);
    // Add the packet to the queue
    pkt_qu.push_back(pkt);  
  endfunction : write

  // ============================================================

  virtual task run_phase(uvm_phase phase);
    spn_seq_item spn_actual;
    super.run_phase(phase);
    
    forever begin
      // Wait for a packet to be available
      wait(pkt_qu.size() > 0);
      // Pop the packet from the queue
      spn_actual = pkt_qu.pop_front();
      
      // Set reference model inputs
      ref_model.data_in = spn_actual.data_in;
      ref_model.symmetric_secret_key = spn_actual.symmetric_secret_key;
      ref_model.opcode = spn_actual.opcode;
      
      // Only check output for valid operations (encrypt/decrypt)
      if(spn_actual.opcode == 2'b01 || spn_actual.opcode == 2'b10) begin
        ref_model.data_out = ref_model.predict();
        
        // Check if DUT output is valid
        if(spn_actual.valid != 2'b00 && spn_actual.valid != 2'b11) begin
          if(ref_model.data_out !== spn_actual.data_out) begin
            `uvm_error(get_type_name(), $sformatf("MISMATCH! Opcode=%0b Expected=%0h Actual=%0h", 
                      spn_actual.opcode, ref_model.data_out, spn_actual.data_out));
          end else begin
            `uvm_info(get_type_name(), $sformatf("MATCH! Opcode=%0b Expected=%0h Actual=%0h", 
                    spn_actual.opcode, ref_model.data_out, spn_actual.data_out), UVM_LOW);
          end
        end else begin
          `uvm_info(get_type_name(),
            "DUT output marked as invalid, skipping comparison.", UVM_LOW);
        end
      end else begin
        `uvm_info(get_type_name(),
          $sformatf("No-op or undefined operation (opcode=%0b), skipping comparison.", spn_actual.opcode), UVM_LOW);
      end
    end      
  endtask : run_phase
  
endclass 
