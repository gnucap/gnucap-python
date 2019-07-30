# Copyright (C) 2018 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
#---------------------------------------------------------------------
import sys as _s
import traceback as _t

def untested():
	s = _t.extract_stack(limit=2)
	s.pop()
	a = s.pop()
	print("@@#", file=_s.stderr)
	print("@@@", a[0]+ ":"+str(a[1])+":"+a[2], file=_s.stderr)
	_s.stderr.flush()

def itested():
	return
	s = _t.extract_stack(limit=2)
	s.pop()
	a = s.pop()
	print("@@#", file=_s.stderr)
	print("@@@: ", a[0]+ ":"+str(a[1])+":"+a[2], file=_s.stderr)
	_s.stderr.flush()

def incomplete():
	s = _t.extract_stack(limit=2)
	s.pop()
	a = s.pop()
	print("@@#", file=_s.stderr)
	print("@@@:", file=_s.stderr)
	print("incomplete", a[0]+ ":"+str(a[1])+":"+a[2], file=_s.stderr)
	_s.stderr.flush()

def unreachable():
	s = _t.extract_stack(limit=2)
	s.pop()
	a = s.pop()
	print("@@#", file=_s.stderr)
	print("@@@:", file=_s.stderr)
	print("unreachable", a[0]+ ":"+str(a[1])+":"+a[2], file=_s.stderr)
	_s.stderr.flush()

# how to do this properly?!
def trace(string, *args):
	s = _t.extract_stack(limit=2)
	s.pop()
	a = s.pop()
	s=a[3][:-1].split(',')[1:]

	print("@#@%s"% string, file=_s.stderr , end="")
	for k,i in enumerate(args):
		print(" %s=%s" % (s[k],i), end="", file=_s.stderr)
	print(file=_s.stderr)
	_s.stderr.flush()
