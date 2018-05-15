import dicom
from numpy import *
import numpy as np   #Fiks dette tullet senere
import scipy as sc
import matplotlib.pyplot as plt
import os
from congridfunc import congrid, conts, conts_sorts, punkt_indekses, rebin, pet_matrix_reader
from mpl_toolkits.mplot3d import Axes3D

vol = 52.5
d_low = 70.0
d_high = 90.0
p_low = 0.0 #0.05
p_high = 1.0 # 1.0 -p_low   #1.0 - 3./vol NB

set_base = 1.0
d_base = 50.0
m_r = 2
z_skal = 2.5 #Funnet manuelt, maa endres hvis annen opploesning, tror den alltid vil vaere lik snittykkelsen paa ct, ev bruke det.
#Henter inn RT-strukturer og lagrer
lokasjon = "Patient 1_test"      #NB! Lokasjon innad i Master mappen paa dropbox
lokasjon_pet = "Patient 1_test"  #Ditto

path = "../" + lokasjon
os.chdir(path)

print lokasjon

#Leser inn original dosefil

file_RD = []
for i in os.listdir(path):
	if os.path.isfile(os.path.join(path, i)) and 'RD' in i:
		file_RD.append(i)

#print file_RD

plan = dicom.read_file(file_RD[0])

#pikseldata, zdim lang, pikseldata[i] = array(uin), [xdunm ydim]
pikseldata = plan['7fe0', '0010'].value #IKKE print denne
xdim = float(plan['0028','0011'].value)
ydim = float(plan['0028','0010'].value)
zdim = float(plan['0028','0008'].value)
dose_skal = float(plan['3004','000E'].value)
posi = plan['0020','0032'].value
res_xy = plan['0028','0030'].value
bits_alloc = plan['0028','0100'].value
pixel_rep = plan['0028','0103'].value
sample_per = plan['0028','002'].value
high_b = plan['0028','0102'].value

xpos = float(posi[0])
ypos = float(posi[1])
zpos = float(posi[2])
res_x = float(res_xy[0])
res_y = float(res_xy[1])

dp_inv = zeros((abs(zdim), abs(ydim), abs(xdim))) #Antall snitt, rows og coloumns.
dim = [3, xdim, ydim, zdim, 4, zdim*ydim*xdim] #Gives the same as size in IDL. 3 is the dimension, 4 is a code (not sure if this is always four), and the last element is the total number of elements in dp_inv

#Finner pet-filer

path_p = "../" + lokasjon_pet
print path_p

file_P = []
for i in os.listdir(path_p):
	if os.path.isfile(os.path.join(path, i)) and 'PT' in i:
		file_P.append(i)

plan_p = dicom.read_file(file_P[0])
#Finner div tagger i PET-fil
xdim_p = float(plan_p['0028', '0011'].value)
ydim_p = float(plan_p['0028', '0010'].value)
posi_p = plan_p['0020', '0032'].value #hjoerne
res_xy_p = plan_p['0028', '0030'].value #pixel_spacing
z_skal_p = float(plan_p['0018', '0050'].value)

xpos_p = float(posi_p[0])
ypos_p = float(posi_p[1])

res_x_p = float(res_xy_p[0])
res_y_p = float(res_xy_p[1])

x_shift = round((xpos - xpos_p)/res_x)
y_shift = round((ypos - ypos_p)/res_y)
x_skal  = round(xdim_p*res_x_p/res_x) #NB! Round gjoer ting litt feil her
y_skal  = round(ydim_p*res_y_p/res_y)

pet_matrix = zeros((round(len(file_P)*z_skal_p/z_skal), abs(ydim), abs(xdim)))

adhoc_just = [0,1]

zpos_orig = zpos #Tar vare paa original zpos, hoerer til strukt osv.

#Her har Marius en test for alle filene, den kan skrives inn om det er forskyvning mellom PET og CT (dose?)


