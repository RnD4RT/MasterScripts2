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
fractions = beam_set.FractionationPattern.NumberOfFractions


beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.3, 'y': 0.0, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.0, 'y': 0.3, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.0, 'y': 0.0, 'z': 0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': -0.3, 'y': 0.0, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.0, 'y': -0.3, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=0.03, IsocenterShift={ 'x': 0.0, 'y': 0.0, 'z': -0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': 0.3, 'y': 0.0, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': 0.0, 'y': 0.3, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': 0.0, 'y': 0.0, 'z': 0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': -0.3, 'y': 0.0, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': 0.0, 'y': -0.3, 'z': 0.0 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': 0.0, 'y': 0.0, 'z': -0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

#beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': -0.3, 'y': -0.3, 'z': -0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

#beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': -0.3, 'y': -0.3, 'z': 0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

#beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': -0.3, 'y': 0.3, 'z': -0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)

#beam_set.ComputePerturbedDose(DensityPerturbation=-0.03, IsocenterShift={ 'x': -0.3, 'y': 0.3, 'z': 0.3 }, IsDoseConsideredClinical=False, OnlyOneDosePerImageSet=False, AllowGridExpansion=False, ExaminationNames=["CT 1"], FractionNumbers=[0], ComputeBeamDoses=True)
