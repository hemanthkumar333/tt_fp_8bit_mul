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
 
fp_mul_8bit uut (
          .flp_a(ui_in[7:0]),
          .flp_b(uio_in[7:0]),
          .result(uo_out[7:0])
);

// assign uio_out = result;
assign uio_oe  = 8'h0;
assign uio_out = 8'h0;

  // List all unused inputs to prevent warnings
wire _unused = &{ena, clk, rst_n};
endmodule

module fp_mul_8bit (flp_a,flp_b,result);
input [7:0] flp_a;
input [7:0] flp_b;   
output reg [7:0] result;

reg sign;
reg [2:0] exp_a, exp_b;
reg [4:0] fract_a, fract_b;
reg signed [3:0] exp_unbiased;
reg [9:0] prod_dbl;         // Full product (10-bit)
reg [3:0] mantissa;         // Updated mantissa (after shifting)

always @ (*)
    begin
	sign = 1'b0;
        exp_a = 3'b0;
        exp_b = 3'b0;
        fract_a = 5'b0;
        fract_b = 5'b0;
	exp_unbiased = 4'b0;
        prod_dbl = 10'b0;
        mantissa = 4'b0;
        result = 8'b0;
	    
        // Step 1: Compute the sign of the result
        sign = flp_a[7] ^ flp_b[7];

        // Step 2: Extract exponent and mantissa
        exp_a = flp_a[6:4];
        exp_b = flp_b[6:4];
        fract_a = (exp_a == 0) ? {1'b0, flp_a[3:0]} : {1'b1, flp_a[3:0]};
        fract_b = (exp_b == 0) ? {1'b0, flp_b[3:0]} : {1'b1, flp_b[3:0]};

	exp_unbiased = exp_a + exp_b - 3'b011;

        // Step 3: Multiply mantissas
        prod_dbl = fract_a * fract_b;

        // Step 4: Shift the mantissa based on product
        if (prod_dbl[9] == 1) begin
            // If the most significant bit is 1, no shift needed
            mantissa = prod_dbl[9:6];  // Take the 4 MSBs
        end else begin
            // If the most significant bit is 0, shift left by 1 bit
            mantissa = prod_dbl[8:5];  // Take the 4 bits shifted left
            // Shift another bit left if necessary (additional shift)
            mantissa = mantissa << 1;  // Perform an extra left shift
        end

        // Step 5: Handle multiplication by zero case
        if (flp_a[6:0] == 0 || flp_b[6:0] == 0) begin
            result = 8'b0;  // Multiplying by zero
        end else begin
            // Normal result: Keep exponent and sign intact, only shift mantissa
            result = {sign, exp_a + exp_b - 3'b011, mantissa};
        end

	// Handle overflow 
	if (exp_unbiased >= 3'b111 & flp_a[6:0] != 0 & flp_b[6:0] != 0) begin
		 result = {sign, 3'b111, 4'b0}; // Overflow to infinity
   	end
    end
endmodule
