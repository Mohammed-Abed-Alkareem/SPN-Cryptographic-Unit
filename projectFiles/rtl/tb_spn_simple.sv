`timescale 1ns/1ps

// --------------------------------------------------------------------------
//  Import any shared packages BEFORE the DUT. (S-boxes, etc.)
// --------------------------------------------------------------------------
`include "spn_sbox_pkg.sv"              // <-- if your core needs it

module tb_spn_simple;

  //--------------------------------------------------------------------
  // 1) Clock & reset
  //--------------------------------------------------------------------
  logic clk = 0;
  always #5 clk = ~clk;                 // 100 MHz clock (10 ns period)

  logic rst;
  initial begin
    rst = 1;                // assert reset for 4 cycles
    repeat (4) @(posedge clk);
    rst = 0;
  end

  //--------------------------------------------------------------------
  // 2) Instantiate interface & DUT
  //--------------------------------------------------------------------
  spn_if #(.DW(16), .KW(32)) bus (clk, rst);

  // DUT ports connect through the interface’s *dut* modport
  spn_cu_top dut (bus);

  //--------------------------------------------------------------------
  // 3) Local variables (test vectors)
  //--------------------------------------------------------------------
  localparam  [15:0] PLAINTEXT = 16'h1234;
  localparam  [31:0] SECRETKEY = 32'h0F0E_0D0C;

  logic [15:0] ciphertext;
  logic [15:0] plaintext_after_dec;

  //--------------------------------------------------------------------
  // 4) Stimulus + checks
  //--------------------------------------------------------------------
  initial begin
    // Initialise interface outputs
    bus.opcode               = 2'b00;
    bus.data_in              = '0;
    bus.symmetric_secret_key = SECRETKEY;

    // Wait until reset is released
    @(negedge rst);

    //---------------- ENCRYPT ----------------------------------------
    @(posedge clk);
    bus.data_in = PLAINTEXT;
    bus.opcode  = 2'b01;                  // encrypt command

    @(posedge clk);                       // single-cycle latency in core
    assert (bus.valid == 2'b01)
      else $fatal("[TB] Encrypt valid flag not set!");

    ciphertext = bus.data_out;
    $display("[%0t] Ciphertext = 0x%04h", $time, ciphertext);

    //---------------- DECRYPT ----------------------------------------
    @(posedge clk);
    bus.data_in = ciphertext;
    bus.opcode  = 2'b10;                  // decrypt command

    @(posedge clk);
    assert (bus.valid == 2'b10)
      else $fatal("[TB] Decrypt valid flag not set!");

    plaintext_after_dec = bus.data_out;
    $display("[%0t] Decrypted text = 0x%04h", $time,
             plaintext_after_dec);

    //---------------- CHECK  -----------------------------------------
    assert (plaintext_after_dec == PLAINTEXT)
      else $fatal("[TB] *** MISMATCH! Decrypted text != original ***");

    $display("[TB] *** PASS — encryption/decryption round-trip OK ***");
    $finish;
  end

endmodule