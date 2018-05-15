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
		self.normal = [0 for i in range(0, n)]


		for i in range(0, len(self.phDP)):
			self.phDP[i]  = np.zeros((self.size[i][0], self.size[i][1]))
			self.pDP[i]   = np.zeros((self.size[i][0], self.size[i][1]))
			self.presc[i] = np.zeros((self.size[i][0], self.size[i][1]))
			self.normal[i] = np.zeros((self.size[i][0], self.size[i][1]))


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
						NormalC = 0
						xcounter = 0
						ycounter = 0

					if (line_split[i].split('\r\n'))[0] == 'Normal:':
						presC = 0
						phC = 0
						pC = 0
						NormalC = 1
						xcounter = 0
						ycounter = 0

					if (line_split[i].split('\r\n'))[0] == 'Translated:':
						presC = 1
						phC = 0
						pC = 0
						NormalC = 0
						xcounter = 0
						ycounter = 0

					if (line_split[i].split('\r\n'))[0] == 'ShrunknShift:':
						presC = 0
						phC = 1
						pC = 0	
						NormalC = 0
						xcounter = 0
						ycounter = 0

					if (line_split[i].split('\r\n'))[0] == 'Shrunk:':
						presC = 0
						phC = 0
						pC = 1
						NormalC = 0
						xcounter = 0
						ycounter = 0

					if NormalC == 1 and (line_split[i].split('\r\n'))[0] != 'Normal:':
						self.normal[patC][xcounter, ycounter] = (float((line_split[i].split('\r\n'))[0]))
					
						if xcounter < self.size[patC][0] - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == self.size[patC][1]:
							xcounter = 0
							ycounter = 0



					if presC == 1 and (line_split[i].split('\r\n'))[0] != 'Translated:':
						self.presc[patC][xcounter, ycounter] = (float((line_split[i].split('\r\n'))[0]))
					
						if xcounter < self.size[patC][0] - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == self.size[patC][1]:
							xcounter = 0
							ycounter = 0

					elif phC == 1 and (line_split[i].split('\r\n'))[0] != 'ShrunknShift:':
						self.phDP[patC][xcounter, ycounter] = (float((line_split[i].split('\r\n'))[0]))
					
						if xcounter < self.size[patC][0] - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == self.size[patC][1]:
							xcounter = 0
							ycounter = 0

					elif pC == 1 and (line_split[i].split('\r\n'))[0] != 'Shrunk:':
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


a = ReadernPlotter('../Txt/MCsnittSize_for_10_patients.txt')
a.Reader('../Txt/ShrunkSnitt_for_10_patients.txt')


plt.figure()
c1 = plt.pcolor(a.presc[0], cmap = 'hot', vmin = 0)
#cbar1 = plt.colorbar(c1)
#plt.title('Translated')
plt.xticks([])
plt.yticks([])
plt.ylim([0, 169])
plt.xlim([0, 99])
plt.savefig('../Figurer/Trans.png')

plt.figure()
c2 = plt.pcolor(a.pDP[0], cmap = 'hot')
#cbar2 = plt.colorbar(c2)
#plt.title('Shrunk')
plt.xticks([])
plt.yticks([])
plt.ylim([0, 169])
plt.xlim([0, 99])
plt.savefig('../Figurer/Shrunk.png')

plt.figure()
c3 = plt.pcolor(a.phDP[0], cmap = 'hot')
#cbar3 = plt.colorbar(c3)
#plt.title('Shrunk and shifted back')
plt.xticks([])
plt.yticks([])
plt.ylim([0, 169])
plt.xlim([0, 99])
plt.savefig('../Figurer/ShrunknShift.png')

# plt.figure()
# c3 = plt.pcolor(a.normal[0], cmap = 'hot', vmin = 0.8)
# cbar3 = plt.colorbar(c3)
# plt.title('Normal')
# plt.xticks([])
# plt.yticks([])
# plt.ylim([0, 169])
# plt.xlim([0, 99])

#plt.show()