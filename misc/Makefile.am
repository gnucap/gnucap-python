plugindir = ${gnucap_plugpath}/gnucap-python

PLUGIN_LDFLAGS=-module -shared

AM_DEFAULT_SOURCE_EXT = .cc
plugin_LTLIBRARIES = d_brl.la
d_brl_la_LDFLAGS = $(PLUGIN_LDFLAGS)
d_brl_la_CPPFLAGS = $(GEDA_CFLAGS) @GC_CPPFLAGS@

EXTRA_DIST = d_coil.cc
