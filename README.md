# Asynchronous FIFO (Async FIFO)

A robust asynchronous FIFO implementation in Verilog with proper Clock Domain Crossing (CDC) synchronization using Gray code pointers.

## Overview

This project implements an **Asynchronous FIFO (First-In-First-Out)** buffer that safely transfers data between two independent clock domains. The design uses Gray code encoding for safe pointer synchronization, eliminating metastability issues in CDC scenarios.

### Key Features

- ✅ **Clock Domain Crossing (CDC) Safe**: Uses Gray code pointers with 2-stage synchronizer for safe clock domain crossing
- ✅ **Parameterizable Design**: Configurable data width and FIFO depth
- ✅ **Independent Clock Domains**: Separate read and write clocks with independent resets
- ✅ **Full and Empty Flags**: Accurate full and empty detection
- ✅ **Synchronous Design**: All operations synchronized to respective clock domains
- ✅ **Memory Efficient**: Uses dual-port memory for efficient data storage

## Architecture
<img width="768" height="434" alt="image" src="https://github.com/user-attachments/assets/30a23de1-5f33-4a01-8035-4bb95deffabb" />

### Block Diagram
```
Write Clock Domain          |          Read Clock Domain
     (wclk)                 |              (rclk)
                            |
  wdata ─────┐              |
             │              |
           ┌─▼──────────────┼──────────────┐
           │  FIFO Memory   │              │
           │  (depth×width) │              │
           └─┬──────────────┼──────────────┘
             │              |            │
    wptr ────┤ Gray Code CDC│ Gray Code ├──► rdata
    wclk ────┤ Synchronizer │ Pointer   │
  wrst_n ────┤              │           │
   full ◄────┤              │           │
             │              |            │
             │              |      rptr ├──► empty
             └──────────────┼──────────┘
                            |
```

## Port Description

### Input Ports

| Port | Width | Description |
|------|-------|-------------|
| `wclk` | 1 | Write clock |
| `rclk` | 1 | Read clock |
| `wrst_n` | 1 | Write domain reset (active low) |
| `rrst_n` | 1 | Read domain reset (active low) |
| `w_en` | 1 | Write enable signal |
| `r_en` | 1 | Read enable signal |
| `wdata` | width | Data to be written (default:  8-bit) |

### Output Ports

| Port | Width | Description |
|------|-------|-------------|
| `rdata` | width | Data read from FIFO (default: 8-bit) |
| `full` | 1 | FIFO is full (active high) |
| `empty` | 1 | FIFO is empty (active high) |

## Parameters

```verilog
parameter width = 8,        // Data width in bits (default: 8)
parameter addr_width = 6    // Address width (FIFO depth = 2^addr_width, default: 64)
```

### Example Instantiation

```verilog
async_fifo #(
    .width(16),         // 16-bit data
    .addr_width(8)      // 256-deep FIFO
) my_fifo (
    .wclk(write_clock),
    .rclk(read_clock),
    .wrst_n(write_reset_n),
    .rrst_n(read_reset_n),
    .w_en(write_enable),
    .r_en(read_enable),
    .wdata(write_data),
    .rdata(read_data),
    .full(fifo_full),
    .empty(fifo_empty)
);
```

## Design Details

### 1. **Gray Code Pointer Encoding**
- Write and read pointers are maintained in both binary and Gray code formats
- Gray code is used for CDC (Clock Domain Crossing) as only one bit changes per increment
- This minimizes metastability issues in synchronizers

### 2. **CDC Synchronization (2-Stage Synchronizer)**
- Gray code pointers are synchronized across clock domains using 2-stage flip-flops
- Write pointer synchronized to read clock domain:  `wclk_rptr_gray_ff1 → wclk_rptr_gray_ff2`
- Read pointer synchronized to write clock domain: `rclk_wptr_gray_ff1 → rclk_wptr_gray_ff2`
- This ensures metastable signals have time to settle

