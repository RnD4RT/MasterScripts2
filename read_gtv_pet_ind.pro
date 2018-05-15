function read_gtv_pet_ind, filename
  openr, lun, filename, /GET_LUN
  
  nlengths = ulong(0)
  readu, lun, nlengths
  
  gtv_pet_ind = make_array(nlengths, /ulong)
  readu, lun, gtv_pet_ind
  
  free_lun, lun
  
  return, gtv_pet_ind
end