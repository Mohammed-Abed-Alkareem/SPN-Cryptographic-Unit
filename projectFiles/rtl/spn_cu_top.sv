// ============================================================================
//  spn_cu_top — 3-round SPN encryption/decryption core
//  • Single-cycle latency (rounds are combinational)
//  • Separate encrypt & decrypt pipelines
// ============================================================================
`include "spn_sbox_pkg.sv"
module spn_cu_top (spn_if.dut bus);
  import spn_sbox_pkg::*;

  /*-----  Key schedule: derive 3×16-bit round keys ------------------------*/
  logic [15:0] R [0:2];         // forward (encrypt)
  logic [15:0] Ri[0:2];         // reverse (decrypt)

  always_comb begin
    R[0]  = {bus.key_i[ 7:0], bus.key_i[23:16]};
    R[1]  =  bus.key_i[15:0];
    R[2]  = {bus.key_i[ 7:0], bus.key_i[31:24]};
    Ri[0] = R[2];               // reverse order
    Ri[1] = R[1];
    Ri[2] = R[0];
  end

  /*-----  Parallel encrypt/decrypt pipelines ------------------------------*/
  logic [15:0] e[0:3], d[0:3];
  assign e[0] = bus.data_i;
  assign d[0] = bus.data_i;

  for (genvar i = 0; i < 3; i++) begin : G_ROUND
    spn_round u_enc (.data_in(e[i]), .key_mix(R [i]), .data_out(e[i+1]));
    spn_round u_dec (.data_in(d[i]), .key_mix(Ri[i]), .data_out(d[i+1]));
  end

  /*-----  Minimal control / output registers ------------------------------*/
  always_ff @(posedge bus.clk or negedge bus.rst_n) begin
    if (!bus.rst_n) begin 
      bus.valid  <= '0;
      bus.data_o <= '0;
    end
    else begin
      bus.valid <= 2'b00;       // default: “no result”
      unique case (bus.opcode)
        2'b01: begin            // encrypt
          bus.data_o <= e[3];
          bus.valid  <= 2'b01;
        end
        2'b10: begin            // decrypt
          bus.data_o <= d[3];
          bus.valid  <= 2'b10;
        end
      endcase
    end
  end
endmodule
