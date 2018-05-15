function TCP_finder, patientlist

  constant = 22974.8
  
  pD   = ptrarr(n_elements(patientlist))
  pDP  = ptrarr(n_elements(patientlist))
  phD  = ptrarr(n_elements(patientlist))
  phDP = ptrarr(n_elements(patientlist))

  GTVindex = ptrarr(n_elements(patientlist))
  TCPmatrix = ptrarr(n_elements(patientlist))
  
  RSinv = ptrarr(n_elements(patientlist))
  RSpresc = ptrarr(n_elements(patientlist))
  PETmatrix = ptrarr(n_elements(patientlist))
  voxelsize = ptrarr(n_elements(patientlist))

  for i = 0, n_elements(patientlist)-1 do begin
    patient = patientlist[i]


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
    
    RSinv[i] = ptr_new(*(inv_doseRS_infomatrix[0])/100.)
    RSpresc[i] = ptr_new(*(presc_doseRS_infomatrix[0])/100.)
    PETmatrix[i] = ptr_new(*(pet_infomatrix[0])) ;NB! Allthough I use read_dat here as well, don't use any information beyond "Dose", which in this case is the pet matrix, and "number of voxels" as these are just fillers
    voxelsize[i] = ptr_new(*(p_infomatrix[2]))
    fractions = 34
    
    GTVindex[i] = ptr_new(where((*RSinv[i]) lt 50.0))

    TCPmatrix[i] = ptr_new(tcpmodel(*phD[i], *phDP[i], *pD[i], *pDP[i], *RSpresc[i], *PETmatrix[i], (*voxelsize[i]), fractions, *GTVindex[i], Constant = constant))
  endfor
  
  
  filename1 = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "TCP68_basedOn_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
  filename2 = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "TCPpres_basedOn_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
  
  openw, 1, filename1
  openw, 2, filename2

  for i = 0, n_elements(patientlist) - 1 do begin
    print, i
    printf, 1, patientlist[i], mean(*(*TCPmatrix[i])[5])
    printf, 2, patientlist[i], mean(*(*TCPmatrix[i])[4])
  endfor

  close, 1
  close, 2 
 end