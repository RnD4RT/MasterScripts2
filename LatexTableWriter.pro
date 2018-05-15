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

function TCPtable, patientlist
  close, 1
  filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\TCPtable.txt'
  storer = Dose_Reader(patientlist, 0)
  
  TCPmatrix = ptrarr(n_elements(patientlist))
  TCPph = fltarr(n_elements(patientlist))
  TCPphDP = fltarr(n_elements(patientlist))
  TCPp = fltarr(n_elements(patientlist))
  TCPpDP = fltarr(n_elements(patientlist))
  TCPpresc = fltarr(n_elements(patientlist))
  TCP68 = fltarr(n_elements(patientlist))
  
  openw, 1, filename
  printf, 1, "\textbf{Patient}   & \textbf{Photon} & \textbf{Photon DPBN} & \textbf{Proton} & \textbf{Proton DPBN} & \textbf{Prescribed} & \textbf{2Gy Dose Plan}  \\  \noalign{\hrule height 1.5pt}"
  for i = 0, n_elements(patientlist) - 1 do begin
    phD_cur = *(*storer[0])[i]
    phDP_cur = *(*storer[1])[i]
    pD_cur = *(*storer[2])[i]
    pDP_cur = *(*storer[3])[i]
    presc_cur = *(*storer[4])[i]
    gtv_RS_ind_cur = *(*storer[5])[i]
    PETmatrix_cur = *(*storer[6])[i]
    voxelsize_cur = *(*storer[7])[i]

    fractions = 34

    TCPmatrix[i] = ptr_new(tcpmodel(phD_cur, phDP_cur, pD_cur, pDP_cur, presc_cur, PETmatrix_cur, voxelsize_cur, fractions, gtv_RS_ind_cur, Constant = 22974.8))
;    printf, 1, patientlist[i], ' & ', (*(*TCPmatrix)[0]), ' & ', (*(*TCPmatrix)[1]),  ' & ', (*(*TCPmatrix)[2]),  ' & ', (*(*TCPmatrix)[3]),  ' & ', (*(*TCPmatrix)[4]),  ' & ', (*(*TCPmatrix)[5]), '\\'
    printf, 1, patientlist[i] + ' & ' + string((*(*TCPmatrix[i])[0]), FORMAT='(F5.2)') + ' & ' + string((*(*TCPmatrix[i])[1]), FORMAT='(F5.2)') + ' & ' + string((*(*TCPmatrix[i])[2]), FORMAT='(F5.2)') + ' & ' + string((*(*TCPmatrix[i])[3]), FORMAT='(F5.2)') + ' & ' + string((*(*TCPmatrix[i])[4]), FORMAT='(F5.2)') + ' & ' + string((*(*TCPmatrix[i])[5]), FORMAT='(F5.2)') + '\\'
    TCPph[i] = (*(*TCPmatrix[i])[0])
    TCPphDP[i] = (*(*TCPmatrix[i])[1])
    TCPp[i] = (*(*TCPmatrix[i])[2])
    TCPpDP[i] = (*(*TCPmatrix[i])[3])
    TCPpresc[i] = (*(*TCPmatrix[i])[4])
    TCP68[i] = (*(*TCPmatrix[i])[5])
  endfor

  printf, 1, '\noalign{\hrule height 1.5pt}'
  printf, 1, '\textbf{Total Mean} & ' + string(mean(TCPph), FORMAT='(F5.2)') + ' $\pm$ ' + string(stddev(TCPph), FORMAT='(F5.2)') + ' & ' + string(mean(TCPphDP), FORMAT='(F5.2)') + ' $\pm$ ' + string(stddev(TCPphDP), FORMAT='(F5.2)') + ' & ' + string(mean(TCPp), FORMAT='(F5.2)') + ' $\pm$ ' + string(stddev(TCPp), FORMAT='(F5.2)') + ' & ' + string(mean(TCPpDP), FORMAT='(F5.2)') + ' $\pm$ ' + string(stddev(TCPpDP), FORMAT='(F5.2)') + ' & ' + string(mean(TCPpresc), FORMAT='(F5.2)') + ' $\pm$ ' + string(stddev(TCPpresc), FORMAT='(F5.2)') + ' & ' + string(mean(TCP68), FORMAT='(F5.2)') + ' $\pm$ ' + string(stddev(TCP68), FORMAT='(F5.2)')
  close, 1
  
end

