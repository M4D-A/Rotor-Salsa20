module salsa_tb;

// Clock and step counter
parameter CLKp = 10;
reg clk = 1'b0;

always begin
	#(CLKp/2) clk = !clk;
end

reg [7:0] state = 8'b0;
reg [7:0] counter = 8'b0;

reg              start = 0;
reg              rst_n = 1;
reg              set_key = 0;
reg              set_count = 0;
reg              start_enc = 0;
reg  [127 : 000] data_in = 0;
reg  [255 : 000] key_in = 0;
wire             busy;
wire [127 : 000] data_out;

salsa tb_block(
	.CLK(clk),
	.RST_N(rst_n),
	.SET_KEY(set_key),
	.SET_COUNT(set_count),
	.START_ENC(start_enc),
	.DATA_IN(data_in),
	.KEY_IN(key_in),
	.BUSY(busy),
	.DATA_OUT(data_out)
);

always @(posedge clk) begin
    if(state == 0  && busy == 0) begin
        state <= 1;
        set_key <= 1;
    end

    else if(state == 1 && busy == 0) begin
        state <= 2;
        set_key <= 0;
        set_count <= 1;
    end

    else if(state == 2 && busy == 0) begin
        state <= 3;
        set_count <= 0;
        start_enc <= 1;
    end

    else if(state == 3 && busy == 0) begin
        state <= 4;
        start_enc <= 0;
    end

    else if(state == 4) begin
        if(busy == 0) begin
            start_enc <= 1;
        end
        else begin
            start_enc <= 0;
        end
        state <= 4;
    end
    
end

endmodule