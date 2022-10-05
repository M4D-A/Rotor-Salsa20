module double_round(
    input wire [511 : 0] d_in,
    output wire [511 : 0] d_out
);

wire [31 : 0] in [0 : 15];
wire [31 : 0] out [0 : 15];

wire [31 : 0] temp [0 : 15];

for(genvar i = 0; i < 16; i = i + 1) begin
    assign in[i] = d_in[i * 32 + 31 : i * 32];
    assign d_out[i * 32 + 31 : i * 32] = out[i];
end

// ODD ROUND
quarter_round unit_c0(
    .a_in(in[00]),
    .b_in(in[04]),
    .c_in(in[08]),
    .d_in(in[12]),

    .a_out(temp[00]),
    .b_out(temp[04]),
    .c_out(temp[08]),
    .d_out(temp[12])
);

quarter_round unit_c1(
    .a_in(in[05]),
    .b_in(in[09]),
    .c_in(in[13]),
    .d_in(in[01]),

    .a_out(temp[05]),
    .b_out(temp[09]),
    .c_out(temp[13]),
    .d_out(temp[01])
);

quarter_round unit_c2(
    .a_in(in[10]),
    .b_in(in[14]),
    .c_in(in[02]),
    .d_in(in[06]),

    .a_out(temp[10]),
    .b_out(temp[14]),
    .c_out(temp[02]),
    .d_out(temp[06])
);

quarter_round unit_c3(
    .a_in(in[15]),
    .b_in(in[03]),
    .c_in(in[07]),
    .d_in(in[11]),

    .a_out(temp[15]),
    .b_out(temp[03]),
    .c_out(temp[07]),
    .d_out(temp[11])
);

// EVEN ROUND
quarter_round unit_r0(
    .a_in(temp[00]),
    .b_in(temp[01]),
    .c_in(temp[02]),
    .d_in(temp[03]),

    .a_out(out[00]),
    .b_out(out[01]),
    .c_out(out[02]),
    .d_out(out[03])
);

quarter_round unit_r1(
    .a_in(temp[05]),
    .b_in(temp[06]),
    .c_in(temp[07]),
    .d_in(temp[04]),

    .a_out(out[05]),
    .b_out(out[06]),
    .c_out(out[07]),
    .d_out(out[04])
);

quarter_round unit_r2(
    .a_in(temp[10]),
    .b_in(temp[11]),
    .c_in(temp[08]),
    .d_in(temp[09]),

    .a_out(out[10]),
    .b_out(out[11]),
    .c_out(out[08]),
    .d_out(out[09])
);

quarter_round unit_r3(
    .a_in(temp[15]),
    .b_in(temp[12]),
    .c_in(temp[13]),
    .d_in(temp[14]),

    .a_out(out[15]),
    .b_out(out[12]),
    .c_out(out[13]),
    .d_out(out[14])
);
					 
endmodule // salsa20_qr
