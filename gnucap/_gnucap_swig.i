// Copyright: 2009-2011 Henrik Johansson
//            2018-2019 Felix Salfelder
// Author: Henrik Johansson

// this work is derived from gnucap, hence GPLv3+

%module(directors="0", allprotected="1") gnucap_swig

// generate directors for all classes that have virtual methods
%feature(director);

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
#include <io_error.h>
#include <memory>
%}

%exception {
    try {
        $action
    } catch (Exception& e) {
      PyErr_SetString(PyExc_Exception, e.message().c_str());
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
void parse(char const*command);

%exception command {
  try{
    $action
  }catch(Exception const& k){ untested();
    PyErr_SetString(PyExc_NameError, k.message().c_str());
    return NULL;
  }catch(MyBadCommand const& k){ untested();
    PyErr_SetString(PyExc_NameError, k._s.c_str());
    return NULL;
  }
}

%{
struct MyBadCommand{
MyBadCommand(std::string const& s) : _s("bad internal command: " + s){}
std::string _s;
};
%}

%inline %{
std::string command(char const*command)
{
	trace1("command", command);
  
  //char filename[L_tmpnam];
  
  //tmpnam(filename);
  
  // supress output to stdout
//  IO::mstdout.detach(stdout);
  IO::mstdout.reset(); // needed?

  // send output to file
//   CMD::command(std::string("> ") + std::string(filename), &CARD_LIST::card_list);

 //  SET_RUN_MODE a(rBATCH);
  CS cmd(CS::_STRING, command); // from string, full command
  std::string s;
  cmd >> s;

  CMD* c = command_dispatcher[s];
  if (c) {
    c->do_it(cmd, &CARD_LIST::card_list);
  }else{
    // std::cout.flush();
    throw MyBadCommand(s);
  }

  // somehow this is needed for python3, if compiled with optimisations on.
  std::cout.flush();

  //IO::mstdout.reset(); // needed?
//  IO::mstdout.attach(stdout);

//  CMD::command(">", &CARD_LIST::card_list);

  // Open file an read it
  //std::ifstream ifs(filename);

  //std::ostringstream oss;

//  oss << ifs.rdbuf();

//  std::string output(oss.str());

  //unlink(filename);
  
  return "";
}
%}

// vim:ts=8:sw=2:et:
