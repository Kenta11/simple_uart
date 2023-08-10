#!/usr/bin/env python3
# -*- coding: utf-8 -*-


from vunit.verilog import VUnit

vu = VUnit.from_argv()

lib = vu.add_library("lib")

lib.add_source_files("src/receiver_axis.sv")
lib.add_source_files("src/receiver_native.sv")
lib.add_source_files("src/transmitter_axis.sv")
lib.add_source_files("src/transmitter_native.sv")

lib.add_source_files("tb/tb_receiver_axis.sv")
lib.add_source_files("tb/tb_receiver_native.sv")
lib.add_source_files("tb/tb_transmitter_native.sv")
lib.add_source_files("tb/tb_transmitter_axis.sv")

vu.main()

