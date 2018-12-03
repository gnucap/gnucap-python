/*                               -*- C++ -*-
 * Copyright (C) 2014 Felix Salfelder
 * Author: Felix Salfelder <felix@salfelder.org>
 *
 * This file is part of "Gnucap", the Gnu Circuit Analysis Package
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
 * a branch inductance. replaces built-in inductance.
 */

#include "d_coil.cc"

namespace {
/*--------------------------------------------------------------------------*/
class DEV_BRANCH_L : public DEV_INDUCTANCE {
public:
  DEV_BRANCH_L() :DEV_INDUCTANCE() { _c_model = true; }
  DEV_BRANCH_L(const DEV_BRANCH_L&p)
     : DEV_INDUCTANCE(p) { _c_model = true; }
  CARD*	   clone()const		{return new DEV_BRANCH_L(*this);}
};
/*--------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------*/
DEV_BRANCH_L p1b;
DISPATCHER<CARD>::INSTALL
  d3(&device_dispatcher, "L|inductor", &p1b);
/*--------------------------------------------------------------------------*/
}
