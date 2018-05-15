function DoseofPet, petint, dose, gtv_pet_ind

  sorted = sort(dose[gtv_pet_ind])
  
  plt = plot((petint[gtv_pet_ind])[sorted], (dose[gtv_pet_ind])[sorted])
end