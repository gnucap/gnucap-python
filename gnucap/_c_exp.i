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
%module(directors="0", allprotected="1") c_exp

%include <std_string.i>

%{
#include "globals.h"
#include "m_expression.h"
#include "c_comand.h"
#include "e_cardlist.h"
%}

%inline %{

  // void eval_(CS& cmd, CARD_LIST* Scope)
  // {
  //   Expression e(cmd);
  //   cmd.check(bDANGER, "syntax error");
  //   Expression r(e, Scope);
  //   std::cout << e << '=' << r << '\n';
  // }

  // TODO: replace. (how?)
  double eval(std::string what) {
    CS cmd(CS::_STRING, what);
    Expression e(cmd);
    cmd.check(bDANGER, "syntax error");
    Expression r(e, &CARD_LIST::card_list);
    return r.eval();
  }

%}
