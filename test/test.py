# SPDX-FileCopyrightText: © 2025 AravindakshanGA
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_fp_multiplication(dut):
    dut._log.info("Starting FP Multiplication Test")

    # Set up the clock with a period of 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset the DUT
    dut._log.info("Resetting DUT")
    dut.ena.value = 1  # Enable the design
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)
    dut._log.info("Reset DUT Done")

    # Test Case 1
    dut._log.info("Starting Test Case 1")
    flp_a = 0b01001000  # Input A (8-bit float)
    flp_b = 0b01010100  # Input B (8-bit float)
    expected_result = 0b01101110  # Expected result
    await perform_fp_multiplication_test(dut, flp_a, flp_b, expected_result)

    # Test Case 2
    dut._log.info("Starting Test Case 2")
    flp_a = 0b00110000  # Input A (8-bit float)
    flp_b = 0b10111000  # Input B (8-bit float)
    expected_result = 0b10111000  # Expected result
    await perform_fp_multiplication_test(dut, flp_a, flp_b, expected_result)

    # Test Case 3 
    dut._log.info("Starting Test Case 3")
    flp_a = 0b01111110 # Input A (8-bit float)
    flp_b = 0b11101010 # Input B (8-bit float)
    expected_result = 0b11110000  # Expected result
    await perform_fp_multiplication_test(dut, flp_a, flp_b, expected_result)

    # Test Case 4
    dut._log.info("Starting Test Case 4")
    flp_a = 0b01111110  # Input A (8-bit float)
    flp_b = 0b00010000  # Input B (8-bit float)
    expected_result = 0b01011110  # Expected result
    await perform_fp_multiplication_test(dut, flp_a, flp_b, expected_result)
   

    # Test Case 5
    dut._log.info("Starting Test Case 5")
    flp_a = 0b00000000  # Input A (8-bit float)
    flp_b = 0b00000000  # Input B (8-bit float)
    expected_result = 0b00000000  # Expected result
    await perform_fp_multiplication_test(dut, flp_a, flp_b, expected_result)

    # Test Case 6
    dut._log.info("Starting Test Case 6")
    flp_a = 0b01111110  # Input A (8-bit float)
    flp_b = 0b01111110  # Input B (8-bit float)
    expected_result = 0b01110000  # Expected result
    await perform_fp_multiplication_test(dut, flp_a, flp_b, expected_result)

    # Test Case 7
    dut._log.info("Starting Test Case 7")
    flp_a = 0b00000000  # Input A (8-bit float)
    flp_b = 0b00001000  # Input B (8-bit float)
    expected_result = 0b00000000  # Expected result
    await perform_fp_multiplication_test(dut, flp_a, flp_b, expected_result)

    # Test Case 8
    dut._log.info("Starting Test Case 8")
    flp_a = 0b00110000  # Input A (8-bit float)
    flp_b = 0b00110000  # Input B (8-bit float)
    expected_result = 0b00110000  # Expected result
    await perform_fp_multiplication_test(dut, flp_a, flp_b, expected_result)



async def perform_fp_multiplication_test(dut, flp_a, flp_b, expected_result):
    # Set the inputs
    dut.ui_in.value = flp_a
    dut.uio_in.value = flp_b

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # Check if the result matches the expected value
    dut._log.info(f"Input A: {bin(flp_a)}, Input B: {bin(flp_b)}")
    dut._log.info(f"Expected result: {bin(expected_result)}")
    dut._log.info(f"Actual result: {bin(dut.uo_out.value)}")
    assert dut.uo_out.value == expected_result, f"Test failed: {bin(dut.uo_out.value)} != {bin(expected_result)}"



    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
