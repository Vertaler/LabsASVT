$NOMOD51
$INCLUDE (80C52.MCU)




;====================================================================
; VARIABLES
;====================================================================
MODE	data	5h
UPD	data	6h
LIGH	data	7h
SHIMD	bit	20h.0
LIGHD	bit	21h.0
LIST	bit	22h.0
DISPLAY DATA P3
E BIT P1.0
W BIT P1.1
RS BIT P2.6
CS BIT P2.7
CNT DATA 48h
;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

ORG	0000H ; Reset Vector
jmp	Init

ORG	000BH ; Timer0 interrupt
clr	tf0
mov	th0,#03Ch
mov	tl0,#0A7h
ljmp	LightsOn



ORG	001BH ; Timer1 interrupt
clr	tf1
mov	th1,#03Ch
mov	tl1,#0A7h
djnz	UPD,IntEnd
mov	UPD,#0Ah
call	CheckLights
IntEnd:     
reti




;====================================================================
; CODE SEGMENT
;====================================================================

      org   0100h
Init:
      mov	p2,#0
      ;mov	p3,#0

      mov	MODE,#0
      mov	LIGH,#0Ah
      mov	UPD,#0Ah
      clr	LIGHD
      clr	LIST
      
      mov	th0,#0FFh
      mov	tl0,#040h
      mov	th1,#03Ch
      mov	tl1,#0A7h
      mov	tmod,#11h
      setb	et0
      setb	et1
      setb	ea
      setb	tcon.4
      setb	tcon.6
      call InitDisplay
      jmp	Start


Start:
      
      jmp	check1

      check1: ; Авария (p1.2)
	 jnb	p1.2,check2
	 clr	SHIMD
	 clr	p1.7
	 mov	MODE,#11111111b
	 setb	LIGHD
	 jmp	AGAIN

      check2: ; Парковка (p1.3)
	 jnb	p1.3,check3
	 setb	SHIMD
	 clr	LIGHD
	 mov	MODE,#11110011b
	 jmp	AGAIN

      check3: ; Задний ход (p1.4)
	 jnb	p1.4,check4
	 clr	SHIMD
	 clr	LIGHD
	 mov	MODE,#11110000b
	 jmp	AGAIN

      check4: ; Поворот налево (p1.5)
	 jnb	p1.5,check5
	 clr	SHIMD
	 clr	p1.7
	 mov	MODE,#11010101b
	 setb	LIGHD
	 jmp	AGAIN

      check5: ; Поворот направо (p1.6)
	 jnb	p1.6,default
	 clr	SHIMD
	 clr	p1.7
	 mov	MODE,#11101010b
	 setb	LIGHD
	 jmp	AGAIN

      default:
	 clr	SHIMD
	 clr	LIGHD
	 mov	MODE,#11000000b
	 mov    a, p2
	 anl    a, MODE
	 mov	p2,a 
	 setb	p1.7
	 setb	p1.0
	 setb	p1.1
	 jmp	AGAIN

   AGAIN:
      ;mov p3,#0
      jmp Start



  CheckLights:
      mov A,p0
      cpl A
      anl A,#01111110b
      jnz CheckLights_check1      
         call ResetDisplay
	 jmp CheckLights_ret
	 CheckLights_check1:
	    
	    mov a,p0
	    cpl a
	    anl a,#00000010b
	    anl a, MODE
	    jz NeedReset1
	    call Set1
	    jmp CheckLights_check2
	    NeedReset1:
	       call Reset1
	 CheckLights_check2:
	    call Reset2
	    mov a,p0
	    cpl a
	    anl a,#00000100b
	    anl a, MODE
	    jz NeedReset2
	    call Set2
	    jmp CheckLights_check5
	    NeedReset2:
	       call Reset2

	 CheckLights_check5:
	    call Reset5
	    mov a,p0
	    cpl a
	    anl a,#00100000b
	    anl a, MODE
	    jz NeedReset5
	    call Set5
	    jmp CheckLights_check6
	    NeedReset5:
	       call Reset5

	 CheckLights_check6:
	    call Reset6 
	    mov a,p0
	    cpl a
	    anl a,#01000000b
	    anl a, MODE
	    jz NeedReset6
	    call Set6
	    jmp CheckLights_ret
	    NeedReset6:
	       call Reset6
      CheckLights_ret:
         call Redraw
	 ret

LightsOn:
      ;call	CheckLights
      jnb	LIGHD,lion
      
      djnz	LIGH,ExitLights
      mov	LIGH,#0Ah
      mov	c,LIST
      jnc	lioff
      jmp	lion
   lioff:
      mov       a, p2
      anl       a, #11000000b
      mov       p2, a 
      jmp	liswitch
   lion:
      mov       a, MODE
      anl       a, #00111111b
      orl       a, p2 
      mov       p2, a 
      jb	LIGHD,liswitch
      jmp	ExitLights
   liswitch:
      cpl	LIST
      reti
      
   ExitLights:
      reti

InitDisplay:
     ;Start display
     mov DISPLAY, #00111111b
     clr CS
     clr W
     clr RS
     setb E
     clr E
     ;Set line
     mov DISPLAY, #10111011b
     clr W
     clr RS
     setb E
     clr E 
     ;Set column
     call ResetColumn
     call InitSpaces
     call ResetDisplay
     ret
  InitSpaces:
     mov 30h, #255
     mov 31h, #255
     mov 33h, #255
     mov 34h, #255
     mov 3Ah, #255
     mov 3Bh, #255
     mov 3Fh, #255
     mov 41h, #255
     mov 42h, #255
     ret
     ;1
  Set1:
     mov 32h, #0
     ret
     ;2
  Set2:   
     mov 35h, #00001110b
     mov 36h, #01101110b
     mov 37h, #01101110b
     mov 38h, #01101110b 
     mov 39h, #01100000b
     ret
     ;5
  Set5:  
     mov 3Ch, #01100000b
     mov 3Dh, #01101110b
     mov 3Eh, #01101110b
     mov 3Fh, #01101110b 
     mov 40h, #00001110b
     ret
  Set6:   
     mov 43h, #0
     mov 44h, #01101110b
     mov 45h, #01101110b
     mov 46h, #01101110b 
     mov 47h, #00001110b
     ret

Redraw:
     mov CNT, #30h
     call ResetColumn
     RedrawLoop:
      mov R0, CNT
      mov a, CNT
      mov a, @R0
      mov DISPLAY, @R0
      clr W
      setb RS
      setb E
      clr E
      inc CNT
      mov a, CNT
      cjne a, #48h, RedrawLoop
      ret
ResetColumn:
     mov DISPLAY, #01000000b
     clr W     
     clr RS
     setb E
     clr E
     ret
ResetDisplay:
   call Reset1
   call Reset2
   call Reset5
   call Reset6
   ret
      
Reset1:
   mov 32h, #255
   ret
Reset2:
   mov 35h, #255
   mov 36h, #255
   mov 37h, #255
   mov 38h, #255
   mov 39h, #255
   ret
Reset5:
   mov 3Ch, #255
   mov 3Dh, #255
   mov 3Eh, #255
   mov 3Fh, #255
   mov 40h, #255
   ret
Reset6:  
   mov 43h, #255
   mov 44h, #255
   mov 45h, #255
   mov 46h, #255 
   mov 47h, #255      
   ret

;====================================================================
      END
