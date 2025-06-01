import spn_cu_pkg::*;
class spn_scoreboard extends uvm_scoreboard;

  spn_seq_item pkt_qu[$];
  SPNReferenceModel ref_model;
  bit [7:0] sc_spn [4];


  uvm_analysis_imp#(spn_seq_item, spn_scoreboard) scb_analysis_imp;
  `uvm_component_utils(spn_scoreboard)

  function new (string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Creating spn_scoreboard: %s", name), UVM_LOW)
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb_analysis_imp = new("scb_analysis_imp", this);
    ref_model = new();
    foreach(sc_spn[i]) 
      sc_spn[i] = 8'hFF;
  endfunction: build_phase
  
  virtual function void write(spn_seq_item pkt);
    //pkt.print();
    pkt_qu.push_back(pkt);
  endfunction : write

  virtual task run_phase(uvm_phase phase);
    spn_seq_item spn_actual;
    super.run_phase(phase);
    
    forever begin
      wait(pkt_qu.size() > 0);
      spn_actual = pkt_qu.pop_front();
      ref_model.data_in = spn_actual.data_in;
      ref_model.symmetric_secret_key = spn_actual.symmetric_secret_key;
      ref_model.opcode = spn_actual.opcode;
      ref_model.predict();
      if(spn_actual.valid) begin
        if(ref_model.data_out !== spn_actual.data_out) begin
          `uvm_error(get_type_name(), $sformatf("Mismatch in data_out: Expected %h, got %h", ref_model.data_out, spn_actual.data_out));
        end else begin
          `uvm_info(get_type_name(), $sformatf("Data_out matches: %h", ref_model.data_out), UVM_LOW);
        end
      end else begin
        `uvm_info(get_type_name(), "Received invalid transaction, skipping comparison.", UVM_LOW);
      end
    end  
      
  endtask : run_phase
endclass 
