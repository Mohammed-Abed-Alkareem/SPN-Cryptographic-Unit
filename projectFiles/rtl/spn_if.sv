interface spn_if (
  input logic clk, rst
  );

  // Inputs driven to the DUT
  logic [1:0]    opcode;    // 00=nop 01=enc 10=dec 11=undefined
  logic [15:0]   data_in;  // plaintext / ciphertext
  logic [31:0]   symmetric_secret_key;   // 32-bit secret key

  // Outputs driven from the DUT
  logic [15:0]   data_out;  // result
  logic [1:0]    valid;     // 00: no valid output, 01: successful encryption, 10: successful decryption  
                            // 11: internal error or undefined operation

  // Clocking blocks
  // Driver clocking block
  clocking driver_cb @(posedge clk);
    default input #1step output #2;
    output opcode, data_in, symmetric_secret_key;
    input data_out, valid;
  endclocking

  // Monitor clocking block  
  clocking monitor_cb @(posedge clk);
    default input #1step;
    input opcode, data_in, symmetric_secret_key, data_out, valid;
  endclocking

  // modports
  modport DUT (input  clk, rst, opcode, data_in, symmetric_secret_key,
              output data_out, valid);
  modport DRIVER (clocking driver_cb, input rst);
  modport MONITOR (clocking monitor_cb, input rst);
            
endinterface
