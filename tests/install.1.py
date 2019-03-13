# Copyright (C) 2019 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from gnucap import ELEMENT, CARD_LIST, SIM
from gnucap import parse
from gnucap import command
from gnucap.pending import install

@install
class mytype2(ELEMENT):
	def custom(self):
		return 41

	def dev_type(self):
		return "mytype2"

	def clone(self):
		return __class__(self)

	def ac_iwant_matrix(self):
		pass
	def tr_iwant_matrix(self):
		pass

	def tr_probe_num(self, s):
		return 2.

@install
class mytype3(ELEMENT):
	def custom(self):
		return 41

	def clone(self):
		return __class__(self)

	def ac_iwant_matrix(self):
		pass
	def tr_iwant_matrix(self):
		pass

	def tr_probe_num(self, s):
		return 3.

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
	def ac_iwant_matrix(self):
		pass
	def tr_iwant_matrix(self):
		pass

	def tr_probe_num(self, s):
		return 4.

	# uses default if not specified.
	# def clone(self):
	#	return __class__(self)

command("set lang verilog")
parse("mytype2 #() a2();")
parse("mytype3 #() a3();")
parse("mytype4 #() a4(0, 0);")

cl = CARD_LIST().card_list_()
for a in cl:
	print(a.long_label(), a.dev_type())

import sys
sys.stdout.flush()
command("list")
command("print op test(*)")
command("op")
