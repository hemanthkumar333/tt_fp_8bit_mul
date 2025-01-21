/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
    wire _unused = &{ena, clk, rst_n, 1'b0};
      fp_mul_8bit uut (
          .flp_a(ui_in[7:0]),
          .flp_b(uio_in[7:0]),
          .result(uo_out[7:0])
    );
endmodule

module fp_mul_8bit (flp_a,flp_b,result);
input [7:0] flp_a;
input [7:0] flp_b;   
output [7:0] result;

reg sign;
// reg [2:0] exponent;
reg [3:0] prod;
reg [7:0] result;
reg [2:0] exp_a, exp_b;
reg [3:0] exp_sum; 
reg [3:0] fract_a, fract_b;
reg [7:0] prod_dbl;
reg [2:0] exp_unbiased;
  
integer i;

always @ (flp_a or flp_b)
    begin
	sign = flp_a[7] ^ flp_b[7];
        exp_a = flp_a[6:4];
        exp_b = flp_b[6:4];
        fract_a = {1'b1, flp_a[3:1]}; // Implicit leading 1
        fract_b = {1'b1, flp_b[3:1]}; 
	 
        exp_sum = exp_a + exp_b;

        // Remove bias
        exp_sum = exp_sum - 3'b011;
	exp_unbiased = exp_sum[2:0];

        prod_dbl = fract_a * fract_b;
        prod = prod_dbl[5:2]; 
		  
        if (prod == 0) begin
            result = 8'b0; 
        end else begin
            for (i = 0; i < 4; i = i + 1) begin
						if (prod[3] == 0 && exp_unbiased > 0) begin
							 prod = prod << 1;
							 exp_unbiased = exp_unbiased - 1;
						end
            end 

            // exponent = exp_unbiased;
		if (flp_a[6:0] == 0 || flp_b[6:0] == 0) begin
			result = 8'b0; 
		end
		else if (exp_unbiased > 3'b111) begin
			 result = {sign, 3'b111, 4'b0}; // Overflow to infinity
		end 
		else if (exp_unbiased < 3'b000) begin
			 result = 8'b0; // Underflow to zero
		end 
		else begin
			 result = {sign, exp_unbiased, prod[3:0]}; // Normal case
		end
        end
    end
 
endmodule
