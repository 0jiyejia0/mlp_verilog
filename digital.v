module digital (a,dr);
	input[3:0]a;
	output[6:0]dr;
	assign  dr=(a==4'b0000)?7'b1000000://0
				  (a==4'b0001)?7'b1111001://1
				  (a==4'b0010)?7'b0100100://2
				  (a==4'b0011)?7'b0110000://3
				  (a==4'b0100)?7'b0011001://4		  
				  (a==4'b0101)?7'b0010010://5			  
				  (a==4'b0110)?7'b0000010://6
				  (a==4'b0111)?7'b1111000://7		  
				  (a==4'b1000)?7'b0000000://8
				  (a==4'b1001)?7'b0010000://9		  
				  (a==4'b1010)?7'b1111111:	dr;
endmodule