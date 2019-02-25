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
%module(directors="0", allprotected="1") e_compon

// generate directors for all classes that have virtual methods
%feature("director") COMPONENT_;
%feature("nodirector") CARD;
%feature("nodirector") COMPONENT;
%ignore COMPONENT;

%include stl.i
%include std_string.i
%include std_complex.i
%include _m_wave.i
%include "_e_card.i"
%include std_shared_ptr.i


%{
#include "wrap.h"
#include <e_compon.h>
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

%pythoncode %{
# this will end up somewhere in component.py
%}

class COMPONENT : public CARD{
public:
  explicit COMPONENT( const COMPONENT& p);
  COMPONENT() ;
  virtual ~COMPONENT() { untested(); }
protected: // COMPONENT
  virtual std::string port_name(int)const { untested();  return "..."; }
  virtual bool print_type_in_spice()const {  untested(); return false; }
  virtual double tr_probe_num(std::string const&) const { return 88; }
protected: // CARD?
  virtual std::string value_name()const { untested(); return "VN"; }
  virtual CARD* clone()const = 0;
};


%{ // _component.cxx
class COMPONENT_ : public COMPONENT{
public:
  explicit COMPONENT_( const COMPONENT_& p) {
  _n = _nodes;
  }
  COMPONENT_() {
  _n = _nodes;
  }
  virtual ~COMPONENT_() { }
protected: // COMPONENT
  virtual std::string port_name(int)const { untested();  return "..."; }
  virtual bool print_type_in_spice()const {  untested(); return false; }
  virtual double tr_probe_num(std::string const&) const { return 88; }
protected: // CARD?
  virtual std::string value_name()const { untested(); return "VN"; }
  virtual CARD* clone()const{ untested();
        // something like
        // hack.push_back( self.__class__(self) )?
        // return hack.back();
    unreachable();
    return NULL;
  }
private:
  node_t   _nodes[20];
};
%}

// COMPONENT, as python sees it.
class COMPONENT_ : public CARD {
public:
  explicit COMPONENT_( const COMPONENT_& p);
  explicit COMPONENT_(); //  : COMPONENT();
  virtual ~COMPONENT_();
protected: // COMPONENT
  virtual std::string port_name(int)const;
  const std::string port_value(int i)const;

protected: // CARD
  virtual int param_count()const;
  virtual bool param_is_printable(int)const;
  virtual double tr_probe_num(std::string const&) const;
  virtual std::string value_name()const = 0;
  virtual CARD* clone()const = 0; // not "recommended"
  virtual std::string dev_type()const	{unreachable(); return "unset";}
  std::string long_label()const;

  virtual int	max_nodes()const	{unreachable(); return 0;}
  virtual int	min_nodes()const	{unreachable(); return 0;}
  virtual int	net_nodes()const	{unreachable(); return 0;}
  virtual int	num_current_ports()const {return 0;}
  virtual int	tail_size()const	{return 0;}

  node_t*	_n;
};


// later
// DISPATCHER<CARD> device_dispatcher;

%inline %{

%}

// vim:ts=8:sw=2:et:
