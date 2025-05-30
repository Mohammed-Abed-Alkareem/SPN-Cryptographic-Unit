//-------------------------------------------------------------------------
//				testbench.sv
//-------------------------------------------------------------------------

//---------------------------------------------------------------
//including interfcae and testcase files
`include "spn_interface.sv"
`include "spn_base_test.sv"
`include "spn_test.sv"
`include "spn_scoreboard.sv"
//---------------------------------------------------------------

module tbench_top;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  bit clk;
 
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #5 clk = ~clk;
  

  
  //---------------------------------------
  //interface instance
  //---------------------------------------
  spn_if intf(clk);
 
  
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual spn_if)::set(uvm_root::get(),"*","vif",intf);
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test();
  end
  
endmodule