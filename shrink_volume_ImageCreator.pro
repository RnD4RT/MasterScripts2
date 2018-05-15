function shrink_volume_theThirds, p_dpbn_dose, ph_dpbn_dose, voxelsize, RSpresc, gtv_RS_ind, idl_presc, patient, petmatrix, ph_dose, p_dose, mm_switch, mmshrink = mmshrink

  if n_elements(mmshrink) eq 0 then mmshrink = 1

  gtv_pet_ind = gtv_RS_ind

  orig_RS_zeros = make_array(value = 0, size = Size(RSpresc))
  orig_ones_zeros = orig_RS_zeros
  orig_p_zeros = orig_RS_zeros
  orig_ph_zeros = orig_RS_zeros

  RS_ones = RSpresc
  RS_ones[gtv_RS_ind] = 1
  RS_ones[where(RS_ones ne 1)] = 0

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

  radius = ceil(max_distance)

    ;Test for å se om alt er innenfor radiusen
    sphere = fltarr(2*radius, 2*radius, 2*radius)
    sphere_ones = sphere
    sphere[0: 2*radius-1, 0: 2*radius-1, 0: 2*radius-1] = p_dpbn_dose[orig_RS_mc[0] - radius:orig_RS_mc[0] + radius-1, orig_RS_mc[1] - radius:orig_RS_mc[1] + radius-1, orig_RS_mc[2] - radius:orig_RS_mc[2] + radius-1]
    sphere_ones[0: 2*radius-1, 0: 2*radius-1, 0: 2*radius-1] = RS_ones[orig_RS_mc[0] - radius:orig_RS_mc[0] + radius-1, orig_RS_mc[1] - radius:orig_RS_mc[1] + radius-1, orig_RS_mc[2] - radius:orig_RS_mc[2] + radius-1]
    for x = -radius, radius-1 do for y = -radius, radius-1 do for z = -radius, radius-1 do begin
      if ceil(sqrt(x^2 + y^2 + z^2)) gt radius then begin
        sphere[x + radius, y + radius, z + radius] = 0
        sphere_ones[x + radius, y + radius, z + radius] = 0
      endif
    endfor
  
    print, n_elements(gtv_RS_ind), n_elements(where(sphere_ones eq 1))


  if mm_switch eq 1 then begin
    scale_factor = (radius*voxelsize[0]*10 - mmshrink)^3/(radius*voxelsize[0]*10)^3
  endif
  if mm_switch eq 0 then begin
    scale_factor = mmshrink
  endif
  



  ;  image(rebin(RSpresc[*, *, 112], 169*10, 99*10))
  ;  image(rebin(RS_ones[*, *, 112], 169*10, 99*10))

  print, scale_factor;, orig_RS_mc


  shrunk_RS_dose = congrid(RSpresc, scale_factor*orig_RS_size[1], scale_factor*orig_RS_size[2], scale_factor*orig_RS_size[3])
  shrunk_RS_ones = congrid(RS_ones, scale_factor*orig_RS_size[1], scale_factor*orig_RS_size[2], scale_factor*orig_RS_size[3])

  ;Find center of Ones-matrix
  ones_RS_mc = make_array(3, n_elements(where(shrunk_RS_ones gt 0 )))
  for i = 0, n_elements(where(shrunk_RS_ones gt 0)) - 1 do begin
    ones_RS_mc[0:2, i] = array_indices(shrunk_RS_ones, (where(shrunk_RS_ones gt 0))[i])
  endfor

  ones_RS_mc = round(total(ones_RS_mc, 2)/n_elements(where(shrunk_RS_ones gt 0)))

  ;  stop
  ;image(rebin(shrunk_RS_dose[*, *, 98], 148*10, 87*10))

  shrunk_RS_ones[where(shrunk_RS_ones lt 0.1)] = 0.5
  orig_ones_zeros[0:(size(shrunk_RS_dose))[1] - 1, 0:(size(shrunk_RS_dose))[2] - 1, 0:(size(shrunk_RS_dose))[3] - 1] = shrunk_RS_ones
  new_ones = shift(orig_ones_zeros, [abs(orig_RS_mc[0] - ones_RS_mc[0]), abs(orig_RS_mc[1] - ones_RS_mc[1]), abs(orig_RS_mc[2] - ones_RS_mc[2])])

  orig_RS_zeros[0:(size(shrunk_RS_dose))[1] - 1, 0:(size(shrunk_RS_dose))[2] - 1, 0:(size(shrunk_RS_dose))[3] - 1] = shrunk_RS_dose
  new_RS = shift(orig_RS_zeros, [abs(orig_RS_mc[0] - ones_RS_mc[0]), abs(orig_RS_mc[1] - ones_RS_mc[1]), abs(orig_RS_mc[2] - ones_RS_mc[2])])

  ;  stop

  QFs = dose_difference_dpbn(idl_presc, ph_dpbn_dose, p_dpbn_dose, new_RS, where(new_ones eq 1), voxelsize)
  TCPs = tcpmodel(ph_dose, ph_dpbn_dose, p_dose, p_dpbn_dose, new_RS, petmatrix, voxelsize, 34.0, where(new_ones eq 1), Constant = 22974.8)

  p_dpbn_QF = (*(QFs[0]))[2]
  ph_dpbn_QF = (*(QFs[0]))[1]

  p_dpbn_TCP = (*(TCPs[3]))
  ph_dpbn_TCP = (*(TCPs[1]))

  store_matrix = ptrarr(9)
  store_matrix[0] = ptr_new((*(QFs[0]))[1])    ;ph_dpbn_QF
  store_matrix[1] = ptr_new((*(QFs[0]))[2])    ;p_dpbn_QF
  store_matrix[2] = ptr_new((*(TCPs[1])))      ;ph_dpbn_TCP
  store_matrix[3] = ptr_new((*(TCPs[3])))      ;p_dpbn_TCP
  store_matrix[4] = ptr_new(RS_ones)
  store_matrix[5] = ptr_new(new_ones)
  store_matrix[6] = ptr_new(orig_RS_mc)
  store_matrix[7] = ptr_new(ones_RS_mc)
  store_matrix[8] = ptr_new(orig_ones_zeros)
  

  return, store_matrix
