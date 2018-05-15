#######################################################################################################
#######################################################################################################
###############		Created by Eirik Ramsli Hauge										###############
###############     Based on: www.voidspace.org.uk/ironpython/winforms/part6.shtml		###############
###############		Contact: eirikhauge@hotmail.com										###############
###############		Feel free to ask if anythings wrong :)      						############### 
#######################################################################################################
#######################################################################################################



from connect import *

import clr

clr.AddReference('System.Windows.Forms')
clr.AddReference('System.Drawing')

import sys

from math import ceil
from System.Drawing import Color, Font, FontStyle, Point
from System.Windows.Forms import Application, BorderStyle, Button, CheckBox, Form, Label, Panel, RadioButton

class SelectROIForm(Form):
	def __init__(self, plan):
		self.Text = "Choose the apropriate ROI"
		
		structure_set = plan.GetStructureSet()
		self.roi_names = sorted([rg.OfRoi.Name for rg in structure_set.RoiGeometries if rg.PrimaryShape != None])
		self.roi_colors = [rg.OfRoi.Color for rg in structure_set.RoiGeometries if rg.PrimaryShape != None]
		
		self.Width = 160*4 + 50
		self.Height = 55*int(ceil(len(self.roi_names)/4.)) + 150
		
		print self.roi_colors
		
		self.setupCheckButtons()
		
		# Add button to press OK and close the Form
		button = Button()
		button.Text = "OK"
		button.AutoSize = True
		button.Location = Point(self.Width - 105, self.Height - 100)
		button.Click += self.ok_button_clicked
		
		# Add button to press Stop and close the Form
		button2 = Button()
		button2.Text = "Stop"
		button2.AutoSize = True
		button2.Location = Point(self.Width - 210, self.Height - 100)
		button2.Click += self.stop_button_clicked
		
		self.Controls.Add(button)
		self.Controls.Add(button2)
		
		self.Controls.Add(self.checkPanel)
		
	def newPanel(self, x, y):
		panel = Panel()
		
		panel.Width = 5120
		panel.Height = 256*(len(self.roi_names)/2.)
		panel.Location = Point(x, y)
		panel.BorderStyle = BorderStyle.Fixed3D
		return panel
	
	def setupCheckButtons(self):
		self.checkPanel = self.newPanel(0,0)
		
		self.checkLabel = Label()
		self.checkLabel.Text = "Choose the ROI(s) that represents GTV68"
		self.checkLabel.Location = Point(25, 25)
		self.checkLabel.AutoSize = True
		
		self.checkBoxList = [CheckBox() for i in range(0, len(self.roi_names))]
		checkBoxJumper = [i*4 for i in range(1, int(ceil(len(self.roi_names)/4.)))]
		
		xcounter = 0
		ycounter = 1
		for i in range(0, len(self.roi_names)):
			for j in checkBoxJumper:
				if i == j:
					xcounter = 0
					ycounter += 1
					
			self.checkBoxList[i].Text = self.roi_names[i]
			self.checkBoxList[i].Location = Point(xcounter*160 + 25, 55*ycounter)
			xcounter += 1
			
					
			self.checkBoxList[i].Width = 150
			self.checkPanel.Controls.Add(self.checkBoxList[i])
		
		self.checkPanel.Controls.Add(self.checkLabel)
		
	def ok_button_clicked(self, sender, event):
		# Method invoked when the button is clicked
		# Save the selected ROI name
		self.roi_name_list = [i.Text for i in self.checkBoxList if str(i.CheckState) == "Checked"]
		
		#for i in self.checkBoxList:
		#	if i.CheckState == "Checked":
		#		self.roi_name_list.Append(i.Text)
		#self.roi_name = self.combobox.SelectedValue
		# Close the form
		self.Close()
		
	def stop_button_clicked(self, sender, event):

		# Close the form
		self.Close()

	
	def redefine_text(self, labeltext):
		self.Text = labeltext
		self.checkLabel.Text = labeltext
		#self.Controls.Add(self.Text) maybe this is needed?


