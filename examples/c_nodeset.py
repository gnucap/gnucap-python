# Felix Salfelder 2019
# GPLv3+

import gnucap
from gnucap.pending import install
from gnucap import node_array, TIME_PAIR, FPOLY1
from gnucap.io_trace import *
from gnucap import findbranch, CMD, CARD_LIST, CS
from gnucap import ground_node, node_t, NODE
import sys

HACK=[]

class COMMON_NODESETTER(gnucap.COMMON_COMPONENT):
	def __init__(self, other=None):
		if other is None:
			super().__init__()
		else:
			super().__init__(other)

	# TODO: default clone for COMMON_COMPONENT
	def clone(self):
		tmp = COMMON_NODESETTER(self)
		HACK.append(tmp)
		return tmp

	def modelname(self):
		return "nodesetter"

	def has_tr_eval(self):
		return True

	def tr_eval(self, elt):
		ic = elt.value().float_()
		ret = True
		_sim = elt.sim_()
		if _sim.analysis_is_tran_dynamic():
			# zero currents
			elt._loss0 = 0
		elif _sim.analysis_is_restore():
			pass
		elif _sim.analysis_is_static():
			if _sim.uic_now():
				untested()
				elt._y[0] = FPOLY1(0, 1, ic);
				elt.q_load()
				ret = False
			else:
				untested()
				elt._y[0] = FPOLY1(0, 1, ic)
				elt.q_load()
		else:
			untested()

		return ret

nsc = COMMON_NODESETTER(27342)
nsc.set_modelname("nodesetter_m")

@install("nodesetter")
class NODESETTER(gnucap.BASE_SUBCKT):
	def __init__(self, other=None):
		if other is None:
			untested()
			super().__init__()
		else:
			untested()
			super().__init__(other)
		self.attach_common(nsc)
		nodes = node_array(20)
		self._n = nodes
		self._param = {}
			
	def param_count(self):
		return 0

	def clone(self):
		n = NODESETTER(self)
		HACK.append(n)
		return n

	def precalc_first(self):
		incomplete()

	def expand(self):
		super().expand()
		self.new_subckt()
		sc = self.subckt()

		ng = node_t()
		ng.set_to_ground(self)

#		n = self.net_nodes() ??
		for i in range(20):
			VS = gnucap.device_dispatcher.clone("V")

			trace("expand", i)
			if not self.port_exists(i):
				break

			nodes = [ ng, self._n[i] ]

			try:
				sc.push_back(VS)
			except e:
				print(e)

			VS.set_constant(False)

			ic = 1.
			try:
				untested()
				icp = self._param["ic"+str(i)]
				untested()
				ic = float(icp)
				untested()
			except IndexError:
				untested()
			except e:
				untested()
				throw

			VS.set_parameters("vs"+str(i), self, nsc, ic, 0, None, nodes)

		sc.expand()
		assert(not self.is_constant())
		sc.set_slave()
		return

	def set_param_by_name(self, n, v):
		self._param[n] = v

	def min_nodes(self):
		return 0
	def max_nodes(self):
		# TODO: proper error message if this is too small!!
		return 2

	def tr_needs_eval(self):
		return True

	def tr_load(self):
		_sim = self.sim_()
		super().tr_load()

	def port_name(self, i):
		return "p"+str(i)

	def is_device(self):
		return True

	def tr_restore(self):
		self.q_eval()
		super().tr_restore()

	def tr_begin(self):
		super().tr_begin()
		self.q_eval() # HACK. possibly related to d_vs.cc + 87

	def do_tr(self):
		self.set_converged(self.subckt().do_tr())
		return self.converged()

	def tr_review(self):
		self.q_accept()
		return TIME_PAIR()

	def tr_accept(self):
		self.q_eval()
		super().tr_accept()

	def tr_advance(self):
		self.q_eval()

	def dc_advance(self):
		super().dc_advance()

a = None


# NS = NODESETTER()
# print("DEVTYPE", NS.dev_type())
# dd = gnucap.install_device("nodesetter", NS)

def get_nodesetter():
	Cmd = CS(gnucap._ap.CS__STRING, "nodesetter0")
	cii = findbranch(Cmd, CARD_LIST.card_list_(None));
	try:
		n = next(cii)
		return n
	except StopIteration:
		global a
		assert(a is None)
		a = NODESETTER()
		a.set_label("nodesetter0")
		CARD_LIST.card_list_(None).push_back(a.__disown__())
		b = get_nodesetter()
		assert(a is b)
		return b

@install("nodeset")
class NODESET(gnucap.CMD):
	def __init__(self):
		super().__init__() #?
		pass

	def do_it(self, args, scope):
		incomplete()

		get_nodesetter()
		# TODO: modify/delete nodesetter, also do ic command.
