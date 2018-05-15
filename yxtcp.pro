function yxtcp, pet_matrix, dose_presc, dose_deliver, x, y, z

  tcp_i = pet_matrix
  alphaM = pet_matrix
  ;alpha = pet_matrix
  alpha = 0.01
  V = x/100.0 * y/100.0 * z/100.0
  
  for i = 0, n_elements(dose_presc)-1 do begin
    alphaM[i] = alpha * (1 + dose_presc[i]/(10.0))
    ;tcp_i[i] = exp(-pet_matrix[i] * V * exp( - alphaM[i] * dose_deliver[i] + gamma[i] * deltaT))
    ;antar gamma[i] = 0
    tcp_i[i] = exp(-pet_matrix[i] * V * exp( - alphaM[i] * dose_deliver[i]))
  endfor
  TCP = total(tcp_i)
  print, "TCP = ", TCP
  stop
end