def renameROI(ROIname, plan, case):
	Popup = SelectROIForm(plan)
	Popup.redefine_text('Select the roi that is %s' %ROIname)
	Application.Run(Popup)

	with CompositeAction('Apply ROI changes (%s)' %Popup.roi_name_list[0]):
		case.PatientModelRegionsOfInterest['%s' %Popup.roi_name_list[0]].Name = ROIname
		
plan = get_current("Plan")

form = SelectROIForm(plan)
Application.Run(form)


case = get_current("Case")
examination = get_current("Examination")

#Try to copy ROI specified from UI

with CompositeAction('ROI Algebra (GTV68, Image set: CT 1)'):

	retval_GTV68 = case.PatientModel.CreateRoi(Name = "GTV68", Color = "255, 140, 0", Type = "Gtv", TissueName = None, RoiMaterial = None)

	retval_GTV68.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': [i for i in form.roi_name_list], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
									ResultOperation="None", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

with CompositeAction('ROI Algebra (PTV68, Image set: CT 1)'):

  	retval_PTV68 = case.PatientModel.CreateRoi(Name="PTV68", Color="Blue", Type="Ptv", TissueName=None, RoiMaterial=None)

  	retval_PTV68.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["GTV68"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0.3, 'Inferior': 0.3, 'Anterior': 0.3, 'Posterior': 0.3, 'Right': 0.3, 'Left': 0.3 } }, 
  									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  									ResultOperation="None", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })
									
with CompositeAction('ROI Algebra (PTV68_eks, Image set: CT 1)'):

  	retval_PTV68_eks = case.PatientModel.CreateRoi(Name="PTV68_eks", Color="Blue", Type="Ptv", TissueName=None, RoiMaterial=None)

  	retval_PTV68_eks.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["PTV68"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': ["GTV68"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  									ResultOperation="Subtraction", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

### Need to insert a UI for selecting ITVs ###
### Add this later, until then: Make the ROI before you start the script. ###

form2 = SelectROIForm(plan)
form2.redefine_text("Select the ROI that is CTV64")
Application.Run(form2)

with CompositeAction('ROI Algebra (CTV64, Image set: CT 1)'):

	retval_CTV64 = case.PatientModel.CreateRoi(Name = "CTV64", Color = "Red", Type = "Ctv", TissueName = None, RoiMaterial = None)

	retval_CTV64.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': [i for i in form2.roi_name_list], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
									ResultOperation="None", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

### From reording: ###
#with CompositeAction('ROI Algebra (CTV64_eks, Image set: CT 1)'):
#
#  retval_1 = case.PatientModel.CreateRoi(Name="CTV64_eks", Color="Red", Type="Ctv", TissueName=None, RoiMaterial=None)
#
#  retval_1.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
#  									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["ITVlkmet I/cecia", "ITVlkmet III uni", "ITVlkmetII", "ITV-PETlkmetII", "ITV-PETtumor", "ITVtumor CT/ cec"], 
#  									'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
#  									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
#  									ResultOperation="None", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })
#
######################

with CompositeAction('ROI Algebra (PTV64, Image set: CT 1)'):

  	retval_PTV64 = case.PatientModel.CreateRoi(Name="PTV64", Color="Blue", Type="Ptv", TissueName=None, RoiMaterial=None)

  	retval_PTV64.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  								ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["CTV64"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0.3, 'Inferior': 0.3, 'Anterior': 0.3, 'Posterior': 0.3, 'Right': 0.3, 'Left': 0.3 } },
  							 	ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  							 	ResultOperation="None", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

### Need to insert a UI for selecting ITVs ###
### Add this later, until then: Make the ROI before you start the script. ###

form3 = SelectROIForm(plan)
form3.redefine_text("Select the ROI that is CTV54 without anything subtracted")
Application.Run(form3)

with CompositeAction('ROI Algebra (CTV54, Image set: CT 1)'):

	retval_CTV54 = case.PatientModel.CreateRoi(Name = "CTV54", Color = "Red", Type = "Ctv", TissueName = None, RoiMaterial = None)

	retval_CTV54.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': [i for i in form3.roi_name_list], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
									ResultOperation="None", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

