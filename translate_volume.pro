function translate_volume, p_dose, p_dpbn_dose, ph_dose, ph_dpbn_dose, voxelsize, RSpresc, gtv_pet_ind, idl_presc, patient, petmatrix
  
  
  x = [-0.3, -0.2, -0.1, 0, 0.1, 0.2,  0.3]   ;cm
  ;x = [-0.3, 0,  0.3]   ;cm
  y = x
  z = x
  
  z_index = 0;round(n_elements(x)/2. + 0.4)
  
  p_QF = fltarr(n_elements(x), n_elements(y), n_elements(z))
  p_dpbn_QF = p_QF
  ph_QF = p_QF
  ph_dpbn_QF = p_QF
  p_dpbn_TCP = p_QF
  ph_dpbn_TCP = p_QF
  
  p_ones = p_dpbn_dose
  p_ones[gtv_pet_ind] = 1
  p_ones[where(p_ones ne 1)] = 0
  
;  ;Test for center of mass after translation 
;  voxel_mc = make_array(3, n_elements(gtv_pet_ind))
;  for i = 0, n_elements(gtv_pet_ind) - 1 do begin
;    voxel_mc[0:2, i] = array_indices(p_dpbn_dose, gtv_pet_ind[i])
;  endfor
;
;  orig_GTV_MC = round(total(voxel_mc, 2)/n_elements(gtv_pet_ind))
;  
;  p_ones[orig_GTV_MC[0], orig_GTV_MC[1], orig_GTV_MC[2]] = 5
  
  ;tic, /PROFILER
  for i = 0, n_elements(x) - 1 do begin
    for j = 0, n_elements(x) - 1 do begin
      for k = 0, n_elements(x) - 1 do begin
        print, round(x[i]/voxelsize[0]), round(y[j]/voxelsize[1]), round(z[k]/voxelsize[2])
        ;p_trans = transform_volume(p_dose, translate = [x[i]/voxelsize[0], y[j]/voxelsize[1], z[k]/voxelsize[2]])
        ;p_dpbn_trans =  transform_volume(p_dpbn_dose, translate = [-round(x[i]/voxelsize[0]), -round(y[j]/voxelsize[1]), -round(z[k]/voxelsize[2])])
        
        ;p_dpbn_trans =  shift(p_dpbn_dose, [round(x[i]/voxelsize[0]), round(y[j]/voxelsize[1]), round(z[k]/voxelsize[2])])
        ;ph_dpbn_trans = shift(p_dpbn_dose, [-round(x[i]/voxelsize[0]), -round(y[j]/voxelsize[1]), -round(z[k]/voxelsize[2])]) ; OBS! Denne er helt feil, men kun med som eksempel!
        ;p_dpbn_trans =  shift(p_dpbn_dose, [(x[i]/voxelsize[0]), (y[j]/voxelsize[1]), (z[k]/voxelsize[2])])
        ;ph_dpbn_trans = shift(p_dpbn_dose, [(x[i]/voxelsize[0]), (y[j]/voxelsize[1]), (z[k]/voxelsize[2])])
        
        ;OBS! CHECK out the translate difference. Why does one have - and the other not?
        ph_dpbn_trans = transform_volume(ph_dpbn_dose, translate = [x[i]/voxelsize[0], y[j]/voxelsize[1], z[k]/voxelsize[2]])
        
        ;Satt inn denne istedenfor den nedenfor 11.04
        p_dpbn_trans =  transform_volume(p_dpbn_dose, translate = [(x[i]/voxelsize[0]), (y[j]/voxelsize[1]), (z[k]/voxelsize[2])])


         ;Opddaget denne idag 11.04, det virker som om jeg har frem til nå flyttet ph og p i stikk motsatt retning. Weird! Prøvde ut begge, hadde nesten ingenting å si på QF, men holder meg til samme forflytning fra nå av
;        p_dpbn_trans =  transform_volume(p_dpbn_dose, translate = [-(x[i]/voxelsize[0]), -(y[j]/voxelsize[1]), -(z[k]/voxelsize[2])])

;        p_ones_trans = transform_volume(p_ones, translate = [-(x[i]/voxelsize[0]), -(y[j]/voxelsize[1]), -(z[k]/voxelsize[2])])
        
