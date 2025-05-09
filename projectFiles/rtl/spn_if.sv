// ============================================================================
//  spn_if — synthesizable interface bundling DUT signals
// ============================================================================
interface spn_if #(int DW = 16, KW = 32) (input logic clk, rst_n);

  /*-------------- Inputs driven to the DUT -----------------------------*/
  logic [1:0]  opcode;    // 00=nop 01=enc 10=dec
  logic [DW-1:0] data_i;  // plaintext / ciphertext
  logic [KW-1:0] key_i;   // 32-bit secret key

  /*-------------- Outputs driven from the DUT --------------------------*/
  logic [DW-1:0] data_o;  // result
  logic [1:0]    valid;   // echoes opcode when done (01/10)

  /*-------------- Direction-controlled modports ---------------------------*/
  modport dut (input  clk, rst_n, opcode, data_i, key_i,
               output data_o, valid);
               
  modport tb  (output opcode, data_i, key_i,
               input  clk, rst_n, data_o, valid);

endinterface
