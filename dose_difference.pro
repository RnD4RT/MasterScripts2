function dose_difference, d, d_rob_ph, d_rob_ph_dpbn, d_rob_p, d_rob_p_dpbn, dose_presc, gtv_pet_ind, voxel_size  
  N_T = n_elements(gtv_pet_ind)
  
  Q_i = d[gtv_pet_ind]/dose_presc[gtv_pet_ind]
  Q_i_rob_ph = d_rob_ph[gtv_pet_ind]/dose_presc[gtv_pet_ind]
  Q_i_rob_ph_dpbn = d_rob_ph_dpbn[gtv_pet_ind]/dose_presc[gtv_pet_ind]
  Q_i_rob_p = d_rob_p[gtv_pet_ind]/dose_presc[gtv_pet_ind]
  Q_i_rob_p_dpbn = d_rob_p_dpbn[gtv_pet_ind]/dose_presc[gtv_pet_ind]
  
  QF = 1.0/N_T * total(abs(Q_i - 1))
  QF_rob_ph = 1.0/N_T * total(abs(Q_i_rob_ph - 1))
  QF_rob_ph_dpbn = 1.0/N_T * total(abs(Q_i_rob_ph_dpbn - 1))
  QF_rob_p = 1.0/N_T * total(abs(Q_i_rob_p - 1))
  QF_rob_p_dpbn = 1.0/N_T * total(abs(Q_i_rob_p_dpbn - 1))
  
;  dV = voxel_size[0] * voxel_size[1] * voxel_size[2]
;  V = dV*N_T
;  volumes = findgen(n_elements(Q_i), increment = dV)
;  dQ = (max(Q_i) - min(Q_i)) / (100.0)
;  Q = FINDGEN(100, start = min(Q_i), increment = dQ)
;  Q_counter = make_array(n_elements(Q))
;  volumes_add = make_array(n_elements(Q))
;  
;  for i= 0, n_elements(Q_i)-1 do begin
;    for j = 0, n_elements(Q)-2 do begin
;      if (Q_i[i] ge Q[j]) and (Q_i[i] lt Q[j+1]) then begin
;        Q_counter[j] = Q_counter[j] + 1
;      endif
;    endfor
;  endfor
;  
;  volumes_add[0] = Q_counter[0]*dV
;  for i = 1, n_elements(Q_counter)-1 do begin
;    volumes_add[i] = volumes_add[i-1] + Q_counter[i]*dV
;  endfor
;  
;  
;  ;p1 = plot(Q, volumes_add/V*100, /Current)
;  p2 = barplot(Q, Q_counter, /Current)
  
;  print, "QF: ", QF
;  print, "QF_rob_ph: ", QF_rob_ph, "    QF_rob_ph_dpbn: ", QF_rob_ph_dpbn
;  print, "QF_rob_p: ", QF_rob_p, "    QF_rob_p_dpbn:   ", QF_rob_p_dpbn
  
  store_matrix = ptrarr(1)
  store_matrix[0] = ptr_new([QF, QF_rob_ph, QF_rob_ph_dpbn, QF_rob_p, QF_rob_p_dpbn])
  
  return, store_matrix
end
