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
%module(directors="0", allprotected="1") s__
%feature(director);

%{
#include <s__.h>
%}

%include _u_sim_data.i
%include _c_comand.i
%include _ap.i
%include _io_.i

#if 0
// does not work. some protected types confuse SWIG.
%include "s__.h"
#else
class SIM : public CMD {
protected:
  SIM();
public:
  ~SIM();
protected: // swig needs to know about these, apparently
  virtual void	setup(CS&)	= 0;
  virtual void	sweep()		= 0;
protected:
  virtual void	outdata(double, int);
  virtual void	head(double,double,const std::string&);
  virtual void	print_results(double);
  virtual void	alarm();
  virtual void	store_results(double);
protected:				/* s__solve.cc */
  void	advance_time();
};
#endif

%extend SIM {
  inline SIM_DATA& sim_(){
    return *self->_sim;
  }
}

// SIM_ is needed since Swig doesn't handle private virtual methods
// or protected enums.
// All non-status methods that are inherited from SIM should also be copied
// here or you will get segmentation faults (really?)

// %exception SIM_::do_it {
//    try{ untested();
//       $action
//    }catch(...){ untested();
//       PyErr_SetString(PyExc_KeyError, "AAA");
//       return NULL;
//    }
// }
// %exception SwigDirector_SIM_::do_it {
//    try{ untested();
//       $action
//    }catch(...){ untested();
//       PyErr_SetString(PyExc_KeyError, "AAA");
//       return NULL;
//    }
// }

%feature("director:except") {
	if ($error != NULL) {
		PyObject *exc, *val, *tb;
		PyErr_Fetch(&exc, &val, &tb);
		PyErr_NormalizeException(&exc, &val, &tb);
		std::string err_msg;

		if(tb){
			PyObject* lineno = PyObject_GetAttrString(tb,"tb_lineno");
			PyObject* str = PyObject_Str(lineno);

			err_msg += "Line ";
			err_msg += PyUnicode_AsUTF8(str);
			err_msg += ", ";
			Py_XDECREF(str);
		}else{
		}

		err_msg += "in method '$symname': ";

		PyObject* exc_str = PyObject_GetAttrString(exc, "__name__");
		err_msg += PyUnicode_AsUTF8(exc_str);
		Py_XDECREF(exc_str);

		if (val != NULL) {
			PyObject* val_str = PyObject_Str(val);
			err_msg += ": ";
			err_msg += PyUnicode_AsUTF8(val_str);
			Py_XDECREF(val_str);
		}else{
		}


		Py_XDECREF(exc);
		Py_XDECREF(val);
		Py_XDECREF(tb);

		std::cerr << err_msg << "\n";
		// not sure if this is a good idea.
		throw Exception(err_msg);
		// Swig::DirectorMethodException::raise(err_msg.c_str());
	}
}

%inline %{
class SIM_ : public SIM {
protected:
  enum TRACE { // how much diagnostics to show
    tNONE      = 0,	/* no extended diagnostics			*/
    tUNDER     = 1,	/* show underlying analysis, important pts only	*/
    tALLTIME   = 2,	/* show every time step, including hidden 	*/
    tREJECTED  = 3,	/* show rejected time steps			*/
    tITERATION = 4,	/* show every iteration, including nonconverged	*/
    tVERBOSE   = 5	/* show extended diagnostics			*/
  };
protected:
  explicit SIM_() : SIM() { }
  ~SIM_() { }
public:
  virtual void  setup(CS&)=0;
  virtual void  sweep()=0;
  virtual void  do_it(CS&, CARD_LIST*){ incomplete(); };
public: // huh?
  virtual void	outdata(double d, int i){ return SIM::outdata(d, i);}
  virtual void	head(double a,double b, const std::string& s){
  return SIM::head(a,b,s);
  }
//  virtual void	print_results(double);
//  virtual void	alarm();
//  virtual void	store_results(double);
protected:
  bool solve(OPT::ITL a, unsigned b){
        return SIM::solve(a, SIM::TRACE(b));
  }
  bool solve_with_homotopy(OPT::ITL a, unsigned b){
        return SIM::solve_with_homotopy(a, SIM::TRACE(b));
  }
public:
  OMSTREAM&   hackout(){return _out;}
};

%}

%pythoncode %{
from .s__ import SIM_
%}

%extend SIM_ {
  inline OMSTREAM& out_(){
    return self->hackout();
  }
  inline OMSTREAM& out_assign(OMSTREAM& o){
    return self->hackout() = o;
  }
}