end

function ShrinkVolumeImage, patientlist, shrinkfactor, movement, mm_switch
  close, 1
  storer  = Dose_Reader(patientlist, 0)       ;NB! Set 1 for just tumor or 0 fro GTV
  shrink  = ptrarr(n_elements(patientlist))
  transpH = ptrarr(n_elements(patientlist))
  transp  = ptrarr(n_elements(patientlist))
  
  filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "ShrunkSnitt_for_" + strcompress(string(n_elements(patientlist)), /remove_all) + "_patients.txt"
  openw, 1, filename
  
  for i = 0, n_elements(patientlist) do begin
    patient = patientlist[i]
    
    phD = *(*storer[0])[i]
    phDP = *(*storer[1])[i]
    pD = *(*storer[2])[i]
    pDP = *(*storer[3])[i]
    presc = *(*storer[4])[i]
    gtv_RS_ind = *(*storer[5])[i]
    petmatrix = *(*storer[6])[i]
    voxelsize = *(*storer[7])[i]
    idl_presc = *(*storer[8])[i]
    
    mc = make_array(3, n_elements(gtv_RS_ind))
    for j = 0, n_elements(gtv_RS_ind) - 1 do begin
      mc[0:2, j] = array_indices(presc, gtv_RS_ind[j])
    endfor
    orig_RS_mc = round(total(mc, 2)/n_elements(gtv_RS_ind))
    
    RS_ones = presc
    RS_ones[gtv_RS_ind] = 1
    RS_ones[where(RS_ones ne 1)] = 0
    
    printf, 1, patientlist[i]
    printf, 1, 'Normal:'
    printf, 1, pDP[*, *, orig_RS_mc[-1]]
    
    transpH[i] = ptr_new(transform_volume(phDP, translate = [movement/voxelsize[0], movement/voxelsize[1], 0/voxelsize[2]]))
    transp[i]  = ptr_new(transform_volume(pDP, translate = [movement/voxelsize[0], movement/voxelsize[1], 0/voxelsize[2]]))
    shrink[i]  = ptr_new(shrink_volume_theThirds(*(transp[i]), *(transpH[i]), voxelsize, presc, gtv_RS_ind, idl_presc, patient, petmatrix, phD, pD, mm_switch, mmshrink = shrinkfactor))
    
    bab = ((*(*shrink[i])[4])[*, *, (*(*shrink[i])[6])[-1]])
    bab[where((*(*shrink[i])[4])[*, *, (*(*shrink[i])[6])[-1]] ne 1)] = 0.5
    
    printf, 1, 'Translated:'
    ;printf, 1, (*(transp[i]))[*, *, orig_RS_mc[-1]]
    ;printf, 1, (*(*shrink[i])[4])[*, *, (*(*shrink[i])[6])[-1]]   ;Translated
    printf, 1, bab                                                 ; Translated
    printf, 1, 'ShrunknShift:'
    printf, 1, (*(*shrink[i])[5])[*, *, (*(*shrink[i])[6])[-1]]   ;Shrunk, shifted and translated
    printf, 1, 'Shrunk:'
    printf, 1, (*(*shrink[i])[8])[*, *, (*(*shrink[i])[7])[-1]]   ;Shrunk and translated
    
    stop
  endfor
  
  close, 1
