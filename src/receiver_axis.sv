module receiver_axis #(
  parameter [31:0] CLOCK_FREQUENCY = 32'd100_000_000,
  parameter [31:0] BAUD_RATE       = 32'd115200,
  parameter [31:0] WORD_WIDTH      = 32'd8
) (
  input                   clk,
  input                   rst,
  input                   din,
  output [WORD_WIDTH-1:0] dout_axis_tdata,
  input                   dout_axis_tready,
  output                  dout_axis_tvalid
);
  // constants
  localparam [31:0] CLOCKS_PER_BIT = CLOCK_FREQUENCY / BAUD_RATE;

  // type definition
  typedef enum logic [1:0] {
    STATE_WAIT         = 2'h0,
    STATE_RECEIVE_BITS = 2'h1,
    STATE_WRITE_WORD   = 2'h2
  } state_t;

  // registers and wires
  state_t                state;
  logic [WORD_WIDTH+1:0] data;
  logic [31:0]           clock_counts;
  logic                  half_clock_counts;
  logic                  full_clock_counts;

  // logics
  assign dout_axis_tdata = data[WORD_WIDTH:1];
  assign dout_axis_tvalid = (state == STATE_WRITE_WORD);

  always_ff@(posedge clk)
  if (rst)
    state <= STATE_WAIT;
  else
    case (state)
      STATE_WAIT:         state <= (~din) ? STATE_RECEIVE_BITS : state;
      STATE_RECEIVE_BITS:
        if (full_clock_counts) begin
          if (~data[0])
            state <= data[WORD_WIDTH+1] ? STATE_WRITE_WORD : STATE_WAIT;
          else
            state <= (data == {{WORD_WIDTH+2}{1'b1}}) ? STATE_WAIT : state;
        end
        else
          state <= state;
      STATE_WRITE_WORD:   state <= STATE_WAIT;
      default:            state <= state;
    endcase

  always_ff@(posedge clk)
  if (rst)
    data <= {{WORD_WIDTH+2}{1'b1}};
  else
    case (state)
      STATE_RECEIVE_BITS: data <= half_clock_counts ? {din, data[WORD_WIDTH+1:1]} : data;
      STATE_WRITE_WORD:   data <= data;
      default:            data <= {{WORD_WIDTH+2}{1'b1}};
    endcase

  always_ff@(posedge clk)
  if (rst)
    clock_counts <= 32'h0;
  else
    case (state)
      STATE_RECEIVE_BITS: clock_counts <= full_clock_counts ? 32'h0 : clock_counts + 32'h1;
      default:            clock_counts <= 32'h0;
    endcase

  assign half_clock_counts = (clock_counts == (CLOCKS_PER_BIT / 2));
  assign full_clock_counts = (clock_counts == (CLOCKS_PER_BIT - 1));
endmodule
