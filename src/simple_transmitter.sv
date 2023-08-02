module simple_transmitter #(
  parameter [31:0] CLOCK_FREQUENCY = 32'd100_000_000,
  parameter [31:0] BAUD_RATE = 32'd115200,
  parameter [31:0] WORD_WIDTH = 32'd8
) (
  input                  clk,
  input                  rst,
  input [WORD_WIDTH-1:0] din,
  input                  empty,
  output logic           re,
  output logic           dout
);
  // constant
  localparam [31:0] ONE_CYCLE = CLOCK_FREQUENCY / BAUD_RATE;

  // type definition
  typedef enum logic [2:0] {
    STATE_WAIT               = 3'h0,
    STATE_SEND_ENABLE        = 3'h1,
    STATE_LOAD_DATA          = 3'h2,
    STATE_TRANSMIT_START_BIT = 3'h3,
    STATE_TRANSMIT_DATA_BIT  = 3'h4,
    STATE_TRANSMIT_STOP_BIT  = 3'h5
  } state_t;

  // registers and wires
  state_t                state;
  logic [WORD_WIDTH-1:0] data;
  logic [31:0]           clocks;
  logic [31:0]           transmitted_bits;
  logic                  full_clocks;

  // logics
  always_ff@(posedge clk)
  if (rst)
    re = 1'b0;
  else
    case (state)
      STATE_WAIT: re <= (~empty);
      default:    re <= 1'b0;
    endcase

  always_comb
  case (state)
    STATE_TRANSMIT_START_BIT: dout = 1'b0;
    STATE_TRANSMIT_DATA_BIT:  dout = data[0];
    default:                  dout = 1'b1;
  endcase

  always_ff@(posedge clk)
  if (rst)
    state <= STATE_WAIT;
  else
    case (state)
      STATE_WAIT:               state <= (~empty) ? STATE_SEND_ENABLE : state;
      STATE_SEND_ENABLE:        state <= STATE_LOAD_DATA;
      STATE_LOAD_DATA:          state <= STATE_TRANSMIT_START_BIT;
      STATE_TRANSMIT_START_BIT: state <= full_clocks ? STATE_TRANSMIT_DATA_BIT : state;
      STATE_TRANSMIT_DATA_BIT:  state <= (full_clocks && (transmitted_bits == (WORD_WIDTH - 1))) ? STATE_TRANSMIT_STOP_BIT : state;
      STATE_TRANSMIT_STOP_BIT:  state <= full_clocks ? STATE_WAIT : state;
      default:                  state <= state;
    endcase

  always_ff@(posedge clk)
  if (rst)
    data <= {WORD_WIDTH+1{1'b1}};
  else
    case (state)
      STATE_LOAD_DATA:         data <= din;
      STATE_TRANSMIT_DATA_BIT: data <= full_clocks ? {1'b1, data[WORD_WIDTH-1:1]} : data;
      default:                 data <= data;
    endcase

  always_ff@(posedge clk)
  if (rst)
    clocks <= 32'h0;
  else
    case (state)
      STATE_TRANSMIT_START_BIT: clocks <= full_clocks ? 32'h0 : clocks + 32'h1;
      STATE_TRANSMIT_DATA_BIT:  clocks <= full_clocks ? 32'h0 : clocks + 32'h1;
      STATE_TRANSMIT_STOP_BIT:  clocks <= full_clocks ? 32'h0 : clocks + 32'h1;
      default:                  clocks <= 32'h0;
    endcase

  always@(posedge clk)
  if (rst)
    transmitted_bits <= 32'h0;
  else
    case (state)
      STATE_TRANSMIT_DATA_BIT: transmitted_bits <= full_clocks ? transmitted_bits + 32'h1 : transmitted_bits;
      default:                 transmitted_bits <= 32'h0;
    endcase

  assign full_clocks = (clocks == (ONE_CYCLE - 1));
endmodule
