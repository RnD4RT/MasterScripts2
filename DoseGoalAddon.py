# Script recorded 22 Feb 2018

#   RayStation version: 4.99.1.12
#   Selected patient: ...

from connect import *

plan = get_current("Plan")


with CompositeAction('Add Optimization Function'):

  retval_0 = plan.PlanOptimizations[2].AddOptimizationFunction(FunctionType="MaxDose", RoiName="ho oye mee", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet=None, UseRbeDose=False)

  plan.PlanOptimizations[2].Objective.ConstituentFunctions[17].DoseFunctionParameters.DoseLevel = 3000

  # CompositeAction ends 


with CompositeAction('Add Optimization Function'):

  retval_1 = plan.PlanOptimizations[2].AddOptimizationFunction(FunctionType="MaxDose", RoiName="linse ho mee", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet=None, UseRbeDose=False)

  plan.PlanOptimizations[2].Objective.ConstituentFunctions[18].DoseFunctionParameters.DoseLevel = 500

  # CompositeAction ends 


with CompositeAction('Add Optimization Function'):

  retval_2 = plan.PlanOptimizations[2].AddOptimizationFunction(FunctionType="MaxDose", RoiName="n. opt. dex mee", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet=None, UseRbeDose=False)

  plan.PlanOptimizations[2].Objective.ConstituentFunctions[19].DoseFunctionParameters.DoseLevel = 5400

  # CompositeAction ends 


with CompositeAction('Add Optimization Function'):

  retval_3 = plan.PlanOptimizations[2].AddOptimizationFunction(FunctionType="MaxDose", RoiName="Chisma/brt", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet=None, UseRbeDose=False)

  plan.PlanOptimizations[2].Objective.ConstituentFunctions[20].DoseFunctionParameters.DoseLevel = 5400

  # CompositeAction ends 


plan.TreatmentCourse.EvaluationSetup.AddClinicalGoal(RoiName="ho oye mee", GoalCriteria="AtMost", GoalType="DoseAtAbsoluteVolume", AcceptanceLevel=3000, ParameterValue=0, IsComparativeGoal=False, Priority=2147483647)

plan.TreatmentCourse.EvaluationSetup.AddClinicalGoal(RoiName="linse ho mee", GoalCriteria="AtMost", GoalType="DoseAtAbsoluteVolume", AcceptanceLevel=1000, ParameterValue=0, IsComparativeGoal=False, Priority=2147483647)

plan.TreatmentCourse.EvaluationSetup.AddClinicalGoal(RoiName="n. opt. dex mee", GoalCriteria="AtMost", GoalType="DoseAtAbsoluteVolume", AcceptanceLevel=5400, ParameterValue=0, IsComparativeGoal=False, Priority=2147483647)

plan.TreatmentCourse.EvaluationSetup.AddClinicalGoal(RoiName="Chisma/brt", GoalCriteria="AtMost", GoalType="DoseAtAbsoluteVolume", AcceptanceLevel=5400, ParameterValue=0, IsComparativeGoal=False, Priority=2147483647)

plan.TreatmentCourse.EvaluationSetup.AddClinicalGoal(RoiName="Medulla oblongata/brt", GoalCriteria="AtMost", GoalType="DoseAtAbsoluteVolume", AcceptanceLevel=5400, ParameterValue=0, IsComparativeGoal=False, Priority=2147483647)

plan.TreatmentCourse.EvaluationSetup.AddClinicalGoal(RoiName="margin til Medulla oblongata", GoalCriteria="AtMost", GoalType="DoseAtAbsoluteVolume", AcceptanceLevel=5600, ParameterValue=0, IsComparativeGoal=False, Priority=2147483647)

with CompositeAction('Add Optimization Function'):

  retval_4 = plan.PlanOptimizations[2].AddOptimizationFunction(FunctionType="MaxDose", RoiName="Medulla oblongata/brt", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet=None, UseRbeDose=False)

  plan.PlanOptimizations[2].Objective.ConstituentFunctions[21].DoseFunctionParameters.DoseLevel = 5400

  # CompositeAction ends 


with CompositeAction('Add Optimization Function'):

  retval_5 = plan.PlanOptimizations[2].AddOptimizationFunction(FunctionType="MaxDose", RoiName="margin til Medulla oblongata", IsConstraint=False, RestrictAllBeamsIndividually=False, RestrictToBeam=None, IsRobust=False, RestrictToBeamSet=None, UseRbeDose=False)

  plan.PlanOptimizations[2].Objective.ConstituentFunctions[22].DoseFunctionParameters.DoseLevel = 5600

  # CompositeAction ends 


