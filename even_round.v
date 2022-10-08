module even_round(
    input wire [511 : 0] d_in,
    output wire [511 : 0] d_out
);

wire [31 : 0] in [0 : 15];
wire [31 : 0] out [0 : 15];

genvar i;
generate
for(i = 0; i < 16; i = i + 1) begin : wire_generator 
	assign in[i] = d_in[i * 32 + 31 : i * 32];
	assign d_out[i * 32 + 31 : i * 32] = out[i];
end
endgenerate

// EVEN ROUND
quarter_round unit_r0(
    .a_in(in[00]),
    .b_in(in[01]),
    .c_in(in[02]),
    .d_in(in[03]),

    .a_out(out[00]),
    .b_out(out[01]),
    .c_out(out[02]),
    .d_out(out[03])
);

quarter_round unit_r1(
    .a_in(in[05]),
    .b_in(in[06]),
    .c_in(in[07]),
    .d_in(in[04]),

    .a_out(out[05]),
    .b_out(out[06]),
    .c_out(out[07]),
    .d_out(out[04])
);

quarter_round unit_r2(
    .a_in(in[10]),
    .b_in(in[11]),
    .c_in(in[08]),
    .d_in(in[09]),

    .a_out(out[10]),
    .b_out(out[11]),
    .c_out(out[08]),
    .d_out(out[09])
);

quarter_round unit_r3(
    .a_in(in[15]),
    .b_in(in[12]),
    .c_in(in[13]),
    .d_in(in[14]),

    .a_out(out[15]),
    .b_out(out[12]),
    .c_out(out[13]),
    .d_out(out[14])
);
					 
endmodule // salsa20_qr
