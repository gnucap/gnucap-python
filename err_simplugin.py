# Copyright (C) 2019 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

# a simulation plugin written in python...
# load from gnucap with "python simplugin.py",
# then run "mysim".

from gnucap import install_command
from gnucap import SIM

import sys

class mysim(SIM):
	def do_it(self, cmd, scope):
		parse_Error

sim = mysim()

d1 = install_command("mysim", sim)
