`timescale 1ns / 1ps



module image_shift(
	input clk,
	input rst,
	input [32-1'b1:0] shift_data_in,
	input [32-1'b1:0] data_in,
	output reg [15:0] shift_data_out
	);
wire  [4:0]shift_num;
assign shift_num=shift_data_in[4:0];
reg [31:0] data [0:4];
reg [4:0] shift [0:3];
always@(posedge clk)
shift[0]<=shift_num;
generate 
genvar i;
for(i=0;i<3;i=i+1)begin
always@(posedge clk)
shift[i+1]<=shift[i];
end
endgenerate
//-----------------ÒÆÎ»-----------------
always@( posedge clk )	begin
	if( rst )begin
		data[0]      <=          32'b0;
	end
	else begin
		case(shift_num[4]) 
		0:data[0]<=data_in;
		1:begin
		  data[0]<={{16{data_in[31]}},data_in[31:16]};
		  end
		endcase
	end
end 
always@( posedge clk )	begin
	if( rst )begin
		data[1]      <=          32'b0;
	end
	else begin
		case(shift[0][3]) 
		0:data[1]<=data[0];
		1:data[1]<={{8{data[0][31]}},data[0][31:8]};
		endcase
	end
end

always@( posedge clk )	begin
	if( rst )begin
		data[2]      <=          32'b0;
	end
	else begin
		case(shift[1][2]) 
		0:data[2]<=data[1];
		1:data[2]<={{4{data[1][31]}},data[1][31:4]};
		endcase
	end
end 

always@( posedge clk )	begin
	if( rst )begin
		data[3]      <=          32'b0;
	end
	else begin
		case(shift[2][1]) 
		0:data[3]<=data[2];
		1:data[3]<={{2{data[2][31]}},data[2][31:2]};
		endcase
	end
end 

always@( posedge clk )	begin
	if( rst )begin
		data[4]      <=          32'b0;
	end
	else begin
		case(shift[3][0]) 
		0:data[4]<=data[3];
		1:data[4]<={data[3][31],data[3][31:1]};
		endcase
	end
end 
//----------------½ØÈ¡²Ù×÷---------------
always@( posedge clk )	begin
	if( rst )begin
		shift_data_out      <=          8'b0;
	end
	else if(data[4][0]==1'b1) 
	     shift_data_out<={data[4][31],data[4][15:1]}+1'b1;
	else shift_data_out<={data[4][31],data[4][15:1]};		
end 

endmodule
