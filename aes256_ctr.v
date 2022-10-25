module aes256_ctr (

	input 				CLK,
	input 				RST_N,
	input 				SET_KEY,
	input				SET_COUNT,
	input 				START_ENC,
	input 	[127:0] 	DATA_IN,
	input 	[255:0] 	KEY_IN,
	output 				BUSY,
	output 	[127:0]	DATA_OUT

);

parameter
		IDLE			= 8'h00,
		SET_COUNTER		= 8'h01,
		KEY_GEN			= 8'h02,
		ENC				= 8'h03,
		COUNTER_INC		= 8'h04;
		
		
		
reg[7:0] aes_ctr_state = IDLE;
reg[127:0] counter = 'b0;
wire ciphk_busy;

aes256_ciphk_module ciphk(
	.CLK(CLK),
	.RST_N(RST_N),
	.SET_KEY(SET_KEY),
	.START_ENC(START_ENC),
	.DATA_IN(counter),
	.KEY_IN(KEY_IN),
	.BUSY(ciphk_busy),
	.DATA_OUT(DATA_OUT)
	);
	
always @(posedge CLK or negedge RST_N)
	begin
		if(~RST_N)
		begin
			aes_ctr_state <= IDLE;
			counter <='b0;
			
		end
		else
		begin
			case(aes_ctr_state)
				IDLE:	
				begin	
					if(SET_KEY)
					begin
						aes_ctr_state<=KEY_GEN;
					end
					else if(SET_COUNT)
					begin
						counter <= DATA_IN;
						aes_ctr_state<=SET_COUNTER;
					end
					else if(START_ENC)
					begin
						aes_ctr_state<=ENC;
					end
					else
					begin
						aes_ctr_state<= IDLE;
					end
				end
				SET_COUNTER:
				begin
					aes_ctr_state<= IDLE;
				end
				
				KEY_GEN:
				begin
					if(ciphk_busy)
					begin
						aes_ctr_state<=KEY_GEN;
					end
					else
					begin
						aes_ctr_state<= IDLE;
					end
				end
				ENC:
				begin
					if(ciphk_busy)
					begin
						aes_ctr_state<=ENC;
					end
					else
					begin
						aes_ctr_state<= COUNTER_INC;
						counter<=counter+1'b1;
					end
				end
				COUNTER_INC:
				begin
					aes_ctr_state<= IDLE;
				end
				
				default:
				begin
					aes_ctr_state<= IDLE;
				end
			endcase
		end
	end	
	
assign BUSY = (aes_ctr_state!=IDLE)|ciphk_busy|SET_COUNT;


endmodule 