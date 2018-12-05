spice
* demo from hspice manual. circulates for ages & considered public domain.
* the level of invention amounts to the spice format adjustments

* run with
* gnucap -b @thisfile@

*>.options trace
*>.attach public c_python.so
*>.attach ./d_brl.so
*>.loadpy pz_spice.py

VIN IN 0 AC 1
*.PZ V(OUT) VIN
*.AC DEC 50 .1K 100K

.SUBCKT OPAMP IN+ IN- OUT
.param GM1=2
.param RI=1K
.param CI=26.6U
.param GM2=1.33333
.param RL=75
RII IN+ IN- 2MEG
RI1 IN+ 0 500MEG
RI2 IN- 0 500MEG
G1 1 0 IN+ IN- {GM1}
C1 1 0 {CI}
R1 1 0 {RI}
G2 OUT 0 1 0 {GM2}
RLD OUT 0 {RL}
.ENDS

.SUBCKT FDNR 1 R1=2K cC1=12N cR4=4.5K cRLX=75
R1 1 2 {R1}
C1 2 3 {C1}
R2 3 4 3.3K
R3 4 5 3.3K
R4 5 6 {R4}
C2 6 0 10N
XOP1 2 4 5 OPAMP
XOP2 6 4 3 OPAMP
.ENDS
*
RS IN 1 5.4779K
R12 1 2 4.44K
R23 2 3 3.2201K
R34 3 4 3.63678K
R45 4 OUT 1.2201K
C5 OUT 0 10N
X1 1 FDNR R1=2.0076K  C1=12N  R4=4.5898K
X2 2 FDNR R1=5.9999K  C1=6.8N R4=4.25725K
X3 3 FDNR R1=5.88327K C1=4.7N R4=5.62599K
X4 4 FDNR R1=1.0301K  C1=6.8N R4=5.808498K

.list

.pz OUT 0 IN 0 cur pz

.end
