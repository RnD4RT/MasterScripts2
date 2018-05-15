import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.font_manager import FontProperties
from matplotlib import cm
import matplotlib.pyplot as plt
import sys


class ReadnPlot:

	def Reader(self, filename, NumberOfPatients = 10, n = 4):

		self.store_matrix = [[0 for i in range(0, n)] for j in range(0, NumberOfPatients)]
		self.patients = ['Patient ' for i in range(0, NumberOfPatients)]
		self.NumberOfPatients = NumberOfPatients

		counter = -5
		index = -1

		file = open(filename, 'r')
		for line in file:
			line_list = (line.split(' '))

			for i in line_list:
				if i != '':
					if i == 'Patient':
						counter = -1
						continue
					
					if counter >= 0:
						#print index - 1, counter, i
						self.store_matrix[index][counter] = float(i)
						counter += 1

					if counter == -1:
						index += 1

						self.patients[index] += '%d' %int(i)
						counter += 1

		if self.patients[-1] == 'Patient 11':
			self.patients[-1] = 'Patient 10'
		#print self.store_matrix, self.patients

	def Sorter(self):
		self.ph = []
		self.phDP = []
		self.p = []
		self.pDP = []


		for i in self.store_matrix:
			self.ph.append(i[0])
			self.phDP.append(i[1])
			self.p.append(i[2])
			self.pDP.append(i[3])

	def Plotter(self):
		return 10

	def LatexTable(self):
		
		if self.ph == []:
			print "Run Sorter first!"
			sys.exit()

		print "\\textbf{Patient}   & \\textbf{Photon} & \\textbf{Photon DPBN} & \\textbf{Proton} & \\textbf{Proton DPBN}  \\\\  \\noalign{\\hrule height 1.5pt}"
		for i in range(0, self.NumberOfPatients - 1):
			print "%s & %1.2f & %1.2f & %1.2f & %1.2f \\\\ \\hline" %(self.patients[i],
						self.ph[i], self.phDP[i], self.p[i], self.pDP[i])
		print "%s & %1.2f & %1.2f & %1.2f & %1.2f \\\\ \\noalign{\\hrule height 1.5pt}" %(
						self.patients[-1], self.ph[-1], self.phDP[-1], self.p[-1], self.pDP[-1])
		print "\\textbf{Total Mean Value} & %1.2f $\pm$ %1.2f & %1.2f $\pm$ %1.2f & %1.2f $\pm$ %1.2f & %1.2f $\pm$ %1.2f" %(
			np.mean(self.ph), np.std(self.ph), np.mean(self.phDP), np.std(self.phDP), 
			np.mean(self.p), np.std(self.p), np.mean(self.pDP), np.std(self.pDP))


# a = ReadnPlot()
# a.Reader('../Txt/NTCPfor_Ipsi_basedOn_9_patients.txt', NumberOfPatients = 9)
# a.Sorter()
# a.LatexTable()

# b = ReadnPlot()
# b.Reader('../Txt/NTCPfor_Cont_basedOn_9_patients.txt', NumberOfPatients = 9)
# b.Sorter()
# b.LatexTable()


reocc = [2, 5, 6]

TCP68 = ReadnPlot()
TCP68.Reader('../Txt/TCP68_basedOn_10_patients.txt', n = 1)
j_switch = 0
reocc_counter = 0

reocc_mean   = 0
success_mean = 0

fig, ax = plt.subplots()
for i in range(0, len(TCP68.store_matrix)):
	for j in reocc:
		if i + 1 == j:
			j_switch = 1
			reocc_counter += 1
	if j_switch == 1:
		ax.plot(1, TCP68.store_matrix[i], 'o',label = '%s' %TCP68.patients[i])
		reocc_mean += TCP68.store_matrix[i][0]
	else:
		ax.plot(0, TCP68.store_matrix[i], 'o',label = '%s' %TCP68.patients[i])
		success_mean += TCP68.store_matrix[i][0]
	j_switch = 0

ax.plot(np.linspace(0.95, 1.05, 3), 
	[reocc_mean/float(reocc_counter) for i in range(0, 3)],
	 '-k', linewidth = 1.5, label = 'Mean')
ax.plot(np.linspace(-0.05, 0.05, 3), 
	[success_mean/float(len(TCP68.store_matrix) - reocc_counter) for i in range(0, 3)], 
	'-k', linewidth = 1.5)

# Shrink current axis by 20%
box = ax.get_position()
ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
ax.legend(loc='center left', bbox_to_anchor=(1, 0.5), numpoints=1)

plt.xticks(np.arange(0, 1, step = 1))
plt.xticks(np.arange(2), ('Successful', 'Recurrence'), fontsize = 16)
plt.yticks(fontsize = 16)

plt.title(r'$TCP_{2Gy}$', fontsize = 20)
plt.xlim([-0.2, 1.2])
plt.ylim([0, 1.1])
plt.ylabel('TCP', fontsize = 20)
plt.savefig('../Figurer/TCP68.png')




TCPPres = ReadnPlot()
TCPPres.Reader('../Txt/TCPpres_basedOn_10_patients.txt', n = 1)
j_switch = 0
reocc_counter = 0

reocc_mean   = 0
success_mean = 0

fig2, ax2 = plt.subplots()
for i in range(0, len(TCPPres.store_matrix)):
	for j in reocc:
		if i + 1 == j:
			j_switch = 1
			reocc_counter += 1

	if j_switch == 1:	
		ax2.plot(1, np.array(TCPPres.store_matrix[i]) - np.array(TCP68.store_matrix[i]), 'o',label = '%s' %TCPPres.patients[i])
		reocc_mean += np.array(TCPPres.store_matrix[i]) - np.array(TCP68.store_matrix[i])[0]
	else:
		ax2.plot(0, np.array(TCPPres.store_matrix[i]) - np.array(TCP68.store_matrix[i]), 'o',label = '%s' %TCPPres.patients[i])
		success_mean += np.array(TCPPres.store_matrix[i]) - np.array(TCP68.store_matrix[i])[0]
	j_switch = 0

ax2.plot(np.linspace(0.95, 1.05, 3), 
	[reocc_mean/float(reocc_counter) for i in range(0, 3)],
	 '-k', linewidth = 1.5, label = 'Mean')
ax2.plot(np.linspace(-0.05, 0.05, 3), 
	[success_mean/float(len(TCPPres.store_matrix) - reocc_counter) for i in range(0, 3)], 
	'-k', linewidth = 1.5)

# Shrink current axis by 20%
box = ax2.get_position()
ax2.set_position([box.x0, box.y0, box.width * 0.8, box.height])
ax2.legend(loc='center left', bbox_to_anchor=(1, 0.5), numpoints=1)

plt.xticks(np.arange(0, 1, step = 1))
plt.xticks(np.arange(2), ('Successful', 'Recurrence'), fontsize = 16)
plt.yticks(fontsize = 16)

plt.title(r'$TCP_{pres} - TCP_{2Gy}$', fontsize = 20)
plt.xlim([-0.2, 1.2])
plt.ylim([0, 1.1])
plt.ylabel('TCP', fontsize = 20)
plt.savefig('../Figurer/DeltaTCP68.png')
plt.show()