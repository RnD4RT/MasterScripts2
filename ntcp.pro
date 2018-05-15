function NTCP_lyman, t
  return, exp(-t^2/2.0)
end

function TD50, v, TD50_1, n
  return, TD50_1 * v^(-n)
end

function NTCP_calc, dosemap, index

  n = 1.0
  m = mean([0.38, 0.40, 0.45])
  TD50_1 = mean([41.3, 39.9, 39]) ;Gy
  d_ref = max(dosemap[index])

  v_effj = 0.003*0.003*0.002/(0.003*0.003*0.002*n_elements(index)) * (dosemap[index]/d_ref)^(1.0/n)

  v_eff = total(v_effj)


  
  t = (d_ref - TD50(v_eff, TD50_1, n))/(m*TD50(v_eff, TD50_1, n))

  B = -1000

  QSIMP, 'NTCP_lyman', B, t, result   ;Found online from: https://idlastro.gsfc.nasa.gov/ftp/pro/math/qsimp.pro

  return, result*(1.0/sqrt(2*!PI))
end


function NTCP, p_dose, p_dpbn_dose, ph_dose, ph_dpbn_dose, OAR1, patient
  OAR_ind1 = read_dat_ind(patient, OAR1)
  
  store_matrix = ptrarr(4)
  store_matrix[0] = ptr_new(OAR1)
  store_matrix[1] = ptr_new(['ph_dose', 'ph_dpbn_dose', 'p_dose', 'p_dpbn_dose'])
  store_matrix[2] = ptr_new([NTCP_calc(ph_dose, OAR_ind1), NTCP_calc(ph_dpbn_dose, OAR_ind1), NTCP_calc(p_dose, OAR_ind1), NTCP_calc(p_dpbn_dose, OAR_ind1)])
  store_matrix[3] = ptr_new([mean(ph_dose[OAR_ind1]), mean(ph_dpbn_dose[OAR_ind1]), mean(p_dose[OAR_ind1]), mean(p_dpbn_dose[OAR_ind1])])
  
  return, store_matrix
end


function NTCP2, ROI, patientlist

  pD   = ptrarr(n_elements(patientlist))
  pDP  = ptrarr(n_elements(patientlist))
  phD  = ptrarr(n_elements(patientlist))
  phDP = ptrarr(n_elements(patientlist))

  ipsi = ['L', 'R', 'L', 'L', 'L', 'R', 'L', 'R', 'R']
  cont = ['R', 'L', 'R', 'R', 'R', 'L', 'R', 'L', 'L']

  ROIinfo = ptrarr(n_elements(patientlist))

  for i = 0, n_elements(patientlist)-1 do begin
    patient = patientlist[i]

    if patient eq 'Patient 1' then begin
      P_list = 'p' + (strsplit(patient, /extract))[-1]
      RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_test_hn_dpbn_p1^p1_Doseplan_'

      p_infomatrix = read_dat((RSlokasjon + 'robust_pr_BeamSet_robust_pr.dat'))
      p_dpbn_infomatrix = read_dat((RSlokasjon + 'robust_pr_BeamSet_robust_dpbn_pr.dat'))
      ph_infomatrix = read_dat((RSlokasjon + 'robust_ph_BeamSet_robust_ph.dat'))
      ph_dpbn_infomatrix = read_dat((RSlokasjon + 'robust_ph_BeamSet_robust_dpbn_ph.dat'))
    endif

    if patient ne 'Patient 1' then begin
      P_list = 'P' + (strsplit(patient, /extract))[-1]
      RSlokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\DoseData\fraction_dose_patient_Test^' + P_list + '_Doseplan_'

      p_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p.dat'))
      p_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_p_BeamSet_rob_p_dpbn.dat'))
      ph_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph.dat'))
      ph_dpbn_infomatrix = read_dat((RSlokasjon + 'rob_ph_BeamSet_rob_ph_dpbn.dat'))
    endif

    pD[i] = ptr_new(*(p_infomatrix[0])/100. * 34.)  ;Må deles på 100 for å gå fra cGy til Gy
    pDP[i] = ptr_new(*(p_dpbn_infomatrix[0])/100. * 34.)   ;Ganges med 34 fraksjoner
    phD[i] = ptr_new(*(ph_infomatrix[0])/100. * 34.)
    phDP[i] = ptr_new(*(ph_dpbn_infomatrix[0])/100. * 34.)
    
    if ROI eq 'Ipsi' then begin
      ROIer = 'Parotid_' + ipsi[i]
      ROIinfo[i] = ptr_new(NTCP((*pD[i]), (*pDP[i]), (*phD[i]), (*phDP[i]), ROIer, patient))
    endif

    if ROI eq 'Cont' then begin
      ROIer = 'Parotid_' + cont[i]
      ROIinfo[i] = ptr_new(NTCP((*pD[i]), (*pDP[i]), (*phD[i]), (*phDP[i]), ROIer, patient))
    endif

    if (ROI ne 'Ipsi' && ROI ne 'Cont') then begin
      ROIinfo[i] = ptr_new(NTCP((*pD[i]), (*pDP[i]), (*phD[i]), (*phDP[i]), ROI, patient))
    endif
  endfor

  ;*(*ROIinfo[0])[2] gives the NTCP for each doseplan in the order stated in *(*ROIinfo[0])[1]
  
  filename1 = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "NTCPfor_" + ROI + "_basedOn_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
  filename2 = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "NTCPMeanDose_for_" + ROI + "_basedOn_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
  openw, 1, filename1
  openw, 2, filename2
  
  printf, 1, *(*ROIinfo[0])[1]
  printf, 2, *(*ROIinfo[0])[1]
;  printf, 1, patientlist
;  printf, 2, patientlist
  
  for i = 0, n_elements(patientlist) - 1 do begin
    print, i
    printf, 1, patientlist[i], *(*ROIinfo[i])[2]
    printf, 2, patientlist[i], *(*ROIinfo[i])[3]
;    
;    printf, 1, '\r\n'
;    printf, 2, '\r\n'
  endfor
  
  close, 1
  close, 2

end


