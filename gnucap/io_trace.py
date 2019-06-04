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
