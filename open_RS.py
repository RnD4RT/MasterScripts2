import dicom
from numpy import *
import os

path = '../pats/Patient 1'
#os.chdir(path)
file_RS = []
for i in os.listdir(path):
	if os.path.isfile(os.path.join(path, i)) and 'RS' in i:
		file_RS.append(path + '/' + i)

print file_RS
plan = dicom.read_file(file_RS[0])

#print (plan['3006','0050'].value)
print plan.RoiName