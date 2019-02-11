# Copyright (C) 2018 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

from __future__ import print_function

import gnucap

from gnucap import COMPONENT
from gnucap import install_device
from copy import deepcopy, copy
from sys import stdout

try:
	c = COMPONENT()
	print("ERROR, component must be pure")
	assert(False)
except RuntimeError:
	pass
except AttributeError:
	pass

class MyAC(gnucap.SIM):
	def do_it(self, cmd, scope):
		print("HELLOWORLD")
		stdout.flush()

ac = MyAC()
c1 = gnucap.install_command("myac", ac)
stdout.flush()

# test: "already installed"
c2 = gnucap.install_command("myac", ac)
stdout.flush()

print("running ac")
stdout.flush()
gnucap.command("ac 1 2 * 2")
stdout.flush()

print("running myac")
stdout.flush()
gnucap.command("myac 1 2 * 2")

try:
	c = gnucap.CARD()
	assert(False)
except RuntimeError:
	pass
except AttributeError:
	pass

# trick python garbage collector
# todo: hide in wrapper layer

class somecomponent(COMPONENT):
	def __init__(self, other=None):
		if other is None:
			print("construct somecomponent", self)
			COMPONENT.__init__(self) # this is required. (or do not implement __init__)
		else:
			print("copyconstruct somecomponent")
			COMPONENT.__init__(self, other) # this is required. (or do not implement __init__)
		print("init", self.long_label())
		self.HACK=[]

#	def __reduce__(self):
#		print("reducing")
#		return(self.__class__, ( ) )

	def clone(self):
		x = somecomponent(self)
		self.HACK.append(x)
		return x

	def value(self):
		return "a";

	def dev_type(self):
		return "pythoncomptest"

	def min_nodes(self):
		return 2;
	def net_nodes(self):
		return 2;
	def max_nodes(self):
		return 2;
	def net_nodes(self):
		return 2;

	def tr_probe_num(self, s):
		if s=="fourtytwo":
			return 42;
		if s=="v":
			return -1; # incomplete
		return 0;


	def port_number(self):
		return 2
	def port_name(self,x):
		return ["P","N"][x]
	def value_name(self):
		return "incomplete"

s = somecomponent()
print("mtest", s.max_nodes(), s.long_label())
s2 = s.clone()
print("mtest", s2.max_nodes(), s2.long_label())
# s.clone()

print("TT", type(s))
a = install_device("somecomp", s)
# b = gnucap.command_installer("somecomp2", s)

gnucap.command("set lang=verilog")
gnucap.parse("vsource #(.dc(1)) v(1 0)")
gnucap.parse("somecomp #() s(1 0)")
gnucap.command("list")
gnucap.command("print dc fourtytwo(s) v(s)")
gnucap.command("dc v 0 1 .5")

print("done")
