// ============================================================================
//  spn_cu_top — 3-round SPN encryption/decryption core
//  • Single-cycle latency (rounds are combinational)
//  • Separate encrypt & decrypt pipelines
// ============================================================================
`include "spn_sbox_pkg.sv"
module spn_cu_top (spn_if.dut bus);
  import spn_sbox_pkg::*;

  logic [15:0] Enc_R_K [0:2];         // Encryption Round Keys
  logic [15:0] Dec_R_K [0:2];         // Decryption Round Keys

  // Round Key Mixing 
  always_comb begin
    // Extracting encryption keys
    Enc_R_K[0]  = {bus.symmetric_secret_key[ 7:0], bus.symmetric_secret_key[23:16]};
    Enc_R_K[1]  =  bus.symmetric_secret_key[15:0];
    Enc_R_K[2]  = {bus.symmetric_secret_key[ 7:0], bus.symmetric_secret_key[31:24]};
    // Decryption keys are in reverse order of the encryption keys
    Dec_R_K[0] = Enc_R_K[2];               
    Dec_R_K[1] = Enc_R_K[1];
    Dec_R_K[2] = Enc_R_K[0];
  end

  logic [15:0] P[0:3], C[0:3];  // Pi in encryption, Ci in decryption
  
  assign P[0] = bus.data_in;
  assign C[0] = bus.data_in;

  // Creating two separate parallel pipelines one for encryption and the other for decryption
  // Implicit generate block
  for (genvar i = 0; i < 3; i++) begin : G_ROUND
    spn_round encryption_round (.data_in(P[i]), .key_mix(Enc_R_K [i]), .data_out(P[i+1]));
    spn_round decryption_round (.data_in(C[i]), .key_mix(Dec_R_K [i]), .data_out(C[i+1]));
  end

  
  always_ff @(posedge bus.clk or posedge bus.rst_n) begin
    if (bus.rst_n) begin 
      bus.valid    <= '0;
      bus.data_out <= '0;
    end
    else begin
      bus.valid <= 2'b00;       // Default: “no valid output”
      unique case (bus.opcode)
        
        2'b01: begin            // Encrypt
          bus.data_out <= P[3];
          bus.valid    <= 2'b01;
        end

        2'b10: begin            // Decrypt
          bus.data_out <= C[3];
          bus.valid    <= 2'b10;
        end

        default:                // No operation / undefined
          ;

      endcase
    end
  end
endmodule