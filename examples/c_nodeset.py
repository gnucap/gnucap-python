# Felix Salfelder 2019
# GPLv3+

import gnucap
from gnucap import IO_mstdout_get
from gnucap.pending import install
from gnucap import node_array, TIME_PAIR, FPOLY1
from gnucap.io_trace import *
from gnucap import findbranch, CMD, CARD_LIST, CS
from gnucap import ground_node, node_t, NODE
from gnucap import PARAM_LIST
import sys

_nodesetter_name = "nodesetter"
_nodesetter_model_name = "nodesetter"

COMMON_NODESETTER = gnucap.COMMON_PARAMLIST

class BM_NODESET(gnucap.COMMON_COMPONENT):
	def __init__(self, other=None):
		if other is None:
			untested()
			super().__init__()
		else:
			super().__init__(other)

	# TODO: default clone for COMMON_COMPONENT
	def clone(self):
		import inspect
		tmp = BM_NODESET(self)
		return tmp.__disown__()

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
nsc.set_modelname(_nodesetter_model_name)

bmns = BM_NODESET(27342)
bmns.set_modelname("bm_nodeset")

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

		sys.stdout.flush()
		nodes = node_array(20)
		self._n = nodes
		self._param = {}
		self._ic_values = {}
			
	def __param_count(self):
		return 0

	def clone(self):
		itested()
		n = NODESETTER(self)
		return n.__disown__()

	def params(self):
		## bug. _params produces a copy?!
		return self.common().params()

	def attach_params(self, p):
		untested()
		self.subckt().attach_params(p, self.scope());

	def value_raw(self, i):
		key = "v_"+self.port_value(i)
		ps = self.subckt().params()

		# why deep?
		return ps.deep_lookup(key)

	def precalc_last(self):
		super().precalc_last()

		for i in self.subckt():
			key = i.short_label()

			P = gnucap.PARAMETERd()
			P.assign(key)
			P.e_val(1e99, self.subckt())
			i.set_value(P.float_())

	def expand(self):
		super().expand()
		if not self.subckt():
			untested()
			self.new_subckt()
			sc = self.subckt()
		else:
			untested()
			pl = self.subckt().params()

		sc = self.subckt()
		sc.attach_params(self.common().params(), self.scope());

		ng = node_t()
		ng.set_to_ground(self)

		proto = gnucap.device_dispatcher["V"]

		n = 20 # cf. self.net_nodes()
		for i in range(n):
			VS = proto.clone()
			if not self.port_exists(i):
				untested()
				break

			key = "v_"+self.port_value(i)
			trace("expand", i, self.port_value(i))
			nodes = [ self._n[i], ng ]

			sc.push_back(VS)
			VS.set_constant(False)

			ic = 1e99
			VS.set_parameters(key, self, bmns, ic, 0, None, nodes)

		sc.expand()
		assert(not self.is_constant())
		sc.set_slave()

	def set_param_by_name(self, n, v):
		self._param[n] = v
		super().set_param_by_name(n, v)

	def min_nodes(self):
		return 0
	def max_nodes(self):
		# TODO: dynamic
		return 20

	#def tr_needs_eval(self):
	#	return True

	#def tr_load(self):
	#	_sim = self.sim_()
	#	super().tr_load()

	def port_name(self, i):
		return "p"+str(i)

	def is_device(self):
		return True

	def tr_begin(self):
		super().tr_begin()
		self.q_eval() # HACK. possibly related to d_vs.cc + 87

	#def do_tr(self):
	#	self.set_converged(self.subckt().do_tr())
	#	return self.converged()

	#def tr_review(self):
	#	self.q_accept()
	#	return TIME_PAIR()

	def tr_accept(self):
		self.q_eval()
		super().tr_accept()

	def tr_advance(self):
		# if time==0?
		self.q_eval()

def get_nodesetter():
	Cmd = CS(gnucap.CS__STRING, _nodesetter_name)
	cii = findbranch(Cmd, CARD_LIST.card_list_(None));
	try:
		n = next(cii)
		return n
	except StopIteration:
		a = NODESETTER()
		a.set_label(_nodesetter_name)

		# disown: transfer ownership.
		CARD_LIST.card_list_(None).push_back(a.__disown__())

		assert(a is get_nodesetter())
		return a

@install("nodeset")
class NODESET(gnucap.CMD):
	def __init__(self):
		super().__init__() #?
		self._out = IO_mstdout_get();

	def list(self):
		g = get_nodesetter()
		ii = 0
		self._out << "nodeset"
		while(True):
			if g.port_exists(ii):
				p = "v_"+g.port_value(ii)
				ic = g.value_raw(ii)
				self._out << " %s=%s"%( p,ic)
			else:
				break
			ii += 1
		self._out << "\n"

	def parse(self, args, scope):
		g = get_nodesetter()

		assert(g is not None)
		pl = g.params()


		if 0:
			g.parse(args)
		else:
			c = g.common().clone()
			c.params().parse(args)
			g.attach_common(c.__disown__())

		for k,i in enumerate(g.params()):
			a = i[0]

			if(a[:2]=="v_"):
				g.set_port_by_index_(k, a[2:])
			else:
				incomplete();

	def do_it(self, args, scope):
		# get_nodesetter()
		# TODO: modify/delete nodesetter, also do ic command.

		args.skip1("nodeset")
		if args.is_end():
			self.list()
		elif (args.umatch("clear")):
			untested()
			self.clear()
		else:
			untested()
			assert self is not None
			self.parse(args, scope)
			incomplete()
