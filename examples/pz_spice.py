# Copyright (C) 2018 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>
# License: GPLv3+

# load into gnucap with loadpy $thisfile
# poles and zeroes spice style command

from sys import stdout
import sys
import numpy as np
from copy import deepcopy, copy
from scipy.sparse import coo_matrix
from scipy.linalg import eig

from gnucap import out, IO_mstdout_get
from gnucap import install_command
from gnucap import SIM, CARD_LIST, outset, outreset
from gnucap import iTOTAL
from gnucap import ELEMENT
from gnucap import node_t
from gnucap import XPROBE
from gnucap import install_device
from gnucap import OMSTREAM__print
from gnucap import OPT_numdgt
from gnucap import fixzero

sigma = 0

###################################################
class spice_pz(SIM):
	def do_it(self, cmd, scope):
		self._scope = scope
		self.sim_().set_command_ac()
		self.setup(cmd)
		self.sim_().init()
		cl = CARD_LIST().card_list_()
		cl.precalc_last()
		self.sim_().alloc_vectors()

		nodes = cl.nodes();

		self.inn = [nodes[self._in0].matrix_number(), nodes[self._in1].matrix_number()]
		self.out = [nodes[self._out0].matrix_number(), nodes[self._out1].matrix_number()]
		assert(self.inn[0] != self.inn[1] ) # for now
		assert(self.out[0] != self.out[1] ) # for now

		acx = self.sim_()._acx
		acx.reallocate()

		self._scope = scope
		self.sweep()
		acx.unallocate();
		self.sim_().unalloc_vectors()

	def setup(self, cmd):
		self._in0=cmd.ctos()
		self._in1=cmd.ctos()
		self._out0=cmd.ctos()
		self._out1=cmd.ctos()

		self._out = self.out_assign(IO_mstdout_get());
		sys.stdout.flush()
		outreset();
		outset(cmd, self._out)

	def sort_and_output(self, E0):
		n = OPT_numdgt()
		self._out.setfloatwidth(n, n)

		Q = []
		for i in E0.transpose():
			if(i[1]):
				q=i[0]/i[1]
				im=np.imag(q)
				im=fixzero(im, 1e8)
				re=np.real(q)
				if(abs(re)>1e8):
					continue
				re=fixzero(re, 1e8)
				Q.append(re+1j*im)

		Q = np.array(Q)
		Q = np.sort_complex(1j*Q)/1j
		# Q = np.sort_complex(Q)
		for i in Q:
			# print(' {:.6e}'.format(i))

			# use outdata...
			OMSTREAM__print(self._out, np.real(i))
			if(np.imag(i)<0):
				OMSTREAM__print(self._out, "- j*")
			else:
				OMSTREAM__print(self._out, "+ j*")
			OMSTREAM__print(self._out, abs(np.imag(i)))
			OMSTREAM__print(self._out, "\n")

	def sweep(self):
		self.sim_()._jomega = -1j
		cl = CARD_LIST().card_list_()
		cl.ac_begin()
		n = self.sim_()._total_nodes
		freqstart = 0.
		freqstop = 1.
		s = self.sim_()

		self.mysolve()

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

		raw = acx._space(False)
		coo = acx._coord(False).transpose()
		i,j = coo

		f = coo_matrix((raw, (i,j)))
		M=f.todense()
		R = np.real(M)
		I = np.imag(M)
		R = R.astype(np.complex128)
		I = I.astype(np.complex128)
		E = eig(R, I, homogeneous_eigvals=True)

		OMSTREAM__print(self._out, "poles\n")
		E0 = E[0]
		self.sort_and_output(E0)

		ir = [ self.inn[0]-1, self.inn[1]-1 ]
		jr = [ self.out[0]-1, self.out[1]-1 ]

		ir.sort()
		jr.sort()

		def set_io(i, ir, raw):
			for idx in range(len(raw)):
				if(i[idx] < ir[0]):
					pass
				elif(i[idx] == ir[0]):
					# there are two
					# this is the smaller one
					# subtract from the other...
					i[idx] = ir[1] - 1
					raw[idx] *= -1
				elif ir[0] == -1 and ir[1] == i[idx]:
					raw[idx] = 0.
					i[idx] = 0
				elif ir[0] == -1 and i[idx] >= ir[1]:
					i[idx] -= 1
				elif ir[0] != -1 and i[idx] > ir[0]:
					i[idx] -= 1
				assert(i[idx]>=0)

		set_io(j, ir, raw)
		set_io(i, jr, raw)

		f = coo_matrix((raw, (i,j)))
		M = f.todense()
		R = np.real(M)
		I = np.imag(M)
		OMSTREAM__print(self._out, "zeroes\n")

		E = eig(R, I, homogeneous_eigvals=True)
		E0 = E[0]

		self.sort_and_output(E0)

		sys.stdout.flush()



sim = spice_pz()
d1 = install_command("pz", sim)