with CompositeAction('ROI Algebra (CTV54_eks, Image set: CT 1)'):

	retval_CTV54_eks = case.PatientModel.CreateRoi(Name = "CTV54_eks", Color = "Red", Type = "Ctv", TissueName = None, RoiMaterial = None)

	retval_CTV54_eks.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': [i for i in form3.roi_name_list], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': ["PTV64"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
									ResultOperation="Subtraction", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })


### From recording: ###
#
#with CompositeAction('ROI Algebra (CTV54_eks, Image set: CT 1)'):
#
#  retval_3 = case.PatientModel.CreateRoi(Name="CTV54_eks", Color="Red", Type="Ctv", TissueName=None, RoiMaterial=None)
#
#  retval_3.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
#									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["ITVelektive lk s", "ITVelektive lk.d"], 
#									'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
#									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': ["PTV64_eks"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
#									ResultOperation="Subtraction", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })
#
#######################

with CompositeAction('ROI Algebra (PTV54_eks, Image set: CT 1)'):

  	retval_PTV54_eks = case.PatientModel.CreateRoi(Name="PTV54_eks", Color="Blue", Type="Ptv", TissueName=None, RoiMaterial=None)

  	retval_PTV54_eks.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["CTV54_eks"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0.3, 'Inferior': 0.3, 'Anterior': 0.3, 'Posterior': 0.3, 'Right': 0.3, 'Left': 0.3 } }, 
  									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': ["PTV64"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  									ResultOperation="Subtraction", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

with CompositeAction('ROI Algebra (CTV64_eks, Image set: CT 1)'):

	retval_CTV64_eks = case.PatientModel.CreateRoi(Name="CTV64_eks", Color="Red", Type="Ctv", TissueName=None, RoiMaterial=None)

  	retval_CTV64_eks.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  		ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["CTV64"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  		ExpressionB={ 'Operation': "Union", 'SourceRoiNames': ["PTV68"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  		ResultOperation="Subtraction", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

with CompositeAction('ROI Algebra (PTV64, Image set: CT 1)'):

  	retval_PTV64_eks = case.PatientModel.CreateRoi(Name="PTV64_eks", Color="Blue", Type="Ptv", TissueName=None, RoiMaterial=None)

  	retval_PTV64_eks.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["CTV64"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0.3, 'Inferior': 0.3, 'Anterior': 0.3, 'Posterior': 0.3, 'Right': 0.3, 'Left': 0.3 } }, 
  									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': ["PTV68"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  									ResultOperation="Subtraction", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })


External_intersection_list = ["CTV64_eks", "CTV54_eks", "PTV64_eks", "PTV54_eks"]

form4 = SelectROIForm(plan)
form4.redefine_text("Select the ROI that is the external. Choose only one!")
Application.Run(form4)

margin = 0.5
ExternalName = form4.roi_name_list   #Don't use an index here
print ExternalName

with CompositeAction('ROI Algebra (PTV64_eks_5mm, Image set: CT 1)'):

  	retval_PTV64_eks_5mm = case.PatientModel.CreateRoi(Name="PTV64_eks_5mm", Color="Blue", Type="Ptv", TissueName=None, RoiMaterial=None)

  	retval_PTV64_eks_5mm.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["PTV64_eks"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [ExternalName[0]], 'MarginSettings': { 'Type': "Contract", 'Superior': 0.5, 'Inferior': 0.5, 'Anterior': 0.5, 'Posterior': 0.5, 'Right': 0.5, 'Left': 0.5 } }, 
  									ResultOperation="Intersection", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

with CompositeAction('ROI Algebra (PTV54_eks_5mm, Image set: CT 1)'):

  	retval_PTV54_eks_5mm = case.PatientModel.CreateRoi(Name="PTV54_eks_5mm", Color="Blue", Type="Ptv", TissueName=None, RoiMaterial=None)

  	retval_PTV54_eks_5mm.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["PTV54_eks"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [ExternalName[0]], 'MarginSettings': { 'Type': "Contract", 'Superior': 0.5, 'Inferior': 0.5, 'Anterior': 0.5, 'Posterior': 0.5, 'Right': 0.5, 'Left': 0.5 } }, 
  									ResultOperation="Intersection", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

with CompositeAction('ROI Algebra (CTV64_eks_5mm, Image set: CT 1)'):

  	retval_CTV64_eks_5mm = case.PatientModel.CreateRoi(Name="CTV64_eks_5mm", Color="Red", Type="Ctv", TissueName=None, RoiMaterial=None)

  	retval_CTV64_eks_5mm.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["CTV64_eks"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [ExternalName[0]], 'MarginSettings': { 'Type': "Contract", 'Superior': 0.5, 'Inferior': 0.5, 'Anterior': 0.5, 'Posterior': 0.5, 'Right': 0.5, 'Left': 0.5 } }, 
  									ResultOperation="Intersection", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })

