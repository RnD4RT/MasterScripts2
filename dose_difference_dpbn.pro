function dose_difference_dpbn, d, d_rob_ph_dpbn, d_rob_p_dpbn, dose_presc, gtv_pet_ind, voxel_size
  N_T = n_elements(gtv_pet_ind)

  Q_i = d[gtv_pet_ind]/dose_presc[gtv_pet_ind]
  Q_i_rob_ph_dpbn = d_rob_ph_dpbn[gtv_pet_ind]/dose_presc[gtv_pet_ind]
  Q_i_rob_p_dpbn = d_rob_p_dpbn[gtv_pet_ind]/dose_presc[gtv_pet_ind]

  QF = 1.0/N_T * total(abs(Q_i - 1))
  QF_rob_ph_dpbn = 1.0/N_T * total(abs(Q_i_rob_ph_dpbn - 1))
  QF_rob_p_dpbn = 1.0/N_T * total(abs(Q_i_rob_p_dpbn - 1))

  store_matrix = ptrarr(1)
  store_matrix[0] = ptr_new([QF, QF_rob_ph_dpbn, QF_rob_p_dpbn])

  return, store_matrix
end