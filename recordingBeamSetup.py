# Script recorded 31 Jan 2018

#   RayStation version: 4.99.1.12
#   Selected patient: ...

from connect import *

case = get_current("Case")


with CompositeAction('Add new beam set'):

  # CompositeAction ends 


with CompositeAction('Set beam set dependencies'):

  # CompositeAction ends 


with CompositeAction('Add dose prescriptions'):

  # CompositeAction ends 


# Unscriptable Action 'Edit plan' Completed : SaveEditedPlanAndTreatmentSetupCompositeAction(...)

# Unscriptable Action 'Add template beams (Beam Set: rob_ph)' Completed : ApplyTreatmentSetupTemplateAction(...)

# Unscriptable Action 'Add template beams (Beam Set: rob_ph_dpbn)' Completed : ApplyTreatmentSetupTemplateAction(...)

# Unscriptable Action 'Save' Completed : SaveAction(...)

case.CopyPlan(PlanName="Inv", NewPlanName="rob_p")

# Unscriptable Action 'Save' Completed : SaveAction(...)

with CompositeAction('Add new beam set'):

  # CompositeAction ends 


with CompositeAction('Set beam set dependencies'):

  # CompositeAction ends 


with CompositeAction('Add dose prescriptions'):

  # CompositeAction ends 


# Unscriptable Action 'Edit plan' Completed : SaveEditedPlanAndTreatmentSetupCompositeAction(...)

# Unscriptable Action 'Add template beams (Beam Set: rob_p)' Completed : ApplyTreatmentSetupTemplateAction(...)

with CompositeAction('Update isocenter (1_70gr, Beam Set: rob_p)'):

  retval_0 = beam_set.Beams['1_70gr'].SetIsocenter(Name="rob_p 2")

  # CompositeAction ends 


with CompositeAction('Update isocenter (2_180gr, Beam Set: rob_p)'):

  retval_1 = beam_set.Beams['2_180gr'].SetIsocenter(Name="rob_p 2")

  # CompositeAction ends 


with CompositeAction('Update isocenter (3_290gr, Beam Set: rob_p)'):

  retval_2 = beam_set.Beams['3_290gr'].SetIsocenter(Name="rob_p 2")

  # CompositeAction ends 


# Unscriptable Action 'Add template beams (Beam Set: rob_p_dpbn)' Completed : ApplyTreatmentSetupTemplateAction(...)

with CompositeAction('Update isocenter (1_70gr, Beam Set: rob_p_dpbn)'):

  retval_3 = beam_set.Beams['1_70gr'].SetIsocenter(Name="rob_p_dpbn 1")

  # CompositeAction ends 


with CompositeAction('Update isocenter (2_180gr, Beam Set: rob_p_dpbn)'):

  retval_4 = beam_set.Beams['2_180gr'].SetIsocenter(Name="rob_p_dpbn 1")

  # CompositeAction ends 


with CompositeAction('Update isocenter (3_290gr, Beam Set: rob_p_dpbn)'):

  retval_5 = beam_set.Beams['3_290gr'].SetIsocenter(Name="rob_p_dpbn 1")

  # CompositeAction ends 


# Unscriptable Action 'Edit beam optimization settings (1_70gr, Beam Set: rob_p_dpbn)' Completed : EditIonBeamOptimizationSettingsAction(...)

# Unscriptable Action 'Edit beam optimization settings (2_180gr, Beam Set: rob_p_dpbn)' Completed : EditIonBeamOptimizationSettingsAction(...)

# Unscriptable Action 'Edit beam optimization settings (3_290gr, Beam Set: rob_p_dpbn)' Completed : EditIonBeamOptimizationSettingsAction(...)

# Unscriptable Action 'Edit beam optimization settings (1_70gr, Beam Set: rob_p)' Completed : EditIonBeamOptimizationSettingsAction(...)

# Unscriptable Action 'Edit beam optimization settings (2_180gr, Beam Set: rob_p)' Completed : EditIonBeamOptimizationSettingsAction(...)

# Unscriptable Action 'Edit beam optimization settings (3_290gr, Beam Set: rob_p)' Completed : EditIonBeamOptimizationSettingsAction(...)

# Unscriptable Action 'Save' Completed : SaveAction(...)