end


function ShrinkorTrans_doseFinder, patientlist, shrinkfactor, movement, mm_switch
  close, 1
  storer  = Dose_Reader(patientlist, 1)       ;NB! Set 1 for just tumor or 0 fro GTV
  shrink  = ptrarr(n_elements(patientlist))
  transpH = ptrarr(n_elements(patientlist))
  transp  = ptrarr(n_elements(patientlist))

  filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "ShrunkorTransDose_for_" + strcompress(string(n_elements(patientlist)), /remove_all) + '_shrink' + strcompress(string(shrinkfactor), /remove_all)+ '_trans' + strcompress(string(movement), /remove_all) +  "_patients.txt"
  openw, 1, filename

  for i = 0, n_elements(patientlist) do begin
    patient = patientlist[i]

    phD = *(*storer[0])[i]
    phDP = *(*storer[1])[i]
    pD = *(*storer[2])[i]
    pDP = *(*storer[3])[i]
    presc = *(*storer[4])[i]
    gtv_RS_ind = *(*storer[5])[i]
    petmatrix = *(*storer[6])[i]
    voxelsize = *(*storer[7])[i]
    idl_presc = *(*storer[8])[i]

    mc = make_array(3, n_elements(gtv_RS_ind))
    for j = 0, n_elements(gtv_RS_ind) - 1 do begin
      mc[0:2, j] = array_indices(presc, gtv_RS_ind[j])
    endfor
    orig_RS_mc = round(total(mc, 2)/n_elements(gtv_RS_ind))
    
    if movement gt 0 then begin
      transpH[i] = ptr_new(transform_volume(phDP, translate = [movement/voxelsize[0], movement/voxelsize[1], movement/voxelsize[2]]))
      transp[i]  = ptr_new(transform_volume(pDP, translate = [movement/voxelsize[0], movement/voxelsize[1], movement/voxelsize[2]]))
      shrink[i]  = ptr_new(shrink_volume_theThirds(*(transp[i]), *(transpH[i]), voxelsize, presc, gtv_RS_ind, idl_presc, patient, petmatrix, phD, pD, mm_switch, mmshrink = shrinkfactor))
    endif
    if movement eq 0 then begin
      shrink[i]  = ptr_new(shrink_volume_theThirds(pDP, phDP, voxelsize, presc, gtv_RS_ind, idl_presc, patient, petmatrix, phD, pD, mm_switch, mmshrink = shrinkfactor))
    endif


    printf, 1, patientlist[i]
    printf, 1, 'ProtonPri:'
    printf, 1, pDP[gtv_RS_ind]
    if movement gt 0 then begin
      printf, 1, 'ProtonPost:'
      printf, 1, (*(transp[i]))[where((*(*shrink[i])[5]) eq 1)]
      printf, 1, 'PhotonPost:'
      printf, 1, (*(transph[i]))[where((*(*shrink[i])[5]) eq 1)]
    endif
    if movement eq 0 then begin
      printf, 1, 'ProtonPost:'
      printf, 1, pDP[where((*(*shrink[i])[5]) eq 1)]
      printf, 1, 'PhotonPost:'
      printf, 1, phDP[where((*(*shrink[i])[5]) eq 1)]
    endif
    printf, 1, 'PhotonPri:'
    printf, 1, phDP[gtv_RS_ind]
    
  endfor

  close, 1
