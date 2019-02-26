# gnucap-python tests Makefile.am
# Author: 2019 Felix Salfelder
# license GPLv3+
#
check_PROGRAMS = test_python
test_python_SOURCES = test_python.cc

test_python_LDADD = ${DEPS_LIBS} @PYTHON_EXTRA_LIBS@ ${PYTHON_LIBS}
test_python_CPPFLAGS = ${GC_CPPFLAGS} @PYTHON_CPPFLAGS@ \
	-DPYTHON_SO=\"@ac_python_libdir@/@ac_python_soname@\" ${AM_CPPFLAGS}

GNUCAP_PLUGPATH := ${top_builddir}:@GC_PKGLIBDIR@:${GNUCAP_PLUGPATH:%=:%}
PYTHONPATH=..

AM_TESTS_ENVIRONMENT = \
    export REDIRECT='exec 2>&9'\
           PYTHON=${PYTHON} \
           PYTHON_VERSION=${PYTHON_VERSION} \
           PYTHONPATH=${PYTHONPATH} \
           MAKEFLAGS=--no-print-directory \
			  GNUCAP_PLUGPATH=$(top_builddir)/misc/.libs:${GNUCAP_PLUGPATH} \
           srcdir='$(srcdir)';
AM_TESTS_FD_REDIRECT = 9>&2
TEST_EXTENSIONS = .gc .py
PY_LOG_COMPILER = $(top_srcdir)/py_log_compiler
GC_LOG_COMPILER = $(top_srcdir)/gc_log_compiler

PY_TESTS = \
	ac.py \
	crash.py \
	comp.py \
	elmt.py \
	find_wave.py \
	instance.py \
	matrix.0.py \
	param.py \
	sim.py \
	store.py

GC_TESTS = \
	err.0.gc \
	err_simplugin.gc \
	use_simplugin.gc \
	pz.0.gc \
	pz.0g.gc

err.0.gc.out: $(PWD)/parse_err.py
pz.0.gc.out: | ${PWD}/pz_spice.py
pz.0g.gc.out: | ${PWD}/pz_spice.py

CLEANFILES = pz_spice.py out3.7 out3.6 out2.7

if PY2
crash.log: PY_LOG_FLAGS=SKIP
CRASH_OUT = crash.py.out
endif

XFAIL_TESTS =

CLEANFILES += ${CRASH_OUT} out3.7 c_python.so

use_simplugin.gc.out: $(PWD)/simplugin.py
err_simplugin.gc.out: $(PWD)/err_simplugin.py

if VPATH_BUILD
$(PWD)/%.py: %.py
	$(LN_S) $< $@
$(PWD)/%.py: ${top_builddir}/examples/%.py
	$(LN_S) $< $@
endif


TESTS = ${PY_TESTS} ${GC_TESTS}
SED_OUT = sed -e '/^default plugins/s/:.*//' \
	           -e '/^core-lib version/s/:.*//' \
	           -e '/^main version/s/:.*//'

${PY_TESTS:%.py=%.py.out}: %.py.out: %.py
	PYTHONPATH=${PYTHONPATH} \
	${PYTHON} < ${srcdir}/$*.py | ${SED_OUT} > $@; exit $${PIPESTATUS[0]}

TLP=.libs${LD_LIBRARY_PATH:%=:%}

${GC_TESTS:%.gc=%.gc.out}: %.gc.out: %.gc
	GNUCAP_PLUGPATH=${GNUCAP_PLUGPATH} \
	PYTHONPATH=${PYTHONPATH} \
	LD_LIBRARY_PATH=${TLP} \
	gnucap < ${srcdir}/$*.gc | ${SED_OUT} > $@

all-local:
	-${LN_S} ${srcdir}/out2 out2.7
	-${LN_S} ${srcdir}/out3 out3.6
	-${LN_S} ${srcdir}/out3 out3.7

EXTRA_DIST = \
	${TESTS:%=out3/%.out} \
	${TESTS:%=out2/%.out} \
	${TESTS} \
	parse_err.py \
	simplugin.py \
	err_simplugin.py

.PHONY: .P
.P:
	@:

$(GC_TESTS:%.gc=%.gc.out): .P
$(PY_TESTS:%.py=%.py.out): .P
$(GC_TESTS:%.gc=%.log): .P
$(PY_TESTS:%.py=%.log): .P

