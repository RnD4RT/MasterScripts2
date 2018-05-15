function shrink_volume2,p_dpbn_dose, ph_dpbn_dose, voxelsize, RSpresc, gtv_RS_ind, idl_presc, patient, petmatrix, ph_dose, p_dose, mmshrink = mmshrink
  
  if n_elements(mmshrink) eq 0 then mmshrink = 1
  
  gtv_pet_ind = gtv_RS_ind
  
  orig_RS_zeros = make_array(value = 0, size = Size(RSpresc))
  orig_ones_zeros = orig_RS_zeros
  orig_p_zeros = orig_RS_zeros
  orig_ph_zeros = orig_RS_zeros
  
  RS_ones = RSpresc
  RS_ones[gtv_RS_ind] = 1
  RS_ones[where(RS_ones ne 1)] = 0
  
;  print, n_elements(where(RS_ones eq 1)), n_elements(gtv_RS_ind)
  
  RS_mc = make_array(3, n_elements(gtv_RS_ind))
  for i = 0, n_elements(gtv_RS_ind) - 1 do begin
    RS_mc[0:2, i] = array_indices(RSpresc, gtv_RS_ind[i])
  endfor
  
  orig_RS_mc = round(total(RS_mc, 2)/n_elements(gtv_RS_ind))
  orig_RS_size = Size(RSpresc)
  
  max_distance = 0
  max_index = -1
  for i = 0, n_elements(RS_mc[0, *, *]) - 1 do begin
    if sqrt((RS_mc[0, i] - orig_RS_mc[0])^2 + ((RS_mc[1, i] - orig_RS_mc[1])^2) + (RS_mc[2, i] - orig_RS_mc[2])^2) gt max_distance then begin
      max_distance = sqrt((RS_mc[0, i] - orig_RS_mc[0])^2 + ((RS_mc[1, i] - orig_RS_mc[1])^2) + (RS_mc[2, i] - orig_RS_mc[2])^2)
      max_index = i
    endif
  endfor
  
  ;  d_axis1 = max(RS_mc[0, *, *]) - min(RS_mc[0, *, *])
  ;  d_axis2 = max(RS_mc[1, *, *]) - min(RS_mc[1, *, *])
  ;  d_axis3 = max(RS_mc[2, *, *]) - min(RS_mc[2, *, *])
  ;  d_axis = [d_axis1, d_axis2, d_axis3]
  radius = ceil(max_distance)

;  ;Test for å se om alt er innenfor radiusen
;  sphere = fltarr(2*radius, 2*radius, 2*radius)
;  sphere_ones = sphere
;  sphere[0: 2*radius-1, 0: 2*radius-1, 0: 2*radius-1] = p_dpbn_dose[orig_RS_mc[0] - radius:orig_RS_mc[0] + radius-1, orig_RS_mc[1] - radius:orig_RS_mc[1] + radius-1, orig_RS_mc[2] - radius:orig_RS_mc[2] + radius-1]
;  sphere_ones[0: 2*radius-1, 0: 2*radius-1, 0: 2*radius-1] = RS_ones[orig_RS_mc[0] - radius:orig_RS_mc[0] + radius-1, orig_RS_mc[1] - radius:orig_RS_mc[1] + radius-1, orig_RS_mc[2] - radius:orig_RS_mc[2] + radius-1]
;  for x = -radius, radius-1 do for y = -radius, radius-1 do for z = -radius, radius-1 do begin
;    if ceil(sqrt(x^2 + y^2 + z^2)) gt radius then begin
;      sphere[x + radius, y + radius, z + radius] = 0
;      sphere_ones[x + radius, y + radius, z + radius] = 0
;    endif
;  endfor
;
;  print, n_elements(gtv_RS_ind), n_elements(where(sphere_ones eq 1))

  
  scale_factor = (radius*voxelsize[0]*10 - mmshrink)^3/(radius*voxelsize[0]*10)^3
  
  

;  image(rebin(RSpresc[*, *, 112], 169*10, 99*10))
;  image(rebin(RS_ones[*, *, 112], 169*10, 99*10))
  
  print, scale_factor;, orig_RS_mc
  
  shrunk_RS_dose = congrid(RSpresc, scale_factor*orig_RS_size[1], scale_factor*orig_RS_size[2], scale_factor*orig_RS_size[3])
  shrunk_RS_ones = congrid(RS_ones, scale_factor*orig_RS_size[1], scale_factor*orig_RS_size[2], scale_factor*orig_RS_size[3])
  
;  shrunk_p = congrid(p_dpbn_dose, scale_factor*orig_RS_size[1], scale_factor*orig_RS_size[2], scale_factor*orig_RS_size[3])
;  shrunk_ph = congrid(ph_dpbn_dose, scale_factor*orig_RS_size[1], scale_factor*orig_RS_size[2], scale_factor*orig_RS_size[3])
  
  ;Find center of Ones-matrix
  ones_RS_mc = make_array(3, n_elements(where(shrunk_RS_ones gt 0 )))
  for i = 0, n_elements(where(shrunk_RS_ones gt 0)) - 1 do begin
    ones_RS_mc[0:2, i] = array_indices(shrunk_RS_ones, (where(shrunk_RS_ones gt 0))[i])
  endfor

  ones_RS_mc = round(total(ones_RS_mc, 2)/n_elements(where(shrunk_RS_ones gt 0)))
  
;  stop
  ;image(rebin(shrunk_RS_dose[*, *, 98], 148*10, 87*10))
  
  orig_ones_zeros[0:(size(shrunk_RS_dose))[1] - 1, 0:(size(shrunk_RS_dose))[2] - 1, 0:(size(shrunk_RS_dose))[3] - 1] = shrunk_RS_ones
  new_ones = shift(orig_ones_zeros, [abs(orig_RS_mc[0] - ones_RS_mc[0]), abs(orig_RS_mc[1] - ones_RS_mc[1]), abs(orig_RS_mc[2] - ones_RS_mc[2])])
  
  orig_RS_zeros[0:(size(shrunk_RS_dose))[1] - 1, 0:(size(shrunk_RS_dose))[2] - 1, 0:(size(shrunk_RS_dose))[3] - 1] = shrunk_RS_dose
  new_RS = shift(orig_RS_zeros, [abs(orig_RS_mc[0] - ones_RS_mc[0]), abs(orig_RS_mc[1] - ones_RS_mc[1]), abs(orig_RS_mc[2] - ones_RS_mc[2])])
  
;  orig_p_zeros[0:(size(shrunk_RS_dose))[1] - 1, 0:(size(shrunk_RS_dose))[2] - 1, 0:(size(shrunk_RS_dose))[3] - 1] = shrunk_p
;  new_p = shift(orig_p_zeros, [abs(orig_RS_mc[0] - ones_RS_mc[0]), abs(orig_RS_mc[1] - ones_RS_mc[1]), abs(orig_RS_mc[2] - ones_RS_mc[2])])
;  
;  orig_ph_zeros[0:(size(shrunk_RS_dose))[1] - 1, 0:(size(shrunk_RS_dose))[2] - 1, 0:(size(shrunk_RS_dose))[3] - 1] = shrunk_ph
;  new_ph = shift(orig_ph_zeros, [abs(orig_RS_mc[0] - ones_RS_mc[0]), abs(orig_RS_mc[1] - ones_RS_mc[1]), abs(orig_RS_mc[2] - ones_RS_mc[2])])
  
  
  ;Skal jeg bytte ut hele GTV eller bare der hvor new_ones = 1?
  
  
  ;p_dpbn_dose[where(new_ones eq 1)] = new_RS[where(new_ones eq 1)]
;  p_dpbn_dose[gtv_RS_ind] = new_RS[gtv_RS_ind] ;Husker ikke helt hvorfor jeg gjør dette og det blir rart når jeg skal translate matrixen i tillegg. Må ha en ny prat med Eirik
;  ph_dpbn_dose[gtv_RS_ind] = new_RS[gtv_RS_ind] ;Nå blir disse to helt identiske. Gir ikke mening.
  ;p_dpbn_dose[gtv_RS_ind] = new_p[gtv_RS_ind] ;Dette gir mer mening. Her har jeg flyttet på p dpbn dosekart og nå setter jeg inn de flytta verdiene i det originale dosekartet.
  ;ph_dpbn_dose[gtv_RS_ind] = new_ph[gtv_RS_ind]
  
  
  ;Måler mot new_RS
  
