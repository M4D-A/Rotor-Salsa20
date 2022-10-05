module quarter_round_tb;

// Clock and step counter
parameter CLKp = 10;
reg clk = 1'b0;
reg [31:0] ctr = 32'b0;

always begin
	#(CLKp/2) clk = !clk;
end

// Unit test data and control
reg [31:0] a_unit_data [15:0];
reg [31:0] b_unit_data [15:0];
reg [31:0] c_unit_data [15:0];
reg [31:0] d_unit_data [15:0];
reg [31:0] correct_ctr = 32'b0;
reg test_passed  = 1'b0;

wire a_correct;
wire b_correct;
wire c_correct;
wire d_correct;

// Testbench block IO
reg [31:0] a_in;
reg [31:0] b_in;
reg [31:0] c_in;
reg [31:0] d_in;

wire [31:0] a_out;
wire [31:0] b_out;
wire [31:0] c_out;
wire [31:0] d_out;

// Success conditions
assign a_correct = (a_out == a_unit_data[ctr]) ? 1'b1 : 1'b0;
assign b_correct = (b_out == b_unit_data[ctr]) ? 1'b1 : 1'b0;
assign c_correct = (c_out == c_unit_data[ctr]) ? 1'b1 : 1'b0;
assign d_correct = (d_out == d_unit_data[ctr]) ? 1'b1 : 1'b0;

// Initialize unit test data
initial begin
    a_unit_data[00] <= 32'h981E8457; 
    a_unit_data[01] <= 32'h35C58BD8; 
    a_unit_data[02] <= 32'hD57AFB68; 
    a_unit_data[03] <= 32'h7253CE9B; 
    a_unit_data[04] <= 32'hBE75D056; 
    a_unit_data[05] <= 32'h099A736E; 
    a_unit_data[06] <= 32'h74B28ED7; 
    a_unit_data[07] <= 32'hFE96DE05; 
    a_unit_data[08] <= 32'hA445D728; 
    a_unit_data[09] <= 32'h38BBA24F; 
    a_unit_data[10] <= 32'h44F45639; 
    a_unit_data[11] <= 32'h9ACD4FDF; 
    a_unit_data[12] <= 32'hD6E76427; 
    a_unit_data[13] <= 32'h97DC3735; 
    a_unit_data[14] <= 32'hA493DD4E; 
    a_unit_data[15] <= 32'hA452CA8B; 

    b_unit_data[00] <= 32'h00000282; 
    b_unit_data[01] <= 32'h97922F1E; 
    b_unit_data[02] <= 32'hB5575652; 
    b_unit_data[03] <= 32'hCAEA50FE; 
    b_unit_data[04] <= 32'h024B9D68; 
    b_unit_data[05] <= 32'hA2A30324; 
    b_unit_data[06] <= 32'h312E470E; 
    b_unit_data[07] <= 32'hC49981DD; 
    b_unit_data[08] <= 32'h9F2D55E2; 
    b_unit_data[09] <= 32'h9184AA47; 
    b_unit_data[10] <= 32'hC3C44661; 
    b_unit_data[11] <= 32'h7B033904; 
    b_unit_data[12] <= 32'hBF762727; 
    b_unit_data[13] <= 32'hF5C4F106; 
    b_unit_data[14] <= 32'hA6FA4294; 
    b_unit_data[15] <= 32'hB292A2CE; 

    c_unit_data[00] <= 32'h00050603; 
    c_unit_data[01] <= 32'h6163EC5C; 
    c_unit_data[02] <= 32'h58A7B98A; 
    c_unit_data[03] <= 32'h923F74CA; 
    c_unit_data[04] <= 32'hACE77223; 
    c_unit_data[05] <= 32'h9D4186E1; 
    c_unit_data[06] <= 32'h0C357E94; 
    c_unit_data[07] <= 32'h941416E6; 
    c_unit_data[08] <= 32'h1C73D9DD; 
    c_unit_data[09] <= 32'h897107B6; 
    c_unit_data[10] <= 32'h76A0664E; 
    c_unit_data[11] <= 32'h99BE1D31; 
    c_unit_data[12] <= 32'h1F501185; 
    c_unit_data[13] <= 32'h47FA4A1C; 
    c_unit_data[14] <= 32'hEB09D861; 
    c_unit_data[15] <= 32'hA609E0CF; 

    d_unit_data[00] <= 32'hA110A004;
    d_unit_data[01] <= 32'h627FFF1A;
    d_unit_data[02] <= 32'h83847EA5;
    d_unit_data[03] <= 32'hBB3D7500;
    d_unit_data[04] <= 32'hDACC00E6;
    d_unit_data[05] <= 32'h4B8CA71A;
    d_unit_data[06] <= 32'h3338E0B6;
    d_unit_data[07] <= 32'h80208BA3;
    d_unit_data[08] <= 32'hA5D77CD7;
    d_unit_data[09] <= 32'h13E8DF89;
    d_unit_data[10] <= 32'h867D38C5;
    d_unit_data[11] <= 32'hACBB9A5D;
    d_unit_data[12] <= 32'h6BAE0185;
    d_unit_data[13] <= 32'h8CCA4632;
    d_unit_data[14] <= 32'h0F94F472;
    d_unit_data[15] <= 32'h9FE75F61;
end

// Initialize testbenched block inputs
initial begin
    a_in = 32'h1;
    b_in = 32'h2;
    c_in = 32'h3;
    d_in = 32'h4;
end

// Testbench block control
always @ (posedge(clk)) begin
    a_in <= a_out; // Forward output to input
    b_in <= b_out;
    c_in <= c_out;
    d_in <= d_out;

    correct_ctr <= (a_correct & b_correct & c_correct & d_correct) ? correct_ctr + 1'b1 : correct_ctr;
    test_passed <= (correct_ctr == 31'd16) ? 1'b1 : 1'b0;
    
    if(ctr == 31'd16) begin
        if(correct_ctr == 16) begin
            $display("TEST PASSED: ", correct_ctr," /16 correct results");
        end 
        else begin
            $display("TEST FAILED", correct_ctr);
        end
        $finish;
    end 

    ctr <= ctr + 1'b1;
end

quarter_round tb_block(
    .a_in(a_in),
    .b_in(b_in),
    .c_in(c_in),
    .d_in(d_in),

    .a_out(a_out),
    .b_out(b_out),
    .c_out(c_out),
    .d_out(d_out)
);

endmodule	