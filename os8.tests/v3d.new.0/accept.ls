

BUFF    0224
BUFFPT  0225
DONE    0217
EXIT    0000EXT 
LISN    0203
MAIN    0200EXT 
MDOLAR  0226

                        ENTRY MAIN
0200  7300      MAIN,   CLA CLL
0201  1224              TAD BUFF
0202  3225              DCA BUFFPT
0203  6031      LISN,   KSF
0204  5203              JMP LISN
0205  6036              KRB
0206  6046              TLS
0207  6201 05           DCA I BUFFPT
0210  3625   
0211  1625              TAD I BUFFPT
0212  1226              TAD MDOLAR
0213  7450              SNA
0214  5217              JMP DONE
0215  2225              ISZ BUFFPT
0216  5203              JMP LISN
0217  7300      DONE,   CLA CLL
0220  6201 05           DCA I BUFFPT
0221  3625   
0222  4033              CALL 0,EXIT
0223  0002 06
0224  2000      BUFF,   2000
0225  0000      BUFFPT, 0
0226  7534      MDOLAR, 7534
                        END
