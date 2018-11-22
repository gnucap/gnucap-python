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
%module(directors="0", allprotected="1") u_xprobe


%{
// working around swig bug, use local copy
// #include <u_xprobe.h>
#include "u_xprobe.h"
%}

class XPROBE{
private:
  COMPLEX _value;
  mod_t   _modifier; // default
  double  _dbscale;  // 20 for voltage, 10 for power, etc.

protected:
  explicit XPROBE():
    _value(COMPLEX(NOT_VALID, NOT_VALID)),
    _modifier(mtNONE),
    _dbscale(20.) {untested();}
public:
  XPROBE(const XPROBE& p):
    _value(p._value),
    _modifier(p._modifier),
    _dbscale(p._dbscale) {untested();}
  explicit XPROBE(COMPLEX v):
    _value(v),
    _modifier(mtMAG),
    _dbscale(20.) {}
  explicit XPROBE(double v):
    _value(v),
    _modifier(mtREAL),
    _dbscale(20.) {}
};
%nodefaultctor XPROBE;
