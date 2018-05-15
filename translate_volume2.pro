function translate_volume2, p_dose, p_dpbn_dose, ph_dose, ph_dpbn_dose, voxelsize, RSpresc, gtv_pet_ind, idl_presc, patient, petmatrix
  
  gtv_RS_ind = gtv_pet_ind

  x = [-0.1 ,0, 0.1, 0.2,  0.3]   ;cm
  ;x = [-0.3, 0,  0.3]   ;cm
  y = x
  z = x

  z_index = 0;round(n_elements(x)/2. + 0.4)

;  p_QF = fltarr(n_elements(x), n_elements(y), n_elements(z))
;  p_dpbn_QF = p_QF
;  ph_QF = p_QF
;  ph_dpbn_QF = p_QF
;  p_dpbn_TCP = p_QF
;  ph_dpbn_TCP = p_QF  

  p_ones = p_dpbn_dose
  p_ones[gtv_pet_ind] = 1
  p_ones[where(p_ones ne 1)] = 0
  
  shrinking = [2];[0, 0.5, 1, 1.5, 2, 2.5]
  
  store_matrix = ptrarr(6, n_elements(x)^3*n_elements(shrinking))

  TIC, /PROFILER
  prevPerc = 0
  timetaker = 0
  ;CGprogressbar = Obj_new('progressbar', /Start, Percent = 0)
  counter = 0
  for i = 0, n_elements(x) - 1 do begin
    for j = 0, n_elements(x) - 1 do begin
      for k = 0, n_elements(x) - 1 do begin
        ;OBS! CHECK out the translate difference. Why does one have - and the other not?
        ph_dpbn_trans = transform_volume(ph_dpbn_dose, translate = [x[i]/voxelsize[0], y[j]/voxelsize[1], z[k]/voxelsize[2]])

        ;Satt inn denne istedenfor den nedenfor 11.04
        p_dpbn_trans =  transform_volume(p_dpbn_dose, translate = [(x[i]/voxelsize[0]), (y[j]/voxelsize[1]), (z[k]/voxelsize[2])])

        ;RSpresc_trans = transform_volume(RSpresc, translate = [(x[i]/voxelsize[0]), (y[j]/voxelsize[1]), (z[k]/voxelsize[2])])
        for l = 0, n_elements(shrinking) - 1 do begin
          clock = TIC()
          ;print, round(x[i]/voxelsize[0]), round(y[j]/voxelsize[1]), round(z[k]/voxelsize[2])
          

  
          QFnTCP_dpbn_shrunk = shrink_volume2(p_dpbn_trans, ph_dpbn_trans, voxelsize, RSpresc, gtv_RS_ind, idl_presc, patient, petmatrix, ph_dose, p_dose, mmshrink = shrinking[l])
          
          store_matrix[0, counter] = ptr_new(abs(x[i] + y[j] + z[k])/3.)
          store_matrix[1, counter] = ptr_new(shrinking[l])
          store_matrix[2, counter] = ptr_new(*(QFnTCP_dpbn_shrunk[0]))   ;ph_dpbn_QF
          store_matrix[3, counter] = ptr_new(*(QFnTCP_dpbn_shrunk[1]))   ;p_dpbn_QF
          store_matrix[4, counter] = ptr_new(*(QFnTCP_dpbn_shrunk[2]))   ;ph_dpbn_TCP
          store_matrix[5, counter] = ptr_new(*(QFnTCP_dpbn_shrunk[3]))  ;p_dpbn_TCP
          
          ptr_free, QFnTCP_dpbn_shrunk
          counter = counter + 1
          
          time = TOC(clock)
            
          timetaker = (timetaker + time)
          averagetime = timetaker/float(counter)  
          curPerc = float(counter)/(n_elements(x)^3*n_elements(shrinking))
          
          print, 'Estimated time left: ',  time2string(((1.0 - curPerc) / (curPerc-prevPerc) * averagetime)) , '. Mean dt = ', averagetime
          
          ;print, float(counter)/(n_elements(x)^3*n_elements(shrinking))
          prevPerc = curPerc
          
  ;        ;QFs = dose_difference_dpbn(idl_presc, ph_dpbn_trans, p_dpbn_trans, RSpresc, gtv_pet_ind, voxelsize)
  ;        ;TCPs = tcpmodel(ph_dose, ph_dpbn_trans, p_dose, p_dpbn_trans, RSpresc, petmatrix, voxelsize, 34.0, gtv_pet_ind, Constant = 22974.8)
  ;        
  ;        ph_dpbn_QF[i, j, k] = (*(QFs[0]))[1]
  ;        p_dpbn_QF[i, j, k] = (*(QFs[0]))[2]
  ;        ph_dpbn_TCP[i, j, k] = (*(TCPs[1]))
  ;        p_dpbn_TCP[i, j, k] = (*(TCPs[3]))
        endfor
      endfor
    endfor
  endfor
  TOC
  return, store_matrix
end