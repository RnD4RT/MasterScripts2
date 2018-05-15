import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.gridspec import GridSpec
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import sys

class QFnTCP_point_plot:
	def __init__(self, n = 9):
		self.phQF   = []
		self.pQF  = []
		self.phTCP  = []
		self.pTCP = []

		self.storer = [self.phQF, self.pQF, self.phTCP, self.pTCP]

	def QFnTCP_reader(self, filename):
		file = open(filename, 'r')

		counter = 0
		counterStorer = 0

		for line in file:
			for i in line.split(' '):
				if i != '':
					self.storer[counterStorer].append(float((i.split('\r\n'))[0]))
					
					counter += 1

					if counter == 9:
						counter = 0
						counterStorer += 1

def Translator():
	translist = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6]

	tot_pQF = []
	tot_pQFstd = []
	tot_phQF = []
	tot_phQFstd = []
	tot_pTCP = []
	tot_pTCPstd = []
	tot_phTCP = []
	tot_phTCPstd = []


	fig, ax = plt.subplots(1, 2, figsize = [20, 10])


	for i in range(0, len(translist)):
		if i > 0:
			filename = '../Txt/ShrunkorTransQFnTCP_for_9_shrink1_trans%1.1f00000_patients.txt' %translist[i]
		else:
			filename = '../Txt/ShrunkorTransQFnTCP_for_9_shrink1_trans0_patients.txt'

		a = QFnTCP_point_plot()
		a.QFnTCP_reader(filename)

		tot_pQF.append(np.mean(a.pQF))
		tot_pQFstd.append(np.std(a.pQF))
		tot_phQF.append(np.mean(a.phQF))
		tot_phQFstd.append(np.std(a.phQF))
		tot_pTCP.append(np.mean(a.pTCP))
		tot_pTCPstd.append(np.std(a.pTCP))
		tot_phTCP.append(np.mean(a.phTCP))
		tot_phTCPstd.append(np.std(a.phTCP))

	fs1 = 20
	fs2 = 16


	x_prot = np.array(translist) - 0.005
	x_phot = np.array(translist) + 0.005

	ax[0].errorbar(x_prot, tot_pQF, yerr=tot_pQFstd, fmt='o', label = 'Protons')
	ax[0].set_xlim([translist[0] - (translist[1] - translist[0])/2., translist[-1] + (translist[1] - translist[0])/2.])
	ax[0].errorbar(x_phot, tot_phQF, yerr=tot_phQFstd, fmt='o', label = 'Photons')
	ax[0].set_xlim([translist[0] - (translist[1] - translist[0])/2., translist[-1] + (translist[1] - translist[0])/2.])
	ax[0].set_xlabel('Uniform translation along each axis [cm]', fontsize = fs1)
	ax[0].set_ylabel('QF', fontsize = fs1)
	ax[0].tick_params(axis = 'both', labelsize = fs2)
	ax[0].legend(loc = 2, numpoints=1)


	ax[1].errorbar(x_prot, tot_pTCP, yerr=tot_pTCPstd, fmt='o', label = 'Protons')
	ax[1].set_xlim([translist[0] - (translist[1] - translist[0])/2., translist[-1] + (translist[1] - translist[0])/2.])
	ax[1].errorbar(x_phot, tot_phTCP, yerr=tot_phTCPstd, fmt='o', label = 'Photons')
	ax[1].set_xlim([translist[0] - (translist[1] - translist[0])/2., translist[-1] + (translist[1] - translist[0])/2.])
	ax[1].set_xlabel('Uniform translation along each axis [cm]', fontsize = fs1)
	ax[1].set_ylabel('TCP', fontsize = fs1)
	ax[1].tick_params(axis = 'both', labelsize = fs2)
	ax[1].legend(loc = 3, numpoints=1)

	plt.savefig('../Figurer/QFnTCPtranslation.png')


