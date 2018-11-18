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
%module(directors="0", allprotected="1") e_elemnt

%feature("director") ELEMENT;

%include stl.i
%include std_string.i
%include std_complex.i
%include e_card.i
%include std_shared_ptr.i
%include "_component.i"
%include "_e_node.i"
%include "_m_cpoly.i"

%{
#include <e_elemnt.h>
#include <e_compon.h>
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

class ELEMENT : public CARD /* it's actually COMPONENT */ {
  virtual ~ELEMENT() {}
protected:
  explicit ELEMENT();
  explicit ELEMENT(const ELEMENT& p);
  
  void	   store_values()		{assert(_y[0]==_y[0]); _y1=_y[0];}
  //void   reject_values()		{ _y0 = _y1;}
protected: // from lower down.
  virtual CARD*	 clone()const = 0;
  virtual std::string port_name(int)const = 0;
protected: //COMPONENT, actually unnecessary here.
  virtual std::string dev_type()const;
  virtual int	max_nodes()const;
  virtual int	min_nodes()const;
  virtual int	net_nodes()const;
  virtual int	matrix_nodes()const;
  virtual int	num_current_ports()const;
  virtual int	tail_size()const;
  virtual void  precalc_last();
  virtual void  tr_begin();
  virtual void  tr_load();
  virtual void  tr_unload();

  virtual void  ac_begin();
  virtual void  do_ac();
  virtual void  ac_load();
protected: // CARD
  void	set_constant(bool c);
public:
//  double*  set__value()			{return _value.pointer_hack();}

  bool	   skip_dev_type(CS&);
public: // override virtual
  bool	   print_type_in_spice()const {return false;}
  // void	   precalc_last();
  //void	   tr_begin();
  void	   tr_restore();
  void	   dc_advance();
  void	   tr_advance();
  void	   tr_regress();
  bool	   tr_needs_eval()const {/*assert(!is_q_for_eval());*/ return !is_constant();}

  TIME_PAIR tr_review();

  std::string long_label()const;
  virtual void	   tr_iwant_matrix() = 0;
  virtual void	   ac_iwant_matrix() = 0;
  //XPROBE   ac_probe_ext(const std::string&)const;

protected: // inline, below
  double   dampdiff(double*, const double&);

  void	   tr_load_inode();
  void	   tr_unload_inode();
  void	   ac_load_inode();

  void	   tr_load_shunt();
  void	   tr_unload_shunt();
  void	   ac_load_shunt();

  void	   tr_load_source();
  void	   tr_unload_source();
  void	   ac_load_source();

  void	   tr_load_couple();
  void	   tr_unload_couple();
  void	   ac_load_couple();

  void	   tr_load_passive();
  void	   tr_unload_passive();
  void	   ac_load_passive();

  void	   tr_load_active();
  void	   tr_unload_active();
  void	   ac_load_active();

  void	   tr_load_extended(const node_t& no1, const node_t& no2,
			    const node_t& ni1, const node_t& ni2,
			    double* value, double* old_value);
  void	   ac_load_extended(const node_t& no1, const node_t& no2,
			    const node_t& ni1, const node_t& ni2,
			    COMPLEX value);

  void	   tr_load_source_point(node_t& no1, double* value, double* old_value);
  void	   ac_load_source_point(node_t& no1, COMPLEX new_value);

  void	   tr_load_diagonal_point(const node_t& no1, double* value, double* old_value);
  void	   ac_load_diagonal_point(const node_t& no1, COMPLEX value);
  
  void	   tr_load_point(const node_t& no1, const node_t& no2,
			 double* value, double* old_value);
  void	   ac_load_point(const node_t& no1, const node_t& no2,
			 COMPLEX value);
  
  bool	   conv_check()const;
  bool	   has_tr_eval()const;
  bool	   has_ac_eval()const;
  bool	   using_tr_eval()const;
  bool	   using_ac_eval()const;
  void	   tr_eval();
  void	   ac_eval();

protected: // in .cc
  void	   tr_iwant_matrix_passive();
  void	   tr_iwant_matrix_active();
  void	   tr_iwant_matrix_extended();
  void	   ac_iwant_matrix_passive();
  void	   ac_iwant_matrix_active();
  void	   ac_iwant_matrix_extended();

public:
  double   tr_review_trunc_error(const FPOLY1* q);
  double   tr_review_check_and_convert(double timestep);

  double   tr_outvolts()const	{return dn_diff(_n[OUT1].v0(), _n[OUT2].v0());}
  double   tr_outvolts_limited()const{return volts_limited(_n[OUT1],_n[OUT2]);}
  COMPLEX  ac_outvolts()const	{return _n[OUT1]->vac() - _n[OUT2]->vac();}

  virtual  double  tr_involts()const		= 0;
  virtual  double  tr_input()const		{return tr_involts();}
  virtual  double  tr_involts_limited()const	= 0;
  virtual  double  tr_input_limited()const	{return tr_involts_limited();}
  virtual  double  tr_amps()const;
  virtual  COMPLEX ac_involts()const		= 0;
  virtual  COMPLEX ac_amps()const;

  virtual int order()const		{return OPT::trsteporder;}
  virtual double error_factor()const	{return OPT::trstepcoef[OPT::trsteporder];}
  int param_count()const {return (0 + COMPONENT::param_count());}
  virtual bool param_is_printable(int)const;
  virtual double tr_probe_num(std::string const&) const;
  virtual std::string value_name()const = 0;
protected:
  int      _loaditer;	// load iteration number
  nodearray_t	_n;
private:
  node_t   _nodes[NODES_PER_BRANCH]; // nodes (0,1:out, 2,3:in)
public:
  CPOLY1   _m0;		// matrix parameters, new
  CPOLY1   _m1;		// matrix parameters, 1 fill ago
  double   _loss0;	// shunt conductance
  double   _loss1;
  std::complex<double>  _acg;	// "COMPLEX" does not work (bug?)
public: // commons
  COMPLEX  _ev;		// ac effective value (usually real)
  double   _dt;

  double   _time[OPT::_keep_time_steps];
  FPOLY1   _y1;		// iteration parameters, 1 iter ago
//  FPOLY1_array_t   _y;
};

%extend ELEMENT {
  inline FPOLY1& _y_(unsigned i){
    return self->_y[i];
  }
  inline void element_tr_begin(){
    return self->ELEMENT::tr_begin();
  }
  inline void element_precalc_last(){
    return self->ELEMENT::precalc_last();
  }
  inline SIM_DATA& sim_(){
    return *self->_sim;
  }
}


// vim:ts=8:sw=2:et:
