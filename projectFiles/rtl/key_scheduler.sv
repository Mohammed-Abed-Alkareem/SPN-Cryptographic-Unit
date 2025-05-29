module key_scheduler (
	input logic [31:0] symmetric_secret_key,
	input logic mode,
	output logic [15:0] round_keys [0:2]
	);
	assign round_keys[0] = mode? {symmetric_secret_key[ 7:0], symmetric_secret_key[31:24]} : {symmetric_secret_key[ 7:0], symmetric_secret_key[23:16]};
	assign round_keys[1] =  symmetric_secret_key[15:0];
	assign round_keys[2] = mode? {symmetric_secret_key[ 7:0], symmetric_secret_key[23:16]} : {symmetric_secret_key[ 7:0], symmetric_secret_key[31:24]};
endmodule