### 3. **Empty Flag Detection**
```verilog
assign empty = (rptr_gray == rclk_wptr_gray);
```
- FIFO is empty when the read pointer equals the synchronized write pointer (in Gray code)

### 4. **Full Flag Detection**
```verilog
assign full = (wptr_gray == {~wclk_rptr_gray[addr_width: addr_width-1], 
                             wclk_rptr_gray[addr_width-2:0]});
```
- FIFO is full when write pointer equals read pointer with MSB inverted
- This is due to the circular nature of the pointer wraparound

## Simulation

### Running the Testbench

Use any Verilog simulator (ModelSim, VCS, Vivado, etc. ):

**Using ModelSim:**
```bash
vlog rtl/async_fifo.v tb/async_fifo_tb.v
vsim async_fifo_tb
run -all
```

**Using Vivado:**
```bash
xvlog rtl/async_fifo. v tb/async_fifo_tb.v
xsim async_fifo_tb -gui
```

### Testbench Overview

The testbench (`async_fifo_tb.v`) includes:
- **Clock Generation**: Independent write (10ns period) and read (20ns period) clocks
- **Asynchronous Reset**:  Separate resets for both clock domains
- **Write Operations**:  Writes 32 random values to the FIFO
- **Read Operations**: Reads 32 values and compares with expected data
- **Verification**: Checks data integrity with error reporting
- **Waveform Dump**:  Generates VCD file for viewing in waveform viewer

### Expected Output
```
[WRITE] Data = xxxxxxxx
[WRITE] Data = xxxxxxxx
... 
[READ ] Data = xxxxxxxx (OK)
[READ ] Data = xxxxxxxx (OK)
...
---- TEST COMPLETED ----
```

## Clock Domain Crossing (CDC) Analysis

### Metastability Handling
The design safely handles clock domain crossing using: 
1. **Gray Code Pointers**: Only one bit changes per pointer increment
2. **2-Stage Synchronizer**: Breaks timing paths and allows metastable signals to settle
3. **Independent Clocks**: Clocks are independent, eliminating race conditions

### Timing Requirements
- Minimum synchronizer period: 2 source clock periods
- No timing constraints between wclk and rclk required
- Can safely handle large clock frequency differences

## File Structure

```
async-fifo/
├── rtl/
│   └── async_fifo.v         # Main FIFO RTL module
├── tb/
│   └── async_fifo_tb.v      # Testbench
├── README.md                # This file
└── . gitignore               # Git ignore file
```

## Key Implementation Notes

1. **Circular Memory**:  Uses modulo addressing with power-of-2 depth for efficient implementation
2. **Pointer Width**: Binary pointers are (addr_width + 1) bits to distinguish full from empty
3. **Synchronous Writes/Reads**: All data updates are synchronous to respective clock domains
4. **Reset Behavior**: Asynchronous resets clear all pointers and data

## Applications

- **Multi-Clock Systems**: Data transfer between different frequency domains
- **Asynchronous Communication**:  FIFO for asynchronous protocols
- **Interface Buffers**: CDC for chip-to-chip or module-to-module communication
- **Real-time Systems**: Safe buffering without strict clock synchronization

## Further Improvements

Possible enhancements:
- [ ] Add FIFO count (occupancy) output
- [ ] Add programmable threshold flags
- [ ] Extend to configurable data widths (16, 32, 64-bit)
- [ ] Add error detection/logging capabilities
- [ ] Create assertion-based verification

## References

- "Crossing the Abyss: Asynchronous FIFO Design Issues" - Sunburst Design
- "CDC Design Verification" - IEEE 802 Standards
- Gray Code:  https://en.wikipedia.org/wiki/Gray_code

## License

This project is open source.  Feel free to use and modify for your own projects. 

## Author

Jathin496

---

**Note**: This is a foundational design. For production use, consider adding formal verification and CDC-specific linting tools.
