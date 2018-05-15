import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import matplotlib.pyplot as plt
import sys


class Hogwarts:
	def __init__(self, avg_mov_len = 10, shrink_len = 6):
		self.avg_mov_len = avg_mov_len
		self.shrink_len = shrink_len


	def Hermione_Granger(self, filename = "../Txt/Patient1_translate_and_shrink_10_6.txt"):
		"""
		This is the file reader
		"""

		avg_mov_len = self.avg_mov_len
		shrink_len = self.shrink_len

		self.patient = (filename.split('/')[-1]).split('_')[0]
		self.patientnr = int(self.patient.split('t')[-1])
		self.patient = self.patient.split(str(self.patientnr))[0]

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
				self.avg_mov.append(float((line.split(' ')[-1]).split('\r\n')[0]))
			if counter == 1:
				self.shrink.append(float((line.split(' ')[-1]).split('\r\n')[0]))
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
						self.phQF[ycounter, xcounter] = float(i.split('\r\n')[0])
					
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
						self.pTCP[ycounter, xcounter] = float(i.split('\r\n')[0])
					
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
						self.phTCP[ycounter, xcounter] = float(i.split('\r\n')[0])
					
						if xcounter < avg_mov_len - 1:
							xcounter += 1
						else:
							xcounter = 0
							ycounter += 1

						if ycounter == shrink_len:
							xcounter = 0
							ycounter = 0

	def Ron_Weasly(self):
		"""
		Because he just uses what Hermione has done
		"""

		self.stder = 0

		filename_list = ["../Txt/Patient1_translate_and_shrink_13_8.txt", "../Txt/Patient2_translate_and_shrink_13_8.txt", "../Txt/Patient3_translate_and_shrink_13_8.txt", "../Txt/Patient4_translate_and_shrink_13_8.txt",
						"../Txt/Patient5_translate_and_shrink_13_8.txt", "../Txt/Patient6_translate_and_shrink_13_8.txt", "../Txt/Patient7_translate_and_shrink_13_8.txt", "../Txt/Patient8_translate_and_shrink_13_8.txt",
						"../Txt/Patient9_translate_and_shrink_13_8.txt","../Txt/Patient11_translate_and_shrink_13_8.txt"]

		b = Hogwarts(avg_mov_len = 13, shrink_len = 8)
		for i in filename_list:
			b.Hermione_Granger(filename = i)
			if b.patientnr == 1:
				pQF_arr = b.pQF
				phQF_arr = b.phQF
				pTCP_arr = b.pTCP
				phTCP_arr = b.phTCP

			
			pQF_arr = pQF_arr + b.pQF
			phQF_arr = phQF_arr + b.phQF
			pTCP_arr = pTCP_arr + b.pTCP
			phTCP_arr = phTCP_arr + b.phTCP


		self.pQF = pQF_arr/float(len(filename_list))
		self.phQF = phQF_arr/float(len(filename_list))
		self.pTCP = pTCP_arr/float(len(filename_list))
		self.phTCP = phTCP_arr/float(len(filename_list))

		self.avg_mov = b.avg_mov
		self.shrink = b.shrink
		self.patient = b.patient
		self.patientnr = b.patientnr


	def Ron_Weasly2(self):
		"""
		Because she does the same as Ron, but only finds the faults.
		"""

		self.stder = 0

		filename_list = ["../Txt/Patient1_translate_and_shrink_13_8.txt", "../Txt/Patient2_translate_and_shrink_13_8.txt", "../Txt/Patient3_translate_and_shrink_13_8.txt", "../Txt/Patient4_translate_and_shrink_13_8.txt",
						"../Txt/Patient5_translate_and_shrink_13_8.txt", "../Txt/Patient6_translate_and_shrink_13_8.txt", "../Txt/Patient7_translate_and_shrink_13_8.txt", "../Txt/Patient8_translate_and_shrink_13_8.txt",
						"../Txt/Patient9_translate_and_shrink_13_8.txt","../Txt/Patient11_translate_and_shrink_13_8.txt"]

		b = Hogwarts(avg_mov_len = 13, shrink_len = 8)

		pQF_list = []
		phQF_list = []
		pTCP_list = []
		phTCP_list = []

		for i in filename_list:
			b.Hermione_Granger(filename = i)
			# print b.patientnr
			# if b.patientnr == 1:
			# 	pQF_arr = b.pQF
			# 	phQF_arr = b.phQF
			# 	pTCP_arr = b.pTCP
			# 	phTCP_arr = b.phTCP

			


			pQF_list.append(b.pQF)
			phQF_list.append(b.phQF)
			pTCP_list.append(b.pTCP)
			phTCP_list.append(b.phTCP)


		# print (pQF_list[0])[0,1]
		# print len((pQF_list[0])[0])
		# print len((pQF_list[0])[:, 0])

		pQF_std_list = [[] for x in range(0, 13*8)]
		phQF_std_list = [[] for x in range(0, 13*8)]
		pTCP_std_list = [[] for x in range(0, 13*8)]
		phTCP_std_list = [[] for x in range(0, 13*8)]

		for i in range(0, len(pQF_list)):
			for j in range(0, len((pQF_list[0])[0])):
				for k in range(0, len((pQF_list[0])[:, 0])):
					pQF_std_list[j + k*13].append((pQF_list[i])[k, j])
					phQF_std_list[j + k*13].append((phQF_list[i])[k, j])
					pTCP_std_list[j + k*13].append((pTCP_list[i])[k, j])
					phTCP_std_list[j + k*13].append((phTCP_list[i])[k, j])

					#To check that the right index is placed right, print (pQF_list[i])[k, j]
					#And check agains pQF_list
		# print ult_list

		pQF_std_list2 = [0 for x in range(0, len(pQF_std_list))]
		for i in range(0, len(pQF_std_list)):
			pQF_std_list2[i] = np.std(pQF_std_list[i])

		#print pQF_std_list2


		self.pQF = np.array([[np.mean(pQF_std_list[j*13 + i]) for i in range(0, 13)] for j in range(0, 8)])
		self.phQF = np.array([[np.mean(phQF_std_list[j*13 + i]) for i in range(0, 13)] for j in range(0, 8)])
		self.pTCP = np.array([[np.mean(pTCP_std_list[j*13 + i]) for i in range(0, 13)] for j in range(0, 8)])
		self.phTCP = np.array([[np.mean(phTCP_std_list[j*13 + i]) for i in range(0, 13)] for j in range(0, 8)])

		#print self.pQF
		# print b.pQF

		# print self.pTCP
		# print self.phTCP

		# print np.array([[np.mean(pQF_std_list[i*j + i]) for i in range(0, 13)] for j in range(0, 8)])
		# print np.array([[np.mean(phQF_std_list[i*j + i]) for i in range(0, 13)] for j in range(0, 8)])
		# print np.array([[np.mean(pTCP_std_list[i*j + i]) for i in range(0, 13)] for j in range(0, 8)])
		# print np.array([[np.mean(phTCP_std_list[i*j + i]) for i in range(0, 13)] for j in range(0, 8)])

		self.avg_mov = b.avg_mov
		self.shrink = b.shrink
		self.patient = b.patient
		self.patientnr = b.patientnr


	def Molly_Weasly(self):
		"""
		Because she does the same as Ron, but only finds the faults.
		"""

		self.stder = 1

		filename_list = ["../Txt/Patient1_translate_and_shrink_13_8.txt", "../Txt/Patient2_translate_and_shrink_13_8.txt", "../Txt/Patient3_translate_and_shrink_13_8.txt", "../Txt/Patient4_translate_and_shrink_13_8.txt",
						"../Txt/Patient5_translate_and_shrink_13_8.txt", "../Txt/Patient6_translate_and_shrink_13_8.txt", "../Txt/Patient7_translate_and_shrink_13_8.txt", "../Txt/Patient8_translate_and_shrink_13_8.txt",
						"../Txt/Patient9_translate_and_shrink_13_8.txt","../Txt/Patient11_translate_and_shrink_13_8.txt"]

		b = Hogwarts(avg_mov_len = 13, shrink_len = 8)

		pQF_list = []
		phQF_list = []
		pTCP_list = []
		phTCP_list = []

		for i in filename_list:
			b.Hermione_Granger(filename = i)
			# print b.patientnr
			# if b.patientnr == 1:
			# 	pQF_arr = b.pQF
			# 	phQF_arr = b.phQF
			# 	pTCP_arr = b.pTCP
			# 	phTCP_arr = b.phTCP

			


			pQF_list.append(b.pQF)
			phQF_list.append(b.phQF)
			pTCP_list.append(b.pTCP)
			phTCP_list.append(b.phTCP)


		# print (pQF_list[0])[0,1]
		# print len((pQF_list[0])[0])
		# print len((pQF_list[0])[:, 0])

		pQF_std_list = [[] for x in range(0, 13*8)]
		phQF_std_list = [[] for x in range(0, 13*8)]
		pTCP_std_list = [[] for x in range(0, 13*8)]
		phTCP_std_list = [[] for x in range(0, 13*8)]

		for i in range(0, len(pQF_list)):
			for j in range(0, len((pQF_list[0])[0])):
				for k in range(0, len((pQF_list[0])[:, 0])):
					pQF_std_list[j + k*13].append((pQF_list[i])[k, j])
					phQF_std_list[j + k*13].append((phQF_list[i])[k, j])
					pTCP_std_list[j + k*13].append((pTCP_list[i])[k, j])
					phTCP_std_list[j + k*13].append((phTCP_list[i])[k, j])

					#To check that the right index is placed right, print (pQF_list[i])[k, j]
					#And check agains pQF_list
		# print ult_list

		pQF_std_list2 = [0 for x in range(0, len(pQF_std_list))]
		for i in range(0, len(pQF_std_list)):
			pQF_std_list2[i] = np.std(pQF_std_list[i])

		#print pQF_std_list2


		self.pQF = np.array([[np.std(pQF_std_list[j*13 + i]) for i in range(0, 13)] for j in range(0, 8)])
		self.phQF = np.array([[np.std(phQF_std_list[j*13 + i]) for i in range(0, 13)] for j in range(0, 8)])
		self.pTCP = np.array([[np.std(pTCP_std_list[j*13 + i]) for i in range(0, 13)] for j in range(0, 8)])
		self.phTCP = np.array([[np.std(phTCP_std_list[j*13 + i]) for i in range(0, 13)] for j in range(0, 8)])

		#print self.pQF
		# print b.pQF

		# print self.pTCP
		# print self.phTCP

		# print np.array([[np.mean(pQF_std_list[i*j + i]) for i in range(0, 13)] for j in range(0, 8)])
		# print np.array([[np.mean(phQF_std_list[i*j + i]) for i in range(0, 13)] for j in range(0, 8)])
		# print np.array([[np.mean(pTCP_std_list[i*j + i]) for i in range(0, 13)] for j in range(0, 8)])
		# print np.array([[np.mean(phTCP_std_list[i*j + i]) for i in range(0, 13)] for j in range(0, 8)])

		self.avg_mov = b.avg_mov
		self.shrink = b.shrink
		self.patient = b.patient
		self.patientnr = b.patientnr


