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
%module(directors="0", allprotected="1") e_compon

// generate directors for all classes that have virtual methods
%feature("director") COMPONENT;

%include stl.i
%include std_string.i
%include std_complex.i
%include _m_wave.i
%include "_e_card.i"
%include "_e_node.i"
%include std_shared_ptr.i

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


class COMPONENT : public CARD {
protected: // these are not private.
  explicit COMPONENT( const COMPONENT& p);
  explicit COMPONENT();

public: // hijack __init__
  %extend {
    %pythoncode {
    _old_comp_init = __init__
    def __init__(self, *args):
        self._patch_card()
        return self._old_comp_init(*args)
    }
  }

protected:
  virtual ~COMPONENT();
//  virtual CARD*	 clone()const = 0;

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
protected:
  node_array* _n;
};

%pythoncode %{
from .e_compon import COMPONENT
%}

// vim:ts=8:sw=2:et:
