#make_bin#

.MODEL TINY 
.DATA 
 
;8253 USED TO GENERATE CLOCK FOR ADC 
 
CNT0 EQU 20H 
CREG EQU 26H 
 
;8255(1)  INITIALISE 
PORT1A EQU 00H  ;CONTROLLING THE LCD 
PORT1B EQU 02H  ;INPUT TO LCD 
PORT1C EQU 04H  ;UPPER - ROW 
                 ;LOWER - COLUMN 
CREG1 EQU 06H 
 
;8255(2) USED FOR ADC, ALARM AND SWITCH 
 
PORT2A EQU 10H  ;INPUT TO DI DEVICE 
PORT2B EQU 12H  ;ADC 
PORT2C EQU 14H  ;PC1 - SOC OF ADC 
;PC2 - ALARM 
;PC3 - ADDC OF ADC (USED FOR SELECTING THE ;FIRST INPUT CHANNEL OF ADC) 
;PC5 - EOC OF ADC 
CREG2 EQU 16H 
 
TABLE_K DB 0EEH,0EDH,0EBH,0E7H,0DEH,0DDH,0DBH,0D7H,0BEH,0BDH,0BBH,0B7H,07EH,07DH,07BH,077H 
DAT2 DB 3 DUP(" "); 
 
.CODE 
.STARTUP 
 
MOV AL,00010110B ;INITIALIZING 8253 
OUT CREG,AL 
MOV AL,5 
OUT CNT0,AL 
 
MOV AL,10001000B ;INITIALIZING 8255(1) 
OUT CREG1,AL 
CALL DELAY_2MS 
 
MOV AL,10001010B ;INITIALIZING 8255(2) 
OUT CREG2,AL 
CALL DELAY_2MS 
 
CALL KEYPAD 
CALL SEND_VOLTAGE 
CALL GET_VOLTAGE_DROP 
CALL HFE  
MOV AX,123H 
X1:   PUSH AX 
   CMP AX,0032H 
   JA PRINT 
   MOV AL,05H 
   OUT CREG2,AL 
   POP AX 
PRINT : CALL LCD_INIT ;CALLING LCD INITIALIZATION 
 CALL WRITE_EMPTY; 
 CALL DELAY  
 CALL DELAY 
 CALL DELAY 
 CALL DISP_DIG 
  
  
 .EXIT 
 
