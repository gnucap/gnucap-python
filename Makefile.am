# gnucap-python top level Makefile.am
# Author: 2018 Felix Salfelder
# license GPLV3
#
# (inspired by now obsolete files from Henrik Johansson)
#
check_PROGRAMS = test_python
test_python_SOURCES = test_python.cc

test_python_LDADD = ${DEPS_LIBS} @PYTHON_EXTRA_LIBS@ ${PYTHON_LIBS}
test_python_CPPFLAGS = ${GC_CPPFLAGS} @PYTHON_CPPFLAGS@ \
	-DPYTHON_SO=\"@ac_python_libdir@/@ac_python_soname@\" ${AM_CPPFLAGS}

ACLOCAL_AMFLAGS = -I m4
SUBDIRS = include gnucap examples

all-local:
	rm -f c_python.so
	-${LN_S} .libs/c_python.so c_python.so
	-${LN_S} out3.6 out3.7

# gnucap plugins
pluginsdir = $(libdir)/gnucap
plugins_LTLIBRARIES = c_python.la

c_python_la_SOURCES = c_python.cc # gnucap_wrap.cxx
c_python_la_CXXFLAGS = -Wall ${AM_CXXFLAGS} -fPIC ${DEPS_CFLAGS}

# BUG: it does not work without NUMPY either.
if NUMPY
  c_python_la_SOURCES += # numpy_interface.cc
  SWIG_FLAGS = -DHAS_NUMPY
endif

c_python_la_CPPFLAGS = ${GC_CPPFLAGS} @PYTHON_CPPFLAGS@ \
	-DPYTHON_SO=\"@ac_python_libdir@/@ac_python_soname@\" ${AM_CPPFLAGS}

c_python_la_LDFLAGS = -shared -module -avoid-version @LDFLAGS@ @PYTHON_LIBS@
c_python_la_LIBADD = ${DEPS_LIBS} @PYTHON_EXTRA_LIBS@
c_python_la_LIBADD += gnucap/libgnucap-python.la

# possibly required on non-posix systems
#c_python_la_LIBADD += @GC_LIBS@

####### TESTS #########
GNUCAP_PLUGPATH := ${builddir}:@GC_PKGLIBDIR@:${GNUCAP_PLUGPATH:%=:%}
PYTHONPATH=.

AM_TESTS_ENVIRONMENT = \
    export REDIRECT='exec 2>&9'\
           PYTHON=${PYTHON} \
           PYTHON_VERSION=${PYTHON_VERSION} \
           PYTHONPATH=. \
           MAKEFLAGS=--no-print-directory \
			  GNUCAP_PLUGPATH=${GNUCAP_PLUGPATH} \
           srcdir='$(srcdir)';
AM_TESTS_FD_REDIRECT = 9>&2
TEST_EXTENSIONS = .gc .py
PY_LOG_COMPILER = $(top_srcdir)/py_log_compiler
GC_LOG_COMPILER = $(top_srcdir)/gc_log_compiler

PY_TESTS = \
	crash.py \
	elmt.py \
	sim.py \
	ac.py \
	param.py \
	store.py \
	comp.py

GC_TESTS = \
	use_simplugin.gc

if PY2
crash.log: PY_LOG_FLAGS=SKIP
CRASH_OUT = crash.py.out
endif

CLEANFILES = ${CRASH_OUT} out3.7 c_python.so

use_simplugin.gc.out: $(PWD)/simplugin.py

if VPATH_BUILD
$(PWD)/%.py: %.py
	$(LN_S) $< $@
endif


TESTS = ${PY_TESTS} ${GC_TESTS}
SED_OUT = sed -e '/^default plugins/s/:.*//' \
	           -e '/^core-lib version/s/:.*//' \
	           -e '/^main version/s/:.*//'

${PY_TESTS:%.py=%.py.out}: %.py.out: %.py
	${PYTHON} < ${srcdir}/$*.py | ${SED_OUT} > $@; exit $${PIPESTATUS[0]}

TLP=.libs${LD_LIBRARY_PATH:%=:%}

${GC_TESTS:%.gc=%.gc.out}: %.gc.out: %.gc
	GNUCAP_PLUGPATH=${GNUCAP_PLUGPATH} \
	PYTHONPATH=${PYTHONPATH} \
	LD_LIBRARY_PATH=${TLP} \
	gnucap < ${srcdir}/$*.gc | ${SED_OUT} > $@

.PHONY: .P
.P:
	@:

$(GC_TESTS:%.gc=%.gc.out): .P
$(PY_TESTS:%.py=%.py.out): .P
$(GC_TESTS:%.gc=%.log): .P
$(PY_TESTS:%.py=%.log): .P

EXTRA_DIST = \
	bootstrap \
	CONTRIBUTE \
	gc_log_compiler \
	py_log_compiler \
	simplugin.py \
	${TESTS:%=out3.6/%.ref} \
	${TESTS:%=out2.7/%.ref} \
	${TESTS}
