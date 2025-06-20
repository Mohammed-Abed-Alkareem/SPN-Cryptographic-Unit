# Substitution-Permutation-Network-Cryptographic-Unit (SPN-CU)

A comprehensive design and verification implementation of a Simplified Substitution-Permutation Network Cryptographic Unit using SystemVerilog and UVM (Universal Verification Methodology).

## 🔐 Project Overview

This project implements a cryptographic processing unit based on the Substitution-Permutation Network (SPN) cipher architecture. The SPN-CU supports both encryption and decryption operations with a 16-bit data path and 32-bit key, featuring a 3-round cipher structure.

### Key Features

- **16-bit Data Path**: Processes 16-bit plaintext/ciphertext blocks
- **32-bit Secret Key**: Uses a 32-bit symmetric encryption key
- **3-Round Structure**: Implements a 3-round SPN cipher
- **Bidirectional Operation**: Supports both encryption and decryption
- **Comprehensive Verification**: Full UVM testbench with advanced verification features

## 🏗️ Architecture

### Core Components

- **SPN Top Module** (`spn_cu_top.sv`): Main cryptographic unit controller
- **SBox/InvSBox** (`sbox.sv`, `invsbox.sv`): Substitution boxes for encryption/decryption
- **Key Scheduler** (`key_scheduler.sv`): Generates round keys from master key
- **Round Module** (`spn_round.sv`): Implements individual cipher rounds
- **Interface** (`spn_if.sv`): SystemVerilog interface for clean connectivity

### Operation Modes

| Opcode    | Operation    | Description             |
| --------- | ------------ | ----------------------- |
| `2'b00` | No Operation | Idle state              |
| `2'b01` | Encrypt      | Plaintext → Ciphertext |
| `2'b10` | Decrypt      | Ciphertext → Plaintext |
| `2'b11` | Undefined    | Error state             |

## 📁 Project Structure

```
projectFiles/
├── rtl/                    # RTL Design Files
│   ├── spn_cu_top.sv      # Top-level SPN cryptographic unit
│   ├── spn_cu_pkg.sv      # Package with types and reference model
│   ├── spn_if.sv          # SystemVerilog interface
│   ├── spn_round.sv       # Individual round implementation
│   ├── sbox.sv            # Substitution box (encryption)
│   ├── invsbox.sv         # Inverse substitution box (decryption)
│   ├── key_scheduler.sv   # Key scheduling unit
│   └── tb_top.sv          # Testbench top module
├── tb/                    # UVM Testbench Components
│   ├── testbench.sv       # Main testbench file
│   ├── spn_tb_pkg.sv      # Testbench package
│   ├── spn_env.sv         # UVM environment
│   ├── spn_agent.sv       # UVM agent
│   ├── spn_driver.sv      # UVM driver
│   ├── spn_monitor.sv     # UVM monitor
│   ├── spn_scoreboard.sv  # UVM scoreboard
│   ├── spn_sequencer.sv   # UVM sequencer
│   ├── spn_sequence.sv    # UVM sequences
│   ├── spn_seq_item.sv    # UVM sequence item
│   ├── spn_base_test.sv   # Base UVM test class
│   └── spn_test.sv        # Specific test implementations
└── test_py.py            # Python test utilities
```

## 🧪 Verification Strategy

### UVM Testbench Architecture

The verification environment follows UVM methodology with the following components:

- **Agent**: Encapsulates driver, monitor, and sequencer
- **Driver**: Drives stimulus to the DUT
- **Monitor**: Observes DUT behavior and collects coverage
- **Scoreboard**: Implements reference model for result checking
- **Sequences**: Generate various test scenarios
- **Tests**: Define specific verification objectives

### Test Scenarios

- **Basic Functionality**: Encrypt/decrypt operations
- **Corner Cases**: Edge values, key patterns
- **Error Conditions**: Invalid opcodes, reset scenarios
- **Performance**: Throughput and latency measurements

## 🔍 Key Technical Details

### Cipher Specifications

- **Block Size**: 16 bits
- **Key Size**: 32 bits
- **Rounds**: 3 rounds for both encryption and decryption
- **S-Box Size**: 4×4 substitution table
- **P-Box**: Bit permutation layer

## 📊 Verification Results

The design has been thoroughly verified with:

- ✅ All encryption/decryption test vectors passed
- ✅ Corner case scenarios validated