function QFtable, patientlist
  close, 1
  filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\QFtable.txt'
  storer = Dose_Reader(patientlist, 0)
  
  QFmatrix = ptrarr(n_elements(patientlist))
  QFph = ptrarr(n_elements(patientlist))
  QFp = fltarr(n_elements(patientlist))
  QFdiff = fltarr(n_elements(patientlist))
  
  openw, 1, filename
  printf, 1, "\textbf{Patient}   & \textbf{Proton} & \textbf{Photon} & \textbf{Difference} \\  \noalign{\hrule height 1.5pt}"
  for i = 0, n_elements(patientlist) - 1 do begin
    phD = *(*storer[0])[i]
    phDP = *(*storer[1])[i]
    pD = *(*storer[2])[i]
    pDP = *(*storer[3])[i]
    presc = *(*storer[4])[i]
    gtv_RS_ind = *(*storer[5])[i]
    PETmatrix = *(*storer[6])[i]
    voxelsize = *(*storer[7])[i]

    fractions = 34

    QFmatrix[i] = ptr_new(dose_difference_dpbn(phD, phDP, pDP, presc, gtv_RS_ind, voxelsize))
    printf, 1, patientlist[i] + ' & ' + string(((*(*QFmatrix[i])[0])[2]), FORMAT='(F5.3)') + ' & ' + string(((*(*QFmatrix[i])[0])[1]), FORMAT='(F5.3)') + ' & ' + string(((*(*QFmatrix[i])[0])[1]) - ((*(*QFmatrix[i])[0])[2]), FORMAT='(F5.3)') + ' \\ \cline{2-4}'
    
    QFp    = (*(*QFmatrix[i])[0])[2]
    QFph   = (*(*QFmatrix[i])[0])[1]
    QFdiff = (*(*QFmatrix[i])[0])[1] - (*(*QFmatrix[i])[0])[2]
  endfor
  
  printf, 1, '\noalign{\hrule height 1.5pt}'
  printf, 1, '\textbf{Total Mean} & ' + string(mean(QFp), FORMAT='(F5.3)') + ' $\pm$ ' + string(stddev(QFp), FORMAT='(F5.4)') + ' & ' + string(mean(QFph), FORMAT='(F5.3)') + ' $\pm$ ' + string(stddev(QFph), FORMAT='(F5.4)') + ' & ' + string(mean(QFdiff), FORMAT='(F5.3)') + ' $\pm$ ' + string(stddev(QFdiff), FORMAT='(F5.4)')
  close, 1
  
  stop
end

