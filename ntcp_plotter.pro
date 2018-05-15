dat_lokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\dat_data\'
ind_lokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\IndData\'

P_list = 'P6'
patient = 'Patient 6'

RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_Test^' + P_list + '_Doseplan_'
presc_doseRS_infomatrix = read_dat((RSlokasjon + 'presc_BeamSet_presc.dat'))
inv_doseRS_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_inv.dat'))

doseIDL_infomatrix = read_dat((dat_lokasjon + patient + '_dp_matr.dat'))
pet_infomatrix = read_dat((dat_lokasjon + patient + '_pet_matrix.dat'))

p_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p.dat'))
p_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p_dpbn.dat'))
ph_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph.dat'))
ph_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph_dpbn.dat'))

p_dose = *(p_infomatrix[0])/100. * 34.  ;Må deles på 100 for å gå fra cGy til Gy
p_dpbn_dose = *(p_dpbn_infomatrix[0])/100. * 34.   ;Ganges med 34 fraksjoner
ph_dose = *(ph_infomatrix[0])/100. * 34.
ph_dpbn_dose = *(ph_dpbn_infomatrix[0])/100. * 34.
RSpresc = *(presc_doseRS_infomatrix[0])/100.   ;NB! Bare én fraksjon på preskribert dose
RSinv = *(inv_doseRS_infomatrix[0])/100.
pet_matrix = *(pet_infomatrix[0]) ;NB! Allthough I use read_dat here as well, don't use any information beyond "Dose", which in this case is the pet matrix, and "number of voxels" as these are just fillers
IDLpresc = *(doseIDL_infomatrix[0])

gtv_RS_ind = where(RSinv lt 50.0)
D_mean = [mean(ph_dose[gtv_RS_ind]), mean(ph_dpbn_dose[gtv_RS_ind]), mean(p_dose[gtv_RS_ind]), mean(p_dpbn_dose[gtv_RS_ind])]

n = 50

dose_holder = ptrarr(n)
ntcp_value_oar1 = make_array(n)
ntcp_value_oar2 = make_array(n)

for i = 1, n-1 do begin
  dose_holder[i] = ptr_new(make_array(size = Size(p_dose), value = i))
  val = ntcp(*(dose_holder[i]), p_dpbn_dose, ph_dose, ph_dpbn_dose, 'Parotid_L', 'Parotid_R', patient)
  ntcp_value_oar1[i] = (*val[2])[2]
  ntcp_value_oar2[i] = (*val[3])[2]
endfor

stop

end