#print pQF[1], avg_mov, shrink, counter, xcounter, ycounter

# x = np.arange(min(avg_mov), max(avg_mov), 0.033333333)
# y = np.arange(min(shrink), max(shrink) + 0.25, shrink[1] - shrink[0])

# X, Y = np.meshgrid(x, y)

# dx, dy = avg_mov[1] - avg_mov[0], shrink[1] - shrink[0]

# Y, X = np.mgrid[slice(min(shrink), max(shrink) + dy, dy), slice(min(avg_mov), max(avg_mov) + dx, dx)]

#print x, y, X, Y, X1, Y1

#print X.shape, Y.shape, X1.shape, Y1.shape
#print pQF.shape




	def HarryPlotter_4(self, fs = 8, fs2 = 20, fs3 = 15, numbers = 0, xText = 0.1, yText = 0.4, AllPAT = 1, shower = 0):
		pQF = self.pQF
		phQF = self.phQF
		pTCP = self.pTCP
		phTCP = self.phTCP

		avg_mov = self.avg_mov
		shrink = self.shrink
		avg_mov_len = self.avg_mov_len
		shrink_len = self.shrink_len

		patient = self.patient
		patientnr = self.patientnr




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

		ax[0,0].set_xlabel('Average Movement [cm]', fontsize = fs2)
		ax[0,1].set_xlabel('Average Movement [cm]', fontsize = fs2)
		ax[1,0].set_xlabel('Average Movement [cm]', fontsize = fs2)
		ax[1,1].set_xlabel('Average Movement [cm]', fontsize = fs2)

		ax[0,0].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)
		ax[0,1].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)
		ax[1,0].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)
		ax[1,1].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)


		#fig.suptitle('%s %d' %(patient, patientnr), fontsize = fs2)
		fig.tight_layout()

		if AllPAT == 1:
			plt.savefig('../Figurer/4-All-pcolor-%d.png' %(numbers))
			if self.stder == 1:
				plt.savefig('../Figurer/4-AllSTD-pcolor-%d.png' %(numbers))
		else:
			plt.savefig('../Figurer/4-%s-%d-pcolor-%d.png' %(patient, patientnr, numbers))

		
		if shower == 1:
			plt.show()

	def HarryPlotter_2(self, modality,  fs = 8, fs2 = 20, fs3 = 15, numbers = 0, xText = 0.1,
						yText = 0.4, AllPAT = 1, shower = 0):
		pQF = self.pQF
		phQF = self.phQF
		pTCP = self.pTCP
		phTCP = self.phTCP

		avg_mov = self.avg_mov
		shrink = self.shrink
		avg_mov_len = self.avg_mov_len
		shrink_len = self.shrink_len

		patient = self.patient
		patientnr = self.patientnr

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

		ax[0].set_xlabel('Average Movement [cm]', fontsize = fs2)
		ax[1].set_xlabel('Average Movement [cm]', fontsize = fs2)

		ax[0].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)
		ax[1].set_ylabel('Uniform shrinking [mm]', fontsize = fs2)

		#fig.suptitle('%s %d' %(patient, patientnr), fontsize = fs2)
		fig.tight_layout()

		if AllPAT == 1:
			plt.savefig('../Figurer/QFogTCP/2-%s-All-pcolor-%d.png' %(modality, numbers))
			if self.stder == 1:
				plt.savefig('../Figurer/QFogTCP/2-%s-AllSTD-pcolor-%d.png' %(modality, numbers))
		else:
			plt.savefig('../Figurer/QFogTCP/2-%s-%s-%d-pcolor-%d.png' %(modality, patient, patientnr, numbers))

		
		if shower == 1:
			plt.show()

	def HarryPlotter(self, modality, mini, maxi, AllPAT = 1,fs = 8, fs2 = 20, fs3 = 15, numbers = 0, xText = 0.1,
						yText = 0.4, shower = 0):

		pQF = self.pQF
		phQF = self.phQF
		pTCP = self.pTCP
		phTCP = self.phTCP

		avg_mov = self.avg_mov
		shrink = self.shrink
		avg_mov_len = self.avg_mov_len
		shrink_len = self.shrink_len

		patient = self.patient
		patientnr = self.patientnr

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

		ax.set_xlabel('Average Movement [cm]', fontsize = fs2)

		ax.set_ylabel('Uniform shrinking [mm]', fontsize = fs2)


		#fig.suptitle('%s %s %d' %(modality, patient, patientnr), fontsize = fs2)
		fig.tight_layout()

		if AllPAT == 1:
			plt.savefig('../Figurer/1-%s-All-pcolor-%d.png' %(modality2, numbers))
			if self.stder == 1:
				plt.savefig('../Figurer/1-%s-AllSTD-pcolor-%d.png' %(modality2, numbers))
		else:
			plt.savefig('../Figurer/1-%s-%s-%d-pcolor-%d.png' %(modality2, patient, patientnr, numbers))

		
		if shower == 1:
			plt.show()


