# (C) 2018 Felix Salfelder
# GPLv3
#
# this is part of gnucap-python

import gnucap, os, sys
from gnucap import command, parse

f=open("crash.sp", "w")
f.write("spice\n")
f.write(".subckt a 1 2 3\n")
f.write("r1 1 2 3\n")
f.write(".ends\n")
f.close()

command("get crash.sp")

os.remove("crash.sp")

parse("X1 1 3 4 a")

command("list")

print("end of crashtest")
