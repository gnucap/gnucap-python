# gnucap-python python library Makefile.am
# Author: 2018 Felix Salfelder
# license GPL-3+
#
# (inspired by now obsolete files from Henrik Johansson)
#

BUILT_SOURCES = u_xprobe.h m_matrix_hack.h
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
	${pythongc_LTLIBRARIES:_%.la=%.py} \
	__init__.py \
	pending.py \
	io_trace.py

pythongc_LTLIBRARIES = \
	_ap.la \
	_gnucap_swig.la \
	_globals.la \
	_md.la \
	_u_sim_data.la \
	_u_function.la \
	_m_cpoly.la \
	_m_matrix.la \
	_m_wave.la \
	_mode.la \
	_c_exp.la \
	_c_comand.la \
	_e_base.la \
	_e_card.la \
	_e_cardlist.la \
	_e_compon.la \
	_e_elemnt.la \
	_e_node.la \
	_e_paramlist.la \
	_e_subckt.la \
	_io_.la \
	_l_compar.la \
	_l_denoise.la \
	_u_nodemap.la \
	_u_opt.la \
	_u_parameter.la \
	_u_status.la \
	_u_time_pair.la \
	_u_xprobe.la \
	_s__.la

PY=${pythongc_LTLIBRARIES:_%.la=%.py}
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

_gnucap_swig_la_SOURCES = command.cc _gnucap_swig.i
_gnucap_swig_la_SOURCES += c_genrat.cc
_gnucap_swig_la_SOURCES += s_tr.cc s_tr_set.cc s_tr_swp.cc s__solve.cc s__out.cc s__init.cc

SWIG_FLAGS = -I${GC_INCLUDEDIR}

%.py _%.cxx _%.h: _%.i
	$(AM_V_GEN)${SWIG} -python -c++ -Wall $(SWIG_FLAGS) -o _$*.cxx $<

.i.cxx:

EXTRA_DIST = \
	director_except.i \
	pending.py \
	numpy.i \
	m_wave_.h \
	wrap.h

CLEANFILES = *~ *.pyc

CLEANFILES+= ${BUILT_SOURCES}
CLEANFILES+= ${pythongc_LTLIBRARIES:_%.la=%.py}
CLEANFILES+= ${pythongc_LTLIBRARIES:%.la=%.cxx}
CLEANFILES+= ${pythongc_LTLIBRARIES:%.la=%.h}

clean-local:
	rm -rf __pycache__

#### dep
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
