# gnucap-python python library Makefile.am
# Author: 2018, 2020 Felix Salfelder
# license GPL-3+
#
# (inspired by now obsolete files by Henrik Johansson)
#

include MakeList

BUILT_SOURCES = \
   ${INTERFACE:%.i=%.cxx} \
   ${INTERFACE:%.i=%.h} \
	u_xprobe.h \
	m_matrix_hack.h \
	__init__.py

u_xprobe.h: ${GC_INCLUDEDIR}/u_xprobe.h
	cp $< $@
	sed -i '/^  explicit.*XPROBE():$$/s/e/public:e/' $@
m_matrix_hack.h: ${GC_INCLUDEDIR}/m_matrix.h
	cp $< $@
	sed -i '/^  mutable bool/s/m/public:m/' $@

AM_CPPFLAGS = \
	-I${top_srcdir}/include \
	@PYTHON_CPPFLAGS@ \
	${CPPFLAGS} \
	${GC_CPPFLAGS} \
	-I${PYTHON_SITE_PKG} \
	-DPYTHON_SO=\"@ac_python_libdir@/@ac_python_soname@\"

# python objects
pythongcdir = $(pythondir)/gnucap
pythongc_PYTHON = \
	pending.py \
	io_trace.py

nodist_pythongc_PYTHON = \
	${PY} \
	__init__.py

if ALL_IN_ONE

pythongc_LTLIBRARIES = _all.la
## TODO: load plugins at run time
_all_la_SOURCES = \
	_all.i \
	command.cc \
	c_genrat.cc \
	s_tr.cc s_tr_set.cc s_tr_swp.cc s__solve.cc s__out.cc s__init.cc

else

_gnucap_swig_la_SOURCES = \
	command.cc _gnucap_swig.i \
	c_genrat.cc \
	s_tr.cc s_tr_set.cc s_tr_swp.cc s__solve.cc s__out.cc s__init.cc

pythongc_LTLIBRARIES = ${INTERFACE_LA}
endif

PY = ${INTERFACE:_%.i=%.py}
ppy:
	echo ${PY}
py: ${PY}

all-local: __init__.py ${PWD}/pending.py ${PWD}/io_trace.py
	for i in ${pythongc_LTLIBRARIES:%.la=%.so}; do \
		rm -f $$i; \
		${LN_S} .libs/$$i $$i; \
	done

if VPATH_BUILD
$(PWD)/%.py: %.py
	$(LN_S) $< $@
endif

check: all-local

AM_LDFLAGS = -module -avoid-version

AM_DEFAULT_SOURCE_EXT = .i

SWIG_FLAGS = -I${GC_INCLUDEDIR}

%.py _%.cxx _%.h: _%.i
	$(AM_V_GEN)${SWIG} -python -c++ -Wall $(SWIG_FLAGS) -o _$*.cxx $<

.i.cxx:

CLEANFILES = *~ *.pyc

CLEANFILES += ${BUILT_SOURCES} ${PY}

clean-local:
	rm -rf __pycache__

#### dep (not building blob)
_c_comand.cxx: _m_wave.i _e_base.i
_e_cardlist.cxx: _u_nodemap.i _e_card.i
_e_compon.cxx: _e_card.i _e_base.i _m_wave.i _e_node.i
_e_base.cxx: _m_wave.i
_e_elemnt.cxx: _e_node.i _u_xprobe.i _e_base.i _e_card.i
_e_elemnt.cxx: _m_wave.i _e_compon.i
_e_node.cxx: _io_.i
_e_paramlist.cxx: _e_compon.i
_e_subckt.cxx: _e_compon.i
_globals.cxx: _m_wave.i
_s__.cxx _u_sim_data.cxx: _m_matrix.i _ap.i _io_.i
_s__.cxx: _m_wave.i _e_base.i
_gnucap_swig.cxx: _e_card.i _e_base.i _m_matrix.i
_gnucap_swig.cxx: _m_wave.i _s__.i _io_.i
_globals.cxx: _e_base.i _e_card.i
# BUG
_e_cardlist.cxx: _e_elemnt.i _e_compon.i

_all.cxx: ${INTERFACE}
