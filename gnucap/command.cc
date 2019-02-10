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
{
	assert(OPT::language);
	CS cmd(CS::_STRING, command);
	trace1("parse", command);
	OPT::language->new__instance(cmd, NULL, &CARD_LIST::card_list);
}


// ???
void uninstall_command(DISPATCHER<CMD>::INSTALL *x) { untested();
  trace1("uninstall", x);
  delete x;
}

// could move to __init__.py.
struct defpl_load{
	defpl_load(){
	  CKT_BASE::_sim = new SIM_DATA;
	  CKT_BASE::_probe_lists = new PROBE_LISTS;
	}
}l1;
