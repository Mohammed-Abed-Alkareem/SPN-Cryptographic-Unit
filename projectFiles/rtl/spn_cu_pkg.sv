package spn_cu_pkg;
	
	typedef enum bit [1:0] {
	  no_op    = 2'b00,
	  encrypt  = 2'b01,
	  decrypt  = 2'b10,
	  undefined= 2'b11
	} operation_t;

	typedef enum bit [1:0] {
	  not_valid    = 2'b00,
	  successful_encryption  = 2'b01,
	  successful_decryption  = 2'b10,
	  internal_error_or_undefined= 2'b11
	} valid_t;
	
	typedef enum bit {
	  ENCRYPT    = 0,
	  DECRYPT  = 1
	} round_t;
	
	class SPNReferenceModel;
	
	    rand logic [15:0] data_in;
	    rand logic [31:0] symmetric_secret_key;
	    rand logic [1:0]  opcode;   
	         logic [15:0] data_out;
	    
	
	    // Round keys
	    logic [15:0] Enc_R_K [0:2];
	    logic [15:0] Dec_R_K [0:2];
	
	
	
	    // Compute keys from a given key
	    function void compute_keys(logic [31:0] symmetric_secret_key);
	        Enc_R_K[0] = {symmetric_secret_key[7:0], symmetric_secret_key[23:16]};
	        Enc_R_K[1] =  symmetric_secret_key[15:0];
	        Enc_R_K[2] = {symmetric_secret_key[7:0], symmetric_secret_key[31:24]};
	
	        Dec_R_K[0] = Enc_R_K[2];
	        Dec_R_K[1] = Enc_R_K[1];
	        Dec_R_K[2] = Enc_R_K[0];
		endfunction : compute_keys
	
	    // S-box lookup
	    function logic [3:0] sbox_lookup(input logic [3:0] nibble);
	        unique case (nibble)
	        4'h0: sbox_lookup = 4'hA;  4'h1: sbox_lookup = 4'h5;
	        4'h2: sbox_lookup = 4'h8;  4'h3: sbox_lookup = 4'h2;
	        4'h4: sbox_lookup = 4'h6;  4'h5: sbox_lookup = 4'hC;
	        4'h6: sbox_lookup = 4'h4;  4'h7: sbox_lookup = 4'h3;
	        4'h8: sbox_lookup = 4'h1;  4'h9: sbox_lookup = 4'h0;
	        4'hA: sbox_lookup = 4'hB;  4'hB: sbox_lookup = 4'h9;
	        4'hC: sbox_lookup = 4'hF;  4'hD: sbox_lookup = 4'hD;
	        4'hE: sbox_lookup = 4'h7;  4'hF: sbox_lookup = 4'hE;
	        endcase
		endfunction : sbox_lookup
	
	    // Inverse S-box lookup
	    function logic [3:0] invsbox_lookup(input logic [3:0] nibble);
	        unique case (nibble)
	        4'h0: invsbox_lookup = 4'h9;  4'h1: invsbox_lookup = 4'h8;
	        4'h2: invsbox_lookup = 4'h3;  4'h3: invsbox_lookup = 4'h7;
	        4'h4: invsbox_lookup = 4'h6;  4'h5: invsbox_lookup = 4'h1;
	        4'h6: invsbox_lookup = 4'h4;  4'h7: invsbox_lookup = 4'hE;
	        4'h8: invsbox_lookup = 4'h2;  4'h9: invsbox_lookup = 4'hB;
	        4'hA: invsbox_lookup = 4'h0;  4'hB: invsbox_lookup = 4'hA;
	        4'hC: invsbox_lookup = 4'h5;  4'hD: invsbox_lookup = 4'hD;
	        4'hE: invsbox_lookup = 4'hF;  4'hF: invsbox_lookup = 4'hC;
	        endcase
	    endfunction : invsbox_lookup
	
	    // P-box permutation
	    function logic [15:0] pbox(input logic [15:0] in);
	        return {in[7:0], in[15:8]};
	    endfunction : pbox
	
	    // Round encryption
	    function logic [15:0] round_encrypt(input logic [15:0] data, input logic [15:0] key);
	        logic [15:0] mix_out, sbox_out;
	        mix_out = data ^ key;
	        for (int i = 0; i < 16; i += 4)
	            sbox_out[i +: 4] = sbox_lookup(mix_out[i +: 4]);
	        return pbox(sbox_out);
	    endfunction : round_encrypt
	
	    // Round decryption
	    function logic [15:0] round_decrypt(input logic [15:0] data, input logic [15:0] key);
	        logic [15:0] pbox_out, sbox_out;
	        pbox_out = pbox(data);
	        for (int i = 0; i < 16; i += 4)
	            sbox_out[i +: 4] = invsbox_lookup(pbox_out[i +: 4]);
	        return sbox_out ^ key;
	    endfunction	: round_decrypt    

		// Predict based on inputs
		function logic [15:0] predict();
			logic [15:0] data;
			compute_keys(symmetric_secret_key);
			if (opcode == encrypt) begin			// Encryption
				data = round_encrypt(data_in, Enc_R_K[0]);
				data = round_encrypt(data, Enc_R_K[1]);
				data = round_encrypt(data, Enc_R_K[2]);
			end else if (opcode == decrypt) begin	// Decryption
				data = round_decrypt(data_in, Dec_R_K[0]);
				data = round_decrypt(data, Dec_R_K[1]);
				data = round_decrypt(data, Dec_R_K[2]);
			end else if (opcode == no_op) begin		// Undefined or no-op modes
				data = data_in; 					// no_op mode, return input as output
			end else begin							// Undefined operation, return output as high impedance
				data = 'z;
			end
			$display("Predicted data_out=0x%0h for data_in=0x%0h, key=0x%0h, opcode=%0b",
				data, data_in, symmetric_secret_key, opcode);
			return data;
	    endfunction : predict
		
	endclass

endpackage
