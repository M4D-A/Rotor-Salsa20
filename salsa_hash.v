module salsa_hash(
    input wire [255 : 0] key_in,
    input wire [63 : 0] nonce_in,
    input wire [63 : 0] counter_in,
    output wire [511 : 0] digest_out
);


wire [511 : 0] data [10:0];

// Magick numbers "expand 32-byte k"
assign data[0][031 : 000] = 31'h61707865;
assign data[0][191 : 160] = 31'h3320646e;
assign data[0][351 : 320] = 31'h79622d32;
assign data[0][511 : 480] = 31'h6b206574;

assign data[0][159 : 032] = key_in[127 : 000];
assign data[0][479 : 352] = key_in[255 : 128];

assign data[0][255 : 192] = nonce_in[063 : 000];

assign data[0][319 : 256] = counter_in[063 : 000];

// 10 double rounds
genvar i;
generate
    for (i=0; i<10; i=i+1) begin : salsa_hash_generator // <-- example block name
        double_round double_round_i(
            .d_in(data[i]),
            .d_out(data[i+1])
        );
    end 
endgenerate

for(i = 0; i<16; i=i+1) begin
    assign digest_out[32*i+31:32*i] = data[10][32*i+31:32*i] + data[0][32*i+31:32*i];
end

endmodule