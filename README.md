# ⏳ Asynchronous FIFO (Async FIFO)

An asynchronous FIFO implementation in Verilog for safe data transfer between two independent clock domains. The design uses Gray code pointers and double-flop synchronization to handle clock domain crossing (CDC) correctly.

---

## 📋 Overview

This project implements an **Asynchronous FIFO (First-In-First-Out)** buffer that allows reliable communication between a write clock domain and a read clock domain running at different frequencies.

The focus of this design is:
- ✅ Correct CDC handling
- ✅ Clean reset behavior
- ✅ Self-checking testbench that verifies data integrity

---

## 🚀 Key Features

- 🔄 Independent write and read clocks
- ⚙️ Parameterized data width and FIFO depth
- 🔐 Gray code pointers for safe CDC
- 🔀 Two-stage synchronizers for pointer crossing
- 🎯 Accurate full and empty flag generation
- 🧪 Self-checking Verilog testbench

---

## 🏗️ Architecture

The FIFO consists of:

- **Shared memory array** – Storage for FIFO data
- **Binary write and read pointers** – Track current positions
- **Gray-coded pointer versions** – Enable safe CDC
- **Pointer synchronization logic** – Cross-domain synchronizers
- **Full and empty flag logic** – Based on Gray pointer comparison

---

## 🔧 Design Details

### Gray Code Pointers

- Write and read pointers are maintained in **binary** and **Gray** formats
- Gray code ensures only **one bit changes per increment**
- Reduces CDC issues and metastability problems

### Pointer Synchronization

- Write pointer is synchronized into the **read clock domain**
- Read pointer is synchronized into the **write clock domain**
- **Two flip-flop stages** are used to allow metastability to settle

### Empty Detection

```verilog
assign empty = (rptr_gray == rclk_wptr_gray);
```

The FIFO is **empty** when the read pointer equals the synchronized write pointer.

### Full Detection

```verilog
assign full = (wptr_gray ==
              {~wclk_rptr_gray[addr_width:addr_width-1],
                wclk_rptr_gray[addr_width-2:0]});
```

The FIFO is **full** when the write pointer wraps around and catches up to the read pointer.

### Reset Behavior

- **Active-low resets** (`wrst_n`, `rrst_n`) for each clock domain
- Pointers and output data are reset to zero
- Writes and reads begin only after reset stabilization

---

## 🧪 Testbench Overview

The testbench (`async_fifo_tb.v`) verifies correct FIFO operation by:

- ✅ Generating independent write and read clocks
- ✅ Driving control signals on negedge and sampling on posedge
- ✅ Writing random data into the FIFO
- ✅ Reading data back and comparing with a reference model
- ✅ Reporting mismatches using `$error`
- ✅ Dumping waveforms for inspection

---

## 📊 Verification Results

| Test Case | Result |
|-----------|--------|
| Data Integrity | ✅ PASSED |
| No Data Loss | ✅ PASSED |
| No Duplication | ✅ PASSED |
| Read Order Preservation | ✅ PASSED |
| Full/Empty Flags | ✅ PASSED |

### Example Simulation Output

```
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
```

---

## ⚙️ Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `width` | 8 | Data width (bits) |
| `addr_width` | 6 | FIFO depth = 2^addr_width |

---

## 🏃 How to Run

### Using Icarus Verilog

```bash
iverilog -o output.vvp async_fifo.v async_fifo_tb.v
vvp output.vvp
```

### View Waveforms

```bash
gtkwave dump.vcd
```

---

## 📁 Project Files

| File | Description |
|------|-------------|
| `async_fifo.v` | Asynchronous FIFO RTL design |
| `async_fifo_tb.v` | Self-checking testbench |
| `README.md` | Project documentation |

---

## 📚 Design Highlights

This project demonstrates practical aspects of:

- 🔌 **Clock Domain Crossing** – Safe pointer synchronization
- ⏱️ **Enable Timing** – Relative to clock edges
- 🔄 **Non-blocking Assignments** – In testbenches
- ⏳ **FIFO Read Latency** – And verification timing considerations

---

## 💡 Possible Improvements

- [ ] Almost-full / almost-empty flags
- [ ] FIFO occupancy counter
- [ ] Assertion-based or formal verification
- [ ] SystemVerilog enhancements
- [ ] Performance metrics and reports

---

## 👤 Author

**Jathin496**