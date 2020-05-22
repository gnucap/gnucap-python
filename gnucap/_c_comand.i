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
%module(directors="0", allprotected="1") c_comand
%feature("director") CMD;

%pythoncode %{
from .io_trace import untested
%}

%include _e_base.i

%exception {
    try {
        $action
    } catch (Exception& e) {
      PyErr_SetString(PyExc_Exception, e.message().c_str());
    }
}
%allowexception;

%{
#include <c_comand.h>
%}

class CMD : public CKT_BASE {
protected:
  explicit CMD();
public:
  std::string value_name()const {return "";}
  virtual void do_it(CS&, CARD_LIST*) = 0;
  virtual ~CMD() {}
  static  void  cmdproc(CS&, CARD_LIST*);
  static  void	command(const std::string&, CARD_LIST*);
};

%pythoncode %{
try:
  from .c_comand import CMD
except ImportError:
  from .all import stub
%}

