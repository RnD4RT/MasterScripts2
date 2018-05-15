import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.gridspec import GridSpec
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import sys

class ReadernPlotter:
	def __init__(self, filename1, n = 10):
		file = open(filename1, 'r')
		self.size = [[] for i in range(0, n)]

		counter = 0

		for line in file:
			for i in line.split(' '):
				if i != '':
					self.size[counter].append(int((i.split('\r\n'))[0]))
			
			counter += 1
		
		print self.size


		self.phDP = [0 for i in range(0, n)]
		self.pDP  = [0 for i in range(0, n)]
		self.presc = [0 for i in range(0, n)]


		for i in range(0, len(self.phDP)):
			self.phDP[i]  = np.zeros((self.size[i][0], self.size[i][1]))
			self.pDP[i]   = np.zeros((self.size[i][0], self.size[i][1]))
			self.presc[i] = np.zeros((self.size[i][0], self.size[i][1]))


		# self.phDP = np.zeros((self.shrink_len, self.avg_mov_len))
		# self.pDP  = [[] for i in range(0, n)]
		# self.presc = [[] for i in range(0, n)]
		# self.size = [[] for i in range(0, n)]
		# self.n = n




	def Reader(self, filename):
		file = open(filename, 'r')

		phC = 0
		pC = 0
		presC = 0
		sizeC = 0
		patC = -1

		for line in file:
			line_split = line.split(' ')
			for i in range(0, len(line_split)):
				if line_split[i] != '':
					if line_split[i] == 'Patient':
						print line_split[i] + (line_split[i + 1].split('\r\n'))[0]
						patC += 1
						presC = 0
						phC = 0
						pC = 0
						xcounter = 0
						ycounter = 0

					if (line_split[i].split('\r\n'))[0] == 'Presc:':
						presC = 1
						phC = 0
						pC = 0
						xcounter = 0
						ycounter = 0

					if (line_split[i].split('\r\n'))[0] == 'Photon:':
						presC = 0
						phC = 1
						pC = 0	
						xcounter = 0
						ycounter = 0

					if (line_split[i].split('\r\n'))[0] == 'Proton:':
						presC = 0
						phC = 0
						pC = 1
						xcounter = 0
						ycounter = 0


					if presC == 1 and (line_split[i].split('\r\n'))[0] != 'Presc:':
						self.presc[patC][xcounter, ycounter] = (float((line_split[i].split('\r\n'))[0]))
					
						if xcounter < self.size[patC][0] - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == self.size[patC][1]:
							xcounter = 0
							ycounter = 0

					elif phC == 1 and (line_split[i].split('\r\n'))[0] != 'Photon:':
						self.phDP[patC][xcounter, ycounter] = (float((line_split[i].split('\r\n'))[0]))
					
						if xcounter < self.size[patC][0] - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == self.size[patC][1]:
							xcounter = 0
							ycounter = 0

					elif pC == 1 and (line_split[i].split('\r\n'))[0] != 'Proton:':
						self.pDP[patC][xcounter, ycounter] = (float((line_split[i].split('\r\n'))[0]))
					
						if xcounter < self.size[patC][0] - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == self.size[patC][1]:
							xcounter = 0
							ycounter = 0
					elif pC == 1 and phC == 1 or pC == 1 and presC == 1 or phC == 1 and presC == 1:
						print "Stuff is wrong"






firstTest = ReadernPlotter('../Txt/MCsnittSize_for_10_patients.txt')
firstTest.Reader('../Txt/MCsnitt_for_10_patients.txt')

colors = [(0, 0, 0), (1, 0, 0), (1, 1, 0), (1, 1, 1)]  # Black -> Red -> Yellow -> White
cm = LinearSegmentedColormap.from_list(
        'Eiriks CM', colors, N=16)
fs1 = 20


for index in range(0, 10):
	plt.figure(figsize = [21, 7])
	gs = GridSpec(1, 3)


	ind_val = np.argwhere(firstTest.presc[index] > 68.01)

	ymin = 10000
	ymax = 0
	xmin = 10000
	xmax = 0
	for i in ind_val:
		if i[0] < xmin:
			xmin = i[0]
		if i[1] < ymin:
			ymin = i[1]
		if i[0] > xmax:
			xmax = i[0]
		if i[1] > ymax:
			ymax = i[1]

	if xmax - xmin > ymax - ymin:
		ymax = int(np.ceil((ymax + ymin)/2. + (xmax - xmin)/2.))
		ymin = int(np.floor((ymax + ymin)/2. - (xmax - xmin)/2.))

		if ymax - ymin != xmax - xmin:
			print "Different dim size"
			ymax += 1
			ymin -= 1


	else:
		xmax = int(np.ceil((xmax + xmin)/2. + (ymax - ymin)/2.))
		xmin = int(np.floor((xmax + xmin)/2. - (ymax - ymin)/2.))

		if xmax - xmin != ymax - ymin:
			print "Different dim size"
			xmax += 1


	box_extra = 5
	print ((firstTest.presc[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra]).shape




	maxdose = np.max([np.max(firstTest.presc[index]), np.max(firstTest.phDP[index]), np.max(firstTest.pDP[index])])

	plt.subplot(gs[0, 0])
	c1 = plt.pcolor((firstTest.presc[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra],
					 cmap = cm, vmin = 68, vmax = maxdose)
	cbar = plt.colorbar(c1)
	plt.xlim([0, ((firstTest.presc[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra]).shape[0]])
	plt.ylim([0, ((firstTest.presc[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra]).shape[1]])
	plt.xticks([])
	plt.yticks([])
	plt.title('Prescribed DPBN', fontsize = fs1)

	plt.subplot(gs[0, 1])
	c2 = plt.pcolor((firstTest.phDP[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra], 
					 cmap = cm, vmin = 68, vmax = maxdose)
	cbar2 = plt.colorbar(c2)
	plt.xlim([0, ((firstTest.presc[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra]).shape[0]])
	plt.ylim([0, ((firstTest.presc[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra]).shape[1]])
	plt.xticks([])
	plt.yticks([])
	plt.title('Photon DPBN', fontsize = fs1)

	plt.subplot(gs[0, 2])
	c3 = plt.pcolor((firstTest.pDP[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra],
					 cmap = cm, vmin = 68, vmax = maxdose)
	cbar3 = plt.colorbar(c3)

	plt.xlim([0, ((firstTest.presc[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra]).shape[0]])
	plt.ylim([0, ((firstTest.presc[index])[xmin- box_extra:xmax + box_extra, ymin - box_extra:ymax + box_extra]).shape[1]])
	plt.xticks([])
	plt.yticks([])
	plt.title('Proton DPBN', fontsize = fs1)



	plt.savefig('../Figurer/PlanColor_%d.png' %index)
#plt.show()