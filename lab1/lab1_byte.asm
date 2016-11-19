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

qq equ 20h
vv equ 21h
uu equ 22h
zz equ 23h
dd equ 24h
xx equ 25h
jj equ 26h
kk equ 27h
yy equ 28h
tmp equ 29h
; initialization
clr x
clr j
clr k
clr u

mov c, q
mov qq.0, c
mov c, v
mov vv.0, c
mov c, u
mov uu.0, c
mov c, z
mov zz.0, c
mov c, d
mov dd.0, c
mov c, x
mov xx.0, c
mov c, j
mov jj.0, c
mov c, k
mov kk.0, c
mov c, y
mov yy.0, c

;program
START:
mov a,xx
anl a,vv
mov tmp, a; tmp = x*v
mov a,yy
orl a,zz
cpl a
orl a, tmp
mov tmp, a; tmp = x*v + /y*/z
mov a, jj
anl a, uu
orl a, dd
orl a, kk
orl a, tmp
mov qq, a
mov c, qq.0
mov q, c

END;
