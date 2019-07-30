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
import sys
import traceback

def untested():
	s = traceback.extract_stack(limit=2)
	s.pop()
	a = s.pop()
	print("@@#", file=sys.stderr)
	print("@@@", a[0]+ ":"+str(a[1])+":"+a[2], file=sys.stderr)

def itested():
	return
	s = traceback.extract_stack(limit=2)
	s.pop()
	a = s.pop()
	print("@@#", file=sys.stderr)
	print("@@@: ", a[0]+ ":"+str(a[1])+":"+a[2], file=sys.stderr)

def incomplete():
	s = traceback.extract_stack(limit=2)
	s.pop()
	a = s.pop()
	print("@@#", file=sys.stderr)
	print("@@@:", file=sys.stderr)
	print("incomplete", a[0]+ ":"+str(a[1])+":"+a[2], file=sys.stderr)

def unreachable():
	s = traceback.extract_stack(limit=2)
	s.pop()
	a = s.pop()
	print("@@#", file=sys.stderr)
	print("@@@:", file=sys.stderr)
	print("unreachable", a[0]+ ":"+str(a[1])+":"+a[2], file=sys.stderr)
