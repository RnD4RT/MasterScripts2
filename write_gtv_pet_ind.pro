function write_gtv_pet_ind, filename, gtv_pet_ind
  openw, lun, filename, /GET_LUN

  number_of_ind = ulong(n_elements(gtv_pet_ind))
  gtv_pet_ind = ulong(gtv_pet_ind)

  writeu, lun, number_of_ind
  writeu, lun, gtv_pet_ind

  free_lun, lun
  return, 0
end