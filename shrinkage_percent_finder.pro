function shrinkage_percent_finder, p_dose, p_dpbn_dose, ph_dose, ph_dpbn_dose, voxelsize, RSpresc, gtv_pet_ind, idl_presc, patient, petmatrix

  gtv_RS_ind = gtv_pet_ind

  x = [-0.1 ,0, 0.1, 0.2,  0.3]   ;cm
  ;x = [-0.3, 0,  0.3]   ;cm
  y = x
  z = x
  p_ones = p_dpbn_dose
  p_ones[gtv_pet_ind] = 1
  p_ones[where(p_ones ne 1)] = 0

  shrinking = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5]

  store_matrix = ptrarr(6, n_elements(x)^3*n_elements(shrinking))

  TIC, /PROFILER
  prevPerc = 0
  timetaker = 0
  ;CGprogressbar = Obj_new('progressbar', /Start, Percent = 0)
  counter = 0
  for i = 0, n_elements(shrinking) - 1 do begin
     QFnTCP_dpbn_shrunk = shrink_volume2(p_dpbn_dose, ph_dpbn_dose, voxelsize, RSpresc, gtv_RS_ind, idl_presc, patient, petmatrix, ph_dose, p_dose, mmshrink = shrinking[i])
  endfor
  TOC
end