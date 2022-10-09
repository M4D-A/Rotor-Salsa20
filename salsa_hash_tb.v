module salsa_hash_tb;

// Clock and step counter
parameter CLKp = 10;
reg clk = 1'b0;

always begin
	#(CLKp/2) clk = !clk;
end

reg [7:0] state = 8'b0;
reg [7:0] counter = 8'b0;
reg [7:0] correct = 8'b0;

reg start;
reg reset;
wire ready;
wire writes;
reg [31 : 0]data_in;
wire [7 : 0] data_out;

reg [31 : 0] input_data [11 : 0];
reg [511 : 0] output_data;
reg [511 : 0] output_data_unit [7 : 0];

salsa_hash tb_block(
    .clk(clk),
    .start(start),
    .reset(reset),
    .ready(ready),
    .writes(writes),
    .data_in(data_in),
    .data_out(data_out)
);

initial begin
    start = 1'b0;
    reset = 1'b0;
    input_data[00] = 32'h1;
    input_data[01] = 32'h2;
    input_data[02] = 32'h3;
    input_data[03] = 32'h4;
    input_data[04] = 32'h5;
    input_data[05] = 32'h6;
    input_data[06] = 32'h7;
    input_data[07] = 32'h8;
    input_data[08] = 32'h9;
    input_data[09] = 32'hA;
    input_data[10] = 32'hB;
    input_data[11] = 32'hC;

    output_data_unit[0] = 512'hDE47B80039E3FA4EE7419247A858F91079D8A4A0BC3C8133223A71CA624D2DDB566A9D8425464CEA721EBEBAE2F310184F9BEFD18679D9CF4F775DD535E7C3D8;
    output_data_unit[1] = 512'h094C453EA4A80D377D8348C43FBAF330823565790091FF1BF94FFA521674367AAEC9D3351CA42A66905AA4CEE8D97A673B15CA8FB340F8863E66E4D686E57C73;
    output_data_unit[2] = 512'h317B924C583716FF517D6466883C27833500FFD9F92DE9FB1B8DAEC8E17EB9F5E5A34A1485FD9C66A6852D3C919DF6B2E986FC8B2C0BDB69EB2C224A2ABCAAA6;
    output_data_unit[3] = 512'h22F6ABEAE215D88DE7B9576DBEC48494360CC4DD49FBC844069E5CEE6D81DB1AB21E2FBE1EF280FAED3A20B4FA0CB99723EB2B0EC3EE760E748D31C9131F0060;
    output_data_unit[4] = 512'hC3C57736C87C563C5D7A983FB7950C095C0EF098AEA140BBCCCE963647A1F86582ADDFCD02F260D212FE0F15037983C7A042766BA575879FF2619F50F5E6721C;
    output_data_unit[5] = 512'hF234F032D1CEEBF3C6F940DD376F8E00F14A9015A40934A13604C2F62BC20EB2B158A5899FB38DFC17451B9DDDCBDE505D2353AC5E2130FA7D1D130743D93732;
    output_data_unit[6] = 512'h2A5E6C03F2B19A05B6A919286C0E4015DCE44864FA934C7505B2AC398AA9DDA77DE3241E3FACAEE76CFF7AE38F3C400E8B866289ABE9A26468E6C3BF91440B8D;
    output_data_unit[7] = 512'hC187BF889230270FE51E0DD297C209D1539950C7B7257E8FEFD3E1BD22151B0A738B819570BFDE906AC8B5ABE2B5F51CF9B98AA20023CF9D3D0922A13B40E435;
end

always @(posedge clk) begin
    if(state == 0  && ready == 1) begin
        state <= 1;
        start <= 1;
        data_in <= input_data[counter];
        input_data[counter] <= input_data[counter] * 2 + 1;
        counter <= counter + 1;
    end 

    if(state == 1) begin
        start <= 0;
        data_in <= input_data[counter];
        input_data[counter] <= input_data[counter] * 2 + 1;
        counter <= counter + 1;
        if(counter == 15) begin
            data_in <= 32'bx;
            counter <= 0;
            state <= 2;
        end
    end

    if(state == 2) begin // wait for output and read first byte
        if(writes == 1) begin
            output_data[511 : 504] <= data_out;
            output_data[503 : 0] <= output_data[511 : 8];
            state <= 3;
        end
    end

    if(state == 3) begin // read data
        if(writes == 1) begin
            output_data[511 : 504] <= data_out;
            output_data[503 : 0] <= output_data[511 : 8];
        end
        else begin // finished reading
            if(output_data == output_data_unit[correct]) begin // check if correct
                correct = correct + 1;
                if(correct == 8) begin // all correct
                    $display("Test passed");
                    $finish;
                end
                state <= 0; // start next test
            end
            else begin // not correct
                $display("Error");
                $finish;
            end
            output_data <= 512'bx;
        end
    end
end

endmodule