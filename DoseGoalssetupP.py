from connect import *

plan = get_current("Plan")
db = get_current("PatientDB")



# Unscriptable Action 'Save' Completed : SaveAction(...)

plan.PlanOptimizations[2].ApplyOptimizationTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_pro'])

plan.TreatmentCourse.EvaluationSetup.ApplyClinicalGoalTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_del'])

# Unscriptable Action 'Save' Completed : SaveAction(...)

plan.PlanOptimizations[1].ApplyOptimizationTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_pro'])

structure_set = plan.GetStructureSet()
roi_names = sorted([rg.OfRoi.Name for rg in structure_set.RoiGeometries if rg.PrimaryShape != None])
name_list = ["Parotid_R", "Parotid_L", "Submandibular_R", "Submandibular_L", "SpinalCord_PRV"]
FunctionTypeList = ["MaxEud", "MaxEud", "MaxEud", "MaxEud", "MaxDose"]
index_list = [0, 1, 2, 3, 12]
retval_list = ["retval_%d" %i for i in index_list]
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
		retval_list[i] = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="%s" %FunctionTypeList[i], DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[index_list[i]], RoiName="%s" %name_list[i], IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)
	

with CompositeAction('Edit Optimization Function'):

  retval_21 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[4], RoiName="SpinalCord", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_22 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="UniformDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[5], RoiName="GTV68", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet=None, UseRbeDose=False)

  plan.PlanOptimizations[1].Objective.ConstituentFunctions[5].DoseFunctionParameters.DoseLevel = 11800

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_23 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="UniformDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[6], RoiName="CTV54_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_24 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="UniformDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[7], RoiName="CTV64_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_25 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="DoseFallOff", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[8], RoiName="External", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_26 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[9], RoiName="External", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)
  plan.PlanOptimizations[1].Objective.ConstituentFunctions[9].DoseFunctionParameters.DoseLevel = 9000
  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_27 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[10], RoiName="CTV64_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_28 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[11], RoiName="CTV54_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 

with CompositeAction('Edit Optimization Function'):

  retval_30 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MinDvh", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[13], RoiName="GTV68", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=True, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_31 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MinDvh", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[14], RoiName="CTV64_eks_5mm", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=True, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_32 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MinDvh", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[15], RoiName="CTV54_eks_5mm", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=True, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_33 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="DoseFallOff", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[16], RoiName="External", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


# Unscriptable Action 'Modify optimization settings' Completed : SaveOptimizationSettingsAction(...)

plan.PlanOptimizations[1].OptimizationParameters.SaveRobustnessParameters(PositionUncertaintyAnterior=0.6, PositionUncertaintyPosterior=0.6, PositionUncertaintySuperior=0.6, PositionUncertaintyInferior=0.6, PositionUncertaintyLeft=0.6, PositionUncertaintyRight=0.6, DensityUncertainty=0.03, IndependentBeams=False, ComputeExactScenarioDoses=False, NamesOfNonPlanningExaminations=[])
plan.PlanOptimizations[2].OptimizationParameters.SaveRobustnessParameters(PositionUncertaintyAnterior=0.6, PositionUncertaintyPosterior=0.6, PositionUncertaintySuperior=0.6, PositionUncertaintyInferior=0.6, PositionUncertaintyLeft=0.6, PositionUncertaintyRight=0.6, DensityUncertainty=0.03, IndependentBeams=False, ComputeExactScenarioDoses=False, NamesOfNonPlanningExaminations=[])

