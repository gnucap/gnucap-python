#!/usr/bin/env python

import gnucap

gnucap.command("print op hidden(0)")
gnucap.command("store op hidden(0)")
gnucap.command("op")
w = gnucap.CKT_BASE_find_wave("hidden(0)")

gnucap.command("param test=17")
gnucap.command("eval test")
gnucap.command("measure mm at(probe='hidden(0)')")

assert(17==gnucap.eval("test"))
assert(0==gnucap.eval("mm"))

for i in w:
	print(i)

