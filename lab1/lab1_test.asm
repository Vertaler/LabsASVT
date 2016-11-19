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


; initialization
clr x
clr j
clr k
clr u

;program
START:
jnb x, TEST_Y
jb v, SET_Q
TEST_Y:
jb y, TEST_K
jnb z, SET_Q
TEST_K:
jb k, SET_Q
jnb j, TEST_D
jb u, SET_Q
TEST_D:
jb d, SET_Q
setb q
jmp START
SET_Q:
clr q
END;