function DVHdoseTable, patientlist, ROIlist
  close, 1
  filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\DVHDosetable_for_IpsiContraSpinalCord.txt'
  storer = Dose_Reader(patientlist, 0)
  
  ipsi = ['L', 'R', 'L', 'L', 'L', 'R', 'L', 'R', 'R']
  cont = ['R', 'L', 'R', 'R', 'R', 'L', 'R', 'L', 'L']
  
  IpsiMax =  ptrarr(n_elements(patientlist))
  IpsiMean = ptrarr(n_elements(patientlist))
  IpsiStd = ptrarr(n_elements(patientlist))
  ContMax =  ptrarr(n_elements(patientlist))
  ContMean = ptrarr(n_elements(patientlist))
  ContStd = ptrarr(n_elements(patientlist))
  SCMax =  ptrarr(n_elements(patientlist))
  SCMean = ptrarr(n_elements(patientlist))
  SCStd = ptrarr(n_elements(patientlist))
  
  
  openw, 1, filename
  printf, 1, "\textbf{Patient} & \textbf{\ac{ROI}} & \textbf{Mean/Max Dose} & \textbf{Photon} & \textbf{Photon DPBN} & \textbf{Proton} & \textbf{Proton DPBN} \\  \noalign{\hrule height 1.5pt}"
  for i = 0, n_elements(patientlist) - 1 do begin
    patient = patientlist[i]
    phD = *(*storer[0])[i]
    phDP = *(*storer[1])[i]
    pD = *(*storer[2])[i]
    pDP = *(*storer[3])[i]
    presc = *(*storer[4])[i]
    gtv_RS_ind = *(*storer[5])[i]
    PETmatrix = *(*storer[6])[i]
    voxelsize = *(*storer[7])[i]

    fractions = 34
    
    ROIindex_pat = ptrarr(n_elements(ROIlist))
    
    
    if patient eq 'Patient 11' then patient = 'Patient 10'
    printf, 1, '\multirow{6}{*}{' + patient + '}'
    if patient eq 'Patient 10' then patient = 'Patient 11'
    
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
      
      
      if ROIlist[j] eq 'Ipsi' then begin
        ROIname = 'Ipsilateral'
        IpsiMax[i] =  ptr_new([max(phD[*ROIindex_pat[j]]),max(phDP[*ROIindex_pat[j]]), max(pD[*ROIindex_pat[j]]), max(pDP[*ROIindex_pat[j]])])
        IpsiMean[i] = ptr_new([mean(phD[*ROIindex_pat[j]]), mean(phDP[*ROIindex_pat[j]]), mean(pD[*ROIindex_pat[j]]), mean(pDP[*ROIindex_pat[j]])])
        IpsiStd[i] = ptr_new([stddev(phD[*ROIindex_pat[j]]), stddev(phDP[*ROIindex_pat[j]]), stddev(pD[*ROIindex_pat[j]]), stddev(pDP[*ROIindex_pat[j]])])
      endif
      if ROIlist[j] eq 'Cont' then begin
        ROIname = 'Contralateral'
        ContMax[i] =  ptr_new([max(phD[*ROIindex_pat[j]]),max(phDP[*ROIindex_pat[j]]), max(pD[*ROIindex_pat[j]]), max(pDP[*ROIindex_pat[j]])])
        ContMean[i] = ptr_new([mean(phD[*ROIindex_pat[j]]), mean(phDP[*ROIindex_pat[j]]), mean(pD[*ROIindex_pat[j]]), mean(pDP[*ROIindex_pat[j]])])
        ContStd[i] = ptr_new([stddev(phD[*ROIindex_pat[j]]), stddev(phDP[*ROIindex_pat[j]]), stddev(pD[*ROIindex_pat[j]]), stddev(pDP[*ROIindex_pat[j]])])
      endif
      
      if ROIlist[j] eq 'SpinalCord' then begin
        ROIname = 'Spinal Cord'
        SCMax[i] =  ptr_new([max(phD[*ROIindex_pat[j]]),max(phDP[*ROIindex_pat[j]]), max(pD[*ROIindex_pat[j]]), max(pDP[*ROIindex_pat[j]])])
        SCMean[i] = ptr_new([mean(phD[*ROIindex_pat[j]]), mean(phDP[*ROIindex_pat[j]]), mean(pD[*ROIindex_pat[j]]), mean(pDP[*ROIindex_pat[j]])])
        SCStd[i] = ptr_new([stddev(phD[*ROIindex_pat[j]]), stddev(phDP[*ROIindex_pat[j]]), stddev(pD[*ROIindex_pat[j]]), stddev(pDP[*ROIindex_pat[j]])])
      endif
      
      
      
      if j lt n_elements(ROIlist) - 1 then begin
        printf, 1, ' & \multirow{2}{*}{' + ROIname + '} & Max & ' + string(max(phD[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(max(phDP[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(max(pD[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(max(pDP[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' \\ \cline{3-7}'
        printf, 1, ' & & Mean & ' + string(mean(phD[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(mean(phDP[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(mean(pD[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(mean(pDP[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' \\ \cline{2-7}'
      endif
      if j eq n_elements(ROIlist) - 1 then begin
        printf, 1, ' & \multirow{2}{*}{' + ROIname + '} & Max & ' + string(max(phD[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(max(phDP[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(max(pD[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(max(pDP[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' \\ \cline{3-7}'
        printf, 1, ' & & Mean & ' + string(mean(phD[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(mean(phDP[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(mean(pD[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' & ' + string(mean(pDP[*ROIindex_pat[j]]), FORMAT='(F15.2)') + ' \\ \noalign{\hrule height 1.2pt}'
      endif
      
    endfor
  endfor
  close, 1
  
  IpsiMax_ph = fltarr(n_elements(patientlist))
  IpsiMax_phDP = fltarr(n_elements(patientlist))
  IpsiMax_p = fltarr(n_elements(patientlist))
  IpsiMax_pDP = fltarr(n_elements(patientlist))
  IpsiMean_ph = fltarr(n_elements(patientlist))
  IpsiMean_phDP = fltarr(n_elements(patientlist))
  IpsiMean_p = fltarr(n_elements(patientlist))
  IpsiMean_pDP = fltarr(n_elements(patientlist))
  
  ContMax_ph = fltarr(n_elements(patientlist))
  ContMax_phDP = fltarr(n_elements(patientlist))
  ContMax_p = fltarr(n_elements(patientlist))
  ContMax_pDP = fltarr(n_elements(patientlist))
  ContMean_ph = fltarr(n_elements(patientlist))
  ContMean_phDP = fltarr(n_elements(patientlist))
  ContMean_p = fltarr(n_elements(patientlist))
  ContMean_pDP = fltarr(n_elements(patientlist))
  
  SCMax_ph = fltarr(n_elements(patientlist))
  SCMax_phDP = fltarr(n_elements(patientlist))
  SCMax_p = fltarr(n_elements(patientlist))
  SCMax_pDP = fltarr(n_elements(patientlist))
  SCMean_ph = fltarr(n_elements(patientlist))
  SCMean_phDP = fltarr(n_elements(patientlist))
  SCMean_p = fltarr(n_elements(patientlist))
  SCMean_pDP = fltarr(n_elements(patientlist))
  
  for i = 0, n_elements(patientlist)-1 do begin
      IpsiMax_ph[i] = (*(IpsiMax[i]))[0]
      IpsiMax_phDP[i] = (*(IpsiMax[i]))[1]
      IpsiMax_p[i] = (*(IpsiMax[i]))[2]
      IpsiMax_pDP[i] = (*(IpsiMax[i]))[1]
      IpsiMean_ph[i] = (*(IpsiMean[i]))[0]
      IpsiMean_phDP[i] = (*(IpsiMean[i]))[1]
      IpsiMean_p[i] = (*(IpsiMean[i]))[2]
      IpsiMean_pDP[i] = (*(IpsiMean[i]))[1]
      
      ContMax_ph[i] = (*(ContMax[i]))[0]
      ContMax_phDP[i] = (*(ContMax[i]))[1]
      ContMax_p[i] = (*(ContMax[i]))[2]
      ContMax_pDP[i] = (*(ContMax[i]))[1]
      ContMean_ph[i] = (*(ContMean[i]))[0]
      ContMean_phDP[i] = (*(ContMean[i]))[1]
      ContMean_p[i] = (*(ContMean[i]))[2]
      ContMean_pDP[i] = (*(ContMean[i]))[1]
      
      SCMax_ph[i] = (*(SCMax[i]))[0]
      SCMax_phDP[i] = (*(SCMax[i]))[1]
      SCMax_p[i] = (*(SCMax[i]))[2]
      SCMax_pDP[i] = (*(SCMax[i]))[1]
      SCMean_ph[i] = (*(SCMean[i]))[0]
      SCMean_phDP[i] = (*(SCMean[i]))[1]
      SCMean_p[i] = (*(SCMean[i]))[2]
      SCMean_pDP[i] = (*(SCMean[i]))[1]
  endfor
  filename2 = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\DVHDosetable2_for_IpsiContraSpinalCord.txt'
  
  
  openw, 1, filename2
  printf, 1, "\textbf{Mean/Max Dose} & \textbf{\ac{ROI}} & \textbf{Photon} & \textbf{Photon DPBN} & \textbf{Proton} & \textbf{Proton DPBN} \\  \noalign{\hrule height 1.5pt}"
  printf, 1, '\multirow{3}{*}{Mean} & Ipsilateral & ' +  string(mean(IpsiMean_ph), FORMAT='(F15.2)') + ' & ' +  string(mean(IpsiMean_phDP), FORMAT='(F15.2)') + ' & ' +  string(mean(IpsiMean_p), FORMAT='(F15.2)') + ' & ' +  string(mean(IpsiMean_pDP), FORMAT='(F15.2)') + ' \\'
  printf, 1, '\multirow{3}{*}{Mean} & Contlateral & ' +  string(mean(ContMean_ph), FORMAT='(F15.2)') + ' & ' +  string(mean(ContMean_phDP), FORMAT='(F15.2)') + ' & ' +  string(mean(ContMean_p), FORMAT='(F15.2)') + ' & ' +  string(mean(ContMean_pDP), FORMAT='(F15.2)') + ' \\'
  printf, 1, '\multirow{3}{*}{Mean} & Spinal Cord & ' +  string(mean(SCMean_ph), FORMAT='(F15.2)') + ' & ' +  string(mean(SCMean_phDP), FORMAT='(F15.2)') + ' & ' +  string(mean(SCMean_p), FORMAT='(F15.2)') + ' & ' +  string(mean(SCMean_pDP), FORMAT='(F15.2)') + ' \\ \hline'
  printf, 1, '\multirow{3}{*}{Max} & Ipsilateral & ' +  string(mean(IpsiMax_ph), FORMAT='(F15.2)') + ' & ' +  string(mean(IpsiMax_phDP), FORMAT='(F15.2)') + ' & ' +  string(mean(IpsiMax_p), FORMAT='(F15.2)') + ' & ' +  string(mean(IpsiMax_pDP), FORMAT='(F15.2)') + ' \\'
  printf, 1, '\multirow{3}{*}{Max} & Contlateral & ' +  string(mean(ContMax_ph), FORMAT='(F15.2)') + ' & ' +  string(mean(ContMax_phDP), FORMAT='(F15.2)') + ' & ' +  string(mean(ContMax_p), FORMAT='(F15.2)') + ' & ' +  string(mean(ContMax_pDP), FORMAT='(F15.2)') + ' \\'
  printf, 1, '\multirow{3}{*}{Max} & Spinal Cord & ' +  string(mean(SCMax_ph), FORMAT='(F15.2)') + ' & ' +  string(mean(SCMax_phDP), FORMAT='(F15.2)') + ' & ' +  string(mean(SCMax_p), FORMAT='(F15.2)') + ' & ' +  string(mean(SCMax_pDP), FORMAT='(F15.2)') + ' \\ \hline'
  
  close, 1
  stop
end