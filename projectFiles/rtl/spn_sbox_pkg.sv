// ============================================================================
//  S-box package — constants & helper for 3-round SPN toy cipher
// ============================================================================
package spn_sbox_pkg;

  localparam int SBOX_W = 4;    // bits per S-box nibble
  localparam int DATA_W = 16;   // width of data block

  // 4-bit substitution table (index = input nibble)
  localparam logic [15:0][SBOX_W-1:0] SBOX = '{
    4'hA, 4'h5, 4'h8, 4'h2,
    4'h6, 4'hC, 4'h4, 4'h3,
    4'h1, 4'h0, 4'hB, 4'h9,
    4'hF, 4'hD, 4'h7, 4'hE
  };

  // Substitution Layer (S-box) utility function
  function logic [DATA_W-1:0] sbox_substitute (logic [DATA_W-1:0] data_in);
      for (int i = 0; i < DATA_W; i += SBOX_W)
        // Replace each 4-bit with the corresponding predefined 4-bit from the substitution table
        data_in[i +: SBOX_W] = SBOX[data_in[i +: SBOX_W]];
      return data_in;
  endfunction

endpackage
