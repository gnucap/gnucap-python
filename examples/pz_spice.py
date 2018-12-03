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

sigma = 0

###################################################
class spice_pz(SIM):
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
		in0=cmd.ctos()
		in1=cmd.ctos()
		out0=cmd.ctos()
		out1=cmd.ctos()

		nodes = cl.nodes();

		self.inn = [nodes[in0].matrix_number(), nodes[in1].matrix_number()]
		self.out = [nodes[out0].matrix_number(), nodes[out1].matrix_number()]

		assert(self.inn[0] != self.inn[1] ) # for now
		assert(self.out[0] != self.out[1] ) # for now

		self._out = self.out_assign(IO_mstdout_get());
		sys.stdout.flush()
		outreset();
		outset(cmd, self._out)

	def sort_and_output(self, E0):
		Q = []
		for i in E0.transpose():
			if(i[1]):
				Q.append(i[0]/i[1])

		Q = np.sort_complex(Q)
		for i in Q:
			print(' {:.6e}'.format(i))

	def sweep(self):
		cl = CARD_LIST().card_list_()
		n = self.sim_()._total_nodes
		freqstart = 0.
		freqstop = 1.
		s = self.sim_()

		cl.ac_begin()
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
		self.sim_()._jomega = -1j
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

		print()
		print("poles")
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
		print()
		print("zeroes")

		E = eig(R, I, homogeneous_eigvals=True)
		E0 = E[0]

		self.sort_and_output(E0)

		sys.stdout.flush()



sim = spice_pz()
d1 = install_command("pz", sim)
