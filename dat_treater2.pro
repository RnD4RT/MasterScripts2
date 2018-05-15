dat_lokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\dat_data\'
ind_lokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\IndData\'
;P_list = [strmid(patient, 0, 1) + strmid(patient, 8, 1)]
patients = ['Patient 1', 'Patient 2', 'Patient 3', 'Patient 4', 'Patient 5', 'Patient 6', 'Patient 7', 'Patient 8', 'Patient 9', 'Patient 11']
P_list = ['p1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7','P8', 'P9', 'P11'] ;P7 og P9 gir problemer i read_dat.pro

info_matrix = ptrarr(n_elements(P_list))

for i=0, n_elements(patients) - 1 do begin
  ;a = read_dat_ind((ind_lokasjon + "ROI_indices_patient_Test~P9_Doseplan_rob_p_BeamSet_inv.dat"))
  
  
  patient = patients[i]
  print, patient, P_list[i]
  
  ;retrieving data from IDL
  gtv_pet_ind = read_gtv_pet_ind((dat_lokasjon + patient + '_gtv_pet_ind.dat'))
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
    RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_Test^' + P_list[i] + '_Doseplan_'
    

    inv_doseRS_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_inv.dat'))
  
    p_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p.dat'))
    p_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p_dpbn.dat'))
    ph_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph.dat'))
    ph_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph_dpbn.dat'))
  endif
  
  
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
  
  
  gtv_RS_ind1 = read_dat_ind(patient, 'GTV68')
 
  
;  print, patient, '&', mean(RSpresc[gtv_pet_ind]), ' \pm ', stddev(RSpresc[gtv_pet_ind]), '&', mean(RSpresc[gtv_RS_ind]), ' \pm ', stddev(RSpresc[gtv_RS_ind]),  '&', mean(RSpresc[gtv_RS_ind1]), ' \pm ', stddev(RSpresc[gtv_RS_ind1]) 
  ;for i = 0, n_elements(gtv_RS_ind) do begin
  ;  print, index_inv[i], gtv_RS_ind[i], inv_dose[index_inv[i]], inv_dose[gtv_RS_ind[i]]
  ;endfor
  a = dose_difference(IDLpresc, ph_dose, ph_dpbn_dose, p_dose, p_dpbn_dose, RSpresc, gtv_RS_ind, *(p_infomatrix[2]))
;  ;b = DoseofPet(pet_matrix, IDLpresc, gtv_RS_ind)
  c = tcpmodel(ph_dose, ph_dpbn_dose, p_dose, p_dpbn_dose, RSpresc, pet_matrix, (*(p_infomatrix[2])), (*(p_infomatrix[4])), gtv_RS_ind, Constant = 22974.8)
;  ;c = convolver(pet_matrix, gtv_pet_ind, IDLpresc, 2)
  d = wcsv((*a[0]), D_mean, c, patient)
  ;e = yxtcp(pet_matrix, RSpresc, p_dose, (*(p_infomatrix[2]))[0], (*(p_infomatrix[2]))[1], (*(p_infomatrix[2]))[2])
  ;f = translate_volume(p_dose, p_dpbn_dose, ph_dose, ph_dpbn_dose, (*(p_infomatrix[2])), RSpresc, gtv_RS_ind, IDLpresc, patient, pet_matrix)
  ;g = shrink_volume2(p_dpbn_dose, ph_dpbn_dose, (*(p_infomatrix[2])), RSpresc, gtv_RS_ind, IDLpresc, patient, pet_matrix, ph_dose, p_dose)
  h  = ntcp(p_dose, p_dpbn_dose, ph_dose, ph_dpbn_dose, 'Parotid_L', patient)
  stop

;
;  
;  QFnTCP = translate_volume2(p_dose, p_dpbn_dose, ph_dose, ph_dpbn_dose, (*(p_infomatrix[2])), RSpresc, gtv_RS_ind, IDLpresc, patient, pet_matrix)
;  
;  info_matrix[i] = ptr_new(QFnTCP)
;  
;  avg_mov = make_array((size(QFnTCP))[2])
;  shrink = avg_mov
;  phQF = avg_mov
;  pQF = avg_mov
;  phTCP = avg_mov
;  pTCP = avg_mov
;  
;  for j = 0, (size(QFnTCP))[2] - 1 do begin
;    avg_mov[j] = *(QFnTCP[0, *])[j]
;    shrink[j]  = *(QFnTCP[1, *])[j]
;    phQF[j]    = *(QFnTCP[2, *])[j]
;    pQF[j]     = *(QFnTCP[3, *])[j]
;    phTCP[j]   = *(QFnTCP[4, *])[j]
;    pTCP[j]    = *(QFnTCP[5, *])[j]
;  endfor
;  
;  avg_mov_elements = sort_one(avg_mov)
;  shrink_elements = sort_one(shrink)
;  
;  test = make_array(n_elements(avg_mov_elements), n_elements(shrink_elements))
;  
;  for j = 0, n_elements(shrink_elements) - 1 do begin
;    for k = 0, n_elements(avg_mov_elements) - 1 do begin
;      test[k, j] = mean(pQF[intersect(where(avg_mov eq avg_mov_elements[k]), where(shrink eq shrink_elements[j]))])
;      print, avg_mov_elements[k], shrink_elements[j], test[k, j]
;    endfor
;  endfor

  
 ; ptr_free, h
  ptr_free, p_infomatrix, p_dpbn_infomatrix, ph_infomatrix, ph_dpbn_infomatrix, presc_doseRS_infomatrix, pet_infomatrix, doseIDL_infomatrix, inv_doseRS_infomatrix

endfor
end