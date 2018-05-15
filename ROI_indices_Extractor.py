from connect import *
import struct
from array import array

path = r'C:\Users\eiraha\Documents\DoseData'

patient = get_current("Patient")
plan = get_current('Plan')
beam_set = get_current("BeamSet")
case = get_current("Case")
fractions = beam_set.FractionationPattern.NumberOfFractions
#filename = path + r'\ROI_indices_patient_%s_Doseplan_%s_BeamSet_%s.dat' %(patient.PatientName, plan.Name, str(str(beam_set).split("'")[1]))

structure_set = plan.GetStructureSet()
roi_names = [rg.OfRoi.Name for rg in structure_set.RoiGeometries if rg.PrimaryShape != None]

roi_really_wants = ['GTV68', 'PTV68', 'PTV68_eks', 'PTV64', 'PTV64_eks', 'PTV64_eks_5mm', 'PTV54_eks_5mm', 'CTV64', 'CTV64_eks', 'CTV54_eks', 'CTV64_eks_5mm', 'CTV54_eks_5mm', 'Parotid_R', 'Parotid_L', 'Submandibular_L', 'Submandibular_R', 'SpinalCord', 'SpinalCord_PRV', ]
#indices_ROIs = {'GTV68' : 0, 'PTV68' : 0, 'PTV64' : 0, 'CTV64' : 0, 'CTV64_eks' : 0, 'CTV54_eks' : 0, 'CTV64_eks_5mm' : 0, 'CTV54_eks_5mm' : 0, 'Parotid_R' : 0, 'Parotid_L' : 0, 
#			'Submandibular_L' : 0, 'Submandibular_R' : 0, 'SpinalCord' : 0}

#roi_wants = ['Parotid_R']
#indices_ROIs = {'Parotid_R' : 0}

roi_not_wants = ['External', 'ext_sub', 'CTV_64_temp', 'CTV_54_temp']

roi_names = [e for e in roi_names if e not in roi_not_wants]

for i in roi_names:
	print i
	name = list(i)
	for j in range(0, len(name)):
		if name[j] == '\\':
			name[j] = '-'
		elif name[j] == '/':
			name[j] = '-'
		elif name[j] == ' ':
			name[j] = '_'
		elif name[j] == '<':
			name[j] = 'lt'
		elif name[j] == '>':
			name[j] = 'gt'
	name = "".join(name)
	print name
	filename = path + r'\ROIindices\%s.txt' %name
	file = open(filename, 'w')
	indices_ROIs = beam_set.FractionDose.GetDoseGridRoi(RoiName=i).RoiVolumeDistribution.VoxelIndices
	length = len(list(indices_ROIs))
	length2 = len(indices_ROIs)
	print length, length2
	#print indices_ROIs
	file.write('%d \r\n' %length)
	file.write('%d \r\n' %int(list(indices_ROIs)[-1]))
	file.write('\r\n')
	for j in list(indices_ROIs):
		file.write('%d \r\n' %j)
	#file.write(struct.pack('%dI' %length, list(indices_ROIs)))
	#s = beam_set.FractionDose.GetDoseGridRoi(RoiName='Parotid_L').RoiVolumeDistribution.VoxelIndices