function shrink_volume,p_dpbn_dose, ph_dpbn_dose, voxelsize, RSpresc, gtv_pet_ind, idl_presc, patient, petmatrix  
  x = findgen(1, start = 0.8, increment = 0.02)   ;cm
  ;x = [-0.3, 0,  0.3]   ;cm
  y = x
  z = x

  z_index = 0;round(n_elements(x)/2. + 0.4)

  s = Size(p_dpbn_dose)
  sx=s[1] & sy=s[2] & sz=s[3]
  st = sx*sy*sz
  center_dosemap=[(sx-1)/2.0,(sy-1)/2.0,(sz-1)/2.0]
  
  voxel_mc = make_array(3, n_elements(gtv_pet_ind))
  for i = 0, n_elements(gtv_pet_ind) - 1 do begin
    voxel_mc[0:2, i] = array_indices(p_dpbn_dose, gtv_pet_ind[i]); - center_dosemap
  endfor
  
  center_rotation = round(total(voxel_mc, 2)/n_elements(gtv_pet_ind))
  
  p_ones = p_dpbn_dose
  p_ones[gtv_pet_ind] = 1
  p_ones[where(p_ones ne 1)] = 0
  
  indexes  = array_indices(p_ones, where(p_ones eq 1))
  
  
  box_factor = 10
  ;box_size = max([max(indexes[0, *, *]) - min(indexes[0, *, *]), max(indexes[1, *, *]) - min(indexes[1, *, *]), max(indexes[2, *, *]) - min(indexes[2, *, *]))]
  box_size = max([max(indexes[0, *, *]) - center_rotation[0], center_rotation[0] - min(indexes[0, *, *]), max(indexes[1, *, *]) - center_rotation[1], center_rotation[1] - min(indexes[1, *, *]), max(indexes[2, *, *]) - center_rotation[2], center_rotation[2] - min(indexes[2, *, *])])
  scale_factor = 0.8
  
  p_ones_test = p_ones[center_rotation[0] - (box_size + box_factor): center_rotation[0] + (box_size + box_factor), center_rotation[1] - (box_size + box_factor):center_rotation[1] + (box_size + box_factor), center_rotation[2] - (box_size + box_factor):center_rotation[2] + (box_size + box_factor)]
  ;p_ones_test = p_ones[79 - box_factor:95 + box_factor, 24 - box_factor:36 + box_factor, 97 - box_factor:127 + box_factor]
  s = Size(p_ones_test)
  sx=s[1] & sy=s[2] & sz=s[3]
  st = sx*sy*sz
  center_onestest=[(sx-1)/2.0,(sy-1)/2.0,(sz-1)/2.0]
  
  x = findgen(100, start = 1, increment = 0.01)
  scl_x = x
  scl_y = scl_x
  scl_z = scl_x
  
  p_ones_test[(sx-1)/2.0,(sy-1)/2.0,(sz-1)/2.0] = 50
  
  ;imorig = image(rebin(p_ones_test[*, *, (sz-1)/2.0], 10*51, 10*51), title = 'Original')
  
  for i = 0, n_elements(x)-1 do begin
    scale_factor = x[i]
    scl = transform_volume(p_ones_test, scale = [scale_factor, scale_factor, scale_factor])
    print, array_indices(scl, where(scl gt (max(scl) - 0.25)))
    scl_x[i] = (array_indices(scl, where(scl gt (max(scl) - 0.25))))[0]
    scl_y[i] = (array_indices(scl, where(scl gt (max(scl) - 0.25))))[1]
    scl_z[i] = (array_indices(scl, where(scl gt (max(scl) - 0.25))))[2]
    ;Im1 = image(rebin(scl[*, *, scl_y[i]], 10*51, 10*51), title = strcompress(string(scl_x[i], format = '(F5.2)')))
  endfor
  ;p_ones_test[(sx-1)/2.0,(sy-1)/2.0,(sz-1)/2.0] = 5
  ;scl = transform_volume(p_ones_test, scale = [scale_factor, scale_factor, scale_factor])
  
  ;print, array_indices(scl, where(scl gt (max(scl) - 0.25)))
  
 stop
 pl1 = plot(x, scl_x)
 
 
 ax = pl1.axes
 
 ax[0].title = 'Scale Factor'
 
 ax[0].text_orientation = 45
 ax[1].text_orientation = 1
 
 pl2 = plot(x, scl_y, '-r', /OVERPLOT)
 pl3 = plot(x, scl_z, '-b', /OVERPLOT)
  stop  


  p_dpbn_QF = fltarr(n_elements(x))
  ph_dpbn_QF = p_dpbn_QF
  
  tic, /PROFILER
  for i = 0, n_elements(x) - 1 do begin
    print, i, [x[i], y[i], z[i]]
    ph_dpbn_trans = transform_volume(ph_dpbn_dose, scale = [x[i], y[i], z[i]], centre_rotation = center_rotation)
    p_dpbn_trans =  transform_volume(p_dpbn_dose, scale = [x[i], y[i], z[i]], centre_rotation = center_rotation)
    
    QFs = dose_difference_dpbn(idl_presc, ph_dpbn_trans, p_dpbn_trans, RSpresc, gtv_pet_ind, voxelsize)
    ph_dpbn_QF[i] = (*(QFs[0]))[1]
    p_dpbn_QF[i] = (*(QFs[0]))[2]
  endfor

  toc
  
  stop
  
