module salsa (
	input   wire         CLK,
	input   wire         RST_N,
	input   wire         SET_KEY,
	input   wire         SET_COUNT,
	input   wire         START_ENC,
	input   wire [127:0] DATA_IN,
	input   wire [255:0] KEY_IN,
	output  wire         BUSY,
	output  wire [127:0] DATA_OUT
);

parameter
	IDLE			= 8'h00,
	KEY_SET			= 8'h01,
	COUNTER_SET	= 8'h02,
	ENC				= 8'h03,
	COUNTER_INC		= 8'h04;

reg [7 : 0] state = IDLE;
reg [7 : 0] enc_counter = 8'h00;
reg [1 : 0] output_counter = 2'h00;

reg [255 : 0] key;
reg [127 : 0] nonce;
reg [127 : 0] counter;

reg [511 : 0] data;
reg [511 : 0] data_copy;

wire [511 : 0] odd_out;
wire [511 : 0] even_out;

odd_round oddr(
    .data_in(data),
    .data_out(odd_out)
);

even_round evenr(
    .data_in(data), 
    .data_out(even_out)
);

assign BUSY = (state != IDLE);
assign DATA_OUT = data[127 : 0];

always @(posedge CLK or negedge RST_N) begin

	if(~RST_N) begin
		state <= IDLE;
        enc_counter <= 'b0;
        key <= 'b0;
		counter <= 'b0;
        data <= 'b0;
        data_copy <= 'b0;
	end

	else begin
		case(state)
			IDLE: begin
				if(SET_KEY) begin
                    key <= KEY_IN;
					state <= KEY_SET;
				end

				else if(SET_COUNT) begin
                    nonce   <= DATA_IN[063:000];
					counter <= DATA_IN[127:064];
					state   <= COUNTER_SET;
				end

				else if(START_ENC) begin
					state <= ENC;
				end

				else begin
					state <= IDLE;
				end
			end

			COUNTER_SET: begin
				state <= IDLE;
			end
				
			KEY_SET: begin
				state <= IDLE;
			end

			ENC: begin
                if(output_counter != 0) begin
                    data <= {128'b0, data[511:128]};
                    output_counter <= output_counter + 1;
                    state <= IDLE;
                end

                else begin
                    if(enc_counter == 0) begin
                        data[159 : 032] <= key[127 : 000];  //key[3:0]
                        data[479 : 352] <= key[255 : 128];  //key[7:4]
                        data[255 : 192] <= nonce;           //nonce[1:0]
                        data[319 : 256] <= counter;         //pos[1:0]
                        data[031 : 000] <= 32'h61707865;
                        data[191 : 160] <= 32'h3320646e;
                        data[351 : 320] <= 32'h79622d32;
                        data[511 : 480] <= 32'h6b206574;
                        
                        enc_counter <= enc_counter + 1;
                    end

                    else if(enc_counter == 1) begin
                        data_copy <= data;
                        enc_counter <= enc_counter + 1;
                    end

                    else if( (enc_counter >= 2) && (enc_counter <= 21) ) begin
                        if(enc_counter % 2 == 0) begin
                            data <= odd_out;
                        end
                        else begin
                            data <= even_out;
                        end
                        enc_counter <= enc_counter + 1;
                    end

                    else if(enc_counter == 22) begin
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

                        output_counter <= 1;
                        enc_counter <= 0;
                        counter <= counter + 1;
                        state <= COUNTER_INC;
                        
                    end
                end
			end

			COUNTER_INC: begin
				state <= IDLE;
			end
				
			default: begin
				state <= IDLE;
			end
		endcase
	end
end	
	



endmodule 