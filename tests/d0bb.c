//
// Fast C implementation of PDP-8 code.
#include <stdlib.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>

// Boilerplate startup.

// Main memory
int core[8*4096]; // As ints
typedef void (*code_t)(void);
code_t code[8*4096]; // As function pointers.

int IF = 0; // Capitalize to avoid keyword
int df = 0;
// IF is in pc, CIF sets ib.
int pc = 00200;
int npc; // Next pc
int ib = 0;
int swr = 07777;
int hlt = 0;
int ion = 0; // Interrupts are off
int ionn = 0; // ... and stay off
int inh = 0;
int um = 0;
int rib = 0;
int rif = 0;
// LINK is in lac.
int lac = 0;
int mq = 0;
int modeb = 0;
int sc = 0;
int gt = 0;
// I/O Devices.
int ttof = 0; // Teleprinter flag is clear
int ttofn = 0; // ... and stays clear
int ttie = 1; // Imput interrupts are enabled
int ttif = 0; // Keyboard input flag is clear
int ttit; // Input character temporary buffer
int ttib; // Input character buffer for KRS, KRB
int ttid; // Instructions until next input check
// Run-time behavior.
int interact = 0; // Not interactive
int trace = 0; // 1 iff trace output desired
int echar = 0205; // Usually ^E
// Temporaries
int skp;
int irq;

void emul8();

