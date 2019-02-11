# testing environment override

import os
os.environ["GNUCAP_LANG"] = "verilog"

import gnucap

gnucap.parse("resistor r1(0,1)")
gnucap.command("list")

gnucap.parse("error_1")
gnucap.command("error_2") # TODO: can't see any error