;  stop
  
  QFs = dose_difference_dpbn(idl_presc, ph_dpbn_dose, p_dpbn_dose, new_RS, where(new_ones eq 1), voxelsize)
  ;QFs2 = dose_difference_dpbn(idl_presc, ph_dpbn_dose, p_dpbn_dose, RSpresc, gtv_RS_ind, voxelsize)
  ;print, (petmatrix[gtv_RS_ind])[-1]
  TCPs = tcpmodel(ph_dose, ph_dpbn_dose, p_dose, p_dpbn_dose, new_RS, petmatrix, voxelsize, 34.0, where(new_ones eq 1), Constant = 22974.8)
  ;print, (petmatrix[gtv_RS_ind])[-1]
  ;TCPs2 = tcpmodel(ph_dose, ph_dpbn_dose, p_dose, p_dpbn_dose, RSpresc, petmatrix, voxelsize, 34.0, gtv_RS_ind, Constant = 22974.8)
  ;print, (petmatrix[gtv_RS_ind])[-1]
  
  p_dpbn_QF = (*(QFs[0]))[2]
  ph_dpbn_QF = (*(QFs[0]))[1]
  
  ;p_dpbn_QF2 = (*(QFs2[0]))[2]
  ;ph_dpbn_QF2 = (*(QFs2[0]))[1]
  
  p_dpbn_TCP = (*(TCPs[3]))
  ph_dpbn_TCP = (*(TCPs[1]))

  ;p_dpbn_TCP2 = (*(TCPs2[3]))
  ;ph_dpbn_QF2 = (*(TCPs2[1]))
  
  ;print, p_dpbn_QF, p_dpbn_QF2, p_dpbn_TCP, p_dpbn_TCP2
  ;print, ph_dpbn_QF, p_dpbn_QF, ph_dpbn_QF2, p_dpbn_QF2
  
  store_matrix = ptrarr(4)
  store_matrix[0] = ptr_new((*(QFs[0]))[1])    ;ph_dpbn_QF
  store_matrix[1] = ptr_new((*(QFs[0]))[2])    ;p_dpbn_QF
  store_matrix[2] = ptr_new((*(TCPs[1])))      ;ph_dpbn_TCP
  store_matrix[3] = ptr_new((*(TCPs[3])))      ;p_dpbn_TCP
  
  return, store_matrix
