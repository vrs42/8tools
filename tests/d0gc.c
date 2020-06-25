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
int swr = 0000;
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
void I00004() { lac &= (010000|core[000000]);  }
void I00005() { lac &= (010000|core[000000]);  }
void D00006() { emul8();  }
void P00007() { lac &= (010000|core[(df<<12)+core[0]]);  }
void P00010() { lac &= (010000|core[000000]);  }
void D00011() { lac &= (010000|core[000000]);  }
void D00012() { lac &= (010000|core[000100]);  }
void D00013() { lac &= (010000|core[000007]);  }
void D00014() { lac &= (010000|core[000003]);  }
void L00020() { lac += core[000175];  }
void I00021() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L00022() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00023() { lac += core[000010];  }
void I00024() { lac ^= 07777; lac++;  }
void I00025() { lac += core[000174];  }
void I00026() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00027() { npc = 000022; inh = 0;  }
void L00030() { lac &= 010000; lac |= swr;  }
void I00031() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00032() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00033() { npc = 000052; inh = 0;  }
void L00034() { core[000154] = 00035; npc = 000154+1; code[000154] = &emul8; inh = 0;  }
void I00035() { core[000167] = lac & 07777; lac &= 010000; code[000167] = &emul8;  }
void I00036() { lac += core[000167];  }
void I00037() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00040() { npc = 000046; inh = 0;  }
void I00041() { lac ^= 07777; lac++;  }
void I00042() { lac += core[000175];  }
void I00043() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00044() { npc = 000052; inh = 0;  }
void I00045() { npc = 000034; inh = 0;  }
void L00046() { lac ^= 07777; lac++;  }
void I00047() { lac += core[000174];  }
void I00050() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00051() { npc = 000034; inh = 0;  }
void L00052() { lac &= 010000; lac |= swr;  }
void I00053() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00054() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00055() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00056() { npc = 000075; inh = 0;  }
void L00057() { core[000154] = 00060; npc = 000154+1; code[000154] = &emul8; inh = 0;  }
void I00060() { core[000166] = lac & 07777; lac &= 010000; code[000166] = &emul8;  }
void I00061() { lac += core[000166];  }
void I00062() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00063() { npc = 000071; inh = 0;  }
void I00064() { lac ^= 07777; lac++;  }
void I00065() { lac += core[000175];  }
void I00066() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00067() { npc = 000075; inh = 0;  }
void I00070() { npc = 000057; inh = 0;  }
void L00071() { lac ^= 07777; lac++;  }
void I00072() { lac += core[000174];  }
void I00073() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00074() { npc = 000057; inh = 0;  }
void L00075() { lac &= 010000; lac |= swr;  }
void I00076() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00077() { lac = (lac<<2) + ((lac>>11)&3);  }
void D00100() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00101() { npc = 000104; inh = 0;  }
void I00102() { core[000154] = 00103; npc = 000154+1; code[000154] = &emul8; inh = 0;  }
void I00103() { core[000170] = lac & 07777; lac &= 010000; code[000170] = &emul8;  }
void L00104() { lac += core[000167];  }
void I00105() { lac ^= 07777; lac++;  }
void I00106() { lac += core[000166];  }
void I00107() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00110() { npc = 000030; inh = 0;  }
void I00111() { lac ^= 07777; lac++;  }
void I00112() { lac ^= 07777;  }
void I00113() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00114() { npc = 000030; inh = 0;  }
void I00115() { lac += core[000171];  }
void I00116() { core[(df<<12)+core[119]] = lac & 07777; lac &= 010000; code[(df<<12)+core[119]] = &emul8;  }
void I00117() { lac += core[000167];  }
void I00120() { lac++;  }
void I00121() { core[000173] = lac & 07777; lac &= 010000; code[000173] = &emul8;  }
void I00122() { lac += core[000172];  }
void I00123() { core[(df<<12)+core[123]] = lac & 07777; lac &= 010000; code[(df<<12)+core[123]] = &emul8;  }
void I00124() { lac += core[000170];  }
void P00125() {  }
void I00126() { npc = (ib<<12)+core[119]; inh = 0;  }
void I00127() { hlt = 1;  }
void L00130() { lac += core[(df<<12)+core[118]];  }
void I00131() { lac ^= 07777; lac++;  }
void I00132() { lac += core[000170];  }
void I00133() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00134() { core[(ib<<12)+core[127]] = 00135; npc = (ib<<12)+core[127]+1; code[(ib<<12)+core[127]] = &emul8; inh = 0;  }
void I00135() { core[(df<<12)+core[118]] = lac & 07777; lac &= 010000; code[(df<<12)+core[118]] = &emul8;  }
void I00136() { core[(df<<12)+core[119]] = lac & 07777; lac &= 010000; code[(df<<12)+core[119]] = &emul8;  }
void I00137() { core[(df<<12)+core[123]] = lac & 07777; lac &= 010000; code[(df<<12)+core[123]] = &emul8;  }
void I00140() { lac += core[000011];  }
void I00141() { lac++;  }
void I00142() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00143() { lac += core[000011];  }
void I00144() { lac += core[000012];  }
void I00145() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00146() { npc = 000030; inh = 0;  }
void I00147() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00150() { if (++core[000006] == 010000) { core[000006] = 0; npc++; }; code[000006] = &emul8;  }
void I00151() { npc = 000030; inh = 0;  }
void I00152() { core[(ib<<12)+core[7]] = 00153; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I00153() { &emul8;  }
void S00154() { &emul8;  }
void I00155() { lac &= 010000;  }
void I00156() { lac += core[000165];  }
void I00157() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I00160() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00161() { lac += core[000014];  }
void I00162() { core[000165] = lac & 07777; lac &= 010000; code[000165] = &emul8;  }
void I00163() { lac += core[000165];  }
void I00164() { npc = (ib<<12)+core[108]; inh = 0;  }
void D00165() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void P00166() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void P00167() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void D00170() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void D00171() { core[(df<<12)+core[118]] = lac & 07777; lac &= 010000; code[(df<<12)+core[118]] = &emul8;  }
void D00172() { npc = 000130; inh = 0;  }
void P00173() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void D00174() { lac &= 010000;  }
void D00175() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void P00176() { lac &= (010000|core[000000]);  }
void P00177() { lac &= (010000|core[000001]);  }
void I00200() { npc = 000020; inh = 0;  }
void S00201() { lac &= (010000|core[000000]);  }
void I00202() { lac &= 010000; lac |= swr;  }
void I00203() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00204() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00205() { npc = (ib<<12)+core[129]; inh = 0;  }
void I00206() { core[000265] = 00207; npc = 000265+1; code[000265] = &emul8; inh = 0;  }
void I00207() { lac += core[000175];  }
void I00210() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L00211() { if (++core[000010] == 010000) core[000010] = 0000;lac += core[(df<<12)+core[000010]];  }
void D00212() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00213() { core[000233] = 00214; npc = 000233+1; code[000233] = &emul8; inh = 0;  }
void I00214() { lac += core[000010];  }
void D00215() { lac ^= 07777; lac++;  }
void I00216() { lac += core[000174];  }
void I00217() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00220() { npc = 000211; inh = 0;  }
void I00221() { lac += core[000374];  }
void I00222() { core[000351] = 00223; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00223() { lac += core[000375];  }
void I00224() { core[000351] = 00225; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00225() { lac += core[000376];  }
void I00226() { core[000351] = 00227; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00227() { lac &= 010000; lac |= swr;  }
void I00230() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00231() { hlt = 1;  }
void I00232() { npc = (ib<<12)+core[129]; inh = 0;  }
void S00233() { lac &= (010000|core[000000]);  }
void I00234() { lac += core[000010];  }
void I00235() { lac ^= 07777; lac++;  }
void I00236() { lac += core[000167];  }
void I00237() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D00240() { npc = (ib<<12)+core[155]; inh = 0;  }
void I00241() { lac += core[000010];  }
void I00242() { lac ^= 07777; lac++;  }
void I00243() { lac += core[000173];  }
void I00244() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00245() { npc = (ib<<12)+core[155]; inh = 0;  }
void I00246() { lac += core[000372];  }
void I00247() { core[000351] = 00250; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00250() { lac += core[000010];  }
void I00251() { core[000310] = 00252; npc = 000310+1; code[000310] = &emul8; inh = 0;  }
void I00252() { lac += core[000010];  }
void I00253() { core[000176] = lac & 07777; lac &= 010000; code[000176] = &emul8;  }
void I00254() { lac += core[000373];  }
void I00255() { core[000351] = 00256; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00256() { lac += core[(df<<12)+core[126]];  }
void I00257() { core[000310] = 00260; npc = 000310+1; code[000310] = &emul8; inh = 0;  }
void D00260() { lac += core[000375];  }
void I00261() { core[000351] = 00262; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00262() { lac += core[000376];  }
void I00263() { core[000351] = 00264; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00264() { npc = (ib<<12)+core[155]; inh = 0;  }
void S00265() { lac &= (010000|core[000000]);  }
void I00266() { lac &= 010000;  }
void I00267() { lac += core[000367];  }
void I00270() { core[000351] = 00271; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00271() { lac += core[000167];  }
void I00272() { core[000310] = 00273; npc = 000310+1; code[000310] = &emul8; inh = 0;  }
void I00273() { lac += core[000371];  }
void I00274() { core[000351] = 00275; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00275() { lac += core[000166];  }
void I00276() { core[000310] = 00277; npc = 000310+1; code[000310] = &emul8; inh = 0;  }
void I00277() { lac += core[000377];  }
void I00300() { core[000351] = 00301; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void D00301() { lac += core[000170];  }
void I00302() { core[000310] = 00303; npc = 000310+1; code[000310] = &emul8; inh = 0;  }
void D00303() { lac += core[000375];  }
void I00304() { core[000351] = 00305; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void D00305() { lac += core[000376];  }
void D00306() { core[000351] = 00307; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00307() { npc = (ib<<12)+core[181]; inh = 0;  }
void P00310() { npc = 000310; inh = 0;  }
void I00311() { core[000366] = lac & 07777; lac &= 010000; code[000366] = &emul8;  }
void I00312() { lac += core[000366];  }
void I00313() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D00314() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00315() { core[000365] = lac & 07777; lac &= 010000; code[000365] = &emul8;  }
void I00316() { lac += core[000365];  }
void D00317() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00320() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00321() { core[000364] = lac & 07777; lac &= 010000; code[000364] = &emul8;  }
void I00322() { lac += core[000364];  }
void I00323() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00324() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00325() { core[000363] = lac & 07777; lac &= 010000; code[000363] = &emul8;  }
void I00326() { lac += core[000370];  }
void I00327() { core[000351] = 00330; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00330() { lac += core[000357];  }
void I00331() { core[000360] = lac & 07777; lac &= 010000; code[000360] = &emul8;  }
void L00332() { lac += core[000363];  }
void I00333() { lac &= (010000|core[000361]);  }
void I00334() { lac += core[000362];  }
void I00335() { core[000351] = 00336; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00336() { lac += core[000364];  }
void I00337() { core[000363] = lac & 07777; lac &= 010000; code[000363] = &emul8;  }
void I00340() { lac += core[000365];  }
void I00341() { core[000364] = lac & 07777; lac &= 010000; code[000364] = &emul8;  }
void I00342() { lac += core[000366];  }
void I00343() { core[000365] = lac & 07777; lac &= 010000; code[000365] = &emul8;  }
void I00344() { if (++core[000360] == 010000) { core[000360] = 0; npc++; }; code[000360] = &emul8;  }
void I00345() { npc = 000332; inh = 0;  }
void I00346() { lac += core[000370];  }
void I00347() { core[000351] = 00350; npc = 000351+1; code[000351] = &emul8; inh = 0;  }
void I00350() { npc = (ib<<12)+core[200]; inh = 0;  }
void S00351() { lac &= (010000|core[000000]);  }
void I00352() { emul8();  }
void L00353() { emul8();  }
void I00354() { npc = 000353; inh = 0;  }
void I00355() { lac &= 010000;  }
void I00356() { npc = (ib<<12)+core[233]; inh = 0;  }
void D00357() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void D00360() { lac &= (010000|core[000000]);  }
void D00361() { lac &= (010000|core[000007]);  }
void D00362() { lac &= (010000|core[000260]);  }
void D00363() { lac &= (010000|core[000000]);  }
void D00364() { lac &= (010000|core[000000]);  }
void D00365() { lac &= (010000|core[000000]);  }
void D00366() { lac &= (010000|core[000000]);  }
void D00367() { lac &= (010000|core[000306]);  }
void D00370() { lac &= (010000|core[000240]);  }
void D00371() { lac &= (010000|core[000301]);  }
void D00372() { lac &= (010000|core[000314]);  }
void D00373() { lac &= (010000|core[000303]);  }
void D00374() { lac &= (010000|core[000305]);  }
void D00375() { lac &= (010000|core[000215]);  }
void D00376() { lac &= (010000|core[000212]);  }
void D00377() { lac &= (010000|core[000317]);  }
void S00400() { lac &= (010000|core[000000]);  }
void I00401() { lac += core[000407];  }
void I00402() { core[000006] = lac & 07777; lac &= 010000; code[000006] = &emul8;  }
void I00403() { lac += core[000013];  }
void I00404() { emul8();  }
void I00405() { lac &= 010000;  }
void I00406() { npc = (ib<<12)+core[256]; inh = 0;  }
void D00407() { emul8();  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &L00001;
  core[000002] = 00002; code[000002] = &D00002;
  core[000003] = 00003; code[000003] = &D00003;
  core[000004] = 00000; code[000004] = &I00004;
  core[000005] = 00000; code[000005] = &I00005;
  core[000006] = 07771; code[000006] = &D00006;
  core[000007] = 00400; code[000007] = &P00007;
  core[000010] = 00000; code[000010] = &P00010;
  core[000011] = 00000; code[000011] = &D00011;
  core[000012] = 00300; code[000012] = &D00012;
  core[000013] = 00207; code[000013] = &D00013;
  core[000014] = 00003; code[000014] = &D00014;
  core[000020] = 01175; code[000020] = &L00020;
  core[000021] = 03010; code[000021] = &I00021;
  core[000022] = 03410; code[000022] = &L00022;
  core[000023] = 01010; code[000023] = &I00023;
  core[000024] = 07041; code[000024] = &I00024;
  core[000025] = 01174; code[000025] = &I00025;
  core[000026] = 07640; code[000026] = &I00026;
  core[000027] = 05022; code[000027] = &I00027;
  core[000030] = 07604; code[000030] = &L00030;
  core[000031] = 07006; code[000031] = &I00031;
  core[000032] = 07510; code[000032] = &I00032;
  core[000033] = 05052; code[000033] = &I00033;
  core[000034] = 04154; code[000034] = &L00034;
  core[000035] = 03167; code[000035] = &I00035;
  core[000036] = 01167; code[000036] = &I00036;
  core[000037] = 07510; code[000037] = &I00037;
  core[000040] = 05046; code[000040] = &I00040;
  core[000041] = 07041; code[000041] = &I00041;
  core[000042] = 01175; code[000042] = &I00042;
  core[000043] = 07710; code[000043] = &I00043;
  core[000044] = 05052; code[000044] = &I00044;
  core[000045] = 05034; code[000045] = &I00045;
  core[000046] = 07041; code[000046] = &L00046;
  core[000047] = 01174; code[000047] = &I00047;
  core[000050] = 07710; code[000050] = &I00050;
  core[000051] = 05034; code[000051] = &I00051;
  core[000052] = 07604; code[000052] = &L00052;
  core[000053] = 07006; code[000053] = &I00053;
  core[000054] = 07004; code[000054] = &I00054;
  core[000055] = 07510; code[000055] = &I00055;
  core[000056] = 05075; code[000056] = &I00056;
  core[000057] = 04154; code[000057] = &L00057;
  core[000060] = 03166; code[000060] = &I00060;
  core[000061] = 01166; code[000061] = &I00061;
  core[000062] = 07510; code[000062] = &I00062;
  core[000063] = 05071; code[000063] = &I00063;
  core[000064] = 07041; code[000064] = &I00064;
  core[000065] = 01175; code[000065] = &I00065;
  core[000066] = 07710; code[000066] = &I00066;
  core[000067] = 05075; code[000067] = &I00067;
  core[000070] = 05057; code[000070] = &I00070;
  core[000071] = 07041; code[000071] = &L00071;
  core[000072] = 01174; code[000072] = &I00072;
  core[000073] = 07710; code[000073] = &I00073;
  core[000074] = 05057; code[000074] = &I00074;
  core[000075] = 07604; code[000075] = &L00075;
  core[000076] = 07006; code[000076] = &I00076;
  core[000077] = 07006; code[000077] = &I00077;
  core[000100] = 07710; code[000100] = &D00100;
  core[000101] = 05104; code[000101] = &I00101;
  core[000102] = 04154; code[000102] = &I00102;
  core[000103] = 03170; code[000103] = &I00103;
  core[000104] = 01167; code[000104] = &L00104;
  core[000105] = 07041; code[000105] = &I00105;
  core[000106] = 01166; code[000106] = &I00106;
  core[000107] = 07450; code[000107] = &I00107;
  core[000110] = 05030; code[000110] = &I00110;
  core[000111] = 07041; code[000111] = &I00111;
  core[000112] = 07040; code[000112] = &I00112;
  core[000113] = 07650; code[000113] = &I00113;
  core[000114] = 05030; code[000114] = &I00114;
  core[000115] = 01171; code[000115] = &I00115;
  core[000116] = 03567; code[000116] = &I00116;
  core[000117] = 01167; code[000117] = &I00117;
  core[000120] = 07001; code[000120] = &I00120;
  core[000121] = 03173; code[000121] = &I00121;
  core[000122] = 01172; code[000122] = &I00122;
  core[000123] = 03573; code[000123] = &I00123;
  core[000124] = 01170; code[000124] = &I00124;
  core[000125] = 07000; code[000125] = &P00125;
  core[000126] = 05567; code[000126] = &I00126;
  core[000127] = 07402; code[000127] = &I00127;
  core[000130] = 01566; code[000130] = &L00130;
  core[000131] = 07041; code[000131] = &I00131;
  core[000132] = 01170; code[000132] = &I00132;
  core[000133] = 07640; code[000133] = &I00133;
  core[000134] = 04577; code[000134] = &I00134;
  core[000135] = 03566; code[000135] = &I00135;
  core[000136] = 03567; code[000136] = &I00136;
  core[000137] = 03573; code[000137] = &I00137;
  core[000140] = 01011; code[000140] = &I00140;
  core[000141] = 07001; code[000141] = &I00141;
  core[000142] = 03011; code[000142] = &I00142;
  core[000143] = 01011; code[000143] = &I00143;
  core[000144] = 01012; code[000144] = &I00144;
  core[000145] = 07640; code[000145] = &I00145;
  core[000146] = 05030; code[000146] = &I00146;
  core[000147] = 03011; code[000147] = &I00147;
  core[000150] = 02006; code[000150] = &I00150;
  core[000151] = 05030; code[000151] = &I00151;
  core[000152] = 04407; code[000152] = &I00152;
  core[000153] = 05030; code[000153] = &I00153;
  core[000154] = 00000; code[000154] = &S00154;
  core[000155] = 07200; code[000155] = &I00155;
  core[000156] = 01165; code[000156] = &I00156;
  core[000157] = 07104; code[000157] = &I00157;
  core[000160] = 07430; code[000160] = &I00160;
  core[000161] = 01014; code[000161] = &I00161;
  core[000162] = 03165; code[000162] = &I00162;
  core[000163] = 01165; code[000163] = &I00163;
  core[000164] = 05554; code[000164] = &I00164;
  core[000165] = 02525; code[000165] = &D00165;
  core[000166] = 03000; code[000166] = &P00166;
  core[000167] = 03001; code[000167] = &P00167;
  core[000170] = 02525; code[000170] = &D00170;
  core[000171] = 03566; code[000171] = &D00171;
  core[000172] = 05130; code[000172] = &D00172;
  core[000173] = 03002; code[000173] = &P00173;
  core[000174] = 07600; code[000174] = &D00174;
  core[000175] = 00410; code[000175] = &D00175;
  core[000176] = 00000; code[000176] = &P00176;
  core[000177] = 00201; code[000177] = &P00177;
  core[000200] = 05020; code[000200] = &I00200;
  core[000201] = 00000; code[000201] = &S00201;
  core[000202] = 07604; code[000202] = &I00202;
  core[000203] = 07004; code[000203] = &I00203;
  core[000204] = 07710; code[000204] = &I00204;
  core[000205] = 05601; code[000205] = &I00205;
  core[000206] = 04265; code[000206] = &I00206;
  core[000207] = 01175; code[000207] = &I00207;
  core[000210] = 03010; code[000210] = &I00210;
  core[000211] = 01410; code[000211] = &L00211;
  core[000212] = 07640; code[000212] = &D00212;
  core[000213] = 04233; code[000213] = &I00213;
  core[000214] = 01010; code[000214] = &I00214;
  core[000215] = 07041; code[000215] = &D00215;
  core[000216] = 01174; code[000216] = &I00216;
  core[000217] = 07640; code[000217] = &I00217;
  core[000220] = 05211; code[000220] = &I00220;
  core[000221] = 01374; code[000221] = &I00221;
  core[000222] = 04351; code[000222] = &I00222;
  core[000223] = 01375; code[000223] = &I00223;
  core[000224] = 04351; code[000224] = &I00224;
  core[000225] = 01376; code[000225] = &I00225;
  core[000226] = 04351; code[000226] = &I00226;
  core[000227] = 07604; code[000227] = &I00227;
  core[000230] = 07700; code[000230] = &I00230;
  core[000231] = 07402; code[000231] = &I00231;
  core[000232] = 05601; code[000232] = &I00232;
  core[000233] = 00000; code[000233] = &S00233;
  core[000234] = 01010; code[000234] = &I00234;
  core[000235] = 07041; code[000235] = &I00235;
  core[000236] = 01167; code[000236] = &I00236;
  core[000237] = 07650; code[000237] = &I00237;
  core[000240] = 05633; code[000240] = &D00240;
  core[000241] = 01010; code[000241] = &I00241;
  core[000242] = 07041; code[000242] = &I00242;
  core[000243] = 01173; code[000243] = &I00243;
  core[000244] = 07650; code[000244] = &I00244;
  core[000245] = 05633; code[000245] = &I00245;
  core[000246] = 01372; code[000246] = &I00246;
  core[000247] = 04351; code[000247] = &I00247;
  core[000250] = 01010; code[000250] = &I00250;
  core[000251] = 04310; code[000251] = &I00251;
  core[000252] = 01010; code[000252] = &I00252;
  core[000253] = 03176; code[000253] = &I00253;
  core[000254] = 01373; code[000254] = &I00254;
  core[000255] = 04351; code[000255] = &I00255;
  core[000256] = 01576; code[000256] = &I00256;
  core[000257] = 04310; code[000257] = &I00257;
  core[000260] = 01375; code[000260] = &D00260;
  core[000261] = 04351; code[000261] = &I00261;
  core[000262] = 01376; code[000262] = &I00262;
  core[000263] = 04351; code[000263] = &I00263;
  core[000264] = 05633; code[000264] = &I00264;
  core[000265] = 00000; code[000265] = &S00265;
  core[000266] = 07200; code[000266] = &I00266;
  core[000267] = 01367; code[000267] = &I00267;
  core[000270] = 04351; code[000270] = &I00270;
  core[000271] = 01167; code[000271] = &I00271;
  core[000272] = 04310; code[000272] = &I00272;
  core[000273] = 01371; code[000273] = &I00273;
  core[000274] = 04351; code[000274] = &I00274;
  core[000275] = 01166; code[000275] = &I00275;
  core[000276] = 04310; code[000276] = &I00276;
  core[000277] = 01377; code[000277] = &I00277;
  core[000300] = 04351; code[000300] = &I00300;
  core[000301] = 01170; code[000301] = &D00301;
  core[000302] = 04310; code[000302] = &I00302;
  core[000303] = 01375; code[000303] = &D00303;
  core[000304] = 04351; code[000304] = &I00304;
  core[000305] = 01376; code[000305] = &D00305;
  core[000306] = 04351; code[000306] = &D00306;
  core[000307] = 05665; code[000307] = &I00307;
  core[000310] = 05310; code[000310] = &P00310;
  core[000311] = 03366; code[000311] = &I00311;
  core[000312] = 01366; code[000312] = &I00312;
  core[000313] = 07012; code[000313] = &I00313;
  core[000314] = 07010; code[000314] = &D00314;
  core[000315] = 03365; code[000315] = &I00315;
  core[000316] = 01365; code[000316] = &I00316;
  core[000317] = 07012; code[000317] = &D00317;
  core[000320] = 07010; code[000320] = &I00320;
  core[000321] = 03364; code[000321] = &I00321;
  core[000322] = 01364; code[000322] = &I00322;
  core[000323] = 07012; code[000323] = &I00323;
  core[000324] = 07010; code[000324] = &I00324;
  core[000325] = 03363; code[000325] = &I00325;
  core[000326] = 01370; code[000326] = &I00326;
  core[000327] = 04351; code[000327] = &I00327;
  core[000330] = 01357; code[000330] = &I00330;
  core[000331] = 03360; code[000331] = &I00331;
  core[000332] = 01363; code[000332] = &L00332;
  core[000333] = 00361; code[000333] = &I00333;
  core[000334] = 01362; code[000334] = &I00334;
  core[000335] = 04351; code[000335] = &I00335;
  core[000336] = 01364; code[000336] = &I00336;
  core[000337] = 03363; code[000337] = &I00337;
  core[000340] = 01365; code[000340] = &I00340;
  core[000341] = 03364; code[000341] = &I00341;
  core[000342] = 01366; code[000342] = &I00342;
  core[000343] = 03365; code[000343] = &I00343;
  core[000344] = 02360; code[000344] = &I00344;
  core[000345] = 05332; code[000345] = &I00345;
  core[000346] = 01370; code[000346] = &I00346;
  core[000347] = 04351; code[000347] = &I00347;
  core[000350] = 05710; code[000350] = &I00350;
  core[000351] = 00000; code[000351] = &S00351;
  core[000352] = 06046; code[000352] = &I00352;
  core[000353] = 06041; code[000353] = &L00353;
  core[000354] = 05353; code[000354] = &I00354;
  core[000355] = 07200; code[000355] = &I00355;
  core[000356] = 05751; code[000356] = &I00356;
  core[000357] = 07774; code[000357] = &D00357;
  core[000360] = 00000; code[000360] = &D00360;
  core[000361] = 00007; code[000361] = &D00361;
  core[000362] = 00260; code[000362] = &D00362;
  core[000363] = 00000; code[000363] = &D00363;
  core[000364] = 00000; code[000364] = &D00364;
  core[000365] = 00000; code[000365] = &D00365;
  core[000366] = 00000; code[000366] = &D00366;
  core[000367] = 00306; code[000367] = &D00367;
  core[000370] = 00240; code[000370] = &D00370;
  core[000371] = 00301; code[000371] = &D00371;
  core[000372] = 00314; code[000372] = &D00372;
  core[000373] = 00303; code[000373] = &D00373;
  core[000374] = 00305; code[000374] = &D00374;
  core[000375] = 00215; code[000375] = &D00375;
  core[000376] = 00212; code[000376] = &D00376;
  core[000377] = 00317; code[000377] = &D00377;
  core[000400] = 00000; code[000400] = &S00400;
  core[000401] = 01207; code[000401] = &I00401;
  core[000402] = 03006; code[000402] = &I00402;
  core[000403] = 01013; code[000403] = &I00403;
  core[000404] = 06046; code[000404] = &I00404;
  core[000405] = 07200; code[000405] = &I00405;
  core[000406] = 05600; code[000406] = &I00406;
  core[000407] = 07771; code[000407] = &D00407;
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

