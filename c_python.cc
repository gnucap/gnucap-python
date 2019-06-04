#include <u_lang.h>
#include <c_comand.h>
#include <globals.h>
#include <s__.h>

#include <Python.h>

// Swig _gnucap init function prototype
//extern "C" void init_gnucap();
//
extern std::vector<CMD*> installed_commands;
extern bool have_default_plugins;

/*--------------------------------------------------------------------------*/
namespace {
/*--------------------------------------------------------------------------*/
static class SIGN_ON {
public:
	SIGN_ON() {
		std::cout.flush(); // BUG
		IO::mstdout << "python plugin version: " PACKAGE_VERSION "\n";
		std::cout.flush(); // BUG
	}
} sign_on;
/*--------------------------------------------------------------------------*/
static int python_loaded = 0;
/*--------------------------------------------------------------------------*/
void load_file(CS& cmd, OMSTREAM out, CARD_LIST* scope)
{
  std::string file_name;
  char *argv[] = {};
  FILE *fp;

  cmd >> file_name;
  
  fp = fopen(file_name.c_str(), "r");
  
  if(fp == NULL) {
    throw Exception_File_Open(std::string("Could not open ") + file_name);
  }else{
  }
  

//  huh?! why not link?
  if(!python_loaded) {
	  trace0("dlopen python");
   // dlopen(PYTHON_SO, RTLD_NOW|RTLD_GLOBAL);
    Py_Initialize();

#if PY_MAJOR_VERSION >= 3
#else
    PySys_SetArgv(0, argv);
#endif
    
    // Call init function of SWIG _gnucap module
 //   init_gnucap();

//    python_loaded = 1;
  }else{ untested();
  }

  trace1("running", file_name);
  PyRun_SimpleFile(fp, file_name.c_str());
}

/*--------------------------------------------------------------------------*/
class CMD_PYTHON : public CMD {
public:
	CMD_PYTHON(){
	  have_default_plugins=true;
	}
	~CMD_PYTHON(){
		// need to uninstall from here?
		trace1("~CMD_PYTHON", installed_commands.size());
		for(auto i : installed_commands){
			command_dispatcher.uninstall(i);
		}
	}
public:
  void do_it(CS& cmd, CARD_LIST* Scope)
  {
    load_file(cmd, IO::mstdout, Scope);
  }
} p1;

DISPATCHER<CMD>::INSTALL d1(&command_dispatcher, "python|loadpy", &p1);
/*--------------------------------------------------------------------------*/
}
