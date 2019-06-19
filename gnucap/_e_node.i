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

%include "_e_base.i"
%include "_mode.i"

%ignore LOGICVAL::operator=;
%ignore LOGICVAL::operator _LOGICVAL;

#if 0
// not yet.
#define INTERFACE
%include "e_node.h"
#else

enum _LOGICVAL {lvSTABLE0,lvRISING,lvFALLING,lvSTABLE1,lvUNKNOWN};

class LOGICVAL {
private:
  _LOGICVAL _lv;
  static const _LOGICVAL or_truth[lvNUM_STATES][lvNUM_STATES];
  static const _LOGICVAL xor_truth[lvNUM_STATES][lvNUM_STATES];
  static const _LOGICVAL and_truth[lvNUM_STATES][lvNUM_STATES];
  static const _LOGICVAL not_truth[lvNUM_STATES];
public:
  LOGICVAL() :_lv(lvUNKNOWN)			{}
  LOGICVAL(const LOGICVAL& p)	:_lv(p._lv)	{}
  LOGICVAL(_LOGICVAL p)		:_lv(p)		{}
  ~LOGICVAL() {}

  operator _LOGICVAL()const {return static_cast<_LOGICVAL>(_lv);}
  
  LOGICVAL& operator=(_LOGICVAL p)	 {_lv=p; return *this;}
  LOGICVAL& operator=(const LOGICVAL& p) {_lv=p._lv; return *this;}

  LOGICVAL& operator&=(LOGICVAL p)
	{ _lv = and_truth[_lv][p._lv]; return *this;}
  LOGICVAL& operator|=(LOGICVAL p)
	{_lv = or_truth[_lv][p._lv]; return *this;}
  LOGICVAL  operator^=(LOGICVAL p)
	{untested(); _lv = xor_truth[_lv][p._lv]; return *this;}
  LOGICVAL  operator~()const	{return not_truth[_lv];}
  
  bool is_unknown()const	{return _lv == lvUNKNOWN;}
  bool lv_future()const		{assert(_lv!=lvUNKNOWN); return _lv & 1;}
  bool lv_old()const		{assert(_lv!=lvUNKNOWN); return _lv & 2;}

  bool is_rising() const	{return _lv == lvRISING;}
  bool is_falling()const	{return _lv == lvFALLING;}

//  LOGICVAL& set_in_transition(LOGICVAL newval);
}; // LOGICVAL

%extend LOGICVAL {
	std::string __repr__(){
		if( self->lv_future()){
			return "1";
		}else{
			return "0";
		}
	}
}

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
	nodearray_t(unsigned i){
		_t=new node_t[i];
	}
  operator node_t const*() const { return _t; }
  operator node_t*() { return _t; }
  node_t const& get(unsigned i) const{return _t[i];}
//private: // why not?
  node_t* _t;
};

%}

// inline?
struct nodearray_t {
	nodearray_t(unsigned i);
  node_t* _t;
//  node_t const& get(unsigned i) const;
};

%include "carrays.i"
%array_class(node_t, node_array);

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

%extend node_t {
	inline void set_mode(smode_t t){
		(*self)->set_mode(t);
	}
	inline void set_d_iter(){
		(*self)->set_d_iter();
	}
	inline void propagate(){
		(*self)->propagate();
	}
	inline void set_lv(LOGICVAL const& x){
		(*self)->set_lv(x);
	}
	inline void store_old_last_change_time(){ untested();
		(*self)->store_old_last_change_time();
	}
	inline void store_old_lv(){ untested();
		(*self)->store_old_lv();
	}
	inline LOGICVAL lv(){ untested();
		return (*self)->lv();
	}
	inline void	restore_lv(){
		(*self)->restore_lv();
	}
	inline void force_initial_value(LOGICVAL const& x){
		(*self)->force_initial_value(x);
	}
	void	      set_event(double delay, LOGICVAL v){
		(*self)->set_event(delay, v);
	}
	double	      final_time(){
		return (*self)->final_time();
	}
}


%extend nodearray_t {
  // inline size_t __len__() const { return -1; }
  inline const node_t& __getitem__(size_t i) const{
    return self->get(i);
  }
  // inline void __setitem__ ...
}