;PROCEDURE FOR TAKING INPUT FROM KEYPAD 
KEYPAD PROC NEAR 
KX0: MOV AL,00H ;CHECK FOR KEY RELEASE 
OUT PORT1C,AL 
CALL DELAY_2MS 
KX1: IN AL,PORT1C 
AND AL,0F0H 
CMP AL,0F0H 
JNZ KX1 
CALL DELAY_22 ;DEBOUNCE 
MOV AL,00H ;CHECK FOR KEY PRESS 
OUT PORT1C,AL 
CALL DELAY_L 
KX2:IN AL,PORT1C 
AND AL,0F0H 
CMP AL,0F0H 
JZ KX2 
MOV AL,0EH ;CHECK FOR KEY PRESS COLUMN1 
MOV BL,AL 
OUT PORT1C,AL 
CALL DELAY_L 
IN AL,PORT1C 
AND AL,0F0H 
CMP AL,0F0H 
JNZ KX3 
MOV AL,0DH ;CHECK FOR KEY PRESS COLUMN2 
MOV BL,AL 
OUT PORT1C,AL 
CALL DELAY_L 
IN AL,PORT1C 
AND AL,0F0H 
CMP AL,0F0H 
JNZ KX3 
MOV AL,0BH ;CHECK FOR KEY PRESS COLUMN3 
MOV BL,AL 
OUT PORT1C,AL 
CALL DELAY_L 
IN AL,PORT1C 
AND AL,0F0H 
CMP AL,0F0H 
JNZ KX3 
MOV AL,07H ;CHECK FOR KEY PRESS COLUMN4 
MOV BL,AL 
OUT PORT1C,AL 
CALL DELAY_L 
IN AL,PORT1C 
AND AL,0F0H 
CMP AL,0F0H 
JNZ KX3 
KX3:OR AL,BL ;DECODE KEY 
MOV CX,0FH 
MOV DI,00H 
KX4:CMP AL,TABLE_K[DI] 
JZ X5 
INC DI 
LOOP KX4 
X5: 
CMP DI,0DH 
JNZ XN1 
MOV CH,0 
JMP XN6 
XN1:CMP DI,8 
JNZ XN2 
MOV CH,1 
JMP XN6 
XN2:CMP DI,9 
JNZ XN3 
MOV CH,2 
JMP XN6 
XN3:CMP DI,0AH 
JNZ XN4 
MOV CH,3 
JMP XN6 
XN4:CMP DI,4 
JNZ XN5 
MOV CH,4 
JMP XN6 
XN5:CMP DI,5 
MOV CH,5 
XN6: 
RET 
KEYPAD ENDP 
;PROCEDURE FOR SENDING VOLTAGE TO DI DEVICE 
SEND_VOLTAGE PROC NEAR 
CMP CH,0 
JNZ V1 
MOV AL,1 
OUT PORT2A,AL 
CALL DELAY_L ;INPUTS 1ST VOLTAGE TO DI DEVICE 
JMP END5 
V1: 
CMP CH,1 
JNZ V2 
MOV AL,2 ;INPUTS 2ND VOLTAGE TO DI DEVICE 
OUT PORT2A,AL 
CALL DELAY_L 
JMP END5 
V2: 
CMP CH,2 
JNZ V3 
MOV AL,4 ;INPUTS 3RD VOLTAGE TO DI DEVICE 
OUT PORT2A,AL 
CALL DELAY_L 
JMP END5 
V3: 
CMP CH,3 
JNZ V4 
MOV AL,8 ;INPUTS 4TH VOLTAGE TO DI DEVICE 
OUT PORT2A,AL 
CALL DELAY_L 
JMP END5 
V4: 
CMP CH,4 
JNZ V5 
MOV AL,10H ;INPUTS 5TH VOLTAGE TO DI DEVICE 
OUT PORT2A,AL 
CALL DELAY_L 
JMP END5 
V5: 
MOV AL,20H ;INPUTS 6TH VOLTAGE TO DI DEVICE 
OUT PORT2A,AL 
CALL DELAY_L 
END5: 
RET 
SEND_VOLTAGE ENDP 
 
;PROCEDURE FOR GETTING THE VOLTAGE DROP ACROSS THE RESISTANCE 
GET_VOLTAGE_DROP PROC NEAR 
MOV AL,06H ;GIVE ADC  
OUT CREG2,AL 
 
MOV AL,00H ;GIVE ALE 
OUT CREG2,AL 
 
MOV AL,02H ;GIVE SOC 
OUT CREG2,AL 
NOP  
NOP 
NOP 
NOP 
 
MOV AL,01H 
OUT CREG2,AL 
 
MOV AL,03H 
OUT CREG2,AL 
NOP 
NOP 
NOP 
NOP 
 
MOV AL,02H ;GIVE SOC 
OUT CREG2,AL 
NOP  
NOP 
NOP 
NOP 
 
MOV AL,00H ;GIVE ALE 
OUT CREG2,AL 
 
LOOP2: 
IN AL,PORT2C 
CALL DELAY_2MS 
AND AL,20H ;CHECK FOR EOC 
CMP AL,20H 
JNZ LOOP2 
CALL DELAY_2MS 
IN AL,PORT2B ;AL HAS THE VOLTAGE DROP ACROSS THE RESISTOR 
MOV AH,00H 
RET 
GET_VOLTAGE_DROP ENDP 
 
