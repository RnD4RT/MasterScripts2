Device, decomposed=0
loadct, 0
;tag 001850 er snitt oppl dose
vol=52.5
d_low=70.
d_high=90.
p_low=0.0 ;0.05
p_high=1.0 ; 1.0-p_low      ;1.-3./vol  NB

set_base=1.
d_base=50.
m_r=2;
z_skal=2.5;funnet manuelt, må endres hvis annen oppløsning, tror den alltid vil være lik snittykkelsen på ct, ev bruke det
; Henter inn RT-strukturer og lagrer
lokasjon='C:\Users\Eirik\Dropbox\Universitet\Master\Patient 1_test'
lokasjon_pet='C:\Users\Eirik\Dropbox\Universitet\Master\pats\Patient 1_test'
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
print, lokasjon_pet
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
cont_pointr=use_rtss_test(file)  ;Egentlig bare use_rtss
cont=*cont_pointr[0]
cont_sort=*cont_pointr[1]
punkt_indeks=*cont_pointr[2]

;test just----
dim_error=fltarr(4)
dim_error(0)=x_shift*res_x-(-xpos_p+xpos)
dim_error(1)=y_shift*res_y-(-ypos_p+ypos)
dim_error(2)=x_skal/(xdim_p*res_x_p/res_x)
dim_error(3)=y_skal/(ydim_p*res_y_p/res_y)
print, dim_error


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
count=0
for i=0, n_elements(s_i)-1 do begin
  print, s_i(i)
  if s_i(i) eq n_elements(punkt_indeks) -1 then begin
    ant=n_elements(cont(2,*))-punkt_indeks(s_i(i))
    print, "If loop"
  endif else begin
    ant=punkt_indeks(s_i(i)+1)-punkt_indeks(s_i(i))
    print, "Else loop"
  endelse
  punkt_indeks_sort(i)=count
  cont_sort(*,punkt_indeks_sort(i):punkt_indeks_sort(i)+ant-1)=cont(*,punkt_indeks(s_i(i)):punkt_indeks(s_i(i))+ant-1)
  print, punkt_indeks_sort(i), punkt_indeks_sort(i)+ant-1
  print, punkt_indeks(s_i(i)), punkt_indeks(s_i(i))+ant-1
  count=count+ant
endfor

;--------kun for visuell sjekk av kontur vs bilder (kan slettes)---------------
zoomf=3
window, 0,xsize=xdim*zoomf, ysize=ydim*zoomf
for i=0,n_elements(punkt_indeks_sort)-1 do begin
  snitt=((cont_sort(2,punkt_indeks_sort(i))-zpos)/z_skal)
  tvscl, rebin(reform(pet_matrix(*,*,snitt)), zoomf*xdim, zoomf*ydim)
  if i ne n_elements(punkt_indeks_sort)-1 then plots, zoomf*cont_sort(0,punkt_indeks_sort(i):punkt_indeks_sort(i+1)-1), zoomf*cont_sort(1,punkt_indeks_sort(i):punkt_indeks_sort(i+1)-1), /device
  if i eq n_elements(punkt_indeks_sort)-1 then plots, zoomf*cont_sort(0,punkt_indeks_sort(i):n_elements(cont_sort(2,*))-1), zoomf*cont_sort(1,punkt_indeks_sort(i):n_elements(cont_sort(2,*))-1), /device
  wait,.5
endfor
;-------------slutt visuell sjekk----------------

stop
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
gtv_pet_ind=where(gtv_pet_mask);indekser til gtv_pet
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
if p_low gt 0.0 then min_pet=prank(pet_matrix(gtv_pet_ind), p_low)   ;sort_gtv(round(n_tot*p_low)-1)
if p_high lt 1.0 then max_pet=prank(pet_matrix(gtv_pet_ind), p_high)   ;sort_gtv(round(n_tot*p_high))
print, min_pet, max_pet, mean(pet_matrix(gtv_pet_ind))