;  pl1 = plot(x, p_dpbn_QF, title = (Patient + 'p QF'))
;  filename = "C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_shrinkQF_pdpbn_n_" + strcompress(string(n_elements(x)), /remove_all) + ".png"
;  pl1.save, filename
; 
;  pl2 = plot(x, ph_dpbn_QF, title = (Patient + 'ph QF'))
;  filename = "C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_shrinkQF_phdpbn_n_" + strcompress(string(n_elements(x)), /remove_all) + ".png"
;  pl1.save, filename
  
  p_dpbn_dose[center_rotation] = min(p_dpbn_dose)
  p_dpbn_trans[center_rotation] = min(p_dpbn_dose)
  
  pl3 = image(p_dpbn_dose[*, *, 112], title = (Patient + 'p QF'))
  pl4 = image(p_dpbn_trans[*, *, 112], title = (Patient + 'ph QF'))
  stop
  
  pl1.close
  pl2.close
  ;WRITE_PNG, filename, TVRD(/TRUE)
  
  
  ;pl1.save, "C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_shrinkQF_pdpbn_n_" + strcompress(string(n_elements(x)), /remove_all) + ".jpg", BORDER=10, RESOLUTION=300
;  ct = COLORTABLE(39, /reverse)
;  con1 = contour(p_dpbn_QF[*,*, z_index], x, y, title = (patient + ' p QF z'), RGB_TABLE=ct, n_levels = 12)  ; 2d konturplot
;  con1.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_pdpbnZ_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;
;  con2 = contour(reform(p_dpbn_QF[z_index, *, *]), y, z, title = (patient + ' p QF x'), RGB_TABLE=ct, n_levels = 12); 2d konturplot langs andre akser enn z-aksen
;  con2.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_pdpbnX_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;
;  con3 = contour(reform(p_dpbn_QF[*, z_index, *]), x, z, title = (patient + ' p QF y'), RGB_TABLE=ct, n_levels = 12)
;  con3.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_pdpbnY_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;
;  con4 = contour(ph_dpbn_QF[*,*,z_index], x, y, title = (patient + ' ph QF z'), RGB_TABLE=ct, n_levels = 12)  ; 2d konturplot
;  con4.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_phdpbnZ_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;
;  con5 = contour(reform(ph_dpbn_QF[z_index, *, *]), y, z, title = (patient + ' ph QF x'), RGB_TABLE=ct, n_levels = 12); 2d konturplot langs andre akser enn z-aksen
;  con5.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_phdpbnX_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;
;  con6 = contour(reform(ph_dpbn_QF[*,z_index, *]), x, z, title = (patient + ' ph QF y'), RGB_TABLE=ct, n_levels = 12)
;  con6.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_phdpbnY_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
end