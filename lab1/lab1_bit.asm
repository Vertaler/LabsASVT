ORG 0000H

; defines
q bit p2.0
v bit p3.3
y bit p1.2
z bit p2.7
d bit p3.7

x bit 20h.0
j bit 20h.4; c
k bit 22h.5; b
u bit 28h.0
tmp bit 20h.1

; initialization
clr x
clr j
clr k
clr u

;program
START:
mov c,x
anl c,v
mov tmp, c; tmp = x*v
mov c,y
orl c,z
cpl c
orl c, tmp
mov tmp, c; tmp = x*v + /y*/z
mov c, j
anl c, u
orl c, d
orl c, k
orl c, tmp
cpl c
mov q, c


END;
