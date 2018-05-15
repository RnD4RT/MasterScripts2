import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.gridspec import GridSpec
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import sys


class ReadernPlotter:
	def __init__(self, n = 10):

		self.phDP  = [[] for i in range(0, n)]
		self.pDP   = [[] for i in range(0, n)]
		self.presc = [[] for i in range(0, n)]
		self.protonPost = [[] for i in range(0, n)]

	def Reader(self, filename):
		file = open(filename, 'r')

		phC = 0
		pC = 0
		presC = 0
		patC = -1
		protpostC = 0

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
						protpostC = 0

					if (line_split[i].split('\r\n'))[0] == 'PhotonPri:':
						presC = 1
						phC = 0
						pC = 0
						protpostC = 0

					if (line_split[i].split('\r\n'))[0] == 'PhotonPost:':
						presC = 0
						phC = 1
						pC = 0	
						protpostC = 0

					if (line_split[i].split('\r\n'))[0] == 'ProtonPri:':
						presC = 0
						phC = 0
						pC = 1
						protpostC = 0

					if (line_split[i].split('\r\n'))[0] == 'ProtonPost:':
						presC = 0
						phC = 0
						pC = 0
						protpostC = 1


					if presC == 1 and (line_split[i].split('\r\n'))[0] != 'PhotonPri:':
						self.presc[patC].append(float((line_split[i].split('\r\n'))[0]))
					

					elif phC == 1 and (line_split[i].split('\r\n'))[0] != 'PhotonPost:':
						self.phDP[patC].append(float((line_split[i].split('\r\n'))[0]))
					

					elif pC == 1 and (line_split[i].split('\r\n'))[0] != 'ProtonPri:':
						self.pDP[patC].append(float((line_split[i].split('\r\n'))[0]))

					elif protpostC == 1 and (line_split[i].split('\r\n'))[0] != 'ProtonPost:':
						self.protonPost[patC].append(float((line_split[i].split('\r\n'))[0]))

					elif pC == 1 and phC == 1 or pC == 1 and presC == 1 or phC == 1 and presC == 1:
						print "Stuff is wrong"

		self.presc = np.array(self.presc)
		self.phDP = np.array(self.phDP)
		self.pDP = np.array(self.pDP)
		self.protonPost = np.array(self.protonPost)

