module even_round(
    input wire [511 : 0] data_in,
    output wire [511 : 0] data_out
);

wire [31 : 0] temp_in [0 : 15];
wire [31 : 0] temp_out [0 : 15];

genvar i;
generate
for(i = 0; i < 16; i = i + 1) begin : wire_generator 
	assign temp_in[i] = data_in[i * 32 + 31 : i * 32];
	assign data_out[i * 32 + 31 : i * 32] = temp_out[i];
end
endgenerate

// EVEN ROUND
quarter_round unit_r0(
    .a_in(temp_in[00]),
    .b_in(temp_in[01]),
    .c_in(temp_in[02]),
    .d_in(temp_in[03]),

    .a_out(temp_out[00]),
    .b_out(temp_out[01]),
    .c_out(temp_out[02]),
    .d_out(temp_out[03])
);

quarter_round unit_r1(
    .a_in(temp_in[05]),
    .b_in(temp_in[06]),
    .c_in(temp_in[07]),
    .d_in(temp_in[04]),

    .a_out(temp_out[05]),
    .b_out(temp_out[06]),
    .c_out(temp_out[07]),
    .d_out(temp_out[04])
);

quarter_round unit_r2(
    .a_in(temp_in[10]),
    .b_in(temp_in[11]),
    .c_in(temp_in[08]),
    .d_in(temp_in[09]),

    .a_out(temp_out[10]),
    .b_out(temp_out[11]),
    .c_out(temp_out[08]),
    .d_out(temp_out[09])
);

quarter_round unit_r3(
    .a_in(temp_in[15]),
    .b_in(temp_in[12]),
    .c_in(temp_in[13]),
    .d_in(temp_in[14]),

    .a_out(temp_out[15]),
    .b_out(temp_out[12]),
    .c_out(temp_out[13]),
    .d_out(temp_out[14])
);
					 
endmodule // salsa20_qr
