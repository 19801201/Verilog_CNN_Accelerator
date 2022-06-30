`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/20 15:43:26
// Design Name: 
// Module Name: image_bias_add
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module image_bias_add(
    input clk,
    input [31:0] norm_data_out,
    input [31:0] bias_data_in,  // 31位为符号位，[30:24]是小数点的位置，[23:0]是数据
    output [47:0] data_out
    );
    

reg [47:0] norm_data_out_temp;  // 高32位是整数、低16位是小数
reg [47:0] bias_data_in_temp;   // 高32位是整数、低16位是小数

always@(posedge clk)begin
    norm_data_out_temp <= {norm_data_out[31:0],{16{1'b0}}};
end

//assign norm_data_out_temp = {norm_data_out[31:0],{16{1'b0}}};  // 卷积结果是32位正数，补低16位小数

always@(posedge clk)begin
    case(bias_data_in[30:24])
        7'b000_0000:  // 0
            bias_data_in_temp <= {{8{bias_data_in[31]}},bias_data_in[23:0],{16{1'b0}}};
        7'b000_0001:  // 1
            bias_data_in_temp <= {{9{bias_data_in[31]}},bias_data_in[23:0],{15{1'b0}}};
        7'b000_0010:  // 2
            bias_data_in_temp <= {{10{bias_data_in[31]}},bias_data_in[23:0],{14{1'b0}}};
        7'b000_0011:  // 3
            bias_data_in_temp <= {{11{bias_data_in[31]}},bias_data_in[23:0],{13{1'b0}}};
        7'b000_0100:  // 4
            bias_data_in_temp <= {{12{bias_data_in[31]}},bias_data_in[23:0],{12{1'b0}}};
        7'b000_0101:  // 5
            bias_data_in_temp <= {{13{bias_data_in[31]}},bias_data_in[23:0],{11{1'b0}}};
        7'b000_0110:  // 6
            bias_data_in_temp <= {{14{bias_data_in[31]}},bias_data_in[23:0],{10{1'b0}}};
        7'b000_0111:  // 7
            bias_data_in_temp <= {{15{bias_data_in[31]}},bias_data_in[23:0],{9{1'b0}}};
        7'b000_1000:  // 8
            bias_data_in_temp <= {{16{bias_data_in[31]}},bias_data_in[23:0],{8{1'b0}}};
        7'b000_1001:  // 9
            bias_data_in_temp <= {{17{bias_data_in[31]}},bias_data_in[23:0],{7{1'b0}}};
        7'b000_1010:  // 10
            bias_data_in_temp <= {{18{bias_data_in[31]}},bias_data_in[23:0],{6{1'b0}}};
        7'b000_1011:  // 11
            bias_data_in_temp <= {{19{bias_data_in[31]}},bias_data_in[23:0],{5{1'b0}}};
        7'b000_1100:  // 12
            bias_data_in_temp <= {{20{bias_data_in[31]}},bias_data_in[23:0],{4{1'b0}}};
        7'b000_1101:  // 13
            bias_data_in_temp <= {{21{bias_data_in[31]}},bias_data_in[23:0],{3{1'b0}}};
        7'b000_1110:  // 14
            bias_data_in_temp <= {{22{bias_data_in[31]}},bias_data_in[23:0],{2{1'b0}}};
        7'b000_1111:  // 15
            bias_data_in_temp <= {{23{bias_data_in[31]}},bias_data_in[23:0],{1{1'b0}}};
        7'b001_0000:  // 16
            bias_data_in_temp <= {{24{bias_data_in[31]}},bias_data_in[23:0]};
    endcase  
end

add_48_48 add_48_48 (
  .A(norm_data_out_temp),      // input wire [47 : 0] A
  .B(bias_data_in_temp),      // input wire [47 : 0] B
  .CLK(clk),  // input wire CLK
  .S(data_out)      // output wire [47 : 0] S
);

    
endmodule
