# Copyright (C) 2018 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from __future__ import print_function

import gnucap

from gnucap import ELEMENT
from gnucap import node_t
from gnucap import install_device
from copy import deepcopy, copy

try:
	c = ELEMENT()
	print("ERROR, must be pure")
	assert(False)
except RuntimeError:
	pass
except AttributeError:
	pass

# trick python garbage collector
# todo: hide in wrapper layer

class myvs(ELEMENT):
	def __init__(self, other=None):
		if other is None:
			# print("construct myvs", self) // python3?
			ELEMENT.__init__(self) # this is required. (or do not implement __init__)
		else:
			print("copyconstruct myvs")
			ELEMENT.__init__(self, other) # this is required. (or do not implement __init__)
		# print("init", self.long_label()) // py3?
		self.HACK=[]

#	def __reduce__(self):
#		print("reducing")
#		return(self.__class__, ( ) )

	def clone(self):
		print("somelt clone")
		x = myvs(self)
		self.HACK.append(x)
		return x

	def value(self):
		return "a";

	def dev_type(self):
		return "pyelt"

	def min_nodes(self):
		return 2;
	def net_nodes(self):
		return 2;
	def max_nodes(self):
		return 2;
	def matrix_nodes(self):
		return 2;
	def net_nodes(self):
		return 2;
	def tr_iwant_matrix(self):
  	   self.tr_iwant_matrix_passive()
	def ac_iwant_matrix(self):
		print("iwant incomplete")
	def tr_involts(self):
		return self.tr_outvolts()
	def precalc_last(self):
		self.element_precalc_last()
		self.set_constant(False)
	def tr_begin(self):
		self.element_tr_begin()
#		super(ELEMENT, self).tr_begin()
		# self._y[0].x  = 0.; // not yet
		self._y_(0).x = 0.;
		self._y_(0).f1 = 2.111; # value.
		self._y1.f0 = self._y_(0).f0 = 0.	#BUG// override
		self._loss1 = self._loss0 = 1./ 10e-6 # OPT::shortckt
		self._m0.x  = 0.
		self._m0.c0 = -self._loss0 * self._y_(0).f1;
		self._m0.c1 = 0.
		self._m1 = self._m0
	def do_tr(self):
		print("do_tr, should not be reached, usually")
	def tr_load(self):
		self.tr_load_shunt()
		self.tr_load_source()
	def tr_unload(self):
		self.tr_unload_source()

	def tr_probe_num(self, s):
		if s=="fourtytwo":
			return 42;
		elif s=="v":
			return self.tr_involts()
		elif s=="nodeprobe":
			return self._n[0].v0()
		return 0;

	def port_number(self):
		return 2
	def port_name(self,x):
		return ["P","N"][x]
	def value_name(self):
		return "incomplete"

s = myvs()

# s._y[0] not yet. how to do that?
s._y_(0)


print("mtest", s.max_nodes(), s.long_label())
s2 = s.clone()
print("mtest", s2.max_nodes(), s2.long_label())
# s.clone()

print("TT", type(s))
a = install_device("myvs", s)
# b = gnucap.command_installer("myvs", s)

gnucap.command("set lang=verilog")
gnucap.parse("resistor #(.r(1)) r(1 0)")
# gnucap.parse("vsource #(.dc(1)) s(1 0)")
gnucap.parse("myvs #() s(1 0)")
gnucap.command("list")
gnucap.command("print dc fourtytwo(s) i(r) v(s) nodeprobe(s) v(nodes)")
gnucap.command("dc r 1 3 .5")

print("done")