a = Hogwarts(avg_mov_len = 13, shrink_len = 8)

# ################################
# #To create std plots for all:
# a.Molly_Weasly()
# a.HarryPlotter_2('QF', shower = 1)
# a.HarryPlotter_2('TCP')
# ################################

################################
#To create normal plots for all:
a.Ron_Weasly2()
a.HarryPlotter_2('QF', shower = 1)
a.HarryPlotter_2('TCP')
################################

# ###############################
# #To create normal plots for all but seperate plots:
# filename_list = ["../Txt/Patient1_translate_and_shrink_13_8.txt", "../Txt/Patient2_translate_and_shrink_13_8.txt", "../Txt/Patient3_translate_and_shrink_13_8.txt", "../Txt/Patient4_translate_and_shrink_13_8.txt",
# 						"../Txt/Patient5_translate_and_shrink_13_8.txt", "../Txt/Patient6_translate_and_shrink_13_8.txt", "../Txt/Patient7_translate_and_shrink_13_8.txt", "../Txt/Patient8_translate_and_shrink_13_8.txt",
# 						"../Txt/Patient9_translate_and_shrink_13_8.txt","../Txt/Patient11_translate_and_shrink_13_8.txt"]
# for i in filename_list:
# 	a.Hermione_Granger(i)
# 	a.HarryPlotter_2('QF', AllPAT = 0)
# 	a.HarryPlotter_2('TCP', AllPAT = 0)



# a.Hermione_Granger(filename = "../Txt/Patient1_translate_and_shrink_13_8.txt")
# a.HarryPlotter_4()
#HarryPlotter_2("TCP")
#HarryPlotter("pTCP", mini = 0.93, maxi = 1)