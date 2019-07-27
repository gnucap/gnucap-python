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
%module(directors="0", allprotected="1") ap

%{
#include <ap.h>
%}

%include std_string.i

enum AP_MOD{
  mNONE,       /* nothing special */
  mSCALE,      /* scale it after reading */
  mOFFSET,     /* add an offset */
  mINVERT,     /* save 1 / the number */
  mPOSITIVE,   /* store absolute value */
  mOCTAL,      /* read the number in octal */
  mHEX         /* read the number in hex */
};

%include "typemaps.i"

class CS {
public:
  enum STRING {_STRING};
  CS(CS::STRING, const std::string& s);

  // status - non-consuming
  unsigned cursor()const	{return _cnt;}
  bool	stuck(unsigned* INOUT)	{bool ok=*last<_cnt; *last=_cnt; return !ok;}
  bool	gotit(unsigned last)	{return last<_cnt;}
	operator bool()const	{return _ok;}

  // get -- non-consuming
  const std::string fullstring()const		{return _cmd;}
  const std::string substr(unsigned i)const {return ((_cmd.length()>=i) ? _cmd.substr(i) : "");}
  const std::string substr(unsigned i, unsigned n)const	{return _cmd.substr(i,n);}
  const std::string tail()const			{return substr(_cnt);}
  char		    peek()const			{return _cmd[_cnt];}

  // status - may consume whitespace only
  bool	      ns_more()const	{return peek()!='\0';}
  bool	      more()		{skipbl(); return ns_more();}
  bool	      is_end()		{return !more();}
  bool	      is_file()		{return (_file && !isatty(fileno(_file)));}
  bool	      is_first_read()const {untested(); return (_line_number == 0);}

  // control
  CS&	      reset(unsigned c=0) {_cnt=c; _ok=true; return *this;}

  // exception handling (ap_error.cc) non-consuming
  CS&	      check(int, const std::string&);
  CS&	      warn(int, unsigned, const std::string&);
  CS&         warn(int i, const std::string& s)	{return warn(i,cursor(), s);}

  // string matching (ap_match.cc) possibly consuming, sets _ok
  CS&	      umatch(const std::string&);
  CS&	      scan(const std::string&);
  std::string last_match()const;
  std::string trimmed_last_match(const std::string& = " ,=;")const;

  // character tests - non-consuming, no _ok
  bool	      match1(char c)const{return (peek()==c);}
  bool	      match1(const std::string& c)const
		{return ns_more() && strchr(c.c_str(),peek());}
  size_t      find1(const std::string& c)const
	{return ((ns_more()) ? c.find_first_of(peek()) : std::string::npos);}
  bool	      is_xdigit()const
		{untested(); return (match1("0123456789abcdefABCDEF"));}
  bool	      is_digit()const	{return (match1("0123456789"));}
  bool	      is_pfloat()const	{return (match1(".0123456789"));}
  bool	      is_float()const	{return (match1("+-.0123456789"));}
  bool	      is_argsym()const	{return (match1("*?$%_&@"));}
  bool	      is_alpha()const	{return !!isalpha(toascii(peek()));}
  bool	      is_alnum()const   {return !!isalnum(toascii(peek()));}
  bool	      is_term(const std::string& t = ",=(){};")
	{char c=peek(); return (c=='\0' || isspace(c) || match1(t));}


public:
  std::string ctos(const std::string& term=",=(){};",
		   const std::string& b="\"'{",
		   const std::string& e="\"'}",
		   const std::string& trap="");
//...
  double      ctof();
  bool	      ctob();
  int	      ctoi();
  unsigned    ctou();
  int	      ctoo();
  int	      ctox();
  double      ctopf()			 {return std::abs(ctof());}

  %rename(myshift) operator>>;
  CS&	      operator>>(bool& INOUT)	 {x=ctob();return *this;}
  CS&	      operator>>(char& INOUT)	 {untested(); x=ctoc();return *this;}
  CS&         operator>>(int& INOUT)	 {x=ctoi();return *this;}
  CS&         operator>>(unsigned& INOUT)	 {x=ctou();return *this;}
  CS&         operator>>(double& INOUT)	 {x=ctof();return *this;}
  CS&	      operator>>(std::string& INOUT) {x=ctos();return *this;}
}; // CS

%pythoncode %{
from .ap import CS
_CS_rshift = dict()
from .ap import _CS_rshift
_CS_rshift[int] = CS.myshift
%}

%extend CS{
%pythoncode %{
	def __repr__(self):
		return "CS("+self.fullstring()+")"
	def stuck_(self, L):
		a, b=self.stuck(L[0])
		L[0]=b
		return a
	def __rshift__(self, b):
		if isinstance(b, list):
			r, x = _CS_rshift[type(b[0])](self, b[0])
			b[0]=x
		else:
			r = _CS_rshift[type(b)](self, b)
		return r;

%}
}



// template <class T>
bool Set(CS& cmd, const std::string& key, bool* INOUT, bool newval);
bool Set(CS& cmd, const std::string& key, double* INOUT, double newval);
bool Set(CS& cmd, const std::string& key, int* INOUT, int newval);

%pythoncode %{
def mySet(cmd, s, L, *args):
  if(isinstance(L, list)):
    a, b = Set(cmd, s, L[0], *args)
    L[0] = b
    return a
  else:
    return Set(cmd, s, L, *args)

%}

/*--------------------------------------------------------------------------*/

//%include "typemaps.i"
bool Get(CS& cmd, const std::string&, bool* INOUT);
bool Get(CS& cmd, const std::string&, int* INOUT,    AP_MOD=mNONE, int=0);
bool Get(CS& cmd, const std::string&, double* INOUT, AP_MOD, double=0.);


%pythoncode %{

_getD = dict()
_getD[int] = Get
_getD[float] = Get
_getD[bool] = Get

def _chooseGet(*args):
   return _getD[type(args[2])](*args)

def myGet(cmd, s, L, *args):
  if(isinstance(L, list)):
    a, b = _chooseGet(cmd, s, L[0], *args)
    L[0] = b
    return a
  else:
    return _chooseGet(cmd, s, L, *args)
%}



%pythoncode %{
from .ap import CS
%}

// vim:ts=8:sw=2
