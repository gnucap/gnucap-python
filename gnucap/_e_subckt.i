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
%module e_subckt
%feature("director", allprotected=1) BASE_SUBCKT;

%include "_e_base.i"
%include "_e_card.i" // expand
%include "_e_compon.i"
%include "_e_node.i"
%include stl.i
%include std_string.i

%{
#include "e_subckt.h"
%}

// these confuse SWIG
%ignore BASE_SUBCKT::dev_type;
// %ignore BASE_SUBCKT::net_nodes;

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

// needed?
class BASE_SUBCKT : public COMPONENT {
protected:
  explicit BASE_SUBCKT()
    :COMPONENT() {}
  explicit BASE_SUBCKT(const BASE_SUBCKT& p)
    :COMPONENT(p) {}
  ~BASE_SUBCKT() {}
protected: // override virtual
  //char  id_letter()const		//CARD/null
  std::string dev_type()const {assert(common()); return common()->modelname();}
  int	  tail_size()const		{return 1;}
  //int	  max_nodes()const		//COMPONENT/null
  //int	  num_nodes()const		//COMPONENT/null
  //int	  min_nodes()const		//COMPONENT/null
  int     matrix_nodes()const		{return 0;}
  int     net_nodes()const		{return _net_nodes;}
  //CARD* clone()const			//CARD/null
  virtual void  precalc_first();
  virtual void  expand();			//COMPONENT
  virtual void  precalc_last();
  //void  map_nodes();
  virtual void	  tr_begin()	{assert(subckt()); subckt()->tr_begin();}
  virtual void	  tr_restore()	{assert(subckt()); subckt()->tr_restore();}
  void	  dc_advance()	{assert(subckt()); subckt()->dc_advance();}
  void	  tr_advance()	{assert(subckt()); subckt()->tr_advance();}
  void	  tr_regress()	{assert(subckt()); subckt()->tr_regress();}
  virtual bool	  tr_needs_eval()const
	{assert(subckt()); return subckt()->tr_needs_eval();}
  void	  tr_queue_eval() {assert(subckt()); subckt()->tr_queue_eval();}
  virtual bool	  do_tr()
	{assert(subckt());set_converged(subckt()->do_tr());return converged();}
  void	  tr_load()	{assert(subckt()); subckt()->tr_load();}
  virtual TIME_PAIR tr_review()	{assert(subckt()); return _time_by = subckt()->tr_review();}
  virtual void  tr_accept()	{assert(subckt()); subckt()->tr_accept();}
  void	  tr_unload()	{assert(subckt()); subckt()->tr_unload();}
  void	  ac_begin()	{assert(subckt()); subckt()->ac_begin();}
  void	  do_ac()	{assert(subckt()); subckt()->do_ac();}
  void	  ac_load()	{assert(subckt()); subckt()->ac_load();}
public:	// ports
  virtual std::string port_name(int)const = 0;
  virtual void set_port_by_name(std::string& name, std::string& value);
  virtual void set_port_by_index(int index, std::string& value);
  bool port_exists(int i)const {return i < net_nodes();}
  const std::string port_value(int i)const;
  void	set_port_to_ground(int index);
public: // actually card. why here?
  CARD_LIST*	     subckt()		{return _subckt;}
  const CARD_LIST*   subckt()const	{return _subckt;}
  void	  new_subckt();
  void	  new_subckt(const CARD* model, PARAM_LIST* p);
  void	  renew_subckt(const CARD* model, PARAM_LIST* p);
  /*virtual*/ CARD_LIST*	   scope();
  /*virtual*/ const CARD_LIST* scope()const;
  /*virtual*/ bool		   makes_own_scope()const  {return false;}
protected:
  node_array* _n;
}; // BASE_SUBCKT

// not yet %include "e_subckt.h"

%pythoncode %{
from .e_subckt import BASE_SUBCKT
%}

// vim:ts=8:sw=2:et:
