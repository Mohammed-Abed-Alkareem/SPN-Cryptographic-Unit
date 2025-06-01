//including interfcae and testcase files
`include "spn_interface.sv"
`include "spn_base_test.sv"
`include "spn_test_encrypt.sv"
`include "spn_test_decrypt.sv"

module tbench_top;

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

  spn_if if (clk, rst);
  spn_cu_top dut (
    .bus(if)
  );

  initial begin 
    uvm_config_db#(virtual spn_if)::set(uvm_root::get(), "*", "vif", if);
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  initial begin
    run_test("spn_test")
    //run_test("spn_test_encrypt");
    //run_test("spn_test_decrypt");
  end
  
endmodule