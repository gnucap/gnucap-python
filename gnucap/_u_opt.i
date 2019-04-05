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
%module(directors="0", allprotected="1") u_opt

%include stl.i
%include _md.i

%{
#include <u_opt.h>
%}
#include "u_opt.h"

#if 0
// not yet?
#define INTERFACE
%include "u_opt.h"
%include "mode.h"
#endif

class SET_RUN_MODE {
public:
      SET_RUN_MODE(RUN_MODE rm);
};

%inline {
  int OPT_numdgt(){
    return OPT::numdgt;
  }
  double OPT_pivtol(){
    return OPT::pivtol;
  }
}
