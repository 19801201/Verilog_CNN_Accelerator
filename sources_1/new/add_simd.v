`timescale 1ns / 1ps

`include  "./Para.v"
module add_simd#(parameter
TYPE       =       "1"//"2"
)(input                                     clk,
input  [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]   data_one_in,
input  [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]   data_two_in,
output [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]   data_out
    );
wire [43:0]data_out_temp[0:1];
localparam add_num=4;   
generate
genvar i;
    case(TYPE)
    "1":begin
           for(i=0;i<`PICTURE_NUM;i=i+1)begin 
                add_16_16 add_16_16 ( 
                  .A(data_one_in[2*`WIDTH_DATA_OUT*(i+1)-1:2*`WIDTH_DATA_OUT*i]),      // input wire [15 : 0] A
                  .B(data_two_in[2*`WIDTH_DATA_OUT*(i+1)-1:2*`WIDTH_DATA_OUT*i]),      // input wire [15 : 0] B
                  .CLK(clk),  // input wire CLK
                  .S(data_out[2*`WIDTH_DATA_OUT*(i+1)-1:2*`WIDTH_DATA_OUT*i])      // output wire [15 : 0] S
                    );//    s[15:0]  s[31:16]
            end
         end
       "2":begin
            for(i=0;i<`PICTURE_NUM>>1;i=i+1)begin 
                  Add_34_34 Add_34_34 (
                    .CLK(clk),  // input wire CLK
                    .A({data_one_in[4*`WIDTH_DATA_OUT*(i+1)-1:(2*i+1)*`WIDTH_DATA_OUT*2],{add_num{1'b0}},data_one_in[(2*i+1)*`WIDTH_DATA_OUT*2-1:4*`WIDTH_DATA_OUT*i]}),   
                    .B({data_two_in[4*`WIDTH_DATA_OUT*(i+1)-1:(2*i+1)*`WIDTH_DATA_OUT*2],{add_num{1'b0}},data_two_in[(2*i+1)*`WIDTH_DATA_OUT*2-1:4*`WIDTH_DATA_OUT*i]}),     
                    .S({data_out_temp[i]})      
                );  
            assign data_out[(2*i+2)*`WIDTH_DATA_OUT*2-1:2*i*`WIDTH_DATA_OUT*2] ={data_out_temp[i][2*`WIDTH_DATA_OUT*2+add_num-1:`WIDTH_DATA_OUT*2+add_num],data_out_temp[i][`WIDTH_DATA_OUT*2-1:0] };
              
            end
        end
    endcase
endgenerate 

endmodule
