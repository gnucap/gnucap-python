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
%module(directors="0", allprotected="1") io_

%pythoncode %{
from .io_trace import untested
%}

%include std_string.i
%include std_complex.i
%include numpy.i

%{
#include <io_.h>
#include <md.h>
%}



%{
// inline OMSTREAM& operator<<(OMSTREAM& o, COMPLEX const& c);
inline OMSTREAM& operator<<(OMSTREAM& o, std::complex<double> const& c)
{
	o << c.real();
	if(c.imag() <0){
		o << "-" << -c.imag();
	}else{
		o << "+" << c.imag();
	}
	return  o	<< "* i";
}
%}

#define INTERFACE // bug in io_.h?

%warnfilter(314) OMSTREAM;
%ignore OMSTREAM::operator=;
%include "io_.h"

%numpy_typemaps(std::complex<double>, NPY_CDOUBLE, int)

#pragma SWIG nowarn=314

%extend OMSTREAM {
  OMSTREAM& print(std::string const& s){
    std::cerr << "deprecated OMSTREAM__print\n";
    return *self << s;
  }
  OMSTREAM& operator<<(double const& d){
    std::cerr << "deprecated OMSTREAM__print\n";
    return *self << d;
  }

  // OMSTREAM& operator<<(std::string const& s){
  //   return *self << s;
  // }
  // OMSTREAM& operator<<(double const& d){
  //   return *self << d;
  // }
  OMSTREAM& operator<<(std::complex<double> const& c){
    return *self << c;
  }
}

%pythoncode %{
try:
  from .io_ import OMSTREAM
except ImportError:
  untested()
  from .all import stub
%}
