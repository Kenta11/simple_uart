#!/usr/bin/env python3
# -*- coding: utf-8 -*-


from vunit.verilog import VUnit

vu = VUnit.from_argv()

lib = vu.add_library("lib")

lib.add_source_files("src/simple_receiver.sv")
lib.add_source_files("src/simple_transmitter.sv")

lib.add_source_files("tb/tb_simple_receiver.sv")
lib.add_source_files("tb/tb_simple_transmitter.sv")

vu.main()