with CompositeAction('ROI Algebra (CTV54_eks_5mm, Image set: CT 1)'):

  	retval_CTV54_eks_5mm = case.PatientModel.CreateRoi(Name="CTV54_eks_5mm", Color="Red", Type="Ctv", TissueName=None, RoiMaterial=None)

  	retval_CTV54_eks_5mm.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  									ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["CTV54_eks"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  									ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [ExternalName[0]], 'MarginSettings': { 'Type': "Contract", 'Superior': 0.5, 'Inferior': 0.5, 'Anterior': 0.5, 'Posterior': 0.5, 'Right': 0.5, 'Left': 0.5 } }, 
  									ResultOperation="Intersection", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })
									
if form4.roi_name_list[0] != "External":
	with CompositeAction('Apply ROI changes (%s)' %form4.roi_name_list[0]):

		case.PatientModel.RegionsOfInterest['%s' %form4.roi_name_list[0]].Name = "External"
									
nothurtlist = ['Parotid_R', 'Parotid_L', 'Submandibular_L', 'Submandibular_R', 'SpinalCord']

#for i in nothurtlist:
#	renameROI(i, plan, case)

structure_set = plan.GetStructureSet()
roi_names = [rg.OfRoi.Name for rg in structure_set.RoiGeometries if rg.PrimaryShape != None]

for j in nothurtlist:
	counter = 0
	for i in roi_names:
		if i == j:
			counter = 1
	if counter == 0:
		form_loop = SelectROIForm(plan)
		form_loop.redefine_text("Select the ROI that is %s. Choose only one!" %j)
		Application.Run(form_loop)
		
		with CompositeAction('Apply ROI changes (%s)' %form_loop.roi_name_list[0]):
			case.PatientModel.RegionsOfInterest['%s' %form_loop.roi_name_list[0]].Name = j
			
		if j == "SpinalCord":
			with CompositeAction('ROI Algebra (SpinalCord_PRV, Image set: CT 1)'):

				retval_SpinalCord_PRV = case.PatientModel.CreateRoi(Name="SpinalCord_PRV", Color="Green", Type="Avoidance", TissueName=None, RoiMaterial=None)

				retval_SpinalCord_PRV.CreateAlgebraGeometry(Examination=examination, Algorithm="Auto", 
  								ExpressionA={ 'Operation': "Union", 'SourceRoiNames': ["SpinalCord"], 'MarginSettings': { 'Type': "Expand", 'Superior': 0.3, 'Inferior': 0.3, 'Anterior': 0.3, 'Posterior': 0.3, 'Right': 0.3, 'Left': 0.3 } },
  							 	ExpressionB={ 'Operation': "Union", 'SourceRoiNames': [], 'MarginSettings': { 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 } }, 
  							 	ResultOperation="None", ResultMarginSettings={ 'Type': "Expand", 'Superior': 0, 'Inferior': 0, 'Anterior': 0, 'Posterior': 0, 'Right': 0, 'Left': 0 })
								
	elif counter > 1 or counter < 0:
		print "Your counter is wrong"
		