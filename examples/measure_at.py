
from gnucap import FUNCTION
from gnucap import CKT_BASE_find_wave as find_wave
# from gnucap.pending import install
from gnucap import install_measure
from gnucap.io_trace import *
from gnucap import Get_, PARAMETERd

# from gnucap import BIGBIG
BIGBIG = 1.e101

# reconstruct polynomial and evaluate.
class At:
	def __init__(self, wave):
		self._wave = wave

	def __call__(self, x, derivative=False, order=2):
		if derivative:
			incomplete()
			return 0

		x2 = x1 = x0 = -1e99
		y2 = y1 = y0 = 0.
		for i in self._wave:
			x2, x1, x0 = x1, x0, i[0]
			y2, y1, y0 = y1, y0, i[1]
			if float(i[0]) > x:
				break;

		dx = x - x1
		t0 = x0 - x1
		d = (y0 - y2) / (x0 - x2)
		v0 = y0 - y1
		b = ( v0/t0 - d ) / t0
		return (d + b * dx) * dx + y1

## @install("at")
class MeasureAt(FUNCTION):
	def eval(self, Cmd, Scope):
		derivative = False
		
		here = Cmd.cursor()
		probe_name = Cmd.ctos()

		w = None
		try:
			w = find_wave(probe_name)
			return "99"
		except KeyError:
			Cmd.reset(here)

		if w is None:
			# BUG
			Cmd.reset(here)

		here = Cmd.cursor();
		probe_name_p = [""]
		x_p = ["0."]
		derivative_p = [False]

		while 1:
			Get_(Cmd, "probe", probe_name_p)

			0 \
			or Get_(Cmd, "probe", probe_name_p) \
			or Get_(Cmd, "x", x_p) \
			or Get_(Cmd, "at", x_p) \
			or Get_(Cmd, "deriv{ative}", derivative_p)

			if Cmd.more() and not Cmd.stuck(here):
				pass
			else:
				break

		probe_name = probe_name_p[0]

		# TODO. wrap into constructor taking string?
		x = PARAMETERd()
		x.assign(x_p[0])

		derivative = derivative_p[0]

		if w is None:
			try:
				w = find_wave(probe_name);
			except KeyError:
				pass
		else:
			pass

		if w is not None:
			at = At(w)
			x.e_val(BIGBIG, Scope);
			r = at(x, derivative=derivative)
			return str(r)
		else:
			raise Exception_No_Match(probe_name);

s = MeasureAt()
a = install_measure("at", s)
