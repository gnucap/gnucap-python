# Copyright (C) 2018 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

# a simulation plugin written in python...
# load from gnucap with "python simplugin.py",
# then run "mysim".

from sys import stdout
from gnucap import out
from gnucap import install_command
from gnucap import SIM
out("... OK\n")

import sys

class mysim(SIM):
	def do_it(self, cmd, scope):
#		print("running mysim...")
		out("running mysim...\n")
	def setup(self, cmd):
		pass
		#out = IO.mstdout;
		#out.reset(); # BUG// don't know why this is needed
	def sweep(self):
		pass

sim = mysim()

d1 = install_command("test", sim)
#del(d1) #what does it do?
d1 = install_command("test", sim)

out("installing again\n")
d2 = install_command("test", sim)
out("installing again\n")
d3 = install_command("mysim", sim)

#BUG: that does not work as expected.
# it just breaks "mysim". why?
#d3 = install_command("mysim", sim)

sys.stdout.flush()
