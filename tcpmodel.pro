function tcpmodel, ph, ph_dpbn, p, p_dpbn, presc, petmatrix, voxelsize, fractions, gtv_pet_ind, Constant = constant
  
  if n_elements(Constant) eq 0 then constant = 1

  pet_matrix = petmatrix * constant
  alpha = (-5)*alog(0.48)/(12.0)
  voxelvol = voxelsize[0]*voxelsize[1]*voxelsize[2]
  
  Array_68 = presc
  Array_68[where(Array_68 ne 68)] = 68.0
  
  TCPi_presc = exp( - pet_matrix[gtv_pet_ind]*voxelvol*exp(-(alpha*(1.0 + (presc[gtv_pet_ind]/fractions)/10.0))*(presc[gtv_pet_ind])))
  TCPi_68 = exp( - pet_matrix[gtv_pet_ind]*voxelvol*exp(-(alpha*(1.0 + (Array_68[gtv_pet_ind]/fractions)/10.0))*(Array_68[gtv_pet_ind])))
  ;Skal den preskriberte dosen deles på fractions når den ikke har blitt gitt i fractions? Ja, tror det ettersom den skal være helt lik en gitt dose.
  
  
  
  TCPi_ph = exp(- pet_matrix[gtv_pet_ind] * voxelvol * exp(-(alpha * (1.0 + (ph[gtv_pet_ind]/fractions)/10.0)) * (ph[gtv_pet_ind])))
  TCPi_ph_dpbn = exp(- pet_matrix[gtv_pet_ind]*voxelvol*exp(-(alpha*(1.0 + (ph_dpbn[gtv_pet_ind]/fractions)/10.0))*(ph_dpbn[gtv_pet_ind])))
  TCPi_p = exp(- pet_matrix[gtv_pet_ind]*voxelvol*exp(-(alpha*(1.0 + (p[gtv_pet_ind]/fractions)/10.0))*(p[gtv_pet_ind])))
  TCPi_p_dpbn = exp(- pet_matrix[gtv_pet_ind]*voxelvol*exp(-(alpha*(1.0 + (p_dpbn[gtv_pet_ind]/fractions)/10.0))*(p_dpbn[gtv_pet_ind])))
  
;  print, min(p_dpbn[gtv_pet_ind]), mean(p_dpbn[gtv_pet_ind]), max(p_dpbn[gtv_pet_ind])
;  print, min(TCPi_p_dpbn[gtv_pet_ind]), mean(TCPi_p_dpbn[gtv_pet_ind]), max(TCPi_p_dpbn[gtv_pet_ind])
;  print, mean(pet_matrix[gtv_pet_ind])
  
  TCP_ph = product(TCPi_ph)
  TCP_ph_dpbn = product(TCPi_ph_dpbn)
  TCP_p = product(TCPi_p)
  TCP_p_dpbn = product(TCPi_p_dpbn)

  TCP_presc = product(TCPi_presc)
  TCP_68 = product(TCPi_68)

  store_matrix = ptrarr(6)
  
  store_matrix[0] = ptr_new(TCP_ph)
  store_matrix[1] = ptr_new(TCP_ph_dpbn)
  store_matrix[2] = ptr_new(TCP_p)
  store_matrix[3] = ptr_new(TCP_p_dpbn)
  store_matrix[4] = ptr_new(TCP_presc)
  store_matrix[5] = ptr_new(TCP_68)
  
  return, store_matrix
end
  