# Copyright (C) 2019 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from gnucap import ELEMENT, CARD_LIST, COMPONENT, CMD
from gnucap import parse
from gnucap import command

# these will be deprecated.
from gnucap import install_device
from gnucap import install_command

# installer and decorator, this is experimental
class install:
	def __del__(self):
		self.i1=None

	def __init__(self, *argv, **args):
		if(len(argv)>1):
			self.name = argv[0]
			self.i1 = self.install_instance(argv[0], argv[1])
		elif(len(argv)==1):
			self.name = argv[0]
		elif(len(argv)==0):
			self.name = None

	def install_instance(self, name, what):
		if(isinstance(what, COMPONENT)):
			return install_device(name, what)
		elif(isinstance(what, CMD)):
			return install_command(name, what)
		else:
			raise TypeError("don't know what this is")
	
	def __call__(self, cls):
		cls._hidden_instance = cls()
		if(self.name is None):
			self.name = cls.dev_type(None)
		cls.i1 = self.install_instance(self.name, cls._hidden_instance)

		return cls

# ====================================

# from gnucap import install

@install()
class mytype2(ELEMENT):
	def __init__(self, other=None):
		if other is None:
			ELEMENT.__init__(self)
		else:
			ELEMENT.__init__(self, other)

	def custom(self):
		return 41

	def dev_type(self):
		return "mytype2"

	def clone(self):
		s = mytype2(self)
		return s


@install("mytype1")
class mytype1(ELEMENT):
	def __init__(self, other=None):
		if other is None:
			ELEMENT.__init__(self)
		else:
			ELEMENT.__init__(self, other)

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
a = install("x|mytype0", m)
a = None # BUG. this is needed (missing assign?)
a = install("x|mytype0", m)
b = install("mytype0", m)

command("set lang verilog")
parse("mytype0 #() a0();")
parse("mytype1 #() a1();")
parse("mytype2 #() a2();")
parse("resistor #() r();")

cl = CARD_LIST().card_list_()
for a in cl:
	print(a.long_label(), a.dev_type())
