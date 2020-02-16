# gnucap-python top level Makefile.am
# Author: 2018 Felix Salfelder
# license GPLv3+
#
# (inspired by now obsolete files from Henrik Johansson)
#

# put stuff into $prefix, no matter what gnucap-conf says
AM_DISTCHECK_CONFIGURE_FLAGS=--enable-plugpath-override

ACLOCAL_AMFLAGS = -I m4
SUBDIRS = \
	examples \
	gnucap \
	misc \
	tests

all-local:
	rm -f c_python.so
	-${LN_S} .libs/c_python.so c_python.so

# gnucap plugins
pluginsdir = $(gnucap_plugpath)
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

CLEANFILES =

EXTRA_DIST = \
	bootstrap \
	THANKS \
	CONTRIBUTE \
	gc_log_compiler \
	py_log_compiler
