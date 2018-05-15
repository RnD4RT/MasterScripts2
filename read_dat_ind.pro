function read_dat_ind, patient, ROIname
  
  path = 'C:\Users\Eirik\Dropbox\Universitet\Master\'
  filename = path + 'Indices\' + strcompress(patient, /remove_all) + '\' + ROIname + '.txt'

  OPENR, lun, filename, /GET_LUN
  ; Read one line at a time, saving the result into array
  array = ''
  line = ''
  WHILE NOT EOF(lun) DO BEGIN & $
    READF, lun, line & $
    array = [array, line] & $
  ENDWHILE
  ; Close the file and free the file unit
  FREE_LUN, lun

  indices = indgen(array[1], start = 7, increment = 2)
  strarray = array[indices]
  
  int_arr = make_array(array[1], /ulong, value = 0)
  
  for i = 0, array[1] - 1 do begin
    int_arr[i] = str2num(strarray[i])
  endfor
  
  if int_arr[-1] eq array[3] then print, 'Woho!'
  

  free_lun, lun
  
  return, int_arr
  
end