# gnucap-python python library Makefile.am
# Author: 2018 Felix Salfelder
# license GPL-3+
#
# (inspired by now obsolete files from Henrik Johansson)
#

AM_CPPFLAGS = \
	-I${top_srcdir}/include \
	@PYTHON_CPPFLAGS@ \
	${CPPFLAGS} \
	${GC_CPPFLAGS} \
	-I${PYTHON_SITE_PKG} \
	-DPYTHON_SO=\"@ac_python_libdir@/@ac_python_soname@\"

# common library
pkglib_LTLIBRARIES = libgnucap-python.la
libgnucap_python_la_SOURCES = garbage.cc
libgnucap_python_la_LDFLAGS =

# python objects
pythongcdir = $(pythondir)/gnucap
pythongc_PYTHON = \
	${pythongc_LTLIBRARIES:_%.la=%.py} __init__.py

pythongc_LTLIBRARIES = \
	_ap.la \
	_gnucap_swig.la \
	_component.la \
	_globals.la \
	_md.la \
	_u_sim_data.la \
	_m_cpoly.la \
	_m_matrix.la \
	_m_wave.la \
	_c_exp.la \
	_c_comand.la \
	_e_base.la \
	_e_cardlist.la \
	_e_elemnt.la \
	_e_node.la \
	_io_.la \
	_u_opt.la \
	_u_status.la \
	_s__.la

all-local:
	for i in ${pythongc_LTLIBRARIES:%.la=%.so}; do \
		rm -f $$i; \
		${LN_S} .libs/$$i $$i; \
	done

check: all-local

AM_LDFLAGS = -module -avoid-version

_globals_la_LIBADD = ${AM_LIBADD} libgnucap-python.la

AM_DEFAULT_SOURCE_EXT = .i

_gnucap_swig_la_SOURCES = command.cc numpy_interface.cc _gnucap_swig.i
_gnucap_swig_la_SOURCES += c_genrat.cc
_gnucap_swig_la_SOURCES += s_tr.cc s_tr_set.cc s_tr_swp.cc s__solve.cc s__out.cc s__init.cc

SWIG_FLAGS = -I${GC_INCLUDEDIR}

%.py _%.cxx _%.h: _%.i
	swig -python -c++ -Wall $(SWIG_FLAGS) -o _$*.cxx $<

.i.cxx:

EXTRA_DIST = \
	m_wave_.h \
	wrap.h \
	e_card.i

CLEANFILES = *~ *.pyc

CLEANFILES+= ${pythongc_LTLIBRARIES:_%.la=%.py}
CLEANFILES+= ${pythongc_LTLIBRARIES:%.la=%.cxx}
CLEANFILES+= ${pythongc_LTLIBRARIES:%.la=%.h}

#### dep
_e_elemnt.cxx: _e_node.i
_component.cxx: e_card.i _e_base.i _m_wave.i
_globals.cxx: _m_wave.i
_c_comand.cxx: _m_wave.i
_s__.cxx: _m_wave.i
_e_base.cxx: _m_wave.i
_e_node.cxx: _io_.i
_e_elemnt.cxx: _m_wave.i
_gnucap_swig.cxx: e_card.i _e_base.i _m_matrix.i _m_wave.i
