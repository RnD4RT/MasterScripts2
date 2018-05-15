################
# This is the main script, launched by RS_DVH_START.py
#
#
# ******************************************************************************
# ******************************************************************************
#Retrieve the location of the SCRIPT_DIRECTORY
#from RS_DVH_LIB import Globals
import Globals
SCRIPT_DIRECTORY = Globals.__SCRIPT_DIRECTORY
XLTM_DIRECTORY = Globals.__SCRIPT_DIRECTORY #XLTM_DIRECTORY is the Excel template directory
DEFAULT_WBFN = Globals.__DEFAULT_WBFN #'Default WorkBook FileName'
#
#
from connect import *
import clr
import System.Array
clr.AddReference("Office")
clr.AddReference("Microsoft.Office.Interop.Excel")
clr.AddReference("System.Windows.Forms")
clr.AddReference("System.Drawing")

from Microsoft.Office.Interop.Excel import *
from System.Drawing import (Color, ContentAlignment, Font, FontStyle, Point)
from System.Windows.Forms import (Application, BorderStyle, Button, CheckBox, ComboBox, DialogResult, Form, FormBorderStyle, Label, Panel, RadioButton)

from RS_DVH_LIB.SelectROIDialog import SelectROIDialog, ROI_Selector
from RS_DVH_LIB.DialogueForm import DialogueForm

#####################################Draw a chart in Excel##################################
def drawDVHchart(Chartsheet = None, Datasheet=None, Rows = None, ChartType = "Percent"):
    # DEBUG: Caution, relies on module wide definition of dose_type AND rois AND patient AND dose_distribution. Fix this.
    # TODO: find a way to not have to pass the Rows argument
    #
    # Copy data from Datasheet to Chartsheet, optionally converting from absolute to relative dose
    DVHRows = Rows
    AllColumns = len(rois) + 1 #Number of ROI's plus column for dose
    #
    chart = Chartsheet.ChartObjects().Add(10.0, 100.0, 800.0, 500.0).Chart
    CS = Chartsheet #shorthand
    DS = Datasheet  #shorthand
    #
    # Copy over the header information
    CS.Range(CS.Cells(1,1),CS.Cells(4,AllColumns)).Value2 = DS.Range(DS.Cells(1,1),DS.Cells(4,AllColumns)).Value2
    #
    #Create an array to hold volume data
    VOL_DATA = create_range_array(DVHRows,1)
    #
    # set x- and y-values
    seriesCollection = chart.seriesCollection()
    for j, roi in enumerate(rois):

        s = seriesCollection.NewSeries()
        s.Name = roi.Name
        Chart_DoseRange = CS.Range(CS.Cells(5,1), CS.Cells(DVHRows,1))
        Data_DoseRange = DS.Range(DS.Cells(5,1), DS.Cells(DVHRows,1))
        #Copy over the doses
        Chart_DoseRange.Value2 = Data_DoseRange.Value2
        #
        xValues = Chart_DoseRange

        #Get the range of absolute volumes for this ROI
        Data_VolumeRange = DS.Range(DS.Cells(5,  j  + 2), DS.Cells(DVHRows, j + 2))
        #Set the destination range for volume data for this ROI
        Chart_VolumeRange = CS.Range(CS.Cells(5, j+2), CS.Cells(DVHRows, j+2))        
        #Create an array to work on the data
        Vol_Data = create_range_array(DVHRows, 1) #Vol_Data is a "Range Array", so it is 2 dimensional: [row,col] where col=0
        Vol_Data = Data_VolumeRange.Value2
        if ChartType == "Percent":
            # Get the maximum volume for this ROI
            MaxVolume = DS.Cells(5, j+2).Value2
            for j, data in enumerate(Vol_Data): 
                Vol_Data[j,0] = 100.0*(data / MaxVolume )

        #Copy over to chart spreadsheet
        Chart_VolumeRange.Value2 = Vol_Data
        yValues = Chart_VolumeRange

        #Assign the values to the chart collection
        s.XValues = xValues
        s.Values = yValues

    # plot
    chart.ChartType = XlChartType.xlXYScatterLinesNoMarkers

    if ChartType == "Percent":
        valueTitle = "Percent Relative Volume"
    else:
        valueTitle = "Volume [cc]"
    patient_info = " \n \n  Patient name: {0}, Date of birth: {1}, ID: {2}".format(patient.PatientName, patient.DateOfBirth, patient.PatientID)
    if dose_type == PLAN_DOSE:
        categoryTitle = "Plan dose [{0}] {1}".format(unit_to_string(selected_dose_unit), patient_info)
        title = "Plan DVH: " + plan.Name
    elif dose_type == BEAM_SET_DOSE:
        categoryTitle = "Beam set dose  [{0}] {1}".format( unit_to_string(selected_dose_unit), patient_info)
        title = "Beam set DVH: " + beam_set_name + '( ' + plan.Name + ' )'
    elif dose_type == SUM_DOSE:
        categoryTitle = "Composite dose [{0}] {1}".format( unit_to_string(selected_dose_unit), patient_info)
        title = "Composite DVH: " + dose_distribution.Name
        
    chart.ChartWizard(Title = title, ValueTitle = valueTitle, CategoryTitle = categoryTitle)
    #Set axes scales and other custom features
    yax = chart.Axes(2)
    xax = chart.Axes(1)
    yax.MaximumScale = 100.0
    yax.MinimumScale = 0.0
    yax.HasMajorGridlines = True
    xax.HasMajorGridlines = True
    return chart

