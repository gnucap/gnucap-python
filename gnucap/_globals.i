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

// generate directors for all classes that have virtual methods
%feature("director");
%feature("nodirector") CARD;

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
%}

%ignore DISPATCHER_BASE;
%ignore DISPATCHER_BASE::operator[];
%ignore DISPATCHER::operator[];

%typemap(out) CARD*
{
	if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){
		$result = d->swig_get_self();
	}else if(ELEMENT* c=dynamic_cast<ELEMENT*>($1)){
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_ELEMENT, $owner);
	}else if(COMPONENT* c=dynamic_cast<COMPONENT*>($1)){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_COMPONENT, $owner);
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{
		unreachable();
	}
	Py_INCREF($result);
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

%include l_dispatcher.h

// does not compile. why?
/// %extend DISPATCHER{ untested();
///   inline CARD const& __getitem__(std::string /*const?*/ s){
///     return *(*self)[s];
///   }
/// }

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


// %typemap(ret) card_install&
// {
//   installed_cards.push_back($1obj);
// //  Py_INCREF($1obj);
// }

%pythoncode %{
from .c_comand import CMD
%}

%inline %{

class install_device {
public:
  typedef DISPATCHER<CARD>::INSTALL card_install;

private:
  install_device(const install_device&){unreachable(); }
public:
  install_device(char const*name, CARD &card){
    _i=new card_install(&device_dispatcher, name, &card);
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
    _i=new card_install(&command_dispatcher, name, &card);
  }
  ~install_command(){
    delete _i;
  }

public:
  card_install* _i;
};
%}

// need both?
%template(DISPATCHER_CARD) DISPATCHER<CARD>;
%template() DISPATCHER<CARD>;

// later
//DISPATCHER<CMD> command_dispatcher;
//DISPATCHER<COMMON_COMPONENT> bm_dispatcher;
//DISPATCHER<MODEL_CARD> model_dispatcher;
extern DISPATCHER<CARD> device_dispatcher;
//DISPATCHER<LANGUAGE> language_dispatcher;
//DISPATCHER<FUNCTION> function_dispatcher;

%{
extern bool have_default_plugins;
%}

%inline %{
bool need_default_plugins(){
  return !have_default_plugins;
}
%}


// vim:ts=8:sw=2:et:
