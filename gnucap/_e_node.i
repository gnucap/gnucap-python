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
%module(directors="0", allprotected="1") e_node

%{
#include <e_node.h>
%}

#if 0
// not yet.
#define INTERFACE
%include "e_node.h"
#else
class node_t {
public:
  int	m_()const;
  int t_()const;
  int	e_()const;
//  NODE* n_(); not yet.

  const std::string  short_label()const;
  void	set_to_ground(CARD*);
  void	new_node(const std::string&, const CARD*);
  void	new_model_node(const std::string& n, CARD* d);
  void	map_subckt_node(int* map_array, const CARD* d);
  bool	is_grounded()const;
  bool	is_connected()const;

  // node_t& map(); name conflict

  explicit node_t();
  node_t(const node_t&);
  explicit    node_t(NODE*);
  ~node_t() {}

public:
  //LOGIC_NODE&	    operator*()const	{untested();return data();}
  LOGIC_NODE*	    operator->()	{return &data();}

  // node_t& operator=(const node_t& p); // yikes.

  bool operator==(const node_t& p);

public:
  double      v0()const;
  COMPLEX     vac()const;
  double&     i();
  //COMPLEX&    iac();
};
#endif

%{

struct nodearray_t {
  operator node_t const*() const { return _t; }
  operator node_t*() { return _t; }
  node_t const& get(unsigned i) const{return _t[i];}
//private: // why not?
  node_t* _t;
};

%}

struct nodearray_t {
  node_t* _t;
//  node_t const& get(unsigned i) const;
};

%inline %{

node_t& get_node(node_t* n, unsigned x){
return n[x];
}

%}

class NODE : public CKT_BASE {
private:
  int	_user_number;
  //int	_flat_number;
  //int	_matrix_number;
protected:
  explicit NODE();
private: // inhibited
  explicit NODE(const NODE& p);
public:
  explicit NODE(const NODE* p); // u_nodemap.cc:49 (deep copy)
  explicit NODE(const std::string& s, int n);
  ~NODE() {}

public: // raw data access (rvalues)
  int	user_number()const	{return _user_number;}
  //int	flat_number()const	{itested();return _flat_number;}
public: // simple calculated data access (rvalues)
  int	matrix_number()const	{return _sim->_nm[_user_number];}
  int	m_()const		{return matrix_number();}
public: // maniputation
  NODE&	set_user_number(int n)	{_user_number = n; return *this;}
  //NODE& set_flat_number(int n) {itested();_flat_number = n; return *this;}
  //NODE& set_matrix_number(int n){untested();_matrix_number = n;return *this;}
public: // virtuals
  double	tr_probe_num(const std::string&)const;
  // XPROBE	ac_probe_ext(const std::string&)const;

  double      v0()const	{
    assert(m_() >= 0);
    assert(m_() <= _sim->_total_nodes);
    return _sim->_v0[m_()];
  }
  double      vt1()const {
    assert(m_() >= 0);
    assert(m_() <= _sim->_total_nodes);
    return _sim->_vt1[m_()];
  }
  COMPLEX     vac()const {
    assert(m_() >= 0);
    assert(m_() <= _sim->_total_nodes);
    return _sim->_ac[m_()];
  }
  //double      vdc()const		{untested();return _vdc[m_()];}

  //double&     i()	{untested();return _i[m_()];}  /* lvalues */
  COMPLEX&    iac() {
    assert(m_() >= 0);
    assert(m_() <= _sim->_total_nodes);
    return _sim->_ac[m_()];
  }
};



%extend nodearray_t {
  // inline size_t __len__() const { return -1; }
  inline const node_t& __getitem__(size_t i) const{
    return self->get(i);
  }
  // inline void __setitem__ ...
}
