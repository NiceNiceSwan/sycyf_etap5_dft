module cos(
	input [16:0] addr,
	output reg signed [7:0] data
);

reg signed [7:0] rom [0:1024];
initial begin
	%readmemb("cos.mem", rom);
end

always @(*) begin
	data = rom[addr]
end

endmodule
