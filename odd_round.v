module odd_round(
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

// ODD ROUND
quarter_round unit_c0(
    .a_in(in[00]),
    .b_in(in[04]),
    .c_in(in[08]),
    .d_in(in[12]),

    .a_out(out[00]),
    .b_out(out[04]),
    .c_out(out[08]),
    .d_out(out[12])
);

quarter_round unit_c1(
    .a_in(in[05]),
    .b_in(in[09]),
    .c_in(in[13]),
    .d_in(in[01]),

    .a_out(out[05]),
    .b_out(out[09]),
    .c_out(out[13]),
    .d_out(out[01])
);

quarter_round unit_c2(
    .a_in(in[10]),
    .b_in(in[14]),
    .c_in(in[02]),
    .d_in(in[06]),

    .a_out(out[10]),
    .b_out(out[14]),
    .c_out(out[02]),
    .d_out(out[06])
);

quarter_round unit_c3(
    .a_in(in[15]),
    .b_in(in[03]),
    .c_in(in[07]),
    .d_in(in[11]),

    .a_out(out[15]),
    .b_out(out[03]),
    .c_out(out[07]),
    .d_out(out[11])
);
					 
endmodule // salsa20_qr
