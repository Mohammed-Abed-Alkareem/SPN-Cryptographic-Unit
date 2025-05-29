module tb_top;
  import spn_cu_pkg::*;	
  
  // Clock & reset
  logic clk, rst;
  
  // DUT outputs
  logic [15:0] generated_ciphertext;
  logic [15:0] recovered_plaintext;
  
  //Reference model outputs
  logic [15:0] rmodel_ciphertext;
  logic [15:0] rmodel_recovered_plaintext;
  
  //Intermediate Values for Debugging
  logic [15:0] key_mix_out [0:2];  // Result of each xor operation excluding the last one which results in the output (Encryption/Decryption)
  logic [15:0] sbox_out [0:2];     // Result of each sbox (Encryption/Decryption)
  logic [15:0] pbox_out [0:2];     // Result of each pbox (Encryption/Decryption)
  
  // Instantiate the reference model class
  SPNReferenceModel rmodel;
  
  //Generating the clock
  always #5 clk = ~clk;                 
  
  //Clock & reset initialization
  initial begin
    clk = 0;
    rst = 1;
    @(posedge clk);	//Wait for positive clock edge
    rst = 0;
  end

  
  //Instantiate interface & DUT
  spn_if bus (clk, rst);

  // DUT ports connect through the interface's dut modport
  spn_cu_top dut (bus, key_mix_out, sbox_out, pbox_out);

  // Applying Stimulus
  initial begin
    // Create the reference model instance
    rmodel = new();
    
    // Initialise interface modport inputs
    bus.opcode               = no_op;
    bus.data_in              = '0;
    bus.symmetric_secret_key = '0;

    // Wait until reset is released
    @(negedge rst);

    // Run multiple randomized tests
    repeat (10) begin
      // Randomize the reference model inputs
      if (!rmodel.randomize()) begin
        $fatal(1, "[TB] Randomization failed!");
      end
      
      $display("\n=== Test with randomized inputs ===");
      $display("[%0t] Random Plaintext = 0x%04h", $time, rmodel.data_in);
      $display("[%0t] Random Key = 0x%08h", $time, rmodel.symmetric_secret_key);

      // ENCRYPT
      @(posedge clk);
      // DUT inputs using randomized values
      bus.data_in = rmodel.data_in;
      bus.symmetric_secret_key = rmodel.symmetric_secret_key;
      bus.opcode  = encrypt;                  // encrypt command
      
      //Reference model call for encryption
      rmodel.mode = ENCRYPT;
      rmodel_ciphertext = rmodel.process(rmodel.data_in, rmodel.symmetric_secret_key, ENCRYPT);

      // Wait for two cycles to make sure the output is ready
      @(posedge clk);                      
      @(posedge clk);		
      
      // Check if the output is valid
      assert (bus.valid == successful_encryption)
        else $fatal(1, "[TB] Encrypt valid flag not set!");

      //Get the ciphertext
      generated_ciphertext = bus.data_out;
      
      $display("[%0t] key_mix0 = 0x%04h", $time, key_mix_out[0]);
      $display("[%0t] sbox0 = 0x%04h", $time, sbox_out[0]);
      $display("[%0t] pbox0 = 0x%04h", $time, pbox_out[0]);
      
      $display("[%0t] key_mix1 = 0x%04h", $time, key_mix_out[1]);
      $display("[%0t] sbox1 = 0x%04h", $time, sbox_out[1]);
      $display("[%0t] pbox1 = 0x%04h", $time, pbox_out[1]);
      
      $display("[%0t] key_mix2 = 0x%04h", $time, key_mix_out[2]);
      $display("[%0t] sbox2 = 0x%04h", $time, sbox_out[2]);
      $display("[%0t] pbox2 = 0x%04h", $time, pbox_out[2]);
      
      $display("[%0t] Ciphertext (DUT) = 0x%04h", $time, generated_ciphertext);
      $display("[%0t] Ciphertext (RM) = 0x%04h", $time, rmodel_ciphertext);
      
      assert (generated_ciphertext == rmodel_ciphertext)
          else $fatal(3, "[TB] Nonmatching outputs between DUT and Reference Model (ciphertext)!");

      // DECRYPT
      @(posedge clk);
      // Input = encrypted plaintext
      // DUT inputs
      bus.data_in = generated_ciphertext;
      bus.opcode  = decrypt;                  // decrypt command
      
      //Reference model call for decryption
      rmodel_recovered_plaintext = rmodel.process(rmodel_ciphertext, rmodel.symmetric_secret_key, DECRYPT);
      
      // Wait for two cycles to make sure the output is ready
      @(posedge clk);
      @(posedge clk);
      assert (bus.valid == successful_decryption)
        else $fatal(2, "[TB] Decrypt valid flag not set!");

      //Get the recovered plaintext
      recovered_plaintext = bus.data_out;
      
      $display("-----------------------");
      $display("[%0t] Ciphertext(RM) = 0x%04h", $time, rmodel_ciphertext);
      $display("[%0t] Ciphertext(DUT) = 0x%04h", $time, generated_ciphertext);
      
      $display("[%0t] pbox0 = 0x%04h", $time, pbox_out[0]);
      $display("[%0t] invsbox0 = 0x%04h", $time, sbox_out[0]);
      $display("[%0t] key_mix0 = 0x%04h", $time, key_mix_out[0]);
      
      $display("[%0t] pbox1 = 0x%04h", $time, pbox_out[1]);
      $display("[%0t] invsbox1 = 0x%04h", $time, sbox_out[1]);
      $display("[%0t] key_mix1 = 0x%04h", $time, key_mix_out[1]);
      
      $display("[%0t] pbox2 = 0x%04h", $time, pbox_out[2]);
      $display("[%0t] invsbox2 = 0x%04h", $time, sbox_out[2]);
      $display("[%0t] key_mix2 = 0x%04h", $time, key_mix_out[2]);

      $display("[%0t] Recovered Plaintext (DUT) = 0x%04h", $time, recovered_plaintext);
      $display("[%0t] Recovered Plaintext (RM) = 0x%04h", $time, rmodel_recovered_plaintext);

      assert (recovered_plaintext == rmodel_recovered_plaintext)
        else $fatal(3, "[TB] Nonmatching outputs between DUT and Reference Model (recovered plaintext)!");
            
      // Check if the decrypted ciphertext = original plaintext
      assert (recovered_plaintext == rmodel.data_in)
        else $fatal(3, "[TB] *** MISMATCH! Decrypted text != original in DUT ***");

      $display("[TB] *** PASS – encryption/decryption round-trip OK for this test ***");
    end
    
    $display("\n[TB] *** ALL TESTS PASSED – All randomized encryption/decryption round-trips OK ***");
    $finish;
  end

endmodule
