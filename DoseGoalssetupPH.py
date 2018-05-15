# Script recorded 31 Jan 2018

#   RayStation version: 4.99.1.12
#   Selected patient: ...

from connect import *

plan = get_current("Plan")
db = get_current("PatientDB")

plan.PlanOptimizations[2].ApplyOptimizationTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_ph_hn'])

plan.TreatmentCourse.EvaluationSetup.ApplyClinicalGoalTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_del'])


plan.PlanOptimizations[1].ApplyOptimizationTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_ph_hn'])


structure_set = plan.GetStructureSet()
roi_names = sorted([rg.OfRoi.Name for rg in structure_set.RoiGeometries if rg.PrimaryShape != None])
name_list = ["Parotid_L", "Parotid_R", "Submandibular_L", "Submandibular_R", "SpinalCord_PRV"]
FunctionTypeList = ["MaxEud", "MaxEud", "MaxEud", "MaxEud", "MaxDose"]
retval_list = ["retval_%d" %i for i in range(0, len(name_list))]
index_list = [0, 1, 2, 3, 5]
exsisting_list = []

counter2 = 0
for j in name_list:
	counter = 0
	for i in roi_names:
		if j == i:
			counter = 1
	if counter == 1:
		exsisting_list.append(counter2)
	counter2 += 1


for i in range(0, len(exsisting_list)):
	with CompositeAction('Edit Optimization Function'):
		retval_list[i] = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="%s" %FunctionTypeList[i], DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[index_list[i]], RoiName="%s" %name_list[i], IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)
	
with CompositeAction('Edit Optimization Function'):

  retval_4 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[4], RoiName="SpinalCord", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_6 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MinDvh", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[6], RoiName="GTV68", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_7 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="UniformDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[7], RoiName="CTV54_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_8 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="UniformDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[8], RoiName="CTV64_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_9 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="DoseFallOff", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[9], RoiName="External", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_10 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[10], RoiName="External", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)
  plan.PlanOptimizations[1].Objective.ConstituentFunctions[10].DoseFunctionParameters.DoseLevel = 9000
  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_11 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[11], RoiName="CTV64_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_12 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[12], RoiName="CTV54_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_13 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="UniformDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[13], RoiName="GTV68", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet=None, UseRbeDose=False)

  plan.PlanOptimizations[1].Objective.ConstituentFunctions[13].DoseFunctionParameters.DoseLevel = 11800

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_14 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MinDvh", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[14], RoiName="CTV64_eks_5mm", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=True, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_15 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MinDvh", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[15], RoiName="CTV54_eks_5mm", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=True, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_16 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MinDvh", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[16], RoiName="GTV68", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=True, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 
  
  
plan.PlanOptimizations[1].OptimizationParameters.SaveRobustnessParameters(PositionUncertaintyAnterior=0.6, PositionUncertaintyPosterior=0.6, PositionUncertaintySuperior=0.6, PositionUncertaintyInferior=0.6, PositionUncertaintyLeft=0.6, PositionUncertaintyRight=0.6, DensityUncertainty=0, IndependentBeams=False, ComputeExactScenarioDoses=False, NamesOfNonPlanningExaminations=[])
plan.PlanOptimizations[2].OptimizationParameters.SaveRobustnessParameters(PositionUncertaintyAnterior=0.6, PositionUncertaintyPosterior=0.6, PositionUncertaintySuperior=0.6, PositionUncertaintyInferior=0.6, PositionUncertaintyLeft=0.6, PositionUncertaintyRight=0.6, DensityUncertainty=0, IndependentBeams=False, ComputeExactScenarioDoses=False, NamesOfNonPlanningExaminations=[])