end
;;
;
;
;
;
;  orig_ph_zeros = make_array(value = 0, size = Size(ph_dpbn_dose))
;  ph_ones = ph_dpbn_dose
;  ph_ones[gtv_pet_ind] = 1
;  ph_ones[where(ph_ones ne 1)] = 0
;  
;  print, n_elements(where(ph_ones eq 1)), n_elements(gtv_pet_ind)
;  
;  orig_p_zeros = make_array(value = 0, size=Size(p_dpbn_dose))
;  p_ones = p_dpbn_dose
;  p_ones[gtv_pet_ind] = 1
;  p_ones[where(p_ones ne 1)] = 0
;  
;  ;Find original photon GTV MC:
;  ph_mc = make_array(3, n_elements(gtv_pet_ind))
;  for i = 0, n_elements(gtv_pet_ind) - 1 do begin
;    ph_mc[0:2, i] = array_indices(ph_dpbn_dose, gtv_pet_ind[i])
;  endfor
;
;  orig_ph_GTV_MC = round(total(ph_mc, 2)/n_elements(gtv_pet_ind))
;
;  orig_ph_size = Size(ph_dpbn_dose)
;  
;  ;Find original proton GTV MC:
;  p_mc = make_array(3, n_elements(gtv_pet_ind))
;  for i = 0, n_elements(gtv_pet_ind) - 1 do begin
;    p_mc[0:2, i] = array_indices(p_dpbn_dose, gtv_pet_ind[i])
;  endfor
;  
;  orig_p_GTV_MC = round(total(p_mc, 2)/n_elements(gtv_pet_ind))
;  
;  orig_p_size = Size(p_dpbn_dose)
;  
;  scale_factor = .9
;  
;  
;  
;  shrunk_p_dose = congrid(p_dpbn_dose, scale_factor*orig_p_size[1], scale_factor*orig_p_size[2], scale_factor*orig_p_size[3])
;  shrunk_p_ones = congrid(p_ones, scale_factor*orig_p_size[1], scale_factor*orig_p_size[2], scale_factor*orig_p_size[3])
;
;  shrunk_ph_dose = congrid(ph_dpbn_dose, scale_factor*orig_ph_size[1], scale_factor*orig_ph_size[2], scale_factor*orig_ph_size[3])
;  shrunk_ph_ones = congrid(ph_ones, scale_factor*orig_ph_size[1], scale_factor*orig_ph_size[2], scale_factor*orig_ph_size[3])
;  
;  ;Find center of Ones-matrix
;  ones_ph_mc = make_array(3, n_elements(where(shrunk_ph_ones gt 0)))
;  for i = 0, n_elements(where(shrunk_ph_ones gt 0)) - 1 do begin
;    ones_ph_mc[0:2, i] = array_indices(shrunk_ph_ones, (where(shrunk_ph_ones gt 0))[i])
;  endfor
;
;  ones_ph_GTV_MC = round(total(ones_ph_mc, 2)/n_elements(where(shrunk_ph_ones gt 0)))
;  
;  ;Find center of Ones-matrix
;  ones_p_mc = make_array(3, n_elements(where(shrunk_p_ones gt 0)))
;  for i = 0, n_elements(where(shrunk_p_ones gt 0)) - 1 do begin
;    ones_p_mc[0:2, i] = array_indices(shrunk_p_ones, (where(shrunk_p_ones gt 0))[i])
;  endfor
;
;  ones_p_GTV_MC = round(total(ones_p_mc, 2)/n_elements(where(shrunk_p_ones gt 0)))
;  
;  orig_ph_zeros[0:(size(shrunk_ph_dose))[1] - 1, 0:(size(shrunk_ph_dose))[2] - 1, 0:(size(shrunk_ph_dose))[3] - 1] = shrunk_ph_dose
;  new_ph = shift(orig_ph_zeros, [abs(orig_ph_GTV_MC[0] - ones_ph_GTV_MC[0]), abs(orig_ph_GTV_MC[1] - ones_ph_GTV_MC[1]), abs(orig_ph_GTV_MC[2] - ones_ph_GTV_MC[2])])
;  
;  orig_p_zeros[0:(size(shrunk_p_dose))[1] - 1, 0:(size(shrunk_p_dose))[2] - 1, 0:(size(shrunk_p_dose))[3] - 1] = shrunk_p_dose
;  new_p = shift(orig_p_zeros, [abs(orig_p_GTV_MC[0] - ones_p_GTV_MC[0]), abs(orig_p_GTV_MC[1] - ones_p_GTV_MC[1]), abs(orig_p_GTV_MC[2] - ones_p_GTV_MC[2])])
;  
;  ;Find new ph GTV MC:
;  new_ph_mc = make_array(3, n_elements(gtv_pet_ind))
;  for i = 0, n_elements(gtv_pet_ind) - 1 do begin
;    new_ph_mc[0:2, i] = array_indices(new_ph, gtv_pet_ind[i])
;  endfor
;
;  new_ph_GTV_MC = round(total(new_ph_mc, 2)/n_elements(gtv_pet_ind))
;  
;  ;Find new p GTV MC:
;  new_p_mc = make_array(3, n_elements(gtv_pet_ind))
;  for i = 0, n_elements(gtv_pet_ind) - 1 do begin
;    new_p_mc[0:2, i] = array_indices(new_p, gtv_pet_ind[i])
;  endfor
;
;  new_p_GTV_MC = round(total(new_p_mc, 2)/n_elements(gtv_pet_ind))
;  
;  QFs = dose_difference_dpbn(idl_presc, new_ph, new_p, RSpresc, gtv_pet_ind, voxelsize)
;  
;  p_dpbn_QF = (*(QFs[0]))[2]
;  ph_dpbn_QF = (*(QFs[0]))[1]
;  
;  stop
;end