################################### START OF SCRIPT ACTIONS ################################
############
############
        

# Check that needed data is available
patient_db = get_current("PatientDB")

try:
    case = get_current("Case")
except SystemError:
    raise IOError("No Case found.")

try:
    patient = get_current("Patient") 
except SystemError:
    raise IOError("No patient loaded. Load patient and plan.")
    
try:
    plan = get_current("Plan") 
except SystemError:
    raise IOError("No plan loaded. Load patient and plan.")

try:
    beamset = get_current("BeamSet")
    beam_set_name = beamset.DicomPlanLabel
except SystemError:
    raise IOError("No beam set loaded.")

# Plan or beam set dose
PLAN_DOSE = 'Plan dose'
BEAM_SET_DOSE = 'Beam set dose'
SUM_DOSE = 'Sum dose'
SUPPORTED_DOSE_TYPES = set([PLAN_DOSE, BEAM_SET_DOSE, SUM_DOSE])

# Units
VOLUME_PERCENT = r'%'
VOLUME_CC = 'cc'
SUPPORTED_VOLUME_UNITS = set([VOLUME_PERCENT, VOLUME_CC])
CGY = 'cGy'
GY = 'Gy'
SUPPORTED_DOSE_UNITS = set([CGY, GY])

######################DEBUG#########################
##################################################
###############################################

#Create a list of DoseEvaluation names (summed dose)
# Create a list of names of the evaluation doses
EvalSumNames = []
# Create a dictionary pointing to DoseEvaluations[n] by name
DoseEvaluations = {}
#
TD = case.TreatmentDelivery
for FE in TD.FractionEvaluations:
    for DoE in FE.DoseOnExaminations:
        for DE in DoE.DoseEvaluations:
            if DE.Name <> "":
                EvalSumNames.append(DE.Name)
                DoseEvaluations[DE.Name]=DE
#
#What if there are no "dose sums"? Make a fake one and label it clearly.
if len(EvalSumNames)==0:
    EvalSumNames.append("None")
    DoseEvaluations["None"]=None
DOSE_SUM_NAMES = tuple(EvalSumNames)   #The ComboBox needs a tuple, not a list

#Create a dictionary pointing to Clinical Goal EvalutionFunctions by template name
ClinicalGoalEvalFunctions = {}
GoalTemplateNames = []
GoalTemplateNames.append('Plan') #For convenience, the first one should be "Plan", which means use what's loaded
EmptyTemplateNames = []  #In case we want to delete them later

TTO = patient_db.TemplateTreatmentOptimizations
for Template in TTO:
    TemplateName = Template.Name
    try:
        EvalFunctions = Template.EvaluationSetups[0].EvaluationFunctions
        GoalTemplateNames.append(TemplateName)
        ClinicalGoalEvalFunctions[TemplateName] = EvalFunctions
    except:
        EmptyTemplateNames.append(TemplateName)

CLINICAL_GOAL_NAMES = tuple(GoalTemplateNames) #ComboBox needs a tuple, not a list

# Prompt user for input
form = DialogueForm(beam_set_name, DOSE_SUM_NAMES, CLINICAL_GOAL_NAMES)
form.DialogResult
# Apply user configuration
if form.DialogResult == DialogResult.OK:
    dose_type = form.SelectedDoseType
    selected_dose_unit = CGY  #Only work in cGy
    selected_volume_unit = VOLUME_CC #Only work with cc
    dose_eval_name = form.SelectedDoseEvalName
    clinical_goal_name = form.SelectedClinicalGoalTemplateName
    
elif form.DialogResult == DialogResult.Cancel:
    print "Script execution cancelled by user..."
    sys.exit(0)
else:
    raise IOError("Selected dose type not supported.")

# Assert. Remove the references to dose unit and volume unit since we fix those as cGy and cc
assert dose_type in SUPPORTED_DOSE_TYPES
#assert selected_dose_unit in SUPPORTED_DOSE_UNITS
#assert selected_volume_unit in SUPPORTED_VOLUME_UNITS

# Converts cc unit if needed
def unit_to_string(unit):
    assert unit in SUPPORTED_VOLUME_UNITS.union(SUPPORTED_DOSE_UNITS)
    if unit == VOLUME_CC:
        return r'cc'
    else: 
        return unit

# Utility function to create 2-dimensional array for assignment to an Excel Range
def create_range_array(Rows, Cols):
  dims = System.Array.CreateInstance(System.Int32, 2)
  dims[0] = Rows
  dims[1] = Cols
  return System.Array.CreateInstance(System.Object, dims)

# Check that needed data is available
if dose_type == PLAN_DOSE:
    if (plan.TreatmentCourse == None or plan.TreatmentCourse.TotalDose == None or plan.TreatmentCourse.TotalDose.DoseValues == None):
        raise IOError('There is no plan dose.')
    else:
        dose_distribution = plan.TreatmentCourse.TotalDose
        
elif dose_type == BEAM_SET_DOSE:
    try:
        #beamset is the current beamset
        nrOfFractions = beamset.FractionationPattern.NumberOfFractions
        dose_distribution = beamset.FractionDose
    except SystemError:
        raise IOError('The beam set dose not exist.')
    
    if beamset.FractionDose == None or beamset.FractionDose.DoseValues == None:
        raise IOError('There is no beam set dose.')

    if beamset.FractionationPattern == None or beamset.FractionationPattern.NumberOfFractions == None:
        raise IOError('Unknown number of fractions')


#Get the correct dose evaluation if that is what is needed
elif dose_type == SUM_DOSE:
    if dose_eval_name in EvalSumNames:
        if dose_eval_name == "None":
            #There isn't really any dose sum, you made a mistake
            raise IOError ('There is no summed dose evalution.')
        else:
            dose_distribution = DoseEvaluations[dose_eval_name]
    else:
        raise IOError ('Did not find dose evaluation: '+dose_eval_name)
    

else:
    raise IOError('Selected Dose type not supported.')

#Record the prescription. Take the Rx from the current beamset. We may or may not use this....
RxDose = beamset.FractionDose.ForBeamSet.Prescription.PrimaryDosePrescription.DoseValue

# Get rois
#
GetSS = plan.GetStructureSet()
RoiGeometries = GetSS.RoiGeometries
geom_list = [x for x in RoiGeometries]
roi_list = [x.OfRoi for x in geom_list]
#
#Put up a dialog box to select specific ROI's
#First create the objects that the dialog box needs
ROIitem_list = []
for roi in roi_list:
    Include_This_ROI = True
    #Now check if the ROI has a volume on this plan (ROI's are in the Geometry even if they aren't in the plan)
    if dose_distribution.GetDoseGridRoi(RoiName = roi.Name) == None or hasattr(dose_distribution.GetDoseGridRoi(RoiName = roi.Name).RoiVolumeDistribution,'TotalVolume')==False:
        Include_This_ROI = False
    if Include_This_ROI:
        ROIdata = ROI_Selector(roi)
        ROIitem_list.append(ROIdata)
