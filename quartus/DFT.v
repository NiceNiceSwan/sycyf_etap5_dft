module DFT(
	input rst,
	input clk,
	input ena,
	input [10:0] sample,
	output [15:0] DFT_output_value
);

localparam [2:0]	idle = 0,
								init = 1,
								read = 2,
								calc_dft = 3,
								print_dft = 4,
								s5 = 5,
								s6 = 6;
								
localparam number_of_samples = 1000; // 1000 samples, because that's what I decided is the optimal amount to not count ourselves to death
localparam _2pi = 6.2831853;
						
reg [2:0] state_reg, state_next;
reg [11:0] samples [7:0];
reg done_reading_samples;
reg [9:0] index, index_next;
reg [10:0] sample_nr, sample_nr_next;
reg [10:0] DFT_real, DFT_real_next, DFT_imag, DFT_imag_next;
reg [15:0] DFT_output_value_next;

always @(posedge clk, posedge rst) begin
	if (rst)
		state_reg <= idle;
	else if (ena)
		state_reg <= state_next;
		sample_nr <= sample_nr_next;
		index <= index_next;
end
	
always@(*) begin
	case (state_reg)
		idle : if (ena) state_next = init;
				 else state_next = idle;
		init: state_next = read;
		read: if (done_reading_samples) state_next = calc_dft;
				else state_next = read;
		calc_dft:	if (index == 1000) state_next = idle;
						else if (sample_nr == 1000) state_next = print_dft;
						else state_next = calc_dft;
		print_dft: state_next = calc_dft;
	endcase
end

always@(*) begin
	sample_nr_next = sample_nr;
	index_next = index;
	case(state_reg)
		init: begin
			index = 0;
			index_next = 0;
			done_reading_samples = 0;
			sample_nr = 0;
			sample_nr_next = 0;
			DFT_real = 0;
			DFT_real_next = 0;
			DFT_imag = 0;
			DFT_imag_next = 0;
			DFT_output_value_next = 0;
		end
		read: begin
			samples[sample_nr] = sample;
			sample_nr_next = sample_nr + 1;
			if (sample_nr == number_of_samples)
				done_reading_samples = 1;
				
		end
		calc_dft: begin
			DFT_real_next = DFT_real + samples[sample_nr] * cos(_2pi*index*sample_nr/1000);
			DFT_imag_next = DFT_imag + samples[sample_nr] * sin(_2pi*index*sample_nr/1000);
			sample_nr_next = sample_nr + 1;
		end
		print_dft: begin
			DFT_output_value_next = (DFT_real * DFT_real + DFT_imag * DFT_imag) >>> 8;
			index_next = index + 1;
		end
	endcase
end
endmodule
