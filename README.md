# The simple uart

## What is this?

The simple uart is a pair of SystemVerilog modules for serial communication.
The receiver receives input signals. Then, it writes the data into Xilinx native FIFO buffer.
The transmitter reads data from Xilinx native FIFO buffer. Then, it transmits output signals.

## Interface

### Common parameters

| Parameter name  | Description          |  Default  |
| --------------- | -------------------- | --------- |
| CLOCK_FREQUENCY | Clock frequency (Hz) | 100000000 |
| BAUD_RATE       | Baud rate (bps)      |  115200   |
| WORD_WIDTH      | Data word width      |     8     |

### Receiver

| Signal Name | I/O | Initial State | Description       |
| ----------- | --- | ------------- | ----------------- |
|     clk     |  I  |       -       | Clock             |
|     rst     |  I  |       -       | Reset             |
|     din     |  I  |       -       | Receive data      |
|     dout    |  O  |       0       | FIFO write data   |
|     full    |  I  |       -       | FIFO full         |
|     we      |  O  |       0       | FIFO write enable |

### Transmitter

| Signal Name | I/O | Initial State | Description       |
| ----------- | --- | ------------- | ----------------- |
|     clk     |  I  |       -       | Clock             |
|     rst     |  I  |       -       | Reset             |
|     din     |  I  |       -       | FIFO read data    |
|    empty    |  I  |       -       | FIFO empty        |
|     re      |  O  |       0       | FIFO read enable  |
|     dout    |  O  |       1       | Transmit data     |

## License

It is licensed under MIT license. See [LICENSE](LICENSE) for details.