def Shrinker1():
	shrinklist = [1.0, 0.9, 0.8, 0.7, 0.6, 0.5]

	tot_pQF = []
	tot_pQFstd = []
	tot_phQF = []
	tot_phQFstd = []
	tot_pTCP = []
	tot_pTCPstd = []
	tot_phTCP = []
	tot_phTCPstd = []


	fig, ax = plt.subplots(1, 2, figsize = [20, 10])


	for i in range(0, len(shrinklist)):
		if i > 0:
			filename = '../Txt/ShrunkorTransQFnTCP_for_9_shrink%1.1f00000_trans0_patients.txt' %shrinklist[i]
		else:
			filename = '../Txt/ShrunkorTransQFnTCP_for_9_shrink%1.1f0000_trans0mmswitchoff_patients.txt' %shrinklist[i]

		a = QFnTCP_point_plot()
		a.QFnTCP_reader(filename)

		tot_pQF.append(np.mean(a.pQF))
		tot_pQFstd.append(np.std(a.pQF))
		tot_phQF.append(np.mean(a.phQF))
		tot_phQFstd.append(np.std(a.phQF))
		tot_pTCP.append(np.mean(a.pTCP))
		tot_pTCPstd.append(np.std(a.pTCP))
		tot_phTCP.append(np.mean(a.phTCP))
		tot_phTCPstd.append(np.std(a.phTCP))

	fs1 = 20
	fs2 = 16


	x_prot = np.array(shrinklist) - 0.005
	x_phot = np.array(shrinklist) + 0.005

	ax[0].errorbar(x_prot, tot_pQF, yerr=tot_pQFstd, fmt='o', label = 'Protons')
	ax[0].set_xlim([shrinklist[0] - (shrinklist[1] - shrinklist[0])/2., shrinklist[-1] + (shrinklist[1] - shrinklist[0])/2.])
	ax[0].errorbar(x_phot, tot_phQF, yerr=tot_phQFstd, fmt='o', label = 'Photons')
	ax[0].set_xlim([shrinklist[0] - (shrinklist[1] - shrinklist[0])/2., shrinklist[-1] + (shrinklist[1] - shrinklist[0])/2.])
	ax[0].set_xlabel('Relative volume left after shrinkage', fontsize = fs1)
	ax[0].set_ylabel('QF', fontsize = fs1)
	ax[0].tick_params(axis = 'both', labelsize = fs2)
	ax[0].legend(loc = 2, numpoints=1)


	ax[1].errorbar(x_prot, tot_pTCP, yerr=tot_pTCPstd, fmt='o', label = 'Protons')
	ax[1].set_xlim([shrinklist[0] - (shrinklist[1] - shrinklist[0])/2., shrinklist[-1] + (shrinklist[1] - shrinklist[0])/2.])
	ax[1].errorbar(x_phot, tot_phTCP, yerr=tot_phTCPstd, fmt='o', label = 'Photons')
	ax[1].set_xlim([shrinklist[0] - (shrinklist[1] - shrinklist[0])/2., shrinklist[-1] + (shrinklist[1] - shrinklist[0])/2.])
	ax[1].set_xlabel('Relative volume left after shrinkage', fontsize = fs1)
	ax[1].set_ylabel('TCP', fontsize = fs1)
	ax[1].tick_params(axis = 'both', labelsize = fs2)
	ax[1].legend(loc = 3, numpoints=1)

	plt.savefig('../Figurer/QFnTCPshrink_rel.png')

def Shrinker2():
	shrinklist = [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]

	tot_pQF = []
	tot_pQFstd = []
	tot_phQF = []
	tot_phQFstd = []
	tot_pTCP = []
	tot_pTCPstd = []
	tot_phTCP = []
	tot_phTCPstd = []


	fig, ax = plt.subplots(1, 2, figsize = [20, 10])


	for i in range(0, len(shrinklist)):
		if i > 1:
			filename = '../Txt/ShrunkorTransQFnTCP_for_9_shrink%1.5f_trans0mmswitchon_patients.txt' %shrinklist[i]
		elif i == 1:
			filename = '../Txt/ShrunkorTransQFnTCP_for_9_shrink%1.6f_trans0mmswitchon_patients.txt' %shrinklist[i]
		else:
			filename = '../Txt/ShrunkorTransQFnTCP_for_9_shrink0_trans0mmswitchon_patients.txt'

		a = QFnTCP_point_plot()
		a.QFnTCP_reader(filename)

		tot_pQF.append(np.mean(a.pQF))
		tot_pQFstd.append(np.std(a.pQF))
		tot_phQF.append(np.mean(a.phQF))
		tot_phQFstd.append(np.std(a.phQF))
		tot_pTCP.append(np.mean(a.pTCP))
		tot_pTCPstd.append(np.std(a.pTCP))
		tot_phTCP.append(np.mean(a.phTCP))
		tot_phTCPstd.append(np.std(a.phTCP))

	fs1 = 20
	fs2 = 16


	x_prot = np.array(shrinklist) - 0.025
	x_phot = np.array(shrinklist) + 0.025

	ax[0].errorbar(x_prot, tot_pQF, yerr=tot_pQFstd, fmt='o', label = 'Protons')
	ax[0].set_xlim([shrinklist[0] - (shrinklist[1] - shrinklist[0])/2., shrinklist[-1] + (shrinklist[1] - shrinklist[0])/2.])
	ax[0].errorbar(x_phot, tot_phQF, yerr=tot_phQFstd, fmt='o', label = 'Photons')
	ax[0].set_xlim([shrinklist[0] - (shrinklist[1] - shrinklist[0])/2., shrinklist[-1] + (shrinklist[1] - shrinklist[0])/2.])
	ax[0].set_xlabel('Radius shrinkage [cm]', fontsize = fs1)
	ax[0].set_ylabel('QF', fontsize = fs1)
	ax[0].tick_params(axis = 'both', labelsize = fs2)
	ax[0].legend(loc = 2, numpoints=1)


	ax[1].errorbar(x_prot, tot_pTCP, yerr=tot_pTCPstd, fmt='o', label = 'Protons')
	ax[1].set_xlim([shrinklist[0] - (shrinklist[1] - shrinklist[0])/2., shrinklist[-1] + (shrinklist[1] - shrinklist[0])/2.])
	ax[1].errorbar(x_phot, tot_phTCP, yerr=tot_phTCPstd, fmt='o', label = 'Photons')
	ax[1].set_xlim([shrinklist[0] - (shrinklist[1] - shrinklist[0])/2., shrinklist[-1] + (shrinklist[1] - shrinklist[0])/2.])
	ax[1].set_xlabel('Radius shrinkage [cm]', fontsize = fs1)
	ax[1].set_ylabel('TCP', fontsize = fs1)
	ax[1].tick_params(axis = 'both', labelsize = fs2)
	ax[1].legend(loc = 4, numpoints=1)

	plt.savefig('../Figurer/QFnTCPshrink_abs.png')

a = Translator()
b = Shrinker1()
c = Shrinker2()

#plt.show()