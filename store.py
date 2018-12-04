# Copyright (C) 2018 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from __future__ import print_function

import gnucap

gnucap.command("set lang spice")
gnucap.parse("V1 1 0 ac 1")
gnucap.command("set lang verilog")
gnucap.parse("capacitor #(.c(1u)) c(1 nout)")
gnucap.parse("resistor #(.r(1k)) s(nout 0)")

gnucap.command("store ac v(nout)")
gnucap.command("ac 1 1024 * 4")

w = gnucap.CKT_BASE_find_wave("v(nout)")

b = iter(w)

for i in range(6):
	n=next(b)
	print(n[0], ' {:.6e}'.format(n[1]))

try:
	next(b)
	assert(False)
except StopIteration:
	pass

for i in w:
	print(i[0], ' {:.6e}'.format(i[1]))


print("done")
