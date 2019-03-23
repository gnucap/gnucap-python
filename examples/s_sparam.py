#                            -*- C++ -*-
# Copyright (C) 2018 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
#------------------------------------------------------------------
# s-param analysis

from sys import stdout
from math import sqrt
import sys
import numpy as np
from scipy.sparse import coo_matrix
from scipy.linalg import eig
from dataclasses import dataclass
from enum import Enum, IntEnum

from gnucap import out, IO_mstdout_get
from gnucap import rPRE_MAIN, rBATCH, rINTERACTIVE, rSCRIPT, rPRESET
from gnucap import install_command
from gnucap import PARAMETERd, PARAMETERi, PARAMETERb
from gnucap import SIM, CARD_LIST, outset, outreset
from gnucap import findbranch
from gnucap import iTOTAL
from gnucap import ELEMENT, CKT_BASE
from gnucap import node_t
from gnucap import XPROBE
from gnucap import install_device
from gnucap import OMSTREAM__print
from gnucap import OPT_numdgt, OPT_pivtol
from gnucap import fixzero
from gnucap.pending import install
from gnucap import ENV
from gnucap import CS
from gnucap import SIM
from gnucap import in_order
from gnucap import Get_, Set_
from math import pi

# from gnucap.u_parameter import float_

def incomplete():
	print("incomplete")

sigma = 0
bWARNING = 5

#*--------------------------------------------------------------------------*#
@install("pac|sparam_port")
class PAC(ELEMENT):
	def value_name(self):
		return "impedance"
	def max_nodes(self):
		return 2
	def min_nodes(self):
		return 2
	def matrix_nodes(self):
		return 2
	def net_nodes(self):
		return 2
	def tr_iwant_matrix(self):
		pass
	def ac_iwant_matrix(self):
		pass
	def precalc_last(self):
		ELEMENT.precalc_last(self)
		self.set_constant(True)
		# self.set_converged() ##??
		if(self.value()<=0):
			print(long_label, ": setting default impedance, 50Ohm")
			# error(bPICKY, long_label()+": setting default impedance, 50Ohm\n")
			self.set_value(50)

	def tr_involts(self):
		return dn_diff(self._n[IN1].v0(), self._n[IN2].v0())
	def tr_involts_limited(self):
		return self.tr_involts()
	def tr_probe_num(self, s):
		if (Umatch(x, "gain ")):
			return self.tr_outvolts() / self.tr_involts()
		else:
			return ELEMENT.tr_probe_num(self.x);

	def port_name(self, i):
		assert(i < 2)
		names = ["p", "n"]
		return names[i]

	def ac_involts(self):
		return - self.ac_outvolts()
	
	def stamp_rhs(self):
		self._acg = 1
		self.ac_load_source()

	def impedance(self):
		return self.value()

#*--------------------------------------------------------------------------*#
#*--------------------------------------------------------------------------*#

@install("sp|sparam")
class SPARAM(SIM):

	@dataclass
	class output_t:
		label: str
		brh0 : CKT_BASE
		brh1 : CKT_BASE

	class stepmode_t(IntEnum):
		ONE_PT = 0
		LIN_STEP = 1
		LIN_PTS = 2
		TIMES = 3
		OCTAVE = 4
		DECADE = 5

	def set_stepmode(self,x):
		self._stepmode = x
		return True
		
	class paramtype_t(IntEnum):
		tZ = 0
		tY = 1
		tS = 2

	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		# self._stepmode = self.stepmode_t()
		self._start = PARAMETERd()	# sweep start frequency
		self._stop = PARAMETERd() # sweep stop frequency
		self._step_in = PARAMETERd() # step size, as input
		#double _step;			// printed step size
		self._linswp = False # flag: use linear sweep (vs log sweep)
		#bool	_prevopppoint;  	// flag: use previous op point
		#bool _dump_matrix; // dump matrix after ac
		# gsl_matrix_complex *_Z;
		self._type = self.paramtype_t.tS

	def do_it(self, x : CS, l : CARD_LIST):
		_SP_do_it(self, x, l)
	def sweep(self):
		return _SP_sweep(self)
	def first(self):
		return _SP_first(self)
	def next_freq(self):
		return _SP_next_freq(self)
	def solve(self):
		return _SP_solve(self)
	def clear(self):
		return _SP_clear(self)
	def setup(self, cmd : CS):
		return _SP_setup(self, cmd)
	def outmatrix(self, M):
		return _SP_outmatrix(self, M)

# private:
	# OMSTREAM _out; // tmp hack
