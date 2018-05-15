dat_lokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\dat_data\'
patients = ['Patient 1', 'Patient 2', 'Patient 3', 'Patient 4', 'Patient 5', 'Patient 6', 'Patient 7', 'Patient 8', 'Patient 9', 'Patient 11']
P_list = ['p1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7','P8', 'P9', 'P11'] ;P7 og P9 gir problemer i read_dat.pro
constant_list = findgen(100, start = 22970, increment = 0.1)    ;2.297480e+004    NB! Found the same when the dose was  translated
best_constant = 0
minimum = 1000.0
mean_dose = make_array(3, n_elements(patients))
max_dose = make_array(2, n_elements(patients))
QF_matrix = make_array(3, n_elements(patients))

for i = 0, n_elements(constant_list) - 1 do begin
  constant = constant_list[i]
  ;tcp_values = make_array(4, n_elements(patients))
  tcp_values = make_array(3, n_elements(patients))
  for j = 0, n_elements(patients)-1 do begin
    patient = patients[j]
  
    ;retrieving data from IDL
    ;gtv_pet_ind = read_gtv_pet_ind((dat_lokasjon + patient + '_gtv_pet_ind.dat'))
    doseIDL_infomatrix = read_dat((dat_lokasjon + patient + '_dp_matr.dat'))
    pet_infomatrix = read_dat((dat_lokasjon + patient + '_pet_matrix.dat'))
    
    ;Using the read_dat function will give you a list of pointers
    ;The index are as follows:
    ;[0] = Dose matrix
    ;[1] = Number of voxels along each axis [#x, #y, #z]
    ;[2] = Voxel size array [dx, dy, dz]
    ;[3] = Upper left corner array [x, y, z]
    ;[4] = Number of fractions
    ;[5] = Total number of voxels
    
    ;retrieving data from Raystation Research
    if patient eq 'Patient 1' then begin
      RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_test_hn_dpbn_p1^p1_Doseplan_'
      presc_doseRS_infomatrix = read_dat((RSlokasjon + 'presc_BeamSet_presc.dat'))
      inv_doseRS_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_inv.dat'))
    
      p_infomatrix = read_dat((RSlokasjon + 'robust_pr_BeamSet_robust_pr.dat'))
      p_dpbn_infomatrix = read_dat((RSlokasjon + 'robust_pr_BeamSet_robust_dpbn_pr.dat'))
      ph_infomatrix = read_dat((RSlokasjon + 'robust_ph_BeamSet_robust_ph.dat'))
      ph_dpbn_infomatrix = read_dat((RSlokasjon + 'robust_ph_BeamSet_robust_dpbn_ph.dat'))
    endif
    
    if patient ne 'Patient 1' then begin
      RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_Test^' + P_list[j] + '_Doseplan_'
      presc_doseRS_infomatrix = read_dat((RSlokasjon + 'presc_BeamSet_presc.dat'))
      inv_doseRS_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_inv.dat'))

      p_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p.dat'))
      p_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p_dpbn.dat'))
      ph_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph.dat'))
      ph_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph_dpbn.dat'))
    endif
    
    p_dose = *(p_infomatrix[0])/100. * 34.  ;Må deles på 100 for å gå fra cGy til Gy
    p_dpbn_dose = *(p_dpbn_infomatrix[0])/100. * 34.   ;Ganges med 34 fraksjoner
    
    p_dpbn_dose =  transform_volume(p_dpbn_dose, translate = [-1, -1, -1])
    
    ph_dose = *(ph_infomatrix[0])/100. * 34.
    ph_dpbn_dose = *(ph_dpbn_infomatrix[0])/100. * 34.
    
    ph_dpbn_dose =  transform_volume(ph_dpbn_dose, translate = [-1, -1, -1])
    
    RSpresc = *(presc_doseRS_infomatrix[0])/100.   ;NB! Bare én fraksjon på preskribert dose
    RSinv = *(inv_doseRS_infomatrix[0])/100.
    pet_matrix = *(pet_infomatrix[0]) ;NB! Allthough I use read_dat here as well, don't use any information beyond "Dose", which in this case is the pet matrix, and "number of voxels" as these are just fillers
    IDLpresc = *(doseIDL_infomatrix[0])
    
    gtv_RS_ind = where(RSinv lt 50.0)
    
    ;factor2 = mean(RSpresc[gtv_RS_ind])/76.0
    factor = mean(ph_dpbn_dose[gtv_RS_ind])/mean(p_dpbn_dose[gtv_RS_ind])
    
    print, mean(ph_dpbn_dose[gtv_RS_ind]), mean(p_dpbn_dose[gtv_RS_ind]), mean(ph_dpbn_dose[gtv_RS_ind])/mean(p_dpbn_dose[gtv_RS_ind])
    
    
    p_dpbn_dose = p_dpbn_dose * factor  ; * factor2
;    ph_dpbn_dose = ph_dpbn_dose * factor2
    
    print, patient, factor
    
    
    
    tcp_ptr = tcpmodel(ph_dose, ph_dpbn_dose, p_dose, p_dpbn_dose, RSpresc, pet_matrix, (*(p_infomatrix[2])), (*(p_infomatrix[4])), gtv_RS_ind, constant = constant)
    ;tcp_values[*, j] = [*(tcp_ptr[0]), *(tcp_ptr[1]), *(tcp_ptr[2]), *(tcp_ptr[3])]
    tcp_values[*, j] = [*(tcp_ptr[5]), *(tcp_ptr[1]), *(tcp_ptr[3])]
    mean_dose[*, j] = [mean(ph_dpbn_dose[gtv_RS_ind]), mean(p_dpbn_dose[gtv_RS_ind]), mean(RSpresc[gtv_RS_ind])]
    max_dose[*, j] = [max(ph_dpbn_dose[gtv_RS_ind]), max(p_dpbn_dose[gtv_RS_ind])]
    QFs = dose_difference_dpbn(IDLpresc, ph_dpbn_dose, p_dpbn_dose, RSpresc, gtv_RS_ind, (*(p_infomatrix[2])))
    QF_matrix[*, j] = [(*QFs[0])[0], (*QFs[0])[1], (*QFs[0])[2]]
  endfor
  
;  if (mean([tcp_values[0, *], tcp_values[2, *]]) - 0.70)^2 lt minimum then begin
;    print, (mean([tcp_values[0, *], tcp_values[2, *]]) - 0.70)^2, constant
;    minimum = (mean([tcp_values[0, *], tcp_values[2, *]]) - 0.70)^2
;    best_constant = constant
;    best_index = j
;    best_tcp = tcp_values
;  endif
  if mean(tcp_values[0, *] - 0.70)^2 lt minimum then begin
    print, mean(tcp_values[0, *] - 0.70)^2, constant, FORMAT = "Best mean = {%e}, with constant = {%e}"
    minimum = mean(tcp_values[0, *] - 0.70)^2
    best_constant = constant
    best_index = j ;Hva i alle dager gjør denne?
    best_tcp = tcp_values
  endif

  ptr_free, tcp_ptr
endfor
  
;print, best_constant, mean([tcp_values[0, *], tcp_values[2, *]]), FORMAT =  "Finished! With the best constant = {%e}, giving a mean TCP of {%e}"
print, best_constant, mean(tcp_values[0, *]), FORMAT =  "Finished! With the best constant = {%e}, giving a mean TCP of {%e}
print, best_tcp ;, mean_dose
print, ' '
print, mean(best_tcp[0, *]), mean(best_tcp[1, *]), mean(best_tcp[2, *]), mean(mean_dose[0, *]), mean(mean_dose[1, *]), mean(max_dose[0, *]), mean(max_dose[1, *]), mean(mean_dose[-1, *])
print, mean(best_tcp[0, *]), mean(best_tcp[1, *])/ mean(best_tcp[2, *]), mean(mean_dose[0, *])/ mean(mean_dose[1, *]), mean(max_dose[0, *])/ mean(max_dose[1, *]) ;, mean(best_tcp[2, *]), mean(best_tcp[3, *])
print, ' '
print, QF_matrix, mean(QF_matrix[0, *]), mean(QF_matrix[1, *]), mean(QF_matrix[2, *])

end