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

class CS {
public:
  enum STRING {_STRING};
  CS(CS::STRING, const std::string& s);
  const std::string fullstring()const;

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
};

%pythoncode %{
from .ap import CS
%}

// vim:ts=8:sw=2
