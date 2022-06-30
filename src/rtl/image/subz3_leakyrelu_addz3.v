`timescale 1ns / 1ps

module subz3_leakyrelu_addz3(
	input 				clk,
	input	[7:0]		data_in,       		 // q3 
	input   [7:0] 		zero_data_in,  		//  z3 
	output	[7:0]		data_out	
);
wire	[15:0]				data_after1;
wire	signed [15:0]		data_after_zero2;  		// q3 - z3
wire  	[15:0]				data_negative;		
wire	[15:0]				data_after_zero3;
reg		[7:0]				data_after2;

assign data_after1[15:0] = {{8{1'b0}},{data_in[7:0]}};

//  2clk
sub_16_u8 sub_q3_z3 (
  .A(data_after1[15:0]),      // input wire [15 : 0] A
  .B(zero_data_in),      // input wire [7 : 0] B
  .CLK(clk),  // input wire CLK
  .S(data_after_zero2[15:0])      // output wire [15 : 0] S
);

assign data_negative[15:0] = (data_after_zero2[15] == 1'b0) ? data_after_zero2 : data_after_zero2 >> 3;

//  2 clk
zero_point_adder add_q3_z3_2 (
	.A(data_negative[15:0]),           // input wire [15 : 0] A
	.B(zero_data_in),           // input wire [7 : 0] B
	.CLK(clk),  		 	   // input wire CLK
	.S(data_after_zero3[15:0])      // output wire [15 : 0] S
);

//    1 clk 
always @ (posedge clk) begin
	if (data_after_zero3[15] == 1'b1)
		data_after2[7:0] <= {8{1'b0}};
	else begin 
		if (data_after_zero3[14:8] > 7'd0)
			data_after2[7:0] <= {8{1'b1}};
		else
			data_after2[7:0] <= data_after_zero3[7:0];
	end
end
 
assign	data_out[7:0] = data_after2[7:0];

endmodule