def Translate_plotter():
	storer = ReadernPlotter(n = 9)
	storer.Reader('../Txt/ShrunkorTransDose_for_10_shrink1_trans0.200000_patients.txt')
	fs1 = 20



	fig1, ax1 = plt.subplots(1, 2, figsize = [20, 10])

	for i in range(0, len(storer.presc)):
		if i == 8:
			break
		print len(storer.presc[i]), len(storer.phDP[i]), len(storer.pDP[i]), len(storer.protonPost[i])

		print i
		line = np.linspace(0, 100, len(storer.presc[0]))
		fig, ax = plt.subplots(1, 2, figsize = [20, 10])

		ax[0].plot(storer.presc[i], storer.pDP[i], 'o')
		ax[0].plot(line, line, '-k', linewidth = 2)
		ax1[0].plot(storer.presc[i], storer.phDP[i], 'bo')

		ax[0].set_xlabel('Dose prior to translation [Gy]', fontsize = fs1)
		ax[0].set_ylabel('Dose post translation [Gy]', fontsize = fs1)
		ax[0].set_xlim([min([min(storer.presc[i]), min(storer.pDP[i]), min(storer.phDP[i])]) - 1, 
						max([max(storer.presc[i]), max(storer.pDP[i]), max(storer.phDP[i])]) + 1])
		ax[0].set_ylim([min([min(storer.presc[i]), min(storer.pDP[i]), min(storer.phDP[i])]) - 1, 
						max([max(storer.presc[i]), max(storer.pDP[i]), max(storer.phDP[i])]) + 1])
		ax[0].set_title('Proton DPBN', fontsize = fs1)
		ax[0].grid()

		ax[1].plot(storer.presc[i], storer.phDP[i], 'o')
		ax[1].plot(line, line, '-k', linewidth = 2)

		ax1[1].plot(storer.pDP[i], storer.protonPost[i], 'bo')


		ax[1].set_xlabel('Dose prior to translation [Gy]', fontsize = fs1)
		ax[1].set_ylabel('Dose post translation [Gy]', fontsize = fs1)
		ax[1].set_xlim([min([min(storer.presc[i]), min(storer.pDP[i]), min(storer.phDP[i])]) - 1, 
						max([max(storer.presc[i]), max(storer.pDP[i]), max(storer.phDP[i])]) + 1])
		ax[1].set_ylim([min([min(storer.presc[i]), min(storer.pDP[i]), min(storer.phDP[i])]) - 1, 
						max([max(storer.presc[i]), max(storer.pDP[i]), max(storer.phDP[i])]) + 1])
		ax[1].set_title('Photon DPBN', fontsize = fs1)
		ax[1].grid()

		fig.savefig('../Figurer/DvDTranslation_%d.png' %i)

		


	ax1[0].plot(line, line, '-k', linewidth = 2)
	ax1[1].plot(line, line, '-k', linewidth = 2)


	ax1[0].set_xlabel('Dose prior to translation [Gy]', fontsize = fs1)
	ax1[0].set_ylabel('Dose post translation [Gy]', fontsize = fs1)
	ax1[0].set_xlim([min([min(min(storer.presc[:])), min(min(storer.pDP[:])), min(min(storer.phDP[:]))]) - 1, 
					max([max(max(storer.presc[:])), max(max(storer.pDP[:])), max(max(storer.phDP[:]))]) + 4])
	ax1[0].set_ylim([min([min(min(storer.presc[:])), min(min(storer.pDP[:])), min(min(storer.phDP[:]))]) - 1, 
					max([max(max(storer.presc[:])), max(max(storer.pDP[:])), max(max(storer.phDP[:]))]) + 4])

	ax1[0].set_title('Proton DPBN', fontsize = fs1)
	ax1[0].grid()	

	ax1[1].set_xlabel('Dose prior to translation [Gy]', fontsize = fs1)
	ax1[1].set_ylabel('Dose post translation [Gy]', fontsize = fs1)
	ax1[1].set_xlim([min([min(min(storer.presc[:])), min(min(storer.pDP[:])), min(min(storer.phDP[:]))]) - 1, 
					max([max(max(storer.presc[:])), max(max(storer.pDP[:])), max(max(storer.phDP[:]))]) + 4])
	ax1[1].set_ylim([min([min(min(storer.presc[:])), min(min(storer.pDP[:])), min(min(storer.phDP[:]))]) - 1, 
					max([max(max(storer.presc[:])), max(max(storer.pDP[:])), max(max(storer.phDP[:]))]) + 4])

	ax1[1].set_title('Photon DPBN', fontsize = fs1)
	ax1[1].grid()

	fig1.savefig('../Figurer/DvDTranslation_AlmostAll.png')

	plt.show()

