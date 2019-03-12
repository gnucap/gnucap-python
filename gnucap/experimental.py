# Copyright (C) 2018, 2019 Felix Salfelder
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
#------------------------------------------------------------------

from .globals import install_device
from .globals import install_command

from .e_compon import COMPONENT
from .c_comand import CMD

import inspect

class install:
	def __del__(self):
		self.i1=None

	def __init__(self, *argv, **args):
		if(len(argv)>1):
			self.name = argv[0]
			self.i1 = self._install_instance(argv[0], argv[1])
		elif(len(argv)==1):
			if(isinstance(argv[0], type)):
				self.name = None
				self(argv[0])
			else:
				self.name = argv[0]
		elif(len(argv)==0):
			self.name = None

	def _install_instance(self, name, what):
		if(isinstance(what, COMPONENT)):
			return install_device(name, what)
		elif(isinstance(what, CMD)):
			return install_command(name, what)
		else:
			raise TypeError("don't know what this is", inspect.getmro(what.__class__))
	
	def __call__(self, cls):
		cls._hidden_instance = cls()
		if(self.name is None):
			self.name = cls._hidden_instance.dev_type()
		cls.i1 = self._install_instance(self.name, cls._hidden_instance)

		return cls
