/******************************************************************/
//MODULE:       LCD_CTRL
//FILE NAME:    LCD_CTRL.v
//VERSION:		1.0
//DATE:			May,2018
//AUTHOR: 		charlotte-mu
//CODE TYPE:	RTL
//DESCRIPTION:	2018 IC Design Contest Preliminary
//
//MODIFICATION HISTORY:
// VERSION Date Description
// 1.0 05/06/2018 test pattern all pass
/******************************************************************/
module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output reg IROM_rd;
output reg [5:0] IROM_A;
output reg IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output reg busy;
output reg done;

reg [7:0]data[0:63];
reg [5:0]x,y;
reg rd,t;
wire [5:0]a,b,c,d;
wire [9:0]max1,max2,min1,min2,ave;

assign a = b-6'd1;
assign b = ((y-6'd1)*6'd8)+x;
assign c = d-6'd1;
assign d = (y*6'd8)+x;

assign ave = (max1 + min2 + max2 + min1)/10'd4;

assign max1 = (data[a] > data[b])? data[a] : data[b];
assign max2 = (data[c] > data[d])? data[c] : data[d];
assign min1 = (data[a] < data[b])? data[a] : data[b];
assign min2 = (data[c] < data[d])? data[c] : data[d];

always@(posedge clk,posedge reset)
begin
	if(reset == 1'b1)
	begin
		IROM_rd <= 1'b1;
		IROM_A <= 6'd0;
		IRAM_valid <= 1'b0;
		IRAM_A <= 6'd0;
		IRAM_D <= 8'd0;
		done <= 1'b0;
		rd <= 1'b0;
		x <= 3'd4;
		y <= 3'd4;
		busy <= 1'b1;
		t <= 1'b0;
	end
	else
	begin
		if(rd == 1'b0)
		begin
			if(IROM_A == 6'd63)
			begin
				rd <= 1'b1;
				busy <= 1'b0;
				IROM_A <= 6'd0;
				data[IROM_A] <= IROM_Q;
			end
			else
			begin
				busy <= 1'b1;
				data[IROM_A] <= IROM_Q;
				IROM_A <= IROM_A + 6'd1;
			end
		end
		else
		begin
			case(cmd)
				4'd0:
				begin
					if(IRAM_A == 6'd63)
					begin
						IRAM_valid <= 1'b0;
						busy <= 1'b0;
						IRAM_A <= 6'd0;
						done <= 1'b1;
						IRAM_D <= data[IRAM_A];
					end
					else
					begin
						IRAM_valid <= 1'b1;
						busy <= 1'b1;
						if(t == 1'b0)
						begin
							t <= 1'b1;
							IRAM_D <= data[IRAM_A];
						end
						else
						begin
							IRAM_A <= IRAM_A + 6'd1;
							IRAM_D <= data[IRAM_A + 6'd1];
						end
					end
				end
				4'd1:
				begin
					if(y > 3'd1)
						y <= y - 3'd1;
				end
				4'd2:
				begin
					if(y < 3'd7)
						y <= y + 3'd1;
				end
				4'd3:
				begin
					if(x > 3'd1)
						x <= x - 3'd1;
				end
				4'd4:
				begin
					if(x < 3'd7)
						x <= x + 3'd1;
				end
				4'd5:
				begin
					if(max1 > max2)
					begin
						data[a] <= max1[7:0];
						data[b] <= max1[7:0];
						data[c] <= max1[7:0];
						data[d] <= max1[7:0];
					end
					else
					begin
						data[a] <= max2[7:0];
						data[b] <= max2[7:0];
						data[c] <= max2[7:0];
						data[d] <= max2[7:0];
					end
				end
				4'd6:
				begin
					if(min1 < min2)
					begin
						data[a] <= min1[7:0];
						data[b] <= min1[7:0];
						data[c] <= min1[7:0];
						data[d] <= min1[7:0];
					end
					else
					begin
						data[a] <= min2[7:0];
						data[b] <= min2[7:0];
						data[c] <= min2[7:0];
						data[d] <= min2[7:0];
					end
				end
				4'd7:
				begin
					data[a] <= ave[7:0];
					data[b] <= ave[7:0];
					data[c] <= ave[7:0];
					data[d] <= ave[7:0];
				end
				4'd8:
				begin
					data[a] <= data[b];
					data[b] <= data[d];
					data[c] <= data[a];
					data[d] <= data[c];
				end
				4'd9:
				begin
					data[a] <= data[c];
					data[b] <= data[a];
					data[c] <= data[d];
					data[d] <= data[b];
				end
				4'd10:
				begin
					data[a] <= data[c];
					data[b] <= data[d];
					data[c] <= data[a];
					data[d] <= data[b];
				end
				4'd11:
				begin
					data[a] <= data[b];
					data[b] <= data[a];
					data[c] <= data[d];
					data[d] <= data[c];
				end
			endcase
		end
	end
end


endmodule
