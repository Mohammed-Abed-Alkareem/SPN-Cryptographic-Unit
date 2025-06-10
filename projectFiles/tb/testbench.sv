`include "uvm_macros.svh"

`include "spn_if.sv"
`include "spn_tb_pkg.sv"  

module testbench;
  import spn_tb_pkg::*;  // Import the package
  //clock and reset signal declaration
  logic clk, rst;
  
  initial begin 
    clk = 0;
    forever #5 clk = ~clk; //toggle clock every 5 time units
  end

  initial begin 
    rst = 1;
    #10 rst = 0; //release reset after 10 time units
  end

  spn_if spn_interface (clk, rst);  
  
  spn_cu_top dut (
    .bus(spn_interface)
  );

  initial begin 
    uvm_config_db#(virtual spn_if)::set(uvm_root::get(), "*", "vif", spn_interface);
    uvm_config_db#(string)::set(null, "*", "sequence_type", "spn_sequence_encryption_decryption");
    //uvm_config_db#(int)::set(null, "*", "num_transactions", 15);
    // uvm_config_db#(int)::set(null, "*", "encrypt_transactions", 10);
    // uvm_config_db#(int)::set(null, "*", "decrypt_transactions", 8);
    // uvm_config_db#(int)::set(null, "*", "noop_transactions", 3);
    // uvm_config_db#(int)::set(null, "*", "undefined_transactions", 2);
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
    initial begin
    run_test("spn_test");
  end
  
endmodule