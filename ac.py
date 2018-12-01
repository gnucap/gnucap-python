# simoverride unit test
#
# Copyright 2018 Felix Salfelder
# Author: Felix Salfelder
#
# inspired by "custom_ac.py" 2009-2011 Henrik Johansson

from __future__ import print_function

import os
import numpy as np
import gnucap

gnucap.command("set trace")
gnucap.command("set lang=acs")

## Set gnucap run mode
runmode = gnucap.SET_RUN_MODE(gnucap.rBATCH)

gnucap.command("set lang=spice")
gnucap.parse("Vin 1 0 dc 0 ac 1.0")
gnucap.parse("R1 1 2 1e3")
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
        self.mysolve()

        self.outdata(freq, 2)

        acx.unallocate();
        self.sim_().unalloc_vectors()

    def mysolve(self):
        acx = self.sim_()._acx
        acx.zero()
        card_list = gnucap.CARD_LIST().card_list_()

        n = self.sim_()._total_nodes
        print("numnodes: "+ str(n))

#        gnucap.set_complex_array(gnucap.cvar.SIM_ac, np.zeros(n, dtype=np.complex))

        for a in range(3):
           for b in range(3):
              assert(self.sim_()._acx[a][b]==0.)


        card_list.do_ac()
        card_list.ac_load()
        print(self.sim_()._acx)
        print("M", self.sim_()._acx[0][0], self.sim_()._acx[0][1], self.sim_()._acx[0][2])
        print("M", self.sim_()._acx[1][0], self.sim_()._acx[1][1], self.sim_()._acx[1][2])
        print("M", self.sim_()._acx[2][0], self.sim_()._acx[2][1], self.sim_()._acx[2][2])

        print("Loaded AC-matrix") # , gnucap.get_complex_array(gnucap.cvar.SIM_ac, n)

#        print gnucap.bsmatrix_to_array_c(acx)

        ## Solve
        acx.lu_decomp()
        print("decomp")
        acx.fbsub_(self.sim_()._ac)
        print("fbsubt")

        # print("rhs after", self.sim_()._ac[0])
        # print "rhs after", gnucap.get_complex_array(gnucap.cvar.SIM_ac, n)


    def setup(self, cmd):
        pass
    def sweep(self):
        pass


myac = MyAC()
d0=gnucap.install_command("myac", myac)
d1=gnucap.install_command("ac", myac)

gnucap.command("op")

gnucap.command("store ac vm(2)")
gnucap.command("print ac vm(2)")
gnucap.command("myac")

w = gnucap.CKT_BASE_find_wave("vm(2)")

#w=w.begin()
#print(next(w))

for i,k in enumerate(w):
    print(i,k)

# vim:et
