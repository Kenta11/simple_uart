# The simple uart

## What is this?

The simple uart is a collection of SystemVerilog modules for serial communication.

## Interface

### Common parameters

| Parameter name  | Description          |  Default  |
| --------------- | -------------------- | --------- |
| CLOCK_FREQUENCY | Clock frequency (Hz) | 100000000 |
| BAUD_RATE       | Baud rate (bps)      |  115200   |
| WORD_WIDTH      | Data word width      |     8     |

### AXI4 Stream

#### Receiver

- [receiver_axis.sv](src/receiver_axis.sv)

|   Signal Name    | I/O | Initial State | Description       |
| ---------------- | --- | ------------- | ----------------- |
|       clk        |  I  |       -       | Clock             |
|       rst        |  I  |       -       | Reset             |
|       din        |  I  |       -       | Receive data      |
| dout_axis_tdata  |  O  |       -       | FIFO write data   |
| dout_axis_tready |  I  |       -       | FIFO write ready  |
| dout_axis_tvalid |  O  |     1'b0      | FIFO write valid  |

#### Transmitter

- [transmitter_axis.sv](src/transmitter_axis.sv)

|   Signal Name   | I/O | Initial State | Description       |
| --------------- | --- | ------------- | ----------------- |
|       clk       |  I  |       -       | Clock             |
|       rst       |  I  |       -       | Reset             |
| din_axis_tdata  |  I  |       -       | FIFO read data    |
| din_axis_tready |  O  |     1'b1      | FIFO read ready   |
| din_axis_tvalid |  I  |       -       | FIFO read valid   |
|       dout      |  O  |     1'b1      | Transmit data     |

### Xilinx native FIFO buffer interface

#### Receiver

- [receiver_native.sv](src/receiver_native.sv)

| Signal Name | I/O | Initial State | Description       |
| ----------- | --- | ------------- | ----------------- |
|     clk     |  I  |       -       | Clock             |
|     rst     |  I  |       -       | Reset             |
|     din     |  I  |       -       | Receive data      |
|     dout    |  O  |       -       | FIFO write data   |
|     full    |  I  |       -       | FIFO full         |
|     we      |  O  |     1'b0      | FIFO write enable |

#### Transmitter

- [transmitter_native.sv](src/transmitter_native.sv)

| Signal Name | I/O | Initial State | Description       |
| ----------- | --- | ------------- | ----------------- |
|     clk     |  I  |       -       | Clock             |
|     rst     |  I  |       -       | Reset             |
|     din     |  I  |       -       | FIFO read data    |
|     empty   |  I  |       -       | FIFO empty        |
|     re      |  O  |     1'b0      | FIFO read enable  |
|     dout    |  O  |     1'b1      | Transmit data     |

## License

It is licensed under MIT license. See [LICENSE](LICENSE) for details.
