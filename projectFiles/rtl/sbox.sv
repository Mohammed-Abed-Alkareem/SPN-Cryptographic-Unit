module sbox (
	input logic [15:0] data_in,
	output logic [15:0] data_out
	);

	// 4-bit substitution table (index = input nibble)
	localparam logic [0:15][3:0] SBOX = '{
		4'hA, 4'h5, 4'h8, 4'h2,
		4'h6, 4'hC, 4'h4, 4'h3,
		4'h1, 4'h0, 4'hB, 4'h9,
		4'hF, 4'hD, 4'h7, 4'hE
	};
	
	always_comb begin
        for (int i = 0; i < 16; i += 4) begin
            data_out[i +: 4] = SBOX[data_in[i +: 4]];
        end
    end
	
endmodule