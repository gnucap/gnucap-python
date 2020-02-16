# Copyright (C) 2019 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from sys import stdout
import sys
import numpy as np
from copy import deepcopy, copy

#from gnucap import install_command
from gnucap import CARD_LIST, outset, outreset
from gnucap import CARD
from gnucap import ELEMENT, COMPONENT
from gnucap import parse
from gnucap import install_device
from gnucap import command

class mytype(ELEMENT):
	def __init__(self, other=None):
		if other is None:
			ELEMENT.__init__(self)
		else:
			ELEMENT.__init__(self, other)
		self.HACK=[]

	def custom(self):
		return 42

	def clone(self):
		print("somelt clone")
		x = mytype(self)
		self.HACK.append(x)
		x.__class__ = mytype
		return x

s = mytype()
d1 = install_device("mytype", s)

command("set lang verilog")
parse("mytype #() a();")
parse("resistor #() r(0,0);")

cl = CARD_LIST().card_list_()
print("tst")
for a in cl:
	print(a.long_label(), "..")
	if(isinstance(a, mytype)):
		print(".. is mytype")
		assert(42==a.custom())
		assert(isinstance(a, ELEMENT))

	if(isinstance(a, ELEMENT)):
		print(".. is element")
		assert(isinstance(a, COMPONENT))

	if(isinstance(a, COMPONENT)):
		print(".. is component")
		if(not isinstance(a, CARD)):
			import inspect
			print("ERROR, should be card", inspect.getmro(a.__class__))

	if(isinstance(a, CARD)):
		print(".. is card")
	else:
		print("type", type(a))
