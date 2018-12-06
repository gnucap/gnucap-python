// Copyright: 2009-2011 Henrik Johansson
// Author: Henrik Johansson

// this work is derived from gnucap, hence GPLv3+

%module(directors="0", allprotected="1") gnucap_swig

// generate directors for all classes that have virtual methods
%feature(director);
%feature(nodirector) CARD;

%include stl.i
%include std_string.i
%include std_complex.i
%include std_shared_ptr.i

%{
#include "m_matrix_hack.h"
#include "wrap.h"
#include <ap.h>
#include <c_comand.h>
#include <l_dispatcher.h>
#include <s__.h>
#include "m_wave_.h"
#include <u_opt.h>
#include <u_status.h>
#include <e_cardlist.h>
#include <globals.h>
#include <md.h>
#include <s_tr.h>
#include <u_time_pair.h>
#include <u_sim_data.h>
#include <memory>
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

///////////////////////////////////////////////////////////////////////////////
// Basic types
///////////////////////////////////////////////////////////////////////////////

%{
#include <md.h>

%}

///////////////////////////////////////////////////////////////////////////////
// Major gnucap classes
///////////////////////////////////////////////////////////////////////////////

%include _s__.i

class TRANSIENT : public SIM {
public:
        void do_it(CS&, CARD_LIST* scope);
        TRANSIENT();
        ~TRANSIENT();
        virtual void accept();
private:
        void  setup(CS&);
protected:
        bool _cont;
        void sweep();
        void outdata(double, int);
};

///////////////////////////////////////////////////////////////////////////////
// gnucap functions
///////////////////////////////////////////////////////////////////////////////
std::string command(char const*command);
void parse(char const*command);

// vim:ts=8:sw=2:et:
