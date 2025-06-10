class spn_monitor extends uvm_monitor;
  `uvm_component_utils(spn_monitor)

  virtual spn_if vif;
  uvm_analysis_port #(spn_seq_item) mon_analysis_port;
  
  // To handle the pipeline, we need to store the inputs from the previous cycle
  spn_seq_item prev_inputs;

  function new (string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // ============================================================

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the analysis port
    mon_analysis_port = new("mon_analysis_port", this);
    // Create the transaction object to hold previous inputs
    prev_inputs = new("prev_inputs");
    // Get the virtual interface from the config DB
    if (!uvm_config_db#(virtual spn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ",
                           get_full_name(), ".vif"});
  endfunction : build_phase

  // ============================================================

  task run_phase(uvm_phase phase);
    spn_seq_item trans_collected;
    
    forever begin
      @(vif.MONITOR.monitor_cb);

      // Check if the DUT is signalling a valid output in the CURRENT cycle
      if (vif.MONITOR.monitor_cb.valid inside {spn_cu_pkg::successful_encryption, spn_cu_pkg::successful_decryption}) begin
          
          // A valid output in this cycle corresponds to inputs from the PREVIOUS cycle.
          // Create a new transaction to send to the scoreboard.
          trans_collected = new;

          // PAIR THE STORED INPUTS (from prev_inputs) WITH THE CURRENT OUTPUTS
          trans_collected.opcode               = prev_inputs.opcode;
          trans_collected.data_in              = prev_inputs.data_in;
          trans_collected.symmetric_secret_key = prev_inputs.symmetric_secret_key;
          trans_collected.data_out             = vif.MONITOR.monitor_cb.data_out;
          trans_collected.valid                = vif.MONITOR.monitor_cb.valid;

          `uvm_info(get_type_name(),
                    $sformatf("Monitor sending to scoreboard: %s", trans_collected.convert2string()),
                    UVM_LOW);
          
          // Write the correctly assembled transaction to the scoreboard
          mon_analysis_port.write(trans_collected);
      end

      // At the end of every cycle, store the CURRENT inputs to be used in the NEXT cycle's check.
      prev_inputs.opcode               = vif.MONITOR.monitor_cb.opcode;
      prev_inputs.data_in              = vif.MONITOR.monitor_cb.data_in;
      prev_inputs.symmetric_secret_key = vif.MONITOR.monitor_cb.symmetric_secret_key;
    end
  endtask : run_phase

endclass