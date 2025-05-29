module spn_cu_top (
  
  spn_if.dut bus,											   
  
  // Variables to store internal changes for debugging purposes
  output logic [15:0] key_mix_out [0:2],   // Result of each xor operation (Encryption/Decryption)
  output logic [15:0] sbox_out [0:2],      // Result of each sbox (Encryption/Decryption)
  output logic [15:0] pbox_out [0:2],      // Result of each pbox (Encryption/Decryption)
 
);
  import spn_cu_pkg::*;

  logic [15:0] round_keys [0:2];      // Encryption/Decryption Round Keys
  
  // Key scheduling
  key_scheduler ksch (bus.symmetric_secret_key, bus.opcode[1], round_keys);
  
  logic [15:0] X[0:3];  // Xi in encryption or Xi in decryption
  
  assign X[0] = bus.data_in;

  // Creating two separate parallel pipelines one for encryption and the other for decryption
  generate
	  for (genvar i = 0; i < 3; i++) begin : G_ROUND
	      spn_round round (.data_in(X[i]), .round_key(round_keys [i]), .mode(bus.opcode[1]), .data_out(X[i+1]), .key_mix_out(key_mix_out[i]), .sbox_out(sbox_out[i]), .pbox_out(pbox_out[i]));
	  end
  endgenerate
  
  always_ff @(posedge bus.clk or posedge bus.rst) begin
    
	if (bus.rst) begin 
      bus.valid    <= not_valid;
      bus.data_out <= '0;
    end
	
    else begin
      bus.valid <= not_valid;       // Default: �no valid output�
      unique case (bus.opcode)
        no_op:
          ; // If the opcode is 00 dont do anything and the ouput is not valid by default
            // This case is inserted since the unique case will trigger and error/warning when it comes across it

        encrypt: begin            // Encrypt
          bus.data_out <= X[3];
          bus.valid    <= successful_encryption;
        end

        decrypt: begin            // Decrypt
          bus.data_out <= X[3];
          bus.valid    <= successful_decryption;
        end

        undefined:                  // Undefined 
          bus.valid    <= internal_error_or_undefined;
          
      // unqique case will trigger a warning/error for any other cases not mentioned
      endcase
    end
  end
endmodule
