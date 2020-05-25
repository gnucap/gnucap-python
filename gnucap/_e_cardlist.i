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
#include <e_card.h>
#include <u_time_pair.h>
%}

%include "_u_nodemap.i"
%include "_e_paramlist.i"
%include "exception.i"
%include "_e_card.i"

//  BUG
%include "_e_compon.i"

%pythoncode %{
from .io_trace import untested
%}

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

%{
#include "e_elemnt.h"
PyObject* _wrap_SWIGTYPE_p_ELEMENT(CARD* p, int owner);
%}

%typemap(out) CARD&
{
	if(Swig::Director* d=dynamic_cast<Swig::Director*>($1)){
		$result = d->swig_get_self();
	}else if(auto c=_wrap_SWIGTYPE_p_ELEMENT($1, $owner)){
		$result = c;
	}else if(COMPONENT* c=dynamic_cast<COMPONENT*>($1)){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_COMPONENT, $owner);
	}else if($1){ untested();
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $1_descriptor, $owner);
	}else{
		unreachable();
	}
	Py_INCREF($result);
}

%inline %{
	class CARD;
	class CardListEnd {};
	class Card_Range {
		public:
			typedef CARD_LIST::iterator iterator;
		public:
			Card_Range(iterator c, iterator e) : _cur(c), _end(e) {}

			// py3 (only?)
			CARD& __next__(){
				return next();
			}
			Card_Range* __iter__(){
				return this;
			}
			bool is_end(){ return _cur==_end; }
			CARD& next();
		private:
			iterator _cur;
			iterator _end;
	};


CARD& Card_Range::next()
{
	// hide non-elements, for now.
	while (!is_end()) {
		if(CARD* e=dynamic_cast<CARD*>(*_cur)){
			++_cur;
			return *e;
		}else{
			++_cur;
		}
	}
	throw CardListEnd();
}
%} // inline

%feature("flatnested");
class CARD_LIST {
public: // internal types
	typedef std::list<CARD*>::iterator iterator;
	// typedef std::list<CARD*>::const_iterator const_iterator;
	class fat_iterator {
	private:
		CARD_LIST* _list;
		iterator	 _iter;
	private:
		explicit		fat_iterator()	{unreachable();}
	public:
			fat_iterator(const fat_iterator& p)
			: _list(p._list), _iter(p._iter) {}
		explicit		fat_iterator(CARD_LIST* l, iterator i)
			: _list(l), _iter(i) {}
		bool		is_end()const		{return _iter == _list->end();}
		CARD*		operator*()		{return (is_end()) ? NULL : *_iter;}
		// fat_iterator& operator++()	{assert(!is_end()); ++_iter; return *this;}
		// fat_iterator	operator++(int)
		// {assert(!is_end()); fat_iterator t(*this); ++_iter; return t;}
		bool		operator==(const fat_iterator& x)const
					 {unreachable(); assert(_list==x._list); return (_iter==x._iter);}
		bool		operator!=(const fat_iterator& x)const
			{assert(_list==x._list); return (_iter!=x._iter);}
		// iterator		iter()const		{return _iter;}
		// CARD_LIST*		list()const		{return _list;}
		fat_iterator	end()const	{return fat_iterator(_list, _list->end());}

		void		insert(CARD* c)	{list()->insert(iter(),c);}
	};
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
	PARAM_LIST* params();
	PARAM_LIST* params()const;
  // more complex stuff
	void attach_params(PARAM_LIST* p, const CARD_LIST* scope);

	iterator begin()			{return _cl.begin();}
	iterator end()			{return _cl.end();}
	iterator find_again(const std::string& short_name, iterator);
	iterator find_(const std::string& short_name);

	CARD_LIST& push_back(CARD* c);
	CARD_LIST& push_front(CARD* c);
}; // CARD_LIST

%feature("flatnested", "");
%extend CARD_LIST::fat_iterator{
// 	void __next__(){
// 		incomplete();
//    }
	CARD& _deref(){
		return ***self;
	}
	void increment_(){
		++(*self);
	}

%pythoncode %{
def __next__(self):
	if self.is_end():
		raise StopIteration
	else:
		return self._deref()
%}
}



%extend Card_Range
{
}

%extend CARD_LIST {
  CARD_LIST& card_list_(){
    return self->card_list;
  }
  Card_Range __iter__() {
    // return a constructed Iterator object
    return Card_Range($self->begin(), $self->end());
  }
};

CARD_LIST::fat_iterator findbranch(CS&,CARD_LIST::fat_iterator);
CARD_LIST::fat_iterator findbranch(CS& cmd, CARD_LIST* cl);

