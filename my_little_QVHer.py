import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import matplotlib.pyplot as plt
import sys

def ROIhistoCreator(filename):

	file = open(filename, 'r')

	xbin = []

	pDPHisto = []
	pDPHistostd = [] 
	phDPHisto = []
	phDPHistostd = []

	hello_counter = 0
	goodbye_counter = 0

	for line in file:
		line_list = line.split(' ')

		del_indexes = []
		for i in line_list:
			if i != '':
				if i.split('\r\n')[0] == 'Goodbye':
					goodbye_counter += 1
					continue
				elif i.split('\r\n')[0] == 'Hello':
					hello_counter += 1
					continue

				if hello_counter == 0 and goodbye_counter == 0:
					xbin.append(float(i.split('\r\n')[0]))
				elif goodbye_counter == 1 and hello_counter == 0:
					pDPHisto.append(float(i.split('\r\n')[0]))
				elif goodbye_counter == 1 and hello_counter == 1:
					pDPHistostd.append(float(i.split('\r\n')[0]))
				
				elif goodbye_counter == 2 and hello_counter == 1:
					phDPHisto.append(float(i.split('\r\n')[0]))
				elif goodbye_counter == 2 and hello_counter == 2:
					phDPHistostd.append(float(i.split('\r\n')[0]))
				
	return xbin, pDPHisto, pDPHistostd, phDPHisto, phDPHistostd

def Harry_Plotter(ROI, organ, fs1 = 20, fs2 = 20):
	# plt.plot(ROI[0], np.array(ROI[index])/float(max(list(ROI[index]))), '-%s' %color, label = organ, linewidth=2)

	# plt.plot(ROI[0], (np.array(ROI[index]) + np.array(ROI[index + 1]))/float(max(list(ROI[index]))), '--%s' %color)
	# plt.plot(ROI[0], (np.array(ROI[index]) - np.array(ROI[index + 1]))/float(max(list(ROI[index]))), '--%s' %color)
	index_list = [1, 3]
	color_list = ['r', 'b']
	label_list = ['Proton DPBN', 'Photon DPBN']

	for i in range(0, len(index_list)):
		color = color_list[i]
		plan = label_list[i]
		index = index_list[i]

		plt.plot(ROI[0], np.array(ROI[index]), '-%s' %color, label = plan, linewidth=2)
		
		posSTD = np.array(ROI[index]) + np.array(ROI[index + 1])
		negSTD = np.array(ROI[index]) - np.array(ROI[index + 1])
		for j in range(0, len(posSTD)):
			if posSTD[j] > 1:
				posSTD[j] = 1
			elif posSTD[j] < 0:
				posSTD[j] = 0

			if negSTD[j] > 1:
				negSTD[j] = 1
			elif negSTD[j] < 0:
				negSTD[j] = 0


		plt.plot(ROI[0], posSTD, '--%s' %color)
		plt.plot(ROI[0], negSTD, '--%s' %color)

	#plt.title('%s' %organ, fontsize = fs1)
	plt.xlabel('Dose [Gy]', fontsize = fs2)
	plt.ylabel('Relative Volume', fontsize = fs2)
	plt.xlim([0.8, 1.2])
	plt.legend()

	plt.savefig('../Figurer/QVH_%s.png' %organ)


filename1 = "../Txt/QVH_basedOn_10_patients.txt"


ROI1 = ROIhistoCreator(filename1)

p1 = plt.figure()
Harry_Plotter(ROI1, 'GTV')

minimum95 = 1000
minimum105 = 1000
minimum95_index = 0
minimum105_index = 0




for i in range(0, len(ROI1[0])):
	if (ROI1[0][i] - 0.95)**2 < minimum95:
		minimum95 = (ROI1[0][i] - 0.95)**2 
		minimum95_index = i

	if (ROI1[0][i] - 1.05)**2 < minimum105:
		minimum105 = (ROI1[0][i] - 1.05)**2
		minimum105_index = i

print "Proton DPBN V_95 = %1.3f $\\pm$ %1.3f" %(ROI1[1][minimum95_index], 
													ROI1[2][minimum95_index])
print "Photon DPBN V_95 = %1.3f $\\pm$ %1.3f" %(ROI1[3][minimum95_index], 
													ROI1[4][minimum95_index])
print "Proton DPBN V_105 = %1.3f $\\pm$ %1.3f" %(ROI1[1][minimum105_index], 
													ROI1[2][minimum105_index])
print "Photon DPBN V_105 = %1.3f $\\pm$ %1.3f" %(ROI1[3][minimum105_index], 
													ROI1[4][minimum105_index])


#plt.show()