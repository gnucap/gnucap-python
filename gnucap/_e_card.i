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

%module(directors="1", allprotected="0") e_card
%include _e_base.i

%pythoncode %{
from .io_trace import untested
%}

%{
#include <e_card.h>
%}

%feature("pythonappend") CARD() %{
    # this is a test
	a=1
%}

%{
#include "e_paramlist.h"
// PyObject* _wrap_SWIGTYPE_pc_COMMON_PARAMLIST(CKT_BASE const*, int owner);
PyObject* _wrap_SWIGTYPE_p_COMMON_PARAMLIST(CKT_BASE*, int owner);

#include "e_elemnt.h"
// PyObject* _wrap_SWIGTYPE_p_ELEMENT(CARD* p, int owner);
PyObject* (*_wrap_SWIGTYPE_p_ELEMENT_p)(CARD* p, int owner);
// PyObject* _wrap_SWIGTYPE_cp_ELEMENT(CARD const* p, int owner);
%}

%typemap(out) CARD*
{
	assert(_wrap_SWIGTYPE_p_ELEMENT_p);
  if($owner == SWIG_POINTER_NEW){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else if(auto c=_wrap_SWIGTYPE_p_COMMON_PARAMLIST($1, $owner)){ untested();
		$result = c;
	}else if(auto c= (*_wrap_SWIGTYPE_p_ELEMENT_p)($1, $owner)){ untested();
		$result = c;
	}else if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){ untested();
		$result = d->swig_get_self();
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{
		unreachable();
	}
	Py_INCREF($result); // BUG
}

class CARD : public CKT_BASE {
protected:                              // create and destroy.
  CARD();
  CARD(const CARD&);
public: // hijack __init__
  %extend {
    %pythoncode %{
    _old_card_init = __init__
    def _patch_card(self):
        if(self.__class__.dev_type == __class__.dev_type):
            # CARD::dev_type is invalid. inject python type name
            self.dev_type = self._default_dev_type

        if(self.__class__.clone == __class__.clone):
            # CARD::dev_type is invalid. inject python copy
            self.clone = self._default_clone

        # refcount hack.
        self._oldclone = self.clone
        self.clone = self._myclone

    def _default_dev_type(self):
        # use the python name if not overridden.
        return type(self).__name__
    def _default_clone(self):
        # make use of python class
        return self.__class__(self)
    def _myclone(self):
        c = self._oldclone()
        return c.__disown__()
    def __init__(self, *args):
        self._old_card_init(*args)
        self._patch_card();
    %}
  }
public:
  virtual  ~CARD();

public: // parameters
  virtual CARD*	 clone()const = 0;
  virtual std::string value_name()const = 0;
  const std::string long_label()const; // no further override

  virtual bool param_is_printable(int)const;
  virtual std::string param_name(int)const;
  virtual std::string param_name(int,int)const;
  virtual std::string param_value(int)const;
  virtual void set_param_by_name(std::string, std::string);
  virtual void set_param_by_index(int, std::string&, int);
  virtual int param_count()const {return 0;}
  virtual std::string dev_type()const;

public:	// dc-tran
//  virtual void	 tr_iwant_matrix()	{}
  virtual void	 tr_begin()		{}
//  virtual void	 tr_restore()		{}
//  virtual void	 dc_advance()		{}
  virtual void	 tr_advance()		{}
  virtual void	 tr_regress()		{}
  virtual bool	 tr_needs_eval()const	{return false;}
//  virtual void	 tr_queue_eval()	{}
//  virtual bool	 do_tr()		{return true;}
//  virtual bool	 do_tr_last()		{return true;}
//  virtual void	 tr_load()		{}
  virtual TIME_PAIR tr_review();	//{return TIME_PAIR(NEVER,NEVER);}
//  virtual void	 tr_accept()		{}
//  virtual void	 tr_unload()		{untested();}

public:        // state, aux data
//  virtual char id_letter()const;
// not yet  virtual int  net_nodes()const;
//  virtual bool is_device()const;
//  virtual void set_slave();
         bool evaluated()const;

  void set_constant(bool c);
  bool is_constant()const;
}; // CARD

%extend CARD{
  //  access directly?
  inline SIM_DATA& sim_(){ itested();
    return *self->_sim;
  }
}

%pythoncode %{
try:
  from .e_card import CARD
except ImportError:
  untested()
  from .all import stub
%}
