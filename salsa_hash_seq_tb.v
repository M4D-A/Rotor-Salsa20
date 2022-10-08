module salsa_hash_seq_tb;

// Clock and step counter
parameter CLKp = 10;
reg clk = 1'b0;
reg [31:0] ctr = 32'b0;

always begin
	#(CLKp/2) clk = !clk;
end

always @(posedge clk) begin
    ctr <= ctr + 1;
end

wire ready;
wire writes;
wire [7 : 0] out;
 

salsa_hash_seq tb_block(
    .clk(clk),
    .start(1'b1),
    .reset(1'b0),

    .ready(ready),
    .writes(writes),

    .data_in(32'h0),
    
    .data_out(out)
);
endmodule