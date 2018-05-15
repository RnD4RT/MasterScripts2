#######################################################################################################
#######################################################################################################
###############		Created by Eirik Ramsli Hauge										###############
###############     Based on: Program given by RayStation upon request          		###############
###############		Contact: eirikhauge@hotmail.com										###############
###############		Feel free to ask if anythings wrong :)      						############### 
#######################################################################################################
#######################################################################################################


from connect import *

import struct
from array import array
path = r'C:\Users\eiraha\Documents\DoseData'

#export the fraction dose
patient = get_current("Patient")
plan = get_current('Plan')
beam_set = get_current("BeamSet")
dose = beam_set.FractionDose
fractions = beam_set.FractionationPattern.NumberOfFractions
filename = path + r'\fraction_dose_patient_%s_Doseplan_%s_BeamSet_%s.dat' %(patient.PatientName, plan.Name, str(str(beam_set).split("'")[1]))
# ----------------------------------------------------------------------------------------------

# write the dose file

#open file
file = open(filename, 'wb')

# write dose grid dimensions
dg = dose.InDoseGrid
# number of voxels (DICOM axes x, y and z)
file.write(struct.pack('III', dg.NrVoxels.x, dg.NrVoxels.y, dg.NrVoxels.z))
#voxel size
file.write(struct.pack('ddd', dg.VoxelSize.x, dg.VoxelSize.y, dg.VoxelSize.z))
#corner of the corner voxel (cm)
file.write(struct.pack('ddd', dg.Corner.x, dg.Corner.y, dg.Corner.z))

# write the number of fractions
file.write(struct.pack('I', fractions))

# write the length of the dose array and the array (cGy)
binary_dose = dose.DoseValues.DoseData
length = len(binary_dose)
file.write(struct.pack('I', length))
array('d', binary_dose).tofile(file)

# done
file.close()