# Copyright (C) 2019 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from gnucap import ELEMENT, CARD_LIST, SIM
from gnucap import parse
from gnucap import command
from gnucap import install_device

class mytype(ELEMENT):
	def custom(self):
		return 41

	def ddev_type(self):
		return "mytype_"

	def clone(self):
		return __class__(self)

	def ac_iwant_matrix(self):
		pass
	def tr_iwant_matrix(self):
		pass

	def tr_probe_num(self, s):
		return 1.

d1 = mytype()
a = install_device("mytype", d1)

class dummy(ELEMENT):
	def custom(self):
		return 41

	def dev_type(self):
		return "not_reached"

	def clone(self):
		return mytype(self)

d2 = dummy()
b = install_device("dummy", d2)

class mytype4(ELEMENT):

	def port_name(self, i):
		return ["a","b"][i]
	def port_exists(self, i):
		return i<2
	def net_nodes(self):
		return 2
	def max_nodes(self):
		return 2
	def ac_iwant_matrix(self):
		pass
	def tr_iwant_matrix(self):
		pass

	def tr_probe_num(self, s):
		return 4.

	# uses default if not specified.
	# def clone(self):
	#	return __class__(self)

d4=mytype4()
b2=install_device("mytype4", d4)

command("set lang verilog")
parse("dummy #() d();")
parse("mytype #() a1();")
parse("mytype4 #() a4(0, 0);")
parse("resistor #() r(0,0);")

cl = CARD_LIST().card_list_()
for a in cl:
	print(a.long_label(), a.dev_type())

import sys
sys.stdout.flush()
command("list")
command("print op test(*)")
command("op")
