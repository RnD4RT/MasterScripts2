Device, decomposed=0
loadct, 0
;tag 001850 er snitt oppl dose
vol=52.5
d_low=68.
d_high=90.
;p_low= 0.0
;p_high= 1.0-p_low      ;1.-3./vol  NB
p_low= 5.0;5.0
p_high= 100.0-p_low      ;1.-3./vol  NB


set_base=1.
d_base=50.
m_r=2;
z_skal=2.0;funnet manuelt, må endres hvis annen oppløsning, tror den alltid vil være lik snittykkelsen på ct, ev bruke det
; Henter inn RT-strukturer og lagrer
;lokasjon='C:\Users\Eirik\Dropbox\Universitet\Master\Patient 10'
;lokasjon_pet='C:\Users\Eirik\Dropbox\Universitet\Master\Patient 10'

;patients_figname = ['Patient_1', 'Patient_2', 'Patient_3', 'Patient_4', 'Patient_5', 'Patient_6', 'Patient_7', 'Patient_8', 'Patient_9', 'Patient_10', 'Patient_11']
;patients_folder = ['Patient 1', 'Patient 2', 'Patient 3', 'Patient 4', 'Patient 5', 'Patient 6', 'Patient 7', 'Patient 8', 'Patient 9', 'Patient 10', 'Patient 11']
figur_lokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\Figurer'
txt_lokasjon = 'C:\Users\Eirik\Dropbox\Universitet\Master\Txt'
patient = 'Patient_1'
lokasjon='C:\Users\Eirik\Dropbox\Universitet\Master\pats\Patient 1'          ; 1, 6 og 8 er gode alternativer
;lokasjon_pet='C:\Users\Eirik\Dropbox\Universitet\Master\pats\Patient 3' ;Denne brukes ikke      ; 3, 7 og 9 har problemer

cd, lokasjon
print, lokasjon
;leser inn original dosefil
file_RD=(file_SEARCH('RD*'))[0]
obj = OBJ_NEW('IDLffDICOM')
read = obj->Read(file_RD)
;pikseldata, zdim lang, pikseldata[i]=array (uin), [xdim, ydim]
pikseldata = obj->GetValue('7fe0'x, '0010'x);
xdim = obj->GetValue('0028'x, '0011'x)
ydim = obj->GetValue('0028'x, '0010'x)
zdim = obj->GetValue('0028'x, '0008'x)
dose_skal = obj->GetValue('3004'x, '000E'x)
posi = obj->GetValue('0020'x, '0032'x);x,y,z øverste venstre hjørne?
res_xy=obj->GetValue('0028'x, '0030'x);pixel_spacing
bits_alloc=obj->GetValue('0028'x, '0100'x);
pixel_rep=obj->GetValue('0028'x, '0103'x);
sample_per=obj->GetValue('0028'x, '002'x);
high_b=obj->GetValue('0028'x, '0102'x);
obj_destroy, obj

