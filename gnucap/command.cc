#include "wrap.h"
#include <u_lang.h>
#include <c_comand.h>
#include <globals.h>
#include <m_wave.h>
#include <u_prblst.h>
#include <u_sim_data.h>
#include <s__.h>
#include <io_.h>
#include <e_cardlist.h>
#include <u_lang.h>

#include <stdio.h>
#include <string>
#include <fstream>
#include <memory>

void parse(char const*command)
{ untested();
	assert(OPT::language);
	CS cmd(CS::_STRING, command);
	trace1("parse", command);
	OPT::language->new__instance(cmd, NULL, &CARD_LIST::card_list);
}
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

  CMD::command(std::string(command), &CARD_LIST::card_list);

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


// ???
void uninstall_command(DISPATCHER<CMD>::INSTALL *x) { untested();
  trace1("uninstall", x);
  delete x;
}

// could move to __init__.py.
struct defpl_load{
	defpl_load(){ untested();
	  CKT_BASE::_sim = new SIM_DATA;
	  CKT_BASE::_probe_lists = new PROBE_LISTS;
	}
}l1;
