// Copyright: ..  -2017 Albert Davis
//            2009-2011 Henrik Johansson
//            2018 Felix Salfelder
// Author: Albert Davis
// License: GPLv3
/*
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

%module(directors="0", allprotected="1") m_matrix

%include stl.i
%include std_complex.i
%include _md.i

%{
#include "m_matrix_hack.h"
#include "wrap.h"
#include <Python.h>
#if PY_MAJOR_VERSION >= 3
#define IS_PY3K
#endif
%}

%{
#define SWIG_FILE_WITH_INIT
%}
%include "numpy.i"
%init %{
import_array();
%}

template<class T> class BSMATRIX {
public:
  BSMATRIX(int ss=0);

  void          iwant(int, int);
  void          unallocate();
  void          allocate();
  void          reallocate();
  int           size()const;
  double        density(); // BUG: const
  void          zero();
  void          dezero(T& o);
  void          load_diagonal_point(int i, T value);
  void          load_point(int i, int j, T value);
  void          load_couple(int i, int j, T value);
  void          load_symmetric(int i, int j, T value);
  void          load_asymmetric(int r1, int r2, int c1, int c2, T value);

  void          lu_decomp(const BSMATRIX<T>&, bool do_partial);
  void          lu_decomp();
//  void          fbsub(T* v) const;
  void          fbsub(T* x, const T* b, T* c = NULL) const;

  T     d(int r, int  )const    {return *(_diaptr[r]);}
 //  const T&    s(int r, int c);

private:
  T& m(int r, int c);
};

%template(BSMATRIXd) BSMATRIX<double>;
%template(BSMATRIXc) BSMATRIX<COMPLEX>;

class BSCR{
  BSCR( BSMATRIX<COMPLEX> const& m, size_t r) : _m(m), _r(r){ }
private:
  BSMATRIX<COMPLEX>& _m;
  size_t r;
};

%extend BSMATRIX<COMPLEX> {
  void fbsub_(COMPLEX_array_t& x){
    return self->fbsub(x._t);
  }
  inline std::string __repr__(){
    return "complex BSMATRIX on gnd + " + std::to_string(self->size())
                  + " nodes with " + std::to_string(self->_nzcount) + " nonzeroes,"
                  + " density " + std::to_string(self->density());
  }
  inline BSCR __getitem__(int p){
        incomplete();
    return BSCR(*self, p);
//    return self->s(p,p);
  }

  double data_(){
    incomplete();
    return self->_space[0].real();
  }

  PyObject* _space(bool gnd=true) {
      npy_intp dims[] = { self->_nzcount - 1 + gnd };
      return PyArray_SimpleNewFromData(1, dims, NPY_CDOUBLE, self->_space + 1 - gnd);
  }
  PyObject* _coord(bool gnd) {
    npy_intp dims[] = { self->_nzcount - 1 + gnd, 2 };
    trace2("coord", dims[0], dims[1]);
    PyObject* ret=PyArray_SimpleNew(2, dims, NPY_INT);
    PyArrayObject* d=(PyArrayObject*)(ret); // fingers crossed.

    int* raw = (int*)PyArray_DATA(d);

    unsigned seek=0;
    auto pprev=self->_diaptr[1-gnd];

    for(int d=0; d<gnd+self->_size; ++d){
      int delta = self->_diaptr[d+1-gnd] - pprev;
      pprev += 2*delta + 1;

      int c=d-delta;
      for(; c<d; ++c){
        raw[seek++] = d;
        raw[seek++] = c;
      }
      for(; c>=d-delta; --c){
        raw[seek++] = c;
        raw[seek++] = d;
      }
    }
    return ret;
  }
}

%extend BSCR{

  inline COMPLEX __getitem__(int p){
    return self->get(p);
  }
  inline std::string __repr__(){
    return "complex BSMATRIX of size " + std::to_string(self->size())
                  + " density " + std::to_string(self->density());
  }

  void __getitem__(PyObject *param) {
    if (PySlice_Check(param)) {
      incomplete();
      Py_ssize_t len = -1u, start = 0, stop = 0, step = 0, slicelength = 0;

%#if PY_MAJOR_VERSION >= 3
     PySlice_GetIndicesEx(param,
          len, &start, &stop, &step, &slicelength);
%#else
     PySlice_GetIndicesEx((PySliceObject*)param,
          len, &start, &stop, &step, &slicelength);
%#endif

      trace5("slice", len, start, stop, step, slicelength);
    }else{
    }
  }
}


// vim:ts=8:sw=2:et
