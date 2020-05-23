/* Copyright (C) 2020 Felix Salfelder
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

%module all

%pythoncode %{
stub=None
%}

%include _ap.i
%include _gnucap_swig.i
%include _s__.i
%include _e_base.i
%include _e_card.i
%include _e_paramlist.i
%include _e_elemnt.i
%include _e_compon.i
%include _io_.i
%include _u_sim_data.i
%include _c_comand.i
%include _c_exp.i
%include director_except.i
%include _e_cardlist.i
%include _e_node.i
%include _e_subckt.i
%include _globals.i
%include _l_compar.i
%include _l_denoise.i
%include _m_cpoly.i
%include _md.i
%include _m_matrix.i
%include _mode.i
%include _m_wave.i
%include numpy.i
%include _u_function.i
%include _u_nodemap.i
%include _u_opt.i
%include _u_parameter.i
%include _u_status.i
%include _u_time_pair.i
%include _u_xprobe.i
