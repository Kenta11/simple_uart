module transmitter_axis #(
  parameter [31:0] CLOCK_FREQUENCY = 32'd100_000_000,
  parameter [31:0] BAUD_RATE       = 32'd115200,
  parameter [31:0] WORD_WIDTH      = 32'd8
) (
  input                  clk,
  input                  rst,
  input [WORD_WIDTH-1:0] din_axis_tdata,
  output                 din_axis_tready,
  input                  din_axis_tvalid,
  output                 dout
);
  // constant
  localparam [31:0] CLOCKS_PER_BIT = CLOCK_FREQUENCY / BAUD_RATE;

  // type definition
  typedef enum logic {
    STATE_WAIT          = 1'h0,
    STATE_TRANSMIT_BITS = 1'h1
  } state_t;

  // registers and wires
  state_t                state;
  logic [WORD_WIDTH+1:0] data;
  logic [31:0]           clock_counts;
  logic                  full_clock_counts;

  // logics
  assign din_axis_tready = (state == STATE_WAIT);
  assign dout = (state == STATE_TRANSMIT_BITS) ? data[0] : 1'b1;

  always_ff@(posedge clk)
  if (rst)
    state <= STATE_WAIT;
  else
    case (state)
      STATE_WAIT:          state <= din_axis_tvalid ? STATE_TRANSMIT_BITS : state;
      STATE_TRANSMIT_BITS: state <= (full_clock_counts && (data == {{WORD_WIDTH{1'b0}}, 1'b1})) ? STATE_WAIT : state;
    endcase

  always_ff@(posedge clk)
  if (rst)
    data <= {WORD_WIDTH+1{1'b1}};
  else
    case (state)
      STATE_WAIT:          data <= {1'b1, din_axis_tdata, 1'b0};
      STATE_TRANSMIT_BITS: data <= full_clock_counts ? {1'b0, data[WORD_WIDTH+1:1]} : data;
    endcase

  always_ff@(posedge clk)
  if (rst)
    clock_counts <= 32'h0;
  else
    case (state)
      STATE_TRANSMIT_BITS: clock_counts <= full_clock_counts ? 32'h0 : clock_counts + 32'h1;
      default:             clock_counts <= 32'h0;
    endcase

  assign full_clock_counts = (clock_counts == (CLOCKS_PER_BIT - 1));
endmodule
