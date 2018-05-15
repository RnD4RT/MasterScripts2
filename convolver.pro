function convolver, bilder, gtv_pet_ind, dp_matr_nonconvol, switcher
;function convolver, bilder, gtv_pet_ind, d_high, d_low, dp_matr_nonconvol, p_low, p_high, set_base, dp_matr, x, y, z

;Setter inn noen verdier som jeg tror er like for alle pasientene. Obs! Viktig å sjekke!
x = 2.6661501
y = x
z = 2.0

d_low = 68.0
d_high = max(dp_matr_nonconvol)
p_low = 0.05
p_high = 1.0 - p_low
set_base = 1.0
dp_matr = dp_matr_nonconvol
dp_matr(*,*,*) = 0


; Lager først konvolusjonskjerne med "bredde" sigx, sigy og sigz i x,y- og z-retning. sig'ene kan i prinsippet være ulike
; Husk at vi opererer i voxelrom; du må bruke voxeloppløsning til å konvertere bredde (i mm) til antall voxler.
sigx=3.0/x
sigy=3.0/y
sigz=3.0/z
; Definer bredden på konvolusjonkjernen. Lar den være 3 standardavvik, kan muligens settes bredere.​
xk=round(3*sigx)
yk=round(3*sigy)
zk=round(3*sigz)
; Senter av konvolusjonkjernen
xm=(xk-1)/2
ym=(yk-1)/2
zm=(zk-1)/2
; Lag 3D Gauss-kjerne
kern=fltarr(xk, yk, zk)
for i=0, xk-1 do begin
  for j=0, yk-1 do begin
    for k=0, zk-1 do begin
      kern(i,j,k)=exp(-(float(i-xm)^2)/(sigx^2))*exp(-(float(j-ym)^2)/(sigy^2))*exp(-(float(k-zm)^2)/(sigz^2))
    endfor
  endfor
endfor

if switcher eq 1 or switcher eq 2 then begin
  ; Konvoluer 3D-bildeserien "bilder" med Gausskjernen:
  bilde_konv=convol(bilder, kern, /CENTER, /NORMALIZE, /EDGE_TRUNCATE)
  
  

  pet_matrix = bilde_konv ;Bruk bilder for å sjekke at alt fungerer

  n_tot=n_elements(gtv_pet_ind)
  max_pet=max(pet_matrix(gtv_pet_ind))
  min_pet=min(pet_matrix(gtv_pet_ind))

  ;fast andel som får maks og min
  n_low=p_low
  n_high=1.-p_high
  temp_gtv=pet_matrix(gtv_pet_ind)
  sort_gtv=temporary(temp_gtv(sort(temp_gtv)))

  ;setter alt utenfor gtv_pet til mindose pga mer robust mhp scoring av dose langs kanten av roi i doseplansyst
  if set_base then begin
    dp_matr(*,*,*)=d_low
    dp_matr(gtv_pet_ind)=0.0
  endif
  ;print, min_pet, max_pet, mean(pet_matrix(gtv_pet_ind))


  ;ser ut som om prank trenger prosent i tall fra 0 til 100, ikke 0 til 1.
  if p_low gt 0.0 then min_pet=prank(pet_matrix(gtv_pet_ind), p_low)   ;sort_gtv(round(n_tot*p_low)-1)
  if p_high lt 100.0 then max_pet=prank(pet_matrix(gtv_pet_ind), p_high)
  ;print, min_pet, max_pet, mean(pet_matrix(gtv_pet_ind))


  ;Finner D_high for YX
  rho_ref = max_pet

  N = n_elements(pet_matrix[gtv_pet_ind])
  n_tot = n_elements(gtv_pet_ind)

  p_high = 0.01*p_high
  p_low = 0.01*p_low ;RYDD OPP!

  n_low=p_low
  n_high=1.-p_high
  n_mean=p_high-p_low
  temp_gtv=pet_matrix(gtv_pet_ind)
  sort_gtv=temporary(temp_gtv(sort(temp_gtv)))

  d_avg = 76.0
  d_mean = d_avg

  n_tot = N

  dp_skal=total((sort_gtv(round(n_tot*p_low):round(n_tot*p_high)-1)-min_pet)/(max_pet-min_pet))/(n_tot*n_mean);litt feil med avrunding her, men neppe relevant mange tusen piksler totalt
  d_high_l=(d_mean+d_low*(dp_skal*n_mean-n_mean-n_low))/(dp_skal*n_mean+n_high)

  dp_matr(gtv_pet_ind)=d_low+(pet_matrix(gtv_pet_ind)-min_pet)*(d_high_l-d_low)/(max_pet-min_pet)

  for i=long(0), n_tot-1 do begin
    if dp_matr(gtv_pet_ind(i)) lt d_low then dp_matr(gtv_pet_ind(i))=d_low
    if dp_matr(gtv_pet_ind(i)) gt d_high_l then dp_matr(gtv_pet_ind(i))=d_high_l
  endfor
  
  print, 'QF (pet matrix origin, convolved vs non convolved) = ', 1.0/n_elements(gtv_pet_ind) * total(abs(1 - dp_matr(gtv_pet_ind)/dp_matr_nonconvol(gtv_pet_ind)))
endif

if switcher eq 0 or switcher eq 2 then begin
  ; Konvoluer 3D-bildeserien "bilder" med Gausskjernen:
  dp_matr=convol(dp_matr_nonconvol, kern, /CENTER, /NORMALIZE, /EDGE_TRUNCATE)
  print, 'QF (dose origin, convolved vs non convolved) = ', 1.0/n_elements(gtv_pet_ind) * total(abs(1 - dp_matr(gtv_pet_ind)/dp_matr_nonconvol(gtv_pet_ind)))
endif

if switcher ne 0 and switcher ne 1 and switcher ne 2 then begin
  print, "Switcher must have a value of 0 (dose matrix is convolved), 1 (pet matrix is convolved) or 2 (both)"
endif

end