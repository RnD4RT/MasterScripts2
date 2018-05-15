function use_rtss, file

cont_pointr=ptrarr(3)
read_rtss, file(0), struct
a=struct.structuresetroi
a=*a[0]
roi_num=a.roinum
roi_name=a.roiname

for i=0, n_elements(roi_num)-1 do begin
  print, roi_num(i), '  ', roi_name(i)
endfor
READ, num, prompt = 'Skriv konturnr: ';velger struktur som skal hentes
a=struct.roicontourmodule
a=*a[0]
c=a.contours
;henter ut koordinater til struktur-fil
n=long(0)
for i=0, n_elements(c)-1 do begin
  d=*c[i]
  e=d.data
  if fix(strcompress(e.(0), /REMOVE_ALL)) eq num then begin
    for j=1, n_tags(e)-1 do begin
      f=e.(j)
      g=size(f)
      for k=0, g(2)-1 do begin
        n=n+1
      endfor
    endfor
    o=n_tags(e)-1
  endif
endfor

cont=fltarr(3,n) ;koord (x,y,z) n antall punkter totalt
cont_sort=fltarr(3,n)
punkt_indeks=intarr(o) ;punkt_indeks(i)= indeksnr for først punkt i snitt i i listen cont
n=long(0)
for i=0, n_elements(c)-1 do begin
  d=*c[i]
  e=d.data
  if fix(strcompress(e.(0), /REMOVE_ALL)) eq num then begin
    for j=1, n_tags(e)-1 do begin
      f=e.(j)
      g=size(f)
      for k=0, g(2)-1 do begin
        cont(0:2,n)=f(0:2, k)
        n=n+1
      endfor
      punkt_indeks(j-1)=g(2)
    endfor
  endif
endfor

cont_pointr(0)=ptr_new(cont)
cont_pointr(1)=ptr_new(cont_sort)
cont_pointr(2)=ptr_new(punkt_indeks)
return, cont_pointr
end