#

SD = SelectROIDialog(patient.PatientName, plan.Name, ROIitem_list)
SD.ShowDialog()
#SD.Selected is a collection of ROI_Selector instances
# ROI_Selector has properties .index, .name and .type
#
#Finally make the list of rois we want to plot
rois = []
try:
    SD.DialogResult == True
    rois = [x for x in SD.Selected]
except:
    #IF the dialog is cancelled, just keep all of the rois that are valid
    rois = [x for x in ROIitem_list]
    

if len(rois) < 1:
  raise IOError('There are no ROIs with dose grid representation.')

#There is one caveat: we always want to include the "External" type ROI, to use in calculating the dose gradient and location of max dose

type_list = [x.Type for x in rois]

if "External" not in type_list:
    #Add the external volume
    for roi in roi_list:
        if roi.Type == "External":
            rois.append(ROI_Selector(roi))
        
# Define relative volumes. ***We will not need these in this version of the script. We use absolute volumes only***
n = 100
relVolumes = [max(0.0,(x+0.5)) / n for x in range(-1, n)]
relVolumes.append(1.0)

#Define the dose levels, in cGy
#  RoiMaxDosePerFraction = dose_distribution.GetDoseStatistic(RoiName = '  ', DoseType = 'Max')
#
MaxDose = 0
for roi in rois:
    RoiMaxDose = dose_distribution.GetDoseStatistic(RoiName = roi.Name, DoseType = 'Max')
    NumFractions = beamset.FractionDose.ForBeamSet.FractionationPattern.NumberOfFractions
    #RoiMaxDose = RoiMaxDose * NumFractions
    if RoiMaxDose > MaxDose:
        MaxDose = RoiMaxDose
#
# Create a dose list, integer values of cGy from 0 to MaxDose rounded plus 1 cGy to make sure last entries have zero volume
dose_list = range(int(round(MaxDose))+1) #Can be integer as here, or float, for GetRelativeVolumeAtDose method



# Get dimensions of an array to hold dose values in cGy from 0 to MaxDose + 1. 

DVHRows = dose_list.Count + 4  #Add one row each for the ROI name, MIN, MEAN, and MAX rows
#
# The dose and volume arrays use the first row for labels.
#

#arr = System.Array.CreateInstance(System.Array, rois.Count)
roi_volumes = System.Array.CreateInstance(System.Array, rois.Count) #to hold volume data for each roi as a range array

#The dose_array is a range array
dose_array = create_range_array(DVHRows, 1) 

#Fill the dose range array
dose_array[0,0] = "ROI: "
dose_array[1,0] = "MIN: "
dose_array[2,0] = "MEAN: "
dose_array[3,0] = "MAX: "
for i, dose in enumerate(dose_list):
    dose_array[i+4,0]= dose

    
    
#Loop through each roi and get the DVH information
for j, roi in enumerate(rois):

    #Create an array that can be assigned to a range. A Range is a two dimensional object [Row, Col], even if only 1 col is used
    roi_volumes[j] = create_range_array(DVHRows, 1)  

    # Get Volumes
    PercentV_at_Dose = dose_distribution.GetRelativeVolumeAtDoseValues(RoiName = roi.Name, DoseValues = dose_list)
    volume_scaler = dose_distribution.GetDoseGridRoi(RoiName = roi.Name).RoiVolumeDistribution.TotalVolume
    Vol_at_Dose = [x * volume_scaler for x in PercentV_at_Dose]

    #Get dose statistics
    MIN = dose_distribution.GetDoseStatistic(RoiName = roi.Name, DoseType = 'Min')
    MAX = dose_distribution.GetDoseStatistic(RoiName = roi.Name, DoseType = 'Max')
    AVG = dose_distribution.GetDoseStatistic(RoiName = roi.Name, DoseType = 'Average')
  
    # volumes
    roi_volumes[j][0,0] = roi.Name
    #One special case: The Type = "External" volume must be named "External" since it is used by the spreadsheet to calculate dose gradient
    if roi.Type == "External":
        roi_volumes[j][0,0] = "External"
    roi_volumes[j][1,0]=MIN
    roi_volumes[j][2,0]=AVG
    roi_volumes[j][3,0]=MAX
    
    for i, value in enumerate(Vol_at_Dose):
        roi_volumes[j][i + 4,0] = value


  
