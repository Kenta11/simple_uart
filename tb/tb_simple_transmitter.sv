`include "vunit_defines.svh"
`timescale 1ns/1ns

module tb_simple_transmitter;
  localparam [31:0] CLOCK_FREQUENCY = 32'd100_000_000;
  localparam [31:0] BAUD_RATE = 32'd115200;
  localparam [31:0] WORD_WIDTH = 32'd8;

  localparam [31:0] CLOCK_PERIOD = 32'd10;

  logic                  clk;
  logic                  rst;
  logic [WORD_WIDTH-1:0] din;
  logic                  empty;
  logic                  re;
  logic                  dout;

  always #(CLOCK_PERIOD/2) clk = ~clk;

  `TEST_SUITE begin
    `TEST_CASE_SETUP begin
      clk   = 1'b0;
      rst   = 1'b0;
      din   = {WORD_WIDTH{1'b0}};
      empty = 1'b1;

      #CLOCK_PERIOD;

      rst   = 1'b1;

      #CLOCK_PERIOD;

      rst   = 1'b0;
    end
    `TEST_CASE("test_1byte") begin
      din   = 8'hA5;
      empty = 1'b0;

      #CLOCK_PERIOD;

      // state == STATE_SEND_ENABLE
      `CHECK_EQUAL(re, 1'b1);
      `CHECK_EQUAL(dout, 1'b1);

      empty = 1'b1;

      #CLOCK_PERIOD;

      // state == STATE_LOAD_DATA
      `CHECK_EQUAL(re, 1'b0);
      `CHECK_EQUAL(dout, 1'b1);

      for (integer j = 0; j < WORD_WIDTH + 2; j = j + 1) begin
        for (integer i = 0; i < CLOCK_FREQUENCY/BAUD_RATE; i = i + 1) begin
          #CLOCK_PERIOD;

          // state == STATE_TRANSMIT_*_BIT
          `CHECK_EQUAL(re, 1'b0);
          `CHECK_EQUAL(dout, {1'b1, din, 1'b0}[j]);
        end
      end

      #CLOCK_PERIOD;

      // state == STATE_WAIT
      `CHECK_EQUAL(re, 1'b0);
      `CHECK_EQUAL(dout, 1'b1);
    end
  end

  `WATCHDOG(1ms);

  simple_transmitter dut(.*);
endmodule
