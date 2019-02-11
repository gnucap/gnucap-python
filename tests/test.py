#import libgnucap

import gnucap



gnucap.command("print dc hidden(0)")
gnucap.command("print tran hidden(0)")
gnucap.command("dc trace=i")
gnucap.command("dc trace=i")
gnucap.command("ac")
gnucap.command("op")
gnucap.command("transient 0 1 1")
gnucap.command("error") # BUG
gnucap.command("status notime")
