#include <p12f675.inc>
processor 12F675

SH_CP    equ 1
DS       equ 0
ST_CP    equ 4

RP0  equ 5
GP0  equ 0
GP1  equ 1
GP2  equ 2
GP3  equ 3
GP4  equ 4
GP5  equ 5
GIE  equ 7
GPIE equ 3
GPIF equ 0
TOIE equ 5
TOIF equ 2
COUNT EQU 0X21
BYTE  EQU 0X22
TEMP  EQU 0X23
MAX   EQU .9
ORG 0x0000
	GOTO START
ORG 0X0004
	 
	banksel INTCON
	btfsc INTCON, GPIF
	goto InputInterupt
	bcf INTCON, GPIF
	bcf INTCON, TOIF 
	banksel TMR0
    DECF TMR0,F
	retfie
InputInterupt
      btfsc GPIO, GP5
      GOTO DEC
      retfie
DEC
      bcf INTCON, GPIF
	   
	  bcf STATUS, Z	
      banksel TMR0
	  MOVF  TMR0, W
	  MOVWF TEMP
	  xorlw .246
	  btfss STATUS, Z
	  DECF TMR0,F
      retfie

ORG 0X00FF
START
	BCF STATUS, RP0
	CLRF GPIO
	MOVLW 0X07
	MOVWF CMCON
	BSF STATUS, RP0
	bcf TRISIO, GP0
	bcf TRISIO, GP1
	bsf TRISIO, GP2
	bcf TRISIO, GP4
	bsf TRISIO, GP5
	
	movlw 0
	movwf ANSEL
	BCF STATUS, RP0
	banksel IOCB
	BSF IOCB,GP5
	banksel TMR0
	MOVLW .246
	MOVWF TMR0
	banksel OPTION_REG
	movlw b'11111111'
	movwf OPTION_REG 
	banksel INTCON
	bcf INTCON, TOIF
	bsf INTCON, TOIE
	bsf INTCON, GIE
	bsf INTCON, GPIE
	bCf INTCON, GPIF
	
	btfsc GPIO, GP5
	
A

	 MOVF  TMR0,W
	 MOVWF BYTE
	 MOVLW .246
	 SUBWF BYTE,F
	 CALL A_1
	 CALL SendByte
	 GOTO A
A_1
	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .0
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'00111111'
	 MOVWF BYTE
	 RETURN
	 
	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .1
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'00000110'
	 MOVWF BYTE
	 RETURN
	 
	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .2
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'01011011'
	 MOVWF BYTE
	 RETURN
	 
	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .3
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'01001111'
	 MOVWF BYTE
	 RETURN
	 
	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .4
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'01100110'
	 MOVWF BYTE
	 RETURN
	 
	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .5
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'01101101'
	 MOVWF BYTE
	 RETURN

	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .6
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'01111101'
	 MOVWF BYTE
	 RETURN

	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .7
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'00000111'
	 MOVWF BYTE
	 RETURN
	 
	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .8
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'01111111'
	 MOVWF BYTE
	 RETURN
	 
	 MOVF BYTE,W
	 MOVWF TEMP
	 XORLW .9
	 BTFSS STATUS,Z
	 GOTO $+4
	 MOVLW B'01101111'
	 MOVWF BYTE
	 RETURN

SendByte
	 bcf    STATUS,C
	 movlw  .8
	 movwf  COUNT
	 SendLoop
		decf   COUNT,  F
		rlf    BYTE
		btfsc  STATUS, C
		goto   Send1
	 Send0
		bcf    GPIO,   DS
		call   ConfirmBit
		goto   CheckCount
	 Send1
		bsf   GPIO, DS
		call  ConfirmBit
		goto  CheckCount
	 CheckCount
		movf  COUNT,W
		btfss STATUS,Z
		goto  SendLoop
		call  ConfirmSending
		return
	ConfirmBit
		bsf GPIO, SH_CP
		bcf GPIO, SH_CP
		return
	ConfirmSending
		bsf GPIO, ST_CP
		bcf GPIO, ST_CP
		return
END