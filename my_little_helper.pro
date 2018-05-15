function my_little_helper, avg_mov, shrink, pQF

  avg_mov_elements = sort_one(avg_mov)
  shrink_elements = sort_one(shrink)
  
  test = make_array(n_elements(avg_mov_elements), n_elements(shrink_elements))
  
  for j = 0, n_elements(shrink_elements) - 1 do begin
    for k = 0, n_elements(avg_mov_elements) - 1 do begin
      test[k, j] = mean(pQF[intersect(where(avg_mov eq avg_mov_elements[k]), where(shrink eq shrink_elements[j]))])
;      print, k, j
;      print, avg_mov_elements[k], shrink_elements[j]
;      print, pQF[intersect(where(avg_mov eq avg_mov_elements[k]), where(shrink eq shrink_elements[j]))]
;      print, test[k, j], stddev(pQF[intersect(where(avg_mov eq avg_mov_elements[k]), where(shrink eq shrink_elements[j]))])
    endfor
  endfor

  return, test  
end