#*--------------------------------------------------------------------------*#
#*--------------------------------------------------------------------------*#
def _SP_do_it(self, Cmd : CS, Scope : CARD_LIST) -> None:
	self._scope = Scope;
	self._sim.set_command_ac()
	# self.reset_timers();
	#::status.ac.reset().start();

	self._sim.init();
	self._sim.alloc_vectors();
	self._sim._acx.reallocate();
	self._sim._acx.set_min_pivot(OPT_pivtol());

	self.setup(Cmd);
	# ::status.set_up.stop();
	if (ENV.run_mode==rPRE_MAIN):
		unreachable()
	elif(ENV.run_mode==rBATCH
	  or ENV.run_mode==rINTERACTIVE
	  or ENV.run_mode==rSCRIPT):
		self.sweep()
	elif ENV.run_mode==rPRESET:
		pass
	else:
		# BUG
		self.sweep()

	self._sim._acx.unallocate()
	self._sim.unalloc_vectors()

	#::status.ac.stop();
	#::status.total.stop();

#*--------------------------------------------------------------------------*#
#*--------------------------------------------------------------------------*#
def _SP_setup(self, Cmd):
	self._out = self.out_assign(IO_mstdout_get());
	self._out.reset(); ##BUG// don't know why this is needed
	self._ports = []
	self._type = 0

	here = Cmd.cursor();

	while True:
		if (Cmd.match1("'\"({") or Cmd.is_float()):
			a = [self._start]
			Cmd.__rshift__(a);
			self._start = a[0]
			if (Cmd.match1("'\"({") or Cmd.is_float()):
				a = [self._stop]
				Cmd.__rshift__(a)
				self._stop = a[0]
			else:
				self._stop = self._start;
			if (Cmd.match1("'\"({") or Cmd.is_float()):
				self._stepmode = LIN_STEP;
				a = [self._step_in]
				Cmd.__rshift__(a)
				self._step_in = a[0]
		else:
			pass

		assert(not isinstance(self._start, int))

		port = ""
		if (Cmd.umatch("port")):
			arg1 = Cmd.cursor();
			cii = findbranch(Cmd, CARD_LIST.card_list_(None));
			try:
				ci = next(cii)
			except StopIteration:
				Cmd.reset(arg1);
				raise Exception_CS("cannot find port", Cmd)

			next_ = Cmd.cursor();
			while(True):
				if(isinstance(ci, PAC)):
					self._ports.append(ci)
				else:
					print("bDANGER", ci.long_label() + " is not a port, skipping\n");
				
				Cmd.reset(arg1);
				cii.increment_()
				cii = findbranch(Cmd, cii)
				try:
					ci = next(cii)
				except StopIteration:
					break
			Cmd.reset(next_);
			
		else:
			pass # not port

		stm = self.set_stepmode

		sip = [self._step_in]
		stp = [self._start]
		endp = [self._stop]
		tp = [self._type]

		0 \
		or (Get_(Cmd, "*",        sip) and stm(self.stepmode_t.TIMES)) \
		or (Get_(Cmd, "+",        sip) and stm(self.stepmode_t.LIN_STEP)) \
		or (Get_(Cmd, "by",       sip) and stm(self.stepmode_t.LIN_STEP)) \
		or (Get_(Cmd, "step",     sip) and stm(self.stepmode_t.LIN_STEP)) \
		or (Get_(Cmd, "d{ecade}", sip) and stm(self.stepmode_t.DECADE)) \
		or (Get_(Cmd, "ti{mes}",  sip) and stm(self.stepmode_t.TIMES)) \
		or (Get_(Cmd, "lin",      sip) and stm(self.stepmode_t.LIN_PTS)) \
		or (Get_(Cmd, "o{ctave}", sip) and stm(self.stepmode_t.OCTAVE)) \
		or Get_(Cmd, "sta{rt}",   stp) \
		or Get_(Cmd, "sto{p}",    endp) \
		or (Cmd.umatch("paramtype {=}") and \
		    (   Set_(Cmd, "z", tp, int(self.paramtype_t.tZ)) \
		     or Set_(Cmd, "y", tp, int(self.paramtype_t.tY)) \
		     or Set_(Cmd, "s", tp, int(self.paramtype_t.tS)) \
		     or Cmd.warn(bWARNING, "need z, y, s") \
		    ) \
		   ) \
		or outset(Cmd, self._out)

		self._step_in = sip[0]
		self._start = stp[0]
		self._stop = endp[0]
		self._type = self.paramtype_t(tp[0])

		ph=[here]
		if not Cmd.more() and not Cmd.stuck_(ph):
			here=ph[0]
			break
		here=ph[0]

	# while loop end?

	Cmd.check(bWARNING, "what's this??");

	size = len(self._ports);
	self._Z = np.zeros((size,size), dtype=complex)

	self._start.e_val(0., self._scope);
	self._stop.e_val(0.,self._scope);
	self._step_in.e_val(0., self._scope);

	self._step = self._step_in;

	if (self._step==0.):
		self._step = self._stop - self._start
		self._linswp = True;

