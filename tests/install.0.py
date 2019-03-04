# Copyright (C) 2019 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from gnucap import ELEMENT, CARD_LIST, SIM
from gnucap import parse
from gnucap import command
from gnucap.experimental import install

class mytype(ELEMENT):
	def custom(self):
		return 41

	def ddev_type(self):
		return "mytype_"

	def clone(self):
		return __class__(self)

a=install("mytype", mytype())

class dummy(ELEMENT):
	def custom(self):
		return 41

	def dev_type(self):
		return "not_reached"

	def clone(self):
		return mytype(self)

b=install("dummy", dummy())

@install
class mytype2(ELEMENT):
	def custom(self):
		return 41

	def dev_type(self):
		return "mytype2"

	def clone(self):
		return __class__(self)

@install
class mytype3(ELEMENT):
	def custom(self):
		return 41

	def clone(self):
		return __class__(self)

@install
class mytype4(ELEMENT):

	def port_name(self, i):
		return ["a","b"][i]
	def port_exists(self, i):
		return i<2
	def net_nodes(self):
		return 2
	def max_nodes(self):
		return 2

	# uses default if not specified.
	# def clone(self):
	#	return __class__(self)

command("set lang verilog")
parse("dummy #() d();")
parse("mytype #() a2();")
parse("mytype2 #() a2();")
parse("mytype3 #() a3();")
parse("mytype4 #() a4(0, 0);")
parse("resistor #() r(0,0);")

cl = CARD_LIST().card_list_()
for a in cl:
	print(a.long_label(), a.dev_type())

command("list")