;        ;Test for center of mass after translation 
;        ones_mc = make_array(3, n_elements(where(p_ones_trans gt 0)))
;        for l = 0, n_elements(where(p_ones_trans gt 0)) - 1 do begin
;          ones_mc[0:2, l] = array_indices(p_ones_trans, (where(p_ones_trans gt 0))[l])
;        endfor
;        
;        ones_GTV_MC = round(total(ones_mc, 2)/n_elements(where(p_ones_trans gt 0)))
        
        
        ;ph_trans = transform_volume(ph_dose, translate = [x[i]/voxelsize[0], y[j]/voxelsize[1], z[k]/voxelsize[2]])
        ;ph_dpbn_trans = transform_volume(ph_dpbn_dose, translate = [-round(x[i]/voxelsize[0]), -round(y[j]/voxelsize[1]), -round(z[k]/voxelsize[2])])
        ;ph_dpbn_trans = shift(ph_dpbn_dose, [-round(x[i]/voxelsize[0]), -round(y[j]/voxelsize[1]), -round(z[k]/voxelsize[2])]) ; Denne er rett!
        QFs = dose_difference_dpbn(idl_presc, ph_dpbn_trans, p_dpbn_trans, RSpresc, gtv_pet_ind, voxelsize)
        TCPs = tcpmodel(ph_dose, ph_dpbn_trans, p_dose, p_dpbn_trans, RSpresc, petmatrix, voxelsize, 34.0, gtv_pet_ind, Constant = 22974.8)
        ph_dpbn_QF[i, j, k] = (*(QFs[0]))[1] 
        p_dpbn_QF[i, j, k] = (*(QFs[0]))[2]
        ph_dpbn_TCP[i, j, k] = (*(TCPs[1]))
        p_dpbn_TCP[i, j, k] = (*(TCPs[3]))
      endfor
    endfor
    ;print, float(i)/n_elements(x)
  endfor
  ;toc
  
  ;Oppdagelser og teorier:
  ; Shift og translate forskyver i stikk motsatt retning.
  ; Shift er avhengig av round og dermed blir det veldig lite forskjell da alt må gå opp i tregangen for x og y og togangen for z. Tror at shift gjør round selv dersom jeg ikke gjør
  ; det mens t3d ikke trenger slike føringer. Hvorfor aner jeg ikke.
  