//
// Compiled code:
void S00000() { lac &= (010000|core[000000]);  }
void L00001() { npc = 000001; inh = 0;  }
void P00002() { lac &= (010000|core[000002]);  }
void D00003() { lac &= (010000|core[000003]);  }
void P00007() { lac &= (010000|core[000000]);  }
void D00020() { emul8();  }
void D00021() { core[(df<<12)+core[127]] = lac & 07777; lac &= 010000; code[(df<<12)+core[127]] = &emul8;  }
void D00022() { npc = (ib<<12)+core[127]; inh = 0;  }
void D00023() { emul8();  }
void D00024() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D00025() { emul8();  }
void D00026() { emul8();  }
void D00027() { emul8();  }
void P00030() { lac &= (010000|core[000000]);  }
void D00031() { emul8();  }
void D00032() { emul8();  }
void D00033() { emul8();  }
void D00034() { emul8();  }
void D00035() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P00036() { lac &= (010000|core[000000]);  }
void D00037() { lac += core[(df<<12)+core[127]];  }
void D00040() { lac &= (010000|core[(df<<12)+core[127]]);  }
void D00041() { lac &= (010000|core[000177]);  }
void P00042() { lac &= (010000|core[000177]);  }
void D00043() { lac &= (010000|core[000077]);  }
void P00044() { lac &= (010000|core[000037]);  }
void D00045() { lac &= (010000|core[000017]);  }
void P00046() { lac &= (010000|core[000007]);  }
void D00047() { lac &= (010000|core[000003]);  }
void P00050() { lac &= (010000|core[000000]);  }
void D00051() { lac &= (010000|core[000001]);  }
void L00052() { core[(ib<<12)+core[0]] = 00053; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void D00053() { core[(ib<<12)+core[127]] = 00054; npc = (ib<<12)+core[127]+1; code[(ib<<12)+core[127]] = &emul8; inh = 0;  }
void D00054() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void D00055() { emul8();  }
void D00056() { core[(ib<<12)+core[36]] = 00057; npc = (ib<<12)+core[36]+1; code[(ib<<12)+core[36]] = &emul8; inh = 0;  }
void D00057() { lac ^= 010000; lac ^= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void D00060() { lac &= (010000|core[(df<<12)+core[71]]);  }
void P00061() { npc = 000052; inh = 0;  }
void D00062() { lac += core[000111];  }
void D00063() { npc = (ib<<12)+core[109]; inh = 0;  }
void D00064() { npc = 000000; inh = 0;  }
void D00065() { lac &= (010000|core[000004]);  }
void L00070() { lac &= (010000|core[(df<<12)+core[7]]);  }
void I00071() { npc = (ib<<12)+core[58]; inh = 0;  }
void P00072() { core[(df<<12)+core[84]] = lac & 07777; lac &= 010000; code[(df<<12)+core[84]] = &emul8;  }
void L00074() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I00075() { npc = (ib<<12)+core[62]; inh = 0;  }
void P00076() { core[(df<<12)+core[76]] = lac & 07777; lac &= 010000; code[(df<<12)+core[76]] = &emul8;  }
void P00110() { lac &= (010000|core[000000]);  }
void L00120() { lac &= (010000|core[(df<<12)+core[24]]);  }
void D00121() { npc = (ib<<12)+core[82]; inh = 0;  }
void P00122() { core[(df<<12)+core[67]] = lac & 07777; lac &= 010000; code[(df<<12)+core[67]] = &emul8;  }
void P00124() { lac &= (010000|core[(df<<12)+core[40]]);  }
void P00125() { npc = (ib<<12)+core[86]; inh = 0;  }
void P00126() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void L00130() { lac &= (010000|core[(df<<12)+core[72]]);  }
void I00131() { npc = (ib<<12)+core[90]; inh = 0;  }
void P00132() { core[(df<<12)+core[49]] = lac & 07777; lac &= 010000; code[(df<<12)+core[49]] = &emul8;  }
void P00172() { lac &= (010000|core[000176]);  }
void P00173() { lac &= (010000|core[000172]);  }
void P00174() { lac &= (010000|core[000173]);  }
void P00175() { lac &= (010000|core[000174]);  }
void P00176() { lac &= (010000|core[000175]);  }
void P00177() { lac += core[000034];  }
void L00200() { lac &= 010000;  }
void I00201() { skp = 0; skp = !skp; npc += skp;  }
void D00202() { lac &= (010000|core[000000]);  }
void I00203() { lac += core[000052];  }
void I00204() { core[000377] = lac & 07777; lac &= 010000; code[000377] = &emul8;  }
void I00205() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00206() { hlt = 1;  }
void I00207() { skp = 0; skp = !skp; npc += skp;  }
void P00210() { lac &= (010000|core[000000]);  }
void I00211() { lac += core[000052];  }
void I00212() { lac ^= 07777; lac++;  }
void I00213() { lac += core[000377];  }
void I00214() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00215() { hlt = 1;  }
void I00216() { lac &= 010000;  }
void I00217() { lac += core[000053];  }
void I00220() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void I00221() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00222() { hlt = 1;  }
void I00223() { lac += core[000053];  }
void I00224() { lac ^= 07777; lac++;  }
void I00225() { lac += core[000202];  }
void I00226() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00227() { hlt = 1;  }
void I00230() { lac &= 010000;  }
void I00231() { lac += core[000020];  }
void I00232() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void I00233() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00234() { hlt = 1;  }
void I00235() { lac += core[000202];  }
void I00236() { lac ^= 07777;  }
void I00237() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00240() { hlt = 1;  }
void I00241() { lac &= 010000;  }
void I00242() { lac += core[000036];  }
void I00243() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void I00244() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00245() { hlt = 1;  }
void I00246() { lac += core[000202];  }
void I00247() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void P00250() { hlt = 1;  }
void I00251() { lac &= 010000;  }
void I00252() { lac += core[000054];  }
void I00253() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void I00254() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00255() { hlt = 1;  }
void I00256() { lac += core[000054];  }
void I00257() { lac ^= 07777; lac++;  }
void I00260() { lac += core[000202];  }
void I00261() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00262() { hlt = 1;  }
void I00263() { lac &= 010000;  }
void I00264() { lac += core[000055];  }
void I00265() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void I00266() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00267() { hlt = 1;  }
void I00270() { lac += core[000055];  }
void I00271() { lac ^= 07777; lac++;  }
void I00272() { lac += core[000202];  }
void I00273() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00274() { hlt = 1;  }
void I00275() { lac &= 010000;  }
void I00276() { lac += core[000056];  }
void I00277() { core[000377] = lac & 07777; lac &= 010000; code[000377] = &emul8;  }
void I00300() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00301() { hlt = 1;  }
void I00302() { lac += core[000056];  }
void I00303() { lac ^= 07777; lac++;  }
void I00304() { lac += core[000377];  }
void I00305() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00306() { hlt = 1;  }
void I00307() { lac &= 010000;  }
void I00310() { lac += core[000057];  }
void I00311() { core[000377] = lac & 07777; lac &= 010000; code[000377] = &emul8;  }
void I00312() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00313() { hlt = 1;  }
void I00314() { lac += core[000057];  }
void I00315() { lac ^= 07777; lac++;  }
void I00316() { lac += core[000377];  }
void I00317() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00320() { hlt = 1;  }
void I00321() { lac &= 010000;  }
void I00322() { lac += core[000060];  }
void I00323() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00324() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00325() { hlt = 1;  }
void I00326() { lac += core[000060];  }
void I00327() { lac ^= 07777; lac++;  }
void I00330() { lac += core[000000];  }
void I00331() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00332() { hlt = 1;  }
void I00333() { lac &= 010000;  }
void I00334() { lac += core[000061];  }
void I00335() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00336() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00337() { hlt = 1;  }
void I00340() { lac += core[000061];  }
void I00341() { lac ^= 07777; lac++;  }
void I00342() { lac += core[000000];  }
void I00343() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00344() { hlt = 1;  }
void I00345() { lac &= 010000;  }
void I00346() { lac += core[000062];  }
void I00347() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00350() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00351() { hlt = 1;  }
void I00352() { lac += core[000062];  }
void I00353() { lac ^= 07777; lac++;  }
void I00354() { lac += core[000000];  }
void I00355() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00356() { hlt = 1;  }
void I00357() { lac &= 010000;  }
void I00360() { lac += core[000063];  }
void I00361() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00362() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00363() { hlt = 1;  }
void I00364() { lac += core[000063];  }
void I00365() { lac ^= 07777; lac++;  }
void I00366() { lac += core[000000];  }
void I00367() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00370() { hlt = 1;  }
void I00371() { npc = 000375; inh = 0;  }
void L00372() { lac &= (010000|core[(df<<12)+core[136]]);  }
void I00373() { npc = (ib<<12)+core[252]; inh = 0;  }
void P00374() { core[(df<<12)+core[168]] = lac & 07777; lac &= 010000; code[(df<<12)+core[168]] = &emul8;  }
void L00375() {  }
void I00376() { skp = 0; skp = !skp; npc += skp;  }
void D00377() { lac &= (010000|core[000000]);  }
void I00400() { lac &= 010000;  }
void I00401() { lac += core[(df<<12)+core[34]];  }
void I00402() { lac ^= 07777; lac++;  }
void I00403() { lac += core[000177];  }
void I00404() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00405() { hlt = 1;  }
void I00406() { lac &= 010000;  }
void I00407() { skp = 0; skp = !skp; npc += skp;  }
void P00410() { lac &= (010000|core[000000]);  }
void I00411() { lac += core[000020];  }
void I00412() { lac &= (010000|core[(df<<12)+core[34]]);  }
void I00413() { lac ^= 07777; lac++;  }
void I00414() { lac += core[000177];  }
void I00415() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00416() { hlt = 1;  }
void I00417() { lac &= 010000;  }
void I00420() { lac += core[000020];  }
void I00421() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00422() { if (++core[(df<<12)+core[30]] == 010000) { core[(df<<12)+core[30]] = 0; npc++; }; code[(df<<12)+core[30]] = &emul8;  }
void I00423() { hlt = 1;  }
void I00424() { lac += core[000000];  }
void I00425() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00426() { hlt = 1;  }
void I00427() { lac &= 010000;  }
void I00430() { lac += core[(df<<12)+core[122]];  }
void I00431() { lac ^= 07777; lac++;  }
void I00432() { lac += core[000176];  }
void I00433() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00434() { hlt = 1;  }
void I00435() { lac &= 010000;  }
void I00436() { lac += core[000020];  }
void P00437() { lac &= (010000|core[(df<<12)+core[122]]);  }
void I00440() { lac ^= 07777; lac++;  }
void I00441() { lac += core[000176];  }
void I00442() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00443() { hlt = 1;  }
void I00444() { lac &= 010000;  }
void I00445() { lac += core[000172];  }
void I00446() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00447() { if (++core[(df<<12)+core[30]] == 010000) { core[(df<<12)+core[30]] = 0; npc++; }; code[(df<<12)+core[30]] = &emul8;  }
void D00450() { skp = 0; skp = !skp; npc += skp;  }
void I00451() { hlt = 1;  }
void I00452() { lac += core[000000];  }
void I00453() { lac ^= 07777; lac++;  }
void I00454() { lac += core[000172];  }
void I00455() { lac ^= 07777;  }
void I00456() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00457() { hlt = 1;  }
void I00460() { lac &= 010000;  }
void I00461() { lac += core[(df<<12)+core[123]];  }
void I00462() { lac ^= 07777; lac++;  }
void I00463() { lac += core[000172];  }
void I00464() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00465() { hlt = 1;  }
void I00466() { lac &= 010000;  }
void I00467() { lac += core[000020];  }
void I00470() { lac &= (010000|core[(df<<12)+core[123]]);  }
void I00471() { lac ^= 07777; lac++;  }
void I00472() { lac += core[000172];  }
void I00473() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00474() { hlt = 1;  }
void I00475() { lac &= 010000;  }
void I00476() { lac += core[000173];  }
void I00477() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00500() { if (++core[(df<<12)+core[30]] == 010000) { core[(df<<12)+core[30]] = 0; npc++; }; code[(df<<12)+core[30]] = &emul8;  }
void I00501() { skp = 0; skp = !skp; npc += skp;  }
void I00502() { hlt = 1;  }
void I00503() { lac += core[000000];  }
void I00504() { lac ^= 07777; lac++;  }
void I00505() { lac += core[000173];  }
void I00506() { lac ^= 07777;  }
void I00507() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00510() { hlt = 1;  }
void I00511() { lac &= 010000;  }
void I00512() { lac += core[(df<<12)+core[124]];  }
void I00513() { lac ^= 07777; lac++;  }
void I00514() { lac += core[000173];  }
void I00515() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00516() { hlt = 1;  }
void I00517() { lac &= 010000;  }
void I00520() { lac += core[000020];  }
void I00521() { lac &= (010000|core[(df<<12)+core[124]]);  }
void I00522() { lac ^= 07777; lac++;  }
void I00523() { lac += core[000173];  }
void I00524() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00525() { hlt = 1;  }
void I00526() { lac &= 010000;  }
void I00527() { lac += core[000174];  }
void I00530() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00531() { if (++core[(df<<12)+core[30]] == 010000) { core[(df<<12)+core[30]] = 0; npc++; }; code[(df<<12)+core[30]] = &emul8;  }
void I00532() { skp = 0; skp = !skp; npc += skp;  }
void I00533() { hlt = 1;  }
void I00534() { lac += core[000000];  }
void I00535() { lac ^= 07777; lac++;  }
void I00536() { lac += core[000174];  }
void I00537() { lac ^= 07777;  }
void I00540() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00541() { hlt = 1;  }
void I00542() { lac &= 010000;  }
void I00543() { lac += core[(df<<12)+core[125]];  }
void I00544() { lac ^= 07777; lac++;  }
void I00545() { lac += core[000174];  }
void I00546() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00547() { hlt = 1;  }
void I00550() { lac &= 010000;  }
void I00551() { lac += core[000020];  }
void I00552() { lac &= (010000|core[(df<<12)+core[125]]);  }
void I00553() { lac ^= 07777; lac++;  }
void I00554() { lac += core[000174];  }
void I00555() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00556() { hlt = 1;  }
void I00557() { lac &= 010000;  }
void I00560() { lac += core[000175];  }
void I00561() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00562() { if (++core[(df<<12)+core[30]] == 010000) { core[(df<<12)+core[30]] = 0; npc++; }; code[(df<<12)+core[30]] = &emul8;  }
void I00563() { skp = 0; skp = !skp; npc += skp;  }
void I00564() { hlt = 1;  }
void I00565() { lac += core[000000];  }
void I00566() { lac ^= 07777; lac++;  }
void I00567() { lac += core[000175];  }
void I00570() { lac ^= 07777;  }
void I00571() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void D00572() { hlt = 1;  }
void I00573() { npc = 000577; inh = 0;  }
void L00574() { lac &= (010000|core[(df<<12)+core[264]]);  }
void I00575() { npc = (ib<<12)+core[382]; inh = 0;  }
void P00576() { core[(df<<12)+core[287]] = lac & 07777; lac &= 010000; code[(df<<12)+core[287]] = &emul8;  }
void L00577() {  }
void I00600() { lac &= 010000;  }
void I00601() { lac += core[(df<<12)+core[126]];  }
void I00602() { lac ^= 07777; lac++;  }
void I00603() { lac += core[000175];  }
void I00604() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00605() { hlt = 1;  }
void I00606() { lac &= 010000;  }
void I00607() { lac += core[000036];  }
void I00610() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00611() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00612() { lac += core[000010];  }
void I00613() { lac += core[000035];  }
void I00614() { lac ^= 07777;  }
void I00615() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00616() { hlt = 1;  }
void I00617() { lac &= 010000;  }
void I00620() { lac += core[000035];  }
void I00621() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00622() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00623() { lac += core[000010];  }
void I00624() { lac += core[000036];  }
void I00625() { lac ^= 07777;  }
void I00626() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00627() { hlt = 1;  }
void I00630() { lac &= 010000;  }
void I00631() { lac += core[000034];  }
void I00632() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00633() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00634() { lac += core[000010];  }
void I00635() { lac += core[000051];  }
void I00636() { lac ^= 07777;  }
void I00637() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00640() { hlt = 1;  }
void I00641() { lac &= 010000;  }
void I00642() { lac += core[000033];  }
void I00643() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00644() { if (++core[000010] == 010000) core[000010] = 0000;lac += core[(df<<12)+core[000010]];  }
void I00645() { lac &= 010000;  }
void I00646() { lac += core[000010];  }
void I00647() { lac += core[000047];  }
void I00650() { lac ^= 07777;  }
void I00651() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00652() { hlt = 1;  }
void I00653() { lac &= 010000;  }
void I00654() { lac += core[000032];  }
void I00655() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00656() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00657() { lac += core[000010];  }
void I00660() { lac += core[000046];  }
void I00661() { lac ^= 07777;  }
void I00662() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00663() { hlt = 1;  }
void I00664() { lac &= 010000;  }
void I00665() { lac += core[000031];  }
void I00666() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00667() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00670() { lac += core[000010];  }
void I00671() { lac += core[000045];  }
void I00672() { lac ^= 07777;  }
void I00673() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00674() { hlt = 1;  }
void I00675() { lac &= 010000;  }
void I00676() { lac += core[000027];  }
void I00677() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00700() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00701() { lac += core[000010];  }
void I00702() { lac += core[000044];  }
void I00703() { lac ^= 07777;  }
void I00704() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00705() { hlt = 1;  }
void I00706() { lac &= 010000;  }
void I00707() { lac += core[000026];  }
void I00710() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00711() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00712() { lac += core[000010];  }
void I00713() { lac += core[000043];  }
void I00714() { lac ^= 07777;  }
void I00715() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00716() { hlt = 1;  }
void I00717() { lac &= 010000;  }
void I00720() { lac += core[000025];  }
void I00721() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00722() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00723() { lac += core[000010];  }
void I00724() { lac += core[000042];  }
void I00725() { lac ^= 07777;  }
void I00726() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00727() { hlt = 1;  }
void I00730() { lac &= 010000;  }
void I00731() { lac += core[000024];  }
void I00732() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00733() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00734() { lac += core[000010];  }
void I00735() { lac += core[000041];  }
void I00736() { lac ^= 07777;  }
void I00737() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00740() { hlt = 1;  }
void I00741() { lac &= 010000;  }
void I00742() { lac += core[000023];  }
void I00743() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00744() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00745() { lac += core[000010];  }
void I00746() { lac += core[000040];  }
void I00747() { lac ^= 07777;  }
void I00750() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00751() { hlt = 1;  }
void I00752() { lac &= 010000;  }
void I00753() { lac += core[000022];  }
void I00754() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00755() { if (++core[000010] == 010000) core[000010] = 0000;if (++core[(df<<12)+core[000010]] == 010000) { core[(df<<12)+core[000010]] = 0; npc++; }; code[(df<<12)+core[000010]] = &emul8;  }
void I00756() {  }
void I00757() { lac += core[000010];  }
void I00760() { lac += core[000037];  }
void I00761() { lac ^= 07777;  }
void I00762() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00763() { hlt = 1;  }
void I00764() { lac &= 010000;  }
void I00765() { lac += core[000021];  }
void I00766() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00767() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I00770() { lac += core[000010];  }
void I00771() { lac += core[000021];  }
void I00772() { lac ^= 07777;  }
void I00773() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00774() { hlt = 1;  }
void I00775() {  }
void I00776() {  }
void I00777() {  }
void I01000() { lac &= 010000;  }
void I01001() { lac += core[000020];  }
void I01002() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I01003() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I01004() { lac += core[000010];  }
void I01005() { lac += core[000020];  }
void I01006() { lac ^= 07777;  }
void I01007() { skp = 0; skp = !skp; npc += skp;  }
void P01010() { lac &= (010000|core[000000]);  }
void I01011() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01012() { hlt = 1;  }
void I01013() { lac &= 010000;  }
void I01014() { lac += core[000036];  }
void I01015() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01016() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01017() { lac += core[000011];  }
void I01020() { lac += core[000035];  }
void I01021() { lac ^= 07777;  }
void I01022() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01023() { hlt = 1;  }
void I01024() { lac &= 010000;  }
void I01025() { lac += core[000035];  }
void P01026() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01027() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01030() { lac += core[000011];  }
void I01031() { lac += core[000036];  }
void I01032() { lac ^= 07777;  }
void I01033() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01034() { hlt = 1;  }
void I01035() { lac &= 010000;  }
void I01036() { lac += core[000034];  }
void I01037() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01040() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I01041() { lac += core[000011];  }
void I01042() { lac += core[000051];  }
void I01043() { lac ^= 07777;  }
void I01044() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01045() { hlt = 1;  }
void I01046() { lac &= 010000;  }
void I01047() { lac += core[000033];  }
void I01050() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01051() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I01052() { lac &= 010000;  }
void I01053() { lac += core[000011];  }
void I01054() { lac += core[000047];  }
void I01055() { lac ^= 07777;  }
void I01056() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01057() { hlt = 1;  }
void I01060() { lac &= 010000;  }
void I01061() { lac += core[000032];  }
void I01062() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01063() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01064() { lac += core[000011];  }
void I01065() { lac += core[000046];  }
void I01066() { lac ^= 07777;  }
void I01067() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01070() { hlt = 1;  }
void I01071() { lac &= 010000;  }
void I01072() { lac += core[000031];  }
void I01073() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01074() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01075() { lac += core[000011];  }
void I01076() { lac += core[000045];  }
void I01077() { lac ^= 07777;  }
void I01100() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01101() { hlt = 1;  }
void I01102() { lac &= 010000;  }
void I01103() { lac += core[000027];  }
void I01104() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01105() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01106() { lac += core[000011];  }
void I01107() { lac += core[000044];  }
void I01110() { lac ^= 07777;  }
void I01111() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01112() { hlt = 1;  }
void I01113() { lac &= 010000;  }
void I01114() { lac += core[000026];  }
void I01115() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01116() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01117() { lac += core[000011];  }
void I01120() { lac += core[000043];  }
void I01121() { lac ^= 07777;  }
void I01122() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01123() { hlt = 1;  }
void I01124() { lac &= 010000;  }
void I01125() { lac += core[000025];  }
void I01126() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01127() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01130() { lac += core[000011];  }
void I01131() { lac += core[000042];  }
void I01132() { lac ^= 07777;  }
void I01133() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01134() { hlt = 1;  }
void I01135() { lac &= 010000;  }
void I01136() { lac += core[000024];  }
void I01137() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01140() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01141() { lac += core[000011];  }
void I01142() { lac += core[000041];  }
void I01143() { lac ^= 07777;  }
void I01144() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01145() { hlt = 1;  }
void I01146() { lac &= 010000;  }
void I01147() { lac += core[000023];  }
void I01150() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01151() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01152() { lac += core[000011];  }
void I01153() { lac += core[000040];  }
void I01154() { lac ^= 07777;  }
void I01155() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01156() { hlt = 1;  }
void I01157() { lac &= 010000;  }
void I01160() { lac += core[000022];  }
void I01161() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01162() { if (++core[000011] == 010000) core[000011] = 0000;if (++core[(df<<12)+core[000011]] == 010000) { core[(df<<12)+core[000011]] = 0; npc++; }; code[(df<<12)+core[000011]] = &emul8;  }
void I01163() {  }
void I01164() { lac += core[000011];  }
void I01165() { lac += core[000037];  }
void I01166() { lac ^= 07777;  }
void I01167() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01170() { hlt = 1;  }
void I01171() {  }
void I01172() { npc = 001176; inh = 0;  }
void L01173() { lac &= (010000|core[(df<<12)+core[520]]);  }
void I01174() { npc = (ib<<12)+core[637]; inh = 0;  }
void P01175() { core[(df<<12)+core[534]] = lac & 07777; lac &= 010000; code[(df<<12)+core[534]] = &emul8;  }
void L01176() {  }
void I01177() {  }
void I01200() { lac &= 010000;  }
void I01201() { lac += core[000021];  }
void I01202() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01203() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01204() { lac += core[000011];  }
void I01205() { lac += core[000021];  }
void I01206() { lac ^= 07777;  }
void I01207() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01210() { hlt = 1;  }
void I01211() { lac &= 010000;  }
void I01212() { lac += core[000020];  }
void I01213() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01214() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I01215() { lac += core[000011];  }
void I01216() { lac += core[000020];  }
void I01217() { lac ^= 07777;  }
void I01220() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01221() { hlt = 1;  }
void I01222() { lac &= 010000;  }
void I01223() { lac += core[000036];  }
void I01224() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01225() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01226() { lac += core[000012];  }
void I01227() { lac += core[000035];  }
void I01230() { lac ^= 07777;  }
void I01231() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01232() { hlt = 1;  }
void I01233() { lac &= 010000;  }
void L01234() { lac += core[000035];  }
void I01235() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01236() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01237() { lac += core[000012];  }
void I01240() { lac += core[000036];  }
void I01241() { lac ^= 07777;  }
void I01242() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01243() { hlt = 1;  }
void I01244() { lac &= 010000;  }
void I01245() { lac += core[000034];  }
void I01246() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01247() { if (++core[000012] == 010000) core[000012] = 0000;core[(df<<12)+core[000012]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000012]] = &emul8;  }
void I01250() { lac += core[000012];  }
void I01251() { lac += core[000051];  }
void I01252() { lac ^= 07777;  }
void I01253() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01254() { hlt = 1;  }
void I01255() { lac &= 010000;  }
void I01256() { lac += core[000033];  }
void I01257() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01260() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I01261() { lac &= 010000;  }
void I01262() { lac += core[000012];  }
void I01263() { lac += core[000047];  }
void I01264() { lac ^= 07777;  }
void I01265() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01266() { hlt = 1;  }
void I01267() { lac &= 010000;  }
void I01270() { lac += core[000032];  }
void I01271() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01272() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01273() { lac += core[000012];  }
void I01274() { lac += core[000046];  }
void I01275() { lac ^= 07777;  }
void I01276() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01277() { hlt = 1;  }
void I01300() { lac &= 010000;  }
void I01301() { lac += core[000031];  }
void I01302() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01303() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01304() { lac += core[000012];  }
void I01305() { lac += core[000045];  }
void I01306() { lac ^= 07777;  }
void I01307() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01310() { hlt = 1;  }
void I01311() { lac &= 010000;  }
void I01312() { lac += core[000027];  }
void I01313() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01314() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01315() { lac += core[000012];  }
void I01316() { lac += core[000044];  }
void I01317() { lac ^= 07777;  }
void I01320() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01321() { hlt = 1;  }
void I01322() { lac &= 010000;  }
void I01323() { lac += core[000026];  }
void I01324() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01325() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01326() { lac += core[000012];  }
void I01327() { lac += core[000043];  }
void I01330() { lac ^= 07777;  }
void I01331() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01332() { hlt = 1;  }
void I01333() { lac &= 010000;  }
void I01334() { lac += core[000025];  }
void I01335() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01336() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01337() { lac += core[000012];  }
void I01340() { lac += core[000042];  }
void I01341() { lac ^= 07777;  }
void I01342() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01343() { hlt = 1;  }
void I01344() { lac &= 010000;  }
void I01345() { lac += core[000024];  }
void I01346() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01347() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01350() { lac += core[000012];  }
void I01351() { lac += core[000041];  }
void I01352() { lac ^= 07777;  }
void I01353() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01354() { hlt = 1;  }
void I01355() { lac &= 010000;  }
void I01356() { lac += core[000023];  }
void I01357() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01360() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01361() { lac += core[000012];  }
void I01362() { lac += core[000040];  }
void I01363() { lac ^= 07777;  }
void I01364() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01365() { hlt = 1;  }
void I01366() { lac &= 010000;  }
void I01367() { lac += core[000022];  }
void I01370() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01371() { if (++core[000012] == 010000) core[000012] = 0000;if (++core[(df<<12)+core[000012]] == 010000) { core[(df<<12)+core[000012]] = 0; npc++; }; code[(df<<12)+core[000012]] = &emul8;  }
void I01372() {  }
void I01373() { lac += core[000012];  }
void I01374() { lac += core[000037];  }
void I01375() { lac ^= 07777;  }
void I01376() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01377() { hlt = 1;  }
void I01400() { lac &= 010000;  }
void I01401() { lac += core[000021];  }
void I01402() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01403() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01404() { lac += core[000012];  }
void I01405() { lac += core[000021];  }
void I01406() { lac ^= 07777;  }
void I01407() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01410() { hlt = 1;  }
void I01411() { lac &= 010000;  }
void I01412() { lac += core[000020];  }
void I01413() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I01414() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01415() { lac += core[000012];  }
void I01416() { lac += core[000020];  }
void I01417() { lac ^= 07777;  }
void I01420() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01421() { hlt = 1;  }
void I01422() { lac &= 010000;  }
void I01423() { lac += core[000036];  }
void I01424() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01425() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01426() { lac += core[000013];  }
void I01427() { lac += core[000035];  }
void I01430() { lac ^= 07777;  }
void I01431() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01432() { hlt = 1;  }
void I01433() { lac &= 010000;  }
void I01434() { lac += core[000035];  }
void I01435() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01436() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01437() { lac += core[000013];  }
void I01440() { lac += core[000036];  }
void I01441() { lac ^= 07777;  }
void I01442() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01443() { hlt = 1;  }
void I01444() { lac &= 010000;  }
void I01445() { lac += core[000034];  }
void I01446() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01447() { if (++core[000013] == 010000) core[000013] = 0000;core[(df<<12)+core[000013]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000013]] = &emul8;  }
void I01450() { lac += core[000013];  }
void I01451() { lac += core[000051];  }
void I01452() { lac ^= 07777;  }
void I01453() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01454() { hlt = 1;  }
void I01455() { lac &= 010000;  }
void I01456() { lac += core[000033];  }
void I01457() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01460() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01461() { lac &= 010000;  }
void I01462() { lac += core[000013];  }
void I01463() { lac += core[000047];  }
void I01464() { lac ^= 07777;  }
void I01465() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01466() { hlt = 1;  }
void I01467() { lac &= 010000;  }
void I01470() { lac += core[000032];  }
void I01471() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01472() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01473() { lac += core[000013];  }
void I01474() { lac += core[000046];  }
void I01475() { lac ^= 07777;  }
void I01476() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01477() { hlt = 1;  }
void I01500() { lac &= 010000;  }
void I01501() { lac += core[000031];  }
void I01502() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01503() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01504() { lac += core[000013];  }
void I01505() { lac += core[000045];  }
void I01506() { lac ^= 07777;  }
void I01507() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01510() { hlt = 1;  }
void I01511() { lac &= 010000;  }
void I01512() { lac += core[000027];  }
void I01513() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01514() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01515() { lac += core[000013];  }
void I01516() { lac += core[000044];  }
void I01517() { lac ^= 07777;  }
void I01520() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01521() { hlt = 1;  }
void I01522() { lac &= 010000;  }
void I01523() { lac += core[000026];  }
void I01524() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01525() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01526() { lac += core[000013];  }
void I01527() { lac += core[000043];  }
void I01530() { lac ^= 07777;  }
void I01531() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01532() { hlt = 1;  }
void I01533() { lac &= 010000;  }
void I01534() { lac += core[000025];  }
void I01535() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01536() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01537() { lac += core[000013];  }
void I01540() { lac += core[000042];  }
void I01541() { lac ^= 07777;  }
void I01542() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01543() { hlt = 1;  }
void I01544() { lac &= 010000;  }
void I01545() { lac += core[000024];  }
void I01546() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01547() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01550() { lac += core[000013];  }
void I01551() { lac += core[000041];  }
void I01552() { lac ^= 07777;  }
void I01553() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01554() { hlt = 1;  }
void I01555() { lac &= 010000;  }
void I01556() { lac += core[000023];  }
void I01557() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01560() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01561() { lac += core[000013];  }
void I01562() { lac += core[000040];  }
void I01563() { lac ^= 07777;  }
void I01564() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01565() { hlt = 1;  }
void I01566() { lac &= 010000;  }
void I01567() { lac += core[000022];  }
void I01570() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01571() { if (++core[000013] == 010000) core[000013] = 0000;if (++core[(df<<12)+core[000013]] == 010000) { core[(df<<12)+core[000013]] = 0; npc++; }; code[(df<<12)+core[000013]] = &emul8;  }
void I01572() {  }
void I01573() { lac += core[000013];  }
void I01574() { lac += core[000037];  }
void I01575() { lac ^= 07777;  }
void I01576() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01577() { hlt = 1;  }
void I01600() { lac &= 010000;  }
void I01601() { lac += core[000021];  }
void I01602() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01603() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01604() { lac += core[000013];  }
void I01605() { lac += core[000021];  }
void I01606() { lac ^= 07777;  }
void I01607() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01610() { hlt = 1;  }
void I01611() { lac &= 010000;  }
void I01612() { lac += core[000020];  }
void I01613() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01614() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I01615() { lac += core[000013];  }
void I01616() { lac += core[000020];  }
void I01617() { lac ^= 07777;  }
void I01620() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01621() { hlt = 1;  }
void I01622() { lac &= 010000;  }
void I01623() { lac += core[000036];  }
void I01624() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01625() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I01626() { lac += core[000014];  }
void I01627() { lac += core[000035];  }
void I01630() { lac ^= 07777;  }
void I01631() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01632() { hlt = 1;  }
void I01633() { lac &= 010000;  }
void I01634() { lac += core[000035];  }
void I01635() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01636() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I01637() { lac += core[000014];  }
void I01640() { lac += core[000036];  }
void I01641() { lac ^= 07777;  }
void I01642() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01643() { hlt = 1;  }
void I01644() { lac &= 010000;  }
void I01645() { lac += core[000034];  }
void I01646() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01647() { if (++core[000014] == 010000) core[000014] = 0000;core[(df<<12)+core[000014]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000014]] = &emul8;  }
void I01650() { lac += core[000014];  }
void I01651() { lac += core[000051];  }
void I01652() { lac ^= 07777;  }
void I01653() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01654() { hlt = 1;  }
void I01655() { lac &= 010000;  }
void I01656() { lac += core[000033];  }
void I01657() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01660() { if (++core[000014] == 010000) core[000014] = 0000;lac += core[(df<<12)+core[000014]];  }
void I01661() { lac &= 010000;  }
void I01662() { lac += core[000014];  }
void I01663() { lac += core[000047];  }
void I01664() { lac ^= 07777;  }
void I01665() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01666() { hlt = 1;  }
void I01667() { lac &= 010000;  }
void I01670() { lac += core[000032];  }
void I01671() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01672() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I01673() { lac += core[000014];  }
void I01674() { lac += core[000046];  }
void I01675() { lac ^= 07777;  }
void I01676() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01677() { hlt = 1;  }
void I01700() { lac &= 010000;  }
void I01701() { lac += core[000031];  }
void I01702() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01703() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I01704() { lac += core[000014];  }
void I01705() { lac += core[000045];  }
void I01706() { lac ^= 07777;  }
void I01707() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01710() { hlt = 1;  }
void I01711() { lac &= 010000;  }
void I01712() { lac += core[000027];  }
void I01713() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01714() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I01715() { lac += core[000014];  }
void I01716() { lac += core[000044];  }
void I01717() { lac ^= 07777;  }
void I01720() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01721() { hlt = 1;  }
void I01722() { lac &= 010000;  }
void I01723() { lac += core[000026];  }
void I01724() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01725() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I01726() { lac += core[000014];  }
void I01727() { lac += core[000043];  }
void I01730() { lac ^= 07777;  }
void I01731() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01732() { hlt = 1;  }
void I01733() { lac &= 010000;  }
void I01734() { lac += core[000025];  }
void I01735() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01736() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I01737() { lac += core[000014];  }
void I01740() { lac += core[000042];  }
void I01741() { lac ^= 07777;  }
void I01742() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01743() { hlt = 1;  }
void I01744() { lac &= 010000;  }
void I01745() { lac += core[000024];  }
void I01746() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01747() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I01750() { lac += core[000014];  }
void I01751() { lac += core[000041];  }
void I01752() { lac ^= 07777;  }
void I01753() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01754() { hlt = 1;  }
void I01755() { lac &= 010000;  }
void I01756() { lac += core[000023];  }
void I01757() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01760() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I01761() { lac += core[000014];  }
void I01762() { lac += core[000040];  }
void I01763() { lac ^= 07777;  }
void I01764() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01765() { hlt = 1;  }
void I01766() { lac &= 010000;  }
void I01767() { lac += core[000022];  }
void I01770() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I01771() { if (++core[000014] == 010000) core[000014] = 0000;if (++core[(df<<12)+core[000014]] == 010000) { core[(df<<12)+core[000014]] = 0; npc++; }; code[(df<<12)+core[000014]] = &emul8;  }
void I01772() {  }
void I01773() { lac += core[000014];  }
void I01774() { lac += core[000037];  }
void I01775() { lac ^= 07777;  }
void I01776() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01777() { hlt = 1;  }
void I02000() { lac &= 010000;  }
void I02001() { lac += core[000021];  }
void I02002() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I02003() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I02004() { lac += core[000014];  }
void I02005() { lac += core[000021];  }
void I02006() { lac ^= 07777;  }
void I02007() { skp = 0; skp = !skp; npc += skp;  }
void P02010() { lac &= (010000|core[000000]);  }
void I02011() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02012() { hlt = 1;  }
void I02013() { lac &= 010000;  }
void I02014() { lac += core[000020];  }
void P02015() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I02016() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I02017() { lac += core[000014];  }
void I02020() { lac += core[000020];  }
void I02021() { lac ^= 07777;  }
void I02022() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02023() { hlt = 1;  }
void I02024() { lac &= 010000;  }
void I02025() { lac += core[000036];  }
void I02026() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02027() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02030() { lac += core[000015];  }
void I02031() { lac += core[000035];  }
void I02032() { lac ^= 07777;  }
void I02033() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02034() { hlt = 1;  }
void I02035() { lac &= 010000;  }
void I02036() { lac += core[000035];  }
void I02037() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02040() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02041() { lac += core[000015];  }
void I02042() { lac += core[000036];  }
void I02043() { lac ^= 07777;  }
void I02044() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02045() { hlt = 1;  }
void I02046() { lac &= 010000;  }
void I02047() { lac += core[000034];  }
void I02050() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02051() { if (++core[000015] == 010000) core[000015] = 0000;core[(df<<12)+core[000015]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000015]] = &emul8;  }
void I02052() { lac += core[000015];  }
void I02053() { lac += core[000051];  }
void I02054() { lac ^= 07777;  }
void I02055() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02056() { hlt = 1;  }
void I02057() { lac &= 010000;  }
void I02060() { lac += core[000033];  }
void I02061() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02062() { if (++core[000015] == 010000) core[000015] = 0000;lac += core[(df<<12)+core[000015]];  }
void I02063() { lac &= 010000;  }
void I02064() { lac += core[000015];  }
void I02065() { lac += core[000047];  }
void I02066() { lac ^= 07777;  }
void I02067() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02070() { hlt = 1;  }
void I02071() { lac &= 010000;  }
void I02072() { lac += core[000032];  }
void I02073() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02074() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02075() { lac += core[000015];  }
void I02076() { lac += core[000046];  }
void I02077() { lac ^= 07777;  }
void I02100() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02101() { hlt = 1;  }
void I02102() { lac &= 010000;  }
void I02103() { lac += core[000031];  }
void I02104() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02105() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02106() { lac += core[000015];  }
void I02107() { lac += core[000045];  }
void I02110() { lac ^= 07777;  }
void I02111() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02112() { hlt = 1;  }
void I02113() { lac &= 010000;  }
void I02114() { lac += core[000027];  }
void I02115() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02116() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02117() { lac += core[000015];  }
void I02120() { lac += core[000044];  }
void I02121() { lac ^= 07777;  }
void I02122() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02123() { hlt = 1;  }
void I02124() { lac &= 010000;  }
void I02125() { lac += core[000026];  }
void I02126() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02127() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02130() { lac += core[000015];  }
void I02131() { lac += core[000043];  }
void I02132() { lac ^= 07777;  }
void I02133() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02134() { hlt = 1;  }
void I02135() { lac &= 010000;  }
void I02136() { lac += core[000025];  }
void I02137() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02140() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02141() { lac += core[000015];  }
void I02142() { lac += core[000042];  }
void I02143() { lac ^= 07777;  }
void I02144() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02145() { hlt = 1;  }
void I02146() { lac &= 010000;  }
void I02147() { lac += core[000024];  }
void I02150() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02151() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02152() { lac += core[000015];  }
void I02153() { lac += core[000041];  }
void I02154() { lac ^= 07777;  }
void I02155() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02156() { hlt = 1;  }
void I02157() { lac &= 010000;  }
void I02160() { lac += core[000023];  }
void I02161() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02162() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02163() { lac += core[000015];  }
void I02164() { lac += core[000040];  }
void I02165() { lac ^= 07777;  }
void I02166() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02167() { hlt = 1;  }
void I02170() {  }
void I02171() {  }
void I02172() { npc = 002176; inh = 0;  }
void L02173() { lac &= (010000|core[(df<<12)+core[1032]]);  }
void I02174() { npc = (ib<<12)+core[1149]; inh = 0;  }
void P02175() { core[(df<<12)+core[1037]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1037]] = &emul8;  }
void L02176() {  }
void I02177() {  }
void I02200() { lac &= 010000;  }
void I02201() { lac += core[000022];  }
void I02202() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02203() { if (++core[000015] == 010000) core[000015] = 0000;if (++core[(df<<12)+core[000015]] == 010000) { core[(df<<12)+core[000015]] = 0; npc++; }; code[(df<<12)+core[000015]] = &emul8;  }
void I02204() {  }
void I02205() { lac += core[000015];  }
void I02206() { lac += core[000037];  }
void I02207() { lac ^= 07777;  }
void I02210() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02211() { hlt = 1;  }
void I02212() { lac &= 010000;  }
void I02213() { lac += core[000021];  }
void I02214() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02215() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02216() { lac += core[000015];  }
void I02217() { lac += core[000021];  }
void I02220() { lac ^= 07777;  }
void I02221() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02222() { hlt = 1;  }
void I02223() { lac &= 010000;  }
void I02224() { lac += core[000020];  }
void I02225() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I02226() { if (++core[000015] == 010000) core[000015] = 0000;lac &= (010000|core[(df<<12)+core[000015]]);  }
void I02227() { lac += core[000015];  }
void I02230() { lac += core[000020];  }
void I02231() { lac ^= 07777;  }
void I02232() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02233() { hlt = 1;  }
void I02234() { lac &= 010000;  }
void I02235() { lac += core[000036];  }
void I02236() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02237() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02240() { lac += core[000016];  }
void I02241() { lac += core[000035];  }
void I02242() { lac ^= 07777;  }
void I02243() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02244() { hlt = 1;  }
void I02245() { lac &= 010000;  }
void I02246() { lac += core[000035];  }
void I02247() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02250() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02251() { lac += core[000016];  }
void I02252() { lac += core[000036];  }
void I02253() { lac ^= 07777;  }
void I02254() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02255() { hlt = 1;  }
void I02256() { lac &= 010000;  }
void I02257() { lac += core[000034];  }
void I02260() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02261() { if (++core[000016] == 010000) core[000016] = 0000;core[(df<<12)+core[000016]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000016]] = &emul8;  }
void I02262() { lac += core[000016];  }
void I02263() { lac += core[000051];  }
void I02264() { lac ^= 07777;  }
void I02265() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02266() { hlt = 1;  }
void I02267() { lac &= 010000;  }
void I02270() { lac += core[000033];  }
void I02271() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02272() { if (++core[000016] == 010000) core[000016] = 0000;lac += core[(df<<12)+core[000016]];  }
void I02273() { lac &= 010000;  }
void I02274() { lac += core[000016];  }
void I02275() { lac += core[000047];  }
void I02276() { lac ^= 07777;  }
void I02277() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02300() { hlt = 1;  }
void I02301() { lac &= 010000;  }
void I02302() { lac += core[000032];  }
void I02303() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02304() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02305() { lac += core[000016];  }
void I02306() { lac += core[000046];  }
void I02307() { lac ^= 07777;  }
void I02310() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02311() { hlt = 1;  }
void I02312() { lac &= 010000;  }
void I02313() { lac += core[000031];  }
void I02314() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02315() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02316() { lac += core[000016];  }
void I02317() { lac += core[000045];  }
void I02320() { lac ^= 07777;  }
void I02321() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02322() { hlt = 1;  }
void I02323() { lac &= 010000;  }
void I02324() { lac += core[000027];  }
void I02325() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02326() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02327() { lac += core[000016];  }
void I02330() { lac += core[000044];  }
void I02331() { lac ^= 07777;  }
void I02332() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02333() { hlt = 1;  }
void I02334() { lac &= 010000;  }
void I02335() { lac += core[000026];  }
void I02336() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02337() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02340() { lac += core[000016];  }
void I02341() { lac += core[000043];  }
void I02342() { lac ^= 07777;  }
void I02343() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02344() { hlt = 1;  }
void I02345() { lac &= 010000;  }
void I02346() { lac += core[000025];  }
void I02347() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02350() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02351() { lac += core[000016];  }
void I02352() { lac += core[000042];  }
void I02353() { lac ^= 07777;  }
void I02354() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02355() { hlt = 1;  }
void I02356() { lac &= 010000;  }
void I02357() { lac += core[000024];  }
void I02360() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02361() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02362() { lac += core[000016];  }
void I02363() { lac += core[000041];  }
void I02364() { lac ^= 07777;  }
void I02365() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02366() { hlt = 1;  }
void I02367() { lac &= 010000;  }
void I02370() { lac += core[000023];  }
void I02371() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02372() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02373() { lac += core[000016];  }
void I02374() { lac += core[000040];  }
void I02375() { lac ^= 07777;  }
void I02376() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02377() { hlt = 1;  }
void I02400() { lac &= 010000;  }
void I02401() { lac += core[000022];  }
void I02402() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02403() { if (++core[000016] == 010000) core[000016] = 0000;if (++core[(df<<12)+core[000016]] == 010000) { core[(df<<12)+core[000016]] = 0; npc++; }; code[(df<<12)+core[000016]] = &emul8;  }
void I02404() {  }
void I02405() { lac += core[000016];  }
void I02406() { lac += core[000037];  }
void I02407() { lac ^= 07777;  }
void I02410() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02411() { hlt = 1;  }
void I02412() { lac &= 010000;  }
void I02413() { lac += core[000021];  }
void I02414() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02415() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02416() { lac += core[000016];  }
void I02417() { lac += core[000021];  }
void I02420() { lac ^= 07777;  }
void I02421() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02422() { hlt = 1;  }
void I02423() { lac &= 010000;  }
void I02424() { lac += core[000020];  }
void I02425() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02426() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I02427() { lac += core[000016];  }
void I02430() { lac += core[000020];  }
void I02431() { lac ^= 07777;  }
void I02432() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02433() { hlt = 1;  }
void I02434() { lac &= 010000;  }
void I02435() { lac += core[000036];  }
void I02436() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02437() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02440() { lac += core[000017];  }
void I02441() { lac += core[000035];  }
void I02442() { lac ^= 07777;  }
void I02443() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02444() { hlt = 1;  }
void I02445() { lac &= 010000;  }
void I02446() { lac += core[000035];  }
void I02447() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02450() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02451() { lac += core[000017];  }
void I02452() { lac += core[000036];  }
void I02453() { lac ^= 07777;  }
void I02454() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02455() { hlt = 1;  }
void I02456() { lac &= 010000;  }
void I02457() { lac += core[000034];  }
void I02460() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02461() { if (++core[000017] == 010000) core[000017] = 0000;core[(df<<12)+core[000017]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000017]] = &emul8;  }
void I02462() { lac += core[000017];  }
void I02463() { lac += core[000051];  }
void I02464() { lac ^= 07777;  }
void I02465() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02466() { hlt = 1;  }
void I02467() { lac &= 010000;  }
void I02470() { lac += core[000033];  }
void I02471() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02472() { if (++core[000017] == 010000) core[000017] = 0000;lac += core[(df<<12)+core[000017]];  }
void I02473() { lac &= 010000;  }
void I02474() { lac += core[000017];  }
void I02475() { lac += core[000047];  }
void I02476() { lac ^= 07777;  }
void I02477() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02500() { hlt = 1;  }
void I02501() { lac &= 010000;  }
void I02502() { lac += core[000032];  }
void I02503() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02504() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02505() { lac += core[000017];  }
void I02506() { lac += core[000046];  }
void I02507() { lac ^= 07777;  }
void I02510() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02511() { hlt = 1;  }
void I02512() { lac &= 010000;  }
void I02513() { lac += core[000031];  }
void I02514() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02515() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02516() { lac += core[000017];  }
void I02517() { lac += core[000045];  }
void I02520() { lac ^= 07777;  }
void I02521() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02522() { hlt = 1;  }
void I02523() { lac &= 010000;  }
void I02524() { lac += core[000027];  }
void I02525() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02526() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02527() { lac += core[000017];  }
void I02530() { lac += core[000044];  }
void I02531() { lac ^= 07777;  }
void I02532() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02533() { hlt = 1;  }
void I02534() { lac &= 010000;  }
void I02535() { lac += core[000026];  }
void I02536() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02537() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02540() { lac += core[000017];  }
void I02541() { lac += core[000043];  }
void I02542() { lac ^= 07777;  }
void I02543() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02544() { hlt = 1;  }
void I02545() { lac &= 010000;  }
void I02546() { lac += core[000025];  }
void I02547() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02550() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02551() { lac += core[000017];  }
void I02552() { lac += core[000042];  }
void I02553() { lac ^= 07777;  }
void I02554() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02555() { hlt = 1;  }
void I02556() { lac &= 010000;  }
void I02557() { lac += core[000024];  }
void I02560() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02561() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02562() { lac += core[000017];  }
void I02563() { lac += core[000041];  }
void I02564() { lac ^= 07777;  }
void I02565() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02566() { hlt = 1;  }
void I02567() { lac &= 010000;  }
void I02570() { lac += core[000023];  }
void I02571() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02572() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02573() { lac += core[000017];  }
void I02574() { lac += core[000040];  }
void I02575() { lac ^= 07777;  }
void I02576() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02577() { hlt = 1;  }
void I02600() { lac &= 010000;  }
void I02601() { lac += core[000022];  }
void I02602() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02603() { if (++core[000017] == 010000) core[000017] = 0000;if (++core[(df<<12)+core[000017]] == 010000) { core[(df<<12)+core[000017]] = 0; npc++; }; code[(df<<12)+core[000017]] = &emul8;  }
void I02604() {  }
void I02605() { lac += core[000017];  }
void I02606() { lac += core[000037];  }
void I02607() { lac ^= 07777;  }
void I02610() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02611() { hlt = 1;  }
void I02612() { lac &= 010000;  }
void I02613() { lac += core[000021];  }
void I02614() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02615() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02616() { lac += core[000017];  }
void I02617() { lac += core[000021];  }
void I02620() { lac ^= 07777;  }
void I02621() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02622() { hlt = 1;  }
void I02623() { lac &= 010000;  }
void I02624() { lac += core[000020];  }
void I02625() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02626() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I02627() { lac += core[000017];  }
void I02630() { lac += core[000020];  }
void I02631() { lac ^= 07777;  }
void I02632() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02633() { hlt = 1;  }
void I02634() { npc = 002636; inh = 0;  }
void I02635() { hlt = 1;  }
void L02636() { skp = 0; skp = !skp; npc += skp;  }
void D02637() { if (++core[(df<<12)+core[1444]] == 010000) { core[(df<<12)+core[1444]] = 0; npc++; }; code[(df<<12)+core[1444]] = &emul8;  }
void I02640() { lac += core[002637];  }
void I02641() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I02642() { if (++core[000010] == 010000) core[000010] = 0000;npc = (ib<<12)+core[000010]; inh = 0;  }
void I02643() { hlt = 1;  }
void P02644() { hlt = 1;  }
void I02645() { core[002647] = 02646; npc = 002647+1; code[002647] = &emul8; inh = 0;  }
void P02646() { hlt = 1;  }
void D02647() { hlt = 1;  }
void I02650() { lac += core[002647];  }
void I02651() { skp = 0; skp = !skp; npc += skp;  }
void D02652() { if (++core[(df<<12)+core[1446]] == 010000) { core[(df<<12)+core[1446]] = 0; npc++; }; code[(df<<12)+core[1446]] = &emul8;  }
void I02653() { lac ^= 07777; lac++;  }
void I02654() { lac += core[002652];  }
void I02655() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02656() { hlt = 1;  }
void I02657() { skp = 0; skp = !skp; npc += skp;  }
void D02660() { if (++core[(df<<12)+core[1460]] == 010000) { core[(df<<12)+core[1460]] = 0; npc++; }; code[(df<<12)+core[1460]] = &emul8;  }
void I02661() { lac += core[002660];  }
void I02662() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I02663() { if (++core[000010] == 010000) core[000010] = 0000;core[(ib<<12)+core[000010]] = 02664; npc = (ib<<12)+core[000010]+1; code[(ib<<12)+core[000010]] = &emul8; inh = 0;  }
void P02664() { hlt = 1;  }
void D02665() { hlt = 1;  }
void I02666() { lac += core[002665];  }
void I02667() { skp = 0; skp = !skp; npc += skp;  }
void D02670() { if (++core[(df<<12)+core[1460]] == 010000) { core[(df<<12)+core[1460]] = 0; npc++; }; code[(df<<12)+core[1460]] = &emul8;  }
void I02671() { lac ^= 07777; lac++;  }
void I02672() { lac += core[002670];  }
void I02673() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02674() { hlt = 1;  }
void I02675() { npc = (ib<<12)+core[1470]; inh = 0;  }
void P02676() { core[002600] = 02677; npc = 002600+1; code[002600] = &emul8; inh = 0;  }
void L02677() { core[(ib<<12)+core[1472]] = 02700; npc = (ib<<12)+core[1472]+1; code[(ib<<12)+core[1472]] = &emul8; inh = 0;  }
void P02700() { core[000011] = 02701; npc = 000011+1; code[000011] = &emul8; inh = 0;  }
void I02701() { emul8();  }
void I02702() { emul8();  }
void I02703() { hlt = 1;  }
void I02704() { lac &= 010000;  }
void I02705() { lac += core[002713];  }
void I02706() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I02707() { emul8();  }
void I02710() {  }
void P02711() { hlt = 1;  }
void D02712() { if (++core[(df<<12)+core[1481]] == 010000) { core[(df<<12)+core[1481]] = 0; npc++; }; code[(df<<12)+core[1481]] = &emul8;  }
void D02713() { if (++core[(df<<12)+core[1484]] == 010000) { core[(df<<12)+core[1484]] = 0; npc++; }; code[(df<<12)+core[1484]] = &emul8;  }
void P02714() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02715() { hlt = 1;  }
void I02716() { lac += core[000000];  }
void I02717() { lac ^= 07777; lac++;  }
void I02720() { lac += core[002712];  }
void I02721() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02722() { hlt = 1;  }
void I02723() { emul8();  }
void I02724() { emul8();  }
void I02725() { hlt = 1;  }
void I02726() { lac &= 010000;  }
void I02727() { lac += core[002735];  }
void I02730() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I02731() { emul8();  }
void I02732() { lac += core[000020];  }
void P02733() { hlt = 1;  }
void D02734() { if (++core[(df<<12)+core[1499]] == 010000) { core[(df<<12)+core[1499]] = 0; npc++; }; code[(df<<12)+core[1499]] = &emul8;  }
void D02735() { if (++core[(df<<12)+core[1502]] == 010000) { core[(df<<12)+core[1502]] = 0; npc++; }; code[(df<<12)+core[1502]] = &emul8;  }
void P02736() { lac ^= 07777;  }
void I02737() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02740() { hlt = 1;  }
void I02741() { lac += core[000000];  }
void I02742() { lac ^= 07777; lac++;  }
void I02743() { lac += core[002734];  }
void I02744() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02745() { hlt = 1;  }
void I02746() { emul8();  }
void I02747() { emul8();  }
void I02750() { hlt = 1;  }
void I02751() { lac &= 010000;  }
void I02752() { lac += core[002761];  }
void I02753() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I02754() { lac += core[000020];  }
void I02755() { emul8();  }
void I02756() { lac &= (010000|core[000020]);  }
void P02757() { hlt = 1;  }
void D02760() { if (++core[(df<<12)+core[1519]] == 010000) { core[(df<<12)+core[1519]] = 0; npc++; }; code[(df<<12)+core[1519]] = &emul8;  }
void D02761() { if (++core[(df<<12)+core[1522]] == 010000) { core[(df<<12)+core[1522]] = 0; npc++; }; code[(df<<12)+core[1522]] = &emul8;  }
void P02762() { lac ^= 07777;  }
void I02763() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02764() { hlt = 1;  }
void I02765() { lac += core[000000];  }
void I02766() { lac ^= 07777; lac++;  }
void I02767() { lac += core[002760];  }
void I02770() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02771() { hlt = 1;  }
void I02772() { npc = (ib<<12)+core[1531]; inh = 0;  }
void P02773() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void L03000() { emul8();  }
void I03001() { emul8();  }
void I03002() { hlt = 1;  }
void I03003() { lac &= 010000;  }
void I03004() { lac += core[003013];  }
void I03005() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03006() { lac += core[000020];  }
void I03007() { emul8();  }
void I03010() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void D03011() { hlt = 1;  }
void D03012() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void D03013() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void D03014() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03015() { hlt = 1;  }
void I03016() { lac += core[000003];  }
void I03017() { lac ^= 07777;  }
void I03020() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03021() { hlt = 1;  }
void I03022() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I03023() { lac += core[000000];  }
void I03024() { lac ^= 07777; lac++;  }
void I03025() { lac += core[003012];  }
void I03026() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03027() { hlt = 1;  }
void I03030() { emul8();  }
void I03031() { emul8();  }
void I03032() { hlt = 1;  }
void I03033() { lac &= 010000;  }
void I03034() { lac += core[003044];  }
void I03035() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03036() { lac += core[000035];  }
void I03037() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I03040() { emul8();  }
void I03041() { if (++core[000003] == 010000) { core[000003] = 0; npc++; }; code[000003] = &emul8;  }
void I03042() { hlt = 1;  }
void D03043() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void D03044() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I03045() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03046() { hlt = 1;  }
void I03047() { lac += core[000003];  }
void I03050() { lac ^= 07777;  }
void I03051() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03052() { hlt = 1;  }
void I03053() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I03054() { lac += core[000000];  }
void I03055() { lac ^= 07777; lac++;  }
void I03056() { lac += core[003043];  }
void I03057() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03060() { hlt = 1;  }
void I03061() { emul8();  }
void I03062() { emul8();  }
void I03063() { hlt = 1;  }
void I03064() { lac &= 010000;  }
void I03065() { lac += core[003076];  }
void I03066() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03067() { lac += core[000020];  }
void I03070() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I03071() { emul8();  }
void I03072() { if (++core[000003] == 010000) { core[000003] = 0; npc++; }; code[000003] = &emul8;  }
void I03073() { hlt = 1;  }
void I03074() { hlt = 1;  }
void D03075() { core[000074] = lac & 07777; lac &= 010000; code[000074] = &emul8;  }
void D03076() { core[000077] = lac & 07777; lac &= 010000; code[000077] = &emul8;  }
void I03077() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03100() { hlt = 1;  }
void I03101() { lac += core[000003];  }
void I03102() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03103() { hlt = 1;  }
void I03104() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I03105() { lac += core[000000];  }
void I03106() { lac ^= 07777; lac++;  }
void I03107() { lac += core[003075];  }
void I03110() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03111() { hlt = 1;  }
void I03112() { emul8();  }
void I03113() { emul8();  }
void I03114() { hlt = 1;  }
void I03115() { lac &= 010000;  }
void I03116() { lac += core[003124];  }
void I03117() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03120() { emul8();  }
void L03121() { npc = 003121; inh = 0;  }
void I03122() { hlt = 1;  }
void D03123() { core[000121] = lac & 07777; lac &= 010000; code[000121] = &emul8;  }
void D03124() { core[000125] = lac & 07777; lac &= 010000; code[000125] = &emul8;  }
void I03125() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03126() { hlt = 1;  }
void I03127() { lac += core[000000];  }
void I03130() { lac ^= 07777; lac++;  }
void I03131() { lac += core[003123];  }
void I03132() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03133() { hlt = 1;  }
void I03134() { emul8();  }
void I03135() { emul8();  }
void I03136() { hlt = 1;  }
void I03137() { lac &= 010000;  }
void I03140() { lac += core[003146];  }
void I03141() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03142() { emul8();  }
void I03143() { core[000003] = 03144; npc = 000003+1; code[000003] = &emul8; inh = 0;  }
void I03144() { hlt = 1;  }
void D03145() { core[000144] = lac & 07777; lac &= 010000; code[000144] = &emul8;  }
void D03146() { core[000147] = lac & 07777; lac &= 010000; code[000147] = &emul8;  }
void I03147() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03150() { hlt = 1;  }
void I03151() { lac += core[000003];  }
void I03152() { lac ^= 07777; lac++;  }
void I03153() { lac += core[003145];  }
void I03154() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03155() { hlt = 1;  }
void I03156() { lac += core[000000];  }
void I03157() { lac ^= 07777; lac++;  }
void I03160() { lac += core[000065];  }
void I03161() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03162() { hlt = 1;  }
void I03163() { npc = (ib<<12)+core[1652]; inh = 0;  }
void P03164() { core[003000] = lac & 07777; lac &= 010000; code[003000] = &emul8;  }
void L03200() { emul8();  }
void I03201() { emul8();  }
void I03202() { hlt = 1;  }
void I03203() { lac &= 010000;  }
void I03204() { lac += core[003213];  }
void I03205() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03206() { lac += core[000020];  }
void I03207() { emul8();  }
void I03210() { lac &= 010000;  }
void D03211() { hlt = 1;  }
void D03212() { core[003211] = lac & 07777; lac &= 010000; code[003211] = &emul8;  }
void D03213() { core[003214] = lac & 07777; lac &= 010000; code[003214] = &emul8;  }
void D03214() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03215() { hlt = 1;  }
void I03216() { lac += core[000000];  }
void I03217() { lac ^= 07777; lac++;  }
void I03220() { lac += core[003212];  }
void I03221() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03222() { hlt = 1;  }
void I03223() { emul8();  }
void I03224() { emul8();  }
void I03225() { hlt = 1;  }
void I03226() { lac &= 010000;  }
void I03227() { lac += core[003236];  }
void I03230() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03231() { emul8();  }
void I03232() { emul8();  }
void I03233() { hlt = 1;  }
void D03234() { hlt = 1;  }
void D03235() { core[003234] = lac & 07777; lac &= 010000; code[003234] = &emul8;  }
void D03236() { core[003237] = lac & 07777; lac &= 010000; code[003237] = &emul8;  }
void D03237() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03240() { hlt = 1;  }
void I03241() { lac += core[000000];  }
void I03242() { lac ^= 07777; lac++;  }
void I03243() { lac += core[003235];  }
void I03244() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03245() { hlt = 1;  }
void I03246() { emul8();  }
void I03247() { emul8();  }
void I03250() { hlt = 1;  }
void I03251() { lac &= 010000;  }
void I03252() { lac += core[003311];  }
void I03253() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03254() { emul8();  }
void I03255() { emul8();  }
void I03256() { emul8();  }
void I03257() { emul8();  }
void I03260() { emul8();  }
void I03261() { emul8();  }
void I03262() { emul8();  }
void I03263() { emul8();  }
void I03264() { emul8();  }
void I03265() { emul8();  }
void I03266() { emul8();  }
void I03267() { emul8();  }
void I03270() { emul8();  }
void I03271() { emul8();  }
void I03272() { emul8();  }
void I03273() { emul8();  }
void I03274() { emul8();  }
void I03275() { emul8();  }
void I03276() { emul8();  }
void I03277() { emul8();  }
void I03300() { emul8();  }
void I03301() { emul8();  }
void I03302() { emul8();  }
void I03303() { emul8();  }
void I03304() { emul8();  }
void I03305() { emul8();  }
void I03306() { emul8();  }
void I03307() { hlt = 1;  }
void I03310() { skp = 0; skp = !skp; npc += skp;  }
void D03311() { core[003313] = lac & 07777; lac &= 010000; code[003313] = &emul8;  }
void I03312() { skp = 0; skp = !skp; npc += skp;  }
void D03313() { hlt = 1;  }
void I03314() { emul8();  }
void I03315() { lac &= 010000;  }
void I03316() { lac += core[003326];  }
void I03317() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03320() { emul8();  }
void I03321() {  }
void I03322() {  }
void I03323() {  }
void I03324() {  }
void I03325() { skp = 0; skp = !skp; npc += skp;  }
void D03326() { core[003330] = lac & 07777; lac &= 010000; code[003330] = &emul8;  }
void I03327() { skp = 0; skp = !skp; npc += skp;  }
void D03330() { hlt = 1;  }
void I03331() { emul8();  }
void I03332() { emul8();  }
void I03333() { emul8();  }
void I03334() { hlt = 1;  }
void I03335() { lac &= 010000;  }
void I03336() { lac += core[003345];  }
void I03337() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03340() { emul8();  }
void I03341() { skp = 0; skp = !skp; npc += skp;  }
void I03342() { hlt = 1;  }
void D03343() { hlt = 1;  }
void D03344() { core[003343] = lac & 07777; lac &= 010000; code[003343] = &emul8;  }
void D03345() { core[003346] = lac & 07777; lac &= 010000; code[003346] = &emul8;  }
void D03346() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03347() { hlt = 1;  }
void I03350() { lac += core[000000];  }
void I03351() { lac ^= 07777; lac++;  }
void I03352() { lac += core[003344];  }
void I03353() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03354() { hlt = 1;  }
void I03355() { emul8();  }
void I03356() { emul8();  }
void I03357() { hlt = 1;  }
void I03360() { lac &= 010000;  }
void I03361() { lac += core[003370];  }
void I03362() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03363() { emul8();  }
void I03364() { npc = (ib<<12)+core[1781]; inh = 0;  }
void P03365() { core[003366] = lac & 07777; lac &= 010000; code[003366] = &emul8;  }
void L03366() { hlt = 1;  }
void D03367() { core[003366] = lac & 07777; lac &= 010000; code[003366] = &emul8;  }
void D03370() { core[003371] = lac & 07777; lac &= 010000; code[003371] = &emul8;  }
void D03371() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03372() { hlt = 1;  }
void I03373() { lac += core[000000];  }
void I03374() { lac ^= 07777; lac++;  }
void I03375() { lac += core[003367];  }
void I03376() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03377() { hlt = 1;  }
void P03400() { emul8();  }
void I03401() { lac += core[003412];  }
void I03402() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I03403() { emul8();  }
void I03404() {  }
void I03405() { emul8();  }
void I03406() { emul8();  }
void I03407() { emul8();  }
void I03410() { npc = 003413; inh = 0;  }
void I03411() { hlt = 1;  }
void D03412() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void L03413() { emul8();  }
void I03414() { npc = (ib<<12)+core[1805]; inh = 0;  }
void P03415() { core[(df<<12)+core[1792]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1792]] = &emul8;  }
void L03600() { lac &= 010000;  }
void I03601() { npc = (ib<<12)+core[1922]; inh = 0;  }
void P03602() { core[000000] = 03603; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void P03603() { core[000010] = 03604; npc = 000010+1; code[000010] = &emul8; inh = 0;  }
void L03604() { lac += core[(df<<12)+core[1923]];  }
void I03605() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03606() { hlt = 1;  }
void D03607() { lac &= 010000;  }
void D03610() { core[(df<<12)+core[1923]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1923]] = &emul8;  }
void I03611() { lac &= 010000;  }
void I03612() { npc = (ib<<12)+core[1931]; inh = 0;  }
void P03613() { if (++core[000173] == 010000) { core[000173] = 0; npc++; }; code[000173] = &emul8;  }
void P03614() { if (++core[000010] == 010000) { core[000010] = 0; npc++; }; code[000010] = &emul8;  }
void L03615() { lac += core[(df<<12)+core[1932]];  }
void I03616() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03617() { hlt = 1;  }
void I03620() { npc = (ib<<12)+core[1937]; inh = 0;  }
void P03621() { core[(df<<12)+core[1938]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1938]] = &emul8;  }
void P03622() { lac &= 010000;  }
void I03623() { npc = (ib<<12)+core[1940]; inh = 0;  }
void P03624() { lac += core[000173];  }
void P03625() { lac += core[000010];  }
void L03626() { lac += core[(df<<12)+core[1941]];  }
void I03627() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03630() { hlt = 1;  }
void I03631() { lac &= 010000;  }
void I03632() { core[(df<<12)+core[1941]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1941]] = &emul8;  }
void I03633() { lac &= 010000;  }
void I03634() { npc = (ib<<12)+core[1949]; inh = 0;  }
void P03635() { lac &= (010000|core[(df<<12)+core[124]]);  }
void P03636() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void L03637() { lac += core[(df<<12)+core[1950]];  }
void I03640() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03641() { hlt = 1;  }
void I03642() { lac &= 010000;  }
void I03643() { core[(df<<12)+core[1950]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1950]] = &emul8;  }
void I03644() { lac &= 010000;  }
void I03645() { npc = (ib<<12)+core[1958]; inh = 0;  }
void P03646() { lac &= (010000|core[003772]);  }
void P03647() { lac &= (010000|core[003610]);  }
void L03650() { lac += core[(df<<12)+core[1959]];  }
void I03651() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03652() { hlt = 1;  }
void I03653() { lac &= 010000;  }
void I03654() { core[(df<<12)+core[1959]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1959]] = &emul8;  }
void I03655() { lac &= 010000;  }
void I03656() { npc = (ib<<12)+core[1967]; inh = 0;  }
void P03657() { lac &= (010000|core[000130]);  }
void P03660() { lac &= (010000|core[000110]);  }
void L03661() { lac += core[(df<<12)+core[1968]];  }
void I03662() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03663() { hlt = 1;  }
void I03664() { lac &= 010000;  }
void I03665() { core[000110] = lac & 07777; lac &= 010000; code[000110] = &emul8;  }
void I03666() { lac &= 010000;  }
void I03667() { npc = (ib<<12)+core[1976]; inh = 0;  }
void P03670() { lac &= (010000|core[000124]);  }
void P03671() { lac &= (010000|core[000050]);  }
void L03672() { lac += core[(df<<12)+core[1977]];  }
void I03673() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03674() { hlt = 1;  }
void I03675() { lac &= 010000;  }
void I03676() { core[000050] = lac & 07777; lac &= 010000; code[000050] = &emul8;  }
void I03677() { lac &= 010000;  }
void I03700() { npc = (ib<<12)+core[1985]; inh = 0;  }
void P03701() { lac &= (010000|core[000120]);  }
void P03702() { lac &= (010000|core[000030]);  }
void L03703() { lac += core[(df<<12)+core[1986]];  }
void I03704() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03705() { hlt = 1;  }
void I03706() { lac &= 010000;  }
void I03707() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void I03710() { lac &= 010000;  }
void I03711() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I03712() { npc = (ib<<12)+core[1995]; inh = 0;  }
void P03713() { lac &= (010000|core[000074]);  }
void L03714() { lac += core[(df<<12)+core[30]];  }
void I03715() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03716() { hlt = 1;  }
void I03717() { lac &= 010000;  }
void I03720() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I03721() { lac &= 010000;  }
void I03722() { npc = (ib<<12)+core[2003]; inh = 0;  }
void P03723() { lac &= (010000|core[000070]);  }
void L03724() { lac += core[(df<<12)+core[38]];  }
void I03725() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03726() { hlt = 1;  }
void I03727() { lac &= 010000;  }
void I03730() { core[000007] = lac & 07777; lac &= 010000; code[000007] = &emul8;  }
void I03731() { lac += core[003747];  }
void I03732() { lac++;  }
void I03733() { core[003747] = lac & 07777; lac &= 010000; code[003747] = &emul8;  }
void I03734() { lac += core[003747];  }
void I03735() { lac += core[003750];  }
void I03736() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03737() { npc = (ib<<12)+core[2022]; inh = 0;  }
void I03740() { core[003747] = lac & 07777; lac &= 010000; code[003747] = &emul8;  }
void I03741() { lac += core[003751];  }
void I03742() { emul8();  }
void L03743() { emul8();  }
void I03744() { npc = 003743; inh = 0;  }
void I03745() { npc = (ib<<12)+core[2022]; inh = 0;  }
void P03746() { lac &= (010000|core[003600]);  }
void D03747() { lac &= (010000|core[000000]);  }
void D03750() { core[(ib<<12)+core[2034]] = 03751; npc = (ib<<12)+core[2034]+1; code[(ib<<12)+core[2034]] = &emul8; inh = 0;  }
void D03751() { lac &= (010000|core[003607]);  }
void L04000() { lac &= (010000|core[(df<<12)+core[2056]]);  }
void I04001() { npc = (ib<<12)+core[2050]; inh = 0;  }
void P04002() { core[(df<<12)+core[2052]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2052]] = &emul8;  }
void P04010() { lac &= (010000|core[000000]);  }
void S04011() { lac &= (010000|core[000000]);  }
void I04012() { lac += core[004020];  }
void I04013() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I04014() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I04015() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I04016() { if (++core[004011] == 010000) { core[004011] = 0; npc++; }; code[004011] = &emul8;  }
void I04017() { npc = (ib<<12)+core[2057]; inh = 0;  }
void D04020() { npc = (ib<<12)+core[2]; inh = 0;  }
void L04200() { lac &= 010000; lac &= 07777;  }
void I04201() { core[(ib<<12)+core[2178]] = 04202; npc = (ib<<12)+core[2178]+1; code[(ib<<12)+core[2178]] = &emul8; inh = 0;  }
void P04202() { core[000011] = 04203; npc = 000011+1; code[000011] = &emul8; inh = 0;  }
void I04203() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04204() { emul8();  }
void I04205() { skp = 0; skp = !skp; npc += skp;  }
void I04206() { hlt = 1;  }
void I04207() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04210() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04211() { hlt = 1;  }
void I04212() { emul8();  }
void I04213() { skp = 0; skp = !skp; npc += skp;  }
void I04214() { hlt = 1;  }
void I04215() { emul8();  }
void I04216() { hlt = 1;  }
void I04217() { emul8();  }
void I04220() { emul8();  }
void I04221() { skp = 0; skp = !skp; npc += skp;  }
void I04222() { hlt = 1;  }
void I04223() { emul8();  }
void I04224() { skp = 0; skp = !skp; npc += skp;  }
void I04225() { hlt = 1;  }
void I04226() { emul8();  }
void I04227() { emul8();  }
void I04230() { emul8();  }
void I04231() { hlt = 1;  }
void I04232() { emul8();  }
void I04233() { emul8();  }
void I04234() { skp = 0; skp = !skp; npc += skp;  }
void I04235() { hlt = 1;  }
void I04236() { emul8();  }
void I04237() { emul8();  }
void I04240() { hlt = 1;  }
void I04241() { emul8();  }
void I04242() { skp = 0; skp = !skp; npc += skp;  }
void I04243() { hlt = 1;  }
void I04244() { lac &= 010000; lac++;  }
void I04245() { emul8();  }
void I04246() { emul8();  }
void I04247() { emul8();  }
void I04250() { hlt = 1;  }
void I04251() { emul8();  }
void I04252() { hlt = 1;  }
void I04253() { emul8();  }
void I04254() { lac += core[004267];  }
void I04255() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I04256() { emul8();  }
void I04257() { skp = 0; skp = !skp; npc += skp;  }
void I04260() { hlt = 1;  }
void I04261() { emul8();  }
void I04262() { hlt = 1;  }
void I04263() { emul8();  }
void I04264() { skp = 0; skp = !skp; npc += skp;  }
void I04265() { hlt = 1;  }
void I04266() { npc = 004271; inh = 0;  }
void D04267() { core[004270] = 04270; npc = 004270+1; code[004270] = &emul8; inh = 0;  }
void I04270() { hlt = 1;  }
void L04271() { emul8();  }
void I04272() { lac += core[004304];  }
void I04273() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I04274() { emul8();  }
void I04275() { emul8();  }
void I04276() { skp = 0; skp = !skp; npc += skp;  }
void I04277() { hlt = 1;  }
void I04300() { emul8();  }
void I04301() { skp = 0; skp = !skp; npc += skp;  }
void I04302() { hlt = 1;  }
void I04303() { npc = 004306; inh = 0;  }
void D04304() { core[004305] = 04305; npc = 004305+1; code[004305] = &emul8; inh = 0;  }
void I04305() { hlt = 1;  }
void L04306() { emul8();  }
void I04307() { lac ^= 07777;  }
void I04310() { emul8();  }
void I04311() { skp = 0; skp = !skp; npc += skp;  }
void I04312() { hlt = 1;  }
void I04313() { lac &= (010000|core[000064]);  }
void I04314() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04315() { hlt = 1;  }
void I04316() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04317() { emul8();  }
void I04320() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04321() { hlt = 1;  }
void I04322() { lac &= (010000|core[000064]);  }
void I04323() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I04324() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04325() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04326() { hlt = 1;  }
void I04327() { emul8();  }
void I04330() { emul8();  }
void I04331() { emul8();  }
void I04332() { lac &= (010000|core[000064]);  }
void I04333() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04334() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04335() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04336() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04337() { hlt = 1;  }
void I04340() { emul8();  }
void I04341() { lac += core[004356];  }
void I04342() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I04343() { emul8();  }
void I04344() { emul8();  }
void I04345() { lac &= (010000|core[000064]);  }
void I04346() { emul8();  }
void I04347() { hlt = 1;  }
void I04350() { lac &= 07777; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I04351() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04352() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04353() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04354() { hlt = 1;  }
void I04355() { npc = 004360; inh = 0;  }
void D04356() { core[004357] = 04357; npc = 004357+1; code[004357] = &emul8; inh = 0;  }
void I04357() { hlt = 1;  }
void L04360() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04361() { lac += core[004375];  }
void I04362() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I04363() { emul8();  }
void I04364() { skp = 0; skp = !skp; npc += skp;  }
void I04365() { hlt = 1;  }
void I04366() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04367() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04370() { hlt = 1;  }
void I04371() { emul8();  }
void I04372() { hlt = 1;  }
void I04373() { npc = (ib<<12)+core[2300]; inh = 0;  }
void P04374() { core[(ib<<12)+core[0]] = 04375; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void D04375() { core[004376] = 04376; npc = 004376+1; code[004376] = &emul8; inh = 0;  }
void I04376() { hlt = 1;  }
void L04400() { emul8();  }
void I04401() { lac += core[004415];  }
void I04402() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I04403() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04404() { emul8();  }
void I04405() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04406() { hlt = 1;  }
void I04407() { emul8();  }
void I04410() { hlt = 1;  }
void I04411() { emul8();  }
void I04412() { lac &= 010000; lac &= 07777;  }
void I04413() { npc = (ib<<12)+core[2316]; inh = 0;  }
void P04414() { if (++core[(df<<12)+core[2367]] == 010000) { core[(df<<12)+core[2367]] = 0; npc++; }; code[(df<<12)+core[2367]] = &emul8;  }
void D04415() { if (++core[000016] == 010000) core[000016] = 0000;core[(ib<<12)+core[000016]] = 04416; npc = (ib<<12)+core[000016]+1; code[(ib<<12)+core[000016]] = &emul8; inh = 0;  }
void I04416() { hlt = 1;  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &L00001;
  core[000002] = 00002; code[000002] = &P00002;
  core[000003] = 00003; code[000003] = &D00003;
  core[000007] = 00000; code[000007] = &P00007;
  core[000020] = 07777; code[000020] = &D00020;
  core[000021] = 03777; code[000021] = &D00021;
  core[000022] = 05777; code[000022] = &D00022;
  core[000023] = 06777; code[000023] = &D00023;
  core[000024] = 07377; code[000024] = &D00024;
  core[000025] = 07577; code[000025] = &D00025;
  core[000026] = 07677; code[000026] = &D00026;
  core[000027] = 07737; code[000027] = &D00027;
  core[000030] = 00000; code[000030] = &P00030;
  core[000031] = 07757; code[000031] = &D00031;
  core[000032] = 07767; code[000032] = &D00032;
  core[000033] = 07773; code[000033] = &D00033;
  core[000034] = 07775; code[000034] = &D00034;
  core[000035] = 07776; code[000035] = &D00035;
  core[000036] = 00000; code[000036] = &P00036;
  core[000037] = 01777; code[000037] = &D00037;
  core[000040] = 00777; code[000040] = &D00040;
  core[000041] = 00377; code[000041] = &D00041;
  core[000042] = 00177; code[000042] = &P00042;
  core[000043] = 00077; code[000043] = &D00043;
  core[000044] = 00037; code[000044] = &P00044;
  core[000045] = 00017; code[000045] = &D00045;
  core[000046] = 00007; code[000046] = &P00046;
  core[000047] = 00003; code[000047] = &D00047;
  core[000050] = 00000; code[000050] = &P00050;
  core[000051] = 00001; code[000051] = &D00051;
  core[000052] = 04400; code[000052] = &L00052;
  core[000053] = 04577; code[000053] = &D00053;
  core[000054] = 02525; code[000054] = &D00054;
  core[000055] = 06666; code[000055] = &D00055;
  core[000056] = 04444; code[000056] = &D00056;
  core[000057] = 07070; code[000057] = &D00057;
  core[000060] = 00707; code[000060] = &D00060;
  core[000061] = 05252; code[000061] = &P00061;
  core[000062] = 01111; code[000062] = &D00062;
  core[000063] = 05555; code[000063] = &D00063;
  core[000064] = 05200; code[000064] = &D00064;
  core[000065] = 00004; code[000065] = &D00065;
  core[000070] = 00407; code[000070] = &L00070;
  core[000071] = 05472; code[000071] = &I00071;
  core[000072] = 03724; code[000072] = &P00072;
  core[000074] = 00400; code[000074] = &L00074;
  core[000075] = 05476; code[000075] = &I00075;
  core[000076] = 03714; code[000076] = &P00076;
  core[000110] = 00000; code[000110] = &P00110;
  core[000120] = 00430; code[000120] = &L00120;
  core[000121] = 05522; code[000121] = &D00121;
  core[000122] = 03703; code[000122] = &P00122;
  core[000124] = 00450; code[000124] = &P00124;
  core[000125] = 05526; code[000125] = &P00125;
  core[000126] = 03672; code[000126] = &P00126;
  core[000130] = 00510; code[000130] = &L00130;
  core[000131] = 05532; code[000131] = &I00131;
  core[000132] = 03661; code[000132] = &P00132;
  core[000172] = 00176; code[000172] = &P00172;
  core[000173] = 00172; code[000173] = &P00173;
  core[000174] = 00173; code[000174] = &P00174;
  core[000175] = 00174; code[000175] = &P00175;
  core[000176] = 00175; code[000176] = &P00176;
  core[000177] = 01234; code[000177] = &P00177;
  core[000200] = 07200; code[000200] = &L00200;
  core[000201] = 07410; code[000201] = &I00201;
  core[000202] = 00000; code[000202] = &D00202;
  core[000203] = 01052; code[000203] = &I00203;
  core[000204] = 03377; code[000204] = &I00204;
  core[000205] = 07440; code[000205] = &I00205;
  core[000206] = 07402; code[000206] = &I00206;
  core[000207] = 07410; code[000207] = &I00207;
  core[000210] = 00000; code[000210] = &P00210;
  core[000211] = 01052; code[000211] = &I00211;
  core[000212] = 07041; code[000212] = &I00212;
  core[000213] = 01377; code[000213] = &I00213;
  core[000214] = 07440; code[000214] = &I00214;
  core[000215] = 07402; code[000215] = &I00215;
  core[000216] = 07200; code[000216] = &I00216;
  core[000217] = 01053; code[000217] = &I00217;
  core[000220] = 03202; code[000220] = &I00220;
  core[000221] = 07440; code[000221] = &I00221;
  core[000222] = 07402; code[000222] = &I00222;
  core[000223] = 01053; code[000223] = &I00223;
  core[000224] = 07041; code[000224] = &I00224;
  core[000225] = 01202; code[000225] = &I00225;
  core[000226] = 07440; code[000226] = &I00226;
  core[000227] = 07402; code[000227] = &I00227;
  core[000230] = 07200; code[000230] = &I00230;
  core[000231] = 01020; code[000231] = &I00231;
  core[000232] = 03202; code[000232] = &I00232;
  core[000233] = 07440; code[000233] = &I00233;
  core[000234] = 07402; code[000234] = &I00234;
  core[000235] = 01202; code[000235] = &I00235;
  core[000236] = 07040; code[000236] = &I00236;
  core[000237] = 07440; code[000237] = &I00237;
  core[000240] = 07402; code[000240] = &I00240;
  core[000241] = 07200; code[000241] = &I00241;
  core[000242] = 01036; code[000242] = &I00242;
  core[000243] = 03202; code[000243] = &I00243;
  core[000244] = 07440; code[000244] = &I00244;
  core[000245] = 07402; code[000245] = &I00245;
  core[000246] = 01202; code[000246] = &I00246;
  core[000247] = 07440; code[000247] = &I00247;
  core[000250] = 07402; code[000250] = &P00250;
  core[000251] = 07200; code[000251] = &I00251;
  core[000252] = 01054; code[000252] = &I00252;
  core[000253] = 03202; code[000253] = &I00253;
  core[000254] = 07440; code[000254] = &I00254;
  core[000255] = 07402; code[000255] = &I00255;
  core[000256] = 01054; code[000256] = &I00256;
  core[000257] = 07041; code[000257] = &I00257;
  core[000260] = 01202; code[000260] = &I00260;
  core[000261] = 07440; code[000261] = &I00261;
  core[000262] = 07402; code[000262] = &I00262;
  core[000263] = 07200; code[000263] = &I00263;
  core[000264] = 01055; code[000264] = &I00264;
  core[000265] = 03202; code[000265] = &I00265;
  core[000266] = 07440; code[000266] = &I00266;
  core[000267] = 07402; code[000267] = &I00267;
  core[000270] = 01055; code[000270] = &I00270;
  core[000271] = 07041; code[000271] = &I00271;
  core[000272] = 01202; code[000272] = &I00272;
  core[000273] = 07440; code[000273] = &I00273;
  core[000274] = 07402; code[000274] = &I00274;
  core[000275] = 07200; code[000275] = &I00275;
  core[000276] = 01056; code[000276] = &I00276;
  core[000277] = 03377; code[000277] = &I00277;
  core[000300] = 07440; code[000300] = &I00300;
  core[000301] = 07402; code[000301] = &I00301;
  core[000302] = 01056; code[000302] = &I00302;
  core[000303] = 07041; code[000303] = &I00303;
  core[000304] = 01377; code[000304] = &I00304;
  core[000305] = 07440; code[000305] = &I00305;
  core[000306] = 07402; code[000306] = &I00306;
  core[000307] = 07200; code[000307] = &I00307;
  core[000310] = 01057; code[000310] = &I00310;
  core[000311] = 03377; code[000311] = &I00311;
  core[000312] = 07440; code[000312] = &I00312;
  core[000313] = 07402; code[000313] = &I00313;
  core[000314] = 01057; code[000314] = &I00314;
  core[000315] = 07041; code[000315] = &I00315;
  core[000316] = 01377; code[000316] = &I00316;
  core[000317] = 07440; code[000317] = &I00317;
  core[000320] = 07402; code[000320] = &I00320;
  core[000321] = 07200; code[000321] = &I00321;
  core[000322] = 01060; code[000322] = &I00322;
  core[000323] = 03000; code[000323] = &I00323;
  core[000324] = 07440; code[000324] = &I00324;
  core[000325] = 07402; code[000325] = &I00325;
  core[000326] = 01060; code[000326] = &I00326;
  core[000327] = 07041; code[000327] = &I00327;
  core[000330] = 01000; code[000330] = &I00330;
  core[000331] = 07440; code[000331] = &I00331;
  core[000332] = 07402; code[000332] = &I00332;
  core[000333] = 07200; code[000333] = &I00333;
  core[000334] = 01061; code[000334] = &I00334;
  core[000335] = 03000; code[000335] = &I00335;
  core[000336] = 07440; code[000336] = &I00336;
  core[000337] = 07402; code[000337] = &I00337;
  core[000340] = 01061; code[000340] = &I00340;
  core[000341] = 07041; code[000341] = &I00341;
  core[000342] = 01000; code[000342] = &I00342;
  core[000343] = 07440; code[000343] = &I00343;
  core[000344] = 07402; code[000344] = &I00344;
  core[000345] = 07200; code[000345] = &I00345;
  core[000346] = 01062; code[000346] = &I00346;
  core[000347] = 03000; code[000347] = &I00347;
  core[000350] = 07440; code[000350] = &I00350;
  core[000351] = 07402; code[000351] = &I00351;
  core[000352] = 01062; code[000352] = &I00352;
  core[000353] = 07041; code[000353] = &I00353;
  core[000354] = 01000; code[000354] = &I00354;
  core[000355] = 07440; code[000355] = &I00355;
  core[000356] = 07402; code[000356] = &I00356;
  core[000357] = 07200; code[000357] = &I00357;
  core[000360] = 01063; code[000360] = &I00360;
  core[000361] = 03000; code[000361] = &I00361;
  core[000362] = 07440; code[000362] = &I00362;
  core[000363] = 07402; code[000363] = &I00363;
  core[000364] = 01063; code[000364] = &I00364;
  core[000365] = 07041; code[000365] = &I00365;
  core[000366] = 01000; code[000366] = &I00366;
  core[000367] = 07440; code[000367] = &I00367;
  core[000370] = 07402; code[000370] = &I00370;
  core[000371] = 05375; code[000371] = &I00371;
  core[000372] = 00610; code[000372] = &L00372;
  core[000373] = 05774; code[000373] = &I00373;
  core[000374] = 03650; code[000374] = &P00374;
  core[000375] = 07000; code[000375] = &L00375;
  core[000376] = 07410; code[000376] = &I00376;
  core[000377] = 00000; code[000377] = &D00377;
  core[000400] = 07200; code[000400] = &I00400;
  core[000401] = 01442; code[000401] = &I00401;
  core[000402] = 07041; code[000402] = &I00402;
  core[000403] = 01177; code[000403] = &I00403;
  core[000404] = 07440; code[000404] = &I00404;
  core[000405] = 07402; code[000405] = &I00405;
  core[000406] = 07200; code[000406] = &I00406;
  core[000407] = 07410; code[000407] = &I00407;
  core[000410] = 00000; code[000410] = &P00410;
  core[000411] = 01020; code[000411] = &I00411;
  core[000412] = 00442; code[000412] = &I00412;
  core[000413] = 07041; code[000413] = &I00413;
  core[000414] = 01177; code[000414] = &I00414;
  core[000415] = 07440; code[000415] = &I00415;
  core[000416] = 07402; code[000416] = &I00416;
  core[000417] = 07200; code[000417] = &I00417;
  core[000420] = 01020; code[000420] = &I00420;
  core[000421] = 03000; code[000421] = &I00421;
  core[000422] = 02436; code[000422] = &I00422;
  core[000423] = 07402; code[000423] = &I00423;
  core[000424] = 01000; code[000424] = &I00424;
  core[000425] = 07440; code[000425] = &I00425;
  core[000426] = 07402; code[000426] = &I00426;
  core[000427] = 07200; code[000427] = &I00427;
  core[000430] = 01572; code[000430] = &I00430;
  core[000431] = 07041; code[000431] = &I00431;
  core[000432] = 01176; code[000432] = &I00432;
  core[000433] = 07440; code[000433] = &I00433;
  core[000434] = 07402; code[000434] = &I00434;
  core[000435] = 07200; code[000435] = &I00435;
  core[000436] = 01020; code[000436] = &I00436;
  core[000437] = 00572; code[000437] = &P00437;
  core[000440] = 07041; code[000440] = &I00440;
  core[000441] = 01176; code[000441] = &I00441;
  core[000442] = 07440; code[000442] = &I00442;
  core[000443] = 07402; code[000443] = &I00443;
  core[000444] = 07200; code[000444] = &I00444;
  core[000445] = 01172; code[000445] = &I00445;
  core[000446] = 03000; code[000446] = &I00446;
  core[000447] = 02436; code[000447] = &I00447;
  core[000450] = 07410; code[000450] = &D00450;
  core[000451] = 07402; code[000451] = &I00451;
  core[000452] = 01000; code[000452] = &I00452;
  core[000453] = 07041; code[000453] = &I00453;
  core[000454] = 01172; code[000454] = &I00454;
  core[000455] = 07040; code[000455] = &I00455;
  core[000456] = 07440; code[000456] = &I00456;
  core[000457] = 07402; code[000457] = &I00457;
  core[000460] = 07200; code[000460] = &I00460;
  core[000461] = 01573; code[000461] = &I00461;
  core[000462] = 07041; code[000462] = &I00462;
  core[000463] = 01172; code[000463] = &I00463;
  core[000464] = 07440; code[000464] = &I00464;
  core[000465] = 07402; code[000465] = &I00465;
  core[000466] = 07200; code[000466] = &I00466;
  core[000467] = 01020; code[000467] = &I00467;
  core[000470] = 00573; code[000470] = &I00470;
  core[000471] = 07041; code[000471] = &I00471;
  core[000472] = 01172; code[000472] = &I00472;
  core[000473] = 07440; code[000473] = &I00473;
  core[000474] = 07402; code[000474] = &I00474;
  core[000475] = 07200; code[000475] = &I00475;
  core[000476] = 01173; code[000476] = &I00476;
  core[000477] = 03000; code[000477] = &I00477;
  core[000500] = 02436; code[000500] = &I00500;
  core[000501] = 07410; code[000501] = &I00501;
  core[000502] = 07402; code[000502] = &I00502;
  core[000503] = 01000; code[000503] = &I00503;
  core[000504] = 07041; code[000504] = &I00504;
  core[000505] = 01173; code[000505] = &I00505;
  core[000506] = 07040; code[000506] = &I00506;
  core[000507] = 07440; code[000507] = &I00507;
  core[000510] = 07402; code[000510] = &I00510;
  core[000511] = 07200; code[000511] = &I00511;
  core[000512] = 01574; code[000512] = &I00512;
  core[000513] = 07041; code[000513] = &I00513;
  core[000514] = 01173; code[000514] = &I00514;
  core[000515] = 07440; code[000515] = &I00515;
  core[000516] = 07402; code[000516] = &I00516;
  core[000517] = 07200; code[000517] = &I00517;
  core[000520] = 01020; code[000520] = &I00520;
  core[000521] = 00574; code[000521] = &I00521;
  core[000522] = 07041; code[000522] = &I00522;
  core[000523] = 01173; code[000523] = &I00523;
  core[000524] = 07440; code[000524] = &I00524;
  core[000525] = 07402; code[000525] = &I00525;
  core[000526] = 07200; code[000526] = &I00526;
  core[000527] = 01174; code[000527] = &I00527;
  core[000530] = 03000; code[000530] = &I00530;
  core[000531] = 02436; code[000531] = &I00531;
  core[000532] = 07410; code[000532] = &I00532;
  core[000533] = 07402; code[000533] = &I00533;
  core[000534] = 01000; code[000534] = &I00534;
  core[000535] = 07041; code[000535] = &I00535;
  core[000536] = 01174; code[000536] = &I00536;
  core[000537] = 07040; code[000537] = &I00537;
  core[000540] = 07440; code[000540] = &I00540;
  core[000541] = 07402; code[000541] = &I00541;
  core[000542] = 07200; code[000542] = &I00542;
  core[000543] = 01575; code[000543] = &I00543;
  core[000544] = 07041; code[000544] = &I00544;
  core[000545] = 01174; code[000545] = &I00545;
  core[000546] = 07440; code[000546] = &I00546;
  core[000547] = 07402; code[000547] = &I00547;
  core[000550] = 07200; code[000550] = &I00550;
  core[000551] = 01020; code[000551] = &I00551;
  core[000552] = 00575; code[000552] = &I00552;
  core[000553] = 07041; code[000553] = &I00553;
  core[000554] = 01174; code[000554] = &I00554;
  core[000555] = 07440; code[000555] = &I00555;
  core[000556] = 07402; code[000556] = &I00556;
  core[000557] = 07200; code[000557] = &I00557;
  core[000560] = 01175; code[000560] = &I00560;
  core[000561] = 03000; code[000561] = &I00561;
  core[000562] = 02436; code[000562] = &I00562;
  core[000563] = 07410; code[000563] = &I00563;
  core[000564] = 07402; code[000564] = &I00564;
  core[000565] = 01000; code[000565] = &I00565;
  core[000566] = 07041; code[000566] = &I00566;
  core[000567] = 01175; code[000567] = &I00567;
  core[000570] = 07040; code[000570] = &I00570;
  core[000571] = 07440; code[000571] = &I00571;
  core[000572] = 07402; code[000572] = &D00572;
  core[000573] = 05377; code[000573] = &I00573;
  core[000574] = 00610; code[000574] = &L00574;
  core[000575] = 05776; code[000575] = &I00575;
  core[000576] = 03637; code[000576] = &P00576;
  core[000577] = 07000; code[000577] = &L00577;
  core[000600] = 07200; code[000600] = &I00600;
  core[000601] = 01576; code[000601] = &I00601;
  core[000602] = 07041; code[000602] = &I00602;
  core[000603] = 01175; code[000603] = &I00603;
  core[000604] = 07440; code[000604] = &I00604;
  core[000605] = 07402; code[000605] = &I00605;
  core[000606] = 07200; code[000606] = &I00606;
  core[000607] = 01036; code[000607] = &I00607;
  core[000610] = 03010; code[000610] = &I00610;
  core[000611] = 00410; code[000611] = &I00611;
  core[000612] = 01010; code[000612] = &I00612;
  core[000613] = 01035; code[000613] = &I00613;
  core[000614] = 07040; code[000614] = &I00614;
  core[000615] = 07440; code[000615] = &I00615;
  core[000616] = 07402; code[000616] = &I00616;
  core[000617] = 07200; code[000617] = &I00617;
  core[000620] = 01035; code[000620] = &I00620;
  core[000621] = 03010; code[000621] = &I00621;
  core[000622] = 00410; code[000622] = &I00622;
  core[000623] = 01010; code[000623] = &I00623;
  core[000624] = 01036; code[000624] = &I00624;
  core[000625] = 07040; code[000625] = &I00625;
  core[000626] = 07440; code[000626] = &I00626;
  core[000627] = 07402; code[000627] = &I00627;
  core[000630] = 07200; code[000630] = &I00630;
  core[000631] = 01034; code[000631] = &I00631;
  core[000632] = 03010; code[000632] = &I00632;
  core[000633] = 03410; code[000633] = &I00633;
  core[000634] = 01010; code[000634] = &I00634;
  core[000635] = 01051; code[000635] = &I00635;
  core[000636] = 07040; code[000636] = &I00636;
  core[000637] = 07440; code[000637] = &I00637;
  core[000640] = 07402; code[000640] = &I00640;
  core[000641] = 07200; code[000641] = &I00641;
  core[000642] = 01033; code[000642] = &I00642;
  core[000643] = 03010; code[000643] = &I00643;
  core[000644] = 01410; code[000644] = &I00644;
  core[000645] = 07200; code[000645] = &I00645;
  core[000646] = 01010; code[000646] = &I00646;
  core[000647] = 01047; code[000647] = &I00647;
  core[000650] = 07040; code[000650] = &I00650;
  core[000651] = 07440; code[000651] = &I00651;
  core[000652] = 07402; code[000652] = &I00652;
  core[000653] = 07200; code[000653] = &I00653;
  core[000654] = 01032; code[000654] = &I00654;
  core[000655] = 03010; code[000655] = &I00655;
  core[000656] = 00410; code[000656] = &I00656;
  core[000657] = 01010; code[000657] = &I00657;
  core[000660] = 01046; code[000660] = &I00660;
  core[000661] = 07040; code[000661] = &I00661;
  core[000662] = 07440; code[000662] = &I00662;
  core[000663] = 07402; code[000663] = &I00663;
  core[000664] = 07200; code[000664] = &I00664;
  core[000665] = 01031; code[000665] = &I00665;
  core[000666] = 03010; code[000666] = &I00666;
  core[000667] = 00410; code[000667] = &I00667;
  core[000670] = 01010; code[000670] = &I00670;
  core[000671] = 01045; code[000671] = &I00671;
  core[000672] = 07040; code[000672] = &I00672;
  core[000673] = 07440; code[000673] = &I00673;
  core[000674] = 07402; code[000674] = &I00674;
  core[000675] = 07200; code[000675] = &I00675;
  core[000676] = 01027; code[000676] = &I00676;
  core[000677] = 03010; code[000677] = &I00677;
  core[000700] = 00410; code[000700] = &I00700;
  core[000701] = 01010; code[000701] = &I00701;
  core[000702] = 01044; code[000702] = &I00702;
  core[000703] = 07040; code[000703] = &I00703;
  core[000704] = 07440; code[000704] = &I00704;
  core[000705] = 07402; code[000705] = &I00705;
  core[000706] = 07200; code[000706] = &I00706;
  core[000707] = 01026; code[000707] = &I00707;
  core[000710] = 03010; code[000710] = &I00710;
  core[000711] = 00410; code[000711] = &I00711;
  core[000712] = 01010; code[000712] = &I00712;
  core[000713] = 01043; code[000713] = &I00713;
  core[000714] = 07040; code[000714] = &I00714;
  core[000715] = 07440; code[000715] = &I00715;
  core[000716] = 07402; code[000716] = &I00716;
  core[000717] = 07200; code[000717] = &I00717;
  core[000720] = 01025; code[000720] = &I00720;
  core[000721] = 03010; code[000721] = &I00721;
  core[000722] = 00410; code[000722] = &I00722;
  core[000723] = 01010; code[000723] = &I00723;
  core[000724] = 01042; code[000724] = &I00724;
  core[000725] = 07040; code[000725] = &I00725;
  core[000726] = 07440; code[000726] = &I00726;
  core[000727] = 07402; code[000727] = &I00727;
  core[000730] = 07200; code[000730] = &I00730;
  core[000731] = 01024; code[000731] = &I00731;
  core[000732] = 03010; code[000732] = &I00732;
  core[000733] = 00410; code[000733] = &I00733;
  core[000734] = 01010; code[000734] = &I00734;
  core[000735] = 01041; code[000735] = &I00735;
  core[000736] = 07040; code[000736] = &I00736;
  core[000737] = 07440; code[000737] = &I00737;
  core[000740] = 07402; code[000740] = &I00740;
  core[000741] = 07200; code[000741] = &I00741;
  core[000742] = 01023; code[000742] = &I00742;
  core[000743] = 03010; code[000743] = &I00743;
  core[000744] = 00410; code[000744] = &I00744;
  core[000745] = 01010; code[000745] = &I00745;
  core[000746] = 01040; code[000746] = &I00746;
  core[000747] = 07040; code[000747] = &I00747;
  core[000750] = 07440; code[000750] = &I00750;
  core[000751] = 07402; code[000751] = &I00751;
  core[000752] = 07200; code[000752] = &I00752;
  core[000753] = 01022; code[000753] = &I00753;
  core[000754] = 03010; code[000754] = &I00754;
  core[000755] = 02410; code[000755] = &I00755;
  core[000756] = 07000; code[000756] = &I00756;
  core[000757] = 01010; code[000757] = &I00757;
  core[000760] = 01037; code[000760] = &I00760;
  core[000761] = 07040; code[000761] = &I00761;
  core[000762] = 07440; code[000762] = &I00762;
  core[000763] = 07402; code[000763] = &I00763;
  core[000764] = 07200; code[000764] = &I00764;
  core[000765] = 01021; code[000765] = &I00765;
  core[000766] = 03010; code[000766] = &I00766;
  core[000767] = 00410; code[000767] = &I00767;
  core[000770] = 01010; code[000770] = &I00770;
  core[000771] = 01021; code[000771] = &I00771;
  core[000772] = 07040; code[000772] = &I00772;
  core[000773] = 07440; code[000773] = &I00773;
  core[000774] = 07402; code[000774] = &I00774;
  core[000775] = 07000; code[000775] = &I00775;
  core[000776] = 07000; code[000776] = &I00776;
  core[000777] = 07000; code[000777] = &I00777;
  core[001000] = 07200; code[001000] = &I01000;
  core[001001] = 01020; code[001001] = &I01001;
  core[001002] = 03010; code[001002] = &I01002;
  core[001003] = 00410; code[001003] = &I01003;
  core[001004] = 01010; code[001004] = &I01004;
  core[001005] = 01020; code[001005] = &I01005;
  core[001006] = 07040; code[001006] = &I01006;
  core[001007] = 07410; code[001007] = &I01007;
  core[001010] = 00000; code[001010] = &P01010;
  core[001011] = 07440; code[001011] = &I01011;
  core[001012] = 07402; code[001012] = &I01012;
  core[001013] = 07200; code[001013] = &I01013;
  core[001014] = 01036; code[001014] = &I01014;
  core[001015] = 03011; code[001015] = &I01015;
  core[001016] = 00411; code[001016] = &I01016;
  core[001017] = 01011; code[001017] = &I01017;
  core[001020] = 01035; code[001020] = &I01020;
  core[001021] = 07040; code[001021] = &I01021;
  core[001022] = 07440; code[001022] = &I01022;
  core[001023] = 07402; code[001023] = &I01023;
  core[001024] = 07200; code[001024] = &I01024;
  core[001025] = 01035; code[001025] = &I01025;
  core[001026] = 03011; code[001026] = &P01026;
  core[001027] = 00411; code[001027] = &I01027;
  core[001030] = 01011; code[001030] = &I01030;
  core[001031] = 01036; code[001031] = &I01031;
  core[001032] = 07040; code[001032] = &I01032;
  core[001033] = 07440; code[001033] = &I01033;
  core[001034] = 07402; code[001034] = &I01034;
  core[001035] = 07200; code[001035] = &I01035;
  core[001036] = 01034; code[001036] = &I01036;
  core[001037] = 03011; code[001037] = &I01037;
  core[001040] = 03411; code[001040] = &I01040;
  core[001041] = 01011; code[001041] = &I01041;
  core[001042] = 01051; code[001042] = &I01042;
  core[001043] = 07040; code[001043] = &I01043;
  core[001044] = 07440; code[001044] = &I01044;
  core[001045] = 07402; code[001045] = &I01045;
  core[001046] = 07200; code[001046] = &I01046;
  core[001047] = 01033; code[001047] = &I01047;
  core[001050] = 03011; code[001050] = &I01050;
  core[001051] = 01411; code[001051] = &I01051;
  core[001052] = 07200; code[001052] = &I01052;
  core[001053] = 01011; code[001053] = &I01053;
  core[001054] = 01047; code[001054] = &I01054;
  core[001055] = 07040; code[001055] = &I01055;
  core[001056] = 07440; code[001056] = &I01056;
  core[001057] = 07402; code[001057] = &I01057;
  core[001060] = 07200; code[001060] = &I01060;
  core[001061] = 01032; code[001061] = &I01061;
  core[001062] = 03011; code[001062] = &I01062;
  core[001063] = 00411; code[001063] = &I01063;
  core[001064] = 01011; code[001064] = &I01064;
  core[001065] = 01046; code[001065] = &I01065;
  core[001066] = 07040; code[001066] = &I01066;
  core[001067] = 07440; code[001067] = &I01067;
  core[001070] = 07402; code[001070] = &I01070;
  core[001071] = 07200; code[001071] = &I01071;
  core[001072] = 01031; code[001072] = &I01072;
  core[001073] = 03011; code[001073] = &I01073;
  core[001074] = 00411; code[001074] = &I01074;
  core[001075] = 01011; code[001075] = &I01075;
  core[001076] = 01045; code[001076] = &I01076;
  core[001077] = 07040; code[001077] = &I01077;
  core[001100] = 07440; code[001100] = &I01100;
  core[001101] = 07402; code[001101] = &I01101;
  core[001102] = 07200; code[001102] = &I01102;
  core[001103] = 01027; code[001103] = &I01103;
  core[001104] = 03011; code[001104] = &I01104;
  core[001105] = 00411; code[001105] = &I01105;
  core[001106] = 01011; code[001106] = &I01106;
  core[001107] = 01044; code[001107] = &I01107;
  core[001110] = 07040; code[001110] = &I01110;
  core[001111] = 07440; code[001111] = &I01111;
  core[001112] = 07402; code[001112] = &I01112;
  core[001113] = 07200; code[001113] = &I01113;
  core[001114] = 01026; code[001114] = &I01114;
  core[001115] = 03011; code[001115] = &I01115;
  core[001116] = 00411; code[001116] = &I01116;
  core[001117] = 01011; code[001117] = &I01117;
  core[001120] = 01043; code[001120] = &I01120;
  core[001121] = 07040; code[001121] = &I01121;
  core[001122] = 07440; code[001122] = &I01122;
  core[001123] = 07402; code[001123] = &I01123;
  core[001124] = 07200; code[001124] = &I01124;
  core[001125] = 01025; code[001125] = &I01125;
  core[001126] = 03011; code[001126] = &I01126;
  core[001127] = 00411; code[001127] = &I01127;
  core[001130] = 01011; code[001130] = &I01130;
  core[001131] = 01042; code[001131] = &I01131;
  core[001132] = 07040; code[001132] = &I01132;
  core[001133] = 07440; code[001133] = &I01133;
  core[001134] = 07402; code[001134] = &I01134;
  core[001135] = 07200; code[001135] = &I01135;
  core[001136] = 01024; code[001136] = &I01136;
  core[001137] = 03011; code[001137] = &I01137;
  core[001140] = 00411; code[001140] = &I01140;
  core[001141] = 01011; code[001141] = &I01141;
  core[001142] = 01041; code[001142] = &I01142;
  core[001143] = 07040; code[001143] = &I01143;
  core[001144] = 07440; code[001144] = &I01144;
  core[001145] = 07402; code[001145] = &I01145;
  core[001146] = 07200; code[001146] = &I01146;
  core[001147] = 01023; code[001147] = &I01147;
  core[001150] = 03011; code[001150] = &I01150;
  core[001151] = 00411; code[001151] = &I01151;
  core[001152] = 01011; code[001152] = &I01152;
  core[001153] = 01040; code[001153] = &I01153;
  core[001154] = 07040; code[001154] = &I01154;
  core[001155] = 07440; code[001155] = &I01155;
  core[001156] = 07402; code[001156] = &I01156;
  core[001157] = 07200; code[001157] = &I01157;
  core[001160] = 01022; code[001160] = &I01160;
  core[001161] = 03011; code[001161] = &I01161;
  core[001162] = 02411; code[001162] = &I01162;
  core[001163] = 07000; code[001163] = &I01163;
  core[001164] = 01011; code[001164] = &I01164;
  core[001165] = 01037; code[001165] = &I01165;
  core[001166] = 07040; code[001166] = &I01166;
  core[001167] = 07440; code[001167] = &I01167;
  core[001170] = 07402; code[001170] = &I01170;
  core[001171] = 07000; code[001171] = &I01171;
  core[001172] = 05376; code[001172] = &I01172;
  core[001173] = 00610; code[001173] = &L01173;
  core[001174] = 05775; code[001174] = &I01174;
  core[001175] = 03626; code[001175] = &P01175;
  core[001176] = 07000; code[001176] = &L01176;
  core[001177] = 07000; code[001177] = &I01177;
  core[001200] = 07200; code[001200] = &I01200;
  core[001201] = 01021; code[001201] = &I01201;
  core[001202] = 03011; code[001202] = &I01202;
  core[001203] = 00411; code[001203] = &I01203;
  core[001204] = 01011; code[001204] = &I01204;
  core[001205] = 01021; code[001205] = &I01205;
  core[001206] = 07040; code[001206] = &I01206;
  core[001207] = 07440; code[001207] = &I01207;
  core[001210] = 07402; code[001210] = &I01210;
  core[001211] = 07200; code[001211] = &I01211;
  core[001212] = 01020; code[001212] = &I01212;
  core[001213] = 03011; code[001213] = &I01213;
  core[001214] = 00411; code[001214] = &I01214;
  core[001215] = 01011; code[001215] = &I01215;
  core[001216] = 01020; code[001216] = &I01216;
  core[001217] = 07040; code[001217] = &I01217;
  core[001220] = 07440; code[001220] = &I01220;
  core[001221] = 07402; code[001221] = &I01221;
  core[001222] = 07200; code[001222] = &I01222;
  core[001223] = 01036; code[001223] = &I01223;
  core[001224] = 03012; code[001224] = &I01224;
  core[001225] = 00412; code[001225] = &I01225;
  core[001226] = 01012; code[001226] = &I01226;
  core[001227] = 01035; code[001227] = &I01227;
  core[001230] = 07040; code[001230] = &I01230;
  core[001231] = 07440; code[001231] = &I01231;
  core[001232] = 07402; code[001232] = &I01232;
  core[001233] = 07200; code[001233] = &I01233;
  core[001234] = 01035; code[001234] = &L01234;
  core[001235] = 03012; code[001235] = &I01235;
  core[001236] = 00412; code[001236] = &I01236;
  core[001237] = 01012; code[001237] = &I01237;
  core[001240] = 01036; code[001240] = &I01240;
  core[001241] = 07040; code[001241] = &I01241;
  core[001242] = 07440; code[001242] = &I01242;
  core[001243] = 07402; code[001243] = &I01243;
  core[001244] = 07200; code[001244] = &I01244;
  core[001245] = 01034; code[001245] = &I01245;
  core[001246] = 03012; code[001246] = &I01246;
  core[001247] = 03412; code[001247] = &I01247;
  core[001250] = 01012; code[001250] = &I01250;
  core[001251] = 01051; code[001251] = &I01251;
  core[001252] = 07040; code[001252] = &I01252;
  core[001253] = 07440; code[001253] = &I01253;
  core[001254] = 07402; code[001254] = &I01254;
  core[001255] = 07200; code[001255] = &I01255;
  core[001256] = 01033; code[001256] = &I01256;
  core[001257] = 03012; code[001257] = &I01257;
  core[001260] = 01412; code[001260] = &I01260;
  core[001261] = 07200; code[001261] = &I01261;
  core[001262] = 01012; code[001262] = &I01262;
  core[001263] = 01047; code[001263] = &I01263;
  core[001264] = 07040; code[001264] = &I01264;
  core[001265] = 07440; code[001265] = &I01265;
  core[001266] = 07402; code[001266] = &I01266;
  core[001267] = 07200; code[001267] = &I01267;
  core[001270] = 01032; code[001270] = &I01270;
  core[001271] = 03012; code[001271] = &I01271;
  core[001272] = 00412; code[001272] = &I01272;
  core[001273] = 01012; code[001273] = &I01273;
  core[001274] = 01046; code[001274] = &I01274;
  core[001275] = 07040; code[001275] = &I01275;
  core[001276] = 07440; code[001276] = &I01276;
  core[001277] = 07402; code[001277] = &I01277;
  core[001300] = 07200; code[001300] = &I01300;
  core[001301] = 01031; code[001301] = &I01301;
  core[001302] = 03012; code[001302] = &I01302;
  core[001303] = 00412; code[001303] = &I01303;
  core[001304] = 01012; code[001304] = &I01304;
  core[001305] = 01045; code[001305] = &I01305;
  core[001306] = 07040; code[001306] = &I01306;
  core[001307] = 07440; code[001307] = &I01307;
  core[001310] = 07402; code[001310] = &I01310;
  core[001311] = 07200; code[001311] = &I01311;
  core[001312] = 01027; code[001312] = &I01312;
  core[001313] = 03012; code[001313] = &I01313;
  core[001314] = 00412; code[001314] = &I01314;
  core[001315] = 01012; code[001315] = &I01315;
  core[001316] = 01044; code[001316] = &I01316;
  core[001317] = 07040; code[001317] = &I01317;
  core[001320] = 07440; code[001320] = &I01320;
  core[001321] = 07402; code[001321] = &I01321;
  core[001322] = 07200; code[001322] = &I01322;
  core[001323] = 01026; code[001323] = &I01323;
  core[001324] = 03012; code[001324] = &I01324;
  core[001325] = 00412; code[001325] = &I01325;
  core[001326] = 01012; code[001326] = &I01326;
  core[001327] = 01043; code[001327] = &I01327;
  core[001330] = 07040; code[001330] = &I01330;
  core[001331] = 07440; code[001331] = &I01331;
  core[001332] = 07402; code[001332] = &I01332;
  core[001333] = 07200; code[001333] = &I01333;
  core[001334] = 01025; code[001334] = &I01334;
  core[001335] = 03012; code[001335] = &I01335;
  core[001336] = 00412; code[001336] = &I01336;
  core[001337] = 01012; code[001337] = &I01337;
  core[001340] = 01042; code[001340] = &I01340;
  core[001341] = 07040; code[001341] = &I01341;
  core[001342] = 07440; code[001342] = &I01342;
  core[001343] = 07402; code[001343] = &I01343;
  core[001344] = 07200; code[001344] = &I01344;
  core[001345] = 01024; code[001345] = &I01345;
  core[001346] = 03012; code[001346] = &I01346;
  core[001347] = 00412; code[001347] = &I01347;
  core[001350] = 01012; code[001350] = &I01350;
  core[001351] = 01041; code[001351] = &I01351;
  core[001352] = 07040; code[001352] = &I01352;
  core[001353] = 07440; code[001353] = &I01353;
  core[001354] = 07402; code[001354] = &I01354;
  core[001355] = 07200; code[001355] = &I01355;
  core[001356] = 01023; code[001356] = &I01356;
  core[001357] = 03012; code[001357] = &I01357;
  core[001360] = 00412; code[001360] = &I01360;
  core[001361] = 01012; code[001361] = &I01361;
  core[001362] = 01040; code[001362] = &I01362;
  core[001363] = 07040; code[001363] = &I01363;
  core[001364] = 07440; code[001364] = &I01364;
  core[001365] = 07402; code[001365] = &I01365;
  core[001366] = 07200; code[001366] = &I01366;
  core[001367] = 01022; code[001367] = &I01367;
  core[001370] = 03012; code[001370] = &I01370;
  core[001371] = 02412; code[001371] = &I01371;
  core[001372] = 07000; code[001372] = &I01372;
  core[001373] = 01012; code[001373] = &I01373;
  core[001374] = 01037; code[001374] = &I01374;
  core[001375] = 07040; code[001375] = &I01375;
  core[001376] = 07440; code[001376] = &I01376;
  core[001377] = 07402; code[001377] = &I01377;
  core[001400] = 07200; code[001400] = &I01400;
  core[001401] = 01021; code[001401] = &I01401;
  core[001402] = 03012; code[001402] = &I01402;
  core[001403] = 00412; code[001403] = &I01403;
  core[001404] = 01012; code[001404] = &I01404;
  core[001405] = 01021; code[001405] = &I01405;
  core[001406] = 07040; code[001406] = &I01406;
  core[001407] = 07440; code[001407] = &I01407;
  core[001410] = 07402; code[001410] = &I01410;
  core[001411] = 07200; code[001411] = &I01411;
  core[001412] = 01020; code[001412] = &I01412;
  core[001413] = 03012; code[001413] = &I01413;
  core[001414] = 00412; code[001414] = &I01414;
  core[001415] = 01012; code[001415] = &I01415;
  core[001416] = 01020; code[001416] = &I01416;
  core[001417] = 07040; code[001417] = &I01417;
  core[001420] = 07440; code[001420] = &I01420;
  core[001421] = 07402; code[001421] = &I01421;
  core[001422] = 07200; code[001422] = &I01422;
  core[001423] = 01036; code[001423] = &I01423;
  core[001424] = 03013; code[001424] = &I01424;
  core[001425] = 00413; code[001425] = &I01425;
  core[001426] = 01013; code[001426] = &I01426;
  core[001427] = 01035; code[001427] = &I01427;
  core[001430] = 07040; code[001430] = &I01430;
  core[001431] = 07440; code[001431] = &I01431;
  core[001432] = 07402; code[001432] = &I01432;
  core[001433] = 07200; code[001433] = &I01433;
  core[001434] = 01035; code[001434] = &I01434;
  core[001435] = 03013; code[001435] = &I01435;
  core[001436] = 00413; code[001436] = &I01436;
  core[001437] = 01013; code[001437] = &I01437;
  core[001440] = 01036; code[001440] = &I01440;
  core[001441] = 07040; code[001441] = &I01441;
  core[001442] = 07440; code[001442] = &I01442;
  core[001443] = 07402; code[001443] = &I01443;
  core[001444] = 07200; code[001444] = &I01444;
  core[001445] = 01034; code[001445] = &I01445;
  core[001446] = 03013; code[001446] = &I01446;
  core[001447] = 03413; code[001447] = &I01447;
  core[001450] = 01013; code[001450] = &I01450;
  core[001451] = 01051; code[001451] = &I01451;
  core[001452] = 07040; code[001452] = &I01452;
  core[001453] = 07440; code[001453] = &I01453;
  core[001454] = 07402; code[001454] = &I01454;
  core[001455] = 07200; code[001455] = &I01455;
  core[001456] = 01033; code[001456] = &I01456;
  core[001457] = 03013; code[001457] = &I01457;
  core[001460] = 01413; code[001460] = &I01460;
  core[001461] = 07200; code[001461] = &I01461;
  core[001462] = 01013; code[001462] = &I01462;
  core[001463] = 01047; code[001463] = &I01463;
  core[001464] = 07040; code[001464] = &I01464;
  core[001465] = 07440; code[001465] = &I01465;
  core[001466] = 07402; code[001466] = &I01466;
  core[001467] = 07200; code[001467] = &I01467;
  core[001470] = 01032; code[001470] = &I01470;
  core[001471] = 03013; code[001471] = &I01471;
  core[001472] = 00413; code[001472] = &I01472;
  core[001473] = 01013; code[001473] = &I01473;
  core[001474] = 01046; code[001474] = &I01474;
  core[001475] = 07040; code[001475] = &I01475;
  core[001476] = 07440; code[001476] = &I01476;
  core[001477] = 07402; code[001477] = &I01477;
  core[001500] = 07200; code[001500] = &I01500;
  core[001501] = 01031; code[001501] = &I01501;
  core[001502] = 03013; code[001502] = &I01502;
  core[001503] = 00413; code[001503] = &I01503;
  core[001504] = 01013; code[001504] = &I01504;
  core[001505] = 01045; code[001505] = &I01505;
  core[001506] = 07040; code[001506] = &I01506;
  core[001507] = 07440; code[001507] = &I01507;
  core[001510] = 07402; code[001510] = &I01510;
  core[001511] = 07200; code[001511] = &I01511;
  core[001512] = 01027; code[001512] = &I01512;
  core[001513] = 03013; code[001513] = &I01513;
  core[001514] = 00413; code[001514] = &I01514;
  core[001515] = 01013; code[001515] = &I01515;
  core[001516] = 01044; code[001516] = &I01516;
  core[001517] = 07040; code[001517] = &I01517;
  core[001520] = 07440; code[001520] = &I01520;
  core[001521] = 07402; code[001521] = &I01521;
  core[001522] = 07200; code[001522] = &I01522;
  core[001523] = 01026; code[001523] = &I01523;
  core[001524] = 03013; code[001524] = &I01524;
  core[001525] = 00413; code[001525] = &I01525;
  core[001526] = 01013; code[001526] = &I01526;
  core[001527] = 01043; code[001527] = &I01527;
  core[001530] = 07040; code[001530] = &I01530;
  core[001531] = 07440; code[001531] = &I01531;
  core[001532] = 07402; code[001532] = &I01532;
  core[001533] = 07200; code[001533] = &I01533;
  core[001534] = 01025; code[001534] = &I01534;
  core[001535] = 03013; code[001535] = &I01535;
  core[001536] = 00413; code[001536] = &I01536;
  core[001537] = 01013; code[001537] = &I01537;
  core[001540] = 01042; code[001540] = &I01540;
  core[001541] = 07040; code[001541] = &I01541;
  core[001542] = 07440; code[001542] = &I01542;
  core[001543] = 07402; code[001543] = &I01543;
  core[001544] = 07200; code[001544] = &I01544;
  core[001545] = 01024; code[001545] = &I01545;
  core[001546] = 03013; code[001546] = &I01546;
  core[001547] = 00413; code[001547] = &I01547;
  core[001550] = 01013; code[001550] = &I01550;
  core[001551] = 01041; code[001551] = &I01551;
  core[001552] = 07040; code[001552] = &I01552;
  core[001553] = 07440; code[001553] = &I01553;
  core[001554] = 07402; code[001554] = &I01554;
  core[001555] = 07200; code[001555] = &I01555;
  core[001556] = 01023; code[001556] = &I01556;
  core[001557] = 03013; code[001557] = &I01557;
  core[001560] = 00413; code[001560] = &I01560;
  core[001561] = 01013; code[001561] = &I01561;
  core[001562] = 01040; code[001562] = &I01562;
  core[001563] = 07040; code[001563] = &I01563;
  core[001564] = 07440; code[001564] = &I01564;
  core[001565] = 07402; code[001565] = &I01565;
  core[001566] = 07200; code[001566] = &I01566;
  core[001567] = 01022; code[001567] = &I01567;
  core[001570] = 03013; code[001570] = &I01570;
  core[001571] = 02413; code[001571] = &I01571;
  core[001572] = 07000; code[001572] = &I01572;
  core[001573] = 01013; code[001573] = &I01573;
  core[001574] = 01037; code[001574] = &I01574;
  core[001575] = 07040; code[001575] = &I01575;
  core[001576] = 07440; code[001576] = &I01576;
  core[001577] = 07402; code[001577] = &I01577;
  core[001600] = 07200; code[001600] = &I01600;
  core[001601] = 01021; code[001601] = &I01601;
  core[001602] = 03013; code[001602] = &I01602;
  core[001603] = 00413; code[001603] = &I01603;
  core[001604] = 01013; code[001604] = &I01604;
  core[001605] = 01021; code[001605] = &I01605;
  core[001606] = 07040; code[001606] = &I01606;
  core[001607] = 07440; code[001607] = &I01607;
  core[001610] = 07402; code[001610] = &I01610;
  core[001611] = 07200; code[001611] = &I01611;
  core[001612] = 01020; code[001612] = &I01612;
  core[001613] = 03013; code[001613] = &I01613;
  core[001614] = 00413; code[001614] = &I01614;
  core[001615] = 01013; code[001615] = &I01615;
  core[001616] = 01020; code[001616] = &I01616;
  core[001617] = 07040; code[001617] = &I01617;
  core[001620] = 07440; code[001620] = &I01620;
  core[001621] = 07402; code[001621] = &I01621;
  core[001622] = 07200; code[001622] = &I01622;
  core[001623] = 01036; code[001623] = &I01623;
  core[001624] = 03014; code[001624] = &I01624;
  core[001625] = 00414; code[001625] = &I01625;
  core[001626] = 01014; code[001626] = &I01626;
  core[001627] = 01035; code[001627] = &I01627;
  core[001630] = 07040; code[001630] = &I01630;
  core[001631] = 07440; code[001631] = &I01631;
  core[001632] = 07402; code[001632] = &I01632;
  core[001633] = 07200; code[001633] = &I01633;
  core[001634] = 01035; code[001634] = &I01634;
  core[001635] = 03014; code[001635] = &I01635;
  core[001636] = 00414; code[001636] = &I01636;
  core[001637] = 01014; code[001637] = &I01637;
  core[001640] = 01036; code[001640] = &I01640;
  core[001641] = 07040; code[001641] = &I01641;
  core[001642] = 07440; code[001642] = &I01642;
  core[001643] = 07402; code[001643] = &I01643;
  core[001644] = 07200; code[001644] = &I01644;
  core[001645] = 01034; code[001645] = &I01645;
  core[001646] = 03014; code[001646] = &I01646;
  core[001647] = 03414; code[001647] = &I01647;
  core[001650] = 01014; code[001650] = &I01650;
  core[001651] = 01051; code[001651] = &I01651;
  core[001652] = 07040; code[001652] = &I01652;
  core[001653] = 07440; code[001653] = &I01653;
  core[001654] = 07402; code[001654] = &I01654;
  core[001655] = 07200; code[001655] = &I01655;
  core[001656] = 01033; code[001656] = &I01656;
  core[001657] = 03014; code[001657] = &I01657;
  core[001660] = 01414; code[001660] = &I01660;
  core[001661] = 07200; code[001661] = &I01661;
  core[001662] = 01014; code[001662] = &I01662;
  core[001663] = 01047; code[001663] = &I01663;
  core[001664] = 07040; code[001664] = &I01664;
  core[001665] = 07440; code[001665] = &I01665;
  core[001666] = 07402; code[001666] = &I01666;
  core[001667] = 07200; code[001667] = &I01667;
  core[001670] = 01032; code[001670] = &I01670;
  core[001671] = 03014; code[001671] = &I01671;
  core[001672] = 00414; code[001672] = &I01672;
  core[001673] = 01014; code[001673] = &I01673;
  core[001674] = 01046; code[001674] = &I01674;
  core[001675] = 07040; code[001675] = &I01675;
  core[001676] = 07440; code[001676] = &I01676;
  core[001677] = 07402; code[001677] = &I01677;
  core[001700] = 07200; code[001700] = &I01700;
  core[001701] = 01031; code[001701] = &I01701;
  core[001702] = 03014; code[001702] = &I01702;
  core[001703] = 00414; code[001703] = &I01703;
  core[001704] = 01014; code[001704] = &I01704;
  core[001705] = 01045; code[001705] = &I01705;
  core[001706] = 07040; code[001706] = &I01706;
  core[001707] = 07440; code[001707] = &I01707;
  core[001710] = 07402; code[001710] = &I01710;
  core[001711] = 07200; code[001711] = &I01711;
  core[001712] = 01027; code[001712] = &I01712;
  core[001713] = 03014; code[001713] = &I01713;
  core[001714] = 00414; code[001714] = &I01714;
  core[001715] = 01014; code[001715] = &I01715;
  core[001716] = 01044; code[001716] = &I01716;
  core[001717] = 07040; code[001717] = &I01717;
  core[001720] = 07440; code[001720] = &I01720;
  core[001721] = 07402; code[001721] = &I01721;
  core[001722] = 07200; code[001722] = &I01722;
  core[001723] = 01026; code[001723] = &I01723;
  core[001724] = 03014; code[001724] = &I01724;
  core[001725] = 00414; code[001725] = &I01725;
  core[001726] = 01014; code[001726] = &I01726;
  core[001727] = 01043; code[001727] = &I01727;
  core[001730] = 07040; code[001730] = &I01730;
  core[001731] = 07440; code[001731] = &I01731;
  core[001732] = 07402; code[001732] = &I01732;
  core[001733] = 07200; code[001733] = &I01733;
  core[001734] = 01025; code[001734] = &I01734;
  core[001735] = 03014; code[001735] = &I01735;
  core[001736] = 00414; code[001736] = &I01736;
  core[001737] = 01014; code[001737] = &I01737;
  core[001740] = 01042; code[001740] = &I01740;
  core[001741] = 07040; code[001741] = &I01741;
  core[001742] = 07440; code[001742] = &I01742;
  core[001743] = 07402; code[001743] = &I01743;
  core[001744] = 07200; code[001744] = &I01744;
  core[001745] = 01024; code[001745] = &I01745;
  core[001746] = 03014; code[001746] = &I01746;
  core[001747] = 00414; code[001747] = &I01747;
  core[001750] = 01014; code[001750] = &I01750;
  core[001751] = 01041; code[001751] = &I01751;
  core[001752] = 07040; code[001752] = &I01752;
  core[001753] = 07440; code[001753] = &I01753;
  core[001754] = 07402; code[001754] = &I01754;
  core[001755] = 07200; code[001755] = &I01755;
  core[001756] = 01023; code[001756] = &I01756;
  core[001757] = 03014; code[001757] = &I01757;
  core[001760] = 00414; code[001760] = &I01760;
  core[001761] = 01014; code[001761] = &I01761;
  core[001762] = 01040; code[001762] = &I01762;
  core[001763] = 07040; code[001763] = &I01763;
  core[001764] = 07440; code[001764] = &I01764;
  core[001765] = 07402; code[001765] = &I01765;
  core[001766] = 07200; code[001766] = &I01766;
  core[001767] = 01022; code[001767] = &I01767;
  core[001770] = 03014; code[001770] = &I01770;
  core[001771] = 02414; code[001771] = &I01771;
  core[001772] = 07000; code[001772] = &I01772;
  core[001773] = 01014; code[001773] = &I01773;
  core[001774] = 01037; code[001774] = &I01774;
  core[001775] = 07040; code[001775] = &I01775;
  core[001776] = 07440; code[001776] = &I01776;
  core[001777] = 07402; code[001777] = &I01777;
  core[002000] = 07200; code[002000] = &I02000;
  core[002001] = 01021; code[002001] = &I02001;
  core[002002] = 03014; code[002002] = &I02002;
  core[002003] = 00414; code[002003] = &I02003;
  core[002004] = 01014; code[002004] = &I02004;
  core[002005] = 01021; code[002005] = &I02005;
  core[002006] = 07040; code[002006] = &I02006;
  core[002007] = 07410; code[002007] = &I02007;
  core[002010] = 00000; code[002010] = &P02010;
  core[002011] = 07440; code[002011] = &I02011;
  core[002012] = 07402; code[002012] = &I02012;
  core[002013] = 07200; code[002013] = &I02013;
  core[002014] = 01020; code[002014] = &I02014;
  core[002015] = 03014; code[002015] = &P02015;
  core[002016] = 00414; code[002016] = &I02016;
  core[002017] = 01014; code[002017] = &I02017;
  core[002020] = 01020; code[002020] = &I02020;
  core[002021] = 07040; code[002021] = &I02021;
  core[002022] = 07440; code[002022] = &I02022;
  core[002023] = 07402; code[002023] = &I02023;
  core[002024] = 07200; code[002024] = &I02024;
  core[002025] = 01036; code[002025] = &I02025;
  core[002026] = 03015; code[002026] = &I02026;
  core[002027] = 00415; code[002027] = &I02027;
  core[002030] = 01015; code[002030] = &I02030;
  core[002031] = 01035; code[002031] = &I02031;
  core[002032] = 07040; code[002032] = &I02032;
  core[002033] = 07440; code[002033] = &I02033;
  core[002034] = 07402; code[002034] = &I02034;
  core[002035] = 07200; code[002035] = &I02035;
  core[002036] = 01035; code[002036] = &I02036;
  core[002037] = 03015; code[002037] = &I02037;
  core[002040] = 00415; code[002040] = &I02040;
  core[002041] = 01015; code[002041] = &I02041;
  core[002042] = 01036; code[002042] = &I02042;
  core[002043] = 07040; code[002043] = &I02043;
  core[002044] = 07440; code[002044] = &I02044;
  core[002045] = 07402; code[002045] = &I02045;
  core[002046] = 07200; code[002046] = &I02046;
  core[002047] = 01034; code[002047] = &I02047;
  core[002050] = 03015; code[002050] = &I02050;
  core[002051] = 03415; code[002051] = &I02051;
  core[002052] = 01015; code[002052] = &I02052;
  core[002053] = 01051; code[002053] = &I02053;
  core[002054] = 07040; code[002054] = &I02054;
  core[002055] = 07440; code[002055] = &I02055;
  core[002056] = 07402; code[002056] = &I02056;
  core[002057] = 07200; code[002057] = &I02057;
  core[002060] = 01033; code[002060] = &I02060;
  core[002061] = 03015; code[002061] = &I02061;
  core[002062] = 01415; code[002062] = &I02062;
  core[002063] = 07200; code[002063] = &I02063;
  core[002064] = 01015; code[002064] = &I02064;
  core[002065] = 01047; code[002065] = &I02065;
  core[002066] = 07040; code[002066] = &I02066;
  core[002067] = 07440; code[002067] = &I02067;
  core[002070] = 07402; code[002070] = &I02070;
  core[002071] = 07200; code[002071] = &I02071;
  core[002072] = 01032; code[002072] = &I02072;
  core[002073] = 03015; code[002073] = &I02073;
  core[002074] = 00415; code[002074] = &I02074;
  core[002075] = 01015; code[002075] = &I02075;
  core[002076] = 01046; code[002076] = &I02076;
  core[002077] = 07040; code[002077] = &I02077;
  core[002100] = 07440; code[002100] = &I02100;
  core[002101] = 07402; code[002101] = &I02101;
  core[002102] = 07200; code[002102] = &I02102;
  core[002103] = 01031; code[002103] = &I02103;
  core[002104] = 03015; code[002104] = &I02104;
  core[002105] = 00415; code[002105] = &I02105;
  core[002106] = 01015; code[002106] = &I02106;
  core[002107] = 01045; code[002107] = &I02107;
  core[002110] = 07040; code[002110] = &I02110;
  core[002111] = 07440; code[002111] = &I02111;
  core[002112] = 07402; code[002112] = &I02112;
  core[002113] = 07200; code[002113] = &I02113;
  core[002114] = 01027; code[002114] = &I02114;
  core[002115] = 03015; code[002115] = &I02115;
  core[002116] = 00415; code[002116] = &I02116;
  core[002117] = 01015; code[002117] = &I02117;
  core[002120] = 01044; code[002120] = &I02120;
  core[002121] = 07040; code[002121] = &I02121;
  core[002122] = 07440; code[002122] = &I02122;
  core[002123] = 07402; code[002123] = &I02123;
  core[002124] = 07200; code[002124] = &I02124;
  core[002125] = 01026; code[002125] = &I02125;
  core[002126] = 03015; code[002126] = &I02126;
  core[002127] = 00415; code[002127] = &I02127;
  core[002130] = 01015; code[002130] = &I02130;
  core[002131] = 01043; code[002131] = &I02131;
  core[002132] = 07040; code[002132] = &I02132;
  core[002133] = 07440; code[002133] = &I02133;
  core[002134] = 07402; code[002134] = &I02134;
  core[002135] = 07200; code[002135] = &I02135;
  core[002136] = 01025; code[002136] = &I02136;
  core[002137] = 03015; code[002137] = &I02137;
  core[002140] = 00415; code[002140] = &I02140;
  core[002141] = 01015; code[002141] = &I02141;
  core[002142] = 01042; code[002142] = &I02142;
  core[002143] = 07040; code[002143] = &I02143;
  core[002144] = 07440; code[002144] = &I02144;
  core[002145] = 07402; code[002145] = &I02145;
  core[002146] = 07200; code[002146] = &I02146;
  core[002147] = 01024; code[002147] = &I02147;
  core[002150] = 03015; code[002150] = &I02150;
  core[002151] = 00415; code[002151] = &I02151;
  core[002152] = 01015; code[002152] = &I02152;
  core[002153] = 01041; code[002153] = &I02153;
  core[002154] = 07040; code[002154] = &I02154;
  core[002155] = 07440; code[002155] = &I02155;
  core[002156] = 07402; code[002156] = &I02156;
  core[002157] = 07200; code[002157] = &I02157;
  core[002160] = 01023; code[002160] = &I02160;
  core[002161] = 03015; code[002161] = &I02161;
  core[002162] = 00415; code[002162] = &I02162;
  core[002163] = 01015; code[002163] = &I02163;
  core[002164] = 01040; code[002164] = &I02164;
  core[002165] = 07040; code[002165] = &I02165;
  core[002166] = 07440; code[002166] = &I02166;
  core[002167] = 07402; code[002167] = &I02167;
  core[002170] = 07000; code[002170] = &I02170;
  core[002171] = 07000; code[002171] = &I02171;
  core[002172] = 05376; code[002172] = &I02172;
  core[002173] = 00610; code[002173] = &L02173;
  core[002174] = 05775; code[002174] = &I02174;
  core[002175] = 03615; code[002175] = &P02175;
  core[002176] = 07000; code[002176] = &L02176;
  core[002177] = 07000; code[002177] = &I02177;
  core[002200] = 07200; code[002200] = &I02200;
  core[002201] = 01022; code[002201] = &I02201;
  core[002202] = 03015; code[002202] = &I02202;
  core[002203] = 02415; code[002203] = &I02203;
  core[002204] = 07000; code[002204] = &I02204;
  core[002205] = 01015; code[002205] = &I02205;
  core[002206] = 01037; code[002206] = &I02206;
  core[002207] = 07040; code[002207] = &I02207;
  core[002210] = 07440; code[002210] = &I02210;
  core[002211] = 07402; code[002211] = &I02211;
  core[002212] = 07200; code[002212] = &I02212;
  core[002213] = 01021; code[002213] = &I02213;
  core[002214] = 03015; code[002214] = &I02214;
  core[002215] = 00415; code[002215] = &I02215;
  core[002216] = 01015; code[002216] = &I02216;
  core[002217] = 01021; code[002217] = &I02217;
  core[002220] = 07040; code[002220] = &I02220;
  core[002221] = 07440; code[002221] = &I02221;
  core[002222] = 07402; code[002222] = &I02222;
  core[002223] = 07200; code[002223] = &I02223;
  core[002224] = 01020; code[002224] = &I02224;
  core[002225] = 03015; code[002225] = &I02225;
  core[002226] = 00415; code[002226] = &I02226;
  core[002227] = 01015; code[002227] = &I02227;
  core[002230] = 01020; code[002230] = &I02230;
  core[002231] = 07040; code[002231] = &I02231;
  core[002232] = 07440; code[002232] = &I02232;
  core[002233] = 07402; code[002233] = &I02233;
  core[002234] = 07200; code[002234] = &I02234;
  core[002235] = 01036; code[002235] = &I02235;
  core[002236] = 03016; code[002236] = &I02236;
  core[002237] = 00416; code[002237] = &I02237;
  core[002240] = 01016; code[002240] = &I02240;
  core[002241] = 01035; code[002241] = &I02241;
  core[002242] = 07040; code[002242] = &I02242;
  core[002243] = 07440; code[002243] = &I02243;
  core[002244] = 07402; code[002244] = &I02244;
  core[002245] = 07200; code[002245] = &I02245;
  core[002246] = 01035; code[002246] = &I02246;
  core[002247] = 03016; code[002247] = &I02247;
  core[002250] = 00416; code[002250] = &I02250;
  core[002251] = 01016; code[002251] = &I02251;
  core[002252] = 01036; code[002252] = &I02252;
  core[002253] = 07040; code[002253] = &I02253;
  core[002254] = 07440; code[002254] = &I02254;
  core[002255] = 07402; code[002255] = &I02255;
  core[002256] = 07200; code[002256] = &I02256;
  core[002257] = 01034; code[002257] = &I02257;
  core[002260] = 03016; code[002260] = &I02260;
  core[002261] = 03416; code[002261] = &I02261;
  core[002262] = 01016; code[002262] = &I02262;
  core[002263] = 01051; code[002263] = &I02263;
  core[002264] = 07040; code[002264] = &I02264;
  core[002265] = 07440; code[002265] = &I02265;
  core[002266] = 07402; code[002266] = &I02266;
  core[002267] = 07200; code[002267] = &I02267;
  core[002270] = 01033; code[002270] = &I02270;
  core[002271] = 03016; code[002271] = &I02271;
  core[002272] = 01416; code[002272] = &I02272;
  core[002273] = 07200; code[002273] = &I02273;
  core[002274] = 01016; code[002274] = &I02274;
  core[002275] = 01047; code[002275] = &I02275;
  core[002276] = 07040; code[002276] = &I02276;
  core[002277] = 07440; code[002277] = &I02277;
  core[002300] = 07402; code[002300] = &I02300;
  core[002301] = 07200; code[002301] = &I02301;
  core[002302] = 01032; code[002302] = &I02302;
  core[002303] = 03016; code[002303] = &I02303;
  core[002304] = 00416; code[002304] = &I02304;
  core[002305] = 01016; code[002305] = &I02305;
  core[002306] = 01046; code[002306] = &I02306;
  core[002307] = 07040; code[002307] = &I02307;
  core[002310] = 07440; code[002310] = &I02310;
  core[002311] = 07402; code[002311] = &I02311;
  core[002312] = 07200; code[002312] = &I02312;
  core[002313] = 01031; code[002313] = &I02313;
  core[002314] = 03016; code[002314] = &I02314;
  core[002315] = 00416; code[002315] = &I02315;
  core[002316] = 01016; code[002316] = &I02316;
  core[002317] = 01045; code[002317] = &I02317;
  core[002320] = 07040; code[002320] = &I02320;
  core[002321] = 07440; code[002321] = &I02321;
  core[002322] = 07402; code[002322] = &I02322;
  core[002323] = 07200; code[002323] = &I02323;
  core[002324] = 01027; code[002324] = &I02324;
  core[002325] = 03016; code[002325] = &I02325;
  core[002326] = 00416; code[002326] = &I02326;
  core[002327] = 01016; code[002327] = &I02327;
  core[002330] = 01044; code[002330] = &I02330;
  core[002331] = 07040; code[002331] = &I02331;
  core[002332] = 07440; code[002332] = &I02332;
  core[002333] = 07402; code[002333] = &I02333;
  core[002334] = 07200; code[002334] = &I02334;
  core[002335] = 01026; code[002335] = &I02335;
  core[002336] = 03016; code[002336] = &I02336;
  core[002337] = 00416; code[002337] = &I02337;
  core[002340] = 01016; code[002340] = &I02340;
  core[002341] = 01043; code[002341] = &I02341;
  core[002342] = 07040; code[002342] = &I02342;
  core[002343] = 07440; code[002343] = &I02343;
  core[002344] = 07402; code[002344] = &I02344;
  core[002345] = 07200; code[002345] = &I02345;
  core[002346] = 01025; code[002346] = &I02346;
  core[002347] = 03016; code[002347] = &I02347;
  core[002350] = 00416; code[002350] = &I02350;
  core[002351] = 01016; code[002351] = &I02351;
  core[002352] = 01042; code[002352] = &I02352;
  core[002353] = 07040; code[002353] = &I02353;
  core[002354] = 07440; code[002354] = &I02354;
  core[002355] = 07402; code[002355] = &I02355;
  core[002356] = 07200; code[002356] = &I02356;
  core[002357] = 01024; code[002357] = &I02357;
  core[002360] = 03016; code[002360] = &I02360;
  core[002361] = 00416; code[002361] = &I02361;
  core[002362] = 01016; code[002362] = &I02362;
  core[002363] = 01041; code[002363] = &I02363;
  core[002364] = 07040; code[002364] = &I02364;
  core[002365] = 07440; code[002365] = &I02365;
  core[002366] = 07402; code[002366] = &I02366;
  core[002367] = 07200; code[002367] = &I02367;
  core[002370] = 01023; code[002370] = &I02370;
  core[002371] = 03016; code[002371] = &I02371;
  core[002372] = 00416; code[002372] = &I02372;
  core[002373] = 01016; code[002373] = &I02373;
  core[002374] = 01040; code[002374] = &I02374;
  core[002375] = 07040; code[002375] = &I02375;
  core[002376] = 07440; code[002376] = &I02376;
  core[002377] = 07402; code[002377] = &I02377;
  core[002400] = 07200; code[002400] = &I02400;
  core[002401] = 01022; code[002401] = &I02401;
  core[002402] = 03016; code[002402] = &I02402;
  core[002403] = 02416; code[002403] = &I02403;
  core[002404] = 07000; code[002404] = &I02404;
  core[002405] = 01016; code[002405] = &I02405;
  core[002406] = 01037; code[002406] = &I02406;
  core[002407] = 07040; code[002407] = &I02407;
  core[002410] = 07440; code[002410] = &I02410;
  core[002411] = 07402; code[002411] = &I02411;
  core[002412] = 07200; code[002412] = &I02412;
  core[002413] = 01021; code[002413] = &I02413;
  core[002414] = 03016; code[002414] = &I02414;
  core[002415] = 00416; code[002415] = &I02415;
  core[002416] = 01016; code[002416] = &I02416;
  core[002417] = 01021; code[002417] = &I02417;
  core[002420] = 07040; code[002420] = &I02420;
  core[002421] = 07440; code[002421] = &I02421;
  core[002422] = 07402; code[002422] = &I02422;
  core[002423] = 07200; code[002423] = &I02423;
  core[002424] = 01020; code[002424] = &I02424;
  core[002425] = 03016; code[002425] = &I02425;
  core[002426] = 00416; code[002426] = &I02426;
  core[002427] = 01016; code[002427] = &I02427;
  core[002430] = 01020; code[002430] = &I02430;
  core[002431] = 07040; code[002431] = &I02431;
  core[002432] = 07440; code[002432] = &I02432;
  core[002433] = 07402; code[002433] = &I02433;
  core[002434] = 07200; code[002434] = &I02434;
  core[002435] = 01036; code[002435] = &I02435;
  core[002436] = 03017; code[002436] = &I02436;
  core[002437] = 00417; code[002437] = &I02437;
  core[002440] = 01017; code[002440] = &I02440;
  core[002441] = 01035; code[002441] = &I02441;
  core[002442] = 07040; code[002442] = &I02442;
  core[002443] = 07440; code[002443] = &I02443;
  core[002444] = 07402; code[002444] = &I02444;
  core[002445] = 07200; code[002445] = &I02445;
  core[002446] = 01035; code[002446] = &I02446;
  core[002447] = 03017; code[002447] = &I02447;
  core[002450] = 00417; code[002450] = &I02450;
  core[002451] = 01017; code[002451] = &I02451;
  core[002452] = 01036; code[002452] = &I02452;
  core[002453] = 07040; code[002453] = &I02453;
  core[002454] = 07440; code[002454] = &I02454;
  core[002455] = 07402; code[002455] = &I02455;
  core[002456] = 07200; code[002456] = &I02456;
  core[002457] = 01034; code[002457] = &I02457;
  core[002460] = 03017; code[002460] = &I02460;
  core[002461] = 03417; code[002461] = &I02461;
  core[002462] = 01017; code[002462] = &I02462;
  core[002463] = 01051; code[002463] = &I02463;
  core[002464] = 07040; code[002464] = &I02464;
  core[002465] = 07440; code[002465] = &I02465;
  core[002466] = 07402; code[002466] = &I02466;
  core[002467] = 07200; code[002467] = &I02467;
  core[002470] = 01033; code[002470] = &I02470;
  core[002471] = 03017; code[002471] = &I02471;
  core[002472] = 01417; code[002472] = &I02472;
  core[002473] = 07200; code[002473] = &I02473;
  core[002474] = 01017; code[002474] = &I02474;
  core[002475] = 01047; code[002475] = &I02475;
  core[002476] = 07040; code[002476] = &I02476;
  core[002477] = 07440; code[002477] = &I02477;
  core[002500] = 07402; code[002500] = &I02500;
  core[002501] = 07200; code[002501] = &I02501;
  core[002502] = 01032; code[002502] = &I02502;
  core[002503] = 03017; code[002503] = &I02503;
  core[002504] = 00417; code[002504] = &I02504;
  core[002505] = 01017; code[002505] = &I02505;
  core[002506] = 01046; code[002506] = &I02506;
  core[002507] = 07040; code[002507] = &I02507;
  core[002510] = 07440; code[002510] = &I02510;
  core[002511] = 07402; code[002511] = &I02511;
  core[002512] = 07200; code[002512] = &I02512;
  core[002513] = 01031; code[002513] = &I02513;
  core[002514] = 03017; code[002514] = &I02514;
  core[002515] = 00417; code[002515] = &I02515;
  core[002516] = 01017; code[002516] = &I02516;
  core[002517] = 01045; code[002517] = &I02517;
  core[002520] = 07040; code[002520] = &I02520;
  core[002521] = 07440; code[002521] = &I02521;
  core[002522] = 07402; code[002522] = &I02522;
  core[002523] = 07200; code[002523] = &I02523;
  core[002524] = 01027; code[002524] = &I02524;
  core[002525] = 03017; code[002525] = &I02525;
  core[002526] = 00417; code[002526] = &I02526;
  core[002527] = 01017; code[002527] = &I02527;
  core[002530] = 01044; code[002530] = &I02530;
  core[002531] = 07040; code[002531] = &I02531;
  core[002532] = 07440; code[002532] = &I02532;
  core[002533] = 07402; code[002533] = &I02533;
  core[002534] = 07200; code[002534] = &I02534;
  core[002535] = 01026; code[002535] = &I02535;
  core[002536] = 03017; code[002536] = &I02536;
  core[002537] = 00417; code[002537] = &I02537;
  core[002540] = 01017; code[002540] = &I02540;
  core[002541] = 01043; code[002541] = &I02541;
  core[002542] = 07040; code[002542] = &I02542;
  core[002543] = 07440; code[002543] = &I02543;
  core[002544] = 07402; code[002544] = &I02544;
  core[002545] = 07200; code[002545] = &I02545;
  core[002546] = 01025; code[002546] = &I02546;
  core[002547] = 03017; code[002547] = &I02547;
  core[002550] = 00417; code[002550] = &I02550;
  core[002551] = 01017; code[002551] = &I02551;
  core[002552] = 01042; code[002552] = &I02552;
  core[002553] = 07040; code[002553] = &I02553;
  core[002554] = 07440; code[002554] = &I02554;
  core[002555] = 07402; code[002555] = &I02555;
  core[002556] = 07200; code[002556] = &I02556;
  core[002557] = 01024; code[002557] = &I02557;
  core[002560] = 03017; code[002560] = &I02560;
  core[002561] = 00417; code[002561] = &I02561;
  core[002562] = 01017; code[002562] = &I02562;
  core[002563] = 01041; code[002563] = &I02563;
  core[002564] = 07040; code[002564] = &I02564;
  core[002565] = 07440; code[002565] = &I02565;
  core[002566] = 07402; code[002566] = &I02566;
  core[002567] = 07200; code[002567] = &I02567;
  core[002570] = 01023; code[002570] = &I02570;
  core[002571] = 03017; code[002571] = &I02571;
  core[002572] = 00417; code[002572] = &I02572;
  core[002573] = 01017; code[002573] = &I02573;
  core[002574] = 01040; code[002574] = &I02574;
  core[002575] = 07040; code[002575] = &I02575;
  core[002576] = 07440; code[002576] = &I02576;
  core[002577] = 07402; code[002577] = &I02577;
  core[002600] = 07200; code[002600] = &I02600;
  core[002601] = 01022; code[002601] = &I02601;
  core[002602] = 03017; code[002602] = &I02602;
  core[002603] = 02417; code[002603] = &I02603;
  core[002604] = 07000; code[002604] = &I02604;
  core[002605] = 01017; code[002605] = &I02605;
  core[002606] = 01037; code[002606] = &I02606;
  core[002607] = 07040; code[002607] = &I02607;
  core[002610] = 07440; code[002610] = &I02610;
  core[002611] = 07402; code[002611] = &I02611;
  core[002612] = 07200; code[002612] = &I02612;
  core[002613] = 01021; code[002613] = &I02613;
  core[002614] = 03017; code[002614] = &I02614;
  core[002615] = 00417; code[002615] = &I02615;
  core[002616] = 01017; code[002616] = &I02616;
  core[002617] = 01021; code[002617] = &I02617;
  core[002620] = 07040; code[002620] = &I02620;
  core[002621] = 07440; code[002621] = &I02621;
  core[002622] = 07402; code[002622] = &I02622;
  core[002623] = 07200; code[002623] = &I02623;
  core[002624] = 01020; code[002624] = &I02624;
  core[002625] = 03017; code[002625] = &I02625;
  core[002626] = 00417; code[002626] = &I02626;
  core[002627] = 01017; code[002627] = &I02627;
  core[002630] = 01020; code[002630] = &I02630;
  core[002631] = 07040; code[002631] = &I02631;
  core[002632] = 07440; code[002632] = &I02632;
  core[002633] = 07402; code[002633] = &I02633;
  core[002634] = 05236; code[002634] = &I02634;
  core[002635] = 07402; code[002635] = &I02635;
  core[002636] = 07410; code[002636] = &L02636;
  core[002637] = 02644; code[002637] = &D02637;
  core[002640] = 01237; code[002640] = &I02640;
  core[002641] = 03010; code[002641] = &I02641;
  core[002642] = 05410; code[002642] = &I02642;
  core[002643] = 07402; code[002643] = &I02643;
  core[002644] = 07402; code[002644] = &P02644;
  core[002645] = 04247; code[002645] = &I02645;
  core[002646] = 07402; code[002646] = &P02646;
  core[002647] = 07402; code[002647] = &D02647;
  core[002650] = 01247; code[002650] = &I02650;
  core[002651] = 07410; code[002651] = &I02651;
  core[002652] = 02646; code[002652] = &D02652;
  core[002653] = 07041; code[002653] = &I02653;
  core[002654] = 01252; code[002654] = &I02654;
  core[002655] = 07440; code[002655] = &I02655;
  core[002656] = 07402; code[002656] = &I02656;
  core[002657] = 07410; code[002657] = &I02657;
  core[002660] = 02664; code[002660] = &D02660;
  core[002661] = 01260; code[002661] = &I02661;
  core[002662] = 03010; code[002662] = &I02662;
  core[002663] = 04410; code[002663] = &I02663;
  core[002664] = 07402; code[002664] = &P02664;
  core[002665] = 07402; code[002665] = &D02665;
  core[002666] = 01265; code[002666] = &I02666;
  core[002667] = 07410; code[002667] = &I02667;
  core[002670] = 02664; code[002670] = &D02670;
  core[002671] = 07041; code[002671] = &I02671;
  core[002672] = 01270; code[002672] = &I02672;
  core[002673] = 07440; code[002673] = &I02673;
  core[002674] = 07402; code[002674] = &I02674;
  core[002675] = 05676; code[002675] = &I02675;
  core[002676] = 04200; code[002676] = &P02676;
  core[002677] = 04700; code[002677] = &L02677;
  core[002700] = 04011; code[002700] = &P02700;
  core[002701] = 06040; code[002701] = &I02701;
  core[002702] = 06041; code[002702] = &I02702;
  core[002703] = 07402; code[002703] = &I02703;
  core[002704] = 07200; code[002704] = &I02704;
  core[002705] = 01313; code[002705] = &I02705;
  core[002706] = 03002; code[002706] = &I02706;
  core[002707] = 06001; code[002707] = &I02707;
  core[002710] = 07000; code[002710] = &I02710;
  core[002711] = 07402; code[002711] = &P02711;
  core[002712] = 02711; code[002712] = &D02712;
  core[002713] = 02714; code[002713] = &D02713;
  core[002714] = 07440; code[002714] = &P02714;
  core[002715] = 07402; code[002715] = &I02715;
  core[002716] = 01000; code[002716] = &I02716;
  core[002717] = 07041; code[002717] = &I02717;
  core[002720] = 01312; code[002720] = &I02720;
  core[002721] = 07640; code[002721] = &I02721;
  core[002722] = 07402; code[002722] = &I02722;
  core[002723] = 06040; code[002723] = &I02723;
  core[002724] = 06041; code[002724] = &I02724;
  core[002725] = 07402; code[002725] = &I02725;
  core[002726] = 07200; code[002726] = &I02726;
  core[002727] = 01335; code[002727] = &I02727;
  core[002730] = 03002; code[002730] = &I02730;
  core[002731] = 06001; code[002731] = &I02731;
  core[002732] = 01020; code[002732] = &I02732;
  core[002733] = 07402; code[002733] = &P02733;
  core[002734] = 02733; code[002734] = &D02734;
  core[002735] = 02736; code[002735] = &D02735;
  core[002736] = 07040; code[002736] = &P02736;
  core[002737] = 07440; code[002737] = &I02737;
  core[002740] = 07402; code[002740] = &I02740;
  core[002741] = 01000; code[002741] = &I02741;
  core[002742] = 07041; code[002742] = &I02742;
  core[002743] = 01334; code[002743] = &I02743;
  core[002744] = 07640; code[002744] = &I02744;
  core[002745] = 07402; code[002745] = &I02745;
  core[002746] = 06040; code[002746] = &I02746;
  core[002747] = 06041; code[002747] = &I02747;
  core[002750] = 07402; code[002750] = &I02750;
  core[002751] = 07200; code[002751] = &I02751;
  core[002752] = 01361; code[002752] = &I02752;
  core[002753] = 03002; code[002753] = &I02753;
  core[002754] = 01020; code[002754] = &I02754;
  core[002755] = 06001; code[002755] = &I02755;
  core[002756] = 00020; code[002756] = &I02756;
  core[002757] = 07402; code[002757] = &P02757;
  core[002760] = 02757; code[002760] = &D02760;
  core[002761] = 02762; code[002761] = &D02761;
  core[002762] = 07040; code[002762] = &P02762;
  core[002763] = 07440; code[002763] = &I02763;
  core[002764] = 07402; code[002764] = &I02764;
  core[002765] = 01000; code[002765] = &I02765;
  core[002766] = 07041; code[002766] = &I02766;
  core[002767] = 01360; code[002767] = &I02767;
  core[002770] = 07640; code[002770] = &I02770;
  core[002771] = 07402; code[002771] = &I02771;
  core[002772] = 05773; code[002772] = &I02772;
  core[002773] = 03000; code[002773] = &P02773;
  core[003000] = 06040; code[003000] = &L03000;
  core[003001] = 06041; code[003001] = &I03001;
  core[003002] = 07402; code[003002] = &I03002;
  core[003003] = 07200; code[003003] = &I03003;
  core[003004] = 01213; code[003004] = &I03004;
  core[003005] = 03002; code[003005] = &I03005;
  core[003006] = 01020; code[003006] = &I03006;
  core[003007] = 06001; code[003007] = &I03007;
  core[003010] = 03003; code[003010] = &I03010;
  core[003011] = 07402; code[003011] = &D03011;
  core[003012] = 03011; code[003012] = &D03012;
  core[003013] = 03014; code[003013] = &D03013;
  core[003014] = 07440; code[003014] = &D03014;
  core[003015] = 07402; code[003015] = &I03015;
  core[003016] = 01003; code[003016] = &I03016;
  core[003017] = 07040; code[003017] = &I03017;
  core[003020] = 07440; code[003020] = &I03020;
  core[003021] = 07402; code[003021] = &I03021;
  core[003022] = 03003; code[003022] = &I03022;
  core[003023] = 01000; code[003023] = &I03023;
  core[003024] = 07041; code[003024] = &I03024;
  core[003025] = 01212; code[003025] = &I03025;
  core[003026] = 07640; code[003026] = &I03026;
  core[003027] = 07402; code[003027] = &I03027;
  core[003030] = 06040; code[003030] = &I03030;
  core[003031] = 06041; code[003031] = &I03031;
  core[003032] = 07402; code[003032] = &I03032;
  core[003033] = 07200; code[003033] = &I03033;
  core[003034] = 01244; code[003034] = &I03034;
  core[003035] = 03002; code[003035] = &I03035;
  core[003036] = 01035; code[003036] = &I03036;
  core[003037] = 03003; code[003037] = &I03037;
  core[003040] = 06001; code[003040] = &I03040;
  core[003041] = 02003; code[003041] = &I03041;
  core[003042] = 07402; code[003042] = &I03042;
  core[003043] = 03042; code[003043] = &D03043;
  core[003044] = 03045; code[003044] = &D03044;
  core[003045] = 07440; code[003045] = &I03045;
  core[003046] = 07402; code[003046] = &I03046;
  core[003047] = 01003; code[003047] = &I03047;
  core[003050] = 07040; code[003050] = &I03050;
  core[003051] = 07440; code[003051] = &I03051;
  core[003052] = 07402; code[003052] = &I03052;
  core[003053] = 03003; code[003053] = &I03053;
  core[003054] = 01000; code[003054] = &I03054;
  core[003055] = 07041; code[003055] = &I03055;
  core[003056] = 01243; code[003056] = &I03056;
  core[003057] = 07640; code[003057] = &I03057;
  core[003060] = 07402; code[003060] = &I03060;
  core[003061] = 06040; code[003061] = &I03061;
  core[003062] = 06041; code[003062] = &I03062;
  core[003063] = 07402; code[003063] = &I03063;
  core[003064] = 07200; code[003064] = &I03064;
  core[003065] = 01276; code[003065] = &I03065;
  core[003066] = 03002; code[003066] = &I03066;
  core[003067] = 01020; code[003067] = &I03067;
  core[003070] = 03003; code[003070] = &I03070;
  core[003071] = 06001; code[003071] = &I03071;
  core[003072] = 02003; code[003072] = &I03072;
  core[003073] = 07402; code[003073] = &I03073;
  core[003074] = 07402; code[003074] = &I03074;
  core[003075] = 03074; code[003075] = &D03075;
  core[003076] = 03077; code[003076] = &D03076;
  core[003077] = 07440; code[003077] = &I03077;
  core[003100] = 07402; code[003100] = &I03100;
  core[003101] = 01003; code[003101] = &I03101;
  core[003102] = 07440; code[003102] = &I03102;
  core[003103] = 07402; code[003103] = &I03103;
  core[003104] = 03003; code[003104] = &I03104;
  core[003105] = 01000; code[003105] = &I03105;
  core[003106] = 07041; code[003106] = &I03106;
  core[003107] = 01275; code[003107] = &I03107;
  core[003110] = 07640; code[003110] = &I03110;
  core[003111] = 07402; code[003111] = &I03111;
  core[003112] = 06040; code[003112] = &I03112;
  core[003113] = 06041; code[003113] = &I03113;
  core[003114] = 07402; code[003114] = &I03114;
  core[003115] = 07200; code[003115] = &I03115;
  core[003116] = 01324; code[003116] = &I03116;
  core[003117] = 03002; code[003117] = &I03117;
  core[003120] = 06001; code[003120] = &I03120;
  core[003121] = 05321; code[003121] = &L03121;
  core[003122] = 07402; code[003122] = &I03122;
  core[003123] = 03121; code[003123] = &D03123;
  core[003124] = 03125; code[003124] = &D03124;
  core[003125] = 07440; code[003125] = &I03125;
  core[003126] = 07402; code[003126] = &I03126;
  core[003127] = 01000; code[003127] = &I03127;
  core[003130] = 07041; code[003130] = &I03130;
  core[003131] = 01323; code[003131] = &I03131;
  core[003132] = 07640; code[003132] = &I03132;
  core[003133] = 07402; code[003133] = &I03133;
  core[003134] = 06040; code[003134] = &I03134;
  core[003135] = 06041; code[003135] = &I03135;
  core[003136] = 07402; code[003136] = &I03136;
  core[003137] = 07200; code[003137] = &I03137;
  core[003140] = 01346; code[003140] = &I03140;
  core[003141] = 03002; code[003141] = &I03141;
  core[003142] = 06001; code[003142] = &I03142;
  core[003143] = 04003; code[003143] = &I03143;
  core[003144] = 07402; code[003144] = &I03144;
  core[003145] = 03144; code[003145] = &D03145;
  core[003146] = 03147; code[003146] = &D03146;
  core[003147] = 07440; code[003147] = &I03147;
  core[003150] = 07402; code[003150] = &I03150;
  core[003151] = 01003; code[003151] = &I03151;
  core[003152] = 07041; code[003152] = &I03152;
  core[003153] = 01345; code[003153] = &I03153;
  core[003154] = 07440; code[003154] = &I03154;
  core[003155] = 07402; code[003155] = &I03155;
  core[003156] = 01000; code[003156] = &I03156;
  core[003157] = 07041; code[003157] = &I03157;
  core[003160] = 01065; code[003160] = &I03160;
  core[003161] = 07640; code[003161] = &I03161;
  core[003162] = 07402; code[003162] = &I03162;
  core[003163] = 05764; code[003163] = &I03163;
  core[003164] = 03200; code[003164] = &P03164;
  core[003200] = 06040; code[003200] = &L03200;
  core[003201] = 06041; code[003201] = &I03201;
  core[003202] = 07402; code[003202] = &I03202;
  core[003203] = 07200; code[003203] = &I03203;
  core[003204] = 01213; code[003204] = &I03204;
  core[003205] = 03002; code[003205] = &I03205;
  core[003206] = 01020; code[003206] = &I03206;
  core[003207] = 06001; code[003207] = &I03207;
  core[003210] = 07200; code[003210] = &I03210;
  core[003211] = 07402; code[003211] = &D03211;
  core[003212] = 03211; code[003212] = &D03212;
  core[003213] = 03214; code[003213] = &D03213;
  core[003214] = 07440; code[003214] = &D03214;
  core[003215] = 07402; code[003215] = &I03215;
  core[003216] = 01000; code[003216] = &I03216;
  core[003217] = 07041; code[003217] = &I03217;
  core[003220] = 01212; code[003220] = &I03220;
  core[003221] = 07640; code[003221] = &I03221;
  core[003222] = 07402; code[003222] = &I03222;
  core[003223] = 06040; code[003223] = &I03223;
  core[003224] = 06041; code[003224] = &I03224;
  core[003225] = 07402; code[003225] = &I03225;
  core[003226] = 07200; code[003226] = &I03226;
  core[003227] = 01236; code[003227] = &I03227;
  core[003230] = 03002; code[003230] = &I03230;
  core[003231] = 06001; code[003231] = &I03231;
  core[003232] = 06041; code[003232] = &I03232;
  core[003233] = 07402; code[003233] = &I03233;
  core[003234] = 07402; code[003234] = &D03234;
  core[003235] = 03234; code[003235] = &D03235;
  core[003236] = 03237; code[003236] = &D03236;
  core[003237] = 07440; code[003237] = &D03237;
  core[003240] = 07402; code[003240] = &I03240;
  core[003241] = 01000; code[003241] = &I03241;
  core[003242] = 07041; code[003242] = &I03242;
  core[003243] = 01235; code[003243] = &I03243;
  core[003244] = 07640; code[003244] = &I03244;
  core[003245] = 07402; code[003245] = &I03245;
  core[003246] = 06040; code[003246] = &I03246;
  core[003247] = 06041; code[003247] = &I03247;
  core[003250] = 07402; code[003250] = &I03250;
  core[003251] = 07200; code[003251] = &I03251;
  core[003252] = 01311; code[003252] = &I03252;
  core[003253] = 03002; code[003253] = &I03253;
  core[003254] = 06001; code[003254] = &I03254;
  core[003255] = 06002; code[003255] = &I03255;
  core[003256] = 06001; code[003256] = &I03256;
  core[003257] = 06002; code[003257] = &I03257;
  core[003260] = 06001; code[003260] = &I03260;
  core[003261] = 06002; code[003261] = &I03261;
  core[003262] = 06001; code[003262] = &I03262;
  core[003263] = 06002; code[003263] = &I03263;
  core[003264] = 06001; code[003264] = &I03264;
  core[003265] = 06002; code[003265] = &I03265;
  core[003266] = 06001; code[003266] = &I03266;
  core[003267] = 06002; code[003267] = &I03267;
  core[003270] = 06001; code[003270] = &I03270;
  core[003271] = 06002; code[003271] = &I03271;
  core[003272] = 06001; code[003272] = &I03272;
  core[003273] = 06002; code[003273] = &I03273;
  core[003274] = 06001; code[003274] = &I03274;
  core[003275] = 06002; code[003275] = &I03275;
  core[003276] = 06001; code[003276] = &I03276;
  core[003277] = 06002; code[003277] = &I03277;
  core[003300] = 06001; code[003300] = &I03300;
  core[003301] = 06002; code[003301] = &I03301;
  core[003302] = 06001; code[003302] = &I03302;
  core[003303] = 06002; code[003303] = &I03303;
  core[003304] = 06001; code[003304] = &I03304;
  core[003305] = 06002; code[003305] = &I03305;
  core[003306] = 06041; code[003306] = &I03306;
  core[003307] = 07402; code[003307] = &I03307;
  core[003310] = 07410; code[003310] = &I03310;
  core[003311] = 03313; code[003311] = &D03311;
  core[003312] = 07410; code[003312] = &I03312;
  core[003313] = 07402; code[003313] = &D03313;
  core[003314] = 06042; code[003314] = &I03314;
  core[003315] = 07200; code[003315] = &I03315;
  core[003316] = 01326; code[003316] = &I03316;
  core[003317] = 03002; code[003317] = &I03317;
  core[003320] = 06001; code[003320] = &I03320;
  core[003321] = 07000; code[003321] = &I03321;
  core[003322] = 07000; code[003322] = &I03322;
  core[003323] = 07000; code[003323] = &I03323;
  core[003324] = 07000; code[003324] = &I03324;
  core[003325] = 07410; code[003325] = &I03325;
  core[003326] = 03330; code[003326] = &D03326;
  core[003327] = 07410; code[003327] = &I03327;
  core[003330] = 07402; code[003330] = &D03330;
  core[003331] = 06002; code[003331] = &I03331;
  core[003332] = 06040; code[003332] = &I03332;
  core[003333] = 06041; code[003333] = &I03333;
  core[003334] = 07402; code[003334] = &I03334;
  core[003335] = 07200; code[003335] = &I03335;
  core[003336] = 01345; code[003336] = &I03336;
  core[003337] = 03002; code[003337] = &I03337;
  core[003340] = 06001; code[003340] = &I03340;
  core[003341] = 07410; code[003341] = &I03341;
  core[003342] = 07402; code[003342] = &I03342;
  core[003343] = 07402; code[003343] = &D03343;
  core[003344] = 03343; code[003344] = &D03344;
  core[003345] = 03346; code[003345] = &D03345;
  core[003346] = 07440; code[003346] = &D03346;
  core[003347] = 07402; code[003347] = &I03347;
  core[003350] = 01000; code[003350] = &I03350;
  core[003351] = 07041; code[003351] = &I03351;
  core[003352] = 01344; code[003352] = &I03352;
  core[003353] = 07640; code[003353] = &I03353;
  core[003354] = 07402; code[003354] = &I03354;
  core[003355] = 06040; code[003355] = &I03355;
  core[003356] = 06041; code[003356] = &I03356;
  core[003357] = 07402; code[003357] = &I03357;
  core[003360] = 07200; code[003360] = &I03360;
  core[003361] = 01370; code[003361] = &I03361;
  core[003362] = 03002; code[003362] = &I03362;
  core[003363] = 06001; code[003363] = &I03363;
  core[003364] = 05765; code[003364] = &I03364;
  core[003365] = 03366; code[003365] = &P03365;
  core[003366] = 07402; code[003366] = &L03366;
  core[003367] = 03366; code[003367] = &D03367;
  core[003370] = 03371; code[003370] = &D03370;
  core[003371] = 07440; code[003371] = &D03371;
  core[003372] = 07402; code[003372] = &I03372;
  core[003373] = 01000; code[003373] = &I03373;
  core[003374] = 07041; code[003374] = &I03374;
  core[003375] = 01367; code[003375] = &I03375;
  core[003376] = 07640; code[003376] = &I03376;
  core[003377] = 07402; code[003377] = &I03377;
  core[003400] = 06007; code[003400] = &P03400;
  core[003401] = 01212; code[003401] = &I03401;
  core[003402] = 03002; code[003402] = &I03402;
  core[003403] = 06001; code[003403] = &I03403;
  core[003404] = 07000; code[003404] = &I03404;
  core[003405] = 06007; code[003405] = &I03405;
  core[003406] = 06040; code[003406] = &I03406;
  core[003407] = 06000; code[003407] = &I03407;
  core[003410] = 05213; code[003410] = &I03410;
  core[003411] = 07402; code[003411] = &I03411;
  core[003412] = 03411; code[003412] = &D03412;
  core[003413] = 06007; code[003413] = &L03413;
  core[003414] = 05615; code[003414] = &I03414;
  core[003415] = 03600; code[003415] = &P03415;
  core[003600] = 07200; code[003600] = &L03600;
  core[003601] = 05602; code[003601] = &I03601;
  core[003602] = 04000; code[003602] = &P03602;
  core[003603] = 04010; code[003603] = &P03603;
  core[003604] = 01603; code[003604] = &L03604;
  core[003605] = 07440; code[003605] = &I03605;
  core[003606] = 07402; code[003606] = &I03606;
  core[003607] = 07200; code[003607] = &D03607;
  core[003610] = 03603; code[003610] = &D03610;
  core[003611] = 07200; code[003611] = &I03611;
  core[003612] = 05613; code[003612] = &I03612;
  core[003613] = 02173; code[003613] = &P03613;
  core[003614] = 02010; code[003614] = &P03614;
  core[003615] = 01614; code[003615] = &L03615;
  core[003616] = 07440; code[003616] = &I03616;
  core[003617] = 07402; code[003617] = &I03617;
  core[003620] = 05621; code[003620] = &I03620;
  core[003621] = 03622; code[003621] = &P03621;
  core[003622] = 07200; code[003622] = &P03622;
  core[003623] = 05624; code[003623] = &I03623;
  core[003624] = 01173; code[003624] = &P03624;
  core[003625] = 01010; code[003625] = &P03625;
  core[003626] = 01625; code[003626] = &L03626;
  core[003627] = 07440; code[003627] = &I03627;
  core[003630] = 07402; code[003630] = &I03630;
  core[003631] = 07200; code[003631] = &I03631;
  core[003632] = 03625; code[003632] = &I03632;
  core[003633] = 07200; code[003633] = &I03633;
  core[003634] = 05635; code[003634] = &I03634;
  core[003635] = 00574; code[003635] = &P03635;
  core[003636] = 00410; code[003636] = &P03636;
  core[003637] = 01636; code[003637] = &L03637;
  core[003640] = 07440; code[003640] = &I03640;
  core[003641] = 07402; code[003641] = &I03641;
  core[003642] = 07200; code[003642] = &I03642;
  core[003643] = 03636; code[003643] = &I03643;
  core[003644] = 07200; code[003644] = &I03644;
  core[003645] = 05646; code[003645] = &I03645;
  core[003646] = 00372; code[003646] = &P03646;
  core[003647] = 00210; code[003647] = &P03647;
  core[003650] = 01647; code[003650] = &L03650;
  core[003651] = 07440; code[003651] = &I03651;
  core[003652] = 07402; code[003652] = &I03652;
  core[003653] = 07200; code[003653] = &I03653;
  core[003654] = 03647; code[003654] = &I03654;
  core[003655] = 07200; code[003655] = &I03655;
  core[003656] = 05657; code[003656] = &I03656;
  core[003657] = 00130; code[003657] = &P03657;
  core[003660] = 00110; code[003660] = &P03660;
  core[003661] = 01660; code[003661] = &L03661;
  core[003662] = 07440; code[003662] = &I03662;
  core[003663] = 07402; code[003663] = &I03663;
  core[003664] = 07200; code[003664] = &I03664;
  core[003665] = 03110; code[003665] = &I03665;
  core[003666] = 07200; code[003666] = &I03666;
  core[003667] = 05670; code[003667] = &I03667;
  core[003670] = 00124; code[003670] = &P03670;
  core[003671] = 00050; code[003671] = &P03671;
  core[003672] = 01671; code[003672] = &L03672;
  core[003673] = 07440; code[003673] = &I03673;
  core[003674] = 07402; code[003674] = &I03674;
  core[003675] = 07200; code[003675] = &I03675;
  core[003676] = 03050; code[003676] = &I03676;
  core[003677] = 07200; code[003677] = &I03677;
  core[003700] = 05701; code[003700] = &I03700;
  core[003701] = 00120; code[003701] = &P03701;
  core[003702] = 00030; code[003702] = &P03702;
  core[003703] = 01702; code[003703] = &L03703;
  core[003704] = 07440; code[003704] = &I03704;
  core[003705] = 07402; code[003705] = &I03705;
  core[003706] = 07200; code[003706] = &I03706;
  core[003707] = 03030; code[003707] = &I03707;
  core[003710] = 07200; code[003710] = &I03710;
  core[003711] = 03000; code[003711] = &I03711;
  core[003712] = 05713; code[003712] = &I03712;
  core[003713] = 00074; code[003713] = &P03713;
  core[003714] = 01436; code[003714] = &L03714;
  core[003715] = 07440; code[003715] = &I03715;
  core[003716] = 07402; code[003716] = &I03716;
  core[003717] = 07200; code[003717] = &I03717;
  core[003720] = 03000; code[003720] = &I03720;
  core[003721] = 07200; code[003721] = &I03721;
  core[003722] = 05723; code[003722] = &I03722;
  core[003723] = 00070; code[003723] = &P03723;
  core[003724] = 01446; code[003724] = &L03724;
  core[003725] = 07440; code[003725] = &I03725;
  core[003726] = 07402; code[003726] = &I03726;
  core[003727] = 07200; code[003727] = &I03727;
  core[003730] = 03007; code[003730] = &I03730;
  core[003731] = 01347; code[003731] = &I03731;
  core[003732] = 07001; code[003732] = &I03732;
  core[003733] = 03347; code[003733] = &I03733;
  core[003734] = 01347; code[003734] = &I03734;
  core[003735] = 01350; code[003735] = &I03735;
  core[003736] = 07640; code[003736] = &I03736;
  core[003737] = 05746; code[003737] = &I03737;
  core[003740] = 03347; code[003740] = &I03740;
  core[003741] = 01351; code[003741] = &I03741;
  core[003742] = 06046; code[003742] = &I03742;
  core[003743] = 06041; code[003743] = &L03743;
  core[003744] = 05343; code[003744] = &I03744;
  core[003745] = 05746; code[003745] = &I03745;
  core[003746] = 00200; code[003746] = &P03746;
  core[003747] = 00000; code[003747] = &D03747;
  core[003750] = 04762; code[003750] = &D03750;
  core[003751] = 00207; code[003751] = &D03751;
  core[004000] = 00610; code[004000] = &L04000;
  core[004001] = 05602; code[004001] = &I04001;
  core[004002] = 03604; code[004002] = &P04002;
  core[004010] = 00000; code[004010] = &P04010;
  core[004011] = 00000; code[004011] = &S04011;
  core[004012] = 01220; code[004012] = &I04012;
  core[004013] = 03001; code[004013] = &I04013;
  core[004014] = 03002; code[004014] = &I04014;
  core[004015] = 03003; code[004015] = &I04015;
  core[004016] = 02211; code[004016] = &I04016;
  core[004017] = 05611; code[004017] = &I04017;
  core[004020] = 05402; code[004020] = &D04020;
  core[004200] = 07300; code[004200] = &L04200;
  core[004201] = 04602; code[004201] = &I04201;
  core[004202] = 04011; code[004202] = &P04202;
  core[004203] = 07360; code[004203] = &I04203;
  core[004204] = 06007; code[004204] = &I04204;
  core[004205] = 07410; code[004205] = &I04205;
  core[004206] = 07402; code[004206] = &I04206;
  core[004207] = 07420; code[004207] = &I04207;
  core[004210] = 07440; code[004210] = &I04210;
  core[004211] = 07402; code[004211] = &I04211;
  core[004212] = 06040; code[004212] = &I04212;
  core[004213] = 07410; code[004213] = &I04213;
  core[004214] = 07402; code[004214] = &I04214;
  core[004215] = 06041; code[004215] = &I04215;
  core[004216] = 07402; code[004216] = &I04216;
  core[004217] = 06007; code[004217] = &I04217;
  core[004220] = 06041; code[004220] = &I04220;
  core[004221] = 07410; code[004221] = &I04221;
  core[004222] = 07402; code[004222] = &I04222;
  core[004223] = 06003; code[004223] = &I04223;
  core[004224] = 07410; code[004224] = &I04224;
  core[004225] = 07402; code[004225] = &I04225;
  core[004226] = 06007; code[004226] = &I04226;
  core[004227] = 06040; code[004227] = &I04227;
  core[004230] = 06003; code[004230] = &I04230;
  core[004231] = 07402; code[004231] = &I04231;
  core[004232] = 06007; code[004232] = &I04232;
  core[004233] = 06035; code[004233] = &I04233;
  core[004234] = 07410; code[004234] = &I04234;
  core[004235] = 07402; code[004235] = &I04235;
  core[004236] = 06040; code[004236] = &I04236;
  core[004237] = 06041; code[004237] = &I04237;
  core[004240] = 07402; code[004240] = &I04240;
  core[004241] = 06003; code[004241] = &I04241;
  core[004242] = 07410; code[004242] = &I04242;
  core[004243] = 07402; code[004243] = &I04243;
  core[004244] = 07201; code[004244] = &I04244;
  core[004245] = 06035; code[004245] = &I04245;
  core[004246] = 06040; code[004246] = &I04246;
  core[004247] = 06041; code[004247] = &I04247;
  core[004250] = 07402; code[004250] = &I04250;
  core[004251] = 06003; code[004251] = &I04251;
  core[004252] = 07402; code[004252] = &I04252;
  core[004253] = 06007; code[004253] = &I04253;
  core[004254] = 01267; code[004254] = &I04254;
  core[004255] = 03002; code[004255] = &I04255;
  core[004256] = 06001; code[004256] = &I04256;
  core[004257] = 07410; code[004257] = &I04257;
  core[004260] = 07402; code[004260] = &I04260;
  core[004261] = 06000; code[004261] = &I04261;
  core[004262] = 07402; code[004262] = &I04262;
  core[004263] = 06000; code[004263] = &I04263;
  core[004264] = 07410; code[004264] = &I04264;
  core[004265] = 07402; code[004265] = &I04265;
  core[004266] = 05271; code[004266] = &I04266;
  core[004267] = 04270; code[004267] = &D04267;
  core[004270] = 07402; code[004270] = &I04270;
  core[004271] = 06007; code[004271] = &L04271;
  core[004272] = 01304; code[004272] = &I04272;
  core[004273] = 03002; code[004273] = &I04273;
  core[004274] = 06001; code[004274] = &I04274;
  core[004275] = 06002; code[004275] = &I04275;
  core[004276] = 07410; code[004276] = &I04276;
  core[004277] = 07402; code[004277] = &I04277;
  core[004300] = 06000; code[004300] = &I04300;
  core[004301] = 07410; code[004301] = &I04301;
  core[004302] = 07402; code[004302] = &I04302;
  core[004303] = 05306; code[004303] = &I04303;
  core[004304] = 04305; code[004304] = &D04304;
  core[004305] = 07402; code[004305] = &I04305;
  core[004306] = 06007; code[004306] = &L04306;
  core[004307] = 07040; code[004307] = &I04307;
  core[004310] = 06004; code[004310] = &I04310;
  core[004311] = 07410; code[004311] = &I04311;
  core[004312] = 07402; code[004312] = &I04312;
  core[004313] = 00064; code[004313] = &I04313;
  core[004314] = 07440; code[004314] = &I04314;
  core[004315] = 07402; code[004315] = &I04315;
  core[004316] = 07360; code[004316] = &I04316;
  core[004317] = 06004; code[004317] = &I04317;
  core[004320] = 07420; code[004320] = &I04320;
  core[004321] = 07402; code[004321] = &I04321;
  core[004322] = 00064; code[004322] = &I04322;
  core[004323] = 07104; code[004323] = &I04323;
  core[004324] = 07430; code[004324] = &I04324;
  core[004325] = 07440; code[004325] = &I04325;
  core[004326] = 07402; code[004326] = &I04326;
  core[004327] = 06007; code[004327] = &I04327;
  core[004330] = 06040; code[004330] = &I04330;
  core[004331] = 06004; code[004331] = &I04331;
  core[004332] = 00064; code[004332] = &I04332;
  core[004333] = 07006; code[004333] = &I04333;
  core[004334] = 07004; code[004334] = &I04334;
  core[004335] = 07430; code[004335] = &I04335;
  core[004336] = 07440; code[004336] = &I04336;
  core[004337] = 07402; code[004337] = &I04337;
  core[004340] = 06007; code[004340] = &I04340;
  core[004341] = 01356; code[004341] = &I04341;
  core[004342] = 03002; code[004342] = &I04342;
  core[004343] = 06001; code[004343] = &I04343;
  core[004344] = 06004; code[004344] = &I04344;
  core[004345] = 00064; code[004345] = &I04345;
  core[004346] = 06000; code[004346] = &I04346;
  core[004347] = 07402; code[004347] = &I04347;
  core[004350] = 07102; code[004350] = &I04350;
  core[004351] = 07012; code[004351] = &I04351;
  core[004352] = 07430; code[004352] = &I04352;
  core[004353] = 07440; code[004353] = &I04353;
  core[004354] = 07402; code[004354] = &I04354;
  core[004355] = 05360; code[004355] = &I04355;
  core[004356] = 04357; code[004356] = &D04356;
  core[004357] = 07402; code[004357] = &I04357;
  core[004360] = 07320; code[004360] = &L04360;
  core[004361] = 01375; code[004361] = &I04361;
  core[004362] = 03002; code[004362] = &I04362;
  core[004363] = 06005; code[004363] = &I04363;
  core[004364] = 07410; code[004364] = &I04364;
  core[004365] = 07402; code[004365] = &I04365;
  core[004366] = 07420; code[004366] = &I04366;
  core[004367] = 07440; code[004367] = &I04367;
  core[004370] = 07402; code[004370] = &I04370;
  core[004371] = 06000; code[004371] = &I04371;
  core[004372] = 07402; code[004372] = &I04372;
  core[004373] = 05774; code[004373] = &I04373;
  core[004374] = 04400; code[004374] = &P04374;
  core[004375] = 04376; code[004375] = &D04375;
  core[004376] = 07402; code[004376] = &I04376;
  core[004400] = 06007; code[004400] = &L04400;
  core[004401] = 01215; code[004401] = &I04401;
  core[004402] = 03002; code[004402] = &I04402;
  core[004403] = 07330; code[004403] = &I04403;
  core[004404] = 06005; code[004404] = &I04404;
  core[004405] = 07420; code[004405] = &I04405;
  core[004406] = 07402; code[004406] = &I04406;
  core[004407] = 06000; code[004407] = &I04407;
  core[004410] = 07402; code[004410] = &I04410;
  core[004411] = 06007; code[004411] = &I04411;
  core[004412] = 07300; code[004412] = &I04412;
  core[004413] = 05614; code[004413] = &I04413;
  core[004414] = 02677; code[004414] = &P04414;
  core[004415] = 04416; code[004415] = &D04415;
  core[004416] = 07402; code[004416] = &I04416;
}
// End of compiled code.

//
// More boilerplate.

//
// Emulate the hard stuff:
//   IOT instructions.
//   Group 3 OPR instructions (dependent on mode A or B).
//   Code modified at runtime.
void emul8() {
  register int op, ea;
  register int inst = core[pc];

  op = inst >> 9;
  if (op < 6) {
    //
    // Operation refences memory
    // Note: Direct EA is always in the current field!
    ea = pc & 070000;
    ea += inst & 0177;
    if (inst & 0200) ea += pc & 07600; // Page bit set
    if (inst & 0400) { // Indirect reference
      if ((ea&07770) == 0010) { // Autoindex
        if (++core[ea] == 010000) core[ea] = 0000;
      }
      if (op < 4) {
        ea = (df<<12)+core[ea];
      } else {
        ea = (ib<<12)+core[ea];
      }
    }
    if (op == 0) { // AND
      lac &= (010000|core[ea]);
    } else if (op == 1) { // TAD
      lac += core[ea];
    } else if (op == 2) { // ISZ
      if (++core[ea] == 010000) {
        core[ea] = 0;
        npc++;
      }
      code[ea] = &emul8;
    } else if (op == 3) { // DCA
      core[ea] = lac & 07777;
      lac &= 010000;
      code[ea] = &emul8;
    } else if (op == 4) { // JMS
      core[ea] = npc & 07777;
      npc = ea + 1;
      if ((ea & 07777) == 07777) npc -= 010000;
      code[ea] = &emul8;
      inh = 0;
    } else { // JMP
      npc = ea;
      inh = 0;
    }
  } else if (op == 6) {
    //
    // IOT -- hair ensues.
// BUGBUG: Should do more here.
    if ((inst&07770) == 06000) { // Interrupt control
      if ((inst&07) == 00) { // SKON
        npc += ion;
        ion = ionn = 0;
      } else if ((inst&07) == 01) { // ION
        ionn = 1;
      } else if ((inst&07) == 02) { // IOF
        ion = ionn = 0;
      } else if ((inst&07) == 03) { // SRQ
        npc += irq;
      } else if ((inst&07) == 04) { // GTF
        lac = (lac&010000)+((lac>>1)&04000)+(gt<<10)+(irq<<9)+(inh<<8)+(ion<<7)+rif;
      } else if ((inst&07) == 05) { // RTF
        int l = lac&04000;
        gt = !!(lac&02000);
        inh = !!(lac&0400);
        // Contrary to documentation, RTF ignores IE and enables interrupts.
        ionn = 1|!!(lac&0200);
        rif = lac&0177;
        lac = l<<1 | (lac&07777);
      } else if ((inst&07) == 06) { // SGT
        npc += gt;
      } else if ((inst&07) == 07) { // CAF
        lac = ion = ionn = ttof = ttofn = ttif = modeb = 0;
      }
    } else if ((inst&07700) == 06200) { // MMU
      int fld = (inst>>3) & 07;
      if (inst & 04) { // More decoding based on fld
        if (fld == 01) { // RDF
          lac |= df<<3;
        } else if (fld == 02) { // RIF
          lac |= pc>>12;
        } else if (fld == 03) { // RIB
          lac |= ib;
        } else if (fld == 04) { // RMF
          um = rif>>6;
          ib = (rif>>3)&07;
          df = rif&07;
        }
      } else { // fld is new IB, DF, or both
        if (inst & 01) { // CDF
          df = fld;
        }
        if (inst & 02) { // CIF
          ib = fld; // Save for next JMP, JMS
          inh = 1; // CIF sets inhibit to delay interrupts.
        }
      }
    } else if ((inst&07770) == 06010) { // High speed reader
    } else if ((inst&07770) == 06020) { // High speed punch
    } else if ((inst&07770) == 06030) { // Keyboard device
      if (inst == 06030) { // Clear input flag, no rrun
        ttif = 0;
      }
      if (inst & 01) { // Skip if ready
        npc += ttif;
      }
      if (inst & 02) { // Clear flag, set rrun
        lac &= 010000;
        ttif = 0;
      }
      if ((inst&05) == 04) { // OR in the last character
        lac |= ttib;
      } else if ((inst&05) == 05) { // TTY interrupt enable
        ttie = lac & 01;
      }
    } else if ((inst&07770) == 06040) { // Teleprinter device
      if (inst == 06040) { // Set printer flag
        ttof = ttofn = 1;
      } else if (inst == 06041) { // Skip if ready
        npc += ttof;
      } else if (inst == 06042) { // Clear flag
        ttof = ttofn = 0;
      }
      if (inst & 04) { // TLS, TPC Output a character
        ttofn = lac & 0177; // Borrow ttofn
//fprintf(stderr, "TLS %o\n", ttofn);
        write(1, &ttofn, 1);
        ttofn = 1;
      }
    } else if ((inst&07770) == 06070) { // VC8/I
    } else if ((inst&07770) == 06100) { // Memory Parity, Power Low
    } else if ((inst&07740) == 06140) { // 6140-6177 LINC, Type 338 display
    } else if ((inst&07770) == 06330) { // LAB-8
    } else if ((inst&07770) == 06340) { // LAB-8
    } else if ((inst&07700) == 06400) { // PT08
    } else if ((inst&07760) == 06760) { // 6760-6777 DECTape
    } else {
      fprintf(stderr, "IOT %05o treated as NOP\r\n", inst);
    }
  } else { // op == 7
    // Must be an OPR.
    if ((inst & 0400) == 0000) {
      //
      // Group 1 -- shifts, clears, complements
      // These are clearest when printed in chronological order.
      // The timing is model dependent, with the PDP-8I having the
      // strictest ordering.
      if (inst & 0200) lac &= 010000; // T1 CLA
      if (inst & 0100) lac &= 07777; // T1 CLL
      if (inst & 0020) lac ^= 010000; // T2 CML
      if (inst & 0040) lac ^= 07777; // T2 CMA
      if (inst & 0001) lac++; // T3 IAC
      if ((inst & 0006) == 004) lac = (lac<<1) + ((lac>>12)&1); // T4 RAL
      if ((inst & 0006) == 006) lac = (lac<<2) + ((lac>>11)&3); // T4 RTL
      if ((inst & 0012) == 010) lac = ((lac&017777)>>1) + ((lac&1)<<12); // T4 RAR
      if ((inst & 0012) == 012) lac = ((lac&017777)>>2) + ((lac&3)<<11); // T4 RTR
      if ((inst & 0016) == 002) lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077); // T4 BSW
    } else if ((inst & 0401) == 0400) {
      //
      // Group 2 -- Skips, hlt, read switches
      // These are clearest when printed in chronological order.
      // The timing here is not model dependent.
      skp = 0; // T1 may skip
      if (inst & 0040) skp = !(lac&07777); // T1 SZA
      if (inst & 0100) skp |= (lac&04000); // T1 SMA
      if (inst & 0020) skp |= (lac&010000); // T1 SNL
      if (inst & 0010) skp = !skp; // T1 SKP
      npc += !!skp; // T1 SKP
      if (inst & 0200) lac &= 010000; // T2 CLA
      if (inst & 0004) lac |= swr; // T3 OSR
      if (inst & 0002) hlt = 1; // T4 HLT
    } else {
      //
      // Group 3 -- Extended Arithmetic Unit
      // Where to find the operand (if any) depends on the mode (A or B).
      if (inst & 0200) lac &= 010000; // T1 CLA
      if ((inst & 0120) == 0100) {
        lac |= mq; // T2 MQA
      } else if ((inst & 0120) == 0020) {
        mq = lac & 07777; // T2 MQL
        lac &= 010000;
        if (inst & 010) modeb = 1; // SWAB=7431
      } else if ((inst & 0120) == 0120) {
        ea = lac; // Borrow 'ea' as temporary
        lac = (lac&010000) + mq;
        mq = ea & 07777; // T2 SWP
      }
      if ((inst & 0376) == 0046) modeb = gt = 0; // SWBA=7447
// BUGBUG: This EAE stuff is surely still wrong.
      if (modeb) {
        op = inst & 056;
	// Mode B EAE operations fetch a 24 bit operand whose
	// address is in the next word of the instruction stream.
        if (op == 000) { // T3 NOP
        } else if (op == 002) { // T3 ASC
          sc = lac & 037; lac &= 010000;
        } else if (op == 004) { // T3 MUY
//fprintf(stderr, "EAE Mode B MUY @%05o\r\n", pc);
          ea = (df<<12) + core[npc++]; // Address in DF
	  // The operand is single precision.
          op  = core[ea];
          op = ((lac<<12)+mq) * op;
          lac = op >> 12;
          mq  = op & 07777;
        } else if (op == 006) { // T3 DVI
//fprintf(stderr, "EAE Mode B DVI @%05o\r\n", pc);
          ea = (df<<12) + core[npc++]; // Address in DF
	  // The operand is single precision.
          op  = core[ea];
          lac &= 07777;
          ea  = (lac<<12)+mq;
          if (!op) {
            mq = 010000; // Force divide overflow
          } else {
            mq = ea / op;
          }
          if (mq & ~07777) {
            lac |= 010000;
            mq = (2*ea&07777) + 1;
            sc = 037;
          } else {
            lac  = ea % op;
          }
        } else if (op == 010) { // T3 NMI (must not set CLA, MQA, or MQL)
//fprintf(stderr, "EAE Mode B NMI @%05o\r\n", pc);
          sc = 0;
          lac = (lac<<12)+mq;
          if (lac == 040000000) lac = 0; // Negative zero?
          // 00000+02000 = 02000
          // 02000+02000 = 04000
          // 04000+02000 = 06000
          // 06000+02000 = 00000
          while ((lac & 017777777) && (~(lac+020000000) & 040000000)) {
            lac = lac << 1; // shl and try again
            sc++;
          }
          mq  = lac & 07777;
          lac = lac >> 12;
        } else if (op == 012) { // T3 SHL
//fprintf(stderr, "EAE Mode B SHL @%05o\r\n", pc);
          lac = (lac<<12) + mq;
          // Note one less shift than mode A
          lac = lac << core[npc++];
          mq  = lac & 07777;
          lac = lac >> 12;
          sc = 037;
        } else if (op == 014) { // T3 ASR
//fprintf(stderr, "EAE Mode B ASR @%05o\r\n", pc);
          lac &= 07777;
          if (lac & 04000) lac |= 03770000; // Sign extend
          lac = (lac<<13) + (mq<<1) + gt;
          // Note one less shift than mode A
          lac = lac >> core[npc++];
          gt = lac & 1;
          mq  = (lac>>1) & 07777;
          lac = lac >> 13;
          sc = 037;
        } else if (op == 016) { // T3 LSR
//fprintf(stderr, "EAE Mode B LSR @%05o\r\n", pc);
          lac &= 07777; // Don't shift in from link
          // Note one less shift than mode A
          lac = (lac<<13) + (mq<<1) + gt;
          lac = lac >> core[npc++];
          gt = lac & 1;
          mq  = (lac>>1) & 07777;
          lac = lac >> 13;
          sc = 037;
        } else if (op == 040) { // T3 SCA
          lac |= sc;
        } else if (op == 042) { // T3 DAD
//fprintf(stderr, "EAE Mode B DAD @%05o\r\n", pc);
          ea = (df<<12) + core[npc++]; // Address in DF
          op  = core[ea++]; // Least significant first
          op += core[ea]<<12;
          lac &= 07777; // Clear link
          lac = (lac<<12) + mq + op; // Carry out sets Link
          mq  = lac & 07777;
          lac = lac >> 12;
        } else if (op == 044) { // T3 DST
          ea = (df<<12) + core[npc++]; // Address in DF
          core[ea++] = mq; // Least significant first
          core[ea] = lac;
        } else if (op == 046) { // T3 SWBA
          modeb = 0;
        } else if (op == 050) { // T3 DPSZ
          if (((lac&07777)|mq) == 0) npc++;
        } else if (op == 052) { // T3 DPIC (must set MQA and MQL)
          // This is microcoded with MQA and MQL set.
          // As a result, MQ and LAC were swapped above, and
          // We need to swap them back here.
          lac = (mq<<12) + (lac&07777) + 1;
//fprintf(stderr, "EAE Mode B DPIC @%05o\r\n", pc);
          mq  = lac & 07777;
          lac = lac >> 12;
        } else if (op == 054) { // T3 DCM (must set MQA and MQL)
          // This is microcoded with MQA and MQL set.
          // As a result, MQ and LAC were swapped above, and
          // We need to swap them back here.
          lac &= 07777;
          lac = (~((mq<<12)+lac) & 077777777) + 1;
//fprintf(stderr, "EAE Mode B DCM @%05o\r\n", pc);
          mq  = lac & 07777;
          lac = (lac >> 12) & 017777;
        } else if (op == 056) { // T3 SAM
          lac &= 07777;
//fprintf(stderr, "EAE Mode B SAM @%05o\r\n", pc);
          gt  = (mq &04000)? mq  | 037777770000 : mq;
          gt -= (lac&04000)? lac | 037777770000 : lac;
          gt = gt >= 0;
          lac = mq + (~lac & 07777) + 1;
        }
//fprintf(stderr, "EAE Mode B %05o treated as NOP\r\n", inst);
      } else { // mode A
        if (inst & 0040) lac |= sc; // T2 SCA
	// Mode A EAE operations fetch an operand from the
        // next word of the instruction stream.
        if ((inst & 016) == 002) { // T3 SCL
          sc = (~core[npc++]) & 037;
        } else if ((inst & 016) == 004) { // T3 MUY
//fprintf(stderr, "EAE Mode A MUY @%05o\r\n", pc);
          op  = mq*core[npc] + (lac&07777);
//fprintf(stderr, "EAE Mode A MUY got %05o\r\n", op);
          lac = op >> 12;
          mq  = op & 07777;
          npc++;
        } else if ((inst & 056) == 006) { // T3 DVI, w/no SCA
          // SWBA executed in Mode A should not skip!
          // Previously, SWBA decoded as SCA DVI, which caused
          // it to skip the DVI operand.
//fprintf(stderr, "EAE Mode A DVI @%05o\r\n", pc);
          op = core[npc];
          lac &= 07777;
          ea  = (lac<<12)+mq;
          // Set link, first subtract
          if (!op) {
            mq = 010000; // Force divide overflow
          } else {
            mq = ea / op;
          }
          if (mq & ~07777) {
            //lac = 010000 | op;
            lac |= 010000;
            mq = (2*ea&07777) + 1;
            sc = 037;
          } else {
            lac  = ea % op;
          }
          npc++;
        } else if ((inst & 016) == 010) { // T3 NMI
//fprintf(stderr, "EAE Mode A NMI @%05o\r\n", pc);
          sc = 0;
          lac = (lac<<12)+mq;
          // 00000+02000 = 02000
          // 02000+02000 = 04000
          // 04000+02000 = 06000
          // 06000+02000 = 00000
          while ((lac & 017777777) && (~(lac+020000000) & 040000000)) {
            lac = lac << 1; // shl and try again
            sc++;
          }
          mq  = lac & 07777;
          lac = (lac >> 12) & 017777;
        } else if ((inst & 016) == 012) { // T3 SHL
//fprintf(stderr, "EAE Mode A SHL @%05o\r\n", pc);
          op = 1 + core[npc++];
          op = op > 31? 31 : op;
          lac = ((lac<<12)+mq) << op;
//fprintf(stderr, "EAE Mode A SHL partial result %08o\r\n", lac);
          gt = 0;
          mq  = lac & 07777;
          lac = (lac >> 12) & 017777;
        } else if ((inst & 016) == 014) { // T3 ASR
//fprintf(stderr, "EAE Mode A ASR @%05o\r\n", pc);
          op = 1 + core[npc++];
          op = op > 31? 31 : op;
          lac &= 07777;
          if (lac & 04000) lac |= 03770000; // Sign extend
          lac = ((lac<<12)+mq) >> op;
          gt = 0;
          mq  = lac & 07777;
          lac = lac >> 12;
        } else if ((inst & 016) == 016) { // T3 LSR
//fprintf(stderr, "EAE Mode A LSR @%05o\r\n", pc);
          op = 1 + core[npc++];
          op = op > 31? 31 : op;
          lac &= 07777; // Shift in zeroes
          lac = ((lac<<12)+mq) >> op;
          gt = 0;
          mq  = lac & 07777;
          lac = lac >> 12;
        }
      }
    }
  }
}

struct termios origtty;
struct termios rawtty;

void rawmode(void) {
  // Let these all silently fail is stdin is not a tty.
  tcgetattr(0, &origtty); // Save this for later
  tcgetattr(0, &rawtty); // Starts out the same
  cfmakeraw(&rawtty); // but is mangled hare
  tcsetattr(0, TCSAFLUSH, &rawtty);
  fcntl(0, F_SETFL, O_NONBLOCK);
}

void oldmode(void) {
  tcsetattr(0, TCSAFLUSH, &origtty);
  fcntl(0, F_SETFL, 0);
}

int main(int argc, char **argv) {
  int i;
  register code_t *f;
  //
  // Run-time Command line parsing.  Command lines can use:
  // =0nnnnn to specify a starting address.
  // %0nnnnn to specify switch register contents.
  // !0nnnnn to specify an exit character other than ^E.
  // -i to activate interaction after HLT.
  // -t to activate trace output on stderr.
  // Other stuff on the command line is retained with the intent
  //   to eventually add code to pass file specs to USR when OS/8
  //   support is added.
//@usr = ();
  for (i = 1; i < argc; i++) {
// BUGBUG: These overlap shell meta characters.  Shouldn't use #, !, etc.
    if (*argv[i] == '=') {
      sscanf(argv[i]+1, "%o", &pc);
    } else if (*argv[i] == '%') {
      sscanf(argv[i]+1, "%o", &swr);
    } else if (*argv[i] == '!') {
      sscanf(argv[i]+1, "%o", &echar);
    } else if (*argv[i] == '-') {
      if (argv[i][1] == 'i') {
        interact = 1;
      } else if (argv[i][1] == 't') {
        trace = 1;
      } else {
        fprintf(stderr, "Unsupported option '%s'\n", argv[i]);
        exit(1);
      }
    } else {
      // Save this one for USR
#if 0
    s/_/</; # Sneaks '<' past the shell
    y/A-Z/a-z/; # Monocase for USR
    push(@usr, $_);
#endif
    }
  }
  preinit(); // Initialize memory.
  rawmode(); // Set input to "raw" mode.
  atexit(&oldmode);

  //
  // The main execution loop.
  while (!hlt) {
    // Return if we are halted
// hlt = 1 if ++vrs > 100000;
    if (hlt) break;
    // This cruft is here because interrupt based programs don't
    // necessarily poll the input device.
    // What we want is to allow (but not encourage) over-run, 
    // with the new character replacing the old.
    // Note that we don't get here at all until the program
    // asks about keyboard ready..
    if (!ttid) {
      ttit = read(0, &ttib, 1);
      if (ttit > 0) {
        ttib |= 0200; // Fix up the character
        ttif = 1; // ... and set the flag.
        if (ttib == echar) { // Type ^E to hlt
          hlt++;
        }
      } else {
        ttid = 1000; // No input, again in 1000 instructions.
      }
    } else {
      ttid--;
    }
    irq = (ttie&ttof) | (ttie&ttif); // TODO: OR in others here too.
    if (ion && !inh) {
      // Interrupts are allowed, so do them.
      if (irq) {
        // Interrupt does a JMS 00000.
        rib = (um<<6)+(lac>>9)+df;
        core[00000] = pc & 07777;
        pc = 00001;
        ion = ionn = 0;
      }
    } 
    ion = ionn; // Allow one instruction after ION.
    ttof = ttofn; // Allow at least one after TLS, before interrupt.
    f = code + pc;
    npc = pc + 1; // Default next instruction
    if (trace || !*f) {
      fprintf(stderr, "%05o %04o %02o %05o:%04o\r\n", lac, mq, sc, pc, core[pc]);
    }
    // Check for code[pc] == 0.
    if (!*f) {
      fprintf(stderr, "Unitialized code fetched at %05o\r\n", pc);
      hlt = 1;
    } else {
      // This deals with PC wrap-around.
      // (D0CC actually depends on wrap for "false carry" tests.)
      if ((npc & 07777) == 0) npc -= 010000;
      (*f)(); // Call some compiled code
    }
    pc = npc;
  }
  //
  // Break means a HLT was done.
  exit(lac & 07777);
}

