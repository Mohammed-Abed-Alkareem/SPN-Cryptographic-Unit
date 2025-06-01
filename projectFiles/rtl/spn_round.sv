// Note that the inverse of key mixing and p-box operations is the same operation
module spn_round (
  input  logic [15:0] data_in,
  input  logic [15:0] round_key,
  input  logic mode,	// 0->encrypt, 1->decrypt
  output logic [15:0] data_out, key_mix_out, sbox_out, pbox_out
);
  import spn_cu_pkg::*;
  logic [15:0] enc_sbox, dec_sbox;
  
  sbox sbox_inst (
    .data_in (key_mix_out),
    .data_out (enc_sbox)
  );

  invsbox inv_sbox_inst (
    .data_in (pbox_out),
    .data_out (dec_sbox)
  );
  
  // Remember Order of assign statements is not important
  
  // Key-mix (XOR)
  assign key_mix_out = mode? (sbox_out ^ round_key) : (data_in ^ round_key);
  
  // Inverse/Regular Substitution Layer (S-box) (4 parallel 4-bit S-boxes)
  assign sbox_out = mode? dec_sbox : enc_sbox;
  
  // Permutation Layer (P-box) rotate (right/left) by one byte
  assign pbox_out = mode? {data_in[7:0], data_in[15:8]} : {sbox_out[7:0], sbox_out[15:8]};
  
  assign data_out = mode? key_mix_out : pbox_out;
  
endmodule  
