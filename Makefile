SRCS = simple_receiver.sv \
       simple_transmitter.sv
TESTS = tb_simple_receiver.sv \
        tb_simple_transmitter.sv

.PHONY: all test clean

all: vunit_out

vunit_out: script/unittest.py $(addprefix src/, $(SRCS)) $(addprefix tb/, $(TESTS))
	python script/unittest.py

clean:
	rm -rf vunit_out

