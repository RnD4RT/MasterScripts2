# Script recorded 02 Nov 2016

#   RayStation version: 4.99.1.12
#   Selected patient: ...

from connect import *

beam_set = get_current("BeamSet")

x = [-0.3, 0, 0, 0.3, 0, 0, 0.3, -0.3]
y = [0, -0.3, 0, 0, 0.3, 0, 0.3, -0.3]
z = [0, 0, -0.3, 0, 0, 0.3, 0.3, -0.3]
counter = 0

for i in range(0, len(x)):
	print x[i], y[i], z[i]
	beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': x[i], 'y': y[i], 'z': z[i] }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)




#beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.3, 'y': 0.0, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)
#beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.0, 'y': 0.3, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)
#beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.0, 'y': 0.0, 'z': 0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)
#beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': -0.3, 'y': 0.0, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)
#beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.0, 'y': -0.3, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)
#beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.0, 'y': 0.0, 'z': -0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)