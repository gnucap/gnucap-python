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
%module(directors="0", allprotected="1") globals

// generate directors for all classes that have virtual methods
%feature("director");
%feature("nodirector") CARD;

%include stl.i
%include std_string.i
%include std_complex.i
%include e_card.i
%include std_shared_ptr.i

%{
#include "wrap.h"
#include <e_compon.h>
#include <e_node.h>
#include <globals.h>
%}


%exception {
    try {
        $action
    } catch (Exception& e) {
      PyErr_SetString(PyExc_Exception, e.message().c_str());
      return NULL;
    }
}
%allowexception;


%{
extern std::vector<CMD*> installed_commands;
extern std::vector<PyObject*> installed_cards;
%}


%typemap(ret) card_install&
{ untested();
  installed_cards.push_back($1obj);
  Py_INCREF($1obj);
}
%inline %{

typedef DISPATCHER<CARD>::INSTALL card_install;

card_install& install_device(char const*name, CARD *card)
{  untested();
   // handle ownership in typemap(ret)
   return *( new card_install(&device_dispatcher, name, card) );
}

typedef DISPATCHER<CMD>::INSTALL cmd_install;
typedef std::shared_ptr< cmd_install > shared_command_installer;

shared_command_installer install_command(char *name, CMD *cmd) {
  installed_commands.push_back(cmd);
  auto x=std::make_shared<DISPATCHER<CMD>::INSTALL>(&command_dispatcher, name, cmd);
  return x;
}
%}

class shared_command_installer{
public:
  // shared_command_installer(DISPATCHER<CMD>*, char *name, CMD *cmd); // ..
  ~shared_command_installer();
};

// later
//DISPATCHER<CMD> command_dispatcher;
//DISPATCHER<COMMON_COMPONENT> bm_dispatcher;
//DISPATCHER<MODEL_CARD> model_dispatcher;
//DISPATCHER<CARD> device_dispatcher;
//DISPATCHER<LANGUAGE> language_dispatcher;
//DISPATCHER<FUNCTION> function_dispatcher;

%{
extern bool have_default_plugins;
%}

%inline %{
bool need_default_plugins(){
  return !have_default_plugins;
}
%}

// vim:ts=8:sw=2:et:
