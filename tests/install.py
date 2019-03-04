# Copyright (C) 2019 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from gnucap import ELEMENT, CARD_LIST, SIM
from gnucap import parse
from gnucap import command
from gnucap.experimental import install

@install()
class mytype2(ELEMENT):
	def __init__(self, *argv, **args):
		ELEMENT.__init__(self, *argv, **args)

	def custom(self):
		return 41

	def dev_type(self):
		return "mytype2"

	def clone(self):
		s = mytype2(self)
		return s

@install("simcmd")
class mysim(SIM):
	def do_it(self, cmd, scope):
		print("running mysim...")
	def setup(self, cmd):
		pass
	def sweep(self):
		pass

@install("mytype1")
class mytype1(ELEMENT):

	def custom(self):
		return 42

	def dev_type(self):
		return "mytype1"

	def clone(self):
		s = mytype1(self)
		return s

# install manually. below.
class mytype(ELEMENT):
	def __init__(self, other=None):
		if other is None:
			ELEMENT.__init__(self)
		else:
			ELEMENT.__init__(self, other)

	def custom(self):
		return 42

	def dev_type(self):
		return "mytype0"

	def clone(self):
		s = mytype(self)
		return s

m = mytype()
a = install("mytype0|y", m)
b = install("y", m)

command("set lang verilog")
parse("mytype0 #() a0();")
parse("mytype1 #() a1();")
parse("mytype2 #() a2();")
parse("resistor #() r();")

cl = CARD_LIST().card_list_()
for a in cl:
	print(a.long_label(), a.dev_type())

command("simcmd")
