<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a PWM (Pulse Width Modulation) controller with SPI interface. The design consists of:

1. A main module that handles input/output signals and coordinates the PWM functionality
2. A PWM peripheral that generates PWM signals with configurable duty cycles at 3000 Hz
3. An SPI interface for communication and control

The system accepts input signals through dedicated input pins (`ui_in`) and bidirectional I/O pins (`uio_in`). The PWM controller can be configured through register writes over the SPI interface, allowing control of:
- Output enable/disable for different channels
- PWM duty cycle settings
- Output signal generation

## How to test

The project can be tested using the provided testbench and cocotb framework. Testing involves:

1. **Setup**:
   - Install the required dependencies from `test/requirements.txt`
   - Ensure the Makefile points to your Verilog source files
   - Update the testbench with your module name

2. **Running Tests**:
   - Run RTL simulation: `make -B`
   - For gate-level simulation: `make -B GATES=yes`
   - View waveforms using GTKWave: `gtkwave tb.vcd tb.gtkw`

3. **Test Cases**:
   - SPI communication testing
   - PWM frequency verification
   - Duty cycle control testing
   - Output enable/disable functionality

## External hardware

This is a digital design that can be implemented on an FPGA or ASIC. The I/O pins can be connected to:
- Digital output devices (LEDs, motors, etc.)
- External controllers through the SPI interface
- Other digital systems requiring PWM control

No specific external hardware is required for basic operation, but the design can be integrated with various digital systems depending on the application requirements.
