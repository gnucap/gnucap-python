# matrix unit tests
#
# Copyright 2018 Felix Salfelder
# Author: Felix Salfelder

from __future__ import print_function

import os
import numpy as np
import gnucap, sys

from scipy.sparse import coo_matrix

def printn(*args, **kwargs):
  for i in args:
    sys.stdout.write(str(i))

gnucap.command("set trace")
gnucap.command("set lang=acs")

## Set gnucap run mode
runmode = gnucap.SET_RUN_MODE(gnucap.rBATCH)

gnucap.command("set lang=spice")
gnucap.parse("Vin 1 0 dc 0 ac 1.0")
gnucap.parse("R1 1 2 1e3")
gnucap.parse("R2 1 3 1e3")
gnucap.parse("C2 1 4 1")
gnucap.parse("R2 2 4 1e3")
gnucap.parse("L2 3 5 1m")
gnucap.parse("C1 2 0 1e-8")
gnucap.command("list")

class MyAC(gnucap.SIM):
    def do_it(self, cmd, scope):
        self._scope = scope
        self.sim_().set_command_ac()
        self.sim_().init()

        self.sim_().alloc_vectors()
        acx = self.sim_()._acx
        acx.reallocate()

        freq = 20e3

        self.sim_()._jomega = 2j * np.pi * freq
        self.head(freq, freq, "Freq")

        card_list = gnucap.CARD_LIST().card_list_()
        card_list.ac_begin()
        acx = self.sim_()._acx
        acx.zero()
        card_list = gnucap.CARD_LIST().card_list_()

        n = self.sim_()._total_nodes

        card_list.do_ac()
        card_list.ac_load()

        M=acx
        for a in range(1+n):
           for b in range(1+n):
              printn(' {:.1g}'.format(M[a][b]))
           print()

        print (M)
        print (M[0][0])
        print("incomplete", M[0])
        print("incomplete", M[0][0:2])
        print(M.data_())
        N = np.array(M)
        print("np", N)

        raw = acx._space()
        print("with gnd", ['{:.2f}'.format(xx) for xx in raw[:5]])

        raw = acx._space(False)
        print("without", raw[:5])

        coo = acx._coord(False)
        print("coo", coo[:5], np.shape(coo));
        assert(np.shape(coo)==(19,2));

        coo_all = acx._coord(True)
        raw_all = acx._space(True)
        coo_allt=coo_all.transpose()
        m_all = coo_matrix((raw_all, coo_allt))
        print(coo_allt[0])
        print(coo_allt[1])
        print(m_all.todense()[0:3])

        if sys.version_info[0] < 3:
           print("too old")
           return

        a=zip(*coo);
        i = next(a)
        j = next(a)

        print("trying coo 1", i[:3], j[:3])
        a = coo_matrix((raw[:3], (i[:3],j[:3])), shape=(4,4))
        print(a.todense())
        print("trying coo 2", i[:3], j[:3])
        print("trying coo 2", len(i), len(j), len(raw))

        coo = acx._coord(False)
        a = zip(*coo);
        i=next(a)
        assert(len(i)==19)
        j=next(a)
        f = coo_matrix((raw, (i,j)))

        print("shape1", f.get_shape())

        coot = acx._coord(False)
        coo = np.transpose(coot)
        print(coo)
        f = coo_matrix((raw, coo))
        g = coo_matrix((raw, zip(*coot)))
        print("shape2", f.get_shape())
        b = f.todense();
        print(b[0,0])
        print(b[1,1])

        print(b[:3,:3])

        acx.unallocate(); # invalidates M
        self.sim_().unalloc_vectors()


    def setup(self, cmd):
        pass
    def sweep(self):
        pass


myac = MyAC()
d0 = gnucap.install_command("myac", myac)

gnucap.command("op")
gnucap.command("myac")

w = gnucap.CKT_BASE_find_wave("vm(2)")

# d0=gnucap.install_command("myac", myac)

# vim:et
