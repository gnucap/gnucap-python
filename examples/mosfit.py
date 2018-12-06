# ASCO replacement
# (C) 2018 Felix Salfelder
# GPLv3+

# use gnucap to fit one mosfet against another in a dc sweep

# this is part of gnucap-python

import sys
import numpy as np
import gnucap
from gnucap import command
import nlopt

# optimize these
# some don't make sense, just a proof-of-concept here.
varnames = ["VTH0", "RSH", "NFACTOR", "K1", "DVT0", "DVT1"]

startvalues = [1., 10., 1, 1, 1., .5]
bounds_lo = [0.5, 1., 0.1, 0.1, 1., 0.1]
bounds_hi = [3, 10., 5., 10., 10., 1]

def setup_circuit():
	command("get mosfit.sp")
	command("store dc v(cmp)")
	command("options reltol=.0001")
	command("options abstol=1e-14")

# evaluate circuit
def eval(*args):
	for i,a in enumerate(args):
		if np.isnan(a):
			raise ValueError()
		command("param "+varnames[i]+"="+str(a))

	command("dc VIN -1 4 .1>/dev/null")
	command('measure DELTA rms(probe="V(CMP)")>/dev/null')

	delta = gnucap.eval("DELTA")

	return delta, 0

# all callbacks require the results. only evaluate once per point.
# this is strictly not necessary here. see inv.py.
hackresult = []
hackx = 0
def eval_cache(*args):
	global hackresult
	global hackx

	if(args!=hackx):
		hackx = args
		hackresult = eval(*args)

	return hackresult

setup_circuit()

n = len(varnames)

# fails miserably
# algo=nlopt.LN_NELDERMEAD

algo=nlopt.LN_COBYLA

opt = nlopt.opt(algo, n)

opt.set_lower_bounds(bounds_lo)
opt.set_upper_bounds(bounds_hi)

def objective(x, grad):
	assert(grad.size==0)
	e = eval_cache(*x)
	print("obj", e[0])
	return e[0]
opt.set_min_objective(objective)

# tolerances. this does not really matter here (too simple)
opt.set_xtol_abs([1e-15]*n);
opt.set_xtol_rel(1e-8);

# do it
xopt = opt.optimize(startvalues)

print("optimum:")
for k,p in enumerate(varnames):
	print(p, xopt[k])

# sometimes crashes during shutdown.
print("done")
