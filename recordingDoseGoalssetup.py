# Script recorded 31 Jan 2018

#   RayStation version: 4.99.1.12
#   Selected patient: ...

from connect import *

plan = get_current("Plan")
db = get_current("PatientDB")


plan.PlanOptimizations[2].ApplyOptimizationTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_ph_hn'])

plan.TreatmentCourse.EvaluationSetup.ApplyClinicalGoalTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_del'])

plan.PlanOptimizations[2].OptimizationParameters.SaveRobustnessParameters(PositionUncertaintyAnterior=0.6, PositionUncertaintyPosterior=0.6, PositionUncertaintySuperior=0.6, PositionUncertaintyInferior=0.6, PositionUncertaintyLeft=0.6, PositionUncertaintyRight=0.6, DensityUncertainty=0, IndependentBeams=False, ComputeExactScenarioDoses=False, NamesOfNonPlanningExaminations=[])

# Unscriptable Action 'Modify optimization settings' Completed : SaveOptimizationSettingsAction(...)

# Unscriptable Action 'Save' Completed : SaveAction(...)

plan.PlanOptimizations[1].ApplyOptimizationTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_ph_hn'])

with CompositeAction('Edit Optimization Function'):

  retval_0 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxEud", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[0], RoiName="Parotid_L", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_1 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxEud", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[1], RoiName="Parotid_R", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_2 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxEud", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[2], RoiName="Submandibular_L", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_3 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxEud", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[3], RoiName="Submandibular_R", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_4 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[4], RoiName="SpinalCord", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_5 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[5], RoiName="SpinalCord_PRV", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_ph_dpbn", UseRbeDose=False)

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


# Unscriptable Action 'Save' Completed : SaveAction(...)

plan.PlanOptimizations[2].ApplyOptimizationTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_pro'])

plan.TreatmentCourse.EvaluationSetup.ApplyClinicalGoalTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_del'])

# Unscriptable Action 'Save' Completed : SaveAction(...)

plan.PlanOptimizations[1].ApplyOptimizationTemplate(Template=db.TemplateTreatmentOptimizations['Eirik_rob_pro'])

with CompositeAction('Edit Optimization Function'):

  retval_17 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxEud", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[0], RoiName="Parotid_R", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_18 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxEud", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[1], RoiName="Parotid_L", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_19 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxEud", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[2], RoiName="Submandibular_R", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_20 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxEud", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[3], RoiName="Submandibular_L", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


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

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_27 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[10], RoiName="CTV64_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_28 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[11], RoiName="CTV54_eks", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

  # CompositeAction ends 


with CompositeAction('Edit Optimization Function'):

  retval_29 = plan.PlanOptimizations[1].EditOptimizationFunction(FunctionType="MaxDose", DoseBasedRoiFunction=plan.PlanOptimizations[1].Objective.ConstituentFunctions[12], RoiName="SpinalCord_PRV", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet="rob_p_dpbn", UseRbeDose=False)

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

