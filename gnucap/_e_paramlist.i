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
%module(directors="1") e_paramlist
%feature(director) COMMON_PARAMLIST;


%{
#include <e_paramlist.h>
%}
%include "_e_compon.i"

%typemap(out) COMMON_COMPONENT*
{
	if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){ untested();
		$result = d->swig_get_self();
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{ untested();
		unreachable();
	}
//	Py_INCREF($result);
}

%typemap(out) COMMON_COMPONENT const*
{
	if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){ untested();
		$result = d->swig_get_self();
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{ untested();
		unreachable();
	}
//	Py_INCREF($result);
}

#if 0 // not yet
%include "e_paramlist.h"
#else
class COMMON_PARAMLIST : public COMMON_COMPONENT {
private:
  explicit COMMON_PARAMLIST(const COMMON_PARAMLIST& p)
    :COMMON_COMPONENT(p), _params(p._params) {++_count;}
public:
  explicit COMMON_PARAMLIST(int c=0)	:COMMON_COMPONENT(c) {++_count;}
	   ~COMMON_PARAMLIST()		{--_count;}
  bool operator==(const COMMON_COMPONENT&)const;
  COMMON_COMPONENT* clone()const	{return new COMMON_PARAMLIST(*this);}
  std::string	name()const		{untested();return "";}
  static int	count()			{untested();return _count;}

  void set_param_by_name(std::string Name, std::string Value) {_params.set(Name, Value);}
  bool		param_is_printable(int)const;
  std::string	param_name(int)const;
  std::string	param_name(int,int)const;
  std::string	param_value(int)const;
  int param_count()const
	{return (static_cast<int>(_params.size()) + COMMON_COMPONENT::param_count());}

  void		precalc_first(const CARD_LIST*);
  void		precalc_last(const CARD_LIST*);
public: // hack
	virtual CARD* clone();
private:
  static int	_count;
public:
  PARAM_LIST	_params;
}; // COMMON_PARAMLIST
#endif

%extend COMMON_PARAMLIST {
  PARAM_LIST& params(){
    return $self->_params;
  }
};

%pythoncode %{
# from .e_paramlist import COMMON_PARAMLIST
%}

%{
PyObject* _wrap_SWIGTYPE_pc_COMMON_PARAMLIST(CKT_BASE const* p, int mode=0){
	if(dynamic_cast<COMMON_PARAMLIST const*>(p)){
		PyObject* r=SWIG_NewPointerObj(SWIG_as_voidptr(p), SWIGTYPE_p_COMMON_PARAMLIST, mode);
		assert(r);
		return r;
	}else{ untested();
		return NULL;
	}
}
PyObject* _wrap_SWIGTYPE_p_COMMON_PARAMLIST(CKT_BASE* p, int mode=0){
	if(dynamic_cast<COMMON_PARAMLIST*>(p)){ untested();
		PyObject* r=SWIG_NewPointerObj(SWIG_as_voidptr(p), SWIGTYPE_p_COMMON_PARAMLIST, mode);
		assert(r);
		return r;
	}else{ untested();
		return NULL;
	}
}
%}