;  ct = COLORTABLE(39, /reverse)
;  con1 = contour(p_dpbn_QF[*,*, z_index], x, y, title = (patient + ' Proton QF, z offset = ' + strcompress(string(z[z_index], format = '(F5.2)')) + ' cm'), RGB_TABLE=ct, n_levels = 12, $
;                  ytitle = 'y offset [cm]', xtitle = 'x offset [cm]')  ; 2d konturplot
;  ax1 = con1.axes
;  ax1[0].tickfont_size = 11
;  ax1[1].tickfont_size = 11
;  
;  con1.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_pdpbnZ_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;  
;  con2 = contour(reform(p_dpbn_QF[z_index, *, *]), y, z, title = (patient + ' Proton QF, x offset = ' + strcompress(string(z[z_index], format = '(F5.2)')) + ' cm'), RGB_TABLE=ct, n_levels = 12, $
;    ytitle = 'z offset [cm]', xtitle = 'y offset [cm]'); 2d konturplot langs andre akser enn z-aksen
;  
;  ax2 = con2.axes
;  ax2[0].tickfont_size = 11
;  ax2[1].tickfont_size = 11
;  
;  con2.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_pdpbnX_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;  
;  con3 = contour(reform(p_dpbn_QF[*, z_index, *]), x, z, title = (patient + ' Proton QF, y offset = ' + strcompress(string(z[z_index], format = '(F5.2)')) + ' cm'), RGB_TABLE=ct, n_levels = 12, $
;    ytitle = 'z offset [cm]', xtitle = 'x offset [cm]')
;    
;  ax3 = con3.axes
;  ax3[0].tickfont_size = 11
;  ax3[1].tickfont_size = 11
;
;  con3.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_pdpbnY_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;  
;  con4 = contour(ph_dpbn_QF[*,*,z_index], x, y, title = (patient + ' Photon QF, z offset = ' + strcompress(string(z[z_index], format = '(F5.2)')) + ' cm'), RGB_TABLE=ct, n_levels = 12, $
;    ytitle = 'y offset [cm]', xtitle = 'x offset [cm]')  ; 2d konturplot
;    
;  ax4 = con4.axes
;  ax4[0].tickfont_size = 11
;  ax4[1].tickfont_size = 11
;  
;  con4.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_phdpbnZ_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;  
;  con5 = contour(reform(ph_dpbn_QF[z_index, *, *]), y, z, title = (patient + ' Photon QF, x offset = ' + strcompress(string(z[z_index], format = '(F5.2)')) + ' cm'), RGB_TABLE=ct, n_levels = 12, $
;    ytitle = 'z offset [cm]', xtitle = 'y offset [cm]'); 2d konturplot langs andre akser enn z-aksen
;    
;  ax5 = con5.axes
;  ax5[0].tickfont_size = 11
;  ax5[1].tickfont_size = 11
;  
;  con5.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_phdpbnX_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;  
;  con6 = contour(reform(ph_dpbn_QF[*,z_index, *]), x, z, title = (patient + ' Photon QF, y offset = ' + strcompress(string(z[z_index], format = '(F5.2)')) + ' cm'), RGB_TABLE=ct, n_levels = 12, $
;    ytitle = 'y offset [cm]', xtitle = 'x offset [cm]')
;    
;  ax6 = con6.axes
;  ax6[0].tickfont_size = 11
;  ax6[1].tickfont_size = 11
;  
;  con6.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourQF_phdpbnY_" + strcompress(string(n_elements(x)), /remove_all) + "index_" + strcompress(string(z_index)) + ".png")
;  
;  con1.Close
;  con2.Close
;  con3.Close
;  con4.Close
;  con5.Close
;  con6.Close
  
  con7 = contour(p_dpbn_TCP[*,*, round(n_elements(x)/2. + 0.4)], x, y, title = (patient + ' p TCP z'), RGB_TABLE=ct, n_levels = 12)  ; 2d konturplot
  con7.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourTCP_pdpbnZ_" + strcompress(string(n_elements(x)), /remove_all) + ".png")

;  con8 = contour(reform(p_dpbn_TCP[round(n_elements(x)/2. + 0.4), *, *]), y, z, title = (patient + ' p TCP x'), RGB_TABLE=ct, n_levels = 12); 2d konturplot langs andre akser enn z-aksen
;  con8.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourTCP_pdpbnX_" + strcompress(string(n_elements(x)), /remove_all) + ".png")
;
;  con9 = contour(reform(p_dpbn_TCP[*, round(n_elements(x)/2. + 0.4), *]), x, z, title = (patient + ' p TCP y'), RGB_TABLE=ct, n_levels = 12)
;  con9.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourTCP_pdpbnY_" + strcompress(string(n_elements(x)), /remove_all) + ".png")
;
;  con10 = contour(ph_dpbn_TCP[*,*,round(n_elements(x)/2. + 0.4)], x, y, title = (patient + ' ph TCP z'), RGB_TABLE=ct, n_levels = 12)  ; 2d konturplot
;  con10.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourTCP_phdpbnZ_" + strcompress(string(n_elements(x)), /remove_all) + ".png")
;
;  con11 = contour(reform(ph_dpbn_TCP[round(n_elements(x)/2. + 0.4), *, *]), y, z, title = (patient + ' ph TCP x'), RGB_TABLE=ct, n_levels = 12); 2d konturplot langs andre akser enn z-aksen
;  con11.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourTCP_phdpbnX_" + strcompress(string(n_elements(x)), /remove_all) + ".png")
;
;  con12 = contour(reform(ph_dpbn_TCP[*,round(n_elements(x)/2. + 0.4), *]), x, z, title = (patient + ' ph TCP y'), RGB_TABLE=ct, n_levels = 12)
;  con12.save, ("C:\Users\Eirik\Dropbox\Universitet\Master\Figurer\" + strcompress(patient, /remove_all) + "_contourTCP_phdpbnY_" + strcompress(string(n_elements(x)), /remove_all) + ".png")
  
  ;plot(x, p_dpbn_QF[*, round(n_elements(x)/2. + 0.4), round(n_elements(x)/2. + 0.4)]); 1d plot av QF langs x-aksen.
  
end