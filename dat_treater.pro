function dat_treater, dp_matr, gtv_pet_ind, dp_matr_inv, pet_matrix


folder = "C:\Users\Eirik\Dropbox\Universitet\Master\"

dose_ph = read_dat(folder + "")
dose_ph_dpbn = read_dat(folder + "")
dose_p = read_dat(folder + "")
dose_p_dpbn = read_dat(folder + "")
dose_presc = read_dat(folder + "")

;Implement check to see if dose_presc == dose_presc from the IDL program
; Check TCP. Find k by using as many patients as possible and try to get 70 % survival
; Plot dose as a function of PETint


print, n_elements(dose_presc)
print, n_elements(dp_matr)
help, dose_presc
help, dp_matr

for i= 0, n_elements(dose_presc[gtv_pet_ind])-1 do begin
  print, (dose_presc[gtv_pet_ind])[i] - (dp_matr[gtv_pet_ind])[i]
endfor
  
return, 0
end