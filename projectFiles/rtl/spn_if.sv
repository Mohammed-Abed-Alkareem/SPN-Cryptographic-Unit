// ============================================================================
//  spn_if — synthesizable interface bundling DUT signals
// ============================================================================
interface spn_if #(int DW = 16, KW = 32) (input logic clk, rst_n);

  // Inputs driven to the DUT
  logic [1:0]    opcode;    // 00=nop 01=enc 10=dec 11=undefined
  logic [DW-1:0] data_in;  // plaintext / ciphertext
  logic [KW-1:0] symmetric_secret_key;   // 32-bit secret key

  // Outputs driven from the DUT
  logic [DW-1:0] data_out;  // result
  logic [1:0]    valid;     // 00: no valid output, 01: successful encryption, 10: successful decryption  
                            // 11: internal error or undefined operation

  /*-------------- Direction-controlled modports ---------------------------*/
  modport dut (input  clk, rst_n, opcode, data_in, symmetric_secret_key,
               output data_out, valid);
               
  modport tb  (output opcode, data_in, symmetric_secret_key,
               input  clk, rst_n, data_out, valid);

endinterface
