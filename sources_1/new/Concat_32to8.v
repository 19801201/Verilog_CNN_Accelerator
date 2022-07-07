`timescale 1ns / 1ps
`include  "./Para.v"

module Concat_32to8 #(
	RE_CHANNEL_IN_NUM  = 8
)(
	input						  clk,
	input  [31:0]                 Concat_Data_In,
	output	reg	[8:0]	          Concat_Data_Out
    );
    
wire  	[22:0]	Concat_Data_Judge;


assign	Concat_Data_Judge[22:0] = Concat_Data_In[30:8];

always @ (posedge clk) begin
	if (Concat_Data_In[31]) begin 
		Concat_Data_Out <= 8'd0;
	end
	else  begin 
		if (Concat_Data_Judge > 1'b0)
			Concat_Data_Out <= {8{1'b1}};
		else
			Concat_Data_Out <= Concat_Data_In[7:0];
	end
end

    
    
endmodule
