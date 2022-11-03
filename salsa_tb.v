module salsa_tb;

// Clock and step counter
parameter CLKp = 10;
reg clk = 1'b0;

always begin
	#(CLKp/2) clk = !clk;
end

reg [7:0] state = 8'b0;
reg [7:0] correct_counter = 8'b0;

reg              start = 0;
reg              rst_n = 1;
reg              set_key = 0;
reg              set_count = 0;
reg              start_enc = 0;

reg  [063 : 000] nonce_in   = 64'h1234567890ABCDEF;
reg  [063 : 000] counter_in = 64'h0;
reg  [255 : 000] key_in     = 256'h1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF;
wire             busy;
wire [127 : 000] data_out;

reg  [127: 000] unit_data [0:15];

initial begin
    unit_data[03] <= 128'h12578220342d7c2f68a8e8e7cfb1543d;
    unit_data[02] <= 128'h16a4a8721524a56fda7e0a6b26d31087;
    unit_data[01] <= 128'h44cdfda43839020d407db3dad7e5b67f;
    unit_data[00] <= 128'hdf8db6c12f790bfbef7da88d5d04e680;

    unit_data[07] <= 128'h9651743753ab9d75a2c155291f5f4a96;
    unit_data[06] <= 128'h1d5cd89f6f4ac0bac83701d0defc6916;
    unit_data[05] <= 128'ha749904878e3081e94e2181566a7f753;
    unit_data[04] <= 128'he3ab8c19ec68ee0f47111a42bfb16625;

    unit_data[11] <= 128'h0407219dec54b4fe5ee330c4f034e5a6;
    unit_data[10] <= 128'hd052f2a8d3028c1fd612570c4105d4d7;
    unit_data[09] <= 128'he2c15651fcc07e9271f401abcf45cfac;
    unit_data[08] <= 128'h0ba8c5dd3f396fc39d1dc8674ee2d611;

    unit_data[15] <= 128'h7b9b989380277d402b550767c85c435a;
    unit_data[14] <= 128'h3710984408c2e66964b0edbd6b00a55c;
    unit_data[13] <= 128'hc11cb34e28a6d19e46fa38be942cd89c;
    unit_data[12] <= 128'h036a20bbd36577e290419252e93f0d93;
end


salsa tb_block(
	.CLK(clk),
	.RST_N(rst_n),
	.SET_KEY(set_key),
	.SET_COUNT(set_count),
	.START_ENC(start_enc),
	.DATA_IN({counter_in, nonce_in}),
	.KEY_IN(key_in),
	.BUSY(busy),
	.DATA_OUT(data_out)
);

parameter
	KEY_IN			= 8'h00,
	COUNT_IN		= 8'h01,
	ENC_START		= 8'h02,
	WAIT		    = 8'h03,
    READ            = 8'h04;

always @(posedge clk) begin
    if(state == KEY_IN  && busy == 0) begin
        state <= 1;
        set_key <= 1;
    end

    else if(state == COUNT_IN && busy == 0) begin
        state <= 2;
        set_key <= 0;
        set_count <= 1;
    end

    else if(state == ENC_START && busy == 0) begin
        state <= 3;
        set_count <= 0;
        start_enc <= 1;
    end

    else if(state == WAIT && busy == 0) begin
        state <= 4;
        start_enc <= 0;
    end

    else if(state == READ) begin
        if(busy == 0) begin
            start_enc <= 1;
        end
        else begin
            start_enc <= 0;
        end
        state <= 4;
    end
end

always @(negedge busy) begin
    if(state == READ) begin
        if(data_out == unit_data[correct_counter]) begin
            correct_counter <= correct_counter + 1;
        end
        else begin
            $display("Error: %h != %h", data_out, unit_data[correct_counter]);
        end
    end
end


endmodule