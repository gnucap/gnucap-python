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
%module(directors="0", allprotected="1") m_wave

// %feature("director") WAVE;

%{
#include "m_wave_.h"
#include <e_base.h>
%}

%include std_pair.i
%include std_deque.i

typedef std::pair<double, double> DPAIR; // swig says this is redundant
                                         // but it's not!
%template() std::pair<double,double>;
%template(PairDeque) std::deque<std::pair<double,double> >;

%inline %{
class StopIterator {};
class WaveIterator {
  public:
    WaveIterator(WAVE::const_iterator _cur, WAVE::const_iterator _end)
      : cur(_cur), end(_end) { untested();
    }
    WaveIterator* __iter__()
    { untested();
      return this;
    }
    WAVE::const_iterator cur;
    WAVE::const_iterator end;
  };
%}

class WAVE {
public:
//  typedef std::deque<DPAIR>::iterator iterator;
  typedef std::deque<DPAIR>::const_iterator const_iterator;

  explicit WAVE(double d=0);
  explicit WAVE(const WAVE&);
  ~WAVE() {}
  WAVE&	   set_delay(double d);
  WAVE&	   initialize();
  WAVE&	   push(double t, double v);
  FPOLY1   v_out(double t)const;
  double   v_reflect(double t, double v_total)const;
  WAVE&	   operator+=(const WAVE& x);
  WAVE&	   operator+=(double x);
  WAVE&	   operator*=(const WAVE& x);
  WAVE&	   operator*=(double x);
  const_iterator begin()const {return _w.begin();}
  const_iterator end()const {return _w.end();}
};

%include "exception.i"

// python2
%exception WaveIterator::next { untested();
  try { untested();
    $action // calls %extend function next() below
  } catch (StopIterator){ untested();
    PyErr_SetString(PyExc_StopIteration, "End of iterator");
    return NULL;
  }
}

// python3
%exception WaveIterator::__next__ { untested();
  try { untested();
    $action // calls %extend function next() below
  } catch (StopIterator){ untested();
    PyErr_SetString(PyExc_StopIteration, "End of iterator");
    return NULL;
  }
}

%extend WaveIterator {
  DPAIR const& __next__()
  { untested();
    if ($self->cur != $self->end) { untested();
      return *$self->cur++;
    }else{ untested();
		 throw StopIterator();
    }
  }
	// python2
  DPAIR const& next()
  { untested();
    if ($self->cur != $self->end) { untested();
      return *$self->cur++;
    }else{ untested();
		 throw StopIterator();
    }
  }
}

%extend WAVE {
  WaveIterator __iter__()
  { untested();
    return WaveIterator($self->begin(), $self->end());
  }
};
