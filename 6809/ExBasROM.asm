                               
UART      EQU  $A000           
RECEV     EQU  UART+1          
TRANS     EQU  UART+1          
USTAT     EQU  UART            
UCTRL     EQU  UART            
                               
BS        EQU  8              BACKSPACE 
CR        EQU  $D             ENTER KEY 
ESC       EQU  $1B            ESCAPE CODE 
SPACE     EQU  $20            SPACE (BLANK) 
STKBUF    EQU  58             STACK BUFFER ROOM 
LBUFMX    EQU  250            MAX NUMBER OF CHARS IN A BASIC LINE 
MAXLIN    EQU  $FA            MAXIMUM MS BYTE OF LINE NUMBER 
* PSEUDO OPS                      
SKP1      EQU  $21            OP CODE OF BRN — SKIP ONE BYTE 
SKP2      EQU  $8C            OP CODE OF CMPX # - SKIP TWO BYTES 
SKP1LD    EQU  $86            OP CODE OF LDA # - SKIP THE NEXT BYTE 
*                             AND LOAD THE VALUE OF THAT BYTE INTO ACCA — THIS 
*                             IS USUALLY USED TO LOAD ACCA WITH A NON ZERO VALUE 
RTS_LOW   EQU  $95             
          ORG  0               
ENDFLG    RMB  1              STOP/END FLAG: POSITIVE=STOP, NEG=END 
CHARAC    RMB  1              TERMINATOR FLAG 1 
ENDCHR    RMB  1              TERMINATOR FLAG 2 
TMPLOC    RMB  1              SCRATCH VARIABLE 
IFCTR     RMB  1              IF COUNTER - HOW MANY IF STATEMENTS IN A LINE 
DIMFLG    RMB  1              *DV* ARRAY FLAG 0=EVALUATE, 1=DIMENSIONING 
VALTYP    RMB  1              *DV* *PV TYPE FLAG: 0=NUMERIC, $FF=STRING 
GARBFL    RMB  1              *TV STRING SPACE HOUSEKEEPING FLAG 
ARYDIS    RMB  1              DISABLE ARRAY SEARCH: 00=ALLOW SEARCH 
INPFLG    RMB  1              *TV INPUT FLAG: READ=0, INPUT<>0 
RELFLG    RMB  1              *TV RELATIONAL OPERATOR FLAG 
TEMPPT    RMB  2              *PV TEMPORARY STRING STACK POINTER 
LASTPT    RMB  2              *PV ADDR OF LAST USED STRING STACK ADDRESS 
TEMPTR    RMB  2              TEMPORARY POINTER 
TMPTR1    RMB  2              TEMPORARY DESCRIPTOR STORAGE (STACK SEARCH) 
FPA2      RMB  4              FLOATING POINT ACCUMULATOR #2 MANTISSA 
BOTSTK    RMB  2              BOTTOM OF STACK AT LAST CHECK 
TXTTAB    RMB  2              *PV BEGINNING OF BASIC PROGRAM 
VARTAB    RMB  2              *PV START OF VARIABLES 
ARYTAB    RMB  2              *PV START OF ARRAYS 
ARYEND    RMB  2              *PV END OF ARRAYS (+1) 
FRETOP    RMB  2              *PV START OF STRING STORAGE (TOP OF FREE RAM) 
STRTAB    RMB  2              *PV START OF STRING VARIABLES 
FRESPC    RMB  2              UTILITY STRING POINTER 
MEMSIZ    RMB  2              *PV TOP OF STRING SPACE 
OLDTXT    RMB  2              SAVED LINE NUMBER DURING A "STOP" 
BINVAL    RMB  2              BINARY VALUE OF A CONVERTED LINE NUMBER 
OLDPTR    RMB  2              SAVED INPUT PTR DURING A "STOP" 
TINPTR    RMB  2              TEMPORARY INPUT POINTER STORAGE 
DATTXT    RMB  2              *PV 'DATA' STATEMENT LINE NUMBER POINTER 
DATPTR    RMB  2              *PV 'DATA' STATEMENT ADDRESS POINTER 
DATTMP    RMB  2              DATA POINTER FOR 'INPUT' & 'READ' 
VARNAM    RMB  2              *TV TEMP STORAGE FOR A VARIABLE NAME 
VARPTR    RMB  2              *TV POINTER TO A VARIABLE DESCRIPTOR 
VARDES    RMB  2              TEMP POINTER TO A VARIABLE DESCRIPTOR 
RELPTR    RMB  2              POINTER TO RELATIONAL OPERATOR PROCESSING ROUTINE 
TRELFL    RMB  1              TEMPORARY RELATIONAL OPERATOR FLAG BYTE 
* FLOATING POINT ACCUMULATORS #3,4 & 5 ARE MOSTLY                      
* USED AS SCRATCH PAD VARIABLES.                      
** FLOATING POINT ACCUMULATOR #3 :PACKED: ($40-$44)                      
V40       RMB  1               
V41       RMB  1               
V42       RMB  1               
V43       RMB  1               
V44       RMB  1               
** FLOATING POINT ACCUMULATOR #4 :PACKED: ($45-$49)                      
V45       RMB  1               
V46       RMB  1               
V47       RMB  1               
V48       RMB  2               
** FLOATING POINT ACCUMULATOR #5 :PACKED: ($4A—$4E)                      
V4A       RMB  1               
V4B       RMB  2               
V4D       RMB  2               
** FLOATING POINT ACCUMULATOR #0                      
FP0EXP    RMB  1              *PV FLOATING POINT ACCUMULATOR #0 EXPONENT 
FPA0      RMB  4              *PV FLOATING POINT ACCUMULATOR #0 MANTISSA 
FP0SGN    RMB  1              *PV FLOATING POINT ACCUMULATOR #0 SIGN 
COEFCT    RMB  1              POLYNOMIAL COEFFICIENT COUNTER 
STRDES    RMB  5              TEMPORARY STRING DESCRIPTOR 
FPCARY    RMB  1              FLOATING POINT CARRY BYTE 
** FLOATING POINT ACCUMULATOR #1                      
FP1EXP    RMB  1              *PV FLOATING POINT ACCUMULATOR #1 EXPONENT 
FPA1      RMB  4              *PV FLOATING POINT ACCUMULATOR #1 MANTISSA 
FP1SGN    RMB  1              *PV FLOATING POINT ACCUMULATOR #1 SIGN 
RESSGN    RMB  1              SIGN OF RESULT OF FLOATING POINT OPERATION 
FPSBYT    RMB  1              FLOATING POINT SUB BYTE (FIFTH BYTE) 
COEFPT    RMB  2              POLYNOMIAL COEFFICIENT POINTER 
LSTTXT    RMB  2              CURRENT LINE POINTER DURING LIST 
CURLIN    RMB  2              *PV CURRENT LINE # OF BASIC PROGRAM, $FFFF = DIRECT 
DEVCFW    RMB  1              *TV TAB FIELD WIDTH 
DEVLCF    RMB  1              *TV TAB ZONE 
DEVPOS    RMB  1              *TV PRINT POSITION 
DEVWID    RMB  1              *TV PRINT WIDTH 
RSTFLG    RMB  1              *PV WARM START FLAG: $55=WARM, OTHER=COLD 
RSTVEC    RMB  2              *PV WARM START VECTOR - JUMP ADDRESS FOR WARM START 
TOPRAM    RMB  2              *PV TOP OF RAM 
IKEYIM    RMB  1              *TV INKEY$ RAM IMAGE 
ZERO      RMB  2              *PV DUMMY - THESE TWO BYTES ARE ALWAYS ZERO 
* THE FOLLOWING BYTES ARE MOVED DOWN FROM ROM                      
LPTCFW    RMB  1              16 
LPTLCF    RMB  1              112 
LPTWID    RMB  1              132 
LPTPOS    RMB  1              0 
EXECJP    RMB  2              LB4AA 
                               
* THIS ROUTINE PICKS UP THE NEXT INPUT CHARACTER FROM                      
* BASIC. THE ADDRESS OF THE NEXT BASIC BYTE TO BE                      
* INTERPRETED IS STORED AT CHARAD.                      
GETNCH    INC  <CHARAD+1      *PV INCREMENT LS BYTE OF INPUT POINTER 
          BNE  GETCCH         *PV BRANCH IF NOT ZERO (NO CARRY) 
          INC  <CHARAD        *PV INCREMENT MS BYTE OF INPUT POINTER 
GETCCH    FCB  $B6            *PV OP CODE OF LDA EXTENDED 
CHARAD    RMB  2              *PV THESE 2 BYTES CONTAIN ADDRESS OF THE CURRENT 
*         *    CHARACTER WHICH THE BASIC INTERPRETER IS  
*         *    PROCESSING      
          JMP  BROMHK         JUMP BACK INTO THE BASIC RUM 
                               
VAB       RMB  1              = LOW ORDER FOUR BYTES OF THE PRODUCT 
VAC       RMB  1              = OF A FLOATING POINT MULTIPLICATION 
VAD       RMB  1              = THESE BYTES ARE USE AS RANDOM DATA 
VAE       RMB  1              = BY THE RND STATEMENT 
                               
* EXTENDED BASIC VARIABLES                      
TRCFLG    RMB  1              *PV TRACE FLAG 0=OFF ELSE=ON 
USRADR    RMB  2              *PV ADDRESS OF THE START OF USR VECTORS 
                               
* EXTENDED BASIC SCRATCH PAD VARIABLES                      
VCF       RMB  2               
VD1       RMB  2               
VD3       RMB  2               
VD5       RMB  2               
VD7       RMB  1               
VD8       RMB  1               
VD9       RMB  1               
VDA       RMB  1               
SW3VEC    RMB  3               
SW2VEC    RMB  3               
SWIVEC    RMB  3               
NMIVEC    RMB  3               
IRQVEC    RMB  3               
FRQVEC    RMB  3               
USRJMP    RMB  3              JUMP ADDRESS FOR BASIC'S USR FUNCTION 
RVSEED    RMB  1              * FLOATING POINT RANDOM NUMBER SEED EXPONENT 
          RMB  4              * MANTISSA: INITIALLY SET TO $804FC75259 
                               
**** USR FUNCTION VECTOR ADDRESSES (EX BASIC ONLY)                      
USR0      RMB  2              USR 0 VECTOR 
          RMB  2              USR 1 
          RMB  2              USR 2 
          RMB  2              USR 3 
          RMB  2              USR 4 
          RMB  2              USR 5 
          RMB  2              USR 6 
          RMB  2              USR 7 
          RMB  2              USR 8 
          RMB  2              USR 9 
                               
STRSTK    RMB  8*5            STRING DESCRIPTOR STACK 
LINHDR    RMB  2              LINE INPUT BUFFER HEADER 
LINBUF    RMB  LBUFMX+1       BASIC LINE INPUT BUFFER 
STRBUF    RMB  41             STRING BUFFER 
                               
PROGST    RMB  1              START OF PROGRAM SPACE 
*         INTERRUPT VECTORS                 
          ORG  $FFF2           
SWI3      RMB  2               
SWI2      RMB  2               
FIRQ      RMB  2               
IRQ       RMB  2               
SWI       RMB  2               
NMI       RMB  2               
RESETV    RMB  2               
                               
                               
                               
          ORG  $DB00           
                               
* CONSOLE IN                      
LA171     BSR  KEYIN          GET A CHARACTER FROM CONSOLE IN 
          BEQ  LA171          LOOP IF NO KEY DOWN 
          RTS                  
                               
*                              
* THIS ROUTINE GETS A KEYSTROKE FROM THE KEYBOARD IF A KEY                      
* IS DOWN. IT RETURNS ZERO TRUE IF THERE WAS NO KEY DOWN.                      
*                              
*                              
LA1C1                          
KEYIN     LDA  USTAT           
          BITA #1              
          BEQ  NOCHAR          
          LDA  RECEV           
          ANDA #$7F            
          RTS                  
NOCHAR    CLRA                 
          RTS                  
                               
                               
                               
* CONSOLE OUT                      
PUTCHR    BSR  WAITACIA        
          PSHS A               
          CMPA #CR            IS IT CARRIAGE RETURN? 
          BEQ  NEWLINE        YES 
          STA  TRANS           
          INC  LPTPOS         INCREMENT CHARACTER COUNTER 
          LDA  LPTPOS         CHECK FOR END OF LINE PRINTER LINE 
          CMPA LPTWID         AT END OF LINE PRINTER LINE? 
          BLO  PUTEND         NO 
NEWLINE   CLR  LPTPOS         RESET CHARACTER COUNTER 
          BSR  WAITACIA        
          LDA  #13             
          STA  TRANS           
          BSR  WAITACIA        
          LDA  #10            DO LINEFEED AFTER CR 
          STA  TRANS           
PUTEND    PULS A               
          RTS                  
                               
WAITACIA  PSHS A               
WRWAIT    LDA  USTAT           
          BITA #2              
          BEQ  WRWAIT          
          PULS A               
          RTS                  
                               
*                              
RESVEC                         
LA00E     LDS  #LINBUF+LBUFMX+1 SET STACK TO TOP OF LINE INPUT BUFFER 
          LDA  RSTFLG         GET WARM START FLAG 
          CMPA #$55           IS IT A WARM START? 
          BNE  BACDST         NO - D0 A COLD START 
          LDX  RSTVEC         WARM START VECTOR 
          LDA  ,X             GET FIRST BYTE OF WARM START ADDR 
          CMPA #$12           IS IT NOP? 
          BNE  BACDST         NO - DO A COLD START 
          JMP  ,X             YES, G0 THERE 
                               
* COLD START ENTRY                      
                               
BACDST    LDX  #PROGST+1      POINT X TO CLEAR 1ST 1K OF RAM 
LA077     CLR  ,--X           MOVE POINTER DOWN TWO-CLEAR BYTE 
          LEAX 1,X            ADVANCE POINTER ONE 
          BNE  LA077          KEEP GOING IF NOT AT BOTTOM OF PAGE 0 
          LDX  #PROGST        SET TO START OF PROGRAM SPACE 
          CLR  ,X+            CLEAR 1ST BYTE OF BASIC PROGRAM 
          STX  TXTTAB         BEGINNING OF BASIC PROGRAM 
LA084     LDA  2,X            LOOK FOR END OF MEMORY 
          COMA                * COMPLEMENT IT AND PUT IT BACK 
          STA  2,X            * INTO SYSTEM MEMORY 
          CMPA 2,X            IS IT RAM? 
          BNE  LA093          BRANCH IF NOT (ROM, BAD RAM OR NO RAM) 
          LEAX 1,X            MOVE POINTER UP ONE 
          COM  1,X            RE-COMPLEMENT TO RESTORE BYTE 
          BRA  LA084          KEEP LOOKING FOR END OF RAM 
LA093     STX  TOPRAM         SAVE ABSOLUTE TOP OF RAM 
          STX  MEMSIZ         SAVE TOP OF STRING SPACE 
          STX  STRTAB         SAVE START OF STRING VARIABLES 
          LEAX -200,X         CLEAR 200 - DEFAULT STRING SPACE TO 200 BYTES 
          STX  FRETOP         SAVE START OF STRING SPACE 
          TFR  X,S            PUT STACK THERE 
          LDX  #LA10D         POINT X TO ROM SOURCE DATA 
          LDU  #LPTCFW        POINT U TO RAM DESTINATION 
          LDB  #18            MOVE 18 BYTES 
          JSR  LA59A          MOVE 18 BYTES FROM ROM TO RAM 
          LDU  #IRQVEC        POINT U TO NEXT RAM DESTINATION 
          LDB  #4             MOVE 4 MORE BYTES 
          JSR  LA59A          MOVE 4 BYTES FROM ROM TO RAM 
          LDA  #$39            
          STA  LINHDR-1       PUT RTS IN LINHDR-1 
          JSR  LAD19          G0 DO A ‘NEW’ 
* EXTENDED BASIC INITIALISATION                      
          LDX  #USR0          INITIALIZE ADDRESS OF START OF 
          STX  USRADR         USR JUMP TABLE 
* INITIALIZE THE USR CALLS TO ‘FC ERROR’                      
          LDU  #LB44A         ADDRESS OF ‘FC ERROR’ ROUTINE 
          LDB  #10            10 USR CALLS IN EX BASIC 
L8031     STU  ,X++           STORE ‘FC’ ERROR AT USR ADDRESSES 
          DECB                FINISHED ALL 10? 
          BNE  L8031          NO 
                               
* INITIALISE ACIA                      
          LDA  #RTS_LOW       DIV16 CLOCK -> 7372800 / 4 / 16 = 115200 
          STA  UCTRL           
          LDX  #LA147-1       POINT X TO COLOR BASIC COPYRIGHT MESSAGE 
          JSR  LB99C          PRINT ‘COLOR BASIC’ 
          LDX  #BAWMST        WARM START ADDRESS 
          STX  RSTVEC         SAVE IT 
          LDA  #$55           WARM START FLAG 
          STA  RSTFLG         SAVE IT 
          BRA  LA0F3          GO TO BASIC’S MAIN LOOP 
BAWMST    NOP  NOP REQ’D FOR WARM START  
          JSR  LAD33          DO PART OF A NEW 
LA0F3     JMP  LAC73          GO TO MAIN LOOP OF BASIC 
*                              
* FIRQ SERVICE ROUTINE                      
BFRQSV                         
          RTI                  
*                              
* THESE BYTES ARE MOVED TO ADDRESSES $76 - $85 THE DIRECT PAGE                      
LA10D     FCB  16             TAB FIELD WIDTH 
          FCB  64             LAST TAB ZONE 
          FCB  80             PRINTER WIDTH 
          FCB  0              LINE PRINTER POSITION 
          FDB  LB44A          ARGUMENT OF EXEC COMMAND - SET TO ‘FC’ ERROR 
* LINE INPUT ROUTINE                      
          INC  CHARAD+1        
          BNE  LA123           
          INC  CHARAD          
LA123     LDA  >0000           
          JMP  BROMHK          
*                              
* THESE BYTES ARE MOVED TO ADDRESSES $A7-$B1                      
          JMP  BIRQSV         IRQ SERVICE 
          JMP  BFRQSV         FIRQ SERVICE 
          JMP  LB44A          USR ADDRESS FOR 8K BASIC (INITIALIZED TO ‘FC’ ERROR) 
          FCB  $80            *RANDOM SEED 
          FDB  $4FC7          *RANDON SEED OF MANTISSA 
          FDB  $5259          *.811635157 
* BASIC COMMAND INTERPRETATION TABLE ROM IMAGE                      
COMVEC    FCB  50             50 BASIC COMMANDS 
          FDB  LAA66          POINTS TO RESERVED WORDS 
          FDB  LAB67          POINTS TO JUMP TABLE FOR COMMANDS 
          FCB  29             29 BASIC SECONDARY COMMANDS 
          FDB  LAB1A          POINTS TO SECONDARY FUNCTION RESERVED WORDS 
          FDB  LAA29          POINTS TO SECONDARY FUNCTION JUMP TABLE 
          FDB  0              NO MORE TABLES (RES WORDS=0) 
          FDB  0              NO MORE TABLES 
          FDB  0              NO MORE TABLES 
          FDB  0              NO MORE TABLES 
          FDB  0              NO MORE TABLES 
          FDB  0              NO MORE TABLES (SECONDARY FNS =0) 
                               
* COPYRIGHT MESSAGES                      
LA147     FCC  "6809 EXTENDED BASIC"  
          FCB  CR              
          FCC  "(C) 1982 BY MICROSOFT"  
LA156     FCB  CR,CR           
LA165     FCB  $00             
                               
                               
LA35F     PSHS X,B,A          SAVE REGISTERS 
          LDX  LPTCFW         TAB FIELD WIDTH AND TAB ZONE 
          LDD  LPTWID         PRINTER WIDTH AND POSITION 
LA37C     STX  DEVCFW         SAVE TAB FIELD WIDTH AND ZONE 
          STB  DEVPOS         SAVE PRINT POSITION 
          STA  DEVWID         SAVE PRINT WIDTH 
          PULS A,B,X,PC       RESTORE REGISTERS 
                               
* THIS IS THE ROUTINE THAT GETS AN INPUT LINE FOR BASIC                      
* EXIT WITH BREAK KEY: CARRY = 1                      
* EXIT WITH ENTER KEY: CARRY = 0                      
LA38D                          
LA390     CLR  IKEYIM         RESET BREAK CHECK KEY TEMP KEY STORAGE 
          LDX  #LINBUF+1      INPUT LINE BUFFER 
          LDB  #1             ACCB CHAR COUNTER: SET TO 1 TO ALLOW A 
*         BACKSPACE AS FIRST CHARACTER  
LA39A     JSR  LA171          GO GET A CHARACTER FROM CONSOLE IN 
          CMPA #BS            BACKSPACE 
          BNE  LA3B4          NO 
          DECB                YES - DECREMENT CHAR COUNTER 
          BEQ  LA390          BRANCH IF BACK AT START OF LINE AGAIN 
          LEAX -1,X           DECREMENT BUFFER POINTER 
          BRA  LA3E8          ECHO CHAR TO SCREEN 
LA3B4     CMPA #$15           SHIFT RIGHT ARROW? 
          BNE  LA3C2          NO 
* YES, RESET BUFFER TO BEGINNING AND ERASE CURRENT LINE                      
LA3B8     DECB                DEC CHAR CTR 
          BEQ  LA390          GO BACK TO START IF CHAR CTR = 0 
          LDA  #BS            BACKSPACE? 
          JSR  PUTCHR         SEND TO CONSOLE OUT (SCREEN) 
          BRA  LA3B8          KEEP GOING 
LA3C2     CMPA #3             BREAK KEY? 
          ORCC #1             SET CARRY FLAG 
          BEQ  LA3CD          BRANCH IF BREAK KEY DOWN 
LA3C8     CMPA #CR            ENTER KEY? 
          BNE  LA3D9          NO 
LA3CC     CLRA                CLEAR CARRY FLAG IF ENTER KEY - END LINE ENTRY 
LA3CD     PSHS CC             SAVE CARRY FLAG 
          JSR  LB958          SEND CR TO SCREEN 
          CLR  ,X             MAKE LAST BYTE IN INPUT BUFFER = 0 
          LDX  #LINBUF        RESET INPUT BUFFER POINTER 
          PULS CC,PC          RESTORE CARRY FLAG 
                               
* INSERT A CHARACTER INTO THE BASIC LINE INPUT BUFFER                      
LA3D9     CMPA #$20           IS IT CONTROL CHAR? 
          BLO  LA39A          BRANCH IF CONTROL CHARACTER 
          CMPA #'z+1          * 
          BCC  LA39A          * IGNORE IF > LOWER CASE Z 
          CMPB #LBUFMX        HAVE 250 OR MORE CHARACTERS BEEN ENTERED? 
          BCC  LA39A          YES, IGNORE ANY MORE 
          STA  ,X+            PUT IT IN INPUT BUFFER 
          INCB                INCREMENT CHARACTER COUNTER 
LA3E8     JSR  PUTCHR         ECHO IT TO SCREEN 
          BRA  LA39A          GO SET SOME MORE 
                               
                               
* EXEC                         
EXEC      BEQ  LA545          BRANCH IF NO ARGUMENT 
          JSR  LB73D          EVALUATE ARGUMENT - ARGUMENT RETURNED IN X 
          STX  EXECJP         STORE X TO EXEC JUMP ADDRESS 
LA545     JMP  [EXECJP]       GO DO IT 
                               
* BREAK CHECK                      
LA549     JMP  LADEB          GO DO BREAK KEY CHECK 
                               
* INKEY$                       
INKEY     LDA  IKEYIM         WAS A KEY DOWN IN THE BREAK CHECK? 
          BNE  LA56B          YES 
          JSR  KEYIN          GO GET A KEY 
LA56B     CLR  IKEYIM         CLEAR INKEY RAM IMAGE 
          STA  FPA0+3         STORE THE KEY IN FPA0 
          LBNE LB68F          CONVERT FPA0+3 TO A STRING 
          STA  STRDES         SET LENGTH OF STRING = 0 IF NO KEY DOWN 
          JMP  LB69B          PUT A NULL STRING ONTO THE STRING STACK 
                               
* MOVE ACCB BYTES FROM (X) TO (U)                      
LA59A     LDA  ,X+            GET BYTE FROM X 
          STA  ,U+            STORE IT AT U 
          DECB                MOVED ALL BYTES? 
          BNE  LA59A          NO 
LA5A1     RTS                  
                               
LA5C4     RTS                  
                               
** THIS ROUTINE WILL SCAN OFF THE FILE NAME FROM A BASIC LINE                      
** AND RETURN A SYNTAX ERROR IF THERE ARE ANY CHARACTERS                      
** FOLLOWING THE END OF THE NAME                      
LA5C7     JSR  GETCCH         GET CURRENT INPUT CHAR FROM BASIC LINE 
LA5C9     BEQ  LA5C4          RETURN IF END OF LINE 
          JMP  LB277          SYNTAX ERROR IF ANY MORE CHARACTERS 
* IRQ SERVICE                      
BIRQSV                         
LA9C5     RTI  RETURN FROM INTERRUPT  
                               
* SET CARRY IF NUMERIC - RETURN WITH                      
* ZERO FLAG SET IF ACCA = 0 OR 3A(:) - END                      
* OF BASIC LINE OR SUB LINE                      
BROMHK    CMPA #'9+1          IS THIS CHARACTER >=(ASCII 9)+1? 
          BHS  LAA28          BRANCH IF > 9; Z SET IF = COLON 
          CMPA #SPACE         SPACE? 
          BNE  LAA24          NO - SET CARRY IF NUMERIC 
          JMP  GETNCH         IF SPACE, GET NECT CHAR (IGNORE SPACES) 
LAA24     SUBA #'0            * SET CARRY IF 
          SUBA #-'0           * CHARACTER > ASCII 0 
LAA28     RTS                  
                               
* DISPATCH TABLE FOR SECONDARY FUNCTIONS                      
* TOKENS ARE PRECEEDED BY $FF                      
* FIRST SET ALWAYS HAS ONE PARAMETER                      
FUNC_TAB                       
LAA29     FDB  SGN            SGN 
          FDB  INT            INT 
          FDB  ABS            ABS 
          FDB  USRJMP         USR 
TOK_USR   EQU  *-FUNC_TAB/2+$7F  
TOK_FF_USR EQU  *-FUNC_TAB/2+$FF7F  
          FDB  RND            RND 
          FDB  SIN            SIN 
          FDB  PEEK           PEEK 
          FDB  LEN            LEN 
          FDB  STR            STR$ 
          FDB  VAL            VAL 
          FDB  ASC            ASC 
          FDB  CHR            CHR$ 
          FDB  ATN            ATN 
          FDB  COS            COS 
          FDB  TAN            TAN 
          FDB  EXP            EXP 
          FDB  FIX            FIX 
          FDB  LOG            LOG 
          FDB  POS            POS 
          FDB  SQR            SQR 
          FDB  HEXDOL         HEX$ 
* LEFT, RIGHT AND MID ARE TREATED SEPARATELY                      
          FDB  LEFT           LEFT$ 
TOK_LEFT  EQU  *-FUNC_TAB/2+$7F  
          FDB  RIGHT          RIGHT$ 
          FDB  MID            MID$ 
TOK_MID   EQU  *-FUNC_TAB/2+$7F  
* REMAINING FUNCTIONS                      
          FDB  INKEY          INKEY$ 
TOK_INKEY EQU  *-FUNC_TAB/2+$7F  
          FDB  MEM            MEM 
          FDB  VARPT          VARPTR 
          FDB  INSTR          INSTR 
          FDB  STRING         STRING$ 
NUM_SEC_FNS EQU  *-FUNC_TAB/2    
                               
* THIS TABLE CONTAINS PRECEDENCES AND DISPATCH ADDRESSES FOR ARITHMETIC                      
* AND LOGICAL OPERATORS - THE NEGATION OPERATORS DO NOT ACT ON TWO OPERANDS                      
* S0 THEY ARE NOT LISTED IN THIS TABLE. THEY ARE TREATED SEPARATELY IN THE                      
* EXPRESSION EVALUATION ROUTINE. THEY ARE:                      
* UNARY NEGATION (-), PRECEDENCE &7D AND LOGICAL NEGATION (NOT), PRECEDENCE $5A                      
* THE RELATIONAL OPERATORS < > = ARE ALSO NOT LISTED, PRECEDENCE $64.                      
* A PRECEDENCE VALUE OF ZERO INDICATES END OF EXPRESSION OR PARENTHESES                      
*                              
LAA51     FCB  $79             
          FDB  LB9C5          + 
          FCB  $79             
          FDB  LB9BC          - 
          FCB  $7B             
          FDB  LBACC          * 
          FCB  $7B             
          FDB  LBB91          / 
          FCB  $7F             
          FDB  L8489          EXPONENTIATION 
          FCB  $50             
          FDB  LB2D5          AND 
          FCB  $46             
          FDB  LB2D4          OR 
                               
* THIS IS THE RESERVED WORD TABLE                      
* FIRST PART OF THE TABLE CONTAINS EXECUTABLE COMMANDS                      
LAA66     FCC  "FO"           80 
          FCB  $80+'R'         
          FCC  "G"            81 
          FCB  $80+'O'         
TOK_GO    EQU  $81             
          FCC  "RE"           82 
          FCB  $80+'M'         
          FCB  ''+$80         83 
          FCC  "ELS"          84 
          FCB  $80+'E'         
          FCC  "I"            85 
          FCB  $80+'F'         
          FCC  "DAT"          86 
          FCB  $80+'A'         
          FCC  "PRIN"         87 
          FCB  $80+'T'         
          FCC  "O"            88 
          FCB  $80+'N'         
          FCC  "INPU"         89 
          FCB  $80+'T'         
          FCC  "EN"           8A 
          FCB  $80+'D'         
          FCC  "NEX"          8B 
          FCB  $80+'T'         
          FCC  "DI"           8C 
          FCB  $80+'M'         
          FCC  "REA"          8D 
          FCB  $80+'D'         
          FCC  "RU"           8E 
          FCB  $80+'N'         
          FCC  "RESTOR"       8F 
          FCB  $80+'E'         
          FCC  "RETUR"        90 
          FCB  $80+'N'         
          FCC  "STO"          91 
          FCB  $80+'P'         
          FCC  "POK"          92 
          FCB  $80+'E'         
          FCC  "CON"          93 
          FCB  $80+'T'         
          FCC  "LIS"          94 
          FCB  $80+'T'         
          FCC  "CLEA"         95 
          FCB  $80+'R'         
          FCC  "NE"           96 
          FCB  $80+'W'         
          FCC  "EXE"          97 
          FCB  $80+'C'         
          FCC  "TRO"          98 
          FCB  $80+'N'         
          FCC  "TROF"         99 
          FCB  $80+'F'         
          FCC  "DE"           9A 
          FCB  $80+'L'         
          FCC  "DE"           9B 
          FCB  $80+'F'         
          FCC  "LIN"          9C 
          FCB  $80+'E'         
          FCC  "RENU"         9D 
          FCB  $80+'M'         
          FCC  "EDI"          9E 
          FCB  $80+'T'         
* END OF EXECUTABLE COMMANDS. THE REMAINDER OF THE TABLE ARE NON-EXECUTABLE TOKENS                      
          FCC  "TAB"          9F 
          FCB  $80+'('         
TOK_TAB   EQU  $9F             
          FCC  "T"            A0 
          FCB  $80+'O'         
TOK_TO    EQU  $A0             
          FCC  "SU"           A1 
          FCB  $80+'B'         
TOK_SUB   EQU  $A1             
          FCC  "THE"          A2 
          FCB  $80+'N'         
TOK_THEN  EQU  $A2             
          FCC  "NO"           A3 
          FCB  $80+'T'         
TOK_NOT   EQU  $A3             
          FCC  "STE"          A4 
          FCB  $80+'P'         
TOK_STEP  EQU  $A4             
          FCC  "OF"           A5 
          FCB  $80+'F'         
          FCB  '++$80         A6 
TOK_PLUS  EQU  $A6             
          FCB  '-+$80         A7 
TOK_MINUS EQU  $A7             
          FCB  '*+$80         A8 
          FCB  '/+$80         A9 
          FCB  '^+$80         AA 
          FCC  "AN"           AB 
          FCB  $80+'D'         
          FCC  "O"            AC 
          FCB  $80+'R'         
          FCB  '>+$80         AD 
TOK_GREATER EQU  $AD             
          FCB  '=+$80         AE 
TOK_EQUALS EQU  $AE             
          FCB  '<+$80         AF 
          FCC  "F"            B0 
          FCB  $80+'N'         
TOK_FN    EQU  $B0             
          FCC  "USIN"         B1 
          FCB  $80+'G'         
TOK_USING EQU  $B1             
*                              
                               
* FIRST SET ALWAYS HAS ONE PARAMETER                      
LAB1A     FCC  "SG"           80 
          FCB  $80+'N'         
          FCC  "IN"           81 
          FCB  $80+'T'         
          FCC  "AB"           82 
          FCB  $80+'S'         
          FCC  "US"           83 
          FCB  $80+'R'         
          FCC  "RN"           84 
          FCB  $80+'D'         
          FCC  "SI"           85 
          FCB  $80+'N'         
          FCC  "PEE"          86 
          FCB  $80+'K'         
          FCC  "LE"           87 
          FCB  $80+'N'         
          FCC  "STR"          88 
          FCB  $80+'$'         
          FCC  "VA"           89 
          FCB  $80+'L'         
          FCC  "AS"           8A 
          FCB  $80+'C'         
          FCC  "CHR"          8B 
          FCB  $80+'$'         
          FCC  "AT"           8C 
          FCB  $80+'N'         
          FCC  "CO"           8D 
          FCB  $80+'S'         
          FCC  "TA"           8E 
          FCB  $80+'N'         
          FCC  "EX"           8F 
          FCB  $80+'P'         
          FCC  "FI"           90 
          FCB  $80+'X'         
          FCC  "LO"           91 
          FCB  $80+'G'         
          FCC  "PO"           92 
          FCB  $80+'S'         
          FCC  "SQ"           93 
          FCB  $80+'R'         
          FCC  "HEX"          94 
          FCB  $80+'$'         
* LEFT, RIGHT AND MID ARE TREATED SEPARATELY                      
          FCC  "LEFT"         95 
          FCB  $80+'$'         
          FCC  "RIGHT"        96 
          FCB  $80+'$'         
          FCC  "MID"          97 
          FCB  $80+'$'         
* REMAINING FUNCTIONS                      
          FCC  "INKEY"        98 
          FCB  $80+'$'         
          FCC  "ME"           99 
          FCB  $80+'M'         
          FCC  "VARPT"        9A 
          FCB  $80+'R'         
          FCC  "INST"         9B 
          FCB  $80+'R'         
          FCC  "STRING"       9C 
          FCB  $80+'$'         
                               
*                              
* DISPATCH TABLE FOR COMMANDS TOKEN #               
CMD_TAB                        
LAB67     FDB  FOR             80   
          FDB  GO              81   
          FDB  REM             82   
TOK_REM   EQU  *-CMD_TAB/2+$7F  
          FDB  REM             83 (') 
TOK_SNGL_Q EQU  *-CMD_TAB/2+$7F  
          FDB  REM             84 (ELSE) 
TOK_ELSE  EQU  *-CMD_TAB/2+$7F  
          FDB  IF              85   
TOK_IF    EQU  *-CMD_TAB/2+$7F  
          FDB  DATA            86   
TOK_DATA  EQU  *-CMD_TAB/2+$7F  
          FDB  PRINT           87   
TOK_PRINT EQU  *-CMD_TAB/2+$7F  
          FDB  ON              88   
          FDB  INPUT           89   
TOK_INPUT EQU  *-CMD_TAB/2+$7F  
          FDB  END             8A   
          FDB  NEXT            8B   
          FDB  DIM             8C   
          FDB  READ            8D   
          FDB  RUN             8E   
          FDB  RESTOR         8F 
          FDB  RETURN          90   
          FDB  STOP            91   
          FDB  POKE            92   
          FDB  CONT           93 
          FDB  LIST            94   
          FDB  CLEAR           95   
          FDB  NEW             96   
          FDB  EXEC           97 
          FDB  TRON           98 
          FDB  TROFF          99 
          FDB  DEL            9A 
          FDB  DEF            9B 
          FDB  LINE           9C 
          FDB  RENUM          9D 
          FDB  EDIT           9E 
TOK_HIGH_EXEC EQU  *-CMD_TAB/2+$7F  
                               
* ERROR MESSAGES AND THEIR NUMBERS AS USED INTERNALLY                      
LABAF     FCC  "NF"           0 NEXT WITHOUT FOR   
          FCC  "SN"           1 SYNTAX ERROR   
          FCC  "RG"           2 RETURN WITHOUT GOSUB   
          FCC  "OD"           3 OUT OF DATA   
          FCC  "FC"           4 ILLEGAL FUNCTION CALL   
          FCC  "OV"           5 OVERFLOW   
          FCC  "OM"           6 OUT OF MEMORY   
          FCC  "UL"           7 UNDEFINED LINE NUMBER   
          FCC  "BS"           8 BAD SUBSCRIPT   
          FCC  "DD"           9 REDIMENSIONED ARRAY   
          FCC  "/0"           10 DIVISION BY ZERO 
          FCC  "ID"           11 ILLEGAL DIRECT STATEMENT 
          FCC  "TM"           12 TYPE MISMATCH 
          FCC  "OS"           13 OUT OF STRING SPACE 
          FCC  "LS"           14 STRING TOO LONG 
          FCC  "ST"           15 STRING FORMULA TOO COMPLEX 
          FCC  "CN"           16 CAN'T CONTINUE 
          FCC  "FD"           17 BAD FILE DATA 
          FCC  "AO"           18 FILE ALREADY OPEN 
          FCC  "DN"           19 DEVICE NUMBER ERROR 
          FCC  "IO"           20 I/O ERROR 
          FCC  "FM"           21 BAD FILE MODE 
          FCC  "NO"           22 FILE NOT OPEN 
          FCC  "IE"           23 INPUT PAST END OF FILE 
          FCC  "DS"           24 DIRECT STATEMENT IN FILE 
* ADDITIONAL ERROR MESSAGES ADDED BY EXTENDED BASIC                      
L890B     FCC  "UF"           25 UNDEFINED FUNCTION (FN) CALL 
L890D     FCC  "NE"           26 FILE NOT FOUND 
                               
LABE1     FCC  " ERROR"        
          FCB  $00             
LABE8     FCC  " IN "          
          FCB  $00             
LABED     FCB  CR              
LABEE     FCC  "OK"            
          FCB  CR,$00          
LABF2     FCB  CR              
          FCC  "BREAK"         
          FCB  $00             
                               
* SEARCH THE STACK FOR ‘GOSUB/RETURN’ OR ‘FOR/NEXT’ DATA.                      
* THE ‘FOR/NEXT’ INDEX VARIABLE DESCRIPTOR ADDRESS BEING                      
* SOUGHT IS STORED IN VARDES. EACH BLOCK OF FOR/NEXT DATA IS 18                      
* BYTES WITH A $80 LEADER BYTE AND THE GOSUB/RETURN DATA IS 5 BYTES                      
* WITH AN $A6 LEADER BYTE. THE FIRST NON "FOR/NEXT" DATA                      
* IS CONSIDERED ‘GOSUB/RETURN’                      
LABF9     LEAX 4,S            POINT X TO 3RD ADDRESS ON STACK - IGNORE THE 
*         FIRST TWO RETURN ADDRESSES ON THE STACK  
LABFB     LDB  #18            18 BYTES SAVED ON STACK FOR EACH ‘FOR’ LOOP 
          STX  TEMPTR         SAVE POINTER 
          LDA  ,X             GET 1ST BYTE 
          SUBA #$80           * CHECK FOR TYPE OF STACK JUMP FOUND 
          BNE  LAC1A          * BRANCH IF NOT ‘FOR/NEXT’ 
          LDX  1,X            = GET INDEX VARIABLE DESCRIPTOR 
          STX  TMPTR1         = POINTER AND SAVE IT IN TMPTR1 
          LDX  VARDES         GET INDEX VARIABLE BEING SEARCHED FOR 
          BEQ  LAC16          BRANCH IF DEFAULT INDEX VARIABLE - USE THE 
*                             FIRST ‘FOR/NEXT’ DATA FOUND ON STACK 
*                             IF NO INDEX VARIABLE AFTER ‘NEXT’ 
          CMPX TMPTR1         DOES THE STACK INDEX MATCH THE ONE 
*                             BEING SEARCHED FOR? 
          BEQ  LAC1A          YES 
          LDX  TEMPTR         * RESTORE INITIAL POINTER, ADD 
          ABX                 * 18 TO IT AND LOOK FOR 
          BRA  LABFB          * NEXT BLOCK OF DATA 
LAC16     LDX  TMPTR1         = GET 1ST INDEX VARIABLE FOUND AND 
          STX  VARDES         = SAVE AS ‘NEXT’ INDEX 
LAC1A     LDX  TEMPTR         POINT X TO START OF ‘FOR/NEXT’ DATA 
          TSTA                SET ZERO FLAG IF ‘FOR/NEXT’ DATA 
          RTS                  
* CHECK FOR MEMORY SPACE FOR NEW TOP OF                      
* ARRAYS AND MOVE ARRAYS TO NEW LOCATION                      
LAC1E     BSR  LAC37          ACCD = NEW BOTTOM OF FREE RAM - IS THERE 
*                             ROOM FOR THE STACK? 
* MOVE BYTES FROM V43(X) TO V41(U) UNTIL (X) = V47 AND                      
* SAVE FINAL VALUE OF U IN V45                      
LAC20     LDU  V41            POINT U TO DESTINATION ADDRESS (V41) 
          LEAU 1,U            ADD ONE TO U - COMPENSATE FOR FIRST PSHU 
          LDX  V43            POINT X TO SOURCE ADDRESS (V43) 
          LEAX 1,X            ADD ONE - COMPENSATE FOR FIRST LDA ,X 
LAC28     LDA  ,-X            GRAB A BYTE FROM SOURCE 
          PSHU A              MOVE IT TO DESTINATION 
          CMPX V47            DONE? 
          BNE  LAC28          NO - KEEP MOVING BYTES 
          STU  V45            SAVE FINAL DESTINATION ADDRESS 
LAC32     RTS                  
* CHECK TO SEE IF THERE IS ROOM TO STORE 2*ACCB                      
* BYTES IN FREE RAM - OM ERROR IF NOT                      
LAC33     CLRA                * ACCD CONTAINS NUMBER OF EXTRA 
          ASLB                * BYTES TO PUT ON STACK 
          ADDD ARYEND         END OF PROGRAM AND VARIABLES 
LAC37     ADDD #STKBUF        ADD STACK BUFFER - ROOM FOR STACK? 
          BCS  LAC44          BRANCH IF GREATER THAN $FFFF 
          STS  BOTSTK         CURRENT NEW BOTTOM OF STACK STACK POINTER 
          CMPD BOTSTK         ARE WE GOING TO BE BELOW STACK? 
          BCS  LAC32          YES - NO ERROR 
LAC44     LDB  #6*2           OUT OF MEMORY ERROR 
                               
* ERROR SERVICING ROUTINE                      
LAC46     JSR  LAD33          RESET STACK, STRING STACK, CONTINUE POINTER 
          JSR  LB95C          SEND A CR TO SCREEN 
          JSR  LB9AF          SEND A ‘?‘ TO SCREEN 
          LDX  #LABAF         POINT TO ERROR TABLE 
LAC60     ABX                 ADD MESSAGE NUMBER OFFSET 
          BSR  LACA0          * GET TWO CHARACTERS FROM X AND 
          BSR  LACA0          * SEND TO CONSOLE OUT (SCREEN) 
          LDX  #LABE1-1       POINT TO "ERROR" MESSAGE 
LAC68     JSR  LB99C          PRINT MESSAGE POINTED TO BY X 
          LDA  CURLIN         GET CURRENT LINE NUMBER (CURL IN) 
          INCA                TEST FOR DIRECT MODE 
          BEQ  LAC73          BRANCH IF DIRECT MODE 
          JSR  LBDC5          PRINT ‘IN ****‘ 
                               
* THIS IS THE MAIN LOOP OF BASIC WHEN IN DIRECT MODE                      
LAC73     JSR  LB95C          MOVE CURSOR TO START OF LINE 
          LDX  #LABED         POINT X TO ‘OK’, CR MESSAGE 
          JSR  LB99C          PRINT ‘OK’, CR 
LAC7C     JSR  LA390          GO GET AN INPUT LINE 
          LDU  #$FFFF         THE LINE NUMBER FOR DIRECT MODE IS $FFFF 
          STU  CURLIN         SAVE IT IN CURLIN 
          BCS  LAC7C          BRANCH IF LINE INPUT TERMINATED BY BREAK 
          STX  CHARAD         SAVE (X) AS CURRENT INPUT POINTER - THIS WILL 
*         ENABLE THE ‘LIVE KEYBOARD’ (DIRECT) MODE. THE  
*         LINE JUST ENTERED WILL BE INTERPRETED  
          JSR  GETNCH         GET NEXT CHARACTER FROM BASIC 
          BEQ  LAC7C          NO LINE INPUT - GET ANOTHER LINE 
          BCS  LACA5          BRANCH IF NUMER1C - THERE WAS A LINE NUMBER BEFORE 
*         THE  STATEMENT ENTERED, SO THIS STATEMENT  
*         WILL BE MERGED INTO THE BASIC PROGRAM  
          JSR  LB821          GO CRUNCH LINE 
          JMP  LADC0          GO EXECUTE THE STATEMENT (LIVE KEYBOARD) 
*                              
LACA0     LDA  ,X+            GET A CHARACTER 
          JMP  LB9B1          SEND TO CONSOLE OUT 
* TAKE A LINE FROM THE LINE INPUT BUFFER                      
* AND INSERT IT INTO THE BASIC PROGRAM                      
LACA5     JSR  LAF67          CONVERT LINE NUMBER TO BINARY 
LACA8     LDX  BINVAL         GET CONVERTED LINE NUMBER 
          STX  LINHDR         STORE IT IN LINE INPUT HEADER 
          JSR  LB821          GO CRUNCH THE LINE 
          STB  TMPLOC         SAVE LINE LENGTH 
          BSR  LAD01          FIND OUT WHERE TO INSERT LINE 
          BCS  LACC8          BRANCH IF LINE NUMBER DOES NOT ALREADY EXIST 
          LDD  V47            GET ABSOLUTE ADDRESS OF LINE NUMBER 
          SUBD ,X             SUBTRACT ADDRESS OF NEXT LINE NUMBER 
          ADDD VARTAB         * ADD TO CURRENT END OF PROGRAM - THIS WILL REMOVE 
          STD  VARTAB         * THE LENGTH OF THIS LINE NUMBER FROM THE PROGRAM 
          LDU  ,X             POINT U TO ADDRESS OF NEXT LINE NUMBER 
* DELETE OLD LINE FROM BASIC PROGRAM                      
LACC0     PULU A              GET A BYTE FROM WHAT’S LEFT OF PROGRAM 
          STA  ,X+            MOVE IT DOWN 
          CMPX VARTAB         COMPARE TO END OF BASIC PROGRAM 
          BNE  LACC0          BRANCH IF NOT AT END 
LACC8     LDA  LINBUF         * CHECK TO SEE IF THERE IS A LINE IN 
          BEQ  LACE9          * THE BUFFER AND BRANCH IF NONE 
          LDD  VARTAB         = SAVE CURRENT END OF 
          STD  V43            = PROGRAM IN V43 
          ADDB TMPLOC         * ADD LENGTH OF CRUNCHED LINE, 
          ADCA #0             * PROPOGATE CARRY AND SAVE NEW END 
          STD  V41            * OF PROGRAM IN V41 
          JSR  LAC1E          = MAKE SURE THERE’S ENOUGH RAM FOR THIS 
*         =    LINE & MAKE A HOLE IN BASIC FOR NEW LINE  
          LDU  #LINHDR-2      POINT U TO LINE TO BE INSERTED 
LACDD     PULU A              GET A BYTE FROM NEW LINE 
          STA  ,X+            INSERT IT IN PROGRAM 
          CMPX V45            * COMPARE TO ADDRESS OF END OF INSERTED 
          BNE  LACDD          * LINE AND BRANCH IF NOT DONE 
          LDX  V41            = GET AND SAVE 
          STX  VARTAB         = END OF PROGRAM 
LACE9     BSR  LAD21          RESET INPUT POINTER, CLEAR VARIABLES, INITIALIZE 
          BSR  LACEF          ADJUST START OF NEXT LINE ADDRESSES 
          BRA  LAC7C          REENTER BASIC’S INPUT LOOP 
* COMPUTE THE START OF NEXT LINE ADDRESSES FOR THE BASIC PROGRAM                      
LACEF     LDX  TXTTAB         POINT X TO START OF PROGRAM 
LACF1     LDD  ,X             GET ADDRESS OF NEXT LINE 
          BEQ  LAD16          RETURN IF END OF PROGRAM 
          LEAU 4,X            POINT U TO START OF BASIC TEXT IN LINE 
LACF7     LDA  ,U+            * SKIP THROUGH THE LINE UNTIL A 
          BNE  LACF7          * ZERO (END OF LINE) IS FOUND 
          STU  ,X             SAVE THE NEW START OF NEXT LINE ADDRESS 
          LDX  ,X             POINT X TO START OF NEXT LINE 
          BRA  LACF1          KEEP GOING 
*                              
* FIND A LINE NUMBER IN THE BASIC PROGRAM                      
* RETURN WITH CARRY SET IF NO MATCH FOUND                      
LAD01     LDD  BINVAL         GET THE LINE NUMBER TO FIND 
          LDX  TXTTAB         BEGINNING OF PROGRAM 
LAD05     LDU  ,X             GET ADDRESS OF NEXT LINE NUMBER 
          BEQ  LAD12          BRANCH IF END OF PROG 
          CMPD 2,X            IS IT A MATCH? 
          BLS  LAD14          CARRY SET IF LOWER; CARRY CLEAR IF MATCH 
          LDX  ,X             X = ADDRESS OF NEXT LINE 
          BRA  LAD05          KEEP LOOPING FOR LINE NUMBER 
LAD12     ORCC #1             SET CARRY FLAG 
LAD14     STX  V47            SAVE MATCH LINE NUMBER OR NUMBER OF LINE JUST AFTER 
*                             WHERE IT SHOULD HAVE BEEN 
LAD16     RTS                  
                               
* NEW                          
NEW       BNE  LAD14          BRANCH IF ARGUMENT GIVEN 
LAD19     LDX  TXTTAB         GET START OF BASIC 
          CLR  ,X+            * PUT 2 ZERO BYTES THERE - ERASE 
          CLR  ,X+            * THE BASIC PROGRAM 
          STX  VARTAB         AND THE NEXT ADDRESS IS NOW THE END OF PROGRAM 
LAD21     LDX  TXTTAB         GET START OF BASIC 
          JSR  LAEBB          PUT INPUT POINTER ONE BEFORE START OF BASIC 
* ERASE ALL VARIABLES                      
LAD26     LDX  MEMSIZ         * RESET START OF STRING VARIABLES 
          STX  STRTAB         * TO TOP OF STRING SPACE 
          JSR  RESTOR         RESET ‘DATA’ POINTER TO START OF BASIC 
          LDX  VARTAB         * GET START OF VARIABLES AND USE IT 
          STX  ARYTAB         * TO RESET START OF ARRAYS 
          STX  ARYEND         RESET END OF ARRAYS 
LAD33     LDX  #STRSTK        * RESET STRING STACK POINTER TO 
          STX  TEMPPT         * BOTTOM OF STRING STACK 
          LDX  ,S             GET RETURN ADDRESS OFF STACK 
          LDS  FRETOP         RESTORE STACK POINTER 
          CLR  ,-S            PUT A ZERO BYTE ON STACK - TO CLEAR ANY RETURN OF 
*                             FOR/NEXT DATA FROM THE STACK 
          CLR  OLDPTR         RESET ‘CONT’ ADDRESS SO YOU 
          CLR  OLDPTR+1       ‘CAN’T CONTINUE’ 
          CLR  ARYDIS         CLEAR THE ARRAY DISABLE FLAG 
          JMP  ,X             RETURN TO CALLING ROUTINE - THIS IS NECESSARY 
*                             SINCE THE STACK WAS RESET 
*                              
* FOR                          
*                              
* THE FOR COMMAND WILL STORE 18 BYTES ON THE STACK FOR                      
* EACH FOR-NEXT LOOP WHICH IS BEING PROCESSED. THESE                      
* BYTES ARE DEFINED AS FOLLOWS: 0- $80 (FOR FLAG);                      
*         1,2=INDEX VARIABLE DESCRIPTOR POINTER; 3-7=FP VALUE OF STEP;  
*         8=STEP DIRECTION: $FF IF NEGATIVE; 0 IF ZERO; 1 IF POSITIVE;  
* 9-13=FP VALUE OF ‘TO’ PARAMETER;                      
* 14,15=CURRENT LINE NUMBER; 16,17=RAM ADDRESS OF THE END                      
*         OF   THE LINE CONTAINING THE ‘FOR’ STATEMENT  
FOR       LDA  #$80           * SAVE THE DISABLE ARRAY FLAG IN VO8 
          STA  ARYDIS         * DO NOT ALLOW THE INDEX VARIABLE TO BE AN ARRAY 
          JSR  LET            SET INDEX VARIABLE TO INITIAL VALUE 
          JSR  LABF9          SEARCH THE STACK FOR ‘FOR/NEXT’ DATA 
          LEAS 2,S            PURGE RETURN ADDRESS OFF OF THE STACK 
          BNE  LAD59          BRANCH IF INDEX VARIABLE NOT ALREADY BEING USED 
          LDX  TEMPTR         GET (ADDRESS + 18) OF MATCHED ‘FOR/NEXT’ DATA 
          LEAS B,X            MOVE THE STACK POINTER TO THE BEGINNING OF THE 
* MATCHED ‘FOR/NEXT’ DATA SO THE NEW DATA WILL                      
* OVERLAY THE OLD DATA. THIS WILL ALSO DESTROY                      
* ALL OF THE ‘RETURN’ AND ‘FOR/NEXT’ DATA BELOW                      
* THIS POINT ON THE STACK                      
LAD59     LDB  #$09           * CHECK FOR ROOM FOR 18 BYTES 
          JSR  LAC33          * IN FREE RAM 
          JSR  LAEE8          GET ADDR OF END OF SUBLINE IN X 
          LDD  CURLIN         GET CURRENT LINE NUMBER 
          PSHS X,B,A          SAVE LINE ADDR AND LINE NUMBER ON STACK 
          LDB  #TOK_TO        TOKEN FOR ‘TO’ 
          JSR  LB26F          SYNTAX CHECK FOR ‘TO’ 
          JSR  LB143          ‘TM’ ERROR IF INDEX VARIABLE SET TO STRING 
          JSR  LB141          EVALUATE EXPRESSION 
*                              
          LDB  FP0SGN         GET FPA0 MANTISSA SIGN 
          ORB  #$7F           FORM A MASK TO SAVE DATA BITS OF HIGH ORDER MANTISSA 
          ANDB FPA0           PUT THE MANTISSA SIGN IN BIT 7 OF HIGH ORDER MANTISSA 
          STB  FPA0           SAVE THE PACKED HIGH ORDER MANTISSA 
          LDY  #LAD7F         LOAD FOLLOWING ADDRESS INTO Y AS A RETURN 
          JMP  LB1EA          ADDRESS - PUSH FPA0 ONTO THE STACK 
LAD7F     LDX  #LBAC5         POINT X TO FLOATING POINT NUMBER 1.0 (DEFAULT STEP VALUE) 
          JSR  LBC14          MOVE (X) TO FPA0 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          CMPA #TOK_STEP      STEP TOKEN 
          BNE  LAD90          BRANCH IF NO ‘STEP’ VALUE 
          JSR  GETNCH         GET A CHARACTER FROM BASIC 
          JSR  LB141          EVALUATE NUMERIC EXPRESSION 
LAD90     JSR  LBC6D          CHECK STATUS OF FPA0 
          JSR  LB1E6          SAVE STATUS AND FPA0 ON THE STACK 
          LDD  VARDES         * GET DESCRIPTOR POINTER FOR THE ‘STEP’ 
          PSHS B,A            * VARIABLE AND SAVE IT ON THE STACK 
          LDA  #$80           = GET THE ‘FOR’ FLAG AND 
          PSHS A              = SAVE IT ON THE STACK 
*                              
* MAIN COMMAND INTERPRETATION LOOP                      
LAD9E     ANDCC #$AF           ENABLE IRQ,FIRQ 
          BSR  LADEB          CHECK FOR KEYBOARD BREAK 
          LDX  CHARAD         GET BASIC’S INPUT POINTER 
          STX  TINPTR         SAVE IT 
          LDA  ,X+            GET CURRENT INPUT CHAR & MOVE POINTER 
          BEQ  LADB4          BRANCH IF END OF LINE 
          CMPA #':            CHECK FOR LINE SEPARATOR 
          BEQ  LADC0          BRANCH IF COLON 
LADB1     JMP  LB277          ‘SYNTAX ERROR’-IF NOT LINE SEPARATOR 
LADB4     LDA  ,X++           GET MS BYTE OF ADDRESS OF NEXT BASIC LINE 
          STA  ENDFLG         SAVE IN STOP/END FLAG - CAUSE A STOP IF 
*                             NEXT LINE ADDRESS IS < $8000; CAUSE 
*                             AN END IF ADDRESS > $8000 
          BEQ  LAE15          BRANCH TO ‘STOP’ - END OF PROGRAM 
          LDD  ,X+            GET CURRENT LINE NUMBER 
          STD  CURLIN         SAVE IN CURLIN 
          STX  CHARAD         SAVE ADDRESS OF FIRST BYTE OF LINE 
* EXTENDED BASIC TRACE                      
          LDA  TRCFLG         TEST THE TRACE FLAG 
          BEQ  LADC0          BRANCH IF TRACE OFF 
          LDA  #$5B           <LEFT HAND MARKER FOR TRON LINE NUMBER 
          JSR  PUTCHR         OUTPUT A CHARACTER 
          LDA  CURLIN         GET MS BYTE OF LINE NUMBER 
          JSR  LBDCC          CONVERT ACCD TO DECIMAL AND PRINT ON SCREEN 
          LDA  #$5D           > RIGHT HAND MARKER FOR TRON LINE NUMBER 
          JSR  PUTCHR         OUTPUT A CHARACTER 
* END OF EXTENDED BASIC TRACE                      
LADC0     JSR  GETNCH         GET A CHARACTER FROM BASIC 
          BSR  LADC6          GO PROCESS COMMAND 
          BRA  LAD9E          GO BACK TO MAIN LOOP 
LADC6     BEQ  LADEA          RETURN IF END OF LINE (RTS - was BEQ LAE40) 
          TSTA                CHECK FOR TOKEN - BIT 7 SET (NEGATIVE) 
          LBPL LET            BRANCH IF NOT A TOKEN - GO DO A ‘LET’ WHICH 
*                             IS THE ‘DEFAULT’ TOKEN FOR MICROSOFT BASIC 
          CMPA #$FF           SECONDARY TOKEN 
          BEQ  SECTOK          
          CMPA #TOK_HIGH_EXEC SKIPF TOKEN - HIGHEST EXECUTABLE COMMAND IN BASIC 
          BHI  LADB1          ‘SYNTAX ERROR’ IF NON-EXECUTABLE TOKEN 
          LDX  COMVEC+3       GET ADDRESS OF BASIC’S COMMAND TABLE 
LADD4     ASLA                X2 (2 BYTE/JUMP ADDRESS) & DISCARD BIT 7 
          TFR  A,B            SAVE COMMAND OFFSET IN ACCB 
          ABX                 NON X POINTS TO COMMAND JUMP ADDR 
          JSR  GETNCH         GET AN INPUT CHAR 
*                              
* HERE IS WHERE WE BRANCH TO DO A ‘COMMAND’                      
          JMP  [,X]           GO DO A COMMAND 
SECTOK                         
* THE ONLY SECONDARY TOKEN THAT CAN ALSO BE AN EXECUTABLE IS                      
* THE MID$ REPLACEMENT STATEMENT. SO SPECIAL-CASE CHECK DONE HERE                      
          JSR  GETNCH         GET AN INPUT CHAR 
          CMPA #TOK_MID       TOKEN FOR "MID$" 
          LBEQ L86D6          PROCESS MID$ REPLACEMENT 
          JMP  LB277          SYNTAX ERROR 
                               
*                              
* RESTORE                      
RESTOR    LDX  TXTTAB         BEGINNING OF PROGRAM ADDRESS 
          LEAX -1,X           MOVE TO ONE BYTE BEFORE PROGRAM 
LADE8     STX  DATPTR         SAVE NEW DATA POINTER 
LADEA     RTS                  
*                              
* BREAK CHECK                      
LADEB     JSR  LA1C1          GET A KEYSTROKE ENTRY 
          BEQ  LADFA          RETURN IF NO INPUT 
LADF0     CMPA #3             CONTROL C? (BREAK) 
          BEQ  STOP           YES 
          CMPA #$13           CONTROL S? (PAUSE) 
          BEQ  LADFB          YES 
          STA  IKEYIM         SAVE KEYSTROKE IN INKEY IMAGE 
LADFA     RTS                  
LADFB     JSR  KEYIN          GET A KEY 
          BEQ  LADFB          BRANCH IF NO KEY DOWN 
          BRA  LADF0          CONTINUE - DO A BREAK CHECK 
*                              
* END                          
END       JSR  GETCCH         GET CURRENT INPUT CHAR 
          BRA  LAE0B           
*                              
* STOP                         
STOP      ORCC #$01           SET CARRY FLAG 
LAE0B     BNE  LAE40          BRANCH IF ARGUMENT EXISTS 
          LDX  CHARAD         * SAVE CURRENT POSITION OF 
          STX  TINPTR         * BASIC’S INPUT POINTER 
LAE11     ROR  ENDFLG         ROTATE CARRY INTO BIT 7 OF STOP/END FLAG 
          LEAS 2,S            PURGE RETURN ADDRESS OFF STACK 
LAE15     LDX  CURLIN         GET CURRENT LINE NUMBER 
          CMPX #$FFFF         DIRECT MODE? 
          BEQ  LAE22          YES 
          STX  OLDTXT         SAVE CURRENT LINE NUMBER 
          LDX  TINPTR         * GET AND SAVE CURRENT POSITION 
          STX  OLDPTR         * OF BASIC’S INPUT POINTER 
LAE22                          
          LDX  #LABF2-1       POINT TO CR, ‘BREAK’ MESSAGE 
          TST  ENDFLG         CHECK STOP/END FLAG 
          LBPL LAC73          BRANCH TO MAIN LOOP OF BASIC IF END 
          JMP  LAC68          PRINT ‘BREAK AT ####’ AND GO TO 
*                             BASIC’S MAIN LOOP IF ‘STOP’ 
                               
* CONT                         
CONT      BNE  LAE40          RETURN IF ARGUMENT GIVEN 
          LDB  #2*16          ‘CAN’T CONTINUE’ ERROR 
          LDX  OLDPTR         GET CONTINUE ADDRESS (INPUT POINTER) 
          LBEQ LAC46          ‘CN’ ERROR IF CONTINUE ADDRESS = 0 
          STX  CHARAD         RESET BASIC’S INPUT POINTER 
          LDX  OLDTXT         GET LINE NUMBER 
          STX  CURLIN         RESET CURRENT LINE NUMBER 
LAE40     RTS                  
*                              
* CLEAR                        
CLEAR     BEQ  LAE6F          BRANCH IF NO ARGUMENT 
          JSR  LB3E6          EVALUATE ARGUMENT 
          PSHS B,A            SAVE AMOUNT OF STRING SPACE ON STACK 
          LDX  MEMSIZ         GET CURRENT TOP OF CLEARED SPACE 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          BEQ  LAE5A          BRANCH IF NO NEW TOP OF CLEARED SPACE 
          JSR  LB26D          SYNTAX CHECK FOR COMMA 
          JSR  LB73D          EVALUATE EXPRESSlON; RETURN VALUE IN X 
          LEAX -1,X           X = TOP OF CLEARED SPACE 
          CMPX TOPRAM         COMPARE TO TOP OF RAM 
          BHI  LAE72          ‘OM’ ERROR IF > TOP OF RAM 
LAE5A     TFR  X,D            ACCD = TOP OF CLEARED SPACE 
          SUBD ,S++           SUBTRACT OUT AMOUNT OF CLEARED SPACE 
          BCS  LAE72          ‘OM’ ERROR IF FREE MEM < 0 
          TFR  D,U            U = BOTTOM OF CLEARED SPACE 
          SUBD #STKBUF        SUBTRACT OUT STACK BUFFER 
          BCS  LAE72          ‘OM’ ERROR IF FREE MEM < 0 
          SUBD VARTAB         SUBTRACT OUT START OF VARIABLES 
          BCS  LAE72          ‘OM’ ERROR IF FREE MEM < 0 
          STU  FRETOP         SAVE NEW BOTTOM OF CLEARED SPACE 
          STX  MEMSIZ         SAVE NEW TOP OF CLEARED SPACE 
LAE6F     JMP  LAD26          ERASE ALL VARIABLES, INITIALIZE POINTERS, ETC 
LAE72     JMP  LAC44          ‘OM’ ERROR 
*                              
* RUN                          
RUN       JSR  GETCCH         * GET CURRENT INPUT CHARACTER 
          LBEQ LAD21          * IF NO LINE NUMBER 
          JSR  LAD26          ERASE ALL VARIABLES 
          BRA  LAE9F          ‘GOTO’ THE RUN ADDRESS 
*                              
* GO                           
GO        TFR  A,B            SAVE INPUT CHARACTER IN ACCB 
LAE88     JSR  GETNCH         GET A CHARACTER FROM BASIC 
          CMPB #TOK_TO        ‘TO’ TOKEN 
          BEQ  LAEA4          BRANCH IF GOTO 
          CMPB #TOK_SUB       ‘SUB’ TOKEN 
          BNE  LAED7          ‘SYNTAX ERROR’ IF NEITHER 
          LDB  #3             =ROOM FOR 6 
          JSR  LAC33          =BYTES ON STACK? 
          LDU  CHARAD         * SAVE CURRENT BASIC INPUT POINTER, LINE 
          LDX  CURLIN         * NUMBER AND SUB TOKEN ON STACK 
          LDA  #TOK_SUB       * 
          PSHS U,X,A          * 
LAE9F     BSR  LAEA4          GO DO A ‘GOTO’ 
          JMP  LAD9E          JUMP BACK TO BASIC’S MAIN LOOP 
* GOTO                         
LAEA4     JSR  GETCCH         GET CURRENT INPUT CHAR 
          JSR  LAF67          GET LINE NUMBER TO BINARY IN BINVAL 
          BSR  LAEEB          ADVANCE BASIC’S POINTER TO END OF LINE 
          LEAX $01,X          POINT TO START OF NEXT LINE 
          LDD  BINVAL         GET THE LINE NUMBER TO RUN 
          CMPD CURLIN         COMPARE TO CURRENT LINE NUMBER 
          BHI  LAEB6          IF REO’D LINE NUMBER IS > CURRENT LINE NUMBER, 
*              DON’T START LOOKING FROM  
*              START OF PROGRAM  
          LDX  TXTTAB         BEGINNING OF PROGRAM 
LAEB6     JSR  LAD05          GO FIND A LINE NUMBER 
          BCS  LAED2          ‘UNDEFINED LINE NUMBER’ 
LAEBB     LEAX -1,X           MOVE BACK TO JUST BEFORE START OF LINE 
          STX  CHARAD         RESET BASIC’S INPUT POINTER 
LAEBF     RTS                  
*                              
* RETURN                       
RETURN    BNE  LAEBF          EXIT ROUTINE IF ARGUMENT GIVEN 
          LDA  #$FF           * PUT AN ILLEGAL VARIABLE NAME IN FIRST BYTE OF 
          STA  VARDES         * VARDES WHICH WILL CAUSE ‘FOR/NEXT’ DATA ON THE 
*              STACK TO BE IGNORED  
          JSR  LABF9          CHECK FOR RETURN DATA ON THE STACK 
          TFR  X,S            RESET STACK POINTER - PURGE TWO RETURN ADDRESSES 
*              FROM THE STACK  
          CMPA #TOK_SUB-$80   SUB TOKEN - $80 
          BEQ  LAEDA          BRANCH IF ‘RETURN’ FROM SUBROUTINE 
          LDB  #2*2           ERROR #2 ‘RETURN WITHOUT GOSUB’ 
          FCB  SKP2           SKIP TWO BYTES 
LAED2     LDB  #7*2           ERROR #7 ‘UNDEFINED LINE NUMBER’ 
          JMP  LAC46          JUMP TO ERROR HANDLER 
LAED7     JMP  LB277          ‘SYNTAX ERROR’ 
LAEDA     PULS A,X,U          * RESTORE VALUES OF CURRENT LINE NUMBER AND 
          STX  CURLIN         * BASIC’S INPUT POINTER FOR THIS SUBROUTINE 
          STU  CHARAD         * AND LOAD ACCA WITH SUB TOKEN ($A6) 
*                              
* DATA                         
DATA      BSR  LAEE8          MOVE INPUT POINTER TO END OF SUBLINE OR LINE 
          FCB  SKP2           SKIP 2 BYTES 
                               
* REM, ELSE                      
ELSE                           
REM       BSR  LAEEB          MOVE INPUT POINTER TO END OF LINE 
          STX  CHARAD         RESET BASIC’S INPUT POINTER 
LAEE7     RTS                  
* ADVANCE INPUT POINTER TO END OF SUBLINE OR LINE                      
LAEE8     LDB  #':            COLON = SUBLINE TERMINATOR CHARACTER 
LAEEA     FCB  SKP1LD         SKPILD SKIP ONE BYTE; LDA #$5F 
* ADVANCE BASIC’S INPUT POINTER TO END OF                      
* LINE - RETURN ADDRESS OF END OF LINE+1 IN X                      
LAEEB     CLRB                0 = LINE TERMINATOR CHARACTER 
          STB  CHARAC         TEMP STORE PRIMARY TERMINATOR CHARACTER 
          CLRB                0 (END OF LINE) = ALTERNATE TERM. CHAR. 
          LDX  CHARAD         LOAD X W/BASIC’S INPUT POINTER 
LAEF1     TFR  B,A            * CHANGE TERMINATOR CHARACTER 
          LDB  CHARAC         * FROM ACCB TO CHARAC - SAVE OLD TERMINATOR 
*         IN   CHARAC          
          STA  CHARAC         SWAP PRIMARY AND SECONDARY TERMINATORS 
LAEF7     LDA  ,X             GET NEXT INPUT CHARACTER 
          BEQ  LAEE7          RETURN IF 0 (END OF LINE) 
          PSHS B              SAVE TERMINATOR ON STACK 
          CMPA ,S+            COMPARE TO INPUT CHARACTER 
          BEQ  LAEE7          RETURN IF EQUAL 
          LEAX 1,X            MOVE POINTER UP ONE 
          CMPA #'"            CHECK FOR DOUBLE QUOTES 
          BEQ  LAEF1          BRANCH IF " - TOGGLE TERMINATOR CHARACTERS 
          INCA                * CHECK FOR $FF AND BRANCH IF 
          BNE  LAF0C          * NOT SECONDARY TOKEN 
          LEAX 1,X            MOVE INPUT POINTER 1 MORE IF SECONDARY 
LAF0C     CMPA #TOK_IF+1      TOKEN FOR IF? 
          BNE  LAEF7          NO - GET ANOTHER INPUT CHARACTER 
          INC  IFCTR          INCREMENT IF COUNTER - KEEP TRACK OF HOW MANY 
*                             ‘IF’ STATEMENTS ARE NESTED IN ONE LINE 
          BRA  LAEF7          GET ANOTHER INPUT CHARACTER 
                               
* IF                           
IF        JSR  LB141          EVALUATE NUMERIC EXPRESSION 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          CMPA #TOK_GO        TOKEN FOR GO 
          BEQ  LAF22          TREAT ‘GO’ THE SAME AS ‘THEN’ 
          LDB  #TOK_THEN      TOKEN FOR THEN 
          JSR  LB26F          DO A SYNTAX CHECK ON ACCB 
LAF22     LDA  FP0EXP         CHECK FOR TRUE/FALSE - FALSE IF FPA0 EXPONENT = ZERO 
          BNE  LAF39          BRANCH IF CONDITION TRUE 
          CLR  IFCTR          CLEAR FLAG - KEEP TRACK OF WHICH NESTED ELSE STATEMENT 
*                             TO SEARCH FOR IN NESTED ‘IF’ LOOPS 
LAF28     BSR  DATA           MOVE BASIC’S POINTER TO END OF SUBLINE 
          TSTA                * CHECK TO SEE IF END OF LINE OR SUBLINE 
          BEQ  LAEE7          * AND RETURN IF END OF LINE 
          JSR  GETNCH         GET AN INPUT CHARACTER FROM BASIC 
          CMPA #TOK_ELSE      TOKEN FOR ELSE 
          BNE  LAF28          IGNORE ALL DATA EXCEPT ‘ELSE’ UNTIL 
*                             END OF LINE (ZERO BYTE) 
          DEC  IFCTR          CHECK TO SEE IF YOU MUST SEARCH ANOTHER SUBLINE 
          BPL  LAF28          BRANCH TO SEARCH ANOTHER SUBLINE FOR ‘ELSE’ 
          JSR  GETNCH         GET AN INPUT CHARACTER FROM BASIC 
LAF39     JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          LBCS LAEA4          BRANCH TO ‘GOTO’ IF NUMERIC CHARACTER 
          JMP  LADC6          RETURN TO MAIN INTERPRETATION LOOP 
                               
* ON                           
ON        JSR  LB70B          EVALUATE EXPRESSION 
          LDB  #TOK_GO        TOKEN FOR GO 
          JSR  LB26F          SYNTAX CHECK FOR GO 
          PSHS A              SAVE NEW TOKEN (TO,SUB) 
          CMPA #TOK_SUB       TOKEN FOR SUB? 
          BEQ  LAF54          YES 
          CMPA #TOK_TO        TOKEN FOR TO? 
LAF52     BNE  LAED7          ‘SYNTAX’ ERROR IF NOT ‘SUB’ OR ‘TO’ 
LAF54     DEC  FPA0+3         DECREMENT IS BYTE OF MANTISSA OF FPA0 - THIS 
*                             IS THE ARGUMENT OF THE ‘ON’ STATEMENT 
          BNE  LAF5D          BRANCH IF NOT AT THE PROPER GOTO OR GOSUB LINE NUMBER 
          PULS B              GET BACK THE TOKEN FOLLOWING ‘GO’ 
          JMP  LAE88          GO DO A ‘GOTO’ OR ‘GOSUB’ 
LAF5D     JSR  GETNCH         GET A CHARACTER FROM BASIC 
          BSR  LAF67          CONVERT BASIC LINE NUMBER TO BINARY 
          CMPA #',            IS CHARACTER FOLLOWING LINE NUMBER A COMMA? 
          BEQ  LAF54          YES 
          PULS B,PC           IF NOT, FALL THROUGH TO NEXT COMMAND 
LAF67     LDX  ZERO           DEFAULT LINE NUMBER OF ZERO 
          STX  BINVAL         SAVE IT IN BINVAL 
*                              
* CONVERT LINE NUMBER TO BINARY - RETURN VALUE IN BINVAL                      
*                              
LAF6B     BCC  LAFCE          RETURN IF NOT NUMERIC CHARACTER 
          SUBA #'0            MASK OFF ASCII 
          STA  CHARAC         SAVE DIGIT IN VO1 
          LDD  BINVAL         GET ACCUMULATED LINE NUMBER VALUE 
          CMPA #24            LARGEST LINE NUMBER IS $F9FF (63999) - 
*         (24*256+255)*10+9                 
          BHI  LAF52          ‘SYNTAX’ ERROR IF TOO BIG 
* MULT ACCD X 10                      
          ASLB                * 
          ROLA                * TIMES 2 
          ASLB                = 
          ROLA                = TIMES 4 
          ADDD BINVAL         ADD 1 = TIMES 5 
          ASLB                * 
          ROLA                * TIMES 10 
          ADDB CHARAC         ADD NEXT DIGIT 
          ADCA #0             PROPAGATE CARRY 
          STD  BINVAL         SAVE NEW ACCUMULATED LINE NUMBER 
          JSR  GETNCH         GET NEXT CHARACTER FROM BASIC 
          BRA  LAF6B          LOOP- PROCESS NEXT DIGIT 
*                              
* LET (EXBAS)                      
* EVALUATE A NON-TOKEN EXPRESSION                      
* TARGET = REPLACEMENT                      
LET       JSR  LB357          FIND TARGET VARIABLE DESCRIPTOR 
          STX  VARDES         SAVE DESCRIPTOR ADDRESS OF 1ST EXPRESSION 
          LDB  #TOK_EQUALS    TOKEN FOR "=" 
          JSR  LB26F          DO A SYNTAX CHECK FOR ‘=‘ 
          LDA  VALTYP         * GET VARIABLE TYPE AND 
          PSHS A              * SAVE ON THE STACK 
          JSR  LB156          EVALUATE EXPRESSION 
          PULS A              * REGET VARIABLE TYPE OF 1ST EXPRESSION AND 
          RORA                * SET CARRY IF STRING 
          JSR  LB148          TYPE CHECK-TM ERROR IF VARIABLE TYPES ON 
*                             BOTH SIDES OF EQUALS SIGN NOT THE SAME 
          LBEQ LBC33          GO PUT FPA0 INTO VARIABLE DESCRIPTOR IF NUMERIC 
* MOVE A STRING WHOSE DESCRIPTOR IS LOCATED AT                      
* FPA0+2 INTO THE STRING SPACE. TRANSFER THE                      
* DESCRIPTOR ADDRESS TO THE ADDRESS IN VARDES                      
* DON’T MOVE THE STRING IF IT IS ALREADY IN THE                      
* STRING SPACE. REMOVE DESCRIPTOR FROM STRING                      
* STACK IF IT IS LAST ONE ON THE STACK                      
LAFA4     LDX  FPA0+2         POINT X TO DESCRIPTOR OF REPLACEMENT STRING 
          LDD  FRETOP         LOAD ACCD WITH START OF STRING SPACE 
          CMPD 2,X            IS THE STRING IN STRING SPACE? 
          BCC  LAFBE          BRANCH IF IT’S NOT IN THE STRING SPACE 
          CMPX VARTAB         COMPARE DESCRIPTOR ADDRESS TO START OF VARIABLES 
          BCS  LAFBE          BRANCH IF DESCRIPTOR ADDRESS NOT IN VARIABLES 
LAFB1     LDB  ,X             GET LENGTH OF REPLACEMENT STRING 
          JSR  LB50D          RESERVE ACCB BYTES OF STRING SPACE 
          LDX  V4D            GET DESCRIPTOR ADDRESS BACK 
          JSR  LB643          MOVE STRING INTO STRING SPACE 
          LDX  #STRDES        POINT X TO TEMP STRING DESCRIPTOR ADDRESS 
LAFBE     STX  V4D            SAVE STRING DESCRIPTOR ADDRESS IN V4D 
          JSR  LB675          REMOVE STRING DESCRIPTOR IF LAST ONE 
*              ON STRING STACK  
          LDU  V4D            POINT U TO REPLACEMENT DESCRIPTOR ADDRESS 
          LDX  VARDES         GET TARGET DESCRIPTOR ADDRESS 
          PULU A,B,Y          GET LENGTH AND START OF REPLACEMENT STRING 
          STA  ,X             * SAVE STRING LENGTH AND START IN 
          STY  2,X            * TARGET DESCRIPTOR LOCATION 
LAFCE     RTS                  
                               
LAFCF     FCC  "?REDO"        ?REDO MESSAGE 
          FCB  CR,$00          
                               
LAFD6                          
LAFDC     JMP  LAC46          JMP TO ERROR HANDLER 
LAFDF     LDA  INPFLG         = GET THE INPUT FLAG AND BRANCH 
          BEQ  LAFEA          = IF ‘INPUT’ 
          LDX  DATTXT         * GET LINE NUMBER WHERE THE ERROR OCCURRED 
          STX  CURLIN         * AND USE IT AS THE CURRENT LINE NUMBER 
          JMP  LB277          ‘SYNTAX ERROR’ 
LAFEA     LDX  #LAFCF-1       * POINT X TO ‘?REDO’ AND PRINT 
          JSR  LB99C          * IT ON THE SCREEN 
          LDX  TINPTR         = GET THE SAVED ABSOLUTE ADDRESS OF 
          STX  CHARAD         = INPUT POINTER AND RESTORE IT 
          RTS                  
*                              
* INPUT                        
INPUT     LDB  #11*2          ‘ID’ ERROR 
          LDX  CURLIN         GET CURRENT LINE NUMBER 
          LEAX 1,X            ADD ONE 
          BEQ  LAFDC          ‘ID’ ERROR BRANCH IF DIRECT MODE 
          BSR  LB00F          GET SOME INPUT DATA - WAS LB002 
          RTS                  
LB00F     CMPA #'"            CHECK FOR PROMPT STRING DELIMITER 
          BNE  LB01E          BRANCH IF NO PROMPT STRING 
          JSR  LB244          PUT PROMPT STRING ON STRING STACK 
          LDB  #';            * 
          JSR  LB26F          * DO A SYNTAX CHECK FOR SEMICOLON 
          JSR  LB99F          PRINT MESSAGE TO CONSOLE OUT 
LB01E     LDX  #LINBUF        POINT TO BASIC’S LINE BUFFER 
          CLR  ,X             CLEAR 1ST BYTE - FLAG TO INDICATE NO DATA 
*              IN LINE BUFFER  
          BSR  LB02F          INPUT A STRING TO LINE BUFFER 
          LDB  #',            * INSERT A COMMA AT THE END 
          STB  ,X             * OF THE LINE INPUT BUFFER 
          BRA  LB049           
* FILL BASIC’S LINE INPUT BUFFER CONSOLE IN                      
LB02F     JSR  LB9AF          SEND A "?" TO CONSOLE OUT 
          JSR  LB9AC          SEND A ‘SPACE’ TO CONSOLE OUT 
LB035     JSR  LA390          GO READ IN A BASIC LINE 
          BCC  LB03F          BRANCH IF ENTER KEY ENDED ENTRY 
          LEAS 4,S            PURGE TWO RETURN ADDRESSES OFF THE STACK 
          JMP  LAE11          GO DO A ‘STOP’ IF BREAK KEY ENDED LINE ENTRY 
LB03F     LDB  #2*23          ‘INPUT PAST END OF FILE’ ERROR 
          RTS                  
*                              
* READ                         
READ      LDX  DATPTR         GET ‘READ’ START ADDRESS 
          FCB  SKP1LD         SKIP ONE BYTE - LDA #*$4F 
LB049     CLRA                ‘INPUT’ ENTRY POINT: INPUT FLAG = 0 
          STA  INPFLG         SET INPUT FLAG; 0 = INPUT: <> 0 = READ 
          STX  DATTMP         SAVE ‘READ’ START ADDRESS/’INPUT’ BUFFER START 
LB04E     JSR  LB357          EVALUATE A VARIABLE 
          STX  VARDES         SAVE DESCRIPTOR ADDRESS 
          LDX  CHARAD         * GET BASIC’S INPUT POINTER 
          STX  BINVAL         * AND SAVE IT 
          LDX  DATTMP         GET ‘READ’ ADDRESS START/’INPUT’ BUFFER POINTER 
          LDA  ,X             GET A CHARACTER FROM THE BASIC PROGRAM 
          BNE  LB069          BRANCH IF NOT END OF LINE 
          LDA  INPFLG         * CHECK INPUT FLAG AND BRANCH 
          BNE  LB0B9          * IF LOOKING FOR DATA (READ) 
* NO DATA IN ‘INPUT’ LINE BUFFER AND/OR INPUT                      
* NOT COMING FROM SCREEN                      
          JSR  LB9AF          SEND A '?' TO CONSOLE OUT 
          BSR  LB02F          FILL INPUT BUFFER FROM CONSOLE IN 
LB069     STX  CHARAD         RESET BASIC’S INPUT POINTER 
          JSR  GETNCH         GET A CHARACTER FROM BASIC 
          LDB  VALTYP         * CHECK VARIABLE TYPE AND 
          BEQ  LB098          * BRANCH IF NUMERIC 
* READ/INPUT A STRING VARIABLE                      
          LDX  CHARAD         LOAD X WITH CURRENT BASIC INPUT POINTER 
          STA  CHARAC         SAVE CURRENT INPUT CHARACTER 
          CMPA #'"            CHECK FOR STRING DELIMITER 
          BEQ  LB08B          BRANCH IF STRING DELIMITER 
          LEAX -1,X           BACK UP POINTER 
          CLRA                * ZERO = END OF LINE CHARACTER 
          STA  CHARAC         * SAVE AS TERMINATOR 
          JSR  LA35F          SET UP PRINT PARAMETERS 
          LDA  #':            END OF SUBLINE CHARACTER 
          STA  CHARAC         SAVE AS TERMINATOR I 
          LDA  #',            COMMA 
LB08B     STA  ENDCHR         SAVE AS TERMINATOR 2 
          JSR  LB51E          STRIP A STRING FROM THE INPUT BUFFER 
          JSR  LB249          MOVE INPUT POINTER TO END OF STRING 
          JSR  LAFA4          PUT A STRING INTO THE STRING SPACE IF NECESSARY 
          BRA  LB09E          CHECK FOR ANOTHER DATA ITEM 
* SAVE A NUMERIC VALUE IN A READ OR INPUT DATA ITEM                      
LB098     JSR  LBD12          CONVERT AN ASCII STRING TO FP NUMBER 
          JSR  LBC33          PACK FPA0 AND STORE IT IN ADDRESS IN VARDES - 
*                             INPUT OR READ DATA ITEM 
LB09E     JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          BEQ  LB0A8          BRANCH IF END OF LINE 
          CMPA #',            CHECK FOR A COMMA 
          LBNE LAFD6          BAD FILE DATA' ERROR OR RETRY 
LB0A8     LDX  CHARAD         * GET CURRENT INPUT 
          STX  DATTMP         * POINTER (USED AS A DATA POINTER) AND SAVE IT 
          LDX  BINVAL         * RESET INPUT POINTER TO INPUT OR 
          STX  CHARAD         * READ STATEMENT 
          JSR  GETCCH         GET CURRENT CHARACTER FROM BASIC 
          BEQ  LB0D5          BRANCH IF END OF LINE - EXIT COMMAND 
          JSR  LB26D          SYNTAX CHECK FOR COMMA 
          BRA  LB04E          GET ANOTHER INPUT OR READ ITEM 
* SEARCH FROM ADDRESS IN X FOR                      
* 1ST OCCURENCE OF THE TOKEN FOR DATA                      
LB0B9     STX  CHARAD         RESET BASIC’S INPUT POINTER 
          JSR  LAEE8          SEARCH FOR END OF CURRENT LINE OR SUBLINE 
          LEAX 1,X            MOVE X ONE PAST END OF LINE 
          TSTA                CHECK FOR END OF LINE 
          BNE  LB0CD          BRANCH IF END OF SUBLINE 
          LDB  #2*3           ‘OUT OF DATA’ ERROR 
          LDU  ,X++           GET NEXT 2 CHARACTERS 
          BEQ  LB10A          ‘OD’ ERROR IF END OF PROGRAM 
          LDD  ,X++           GET BASIC LINE NUMBER AND 
          STD  DATTXT         SAVE IT IN DATTXT 
LB0CD     LDA  ,X             GET AN INPUT CHARACTER 
          CMPA #TOK_DATA      DATA TOKEN? 
          BNE  LB0B9          NO — KEEP LOOKING 
          BRA  LB069          YES 
* EXIT READ AND INPUT COMMANDS                      
LB0D5     LDX  DATTMP         GET DATA POINTER 
          LDB  INPFLG         * CHECK INPUT FLAG 
          LBNE LADE8          * SAVE NEW DATA POINTER IF READ 
          LDA  ,X             = CHECK NEXT CHARACTER IN ‘INPUT’ BUFFER 
          BEQ  LB0E7          = 
          LDX  #LB0E8-1       POINT X TO ‘?EXTRA IGNORED’ 
          JMP  LB99C          PRINT THE MESSAGE 
LB0E7     RTS                  
                               
LB0E8     FCC  "?EXTRA IGNORED" ?EXTRA IGNORED MESSAGE 
                               
                               
          FCB  CR,$00          
                               
* NEXT                         
NEXT      BNE  LB0FE          BRANCH IF ARGUMENT GIVEN 
          LDX  ZERO           X = 0: DEFAULT FOR NO ARGUMENT 
          BRA  LB101           
LB0FE     JSR  LB357          EVALUATE AN ALPHA EXPRESSION 
LB101     STX  VARDES         SAVE VARIABLE DESCRIPTOR POINTER 
          JSR  LABF9          GO SCAN FOR ‘FOR/NEXT’ DATA ON STACK 
          BEQ  LB10C          BRANCH IF DATA FOUND 
          LDB  #0             ‘NEXT WITHOUT FOR’ ERROR (SHOULD BE CLRB) 
LB10A     BRA  LB153          PROCESS ERROR 
LB10C     TFR  X,S            POINT S TO START OF ‘FOR/NEXT’ DATA 
          LEAX 3,X            POINT X TO FP VALUE OF STEP 
          JSR  LBC14          COPY A FP NUMBER FROM (X) TO FPA0 
          LDA  8,S            GET THE DIRECTION OF STEP 
          STA  FP0SGN         SAVE IT AS THE SIGN OF FPA0 
          LDX  VARDES         POINT (X) TO INDEX VARIABLE DESCRIPTOR 
          JSR  LB9C2          ADD (X) TO FPA0 (STEP TO INDEX) 
          JSR  LBC33          PACK FPA0 AND STORE IT IN ADDRESS 
*                             CONTAINED IN VARDES 
          LEAX 9,S            POINT (X) TO TERMINAL VALUE OF INDEX 
          JSR  LBC96          COMPARE CURRENT INDEX VALUE TO TERMINAL VALUE OF INDEX 
          SUBB 8,S            ACCB = 0 IF TERMINAL VALUE=CURRENT VALUE AND STEP=0 OR IF 
*                             STEP IS POSITIVE AND CURRENT VALUE>TERMINAL VALUE OR 
*                             STEP IS NEGATIVE AND CURRENT VALUE<TERMINAL VALUE 
          BEQ  LB134          BRANCH IF ‘FOR/NEXT’ LOOP DONE 
          LDX  14,S           * GET LINE NUMBER AND 
          STX  CURLIN         * BASIC POINTER OF 
          LDX  16,S           * STATEMENT FOLLOWING THE 
          STX  CHARAD         * PROPER FOR STATEMENT 
LB131     JMP  LAD9E          JUMP BACK TO COMMAND INTEPR. LOOP 
LB134     LEAS 18,S           PULL THE ‘FOR-NEXT’ DATA OFF THE STACK 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          CMPA #',            CHECK FOR ANOTHER ARGUMENT 
          BNE  LB131          RETURN IF NONE 
          JSR  GETNCH         GET NEXT CHARACTER FROM BASIC 
          BSR  LB0FE          BSR SIMULATES A CALL TO ‘NEXT’ FROM COMMAND LOOP 
                               
                               
LB141     BSR  LB156          EVALUATE EXPRESSION AND DO A TYPE CHECK FOR NUMERIC 
LB143     ANDCC #$FE           CLEAR CARRY FLAG 
LB145     FCB  $7D            OP CODE OF TST $1A01 - SKIP TWO BYTES (DO 
*              NOT CHANGE CARRY FLAG)  
LB146     ORCC #1             SET CARRY 
                               
* STRING TYPE MODE CHECK - IF ENTERED AT LB146 THEN VALTYP PLUS IS 'TM' ERROR                      
* NUMERIC TYPE MODE CHECK - IF ENTERED AT LB143 THEN VALTYP MINUS IS 'TM' ERROR                      
* IF ENTERED AT LB148, A TYPE CHECK IS DONE ON VALTYP                      
* IF ENTERED WITH CARRY SET, THEN 'TM' ERROR IF NUMERIC                      
* IF ENTERED WITH CARRY CLEAR, THEN 'TM' ERROR IF STRING.                      
LB148     TST  VALTYP         TEST TYPE FLAG; DO NOT CHANGE CARRY 
          BCS  LB14F          BRANCH IF STRING 
          BPL  LB0E7          RETURN ON PLUS 
          FCB  SKP2           SKIP 2 BYTES - ‘TM’ ERROR 
LB14F     BMI  LB0E7          RETURN ON MINUS 
          LDB  #12*2          ‘TYPE M1SMATCH’ ERROR 
LB153     JMP  LAC46          PROCESS ERROR 
* EVALUATE EXPRESSION                      
LB156     BSR  LB1C6          BACK UP INPUT POINTER 
LB158     CLRA                END OF OPERATION PRECEDENCE FLAG 
          FCB  SKP2           SKIP TWO BYTES 
LB15A     PSHS B              SAVE FLAG (RELATIONAL OPERATOR FLAG) 
          PSHS A              SAVE FLAG (PRECEDENCE FLAG) 
          LDB  #1             * 
          JSR  LAC33          * SEE IF ROOM IN FREE RAM FOR (B) WORDS 
          JSR  LB223          GO EVALUATE AN EXPRESSION 
          CLR  TRELFL         RESET RELATIONAL OPERATOR FLAG 
LB168     JSR  GETCCH         GET CURRENT INPUT CHARACTER 
* CHECK FOR RELATIONAL OPERATORS                      
LB16A     SUBA #TOK_GREATER   TOKEN FOR > 
          BCS  LB181          BRANCH IF LESS THAN RELATIONAL OPERATORS 
          CMPA #3             * 
          BCC  LB181          * BRANCH IF GREATER THAN RELATIONAL OPERATORS 
          CMPA #1             SET CARRY IF ‘>‘ 
          ROLA                CARRY TO BIT 0 
          EORA TRELFL         * CARRY SET IF 
          CMPA TRELFL         * TRELFL = ACCA 
          BCS  LB1DF          BRANCH IF SYNTAX ERROR : == << OR >> 
          STA  TRELFL         BIT 0: >, BIT 1 =, BIT 2: < 
          JSR  GETNCH         GET AN INPUT CHARACTER 
          BRA  LB16A          CHECK FOR ANOTHER RELATIONAL OPERATOR 
*                              
LB181     LDB  TRELFL         GET RELATIONAL OPERATOR FLAG 
          BNE  LB1B8          BRANCH IF RELATIONAL COMPARISON 
          LBCC LB1F4          BRANCH IF > RELATIONAL OPERATOR 
          ADDA #7             SEVEN ARITHMETIC/LOGICAL OPERATORS 
          BCC  LB1F4          BRANCH IF NOT ARITHMETIC/LOGICAL OPERATOR 
          ADCA VALTYP         ADD CARRY, NUMERIC FLAG AND MODIFIED TOKEN NUMBER 
          LBEQ LB60F          BRANCH IF VALTYP = FF, AND ACCA = ‘+‘ TOKEN - 
*                             CONCATENATE TWO STRINGS 
          ADCA #-1            RESTORE ARITHMETIC/LOGICAL OPERATOR NUMBER 
          PSHS A              * STORE OPERATOR NUMBER ON STACK; MULTIPLY IT BY 2 
          ASLA                * THEN ADD THE STORED STACK DATA = MULTIPLY 
          ADDA ,S+            * X 3; 3 BYTE/TABLE ENTRY 
          LDX  #LAA51         JUMP TABLE FOR ARITHMETIC & LOGICAL OPERATORS 
          LEAX A,X            POINT X TO PROPER TABLE 
LB19F     PULS A              GET PRECEDENCE FLAG FROM STACK 
          CMPA ,X             COMPARE TO CURRENT OPERATOR 
          BCC  LB1FA          BRANCH IF STACK OPERATOR > CURRENT OPERATOR 
          BSR  LB143          ‘TM’ ERROR IF VARIABLE TYPE = STRING 
                               
* OPERATION BEING PROCESSED IS OF HIGHER PRECEDENCE THAN THE PREVIOUS OPERATION.                      
LB1A7     PSHS A              SAVE PRECEDENCE FLAG 
          BSR  LB1D4          PUSH OPERATOR ROUTINE ADDRESS AND FPA0 ONTO STACK 
          LDX  RELPTR         GET POINTER TO ARITHMETIC/LOGICAL TABLE ENTRY FOR 
*                             LAST CALCULATED OPERATION 
          PULS A              GET PRECEDENCE FLAG OF PREVIOUS OPERATION 
          BNE  LB1CE          BRANCH IF NOT END OF OPERATION 
          TSTA                CHECK TYPE OF PRECEDENCE FLAG 
          LBEQ LB220          BRANCH IF END OF EXPRESSION OR SUB-EXPRESSION 
          BRA  LB203          EVALUATE AN OPERATION 
                               
LB1B8     ASL  VALTYP         BIT 7 OF TYPE FLAG TO CARRY 
          ROLB                SHIFT RELATIONAL FLAG LEFT - VALTYP TO BIT 0 
          BSR  LB1C6          MOVE THE INPUT POINTER BACK ONE 
          LDX  #LB1CB         POINT X TO RELATIONAL COMPARISON JUMP TABLE 
          STB  TRELFL         SAVE RELATIONAL COMPARISON DATA 
          CLR  VALTYP         SET VARIABLE TYPE TO NUMERIC 
          BRA  LB19F          PERFORM OPERATION OR SAVE ON STACK 
                               
LB1C6     LDX  CHARAD         * GET BASIC’S INPUT POINTER AND 
          JMP  LAEBB          * MOVE IT BACK ONE 
* RELATIONAL COMPARISON JUMP TABLE                      
LB1CB     FCB  $64            RELATIONAL COMPARISON FLAG 
LB1CC     FDB  LB2F4          JUMP ADDRESS 
                               
LB1CE     CMPA ,X             COMPARE PRECEDENCE OF LAST DONE OPERATION TO 
*         NEXT TO BE DONE OPERATION  
          BCC  LB203          EVALUATE OPERATION IF LOWER PRECEDENCE 
          BRA  LB1A7          PUSH OPERATION DATA ON STACK IF HIGHER PRECEDENCE 
                               
* PUSH OPERATOR EVALUATION ADDRESS AND FPA0 ONTO STACK AND EVALUATE ANOTHER EXPR                      
LB1D4     LDD  1,X            GET ADDRESS OF OPERATOR ROUTINE 
          PSHS B,A            SAVE IT ON THE STACK 
          BSR  LB1E2          PUSH FPA0 ONTO STACK 
          LDB  TRELFL         GET BACK RELATIONAL OPERATOR FLAG 
          LBRA LB15A          EVALUATE ANOTHER EXPRESSION 
LB1DF     JMP  LB277          ‘SYNTAX ERROR’ 
* PUSH FPA0 ONTO THE STACK. ,S   = EXPONENT      
* 1-2,S =HIGH ORDER MANTISSA 3-4,S = LOW ORDER MANTISSA  
* 5,S = SIGN RETURN WITH PRECEDENCE CODE IN ACCA  
LB1E2     LDB  FP0SGN         GET SIGN OF FPA0 MANTISSA 
          LDA  ,X             GET PRECEDENCE CODE TO ACCA 
LB1E6     PULS Y              GET RETURN ADDRESS FROM STACK & PUT IT IN Y 
          PSHS B              SAVE ACCB ON STACK 
LB1EA     LDB  FP0EXP         * PUSH FPA0 ONTO THE STACK 
          LDX  FPA0           * 
          LDU  FPA0+2         * 
          PSHS U,X,B          * 
          JMP  ,Y             JUMP TO ADDRESS IN Y 
                               
* BRANCH HERE IF NON-OPERATOR CHARACTER FOUND - USUALLY ‘)‘ OR END OF LINE                      
LB1F4     LDX  ZERO           POINT X TO DUMMY VALUE (ZERO) 
          LDA  ,S+            GET PRECEDENCE FLAG FROM STACK 
          BEQ  LB220          BRANCH IF END OF EXPRESSION 
LB1FA     CMPA #$64           * CHECK FOR RELATIONAL COMPARISON FLAG 
          BEQ  LB201          * AND BRANCH IF RELATIONAL COMPARISON 
          JSR  LB143          ‘TM’ ERROR IF VARIABLE TYPE = STRING 
LB201     STX  RELPTR         SAVE POINTER TO OPERATOR ROUTINE 
LB203     PULS B              GET RELATIONAL OPERATOR FLAG FROM STACK 
          CMPA #$5A           CHECK FOR ‘NOT’ OPERATOR 
          BEQ  LB222          RETURN IF ‘NOT’ - NO RELATIONAL COMPARISON 
          CMPA #$7D           CHECK FOR NEGATION (UNARY) FLAG 
          BEQ  LB222          RETURN IF NEGATION - NO RELATIONAL COMPARISON 
                               
* EVALUATE AN OPERATION. EIGHT BYTES WILL BE STORED ON STACK, FIRST SIX BYTES                      
* ARE A TEMPORARY FLOATING POINT RESULT THEN THE ADDRESS OF ROUTINE WHICH                      
* WILL EVALUATE THE OPERATION. THE RTS AT END OF ROUTINE WILL VECTOR                      
* TO EVALUATING ROUTINE.                      
          LSRB                = ROTATE VALTYP BIT INTO CARRY 
          STB  RELFLG         = FLAG AND SAVE NEW RELFLG 
          PULS A,X,U          * PULL A FP VALUE OFF OF THE STACK 
          STA  FP1EXP         * AND SAVE IT IN FPA1 
          STX  FPA1           * 
          STU  FPA1+2         * 
          PULS B              = GET MANTISSA SIGN AND 
          STB  FP1SGN         = SAVE IT IN FPA1 
          EORB FP0SGN         EOR IT WITH FPA1 MANTISSA SIGN 
          STB  RESSGN         SAVE IT IN RESULT SIGN BYTE 
LB220     LDB  FP0EXP         GET EXPONENT OF FPA0 
LB222     RTS                  
                               
LB223     JSR  XVEC15         CALL EXTENDED BASIC ADD-IN 
          CLR  VALTYP         INITIALIZE TYPE FLAG TO NUMERIC 
          JSR  GETNCH         GET AN INPUT CHAR 
          BCC  LB22F          BRANCH IF NOT NUMERIC 
LB22C     JMP  LBD12          CONVERT ASCII STRING TO FLOATING POINT - 
*         RETURN RESULT IN FPA0  
* PROCESS A NON NUMERIC FIRST CHARACTER                      
LB22F     JSR  LB3A2          SET CARRY IF NOT ALPHA 
          BCC  LB284          BRANCH IF ALPHA CHARACTER 
          CMPA #'.            IS IT ‘.‘ (DECIMAL POINT)? 
          BEQ  LB22C          CONVERT ASCII STRING TO FLOATING POINT 
          CMPA #TOK_MINUS     MINUS TOKEN 
          BEQ  LB27C          YES - GO PROCESS THE MINUS OPERATOR 
          CMPA #TOK_PLUS      PLUS TOKEN 
          BEQ  LB223          YES - GET ANOTHER CHARACTER 
          CMPA #'"            STRING DELIMITER? 
          BNE  LB24E          NO 
LB244     LDX  CHARAD         CURRENT BASIC POINTER TO X 
          JSR  LB518          SAVE STRING ON STRING STACK 
LB249     LDX  COEFPT         * GET ADDRESS OF END OF STRING AND 
          STX  CHARAD         * PUT BASIC’S INPUT POINTER THERE 
          RTS                  
LB24E     CMPA #TOK_NOT       NOT TOKEN? 
          BNE  LB25F          NO 
* PROCESS THE NOT OPERATOR                      
          LDA  #$5A           ‘NOT’ PRECEDENCE FLAG 
          JSR  LB15A          PROCESS OPERATION FOLLOWING ‘NOT’ 
          JSR  INTCNV         CONVERT FPA0 TO INTEGER IN ACCD 
          COMA                * ‘NOT’ THE INTEGER 
          COMB                * 
          JMP  GIVABF         CONVERT ACCD TO FLOATING POINT (FPA0) 
LB25F     INCA                CHECK FOR TOKENS PRECEEDED BY $FF 
          BEQ  LB290          IT WAS PRECEEDED BY $FF 
LB262     BSR  LB26A          SYNTAX CHECK FOR A ‘(‘ 
          JSR  LB156          EVALUATE EXPRESSIONS WITHIN PARENTHESES AT 
*         HIGHEST PRECEDENCE      
LB267     LDB  #')            SYNTAX CHECK FOR ‘)‘ 
          FCB  SKP2           SKIP 2 BYTES 
LB26A     LDB  #'(            SYNTAX CHECK FOR ‘(‘ 
          FCB  SKP2           SKIP 2 BYTES 
LB26D     LDB  #',            SYNTAX CHECK FOR COMMA 
LB26F     CMPB [CHARAD]       * COMPARE ACCB TO CURRENT INPUT 
          BNE  LB277          * CHARACTER - SYNTAX ERROR IF NO MATCH 
          JMP  GETNCH         GET A CHARACTER FROM BASIC 
LB277     LDB  #2*1           SYNTAX ERROR 
          JMP  LAC46          JUMP TO ERROR HANDLER 
                               
* PROCESS THE MINUS (UNARY) OPERATOR                      
LB27C     LDA  #$7D           MINUS (UNARY) PRECEDENCE FLAG 
          JSR  LB15A          PROCESS OPERATION FOLLOWING ‘UNARY’ NEGATION 
          JMP  LBEE9          CHANGE SIGN OF FPA0 MANTISSA 
                               
* EVALUATE ALPHA EXPRESSION                      
LB284     JSR  LB357          FIND THE DESCRIPTOR ADDRESS OF A VARIABLE 
LB287     STX  FPA0+2         SAVE DESCRIPTOR ADDRESS IN FPA0 
          LDA  VALTYP         TEST VARIABLE TYPE 
          BNE  LB222          RETURN IF STRING 
          JMP  LBC14          COPY A FP NUMBER FROM (X) TO FPA0 
                               
* EVALUATING A SECONDARY TOKEN                      
LB290     JSR  GETNCH         GET AN INPUT CHARACTER (SECONDARY TOKEN) 
          TFR  A,B            SAVE IT IN ACCB 
          ASLB                X2 & BET RID OF BIT 7 
          JSR  GETNCH         GET ANOTHER INPUT CHARACTER 
          CMPB #NUM_SEC_FNS-1*2 29 SECONDARY FUNCTIONS - 1 
          BLS  LB29F          BRANCH IF COLOR BASIC TOKEN 
          JMP  LB277          SYNTAX ERROR 
LB29F     PSHS B              SAVE TOKEN OFFSET ON STACK 
          CMPB #TOK_LEFT-$80*2 CHECK FOR TOKEN WITH AN ARGUMENT 
          BCS  LB2C7          DO SECONDARIES STRING$ OR LESS 
          CMPB #TOK_INKEY-$80*2 * 
          BCC  LB2C9          * DO SECONDARIES $92 (INKEY$) OR > 
          BSR  LB26A          SYNTAX CHECK FOR A ‘(‘ 
          LDA  ,S             GET TOKEN NUMBER 
* DO SECONDARIES (LEFT$, RIGHT$, MID$)                      
          JSR  LB156          EVALUATE FIRST STRING IN ARGUMENT 
          BSR  LB26D          SYNTAX CHECK FOR A COMMA 
          JSR  LB146          ‘TM’ ERROR IF NUMERIC VARiABLE 
          PULS A              GET TOKEN OFFSET FROM STACK 
          LDU  FPA0+2         POINT U TO STRING DESCRIPTOR 
          PSHS U,A            SAVE TOKEN OFFSET AND DESCRIPTOR ADDRESS 
          JSR  LB70B          EVALUATE FIRST NUMERIC ARGUMENT 
          PULS A              GET TOKEN OFFSET FROM STACK 
          PSHS B,A            SAVE TOKEN OFFSET AND NUMERIC ARGUMENT 
          FCB  $8E            OP CODE OF LDX# - SKlP 2 BYTES 
LB2C7     BSR  LB262          SYNTAX CHECK FOR A ‘(‘ 
LB2C9     PULS B              GET TOKEN OFFSET 
          LDX  COMVEC+8       GET SECONDARY FUNCTION JUMP TABLE ADDRESS 
LB2CE     ABX                 ADD IN COMMAND OFFSET 
*                              
* HERE IS WHERE WE BRANCH TO A SECONDARY FUNCTION                      
          JSR  [,X]           GO DO AN SECONDARY FUNCTION 
          JMP  LB143          ‘TM’ ERROR IF VARIABLE TYPE = STRING 
                               
* LOGICAL OPERATOR ‘OR’ JUMPS HERE                      
LB2D4     FCB  SKP1LD         SKIP ONE BYTE - ‘OR’ FLAG = $4F 
                               
* LOGICAL OPERATOR ‘AND’ JUMPS HERE                      
LB2D5     CLRA                AND FLAG = 0 
          STA  TMPLOC         AND/OR FLAG 
          JSR  INTCNV         CONVERT FPA0 INTO AN INTEGER IN ACCD 
          STD  CHARAC         TEMP SAVE ACCD 
          JSR  LBC4A          MOVE FPA1 TO FPA0 
          JSR  INTCNV         CONVERT FPA0 INTO AN INTEGER IN ACCD 
          TST  TMPLOC         CHECK AND/OR FLAG 
          BNE  LB2ED          BRANCH IF OR 
          ANDA CHARAC         * ‘AND’ ACCD WITH FPA0 INTEGER 
          ANDB ENDCHR         * STORED IN ENDCHR 
          BRA  LB2F1          CONVERT TO FP 
LB2ED     ORA  CHARAC         * ‘OR’ ACCD WITH FPA0 INTEGER 
          ORB  ENDCHR         * STORED IN CHARAC 
LB2F1     JMP  GIVABF         CONVERT THE VALUE IN ACCD INTO A FP NUMBER 
                               
* RELATIONAL COMPARISON PROCESS HANDLER                      
LB2F4     JSR  LB148          ‘TM’ ERROR IF TYPE MISMATCH 
          BNE  LB309          BRANCH IF STRING VARIABLE 
          LDA  FP1SGN         * ‘PACK’ THE MANTISSA 
          ORA  #$7F           * SIGN OF FPA1 INTO 
          ANDA FPA1           * BIT 7 OF THE 
          STA  FPA1           * MANTISSA MS BYTE 
          LDX  #FP1EXP        POINT X TO FPA1 
          JSR  LBC96          COMPARE FPA0 TO FPA1 
          BRA  LB33F          CHECK TRUTH OF RELATIONAL COMPARISON 
                               
* RELATIONAL COMPARISON OF STRINGS                      
LB309     CLR  VALTYP         SET VARIABLE TYPE TO NUMERIC 
          DEC  TRELFL         REMOVE STRING TYPE FLAG (BIT0=1 FOR STRINGS) FROM THE 
*                             DESIRED RELATIONAL COMPARISON DATA 
          JSR  LB657          GET LENGTH AND ADDRESS OF STRING WHOSE 
*                             DESCRIPTOR ADDRESS IS IN THE BOTTOM OF FPA0 
          STB  STRDES         * SAVE LENGTH AND ADDRESS IN TEMPORARY 
          STX  STRDES+2       * DESCRIPTOR (STRING B) 
          LDX  FPA1+2         = RETURN LENGTH AND ADDRESS OF STRING 
          JSR  LB659          = WHOSE DESCRIPTOR ADDRESS IS STORED IN FPA1+2 
          LDA  STRDES         LOAD ACCA WITH LENGTH OF STRING B 
          PSHS B              SAVE LENGTH A ON STACK 
          SUBA ,S+            SUBTRACT LENGTH A FROM LENGTH B 
          BEQ  LB328          BRANCH IF STRINGS OF EQUAL LENGTH 
          LDA  #1             TRUE FLAG 
          BCC  LB328          TRUE IF LENGTH B > LENGTH A 
          LDB  STRDES         LOAD ACCB WITH LENGTH B 
          NEGA                SET FLAG = FALSE (1FF) 
LB328     STA  FP0SGN         SAVE TRUE/FALSE FLAG 
          LDU  STRDES+2       POINT U TO START OF STRING 
          INCB                COMPENSATE FOR THE DECB BELOW 
* ENTER WITH ACCB CONTAINING LENGTH OF SHORTER STRING                      
LB32D     DECB                DECREMENT SHORTER STRING LENGTH 
          BNE  LB334          BRANCH IF ALL OF STRING NOT COMPARED 
          LDB  FP0SGN         GET TRUE/FALSE FLAB 
          BRA  LB33F          CHECK TRUTH OF RELATIONAL COMPARISON 
LB334     LDA  ,X+            GET A BYTE FROM STRING A 
          CMPA ,U+            COMPARE TO STRING B 
          BEQ  LB32D          CHECK ANOTHER CHARACTER IF = 
          LDB  #$FF           FALSE FLAG IF STRING A > B 
          BCC  LB33F          BRANCH IF STRING A > STRING B 
          NEGB                SET FLAG = TRUE 
                               
* DETERMINE TRUTH OF COMPARISON - RETURN RESULT IN FPA0                      
LB33F     ADDB #1             CONVERT $FF,0,1 TO 0,1,2 
          ROLB                NOW IT’S 1,2,4 FOR > = < 
          ANDB RELFLG         ‘AND’ THE ACTUAL COMPARISON WITH THE DESIRED - 
COMPARISON                      
          BEQ  LB348          BRANCH IF FALSE (NO MATCHING BITS) 
          LDB  #$FF           TRUE FLAG 
LB348     JMP  LBC7C          CONVERT ACCB INTO FP NUMBER IN FPA0 
                               
* DIM                          
LB34B     JSR  LB26D          SYNTAX CHECK FOR COMMA 
DIM       LDB  #1             DIMENSION FLAG 
          BSR  LB35A          SAVE ARRAY SPACE FOR THIS VARIABLE 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          BNE  LB34B          KEEP DIMENSIONING IF NOT END OF LINE 
          RTS                  
* EVALUATE A VARIABLE - RETURN X AND                      
* VARPTR POINTING TO VARIABLE DESCRIPTOR                      
* EACH VARIABLE REQUIRES 7 BYTES - THE FIRST TWO                      
* BYTES ARE THE VARIABLE NAME AND THE NEXT 5                      
* BYTES ARE THE DESCRIPTOR. IF BIT 7 OF THE                      
* FIRST BYTE OF VARlABLE NAME IS SET, THE                      
* VARIABLE IS A DEF FN VARIABLE. IF BIT 7 OF                      
* THE SECOND BYTE OF VARIABLE NAME IS SET, THE                      
* VARIABLE IS A STRING, OTHERWISE THE VARIABLE                      
* IS NUMERIC.                      
* IF THE VARIABLE IS NOT FOUND, A ZERO VARIABLE IS                      
* INSERTED INTO THE VARIABLE SPACE                      
LB357     CLRB                DIMENSION FLAG = 0; DO NOT SET UP AN ARRAY 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
LB35A     STB  DIMFLG         SAVE ARRAY FLAG 
* ENTRY POINT FOR DEF FN VARIABLE SEARCH                      
LB35C     STA  VARNAM         SAVE INPUT CHARACTER 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          BSR  LB3A2          SET CARRY IF NOT ALPHA 
          LBCS LB277          SYNTAX ERROR IF NOT ALPHA 
          CLRB                DEFAULT 2ND VARIABLE CHARACTER TO ZERO 
          STB  VALTYP         SET VARIABLE TYPE TO NUMERIC 
          JSR  GETNCH         GET ANOTHER CHARACTER FROM BASIC 
          BCS  LB371          BRANCH IF NUMERIC (2ND CHARACTER IN 
*                             VARIABLE MAY BE NUMERIC) 
          BSR  LB3A2          SET CARRY IF NOT ALPHA 
          BCS  LB37B          BRANCH IF NOT ALPHA 
LB371     TFR  A,B            SAVE 2ND CHARACTER IN ACCB 
* READ INPUT CHARACTERS UNTIL A NON ALPHA OR                      
* NON NUMERIC IS FOUND - IGNORE ALL CHARACTERS                      
* IN VARIABLE NAME AFTER THE 1ST TWO                      
LB373     JSR  GETNCH         GET AN INPUT CHARACTER 
          BCS  LB373          BRANCH IF NUMERIC 
          BSR  LB3A2          SET CARRY IF NOT ALPHA 
          BCC  LB373          BRANCH IF ALPHA 
LB37B     CMPA #'$            CHECK FOR A STRING VARIABLE 
          BNE  LB385          BRANCH IF IT IS NOT A STRING 
          COM  VALTYP         SET VARIABLE TYPE TO STRING 
          ADDB #$80           SET BIT 7 OF 2ND CHARACTER (STRING) 
          JSR  GETNCH         GET AN INPUT CHARACTER 
LB385     STB  VARNAM+1       SAVE 2ND CHARACTER IN VARNAM+1 
          ORA  ARYDIS         OR IN THE ARRAY DISABLE FLAG - IF = $80, 
*              DON’T SEARCH FOR VARIABLES IN THE ARRAYS  
          SUBA #'(            IS THIS AN ARRAY VARIABLE? 
          LBEQ LB404          BRANCH IF IT IS 
          CLR  ARYDIS         RESET THE ARRAY DISABLE FLAG 
          LDX  VARTAB         POINT X TO THE START OF VARIABLES 
          LDD  VARNAM         GET VARIABLE IN QUESTION 
LB395     CMPX ARYTAB         COMPARE X TO THE END OF VARIABLES 
          BEQ  LB3AB          BRANCH IF END OF VARIABLES 
          CMPD ,X++           * COMPARE VARIABLE IN QUESTION TO CURRENT 
          BEQ  LB3DC          * VARIABLE AND BRANCH IF MATCH 
          LEAX 5,X            = MOVE POINTER TO NEXT VARIABLE AND 
          BRA  LB395          = KEEP LOOKING 
                               
* SET CARRY IF NOT UPPER CASE ALPHA                      
LB3A2     CMPA #'A            * CARRY SET IF < ‘A’ 
          BCS  LB3AA          * 
          SUBA #'Z+1          = 
*         SUBA #-('Z+1)       = CARRY CLEAR IF <= 'Z' 
          FCB  $80,$A5         
LB3AA     RTS                  
* PUT A NEW VARIABLE IN TABLE OF VARIABLES                      
LB3AB     LDX  #ZERO          POINT X TO ZERO LOCATION 
          LDU  ,S             GET CURRENT RETURN ADDRESS 
          CMPU #LB287         DID WE COME FROM ‘EVALUATE ALPHA EXPR’? 
          BEQ  LB3DE          YES - RETURN A ZERO VALUE 
          LDD  ARYEND         * GET END OF ARRAYS ADDRESS AND 
          STD  V43            * SAVE IT AT V43 
          ADDD #7             = ADD 7 TO END OF ARRAYS (EACH 
          STD  V41            = VARIABLE = 7 BYTES) AND SAVE AT V41 
          LDX  ARYTAB         * GET END OF VARIABLES AND SAVE AT V47 
          STX  V47            * 
          JSR  LAC1E          MAKE A SEVEN BYTE SLOT FOR NEW VARIABLE AT 
*         TOP  OF VARIABLES    
          LDX  V41            = GET NEW END OF ARRAYS AND SAVE IT 
          STX  ARYEND         = 
          LDX  V45            * GET NEW END OF VARIABLES AND SAVE IT 
          STX  ARYTAB         * 
          LDX  V47            GET OLD END OF VARIABLES 
          LDD  VARNAM         GET NEW VARIABLE NAME 
          STD  ,X++           SAVE VARIABLE NAME 
          CLRA                * ZERO OUT THE FP VALUE OF THE NUMERIC 
          CLRB                * VARIABLE OR THE LENGTH AND ADDRESS 
          STD  ,X             * OF A STRING VARIABLE 
          STD  2,X            * 
          STA  4,X            * 
LB3DC     STX  VARPTR         STORE ADDRESS OF VARIABLE VALUE 
LB3DE     RTS                  
*                              
LB3DF     FCB  $90,$80,$00,$00,$00 * FLOATING POINT -32768 
*                             SMALLEST SIGNED TWO BYTE INTEGER 
*                              
LB3E4     JSR  GETNCH         GET AN INPUT CHARACTER FROM BASIC 
LB3E6     JSR  LB141          GO EVALUATE NUMERIC EXPRESSION 
LB3E9     LDA  FP0SGN         GET FPA0 MANTISSA SIGN 
          BMI  LB44A          ‘FC’ ERROR IF NEGATIVE NUMBER 
                               
                               
INTCNV    JSR  LB143          ‘TM’ ERROR IF STRING VARIABLE 
          LDA  FP0EXP         GET FPA0 EXPONENT 
          CMPA #$90           * COMPARE TO 32768 - LARGEST INTEGER EXPONENT AND 
          BCS  LB3FE          * BRANCH IF FPA0 < 32768 
          LDX  #LB3DF         POINT X TO FP VALUE OF -32768 
          JSR  LBC96          COMPARE -32768 TO FPA0 
          BNE  LB44A          ‘FC’ ERROR IF NOT = 
LB3FE     JSR  LBCC8          CONVERT FPA0 TO A TWO BYTE INTEGER 
          LDD  FPA0+2         GET THE INTEGER 
          RTS                  
* EVALUATE AN ARRAY VARIABLE                      
LB404     LDD  DIMFLG         GET ARRAY FLAG AND VARIABLE TYPE 
          PSHS B,A            SAVE THEM ON STACK 
          NOP                 DEAD SPACE CAUSED BY 1.2 REVISION 
          CLRB                RESET DIMENSION COUNTER 
LB40A     LDX  VARNAM         GET VARIABLE NAME 
          PSHS X,B            SAVE VARIABLE NAME AND DIMENSION COUNTER 
          BSR  LB3E4          EVALUATE EXPRESSION (DIMENSlON LENGTH) 
          PULS B,X,Y          PULL OFF VARIABLE NAME, DIMENSlON COUNTER, 
*                             ARRAY FLAG 
          STX  VARNAM         SAVE VARIABLE NAME AND VARIABLE TYPE 
          LDU  FPA0+2         GET DIMENSION LENGTH 
          PSHS U,Y            SAVE DIMENSION LENGTH, ARRAY FLAG, VARIABLE TYPE 
          INCB                INCREASE DIMENSION COUNTER 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          CMPA #',            CHECK FOR ANOTHER DIMENSION 
          BEQ  LB40A          BRANCH IF MORE 
          STB  TMPLOC         SAVE DIMENSION COUNTER 
          JSR  LB267          SYNTAX CHECK FOR A ‘)‘ 
          PULS A,B            * RESTORE VARIABLE TYPE AND ARRAY 
          STD  DIMFLG         * FLAG - LEAVE DIMENSION LENGTH ON STACK 
          LDX  ARYTAB         GET START OF ARRAYS 
LB42A     CMPX ARYEND         COMPARE TO END OF ARRAYS 
          BEQ  LB44F          BRANCH IF NO MATCH FOUND 
          LDD  VARNAM         GET VARIABLE IN QUESTION 
          CMPD ,X             COMPARE TO CURRENT VARIABLE 
          BEQ  LB43B          BRANCH IF = 
          LDD  2,X            GET OFFSET TO NEXT ARRAY VARIABLE 
          LEAX D,X            ADD TO CURRENT POINTER 
          BRA  LB42A          KEEP SEARCHING 
LB43B     LDB  #2*9           ‘REDIMENSIONED ARRAY’ ERROR 
          LDA  DIMFLG         * TEST ARRAY FLAG - IF <>0 YOU ARE TRYING 
          BNE  LB44C          * TO REDIMENSION AN ARRAY 
          LDB  TMPLOC         GET NUMBER OF DIMENSIONS IN ARRAY 
          CMPB 4,X            COMPARE TO THIS ARRAYS DIMENSIONS 
          BEQ  LB4A0          BRANCH IF = 
LB447     LDB  #8*2           ‘BAD SUBSCRIPT’ 
          FCB  SKP2           SKIP TWO BYTES 
LB44A     LDB  #4*2           ‘ILLEGAL FUNCTION CALL’ 
LB44C     JMP  LAC46          JUMP TO ERROR SERVICING ROUTINE 
                               
* INSERT A NEW ARRAY INTO ARRAY VARIABLES                      
* EACH SET OF ARRAY VARIABLES IS PRECEEDED BY A DE-                      
* SCRIPTOR BLOCK COMPOSED OF 5+2*N BYTES WHERE N IS THE                      
* NUMBER OF DIMENSIONS IN THE ARRAY. THE BLOCK IS DEFINED                      
* AS FOLLOWS: BYTES 0,1:VARIABLE’S NAME; 2,3:TOTAL LENGTH                      
* OF ARRAY ITEMS AND DESCRIPTOR BLOCK; 4:NUMBER OF DIMEN-                      
* ISIONS; 5,6:LENGTH OF DIMENSION 1; 7,8:LENGTH OF DIMEN-                      
* SION 2;… 4+N,5+N:LENGTH OF DIMENSION N.                      
                               
LB44F     LDD  #5             * 5 BYTES/ARRAY ENTRY SAVE AT COEFPT 
          STD  COEFPT         * 
          LDD  VARNAM         = GET NAME OF ARRAY AND SAVE IN 
          STD  ,X             = FIRST 2 BYTES OF DESCRIPTOR 
          LDB  TMPLOC         GET NUMBER OF DIMENSIONS AND SAVE IN 
          STB  4,X            * 5TH BYTE OF DESCRIPTOR 
          JSR  LAC33          CHECK FOR ROOM FOR DESCRIPTOR IN FREE RAM 
          STX  V41            TEMPORARILY SAVE DESCRIPTOR ADDRESS 
LB461     LDB  #11            * DEFAULT DIMENSION VALUE:X(10) 
          CLRA                * 
          TST  DIMFLG         = CHECK ARRAY FLAG AND BRANCH IF 
          BEQ  LB46D          = NOT DIMENSIONING AN ARRAY 
          PULS A,B            GET DIMENSION LENGTH 
          ADDD #1             ADD ONE (X(0) HAS A LENGTH OF ONE) 
LB46D     STD  5,X            SAVE LENGTH OF ARRAY DIMENSION 
          BSR  LB4CE          MULTIPLY ACCUM ARRAY SIZE NUMBER LENGTH 
*                             OF NEW DIMENSION 
          STD  COEFPT         TEMP STORE NEW CURRENT ACCUMULATED ARRAY SIZE 
          LEAX 2,X            BUMP POINTER UP TWO 
          DEC  TMPLOC         * DECREMENT DIMENSION COUNTER AND BRANCH IF 
          BNE  LB461          * NOT DONE WITH ALL DIMENSIONS 
          STX  TEMPTR         SAVE ADDRESS OF (END OF ARRAY DESCRIPTOR - 5) 
          ADDD TEMPTR         ADD TOTAL SIZE OF NEW ARRAY 
          LBCS LAC44          ‘OM’ ERROR IF > $FFFF 
          TFR  D,X            SAVE END OF ARRAY IN X 
          JSR  LAC37          MAKE SURE THERE IS ENOUGH FREE RAM FOR ARRAY 
          SUBD #STKBUF-5      SUBTRACT OUT THE (STACK BUFFER - 5) 
          STD  ARYEND         SAVE NEW END OF ARRAYS 
          CLRA                ZERO = TERMINATOR BYTE 
LB48C     LEAX -1,X           * STORE TWO TERMINATOR BYTES AT 
          STA  5,X            * THE END OF THE ARRAY DESCRIPTOR 
          CMPX TEMPTR         * 
          BNE  LB48C          * 
          LDX  V41            GET ADDRESS OF START OF DESCRIPTOR 
          LDA  ARYEND         GET MSB OF END OF ARRAYS; LSB ALREADY THERE 
          SUBD V41            SUBTRACT OUT ADDRESS OF START OF DESCRIPTOR 
          STD  2,X            SAVE LENGTH OF (ARRAY AND DESCRIPTOR) 
          LDA  DIMFLG         * GET ARRAY FLAG AND BRANCH 
          BNE  LB4CD          * BACK IF DIMENSIONING 
* CALCULATE POINTER TO CORRECT ELEMENT                      
LB4A0     LDB  4,X            GET THE NUMBER OF DIMENSIONS 
          STB  TMPLOC         TEMPORARILY SAVE 
          CLRA                * INITIALIZE POINTER 
          CLRB                * TO ZERO 
LB4A6     STD  COEFPT         SAVE ACCUMULATED POINTER 
          PULS A,B            * PULL DIMENSION ARGUMENT OFF THE 
          STD  FPA0+2         * STACK AND SAVE IT 
          CMPD 5,X            COMPARE TO STORED ‘DIM’ ARGUMENT 
          BCC  LB4EB          ‘BS’ ERROR IF > = "DIM" ARGUMENT 
          LDU  COEFPT         * GET ACCUMULATED POINTER AND 
          BEQ  LB4B9          * BRANCH IF 1ST DIMENSION 
          BSR  LB4CE          = MULTIPLY ACCUMULATED POINTER AND DIMENSION 
          ADDD FPA0+2         = LENGTH AND ADD TO CURRENT ARGUMENT 
LB4B9     LEAX 2,X            MOVE POINTER TO NEXT DIMENSION 
          DEC  TMPLOC         * DECREMENT DIMENSION COUNTER AND 
          BNE  LB4A6          * BRANCH IF ANY DIMENSIONS LEFT 
* MULTIPLY ACCD BY 5 - 5 BYTES/ARRAY VALUE                      
          STD  ,--S            
          ASLB                 
          ROLA                TIMES 2 
          ASLB                 
          ROLA                TIMES 4 
          ADDD ,S++           TIMES 5 
          LEAX D,X            ADD OFFSET TO START OF ARRAY 
          LEAX 5,X            ADJUST POINTER FOR SIZE OF DESCRIPTOR 
          STX  VARPTR         SAVE POINTER TO ARRAY VALUE 
LB4CD     RTS                  
* MULTIPLY 2 BYTE NUMBER IN 5,X BY THE 2 BYTE NUMBER                      
* IN COEFPT. RETURN RESULT IN ACCD, BS ERROR IF > $FFFF                      
LB4CE     LDA  #16            16 SHIFTS TO DO A MULTIPLY 
          STA  V45            SHIFT COUNTER 
          LDD  5,X            * GET SIZE OF DIMENSION 
          STD  BOTSTK         * AND SAVE IT 
          CLRA                * ZERO 
          CLRB                * ACCD 
LB4D8     ASLB                = SHIFT ACCB LEFT 
          ROLA                = ONE BIT 
          BCS  LB4EB          BS' ERROR IF CARRY 
          ASL  COEFPT+1       * SHIFT MULTIPLICAND LEFT ONE 
          ROL  COEFPT         * BIT - ADD MULTIPLIER TO ACCUMULATOR 
          BCC  LB4E6          * IF CARRY <> 0 
          ADDD BOTSTK         ADD MULTIPLIER TO ACCD 
          BCS  LB4EB          BS' ERROR IF CARRY (>$FFFF) 
LB4E6     DEC  V45            * DECREMENT SHIFT COUNTER 
          BNE  LB4D8          * IF NOT DONE 
          RTS                  
LB4EB     JMP  LB447          BS' ERROR 
*                              
* MEM                          
* THIS IS NOT A TRUE INDICATOR OF FREE MEMORY BECAUSE                      
* BASIC REQUIRES A STKBUF SIZE BUFFER FOR THE STACK                      
* FOR WHICH MEM DOES NOT ALLOW.                      
*                              
MEM       TFR  S,D            PUT STACK POINTER INTO ACCD 
          SUBD ARYEND         SUBTRACT END OF ARRAYS 
          FCB  SKP1           SKIP ONE BYTE 
*CONVERT THE VALUE IN ACCB INTO A FP NUMBER IN FPA0                      
LB4F3     CLRA                CLEAR MS BYTE OF ACCD 
* CONVERT THE VALUE IN ACCD INTO A FLOATING POINT NUMBER IN FPA0                      
GIVABF    CLR  VALTYP         SET VARIABLE TYPE TO NUMERIC 
          STD  FPA0           SAVE ACCD IN TOP OF FACA 
          LDB  #$90           EXPONENT REQUIRED IF THE TOP TWO BYTES 
*         OF   FPA0 ARE TO BE TREATED AS AN INTEGER IN FPA0  
          JMP  LBC82          CONVERT THE REST OF FPA0 TO AN INTEGER 
                               
* STR$                         
STR       JSR  LB143          TM' ERROR IF STRING VARIABLE 
          LDU  #STRBUF+2      *CONVERT FP NUMBER TO ASCII STRING IN 
          JSR  LBDDC          *THE STRING BUFFER 
          LEAS 2,S            PURGE THE RETURN ADDRESS FROM THE STACK 
          LDX  #STRBUF+1      *POINT X TO STRING BUFFER AND SAVE 
          BRA  LB518          *THE STRING IN THE STRING SPACE 
* RESERVE ACCB BYTES OF STRING SPACE. RETURN START                      
* ADDRESS IN (X) AND FRESPC                      
LB50D     STX  V4D            SAVE X IN V4D 
LB50F     BSR  LB56D          RESERVE ACCB BYTES IN STRING SPACE 
LB511     STX  STRDES+2       SAVE NEW STRING ADDRESS 
          STB  STRDES         SAVE LENGTH OF RESERVED BLOCK 
          RTS                  
LB516     LEAX -1,X           MOVE POINTER BACK ONE 
* SCAN A LINE FROM (X) UNTIL AN END OF LINE FLAG (ZERO) OR                      
* EITHER OF THE TWO TERMINATORS STORED IN CHARAC OR ENDCHR IS MATCHED.                      
* THE RESULTING STRING IS STORED IN THE STRING SPACE                      
* ONLY IF THE START OF THE STRING IS <= STRBUF+2                      
LB518     LDA  #'"            * INITIALIZE 
          STA  CHARAC         * TERMINATORS 
LB51A     STA  ENDCHR         * TO " 
LB51E     LEAX 1,X            MOVE POINTER UP ONE 
          STX  RESSGN         TEMPORARILY SAVE START OF STRING 
          STX  STRDES+2       SAVE START OF STRING IN TEMP DESCRIPTOR 
          LDB  #-1            INITIALIZE CHARACTER COUNTER TO - 1 
LB526     INCB                INCREMENT CHARACTER COUNTER 
          LDA  ,X+            GET CHARACTER 
          BEQ  LB537          BRANCH IF END OF LINE 
          CMPA CHARAC         * CHECK FOR TERMINATORS 
          BEQ  LB533          * IN CHARAC AND ENDCHR 
          CMPA ENDCHR         * DON’T MOVE POINTER BACK 
          BNE  LB526          * ONE IF TERMINATOR IS "MATCHED" 
LB533     CMPA #'"            = COMPARE CHARACTER TO STRING DELIMITER 
          BEQ  LB539          = & DON’T MOVE POINTER BACK IF SO 
LB537     LEAX -1,X           MOVE POINTER BACK ONE 
LB539     STX  COEFPT         SAVE END OF STRING ADDRESS 
          STB  STRDES         SAVE STRING LENGTH IN TEMP DESCRIPTOR 
          LDU  RESSGN         GET INITlAL STRING START 
          CMPU #STRBUF+2      COMPARE TO START OF STRING BUFFER 
LB543     BHI  LB54C          BRANCH IF > START OF STRING BUFFER 
          BSR  LB50D          GO RESERVE SPACE FOR THE STRING 
          LDX  RESSGN         POINT X TO THE BEGINNING OF THE STRING 
          JSR  LB645          MOVE (B) BYTES FROM (X) TO 
*                             [FRESPC] - MOVE STRING DATA 
* PUT DIRECT PAGE STRING DESCRIPTOR BUFFER DATA                      
* ON THE STRING STACK. SET VARIABLE TYPE TO STRING                      
LB54C     LDX  TEMPPT         GET NEXT AVAILABLE STRING STACK DESCRIPTOR 
          CMPX #LINHDR        COMPARE TO TOP OF STRING DESCRIPTOR STACK - WAS #CFNBUF 
          BNE  LB558          FORMULA O.K. 
          LDB  #15*2          STRING FORMULA TOO COMPLEX' ERROR 
LB555     JMP  LAC46          JUMP TO ERROR SERVICING ROUTINE 
LB558     LDA  STRDES         * GET LENGTH OF STRING AND SAVE IT 
*         STA  ,X             * IN BYTE 0 OF DESCRIPTOR 
          FCB  $A7,$00         
          LDD  STRDES+2       = GET START ADDRESS OF ACTUAL STRING 
          STD  2,X            = AND SAVE IN BYTES 2,3 OF DESCRIPTOR 
          LDA  #$FF           * VARIABLE TYPE = STRING 
          STA  VALTYP         * SAVE IN VARIABLE TYPE FLAG 
          STX  LASTPT         = SAVE START OF DESCRIPTOR 
          STX  FPA0+2         = ADDRESS IN LASTPT AND FPA0 
          LEAX 5,X            5 BYTES/STRING DESCRIPTOR 
          STX  TEMPPT         NEXT AVAILABLE STRING VARIABLE DESCRIPTOR 
          RTS                  
* RESERVE ACCB BYTES IN STRING STORAGE SPACE                      
* RETURN WITH THE STARTING ADDRESS OF THE                      
* RESERVED STRING SPACE IN (X) AND FRESPC                      
LB56D     CLR  GARBFL         CLEAR STRING REORGANIZATION FLAG 
LB56F     CLRA                * PUSH THE LENGTH OF THE 
          PSHS B,A            * STRING ONTO THE STACK 
          LDD  STRTAB         GET START OF STRING VARIABLES 
          SUBD ,S+            SUBTRACT STRING LENGTH 
          CMPD FRETOP         COMPARE TO START OF STRING STORAGE 
          BCS  LB585          IF BELOW START, THEN REORGANIZE 
          STD  STRTAB         SAVE NEW START OF STRING VARIABLES 
          LDX  STRTAB         GET START OF STRING VARIABLES 
          LEAX 1,X            ADD ONE 
          STX  FRESPC         SAVE START ADDRESS OF NEWLY RESERVED SPACE 
          PULS B,PC           RESTORE NUMBER OF BYTES RESERVED AND RETURN 
LB585     LDB  #2*13          OUT OF STRING SPACE' ERROR 
          COM  GARBFL         TOGGLE REORGANIZATiON FLAG 
          BEQ  LB555          ERROR IF FRESHLY REORGANIZED 
          BSR  LB591          GO REORGANIZE STRING SPACE 
          PULS B              GET BACK THE NUMBER OF BYTES TO RESERVE 
          BRA  LB56F          TRY TO RESERVE ACCB BYTES AGAIN 
* REORGANIZE THE STRING SPACE                      
LB591     LDX  MEMSIZ         GET THE TOP OF STRING SPACE 
LB593     STX  STRTAB         SAVE TOP OF UNORGANIZED STRING SPACE 
          CLRA                * ZERO OUT ACCD 
          CLRB                * AND RESET VARIABLE 
          STD  V4B            * POINTER TO 0 
          LDX  FRETOP         POINT X TO START OF STRING SPACE 
          STX  V47            SAVE POINTER IN V47 
          LDX  #STRSTK        POINT X TO START OF STRING DESCRIPTOR STACK 
LB5A0     CMPX TEMPPT         COMPARE TO ADDRESS OF NEXT AVAILABLE DESCRIPTOR 
          BEQ  LB5A8          BRANCH IF TOP OF STRING STACK 
          BSR  LB5D8          CHECK FOR STRING IN UNORGANIZED STRING SPACE 
          BRA  LB5A0          KEEP CHECKING 
LB5A8     LDX  VARTAB         GET THE END OF BASIC PROGRAM 
LB5AA     CMPX ARYTAB         COMPARE TO END OF VARIABLES 
          BEQ  LB5B2          BRANCH IF AT TOP OF VARIABLES 
          BSR  LB5D2          CHECK FOR STRING IN UNORGANIZED STRING SPACE 
          BRA  LB5AA          KEEP CHECKING VARIABLES 
LB5B2     STX  V41            SAVE ADDRESS OF THE END OF VARIABLES 
LB5B4     LDX  V41            GET CURRENT ARRAY POINTER 
LB5B6     CMPX ARYEND         COMPARE TO THE END OF ARRAYS 
          BEQ  LB5EF          BRANCH IF AT END OF ARRAYS 
          LDD  2,X            GET LENGTH OF ARRAY AND DESCRIPTOR 
          ADDD V41            * ADD TO CURRENT ARRAY POINTER 
          STD  V41            * AND SAVE IT 
          LDA  1,X            GET 1ST CHARACTER OF VARIABLE NAME 
          BPL  LB5B4          BRANCH IF NUMERIC ARRAY 
          LDB  4,X            GET THE NUMBER OF DIMENSIONS IN THIS ARRAY 
          ASLB                MULTIPLY BY 2 
          ADDB #5             ADD FIVE BYTES (VARIABLE NAME, ARRAY 
*                             LENGTH, NUMBER DIMENSIONS) 
          ABX                 X NOW POINTS TO START OF ARRAY ELEMENTS 
LB5CA     CMPX V41            AT END OF THIS ARRAY? 
          BEQ  LB5B6          YES - CHECK FOR ANOTHER 
          BSR  LB5D8          CHECK FOR STRING LOCATED IN 
*                             UNORGANIZED STRING SPACE 
          BRA  LB5CA          KEEP CHECKING ELEMENTS IN THIS ARRAY 
LB5D2     LDA  1,X            GET F1RST BYTE OF VARIABLE NAME 
          LEAX 2,X            MOVE POINTER TO DESCRIPTOR 
          BPL  LB5EC          BRANCH IF VARIABLE IS NUMERIC 
* SEARCH FOR STRING - ENTER WITH X POINTING TO                      
* THE STRING DESCRIPTOR. IF STRING IS STORED                      
* BETWEEN V47 AND STRTAB, SAVE DESCRIPTOR POINTER                      
* IN V4B AND RESET V47 TO STRING ADDRESS                      
LB5D8     LDB  ,X             GET THE LENGTH OF THE STRING 
          BEQ  LB5EC          BRANCH IF NULL - NO STRING 
          LDD  2,X            GET STARTING ADDRESS OF THE STRING 
          CMPD STRTAB         COMPARE TO THE START OF STRING VARIABLES 
          BHI  LB5EC          BRANCH IF THIS STRING IS STORED IN 
*              THE STRING VARIABLES  
          CMPD V47            COMPARE TO START OF STRING SPACE 
          BLS  LB5EC          BRANCH IF NOT STORED IN THE STRING SPACE 
          STX  V4B            SAVE VARIABLE POINTER IF STORED IN STRING SPACE 
          STD  V47            SAVE STRING STARTING ADDRESS 
LB5EC     LEAX 5,X            MOVE TO NEXT VARIABLE DESCRIPTOR 
LB5EE     RTS                  
LB5EF     LDX  V4B            GET ADDRESS OF THE DESCRIPTOR FOR THE 
*              STRING WHICH IS STORED IN THE HIGHEST RAM ADDRESS IN  
*              THE UNORGANIZED STRING SPACE  
          BEQ  LB5EE          BRANCH IF NONE FOUND AND REORGANIZATION DONE 
          CLRA                CLEAR MS BYTE OF LENGTH 
          LDB  ,X             GET LENGTH OF STRING 
          DECB                SUBTRACT ONE 
          ADDD V47            ADD LENGTH OF STRING TO ITS STARTING ADDRESS 
          STD  V43            SAVE AS MOVE STARTING ADDRESS 
          LDX  STRTAB         POINT X TO THE START OF ORGANIZED STRING VARIABLES 
          STX  V41            SAVE AS MOVE ENDING ADDRESS 
          JSR  LAC20          MOVE STRING FROM CURRENT POSITION TO THE 
*              TOP OF UNORGANIZED STRING SPACE  
          LDX  V4B            POINT X TO STRING DESCRIPTOR 
          LDD  V45            * GET NEW STARTING ADDRESS OF STRING AND 
          STD  2,X            * SAVE IT IN DESCRIPTOR 
          LDX  V45            GET NEW TOP OF UNORGANIZED STRING SPACE 
          LEAX -1,X           MOVE POINTER BACK ONE 
          JMP  LB593          JUMP BACK AND REORGANIZE SOME MORE 
                               
                               
LB60F     LDD  FPA0+2         * GET DESCRIPTOR ADDRESS OF STRING A 
          PSHS B,A            * AND SAVE IT ON THE STACK 
          JSR  LB223          GET DESCRIPTOR ADDRESS OF STRING B 
          JSR  LB146          TM' ERROR IF NUMERIC VARIABLE 
          PULS X              * POINT X TO STRING A DESCRIPTOR 
          STX  RESSGN         * ADDRESS AND SAVE IT IN RESSGN 
          LDB  ,X             GET LENGTH OF STRING A 
          LDX  FPA0+2         POINT X TO DESCRIPTOR OF STRING B 
          ADDB ,X             ADD LENGTH OF STRING B TO STR1NG A 
          BCC  LB62A          BRANCH IF LENGTH < 256 
          LDB  #2*14          STRING TOO LONG' ERROR IF LENGTH > 255 
          JMP  LAC46          JUMP TO ERROR SERVICING ROUTINE 
LB62A     JSR  LB50D          RESERVE ROOM IN STRING SPACE FOR NEW STRING 
          LDX  RESSGN         GET DESCRIPTOR ADDRESS OF STRING A 
          LDB  ,X             GET LENGTH OF STRING A 
          BSR  LB643          MOVE STRING A INTO RESERVED BUFFER IN STRING SPACE 
          LDX  V4D            GET DESCRIPTOR ADDRESS OF STRING B 
          BSR  LB659          GET LENGTH AND ADDRESS OF STRING B 
          BSR  LB645          MOVE STRING B INTO REST OF RESERVED BUFFER 
          LDX  RESSGN         POINT X TO DESCRIPTOR OF STRING A 
          BSR  LB659          DELETE STRING A IF LAST STRING ON STRING STACK 
          JSR  LB54C          PUT STRING DESCRIPTOR ON THE STRING STACK 
          JMP  LB168          BRANCH BACK TO EXPRESSION EVALUATION 
                               
* MOVE (B) BYTES FROM 2,X TO FRESPC                      
LB643     LDX  2,X            POINT X TO SOURCE ADDRESS 
LB645     LDU  FRESPC         POINT U TO DESTINATION ADDRESS 
          INCB                COMPENSATION FOR THE DECB BELOW 
          BRA  LB64E          GO MOVE THE BYTES 
* MOVE B BYTES FROM (X) TO (U)                      
LB64A     LDA  ,X+            * GET A SOURCE BYTE AND MOVE IT 
          STA  ,U+            * TO THE DESTINATION 
LB64E     DECB                DECREMENT BYTE COUNTER 
          BNE  LB64A          BRANCH IF ALL BYTES NOT MOVED 
          STU  FRESPC         SAVE ENDING ADDRESS IN FRESPC 
          RTS                  
* RETURN LENGTH (ACCB) AND ADDRESS (X) OF                      
* STRING WHOSE DESCRIPTOR IS IN FPA0+2                      
* DELETE THE STRING IF IT IS THE LAST ONE                      
* PUT ON THE STRING STACK. REMOVE STRING FROM STRING                      
* SPACE IF IT IS AT THE BOTTOM OF STRING VARIABLES.                      
LB654     JSR  LB146          TM' ERROR IF VARIABLE TYPE = NUMERIC 
LB657     LDX  FPA0+2         GET ADDRESS OF SELECTED STRING DESCRIPTOR 
LB659     LDB  ,X             GET LENGTH OF STRING 
          BSR  LB675          * CHECK TO SEE IF THIS STRING DESCRIPTOR WAS 
          BNE  LB672          * THE LAST ONE PUT ON THE STRING STACK AND 
*                             * BRANCH IF NOT 
          LDX  5+2,X          GET START ADDRESS OF STRING JUST REMOVED 
          LEAX -1,X           MOVE POINTER DOWN ONE 
          CMPX STRTAB         COMPARE TO START OF STRING VARIABLES 
          BNE  LB66F          BRANCH IF THIS STRING IS NOT AT THE BOTTOM 
*                             OF STRING VARIABLES 
          PSHS B              SAVE LENGTH; ACCA WAS CLEARED 
          ADDD STRTAB         * ADD THE LENGTH OF THE JUST REMOVED STRING 
          STD  STRTAB         * TO THE START OF STRING VARIABLES - THIS WILL 
*                             * REMOVE THE STRING FROM THE STRING SPACE 
          PULS B              RESTORE LENGTH 
LB66F     LEAX 1,X            ADD ONE TO POINTER 
          RTS                  
LB672     LDX  2,X            *POINT X TO ADDRESS OF STRING NOT 
          RTS                 *ON THE STRING STACK 
* REMOVE STRING FROM STRING STACK. ENTER WITH X                      
* POINTING TO A STRING DESCRIPTOR - DELETE THE                      
* STRING FROM STACK IF IT IS ON TOP OF THE                      
* STACK. IF THE STRING IS DELETED, SET THE ZERO FLAG                      
LB675     CMPX LASTPT         *COMPARE TO LAST USED DESCRIPTOR ADDRESS 
          BNE  LB680          *ON THE STRING STACK, RETURN IF DESCRIPTOR 
*                             *ADDRESS NOT ON THE STRING STACK 
          STX  TEMPPT         SAVE LAST USED DESCRIPTOR AS NEXT AVAILABLE 
          LEAX -5,X           * MOVE LAST USED DESCRIPTOR BACK 5 BYTES 
          STX  LASTPT         * AND SAVE AS THE LAST USED DESCRIPTOR ADDR 
          CLRA                SET ZERO FLAG 
LB680     RTS                  
                               
* LEN                          
LEN       BSR  LB686          POINT X TO PROPER STRING AND GET LENGTH 
LB683     JMP  LB4F3          CONVERT ACCB TO FP NUMBER IN FPA0 
* POINT X TO STRING ADDRESS LOAD LENGTH INTO                      
* ACCB. ENTER WITH THE STRING DESCRIPTOR IN                      
* BOTTOM TWO BYTES OF FPA0                      
LB686     BSR  LB654          GET LENGTH AND ADDRESS OF STRING 
          CLR  VALTYP         SET VARIABLE TYPE TO NUMERIC 
          TSTB                SET FLAGS ACCORDING TO LENGTH 
          RTS                  
                               
* CHR$                         
CHR       JSR  LB70E          CONVERT FPA0 TO AN INTEGER IN ACCD 
LB68F     LDB  #1             * RESERVE ONE BYTE IN 
          JSR  LB56D          * THE STRING SPACE 
          LDA  FPA0+3         GET ASCII STRING VALUE 
          JSR  LB511          SAVE RESERVED STRING DESCRIPTOR IN TEMP DESCRIPTOR 
          STA  ,X             SAVE THE STRING (IT’S ONLY ONE BYTE) 
LB69B     LEAS 2,S            PURGE THE RETURN ADDRESS OFF OF THE STACK 
LB69D     JMP  LB54C          PUT TEMP DESCRIPTOR DATA ONTO STRING STACK 
                               
                               
ASC       BSR  LB6A4          PUT 1ST CHARACTER OF STRING INTO ACCB 
          BRA  LB683          CONVERT ACCB INTO FP NUMBER IN FPA0 
LB6A4     BSR  LB686          POINT X TO STRING DESCRIPTOR 
          BEQ  LB706          FC' ERROR IF NULL STRING 
          LDB  ,X             GET FIRST BYTE OF STRING 
          RTS                  
                               
                               
LEFT      BSR  LB6F5          GET ARGUMENTS FROM STACK 
LB6AD     CLRA                CLEAR STRING POINTER OFFSET - OFFSET = 0 FOR LEFT$ 
LB6AE     CMPB ,X             * COMPARE LENGTH PARAMETER TO LENGTH OF 
          BLS  LB6B5          * STRING AND BRANCH IF LENGTH OF STRING 
*                             >= LENGTH PARAMETER 
          LDB  ,X             USE LENGTH OF STRING OTHERWISE 
          CLRA                CLEAR STRING POINTER OFFSET (0 FOR LEFT$) 
LB6B5     PSHS B,A            PUSH PARAMETERS ONTO STACK 
          JSR  LB50F          RESERVE ACCB BYTES IN THE STRING SPACE 
          LDX  V4D            POINT X TO STRING DESCRIPTOR 
          BSR  LB659          GET ADDRESS OF OLD STRING (X=ADDRESS) 
          PULS B              * PULL STRING POINTER OFFSET OFF OF THE STACK 
          ABX                 * AND ADD IT TO STRING ADDRESS 
          PULS B              PULL LENGTH PARAMETER OFF OF THE STACK 
          JSR  LB645          MOVE ACCB BYTES FROM (X) TO [FRESPC] 
          BRA  LB69D          PUT TEMP STRING DESCRIPTOR ONTO THE STRING STACK 
                               
* RIGHT$                       
RIGHT     BSR  LB6F5          GET ARGUMENTS FROM STACK 
          SUBA ,X             ACCA=LENGTH PARAMETER - LENGTH OF OLD STRING 
          NEGA                NOW ACCA = LENGTH OF OLD STRING 
          BRA  LB6AE          PUT NEW STRING IN THE STRING SPACE 
                               
* MID$                         
MID       LDB  #$FF           * GET DEFAULT VALUE OF LENGTH AND 
          STB  FPA0+3         * SAVE IT IN FPA0 
          JSR  GETCCH         GET CURRENT CHARACTER FROM BASIC 
          CMPA #')            ARGUMENT DELIMITER? 
          BEQ  LB6DE          YES - NO LENGTH PARAMETER GIVEN 
          JSR  LB26D          SYNTAX CHECK FOR COMMA 
          BSR  LB70B          EVALUATE NUMERIC EXPRESSION (LENGTH) 
LB6DE     BSR  LB6F5          GET ARGUMENTS FROM STACK 
          BEQ  LB706          FC' ERROR IF NULL STRING 
          CLRB                CLEAR LENGTH COUNTER (DEFAULT VALUE) 
          DECA                *SUOTRACT ONE FROM POSITION PARAMETER (THESE 
          CMPA ,X             *ROUTINES EXPECT 1ST POSITION TO BE ZERO, NOT ONE) 
*                             *AND COMPARE IT TO LENGTH OF OLD STRING 
          BCC  LB6B5          IF POSITION > LENGTH OF OLD STRING, THEN NEW 
*                             STRING WILL BE A NULL STRING 
          TFR  A,B            SAVE ABSOLUTE POSITION PARAMETER IN ACCB 
          SUBB ,X             ACCB=POSITION-LENGTH OF OLD STRING 
          NEGB                NOW ACCB=LENGTH OF OLDSTRING-POSITION 
          CMPB FPA0+3         *IF THE AMOUNT OF OLD STRING TO THE RIGHT OF 
          BLS  LB6B5          *POSITION IS <= THE LENGTH PARAMETER, BRANCH AND 
* USE ALL OF THE STRING TO THE RIGHT OF THE POSITION                      
* INSTEAD OF THE LENGTH PARAMETER                      
          LDB  FPA0+3         GET LENGTH OF NEW STRING 
          BRA  LB6B5          PUT NEW STRING IN STRING SPACE 
* DO A SYNTAX CHECK FOR ")", THEN PULL THE PREVIOUSLY CALCULATED NUMERIC                      
* ARGUMENT (ACCD) AND STRING ARGUMENT DESCRIPTOR ADDR OFF OF THE STACK                      
LB6F5     JSR  LB267          SYNTAX CHECK FOR A ")" 
          LDU  ,S             LOAD THE RETURN ADDRESS INTO U REGISTER 
          LDX  5,S            * GET ADDRESS OF STRING AND 
          STX  V4D            * SAVE IT IN V4D 
          LDA  4,S            = PUT LENGTH OF STRING IN 
          LDB  4,S            = BOTH ACCA AND ACCB 
          LEAS 7,S            REMOVE DESCRIPTOR AND RETURN ADDRESS FROM STACK 
          TFR  U,PC           JUMP TO ADDRESS IN U REGISTER 
LB706     JMP  LB44A          ILLEGAL FUNCTION CALL' 
* EVALUATE AN EXPRESSION - RETURN AN INTEGER IN                      
* ACCB - 'FC' ERROR IF EXPRESSION > 255                      
LB709     JSR  GETNCH         GET NEXT BASIC INPUT CHARACTER 
LB70B     JSR  LB141          EVALUATE A NUMERIC EXPRESSION 
LB70E     JSR  LB3E9          CONVERT FPA0 TO INTEGER IN ACCD 
          TSTA                TEST MS BYTE OF INTEGER 
          BNE  LB706          FC' ERROR IF EXPRESSION > 255 
          JMP  GETCCH         GET CURRENT INPUT CHARACTER FROM BASIC 
                               
* VAL                          
VAL       JSR  LB686          POINT X TO STRING ADDRESS 
          LBEQ LBA39          IF NULL STRING SET FPA0 
          LDU  CHARAD         SAVE INPUT POINTER IN REGISTER U 
          STX  CHARAD         POINT INPUT POINTER TO ADDRESS OF STRING 
          ABX  MOVE POINTER TO END OF STRING TERMINATOR  
          LDA  ,X             GET LAST BYTE OF STRING 
          PSHS U,X,A          SAVE INPUT POINTER, STRING TERMINATOR 
*         ADDRESS AND CHARACTER   
          CLR  ,X             CLEAR STRING TERMINATOR : FOR ASCII - FP CONVERSION 
          JSR  GETCCH         GET CURRENT CHARACTER FROM BASIC 
          JSR  LBD12          CONVERT AN ASCII STRING TO FLOATING POINT 
          PULS A,X,U          RESTORE CHARACTERS AND POINTERS 
          STA  ,X             REPLACE STRING TERMINATOR 
          STU  CHARAD         RESTORE INPUT CHARACTER 
          RTS                  
                               
LB734     BSR  LB73D          * EVALUATE AN EXPRESSION, RETURN 
          STX  BINVAL         * THE VALUE IN X; STORE IT IN BINVAL 
LB738     JSR  LB26D          SYNTAX CHECK FOR A COMMA 
          BRA  LB70B          EVALUATE EXPRESSION IN RANGE 0 <= X < 256 
* EVALUATE EXPRESSION : RETURN INTEGER PORTION IN X - 'FC' ERROR IF                      
                               
LB73D     JSR  LB141          EVALUATE NUMERIC EXPRESSION 
LB740     LDA  FP0SGN         GET SIGN OF FPA0 MANTISSA 
          BMI  LB706          ILLEGAL FUNCTION CALL' IF NEGATIVE 
          LDA  FP0EXP         GET EXPONENT OF FPA0 
          CMPA #$90           COMPARE TO LARGEST POSITIVE INTEGER 
          BHI  LB706          ILLEGAL FUNCTION CALL' IF TOO LARGE 
          JSR  LBCC8          SHIFT BINARY POINT TO EXTREME RIGHT OF FPA0 
          LDX  FPA0+2         LOAD X WITH LOWER TWO BYTES OF FPA0 
          RTS                  
                               
* PEEK                         
PEEK      BSR  LB740          CONVERT FPA0 TO INTEGER IN REGISTER X 
          LDB  ,X             GET THE VALUE BEING 'PEEK'ED 
          JMP  LB4F3          CONVERT ACCB INTO A FP NUMBER 
                               
* POKE                         
POKE      BSR  LB734          EVALUATE 2 EXPRESSIONS 
          LDX  BINVAL         GET THE ADDRESS TO BE 'POKE'ED 
          STB  ,X             STORE THE DATA IN THAT ADDRESS 
          RTS                  
                               
                               
* LIST                         
LIST      PSHS CC             SAVE ZERO FLAG ON STACK 
          JSR  LAF67          CONVERT DECIMAL LINE NUMBER TO BINARY 
          JSR  LAD01          * FIND RAM ADDRESS OF THAT LINE NUMBER AND 
          STX  LSTTXT         * SAVE IT IN LSTTXT 
          PULS CC             GET ZERO FLAG FROM STACK 
          BEQ  LB784          BRANCH IF END OF LINE 
          JSR  GETCCH         GET CURRENT CHARACTER FROM BASIC 
          BEQ  LB789          BRANCH IF END OF LINE 
          CMPA #TOK_MINUS     MINUS TOKEN (IS IT A RANGE OF LINE NUMBERS?) 
          BNE  LB783          NO - RETURN 
          JSR  GETNCH         GET NEXT CHARACTER FROM BASIC 
          BEQ  LB784          BRANCH IF END OF LINE 
          JSR  LAF67          GET ENDING LINE NUMBER 
          BEQ  LB789          BRANCH IF LEGAL LINE NUMBER 
LB783 RTS                      
* LIST THE ENTIRE PROGRAM                      
LB784     LDU  #$FFFF         * SET THE DEFAULT ENDING LINE NUMBER 
          STU  BINVAL         * TO $FFFF 
LB789     LEAS 2,S            PURGE RETURN ADDRESS FROM THE STACK 
          LDX  LSTTXT         POINT X TO STARTING LINE ADDRESS 
LB78D     JSR  LB95C          MOVE CURSOR TO START OF A NEW LINE 
          JSR  LA549          CHECK FOR A BREAK OR PAUSE 
          LDD  ,X             GET ADDRESS OF NEXT BASIC LINE 
          BNE  LB79F          BRANCH IF NOT END OF PROGRAM 
LB797                          
          JMP  LAC73          RETURN TO BASIC’S MAIN INPUT LOOP 
LB79F     STX  LSTTXT         SAVE NEW STARTING LINE ADDRESS 
          LDD  2,X            * GET THE LINE NUMBER OF THIS LINE AND 
          CMPD BINVAL         * COMPARE IT TO ENDING LINE NUMBER 
          BHI  LB797          EXIT IF LINE NUMBER > ENDING LINE NUMBER 
          JSR  LBDCC          PRINT THE NUMBER IN ACCD ON SCREEN IN DECIMAL 
          JSR  LB9AC          SEND A SPACE TO CONSOLE OUT 
          LDX  LSTTXT         GET RAM ADDRESS OF THIS LINE 
          BSR  LB7C2          UNCRUNCH A LINE 
          LDX  [LSTTXT]       POINT X TO START OF NEXT LINE 
          LDU  #LINBUF+1      POINT U TO BUFFER FULL OF UNCRUNCHED LINE 
LB7B9     LDA  ,U+            GET A BYTE FROM THE BUFFER 
          BEQ  LB78D          BRANCH IF END OF BUFFER 
          JSR  LB9B1          SEND CHARACTER TO CONSOLE OUT 
          BRA  LB7B9          GET ANOTHER CHARACTER 
                               
* UNCRUNCH A LINE INTO BASIC’S LINE INPUT BUFFER                      
LB7C2     LEAX 4,X            MOVE POINTER PAST ADDRESS OF NEXT LINE AND LINE NUMBER 
          LDY  #LINBUF+1      UNCRUNCH LINE INTO LINE INPUT BUFFER 
LB7CB     LDA  ,X+            GET A CHARACTER 
          BEQ  LB820          BRANCH IF END OF LINE 
          BMI  LB7E6          BRANCH IF IT’S A TOKEN 
          CMPA #':            CHECK FOR END OF SUB LINE 
          BNE  LB7E2          BRNCH IF NOT END OF SUB LINE 
          LDB  ,X             GET CHARACTER FOLLOWING COLON 
          CMPB #TOK_ELSE      TOKEN FOR ELSE? 
          BEQ  LB7CB          YES - DON’T PUT IT IN BUFFER 
          CMPB #TOK_SNGL_Q    TOKEN FOR REMARK? 
          BEQ  LB7CB          YES - DON’T PUT IT IN BUFFER 
          FCB  SKP2           SKIP TWO BYTES 
LB7E0     LDA  #'!            EXCLAMATION POINT 
LB7E2     BSR  LB814          PUT CHARACTER IN BUFFER 
          BRA  LB7CB          GET ANOTHER CHARACTER 
                               
LB7E6     LDU  #COMVEC-10     FIRST DO COMMANDS 
          CMPA #$FF           CHECK FOR SECONDARY TOKEN 
          BNE  LB7F1          BRANCH IF NON SECONDARY TOKEN 
          LDA  ,X+            GET SECONDARY TOKEN 
          LEAU 5,U            BUMP IT UP TO SECONDARY FUNCTIONS 
LB7F1     ANDA #$7F           MASK OFF BIT 7 OF TOKEN 
LB7F3     LEAU 10,U           MOVE TO NEXT COMMAND TABLE 
          TST  ,U             IS THIS TABLE ENABLED? 
          BEQ  LB7E0          NO - ILLEGAL TOKEN 
          SUBA ,U             SUBTRACT THE NUMBER OF TOKENS FROM THE CURRENT TOKEN NUMBER 
          BPL  LB7F3          BRANCH IF TOKEN NOT IN THIS TABLE 
          ADDA ,U             RESTORE TOKEN NUMBER RELATIVE TO THIS TABLE 
          LDU  1,U            POINT U TO COMMAND DICTIONARY TABLE 
LB801     DECA                DECREMENT TOKEN NUMBER 
          BMI  LB80A          BRANCH IF THIS IS THE CORRECT TOKEN 
* SKIP THROUGH DICTIONARY TABLE TO START OF NEXT TOKEN                      
LB804     TST  ,U+            GRAB A BYTE 
          BPL  LB804          BRANCH IF BIT 7 NOT SET 
          BRA  LB801          GO SEE IF THIS IS THE CORRECT TOKEN 
LB80A     LDA  ,U             GET A CHARACTER FROM DICTIONARY TABLE 
          BSR  LB814          PUT CHARACTER IN BUFFER 
          TST  ,U+            CHECK FOR START OF NEXT TOKEN 
          BPL  LB80A          BRANCH IF NOT DONE WITH THIS TOKEN 
          BRA  LB7CB          GO GET ANOTHER CHARACTER 
LB814     CMPY #LINBUF+LBUFMX TEST FOR END OF LINE INPUT BUFFER 
          BCC  LB820          BRANCH IF AT END OF BUFFER 
          ANDA #$7F           MASK OFF BIT 7 
          STA  ,Y+            * SAVE CHARACTER IN BUFFER AND 
          CLR  ,Y             * CLEAR NEXT CHARACTER SLOT IN BUFFER 
LB820     RTS                  
*                              
* CRUNCH THE LINE THAT THE INPUT POINTER IS                      
* POINTING TO INTO THE LINE INPUT BUFFER                      
* RETURN LENGTH OF CRUNCHED LINE IN ACCD                      
*                              
LB821     LDX  CHARAD         GET BASIC'S INPUT POINTER ADDRESS 
          LDU  #LINBUF        POINT X TO LINE INPUT BUFFER 
LB829     CLR  V43            CLEAR ILLEGAL TOKEN FLAG 
          CLR  V44            CLEAR DATA FLAG 
LB82D     LDA  ,X+            GET INPUT CHAR 
          BEQ  LB852          BRANCH IF END OF LINE 
          TST  V43            * CHECK ILLEGAL TOKEN FLAG & BRANCH IF NOT 
          BEQ  LB844          * PROCESSING AN ILLEGAL TOKEN 
          JSR  LB3A2          SET CARRY IF NOT UPPER CASE ALPHA 
          BCC  LB852          BRANCH IF UPPER CASE ALPHA 
          CMPA #'0            * DON’T CRUNCH ASCII NUMERIC CHARACTERS 
          BLO  LB842          * BRANCH IF NOT NUMERIC 
          CMPA #'9            * 
          BLS  LB852          * BRANCH IF NUMERIC 
* END UP HERE IF NOT UPPER CASE ALPHA OR NUMERIC                      
LB842     CLR  V43            CLEAR ILLEGAL TOKEN FLAG 
LB844     CMPA #SPACE         SPACE? 
          BEQ  LB852          DO NOT REMOVE SPACES 
          STA  V42            SAVE INPUT CHARACTER AS SCAN DELIMITER 
          CMPA #'"            CHECK FOR STRING DELIMITER 
          BEQ  LB886          BRANCH IF STRING 
          TST  V44            * CHECK DATA FLAG AND BRANCH IF CLEAR 
          BEQ  LB86B          * DO NOT CRUNCH DATA 
LB852     STA  ,U+            SAVE CHARACTER IN BUFFER 
          BEQ  LB85C          BRANCH IF END OF LINE 
          CMPA #':            * CHECK FOR END OF SUBLINE 
          BEQ  LB829          * AND RESET FLAGS IF END OF SUBLINE 
LB85A     BRA  LB82D          GO GET ANOTHER CHARACTER 
LB85C     CLR  ,U+            * DOUBLE ZERO AT END OF LINE 
          CLR  ,U+            * 
          TFR  U,D            SAVE ADDRESS OF END OF LINE IN ACCD 
          SUBD #LINHDR        LENGTH OF LINE IN ACCD 
          LDX  #LINBUF-1      * SET THE INPUT POINTER TO ONE BEFORE 
          STX  CHARAD         * THE START OF THE CRUNCHED LINE 
          RTS  EXIT 'CRUNCH'   
LB86B     CMPA #'?            CHECK FOR "?" - PRINT ABBREVIATION 
          BNE  LB873          BRANCH IF NOT PRINT ABBREVIATION 
          LDA  #TOK_PRINT     * GET THE PRINT TOKEN AND SAVE IT 
          BRA  LB852          * IN BUFFER 
LB873     CMPA #''            APOSTROPHE IS SAME AS REM 
          BNE  LB88A          BRANCH IF NOT REMARK 
          LDD  #$3A00+TOK_SNGL_Q COLON, REM TOKEN 
          STD  ,U++           SAVE IN BUFFER 
LB87C     CLR  V42            SET DELIMITER = 0 (END OF LINE) 
LB87E     LDA  ,X+            SCAN TILL WE MATCH [V42] 
          BEQ  LB852          BRANCH IF END OF LINE 
          CMPA V42            DELIMITER? 
          BEQ  LB852          BRANCH OUT IF SO 
LB886     STA  ,U+            DON’T CRUNCH REMARKS OR STRINGS 
          BRA  LB87E          GO GET MORE STRING OR REMARK 
LB88A     CMPA #'0            * LESS THAN ASCII ZERO? 
          BCS  LB892          * BRANCH IF SO 
          CMPA #';+1          = CHECK FOR NUMERIC VALUE, COLON OR SEMICOLON 
          BCS  LB852          = AND INSERT IN BUFFER IF SO 
LB892     LEAX -1,X           MOVE INPUT POINTER BACK ONE 
          PSHS U,X            SAVE POINTERS TO INPUT STRING, OUTPUT STRING 
          CLR  V41            TOKEN FLAG 0 = COMMAND, FF = SECONDARY 
          LDU  #COMVEC-10     POINT U TO COMMAND INTERPRETATION 
*                             TABLE FOR BASIC - 10 
LB89B     CLR  V42            INITIALIZE V42 AS TOKEN COUNTER 
LB89D     LEAU 10,U           MOVE TO NEXT COMMAND INTERPRETATION TABLE 
          LDA  ,U             GET NUMBER OF COMMANDS 
          BEQ  LB8D4          GO DO SECONDARY FUNCTIONS IF NO COMMAND TABLE 
          LDY  1,U            POINT Y TO COMMAND DICTIONARY TABLE 
LB8A6     LDX  ,S             GET POINTER TO INPUT STRING 
LB8A8     LDB  ,Y+            GET A BYTE FROM DICTIONARY TABLE 
          SUBB ,X+            SUBTRACT INPUT CHARACTER 
          BEQ  LB8A8          LOOP IF SAME 
          CMPB #$80           LAST CHAR IN RESERVED WORD TABLE HAD 
*                             BIT 7 SET, SO IF WE HAVE $80 HERE 
*                             THEN IT IS A GOOD COMPARE 
          BNE  LB8EA          BRANCH IF NO MATCH - CHECK ANOTHER COMMAND 
          LEAS 2,S            DELETE OLD INPUT POINTER FROM STACK 
          PULS U              GET POINTER TO OUTPUT STRING 
          ORB  V42            OR IN THE TABLE POSITION TO MAKE THE TOKEN 
*                             - NOTE THAT B ALREADY HAD $80 IN IT - 
          LDA  V41            * CHECK TOKEN FLAG AND BRANCH 
          BNE  LB8C2          * IF SECONDARY 
          CMPB #TOK_ELSE      IS IT ELSE TOKEN? 
          BNE  LB8C6          NO 
          LDA  #':            PUT A COLON (SUBLINE) BEFORE ELSE TOKEN 
LB8C2     STD  ,U++           SECONDARY TOKENS PRECEEDED BY $FF 
          BRA  LB85A          GO PROCESS MORE INPUT CHARACTERS 
LB8C6     STB  ,U+            SAVE THIS TOKEN 
          CMPB #TOK_DATA      DATA TOKEN? 
          BNE  LB8CE          NO 
          INC  V44            SET DATA FLAG 
LB8CE     CMPB #TOK_REM       REM TOKEN? 
          BEQ  LB87C          YES 
LB8D2     BRA  LB85A          GO PROCESS MORE INPUT CHARACTERS 
* CHECK FOR A SECONDARY TOKEN                      
LB8D4     LDU  #COMVEC-5      NOW DO SECONDARY FUNCTIONS 
          COM  V41            TOGGLE THE TOKEN FLAG 
          BNE  LB89B          BRANCH IF NOW CHECKING SECONDARY COMMANDS 
                               
* THIS CODE WILL PROCESS INPUT DATA WHICH CANNOT BE CRUNCHED AND SO                      
* IS ASSUMED TO BE ILLEGAL DATA OR AN ILLEGAL TOKEN                      
          PULS X,U            RESTORE INPUT AND OUTPUT POINTERS 
          LDA  ,X+            * MOVE THE FIRST CHARACTER OF AN 
          STA  ,U+            * ILLEGAL TOKEN 
          JSR  LB3A2          SET CARRY IF NOT ALPHA 
          BCS  LB8D2          BRANCH IF NOT ALPHA 
          COM  V43            SET ILLEGAL TOKEN FLAG IF UPPER CASE ALPHA 
          BRA  LB8D2          PROCESS MORE INPUT CHARACTERS 
LB8EA     INC  V42            INCREMENT TOKEN COUNTER 
          DECA                DECR COMMAND COUNTER 
          BEQ  LB89D          GET ANOTHER COMMAND TABLE IF DONE W/THIS ONE 
          LEAY -1,Y           MOVE POINTER BACK ONE 
LB8F1     LDB  ,Y+            * GET TO NEXT 
          BPL  LB8F1          * RESERVED WORD 
          BRA  LB8A6          GO SEE IF THIS WORD IS A MATCH 
                               
* PRINT                        
PRINT     BEQ  LB958          BRANCH IF NO ARGUMENT 
          BSR  LB8FE          CHECK FOR ALL PRINT OPTIONS 
          RTS                  
LB8FE                          
LB918     JSR  XVEC9          CALL EXTENDED BASIC ADD-IN 
LB91B     BEQ  LB965          RETURN IF END OF LINE 
LB91D     CMPA #TOK_TAB       TOKEN FOR TAB( ? 
          BEQ  LB97E          YES 
          CMPA #',            COMMA? 
          BEQ  LB966          YES - ADVANCE TO NEXT TAB FIELD 
          CMPA #';            SEMICOLON? 
          BEQ  LB997          YES - DO NOT ADVANCE CURSOR 
          JSR  LB156          EVALUATE EXPRESSION 
          LDA  VALTYP         * GET VARIABLE TYPE AND 
          PSHS A              * SAVE IT ON THE STACK 
          BNE  LB938          BRANCH IF STRING VARIABLE 
          JSR  LBDD9          CONVERT FP NUMBER TO AN ASCII STRING 
          JSR  LB516          PARSE A STRING FROM (X-1) AND PUT 
*                             DESCRIPTOR ON STRING STACK 
LB938     BSR  LB99F          PRINT STRING POINTED TO BY X 
          PULS B              GET VARIABLE TYPE BACK 
          JSR  LA35F          SET UP TAB WIDTH ZONE, ETC 
LB949     TSTB                CHECK CURRENT PRINT POSITION 
          BNE  LB954          BRANCH IF NOT AT START OF LINE 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          CMPA #',            COMMA? 
          BEQ  LB966          SKIP TO NEXT TAB FIELD 
          BSR  LB9AC          SEND A SPACE TO CONSOLE OUT 
LB954     JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          BNE  LB91D          BRANCH IF NOT END OF LINE 
LB958     LDA  #CR            * SEND A CR TO 
          BRA  LB9B1          * CONSOLE OUT 
LB95C     JSR  LA35F          SET UP TAB WIDTH, ZONE ETC 
          BEQ  LB958          BRANCH IF WIDTH = ZERO 
          LDA  DEVPOS         GET PRINT POSITION 
          BNE  LB958          BRANCH IF NOT AT START OF LINE 
LB965     RTS                  
* SKIP TO NEXT TAB FIELD                      
LB966     JSR  LA35F          SET UP TAB WIDTH, ZONE ETC 
          BEQ  LB975          BRANCH IF LINE WIDTH = 0 (CASSETTE) 
          LDB  DEVPOS         GET CURRENT POSITION 
          CMPB DEVLCF         COMPARE TO LAST TAB ZONE 
          BCS  LB977          BRANCH IF < LAST TAB ZONE 
          BSR  LB958          SEND A CARRIAGE RETURN TO CONSOLE OUT 
          BRA  LB997          GET MORE DATA 
LB975     LDB  DEVPOS         * 
LB977     SUBB DEVCFW         * SUBTRACT TAB FIELD WIDTH FROM CURRENT 
          BCC  LB977          * POSITION UNTIL CARRY SET - NEGATING THE 
          NEGB                * REMAINDER LEAVES THE NUMBER OF SPACES TO NEXT 
*              * TAB ZONE IN ACCB  
          BRA  LB98E          GO ADVANCE TO NEXT TAB ZONE 
                               
* PRINT TAB(                      
LB97E     JSR  LB709          EVALUATE EXPRESSION - RETURN VALUE IN B 
          CMPA #')            * 'SYNTAX' ERROR IF NOT ')' 
          LBNE LB277          * 
          JSR  LA35F          SET UP TAB WIDTH, ZONE ETC 
          SUBB DEVPOS         GET DIFFERENCE OF PRINT POSITION & TAB POSITION 
          BLS  LB997          BRANCH IF TAB POSITION < CURRENT POSITION 
LB98E                          
LB992     BSR  LB9AC          SEND A SPACE TO CONSOLE OUT 
          DECB                DECREMENT DIFFERENCE COUNT 
          BNE  LB992          BRANCH UNTIL CURRENT POSITION = TAB POSITION 
LB997     JSR  GETNCH         GET NEXT CHARACTER FROM BASIC 
          JMP  LB91B          LOOK FOR MORE PRINT DATA 
* COPY A STRING FROM (X) TO CONSOLE OUT                      
LB99C     JSR  LB518          PARSE A STRING FROM X AND PUT 
*         DESCRIPTOR ON STRING STACK  
LB99F     JSR  LB657          GET LENGTH OF STRING AND REMOVE 
*         DESCRIPTOR FROM STRING STACK  
          INCB                COMPENSATE FOR DECB BELOW 
LB9A3     DECB                DECREMENT COUNTER 
          BEQ  LB965          EXIT ROUTINE 
          LDA  ,X+            GET A CHARACTER FROM X 
          BSR  LB9B1          SEND TO CONSOLE OUT 
          BRA  LB9A3          KEEP LOOPING 
LB9AC     LDA  #SPACE         SPACE TO CONSOLE OUT 
          FCB  SKP2           SKIP NEXT TWO BYTES 
LB9AF     LDA  #'?            QUESTION MARK TO CONSOLE OUT 
LB9B1     JMP  PUTCHR         JUMP TO CONSOLE OUT 
                               
* FLOATING POINT MATH PACKAGE                      
                               
* ADD .5 TO FPA0                      
LB9B4     LDX  #LBEC0         FLOATING POINT CONSTANT (.5) 
          BRA  LB9C2          ADD .5 TO FPA0 
* SUBTRACT FPA0 FROM FP NUMBER POINTED                      
* TO BY (X), LEAVE RESULT IN FPA0                      
LB9B9     JSR  LBB2F          COPY PACKED FP DATA FROM (X) TO FPA1 
                               
* ARITHMETIC OPERATION (-) JUMPS HERE - SUBTRACT FPA0 FROM FPA1 (ENTER                      
* WITH EXPONENT OF FPA0 IN ACCB AND EXPONENT OF FPA1 IN ACCA)                      
LB9BC     COM  FP0SGN         CHANGE MANTISSA SIGN OF FPA0 
          COM  RESSGN         REVERSE RESULT SIGN FLAG 
          BRA  LB9C5          GO ADD FPA1 AND FPA0 
* ADD FP NUMBER POINTED TO BY                      
* (X) TO FPA0 - LEAVE RESULT IN FPA0                      
LB9C2     JSR  LBB2F          UNPACK PACKED FP DATA FROM (X) TO 
*         FPA1; RETURN EXPONENT OF FPA1 IN ACCA  
                               
* ARITHMETIC OPERATION (+) JUMPS HERE - ADD FPA0 TO                      
                               
LB9C5     TSTB                CHECK EXPONENT OF FPA0 
          LBEQ LBC4A          COPY FPA1 TO FPA0 IF FPA0 = 
          LDX  #FP1EXP        POINT X TO FPA1 
LB9CD     TFR  A,B            PUT EXPONENT OF FPA1 INTO ACCB 
          TSTB                CHECK EXPONENT 
          BEQ  LBA3E          RETURN IF EXPONENT = 0 (ADDING 0 TO FPA0) 
          SUBB FP0EXP         SUBTRACT EXPONENT OF FPA0 FROM EXPONENT OF FPA1 
          BEQ  LBA3F          BRANCH IF EXPONENTS ARE EQUAL 
          BCS  LB9E2          BRANCH IF EXPONENT FPA0 > FPA1 
          STA  FP0EXP         REPLACE FPA0 EXPONENT WITH FPA1 EXPONENT 
          LDA  FP1SGN         * REPLACE FPA0 MANTISSA SIGN 
          STA  FP0SGN         * WITH FPA1 MANTISSA SIGN 
          LDX  #FP0EXP        POINT X TO FPA0 
          NEGB                NEGATE DIFFERENCE OF EXPONENTS 
LB9E2     CMPB #-8            TEST DIFFERENCE OF EXPONENTS 
          BLE  LBA3F          BRANCH IF DIFFERENCE OF EXPONENTS <= 8 
          CLRA                CLEAR OVERFLOW BYTE 
          LSR  1,X            SHIFT MS BYTE OF MANTISSA; BIT 7 = 0 
          JSR  LBABA          GO SHIFT MANTISSA OF (X) TO THE RIGHT (B) TIMES 
LB9EC     LDB  RESSGN         GET SIGN FLAG 
          BPL  LB9FB          BRANCH IF FPA0 AND FPA1 SIGNS ARE THE SAME 
          COM  1,X            * COMPLEMENT MANTISSA POINTED 
          COM  2,X            * TO BY (X) THE 
          COM  3,X            * ADCA BELOW WILL 
          COM  4,X            * CONVERT THIS OPERATION 
          COMA                * INTO A NEG (MANTISSA) 
          ADCA #0             ADD ONE TO ACCA - COMA ALWAYS SETS THE CARRY FLAG 
* THE PREVIOUS TWO BYTES MAY BE REPLACED BY A NEGA                      
*                              
* ADD MANTISSAS OF FPA0 AND FPA1, PUT RESULT IN FPA0                      
LB9FB     STA  FPSBYT         SAVE FPA SUB BYTE 
          LDA  FPA0+3         * ADD LS BYTE 
          ADCA FPA1+3         * OF MANTISSA 
          STA  FPA0+3         SAVE IN FPA0 LSB 
          LDA  FPA0+2         * ADD NEXT BYTE 
          ADCA FPA1+2         * OF MANTISSA 
          STA  FPA0+2         SAVE IN FPA0 
          LDA  FPA0+1         * ADD NEXT BYTE 
          ADCA FPA1+1         * OF MANTISSA 
          STA  FPA0+1         SAVE IN FPA0 
          LDA  FPA0           * ADD MS BYTE 
          ADCA FPA1           * OF MANTISSA 
          STA  FPA0           SAVE IN FPA0 
          TSTB TEST SIGN FLAG  
          BPL  LBA5C          BRANCH IF FPA0 & FPA1 SIGNS WERE ALIKE 
LBA18     BCS  LBA1C          BRANCH IF POSITIVE MANTISSA 
          BSR  LBA79          NEGATE FPA0 MANTISSA 
                               
* NORMALIZE FPA0                      
LBA1C     CLRB                CLEAR TEMPORARY EXPONENT ACCUMULATOR 
LBA1D     LDA  FPA0           TEST MSB OF MANTISSA 
          BNE  LBA4F          BRANCH IF <> 0 
          LDA  FPA0+1         * IF THE MSB IS 
          STA  FPA0           * 0, THEN SHIFT THE 
          LDA  FPA0+2         * MANTISSA A WHOLE BYTE 
          STA  FPA0+1         * AT A TIME. THIS 
          LDA  FPA0+3         * IS FASTER THAN ONE 
          STA  FPA0+2         * BIT AT A TIME 
          LDA  FPSBYT         * BUT USES MORE MEMORY. 
          STA  FPA0+3         * FPSBYT, THE CARRY IN 
          CLR  FPSBYT         * BYTE, REPLACES THE MATISSA LSB. 
          ADDB #8             SHIFTING ONE BYTE = 8 BIT SHIFTS; ADD 8 TO EXPONENT 
          CMPB #5*8           CHECK FOR 5 SHIFTS 
          BLT  LBA1D          BRANCH IF < 5 SHIFTS, IF > 5, THEN MANTISSA = 0 
LBA39     CLRA                A ZERO EXPONENT = 0 FLOATING POINT 
LBA3A     STA  FP0EXP         ZERO OUT THE EXPONENT 
          STA  FP0SGN         ZERO OUT THE MANTISSA SIGN 
LBA3E     RTS                  
LBA3F     BSR  LBAAE          SHIFT FPA0 MANTISSA TO RIGHT 
          CLRB                CLEAR CARRY FLAG 
          BRA  LB9EC           
* SHIFT FPA0 LEFT ONE BIT UNTIL BIT 7                      
* OF MATISSA MS BYTE = 1                      
LBA44     INCB                ADD ONE TO EXPONENT ACCUMULATOR 
          ASL  FPSBYT         SHIFT SUB BYTE ONE LEFT 
          ROL  FPA0+3         SHIFT LS BYTE 
          ROL  FPA0+2         SHIFT NS BYTE 
          ROL  FPA0+1         SHIFT NS BYTE 
          ROL  FPA0           SHIFT MS BYTE 
LBA4F     BPL  LBA44          BRANCH IF NOT YET NORMALIZED 
          LDA  FP0EXP         GET CURRENT EXPONENT 
          PSHS B              SAVE EXPONENT MODIFIER CAUSED BY NORMALIZATION 
          SUBA ,S+            SUBTRACT ACCUMULATED EXPONENT MODIFIER 
          STA  FP0EXP         SAVE AS NEW EXPONENT 
          BLS  LBA39          SET FPA0 = 0 IF THE NORMALIZATION CAUSED 
*         MORE OR EQUAL NUMBER OF LEFT SHIFTS THAN THE  
*         SIZE OF THE EXPONENT  
          FCB  SKP2           SKIP 2 BYTES 
LBA5C     BCS  LBA66          BRANCH IF MANTISSA OVERFLOW 
          ASL  FPSBYT         SUB BYTE BIT 7 TO CARRY - USE AS ROUND-OFF 
*                             FLAG (TRUNCATE THE REST OF SUB BYTE) 
          LDA  #0             CLRA, BUT DO NOT CHANGE CARRY FLAG 
          STA  FPSBYT         CLEAR THE SUB BYTE 
          BRA  LBA72          GO ROUND-OFF RESULT 
LBA66     INC  FP0EXP         INCREMENT EXPONENT - MULTIPLY BY 2 
          BEQ  LBA92          OVERFLOW ERROR IF CARRY PAST $FF 
          ROR  FPA0           * SHIFT MANTISSA 
          ROR  FPA0+1         * ONE TO 
          ROR  FPA0+2         * THE RIGHT - 
          ROR  FPA0+3         * DIVIDE BY TWO 
LBA72     BCC  LBA78          BRANCH IF NO ROUND-OFF NEEDED 
          BSR  LBA83          ADD ONE TO MANTISSA - ROUND OFF 
          BEQ  LBA66          BRANCH iF OVERFLOW - MANTISSA = 0 
LBA78     RTS                  
* NEGATE FPA0 MANTISSA                      
LBA79     COM  FP0SGN         TOGGLE SIGN OF MANTISSA 
LBA7B     COM  FPA0           * COMPLEMENT ALL 4 MANTISSA BYTES 
          COM  FPA0+1         * 
          COM  FPA0+2         * 
          COM  FPA0+3         * 
* ADD ONE TO FPA0 MANTISSA                      
LBA83     LDX  FPA0+2         * GET BOTTOM 2 MANTISSA 
          LEAX 1,X            * BYTES, ADD ONE TO 
          STX  FPA0+2         * THEM AND SAVE THEM 
          BNE  LBA91          BRANCH IF NO OVERFLOW 
          LDX  FPA0           * IF OVERFLOW ADD ONE 
          LEAX 1,X            * TO TOP 2 MANTISSA 
          STX  FPA0           * BYTES AND SAVE THEM 
LBA91     RTS                  
LBA92     LDB  #2*5           OV' OVERFLOW ERROR 
          JMP  LAC46          PROCESS AN ERROR 
LBA97     LDX  #FPA2-1        POINT X TO FPA2 
* SHIFT FPA POINTED TO BY (X) TO                      
* THE RIGHT -(B) TIMES. EXIT WITH                      
* ACCA CONTAINING DATA SHIFTED OUT                      
* TO THE RIGHT (SUB BYTE) AND THE DATA                      
* SHIFTED IN FROM THE LEFT WILL COME FROM FPCARY                      
LBA9A     LDA  4,X            GET LS BYTE OF MANTISSA (X) 
          STA  FPSBYT         SAVE IN FPA SUB BYTE 
          LDA  3,X            * SHIFT THE NEXT THREE BYTES OF THE 
          STA  4,X            * MANTISSA RIGHT ONE COMPLETE BYTE. 
          LDA  2,X            * 
          STA  3,X            * 
          LDA  1,X            * 
          STA  2,X            * 
          LDA  FPCARY         GET THE CARRY IN BYTE 
          STA  1,X            STORE AS THE MS MANTISSA BYTE OF (X) 
LBAAE     ADDB #8             ADD 8 TO DIFFERENCE OF EXPONENTS 
          BLE  LBA9A          BRANCH IF EXPONENT DIFFERENCE < -8 
          LDA  FPSBYT         GET FPA SUB BYTE 
          SUBB #8             CAST OUT THE 8 ADDED IN ABOVE 
          BEQ  LBAC4          BRANCH IF EXPONENT DIFFERENCE = 0 
                               
                               
LBAB8     ASR  1,X            * SHIFT MANTISSA AND SUB BYTE ONE BIT TO THE RIGHT 
LBABA     ROR  2,X            * 
          ROR  3,X            * 
          ROR  4,X            * 
          RORA                * 
          INCB                ADD ONE TO EXPONENT DIFFERENCE 
          BNE  LBAB8          BRANCH IF EXPONENTS NOT = 
LBAC4     RTS                  
LBAC5     FCB  $81,$00,$00,$00,$00 FLOATING POINT CONSTANT 1.0 
                               
* ARITHMETIC OPERATION (*) JUMPS HERE - MULTIPLY                      
* FPA0 BY (X) - RETURN PRODUCT IN FPA0                      
LBACA     BSR  LBB2F          MOVE PACKED FPA FROM (X) TO FPA1 
LBACC     BEQ  LBB2E          BRANCH IF EXPONENT OF FPA0 = 0 
          BSR  LBB48          CALCULATE EXPONENT OF PRODUCT 
* MULTIPLY FPA0 MANTISSA BY FPA1. NORMALIZE                      
* HIGH ORDER BYTES OF PRODUCT IN FPA0. THE                      
* LOW ORDER FOUR BYTES OF THE PRODUCT WILL                      
* BE STORED IN VAB-VAE.                      
LBAD0     LDA  #0             * ZERO OUT MANTISSA OF FPA2 
          STA  FPA2           * 
          STA  FPA2+1         * 
          STA  FPA2+2         * 
          STA  FPA2+3         * 
          LDB  FPA0+3         GET LS BYTE OF FPA0 
          BSR  LBB00          MULTIPLY BY FPA1 
          LDB  FPSBYT         * TEMPORARILY SAVE SUB BYTE 4 
          STB  VAE            * 
          LDB  FPA0+2         GET NUMBER 3 MANTISSA BYTE OF FPA0 
          BSR  LBB00          MULTIPLY BY FPA1 
          LDB  FPSBYT         * TEMPORARILY SAVE SUB BYTE 3 
          STB  VAD            * 
          LDB  FPA0+1         GET NUMBER 2 MANTISSA BYTE OF FPA0 
          BSR  LBB00          MULTIPLY BY FPA1 
          LDB  FPSBYT         * TEMPORARILY SAVE SUB BYTE 2 
          STB  VAC            * 
          LDB  FPA0           GET MS BYTE OF FPA0 MANTISSA 
          BSR  LBB02          MULTIPLY BY FPA1 
          LDB  FPSBYT         * TEMPORARILY SAVE SUB BYTE 1 
          STB  VAB            * 
          JSR  LBC0B          COPY MANTISSA FROM FPA2 TO FPA0 
          JMP  LBA1C          NORMALIZE FPA0 
LBB00     BEQ  LBA97          SHIFT FPA2 ONE BYTE TO RIGHT 
LBB02     COMA                SET CARRY FLAG 
* MULTIPLY FPA1 MANTISSA BY ACCB AND                      
* ADD PRODUCT TO FPA2 MANTISSA                      
LBB03     LDA  FPA2           GET FPA2 MS BYTE 
          RORB ROTATE CARRY FLAG INTO SHIFT COUNTER;  
*         DATA BIT INTO CARRY  
          BEQ  LBB2E          BRANCH WHEN 8 SHIFTS DONE 
          BCC  LBB20          DO NOT ADD FPA1 IF DATA BIT = 0 
          LDA  FPA2+3         * ADD MANTISSA LS BYTE 
          ADDA FPA1+3         * 
          STA  FPA2+3         * 
          LDA  FPA2+2         = ADD MANTISSA NUMBER 3 BYTE 
          ADCA FPA1+2         = 
          STA  FPA2+2         = 
          LDA  FPA2+1         * ADD MANTISSA NUMBER 2 BYTE 
          ADCA FPA1+1         * 
          STA  FPA2+1         * 
          LDA  FPA2           = ADD MANTISSA MS BYTE 
          ADCA FPA1           = 
LBB20     RORA * ROTATE CARRY INTO MS BYTE  
          STA  FPA2           * 
          ROR  FPA2+1         = ROTATE FPA2 ONE BIT TO THE RIGHT 
          ROR  FPA2+2         = 
          ROR  FPA2+3         = 
          ROR  FPSBYT         = 
          CLRA                CLEAR CARRY FLAG 
          BRA  LBB03          KEEP LOOPING 
LBB2E     RTS                  
* UNPACK A FP NUMBER FROM (X) TO FPA1                      
LBB2F     LDD  1,X            GET TWO MSB BYTES OF MANTISSA FROM 
*         FPA  POINTED TO BY X  
          STA  FP1SGN         SAVE PACKED MANTISSA SIGN BYTE 
          ORA  #$80           FORCE BIT 7 OF MSB MANTISSA = 1 
          STD  FPA1           SAVE 2 MSB BYTES IN FPA1 
          LDB  FP1SGN         * GET PACKED MANTISSA SIGN BYTE. EOR W/FPA0 
          EORB FP0SGN         * SIGN - NEW SIGN POSITION IF BOTH OLD SIGNS ALIKE, 
          STB  RESSGN         * NEG IF BOTH OLD SIGNS DIFF. SAVE ADJUSTED 
*                             * MANTISSA SIGN BYTE 
          LDD  3,X            = GET 2 LSB BYTES OF MANTISSA 
          STD  FPA1+2         = AND PUT IN FPA1 
          LDA  ,X             * GET EXPONENT FROM (X) AND 
          STA  FP1EXP         * PUT IN EXPONENT OF FPA1 
          LDB  FP0EXP         GET EXPONENT OF FPA0 
          RTS                  
* CALCULATE EXPONENT FOR PRODUCT OF FPA0 & FPA1                      
* ENTER WITH EXPONENT OF FPA1 IN ACCA                      
LBB48     TSTA                TEST EXPONENT OF FPA1 
          BEQ  LBB61          PURGE RETURN ADDRESS & SET FPA0 = 0 
          ADDA FP0EXP         ADD FPA1 EXPONENT TO FPA0 EXPONENT 
          RORA                ROTATE CARRY INTO BIT 7; BIT 0 INTO CARRY 
          ROLA                SET OVERFLOW FLAG 
          BVC  LBB61          BRANCH IF EXPONENT TOO LARGE OR SMALL 
          ADDA #$80           ADD $80 BIAS TO EXPONENT 
          STA  FP0EXP         SAVE NEW EXPONENT 
          BEQ  LBB63          SET FPA0 
          LDA  RESSGN         GET MANTISSA SIGN 
          STA  FP0SGN         SAVE AS MANTISSA SIGN OF FPA0 
          RTS                  
* IF FPA0 = POSITIVE THEN 'OV' ERROR IF FPA0                      
* = IS NEGATIVE THEN FPA0 = 0                      
LBB5C     LDA  FP0SGN         GET MANTISSA SIGN OF FPA0 
          COMA                CHANGE SIGN OF FPA0 MANTISSA 
          BRA  LBB63           
LBB61     LEAS 2,S            PURGE RETURN ADDRESS FROM STACK 
LBB63     LBPL LBA39          ZERO FPA0 MANTISSA SIGN & EXPONENT 
LBB67     JMP  LBA92          OV' OVERFLOW ERROR 
* FAST MULTIPLY BY 10 AND LEAVE RESULT IN FPA0                      
LBB6A     JSR  LBC5F          TRANSFER FPA0 TO FPA1 
          BEQ  LBB7C          BRANCH IF EXPONENT = 0 
          ADDA #2             ADD 2 TO EXPONENT (TIMES 4) 
          BCS  LBB67          OV' ERROR IF EXPONENT > $FF 
          CLR  RESSGN         CLEAR RESULT SIGN BYTE 
          JSR  LB9CD          ADD FPA1 TO FPA0 (TIMES 5) 
          INC  FP0EXP         ADD ONE TO EXPONENT (TIMES 10) 
          BEQ  LBB67          OV' ERROR IF EXPONENT > $FF 
LBB7C     RTS                  
LBB7D     FCB  $84,$20,$00,$00,$00 FLOATING POINT CONSTANT 10 
* DIVIDE FPA0 BY 10                      
LBB82     JSR  LBC5F          MOVE FPA0 TO FPA1 
          LDX  #LBB7D         POINT TO FLOATING POINT CONSTANT 10 
          CLRB                ZERO MANTISSA SIGN BYTE 
LBB89     STB  RESSGN         STORE THE QUOTIENT MANTISSA SIGN BYTE 
          JSR  LBC14          UNPACK AN FP NUMBER FROM (X) INTO FPA0 
          FCB  SKP2           SKIP TWO BYTES 
* DIVIDE (X) BY FPA0-LEAVE NORMALIZED QUOTIENT IN FPA0                      
LBB8F     BSR  LBB2F          GET FP NUMBER FROM (X) TO FPA1 
                               
* ARITHMETIC OPERATION (/) JUMPS HERE. DIVIDE FPA1 BY FPA0 (ENTER WITH                      
* EXPONENT OF FPA1 IN ACCA AND FLAGS SET BY TSTA)                      
                               
* DIVIDE FPA1 BY FPA0                      
LBB91     BEQ  LBC06          /0' DIVIDE BY ZERO ERROR 
          NEG  FP0EXP         GET EXPONENT OF RECIPROCAL OF DIVISOR 
          BSR  LBB48          CALCULATE EXPONENT OF QUOTIENT 
          INC  FP0EXP         INCREMENT EXPONENT 
          BEQ  LBB67          OV' OVERFLOW ERROR 
          LDX  #FPA2          POINT X TO MANTISSA OF FPA2 - HOLD 
*                             TEMPORARY QUOTIENT IN FPA2 
          LDB  #4             5 BYTE DIVIDE 
          STB  TMPLOC         SAVE BYTE COUNTER 
          LDB  #1             SHIFT COUNTER-AND TEMPORARY QUOTIENT BYTE 
* COMPARE FPA0 MANTISSA TO FPA1 MANTISSA -                      
* SET CARRY FLAG IF FPA1 >= FPA0                      
LBBA4     LDA  FPA0           * COMPARE THE TWO MS BYTES 
          CMPA FPA1           * OF FPA0 AND FPA1 AND 
          BNE  LBBBD          * BRANCH IF <> 
          LDA  FPA0+1         = COMPARE THE NUMBER 2 
          CMPA FPA1+1         = BYTES AND 
          BNE  LBBBD          = BRANCH IF <> 
          LDA  FPA0+2         * COMPARE THE NUMBER 3 
          CMPA FPA1+2         * BYTES AND 
          BNE  LBBBD          * BRANCH IF <> 
          LDA  FPA0+3         = COMPARE THE LS BYTES 
          CMPA FPA1+3         = AND BRANCH 
          BNE  LBBBD          = IF <> 
          COMA                SET CARRY FLAG IF FPA0 = FPA1 
LBBBD     TFR  CC,A           SAVE CARRY FLAG STATUS IN ACCA; CARRY 
*         CLEAR IF FPA0 > FPA1  
          ROLB                ROTATE CARRY INTO TEMPORARY QUOTIENT BYTE 
          BCC  LBBCC          CARRY WILL BE SET AFTER 8 SHIFTS 
          STB  ,X+            SAVE TEMPORARY QUOTIENT 
          DEC  TMPLOC         DECREMENT BYTE COUNTER 
          BMI  LBBFC          BRANCH IF DONE 
          BEQ  LBBF8          BRANCH IF LAST BYTE 
          LDB  #1             RESET SHIFT COUNTER AND TEMPORARY QUOTIENT BYTE 
LBBCC     TFR  A,CC           RESTORE CARRY FLAG AND 
          BCS  LBBDE          BRANCH IF FPA0 =< FPA1 
LBBD0     ASL  FPA1+3         * SHIFT FPA1 MANTISSA 1 BIT TO LEFT 
          ROL  FPA1+2         * 
          ROL  FPA1+1         * 
          ROL  FPA1           * 
          BCS  LBBBD          BRANCH IF CARRY - ADD ONE TO PARTIAL QUOTIENT 
          BMI  LBBA4          IF MSB OF HIGH ORDER MANTISSA BYTE IS 
*         SET, CHECK THE MAGNITUDES OF FPA0, FPA1  
          BRA  LBBBD          CARRY IS CLEAR, CHECK ANOTHER BIT 
* SUBTRACT FPA0 FROM FPA1 - LEAVE RESULT IN FPA1                      
LBBDE     LDA  FPA1+3         * SUBTRACT THE LS BYTES OF MANTISSA 
          SUBA FPA0+3         * 
          STA  FPA1+3         * 
          LDA  FPA1+2         = THEN THE NEXT BYTE 
          SBCA FPA0+2         = 
          STA  FPA1+2         = 
          LDA  FPA1+1         * AND THE NEXT 
          SBCA FPA0+1         * 
          STA  FPA1+1         * 
          LDA  FPA1           = AND FINALLY, THE MS BYTE OF MANTISSA 
          SBCA FPA0           = 
          STA  FPA1           = 
          BRA  LBBD0          GO SHIFT FPA1 
LBBF8     LDB  #$40           USE ONLY TWO BITS OF THE LAST BYTE (FIFTH) 
          BRA  LBBCC          GO SHIFT THE LAST BYTE 
LBBFC     RORB * SHIFT CARRY (ALWAYS SET HERE) INTO  
          RORB * BIT 5 AND MOVE  
          RORB * BITS 1,0 TO BITS 7,6  
          STB  FPSBYT         SAVE SUB BYTE 
          BSR  LBC0B          MOVE MANTISSA OF FPA2 TO FPA0 
          JMP  LBA1C          NORMALIZE FPA0 
LBC06     LDB  #2*10          /0' ERROR 
          JMP  LAC46          PROCESS THE ERROR 
* COPY MANTISSA FROM FPA2 TO FPA0                      
LBC0B     LDX  FPA2           * MOVE TOP 2 BYTES 
          STX  FPA0           * 
          LDX  FPA2+2         = MOVE BOTTOM 2 BYTES 
          STX  FPA0+2         = 
          RTS                  
* COPY A PACKED FP NUMBER FROM (X) TO FPA0                      
LBC14     PSHS A              SAVE ACCA 
          LDD  1,X            GET TOP TWO MANTISSA BYTES 
          STA  FP0SGN         SAVE MS BYTE OF MANTISSA AS MANTISSA SIGN 
          ORA  #$80           UNPACK MS BYTE 
          STD  FPA0           SAVE UNPACKED TOP 2 MANTISSA BYTES 
          CLR  FPSBYT         CLEAR MANTISSA SUB BYTE 
          LDB  ,X             GET EXPONENT TO ACCB 
          LDX  3,X            * MOVE LAST 2 
          STX  FPA0+2         * MANTISSA BYTES 
          STB  FP0EXP         SAVE EXPONENT 
          PULS A,PC           RESTORE ACCA AND RETURN 
                               
LBC2A     LDX  #V45           POINT X TO MANTISSA OF FPA4 
          BRA  LBC35          MOVE FPA0 TO FPA4 
LBC2F     LDX  #V40           POINT X TO MANTISSA OF FPA3 
          FCB  SKP2           SKIP TWO BYTES 
LBC33     LDX  VARDES         POINT X TO VARIABLE DESCRIPTOR IN VARDES 
* PACK FPA0 AND MOVE IT TO ADDRESS IN X                      
LBC35     LDA  FP0EXP         * COPY EXPONENT 
          STA  ,X             * 
          LDA  FP0SGN         GET MANTISSA SIGN BIT 
          ORA  #$7F           MASK THE BOTTOM 7 BITS 
          ANDA FPA0           AND BIT 7 OF MANTISSA SIGN INTO BIT 7 OF MS BYTE 
          STA  1,X            SAVE MS BYTE 
          LDA  FPA0+1         * MOVE 2ND MANTISSA BYTE 
          STA  2,X            * 
          LDU  FPA0+2         = MOVE BOTTOM 2 MANTISSA BYTES 
          STU  3,X            = 
          RTS                  
* MOVE FPA1 TO FPA0 RETURN W/MANTISSA SIGN IN ACCA                      
LBC4A     LDA  FP1SGN         * COPY MANTISSA SIGN FROM 
LBC4C     STA  FP0SGN         * FPA1 TO FPA0 
          LDX  FP1EXP         = COPY EXPONENT + MS BYTE FROM 
          STX  FP0EXP         = FPA1 TO FPA0 
          CLR  FPSBYT         CLEAR MANTISSA SUB BYTE 
          LDA  FPA1+1         * COPY 2ND MANTISSA BYTE 
          STA  FPA0+1         * FROM FPA1 TO FPA0 
          LDA  FP0SGN         GET MANTISSA SIGN 
          LDX  FPA1+2         * COPY 3RD AND 4TH MANTISSA BYTE 
          STX  FPA0+2         * FROM FPA1 TO FPA0 
          RTS                  
* TRANSFER FPA0 TO FPA1                      
LBC5F     LDD  FP0EXP         * TRANSFER EXPONENT & MS BYTE 
          STD  FP1EXP         * 
          LDX  FPA0+1         = TRANSFER MIDDLE TWO BYTES 
          STX  FPA1+1         = 
          LDX  FPA0+3         * TRANSFER BOTTOM TWO BYTES 
          STX  FPA1+3         * 
          TSTA                SET FLAGS ACCORDING TO EXPONENT 
          RTS                  
* CHECK FPA0; RETURN ACCB = 0 IF FPA0 = 0,                      
* ACCB = $FF IF FPA0 = NEGATIVE, ACCB = 1 IF FPA0 = POSITIVE                      
LBC6D     LDB  FP0EXP         GET EXPONENT 
          BEQ  LBC79          BRANCH IF FPA0 = 0 
LBC71     LDB  FP0SGN         GET SIGN OF MANTISSA 
LBC73     ROLB                BIT 7 TO CARRY 
          LDB  #$FF           NEGATIVE FLAG 
          BCS  LBC79          BRANCH IF NEGATIVE MANTISSA 
          NEGB                ACCB = 1 IF POSITIVE MANTISSA 
LBC79     RTS                  
                               
* SGN                          
SGN       BSR  LBC6D          SET ACCB ACCORDING TO SIGN OF FPA0 
* CONVERT A SIGNED NUMBER IN ACCB INTO A FLOATING POINT NUMBER                      
LBC7C     STB  FPA0           SAVE ACCB IN FPA0 
          CLR  FPA0+1         CLEAR NUMBER 2 MANTISSA BYTE OF FPA0 
          LDB  #$88           EXPONENT REQUIRED IF FPA0 IS TO BE AN INTEGER 
LBC82     LDA  FPA0           GET MS BYTE OF MANTISSA 
          SUBA #$80           SET CARRY IF POSITIVE MANTISSA 
LBC86     STB  FP0EXP         SAVE EXPONENT 
          LDD  ZERO           * ZERO OUT ACCD AND 
          STD  FPA0+2         * BOTTOM HALF OF FPA0 
          STA  FPSBYT         CLEAR SUB BYTE 
          STA  FP0SGN         CLEAR SIGN OF FPA0 MANTISSA 
          JMP  LBA18          GO NORMALIZE FPA0 
                               
* ABS                          
ABS       CLR  FP0SGN         FORCE MANTISSA SIGN OF FPA0 POSITIVE 
          RTS                  
* COMPARE A PACKED FLOATING POINT NUMBER POINTED TO                      
* BY (X) TO AN UNPACKED FP NUMBER IN FPA0. RETURN                      
* ZERO FLAG SET AND ACCB = 0, IF EQUAL; ACCB = 1 IF                      
* FPA0 > (X); ACCB = $FF IF FPA0 < (X)                      
LBC96     LDB  ,X             CHECK EXPONENT OF (X) 
          BEQ  LBC6D          BRANCH IF FPA = 0 
          LDB  1,X            GET MS BYTE OF MANTISSA OF (X) 
          EORB FP0SGN         EOR WITH SIGN OF FPA0 
          BMI  LBC71          BRANCH IF SIGNS NOT = 
* COMPARE FPA0 WITH FP NUMBER POINTED TO BY (X).                      
* FPA0 IS NORMALIZED, (X) IS PACKED.                      
LBCA0     LDB  FP0EXP         * GET EXPONENT OF 
          CMPB ,X             * FPA0, COMPARE TO EXPONENT OF 
          BNE  LBCC3          * (X) AND BRANCH IF <>. 
          LDB  1,X            * GET MS BYTE OF (X), KEEP ONLY 
          ORB  #$7F           * THE SIGN BIT - 'AND' THE BOTTOM 7 
          ANDB FPA0           * BITS OF FPA0 INTO ACCB 
          CMPB 1,X            = COMPARE THE BOTTOM 7 BITS OF THE MANTISSA 
          BNE  LBCC3          = MS BYTE AND BRANCH IF <> 
          LDB  FPA0+1         * COMPARE 2ND BYTE 
          CMPB 2,X            * OF MANTISSA, 
          BNE  LBCC3          * BRANCH IF <> 
          LDB  FPA0+2         = COMPARE 3RD BYTE 
          CMPB 3,X            = OF MANTISSA, 
          BNE  LBCC3          = BRANCH IF <> 
          LDB  FPA0+3         * SUBTRACT LS BYTE 
          SUBB 4,X            * OF (X) FROM LS BYTE OF 
          BNE  LBCC3          * FPA0, BRANCH IF <> 
          RTS                 RETURN IF FP (X) = FPA0 
LBCC3     RORB                SHIFT CARRY TO BIT 7; CARRY SET IF FPA0 < (X) 
          EORB FP0SGN         TOGGLE SIZE COMPARISON BIT IF FPA0 IS NEGATIVE 
          BRA  LBC73          GO SET ACCB ACCORDING TO COMPARISON 
* DE-NORMALIZE FPA0 : SHIFT THE MANTISSA UNTIL THE BINARY POINT IS TO THE RIGHT                      
* OF THE LEAST SIGNIFICANT BYTE OF THE MANTISSA                      
LBCC8     LDB  FP0EXP         GET EXPONENT OF FPA0 
          BEQ  LBD09          ZERO MANTISSA IF FPA0 = 0 
          SUBB #$A0           SUBTRACT $A0 FROM FPA0 EXPONENT T THIS WILL YIELD 
*                             THE NUMBER OF SHIFTS REQUIRED TO DENORMALIZE FPA0. WHEN 
*                             THE EXPONENT OF FPA0 IS = ZERO, THEN THE BINARY POINT 
*                             WILL BE TO THE RIGHT OF THE MANTISSA 
          LDA  FP0SGN         TEST SIGN OF FPA0 MANTISSA 
          BPL  LBCD7          BRANCH IF POSITIVE 
          COM  FPCARY         COMPLEMENT CARRY IN BYTE 
          JSR  LBA7B          NEGATE MANTISSA OF FPA0 
LBCD7     LDX  #FP0EXP        POINT X TO FPA0 
          CMPB #-8            EXPONENT DIFFERENCE < -8? 
          BGT  LBCE4          YES 
          JSR  LBAAE          SHIFT FPA0 RIGHT UNTIL FPA0 EXPONENT = $A0 
          CLR  FPCARY         CLEAR CARRY IN BYTE 
          RTS                  
LBCE4     CLR  FPCARY         CLEAR CARRY IN BYTE 
          LDA  FP0SGN         * GET SIGN OF FPA0 MANTISSA 
          ROLA                * ROTATE IT INTO THE CARRY FLAG 
          ROR  FPA0           ROTATE CARRY (MANTISSA SIGN) INTO BIT 7 
*                             OF LS BYTE OF MANTISSA 
          JMP  LBABA          DE-NORMALIZE FPA0 
                               
* INT                          
* THE INT STATEMENT WILL "DENORMALIZE" FPA0 - THAT IS IT WILL SHIFT THE BINARY POINT                      
* TO THE EXTREME RIGHT OF THE MANTISSA TO FORCE ITS EXPONENT TO BE $AO. ONCE                      
* THIS IS DONE THE MANTISSA OF FPA0 WILL CONTAIN THE FOUR LEAST SIGNIFICANT                      
* BYTES OF THE INTEGER PORTION OF FPA0. AT THE CONCLUSION OF THE DE-NORMALIZATION                      
* ONLY THE INTEGER PORTION OF FPA0 WILL REMAIN.                      
*                              
INT       LDB  FP0EXP         GET EXPONENT OF FPA0 
          CMPB #$A0           LARGEST POSSIBLE INTEGER EXPONENT 
          BCC  LBD11          RETURN IF FPA0 >= 32768 
          BSR  LBCC8          SHIFT THE BINARY POINT ONE TO THE RIGHT OF THE 
*                             LS BYTE OF THE FPA0 MANTISSA 
          STB  FPSBYT         ACCB = 0: ZERO OUT THE SUB BYTE 
          LDA  FP0SGN         GET MANTISSA SIGN 
          STB  FP0SGN         FORCE MANTISSA SIGN TO BE POSITIVE 
          SUBA #$80           SET CARRY IF MANTISSA 
          LDA  #$A0           * GET DENORMALIZED EXPONENT AND 
          STA  FP0EXP         * SAVE IT IN FPA0 EXPONENT 
          LDA  FPA0+3         = GET LS BYTE OF FPA0 AND 
          STA  CHARAC         = SAVE IT IN CHARAC 
          JMP  LBA18          NORMALIZE FPA0 
                               
LBD09     STB  FPA0           * LOAD MANTISSA OF FPA0 WITH CONTENTS OF ACCB 
          STB  FPA0+1         * 
          STB  FPA0+2         * 
          STB  FPA0+3         * 
LBD11     RTS                 * 
                               
* CONVERT ASCII STRING TO FLOATING POINT                      
LBD12     LDX  ZERO           (X) = 0 
          STX  FP0SGN         * ZERO OUT FPA0 & THE SIGN FLAG (COEFCT) 
          STX  FP0EXP         * 
          STX  FPA0+1         * 
          STX  FPA0+2         * 
          STX  V47            INITIALIZE EXPONENT & EXPONENT SIGN FLAG TO ZERO 
          STX  V45            INITIALIZE RIGHT DECIMAL CTR & DECIMAL PT FLAG TO 0 
          BCS  LBD86          IF CARRY SET (NUMERIC CHARACTER), ASSUME ACCA CONTAINS FIRST 
*         NUMERIC CHAR, SIGN IS POSITIVE AND SKIP THE RAM HOOK  
          JSR  XVEC19         CALL EXTENDED BASIC ADD-IN 
LBD25     CMPA #'-            * CHECK FOR A LEADING MINUS SIGN AND BRANCH 
          BNE  LBD2D          * IF NO MINUS SIGN 
          COM  COEFCT         TOGGLE SIGN; 0 = +; FF = - 
          BRA  LBD31          INTERPRET THE REST OF THE STRING 
LBD2D     CMPA #'+            * CHECK FOR LEADING PLUS SlGN AND BRANCH 
          BNE  LBD35          * IF NOT A PLUS SIGN 
LBD31     JSR  GETNCH         GET NEXT INPUT CHARACTER FROM BASIC 
          BCS  LBD86          BRANCH IF NUMERIC CHARACTER 
LBD35     CMPA #'.            DECIMAL POlNT? 
          BEQ  LBD61          YES 
          CMPA #'E            "E" SHORTHAND FORM (SCIENTIFIC NOTATION)? 
          BNE  LBD65          NO 
* EVALUATE EXPONENT OF EXPONENTIAL FORMAT                      
          JSR  GETNCH         GET NEXT INPUT CHARACTER FROM BASIC 
          BCS  LBDA5          BRANCH IF NUMERIC 
          CMPA #TOK_MINUS     MINUS TOKEN? 
          BEQ  LBD53          YES 
          CMPA #'-            ASCII MINUS? 
          BEQ  LBD53          YES 
          CMPA #TOK_PLUS      PLUS TOKEN? 
          BEQ  LBD55          YES 
          CMPA #'+            ASCII PLUS? 
          BEQ  LBD55          YES 
          BRA  LBD59          BRANCH IF NO SIGN FOUND 
LBD53     COM  V48            SET EXPONENT SIGN FLAG TO NEGATIVE 
* STRIP A DECIMAL NUMBER FROM BASIC LINE, CONVERT IT TO BINARY IN V47                      
LBD55     JSR  GETNCH         GET NEXT INPUT CHARACTER FROM BASIC 
          BCS  LBDA5          IF NUMERIC CHARACTER, CONVERT TO BINARY 
LBD59     TST  V48            * CHECK EXPONENT SIGN FLAG 
          BEQ  LBD65          * AND BRANCH IF POSITIVE 
          NEG  V47            NEGATE VALUE OF EXPONENT 
          BRA  LBD65           
LBD61     COM  V46            *TOGGLE DECIMAL PT FLAG AND INTERPRET ANOTHER 
          BNE  LBD31          *CHARACTER IF <> 0 - TERMINATE INTERPRETATION 
*         IF   SECOND DECIMAL POINT  
* ADJUST FPA0 FOR THE DECIMAL EXPONENT IN V47                      
LBD65     LDA  V47            * GET EXPONENT, SUBTRACT THE NUMBER OF 
          SUBA V45            * PLACES TO THE RIGHT OF DECIMAL POINT 
          STA  V47            * AND RESAVE IT. 
          BEQ  LBD7F          EXIT ROUTINE IF ADJUSTED EXPONENT = ZERO 
          BPL  LBD78          BRANCH IF POSITIVE EXPONENT 
LBD6F     JSR  LBB82          DIVIDE FPA0 BY 10 
          INC  V47            INCREMENT EXPONENT COUNTER (MULTIPLY BY 10) 
          BNE  LBD6F          KEEP MULTIPLYING 
          BRA  LBD7F          EXIT ROUTINE 
LBD78     JSR  LBB6A          MULTIPLY FPA0 BY 10 
          DEC  V47            DECREMENT EXPONENT COUNTER (DIVIDE BY 10) 
          BNE  LBD78          KEEP MULTIPLYING 
LBD7F     LDA  COEFCT         GET THE SIGN FLAG 
          BPL  LBD11          RETURN IF POSITIVE 
          JMP  LBEE9          TOGGLE MANTISSA SIGN OF FPA0, IF NEGATIVE 
*MULTIPLY FPA0 BY TEN AND ADD ACCA TO THE RESULT                      
LBD86     LDB  V45            *GET THE RIGHT DECIMAL COUNTER AND SUBTRACT 
          SUBB V46            *THE DECIMAL POINT FLAG FROM IT. IF DECIMAL POINT 
          STB  V45            *FLAG=0, NOTHING HAPPENS. IF DECIMAL POINT FLAG IS 
*                             -1, THEN RIGHT DECIMAL COUNTER IS INCREMENTED BY ONE 
          PSHS A              SAVE NEW DIGIT ON STACK 
          JSR  LBB6A          MULTIPLY FPA0 BY 10 
          PULS B              GET NEW DIGIT BACK 
          SUBB #'0            MASK OFF ASCII 
          BSR  LBD99          ADD ACCB TO FPA0 
          BRA  LBD31          GET ANOTHER CHARACTER FROM BASIC 
LBD99     JSR  LBC2F          PACK FPA0 AND SAVE IT IN FPA3 
          JSR  LBC7C          CONVERT ACCB TO FP NUMBER IN FPA0 
          LDX  #V40           * ADD FPA0 TO 
          JMP  LB9C2          * FPA3 
                               
                               
LBDA5     LDB  V47             
          ASLB                TIMES 2 
          ASLB                TIMES 4 
          ADDB V47            ADD 1 = TIMES 5 
          ASLB                TIMES 10 
          SUBA #'0            *MASK OFF ASCII FROM ACCA, PUSH 
          PSHS B              *RESULT ONTO THE STACK AND 
          ADDA ,S+            ADD lT TO ACCB 
          STA  V47            SAVE IN V47 
          BRA  LBD55          INTERPRET ANOTHER CHARACTER 
*                              
LBDB6     FCB  $9B,$3E,$BC,$1F,$FD * 99999999.9 
LBDBB     FCB  $9E,$6E,$6B,$27,$FD * 999999999 
LBDC0     FCB  $9E,$6E,$6B,$28,$00 * 1E + 09 
*                              
LBDC5     LDX  #LABE8-1       POINT X TO " IN " MESSAGE 
          BSR  LBDD6          COPY A STRING FROM (X) TO CONSOLE OUT 
          LDD  CURLIN         GET CURRENT BASIC LINE NUMBER TO ACCD 
* CONVERT VALUE IN ACCD INTO A DECIMAL NUMBER                      
* AND PRINT IT TO CONSOLE OUT                      
LBDCC     STD  FPA0           SAVE ACCD IN TOP HALF OF FPA0 
          LDB  #$90           REQ’D EXPONENT IF TOP HALF OF ACCD = INTEGER 
          COMA                SET CARRY FLAG - FORCE POSITIVE MANTISSA 
          JSR  LBC86          ZERO BOTTOM HALF AND SIGN OF FPA0, THEN 
*         SAVE EXPONENT AND NORMALIZE IT  
          BSR  LBDD9          CONVERT FP NUMBER TO ASCII STRING 
LBDD6     JMP  LB99C          COPY A STRING FROM (X) TO CONSOLE OUT 
                               
* CONVERT FP NUMBER TO ASCII STRING                      
LBDD9     LDU  #STRBUF+3      POINT U TO BUFFER WHICH WILL NOT CAUSE 
*                             THE STRING TO BE STORED IN STRING SPACE 
LBDDC     LDA  #SPACE         SPACE = DEFAULT SIGN FOR POSITIVE # 
          LDB  FP0SGN         GET SIGN OF FPA0 
          BPL  LBDE4          BRANCH IF POSITIVE 
          LDA  #'-            ASCII MINUS SIGN 
LBDE4     STA  ,U+            STORE SIGN OF NUMBER 
          STU  COEFPT         SAVE BUFFER POINTER 
          STA  FP0SGN         SAVE SIGN (IN ASCII) 
          LDA  #'0            ASCII ZERO IF EXPONENT = 0 
          LDB  FP0EXP         GET FPA0 EXPONENT 
          LBEQ LBEB8          BRANCH IF FPA0 = 0 
          CLRA                BASE 10 EXPONENT=0 FOR FP NUMBER > 1 
          CMPB #$80           CHECK EXPONENT 
          BHI  LBDFF          BRANCH IF FP NUMBER > 1 
* IF FPA0 < 1.0, MULTIPLY IT BY 1E+09 TO SPEED UP THE CONVERSION PROCESS                      
          LDX  #LBDC0         POINT X TO FP 1E+09 
          JSR  LBACA          MULTIPLY FPA0 BY (X) 
          LDA  #-9            BASE 10 EXPONENT = -9 
LBDFF     STA  V45            BASE 10 EXPONENT 
* PSEUDO - NORMALIZE THE FP NUMBER TO A VALUE IN THE RANGE                      
* OF 999,999,999 RO 99,999,999.9 - THIS IS THE LARGEST                      
* NUMBER RANGE IN WHICH ALL OF THE DIGITS ARE                      
* SIGNIFICANT WHICH CAN BE DISPLAYED WITHOUT USING                      
* SCIENTIFIC NOTATION                      
LBE01     LDX  #LBDBB         POINT X TO FP 999,999,999 
          JSR  LBCA0          COMPARE FPA0 TO 999,999,999 
          BGT  LBE18          BRANCH IF > 999,999,999 
LBE09     LDX  #LBDB6         POINT X TO FP 99,999,999.9 
          JSR  LBCA0          COMPARE FPA0 TO 99,999,999.9 
          BGT  LBE1F          BRANCH IF > 99,999,999.9 (IN RANGE) 
          JSR  LBB6A          MULTIPLY FPA0 BY 10 
          DEC  V45            SUBTRACT ONE FROM DECIMAL OFFSET 
          BRA  LBE09          PSEUDO - NORMALIZE SOME MORE 
LBE18     JSR  LBB82          DIVIDE FPA0 BY 10 
          INC  V45            ADD ONE TO BASE 10 EXPONENT 
          BRA  LBE01          PSEUDO - NORMALIZE SOME MORE 
LBE1F     JSR  LB9B4          ADD .5 TO FPA0 (ROUND OFF) 
          JSR  LBCC8          CONVERT FPA0 TO AN INTEGER 
          LDB  #1             DEFAULT DECIMAL POINT FLAG (FORCE IMMED DECIMAL PT) 
          LDA  V45            * GET BASE 10 EXPONENT AND ADD TEN TO IT 
          ADDA #9+1           * (NUMBER ‘NORMALIZED’ TO 9 PLACES & DECIMAL PT) 
          BMI  LBE36          BRANCH IF NUMBER < 1.0 
          CMPA #9+2           NINE PLACES MAY BE DISPLAYED WITHOUT 
*         USING SCIENTIFIC NOTATION  
          BCC  LBE36          BRANCH IF SCIENTIFIC NOTATION REQUIRED 
          DECA                * SUBTRACT 1 FROM MODIFIED BASE 10 EXPONENT CTR 
          TFR  A,B            * AND SAVE IT IN ACCB (DECiMAL POINT FLAG) 
          LDA  #2             FORCE EXPONENT = 0 - DON'T USE SCIENTIFIC NOTATION 
LBE36     DECA                * SUBTRACT TWO (WITHOUT AFFECTING CARRY) 
          DECA                * FROM BASE 10 EXPONENT 
          STA  V47            SAVE EXPONENT - ZERO EXPONENT = DO NOT DISPLAY 
*         IN   SCIENTIFIC NOTATION  
          STB  V45            DECIMAL POINT FLAG - NUMBER OF PLACES TO 
*         LEFT OF DECIMAL POINT  
          BGT  LBE4B          BRANCH IF >= 1 
          LDU  COEFPT         POINT U TO THE STRING BUFFER 
          LDA  #'.            * STORE A PERIOD 
          STA  ,U+            * IN THE BUFFER 
          TSTB CHECK DECIMAL POINT FLAG  
          BEQ  LBE4B          BRANCH IF NOTHING TO LEFT OF DECIMAL POINT 
          LDA  #'0            * STORE A ZERO 
          STA  ,U+            * IN THE BUFFER 
                               
* CONVERT FPA0 INTO A STRING OF ASCII DIGITS                      
LBE4B     LDX  #LBEC5         POINT X TO FP POWER OF 10 MANTISSA 
          LDB  #0+$80         INITIALIZE DIGIT COUNTER TO 0+$80 
* BIT 7 SET IS USED TO INDICATE THAT THE POWER OF 10 MANTISSA                      
* IS NEGATIVE. WHEN YOU 'ADD' A NEGATIVE MANTISSA, IT IS                      
* THE SAME AS SUBTRACTING A POSITIVE ONE AND BIT 7 OF ACCB IS HOW                      
* THE ROUTINE KNOWS THAT A 'SUBTRACTION' IS OCCURING.                      
LBE50     LDA  FPA0+3         * ADD MANTISSA LS 
          ADDA 3,X            * BYTE OF FPA0 
          STA  FPA0+3         * AND (X) 
          LDA  FPA0+2         = ADD MANTISSA 
          ADCA 2,X            = NUMBER 3 BYTE OF 
          STA  FPA0+2         = FPA0 AND (X) 
          LDA  FPA0+1         * ADD MANTISSA 
          ADCA 1,X            * NUMBER 2 BYTE OF 
          STA  FPA0+1         * FPA0 AND (X) 
          LDA  FPA0           = ADD MANTISSA 
          ADCA ,X             = MS BYTE OF 
          STA  FPA0           = FPA0 AND (X) 
          INCB                ADD ONE TO DIGIT COUNTER 
          RORB ROTATE CARRY INTO BIT 7  
          ROLB                *SET OVERFLOW FLAG AND BRANCH IF CARRY = 1 AND 
          BVC  LBE50          *POSITIVE MANTISSA OR CARRY = 0 AND NEG MANTISSA 
          BCC  LBE72          BRANCH IF NEGATIVE MANTISSA 
          SUBB #10+1          * TAKE THE 9’S COMPLEMENT IF 
          NEGB                * ADDING MANTISSA 
LBE72     ADDB #'0-1          ADD ASCII OFFSET TO DIGIT 
          LEAX 4,X            MOVE TO NEXT POWER OF 10 MANTISSA 
          TFR  B,A            SAVE DIGIT IN ACCA 
          ANDA #$7F           MASK OFF BIT 7 (ADD/SUBTRACT FLAG) 
          STA  ,U+            STORE DIGIT IN STRING BUFFER 
          DEC  V45            DECREMENT DECIMAL POINT FLAG 
          BNE  LBE84          BRANCH IF NOT TIME FOR DECIMAL POINT 
          LDA  #'.            * STORE DECIMAL POINT IN 
          STA  ,U+            * STRING BUFFER 
LBE84     COMB                TOGGLE BIT 7 (ADD/SUBTRACT FLAG) 
          ANDB #$80           MASK OFF ALL BUT ADD/SUBTRACT FLAG 
          CMPX #LBEC5+36      COMPARE X TO END OF MANTISSA TABLE 
          BNE  LBE50          BRANCH IF NOT AT END OF TABLE 
* BLANK TRAILING ZEROS AND STORE EXPONENT IF ANY                      
LBE8C     LDA  ,-U            GET THE LAST CHARACTER; MOVE POINTER BACK 
          CMPA #'0            WAS IT A ZERO? 
          BEQ  LBE8C          IGNORE TRAILING ZEROS IF SO 
          CMPA #'.            CHECK FOR DECIMAL POINT 
          BNE  LBE98          BRANCH IF NOT DECIMAL POINT 
          LEAU -1,U           STEP OVER THE DECIMAL POINT 
LBE98     LDA  #'+            ASCII PLUS SIGN 
          LDB  V47            GET SCIENTIFIC NOTATION EXPONENT 
          BEQ  LBEBA          BRANCH IF NOT SCIENTIFIC NOTATION 
          BPL  LBEA3          BRANCH IF POSITIVE EXPONENT 
          LDA  #'-            ASCII MINUS SIGN 
          NEGB                NEGATE EXPONENT IF NEGATIVE 
LBEA3     STA  2,U            STORE EXPONENT SIGN IN STRING 
          LDA  #'E            * GET ASCII ‘E’ (SCIENTIFIC NOTATION 
          STA  1,U            * FLAG) AND SAVE IT IN THE STRING 
          LDA  #'0-1          INITIALIZE ACCA TO ASCII ZERO 
                               
                               
LBEAB     INCA                ADD ONE TO 10’S DIGIT OF EXPONENT 
          SUBB #10            SUBTRACT 10 FROM ACCB 
          BCC  LBEAB          ADD 1 TO 10’S DIGIT IF NO CARRY 
          ADDB #'9+1          CONVERT UNITS DIGIT TO ASCII 
          STD  3,U            SAVE EXPONENT IN STRING 
          CLR  5,U            CLEAR LAST BYTE (TERMINATOR) 
          BRA  LBEBC          GO RESET POINTER 
LBEB8     STA  ,U             STORE LAST CHARACTER 
LBEBA     CLR  1,U            CLEAR LAST BYTE (TERMINATOR - REQUIRED BY 
*         PRINT SUBROUTINES)    
LBEBC     LDX  #STRBUF+3      RESET POINTER TO START OF BUFFER 
          RTS                  
*                              
LBEC0     FCB  $80,$00,$00,$00,$00 FLOATING POINT .5 
*                              
*** TABLE OF UNNORMALIZED POWERS OF 10                      
LBEC5     FCB  $FA,$0A,$1F,$00 -100000000 
LBEC9     FCB  $00,$98,$96,$80 10000000 
LBECD     FCB  $FF,$F0,$BD,$C0 -1000000 
LBED1     FCB  $00,$01,$86,$A0 100000 
LBED5     FCB  $FF,$FF,$D8,$F0 -10000 
LBED9     FCB  $00,$00,$03,$E8 1000 
LBEDD     FCB  $FF,$FF,$FF,$9C -100 
LBEE1     FCB  $00,$00,$00,$0A 10 
LBEE5     FCB  $FF,$FF,$FF,$FF -1 
*                              
*                              
LBEE9     LDA  FP0EXP         GET EXPONENT OF FPA0 
          BEQ  LBEEF          BRANCH IF FPA0 = 0 
          COM  FP0SGN         TOGGLE MANTISSA SIGN OF FPA0 
LBEEF     RTS                  
* EXPAND A POLYNOMIAL OF THE FORM                      
* AQ+BQ**3+CQ**5+DQ**7.... WHERE Q = FPA0                      
* AND THE X REGISTER POINTS TO A TABLE OF                      
* COEFFICIENTS A,B,C,D....                      
LBEF0     STX  COEFPT         SAVE COEFFICIENT TABLE POINTER 
          JSR  LBC2F          MOVE FPA0 TO FPA3 
          BSR  LBEFC          MULTIPLY FPA3 BY FPA0 
          BSR  LBF01          EXPAND POLYNOMIAL 
          LDX  #V40           POINT X TO FPA3 
LBEFC     JMP  LBACA          MULTIPLY (X) BY FPA0 
                               
* CALCULATE THE VALUE OF AN EXPANDED POLYNOMIAL                      
* EXPRESSION. ENTER WITH (X) POINTING TO A TABLE                      
* OF COEFFICIENTS, THE FIRST BYTE OF WHICH IS THE                      
* NUMBER OF (COEFFICIENTS-1) FOLLOWED BY THAT NUMBER                      
* OF PACKED FLOATING POINT NUMBERS. THE                      
* POLYNOMIAL IS EVALUATED AS FOLLOWS: VALUE =                      
* (((FPA0*Y0+Y1)*FPA0+Y2)*FPA0…YN)                      
LBEFF     STX  COEFPT         SAVE COEFFICIENT TABLE POINTER 
LBF01     JSR  LBC2A          MOVE FPA0 TO FPA4 
          LDX  COEFPT         GET THE COEFFICIENT POINTER 
          LDB  ,X+            GET THE TOP OF COEFFICIENT TABLE TO 
          STB  COEFCT         * USE AND STORE IT IN TEMPORARY COUNTER 
          STX  COEFPT         SAVE NEW COEFFICIENT POINTER 
LBF0C     BSR  LBEFC          MULTIPLY (X) BY FPA0 
          LDX  COEFPT         *GET COEFFICIENT POINTER 
          LEAX 5,X            *MOVE TO NEXT FP NUMBER 
          STX  COEFPT         *SAVE NEW COEFFICIENT POINTER 
          JSR  LB9C2          ADD (X) AND FPA0 
          LDX  #V45           POINT (X) TO FPA4 
          DEC  COEFCT         DECREMENT TEMP COUNTER 
          BNE  LBF0C          BRANCH IF MORE COEFFICIENTS LEFT 
          RTS                  
                               
* RND                          
RND       JSR  LBC6D          TEST FPA0 
          BMI  LBF45          BRANCH IF FPA0 = NEGATIVE 
          BEQ  LBF3B          BRANCH IF FPA0 = 0 
          BSR  LBF38          CONVERT FPA0 TO AN INTEGER 
          JSR  LBC2F          PACK FPA0 TO FPA3 
          BSR  LBF3B          GET A RANDOM NUMBER: FPA0 < 1.0 
          LDX  #V40           POINT (X) TO FPA3 
          BSR  LBEFC          MULTIPLY (X) BY FPA0 
          LDX  #LBAC5         POINT (X) TO FP VALUE OF 1.0 
          JSR  LB9C2          ADD 1.0 TO FPA0 
LBF38     JMP  INT            CONVERT FPA0 TO AN INTEGER 
* CALCULATE A RANDOM NUMBER IN THE RANGE 0.0 < X <= 1.0                      
LBF3B     LDX  RVSEED+1       * MOVE VARIABLE 
          STX  FPA0           * RANDOM NUMBER 
          LDX  RVSEED+3       * SEED TO 
          STX  FPA0+2         * FPA0 
LBF45     LDX  RSEED          = MOVE FIXED 
          STX  FPA1           = RANDOM NUMBER 
          LDX  RSEED+2        = SEED TO 
          STX  FPA1+2         = MANTISSA OF FPA0 
          JSR  LBAD0          MULTIPLY FPA0 X FPA1 
          LDD  VAD            GET THE TWO LOWEST ORDER PRODUCT BYTES 
          ADDD #$658B         ADD A CONSTANT 
          STD  RVSEED+3       SAVE NEW LOW ORDER VARIABLE RANDOM # SEED 
          STD  FPA0+2         SAVE NEW LOW ORDER BYTES OF FPA0 MANTISSA 
          LDD  VAB            GET 2 MORE LOW ORDER PRODUCT BYTES 
          ADCB #$B0           ADD A CONSTANT 
          ADCA #5             ADD A CONSTANT 
          STD  RVSEED+1       SAVE NEW HIGH ORDER VARIABLE RANDOM # SEED 
          STD  FPA0           SAVE NEW HIGH ORDER FPA0 MANTISSA 
          CLR  FP0SGN         FORCE FPA0 MANTISSA = POSITIVE 
          LDA  #$80           * SET FPA0 BIASED EXPONENT 
          STA  FP0EXP         * TO 0 1 < FPA0 < 0 
          LDA  FPA2+2         GET A BYTE FROM FPA2 (MORE RANDOMNESS) 
          STA  FPSBYT         SAVE AS SUB BYTE 
          JMP  LBA1C          NORMALIZE FPA0 
*                              
RSEED     FDB  $40E6          *CONSTANT RANDOM NUMBER GENERATOR SEED 
          FDB  $4DAB          * 
                               
* SIN                          
* THE SIN FUNCTION REQUIRES AN ARGUMENT IN RADIANS AND WILL REPEAT ITSELF EVERY                      
* 2*PI RADIANS. THE ARGUMENT IS DIVIDED BY 2*PI AND ONLY THE FRACTIONAL PART IS                      
* RETAINED. SINCE THE ARGUMENT WAS DIVIDED BY 2*P1, THE COEFFICIENTS MUST BE                      
* MULTIPLIED BY THE APPROPRIATE POWER OF 2*PI.                      
                               
* SIN IS EVALUATED USING THE TRIGONOMETRIC IDENTITIES BELOW:                      
* SIN(X)=SIN(PI-X) & -SIN(PI/2-X)=SIN((3*PI)/2+X)                      
SIN       JSR  LBC5F          COPY FPA0 TO FPA1 
          LDX  #LBFBD         POINT (X) TO 2*PI 
          LDB  FP1SGN         *GET MANTISSA SIGN OF FPA1 
          JSR  LBB89          *AND DIVIDE FPA0 BY 2*PI 
          JSR  LBC5F          COPY FPA0 TO FPA1 
          BSR  LBF38          CONVERT FPA0 TO AN INTEGER 
          CLR  RESSGN         SET RESULT SIGN = POSITIVE 
          LDA  FP1EXP         *GET EXPONENT OF FPA1 
          LDB  FP0EXP         *GET EXPONENT OF FPA0 
          JSR  LB9BC          *SUBTRACT FPA0 FROM FPA1 
* NOW FPA0 CONTAINS ONLY THE FRACTIONAL PART OF ARGUMENT/2*PI                      
          LDX  #LBFC2         POINT X TO FP (.25) 
          JSR  LB9B9          SUBTRACT FPA0 FROM .25 (PI/2) 
          LDA  FP0SGN         GET MANTISSA SIGN OF FPA0 
          PSHS A              SAVE IT ON STACK 
          BPL  LBFA6          BRANCH IF MANTISSA POSITIVE 
          JSR  LB9B4          ADD .5 (PI) TO FPA0 
          LDA  FP0SGN         GET SIGN OF FPA0 
          BMI  LBFA9          BRANCH IF NEGATIVE 
          COM  RELFLG         COM IF +(3*PI)/2 >= ARGUMENT >+ PI/2 (QUADRANT FLAG) 
LBFA6     JSR  LBEE9          TOGGLE MANTISSA SIGN OF FPA0 
LBFA9     LDX  #LBFC2         POINT X TO FP (.25) 
          JSR  LB9C2          ADD .25 (PI/2) TO FPA0 
          PULS A              GET OLD MANTISSA SIGN 
          TSTA                * BRANCH IF OLD 
          BPL  LBFB7          * SIGN WAS POSITIVE 
          JSR  LBEE9          TOGGLE MANTISSA SIGN 
LBFB7     LDX  #LBFC7         POINT X TO TABLE OF COEFFICIENTS 
          JMP  LBEF0          GO CALCULATE POLYNOMIAL VALUE 
                               
LBFBD     FCB  $83,$49,$0F,$DA,$A2 6.28318531 (2*PI) 
LBFC2     FCB  $7F,$00,$00,$00,$00 .25 
                               
                               
LBFC7     FCB  6-1            SIX COEFFICIENTS 
LBFC8     FCB  $84,$E6,$1A,$2D,$1B * -((2*PI)**11)/11! 
LBFCD     FCB  $86,$28,$07,$FB,$F8 * ((2*PI)**9)/9! 
LBFD2     FCB  $87,$99,$68,$89,$01 * -((2*PI)**7)/7! 
LBFD7     FCB  $87,$23,$35,$DF,$E1 * ((2*PI)**5)/5! 
LBFDC     FCB  $86,$A5,$5D,$E7,$28 * -((2*PI)**3)/3! 
LBFE1     FCB  $83,$49,$0F,$DA,$A2 * 
                               
          FCB  $A1,$54,$46,$8F,$13 UNUSED GARBAGE BYTES 
          FCB  $8F,$52,$43,$89,$CD UNUSED GARBAGE BYTES 
* EXTENDED BASIC                      
                               
* COS                          
* THE VALUE OF COS(X) IS DETERMINED BY THE TRIG IDENTITY COS(X)=SIN((PI/2)+X)                      
COS       LDX  #L83AB         POINT X TO FP CONSTANT (P1/2) 
          JSR  LB9C2          ADD FPA0 TO (X) 
L837E     JMP  SIN            JUMP TO SIN ROUTINE 
                               
* TAN                          
* THE VALUE OF TAN(X) IS DETERMINED BY THE TRIG IDENTITY TAN(X)=SIN(X)/COS(X)                      
TAN       JSR  LBC2F          PACK FPA0 AND MOVE IT TO FPA3 
          CLR  RELFLG         RESET QUADRANT FLAG 
          BSR  L837E          CALCULATE SIN OF ARGUMENT 
          LDX  #V4A           POINT X TO FPA5 
          JSR  LBC35          PACK FPA0 AND MOVE IT TO FPA5 
          LDX  #V40           POINT X TO FPA3 
          JSR  LBC14          MOVE FPA3 TO FPA0 
          CLR  FP0SGN         FORCE FPA0 MANTISSA TO BE POSITIVE 
          LDA  RELFLG         GET THE QUADRANT FLAG - COS NEGATIVE IN QUADS 2,3 
          BSR  L83A6          CALCULATE VALUE OF COS(FPA0) 
          TST  FP0EXP         CHECK EXPONENT OF FPA0 
          LBEQ LBA92          ‘OV’ ERROR IF COS(X)=0 
          LDX  #V4A           POINT X TO FPA5 
L83A3     JMP  LBB8F          DIVIDE (X) BY FPA0 - SIN(X)/COS(X) 
L83A6     PSHS A              SAVE SIGN FLAG ON STACK 
          JMP  LBFA6          EXPAND POLYNOMIAL 
                               
L83AB     FCB  $81,$49,$0F,$DA,$A2 1.57079633 (PI/2) 
                               
* ATN                          
* A 12 TERM TAYLOR SERIES IS USED TO EVALUATE THE                      
* ARCTAN EXPRESSION. TWO  DIFFERENT FORMULI ARE USED  
* TO EVALUATE THE EXPRESSION DEPENDING UPON                      
* WHETHER OR NOT THE ARGUMENT SQUARED IS > OR < 1.0                      
                               
* IF X**2<1 THEN ATN=X-(X**3)/3+(X**5)/5-(X**7)/7. . .                      
* IF X**2>=1 THEN ATN=PI/2-(1/X-1/((X**3)*3)+(1/((X**5)*5)-. . .)                      
                               
ATN       LDA  FP0SGN         * GET THE SIGN OF THE MANTISSA AND 
          PSHS A              * SAVE IT ON THE STACK 
          BPL  L83B8          BRANCH IF POSITIVE MANTISSA 
          BSR  L83DC          CHANGE SIGN OF FPA0 
L83B8     LDA  FP0EXP         * GET EXPONENT OF FPA0 AND 
          PSHS A              * SAVE IT ON THE STACK 
          CMPA #$81           IS FPAO < 1.0? 
          BLO  L83C5          YES 
          LDX  #LBAC5         POINT X TO FP CONSTANT 1.0 
          BSR  L83A3          GET RECIPROCAL OF FPA0 
L83C5     LDX  #L83E0         POINT (X) TO TAYLOR SERIES COEFFICIENTS 
          JSR  LBEF0          EXPAND POLYNOMIAL 
          PULS A              GET EXPONENT OF ARGUMENT 
          CMPA #$81           WAS ARGUMENT < 1.0? 
          BLO  L83D7          YES 
          LDX  #L83AB         POINT (X) TO FP NUMBER (PI/2) 
          JSR  LB9B9          SUBTRACT FPA0 FROM (PI/2) 
L83D7     PULS A              * GET SIGN OF INITIAL ARGUMENT MANTISSA 
          TSTA                * AND SET FLAGS ACCORDING TO IT 
          BPL  L83DF          RETURN IF ARGUMENT WAS POSITIVE 
L83DC     JMP  LBEE9          CHANGE MANTISSA SIGN OF FPA0 
L83DF     RTS                  
*                              
* TCHEBYSHEV MODIFIED TAYLOR SERIES COEFFICIENTS FOR ARCTANGENT                      
L83E0     FCB  $0B            TWELVE COEFFICIENTS 
L83E1     FCB  $76,$B3,$83,$BD,$D3 -6.84793912E-04 1/23 
L83E6     FCB  $79,$1E,$F4,$A6,$F5 +4.85094216E-03 1/21 
L83EB     FCB  $7B,$83,$FC,$B0,$10 -0.0161117018 
L83F0     FCB  $7C,$0C,$1F,$67,$CA 0.0342096381 
L83F5     FCB  $7C,$DE,$53,$CB,$C1 -0.0542791328 
L83FA     FCB  $7D,$14,$64,$70,$4C 0.0724571965 
L83FF     FCB  $7D,$B7,$EA,$51,$7A -0.0898023954 
L8404     FCB  $7D,$63,$30,$88,$7E 0.110932413 
L8409     FCB  $7E,$92,$44,$99,$3A -0.142839808 
L840E     FCB  $7E,$4C,$CC,$91,$C7 0.199999121 
L8413     FCB  $7F,$AA,$AA,$AA,$13 -0.333333316 
L8418     FCB  $81,$00,$00,$00,$00 1 
*                              
*** TCHEBYSHEV MODIFIED TAYLOR SERIES COEFFICIENTS FOR LN(X)                      
*                              
L841D     FCB  3              FOUR COEFFICIENTS 
L841E     FCB  $7F,$5E,$56,$CB,$79 0.434255942 
L8423     FCB  $80,$13,$9B,$0B,$64 0.576584541 
L8428     FCB  $80,$76,$38,$93,$16 0.961800759 
L842D     FCB  $82,$38,$AA,$3B,$20 2.88539007 
                               
L8432     FCB  $80,$35,$04,$F3,$34 1/SQR(2) 
                               
L8437     FCB  $81,$35,$04,$F3,$34 SQR(2) 
                               
L843C     FCB  $80,$80,$00,$00,$00 -0.5 
                               
L8441     FCB  $80,$31,$72,$17,$F8 LN(2) 
*                              
* LOG - NATURAL LOGARITHM (LN)                      
                               
* THE NATURAL OR NAPERIAN LOGARITHM IS CALCULATED USING                      
* MATHEMATICAL IDENTITIES. FPA0 IS OF THE FORM FPA0=A*(2**B) (SCIENTIFIC                      
* NOTATION). THEREFORE, THE LOG ROUTINE DETERMINES THE VALUE OF                      
* LN(A*(2**B)). A SERIES OF MATHEMATICAL IDENTITIES WILL EXPAND THIS                      
* TERM: LN(A*(2**B))=(-1/2+(1/LN(2))*(LN(A*SQR(2)))+B)*LN(2). ALL OF                      
* THE TERMS OF THE LATTER EXPRESSION ARE CONSTANTS EXCEPT FOR THE                      
* LN(A*SQR(2)) TERM WHICH IS EVALUATED USING THE TAYLOR SERIES EXPANSION                      
LOG       JSR  LBC6D          CHECK STATUS OF FPA0 
          LBLE LB44A          ‘FC’ ERROR IF NEGATIVE OR ZERO 
          LDX  #L8432         POINT (X) TO FP NUMBER (1/SQR(2)) 
          LDA  FP0EXP         *GET EXPONENT OF ARGUMENT 
          SUBA #$80           *SUBTRACT OFF THE BIAS AND 
          PSHS A              *SAVE IT ON THE STACK 
          LDA  #$80            
          STA  FP0EXP          
          JSR  LB9C2          ADD FPA0 TO (X) 
          LDX  #L8437         POINT X TO SQR(2) 
          JSR  LBB8F          DIVIDE SQR(2) BY FPA0 
          LDX  #LBAC5         POINT X TO FP VALUE OF 1.00 
          JSR  LB9B9          SUBTRACT FPA0 FROM (X) 
*         NOW  FPA0 = (1-SQR(2)*X)/(1+SQR(2)*X) WHERE X IS ARGUMENT  
          LDX  #L841D         POINT X TO TABLE OF COEFFICIENTS 
          JSR  LBEF0          EXPAND POLYNOMIAL 
          LDX  #L843C         POINT X TO FP VALUE OF (-.5) 
          JSR  LB9C2          ADD FPA0 TO X 
          PULS B              GET EXPONENT OF ARGUMENT BACK (WITHOUT BIAS) 
          JSR  LBD99          ADD ACCB TO FPA0 
          LDX  #L8441         POINT X TO LN(2) 
          JMP  LBACA          MULTIPLY FPA0 * LN(2) 
                               
* SQR                          
SQR       JSR  LBC5F          MOVE FPA0 TO FPA1 
          LDX  #LBEC0         POINT (X) TO FP NUMBER (.5) 
          JSR  LBC14          COPY A PACKED NUMBER FROM (X) TO FPA0 
                               
* ARITHMETIC OPERATOR FOR EXPONENTIATION JUMPS                      
* HERE. THE FORMULA USED TO EVALUATE EXPONENTIATION                      
* IS A**X=E**(X LN A) = E**(FPA0*LN(FPA1)), E=2.7182818                      
L8489     BEQ  EXP            DO A NATURAL EXPONENTIATION IF EXPONENT = 0 
          TSTA                *CHECK VALUE BEING EXPONENTIATED 
          BNE  L8491          *AND BRANCH IF IT IS <> 0 
          JMP  LBA3A          FPA0=0 IF RAISING ZERO TO A POWER 
L8491     LDX  #V4A           * PACK FPA0 AND SAVE 
          JSR  LBC35          * IT IN FPA5 (ARGUMENT’S EXPONENT) 
          CLRB                ACCB=DEFAULT RESULT SIGN FLAG; 0=POSITIVE 
          LDA  FP1SGN         *CHECK THE SIGN OF ARGUMENT 
          BPL  L84AC          *BRANCH IF POSITIVE 
          JSR  INT            CONVERT EXPONENT INTO AN INTEGER 
          LDX  #V4A           POINT X TO FPA5 (ORIGINAL EXPONENT) 
          LDA  FP1SGN         GET MANTISSA SIGN OF FPA1 (ARGUMENT) 
          JSR  LBCA0          *COMPARE FPA0 TO (X) AND 
          BNE  L84AC          *BRANCH IF NOT EQUAL 
          COMA                TOGGLE FPA1 MANTISSA SIGN - FORCE POSITIVE 
          LDB  CHARAC         GET LS BYTE OF INTEGER VALUE OF EXPONENT (RESULT SIGN FLAG) 
L84AC     JSR  LBC4C          COPY FPA1 TO FPA0; ACCA = MANTISSA SIGN 
          PSHS B              PUT RESULT SIGN FLAG ON THE STACK 
          JSR  LOG             
          LDX  #V4A           POINT (X) TO FPA5 
          JSR  LBACA          MULTIPLY FPA0 BY FPA5 
          BSR  EXP            CALCULATE E**(FPA0) 
          PULS A              * GET RESULT SIGN FLAG FROM THE STACK 
          RORA * AND BRANCH IF NEGATIVE  
          LBCS LBEE9          CHANGE SIGN OF FPA0 MANTISSA 
          RTS                  
                               
* CORRECTION FACTOR FOR EXPONENTIAL FUNCTION                      
L84C4     FCB  $81,$38,$AA,$3B,$29 1.44269504 ( CF ) 
*                              
* TCHEBYSHEV MODIFIED TAYLOR SERIES COEFFICIENTS FOR E**X                      
*                              
L84C9     FCB  7              EIGHT COEFFICIENTS 
L84CA     FCB  $71,$34,$58,$3E,$56 2.14987637E-05: 1/(7!*(CF**7)) 
L84CF     FCB  $74,$16,$7E,$B3,$1B 1.4352314E-04 : 1/(6!*(CF**6)) 
L84D4     FCB  $77,$2F,$EE,$E3,$85 1.34226348E-03: 1/(5!*(CF**5)) 
L84D9     FCB  $7A,$1D,$84,$1C,$2A 9.61401701E-03: 1/(4!*(CF**4)) 
L84DE     FCB  $7C,$63,$59,$58,$0A 0.0555051269 
L84E3     FCB  $7E,$75,$FD,$E7,$C6 0.240226385 
L84E8     FCB  $80,$31,$72,$18,$10 0.693147186 
L84ED     FCB  $81,$00,$00,$00,$00 1 
*                              
* EXP ( E**X)                      
* THE EXPONENTIAL FUNCTION IS EVALUATED BY FIRST MULTIPLYING THE                      
* ARGUMENT BY A CORRECTION FACTOR (CF). AFTER THIS IS DONE, AN                      
* ARGUMENT >= 127 WILL YIELD A ZERO RESULT (NO UNDERFLOW) FOR A                      
* NEGATIVE ARGUMENT OR AN 'OV' (OVERFLOW) ERROR FOR A POSITIVE                      
* ARGUMENT. THE POLYNOMIAL COEFFICIENTS ARE MODIFIED TO REFLECT                      
* THE CF MULTIPLICATION AT THE START OF THE EVALUATION PROCESS.                      
                               
EXP       LDX  #L84C4         POINT X TO THE CORRECTION FACTOR 
          JSR  LBACA          MULTIPLY FPA0 BY (X) 
          JSR  LBC2F          PACK FPA0 AND STORE IT IN FPA3 
          LDA  FP0EXP         *GET EXPONENT OF FPA0 AND 
          CMPA #$88           *COMPARE TO THE MAXIMUM VALUE 
          BLO  L8504          BRANCH IF FPA0 < 128 
L8501     JMP  LBB5C          SET FPA0 = 0 OR ‘OV’ ERROR 
L8504     JSR  INT            CONVERT FPA0 TO INTEGER 
          LDA  CHARAC         GET LS BYTE OF INTEGER 
          ADDA #$81           * WAS THE ARGUMENT =127, IF SO 
          BEQ  L8501          * THEN ‘OV’ ERROR; THIS WILL ALSO ADD THE $80 BIAS 
*              * REQUIRED WHEN THE NEW EXPONENT IS CALCULATED BELOW  
          DECA                DECREMENT ONE FROM THE EXPONENT, BECAUSE $81, NOT $80 WAS USED ABOVE 
          PSHS A              SAVE EXPONENT OF INTEGER PORTION ON STACK 
          LDX  #V40           POINT (X) TO FPA3 
          JSR  LB9B9          SUBTRACT FPA0 FROM (X) - GET FRACTIONAL PART OF ARGUMENT 
          LDX  #L84C9         POINT X TO COEFFICIENTS 
          JSR  LBEFF          EVALUATE POLYNOMIAL FOR FRACTIONAL PART 
          CLR  RESSGN         FORCE THE MANTISSA TO BE POSITIVE 
          PULS A              GET INTEGER EXPONENT FROM STACK 
          JSR  LBB48          * CALCULATE EXPONENT OF NEW FPA0 BY ADDING THE EXPONENTS OF THE 
*              * INTEGER AND FRACTIONAL PARTS  
          RTS                  
                               
* FIX                          
FIX       JSR  LBC6D          CHECK STATUS OF FPA0 
          BMI  L852C          BRANCH IF FPA0 = NEGATIVE 
L8529     JMP  INT            CONVERT FPA0 TO INTEGER 
L852C     COM  FP0SGN         TOGGLE SIGN OF FPA0 MANTISSA 
          BSR  L8529          CONVERT FPA0 TO INTEGER 
          JMP  LBEE9          TOGGLE SIGN OF FPA0 
                               
* EDIT                         
EDIT      JSR  L89AE          GET LINE NUMBER FROM BASIC 
          LEAS $02,S PURGE RETURN ADDRESS OFF OF THE STACK  
L8538     LDA  #$01           ‘LIST’ FLAG 
          STA  VD8            SET FLAG TO LIST LINE 
          JSR  LAD01          GO FIND THE LINE NUMBER IN PROGRAM 
          LBCS LAED2 ERROR #7 ‘UNDEFINED LINE #'  
          JSR  LB7C2          GO UNCRUNCH LINE INTO BUFFER AT LINBUF+1 
          TFR  Y,D            PUT ABSOLUTE ADDRESS OF END OF LINE TO ACCD 
          SUBD #LINBUF+2 SUBTRACT OUT THE START OF LINE  
          STB  VD7            SAVE LENGTH OF LINE 
L854D     LDD  BINVAL         GET THE HEX VALUE OF LINE NUMBER 
          JSR  LBDCC          LIST THE LINE NUMBER ON THE SCREEN 
          JSR  LB9AC          PRINT A SPACE 
          LDX  #LINBUF+1      POINT X TO BUFFER 
          LDB  VD8            * CHECK TO SEE IF LINE IS TO BE 
          BNE  L8581          * LISTED TO SCREEN - BRANCH IF IT IS 
L855C     CLRB                RESET DIGIT ACCUMULATOR - DEFAULT VALUE 
L855D     JSR  L8687          GET KEY STROKE 
          JSR  L90AA          SET CARRY IF NOT NUMERIC 
          BLO  L8570          BRANCH IF NOT NUMERIC 
          SUBA #'0' MASK OFF ASCII  
          PSHS A SAVE IT ON STACK  
          LDA  #10            NUMBER BEING CONVERTED IS BASE 10 
          MUL  MULTIPLY ACCUMULATED VALUE BY BASE (10)  
          ADDB ,S+ ADD DIGIT TO ACCUMULATED VALUE  
          BRA  L855D          CHECK FOR ANOTHER DIGIT 
L8570     SUBB #$01 * REPEAT PARAMETER IN ACCB; IF IT  
          ADCB #$01 *IS 0, THEN MAKE IT ‘1’  
          CMPA #'A' ABORT?          
          BNE  L857D          NO 
          JSR  LB958          PRINT CARRIAGE RETURN TO SCREEN 
          BRA  L8538          RESTART EDIT PROCESS - CANCEL ALL CHANGES 
L857D     CMPA #'L' LIST?           
          BNE  L858C          NO 
L8581     BSR  L85B4          LIST THE LINE 
          CLR  VD8            RESET THE LIST FLAG TO ‘NO LIST’ 
          JSR  LB958          PRINT CARRIAGE RETURN 
          BRA  L854D          GO INTERPRET ANOTHER EDIT COMMAND 
L858A     LEAS $02,S PURGE RETURN ADDRESS OFF OF THE STACK  
L858C     CMPA #CR ENTER KEY?      
          BNE  L859D          NO 
          BSR  L85B4          ECHO THE LINE TO THE SCREEN 
L8592     JSR  LB958          PRINT CARRIAGE RETURN 
          LDX  #LINBUF+1      * RESET BASIC’S INPUT POINTER 
          STX  CHARAD         * TO THE LINE INPUT BUFFER 
          JMP  LACA8          GO PUT LINE BACK IN PROGRAM 
L859D     CMPA #'E' EXIT?           
          BEQ  L8592          YES - SAME AS ENTER EXCEPT NO ECHO 
          CMPA #'Q' QUIT?           
          BNE  L85AB          NO 
          JSR  LB958          PRINT CARRIAGE RETURN TO SCREEN 
          JMP  LAC73          GO TO COMMAND LEVEL - MAKE NO CHANGES 
L85AB     BSR  L85AF          INTERPRET THE REMAINING COMMANDS AS SUBROUTINES 
          BRA  L855C          GO INTERPRET ANOTHER EDIT COMMAND 
L85AF     CMPA #SPACE SPACE BAR?      
          BNE  L85C3          NO 
L85B3     FCB  SKP2           SKIP TWO BYTES 
* DISPLAY THE NEXT ACCB BYTES OF THE LINE IN THE BUFFER TO THE SCREEN                      
*                              
L85B4     LDB  #LBUFMX-1      250 BYTES MAX IN BUFFER 
L85B6     LDA  ,X             GET A CHARACTER FROM BUFFER 
          BEQ  L85C2          EXIT IF IT’S A 0 
          JSR  PUTCHR         SEND CHAR TO CONSOLE OUT 
          LEAX $01,X MOVE POINTER UP ONE  
          DECB DECREMENT CHARACTER COUNTER  
          BNE  L85B6          LOOP IF NOT DONE 
L85C2     RTS                  
L85C3     CMPA #'D' DELETE?         
          BNE  L860F          NO 
L85C7     TST  ,X             * CHECK FOR END OF LINE 
          BEQ  L85C2          * AND BRANCH IF SO 
          BSR  L85D1          REMOVE A CHARACTER 
          DECB DECREMENT REPEAT PARAMETER  
          BNE  L85C7          BRANCH IF NOT DONE 
          RTS                  
* REMOVE ONE CHARACTER FROM BUFFER                      
L85D1     DEC  VD7            DECREMENT LENGTH OF BUFFER 
          LEAY $-01,X POINT Y TO ONE BEFORE CURRENT BUFFER POINTER  
L85D5     LEAY $01,Y INCREMENT TEMPORARY BUFFER POINTER  
          LDA  $01,Y          GET NEXT CHARACTER 
          STA  ,Y             PUT IT IN CURRENT POSITION 
          BNE  L85D5          BRANCH IF NOT END OF LINE 
          RTS                  
L85DE     CMPA #'I' INSERT?         
          BEQ  L85F5          YES 
          CMPA #'X' EXTEND?         
          BEQ  L85F3          YES 
          CMPA #'H' HACK?           
          BNE  L8646          NO 
          CLR  ,X             TURN CURRENT BUFFER POINTER INTO END OF LINE FLAG 
          TFR  X,D            PUT CURRENT BUFFER POINTER IN ACCD 
          SUBD #LINBUF+2 SUBTRACT INITIAL POINTER POSITION  
          STB  VD7            SAVE NEW BUFFER LENGTH 
L85F3     BSR  L85B4          DISPLAY THE LINE ON THE SCREEN 
L85F5     JSR  L8687          GET A KEYSTROKE 
          CMPA #CR ENTER KEY?      
          BEQ  L858A          YES - INTERPRET ANOTHER COMMAND - PRINT LINE 
          CMPA #ESC ESCAPE?         
          BEQ  L8625          YES - RETURN TO COMMAND LEVEL - DON’T PRINT LINE 
          CMPA #BS BACK SPACE?     
          BNE  L8626          NO 
          CMPX #LINBUF+1 COMPARE POINTER TO START OF BUFFER  
          BEQ  L85F5          DO NOT ALLOW BS IF AT START 
          BSR  L8650          MOVE POINTER BACK ONE, BS TO SCREEN 
          BSR  L85D1          REMOVE ONE CHARACTER FROM BUFFER 
          BRA  L85F5          GET INSERT SUB COMMAND 
L860F     CMPA #'C' CHANGE?         
          BNE  L85DE          NO 
L8613     TST  ,X             CHECK CURRENT BUFFER CHARACTER 
          BEQ  L8625          BRANCH IF END OF LINE 
          JSR  L8687          GET A KEYSTROKE 
          BLO  L861E          BRANCH IF LEGITIMATE KEY 
          BRA  L8613          TRY AGAIN IF ILLEGAL KEY 
L861E     STA  ,X+            INSERT NEW CHARACTER INTO BUFFER 
          BSR  L8659          SEND NEW CHARACTER TO SCREEN 
          DECB DECREMENT REPEAT PARAMETER  
          BNE  L8613          BRANCH IF NOT DONE 
L8625     RTS                  
L8626     LDB  VD7            GET LENGTH OF LINE 
          CMPB #LBUFMX-1 COMPARE TO MAXIMUM LENGTH  
          BNE  L862E          BRANCH IF NOT AT MAXIMUM 
          BRA  L85F5          IGNORE INPUT IF LINE AT MAXIMUM LENGTH 
L862E     PSHS X SAVE CURRENT BUFFER POINTER  
L8630     TST  ,X+            * SCAN THE LINE UNTIL END OF 
          BNE  L8630          * LINE (0) IS FOUND 
L8634     LDB  ,-X            DECR TEMP LINE POINTER AND GET A CHARACTER 
          STB  $01,X          PUT CHARACTER BACK DOWN ONE SPOT 
          CMPX ,S HAVE WE REACHED STARTING POINT?  
          BNE  L8634          NO - KEEP GOING 
          LEAS $02,S PURGE BUFFER POINTER FROM STACK  
          STA  ,X+            INSERT NEW CHARACTER INTO THE LINE 
          BSR  L8659          SEND A CHARACTER TO CONSOLE OUT 
          INC  VD7            ADD ONE TO BUFFER LENGTH 
          BRA  L85F5          GET INSERT SUB COMMAND 
L8646     CMPA #BS BACKSPACE?      
          BNE  L865C          NO 
L864A     BSR  L8650          MOVE POINTER BACK 1, SEND BS TO SCREEN 
          DECB DECREMENT REPEAT PARAMETER  
          BNE  L864A          LOOP UNTIL DONE 
          RTS                  
L8650     CMPX #LINBUF+1 COMPARE POINTER TO START OF BUFFER  
          BEQ  L8625          DO NOT ALLOW BS IF AT START 
          LEAX $-01,X MOVE POINTER BACK ONE  
          LDA  #BS            BACK SPACE 
L8659     JMP  PUTCHR         SEND TO CONSOLE OUT 
L865C     CMPA #'K' KILL?           
          BEQ  L8665          YES 
          SUBA #'S' SEARCH?         
          BEQ  L8665          YES 
          RTS                  
L8665     PSHS A SAVE KILL/SEARCH FLAG ON STACK  
          BSR  L8687          * GET A KEYSTROKE (TARGET CHARACTER) 
          PSHS A * AND SAVE IT ON STACK  
L866B     LDA  ,X             GET CURRENT BUFFER CHARACTER 
          BEQ  L8685          AND RETURN IF END OF LINE 
          TST  $01,S          CHECK KILL/SEARCH FLAG 
          BNE  L8679          BRANCH IF KILL 
          BSR  L8659          SEND A CHARACTER TO CONSOLE OUT 
          LEAX $01,X INCREMENT BUFFER POINTER  
          BRA  L867C          CHECK NEXT INPUT CHARACTER 
L8679     JSR  L85D1          REMOVE ONE CHARACTER FROM BUFFER 
L867C     LDA  ,X             GET CURRENT INPUT CHARACTER 
          CMPA ,S COMPARE TO TARGET CHARACTER  
          BNE  L866B          BRANCH IF NO MATCH 
          DECB DECREMENT REPEAT PARAMETER  
          BNE  L866B          BRANCH IF NOT DONE 
L8685     PULS Y,PC THE Y PULL WILL CLEAN UP THE STACK FOR THE 2 PSHS A  
*                              
* GET A KEYSTRKE                      
L8687     JSR  LA171          CALL CONSOLE IN : DEV NBR=SCREEN 
          CMPA #$7F GRAPHIC CHARACTER?  
          BCC  L8687          YES - GET ANOTHER CHAR 
          CMPA #$5F SHIFT UP ARROW (QUIT INSERT)  
          BNE  L8694          NO 
          LDA  #ESC           REPLACE W/ESCAPE CODE 
L8694     CMPA #CR ENTER KEY       
          BEQ  L86A6          YES 
          CMPA #ESC ESCAPE?         
          BEQ  L86A6          YES 
          CMPA #BS BACKSPACE?      
          BEQ  L86A6          YES 
          CMPA #SPACE SPACE           
          BLO  L8687          GET ANOTHER CHAR IF CONTROL CHAR 
          ORCC #$01 SET CARRY       
L86A6     RTS                  
                               
* TRON                         
TRON      FCB  SKP1LD         SKIP ONE BYTE AND LDA #$4F 
                               
* TROFF                        
TROFF     CLRA                TROFF FLAG 
          STA  TRCFLG         TRON/TROFF FLAG:0=TROFF, <> 0=TRON 
          RTS                  
                               
* POS                          
                               
POS       LDA  #0             GET DEVICE NUMBER 
          LDB  LPTPOS         GET PRINT POSITION 
LA5E8     SEX                 CONVERT ACCB TO 2 DIGIT SIGNED INTEGER 
          JMP  GIVABF         CONVERT ACCD TO FLOATING POINT 
                               
                               
* VARPTR                       
VARPT     JSR  LB26A          SYNTAX CHECK FOR ‘(‘ 
          LDD  ARYEND         GET ADDR OF END OF ARRAYS 
          PSHS B,A            SAVE IT ON STACK 
          JSR  LB357          GET VARIABLE DESCRIPTOR 
          JSR  LB267          SYNTAX CHECK FOR ‘)‘ 
          PULS A,B            GET END OF ARRAYS ADDR BACK 
          EXG  X,D            SWAP END OF ARRAYS AND VARIABLE DESCRIPTOR 
          CMPX ARYEND         COMPARE TO NEW END OF ARRAYS 
          BNE  L8724          ‘FC’ ERROR IF VARIABLE WAS NOT DEFINED PRIOR TO CALLING VARPTR 
          JMP  GIVABF         CONVERT VARIABLE DESCRIPTOR INTO A FP NUMBER 
                               
* MID$(OLDSTRING,POSITION,LENGTH)=REPLACEMENT                      
L86D6     JSR  GETNCH         GET INPUT CHAR FROM BASIC 
          JSR  LB26A          SYNTAX CHECK FOR ‘(‘ 
          JSR  LB357          * GET VARIABLE DESCRIPTOR ADDRESS AND 
          PSHS X              * SAVE IT ON THE STACK 
          LDD  $02,X          POINT ACCD TO START OF OLDSTRING 
          CMPD FRETOP         COMPARE TO START OF CLEARED SPACE 
          BLS  L86EB          BRANCH IF <= 
          SUBD MEMSIZ         SUBTRACT OUT TOP OF CLEARED SPACE 
          BLS  L86FD          BRANCH IF STRING IN STRING SPACE 
L86EB     LDB  ,X             GET LENGTH OF OLDSTRING 
          JSR  LB56D          RESERVE ACCB BYTES IN STRING SPACE 
          PSHS X              SAVE RESERVED SPACE STRING ADDRESS ON STACK 
          LDX  $02,S          POINT X TO OLDSTRING DESCRIPTOR 
          JSR  LB643          MOVE OLDSTRING INTO STRING SPACE 
          PULS X,U            * GET OLDSTRING DESCRIPTOR ADDRESS AND RESERVED STRING 
          STX  $02,U          * ADDRESS AND SAVE RESERVED ADDRESS AS OLDSTRING ADDRESS 
          PSHS U              SAVE OLDSTRING DESCRIPTOR ADDRESS 
L86FD     JSR  LB738          SYNTAX CHECK FOR COMMA AND EVALUATE LENGTH EXPRESSION 
          PSHS B              SAVE POSITION PARAMETER ON STACK 
          TSTB * CHECK POSITION PARAMETER AND BRANCH  
          BEQ  L8724          * IF START OF STRING 
          LDB  #$FF           DEFAULT REPLACEMENT LENGTH = $FF 
          CMPA #')'           * CHECK FOR END OF MID$ STATEMENT AND 
          BEQ  L870E          * BRANCH IF AT END OF STATEMENT 
          JSR  LB738          SYNTAX CHECK FOR COMMA AND EVALUATE LENGTH EXPRESSION 
L870E     PSHS B              SAVE LENGTH PARAMETER ON STACK 
          JSR  LB267          SYNTAX CHECK FOR ‘)‘ 
          LDB  #TOK_EQUALS    TOKEN FOR = 
          JSR  LB26F          SYNTAX CHECK FOR “=‘ 
          BSR  L8748          EVALUATE REPLACEMENT STRING 
          TFR  X,U            SAVE REPLACEMENT STRING ADDRESS IN U 
          LDX  $02,S          POINT X TO OLOSTRING DESCRIPTOR ADDRESS 
          LDA  ,X             GET LENGTH OF OLDSTRING 
          SUBA $01,S          SUBTRACT POSITION PARAMETER 
          BCC  L8727          INSERT REPLACEMENT STRING INTO OLDSTRING 
L8724     JMP  LB44A          ‘FC’ ERROR IF POSITION > LENGTH OF OLDSTRING 
L8727     INCA                * NOW ACCA = NUMBER OF CHARACTERS TO THE RIGHT 
*                             * (INCLUSIVE) OF THE POSITION PARAMETER 
          CMPA ,S              
          BCC  L872E          BRANCH IF NEW STRING WILL FIT IN OLDSTRING 
          STA  ,S             IF NOT, USE AS MUCH OF LENGTH PARAMETER AS WILL FIT 
L872E     LDA  $01,S          GET POSITION PARAMETER 
          EXG  A,B            ACCA=LENGTH OF REPL STRING, ACCB=POSITION PARAMETER 
          LDX  $02,X          POINT X TO OLDSTRING ADDRESS 
          DECB                * BASIC’S POSITION PARAMETER STARTS AT 1; THIS ROUTINE 
*                             * WANTS IT TO START AT ZERO 
          ABX                 POINT X TO POSITION IN OLDSTRING WHERE THE REPLACEMENT WILL GO 
          TSTA                * IF THE LENGTH OF THE REPLACEMENT STRING IS ZERO 
          BEQ  L8746          * THEN RETURN 
          CMPA ,S              
          BLS  L873F          ADJUSTED LENGTH PARAMETER, THEN BRANCH 
          LDA  ,S             OTHERWISE USE AS MUCH ROOM AS IS AVAILABLE 
L873F     TFR  A,B            SAVE NUMBER OF BYTES TO MOVE IN ACCB 
          EXG  U,X            SWAP SOURCE AND DESTINATION POINTERS 
          JSR  LA59A          MOVE (B) BYTES FROM (X) TO (U) 
L8746     PULS A,B,X,PC        
L8748     JSR  LB156          EVALUATE EXPRESSION 
          JMP  LB654          *‘TM’ ERROR IF NUMERIC; RETURN WITH X POINTING 
*                             *TO STRING, ACCB = LENGTH 
                               
* STRING                       
STRING    JSR  LB26A          SYNTAX CHECK FOR ‘(’ 
          JSR  LB70B          EVALUATE EXPRESSION; ERROR IF > 255 
          PSHS B              SAVE LENGTH OF STRING 
          JSR  LB26D          SYNTAX CHECK FOR COMMA 
          JSR  LB156          EVALUATE EXPRESSION 
          JSR  LB267          SYNTAX CHECK FOR ‘)‘ 
          LDA  VALTYP         GET VARIABLE TYPE 
          BNE  L8768          BRANCH IF STRING 
          JSR  LB70E          CONVERT FPA0 INTO AN INTEGER IN ACCB 
          BRA  L876B          SAVE THE STRING IN STRING SPACE 
L8768     JSR  LB6A4          GET FIRST BYTE OF STRING 
L876B     PSHS B              SAVE FIRST BYTE OF EXPRESSION 
          LDB  $01,S          GET LENGTH OF STRING 
          JSR  LB50F          RESERVE ACCB BYTES IN STRING SPACE 
          PULS A,B            GET LENGTH OF STRING AND CHARACTER 
          BEQ  L877B          BRANCH IF NULL STRING 
L8776     STA  ,X+            SAVE A CHARACTER IN STRING SPACE 
          DECB                DECREMENT LENGTH 
          BNE  L8776          BRANCH IF NOT DONE 
L877B     JMP  LB69B          PUT STRING DESCRIPTOR ONTO STRING STACK 
                               
* INSTR                        
INSTR     JSR  LB26A          SYNTAX CHECK FOR ‘(‘ 
          JSR  LB156          EVALUATE EXPRESSION 
          LDB  #$01           DEFAULT POSITION = 1 (SEARCH START) 
          PSHS B              SAVE START 
          LDA  VALTYP         GET VARIABLE TYPE 
          BNE  L879C          BRANCH IF STRING 
          JSR  LB70E          CONVERT FPA0 TO INTEGER IN ACCB 
          STB  ,S             SAVE START SEARCH VALUE 
          BEQ  L8724          BRANCH IF START SEARCH AT ZERO 
          JSR  LB26D          SYNTAX CHECK FOR COMMA 
          JSR  LB156          EVALUATE EXPRESSION - SEARCH STRING 
          JSR  LB146          ‘TM’ ERROR IF NUMERIC 
L879C     LDX  FPA0+2         SEARCH STRING DESCRIPTOR ADDRESS 
          PSHS X              SAVE ON THE STACK 
          JSR  LB26D          SYNTAX CHECK FOR COMMA 
          JSR  L8748          EVALUATE TARGET STRING EXPRESSION 
          PSHS X,B            SAVE ADDRESS AND LENGTH ON STACK 
          JSR  LB267          SYNTAX CHECK FOR ')' 
          LDX  $03,S          * LOAD X WITH SEARCH STRING DESCRIPTOR ADDRESS 
          JSR  LB659          * AND GET THE LENGTH ANDADDRESS OF SEARCH STRING 
          PSHS B              SAVE LENGTH ON STACK 
*                              
* AT THIS POINT THE STACK HAS THE FOLLOWING INFORMATION                      
* ON IT: 0,S-SEARCH LENGTH; 1,S-TARGET LENGTH; 2 3,S-TARGET                      
* ADDRESS; 4 5,S-SEARCH DESCRIPTOR ADDRESS; 6,S-SEARCH POSITION                      
          CMPB $06,S          COMPARE LENGTH OF SEARCH STRING TO START 
          BLO  L87D9          POSITION; RETURN 0 IF LENGTH < START 
          LDA  $01,S          GET LENGTH OF TARGET STRING 
          BEQ  L87D6          BRANCH IF TARGET STRING = NULL 
          LDB  $06,S          GET START POSITION 
          DECB                MOVE BACK ONE 
          ABX  POINT X TO POSITION IN SEARCH STRING WHERE SEARCHING WILL START  
L87BE     LEAY ,X             POINT Y TO SEARCH POSITION 
          LDU  $02,S          POINT U TO START OF TARGET 
          LDB  $01,S          LOAD ACCB WITH LENGTH OF TARGET 
          LDA  ,S             LOAD ACCA WITH LENGTH OF SEARCH 
          SUBA $06,S          SUBTRACT SEARCH POSITION FROM SEARCH LENGTH 
          INCA                ADD ONE 
          CMPA $01,S          COMPARE TO TARGET LENGTH 
          BLO  L87D9          RETURN 0 IF TARGET LENGTH > WHAT’S LEFT OF SEARCH STRING 
L87CD     LDA  ,X+            GET A CHARACTER FROM SEARCH STRING 
          CMPA ,U+            COMPARE IT TO TARGET STRING 
          BNE  L87DF          BRANCH IF NO MATCH 
          DECB                DECREMENT TARGET LENGTH 
          BNE  L87CD          CHECK ANOTHER CHARACTER 
L87D6     LDB  $06,S          GET MATCH POSITION 
L87D8     FCB  SKP1           SKIP NEXT BYTE 
L87D9     CLRB                MATCH ADDRESS = 0 
          LEAS $07,S          CLEAN UP THE STACK 
          JMP  LB4F3          CONVERT ACCB TO FP NUMBER 
L87DF     INC  $06,S          INCREMENT SEARCH POSITION 
          LEAX $01,Y          MOVE X TO NEXT SEARCH POSITION 
          BRA  L87BE          KEEP LOOKING FOR A MATCH 
                               
* EXTENDED BASIC RVEC19 HOOK CODE                      
XVEC19    CMPA #'&'           * 
          BNE  L8845          * RETURN IF NOT HEX OR OCTAL VARIABLE 
          LEAS $02,S          PURGE RETURN ADDRESS FROM STACK 
* PROCESS A VARIABLE PRECEEDED BY A ‘&‘ (&H,&O)                      
L87EB     CLR  FPA0+2         * CLEAR BOTTOM TWO 
          CLR  FPA0+3         * BYTES OF FPA0 
          LDX  #FPA0+2        BYTES 2,3 OF FPA0 = (TEMPORARY ACCUMULATOR) 
          JSR  GETNCH         GET A CHARACTER FROM BASIC 
          CMPA #'O'            
          BEQ  L880A          YES 
          CMPA #'H'            
          BEQ  L881F          YES 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          BRA  L880C          DEFAULT TO OCTAL (&O) 
L8800     CMPA #'8'            
          LBHI LB277           
          LDB  #$03           BASE 8 MULTIPLIER 
          BSR  L8834          ADD DIGIT TO TEMPORARY ACCUMULATOR 
* EVALUATE AN &O VARIABLE                      
L880A     JSR  GETNCH         GET A CHARACTER FROM BASIC 
L880C     BLO  L8800          BRANCH IF NUMERIC 
L880E     CLR  FPA0           * CLEAR 2 HIGH ORDER 
          CLR  FPA0+1         * BYTES OF FPA0 
          CLR  VALTYP         SET VARXABLE TYPE TO NUMERIC 
          CLR  FPSBYT         ZERO OUT SUB BYTE OF FPA0 
          CLR  FP0SGN         ZERO OUT MANTISSA SIGN OF FPA0 
          LDB  #$A0           * SET EXPONENT OF FPA0 
          STB  FP0EXP         * 
          JMP  LBA1C          GO NORMALIZE FPA0 
* EVALUATE AN &H VARIABLE                      
L881F     JSR  GETNCH         GET A CHARACTER FROM BASIC 
          BLO  L882E          BRANCH IF NUMERIC 
          JSR  LB3A2          SET CARRY IF NOT ALPHA 
          BLO  L880E          BRANCH IF NOT ALPHA OR NUMERIC 
          CMPA #'G'           CHECK FOR LETTERS A-F 
          BCC  L880E          BRANCH IF >= G (ILLEGAL HEX LETTER) 
          SUBA #7             SUBTRACT ASCII DIFFERENCE BETWEEN A AND 9 
L882E     LDB  #$04           BASE 16 DIGIT MULTIPLIER = 2**4 
          BSR  L8834          ADD DIGIT TO TEMPORARY ACCUMULATOR 
          BRA  L881F          KEEP EVALUATING VARIABLE 
L8834     ASL  $01,X          * MULTIPLY TEMPORARY 
          ROL  ,X             * ACCUMULATOR BY TWO 
          LBCS LBA92          ‘OV' OVERFLOW ERROR 
          DECB                DECREMENT SHIFT COUNTER 
          BNE  L8834          MULTIPLY TEMPORARY ACCUMULATOR AGAIN 
          SUBA #'0'           MASK OFF ASCII 
          ADDA $01,X          * ADD DIGIT TO TEMPORARY 
          STA  $01,X          * ACCUMULATOR AND SAVE IT 
L8845     RTS                  
                               
XVEC15    PULS U              PULL RETURN ADDRESS AND SAVE IN U REGISTER 
          CLR  VALTYP         SET VARIABLE TYPE TO NUMERIC 
          LDX  CHARAD         CURRENT INPUT POINTER TO X 
          JSR  GETNCH         GET CHARACTER FROM BASIC 
          CMPA #'&'           HEX AND OCTAL VARIABLES ARE PRECEEDED BY & 
          BEQ  L87EB          PROCESS A ‘&‘ VARIABLE 
          CMPA #TOK_FN        TOKEN FOR FN 
          BEQ  L88B4          PROCESS FN CALL 
          CMPA #$FF           CHECK FOR SECONDARY TOKEN 
          BNE  L8862          NOT SECONDARY 
          JSR  GETNCH         GET CHARACTER FROM BASIC 
          CMPA #TOK_USR       TOKEN FOR USR 
          LBEQ L892C          PROCESS USR CALL 
L8862     STX  CHARAD         RESTORE BASIC’S INPUT POINTER 
          JMP  ,U             RETURN TO CALLING ROUTINE 
L8866     LDX  CURLIN         GET CURRENT LINE NUMBER 
          LEAX $01,X          IN DIRECT MODE? 
          BNE  L8845          RETURN IF NOT IN DIRECT MODE 
          LDB  #2*11          ‘ILLEGAL DIRECT STATEMENT’ ERROR 
L886E     JMP  LAC46          PROCESS ERROR 
                               
DEF       LDX  [CHARAD]       GET TWO INPUT CHARS 
          CMPX #TOK_FF_USR    TOKEN FOR USR 
          LBEQ L890F          BRANCH IF DEF USR 
          BSR  L88A1          GET DESCRIPTOR ADDRESS FOR FN VARIABLE NAME 
          BSR  L8866          DON’T ALLOW DEF FN IF IN DIRECT MODE 
          JSR  LB26A          SYNTAX CHECK FOR ‘(‘ 
          LDB  #$80           * GET THE FLAG TO INDICATE ARRAY VARIABLE SEARCH DISABLE 
          STB  ARYDIS         * AND SAVE IT IN THE ARRAY DISABLE FLAG 
          JSR  LB357          GET VARIABLE DESCRIPTOR 
          BSR  L88B1          ‘TM’ ERROR IF STRING 
          JSR  LB267          SYNTAX CHECK FOR ‘)‘ 
          LDB  #TOK_EQUALS    TOKEN FOR ‘=‘ 
          JSR  LB26F          DO A SYNTAX CHECK FOR = 
          LDX  V4B            GET THE ADDRESS OF THE FN NAME DESCRIPTOR 
          LDD  CHARAD         * GET THE CURRENT INPUT POINTER ADDRESS AND 
          STD  ,X             * SAVE IT IN FIRST 2 BYTES OF THE DESCRIPTOR 
          LDD  VARPTR         = GET THE DESCRIPTOR ADDRESS OF THE ARGUMENT 
          STD  $02,X          = VARIABLE AND SAVE IT IN THE DESCRIPTOR OF THE FN NAME 
          JMP  DATA           MOVE INPUT POINTER TO END OF LINE OR SUBLINE 
L88A1     LDB  #TOK_FN        TOKEN FOR FN 
          JSR  LB26F          DO A SYNTAX CHECK FOR FN 
          LDB  #$80           * GET THE FLAG TO INDICATE ARRAY VARIABLE SEARCH DISABLE FLAG 
          STB  ARYDIS         * AND SAVE IT IN ARRAY VARIABLE FLAG 
          ORA  #$80           SET BIT 7 OF CURRENT INPUT CHARACTER TO INDICATE AN FN VARIABLE 
          JSR  LB35C          * GET THE DESCRIPTOR ADDRESS OF THIS 
          STX  V4B            * VARIABLE AND SAVE IT IN V4B 
L88B1     JMP  LB143          ‘TM’ ERROR IF STRING VARIABLE 
* EVALUATE AN FN CALL                      
L88B4     BSR  L88A1          * GET THE DESCRIPTOR OF THE FN NAME 
          PSHS X              * VARIABLE AND SAVE IT ON THE STACK 
          JSR  LB262          SYNTAX CHECK FOR ‘(‘ & EVALUATE EXPR 
          BSR  L88B1          ‘TM’ ERROR IF STRING VARIABLE 
          PULS U              POINT U TO FN NAME DESCRIPTOR 
          LDB  #2*25          ‘UNDEFINED FUNCTION CALL’ ERROR 
          LDX  $02,U          POINT X TO ARGUMENT VARIABLE DESCRIPTOR 
          BEQ  L886E          BRANCH TO ERROR HANDLER 
          LDY  CHARAD         SAVE CURRENT INPUT POINTER IN Y 
          LDU  ,U             * POINT U TO START OF FN FORMULA AND 
          STU  CHARAD         * SAVE IT IN INPUT POINTER 
          LDA  $04,X          = GET FP VALUE OF 
          PSHS A              = ARGUMENT VARIABLE, CURRENT INPUT 
          LDD  ,X             = POINTER, AND ADDRESS OF START 
          LDU  $02,X          = OF FN FORMULA AND SAVE 
          PSHS U,Y,X,B,A      = THEM ON THE STACK 
          JSR  LBC35          PACK FPA0 AND SAVE IT IN (X) 
L88D9     JSR  LB141          EVALUATE FN EXPRESSION 
          PULS A,B,X,Y,U      RESTORE REGISTERS 
          STD  ,X             * GET THE FP 
          STU  $02,X          * VALUE OF THE ARGUMENT 
          PULS A              * VARIABLE OFF OF THE 
          STA  $04,X          * STACK AND RE-SAVE IT 
          JSR  GETCCH         GET FINAL CHARACTER OF THE FN FORMULA 
          LBNE LB277          ‘SYNTAX’ ERROR IF NOT END OF LINE 
          STY  CHARAD         RESTORE INPUT POINTER 
L88EF     RTS                  
                               
                               
                               
* DEF USR                      
L890F     JSR  GETNCH         SKIP PAST SECOND BYTE OF DEF USR TOKEN 
          BSR  L891C          GET FN NUMBER 
          PSHS X              SAVE FN EXEC ADDRESS STORAGE LOC 
          BSR  L8944          CALCULATE EXEC ADDRESS 
          PULS U              GET FN EXEC ADDRESS STORAGE LOC 
          STX  ,U             SAVE EXEC ADDRESS 
          RTS                  
L891C     CLRB                DEFAULT TO USR0 IF NO ARGUMENT 
          JSR  GETNCH         GET A CHARACTER FROM BASIC 
          BCC  L8927          BRANCH IF NOT NUMERIC 
          SUBA #'0'           MASK OFF ASCII 
          TFR  A,B            SAVE USR NUMBER IN ACCB 
          JSR  GETNCH         GET A CHARACTER FROM BASIC 
L8927     LDX  USRADR         GET ADDRESS OF STORAGE LOCs FOR USR ADDRESS 
          ASLB                X2 - 2 BYTES/USR ADDRESS 
          ABX                 ADD OFFSET TO START ADDRESS OF STORAGE LOCs 
          RTS                  
* PROCESS A USR CALL                      
L892C     BSR  L891C          GET STORAGE LOC OF EXEC ADDRESS FOR USR N 
          LDX  ,X             * GET EXEC ADDRESS AND 
          PSHS X              * PUSH IT ONTO STACK 
          JSR  LB262          SYNTAX CHECK FOR ‘(‘ & EVALUATE EXPR 
          LDX  #FP0EXP        POINT X TO FPA0 
          LDA  VALTYP         GET VARIABLE TYPE 
          BEQ  L8943          BRANCH IF NUMERIC, STRING IF <> 0 
          JSR  LB657          GET LENGTH & ADDRESS OF STRING VARIABLE 
          LDX  FPA0+2         GET POINTER TO STRING DESCRIPTOR 
          LDA  VALTYP         GET VARIABLE TYPE 
L8943     RTS                 JUMP TO USR ROUTINE (PSHS X ABOVE) 
L8944     LDB  #TOK_EQUALS    TOKEN FOR ‘=‘ 
          JSR  LB26F          DO A SYNTAX CHECK FOR = 
          JMP  LB73D          EVALUATE EXPRESSION, RETURN VALUE IN X 
                               
                               
                               
* DEL                          
DEL       LBEQ LB44A          FC’ ERROR IF NO ARGUMENT 
          JSR  LAF67          CONVERT A DECIMAL BASiC NUMBER TO BINARY 
          JSR  LAD01          FIND RAM ADDRESS OF START OF A BASIC LINE 
          STX  VD3            SAVE RAM ADDRESS OF STARTING LINE NUMBER 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          BEQ  L8990          BRANCH IF END OF LINE 
          CMPA #TOK_MINUS     TOKEN FOR ‘-' 
          BNE  L89BF          TERMINATE COMMAND IF LINE NUMBER NOT FOLLOWED BY ‘-‘ 
          JSR  GETNCH         GET A CHARACTER FROM BASIC 
          BEQ  L898C          IF END OF LINE, USE DEFAULT ENDING LINE NUMBER 
          BSR  L89AE          * CONVERT ENDING LINE NUMBER TO BINARY 
          BRA  L8990          * AND SAVE IT IN BINVAL 
L898C     LDA  #$FF           = USE $FFXX AS DEFAULT ENDING 
          STA  BINVAL         = LINE NUMBER - SAVE IT IN BINVAL 
L8990     LDU  VD3            POINT U TO STARTING LINE NUMBER ADDRESS 
L8992     FCB  SKP2           SKIP TWO BYTES 
L8993     LDU  ,U             POINT U TO START OF NEXT LINE 
          LDD  ,U             CHECK FOR END OF PROGRAM 
          BEQ  L899F          BRANCH IF END OF PROGRAM 
          LDD  $02,U          LOAD ACCD WITH THIS LINE’S NUMBER 
          SUBD BINVAL         SUBTRACT ENDING LINE NUMBER ADDRESS 
          BLS  L8993          BRANCH IF = < ENDING LINE NUMBER 
L899F     LDX  VD3            GET STARTING LINE NUMBER 
          BSR  L89B8          MOVE (U) TO (X) UNTIL END OF PROGRAM 
          JSR  LAD21          RESET BASIC’S INPUT POINTER AND ERASE VARIABLES 
          LDX  VD3            GET STARTING LINE NUMBER ADDRESS 
          JSR  LACF1          RECOMPUTE START OF NEXT LINE ADDRESSES 
          JMP  LAC73          JUMP TO BASIC’S MAIN COMMAND LOOP 
L89AE     JSR  LAF67          GO GET LINE NUMBER CONVERTED TO BINARY 
          JMP  LA5C7          MAKE SURE THERE’S NO MORE ON THIS LINE 
L89B4     LDA  ,U+            GET A BYTE FROM (U) 
          STA  ,X+            MOVE THE BYTE TO (X) 
L89B8     CMPU VARTAB         COMPARE TO END OF BASIC 
          BNE  L89B4          BRANCH IF NOT AT END 
          STX  VARTAB         SAVE (X) AS NEW END OF BASIC 
L89BF     RTS                  
                               
                               
L89C0     JSR  L8866          ‘BS’ ERROR IF IN DIRECT MODE 
          JSR  GETNCH         GET A CHAR FROM BASIC 
L89D2     CMPA #'"'           CHECK FOR PROMPT STRING 
          BNE  L89E1          BRANCH IF NO PROMPT STRING 
          JSR  LB244          STRIP OFF PROMPT STRING & PUT IT ON STRING STACK 
          LDB  #';'           * 
          JSR  LB26F          * DO A SYNTAX CHECK FOR; 
          JSR  LB99F          REMOVE PROMPT STRING FROM STRING STACK & SEND TO CONSOLE OUT 
L89E1     LEAS $-02,S         RESERVE TWO STORAGE SLOTS ON STACK 
          JSR  LB035          INPUT A LINE FROM CURRENT INPUT DEVICE 
          LEAS $02,S          CLEAN UP THE STACK 
          JSR  LB357          SEARCH FOR A VARIABLE 
          STX  VARDES         SAVE POINTER TO VARIABLE DESCRIPTOR 
          JSR  LB146          ‘TM’ ERROR IF VARIABLE TYPE = NUMERIC 
          LDX  #LINBUF        POINT X TO THE STRING BUFFER WHERE THE INPUT STRING WAS STORED 
          CLRA                TERMINATOR CHARACTER 0 (END OF LINE) 
          JSR  LB51A          PARSE THE INPUT STRING AND STORE IT IN THE STRING SPACE 
          JMP  LAFA4          REMOVE DESCRIPTOR FROM STRING STACK 
L89FC     JSR  LAF67          STRIP A DECIMAL NUMBER FROM BASIC INPUT LINE 
          LDX  BINVAL         GET BINARY VALUE 
          RTS                  
L8A02     LDX  VD1            GET CURRENT OLD NUMBER BEING RENUMBERED 
L8A04     STX  BINVAL         SAVE THE LINE NUMBER BEING SEARCHED FOR 
          JMP  LAD01          GO FIND THE LINE NUMBER IN BASIC PROGRAM 
                               
* RENUM                        
RENUM     JSR  LAD26          ERASE VARIABLES 
          LDD  #10            DEFAULT LINE NUMBER INTERVAL 
          STD  VD5            SAVE DEFAULT RENUMBER START LINE NUMBER 
          STD  VCF            SAVE DEFAULT INTERVAL 
          CLRB                NOW ACCD = 0 
          STD  VD1            DEFAULT LINE NUMBER OF WHERE TO START RENUMBERING 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          BCC  L8A20          BRANCH IF NOT NUMERIC 
          BSR  L89FC          CONVERT DECIMAL NUMBER IN BASIC PROGRAM TO BINARY 
          STX  VD5            SAVE LINE NUMBER WHERE RENUMBERING STARTS 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
L8A20     BEQ  L8A3D          BRANCH IF END OF LINE 
          JSR  LB26D          SYNTAX CHECK FOR COMMA 
          BCC  L8A2D          BRANCH IF NEXT CHARACTER NOT NUMERIC 
          BSR  L89FC          CONVERT DECIMAL NUMBER IN BASIC PROGRAM TO BINARY 
          STX  VD1            SAVE NEW RENUMBER LINE 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
L8A2D     BEQ  L8A3D          BRANCH IF END OF LINE 
          JSR  LB26D          SYNTAX CHECK FOR COMMA 
          BCC  L8A3A          BRANCH IF NEXT CHARACTER NOT NUMERIC 
          BSR  L89FC          CONVERT DECIMAL NUMBER IN BASIC PROGRAM TO BINARY 
          STX  VCF            SAVE NEW INTERVAL 
          BEQ  L8A83          ‘FC' ERROR 
L8A3A     JSR  LA5C7          CHECK FOR MORE CHARACTERS ON LINE - ‘SYNTAX’ ERROR IF ANY 
L8A3D     BSR  L8A02          GO GET ADDRESS OF OLD NUMBER BEING RENUMBERED 
          STX  VD3            SAVE ADDRESS 
          LDX  VD5            GET NEXT RENUMBERED LINE NUMBER TO USE 
          BSR  L8A04          FIND THE LINE NUMBER IN THE BASIC PROGRAM 
          CMPX VD3            COMPARE TO ADDRESS OF OLD LINE NUMBER 
          BLO  L8A83          ‘FC’ ERROR IF NEW ADDRESS < OLD ADDRESS 
          BSR  L8A67          MAKE SURE RENUMBERED LINE NUMBERS WILL BE IN RANGE 
          JSR  L8ADD          CONVERT ASCII LINE NUMBERS TO ‘EXPANDED’ BINARY 
          JSR  LACEF          RECALCULATE NEXT LINE RAM ADDRESSES 
          BSR  L8A02          GET RAM ADDRESS OF FIRST LINE TO BE RENUMBERED 
          STX  VD3            SAVE IT 
          BSR  L8A91          MAKE SURE LINE NUMBERS EXIST 
          BSR  L8A68          INSERT NEW LINE NUMBERS IN LINE HEADERS 
          BSR  L8A91          INSERT NEW LINE NUMBERS IN PROGRAM STATEMENTS 
          JSR  L8B7B          CONVERT PACKED BINARY LINE NUMBERS TO ASCII 
          JSR  LAD26          ERASE VARIABLES 
          JSR  LACEF          RECALCULATE NEXT LINE RAM ADDRESS 
          JMP  LAC73          GO BACK TO BASIC’S MAIN LOOP 
L8A67     FCB  SKP1LD         SKIP ONE BYTE - LDA #$4F 
L8A68     CLRA                NEW LINE NUMBER FLAG - 0; INSERT NEW LINE NUMBERS 
          STA  VD8            SAVE NEW LINE NUMBER FLAG; 0 = INSERT NEW NUMBERS 
          LDX  VD3            GET ADDRESS OF OLD LINE NUMBER BEING RENUMBERED 
          LDD  VD5            GET THE CURRENT RENUMBERED LINE NUMBER 
          BSR  L8A86          RETURN IF END OF PROGRAM 
L8A71     TST  VD8            CHECK NEW LINE NUMBER FLAG 
          BNE  L8A77          BRANCH IF NOT INSERTING NEW LINE NUMBERS 
          STD  $02,X          STORE THE NEW LINE NUMBER IN THE BASIC PROGRAM 
L8A77     LDX  ,X             POINT X TO THE NEXT LINE IN BASIC 
          BSR  L8A86          RETURN IF END OF PROGRAM 
          ADDD VCF            ADD INTERVAL TO CURRENT RENUMBERED LINE NUMBER 
          BLO  L8A83          ‘FC’ ERROR IF LINE NUMBER > $FFFF 
          CMPA #MAXLIN        LARGEST LINE NUMBER = $F9FF 
          BLO  L8A71          BRANCH IF LEGAL LINE NUMBER 
L8A83     JMP  LB44A          ‘FC’ ERROR IF LINE NUMBER MS BYTE > $F9 
* TEST THE TWO BYTES POINTED TO BY (X).                      
* NORMAL RETURN IF <> 0. IF = 0 (END OF                      
* PROGRAM) RETURN IS PULLED OFF STACK AND                      
* YOU RETURN TO PREVIOUS SUBROUTINE CALL.                      
L8A86     PSHS B,A            SAVE ACCD 
          LDD  ,X             TEST THE 2 BYTES POINTED TO BY X 
          PULS A,B            RESTORE ACCD 
          BNE  L8A90          BRANCH IF NOT END OF PROGRAM 
          LEAS $02,S          PURGE RETURN ADDRESS FROM STACK 
L8A90     RTS                  
L8A91     LDX  TXTTAB         GET START OF BASIC PROGRAM 
          LEAX $-01,X         MOVE POINTER BACK ONE 
L8A95     LEAX $01,X          MOVE POINTER UP ONE 
          BSR  L8A86          RETURN IF END OF PROGRAM 
L8A99     LEAX $03,X          SKIP OVER NEXT LINE ADDRESS AND LINE NUMBER 
L8A9B     LEAX $01,X          MOVE POINTER TO NEXT CHARACTER 
          LDA  ,X             CHECK CURRENT CHARACTER 
          BEQ  L8A95          BRANCH IF END OF LINE 
          STX  TEMPTR         SAVE CURRENT POINTER 
          DECA                = 
          BEQ  L8AB2          =BRANCH IF START OF PACKED NUMERIC LINE 
          DECA                * 
          BEQ  L8AD3          *BRANCH IF LINE NUMBER EXISTS 
          DECA                = 
          BNE  L8A9B          =MOVE TO NEXT CHARACTER IF > 3 
L8AAC     LDA  #$03           * SET 1ST BYTE = 3 TO INDICATE LINE 
          STA  ,X+            * NUMBER DOESN’T CURRENTLY EXIST 
          BRA  L8A99          GO GET ANOTHER CHARACTER 
L8AB2     LDD  $01,X          GET MS BYTE OF LINE NUMBER 
          DEC  $02,X          DECREMENT ZERO CHECK BYTE 
          BEQ  L8AB9          BRANCH IF MS BYTE <> 0 
          CLRA                CLEAR MS BYTE 
L8AB9     LDB  $03,X          GET LS BYTE OF LINE NUMBER 
          DEC  $04,X          DECREMENT ZERO CHECK FLAG 
          BEQ  L8AC0          BRANCH IF IS BYTE <> 0 
          CLRB                CLEAR LS BYTE 
L8AC0     STD  $01,X          SAVE BINARY LINE NUMBER 
          STD  BINVAL         SAVE TRIAL LINE NUMBER 
          JSR  LAD01          FIND RAM ADDRESS OF A BASIC LINE NUMBER 
L8AC7     LDX  TEMPTR         GET BACK POINTER TO START OF PACKED LINE NUMBER 
          BLO  L8AAC          BRANCH IF NO LINE NUMBER MATCH FOUND 
          LDD  V47            GET START ADDRESS OF LINE NUMBER 
          INC  ,X+            * SET 1ST BYTE = 2, TO INDICATE LINE NUMBER EXISTS IF CHECKING FOR 
*              * EXISTENCE OF LINE NUMBER, SET IT = 1 IF INSERTING LINE NUMBERS  
                               
          STD  ,X             SAVE RAM ADDRESS OF CORRECT LINE NUMBER 
          BRA  L8A99          GO GET ANOTHER CHARACTER 
L8AD3     CLR  ,X             CLEAR CARRY FLAG AND 1ST BYTE 
          LDX  $01,X          POINT X TO RAM ADDRESS OF CORRECT LINE NUMBER 
          LDX  $02,X          PUT CORRECT LINE NUMBER INTO (X) 
          STX  V47            SAVE IT TEMPORARILY 
          BRA  L8AC7          GO INSERT IT INTO BASIC LINE 
L8ADD     LDX  TXTTAB         GET BEGINNING OF BASIC PROGRAM 
          BRA  L8AE5           
L8AE1     LDX  CHARAD         *GET CURRENT INPUT POINTER 
          LEAX $01,X          *AND BUMP IT ONE 
L8AE5     BSR  L8A86          RETURN IF END OF PROGRAM 
          LEAX $02,X          SKIP PAST NEXT LINE ADDRESS 
L8AE9     LEAX $01,X          ADVANCE POINTER BY ONE 
L8AEB     STX  CHARAD         SAVE NEW BASIC INPUT POINTER 
L8AED     JSR  GETNCH         GET NEXT CHARACTER FROM BASIC 
L8AEF     TSTA                CHECK THE CHARACTER 
          BEQ  L8AE1          BRANCH IF END OF LINE 
          BPL  L8AED          BRANCH IF NOT A TOKEN 
          LDX  CHARAD         GET CURRENT INPUT POINTER 
          CMPA #$FF           IS THIS A SECONDARY TOKEN? 
          BEQ  L8AE9          YES - IGNORE IT 
          CMPA #TOK_THEN      TOKEN FOR THEN? 
          BEQ  L8B13          YES 
          CMPA #TOK_ELSE      TOKEN FOR ELSE? 
          BEQ  L8B13          YES 
          CMPA #TOK_GO        TOKEN FOR GO? 
          BNE  L8AED          NO 
          JSR  GETNCH         GET A CHARACTER FROM BASIC 
          CMPA #TOK_TO        TOKEN FOR TO? 
          BEQ  L8B13          YES 
          CMPA #TOK_SUB       TOKEN FOR SUB? 
          BNE  L8AEB          NO 
L8B13     JSR  GETNCH         GET A CHARACTER FROM BASIC 
          BLO  L8B1B          BRANCH IF NUMERIC 
L8B17     JSR  GETCCH         GET CURRENT BASIC INPUT CHARRACTER 
          BRA  L8AEF          KEEP CHECKING THE LINE 
L8B1B     LDX  CHARAD         GET CURRENT INPUT ADDRESS 
          PSHS X              SAVE IT ON THE STACK 
          JSR  LAF67          CONVERT DECIMAL BASIC NUMBER TO BINARY 
          LDX  CHARAD         GET CURRENT INPUT POINTER 
L8B24     LDA  ,-X            GET PREVIOUS INPUT CHARACTER 
          JSR  L90AA          CLEAR CARRY IF NUMERIC INPUT VALUE 
          BLO  L8B24          BRANCH IF NON-NUMERIC 
          LEAX $01,X          MOVE POINTER UP ONE 
          TFR  X,D            NOW ACCD POINTS TO ONE PAST END OF LINE NUMBER 
          SUBB $01,S          SUBTRACT PRE-NUMERIC POINTER LS BYTE 
          SUBB #$05           MAKE SURE THERE ARE AT LEAST 5 CHARACTERS IN THE NUMERIC LINE 
*                              
          BEQ  L8B55          BRANCH IF EXACTLY 5 
          BLO  L8B41          BRANCH IF < 5 
          LEAU ,X             TRANSFER X TO U 
          NEGB                NEGATE B 
          LEAX B,X            MOVE X BACK B BYTES 
          JSR  L89B8          *MOVE BYTES FROM (U) TO (X) UNTIL 
*         *U   = END OF BASIC; (I) = NEW END OF BASIC  
          BRA  L8B55           
* FORCE FIVE BYTES OF SPACE FOR THE LINE NUMBER                      
L8B41     STX  V47            SAVE END OF NUMERIC VALUE 
          LDX  VARTAB         GET END OF BASIC PROGRAM 
          STX  V43            SAVE IT 
          NEGB                NEGATE B 
          LEAX B,X            ADD IT TO END OF NUMERIC POiNTER 
          STX  V41            SAVE POINTER 
          STX  VARTAB         STORE END OF BASIC PROGRAM 
          JSR  LAC1E          ACCD = TOP OF ARRAYS - CHECK FOR ENOUGH ROOM 
          LDX  V45            * GET AND SAVE THE 
          STX  CHARAD         * NEW CURRENT INPUT POINTER 
L8B55     PULS X              RESTORE POINTER TO START OF NUMERIC VALUE 
          LDA  #$01           NEW LINE NUMBER FLAG 
          STA  ,X             * SAVE NEW LINE FLAG 
          STA  $02,X          * 
          STA  $04,X          * 
          LDB  BINVAL         GET MS BYTE OF BINARY LINE NUMBER 
          BNE  L8B67          BRANCH IF IT IS NOT ZERO 
          LDB  #$01           SAVE A 1 IF BYTE IS 0; OTHERWISE, BASIC WILL 
*              THINK IT IS THE END OF A LINE  
          INC  $02,X          IF 2,X = 2, THEN PREVIOUS BYTE WAS A ZERO 
L8B67     STB  $01,X          SAVE MS BYTE OF BINARY LINE NUMBER 
          LDB  BINVAL+1       GET IS BYTE OF BINARY LINE NUMBER 
          BNE  L8B71          BRANCH IF NOT A ZERO BYTE 
          LDB  #$01           SAVE A 1 IF BYTE IS A 0 
          INC  $04,X          IF 4,X = 2, THEN PREVIOUS BYTE WAS A 0 
L8B71     STB  $03,X          SAVE LS BYTE OF BINARY LINE NUMBER 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          CMPA #','           IS IT A COMMA? 
          BEQ  L8B13          YES - PROCESS ANOTHER NUMERIC VALUE 
          BRA  L8B17          NO - GO GET AND PROCESS AN INPUT CHARACTER 
L8B7B     LDX  TXTTAB         POINT X TO START OF BASIC PROGRAM 
          LEAX $-01,X         MOVE POINTER BACK ONE 
L8B7F     LEAX $01,X          MOVE POINTER UP ONE 
          LDD  $02,X          GET ADDRESS OF NEXT LINE 
          STD  CURLIN         SAVE IT IN CURLIN 
          JSR  L8A86          RETURN IF END OF PROGRAM 
          LEAX $03,X          SKIP OVER ADDRESS OF NEXT LINE AND 1ST BYTE OF LINE NUMBER 
L8B8A     LEAX $01,X          MOVE POINTER UP ONE 
L8B8C     LDA  ,X             GET CURRENT CHARACTER 
          BEQ  L8B7F          BRANCH IF END OF LINE 
          DECA                INPUT CHARACTER = 1? - VALID LINE NUMBER 
          BEQ  L8BAE          YES 
          SUBA #$02           INPUT CHARACTER 3? - UL LINE NUMBER 
          BNE  L8B8A          NO 
          PSHS X              SAVE CURRENT POSITION OF INPUT POINTER 
          LDX  #L8BD9-1       POINT X TO ‘UL’ MESSAGE 
          JSR  LB99C          PRINT STRING TO THE SCREEN 
          LDX  ,S             GET INPUT POINTER 
          LDD  $01,X          GET THE UNDEFINED LINE NUMBER 
          JSR  LBDCC          CONVERT NUMBER IN ACCD TO DECIMAL AND DISPLAY IT 
          JSR  LBDC5          PRINT ‘IN XXXX’ XXXX = CURRENT LINE NUMBER 
          JSR  LB958          SEND A CR TO CONSOLE OUT 
          PULS X              GET INPUT POINTER BACK 
L8BAE     PSHS X              SAVE CURRENT POSITION OF INPUT POINTER 
          LDD  $01,X          LOAD ACCD WITH BINARY VALUE OF LINE NUMBER 
          STD  FPA0+2         SAVE IN BOTTOM 2 BYTES OF FPA0 
          JSR  L880E          ADJUST REST OF FPA0 AS AN INTEGER 
          JSR  LBDD9          CONVERT FPA0 TO ASCII, STORE IN LINE NUMBER 
          PULS U              LOAD U WITH PREVIOUS ADDRESS OF INPUT POINTER 
          LDB  #$05           EACH EXPANDED LINE NUMBER USES 5 BYTES 
L8BBE     LEAX $01,X          MOVE POINTER FORWARD ONE 
          LDA  ,X             GET AN ASCII BYTE 
          BEQ  L8BC9          BRANCH IF END OF NUMBER 
          DECB                DECREMENT BYTE COUNTER 
          STA  ,U+            STORE ASCII NUMBER IN BASIC LINE 
          BRA  L8BBE          CHECK FOR ANOTHER DIGIT 
L8BC9     LEAX ,U             TRANSFER NEW LINE POINTER TO (X) 
          TSTB DOES THE NEW LINE NUMBER REQUIRE 5 BYTES?  
          BEQ  L8B8C          YES - GO GET ANOTHER INPUT CHARACTER 
          LEAY ,U             SAVE NEW LINE POINTER IN Y 
          LEAU B,U            POINT U TO END OF 5 BYTE PACKED LINE NUMBER BLOCK 
          JSR  L89B8          MOVE BYTES FROM (U) TO (X) UNTIL END OF PROGRAM 
          LEAX ,Y             LOAD (X) WITH NEW LINE POINTER 
          BRA  L8B8C          GO GET ANOTHER INPUT CHARACTER 
                               
L8BD9     FCC  "UL "          UNKNOWN LINE NUMBER MESSAGE 
          FCB  0               
                               
                               
HEXDOL    JSR  LB740          CONVERT FPA0 INTO A POSITIVE 2 BYTE INTEGER 
          LDX  #STRBUF+2      POINT TO TEMPORARY BUFFER 
          LDB  #$04           CONVERT 4 NIBBLES 
L8BE5     PSHS B              SAVE NIBBLE COUNTER 
          CLRB                CLEAR CARRY FLAG 
          LDA  #$04           4 SHIFTS 
L8BEA     ASL  FPA0+3         * SHIFT BOTTOM TWO BYTES OF 
          ROL  FPA0+2         * FPA0 LEFT ONE BIT (X2) 
          ROLB                IF OVERFLOW, ACCB <> 0 
          DECA                * DECREMENT SHIFT COUNTER AND 
          BNE  L8BEA          * BRANCH IF NOT DONE 
          TSTB CHECK FOR OVERFLOW  
          BNE  L8BFF          BRANCH IF OVERFLOW 
          LDA  ,S             * GET NIBBLE COUNTER, 
          DECA                * DECREMENT IT AND 
          BEQ  L8BFF          * BRANCH IF DONE 
          CMPX #STRBUF+2      DO NOT DO A CONVERSION UNTIL A NON-ZERO 
          BEQ  L8C0B          BYTE IS FOUND - LEADING ZERO SUPPRESSION 
L8BFF     ADDB #'0'           ADD IN ASCII ZERO 
          CMPB #'9'           COMPARE TO ASCII 9 
          BLS  L8C07          BRANCH IF < 9 
          ADDB #7             ADD ASCII OFFSET IF HEX LETTER 
L8C07     STB  ,X+            STORE HEX VALUE AND ADVANCE POINTER 
          CLR  ,X             CLEAR NEXT BYTE - END OF STRING FLAG 
L8C0B     PULS B              * GET NIBBLE COUNTER, 
          DECB                * DECREMENT IT AND 
          BNE  L8BE5          * BRANCH IF NOT DONE 
          LEAS $02,S          PURGE RETURN ADDRESS OFF OF STACK 
          LDX  #STRBUF+1      RESET POINTER 
          JMP  LB518          SAVE STRING ON STRING STACK 
* PROCESS EXCLAMATION POINT                      
L8E37     LDA  #$01           * SET SPACES 
          STA  VD9            * COUNTER = 1 
* PROCESS STRING ITEM - LIST                      
L8E3B     DECB                DECREMENT FORMAT STRING LENGTH COUNTER 
          JSR  L8FD8          SEND A '+' TO CONSOLE OUT IF VDA <>0 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          LBEQ L8ED8          EXIT PRINT USING IF END OF LINE 
          STB  VD3            SAVE REMAINDER FORMAT STRING LENGTH 
          JSR  LB156          EVALUATE EXPRESSION 
          JSR  LB146          ‘TM’ ERROR IF NUMERIC VARIABLE 
          LDX  FPA0+2         * GET ITEM - LIST DESCRIPTOR ADDRESS 
          STX  V4D            * AND SAVE IT IN V4D 
          LDB  VD9            GET SPACES COUNTER 
          JSR  LB6AD          PUT ACCB BYTES INTO STRING SPACE & PUT DESCRIPTOR ON STRING STACK 
          JSR  LB99F          PRINT THE FORMATTED STRING TO CONSOLE OUT 
* PAD FORMAT STRING WITH SPACES IF ITEM - LIST STRING < FORMAT STRING LENGTH                      
          LDX  FPA0+2         POINT X TO FORMATTED STRING DESCRIPTOR ADDRESS 
          LDB  VD9            GET SPACES COUNTER 
          SUBB ,X             SUBTRACT LENGTH OF FORMATTED STRING 
L8E5F     DECB                DECREMENT DIFFERENCE 
          LBMI L8FB3          GO INTERPRET ANOTHER ITEM - LIST 
          JSR  LB9AC          PAD FORMAT STRING WITH A SPACE 
          BRA  L8E5F          KEEP PADDING 
* PERCENT SIGN - PROCESS A %SPACES% COMMAND                      
L8E69     STB  VD3            * SAVE THE CURRENT FORMAT STRING 
          STX  TEMPTR         * COUNTER AND POINTER 
          LDA  #$02           INITIAL SPACES COUNTER = 2 
          STA  VD9            SAVE IN SPACES COUNTER 
L8E71     LDA  ,X             GET A CHARACTER FROM FORMAT STRING 
          CMPA #'%'           COMPARE TO TERMINATOR CHARACTER 
          BEQ  L8E3B          BRANCH IF END OF SPACES COMMAND 
          CMPA #' '           BLANK 
          BNE  L8E82          BRANCH IF ILLEGAL CHARACTER 
          INC  VD9            ADD ONE TO SPACES COUNTER 
          LEAX $01,X          MOVE FORMAT POINTER UP ONE 
          DECB                DECREMENT LENGTH COUNTER 
          BNE  L8E71          BRANCH IF NOT END OF FORMAT STRING 
L8E82     LDX  TEMPTR         * RESTORE CURRENT FORMAT STRING COUNTER 
          LDB  VD3            * AND POINTER TO POSITION BEFORE SPACES COMMAND 
          LDA  #'%'           SEND A ‘%’ TO CONSOLE OUT AS A DEBUGGING AID 
* ERROR PROCESSOR - ILLEGAL CHARACTER OR BAD SYNTAX IN FORMAT STRING                      
L8E88     JSR  L8FD8          SEND A ‘+' TO CONSOLE OUT IF VDA <> 0 
          JSR  PUTCHR         SEND CHARACTER TO CONSOLE OUT 
          BRA  L8EB9          GET NEXT CHARACTER IN FORMAT STRING 
                               
* PRINT RAM HOOK                      
XVEC9     CMPA #TOK_USING     USING TOKEN 
          BEQ  L8E95          BRANCH IF PRINT USING 
          RTS                  
                               
* PRINT USING                      
* VDA IS USED AS A STATUS BYTE: BIT 6 = COMMA FORCE                      
* BIT 5=LEADING ASTERISK FORCE; BIT 4 = FLOATING $ FORCE                      
* BIT 3 = PRE SIGN FORCE; BIT 2 = POST SIGN FORCE; BIT 0 = EXPONENTIAL FORCE                      
L8E95     LEAS $02,S          PURGE RETURN ADDRESS OFF THE STACK 
          JSR  LB158          EVALUATE FORMAT STRING 
          JSR  LB146          ‘TM’ ERROR IF VARIABLE TYPE = NUMERIC 
          LDB  #';'           CHECK FOR ITEM LIST SEPARATOR 
          JSR  LB26F          SYNTAX CHECK FOR ; 
          LDX  FPA0+2         * GET FORMAT STRING DESCRIPTOR ADDRESS 
          STX  VD5            * AND SAVE IT IN VD5 
          BRA  L8EAE          GO PROCESS FORMAT STRING 
L8EA8     LDA  VD7            *CHECK NEXT PRINT ITEM FLAG AND 
          BEQ  L8EB4          *‘FC’ ERROR IF NO FURTHER PRINT ITEMS 
          LDX  VD5            RESET FORMAT STRING POINTER TO START OF STRING 
L8EAE     CLR  VD7            RESET NEXT PRINT ITEM FLAG 
          LDB  ,X             GET LENGTH OF FORMAT STRING 
          BNE  L8EB7          INTERPRET FORMAT STRING IF LENGTH > 0 
L8EB4     JMP  LB44A          ‘FC’ ERROR IF FORMAT STRING = NULL 
L8EB7     LDX  $02,X          POINT X TO START OF FORMAT STRING 
* INTERPRET THE FORMAT STRING                      
L8EB9     CLR  VDA            CLEAR THE STATUS BYTE 
L8EBB     CLR  VD9            CLEAR LEFT DIGIT COUNTER 
          LDA  ,X+            GET A CHARACTER FROM FORMAT STRING 
          CMPA #'!'           EXCLAMATION POINT? 
          LBEQ L8E37          YES - STRING TYPE FORMAT 
          CMPA #'#'           NUMBER SIGN? (DIGIT LOCATOR) 
          BEQ  L8F24          YES - NUMERIC TYPE FORMAT 
          DECB                DECREMENT FORMAT STRING LENGTH 
          BNE  L8EE2          BRANCH IF NOT DONE 
          JSR  L8FD8          SEND A ‘+‘ TO CONSOLE OUT IF VDA <> 0 
          JSR  PUTCHR         SEND CHARACTER TO CONSOLE OUT 
L8ED2     JSR  GETCCH         GET CURRENT CHARACTER FROM BASIC 
          BNE  L8EA8          BRANCH IF NOT END OF LINE 
          LDA  VD7            GET NEXT PRINT ITEM FLAG 
L8ED8     BNE  L8EDD          BRANCH IF MORE PRINT ITEMS 
          JSR  LB958          SEND A CARRIAGE RETURN TO CONSOLE OUT 
L8EDD     LDX  VD5            POINT X TO FORMAT STRING DESCRIPTOR 
          JMP  LB659          RETURN ADDRESS AND LENGTH OF FORMAT STRING - EXIT PRINT USING 
L8EE2     CMPA #'+'           CHECK FOR ‘+‘ (PRE-SIGN FORCE) 
          BNE  L8EEF          NO PLUS 
          JSR  L8FD8          SEND A ‘+' TO CONSOLE OUT IF VDA <> 0 
          LDA  #$08           * LOAD THE STATUS BYTE WITH 8; 
          STA  VDA            * PRE-SIGN FORCE FLAG 
          BRA  L8EBB          INTERPRET THE REST OF THE FORMAT STRING 
L8EEF     CMPA #'.'           DECIMAL POINT? 
          BEQ  L8F41          YES 
          CMPA #'%'           PERCENT SIGN? 
          LBEQ L8E69          YES 
          CMPA ,X             COMPARE THE PRESENT FORMAT STRING INPUT 
*              CHARACTER TO THE NEXT ONE IN THE STRING  
L8EFB     BNE  L8E88          NO MATCH - ILLEGAL CHARACTER 
* TWO CONSECUTIVE EQUAL CHARACTERS IN FORMAT STRING                      
          CMPA #'$'           DOLLAR SIGN? 
          BEQ  L8F1A          YES - MAKE THE DOLLAR SIGN FLOAT 
          CMPA #'*'           ASTERISK? 
          BNE  L8EFB          NO - ILLEGAL CHARACTER 
          LDA  VDA            * GRAB THE STATUS BYTE AND BET BIT 5 
          ORA  #$20           * TO INDICATE THAT THE OUTPUT WILL 
          STA  VDA            * BE LEFT PADDED WITH ASTERISKS 
          CMPB #2             * CHECK TO SEE IF THE $$ ARE THE LAST TWO 
          BLO  L8F20          * CHARACTERS IN THE FORMAT STRING AND BRANCH IF SO 
          LDA  $01,X          GET THE NEXT CHARACTER AFTER ** 
          CMPA #'$'           CHECK FOR **$ 
          BNE  L8F20          CHECK FOR MORE CHARACTERS 
          DECB                DECREMENT STRING LENGTH COUNTER 
          LEAX $01,X          MOVE FORMAT STRING POINTER UP ONE 
          INC  VD9            ADD ONE TO LEFT DIGIT COUNTER - FOR ASTERISK PAD AND 
*              FLOATING DOLLAR SIGN COMBINATION  
L8F1A     LDA  VDA            * GET THE STATUS BYTE AND SET 
          ORA  #$10           * BIT 4 TO INDICATE A 
          STA  VDA            * FLOATING DOLLAR SIGN 
L8F20     LEAX $01,X          MOVE FORMAT STRING POINTER UP ONE 
          INC  VD9            ADD ONE TO LEFT DIGIT (FLOATING $ OR ASTERISK PAD) 
* PROCESS CHARACTERS TO THE LEFT OF THE DECIMAL POINT IN THE FORMAT STRING                      
L8F24     CLR  VD8            CLEAR THE RIGHT DIGIT COUNTER 
L8F26     INC  VD9            ADD ONE TO LEFT DIGIT COUNTER 
          DECB                DECREMENT FORMAT STRING LENGTH COUNTER 
          BEQ  L8F74          BRANCH IF END OF FORMAT STRING 
          LDA  ,X+            GET THE NEXT FORMAT CHARACTER 
          CMPA #'.'           DECIMAL POINT? 
          BEQ  L8F4F          YES 
          CMPA #'#'           NUMBER SIGN? 
          BEQ  L8F26          YES 
          CMPA #','           COMMA? 
          BNE  L8F5A          NO 
          LDA  VDA            * GET THE STATUS BYTE 
          ORA  #$40           * AND SET BIT 6 WHICH IS THE 
          STA  VDA            * COMMA SEPARATOR FLAG 
          BRA  L8F26          PROCESS MORE CHARACTERS TO LEFT OF DECIMAL POINT 
* PROCESS DECIMAL POINT IF NO DIGITS TO LEFT OF IT                      
L8F41     LDA  ,X             GET NEXT FORMAT CHARACTER 
          CMPA #'#'           IS IT A NUMBER SIGN? 
          LBNE L8E88          NO 
          LDA  #1             * SET THE RIGHT DIGIT COUNTER TO 1 - 
          STA  VD8            * ALLOW ONE SPOT FOR DECIMAL POINT 
          LEAX $01,X          MOVE FORMAT POINTER UP ONE 
* PROCESS DIGITS TO RIGHT OF DECIMAL POINT                      
L8F4F     INC  VD8            ADD ONE TO RIGHT DIGIT COUNTER 
          DECB                DECREMENT FORMAT LENGTH COUNTER 
          BEQ  L8F74          BRANCH IF END OF FORMAT STRING 
          LDA  ,X+            GET A CHARACTER FROM FORMAT STRING 
          CMPA #'#'           IS IT NUMBER SIGN? 
          BEQ  L8F4F          YES - KEEP CHECKING 
* CHECK FOR EXPONENTIAL FORCE                      
L8F5A     CMPA #$5E           CHECK FOR UP ARROW 
          BNE  L8F74          NO UP ARROW 
          CMPA ,X             IS THE NEXT CHARACTER AN UP ARROW? 
          BNE  L8F74          NO 
          CMPA $01,X          AND THE NEXT CHARACTER? 
          BNE  L8F74          NO 
          CMPA $02,X          HOW ABOUT THE 4TH CHARACTER? 
          BNE  L8F74          NO, ALSO 
          CMPB #4             * CHECK TO SEE IF THE 4 UP ARROWS ARE IN THE 
          BLO  L8F74          * FORMAT STRING AND BRANCH IF NOT 
          SUBB #4             * MOVE POINTER UP 4 AND SUBTRACT 
          LEAX $04,X          * FOUR FROM LENGTH 
          INC  VDA INCREMENT STATUS BYTE - EXPONENTIAL FORM  
                               
* CHECK FOR A PRE OR POST - SIGN FORCE AT END OF FORMAT STRING                      
L8F74     LEAX $-01,X         MOVE POINTER BACK ONE 
          INC  VD9            ADD ONE TO LEFT DIGIT COUNTER FOR PRE-SIGN FORCE 
          LDA  VDA            * PRE-SIGN 
          BITA #$08           * FORCE AND 
          BNE  L8F96          * BRANCH IF SET 
          DEC  VD9            DECREMENT LEFT DIGIT — NO PRE-SIGN FORCE 
          TSTB * CHECK LENGTH COUNTER AND BRANCH  
          BEQ  L8F96          * IF END OF FORMAT STRING 
          LDA  ,X             GET NEXT FORMAT STRING CHARACTER 
          SUBA #'-'           CHECK FOR MINUS SIGN 
          BEQ  L8F8F          BRANCH IF MINUS SIGN 
          CMPA #$FE           * WAS CMPA #('+')-('-') 
          BNE  L8F96          BRANCH IF NO PLUS SIGN 
          LDA  #$08           GET THE PRE-SIGN FORCE FLAG 
L8F8F     ORA  #$04           ‘OR’ IN POST-SIGN FORCE FLAG 
          ORA  VDA            ‘OR’ IN THE STATUS BYTE 
          STA  VDA            SAVE THE STATUS BYTE 
          DECB                DECREMENT FORMAT STRING LENGTH 
                               
* EVALUATE NUMERIC ITEM-LIST                      
L8F96     JSR  GETCCH         GET CURRENT CHARACTER 
          LBEQ L8ED8          BRANCH IF END OF LINE 
          STB  VD3            SAVE FORMAT STRING LENGTH WHEN FORMAT EVALUATION ENDED 
          JSR  LB141          EVALUATE EXPRESSION 
          LDA  VD9            GET THE LEFT DIGIT COUNTER 
          ADDA VD8            ADD IT TO THE RIGHT DIGIT COUNTER 
          CMPA #17            * 
          LBHI LB44A          *‘FC’ ERROR IF MORE THAN 16 DIGITS AND DECIMAL POiNT 
          JSR  L8FE5          CONVERT ITEM-LIST TO FORMATTED ASCII STRING 
          LEAX $-01,X         MOVE BUFFER POINTER BACK ONE 
          JSR  LB99C          DISPLAY THE FORMATTED STRING TO CONSOLE OUT 
L8FB3     CLR  VD7            RESET NEXT PRINT ITEM FLAG 
          JSR  GETCCH         GET CURRENT INPUT CHARACTER 
          BEQ  L8FC6          BRANCH IF END OF LINE 
          STA  VD7            SAVE CURRENT CHARACTER (<>0) IN NEXT PRINT ITEM FLAG 
          CMPA #';'           * CHECK FOR ; - ITEM-LIST SEPARATOR AND 
          BEQ  L8FC4          * BRANCH IF SEMICOLON 
          JSR  LB26D          SYNTAX CHECK FOR COMMA 
          BRA  L8FC6          PROCESS NEXT PRINT ITEM 
L8FC4     JSR  GETNCH         GET NEXT INPUT CHARACTER 
L8FC6     LDX  VD5            GET FORMAT STRING DESCRIPTOR ADDRESS 
          LDB  ,X             GET LENGTH OF FORMAT STRING 
          SUBB VD3            SUBTRACT AMOUNT OF FORMAT STRING LEFT AFTER LAST PRINT ITEM 
          LDX  $02,X          *GET FORMAT STRING START ADDRESS AND ADVANCE 
          ABX  *POINTER TO START OF UNUSED FORMAT STRING  
          LDB  VD3            * GET AMOUNT OF UNUSED FORMAT STRING 
          LBNE L8EB9          * REINTERPRET FORMAT STRING FROM THAT POINT 
          JMP  L8ED2          REINTERPRET FORMAT STRING FROM THE START IF ENTIRELY 
*         USED ON LAST PRINT ITEM  
                               
* PRINT A ‘+‘ TO CONSOLE OUT IF THE STATUS BYTE <> 0                      
L8FD8     PSHS A              RESTORE ACCA AND RETURN 
          LDA  #'+'           GET ASCII PLUS SIGN 
          TST  VDA            * CHECK THE STATUS BYTE AND 
          BEQ  L8FE3          * RETURN IF = 0 
          JSR  PUTCHR         SEND A CHARACTER TO CONSOLE OUT 
L8FE3     PULS A,PC           RETURN ACCA AND RETURN 
                               
* CONVERT ITEM-LIST TO DECIMAL ASCII STRING                      
L8FE5     LDU  #STRBUF+4      POINT U TO STRING BUFFER 
          LDB  #SPACE         BLANK 
          LDA  VDA            * GET THE STATUS FLAG AND 
          BITA #$08           * CHECK FOR A PRE-SIGN FORCE 
          BEQ  L8FF2          * BRANCH IF NO PRE-SIGN FORCE 
          LDB  #'+'           PLUS SIGN 
L8FF2     TST  FP0SGN         CHECK THE SIGN OF FPA0 
          BPL  L8FFA          BRANCH IF POSITIVE 
          CLR  FP0SGN         FORCE FPA0 SIGN TO BE POSITIVE 
          LDB  #'-'           MINUS SIGN 
L8FFA     STB  ,U+            SAVE THE SIGN IN BUFFER 
          LDB  #'0'           * PUT A ZERO INTO THE BUFFER 
          STB  ,U+            * 
          ANDA #$01           * CHECK THE EXPONENTIAL FORCE FLAG IN 
          LBNE L910D          * THE STATUS BYTE - BRANCH IF ACTIVE 
          LDX  #LBDC0         POINT X TO FLOATING POINT 1E + 09 
          JSR  LBCA0          COMPARE FPA0 TO (X) 
          BMI  L9023          BRANCH IF FPA0 < 1E+09 
          JSR  LBDD9          CONVERT FP NUMBER TO ASCII STRING 
L9011     LDA  ,X+            * ADVANCE POINTER TO END OF 
          BNE  L9011          * ASCII STRING (ZERO BYTE) 
L9015     LDA  ,-X            MOVE THE 
          STA  $01,X          ENTIRE STRING 
          CMPX #STRBUF+3      UP ONE 
          BNE  L9015          BYTE 
          LDA  #'%'           * INSERT A % SIGN AT START OF 
          STA  ,X             * STRING - OVERFLOW ERROR 
          RTS                  
                               
L9023     LDA  FP0EXP         GET EXPONENT OF FPA0 
          STA  V47            AND SAVE IT IN V74 
          BEQ  L902C          BRANCH IF FPA0 = 0 
          JSR  L91CD          CONVERT FPA0 TO NUMBER WITH 9 SIGNIFICANT 
*              PLACES TO LEFT OF DECIMAL POINT  
L902C     LDA  V47            GET BASE 10 EXPONENT OFFSET 
          LBMI L90B3          BRANCH IF FPA0 < 100,000,000 
          NEGA                * CALCULATE THE NUMBER OF LEADING ZEROES TO INSERT - 
          ADDA VD9            * SUBTRACT BASE 10 EXPONENT OFFSET AND 9 (FPA0 HAS 
          SUBA #$09           * 9 PLACES TO LEFT OF EXPONENT) FROM LEFT DIGIT COUNTER 
          JSR  L90EA          PUT ACCA ZEROES IN STRING BUFFER 
          JSR  L9263          INITIALIZE DECIMAL POINT AND COMMA COUNTERS 
          JSR  L9202          CONVERT FPA0 TO DECIMAL ASCII IN THE STRING BUFFER 
          LDA  V47            * GET BASE 10 EXPONENT AND PUT THAT MANY 
          JSR  L9281          * ZEROES IN STRING BUFFER - STOP AT DECIMAL POINT 
          LDA  V47            WASTED INSTRUCTION - SERVES NO PURPOSE 
          JSR  L9249          CHECK FOR DECIMAL POINT 
          LDA  VD8            GET THE RIGHT DIGIT COUNTER 
          BNE  L9050          BRANCH IF RIGHT DIGlT COUNTER <> 0 
          LEAU $-01,U         * MOVE BUFFER POINTER BACK ONE - DELETE 
*              * DECIMAL POINT IF NO RIGHT DIGITS SPECiFIED  
L9050     DECA                SUBTRACT ONE (DECIMAL POINT) 
          JSR  L90EA          PUT ACCA ZEROES INTO BUFFER (TRAILING ZEROES) 
L9054     JSR  L9185          INSERT ASTERISK PADDING, FLOATING $, AND POST-SIGN 
          TSTA                WAS THERE A POST-SIGN? 
          BEQ  L9060          NO 
          CMPB #'*'           IS THE FIRST CHARACTER AN $? 
          BEQ  L9060          YES 
          STB  ,U+            STORE THE POST-SIGN 
L9060     CLR  ,U             CLEAR THE LAST CHARACTER IN THE BUFFER 
*                              
* REMOVE ANY EXTRA BLANKS OR ASTERISKS FROM THE                      
* STRING BUFFER TO THE LEFT OF THE DECIMAL POINT                      
          LDX  #STRBUF+3 POINT X TO THE START OF THE BUFFER  
L9065     LEAX $01,X          MOVE BUFFER POINTER UP ONE 
          STX  TEMPTR         SAVE BUFFER POINTER IN TEMPTR 
          LDA  VARPTR+1       * GET ADDRESS OF DECIMAL POINT IN BUFFER, SUBTRACT 
          SUBA TEMPTR+1       * CURRENT POSITION AND SUBTRACT LEFT DIGIT COUNTER - 
          SUBA VD9            * THE RESULT WILL BE ZERO WHEN TEMPTR+1 IS POINTING 
*              * TO THE FIRST DIGIT OF THE FORMAT STRING  
          BEQ  L90A9          RETURN IF NO DIGITS TO LEFT OF THE DECiMAL POINT 
          LDA  ,X             GET THE CURRENT BUFFER CHARACTER 
          CMPA #SPACE         SPACE? 
          BEQ  L9065          YES - ADVANCE POINTER 
          CMPA #'*'           ASTERISK? 
          BEQ  L9065          YES - ADVANCE POINTER 
          CLRA                A ZERO ON THE STACK IS END OF DATA POINTER 
L907C     PSHS A              PUSH A CHARACTER ONTO THE STACK 
          LDA  ,X+            GET NEXT CHARACTER FROM BUFFER 
          CMPA #'-'           MINUS SIGN? 
          BEQ  L907C          YES 
          CMPA #'+'           PLUS SIGN? 
          BEQ  L907C          YES 
          CMPA $'$'           DOLLAR SIGN? 
          BEQ  L907C          YES 
          CMPA #'0'           ZERO? 
          BNE  L909E          NO - ERROR 
          LDA  $01,X          GET CHARACTER FOLLOWING ZERO 
          BSR  L90AA          CLEAR CARRY IF NUMERIC 
          BLO  L909E          BRANCH IF NOT A NUMERIC CHARACTER - ERROR 
L9096     PULS A              * PULL A CHARACTER OFF OF THE STACK 
          STA  ,-X            * AND PUT IT BACK IN THE STRING BUFFER 
          BNE  L9096          * KEEP GOING UNTIL ZERO FLAG 
          BRA  L9065          KEEP CLEANING UP THE INPUT BUFFER 
L909E     PULS A               
          TSTA                * THE STACK AND EXIT WHEN 
          BNE  L909E          * ZERO FLAG FOUND 
          LDX  TEMPTR         GET THE STRING BUFFER START POINTER 
          LDA  #'%'           * PUT A % SIGN BEFORE THE ERROR POSITION TO 
          STA  ,-X            * INDICATE AN ERROR 
L90A9     RTS                  
*                              
* CLEAR CARRY IF NUMERIC                      
L90AA     CMPA #'0'           ASCII ZERO 
          BLO  L90B2          RETURN IF ACCA < ASCII 0 
          SUBA #$3A           *  #'9'+1 
          SUBA #$C6           * #-('9'+1)  CARRY CLEAR IF NUMERIC 
L90B2     RTS                  
*                              
* PROCESS AN ITEM-LIST WHICH IS < 100,000,000                      
L90B3     LDA  VD8            GET RIGHT DIGIT COUNTER 
          BEQ  L90B8          BRANCH IF NO FORMATTED DIGITS TO THE RIGHT OF DECIMAL PT 
          DECA                SUBTRACT ONE FOR DECIMAL POINT 
L90B8     ADDA V47            *ADD THE BASE 10 EXPONENT OFFSET - ACCA CONTAINS THE 
*         *NUMBER OF SHIFTS REQUIRED TO ADJUST FPA0 TO THE SPECIFIED  
*         *NUMBER OF DlGITS TO THE RIGHT OF THE DECIMAL POINT  
          BMI  L90BD          IF ACCA >= 0 THEN NO SHIFTS ARE REQUIRED 
          CLRA                FORCE SHIFT COUNTER = 0 
L90BD     PSHS A              SAVE INITIAL SHIFT COUNTER ON THE STACK 
L90BF     BPL  L90CB          EXIT ROUTINE IF POSITIVE 
          PSHS A              SAVE SHIFT COUNTER ON STACK 
          JSR  LBB82          DIVIDE FPA0 BY 10 - SHIFT ONE DIGIT TO RIGHT 
          PULS A              GET SHIFT COUNTER FROM THE STACK 
          INCA                BUMP SHIFT COUNTER UP BY ONE 
          BRA  L90BF          CHECK FOR FURTHER DIVISION 
L90CB     LDA  V47            * GET BASE 10 EXPONENT OFFSET, ADD INITIAL SHIFT COUNTER 
          SUBA ,S+            * AND SAVE NEW BASE 10 EXPONENT OFFSET - BECAUSE 
          STA  V47            * FPA0 WAS SHIFTED ABOVE 
          ADDA #$09           * ADD NINE (SIGNIFICANT PLACES) AND BRANCH IF THERE ARE NO 
          BMI  L90EE          * ZEROES TO THE LEFT OF THE DECIMAL POINT IN THIS PRINT ITEM 
          LDA  VD9            *DETERMINE HOW MANY FILLER ZEROES TO THE LEFT OF THE DECIMAL 
          SUBA #$09           *POINT. GET THE NUMBER OF FORMAT PLACES TO LEFT OF DECIMAL 
          SUBA V47            *POINT, SUBTRACT THE BASE 10 EXPONENT OFFSET AND THE CONSTANT 9 
          BSR  L90EA          *(UNNORMALIZATION)-THEN OUTPUT THAT MANY ZEROES TO THE BUFFER 
          JSR  L9263          INITIALIZE DECIMAL POINT AND COMMA COUNTERS 
          BRA  L90FF          PROCESS THE REMAINDER OF THE PRINT ITEM 
*                              
* PUT (ACCA+1) ASCII ZEROES IN BUFFER                      
L90E2     PSHS A              SAVE ZERO COUNTER 
          LDA  #'0'           * INSERT A ZERO INTO 
          STA  ,U+            * THE BUFFER 
          PULS A              RESTORE ZERO COUNTER 
                               
* PUT ACCA ASCII ZEROES INTO THE BUFFER                      
L90EA     DECA                DECREMENT ZERO COUNTER 
          BPL  L90E2          BRANCH IF NOT DONE 
          RTS                  
                               
L90EE     LDA  VD9            * GET THE LEFT DIGIT COUNTER AND PUT 
          BSR  L90EA          * THAT MANY ZEROES IN THE STRiNG BUFFER 
          JSR  L924D          PUT THE DECIMAL POINT IN THE STRING BUFFER 
          LDA  #-9            *DETERMINE HOW MANY FILLER ZEROES BETWEEN THE DECIMAL POINT 
          SUBA V47            *AND SIGNIFICANT DATA. SUBTRACT BASE 10 EXPONENT FROM -9 
          BSR  L90EA          *(UNNORMALIZATION) AND OUTPUT THAT MANY ZEROES TO BUFFER 
          CLR  V45            CLEAR THE DECIMAL POINT COUNTER - SUPPRESS THE DECIMAL POINT 
          CLR  VD7            CLEAR THE COMMA COUNTER - SUPPRESS COMMAS 
L90FF     JSR  L9202          DECODE FPA0 INTO A DECIMAL ASCII STRING 
          LDA  VD8            GET THE RIGHT DIGIT COUNTER 
          BNE  L9108          BRANCH IF RIGHT DIGIT COUNTER <> 0 
          LDU  VARPTR         RESET BUFFER PTR TO THE DECIMAL POINT IF NO DIGITS TO RIGHT 
L9108     ADDA V47            *ADD BASE 10 EXPONENT - A POSITIVE ACCA WILL CAUSE THAT MANY 
* *FILLER ZEROES TO BE OUTPUT TO THE RIGHT OF LAST SIGNIFICANT DATA                      
*         *SIGNIFICANT DATA            
          LBRA L9050          INSERT LEADING ASTERISKS, FLOATING DOLLAR SIGN, ETC 
*                              
* FORCE THE NUMERIC OUTPUT FORMAT TO BE EXPONENTIAL FORMAT                      
L910D     LDA  FP0EXP         * GET EXPONENT OF FPA0 AND 
          PSHS A              * SAVE IT ON THE STACK 
          BEQ  L9116          BRANCH IF FPA0 = 0 
          JSR  L91CD          *CONVERT FPA0 INTO A NUMBER WITH 9 SIGNIFICANT 
*         *DIGITS TO THE LEFT OF THE DECIMAL POINT  
L9116     LDA  VD8            GET THE RIGHT DIGIT COUNTER 
          BEQ  L911B          BRANCH IF NO FORMATTED DIGITS TO THE RIGHT 
          DECA                SUBTRACT ONE FOR THE DECIMAL POINT 
L911B     ADDA VD9            ADD TO THE LEFT DIGIT COUNTER 
          CLR  STRBUF+3       CLEAR BUFFER BYTE AS TEMPORARY STORAGE LOCATION 
          LDB  VDA            * GET THE STATUS BYTE FOR A 
          ANDB #$04           * POST-BYTE FORCE; BRANCH IF 
          BNE  L9129          * A POST-BYTE FORCE 
          COM  STRBUF+3       TOGGLE BUFFER BYTE TO -1 IF NO POST-BYTE FORCE 
L9129     ADDA STRBUF+3       SUBTRACT 1 IF NO POST BYTE FORCE 
          SUBA #$09           *SUBTRACT 9 (DUE TO THE CONVERSION TO 9 
*         *SIGNIFICANT DIGITS TO LEFT OF DECIMAL POINT)  
          PSHS A              * SAVE SHIFT COUNTER ON THE STACK - ACCA CONTAINS THE NUMBER 
*         OF   SHIFTS REQUIRED TO ADJUST FPA0 FOR THE NUMBER OF  
*         FORMATTED PLACES TO THE RIGHT OF THE DECIMAL POINT.  
L9130     BPL  L913C          NO MORE SHIFTS WHEN ACCA >= 0 
          PSHS A              SAVE SHIFT COUNTER 
          JSR  LBB82          DIVIDE FPA0 BY 10 - SHIFT TO RIGHT ONE 
          PULS A              RESTORE THE SHIFT COUNTER 
          INCA                ADD 1 TO SHIFT COUNTER 
          BRA  L9130          CHECK FOR FURTHER SHIFTING (DIVISION) 
L913C     LDA  ,S             *GET THE INITIAL VALUE OF THE SHIFT COUNTER 
          BMI  L9141          *AND BRANCH IF SHIFTING HAS TAKEN PLACE 
          CLRA                RESET ACCA IF NO SHIFTING HAS TAKEN PLACE 
L9141     NEGA                *CALCULATE THE POSITION OF THE DECIMAL POINT BY 
          ADDA VD9            *NEGATING SHIFT COUNTER, ADDING THE LEFT DIGIT COUNTER 
          INCA                *PLUS ONE AND THE POST-BYTE POSlTION, IF USED 
          ADDA STRBUF+3       * 
          STA  V45            SAVE DECIMAL POINT COUNTER 
          CLR  VD7            CLEAR COMMA COUNTER - NO COMMAS INSERTED 
          JSR  L9202          CONVERT FPA0 INTO ASCII DECIMAL STRING 
          PULS A              * GET THE INITIAL VALUE OF SHIFT COUNTER AND 
          JSR  L9281          * INSERT THAT MANY ZEROES INTO THE BUFFER 
          LDA  VD8            *GET THE RIGHT DIGIT COUNTER AND BRANCH 
          BNE  L915A          *IF NOT ZERO 
          LEAU $-01,U         MOVE BUFFER POINTER BACK ONE 
                               
* CALCULATE VALUE OF EXPONENT AND PUT IN STRING BUFFER                      
L915A     LDB  ,S+            GET ORIGINAL EXPONENT OF FPA0 
          BEQ  L9167          BRANCH IF EXPONENT = 0 
          LDB  V47            GET BASE 10 EXPONENT 
          ADDB #$09           ADD 9 FOR 9 SIGNIFICANT DIGIT CONVERSION 
          SUBB VD9            SUBTRACT LEFT DIGIT COUNTER 
          SUBB STRBUF+3       ADD ONE TO EXPONENT IF POST-SIGN FORCE 
L9167     LDA  #'+'           PLUS SIGN 
          TSTB TEST EXPONENT   
          BPL  L916F          BRANCH IF POSITIVE EXPONENT 
          LDA  #'-'           MINUS SIGN 
          NEGB                CONVERT EXPONENT TO POSITIVE NUMBER 
L916F     STA  $01,U          PUT SIGN OF EXPONENT IN STRING BUFFER 
          LDA  #'E'           * PUT AN ‘E’ (EXPONENTIATION FLAG) IN 
          STA  ,U++           * BUFFER AND SKIP OVER THE SIGN 
          LDA  #$2F           * WAS LDA #'0'-1 
*CONVERT BINARY EXPONENT IN ACCB TO ASCII VALUE IN ACCA                      
L9177     INCA                ADD ONE TO TENS DIGIT COUNTER 
          SUBB #10            *SUBTRACT 10 FROM EXPONENT AND ADD ONE TO TENS 
          BCC  L9177          * DIGIT IF NO CARRY. TENS DIGIT DONE IF THERE IS A CARRY 
          ADDB #$3A           WAS ADDB #'9'+1 
          STD  ,U++           SAVE EXPONENT IN BUFFER 
          CLR  ,U             CLEAR FINAL BYTE IN BUFFER - PRINT TERMINATOR 
          JMP  L9054          INSERT ASTERISK PADDING, FLOATING DOLLAR SIGN, ETC. 
                               
* INSERT ASTERISK PADDING, FLOATING $ AND PRE-SIGN                      
L9185     LDX  #STRBUF+4      POINT X TO START OF PRINT ITEM BUFFER 
          LDB  ,X             * GET SIGN BYTE OF ITEM-LIST BUFFER 
          PSHS B              * AND SAVE IT ON THE STACK 
          LDA  #SPACE         DEFAULT PAD WITH BLANKS 
          LDB  VDA            * GET STATUS BYTE AND CHECK FOR 
          BITB #$20           * ASTERISK LEFT PADDING 
          PULS B              GET SIGN BYTE AGAIN 
          BEQ  L919E          BRANCH IF NO PADDING 
          LDA  #'*'           PAD WITH ASTERISK 
          CMPB #SPACE         WAS THE FIRST BYTE A BLANK (POSITIVE)? 
          BNE  L919E          NO 
          TFR  A,B            TRANSFER PAD CHARACTER TO ACCB 
L919E     PSHS B              SAVE FIRST CHARACTER ON STACK 
L91A0     STA  ,X+            STORE PAD CHARACTER IN BUFFER 
          LDB  ,X             GET NEXT CHARACTER IN BUFFER 
          BEQ  L91B6          INSERT A ZERO IF END OF BUFFER 
          CMPB #'E'           * CHECK FOR AN ‘E’ AND 
          BEQ  L91B6          * PUT A ZERO BEFORE IT 
          CMPB #'0'           * REPLACE LEADING ZEROES WITH 
          BEQ  L91A0          * PAD CHARACTERS 
          CMPB #','           * REPLACE LEADING COMMAS 
          BEQ  L91A0          * WITH PAD CHARACTERS 
          CMPB #'.'           * CHECK FOR DECIMAL POINT 
          BNE  L91BA          * AND DON’T PUT A ZERO BEFORE IT 
L91B6     LDA  #'0'           * REPLACE PREVIOUS CHARACTER 
          STA  ,-X            * WITH A ZERO 
L91BA     LDA  VDA            * GET STATUS BYTE, CHECK 
          BITA #$10           * FOR FLOATING $ 
          BEQ  L91C4          * BRANCH IF NO FLOATING $ 
          LDB  #'$'           * STORE A $ IN 
          STB  ,-X            * BUFFER 
L91C4     ANDA #$04           CHECK PRE-SIGN FLAG 
          PULS B              GET SIGN CHARACTER 
          BNE  L91CC          RETURN IF POST-SIGN REQUIRED 
          STB  ,-X            STORE FIRST CHARACTER 
L91CC     RTS                  
*                              
* CONVERT FPA0 INTO A NUMBER OF THE FORM - NNN,NNN,NNN X 10**M.                      
* THE EXPONENT M WILL BE RETURNED IN V47 (BASE 10 EXPONENT).                      
L91CD     PSHS U              SAVE BUFFER POINTER 
          CLRA                INITIAL EXPONENT OFFSET = 0 
L91D0     STA  V47            SAVE EXPONENT OFFSET 
          LDB  FP0EXP         GET EXPONENT OF FPA0 
          CMPB #$80           * COMPARE TO EXPONENT OF .5 
          BHI  L91E9          * AND BRANCH IF FPA0 > = 1.0 
                               
* IF FPA0 < 1.0, MULTIPLY IT BY 1E+09 UNTIL IT IS >= 1                      
          LDX  #LBDC0         POINT X TO FP NUMBER (1E+09) 
          JSR  LBACA          MULTIPLY FPA0 BY 1E+09 
          LDA  V47            GET EXPONENT OFFSET 
          SUBA #$09           SUBTRACT 9 (BECAUSE WE MULTIPLIED BY 1E+09 ABOVE) 
          BRA  L91D0          CHECK TO SEE IF > 1.0 
L91E4     JSR  LBB82          DIVIDE FPA0 BY 10 
          INC  V47            INCREMENT EXPONENT OFFSET 
L91E9     LDX  #LBDBB         POINT X TO FP NUMBER (999,999,999) 
          JSR  LBCA0          COMPARE FPA0 TO X 
          BGT  L91E4          BRANCH IF FPA0 > 999,999,999 
L91F1     LDX  #LBDB6         POINT X TO FP NUMBER (99,999,999.9) 
          JSR  LBCA0          COMPARE FPA0 TO X 
          BGT  L9200          RETURN IF 999,999,999 > FPA0 > 99,999,999.9 
          JSR  LBB6A          MULTIPLY FPA0 BY 10 
          DEC  V47            DECREMENT EXPONENT OFFSET 
          BRA  L91F1          KEEP UNNORMALIZING 
L9200     PULS U,PC           RESTORE BUFFER POINTER AND RETURN 
*                              
* CONVERT FPA0 INTO AN INTEGER, THEN DECODE IT                      
* INTO A DECIMAL ASCII STRING IN THE BUFFER                      
L9202     PSHS U              SAVE BUFFER POINTER 
          JSR  LB9B4          ADD .5 TO FPA0 (ROUND OFF) 
          JSR  LBCC8          CONVERT FPA0 TO INTEGER FORMAT 
          PULS U              RESTORE BUFFER POINTER 
*                              
* CONVERT FPA0 INTO A DECIMAL ASCII STRING                      
          LDX  #LBEC5         POINT X TO UNNORMALIZED POWERS OF 10 
          LDB  #$80           INITIALIZE DIGIT COUNTER TO 0 + $80. 
* BIT 7 SET IS USED TO INDICATE THAT THE POWER OF 10 MANTISSA                      
* IS NEGATIVE. WHEN YOU ‘ADD’ A NEGATIVE MANTISSA, IT IS                      
* THE SAME AS SUBTRACTING A POSITIVE ONE AND BIT 7 OF ACCB                      
* IS HOW THIS ROUTINE KNOWS THAT A ‘SUBTRACTION’ IS OCCURRING.                      
L9211     BSR  L9249          CHECK FOR COMMA INSERTION 
L9213     LDA  FPA0+3         * ‘ADD’ A POWER OF 10 MANTISSA TO FPA0. 
          ADDA $03,X          * IF THE MANTISSA IS NEGATIVE, A SUBTRACTION 
          STA  FPA0+3         * WILL BE WHAT REALLY TAKES PLACE. 
          LDA  FPA0+2         * 
          ADCA $02,X          * 
          STA  FPA0+2         * 
          LDA  FPA0+1         * 
          ADCA $01,X          * 
          STA  FPA0+1         * 
          LDA  FPA0           * 
          ADCA ,X             * 
          STA  FPA0           * 
          INCB                ADD ONE TO DIGIT COUNTER 
          RORB ROTATE CARRY INTO BIT 7  
          ROLB                * SET OVERFLOW FLAG - BRANCH IF CARRY SET AND 
          BVC  L9213          * ADDING MANTISSA OR CARRY CLEAR AND SUBTRACTING MANTISSA 
          BCC  L9235          BRANCH IF SUBTRACTING MANTISSA 
          SUBB #10+1          WAS SUBB #10+1 
          NEGB                * IF ADDING MANTISSA 
L9235     ADDB #$2F           WAS ADDB #'0'-1 
          LEAX $04,X          MOVE TO NEXT POWER OF 10 MANTISSA 
          TFR  B,A            SAVE DIGIT IN ACCA 
          ANDA #$7F           MASK OFF ADD/SUBTRACT FLAG (BIT 7) 
          STA  ,U+            STORE DIGIT IN BUFFER 
          COMB                TOGGLE ADD/SUBTRACT FLAG 
          ANDB #$80           MASK OFF EVERYTHING BUT ADD/SUB FLAG 
          CMPX #LBEE9         COMPARE TO END OF UNNORMALIZED POWERS OF 10 
          BNE  L9211          BRANCH IF NOT DONE 
          CLR  ,U             PUT A ZERO AT END OF INTEGER 
                               
* DECREMENT DECIMAL POINT COUNTER AND CHECK FOR COMMA INSERTION                      
L9249     DEC  V45            DECREMENT DECIMAL POINT COUNTER 
          BNE  L9256          NOT TIME FOR DECIMAL POINT 
L924D     STU  VARPTR         SAVE BUFFER POINTER-POSITION OF THE DECIMAL POINT 
          LDA  #'.'           * STORE A DECIMAL 
          STA  ,U+            * POINT IN THE OUTPUT BUFFER 
          CLR  VD7            * CLEAR COMMA COUNTER - NOW IT WILL TAKE 255 
*                             * DECREMENTS BEFORE ANOTHER COMMA WILL BE INSERTED 
          RTS                  
L9256     DEC  VD7            DECREMENT COMMA COUNTER 
          BNE  L9262          RETURN IF NOT TIME FOR COMMA 
          LDA  #$03           * RESET COMMA COUNTER TO 3; THREE 
          STA  VD7            * DIGITS BETWEEN COMMAS 
          LDA  #','           * PUT A COMMA INTO 
          STA  ,U+            * THE BUFFER 
L9262     RTS                  
                               
* INITIALIZE DECIMAL POINT AND COMMA COUNTERS                      
L9263     LDA  V47            GET THE BASE 10 EXPONENT OFFSET 
          ADDA #10            * ADD 10 (FPA0 WAS ‘NORMALIZED’ TO 9 PLACES LEFT 
          STA  V45            * OF DECIMAL POINT) - SAVE IN DECIMAL POINT COUNTER 
          INCA                ADD ONE FOR THE DECIMAL POINT 
L926A     SUBA #$03           * DIVIDE DECIMAL POINT COUNTER BY 3; LEAVE 
          BCC  L926A          * THE REMAINDER IN ACCA 
          ADDA #$05           CONVERT REMAINDER INTO A NUMBER FROM 1-3 
          STA  VD7            SAVE COMMA COUNTER 
          LDA  VDA            GET STATUS BYTE 
          ANDA #$40           CHECK FOR COMMA FLAG 
          BNE  L927A          BRANCH IF COMMA FLAG ACTIVE 
          STA  VD7            CLEAR COMMA COUNTER - 255 DIGITS OUTPUT BEFORE A COMMA 
L927A     RTS                  
*                              
* INSERT ACCA ZEROES INTO THE BUFFER                      
L927B     PSHS A              SAVE ZEROES COUNTER 
          BSR  L9249          CHECK FOR DECIMAL POINT 
          PULS A              RESTORE ZEROES COUNTER 
L9281     DECA                * DECREMENT ZEROES COUNTER AND 
          BMI  L928E          * RETURN IF < 0 
          PSHS A              SAVE ZEROES COUNTER 
          LDA  #'0'           * PUT A ZERO INTO 
          STA  ,U+            * THE BUFFER 
          LDA  ,S+            RESTORE THE ZEROES COUNTER 
          BNE  L927B          BRANCH IF NOT DONE 
L928E     RTS                  
                               
                               
* LINE                         
LINE      CMPA #TOK_INPUT     ‘INPUT’ TOKEN 
          LBEQ L89C0          GO DO ‘LINE INPUT’ COMMAND 
          JMP  LB277          ‘SYNTAX ERROR’ IF NOT "LINE INPUT" 
                               
                               
* END OF EXTENDED BASIC                      
* INTERRUPT VECTORS                      
          ORG  $FFF0           
LBFF0     FDB  $0000          RESERVED 
LBFF2     FDB  SW3VEC         SWI3 
LBFF4     FDB  SW2VEC         SWI2 
LBFF6     FDB  FRQVEC         FIRQ 
LBFF8     FDB  IRQVEC         IRQ 
LBFFA     FDB  SWIVEC         SWI 
LBFFC     FDB  NMIVEC         NMI 
LBFFE     FDB  RESVEC         RESET 
