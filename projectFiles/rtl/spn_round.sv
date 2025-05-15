// ============================================================================
//  spn_round — one encryption/decryption round (combinational)
// ============================================================================
`include "spn_sbox_pkg.sv"
module spn_round #(int DW = 16)(
  input  logic [DW-1:0] data_in,
  input  logic [DW-1:0] round_key,
  output logic [DW-1:0] data_out
);
  import spn_sbox_pkg::*;

  // Key-mix (XOR)
  logic [DW-1:0] after_xor = data_in ^ round_key;

  // Substitution Layer (S-box) (4 parallel 4-bit S-boxes)
  logic [DW-1:0] after_s   = sbox_substitute(after_xor);

  // Permutation Layer (P-box) — rotate left by one byte (8 bits)
  assign data_out = {after_s[7:0], after_s[15:8]};
endmodule
