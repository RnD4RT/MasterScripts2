function my_little_plotter, avg_mov, shrink, avg_mov_elements, shrink_elements, tpQF, tphQF, tpTCP, tphTCP

  rgb_table = 34
  
  zoomf = 50
  
  pltpQF   = image(rebin(tpQF, zoomf*n_elements(avg_mov_elements), zoomf*n_elements(shrink_elements), /SAMPLE), RGB_Table = rgb_table, LAYOUT = [2, 2, 1], $
    title = 'Proton QF')
  cbpQF = colorbar(target = pltpQF)
  pltphQF  = image(rebin(tphQF, zoomf*n_elements(avg_mov_elements), zoomf*n_elements(shrink_elements), /SAMPLE), RGB_Table = rgb_table, LAYOUT = [2, 2, 2], /CURRENT, title = 'Photon QF')
  cbphQF = colorbar(target = pltphQF)
  pltpTCP  = image(rebin(tpTCP, zoomf*n_elements(avg_mov_elements), zoomf*n_elements(shrink_elements), /SAMPLE), RGB_Table = rgb_table, LAYOUT = [2, 2, 3], /CURRENT, title = 'Proton TCP')
  cbpTCP = colorbar(target = pltpTCP)
  pltphTCP = image(rebin(tphTCP, zoomf*n_elements(avg_mov_elements), zoomf*n_elements(shrink_elements), /SAMPLE), RGB_Table = rgb_table, LAYOUT = [2, 2, 4], /CURRENT, title = 'Photon TCP')
  cbphTCP = colorbar(target = pltphTCP)

end