;PROCEDURE TO CALCULATE HFE 
HFE PROC NEAR 
CMP CH,0 
JNZ H1 
MOV BL,0B6H ;CORRESPONDING TO INPUT VOLTAGE = 0.025V 
JMP VAL1 
H1: 
CMP CH,1 
JNZ H2 
MOV BL,5BH ;CORRESPONDING TO INPUT VOLTAGE = 0.05V 
JMP VAL2 
H2: 
CMP CH,2 
JNZ H3 
MOV BL,49H ;CORRESPONDING TO INPUT VOLTAGE = 0.0625V 
JMP VAL3 
H3: 
CMP CH,3 
JNZ H4 
MOV BL,3DH ;CORRESPONDING TO INPUT VOLTAGE = 0.075V 
JMP VAL4 
H4: 
CMP CH,4 
JNZ H5 
MOV BL,34H ;CORRESPONDING TO INPUT VOLTAGE = 0.0875 
JMP VAL5 
H5: 
MOV BL,2DH ;CORRESPONDING TO INPUT VOLTAGE = 0.1V 
JMP VAL6 
VAL1: 
MUL BL ;AX NOW CONTAINS THE VALUE OF HFE 
JMP END1 
VAL2: 
MUL BL 
JMP END1 
VAL3: 
MUL BL 
JMP END1 
VAL4: 
MUL BL 
JMP END1 
VAL5: 
MUL BL 
JMP END1 
VAL6: 
MUL BL 
JMP END1 
END1: 
RET 
HFE ENDP 
 
LCD_INIT PROC NEAR 
 MOV AL, 38H ;INITIALIZE LCD FOR 2 LINES & 5*7 MATRIX 
 CALL COMNDWRT ;WRITE THE COMMAND TO LCD 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT COMMAND 
 CALL DELAY ;THIS COMMAND NEEDS LOTS OF DELAY 
 CALL DELAY 
 MOV AL, 0EH ;SEND COMMAND FOR LCD ON, CURSOR ON  
 CALL COMNDWRT 
 CALL DELAY 
 MOV AL, 01  ;CLEAR LCD 
 CALL COMNDWRT  
 CALL DELAY 
 MOV AL, 06  ;COMMAND FOR SHIFTING CURSOR RIGHT 
 CALL COMNDWRT 
 CALL DELAY 
 RET 
LCD_INIT ENDP 
 
CLS PROC  
 MOV AL, 01  ;CLEAR LCD 
 CALL COMNDWRT 
 CALL DELAY 
 CALL DELAY 
 RET 
CLS ENDP 
COMNDWRT PROC ;THIS PROCEDURE WRITES COMMANDS TO LCD 
 MOV DX, PORT1B 
 OUT DX, AL  ;SEND THE CODE TO PORT A 
 MOV DX, PORT1A   
 MOV AL, 00000100B ;RS=0,R/W=0,E=1 FOR H-TO-L PULSE 
 OUT DX, AL 
 NOP 
 NOP  
 MOV AL, 00000000B ;RS=0,R/W=0,E=0 FOR H-TO-L PULSE 
 OUT DX, AL 
 RET 
COMNDWRT ENDP 
 
WRITE_EMPTY PROC NEAR 
 CALL CLS 
 MOV AL, 'E' ;DISPLAY �E� LETTER 
 CALL DATWRIT ;ISSUE IT TO LCD 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT CHARACTER 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT CHARACTER 
 MOV AL, 'M' ;DISPLAY �M� LETTER 
 CALL DATWRIT ;ISSUE IT TO LCD 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT CHARACTER 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT CHARACTER 
 MOV AL, 'P' ;DISPLAY �P� LETTER 
 CALL DATWRIT ;ISSUE IT TO LCD 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT CHARACTER 
 CALL DELAY ;WAIT 
 MOV AL, 'T' ;DISPLAY �T� LETTER 
 CALL DATWRIT ;ISSUE IT TO LCD 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT CHARACTER 
 CALL DELAY ;WAIT 
 MOV AL, 'Y' ;DISPLAY �Y� LETTER 
 CALL DATWRIT ;ISSUE IT TO LCD 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT CHARACTER 
 CALL DELAY ;WAIT 
 RET 
