module sin(
	input [16:0] addr,
	output reg signed [7:0] data
);

reg signed [7:0] rom [0:1024];
initial begin
	%readmemb("sin.mem", rom);
end

always @(*) begin
	data = rom[addr]
end

endmodule