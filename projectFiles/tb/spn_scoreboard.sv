//-------------------------------------------------------------------------
//						spn_scoreboard 
//-------------------------------------------------------------------------
`ifndef spn_SCOREBOARD_SV
`define spn_SCOREBOARD_SV
class spn_scoreboard extends uvm_scoreboard;
  
  //---------------------------------------
  // declaring pkt_qu to store the pkt's recived from monitor
  //---------------------------------------
spn_seq_item pkt_qu[$];
  
  //---------------------------------------
  // sc_spn 
  //---------------------------------------
  bit [7:0] sc_spn [4];

  //---------------------------------------
  //port to recive packets from monitor
  //---------------------------------------
  uvm_analysis_imp#(spn_seq_item, spn_scoreboard) item_collected_export;
  `uvm_component_utils(spn_scoreboard)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), $sformatf("Creating spn_scoreboard: %s", name), UVM_LOW)
  endfunction : new
  //---------------------------------------
  // build_phase - create port and initialize local spnory
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      item_collected_export = new("item_collected_export", this);
      foreach(sc_spn[i]) sc_spn[i] = 8'hFF;
  endfunction: build_phase
  
  //---------------------------------------
  // write task - recives the pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write(spn_seq_item pkt);
    //pkt.print();
    pkt_qu.push_back(pkt);
  endfunction : write

  //---------------------------------------
  // run_phase - compare's the read data with the expected data(stored in local spnory)
  // local spnory will be updated on the write operation.
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    spn_seq_item spn_pkt;
    
    forever begin
      wait(pkt_qu.size() > 0);
      spn_pkt = pkt_qu.pop_front();

      //here we have the packet from monitor
      
      
        
    
  endtask : run_phase
endclass 
`endif // spn_SCOREBOARD_SV