#  incomplete();
#  initio(_out);


#*--------------------------------------------------------------------------*#
def _SP_solve(self):
	self._sim._acx.zero();
	n = self._sim._total_nodes
	ac = self._sim._ac
	for i in range(n+1):
		ac[i] = 0;

	# ::status.load.start();
	self._sim.count_iterations(iTOTAL)
	CARD_LIST.card_list_(None).do_ac()
	CARD_LIST.card_list_(None).ac_load()
  # ::status.load.stop();

  #if (_dump_matrix){
  #  _out.setfloatwidth(0,0);
  #  _out << _sim->_acx << "\n" ;
  #}
  #::status.lud.start();
	self._sim._acx.lu_decomp()
  #::status.lud.stop();

	return

#*--------------------------------------------------------------------------*#
def _SP_outmatrix(self, m):
	n = OPT_numdgt()
	self._out.setfloatwidth(n, n)
	for i in range(m.shape[0]):
		for j in range (m.shape[1]):
			x = m[i, j]
			self._out << x
		self._out <<"\n";

#*--------------------------------------------------------------------------*#
def mul_rows(m, s):
	for i in range(m.shape[0]):
		for j in range (m.shape[1]):
			m[i, j] *= s[i]
#*--------------------------------------------------------------------------*#
def mul_cols(m, s):
	for i in range(m.shape[0]):
		for j in range (m.shape[1]):
			m[i, j] *= s[j]
#*--------------------------------------------------------------------------*#
def add_dia(m, s):
	for i in range(m.shape[0]):
		m[i, i] += s
#*--------------------------------------------------------------------------*#
def _SP_sweep(self):
	width = 4 # std::min(OPT::numdgt+5, BIGBUFLEN-10);

	#char format[20];
	#//sprintf(format, "%%c%%-%u.%us", width, width);
	#sprintf(format, "%%c%%-%us", width);
	#_out.form(format, '*', "param");

	#sprintf(format, "%%-%us", width);

	self.head(self._start.float_(), self._stop.float_(), "@freq")
	self.first()
	CARD_LIST.card_list_(None).ac_begin()

	while True:
		self._out << "." << self._sim._freq << "\n";
		self._sim._jomega = 1.j * self._sim._freq * 2.*pi
		self.solve();
		i = 0;
		n = self._sim._total_nodes
		ac = self._sim._ac
		for i, inp in enumerate(self._ports):
			for k in range(n+1):
				ac[k] = 0;
			inp.stamp_rhs()
			
			#::status.back.start();
			self._sim._acx.fbsub_(ac)
			#::status.back.stop();
			
			for j, out in enumerate(self._ports):
				v = out.ac_involts();
				self._Z[i, j] = v
				n = OPT_numdgt()
				self._out.setfloatwidth(n, n)
				if(self._type==self.paramtype_t.tZ):
					self._out << v
			if(self._type==self.paramtype_t.tZ):
				self._out << "\n"

		if(self._type==self.paramtype_t.tY):
			self._out << "Y incomplete\n" # see .cc
		elif(self._type==self.paramtype_t.tZ):
			pass # above
		elif(self._type==self.paramtype_t.tS):
			size = len(self._ports)
			sy0 = np.zeros(size)
			i = 0
			for p in self._ports:
				yy = 1./p.impedance().float_()
				assert(yy>0)
				sy0[i] = sqrt(yy)
				i += 1

			mul_rows(self._Z, sy0);
			mul_cols(self._Z, sy0);

			# // sY = sqrt(Y_0)
			# // S = ( sY Z sY - 1 ) * ( sY Z sY + 1 )^-1
			# //   = ( sY Z sY + 1 )^-1 * ( sY Z sY - 1 )
			# //   = A^-1 * B
			# //
			A = self._Z.copy();
			B = self._Z.copy();
			add_dia(A, 1.);
			add_dia(B, -1.);
			
			A = np.linalg.inv(A)

			S = A.dot(B)

			self.outmatrix(S.transpose());

		else:
			unreachable()

		if not self.next_freq():
			break

#*--------------------------------------------------------------------------*#
def _SP_first(self):
	self._sim._freq = self._start.float_()
#*--------------------------------------------------------------------------*#
def _SP_next_freq(self):
	if self._linswp:
		realstop = self._stop - self._step*.01
	else:
		realstop = self._stop / pow(self._step.float_(),.01)

	if (not in_order(self._start.float_(), self._sim._freq, realstop)):
		return False;

	if self._linswp:
		self._sim._freq += self._step.float_()
	else:
		self._sim._freq = self._step * self._sim._freq

	if (in_order(self._sim._freq, self._start.float_(), self._stop.float_())):
		return False;
	else:
		return True;
#*--------------------------------------------------------------------------*#
