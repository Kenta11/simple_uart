module simple_receiver #(
  parameter [31:0] CLOCK_FREQUENCY = 32'd100_000_000,
  parameter [31:0] BAUD_RATE = 32'd115200,
  parameter [31:0] WORD_WIDTH = 32'd8
) (
  input                         clk,
  input                         rst,
  input                         din,
  output logic [WORD_WIDTH-1:0] dout,
  input                         full,
  output                        we
);
  // constants
  localparam [31:0] ONE_CYCLE = CLOCK_FREQUENCY / BAUD_RATE;

  // type definition
  typedef enum logic [2:0] {
    STATE_WAIT             = 3'h0,
    STATE_IGNORE_DATA_BIT  = 3'h1,
    STATE_RECEIVE_DATA_BIT = 3'h2,
    STATE_RECEIVE_STOP_BIT = 3'h3,
    STATE_WRITE_WORD       = 3'h4
  } state_t;

  // registers and wires
  state_t               state;
  logic [31:0]          clocks;
  logic [ONE_CYCLE-1:0] seq;
  logic [31:0]          zeros;
  logic [31:0]          received_bits;
  logic                 received_start_bit;
  logic                 received_a_word;
  logic                 half_clocks;
  logic                 full_clocks;

  // logics
  always_ff@(posedge clk)
  if (rst)
    dout <= {WORD_WIDTH{1'b0}};
  else
    case (state)
      STATE_RECEIVE_DATA_BIT: dout <= full_clocks ? {zeros <= (ONE_CYCLE / 2), dout[WORD_WIDTH-1:1]} : dout;
      default:                dout <= dout;
    endcase

  assign we = (state == STATE_WRITE_WORD);

  always_ff@(posedge clk)
  if (rst)
    state <= STATE_WAIT;
  else
    case (state)
      STATE_WAIT:             state <= received_start_bit ? STATE_IGNORE_DATA_BIT : state;
      STATE_IGNORE_DATA_BIT:  state <= half_clocks ? STATE_RECEIVE_DATA_BIT : state;
      STATE_RECEIVE_DATA_BIT: state <= received_a_word ? STATE_RECEIVE_STOP_BIT : state;
      STATE_RECEIVE_STOP_BIT: state <= full_clocks ? (((zeros <= (ONE_CYCLE / 2)) && (~full)) ? STATE_WRITE_WORD : STATE_WAIT) : state;
      STATE_WRITE_WORD:       state <= STATE_WAIT;
      default:                state <= state;
    endcase

  always_ff@(posedge clk)
  if (rst)
    clocks <= 32'h0;
  else
    case (state)
      STATE_IGNORE_DATA_BIT:  clocks <= half_clocks ? 32'h0 : clocks + 32'h1;
      STATE_RECEIVE_DATA_BIT: clocks <= full_clocks ? 32'h0 : clocks + 32'h1;
      STATE_RECEIVE_STOP_BIT: clocks <= full_clocks ? 32'h0 : clocks + 32'h1;
      default:                clocks <= 32'h0;
    endcase

  always_ff@(posedge clk)
  if (rst)
    seq <= {ONE_CYCLE{1'b1}};
  else if (full_clocks)
    seq <= {ONE_CYCLE{1'b1}};
  else
    seq <= {seq[ONE_CYCLE-2:0], din};

  always_ff@(posedge clk)
  if (rst)
    zeros <= 32'h0;
  else if (full_clocks)
    zeros <= 32'h0;
  else
    zeros <= zeros - (~seq[ONE_CYCLE-1]) + (~din);

  always_ff@(posedge clk)
  if (rst)
    received_bits <= 4'h0;
  else
    case (state)
      STATE_RECEIVE_DATA_BIT: received_bits <= full_clocks ? received_bits + 4'h1 : received_bits;
      default:                received_bits <= 4'h0;
    endcase

  always_comb
  case (state)
    STATE_WAIT: received_start_bit = (zeros == (ONE_CYCLE / 2));
    default:    received_start_bit = 1'b0;
  endcase

  always_comb
  case (state)
    STATE_RECEIVE_DATA_BIT: received_a_word = full_clocks && (received_bits == 4'h7);
    default:                received_a_word = 1'b0;
  endcase

  assign half_clocks = (clocks == (ONE_CYCLE / 2));
  assign full_clocks = (clocks == (ONE_CYCLE - 1));
endmodule
