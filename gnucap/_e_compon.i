/* Copyright (C) 2018, 2019 Felix Salfelder
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
%module(directors="1", allprotected="0") e_compon

%pythoncode %{
from .io_trace import untested
%}

%include stl.i
%include std_string.i
%include std_complex.i
%include _m_wave.i
%include "_e_card.i"
%include "_e_node.i"
%include "_u_time_pair.i"
%include std_shared_ptr.i

%feature("director") COMPONENT;
%feature("director") COMMON_COMPONENT;

%{
#include "e_compon.h"
#include "wrap.h"
#include <e_node.h>
%}

%exception {
    try {
        $action
    } catch (Exception& e) {
      PyErr_SetString(PyExc_Exception, e.message().c_str());
      return NULL;
    }
}
%allowexception;

%typemap(in) COMMON_COMPONENT*(KEEPREF)
{ untested();
   void *argp2 = 0 ;
   int res2 = 0 ;

       // BUG: memory leak
  Py_INCREF($input /*HERE*/ );

  res2 = SWIG_ConvertPtr($input, &argp2,SWIGTYPE_p_COMMON_COMPONENT, 0 |  0 );
  if (!SWIG_IsOK(res2)) {
    SWIG_exception_fail(SWIG_ArgError(res2), "in method '" "COMPONENT_attach_common" "', argument " "2"" of type '" "COMMON_COMPONENT *""'"); 
  }
  arg2 = reinterpret_cast< COMMON_COMPONENT * >(argp2);
}

class node_t;
%typemap(in) (int node_count, const node_t nodes[])
{
  /* Check if is a list */
  if (PyTuple_Check($input)) { untested();
    incomplete();
  }else if (PyList_Check($input)){
    int i;
    $1 = PyList_Size($input);
    $2 = (node_t*) malloc(($1)*sizeof(node_t));
    for (i = 0; i < $1; i++) {
      PyObject *o = PyList_GetItem($input, i);
      if (1 || PyString_Check(o)) {
        auto it = PyList_GetItem($input, i);
        void* argp2;
        res2 = SWIG_ConvertPtr(it, &argp2,SWIGTYPE_p_node_t, 0 |  0 );
        if (!SWIG_IsOK(res2)) {
          SWIG_exception_fail(SWIG_ArgError(res2), "must be node");
        }
        $2[i] = * ((node_t*) argp2);
      } else { untested();
        PyErr_SetString(PyExc_TypeError, "list must contain nodes");
        SWIG_fail;
      }
    }
  } else { untested();
    PyErr_SetString(PyExc_TypeError, "not a list");
    SWIG_fail;
  }
}
%typemap(freearg) (int node_count, const node_t nodes[])
{
free((node_t *) $2);
}

// %include "_e_paramlist.i" # HACK 

%{
#include "e_paramlist.h"
PyObject* _wrap_SWIGTYPE_pc_COMMON_PARAMLIST(CKT_BASE const*, int owner);
PyObject* _wrap_SWIGTYPE_p_COMMON_PARAMLIST(CKT_BASE*, int owner);
%}

%typemap(out) COMMON_COMPONENT*
{
        if($owner == SWIG_POINTER_NEW){
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
        }else if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){ untested();
		$result = d->swig_get_self();
	}else if(auto c=_wrap_SWIGTYPE_p_COMMON_PARAMLIST($1, $owner)){
                return c;
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{ untested();
		unreachable();
	}
	Py_INCREF($result); //BUG
}


%typemap(out) COMMON_COMPONENT const*
{
	if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){
		$result = d->swig_get_self();
	}else if(auto c=dynamic_cast<COMMON_PARAMLIST const*>($1)){
                assert(!$owner);
		$result = _wrap_SWIGTYPE_pc_COMMON_PARAMLIST($1, $owner);
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{ untested();
		unreachable();
	}
	Py_INCREF($result); // BUG
}

