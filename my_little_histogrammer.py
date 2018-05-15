import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import matplotlib.pyplot as plt
import sys

def ROIhistoCreator(filename):

	file = open(filename, 'r')

	xbin = []

	pHisto = []
	pHistostd = []
	pDPHisto = []
	pDPHistostd = []
	phHisto = []
	phHistostd = []
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
					pHisto.append(float(i.split('\r\n')[0]))
				elif goodbye_counter == 1 and hello_counter == 1:
					pHistostd.append(float(i.split('\r\n')[0]))
				
				elif goodbye_counter == 2 and hello_counter == 1:
					pDPHisto.append(float(i.split('\r\n')[0]))
				elif goodbye_counter == 2 and hello_counter == 2:
					pDPHistostd.append(float(i.split('\r\n')[0]))
				
				elif goodbye_counter == 3 and hello_counter == 2:
					phHisto.append(float(i.split('\r\n')[0]))
				elif goodbye_counter == 3 and hello_counter == 3:
					phHistostd.append(float(i.split('\r\n')[0]))
				
				elif goodbye_counter == 4 and hello_counter == 3:
					phDPHisto.append(float(i.split('\r\n')[0]))
				elif goodbye_counter == 4 and hello_counter == 4:
					phDPHistostd.append(float(i.split('\r\n')[0]))

	return xbin, pHisto, pHistostd, pDPHisto, pDPHistostd, phHisto, phHistostd, phDPHisto, phDPHistostd

def Harry_Plotter(ROI, organ, fs1 = 20, fs2 = 20, xlims = [0, 0]):
	# plt.plot(ROI[0], np.array(ROI[index])/float(max(list(ROI[index]))), '-%s' %color, label = organ, linewidth=2)

	# plt.plot(ROI[0], (np.array(ROI[index]) + np.array(ROI[index + 1]))/float(max(list(ROI[index]))), '--%s' %color)
	# plt.plot(ROI[0], (np.array(ROI[index]) - np.array(ROI[index + 1]))/float(max(list(ROI[index]))), '--%s' %color)
	index_list = [1, 3, 5, 7]
	color_list = ['g', 'r', 'k', 'b']
	label_list = ['Proton', 'Proton DPBN', 'Photon', 'Photon DPBN']

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
	plt.legend()

	if xlims != [0, 0]:
		plt.xlim(xlims)

	plt.savefig('../Figurer/DVH_%s.png' %organ)



	# plt.plot(ROI[0], np.array(ROI[1]), '-r', label = Proton, linewidth=2)
	# plt.plot(ROI[0], np.array(ROI[3]), '-b', label = Proton DPBN, linewidth=2)
	# plt.plot(ROI[0], np.array(ROI[5]), '-g', label = Photon, linewidth=2)
	# plt.plot(ROI[0], np.array(ROI[7]), '-k', label = Photon DPBN, linewidth=2)


	# plt.plot(ROI[0], np.array(ROI[index]), '-%s' %color, label = organ, linewidth=2)

	# plt.plot(ROI[0], (np.array(ROI[1]) + np.array(ROI[index + 1])), '--%s' %color)
	# plt.plot(ROI[0], (np.array(ROI[1]) - np.array(ROI[index + 1])), '--%s' %color)



##############################
#######      OARs      #######   
##############################


# filename1 = "../Txt/DVHfor_IpsibasedOn_10_patients.txt"
# filename2 = "../Txt/DVHfor_ContbasedOn_10_patients.txt"
# filename3 = "../Txt/DVHfor_SpinalCordbasedOn_10_patients.txt"

# ROI1 = ROIhistoCreator(filename1)
# ROI2 = ROIhistoCreator(filename2)
# ROI3 = ROIhistoCreator(filename3)


# p1 = plt.figure()
# Harry_Plotter(ROI1, 'Ipsilateral')

# p2 = plt.figure()
# Harry_Plotter(ROI2, 'Contralateral')

# p3 = plt.figure()
# Harry_Plotter(ROI3, 'SpinalCord')

# plt.show()

##############################
#######      GTV       #######   
##############################

filename4 = "../Txt/DVHfor_GTV68basedOn_10_patients.txt"
ROI4 = ROIhistoCreator(filename4)
p4 = plt.figure()
Harry_Plotter(ROI4, 'GTV68', xlims = [50, 100])

##############################
#######      GTV       #######   
##############################

filename5 = "../Txt/DVHfor_CTV64_eks_5mmbasedOn_10_patients.txt"
ROI5 = ROIhistoCreator(filename5)
p5 = plt.figure()
Harry_Plotter(ROI5, 'CTV64', xlims = [40, 80])


filename6 = "../Txt/DVHfor_CTV54_eks_5mmbasedOn_10_patients.txt"
ROI6 = ROIhistoCreator(filename6)
p6 = plt.figure()
Harry_Plotter(ROI6, 'CTV54', xlims = [40, 80])


plt.show()