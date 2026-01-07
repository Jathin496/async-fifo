Asynchronous FIFO (Async FIFO)

An asynchronous FIFO implementation in Verilog for safe data transfer between two independent clock domains.
The design uses Gray code pointers and double-flop synchronization to handle clock domain crossing (CDC) correctly.

Overview

This project implements an Asynchronous FIFO (First-In-First-Out) buffer that allows reliable communication between a write clock domain and a read clock domain running at different frequencies.

The focus of this design is correct CDC handling, clean reset behavior, and a self-checking testbench that verifies data integrity.

Key Features

Independent write and read clocks

Parameterized data width and FIFO depth

Gray code pointers for safe CDC

Two-stage synchronizers for pointer crossing

Accurate full and empty flag generation

Self-checking Verilog testbench

Architecture

The FIFO consists of:

A shared memory array

Binary write and read pointers

Gray-coded versions of the pointers for CDC

Pointer synchronization across clock domains

Full and empty flag logic based on Gray pointer comparison

A high-level block diagram of the async FIFO architecture is shown below.

(Block diagram image can be added here)

Design Details
Gray Code Pointers

Write and read pointers are maintained in binary and Gray formats

Gray code ensures only one bit changes per increment, reducing CDC issues

Pointer Synchronization

Write pointer is synchronized into the read clock domain

Read pointer is synchronized into the write clock domain

Two flip-flop stages are used to allow metastability to settle

Empty Detection
assign empty = (rptr_gray == rclk_wptr_gray);


The FIFO is empty when the read pointer equals the synchronized write pointer.

Full Detection
assign full = (wptr_gray ==
              {~wclk_rptr_gray[addr_width:addr_width-1],
                wclk_rptr_gray[addr_width-2:0]});


The FIFO is full when the write pointer wraps around and catches up to the read pointer.

Reset Behavior

Active-low resets (wrst_n, rrst_n) for each clock domain

Pointers and output data are reset to zero

Writes and reads begin only after reset stabilization

Testbench Overview

The testbench (async_fifo_tb.v) verifies correct FIFO operation by:

Generating independent write and read clocks

Driving control signals on negedge and sampling on posedge

Writing random data into the FIFO

Reading data back and comparing with a reference model

Reporting mismatches using $error

Dumping waveforms for inspection

Verification Results

All written data is read back correctly

No data loss or duplication

Correct read order is preserved

Full and empty flags behave as expected

Example simulation output:

[WRITE] Data = 24
[WRITE] Data = 81
[WRITE] Data = 09
[WRITE] Data = 63
[WRITE] Data = 0d
[READ] 24 OK
[READ] 81 OK
[READ] 09 OK
[READ] 63 OK
[READ] 0d OK
---- TEST COMPLETED ----

Parameters
parameter width = 8;        // Data width
parameter addr_width = 6;  // FIFO depth = 2^addr_width

How to Run

Using Icarus Verilog:

iverilog -o output.vvp async_fifo.v async_fifo_tb.v
vvp output.vvp


To view waveforms:

gtkwave dump.vcd

Files

async_fifo.v – Asynchronous FIFO RTL

async_fifo_tb.v – Self-checking testbench

Notes

This project highlights practical aspects of:

Clock domain crossing

Enable timing relative to clock edges

Non-blocking assignment behavior in testbenches

FIFO read latency and verification timing

Possible Improvements

Almost-full / almost-empty flags

FIFO occupancy counter

Assertion-based or formal verification

SystemVerilog enhancements

Author

Jathin496
