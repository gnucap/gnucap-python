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
%module(directors="0", allprotected="1") mode

// %include "mode.h"

%inline %{

enum SIM_MODE { // simulation types
  s_NONE,	/* not doing anything, reset by cmd interpreter	*/
  s_AC,  	/* AC analysis					*/
  s_OP,  	/* op command					*/
  s_DC,  	/* dc sweep command				*/
  s_TRAN,	/* transient command				*/
  s_FOURIER	/* fourier command				*/
};
const int sSTART = s_NONE;
const int sCOUNT = s_FOURIER + 1;

/// inline OMSTREAM& operator<<(OMSTREAM& o, SIM_MODE t) {
///   const std::string s[] = {"ALL", "AC", "OP", "DC", "TRAN", "FOURIER"};
///   assert(t >= int(s_NONE));
///   assert(t <= int(s_FOURIER));
///   return (o << s[t]);
/// }

enum SIM_PHASE { // which of the many steps...
  p_NONE,	/* not doing anything, reset by cmd interpreter */
  p_INIT_DC,	/* initial DC analysis				*/
  p_DC_SWEEP,	/* DC analysis sweep, in progress		*/
  p_TRAN, 	/* transient, in progress			*/
  p_RESTORE	/* transient restore after stop			*/
};


enum PROBE_INDEX { // iter probes (continue after SIM_MODE)
  iPRINTSTEP = sCOUNT,	/* iterations for this printed step		*/
  iSTEP,		/* iterations this internal step		*/
  iTOTAL		/* total iterations since startup		*/
};
const int iCOUNT = iTOTAL + 1;	/* number of iteration counters		*/

%}
