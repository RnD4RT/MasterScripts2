import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import matplotlib.pyplot as plt
import sys


class Hogwarts:
	def __init__(self, avg_mov_len = 10, shrink_len = 6):
		self.avg_mov_len = avg_mov_len
		self.shrink_len = shrink_len


	def Hermione_Granger(self, filename = "../Txt/Patient1_translate_and_shrink_10_6.txt")
		"""
		This is the file reader
		"""


		self.patient = (filename.split('/')[-1])[:8]
		self.patientnr = int(patient[-1])
		self.patient = patient[:-1]

		file = open(filename, 'r')

		counter  = 0
		xcounter = 0
		ycounter = 0

		self.pQF   = np.zeros((self.shrink_len, self.avg_mov_len))
		self.phQF  = np.zeros((self.shrink_len, self.avg_mov_len))
		self.pTCP  = np.zeros((self.shrink_len, self.avg_mov_len))
		self.phTCP = np.zeros((self.shrink_len, self.avg_mov_len))

		self.avg_mov = []
		self.shrink  = []


		for line in file:
			first_element = line.split(' ')[-1][:-2]

			#print line.split(' ')

			if first_element == '#':
				counter += 1
				continue
			if counter == 0:
				avg_mov.append(float((line.split(' ')[-1]).split('\r\n')[0]))
			if counter == 1:
				shrink.append(float((line.split(' ')[-1]).split('\r\n')[0]))
			if counter == 2:
				for i in line.split(' '):
					if i != '':
						self.pQF[ycounter, xcounter] = float(i.split('\r\n')[0])
					
						if xcounter < avg_mov_len - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == shrink_len:
							xcounter = 0
							ycounter = 0

			if counter == 3:
				for i in line.split(' '):
					if i != '':
						phQF[ycounter, xcounter] = float(i.split('\r\n')[0])
					
						if xcounter < avg_mov_len - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == shrink_len:
							xcounter = 0
							ycounter = 0



			if counter == 4:
				for i in line.split(' '):
					if i != '':
						pTCP[ycounter, xcounter] = float(i.split('\r\n')[0])
					
						if xcounter < avg_mov_len - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == shrink_len:
							xcounter = 0
							ycounter = 0

			if counter == 5:
				for i in line.split(' '):
					if i != '':
						phTCP[ycounter, xcounter] = float(i.split('\r\n')[0])
					
						if xcounter < avg_mov_len - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == shrink_len:
							xcounter = 0
							ycounter = 0

#print pQF[1], avg_mov, shrink, counter, xcounter, ycounter

# x = np.arange(min(avg_mov), max(avg_mov), 0.033333333)
# y = np.arange(min(shrink), max(shrink) + 0.25, shrink[1] - shrink[0])

# X, Y = np.meshgrid(x, y)

# dx, dy = avg_mov[1] - avg_mov[0], shrink[1] - shrink[0]

# Y, X = np.mgrid[slice(min(shrink), max(shrink) + dy, dy), slice(min(avg_mov), max(avg_mov) + dx, dx)]

#print x, y, X, Y, X1, Y1

#print X.shape, Y.shape, X1.shape, Y1.shape
#print pQF.shape




