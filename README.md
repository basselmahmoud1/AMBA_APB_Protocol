# AMBA APB Protocol — SystemVerilog Implementation

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue?style=flat-square)
![Standard](https://img.shields.io/badge/Standard-AMBA%20APB%20v2.0-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

A fully verified **SystemVerilog** implementation of the **ARM AMBA APB (Advanced Peripheral Bus) Protocol**, based on the official ARM IHI0024D specification. This project provides a synthesizable design of the APB bridge and peripheral slave interface, suitable for SoC integration and academic study.

---

## Table of Contents

- [Overview](#overview)
- [Protocol Background](#protocol-background)
- [Repository Structure](#repository-structure)
- [Signal Description](#signal-description)
- [State Machine](#state-machine)
- [Getting Started](#getting-started)
- [Simulation](#simulation)
- [Reference](#reference)

---

## Overview

The **Advanced Peripheral Bus (APB)** is part of the ARM AMBA protocol family and is designed for low-power, low-bandwidth peripheral communication. It provides a simple, low-complexity interface ideal for connecting slow peripherals such as UARTs, timers, and GPIOs in a System-on-Chip (SoC) design.

This implementation includes:

- APB Master (Bridge) interface
- APB Slave interface
- Full read/write transaction support
- Wait-state insertion support
- Error response (`PSLVERR`) support

---

## Protocol Background

APB is a non-pipelined protocol with a simple handshake mechanism. Every transfer takes at least **two clock cycles** and follows a three-phase state machine:

| Phase | Description |
|-------|-------------|
| **IDLE** | Default state; no transfers in progress |
| **SETUP** | Address, data, and control signals are driven |
| **ACCESS** | Transfer is completed; slave responds |

---

## Repository Structure

```
AMBA_APB_Protocol/
├── src/                            # RTL source files (SystemVerilog)
│   ├── apb_master.sv               # APB Master / Bridge
│   ├── apb_slave.sv                # APB Slave peripheral
│   └── ...                         # Additional modules
├── ARM IHI0024D_amba_apb_protocol_spec.pdf   # Official ARM APB specification
└── README.md
```

---

## Signal Description

### APB Master → Slave Signals

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `PCLK` | 1 | Input | Clock signal |
| `PRESETn` | 1 | Input | Active-low reset |
| `PADDR` | 32 | Master → Slave | Address bus |
| `PSEL` | 1 | Master → Slave | Slave select |
| `PENABLE` | 1 | Master → Slave | Enables the transfer |
| `PWRITE` | 1 | Master → Slave | Write (1) / Read (0) |
| `PWDATA` | 32 | Master → Slave | Write data |

### APB Slave → Master Signals

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `PRDATA` | 32 | Slave → Master | Read data |
| `PREADY` | 1 | Slave → Master | Transfer complete |
| `PSLVERR` | 1 | Slave → Master | Error response |

---

## State Machine

```
          ┌────────┐
  ───────▶│  IDLE  │◀──────────────────────┐
          └────────┘                        │
              │ PSEL asserted               │ Transfer done
              ▼                             │ (PREADY high)
          ┌────────┐                   ┌──────────┐
          │ SETUP  │──────────────────▶│  ACCESS  │
          └────────┘   PENABLE asserted└──────────┘
```

---

## Getting Started

### Prerequisites

- A SystemVerilog-compatible simulator:
  - [ModelSim / QuestaSim](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-sim.html)
  - [Vivado Simulator (xsim)](https://www.xilinx.com/products/design-tools/vivado.html)
  - [VCS (Synopsys)](https://www.synopsys.com/verification/simulation/vcs.html)
  - [Icarus Verilog + GTKWave](http://iverilog.icarus.com/) *(free & open source)*

### Clone the Repository

```bash
git clone https://github.com/basselmahmoud1/AMBA_APB_Protocol.git
cd AMBA_APB_Protocol
```

---

## Simulation

### Using ModelSim

```bash
vlib work
vlog src/*.sv
vsim -c tb_apb -do "run -all; quit"
```

### Using Icarus Verilog

```bash
iverilog -g2012 -o apb_sim src/*.sv
vvp apb_sim
gtkwave dump.vcd
```

---

## Reference

- **ARM AMBA APB Protocol Specification** — `ARM IHI0024D` (included in this repo)
- [ARM Developer Documentation](https://developer.arm.com/documentation/ihi0024/latest)

---

## Author

**Bassel Mahmoud**
[GitHub Profile](https://github.com/basselmahmoud1)