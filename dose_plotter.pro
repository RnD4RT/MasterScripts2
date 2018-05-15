function Dose_Reader, patientlist, GTVplots

  pD   = ptrarr(n_elements(patientlist))
  pDP  = ptrarr(n_elements(patientlist))
  phD  = ptrarr(n_elements(patientlist))
  phDP = ptrarr(n_elements(patientlist))
  RSpresc = ptrarr(n_elements(patientlist))
  GTVind = ptrarr(n_elements(patientlist))
  PETmatrix = ptrarr(n_elements(patientlist))
  voxelsize = ptrarr(n_elements(patientlist))
  IDLpresc = ptrarr(n_elements(patientlist))

  ROIindex = ptrarr(n_elements(patientlist))

  for i = 0, n_elements(patientlist)-1 do begin
    patient = patientlist[i]
    print, patient

    doseIDL_infomatrix = read_dat(('C:\Users\Eirik\Dropbox\Universitet\Master\dat_data\' + patient + '_dp_matr.dat'))
    pet_infomatrix = read_dat(('C:\Users\Eirik\Dropbox\Universitet\Master\dat_data\' + patient + '_pet_matrix.dat'))
    if patient eq 'Patient 1' then begin
      P_list = 'p' + (strsplit(patient, /extract))[-1]
      RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_test_hn_dpbn_p1^p1_Doseplan_'
      presc_doseRS_infomatrix = read_dat((RSlokasjon + 'presc_BeamSet_presc.dat'))
      inv_doseRS_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_inv.dat'))

      p_infomatrix = read_dat((RSlokasjon + 'robust_pr_BeamSet_robust_pr.dat'))
      p_dpbn_infomatrix = read_dat((RSlokasjon + 'robust_pr_BeamSet_robust_dpbn_pr.dat'))
      ph_infomatrix = read_dat((RSlokasjon + 'robust_ph_BeamSet_robust_ph.dat'))
      ph_dpbn_infomatrix = read_dat((RSlokasjon + 'robust_ph_BeamSet_robust_dpbn_ph.dat'))
    endif

    if patient ne 'Patient 1' then begin
      P_list = 'P' + (strsplit(patient, /extract))[-1]
      RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_Test^' + P_list + '_Doseplan_'
      presc_doseRS_infomatrix = read_dat((RSlokasjon + 'presc_BeamSet_presc.dat'))
      inv_doseRS_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_inv.dat'))

      p_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p.dat'))
      p_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p_dpbn.dat'))
      ph_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph.dat'))
      ph_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph_dpbn.dat'))
    endif

    pD[i] = ptr_new(*(p_infomatrix[0])/100. * 34.)  ;Må deles på 100 for å gå fra cGy til Gy
    pDP[i] = ptr_new(*(p_dpbn_infomatrix[0])/100. * 34.)   ;Ganges med 34 fraksjoner
    phD[i] = ptr_new(*(ph_infomatrix[0])/100. * 34.)
    phDP[i] = ptr_new(*(ph_dpbn_infomatrix[0])/100. * 34.)
    PETmatrix[i] = ptr_new(*(pet_infomatrix[0]))
    RSinv = *(inv_doseRS_infomatrix[0])/100.
    RSpresc[i] = ptr_new(*(presc_doseRS_infomatrix[0])/100.)
    voxelsize[i] = ptr_new(*(p_infomatrix[2]))
    IDLpresc[i] = ptr_new(*(doseIDL_infomatrix[0]))
    
    if GTVplots eq 1 then begin
      if patient eq 'Patient 4' then GTVind[i] = ptr_new(read_dat_ind(patient, 'GTV_tumor_PET_AL'))
      if patient eq 'Patient 5' then GTVind[i] = ptr_new(read_dat_ind(patient, 'GTV_tumor_70Gy-MN'))
      if patient eq 'Patient 7' then GTVind[i] = ptr_new(read_dat_ind(patient, 'GTV_prim_tum_(70_Gy)'))
      if patient eq 'Patient 11' then GTVind[i] = ptr_new(read_dat_ind(patient, 'GTV_prim_tum_(70_Gy)'))
      if (patient ne 'Patient 4' && patient ne 'Patient 5' && patient ne 'Patient 7' && patient ne 'Patient 11') then begin
        GTVind[i] = ptr_new(where(RSinv lt 50.0))
      endif
    endif
    if GTVplots eq 0 then begin
      GTVind[i] = ptr_new(where(RSinv lt 50.0))
    endif
    
  endfor
  
  store_matrix = ptrarr(9)
  store_matrix[0] = ptr_new(phD)
  store_matrix[1] = ptr_new(phDP)
  store_matrix[2] = ptr_new(pD)
  store_matrix[3] = ptr_new(pDP)
  store_matrix[4] = ptr_new(RSpresc)
  store_matrix[5] = ptr_new(GTVind)
  store_matrix[6] = ptr_new(PETmatrix)
  store_matrix[7] = ptr_new(voxelsize)
  store_matrix[8] = ptr_new(IDLpresc)

  return, store_matrix
end

function Dose_Plotter, patientlist
  ;Extracts the slice continaing the CM for the prescribed dose in presc, phDP and pDP
  storer = Dose_Reader(patientlist, 1)
  
  filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "MCsnitt_for_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
  filename2 = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "MCsnittSize_for_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
  openw, 1, filename
  openw, 2, filename2
  
  for i = 0, n_elements(patientlist) - 1 do begin
    phDP = *(*storer[1])[i]
    pDP = *(*storer[3])[i]
    presc = *(*storer[4])[i]
    gtv_RS_ind = *(*storer[5])[i]
    
    mc = make_array(3, n_elements(gtv_RS_ind))
    mc_p = make_array(3, n_elements(gtv_RS_ind))
    mc_ph = make_array(3, n_elements(gtv_RS_ind))
    for j = 0, n_elements(gtv_RS_ind) - 1 do begin
      mc[0:2, j] = array_indices(presc, gtv_RS_ind[j])
      mc_p[0:2, j] = array_indices(pDP, gtv_RS_ind[j])
      mc_ph[0:2, j] = array_indices(phDP, gtv_RS_ind[j])
    endfor

    orig_RS_mc = round(total(mc, 2)/n_elements(gtv_RS_ind))
    orig_mc_p = round(total(mc_p, 2)/n_elements(gtv_RS_ind))
    orig_mc_ph = round(total(mc_ph, 2)/n_elements(gtv_RS_ind))
    
    printf, 1, patientlist[i]
    printf, 2, (size(presc))[1:2]
    printf, 1, 'Presc:'
    printf, 1, presc[*, *, orig_RS_mc[-1]]
    printf, 1, 'Photon:'
    printf, 1, phDP[*, *, orig_RS_mc[-1]]
    printf, 1, 'Proton:'
    printf, 1, pDP[*, *, orig_RS_mc[-1]]
  endfor
  
  close, 1
  close, 2
end


function Dose_Plotter2, patientlist
  filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "DvD_for_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
  storer = Dose_Reader(patientlist, 1)
  
  openw, 1, filename
  for i = 0, n_elements(patientlist) - 1 do begin
    phDP = *(*storer[1])[i]
    pDP = *(*storer[3])[i]
    presc = *(*storer[4])[i]
    gtv_RS_ind = *(*storer[5])[i]

    printf, 1, patientlist[i]
    printf, 1, 'Presc:'
    printf, 1, presc[gtv_RS_ind]
    printf, 1, 'Photon:'
    printf, 1, phDP[gtv_RS_ind]
    printf, 1, 'Proton:'
    printf, 1, pDP[gtv_RS_ind]
  endfor

  close, 1 
  
  
end