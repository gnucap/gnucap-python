
from gnucap import PARAMETERi, PARAMETERd, Get_, CS, Get

key="k"

ppp = PARAMETERd()
print("ppp", ppp)
print("gotit.", type(ppp))

print("====3b")
Cmd = CS(CS._STRING, "k=true")

a = False
L = [a]
r = Get_(Cmd, key, L)
assert(r)
assert(L[0]==True)


print("====bool")
Cmd = CS(CS._STRING, "k=0")

a = True
r = Get_(Cmd, key, a)
print(r)

print("====int")
Cmd = CS(CS._STRING, "k=1")

a = 2
r = Get_(Cmd, key, a)
print(r)

print("====intlist")
Cmd = CS(CS._STRING, "k=0")

a = 2
L = [a]
r = Get_(Cmd, key, L)
print(r, L)
assert(L[0]==0)



print("====0")

pd = PARAMETERd(0.)
assert(pd==0)
Cmd = CS(CS._STRING, "k=1.")
r, s=Get_(Cmd, key, pd)
assert(pd==1)

print(pd<=3.)

print("====")
pd = PARAMETERd()
L=[pd]
Cmd = CS(CS._STRING, "k=1.")
r=Get_(Cmd, key, L)
assert(r)
assert(L[0]==1)

print(pd<=3.)
print("====2")

a = PARAMETERi()
print(a>3)
Cmd = CS(CS._STRING, "k=1")

r = Get_(Cmd, "k", a)
print("?", r)

print("====4")

from gnucap import mNONE
L=[3.]
Cmd = CS(CS._STRING, "k=5.")
r = Get_(Cmd, key, L, mNONE)
assert(r)
assert(L[0]==5.)

print("====5")
Cmd = CS(CS._STRING, "k=-.1")

p = PARAMETERd()
sip=[p]

print(Cmd.tail(), "....")
r = Get_(Cmd, "k", sip)
print(r)
print(sip[0])