end

function ShrinkorTrans_QFnTCPFinder, patientlist, shrinkfactor, movement, mm_switch
  close, 1
  storer  = Dose_Reader(patientlist, 1)       ;NB! Set 1 for just tumor or 0 fro GTV
  shrink  = ptrarr(n_elements(patientlist))
  transpH = ptrarr(n_elements(patientlist))
  transp  = ptrarr(n_elements(patientlist))

  if mm_switch eq 1 then begin
    filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "ShrunkorTransQFnTCP_for_" + strcompress(string(n_elements(patientlist)), /remove_all) + '_shrink' + strcompress(string(shrinkfactor), /remove_all)+ '_trans' + strcompress(string(movement), /remove_all) + "mmswitchon_patients.txt"
  endif
  if mm_switch eq 0 then begin
    filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + "ShrunkorTransQFnTCP_for_" + strcompress(string(n_elements(patientlist)), /remove_all) + '_shrink' + strcompress(string(shrinkfactor), /remove_all)+ '_trans' + strcompress(string(movement), /remove_all) + "mmswitchoff_patients.txt"
  endif
  
  openw, 1, filename

  for i = 0, n_elements(patientlist)- 1 do begin
    patient = patientlist[i]

    phD = *(*storer[0])[i]
    phDP = *(*storer[1])[i]
    pD = *(*storer[2])[i]
    pDP = *(*storer[3])[i]
    presc = *(*storer[4])[i]
    gtv_RS_ind = *(*storer[5])[i]
    petmatrix = *(*storer[6])[i]
    voxelsize = *(*storer[7])[i]
    idl_presc = *(*storer[8])[i]

    mc = make_array(3, n_elements(gtv_RS_ind))
    for j = 0, n_elements(gtv_RS_ind) - 1 do begin
      mc[0:2, j] = array_indices(presc, gtv_RS_ind[j])
    endfor
    orig_RS_mc = round(total(mc, 2)/n_elements(gtv_RS_ind))

    if movement gt 0 then begin
      transpH[i] = ptr_new(transform_volume(phDP, translate = [movement/voxelsize[0], movement/voxelsize[1], movement/voxelsize[2]]))
      transp[i]  = ptr_new(transform_volume(pDP, translate = [movement/voxelsize[0], movement/voxelsize[1], movement/voxelsize[2]]))
      shrink[i]  = ptr_new(shrink_volume_theThirds(*(transp[i]), *(transpH[i]), voxelsize, presc, gtv_RS_ind, idl_presc, patient, petmatrix, phD, pD, mm_switch, mmshrink = shrinkfactor))
    endif
    if movement eq 0 then begin
      shrink[i]  = ptr_new(shrink_volume_theThirds(pDP, phDP, voxelsize, presc, gtv_RS_ind, idl_presc, patient, petmatrix, phD, pD, mm_switch, mmshrink = shrinkfactor))
    endif
  endfor
  
  pQF = fltarr(n_elements(patientlist))
  phQF = fltarr(n_elements(patientlist))
  pTCP = fltarr(n_elements(patientlist))
  phTCP = fltarr(n_elements(patientlist))
  
  for i = 0, n_elements(patientlist) - 1 do begin
    phQF[i]  = *(*shrink[i])[0]
    pQF[i]   = *(*shrink[i])[1]
    phTCP[i] = *(*shrink[i])[2]
    pTCP[i]  = *(*shrink[i])[3]
  endfor
  
  printf, 1, phQF
  printf, 1, pQF
  printf, 1, phTCP
  printf, 1, pTCP  
    
  close, 1

end