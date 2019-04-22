#!/usr/bin/env python3
# some data parsing. Felix Salfelder 2019, GPLv3+
# see main section below for example use

from __future__ import print_function

class datafile_by_index:
	def __init__(self, fn, indexlist=None):
		self._f = open(fn, "r")
		self._i = indexlist
		self._s = next(self._f)

		keys = []
		if(indexlist is None):
			self._i = self._s[:-1].split()

		if(self._s[0]=='#'):
			keys = self._s[:-1].split()
		
		for i,k in enumerate(self._i):
			if type(k)==str:
				# print(k)
				for j,l in enumerate(keys):
					if l==k:
						self._i[i]=j
						break;

		self._headers = [ keys[x] for x in self._i ]

	def headers(self):
		return self._headers

	def __iter__(self):
		return self

	def next(self):
		return self.__next__()

	def __next__(self):
		self._s = next(self._f)
		while(self._s[0]=='#'):
			self._s = next(self._f)
		v = self._s.split()
		x = []

		try:
			for i in self._i:
				x.append(float(v[i]))
		except:
			print("ERROR", self._s, self._i)
			raise

		return x


if __name__=="__main__":
	"""
	testing dataparse. put something like

	#key value1 value2 value3
	1 1.1 1.2 1.3
	2 2.1 2.2 2.3
	3 3.1 3.2 3.3
	4 4.1 4.2 4.3

	into file.out.  will print something like
	headers: ['#key', 'value1', 'value2', 'value3']
	[1.0, 1.1, 1.2, 1.3]
	[2.0, 2.1, 2.2, 2.3]
	[3.0, 3.1, 3.2, 3.3]
	[4.0, 4.1, 4.2, 4.3]
	headers: ['#key', 'value2', 'value3']
	[1.0, 1.2, 1.3]
	[2.0, 2.2, 2.3]
	[3.0, 3.2, 3.3]
	[4.0, 4.2, 4.3]
	"""

	f = datafile_by_index("file.out")
	print("headers:", f.headers())

	for i in f:
		print(i)

	f = datafile_by_index("file.out", ["#key", "value2", "value3"])
	print("headers:", f.headers())
	for i in f:
		print(i)