def HarryPlotter_4(fs = 8, fs2 = 20, fs3 = 15, numbers = 0, xText = 0.1, yText = 0.4):
	pQF = self.pQF
	phQF = self.phQF
	pTCP = self.pTCP
	phTCP = self.phTCP

	avg_mov = self.avg_mov
	shrink = self.shrink


	fig, ax = plt.subplots(2, 2, figsize = (18, 12))
	# fig.subplots_adjust(bottom = 0.25, left = 0.25) # make room for labels

	QFmin = min([pQF.min(), phQF.min()])
	QFmax = max([pQF.max(), phQF.max()])

	TCPmin = min([pTCP.min(), phTCP.min()])
	TCPmax = max([pTCP.max(), phTCP.max()])

	xheaders = ['%1.3f' %i  for i in avg_mov]
	yheaders = ['%1.3f' %i for i in shrink]

	fs = 8
	fs2 = 20
	fs3 = 15
	numbers = 1

	xText = 0.1
	yText = 0.4


	#pQF
	heatmap = ax[0, 0].pcolor(pQF, vmin = QFmin, vmax = QFmax)
	cbar = plt.colorbar(heatmap, ax = ax[0, 0])

	if numbers == 1:
		for i in range(0, len(avg_mov)):
			for j in range(0, len(shrink)):
				ax[0,0].text(i + xText, j + yText, '%1.2e' %pQF[j,i], fontsize = fs, color = "White")



	ax[0,0].set_xticks(np.arange(pQF.shape[1]) +.5, minor = False)
	ax[0,0].set_yticks(np.arange(pQF.shape[0]) +.5, minor = False)

	ax[0,0].set_xticklabels(xheaders,rotation=90, fontsize = fs3)
	ax[0,0].set_yticklabels(yheaders, fontsize = fs3)


	#ph QF
	heatmap = ax[0, 1].pcolor(phQF, vmin = QFmin, vmax = QFmax)
	cbar = plt.colorbar(heatmap, ax = ax[0, 1])

	if numbers == 1:
		for i in range(0, len(avg_mov)):
			for j in range(0, len(shrink)):
				ax[0,1].text(i + xText, j + yText, '%1.2e' %phQF[j,i], fontsize = fs, color = "White")



	ax[0,1].set_xticks(np.arange(phQF.shape[1]) +.5, minor = False)
	ax[0,1].set_yticks(np.arange(phQF.shape[0]) +.5, minor = False)

	ax[0,1].set_xticklabels(xheaders,rotation=90, fontsize = fs3)
	ax[0,1].set_yticklabels(yheaders, fontsize = fs3)


	#p TCP
	heatmap = ax[1, 0].pcolor(pTCP, vmin = TCPmin, vmax = TCPmax)
	cbar = plt.colorbar(heatmap, ax = ax[1, 0])

	if numbers == 1:
		for i in range(0, len(avg_mov)):
			for j in range(0, len(shrink)):
				ax[1,0].text(i + xText, j + yText, '%1.2e' %pTCP[j,i], fontsize = fs, color = "White")



	ax[1,0].set_xticks(np.arange(pTCP.shape[1]) +.5, minor = False)
	ax[1,0].set_yticks(np.arange(pTCP.shape[0]) +.5, minor = False)

	ax[1,0].set_xticklabels(xheaders,rotation=90, fontsize = fs3)
	ax[1,0].set_yticklabels(yheaders, fontsize = fs3)


	#ph TCP
	heatmap = ax[1, 1].pcolor(phTCP, vmin = TCPmin, vmax = TCPmax)
	cbar = plt.colorbar(heatmap, ax = ax[1, 1])

	if numbers == 1:
		for i in range(0, len(avg_mov)):
			for j in range(0, len(shrink)):
				ax[1,1].text(i + xText, j + yText, '%1.2e' %phTCP[j,i], fontsize = fs, color = "White")



	ax[1,1].set_xticks(np.arange(phTCP.shape[1]) +.5, minor = False)
	ax[1,1].set_yticks(np.arange(phTCP.shape[0]) +.5, minor = False)

	ax[1,1].set_xticklabels(xheaders,rotation=90, fontsize = fs3)
	ax[1,1].set_yticklabels(yheaders, fontsize = fs3)

	ax[0,0].set_title('Proton QF', fontsize = fs2)
	ax[0,1].set_title('Photon QF', fontsize = fs2)
	ax[1,0].set_title('Proton TCP', fontsize = fs2)
	ax[1,1].set_title('Photon TCP', fontsize = fs2)

	ax[0,0].set_xlabel('Average Movement [mm]', fontsize = fs2)
	ax[0,1].set_xlabel('Average Movement [mm]', fontsize = fs2)
	ax[1,0].set_xlabel('Average Movement [mm]', fontsize = fs2)
	ax[1,1].set_xlabel('Average Movement [mm]', fontsize = fs2)

	ax[0,0].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)
	ax[0,1].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)
	ax[1,0].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)
	ax[1,1].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)


	fig.suptitle('%s %d' %(patient, patientnr), fontsize = fs2)
	fig.tight_layout()

	plt.savefig('../Figurer/4%s-%d-pcolor-%d.png' %(patient, patientnr, numbers))
	
	plt.show()

