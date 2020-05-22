/* Copyright (C) 2018 Felix Salfelder
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
%module(directors="0", allprotected="1") globals
%feature("director");
// %feature("nodirector") CARD;

%pythoncode %{
from .io_trace import untested
%}

%include stl.i
%include std_string.i
%include std_complex.i
%include std_shared_ptr.i

%include "_e_card.i"
%include "_c_comand.i" // bug?
%include "_e_elemnt.i" // bug?

%{
#include "wrap.h"
#include <e_compon.h>
#include <e_node.h>
#include <globals.h>
#include <u_function.h>
%}

%ignore DISPATCHER_BASE;
%ignore DISPATCHER_BASE::operator[];
%ignore DISPATCHER::operator[];
%ignore DISPATCHER_CARD::DISPATCHER_CARD;

// card.i??
%{
#include "e_elemnt.h"
// PyObject* _wrap_SWIGTYPE_p_ELEMENT(CARD* p, int owner);
extern PyObject* (*_wrap_SWIGTYPE_p_ELEMENT_p)(CARD* p, int owner);
PyObject* _wrap_SWIGTYPE_cp_ELEMENT(CARD const* p, int owner);
%}

#if 1
%typemap(out) CARD*
{
assert(_wrap_SWIGTYPE_p_ELEMENT_p);
	if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){
		$result = d->swig_get_self();
	}else if(auto c=(*_wrap_SWIGTYPE_p_ELEMENT_p)($1, $owner)){
		$result = c; // SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_ELEMENT, $owner);
	}else if(COMPONENT* c=dynamic_cast<COMPONENT*>($1)){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_COMPONENT, $owner);
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{
		unreachable();
	}
	Py_INCREF($result);
}
#endif

%typemap(out) CARD const*
{
	if(auto c=_wrap_SWIGTYPE_p_COMMON_PARAMLIST($1, $owner)){ untested();
		$result = c;
	}else if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){ untested();
		$result = d->swig_get_self();
	}else if(auto c=_wrap_SWIGTYPE_cp_ELEMENT($1, $owner)){ untested();
		$result = c;
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{
		unreachable();
	}
	Py_INCREF($result); // BUG
}

%typemap(out) COMMON_COMPONENT*
{
	if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){ untested();
		$result = d->swig_get_self();
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{ untested();
		unreachable();
	}
}

#if 1
%include l_dispatcher.h
#else
template <class TT>
class INTERFACE DISPATCHER : public DISPATCHER_BASE {
public:
  void install(const std::string& s, TT* p);

  TT* operator[](std::string s);
  TT* operator[](CS& cmd);
  TT* clone(std::string s);

  class INSTALL;
};
#endif

// does not compile. why?
%extend DISPATCHER{
  inline CARD const* __getitem__(std::string const& s){
    return (*self)[s];
  }
}

// need both?
%template(DISPATCHER_CARD) DISPATCHER<CARD>;
%template() DISPATCHER<CARD>;

%exception {
    try {
        $action
    } catch (Exception& e) {
      PyErr_SetString(PyExc_Exception, e.message().c_str());
      return NULL;
    }
}
%allowexception;


%{
extern std::vector<CMD*> installed_commands;
extern std::vector<PyObject*> installed_cards;
%}

%pythoncode %{
try:
  untested()
  from .c_comand import CMD
except ImportError:
  untested()
  pass
%}

%inline %{

class install_device {
public:
  typedef DISPATCHER<CARD>::INSTALL card_install;
private:
  install_device(const install_device&){unreachable(); }
public:
  install_device(char const*name, CARD &card){
    _i = new card_install(&device_dispatcher, name, &card);
  }
  ~install_device(){
    delete _i;
  }
public:
  card_install* _i;
};

class install_command {
public:
  typedef DISPATCHER<CMD>::INSTALL card_install;
private:
  install_command(const install_command&){unreachable(); }
public:
  install_command(char const*name, CMD &card){
    _i = new card_install(&command_dispatcher, name, &card);
  }
  ~install_command(){
    delete _i;
  }
public:
  card_install* _i;
};

class install_measure {
public:
  typedef DISPATCHER<FUNCTION>::INSTALL measure_install;
private:
  install_measure(const install_measure&){unreachable(); }
public:
  install_measure(char const*name, FUNCTION &p){
    _i = new measure_install(&measure_dispatcher, name, &p);
  }
  ~install_measure(){
    delete _i;
  }
public:
  measure_install* _i;
};

class install_function {
public:
  typedef DISPATCHER<FUNCTION>::INSTALL function_install;
private:
  install_function(const install_function&){unreachable(); }
public:
  install_function(char const*name, FUNCTION &p){
    _i = new function_install(&function_dispatcher, name, &p);
  }
  ~install_function(){
    delete _i;
  }
public:
  function_install* _i;
};

%}


// later
//DISPATCHER<CMD> command_dispatcher;
//DISPATCHER<COMMON_COMPONENT> bm_dispatcher;
//DISPATCHER<MODEL_CARD> model_dispatcher;
extern DISPATCHER<CARD> device_dispatcher;
//DISPATCHER<LANGUAGE> language_dispatcher;
extern DISPATCHER<FUNCTION> function_dispatcher;

// vim:ts=8:sw=2:et:
