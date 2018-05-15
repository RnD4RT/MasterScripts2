from connect import *
import struct
from array import array

path = r'C:\Users\eiraha\Documents\DoseData'

patient = get_current("Patient")
plan = get_current('Plan')
beam_set = get_current("BeamSet")
case = get_current("Case")
fractions = beam_set.FractionationPattern.NumberOfFractions
filename = path + r'\Clincal_selfs_patient_%s_Doseplan_%s_BeamSet_%s.dat' %(patient.PatientName, plan.Name, str(str(beam_set).split("'")[1]))

EvalFunck = plan.TreatmentCourse.EvaluationSetup.EvaluationFunctions

class Clincalself:
	def __init__(self, EvaluationFunction = None):
		Function = EvaluationFunction
		self.ROIName = Function.ForRegionOfInterest.Name
		self.Level = Planningself.AcceptanceLevel
		self.Type = Planningself.Type
		self.Value = Planningself.ParameterValue
		self.Criteria = Planningself.selfCriteria
		self.Actual = 0
		
		#Special case: for AverageDose there is no self.Value
		if self.Type == "AverageDose":
			VALUE.Value2 = ""
		#Now load the actual value 
		#ACTUAL.Value2 = 1234.5 #PLACEHOLDER
		if self.Type == "AbsoluteVolumeAtDose":
			PercentV_at_Dose = dose_distribution.GetRelativeVolumeAtDoseValues(RoiName = self.ROIName, DoseValues = [self.Value])
			volume_scaler = dose_distribution.GetDoseGridRoi(RoiName = self.ROIName).RoiVolumeDistribution.TotalVolume
			Vol_at_Dose = [x * volume_scaler for x in PercentV_at_Dose]    
			self.Actual = Vol_at_Dose[0]
		elif self.Type == "VolumeAtDose":
			PercentV_at_Dose = dose_distribution.GetRelativeVolumeAtDoseValues(RoiName = self.ROIName, DoseValues = [self.Value])
			self.Actual = PercentV_at_Dose[0]
		elif self.Type == "DoseAtVolume":
			Dose_at_PercentV = dose_distribution.GetDoseAtRelativeVolumes(RoiName = self.ROIName, RelativeVolumes = [self.Value])
			self.Actual = Dose_at_PercentV[0]
		elif self.Type == "DoseAtAbsoluteVolume":
			volume_scaler = dose_distribution.GetDoseGridRoi(RoiName = self.ROIName).RoiVolumeDistribution.TotalVolume
			Percent_V = self.Value/volume_scaler #TotalVolume could be less than self.Value, but percent can't go above 1.0
			if Percent_V <= 1.0:            
				Dose_at_PercentV = dose_distribution.GetDoseAtRelativeVolumes(RoiName = self.ROIName, RelativeVolumes = [Percent_V])
				self.Actual = Dose_at_PercentV[0]
			else:
				self.Actual = 0.0
		elif self.Type == "AverageDose":
			AverageDose = dose_distribution.GetDoseStatistic(RoiName = self.ROIName, DoseType = "Average")
			self.Actual = AverageDose
		
selfs = []
for Function in EvalFunck:
	selfs.append(Clincalself(Function))
	
print selfs