for i in range(0, 2):#len(file_P)):
	plan_temp = dicom.read_file(file_P[i])
	pikseldata_temp_direct  = np.flipud(plan_temp.pixel_array)    #Brukes til imshow
	pikseldata_temp = zeros(len(plan_temp.pixel_array)*len(plan_temp.pixel_array)) #Som den i IDL. En lang array med alle verdiene.
	counter = 0
	for j in plan_temp.pixel_array:
			for k in j:
				pikseldata_temp[counter] = k
				counter += 1
	conv_kern = plan_temp['0018', '1210'].value
	xd = plan_temp['0028', '0011'].value
	yd = plan_temp['0028', '0010'].value
	posi_d = plan_temp['0020', '0032'].value
	res_xy_d = plan_temp['0028', '0030'].value
	pet_skal = float(plan_temp['0028', '1053'].value) #OBS! Kan vaere ulikt for hvert snitt
	xpos_d = float(posi_d[0])
	ypos_d = float(posi_d[1])
	zpos_d = float(posi_d[2])
	res_x_d = float(res_xy_d[0])
	res_y_d = float(res_xy_d[1])

	temp = congrid(pikseldata_temp_direct, [x_skal, y_skal])  #congrid funnet paa: http://scipy-cookbook.readthedocs.io/items/Rebinning.html Example 3

	if zpos_d > zpos:
		for j in range(0, int(xdim)-1):
			j_p = j + x_shift + adhoc_just[0]
			if j_p > 0 and j_p < x_skal:
				for k in range(0, int(ydim)-1):
					k_p = k + y_shift + adhoc_just[1]
					if k_p > 0 and k_p < y_skal:
						pet_matrix[round((zpos_d - zpos)/z_skal), k, j] = pet_skal*temp[j_p, k_p] #Tror kanskje det skal vaere [k_p, j_p] Husk aa sjekke!

new_pet_dim = [3, len(pet_matrix[0][0]), len(pet_matrix[1]), len(pet_matrix), 4, len(pet_matrix[0][0])*len(pet_matrix[0])*len(pet_matrix)]   #3d, x-, y-, z-dim, kode, antall element

zpos = zpos_orig #Tilbake til zpos dosematrise, i tilfelle ulik ref.

#Interpolerer dersom det mangler pet-bilde, tror ikke denne fungerer som den skal.
for i in range(1, new_pet_dim[3] - 2):
	if max(pet_matrix[i][0]) == 0:
		pet_matrix[i][0] = 0.5*(pet_matrix[i - 1][0] + 0.5*pet_matrix[i + 1][0])   #Litt usikker paa valg av element her, men tror det er rett.
# 	if plan_temp['0020','0032'].value[2] >= -222 and plan_temp['0020','0032'].value[2] <= -221:
# 	#plt.plot(plan_temp.pixel_array)
# #plt.plot(plan_temp.pixel_array)
# 		counter = 0
# 		print len(plan_temp.pixel_array)
# 		pikseldata_temp = zeros(len(plan_temp.pixel_array)*len(plan_temp.pixel_array))
# 		for j in plan_temp.pixel_array:
# 			for k in j:
# 				pikseldata_temp[counter] = k
# 				counter += 1

# 		x_temp = linspace(0, max(pikseldata_temp), len(pikseldata_temp))
# 		#plt.imshow(plan_temp.pixel_array)
# 		print len(pikseldata_temp), 256*256
# 		#plt.plot(x_temp, pikseldata_temp)

# 		#plt.figure(1)

# 		print len(plan_temp.pixel_array), len(plan_temp.pixel_array[0])
# 		print plan_temp.pixel_array[30]

# 		temptemp = zeros((len(plan_temp.pixel_array), len(plan_temp.pixel_array), len(plan_temp.pixel_array)))

# 		temptemptemp = np.flipud(plan_temp.pixel_array)

# 		for j in range(0, len(plan_temp.pixel_array)-1):
# 			#print plan_temp.pixel_array[-j]
# 			temptemp[j] = plan_temp.pixel_array[-j]

# 		##temptemp = plan_temp.pixel_array[::1, ::-1]
# 		#for j in range(0, len(plan_temp.pixel_array)):
# 		#	print max(plan_temp.pixel_array[j]), max(temptemp[j])


# 		#plt.imshow(temptemp)

# 		plt.figure(2)
# 		plt.imshow(temptemptemp)
# 		#plt.imshow(plan_temp.pixel_array, origin = 'lower')
# 		plt.show()

# 		print plan_temp['0020','0032'].value[2]

cont = conts('../Patient 1_test/structures.txt')
cont_sort = conts_sorts('../Patient 1_test/structures_sort.txt')
for i in range(0, len(cont_sort)):
	cont_sort[i] = cont_sort[i][0:len(cont[i])]

punkt_indeks = punkt_indekses('../structures_punkt.txt')

dim_error = zeros(4)
dim_error[0] = x_shift*res_x - (-xpos_p + xpos)
dim_error[1] = y_shift*res_y - (-ypos_p + ypos)
dim_error[2] = x_skal/(xdim_p*res_x_p/res_x)
dim_error[3] = y_skal/(ydim_p*res_y_p/res_y)

print dim_error

#Gjoer om x og y til plass i pet_matrise (i dose ref), (plassering roi er i mm)
#Original, ev tilbake

