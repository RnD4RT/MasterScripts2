function plot_expander, mat, n, m = m
  ; Takes a matrix and expands each pixel to a n x n element.
  ; Can add a black border around each square with thickness m
  
  if n_elements(m) eq 0 then m = 0
  
  border_size = m
  
  shape = size(mat)
  new_mat = make_array(n * shape[1] + border_size * shape[1] + border_size, n * shape[2] + border_size * shape[2] + border_size, value = 0)
  
  for i = 0, shape[1] - 1 do begin
    for j = 0, shape[2] - 1 do begin
      new_mat[n*i + m*(i + 1):n*i + m*(i + 1) + ceil(n/2.), n*j + m*(j + 1):n*j + m*(j + 1) + ceil(n/2.)] = mat[i, j]
    endfor
  endfor
  
  
  stop
  return, new_mat
  
end