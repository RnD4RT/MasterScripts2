function doseresponsecurve, presc, gtv_RS_ind, constant, voxelsize, petmatrix
  
  dose = findgen(80, start = 50, increment = 0.5)
  alpha = (-5)*alog(0.48)/(12.0)
  TCP = make_array(size = size(dose), value = 0)
  fractions = 34
  voxelvol = voxelsize[0]*voxelsize[1]*voxelsize[2]
  
  pet_matrix = petmatrix * constant
  
  for i = 0, n_elements(dose) - 1 do begin
    Array_68 = make_array(size = size(presc), value = dose[i])
    ;Array_68[where(Array_68 ne 68)] = 68.0
    
    TCPi_68 = exp( - pet_matrix[gtv_RS_ind]*voxelvol*exp(-(alpha*(1.0 + (Array_68[gtv_RS_ind]/fractions)/10.0))*(Array_68[gtv_RS_ind])))
    TCP[i] = product(TCPi_68)
  endfor
  
  ;plt1 = plot(dose, TCP)
  
  index_list = list()
  foreach element, TCP do begin
    if ((element gt 0.40) && (element lt 0.60)) then begin
      index_list.add, where(TCP eq element)
    endif
  endforeach
  
  if n_elements(index_list) eq 0 then begin
    print, 'No elements in list'
  endif
  
  if n_elements(index_list) eq 1 then begin
    down = TCP[index_list[0] - 1]
    up = TCP[index_list[0] + 1]
    
    slope = mean(TCP[index_list[0]] - down, TCP[index_list[0]] + up)/1.
  endif
  
  if n_elements(index_list) gt 1 then begin
    slope = 0
    for i = 0, n_elements(index_list) - 1 do begin
      slope = (TCP[index_list[i]] - TCP[index_list[i] - 1]) + slope
    endfor
    meanslope = slope/float(dose[index_list[-1]] - dose[index_list[0]])
    print, meanslope
  endif
  
   dicerolls = [fix(6*randomu(seed)), fix(6*randomu(seed)), fix(6*randomu(seed)), fix(6*randomu(seed))]
   dicerolls[where(dicerolls eq 0)] = 6
   dicerolls[where(dicerolls eq min(dicerolls))] = 0
   print, total(dicerolls)
  
  stop
  
end