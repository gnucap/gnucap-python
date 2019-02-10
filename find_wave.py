# Copyright (C) 2019 Felix Salfelder
# Author: Felix Salfelder <felix@salfelder.org>

import gnucap

print("testing key error")

gnucap.command("op")
try:
	gnucap.CKT_BASE_find_wave("doesntexist")
	print("FAIL")
except KeyError as e:
	print("OK, KeyError", e)

print("DONE")
