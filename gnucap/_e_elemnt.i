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
%module(directors="0", allprotected="1") e_elemnt

%feature("director") ELEMENT;

%include stl.i
%include std_string.i
%include std_complex.i
%include std_shared_ptr.i

// look like these should be %import. but that doesn't work
%include "_e_compon.i"
%include "_u_xprobe.i"
%include "_m_cpoly.i"

%include "_md.i"

%{
#include <e_elemnt.h>
#include <typeindex>
%}

#include <e_elemnt.h>

%exception {
    try {
        $action
    } catch (Exception& e) {
      PyErr_SetString(PyExc_Exception, e.message().c_str());
    }
}
%allowexception;

%nodefaultctor XPROBE;

%{
inline bool COMPONENT::print_type_in_spice() const{ return false; }
%}

%inline %{
template <typename Type, size_t N>
struct wrapped_array{
     Type _d[N];

     operator Type* const&() const;
};
%}

%extend wrapped_array {
  inline size_t __len__() const { return N; }

  inline const Type& __getitem__(size_t i) const throw(std::out_of_range) {
    if (i >= N || i < 0)
      throw std::out_of_range("out of bounds access");
    return self->_d[i];
  }

  inline void __setitem__(size_t i, const Type& v) throw(std::out_of_range) {
    if (i >= N || i < 0)
      throw std::out_of_range("out of bounds access");
    self->_d[i] = v;
  }
}

%typemap(memberin) FPOLY1 [OPT::_keep_time_steps] {
incomplete();
//   memmove($1, $input, 4*sizeof(int));
}
%typemap(memberin) wrapped_array<FPOLY1, OPT::_keep_time_steps> {
incomplete();
//   memmove($1, $input, 4*sizeof(int));
}

class ELEMENT : public COMPONENT {
protected:
  explicit ELEMENT();
  explicit ELEMENT(const ELEMENT& p);
  ~ELEMENT();

public: // hijack __init__
  %extend {
    %pythoncode {
    _oldinit = __init__
    def __init__(self, *args):
        if self.__class__==ELEMENT:
            raise RuntimeError("ELEMENT is abstract")
        self._patch_card();
        return self._oldinit(*args)
    }
  }
protected: // from lower down.
  void	   store_values()		{assert(_y[0]==_y[0]); _y1=_y[0];}
  //void   reject_values()		{ _y0 = _y1;}

  virtual std::string port_name(int)const = 0;

protected: // CARD
//  void	set_constant(bool c);
public:
//  double*  set__value()			{return _value.pointer_hack();}

  bool	   skip_dev_type(CS&);
public: // override virtual
  bool	   print_type_in_spice()const;
  // void	   precalc_last();
  //void	   tr_begin();
  void	   tr_restore();
  void	   dc_advance();
  void	   tr_advance();
  void	   tr_regress();
//  bool	   tr_needs_eval()const {/*assert(!is_q_for_eval());*/ return !is_constant();}

  TIME_PAIR tr_review();

  virtual void	   tr_iwant_matrix() = 0;
  virtual void	   ac_iwant_matrix() = 0;
  virtual XPROBE   ac_probe_ext(const std::string&)const;

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
  node_array* _n;
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
  //FPOLY1   _y[OPT::_keep_time_steps];

  ///FPOLY1*   _y;
  wrapped_array<FPOLY1, OPT::_keep_time_steps> _y;
};

%template (FPOLY1_k) wrapped_array<FPOLY1, OPT::_keep_time_steps>;

%extend ELEMENT {
  // inline FPOLY1& _y_(unsigned i){
  //   return self->_y[i];
  // }
  inline void element_tr_begin(){
    return self->ELEMENT::tr_begin();
  }
  inline void element_precalc_last(){
    return self->ELEMENT::precalc_last();
  }
  inline std::string typeNameHack(){
    return typeid(self).name();
  }
}

// %template(AList) std::vector<A*>;
// %template(AList) CARD_LIST;

%{
namespace {
  std::map<std::type_index, swig_type_info*> elt_type;
}

namespace swig {

//   template<>
//   struct traits<SwigDirector_ELEMENT>{
//         static char const* type_name(){
//         return "ELEMENT";
//     }
//   };
  template<>
  struct traits<ELEMENT>{
        static char const* type_name(){
        return "ELEMENT";
    }
  };
  template<class Type>
  struct traits_from_ptr;

  template <class Type>
  inline swig_type_info *type_info();

  template<>
  struct traits_from_ptr<ELEMENT> {
    static PyObject *from(ELEMENT *val, int owner = 0) { untested();
      auto ty = elt_type[typeid(*val)];
      if (!ty) { untested();
        ty = type_info<ELEMENT>();
      }else{ untested();
      }
      return SWIG_NewPointerObj(val, ty, owner);
    }
  };

  template<>
  struct traits_info<ELEMENT*> {
  };
}
%}

%{
PyObject* _wrap_SWIGTYPE_cp_ELEMENT(CARD const* p, int owner){ untested();
  if(dynamic_cast<ELEMENT const*>(p)){
    PyObject* r=SWIG_NewPointerObj(SWIG_as_voidptr(p), SWIGTYPE_p_ELEMENT, owner);
    assert(r);
    return r;
  }else{
    return NULL;
  }
}
PyObject* _wrap_SWIGTYPE_p_ELEMENT(CARD* p, int owner){ untested();
  if(dynamic_cast<ELEMENT*>(p)){
    PyObject* r=SWIG_NewPointerObj(SWIG_as_voidptr(p), SWIGTYPE_p_ELEMENT, owner);
    assert(r);
    return r;
  }else{
    return NULL;
  }
}
extern PyObject* (*_wrap_SWIGTYPE_p_ELEMENT_p)(CARD* p, int owner);

struct install_element_cast{
        install_element_cast(){
                _wrap_SWIGTYPE_p_ELEMENT_p = &_wrap_SWIGTYPE_p_ELEMENT;
        }
}a;
%}


// vim:ts=8:sw=2:et:
