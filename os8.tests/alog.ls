
RALF V62A   12-FEB-80    PAGE 1

            /
            /
            /       A  L  O  G
            /       -  -  -  -
            /
            /SUBROUTINE     ALOG(X)
            /
            / VERSION 5A 4-26-77 (MH)
            /
--US--
--US--
00000 0000          SECT    ALOG
--US--
--US--
00001 0000          JA      #ALOG
00002 0000          0                       /WORKING SPACE FOR EXPONENT DIDDLE.
00003 0000          0
00004 0000          0
00005 0000  ALOGTM, 0
00006 0000          0
00007 0000          0
00010 0000          0
--US--
00011 0002  F2ALOG, F 2.
--EG--
00012 0001  FPI2,   1
00013 3110          3110
00014 3755          3755
            /
--US--
--US--
00015 0000          EXTERN  #ARGER
--US--
--US--
00016 0000  ALOG0,  TRAP4   #ARGER
--US--
--US--
00017 0000          JA      ALGRTN          /RETURN NOW.
            /
--US--
--US--
00020 0000          EXTERN  #ARGER
--US--
--US--
00021 0000  ALOGM1, TRAP4   #ARGER
--US--
--US--
00022 0000          JA      ALGRTN
--US--
--BX--
00023 0000          TEXT    +ALOG  +
--EG--
            ALOGXR,
--US--
00024 0000  BPALOG, F 0.0
--EG--
RALF V62A   12-FEB-80    PAGE 1-1

--US--
00025 0000  XRALOG, F 0.0
--EG--
--US--
00026 0000  ALOG1,  F 0.0
--EG--
--US--
00027 0000  ALOG2,  F 0.0
--EG--
--US--
00030 0001  F1ALOG, F 1.
--EG--
            /
00031 0000  ALOGMG, 0
00032 0000          0
00033 0013          13                      /CORRECT EXPONENT DIDDLER.
            /
            /
            /
            /
00034 0000  ALOGL1, 0
00035 3777          3777
00036 7742          7742
            /
00037 0000  ALOGE2, 0
00040 2613          2613
00041 4414          4414
            /
--US--
--RE--
00042 0054          ORG     10*3+BPALOG
--US--
00043 0000          FNOP
--US--
--RE--
00044 0024          JA      ALOGXR
00045 0000          0
--US--
--RE--
00046 0046  ALGRTN, JA      .
00047 7777  ALOGL2, 7777
00050 4000          4000
00051 4100          4100
            /
00052 7777  ALOGL3, 7777
00053 2517          2517
00054 0310          0310
            /
00055 7776  ALOGL4, 7776
00056 4113          4113
00057 7211          7211
            /
00060 7776  ALOGL5, 7776
00061 2535          2535
00062 3301          3301
            /
RALF V62A   12-FEB-80    PAGE 1-2

00063 7775  ALOGL6, 7775
00064 4746          4746
00065 0771          0771
            /
00066 7774  ALOGL7, 7774
00067 2236          2236
00070 4304          4304
            /
00071 7771  ALOGL8, 7771
00072 4544          4544
00073 1735          1735
--US--
00074 0000          BASE    0
--US--
00075 0000  #ALOG,  STARTD
--US--
00076 0030          FLDA    10*3
--US--
--RE--
00077 0046          FSTA    ALGRTN
--US--
00100 0000          FLDA    0
--US--
--RE--
00101 0025          SETX    XRALOG
--US--
--RE--
00102 0024          SETB    BPALOG
--US--
--RE--
00103 0024          BASE    BPALOG
--US--
00104 0001          LDX     1,1     
--EG--
--US--
--RE--
00105 0024          FSTA    BPALOG
--US--
00106 0000          FLDA%   BPALOG,1  /ADDR OF X
--EG--
--US--
--RE--
00107 0024          FSTA    BPALOG
--US--
00110 0000          STARTF
--US--
00111 0000          FLDA%   BPALOG  /GET X
--EG--
--US--
--RE--
00112 0016          JEQ     ALOG0   /IF  =0 THEN ERROR
--US--
--RE--
00113 0021          JLT     ALOGM1  /IF<0 THEN ERROR
--US--
--BX--
RALF V62A   12-FEB-80    PAGE 1-3

00114 0000          LDX     -1,0    /IF >0 THEN START DOING
--EG--
--US--
--RE--
00115 0026          FSTA    ALOG1           /SAVE IN A TEMP.
--US--
--RE--
00116 0030          FSUB    F1ALOG          /KNOCK OFF ONE.
--US--
--RE--
00117 0046          JEQ     ALGRTN          /IF ZERO EXIT. LOG(1)=0
--US--
--US--
00120 0000          JGE     ALOGST          /IF POSITIVE LOG>0
--US--
--RE--
00121 0030          FLDA    F1ALOG          /NEGITE. INVERT IT.
--US--
--RE--
00122 0026          FDIV    ALOG1           /BY DIVIDING INTO ONE.
--US--
--RE--
00123 0026          FSTA    ALOG1
--US--
00124 0000          LDX     0,0             /RESET SIGN TO NEGATIVE.
--EG--
--US--
--RE--
00125 0130          JA      .+3             /AVOID USELESS LOAD INSTRUCTION.
            /
--US--
--RE--
00126 0026  ALOGST, FLDA    ALOG1           /RECALL NUMBER.
--US--
--RE--
00127 0011          FDIV    F2ALOG          /CUT IN HALF.
--US--
--RE--
00130 0005          FSTA    ALOGTM          /PREPARE FOR EXPONENT DIDDLE.
--US--
--RE--
00131 0031          FLDA    ALOGMG          /SET THE EXPONENT OF THE EXPONENT TO 13.
--US--
--RE--
00132 0002          FSTA    ALOGTM-3        /SO THAT NORMALIZE WILL DO JOB.
--US--
--RE--
00133 0006          FSTA    ALOGTM+1        /AND ALSO ZERO OUT LOW ORDER POART OF EX. MANT.
--US--
--RE--
00134 0004          FLDA    ALOGTM-1        /RECALL THE NUMBER
--US--
00135 0000          FNORM                   /NORMALIZE IT.
--US--
--RE--
00136 0037          FMUL    ALOGE2          /NOW MULITPLY EXPONENT BY LOG E 2
RALF V62A   12-FEB-80    PAGE 1-4

--US--
--RE--
00137 0027          FSTA    ALOG2           /AND SAVE IT FOR A SECOND.
--US--
--RE--
00140 0026          FLDA    ALOG1           /RECALL THE NUMBER AGAIN.
--US--
--RE--
00141 0005          FSTA    ALOGTM          /STORE IN THE TEMPORARY WORKER.
--US--
--RE--
00142 0010          FLDA    FPI2-2          /RECALL WORD WITH LOW ORDER ONE.
--US--
--RE--
00143 0003          FSTA    ALOGTM-2        /STORE AWAY.
--US--
--RE--
00144 0005          FLDA    ALOGTM          /RECALL NUMBER WITH AN EXPONENT OF 1
--US--
--RE--
00145 0030          FSUB    F1ALOG          /SUBTRACT AWAY.
--US--
--RE--
00146 0026          FSTA    ALOG1           /AND STORE
--US--
--RE--
00147 0071          FMUL    ALOGL8          /MULTIPLY BY THE CONSTANT.
--US--
--RE--
00150 0066          FADD    ALOGL7          /ADD IN
--US--
--RE--
00151 0026          FMUL    ALOG1           /MULT.
--US--
--RE--
00152 0063          FADD    ALOGL6          /AND SO ON DOWN THE LINE.
--US--
--RE--
00153 0026          FMUL    ALOG1
--US--
--RE--
00154 0060          FADD    ALOGL5
--US--
--RE--
00155 0026          FMUL    ALOG1
--US--
--RE--
00156 0055          FADD    ALOGL4
--US--
--RE--
00157 0026          FMUL    ALOG1
--US--
--RE--
00160 0052          FADD    ALOGL3
--US--
--RE--
RALF V62A   12-FEB-80    PAGE 1-5

00161 0026          FMUL    ALOG1
--US--
--RE--
00162 0047          FADD    ALOGL2
--US--
--RE--
00163 0026          FMUL    ALOG1
--US--
--RE--
00164 0034          FADD    ALOGL1
--US--
--RE--
00165 0026          FMUL    ALOG1
--US--
--RE--
00166 0027          FADD    ALOG2           /CORRECT NOW.ADD IN EXPONENT.
--US--
--RE--
00167 0046          JXN     ALGRTN,0                /EXIT IF SIGN IS OK.
--EG--
--US--
00170 0000          FNEG                    /ELSE NEGATE IT.
--US--
--RE--
00171 0046          JA      ALGRTN
RALF V62A   12-FEB-80    PAGE 2

157 ERRORS 
78 SYMBOLS, NO ABS REFS 

 #ALOG    00075   #ARGER U 00000   ALGRTN   00046   ALOG   U 00000  
 ALOGE2   00037   ALOGL1   00034   ALOGL2   00047   ALOGL3   00052  
 ALOGL4   00055   ALOGL5   00060   ALOGL6   00063   ALOGL7   00066  
 ALOGL8   00071   ALOGMG   00031   ALOGM1   00021   ALOGST   00126  
 ALOGTM   00005   ALOGXR   00024   ALOG0    00016   ALOG1    00026  
 ALOG2    00027   BASE   U 00000   BPALOG   00024   EXTERN U 00000  
 F      U 00000   FADD   U 00000   FDIV   U 00000   FLDA   U 00000  
 FMUL   U 00000   FNEG   U 00000   FNOP   U 00000   FNORM  U 00000  
 FPI2     00012   FSTA   U 00000   FSUB   U 00000   F1ALOG   00030  
 F2ALOG   00011   JA     U 00000   JEQ    U 00000   JGE    U 00000  
 JLT    U 00000   JXN    U 00000   LDX    U 00000   ORG    U 00000  
 SECT   U 00000   SETB   U 00000   SETX   U 00000   STARTD U 00000  
 STARTF U 00000   TEXT   U 00000   TRAP4  U 00000   XRALOG   00025  