def HarryPlotter_2(modality,  fs = 8, fs2 = 20, fs3 = 15, numbers = 0, xText = 0.1,
					yText = 0.4):
	pQF = self.pQF
	phQF = self.phQF
	pTCP = self.pTCP
	phTCP = self.phTCP

	avg_mov = self.avg_mov
	shrink = self.shrink

	if modality == 'QF':
		p = pQF
		ph = phQF
	elif modality == 'TCP':
		p = pTCP
		ph = phTCP
	
	fig, ax = plt.subplots(1, 2, figsize = (18, 9))

	mini = min([p.min(), ph.min()])
	maxi = max([p.max(), ph.max()])

	xheaders = ['%1.3f' %i  for i in avg_mov]
	yheaders = ['%1.3f' %i for i in shrink]

	#p
	heatmap = ax[0].pcolor(p, vmin = mini, vmax = maxi)
	cbar = plt.colorbar(heatmap, ax = ax[0])

	if numbers == 1:
		for i in range(0, len(avg_mov)):
			for j in range(0, len(shrink)):
				ax[0].text(i + xText, j + yText, '%1.2e' %p[j,i], fontsize = fs, color = "White")



	ax[0].set_xticks(np.arange(p.shape[1]) +.5, minor = False)
	ax[0].set_yticks(np.arange(p.shape[0]) +.5, minor = False)

	ax[0].set_xticklabels(xheaders,rotation=90, fontsize = fs3)
	ax[0].set_yticklabels(yheaders, fontsize = fs3)


	#ph
	heatmap = ax[1].pcolor(ph, vmin = mini, vmax = maxi)
	cbar = plt.colorbar(heatmap, ax = ax[1])

	if numbers == 1:
		for i in range(0, len(avg_mov)):
			for j in range(0, len(shrink)):
				ax[1].text(i + xText, j + yText, '%1.2e' %ph[j,i], fontsize = fs, color = "White")



	ax[1].set_xticks(np.arange(ph.shape[1]) +.5, minor = False)
	ax[1].set_yticks(np.arange(ph.shape[0]) +.5, minor = False)

	ax[1].set_xticklabels(xheaders,rotation=90, fontsize = fs3)
	ax[1].set_yticklabels(yheaders, fontsize = fs3)

	ax[0].set_title('Proton %s' %modality, fontsize = fs2)
	ax[1].set_title('Photon %s' %modality, fontsize = fs2)

	ax[0].set_xlabel('Average Movement [mm]', fontsize = fs2)
	ax[1].set_xlabel('Average Movement [mm]', fontsize = fs2)

	ax[0].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)
	ax[1].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)

	fig.suptitle('%s %d' %(patient, patientnr), fontsize = fs2)
	fig.tight_layout()

	plt.savefig('../Figurer/2-%s-%s-%d-pcolor-%d.png' %(modality, patient, patientnr, numbers))
	
	plt.show()

def HarryPlotter(modality, mini, maxi, avg_mov = avg_mov, 
					shrink = shrink,  fs = 8, fs2 = 20, fs3 = 15, numbers = 0, xText = 0.1,
					yText = 0.4):

	pQF = self.pQF
	phQF = self.phQF
	pTCP = self.pTCP
	phTCP = self.phTCP

	avg_mov = self.avg_mov
	shrink = self.shrink

	if modality == 'pQF':
		plotthing = pQF
		modality = 'Proton QF'
		modality2 = 'Proton-QF'

	elif modality == 'phQF':
		plotthing = phQF
		modality = 'Photon QF'
		modality2 = 'Photon-QF'

	elif modality == 'pTCP':
		plotthing = pTCP
		modality = 'Proton TCP'
		modality2 = 'Proton-TCP'

	elif modality == 'phTCP':
		plotthing = phTCP
		modality = 'Photon TCP'
		modality2 = 'Photon-TCP'
	
	fig, ax = plt.subplots(figsize = (18, 9))

	xheaders = ['%1.3f' %i  for i in avg_mov]
	yheaders = ['%1.3f' %i for i in shrink]

	#p
	heatmap = ax.pcolor(plotthing, vmin = mini, vmax = maxi)
	cbar = plt.colorbar(heatmap, ax = ax)

	if numbers == 1:
		for i in range(0, len(avg_mov)):
			for j in range(0, len(shrink)):
				ax.text(i + xText, j + yText, '%1.2e' %plotthing[j,i], fontsize = fs, color = "White")



	ax.set_xticks(np.arange(plotthing.shape[1]) +.5, minor = False)
	ax.set_yticks(np.arange(plotthing.shape[0]) +.5, minor = False)

	ax.set_xticklabels(xheaders,rotation=90, fontsize = fs3)
	ax.set_yticklabels(yheaders, fontsize = fs3)


	ax.set_title('Proton %s' %modality, fontsize = fs2)

	ax.set_xlabel('Average Movement [mm]', fontsize = fs2)

	ax.set_ylabel('Uniform shrinking [mm]', fontsize = fs2)


	fig.suptitle('%s %s %d' %(modality, patient, patientnr), fontsize = fs2)
	fig.tight_layout()

	plt.savefig('../Figurer/1-%s-%s-%d-pcolor-%d.png' %(modality2, patient, patientnr, numbers))
	
	plt.show()


HarryPlotter_4()
#HarryPlotter_2("TCP")
#HarryPlotter("pTCP", mini = 0.93, maxi = 1)