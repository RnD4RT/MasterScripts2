N = 250

matr = make_array(N, N, N)
j = 0

p = N/5.


for i = (N/2.) - round(p), (N/2.) + round(p) do begin
  for j = (N/2.) - round(p), (N/2.) + round(p) do begin
    matr[i, j, (N/2.) - round(p) :  (N/2.) + round(p)] = 1
  endfor
endfor

im = image(matr[*,*, round(N/2.)])


p = p + 0.5

matrS = shift(matr, p, p, p)
matrT = transform_volume(matr, translate = [-p, -p, -p])
imS = image(matrS[*,*, N/2.] + 10, title = "Shift")
imT = image(matrT[*,*,N/2.] + 10, title = "Transform Volume")

;Tanke: Shift trenger heltall og bruker round dersom det ikke går. Transform Volume gjør en interpolasjon dersom det er overlapp
;Tillegg: Flytter man ting ut av bildet fyller Transform Volume på med svart (alltid?) mens Shift skyver det inn fra motsatt retning. Altså, shift behandler matrisen
; som en torus mens Transform Volume behandler det som en flate.
;Min konklusjon: Transform Volume er den beste å bruke ettersom vi har såpass grov pet at å flytte under 3 mm uten å interpolere bare gir trøbbel. Dette forklarer
;også hvorfor shift gav så stort sentrum med lik verdi på konturplot da den vil rounde av til samme verdi for alt under 3mm/2mm i x,y/z.
;Tillegg: Transform Volume og Shift forflytter motsatt av hverandre i xy-planet. Muligens også i Z, dette må sjekkes. 
;Shift flytter intuitivt, altså positiv x, y = forflyttning opp og mot høyre.
end