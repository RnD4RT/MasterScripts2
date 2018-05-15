function write_dat, filename, d, total_voxels, nr_voxels, voxel_size, corner, fractions
  
  if ((filename eq "C:\Users\Eirik\Dropbox\Universitet\Master\dat_data\Patient 7_pet_matrix.dat") || (filename eq "C:\Users\Eirik\Dropbox\Universitet\Master\dat_data\Patient 9_pet_matrix.dat")) then begin
    nr_voxels[-1] = nr_voxels[-1] - 1    ;Hvorfor er det slik mon tro?
  endif
  
  openw, lun, filename, /GET_LUN
  
  nr_voxels = ulong(nr_voxels)
  voxel_size = double(voxel_size)
  corner = double(corner)
  fractions = ulong(fractions)
  total_voxels = ulong(total_voxels)
  
  writeu, lun, nr_voxels
  writeu, lun, voxel_size
  writeu, lun, corner
  writeu, lun, fractions
  writeu, lun, total_voxels
  
  d = double(d)
  
  writeu, lun, d
  
  free_lun, lun
  return, 0
end