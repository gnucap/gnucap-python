// derived from mesos swig interface
// Madhusudan.C.S, 2011. see
// https://stackoverflow.com/questions/4811492/swig-reporting-python-exceptions-from-c-code

%{
#include <io_trace.h>
%}

%feature("director:except") {
	if( $error != NULL ) { itested();
		PyObject *ptype, *pvalue, *ptraceback;
		PyErr_Fetch( &ptype, &pvalue, &ptraceback );
		PyErr_Restore( ptype, pvalue, ptraceback );
		PyErr_Print();
		Py_Exit(1); // really?
	}else{ untested();
	}
}
