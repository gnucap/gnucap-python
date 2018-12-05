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
%module(directors="0", allprotected="1") e_cardlist

%{
#include <e_cardlist.h>
#include <e_elemnt.h>
#include <u_time_pair.h>
%}

%include "_u_nodemap.i"
%include "exception.i"

%exception Card_Range::next {
  try {
    $action
  } catch (CardListEnd) {
    PyErr_SetString(PyExc_StopIteration, "end of card range");
    return NULL;
  }
}
%exception Card_Range::__next__ {
  try {
    $action
  } catch (CardListEnd) {
    PyErr_SetString(PyExc_StopIteration, "end of card range");
    return NULL;
  }
}

%inline %{
	class ELEMENT;
	class CardListEnd {};
	class Card_Range {
		public:
			typedef CARD_LIST::iterator iterator;
		public:
			Card_Range(iterator c, iterator e) : _cur(c), _end(e) {}

			// py3 (only?)
			ELEMENT& __next__(){
				return next();
			}
			Card_Range* __iter__(){
				return this;
			}
			bool is_end(){ return _cur==_end; }
			ELEMENT& next(){
				// hide non-elements, for now.
				while (!is_end()) {
					if(ELEMENT* e=dynamic_cast<ELEMENT*>(*_cur)){
						++_cur;
						return *e;
					}else{
						++_cur;
					}
				}
				throw CardListEnd();
			}
		private:
			iterator _cur;
			iterator _end;
	};
%}

class CARD_LIST {
public:
	typedef std::list<CARD*>::iterator iterator;
   CARD_LIST& expand();
   CARD_LIST& map_nodes();
   CARD_LIST& tr_iwant_matrix();
	CARD_LIST& set_slave();
	CARD_LIST& precalc_first();
	CARD_LIST& expand();
	CARD_LIST& precalc_last();
	CARD_LIST& map_nodes();
	CARD_LIST& tr_iwant_matrix();
   CARD_LIST& tr_begin();
   CARD_LIST& tr_restore();
   CARD_LIST& dc_advance();
   CARD_LIST& tr_advance();
   CARD_LIST& tr_regress();
   bool       tr_needs_eval()const;
   CARD_LIST& tr_queue_eval();
   bool       do_tr();
   CARD_LIST& tr_load();
   TIME_PAIR  tr_review();
   CARD_LIST& tr_accept();
   CARD_LIST& tr_unload();
   CARD_LIST& ac_iwant_matrix();
   CARD_LIST& ac_begin();
   CARD_LIST& do_ac();
   CARD_LIST& ac_load();

	NODE_MAP*   nodes()const {assert(_nm); return _nm;}

	iterator begin()			{return _cl.begin();}
	iterator end()			{return _cl.end();}
	iterator find_again(const std::string& short_name, iterator);
	iterator find_(const std::string& short_name);
};



%extend Card_Range
{
}

%extend CARD_LIST {
  CARD_LIST& card_list_(){
    return self->card_list;
  }
  Card_Range __iter__() { untested();
    // return a constructed Iterator object
    return Card_Range($self->begin(), $self->end());
  }
};
