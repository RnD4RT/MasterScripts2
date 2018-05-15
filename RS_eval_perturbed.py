# Script recorded 02 Nov 2016

#   RayStation version: 4.99.1.12
#   Selected patient: ...

from connect import *
import struct
from array import array

path = r'C:\Users\eiraha\Documents\DoseData'

patient = get_current("Patient")
plan = get_current('Plan')
beam_set = get_current("BeamSet")
case = get_current("Case")
fractions = beam_set.FractionationPattern.NumberOfFractions
filename = path + r'\perturbed_dose_patient_%s_Doseplan_%s_BeamSet_%s.dat' %(patient.PatientName, plan.Name, str(str(beam_set).split("'")[1]))


dose1  = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[1]
dose2  = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[2]
dose3  = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[3]
dose4  = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[4]
dose5  = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[5]
dose6  = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[6]
dose7  = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[7]
dose8  = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[8]
dose9  = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[9]
dose10 = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[10]
dose11 = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[11]
dose12 = patient.Cases[case.CaseName].TreatmentDelivery.FractionEvaluations[0].DoseOnExaminations[0].DoseEvaluations[12]

doses = [dose1, dose2, dose3, dose4, dose5, dose6, dose7, dose8, dose9, dose10, dose11, dose12]

# write dose grid dimensions
dg = dose1.InDoseGrid
# number of voxels (DICOM axes x, y and z)
file.write(struct.pack('III', dg.NrVoxels.x, dg.NrVoxels.y, dg.NrVoxels.z))
#voxel size
file.write(struct.pack('ddd', dg.VoxelSize.x, dg.VoxelSize.y, dg.VoxelSize.z))
#corner of the corner voxel (cm)
file.write(struct.pack('ddd', dg.Corner.x, dg.Corner.y, dg.Corner.z))

# write the number of fractions
file.write(struct.pack('I', fractions))

for i in doses:
	# write the length of the dose array and the array (cGy)
	binary_dose = i.DoseValues.DoseData
	length = len(binary_dose)
	file.write(struct.pack('I', length))
	array('d', binary_dose).tofile(file)