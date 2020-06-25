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
void D00002() { lac &= (010000|core[000002]);  }
void D00003() { lac &= (010000|core[000003]);  }
void I00004() { lac &= (010000|core[000003]);  }
void D00005() { lac &= (010000|core[000000]);  }
void D00006() { lac &= (010000|core[000000]);  }
void D00007() { lac &= (010000|core[000000]);  }
void P00010() { lac &= (010000|core[000000]);  }
void D00020() { lac &= (010000|core[000000]);  }
void L00200() { emul8();  }
void D00201() { lac += core[000204];  }
void P00202() { core[000201] = lac & 07777; lac &= 010000; code[000201] = &emul8;  }
void P00203() { core[000205] = 00204; npc = 000205+1; code[000205] = &emul8; inh = 0;  }
void D00204() { npc = 000274; inh = 0;  }
void S00205() { lac &= (010000|core[000000]);  }
void I00206() { lac += core[000374];  }
void I00207() { core[000266] = lac & 07777; lac &= 010000; code[000266] = &emul8;  }
void I00210() { lac += core[000374];  }
void I00211() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void D00212() { core[000203] = lac & 07777; lac &= 010000; code[000203] = &emul8;  }
void I00213() { core[000225] = 00214; npc = 000225+1; code[000225] = &emul8; inh = 0;  }
void I00214() { npc = (ib<<12)+core[133]; inh = 0;  }
void S00215() { lac &= (010000|core[000000]);  }
void I00216() { lac += core[000374];  }
void I00217() { core[000266] = lac & 07777; lac &= 010000; code[000266] = &emul8;  }
void I00220() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void I00221() { lac += core[000374];  }
void I00222() { core[000203] = lac & 07777; lac &= 010000; code[000203] = &emul8;  }
void I00223() { core[000225] = 00224; npc = 000225+1; code[000225] = &emul8; inh = 0;  }
void I00224() { npc = (ib<<12)+core[141]; inh = 0;  }
void S00225() { lac &= (010000|core[000000]);  }
void L00226() { lac += core[(df<<12)+core[130]];  }
void I00227() { core[(df<<12)+core[131]] = lac & 07777; lac &= 010000; code[(df<<12)+core[131]] = &emul8;  }
void I00230() { lac += core[(df<<12)+core[130]];  }
void I00231() { lac ^= 07777; lac++;  }
void I00232() { lac += core[(df<<12)+core[131]];  }
void I00233() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00234() { hlt = 1;  }
void I00235() { if (++core[000202] == 010000) { core[000202] = 0; npc++; }; code[000202] = &emul8;  }
void I00236() {  }
void I00237() { if (++core[000203] == 010000) { core[000203] = 0; npc++; }; code[000203] = &emul8;  }
void I00240() {  }
void I00241() { if (++core[000266] == 010000) { core[000266] = 0; npc++; }; code[000266] = &emul8;  }
void I00242() { npc = 000226; inh = 0;  }
void I00243() { npc = (ib<<12)+core[149]; inh = 0;  }
void L00244() { core[000215] = 00245; npc = 000215+1; code[000215] = &emul8; inh = 0;  }
void I00245() { lac += core[000373];  }
void I00246() { core[000266] = lac & 07777; lac &= 010000; code[000266] = &emul8;  }
void I00247() { lac += core[000365];  }
void I00250() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void I00251() { lac += core[000372];  }
void I00252() { core[000203] = lac & 07777; lac &= 010000; code[000203] = &emul8;  }
void I00253() { core[000225] = 00254; npc = 000225+1; code[000225] = &emul8; inh = 0;  }
void I00254() { npc = (ib<<12)+core[250]; inh = 0;  }
void L00255() { core[000205] = 00256; npc = 000205+1; code[000205] = &emul8; inh = 0;  }
void I00256() { lac += core[000373];  }
void I00257() { core[000266] = lac & 07777; lac &= 010000; code[000266] = &emul8;  }
void I00260() { lac += core[000372];  }
void I00261() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void I00262() { lac += core[000365];  }
void I00263() { core[000203] = lac & 07777; lac &= 010000; code[000203] = &emul8;  }
void I00264() { core[000225] = 00265; npc = 000225+1; code[000225] = &emul8; inh = 0;  }
void I00265() { npc = (ib<<12)+core[245]; inh = 0;  }
void S00266() { lac &= (010000|core[000000]);  }
void I00267() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00270() { lac += core[000266];  }
void I00271() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00272() { lac += core[000371];  }
void I00273() { npc = (ib<<12)+core[182]; inh = 0;  }
void L00274() { lac &= 010000; lac &= 07777;  }
void I00275() { core[000202] = lac & 07777; lac &= 010000; code[000202] = &emul8;  }
void I00276() { core[000266] = 00277; npc = 000266+1; code[000266] = &emul8; inh = 0;  }
void I00277() { npc = 000377; inh = 0;  }
void S00300() { lac &= (010000|core[000000]);  }
void D00301() { lac ^= 07777;  }
void I00302() { core[000204] = lac & 07777; lac &= 010000; code[000204] = &emul8;  }
void I00303() { emul8();  }
void I00304() { lac ^= 07777;  }
void I00305() { emul8();  }
void I00306() { lac += core[000204];  }
void I00307() { emul8();  }
void I00310() { lac ^= 07777;  }
void I00311() { npc = (ib<<12)+core[192]; inh = 0;  }
void S00312() { lac &= (010000|core[000000]);  }
void I00313() { emul8();  }
void I00314() { lac &= 010000; lac |= swr;  }
void I00315() { core[000300] = 00316; npc = 000300+1; code[000300] = &emul8; inh = 0;  }
void I00316() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00317() { if (++core[000312] == 010000) { core[000312] = 0; npc++; }; code[000312] = &emul8;  }
void I00320() { npc = (ib<<12)+core[202]; inh = 0;  }
void P00321() { lac &= (010000|core[000000]);  }
void I00322() { if (++core[000202] == 010000) { core[000202] = 0; npc++; }; code[000202] = &emul8;  }
void I00323() { npc = (ib<<12)+core[209]; inh = 0;  }
void I00324() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00325() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00326() { core[000312] = 00327; npc = 000312+1; code[000312] = &emul8; inh = 0;  }
void I00327() { npc = 000336; inh = 0;  }
void I00330() { lac += core[000366];  }
void I00331() { core[000337] = 00332; npc = 000337+1; code[000337] = &emul8; inh = 0;  }
void I00332() { lac += core[000367];  }
void I00333() { core[000337] = 00334; npc = 000337+1; code[000337] = &emul8; inh = 0;  }
void I00334() { lac += core[000370];  }
void I00335() { core[000337] = 00336; npc = 000337+1; code[000337] = &emul8; inh = 0;  }
void L00336() { npc = 000345; inh = 0;  }
void S00337() { lac &= (010000|core[000000]);  }
void I00340() { emul8();  }
void L00341() { emul8();  }
void I00342() { npc = 000341; inh = 0;  }
void I00343() { lac &= 010000;  }
void I00344() { npc = (ib<<12)+core[223]; inh = 0;  }
void L00345() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00346() { core[000312] = 00347; npc = 000312+1; code[000312] = &emul8; inh = 0;  }
void I00347() { skp = 0; skp = !skp; npc += skp;  }
void I00350() { npc = 000355; inh = 0;  }
void I00351() { core[000266] = 00352; npc = 000266+1; code[000266] = &emul8; inh = 0;  }
void I00352() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00353() { core[000215] = 00354; npc = 000215+1; code[000215] = &emul8; inh = 0;  }
void I00354() { hlt = 1;  }
void L00355() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00356() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00357() { core[000312] = 00360; npc = 000312+1; code[000312] = &emul8; inh = 0;  }
void I00360() { npc = (ib<<12)+core[209]; inh = 0;  }
void I00361() { core[000266] = 00362; npc = 000266+1; code[000266] = &emul8; inh = 0;  }
void I00362() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00363() { npc = 000244; inh = 0;  }
void I00364() { npc = 000255; inh = 0;  }
void P00365() { lac &= (010000|core[000200]);  }
void D00366() { lac &= (010000|core[000215]);  }
void D00367() { lac &= (010000|core[000212]);  }
void D00370() { lac &= (010000|core[000301]);  }
void D00371() { emul8();  }
void P00372() { emul8();  }
void D00373() {  }
void D00374() { lac &= 010000;  }
void L00377() {  }
void D00400() { core[000437] = lac & 07777; lac &= 010000; code[000437] = &emul8;  }
void D00401() { lac += core[000442];  }
void I00402() { lac += core[000437];  }
void I00403() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00404() { lac += core[000443];  }
void I00405() { lac += core[000437];  }
void I00406() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00407() { lac += core[000445];  }
void I00410() { lac += core[000437];  }
void I00411() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00412() { lac += core[000446];  }
void I00413() { lac += core[000437];  }
void I00414() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00415() { lac += core[000447];  }
void I00416() { lac += core[000437];  }
void I00417() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00420() { lac += core[000444];  }
void I00421() { lac += core[000437];  }
void I00422() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00423() { lac += core[000437];  }
void I00424() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00425() { npc = 000433; inh = 0;  }
void I00426() { lac += core[000440];  }
void I00427() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00430() { lac += core[000450];  }
void I00431() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00432() { npc = 000577; inh = 0;  }
void L00433() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00434() { lac += core[000451];  }
void I00435() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00436() { npc = 000577; inh = 0;  }
void D00437() { lac &= (010000|core[000000]);  }
void D00440() { lac &= (010000|core[000400]);  }
void I00441() {  }
void D00442() { lac &= (010000|core[(df<<12)+core[363]]);  }
void D00443() { lac += core[000000];  }
void D00444() { lac &= (010000|core[000521]);  }
void D00445() { lac &= (010000|core[000500]);  }
void D00446() { lac &= (010000|core[(df<<12)+core[330]]);  }
void D00447() { lac &= (010000|core[000512]);  }
void D00450() { emul8();  }
void D00451() { lac += core[000401];  }
void L00577() {  }
void L00600() { lac &= 010000; lac &= 07777;  }
void I00601() { lac += core[000755];  }
void I00602() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00603() { lac++;  }
void I00604() { core[(ib<<12)+core[495]] = 00605; npc = (ib<<12)+core[495]+1; code[(ib<<12)+core[495]] = &emul8; inh = 0;  }
void I00605() { npc = 000624; inh = 0;  }
void I00606() { lac += core[000762];  }
void I00607() { core[000006] = lac & 07777; lac &= 010000; code[000006] = &emul8;  }
void I00610() { lac += core[000761];  }
void I00611() { core[000007] = lac & 07777; lac &= 010000; code[000007] = &emul8;  }
void I00612() { core[(ib<<12)+core[492]] = 00613; npc = (ib<<12)+core[492]+1; code[(ib<<12)+core[492]] = &emul8; inh = 0;  }
void I00613() { core[000765] = lac & 07777; lac &= 010000; code[000765] = &emul8;  }
void I00614() { lac += core[000001];  }
void I00615() { core[000763] = lac & 07777; lac &= 010000; code[000763] = &emul8;  }
void I00616() { lac += core[000002];  }
void I00617() { core[000764] = lac & 07777; lac &= 010000; code[000764] = &emul8;  }
void I00620() { lac += core[000003];  }
void I00621() { core[000766] = lac & 07777; lac &= 010000; code[000766] = &emul8;  }
void I00622() { lac += core[000005];  }
void I00623() { core[000767] = lac & 07777; lac &= 010000; code[000767] = &emul8;  }
void L00624() { lac &= 07777; lac++; lac = (lac<<1) + ((lac>>12)&1);  }
void I00625() { core[(ib<<12)+core[495]] = 00626; npc = (ib<<12)+core[495]+1; code[(ib<<12)+core[495]] = &emul8; inh = 0;  }
void I00626() { npc = 000634; inh = 0;  }
void I00627() { lac += core[000770];  }
void I00630() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I00631() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00632() { lac += core[000774];  }
void I00633() { core[000770] = lac & 07777; lac &= 010000; code[000770] = &emul8;  }
void L00634() { lac &= 010000; lac &= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I00635() { core[(ib<<12)+core[495]] = 00636; npc = (ib<<12)+core[495]+1; code[(ib<<12)+core[495]] = &emul8; inh = 0;  }
void I00636() { npc = 000644; inh = 0;  }
void I00637() { lac += core[000771];  }
void I00640() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I00641() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00642() { lac += core[000774];  }
void I00643() { core[000771] = lac & 07777; lac &= 010000; code[000771] = &emul8;  }
void L00644() { lac &= 010000; lac &= 07777;  }
void I00645() { lac += core[000763];  }
void I00646() { core[(df<<12)+core[500]] = lac & 07777; lac &= 010000; code[(df<<12)+core[500]] = &emul8;  }
void I00647() { lac += core[000765];  }
void I00650() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00651() { npc = 000667; inh = 0;  }
void I00652() { lac += core[000766];  }
void I00653() { lac += core[000775];  }
void I00654() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00655() { npc = 000662; inh = 0;  }
void I00656() { lac += core[000766];  }
void I00657() { lac += core[000776];  }
void I00660() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00661() { lac ^= 07777;  }
void L00662() { lac += core[000767];  }
void I00663() { core[(df<<12)+core[502]] = lac & 07777; lac &= 010000; code[(df<<12)+core[502]] = &emul8;  }
void I00664() { lac += core[000770];  }
void I00665() { core[(df<<12)+core[503]] = lac & 07777; lac &= 010000; code[(df<<12)+core[503]] = &emul8;  }
void I00666() { npc = 000671; inh = 0;  }
void L00667() { lac += core[000770];  }
void I00670() { core[(df<<12)+core[502]] = lac & 07777; lac &= 010000; code[(df<<12)+core[502]] = &emul8;  }
void L00671() { lac &= 010000; lac &= 07777;  }
void I00672() { lac += core[000770];  }
void I00673() { emul8();  }
void I00674() { lac += core[000771];  }
void I00675() { core[(ib<<12)+core[493]] = 00676; npc = (ib<<12)+core[493]+1; code[(ib<<12)+core[493]] = &emul8; inh = 0;  }
void I00676() { core[000772] = lac & 07777; lac &= 010000; code[000772] = &emul8;  }
void I00677() { lac += core[000756];  }
void I00700() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00701() { lac += core[000764];  }
void I00702() { lac++;  }
void I00703() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00704() { npc = 000600; inh = 0;  }
void I00705() { core[000753] = lac & 07777; lac &= 010000; code[000753] = &emul8;  }
void I00706() { lac += core[000773];  }
void I00707() { core[(df<<12)+core[491]] = lac & 07777; lac &= 010000; code[(df<<12)+core[491]] = &emul8;  }
void I00710() { lac += core[000771];  }
void I00711() { npc = (ib<<12)+core[500]; inh = 0;  }
void I00712() { core[000777] = lac & 07777; lac &= 010000; code[000777] = &emul8;  }
void I00713() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00714() { core[000724] = 00715; npc = 000724+1; code[000724] = &emul8; inh = 0;  }
void I00715() { lac += core[000772];  }
void I00716() { lac ^= 07777; lac++;  }
void I00717() { lac += core[000777];  }
void I00720() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00721() { core[000724] = 00722; npc = 000724+1; code[000724] = &emul8; inh = 0;  }
void I00722() { core[(ib<<12)+core[496]] = 00723; npc = (ib<<12)+core[496]+1; code[(ib<<12)+core[496]] = &emul8; inh = 0;  }
void I00723() { npc = 000600; inh = 0;  }
void S00724() { lac &= (010000|core[000000]);  }
void I00725() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00726() { core[(ib<<12)+core[495]] = 00727; npc = (ib<<12)+core[495]+1; code[(ib<<12)+core[495]] = &emul8; inh = 0;  }
void I00727() { npc = 000751; inh = 0;  }
void I00730() { lac += core[000770];  }
void I00731() { hlt = 1;  }
void I00732() { lac &= 010000;  }
void I00733() { lac += core[000771];  }
void I00734() { hlt = 1;  }
void I00735() { lac &= 010000;  }
void I00736() { lac += core[000001];  }
void I00737() { hlt = 1;  }
void I00740() { lac &= 010000;  }
void I00741() { lac += core[000764];  }
void I00742() { hlt = 1;  }
void I00743() { lac &= 010000;  }
void I00744() { lac += core[000766];  }
void I00745() { hlt = 1;  }
void I00746() { lac &= 010000;  }
void I00747() { lac += core[000767];  }
void I00750() { hlt = 1;  }
void L00751() { lac &= 010000; lac &= 07777;  }
void I00752() { npc = (ib<<12)+core[468]; inh = 0;  }
void P00753() { lac &= (010000|core[000000]);  }
void P00754() { lac &= (010000|core[000000]);  }
void P00755() { lac &= (010000|core[000000]);  }
void D00756() { lac &= (010000|core[000000]);  }
void P00757() { lac &= (010000|core[000000]);  }
void P00760() { lac &= (010000|core[000000]);  }
void D00761() { lac &= (010000|core[000000]);  }
void D00762() { lac &= (010000|core[000000]);  }
void D00763() { lac &= (010000|core[000000]);  }
void P00764() { lac &= (010000|core[000000]);  }
void D00765() { lac &= (010000|core[000000]);  }
void P00766() { lac &= (010000|core[000000]);  }
void P00767() { lac &= (010000|core[000000]);  }
void D00770() { lac &= (010000|core[000021]);  }
void D00771() { lac &= (010000|core[000037]);  }
void D00772() { lac &= (010000|core[000000]);  }
void D00773() { npc = (ib<<12)+core[0]; inh = 0;  }
void D00774() { lac &= (010000|core[000003]);  }
void D00775() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void D00776() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D00777() { lac &= (010000|core[000000]);  }
void P01000() { lac &= (010000|core[000000]);  }
void L01001() { lac += core[001167];  }
void I01002() { core[001140] = 01003; npc = 001140+1; code[001140] = &emul8; inh = 0;  }
void I01003() { core[001167] = lac & 07777; lac &= 010000; code[001167] = &emul8;  }
void I01004() { lac += core[001167];  }
void I01005() { emul8();  }
void I01006() { lac += core[000007];  }
void I01007() { emul8();  }
void I01010() { emul8();  }
void I01011() { lac += core[001171];  }
void I01012() { core[(ib<<12)+core[0]] = 01013; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void I01013() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I01014() { lac += core[000001];  }
void I01015() { core[001154] = 01016; npc = 001154+1; code[001154] = &emul8; inh = 0;  }
void I01016() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void L01017() { lac += core[001172];  }
void I01020() { core[001140] = 01021; npc = 001140+1; code[001140] = &emul8; inh = 0;  }
void I01021() { core[001172] = lac & 07777; lac &= 010000; code[001172] = &emul8;  }
void I01022() { core[001145] = 01023; npc = 001145+1; code[001145] = &emul8; inh = 0;  }
void I01023() { lac += core[001172];  }
void I01024() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I01025() { npc = 001017; inh = 0;  }
void I01026() { lac += core[001172];  }
void I01027() { lac += core[001173];  }
void I01030() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I01031() { npc = 001046; inh = 0;  }
void I01032() { lac += core[000020];  }
void I01033() { lac ^= 07777; lac++;  }
void I01034() { lac += core[001172];  }
void L01035() { core[001161] = 01036; npc = 001161+1; code[001161] = &emul8; inh = 0;  }
void I01036() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I01037() { npc = 001017; inh = 0;  }
void L01040() { lac += core[000020];  }
void I01041() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01042() { npc = 001001; inh = 0;  }
void I01043() { lac += core[001172];  }
void I01044() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I01045() { npc = 001061; inh = 0;  }
void L01046() { lac += core[000001];  }
void I01047() { emul8();  }
void I01050() { lac += core[001176];  }
void I01051() { core[(ib<<12)+core[0]] = 01052; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void I01052() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01053() { npc = 001040; inh = 0;  }
void I01054() { lac += core[001172];  }
void I01055() { core[001154] = 01056; npc = 001154+1; code[001154] = &emul8; inh = 0;  }
void I01056() { lac ^= 07777; lac++;  }
void I01057() { lac += core[000020];  }
void I01060() { npc = 001035; inh = 0;  }
void L01061() { lac += core[000001];  }
void I01062() { emul8();  }
void I01063() { lac += core[001176];  }
void I01064() { core[(ib<<12)+core[0]] = 01065; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void I01065() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01066() { npc = 001106; inh = 0;  }
void I01067() { lac += core[000002];  }
void I01070() { emul8();  }
void I01071() { lac += core[001173];  }
void I01072() { core[(ib<<12)+core[0]] = 01073; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void I01073() { emul8();  }
void I01074() { lac += core[000020];  }
void I01075() { emul8();  }
void I01076() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void L01077() { lac += core[000001];  }
void I01100() { emul8();  }
void I01101() { lac += core[001175];  }
void I01102() { core[(ib<<12)+core[0]] = 01103; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void I01103() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01104() { npc = 001111; inh = 0;  }
void I01105() { npc = (ib<<12)+core[512]; inh = 0;  }
void L01106() { lac += core[000020];  }
void I01107() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I01110() { npc = 001077; inh = 0;  }
void L01111() { lac += core[001177];  }
void I01112() { core[001140] = 01113; npc = 001140+1; code[001140] = &emul8; inh = 0;  }
void I01113() { core[001177] = lac & 07777; lac &= 010000; code[001177] = &emul8;  }
void I01114() { core[001145] = 01115; npc = 001145+1; code[001145] = &emul8; inh = 0;  }
void I01115() { lac += core[001177];  }
void I01116() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I01117() { npc = 001111; inh = 0;  }
void I01120() { lac += core[000002];  }
void I01121() { lac ^= 07777; lac++;  }
void I01122() { lac += core[001177];  }
void I01123() { core[001161] = 01124; npc = 001161+1; code[001161] = &emul8; inh = 0;  }
void I01124() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I01125() { npc = 001111; inh = 0;  }
void I01126() { lac += core[000003];  }
void I01127() { lac ^= 07777; lac++;  }
void I01130() { lac += core[001177];  }
void I01131() { core[001161] = 01132; npc = 001161+1; code[001161] = &emul8; inh = 0;  }
void I01132() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I01133() { npc = 001111; inh = 0;  }
void I01134() { lac += core[001177];  }
void I01135() { core[000005] = lac & 07777; lac &= 010000; code[000005] = &emul8;  }
void I01136() { lac ^= 07777;  }
void I01137() { npc = (ib<<12)+core[512]; inh = 0;  }
void S01140() { lac &= (010000|core[000000]);  }
void I01141() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I01142() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01143() { lac += core[001170];  }
void I01144() { npc = (ib<<12)+core[608]; inh = 0;  }
void S01145() { lac &= (010000|core[000000]);  }
void I01146() { lac += core[000007];  }
void I01147() { lac &= 07777;  }
void I01150() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01151() { lac ^= 010000;  }
void I01152() { lac += core[000006];  }
void I01153() { npc = (ib<<12)+core[613]; inh = 0;  }
void S01154() { lac &= (010000|core[000000]);  }
void I01155() { emul8();  }
void I01156() { lac += core[001174];  }
void I01157() { core[(ib<<12)+core[0]] = 01160; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void I01160() { npc = (ib<<12)+core[620]; inh = 0;  }
void S01161() { lac &= (010000|core[000000]);  }
void I01162() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I01163() { lac ^= 07777; lac++;  }
void I01164() { lac++;  }
void I01165() { lac++;  }
void I01166() { npc = (ib<<12)+core[625]; inh = 0;  }
void D01167() { lac &= (010000|core[000001]);  }
void D01170() { lac &= (010000|core[000003]);  }
void D01171() { lac &= (010000|core[(df<<12)+core[639]]);  }
void D01172() { lac &= (010000|core[000005]);  }
void D01173() { lac &= 010000;  }
void D01174() { lac &= (010000|core[000177]);  }
void D01175() { lac &= (010000|core[(df<<12)+core[0]]);  }
void D01176() { lac &= (010000|core[001000]);  }
void P01177() { lac &= (010000|core[000015]);  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &L00001;
  core[000002] = 00002; code[000002] = &D00002;
  core[000003] = 00003; code[000003] = &D00003;
  core[000004] = 00003; code[000004] = &I00004;
  core[000005] = 00000; code[000005] = &D00005;
  core[000006] = 00000; code[000006] = &D00006;
  core[000007] = 00000; code[000007] = &D00007;
  core[000010] = 00000; code[000010] = &P00010;
  core[000020] = 00000; code[000020] = &D00020;
  core[000200] = 06007; code[000200] = &L00200;
  core[000201] = 01204; code[000201] = &D00201;
  core[000202] = 03201; code[000202] = &P00202;
  core[000203] = 04205; code[000203] = &P00203;
  core[000204] = 05274; code[000204] = &D00204;
  core[000205] = 00000; code[000205] = &S00205;
  core[000206] = 01374; code[000206] = &I00206;
  core[000207] = 03266; code[000207] = &I00207;
  core[000210] = 01374; code[000210] = &I00210;
  core[000211] = 03202; code[000211] = &I00211;
  core[000212] = 03203; code[000212] = &D00212;
  core[000213] = 04225; code[000213] = &I00213;
  core[000214] = 05605; code[000214] = &I00214;
  core[000215] = 00000; code[000215] = &S00215;
  core[000216] = 01374; code[000216] = &I00216;
  core[000217] = 03266; code[000217] = &I00217;
  core[000220] = 03202; code[000220] = &I00220;
  core[000221] = 01374; code[000221] = &I00221;
  core[000222] = 03203; code[000222] = &I00222;
  core[000223] = 04225; code[000223] = &I00223;
  core[000224] = 05615; code[000224] = &I00224;
  core[000225] = 00000; code[000225] = &S00225;
  core[000226] = 01602; code[000226] = &L00226;
  core[000227] = 03603; code[000227] = &I00227;
  core[000230] = 01602; code[000230] = &I00230;
  core[000231] = 07041; code[000231] = &I00231;
  core[000232] = 01603; code[000232] = &I00232;
  core[000233] = 07640; code[000233] = &I00233;
  core[000234] = 07402; code[000234] = &I00234;
  core[000235] = 02202; code[000235] = &I00235;
  core[000236] = 07000; code[000236] = &I00236;
  core[000237] = 02203; code[000237] = &I00237;
  core[000240] = 07000; code[000240] = &I00240;
  core[000241] = 02266; code[000241] = &I00241;
  core[000242] = 05226; code[000242] = &I00242;
  core[000243] = 05625; code[000243] = &I00243;
  core[000244] = 04215; code[000244] = &L00244;
  core[000245] = 01373; code[000245] = &I00245;
  core[000246] = 03266; code[000246] = &I00246;
  core[000247] = 01365; code[000247] = &I00247;
  core[000250] = 03202; code[000250] = &I00250;
  core[000251] = 01372; code[000251] = &I00251;
  core[000252] = 03203; code[000252] = &I00252;
  core[000253] = 04225; code[000253] = &I00253;
  core[000254] = 05772; code[000254] = &I00254;
  core[000255] = 04205; code[000255] = &L00255;
  core[000256] = 01373; code[000256] = &I00256;
  core[000257] = 03266; code[000257] = &I00257;
  core[000260] = 01372; code[000260] = &I00260;
  core[000261] = 03202; code[000261] = &I00261;
  core[000262] = 01365; code[000262] = &I00262;
  core[000263] = 03203; code[000263] = &I00263;
  core[000264] = 04225; code[000264] = &I00264;
  core[000265] = 05765; code[000265] = &I00265;
  core[000266] = 00000; code[000266] = &S00266;
  core[000267] = 07330; code[000267] = &I00267;
  core[000270] = 01266; code[000270] = &I00270;
  core[000271] = 07630; code[000271] = &I00271;
  core[000272] = 01371; code[000272] = &I00272;
  core[000273] = 05666; code[000273] = &I00273;
  core[000274] = 07300; code[000274] = &L00274;
  core[000275] = 03202; code[000275] = &I00275;
  core[000276] = 04266; code[000276] = &I00276;
  core[000277] = 05377; code[000277] = &I00277;
  core[000300] = 00000; code[000300] = &S00300;
  core[000301] = 07040; code[000301] = &D00301;
  core[000302] = 03204; code[000302] = &I00302;
  core[000303] = 07501; code[000303] = &I00303;
  core[000304] = 07040; code[000304] = &I00304;
  core[000305] = 07421; code[000305] = &I00305;
  core[000306] = 01204; code[000306] = &I00306;
  core[000307] = 07501; code[000307] = &I00307;
  core[000310] = 07040; code[000310] = &I00310;
  core[000311] = 05700; code[000311] = &I00311;
  core[000312] = 00000; code[000312] = &S00312;
  core[000313] = 07421; code[000313] = &I00313;
  core[000314] = 07604; code[000314] = &I00314;
  core[000315] = 04300; code[000315] = &I00315;
  core[000316] = 07650; code[000316] = &I00316;
  core[000317] = 02312; code[000317] = &I00317;
  core[000320] = 05712; code[000320] = &I00320;
  core[000321] = 00000; code[000321] = &P00321;
  core[000322] = 02202; code[000322] = &I00322;
  core[000323] = 05721; code[000323] = &I00323;
  core[000324] = 07332; code[000324] = &I00324;
  core[000325] = 07012; code[000325] = &I00325;
  core[000326] = 04312; code[000326] = &I00326;
  core[000327] = 05336; code[000327] = &I00327;
  core[000330] = 01366; code[000330] = &I00330;
  core[000331] = 04337; code[000331] = &I00331;
  core[000332] = 01367; code[000332] = &I00332;
  core[000333] = 04337; code[000333] = &I00333;
  core[000334] = 01370; code[000334] = &I00334;
  core[000335] = 04337; code[000335] = &I00335;
  core[000336] = 05345; code[000336] = &L00336;
  core[000337] = 00000; code[000337] = &S00337;
  core[000340] = 06046; code[000340] = &I00340;
  core[000341] = 06041; code[000341] = &L00341;
  core[000342] = 05341; code[000342] = &I00342;
  core[000343] = 07200; code[000343] = &I00343;
  core[000344] = 05737; code[000344] = &I00344;
  core[000345] = 07332; code[000345] = &L00345;
  core[000346] = 04312; code[000346] = &I00346;
  core[000347] = 07410; code[000347] = &I00347;
  core[000350] = 05355; code[000350] = &I00350;
  core[000351] = 04266; code[000351] = &I00351;
  core[000352] = 07650; code[000352] = &I00352;
  core[000353] = 04215; code[000353] = &I00353;
  core[000354] = 07402; code[000354] = &I00354;
  core[000355] = 07332; code[000355] = &L00355;
  core[000356] = 07010; code[000356] = &I00356;
  core[000357] = 04312; code[000357] = &I00357;
  core[000360] = 05721; code[000360] = &I00360;
  core[000361] = 04266; code[000361] = &I00361;
  core[000362] = 07650; code[000362] = &I00362;
  core[000363] = 05244; code[000363] = &I00363;
  core[000364] = 05255; code[000364] = &I00364;
  core[000365] = 00200; code[000365] = &P00365;
  core[000366] = 00215; code[000366] = &D00366;
  core[000367] = 00212; code[000367] = &D00367;
  core[000370] = 00301; code[000370] = &D00370;
  core[000371] = 06400; code[000371] = &D00371;
  core[000372] = 06600; code[000372] = &P00372;
  core[000373] = 07000; code[000373] = &D00373;
  core[000374] = 07600; code[000374] = &D00374;
  core[000377] = 07000; code[000377] = &L00377;
  core[000400] = 03237; code[000400] = &D00400;
  core[000401] = 01242; code[000401] = &D00401;
  core[000402] = 01237; code[000402] = &I00402;
  core[000403] = 03010; code[000403] = &I00403;
  core[000404] = 01243; code[000404] = &I00404;
  core[000405] = 01237; code[000405] = &I00405;
  core[000406] = 03410; code[000406] = &I00406;
  core[000407] = 01245; code[000407] = &I00407;
  core[000410] = 01237; code[000410] = &I00410;
  core[000411] = 03410; code[000411] = &I00411;
  core[000412] = 01246; code[000412] = &I00412;
  core[000413] = 01237; code[000413] = &I00413;
  core[000414] = 03410; code[000414] = &I00414;
  core[000415] = 01247; code[000415] = &I00415;
  core[000416] = 01237; code[000416] = &I00416;
  core[000417] = 03410; code[000417] = &I00417;
  core[000420] = 01244; code[000420] = &I00420;
  core[000421] = 01237; code[000421] = &I00421;
  core[000422] = 03410; code[000422] = &I00422;
  core[000423] = 01237; code[000423] = &I00423;
  core[000424] = 07640; code[000424] = &I00424;
  core[000425] = 05233; code[000425] = &I00425;
  core[000426] = 01240; code[000426] = &I00426;
  core[000427] = 03410; code[000427] = &I00427;
  core[000430] = 01250; code[000430] = &I00430;
  core[000431] = 03410; code[000431] = &I00431;
  core[000432] = 05377; code[000432] = &I00432;
  core[000433] = 03410; code[000433] = &L00433;
  core[000434] = 01251; code[000434] = &I00434;
  core[000435] = 03410; code[000435] = &I00435;
  core[000436] = 05377; code[000436] = &I00436;
  core[000437] = 00000; code[000437] = &D00437;
  core[000440] = 00200; code[000440] = &D00440;
  core[000441] = 07000; code[000441] = &I00441;
  core[000442] = 00753; code[000442] = &D00442;
  core[000443] = 01000; code[000443] = &D00443;
  core[000444] = 00321; code[000444] = &D00444;
  core[000445] = 00300; code[000445] = &D00445;
  core[000446] = 00712; code[000446] = &D00446;
  core[000447] = 00312; code[000447] = &D00447;
  core[000450] = 06600; code[000450] = &D00450;
  core[000451] = 01201; code[000451] = &D00451;
  core[000577] = 07000; code[000577] = &L00577;
  core[000600] = 07300; code[000600] = &L00600;
  core[000601] = 01355; code[000601] = &I00601;
  core[000602] = 03000; code[000602] = &I00602;
  core[000603] = 07001; code[000603] = &I00603;
  core[000604] = 04757; code[000604] = &I00604;
  core[000605] = 05224; code[000605] = &I00605;
  core[000606] = 01362; code[000606] = &I00606;
  core[000607] = 03006; code[000607] = &I00607;
  core[000610] = 01361; code[000610] = &I00610;
  core[000611] = 03007; code[000611] = &I00611;
  core[000612] = 04754; code[000612] = &I00612;
  core[000613] = 03365; code[000613] = &I00613;
  core[000614] = 01001; code[000614] = &I00614;
  core[000615] = 03363; code[000615] = &I00615;
  core[000616] = 01002; code[000616] = &I00616;
  core[000617] = 03364; code[000617] = &I00617;
  core[000620] = 01003; code[000620] = &I00620;
  core[000621] = 03366; code[000621] = &I00621;
  core[000622] = 01005; code[000622] = &I00622;
  core[000623] = 03367; code[000623] = &I00623;
  core[000624] = 07105; code[000624] = &L00624;
  core[000625] = 04757; code[000625] = &I00625;
  core[000626] = 05234; code[000626] = &I00626;
  core[000627] = 01370; code[000627] = &I00627;
  core[000630] = 07104; code[000630] = &I00630;
  core[000631] = 07430; code[000631] = &I00631;
  core[000632] = 01374; code[000632] = &I00632;
  core[000633] = 03370; code[000633] = &I00633;
  core[000634] = 07307; code[000634] = &L00634;
  core[000635] = 04757; code[000635] = &I00635;
  core[000636] = 05244; code[000636] = &I00636;
  core[000637] = 01371; code[000637] = &I00637;
  core[000640] = 07104; code[000640] = &I00640;
  core[000641] = 07430; code[000641] = &I00641;
  core[000642] = 01374; code[000642] = &I00642;
  core[000643] = 03371; code[000643] = &I00643;
  core[000644] = 07300; code[000644] = &L00644;
  core[000645] = 01363; code[000645] = &I00645;
  core[000646] = 03764; code[000646] = &I00646;
  core[000647] = 01365; code[000647] = &I00647;
  core[000650] = 07650; code[000650] = &I00650;
  core[000651] = 05267; code[000651] = &I00651;
  core[000652] = 01366; code[000652] = &I00652;
  core[000653] = 01375; code[000653] = &I00653;
  core[000654] = 07630; code[000654] = &I00654;
  core[000655] = 05262; code[000655] = &I00655;
  core[000656] = 01366; code[000656] = &I00656;
  core[000657] = 01376; code[000657] = &I00657;
  core[000660] = 07630; code[000660] = &I00660;
  core[000661] = 07040; code[000661] = &I00661;
  core[000662] = 01367; code[000662] = &L00662;
  core[000663] = 03766; code[000663] = &I00663;
  core[000664] = 01370; code[000664] = &I00664;
  core[000665] = 03767; code[000665] = &I00665;
  core[000666] = 05271; code[000666] = &I00666;
  core[000667] = 01370; code[000667] = &L00667;
  core[000670] = 03766; code[000670] = &I00670;
  core[000671] = 07300; code[000671] = &L00671;
  core[000672] = 01370; code[000672] = &I00672;
  core[000673] = 07421; code[000673] = &I00673;
  core[000674] = 01371; code[000674] = &I00674;
  core[000675] = 04755; code[000675] = &I00675;
  core[000676] = 03372; code[000676] = &I00676;
  core[000677] = 01356; code[000677] = &I00677;
  core[000700] = 03000; code[000700] = &I00700;
  core[000701] = 01364; code[000701] = &I00701;
  core[000702] = 07001; code[000702] = &I00702;
  core[000703] = 07450; code[000703] = &I00703;
  core[000704] = 05200; code[000704] = &I00704;
  core[000705] = 03353; code[000705] = &I00705;
  core[000706] = 01373; code[000706] = &I00706;
  core[000707] = 03753; code[000707] = &I00707;
  core[000710] = 01371; code[000710] = &I00710;
  core[000711] = 05764; code[000711] = &I00711;
  core[000712] = 03377; code[000712] = &I00712;
  core[000713] = 07430; code[000713] = &I00713;
  core[000714] = 04324; code[000714] = &I00714;
  core[000715] = 01372; code[000715] = &I00715;
  core[000716] = 07041; code[000716] = &I00716;
  core[000717] = 01377; code[000717] = &I00717;
  core[000720] = 07640; code[000720] = &I00720;
  core[000721] = 04324; code[000721] = &I00721;
  core[000722] = 04760; code[000722] = &I00722;
  core[000723] = 05200; code[000723] = &I00723;
  core[000724] = 00000; code[000724] = &S00724;
  core[000725] = 07330; code[000725] = &I00725;
  core[000726] = 04757; code[000726] = &I00726;
  core[000727] = 05351; code[000727] = &I00727;
  core[000730] = 01370; code[000730] = &I00730;
  core[000731] = 07402; code[000731] = &I00731;
  core[000732] = 07200; code[000732] = &I00732;
  core[000733] = 01371; code[000733] = &I00733;
  core[000734] = 07402; code[000734] = &I00734;
  core[000735] = 07200; code[000735] = &I00735;
  core[000736] = 01001; code[000736] = &I00736;
  core[000737] = 07402; code[000737] = &I00737;
  core[000740] = 07200; code[000740] = &I00740;
  core[000741] = 01364; code[000741] = &I00741;
  core[000742] = 07402; code[000742] = &I00742;
  core[000743] = 07200; code[000743] = &I00743;
  core[000744] = 01366; code[000744] = &I00744;
  core[000745] = 07402; code[000745] = &I00745;
  core[000746] = 07200; code[000746] = &I00746;
  core[000747] = 01367; code[000747] = &I00747;
  core[000750] = 07402; code[000750] = &I00750;
  core[000751] = 07300; code[000751] = &L00751;
  core[000752] = 05724; code[000752] = &I00752;
  core[000753] = 00000; code[000753] = &P00753;
  core[000754] = 00000; code[000754] = &P00754;
  core[000755] = 00000; code[000755] = &P00755;
  core[000756] = 00000; code[000756] = &D00756;
  core[000757] = 00000; code[000757] = &P00757;
  core[000760] = 00000; code[000760] = &P00760;
  core[000761] = 00000; code[000761] = &D00761;
  core[000762] = 00000; code[000762] = &D00762;
  core[000763] = 00000; code[000763] = &D00763;
  core[000764] = 00000; code[000764] = &P00764;
  core[000765] = 00000; code[000765] = &D00765;
  core[000766] = 00000; code[000766] = &P00766;
  core[000767] = 00000; code[000767] = &P00767;
  core[000770] = 00021; code[000770] = &D00770;
  core[000771] = 00037; code[000771] = &D00771;
  core[000772] = 00000; code[000772] = &D00772;
  core[000773] = 05400; code[000773] = &D00773;
  core[000774] = 00003; code[000774] = &D00774;
  core[000775] = 07760; code[000775] = &D00775;
  core[000776] = 07770; code[000776] = &D00776;
  core[000777] = 00000; code[000777] = &D00777;
  core[001000] = 00000; code[001000] = &P01000;
  core[001001] = 01367; code[001001] = &L01001;
  core[001002] = 04340; code[001002] = &I01002;
  core[001003] = 03367; code[001003] = &I01003;
  core[001004] = 01367; code[001004] = &I01004;
  core[001005] = 07421; code[001005] = &I01005;
  core[001006] = 01007; code[001006] = &I01006;
  core[001007] = 07501; code[001007] = &I01007;
  core[001010] = 07421; code[001010] = &I01010;
  core[001011] = 01371; code[001011] = &I01011;
  core[001012] = 04400; code[001012] = &I01012;
  core[001013] = 03001; code[001013] = &I01013;
  core[001014] = 01001; code[001014] = &I01014;
  core[001015] = 04354; code[001015] = &I01015;
  core[001016] = 03020; code[001016] = &I01016;
  core[001017] = 01372; code[001017] = &L01017;
  core[001020] = 04340; code[001020] = &I01020;
  core[001021] = 03372; code[001021] = &I01021;
  core[001022] = 04345; code[001022] = &I01022;
  core[001023] = 01372; code[001023] = &I01023;
  core[001024] = 07620; code[001024] = &I01024;
  core[001025] = 05217; code[001025] = &I01025;
  core[001026] = 01372; code[001026] = &I01026;
  core[001027] = 01373; code[001027] = &I01027;
  core[001030] = 07620; code[001030] = &I01030;
  core[001031] = 05246; code[001031] = &I01031;
  core[001032] = 01020; code[001032] = &I01032;
  core[001033] = 07041; code[001033] = &I01033;
  core[001034] = 01372; code[001034] = &I01034;
  core[001035] = 04361; code[001035] = &L01035;
  core[001036] = 07700; code[001036] = &I01036;
  core[001037] = 05217; code[001037] = &I01037;
  core[001040] = 01020; code[001040] = &L01040;
  core[001041] = 07650; code[001041] = &I01041;
  core[001042] = 05201; code[001042] = &I01042;
  core[001043] = 01372; code[001043] = &I01043;
  core[001044] = 03002; code[001044] = &I01044;
  core[001045] = 05261; code[001045] = &I01045;
  core[001046] = 01001; code[001046] = &L01046;
  core[001047] = 07421; code[001047] = &I01047;
  core[001050] = 01376; code[001050] = &I01050;
  core[001051] = 04400; code[001051] = &I01051;
  core[001052] = 07650; code[001052] = &I01052;
  core[001053] = 05240; code[001053] = &I01053;
  core[001054] = 01372; code[001054] = &I01054;
  core[001055] = 04354; code[001055] = &I01055;
  core[001056] = 07041; code[001056] = &I01056;
  core[001057] = 01020; code[001057] = &I01057;
  core[001060] = 05235; code[001060] = &I01060;
  core[001061] = 01001; code[001061] = &L01061;
  core[001062] = 07421; code[001062] = &I01062;
  core[001063] = 01376; code[001063] = &I01063;
  core[001064] = 04400; code[001064] = &I01064;
  core[001065] = 07650; code[001065] = &I01065;
  core[001066] = 05306; code[001066] = &I01066;
  core[001067] = 01002; code[001067] = &I01067;
  core[001070] = 07421; code[001070] = &I01070;
  core[001071] = 01373; code[001071] = &I01071;
  core[001072] = 04400; code[001072] = &I01072;
  core[001073] = 07421; code[001073] = &I01073;
  core[001074] = 01020; code[001074] = &I01074;
  core[001075] = 07501; code[001075] = &I01075;
  core[001076] = 03003; code[001076] = &I01076;
  core[001077] = 01001; code[001077] = &L01077;
  core[001100] = 07421; code[001100] = &I01100;
  core[001101] = 01375; code[001101] = &I01101;
  core[001102] = 04400; code[001102] = &I01102;
  core[001103] = 07640; code[001103] = &I01103;
  core[001104] = 05311; code[001104] = &I01104;
  core[001105] = 05600; code[001105] = &I01105;
  core[001106] = 01020; code[001106] = &L01106;
  core[001107] = 03003; code[001107] = &I01107;
  core[001110] = 05277; code[001110] = &I01110;
  core[001111] = 01377; code[001111] = &L01111;
  core[001112] = 04340; code[001112] = &I01112;
  core[001113] = 03377; code[001113] = &I01113;
  core[001114] = 04345; code[001114] = &I01114;
  core[001115] = 01377; code[001115] = &I01115;
  core[001116] = 07620; code[001116] = &I01116;
  core[001117] = 05311; code[001117] = &I01117;
  core[001120] = 01002; code[001120] = &I01120;
  core[001121] = 07041; code[001121] = &I01121;
  core[001122] = 01377; code[001122] = &I01122;
  core[001123] = 04361; code[001123] = &I01123;
  core[001124] = 07700; code[001124] = &I01124;
  core[001125] = 05311; code[001125] = &I01125;
  core[001126] = 01003; code[001126] = &I01126;
  core[001127] = 07041; code[001127] = &I01127;
  core[001130] = 01377; code[001130] = &I01130;
  core[001131] = 04361; code[001131] = &I01131;
  core[001132] = 07700; code[001132] = &I01132;
  core[001133] = 05311; code[001133] = &I01133;
  core[001134] = 01377; code[001134] = &I01134;
  core[001135] = 03005; code[001135] = &I01135;
  core[001136] = 07040; code[001136] = &I01136;
  core[001137] = 05600; code[001137] = &I01137;
  core[001140] = 00000; code[001140] = &S01140;
  core[001141] = 07104; code[001141] = &I01141;
  core[001142] = 07430; code[001142] = &I01142;
  core[001143] = 01370; code[001143] = &I01143;
  core[001144] = 05740; code[001144] = &I01144;
  core[001145] = 00000; code[001145] = &S01145;
  core[001146] = 01007; code[001146] = &I01146;
  core[001147] = 07100; code[001147] = &I01147;
  core[001150] = 07650; code[001150] = &I01150;
  core[001151] = 07020; code[001151] = &I01151;
  core[001152] = 01006; code[001152] = &I01152;
  core[001153] = 05745; code[001153] = &I01153;
  core[001154] = 00000; code[001154] = &S01154;
  core[001155] = 07421; code[001155] = &I01155;
  core[001156] = 01374; code[001156] = &I01156;
  core[001157] = 04400; code[001157] = &I01157;
  core[001160] = 05754; code[001160] = &I01160;
  core[001161] = 00000; code[001161] = &S01161;
  core[001162] = 07500; code[001162] = &I01162;
  core[001163] = 07041; code[001163] = &I01163;
  core[001164] = 07001; code[001164] = &I01164;
  core[001165] = 07001; code[001165] = &I01165;
  core[001166] = 05761; code[001166] = &I01166;
  core[001167] = 00001; code[001167] = &D01167;
  core[001170] = 00003; code[001170] = &D01170;
  core[001171] = 00777; code[001171] = &D01171;
  core[001172] = 00005; code[001172] = &D01172;
  core[001173] = 07600; code[001173] = &D01173;
  core[001174] = 00177; code[001174] = &D01174;
  core[001175] = 00400; code[001175] = &D01175;
  core[001176] = 00200; code[001176] = &D01176;
  core[001177] = 00015; code[001177] = &P01177;
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

