function read_dat, filename
  openr, lun, filename, /GET_LUN
  
  nr_voxels = make_array(3, 1, /ulong, value = 0)
  voxel_size = make_array(3, 1, /double, value = 0)
  corner = make_array(3, 1, /double, value = 0)
  fractions = ulong(0)
  total_voxels = ulong(0)
  
  
  readu, lun, nr_voxels
  readu, lun, voxel_size
  readu, lun, corner
  readu, lun, fractions
  readu, lun, total_voxels
  
  d = make_array(nr_voxels[0], nr_voxels[1], nr_voxels[2], /double, value=0)
  
  readu, lun, d
  
  free_lun, lun
  
  store_matrix = ptrarr(6)
  
  store_matrix[0] = ptr_new(d)
  store_matrix[1] = ptr_new(nr_voxels)
  store_matrix[2] = ptr_new(voxel_size)
  store_matrix[3] = ptr_new(corner)
  store_matrix[4] = ptr_new(fractions)
  store_matrix[5] = ptr_new(total_voxels)
  
  return, store_matrix
end