# Open Excel with new worksheet
excel = ApplicationClass(Visible=True)
workbook = excel.Workbooks.Add(DEFAULT_WBFN)
DVHsheet = workbook.Worksheets["DVHs"]
GOALsheet = workbook.Worksheets["GOALs"]
CHARTsheet = workbook.Worksheets["CHART"]


# Populate DVHSheet worksheet



#Write the dose column. Dose is included with each roi, but we can just use the first one

tablerange = DVHsheet.Range(DVHsheet.Cells(1,1), DVHsheet.Cells(DVHRows,1))
tablerange.Value2 = dose_array

#Write DVH data
for j, roi in enumerate(rois):
    #Load the roi Name and volumes
    x_roi =  j + 2
    tablerange_roi = DVHsheet.Range(DVHsheet.Cells(1,x_roi), DVHsheet.Cells(DVHRows, x_roi))
    tablerange_roi.Value2 = roi_volumes[j]
    #Populate the OARs sheet
#    OARName = OARsheet.Cells(j + 2,1)
#    OARName.Value2 = roi.Name
#    OARIndex = OARsheet.Cells(j+2,2)
 #   OARIndex.Value2 = j + 1

# Create a graph object
DVHchart = drawDVHchart(Chartsheet = CHARTsheet, Datasheet=DVHsheet, Rows = DVHRows)


#Populate the Clinical Goals GOALsheet
if clinical_goal_name == "" or clinical_goal_name == 'Plan':
    EvalFunx = plan.TreatmentCourse.EvaluationSetup.EvaluationFunctions  #Use the plan clinical goals if nothing selected or "plan" is selected
else:
    #EvalFunx = ClinicalGoalEvalFunctions[clinical_goal_name] #Use the selected template
    plan.TreatmentCourse.EvaluationSetup.ApplyClinicalGoalTemplate(Template = patient_db.TemplateTreatmentOptimizations[clinical_goal_name])
    EvalFunx = plan.TreatmentCourse.EvaluationSetup.EvaluationFunctions

class ClinicalGoal:
    '''Used to collect information on a single clinical goal'''
    def __init__(self, EvaluationFunction = None):
        Function = EvaluationFunction
        PlanningGoal = Function.PlanningGoal
        self.ROIName = Function.ForRegionOfInterest.Name
        self.Level = PlanningGoal.AcceptanceLevel
        self.Type = PlanningGoal.Type
        self.Value = PlanningGoal.ParameterValue
        self.Criteria = PlanningGoal.GoalCriteria
        
        
class ClinicalGoals(object):
    '''Returns a list of ClinicalGoal objects that can be used to load a spreadsheet'''
    def __init__(self, EvaluationFunctions = None):
        Functions =EvaluationFunctions
        self.Goals = []
        for Function in Functions:
            self.Goals.append(ClinicalGoal(Function))
            
    
