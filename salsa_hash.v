module salsa_hash(
    input wire clk,
    input wire start,
    input wire reset,

    output wire ready,
    output wire writes,

    input wire [31 : 0] data_in,

    output wire [7 : 0] data_out
);

reg [7 : 0] state;
reg [7 : 0] counter;
reg [511 : 0] data;
reg [511 : 0] data_copy;

wire [511 : 0] odd_out;
wire [511 : 0] even_out;

assign ready = (state == 0);
assign writes = (state == 4);
assign data_out = data[007 : 000];

odd_round oddr(
    .data_in(data),
    .data_out(odd_out)
);

even_round evenr(
    .data_in(data),
    .data_out(even_out)
);

initial begin
    data <= 512'bx;
    data_copy <= 512'bx;

    counter <= 7'b0;
    state <= 7'b0;
end

always @(posedge clk) begin
    if (reset) begin
        state <= 7'b0;
        counter <= 7'b0;
        data <= 512'bx;
        data_copy <= 512'bx;
    end 
    else begin
        case(state)
        0: begin
            if(start == 1) begin // wait for data and read key[0]
                state <= 1;
                counter <= 1;
                data[383:000] <= {data_in, data[383:32]};
            end
        end

        1: begin
            counter <= counter + 1;
            data[383:000] <= {data_in, data[383:32]};
            if (counter == 11) begin
                counter <= 0;
                state <= 2;
            end
        end

        2: begin
            data[159 : 032] <= data[127 : 000]; //key[3:0]
            data[479 : 352] <= data[255 : 128]; //key[7:4]
            data[255 : 192] <= data[309 : 256]; //nonce[1:0]
            data[319 : 256] <= data[383 : 320]; //pos[1:0]
            data[031 : 000] <= 32'h61707865;
            data[191 : 160] <= 32'h3320646e;
            data[351 : 320] <= 32'h79622d32;
            data[511 : 480] <= 32'h6b206574;

            sipo_in <= 384'bx;
            state <= 3;
        end

        3: begin
            if(counter == 0) begin
                data_copy <= data;
                counter <= counter + 1;
            end

            else if( (counter > 0) && (counter < 21) ) begin
                if(counter % 2 == 0) begin
                    data <= even_out;
                end
                else begin
                    data <= odd_out;
                end
                counter <= counter + 1;
            end
            
             
            else if(counter == 21) begin
                data[511:480] <= data[511:480] + data_copy[511:480];
                data[479:448] <= data[479:448] + data_copy[479:448];
                data[447:416] <= data[447:416] + data_copy[447:416];
                data[415:384] <= data[415:384] + data_copy[415:384];
                data[383:352] <= data[383:352] + data_copy[383:352];
                data[351:320] <= data[351:320] + data_copy[351:320];
                data[319:288] <= data[319:288] + data_copy[319:288];
                data[287:256] <= data[287:256] + data_copy[287:256];
                data[255:224] <= data[255:224] + data_copy[255:224];
                data[223:192] <= data[223:192] + data_copy[223:192];
                data[191:160] <= data[191:160] + data_copy[191:160];
                data[159:128] <= data[159:128] + data_copy[159:128];
                data[127:096] <= data[127:096] + data_copy[127:096];
                data[095:064] <= data[095:064] + data_copy[095:064];
                data[063:032] <= data[063:032] + data_copy[063:032];
                data[031:000] <= data[031:000] + data_copy[031:000];
                state <= 4;
                counter <= 0;
            end
        end

        4: begin
            if (counter == 63) begin
                state <= 7'b0;
                counter <= 7'b0;
                data <= 512'bx;
                data_copy <= 512'bx;
            end
            else begin
                data[503 : 000] <= data[511 : 008];
                data[511 : 504] <= 8'bx;
                counter <= counter + 1;
            end
        end
        endcase
    end
end

endmodule
