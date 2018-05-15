function DVH_Eirik, p_dose, p_dpbn_dose, ph_dose, ph_dpbn_dose, ROI, patient
  
  ;Gjennomsnitt for alle organ, men ett plot per doseplan. Så altså et 2x2 grid med plots for f.eks. Parotid 1 og 2, Medulla og GTV?
  
  index = read_dat_ind(patient, ROI)
  pD = p_dose[index]
  pDPD = p_dpbn_dose[index]
  phD = ph_dose[index]
  phDPD = ph_dpbn_dose[index]
  
  maximum = 100; Gy
  minimum = 1
  
  pDhist = histogram(pD, max = maximum, min = minimum, locations = xbinP)
  pDPDhist = histogram(pDPD, max = maximum,  min = minimum, locations = xbinPDP)
  phDhist = histogram(phD, max = maximum, min = minimum, locations = xbinPHD)
  phDPDhist = histogram(phDPD, max = maximum, min = minimum, locations = xbinPHDPD)
  
  tot_vox = make_array(size = size(xbinP*4))
  tot_voxpluss = make_array(size = size(tot_vox))
  tot_voxminus = make_array(size = size(tot_vox))
  
  for i = 0, n_elements(pDhist)-1 do begin
    ;tot_vox[i] = (total(pDhist[i:-1]) + total(pDPDhist[i:-1]) + total(phDhist[i:-1]) + total(phDPDhist[i:-1])) / float(total(pDhist) + total(pDPDhist) + total(phDhist) + total(phDPDhist))
     tot_vox[i] = mean([total(pDhist[i:-1]),total(pDPDhist[i:-1]),total(phDhist[i:-1]),total(phDPDhist[i:-1])]) / float(mean([total(pDhist),total(pDPDhist),total(phDhist),total(phDPDhist)]))
     tot_voxpluss[i] = tot_vox[i] + stddev([total(pDhist[i:-1]),total(pDPDhist[i:-1]),total(phDhist[i:-1]),total(phDPDhist[i:-1])])/ float(mean([total(pDhist),total(pDPDhist),total(phDhist),total(phDPDhist)]))
     tot_voxminus[i] = tot_vox[i] - stddev([total(pDhist[i:-1]),total(pDPDhist[i:-1]),total(phDhist[i:-1]),total(phDPDhist[i:-1])])/ float(mean([total(pDhist),total(pDPDhist),total(phDhist),total(phDPDhist)]))
  endfor
  stop
end

