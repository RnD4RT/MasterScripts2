function wcsv, qf, d_mean, TCPpointer, patient

;openw, 11, '../csv_data/tabeldata.csv'


;read in data
;the write back the same data except change for patient x
;

;fill_array = make_array(3, 44, /float, value = 0.0)

;fill_array = read_csv('../../csv_data/test1.csv')
fill_array = read_csv('C:\Users\Eirik\Dropbox\Universitet\Master\csv_data\test3.csv')

pat = uint((strsplit(patient, /EXTRACT))[-1])
if pat eq 11 then begin
  pat = 10
  print, "Pat 11 = Pat 10 now"
endif

TCP = make_array(7, /float, value = 0.0)
TCP[1:4] = [*(TCPpointer[0]), *(TCPpointer[1]), *(TCPpointer[2]), *(TCPpointer[3])];, *(TCPpointer[4]), *(TCPpointer[5])]
fill_array.field1[(pat-1)*4:(pat-1)*4+3] = qf[1:-1]     ;ph, ph_dpbn, p, p_dpbn
;fill_array.field1[(pat-1)*4+4] = qf[-1] - qf[-3]        ;p_dpbn - ph_dpbn
fill_array.field2[(pat-1)*4:(pat-1)*4+5] = TCP[1:-1]    ;ph, ph_dpbn, p, p_dpbn, presc, 68Gy
fill_array.field3[(pat-1)*4:(pat-1)*4+3] = D_mean

write_csv, 'C:\Users\Eirik\Dropbox\Universitet\Master\csv_data\test3.csv', fill_array

return, 0
end