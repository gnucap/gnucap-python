#include <Python.h>
#include <string>

#if PY_MAJOR_VERSION >= 3
#define IS_PY3K
#endif

/*--------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------*/
int main( int argc, char**argv)
{
  std::string file_name("comp.py");
//  char *argv[] = {};
  FILE *fp;
  
  fp = fopen(file_name.c_str(), "r");
  
  if(fp == NULL) {
  }else{
  }
  

//  huh?! why not link?
  //  dlopen(PYTHON_SO, RTLD_NOW|RTLD_GLOBAL);
    Py_Initialize();
#ifdef IS_PY3K
	 wchar_t **argv_w;
	 argv_w = (wchar_t**) malloc((argc)* sizeof(wchar_t**));

	for (int i = 0; i < argc; ++i) {
	 argv_w[i] = Py_DecodeLocale(argv[i], NULL);
	}

    PySys_SetArgv(0, argv_w);

	for (int i = 0; i < argc; ++i) {
	  PyMem_RawFree(argv_w[i]);
	}
#else
    PySys_SetArgv(0, argv);
#endif
    
    // Call init function of SWIG _gnucap module
 //   init_gnucap();

//    python_loaded = 1;

  PyRun_SimpleFile(fp, file_name.c_str());
}
