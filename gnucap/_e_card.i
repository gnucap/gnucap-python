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

%module(directors="0", allprotected="1") e_card
%include _e_base.i

%{
#include <e_card.h>
%}

class CARD : public CKT_BASE {
protected:                              // create and destroy.
  CARD();
  CARD(const CARD&);
public: // hijack __init__
  %extend {
    %pythoncode %{
    _old_card_init = __init__
    def _patch_card(self):
        if(self.__class__.dev_type == __class__.dev_type):
            # CARD::dev_type is invalid. inject python type name
            self.dev_type = self._default_dev_type

        if(self.__class__.clone == __class__.clone):
            # CARD::dev_type is invalid. inject python copy
            self.clone = self._default_clone

        # refcount hack.
        self._oldclone = self.clone
        self.clone = self._myclone
        self.HACK = []

    def _default_dev_type(self):
        # use the python name if not overridden.
        return type(self).__name__
    def _default_clone(self):
        # make use of python class
        return self.__class__(self)
    def _myclone(self):
        c = self._oldclone()
        self.HACK.append(c)
        return c
    def __init__(self, *args):
        self._old_card_init(*args)
        self._patch_card();
    %}
  }
public:
  virtual  ~CARD();

public: // parameters
  virtual CARD*	 clone()const = 0;
  virtual std::string value_name()const = 0;
  const std::string long_label()const; // no further override

  virtual bool param_is_printable(int)const;
  virtual std::string param_name(int)const;
  virtual std::string param_name(int,int)const;
  virtual std::string param_value(int)const;
  virtual void set_param_by_name(std::string, std::string);
  virtual void set_param_by_index(int, std::string&, int);
  virtual int param_count()const {return 0;}
  virtual std::string dev_type()const;

public:        // state, aux data
//  virtual char id_letter()const;
// not yet  virtual int  net_nodes()const;
//  virtual bool is_device()const;
//  virtual void set_slave();
         bool evaluated()const;

//  void set_constant(bool c);
  bool is_constant()const;
}; // CARD

%extend CARD{
  inline SIM_DATA& sim_(){ untested();
    return *self->_sim;
  }
}

%pythoncode %{
from .e_card import CARD
%}