WRITE_EMPTY ENDP 
 
DATWRIT PROC 
 PUSH DX  ;SAVE DX 
 MOV DX,PORT1B  ;DX=PORT A ADDRESS 
 OUT DX, AL ;ISSUE THE CHAR TO LCD 
 MOV AL, 00000101B ;RS=1, R/W=0, E=1 FOR H-TO-L PULSE 
 MOV DX, PORT1A ;PORT B ADDRESS 
 OUT DX, AL  ;MAKE ENABLE HIGH 
 MOV AL, 00000001B ;RS=1,R/W=0 AND E=0 FOR H-TO-L PULSE 
 OUT DX, AL 
 POP DX 
 RET 
DATWRIT ENDP ;WRITING ON THE LCD ENDS  
 
DISP_DIG PROC NEAR 
   
 
  LEA DI,DAT2 
   
  MOV BX,100D   
  MOV DX,0 
  IDIV BX 
  MOV BL,AL 
  ADD BL,30H 
  MOV [DI],BL 
  INC DI 
   
  MOV AX,DX 
  MOV BX,10D   
  MOV DX,0 
  IDIV BX 
  MOV BL,AL 
  ADD BL,30H 
  MOV [DI],BL 
  INC DI 
   
  MOV AX,DX 
  MOV BL,AL   
  ADD BL,30H 
  MOV [DI],BL 
   
   
  CALL WRITE_MEM ;CALLING WRITE_MEM SO THAT THE WRITE OPERATION CAN BE PERFORMED 
   
 
LAST:  
  RET ;RETURN STATEMENT TO RETURN BACK 
DISP_DIG ENDP ;END OF DISPLAY OF LCD 
 
WRITE_MEM PROC NEAR  
 LEA DI,DAT2 
 CALL CLS 
 MOV CX,0003H 
 ;MOV CL,4 
 ;MOV CH,0 
 MOV SI,CX 
X10:MOV AL, [DI]  
 CALL DATWRIT ;ISSUE IT TO LCD 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT CHARACTER 
 CALL DELAY ;WAIT BEFORE ISSUING THE NEXT CHARACTER 
 INC DI 
 ;INT 3H 
 DEC SI 
 JNZ X10  
 INT 3H 
 RET 
WRITE_MEM ENDP  
 
 
 
 
;DELAY IN THE CIRCUIT HERE THE DELAY OF 20 MILLISECOND IS PRODUCED 
DELAY PROC 
 MOV CX, 1325 ;1325*15.085 USEC = 20 MSEC 
 W1:  
  NOP 
  NOP 
  NOP 
  NOP 
  NOP 
 LOOP W1 
 RET 
DELAY ENDP 
 
  
;DELAY PROCEDURE 
DELAY_22 PROC NEAR 
MOV CX,22 
X: 
NOP 
NOP 
LOOP X 
RET 
DELAY_22 ENDP 
 
 
DELAY_2MS PROC NEAR 
MOV CX,100 
HER: NOP 
 LOOP HER 
RET 
DELAY_2MS ENDP 
DELAY_3MS PROC NEAR 
MOV CX,225 
HER1: NOP 
 LOOP HER1 
RET 
DELAY_3MS ENDP 
DELAY_L PROC NEAR 
MOV CX,250 
HER2: NOP 
 LOOP HER2 
RET 
DELAY_L ENDP 
DELAY_S PROC NEAR 
MOV CX,1050 
HER3: NOP 
 LOOP HER3 
RET 
DELAY_S ENDP 
DELAY_T PROC NEAR 
MOV CX,8000 
HER4: NOP 
 LOOP HER4 
RET 
DELAY_T ENDP 
END 