CGs = ClinicalGoals(EvaluationFunctions = EvalFunx)
StartRow = 13
#Create a dictionary to translate RayStation goal Type to spreadsheet label
GoalType = {"DoseAtVolume":"D@%V","DoseAtAbsoluteVolume":"D@V","VolumeAtDose":"%V@D","AbsoluteVolumeAtDose":"V@D","AverageDose":"AVG","ConformityIndex":"CI","HomogeneityIndex":"HI"}
CriteriaType = {"AtMost":"At Most","AtLeast":"At Least"}
for j, Goal in enumerate(CGs.Goals):
    Row = StartRow + j
    STRUCTURE = GOALsheet.Cells(Row,1)
    STRUCTURE.Value2 = Goal.ROIName
    TYPE = GOALsheet.Cells(Row,7)
    TYPE.Value2 = GoalType[Goal.Type]
    CRITERIA = GOALsheet.Cells(Row,10)
    CRITERIA.Value2 = CriteriaType[Goal.Criteria]
    LEVEL = GOALsheet.Cells(Row,13)
    LEVEL.Value2 = Goal.Level
    VALUE = GOALsheet.Cells(Row, 19)
    VALUE.Value2 = Goal.Value
    #Special case: for AverageDose there is no Goal.Value
    if Goal.Type == "AverageDose":
        VALUE.Value2 = ""
    #Now load the actual value 
    ACTUAL = GOALsheet.Cells(Row, 25)
    #ACTUAL.Value2 = 1234.5 #PLACEHOLDER
    if Goal.Type == "AbsoluteVolumeAtDose":
        PercentV_at_Dose = dose_distribution.GetRelativeVolumeAtDoseValues(RoiName = Goal.ROIName, DoseValues = [Goal.Value])
        volume_scaler = dose_distribution.GetDoseGridRoi(RoiName = Goal.ROIName).RoiVolumeDistribution.TotalVolume
        Vol_at_Dose = [x * volume_scaler for x in PercentV_at_Dose]    
        ACTUAL.Value2 = Vol_at_Dose[0]
    elif Goal.Type == "VolumeAtDose":
        PercentV_at_Dose = dose_distribution.GetRelativeVolumeAtDoseValues(RoiName = Goal.ROIName, DoseValues = [Goal.Value])
        ACTUAL.Value2 = PercentV_at_Dose[0]
    elif Goal.Type == "DoseAtVolume":
        Dose_at_PercentV = dose_distribution.GetDoseAtRelativeVolumes(RoiName = Goal.ROIName, RelativeVolumes = [Goal.Value])
        ACTUAL.Value2 = Dose_at_PercentV[0]
    elif Goal.Type == "DoseAtAbsoluteVolume":
        volume_scaler = dose_distribution.GetDoseGridRoi(RoiName = Goal.ROIName).RoiVolumeDistribution.TotalVolume
        Percent_V = Goal.Value/volume_scaler #TotalVolume could be less than Goal.Value, but percent can't go above 1.0
        if Percent_V <= 1.0:            
            Dose_at_PercentV = dose_distribution.GetDoseAtRelativeVolumes(RoiName = Goal.ROIName, RelativeVolumes = [Percent_V])
            ACTUAL.Value2 = Dose_at_PercentV[0]
        else:
            ACTUAL.Value2 = 0.0
    elif Goal.Type == "AverageDose":
        AverageDose = dose_distribution.GetDoseStatistic(RoiName = Goal.ROIName, DoseType = "Average")
        ACTUAL.Value2 = AverageDose
        
        
#Populate the patient demographics
PN = patient.PatientName.replace('^',', ')
DOB = patient.DateOfBirth.ToString().split(' ')[0]
MRN = patient.PatientID
PlanName = plan.Name
PlanLabel = beamset.DicomPlanLabel
TPS_Name = 'RayStation'

#Load the spreadsheet
PNR = GOALsheet.Range("Patient_Name")
PNR.Value2 = PN
DOBR = GOALsheet.Range("Date_of_Birth")
DOBR.Value2 = DOB
MRNR = GOALsheet.Range("MRN")
MRNR.Value2 = MRN
PlanNameR = GOALsheet.Range("Plan_Name")
PlanNameR.Value2 = PlanName
PlanLabelR = GOALsheet.Range("Plan_Label")
PlanLabelR.Value2 = PlanLabel
TPS_NameR = GOALsheet.Range("TPS_Name")
TPS_NameR.Value2 = TPS_Name
Plan_Rx = GOALsheet.Range("Plan_Rx")
Plan_Rx.Value2 = RxDose

