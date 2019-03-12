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
%module(directors="0", allprotected="1") u_sim_data

%{
#include "m_matrix_hack.h"
#include <u_sim_data.h>
%}

%include _md.i
%include _m_matrix.i

struct SIM_DATA{
  int _user_nodes;
  int _subckt_nodes;
  int _model_nodes;
  int _total_nodes;
  int _iter[iCOUNT];

  COMPLEX _jomega;	/* AC frequency to analyze at (radians) */
  double _freq;      /* AC frequency to analyze at (Hertz) */
  bool _limiting;	/* flag: node limiting */
  double _vmax;
  double _vmin;
  bool _uic;		/* flag: use initial conditions (spice-like) */
  TRI_STATE _inc_mode;	/* flag: make incremental changes (3 state) */
  SIM_MODE _mode;	/* simulation type (AC, DC, ...) */
  SIM_PHASE _phase;	/* phase of simulation (iter, init-dc,) */
  int	*_nm;		/* node map (external to internal)	*/
  double *_i;		/* dc-tran current (i) vector		*/
  double *_v0;		/* dc-tran voltage, new			*/
  double *_vt1;		/* dc-tran voltage, 1 time ago		*/
			/*  used to restore after rejected step	*/
  COMPLEX_array_t _ac;		/* ac right side			*/
  LOGIC_NODE* _nstat;	/* digital data				*/
  double *_vdc;		/* saved dc voltages			*/
  BSMATRIX<double> _aa;	/* raw matrix for DC & tran */
  BSMATRIX<double> _lu;	/* decomposed matrix for DC & tran */
  BSMATRIX<COMPLEX> _acx;/* raw & decomposed matrix for AC */

  bool is_first_expand();
  void alloc_hold_vectors();
  void alloc_vectors();
  void unalloc_vectors();
  void uninit();
  void init();
  private:
  virtual void  setup(CS&)      = 0;
  virtual void  sweep()         = 0;
  virtual void  finish()        {}
  virtual bool  is_step_rejected()const {return false;}
public:
  void set_command_none() {_mode = s_NONE;}
  void set_command_ac()	  {_mode = s_AC;}
  void set_command_dc()	  {_mode = s_DC;}
  void set_command_op()	  {_mode = s_OP;}
  void set_command_tran() {_mode = s_TRAN;}
  void set_command_fourier() {_mode = s_FOURIER;}
  SIM_MODE sim_mode()	   {return _mode;}
  bool command_is_ac()	   {return _mode == s_AC;}
  bool command_is_dc()	   {return _mode == s_DC;}
  bool command_is_op()	   {return _mode == s_OP;}
  //bool command_is_tran()    {return _mode == s_TRAN;}
  //bool command_is_fourier() {return _mode == s_FOURIER;}
  bool analysis_is_ac()      {return _mode == s_AC;}
  bool analysis_is_dcop()    {return _mode == s_DC || _mode == s_OP;}
  bool analysis_is_static()  {return _phase == p_INIT_DC || _phase == p_DC_SWEEP;}
  bool analysis_is_restore() {return _phase == p_RESTORE;}
  bool analysis_is_tran()    {return _mode == s_TRAN || _mode == s_FOURIER;}
  bool analysis_is_tran_static()  {return analysis_is_tran() && _phase == p_INIT_DC;}
  bool analysis_is_tran_restore() {return analysis_is_tran() && _phase == p_RESTORE;}
  bool analysis_is_tran_dynamic() {return analysis_is_tran() && _phase == p_TRAN;}

  void reset_iteration_counter(int i) {assert(up_order(0,i,iCOUNT-1)); _iter[i] = 0;}
  void count_iterations(int i)	{assert(up_order(0,i,iCOUNT-1)); ++_iter[i];}
};
