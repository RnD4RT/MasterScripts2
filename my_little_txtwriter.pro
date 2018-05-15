function my_little_txtwriter, avg_mov, shrink, avg_mov_elements, shrink_elements, tpQF, tphQF, tpTCP, tphTCP, patient
  
  ;openw, 4, 'C:\Users\Eirik\Dropbox\Universitet\Master\pet_matrix.txt'
  ;printf, 4, pet_matrix
  ;close, 4
  
  filename = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt\' + strcompress(patient, /remove_all) + "_translate_and_shrink_" + strcompress(string(n_elements(avg_mov_elements)), /remove_all) + "_" + strcompress(string(n_elements(shrink_elements)), /remove_all) + ".txt"
  
  openw, 1, filename
;  printf, 1, avg_mov
;  printf, 1, shrink
  printf, 1, avg_mov_elements
  printf, 1, '#'
  printf, 1, shrink_elements
  printf, 1, '#'
  printf, 1, tpQF
  printf, 1, '#'
  printf, 1, tphQF
  printf, 1, '#'
  printf, 1, tpTCP
  printf, 1, '#'
  printf, 1, tphTCP
  close, 1
  
end