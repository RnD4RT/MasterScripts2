from numpy import *

print "Patient & Plan & QF & TCP & D\_max \\\\ \hline"

c = 3
pat = 1

stringlist = ["Photon \\ac{DPBN}", "Proton", "Proton \\ac{DPBN}"]

for i in range(1, 45):
	if c == 3:
		print "\multirow{4}{*}{Patient %d} & Photon & \\formatNumber{\datacell[%d,1]} & \\formatNumber{\datacell[%d,2]} & \\formatNumber{\datacell[%d,3]} \\\\ \cline {2 - 5}" %(pat, i, i, i)
		c = 0
		pat += 1
	elif c == 2:
		c += 1
		print "& %s & \\formatNumber{\datacell[%d,1]} & \\formatNumber{\datacell[%d,2]} & \\formatNumber{\datacell[%d,3]} \\\\ \hline" %(stringlist[c-1], i, i, i)
	else:
		c += 1
		print "& %s & \\formatNumber{\datacell[%d,1]} & \\formatNumber{\datacell[%d,2]} & \\formatNumber{\datacell[%d,3]} \\\\ \cline {2 - 5}" %(stringlist[c-1], i, i, i)