def ShrinkPlotter():
	storer = ReadernPlotter(n = 9)
	storer.Reader('../Txt/ShrunkorTransDose_for_10_shrink1.50000_trans0_patients.txt')
	fs1 = 20



	fig1, ax1 = plt.subplots(1, 2, figsize = [20, 10])

	for i in range(0, len(storer.presc)):
		if i == 8:
			break
		print len(storer.presc[i]), len(storer.phDP[i]), len(storer.pDP[i]), len(storer.protonPost[i])

		print i
		line = np.linspace(0, 100, len(storer.presc[0]))
		fig, ax = plt.subplots(1, 2, figsize = [20, 10])

		ax[0].plot(storer.presc[i], storer.pDP[i], 'o')
		ax[0].plot(line, line, '-k', linewidth = 2)
		ax1[0].plot(storer.presc[i], storer.phDP[i], 'bo')

		ax[0].set_xlabel('Dose prior to shrinking [Gy]', fontsize = fs1)
		ax[0].set_ylabel('Dose when shrunk [Gy]', fontsize = fs1)
		ax[0].set_xlim([min([min(storer.presc[i]), min(storer.pDP[i]), min(storer.phDP[i])]) - 1, 
						max([max(storer.presc[i]), max(storer.pDP[i]), max(storer.phDP[i])]) + 1])
		ax[0].set_ylim([min([min(storer.presc[i]), min(storer.pDP[i]), min(storer.phDP[i])]) - 1, 
						max([max(storer.presc[i]), max(storer.pDP[i]), max(storer.phDP[i])]) + 1])
		ax[0].set_title('Proton DPBN', fontsize = fs1)
		ax[0].grid()

		ax[1].plot(storer.presc[i], storer.phDP[i], 'o')
		ax[1].plot(line, line, '-k', linewidth = 2)

		ax1[1].plot(storer.pDP[i], storer.protonPost[i], 'bo')


		ax[1].set_xlabel('Dose prior to shrinking [Gy]', fontsize = fs1)
		ax[1].set_ylabel('Dose when shrunk [Gy]', fontsize = fs1)
		ax[1].set_xlim([min([min(storer.presc[i]), min(storer.pDP[i]), min(storer.phDP[i])]) - 1, 
						max([max(storer.presc[i]), max(storer.pDP[i]), max(storer.phDP[i])]) + 1])
		ax[1].set_ylim([min([min(storer.presc[i]), min(storer.pDP[i]), min(storer.phDP[i])]) - 1, 
						max([max(storer.presc[i]), max(storer.pDP[i]), max(storer.phDP[i])]) + 1])
		ax[1].set_title('Photon DPBN', fontsize = fs1)
		ax[1].grid()

		fig.savefig('../Figurer/DvDShrinkage_%d.png' %i)

		


	ax1[0].plot(line, line, '-k', linewidth = 2)
	ax1[1].plot(line, line, '-k', linewidth = 2)


	ax1[0].set_xlabel('Dose prior to shrinking [Gy]', fontsize = fs1)
	ax1[0].set_ylabel('Dose when shrunk [Gy]', fontsize = fs1)
	ax1[0].set_xlim([min([min(min(storer.presc[:])), min(min(storer.pDP[:])), min(min(storer.phDP[:]))]) - 1, 
					max([max(max(storer.presc[:])), max(max(storer.pDP[:])), max(max(storer.phDP[:]))]) + 4])
	ax1[0].set_ylim([min([min(min(storer.presc[:])), min(min(storer.pDP[:])), min(min(storer.phDP[:]))]) - 1, 
					max([max(max(storer.presc[:])), max(max(storer.pDP[:])), max(max(storer.phDP[:]))]) + 4])

	ax1[0].set_title('Proton DPBN', fontsize = fs1)
	ax1[0].grid()	

	ax1[1].set_xlabel('Dose prior to shrinking [Gy]', fontsize = fs1)
	ax1[1].set_ylabel('Dose when shrunk [Gy]', fontsize = fs1)
	ax1[1].set_xlim([min([min(min(storer.presc[:])), min(min(storer.pDP[:])), min(min(storer.phDP[:]))]) - 1, 
					max([max(max(storer.presc[:])), max(max(storer.pDP[:])), max(max(storer.phDP[:]))]) + 4])
	ax1[1].set_ylim([min([min(min(storer.presc[:])), min(min(storer.pDP[:])), min(min(storer.phDP[:]))]) - 1, 
					max([max(max(storer.presc[:])), max(max(storer.pDP[:])), max(max(storer.phDP[:]))]) + 4])

	ax1[1].set_title('Photon DPBN', fontsize = fs1)
	ax1[1].grid()

	fig1.savefig('../Figurer/DvDShrinkage_AlmostAll.png')

	plt.show()

a = Translate_plotter()