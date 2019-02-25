# Copyright (C) 2018 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from __future__ import print_function

import gnucap
import sys

from gnucap import install_device

try:
	a = gnucap.SIM()
	assert(False)
except RuntimeError:
	print("SIM construction refused (correct)")

class MyAC(gnucap.SIM):
	def do_it(self, cmd, scope):
		print("HELLOWORLD")
	def setup(self, cmd):
		pass
	def sweep(self):
		pass

class MyAC2(gnucap.SIM):
	def do_it(self, cmd, scope):
		print("HELLOWORLD2")
	def setup(self, cmd):
		pass
	def sweep(self):
		pass

ac = MyAC()
ac2 = MyAC2()
print("install1")
d1 = gnucap.install_command("myac1", ac)
print("install2")
d2 = gnucap.install_command("myac", ac2)
d3 = gnucap.install_command("myac", ac)
d4 = gnucap.install_command("ac", ac)

gnucap.command("set trace")
gnucap.command("ac 1 2 * 2")
gnucap.command("myac1 1 2 * 2")
gnucap.command("myac:0 1 2 * 2")
gnucap.command("myac 1 2 * 2")

print("side effects?")
del(d2)
try:
	gnucap.command("myac:0 1 2 * 2") # bad command? yes. this was d2
	print("FAIL")
except NameError as e:
	print("got nameError", e)

print("....")
sys.stdout.flush()
gnucap.command("myac 1 2 * 2")
gnucap.command("myac1 1 2 * 2")


print("done")

# gnucap.parse("myac 1 2 * 2")
