`timescale 1ns / 1ps

`include  "../Para.v"
module mult_simd   #(parameter
TYPE       =       "2"//"2"
)
(
input                                   clk,
input  [`PICTURE_NUM*`WIDTH_DATA-1:0]   data_in,
input  [`WIDTH_DATA-1:0]                weight_in,
output [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0] data_out  //16====20
    );
    
wire [33:0]data_out_temp[0:1];
wire  [`WIDTH_DATA*2-1:0] data_out_mult[0:`PICTURE_NUM-1];  //16====20
localparam num=8;
localparam add_num=4;
generate
genvar i;
    case(TYPE)
    "1":begin
                for(i=0;i<`PICTURE_NUM;i=i+1)begin 
//                    mult_8_8_16  mult_8_8_16 (
//                        .CLK(clk),  // input wire CLK
//                        .A(data_in[`WIDTH_DATA*(i+1)-1:`WIDTH_DATA*i]),      // input wire [7 : 0] A
//                        .B(weight_in),      // input wire [7 : 0] B
//                        .P(data_out_mult[i])      // output wire [15 : 0] P
//                        );   
//                    assign data_out[2*`WIDTH_DATA_OUT*(i+1)-1:2*`WIDTH_DATA_OUT*i] = {{add_num{data_out_mult[i][15]}},data_out_mult[i]};
mult_dou_8_8   mult_dou_8_8(
    .clk  (clk),
    .data_in(data_in[`WIDTH_DATA*(i+1)-1:`WIDTH_DATA*i]),  // 8bit
    . weight_in(weight_in),
    . result_a(data_out[2*`WIDTH_DATA_OUT*(i+1)-1:2*`WIDTH_DATA_OUT*i]) // 20bit
);   
               end
         end
       "2":begin
            for(i=0;i<`PICTURE_NUM>>1;i=i+1)begin 
//                  Mult_26_8_34 Mult_2 (
//                    .CLK(clk),  // input wire CLK
//                   // .A({{data_in[(2*i+2)*`WIDTH_DATA-1:(2*i+1)*`WIDTH_DATA]-data_in[(2*i+1)*`WIDTH_DATA-1]},{num{data_in[(2*i+1)*`WIDTH_DATA-1]}},data_in[(2*i+1)*`WIDTH_DATA-1:2*i*`WIDTH_DATA]}),      // input wire [25 : 0] A
//                    .A(
//                    {
//                    {data_in[(2*i+2)*`WIDTH_DATA-1:(2*i+1)*`WIDTH_DATA]},
//                    {num{1'b0}},
//                    {data_in[(2*i+1)*`WIDTH_DATA-1:2*i*`WIDTH_DATA]}
//                    }
//                    ),   
//                    .B(weight_in),      // input wire [8 : 0] B
//                    .P(data_out_temp[i])      // output wire [34 : 0] P
//                ); 
//            assign data_out[(2*i+1)*`WIDTH_DATA_OUT*2-1:2*i*`WIDTH_DATA_OUT*2] ={{add_num{data_out_temp[i][15]}},{data_out_temp[i][`WIDTH_DATA*2-1:0]}};
//            assign data_out[(2*i+2)*`WIDTH_DATA_OUT*2-1:(2*i+1)*`WIDTH_DATA_OUT*2] ={{add_num{data_out_temp[i][33]}},{data_out_temp[i][`WIDTH_DATA*2+17:18]}};      
 mult_dou_26_8   mult_dou_26_8(
    .clk  (clk),
    .data_in({{data_in[(2*i+2)*`WIDTH_DATA-1:(2*i+1)*`WIDTH_DATA]}, // 8bit
                  {num{1'b0}},  // 8bit
                  {data_in[(2*i+1)*`WIDTH_DATA-1:2*i*`WIDTH_DATA]}}),  // 8bit
    . weight_in(weight_in),
    . result_a(data_out[(2*i+2)*`WIDTH_DATA_OUT*2-1:(2*i+1)*`WIDTH_DATA_OUT*2]), // 20bit
    . result_b(data_out[(2*i+1)*`WIDTH_DATA_OUT*2-1:2*i*`WIDTH_DATA_OUT*2]) // 20bit
);
            end
        end
    endcase
endgenerate
endmodule