;lager preskribsjonsmatrise etter lineær formel, korrigere verdier over/under dhigh/dlow etterpå hvis persentiler benyttet
dp_matr(gtv_pet_ind)=d_low+(pet_matrix(gtv_pet_ind)-min_pet)*(d_high-d_low)/(max_pet-min_pet)
for i=long(0), n_tot-1 do begin
  if dp_matr(gtv_pet_ind(i)) lt d_low then dp_matr(gtv_pet_ind(i))=d_low
  if dp_matr(gtv_pet_ind(i)) gt d_high then dp_matr(gtv_pet_ind(i))=d_high
endfor

;lager inv matrise for summert optimalisering i tps
;setter d=d_baae utenfor gtv_pet og som maxdose til gtv_pet i invers matrise, minstedose i invers matrise blir d_base-(d_high-d_low)
if set_base then begin
  dp_inv=d_low+d_base-dp_matr;
endif else begin
  dp_inv(gtv_pet_ind)=d_low+d_base-dp_matr(gtv_pet_ind)
endelse

;div sjekk av verdier
d_mean=mean(dp_matr(gtv_pet_ind))
print, 'presc: ', max(dp_matr(gtv_pet_ind)), min(dp_matr(gtv_pet_ind)), mean(dp_matr(gtv_pet_ind))
print, 'inv: ', max(dp_inv(gtv_pet_ind)), min(dp_inv(gtv_pet_ind))

;--------------div for visuell sjekk (kan slettes)-----------
histo=histogram(dp_matr(gtv_pet_ind),locations=l, binsize=1, min=d_low, max=round(d_high))
histo_inv=histogram(dp_inv(gtv_pet_ind),locations=l2, binsize=1, min=d_low+d_base-round(d_high), max=d_base)
window, 1
plot, l, histo, psym=10
window, 2
plot, l2, histo_inv, psym=10

;loadct ,33
;zoomf=3
;window, 4,xsize=xdim*zoomf, ysize=ydim*zoomf, title='Inv'
;window, 5,xsize=xdim*zoomf, ysize=ydim*zoomf, title='Presc'
;for i=0,n_elements(punkt_indeks_sort)-1 do begin
;  snitt=(cont_sort(2,punkt_indeks_sort(i))-zpos)/z_skal
;  wset, 4
;  tvscl, rebin(reform(dp_inv(*,*,snitt)), zoomf*xdim, zoomf*ydim)
;  if i ne n_elements(punkt_indeks_sort)-1 then plots, zoomf*cont_sort(0,punkt_indeks_sort(i):punkt_indeks_sort(i+1)-1), zoomf*cont_sort(1,punkt_indeks_sort(i):punkt_indeks_sort(i+1)-1), /device
;  if i eq n_elements(punkt_indeks_sort)-1 then plots, zoomf*cont_sort(0,punkt_indeks_sort(i):n_elements(cont_sort(2,*))-1), zoomf*cont_sort(1,punkt_indeks_sort(i):n_elements(cont_sort(2,*))-1), /device
;  wset, 5
;  tvscl, rebin(reform(dp_matr(*,*,snitt)), zoomf*xdim, zoomf*ydim)
;  if i ne n_elements(punkt_indeks_sort)-1 then plots, zoomf*cont_sort(0,punkt_indeks_sort(i):punkt_indeks_sort(i+1)-1), zoomf*cont_sort(1,punkt_indeks_sort(i):punkt_indeks_sort(i+1)-1), /device
;  if i eq n_elements(punkt_indeks_sort)-1 then plots, zoomf*cont_sort(0,punkt_indeks_sort(i):n_elements(cont_sort(2,*))-1), zoomf*cont_sort(1,punkt_indeks_sort(i):n_elements(cont_sort(2,*))-1), /device
;  wait,.1
;endfor
;;----------------------slutt visuell sjekk----------

;formaterer til uint med ny dose grid scaling
new_dose_skal=max(dp_inv)/65500.
new_dose_skal_o=max(dp_matr)/65500.
if pixel_rep eq 0 then begin
  dp_inv=uint(dp_inv/new_dose_skal)
  dp_matr=uint(dp_matr/new_dose_skal_o)
endif

end
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