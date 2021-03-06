# gnucap-python

This package contains a python plugin for the circuit simulator Gnucap which
allows the user to implement commands or components (or anything) in Python,
and run the simulator in a python environment, e.g. for postprocessing or
plotting purposes.

The package also provides a command for Gnucap that loads Python modules, such
as Python modules implementing custom commands or components (or anything).
See [examples](examples).

Your support is gratefully received.

[![donate](https://liberapay.com/assets/widgets/donate.svg "donate through lp")](https://liberapay.com/felixs/donate)

## Requirements

requirements are:
  * gnucap >= oct '17
  * Python >= 3.6
  * Swig >= 3.0.0 (tested with 3.0.12, 4.0.1)
  * Numpy (with development headers/libraries)
  * c++11 compiler (known issue with gcc 9, param.py)

##  Installation

Build python plugin for gnucap

::

   $ ./bootstrap
   $ ./configure  # pass PYTHON=some_other_python, to select
                  # pass SWIG=/path/to/some/swig3.0, if needed
   $ make
   $ make check   # runs tests
   $ make install # optional. may require root privileges

will install the python module "gnucap" and a gnucap plugin "python".

## no Installation

after

::

	$ make
	$ export PYTHONPATH=.

it should be possible to "import gnucap" from a python interpreter, e.g.

::

	$ python3 -c "import gnucap"
	$ python3 some/test_or_example.py


## Examples

### From gnucap

This seems outdated. See examples/README

::

   $ gnucap -a python.so
   gnucap> python example/loadplot.py        <= this file is missing, but still.
   gnucap> get example/eq2-145.ckt
   gnucap> store ac vm(2)
   gnucap> ac oct 10 1k 100k
   gnucap> myplot vm(2)

First, the Python plugin is loaded. The second line loads a new command called
"myplot" that plots a stored waveform using matplotlib. Line 3-5 loads a
circuit and runs an ac analysis. Finally the ac magnitude of node 2 is plotted
using the new plotting command.

### From Python

Do the same directly from Python

::

   $ python
   >>> import gnucap
   [..]
   welcome to gnucap-python
   >>> gnucap.stuff

stuff is not documented much, but closely resembles the libgnucap interface.
Exceptions are additional Pythonicity, and some usability hacks. see examples
for some applications

## Caveats

* Sometimes tests fail because of stream buffer races. don't know how to
  synchronize Python output with library output. Check manually...

* For debugging Python extensions with valgrind, you should set
  PYTHONMALLOC=malloc. The built-in default allocator, pymalloc, confuses
  valgrind.

* Python interface functions ending with _ are "under construction". These
  may be replaced or superseded by a more Pythonic approach later on.

* Generally you are advised to use gnucap packages from your distribution.
  If Gnucap is installed manually and with a custom prefix, you might have to pass

  LDFLAGS=-L$prefix/lib to configure. also export
  LD_LIBRARY_PATH=$prefix/lib before you run gnucap-python.

  *** on some systems /usr/local is considered "custom", on others a dirty cache
  interferes with the linker. YMMV, tell me your workarounds ***

* the clone hack. currently, the clone override needs to keep a local
  reference to the returned python object. it boils down to an incompleteness
  in swig. generated code looks like

    c_result = reinterpret_cast< CARD * >(swig_argp);
    swig_acquire_ownership_obj(SWIG_as_voidptr(c_result), own /* & TODO: SWIG_POINTER_OWN */);
    return (CARD *) c_result;

  maybe a future swig will allow a better approach. NB: the clone override is
  now optional, and a default is taking care of this.

* python sometimes generates .pyc files containing cached bytecode in random
  places. these may lead to weird error messages, if they are outdated. delete
  them.
