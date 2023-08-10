SRCS = receiver_axis.sv \
       receiver_native.sv \
       transmitter_axis.sv \
	   transmitter_native.sv
TESTS = tb_receiver_axis.sv \
		tb_receiver_native.sv \
        tb_transmitter_native.sv \
		tb_transmitter_axis.sv

.PHONY: all test clean

all: vunit_out

vunit_out: script/unittest.py $(addprefix src/, $(SRCS)) $(addprefix tb/, $(TESTS))
	python script/unittest.py

clean:
	rm -rf vunit_out