xdim = float(*xdim[0])
ydim = float(*ydim[0])
zdim=float(*zdim[0])
dose_skal = float(strcompress(*dose_skal[0], /REMOVE_ALL))
posi=strsplit(*posi[0], '\', /EXTRACT)
xpos=float(strcompress(posi(0), /REMOVE_ALL))
ypos=float(strcompress(posi(1), /REMOVE_ALL))
zpos=float(strcompress(posi(2), /REMOVE_ALL))
res_xy=strsplit(*res_xy[0], '\', /EXTRACT)
res_x=float(strcompress(res_xy(0), /REMOVE_ALL))
res_y=float(strcompress(res_xy(1), /REMOVE_ALL))
bits_alloc=uint(*bits_alloc[0])
pixel_rep=uint(*pixel_rep[0])
sample_per=uint(*sample_per[0])
high_b=uint(*high_b[0])

;for invers dosematrise til dicom
dp_inv=fltarr(xdim, ydim, zdim) ;res dosematrise
dim=size(dp_inv)

;finner pet-filer
;cd, lokasjon_pet
;print, lokasjon_pet
;file=file_search('f*')
file=file_search('PT*')
obj = OBJ_NEW('IDLffDICOM')
read = obj->Read(file(0))
;finner div tagger i pet-fil
xdim_p = obj->GetValue('0028'x, '0011'x)
ydim_p = obj->GetValue('0028'x, '0010'x)
posi_p = obj->GetValue('0020'x, '0032'x);hjørne
res_xy_p=obj->GetValue('0028'x, '0030'x);pixel_spacing
z_skal_p=obj->GetValue('0018'x, '0050'x)

obj_destroy, obj

xdim_p = float(*xdim_p[0])
ydim_p = float(*ydim_p[0])
z_skal_p=float(*z_skal_p[0]); nb bør endres til avstand mellom snitt, ikke snittykkelse

posi_p=strsplit(*posi_p[0], '\', /EXTRACT)
xpos_p=float(strcompress(posi_p(0), /REMOVE_ALL))
ypos_p=float(strcompress(posi_p(1), /REMOVE_ALL))

res_xy_p=strsplit(*res_xy_p[0], '\', /EXTRACT)
res_x_p=float(strcompress(res_xy_p(0), /REMOVE_ALL))
res_y_p=float(strcompress(res_xy_p(1), /REMOVE_ALL))

x_shift=round((xpos-xpos_p)/res_x)
y_shift=round((ypos-ypos_p)/res_y)
x_skal=round(xdim_p*res_x_p/res_x); nb, round gjør ting litt feil her...
y_skal=round(ydim_p*res_y_p/res_y)

;obs, obs, z_skal_p, er feil fyllt inn i dicom header for lu1, står 5mm, men er 3mm
;får ingen konsekvenser i det tilfellet, da det ikke er plass til et helt snitt mellom...
;NEI, NEI, NEI, det er ikke feil, snittykkelse er 5mm, men avstand mellom snitt er 3mm pga overlappende snitt
;Det er snittavstanden som teller, ev endre kode til å definere z_skal_p fra dette.
;må sjekkes for andre pas seinere, ev bruke forskjell i zpos for to nabosnitt og ikke verdi i tag.
;z_res dosematrise kan være annerledes enn oppløsning pet (i eclipse..)
pet_matrix=fltarr(xdim, ydim, round(n_elements(file)*z_skal_p/z_skal));pet i dose ref


adhoc_just=[0,1]
zpos_orig=zpos;ta vare på original zpos dosefil, hører til strukt osv
;leser inn alle billed-filer til matrise
diff_ref=0
if diff_ref then begin
  zpos=1000
  x_shift=0;??
  y_shift=0;??
  ;finner minste z verdi pet opptak
  for i=0, n_elements(file)-1 do begin
      obj = OBJ_NEW('IDLffDICOM')
      read = obj->Read(file(i))
      zpos_d=obj->GetValue('0020'x, '1041'x)
      zpos_d=float(*zpos_d[0])
      if zpos_d lt zpos then zpos=zpos_d
      obj_destroy, obj
   endfor
   x_shift=round((xpos-xpos_p)/res_x);??
   y_shift=round((ypos-ypos_p)/res_y);??
endif


zpos_dd = 0

for i=0, n_elements(file)-1 do begin

  obj = OBJ_NEW('IDLffDICOM')
  read = obj->Read(file(i))
  pikseldata = read_dicom(file(i))
  conv_kern=obj->GetValue('0018'x, '1210'x)
  xd = obj->GetValue('0028'x, '0011'x)
  yd = obj->GetValue('0028'x, '0010'x)
  posi_d = obj->GetValue('0020'x, '0032'x);x,y,z øverste venstre hjørne?
  res_xy_d=obj->GetValue('0028'x, '0030'x);pixel_spacing
  pet_skal= obj->GetValue('0028'x, '1053'x)
  pet_skal=float(*pet_skal[0]);OBS kan være ulik for hvert snitt
  ;print, 'conv-kern ', *conv_kern[0]
  xd = *xd[0]
  yd = *yd[0]
  posi_d=strsplit(*posi_d[0], '\', /EXTRACT)
  xpos_d=float(strcompress(posi_d(0), /REMOVE_ALL))
  ypos_d=float(strcompress(posi_d(1), /REMOVE_ALL))
  zpos_d=float(strcompress(posi_d(2), /REMOVE_ALL))
  res_xy_d=strsplit(*res_xy_d[0], '\', /EXTRACT)
  res_x_d=float(strcompress(res_xy_d(0), /REMOVE_ALL))
  res_y_d=float(strcompress(res_xy_d(1), /REMOVE_ALL))
  ;kontr at alle geom-param er like, kan slettes
  if xdim_p ne xd or ydim_p ne yd or xpos_d ne xpos_p or ypos_d ne ypos_p or res_y_d ne res_y_p or res_x_d ne res_x_p then stop
  ;zpos_d=obj->GetValue('0020'x, '1041'x)
  ;zpos_d=float(*zpos_d[0])
  
  z_thickness = zpos_dd - zpos_d ;Ikke sikkert dette fungerer for alle PET-filer, men fungerer for test pasient 1
  zpos_dd = zpos_d
  
  temp=congrid(float(pikseldata), x_skal, y_skal) ; sikre samme oppløsing i dose og pet-bilde
  ;innlesing til matrise i dosereferanse robust for ulik størrelse og plassering av pet-matrise
  if zpos_d ge zpos then begin
    for j=0, xdim-1 do begin
      j_p=j+x_shift+adhoc_just(0)
      if j_p ge 0 and j_p lt x_skal then begin
        for k=0, ydim-1 do begin
          k_p=k+y_shift+adhoc_just(1)
          if k_p ge 0 and k_p lt y_skal then pet_matrix(j,k,round((zpos_d-zpos)/z_skal))=pet_skal*temp(j_p, k_p)
        endfor
      endif
    endfor
  endif
endfor


obj_destroy, obj
new_pet_dim=size(pet_matrix);
zpos=zpos_orig; tilbake til zpos dosematrise, i tilfelle ulik ref

;fyller inn manglende pet_snitt (hvis større snittavstand pet og dosematrise);
for i=1,new_pet_dim(3)-2 do begin ;antar at det ikke er noe interesant i ev manglene første eller siste snit
  if max(pet_matrix(*,*,i)) eq 0 then pet_matrix(*,*,i)=.5*(pet_matrix(*,*,i-1)+pet_matrix(*,*,i+1));
endfor 

;openw, 4, 'C:\Users\Eirik\Dropbox\Universitet\Master\pet_matrix.txt'
;printf, 4, pet_matrix
;close, 4


;--kun aktuelt hvis pet og ct ikke er fra samme sesjon
;z_diff_reg=70
;x_diff_reg=2
;y_diff_reg=-10
;
;if diff_ref then begin
;  temp_pet_matrix=pet_matrix
;  pet_matrix=fltarr(xdim, ydim, zdim)
;  for i=0, n_elements(file)-1 do begin
;    pet_matrix(*,*,i+z_diff_reg)=shift(reform(temp_pet_matrix(*,*,i)),x_diff_reg, y_diff_reg)
;  endfor
;endif
;---------------

;finner struktur-fil
; NB
cd, lokasjon

file=file_search('RS*')
cont_pointr = use_rtss_test(file)  ;Egentlig bare use_rtss

numbers = n_elements(cont_pointr[*, 0])
cont_mat= cont_pointr[*, 0]
cont_sort_mat= cont_pointr[*, 1]
punkt_indeks_mat= cont_pointr[*, 2]


;test just----
dim_error=fltarr(4)
dim_error(0)=x_shift*res_x-(-xpos_p+xpos)
dim_error(1)=y_shift*res_y-(-ypos_p+ypos)
dim_error(2)=x_skal/(xdim_p*res_x_p/res_x)
dim_error(3)=y_skal/(ydim_p*res_y_p/res_y)
print, dim_error

store_matrix = ptrarr(numbers, 11)


for numb=0, numbers - 1 do begin
  cont = *(cont_mat[numb])
  cont_sort = *(cont_sort_mat[numb])
  punkt_indeks = *(punkt_indeks_mat[numb])
    
  
  ;prøver og kompensere for avrunding i shift og congrid
  ;cont(0,*)=(dim_error(2)*(cont(0,*)-xpos+dim_error(0))/res_x)
  ;cont(1,*)=(dim_error(3)*(cont(1,*)-ypos+dim_error(1))/res_y)
  ;slutt test just, ev slett
  ;
  ;;gjør om x og y til plass i pet_matrise (i dose ref), (plassering roi er i mm)
  ;;original,ev tilbake
  ;
  cont(0,*)=(cont(0,*)-xpos)/res_x
  cont(1,*)=(cont(1,*)-ypos)/res_y

  ;får orden på indeksering av snittskifte i punktliste
  for i=n_elements(punkt_indeks)-1,0, -1  do punkt_indeks(i)=total(punkt_indeks(0:i))-punkt_indeks(i)
  
  
  ;sorterer punktliste etter stigende z
  s_i=sort(cont(2,punkt_indeks))
  
  punkt_indeks_sort=intarr(n_elements(punkt_indeks))
  z_value = fltarr(n_elements(punkt_indeks))
  count=0
  for i=0, n_elements(s_i)-1 do begin
    if s_i(i) eq n_elements(punkt_indeks) -1 then begin
      ant=n_elements(cont(2,*))-punkt_indeks(s_i(i))
    endif else begin
      ant=punkt_indeks(s_i(i)+1)-punkt_indeks(s_i(i))
    endelse
    punkt_indeks_sort(i)=count
    cont_sort(*,punkt_indeks_sort(i):punkt_indeks_sort(i)+ant-1)=cont(*,punkt_indeks(s_i(i)):punkt_indeks(s_i(i))+ant-1)
    z_value(i) = cont(2,punkt_indeks(s_i(i)))
    (*cont_sort_mat[numb])[*,punkt_indeks_sort(i):punkt_indeks_sort(i)+ant-1] = cont(*,punkt_indeks(s_i(i)):punkt_indeks(s_i(i))+ant-1)
    ;Endre hovedmatrix her. Type: (cont_sort_mat[l])[*, punkt_indeks_sort(i):punkt_indeks_sort(i)+ant-1] osv.
    count=count+ant
  endfor

  ;lage mask for roi til pet-matrise
  gtv_pet_mask=intarr(dim(1),dim(2), dim(3))
  for i=0,n_elements(punkt_indeks_sort)-1 do begin
    snitt=((cont_sort(2,punkt_indeks_sort(i))-zpos)/z_skal)
    if i ne n_elements(punkt_indeks_sort)-1 then points=reform(cont_sort(0:1,punkt_indeks_sort(i):punkt_indeks_sort(i+1)-1))
    if i eq n_elements(punkt_indeks_sort)-1 then points=reform(cont_sort(0:1,punkt_indeks_sort(i):n_elements(cont_sort(2,*))-1))
    obj_midl=OBJ_NEW('IDLanRoi', points(0,*),points(1,*))
    mask_midl=obj_midl->IDLanRoi::ComputeMask(dimensions=[dim(1),dim(2)], mask_rule=m_r)
    gtv_pet_mask(*,*, snitt)=gtv_pet_mask(*,*, snitt)+mask_midl; kan ha to lukkede konturer i samme snitt
    obj_destroy, obj_midl
  endfor
  
  
  ;marise med ønsket dp dosefordeling i gtv_pet, i samme ref-system som hele pet_matrisen for enkelhets skyld
  dp_matr=fltarr(dim(1), dim(2), dim(3))
  gtv_pet_ind=where(gtv_pet_mask);indekser til gtv_pet [som er over 0], [] = Lagt til av Eirik
  
  store_matrix[numb, 0] = ptr_new(gtv_pet_mask)
  ;store_matrix[numb, 1] = ptr_new(dp_matr)
  store_matrix[numb, 2] = ptr_new(gtv_pet_ind)
;  store_matrix[numb, 3] = ptr_new(n_tot)
;  store_matrix[numb, 4] = ptr_new(max_pet)
;  store_matrix[numb, 5] = ptr_new(min_pet)
;  store_matrix[numb, 6] = ptr_new(temp_gtv)
;  store_matrix[numb, 7] = ptr_new(sort_gtv)
;  store_matrix[numb, 8] = ptr_new(dp_inv)
  store_matrix[numb, 9] = ptr_new(punkt_indeks_sort)
  store_matrix[numb, 10] = ptr_new(z_value)
  
  ;stop
  
  ; What I want to know outside of loop: gtv_pet_mask, dp_matr, gtv_pet_ind, n_tot, max_pet, min_pet, temp_gtv, sort_gtv, dp_inv
  
  ;formaterer til uint med ny dose grid scaling
;  new_dose_skal=max(dp_inv)/65500.
;  new_dose_skal_o=max(dp_matr)/65500.
;  if pixel_rep eq 0 then begin
;    dp_inv=uint(dp_inv/new_dose_skal)
;    dp_matr=uint(dp_matr/new_dose_skal_o)
;  endif
  
  ;Burde jeg lagre disse verdiene også?
endfor


;stop ;Her kommer det Program caused arithmetic error: Floating illegal operand error


counter = 0
for i=0, numbers-1 do begin
  for j = i+1, numbers-1 do begin
    for k=0, n_elements((*store_matrix[i, 2]))-1 do begin
      for l=0, n_elements((*store_matrix[j, 2]))-1 do begin
        if (*store_matrix[i, 2])[k] eq (*store_matrix[j, 2])[l] then begin
          ;print, 'You have overlapping doseplans at the index:', (*store_matrix[i, 2])[k], (*store_matrix[j, 2])[l]
          counter++
        endif
      endfor
    endfor
  endfor
endfor

print, 'You have ', counter, ' overlapping doseplan indeicies'



gtv_pet_ind = []
;foreach element, (*store_matrix[*, 2]) do begin
;  print, element
;endforeach

for i=0, numb-1 do begin
  gtv_pet_ind = [gtv_pet_ind, (*store_matrix[i, 2])]               ;Legger alle indekser på samme matrise slik at jeg kan bruke alt til å lage én dosematrise.
endfor

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
print, min_pet, max_pet, mean(pet_matrix(gtv_pet_ind))


;definerer Ihigh ig Ilow fra persentilene (ev bytte til mer proff persentilfunksjon...)
;if p_low gt 0.0 then min_pet=prank(pet_matrix(gtv_pet_ind), p_low)   ;sort_gtv(round(n_tot*p_low)-1)
;if p_high lt 1.0 then max_pet=prank(pet_matrix(gtv_pet_ind), p_high)   ;sort_gtv(round(n_tot*p_high))

;ser ut som om prank trenger prosent i tall fra 0 til 100, ikke 0 til 1.
if p_low gt 0.0 then min_pet=prank(pet_matrix(gtv_pet_ind), p_low)   ;sort_gtv(round(n_tot*p_low)-1)
if p_high lt 100.0 then max_pet=prank(pet_matrix(gtv_pet_ind), p_high)
print, min_pet, max_pet, mean(pet_matrix(gtv_pet_ind))


;Finner D_high for YX
rho_ref = max_pet

sigma2 = total(alog(rho_ref/pet_matrix[gtv_pet_ind]))
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
;rho_min = min_pet
;
;c = (alog(rho_ref/rho_min) - 1.0/N * (sigma2))/(d_avg - d_low)
;
;D_ref = d_low + 1/c*alog(rho_ref/rho_min)
;
;d_high_yx = D_ref ;Var d_high_yx før


;Finner D_high for lineær
;sigma_l = total((pet_matrix[gtv_pet_ind] - min_pet)/(max_pet - min_pet))
;d_high_l = N/sigma_l * (d_avg - d_low) + d_low

n_tot = N

;dp_skal=total((pet_matrix(gtv_pet_ind)-min_pet)/(max_pet-min_pet))/n_tot; original formel
;d_high_l=((d_avg-d_low)/dp_skal)+d_low;original formel

dp_skal=total((sort_gtv(round(n_tot*p_low):round(n_tot*p_high)-1)-min_pet)/(max_pet-min_pet))/(n_tot*n_mean);litt feil med avrunding her, men neppe relevant mange tusen piksler totalt
d_high_l=(d_mean+d_low*(dp_skal*n_mean-n_mean-n_low))/(dp_skal*n_mean+n_high)

;print, sigma_l

;lager preskribsjonsmatrise etter lineær formel, korrigere verdier over/under dhigh/dlow etterpå hvis persentiler benyttet
ans = ''
READ, ans, prompt = 'Ønsker du lineær, YangXing eller begge? (l/yx/b) '
;ans = 'yx'

if ans eq 'l' then begin
  dp_matr(gtv_pet_ind)=d_low+(pet_matrix(gtv_pet_ind)-min_pet)*(d_high_l-d_low)/(max_pet-min_pet)
  for i=long(0), n_tot-1 do begin
    if dp_matr(gtv_pet_ind(i)) lt d_low then dp_matr(gtv_pet_ind(i))=d_low
    if dp_matr(gtv_pet_ind(i)) gt d_high_l then dp_matr(gtv_pet_ind(i))=d_high_l
 
  endfor
endif


stop
if ans eq 'yx' then begin
  SF2 = 0.48
  alpha = - alog(SF2)/2.0
  print, alpha
  rho_ref = max_pet
  dp_matr(gtv_pet_ind) = d_high_yx - 1.0/c * alog(rho_ref/pet_matrix(gtv_pet_ind))   ;c var alpha her før.
endif

if ans eq 'b' then begin
  dp_matr1 = dp_matr
  dp_matr2 = dp_matr
  
  dp_matr1(gtv_pet_ind)=d_low+(pet_matrix(gtv_pet_ind)-min_pet)*(d_high_l-d_low)/(max_pet-min_pet)
  for i=long(0), n_tot-1 do begin
    if dp_matr1(gtv_pet_ind(i)) lt d_low then dp_matr1(gtv_pet_ind(i))=d_low
    if dp_matr1(gtv_pet_ind(i)) gt d_high_l then dp_matr1(gtv_pet_ind(i))=d_high_l
  endfor
  
  SF2 = 0.48
  alpha = - alog(SF2)/2.0
  print, alpha
  rho_ref = max_pet
  dp_matr2(gtv_pet_ind) = d_high_yx - 1.0/c * alog(rho_ref/pet_matrix(gtv_pet_ind))   ;c var alpha her før.
  
  if set_base then begin
    dp_inv1=d_low+d_base-dp_matr1;
    dp_inv2=d_low+d_base-dp_matr2;
  endif else begin
    dp_inv1(gtv_pet_ind)=d_low+d_base-dp_matr1(gtv_pet_ind)
    dp_inv2(gtv_pet_ind)=d_low+d_base-dp_matr2(gtv_pet_ind)
  endelse

  ;div sjekk av verdier
  d_mean1=mean(dp_matr1(gtv_pet_ind))
  d_mean2=mean(dp_matr2(gtv_pet_ind))
  print, 'presc_l: ', max(dp_matr1(gtv_pet_ind)), min(dp_matr1(gtv_pet_ind)), mean(dp_matr1(gtv_pet_ind))
  print, 'inv_l: ', max(dp_inv1(gtv_pet_ind)), min(dp_inv1(gtv_pet_ind))
  print, 'presc_yx: ', max(dp_matr2(gtv_pet_ind)), min(dp_matr2(gtv_pet_ind)), mean(dp_matr2(gtv_pet_ind))
  print, 'inv_yx: ', max(dp_inv2(gtv_pet_ind)), min(dp_inv2(gtv_pet_ind))


  ;--------------div for visuell sjekk (kan slettes)-----------
  ans = ''
  READ, ans, prompt = 'Vil du se histogram for begge? (Y/n) '
  if ans eq 'Y' then begin
    ;histo1=histogram(dp_matr1(gtv_pet_ind),locations=l, binsize=1, min=d_low, max=round(d_high))
    
    cd, figur_lokasjon
    
    histo1=histogram(dp_matr1(gtv_pet_ind),locations=xbin, binsize=1, min=d_low, max=round(d_high))
    histo_inv1=histogram(dp_inv1(gtv_pet_ind),locations=l2, binsize=1, min=d_low+d_base-round(d_high), max=d_base)
    histo2=histogram(dp_matr2(gtv_pet_ind),locations=l, binsize=1, min=d_low, max=round(d_high))
    histo_inv2=histogram(dp_inv2(gtv_pet_ind),locations=l2, binsize=1, min=d_low+d_base-round(d_high), max=d_base)

    ;Dosematrise for pasient utregnet med lineær

    title1 = 'lin_' + patient
    phisto = plot(xbin, histo1, xrange = [d_low, d_high], TITLE = title1)
    ax = phisto.AXES
    ax[1].minor = 0
    ax[2].major = 0
    ax[2].minor = 0
    ax[3].minor = 0
    phisto.stairstep = 1
    
    phisto.save, (title1 + '.png'), resolution = 300
    
;    Dosematrise for pasient utregnet med yx

    title2 = 'yx_' + patient
    phisto2 = plot(xbin, histo2, xrange = [d_low, d_high], TITLE = title2)
    ax = phisto2.AXES
    ax[1].minor = 0
    ax[2].major = 0
    ax[2].minor = 0
    ax[3].minor = 0
    phisto2.stairstep = 1
    
    phisto2.save, (title2 + '.png'), resolution = 300
  endif
  ;------------------------------------------------------------
  dp_matr = dp_matr1
endif

V_i = res_x_p*1e-3*res_y_p*1e-3*z_thickness*1e-3 ;Veldig usikker på om disse har samme enhet. Spør om det. Satt til mm
;TCP = exp(-rho_i *V_i * exp(-alpha_i_marked * dose_i + gamma_i *deltaT))
gamma = alog(2)/40.0 ;Fra tabell 2 i yx
deltaT = 35.0/5.0 * 7.0 - 2; Antar 35 fraksjoner, 5 dager i uken. Trekker fra siste helg

;TCP_i = exp(-pet_matrix[gtv_pet_ind] * V_i * exp(-c*dp_matr[gtv_pet_ind] + gamma*deltaT))
;
;TCP = TCP_i[0]
;
;for i=1, n_elements(TCP_i) - 1 do begin
;  TCP = TCP*TCP_i[i]
;endfor

;Alt blir uendelig lite. Finn gamma_i og deltaT
;print, TCP


;TCP(gtv_pet_ind) = exp(-pet_matrix(gtv_pet_ind)*Volume*exp(-alpha*dp_matr(gtv_pet_ind + gamameleon[gtv_pet_ind]*delta_T)))
           
;p = plot(dp_matr[*,*, 100])
;ax = p.AXES
;ax[1].yrange = [d_low - ((d_high-d_low)/100.0)*10, d_high + ((d_high-d_low)/100.0)*10]
;p.SYM_INCREMENT = 5
;p.SYM_COLOR = "blue"
;p.SYM_FILLED = 1
;p.SYM_FILL_COLOR = 0
;
;p2 = plot((dp_matr(gtv_pet_ind))[sort(dp_matr(gtv_pet_ind))])
;ax2 = p2.AXES
;ax2[1].yrange = ax[1].yrange

;lager inv matrise for summert optimalisering i tps
;setter d=d_baae utenfor gtv_pet og som maxdose til gtv_pet i invers matrise, minstedose i invers matrise blir d_base-(d_high-d_low)
if set_base then begin
  dp_inv=d_low+d_base-dp_matr;
endif else begin
  dp_inv(gtv_pet_ind)=d_low+d_base-dp_matr(gtv_pet_ind)
endelse



;div sjekk av verdier
d_mean=mean(dp_matr(gtv_pet_ind))
print, 'Total presc: ', max(dp_matr(gtv_pet_ind)), min(dp_matr(gtv_pet_ind)), mean(dp_matr(gtv_pet_ind))
print, 'Total inv: ', max(dp_inv(gtv_pet_ind)), min(dp_inv(gtv_pet_ind))
for i=0, numb-1 do begin
  print, 'Kontur ', *(cont_pointr[*, 3])[i], ' presc: ', max(dp_matr[(*store_matrix[i, 2])]), min(dp_matr[(*store_matrix[i, 2])]), mean(dp_matr[(*store_matrix[i, 2])])
  print, 'Kontur ', *(cont_pointr[*, 3])[i], ' inv: ', max(dp_inv[(*store_matrix[i, 2])]), min(dp_inv[(*store_matrix[i, 2])])
endfor

A = 'Total presc: ' + strcompress(max(dp_matr(gtv_pet_ind))) + strcompress(min(dp_matr(gtv_pet_ind))) + strcompress(mean(dp_matr(gtv_pet_ind)))

txt_filename = txt_lokasjon + '/' + patient + '_total_dose_' + strcompress(numbers) + '_ROIs' + '.txt'
openw, 1, txt_filename
printf, 1, FORMAT = '(%"Total presc: %f %f %f")', max(dp_matr(gtv_pet_ind)), min(dp_matr(gtv_pet_ind)), mean(dp_matr(gtv_pet_ind))
printf, 1, FORMAT = '(%"Total inv: %f %f")' , max(dp_inv(gtv_pet_ind)), min(dp_inv(gtv_pet_ind))
for i=0, numb-1 do begin
  printf, 1, FORMAT = '(%"Kontur: %s, presc: %f %f %f")', *(cont_pointr[*, 3])[i], max(dp_matr[(*store_matrix[i, 2])]), min(dp_matr[(*store_matrix[i, 2])]), mean(dp_matr[(*store_matrix[i, 2])])  ;'Kontur ', *(cont_pointr[*, 3])[i], ' presc: ', max(dp_matr[(*store_matrix[i, 2])]), min(dp_matr[(*store_matrix[i, 2])]), mean(dp_matr[(*store_matrix[i, 2])])
  printf, 1, FORMAT = '(%"Kontur: %s, inv: %f %f")', *(cont_pointr[*, 3])[i], max(dp_inv[(*store_matrix[i, 2])]), min(dp_inv[(*store_matrix[i, 2])]) ;'Kontur ', *(cont_pointr[*, 3])[i], ' inv: ', max(dp_inv[(*store_matrix[i, 2])]), min(dp_inv[(*store_matrix[i, 2])])
endfor

close, 1

;--------------div for visuell sjekk (kan slettes)-----------
ans = ''
READ, ans, prompt = 'Vil du se histogram? (Y/n) '
if ans eq 'Y' then begin
  histo=histogram(dp_matr(gtv_pet_ind),locations=l, binsize=1, min=d_low, max=round(d_high))
  histo_inv=histogram(dp_inv(gtv_pet_ind),locations=l2, binsize=1, min=d_low+d_base-round(d_high), max=d_base)
  window, 1
  plot, l, histo, psym=10
  window, 2
  plot, l2, histo_inv, psym=10  
endif
;------------------------------------------------------------

;formaterer til uint med ny dose grid scaling
new_dose_skal=max(dp_inv)/65500.
new_dose_skal_o=max(dp_matr)/65500.
if pixel_rep eq 0 then begin
  dp_inv=uint(dp_inv/new_dose_skal)
  dp_matr=uint(dp_matr/new_dose_skal_o)
endif








;Illustrering av konturer på PETbilde, kan sløyfes.
ans = 'Y'
READ, ans, prompt = 'Vil du se konturplot snitt for snitt? (Y/n) '
if ans eq 'Y' then begin


  n = 0
  
  for i=0, numbers-1 do begin
    if n_elements(*punkt_indeks_mat[i]) ge n then begin
      n = n_elements(*punkt_indeks_mat[i])
    endif
  endfor
  
  
  
  punkt_indeks_min = 10000
  punkt_indeks_maks = -punkt_indeks_min
  
  for i=0, n_elements(store_matrix[*, 10])-1 do begin
    if min(*store_matrix[i, 10]) le punkt_indeks_min then begin
      punkt_indeks_min = min(*store_matrix[i, 10])
    endif
  
    if max(*store_matrix[i, 10]) ge punkt_indeks_maks then begin
      punkt_indeks_maks = max(*store_matrix[i, 10])
    endif
  endfor
  
  new_punkt_indeks_sort = make_array(2*numbers+1, (punkt_indeks_maks-punkt_indeks_min+z_skal_p)/z_skal_p, /INT) ;+z_skal_p pga 0 må telles med
  
  for i=0, n_elements(new_punkt_indeks_sort[0,*])-1 do begin
    new_punkt_indeks_sort[0,i] = punkt_indeks_min
    punkt_indeks_min = punkt_indeks_min + 2
  endfor
  
  for i=0, numbers - 1 do begin
    for j=0, n_elements(*store_matrix[i, 10])-1 do begin
      for k=0, n_elements(new_punkt_indeks_sort[0,*])-1 do begin
        if (*store_matrix[i, 10])[j] eq new_punkt_indeks_sort[0,k] then begin
          new_punkt_indeks_sort[i+1, k] = 1
          new_punkt_indeks_sort[i+numbers+1, k] = (*(store_matrix[i, 9]))[j]
        endif
      endfor
    endfor
  endfor
  
  
  counter = 0

  zoomf=3
  window, 0,xsize=xdim*zoomf, ysize=ydim*zoomf
  for i=0,n_elements(new_punkt_indeks_sort[0, *])-1 do begin
    switcher = 1
    ;print, 'i = ', i
    
    for j=0, n_elements(new_punkt_indeks_sort[1:numbers, 0])-1 do begin
      ;print, 'j = ', j
      ;print, 'Supposed to be 0 or 1 = ',(new_punkt_indeks_sort[1:3, i])[j]
      if (new_punkt_indeks_sort[1:numbers, i])[j] eq 1 then begin
        cont_sort = *(cont_sort_mat[j])
        ;punkt_indeks_sort = *(store_matrix[j, 9])
        
        snitt = ((cont_sort(2, new_punkt_indeks_sort[j+numb+1, i]) - zpos)/z_skal)
        if switcher eq 1 then begin
          counter += 1
          tvscl, rebin(reform(pet_matrix(*,*,snitt)), zoomf*xdim, zoomf*ydim)
          switcher = 0
        endif
        if i ne n_elements((new_punkt_indeks_sort[j+numb+1, *]))-1 then plots, zoomf*cont_sort(0,(new_punkt_indeks_sort[j+numb+1, *])(i):(new_punkt_indeks_sort[j+numb+1, *])(i+1)-1), zoomf*cont_sort(1,(new_punkt_indeks_sort[j+numb+1, *])(i):(new_punkt_indeks_sort[j+numb+1, *])(i+1)-1), /device
        if i eq n_elements((new_punkt_indeks_sort[j+numb+1, *]))-1 then plots, zoomf*cont_sort(0,(new_punkt_indeks_sort[j+numb+1, *])(i):n_elements(cont_sort(2,*))-1), zoomf*cont_sort(1,(new_punkt_indeks_sort[j+numb+1, *])(i):n_elements(cont_sort(2,*))-1), /device  
      endif
    endfor
    wait, .5
  endfor
endif

end
;for i=0, n_elements(store_matrix[*, 10])-1 do begin 
;  for j=i+1, n_elements(store_matrix[*, 10])-1 do begin
;    for k=0, n_elements(*store_matrix[i, 10])-1 do begin
;      for l=0, n_elements(*store_matrix[j, 10])-1 do begin
;        if (*store_matrix[i, 10])[k] eq (*store_matrix[j, 10])[l] then begin
;          ;print, i, j, k, l, (*store_matrix[i, 10])[k], (*store_matrix[j, 10])[l]
;        endif
;      endfor 
;    endfor
;  endfor
;endfor

;stop
;
;cd, lokasjon
;print, lokasjon
;inv_name=strcompress(round(d_low*100))+'_'+strcompress(round(d_high*100))+strcompress(round(d_mean*100))+'Gy_inv_base'+strcompress(round(set_base))+'.dcm'
;presc_name=strcompress(round(d_low*100))+'_'+strcompress(round(d_high*100))+strcompress(round(d_mean*100))+'Gy_presc_base'+strcompress(round(set_base))+'.dcm'
;s_file=DIALOG_PICKFILE(PATH=FILEPATH('', root_dir=lokasjon),TITLE='Select original RT-Dose file to be cloned ', FILTER='rd*', GET_PATH=path)
;
;dose_exp =getenv(s_file)+path+inv_name
;dose_exp_o =getenv(s_file)+path+presc_name
;dose_inv_obj = OBJ_NEW('IDLffDicomEx',dose_exp, CLONE=s_file)
;dose_o_obj = OBJ_NEW('IDLffDicomEx',dose_exp_o, CLONE=s_file)
;
;if bits_alloc ne 16 then begin;problemer med 32 bit i pixel matrix for eclipse filer, endrer til 16 bit
;  dose_inv_obj->setvalue, '0028,0100', 'US', uint(16)
;  dose_o_obj->setvalue, '0028,0100', 'US', uint(16)
;  dose_inv_obj->setvalue, '0028,0101', 'US', uint(16)
;  dose_o_obj->setvalue, '0028,0101', 'US', uint(16)
;  dose_inv_obj->setvalue, '0028,0102', 'US', uint(15)
;  dose_o_obj->setvalue, '0028,0102', 'US', uint(15)
;  bits_alloc=uint(16)
;endif
;
;;sette ny dose grid scaling og skriver inn pixeldata
;dose_inv_obj ->SetValue, '3004,000E', 'DS',string(new_dose_skal, format='(e11.4)')
;dose_inv_obj ->SetPixelData, dp_inv,  BITS_ALLOCATED=bits_alloc , COLUMNS=uint(xdim) , /order, ROWS=uint(ydim), NUMBER_OF_FRAMES=uint(zdim) , PIXEL_REPRESENTATION=piksel_rep,   SAMPLES_PER_PIXEL=sample_per
;dose_o_obj ->SetValue, '3004,000E', 'DS',string(new_dose_skal_o, format='(e11.4)')
;dose_o_obj ->SetPixelData, dp_matr,  BITS_ALLOCATED=bits_alloc , COLUMNS=uint(xdim) , /order, ROWS=uint(ydim), NUMBER_OF_FRAMES=uint(zdim) , PIXEL_REPRESENTATION=piksel_rep,   SAMPLES_PER_PIXEL=sample_per
;dose_inv_obj ->commit
;dose_o_obj ->commit
;OBJ_DESTROY, dose_inv_obj
;OBJ_DESTROY, dose_o_obj
;print, 'done'
;
;end