function QVH, patientlist
  maximum = 1.3; Gy
  minimum = 0.7


  pD   = ptrarr(n_elements(patientlist))
  pDP  = ptrarr(n_elements(patientlist))
  phD  = ptrarr(n_elements(patientlist))
  phDP = ptrarr(n_elements(patientlist))
  RSpresc = ptrarr(n_elements(patientlist))

  ipsi = ['L', 'R', 'L', 'L', 'L', 'R', 'L', 'R', 'R']
  cont = ['R', 'L', 'R', 'R', 'R', 'L', 'R', 'L', 'L']


  ROIindex = ptrarr(n_elements(patientlist))


  for i = 0, n_elements(patientlist)-1 do begin
    patient = patientlist[i]

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

    pDP[i] = ptr_new(*(p_dpbn_infomatrix[0])/100. * 34.)   ;Ganges med 34 fraksjoner
    phDP[i] = ptr_new(*(ph_dpbn_infomatrix[0])/100. * 34.)
    RSpresc[i] = ptr_new(*(presc_doseRS_infomatrix[0])/100.)   ;NB! Bare én fraksjon på preskribert dose
    RSinv = *(inv_doseRS_infomatrix[0])/100.
    
    ROIindex[i] = ptr_new(where(RSinv lt 50.0))
  endfor

  tot_vox_arr = ptrarr(2)
  tot_vox_arr_std = ptrarr(2)


  pDPhistos  = ptrarr(n_elements(patientlist))
  phDPhistos = ptrarr(n_elements(patientlist))

  for j = 0, n_elements(patientlist) - 1 do begin
    index = (*ROIindex[j])
    pDPhistos[j] = ptr_new(histogram((*pDP[j])[index]/((*RSpresc[j])[index]), min = minimum, max = maximum, nbins = 1001, locations = xbin))
    phDPhistos[j] = ptr_new(histogram(((*phDP[j])[index])/((*RSpresc[j])[index]), min = minimum, max = maximum, nbins = 1001, locations = xbin))
  endfor

  tot_vox2 = make_array(size = size(xbin*2))
  tot_vox_std2 = make_array(size = size(xbin*2))
  tot_vox4 = make_array(size = size(xbin*2))
  tot_vox_std4 = make_array(size = size(xbin*2))

  norm2=fltarr(n_elements(patientlist))
  norm4=fltarr(n_elements(patientlist))

  for i = 0, n_elements(patientlist)-1 do begin   ;Goes through every patient
    norm2[i] = total((*(pDPhistos[i]))[0:-1])  ;Counts all contained in this bin (j) and all after for plan pDPhistos
    norm4[i] = total((*(phDPhistos[i]))[0:-1])
  endfor

  for j = 0, n_elements(tot_vox2)-1 do begin   ; Goes through every bin
    temp_arr2 = fltarr(n_elements(patientlist))
    temp_arr4 = fltarr(n_elements(patientlist))  ;make_array(n_elements(patientlist), value = 5)

    for i = 0, n_elements(patientlist)-1 do begin   ;Goes through every patient
      temp_arr2[i] = total((*(pDPhistos[i]))[j:-1])/norm2[i]   ;Counts all contained in this bin (j) and all after for plan pDPhistos
      temp_arr4[i] = total((*(phDPhistos[i]))[j:-1])/norm4[i]
    endfor

    tot_vox2[j] = mean(temp_arr2)   ;Mean values of the total of all patients for bin (j)
    tot_vox_std2[j] = stddev(temp_arr2)     ;STD of total of all patients for bin (j)
    tot_vox4[j] = mean(temp_arr4)
    tot_vox_std4[j] = stddev(temp_arr4)




    tot_vox_arr[0:1] = [ptr_new(tot_vox2), ptr_new(tot_vox4)]   ;Protons [0], photons [1]
    tot_vox_arr_std[0:1] = [ptr_new(tot_vox_std2), ptr_new(tot_vox_std4)]
    ;      hP = histogram(mean([total(pDhist[i:-1]),total(pDPDhist[i:-1]),total(phDhist[i:-1]),total(phDPDhist[i:-1])]) / float(mean([total(pDhist),total(pDPDhist),total(phDhist),total(phDPDhist)])))
    ;      hP = histogram(mean([total(((*pD[0])*(*ROIindex[0])[i])[i:-1])]))
    ;    endfor
  endfor

  colorlist = ['-r', '-b', '-g', '-k']



  filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "QVH_basedOn_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
  openw, 1, filename
  printf, 1, xbin
  printf, 1, 'Goodbye'
  for j = 0, 1 do begin
    printf, 1, *(tot_vox_arr[j])
    printf, 1, 'Hello'
    printf, 1, *(tot_vox_arr_std[j])
    printf, 1, 'Goodbye'
  endfor
  close, 1

  ;  for i = 0, n_elements(ROIlist) do begin
  ;    if i eq 0 then begin
  ;      p1 = plot(xbin, *(tot_vox_arr[0])/float(max(*(tot_vox_arr[0]))), layout = [2,2,1], colorlist[i], title = 'Proton', /stairstep)
  ;      p2 = plot(xbin, *(tot_vox_arr[1])/float(max(*(tot_vox_arr[1]))), layout = [2,2,2], colorlist[i], title = 'Proton DPBN', /stairstep, /current)
  ;      p3 = plot(xbin, *(tot_vox_arr[2])/float(max(*(tot_vox_arr[2]))), layout = [2,2,3], colorlist[i], title = 'Photon', /stairstep, /current)
  ;      p4 = plot(xbin, *(tot_vox_arr[3])/float(max(*(tot_vox_arr[3]))), layout = [2,2,4], colorlist[i], title = 'Photon DPBN', /stairstep, /current)
  ;      i = i + 1
  ;    endif
  ;
  ;    p5 = plot(xbin, *(tot_vox_arr[i*4 + 0])/float(max(*(tot_vox_arr[i*4 + 0]))), layout = [2,2,1], colorlist[i], /stairstep, /current)
  ;    p6 = plot(xbin, *(tot_vox_arr[i*4 + 1])/float(max(*(tot_vox_arr[i*4 + 1]))), layout = [2,2,2], colorlist[i], /stairstep, /current)
  ;    p7 = plot(xbin, *(tot_vox_arr[i*4 + 2])/float(max(*(tot_vox_arr[i*4 + 2]))), layout = [2,2,3], colorlist[i], /stairstep, /current)
  ;    p8 = plot(xbin, *(tot_vox_arr[i*4 + 3])/float(max(*(tot_vox_arr[i*4 + 3]))), layout = [2,2,4], colorlist[i], /stairstep, /current)
  ;
  ;  endfor

  stop

end