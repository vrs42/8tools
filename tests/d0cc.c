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
void P00001() { npc = 000001; inh = 0;  }
void S00002() { lac &= (010000|core[000002]);  }
void P00003() { lac &= (010000|core[000003]);  }
void S00004() { lac &= (010000|core[000000]);  }
void P00010() { lac &= (010000|core[000000]);  }
void P00011() { lac &= (010000|core[000000]);  }
void P00012() { lac &= (010000|core[000000]);  }
void P00020() { lac &= (010000|core[000000]);  }
void P00021() { lac &= (010000|core[000022]);  }
void P00022() { emul8();  }
void D00023() { lac &= (010000|core[000000]);  }
void P00024() { lac &= (010000|core[000000]);  }
void P00025() { lac &= (010000|core[000000]);  }
void L00026() { lac &= (010000|core[000000]);  }
void D00027() { lac &= (010000|core[000000]);  }
void P00030() { lac &= (010000|core[000000]);  }
void D00031() { lac &= (010000|core[000000]);  }
void D00032() { lac &= (010000|core[000000]);  }
void D00033() { lac &= (010000|core[000000]);  }
void P00034() { lac &= (010000|core[000000]);  }
void D00035() { lac &= (010000|core[000000]);  }
void P00036() { lac &= (010000|core[000000]);  }
void P00037() { lac &= (010000|core[000000]);  }
void S00040() { lac &= (010000|core[000000]);  }
void L00041() { lac &= (010000|core[000037]);  }
void I00042() { lac &= (010000|core[000000]);  }
void D00043() { lac &= (010000|core[000000]);  }
void D00044() { lac &= (010000|core[000000]);  }
void D00045() { lac &= (010000|core[000000]);  }
void P00046() { lac += core[(df<<12)+core[0]];  }
void P00047() { lac += core[(df<<12)+core[42]];  }
void P00050() { lac += core[000133];  }
void P00051() { lac += core[000000];  }
void P00052() { lac &= (010000|core[(df<<12)+core[110]]);  }
void D00053() { lac += core[000157];  }
void D00054() { lac += core[000140];  }
void P00055() { lac += core[(df<<12)+core[47]];  }
void P00056() { lac += core[000000];  }
void P00057() { lac += core[000031];  }
void P00060() { lac &= (010000|core[(df<<12)+core[68]]);  }
void P00061() { lac &= (010000|core[(df<<12)+core[83]]);  }
void P00062() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void P00063() { core[(df<<12)+core[88]] = lac & 07777; lac &= 010000; code[(df<<12)+core[88]] = &emul8;  }
void P00064() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void P00065() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void P00066() { core[000027] = lac & 07777; lac &= 010000; code[000027] = &emul8;  }
void P00067() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void D00070() { emul8();  }
void P00071() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P00072() { emul8();  }
void P00073() { core[(df<<12)+core[74]] = lac & 07777; lac &= 010000; code[(df<<12)+core[74]] = &emul8;  }
void P00074() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void P00075() { lac &= (010000|core[(df<<12)+core[106]]);  }
void D00076() { lac &= (010000|core[000040]);  }
void D00077() { lac &= (010000|core[000060]);  }
void L00100() { lac &= (010000|core[000061]);  }
void P00101() { emul8();  }
void P00102() { lac &= (010000|core[000102]);  }
void D00103() { core[000000] = 00104; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void P00104() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void D00105() { lac += core[000000];  }
void D00106() { lac &= (010000|core[(df<<12)+core[0]]);  }
void P00107() { lac &= (010000|core[000000]);  }
void P00110() { lac &= (010000|core[000100]);  }
void D00111() { lac &= (010000|core[000040]);  }
void P00112() { lac &= (010000|core[000020]);  }
void D00113() { lac &= (010000|core[000010]);  }
void P00114() { lac &= (010000|core[000004]);  }
void P00115() { lac &= (010000|core[000002]);  }
void P00116() { lac &= (010000|core[000001]);  }
void I00117() { lac &= (010000|core[000000]);  }
void I00120() { core[000000] = 00121; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I00121() { lac &= (010000|core[000001]);  }
void P00122() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void P00123() { if (++core[000043] == 010000) { core[000043] = 0; npc++; }; code[000043] = &emul8;  }
void D00124() { if (++core[000076] == 010000) { core[000076] = 0; npc++; }; code[000076] = &emul8;  }
void D00125() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void D00126() { if (++core[000032] == 010000) { core[000032] = 0; npc++; }; code[000032] = &emul8;  }
void D00127() { if (++core[000070] == 010000) { core[000070] = 0; npc++; }; code[000070] = &emul8;  }
void P00130() { if (++core[(df<<12)+core[0]] == 010000) { core[(df<<12)+core[0]] = 0; npc++; }; code[(df<<12)+core[0]] = &emul8;  }
void D00131() { if (++core[(df<<12)+core[30]] == 010000) { core[(df<<12)+core[30]] = 0; npc++; }; code[(df<<12)+core[30]] = &emul8;  }
void D00132() { if (++core[(df<<12)+core[58]] == 010000) { core[(df<<12)+core[58]] = 0; npc++; }; code[(df<<12)+core[58]] = &emul8;  }
void D00133() { if (++core[(df<<12)+core[0]] == 010000) { core[(df<<12)+core[0]] = 0; npc++; }; code[(df<<12)+core[0]] = &emul8;  }
void D00134() { if (++core[(df<<12)+core[28]] == 010000) { core[(df<<12)+core[28]] = 0; npc++; }; code[(df<<12)+core[28]] = &emul8;  }
void D00135() { if (++core[(df<<12)+core[55]] == 010000) { core[(df<<12)+core[55]] = 0; npc++; }; code[(df<<12)+core[55]] = &emul8;  }
void D00136() { lac += core[000176];  }
void D00137() { lac++;  }
void P00140() { npc = (ib<<12)+core[4]; inh = 0;  }
void D00141() { npc = (ib<<12)+core[2]; inh = 0;  }
void D00142() { lac ^= 010000; lac ^= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void D00143() { if (++core[000176] == 010000) { core[000176] = 0; npc++; }; code[000176] = &emul8;  }
void P00144() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void D00145() { if (++core[000010] == 010000) core[000010] = 0000;if (++core[(df<<12)+core[000010]] == 010000) { core[(df<<12)+core[000010]] = 0; npc++; }; code[(df<<12)+core[000010]] = &emul8;  }
void D00146() { core[000000] = 00147; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void D00147() { core[(ib<<12)+core[126]] = 00150; npc = (ib<<12)+core[126]+1; code[(ib<<12)+core[126]] = &emul8; inh = 0;  }
void P00150() { if (++core[000010] == 010000) core[000010] = 0000;core[(ib<<12)+core[000010]] = 00151; npc = (ib<<12)+core[000010]+1; code[(ib<<12)+core[000010]] = &emul8; inh = 0;  }
void D00151() { npc = (ib<<12)+core[3]; inh = 0;  }
void P00152() { npc = (ib<<12)+core[1]; inh = 0;  }
void D00153() { core[000177] = 00154; npc = 000177+1; code[000177] = &emul8; inh = 0;  }
void P00154() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void D00155() { npc = 000101; inh = 0;  }
void P00156() { emul8();  }
void D00157() { lac &= 010000; lac |= swr;  }
void I00160() { lac &= (010000|core[000106]);  }
void I00161() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00162() { npc = 000177; inh = 0;  }
void I00163() { lac &= 010000; lac ^= 07777;  }
void I00164() { lac &= (010000|core[000170]);  }
void P00165() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I00166() { npc = (ib<<12)+core[119]; inh = 0;  }
void P00167() { lac &= (010000|core[000002]);  }
void D00170() { lac &= (010000|core[000000]);  }
void P00171() { lac &= (010000|core[000000]);  }
void D00172() { lac &= (010000|core[000007]);  }
void D00173() { lac &= (010000|core[000070]);  }
void D00174() { lac &= (010000|core[000000]);  }
void D00175() { lac &= (010000|core[000000]);  }
void P00176() { lac &= (010000|core[000000]);  }
void L00177() { skp = 0; skp = !skp; npc += skp;  }
void L00200() { npc = 000156; inh = 0;  }
void I00201() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void L00202() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I00203() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void L00204() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00205() { lac &= (010000|core[000023]);  }
void I00206() { emul8();  }
void I00207() { lac ^= 07777;  }
void I00210() { lac &= (010000|core[000024]);  }
void I00211() { emul8();  }
void I00212() { core[000027] = lac & 07777; lac &= 010000; code[000027] = &emul8;  }
void I00213() { emul8();  }
void I00214() { lac ^= 07777;  }
void I00215() { lac &= (010000|core[000024]);  }
void I00216() { emul8();  }
void I00217() { lac ^= 07777;  }
void I00220() { lac &= (010000|core[000024]);  }
void I00221() { lac ^= 07777;  }
void I00222() { lac &= (010000|core[000023]);  }
void I00223() { emul8();  }
void I00224() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I00225() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void I00226() { lac ^= 07777;  }
void I00227() { lac &= (010000|core[000023]);  }
void I00230() { lac &= (010000|core[000024]);  }
void I00231() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00232() { npc = 000274; inh = 0;  }
void I00233() { emul8();  }
void L00234() { emul8();  }
void I00235() { lac &= (010000|core[000027]);  }
void I00236() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00237() { npc = 000244; inh = 0;  }
void I00240() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I00241() { emul8();  }
void I00242() { emul8();  }
void I00243() { npc = 000234; inh = 0;  }
void L00244() { emul8();  }
void I00245() { lac &= (010000|core[000027]);  }
void I00246() { lac &= (010000|core[000103]);  }
void I00247() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00250() { npc = 000253; inh = 0;  }
void I00251() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void I00252() { npc = 000260; inh = 0;  }
void L00253() { lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00254() { lac &= (010000|core[000023]);  }
void I00255() { lac &= (010000|core[000024]);  }
void I00256() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00257() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void L00260() { emul8();  }
void I00261() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void I00262() { emul8();  }
void I00263() { lac ^= 07777;  }
void I00264() { lac &= (010000|core[000025]);  }
void I00265() { emul8();  }
void I00266() { lac ^= 07777;  }
void I00267() { lac &= (010000|core[000025]);  }
void I00270() { lac ^= 07777;  }
void I00271() { lac &= (010000|core[000030]);  }
void I00272() { emul8();  }
void I00273() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void L00274() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00275() { lac &= (010000|core[000023]);  }
void I00276() { lac += core[000024];  }
void I00277() {  }
void I00300() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I00301() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00302() { core[000032] = lac & 07777; lac &= 010000; code[000032] = &emul8;  }
void I00303() { lac ^= 07777;  }
void I00304() { lac &= (010000|core[000024]);  }
void I00305() { lac += core[000023];  }
void I00306() {  }
void I00307() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I00310() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00311() { core[000034] = lac & 07777; lac &= 010000; code[000034] = &emul8;  }
void I00312() {  }
void I00313() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00314() { lac &= (010000|core[000031]);  }
void I00315() { lac ^= 07777;  }
void I00316() { lac &= (010000|core[000033]);  }
void I00317() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00320() { npc = 000377; inh = 0;  }
void I00321() { lac ^= 07777;  }
void I00322() { lac &= (010000|core[000033]);  }
void I00323() { lac ^= 07777;  }
void I00324() { lac &= (010000|core[000031]);  }
void I00325() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00326() { npc = 000377; inh = 0;  }
void I00327() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00330() { lac &= (010000|core[000031]);  }
void I00331() { lac ^= 07777;  }
void I00332() { lac &= (010000|core[000025]);  }
void I00333() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00334() { npc = 000377; inh = 0;  }
void I00335() { lac ^= 07777;  }
void I00336() { lac &= (010000|core[000025]);  }
void I00337() { lac ^= 07777;  }
void I00340() { lac &= (010000|core[000031]);  }
void I00341() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00342() { npc = 000377; inh = 0;  }
void I00343() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00344() { lac &= (010000|core[000032]);  }
void I00345() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00346() { lac &= 010000; lac ^= 07777;  }
void I00347() { lac &= (010000|core[000034]);  }
void I00350() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00351() { lac ^= 010000;  }
void I00352() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00353() { npc = 000377; inh = 0;  }
void I00354() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00355() { lac &= (010000|core[000032]);  }
void I00356() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00357() { lac &= 010000; lac ^= 07777;  }
void I00360() { lac &= (010000|core[000026]);  }
void I00361() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00362() { lac ^= 010000;  }
void I00363() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00364() { npc = 000377; inh = 0;  }
void I00365() { npc = (ib<<12)+core[60]; inh = 0;  }
void L00366() { if (++core[000023] == 010000) { core[000023] = 0; npc++; }; code[000023] = &emul8;  }
void I00367() { npc = 000204; inh = 0;  }
void I00370() { if (++core[000024] == 010000) { core[000024] = 0; npc++; }; code[000024] = &emul8;  }
void I00371() { skp = 0; skp = !skp; npc += skp;  }
void I00372() { npc = (ib<<12)+core[61]; inh = 0;  }
void I00373() { lac &= 010000; lac ^= 07777;  }
void I00374() { lac &= (010000|core[000024]);  }
void I00375() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I00376() { npc = 000204; inh = 0;  }
void L00377() {  }
void L00400() { lac &= 010000; lac |= swr;  }
void I00401() { lac &= (010000|core[000104]);  }
void I00402() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00403() { core[000417] = 00404; npc = 000417+1; code[000417] = &emul8; inh = 0;  }
void L00404() { lac &= 010000; lac |= swr;  }
void I00405() { lac &= (010000|core[000103]);  }
void I00406() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00407() { core[000477] = 00410; npc = 000477+1; code[000477] = &emul8; inh = 0;  }
void L00410() { lac &= 010000; lac |= swr;  }
void I00411() { lac &= (010000|core[000105]);  }
void I00412() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00413() { npc = (ib<<12)+core[269]; inh = 0;  }
void I00414() { npc = (ib<<12)+core[270]; inh = 0;  }
void P00415() { lac &= (010000|core[000474]);  }
void P00416() { lac &= (010000|core[000566]);  }
void D00417() { lac &= (010000|core[000000]);  }
void I00420() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00421() { lac &= (010000|core[000035]);  }
void I00422() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00423() { core[000467] = 00424; npc = 000467+1; code[000467] = &emul8; inh = 0;  }
void I00424() { lac ^= 07777;  }
void I00425() { lac &= (010000|core[000023]);  }
void I00426() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I00427() { core[000523] = 00430; npc = 000523+1; code[000523] = &emul8; inh = 0;  }
void I00430() { lac ^= 07777;  }
void I00431() { lac &= (010000|core[000024]);  }
void I00432() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I00433() { core[000523] = 00434; npc = 000523+1; code[000523] = &emul8; inh = 0;  }
void I00434() { lac ^= 07777;  }
void I00435() { lac &= (010000|core[000026]);  }
void I00436() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I00437() { lac ^= 07777;  }
void I00440() { lac &= (010000|core[000025]);  }
void I00441() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I00442() { core[000504] = 00443; npc = 000504+1; code[000504] = &emul8; inh = 0;  }
void I00443() { core[000523] = 00444; npc = 000523+1; code[000523] = &emul8; inh = 0;  }
void I00444() { lac ^= 07777;  }
void I00445() { lac &= (010000|core[000032]);  }
void I00446() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I00447() { lac ^= 07777;  }
void I00450() { lac &= (010000|core[000031]);  }
void I00451() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I00452() { core[000504] = 00453; npc = 000504+1; code[000504] = &emul8; inh = 0;  }
void I00453() { core[000523] = 00454; npc = 000523+1; code[000523] = &emul8; inh = 0;  }
void I00454() { lac ^= 07777;  }
void I00455() { lac &= (010000|core[000034]);  }
void I00456() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I00457() { lac ^= 07777;  }
void I00460() { lac &= (010000|core[000033]);  }
void I00461() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I00462() { core[000504] = 00463; npc = 000504+1; code[000504] = &emul8; inh = 0;  }
void I00463() { core[000523] = 00464; npc = 000523+1; code[000523] = &emul8; inh = 0;  }
void I00464() { core[(ib<<12)+core[38]] = 00465; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I00465() { npc = (ib<<12)+core[354]; inh = 0;  }
void I00466() { npc = 000404; inh = 0;  }
void S00467() { lac &= (010000|core[000000]);  }
void I00470() { core[(ib<<12)+core[38]] = 00471; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I00471() { if (++core[000017] == 010000) core[000017] = 0000;npc = (ib<<12)+core[000017]; inh = 0;  }
void I00472() { core[(ib<<12)+core[38]] = 00473; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I00473() { npc = 000177; inh = 0;  }
void D00474() { lac &= 010000; lac ^= 07777;  }
void I00475() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void I00476() { npc = (ib<<12)+core[311]; inh = 0;  }
void S00477() { lac &= (010000|core[000000]);  }
void I00500() { lac &= 010000; lac ^= 07777;  }
void I00501() { lac &= (010000|core[000551]);  }
void I00502() { hlt = 1;  }
void I00503() { npc = (ib<<12)+core[319]; inh = 0;  }
void S00504() { lac &= (010000|core[000000]);  }
void I00505() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00506() { lac &= (010000|core[000040]);  }
void D00507() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00510() { npc = 000520; inh = 0;  }
void I00511() { lac ^= 07777;  }
void I00512() { lac &= (010000|core[000077]);  }
void L00513() { core[(ib<<12)+core[39]] = 00514; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I00514() { lac ^= 07777;  }
void I00515() { lac &= (010000|core[000076]);  }
void I00516() { core[(ib<<12)+core[39]] = 00517; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I00517() { npc = (ib<<12)+core[324]; inh = 0;  }
void L00520() { lac ^= 07777;  }
void P00521() { lac &= (010000|core[000100]);  }
void I00522() { npc = 000513; inh = 0;  }
void S00523() { lac &= (010000|core[000000]);  }
void I00524() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00525() { lac &= (010000|core[000102]);  }
void I00526() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void L00527() { lac ^= 07777;  }
void I00530() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I00531() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00532() { npc = 000545; inh = 0;  }
void I00533() { lac &= (010000|core[000037]);  }
void I00534() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00535() { npc = 000542; inh = 0;  }
void I00536() { lac ^= 07777;  }
void I00537() { lac &= (010000|core[000077]);  }
void L00540() { core[(ib<<12)+core[39]] = 00541; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I00541() { npc = 000527; inh = 0;  }
void P00542() { lac ^= 07777;  }
void I00543() { lac &= (010000|core[000100]);  }
void I00544() { npc = 000540; inh = 0;  }
void L00545() { lac ^= 07777;  }
void I00546() { lac &= (010000|core[000076]);  }
void I00547() { core[(ib<<12)+core[39]] = 00550; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I00550() { npc = (ib<<12)+core[339]; inh = 0;  }
void D00551() { lac &= (010000|core[000404]);  }
void L00552() { lac &= 010000; lac |= swr;  }
void I00553() { lac &= (010000|core[000115]);  }
void I00554() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00555() { npc = 000570; inh = 0;  }
void L00556() { lac &= 010000; lac |= swr;  }
void I00557() { lac &= (010000|core[000114]);  }
void I00560() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00561() { hlt = 1;  }
void I00562() { lac &= 010000; lac |= swr;  }
void I00563() { lac &= (010000|core[000116]);  }
void I00564() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00565() { npc = 000577; inh = 0;  }
void D00566() { npc = (ib<<12)+core[375]; inh = 0;  }
void P00567() { lac &= (010000|core[000404]);  }
void L00570() { core[(ib<<12)+core[38]] = 00571; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I00571() { npc = (ib<<12)+core[337]; inh = 0;  }
void I00572() { npc = 000556; inh = 0;  }
void L00577() {  }
void L00600() { core[(ib<<12)+core[490]] = 00601; npc = (ib<<12)+core[490]+1; code[(ib<<12)+core[490]] = &emul8; inh = 0;  }
void L00601() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00602() { lac &= (010000|core[000052]);  }
void I00603() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I00604() { core[(ib<<12)+core[41]] = 00605; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void L00605() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00606() { lac &= (010000|core[000024]);  }
void I00607() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00610() { lac ^= 010000;  }
void I00611() { lac ^= 07777;  }
void I00612() { lac &= (010000|core[000023]);  }
void I00613() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00614() {  }
void I00615() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I00616() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00617() { lac ^= 07777;  }
void I00620() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I00621() { core[(ib<<12)+core[46]] = 00622; npc = (ib<<12)+core[46]+1; code[(ib<<12)+core[46]] = &emul8; inh = 0;  }
void I00622() { npc = 000605; inh = 0;  }
void I00623() { core[(ib<<12)+core[47]] = 00624; npc = (ib<<12)+core[47]+1; code[(ib<<12)+core[47]] = &emul8; inh = 0;  }
void I00624() { npc = 000601; inh = 0;  }
void I00625() { core[(ib<<12)+core[491]] = 00626; npc = (ib<<12)+core[491]+1; code[(ib<<12)+core[491]] = &emul8; inh = 0;  }
void L00626() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00627() { lac &= (010000|core[000102]);  }
void I00630() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I00631() { core[(ib<<12)+core[41]] = 00632; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void L00632() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00633() { lac &= (010000|core[000024]);  }
void I00634() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00635() { lac ^= 010000;  }
void D00636() { lac ^= 07777;  }
void I00637() { lac &= (010000|core[000023]);  }
void I00640() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00641() {  }
void I00642() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I00643() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00644() { lac ^= 07777;  }
void I00645() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I00646() { core[(ib<<12)+core[46]] = 00647; npc = (ib<<12)+core[46]+1; code[(ib<<12)+core[46]] = &emul8; inh = 0;  }
void I00647() { npc = 000632; inh = 0;  }
void I00650() { core[(ib<<12)+core[47]] = 00651; npc = (ib<<12)+core[47]+1; code[(ib<<12)+core[47]] = &emul8; inh = 0;  }
void I00651() { npc = 000626; inh = 0;  }
void I00652() { core[(ib<<12)+core[492]] = 00653; npc = (ib<<12)+core[492]+1; code[(ib<<12)+core[492]] = &emul8; inh = 0;  }
void L00653() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00654() { lac &= (010000|core[000053]);  }
void I00655() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I00656() { core[(ib<<12)+core[41]] = 00657; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void L00657() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00660() { lac &= (010000|core[000024]);  }
void I00661() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00662() { lac ^= 010000;  }
void I00663() { lac ^= 07777;  }
void I00664() { lac &= (010000|core[000023]);  }
void I00665() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00666() {  }
void I00667() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I00670() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00671() { lac ^= 07777;  }
void I00672() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I00673() { core[(ib<<12)+core[46]] = 00674; npc = (ib<<12)+core[46]+1; code[(ib<<12)+core[46]] = &emul8; inh = 0;  }
void I00674() { npc = 000657; inh = 0;  }
void I00675() { core[(ib<<12)+core[47]] = 00676; npc = (ib<<12)+core[47]+1; code[(ib<<12)+core[47]] = &emul8; inh = 0;  }
void I00676() { npc = 000653; inh = 0;  }
void I00677() { core[(ib<<12)+core[493]] = 00700; npc = (ib<<12)+core[493]+1; code[(ib<<12)+core[493]] = &emul8; inh = 0;  }
void L00700() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00701() { lac &= (010000|core[000054]);  }
void I00702() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I00703() { core[(ib<<12)+core[41]] = 00704; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void L00704() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00705() { lac &= (010000|core[000024]);  }
void I00706() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00707() { lac ^= 010000;  }
void I00710() { lac ^= 07777;  }
void I00711() { lac &= (010000|core[000023]);  }
void I00712() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00713() {  }
void I00714() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I00715() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00716() { lac ^= 07777;  }
void I00717() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I00720() { core[(ib<<12)+core[46]] = 00721; npc = (ib<<12)+core[46]+1; code[(ib<<12)+core[46]] = &emul8; inh = 0;  }
void I00721() { npc = 000704; inh = 0;  }
void I00722() { core[(ib<<12)+core[47]] = 00723; npc = (ib<<12)+core[47]+1; code[(ib<<12)+core[47]] = &emul8; inh = 0;  }
void D00723() { npc = 000700; inh = 0;  }
void I00724() { core[(ib<<12)+core[494]] = 00725; npc = (ib<<12)+core[494]+1; code[(ib<<12)+core[494]] = &emul8; inh = 0;  }
void L00725() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00726() { lac &= (010000|core[000055]);  }
void I00727() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I00730() { core[(ib<<12)+core[510]] = 00731; npc = (ib<<12)+core[510]+1; code[(ib<<12)+core[510]] = &emul8; inh = 0;  }
void L00731() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00732() { lac &= (010000|core[000024]);  }
void I00733() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00734() { lac ^= 010000;  }
void I00735() { lac ^= 07777;  }
void I00736() { lac &= (010000|core[000023]);  }
void I00737() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I00740() {  }
void I00741() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I00742() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00743() { lac ^= 07777;  }
void I00744() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I00745() { core[(ib<<12)+core[46]] = 00746; npc = (ib<<12)+core[46]+1; code[(ib<<12)+core[46]] = &emul8; inh = 0;  }
void I00746() { npc = 000731; inh = 0;  }
void I00747() { core[(ib<<12)+core[47]] = 00750; npc = (ib<<12)+core[47]+1; code[(ib<<12)+core[47]] = &emul8; inh = 0;  }
void I00750() { npc = 000725; inh = 0;  }
void I00751() { npc = (ib<<12)+core[511]; inh = 0;  }
void P00752() { lac += core[(df<<12)+core[0]];  }
void P00753() { if (++core[000010] == 010000) core[000010] = 0000;lac += core[(df<<12)+core[000010]];  }
void P00754() { lac += core[(df<<12)+core[16]];  }
void P00755() { lac += core[(df<<12)+core[24]];  }
void P00756() { lac += core[(df<<12)+core[32]];  }
void I00757() { lac &= (010000|core[000001]);  }
void I00760() { lac &= (010000|core[000002]);  }
void I00761() { lac &= (010000|core[000004]);  }
void I00762() { lac &= (010000|core[000010]);  }
void I00763() { lac &= (010000|core[000020]);  }
void I00764() { lac &= (010000|core[000040]);  }
void I00765() { lac &= (010000|core[000100]);  }
void I00766() { lac &= (010000|core[000600]);  }
void I00767() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I00770() { lac += core[000000];  }
void I00771() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I00772() { core[000000] = 00773; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I00773() { lac &= (010000|core[000000]);  }
void I00774() { lac &= (010000|core[000001]);  }
void I00775() { core[000000] = 00776; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void P00776() { lac += core[000636];  }
void P00777() { lac += core[000723];  }
void S01000() { lac &= (010000|core[000000]);  }
void I01001() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01002() { lac &= (010000|core[000025]);  }
void I01003() { lac ^= 07777;  }
void I01004() { lac &= (010000|core[000031]);  }
void I01005() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01006() { npc = 001026; inh = 0;  }
void I01007() { lac ^= 07777;  }
void I01010() { lac &= (010000|core[000031]);  }
void I01011() { lac ^= 07777;  }
void I01012() { lac &= (010000|core[000025]);  }
void I01013() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01014() { npc = 001026; inh = 0;  }
void I01015() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01016() { lac &= (010000|core[000026]);  }
void I01017() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01020() { lac ^= 010000;  }
void I01021() { lac ^= 07777;  }
void I01022() { lac &= (010000|core[000033]);  }
void I01023() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01024() { lac ^= 010000;  }
void I01025() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void L01026() { npc = 001046; inh = 0;  }
void L01027() { if (++core[001000] == 010000) { core[001000] = 0; npc++; }; code[001000] = &emul8;  }
void L01030() { npc = (ib<<12)+core[512]; inh = 0;  }
void S01031() { lac &= (010000|core[000000]);  }
void I01032() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01033() { lac &= (010000|core[000024]);  }
void I01034() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01035() { npc = 001044; inh = 0;  }
void I01036() { lac ^= 07777;  }
void I01037() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01040() { if (++core[000023] == 010000) { core[000023] = 0; npc++; }; code[000023] = &emul8;  }
void I01041() { npc = (ib<<12)+core[537]; inh = 0;  }
void I01042() { if (++core[001031] == 010000) { core[001031] = 0; npc++; }; code[001031] = &emul8;  }
void I01043() { npc = (ib<<12)+core[537]; inh = 0;  }
void L01044() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01045() { npc = (ib<<12)+core[537]; inh = 0;  }
void L01046() { lac &= 010000; lac |= swr;  }
void I01047() { lac &= (010000|core[000104]);  }
void I01050() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01051() { core[001071] = 01052; npc = 001071+1; code[001071] = &emul8; inh = 0;  }
void I01052() { lac &= 010000; lac |= swr;  }
void I01053() { lac &= (010000|core[000103]);  }
void I01054() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01055() { npc = 001063; inh = 0;  }
void L01056() { lac &= 010000; lac |= swr;  }
void I01057() { lac &= (010000|core[000105]);  }
void I01060() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01061() { npc = 001027; inh = 0;  }
void I01062() { npc = 001030; inh = 0;  }
void L01063() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01064() { lac &= (010000|core[(df<<12)+core[41]]);  }
void I01065() { lac += core[001070];  }
void I01066() { hlt = 1;  }
void I01067() { npc = 001056; inh = 0;  }
void D01070() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void S01071() { lac &= (010000|core[000000]);  }
void I01072() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01073() { lac &= (010000|core[000035]);  }
void I01074() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01075() { core[001131] = 01076; npc = 001131+1; code[001131] = &emul8; inh = 0;  }
void I01076() { lac ^= 07777;  }
void L01077() { lac &= (010000|core[000023]);  }
void I01100() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I01101() { lac ^= 07777;  }
void I01102() { lac &= (010000|core[000024]);  }
void I01103() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I01104() { core[(ib<<12)+core[48]] = 01105; npc = (ib<<12)+core[48]+1; code[(ib<<12)+core[48]] = &emul8; inh = 0;  }
void I01105() { core[(ib<<12)+core[49]] = 01106; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I01106() { lac ^= 07777;  }
void I01107() { lac &= (010000|core[000025]);  }
void I01110() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I01111() { lac ^= 07777;  }
void I01112() { lac &= (010000|core[000026]);  }
void I01113() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I01114() { core[(ib<<12)+core[48]] = 01115; npc = (ib<<12)+core[48]+1; code[(ib<<12)+core[48]] = &emul8; inh = 0;  }
void I01115() { core[(ib<<12)+core[49]] = 01116; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I01116() { lac ^= 07777;  }
void I01117() { lac &= (010000|core[000031]);  }
void I01120() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I01121() { lac ^= 07777;  }
void I01122() { lac &= (010000|core[000033]);  }
void I01123() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I01124() { core[(ib<<12)+core[48]] = 01125; npc = (ib<<12)+core[48]+1; code[(ib<<12)+core[48]] = &emul8; inh = 0;  }
void I01125() { core[(ib<<12)+core[49]] = 01126; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I01126() { core[(ib<<12)+core[38]] = 01127; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I01127() { npc = (ib<<12)+core[610]; inh = 0;  }
void I01130() { npc = (ib<<12)+core[569]; inh = 0;  }
void S01131() { lac &= (010000|core[000000]);  }
void I01132() { core[(ib<<12)+core[38]] = 01133; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void D01133() { lac &= (010000|core[000000]);  }
void I01134() { core[(ib<<12)+core[38]] = 01135; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I01135() { npc = 001044; inh = 0;  }
void I01136() { lac &= 010000; lac ^= 07777;  }
void I01137() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void I01140() { npc = (ib<<12)+core[601]; inh = 0;  }
void I01141() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void P01142() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I01143() { lac &= (010000|core[000100]);  }
void I01144() { lac &= (010000|core[000020]);  }
void I01145() { lac &= (010000|core[000004]);  }
void I01146() { lac &= (010000|core[000001]);  }
void I01147() { core[000000] = 01150; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I01150() { lac += core[000000];  }
void I01151() { lac &= (010000|core[001000]);  }
void I01152() { lac &= (010000|core[000040]);  }
void I01153() { lac &= (010000|core[000010]);  }
void I01154() { lac &= (010000|core[000002]);  }
void I01155() { lac &= (010000|core[000000]);  }
void I01156() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I01157() { lac &= (010000|core[000002]);  }
void I01160() { lac &= (010000|core[000002]);  }
void I01161() { lac &= (010000|core[000010]);  }
void I01162() { lac &= (010000|core[000040]);  }
void I01163() { lac &= (010000|core[001000]);  }
void I01164() { lac += core[000000];  }
void I01165() { core[000000] = 01166; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I01166() { lac &= (010000|core[000001]);  }
void I01167() { lac &= (010000|core[000004]);  }
void I01170() { lac &= (010000|core[000020]);  }
void I01171() { lac &= (010000|core[000100]);  }
void I01172() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I01173() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I01174() { lac &= (010000|core[000000]);  }
void I01175() { lac &= (010000|core[000002]);  }
void I01176() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void S01200() { lac &= (010000|core[000000]);  }
void I01201() { lac &= 010000; lac &= 07777;  }
void I01202() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I01203() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void I01204() { lac ^= 07777;  }
void I01205() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01206() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void L01207() { lac ^= 07777;  }
void I01210() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01211() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01212() { npc = 001303; inh = 0;  }
void I01213() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I01214() { lac ^= 07777;  }
void I01215() { lac &= (010000|core[000023]);  }
void I01216() { lac &= (010000|core[000037]);  }
void I01217() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01220() { core[001225] = 01221; npc = 001225+1; code[001225] = &emul8; inh = 0;  }
void I01221() { lac ^= 07777;  }
void I01222() { lac &= (010000|core[000040]);  }
void I01223() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I01224() { npc = 001207; inh = 0;  }
void S01225() { lac &= (010000|core[000000]);  }
void I01226() { lac &= 010000; lac ^= 07777;  }
void I01227() { lac &= (010000|core[000040]);  }
void I01230() { emul8();  }
void I01231() { lac ^= 07777;  }
void I01232() { lac &= (010000|core[000025]);  }
void I01233() { emul8();  }
void I01234() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I01235() { npc = (ib<<12)+core[661]; inh = 0;  }
void S01236() { lac &= (010000|core[000000]);  }
void I01237() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01240() { lac &= (010000|core[001236]);  }
void I01241() { core[(df<<12)+core[41]] = lac & 07777; lac &= 010000; code[(df<<12)+core[41]] = &emul8;  }
void I01242() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I01243() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void L01244() { lac ^= 07777;  }
void I01245() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01246() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01247() { npc = 001277; inh = 0;  }
void I01250() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I01251() { lac ^= 07777;  }
void I01252() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01253() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I01254() { lac ^= 07777;  }
void I01255() { lac &= (010000|core[000023]);  }
void I01256() { lac &= (010000|core[000037]);  }
void I01257() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01260() { core[001225] = 01261; npc = 001225+1; code[001225] = &emul8; inh = 0;  }
void I01261() { lac ^= 07777;  }
void I01262() { lac &= (010000|core[000037]);  }
void I01263() { emul8();  }
void I01264() { lac ^= 07777;  }
void I01265() { lac &= (010000|core[000040]);  }
void I01266() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I01267() { emul8();  }
void I01270() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I01271() { lac ^= 07777;  }
void I01272() { lac &= (010000|core[000023]);  }
void I01273() { lac &= (010000|core[000037]);  }
void I01274() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01275() { core[001225] = 01276; npc = 001225+1; code[001225] = &emul8; inh = 0;  }
void I01276() { npc = 001244; inh = 0;  }
void L01277() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01300() { lac &= (010000|core[000024]);  }
void I01301() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void I01302() { npc = (ib<<12)+core[670]; inh = 0;  }
void L01303() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01304() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01305() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I01306() { lac ^= 07777;  }
void I01307() { lac &= (010000|core[000116]);  }
void I01310() { lac &= (010000|core[000024]);  }
void I01311() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01312() { core[001225] = 01313; npc = 001225+1; code[001225] = &emul8; inh = 0;  }
void I01313() { lac ^= 07777;  }
void I01314() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I01315() { lac &= (010000|core[000023]);  }
void I01316() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01317() { lac &= 010000; lac ^= 07777;  }
void I01320() { lac &= (010000|core[000116]);  }
void I01321() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void I01322() { npc = (ib<<12)+core[640]; inh = 0;  }
void L01323() { lac &= 010000; lac |= swr;  }
void I01324() { lac &= (010000|core[000115]);  }
void P01325() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01326() { npc = 001342; inh = 0;  }
void L01327() { lac &= 010000; lac |= swr;  }
void I01330() { lac &= (010000|core[000114]);  }
void I01331() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01332() { hlt = 1;  }
void I01333() { lac &= 010000; lac |= swr;  }
void I01334() { lac &= (010000|core[000116]);  }
void I01335() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01336() { npc = (ib<<12)+core[736]; inh = 0;  }
void I01337() { npc = (ib<<12)+core[737]; inh = 0;  }
void P01340() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void P01341() { lac &= (010000|core[(df<<12)+core[640]]);  }
void L01342() { core[(ib<<12)+core[38]] = 01343; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I01343() { npc = (ib<<12)+core[725]; inh = 0;  }
void I01344() { npc = 001327; inh = 0;  }
void S01400() { lac &= (010000|core[000000]);  }
void I01401() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01402() { lac &= (010000|core[001450]);  }
void I01403() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I01404() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void D01405() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01406() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I01407() { npc = (ib<<12)+core[768]; inh = 0;  }
void S01410() { lac &= (010000|core[000000]);  }
void I01411() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01412() { lac &= (010000|core[001451]);  }
void I01413() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I01414() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void I01415() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01416() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I01417() { npc = (ib<<12)+core[776]; inh = 0;  }
void S01420() { lac &= (010000|core[000000]);  }
void I01421() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01422() { lac &= (010000|core[001452]);  }
void I01423() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I01424() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void I01425() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01426() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I01427() { npc = (ib<<12)+core[784]; inh = 0;  }
void S01430() { lac &= (010000|core[000000]);  }
void I01431() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01432() { lac &= (010000|core[001453]);  }
void I01433() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I01434() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void I01435() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01436() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I01437() { npc = (ib<<12)+core[792]; inh = 0;  }
void S01440() { lac &= (010000|core[000000]);  }
void I01441() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01442() { lac &= (010000|core[001454]);  }
void I01443() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I01444() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void I01445() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01446() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I01447() { npc = (ib<<12)+core[800]; inh = 0;  }
void D01450() { npc = (ib<<12)+core[32]; inh = 0;  }
void D01451() { npc = (ib<<12)+core[49]; inh = 0;  }
void D01452() { npc = (ib<<12)+core[66]; inh = 0;  }
void D01453() { npc = (ib<<12)+core[83]; inh = 0;  }
void D01454() { npc = (ib<<12)+core[100]; inh = 0;  }
void S01600() { lac &= (010000|core[000000]);  }
void I01601() { lac &= 010000; lac &= 07777;  }
void I01602() { lac += core[(df<<12)+core[896]];  }
void I01603() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01604() { if (++core[001600] == 010000) { core[001600] = 0; npc++; }; code[001600] = &emul8;  }
void L01605() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I01606() { core[000036] = lac & 07777; lac &= 010000; code[000036] = &emul8;  }
void I01607() { lac += core[000036];  }
void I01610() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01611() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D01612() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01613() { core[001617] = 01614; npc = 001617+1; code[001617] = &emul8; inh = 0;  }
void I01614() { lac += core[000036];  }
void D01615() { core[001617] = 01616; npc = 001617+1; code[001617] = &emul8; inh = 0;  }
void I01616() { npc = 001605; inh = 0;  }
void S01617() { lac &= (010000|core[000000]);  }
void I01620() { lac &= (010000|core[001645]);  }
void I01621() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01622() { npc = (ib<<12)+core[896]; inh = 0;  }
void I01623() { lac += core[001646];  }
void I01624() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I01625() { npc = 001630; inh = 0;  }
void I01626() { lac += core[000076];  }
void I01627() { npc = 001643; inh = 0;  }
void L01630() { lac++;  }
void I01631() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01632() { npc = 001635; inh = 0;  }
void I01633() { lac += core[001651];  }
void I01634() { npc = 001643; inh = 0;  }
void L01635() { lac++;  }
void I01636() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01637() { npc = 001642; inh = 0;  }
void I01640() { lac += core[001650];  }
void I01641() { npc = 001643; inh = 0;  }
void L01642() { lac += core[001647];  }
void L01643() { core[(ib<<12)+core[39]] = 01644; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I01644() { npc = (ib<<12)+core[911]; inh = 0;  }
void D01645() { lac &= (010000|core[000077]);  }
void D01646() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D01647() { lac &= (010000|core[001736]);  }
void D01650() { lac &= (010000|core[001612]);  }
void D01651() { lac &= (010000|core[001615]);  }
void S01652() { lac &= (010000|core[000000]);  }
void I01653() { emul8();  }
void L01654() { emul8();  }
void I01655() { npc = 001654; inh = 0;  }
void I01656() { lac &= 010000;  }
void D01657() { npc = (ib<<12)+core[938]; inh = 0;  }
void I01660() { lac &= (010000|core[000001]);  }
void I01661() { lac &= (010000|core[000100]);  }
void I01662() { lac &= (010000|core[000002]);  }
void I01663() { lac &= (010000|core[001600]);  }
void I01664() { lac &= (010000|core[000004]);  }
void I01665() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I01666() { lac &= (010000|core[000010]);  }
void I01667() { lac += core[000000];  }
void I01670() { lac &= (010000|core[000020]);  }
void I01671() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I01672() { lac &= (010000|core[000040]);  }
void I01673() { core[000000] = 01674; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I01674() { lac &= (010000|core[000000]);  }
void L02000() { lac &= 010000; lac &= 07777;  }
void I02001() { lac += core[000122];  }
void I02002() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02003() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void L02004() { lac &= 010000; lac &= 07777;  }
void I02005() { lac &= 010000; lac &= 07777;  }
void I02006() { core[(df<<12)+core[57]] = lac & 07777; lac &= 010000; code[(df<<12)+core[57]] = &emul8;  }
void I02007() { lac += core[000136];  }
void I02010() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02011() { lac += core[002132];  }
void I02012() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02013() { lac += core[000137];  }
void I02014() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02015() { lac += core[000140];  }
void I02016() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I02017() { lac &= 010000; lac ^= 07777;  }
void I02020() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I02021() { lac += core[002127];  }
void I02022() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void L02023() { lac &= 010000; lac &= 07777;  }
void I02024() { npc = (ib<<12)+core[58]; inh = 0;  }
void I02025() {  }
void I02026() {  }
void I02027() { core[(ib<<12)+core[52]] = 02030; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02030() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02031() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02032() { core[(ib<<12)+core[53]] = 02033; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02033() { skp = 0; skp = !skp; npc += skp;  }
void I02034() { core[(ib<<12)+core[54]] = 02035; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02035() { core[(ib<<12)+core[55]] = 02036; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02036() { npc = 002023; inh = 0;  }
void I02037() { lac &= 010000;  }
void I02040() { lac += core[000123];  }
void I02041() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02042() { npc = (ib<<12)+core[108]; inh = 0;  }
void L02043() { lac &= 010000; lac &= 07777;  }
void I02044() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02045() { core[(df<<12)+core[57]] = lac & 07777; lac &= 010000; code[(df<<12)+core[57]] = &emul8;  }
void I02046() { lac += core[000136];  }
void I02047() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02050() { lac += core[000137];  }
void I02051() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02052() { lac += core[000141];  }
void I02053() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02054() { lac += core[002130];  }
void I02055() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void L02056() { lac &= 010000; lac &= 07777;  }
void I02057() { npc = (ib<<12)+core[58]; inh = 0;  }
void I02060() {  }
void I02061() {  }
void I02062() { core[(ib<<12)+core[52]] = 02063; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02063() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02064() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02065() { core[(ib<<12)+core[53]] = 02066; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02066() { skp = 0; skp = !skp; npc += skp;  }
void I02067() { core[(ib<<12)+core[54]] = 02070; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02070() { core[(ib<<12)+core[55]] = 02071; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02071() { npc = 002056; inh = 0;  }
void I02072() { lac &= 010000;  }
void I02073() { lac += core[000124];  }
void I02074() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02075() { npc = (ib<<12)+core[108]; inh = 0;  }
void I02076() { lac &= 010000; lac &= 07777;  }
void I02077() { lac += core[000137];  }
void I02100() { core[(df<<12)+core[57]] = lac & 07777; lac &= 010000; code[(df<<12)+core[57]] = &emul8;  }
void I02101() { lac += core[002133];  }
void I02102() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02103() { lac += core[000152];  }
void I02104() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02105() { lac += core[002131];  }
void I02106() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void L02107() { lac &= 010000; lac &= 07777;  }
void I02110() { npc = (ib<<12)+core[57]; inh = 0;  }
void I02111() {  }
void I02112() {  }
void I02113() { core[(ib<<12)+core[52]] = 02114; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02114() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02115() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02116() { core[(ib<<12)+core[53]] = 02117; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02117() { skp = 0; skp = !skp; npc += skp;  }
void I02120() { core[(ib<<12)+core[54]] = 02121; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02121() { core[(ib<<12)+core[55]] = 02122; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02122() { npc = 002107; inh = 0;  }
void I02123() { lac &= 010000;  }
void I02124() { lac += core[000125];  }
void I02125() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02126() { npc = (ib<<12)+core[108]; inh = 0;  }
void D02127() { if (++core[000025] == 010000) { core[000025] = 0; npc++; }; code[000025] = &emul8;  }
void D02130() { if (++core[000060] == 010000) { core[000060] = 0; npc++; }; code[000060] = &emul8;  }
void D02131() { if (++core[000111] == 010000) { core[000111] = 0; npc++; }; code[000111] = &emul8;  }
void D02132() { lac += core[000003];  }
void D02133() { lac += core[(df<<12)+core[17]];  }
void I02200() { lac &= 010000; lac &= 07777;  }
void I02201() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02202() { core[(df<<12)+core[57]] = lac & 07777; lac &= 010000; code[(df<<12)+core[57]] = &emul8;  }
void I02203() { lac += core[000136];  }
void I02204() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02205() { lac += core[000142];  }
void I02206() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02207() { lac += core[000141];  }
void I02210() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02211() { lac += core[002324];  }
void I02212() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void L02213() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02214() { npc = (ib<<12)+core[58]; inh = 0;  }
void D02215() {  }
void I02216() {  }
void I02217() { core[(ib<<12)+core[52]] = 02220; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02220() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02221() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02222() { core[(ib<<12)+core[53]] = 02223; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02223() { skp = 0; skp = !skp; npc += skp;  }
void I02224() { core[(ib<<12)+core[54]] = 02225; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02225() { core[(ib<<12)+core[55]] = 02226; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02226() { npc = 002213; inh = 0;  }
void I02227() { lac += core[000126];  }
void I02230() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02231() { npc = (ib<<12)+core[108]; inh = 0;  }
void I02232() { lac &= 010000; lac &= 07777;  }
void I02233() { lac &= 010000; lac &= 07777;  }
void I02234() { lac += core[000143];  }
void I02235() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02236() { lac += core[000137];  }
void I02237() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02240() { lac += core[000137];  }
void I02241() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02242() { lac += core[000151];  }
void I02243() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I02244() { lac += core[002325];  }
void I02245() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void L02246() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02247() { core[(df<<12)+core[57]] = lac & 07777; lac &= 010000; code[(df<<12)+core[57]] = &emul8;  }
void I02250() { lac ^= 07777;  }
void I02251() { npc = (ib<<12)+core[58]; inh = 0;  }
void D02252() {  }
void I02253() {  }
void I02254() { core[(ib<<12)+core[52]] = 02255; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02255() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02256() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02257() { core[(ib<<12)+core[53]] = 02260; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02260() { skp = 0; skp = !skp; npc += skp;  }
void I02261() { core[(ib<<12)+core[54]] = 02262; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02262() { core[(ib<<12)+core[55]] = 02263; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02263() { npc = 002246; inh = 0;  }
void I02264() { lac &= 010000;  }
void I02265() { lac += core[000127];  }
void I02266() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02267() { npc = (ib<<12)+core[108]; inh = 0;  }
void I02270() { lac &= 010000; lac &= 07777;  }
void I02271() { lac &= 010000; lac &= 07777;  }
void I02272() { lac += core[000144];  }
void I02273() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02274() { lac += core[000137];  }
void I02275() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02276() { lac += core[000151];  }
void I02277() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I02300() { lac += core[002326];  }
void I02301() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void L02302() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02303() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02304() { lac &= 010000; lac ^= 07777;  }
void I02305() { npc = (ib<<12)+core[58]; inh = 0;  }
void D02306() {  }
void I02307() {  }
void I02310() { core[(ib<<12)+core[52]] = 02311; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02311() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02312() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02313() { core[(ib<<12)+core[53]] = 02314; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02314() { skp = 0; skp = !skp; npc += skp;  }
void I02315() { core[(ib<<12)+core[54]] = 02316; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02316() { core[(ib<<12)+core[55]] = 02317; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02317() { npc = 002302; inh = 0;  }
void I02320() { lac &= 010000;  }
void I02321() { lac += core[000130];  }
void I02322() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02323() { npc = (ib<<12)+core[108]; inh = 0;  }
void D02324() { if (++core[002215] == 010000) { core[002215] = 0; npc++; }; code[002215] = &emul8;  }
void D02325() { if (++core[002252] == 010000) { core[002252] = 0; npc++; }; code[002252] = &emul8;  }
void D02326() { if (++core[002306] == 010000) { core[002306] = 0; npc++; }; code[002306] = &emul8;  }
void D02400() { lac &= 010000; lac &= 07777;  }
void I02401() { lac &= 010000; lac &= 07777;  }
void I02402() { lac += core[000145];  }
void I02403() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02404() { lac += core[000137];  }
void I02405() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02406() { lac += core[000151];  }
void I02407() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I02410() { lac += core[002526];  }
void I02411() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void L02412() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02413() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I02414() { lac ^= 07777;  }
void I02415() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02416() { lac ^= 07777;  }
void I02417() { npc = (ib<<12)+core[58]; inh = 0;  }
void I02420() {  }
void I02421() {  }
void I02422() { core[(ib<<12)+core[52]] = 02423; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02423() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02424() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void D02425() { core[(ib<<12)+core[53]] = 02426; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02426() { skp = 0; skp = !skp; npc += skp;  }
void I02427() { core[(ib<<12)+core[54]] = 02430; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02430() { core[(ib<<12)+core[55]] = 02431; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02431() { npc = 002412; inh = 0;  }
void I02432() { lac &= 010000;  }
void I02433() { lac += core[000131];  }
void I02434() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02435() { npc = (ib<<12)+core[108]; inh = 0;  }
void I02436() { lac &= 010000; lac &= 07777;  }
void I02437() { lac &= 010000; lac &= 07777;  }
void I02440() { lac += core[000137];  }
void I02441() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02442() { lac += core[000137];  }
void I02443() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02444() { lac += core[000140];  }
void I02445() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I02446() { lac += core[002527];  }
void I02447() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void L02450() { lac &= 010000; lac &= 07777;  }
void I02451() { lac += core[000146];  }
void I02452() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02453() { lac &= 010000; lac ^= 07777;  }
void I02454() { npc = (ib<<12)+core[58]; inh = 0;  }
void I02455() {  }
void I02456() {  }
void I02457() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02460() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02461() { core[(ib<<12)+core[53]] = 02462; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02462() { skp = 0; skp = !skp; npc += skp;  }
void I02463() { core[(ib<<12)+core[54]] = 02464; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02464() { core[(ib<<12)+core[55]] = 02465; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02465() { npc = 002450; inh = 0;  }
void I02466() { lac &= 010000;  }
void I02467() { lac += core[000132];  }
void I02470() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02471() { npc = (ib<<12)+core[108]; inh = 0;  }
void I02472() { lac &= 010000; lac &= 07777;  }
void I02473() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02474() { core[(df<<12)+core[57]] = lac & 07777; lac &= 010000; code[(df<<12)+core[57]] = &emul8;  }
void I02475() { lac += core[000137];  }
void I02476() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02477() { lac += core[000141];  }
void I02500() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02501() { lac += core[002530];  }
void I02502() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void L02503() { lac &= 010000; lac &= 07777;  }
void I02504() { lac += core[000147];  }
void I02505() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02506() { lac &= 010000; lac ^= 07777;  }
void I02507() { npc = (ib<<12)+core[58]; inh = 0;  }
void I02510() {  }
void I02511() {  }
void I02512() { core[(ib<<12)+core[52]] = 02513; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02513() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02514() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02515() { core[(ib<<12)+core[53]] = 02516; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02516() { skp = 0; skp = !skp; npc += skp;  }
void I02517() { core[(ib<<12)+core[54]] = 02520; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02520() { core[(ib<<12)+core[55]] = 02521; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02521() { npc = 002503; inh = 0;  }
void I02522() { lac &= 010000;  }
void I02523() { lac += core[000133];  }
void I02524() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02525() { npc = (ib<<12)+core[108]; inh = 0;  }
void D02526() { if (++core[(df<<12)+core[16]] == 010000) { core[(df<<12)+core[16]] = 0; npc++; }; code[(df<<12)+core[16]] = &emul8;  }
void D02527() { if (++core[(df<<12)+core[45]] == 010000) { core[(df<<12)+core[45]] = 0; npc++; }; code[(df<<12)+core[45]] = &emul8;  }
void D02530() { if (++core[(df<<12)+core[72]] == 010000) { core[(df<<12)+core[72]] = 0; npc++; }; code[(df<<12)+core[72]] = &emul8;  }
void D02600() { lac &= 010000; lac &= 07777;  }
void I02601() { lac &= 010000; lac &= 07777;  }
void I02602() { lac += core[000150];  }
void I02603() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02604() { lac += core[000137];  }
void I02605() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02606() { lac += core[000151];  }
void I02607() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I02610() { lac += core[002715];  }
void I02611() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void L02612() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02613() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I02614() { lac ^= 07777;  }
void I02615() { npc = (ib<<12)+core[58]; inh = 0;  }
void P02616() {  }
void I02617() {  }
void I02620() { core[(ib<<12)+core[52]] = 02621; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02621() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02622() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02623() { core[(ib<<12)+core[53]] = 02624; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02624() { skp = 0; skp = !skp; npc += skp;  }
void I02625() { core[(ib<<12)+core[54]] = 02626; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02626() { core[(ib<<12)+core[55]] = 02627; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02627() { npc = 002612; inh = 0;  }
void I02630() { lac &= 010000;  }
void I02631() { lac += core[000134];  }
void I02632() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02633() { npc = (ib<<12)+core[108]; inh = 0;  }
void I02634() { lac &= 010000; lac &= 07777;  }
void I02635() { lac &= 010000; lac &= 07777;  }
void I02636() { lac += core[000137];  }
void I02637() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02640() { lac += core[000141];  }
void I02641() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I02642() { lac += core[002716];  }
void I02643() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void L02644() { lac &= 010000; lac &= 07777;  }
void I02645() { lac += core[000153];  }
void I02646() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02647() { lac &= 010000; lac ^= 07777;  }
void I02650() { npc = (ib<<12)+core[58]; inh = 0;  }
void P02651() {  }
void I02652() {  }
void I02653() { core[(ib<<12)+core[52]] = 02654; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02654() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02655() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02656() { core[(ib<<12)+core[53]] = 02657; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02657() { skp = 0; skp = !skp; npc += skp;  }
void I02660() { core[(ib<<12)+core[54]] = 02661; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02661() { core[(ib<<12)+core[55]] = 02662; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02662() { npc = 002644; inh = 0;  }
void I02663() { lac &= 010000;  }
void I02664() { lac += core[000135];  }
void I02665() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02666() { npc = (ib<<12)+core[108]; inh = 0;  }
void I02667() { lac &= 010000; lac &= 07777;  }
void I02670() { lac &= 010000; lac &= 07777;  }
void I02671() { lac += core[000137];  }
void I02672() { core[(df<<12)+core[58]] = lac & 07777; lac &= 010000; code[(df<<12)+core[58]] = &emul8;  }
void I02673() { lac += core[000152];  }
void I02674() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I02675() { lac += core[002717];  }
void I02676() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void L02677() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02700() { npc = (ib<<12)+core[58]; inh = 0;  }
void P02701() {  }
void I02702() {  }
void I02703() { core[(ib<<12)+core[52]] = 02704; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02704() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02705() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02706() { core[(ib<<12)+core[53]] = 02707; npc = (ib<<12)+core[53]+1; code[(ib<<12)+core[53]] = &emul8; inh = 0;  }
void I02707() { skp = 0; skp = !skp; npc += skp;  }
void I02710() { core[(ib<<12)+core[54]] = 02711; npc = (ib<<12)+core[54]+1; code[(ib<<12)+core[54]] = &emul8; inh = 0;  }
void I02711() { core[(ib<<12)+core[55]] = 02712; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I02712() { npc = 002677; inh = 0;  }
void I02713() { npc = (ib<<12)+core[1484]; inh = 0;  }
void P02714() { core[002600] = lac & 07777; lac &= 010000; code[002600] = &emul8;  }
void D02715() { if (++core[(df<<12)+core[1422]] == 010000) { core[(df<<12)+core[1422]] = 0; npc++; }; code[(df<<12)+core[1422]] = &emul8;  }
void D02716() { if (++core[(df<<12)+core[1449]] == 010000) { core[(df<<12)+core[1449]] = 0; npc++; }; code[(df<<12)+core[1449]] = &emul8;  }
void D02717() { if (++core[(df<<12)+core[1473]] == 010000) { core[(df<<12)+core[1473]] = 0; npc++; }; code[(df<<12)+core[1473]] = &emul8;  }
void S03000() { lac &= (010000|core[000000]);  }
void I03001() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I03002() { lac &= (010000|core[000040]);  }
void I03003() { lac ^= 07777;  }
void I03004() { lac &= (010000|core[000037]);  }
void I03005() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03006() { npc = (ib<<12)+core[1536]; inh = 0;  }
void I03007() { lac ^= 07777;  }
void I03010() { lac &= (010000|core[000037]);  }
void I03011() { lac ^= 07777;  }
void I03012() { lac &= (010000|core[000040]);  }
void I03013() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03014() { npc = (ib<<12)+core[1536]; inh = 0;  }
void I03015() { if (++core[003000] == 010000) { core[003000] = 0; npc++; }; code[003000] = &emul8;  }
void I03016() { npc = (ib<<12)+core[1536]; inh = 0;  }
void S03017() { lac &= (010000|core[000000]);  }
void I03020() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I03021() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03022() { lac ^= 07777;  }
void I03023() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void L03024() { lac ^= 07777;  }
void I03025() { lac &= (010000|core[000025]);  }
void I03026() { npc = (ib<<12)+core[1551]; inh = 0;  }
void S03027() { lac &= (010000|core[000000]);  }
void I03030() { lac &= 010000; lac |= swr;  }
void I03031() { lac &= (010000|core[000103]);  }
void I03032() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03033() { npc = (ib<<12)+core[1559]; inh = 0;  }
void I03034() { lac += core[000154];  }
void I03035() { hlt = 1;  }
void I03036() { npc = (ib<<12)+core[1559]; inh = 0;  }
void S03037() { lac &= (010000|core[000000]);  }
void I03040() { lac &= 010000; lac |= swr;  }
void I03041() { lac &= (010000|core[000104]);  }
void I03042() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I03043() { core[003056] = 03044; npc = 003056+1; code[003056] = &emul8; inh = 0;  }
void I03044() { if (++core[003037] == 010000) { core[003037] = 0; npc++; }; code[003037] = &emul8;  }
void I03045() { npc = (ib<<12)+core[1567]; inh = 0;  }
void S03046() { lac &= (010000|core[000000]);  }
void I03047() { lac &= 010000; lac |= swr;  }
void I03050() { lac &= (010000|core[000105]);  }
void I03051() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I03052() { npc = 003054; inh = 0;  }
void I03053() { npc = (ib<<12)+core[1574]; inh = 0;  }
void L03054() { if (++core[003046] == 010000) { core[003046] = 0; npc++; }; code[003046] = &emul8;  }
void I03055() { npc = (ib<<12)+core[1574]; inh = 0;  }
void S03056() { lac &= (010000|core[000000]);  }
void I03057() { core[(ib<<12)+core[38]] = 03060; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I03060() { npc = (ib<<12)+core[1636]; inh = 0;  }
void I03061() { lac += core[000037];  }
void I03062() { core[(ib<<12)+core[1595]] = 03063; npc = (ib<<12)+core[1595]+1; code[(ib<<12)+core[1595]] = &emul8; inh = 0;  }
void I03063() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I03064() { lac &= (010000|core[000025]);  }
void I03065() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I03066() { lac &= (010000|core[000026]);  }
void I03067() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I03070() { core[(ib<<12)+core[48]] = 03071; npc = (ib<<12)+core[48]+1; code[(ib<<12)+core[48]] = &emul8; inh = 0;  }
void I03071() { core[(ib<<12)+core[49]] = 03072; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I03072() { npc = (ib<<12)+core[1582]; inh = 0;  }
void P03073() { core[003027] = lac & 07777; lac &= 010000; code[003027] = &emul8;  }
void L03200() { lac &= 010000; lac &= 07777;  }
void I03201() { if (++core[000020] == 010000) { core[000020] = 0; npc++; }; code[000020] = &emul8;  }
void I03202() { npc = 003224; inh = 0;  }
void I03203() { lac &= 010000; lac |= swr;  }
void I03204() { lac &= (010000|core[000115]);  }
void I03205() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I03206() { npc = 003221; inh = 0;  }
void L03207() { lac &= 010000; lac |= swr;  }
void I03210() { lac &= (010000|core[000114]);  }
void I03211() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03212() { hlt = 1;  }
void I03213() { lac &= 010000; lac |= swr;  }
void I03214() { lac &= (010000|core[000116]);  }
void I03215() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03216() { npc = 003224; inh = 0;  }
void I03217() { npc = (ib<<12)+core[1680]; inh = 0;  }
void P03220() { core[(df<<12)+core[0]] = lac & 07777; lac &= 010000; code[(df<<12)+core[0]] = &emul8;  }
void L03221() { core[(ib<<12)+core[38]] = 03222; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I03222() { npc = (ib<<12)+core[1754]; inh = 0;  }
void I03223() { npc = 003207; inh = 0;  }
void L03224() { lac += core[000122];  }
void I03225() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I03226() { npc = (ib<<12)+core[108]; inh = 0;  }
void S03227() { lac &= (010000|core[000000]);  }
void I03230() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I03231() { lac += core[000037];  }
void I03232() { lac &= (010000|core[000172]);  }
void I03233() { core[003264] = lac & 07777; lac &= 010000; code[003264] = &emul8;  }
void I03234() { lac += core[000037];  }
void I03235() { lac = (lac<<2) + ((lac>>11)&3);  }
void I03236() { lac = (lac<<1) + ((lac>>12)&1);  }
void I03237() { lac &= (010000|core[003266]);  }
void I03240() { lac += core[003264];  }
void I03241() { lac += core[003267];  }
void I03242() { core[003264] = lac & 07777; lac &= 010000; code[003264] = &emul8;  }
void I03243() { lac += core[000037];  }
void I03244() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03245() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03246() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03247() { lac &= (010000|core[000172]);  }
void I03250() { core[003263] = lac & 07777; lac &= 010000; code[003263] = &emul8;  }
void I03251() { lac += core[000037];  }
void I03252() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03253() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03254() { lac &= (010000|core[003266]);  }
void I03255() { lac += core[003263];  }
void I03256() { lac += core[003267];  }
void I03257() { core[003263] = lac & 07777; lac &= 010000; code[003263] = &emul8;  }
void I03260() { core[(ib<<12)+core[38]] = 03261; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I03261() { core[003262] = lac & 07777; lac &= 010000; code[003262] = &emul8;  }
void D03262() { npc = (ib<<12)+core[1687]; inh = 0;  }
void D03263() { lac &= (010000|core[000000]);  }
void D03264() { lac &= (010000|core[000000]);  }
void I03265() { core[000000] = 03266; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void D03266() { lac &= (010000|core[(df<<12)+core[1728]]);  }
void D03267() { emul8();  }
void P03400() { lac &= 010000; lac &= 07777;  }
void I03401() { core[(ib<<12)+core[59]] = 03402; npc = (ib<<12)+core[59]+1; code[(ib<<12)+core[59]] = &emul8; inh = 0;  }
void L03402() { lac &= 010000; lac &= 07777;  }
void I03403() { lac += core[000041];  }
void I03404() { lac += core[000043];  }
void I03405() { lac += core[000043];  }
void I03406() { lac += core[000041];  }
void I03407() { lac += core[000041];  }
void I03410() { lac += core[000041];  }
void I03411() { lac += core[000043];  }
void I03412() { lac += core[000043];  }
void I03413() { lac += core[000041];  }
void I03414() { lac += core[000041];  }
void I03415() { lac += core[000043];  }
void I03416() { lac += core[000041];  }
void I03417() { lac += core[000043];  }
void I03420() { lac += core[000043];  }
void I03421() { lac += core[000041];  }
void I03422() { lac += core[000041];  }
void I03423() { lac += core[000043];  }
void I03424() { lac += core[000043];  }
void I03425() { lac += core[000043];  }
void I03426() { lac += core[000041];  }
void I03427() { lac += core[000043];  }
void I03430() { lac += core[000041];  }
void I03431() { lac += core[000041];  }
void I03432() { lac += core[000041];  }
void I03433() { lac += core[000043];  }
void I03434() { lac += core[000043];  }
void I03435() {  }
void I03436() { core[(ib<<12)+core[52]] = 03437; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I03437() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03440() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03441() { core[(ib<<12)+core[1830]] = 03442; npc = (ib<<12)+core[1830]+1; code[(ib<<12)+core[1830]] = &emul8; inh = 0;  }
void I03442() { core[(ib<<12)+core[55]] = 03443; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I03443() { npc = 003402; inh = 0;  }
void I03444() { npc = (ib<<12)+core[1829]; inh = 0;  }
void P03445() { core[(df<<12)+core[1792]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1792]] = &emul8;  }
void P03446() { core[(df<<12)+core[39]] = lac & 07777; lac &= 010000; code[(df<<12)+core[39]] = &emul8;  }
void S03447() { lac &= (010000|core[000000]);  }
void I03450() { lac &= 010000; lac |= swr;  }
void I03451() { lac &= (010000|core[000104]);  }
void I03452() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03453() { npc = 003502; inh = 0;  }
void I03454() { core[(ib<<12)+core[38]] = 03455; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I03455() { npc = (ib<<12)+core[117]; inh = 0;  }
void I03456() { core[(ib<<12)+core[38]] = 03457; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I03457() { npc = 003516; inh = 0;  }
void I03460() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I03461() { lac &= (010000|core[000041]);  }
void I03462() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I03463() { core[(ib<<12)+core[49]] = 03464; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I03464() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I03465() { lac &= (010000|core[000043]);  }
void I03466() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I03467() { core[(ib<<12)+core[49]] = 03470; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I03470() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I03471() { lac &= (010000|core[000025]);  }
void I03472() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I03473() { lac ^= 07777;  }
void I03474() { lac &= (010000|core[000026]);  }
void I03475() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I03476() { core[(ib<<12)+core[48]] = 03477; npc = (ib<<12)+core[48]+1; code[(ib<<12)+core[48]] = &emul8; inh = 0;  }
void I03477() { core[(ib<<12)+core[49]] = 03500; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I03500() { core[(ib<<12)+core[38]] = 03501; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I03501() { npc = (ib<<12)+core[1890]; inh = 0;  }
void L03502() { lac &= 010000; lac |= swr;  }
void I03503() { lac &= (010000|core[000103]);  }
void I03504() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03505() { npc = (ib<<12)+core[1831]; inh = 0;  }
void I03506() { lac &= 010000; lac &= 07777;  }
void I03507() { lac += core[003447];  }
void I03510() { hlt = 1;  }
void I03511() { npc = (ib<<12)+core[1831]; inh = 0;  }
void S03512() { lac &= (010000|core[000000]);  }
void I03513() { lac &= 010000; lac &= 07777;  }
void I03514() { lac += core[000041];  }
void I03515() { lac = (lac<<1) + ((lac>>12)&1);  }
void L03516() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03517() { lac += core[003542];  }
void I03520() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I03521() { lac += core[000041];  }
void I03522() { lac ^= 07777; lac++;  }
void I03523() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I03524() { lac &= 07777;  }
void I03525() { lac += core[003541];  }
void I03526() { lac = (lac<<1) + ((lac>>12)&1);  }
void I03527() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03530() { lac += core[003542];  }
void I03531() { core[003541] = lac & 07777; lac &= 010000; code[003541] = &emul8;  }
void I03532() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03533() { lac ^= 07777;  }
void I03534() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I03535() { lac += core[000044];  }
void I03536() { lac ^= 07777;  }
void I03537() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I03540() { npc = (ib<<12)+core[1866]; inh = 0;  }
void D03541() { lac &= (010000|core[000001]);  }
void P03542() { lac &= (010000|core[000003]);  }
void L03600() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I03601() { lac &= (010000|core[000041]);  }
void I03602() { core[003746] = lac & 07777; lac &= 010000; code[003746] = &emul8;  }
void I03603() { lac ^= 07777;  }
void I03604() { lac &= (010000|core[000041]);  }
void I03605() { lac ^= 07777;  }
void I03606() { core[003747] = lac & 07777; lac &= 010000; code[003747] = &emul8;  }
void I03607() { lac ^= 07777;  }
void I03610() { lac &= (010000|core[000103]);  }
void I03611() { core[003752] = lac & 07777; lac &= 010000; code[003752] = &emul8;  }
void L03612() { lac ^= 07777;  }
void I03613() { lac &= (010000|core[003752]);  }
void I03614() { lac ^= 07777;  }
void I03615() { core[003753] = lac & 07777; lac &= 010000; code[003753] = &emul8;  }
void I03616() { lac ^= 07777;  }
void I03617() { lac &= (010000|core[003746]);  }
void I03620() { lac &= (010000|core[003752]);  }
void I03621() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03622() { npc = 003632; inh = 0;  }
void I03623() { lac ^= 07777;  }
void I03624() { lac &= (010000|core[003746]);  }
void I03625() { core[003701] = 03626; npc = 003701+1; code[003701] = &emul8; inh = 0;  }
void I03626() { lac ^= 07777;  }
void I03627() { lac &= (010000|core[003747]);  }
void I03630() { core[003751] = lac & 07777; lac &= 010000; code[003751] = &emul8;  }
void I03631() { npc = 003640; inh = 0;  }
void L03632() { lac &= 010000; lac ^= 07777;  }
void I03633() { lac &= (010000|core[003747]);  }
void I03634() { core[003715] = 03635; npc = 003715+1; code[003715] = &emul8; inh = 0;  }
void I03635() { lac ^= 07777;  }
void I03636() { lac &= (010000|core[003746]);  }
void I03637() { core[003751] = lac & 07777; lac &= 010000; code[003751] = &emul8;  }
void L03640() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I03641() { lac &= (010000|core[003750]);  }
void I03642() { lac += core[003751];  }
void I03643() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03644() { lac++;  }
void I03645() { core[(ib<<12)+core[52]] = 03646; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I03646() { core[(ib<<12)+core[51]] = 03647; npc = (ib<<12)+core[51]+1; code[(ib<<12)+core[51]] = &emul8; inh = 0;  }
void I03647() { skp = 0; skp = !skp; npc += skp;  }
void I03650() { core[(ib<<12)+core[2030]] = 03651; npc = (ib<<12)+core[2030]+1; code[(ib<<12)+core[2030]] = &emul8; inh = 0;  }
void I03651() { core[(ib<<12)+core[55]] = 03652; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I03652() { npc = 003640; inh = 0;  }
void I03653() { npc = 003654; inh = 0;  }
void L03654() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I03655() { lac &= (010000|core[003751]);  }
void I03656() { lac += core[003750];  }
void I03657() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03660() { lac++;  }
void I03661() { core[(ib<<12)+core[52]] = 03662; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I03662() { core[(ib<<12)+core[51]] = 03663; npc = (ib<<12)+core[51]+1; code[(ib<<12)+core[51]] = &emul8; inh = 0;  }
void I03663() { skp = 0; skp = !skp; npc += skp;  }
void I03664() { core[(ib<<12)+core[2030]] = 03665; npc = (ib<<12)+core[2030]+1; code[(ib<<12)+core[2030]] = &emul8; inh = 0;  }
void I03665() { core[(ib<<12)+core[55]] = 03666; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I03666() { npc = 003654; inh = 0;  }
void I03667() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I03670() { lac &= (010000|core[003752]);  }
void I03671() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03672() { core[003752] = lac & 07777; lac &= 010000; code[003752] = &emul8;  }
void I03673() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03674() { npc = 003612; inh = 0;  }
void I03675() { core[(ib<<12)+core[55]] = 03676; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I03676() { npc = 003600; inh = 0;  }
void I03677() { npc = (ib<<12)+core[1984]; inh = 0;  }
void P03700() { core[003600] = 03701; npc = 003600+1; code[003600] = &emul8; inh = 0;  }
void S03701() { lac &= (010000|core[000000]);  }
void I03702() { lac &= (010000|core[003753]);  }
void I03703() { lac ^= 07777;  }
void I03704() { core[003754] = lac & 07777; lac &= 010000; code[003754] = &emul8;  }
void I03705() { lac ^= 07777;  }
void I03706() { lac &= (010000|core[003747]);  }
void I03707() { lac &= (010000|core[003752]);  }
void I03710() { lac ^= 07777;  }
void I03711() { lac &= (010000|core[003754]);  }
void I03712() { lac ^= 07777;  }
void I03713() { core[003750] = lac & 07777; lac &= 010000; code[003750] = &emul8;  }
void I03714() { npc = (ib<<12)+core[1985]; inh = 0;  }
void S03715() { lac &= (010000|core[000000]);  }
void I03716() { lac &= (010000|core[003752]);  }
void I03717() { lac ^= 07777;  }
void I03720() { core[003754] = lac & 07777; lac &= 010000; code[003754] = &emul8;  }
void I03721() { lac ^= 07777;  }
void I03722() { lac &= (010000|core[003746]);  }
void I03723() { lac &= (010000|core[003753]);  }
void I03724() { lac ^= 07777;  }
void I03725() { lac &= (010000|core[003754]);  }
void I03726() { core[003750] = lac & 07777; lac &= 010000; code[003750] = &emul8;  }
void I03727() { npc = (ib<<12)+core[1997]; inh = 0;  }
void S03730() { lac &= (010000|core[000000]);  }
void I03731() { lac ^= 07777;  }
void I03732() { core[003755] = lac & 07777; lac &= 010000; code[003755] = &emul8;  }
void I03733() { lac ^= 07777;  }
void I03734() { lac &= (010000|core[000025]);  }
void I03735() { lac &= (010000|core[003753]);  }
void D03736() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03737() { npc = 003744; inh = 0;  }
void I03740() { lac ^= 07777;  }
void I03741() { lac &= (010000|core[003752]);  }
void I03742() { lac &= (010000|core[003755]);  }
void I03743() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void L03744() { if (++core[003730] == 010000) { core[003730] = 0; npc++; }; code[003730] = &emul8;  }
void I03745() { npc = (ib<<12)+core[2008]; inh = 0;  }
void D03746() { lac &= (010000|core[000000]);  }
void D03747() { lac &= (010000|core[000000]);  }
void D03750() { lac &= (010000|core[000000]);  }
void D03751() { lac &= (010000|core[000000]);  }
void D03752() { lac &= (010000|core[000000]);  }
void D03753() { lac &= (010000|core[000000]);  }
void D03754() { lac &= (010000|core[000000]);  }
void D03755() { lac &= (010000|core[000000]);  }
void P03756() { core[000000] = 03757; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void S04000() { lac &= (010000|core[000000]);  }
void I04001() { lac &= 010000; lac |= swr;  }
void I04002() { lac &= (010000|core[000104]);  }
void I04003() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I04004() { npc = 004033; inh = 0;  }
void P04005() { core[(ib<<12)+core[38]] = 04006; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I04006() { npc = (ib<<12)+core[2053]; inh = 0;  }
void I04007() { core[(ib<<12)+core[38]] = 04010; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I04010() { npc = 004164; inh = 0;  }
void I04011() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I04012() { lac &= (010000|core[(df<<12)+core[2175]]);  }
void I04013() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I04014() { core[(ib<<12)+core[49]] = 04015; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I04015() { lac ^= 07777;  }
void I04016() { lac &= (010000|core[(df<<12)+core[2174]]);  }
void I04017() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I04020() { core[(ib<<12)+core[49]] = 04021; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I04021() { lac ^= 07777;  }
void D04022() { lac &= (010000|core[(df<<12)+core[2173]]);  }
void I04023() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void D04024() { core[(ib<<12)+core[49]] = 04025; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I04025() { lac ^= 07777;  }
void I04026() { lac &= (010000|core[000025]);  }
void I04027() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I04030() { core[(ib<<12)+core[49]] = 04031; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I04031() { core[(ib<<12)+core[38]] = 04032; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I04032() { npc = (ib<<12)+core[2146]; inh = 0;  }
void L04033() { lac &= 010000; lac |= swr;  }
void I04034() { lac &= (010000|core[000103]);  }
void I04035() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I04036() { npc = (ib<<12)+core[2048]; inh = 0;  }
void I04037() { lac &= 010000; lac &= 07777;  }
void D04040() { lac += core[004000];  }
void I04041() { hlt = 1;  }
void I04042() { npc = (ib<<12)+core[2048]; inh = 0;  }
void P04175() { core[(df<<12)+core[2154]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2154]] = &emul8;  }
void P04176() { core[(df<<12)+core[2153]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2153]] = &emul8;  }
void P04177() { core[(df<<12)+core[2152]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2152]] = &emul8;  }
void L04200() { lac &= 010000; lac &= 07777;  }
void I04201() { lac += core[000044];  }
void I04202() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04203() { lac &= 010000; lac ^= 010000;  }
void I04204() { lac += core[000041];  }
void I04205() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04206() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04207() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04210() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04211() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04212() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04213() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04214() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04215() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04216() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04217() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04220() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04221() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04222() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04223() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04224() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04225() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04226() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04227() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04230() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04231() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04232() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04233() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04234() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04235() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04236() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04237() {  }
void I04240() {  }
void I04241() { core[(ib<<12)+core[52]] = 04242; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I04242() { lac += core[000043];  }
void I04243() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I04244() { npc = 004250; inh = 0;  }
void I04245() { lac += core[000044];  }
void I04246() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I04247() { lac += core[000026];  }
void L04250() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I04251() { core[(ib<<12)+core[50]] = 04252; npc = (ib<<12)+core[50]+1; code[(ib<<12)+core[50]] = &emul8; inh = 0;  }
void I04252() { core[(ib<<12)+core[2269]] = 04253; npc = (ib<<12)+core[2269]+1; code[(ib<<12)+core[2269]] = &emul8; inh = 0;  }
void I04253() { core[(ib<<12)+core[55]] = 04254; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I04254() { npc = 004200; inh = 0;  }
void L04255() { lac &= 010000; lac &= 07777;  }
void I04256() { lac += core[000044];  }
void I04257() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04260() { lac &= 010000; lac ^= 010000;  }
void I04261() { lac += core[000041];  }
void I04262() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04263() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04264() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04265() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04266() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04267() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04270() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04271() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04272() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04273() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04274() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04275() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04276() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04277() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04300() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04301() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04302() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04303() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04304() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04305() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04306() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04307() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04310() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04311() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04312() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04313() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04314() {  }
void I04315() {  }
void I04316() { core[(ib<<12)+core[52]] = 04317; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I04317() { lac += core[000043];  }
void I04320() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04321() { npc = 004325; inh = 0;  }
void I04322() { lac += core[000044];  }
void I04323() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I04324() { lac += core[000026];  }
void L04325() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I04326() { core[(ib<<12)+core[50]] = 04327; npc = (ib<<12)+core[50]+1; code[(ib<<12)+core[50]] = &emul8; inh = 0;  }
void I04327() { core[(ib<<12)+core[2268]] = 04330; npc = (ib<<12)+core[2268]+1; code[(ib<<12)+core[2268]] = &emul8; inh = 0;  }
void I04330() { core[(ib<<12)+core[55]] = 04331; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I04331() { npc = 004255; inh = 0;  }
void I04332() { npc = (ib<<12)+core[2267]; inh = 0;  }
void P04333() { core[(ib<<12)+core[0]] = 04334; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void P04334() { npc = 000013; inh = 0;  }
void P04335() { npc = 000000; inh = 0;  }
void P04400() { lac &= 010000; lac &= 07777;  }
void I04401() { lac += core[000044];  }
void I04402() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04403() { lac &= 010000; lac ^= 010000;  }
void I04404() { lac += core[000041];  }
void I04405() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04406() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04407() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04410() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04411() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04412() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04413() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04414() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04415() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04416() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04417() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04420() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04421() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04422() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04423() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04424() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04425() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04426() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04427() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04430() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04431() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04432() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04433() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04434() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04435() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04436() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04437() {  }
void I04440() {  }
void I04441() { core[(ib<<12)+core[52]] = 04442; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I04442() { lac += core[000043];  }
void I04443() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04444() { npc = 004450; inh = 0;  }
void I04445() { lac += core[000044];  }
void L04446() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I04447() { lac += core[000026];  }
void L04450() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I04451() { core[(ib<<12)+core[50]] = 04452; npc = (ib<<12)+core[50]+1; code[(ib<<12)+core[50]] = &emul8; inh = 0;  }
void I04452() { core[(ib<<12)+core[2425]] = 04453; npc = (ib<<12)+core[2425]+1; code[(ib<<12)+core[2425]] = &emul8; inh = 0;  }
void I04453() { core[(ib<<12)+core[55]] = 04454; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I04454() { npc = 004400; inh = 0;  }
void L04455() { lac &= 010000; lac &= 07777;  }
void I04456() { lac += core[000044];  }
void I04457() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void L04460() { lac &= 010000; lac ^= 010000;  }
void I04461() { lac += core[000041];  }
void I04462() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04463() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04464() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04465() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04466() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04467() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04470() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04471() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04472() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04473() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04474() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04475() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04476() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04477() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04500() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04501() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04502() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04503() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04504() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04505() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04506() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04507() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04510() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04511() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04512() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04513() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04514() {  }
void I04515() {  }
void I04516() { core[(ib<<12)+core[52]] = 04517; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I04517() { lac += core[000043];  }
void I04520() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04521() { npc = 004525; inh = 0;  }
void I04522() { lac += core[000044];  }
void I04523() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I04524() { lac += core[000026];  }
void L04525() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I04526() { core[(ib<<12)+core[50]] = 04527; npc = (ib<<12)+core[50]+1; code[(ib<<12)+core[50]] = &emul8; inh = 0;  }
void I04527() { core[(ib<<12)+core[2424]] = 04530; npc = (ib<<12)+core[2424]+1; code[(ib<<12)+core[2424]] = &emul8; inh = 0;  }
void I04530() { core[(ib<<12)+core[55]] = 04531; npc = (ib<<12)+core[55]+1; code[(ib<<12)+core[55]] = &emul8; inh = 0;  }
void I04531() { npc = 004455; inh = 0;  }
void I04532() { if (++core[000020] == 010000) { core[000020] = 0; npc++; }; code[000020] = &emul8;  }
void I04533() { npc = 004566; inh = 0;  }
void I04534() { lac &= 010000; lac |= swr;  }
void P04535() { lac &= (010000|core[000115]);  }
void I04536() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04537() { npc = 004563; inh = 0;  }
void L04540() { lac &= 010000; lac |= swr;  }
void I04541() { lac &= (010000|core[000114]);  }
void I04542() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I04543() { hlt = 1;  }
void I04544() { lac &= 010000; lac |= swr;  }
void I04545() { lac &= (010000|core[000116]);  }
void I04546() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I04547() { npc = 004566; inh = 0;  }
void L04550() { lac &= 010000; lac |= swr;  }
void I04551() { lac &= (010000|core[000173]);  }
void I04552() { lac &= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04553() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04554() { core[000175] = lac & 07777; lac &= 010000; code[000175] = &emul8;  }
void I04555() { lac &= 010000; lac |= swr;  }
void I04556() { lac &= (010000|core[000107]);  }
void I04557() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I04560() { npc = (ib<<12)+core[2426]; inh = 0;  }
void I04561() { npc = (ib<<12)+core[2418]; inh = 0;  }
void P04562() { lac &= (010000|core[004400]);  }
void L04563() { core[(ib<<12)+core[38]] = 04564; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I04564() { npc = (ib<<12)+core[2397]; inh = 0;  }
void I04565() { npc = 004540; inh = 0;  }
void L04566() { npc = (ib<<12)+core[2423]; inh = 0;  }
void P04567() { core[(df<<12)+core[0]] = lac & 07777; lac &= 010000; code[(df<<12)+core[0]] = &emul8;  }
void P04570() { npc = 000026; inh = 0;  }
void P04571() { npc = 000041; inh = 0;  }
void P04572() { core[(ib<<12)+core[2304]] = 04573; npc = (ib<<12)+core[2304]+1; code[(ib<<12)+core[2304]] = &emul8; inh = 0;  }
void L04600() { core[004631] = 04601; npc = 004631+1; code[004631] = &emul8; inh = 0;  }
void I04601() { core[004664] = 04602; npc = 004664+1; code[004664] = &emul8; inh = 0;  }
void I04602() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I04603() { core[004741] = 04604; npc = 004741+1; code[004741] = &emul8; inh = 0;  }
void I04604() { core[004731] = 04605; npc = 004731+1; code[004731] = &emul8; inh = 0;  }
void I04605() { core[004752] = 04606; npc = 004752+1; code[004752] = &emul8; inh = 0;  }
void I04606() { core[(ib<<12)+core[38]] = 04607; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I04607() { npc = (ib<<12)+core[2541]; inh = 0;  }
void I04610() { core[004760] = 04611; npc = 004760+1; code[004760] = &emul8; inh = 0;  }
void I04611() { core[004731] = 04612; npc = 004731+1; code[004731] = &emul8; inh = 0;  }
void D04612() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I04613() { core[004741] = 04614; npc = 004741+1; code[004741] = &emul8; inh = 0;  }
void I04614() { lac += core[000175];  }
void D04615() { lac ^= 07777; lac++;  }
void I04616() { lac += core[000174];  }
void I04617() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04620() { npc = 004623; inh = 0;  }
void I04621() { lac &= 010000; hlt = 1;  }
void I04622() { npc = (ib<<12)+core[2552]; inh = 0;  }
void L04623() { lac += core[004714];  }
void I04624() { lac += core[000115];  }
void I04625() { core[004626] = lac & 07777; lac &= 010000; code[004626] = &emul8;  }
void D04626() { lac &= (010000|core[000000]);  }
void I04627() { npc = (ib<<12)+core[2456]; inh = 0;  }
void P04630() { lac &= (010000|core[004600]);  }
void S04631() { lac &= (010000|core[000000]);  }
void I04632() { lac &= 010000; lac &= 07777;  }
void I04633() { core[000174] = lac & 07777; lac &= 010000; code[000174] = &emul8;  }
void I04634() { lac += core[004771];  }
void I04635() { core[000176] = lac & 07777; lac &= 010000; code[000176] = &emul8;  }
void I04636() { emul8();  }
void I04637() { core[(df<<12)+core[121]] = lac & 07777; lac &= 010000; code[(df<<12)+core[121]] = &emul8;  }
void I04640() { lac += core[004772];  }
void L04641() { lac += core[000113];  }
void I04642() { core[004643] = lac & 07777; lac &= 010000; code[004643] = &emul8;  }
void D04643() { lac &= (010000|core[000000]);  }
void I04644() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I04645() { core[(df<<12)+core[121]] = lac & 07777; lac &= 010000; code[(df<<12)+core[121]] = &emul8;  }
void I04646() { lac += core[(df<<12)+core[121]];  }
void I04647() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04650() { npc = 004655; inh = 0;  }
void I04651() { if (++core[000174] == 010000) { core[000174] = 0; npc++; }; code[000174] = &emul8;  }
void D04652() { lac += core[004643];  }
void I04653() { if (++core[000176] == 010000) { core[000176] = 0; npc++; }; code[000176] = &emul8;  }
void I04654() { npc = 004641; inh = 0;  }
void L04655() { lac &= 010000; lac &= 07777;  }
void I04656() { emul8();  }
void I04657() { lac += core[(df<<12)+core[121]];  }
void I04660() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04661() { npc = (ib<<12)+core[2457]; inh = 0;  }
void I04662() { lac &= 010000; hlt = 1;  }
void I04663() { npc = 004674; inh = 0;  }
void S04664() { lac &= (010000|core[000000]);  }
void I04665() { lac &= 010000; lac &= 07777;  }
void I04666() { core[000176] = lac & 07777; lac &= 010000; code[000176] = &emul8;  }
void I04667() { emul8();  }
void I04670() { lac += core[000113];  }
void I04671() { lac &= (010000|core[004775]);  }
void I04672() { core[004712] = lac & 07777; lac &= 010000; code[004712] = &emul8;  }
void I04673() { lac &= 010000; lac &= 07777; lac++;  }
void L04674() { lac += core[000174];  }
void I04675() { lac = (lac<<1) + ((lac>>12)&1);  }
void I04676() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04677() { lac ^= 07777; lac++;  }
void I04700() { lac += core[004712];  }
void I04701() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04702() { lac += core[004712];  }
void I04703() { lac += core[004772];  }
void I04704() { core[004714] = lac & 07777; lac &= 010000; code[004714] = &emul8;  }
void I04705() { emul8();  }
void I04706() { lac += core[004772];  }
void I04707() { core[004712] = lac & 07777; lac &= 010000; code[004712] = &emul8;  }
void I04710() { lac += core[004712];  }
void I04711() { core[004717] = lac & 07777; lac &= 010000; code[004717] = &emul8;  }
void L04712() { lac &= (010000|core[000000]);  }
void I04713() { lac += core[(df<<12)+core[126]];  }
void D04714() { lac &= (010000|core[000000]);  }
void I04715() { core[(df<<12)+core[126]] = lac & 07777; lac &= 010000; code[(df<<12)+core[126]] = &emul8;  }
void I04716() { lac += core[(df<<12)+core[126]];  }
void D04717() { lac &= (010000|core[000000]);  }
void I04720() { lac ^= 07777; lac++;  }
void I04721() { lac += core[(df<<12)+core[126]];  }
void I04722() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04723() { npc = 004726; inh = 0;  }
void I04724() { lac &= 010000; hlt = 1;  }
void I04725() { npc = 004712; inh = 0;  }
void L04726() { if (++core[000176] == 010000) { core[000176] = 0; npc++; }; code[000176] = &emul8;  }
void I04727() { npc = 004712; inh = 0;  }
void I04730() { npc = (ib<<12)+core[2484]; inh = 0;  }
void S04731() { lac &= (010000|core[000000]);  }
void I04732() { lac += core[004771];  }
void I04733() { core[000176] = lac & 07777; lac &= 010000; code[000176] = &emul8;  }
void L04734() { lac += core[004776];  }
void I04735() { core[(ib<<12)+core[39]] = 04736; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I04736() { if (++core[000176] == 010000) { core[000176] = 0; npc++; }; code[000176] = &emul8;  }
void I04737() { npc = 004734; inh = 0;  }
void I04740() { npc = (ib<<12)+core[2521]; inh = 0;  }
void S04741() { lac &= (010000|core[000000]);  }
void I04742() { core[000176] = lac & 07777; lac &= 010000; code[000176] = &emul8;  }
void L04743() { lac += core[004774];  }
void I04744() { core[(ib<<12)+core[39]] = 04745; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I04745() { lac += core[004773];  }
void I04746() { core[(ib<<12)+core[39]] = 04747; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I04747() { if (++core[000176] == 010000) { core[000176] = 0; npc++; }; code[000176] = &emul8;  }
void I04750() { npc = 004743; inh = 0;  }
void I04751() { npc = (ib<<12)+core[2529]; inh = 0;  }
void S04752() { lac &= (010000|core[000000]);  }
void I04753() { lac += core[000174];  }
void I04754() { lac &= (010000|core[000172]);  }
void P04755() { lac += core[000077];  }
void I04756() { core[(ib<<12)+core[39]] = 04757; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I04757() { npc = (ib<<12)+core[2538]; inh = 0;  }
void S04760() { lac &= (010000|core[000000]);  }
void I04761() { lac += core[004714];  }
void I04762() { lac &= (010000|core[000173]);  }
void I04763() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04764() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04765() { lac += core[000077];  }
void I04766() { core[(ib<<12)+core[39]] = 04767; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void I04767() { npc = (ib<<12)+core[2544]; inh = 0;  }
void P04770() { core[(ib<<12)+core[104]] = 04771; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void D04771() { emul8();  }
void D04772() { emul8();  }
void D04773() { lac &= (010000|core[004612]);  }
void D04774() { lac &= (010000|core[004615]);  }
void D04775() { lac &= (010000|core[000170]);  }
void D04776() { lac &= (010000|core[004652]);  }
void D05000() { lac &= (010000|core[000000]);  }
void L05001() { lac &= 010000; lac |= swr;  }
void I05002() { lac &= (010000|core[000104]);  }
void I05003() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05004() { npc = 005010; inh = 0;  }
void I05005() { core[(ib<<12)+core[38]] = 05006; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I05006() { npc = (ib<<12)+core[2581]; inh = 0;  }
void I05007() { core[005064] = 05010; npc = 005064+1; code[005064] = &emul8; inh = 0;  }
void L05010() { lac &= 010000; lac &= 07777;  }
void I05011() { lac += core[005000];  }
void I05012() { npc = 005053; inh = 0;  }
void D05013() { lac &= (010000|core[000000]);  }
void I05014() { lac &= 010000; lac |= swr;  }
void I05015() { lac &= (010000|core[000104]);  }
void I05016() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05017() { npc = 005023; inh = 0;  }
void I05020() { core[(ib<<12)+core[38]] = 05021; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I05021() { npc = (ib<<12)+core[2596]; inh = 0;  }
void I05022() { core[005064] = 05023; npc = 005064+1; code[005064] = &emul8; inh = 0;  }
void L05023() { lac &= 010000; lac &= 07777;  }
void I05024() { lac += core[005013];  }
void P05025() { npc = 005053; inh = 0;  }
void D05026() { lac &= (010000|core[000000]);  }
void I05027() { lac &= 010000; lac |= swr;  }
void I05030() { lac &= (010000|core[000104]);  }
void I05031() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05032() { npc = 005036; inh = 0;  }
void I05033() { core[(ib<<12)+core[38]] = 05034; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I05034() { npc = (ib<<12)+core[2611]; inh = 0;  }
void I05035() { core[005064] = 05036; npc = 005064+1; code[005064] = &emul8; inh = 0;  }
void L05036() { lac &= 010000; lac &= 07777;  }
void I05037() { lac += core[005026];  }
void I05040() { npc = 005053; inh = 0;  }
void D05041() { lac &= (010000|core[000000]);  }
void I05042() { lac &= 010000; lac |= swr;  }
void I05043() { lac &= (010000|core[000104]);  }
void P05044() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05045() { npc = 005051; inh = 0;  }
void I05046() { core[(ib<<12)+core[38]] = 05047; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I05047() { npc = (ib<<12)+core[2626]; inh = 0;  }
void I05050() { core[005064] = 05051; npc = 005064+1; code[005064] = &emul8; inh = 0;  }
void L05051() { lac &= 010000; lac &= 07777;  }
void I05052() { lac += core[005041];  }
void L05053() { core[005063] = lac & 07777; lac &= 010000; code[005063] = &emul8;  }
void I05054() { lac &= 010000; lac |= swr;  }
void I05055() { lac &= (010000|core[000103]);  }
void I05056() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05057() { npc = 005062; inh = 0;  }
void I05060() { lac += core[005063];  }
void I05061() { hlt = 1;  }
void L05062() { npc = (ib<<12)+core[2611]; inh = 0;  }
void P05063() { lac &= (010000|core[000000]);  }
void S05064() { lac &= (010000|core[000000]);  }
void I05065() { core[(ib<<12)+core[38]] = 05066; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I05066() { npc = 005147; inh = 0;  }
void I05067() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I05070() { lac &= (010000|core[000044]);  }
void I05071() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I05072() { lac ^= 07777;  }
void I05073() { lac &= (010000|core[000041]);  }
void I05074() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I05075() { core[(ib<<12)+core[48]] = 05076; npc = (ib<<12)+core[48]+1; code[(ib<<12)+core[48]] = &emul8; inh = 0;  }
void I05076() { core[(ib<<12)+core[49]] = 05077; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I05077() { lac ^= 07777;  }
void I05100() { lac &= (010000|core[000026]);  }
void I05101() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void P05102() { core[(ib<<12)+core[48]] = 05103; npc = (ib<<12)+core[48]+1; code[(ib<<12)+core[48]] = &emul8; inh = 0;  }
void I05103() { lac ^= 07777;  }
void I05104() { lac &= (010000|core[000025]);  }
void I05105() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I05106() { core[(ib<<12)+core[49]] = 05107; npc = (ib<<12)+core[49]+1; code[(ib<<12)+core[49]] = &emul8; inh = 0;  }
void I05107() { core[(ib<<12)+core[38]] = 05110; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void I05110() { npc = (ib<<12)+core[2658]; inh = 0;  }
void I05111() { npc = (ib<<12)+core[2612]; inh = 0;  }
void P05200() { core[(df<<12)+core[2782]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2782]] = &emul8;  }
void P05201() { core[000040] = 05202; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05202() { core[000001] = 05203; npc = 000001+1; code[000001] = &emul8; inh = 0;  }
void I05203() { if (++core[005207] == 010000) { core[005207] = 0; npc++; }; code[005207] = &emul8;  }
void P05204() { emul8();  }
void D05205() { core[000040] = 05206; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05206() { core[000040] = 05207; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void D05207() { core[000040] = 05210; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05210() { core[000040] = 05211; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void D05211() { lac &= (010000|core[000122]);  }
void I05212() { lac &= (010000|core[(df<<12)+core[2802]]);  }
void I05213() { core[000040] = 05214; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05214() { core[000040] = 05215; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05215() { core[000040] = 05216; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void D05216() { core[000040] = 05217; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05217() { core[000023] = 05220; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I05220() { lac += core[000115];  }
void I05221() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I05222() { lac &= (010000|core[000124]);  }
void I05223() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05224() { core[000040] = 05225; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05225() { core[000040] = 05226; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05226() { core[000040] = 05227; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05227() { core[000001] = 05230; npc = 000001+1; code[000001] = &emul8; inh = 0;  }
void I05230() { if (++core[005207] == 010000) { core[005207] = 0; npc++; }; code[005207] = &emul8;  }
void I05231() { emul8();  }
void I05232() { lac &= (010000|core[000122]);  }
void I05233() { lac &= (010000|core[(df<<12)+core[2802]]);  }
void I05234() { core[000040] = 05235; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05235() { core[000040] = 05236; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05236() { core[000001] = 05237; npc = 000001+1; code[000001] = &emul8; inh = 0;  }
void I05237() { if (++core[005207] == 010000) { core[005207] = 0; npc++; }; code[005207] = &emul8;  }
void I05240() { emul8();  }
void I05241() { lac &= (010000|core[000122]);  }
void I05242() { lac &= (010000|core[(df<<12)+core[2801]]);  }
void I05243() { core[(df<<12)+core[2782]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2782]] = &emul8;  }
void I05244() { lac &= (010000|core[000000]);  }
void I05245() { core[(df<<12)+core[2782]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2782]] = &emul8;  }
void I05246() { core[000040] = 05247; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05247() { core[000040] = 05250; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05250() { core[000017] = 05251; npc = 000017+1; code[000017] = &emul8; inh = 0;  }
void I05251() { if (++core[005211] == 010000) { core[005211] = 0; npc++; }; code[005211] = &emul8;  }
void I05252() { lac &= (010000|core[(df<<12)+core[2761]]);  }
void L05253() { lac += core[(df<<12)+core[2689]];  }
void I05254() { lac += core[(df<<12)+core[32]];  }
void I05255() { core[000040] = 05256; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05256() { core[000040] = 05257; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05257() { core[000023] = 05260; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I05260() { lac += core[000115];  }
void I05261() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I05262() { lac &= (010000|core[000124]);  }
void I05263() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05264() { core[000040] = 05265; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05265() { core[000040] = 05266; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05266() { core[000040] = 05267; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05267() { core[000001] = 05270; npc = 000001+1; code[000001] = &emul8; inh = 0;  }
void I05270() { lac &= (010000|core[005324]);  }
void I05271() { if (++core[(df<<12)+core[65]] == 010000) { core[(df<<12)+core[65]] = 0; npc++; }; code[(df<<12)+core[65]] = &emul8;  }
void I05272() { lac += core[(df<<12)+core[31]];  }
void I05273() { core[(df<<12)+core[2688]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2688]] = &emul8;  }
void I05274() { core[(df<<12)+core[2782]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2782]] = &emul8;  }
void I05275() { if (++core[005201] == 010000) { core[005201] = 0; npc++; }; code[005201] = &emul8;  }
void I05276() { lac += core[(df<<12)+core[2692]];  }
void I05277() { lac &= (010000|core[000140]);  }
void I05300() { core[000040] = 05301; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05301() { core[000040] = 05302; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05302() { core[000040] = 05303; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05303() { core[000022] = 05304; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05304() { lac &= (010000|core[000116]);  }
void I05305() { lac &= (010000|core[(df<<12)+core[3]]);  }
void I05306() { core[000040] = 05307; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05307() { core[000040] = 05310; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05310() { core[000040] = 05311; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void P05311() { core[000040] = 05312; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05312() { if (++core[005205] == 010000) { core[005205] = 0; npc++; }; code[005205] = &emul8;  }
void I05313() { if (++core[005325] == 010000) { core[005325] = 0; npc++; }; code[005325] = &emul8;  }
void I05314() { lac += core[(df<<12)+core[20]];  }
void I05315() { core[(df<<12)+core[2782]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2782]] = &emul8;  }
void I05316() { lac &= (010000|core[000000]);  }
void I05317() { core[(df<<12)+core[2782]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2782]] = &emul8;  }
void I05320() { if (++core[005201] == 010000) { core[005201] = 0; npc++; }; code[005201] = &emul8;  }
void I05321() { lac += core[(df<<12)+core[2692]];  }
void P05322() { lac &= (010000|core[000140]);  }
void I05323() { core[000040] = 05324; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void D05324() { core[000040] = 05325; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void D05325() { core[000040] = 05326; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05326() { core[000002] = 05327; npc = 000002+1; code[000002] = &emul8; inh = 0;  }
void I05327() { if (++core[000017] == 010000) { core[000017] = 0; npc++; }; code[000017] = &emul8;  }
void I05330() { if (++core[005340] == 010000) { core[005340] = 0; npc++; }; code[005340] = &emul8;  }
void I05331() { core[000040] = 05332; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05332() { core[000040] = 05333; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05333() { core[000040] = 05334; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05334() { core[000040] = 05335; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05335() { lac &= (010000|core[005216]);  }
void P05336() { lac &= (010000|core[(df<<12)+core[71]]);  }
void I05337() { core[000040] = 05340; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void D05340() { core[000040] = 05341; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05341() { core[000040] = 05342; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05342() { core[000040] = 05343; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05343() { core[000022] = 05344; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05344() { lac &= (010000|core[(df<<12)+core[83]]);  }
void I05345() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I05346() { if (++core[(df<<12)+core[31]] == 010000) { core[(df<<12)+core[31]] = 0; npc++; }; code[(df<<12)+core[31]] = &emul8;  }
void I05347() { core[(df<<12)+core[2688]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2688]] = &emul8;  }
void I05350() { core[(df<<12)+core[2782]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2782]] = &emul8;  }
void I05351() { lac += core[(df<<12)+core[2770]];  }
void I05352() { lac += core[000107];  }
void I05353() { lac += core[000116];  }
void I05354() { lac &= (010000|core[000114]);  }
void I05355() { core[000040] = 05356; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05356() { core[000040] = 05357; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05357() { core[000040] = 05360; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05360() { lac &= (010000|core[000103]);  }
void P05361() { if (++core[(df<<12)+core[21]] == 010000) { core[(df<<12)+core[21]] = 0; npc++; }; code[(df<<12)+core[21]] = &emul8;  }
void P05362() { lac &= (010000|core[000114]);  }
void I05363() { core[(df<<12)+core[2782]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2782]] = &emul8;  }
void I05364() { lac &= (010000|core[000000]);  }
void I05365() { core[(df<<12)+core[2782]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2782]] = &emul8;  }
void I05366() { core[000040] = 05367; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05367() { core[000040] = 05370; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05370() { lac &= (010000|core[000122]);  }
void I05371() { lac &= (010000|core[(df<<12)+core[2801]]);  }
void I05372() { core[000040] = 05373; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05373() { core[000040] = 05374; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05374() { core[000040] = 05375; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05375() { core[000040] = 05376; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05376() { core[000001] = 05377; npc = 000001+1; code[000001] = &emul8; inh = 0;  }
void I05377() { if (++core[005207] == 010000) { core[005207] = 0; npc++; }; code[005207] = &emul8;  }
void I05400() { emul8();  }
void P05401() { core[000040] = 05402; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05402() { core[000040] = 05403; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05403() { core[000040] = 05404; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void D05404() { lac &= (010000|core[(df<<12)+core[88]]);  }
void I05405() { if (++core[000005] == 010000) { core[000005] = 0; npc++; }; code[000005] = &emul8;  }
void I05406() { lac &= (010000|core[005524]);  }
void I05407() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05410() { core[000040] = 05411; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05411() { core[000040] = 05412; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05412() { core[000040] = 05413; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05413() { lac &= (010000|core[000103]);  }
void I05414() { if (++core[(df<<12)+core[21]] == 010000) { core[(df<<12)+core[21]] = 0; npc++; }; code[(df<<12)+core[21]] = &emul8;  }
void I05415() { lac &= (010000|core[000114]);  }
void I05416() { core[(df<<12)+core[2910]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2910]] = &emul8;  }
void I05417() { lac &= (010000|core[000000]);  }
void I05420() { core[(df<<12)+core[2910]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2910]] = &emul8;  }
void I05421() { core[000040] = 05422; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05422() { core[000040] = 05423; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05423() { core[000023] = 05424; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I05424() { lac += core[000115];  }
void I05425() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I05426() { lac &= (010000|core[000124]);  }
void I05427() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05430() { core[000001] = 05431; npc = 000001+1; code[000001] = &emul8; inh = 0;  }
void I05431() { lac &= (010000|core[(df<<12)+core[4]]);  }
void I05432() { core[000024] = 05433; npc = 000024+1; code[000024] = &emul8; inh = 0;  }
void I05433() { lac &= (010000|core[(df<<12)+core[83]]);  }
void I05434() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I05435() { lac &= (010000|core[(df<<12)+core[2817]]);  }
void I05436() { lac += core[000114];  }
void I05437() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05440() { lac &= (010000|core[000000]);  }
void I05441() { core[(df<<12)+core[2910]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2910]] = &emul8;  }
void I05442() { core[000040] = 05443; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05443() { core[000040] = 05444; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05444() { core[000023] = 05445; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I05445() { lac += core[000115];  }
void I05446() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I05447() { lac &= (010000|core[000124]);  }
void I05450() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05451() { core[000022] = 05452; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05452() { lac &= (010000|core[000114]);  }
void I05453() { core[000024] = 05454; npc = 000024+1; code[000024] = &emul8; inh = 0;  }
void I05454() { lac &= (010000|core[(df<<12)+core[83]]);  }
void I05455() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I05456() { lac &= (010000|core[(df<<12)+core[2817]]);  }
void I05457() { lac += core[000114];  }
void I05460() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05461() { lac &= (010000|core[000000]);  }
void I05462() { core[(df<<12)+core[2910]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2910]] = &emul8;  }
void I05463() { core[000040] = 05464; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05464() { core[000040] = 05465; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05465() { core[000023] = 05466; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I05466() { lac += core[000115];  }
void I05467() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I05470() { lac &= (010000|core[000124]);  }
void I05471() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05472() { core[000022] = 05473; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05473() { lac &= (010000|core[000122]);  }
void I05474() { core[000024] = 05475; npc = 000024+1; code[000024] = &emul8; inh = 0;  }
void I05475() { lac &= (010000|core[(df<<12)+core[83]]);  }
void I05476() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I05477() { lac &= (010000|core[(df<<12)+core[2817]]);  }
void I05500() { lac += core[000114];  }
void I05501() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05502() { lac &= (010000|core[000000]);  }
void I05503() { core[(df<<12)+core[2910]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2910]] = &emul8;  }
void I05504() { core[000040] = 05505; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05505() { core[000040] = 05506; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05506() { core[000023] = 05507; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I05507() { lac += core[000115];  }
void I05510() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I05511() { lac &= (010000|core[000124]);  }
void I05512() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05513() { core[000022] = 05514; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05514() { if (++core[000014] == 010000) core[000014] = 0000;if (++core[(df<<12)+core[000014]] == 010000) { core[(df<<12)+core[000014]] = 0; npc++; }; code[(df<<12)+core[000014]] = &emul8;  }
void I05515() { core[000024] = 05516; npc = 000024+1; code[000024] = &emul8; inh = 0;  }
void I05516() { lac &= (010000|core[(df<<12)+core[83]]);  }
void I05517() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I05520() { lac &= (010000|core[(df<<12)+core[2817]]);  }
void I05521() { lac += core[000114];  }
void I05522() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05523() { lac &= (010000|core[000000]);  }
void D05524() { core[(df<<12)+core[2910]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2910]] = &emul8;  }
void I05525() { core[000040] = 05526; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05526() { core[000040] = 05527; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void D05527() { core[000023] = 05530; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I05530() { lac += core[000115];  }
void I05531() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I05532() { lac &= (010000|core[000124]);  }
void I05533() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05534() { core[000022] = 05535; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05535() { if (++core[(df<<12)+core[18]] == 010000) { core[(df<<12)+core[18]] = 0; npc++; }; code[(df<<12)+core[18]] = &emul8;  }
void P05536() { core[000024] = 05537; npc = 000024+1; code[000024] = &emul8; inh = 0;  }
void I05537() { lac &= (010000|core[(df<<12)+core[83]]);  }
void I05540() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I05541() { lac &= (010000|core[(df<<12)+core[2817]]);  }
void I05542() { lac += core[000114];  }
void I05543() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05544() { lac &= (010000|core[000000]);  }
void I05545() { core[(df<<12)+core[2910]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2910]] = &emul8;  }
void I05546() { core[000040] = 05547; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05547() { core[000040] = 05550; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05550() { core[000023] = 05551; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I05551() { lac += core[000115];  }
void I05552() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I05553() { lac &= (010000|core[000124]);  }
void I05554() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05555() { core[000002] = 05556; npc = 000002+1; code[000002] = &emul8; inh = 0;  }
void I05556() { if (++core[005527] == 010000) { core[005527] = 0; npc++; }; code[005527] = &emul8;  }
void I05557() { core[000024] = 05560; npc = 000024+1; code[000024] = &emul8; inh = 0;  }
void I05560() { lac &= (010000|core[(df<<12)+core[83]]);  }
void I05561() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I05562() { lac &= (010000|core[(df<<12)+core[2817]]);  }
void I05563() { lac += core[000114];  }
void I05564() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I05565() { lac &= (010000|core[000000]);  }
void I05566() { core[(df<<12)+core[2910]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2910]] = &emul8;  }
void I05567() { core[000040] = 05570; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05570() { core[000040] = 05571; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05571() { core[000022] = 05572; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05572() { lac &= (010000|core[000116]);  }
void I05573() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I05574() { lac += core[(df<<12)+core[96]];  }
void I05575() { lac &= (010000|core[000104]);  }
void I05576() { lac &= (010000|core[(df<<12)+core[32]]);  }
void I05577() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void P05600() { if (++core[005724] == 010000) { core[005724] = 0; npc++; }; code[005724] = &emul8;  }
void D05601() { core[000061] = 05602; npc = 000061+1; code[000061] = &emul8; inh = 0;  }
void I05602() { core[000006] = 05603; npc = 000006+1; code[000006] = &emul8; inh = 0;  }
void P05603() { lac &= (010000|core[000111]);  }
void P05604() { lac += core[(df<<12)+core[5]];  }
void I05605() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I05606() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05607() { core[000040] = 05610; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05610() { core[000040] = 05611; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05611() { core[000022] = 05612; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05612() { lac &= (010000|core[000116]);  }
void P05613() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I05614() { lac += core[(df<<12)+core[96]];  }
void I05615() { lac &= (010000|core[000104]);  }
void I05616() { lac &= (010000|core[(df<<12)+core[32]]);  }
void D05617() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void I05620() { if (++core[005724] == 010000) { core[005724] = 0; npc++; }; code[005724] = &emul8;  }
void I05621() { core[000062] = 05622; npc = 000062+1; code[000062] = &emul8; inh = 0;  }
void I05622() { core[000006] = 05623; npc = 000006+1; code[000006] = &emul8; inh = 0;  }
void I05623() { lac &= (010000|core[000111]);  }
void D05624() { lac += core[(df<<12)+core[5]];  }
void I05625() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I05626() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05627() { core[000040] = 05630; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05630() { core[000040] = 05631; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05631() { core[000022] = 05632; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05632() { lac &= (010000|core[000116]);  }
void I05633() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I05634() { lac += core[(df<<12)+core[96]];  }
void I05635() { if (++core[005601] == 010000) { core[005601] = 0; npc++; }; code[005601] = &emul8;  }
void I05636() { if (++core[005640] == 010000) { core[005640] = 0; npc++; }; code[005640] = &emul8;  }
void D05637() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void D05640() { if (++core[005724] == 010000) { core[005724] = 0; npc++; }; code[005724] = &emul8;  }
void I05641() { core[000006] = 05642; npc = 000006+1; code[000006] = &emul8; inh = 0;  }
void I05642() { lac &= (010000|core[000111]);  }
void I05643() { lac += core[(df<<12)+core[5]];  }
void I05644() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I05645() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05646() { core[000040] = 05647; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05647() { core[000040] = 05650; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05650() { core[000022] = 05651; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05651() { lac &= (010000|core[000116]);  }
void I05652() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I05653() { lac += core[(df<<12)+core[96]];  }
void I05654() { if (++core[005601] == 010000) { core[005601] = 0; npc++; }; code[005601] = &emul8;  }
void I05655() { lac += core[(df<<12)+core[32]];  }
void I05656() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void I05657() { if (++core[005724] == 010000) { core[005724] = 0; npc++; }; code[005724] = &emul8;  }
void I05660() { core[000006] = 05661; npc = 000006+1; code[000006] = &emul8; inh = 0;  }
void I05661() { lac &= (010000|core[000111]);  }
void I05662() { lac += core[(df<<12)+core[5]];  }
void I05663() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I05664() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05665() { core[000040] = 05666; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05666() { core[000040] = 05667; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05667() { core[000022] = 05670; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05670() { lac &= (010000|core[000116]);  }
void I05671() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I05672() { lac += core[(df<<12)+core[96]];  }
void I05673() { if (++core[005624] == 010000) { core[005624] = 0; npc++; }; code[005624] = &emul8;  }
void I05674() { lac += core[(df<<12)+core[32]];  }
void I05675() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void I05676() { if (++core[005724] == 010000) { core[005724] = 0; npc++; }; code[005724] = &emul8;  }
void I05677() { core[000006] = 05700; npc = 000006+1; code[000006] = &emul8; inh = 0;  }
void I05700() { lac &= (010000|core[000111]);  }
void I05701() { lac += core[(df<<12)+core[5]];  }
void I05702() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I05703() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05704() { core[000040] = 05705; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I05705() { core[000040] = 05706; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void P05706() { core[000022] = 05707; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I05707() { lac &= (010000|core[000116]);  }
void I05710() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void D05711() { lac += core[(df<<12)+core[96]];  }
void I05712() { if (++core[005624] == 010000) { core[005624] = 0; npc++; }; code[005624] = &emul8;  }
void I05713() { if (++core[005640] == 010000) { core[005640] = 0; npc++; }; code[005640] = &emul8;  }
void I05714() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void P05715() { if (++core[005724] == 010000) { core[005724] = 0; npc++; }; code[005724] = &emul8;  }
void I05716() { core[000006] = 05717; npc = 000006+1; code[000006] = &emul8; inh = 0;  }
void I05717() { lac &= (010000|core[000111]);  }
void I05720() { lac += core[(df<<12)+core[5]];  }
void I05721() { lac &= (010000|core[(df<<12)+core[0]]);  }
void P05722() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05723() { if (++core[005711] == 010000) { core[005711] = 0; npc++; }; code[005711] = &emul8;  }
void P05724() { lac += core[(df<<12)+core[65]];  }
void I05725() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I05726() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05727() { if (++core[005711] == 010000) { core[005711] = 0; npc++; }; code[005711] = &emul8;  }
void I05730() { lac += core[(df<<12)+core[82]];  }
void I05731() { lac += core[(df<<12)+core[3028]];  }
void I05732() { lac &= (010000|core[000000]);  }
void I05733() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05734() { lac &= (010000|core[(df<<12)+core[2947]]);  }
void I05735() { if (++core[(df<<12)+core[0]] == 010000) { core[(df<<12)+core[0]] = 0; npc++; }; code[(df<<12)+core[0]] = &emul8;  }
void P05736() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05737() { if (++core[005601] == 010000) { core[005601] = 0; npc++; }; code[005601] = &emul8;  }
void D05740() { lac += core[(df<<12)+core[2948]];  }
void I05741() { lac += core[(df<<12)+core[3021]];  }
void I05742() { lac &= (010000|core[000000]);  }
void I05743() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05744() { lac &= (010000|core[000000]);  }
void I05745() { core[(df<<12)+core[3038]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3038]] = &emul8;  }
void I05746() { core[000004] = 05747; npc = 000004+1; code[000004] = &emul8; inh = 0;  }
void I05747() { lac &= (010000|core[000124]);  }
void I05750() { lac &= (010000|core[000140]);  }
void I05751() { lac &= (010000|core[(df<<12)+core[82]]);  }
void I05752() { if (++core[005617] == 010000) { core[005617] = 0; npc++; }; code[005617] = &emul8;  }
void I05753() { if (++core[005637] == 010000) { core[005637] = 0; npc++; }; code[005637] = &emul8;  }
void I05754() { core[(df<<12)+core[2944]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2944]] = &emul8;  }
void I05755() { emul8();  }
void I05756() { core[000005] = 05757; npc = 000005+1; code[000005] = &emul8; inh = 0;  }
void I05757() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I05760() { lac &= (010000|core[(df<<12)+core[78]]);  }
void I05761() { lac &= (010000|core[(df<<12)+core[5]]);  }
void I05762() { lac &= (010000|core[(df<<12)+core[32]]);  }
void I05763() { lac &= (010000|core[005601]);  }
void I05764() { lac += core[(df<<12)+core[2955]];  }
void I05765() { if (++core[005740] == 010000) { core[005740] = 0; npc++; }; code[005740] = &emul8;  }
void I05766() { lac += core[(df<<12)+core[3014]];  }
void I05767() { core[000015] = 05770; npc = 000015+1; code[000015] = &emul8; inh = 0;  }
void I05770() { lac &= (010000|core[(df<<12)+core[77]]);  }
void I05771() { lac += core[(df<<12)+core[3026]];  }
void I05772() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void I05773() { if (++core[000017] == 010000) core[000017] = 0000;if (++core[(df<<12)+core[000017]] == 010000) { core[(df<<12)+core[000017]] = 0; npc++; }; code[(df<<12)+core[000017]] = &emul8;  }
void I05774() { core[000002] = 05775; npc = 000002+1; code[000002] = &emul8; inh = 0;  }
void I05775() { lac &= (010000|core[000116]);  }
void I05776() { lac += core[005740];  }
void I05777() { lac &= (010000|core[000000]);  }
void I07600() { lac &= 010000; lac &= 07777;  }
void I07601() { lac += core[000155];  }
void I07602() { core[007777] = lac & 07777; lac &= 010000; code[007777] = &emul8;  }
void I07603() { npc = 007777; inh = 0;  }
void I07775() { lac &= (010000|core[000000]);  }
void L07776() { lac &= (010000|core[000000]);  }
void L07777() { lac &= (010000|core[000000]);  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &P00001;
  core[000002] = 00002; code[000002] = &S00002;
  core[000003] = 00003; code[000003] = &P00003;
  core[000004] = 00000; code[000004] = &S00004;
  core[000010] = 00000; code[000010] = &P00010;
  core[000011] = 00000; code[000011] = &P00011;
  core[000012] = 00000; code[000012] = &P00012;
  core[000020] = 00000; code[000020] = &P00020;
  core[000021] = 00022; code[000021] = &P00021;
  core[000022] = 07777; code[000022] = &P00022;
  core[000023] = 00000; code[000023] = &D00023;
  core[000024] = 00000; code[000024] = &P00024;
  core[000025] = 00000; code[000025] = &P00025;
  core[000026] = 00000; code[000026] = &L00026;
  core[000027] = 00000; code[000027] = &D00027;
  core[000030] = 00000; code[000030] = &P00030;
  core[000031] = 00000; code[000031] = &D00031;
  core[000032] = 00000; code[000032] = &D00032;
  core[000033] = 00000; code[000033] = &D00033;
  core[000034] = 00000; code[000034] = &P00034;
  core[000035] = 00000; code[000035] = &D00035;
  core[000036] = 00000; code[000036] = &P00036;
  core[000037] = 00000; code[000037] = &P00037;
  core[000040] = 00000; code[000040] = &S00040;
  core[000041] = 00037; code[000041] = &L00041;
  core[000042] = 00000; code[000042] = &I00042;
  core[000043] = 00000; code[000043] = &D00043;
  core[000044] = 00000; code[000044] = &D00044;
  core[000045] = 00000; code[000045] = &D00045;
  core[000046] = 01600; code[000046] = &P00046;
  core[000047] = 01652; code[000047] = &P00047;
  core[000050] = 01133; code[000050] = &P00050;
  core[000051] = 01200; code[000051] = &P00051;
  core[000052] = 00756; code[000052] = &P00052;
  core[000053] = 01157; code[000053] = &D00053;
  core[000054] = 01140; code[000054] = &D00054;
  core[000055] = 01657; code[000055] = &P00055;
  core[000056] = 01000; code[000056] = &P00056;
  core[000057] = 01031; code[000057] = &P00057;
  core[000060] = 00504; code[000060] = &P00060;
  core[000061] = 00523; code[000061] = &P00061;
  core[000062] = 03000; code[000062] = &P00062;
  core[000063] = 03730; code[000063] = &P00063;
  core[000064] = 03017; code[000064] = &P00064;
  core[000065] = 03037; code[000065] = &P00065;
  core[000066] = 03027; code[000066] = &P00066;
  core[000067] = 03046; code[000067] = &P00067;
  core[000070] = 07775; code[000070] = &D00070;
  core[000071] = 07776; code[000071] = &P00071;
  core[000072] = 07777; code[000072] = &P00072;
  core[000073] = 03512; code[000073] = &P00073;
  core[000074] = 00410; code[000074] = &P00074;
  core[000075] = 00552; code[000075] = &P00075;
  core[000076] = 00240; code[000076] = &D00076;
  core[000077] = 00260; code[000077] = &D00077;
  core[000100] = 00261; code[000100] = &L00100;
  core[000101] = 06000; code[000101] = &P00101;
  core[000102] = 00102; code[000102] = &P00102;
  core[000103] = 04000; code[000103] = &D00103;
  core[000104] = 02000; code[000104] = &P00104;
  core[000105] = 01000; code[000105] = &D00105;
  core[000106] = 00400; code[000106] = &D00106;
  core[000107] = 00200; code[000107] = &P00107;
  core[000110] = 00100; code[000110] = &P00110;
  core[000111] = 00040; code[000111] = &D00111;
  core[000112] = 00020; code[000112] = &P00112;
  core[000113] = 00010; code[000113] = &D00113;
  core[000114] = 00004; code[000114] = &P00114;
  core[000115] = 00002; code[000115] = &P00115;
  core[000116] = 00001; code[000116] = &P00116;
  core[000117] = 00000; code[000117] = &I00117;
  core[000120] = 04000; code[000120] = &I00120;
  core[000121] = 00001; code[000121] = &I00121;
  core[000122] = 02004; code[000122] = &P00122;
  core[000123] = 02043; code[000123] = &P00123;
  core[000124] = 02076; code[000124] = &D00124;
  core[000125] = 02200; code[000125] = &D00125;
  core[000126] = 02232; code[000126] = &D00126;
  core[000127] = 02270; code[000127] = &D00127;
  core[000130] = 02400; code[000130] = &P00130;
  core[000131] = 02436; code[000131] = &D00131;
  core[000132] = 02472; code[000132] = &D00132;
  core[000133] = 02600; code[000133] = &D00133;
  core[000134] = 02634; code[000134] = &D00134;
  core[000135] = 02667; code[000135] = &D00135;
  core[000136] = 01376; code[000136] = &D00136;
  core[000137] = 07001; code[000137] = &D00137;
  core[000140] = 05404; code[000140] = &P00140;
  core[000141] = 05402; code[000141] = &D00141;
  core[000142] = 07070; code[000142] = &D00142;
  core[000143] = 02376; code[000143] = &D00143;
  core[000144] = 02000; code[000144] = &P00144;
  core[000145] = 02410; code[000145] = &D00145;
  core[000146] = 04000; code[000146] = &D00146;
  core[000147] = 04776; code[000147] = &D00147;
  core[000150] = 04410; code[000150] = &P00150;
  core[000151] = 05403; code[000151] = &D00151;
  core[000152] = 05401; code[000152] = &P00152;
  core[000153] = 04377; code[000153] = &D00153;
  core[000154] = 02004; code[000154] = &P00154;
  core[000155] = 05301; code[000155] = &D00155;
  core[000156] = 06007; code[000156] = &P00156;
  core[000157] = 07604; code[000157] = &D00157;
  core[000160] = 00106; code[000160] = &I00160;
  core[000161] = 07650; code[000161] = &I00161;
  core[000162] = 05177; code[000162] = &I00162;
  core[000163] = 07240; code[000163] = &I00163;
  core[000164] = 00170; code[000164] = &I00164;
  core[000165] = 03024; code[000165] = &P00165;
  core[000166] = 05567; code[000166] = &I00166;
  core[000167] = 00202; code[000167] = &P00167;
  core[000170] = 00000; code[000170] = &D00170;
  core[000171] = 00000; code[000171] = &P00171;
  core[000172] = 00007; code[000172] = &D00172;
  core[000173] = 00070; code[000173] = &D00173;
  core[000174] = 00000; code[000174] = &D00174;
  core[000175] = 00000; code[000175] = &D00175;
  core[000176] = 00000; code[000176] = &P00176;
  core[000177] = 07410; code[000177] = &L00177;
  core[000200] = 05156; code[000200] = &L00200;
  core[000201] = 03024; code[000201] = &I00201;
  core[000202] = 03023; code[000202] = &L00202;
  core[000203] = 03035; code[000203] = &I00203;
  core[000204] = 07340; code[000204] = &L00204;
  core[000205] = 00023; code[000205] = &I00205;
  core[000206] = 07421; code[000206] = &I00206;
  core[000207] = 07040; code[000207] = &I00207;
  core[000210] = 00024; code[000210] = &I00210;
  core[000211] = 07501; code[000211] = &I00211;
  core[000212] = 03027; code[000212] = &I00212;
  core[000213] = 07501; code[000213] = &I00213;
  core[000214] = 07040; code[000214] = &I00214;
  core[000215] = 00024; code[000215] = &I00215;
  core[000216] = 07421; code[000216] = &I00216;
  core[000217] = 07040; code[000217] = &I00217;
  core[000220] = 00024; code[000220] = &I00220;
  core[000221] = 07040; code[000221] = &I00221;
  core[000222] = 00023; code[000222] = &I00222;
  core[000223] = 07501; code[000223] = &I00223;
  core[000224] = 03025; code[000224] = &I00224;
  core[000225] = 03026; code[000225] = &I00225;
  core[000226] = 07040; code[000226] = &I00226;
  core[000227] = 00023; code[000227] = &I00227;
  core[000230] = 00024; code[000230] = &I00230;
  core[000231] = 07450; code[000231] = &I00231;
  core[000232] = 05274; code[000232] = &I00232;
  core[000233] = 07421; code[000233] = &I00233;
  core[000234] = 07521; code[000234] = &L00234;
  core[000235] = 00027; code[000235] = &I00235;
  core[000236] = 07450; code[000236] = &I00236;
  core[000237] = 05244; code[000237] = &I00237;
  core[000240] = 07104; code[000240] = &I00240;
  core[000241] = 07521; code[000241] = &I00241;
  core[000242] = 07501; code[000242] = &I00242;
  core[000243] = 05234; code[000243] = &I00243;
  core[000244] = 07501; code[000244] = &L00244;
  core[000245] = 00027; code[000245] = &I00245;
  core[000246] = 00103; code[000246] = &I00246;
  core[000247] = 07450; code[000247] = &I00247;
  core[000250] = 05253; code[000250] = &I00250;
  core[000251] = 03026; code[000251] = &I00251;
  core[000252] = 05260; code[000252] = &I00252;
  core[000253] = 07130; code[000253] = &L00253;
  core[000254] = 00023; code[000254] = &I00254;
  core[000255] = 00024; code[000255] = &I00255;
  core[000256] = 07440; code[000256] = &I00256;
  core[000257] = 03026; code[000257] = &I00257;
  core[000260] = 07501; code[000260] = &L00260;
  core[000261] = 03030; code[000261] = &I00261;
  core[000262] = 07501; code[000262] = &I00262;
  core[000263] = 07040; code[000263] = &I00263;
  core[000264] = 00025; code[000264] = &I00264;
  core[000265] = 07421; code[000265] = &I00265;
  core[000266] = 07040; code[000266] = &I00266;
  core[000267] = 00025; code[000267] = &I00267;
  core[000270] = 07040; code[000270] = &I00270;
  core[000271] = 00030; code[000271] = &I00271;
  core[000272] = 07501; code[000272] = &I00272;
  core[000273] = 03025; code[000273] = &I00273;
  core[000274] = 07340; code[000274] = &L00274;
  core[000275] = 00023; code[000275] = &I00275;
  core[000276] = 01024; code[000276] = &I00276;
  core[000277] = 07000; code[000277] = &I00277;
  core[000300] = 03031; code[000300] = &I00300;
  core[000301] = 07010; code[000301] = &I00301;
  core[000302] = 03032; code[000302] = &I00302;
  core[000303] = 07040; code[000303] = &I00303;
  core[000304] = 00024; code[000304] = &I00304;
  core[000305] = 01023; code[000305] = &I00305;
  core[000306] = 07000; code[000306] = &I00306;
  core[000307] = 03033; code[000307] = &I00307;
  core[000310] = 07010; code[000310] = &I00310;
  core[000311] = 03034; code[000311] = &I00311;
  core[000312] = 07000; code[000312] = &I00312;
  core[000313] = 07340; code[000313] = &I00313;
  core[000314] = 00031; code[000314] = &I00314;
  core[000315] = 07040; code[000315] = &I00315;
  core[000316] = 00033; code[000316] = &I00316;
  core[000317] = 07440; code[000317] = &I00317;
  core[000320] = 05377; code[000320] = &I00320;
  core[000321] = 07040; code[000321] = &I00321;
  core[000322] = 00033; code[000322] = &I00322;
  core[000323] = 07040; code[000323] = &I00323;
  core[000324] = 00031; code[000324] = &I00324;
  core[000325] = 07440; code[000325] = &I00325;
  core[000326] = 05377; code[000326] = &I00326;
  core[000327] = 07340; code[000327] = &I00327;
  core[000330] = 00031; code[000330] = &I00330;
  core[000331] = 07040; code[000331] = &I00331;
  core[000332] = 00025; code[000332] = &I00332;
  core[000333] = 07440; code[000333] = &I00333;
  core[000334] = 05377; code[000334] = &I00334;
  core[000335] = 07040; code[000335] = &I00335;
  core[000336] = 00025; code[000336] = &I00336;
  core[000337] = 07040; code[000337] = &I00337;
  core[000340] = 00031; code[000340] = &I00340;
  core[000341] = 07440; code[000341] = &I00341;
  core[000342] = 05377; code[000342] = &I00342;
  core[000343] = 07340; code[000343] = &I00343;
  core[000344] = 00032; code[000344] = &I00344;
  core[000345] = 07004; code[000345] = &I00345;
  core[000346] = 07240; code[000346] = &I00346;
  core[000347] = 00034; code[000347] = &I00347;
  core[000350] = 07640; code[000350] = &I00350;
  core[000351] = 07020; code[000351] = &I00351;
  core[000352] = 07430; code[000352] = &I00352;
  core[000353] = 05377; code[000353] = &I00353;
  core[000354] = 07340; code[000354] = &I00354;
  core[000355] = 00032; code[000355] = &I00355;
  core[000356] = 07004; code[000356] = &I00356;
  core[000357] = 07240; code[000357] = &I00357;
  core[000360] = 00026; code[000360] = &I00360;
  core[000361] = 07640; code[000361] = &I00361;
  core[000362] = 07020; code[000362] = &I00362;
  core[000363] = 07430; code[000363] = &I00363;
  core[000364] = 05377; code[000364] = &I00364;
  core[000365] = 05474; code[000365] = &I00365;
  core[000366] = 02023; code[000366] = &L00366;
  core[000367] = 05204; code[000367] = &I00367;
  core[000370] = 02024; code[000370] = &I00370;
  core[000371] = 07410; code[000371] = &I00371;
  core[000372] = 05475; code[000372] = &I00372;
  core[000373] = 07240; code[000373] = &I00373;
  core[000374] = 00024; code[000374] = &I00374;
  core[000375] = 03023; code[000375] = &I00375;
  core[000376] = 05204; code[000376] = &I00376;
  core[000377] = 07000; code[000377] = &L00377;
  core[000400] = 07604; code[000400] = &L00400;
  core[000401] = 00104; code[000401] = &I00401;
  core[000402] = 07650; code[000402] = &I00402;
  core[000403] = 04217; code[000403] = &I00403;
  core[000404] = 07604; code[000404] = &L00404;
  core[000405] = 00103; code[000405] = &I00405;
  core[000406] = 07650; code[000406] = &I00406;
  core[000407] = 04277; code[000407] = &I00407;
  core[000410] = 07604; code[000410] = &L00410;
  core[000411] = 00105; code[000411] = &I00411;
  core[000412] = 07640; code[000412] = &I00412;
  core[000413] = 05615; code[000413] = &I00413;
  core[000414] = 05616; code[000414] = &I00414;
  core[000415] = 00274; code[000415] = &P00415;
  core[000416] = 00366; code[000416] = &P00416;
  core[000417] = 00000; code[000417] = &D00417;
  core[000420] = 07340; code[000420] = &I00420;
  core[000421] = 00035; code[000421] = &I00421;
  core[000422] = 07650; code[000422] = &I00422;
  core[000423] = 04267; code[000423] = &I00423;
  core[000424] = 07040; code[000424] = &I00424;
  core[000425] = 00023; code[000425] = &I00425;
  core[000426] = 03037; code[000426] = &I00426;
  core[000427] = 04323; code[000427] = &I00427;
  core[000430] = 07040; code[000430] = &I00430;
  core[000431] = 00024; code[000431] = &I00431;
  core[000432] = 03037; code[000432] = &I00432;
  core[000433] = 04323; code[000433] = &I00433;
  core[000434] = 07040; code[000434] = &I00434;
  core[000435] = 00026; code[000435] = &I00435;
  core[000436] = 03040; code[000436] = &I00436;
  core[000437] = 07040; code[000437] = &I00437;
  core[000440] = 00025; code[000440] = &I00440;
  core[000441] = 03037; code[000441] = &I00441;
  core[000442] = 04304; code[000442] = &I00442;
  core[000443] = 04323; code[000443] = &I00443;
  core[000444] = 07040; code[000444] = &I00444;
  core[000445] = 00032; code[000445] = &I00445;
  core[000446] = 03040; code[000446] = &I00446;
  core[000447] = 07040; code[000447] = &I00447;
  core[000450] = 00031; code[000450] = &I00450;
  core[000451] = 03037; code[000451] = &I00451;
  core[000452] = 04304; code[000452] = &I00452;
  core[000453] = 04323; code[000453] = &I00453;
  core[000454] = 07040; code[000454] = &I00454;
  core[000455] = 00034; code[000455] = &I00455;
  core[000456] = 03040; code[000456] = &I00456;
  core[000457] = 07040; code[000457] = &I00457;
  core[000460] = 00033; code[000460] = &I00460;
  core[000461] = 03037; code[000461] = &I00461;
  core[000462] = 04304; code[000462] = &I00462;
  core[000463] = 04323; code[000463] = &I00463;
  core[000464] = 04446; code[000464] = &I00464;
  core[000465] = 05742; code[000465] = &I00465;
  core[000466] = 05204; code[000466] = &I00466;
  core[000467] = 00000; code[000467] = &S00467;
  core[000470] = 04446; code[000470] = &I00470;
  core[000471] = 05417; code[000471] = &I00471;
  core[000472] = 04446; code[000472] = &I00472;
  core[000473] = 05177; code[000473] = &I00473;
  core[000474] = 07240; code[000474] = &D00474;
  core[000475] = 03035; code[000475] = &I00475;
  core[000476] = 05667; code[000476] = &I00476;
  core[000477] = 00000; code[000477] = &S00477;
  core[000500] = 07240; code[000500] = &I00500;
  core[000501] = 00351; code[000501] = &I00501;
  core[000502] = 07402; code[000502] = &I00502;
  core[000503] = 05677; code[000503] = &I00503;
  core[000504] = 00000; code[000504] = &S00504;
  core[000505] = 07340; code[000505] = &I00505;
  core[000506] = 00040; code[000506] = &I00506;
  core[000507] = 07640; code[000507] = &D00507;
  core[000510] = 05320; code[000510] = &I00510;
  core[000511] = 07040; code[000511] = &I00511;
  core[000512] = 00077; code[000512] = &I00512;
  core[000513] = 04447; code[000513] = &L00513;
  core[000514] = 07040; code[000514] = &I00514;
  core[000515] = 00076; code[000515] = &I00515;
  core[000516] = 04447; code[000516] = &I00516;
  core[000517] = 05704; code[000517] = &I00517;
  core[000520] = 07040; code[000520] = &L00520;
  core[000521] = 00100; code[000521] = &P00521;
  core[000522] = 05313; code[000522] = &I00522;
  core[000523] = 00000; code[000523] = &S00523;
  core[000524] = 07340; code[000524] = &I00524;
  core[000525] = 00102; code[000525] = &I00525;
  core[000526] = 03011; code[000526] = &I00526;
  core[000527] = 07040; code[000527] = &L00527;
  core[000530] = 00411; code[000530] = &I00530;
  core[000531] = 07450; code[000531] = &I00531;
  core[000532] = 05345; code[000532] = &I00532;
  core[000533] = 00037; code[000533] = &I00533;
  core[000534] = 07640; code[000534] = &I00534;
  core[000535] = 05342; code[000535] = &I00535;
  core[000536] = 07040; code[000536] = &I00536;
  core[000537] = 00077; code[000537] = &I00537;
  core[000540] = 04447; code[000540] = &L00540;
  core[000541] = 05327; code[000541] = &I00541;
  core[000542] = 07040; code[000542] = &P00542;
  core[000543] = 00100; code[000543] = &I00543;
  core[000544] = 05340; code[000544] = &I00544;
  core[000545] = 07040; code[000545] = &L00545;
  core[000546] = 00076; code[000546] = &I00546;
  core[000547] = 04447; code[000547] = &I00547;
  core[000550] = 05723; code[000550] = &I00550;
  core[000551] = 00204; code[000551] = &D00551;
  core[000552] = 07604; code[000552] = &L00552;
  core[000553] = 00115; code[000553] = &I00553;
  core[000554] = 07650; code[000554] = &I00554;
  core[000555] = 05370; code[000555] = &I00555;
  core[000556] = 07604; code[000556] = &L00556;
  core[000557] = 00114; code[000557] = &I00557;
  core[000560] = 07640; code[000560] = &I00560;
  core[000561] = 07402; code[000561] = &I00561;
  core[000562] = 07604; code[000562] = &I00562;
  core[000563] = 00116; code[000563] = &I00563;
  core[000564] = 07650; code[000564] = &I00564;
  core[000565] = 05377; code[000565] = &I00565;
  core[000566] = 05767; code[000566] = &D00566;
  core[000567] = 00204; code[000567] = &P00567;
  core[000570] = 04446; code[000570] = &L00570;
  core[000571] = 05721; code[000571] = &I00571;
  core[000572] = 05356; code[000572] = &I00572;
  core[000577] = 07000; code[000577] = &L00577;
  core[000600] = 04752; code[000600] = &L00600;
  core[000601] = 07340; code[000601] = &L00601;
  core[000602] = 00052; code[000602] = &I00602;
  core[000603] = 03012; code[000603] = &I00603;
  core[000604] = 04451; code[000604] = &I00604;
  core[000605] = 07340; code[000605] = &L00605;
  core[000606] = 00024; code[000606] = &I00606;
  core[000607] = 07640; code[000607] = &I00607;
  core[000610] = 07020; code[000610] = &I00610;
  core[000611] = 07040; code[000611] = &I00611;
  core[000612] = 00023; code[000612] = &I00612;
  core[000613] = 07004; code[000613] = &I00613;
  core[000614] = 07000; code[000614] = &I00614;
  core[000615] = 03031; code[000615] = &I00615;
  core[000616] = 07430; code[000616] = &I00616;
  core[000617] = 07040; code[000617] = &I00617;
  core[000620] = 03033; code[000620] = &I00620;
  core[000621] = 04456; code[000621] = &I00621;
  core[000622] = 05205; code[000622] = &I00622;
  core[000623] = 04457; code[000623] = &I00623;
  core[000624] = 05201; code[000624] = &I00624;
  core[000625] = 04753; code[000625] = &I00625;
  core[000626] = 07340; code[000626] = &L00626;
  core[000627] = 00102; code[000627] = &I00627;
  core[000630] = 03012; code[000630] = &I00630;
  core[000631] = 04451; code[000631] = &I00631;
  core[000632] = 07340; code[000632] = &L00632;
  core[000633] = 00024; code[000633] = &I00633;
  core[000634] = 07640; code[000634] = &I00634;
  core[000635] = 07020; code[000635] = &I00635;
  core[000636] = 07040; code[000636] = &D00636;
  core[000637] = 00023; code[000637] = &I00637;
  core[000640] = 07010; code[000640] = &I00640;
  core[000641] = 07000; code[000641] = &I00641;
  core[000642] = 03031; code[000642] = &I00642;
  core[000643] = 07430; code[000643] = &I00643;
  core[000644] = 07040; code[000644] = &I00644;
  core[000645] = 03033; code[000645] = &I00645;
  core[000646] = 04456; code[000646] = &I00646;
  core[000647] = 05232; code[000647] = &I00647;
  core[000650] = 04457; code[000650] = &I00650;
  core[000651] = 05226; code[000651] = &I00651;
  core[000652] = 04754; code[000652] = &I00652;
  core[000653] = 07340; code[000653] = &L00653;
  core[000654] = 00053; code[000654] = &I00654;
  core[000655] = 03012; code[000655] = &I00655;
  core[000656] = 04451; code[000656] = &I00656;
  core[000657] = 07340; code[000657] = &L00657;
  core[000660] = 00024; code[000660] = &I00660;
  core[000661] = 07640; code[000661] = &I00661;
  core[000662] = 07020; code[000662] = &I00662;
  core[000663] = 07040; code[000663] = &I00663;
  core[000664] = 00023; code[000664] = &I00664;
  core[000665] = 07006; code[000665] = &I00665;
  core[000666] = 07000; code[000666] = &I00666;
  core[000667] = 03031; code[000667] = &I00667;
  core[000670] = 07430; code[000670] = &I00670;
  core[000671] = 07040; code[000671] = &I00671;
  core[000672] = 03033; code[000672] = &I00672;
  core[000673] = 04456; code[000673] = &I00673;
  core[000674] = 05257; code[000674] = &I00674;
  core[000675] = 04457; code[000675] = &I00675;
  core[000676] = 05253; code[000676] = &I00676;
  core[000677] = 04755; code[000677] = &I00677;
  core[000700] = 07340; code[000700] = &L00700;
  core[000701] = 00054; code[000701] = &I00701;
  core[000702] = 03012; code[000702] = &I00702;
  core[000703] = 04451; code[000703] = &I00703;
  core[000704] = 07340; code[000704] = &L00704;
  core[000705] = 00024; code[000705] = &I00705;
  core[000706] = 07640; code[000706] = &I00706;
  core[000707] = 07020; code[000707] = &I00707;
  core[000710] = 07040; code[000710] = &I00710;
  core[000711] = 00023; code[000711] = &I00711;
  core[000712] = 07012; code[000712] = &I00712;
  core[000713] = 07000; code[000713] = &I00713;
  core[000714] = 03031; code[000714] = &I00714;
  core[000715] = 07430; code[000715] = &I00715;
  core[000716] = 07040; code[000716] = &I00716;
  core[000717] = 03033; code[000717] = &I00717;
  core[000720] = 04456; code[000720] = &I00720;
  core[000721] = 05304; code[000721] = &I00721;
  core[000722] = 04457; code[000722] = &I00722;
  core[000723] = 05300; code[000723] = &D00723;
  core[000724] = 04756; code[000724] = &I00724;
  core[000725] = 07340; code[000725] = &L00725;
  core[000726] = 00055; code[000726] = &I00726;
  core[000727] = 03012; code[000727] = &I00727;
  core[000730] = 04776; code[000730] = &I00730;
  core[000731] = 07340; code[000731] = &L00731;
  core[000732] = 00024; code[000732] = &I00732;
  core[000733] = 07640; code[000733] = &I00733;
  core[000734] = 07020; code[000734] = &I00734;
  core[000735] = 07040; code[000735] = &I00735;
  core[000736] = 00023; code[000736] = &I00736;
  core[000737] = 07002; code[000737] = &I00737;
  core[000740] = 07000; code[000740] = &I00740;
  core[000741] = 03031; code[000741] = &I00741;
  core[000742] = 07430; code[000742] = &I00742;
  core[000743] = 07040; code[000743] = &I00743;
  core[000744] = 03033; code[000744] = &I00744;
  core[000745] = 04456; code[000745] = &I00745;
  core[000746] = 05331; code[000746] = &I00746;
  core[000747] = 04457; code[000747] = &I00747;
  core[000750] = 05325; code[000750] = &I00750;
  core[000751] = 05777; code[000751] = &I00751;
  core[000752] = 01400; code[000752] = &P00752;
  core[000753] = 01410; code[000753] = &P00753;
  core[000754] = 01420; code[000754] = &P00754;
  core[000755] = 01430; code[000755] = &P00755;
  core[000756] = 01440; code[000756] = &P00756;
  core[000757] = 00001; code[000757] = &I00757;
  core[000760] = 00002; code[000760] = &I00760;
  core[000761] = 00004; code[000761] = &I00761;
  core[000762] = 00010; code[000762] = &I00762;
  core[000763] = 00020; code[000763] = &I00763;
  core[000764] = 00040; code[000764] = &I00764;
  core[000765] = 00100; code[000765] = &I00765;
  core[000766] = 00200; code[000766] = &I00766;
  core[000767] = 00400; code[000767] = &I00767;
  core[000770] = 01000; code[000770] = &I00770;
  core[000771] = 02000; code[000771] = &I00771;
  core[000772] = 04000; code[000772] = &I00772;
  core[000773] = 00000; code[000773] = &I00773;
  core[000774] = 00001; code[000774] = &I00774;
  core[000775] = 04000; code[000775] = &I00775;
  core[000776] = 01236; code[000776] = &P00776;
  core[000777] = 01323; code[000777] = &P00777;
  core[001000] = 00000; code[001000] = &S01000;
  core[001001] = 07340; code[001001] = &I01001;
  core[001002] = 00025; code[001002] = &I01002;
  core[001003] = 07040; code[001003] = &I01003;
  core[001004] = 00031; code[001004] = &I01004;
  core[001005] = 07440; code[001005] = &I01005;
  core[001006] = 05226; code[001006] = &I01006;
  core[001007] = 07040; code[001007] = &I01007;
  core[001010] = 00031; code[001010] = &I01010;
  core[001011] = 07040; code[001011] = &I01011;
  core[001012] = 00025; code[001012] = &I01012;
  core[001013] = 07440; code[001013] = &I01013;
  core[001014] = 05226; code[001014] = &I01014;
  core[001015] = 07340; code[001015] = &I01015;
  core[001016] = 00026; code[001016] = &I01016;
  core[001017] = 07640; code[001017] = &I01017;
  core[001020] = 07020; code[001020] = &I01020;
  core[001021] = 07040; code[001021] = &I01021;
  core[001022] = 00033; code[001022] = &I01022;
  core[001023] = 07440; code[001023] = &I01023;
  core[001024] = 07020; code[001024] = &I01024;
  core[001025] = 07430; code[001025] = &I01025;
  core[001026] = 05246; code[001026] = &L01026;
  core[001027] = 02200; code[001027] = &L01027;
  core[001030] = 05600; code[001030] = &L01030;
  core[001031] = 00000; code[001031] = &S01031;
  core[001032] = 07340; code[001032] = &I01032;
  core[001033] = 00024; code[001033] = &I01033;
  core[001034] = 07640; code[001034] = &I01034;
  core[001035] = 05244; code[001035] = &I01035;
  core[001036] = 07040; code[001036] = &I01036;
  core[001037] = 03024; code[001037] = &I01037;
  core[001040] = 02023; code[001040] = &I01040;
  core[001041] = 05631; code[001041] = &I01041;
  core[001042] = 02231; code[001042] = &I01042;
  core[001043] = 05631; code[001043] = &I01043;
  core[001044] = 03024; code[001044] = &L01044;
  core[001045] = 05631; code[001045] = &I01045;
  core[001046] = 07604; code[001046] = &L01046;
  core[001047] = 00104; code[001047] = &I01047;
  core[001050] = 07650; code[001050] = &I01050;
  core[001051] = 04271; code[001051] = &I01051;
  core[001052] = 07604; code[001052] = &I01052;
  core[001053] = 00103; code[001053] = &I01053;
  core[001054] = 07650; code[001054] = &I01054;
  core[001055] = 05263; code[001055] = &I01055;
  core[001056] = 07604; code[001056] = &L01056;
  core[001057] = 00105; code[001057] = &I01057;
  core[001060] = 07650; code[001060] = &I01060;
  core[001061] = 05227; code[001061] = &I01061;
  core[001062] = 05230; code[001062] = &I01062;
  core[001063] = 07340; code[001063] = &L01063;
  core[001064] = 00451; code[001064] = &I01064;
  core[001065] = 01270; code[001065] = &I01065;
  core[001066] = 07402; code[001066] = &I01066;
  core[001067] = 05256; code[001067] = &I01067;
  core[001070] = 07774; code[001070] = &D01070;
  core[001071] = 00000; code[001071] = &S01071;
  core[001072] = 07340; code[001072] = &I01072;
  core[001073] = 00035; code[001073] = &I01073;
  core[001074] = 07650; code[001074] = &I01074;
  core[001075] = 04331; code[001075] = &I01075;
  core[001076] = 07040; code[001076] = &I01076;
  core[001077] = 00023; code[001077] = &L01077;
  core[001100] = 03037; code[001100] = &I01100;
  core[001101] = 07040; code[001101] = &I01101;
  core[001102] = 00024; code[001102] = &I01102;
  core[001103] = 03040; code[001103] = &I01103;
  core[001104] = 04460; code[001104] = &I01104;
  core[001105] = 04461; code[001105] = &I01105;
  core[001106] = 07040; code[001106] = &I01106;
  core[001107] = 00025; code[001107] = &I01107;
  core[001110] = 03037; code[001110] = &I01110;
  core[001111] = 07040; code[001111] = &I01111;
  core[001112] = 00026; code[001112] = &I01112;
  core[001113] = 03040; code[001113] = &I01113;
  core[001114] = 04460; code[001114] = &I01114;
  core[001115] = 04461; code[001115] = &I01115;
  core[001116] = 07040; code[001116] = &I01116;
  core[001117] = 00031; code[001117] = &I01117;
  core[001120] = 03037; code[001120] = &I01120;
  core[001121] = 07040; code[001121] = &I01121;
  core[001122] = 00033; code[001122] = &I01122;
  core[001123] = 03040; code[001123] = &I01123;
  core[001124] = 04460; code[001124] = &I01124;
  core[001125] = 04461; code[001125] = &I01125;
  core[001126] = 04446; code[001126] = &I01126;
  core[001127] = 05742; code[001127] = &I01127;
  core[001130] = 05671; code[001130] = &I01130;
  core[001131] = 00000; code[001131] = &S01131;
  core[001132] = 04446; code[001132] = &I01132;
  core[001133] = 00000; code[001133] = &D01133;
  core[001134] = 04446; code[001134] = &I01134;
  core[001135] = 05244; code[001135] = &I01135;
  core[001136] = 07240; code[001136] = &I01136;
  core[001137] = 03035; code[001137] = &I01137;
  core[001140] = 05731; code[001140] = &I01140;
  core[001141] = 02000; code[001141] = &I01141;
  core[001142] = 00400; code[001142] = &P01142;
  core[001143] = 00100; code[001143] = &I01143;
  core[001144] = 00020; code[001144] = &I01144;
  core[001145] = 00004; code[001145] = &I01145;
  core[001146] = 00001; code[001146] = &I01146;
  core[001147] = 04000; code[001147] = &I01147;
  core[001150] = 01000; code[001150] = &I01150;
  core[001151] = 00200; code[001151] = &I01151;
  core[001152] = 00040; code[001152] = &I01152;
  core[001153] = 00010; code[001153] = &I01153;
  core[001154] = 00002; code[001154] = &I01154;
  core[001155] = 00000; code[001155] = &I01155;
  core[001156] = 02000; code[001156] = &I01156;
  core[001157] = 00002; code[001157] = &I01157;
  core[001160] = 00002; code[001160] = &I01160;
  core[001161] = 00010; code[001161] = &I01161;
  core[001162] = 00040; code[001162] = &I01162;
  core[001163] = 00200; code[001163] = &I01163;
  core[001164] = 01000; code[001164] = &I01164;
  core[001165] = 04000; code[001165] = &I01165;
  core[001166] = 00001; code[001166] = &I01166;
  core[001167] = 00004; code[001167] = &I01167;
  core[001170] = 00020; code[001170] = &I01170;
  core[001171] = 00100; code[001171] = &I01171;
  core[001172] = 00400; code[001172] = &I01172;
  core[001173] = 02000; code[001173] = &I01173;
  core[001174] = 00000; code[001174] = &I01174;
  core[001175] = 00002; code[001175] = &I01175;
  core[001176] = 02000; code[001176] = &I01176;
  core[001200] = 00000; code[001200] = &S01200;
  core[001201] = 07300; code[001201] = &I01201;
  core[001202] = 03025; code[001202] = &I01202;
  core[001203] = 03026; code[001203] = &I01203;
  core[001204] = 07040; code[001204] = &I01204;
  core[001205] = 00412; code[001205] = &I01205;
  core[001206] = 03037; code[001206] = &I01206;
  core[001207] = 07040; code[001207] = &L01207;
  core[001210] = 00412; code[001210] = &I01210;
  core[001211] = 07450; code[001211] = &I01211;
  core[001212] = 05303; code[001212] = &I01212;
  core[001213] = 03040; code[001213] = &I01213;
  core[001214] = 07040; code[001214] = &I01214;
  core[001215] = 00023; code[001215] = &I01215;
  core[001216] = 00037; code[001216] = &I01216;
  core[001217] = 07440; code[001217] = &I01217;
  core[001220] = 04225; code[001220] = &I01220;
  core[001221] = 07040; code[001221] = &I01221;
  core[001222] = 00040; code[001222] = &I01222;
  core[001223] = 03037; code[001223] = &I01223;
  core[001224] = 05207; code[001224] = &I01224;
  core[001225] = 00000; code[001225] = &S01225;
  core[001226] = 07240; code[001226] = &I01226;
  core[001227] = 00040; code[001227] = &I01227;
  core[001230] = 07421; code[001230] = &I01230;
  core[001231] = 07040; code[001231] = &I01231;
  core[001232] = 00025; code[001232] = &I01232;
  core[001233] = 07501; code[001233] = &I01233;
  core[001234] = 03025; code[001234] = &I01234;
  core[001235] = 05625; code[001235] = &I01235;
  core[001236] = 00000; code[001236] = &S01236;
  core[001237] = 07340; code[001237] = &I01237;
  core[001240] = 00236; code[001240] = &I01240;
  core[001241] = 03451; code[001241] = &I01241;
  core[001242] = 03025; code[001242] = &I01242;
  core[001243] = 03026; code[001243] = &I01243;
  core[001244] = 07040; code[001244] = &L01244;
  core[001245] = 00412; code[001245] = &I01245;
  core[001246] = 07450; code[001246] = &I01246;
  core[001247] = 05277; code[001247] = &I01247;
  core[001250] = 03037; code[001250] = &I01250;
  core[001251] = 07040; code[001251] = &I01251;
  core[001252] = 00412; code[001252] = &I01252;
  core[001253] = 03040; code[001253] = &I01253;
  core[001254] = 07040; code[001254] = &I01254;
  core[001255] = 00023; code[001255] = &I01255;
  core[001256] = 00037; code[001256] = &I01256;
  core[001257] = 07440; code[001257] = &I01257;
  core[001260] = 04225; code[001260] = &I01260;
  core[001261] = 07040; code[001261] = &I01261;
  core[001262] = 00037; code[001262] = &I01262;
  core[001263] = 07421; code[001263] = &I01263;
  core[001264] = 07040; code[001264] = &I01264;
  core[001265] = 00040; code[001265] = &I01265;
  core[001266] = 03037; code[001266] = &I01266;
  core[001267] = 07501; code[001267] = &I01267;
  core[001270] = 03040; code[001270] = &I01270;
  core[001271] = 07040; code[001271] = &I01271;
  core[001272] = 00023; code[001272] = &I01272;
  core[001273] = 00037; code[001273] = &I01273;
  core[001274] = 07440; code[001274] = &I01274;
  core[001275] = 04225; code[001275] = &I01275;
  core[001276] = 05244; code[001276] = &I01276;
  core[001277] = 07340; code[001277] = &L01277;
  core[001300] = 00024; code[001300] = &I01300;
  core[001301] = 03026; code[001301] = &I01301;
  core[001302] = 05636; code[001302] = &I01302;
  core[001303] = 07340; code[001303] = &L01303;
  core[001304] = 00412; code[001304] = &I01304;
  core[001305] = 03040; code[001305] = &I01305;
  core[001306] = 07040; code[001306] = &I01306;
  core[001307] = 00116; code[001307] = &I01307;
  core[001310] = 00024; code[001310] = &I01310;
  core[001311] = 07440; code[001311] = &I01311;
  core[001312] = 04225; code[001312] = &I01312;
  core[001313] = 07040; code[001313] = &I01313;
  core[001314] = 00412; code[001314] = &I01314;
  core[001315] = 00023; code[001315] = &I01315;
  core[001316] = 07440; code[001316] = &I01316;
  core[001317] = 07240; code[001317] = &I01317;
  core[001320] = 00116; code[001320] = &I01320;
  core[001321] = 03026; code[001321] = &I01321;
  core[001322] = 05600; code[001322] = &I01322;
  core[001323] = 07604; code[001323] = &L01323;
  core[001324] = 00115; code[001324] = &I01324;
  core[001325] = 07650; code[001325] = &P01325;
  core[001326] = 05342; code[001326] = &I01326;
  core[001327] = 07604; code[001327] = &L01327;
  core[001330] = 00114; code[001330] = &I01330;
  core[001331] = 07640; code[001331] = &I01331;
  core[001332] = 07402; code[001332] = &I01332;
  core[001333] = 07604; code[001333] = &I01333;
  core[001334] = 00116; code[001334] = &I01334;
  core[001335] = 07650; code[001335] = &I01335;
  core[001336] = 05740; code[001336] = &I01336;
  core[001337] = 05741; code[001337] = &I01337;
  core[001340] = 02000; code[001340] = &P01340;
  core[001341] = 00600; code[001341] = &P01341;
  core[001342] = 04446; code[001342] = &L01342;
  core[001343] = 05725; code[001343] = &I01343;
  core[001344] = 05327; code[001344] = &I01344;
  core[001400] = 00000; code[001400] = &S01400;
  core[001401] = 07340; code[001401] = &I01401;
  core[001402] = 00250; code[001402] = &I01402;
  core[001403] = 03450; code[001403] = &I01403;
  core[001404] = 03035; code[001404] = &I01404;
  core[001405] = 03024; code[001405] = &D01405;
  core[001406] = 03023; code[001406] = &I01406;
  core[001407] = 05600; code[001407] = &I01407;
  core[001410] = 00000; code[001410] = &S01410;
  core[001411] = 07340; code[001411] = &I01411;
  core[001412] = 00251; code[001412] = &I01412;
  core[001413] = 03450; code[001413] = &I01413;
  core[001414] = 03035; code[001414] = &I01414;
  core[001415] = 03024; code[001415] = &I01415;
  core[001416] = 03023; code[001416] = &I01416;
  core[001417] = 05610; code[001417] = &I01417;
  core[001420] = 00000; code[001420] = &S01420;
  core[001421] = 07340; code[001421] = &I01421;
  core[001422] = 00252; code[001422] = &I01422;
  core[001423] = 03450; code[001423] = &I01423;
  core[001424] = 03035; code[001424] = &I01424;
  core[001425] = 03024; code[001425] = &I01425;
  core[001426] = 03023; code[001426] = &I01426;
  core[001427] = 05620; code[001427] = &I01427;
  core[001430] = 00000; code[001430] = &S01430;
  core[001431] = 07340; code[001431] = &I01431;
  core[001432] = 00253; code[001432] = &I01432;
  core[001433] = 03450; code[001433] = &I01433;
  core[001434] = 03035; code[001434] = &I01434;
  core[001435] = 03024; code[001435] = &I01435;
  core[001436] = 03023; code[001436] = &I01436;
  core[001437] = 05630; code[001437] = &I01437;
  core[001440] = 00000; code[001440] = &S01440;
  core[001441] = 07340; code[001441] = &I01441;
  core[001442] = 00254; code[001442] = &I01442;
  core[001443] = 03450; code[001443] = &I01443;
  core[001444] = 03035; code[001444] = &I01444;
  core[001445] = 03024; code[001445] = &I01445;
  core[001446] = 03023; code[001446] = &I01446;
  core[001447] = 05640; code[001447] = &I01447;
  core[001450] = 05440; code[001450] = &D01450;
  core[001451] = 05461; code[001451] = &D01451;
  core[001452] = 05502; code[001452] = &D01452;
  core[001453] = 05523; code[001453] = &D01453;
  core[001454] = 05544; code[001454] = &D01454;
  core[001600] = 00000; code[001600] = &S01600;
  core[001601] = 07300; code[001601] = &I01601;
  core[001602] = 01600; code[001602] = &I01602;
  core[001603] = 03011; code[001603] = &I01603;
  core[001604] = 02200; code[001604] = &I01604;
  core[001605] = 01411; code[001605] = &L01605;
  core[001606] = 03036; code[001606] = &I01606;
  core[001607] = 01036; code[001607] = &I01607;
  core[001610] = 07012; code[001610] = &I01610;
  core[001611] = 07012; code[001611] = &I01611;
  core[001612] = 07012; code[001612] = &D01612;
  core[001613] = 04217; code[001613] = &I01613;
  core[001614] = 01036; code[001614] = &I01614;
  core[001615] = 04217; code[001615] = &D01615;
  core[001616] = 05205; code[001616] = &I01616;
  core[001617] = 00000; code[001617] = &S01617;
  core[001620] = 00245; code[001620] = &I01620;
  core[001621] = 07450; code[001621] = &I01621;
  core[001622] = 05600; code[001622] = &I01622;
  core[001623] = 01246; code[001623] = &I01623;
  core[001624] = 07510; code[001624] = &I01624;
  core[001625] = 05230; code[001625] = &I01625;
  core[001626] = 01076; code[001626] = &I01626;
  core[001627] = 05243; code[001627] = &I01627;
  core[001630] = 07001; code[001630] = &L01630;
  core[001631] = 07440; code[001631] = &I01631;
  core[001632] = 05235; code[001632] = &I01632;
  core[001633] = 01251; code[001633] = &I01633;
  core[001634] = 05243; code[001634] = &I01634;
  core[001635] = 07001; code[001635] = &L01635;
  core[001636] = 07440; code[001636] = &I01636;
  core[001637] = 05242; code[001637] = &I01637;
  core[001640] = 01250; code[001640] = &I01640;
  core[001641] = 05243; code[001641] = &I01641;
  core[001642] = 01247; code[001642] = &L01642;
  core[001643] = 04447; code[001643] = &L01643;
  core[001644] = 05617; code[001644] = &I01644;
  core[001645] = 00077; code[001645] = &D01645;
  core[001646] = 07740; code[001646] = &D01646;
  core[001647] = 00336; code[001647] = &D01647;
  core[001650] = 00212; code[001650] = &D01650;
  core[001651] = 00215; code[001651] = &D01651;
  core[001652] = 00000; code[001652] = &S01652;
  core[001653] = 06046; code[001653] = &I01653;
  core[001654] = 06041; code[001654] = &L01654;
  core[001655] = 05254; code[001655] = &I01655;
  core[001656] = 07200; code[001656] = &I01656;
  core[001657] = 05652; code[001657] = &D01657;
  core[001660] = 00001; code[001660] = &I01660;
  core[001661] = 00100; code[001661] = &I01661;
  core[001662] = 00002; code[001662] = &I01662;
  core[001663] = 00200; code[001663] = &I01663;
  core[001664] = 00004; code[001664] = &I01664;
  core[001665] = 00400; code[001665] = &I01665;
  core[001666] = 00010; code[001666] = &I01666;
  core[001667] = 01000; code[001667] = &I01667;
  core[001670] = 00020; code[001670] = &I01670;
  core[001671] = 02000; code[001671] = &I01671;
  core[001672] = 00040; code[001672] = &I01672;
  core[001673] = 04000; code[001673] = &I01673;
  core[001674] = 00000; code[001674] = &I01674;
  core[002000] = 07300; code[002000] = &L02000;
  core[002001] = 01122; code[002001] = &I02001;
  core[002002] = 03154; code[002002] = &I02002;
  core[002003] = 03020; code[002003] = &I02003;
  core[002004] = 07300; code[002004] = &L02004;
  core[002005] = 07300; code[002005] = &I02005;
  core[002006] = 03471; code[002006] = &I02006;
  core[002007] = 01136; code[002007] = &I02007;
  core[002010] = 03472; code[002010] = &I02010;
  core[002011] = 01332; code[002011] = &I02011;
  core[002012] = 03000; code[002012] = &I02012;
  core[002013] = 01137; code[002013] = &I02013;
  core[002014] = 03001; code[002014] = &I02014;
  core[002015] = 01140; code[002015] = &I02015;
  core[002016] = 03002; code[002016] = &I02016;
  core[002017] = 07240; code[002017] = &I02017;
  core[002020] = 03003; code[002020] = &I02020;
  core[002021] = 01327; code[002021] = &I02021;
  core[002022] = 03004; code[002022] = &I02022;
  core[002023] = 07300; code[002023] = &L02023;
  core[002024] = 05472; code[002024] = &I02024;
  core[002025] = 07000; code[002025] = &I02025;
  core[002026] = 07000; code[002026] = &I02026;
  core[002027] = 04464; code[002027] = &I02027;
  core[002030] = 07430; code[002030] = &I02030;
  core[002031] = 07440; code[002031] = &I02031;
  core[002032] = 04465; code[002032] = &I02032;
  core[002033] = 07410; code[002033] = &I02033;
  core[002034] = 04466; code[002034] = &I02034;
  core[002035] = 04467; code[002035] = &I02035;
  core[002036] = 05223; code[002036] = &I02036;
  core[002037] = 07200; code[002037] = &I02037;
  core[002040] = 01123; code[002040] = &I02040;
  core[002041] = 03154; code[002041] = &I02041;
  core[002042] = 05554; code[002042] = &I02042;
  core[002043] = 07300; code[002043] = &L02043;
  core[002044] = 07340; code[002044] = &I02044;
  core[002045] = 03471; code[002045] = &I02045;
  core[002046] = 01136; code[002046] = &I02046;
  core[002047] = 03472; code[002047] = &I02047;
  core[002050] = 01137; code[002050] = &I02050;
  core[002051] = 03000; code[002051] = &I02051;
  core[002052] = 01141; code[002052] = &I02052;
  core[002053] = 03001; code[002053] = &I02053;
  core[002054] = 01330; code[002054] = &I02054;
  core[002055] = 03002; code[002055] = &I02055;
  core[002056] = 07300; code[002056] = &L02056;
  core[002057] = 05472; code[002057] = &I02057;
  core[002060] = 07000; code[002060] = &I02060;
  core[002061] = 07000; code[002061] = &I02061;
  core[002062] = 04464; code[002062] = &I02062;
  core[002063] = 07430; code[002063] = &I02063;
  core[002064] = 07440; code[002064] = &I02064;
  core[002065] = 04465; code[002065] = &I02065;
  core[002066] = 07410; code[002066] = &I02066;
  core[002067] = 04466; code[002067] = &I02067;
  core[002070] = 04467; code[002070] = &I02070;
  core[002071] = 05256; code[002071] = &I02071;
  core[002072] = 07200; code[002072] = &I02072;
  core[002073] = 01124; code[002073] = &I02073;
  core[002074] = 03154; code[002074] = &I02074;
  core[002075] = 05554; code[002075] = &I02075;
  core[002076] = 07300; code[002076] = &I02076;
  core[002077] = 01137; code[002077] = &I02077;
  core[002100] = 03471; code[002100] = &I02100;
  core[002101] = 01333; code[002101] = &I02101;
  core[002102] = 03472; code[002102] = &I02102;
  core[002103] = 01152; code[002103] = &I02103;
  core[002104] = 03000; code[002104] = &I02104;
  core[002105] = 01331; code[002105] = &I02105;
  core[002106] = 03001; code[002106] = &I02106;
  core[002107] = 07300; code[002107] = &L02107;
  core[002110] = 05471; code[002110] = &I02110;
  core[002111] = 07000; code[002111] = &I02111;
  core[002112] = 07000; code[002112] = &I02112;
  core[002113] = 04464; code[002113] = &I02113;
  core[002114] = 07430; code[002114] = &I02114;
  core[002115] = 07440; code[002115] = &I02115;
  core[002116] = 04465; code[002116] = &I02116;
  core[002117] = 07410; code[002117] = &I02117;
  core[002120] = 04466; code[002120] = &I02120;
  core[002121] = 04467; code[002121] = &I02121;
  core[002122] = 05307; code[002122] = &I02122;
  core[002123] = 07200; code[002123] = &I02123;
  core[002124] = 01125; code[002124] = &I02124;
  core[002125] = 03154; code[002125] = &I02125;
  core[002126] = 05554; code[002126] = &I02126;
  core[002127] = 02025; code[002127] = &D02127;
  core[002130] = 02060; code[002130] = &D02130;
  core[002131] = 02111; code[002131] = &D02131;
  core[002132] = 01003; code[002132] = &D02132;
  core[002133] = 01421; code[002133] = &D02133;
  core[002200] = 07300; code[002200] = &I02200;
  core[002201] = 07340; code[002201] = &I02201;
  core[002202] = 03471; code[002202] = &I02202;
  core[002203] = 01136; code[002203] = &I02203;
  core[002204] = 03472; code[002204] = &I02204;
  core[002205] = 01142; code[002205] = &I02205;
  core[002206] = 03000; code[002206] = &I02206;
  core[002207] = 01141; code[002207] = &I02207;
  core[002210] = 03001; code[002210] = &I02210;
  core[002211] = 01324; code[002211] = &I02211;
  core[002212] = 03002; code[002212] = &I02212;
  core[002213] = 07340; code[002213] = &L02213;
  core[002214] = 05472; code[002214] = &I02214;
  core[002215] = 07000; code[002215] = &D02215;
  core[002216] = 07000; code[002216] = &I02216;
  core[002217] = 04464; code[002217] = &I02217;
  core[002220] = 07430; code[002220] = &I02220;
  core[002221] = 07440; code[002221] = &I02221;
  core[002222] = 04465; code[002222] = &I02222;
  core[002223] = 07410; code[002223] = &I02223;
  core[002224] = 04466; code[002224] = &I02224;
  core[002225] = 04467; code[002225] = &I02225;
  core[002226] = 05213; code[002226] = &I02226;
  core[002227] = 01126; code[002227] = &I02227;
  core[002230] = 03154; code[002230] = &I02230;
  core[002231] = 05554; code[002231] = &I02231;
  core[002232] = 07300; code[002232] = &I02232;
  core[002233] = 07300; code[002233] = &I02233;
  core[002234] = 01143; code[002234] = &I02234;
  core[002235] = 03472; code[002235] = &I02235;
  core[002236] = 01137; code[002236] = &I02236;
  core[002237] = 03000; code[002237] = &I02237;
  core[002240] = 01137; code[002240] = &I02240;
  core[002241] = 03001; code[002241] = &I02241;
  core[002242] = 01151; code[002242] = &I02242;
  core[002243] = 03002; code[002243] = &I02243;
  core[002244] = 01325; code[002244] = &I02244;
  core[002245] = 03003; code[002245] = &I02245;
  core[002246] = 07340; code[002246] = &L02246;
  core[002247] = 03471; code[002247] = &I02247;
  core[002250] = 07040; code[002250] = &I02250;
  core[002251] = 05472; code[002251] = &I02251;
  core[002252] = 07000; code[002252] = &D02252;
  core[002253] = 07000; code[002253] = &I02253;
  core[002254] = 04464; code[002254] = &I02254;
  core[002255] = 07430; code[002255] = &I02255;
  core[002256] = 07440; code[002256] = &I02256;
  core[002257] = 04465; code[002257] = &I02257;
  core[002260] = 07410; code[002260] = &I02260;
  core[002261] = 04466; code[002261] = &I02261;
  core[002262] = 04467; code[002262] = &I02262;
  core[002263] = 05246; code[002263] = &I02263;
  core[002264] = 07200; code[002264] = &I02264;
  core[002265] = 01127; code[002265] = &I02265;
  core[002266] = 03154; code[002266] = &I02266;
  core[002267] = 05554; code[002267] = &I02267;
  core[002270] = 07300; code[002270] = &I02270;
  core[002271] = 07300; code[002271] = &I02271;
  core[002272] = 01144; code[002272] = &I02272;
  core[002273] = 03472; code[002273] = &I02273;
  core[002274] = 01137; code[002274] = &I02274;
  core[002275] = 03001; code[002275] = &I02275;
  core[002276] = 01151; code[002276] = &I02276;
  core[002277] = 03002; code[002277] = &I02277;
  core[002300] = 01326; code[002300] = &I02300;
  core[002301] = 03003; code[002301] = &I02301;
  core[002302] = 07340; code[002302] = &L02302;
  core[002303] = 03000; code[002303] = &I02303;
  core[002304] = 07240; code[002304] = &I02304;
  core[002305] = 05472; code[002305] = &I02305;
  core[002306] = 07000; code[002306] = &D02306;
  core[002307] = 07000; code[002307] = &I02307;
  core[002310] = 04464; code[002310] = &I02310;
  core[002311] = 07430; code[002311] = &I02311;
  core[002312] = 07440; code[002312] = &I02312;
  core[002313] = 04465; code[002313] = &I02313;
  core[002314] = 07410; code[002314] = &I02314;
  core[002315] = 04466; code[002315] = &I02315;
  core[002316] = 04467; code[002316] = &I02316;
  core[002317] = 05302; code[002317] = &I02317;
  core[002320] = 07200; code[002320] = &I02320;
  core[002321] = 01130; code[002321] = &I02321;
  core[002322] = 03154; code[002322] = &I02322;
  core[002323] = 05554; code[002323] = &I02323;
  core[002324] = 02215; code[002324] = &D02324;
  core[002325] = 02252; code[002325] = &D02325;
  core[002326] = 02306; code[002326] = &D02326;
  core[002400] = 07300; code[002400] = &D02400;
  core[002401] = 07300; code[002401] = &I02401;
  core[002402] = 01145; code[002402] = &I02402;
  core[002403] = 03472; code[002403] = &I02403;
  core[002404] = 01137; code[002404] = &I02404;
  core[002405] = 03001; code[002405] = &I02405;
  core[002406] = 01151; code[002406] = &I02406;
  core[002407] = 03002; code[002407] = &I02407;
  core[002410] = 01326; code[002410] = &I02410;
  core[002411] = 03003; code[002411] = &I02411;
  core[002412] = 07340; code[002412] = &L02412;
  core[002413] = 03010; code[002413] = &I02413;
  core[002414] = 07040; code[002414] = &I02414;
  core[002415] = 03000; code[002415] = &I02415;
  core[002416] = 07040; code[002416] = &I02416;
  core[002417] = 05472; code[002417] = &I02417;
  core[002420] = 07000; code[002420] = &I02420;
  core[002421] = 07000; code[002421] = &I02421;
  core[002422] = 04464; code[002422] = &I02422;
  core[002423] = 07430; code[002423] = &I02423;
  core[002424] = 07440; code[002424] = &I02424;
  core[002425] = 04465; code[002425] = &D02425;
  core[002426] = 07410; code[002426] = &I02426;
  core[002427] = 04466; code[002427] = &I02427;
  core[002430] = 04467; code[002430] = &I02430;
  core[002431] = 05212; code[002431] = &I02431;
  core[002432] = 07200; code[002432] = &I02432;
  core[002433] = 01131; code[002433] = &I02433;
  core[002434] = 03154; code[002434] = &I02434;
  core[002435] = 05554; code[002435] = &I02435;
  core[002436] = 07300; code[002436] = &I02436;
  core[002437] = 07300; code[002437] = &I02437;
  core[002440] = 01137; code[002440] = &I02440;
  core[002441] = 03000; code[002441] = &I02441;
  core[002442] = 01137; code[002442] = &I02442;
  core[002443] = 03001; code[002443] = &I02443;
  core[002444] = 01140; code[002444] = &I02444;
  core[002445] = 03002; code[002445] = &I02445;
  core[002446] = 01327; code[002446] = &I02446;
  core[002447] = 03004; code[002447] = &I02447;
  core[002450] = 07300; code[002450] = &L02450;
  core[002451] = 01146; code[002451] = &I02451;
  core[002452] = 03472; code[002452] = &I02452;
  core[002453] = 07240; code[002453] = &I02453;
  core[002454] = 05472; code[002454] = &I02454;
  core[002455] = 07000; code[002455] = &I02455;
  core[002456] = 07000; code[002456] = &I02456;
  core[002457] = 07430; code[002457] = &I02457;
  core[002460] = 07440; code[002460] = &I02460;
  core[002461] = 04465; code[002461] = &I02461;
  core[002462] = 07410; code[002462] = &I02462;
  core[002463] = 04466; code[002463] = &I02463;
  core[002464] = 04467; code[002464] = &I02464;
  core[002465] = 05250; code[002465] = &I02465;
  core[002466] = 07200; code[002466] = &I02466;
  core[002467] = 01132; code[002467] = &I02467;
  core[002470] = 03154; code[002470] = &I02470;
  core[002471] = 05554; code[002471] = &I02471;
  core[002472] = 07300; code[002472] = &I02472;
  core[002473] = 07340; code[002473] = &I02473;
  core[002474] = 03471; code[002474] = &I02474;
  core[002475] = 01137; code[002475] = &I02475;
  core[002476] = 03000; code[002476] = &I02476;
  core[002477] = 01141; code[002477] = &I02477;
  core[002500] = 03001; code[002500] = &I02500;
  core[002501] = 01330; code[002501] = &I02501;
  core[002502] = 03002; code[002502] = &I02502;
  core[002503] = 07300; code[002503] = &L02503;
  core[002504] = 01147; code[002504] = &I02504;
  core[002505] = 03472; code[002505] = &I02505;
  core[002506] = 07240; code[002506] = &I02506;
  core[002507] = 05472; code[002507] = &I02507;
  core[002510] = 07000; code[002510] = &I02510;
  core[002511] = 07000; code[002511] = &I02511;
  core[002512] = 04464; code[002512] = &I02512;
  core[002513] = 07430; code[002513] = &I02513;
  core[002514] = 07440; code[002514] = &I02514;
  core[002515] = 04465; code[002515] = &I02515;
  core[002516] = 07410; code[002516] = &I02516;
  core[002517] = 04466; code[002517] = &I02517;
  core[002520] = 04467; code[002520] = &I02520;
  core[002521] = 05303; code[002521] = &I02521;
  core[002522] = 07200; code[002522] = &I02522;
  core[002523] = 01133; code[002523] = &I02523;
  core[002524] = 03154; code[002524] = &I02524;
  core[002525] = 05554; code[002525] = &I02525;
  core[002526] = 02420; code[002526] = &D02526;
  core[002527] = 02455; code[002527] = &D02527;
  core[002530] = 02510; code[002530] = &D02530;
  core[002600] = 07300; code[002600] = &D02600;
  core[002601] = 07300; code[002601] = &I02601;
  core[002602] = 01150; code[002602] = &I02602;
  core[002603] = 03472; code[002603] = &I02603;
  core[002604] = 01137; code[002604] = &I02604;
  core[002605] = 03001; code[002605] = &I02605;
  core[002606] = 01151; code[002606] = &I02606;
  core[002607] = 03002; code[002607] = &I02607;
  core[002610] = 01315; code[002610] = &I02610;
  core[002611] = 03003; code[002611] = &I02611;
  core[002612] = 07340; code[002612] = &L02612;
  core[002613] = 03010; code[002613] = &I02613;
  core[002614] = 07040; code[002614] = &I02614;
  core[002615] = 05472; code[002615] = &I02615;
  core[002616] = 07000; code[002616] = &P02616;
  core[002617] = 07000; code[002617] = &I02617;
  core[002620] = 04464; code[002620] = &I02620;
  core[002621] = 07430; code[002621] = &I02621;
  core[002622] = 07440; code[002622] = &I02622;
  core[002623] = 04465; code[002623] = &I02623;
  core[002624] = 07410; code[002624] = &I02624;
  core[002625] = 04466; code[002625] = &I02625;
  core[002626] = 04467; code[002626] = &I02626;
  core[002627] = 05212; code[002627] = &I02627;
  core[002630] = 07200; code[002630] = &I02630;
  core[002631] = 01134; code[002631] = &I02631;
  core[002632] = 03154; code[002632] = &I02632;
  core[002633] = 05554; code[002633] = &I02633;
  core[002634] = 07300; code[002634] = &I02634;
  core[002635] = 07300; code[002635] = &I02635;
  core[002636] = 01137; code[002636] = &I02636;
  core[002637] = 03000; code[002637] = &I02637;
  core[002640] = 01141; code[002640] = &I02640;
  core[002641] = 03001; code[002641] = &I02641;
  core[002642] = 01316; code[002642] = &I02642;
  core[002643] = 03002; code[002643] = &I02643;
  core[002644] = 07300; code[002644] = &L02644;
  core[002645] = 01153; code[002645] = &I02645;
  core[002646] = 03472; code[002646] = &I02646;
  core[002647] = 07240; code[002647] = &I02647;
  core[002650] = 05472; code[002650] = &I02650;
  core[002651] = 07000; code[002651] = &P02651;
  core[002652] = 07000; code[002652] = &I02652;
  core[002653] = 04464; code[002653] = &I02653;
  core[002654] = 07430; code[002654] = &I02654;
  core[002655] = 07440; code[002655] = &I02655;
  core[002656] = 04465; code[002656] = &I02656;
  core[002657] = 07410; code[002657] = &I02657;
  core[002660] = 04466; code[002660] = &I02660;
  core[002661] = 04467; code[002661] = &I02661;
  core[002662] = 05244; code[002662] = &I02662;
  core[002663] = 07200; code[002663] = &I02663;
  core[002664] = 01135; code[002664] = &I02664;
  core[002665] = 03154; code[002665] = &I02665;
  core[002666] = 05554; code[002666] = &I02666;
  core[002667] = 07300; code[002667] = &I02667;
  core[002670] = 07300; code[002670] = &I02670;
  core[002671] = 01137; code[002671] = &I02671;
  core[002672] = 03472; code[002672] = &I02672;
  core[002673] = 01152; code[002673] = &I02673;
  core[002674] = 03000; code[002674] = &I02674;
  core[002675] = 01317; code[002675] = &I02675;
  core[002676] = 03001; code[002676] = &I02676;
  core[002677] = 07340; code[002677] = &L02677;
  core[002700] = 05472; code[002700] = &I02700;
  core[002701] = 07000; code[002701] = &P02701;
  core[002702] = 07000; code[002702] = &I02702;
  core[002703] = 04464; code[002703] = &I02703;
  core[002704] = 07430; code[002704] = &I02704;
  core[002705] = 07440; code[002705] = &I02705;
  core[002706] = 04465; code[002706] = &I02706;
  core[002707] = 07410; code[002707] = &I02707;
  core[002710] = 04466; code[002710] = &I02710;
  core[002711] = 04467; code[002711] = &I02711;
  core[002712] = 05277; code[002712] = &I02712;
  core[002713] = 05714; code[002713] = &I02713;
  core[002714] = 03200; code[002714] = &P02714;
  core[002715] = 02616; code[002715] = &D02715;
  core[002716] = 02651; code[002716] = &D02716;
  core[002717] = 02701; code[002717] = &D02717;
  core[003000] = 00000; code[003000] = &S03000;
  core[003001] = 07340; code[003001] = &I03001;
  core[003002] = 00040; code[003002] = &I03002;
  core[003003] = 07040; code[003003] = &I03003;
  core[003004] = 00037; code[003004] = &I03004;
  core[003005] = 07640; code[003005] = &I03005;
  core[003006] = 05600; code[003006] = &I03006;
  core[003007] = 07040; code[003007] = &I03007;
  core[003010] = 00037; code[003010] = &I03010;
  core[003011] = 07040; code[003011] = &I03011;
  core[003012] = 00040; code[003012] = &I03012;
  core[003013] = 07640; code[003013] = &I03013;
  core[003014] = 05600; code[003014] = &I03014;
  core[003015] = 02200; code[003015] = &I03015;
  core[003016] = 05600; code[003016] = &I03016;
  core[003017] = 00000; code[003017] = &S03017;
  core[003020] = 03025; code[003020] = &I03020;
  core[003021] = 07430; code[003021] = &I03021;
  core[003022] = 07040; code[003022] = &I03022;
  core[003023] = 03026; code[003023] = &I03023;
  core[003024] = 07040; code[003024] = &L03024;
  core[003025] = 00025; code[003025] = &I03025;
  core[003026] = 05617; code[003026] = &I03026;
  core[003027] = 00000; code[003027] = &S03027;
  core[003030] = 07604; code[003030] = &I03030;
  core[003031] = 00103; code[003031] = &I03031;
  core[003032] = 07640; code[003032] = &I03032;
  core[003033] = 05627; code[003033] = &I03033;
  core[003034] = 01154; code[003034] = &I03034;
  core[003035] = 07402; code[003035] = &I03035;
  core[003036] = 05627; code[003036] = &I03036;
  core[003037] = 00000; code[003037] = &S03037;
  core[003040] = 07604; code[003040] = &I03040;
  core[003041] = 00104; code[003041] = &I03041;
  core[003042] = 07450; code[003042] = &I03042;
  core[003043] = 04256; code[003043] = &I03043;
  core[003044] = 02237; code[003044] = &I03044;
  core[003045] = 05637; code[003045] = &I03045;
  core[003046] = 00000; code[003046] = &S03046;
  core[003047] = 07604; code[003047] = &I03047;
  core[003050] = 00105; code[003050] = &I03050;
  core[003051] = 07650; code[003051] = &I03051;
  core[003052] = 05254; code[003052] = &I03052;
  core[003053] = 05646; code[003053] = &I03053;
  core[003054] = 02246; code[003054] = &L03054;
  core[003055] = 05646; code[003055] = &I03055;
  core[003056] = 00000; code[003056] = &S03056;
  core[003057] = 04446; code[003057] = &I03057;
  core[003060] = 05744; code[003060] = &I03060;
  core[003061] = 01037; code[003061] = &I03061;
  core[003062] = 04673; code[003062] = &I03062;
  core[003063] = 07340; code[003063] = &I03063;
  core[003064] = 00025; code[003064] = &I03064;
  core[003065] = 03037; code[003065] = &I03065;
  core[003066] = 00026; code[003066] = &I03066;
  core[003067] = 03040; code[003067] = &I03067;
  core[003070] = 04460; code[003070] = &I03070;
  core[003071] = 04461; code[003071] = &I03071;
  core[003072] = 05656; code[003072] = &I03072;
  core[003073] = 03227; code[003073] = &P03073;
  core[003200] = 07300; code[003200] = &L03200;
  core[003201] = 02020; code[003201] = &I03201;
  core[003202] = 05224; code[003202] = &I03202;
  core[003203] = 07604; code[003203] = &I03203;
  core[003204] = 00115; code[003204] = &I03204;
  core[003205] = 07650; code[003205] = &I03205;
  core[003206] = 05221; code[003206] = &I03206;
  core[003207] = 07604; code[003207] = &L03207;
  core[003210] = 00114; code[003210] = &I03210;
  core[003211] = 07640; code[003211] = &I03211;
  core[003212] = 07402; code[003212] = &I03212;
  core[003213] = 07604; code[003213] = &I03213;
  core[003214] = 00116; code[003214] = &I03214;
  core[003215] = 07640; code[003215] = &I03215;
  core[003216] = 05224; code[003216] = &I03216;
  core[003217] = 05620; code[003217] = &I03217;
  core[003220] = 03400; code[003220] = &P03220;
  core[003221] = 04446; code[003221] = &L03221;
  core[003222] = 05732; code[003222] = &I03222;
  core[003223] = 05207; code[003223] = &I03223;
  core[003224] = 01122; code[003224] = &L03224;
  core[003225] = 03154; code[003225] = &I03225;
  core[003226] = 05554; code[003226] = &I03226;
  core[003227] = 00000; code[003227] = &S03227;
  core[003230] = 03037; code[003230] = &I03230;
  core[003231] = 01037; code[003231] = &I03231;
  core[003232] = 00172; code[003232] = &I03232;
  core[003233] = 03264; code[003233] = &I03233;
  core[003234] = 01037; code[003234] = &I03234;
  core[003235] = 07006; code[003235] = &I03235;
  core[003236] = 07004; code[003236] = &I03236;
  core[003237] = 00266; code[003237] = &I03237;
  core[003240] = 01264; code[003240] = &I03240;
  core[003241] = 01267; code[003241] = &I03241;
  core[003242] = 03264; code[003242] = &I03242;
  core[003243] = 01037; code[003243] = &I03243;
  core[003244] = 07012; code[003244] = &I03244;
  core[003245] = 07012; code[003245] = &I03245;
  core[003246] = 07012; code[003246] = &I03246;
  core[003247] = 00172; code[003247] = &I03247;
  core[003250] = 03263; code[003250] = &I03250;
  core[003251] = 01037; code[003251] = &I03251;
  core[003252] = 07012; code[003252] = &I03252;
  core[003253] = 07010; code[003253] = &I03253;
  core[003254] = 00266; code[003254] = &I03254;
  core[003255] = 01263; code[003255] = &I03255;
  core[003256] = 01267; code[003256] = &I03256;
  core[003257] = 03263; code[003257] = &I03257;
  core[003260] = 04446; code[003260] = &I03260;
  core[003261] = 03262; code[003261] = &I03261;
  core[003262] = 05627; code[003262] = &D03262;
  core[003263] = 00000; code[003263] = &D03263;
  core[003264] = 00000; code[003264] = &D03264;
  core[003265] = 04000; code[003265] = &I03265;
  core[003266] = 00700; code[003266] = &D03266;
  core[003267] = 06060; code[003267] = &D03267;
  core[003400] = 07300; code[003400] = &P03400;
  core[003401] = 04473; code[003401] = &I03401;
  core[003402] = 07300; code[003402] = &L03402;
  core[003403] = 01041; code[003403] = &I03403;
  core[003404] = 01043; code[003404] = &I03404;
  core[003405] = 01043; code[003405] = &I03405;
  core[003406] = 01041; code[003406] = &I03406;
  core[003407] = 01041; code[003407] = &I03407;
  core[003410] = 01041; code[003410] = &I03410;
  core[003411] = 01043; code[003411] = &I03411;
  core[003412] = 01043; code[003412] = &I03412;
  core[003413] = 01041; code[003413] = &I03413;
  core[003414] = 01041; code[003414] = &I03414;
  core[003415] = 01043; code[003415] = &I03415;
  core[003416] = 01041; code[003416] = &I03416;
  core[003417] = 01043; code[003417] = &I03417;
  core[003420] = 01043; code[003420] = &I03420;
  core[003421] = 01041; code[003421] = &I03421;
  core[003422] = 01041; code[003422] = &I03422;
  core[003423] = 01043; code[003423] = &I03423;
  core[003424] = 01043; code[003424] = &I03424;
  core[003425] = 01043; code[003425] = &I03425;
  core[003426] = 01041; code[003426] = &I03426;
  core[003427] = 01043; code[003427] = &I03427;
  core[003430] = 01041; code[003430] = &I03430;
  core[003431] = 01041; code[003431] = &I03431;
  core[003432] = 01041; code[003432] = &I03432;
  core[003433] = 01043; code[003433] = &I03433;
  core[003434] = 01043; code[003434] = &I03434;
  core[003435] = 07000; code[003435] = &I03435;
  core[003436] = 04464; code[003436] = &I03436;
  core[003437] = 07430; code[003437] = &I03437;
  core[003440] = 07440; code[003440] = &I03440;
  core[003441] = 04646; code[003441] = &I03441;
  core[003442] = 04467; code[003442] = &I03442;
  core[003443] = 05202; code[003443] = &I03443;
  core[003444] = 05645; code[003444] = &I03444;
  core[003445] = 03600; code[003445] = &P03445;
  core[003446] = 03447; code[003446] = &P03446;
  core[003447] = 00000; code[003447] = &S03447;
  core[003450] = 07604; code[003450] = &I03450;
  core[003451] = 00104; code[003451] = &I03451;
  core[003452] = 07640; code[003452] = &I03452;
  core[003453] = 05302; code[003453] = &I03453;
  core[003454] = 04446; code[003454] = &I03454;
  core[003455] = 05565; code[003455] = &I03455;
  core[003456] = 04446; code[003456] = &I03456;
  core[003457] = 05316; code[003457] = &I03457;
  core[003460] = 07340; code[003460] = &I03460;
  core[003461] = 00041; code[003461] = &I03461;
  core[003462] = 03037; code[003462] = &I03462;
  core[003463] = 04461; code[003463] = &I03463;
  core[003464] = 07340; code[003464] = &I03464;
  core[003465] = 00043; code[003465] = &I03465;
  core[003466] = 03037; code[003466] = &I03466;
  core[003467] = 04461; code[003467] = &I03467;
  core[003470] = 07340; code[003470] = &I03470;
  core[003471] = 00025; code[003471] = &I03471;
  core[003472] = 03037; code[003472] = &I03472;
  core[003473] = 07040; code[003473] = &I03473;
  core[003474] = 00026; code[003474] = &I03474;
  core[003475] = 03040; code[003475] = &I03475;
  core[003476] = 04460; code[003476] = &I03476;
  core[003477] = 04461; code[003477] = &I03477;
  core[003500] = 04446; code[003500] = &I03500;
  core[003501] = 05742; code[003501] = &I03501;
  core[003502] = 07604; code[003502] = &L03502;
  core[003503] = 00103; code[003503] = &I03503;
  core[003504] = 07640; code[003504] = &I03504;
  core[003505] = 05647; code[003505] = &I03505;
  core[003506] = 07300; code[003506] = &I03506;
  core[003507] = 01247; code[003507] = &I03507;
  core[003510] = 07402; code[003510] = &I03510;
  core[003511] = 05647; code[003511] = &I03511;
  core[003512] = 00000; code[003512] = &S03512;
  core[003513] = 07300; code[003513] = &I03513;
  core[003514] = 01041; code[003514] = &I03514;
  core[003515] = 07004; code[003515] = &I03515;
  core[003516] = 07430; code[003516] = &L03516;
  core[003517] = 01342; code[003517] = &I03517;
  core[003520] = 03041; code[003520] = &I03520;
  core[003521] = 01041; code[003521] = &I03521;
  core[003522] = 07041; code[003522] = &I03522;
  core[003523] = 03043; code[003523] = &I03523;
  core[003524] = 07100; code[003524] = &I03524;
  core[003525] = 01341; code[003525] = &I03525;
  core[003526] = 07004; code[003526] = &I03526;
  core[003527] = 07430; code[003527] = &I03527;
  core[003530] = 01342; code[003530] = &I03530;
  core[003531] = 03341; code[003531] = &I03531;
  core[003532] = 07430; code[003532] = &I03532;
  core[003533] = 07040; code[003533] = &I03533;
  core[003534] = 03044; code[003534] = &I03534;
  core[003535] = 01044; code[003535] = &I03535;
  core[003536] = 07040; code[003536] = &I03536;
  core[003537] = 03045; code[003537] = &I03537;
  core[003540] = 05712; code[003540] = &I03540;
  core[003541] = 00001; code[003541] = &D03541;
  core[003542] = 00003; code[003542] = &P03542;
  core[003600] = 07340; code[003600] = &L03600;
  core[003601] = 00041; code[003601] = &I03601;
  core[003602] = 03346; code[003602] = &I03602;
  core[003603] = 07040; code[003603] = &I03603;
  core[003604] = 00041; code[003604] = &I03604;
  core[003605] = 07040; code[003605] = &I03605;
  core[003606] = 03347; code[003606] = &I03606;
  core[003607] = 07040; code[003607] = &I03607;
  core[003610] = 00103; code[003610] = &I03610;
  core[003611] = 03352; code[003611] = &I03611;
  core[003612] = 07040; code[003612] = &L03612;
  core[003613] = 00352; code[003613] = &I03613;
  core[003614] = 07040; code[003614] = &I03614;
  core[003615] = 03353; code[003615] = &I03615;
  core[003616] = 07040; code[003616] = &I03616;
  core[003617] = 00346; code[003617] = &I03617;
  core[003620] = 00352; code[003620] = &I03620;
  core[003621] = 07440; code[003621] = &I03621;
  core[003622] = 05232; code[003622] = &I03622;
  core[003623] = 07040; code[003623] = &I03623;
  core[003624] = 00346; code[003624] = &I03624;
  core[003625] = 04301; code[003625] = &I03625;
  core[003626] = 07040; code[003626] = &I03626;
  core[003627] = 00347; code[003627] = &I03627;
  core[003630] = 03351; code[003630] = &I03630;
  core[003631] = 05240; code[003631] = &I03631;
  core[003632] = 07240; code[003632] = &L03632;
  core[003633] = 00347; code[003633] = &I03633;
  core[003634] = 04315; code[003634] = &I03634;
  core[003635] = 07040; code[003635] = &I03635;
  core[003636] = 00346; code[003636] = &I03636;
  core[003637] = 03351; code[003637] = &I03637;
  core[003640] = 07340; code[003640] = &L03640;
  core[003641] = 00350; code[003641] = &I03641;
  core[003642] = 01351; code[003642] = &I03642;
  core[003643] = 07430; code[003643] = &I03643;
  core[003644] = 07001; code[003644] = &I03644;
  core[003645] = 04464; code[003645] = &I03645;
  core[003646] = 04463; code[003646] = &I03646;
  core[003647] = 07410; code[003647] = &I03647;
  core[003650] = 04756; code[003650] = &I03650;
  core[003651] = 04467; code[003651] = &I03651;
  core[003652] = 05240; code[003652] = &I03652;
  core[003653] = 05254; code[003653] = &I03653;
  core[003654] = 07340; code[003654] = &L03654;
  core[003655] = 00351; code[003655] = &I03655;
  core[003656] = 01350; code[003656] = &I03656;
  core[003657] = 07430; code[003657] = &I03657;
  core[003660] = 07001; code[003660] = &I03660;
  core[003661] = 04464; code[003661] = &I03661;
  core[003662] = 04463; code[003662] = &I03662;
  core[003663] = 07410; code[003663] = &I03663;
  core[003664] = 04756; code[003664] = &I03664;
  core[003665] = 04467; code[003665] = &I03665;
  core[003666] = 05254; code[003666] = &I03666;
  core[003667] = 07340; code[003667] = &I03667;
  core[003670] = 00352; code[003670] = &I03670;
  core[003671] = 07010; code[003671] = &I03671;
  core[003672] = 03352; code[003672] = &I03672;
  core[003673] = 07420; code[003673] = &I03673;
  core[003674] = 05212; code[003674] = &I03674;
  core[003675] = 04467; code[003675] = &I03675;
  core[003676] = 05200; code[003676] = &I03676;
  core[003677] = 05700; code[003677] = &I03677;
  core[003700] = 04200; code[003700] = &P03700;
  core[003701] = 00000; code[003701] = &S03701;
  core[003702] = 00353; code[003702] = &I03702;
  core[003703] = 07040; code[003703] = &I03703;
  core[003704] = 03354; code[003704] = &I03704;
  core[003705] = 07040; code[003705] = &I03705;
  core[003706] = 00347; code[003706] = &I03706;
  core[003707] = 00352; code[003707] = &I03707;
  core[003710] = 07040; code[003710] = &I03710;
  core[003711] = 00354; code[003711] = &I03711;
  core[003712] = 07040; code[003712] = &I03712;
  core[003713] = 03350; code[003713] = &I03713;
  core[003714] = 05701; code[003714] = &I03714;
  core[003715] = 00000; code[003715] = &S03715;
  core[003716] = 00352; code[003716] = &I03716;
  core[003717] = 07040; code[003717] = &I03717;
  core[003720] = 03354; code[003720] = &I03720;
  core[003721] = 07040; code[003721] = &I03721;
  core[003722] = 00346; code[003722] = &I03722;
  core[003723] = 00353; code[003723] = &I03723;
  core[003724] = 07040; code[003724] = &I03724;
  core[003725] = 00354; code[003725] = &I03725;
  core[003726] = 03350; code[003726] = &I03726;
  core[003727] = 05715; code[003727] = &I03727;
  core[003730] = 00000; code[003730] = &S03730;
  core[003731] = 07040; code[003731] = &I03731;
  core[003732] = 03355; code[003732] = &I03732;
  core[003733] = 07040; code[003733] = &I03733;
  core[003734] = 00025; code[003734] = &I03734;
  core[003735] = 00353; code[003735] = &I03735;
  core[003736] = 07440; code[003736] = &D03736;
  core[003737] = 05344; code[003737] = &I03737;
  core[003740] = 07040; code[003740] = &I03740;
  core[003741] = 00352; code[003741] = &I03741;
  core[003742] = 00355; code[003742] = &I03742;
  core[003743] = 07440; code[003743] = &I03743;
  core[003744] = 02330; code[003744] = &L03744;
  core[003745] = 05730; code[003745] = &I03745;
  core[003746] = 00000; code[003746] = &D03746;
  core[003747] = 00000; code[003747] = &D03747;
  core[003750] = 00000; code[003750] = &D03750;
  core[003751] = 00000; code[003751] = &D03751;
  core[003752] = 00000; code[003752] = &D03752;
  core[003753] = 00000; code[003753] = &D03753;
  core[003754] = 00000; code[003754] = &D03754;
  core[003755] = 00000; code[003755] = &D03755;
  core[003756] = 04000; code[003756] = &P03756;
  core[004000] = 00000; code[004000] = &S04000;
  core[004001] = 07604; code[004001] = &I04001;
  core[004002] = 00104; code[004002] = &I04002;
  core[004003] = 07640; code[004003] = &I04003;
  core[004004] = 05233; code[004004] = &I04004;
  core[004005] = 04446; code[004005] = &P04005;
  core[004006] = 05605; code[004006] = &I04006;
  core[004007] = 04446; code[004007] = &I04007;
  core[004010] = 05364; code[004010] = &I04010;
  core[004011] = 07340; code[004011] = &I04011;
  core[004012] = 00777; code[004012] = &I04012;
  core[004013] = 03037; code[004013] = &I04013;
  core[004014] = 04461; code[004014] = &I04014;
  core[004015] = 07040; code[004015] = &I04015;
  core[004016] = 00776; code[004016] = &I04016;
  core[004017] = 03037; code[004017] = &I04017;
  core[004020] = 04461; code[004020] = &I04020;
  core[004021] = 07040; code[004021] = &I04021;
  core[004022] = 00775; code[004022] = &D04022;
  core[004023] = 03037; code[004023] = &I04023;
  core[004024] = 04461; code[004024] = &D04024;
  core[004025] = 07040; code[004025] = &I04025;
  core[004026] = 00025; code[004026] = &I04026;
  core[004027] = 03037; code[004027] = &I04027;
  core[004030] = 04461; code[004030] = &I04030;
  core[004031] = 04446; code[004031] = &I04031;
  core[004032] = 05742; code[004032] = &I04032;
  core[004033] = 07604; code[004033] = &L04033;
  core[004034] = 00103; code[004034] = &I04034;
  core[004035] = 07640; code[004035] = &I04035;
  core[004036] = 05600; code[004036] = &I04036;
  core[004037] = 07300; code[004037] = &I04037;
  core[004040] = 01200; code[004040] = &D04040;
  core[004041] = 07402; code[004041] = &I04041;
  core[004042] = 05600; code[004042] = &I04042;
  core[004175] = 03752; code[004175] = &P04175;
  core[004176] = 03751; code[004176] = &P04176;
  core[004177] = 03750; code[004177] = &P04177;
  core[004200] = 07300; code[004200] = &L04200;
  core[004201] = 01044; code[004201] = &I04201;
  core[004202] = 07440; code[004202] = &I04202;
  core[004203] = 07220; code[004203] = &I04203;
  core[004204] = 01041; code[004204] = &I04204;
  core[004205] = 07010; code[004205] = &I04205;
  core[004206] = 07010; code[004206] = &I04206;
  core[004207] = 07010; code[004207] = &I04207;
  core[004210] = 07010; code[004210] = &I04210;
  core[004211] = 07010; code[004211] = &I04211;
  core[004212] = 07010; code[004212] = &I04212;
  core[004213] = 07010; code[004213] = &I04213;
  core[004214] = 07010; code[004214] = &I04214;
  core[004215] = 07010; code[004215] = &I04215;
  core[004216] = 07010; code[004216] = &I04216;
  core[004217] = 07010; code[004217] = &I04217;
  core[004220] = 07010; code[004220] = &I04220;
  core[004221] = 07010; code[004221] = &I04221;
  core[004222] = 07010; code[004222] = &I04222;
  core[004223] = 07010; code[004223] = &I04223;
  core[004224] = 07010; code[004224] = &I04224;
  core[004225] = 07010; code[004225] = &I04225;
  core[004226] = 07010; code[004226] = &I04226;
  core[004227] = 07010; code[004227] = &I04227;
  core[004230] = 07010; code[004230] = &I04230;
  core[004231] = 07010; code[004231] = &I04231;
  core[004232] = 07010; code[004232] = &I04232;
  core[004233] = 07010; code[004233] = &I04233;
  core[004234] = 07010; code[004234] = &I04234;
  core[004235] = 07010; code[004235] = &I04235;
  core[004236] = 07010; code[004236] = &I04236;
  core[004237] = 07000; code[004237] = &I04237;
  core[004240] = 07000; code[004240] = &I04240;
  core[004241] = 04464; code[004241] = &I04241;
  core[004242] = 01043; code[004242] = &I04242;
  core[004243] = 07640; code[004243] = &I04243;
  core[004244] = 05250; code[004244] = &I04244;
  core[004245] = 01044; code[004245] = &I04245;
  core[004246] = 03037; code[004246] = &I04246;
  core[004247] = 01026; code[004247] = &I04247;
  core[004250] = 03040; code[004250] = &L04250;
  core[004251] = 04462; code[004251] = &I04251;
  core[004252] = 04735; code[004252] = &I04252;
  core[004253] = 04467; code[004253] = &I04253;
  core[004254] = 05200; code[004254] = &I04254;
  core[004255] = 07300; code[004255] = &L04255;
  core[004256] = 01044; code[004256] = &I04256;
  core[004257] = 07440; code[004257] = &I04257;
  core[004260] = 07220; code[004260] = &I04260;
  core[004261] = 01041; code[004261] = &I04261;
  core[004262] = 07004; code[004262] = &I04262;
  core[004263] = 07004; code[004263] = &I04263;
  core[004264] = 07004; code[004264] = &I04264;
  core[004265] = 07004; code[004265] = &I04265;
  core[004266] = 07004; code[004266] = &I04266;
  core[004267] = 07004; code[004267] = &I04267;
  core[004270] = 07004; code[004270] = &I04270;
  core[004271] = 07004; code[004271] = &I04271;
  core[004272] = 07004; code[004272] = &I04272;
  core[004273] = 07004; code[004273] = &I04273;
  core[004274] = 07004; code[004274] = &I04274;
  core[004275] = 07004; code[004275] = &I04275;
  core[004276] = 07004; code[004276] = &I04276;
  core[004277] = 07004; code[004277] = &I04277;
  core[004300] = 07004; code[004300] = &I04300;
  core[004301] = 07004; code[004301] = &I04301;
  core[004302] = 07004; code[004302] = &I04302;
  core[004303] = 07004; code[004303] = &I04303;
  core[004304] = 07004; code[004304] = &I04304;
  core[004305] = 07004; code[004305] = &I04305;
  core[004306] = 07004; code[004306] = &I04306;
  core[004307] = 07004; code[004307] = &I04307;
  core[004310] = 07004; code[004310] = &I04310;
  core[004311] = 07004; code[004311] = &I04311;
  core[004312] = 07004; code[004312] = &I04312;
  core[004313] = 07004; code[004313] = &I04313;
  core[004314] = 07000; code[004314] = &I04314;
  core[004315] = 07000; code[004315] = &I04315;
  core[004316] = 04464; code[004316] = &I04316;
  core[004317] = 01043; code[004317] = &I04317;
  core[004320] = 07440; code[004320] = &I04320;
  core[004321] = 05325; code[004321] = &I04321;
  core[004322] = 01044; code[004322] = &I04322;
  core[004323] = 03037; code[004323] = &I04323;
  core[004324] = 01026; code[004324] = &I04324;
  core[004325] = 03040; code[004325] = &L04325;
  core[004326] = 04462; code[004326] = &I04326;
  core[004327] = 04734; code[004327] = &I04327;
  core[004330] = 04467; code[004330] = &I04330;
  core[004331] = 05255; code[004331] = &I04331;
  core[004332] = 05733; code[004332] = &I04332;
  core[004333] = 04400; code[004333] = &P04333;
  core[004334] = 05013; code[004334] = &P04334;
  core[004335] = 05000; code[004335] = &P04335;
  core[004400] = 07300; code[004400] = &P04400;
  core[004401] = 01044; code[004401] = &I04401;
  core[004402] = 07440; code[004402] = &I04402;
  core[004403] = 07220; code[004403] = &I04403;
  core[004404] = 01041; code[004404] = &I04404;
  core[004405] = 07006; code[004405] = &I04405;
  core[004406] = 07006; code[004406] = &I04406;
  core[004407] = 07006; code[004407] = &I04407;
  core[004410] = 07006; code[004410] = &I04410;
  core[004411] = 07006; code[004411] = &I04411;
  core[004412] = 07006; code[004412] = &I04412;
  core[004413] = 07006; code[004413] = &I04413;
  core[004414] = 07006; code[004414] = &I04414;
  core[004415] = 07006; code[004415] = &I04415;
  core[004416] = 07006; code[004416] = &I04416;
  core[004417] = 07006; code[004417] = &I04417;
  core[004420] = 07006; code[004420] = &I04420;
  core[004421] = 07006; code[004421] = &I04421;
  core[004422] = 07006; code[004422] = &I04422;
  core[004423] = 07006; code[004423] = &I04423;
  core[004424] = 07006; code[004424] = &I04424;
  core[004425] = 07006; code[004425] = &I04425;
  core[004426] = 07006; code[004426] = &I04426;
  core[004427] = 07006; code[004427] = &I04427;
  core[004430] = 07006; code[004430] = &I04430;
  core[004431] = 07006; code[004431] = &I04431;
  core[004432] = 07006; code[004432] = &I04432;
  core[004433] = 07006; code[004433] = &I04433;
  core[004434] = 07006; code[004434] = &I04434;
  core[004435] = 07006; code[004435] = &I04435;
  core[004436] = 07006; code[004436] = &I04436;
  core[004437] = 07000; code[004437] = &I04437;
  core[004440] = 07000; code[004440] = &I04440;
  core[004441] = 04464; code[004441] = &I04441;
  core[004442] = 01043; code[004442] = &I04442;
  core[004443] = 07440; code[004443] = &I04443;
  core[004444] = 05250; code[004444] = &I04444;
  core[004445] = 01044; code[004445] = &I04445;
  core[004446] = 03037; code[004446] = &L04446;
  core[004447] = 01026; code[004447] = &I04447;
  core[004450] = 03040; code[004450] = &L04450;
  core[004451] = 04462; code[004451] = &I04451;
  core[004452] = 04771; code[004452] = &I04452;
  core[004453] = 04467; code[004453] = &I04453;
  core[004454] = 05200; code[004454] = &I04454;
  core[004455] = 07300; code[004455] = &L04455;
  core[004456] = 01044; code[004456] = &I04456;
  core[004457] = 07440; code[004457] = &I04457;
  core[004460] = 07220; code[004460] = &L04460;
  core[004461] = 01041; code[004461] = &I04461;
  core[004462] = 07012; code[004462] = &I04462;
  core[004463] = 07012; code[004463] = &I04463;
  core[004464] = 07012; code[004464] = &I04464;
  core[004465] = 07012; code[004465] = &I04465;
  core[004466] = 07012; code[004466] = &I04466;
  core[004467] = 07012; code[004467] = &I04467;
  core[004470] = 07012; code[004470] = &I04470;
  core[004471] = 07012; code[004471] = &I04471;
  core[004472] = 07012; code[004472] = &I04472;
  core[004473] = 07012; code[004473] = &I04473;
  core[004474] = 07012; code[004474] = &I04474;
  core[004475] = 07012; code[004475] = &I04475;
  core[004476] = 07012; code[004476] = &I04476;
  core[004477] = 07012; code[004477] = &I04477;
  core[004500] = 07012; code[004500] = &I04500;
  core[004501] = 07012; code[004501] = &I04501;
  core[004502] = 07012; code[004502] = &I04502;
  core[004503] = 07012; code[004503] = &I04503;
  core[004504] = 07012; code[004504] = &I04504;
  core[004505] = 07012; code[004505] = &I04505;
  core[004506] = 07012; code[004506] = &I04506;
  core[004507] = 07012; code[004507] = &I04507;
  core[004510] = 07012; code[004510] = &I04510;
  core[004511] = 07012; code[004511] = &I04511;
  core[004512] = 07012; code[004512] = &I04512;
  core[004513] = 07012; code[004513] = &I04513;
  core[004514] = 07000; code[004514] = &I04514;
  core[004515] = 07000; code[004515] = &I04515;
  core[004516] = 04464; code[004516] = &I04516;
  core[004517] = 01043; code[004517] = &I04517;
  core[004520] = 07440; code[004520] = &I04520;
  core[004521] = 05325; code[004521] = &I04521;
  core[004522] = 01044; code[004522] = &I04522;
  core[004523] = 03037; code[004523] = &I04523;
  core[004524] = 01026; code[004524] = &I04524;
  core[004525] = 03040; code[004525] = &L04525;
  core[004526] = 04462; code[004526] = &I04526;
  core[004527] = 04770; code[004527] = &I04527;
  core[004530] = 04467; code[004530] = &I04530;
  core[004531] = 05255; code[004531] = &I04531;
  core[004532] = 02020; code[004532] = &I04532;
  core[004533] = 05366; code[004533] = &I04533;
  core[004534] = 07604; code[004534] = &I04534;
  core[004535] = 00115; code[004535] = &P04535;
  core[004536] = 07650; code[004536] = &I04536;
  core[004537] = 05363; code[004537] = &I04537;
  core[004540] = 07604; code[004540] = &L04540;
  core[004541] = 00114; code[004541] = &I04541;
  core[004542] = 07640; code[004542] = &I04542;
  core[004543] = 07402; code[004543] = &I04543;
  core[004544] = 07604; code[004544] = &I04544;
  core[004545] = 00116; code[004545] = &I04545;
  core[004546] = 07640; code[004546] = &I04546;
  core[004547] = 05366; code[004547] = &I04547;
  core[004550] = 07604; code[004550] = &L04550;
  core[004551] = 00173; code[004551] = &I04551;
  core[004552] = 07110; code[004552] = &I04552;
  core[004553] = 07012; code[004553] = &I04553;
  core[004554] = 03175; code[004554] = &I04554;
  core[004555] = 07604; code[004555] = &I04555;
  core[004556] = 00107; code[004556] = &I04556;
  core[004557] = 07640; code[004557] = &I04557;
  core[004560] = 05772; code[004560] = &I04560;
  core[004561] = 05762; code[004561] = &I04561;
  core[004562] = 00200; code[004562] = &P04562;
  core[004563] = 04446; code[004563] = &L04563;
  core[004564] = 05735; code[004564] = &I04564;
  core[004565] = 05340; code[004565] = &I04565;
  core[004566] = 05767; code[004566] = &L04566;
  core[004567] = 03400; code[004567] = &P04567;
  core[004570] = 05026; code[004570] = &P04570;
  core[004571] = 05041; code[004571] = &P04571;
  core[004572] = 04600; code[004572] = &P04572;
  core[004600] = 04231; code[004600] = &L04600;
  core[004601] = 04264; code[004601] = &I04601;
  core[004602] = 07346; code[004602] = &I04602;
  core[004603] = 04341; code[004603] = &I04603;
  core[004604] = 04331; code[004604] = &I04604;
  core[004605] = 04352; code[004605] = &I04605;
  core[004606] = 04446; code[004606] = &I04606;
  core[004607] = 05755; code[004607] = &I04607;
  core[004610] = 04360; code[004610] = &I04610;
  core[004611] = 04331; code[004611] = &I04611;
  core[004612] = 07344; code[004612] = &D04612;
  core[004613] = 04341; code[004613] = &I04613;
  core[004614] = 01175; code[004614] = &I04614;
  core[004615] = 07041; code[004615] = &D04615;
  core[004616] = 01174; code[004616] = &I04616;
  core[004617] = 07650; code[004617] = &I04617;
  core[004620] = 05223; code[004620] = &I04620;
  core[004621] = 07602; code[004621] = &I04621;
  core[004622] = 05770; code[004622] = &I04622;
  core[004623] = 01314; code[004623] = &L04623;
  core[004624] = 01115; code[004624] = &I04624;
  core[004625] = 03226; code[004625] = &I04625;
  core[004626] = 00000; code[004626] = &D04626;
  core[004627] = 05630; code[004627] = &I04627;
  core[004630] = 00200; code[004630] = &P04630;
  core[004631] = 00000; code[004631] = &S04631;
  core[004632] = 07300; code[004632] = &I04632;
  core[004633] = 03174; code[004633] = &I04633;
  core[004634] = 01371; code[004634] = &I04634;
  core[004635] = 03176; code[004635] = &I04635;
  core[004636] = 06201; code[004636] = &I04636;
  core[004637] = 03571; code[004637] = &I04637;
  core[004640] = 01372; code[004640] = &I04640;
  core[004641] = 01113; code[004641] = &L04641;
  core[004642] = 03243; code[004642] = &I04642;
  core[004643] = 00000; code[004643] = &D04643;
  core[004644] = 07340; code[004644] = &I04644;
  core[004645] = 03571; code[004645] = &I04645;
  core[004646] = 01571; code[004646] = &I04646;
  core[004647] = 07650; code[004647] = &I04647;
  core[004650] = 05255; code[004650] = &I04650;
  core[004651] = 02174; code[004651] = &I04651;
  core[004652] = 01243; code[004652] = &D04652;
  core[004653] = 02176; code[004653] = &I04653;
  core[004654] = 05241; code[004654] = &I04654;
  core[004655] = 07300; code[004655] = &L04655;
  core[004656] = 06201; code[004656] = &I04656;
  core[004657] = 01571; code[004657] = &I04657;
  core[004660] = 07650; code[004660] = &I04660;
  core[004661] = 05631; code[004661] = &I04661;
  core[004662] = 07602; code[004662] = &I04662;
  core[004663] = 05274; code[004663] = &I04663;
  core[004664] = 00000; code[004664] = &S04664;
  core[004665] = 07300; code[004665] = &I04665;
  core[004666] = 03176; code[004666] = &I04666;
  core[004667] = 06224; code[004667] = &I04667;
  core[004670] = 01113; code[004670] = &I04670;
  core[004671] = 00375; code[004671] = &I04671;
  core[004672] = 03312; code[004672] = &I04672;
  core[004673] = 07301; code[004673] = &I04673;
  core[004674] = 01174; code[004674] = &L04674;
  core[004675] = 07004; code[004675] = &I04675;
  core[004676] = 07006; code[004676] = &I04676;
  core[004677] = 07041; code[004677] = &I04677;
  core[004700] = 01312; code[004700] = &I04700;
  core[004701] = 07620; code[004701] = &I04701;
  core[004702] = 01312; code[004702] = &I04702;
  core[004703] = 01372; code[004703] = &I04703;
  core[004704] = 03314; code[004704] = &I04704;
  core[004705] = 06224; code[004705] = &I04705;
  core[004706] = 01372; code[004706] = &I04706;
  core[004707] = 03312; code[004707] = &I04707;
  core[004710] = 01312; code[004710] = &I04710;
  core[004711] = 03317; code[004711] = &I04711;
  core[004712] = 00000; code[004712] = &L04712;
  core[004713] = 01576; code[004713] = &I04713;
  core[004714] = 00000; code[004714] = &D04714;
  core[004715] = 03576; code[004715] = &I04715;
  core[004716] = 01576; code[004716] = &I04716;
  core[004717] = 00000; code[004717] = &D04717;
  core[004720] = 07041; code[004720] = &I04720;
  core[004721] = 01576; code[004721] = &I04721;
  core[004722] = 07650; code[004722] = &I04722;
  core[004723] = 05326; code[004723] = &I04723;
  core[004724] = 07602; code[004724] = &I04724;
  core[004725] = 05312; code[004725] = &I04725;
  core[004726] = 02176; code[004726] = &L04726;
  core[004727] = 05312; code[004727] = &I04727;
  core[004730] = 05664; code[004730] = &I04730;
  core[004731] = 00000; code[004731] = &S04731;
  core[004732] = 01371; code[004732] = &I04732;
  core[004733] = 03176; code[004733] = &I04733;
  core[004734] = 01376; code[004734] = &L04734;
  core[004735] = 04447; code[004735] = &I04735;
  core[004736] = 02176; code[004736] = &I04736;
  core[004737] = 05334; code[004737] = &I04737;
  core[004740] = 05731; code[004740] = &I04740;
  core[004741] = 00000; code[004741] = &S04741;
  core[004742] = 03176; code[004742] = &I04742;
  core[004743] = 01374; code[004743] = &L04743;
  core[004744] = 04447; code[004744] = &I04744;
  core[004745] = 01373; code[004745] = &I04745;
  core[004746] = 04447; code[004746] = &I04746;
  core[004747] = 02176; code[004747] = &I04747;
  core[004750] = 05343; code[004750] = &I04750;
  core[004751] = 05741; code[004751] = &I04751;
  core[004752] = 00000; code[004752] = &S04752;
  core[004753] = 01174; code[004753] = &I04753;
  core[004754] = 00172; code[004754] = &I04754;
  core[004755] = 01077; code[004755] = &P04755;
  core[004756] = 04447; code[004756] = &I04756;
  core[004757] = 05752; code[004757] = &I04757;
  core[004760] = 00000; code[004760] = &S04760;
  core[004761] = 01314; code[004761] = &I04761;
  core[004762] = 00173; code[004762] = &I04762;
  core[004763] = 07010; code[004763] = &I04763;
  core[004764] = 07012; code[004764] = &I04764;
  core[004765] = 01077; code[004765] = &I04765;
  core[004766] = 04447; code[004766] = &I04766;
  core[004767] = 05760; code[004767] = &I04767;
  core[004770] = 04550; code[004770] = &P04770;
  core[004771] = 07771; code[004771] = &D04771;
  core[004772] = 06201; code[004772] = &D04772;
  core[004773] = 00212; code[004773] = &D04773;
  core[004774] = 00215; code[004774] = &D04774;
  core[004775] = 00170; code[004775] = &D04775;
  core[004776] = 00252; code[004776] = &D04776;
  core[005000] = 00000; code[005000] = &D05000;
  core[005001] = 07604; code[005001] = &L05001;
  core[005002] = 00104; code[005002] = &I05002;
  core[005003] = 07640; code[005003] = &I05003;
  core[005004] = 05210; code[005004] = &I05004;
  core[005005] = 04446; code[005005] = &I05005;
  core[005006] = 05625; code[005006] = &I05006;
  core[005007] = 04264; code[005007] = &I05007;
  core[005010] = 07300; code[005010] = &L05010;
  core[005011] = 01200; code[005011] = &I05011;
  core[005012] = 05253; code[005012] = &I05012;
  core[005013] = 00000; code[005013] = &D05013;
  core[005014] = 07604; code[005014] = &I05014;
  core[005015] = 00104; code[005015] = &I05015;
  core[005016] = 07640; code[005016] = &I05016;
  core[005017] = 05223; code[005017] = &I05017;
  core[005020] = 04446; code[005020] = &I05020;
  core[005021] = 05644; code[005021] = &I05021;
  core[005022] = 04264; code[005022] = &I05022;
  core[005023] = 07300; code[005023] = &L05023;
  core[005024] = 01213; code[005024] = &I05024;
  core[005025] = 05253; code[005025] = &P05025;
  core[005026] = 00000; code[005026] = &D05026;
  core[005027] = 07604; code[005027] = &I05027;
  core[005030] = 00104; code[005030] = &I05030;
  core[005031] = 07640; code[005031] = &I05031;
  core[005032] = 05236; code[005032] = &I05032;
  core[005033] = 04446; code[005033] = &I05033;
  core[005034] = 05663; code[005034] = &I05034;
  core[005035] = 04264; code[005035] = &I05035;
  core[005036] = 07300; code[005036] = &L05036;
  core[005037] = 01226; code[005037] = &I05037;
  core[005040] = 05253; code[005040] = &I05040;
  core[005041] = 00000; code[005041] = &D05041;
  core[005042] = 07604; code[005042] = &I05042;
  core[005043] = 00104; code[005043] = &I05043;
  core[005044] = 07640; code[005044] = &P05044;
  core[005045] = 05251; code[005045] = &I05045;
  core[005046] = 04446; code[005046] = &I05046;
  core[005047] = 05702; code[005047] = &I05047;
  core[005050] = 04264; code[005050] = &I05050;
  core[005051] = 07300; code[005051] = &L05051;
  core[005052] = 01241; code[005052] = &I05052;
  core[005053] = 03263; code[005053] = &L05053;
  core[005054] = 07604; code[005054] = &I05054;
  core[005055] = 00103; code[005055] = &I05055;
  core[005056] = 07640; code[005056] = &I05056;
  core[005057] = 05262; code[005057] = &I05057;
  core[005060] = 01263; code[005060] = &I05060;
  core[005061] = 07402; code[005061] = &I05061;
  core[005062] = 05663; code[005062] = &L05062;
  core[005063] = 00000; code[005063] = &P05063;
  core[005064] = 00000; code[005064] = &S05064;
  core[005065] = 04446; code[005065] = &I05065;
  core[005066] = 05347; code[005066] = &I05066;
  core[005067] = 07340; code[005067] = &I05067;
  core[005070] = 00044; code[005070] = &I05070;
  core[005071] = 03040; code[005071] = &I05071;
  core[005072] = 07040; code[005072] = &I05072;
  core[005073] = 00041; code[005073] = &I05073;
  core[005074] = 03037; code[005074] = &I05074;
  core[005075] = 04460; code[005075] = &I05075;
  core[005076] = 04461; code[005076] = &I05076;
  core[005077] = 07040; code[005077] = &I05077;
  core[005100] = 00026; code[005100] = &I05100;
  core[005101] = 03040; code[005101] = &I05101;
  core[005102] = 04460; code[005102] = &P05102;
  core[005103] = 07040; code[005103] = &I05103;
  core[005104] = 00025; code[005104] = &I05104;
  core[005105] = 03037; code[005105] = &I05105;
  core[005106] = 04461; code[005106] = &I05106;
  core[005107] = 04446; code[005107] = &I05107;
  core[005110] = 05742; code[005110] = &I05110;
  core[005111] = 05664; code[005111] = &I05111;
  core[005200] = 03736; code[005200] = &P05200;
  core[005201] = 04040; code[005201] = &P05201;
  core[005202] = 04001; code[005202] = &I05202;
  core[005203] = 02207; code[005203] = &I05203;
  core[005204] = 06140; code[005204] = &P05204;
  core[005205] = 04040; code[005205] = &D05205;
  core[005206] = 04040; code[005206] = &I05206;
  core[005207] = 04040; code[005207] = &D05207;
  core[005210] = 04040; code[005210] = &I05210;
  core[005211] = 00122; code[005211] = &D05211;
  core[005212] = 00762; code[005212] = &I05212;
  core[005213] = 04040; code[005213] = &I05213;
  core[005214] = 04040; code[005214] = &I05214;
  core[005215] = 04040; code[005215] = &I05215;
  core[005216] = 04040; code[005216] = &D05216;
  core[005217] = 04023; code[005217] = &I05217;
  core[005220] = 01115; code[005220] = &I05220;
  core[005221] = 02514; code[005221] = &I05221;
  core[005222] = 00124; code[005222] = &I05222;
  core[005223] = 00504; code[005223] = &I05223;
  core[005224] = 04040; code[005224] = &I05224;
  core[005225] = 04040; code[005225] = &I05225;
  core[005226] = 04040; code[005226] = &I05226;
  core[005227] = 04001; code[005227] = &I05227;
  core[005230] = 02207; code[005230] = &I05230;
  core[005231] = 06153; code[005231] = &I05231;
  core[005232] = 00122; code[005232] = &I05232;
  core[005233] = 00762; code[005233] = &I05233;
  core[005234] = 04040; code[005234] = &I05234;
  core[005235] = 04040; code[005235] = &I05235;
  core[005236] = 04001; code[005236] = &I05236;
  core[005237] = 02207; code[005237] = &I05237;
  core[005240] = 06253; code[005240] = &I05240;
  core[005241] = 00122; code[005241] = &I05241;
  core[005242] = 00761; code[005242] = &I05242;
  core[005243] = 03736; code[005243] = &I05243;
  core[005244] = 00000; code[005244] = &I05244;
  core[005245] = 03736; code[005245] = &I05245;
  core[005246] = 04040; code[005246] = &I05246;
  core[005247] = 04040; code[005247] = &I05247;
  core[005250] = 04017; code[005250] = &I05250;
  core[005251] = 02211; code[005251] = &I05251;
  core[005252] = 00711; code[005252] = &I05252;
  core[005253] = 01601; code[005253] = &L05253;
  core[005254] = 01440; code[005254] = &I05254;
  core[005255] = 04040; code[005255] = &I05255;
  core[005256] = 04040; code[005256] = &I05256;
  core[005257] = 04023; code[005257] = &I05257;
  core[005260] = 01115; code[005260] = &I05260;
  core[005261] = 02514; code[005261] = &I05261;
  core[005262] = 00124; code[005262] = &I05262;
  core[005263] = 00504; code[005263] = &I05263;
  core[005264] = 04040; code[005264] = &I05264;
  core[005265] = 04040; code[005265] = &I05265;
  core[005266] = 04040; code[005266] = &I05266;
  core[005267] = 04001; code[005267] = &I05267;
  core[005270] = 00324; code[005270] = &I05270;
  core[005271] = 02501; code[005271] = &I05271;
  core[005272] = 01437; code[005272] = &I05272;
  core[005273] = 03600; code[005273] = &I05273;
  core[005274] = 03736; code[005274] = &I05274;
  core[005275] = 02201; code[005275] = &I05275;
  core[005276] = 01604; code[005276] = &I05276;
  core[005277] = 00140; code[005277] = &I05277;
  core[005300] = 04040; code[005300] = &I05300;
  core[005301] = 04040; code[005301] = &I05301;
  core[005302] = 04040; code[005302] = &I05302;
  core[005303] = 04022; code[005303] = &I05303;
  core[005304] = 00116; code[005304] = &I05304;
  core[005305] = 00403; code[005305] = &I05305;
  core[005306] = 04040; code[005306] = &I05306;
  core[005307] = 04040; code[005307] = &I05307;
  core[005310] = 04040; code[005310] = &I05310;
  core[005311] = 04040; code[005311] = &P05311;
  core[005312] = 02205; code[005312] = &I05312;
  core[005313] = 02325; code[005313] = &I05313;
  core[005314] = 01424; code[005314] = &I05314;
  core[005315] = 03736; code[005315] = &I05315;
  core[005316] = 00000; code[005316] = &I05316;
  core[005317] = 03736; code[005317] = &I05317;
  core[005320] = 02201; code[005320] = &I05320;
  core[005321] = 01604; code[005321] = &I05321;
  core[005322] = 00140; code[005322] = &P05322;
  core[005323] = 04040; code[005323] = &I05323;
  core[005324] = 04040; code[005324] = &D05324;
  core[005325] = 04040; code[005325] = &D05325;
  core[005326] = 04002; code[005326] = &I05326;
  core[005327] = 02017; code[005327] = &I05327;
  core[005330] = 02340; code[005330] = &I05330;
  core[005331] = 04040; code[005331] = &I05331;
  core[005332] = 04040; code[005332] = &I05332;
  core[005333] = 04040; code[005333] = &I05333;
  core[005334] = 04040; code[005334] = &I05334;
  core[005335] = 00216; code[005335] = &I05335;
  core[005336] = 00507; code[005336] = &P05336;
  core[005337] = 04040; code[005337] = &I05337;
  core[005340] = 04040; code[005340] = &D05340;
  core[005341] = 04040; code[005341] = &I05341;
  core[005342] = 04040; code[005342] = &I05342;
  core[005343] = 04022; code[005343] = &I05343;
  core[005344] = 00523; code[005344] = &I05344;
  core[005345] = 02514; code[005345] = &I05345;
  core[005346] = 02437; code[005346] = &I05346;
  core[005347] = 03600; code[005347] = &I05347;
  core[005350] = 03736; code[005350] = &I05350;
  core[005351] = 01722; code[005351] = &I05351;
  core[005352] = 01107; code[005352] = &I05352;
  core[005353] = 01116; code[005353] = &I05353;
  core[005354] = 00114; code[005354] = &I05354;
  core[005355] = 04040; code[005355] = &I05355;
  core[005356] = 04040; code[005356] = &I05356;
  core[005357] = 04040; code[005357] = &I05357;
  core[005360] = 00103; code[005360] = &I05360;
  core[005361] = 02425; code[005361] = &P05361;
  core[005362] = 00114; code[005362] = &P05362;
  core[005363] = 03736; code[005363] = &I05363;
  core[005364] = 00000; code[005364] = &I05364;
  core[005365] = 03736; code[005365] = &I05365;
  core[005366] = 04040; code[005366] = &I05366;
  core[005367] = 04040; code[005367] = &I05367;
  core[005370] = 00122; code[005370] = &I05370;
  core[005371] = 00761; code[005371] = &I05371;
  core[005372] = 04040; code[005372] = &I05372;
  core[005373] = 04040; code[005373] = &I05373;
  core[005374] = 04040; code[005374] = &I05374;
  core[005375] = 04040; code[005375] = &I05375;
  core[005376] = 04001; code[005376] = &I05376;
  core[005377] = 02207; code[005377] = &I05377;
  core[005400] = 06240; code[005400] = &I05400;
  core[005401] = 04040; code[005401] = &P05401;
  core[005402] = 04040; code[005402] = &I05402;
  core[005403] = 04040; code[005403] = &I05403;
  core[005404] = 00530; code[005404] = &D05404;
  core[005405] = 02005; code[005405] = &I05405;
  core[005406] = 00324; code[005406] = &I05406;
  core[005407] = 00504; code[005407] = &I05407;
  core[005410] = 04040; code[005410] = &I05410;
  core[005411] = 04040; code[005411] = &I05411;
  core[005412] = 04040; code[005412] = &I05412;
  core[005413] = 00103; code[005413] = &I05413;
  core[005414] = 02425; code[005414] = &I05414;
  core[005415] = 00114; code[005415] = &I05415;
  core[005416] = 03736; code[005416] = &I05416;
  core[005417] = 00000; code[005417] = &I05417;
  core[005420] = 03736; code[005420] = &I05420;
  core[005421] = 04040; code[005421] = &I05421;
  core[005422] = 04040; code[005422] = &I05422;
  core[005423] = 04023; code[005423] = &I05423;
  core[005424] = 01115; code[005424] = &I05424;
  core[005425] = 02514; code[005425] = &I05425;
  core[005426] = 00124; code[005426] = &I05426;
  core[005427] = 00504; code[005427] = &I05427;
  core[005430] = 04001; code[005430] = &I05430;
  core[005431] = 00404; code[005431] = &I05431;
  core[005432] = 04024; code[005432] = &I05432;
  core[005433] = 00523; code[005433] = &I05433;
  core[005434] = 02440; code[005434] = &I05434;
  core[005435] = 00601; code[005435] = &I05435;
  core[005436] = 01114; code[005436] = &I05436;
  core[005437] = 00504; code[005437] = &I05437;
  core[005440] = 00000; code[005440] = &I05440;
  core[005441] = 03736; code[005441] = &I05441;
  core[005442] = 04040; code[005442] = &I05442;
  core[005443] = 04040; code[005443] = &I05443;
  core[005444] = 04023; code[005444] = &I05444;
  core[005445] = 01115; code[005445] = &I05445;
  core[005446] = 02514; code[005446] = &I05446;
  core[005447] = 00124; code[005447] = &I05447;
  core[005450] = 00504; code[005450] = &I05450;
  core[005451] = 04022; code[005451] = &I05451;
  core[005452] = 00114; code[005452] = &I05452;
  core[005453] = 04024; code[005453] = &I05453;
  core[005454] = 00523; code[005454] = &I05454;
  core[005455] = 02440; code[005455] = &I05455;
  core[005456] = 00601; code[005456] = &I05456;
  core[005457] = 01114; code[005457] = &I05457;
  core[005460] = 00504; code[005460] = &I05460;
  core[005461] = 00000; code[005461] = &I05461;
  core[005462] = 03736; code[005462] = &I05462;
  core[005463] = 04040; code[005463] = &I05463;
  core[005464] = 04040; code[005464] = &I05464;
  core[005465] = 04023; code[005465] = &I05465;
  core[005466] = 01115; code[005466] = &I05466;
  core[005467] = 02514; code[005467] = &I05467;
  core[005470] = 00124; code[005470] = &I05470;
  core[005471] = 00504; code[005471] = &I05471;
  core[005472] = 04022; code[005472] = &I05472;
  core[005473] = 00122; code[005473] = &I05473;
  core[005474] = 04024; code[005474] = &I05474;
  core[005475] = 00523; code[005475] = &I05475;
  core[005476] = 02440; code[005476] = &I05476;
  core[005477] = 00601; code[005477] = &I05477;
  core[005500] = 01114; code[005500] = &I05500;
  core[005501] = 00504; code[005501] = &I05501;
  core[005502] = 00000; code[005502] = &I05502;
  core[005503] = 03736; code[005503] = &I05503;
  core[005504] = 04040; code[005504] = &I05504;
  core[005505] = 04040; code[005505] = &I05505;
  core[005506] = 04023; code[005506] = &I05506;
  core[005507] = 01115; code[005507] = &I05507;
  core[005510] = 02514; code[005510] = &I05510;
  core[005511] = 00124; code[005511] = &I05511;
  core[005512] = 00504; code[005512] = &I05512;
  core[005513] = 04022; code[005513] = &I05513;
  core[005514] = 02414; code[005514] = &I05514;
  core[005515] = 04024; code[005515] = &I05515;
  core[005516] = 00523; code[005516] = &I05516;
  core[005517] = 02440; code[005517] = &I05517;
  core[005520] = 00601; code[005520] = &I05520;
  core[005521] = 01114; code[005521] = &I05521;
  core[005522] = 00504; code[005522] = &I05522;
  core[005523] = 00000; code[005523] = &I05523;
  core[005524] = 03736; code[005524] = &D05524;
  core[005525] = 04040; code[005525] = &I05525;
  core[005526] = 04040; code[005526] = &I05526;
  core[005527] = 04023; code[005527] = &D05527;
  core[005530] = 01115; code[005530] = &I05530;
  core[005531] = 02514; code[005531] = &I05531;
  core[005532] = 00124; code[005532] = &I05532;
  core[005533] = 00504; code[005533] = &I05533;
  core[005534] = 04022; code[005534] = &I05534;
  core[005535] = 02422; code[005535] = &I05535;
  core[005536] = 04024; code[005536] = &P05536;
  core[005537] = 00523; code[005537] = &I05537;
  core[005540] = 02440; code[005540] = &I05540;
  core[005541] = 00601; code[005541] = &I05541;
  core[005542] = 01114; code[005542] = &I05542;
  core[005543] = 00504; code[005543] = &I05543;
  core[005544] = 00000; code[005544] = &I05544;
  core[005545] = 03736; code[005545] = &I05545;
  core[005546] = 04040; code[005546] = &I05546;
  core[005547] = 04040; code[005547] = &I05547;
  core[005550] = 04023; code[005550] = &I05550;
  core[005551] = 01115; code[005551] = &I05551;
  core[005552] = 02514; code[005552] = &I05552;
  core[005553] = 00124; code[005553] = &I05553;
  core[005554] = 00504; code[005554] = &I05554;
  core[005555] = 04002; code[005555] = &I05555;
  core[005556] = 02327; code[005556] = &I05556;
  core[005557] = 04024; code[005557] = &I05557;
  core[005560] = 00523; code[005560] = &I05560;
  core[005561] = 02440; code[005561] = &I05561;
  core[005562] = 00601; code[005562] = &I05562;
  core[005563] = 01114; code[005563] = &I05563;
  core[005564] = 00504; code[005564] = &I05564;
  core[005565] = 00000; code[005565] = &I05565;
  core[005566] = 03736; code[005566] = &I05566;
  core[005567] = 04040; code[005567] = &I05567;
  core[005570] = 04040; code[005570] = &I05570;
  core[005571] = 04022; code[005571] = &I05571;
  core[005572] = 00116; code[005572] = &I05572;
  core[005573] = 00417; code[005573] = &I05573;
  core[005574] = 01540; code[005574] = &I05574;
  core[005575] = 00104; code[005575] = &I05575;
  core[005576] = 00440; code[005576] = &I05576;
  core[005577] = 02405; code[005577] = &I05577;
  core[005600] = 02324; code[005600] = &P05600;
  core[005601] = 04061; code[005601] = &D05601;
  core[005602] = 04006; code[005602] = &I05602;
  core[005603] = 00111; code[005603] = &P05603;
  core[005604] = 01405; code[005604] = &P05604;
  core[005605] = 00400; code[005605] = &I05605;
  core[005606] = 03736; code[005606] = &I05606;
  core[005607] = 04040; code[005607] = &I05607;
  core[005610] = 04040; code[005610] = &I05610;
  core[005611] = 04022; code[005611] = &I05611;
  core[005612] = 00116; code[005612] = &I05612;
  core[005613] = 00417; code[005613] = &P05613;
  core[005614] = 01540; code[005614] = &I05614;
  core[005615] = 00104; code[005615] = &I05615;
  core[005616] = 00440; code[005616] = &I05616;
  core[005617] = 02405; code[005617] = &D05617;
  core[005620] = 02324; code[005620] = &I05620;
  core[005621] = 04062; code[005621] = &I05621;
  core[005622] = 04006; code[005622] = &I05622;
  core[005623] = 00111; code[005623] = &I05623;
  core[005624] = 01405; code[005624] = &D05624;
  core[005625] = 00400; code[005625] = &I05625;
  core[005626] = 03736; code[005626] = &I05626;
  core[005627] = 04040; code[005627] = &I05627;
  core[005630] = 04040; code[005630] = &I05630;
  core[005631] = 04022; code[005631] = &I05631;
  core[005632] = 00116; code[005632] = &I05632;
  core[005633] = 00417; code[005633] = &I05633;
  core[005634] = 01540; code[005634] = &I05634;
  core[005635] = 02201; code[005635] = &I05635;
  core[005636] = 02240; code[005636] = &I05636;
  core[005637] = 02405; code[005637] = &D05637;
  core[005640] = 02324; code[005640] = &D05640;
  core[005641] = 04006; code[005641] = &I05641;
  core[005642] = 00111; code[005642] = &I05642;
  core[005643] = 01405; code[005643] = &I05643;
  core[005644] = 00400; code[005644] = &I05644;
  core[005645] = 03736; code[005645] = &I05645;
  core[005646] = 04040; code[005646] = &I05646;
  core[005647] = 04040; code[005647] = &I05647;
  core[005650] = 04022; code[005650] = &I05650;
  core[005651] = 00116; code[005651] = &I05651;
  core[005652] = 00417; code[005652] = &I05652;
  core[005653] = 01540; code[005653] = &I05653;
  core[005654] = 02201; code[005654] = &I05654;
  core[005655] = 01440; code[005655] = &I05655;
  core[005656] = 02405; code[005656] = &I05656;
  core[005657] = 02324; code[005657] = &I05657;
  core[005660] = 04006; code[005660] = &I05660;
  core[005661] = 00111; code[005661] = &I05661;
  core[005662] = 01405; code[005662] = &I05662;
  core[005663] = 00400; code[005663] = &I05663;
  core[005664] = 03736; code[005664] = &I05664;
  core[005665] = 04040; code[005665] = &I05665;
  core[005666] = 04040; code[005666] = &I05666;
  core[005667] = 04022; code[005667] = &I05667;
  core[005670] = 00116; code[005670] = &I05670;
  core[005671] = 00417; code[005671] = &I05671;
  core[005672] = 01540; code[005672] = &I05672;
  core[005673] = 02224; code[005673] = &I05673;
  core[005674] = 01440; code[005674] = &I05674;
  core[005675] = 02405; code[005675] = &I05675;
  core[005676] = 02324; code[005676] = &I05676;
  core[005677] = 04006; code[005677] = &I05677;
  core[005700] = 00111; code[005700] = &I05700;
  core[005701] = 01405; code[005701] = &I05701;
  core[005702] = 00400; code[005702] = &I05702;
  core[005703] = 03736; code[005703] = &I05703;
  core[005704] = 04040; code[005704] = &I05704;
  core[005705] = 04040; code[005705] = &I05705;
  core[005706] = 04022; code[005706] = &P05706;
  core[005707] = 00116; code[005707] = &I05707;
  core[005710] = 00417; code[005710] = &I05710;
  core[005711] = 01540; code[005711] = &D05711;
  core[005712] = 02224; code[005712] = &I05712;
  core[005713] = 02240; code[005713] = &I05713;
  core[005714] = 02405; code[005714] = &I05714;
  core[005715] = 02324; code[005715] = &P05715;
  core[005716] = 04006; code[005716] = &I05716;
  core[005717] = 00111; code[005717] = &I05717;
  core[005720] = 01405; code[005720] = &I05720;
  core[005721] = 00400; code[005721] = &I05721;
  core[005722] = 03736; code[005722] = &P05722;
  core[005723] = 02311; code[005723] = &I05723;
  core[005724] = 01501; code[005724] = &P05724;
  core[005725] = 00400; code[005725] = &I05725;
  core[005726] = 03736; code[005726] = &I05726;
  core[005727] = 02311; code[005727] = &I05727;
  core[005730] = 01522; code[005730] = &I05730;
  core[005731] = 01724; code[005731] = &I05731;
  core[005732] = 00000; code[005732] = &I05732;
  core[005733] = 03736; code[005733] = &I05733;
  core[005734] = 00603; code[005734] = &I05734;
  core[005735] = 02400; code[005735] = &I05735;
  core[005736] = 03736; code[005736] = &P05736;
  core[005737] = 02201; code[005737] = &I05737;
  core[005740] = 01604; code[005740] = &D05740;
  core[005741] = 01715; code[005741] = &I05741;
  core[005742] = 00000; code[005742] = &I05742;
  core[005743] = 03736; code[005743] = &I05743;
  core[005744] = 00000; code[005744] = &I05744;
  core[005745] = 03736; code[005745] = &I05745;
  core[005746] = 04004; code[005746] = &I05746;
  core[005747] = 00124; code[005747] = &I05747;
  core[005750] = 00140; code[005750] = &I05750;
  core[005751] = 00522; code[005751] = &I05751;
  core[005752] = 02217; code[005752] = &I05752;
  core[005753] = 02237; code[005753] = &I05753;
  core[005754] = 03600; code[005754] = &I05754;
  core[005755] = 07777; code[005755] = &I05755;
  core[005756] = 04005; code[005756] = &I05756;
  core[005757] = 03024; code[005757] = &I05757;
  core[005760] = 00516; code[005760] = &I05760;
  core[005761] = 00405; code[005761] = &I05761;
  core[005762] = 00440; code[005762] = &I05762;
  core[005763] = 00201; code[005763] = &I05763;
  core[005764] = 01613; code[005764] = &I05764;
  core[005765] = 02340; code[005765] = &I05765;
  core[005766] = 01706; code[005766] = &I05766;
  core[005767] = 04015; code[005767] = &I05767;
  core[005770] = 00515; code[005770] = &I05770;
  core[005771] = 01722; code[005771] = &I05771;
  core[005772] = 03140; code[005772] = &I05772;
  core[005773] = 02417; code[005773] = &I05773;
  core[005774] = 04002; code[005774] = &I05774;
  core[005775] = 00116; code[005775] = &I05775;
  core[005776] = 01340; code[005776] = &I05776;
  core[005777] = 00000; code[005777] = &I05777;
  core[007600] = 07300; code[007600] = &I07600;
  core[007601] = 01155; code[007601] = &I07601;
  core[007602] = 03377; code[007602] = &I07602;
  core[007603] = 05377; code[007603] = &I07603;
  core[007775] = 00000; code[007775] = &I07775;
  core[007776] = 00000; code[007776] = &L07776;
  core[007777] = 00000; code[007777] = &L07777;
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

