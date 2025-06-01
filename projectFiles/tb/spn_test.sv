`include "spn_sequence.sv"
class spn_test extends spn_base_test;

    `uvm_component_utils(spn_test)

    spn_base_sequence seq;

    function new(string name = "spn_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Create the sequence
        choose_sequence("spn_sequence_combination");
        
    endfunction : build_phase
    
    virtual function void choose_sequence(string sequence_type);
        if (sequence_type == "spn_sequence_encrypt") begin
            seq = spn_sequence_encrypt::type_id::create("seq");
        end else if (sequence_type == "spn_sequence_decrypt") begin
            seq = spn_sequence_decrypt::type_id::create("seq");
        end else if (sequence_type == "spn_sequence_combination") begin
            seq = spn_sequence_combination::type_id::create("seq");
        end else if (sequence_type == "spn_sequence_reset") begin
            seq = spn_sequence_reset::type_id::create("seq");
        end else begin
            seq = spn_sequence_noop::type_id::create("seq");
        end
    endfunction : choose_sequence
        
    
    task run_phase(uvm_phase phase);
        int num_iterations = 512; // Number of times to repeat the test
        phase.raise_objection(this);
        for (int i = 0; i < num_iterations; i++) begin
            `uvm_info(get_type_name(), $sformatf("Running iteration %0d", i+1), UVM_LOW);
            seq.start(env.spn_agnt.sequencer);
        end
        phase.drop_objection(this);
    endtask : run_phase

endclass : spn_test