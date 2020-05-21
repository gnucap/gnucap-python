# Copyright (C) 2018 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>
# License: GPLv3+

# load into gnucap with loadpy $thisfile

from sys import stdout
import sys
import numpy as np
from copy import deepcopy, copy

from gnucap import out, IO_mstdout_get
from gnucap import install_command
from gnucap import SIM, CARD_LIST, outset, outreset
from gnucap import iTOTAL
from gnucap import ELEMENT
from gnucap import node_t
from gnucap import XPROBE
from gnucap import install_device
from gnucap import OMSTREAM__print

sigma = 0

def eprint(*args, **kwargs):
           print(*args, file=sys.stderr, **kwargs)

class pzsrc(ELEMENT):
	def __init__(self, other=None):
		if other is None:
			ELEMENT.__init__(self)
		else:
			ELEMENT.__init__(self, other)
		self.HACK=[]

	def clone(self):
		print("somelt clone")
		x = pzsrc(self)
		self.HACK.append(x)
		x.__class__ = pzsrc
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
		self._y[0].x = 0.;
		self._y[0].f1 = 2.111; # value.
		self._y1.f0 = self._y[0].f0 = 0.	#BUG// override
		self._loss1 = self._loss0 = 1./ 10e-6 # OPT::shortckt
		self._m0.x  = 0.
		self._m0.c0 = -self._loss0 * self._y[0].f1;
		self._m0.c1 = 0.
		self._m1 = self._m0
	def do_tr(self):
		print("do_tr, should not be reached, usually")
	def tr_load(self):
		self.tr_load_shunt()
		self.tr_load_source()
	def tr_unload(self):
		self.tr_unload_source()

#	def ac_begin(self):
#		pass
	def do_ac(self):
		self._acg = self.sim_()._jomega # + sigma
	def ac_load(self):
		self.ac_load_shunt()
		self.ac_load_source()

	def ac_probe_ext(self, s):
		if s=="sigma":
			return XPROBE(sigma);
		elif s=="omega":
			return XPROBE(self.sim_()._jomega.imag);

	def tr_probe_num(self, s):
		if s=="sigma":
			return sigma;
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

s = pzsrc()
a = install_device("pzsrc", s)

###################################################
class mysim(SIM):
	def do_it(self, cmd, scope):
		self._scope = scope
		self.sim_().set_command_ac()
		self.setup(cmd)
		self.sim_().init()
		self.sim_().alloc_vectors()

		acx = self.sim_()._acx
		acx.reallocate()

		self._scope = scope
		self.sweep()
		acx.unallocate();
		self.sim_().unalloc_vectors()

	def setup(self, cmd):
		cl = CARD_LIST().card_list_()
		print("tst")
		eprint("=============")
		print("tst")
		for i in cl:
			print (i)
		print("tst")
		self._out = self.out_assign(IO_mstdout_get());
		outreset();
		outset(cmd, self._out)

	def sweep(self):
		cl = CARD_LIST().card_list_()
		n = self.sim_()._total_nodes
		freqstart = 0.
		freqstop = 1.
		s = self.sim_()

		cl.ac_begin()

		self.head(freqstart, freqstop, "Freq")
		acx = self.sim_()._acx

		for freq in range(-40,41):
			for mysigma in np.arange(-40,41) / 10.:
				self.sim_()._jomega = 2j * np.pi * freq / 100 + mysigma
				global sigma
				sigma=mysigma

				self.mysolve()
				self.outdata(sigma, 1)
			OMSTREAM__print(self._out, "\n")

	def mysolve(self):
		n = self.sim_()._total_nodes
		s = self.sim_()
		acx = s._acx
		acx.zero()
		ac = s._ac
		for i in range(n+1):
		  	ac[i] = 0;

		s.count_iterations(iTOTAL);

		cl = CARD_LIST().card_list_()
		cl.do_ac()
		cl.ac_load()

		if(0):
			print("M", self.sim_()._acx[0][0], self.sim_()._acx[0][1], self.sim_()._acx[0][2])
			print("M", self.sim_()._acx[1][0], self.sim_()._acx[1][1], self.sim_()._acx[1][2])
			print("M", self.sim_()._acx[2][0], self.sim_()._acx[2][1], self.sim_()._acx[2][2])

		acx.lu_decomp()
		acx.fbsub_(self.sim_()._ac)


sim = mysim()
d1 = install_command("mysim", sim)
