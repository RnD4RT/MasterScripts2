import numpy as np
import os
import dicom
import matplotlib.pyplot as plt
import cv2
from scipy.interpolate import RegularGridInterpolator

Patient = "Patient 1"
PathDicom = "../pats/" + Patient + "/"

lstFilesPET = []
lstFilesCT  = []

for dirName, subdirList, fileList in os.walk(PathDicom):
	for filename in fileList:
		if ".dcm" in filename.lower() and filename[:2] == "PT":
			lstFilesPET.append(os.path.join(dirName, filename))
		elif ".dcm" in filename.lower() and filename[:2] == "CT":
			lstFilesCT.append(os.path.join(dirName, filename))


RefPETs = dicom.read_file(lstFilesPET[0])
RefCTs = dicom.read_file(lstFilesCT[0])

ConstPixelDimsPET = (int(RefPETs.Rows), int(RefPETs.Columns), len(lstFilesPET))
ConstPixelSpacingPET = (float(RefPETs.PixelSpacing[0]), float(RefPETs.PixelSpacing[1]), float(RefPETs.SliceThickness))

ConstPixelDimsCT = (int(RefCTs.Rows), int(RefCTs.Columns), len(lstFilesCT))
ConstPixelSpacingCT = (float(RefCTs.PixelSpacing[0]), float(RefCTs.PixelSpacing[1]), float(RefCTs.SliceThickness))

xPET = np.arange(0.0, (ConstPixelDimsPET[0]+1)*ConstPixelSpacingPET[0], ConstPixelSpacingPET[0])
yPET = np.arange(0.0, (ConstPixelDimsPET[1]+1)*ConstPixelSpacingPET[1], ConstPixelSpacingPET[1])
zPET = np.arange(0.0, (ConstPixelDimsPET[2]+1)*ConstPixelSpacingPET[2], ConstPixelSpacingPET[2])

xCT = np.arange(0.0, (ConstPixelDimsCT[0]+1)*ConstPixelSpacingCT[0], ConstPixelSpacingCT[0])
yCT = np.arange(0.0, (ConstPixelDimsCT[1]+1)*ConstPixelSpacingCT[1], ConstPixelSpacingCT[1])
zCT = np.arange(0.0, (ConstPixelDimsCT[2]+1)*ConstPixelSpacingCT[2], ConstPixelSpacingCT[2])

print RefPETs.PixelSpacing
print RefCTs.PixelSpacing

print RefPETs.ImagePositionPatient
print RefCTs.ImagePositionPatient


ArrayDicomPET = np.zeros(ConstPixelDimsPET, dtype = RefPETs.pixel_array.dtype)
print ConstPixelDimsPET[0], ConstPixelDimsPET[1], ConstPixelDimsPET[2]
Res_Masked_PET = np.zeros((ConstPixelDimsPET[0]*2, ConstPixelDimsPET[1]*2, ConstPixelDimsPET[2]), dtype = RefPETs.pixel_array.dtype)
Masked_PET = ArrayDicomPET 
ArrayDicomCT = np.zeros(ConstPixelDimsCT, dtype = RefCTs.pixel_array.dtype)

PET_z_sort = np.zeros(len(zPET))
CT_z_sort = np.zeros(len(zCT))

for filenamePET in lstFilesPET:
	ds = dicom.read_file(filenamePET)
	ArrayDicomPET[:, :, lstFilesPET.index(filenamePET)] = ds.pixel_array
	Masked_PET[:, :, lstFilesPET.index(filenamePET)] = np.ma.masked_where(ArrayDicomPET[:, :, lstFilesPET.index(filenamePET)] < 50, ArrayDicomPET[:, :, lstFilesPET.index(filenamePET)])
	Res_Masked_PET[:, :, lstFilesPET.index(filenamePET)] = cv2.resize(Masked_PET[:, :, lstFilesPET.index(filenamePET)], dsize=(512, 512), interpolation=cv2.INTER_CUBIC)
	PET_z_sort[lstFilesPET.index(filenamePET)] = ds.SliceLocation

	###SORTER PET OG CT LIKT, FLYTT PET SITT VENSTRE HJORNE TIL AA PASSE MED CT SITT VENSTRE HJORNE

for filenameCT in lstFilesCT:
	ds = dicom.read_file(filenameCT)
	ArrayDicomCT[:, :, lstFilesCT.index(filenameCT)] = ds.pixel_array
	CT_z_sort[lstFilesCT.index(filenameCT)] = ds.SliceLocation

print ArrayDicomPET.shape
print PET_z_sort, len(PET_z_sort)
print CT_z_sort, len(CT_z_sort)


data = np.meshgrid(xPET, yPET, PET_z_sort)
data2 = np.meshgrid(xCT, yCT, CT_z_sort)

print xPET, yPET, zPET
print xCT, yCT, zCT

# fn = RegularGridInterpolator(data, ArrayDicomPET)
# NewPET = fn(data2)



a = np.zeros(shape=(ConstPixelDimsPET))

print len(xCT), len(yCT), len(zCT), len(xPET), len(yPET), len(zPET)
np.delete(xPET, -1)
np.delete(yPET, -1)
print len(xCT), len(yCT), len(zCT), len(xPET), len(yPET), len(zPET)

#hopethisgoeswell = [np.array([i, i, i]) for i in range(0, len(xCT) * len(yCT) * len(zCT))]
#hopethisgoeswell = [((np.array([i, j, k]) for k in range(0, len(kCT))) for j in range(0, len(yCT))) for i in range(0, len(xCT))]

print "Hammer time!"

fn = RegularGridInterpolator((xPET[:-1], yPET[:-1], zPET[:-1]), ArrayDicomPET)

test = np.zeros(shape=ArrayDicomCT.shape, dtype = np.ndarray)

xDim = np.linspace(0, 512, 513)
yDim = xDim
zDim = np.linspace(0, len(zCT)-1, len(zCT))

counter = 0
for i in range(0, len(xDim)-1):
	print i/float(len(xDim) - 1)
	for j in range(0, len(yDim)-1):
		#test[i, j, 100] = fn(np.array([i, j, 100]))
		 for k in range(0, len(zDim)-1):
		# 	counter += 1
		 	test[i, j, k] = np.array([i, j, k])

test2 = np.zeros(shape=ArrayDicomCT.shape)

for i in len(0, )

# for i in range(0, len(test)):
# 	print i
# 	for j in range(0, len(test[i])):
# 		for k in range(0, len((test[i])[j])):
# 			test[i, j, k] = fn(test[i, j, k])



print "Stop"

#x = np.meshgrid(xDim, yDim, zDim, indexing='ij')

test = np.zeros(shape=ArrayDicomCT.shape)

# counter = 0
# for i in range(0, len(xDim)-1):
# 	print i/float(len(xDim) - 1)
# 	for j in range(0, len(yDim)-1):
# 		test[i, j, 100] = fn(np.array([i, j, 100]))
# 		# for k in range(0, len(zDim)-1):
# 		# 	counter += 1
# 		# 	test[i,j, k] = fn(np.array([i, j, k]))

fig, ax = plt.subplots()
#ax.axes().set_aspect('equal', 'datalim')
#ax.set_cmap(plt.gray())
ax.imshow(np.flipud(ArrayDicomCT[:, :, 100]), cmap = 'gray', interpolation = 'none')
ax.imshow(np.flipud(ArrayDicomPET[:, :, 100]), cmap = 'jet', alpha = 0.3, interpolation = 'none')
#ax.imshow(np.flipud(test[:, :, 100]), cmap = 'jet', alpha = 0.7)
plt.show()