for i in range(0, len(cont)):
	cont[i][:,0] = (cont[i][:,0] - xpos)/res_x
	cont[i][:,1] = (cont[i][:,1] - ypos)/res_y

#Faar orden paa indeksering av snittskifte i punktliste
for j in punkt_indeks:     #Bytter om paa normal rekkefoelge av i og j for aa faa bedre overensstemmelse med
	for i in range(len(j)-1, 0-1, -1):     #Marius sitt program.
		j[i] = sum(j[0:i+1])-j[i]

#sorterer punktliste etter stigende z
###############################################
### Dette ble veldig rotete, gjoer bedre!   ###
###############################################
counter = 0
s_i = []
for i in range(0, len(cont)):
	s_i.append([])
for j in cont:
	for i in punkt_indeks[counter]:
		s_i[counter].append(j[:, 2][i])
	counter += 1

s_i = array(s_i)

for i in range(0, len(s_i)):
	s_i[i] = sc.argsort(s_i[i])
###############################################

punkt_indeks_sort = [[] for i in range(0, len(punkt_indeks))]
print punkt_indeks_sort
for i in range(0, len(punkt_indeks_sort)):
	punkt_indeks_sort[i] = (zeros(len(punkt_indeks[i])))

count = 0
ant = 0

for j in range(0, len(cont)):
	count = 0
	ant = 0
	for i in range(0, len(s_i[j])):
		if s_i[j][i] == len(punkt_indeks[j])-1:
			ant = len(cont[j][:,2]) - punkt_indeks[j][s_i[j][i]]  
		else:
			ant = punkt_indeks[j][s_i[j][i] + 1] - punkt_indeks[j][s_i[j][i]]

		punkt_indeks_sort[j][i] = count

		cont_sort[j][punkt_indeks_sort[j][i]:punkt_indeks_sort[j][i]+ant] = cont[j][punkt_indeks[j][s_i[j][i]]:punkt_indeks[j][s_i[j][i]] + ant] #Marius hr til ant - 1, men python krever lister aa gaa ett steg lengre
		count = count + ant

zoomf = 1
xsize = xdim*zoomf
ysize = ydim*zoomf

print len(pet_matrix)
print xdim, ydim, round(len(file_P)*z_skal_p/z_skal)
#print pet_matrix
print len(pet_matrix[1, 1])
print len(pet_matrix[1])

pet_matrix = pet_matrix_reader('../pet_matrix.txt', xdim, ydim, round(len(file_P)*z_skal_p/z_skal))


#for i in range(0, len(pet_matrix)):
#	pet_matrix[i] = rebin(pet_matrix[i], xsize, ysize)


#plt.imshow(pet_matrix[97], origin = 'lower')
#plt.show()

counter = 0
for i in range(0, len(punkt_indeks_sort[0])):   #Endres til den lengste av alle punkt_indeks_sort
	for j in range(0, len(cont)):
		#print cont_sort[j][2,:]

		if i >= len(punkt_indeks_sort[j]):
			break
		else:
			snitt = ((cont_sort[j][punkt_indeks_sort[j][i], 2] - zpos)/z_skal)
			plt.imshow(pet_matrix[snitt], origin = 'lower', cmap = 'gray')
			if i != len(punkt_indeks_sort[j])-1:
				plt.plot(zoomf*cont_sort[j][punkt_indeks_sort[j][i]:punkt_indeks_sort[j][i+1], 0], zoomf*cont_sort[j][punkt_indeks_sort[j][i]:punkt_indeks_sort[j][i+1], 1])
			if i == len(punkt_indeks_sort[j])-1:
				plt.plot(zoomf*cont_sort[j][punkt_indeks_sort[j][i]:len(cont_sort[j]), 0], zoomf*cont_sort[j][punkt_indeks_sort[j][i]:len(cont_sort[j]), 1])
	plt.savefig('../../../../Pictures/mastertest/master%2d.png' %counter)
	plt.close()
	counter += 1
	
		#plt.plot(rebin(pet_matrix[:][:, snitt], zoomf*xdim, zoomf*ydim))
		#print len(pet_matrix[snitt][:, :])
		#print pet_matrix[snitt][:,:]
		#a = pet_matrix[snitt][:,:]

#import subprocess
#subprocess.call('convert -delay 8 -loop 0 ~/../../mnt/c/Users/Eirik/Pictures/mastertest/master*.png ~/../../mnt/c/Users/Eirik/Pictures/mastertest/anim.gif', shell=True)

		
plt.imshow(pet_matrix[97])
plt.show()
#for i in pet_matrix[97.6][:,:]:
	#print max(i)