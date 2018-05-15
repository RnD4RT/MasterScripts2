function use_rtss_test, file

;cont_pointr=fltarr(3)
read_rtss, file(0), struct
a=struct.structuresetroi
a=*a[0]
roi_num=a.roinum
roi_name=a.roiname

for i=0, n_elements(roi_num)-1 do begin
  print, roi_num(i), '  ', roi_name(i)
endfor
num = ''
READ, num, prompt = 'Skriv konturnr, mellomrom mellom tall dersom du vil velge flere elementer: ';velger struktur som skal hentes, for flere strukturer, bruk mellomrom.
;num = '23'
;num = '23 24'
numbers = uint(strsplit(num, /EXTRACT)); Tar tall fra NUM og lager en liste

roi_names = ptrarr(n_elements(numbers), /ALLOCATE_HEAP)
roi_numbers = ptrarr(n_elements(numbers), /ALLOCATE_HEAP)

for i=0, n_elements(roi_num) - 1 do begin
  for j=0, n_elements(numbers) - 1 do begin
    if roi_num[i] eq numbers[j] then begin
      *(roi_names[j]) = roi_name[i]
      *(roi_numbers[j]) = roi_num[i]
    endif
  endfor
endfor

a=struct.roicontourmodule
a=*a[0]
c=a.contours
o = 0

;new_matrix = ptrarr(n_elements(numbers))
cont_matrix = ptrarr(n_elements(numbers))
cont_sort_matrix = ptrarr(n_elements(numbers))
punkt_indeks_matrix = ptrarr(n_elements(numbers))

n = fltarr(1, n_elements(numbers))
o = fltarr(1, n_elements(numbers))
;n=long(0)

cont_pointr = make_array(n_elements(numbers), 5, /PTR)

for l=0, n_elements(numbers) - 1 do begin
  cur_num = numbers(l)
  
  p = long(0)
  ;henter ut koordinater til struktur-fil
  for i=0, n_elements(c)-1 do begin
    d=*c[i]
    e=d.data
    if fix(strcompress(e.(0), /REMOVE_ALL)) eq cur_num then begin
      for j=1, n_tags(e)-1 do begin
        f=e.(j)
        g=size(f)
        
        p = p + g(2)
        
        for k=0, g(2)-1 do begin
          
          n(l)=n(l)+1
        endfor
        
        
      endfor
      cont_matrix(l) = ptr_new(fltarr(3, p))
      cont_sort_matrix(l) = ptr_new(fltarr(3, p))
      punkt_indeks_matrix(l) = ptr_new(fltarr(1, n_tags(e)-1))
      
      o(l)= n_tags(e)-1
    endif
  endfor

endfor

;cont=fltarr(3*n_elements(numbers),max(n)) ;koord (x,y,z) n antall punkter totalt
;cont_sort=fltarr(3*n_elements(numbers),max(n))
;punkt_indeks=intarr(n_elements(numbers), max(o)) ;punkt_indeks(i)= indeksnr for først punkt i snitt i i listen cont



;n=long(0)


for l=0, n_elements(numbers)-1 do begin
  cur_num = numbers(l)
  n(l) = long(0)
  
  for i=0, n_elements(c)-1 do begin
    d=*c[i]
    e=d.data
    if fix(strcompress(e.(0), /REMOVE_ALL)) eq cur_num then begin
      p = long(0)
      for j=1, n_tags(e)-1 do begin
        f=e.(j)
        g=size(f)
        for k=0, g(2)-1 do begin
 
          ;(*(new_matrix[l]))[*,p++] = f(0:2, k)
          (*(cont_matrix[l]))[*, p++] = f(0:2, k)
          ;cont((l*3):(l*3)+2, n(l)) = f(0:2, k)
         
        endfor
        ;punkt_indeks(l, j-1)=g(2)
        (*(punkt_indeks_matrix[l]))[j-1] = g(2)
      endfor
    endif
  endfor

endfor

cont_pointr[*, 0] = cont_matrix ;ptr_new(cont_matrix)
cont_pointr[*, 1] = cont_sort_matrix ;ptr_new(cont_sort_matrix)
cont_pointr[*, 2] = punkt_indeks_matrix ;ptr_new(punkt_indeks_matrix)
cont_pointr[*, 3] = roi_names
cont_pointr[*, 4] = roi_numbers

;for i=0, n_elements(new_matrix) - 1 do ptr_free, new_matrix[i]
;for i=0, n_elements(cont_matrix) - 1 do ptr_free, cont_matrix[i]
;for i=0, n_elements(punkt_indeks_matrix) - 1 do ptr_free, punkt_indeks_matrix[i]

return, cont_pointr

end