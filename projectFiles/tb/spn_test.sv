class spn_test extends spn_base_test;
    `uvm_component_utils(spn_test)

    spn_base_sequence seq;
    string sequence_type = "spn_sequence_combination";  // Default

    function new(string name = "spn_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction : new

    // ========================================================================

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Get configuration from config DB
        if (!uvm_config_db#(string)::get(this, "", "sequence_type", sequence_type)) begin
            `uvm_info(get_type_name(), $sformatf("Using default sequence_type: %s", sequence_type), UVM_LOW);
        end
        
        // Create the sequence based on configuration
        choose_sequence(sequence_type);
        
    endfunction : build_phase
    
    // ========================================================================

    virtual function void choose_sequence(string sequence_type);
        case(sequence_type)
            "spn_sequence_combination": begin
                `uvm_info(get_type_name(), "Creating spn_sequence_combination", UVM_LOW);
                seq = spn_sequence_combination::type_id::create("seq");
            end
            "spn_sequence_encryption_decryption": begin
                `uvm_info(get_type_name(), "Creating spn_sequence_encryption_decryption", UVM_LOW);
                seq = spn_sequence_encryption_decryption::type_id::create("seq");
            end
            "spn_sequence_key_corner_cases": begin
                `uvm_info(get_type_name(), "Creating spn_sequence_key_corner_cases", UVM_LOW);
                seq = spn_sequence_key_corner_cases::type_id::create("seq");
            end
            "spn_sequence_data_patterns": begin
                `uvm_info(get_type_name(), "Creating spn_sequence_data_patterns", UVM_LOW);
                seq = spn_sequence_data_patterns::type_id::create("seq");
            end
            "spn_sequence_rapid_changes": begin
                `uvm_info(get_type_name(), "Creating spn_sequence_rapid_changes", UVM_LOW);
                seq = spn_sequence_rapid_changes::type_id::create("seq");
            end
            "spn_sequence_undefined_stress": begin
                `uvm_info(get_type_name(), "Creating spn_sequence_undefined_stress", UVM_LOW);
                seq = spn_sequence_undefined_stress::type_id::create("seq");
            end
            "spn_sequence_boundary_values": begin
                `uvm_info(get_type_name(), "Creating spn_sequence_boundary_values", UVM_LOW);
                seq = spn_sequence_boundary_values::type_id::create("seq");
            end
            "spn_sequence_same_key_diff_data": begin
                `uvm_info(get_type_name(), "Creating spn_sequence_same_key_diff_data", UVM_LOW);
                seq = spn_sequence_same_key_diff_data::type_id::create("seq");
            end
            "spn_sequence_corner_cases": begin
                `uvm_info(get_type_name(), "Creating spn_sequence_corner_cases (comprehensive)", UVM_LOW);
                seq = spn_sequence_corner_cases::type_id::create("seq");
            end
            default: begin
                `uvm_warning(get_type_name(), $sformatf("Unknown sequence type '%s', using default", sequence_type));
                seq = spn_sequence_combination::type_id::create("seq");            
            end
        endcase
    endfunction : choose_sequence
        
    // ========================================================================

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.spn_agnt.sequencer);
        phase.drop_objection(this);
    endtask : run_phase

endclass : spn_test