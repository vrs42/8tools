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
void P00002() { lac &= (010000|core[000002]);  }
void D00003() { lac &= (010000|core[000003]);  }
void D00004() { lac &= (010000|core[000000]);  }
void I00005() { lac &= (010000|core[000000]);  }
void D00006() { lac &= (010000|core[000002]);  }
void P00007() { lac &= (010000|core[(df<<12)+core[103]]);  }
void D00010() { lac &= (010000|core[000007]);  }
void P00011() { lac &= (010000|core[000000]);  }
void P00012() { lac &= (010000|core[000000]);  }
void P00013() { emul8();  }
void P00014() { core[(df<<12)+core[7]] = lac & 07777; lac &= 010000; code[(df<<12)+core[7]] = &emul8;  }
void D00015() { lac &= (010000|core[000003]);  }
void D00016() { if (++core[(df<<12)+core[17]] == 010000) { core[(df<<12)+core[17]] = 0; npc++; }; code[(df<<12)+core[17]] = &emul8;  }
void D00017() { npc = 000116; inh = 0;  }
void D00020() { npc = 000141; inh = 0;  }
void P00021() { lac &= (010000|core[000000]);  }
void D00022() { lac &= (010000|core[000000]);  }
void D00023() { lac &= (010000|core[000000]);  }
void D00024() { lac &= (010000|core[000000]);  }
void D00025() { lac &= (010000|core[000004]);  }
void P00026() { lac &= (010000|core[(df<<12)+core[0]]);  }
void D00027() { lac &= (010000|core[000000]);  }
void D00030() { lac &= (010000|core[000100]);  }
void D00031() { lac &= (010000|core[000000]);  }
void D00032() { lac &= (010000|core[000057]);  }
void P00033() { lac &= (010000|core[000001]);  }
void P00034() { lac &= (010000|core[000006]);  }
void P00035() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void D00036() { lac += core[000014];  }
void P00037() { lac &= (010000|core[(df<<12)+core[0]]);  }
void L00040() { core[(ib<<12)+core[33]] = 00041; npc = (ib<<12)+core[33]+1; code[(ib<<12)+core[33]] = &emul8; inh = 0;  }
void P00041() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I00042() { lac &= (010000|core[000015]);  }
void I00043() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00044() { npc = (ib<<12)+core[22]; inh = 0;  }
void I00045() { lac += core[000036];  }
void I00046() { core[000165] = lac & 07777; lac &= 010000; code[000165] = &emul8;  }
void L00047() { lac &= 010000; lac |= swr;  }
void I00050() { lac &= (010000|core[000030]);  }
void I00051() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00052() { npc = 000055; inh = 0;  }
void I00053() { core[000164] = 00054; npc = 000164+1; code[000164] = &emul8; inh = 0;  }
void D00054() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void L00055() { lac &= 010000; lac |= swr;  }
void I00056() { lac &= (010000|core[000027]);  }
void D00057() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00060() { npc = 000065; inh = 0;  }
void I00061() { core[000164] = 00062; npc = 000164+1; code[000164] = &emul8; inh = 0;  }
void D00062() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I00063() { lac += core[000021];  }
void I00064() { core[000151] = 00065; npc = 000151+1; code[000151] = &emul8; inh = 0;  }
void L00065() { lac &= 010000; lac |= swr;  }
void I00066() { lac &= (010000|core[000026]);  }
void I00067() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00070() { npc = 000075; inh = 0;  }
void I00071() { core[000164] = 00072; npc = 000164+1; code[000164] = &emul8; inh = 0;  }
void D00072() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I00073() { lac += core[000002];  }
void I00074() { core[000151] = 00075; npc = 000151+1; code[000151] = &emul8; inh = 0;  }
void L00075() { lac &= 010000; lac ^= 07777;  }
void I00076() { lac += core[000002];  }
void D00077() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void D00100() { lac += core[000016];  }
void I00101() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I00102() { lac += core[000017];  }
void I00103() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I00104() { lac += core[000020];  }
void I00105() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I00106() { lac += core[000022];  }
void I00107() { core[(df<<12)+core[17]] = lac & 07777; lac &= 010000; code[(df<<12)+core[17]] = &emul8;  }
void I00110() { lac += core[000022];  }
void L00111() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I00112() { lac += core[000023];  }
void I00113() { lac++;  }
void I00114() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void P00115() { npc = (ib<<12)+core[7]; inh = 0;  }
void L00116() { lac &= 010000; lac |= swr;  }
void I00117() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00120() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00121() { npc = 000132; inh = 0;  }
void I00122() { lac += core[(df<<12)+core[17]];  }
void I00123() { lac ^= 07777; lac++;  }
void I00124() { lac += core[000024];  }
void I00125() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00126() { npc = (ib<<12)+core[27]; inh = 0;  }
void I00127() { lac += core[(df<<12)+core[17]];  }
void I00130() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00131() { npc = (ib<<12)+core[27]; inh = 0;  }
void L00132() { lac &= 010000; lac |= swr;  }
void I00133() { lac &= (010000|core[000025]);  }
void I00134() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00135() { npc = 000047; inh = 0;  }
void I00136() { lac++;  }
void I00137() { lac += core[000023];  }
void I00140() { npc = 000111; inh = 0;  }
void L00141() { lac &= 010000; lac |= swr;  }
void I00142() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00143() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void P00144() { npc = 000047; inh = 0;  }
void I00145() { lac += core[(df<<12)+core[17]];  }
void I00146() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void P00147() { npc = (ib<<12)+core[28]; inh = 0;  }
void I00150() { npc = 000047; inh = 0;  }
void S00151() { lac &= (010000|core[000000]);  }
void I00152() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00153() { npc = 000160; inh = 0;  }
void I00154() { lac += core[000003];  }
void I00155() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00156() { npc = (ib<<12)+core[105]; inh = 0;  }
void I00157() { npc = 000165; inh = 0;  }
void L00160() { lac += core[000006];  }
void I00161() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00162() { npc = 000165; inh = 0;  }
void I00163() { npc = (ib<<12)+core[105]; inh = 0;  }
void S00164() { lac &= (010000|core[000000]);  }
void L00165() { lac += core[000014];  }
void I00166() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void P00167() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00170() { lac += core[000015];  }
void I00171() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I00172() { lac += core[000014];  }
void I00173() { npc = (ib<<12)+core[116]; inh = 0;  }
void D00174() { lac += core[000000];  }
void D00175() { lac &= (010000|core[000000]);  }
void I00200() { npc = 000040; inh = 0;  }
void L00201() { lac += core[000340];  }
void I00202() { core[000332] = lac & 07777; lac &= 010000; code[000332] = &emul8;  }
void I00203() { lac ^= 07777;  }
void I00204() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I00205() { npc = 000210; inh = 0;  }
void L00206() { lac += core[000331];  }
void I00207() { core[000332] = lac & 07777; lac &= 010000; code[000332] = &emul8;  }
void L00210() { lac += core[000002];  }
void I00211() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void D00212() { lac += core[000370];  }
void I00213() { core[000342] = 00214; npc = 000342+1; code[000342] = &emul8; inh = 0;  }
void I00214() { lac += core[000021];  }
void D00215() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00216() { lac += core[000371];  }
void I00217() { core[000342] = 00220; npc = 000342+1; code[000342] = &emul8; inh = 0;  }
void I00220() { lac += core[000022];  }
void I00221() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00222() { lac += core[000372];  }
void I00223() { core[000342] = 00224; npc = 000342+1; code[000342] = &emul8; inh = 0;  }
void I00224() { lac += core[000023];  }
void I00225() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00226() { lac += core[000373];  }
void I00227() { core[000342] = 00230; npc = 000342+1; code[000342] = &emul8; inh = 0;  }
void I00230() { lac += core[(df<<12)+core[17]];  }
void I00231() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00232() { lac += core[000374];  }
void I00233() { core[000342] = 00234; npc = 000342+1; code[000342] = &emul8; inh = 0;  }
void I00234() { emul8();  }
void I00235() { lac += core[000032];  }
void I00236() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void L00237() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void D00240() { emul8();  }
void L00241() { emul8();  }
void I00242() { npc = 000241; inh = 0;  }
void I00243() { lac += core[000013];  }
void I00244() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00245() { npc = 000237; inh = 0;  }
void I00246() { emul8();  }
void I00247() { emul8();  }
void I00250() { lac &= 010000; lac |= swr;  }
void I00251() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00252() { hlt = 1;  }
void I00253() { lac += core[000031];  }
void I00254() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00255() { npc = 000047; inh = 0;  }
void I00256() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I00257() { npc = 000132; inh = 0;  }
void D00260() { lac &= (010000|core[000306]);  }
void D00261() { lac &= (010000|core[000240]);  }
void I00262() { lac &= (010000|core[000000]);  }
void I00263() { lac &= (010000|core[000000]);  }
void I00264() { lac &= (010000|core[000000]);  }
void I00265() { lac &= (010000|core[000000]);  }
void I00266() { lac &= (010000|core[000240]);  }
void I00267() { lac &= (010000|core[000240]);  }
void I00270() { lac &= (010000|core[000324]);  }
void D00271() { lac &= (010000|core[000240]);  }
void I00272() { lac &= (010000|core[000000]);  }
void I00273() { lac &= (010000|core[000000]);  }
void I00274() { lac &= (010000|core[000000]);  }
void I00275() { lac &= (010000|core[000000]);  }
void I00276() { lac &= (010000|core[000215]);  }
void I00277() { lac &= (010000|core[000212]);  }
void I00300() { lac &= (010000|core[000215]);  }
void I00301() { lac &= (010000|core[000215]);  }
void I00302() { lac &= (010000|core[000317]);  }
void D00303() { lac &= (010000|core[000240]);  }
void I00304() { lac &= (010000|core[000000]);  }
void I00305() { lac &= (010000|core[000000]);  }
void D00306() { lac &= (010000|core[000000]);  }
void I00307() { lac &= (010000|core[000000]);  }
void I00310() { lac &= (010000|core[000240]);  }
void I00311() { lac &= (010000|core[000240]);  }
void I00312() { lac &= (010000|core[000306]);  }
void D00313() { lac &= (010000|core[000240]);  }
void I00314() { lac &= (010000|core[000000]);  }
void I00315() { lac &= (010000|core[000000]);  }
void D00316() { lac &= (010000|core[000000]);  }
void D00317() { lac &= (010000|core[000000]);  }
void I00320() { lac &= (010000|core[000240]);  }
void I00321() { lac &= (010000|core[000240]);  }
void D00322() { lac &= (010000|core[000322]);  }
void D00323() { lac &= (010000|core[000240]);  }
void D00324() { lac &= (010000|core[000000]);  }
void I00325() { lac &= (010000|core[000000]);  }
void I00326() { lac &= (010000|core[000000]);  }
void I00327() { lac &= (010000|core[000000]);  }
void I00330() { lac &= (010000|core[000240]);  }
void D00331() { lac &= (010000|core[000240]);  }
void D00332() { lac &= (010000|core[000316]);  }
void I00333() { lac &= (010000|core[000323]);  }
void I00334() { lac &= (010000|core[000215]);  }
void I00335() { lac &= (010000|core[000212]);  }
void I00336() { lac &= (010000|core[000212]);  }
void I00337() { lac &= (010000|core[000377]);  }
void D00340() { lac &= (010000|core[000316]);  }
void I00341() { lac &= (010000|core[000323]);  }
void S00342() { lac &= (010000|core[000000]);  }
void I00343() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I00344() { lac += core[000011];  }
void I00345() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00346() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00347() { core[000362] = 00350; npc = 000362+1; code[000362] = &emul8; inh = 0;  }
void I00350() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00351() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00352() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00353() { core[000362] = 00354; npc = 000362+1; code[000362] = &emul8; inh = 0;  }
void I00354() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00355() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00356() { core[000362] = 00357; npc = 000362+1; code[000362] = &emul8; inh = 0;  }
void I00357() { core[000362] = 00360; npc = 000362+1; code[000362] = &emul8; inh = 0;  }
void I00360() { lac &= 010000;  }
void I00361() { npc = (ib<<12)+core[226]; inh = 0;  }
void S00362() { lac &= (010000|core[000000]);  }
void I00363() { lac &= (010000|core[000010]);  }
void I00364() { lac += core[000375];  }
void I00365() { if (++core[000012] == 010000) core[000012] = 0000;core[(df<<12)+core[000012]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000012]] = &emul8;  }
void I00366() { lac += core[000011];  }
void I00367() { npc = (ib<<12)+core[242]; inh = 0;  }
void D00370() { lac &= (010000|core[000261]);  }
void D00371() { lac &= (010000|core[000271]);  }
void D00372() { lac &= (010000|core[000303]);  }
void D00373() { lac &= (010000|core[000313]);  }
void D00374() { lac &= (010000|core[000323]);  }
void D00375() { lac &= (010000|core[000260]);  }
void L00400() { lac += core[000003];  }
void I00401() { lac ^= 07777; lac++;  }
void I00402() { core[000510] = lac & 07777; lac &= 010000; code[000510] = &emul8;  }
void I00403() { lac += core[000003];  }
void I00404() { lac ^= 07777;  }
void I00405() { core[000511] = lac & 07777; lac &= 010000; code[000511] = &emul8;  }
void I00406() { lac += core[000546];  }
void I00407() { core[000513] = lac & 07777; lac &= 010000; code[000513] = &emul8;  }
void I00410() { lac += core[000514];  }
void I00411() { core[000165] = lac & 07777; lac &= 010000; code[000165] = &emul8;  }
void D00412() { npc = 000047; inh = 0;  }
void L00413() { lac += core[000164];  }
void I00414() { lac ^= 07777; lac++;  }
void D00415() { lac += core[000505];  }
void I00416() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00417() { npc = 000503; inh = 0;  }
void I00420() { lac += core[000164];  }
void I00421() { lac ^= 07777; lac++;  }
void I00422() { lac += core[000506];  }
void I00423() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00424() { npc = 000501; inh = 0;  }
void I00425() { npc = 000426; inh = 0;  }
void L00426() { lac += core[(df<<12)+core[331]];  }
void I00427() { core[000512] = lac & 07777; lac &= 010000; code[000512] = &emul8;  }
void I00430() { lac += core[000512];  }
void I00431() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00432() { npc = 000440; inh = 0;  }
void I00433() { lac &= 010000; lac++;  }
void I00434() { lac += core[000513];  }
void I00435() { core[000513] = lac & 07777; lac &= 010000; code[000513] = &emul8;  }
void I00436() { lac += core[000512];  }
void I00437() { npc = (ib<<12)+core[116]; inh = 0;  }
void L00440() { lac += core[000545];  }
void I00441() { core[000513] = lac & 07777; lac &= 010000; code[000513] = &emul8;  }
void I00442() { lac++;  }
void I00443() { lac += core[000511];  }
void I00444() { core[000511] = lac & 07777; lac &= 010000; code[000511] = &emul8;  }
void I00445() { lac += core[000511];  }
void I00446() { lac ^= 07777; lac++;  }
void I00447() { lac += core[000510];  }
void I00450() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00451() { npc = 000455; inh = 0;  }
void I00452() { lac += core[000511];  }
void I00453() { lac += core[000015];  }
void I00454() { core[000511] = lac & 07777; lac &= 010000; code[000511] = &emul8;  }
void L00455() { lac += core[000511];  }
void I00456() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I00457() { npc = 000476; inh = 0;  }
void I00460() { lac += core[000006];  }
void I00461() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00462() { npc = 000476; inh = 0;  }
void I00463() { lac &= 010000; lac++;  }
void I00464() { lac += core[000510];  }
void I00465() { core[000510] = lac & 07777; lac &= 010000; code[000510] = &emul8;  }
void I00466() { lac += core[000003];  }
void I00467() { lac ^= 07777; lac++;  }
void I00470() { core[000511] = lac & 07777; lac &= 010000; code[000511] = &emul8;  }
void I00471() { lac += core[000510];  }
void I00472() { lac += core[000006];  }
void I00473() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00474() { npc = 000476; inh = 0;  }
void I00475() { npc = 000400; inh = 0;  }
void L00476() { lac &= 010000;  }
void I00477() { lac += core[000512];  }
void I00500() { npc = (ib<<12)+core[116]; inh = 0;  }
void L00501() { lac += core[000511];  }
void I00502() { npc = (ib<<12)+core[116]; inh = 0;  }
void L00503() { lac += core[000510];  }
void I00504() { npc = (ib<<12)+core[116]; inh = 0;  }
void D00505() { lac &= (010000|core[000072]);  }
void D00506() { lac &= (010000|core[000062]);  }
void I00507() { lac &= (010000|core[000054]);  }
void D00510() { lac &= (010000|core[000000]);  }
void D00511() { lac &= (010000|core[000000]);  }
void D00512() { lac &= (010000|core[000000]);  }
void P00513() { lac &= (010000|core[000000]);  }
void D00514() { npc = (ib<<12)+core[29]; inh = 0;  }
void I00515() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I00516() { emul8();  }
void I00517() { emul8();  }
void I00520() { emul8();  }
void I00521() { emul8();  }
void I00522() { emul8();  }
void I00523() { emul8();  }
void I00524() { emul8();  }
void I00525() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00526() { emul8();  }
void I00527() { npc = (ib<<12)+core[383]; inh = 0;  }
void I00530() { core[(df<<12)+core[383]] = lac & 07777; lac &= 010000; code[(df<<12)+core[383]] = &emul8;  }
void I00531() { lac &= (010000|core[000001]);  }
void I00532() { lac &= (010000|core[000003]);  }
void I00533() { lac &= (010000|core[000007]);  }
void I00534() { lac &= (010000|core[000017]);  }
void I00535() { lac &= (010000|core[000037]);  }
void I00536() { lac &= (010000|core[000077]);  }
void I00537() { lac &= (010000|core[000177]);  }
void I00540() { lac &= (010000|core[000577]);  }
void I00541() { lac &= (010000|core[(df<<12)+core[383]]);  }
void I00542() { lac += core[(df<<12)+core[383]];  }
void I00543() { core[(df<<12)+core[383]] = lac & 07777; lac &= 010000; code[(df<<12)+core[383]] = &emul8;  }
void I00544() { lac &= (010000|core[000000]);  }
void D00545() { lac &= (010000|core[(df<<12)+core[77]]);  }
void D00546() { lac &= (010000|core[(df<<12)+core[100]]);  }
void L00547() { lac += core[000575];  }
void I00550() { lac++;  }
void I00551() { core[000575] = lac & 07777; lac &= 010000; code[000575] = &emul8;  }
void I00552() { lac += core[000575];  }
void I00553() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00554() { npc = (ib<<12)+core[31]; inh = 0;  }
void I00555() { lac += core[000175];  }
void I00556() { lac += core[000174];  }
void I00557() { core[000175] = lac & 07777; lac &= 010000; code[000175] = &emul8;  }
void I00560() { lac += core[000175];  }
void I00561() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00562() { npc = (ib<<12)+core[31]; inh = 0;  }
void I00563() { emul8();  }
void I00564() { lac += core[000576];  }
void I00565() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00566() { npc = (ib<<12)+core[375]; inh = 0;  }
void P00567() { lac &= 010000; hlt = 1;  }
void I00570() { lac &= (010000|core[000415]);  }
void I00571() { lac &= (010000|core[000412]);  }
void I00572() { lac &= (010000|core[000506]);  }
void I00573() { lac &= (010000|core[000503]);  }
void I00574() { lac &= (010000|core[000577]);  }
void D00575() { lac &= (010000|core[000000]);  }
void D00576() { lac &= (010000|core[(df<<12)+core[119]]);  }
void L00600() { lac += core[000021];  }
void I00601() { lac ^= 07777; lac++;  }
void I00602() { lac += core[000002];  }
void I00603() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00604() { npc = 000055; inh = 0;  }
void I00605() { lac++;  }
void I00606() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00607() { npc = 000055; inh = 0;  }
void I00610() { lac++;  }
void I00611() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00612() { npc = 000055; inh = 0;  }
void I00613() { npc = (ib<<12)+core[2]; inh = 0;  }
void S00614() { lac &= (010000|core[000000]);  }
void I00615() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00616() { lac += core[000632];  }
void I00617() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I00620() { lac += core[000633];  }
void I00621() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I00622() { lac += core[000634];  }
void I00623() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I00624() { lac += core[000635];  }
void I00625() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I00626() { lac += core[000636];  }
void I00627() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I00630() { emul8();  }
void I00631() { npc = (ib<<12)+core[396]; inh = 0;  }
void D00632() { hlt = 1;  }
void D00633() { lac &= (010000|core[000000]);  }
void D00634() { lac &= 07777; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D00635() { emul8();  }
void D00636() { lac &= 010000; lac |= swr;  }
void L07602() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I07603() { emul8();  }
void L07604() { emul8();  }
void I07605() { npc = 007604; inh = 0;  }
void I07606() { lac += core[000013];  }
void I07607() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07610() { npc = 007602; inh = 0;  }
void I07611() { npc = 007617; inh = 0;  }
void L07617() { emul8();  }
void I07620() { emul8();  }
void I07621() { npc = (ib<<12)+core[31]; inh = 0;  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &L00001;
  core[000002] = 00002; code[000002] = &P00002;
  core[000003] = 00003; code[000003] = &D00003;
  core[000004] = 00000; code[000004] = &D00004;
  core[000005] = 00000; code[000005] = &I00005;
  core[000006] = 00202; code[000006] = &D00006;
  core[000007] = 00547; code[000007] = &P00007;
  core[000010] = 00007; code[000010] = &D00010;
  core[000011] = 00000; code[000011] = &P00011;
  core[000012] = 00000; code[000012] = &P00012;
  core[000013] = 07401; code[000013] = &P00013;
  core[000014] = 03607; code[000014] = &P00014;
  core[000015] = 00003; code[000015] = &D00015;
  core[000016] = 02421; code[000016] = &D00016;
  core[000017] = 05116; code[000017] = &D00017;
  core[000020] = 05141; code[000020] = &D00020;
  core[000021] = 00000; code[000021] = &P00021;
  core[000022] = 00000; code[000022] = &D00022;
  core[000023] = 00000; code[000023] = &D00023;
  core[000024] = 00000; code[000024] = &D00024;
  core[000025] = 00004; code[000025] = &D00025;
  core[000026] = 00400; code[000026] = &P00026;
  core[000027] = 00200; code[000027] = &D00027;
  core[000030] = 00100; code[000030] = &D00030;
  core[000031] = 00000; code[000031] = &D00031;
  core[000032] = 00257; code[000032] = &D00032;
  core[000033] = 00201; code[000033] = &P00033;
  core[000034] = 00206; code[000034] = &P00034;
  core[000035] = 00413; code[000035] = &P00035;
  core[000036] = 01014; code[000036] = &D00036;
  core[000037] = 00600; code[000037] = &P00037;
  core[000040] = 04441; code[000040] = &L00040;
  core[000041] = 00614; code[000041] = &P00041;
  core[000042] = 00015; code[000042] = &I00042;
  core[000043] = 07640; code[000043] = &I00043;
  core[000044] = 05426; code[000044] = &I00044;
  core[000045] = 01036; code[000045] = &I00045;
  core[000046] = 03165; code[000046] = &I00046;
  core[000047] = 07604; code[000047] = &L00047;
  core[000050] = 00030; code[000050] = &I00050;
  core[000051] = 07440; code[000051] = &I00051;
  core[000052] = 05055; code[000052] = &I00052;
  core[000053] = 04164; code[000053] = &I00053;
  core[000054] = 03022; code[000054] = &D00054;
  core[000055] = 07604; code[000055] = &L00055;
  core[000056] = 00027; code[000056] = &I00056;
  core[000057] = 07640; code[000057] = &D00057;
  core[000060] = 05065; code[000060] = &I00060;
  core[000061] = 04164; code[000061] = &I00061;
  core[000062] = 03021; code[000062] = &D00062;
  core[000063] = 01021; code[000063] = &I00063;
  core[000064] = 04151; code[000064] = &I00064;
  core[000065] = 07604; code[000065] = &L00065;
  core[000066] = 00026; code[000066] = &I00066;
  core[000067] = 07640; code[000067] = &I00067;
  core[000070] = 05075; code[000070] = &I00070;
  core[000071] = 04164; code[000071] = &I00071;
  core[000072] = 03002; code[000072] = &D00072;
  core[000073] = 01002; code[000073] = &I00073;
  core[000074] = 04151; code[000074] = &I00074;
  core[000075] = 07240; code[000075] = &L00075;
  core[000076] = 01002; code[000076] = &I00076;
  core[000077] = 03011; code[000077] = &D00077;
  core[000100] = 01016; code[000100] = &D00100;
  core[000101] = 03411; code[000101] = &I00101;
  core[000102] = 01017; code[000102] = &I00102;
  core[000103] = 03411; code[000103] = &I00103;
  core[000104] = 01020; code[000104] = &I00104;
  core[000105] = 03411; code[000105] = &I00105;
  core[000106] = 01022; code[000106] = &I00106;
  core[000107] = 03421; code[000107] = &I00107;
  core[000110] = 01022; code[000110] = &I00110;
  core[000111] = 03023; code[000111] = &L00111;
  core[000112] = 01023; code[000112] = &I00112;
  core[000113] = 07001; code[000113] = &I00113;
  core[000114] = 03024; code[000114] = &I00114;
  core[000115] = 05407; code[000115] = &P00115;
  core[000116] = 07604; code[000116] = &L00116;
  core[000117] = 07004; code[000117] = &I00117;
  core[000120] = 07710; code[000120] = &I00120;
  core[000121] = 05132; code[000121] = &I00121;
  core[000122] = 01421; code[000122] = &I00122;
  core[000123] = 07041; code[000123] = &I00123;
  core[000124] = 01024; code[000124] = &I00124;
  core[000125] = 07640; code[000125] = &I00125;
  core[000126] = 05433; code[000126] = &I00126;
  core[000127] = 01421; code[000127] = &I00127;
  core[000130] = 07650; code[000130] = &I00130;
  core[000131] = 05433; code[000131] = &I00131;
  core[000132] = 07604; code[000132] = &L00132;
  core[000133] = 00025; code[000133] = &I00133;
  core[000134] = 07650; code[000134] = &I00134;
  core[000135] = 05047; code[000135] = &I00135;
  core[000136] = 07001; code[000136] = &I00136;
  core[000137] = 01023; code[000137] = &I00137;
  core[000140] = 05111; code[000140] = &I00140;
  core[000141] = 07604; code[000141] = &L00141;
  core[000142] = 07004; code[000142] = &I00142;
  core[000143] = 07710; code[000143] = &I00143;
  core[000144] = 05047; code[000144] = &P00144;
  core[000145] = 01421; code[000145] = &I00145;
  core[000146] = 07640; code[000146] = &I00146;
  core[000147] = 05434; code[000147] = &P00147;
  core[000150] = 05047; code[000150] = &I00150;
  core[000151] = 00000; code[000151] = &S00151;
  core[000152] = 07510; code[000152] = &I00152;
  core[000153] = 05160; code[000153] = &I00153;
  core[000154] = 01003; code[000154] = &I00154;
  core[000155] = 07700; code[000155] = &I00155;
  core[000156] = 05551; code[000156] = &I00156;
  core[000157] = 05165; code[000157] = &I00157;
  core[000160] = 01006; code[000160] = &L00160;
  core[000161] = 07700; code[000161] = &I00161;
  core[000162] = 05165; code[000162] = &I00162;
  core[000163] = 05551; code[000163] = &I00163;
  core[000164] = 00000; code[000164] = &S00164;
  core[000165] = 01014; code[000165] = &L00165;
  core[000166] = 07104; code[000166] = &I00166;
  core[000167] = 07430; code[000167] = &P00167;
  core[000170] = 01015; code[000170] = &I00170;
  core[000171] = 03014; code[000171] = &I00171;
  core[000172] = 01014; code[000172] = &I00172;
  core[000173] = 05564; code[000173] = &I00173;
  core[000174] = 01000; code[000174] = &D00174;
  core[000175] = 00000; code[000175] = &D00175;
  core[000200] = 05040; code[000200] = &I00200;
  core[000201] = 01340; code[000201] = &L00201;
  core[000202] = 03332; code[000202] = &I00202;
  core[000203] = 07040; code[000203] = &I00203;
  core[000204] = 03031; code[000204] = &I00204;
  core[000205] = 05210; code[000205] = &I00205;
  core[000206] = 01331; code[000206] = &L00206;
  core[000207] = 03332; code[000207] = &I00207;
  core[000210] = 01002; code[000210] = &L00210;
  core[000211] = 03011; code[000211] = &I00211;
  core[000212] = 01370; code[000212] = &D00212;
  core[000213] = 04342; code[000213] = &I00213;
  core[000214] = 01021; code[000214] = &I00214;
  core[000215] = 03011; code[000215] = &D00215;
  core[000216] = 01371; code[000216] = &I00216;
  core[000217] = 04342; code[000217] = &I00217;
  core[000220] = 01022; code[000220] = &I00220;
  core[000221] = 03011; code[000221] = &I00221;
  core[000222] = 01372; code[000222] = &I00222;
  core[000223] = 04342; code[000223] = &I00223;
  core[000224] = 01023; code[000224] = &I00224;
  core[000225] = 03011; code[000225] = &I00225;
  core[000226] = 01373; code[000226] = &I00226;
  core[000227] = 04342; code[000227] = &I00227;
  core[000230] = 01421; code[000230] = &I00230;
  core[000231] = 03011; code[000231] = &I00231;
  core[000232] = 01374; code[000232] = &I00232;
  core[000233] = 04342; code[000233] = &I00233;
  core[000234] = 06002; code[000234] = &I00234;
  core[000235] = 01032; code[000235] = &I00235;
  core[000236] = 03011; code[000236] = &I00236;
  core[000237] = 01411; code[000237] = &L00237;
  core[000240] = 06046; code[000240] = &D00240;
  core[000241] = 06041; code[000241] = &L00241;
  core[000242] = 05241; code[000242] = &I00242;
  core[000243] = 01013; code[000243] = &I00243;
  core[000244] = 07640; code[000244] = &I00244;
  core[000245] = 05237; code[000245] = &I00245;
  core[000246] = 06042; code[000246] = &I00246;
  core[000247] = 06001; code[000247] = &I00247;
  core[000250] = 07604; code[000250] = &I00250;
  core[000251] = 07700; code[000251] = &I00251;
  core[000252] = 07402; code[000252] = &I00252;
  core[000253] = 01031; code[000253] = &I00253;
  core[000254] = 07650; code[000254] = &I00254;
  core[000255] = 05047; code[000255] = &I00255;
  core[000256] = 03031; code[000256] = &I00256;
  core[000257] = 05132; code[000257] = &I00257;
  core[000260] = 00306; code[000260] = &D00260;
  core[000261] = 00240; code[000261] = &D00261;
  core[000262] = 00000; code[000262] = &I00262;
  core[000263] = 00000; code[000263] = &I00263;
  core[000264] = 00000; code[000264] = &I00264;
  core[000265] = 00000; code[000265] = &I00265;
  core[000266] = 00240; code[000266] = &I00266;
  core[000267] = 00240; code[000267] = &I00267;
  core[000270] = 00324; code[000270] = &I00270;
  core[000271] = 00240; code[000271] = &D00271;
  core[000272] = 00000; code[000272] = &I00272;
  core[000273] = 00000; code[000273] = &I00273;
  core[000274] = 00000; code[000274] = &I00274;
  core[000275] = 00000; code[000275] = &I00275;
  core[000276] = 00215; code[000276] = &I00276;
  core[000277] = 00212; code[000277] = &I00277;
  core[000300] = 00215; code[000300] = &I00300;
  core[000301] = 00215; code[000301] = &I00301;
  core[000302] = 00317; code[000302] = &I00302;
  core[000303] = 00240; code[000303] = &D00303;
  core[000304] = 00000; code[000304] = &I00304;
  core[000305] = 00000; code[000305] = &I00305;
  core[000306] = 00000; code[000306] = &D00306;
  core[000307] = 00000; code[000307] = &I00307;
  core[000310] = 00240; code[000310] = &I00310;
  core[000311] = 00240; code[000311] = &I00311;
  core[000312] = 00306; code[000312] = &I00312;
  core[000313] = 00240; code[000313] = &D00313;
  core[000314] = 00000; code[000314] = &I00314;
  core[000315] = 00000; code[000315] = &I00315;
  core[000316] = 00000; code[000316] = &D00316;
  core[000317] = 00000; code[000317] = &D00317;
  core[000320] = 00240; code[000320] = &I00320;
  core[000321] = 00240; code[000321] = &I00321;
  core[000322] = 00322; code[000322] = &D00322;
  core[000323] = 00240; code[000323] = &D00323;
  core[000324] = 00000; code[000324] = &D00324;
  core[000325] = 00000; code[000325] = &I00325;
  core[000326] = 00000; code[000326] = &I00326;
  core[000327] = 00000; code[000327] = &I00327;
  core[000330] = 00240; code[000330] = &I00330;
  core[000331] = 00240; code[000331] = &D00331;
  core[000332] = 00316; code[000332] = &D00332;
  core[000333] = 00323; code[000333] = &I00333;
  core[000334] = 00215; code[000334] = &I00334;
  core[000335] = 00212; code[000335] = &I00335;
  core[000336] = 00212; code[000336] = &I00336;
  core[000337] = 00377; code[000337] = &I00337;
  core[000340] = 00316; code[000340] = &D00340;
  core[000341] = 00323; code[000341] = &I00341;
  core[000342] = 00000; code[000342] = &S00342;
  core[000343] = 03012; code[000343] = &I00343;
  core[000344] = 01011; code[000344] = &I00344;
  core[000345] = 07006; code[000345] = &I00345;
  core[000346] = 07006; code[000346] = &I00346;
  core[000347] = 04362; code[000347] = &I00347;
  core[000350] = 07012; code[000350] = &I00350;
  core[000351] = 07012; code[000351] = &I00351;
  core[000352] = 07012; code[000352] = &I00352;
  core[000353] = 04362; code[000353] = &I00353;
  core[000354] = 07012; code[000354] = &I00354;
  core[000355] = 07010; code[000355] = &I00355;
  core[000356] = 04362; code[000356] = &I00356;
  core[000357] = 04362; code[000357] = &I00357;
  core[000360] = 07200; code[000360] = &I00360;
  core[000361] = 05742; code[000361] = &I00361;
  core[000362] = 00000; code[000362] = &S00362;
  core[000363] = 00010; code[000363] = &I00363;
  core[000364] = 01375; code[000364] = &I00364;
  core[000365] = 03412; code[000365] = &I00365;
  core[000366] = 01011; code[000366] = &I00366;
  core[000367] = 05762; code[000367] = &I00367;
  core[000370] = 00261; code[000370] = &D00370;
  core[000371] = 00271; code[000371] = &D00371;
  core[000372] = 00303; code[000372] = &D00372;
  core[000373] = 00313; code[000373] = &D00373;
  core[000374] = 00323; code[000374] = &D00374;
  core[000375] = 00260; code[000375] = &D00375;
  core[000400] = 01003; code[000400] = &L00400;
  core[000401] = 07041; code[000401] = &I00401;
  core[000402] = 03310; code[000402] = &I00402;
  core[000403] = 01003; code[000403] = &I00403;
  core[000404] = 07040; code[000404] = &I00404;
  core[000405] = 03311; code[000405] = &I00405;
  core[000406] = 01346; code[000406] = &I00406;
  core[000407] = 03313; code[000407] = &I00407;
  core[000410] = 01314; code[000410] = &I00410;
  core[000411] = 03165; code[000411] = &I00411;
  core[000412] = 05047; code[000412] = &D00412;
  core[000413] = 01164; code[000413] = &L00413;
  core[000414] = 07041; code[000414] = &I00414;
  core[000415] = 01305; code[000415] = &D00415;
  core[000416] = 07650; code[000416] = &I00416;
  core[000417] = 05303; code[000417] = &I00417;
  core[000420] = 01164; code[000420] = &I00420;
  core[000421] = 07041; code[000421] = &I00421;
  core[000422] = 01306; code[000422] = &I00422;
  core[000423] = 07650; code[000423] = &I00423;
  core[000424] = 05301; code[000424] = &I00424;
  core[000425] = 05226; code[000425] = &I00425;
  core[000426] = 01713; code[000426] = &L00426;
  core[000427] = 03312; code[000427] = &I00427;
  core[000430] = 01312; code[000430] = &I00430;
  core[000431] = 07450; code[000431] = &I00431;
  core[000432] = 05240; code[000432] = &I00432;
  core[000433] = 07201; code[000433] = &I00433;
  core[000434] = 01313; code[000434] = &I00434;
  core[000435] = 03313; code[000435] = &I00435;
  core[000436] = 01312; code[000436] = &I00436;
  core[000437] = 05564; code[000437] = &I00437;
  core[000440] = 01345; code[000440] = &L00440;
  core[000441] = 03313; code[000441] = &I00441;
  core[000442] = 07001; code[000442] = &I00442;
  core[000443] = 01311; code[000443] = &I00443;
  core[000444] = 03311; code[000444] = &I00444;
  core[000445] = 01311; code[000445] = &I00445;
  core[000446] = 07041; code[000446] = &I00446;
  core[000447] = 01310; code[000447] = &I00447;
  core[000450] = 07640; code[000450] = &I00450;
  core[000451] = 05255; code[000451] = &I00451;
  core[000452] = 01311; code[000452] = &I00452;
  core[000453] = 01015; code[000453] = &I00453;
  core[000454] = 03311; code[000454] = &I00454;
  core[000455] = 01311; code[000455] = &L00455;
  core[000456] = 07500; code[000456] = &I00456;
  core[000457] = 05276; code[000457] = &I00457;
  core[000460] = 01006; code[000460] = &I00460;
  core[000461] = 07710; code[000461] = &I00461;
  core[000462] = 05276; code[000462] = &I00462;
  core[000463] = 07201; code[000463] = &I00463;
  core[000464] = 01310; code[000464] = &I00464;
  core[000465] = 03310; code[000465] = &I00465;
  core[000466] = 01003; code[000466] = &I00466;
  core[000467] = 07041; code[000467] = &I00467;
  core[000470] = 03311; code[000470] = &I00470;
  core[000471] = 01310; code[000471] = &I00471;
  core[000472] = 01006; code[000472] = &I00472;
  core[000473] = 07710; code[000473] = &I00473;
  core[000474] = 05276; code[000474] = &I00474;
  core[000475] = 05200; code[000475] = &I00475;
  core[000476] = 07200; code[000476] = &L00476;
  core[000477] = 01312; code[000477] = &I00477;
  core[000500] = 05564; code[000500] = &I00500;
  core[000501] = 01311; code[000501] = &L00501;
  core[000502] = 05564; code[000502] = &I00502;
  core[000503] = 01310; code[000503] = &L00503;
  core[000504] = 05564; code[000504] = &I00504;
  core[000505] = 00072; code[000505] = &D00505;
  core[000506] = 00062; code[000506] = &D00506;
  core[000507] = 00054; code[000507] = &I00507;
  core[000510] = 00000; code[000510] = &D00510;
  core[000511] = 00000; code[000511] = &D00511;
  core[000512] = 00000; code[000512] = &D00512;
  core[000513] = 00000; code[000513] = &P00513;
  core[000514] = 05435; code[000514] = &D00514;
  core[000515] = 07776; code[000515] = &I00515;
  core[000516] = 07775; code[000516] = &I00516;
  core[000517] = 07773; code[000517] = &I00517;
  core[000520] = 07767; code[000520] = &I00520;
  core[000521] = 07757; code[000521] = &I00521;
  core[000522] = 07737; code[000522] = &I00522;
  core[000523] = 07677; code[000523] = &I00523;
  core[000524] = 07577; code[000524] = &I00524;
  core[000525] = 07377; code[000525] = &I00525;
  core[000526] = 06777; code[000526] = &I00526;
  core[000527] = 05777; code[000527] = &I00527;
  core[000530] = 03777; code[000530] = &I00530;
  core[000531] = 00001; code[000531] = &I00531;
  core[000532] = 00003; code[000532] = &I00532;
  core[000533] = 00007; code[000533] = &I00533;
  core[000534] = 00017; code[000534] = &I00534;
  core[000535] = 00037; code[000535] = &I00535;
  core[000536] = 00077; code[000536] = &I00536;
  core[000537] = 00177; code[000537] = &I00537;
  core[000540] = 00377; code[000540] = &I00540;
  core[000541] = 00777; code[000541] = &I00541;
  core[000542] = 01777; code[000542] = &I00542;
  core[000543] = 03777; code[000543] = &I00543;
  core[000544] = 00000; code[000544] = &I00544;
  core[000545] = 00515; code[000545] = &D00545;
  core[000546] = 00544; code[000546] = &D00546;
  core[000547] = 01375; code[000547] = &L00547;
  core[000550] = 07001; code[000550] = &I00550;
  core[000551] = 03375; code[000551] = &I00551;
  core[000552] = 01375; code[000552] = &I00552;
  core[000553] = 07640; code[000553] = &I00553;
  core[000554] = 05437; code[000554] = &I00554;
  core[000555] = 01175; code[000555] = &I00555;
  core[000556] = 01174; code[000556] = &I00556;
  core[000557] = 03175; code[000557] = &I00557;
  core[000560] = 01175; code[000560] = &I00560;
  core[000561] = 07640; code[000561] = &I00561;
  core[000562] = 05437; code[000562] = &I00562;
  core[000563] = 06002; code[000563] = &I00563;
  core[000564] = 01376; code[000564] = &I00564;
  core[000565] = 03011; code[000565] = &I00565;
  core[000566] = 05767; code[000566] = &I00566;
  core[000567] = 07602; code[000567] = &P00567;
  core[000570] = 00215; code[000570] = &I00570;
  core[000571] = 00212; code[000571] = &I00571;
  core[000572] = 00306; code[000572] = &I00572;
  core[000573] = 00303; code[000573] = &I00573;
  core[000574] = 00377; code[000574] = &I00574;
  core[000575] = 00000; code[000575] = &D00575;
  core[000576] = 00567; code[000576] = &D00576;
  core[000600] = 01021; code[000600] = &L00600;
  core[000601] = 07041; code[000601] = &I00601;
  core[000602] = 01002; code[000602] = &I00602;
  core[000603] = 07450; code[000603] = &I00603;
  core[000604] = 05055; code[000604] = &I00604;
  core[000605] = 07001; code[000605] = &I00605;
  core[000606] = 07450; code[000606] = &I00606;
  core[000607] = 05055; code[000607] = &I00607;
  core[000610] = 07001; code[000610] = &I00610;
  core[000611] = 07650; code[000611] = &I00611;
  core[000612] = 05055; code[000612] = &I00612;
  core[000613] = 05402; code[000613] = &I00613;
  core[000614] = 00000; code[000614] = &S00614;
  core[000615] = 03000; code[000615] = &I00615;
  core[000616] = 01232; code[000616] = &I00616;
  core[000617] = 03001; code[000617] = &I00617;
  core[000620] = 01233; code[000620] = &I00620;
  core[000621] = 03002; code[000621] = &I00621;
  core[000622] = 01234; code[000622] = &I00622;
  core[000623] = 03003; code[000623] = &I00623;
  core[000624] = 01235; code[000624] = &I00624;
  core[000625] = 03040; code[000625] = &I00625;
  core[000626] = 01236; code[000626] = &I00626;
  core[000627] = 03041; code[000627] = &I00627;
  core[000630] = 06001; code[000630] = &I00630;
  core[000631] = 05614; code[000631] = &I00631;
  core[000632] = 07402; code[000632] = &D00632;
  core[000633] = 00000; code[000633] = &D00633;
  core[000634] = 07157; code[000634] = &D00634;
  core[000635] = 06001; code[000635] = &D00635;
  core[000636] = 07604; code[000636] = &D00636;
  core[007602] = 01411; code[007602] = &L07602;
  core[007603] = 06046; code[007603] = &I07603;
  core[007604] = 06041; code[007604] = &L07604;
  core[007605] = 05204; code[007605] = &I07605;
  core[007606] = 01013; code[007606] = &I07606;
  core[007607] = 07640; code[007607] = &I07607;
  core[007610] = 05202; code[007610] = &I07610;
  core[007611] = 05217; code[007611] = &I07611;
  core[007617] = 06042; code[007617] = &L07617;
  core[007620] = 06001; code[007620] = &I07620;
  core[007621] = 05437; code[007621] = &I07621;
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

