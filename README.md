# 1x3 Router Project

## 🧠 Overview

This project implements a **1x3 Packet Router** using Verilog HDL. The router accepts packets from a single input port and routes them to one of the three output ports based on the destination address encoded in the packet. It demonstrates fundamental concepts of **digital communication**, **NoC (Network-on-Chip)** architecture, and **hardware-based routing**.

---


---

## 🔧 Features

- Single input port with three output ports
- Routing based on 2-bit destination header
- Individual FIFO buffers at each output port
- Handshaking signals (`valid`, `ready`, `busy`) for flow control
- Clock-synchronous, fully synthesizable Verilog code
- Self-checking testbench for simulation

---

## 🚀 How It Works

1. **Input Port**: Receives packets structured with a header and payload.
2. **Header Decoder**: Extracts destination address from the packet header.
3. **Demux**: Routes packet data to the correct output FIFO.
4. **FIFO Buffers**: Store routed packets at output ports.
5. **Control Signals**: `valid`, `ready`, `busy` signals manage packet flow.

---

## 🧪 Testbench

The testbench verifies:
- Packet reception and routing accuracy
- FIFO behavior and data integrity
- Control signal response

### Run Simulation (using Icarus Verilog):

```bash
iverilog -o router_tb tb/router_tb.v src/*.v
vvp router_tb
gtkwave dump.vcd
