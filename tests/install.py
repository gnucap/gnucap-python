# Copyright (C) 2019 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from gnucap import ELEMENT, CARD_LIST, COMPONENT, CMD
from gnucap import parse
from gnucap import command

class install:
	def __init__(self, *argv, **args):
		self.name = argv[0]
	
	def __call__(self, cls):
		cls.d1 = cls()
		if(issubclass(cls, COMPONENT)):
			from gnucap import install_device
			self.i1 = install_device(self.name, cls.d1)
		elif(issubclass(cls, CMD)):
			from gnucap import install_command
			self.i1 = install_command(self.name, cls.d1)
		else:
			incomplete

		return cls

# ====================================

# from gnucap import install

@install("mytype")
class mytype(ELEMENT):
	def __init__(self, other=None):
		if other is None:
			ELEMENT.__init__(self)
		else:
			ELEMENT.__init__(self, other)

	def custom(self):
		return 42

	def dev_type(self):
		return "mytype"

	def clone(self):
		s = mytype(self)
		return s

command("set lang verilog")
parse("mytype #() a();")
parse("resistor #() r();")

cl = CARD_LIST().card_list_()
for a in cl:
	print(a.long_label(), a.dev_type())
