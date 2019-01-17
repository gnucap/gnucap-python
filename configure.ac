#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
# Copyright: 2009-2011 Henrik Johansson
#            2018 Felix Salfelder <felix@salfelder.org>
# Author: Henrik Johansson
# License: GPLv3
#
# $Id$

AC_PREREQ(2.69)
AC_INIT([gnucap-python], [0.0.2], [gnucap-devel@gnu.org])
AC_CONFIG_SRCDIR([c_python.cc])
AM_INIT_AUTOMAKE([foreign])
AM_CONFIG_HEADER([config.h])

# Checks for libraries.
# this is a c++ program so use c++ for the tests
AC_LANG([C++])

# ------------ debug switch
AC_MSG_CHECKING([if debug code should be compiled in])
AC_ARG_ENABLE([debug],
[  --enable-debug            Enable building of debug code. [[default: disabled]]],
[
if test "X$enable_debug" = "Xno" ; then
	AC_MSG_RESULT([no])
else
	AC_MSG_RESULT([yes])
	enable_debug=yes
fi
],
[
	AC_MSG_RESULT([no])
	enable_debug=no
])


AC_CHECK_PROG(HAVE_GCCONF, gnucap-conf, true, false)
if test "x$HAVE_GCCONF" = "xfalse"; then
	AC_MSG_ERROR([cannot find gnucap-conf. please install gnucap])
fi
GC_INCLUDEDIR=$(gnucap-conf$_program_suffix --includedir)
GC_CPPFLAGS+=$(gnucap-conf$_program_suffix --cppflags)
GC_PKGLIBDIR=$(gnucap-conf$_program_suffix --pkglibdir)
GC_LDFLAGS=$(gnucap-conf$_program_suffix --ldflags)
GC_LIBS=$(gnucap-conf$_program_suffix --libs)

AM_CONDITIONAL([HAVE_PYTHON], [test "$PYTHON" != :])
AM_CONDITIONAL([VPATH_BUILD], [test ! x$srcdir = "x."])

# Check for python
AM_PATH_PYTHON([2.7])
AC_PYTHON_DEVEL([>= '2.3']) # ???
AC_SUBST(ac_python_soname)
AC_SUBST(ac_python_libdir)

AC_SUBST([PYTHON_SITE_PKG])
AC_SUBST([GC_CPPFLAGS])
AC_SUBST([GC_INCLUDEDIR])
AC_SUBST([GC_LIBS])
AC_SUBST([GC_PKGLIBDIR])
AC_SUBST([LIBGNUCAP_SONAME])
AC_SUBST([gnucap_plugpath])

## Libtool init
AC_PROG_LIBTOOL
AC_CONFIG_MACRO_DIR([m4])

# export symbols to plugins
LDFLAGS="$LDFLAGS -rdynamic $GC_LDFLAGS"

AX_CHECK_LIB_SONAME([LIBGNUCAP], [gnucap], [help_dispatcher], [],
		    [AC_MSG_WARN(["cannot find SONAME in -lgnucap, using fallback"])
		     LIBGNUCAP_SONAME=libgnucap.so ],
		    [AC_MSG_ERROR(["cannot link -lgnucap"])])

if test "$enable_debug" = "yes" ; then
	CPPFLAGS="$CPPFLAGS -DTRACE_UNTESTED"
else
	CPPFLAGS="$CPPFLAGS -DNDEBUG"
fi

AC_MSG_CHECKING([plugpath-override])
AC_ARG_ENABLE([plugpath-override],
[  --enable-plugpath-override          install plugins under prefix. [[default: disabled]]],
[
if test "X$enable_prefix_override" = "Xno" ; then
	AC_MSG_RESULT([no])
else
	AC_MSG_RESULT([yes])
	enable_plugpath_override=yes
fi
],
[
	AC_MSG_RESULT([no])
	enable_plugpath_override=no
])

test "x$prefix" = xNONE &&  prefix=$ac_default_prefix
AS_IF([ test "X$enable_plugpath_override" = "Xyes"],
       [ gnucap_plugpath=$prefix/lib/gnucap ],
       [ gnucap_plugpath=$(gnucap-conf$_program_suffix --pkglibdir) ])

## Check for numpy development file
AC_PYTHON_MODULE(numpy)
NUMPY_DIR="${PYTHON_SITE_PKG}/numpy"
AC_ARG_WITH([numpy], [AC_HELP_STRING([--with-numpy=DIR],
                     [directory where numpy is installed
                      [default=${PYLIBDIR}/numpy] ])],
        NUMPY_DIR=$withval)
NUMPY_DIR="${NUMPY_DIR}/core/include/numpy"
save_CPPFLAGS="$CPPFLAGS"
CPPFLAGS="$CPPFLAGS $PYTHON_CPPFLAGS -I$NUMPY_DIR"
HAS_NUMPY=no

AC_CHECK_HEADER([${NUMPY_DIR}/arrayobject.h],
                [ AC_DEFINE(HAS_NUMPY,[],[wether to include numpy support])
		HAS_NUMPY=yes],[],[#include "Python.h"])
CPPFLAGS=$save_CPPFLAGS

AM_CONDITIONAL(NUMPY, test "x$HAS_NUMPY" = "xyes")
AM_CONDITIONAL(PY2, test "x$PYTHON_VERSION" = "x2.7")

AC_PROG_SWIG()

AC_OUTPUT([
	Makefile
	misc/Makefile
	gnucap/Makefile
	examples/Makefile
	gnucap/__init__.py
	])

AC_MSG_RESULT([
** Configuration summary for $PACKAGE $VERSION:

   prefix:                   $prefix
   plugpath:                 $gnucap_plugpath
   CPPFLAGS:                 $CPPFLAGS
   GC_CPPFLAGS:              $GC_CPPFLAGS
   CFLAGS:                   $CFLAGS
   CXXFLAGS:                 $CXXFLAGS
   LDFLAGS:                  $LDFLAGS
   LIBS:                     $LIBS
   PYTHON:                   $PYTHON

])

dnl vim:ts=8:sw=2:
