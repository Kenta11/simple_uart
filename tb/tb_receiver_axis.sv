`include "vunit_defines.svh"
`timescale 1ns/1ns

module tb_receiver_axis;
  localparam [31:0] CLOCK_FREQUENCY = 32'd100_000_000;
  localparam [31:0] BAUD_RATE = 32'd115200;
  localparam [31:0] WORD_WIDTH = 32'd8;

  localparam [31:0] CLOCK_PERIOD = 32'd10;

  logic                  clk;
  logic                  rst;
  logic                  din;
  logic [WORD_WIDTH-1:0] dout_axis_tdata;
  logic                  dout_axis_tvalid;
  logic                  dout_axis_tready;

  always #(CLOCK_PERIOD/2) clk = ~clk;

  `TEST_SUITE begin
    `TEST_CASE_SETUP begin
      clk              = 1'b0;
      rst              = 1'b0;
      din              = 1'b1;
      dout_axis_tready = 1'b1;

      #CLOCK_PERIOD;

      rst              = 1'b1;

      #CLOCK_PERIOD;

      rst              = 1'b0;
    end
    `TEST_CASE("test_1byte") begin
      // STATE_RECEIVE_BITS
      for (integer j = 0; j < WORD_WIDTH + 2; j = j + 1) begin
        din  = {1'b1, 8'hA5, 1'b0}[j];
        for (integer i = 0; i < CLOCK_FREQUENCY/BAUD_RATE; i = i + 1) begin
          #CLOCK_PERIOD;

          `CHECK_EQUAL(dout_axis_tvalid, 1'b0);
        end
      end

      #CLOCK_PERIOD;

      // state == STATE_WRITE_WORD
      `CHECK_EQUAL(dout_axis_tdata, 8'hA5);
      `CHECK_EQUAL(dout_axis_tvalid, 1'b1);

      #CLOCK_PERIOD;

      // state == STATE_WAIT
      `CHECK_EQUAL(dout_axis_tvalid, 1'b0);
    end
  end

  `WATCHDOG(1ms);

  receiver_axis dut(.*);
endmodule
