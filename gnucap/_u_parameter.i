/* Copyright (C) 2019 Felix Salfelder
 * Author: Felix Salfelder <felix@salfelder.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 *------------------------------------------------------------------
 */
%module(directors="0") u_parameter

%pythoncode %{
from .io_trace import untested
%}

%{
#include <u_parameter.h>
#include <ap.h>
%}
// #include <_ap.i>

%include "std_string.i"
%include "std_pair.i"


template<class T>
class PARAMETER{
public:
  explicit PARAMETER() : PARA_BASE(), _v(NOT_INPUT) {}
  PARAMETER(const PARAMETER<T>& p): PARA_BASE(p), _v(p._v) {}
  explicit PARAMETER(T v) :PARA_BASE(), _v(v) {}
  //explicit PARAMETER(T v, const std::string& s) :_v(v), _s(s) {untested();}
  ~PARAMETER() {}
  
  bool	has_good_value()const {return (_v != NOT_INPUT);}
  //bool has_soft_value()const {untested(); return (has_good_value() && !has_hard_value());}

  // operator T()const {return _v;}
  T	e_val(const T& def, const CARD_LIST* scope)const;
  void	parse(CS& cmd);

  std::string string()const {
    if (_s == "#") {
      return to_string(_v);
    }else if (_s == "") {
      return "NA(" + to_string(_v) + ")";
    }else{
      return _s;
    }
  }
  void	print(OMSTREAM& o)const		{o << string();}
  void	set_default(const T& v)		{_v = v; _s = "";}
  // void	operator=(const PARAMETER& p)	{_v = p._v; _s = p._s;}
  // void	operator=(const T& v)		{_v = v; _s = "#";}
  //void	operator=(const std::string& s)	{untested();_s = s;}

  // void	operator=(const std::string& s);
  bool  operator==(const PARAMETER& p)const;
  // bool  operator==(const T& v)const;
};

%inline %{
class ExceptionEOPL {};
class PARAM_LIST_RANGE {
public:
	typedef std::pair< std::string, PARAMETER<double> > value_type;
	// typedef value_type& ref_type;
	typedef value_type ref_type; // BUG
public:
	PARAM_LIST_RANGE(PARAM_LIST::iterator cur, PARAM_LIST::iterator end) : _cur(cur), _end(end) {}
	PARAM_LIST_RANGE* __iter__() {
		return this;
	}
	PARAM_LIST::iterator _cur;
	PARAM_LIST::iterator _end;
};
%}

#define INTERFACE
%include "u_parameter.h"

%template(PARAMETERd) PARAMETER<double>;
%template(PARAMETERi) PARAMETER<int>;
%template(PARAMETERb) PARAMETER<bool>;


// %feature("valuewrapper") std::pair<const std::string, PARAMETER<double> >;
// %template(testtype) std::pair<const std::string, PARAMETERd >;
%template(testtype) std::pair<std::string, PARAMETER<double> >;


%pythoncode %{
try:
  from .u_parameter import PARAMETERi, PARAMETERd, PARAMETERb
except ImportError:
  untested()
  from .all import stub
%}

%extend PARAMETER<double> {
	double float_(){
		return *self;
	}
	inline PARAMETER<double>& assign(std::string const& s){
		*self = s;
		return *self;
	}
	inline double __sub__(double const&x){
		return *self - x;
	}
	inline double __sub__(PARAMETER<double> const&x){ untested();
		return *self - x;
	}
	inline double __mul__(PARAMETER<double> const&x){ untested();
		return *self * x;
	}
	inline double __mul__(double const&x){
		return *self * x;
	}
	inline double __div__(PARAMETER<double> const& x){ untested();
		return *self / x;
	}
	inline double __truediv__(double const& x){
		return *self / x;
	}
}

%define PAR_OPS(TypeName)
%extend TypeName {
	inline bool __lt__(double x){
		return double(*self) < x;
	}
	inline bool __le__(double x){
		return double(*self) <= x;
	}
	inline bool __eq__(double x){
		return double(*self) == x;
	}
	inline bool __ne__(double x){
		return double(*self) != x;
	}
	inline bool __gt__(double x){
		return double(*self) > x;
	}
	inline bool __ge__(double x){
		return double(*self) >= x;
	}
	inline std::string __repr__(){
		return self->string();
	}
}
%enddef

%typemap(argout) PARAMETER<double> *INOUT {
  $result=SWIG_Python_AppendOutput($result, obj2);
  Py_INCREF(obj2);
}
%typemap(argout) PARAMETER<int> *INOUT { untested();
  $result=SWIG_Python_AppendOutput($result, obj2);
  Py_INCREF(obj2);
}
%typemap(argout) PARAMETER<bool> *INOUT { untested();
  $result=SWIG_Python_AppendOutput($result, obj2);
  Py_INCREF(obj2);
}

bool Get(CS& cmd, const std::string& key, PARAMETER<bool>* INOUT);
bool Get(CS& cmd, const std::string& key, PARAMETER<int>* INOUT);
bool Get(CS& cmd, const std::string& key, PARAMETER<double>* INOUT);


%typemap(argout) PARAMETER<double> &INOUT {
  $result=SWIG_Python_AppendOutput($result, obj1);
  Py_INCREF(obj1);
}
%inline %{

CS& _para_rshift(CS& a,  PARAMETER<double>& INOUT){
	return a >> INOUT;
}

%}

%pythoncode %{

try:
  from .ap import _getD
except ImportError:
  from .all import stub

_getD[PARAMETERi] = Get
_getD[PARAMETERd] = Get
_getD[PARAMETERb] = Get

try:
  from .ap import _CS_rshift
except ImportError:
  untested()
  from .all import _CS_rshift

_CS_rshift[PARAMETERd] = _para_rshift
%}


PAR_OPS(PARAMETER<int>)
PAR_OPS(PARAMETER<double>)
PAR_OPS(PARAMETER<bool>)

%include "exception.i"
%exception PARAM_LIST_RANGE::__next__ {
  try {
    $action
  } catch (ExceptionEOPL) {
    PyErr_SetString(PyExc_StopIteration, "End of PARAM_LIST");
    return NULL;
  }
}

%extend PARAM_LIST_RANGE {
	PARAM_LIST_RANGE::ref_type __next__() {
		PARAM_LIST::iterator& p = $self->_cur;
		if (p != $self->_end) {
			PARAM_LIST_RANGE::value_type r = *p;
			++p;
			return r;
		}else{
			throw ExceptionEOPL();
		}
	}
}

%extend PARAM_LIST {
  PARAM_LIST_RANGE __iter__() {
    return PARAM_LIST_RANGE($self->begin(), $self->end());
  }
};
