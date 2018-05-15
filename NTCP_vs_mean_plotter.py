import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.font_manager import FontProperties
from matplotlib import cm
import matplotlib.pyplot as plt
import sys


class Reader():

	def read(self, filename, n = 9):
		self.n = n
		self.storer = [[] for i in range(0, n)]
		file = open(filename, 'r')

		counter = 0
		patnumb = -1
		for line in file:
			line_list = (line.split(' '))
			for i in line_list:
				if i != '':

					switch = 0
					print i.split('\r\n')[0]
					if i.split('\r\n')[0] == 'Patient':
						counter = 1
						switch = 1

					if counter == 2:
						self.storer[patnumb].append(float(i.split('\r\n')[0]))

					if counter == 1 and switch != 1:
						patnumb += 1
						counter = 2
		return self.storer

					
					


a = Reader()
Ipsi_dose = a.read('../Txt/NTCPfor_Ipsi_basedOn_9_patients.txt')
Cont_dose = a.read('../Txt/NTCPfor_Cont_basedOn_9_patients.txt')
Ipsi_Mean = a.read('../Txt/NTCPMeanDose_for_Ipsi_basedOn_9_patients.txt')
Cont_Mean = a.read('../Txt/NTCPMeanDose_for_Cont_basedOn_9_patients.txt')

plt.plot(Ipsi_Mean[0], Ipsi_dose[0], 'go', label = 'Ipsilateral')
plt.plot(Cont_Mean[0], Cont_dose[0], 'b*', label = 'Contralateral') 

for i in range(1, a.n):
	plt.plot(Ipsi_Mean[i], Ipsi_dose[i], 'go')
	plt.plot(Cont_Mean[i], Cont_dose[i], 'b*') 

plt.yticks(np.linspace(0, 1, 21))
plt.xticks(np.linspace(0, 70, 15))
plt.legend(numpoints = 1, loc = 2)
plt.xlabel('Mean Dose [Gy]', fontsize = 20)
plt.ylabel('NTCP', fontsize = 20)
plt.grid()

plt.savefig('../Figurer/NTCPvsMeanDose.png')

plt.show()