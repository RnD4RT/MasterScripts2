function sort_one, list1

  var = list1[sort(list1)]
  
  new_list = list(var[0])
  for i = 1, n_elements(var) - 1 do begin
    if ((var[i] gt var[i - 1] + 0.005) || (var[i] lt var[i - 1] - 0.005)) then begin
      new_list.add, var[i]
    endif
  endfor
  
  return, new_list
end