#if 1 // BUG
class COMPONENT : public CARD {
protected: // these are not private.
  explicit COMPONENT( const COMPONENT& p);
  explicit COMPONENT();

protected:
  virtual ~COMPONENT();
//  virtual CARD*	 clone()const = 0;
public: // common
  COMMON_COMPONENT* mutable_common()	  {return _common;}
  const COMMON_COMPONENT* common()const	  {return _common;}
  bool	has_common()const		  {return _common;}
  void	attach_common(COMMON_COMPONENT*KEEPREF) {COMMON_COMPONENT::attach_common(c,&_common);}
  void	detach_common()			  {COMMON_COMPONENT::detach_common(&_common);}
  void	deflate_common();
  //--------------------------------------------------------------------
public:	// type
  void  set_dev_type(const std::string& new_type);
  //--------------------------------------------------------------------
  //--------------------------------------------------------------------
  // list and queue management
  bool	is_q_for_eval()const	 {return (_q_for_eval >= _sim->iteration_tag());}
  void	mark_q_for_eval()	 {_q_for_eval = _sim->iteration_tag();}
  void	mark_always_q_for_eval() {_q_for_eval = INT_MAX;}
  void	q_eval();
  void	q_load()		 {_sim->_loadq.push_back(this);}
  void	q_accept()		 {_sim->_acceptq.push_back(this);}

public:	// ports
  virtual std::string port_name(int)const = 0;
  virtual void set_port_by_name(std::string& name, std::string& value);
  virtual void set_port_by_index(int index, std::string& value);
  bool port_exists(int i)const {return i < net_nodes();}
  const std::string port_value(int i)const;
  void	set_port_to_ground(int index);

  virtual std::string current_port_name(int)const;
  virtual const std::string current_port_value(int)const;
  virtual void set_current_port_by_index(int, const std::string&);
  bool current_port_exists(int i)const;

public:	// state, aux data
// not yet  bool	is_device()const;
// // not yet void	set_slave();
  bool	converged()const		{return _converged;}
  void	set_converged(bool s=true)	{_converged = s;}
  void	set_not_converged()		{_converged = false;}

  void  map_nodes();

protected: // CARD
  virtual double tr_probe_num(std::string const&) const;

public:
//  virtual std::string dev_type()const;

public: // parameters
  void set_param_by_name(std::string, std::string);
  void set_param_by_index(int, std::string&, int);
  int  param_count()const
	{return ((has_common()) ? (common()->param_count()) : (2 + CARD::param_count()));}
  bool param_is_printable(int)const;
  std::string param_name(int)const;
  std::string param_name(int,int)const;
  std::string param_value(int)const; 

  virtual void set_parameters(const std::string& Label, CARD* Parent,
			      COMMON_COMPONENT* Common, double Value,
			      int state_count, double state[],
			      int node_count, const node_t nodes[]);
  void	set_value(const PARAMETER<double>& v)	{_value = v;}
  void	set_value(double v)			{_value = v;}
  void  set_value(const std::string& v)		{untested(); _value = v;}
  void	set_value(double v, COMMON_COMPONENT* c);
  const PARAMETER<double>& value()const		{return _value;}

  virtual bool print_type_in_spice()const = 0;

  virtual int	max_nodes()const;
  virtual int	min_nodes()const;
  virtual int	net_nodes()const;
  virtual int	num_current_ports()const;
  virtual int	tail_size()const;
  virtual void  precalc_last();
  virtual void  tr_load();
  virtual void  tr_unload();

  virtual void  ac_begin();
  virtual void  do_ac();
  virtual void  ac_load();

public: // should come from CARD. need workaround, still
  // virtual bool	 tr_needs_eval()const;
  // virtual void	 tr_begin();
  // virtual void	 tr_restore()		{}
  // virtual void	 tr_advance()		{}
  // virtual void	 tr_regress()		{}
  // virtual bool	 do_tr();
  // virtual void  tr_accept();
  // virtual TIME_PAIR  tr_review();

protected:
  node_array* _n;
}; // COMPONENT
#endif

%pythoncode {
from gnucap.io_trace import *
}

%extend COMPONENT {
  %pythoncode {
  _old_comp_init = __init__
  def __init__(self, *args):
      self._patch_card()
      return self._old_comp_init(*args)
  }
}
// BUG CARD virtuals, these should not be necessary here
%extend COMPONENT {
  %pythoncode {
  def tr_needs_eval(self):
      return False
  def tr_begin(self):
      pass
  def tr_restore(self):
      untested()
      pass
  def tr_advance(self):
      pass
  def tr_regress(self):
      untested()
      pass
  def do_tr(self):
      untested()
      return True
  def tr_accept(self):
      untested()
      pass
  def tr_review(self):
      try:
        from .u_time_pair import NEVER
      except:
        from .all import NEVER
      return TIME_PAIR(NEVER, NEVER) # BUG
  }
}

// BUG: typemap leaks into constructor here.
// BUG: this should be sufficient, but need stuff above, still
//      (will ignore COMPONENT in e_compon.h)
%include "e_compon.h"

%pythoncode %{
try:
  from .e_compon import COMPONENT
except ImportError:
  untested()
  from .all import stub
%}

// vim:ts=8:sw=2:et:
