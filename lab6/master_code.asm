#include <p12f675.inc>
processor 12F675

#include <p12f675.inc>
processor 12F675

RP0 EQU 5
GP0 EQU 0
GP1 EQU 1
GP2 EQU 2
GP3 EQU 3
GP4 EQU 4
GP5 EQU 5
GPIE EQU 3
GIE EQU 7
GPIF EQU 0

FROM_THIS equ 0

MODE  EQU 0x30
DEST  EQU 0x28
VALUE EQU 0x29
THIS_ADDRESS EQU .0
TMP  EQU 0x27
BYTE EQU 0X20
TX_COUNT EQU 0X21
TBYTE EQU 0X22
SCOUNT EQU 0X23
RX_COUNT EQU 0X24
RBYTE EQU 0X25
FLUG EQU 0X26

ORG 0X00
	    GOTO START
ORG 0X04
	    BTFSC INTCON,GPIF
	    GOTO INTER_0
	    RETFIE
	  
ORG 0XFF
START
	    BCF STATUS, RP0
	    BSF GPIO,GP0
	    BSF INTCON,GPIE
	    BSF INTCON,GIE
	    MOVLW 0X07
	    MOVWF CMCON
	    MOVLW 0X00
	    MOVWF DEST
	    MOVWF VALUE
	    BSF STATUS, RP0
	    BCF TRISIO, GP0
	    BSF TRISIO, GP1
	    BCF TRISIO, GP2
	    BCF TRISIO, GP4
	    BSF TRISIO, GP5
	    CLRF IOCB
	    BSF IOCB, GP1
	    BSF IOCB, GP5
	    MOVLW 0
	    MOVWF ANSEL
	    MOVWF RBYTE
	    MOVWF TBYTE
	    BCF STATUS, RP0
	    GOTO $
IncValue
      incf VALUE
      movlw .15
      andwf VALUE, F 
      return
IncAddress
      incf DEST
      movf DEST, W
      xorlw .5
      btfsc STATUS, Z 
      clrf DEST
      return
   
	    
TRANSMIT 
            MOVLW  .8
            MOVWF  TX_COUNT
	    ;MOVF  RBYTE,W
	    call IncValue
	    call IncAddress
	    call PrepareToTransmit
	    movf DEST, W
	    xorwf THIS_ADDRESS, W
	    btfsc STATUS, Z
	    return
	    BCF GPIO,GP0          
NEXT_TX     
	    CALL   DELAY
            BTFSS  TBYTE,0          
            GOTO   ZERO             
            BSF    GPIO,GP0          
            GOTO   ONE
ZERO       
	    bcf    GPIO,GP0          
ONE         
	    RRF    TBYTE,F          
            DECFSZ TX_COUNT,F       
            GOTO   NEXT_TX          
            CALL   DELAY            
            BSF    GPIO,GP0          
            CALL   DELAY          
            CLRF   TBYTE            
	    
DELAY      
	    MOVLW .8
            MOVWF SCOUNT
NEXT       
	    NOP
	    NOP
            DECFSZ SCOUNT,1
            GOTO NEXT
            RETURN
INTER_0
	    bsf MODE, FROM_THIS
	    BCF INTCON,GPIF
	    BTFSS GPIO,GP1
	    CALL TRANSMIT
	    BTFSS GPIO,GP5
	    CALL RECIEVE
JMP_1
	    BTFSS GPIO,GP1
	    GOTO JMP_1
RET_FI
	    BCF INTCON,GPIF
	    RETFIE
	    
RECIEVE   
	    NOP
	    NOP
	    NOP
	    MOVLW .8
	    MOVWF RX_COUNT 
NEXT_RX    
	    CALL  DELAY             
            BCF   STATUS,0          
            RRF   RBYTE,F          
            BTFSC GPIO,GP5          
            BSF   RBYTE,7           
            DECFSZ RX_COUNT,F      
            GOTO  NEXT_RX           
            CALL  DELAY
	    CALL  CHECK_ADDRESS
            RETURN

CHECK_ADDRESS
      MOVF  RBYTE , W
      MOVWF TMP
      RRF   TMP
      RRF   TMP
      RRF   TMP
      RRF   TMP
      MOVF  TMP,  W
      ANDLW .15
      XORLW THIS_ADDRESS
      BTFSC STATUS, Z
      GOTO PRINT_RECIEVED
      bcf MODE, FROM_THIS
      movf  TMP, W
      movwf DEST
      decf  DEST
      movf  RBYTE, W
      andlw .15
      movwf VALUE
      decf  VALUE
      call TRANSMIT
      RETURN
      PRINT_RECIEVED
	 movf  RBYTE,W
	 iorlw .240
	 movwf BYTE
	 call PRINT_BYTE
	 return
PrepareToTransmit
      ;MOVF VALUE, W
      ;MOVWF TBYTE
      movf  DEST , W
      movwf TMP
      rlf   TMP
      rlf   TMP
      rlf   TMP
      rlf   TMP
      movf  TMP,  W
      andlw .240
      addwf VALUE, W
      movwf TBYTE
      movwf BYTE
      btfsc MODE, FROM_THIS 
      call PRINT_BYTE
      return

PRINT_BYTE 
	    	    BCF STATUS,C
	    MOVLW .8
	    MOVWF SCOUNT
SSSS
	    DECF SCOUNT,F
	    RLF BYTE
	    BTFSC STATUS,C
	    GOTO P_1
	    BCF GPIO, GP2
	    BSF GPIO, GP4
	    BCF GPIO, GP4
	 
	    MOVF SCOUNT,W
	    BTFSS STATUS,Z
	    GOTO SSSS
	    RETURN
P_1
	    BSF GPIO, GP2
	    BSF GPIO, GP4
	    BCF GPIO, GP4
	    MOVF SCOUNT,W
	    BTFSS STATUS,Z
	    GOTO SSSS
	    RETURN
END
