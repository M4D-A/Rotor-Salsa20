module quarter_round(
    input wire [31 : 0]  a_in,
    input wire [31 : 0]  b_in,
    input wire [31 : 0]  c_in,
    input wire [31 : 0]  d_in,

    output wire [31 : 0] a_out,
    output wire [31 : 0] b_out,
    output wire [31 : 0] c_out,
    output wire [31 : 0] d_out
);

wire [31 : 0] ad_sum;
wire [31 : 0] ba_sum;
wire [31 : 0] cb_sum;
wire [31 : 0] dc_sum;

wire [31 : 0] a_temp;
wire [31 : 0] b_temp;
wire [31 : 0] c_temp;
wire [31 : 0] d_temp;

assign ad_sum = a_in + d_in;
assign b_temp = b_in ^ {ad_sum[24:0], ad_sum[31:25]};

assign ba_sum = b_temp + a_in;
assign c_temp = c_in ^ {ba_sum[22:0], ba_sum[31:23]};

assign cb_sum = c_temp + b_temp;
assign d_temp = d_in ^ {cb_sum[18:0], cb_sum[31:19]};

assign dc_sum = d_temp + c_temp;
assign a_temp = a_in ^ {dc_sum[13:0], dc_sum[31:14]};

assign a_out = a_temp;
assign b_out = b_temp;
assign c_out = c_temp;
assign d_out = d_temp;
					 
endmodule // salsa20_qr
