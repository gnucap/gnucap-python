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
%module(directors="0", allprotected="1") md

%include std_complex.i
%include "md.h"
// typedef std::complex<double> COMPLEX;

%{
#include "wrap.h"


#if PY_MAJOR_VERSION >= 3
#define IS_PY3K
#endif

%}

struct COMPLEX_array_t {
  COMPLEX* _t;
};


%extend COMPLEX_array_t {
  // inline size_t __len__() const { return status.something }
  inline COMPLEX __getitem__(size_t i){
    return self->get(i);
  }
  inline COMPLEX __setitem__(size_t i, COMPLEX a){
    return self->set(i, a);
  }
}