function DVH_Eirik2, ROIlist, patientlist
  maximum = 100; Gy
  minimum = 0.1


  pD   = ptrarr(n_elements(patientlist))
  pDP  = ptrarr(n_elements(patientlist))
  phD  = ptrarr(n_elements(patientlist))
  phDP = ptrarr(n_elements(patientlist))
  
  ipsi = ['L', 'R', 'L', 'L', 'L', 'R', 'L', 'R', 'R']
  cont = ['R', 'L', 'R', 'R', 'R', 'L', 'R', 'L', 'L']
  
  
  ROIindex = ptrarr(n_elements(patientlist))
  
  
  
  for i = 0, n_elements(patientlist)-1 do begin
    patient = patientlist[i]
    print, patient
    
    if patient eq 'Patient 1' then begin
      P_list = 'p' + (strsplit(patient, /extract))[-1]
      RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_test_hn_dpbn_p1^p1_Doseplan_'
      inv_doseRS_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_inv.dat'))

      p_infomatrix = read_dat((RSlokasjon + 'robust_pr_BeamSet_robust_pr.dat'))
      p_dpbn_infomatrix = read_dat((RSlokasjon + 'robust_pr_BeamSet_robust_dpbn_pr.dat'))
      ph_infomatrix = read_dat((RSlokasjon + 'robust_ph_BeamSet_robust_ph.dat'))
      ph_dpbn_infomatrix = read_dat((RSlokasjon + 'robust_ph_BeamSet_robust_dpbn_ph.dat'))
    endif

    if patient ne 'Patient 1' then begin
      P_list = 'P' + (strsplit(patient, /extract))[-1]
      RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_Test^' + P_list + '_Doseplan_'
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
    RSinv = *(inv_doseRS_infomatrix[0])/100.
    
    ROIindex_pat = ptrarr(n_elements(ROIlist))
    
    for j = 0, n_elements(ROIlist)-1 do begin
      if ROIlist[j] eq 'Ipsi' then begin
        ROIer = 'Parotid_' + ipsi[i]
        ROIindex_pat[j] = ptr_new(read_dat_ind(patient, ROIer))
      endif
      
      if ROIlist[j] eq 'Cont' then begin
        ROIer = 'Parotid_' + cont[i]
        ROIindex_pat[j] = ptr_new(read_dat_ind(patient, ROIer))
      endif
      
      if ROIlist[j] eq 'GTV68' then begin
        ROIindex_pat[j] = ptr_new(where(RSinv lt 50))
      endif
      
      if (ROIlist[j] ne 'Ipsi' && ROIlist[j] ne 'Cont' && ROIlist[j] ne 'GTV68') then begin
        ROIindex_pat[j] = ptr_new(read_dat_ind(patient, ROIlist[j]))
      endif
    endfor
    
    ROIindex[i] = ptr_new(ROIindex_pat)
  endfor
  
  tot_vox_arr = ptrarr(n_elements(ROIlist)*4)
  tot_vox_arr_std = ptrarr(n_elements(ROIlist)*4)
  
  for k = 0, n_elements(ROIlist)-1 do begin
    pDhistos   = ptrarr(n_elements(patientlist))
    pDPhistos  = ptrarr(n_elements(patientlist))
    phDhistos  = ptrarr(n_elements(patientlist))
    phDPhistos = ptrarr(n_elements(patientlist))
    
    for j = 0, n_elements(patientlist) - 1 do begin
      index = *(*ROIindex[j])[k]
      pDhistos[j] = ptr_new(histogram((*pD[j])[index], min = minimum, max = maximum, nbins = 1001, locations = xbin))
      pDPhistos[j] = ptr_new(histogram((*pDP[j])[index], min = minimum, max = maximum, nbins = 1001, locations = xbin))
      phDhistos[j] = ptr_new(histogram((*phD[j])[index], min = minimum, max = maximum, nbins = 1001, locations = xbin))
      phDPhistos[j] = ptr_new(histogram((*phDP[j])[index], min = minimum, max = maximum, nbins = 1001, locations = xbin))
    endfor
    
    tot_vox1 = make_array(size = size(xbin*4))
    tot_vox_std1 = make_array(size = size(xbin*4))
    tot_vox2 = make_array(size = size(xbin*4))
    tot_vox_std2 = make_array(size = size(xbin*4))
    tot_vox3 = make_array(size = size(xbin*4))
    tot_vox_std3 = make_array(size = size(xbin*4))
    tot_vox4 = make_array(size = size(xbin*4))
    tot_vox_std4 = make_array(size = size(xbin*4))
    
    norm1=fltarr(n_elements(patientlist))
    norm2=fltarr(n_elements(patientlist))
    norm3=fltarr(n_elements(patientlist))
    norm4=fltarr(n_elements(patientlist))

    for i = 0, n_elements(patientlist)-1 do begin   ;Goes through every patient
      norm1[i] = total((*(pDhistos[i]))[0:-1])   ;Counts all contained in this bin (j) and all after for plan pDhistos
      norm2[i] = total((*(pDPhistos[i]))[0:-1])
      norm3[i] = total((*(phDhistos[i]))[0:-1])
      norm4[i] = total((*(phDPhistos[i]))[0:-1])
    endfor
    
    for j = 0, n_elements(tot_vox1)-1 do begin   ; Goes through every bin
      temp_arr1 = fltarr(n_elements(patientlist))
      temp_arr2 = fltarr(n_elements(patientlist))
      temp_arr3 = fltarr(n_elements(patientlist))
      temp_arr4 = fltarr(n_elements(patientlist))  ;make_array(n_elements(patientlist), value = 5)
      
      for i = 0, n_elements(patientlist)-1 do begin   ;Goes through every patient
        temp_arr1[i] = total((*(pDhistos[i]))[j:-1])/norm1[i]   ;Counts all contained in this bin (j) and all after for plan pDhistos
        temp_arr2[i] = total((*(pDPhistos[i]))[j:-1])/norm2[i]
        temp_arr3[i] = total((*(phDhistos[i]))[j:-1])/norm3[i]
        temp_arr4[i] = total((*(phDPhistos[i]))[j:-1])/norm4[i]
      endfor
      
      tot_vox1[j] = mean(temp_arr1)   ;Mean values of the total of all patients for bin (j)
      tot_vox_std1[j] = stddev(temp_arr1)     ;STD of total of all patients for bin (j)
      tot_vox2[j] = mean(temp_arr2)
      tot_vox_std2[j] = stddev(temp_arr2)   
      tot_vox3[j] = mean(temp_arr3)
      tot_vox_std3[j] = stddev(temp_arr3)
      tot_vox4[j] = mean(temp_arr4)
      tot_vox_std4[j] = stddev(temp_arr4)  
      

    endfor
    
    tot_vox_arr[k + k*3: k + k*3 + 3] = [ptr_new(tot_vox1), ptr_new(tot_vox2), ptr_new(tot_vox3), ptr_new(tot_vox4)]
    tot_vox_arr_std[k + k*3: k + k*3 + 3] = [ptr_new(tot_vox_std1), ptr_new(tot_vox_std2), ptr_new(tot_vox_std3), ptr_new(tot_vox_std4)]
;      hP = histogram(mean([total(pDhist[i:-1]),total(pDPDhist[i:-1]),total(phDhist[i:-1]),total(phDPDhist[i:-1])]) / float(mean([total(pDhist),total(pDPDhist),total(phDhist),total(phDPDhist)])))
;      hP = histogram(mean([total(((*pD[0])*(*ROIindex[0])[i])[i:-1])]))
;    endfor
  endfor
  
  colorlist = ['-r', '-b', '-g', '-k']
  
  
  for i = 0, n_elements(ROIlist)-1 do begin
    filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "DVHfor_" + ROIlist[i] + "basedOn_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
    openw, 1, filename
    printf, 1, xbin
    printf, 1, 'Goodbye'
    for j = 0, 3 do begin
      printf, 1, *(tot_vox_arr[j + i*3])
      printf, 1, 'Hello'
      printf, 1, *(tot_vox_arr_std[j + i*4])
      printf, 1, 'Goodbye'
    endfor
    close, 1
  endfor
  
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