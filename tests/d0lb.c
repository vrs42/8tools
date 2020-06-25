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
int swr = 05000;
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
void D00002() { lac &= (010000|core[000002]);  }
void P00003() { lac &= (010000|core[000003]);  }
void P00010() { lac &= (010000|core[000000]);  }
void P00011() { lac &= (010000|core[000000]);  }
void P00012() { lac &= (010000|core[000000]);  }
void P00013() { lac &= (010000|core[000000]);  }
void P00020() { lac &= (010000|core[000000]);  }
void D00021() { lac &= (010000|core[000000]);  }
void D00022() { lac &= (010000|core[000000]);  }
void P00023() { lac &= (010000|core[000000]);  }
void D00024() { lac &= (010000|core[000000]);  }
void P00025() { lac &= (010000|core[000000]);  }
void P00026() { lac &= (010000|core[000000]);  }
void D00027() { lac &= (010000|core[000000]);  }
void P00030() { lac &= (010000|core[000000]);  }
void P00031() { lac &= (010000|core[000000]);  }
void P00032() { lac &= (010000|core[000000]);  }
void L00033() { lac &= (010000|core[000000]);  }
void P00034() { lac &= (010000|core[000000]);  }
void P00035() { lac &= (010000|core[000000]);  }
void D00036() { lac &= (010000|core[000000]);  }
void D00037() { lac &= (010000|core[000000]);  }
void P00040() { lac &= (010000|core[000000]);  }
void D00041() { lac &= (010000|core[000000]);  }
void D00042() { lac &= (010000|core[000000]);  }
void D00043() { lac &= (010000|core[000000]);  }
void P00044() { lac &= (010000|core[000000]);  }
void P00045() { lac &= (010000|core[000000]);  }
void D00046() { lac &= (010000|core[000000]);  }
void D00047() { lac &= (010000|core[000000]);  }
void P00050() { emul8();  }
void P00051() { emul8();  }
void P00052() { emul8();  }
void P00053() { emul8();  }
void P00054() { emul8();  }
void P00055() { emul8();  }
void P00056() { lac &= (010000|core[000000]);  }
void P00057() { lac &= (010000|core[000000]);  }
void D00060() { lac &= (010000|core[(df<<12)+core[0]]);  }
void D00061() { lac &= (010000|core[(df<<12)+core[67]]);  }
void P00062() { lac &= (010000|core[(df<<12)+core[40]]);  }
void P00063() { lac &= (010000|core[000000]);  }
void D00064() { lac &= (010000|core[000000]);  }
void D00065() { lac &= (010000|core[000000]);  }
void D00066() { lac &= (010000|core[000000]);  }
void P00067() { lac &= (010000|core[000000]);  }
void D00070() { lac &= (010000|core[000015]);  }
void D00071() { lac &= (010000|core[000012]);  }
void D00072() { lac &= (010000|core[000115]);  }
void P00073() { lac &= (010000|core[000121]);  }
void P00074() { lac &= (010000|core[000114]);  }
void P00075() { lac &= (010000|core[000124]);  }
void P00076() { lac &= (010000|core[000101]);  }
void P00077() { lac &= (010000|core[000103]);  }
void P00100() { lac &= (010000|core[000061]);  }
void D00101() { lac &= (010000|core[000060]);  }
void D00102() { lac &= (010000|core[000000]);  }
void P00103() { lac &= (010000|core[000055]);  }
void P00104() { emul8();  }
void D00105() { lac &= (010000|core[000000]);  }
void D00106() { lac &= (010000|core[000000]);  }
void P00107() { lac += core[000000];  }
void D00110() { lac += core[000135];  }
void D00111() { lac &= (010000|core[000126]);  }
void P00112() { lac &= (010000|core[000063]);  }
void P00113() { lac &= (010000|core[000062]);  }
void D00114() { lac &= (010000|core[000000]);  }
void D00115() { lac &= (010000|core[000000]);  }
void D00116() { lac &= (010000|core[000000]);  }
void P00117() { lac &= (010000|core[000000]);  }
void P00120() { lac &= (010000|core[000000]);  }
void P00121() { lac &= (010000|core[000000]);  }
void P00122() { lac &= (010000|core[000000]);  }
void P00123() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void P00124() { npc = (ib<<12)+core[0]; inh = 0;  }
void P00125() { npc = (ib<<12)+core[7]; inh = 0;  }
void P00126() { if (++core[000013] == 010000) core[000013] = 0000;npc = (ib<<12)+core[000013]; inh = 0;  }
void P00127() { npc = (ib<<12)+core[32]; inh = 0;  }
void P00130() { npc = (ib<<12)+core[46]; inh = 0;  }
void P00131() { npc = (ib<<12)+core[51]; inh = 0;  }
void P00132() { npc = (ib<<12)+core[37]; inh = 0;  }
void L00133() { npc = (ib<<12)+core[42]; inh = 0;  }
void P00134() { npc = (ib<<12)+core[71]; inh = 0;  }
void P00135() { npc = 000074; inh = 0;  }
void P00136() { npc = 000117; inh = 0;  }
void P00137() {  }
void P00140() { npc = (ib<<12)+core[80]; inh = 0;  }
void P00141() { if (++core[000010] == 010000) core[000010] = 0000;npc = (ib<<12)+core[000010]; inh = 0;  }
void P00142() { npc = (ib<<12)+core[102]; inh = 0;  }
void P00143() { npc = 000125; inh = 0;  }
void P00144() { npc = 000133; inh = 0;  }
void P00145() { npc = 000142; inh = 0;  }
void P00146() { npc = (ib<<12)+core[0]; inh = 0;  }
void P00147() { lac ^= 010000; lac ^= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void P00150() { emul8();  }
void P00151() { npc = (ib<<12)+core[105]; inh = 0;  }
void P00152() { npc = (ib<<12)+core[90]; inh = 0;  }
void P00153() { npc = (ib<<12)+core[113]; inh = 0;  }
void P00154() { emul8();  }
void P00155() { npc = (ib<<12)+core[86]; inh = 0;  }
void P00156() { npc = (ib<<12)+core[67]; inh = 0;  }
void D00163() { core[000000] = 00164; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void D00164() { lac &= (010000|core[000031]);  }
void D00165() { lac &= (010000|core[000037]);  }
void D00166() { emul8();  }
void P00167() { lac &= (010000|core[000033]);  }
void D00170() { lac &= (010000|core[000042]);  }
void D00171() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void D00172() { npc = 000052; inh = 0;  }
void P00173() { npc = (ib<<12)+core[119]; inh = 0;  }
void D00174() { emul8();  }
void P00175() { npc = (ib<<12)+core[105]; inh = 0;  }
void P00176() { emul8();  }
void P00177() { npc = 000000; inh = 0;  }
void I00200() { emul8();  }
void I00201() { core[000115] = lac & 07777; lac &= 010000; code[000115] = &emul8;  }
void L00202() { emul8();  }
void I00203() { core[(ib<<12)+core[127]] = 00204; npc = (ib<<12)+core[127]+1; code[(ib<<12)+core[127]] = &emul8; inh = 0;  }
void L00204() { npc = 000244; inh = 0;  }
void L00205() { core[(ib<<12)+core[98]] = 00206; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L00206() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I00207() { lac &= (010000|core[000065]);  }
void I00210() { core[000063] = lac & 07777; lac &= 010000; code[000063] = &emul8;  }
void I00211() { lac &= 010000; lac ^= 07777;  }
void I00212() { core[000064] = lac & 07777; lac &= 010000; code[000064] = &emul8;  }
void I00213() { lac += core[000063];  }
void I00214() { emul8();  }
void I00215() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00216() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I00217() { npc = 000345; inh = 0;  }
void I00220() { lac &= 010000; lac ^= 07777;  }
void I00221() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void L00222() { lac += core[000067];  }
void I00223() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00224() { npc = 000231; inh = 0;  }
void I00225() { lac += core[000066];  }
void I00226() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00227() { npc = 000231; inh = 0;  }
void I00230() { npc = 000237; inh = 0;  }
void L00231() { core[(ib<<12)+core[101]] = 00232; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I00232() { core[000254] = 00233; npc = 000254+1; code[000254] = &emul8; inh = 0;  }
void I00233() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void I00234() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00235() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00236() { hlt = 1;  }
void L00237() { lac &= 010000; lac |= swr;  }
void I00240() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00241() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00242() { npc = 000206; inh = 0;  }
void I00243() { npc = 000205; inh = 0;  }
void L00244() { lac &= 010000; lac &= 07777;  }
void I00245() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I00246() { lac += core[000344];  }
void I00247() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I00250() { lac += core[000060];  }
void I00251() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I00252() { core[(ib<<12)+core[93]] = 00253; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I00253() { npc = 000205; inh = 0;  }
void S00254() { lac &= (010000|core[000000]);  }
void L00255() { core[(ib<<12)+core[85]] = 00256; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I00256() { core[000302] = 00257; npc = 000302+1; code[000302] = &emul8; inh = 0;  }
void I00257() { core[000311] = 00260; npc = 000311+1; code[000311] = &emul8; inh = 0;  }
void I00260() { core[000316] = 00261; npc = 000316+1; code[000316] = &emul8; inh = 0;  }
void L00261() { core[(ib<<12)+core[126]] = 00262; npc = (ib<<12)+core[126]+1; code[(ib<<12)+core[126]] = &emul8; inh = 0;  }
void D00262() { core[(ib<<12)+core[84]] = 00263; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void D00263() { core[(ib<<12)+core[45]] = 00264; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I00264() { core[000323] = 00265; npc = 000323+1; code[000323] = &emul8; inh = 0;  }
void I00265() { core[(ib<<12)+core[45]] = 00266; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I00266() { core[000332] = 00267; npc = 000332+1; code[000332] = &emul8; inh = 0;  }
void I00267() { core[(ib<<12)+core[44]] = 00270; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I00270() { core[(ib<<12)+core[224]] = 00271; npc = (ib<<12)+core[224]+1; code[(ib<<12)+core[224]] = &emul8; inh = 0;  }
void I00271() { core[(ib<<12)+core[84]] = 00272; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I00272() { core[(ib<<12)+core[88]] = 00273; npc = (ib<<12)+core[88]+1; code[(ib<<12)+core[88]] = &emul8; inh = 0;  }
void I00273() { core[(ib<<12)+core[225]] = 00274; npc = (ib<<12)+core[225]+1; code[(ib<<12)+core[225]] = &emul8; inh = 0;  }
void I00274() { core[000323] = 00275; npc = 000323+1; code[000323] = &emul8; inh = 0;  }
void I00275() { core[(ib<<12)+core[45]] = 00276; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I00276() { core[(ib<<12)+core[226]] = 00277; npc = (ib<<12)+core[226]+1; code[(ib<<12)+core[226]] = &emul8; inh = 0;  }
void I00277() { core[(ib<<12)+core[44]] = 00300; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I00300() { core[(ib<<12)+core[227]] = 00301; npc = (ib<<12)+core[227]+1; code[(ib<<12)+core[227]] = &emul8; inh = 0;  }
void L00301() { npc = (ib<<12)+core[172]; inh = 0;  }
void S00302() { lac &= (010000|core[000000]);  }
void L00303() { lac &= 010000; lac ^= 07777;  }
void I00304() { lac &= (010000|core[000072]);  }
void I00305() { core[(ib<<12)+core[86]] = 00306; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00306() { lac += core[000073];  }
void I00307() { core[(ib<<12)+core[86]] = 00310; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00310() { npc = (ib<<12)+core[194]; inh = 0;  }
void S00311() { lac &= (010000|core[000000]);  }
void I00312() { lac &= 010000; lac ^= 07777;  }
void I00313() { lac &= (010000|core[000074]);  }
void L00314() { core[(ib<<12)+core[86]] = 00315; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00315() { npc = (ib<<12)+core[201]; inh = 0;  }
void S00316() { lac &= (010000|core[000000]);  }
void I00317() { lac &= 010000; lac ^= 07777;  }
void D00320() { lac &= (010000|core[000075]);  }
void D00321() { core[(ib<<12)+core[86]] = 00322; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00322() { npc = (ib<<12)+core[206]; inh = 0;  }
void S00323() { lac &= (010000|core[000000]);  }
void L00324() { lac &= 010000; lac ^= 07777;  }
void I00325() { lac &= (010000|core[000076]);  }
void I00326() { core[(ib<<12)+core[86]] = 00327; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00327() { lac += core[000077];  }
void I00330() { core[(ib<<12)+core[86]] = 00331; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00331() { npc = (ib<<12)+core[211]; inh = 0;  }
void S00332() { lac &= (010000|core[000000]);  }
void I00333() { lac &= 010000; lac ^= 07777;  }
void I00334() { lac &= (010000|core[000064]);  }
void I00335() { core[000102] = lac & 07777; lac &= 010000; code[000102] = &emul8;  }
void I00336() { core[(ib<<12)+core[87]] = 00337; npc = (ib<<12)+core[87]+1; code[(ib<<12)+core[87]] = &emul8; inh = 0;  }
void I00337() { npc = (ib<<12)+core[218]; inh = 0;  }
void P00340() { lac &= (010000|core[000362]);  }
void P00341() { lac &= (010000|core[000355]);  }
void P00342() { lac &= (010000|core[000347]);  }
void P00343() { lac &= (010000|core[000370]);  }
void D00344() { lac &= (010000|core[000204]);  }
void L00345() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I00346() { npc = 000222; inh = 0;  }
void S00347() { lac &= (010000|core[000000]);  }
void D00350() { lac &= 010000; lac ^= 07777;  }
void I00351() { lac &= (010000|core[000066]);  }
void I00352() { core[000102] = lac & 07777; lac &= 010000; code[000102] = &emul8;  }
void I00353() { core[(ib<<12)+core[87]] = 00354; npc = (ib<<12)+core[87]+1; code[(ib<<12)+core[87]] = &emul8; inh = 0;  }
void I00354() { npc = (ib<<12)+core[231]; inh = 0;  }
void S00355() { lac &= (010000|core[000000]);  }
void I00356() { lac &= 010000; lac ^= 07777;  }
void I00357() { lac &= (010000|core[000103]);  }
void I00360() { core[(ib<<12)+core[86]] = 00361; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00361() { npc = (ib<<12)+core[237]; inh = 0;  }
void S00362() { lac &= (010000|core[000000]);  }
void I00363() { lac &= 010000; lac ^= 07777;  }
void I00364() { lac &= (010000|core[000063]);  }
void I00365() { core[000106] = lac & 07777; lac &= 010000; code[000106] = &emul8;  }
void I00366() { core[(ib<<12)+core[89]] = 00367; npc = (ib<<12)+core[89]+1; code[(ib<<12)+core[89]] = &emul8; inh = 0;  }
void I00367() { npc = (ib<<12)+core[242]; inh = 0;  }
void S00370() { lac &= (010000|core[000000]);  }
void I00371() { lac &= 010000; lac ^= 07777;  }
void I00372() { lac &= (010000|core[000067]);  }
void I00373() { core[000106] = lac & 07777; lac &= 010000; code[000106] = &emul8;  }
void I00374() { core[(ib<<12)+core[89]] = 00375; npc = (ib<<12)+core[89]+1; code[(ib<<12)+core[89]] = &emul8; inh = 0;  }
void I00375() { npc = (ib<<12)+core[248]; inh = 0;  }
void P00400() { npc = 000427; inh = 0;  }
void L00401() { core[(ib<<12)+core[98]] = 00402; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L00402() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00403() { lac &= (010000|core[000065]);  }
void I00404() { core[000063] = lac & 07777; lac &= 010000; code[000063] = &emul8;  }
void P00405() { core[000064] = lac & 07777; lac &= 010000; code[000064] = &emul8;  }
void I00406() { lac ^= 07777;  }
void I00407() { lac &= (010000|core[000063]);  }
void I00410() { emul8();  }
void I00411() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00412() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I00413() { npc = 000501; inh = 0;  }
void I00414() { lac &= 010000; lac ^= 07777;  }
void I00415() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void L00416() { lac ^= 07777;  }
void I00417() { lac &= (010000|core[000067]);  }
void I00420() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00421() { npc = 000437; inh = 0;  }
void I00422() { lac &= 010000; lac ^= 07777;  }
void I00423() { lac &= (010000|core[000066]);  }
void I00424() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00425() { npc = 000437; inh = 0;  }
void I00426() { npc = 000450; inh = 0;  }
void L00427() { lac &= 010000; lac &= 07777;  }
void I00430() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I00431() { lac += core[000060];  }
void I00432() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I00433() { lac += core[000061];  }
void I00434() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I00435() { core[(ib<<12)+core[93]] = 00436; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I00436() { npc = 000401; inh = 0;  }
void L00437() { lac &= 010000; lac |= swr;  }
void I00440() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00441() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00442() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00443() { npc = 000456; inh = 0;  }
void I00444() { lac &= 010000; lac |= swr;  }
void I00445() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void P00446() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00447() { hlt = 1;  }
void L00450() { lac &= 010000; lac |= swr;  }
void I00451() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00452() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00453() { npc = 000402; inh = 0;  }
void D00454() { npc = 000401; inh = 0;  }
void D00455() { lac &= (010000|core[(df<<12)+core[36]]);  }
void L00456() { lac &= 010000; lac ^= 07777;  }
void I00457() { lac &= (010000|core[000455]);  }
void I00460() { core[(df<<12)+core[320]] = lac & 07777; lac &= 010000; code[(df<<12)+core[320]] = &emul8;  }
void D00461() { core[(ib<<12)+core[85]] = 00462; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I00462() { core[(ib<<12)+core[312]] = 00463; npc = (ib<<12)+core[312]+1; code[(ib<<12)+core[312]] = &emul8; inh = 0;  }
void I00463() { core[(ib<<12)+core[313]] = 00464; npc = (ib<<12)+core[313]+1; code[(ib<<12)+core[313]] = &emul8; inh = 0;  }
void I00464() { core[(ib<<12)+core[314]] = 00465; npc = (ib<<12)+core[314]+1; code[(ib<<12)+core[314]] = &emul8; inh = 0;  }
void I00465() { core[000473] = 00466; npc = 000473+1; code[000473] = &emul8; inh = 0;  }
void I00466() { npc = (ib<<12)+core[311]; inh = 0;  }
void P00467() { lac &= (010000|core[000461]);  }
void P00470() { lac &= (010000|core[000502]);  }
void P00471() { lac &= (010000|core[000511]);  }
void P00472() { lac &= (010000|core[000516]);  }
void S00473() { lac &= (010000|core[000000]);  }
void I00474() { lac &= 010000; lac ^= 07777;  }
void I00475() { lac &= (010000|core[000100]);  }
void I00476() { core[(ib<<12)+core[86]] = 00477; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00477() { npc = (ib<<12)+core[315]; inh = 0;  }
void P00500() { lac &= (010000|core[000454]);  }
void L00501() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void D00502() { npc = 000416; inh = 0;  }
void I00503() { npc = 000540; inh = 0;  }
void L00504() { core[(ib<<12)+core[98]] = 00505; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L00505() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I00506() { lac &= (010000|core[000065]);  }
void I00507() { core[000063] = lac & 07777; lac &= 010000; code[000063] = &emul8;  }
void I00510() { lac &= 010000; lac ^= 07777;  }
void D00511() { core[000064] = lac & 07777; lac &= 010000; code[000064] = &emul8;  }
void I00512() { lac ^= 07777;  }
void I00513() { lac &= (010000|core[000063]);  }
void I00514() { emul8();  }
void I00515() { emul8();  }
void D00516() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00517() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I00520() { npc = (ib<<12)+core[383]; inh = 0;  }
void I00521() { lac &= 010000; lac ^= 07777;  }
void I00522() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void L00523() { lac ^= 07777;  }
void I00524() { lac &= (010000|core[000063]);  }
void I00525() { lac &= 07777; lac ^= 07777;  }
void I00526() { lac += core[000067];  }
void I00527() { lac ^= 07777;  }
void I00530() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00531() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00532() { npc = 000550; inh = 0;  }
void I00533() { lac &= 010000; lac ^= 07777;  }
void I00534() { lac &= (010000|core[000066]);  }
void I00535() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00536() { npc = 000550; inh = 0;  }
void I00537() { npc = 000563; inh = 0;  }
void L00540() { lac &= 010000; lac &= 07777;  }
void I00541() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I00542() { lac += core[000061];  }
void I00543() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I00544() { lac += core[000062];  }
void I00545() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I00546() { core[(ib<<12)+core[93]] = 00547; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I00547() { npc = 000504; inh = 0;  }
void L00550() { lac &= 010000; lac |= swr;  }
void I00551() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00552() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00553() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00554() { npc = 000557; inh = 0;  }
void I00555() { core[(ib<<12)+core[382]] = 00556; npc = (ib<<12)+core[382]+1; code[(ib<<12)+core[382]] = &emul8; inh = 0;  }
void I00556() { core[(ib<<12)+core[381]] = 00557; npc = (ib<<12)+core[381]+1; code[(ib<<12)+core[381]] = &emul8; inh = 0;  }
void L00557() { lac &= 010000; lac |= swr;  }
void I00560() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I00561() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00562() { hlt = 1;  }
void L00563() { lac &= 010000; lac |= swr;  }
void I00564() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00565() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00566() { npc = 000505; inh = 0;  }
void I00567() { npc = 000504; inh = 0;  }
void P00575() { lac &= (010000|core[(df<<12)+core[261]]);  }
void P00576() { lac &= (010000|core[(df<<12)+core[256]]);  }
void P00577() { lac &= (010000|core[(df<<12)+core[294]]);  }
void S00600() { lac &= (010000|core[000000]);  }
void I00601() { core[(ib<<12)+core[85]] = 00602; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I00602() { core[(ib<<12)+core[511]] = 00603; npc = (ib<<12)+core[511]+1; code[(ib<<12)+core[511]] = &emul8; inh = 0;  }
void I00603() { core[000632] = 00604; npc = 000632+1; code[000632] = &emul8; inh = 0;  }
void I00604() { npc = (ib<<12)+core[384]; inh = 0;  }
void S00605() { lac &= (010000|core[000000]);  }
void I00606() { core[(ib<<12)+core[126]] = 00607; npc = (ib<<12)+core[126]+1; code[(ib<<12)+core[126]] = &emul8; inh = 0;  }
void I00607() { core[(ib<<12)+core[84]] = 00610; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I00610() { core[(ib<<12)+core[41]] = 00611; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I00611() { emul8();  }
void I00612() { core[(ib<<12)+core[510]] = 00613; npc = (ib<<12)+core[510]+1; code[(ib<<12)+core[510]] = &emul8; inh = 0;  }
void I00613() { core[(ib<<12)+core[45]] = 00614; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I00614() { core[(ib<<12)+core[509]] = 00615; npc = (ib<<12)+core[509]+1; code[(ib<<12)+core[509]] = &emul8; inh = 0;  }
void I00615() { core[(ib<<12)+core[44]] = 00616; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I00616() { core[(ib<<12)+core[508]] = 00617; npc = (ib<<12)+core[508]+1; code[(ib<<12)+core[508]] = &emul8; inh = 0;  }
void I00617() { core[(ib<<12)+core[84]] = 00620; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I00620() { core[(ib<<12)+core[511]] = 00621; npc = (ib<<12)+core[511]+1; code[(ib<<12)+core[511]] = &emul8; inh = 0;  }
void I00621() { core[(ib<<12)+core[507]] = 00622; npc = (ib<<12)+core[507]+1; code[(ib<<12)+core[507]] = &emul8; inh = 0;  }
void I00622() { core[(ib<<12)+core[44]] = 00623; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I00623() { core[(ib<<12)+core[511]] = 00624; npc = (ib<<12)+core[511]+1; code[(ib<<12)+core[511]] = &emul8; inh = 0;  }
void I00624() { core[000641] = 00625; npc = 000641+1; code[000641] = &emul8; inh = 0;  }
void I00625() { core[(ib<<12)+core[45]] = 00626; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I00626() { core[(ib<<12)+core[506]] = 00627; npc = (ib<<12)+core[506]+1; code[(ib<<12)+core[506]] = &emul8; inh = 0;  }
void I00627() { core[(ib<<12)+core[44]] = 00630; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I00630() { core[(ib<<12)+core[505]] = 00631; npc = (ib<<12)+core[505]+1; code[(ib<<12)+core[505]] = &emul8; inh = 0;  }
void I00631() { npc = (ib<<12)+core[389]; inh = 0;  }
void S00632() { lac &= (010000|core[000000]);  }
void I00633() { lac &= 010000; lac ^= 07777;  }
void I00634() { lac &= (010000|core[000076]);  }
void I00635() { core[(ib<<12)+core[86]] = 00636; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00636() { lac += core[000075];  }
void I00637() { core[(ib<<12)+core[86]] = 00640; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00640() { npc = (ib<<12)+core[410]; inh = 0;  }
void S00641() { lac &= (010000|core[000000]);  }
void I00642() { lac &= 010000; lac ^= 07777;  }
void I00643() { lac &= (010000|core[000076]);  }
void I00644() { core[(ib<<12)+core[86]] = 00645; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00645() { npc = (ib<<12)+core[417]; inh = 0;  }
void L00646() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I00647() { npc = (ib<<12)+core[504]; inh = 0;  }
void L00650() { core[000704] = 00651; npc = 000704+1; code[000704] = &emul8; inh = 0;  }
void L00651() { core[(ib<<12)+core[98]] = 00652; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L00652() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00653() { lac &= (010000|core[000065]);  }
void I00654() { core[000063] = lac & 07777; lac &= 010000; code[000063] = &emul8;  }
void I00655() { core[000064] = lac & 07777; lac &= 010000; code[000064] = &emul8;  }
void I00656() { lac ^= 07777;  }
void I00657() { lac &= (010000|core[000063]);  }
void I00660() { emul8();  }
void I00661() { emul8();  }
void I00662() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00663() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I00664() { npc = 000740; inh = 0;  }
void I00665() { lac &= 010000; lac ^= 07777;  }
void I00666() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void L00667() { lac ^= 07777;  }
void I00670() { lac &= (010000|core[000063]);  }
void I00671() { lac &= 07777; lac ^= 07777;  }
void I00672() { lac += core[000067];  }
void I00673() { lac ^= 07777;  }
void I00674() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00675() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00676() { npc = 000714; inh = 0;  }
void I00677() { lac &= 010000; lac ^= 07777;  }
void I00700() { lac &= (010000|core[000066]);  }
void I00701() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void D00702() { npc = 000714; inh = 0;  }
void I00703() { npc = 000730; inh = 0;  }
void I00704() { lac &= 010000; lac &= 07777;  }
void I00705() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I00706() { lac += core[000062];  }
void I00707() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I00710() { lac += core[000107];  }
void D00711() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I00712() { core[(ib<<12)+core[93]] = 00713; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I00713() { npc = 000651; inh = 0;  }
void L00714() { lac &= 010000; lac |= swr;  }
void I00715() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00716() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00717() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00720() { npc = 000724; inh = 0;  }
void I00721() { core[(ib<<12)+core[477]] = 00722; npc = (ib<<12)+core[477]+1; code[(ib<<12)+core[477]] = &emul8; inh = 0;  }
void I00722() { core[(ib<<12)+core[478]] = 00723; npc = (ib<<12)+core[478]+1; code[(ib<<12)+core[478]] = &emul8; inh = 0;  }
void D00723() { core[(ib<<12)+core[479]] = 00724; npc = (ib<<12)+core[479]+1; code[(ib<<12)+core[479]] = &emul8; inh = 0;  }
void L00724() { lac &= 010000; lac |= swr;  }
void I00725() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I00726() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00727() { hlt = 1;  }
void L00730() { lac &= 010000; lac |= swr;  }
void I00731() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void D00732() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00733() { npc = 000652; inh = 0;  }
void I00734() { npc = 000651; inh = 0;  }
void P00735() { lac &= (010000|core[(df<<12)+core[384]]);  }
void P00736() { lac &= (010000|core[(df<<12)+core[59]]);  }
void P00737() { lac &= (010000|core[(df<<12)+core[389]]);  }
void L00740() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I00741() { npc = 000667; inh = 0;  }
void P00770() { lac &= (010000|core[(df<<12)+core[83]]);  }
void P00771() { lac &= (010000|core[000770]);  }
void P00772() { lac &= (010000|core[000747]);  }
void P00773() { lac &= (010000|core[000711]);  }
void P00774() { lac &= (010000|core[000762]);  }
void P00775() { lac &= (010000|core[000732]);  }
void P00776() { lac &= (010000|core[000723]);  }
void P00777() { lac &= (010000|core[000702]);  }
void P01000() { npc = 001032; inh = 0;  }
void L01001() { core[(ib<<12)+core[98]] = 01002; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L01002() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I01003() { lac &= (010000|core[000065]);  }
void I01004() { lac ^= 07777;  }
void I01005() { core[000063] = lac & 07777; lac &= 010000; code[000063] = &emul8;  }
void I01006() { lac ^= 07777;  }
void I01007() { core[000064] = lac & 07777; lac &= 010000; code[000064] = &emul8;  }
void D01010() { lac += core[000065];  }
void I01011() { emul8();  }
void I01012() { lac += core[000063];  }
void I01013() { emul8();  }
void I01014() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I01015() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I01016() { npc = 001133; inh = 0;  }
void I01017() { lac &= 010000; lac ^= 07777;  }
void I01020() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void L01021() { lac += core[000067];  }
void I01022() { lac ^= 07777;  }
void D01023() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01024() { npc = 001042; inh = 0;  }
void I01025() { lac ^= 07777;  }
void I01026() { lac &= (010000|core[000066]);  }
void I01027() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01030() { npc = 001042; inh = 0;  }
void I01031() { npc = 001055; inh = 0;  }
void L01032() { lac &= 010000; lac &= 07777;  }
void I01033() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I01034() { lac += core[000107];  }
void I01035() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I01036() { lac += core[000110];  }
void I01037() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void D01040() { core[(ib<<12)+core[93]] = 01041; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void D01041() { npc = 001001; inh = 0;  }
void L01042() { lac &= 010000; lac |= swr;  }
void I01043() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I01044() { lac = (lac<<1) + ((lac>>12)&1);  }
void I01045() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01046() { npc = 001051; inh = 0;  }
void I01047() { core[(ib<<12)+core[562]] = 01050; npc = (ib<<12)+core[562]+1; code[(ib<<12)+core[562]] = &emul8; inh = 0;  }
void I01050() { core[001063] = 01051; npc = 001063+1; code[001063] = &emul8; inh = 0;  }
void L01051() { lac &= 010000; lac |= swr;  }
void I01052() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I01053() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01054() { hlt = 1;  }
void L01055() { lac &= 010000; lac |= swr;  }
void I01056() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I01057() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01060() { npc = 001002; inh = 0;  }
void I01061() { npc = 001001; inh = 0;  }
void P01062() { lac &= (010000|core[(df<<12)+core[512]]);  }
void S01063() { lac &= (010000|core[000000]);  }
void I01064() { core[001126] = 01065; npc = 001126+1; code[001126] = &emul8; inh = 0;  }
void I01065() { core[(ib<<12)+core[126]] = 01066; npc = (ib<<12)+core[126]+1; code[(ib<<12)+core[126]] = &emul8; inh = 0;  }
void L01066() { core[(ib<<12)+core[84]] = 01067; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I01067() { core[(ib<<12)+core[45]] = 01070; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I01070() { core[(ib<<12)+core[44]] = 01071; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I01071() { core[(ib<<12)+core[639]] = 01072; npc = (ib<<12)+core[639]+1; code[(ib<<12)+core[639]] = &emul8; inh = 0;  }
void I01072() { core[(ib<<12)+core[45]] = 01073; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I01073() { core[(ib<<12)+core[638]] = 01074; npc = (ib<<12)+core[638]+1; code[(ib<<12)+core[638]] = &emul8; inh = 0;  }
void I01074() { core[(ib<<12)+core[44]] = 01075; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I01075() { core[(ib<<12)+core[637]] = 01076; npc = (ib<<12)+core[637]+1; code[(ib<<12)+core[637]] = &emul8; inh = 0;  }
void I01076() { core[(ib<<12)+core[84]] = 01077; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I01077() { core[(ib<<12)+core[45]] = 01100; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I01100() { core[(ib<<12)+core[44]] = 01101; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I01101() { core[(ib<<12)+core[636]] = 01102; npc = (ib<<12)+core[636]+1; code[(ib<<12)+core[636]] = &emul8; inh = 0;  }
void D01102() { core[(ib<<12)+core[45]] = 01103; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I01103() { core[(ib<<12)+core[45]] = 01104; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I01104() { lac &= 010000;  }
void I01105() { lac += core[000065];  }
void I01106() { core[000063] = lac & 07777; lac &= 010000; code[000063] = &emul8;  }
void I01107() { core[(ib<<12)+core[637]] = 01110; npc = (ib<<12)+core[637]+1; code[(ib<<12)+core[637]] = &emul8; inh = 0;  }
void I01110() { core[(ib<<12)+core[84]] = 01111; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I01111() { core[(ib<<12)+core[636]] = 01112; npc = (ib<<12)+core[636]+1; code[(ib<<12)+core[636]] = &emul8; inh = 0;  }
void I01112() { core[001121] = 01113; npc = 001121+1; code[001121] = &emul8; inh = 0;  }
void I01113() { core[(ib<<12)+core[639]] = 01114; npc = (ib<<12)+core[639]+1; code[(ib<<12)+core[639]] = &emul8; inh = 0;  }
void I01114() { core[(ib<<12)+core[45]] = 01115; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I01115() { core[(ib<<12)+core[635]] = 01116; npc = (ib<<12)+core[635]+1; code[(ib<<12)+core[635]] = &emul8; inh = 0;  }
void I01116() { core[(ib<<12)+core[44]] = 01117; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I01117() { core[(ib<<12)+core[634]] = 01120; npc = (ib<<12)+core[634]+1; code[(ib<<12)+core[634]] = &emul8; inh = 0;  }
void I01120() { npc = (ib<<12)+core[563]; inh = 0;  }
void S01121() { lac &= (010000|core[000000]);  }
void I01122() { lac &= 010000; lac ^= 07777;  }
void D01123() { lac &= (010000|core[000111]);  }
void I01124() { core[(ib<<12)+core[86]] = 01125; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01125() { npc = (ib<<12)+core[593]; inh = 0;  }
void S01126() { lac &= (010000|core[000000]);  }
void I01127() { lac &= 010000; lac ^= 07777;  }
void I01130() { lac &= (010000|core[000113]);  }
void I01131() { core[(ib<<12)+core[86]] = 01132; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void D01132() { npc = (ib<<12)+core[598]; inh = 0;  }
void L01133() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I01134() { npc = 001021; inh = 0;  }
void I01135() { npc = (ib<<12)+core[633]; inh = 0;  }
void L01136() { core[(ib<<12)+core[98]] = 01137; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L01137() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I01140() { lac &= (010000|core[000065]);  }
void I01141() { lac ^= 07777;  }
void I01142() { core[000063] = lac & 07777; lac &= 010000; code[000063] = &emul8;  }
void I01143() { core[000064] = lac & 07777; lac &= 010000; code[000064] = &emul8;  }
void I01144() { lac ^= 07777;  }
void I01145() { lac &= (010000|core[000065]);  }
void I01146() { emul8();  }
void D01147() { lac += core[000063];  }
void I01150() { emul8();  }
void I01151() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I01152() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I01153() { skp = 0; skp = !skp; npc += skp;  }
void I01154() { lac &= 010000; lac ^= 07777;  }
void I01155() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I01156() { lac += core[000067];  }
void I01157() { lac ^= 07777;  }
void I01160() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01161() { npc = (ib<<12)+core[632]; inh = 0;  }
void D01162() { lac ^= 07777;  }
void I01163() { lac &= (010000|core[000066]);  }
void I01164() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01165() { npc = (ib<<12)+core[632]; inh = 0;  }
void I01166() { npc = (ib<<12)+core[631]; inh = 0;  }
void P01167() { lac += core[001023];  }
void P01170() { lac += core[001010];  }
void P01171() { lac += core[001000];  }
void P01172() { lac &= (010000|core[001170]);  }
void P01173() { lac &= (010000|core[001147]);  }
void P01174() { lac &= (010000|core[001102]);  }
void P01175() { lac &= (010000|core[001162]);  }
void P01176() { lac &= (010000|core[001132]);  }
void P01177() { lac &= (010000|core[001123]);  }
void P01200() { lac &= 010000; lac &= 07777;  }
void I01201() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I01202() { lac += core[000110];  }
void I01203() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I01204() { lac += core[001377];  }
void I01205() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I01206() { core[(ib<<12)+core[93]] = 01207; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I01207() { npc = (ib<<12)+core[766]; inh = 0;  }
void L01210() { lac &= 010000; lac |= swr;  }
void I01211() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I01212() { lac = (lac<<1) + ((lac>>12)&1);  }
void I01213() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01214() { npc = 001217; inh = 0;  }
void I01215() { core[(ib<<12)+core[664]] = 01216; npc = (ib<<12)+core[664]+1; code[(ib<<12)+core[664]] = &emul8; inh = 0;  }
void I01216() { npc = 001233; inh = 0;  }
void L01217() { lac &= 010000; lac |= swr;  }
void I01220() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I01221() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01222() { hlt = 1;  }
void L01223() { lac &= 010000; lac |= swr;  }
void I01224() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I01225() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01226() { npc = (ib<<12)+core[765]; inh = 0;  }
void I01227() { npc = (ib<<12)+core[766]; inh = 0;  }
void P01230() { lac &= (010000|core[(df<<12)+core[640]]);  }
void D01231() { lac += core[001217];  }
void P01232() { lac += core[000063];  }
void L01233() { core[001240] = 01234; npc = 001240+1; code[001240] = &emul8; inh = 0;  }
void I01234() { core[(ib<<12)+core[126]] = 01235; npc = (ib<<12)+core[126]+1; code[(ib<<12)+core[126]] = &emul8; inh = 0;  }
void I01235() { lac += core[001231];  }
void I01236() { core[(df<<12)+core[666]] = lac & 07777; lac &= 010000; code[(df<<12)+core[666]] = &emul8;  }
void I01237() { npc = (ib<<12)+core[764]; inh = 0;  }
void S01240() { lac &= (010000|core[000000]);  }
void I01241() { lac &= 010000; lac ^= 07777;  }
void I01242() { lac &= (010000|core[000112]);  }
void I01243() { core[(ib<<12)+core[86]] = 01244; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01244() { npc = (ib<<12)+core[672]; inh = 0;  }
void D01245() { core[001315] = 01246; npc = 001315+1; code[001315] = &emul8; inh = 0;  }
void L01246() { core[001263] = 01247; npc = 001263+1; code[001263] = &emul8; inh = 0;  }
void L01247() { lac += core[000021];  }
void I01250() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I01251() { lac += core[000023];  }
void I01252() { emul8();  }
void I01253() { lac += core[000022];  }
void I01254() { emul8();  }
void I01255() { core[(ib<<12)+core[97]] = 01256; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I01256() { core[(ib<<12)+core[763]] = 01257; npc = (ib<<12)+core[763]+1; code[(ib<<12)+core[763]] = &emul8; inh = 0;  }
void I01257() { core[(ib<<12)+core[42]] = 01260; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I01260() { emul8();  }
void I01261() { npc = 001276; inh = 0;  }
void I01262() { npc = 001302; inh = 0;  }
void S01263() { lac &= (010000|core[000000]);  }
void I01264() { core[(ib<<12)+core[43]] = 01265; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void D01265() { lac &= (010000|core[000000]);  }
void I01266() { lac &= (010000|core[000021]);  }
void I01267() { emul8();  }
void I01270() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = (lac<<1) + ((lac>>12)&1);  }
void I01271() { lac += core[001265];  }
void I01272() { core[001265] = lac & 07777; lac &= 010000; code[001265] = &emul8;  }
void I01273() { if (++core[000114] == 010000) { core[000114] = 0; npc++; }; code[000114] = &emul8;  }
void I01274() { npc = (ib<<12)+core[691]; inh = 0;  }
void I01275() { npc = (ib<<12)+core[125]; inh = 0;  }
void L01276() { core[(ib<<12)+core[101]] = 01277; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01277() { core[001305] = 01300; npc = 001305+1; code[001305] = &emul8; inh = 0;  }
void I01300() { core[(ib<<12)+core[99]] = 01301; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I01301() { hlt = 1;  }
void L01302() { core[(ib<<12)+core[100]] = 01303; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I01303() { npc = 001247; inh = 0;  }
void I01304() { npc = 001246; inh = 0;  }
void S01305() { lac &= (010000|core[000000]);  }
void I01306() { core[(ib<<12)+core[92]] = 01307; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I01307() { emul8();  }
void I01310() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac |= swr;  }
void I01311() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01312() { emul8();  }
void I01313() { core[(ib<<12)+core[95]] = 01314; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I01314() { npc = (ib<<12)+core[709]; inh = 0;  }
void S01315() { lac &= (010000|core[000000]);  }
void I01316() { core[(ib<<12)+core[96]] = 01317; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01317() { lac += core[001372];  }
void I01320() { core[001265] = lac & 07777; lac &= 010000; code[001265] = &emul8;  }
void I01321() { lac += core[001377];  }
void I01322() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I01323() { lac += core[001371];  }
void I01324() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I01325() { lac += core[001370];  }
void I01326() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I01327() { core[(ib<<12)+core[93]] = 01330; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I01330() { core[(ib<<12)+core[94]] = 01331; npc = (ib<<12)+core[94]+1; code[(ib<<12)+core[94]] = &emul8; inh = 0;  }
void I01331() { emul8();  }
void I01332() { npc = (ib<<12)+core[717]; inh = 0;  }
void D01333() { core[(ib<<12)+core[759]] = 01334; npc = (ib<<12)+core[759]+1; code[(ib<<12)+core[759]] = &emul8; inh = 0;  }
void L01334() { core[(ib<<12)+core[106]] = 01335; npc = (ib<<12)+core[106]+1; code[(ib<<12)+core[106]] = &emul8; inh = 0;  }
void L01335() { lac += core[000023];  }
void I01336() { emul8();  }
void I01337() { core[(ib<<12)+core[107]] = 01340; npc = (ib<<12)+core[107]+1; code[(ib<<12)+core[107]] = &emul8; inh = 0;  }
void I01340() { core[(ib<<12)+core[110]] = 01341; npc = (ib<<12)+core[110]+1; code[(ib<<12)+core[110]] = &emul8; inh = 0;  }
void I01341() { lac += core[000021];  }
void I01342() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I01343() { lac += core[000022];  }
void I01344() { emul8();  }
void I01345() { core[(ib<<12)+core[97]] = 01346; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I01346() { core[(ib<<12)+core[763]] = 01347; npc = (ib<<12)+core[763]+1; code[(ib<<12)+core[763]] = &emul8; inh = 0;  }
void I01347() { core[(ib<<12)+core[42]] = 01350; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I01350() { emul8();  }
void I01351() { npc = (ib<<12)+core[758]; inh = 0;  }
void I01352() { npc = (ib<<12)+core[757]; inh = 0;  }
void P01365() { if (++core[000015] == 010000) core[000015] = 0000;lac += core[(df<<12)+core[000015]];  }
void P01366() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void P01367() { lac += core[(df<<12)+core[0]];  }
void D01370() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void D01371() { lac += core[001333];  }
void D01372() { lac &= 010000; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void P01373() { emul8();  }
void P01374() { lac += core[000066];  }
void P01375() { lac += core[000137];  }
void P01376() { lac += core[000136];  }
void D01377() { lac += core[001245];  }
void S01400() { lac &= (010000|core[000000]);  }
void I01401() { core[(ib<<12)+core[96]] = 01402; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01402() { lac += core[001577];  }
void I01403() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I01404() { lac += core[001576];  }
void I01405() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I01406() { core[(ib<<12)+core[93]] = 01407; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I01407() { core[(ib<<12)+core[94]] = 01410; npc = (ib<<12)+core[94]+1; code[(ib<<12)+core[94]] = &emul8; inh = 0;  }
void I01410() { npc = (ib<<12)+core[768]; inh = 0;  }
void L01411() { core[(ib<<12)+core[101]] = 01412; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01412() { core[001420] = 01413; npc = 001420+1; code[001420] = &emul8; inh = 0;  }
void I01413() { core[(ib<<12)+core[99]] = 01414; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I01414() { hlt = 1;  }
void L01415() { core[(ib<<12)+core[100]] = 01416; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I01416() { npc = (ib<<12)+core[893]; inh = 0;  }
void I01417() { npc = (ib<<12)+core[892]; inh = 0;  }
void S01420() { lac &= (010000|core[000000]);  }
void I01421() { core[(ib<<12)+core[92]] = 01422; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I01422() { emul8();  }
void I01423() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac |= swr;  }
void I01424() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01425() { emul8();  }
void I01426() { core[(ib<<12)+core[95]] = 01427; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I01427() { npc = (ib<<12)+core[784]; inh = 0;  }
void I01430() { core[001453] = 01431; npc = 001453+1; code[001453] = &emul8; inh = 0;  }
void L01431() { core[(ib<<12)+core[98]] = 01432; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L01432() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01433() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I01434() { lac += core[000065];  }
void I01435() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I01436() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void I01437() { lac += core[001444];  }
void I01440() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01441() { lac += core[000065];  }
void I01442() { emul8();  }
void I01443() { emul8();  }
void D01444() { lac &= (010000|core[000000]);  }
void I01445() { core[(ib<<12)+core[97]] = 01446; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I01446() { core[(ib<<12)+core[891]] = 01447; npc = (ib<<12)+core[891]+1; code[(ib<<12)+core[891]] = &emul8; inh = 0;  }
void I01447() { core[(ib<<12)+core[42]] = 01450; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I01450() { emul8();  }
void I01451() { npc = 001474; inh = 0;  }
void I01452() { npc = 001500; inh = 0;  }
void S01453() { lac &= (010000|core[000000]);  }
void I01454() { core[(ib<<12)+core[96]] = 01455; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01455() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I01456() { core[001444] = lac & 07777; lac &= 010000; code[001444] = &emul8;  }
void I01457() { lac += core[001572];  }
void I01460() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I01461() { lac += core[001571];  }
void I01462() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I01463() { lac += core[000174];  }
void I01464() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I01465() { core[(ib<<12)+core[93]] = 01466; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I01466() { npc = (ib<<12)+core[811]; inh = 0;  }
void I01467() { if (++core[001444] == 010000) { core[001444] = 0; npc++; }; code[001444] = &emul8;  }
void I01470() { if (++core[000114] == 010000) { core[000114] = 0; npc++; }; code[000114] = &emul8;  }
void I01471() { npc = 001431; inh = 0;  }
void I01472() { npc = (ib<<12)+core[827]; inh = 0;  }
void P01473() { lac += core[(df<<12)+core[768]];  }
void L01474() { core[(ib<<12)+core[101]] = 01475; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01475() { core[001503] = 01476; npc = 001503+1; code[001503] = &emul8; inh = 0;  }
void I01476() { core[(ib<<12)+core[99]] = 01477; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I01477() { hlt = 1;  }
void L01500() { core[(ib<<12)+core[100]] = 01501; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I01501() { npc = 001432; inh = 0;  }
void I01502() { npc = 001431; inh = 0;  }
void S01503() { lac &= (010000|core[000000]);  }
void I01504() { core[(ib<<12)+core[92]] = 01505; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I01505() { emul8();  }
void I01506() { emul8();  }
void I01507() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01510() { emul8();  }
void I01511() { core[(ib<<12)+core[103]] = 01512; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01512() { core[(ib<<12)+core[95]] = 01513; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I01513() { npc = (ib<<12)+core[835]; inh = 0;  }
void D01571() { lac += core[(df<<12)+core[55]];  }
void D01572() { lac += core[(df<<12)+core[25]];  }
void P01573() { emul8();  }
void P01574() { lac += core[001534];  }
void P01575() { lac += core[001535];  }
void D01576() { lac += core[001533];  }
void D01577() { lac += core[(df<<12)+core[24]];  }
void P01600() { core[001616] = 01601; npc = 001616+1; code[001616] = &emul8; inh = 0;  }
void L01601() { core[(ib<<12)+core[106]] = 01602; npc = (ib<<12)+core[106]+1; code[(ib<<12)+core[106]] = &emul8; inh = 0;  }
void L01602() { core[(ib<<12)+core[105]] = 01603; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I01603() { lac += core[000024];  }
void I01604() { core[001607] = lac & 07777; lac &= 010000; code[001607] = &emul8;  }
void I01605() { lac += core[000022];  }
void I01606() { emul8();  }
void D01607() { lac &= (010000|core[000000]);  }
void I01610() { core[(ib<<12)+core[97]] = 01611; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I01611() { core[(ib<<12)+core[1023]] = 01612; npc = (ib<<12)+core[1023]+1; code[(ib<<12)+core[1023]] = &emul8; inh = 0;  }
void I01612() { core[(ib<<12)+core[42]] = 01613; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I01613() { emul8();  }
void I01614() { npc = 001626; inh = 0;  }
void I01615() { npc = 001632; inh = 0;  }
void S01616() { lac &= (010000|core[000000]);  }
void I01617() { core[(ib<<12)+core[96]] = 01620; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01620() { lac += core[001776];  }
void I01621() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I01622() { lac += core[001775];  }
void I01623() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I01624() { core[(ib<<12)+core[93]] = 01625; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I01625() { npc = (ib<<12)+core[910]; inh = 0;  }
void L01626() { core[(ib<<12)+core[101]] = 01627; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01627() { core[001635] = 01630; npc = 001635+1; code[001635] = &emul8; inh = 0;  }
void I01630() { core[(ib<<12)+core[99]] = 01631; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I01631() { hlt = 1;  }
void L01632() { core[(ib<<12)+core[100]] = 01633; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I01633() { npc = 001602; inh = 0;  }
void I01634() { npc = 001601; inh = 0;  }
void S01635() { lac &= (010000|core[000000]);  }
void I01636() { core[(ib<<12)+core[92]] = 01637; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I01637() { emul8();  }
void I01640() { emul8();  }
void I01641() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01642() { emul8();  }
void I01643() { core[(ib<<12)+core[103]] = 01644; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01644() { core[(ib<<12)+core[95]] = 01645; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I01645() { npc = (ib<<12)+core[925]; inh = 0;  }
void P01646() { core[001672] = 01647; npc = 001672+1; code[001672] = &emul8; inh = 0;  }
void P01647() { core[(ib<<12)+core[98]] = 01650; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L01650() { lac += core[000065];  }
void I01651() { core[(ib<<12)+core[1020]] = 01652; npc = (ib<<12)+core[1020]+1; code[(ib<<12)+core[1020]] = &emul8; inh = 0;  }
void I01652() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void I01653() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I01654() { lac += core[001663];  }
void I01655() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01656() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01657() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I01660() { emul8();  }
void I01661() { lac += core[000022];  }
void I01662() { emul8();  }
void D01663() { lac &= (010000|core[000000]);  }
void I01664() { core[(ib<<12)+core[97]] = 01665; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I01665() { core[(ib<<12)+core[1019]] = 01666; npc = (ib<<12)+core[1019]+1; code[(ib<<12)+core[1019]] = &emul8; inh = 0;  }
void I01666() { core[(ib<<12)+core[42]] = 01667; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I01667() { emul8();  }
void I01670() { npc = 001713; inh = 0;  }
void I01671() { npc = 001717; inh = 0;  }
void S01672() { lac &= (010000|core[000000]);  }
void I01673() { core[(ib<<12)+core[96]] = 01674; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01674() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I01675() { core[001663] = lac & 07777; lac &= 010000; code[001663] = &emul8;  }
void I01676() { lac += core[001772];  }
void I01677() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I01700() { lac += core[001771];  }
void I01701() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I01702() { lac += core[000174];  }
void I01703() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I01704() { core[(ib<<12)+core[93]] = 01705; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I01705() { npc = (ib<<12)+core[954]; inh = 0;  }
void P01706() { if (++core[001663] == 010000) { core[001663] = 0; npc++; }; code[001663] = &emul8;  }
void I01707() { if (++core[000114] == 010000) { core[000114] = 0; npc++; }; code[000114] = &emul8;  }
void I01710() { npc = 001647; inh = 0;  }
void I01711() { npc = (ib<<12)+core[970]; inh = 0;  }
void P01712() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void L01713() { core[(ib<<12)+core[101]] = 01714; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01714() { core[001722] = 01715; npc = 001722+1; code[001722] = &emul8; inh = 0;  }
void I01715() { core[(ib<<12)+core[99]] = 01716; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I01716() { hlt = 1;  }
void L01717() { core[(ib<<12)+core[100]] = 01720; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I01720() { npc = 001650; inh = 0;  }
void I01721() { npc = 001647; inh = 0;  }
void S01722() { lac &= (010000|core[000000]);  }
void I01723() { core[(ib<<12)+core[92]] = 01724; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I01724() { emul8();  }
void I01725() { emul8();  }
void I01726() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01727() { emul8();  }
void I01730() { core[(ib<<12)+core[103]] = 01731; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01731() { core[(ib<<12)+core[95]] = 01732; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I01732() { npc = (ib<<12)+core[978]; inh = 0;  }
void D01771() { lac += core[(df<<12)+core[966]];  }
void D01772() { lac += core[(df<<12)+core[935]];  }
void P01773() { emul8();  }
void P01774() { emul8();  }
void D01775() { lac += core[(df<<12)+core[934]];  }
void D01776() { lac += core[(df<<12)+core[896]];  }
void P01777() { emul8();  }
void L02000() { core[002016] = 02001; npc = 002016+1; code[002016] = &emul8; inh = 0;  }
void L02001() { core[(ib<<12)+core[106]] = 02002; npc = (ib<<12)+core[106]+1; code[(ib<<12)+core[106]] = &emul8; inh = 0;  }
void L02002() { core[(ib<<12)+core[105]] = 02003; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02003() { lac += core[000024];  }
void I02004() { core[002007] = lac & 07777; lac &= 010000; code[002007] = &emul8;  }
void I02005() { lac += core[000022];  }
void I02006() { emul8();  }
void D02007() { lac &= (010000|core[000000]);  }
void I02010() { core[(ib<<12)+core[97]] = 02011; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I02011() { core[(ib<<12)+core[1151]] = 02012; npc = (ib<<12)+core[1151]+1; code[(ib<<12)+core[1151]] = &emul8; inh = 0;  }
void I02012() { core[(ib<<12)+core[42]] = 02013; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I02013() { emul8();  }
void I02014() { npc = 002026; inh = 0;  }
void I02015() { npc = 002032; inh = 0;  }
void S02016() { lac &= (010000|core[000000]);  }
void I02017() { core[(ib<<12)+core[96]] = 02020; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I02020() { lac += core[002176];  }
void I02021() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I02022() { lac += core[002175];  }
void I02023() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02024() { core[(ib<<12)+core[93]] = 02025; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I02025() { npc = (ib<<12)+core[1038]; inh = 0;  }
void L02026() { core[(ib<<12)+core[101]] = 02027; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I02027() { core[002035] = 02030; npc = 002035+1; code[002035] = &emul8; inh = 0;  }
void I02030() { core[(ib<<12)+core[99]] = 02031; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I02031() { hlt = 1;  }
void L02032() { core[(ib<<12)+core[100]] = 02033; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I02033() { npc = 002002; inh = 0;  }
void I02034() { npc = 002001; inh = 0;  }
void S02035() { lac &= (010000|core[000000]);  }
void I02036() { core[(ib<<12)+core[92]] = 02037; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I02037() { emul8();  }
void I02040() { emul8();  }
void I02041() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02042() { emul8();  }
void I02043() { core[(ib<<12)+core[103]] = 02044; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I02044() { core[(ib<<12)+core[95]] = 02045; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I02045() { npc = (ib<<12)+core[1053]; inh = 0;  }
void I02046() { core[002072] = 02047; npc = 002072+1; code[002072] = &emul8; inh = 0;  }
void L02047() { core[(ib<<12)+core[98]] = 02050; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L02050() { lac += core[000065];  }
void I02051() { core[(ib<<12)+core[1148]] = 02052; npc = (ib<<12)+core[1148]+1; code[(ib<<12)+core[1148]] = &emul8; inh = 0;  }
void I02052() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void I02053() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I02054() { lac += core[002063];  }
void I02055() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I02056() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I02057() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I02060() { emul8();  }
void I02061() { lac += core[000022];  }
void I02062() { emul8();  }
void D02063() { lac &= (010000|core[000000]);  }
void I02064() { core[(ib<<12)+core[97]] = 02065; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I02065() { core[(ib<<12)+core[1147]] = 02066; npc = (ib<<12)+core[1147]+1; code[(ib<<12)+core[1147]] = &emul8; inh = 0;  }
void I02066() { core[(ib<<12)+core[42]] = 02067; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I02067() { emul8();  }
void I02070() { npc = 002113; inh = 0;  }
void I02071() { npc = 002117; inh = 0;  }
void S02072() { lac &= (010000|core[000000]);  }
void I02073() { core[(ib<<12)+core[96]] = 02074; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I02074() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I02075() { core[002063] = lac & 07777; lac &= 010000; code[002063] = &emul8;  }
void I02076() { lac += core[002172];  }
void I02077() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I02100() { lac += core[002171];  }
void I02101() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02102() { lac += core[000174];  }
void I02103() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I02104() { core[(ib<<12)+core[93]] = 02105; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I02105() { npc = (ib<<12)+core[1082]; inh = 0;  }
void I02106() { if (++core[002063] == 010000) { core[002063] = 0; npc++; }; code[002063] = &emul8;  }
void I02107() { if (++core[000114] == 010000) { core[000114] = 0; npc++; }; code[000114] = &emul8;  }
void I02110() { npc = 002047; inh = 0;  }
void I02111() { npc = (ib<<12)+core[1098]; inh = 0;  }
void P02112() { if (++core[002000] == 010000) { core[002000] = 0; npc++; }; code[002000] = &emul8;  }
void L02113() { core[(ib<<12)+core[101]] = 02114; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I02114() { core[002122] = 02115; npc = 002122+1; code[002122] = &emul8; inh = 0;  }
void I02115() { core[(ib<<12)+core[99]] = 02116; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I02116() { hlt = 1;  }
void L02117() { core[(ib<<12)+core[100]] = 02120; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I02120() { npc = 002050; inh = 0;  }
void I02121() { npc = 002047; inh = 0;  }
void S02122() { lac &= (010000|core[000000]);  }
void I02123() { core[(ib<<12)+core[92]] = 02124; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I02124() { emul8();  }
void I02125() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; hlt = 1;  }
void I02126() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02127() { emul8();  }
void I02130() { core[(ib<<12)+core[103]] = 02131; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I02131() { core[(ib<<12)+core[95]] = 02132; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I02132() { npc = (ib<<12)+core[1106]; inh = 0;  }
void D02171() { if (++core[000106] == 010000) { core[000106] = 0; npc++; }; code[000106] = &emul8;  }
void D02172() { if (++core[000047] == 010000) { core[000047] = 0; npc++; }; code[000047] = &emul8;  }
void P02173() { emul8();  }
void P02174() { emul8();  }
void D02175() { if (++core[000046] == 010000) { core[000046] = 0; npc++; }; code[000046] = &emul8;  }
void D02176() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void P02177() { emul8();  }
void L02200() { core[002216] = 02201; npc = 002216+1; code[002216] = &emul8; inh = 0;  }
void L02201() { core[(ib<<12)+core[106]] = 02202; npc = (ib<<12)+core[106]+1; code[(ib<<12)+core[106]] = &emul8; inh = 0;  }
void L02202() { core[(ib<<12)+core[105]] = 02203; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02203() { lac += core[000024];  }
void I02204() { core[002207] = lac & 07777; lac &= 010000; code[002207] = &emul8;  }
void I02205() { lac += core[000022];  }
void I02206() { emul8();  }
void D02207() { lac &= (010000|core[000000]);  }
void I02210() { core[(ib<<12)+core[97]] = 02211; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I02211() { core[(ib<<12)+core[1279]] = 02212; npc = (ib<<12)+core[1279]+1; code[(ib<<12)+core[1279]] = &emul8; inh = 0;  }
void I02212() { core[(ib<<12)+core[42]] = 02213; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I02213() { emul8();  }
void I02214() { npc = 002226; inh = 0;  }
void I02215() { npc = 002232; inh = 0;  }
void S02216() { lac &= (010000|core[000000]);  }
void I02217() { core[(ib<<12)+core[96]] = 02220; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I02220() { lac += core[002376];  }
void I02221() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I02222() { lac += core[002375];  }
void I02223() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02224() { core[(ib<<12)+core[93]] = 02225; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I02225() { npc = (ib<<12)+core[1166]; inh = 0;  }
void L02226() { core[(ib<<12)+core[101]] = 02227; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I02227() { core[002235] = 02230; npc = 002235+1; code[002235] = &emul8; inh = 0;  }
void I02230() { core[(ib<<12)+core[99]] = 02231; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I02231() { hlt = 1;  }
void L02232() { core[(ib<<12)+core[100]] = 02233; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I02233() { npc = 002202; inh = 0;  }
void I02234() { npc = 002201; inh = 0;  }
void S02235() { lac &= (010000|core[000000]);  }
void I02236() { core[(ib<<12)+core[92]] = 02237; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I02237() { emul8();  }
void I02240() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; hlt = 1;  }
void I02241() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02242() { emul8();  }
void I02243() { core[(ib<<12)+core[103]] = 02244; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I02244() { core[(ib<<12)+core[95]] = 02245; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I02245() { npc = (ib<<12)+core[1181]; inh = 0;  }
void L02246() { core[(ib<<12)+core[1276]] = 02247; npc = (ib<<12)+core[1276]+1; code[(ib<<12)+core[1276]] = &emul8; inh = 0;  }
void I02247() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void L02250() { core[(ib<<12)+core[1275]] = 02251; npc = (ib<<12)+core[1275]+1; code[(ib<<12)+core[1275]] = &emul8; inh = 0;  }
void L02251() { lac &= 010000; lac &= 07777;  }
void I02252() { lac += core[000044];  }
void I02253() { lac += core[000043];  }
void I02254() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02255() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02256() { core[002302] = 02257; npc = 002302+1; code[002302] = &emul8; inh = 0;  }
void I02257() { core[002313] = 02260; npc = 002313+1; code[002313] = &emul8; inh = 0;  }
void I02260() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I02261() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I02262() { lac += core[000042];  }
void D02263() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I02264() { lac += core[000044];  }
void I02265() { emul8();  }
void I02266() { lac += core[000043];  }
void I02267() { emul8();  }
void D02270() { lac &= (010000|core[000000]);  }
void D02271() { lac &= (010000|core[000000]);  }
void L02272() { core[(ib<<12)+core[97]] = 02273; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I02273() { core[(ib<<12)+core[42]] = 02274; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I02274() { emul8();  }
void I02275() { skp = 0; skp = !skp; npc += skp; lac &= 010000;  }
void I02276() { npc = (ib<<12)+core[1274]; inh = 0;  }
void I02277() { lac += core[002371];  }
void I02300() { core[(df<<12)+core[1272]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1272]] = &emul8;  }
void D02301() { npc = (ib<<12)+core[1271]; inh = 0;  }
void S02302() { lac &= (010000|core[000000]);  }
void I02303() { lac += core[002366];  }
void I02304() { core[002270] = lac & 07777; lac &= 010000; code[002270] = &emul8;  }
void I02305() { lac += core[002364];  }
void I02306() { core[002271] = lac & 07777; lac &= 010000; code[002271] = &emul8;  }
void I02307() { lac += core[002363];  }
void I02310() { core[(df<<12)+core[1272]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1272]] = &emul8;  }
void D02311() { if (++core[002302] == 010000) { core[002302] = 0; npc++; }; code[002302] = &emul8;  }
void I02312() { npc = (ib<<12)+core[1218]; inh = 0;  }
void S02313() { lac &= (010000|core[000000]);  }
void I02314() { lac += core[002366];  }
void I02315() { core[002271] = lac & 07777; lac &= 010000; code[002271] = &emul8;  }
void I02316() { lac += core[002364];  }
void I02317() { core[002270] = lac & 07777; lac &= 010000; code[002270] = &emul8;  }
void I02320() { lac += core[002362];  }
void I02321() { core[(df<<12)+core[1272]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1272]] = &emul8;  }
void I02322() { npc = (ib<<12)+core[1227]; inh = 0;  }
void D02362() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac |= swr;  }
void D02363() { emul8();  }
void D02364() { npc = (ib<<12)+core[1269]; inh = 0;  }
void P02365() { if (++core[(df<<12)+core[74]] == 010000) { core[(df<<12)+core[74]] = 0; npc++; }; code[(df<<12)+core[74]] = &emul8;  }
void D02366() { npc = 002272; inh = 0;  }
void P02367() { if (++core[(df<<12)+core[75]] == 010000) { core[(df<<12)+core[75]] = 0; npc++; }; code[(df<<12)+core[75]] = &emul8;  }
void P02370() { npc = (ib<<12)+core[100]; inh = 0;  }
void D02371() { emul8();  }
void P02372() { if (++core[(df<<12)+core[79]] == 010000) { core[(df<<12)+core[79]] = 0; npc++; }; code[(df<<12)+core[79]] = &emul8;  }
void P02373() { if (++core[(df<<12)+core[62]] == 010000) { core[(df<<12)+core[62]] = 0; npc++; }; code[(df<<12)+core[62]] = &emul8;  }
void P02374() { if (++core[(df<<12)+core[0]] == 010000) { core[(df<<12)+core[0]] = 0; npc++; }; code[(df<<12)+core[0]] = &emul8;  }
void D02375() { if (++core[002246] == 010000) { core[002246] = 0; npc++; }; code[002246] = &emul8;  }
void D02376() { if (++core[002200] == 010000) { core[002200] = 0; npc++; }; code[002200] = &emul8;  }
void P02377() { emul8();  }
void S02400() { lac &= (010000|core[000000]);  }
void I02401() { core[(ib<<12)+core[96]] = 02402; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I02402() { lac += core[002577];  }
void I02403() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I02404() { lac += core[002576];  }
void I02405() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02406() { lac += core[(df<<12)+core[1405]];  }
void I02407() { core[(df<<12)+core[1404]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1404]] = &emul8;  }
void I02410() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I02411() { core[002473] = lac & 07777; lac &= 010000; code[002473] = &emul8;  }
void I02412() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I02413() { core[002474] = lac & 07777; lac &= 010000; code[002474] = &emul8;  }
void I02414() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I02415() { core[002475] = lac & 07777; lac &= 010000; code[002475] = &emul8;  }
void I02416() { lac += core[002573];  }
void I02417() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I02420() { core[(ib<<12)+core[93]] = 02421; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I02421() { lac += core[000115];  }
void I02422() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I02423() { npc = 002464; inh = 0;  }
void I02424() { emul8();  }
void I02425() { npc = (ib<<12)+core[1280]; inh = 0;  }
void L02426() { if (++core[000114] == 010000) { core[000114] = 0; npc++; }; code[000114] = &emul8;  }
void I02427() { npc = (ib<<12)+core[1402]; inh = 0;  }
void I02430() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02431() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I02432() { lac &= 010000; lac ^= 07777;  }
void I02433() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I02434() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I02435() { if (++core[002473] == 010000) { core[002473] = 0; npc++; }; code[002473] = &emul8;  }
void I02436() { npc = (ib<<12)+core[1402]; inh = 0;  }
void I02437() { lac &= 010000; lac ^= 07777;  }
void I02440() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I02441() { lac &= 010000; lac ^= 07777;  }
void I02442() { core[002473] = lac & 07777; lac &= 010000; code[002473] = &emul8;  }
void I02443() { lac &= 010000; lac ^= 07777;  }
void I02444() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I02445() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void D02446() { if (++core[002474] == 010000) { core[002474] = 0; npc++; }; code[002474] = &emul8;  }
void I02447() { npc = (ib<<12)+core[1402]; inh = 0;  }
void D02450() { lac &= 010000; lac ^= 07777;  }
void D02451() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I02452() { lac ^= 07777;  }
void I02453() { core[002473] = lac & 07777; lac &= 010000; code[002473] = &emul8;  }
void I02454() { lac ^= 07777;  }
void I02455() { core[002474] = lac & 07777; lac &= 010000; code[002474] = &emul8;  }
void I02456() { lac ^= 07777;  }
void I02457() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I02460() { lac ^= 07777;  }
void I02461() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I02462() { if (++core[002475] == 010000) { core[002475] = 0; npc++; }; code[002475] = &emul8;  }
void I02463() { npc = (ib<<12)+core[1402]; inh = 0;  }
void L02464() { lac &= 010000; lac |= swr;  }
void I02465() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02466() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02467() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02470() { npc = (ib<<12)+core[1407]; inh = 0;  }
void I02471() { npc = (ib<<12)+core[1338]; inh = 0;  }
void P02472() { if (++core[(df<<12)+core[1280]] == 010000) { core[(df<<12)+core[1280]] = 0; npc++; }; code[(df<<12)+core[1280]] = &emul8;  }
void D02473() { lac &= (010000|core[000000]);  }
void D02474() { lac &= (010000|core[000000]);  }
void D02475() { lac &= (010000|core[000000]);  }
void D02476() { lac &= (010000|core[000000]);  }
void I02477() { lac += core[000044];  }
void I02500() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02501() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I02502() { lac += core[000043];  }
void I02503() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02504() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I02505() { lac += core[000043];  }
void I02506() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void I02507() { lac += core[000044];  }
void I02510() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I02511() { npc = 002426; inh = 0;  }
void L02512() { core[(ib<<12)+core[97]] = 02513; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void L02513() { core[(ib<<12)+core[101]] = 02514; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I02514() { core[002523] = 02515; npc = 002523+1; code[002523] = &emul8; inh = 0;  }
void I02515() { core[(ib<<12)+core[99]] = 02516; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I02516() { hlt = 1;  }
void L02517() { core[(ib<<12)+core[100]] = 02520; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I02520() { npc = (ib<<12)+core[1402]; inh = 0;  }
void I02521() { lac &= 07777;  }
void I02522() { npc = (ib<<12)+core[1401]; inh = 0;  }
void S02523() { lac &= (010000|core[000000]);  }
void I02524() { core[(ib<<12)+core[92]] = 02525; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I02525() { emul8();  }
void I02526() { emul8();  }
void I02527() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02530() { emul8();  }
void I02531() { core[(ib<<12)+core[95]] = 02532; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I02532() { npc = (ib<<12)+core[1363]; inh = 0;  }
void P02571() { if (++core[002450] == 010000) { core[002450] = 0; npc++; }; code[002450] = &emul8;  }
void P02572() { if (++core[002451] == 010000) { core[002451] = 0; npc++; }; code[002451] = &emul8;  }
void D02573() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P02574() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void P02575() { lac ^= 07777; lac++; lac = (lac<<1) + ((lac>>12)&1);  }
void D02576() { if (++core[(df<<12)+core[22]] == 010000) { core[(df<<12)+core[22]] = 0; npc++; }; code[(df<<12)+core[22]] = &emul8;  }
void P02577() { if (++core[002446] == 010000) { core[002446] = 0; npc++; }; code[002446] = &emul8;  }
void L02600() { core[002621] = 02601; npc = 002621+1; code[002621] = &emul8; inh = 0;  }
void P02601() { core[(ib<<12)+core[98]] = 02602; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L02602() { lac &= 010000; lac ^= 07777;  }
void I02603() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void I02604() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I02605() { lac += core[000065];  }
void I02606() { emul8();  }
void I02607() { emul8();  }
void I02610() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I02611() { lac &= 010000; lac ^= 07777;  }
void I02612() { emul8();  }
void I02613() { core[(ib<<12)+core[97]] = 02614; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I02614() { core[(ib<<12)+core[1535]] = 02615; npc = (ib<<12)+core[1535]+1; code[(ib<<12)+core[1535]] = &emul8; inh = 0;  }
void I02615() { core[(ib<<12)+core[42]] = 02616; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I02616() { emul8();  }
void I02617() { npc = 002634; inh = 0;  }
void I02620() { npc = 002640; inh = 0;  }
void S02621() { lac &= (010000|core[000000]);  }
void I02622() { core[(ib<<12)+core[96]] = 02623; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I02623() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I02624() { lac += core[002776];  }
void I02625() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I02626() { lac += core[002775];  }
void I02627() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02630() { core[(ib<<12)+core[93]] = 02631; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I02631() { core[(ib<<12)+core[94]] = 02632; npc = (ib<<12)+core[94]+1; code[(ib<<12)+core[94]] = &emul8; inh = 0;  }
void I02632() { emul8();  }
void I02633() { npc = (ib<<12)+core[1425]; inh = 0;  }
void L02634() { core[(ib<<12)+core[101]] = 02635; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I02635() { core[002643] = 02636; npc = 002643+1; code[002643] = &emul8; inh = 0;  }
void I02636() { core[(ib<<12)+core[99]] = 02637; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I02637() { hlt = 1;  }
void L02640() { core[(ib<<12)+core[100]] = 02641; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I02641() { npc = 002602; inh = 0;  }
void I02642() { npc = 002601; inh = 0;  }
void S02643() { lac &= (010000|core[000000]);  }
void I02644() { core[(ib<<12)+core[92]] = 02645; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I02645() { emul8();  }
void I02646() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02647() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02650() { emul8();  }
void I02651() { core[(ib<<12)+core[95]] = 02652; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I02652() { npc = (ib<<12)+core[1443]; inh = 0;  }
void P02653() { core[002667] = 02654; npc = 002667+1; code[002667] = &emul8; inh = 0;  }
void L02654() { core[(ib<<12)+core[106]] = 02655; npc = (ib<<12)+core[106]+1; code[(ib<<12)+core[106]] = &emul8; inh = 0;  }
void L02655() { core[(ib<<12)+core[110]] = 02656; npc = (ib<<12)+core[110]+1; code[(ib<<12)+core[110]] = &emul8; inh = 0;  }
void I02656() { core[(ib<<12)+core[105]] = 02657; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02657() { lac += core[000022];  }
void I02660() { emul8();  }
void I02661() { core[(ib<<12)+core[97]] = 02662; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I02662() { core[(ib<<12)+core[1535]] = 02663; npc = (ib<<12)+core[1535]+1; code[(ib<<12)+core[1535]] = &emul8; inh = 0;  }
void I02663() { core[(ib<<12)+core[42]] = 02664; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I02664() { emul8();  }
void I02665() { npc = 002700; inh = 0;  }
void I02666() { npc = 002704; inh = 0;  }
void S02667() { lac &= (010000|core[000000]);  }
void I02670() { core[(ib<<12)+core[96]] = 02671; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I02671() { lac += core[002775];  }
void I02672() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I02673() { lac += core[002774];  }
void I02674() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02675() { core[(ib<<12)+core[93]] = 02676; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I02676() { core[(ib<<12)+core[94]] = 02677; npc = (ib<<12)+core[94]+1; code[(ib<<12)+core[94]] = &emul8; inh = 0;  }
void I02677() { npc = (ib<<12)+core[1463]; inh = 0;  }
void L02700() { core[(ib<<12)+core[101]] = 02701; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I02701() { core[002707] = 02702; npc = 002707+1; code[002707] = &emul8; inh = 0;  }
void I02702() { core[(ib<<12)+core[99]] = 02703; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I02703() { hlt = 1;  }
void L02704() { core[(ib<<12)+core[100]] = 02705; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I02705() { npc = 002655; inh = 0;  }
void I02706() { npc = 002654; inh = 0;  }
void S02707() { lac &= (010000|core[000000]);  }
void I02710() { core[(ib<<12)+core[92]] = 02711; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I02711() { emul8();  }
void I02712() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02713() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02714() { emul8();  }
void I02715() { core[(ib<<12)+core[95]] = 02716; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I02716() { npc = (ib<<12)+core[1479]; inh = 0;  }
void P02717() { core[(ib<<12)+core[1531]] = 02720; npc = (ib<<12)+core[1531]+1; code[(ib<<12)+core[1531]] = &emul8; inh = 0;  }
void L02720() { core[(ib<<12)+core[106]] = 02721; npc = (ib<<12)+core[106]+1; code[(ib<<12)+core[106]] = &emul8; inh = 0;  }
void L02721() { core[(ib<<12)+core[110]] = 02722; npc = (ib<<12)+core[110]+1; code[(ib<<12)+core[110]] = &emul8; inh = 0;  }
void I02722() { core[(ib<<12)+core[105]] = 02723; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02723() { lac += core[000022];  }
void I02724() { emul8();  }
void I02725() { core[(ib<<12)+core[97]] = 02726; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I02726() { core[(ib<<12)+core[1530]] = 02727; npc = (ib<<12)+core[1530]+1; code[(ib<<12)+core[1530]] = &emul8; inh = 0;  }
void I02727() { core[(ib<<12)+core[42]] = 02730; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I02730() { emul8();  }
void I02731() { npc = (ib<<12)+core[1529]; inh = 0;  }
void I02732() { npc = (ib<<12)+core[1528]; inh = 0;  }
void P02770() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void P02771() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void P02772() { emul8();  }
void P02773() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void D02774() { if (++core[(df<<12)+core[1487]] == 010000) { core[(df<<12)+core[1487]] = 0; npc++; }; code[(df<<12)+core[1487]] = &emul8;  }
void D02775() { if (++core[(df<<12)+core[1451]] == 010000) { core[(df<<12)+core[1451]] = 0; npc++; }; code[(df<<12)+core[1451]] = &emul8;  }
void D02776() { if (++core[(df<<12)+core[1409]] == 010000) { core[(df<<12)+core[1409]] = 0; npc++; }; code[(df<<12)+core[1409]] = &emul8;  }
void P02777() { emul8();  }
void S03000() { lac &= (010000|core[000000]);  }
void I03001() { core[(ib<<12)+core[96]] = 03002; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I03002() { lac += core[003177];  }
void I03003() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I03004() { lac += core[003176];  }
void I03005() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I03006() { core[(ib<<12)+core[93]] = 03007; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I03007() { core[(ib<<12)+core[94]] = 03010; npc = (ib<<12)+core[94]+1; code[(ib<<12)+core[94]] = &emul8; inh = 0;  }
void I03010() { npc = (ib<<12)+core[1536]; inh = 0;  }
void L03011() { core[(ib<<12)+core[101]] = 03012; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03012() { core[003020] = 03013; npc = 003020+1; code[003020] = &emul8; inh = 0;  }
void I03013() { core[(ib<<12)+core[99]] = 03014; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I03014() { hlt = 1;  }
void L03015() { core[(ib<<12)+core[100]] = 03016; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I03016() { npc = (ib<<12)+core[1661]; inh = 0;  }
void I03017() { npc = (ib<<12)+core[1660]; inh = 0;  }
void S03020() { lac &= (010000|core[000000]);  }
void I03021() { core[(ib<<12)+core[92]] = 03022; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I03022() { emul8();  }
void I03023() { emul8();  }
void D03024() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03025() { emul8();  }
void I03026() { core[(ib<<12)+core[95]] = 03027; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I03027() { npc = (ib<<12)+core[1552]; inh = 0;  }
void I03030() { core[003067] = 03031; npc = 003067+1; code[003067] = &emul8; inh = 0;  }
void L03031() { core[003053] = 03032; npc = 003053+1; code[003053] = &emul8; inh = 0;  }
void L03032() { lac += core[000021];  }
void I03033() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I03034() { lac += core[000023];  }
void I03035() { emul8();  }
void I03036() { lac += core[000024];  }
void I03037() { core[000122] = lac & 07777; lac &= 010000; code[000122] = &emul8;  }
void I03040() { lac += core[000025];  }
void I03041() { core[000121] = lac & 07777; lac &= 010000; code[000121] = &emul8;  }
void I03042() { lac += core[000022];  }
void I03043() { emul8();  }
void I03044() { lac &= (010000|core[000121]);  }
void I03045() { core[(ib<<12)+core[97]] = 03046; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I03046() { core[(ib<<12)+core[1659]] = 03047; npc = (ib<<12)+core[1659]+1; code[(ib<<12)+core[1659]] = &emul8; inh = 0;  }
void I03047() { core[(ib<<12)+core[42]] = 03050; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I03050() { emul8();  }
void I03051() { npc = 003107; inh = 0;  }
void I03052() { npc = 003125; inh = 0;  }
void S03053() { lac &= (010000|core[000000]);  }
void I03054() { core[(ib<<12)+core[43]] = 03055; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void D03055() { lac &= (010000|core[000000]);  }
void I03056() { lac &= (010000|core[000021]);  }
void I03057() { emul8();  }
void I03060() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<2) + ((lac>>11)&3);  }
void I03061() { lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03062() { lac += core[003055];  }
void I03063() { core[003055] = lac & 07777; lac &= 010000; code[003055] = &emul8;  }
void D03064() { if (++core[000114] == 010000) { core[000114] = 0; npc++; }; code[000114] = &emul8;  }
void I03065() { npc = (ib<<12)+core[1579]; inh = 0;  }
void I03066() { npc = (ib<<12)+core[125]; inh = 0;  }
void S03067() { lac &= (010000|core[000000]);  }
void I03070() { core[(ib<<12)+core[96]] = 03071; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I03071() { lac += core[003172];  }
void I03072() { core[003055] = lac & 07777; lac &= 010000; code[003055] = &emul8;  }
void I03073() { lac += core[003176];  }
void I03074() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I03075() { lac += core[003171];  }
void I03076() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I03077() { lac += core[003170];  }
void I03100() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I03101() { lac += core[(df<<12)+core[1655]];  }
void I03102() { core[(df<<12)+core[1654]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1654]] = &emul8;  }
void I03103() { core[(ib<<12)+core[93]] = 03104; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I03104() { core[(ib<<12)+core[94]] = 03105; npc = (ib<<12)+core[94]+1; code[(ib<<12)+core[94]] = &emul8; inh = 0;  }
void I03105() { emul8();  }
void I03106() { npc = (ib<<12)+core[1591]; inh = 0;  }
void L03107() { lac += core[000024];  }
void I03110() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I03111() { lac += core[000025];  }
void I03112() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I03113() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I03114() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I03115() { core[(ib<<12)+core[101]] = 03116; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03116() { core[003130] = 03117; npc = 003130+1; code[003130] = &emul8; inh = 0;  }
void P03117() { lac += core[000040];  }
void P03120() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void P03121() { lac += core[000041];  }
void I03122() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I03123() { core[(ib<<12)+core[99]] = 03124; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I03124() { hlt = 1;  }
void L03125() { core[(ib<<12)+core[100]] = 03126; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I03126() { npc = 003032; inh = 0;  }
void I03127() { npc = 003031; inh = 0;  }
void S03130() { lac &= (010000|core[000000]);  }
void I03131() { core[(ib<<12)+core[92]] = 03132; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I03132() { emul8();  }
void I03133() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac |= swr; hlt = 1;  }
void I03134() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03135() { emul8();  }
void I03136() { core[(ib<<12)+core[95]] = 03137; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I03137() { npc = (ib<<12)+core[1624]; inh = 0;  }
void P03166() { lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void P03167() { lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void D03170() { emul8();  }
void D03171() { core[003000] = lac & 07777; lac &= 010000; code[003000] = &emul8;  }
void D03172() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void P03173() { emul8();  }
void P03174() { if (++core[(df<<12)+core[1616]] == 010000) { core[(df<<12)+core[1616]] = 0; npc++; }; code[(df<<12)+core[1616]] = &emul8;  }
void P03175() { if (++core[(df<<12)+core[1617]] == 010000) { core[(df<<12)+core[1617]] = 0; npc++; }; code[(df<<12)+core[1617]] = &emul8;  }
void D03176() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void D03177() { if (++core[(df<<12)+core[1615]] == 010000) { core[(df<<12)+core[1615]] = 0; npc++; }; code[(df<<12)+core[1615]] = &emul8;  }
void D03200() { core[003223] = 03201; npc = 003223+1; code[003223] = &emul8; inh = 0;  }
void L03201() { core[003241] = 03202; npc = 003241+1; code[003241] = &emul8; inh = 0;  }
void L03202() { lac += core[000021];  }
void I03203() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I03204() { lac += core[000023];  }
void I03205() { emul8();  }
void I03206() { lac += core[000024];  }
void I03207() { core[000122] = lac & 07777; lac &= 010000; code[000122] = &emul8;  }
void I03210() { lac += core[000025];  }
void I03211() { core[000121] = lac & 07777; lac &= 010000; code[000121] = &emul8;  }
void I03212() { lac += core[000022];  }
void I03213() { emul8();  }
void I03214() { lac &= (010000|core[000121]);  }
void I03215() { core[(ib<<12)+core[97]] = 03216; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I03216() { core[(ib<<12)+core[1791]] = 03217; npc = (ib<<12)+core[1791]+1; code[(ib<<12)+core[1791]] = &emul8; inh = 0;  }
void I03217() { core[(ib<<12)+core[42]] = 03220; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I03220() { emul8();  }
void I03221() { npc = 003257; inh = 0;  }
void I03222() { npc = 003275; inh = 0;  }
void S03223() { lac &= (010000|core[000000]);  }
void I03224() { core[(ib<<12)+core[96]] = 03225; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I03225() { lac += core[003376];  }
void I03226() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I03227() { lac += core[003375];  }
void I03230() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I03231() { lac += core[(df<<12)+core[1788]];  }
void I03232() { core[(df<<12)+core[1787]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1787]] = &emul8;  }
void I03233() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I03234() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I03235() { core[(ib<<12)+core[93]] = 03236; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I03236() { core[(ib<<12)+core[94]] = 03237; npc = (ib<<12)+core[94]+1; code[(ib<<12)+core[94]] = &emul8; inh = 0;  }
void I03237() { emul8();  }
void I03240() { npc = (ib<<12)+core[1683]; inh = 0;  }
void S03241() { lac &= (010000|core[000000]);  }
void I03242() { core[(ib<<12)+core[1786]] = 03243; npc = (ib<<12)+core[1786]+1; code[(ib<<12)+core[1786]] = &emul8; inh = 0;  }
void I03243() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void I03244() { core[(ib<<12)+core[1786]] = 03245; npc = (ib<<12)+core[1786]+1; code[(ib<<12)+core[1786]] = &emul8; inh = 0;  }
void I03245() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I03246() { core[(ib<<12)+core[1786]] = 03247; npc = (ib<<12)+core[1786]+1; code[(ib<<12)+core[1786]] = &emul8; inh = 0;  }
void I03247() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I03250() { core[(ib<<12)+core[1786]] = 03251; npc = (ib<<12)+core[1786]+1; code[(ib<<12)+core[1786]] = &emul8; inh = 0;  }
void I03251() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I03252() { lac &= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03253() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I03254() { core[(ib<<12)+core[123]] = 03255; npc = (ib<<12)+core[123]+1; code[(ib<<12)+core[123]] = &emul8; inh = 0;  }
void I03255() { npc = (ib<<12)+core[1697]; inh = 0;  }
void I03256() { npc = (ib<<12)+core[125]; inh = 0;  }
void L03257() { lac += core[000024];  }
void I03260() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I03261() { lac += core[000025];  }
void I03262() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I03263() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I03264() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I03265() { core[(ib<<12)+core[101]] = 03266; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03266() { core[003300] = 03267; npc = 003300+1; code[003300] = &emul8; inh = 0;  }
void I03267() { lac += core[000040];  }
void I03270() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I03271() { lac += core[000041];  }
void I03272() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I03273() { core[(ib<<12)+core[99]] = 03274; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I03274() { hlt = 1;  }
void L03275() { core[(ib<<12)+core[100]] = 03276; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I03276() { npc = 003202; inh = 0;  }
void I03277() { npc = 003201; inh = 0;  }
void S03300() { lac &= (010000|core[000000]);  }
void I03301() { core[(ib<<12)+core[92]] = 03302; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I03302() { emul8();  }
void I03303() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac |= swr; hlt = 1;  }
void I03304() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03305() { emul8();  }
void I03306() { core[(ib<<12)+core[95]] = 03307; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I03307() { npc = (ib<<12)+core[1728]; inh = 0;  }
void D03310() { core[(ib<<12)+core[1785]] = 03311; npc = (ib<<12)+core[1785]+1; code[(ib<<12)+core[1785]] = &emul8; inh = 0;  }
void L03311() { core[(ib<<12)+core[1784]] = 03312; npc = (ib<<12)+core[1784]+1; code[(ib<<12)+core[1784]] = &emul8; inh = 0;  }
void L03312() { lac += core[000042];  }
void I03313() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I03314() { lac += core[000044];  }
void I03315() { emul8();  }
void I03316() { lac += core[000043];  }
void I03317() { emul8();  }
void I03320() { lac &= (010000|core[000121]);  }
void I03321() { core[(ib<<12)+core[97]] = 03322; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I03322() { lac += core[000121];  }
void I03323() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I03324() { lac += core[000122];  }
void I03325() { core[000036] = lac & 07777; lac &= 010000; code[000036] = &emul8;  }
void I03326() { core[(ib<<12)+core[42]] = 03327; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I03327() { emul8();  }
void I03330() { npc = (ib<<12)+core[1783]; inh = 0;  }
void D03331() { lac += core[000044];  }
void D03332() { emul8();  }
void I03333() { lac += core[000043];  }
void I03334() { emul8();  }
void I03335() { emul8();  }
void I03336() { lac &= (010000|core[000121]);  }
void D03337() { emul8();  }
void I03340() { npc = (ib<<12)+core[1783]; inh = 0;  }
void I03341() { npc = (ib<<12)+core[1782]; inh = 0;  }
void P03366() { core[(df<<12)+core[29]] = lac & 07777; lac &= 010000; code[(df<<12)+core[29]] = &emul8;  }
void P03367() { core[(df<<12)+core[25]] = lac & 07777; lac &= 010000; code[(df<<12)+core[25]] = &emul8;  }
void P03370() { core[(df<<12)+core[0]] = lac & 07777; lac &= 010000; code[(df<<12)+core[0]] = &emul8;  }
void P03371() { if (++core[000013] == 010000) core[000013] = 0000;core[(df<<12)+core[000013]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000013]] = &emul8;  }
void P03372() { emul8();  }
void P03373() { lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void P03374() { lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void D03375() { core[003310] = lac & 07777; lac &= 010000; code[003310] = &emul8;  }
void D03376() { core[003200] = lac & 07777; lac &= 010000; code[003200] = &emul8;  }
void P03377() { emul8();  }
void S03400() { lac &= (010000|core[000000]);  }
void I03401() { core[(ib<<12)+core[43]] = 03402; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void D03402() { lac &= (010000|core[000000]);  }
void I03403() { lac &= (010000|core[000042]);  }
void I03404() { emul8();  }
void I03405() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = (lac<<1) + ((lac>>12)&1);  }
void I03406() { lac += core[003402];  }
void I03407() { core[003402] = lac & 07777; lac &= 010000; code[003402] = &emul8;  }
void I03410() { if (++core[000114] == 010000) { core[000114] = 0; npc++; }; code[000114] = &emul8;  }
void I03411() { npc = (ib<<12)+core[1792]; inh = 0;  }
void I03412() { npc = (ib<<12)+core[125]; inh = 0;  }
void S03413() { lac &= (010000|core[000000]);  }
void I03414() { core[(ib<<12)+core[96]] = 03415; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I03415() { lac += core[003577];  }
void I03416() { core[003402] = lac & 07777; lac &= 010000; code[003402] = &emul8;  }
void I03417() { lac += core[003576];  }
void I03420() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I03421() { lac += core[003575];  }
void I03422() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I03423() { lac += core[003574];  }
void I03424() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I03425() { core[(ib<<12)+core[93]] = 03426; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I03426() { core[(ib<<12)+core[94]] = 03427; npc = (ib<<12)+core[94]+1; code[(ib<<12)+core[94]] = &emul8; inh = 0;  }
void I03427() { emul8();  }
void I03430() { npc = (ib<<12)+core[1803]; inh = 0;  }
void L03431() { core[(ib<<12)+core[101]] = 03432; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03432() { core[003440] = 03433; npc = 003440+1; code[003440] = &emul8; inh = 0;  }
void I03433() { core[(ib<<12)+core[99]] = 03434; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I03434() { hlt = 1;  }
void L03435() { core[(ib<<12)+core[100]] = 03436; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I03436() { npc = (ib<<12)+core[1915]; inh = 0;  }
void I03437() { npc = (ib<<12)+core[1914]; inh = 0;  }
void S03440() { lac &= (010000|core[000000]);  }
void I03441() { core[(ib<<12)+core[92]] = 03442; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I03442() { emul8();  }
void I03443() { emul8();  }
void I03444() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03445() { emul8();  }
void I03446() { core[(ib<<12)+core[1913]] = 03447; npc = (ib<<12)+core[1913]+1; code[(ib<<12)+core[1913]] = &emul8; inh = 0;  }
void I03447() { npc = (ib<<12)+core[1824]; inh = 0;  }
void I03450() { core[003514] = 03451; npc = 003514+1; code[003514] = &emul8; inh = 0;  }
void L03451() { core[003502] = 03452; npc = 003502+1; code[003502] = &emul8; inh = 0;  }
void L03452() { lac += core[000042];  }
void I03453() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I03454() { lac += core[000044];  }
void I03455() { emul8();  }
void I03456() { lac += core[000043];  }
void I03457() { emul8();  }
void I03460() { lac &= (010000|core[000121]);  }
void I03461() { core[(ib<<12)+core[97]] = 03462; npc = (ib<<12)+core[97]+1; code[(ib<<12)+core[97]] = &emul8; inh = 0;  }
void I03462() { lac += core[000121];  }
void I03463() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I03464() { lac += core[000122];  }
void I03465() { core[000036] = lac & 07777; lac &= 010000; code[000036] = &emul8;  }
void I03466() { core[(ib<<12)+core[42]] = 03467; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I03467() { emul8();  }
void I03470() { npc = 003526; inh = 0;  }
void I03471() { lac += core[000044];  }
void I03472() { emul8();  }
void I03473() { lac += core[000043];  }
void I03474() { emul8();  }
void I03475() { emul8();  }
void I03476() { lac &= (010000|core[000121]);  }
void I03477() { emul8();  }
void I03500() { npc = 003526; inh = 0;  }
void I03501() { npc = 003532; inh = 0;  }
void S03502() { lac &= (010000|core[000000]);  }
void I03503() { core[(ib<<12)+core[1912]] = 03504; npc = (ib<<12)+core[1912]+1; code[(ib<<12)+core[1912]] = &emul8; inh = 0;  }
void I03504() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I03505() { core[(ib<<12)+core[1912]] = 03506; npc = (ib<<12)+core[1912]+1; code[(ib<<12)+core[1912]] = &emul8; inh = 0;  }
void I03506() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I03507() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void D03510() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void D03511() { core[(ib<<12)+core[123]] = 03512; npc = (ib<<12)+core[123]+1; code[(ib<<12)+core[123]] = &emul8; inh = 0;  }
void D03512() { npc = (ib<<12)+core[1858]; inh = 0;  }
void I03513() { npc = (ib<<12)+core[125]; inh = 0;  }
void S03514() { lac &= (010000|core[000000]);  }
void I03515() { core[(ib<<12)+core[96]] = 03516; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I03516() { lac += core[003575];  }
void I03517() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I03520() { lac += core[003567];  }
void I03521() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I03522() { core[(ib<<12)+core[93]] = 03523; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I03523() { core[(ib<<12)+core[94]] = 03524; npc = (ib<<12)+core[94]+1; code[(ib<<12)+core[94]] = &emul8; inh = 0;  }
void I03524() { emul8();  }
void I03525() { npc = (ib<<12)+core[1868]; inh = 0;  }
void L03526() { core[(ib<<12)+core[101]] = 03527; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03527() { core[003535] = 03530; npc = 003535+1; code[003535] = &emul8; inh = 0;  }
void I03530() { core[(ib<<12)+core[99]] = 03531; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I03531() { hlt = 1;  }
void L03532() { core[(ib<<12)+core[100]] = 03533; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I03533() { npc = 003452; inh = 0;  }
void I03534() { npc = 003451; inh = 0;  }
void S03535() { lac &= (010000|core[000000]);  }
void I03536() { core[(ib<<12)+core[92]] = 03537; npc = (ib<<12)+core[92]+1; code[(ib<<12)+core[92]] = &emul8; inh = 0;  }
void I03537() { emul8();  }
void I03540() { emul8();  }
void I03541() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03542() { emul8();  }
void I03543() { core[(ib<<12)+core[1913]] = 03544; npc = (ib<<12)+core[1913]+1; code[(ib<<12)+core[1913]] = &emul8; inh = 0;  }
void I03544() { npc = (ib<<12)+core[1885]; inh = 0;  }
void D03567() { core[(df<<12)+core[1792]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1792]] = &emul8;  }
void P03570() { emul8();  }
void P03571() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void P03572() { core[003511] = lac & 07777; lac &= 010000; code[003511] = &emul8;  }
void P03573() { core[003512] = lac & 07777; lac &= 010000; code[003512] = &emul8;  }
void D03574() { emul8();  }
void D03575() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void D03576() { core[003510] = lac & 07777; lac &= 010000; code[003510] = &emul8;  }
void D03577() { lac &= 010000; lac &= 07777; lac++; lac = (lac<<1) + ((lac>>12)&1);  }
void L03600() { npc = 003657; inh = 0;  }
void L03601() { core[003712] = 03602; npc = 003712+1; code[003712] = &emul8; inh = 0;  }
void L03602() { lac &= 010000; lac ^= 07777;  }
void I03603() { lac &= (010000|core[003705]);  }
void I03604() { emul8();  }
void I03605() { lac ^= 07777;  }
void I03606() { lac &= (010000|core[003704]);  }
void I03607() { emul8();  }
void I03610() { core[003707] = lac & 07777; lac &= 010000; code[003707] = &emul8;  }
void I03611() { emul8();  }
void I03612() { core[003706] = lac & 07777; lac &= 010000; code[003706] = &emul8;  }
void I03613() { emul8();  }
void I03614() { core[003700] = lac & 07777; lac &= 010000; code[003700] = &emul8;  }
void I03615() { lac ^= 07777;  }
void I03616() { lac &= (010000|core[003707]);  }
void I03617() { lac &= 07777; lac ^= 07777;  }
void I03620() { lac += core[003701];  }
void I03621() { lac ^= 07777;  }
void I03622() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03623() { npc = 003650; inh = 0;  }
void I03624() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03625() { npc = 003650; inh = 0;  }
void I03626() { lac &= 010000; lac ^= 07777;  }
void I03627() { lac &= (010000|core[003706]);  }
void I03630() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03631() { npc = 003650; inh = 0;  }
void I03632() { lac ^= 07777;  }
void I03633() { lac &= (010000|core[003700]);  }
void I03634() { lac &= 07777; lac ^= 07777;  }
void I03635() { lac += core[003703];  }
void I03636() { lac ^= 07777;  }
void I03637() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03640() { npc = 003650; inh = 0;  }
void I03641() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03642() { npc = 003650; inh = 0;  }
void I03643() { lac &= 010000; lac ^= 07777;  }
void I03644() { lac &= (010000|core[003703]);  }
void I03645() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03646() { npc = 003654; inh = 0;  }
void I03647() { npc = 003672; inh = 0;  }
void L03650() { core[(ib<<12)+core[101]] = 03651; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03651() { core[(ib<<12)+core[1993]] = 03652; npc = (ib<<12)+core[1993]+1; code[(ib<<12)+core[1993]] = &emul8; inh = 0;  }
void I03652() { core[(ib<<12)+core[99]] = 03653; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I03653() { hlt = 1;  }
void L03654() { core[(ib<<12)+core[100]] = 03655; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I03655() { npc = 003602; inh = 0;  }
void I03656() { npc = 003601; inh = 0;  }
void L03657() { lac &= 010000; lac ^= 07777;  }
void I03660() { lac &= (010000|core[003727]);  }
void I03661() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I03662() { lac ^= 07777;  }
void I03663() { lac &= (010000|core[003730]);  }
void I03664() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I03665() { lac ^= 07777;  }
void I03666() { lac &= (010000|core[003702]);  }
void I03667() { core[003703] = lac & 07777; lac &= 010000; code[003703] = &emul8;  }
void I03670() { core[(ib<<12)+core[93]] = 03671; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I03671() { npc = 003601; inh = 0;  }
void L03672() { lac &= 010000; lac |= swr;  }
void I03673() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I03674() { lac = (lac<<2) + ((lac>>11)&3);  }
void I03675() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03676() { npc = 003600; inh = 0;  }
void I03677() { npc = (ib<<12)+core[1992]; inh = 0;  }
void D03700() { lac &= (010000|core[000000]);  }
void D03701() { emul8();  }
void D03702() { lac &= (010000|core[000027]);  }
void D03703() { lac &= (010000|core[000000]);  }
void D03704() { lac &= (010000|core[000000]);  }
void D03705() { lac &= (010000|core[000000]);  }
void D03706() { lac &= (010000|core[000000]);  }
void D03707() { lac &= (010000|core[000000]);  }
void P03710() { core[003600] = 03711; npc = 003600+1; code[003600] = &emul8; inh = 0;  }
void P03711() { core[000000] = 03712; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void S03712() { lac &= (010000|core[000000]);  }
void I03713() { lac &= 010000; lac ^= 07777;  }
void I03714() { if (++core[000012] == 010000) core[000012] = 0000;lac &= (010000|core[(df<<12)+core[000012]]);  }
void I03715() { core[003704] = lac & 07777; lac &= 010000; code[003704] = &emul8;  }
void D03716() { lac ^= 07777;  }
void D03717() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void I03720() { core[003705] = lac & 07777; lac &= 010000; code[003705] = &emul8;  }
void I03721() { lac ^= 07777;  }
void I03722() { lac &= (010000|core[003703]);  }
void I03723() { lac ^= 07777; lac++;  }
void I03724() { lac ^= 07777;  }
void I03725() { core[003703] = lac & 07777; lac &= 010000; code[003703] = &emul8;  }
void I03726() { npc = 003731; inh = 0;  }
void D03727() { core[000060] = 03730; npc = 000060+1; code[000060] = &emul8; inh = 0;  }
void D03730() { core[000074] = 03731; npc = 000074+1; code[000074] = &emul8; inh = 0;  }
void L03731() { lac &= 010000; lac ^= 07777;  }
void I03732() { lac &= (010000|core[003703]);  }
void I03733() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03734() { npc = (ib<<12)+core[1994]; inh = 0;  }
void I03735() { npc = 003672; inh = 0;  }
void S04000() { lac &= (010000|core[000000]);  }
void I04001() { core[(ib<<12)+core[85]] = 04002; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I04002() { core[004126] = 04003; npc = 004126+1; code[004126] = &emul8; inh = 0;  }
void I04003() { core[(ib<<12)+core[41]] = 04004; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I04004() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void I04005() { core[(ib<<12)+core[2175]] = 04006; npc = (ib<<12)+core[2175]+1; code[(ib<<12)+core[2175]] = &emul8; inh = 0;  }
void I04006() { core[(ib<<12)+core[2174]] = 04007; npc = (ib<<12)+core[2174]+1; code[(ib<<12)+core[2174]] = &emul8; inh = 0;  }
void I04007() { core[(ib<<12)+core[2173]] = 04010; npc = (ib<<12)+core[2173]+1; code[(ib<<12)+core[2173]] = &emul8; inh = 0;  }
void I04010() { core[(ib<<12)+core[2172]] = 04011; npc = (ib<<12)+core[2172]+1; code[(ib<<12)+core[2172]] = &emul8; inh = 0;  }
void I04011() { core[(ib<<12)+core[41]] = 04012; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I04012() { emul8();  }
void I04013() { core[(ib<<12)+core[2175]] = 04014; npc = (ib<<12)+core[2175]+1; code[(ib<<12)+core[2175]] = &emul8; inh = 0;  }
void I04014() { core[(ib<<12)+core[2174]] = 04015; npc = (ib<<12)+core[2174]+1; code[(ib<<12)+core[2174]] = &emul8; inh = 0;  }
void I04015() { core[(ib<<12)+core[2171]] = 04016; npc = (ib<<12)+core[2171]+1; code[(ib<<12)+core[2171]] = &emul8; inh = 0;  }
void I04016() { core[(ib<<12)+core[2172]] = 04017; npc = (ib<<12)+core[2172]+1; code[(ib<<12)+core[2172]] = &emul8; inh = 0;  }
void I04017() { core[(ib<<12)+core[126]] = 04020; npc = (ib<<12)+core[126]+1; code[(ib<<12)+core[126]] = &emul8; inh = 0;  }
void I04020() { core[(ib<<12)+core[84]] = 04021; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I04021() { core[(ib<<12)+core[41]] = 04022; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I04022() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void I04023() { lac += core[(df<<12)+core[2170]];  }
void I04024() { core[(ib<<12)+core[2169]] = 04025; npc = (ib<<12)+core[2169]+1; code[(ib<<12)+core[2169]] = &emul8; inh = 0;  }
void I04025() { core[(ib<<12)+core[41]] = 04026; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I04026() { emul8();  }
void I04027() { lac += core[(df<<12)+core[2168]];  }
void I04030() { core[(ib<<12)+core[2169]] = 04031; npc = (ib<<12)+core[2169]+1; code[(ib<<12)+core[2169]] = &emul8; inh = 0;  }
void I04031() { core[(ib<<12)+core[84]] = 04032; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I04032() { core[(ib<<12)+core[2167]] = 04033; npc = (ib<<12)+core[2167]+1; code[(ib<<12)+core[2167]] = &emul8; inh = 0;  }
void I04033() { core[(ib<<12)+core[41]] = 04034; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I04034() { emul8();  }
void I04035() { lac += core[(df<<12)+core[2166]];  }
void I04036() { core[(ib<<12)+core[2169]] = 04037; npc = (ib<<12)+core[2169]+1; code[(ib<<12)+core[2169]] = &emul8; inh = 0;  }
void I04037() { core[(ib<<12)+core[41]] = 04040; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I04040() { emul8();  }
void I04041() { lac += core[(df<<12)+core[2165]];  }
void I04042() { core[(ib<<12)+core[2169]] = 04043; npc = (ib<<12)+core[2169]+1; code[(ib<<12)+core[2169]] = &emul8; inh = 0;  }
void I04043() { core[(ib<<12)+core[84]] = 04044; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I04044() { core[(ib<<12)+core[2164]] = 04045; npc = (ib<<12)+core[2164]+1; code[(ib<<12)+core[2164]] = &emul8; inh = 0;  }
void I04045() { core[(ib<<12)+core[45]] = 04046; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I04046() { lac += core[(df<<12)+core[2163]];  }
void I04047() { core[(ib<<12)+core[2169]] = 04050; npc = (ib<<12)+core[2169]+1; code[(ib<<12)+core[2169]] = &emul8; inh = 0;  }
void I04050() { core[(ib<<12)+core[84]] = 04051; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I04051() { core[(ib<<12)+core[2162]] = 04052; npc = (ib<<12)+core[2162]+1; code[(ib<<12)+core[2162]] = &emul8; inh = 0;  }
void I04052() { core[(ib<<12)+core[41]] = 04053; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I04053() { emul8();  }
void I04054() { lac += core[(df<<12)+core[2161]];  }
void I04055() { core[(ib<<12)+core[2169]] = 04056; npc = (ib<<12)+core[2169]+1; code[(ib<<12)+core[2169]] = &emul8; inh = 0;  }
void I04056() { core[(ib<<12)+core[84]] = 04057; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I04057() { npc = (ib<<12)+core[2048]; inh = 0;  }
void I04060() { lac &= (010000|core[000000]);  }
void I04061() { emul8();  }
void I04062() { emul8();  }
void I04063() { emul8();  }
void I04064() { emul8();  }
void I04065() { emul8();  }
void I04066() { emul8();  }
void I04067() { emul8();  }
void I04070() { emul8();  }
void I04071() { emul8();  }
void I04072() { emul8();  }
void I04073() { emul8();  }
void I04074() { emul8();  }
void I04075() { emul8();  }
void I04076() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I04077() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void P04100() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04101() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void D04102() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void P04103() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void P04104() { lac &= 010000;  }
void P04105() {  }
void P04106() {  }
void P04107() { emul8();  }
void I04110() { core[000000] = 04111; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I04111() { lac &= (010000|core[000000]);  }
void I04112() { lac &= (010000|core[000000]);  }
void I04113() { lac &= (010000|core[000000]);  }
void I04114() { lac &= (010000|core[000000]);  }
void I04115() { lac &= (010000|core[000000]);  }
void I04116() { lac &= (010000|core[000000]);  }
void I04117() { lac &= (010000|core[000000]);  }
void I04120() { lac &= (010000|core[000000]);  }
void I04121() { lac &= (010000|core[000000]);  }
void I04122() { lac &= (010000|core[000000]);  }
void D04123() { lac &= (010000|core[000000]);  }
void I04124() { lac &= (010000|core[000000]);  }
void I04125() { lac &= (010000|core[000000]);  }
void S04126() { lac &= (010000|core[000000]);  }
void I04127() { core[004132] = 04130; npc = 004132+1; code[004132] = &emul8; inh = 0;  }
void I04130() { core[004143] = 04131; npc = 004143+1; code[004143] = &emul8; inh = 0;  }
void I04131() { npc = (ib<<12)+core[2134]; inh = 0;  }
void S04132() { lac &= (010000|core[000000]);  }
void I04133() { lac &= 010000; lac ^= 07777;  }
void I04134() { lac &= (010000|core[(df<<12)+core[2160]]);  }
void I04135() { core[(ib<<12)+core[86]] = 04136; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I04136() { lac += core[(df<<12)+core[2159]];  }
void I04137() { core[(ib<<12)+core[86]] = 04140; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I04140() { lac += core[(df<<12)+core[2158]];  }
void I04141() { core[(ib<<12)+core[86]] = 04142; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I04142() { npc = (ib<<12)+core[2138]; inh = 0;  }
void S04143() { lac &= (010000|core[000000]);  }
void I04144() { lac &= 010000; lac ^= 07777;  }
void I04145() { lac &= (010000|core[(df<<12)+core[2157]]);  }
void I04146() { core[(ib<<12)+core[86]] = 04147; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I04147() { npc = (ib<<12)+core[2147]; inh = 0;  }
void P04155() { npc = (ib<<12)+core[63]; inh = 0;  }
void P04156() { npc = (ib<<12)+core[62]; inh = 0;  }
void P04157() { npc = (ib<<12)+core[61]; inh = 0;  }
void P04160() { npc = (ib<<12)+core[60]; inh = 0;  }
void P04161() { core[(df<<12)+core[2112]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2112]] = &emul8;  }
void P04162() { npc = (ib<<12)+core[28]; inh = 0;  }
void P04163() { core[(df<<12)+core[2115]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2115]] = &emul8;  }
void P04164() { npc = (ib<<12)+core[24]; inh = 0;  }
void P04165() { core[(df<<12)+core[2118]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2118]] = &emul8;  }
void P04166() { core[(df<<12)+core[2119]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2119]] = &emul8;  }
void P04167() { npc = (ib<<12)+core[21]; inh = 0;  }
void P04170() { core[(df<<12)+core[2117]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2117]] = &emul8;  }
void P04171() { lac &= 010000;  }
void P04172() { core[(df<<12)+core[2116]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2116]] = &emul8;  }
void P04173() { lac &= (010000|core[004102]);  }
void P04174() { npc = (ib<<12)+core[55]; inh = 0;  }
void P04175() { lac &= (010000|core[004123]);  }
void P04176() { npc = (ib<<12)+core[50]; inh = 0;  }
void P04177() { npc = (ib<<12)+core[45]; inh = 0;  }
void L04200() { npc = 004261; inh = 0;  }
void L04201() { core[004273] = 04202; npc = 004273+1; code[004273] = &emul8; inh = 0;  }
void L04202() { lac &= 010000; lac ^= 07777;  }
void I04203() { lac &= (010000|core[(df<<12)+core[2254]]);  }
void I04204() { emul8();  }
void I04205() { lac &= 010000; lac ^= 07777;  }
void I04206() { lac &= (010000|core[(df<<12)+core[2255]]);  }
void I04207() { emul8();  }
void I04210() { core[(df<<12)+core[2261]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2261]] = &emul8;  }
void I04211() { emul8();  }
void I04212() { core[(df<<12)+core[2262]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2262]] = &emul8;  }
void I04213() { emul8();  }
void I04214() { core[(df<<12)+core[2263]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2263]] = &emul8;  }
void I04215() { lac &= 010000; lac ^= 07777;  }
void D04216() { lac &= (010000|core[(df<<12)+core[2261]]);  }
void I04217() { lac &= 07777; lac ^= 07777;  }
void I04220() { lac += core[(df<<12)+core[2254]];  }
void I04221() { lac ^= 07777;  }
void I04222() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04223() { npc = 004333; inh = 0;  }
void I04224() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04225() { npc = 004333; inh = 0;  }
void I04226() { lac &= 010000; lac ^= 07777;  }
void I04227() { lac &= (010000|core[(df<<12)+core[2262]]);  }
void I04230() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04231() { npc = 004333; inh = 0;  }
void I04232() { lac &= 010000; lac ^= 07777;  }
void I04233() { lac &= (010000|core[(df<<12)+core[2263]]);  }
void I04234() { lac &= 07777; lac ^= 07777;  }
void I04235() { lac += core[004331];  }
void I04236() { lac ^= 07777;  }
void I04237() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04240() { npc = 004333; inh = 0;  }
void I04241() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04242() { npc = 004333; inh = 0;  }
void I04243() { if (++core[004315] == 010000) { core[004315] = 0; npc++; }; code[004315] = &emul8;  }
void I04244() { npc = 004202; inh = 0;  }
void I04245() { lac &= 010000; lac |= swr;  }
void I04246() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I04247() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04250() { npc = 004202; inh = 0;  }
void I04251() { if (++core[004322] == 010000) { core[004322] = 0; npc++; }; code[004322] = &emul8;  }
void L04252() { npc = 004201; inh = 0;  }
void I04253() { lac &= 010000; lac |= swr;  }
void I04254() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I04255() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04256() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04257() { npc = 004200; inh = 0;  }
void I04260() { npc = (ib<<12)+core[2260]; inh = 0;  }
void L04261() { lac &= 010000;  }
void I04262() { core[004315] = lac & 07777; lac &= 010000; code[004315] = &emul8;  }
void I04263() {  }
void I04264() { lac ^= 07777;  }
void I04265() { lac &= (010000|core[004323]);  }
void I04266() { core[004322] = lac & 07777; lac &= 010000; code[004322] = &emul8;  }
void D04267() { lac += core[004331];  }
void I04270() { core[(df<<12)+core[2264]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2264]] = &emul8;  }
void I04271() { core[(ib<<12)+core[93]] = 04272; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void D04272() { npc = 004201; inh = 0;  }
void S04273() { lac &= (010000|core[000000]);  }
void I04274() { lac &= 010000; lac ^= 07777;  }
void I04275() { lac &= (010000|core[004322]);  }
void I04276() { lac ^= 07777;  }
void I04277() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void P04300() { npc = 004302; inh = 0;  }
void I04301() { npc = 004307; inh = 0;  }
void L04302() { lac &= 010000; lac ^= 07777;  }
void P04303() { lac &= (010000|core[004320]);  }
void P04304() { core[(df<<12)+core[2254]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2254]] = &emul8;  }
void P04305() { core[(df<<12)+core[2255]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2255]] = &emul8;  }
void P04306() { npc = (ib<<12)+core[2235]; inh = 0;  }
void P04307() { lac &= 010000; lac ^= 07777;  }
void I04310() { lac &= (010000|core[004321]);  }
void I04311() { core[(df<<12)+core[2254]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2254]] = &emul8;  }
void I04312() { lac ^= 07777;  }
void I04313() { core[(df<<12)+core[2255]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2255]] = &emul8;  }
void I04314() { npc = (ib<<12)+core[2235]; inh = 0;  }
void D04315() { lac &= (010000|core[000000]);  }
void P04316() { core[(df<<12)+core[2245]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2245]] = &emul8;  }
void P04317() { core[(df<<12)+core[2244]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2244]] = &emul8;  }
void D04320() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void D04321() { npc = 004252; inh = 0;  }
void D04322() { lac &= (010000|core[000000]);  }
void D04323() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P04324() { core[(ib<<12)+core[0]] = 04325; npc = (ib<<12)+core[0]+1; code[(ib<<12)+core[0]] = &emul8; inh = 0;  }
void P04325() { core[(df<<12)+core[2247]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2247]] = &emul8;  }
void P04326() { core[(df<<12)+core[2246]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2246]] = &emul8;  }
void P04327() { core[(df<<12)+core[2240]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2240]] = &emul8;  }
void P04330() { core[(df<<12)+core[2243]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2243]] = &emul8;  }
void D04331() { lac &= (010000|core[000014]);  }
void P04332() { core[000000] = 04333; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void L04333() { core[(ib<<12)+core[101]] = 04334; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I04334() { core[(ib<<12)+core[2266]] = 04335; npc = (ib<<12)+core[2266]+1; code[(ib<<12)+core[2266]] = &emul8; inh = 0;  }
void I04335() { core[(ib<<12)+core[99]] = 04336; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I04336() { hlt = 1;  }
void I04337() { core[(ib<<12)+core[100]] = 04340; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I04340() { skp = 0; skp = !skp; npc += skp; lac &= 010000;  }
void I04341() { npc = 004202; inh = 0;  }
void I04342() { core[004315] = lac & 07777; lac &= 010000; code[004315] = &emul8;  }
void I04343() { npc = 004202; inh = 0;  }
void P04400() { npc = 004505; inh = 0;  }
void L04401() { core[004453] = 04402; npc = 004453+1; code[004453] = &emul8; inh = 0;  }
void L04402() { emul8();  }
void I04403() { lac ^= 07777;  }
void I04404() { lac &= (010000|core[(df<<12)+core[2389]]);  }
void I04405() { emul8();  }
void I04406() { lac &= 07777; lac ^= 07777;  }
void I04407() { lac &= (010000|core[(df<<12)+core[2390]]);  }
void I04410() { emul8();  }
void I04411() { core[(df<<12)+core[2391]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2391]] = &emul8;  }
void I04412() { emul8();  }
void I04413() { core[(df<<12)+core[2392]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2392]] = &emul8;  }
void I04414() { emul8();  }
void I04415() { core[(df<<12)+core[2396]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2396]] = &emul8;  }
void I04416() { lac ^= 07777;  }
void I04417() { lac &= (010000|core[(df<<12)+core[2391]]);  }
void I04420() { lac ^= 07777;  }
void I04421() { lac += core[004531];  }
void I04422() { lac ^= 07777;  }
void I04423() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04424() { npc = 004513; inh = 0;  }
void I04425() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04426() { npc = 004513; inh = 0;  }
void I04427() { lac ^= 07777;  }
void I04430() { lac &= (010000|core[(df<<12)+core[2392]]);  }
void I04431() { lac ^= 07777;  }
void I04432() { lac += core[004532];  }
void I04433() { lac ^= 07777;  }
void I04434() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04435() { npc = 004513; inh = 0;  }
void I04436() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04437() { npc = 004513; inh = 0;  }
void I04440() { lac ^= 07777;  }
void I04441() { lac &= (010000|core[(df<<12)+core[2396]]);  }
void I04442() { lac ^= 07777; lac++;  }
void I04443() { lac += core[(df<<12)+core[2395]];  }
void I04444() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04445() { npc = 004513; inh = 0;  }
void I04446() { if (++core[004536] == 010000) { core[004536] = 0; npc++; }; code[004536] = &emul8;  }
void I04447() { npc = 004402; inh = 0;  }
void L04450() { core[(ib<<12)+core[100]] = 04451; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I04451() { npc = 004402; inh = 0;  }
void I04452() { npc = 004545; inh = 0;  }
void S04453() { lac &= (010000|core[000000]);  }
void I04454() { lac &= 010000; lac ^= 07777;  }
void I04455() { lac &= (010000|core[004537]);  }
void I04456() { lac ^= 07777;  }
void I04457() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04460() { npc = 004462; inh = 0;  }
void I04461() { npc = 004471; inh = 0;  }
void L04462() { lac &= 010000;  }
void I04463() { core[(df<<12)+core[2390]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2390]] = &emul8;  }
void I04464() { core[(df<<12)+core[2389]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2389]] = &emul8;  }
void I04465() { core[004531] = lac & 07777; lac &= 010000; code[004531] = &emul8;  }
void I04466() { core[004532] = lac & 07777; lac &= 010000; code[004532] = &emul8;  }
void I04467() { core[(df<<12)+core[2395]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2395]] = &emul8;  }
void I04470() { npc = (ib<<12)+core[2347]; inh = 0;  }
void L04471() { lac &= 010000; lac ^= 07777;  }
void I04472() { lac &= (010000|core[004535]);  }
void I04473() { core[(df<<12)+core[2389]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2389]] = &emul8;  }
void I04474() { lac ^= 07777;  }
void I04475() { lac &= (010000|core[004540]);  }
void I04476() { core[(df<<12)+core[2395]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2395]] = &emul8;  }
void I04477() { core[(df<<12)+core[2390]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2390]] = &emul8;  }
void P04500() { core[004532] = lac & 07777; lac &= 010000; code[004532] = &emul8;  }
void I04501() { lac ^= 07777;  }
void I04502() { lac &= (010000|core[004541]);  }
void P04503() { core[004531] = lac & 07777; lac &= 010000; code[004531] = &emul8;  }
void P04504() { npc = (ib<<12)+core[2347]; inh = 0;  }
void P04505() { lac &= 010000; lac ^= 07777;  }
void P04506() { lac &= (010000|core[004542]);  }
void P04507() { core[004537] = lac & 07777; lac &= 010000; code[004537] = &emul8;  }
void I04510() { core[004536] = lac & 07777; lac &= 010000; code[004536] = &emul8;  }
void I04511() { core[(ib<<12)+core[93]] = 04512; npc = (ib<<12)+core[93]+1; code[(ib<<12)+core[93]] = &emul8; inh = 0;  }
void I04512() { npc = 004401; inh = 0;  }
void L04513() { core[(ib<<12)+core[101]] = 04514; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I04514() { core[(ib<<12)+core[2403]] = 04515; npc = (ib<<12)+core[2403]+1; code[(ib<<12)+core[2403]] = &emul8; inh = 0;  }
void I04515() { lac &= 010000; lac |= swr;  }
void I04516() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I04517() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04520() { hlt = 1;  }
void I04521() { npc = 004450; inh = 0;  }
void L04522() { core[(ib<<12)+core[102]] = 04523; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I04523() { npc = 004400; inh = 0;  }
void I04524() { npc = (ib<<12)+core[2404]; inh = 0;  }
void P04525() { core[(df<<12)+core[2373]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2373]] = &emul8;  }
void P04526() { core[(df<<12)+core[2372]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2372]] = &emul8;  }
void P04527() { core[(df<<12)+core[2375]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2375]] = &emul8;  }
void P04530() { core[(df<<12)+core[2374]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2374]] = &emul8;  }
void D04531() { lac &= (010000|core[000000]);  }
void D04532() { lac &= (010000|core[000000]);  }
void P04533() { core[(df<<12)+core[2371]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2371]] = &emul8;  }
void P04534() { core[(df<<12)+core[2368]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2368]] = &emul8;  }
void D04535() { lac &= (010000|core[000001]);  }
void D04536() { lac &= (010000|core[000000]);  }
void D04537() { lac &= (010000|core[000000]);  }
void D04540() { lac &= (010000|core[000026]);  }
void D04541() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void D04542() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P04543() { core[000000] = 04544; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void P04544() { core[(ib<<12)+core[2304]] = 04545; npc = (ib<<12)+core[2304]+1; code[(ib<<12)+core[2304]] = &emul8; inh = 0;  }
void L04545() { if (++core[004537] == 010000) { core[004537] = 0; npc++; }; code[004537] = &emul8;  }
void I04546() { npc = 004401; inh = 0;  }
void I04547() { npc = 004522; inh = 0;  }
void L04600() { lac &= 010000; lac ^= 07777;  }
void I04601() { emul8();  }
void I04602() { emul8();  }
void I04603() { emul8();  }
void I04604() { skp = 0; skp = !skp; npc += skp;  }
void I04605() { hlt = 1;  }
void I04606() { lac ^= 07777;  }
void I04607() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I04610() { hlt = 1;  }
void I04611() { emul8();  }
void I04612() { lac ^= 07777;  }
void I04613() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04614() { hlt = 1;  }
void I04615() { lac &= 010000; lac ^= 07777;  }
void I04616() { emul8();  }
void I04617() { emul8();  }
void I04620() { emul8();  }
void I04621() { skp = 0; skp = !skp; npc += skp;  }
void I04622() { hlt = 1;  }
void I04623() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I04624() { hlt = 1;  }
void I04625() { emul8();  }
void I04626() { lac ^= 07777;  }
void I04627() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04630() { hlt = 1;  }
void I04631() { lac &= 010000; lac ^= 07777;  }
void I04632() { emul8();  }
void I04633() { emul8();  }
void I04634() { emul8();  }
void I04635() { emul8();  }
void I04636() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04637() { hlt = 1;  }
void I04640() { lac &= 010000;  }
void I04641() { lac += core[000172];  }
void I04642() { emul8();  }
void I04643() { lac += core[000171];  }
void I04644() { emul8();  }
void I04645() { lac += core[000171];  }
void I04646() { lac ^= 07777;  }
void I04647() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04650() { hlt = 1;  }
void I04651() { emul8();  }
void L04652() { lac += core[000172];  }
void I04653() { lac ^= 07777;  }
void I04654() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04655() { hlt = 1;  }
void I04656() { emul8();  }
void I04657() { lac += core[000171];  }
void I04660() { emul8();  }
void L04661() { lac += core[000172];  }
void I04662() { emul8();  }
void I04663() { lac += core[000172];  }
void I04664() { lac ^= 07777;  }
void I04665() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04666() { hlt = 1;  }
void I04667() { emul8();  }
void I04670() { lac += core[000115];  }
void I04671() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04672() { npc = 004753; inh = 0;  }
void I04673() { emul8();  }
void I04674() { emul8();  }
void I04675() { lac += core[000171];  }
void I04676() { emul8();  }
void I04677() { lac += core[000172];  }
void I04700() { emul8();  }
void I04701() { core[(ib<<12)+core[2499]] = 04702; npc = (ib<<12)+core[2499]+1; code[(ib<<12)+core[2499]] = &emul8; inh = 0;  }
void I04702() { npc = 004705; inh = 0;  }
void P04703() { npc = 004652; inh = 0;  }
void I04704() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void L04705() { lac += core[000172];  }
void I04706() { lac ^= 07777;  }
void I04707() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04710() { hlt = 1;  }
void I04711() { emul8();  }
void I04712() { lac += core[000171];  }
void I04713() { lac ^= 07777;  }
void I04714() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04715() { hlt = 1;  }
void I04716() { emul8();  }
void I04717() { emul8();  }
void I04720() { lac += core[000171];  }
void I04721() { emul8();  }
void I04722() { emul8();  }
void I04723() { core[004732] = lac & 07777; lac &= 010000; code[004732] = &emul8;  }
void I04724() { lac += core[000172];  }
void I04725() { core[004733] = lac & 07777; lac &= 010000; code[004733] = &emul8;  }
void I04726() { lac += core[000172];  }
void I04727() { emul8();  }
void I04730() { core[(ib<<12)+core[2522]] = 04731; npc = (ib<<12)+core[2522]+1; code[(ib<<12)+core[2522]] = &emul8; inh = 0;  }
void I04731() { npc = 004734; inh = 0;  }
void P04732() { lac &= (010000|core[000000]);  }
void D04733() { lac &= (010000|core[000000]);  }
void L04734() { emul8();  }
void I04735() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04736() { hlt = 1;  }
void I04737() { lac += core[004732];  }
void I04740() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04741() { hlt = 1;  }
void I04742() { lac += core[004733];  }
void I04743() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04744() { hlt = 1;  }
void I04745() { emul8();  }
void I04746() { emul8();  }
void I04747() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04750() { emul8();  }
void I04751() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04752() { hlt = 1;  }
void L04753() { emul8();  }
void I04754() { core[(ib<<12)+core[102]] = 04755; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I04755() { npc = 004600; inh = 0;  }
void I04756() { if (++core[000117] == 010000) { core[000117] = 0; npc++; }; code[000117] = &emul8;  }
void I04757() { npc = 004600; inh = 0;  }
void I04760() { npc = (ib<<12)+core[2559]; inh = 0;  }
void P04777() { npc = 004661; inh = 0;  }
void L05000() { lac &= (010000|core[000000]);  }
void L05001() { emul8();  }
void I05002() { emul8();  }
void I05003() { skp = 0; skp = !skp; npc += skp;  }
void I05004() { hlt = 1;  }
void I05005() { emul8();  }
void I05006() { emul8();  }
void I05007() { emul8();  }
void I05010() { hlt = 1;  }
void I05011() { emul8();  }
void I05012() { emul8();  }
void I05013() { emul8();  }
void I05014() { skp = 0; skp = !skp; npc += skp;  }
void I05015() { hlt = 1;  }
void I05016() { emul8();  }
void I05017() { emul8();  }
void I05020() { emul8();  }
void I05021() { emul8();  }
void I05022() { skp = 0; skp = !skp; npc += skp; lac &= 010000;  }
void I05023() { hlt = 1;  }
void I05024() { lac &= 010000;  }
void I05025() { emul8();  }
void I05026() { emul8();  }
void I05027() { emul8();  }
void I05030() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05031() { hlt = 1;  }
void I05032() { emul8();  }
void D05033() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I05034() { emul8();  }
void I05035() { lac += core[005033];  }
void I05036() { lac ^= 07777;  }
void I05037() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05040() { hlt = 1;  }
void I05041() { emul8();  }
void D05042() { emul8();  }
void I05043() { emul8();  }
void I05044() { lac += core[005042];  }
void I05045() { lac ^= 07777;  }
void I05046() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05047() { hlt = 1;  }
void I05050() { emul8();  }
void D05051() { emul8();  }
void I05052() { emul8();  }
void I05053() { lac += core[005051];  }
void I05054() { lac ^= 07777;  }
void I05055() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05056() { hlt = 1;  }
void I05057() { emul8();  }
void D05060() { emul8();  }
void I05061() { emul8();  }
void I05062() { lac += core[005060];  }
void I05063() { lac ^= 07777;  }
void I05064() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05065() { hlt = 1;  }
void I05066() { emul8();  }
void D05067() { emul8();  }
void I05070() { emul8();  }
void I05071() { lac += core[005067];  }
void I05072() { lac ^= 07777;  }
void I05073() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05074() { hlt = 1;  }
void I05075() { emul8();  }
void D05076() { emul8();  }
void I05077() { emul8();  }
void I05100() { lac += core[005076];  }
void I05101() { lac ^= 07777;  }
void I05102() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05103() { hlt = 1;  }
void I05104() { emul8();  }
void D05105() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void I05106() { emul8();  }
void I05107() { lac += core[005105];  }
void I05110() { lac ^= 07777;  }
void I05111() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05112() { hlt = 1;  }
void I05113() { emul8();  }
void I05114() { lac &= (010000|core[000077]);  }
void I05115() { emul8();  }
void I05116() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05117() { hlt = 1;  }
void I05120() { emul8();  }
void I05121() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I05122() { emul8();  }
void I05123() { lac += core[000123];  }
void I05124() { lac ^= 07777;  }
void I05125() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05126() { hlt = 1;  }
void I05127() { emul8();  }
void I05130() { emul8();  }
void I05131() { lac &= 010000; lac ^= 07777;  }
void I05132() { emul8();  }
void I05133() { lac ^= 07777;  }
void I05134() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05135() { hlt = 1;  }
void I05136() { emul8();  }
void D05137() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void I05140() { lac &= 010000;  }
void I05141() { lac += core[005137];  }
void I05142() { emul8();  }
void I05143() { lac ^= 07777;  }
void I05144() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05145() { hlt = 1;  }
void I05146() { emul8();  }
void D05147() { emul8();  }
void I05150() { lac &= 010000;  }
void I05151() { lac += core[005147];  }
void I05152() { emul8();  }
void I05153() { lac ^= 07777;  }
void I05154() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05155() { hlt = 1;  }
void I05156() { emul8();  }
void I05157() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I05160() { emul8();  }
void I05161() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I05162() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05163() { hlt = 1;  }
void I05164() { emul8();  }
void I05165() { lac += core[000123];  }
void I05166() { lac ^= 07777;  }
void I05167() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05170() { hlt = 1;  }
void I05171() { npc = (ib<<12)+core[2687]; inh = 0;  }
void P05177() { npc = 005000; inh = 0;  }
void L05200() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I05201() { lac += core[000123];  }
void D05202() { emul8();  }
void I05203() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void D05204() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05205() { hlt = 1;  }
void I05206() { emul8();  }
void I05207() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05210() { hlt = 1;  }
void I05211() { emul8();  }
void I05212() { lac &= 010000; lac &= 07777;  }
void I05213() { core[(ib<<12)+core[108]] = 05214; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I05214() { emul8();  }
void I05215() { lac &= (010000|core[005377]);  }
void I05216() { lac = (lac<<2) + ((lac>>11)&3);  }
void I05217() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I05220() { hlt = 1;  }
void I05221() { emul8();  }
void I05222() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I05223() { core[(ib<<12)+core[108]] = 05224; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I05224() { emul8();  }
void I05225() { lac &= (010000|core[005377]);  }
void I05226() { lac = (lac<<2) + ((lac>>11)&3);  }
void D05227() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I05230() { hlt = 1;  }
void I05231() { emul8();  }
void D05232() { lac &= 010000; lac &= 07777;  }
void I05233() { core[(ib<<12)+core[108]] = 05234; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I05234() { emul8();  }
void I05235() { skp = 0; skp = !skp; npc += skp;  }
void I05236() { hlt = 1;  }
void I05237() { emul8();  }
void I05240() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I05241() { core[(ib<<12)+core[108]] = 05242; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I05242() { emul8();  }
void I05243() { hlt = 1;  }
void I05244() { emul8();  }
void I05245() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I05246() { core[(ib<<12)+core[108]] = 05247; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I05247() { emul8();  }
void I05250() { emul8();  }
void I05251() { skp = 0; skp = !skp; npc += skp; lac &= 010000;  }
void I05252() { hlt = 1;  }
void I05253() { core[(ib<<12)+core[102]] = 05254; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I05254() { npc = (ib<<12)+core[2814]; inh = 0;  }
void I05255() { if (++core[000117] == 010000) { core[000117] = 0; npc++; }; code[000117] = &emul8;  }
void I05256() { npc = (ib<<12)+core[2814]; inh = 0;  }
void I05257() { emul8();  }
void I05260() { npc = (ib<<12)+core[2813]; inh = 0;  }
void L05261() { core[(ib<<12)+core[84]] = 05262; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I05262() { lac += core[000115];  }
void I05263() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05264() { npc = 005267; inh = 0;  }
void I05265() { core[(ib<<12)+core[40]] = 05266; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I05266() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; hlt = 1;  }
void L05267() { lac += core[000115];  }
void I05270() { lac &= 07777; lac ^= 07777;  }
void I05271() { core[000115] = lac & 07777; lac &= 010000; code[000115] = &emul8;  }
void I05272() { emul8();  }
void I05273() { npc = (ib<<12)+core[2812]; inh = 0;  }
void S05274() { lac &= (010000|core[000000]);  }
void I05275() { lac &= 010000; lac |= swr;  }
void I05276() { lac &= 07777; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I05277() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I05300() { npc = 005311; inh = 0;  }
void L05301() { lac &= 010000;  }
void D05302() { lac += core[000115];  }
void I05303() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05304() { npc = 005307; inh = 0;  }
void I05305() { emul8();  }
void I05306() { npc = (ib<<12)+core[2748]; inh = 0;  }
void L05307() { emul8();  }
void I05310() { npc = (ib<<12)+core[2748]; inh = 0;  }
void L05311() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05312() { npc = 005315; inh = 0;  }
void L05313() { core[000115] = lac & 07777; lac &= 010000; code[000115] = &emul8;  }
void I05314() { npc = 005301; inh = 0;  }
void L05315() { lac &= 07777; lac ^= 07777;  }
void I05316() { npc = 005313; inh = 0;  }
void S05317() { lac &= (010000|core[000000]);  }
void I05320() { lac &= 010000;  }
void I05321() { lac += core[000115];  }
void I05322() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I05323() { npc = (ib<<12)+core[125]; inh = 0;  }
void I05324() { npc = (ib<<12)+core[2767]; inh = 0;  }
void S05325() { lac &= (010000|core[000000]);  }
void I05326() { lac &= 010000; lac |= swr;  }
void I05327() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05330() { npc = (ib<<12)+core[2773]; inh = 0;  }
void I05331() { if (++core[005325] == 010000) { core[005325] = 0; npc++; }; code[005325] = &emul8;  }
void I05332() { npc = (ib<<12)+core[2773]; inh = 0;  }
void S05333() { lac &= (010000|core[000000]);  }
void I05334() { lac &= 010000; lac |= swr;  }
void I05335() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05336() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05337() { npc = (ib<<12)+core[2779]; inh = 0;  }
void I05340() { if (++core[005333] == 010000) { core[005333] = 0; npc++; }; code[005333] = &emul8;  }
void I05341() { npc = (ib<<12)+core[2779]; inh = 0;  }
void S05342() { lac &= (010000|core[000000]);  }
void I05343() { lac &= 010000; lac |= swr;  }
void I05344() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I05345() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05346() { npc = (ib<<12)+core[2786]; inh = 0;  }
void I05347() { if (++core[005342] == 010000) { core[005342] = 0; npc++; }; code[005342] = &emul8;  }
void I05350() { npc = (ib<<12)+core[2786]; inh = 0;  }
void P05374() { lac &= (010000|core[005202]);  }
void P05375() { lac &= (010000|core[005204]);  }
void P05376() { npc = 000001; inh = 0;  }
void D05377() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void S05400() { lac &= (010000|core[000000]);  }
void I05401() { lac &= 010000; lac |= swr;  }
void I05402() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I05403() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I05404() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05405() { npc = (ib<<12)+core[2816]; inh = 0;  }
void I05406() { if (++core[005400] == 010000) { core[005400] = 0; npc++; }; code[005400] = &emul8;  }
void I05407() { npc = (ib<<12)+core[2816]; inh = 0;  }
void S05410() { lac &= (010000|core[000000]);  }
void I05411() { core[000034] = lac & 07777; lac &= 010000; code[000034] = &emul8;  }
void I05412() { emul8();  }
void I05413() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void I05414() { lac &= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I05415() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I05416() { emul8();  }
void I05417() { core[000036] = lac & 07777; lac &= 010000; code[000036] = &emul8;  }
void I05420() { emul8();  }
void I05421() { lac &= (010000|core[005577]);  }
void I05422() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I05423() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I05424() { npc = (ib<<12)+core[2824]; inh = 0;  }
void S05425() { lac &= (010000|core[000000]);  }
void I05426() { core[(ib<<12)+core[2942]] = 05427; npc = (ib<<12)+core[2942]+1; code[(ib<<12)+core[2942]] = &emul8; inh = 0;  }
void I05427() { npc = (ib<<12)+core[2837]; inh = 0;  }
void S05430() { lac &= (010000|core[000000]);  }
void I05431() { core[005437] = 05432; npc = 005437+1; code[005437] = &emul8; inh = 0;  }
void I05432() { core[005450] = 05433; npc = 005450+1; code[005450] = &emul8; inh = 0;  }
void I05433() { npc = (ib<<12)+core[2840]; inh = 0;  }
void S05434() { lac &= (010000|core[000000]);  }
void I05435() { core[005437] = 05436; npc = 005437+1; code[005437] = &emul8; inh = 0;  }
void I05436() { npc = (ib<<12)+core[2844]; inh = 0;  }
void S05437() { lac &= (010000|core[000000]);  }
void I05440() { lac &= 010000; lac ^= 07777;  }
void I05441() { lac &= (010000|core[005500]);  }
void I05442() { core[(ib<<12)+core[86]] = 05443; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05443() { lac += core[005501];  }
void I05444() { core[(ib<<12)+core[86]] = 05445; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05445() { lac += core[005502];  }
void I05446() { core[(ib<<12)+core[86]] = 05447; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05447() { npc = (ib<<12)+core[2847]; inh = 0;  }
void S05450() { lac &= (010000|core[000000]);  }
void D05451() { lac &= 010000; lac ^= 07777;  }
void I05452() { lac &= (010000|core[005477]);  }
void I05453() { core[(ib<<12)+core[86]] = 05454; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05454() { npc = (ib<<12)+core[2856]; inh = 0;  }
void S05455() { lac &= (010000|core[000000]);  }
void I05456() { lac &= 010000;  }
void I05457() { lac += core[000077];  }
void I05460() { core[(ib<<12)+core[86]] = 05461; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05461() { npc = (ib<<12)+core[2861]; inh = 0;  }
void S05462() { lac &= (010000|core[000000]);  }
void I05463() { lac &= 010000;  }
void I05464() { lac += core[005575];  }
void I05465() { core[(ib<<12)+core[86]] = 05466; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05466() { npc = (ib<<12)+core[2866]; inh = 0;  }
void S05467() { lac &= (010000|core[000000]);  }
void I05470() { lac &= 010000;  }
void I05471() { lac += core[005574];  }
void I05472() { core[(ib<<12)+core[86]] = 05473; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05473() { npc = (ib<<12)+core[2871]; inh = 0;  }
void D05474() { lac &= (010000|core[005516]);  }
void D05475() { lac &= (010000|core[005515]);  }
void D05476() { lac &= (010000|core[005511]);  }
void D05477() { lac &= (010000|core[005524]);  }
void D05500() { lac &= (010000|core[005523]);  }
void D05501() { lac &= (010000|core[005503]);  }
void D05502() { lac &= (010000|core[005501]);  }
void S05503() { lac &= (010000|core[000000]);  }
void I05504() { lac += core[000115];  }
void I05505() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05506() { npc = 005515; inh = 0;  }
void I05507() { lac += core[000024];  }
void I05510() { lac ^= 07777;  }
void D05511() { core[005513] = lac & 07777; lac &= 010000; code[005513] = &emul8;  }
void I05512() { emul8();  }
void D05513() { lac &= (010000|core[000000]);  }
void I05514() { npc = (ib<<12)+core[2883]; inh = 0;  }
void L05515() { lac += core[000024];  }
void D05516() { emul8();  }
void I05517() { npc = (ib<<12)+core[2883]; inh = 0;  }
void S05520() { lac &= (010000|core[000000]);  }
void I05521() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I05522() { core[000120] = lac & 07777; lac &= 010000; code[000120] = &emul8;  }
void D05523() { core[(ib<<12)+core[108]] = 05524; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void D05524() { lac += core[000170];  }
void I05525() { core[(df<<12)+core[2939]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2939]] = &emul8;  }
void I05526() { lac += core[000167];  }
void I05527() { core[(df<<12)+core[2938]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2938]] = &emul8;  }
void I05530() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I05531() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I05532() { core[(df<<12)+core[2937]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2937]] = &emul8;  }
void I05533() { core[(df<<12)+core[2936]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2936]] = &emul8;  }
void I05534() { core[(ib<<12)+core[43]] = 05535; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I05535() { lac &= (010000|core[000021]);  }
void I05536() { lac &= (010000|core[000022]);  }
void I05537() { emul8();  }
void I05540() { npc = (ib<<12)+core[2896]; inh = 0;  }
void S05541() { lac &= (010000|core[000000]);  }
void I05542() { core[(ib<<12)+core[85]] = 05543; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I05543() { core[(ib<<12)+core[40]] = 05544; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void D05544() { lac &= (010000|core[000000]);  }
void I05545() { npc = (ib<<12)+core[2913]; inh = 0;  }
void S05546() { lac &= (010000|core[000000]);  }
void I05547() { if (++core[000065] == 010000) { core[000065] = 0; npc++; }; code[000065] = &emul8;  }
void I05550() { npc = (ib<<12)+core[2918]; inh = 0;  }
void L05551() { lac &= 010000; lac |= swr;  }
void I05552() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I05553() { lac = (lac<<2) + ((lac>>11)&3);  }
void I05554() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05555() { npc = (ib<<12)+core[46]; inh = 0;  }
void I05556() { npc = (ib<<12)+core[47]; inh = 0;  }
void P05570() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void P05571() { lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void P05572() { emul8();  }
void P05573() { emul8();  }
void D05574() { lac &= (010000|core[005451]);  }
void D05575() { lac &= (010000|core[005450]);  }
void P05576() { core[000132] = 05577; npc = 000132+1; code[000132] = &emul8; inh = 0;  }
void D05577() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void S05600() { lac &= (010000|core[000000]);  }
void I05601() { lac &= 010000; lac ^= 07777;  }
void I05602() { lac &= (010000|core[000070]);  }
void I05603() { core[(ib<<12)+core[86]] = 05604; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05604() { lac += core[000071];  }
void I05605() { core[(ib<<12)+core[86]] = 05606; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05606() { npc = (ib<<12)+core[2944]; inh = 0;  }
void S05607() { lac &= (010000|core[000000]);  }
void I05610() { core[(ib<<12)+core[84]] = 05611; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I05611() { core[(ib<<12)+core[84]] = 05612; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I05612() { npc = (ib<<12)+core[2951]; inh = 0;  }
void S05613() { lac &= (010000|core[000000]);  }
void I05614() { core[005636] = lac & 07777; lac &= 010000; code[005636] = &emul8;  }
void I05615() { lac += core[000020];  }
void I05616() { lac ^= 07777;  }
void I05617() { core[005637] = lac & 07777; lac &= 010000; code[005637] = &emul8;  }
void I05620() { lac += core[005636];  }
void I05621() { emul8();  }
void L05622() { emul8();  }
void I05623() { npc = 005622; inh = 0;  }
void I05624() { lac += core[000166];  }
void I05625() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05626() { npc = (ib<<12)+core[2955]; inh = 0;  }
void L05627() { if (++core[005637] == 010000) { core[005637] = 0; npc++; }; code[005637] = &emul8;  }
void I05630() { skp = 0; skp = !skp; npc += skp; lac &= 010000;  }
void I05631() { npc = (ib<<12)+core[2955]; inh = 0;  }
void I05632() { emul8();  }
void L05633() { emul8();  }
void I05634() { npc = 005633; inh = 0;  }
void I05635() { npc = 005627; inh = 0;  }
void D05636() { lac &= (010000|core[000000]);  }
void D05637() { lac &= (010000|core[000000]);  }
void S05640() { lac &= (010000|core[000000]);  }
void I05641() { lac &= 010000; lac ^= 07777;  }
void I05642() { lac &= (010000|core[000102]);  }
void I05643() { core[005645] = 05644; npc = 005645+1; code[005645] = &emul8; inh = 0;  }
void I05644() { npc = (ib<<12)+core[2976]; inh = 0;  }
void S05645() { lac &= (010000|core[000000]);  }
void I05646() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05647() { npc = 005652; inh = 0;  }
void I05650() { core[005656] = 05651; npc = 005656+1; code[005656] = &emul8; inh = 0;  }
void I05651() { npc = (ib<<12)+core[2981]; inh = 0;  }
void L05652() { lac &= 010000; lac ^= 07777;  }
void D05653() { lac &= (010000|core[000100]);  }
void I05654() { core[(ib<<12)+core[86]] = 05655; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05655() { npc = (ib<<12)+core[2981]; inh = 0;  }
void S05656() { lac &= (010000|core[000000]);  }
void I05657() { lac &= 010000; lac ^= 07777;  }
void I05660() { lac &= (010000|core[000101]);  }
void I05661() { core[(ib<<12)+core[86]] = 05662; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05662() { npc = (ib<<12)+core[2990]; inh = 0;  }
void S05663() { lac &= (010000|core[000000]);  }
void I05664() { lac &= 010000; lac ^= 07777;  }
void I05665() { lac &= (010000|core[000104]);  }
void I05666() { core[000105] = lac & 07777; lac &= 010000; code[000105] = &emul8;  }
void L05667() { if (++core[000105] == 010000) { core[000105] = 0; npc++; }; code[000105] = &emul8;  }
void I05670() { skp = 0; skp = !skp; npc += skp;  }
void I05671() { npc = (ib<<12)+core[2995]; inh = 0;  }
void I05672() { lac &= 010000; lac ^= 07777;  }
void D05673() { lac &= (010000|core[000106]);  }
void I05674() { lac &= 07777;  }
void I05675() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05676() { core[000106] = lac & 07777; lac &= 010000; code[000106] = &emul8;  }
void I05677() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I05700() { npc = 005703; inh = 0;  }
void I05701() { core[005656] = 05702; npc = 005656+1; code[005656] = &emul8; inh = 0;  }
void I05702() { npc = 005667; inh = 0;  }
void L05703() { lac &= 010000; lac ^= 07777;  }
void I05704() { lac &= (010000|core[000100]);  }
void I05705() { core[(ib<<12)+core[86]] = 05706; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I05706() { npc = 005667; inh = 0;  }
void S05707() { lac &= (010000|core[000000]);  }
void I05710() { core[(ib<<12)+core[85]] = 05711; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I05711() { lac += core[(df<<12)+core[3015]];  }
void I05712() { core[000116] = lac & 07777; lac &= 010000; code[000116] = &emul8;  }
void L05713() { if (++core[005707] == 010000) { core[005707] = 0; npc++; }; code[005707] = &emul8;  }
void I05714() { lac += core[(df<<12)+core[3015]];  }
void I05715() { core[005717] = lac & 07777; lac &= 010000; code[005717] = &emul8;  }
void I05716() { core[(ib<<12)+core[40]] = 05717; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void D05717() { lac &= (010000|core[000000]);  }
void I05720() { core[(ib<<12)+core[45]] = 05721; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I05721() { if (++core[000116] == 010000) { core[000116] = 0; npc++; }; code[000116] = &emul8;  }
void I05722() { npc = 005713; inh = 0;  }
void I05723() { core[(ib<<12)+core[44]] = 05724; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I05724() { if (++core[005707] == 010000) { core[005707] = 0; npc++; }; code[005707] = &emul8;  }
void I05725() { npc = (ib<<12)+core[3015]; inh = 0;  }
void S05726() { lac &= (010000|core[000000]);  }
void I05727() { core[000102] = lac & 07777; lac &= 010000; code[000102] = &emul8;  }
void I05730() { core[(ib<<12)+core[87]] = 05731; npc = (ib<<12)+core[87]+1; code[(ib<<12)+core[87]] = &emul8; inh = 0;  }
void I05731() { npc = (ib<<12)+core[3030]; inh = 0;  }
void S05732() { lac &= (010000|core[000000]);  }
void I05733() { core[(ib<<12)+core[104]] = 05734; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void I05734() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void I05735() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I05736() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I05737() { core[(ib<<12)+core[104]] = 05740; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void I05740() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I05741() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I05742() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I05743() { core[(ib<<12)+core[104]] = 05744; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void I05744() { lac &= (010000|core[000165]);  }
void I05745() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I05746() { core[(ib<<12)+core[123]] = 05747; npc = (ib<<12)+core[123]+1; code[(ib<<12)+core[123]] = &emul8; inh = 0;  }
void I05747() { npc = (ib<<12)+core[3034]; inh = 0;  }
void I05750() { npc = (ib<<12)+core[125]; inh = 0;  }
void S05751() { lac &= (010000|core[000000]);  }
void I05752() { lac &= 010000; lac &= 07777;  }
void I05753() { lac += core[000023];  }
void I05754() { emul8();  }
void I05755() { core[(ib<<12)+core[107]] = 05756; npc = (ib<<12)+core[107]+1; code[(ib<<12)+core[107]] = &emul8; inh = 0;  }
void I05756() { lac += core[000021];  }
void I05757() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I05760() { npc = (ib<<12)+core[3049]; inh = 0;  }
void S05761() { lac &= (010000|core[000000]);  }
void I05762() { lac &= 010000;  }
void I05763() { lac += core[000025];  }
void I05764() { lac &= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I05765() { core[(ib<<12)+core[108]] = 05766; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I05766() { npc = (ib<<12)+core[3057]; inh = 0;  }
void S05767() { lac &= (010000|core[000000]);  }
void I05770() { if (++core[000114] == 010000) { core[000114] = 0; npc++; }; code[000114] = &emul8;  }
void I05771() { npc = (ib<<12)+core[3063]; inh = 0;  }
void I05772() { if (++core[000120] == 010000) { core[000120] = 0; npc++; }; code[000120] = &emul8;  }
void I05773() { npc = (ib<<12)+core[3063]; inh = 0;  }
void I05774() { if (++core[005767] == 010000) { core[005767] = 0; npc++; }; code[005767] = &emul8;  }
void I05775() { npc = (ib<<12)+core[3063]; inh = 0;  }
void S06000() { lac &= (010000|core[000000]);  }
void I06001() { core[000116] = lac & 07777; lac &= 010000; code[000116] = &emul8;  }
void I06002() { emul8();  }
void I06003() { lac &= 07777; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I06004() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06005() { emul8();  }
void I06006() { lac += core[000116];  }
void I06007() { emul8();  }
void I06010() { emul8();  }
void I06011() { lac &= 010000; lac &= 07777;  }
void I06012() { npc = (ib<<12)+core[3072]; inh = 0;  }
void S06013() { lac &= (010000|core[000000]);  }
void I06014() { lac += core[000022];  }
void I06015() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I06016() { lac &= 07777; lac ^= 010000;  }
void I06017() { lac ^= 07777; lac++;  }
void I06020() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I06021() { lac += core[000023];  }
void I06022() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06023() { lac ^= 010000;  }
void I06024() { lac += core[000040];  }
void I06025() { lac &= 010000; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06026() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06027() { lac += core[000022];  }
void I06030() { lac ^= 07777; lac++;  }
void I06031() { lac += core[000023];  }
void I06032() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06033() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06034() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I06035() { lac += core[000023];  }
void I06036() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06037() { lac += core[000024];  }
void I06040() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06041() { npc = (ib<<12)+core[3083]; inh = 0;  }
void S06042() { lac &= (010000|core[000000]);  }
void I06043() { lac += core[000024];  }
void I06044() { lac += core[000115];  }
void I06045() { lac &= 07777; lac ^= 07777;  }
void I06046() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06047() { lac += core[000022];  }
void I06050() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06051() { lac += core[000023];  }
void I06052() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06053() { lac += core[000025];  }
void I06054() { lac &= (010000|core[000115]);  }
void I06055() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06056() { lac += core[000045];  }
void I06057() { lac += core[006177];  }
void I06060() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06061() { npc = 006107; inh = 0;  }
void I06062() { lac += core[000045];  }
void I06063() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06064() { npc = 006113; inh = 0;  }
void I06065() { lac += core[000044];  }
void I06066() { emul8();  }
void I06067() { lac += core[000043];  }
void L06070() { emul8();  }
void I06071() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I06072() { emul8();  }
void I06073() { lac = (lac<<1) + ((lac>>12)&1);  }
void L06074() { if (++core[000045] == 010000) { core[000045] = 0; npc++; }; code[000045] = &emul8;  }
void I06075() { npc = 006070; inh = 0;  }
void I06076() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06077() { emul8();  }
void I06100() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06101() { lac &= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06102() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I06103() { lac += core[000115];  }
void I06104() { lac &= (010000|core[000165]);  }
void I06105() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06106() { npc = (ib<<12)+core[3106]; inh = 0;  }
void L06107() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I06110() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06111() { emul8();  }
void I06112() { npc = 006074; inh = 0;  }
void L06113() { lac += core[000021];  }
void I06114() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I06115() { lac += core[000165];  }
void I06116() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06117() { npc = (ib<<12)+core[3106]; inh = 0;  }
void S06120() { lac &= (010000|core[000000]);  }
void I06121() { lac += core[000024];  }
void I06122() { lac += core[000115];  }
void I06123() { lac &= 07777; lac ^= 07777;  }
void I06124() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06125() { lac += core[000045];  }
void I06126() { lac += core[000164];  }
void I06127() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06130() { npc = 006167; inh = 0;  }
void I06131() { lac += core[000022];  }
void I06132() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06133() { lac += core[000023];  }
void I06134() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06135() { lac += core[000045];  }
void I06136() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06137() { npc = 006164; inh = 0;  }
void I06140() { lac += core[000044];  }
void I06141() { emul8();  }
void I06142() { lac += core[000043];  }
void L06143() { lac &= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06144() { emul8();  }
void I06145() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06146() { emul8();  }
void L06147() { if (++core[000045] == 010000) { core[000045] = 0; npc++; }; code[000045] = &emul8;  }
void I06150() { npc = 006143; inh = 0;  }
void I06151() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06152() { emul8();  }
void I06153() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06154() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I06155() { lac &= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06156() { lac &= (010000|core[000115]);  }
void I06157() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void L06160() { lac += core[000165];  }
void I06161() { lac &= (010000|core[000115]);  }
void I06162() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06163() { npc = (ib<<12)+core[3152]; inh = 0;  }
void L06164() { lac += core[000025];  }
void I06165() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06166() { npc = 006160; inh = 0;  }
void L06167() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I06170() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06171() { emul8();  }
void I06172() { npc = 006147; inh = 0;  }
void D06177() { lac &= (010000|core[000032]);  }
void S06200() { lac &= (010000|core[000000]);  }
void I06201() { lac += core[000024];  }
void I06202() { lac += core[000115];  }
void I06203() { lac &= 07777; lac ^= 07777;  }
void I06204() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06205() { lac += core[000022];  }
void I06206() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06207() { lac += core[000023];  }
void I06210() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06211() { lac += core[000045];  }
void I06212() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06213() { npc = 006251; inh = 0;  }
void I06214() { lac += core[000045];  }
void I06215() { lac += core[000164];  }
void I06216() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06217() { npc = 006257; inh = 0;  }
void I06220() { lac += core[000044];  }
void I06221() { emul8();  }
void I06222() { lac += core[000043];  }
void L06223() { lac &= 07777;  }
void I06224() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06225() { lac ^= 010000;  }
void I06226() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06227() { emul8();  }
void I06230() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06231() { emul8();  }
void I06232() { if (++core[000045] == 010000) { core[000045] = 0; npc++; }; code[000045] = &emul8;  }
void I06233() { npc = 006223; inh = 0;  }
void I06234() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06235() { emul8();  }
void I06236() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void L06237() { lac &= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06240() { lac &= (010000|core[000115]);  }
void I06241() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06242() { lac += core[000043];  }
void I06243() { lac &= (010000|core[000163]);  }
void I06244() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void L06245() { lac += core[000165];  }
void I06246() { lac &= (010000|core[000115]);  }
void I06247() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06250() { npc = (ib<<12)+core[3200]; inh = 0;  }
void L06251() { lac += core[000022];  }
void I06252() { lac &= (010000|core[000163]);  }
void I06253() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I06254() { lac += core[000025];  }
void I06255() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06256() { npc = 006245; inh = 0;  }
void L06257() { lac += core[000043];  }
void I06260() { lac &= (010000|core[000163]);  }
void I06261() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I06262() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I06263() { npc = 006271; inh = 0;  }
void I06264() { lac ^= 07777;  }
void I06265() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06266() { lac ^= 07777;  }
void L06267() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06270() { npc = 006237; inh = 0;  }
void L06271() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06272() { npc = 006267; inh = 0;  }
void S06273() { lac &= (010000|core[000000]);  }
void I06274() { lac += core[000023];  }
void I06275() { lac &= 07777; lac++;  }
void I06276() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06277() { lac = (lac<<1) + ((lac>>12)&1);  }
void I06300() { lac += core[000022];  }
void I06301() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06302() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06303() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I06304() { lac += core[000025];  }
void I06305() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06306() { lac += core[000024];  }
void I06307() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06310() { npc = (ib<<12)+core[3259]; inh = 0;  }
void S06311() { lac &= (010000|core[000000]);  }
void I06312() { lac += core[000023];  }
void I06313() { lac ^= 07777; lac++;  }
void I06314() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06315() { lac += core[000022];  }
void I06316() { lac ^= 07777;  }
void I06317() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06320() { lac = (lac<<1) + ((lac>>12)&1);  }
void I06321() { lac += core[000043];  }
void I06322() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06323() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06324() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I06325() { lac += core[000025];  }
void I06326() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06327() { lac += core[000024];  }
void I06330() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06331() { npc = (ib<<12)+core[3273]; inh = 0;  }
void S06332() { lac &= (010000|core[000000]);  }
void I06333() { lac += core[000023];  }
void I06334() { lac += core[000025];  }
void I06335() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06336() { lac &= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I06337() { lac += core[000022];  }
void I06340() { lac += core[000024];  }
void I06341() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06342() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06343() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I06344() { npc = (ib<<12)+core[3290]; inh = 0;  }
void S06345() { lac &= (010000|core[000000]);  }
void I06346() { lac += core[(df<<12)+core[3301]];  }
void I06347() { core[006374] = lac & 07777; lac &= 010000; code[006374] = &emul8;  }
void I06350() { if (++core[006345] == 010000) { core[006345] = 0; npc++; }; code[006345] = &emul8;  }
void I06351() { lac += core[006370];  }
void I06352() { core[006372] = lac & 07777; lac &= 010000; code[006372] = &emul8;  }
void I06353() { lac += core[006371];  }
void I06354() { core[006373] = lac & 07777; lac &= 010000; code[006373] = &emul8;  }
void L06355() { lac += core[(df<<12)+core[3322]];  }
void I06356() { lac ^= 07777; lac++;  }
void I06357() { lac += core[(df<<12)+core[3323]];  }
void I06360() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06361() { npc = (ib<<12)+core[3301]; inh = 0;  }
void I06362() { if (++core[006372] == 010000) { core[006372] = 0; npc++; }; code[006372] = &emul8;  }
void I06363() { if (++core[006373] == 010000) { core[006373] = 0; npc++; }; code[006373] = &emul8;  }
void I06364() { if (++core[006374] == 010000) { core[006374] = 0; npc++; }; code[006374] = &emul8;  }
void I06365() { npc = 006355; inh = 0;  }
void I06366() { if (++core[006345] == 010000) { core[006345] = 0; npc++; }; code[006345] = &emul8;  }
void I06367() { npc = (ib<<12)+core[3301]; inh = 0;  }
void D06370() { lac &= (010000|core[000000]);  }
void D06371() { lac &= (010000|core[000000]);  }
void P06372() { lac &= (010000|core[000000]);  }
void P06373() { lac &= (010000|core[000000]);  }
void D06374() { lac &= (010000|core[000000]);  }
void S06400() { lac &= (010000|core[000000]);  }
void I06401() { lac &= 010000;  }
void I06402() { lac += core[(df<<12)+core[3328]];  }
void I06403() { core[006423] = lac & 07777; lac &= 010000; code[006423] = &emul8;  }
void I06404() { if (++core[006400] == 010000) { core[006400] = 0; npc++; }; code[006400] = &emul8;  }
void I06405() { lac += core[(df<<12)+core[3328]];  }
void I06406() { core[006424] = lac & 07777; lac &= 010000; code[006424] = &emul8;  }
void I06407() { if (++core[006400] == 010000) { core[006400] = 0; npc++; }; code[006400] = &emul8;  }
void D06410() { lac += core[(df<<12)+core[3328]];  }
void I06411() { core[006425] = lac & 07777; lac &= 010000; code[006425] = &emul8;  }
void I06412() { if (++core[006400] == 010000) { core[006400] = 0; npc++; }; code[006400] = &emul8;  }
void L06413() { lac &= 010000;  }
void I06414() { lac += core[(df<<12)+core[3347]];  }
void I06415() { core[(df<<12)+core[3348]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3348]] = &emul8;  }
void I06416() { if (++core[006423] == 010000) { core[006423] = 0; npc++; }; code[006423] = &emul8;  }
void I06417() { if (++core[006424] == 010000) { core[006424] = 0; npc++; }; code[006424] = &emul8;  }
void I06420() { if (++core[006425] == 010000) { core[006425] = 0; npc++; }; code[006425] = &emul8;  }
void I06421() { npc = 006413; inh = 0;  }
void D06422() { npc = (ib<<12)+core[3328]; inh = 0;  }
void P06423() { lac &= (010000|core[000000]);  }
void P06424() { lac &= (010000|core[000000]);  }
void D06425() { lac &= (010000|core[000000]);  }
void S06426() { lac &= (010000|core[000000]);  }
void I06427() { lac += core[006577];  }
void I06430() { core[006471] = lac & 07777; lac &= 010000; code[006471] = &emul8;  }
void I06431() { lac += core[006462];  }
void I06432() { core[006443] = lac & 07777; lac &= 010000; code[006443] = &emul8;  }
void I06433() { lac += core[(df<<12)+core[3350]];  }
void I06434() { if (++core[006426] == 010000) { core[006426] = 0; npc++; }; code[006426] = &emul8;  }
void I06435() { core[006470] = lac & 07777; lac &= 010000; code[006470] = &emul8;  }
void I06436() { lac += core[(df<<12)+core[3384]];  }
void I06437() { core[006467] = lac & 07777; lac &= 010000; code[006467] = &emul8;  }
void L06440() { core[006470] = lac & 07777; lac &= 010000; code[006470] = &emul8;  }
void L06441() { lac &= 07777;  }
void I06442() { lac += core[006467];  }
void D06443() { lac += core[006463];  }
void I06444() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I06445() { npc = 006451; inh = 0;  }
void I06446() { if (++core[006470] == 010000) { core[006470] = 0; npc++; }; code[006470] = &emul8;  }
void I06447() { core[006467] = lac & 07777; lac &= 010000; code[006467] = &emul8;  }
void I06450() { npc = 006441; inh = 0;  }
void L06451() { lac &= 010000;  }
void I06452() { lac += core[006470];  }
void I06453() { lac += core[006472];  }
void I06454() { core[(ib<<12)+core[86]] = 06455; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I06455() { lac &= 010000; lac &= 07777;  }
void I06456() { if (++core[006443] == 010000) { core[006443] = 0; npc++; }; code[006443] = &emul8;  }
void I06457() { if (++core[006471] == 010000) { core[006471] = 0; npc++; }; code[006471] = &emul8;  }
void D06460() { npc = 006440; inh = 0;  }
void I06461() { npc = (ib<<12)+core[3350]; inh = 0;  }
void D06462() { lac += core[006463];  }
void D06463() { emul8();  }
void I06464() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I06465() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I06466() { emul8();  }
void D06467() { lac &= (010000|core[000000]);  }
void P06470() { lac &= (010000|core[000000]);  }
void D06471() { lac &= (010000|core[000000]);  }
void D06472() { lac &= (010000|core[006460]);  }
void S06473() { lac &= (010000|core[000000]);  }
void I06474() { lac &= 07777; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I06475() { emul8();  }
void I06476() { emul8();  }
void I06477() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I06500() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06501() { lac &= (010000|core[006576]);  }
void I06502() { emul8();  }
void I06503() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I06504() { lac = (lac<<1) + ((lac>>12)&1);  }
void I06505() { lac &= (010000|core[006575]);  }
void I06506() { emul8();  }
void P06507() { emul8();  }
void I06510() { emul8();  }
void I06511() { lac &= (010000|core[006574]);  }
void I06512() { core[006524] = lac & 07777; lac &= 010000; code[006524] = &emul8;  }
void I06513() { emul8();  }
void I06514() { lac &= (010000|core[006573]);  }
void I06515() { lac &= 07777; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I06516() { emul8();  }
void I06517() { lac &= (010000|core[006572]);  }
void I06520() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I06521() { lac += core[006524];  }
void I06522() { emul8();  }
void I06523() { npc = (ib<<12)+core[3387]; inh = 0;  }
void D06524() { lac &= (010000|core[000000]);  }
void S06525() { lac &= (010000|core[000000]);  }
void I06526() { lac &= 010000;  }
void I06527() { lac += core[006570];  }
void I06530() { lac += core[006555];  }
void I06531() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06532() { npc = 006542; inh = 0;  }
void I06533() { lac += core[006557];  }
void I06534() { core[006555] = lac & 07777; lac &= 010000; code[006555] = &emul8;  }
void I06535() { lac += core[006556];  }
void I06536() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I06537() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I06540() { lac++;  }
void I06541() { core[006556] = lac & 07777; lac &= 010000; code[006556] = &emul8;  }
void L06542() { lac += core[006556];  }
void I06543() { lac += core[(df<<12)+core[3437]];  }
void I06544() { core[(df<<12)+core[3437]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3437]] = &emul8;  }
void I06545() { lac += core[006571];  }
void I06546() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06547() { lac += core[(df<<12)+core[3437]];  }
void I06550() { if (++core[006555] == 010000) { core[006555] = 0; npc++; }; code[006555] = &emul8;  }
void I06551() {  }
void I06552() { core[006571] = lac & 07777; lac &= 010000; code[006571] = &emul8;  }
void I06553() { lac += core[006571];  }
void I06554() { npc = (ib<<12)+core[3413]; inh = 0;  }
void P06555() { emul8();  }
void D06556() { emul8();  }
void D06557() { emul8();  }
void I06560() { emul8();  }
void I06561() { core[006410] = lac & 07777; lac &= 010000; code[006410] = &emul8;  }
void I06562() { lac &= (010000|core[(df<<12)+core[3445]]);  }
void I06563() { npc = (ib<<12)+core[26]; inh = 0;  }
void I06564() { if (++core[000107] == 010000) { core[000107] = 0; npc++; }; code[000107] = &emul8;  }
void P06565() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I06566() { core[006521] = 06567; npc = 006521+1; code[006521] = &emul8; inh = 0;  }
void I06567() { lac &= (010000|core[000176]);  }
void D06570() { lac += core[006410];  }
void D06571() { lac &= (010000|core[000000]);  }
void D06572() { lac += core[000111];  }
void D06573() { core[(ib<<12)+core[36]] = 06574; npc = (ib<<12)+core[36]+1; code[(ib<<12)+core[36]] = &emul8; inh = 0;  }
void D06574() { if (++core[006422] == 010000) { core[006422] = 0; npc++; }; code[006422] = &emul8;  }
void D06575() { lac ^= 010000; lac ^= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void D06576() { lac &= (010000|core[(df<<12)+core[3399]]);  }
void D06577() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void S06600() { lac &= (010000|core[000000]);  }
void I06601() { lac &= 010000;  }
void I06602() { lac += core[(df<<12)+core[3456]];  }
void I06603() { core[006663] = lac & 07777; lac &= 010000; code[006663] = &emul8;  }
void I06604() { core[006665] = lac & 07777; lac &= 010000; code[006665] = &emul8;  }
void I06605() { if (++core[006600] == 010000) { core[006600] = 0; npc++; }; code[006600] = &emul8;  }
void L06606() { lac += core[(df<<12)+core[3507]];  }
void I06607() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I06610() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I06611() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I06612() { core[006617] = 06613; npc = 006617+1; code[006617] = &emul8; inh = 0;  }
void I06613() { lac += core[(df<<12)+core[3507]];  }
void I06614() { core[006617] = 06615; npc = 006617+1; code[006617] = &emul8; inh = 0;  }
void I06615() { if (++core[006663] == 010000) { core[006663] = 0; npc++; }; code[006663] = &emul8;  }
void I06616() { npc = 006606; inh = 0;  }
void S06617() { lac &= (010000|core[000000]);  }
void I06620() { lac &= (010000|core[006777]);  }
void I06621() { core[006664] = lac & 07777; lac &= 010000; code[006664] = &emul8;  }
void I06622() { lac += core[006665];  }
void I06623() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06624() { npc = 006634; inh = 0;  }
void I06625() { lac += core[006664];  }
void I06626() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06627() { npc = 006632; inh = 0;  }
void L06630() { core[006653] = 06631; npc = 006653+1; code[006653] = &emul8; inh = 0;  }
void I06631() { npc = (ib<<12)+core[3471]; inh = 0;  }
void L06632() { if (++core[006665] == 010000) { core[006665] = 0; npc++; }; code[006665] = &emul8;  }
void I06633() { npc = (ib<<12)+core[3471]; inh = 0;  }
void L06634() { core[006665] = lac & 07777; lac &= 010000; code[006665] = &emul8;  }
void I06635() { lac += core[006664];  }
void I06636() { lac ^= 07777; lac++;  }
void I06637() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void D06640() { npc = 006630; inh = 0;  }
void I06641() { lac++;  }
void I06642() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06643() { npc = (ib<<12)+core[3456]; inh = 0;  }
void I06644() { lac += core[006666];  }
void I06645() { core[006655] = lac & 07777; lac &= 010000; code[006655] = &emul8;  }
void I06646() { lac += core[006664];  }
void I06647() { core[006653] = 06650; npc = 006653+1; code[006653] = &emul8; inh = 0;  }
void I06650() { lac += core[006667];  }
void I06651() { core[006655] = lac & 07777; lac &= 010000; code[006655] = &emul8;  }
void I06652() { npc = (ib<<12)+core[3471]; inh = 0;  }
void S06653() { lac &= (010000|core[000000]);  }
void I06654() { lac += core[006776];  }
void D06655() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06656() { lac += core[006775];  }
void I06657() { lac += core[006774];  }
void I06660() { core[(ib<<12)+core[86]] = 06661; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I06661() { npc = (ib<<12)+core[3499]; inh = 0;  }
void I06662() { lac &= (010000|core[000000]);  }
void P06663() { lac &= (010000|core[000000]);  }
void D06664() { lac &= (010000|core[000000]);  }
void D06665() { lac &= (010000|core[000000]);  }
void D06666() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void D06667() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void S06670() { lac &= (010000|core[000000]);  }
void I06671() { lac += core[(df<<12)+core[3512]];  }
void I06672() { core[006703] = lac & 07777; lac &= 010000; code[006703] = &emul8;  }
void I06673() { if (++core[006670] == 010000) { core[006670] = 0; npc++; }; code[006670] = &emul8;  }
void L06674() { core[(ib<<12)+core[40]] = 06675; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I06675() { emul8();  }
void I06676() { if (++core[006703] == 010000) { core[006703] = 0; npc++; }; code[006703] = &emul8;  }
void I06677() { npc = 006674; inh = 0;  }
void I06700() { npc = (ib<<12)+core[3512]; inh = 0;  }
void I06701() { core[000000] = 06702; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I06702() { lac &= (010000|core[000100]);  }
void D06703() { lac &= (010000|core[000000]);  }
void S06704() { lac &= (010000|core[000000]);  }
void I06705() { lac &= 010000; lac &= 07777;  }
void I06706() { lac += core[000115];  }
void I06707() { lac ^= 07777;  }
void I06710() { lac += core[006773];  }
void I06711() { core[006721] = lac & 07777; lac &= 010000; code[006721] = &emul8;  }
void I06712() { core[(ib<<12)+core[41]] = 06713; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I06713() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I06714() { core[(ib<<12)+core[40]] = 06715; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I06715() { emul8();  }
void I06716() { npc = (ib<<12)+core[3524]; inh = 0;  }
void I06717() { lac += core[(df<<12)+core[79]];  }
void I06720() { lac &= (010000|core[(df<<12)+core[5]]);  }
void D06721() { lac &= (010000|core[000000]);  }
void I06722() { lac &= (010000|core[000001]);  }
void S06723() { lac &= (010000|core[000000]);  }
void I06724() { core[(ib<<12)+core[41]] = 06725; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I06725() { emul8();  }
void I06726() { npc = (ib<<12)+core[3539]; inh = 0;  }
void S06727() { lac &= (010000|core[000000]);  }
void I06730() { core[(ib<<12)+core[41]] = 06731; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I06731() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I06732() { npc = (ib<<12)+core[3543]; inh = 0;  }
void S06733() { lac &= (010000|core[000000]);  }
void I06734() { core[(ib<<12)+core[85]] = 06735; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I06735() { core[(ib<<12)+core[41]] = 06736; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I06736() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void I06737() { core[(ib<<12)+core[40]] = 06740; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I06740() { emul8();  }
void I06741() { core[(ib<<12)+core[41]] = 06742; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I06742() { emul8();  }
void I06743() { core[(ib<<12)+core[40]] = 06744; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I06744() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I06745() { core[(ib<<12)+core[41]] = 06746; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I06746() { emul8();  }
void I06747() { core[(ib<<12)+core[40]] = 06750; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I06750() { emul8();  }
void I06751() { core[(ib<<12)+core[41]] = 06752; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I06752() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I06753() { core[(ib<<12)+core[40]] = 06754; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I06754() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac |= swr; hlt = 1;  }
void I06755() { core[(ib<<12)+core[41]] = 06756; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I06756() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void I06757() { core[(ib<<12)+core[40]] = 06760; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I06760() { emul8();  }
void I06761() { npc = (ib<<12)+core[3547]; inh = 0;  }
void D06773() { core[000002] = 06774; npc = 000002+1; code[000002] = &emul8; inh = 0;  }
void D06774() { lac &= (010000|core[006640]);  }
void D06775() { lac &= (010000|core[000100]);  }
void D06776() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D06777() { lac &= (010000|core[000077]);  }
void S07000() { lac &= (010000|core[000000]);  }
void I07001() { core[(ib<<12)+core[126]] = 07002; npc = (ib<<12)+core[126]+1; code[(ib<<12)+core[126]] = &emul8; inh = 0;  }
void D07002() { lac &= (010000|core[000000]);  }
void I07003() { core[(ib<<12)+core[3711]] = 07004; npc = (ib<<12)+core[3711]+1; code[(ib<<12)+core[3711]] = &emul8; inh = 0;  }
void I07004() { core[(ib<<12)+core[85]] = 07005; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I07005() { core[(ib<<12)+core[43]] = 07006; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I07006() { lac &= (010000|core[000021]);  }
void I07007() { lac &= (010000|core[000026]);  }
void I07010() { emul8();  }
void I07011() { core[(ib<<12)+core[40]] = 07012; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07012() { skp = 0; skp = !skp; npc += skp; hlt = 1;  }
void I07013() { core[(ib<<12)+core[41]] = 07014; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07014() { emul8();  }
void I07015() { core[007046] = 07016; npc = 007046+1; code[007046] = &emul8; inh = 0;  }
void D07016() { lac &= (010000|core[000000]);  }
void I07017() { core[(ib<<12)+core[85]] = 07020; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I07020() { core[(ib<<12)+core[40]] = 07021; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07021() { emul8();  }
void I07022() { core[(ib<<12)+core[41]] = 07023; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07023() { emul8();  }
void I07024() { core[(ib<<12)+core[43]] = 07025; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I07025() { lac &= (010000|core[000042]);  }
void I07026() { lac &= (010000|core[000026]);  }
void I07027() { emul8();  }
void I07030() { core[007046] = 07031; npc = 007046+1; code[007046] = &emul8; inh = 0;  }
void I07031() { core[(ib<<12)+core[85]] = 07032; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I07032() { core[(ib<<12)+core[40]] = 07033; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07033() { emul8();  }
void I07034() { core[(ib<<12)+core[41]] = 07035; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07035() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07036() { core[(ib<<12)+core[43]] = 07037; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I07037() { lac &= (010000|core[000033]);  }
void I07040() { lac &= (010000|core[000026]);  }
void I07041() { emul8();  }
void I07042() { core[007046] = 07043; npc = 007046+1; code[007046] = &emul8; inh = 0;  }
void I07043() { npc = (ib<<12)+core[3584]; inh = 0;  }
void D07044() { core[(ib<<12)+core[3710]] = 07045; npc = (ib<<12)+core[3710]+1; code[(ib<<12)+core[3710]] = &emul8; inh = 0;  }
void D07045() { core[(ib<<12)+core[3709]] = 07046; npc = (ib<<12)+core[3709]+1; code[(ib<<12)+core[3709]] = &emul8; inh = 0;  }
void S07046() { lac &= (010000|core[000000]);  }
void I07047() { lac += core[000026];  }
void I07050() { core[(ib<<12)+core[109]] = 07051; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I07051() { core[(ib<<12)+core[45]] = 07052; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I07052() { lac += core[000027];  }
void I07053() { core[(ib<<12)+core[3708]] = 07054; npc = (ib<<12)+core[3708]+1; code[(ib<<12)+core[3708]] = &emul8; inh = 0;  }
void I07054() { core[(ib<<12)+core[45]] = 07055; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I07055() { lac += core[000030];  }
void I07056() { core[(ib<<12)+core[3708]] = 07057; npc = (ib<<12)+core[3708]+1; code[(ib<<12)+core[3708]] = &emul8; inh = 0;  }
void I07057() { core[(ib<<12)+core[41]] = 07060; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07060() { emul8();  }
void I07061() { lac += core[000032];  }
void I07062() { core[(ib<<12)+core[109]] = 07063; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I07063() { core[(ib<<12)+core[41]] = 07064; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07064() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I07065() { lac += core[000031];  }
void I07066() { core[(ib<<12)+core[3708]] = 07067; npc = (ib<<12)+core[3708]+1; code[(ib<<12)+core[3708]] = &emul8; inh = 0;  }
void I07067() { npc = (ib<<12)+core[3622]; inh = 0;  }
void S07070() { lac &= (010000|core[000000]);  }
void I07071() { core[(ib<<12)+core[41]] = 07072; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07072() { emul8();  }
void I07073() { lac += core[000024];  }
void I07074() { lac++;  }
void I07075() { lac += core[000115];  }
void I07076() { core[000116] = lac & 07777; lac &= 010000; code[000116] = &emul8;  }
void I07077() { core[(ib<<12)+core[3707]] = 07100; npc = (ib<<12)+core[3707]+1; code[(ib<<12)+core[3707]] = &emul8; inh = 0;  }
void I07100() { lac &= (010000|core[000116]);  }
void I07101() { core[(ib<<12)+core[45]] = 07102; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I07102() { core[(ib<<12)+core[40]] = 07103; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07103() { emul8();  }
void I07104() { core[(ib<<12)+core[45]] = 07105; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I07105() { npc = (ib<<12)+core[3640]; inh = 0;  }
void S07106() { lac &= (010000|core[000000]);  }
void I07107() { core[(ib<<12)+core[126]] = 07110; npc = (ib<<12)+core[126]+1; code[(ib<<12)+core[126]] = &emul8; inh = 0;  }
void I07110() { core[(ib<<12)+core[3706]] = 07111; npc = (ib<<12)+core[3706]+1; code[(ib<<12)+core[3706]] = &emul8; inh = 0;  }
void I07111() { core[(ib<<12)+core[85]] = 07112; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I07112() { core[(ib<<12)+core[40]] = 07113; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07113() { emul8();  }
void I07114() { core[(ib<<12)+core[41]] = 07115; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07115() { emul8();  }
void I07116() { lac += core[000042];  }
void I07117() { core[(ib<<12)+core[109]] = 07120; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I07120() { core[(ib<<12)+core[41]] = 07121; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07121() { emul8();  }
void I07122() { lac += core[000033];  }
void I07123() { core[(ib<<12)+core[109]] = 07124; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I07124() { core[(ib<<12)+core[84]] = 07125; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I07125() { core[(ib<<12)+core[40]] = 07126; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07126() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I07127() { core[(ib<<12)+core[41]] = 07130; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07130() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I07131() { lac += core[000043];  }
void I07132() { core[(ib<<12)+core[3708]] = 07133; npc = (ib<<12)+core[3708]+1; code[(ib<<12)+core[3708]] = &emul8; inh = 0;  }
void I07133() { core[(ib<<12)+core[41]] = 07134; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07134() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I07135() { lac += core[000034];  }
void I07136() { core[(ib<<12)+core[3708]] = 07137; npc = (ib<<12)+core[3708]+1; code[(ib<<12)+core[3708]] = &emul8; inh = 0;  }
void I07137() { core[(ib<<12)+core[84]] = 07140; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I07140() { core[(ib<<12)+core[40]] = 07141; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07141() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac |= swr;  }
void I07142() { core[(ib<<12)+core[41]] = 07143; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07143() { emul8();  }
void I07144() { lac += core[000036];  }
void I07145() { core[(ib<<12)+core[3708]] = 07146; npc = (ib<<12)+core[3708]+1; code[(ib<<12)+core[3708]] = &emul8; inh = 0;  }
void I07146() { core[(ib<<12)+core[84]] = 07147; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I07147() { core[(ib<<12)+core[40]] = 07150; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07150() { emul8();  }
void I07151() { core[(ib<<12)+core[41]] = 07152; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07152() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I07153() { lac += core[000044];  }
void I07154() { core[(ib<<12)+core[3708]] = 07155; npc = (ib<<12)+core[3708]+1; code[(ib<<12)+core[3708]] = &emul8; inh = 0;  }
void I07155() { core[(ib<<12)+core[41]] = 07156; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07156() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I07157() { lac += core[000035];  }
void I07160() { core[(ib<<12)+core[3708]] = 07161; npc = (ib<<12)+core[3708]+1; code[(ib<<12)+core[3708]] = &emul8; inh = 0;  }
void I07161() { core[(ib<<12)+core[84]] = 07162; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I07162() { core[(ib<<12)+core[40]] = 07163; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07163() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I07164() { core[(ib<<12)+core[41]] = 07165; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07165() { emul8();  }
void I07166() { lac += core[000037];  }
void I07167() { core[(ib<<12)+core[3708]] = 07170; npc = (ib<<12)+core[3708]+1; code[(ib<<12)+core[3708]] = &emul8; inh = 0;  }
void I07170() { npc = (ib<<12)+core[3654]; inh = 0;  }
void P07172() { lac &= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void P07173() { emul8();  }
void P07174() { lac &= 010000;  }
void P07175() { npc = (ib<<12)+core[97]; inh = 0;  }
void P07176() { lac &= 010000; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void P07177() { emul8();  }
void S07200() { lac &= (010000|core[000000]);  }
void I07201() { core[000106] = lac & 07777; lac &= 010000; code[000106] = &emul8;  }
void I07202() { core[(ib<<12)+core[89]] = 07203; npc = (ib<<12)+core[89]+1; code[(ib<<12)+core[89]] = &emul8; inh = 0;  }
void I07203() { npc = (ib<<12)+core[3712]; inh = 0;  }
void S07204() { lac &= (010000|core[000000]);  }
void I07205() { core[(ib<<12)+core[85]] = 07206; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I07206() { core[(ib<<12)+core[44]] = 07207; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I07207() { core[(ib<<12)+core[40]] = 07210; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07210() { emul8();  }
void I07211() { core[(ib<<12)+core[41]] = 07212; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07212() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void I07213() { core[(ib<<12)+core[40]] = 07214; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07214() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac |= swr;  }
void I07215() { core[(ib<<12)+core[44]] = 07216; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I07216() { core[(ib<<12)+core[40]] = 07217; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07217() { emul8();  }
void I07220() { core[(ib<<12)+core[41]] = 07221; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07221() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void I07222() { core[(ib<<12)+core[40]] = 07223; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07223() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I07224() { core[(ib<<12)+core[44]] = 07225; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void I07225() { core[(ib<<12)+core[40]] = 07226; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07226() { emul8();  }
void I07227() { npc = (ib<<12)+core[3716]; inh = 0;  }
void S07230() { lac &= (010000|core[000000]);  }
void I07231() { core[(ib<<12)+core[85]] = 07232; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I07232() { core[(ib<<12)+core[40]] = 07233; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07233() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac |= swr; hlt = 1;  }
void I07234() { core[(ib<<12)+core[41]] = 07235; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07235() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void I07236() { lac += core[000040];  }
void I07237() { core[007200] = 07240; npc = 007200+1; code[007200] = &emul8; inh = 0;  }
void D07240() { core[(ib<<12)+core[45]] = 07241; npc = (ib<<12)+core[45]+1; code[(ib<<12)+core[45]] = &emul8; inh = 0;  }
void I07241() { lac += core[000041];  }
void I07242() { core[007200] = 07243; npc = 007200+1; code[007200] = &emul8; inh = 0;  }
void I07243() { npc = (ib<<12)+core[3736]; inh = 0;  }
void I07244() { lac &= (010000|core[000000]);  }
void I07245() { lac &= (010000|core[000000]);  }
void I07246() { emul8();  }
void I07247() { core[000000] = 07250; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07250() { emul8();  }
void I07251() { lac &= (010000|core[000000]);  }
void L07252() { lac &= (010000|core[000000]);  }
void I07253() { emul8();  }
void I07254() { emul8();  }
void I07255() { lac &= (010000|core[000000]);  }
void I07256() { lac &= (010000|core[000000]);  }
void I07257() { lac &= (010000|core[000000]);  }
void I07260() { lac &= (010000|core[000000]);  }
void I07261() { lac &= (010000|core[000001]);  }
void I07262() { lac &= (010000|core[000002]);  }
void I07263() { lac &= (010000|core[000000]);  }
void I07264() { core[(df<<12)+core[3838]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3838]] = &emul8;  }
void I07265() { core[(df<<12)+core[3839]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3839]] = &emul8;  }
void I07266() { core[000000] = 07267; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07267() { core[(df<<12)+core[3839]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3839]] = &emul8;  }
void I07270() { core[(df<<12)+core[3838]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3838]] = &emul8;  }
void I07271() { core[000000] = 07272; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07272() { core[(ib<<12)+core[3839]] = 07273; npc = (ib<<12)+core[3839]+1; code[(ib<<12)+core[3839]] = &emul8; inh = 0;  }
void I07273() { core[(ib<<12)+core[3838]] = 07274; npc = (ib<<12)+core[3838]+1; code[(ib<<12)+core[3838]] = &emul8; inh = 0;  }
void I07274() { lac &= (010000|core[000000]);  }
void I07275() { core[(ib<<12)+core[3838]] = 07276; npc = (ib<<12)+core[3838]+1; code[(ib<<12)+core[3838]] = &emul8; inh = 0;  }
void I07276() { core[(ib<<12)+core[3839]] = 07277; npc = (ib<<12)+core[3839]+1; code[(ib<<12)+core[3839]] = &emul8; inh = 0;  }
void I07277() { core[000000] = 07300; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void D07300() { emul8();  }
void I07301() { core[(df<<12)+core[3838]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3838]] = &emul8;  }
void I07302() { lac &= (010000|core[000000]);  }
void I07303() { core[(df<<12)+core[3838]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3838]] = &emul8;  }
void I07304() { emul8();  }
void I07305() { lac &= (010000|core[000000]);  }
void I07306() { emul8();  }
void I07307() { emul8();  }
void I07310() { core[000000] = 07311; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07311() { lac &= (010000|core[000000]);  }
void I07312() { lac &= (010000|core[000000]);  }
void I07313() { core[000000] = 07314; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07314() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void I07315() { npc = 007252; inh = 0;  }
void I07316() { lac &= (010000|core[000000]);  }
void I07317() { npc = 007252; inh = 0;  }
void I07320() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void I07321() { lac &= (010000|core[000000]);  }
void I07322() { lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I07323() { lac &= (010000|core[(df<<12)+core[3832]]);  }
void I07324() { core[000000] = 07325; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07325() { lac &= (010000|core[(df<<12)+core[3832]]);  }
void I07326() { lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I07327() { lac &= (010000|core[000000]);  }
void I07330() { lac &= (010000|core[000000]);  }
void I07331() { lac &= (010000|core[000000]);  }
void I07332() { lac &= (010000|core[000000]);  }
void I07333() { lac &= (010000|core[000000]);  }
void I07334() { core[000000] = 07335; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07335() { emul8();  }
void I07336() { emul8();  }
void I07337() { lac &= (010000|core[000000]);  }
void I07340() { lac &= (010000|core[000000]);  }
void I07341() { core[000000] = 07342; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07342() { lac &= (010000|core[000000]);  }
void I07343() { lac &= (010000|core[000000]);  }
void I07344() { emul8();  }
void I07345() { emul8();  }
void I07346() { lac &= (010000|core[000000]);  }
void I07347() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void D07350() { npc = 007252; inh = 0;  }
void I07351() { npc = 007252; inh = 0;  }
void I07352() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void I07353() { core[000000] = 07354; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07354() { npc = 007252; inh = 0;  }
void I07355() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void I07356() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void I07357() { npc = 007252; inh = 0;  }
void I07360() { core[000000] = 07361; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I07361() { lac &= (010000|core[(df<<12)+core[3832]]);  }
void I07362() { lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I07363() { lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I07364() { lac &= (010000|core[(df<<12)+core[3832]]);  }
void I07365() { lac &= (010000|core[000000]);  }
void I07366() { lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I07367() { lac &= (010000|core[(df<<12)+core[3832]]);  }
void P07370() { lac &= (010000|core[(df<<12)+core[3832]]);  }
void I07371() { lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I07372() { lac &= (010000|core[000000]);  }
void I07373() { emul8();  }
void I07374() { emul8();  }
void I07375() { emul8();  }
void P07376() { emul8();  }
void P07377() { lac &= (010000|core[007350]);  }
void D07400() { lac &= (010000|core[000103]);  }
void I07401() { npc = 000100; inh = 0;  }
void I07402() { lac &= (010000|core[000100]);  }
void I07403() { lac &= (010000|core[007550]);  }
void I07404() { lac += core[(df<<12)+core[81]];  }
void D07405() { npc = 000100; inh = 0;  }
void I07406() { lac &= (010000|core[000100]);  }
void I07407() { lac &= (010000|core[007550]);  }
void I07410() { lac += core[(df<<12)+core[41]];  }
void P07411() { lac &= (010000|core[000001]);  }
void I07412() { if (++core[000022] == 010000) { core[000022] = 0; npc++; }; code[000022] = &emul8;  }
void I07413() { lac += core[(df<<12)+core[3906]];  }
void I07414() { lac += core[(df<<12)+core[5]];  }
void I07415() { lac += core[(df<<12)+core[64]];  }
void I07416() { lac &= (010000|core[000100]);  }
void P07417() { if (++core[007511] == 010000) { core[007511] = 0; npc++; }; code[007511] = &emul8;  }
void I07420() { lac += core[(df<<12)+core[85]];  }
void D07421() { lac += core[(df<<12)+core[1]];  }
void I07422() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void I07423() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I07424() { lac &= (010000|core[000100]);  }
void I07425() { lac &= (010000|core[000103]);  }
void I07426() { if (++core[(df<<12)+core[21]] == 010000) { core[(df<<12)+core[21]] = 0; npc++; }; code[(df<<12)+core[21]] = &emul8;  }
void I07427() { lac &= (010000|core[000114]);  }
void D07430() { lac &= (010000|core[000001]);  }
void I07431() { lac &= (010000|core[007550]);  }
void I07432() { if (++core[007503] == 010000) { core[007503] = 0; npc++; }; code[007503] = &emul8;  }
void I07433() { npc = 000100; inh = 0;  }
void I07434() { lac &= (010000|core[000100]);  }
void I07435() { if (++core[007510] == 010000) { core[007510] = 0; npc++; }; code[007510] = &emul8;  }
void I07436() { lac += core[(df<<12)+core[0]];  }
void I07437() { lac &= (010000|core[000100]);  }
void I07440() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void I07441() { if (++core[007524] == 010000) { core[007524] = 0; npc++; }; code[007524] = &emul8;  }
void I07442() { lac &= (010000|core[000001]);  }
void I07443() { emul8();  }
void I07444() { lac &= (010000|core[000100]);  }
void I07445() { emul8();  }
void I07446() { lac &= (010000|core[000100]);  }
void I07447() { if (++core[007510] == 010000) { core[007510] = 0; npc++; }; code[007510] = &emul8;  }
void I07450() { lac += core[000106];  }
void I07451() { if (++core[(df<<12)+core[19]] == 010000) { core[(df<<12)+core[19]] = 0; npc++; }; code[(df<<12)+core[19]] = &emul8;  }
void I07452() { lac &= (010000|core[000001]);  }
void I07453() { lac += core[(df<<12)+core[19]];  }
void I07454() { if (++core[007400] == 010000) { core[007400] = 0; npc++; }; code[007400] = &emul8;  }
void I07455() { lac &= (010000|core[000100]);  }
void I07456() { lac &= (010000|core[007550]);  }
void I07457() { lac &= (010000|core[(df<<12)+core[3924]]);  }
void I07460() { npc = 000100; inh = 0;  }
void I07461() { lac &= (010000|core[000100]);  }
void I07462() { lac &= (010000|core[000123]);  }
void I07463() { if (++core[007400] == 010000) { core[007400] = 0; npc++; }; code[007400] = &emul8;  }
void I07464() { lac &= (010000|core[000100]);  }
void I07465() { lac &= (010000|core[(df<<12)+core[16]]);  }
void I07466() { if (++core[007532] == 010000) { core[007532] = 0; npc++; }; code[007532] = &emul8;  }
void I07467() { lac &= (010000|core[000001]);  }
void I07470() { lac &= (010000|core[(df<<12)+core[16]]);  }
void I07471() { lac += core[000103];  }
void I07472() { lac &= (010000|core[000001]);  }
void I07473() { lac &= (010000|core[(df<<12)+core[3]]);  }
void I07474() { lac += core[(df<<12)+core[64]];  }
void I07475() { lac &= (010000|core[000100]);  }
void I07476() { lac &= (010000|core[(df<<12)+core[1]]);  }
void I07477() { lac &= (010000|core[(df<<12)+core[0]]);  }
void P07500() { lac &= (010000|core[000100]);  }
void D07501() { lac &= (010000|core[(df<<12)+core[19]]);  }
void P07502() { if (++core[(df<<12)+core[0]] == 010000) { core[(df<<12)+core[0]] = 0; npc++; }; code[(df<<12)+core[0]] = &emul8;  }
void P07503() { lac &= (010000|core[000100]);  }
void I07504() { lac &= (010000|core[007405]);  }
void D07505() { lac &= (010000|core[(df<<12)+core[3855]]);  }
void I07506() { if (++core[007405] == 010000) { core[007405] = 0; npc++; }; code[007405] = &emul8;  }
void I07507() { lac &= (010000|core[000001]);  }
void D07510() { lac &= (010000|core[000106]);  }
void D07511() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void I07512() { if (++core[007400] == 010000) { core[007400] = 0; npc++; }; code[007400] = &emul8;  }
void D07513() { lac &= (010000|core[000100]);  }
void I07514() { lac &= (010000|core[007550]);  }
void I07515() { lac += core[(df<<12)+core[83]];  }
void I07516() { lac += core[000051];  }
void I07517() { lac &= (010000|core[000001]);  }
void I07520() { lac &= (010000|core[007550]);  }
void I07521() { lac += core[(df<<12)+core[19]];  }
void I07522() { lac += core[000051];  }
void I07523() { lac &= (010000|core[000001]);  }
void P07524() { if (++core[007501] == 010000) { core[007501] = 0; npc++; }; code[007501] = &emul8;  }
void D07525() { lac += core[(df<<12)+core[64]];  }
void I07526() { lac &= (010000|core[000100]);  }
void I07527() { if (++core[007405] == 010000) { core[007405] = 0; npc++; }; code[007405] = &emul8;  }
void I07530() { lac &= (010000|core[(df<<12)+core[3904]]);  }
void I07531() { lac &= (010000|core[000100]);  }
void D07532() { lac += core[007505];  }
void I07533() { lac ^= 07777;  }
void I07534() { emul8();  }
void I07535() { lac &= (010000|core[000100]);  }
void I07536() { if (++core[000017] == 010000) core[000017] = 0000;if (++core[(df<<12)+core[000017]] == 010000) { core[(df<<12)+core[000017]] = 0; npc++; }; code[(df<<12)+core[000017]] = &emul8;  }
void I07537() { core[000002] = 07540; npc = 000002+1; code[000002] = &emul8; inh = 0;  }
void P07540() { lac &= (010000|core[(df<<12)+core[96]]);  }
void I07541() { lac &= (010000|core[000104]);  }
void I07542() { lac &= (010000|core[(df<<12)+core[5]]);  }
void I07543() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I07544() { lac &= (010000|core[000100]);  }
void I07545() { if (++core[007513] == 010000) { core[007513] = 0; npc++; }; code[007513] = &emul8;  }
void I07546() { lac += core[000120];  }
void I07547() { core[000017] = 07550; npc = 000017+1; code[000017] = &emul8; inh = 0;  }
void D07550() { lac &= (010000|core[007503]);  }
void I07551() { if (++core[(df<<12)+core[82]] == 010000) { core[(df<<12)+core[82]] = 0; npc++; }; code[(df<<12)+core[82]] = &emul8;  }
void I07552() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I07553() { lac &= (010000|core[000001]);  }
void I07554() { lac += core[(df<<12)+core[3855]];  }
void I07555() { core[000023] = 07556; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I07556() { lac += core[007511];  }
void I07557() { if (++core[000040] == 010000) { core[000040] = 0; npc++; }; code[000040] = &emul8;  }
void I07560() { lac += core[(df<<12)+core[3907]];  }
void I07561() { lac &= (010000|core[007525]);  }
void I07562() { if (++core[007405] == 010000) { core[007405] = 0; npc++; }; code[007405] = &emul8;  }
void I07563() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I07564() { lac &= (010000|core[000100]);  }
void I07565() { if (++core[007405] == 010000) { core[007405] = 0; npc++; }; code[007405] = &emul8;  }
void I07566() { lac &= (010000|core[(df<<12)+core[3936]]);  }
void I07567() { lac += core[(df<<12)+core[79]];  }
void I07570() { if (++core[000011] == 010000) core[000011] = 0000;lac &= (010000|core[(df<<12)+core[000011]]);  }
void I07571() { lac &= (010000|core[(df<<12)+core[3849]]);  }
void I07572() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I07573() { lac &= (010000|core[000001]);  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &P00001;
  core[000002] = 00002; code[000002] = &D00002;
  core[000003] = 00003; code[000003] = &P00003;
  core[000010] = 00000; code[000010] = &P00010;
  core[000011] = 00000; code[000011] = &P00011;
  core[000012] = 00000; code[000012] = &P00012;
  core[000013] = 00000; code[000013] = &P00013;
  core[000020] = 00000; code[000020] = &P00020;
  core[000021] = 00000; code[000021] = &D00021;
  core[000022] = 00000; code[000022] = &D00022;
  core[000023] = 00000; code[000023] = &P00023;
  core[000024] = 00000; code[000024] = &D00024;
  core[000025] = 00000; code[000025] = &P00025;
  core[000026] = 00000; code[000026] = &P00026;
  core[000027] = 00000; code[000027] = &D00027;
  core[000030] = 00000; code[000030] = &P00030;
  core[000031] = 00000; code[000031] = &P00031;
  core[000032] = 00000; code[000032] = &P00032;
  core[000033] = 00000; code[000033] = &L00033;
  core[000034] = 00000; code[000034] = &P00034;
  core[000035] = 00000; code[000035] = &P00035;
  core[000036] = 00000; code[000036] = &D00036;
  core[000037] = 00000; code[000037] = &D00037;
  core[000040] = 00000; code[000040] = &P00040;
  core[000041] = 00000; code[000041] = &D00041;
  core[000042] = 00000; code[000042] = &D00042;
  core[000043] = 00000; code[000043] = &D00043;
  core[000044] = 00000; code[000044] = &P00044;
  core[000045] = 00000; code[000045] = &P00045;
  core[000046] = 00000; code[000046] = &D00046;
  core[000047] = 00000; code[000047] = &D00047;
  core[000050] = 06600; code[000050] = &P00050;
  core[000051] = 06670; code[000051] = &P00051;
  core[000052] = 06345; code[000052] = &P00052;
  core[000053] = 06400; code[000053] = &P00053;
  core[000054] = 06723; code[000054] = &P00054;
  core[000055] = 06727; code[000055] = &P00055;
  core[000056] = 00000; code[000056] = &P00056;
  core[000057] = 00000; code[000057] = &P00057;
  core[000060] = 00400; code[000060] = &D00060;
  core[000061] = 00503; code[000061] = &D00061;
  core[000062] = 00650; code[000062] = &P00062;
  core[000063] = 00000; code[000063] = &P00063;
  core[000064] = 00000; code[000064] = &D00064;
  core[000065] = 00000; code[000065] = &D00065;
  core[000066] = 00000; code[000066] = &D00066;
  core[000067] = 00000; code[000067] = &P00067;
  core[000070] = 00215; code[000070] = &D00070;
  core[000071] = 00212; code[000071] = &D00071;
  core[000072] = 00315; code[000072] = &D00072;
  core[000073] = 00321; code[000073] = &P00073;
  core[000074] = 00314; code[000074] = &P00074;
  core[000075] = 00324; code[000075] = &P00075;
  core[000076] = 00301; code[000076] = &P00076;
  core[000077] = 00303; code[000077] = &P00077;
  core[000100] = 00261; code[000100] = &P00100;
  core[000101] = 00260; code[000101] = &D00101;
  core[000102] = 00000; code[000102] = &D00102;
  core[000103] = 00255; code[000103] = &P00103;
  core[000104] = 07763; code[000104] = &P00104;
  core[000105] = 00000; code[000105] = &D00105;
  core[000106] = 00000; code[000106] = &D00106;
  core[000107] = 01000; code[000107] = &P00107;
  core[000110] = 01135; code[000110] = &D00110;
  core[000111] = 00326; code[000111] = &D00111;
  core[000112] = 00263; code[000112] = &P00112;
  core[000113] = 00262; code[000113] = &P00113;
  core[000114] = 00000; code[000114] = &D00114;
  core[000115] = 00000; code[000115] = &D00115;
  core[000116] = 00000; code[000116] = &D00116;
  core[000117] = 00000; code[000117] = &P00117;
  core[000120] = 00000; code[000120] = &P00120;
  core[000121] = 00000; code[000121] = &P00121;
  core[000122] = 00000; code[000122] = &P00122;
  core[000123] = 07740; code[000123] = &P00123;
  core[000124] = 05600; code[000124] = &P00124;
  core[000125] = 05607; code[000125] = &P00125;
  core[000126] = 05613; code[000126] = &P00126;
  core[000127] = 05640; code[000127] = &P00127;
  core[000130] = 05656; code[000130] = &P00130;
  core[000131] = 05663; code[000131] = &P00131;
  core[000132] = 05645; code[000132] = &P00132;
  core[000133] = 05652; code[000133] = &L00133;
  core[000134] = 05707; code[000134] = &P00134;
  core[000135] = 05274; code[000135] = &P00135;
  core[000136] = 05317; code[000136] = &P00136;
  core[000137] = 07000; code[000137] = &P00137;
  core[000140] = 05520; code[000140] = &P00140;
  core[000141] = 05410; code[000141] = &P00141;
  core[000142] = 05546; code[000142] = &P00142;
  core[000143] = 05325; code[000143] = &P00143;
  core[000144] = 05333; code[000144] = &P00144;
  core[000145] = 05342; code[000145] = &P00145;
  core[000146] = 05400; code[000146] = &P00146;
  core[000147] = 07070; code[000147] = &P00147;
  core[000150] = 06525; code[000150] = &P00150;
  core[000151] = 05751; code[000151] = &P00151;
  core[000152] = 05732; code[000152] = &P00152;
  core[000153] = 05761; code[000153] = &P00153;
  core[000154] = 06000; code[000154] = &P00154;
  core[000155] = 05726; code[000155] = &P00155;
  core[000156] = 05503; code[000156] = &P00156;
  core[000163] = 04000; code[000163] = &D00163;
  core[000164] = 00031; code[000164] = &D00164;
  core[000165] = 00037; code[000165] = &D00165;
  core[000166] = 07563; code[000166] = &D00166;
  core[000167] = 00033; code[000167] = &P00167;
  core[000170] = 00042; code[000170] = &D00170;
  core[000171] = 02525; code[000171] = &D00171;
  core[000172] = 05252; code[000172] = &D00172;
  core[000173] = 05767; code[000173] = &P00173;
  core[000174] = 07741; code[000174] = &D00174;
  core[000175] = 05551; code[000175] = &P00175;
  core[000176] = 06704; code[000176] = &P00176;
  core[000177] = 05000; code[000177] = &P00177;
  core[000200] = 06007; code[000200] = &I00200;
  core[000201] = 03115; code[000201] = &I00201;
  core[000202] = 07621; code[000202] = &L00202;
  core[000203] = 04577; code[000203] = &I00203;
  core[000204] = 05244; code[000204] = &L00204;
  core[000205] = 04542; code[000205] = &L00205;
  core[000206] = 07360; code[000206] = &L00206;
  core[000207] = 00065; code[000207] = &I00207;
  core[000210] = 03063; code[000210] = &I00210;
  core[000211] = 07240; code[000211] = &I00211;
  core[000212] = 03064; code[000212] = &I00212;
  core[000213] = 01063; code[000213] = &I00213;
  core[000214] = 07421; code[000214] = &I00214;
  core[000215] = 03067; code[000215] = &I00215;
  core[000216] = 07620; code[000216] = &I00216;
  core[000217] = 05345; code[000217] = &I00217;
  core[000220] = 07240; code[000220] = &I00220;
  core[000221] = 03066; code[000221] = &I00221;
  core[000222] = 01067; code[000222] = &L00222;
  core[000223] = 07640; code[000223] = &I00223;
  core[000224] = 05231; code[000224] = &I00224;
  core[000225] = 01066; code[000225] = &I00225;
  core[000226] = 07450; code[000226] = &I00226;
  core[000227] = 05231; code[000227] = &I00227;
  core[000230] = 05237; code[000230] = &I00230;
  core[000231] = 04545; code[000231] = &L00231;
  core[000232] = 04254; code[000232] = &I00232;
  core[000233] = 07704; code[000233] = &I00233;
  core[000234] = 07004; code[000234] = &I00234;
  core[000235] = 07430; code[000235] = &I00235;
  core[000236] = 07402; code[000236] = &I00236;
  core[000237] = 07604; code[000237] = &L00237;
  core[000240] = 07106; code[000240] = &I00240;
  core[000241] = 07430; code[000241] = &I00241;
  core[000242] = 05206; code[000242] = &I00242;
  core[000243] = 05205; code[000243] = &I00243;
  core[000244] = 07300; code[000244] = &L00244;
  core[000245] = 03065; code[000245] = &I00245;
  core[000246] = 01344; code[000246] = &I00246;
  core[000247] = 03056; code[000247] = &I00247;
  core[000250] = 01060; code[000250] = &I00250;
  core[000251] = 03057; code[000251] = &I00251;
  core[000252] = 04535; code[000252] = &I00252;
  core[000253] = 05205; code[000253] = &I00253;
  core[000254] = 00000; code[000254] = &S00254;
  core[000255] = 04525; code[000255] = &L00255;
  core[000256] = 04302; code[000256] = &I00256;
  core[000257] = 04311; code[000257] = &I00257;
  core[000260] = 04316; code[000260] = &I00260;
  core[000261] = 04576; code[000261] = &L00261;
  core[000262] = 04524; code[000262] = &D00262;
  core[000263] = 04455; code[000263] = &D00263;
  core[000264] = 04323; code[000264] = &I00264;
  core[000265] = 04455; code[000265] = &I00265;
  core[000266] = 04332; code[000266] = &I00266;
  core[000267] = 04454; code[000267] = &I00267;
  core[000270] = 04740; code[000270] = &I00270;
  core[000271] = 04524; code[000271] = &I00271;
  core[000272] = 04530; code[000272] = &I00272;
  core[000273] = 04741; code[000273] = &I00273;
  core[000274] = 04323; code[000274] = &I00274;
  core[000275] = 04455; code[000275] = &I00275;
  core[000276] = 04742; code[000276] = &I00276;
  core[000277] = 04454; code[000277] = &I00277;
  core[000300] = 04743; code[000300] = &I00300;
  core[000301] = 05654; code[000301] = &L00301;
  core[000302] = 00000; code[000302] = &S00302;
  core[000303] = 07240; code[000303] = &L00303;
  core[000304] = 00072; code[000304] = &I00304;
  core[000305] = 04526; code[000305] = &I00305;
  core[000306] = 01073; code[000306] = &I00306;
  core[000307] = 04526; code[000307] = &I00307;
  core[000310] = 05702; code[000310] = &I00310;
  core[000311] = 00000; code[000311] = &S00311;
  core[000312] = 07240; code[000312] = &I00312;
  core[000313] = 00074; code[000313] = &I00313;
  core[000314] = 04526; code[000314] = &L00314;
  core[000315] = 05711; code[000315] = &I00315;
  core[000316] = 00000; code[000316] = &S00316;
  core[000317] = 07240; code[000317] = &I00317;
  core[000320] = 00075; code[000320] = &D00320;
  core[000321] = 04526; code[000321] = &D00321;
  core[000322] = 05716; code[000322] = &I00322;
  core[000323] = 00000; code[000323] = &S00323;
  core[000324] = 07240; code[000324] = &L00324;
  core[000325] = 00076; code[000325] = &I00325;
  core[000326] = 04526; code[000326] = &I00326;
  core[000327] = 01077; code[000327] = &I00327;
  core[000330] = 04526; code[000330] = &I00330;
  core[000331] = 05723; code[000331] = &I00331;
  core[000332] = 00000; code[000332] = &S00332;
  core[000333] = 07240; code[000333] = &I00333;
  core[000334] = 00064; code[000334] = &I00334;
  core[000335] = 03102; code[000335] = &I00335;
  core[000336] = 04527; code[000336] = &I00336;
  core[000337] = 05732; code[000337] = &I00337;
  core[000340] = 00362; code[000340] = &P00340;
  core[000341] = 00355; code[000341] = &P00341;
  core[000342] = 00347; code[000342] = &P00342;
  core[000343] = 00370; code[000343] = &P00343;
  core[000344] = 00204; code[000344] = &D00344;
  core[000345] = 03066; code[000345] = &L00345;
  core[000346] = 05222; code[000346] = &I00346;
  core[000347] = 00000; code[000347] = &S00347;
  core[000350] = 07240; code[000350] = &D00350;
  core[000351] = 00066; code[000351] = &I00351;
  core[000352] = 03102; code[000352] = &I00352;
  core[000353] = 04527; code[000353] = &I00353;
  core[000354] = 05747; code[000354] = &I00354;
  core[000355] = 00000; code[000355] = &S00355;
  core[000356] = 07240; code[000356] = &I00356;
  core[000357] = 00103; code[000357] = &I00357;
  core[000360] = 04526; code[000360] = &I00360;
  core[000361] = 05755; code[000361] = &I00361;
  core[000362] = 00000; code[000362] = &S00362;
  core[000363] = 07240; code[000363] = &I00363;
  core[000364] = 00063; code[000364] = &I00364;
  core[000365] = 03106; code[000365] = &I00365;
  core[000366] = 04531; code[000366] = &I00366;
  core[000367] = 05762; code[000367] = &I00367;
  core[000370] = 00000; code[000370] = &S00370;
  core[000371] = 07240; code[000371] = &I00371;
  core[000372] = 00067; code[000372] = &I00372;
  core[000373] = 03106; code[000373] = &I00373;
  core[000374] = 04531; code[000374] = &I00374;
  core[000375] = 05770; code[000375] = &I00375;
  core[000400] = 05227; code[000400] = &P00400;
  core[000401] = 04542; code[000401] = &L00401;
  core[000402] = 07340; code[000402] = &L00402;
  core[000403] = 00065; code[000403] = &I00403;
  core[000404] = 03063; code[000404] = &I00404;
  core[000405] = 03064; code[000405] = &P00405;
  core[000406] = 07040; code[000406] = &I00406;
  core[000407] = 00063; code[000407] = &I00407;
  core[000410] = 07421; code[000410] = &I00410;
  core[000411] = 03067; code[000411] = &I00411;
  core[000412] = 07620; code[000412] = &I00412;
  core[000413] = 05301; code[000413] = &I00413;
  core[000414] = 07240; code[000414] = &I00414;
  core[000415] = 03066; code[000415] = &I00415;
  core[000416] = 07040; code[000416] = &L00416;
  core[000417] = 00067; code[000417] = &I00417;
  core[000420] = 07440; code[000420] = &I00420;
  core[000421] = 05237; code[000421] = &I00421;
  core[000422] = 07240; code[000422] = &I00422;
  core[000423] = 00066; code[000423] = &I00423;
  core[000424] = 07440; code[000424] = &I00424;
  core[000425] = 05237; code[000425] = &I00425;
  core[000426] = 05250; code[000426] = &I00426;
  core[000427] = 07300; code[000427] = &L00427;
  core[000430] = 03065; code[000430] = &I00430;
  core[000431] = 01060; code[000431] = &I00431;
  core[000432] = 03056; code[000432] = &I00432;
  core[000433] = 01061; code[000433] = &I00433;
  core[000434] = 03057; code[000434] = &I00434;
  core[000435] = 04535; code[000435] = &I00435;
  core[000436] = 05201; code[000436] = &I00436;
  core[000437] = 07604; code[000437] = &L00437;
  core[000440] = 07106; code[000440] = &I00440;
  core[000441] = 07004; code[000441] = &I00441;
  core[000442] = 07430; code[000442] = &I00442;
  core[000443] = 05256; code[000443] = &I00443;
  core[000444] = 07604; code[000444] = &I00444;
  core[000445] = 07104; code[000445] = &I00445;
  core[000446] = 07430; code[000446] = &P00446;
  core[000447] = 07402; code[000447] = &I00447;
  core[000450] = 07604; code[000450] = &L00450;
  core[000451] = 07106; code[000451] = &I00451;
  core[000452] = 07430; code[000452] = &I00452;
  core[000453] = 05202; code[000453] = &I00453;
  core[000454] = 05201; code[000454] = &D00454;
  core[000455] = 00444; code[000455] = &D00455;
  core[000456] = 07240; code[000456] = &L00456;
  core[000457] = 00255; code[000457] = &I00457;
  core[000460] = 03700; code[000460] = &I00460;
  core[000461] = 04525; code[000461] = &D00461;
  core[000462] = 04670; code[000462] = &I00462;
  core[000463] = 04671; code[000463] = &I00463;
  core[000464] = 04672; code[000464] = &I00464;
  core[000465] = 04273; code[000465] = &I00465;
  core[000466] = 05667; code[000466] = &I00466;
  core[000467] = 00261; code[000467] = &P00467;
  core[000470] = 00302; code[000470] = &P00470;
  core[000471] = 00311; code[000471] = &P00471;
  core[000472] = 00316; code[000472] = &P00472;
  core[000473] = 00000; code[000473] = &S00473;
  core[000474] = 07240; code[000474] = &I00474;
  core[000475] = 00100; code[000475] = &I00475;
  core[000476] = 04526; code[000476] = &I00476;
  core[000477] = 05673; code[000477] = &I00477;
  core[000500] = 00254; code[000500] = &P00500;
  core[000501] = 03066; code[000501] = &L00501;
  core[000502] = 05216; code[000502] = &D00502;
  core[000503] = 05340; code[000503] = &I00503;
  core[000504] = 04542; code[000504] = &L00504;
  core[000505] = 07360; code[000505] = &L00505;
  core[000506] = 00065; code[000506] = &I00506;
  core[000507] = 03063; code[000507] = &I00507;
  core[000510] = 07240; code[000510] = &I00510;
  core[000511] = 03064; code[000511] = &D00511;
  core[000512] = 07040; code[000512] = &I00512;
  core[000513] = 00063; code[000513] = &I00513;
  core[000514] = 07421; code[000514] = &I00514;
  core[000515] = 07501; code[000515] = &I00515;
  core[000516] = 03067; code[000516] = &D00516;
  core[000517] = 07620; code[000517] = &I00517;
  core[000520] = 05777; code[000520] = &I00520;
  core[000521] = 07240; code[000521] = &I00521;
  core[000522] = 03066; code[000522] = &I00522;
  core[000523] = 07040; code[000523] = &L00523;
  core[000524] = 00063; code[000524] = &I00524;
  core[000525] = 07140; code[000525] = &I00525;
  core[000526] = 01067; code[000526] = &I00526;
  core[000527] = 07040; code[000527] = &I00527;
  core[000530] = 07450; code[000530] = &I00530;
  core[000531] = 07430; code[000531] = &I00531;
  core[000532] = 05350; code[000532] = &I00532;
  core[000533] = 07240; code[000533] = &I00533;
  core[000534] = 00066; code[000534] = &I00534;
  core[000535] = 07450; code[000535] = &I00535;
  core[000536] = 05350; code[000536] = &I00536;
  core[000537] = 05363; code[000537] = &I00537;
  core[000540] = 07300; code[000540] = &L00540;
  core[000541] = 03065; code[000541] = &I00541;
  core[000542] = 01061; code[000542] = &I00542;
  core[000543] = 03056; code[000543] = &I00543;
  core[000544] = 01062; code[000544] = &I00544;
  core[000545] = 03057; code[000545] = &I00545;
  core[000546] = 04535; code[000546] = &I00546;
  core[000547] = 05304; code[000547] = &I00547;
  core[000550] = 07604; code[000550] = &L00550;
  core[000551] = 07106; code[000551] = &I00551;
  core[000552] = 07004; code[000552] = &I00552;
  core[000553] = 07420; code[000553] = &I00553;
  core[000554] = 05357; code[000554] = &I00554;
  core[000555] = 04776; code[000555] = &I00555;
  core[000556] = 04775; code[000556] = &I00556;
  core[000557] = 07604; code[000557] = &L00557;
  core[000560] = 07104; code[000560] = &I00560;
  core[000561] = 07430; code[000561] = &I00561;
  core[000562] = 07402; code[000562] = &I00562;
  core[000563] = 07604; code[000563] = &L00563;
  core[000564] = 07106; code[000564] = &I00564;
  core[000565] = 07430; code[000565] = &I00565;
  core[000566] = 05305; code[000566] = &I00566;
  core[000567] = 05304; code[000567] = &I00567;
  core[000575] = 00605; code[000575] = &P00575;
  core[000576] = 00600; code[000576] = &P00576;
  core[000577] = 00646; code[000577] = &P00577;
  core[000600] = 00000; code[000600] = &S00600;
  core[000601] = 04525; code[000601] = &I00601;
  core[000602] = 04777; code[000602] = &I00602;
  core[000603] = 04232; code[000603] = &I00603;
  core[000604] = 05600; code[000604] = &I00604;
  core[000605] = 00000; code[000605] = &S00605;
  core[000606] = 04576; code[000606] = &I00606;
  core[000607] = 04524; code[000607] = &I00607;
  core[000610] = 04451; code[000610] = &I00610;
  core[000611] = 07773; code[000611] = &I00611;
  core[000612] = 04776; code[000612] = &I00612;
  core[000613] = 04455; code[000613] = &I00613;
  core[000614] = 04775; code[000614] = &I00614;
  core[000615] = 04454; code[000615] = &I00615;
  core[000616] = 04774; code[000616] = &I00616;
  core[000617] = 04524; code[000617] = &I00617;
  core[000620] = 04777; code[000620] = &I00620;
  core[000621] = 04773; code[000621] = &I00621;
  core[000622] = 04454; code[000622] = &I00622;
  core[000623] = 04777; code[000623] = &I00623;
  core[000624] = 04241; code[000624] = &I00624;
  core[000625] = 04455; code[000625] = &I00625;
  core[000626] = 04772; code[000626] = &I00626;
  core[000627] = 04454; code[000627] = &I00627;
  core[000630] = 04771; code[000630] = &I00630;
  core[000631] = 05605; code[000631] = &I00631;
  core[000632] = 00000; code[000632] = &S00632;
  core[000633] = 07240; code[000633] = &I00633;
  core[000634] = 00076; code[000634] = &I00634;
  core[000635] = 04526; code[000635] = &I00635;
  core[000636] = 01075; code[000636] = &I00636;
  core[000637] = 04526; code[000637] = &I00637;
  core[000640] = 05632; code[000640] = &I00640;
  core[000641] = 00000; code[000641] = &S00641;
  core[000642] = 07240; code[000642] = &I00642;
  core[000643] = 00076; code[000643] = &I00643;
  core[000644] = 04526; code[000644] = &I00644;
  core[000645] = 05641; code[000645] = &I00645;
  core[000646] = 03066; code[000646] = &L00646;
  core[000647] = 05770; code[000647] = &I00647;
  core[000650] = 04304; code[000650] = &L00650;
  core[000651] = 04542; code[000651] = &L00651;
  core[000652] = 07340; code[000652] = &L00652;
  core[000653] = 00065; code[000653] = &I00653;
  core[000654] = 03063; code[000654] = &I00654;
  core[000655] = 03064; code[000655] = &I00655;
  core[000656] = 07040; code[000656] = &I00656;
  core[000657] = 00063; code[000657] = &I00657;
  core[000660] = 07421; code[000660] = &I00660;
  core[000661] = 07501; code[000661] = &I00661;
  core[000662] = 03067; code[000662] = &I00662;
  core[000663] = 07620; code[000663] = &I00663;
  core[000664] = 05340; code[000664] = &I00664;
  core[000665] = 07240; code[000665] = &I00665;
  core[000666] = 03066; code[000666] = &I00666;
  core[000667] = 07040; code[000667] = &L00667;
  core[000670] = 00063; code[000670] = &I00670;
  core[000671] = 07140; code[000671] = &I00671;
  core[000672] = 01067; code[000672] = &I00672;
  core[000673] = 07040; code[000673] = &I00673;
  core[000674] = 07450; code[000674] = &I00674;
  core[000675] = 07430; code[000675] = &I00675;
  core[000676] = 05314; code[000676] = &I00676;
  core[000677] = 07240; code[000677] = &I00677;
  core[000700] = 00066; code[000700] = &I00700;
  core[000701] = 07440; code[000701] = &I00701;
  core[000702] = 05314; code[000702] = &D00702;
  core[000703] = 05330; code[000703] = &I00703;
  core[000704] = 07300; code[000704] = &I00704;
  core[000705] = 03065; code[000705] = &I00705;
  core[000706] = 01062; code[000706] = &I00706;
  core[000707] = 03056; code[000707] = &I00707;
  core[000710] = 01107; code[000710] = &I00710;
  core[000711] = 03057; code[000711] = &D00711;
  core[000712] = 04535; code[000712] = &I00712;
  core[000713] = 05251; code[000713] = &I00713;
  core[000714] = 07604; code[000714] = &L00714;
  core[000715] = 07106; code[000715] = &I00715;
  core[000716] = 07004; code[000716] = &I00716;
  core[000717] = 07420; code[000717] = &I00717;
  core[000720] = 05324; code[000720] = &I00720;
  core[000721] = 04735; code[000721] = &I00721;
  core[000722] = 04736; code[000722] = &I00722;
  core[000723] = 04737; code[000723] = &D00723;
  core[000724] = 07604; code[000724] = &L00724;
  core[000725] = 07104; code[000725] = &I00725;
  core[000726] = 07430; code[000726] = &I00726;
  core[000727] = 07402; code[000727] = &I00727;
  core[000730] = 07604; code[000730] = &L00730;
  core[000731] = 07106; code[000731] = &I00731;
  core[000732] = 07430; code[000732] = &D00732;
  core[000733] = 05252; code[000733] = &I00733;
  core[000734] = 05251; code[000734] = &I00734;
  core[000735] = 00600; code[000735] = &P00735;
  core[000736] = 00473; code[000736] = &P00736;
  core[000737] = 00605; code[000737] = &P00737;
  core[000740] = 03066; code[000740] = &L00740;
  core[000741] = 05267; code[000741] = &I00741;
  core[000770] = 00523; code[000770] = &P00770;
  core[000771] = 00370; code[000771] = &P00771;
  core[000772] = 00347; code[000772] = &P00772;
  core[000773] = 00311; code[000773] = &P00773;
  core[000774] = 00362; code[000774] = &P00774;
  core[000775] = 00332; code[000775] = &P00775;
  core[000776] = 00323; code[000776] = &P00776;
  core[000777] = 00302; code[000777] = &P00777;
  core[001000] = 05232; code[001000] = &P01000;
  core[001001] = 04542; code[001001] = &L01001;
  core[001002] = 07360; code[001002] = &L01002;
  core[001003] = 00065; code[001003] = &I01003;
  core[001004] = 07040; code[001004] = &I01004;
  core[001005] = 03063; code[001005] = &I01005;
  core[001006] = 07040; code[001006] = &I01006;
  core[001007] = 03064; code[001007] = &I01007;
  core[001010] = 01065; code[001010] = &D01010;
  core[001011] = 07421; code[001011] = &I01011;
  core[001012] = 01063; code[001012] = &I01012;
  core[001013] = 07501; code[001013] = &I01013;
  core[001014] = 03067; code[001014] = &I01014;
  core[001015] = 07620; code[001015] = &I01015;
  core[001016] = 05333; code[001016] = &I01016;
  core[001017] = 07240; code[001017] = &I01017;
  core[001020] = 03066; code[001020] = &I01020;
  core[001021] = 01067; code[001021] = &L01021;
  core[001022] = 07040; code[001022] = &I01022;
  core[001023] = 07440; code[001023] = &D01023;
  core[001024] = 05242; code[001024] = &I01024;
  core[001025] = 07040; code[001025] = &I01025;
  core[001026] = 00066; code[001026] = &I01026;
  core[001027] = 07450; code[001027] = &I01027;
  core[001030] = 05242; code[001030] = &I01030;
  core[001031] = 05255; code[001031] = &I01031;
  core[001032] = 07300; code[001032] = &L01032;
  core[001033] = 03065; code[001033] = &I01033;
  core[001034] = 01107; code[001034] = &I01034;
  core[001035] = 03056; code[001035] = &I01035;
  core[001036] = 01110; code[001036] = &I01036;
  core[001037] = 03057; code[001037] = &I01037;
  core[001040] = 04535; code[001040] = &D01040;
  core[001041] = 05201; code[001041] = &D01041;
  core[001042] = 07604; code[001042] = &L01042;
  core[001043] = 07106; code[001043] = &I01043;
  core[001044] = 07004; code[001044] = &I01044;
  core[001045] = 07420; code[001045] = &I01045;
  core[001046] = 05251; code[001046] = &I01046;
  core[001047] = 04662; code[001047] = &I01047;
  core[001050] = 04263; code[001050] = &I01050;
  core[001051] = 07604; code[001051] = &L01051;
  core[001052] = 07104; code[001052] = &I01052;
  core[001053] = 07430; code[001053] = &I01053;
  core[001054] = 07402; code[001054] = &I01054;
  core[001055] = 07604; code[001055] = &L01055;
  core[001056] = 07106; code[001056] = &I01056;
  core[001057] = 07430; code[001057] = &I01057;
  core[001060] = 05202; code[001060] = &I01060;
  core[001061] = 05201; code[001061] = &I01061;
  core[001062] = 00600; code[001062] = &P01062;
  core[001063] = 00000; code[001063] = &S01063;
  core[001064] = 04326; code[001064] = &I01064;
  core[001065] = 04576; code[001065] = &I01065;
  core[001066] = 04524; code[001066] = &L01066;
  core[001067] = 04455; code[001067] = &I01067;
  core[001070] = 04454; code[001070] = &I01070;
  core[001071] = 04777; code[001071] = &I01071;
  core[001072] = 04455; code[001072] = &I01072;
  core[001073] = 04776; code[001073] = &I01073;
  core[001074] = 04454; code[001074] = &I01074;
  core[001075] = 04775; code[001075] = &I01075;
  core[001076] = 04524; code[001076] = &I01076;
  core[001077] = 04455; code[001077] = &I01077;
  core[001100] = 04454; code[001100] = &I01100;
  core[001101] = 04774; code[001101] = &I01101;
  core[001102] = 04455; code[001102] = &D01102;
  core[001103] = 04455; code[001103] = &I01103;
  core[001104] = 07200; code[001104] = &I01104;
  core[001105] = 01065; code[001105] = &I01105;
  core[001106] = 03063; code[001106] = &I01106;
  core[001107] = 04775; code[001107] = &I01107;
  core[001110] = 04524; code[001110] = &I01110;
  core[001111] = 04774; code[001111] = &I01111;
  core[001112] = 04321; code[001112] = &I01112;
  core[001113] = 04777; code[001113] = &I01113;
  core[001114] = 04455; code[001114] = &I01114;
  core[001115] = 04773; code[001115] = &I01115;
  core[001116] = 04454; code[001116] = &I01116;
  core[001117] = 04772; code[001117] = &I01117;
  core[001120] = 05663; code[001120] = &I01120;
  core[001121] = 00000; code[001121] = &S01121;
  core[001122] = 07240; code[001122] = &I01122;
  core[001123] = 00111; code[001123] = &D01123;
  core[001124] = 04526; code[001124] = &I01124;
  core[001125] = 05721; code[001125] = &I01125;
  core[001126] = 00000; code[001126] = &S01126;
  core[001127] = 07240; code[001127] = &I01127;
  core[001130] = 00113; code[001130] = &I01130;
  core[001131] = 04526; code[001131] = &I01131;
  core[001132] = 05726; code[001132] = &D01132;
  core[001133] = 03066; code[001133] = &L01133;
  core[001134] = 05221; code[001134] = &I01134;
  core[001135] = 05771; code[001135] = &I01135;
  core[001136] = 04542; code[001136] = &L01136;
  core[001137] = 07340; code[001137] = &L01137;
  core[001140] = 00065; code[001140] = &I01140;
  core[001141] = 07040; code[001141] = &I01141;
  core[001142] = 03063; code[001142] = &I01142;
  core[001143] = 03064; code[001143] = &I01143;
  core[001144] = 07040; code[001144] = &I01144;
  core[001145] = 00065; code[001145] = &I01145;
  core[001146] = 07421; code[001146] = &I01146;
  core[001147] = 01063; code[001147] = &D01147;
  core[001150] = 07501; code[001150] = &I01150;
  core[001151] = 03067; code[001151] = &I01151;
  core[001152] = 07620; code[001152] = &I01152;
  core[001153] = 07410; code[001153] = &I01153;
  core[001154] = 07240; code[001154] = &I01154;
  core[001155] = 03066; code[001155] = &I01155;
  core[001156] = 01067; code[001156] = &I01156;
  core[001157] = 07040; code[001157] = &I01157;
  core[001160] = 07440; code[001160] = &I01160;
  core[001161] = 05770; code[001161] = &I01161;
  core[001162] = 07040; code[001162] = &D01162;
  core[001163] = 00066; code[001163] = &I01163;
  core[001164] = 07440; code[001164] = &I01164;
  core[001165] = 05770; code[001165] = &I01165;
  core[001166] = 05767; code[001166] = &I01166;
  core[001167] = 01223; code[001167] = &P01167;
  core[001170] = 01210; code[001170] = &P01170;
  core[001171] = 01200; code[001171] = &P01171;
  core[001172] = 00370; code[001172] = &P01172;
  core[001173] = 00347; code[001173] = &P01173;
  core[001174] = 00302; code[001174] = &P01174;
  core[001175] = 00362; code[001175] = &P01175;
  core[001176] = 00332; code[001176] = &P01176;
  core[001177] = 00323; code[001177] = &P01177;
  core[001200] = 07300; code[001200] = &P01200;
  core[001201] = 03065; code[001201] = &I01201;
  core[001202] = 01110; code[001202] = &I01202;
  core[001203] = 03056; code[001203] = &I01203;
  core[001204] = 01377; code[001204] = &I01204;
  core[001205] = 03057; code[001205] = &I01205;
  core[001206] = 04535; code[001206] = &I01206;
  core[001207] = 05776; code[001207] = &I01207;
  core[001210] = 07604; code[001210] = &L01210;
  core[001211] = 07106; code[001211] = &I01211;
  core[001212] = 07004; code[001212] = &I01212;
  core[001213] = 07420; code[001213] = &I01213;
  core[001214] = 05217; code[001214] = &I01214;
  core[001215] = 04630; code[001215] = &I01215;
  core[001216] = 05233; code[001216] = &I01216;
  core[001217] = 07604; code[001217] = &L01217;
  core[001220] = 07104; code[001220] = &I01220;
  core[001221] = 07430; code[001221] = &I01221;
  core[001222] = 07402; code[001222] = &I01222;
  core[001223] = 07604; code[001223] = &L01223;
  core[001224] = 07106; code[001224] = &I01224;
  core[001225] = 07430; code[001225] = &I01225;
  core[001226] = 05775; code[001226] = &I01226;
  core[001227] = 05776; code[001227] = &I01227;
  core[001230] = 00600; code[001230] = &P01230;
  core[001231] = 01217; code[001231] = &D01231;
  core[001232] = 01063; code[001232] = &P01232;
  core[001233] = 04240; code[001233] = &L01233;
  core[001234] = 04576; code[001234] = &I01234;
  core[001235] = 01231; code[001235] = &I01235;
  core[001236] = 03632; code[001236] = &I01236;
  core[001237] = 05774; code[001237] = &I01237;
  core[001240] = 00000; code[001240] = &S01240;
  core[001241] = 07240; code[001241] = &I01241;
  core[001242] = 00112; code[001242] = &I01242;
  core[001243] = 04526; code[001243] = &I01243;
  core[001244] = 05640; code[001244] = &I01244;
  core[001245] = 04315; code[001245] = &D01245;
  core[001246] = 04263; code[001246] = &L01246;
  core[001247] = 01021; code[001247] = &L01247;
  core[001250] = 07104; code[001250] = &I01250;
  core[001251] = 01023; code[001251] = &I01251;
  core[001252] = 07421; code[001252] = &I01252;
  core[001253] = 01022; code[001253] = &I01253;
  core[001254] = 07457; code[001254] = &I01254;
  core[001255] = 04541; code[001255] = &I01255;
  core[001256] = 04773; code[001256] = &I01256;
  core[001257] = 04452; code[001257] = &I01257;
  core[001260] = 07773; code[001260] = &I01260;
  core[001261] = 05276; code[001261] = &I01261;
  core[001262] = 05302; code[001262] = &I01262;
  core[001263] = 00000; code[001263] = &S01263;
  core[001264] = 04453; code[001264] = &I01264;
  core[001265] = 00000; code[001265] = &D01265;
  core[001266] = 00021; code[001266] = &I01266;
  core[001267] = 07775; code[001267] = &I01267;
  core[001270] = 07325; code[001270] = &I01270;
  core[001271] = 01265; code[001271] = &I01271;
  core[001272] = 03265; code[001272] = &I01272;
  core[001273] = 02114; code[001273] = &I01273;
  core[001274] = 05663; code[001274] = &I01274;
  core[001275] = 05575; code[001275] = &I01275;
  core[001276] = 04545; code[001276] = &L01276;
  core[001277] = 04305; code[001277] = &I01277;
  core[001300] = 04543; code[001300] = &I01300;
  core[001301] = 07402; code[001301] = &I01301;
  core[001302] = 04544; code[001302] = &L01302;
  core[001303] = 05247; code[001303] = &I01303;
  core[001304] = 05246; code[001304] = &I01304;
  core[001305] = 00000; code[001305] = &S01305;
  core[001306] = 04534; code[001306] = &I01306;
  core[001307] = 07775; code[001307] = &I01307;
  core[001310] = 07524; code[001310] = &I01310;
  core[001311] = 07440; code[001311] = &I01311;
  core[001312] = 07443; code[001312] = &I01312;
  core[001313] = 04537; code[001313] = &I01313;
  core[001314] = 05705; code[001314] = &I01314;
  core[001315] = 00000; code[001315] = &S01315;
  core[001316] = 04540; code[001316] = &I01316;
  core[001317] = 01372; code[001317] = &I01317;
  core[001320] = 03265; code[001320] = &I01320;
  core[001321] = 01377; code[001321] = &I01321;
  core[001322] = 03056; code[001322] = &I01322;
  core[001323] = 01371; code[001323] = &I01323;
  core[001324] = 03057; code[001324] = &I01324;
  core[001325] = 01370; code[001325] = &I01325;
  core[001326] = 03114; code[001326] = &I01326;
  core[001327] = 04535; code[001327] = &I01327;
  core[001330] = 04536; code[001330] = &I01330;
  core[001331] = 07403; code[001331] = &I01331;
  core[001332] = 05715; code[001332] = &I01332;
  core[001333] = 04767; code[001333] = &D01333;
  core[001334] = 04552; code[001334] = &L01334;
  core[001335] = 01023; code[001335] = &L01335;
  core[001336] = 07421; code[001336] = &I01336;
  core[001337] = 04553; code[001337] = &I01337;
  core[001340] = 04556; code[001340] = &I01340;
  core[001341] = 01021; code[001341] = &I01341;
  core[001342] = 07104; code[001342] = &I01342;
  core[001343] = 01022; code[001343] = &I01343;
  core[001344] = 07457; code[001344] = &I01344;
  core[001345] = 04541; code[001345] = &I01345;
  core[001346] = 04773; code[001346] = &I01346;
  core[001347] = 04452; code[001347] = &I01347;
  core[001350] = 07773; code[001350] = &I01350;
  core[001351] = 05766; code[001351] = &I01351;
  core[001352] = 05765; code[001352] = &I01352;
  core[001365] = 01415; code[001365] = &P01365;
  core[001366] = 01411; code[001366] = &P01366;
  core[001367] = 01400; code[001367] = &P01367;
  core[001370] = 07764; code[001370] = &D01370;
  core[001371] = 01333; code[001371] = &D01371;
  core[001372] = 07244; code[001372] = &D01372;
  core[001373] = 06013; code[001373] = &P01373;
  core[001374] = 01066; code[001374] = &P01374;
  core[001375] = 01137; code[001375] = &P01375;
  core[001376] = 01136; code[001376] = &P01376;
  core[001377] = 01245; code[001377] = &D01377;
  core[001400] = 00000; code[001400] = &S01400;
  core[001401] = 04540; code[001401] = &I01401;
  core[001402] = 01377; code[001402] = &I01402;
  core[001403] = 03057; code[001403] = &I01403;
  core[001404] = 01376; code[001404] = &I01404;
  core[001405] = 03056; code[001405] = &I01405;
  core[001406] = 04535; code[001406] = &I01406;
  core[001407] = 04536; code[001407] = &I01407;
  core[001410] = 05600; code[001410] = &I01410;
  core[001411] = 04545; code[001411] = &L01411;
  core[001412] = 04220; code[001412] = &I01412;
  core[001413] = 04543; code[001413] = &I01413;
  core[001414] = 07402; code[001414] = &I01414;
  core[001415] = 04544; code[001415] = &L01415;
  core[001416] = 05775; code[001416] = &I01416;
  core[001417] = 05774; code[001417] = &I01417;
  core[001420] = 00000; code[001420] = &S01420;
  core[001421] = 04534; code[001421] = &I01421;
  core[001422] = 07775; code[001422] = &I01422;
  core[001423] = 07524; code[001423] = &I01423;
  core[001424] = 07440; code[001424] = &I01424;
  core[001425] = 07445; code[001425] = &I01425;
  core[001426] = 04537; code[001426] = &I01426;
  core[001427] = 05620; code[001427] = &I01427;
  core[001430] = 04253; code[001430] = &I01430;
  core[001431] = 04542; code[001431] = &L01431;
  core[001432] = 07331; code[001432] = &L01432;
  core[001433] = 03021; code[001433] = &I01433;
  core[001434] = 01065; code[001434] = &I01434;
  core[001435] = 03023; code[001435] = &I01435;
  core[001436] = 03022; code[001436] = &I01436;
  core[001437] = 01244; code[001437] = &I01437;
  core[001440] = 03024; code[001440] = &I01440;
  core[001441] = 01065; code[001441] = &I01441;
  core[001442] = 07421; code[001442] = &I01442;
  core[001443] = 07413; code[001443] = &I01443;
  core[001444] = 00000; code[001444] = &D01444;
  core[001445] = 04541; code[001445] = &I01445;
  core[001446] = 04773; code[001446] = &I01446;
  core[001447] = 04452; code[001447] = &I01447;
  core[001450] = 07773; code[001450] = &I01450;
  core[001451] = 05274; code[001451] = &I01451;
  core[001452] = 05300; code[001452] = &I01452;
  core[001453] = 00000; code[001453] = &S01453;
  core[001454] = 04540; code[001454] = &I01454;
  core[001455] = 03065; code[001455] = &I01455;
  core[001456] = 03244; code[001456] = &I01456;
  core[001457] = 01372; code[001457] = &I01457;
  core[001460] = 03056; code[001460] = &I01460;
  core[001461] = 01371; code[001461] = &I01461;
  core[001462] = 03057; code[001462] = &I01462;
  core[001463] = 01174; code[001463] = &I01463;
  core[001464] = 03114; code[001464] = &I01464;
  core[001465] = 04535; code[001465] = &I01465;
  core[001466] = 05653; code[001466] = &I01466;
  core[001467] = 02244; code[001467] = &I01467;
  core[001470] = 02114; code[001470] = &I01470;
  core[001471] = 05231; code[001471] = &I01471;
  core[001472] = 05673; code[001472] = &I01472;
  core[001473] = 01600; code[001473] = &P01473;
  core[001474] = 04545; code[001474] = &L01474;
  core[001475] = 04303; code[001475] = &I01475;
  core[001476] = 04543; code[001476] = &I01476;
  core[001477] = 07402; code[001477] = &I01477;
  core[001500] = 04544; code[001500] = &L01500;
  core[001501] = 05232; code[001501] = &I01501;
  core[001502] = 05231; code[001502] = &I01502;
  core[001503] = 00000; code[001503] = &S01503;
  core[001504] = 04534; code[001504] = &I01504;
  core[001505] = 07775; code[001505] = &I01505;
  core[001506] = 07435; code[001506] = &I01506;
  core[001507] = 07440; code[001507] = &I01507;
  core[001510] = 07443; code[001510] = &I01510;
  core[001511] = 04547; code[001511] = &I01511;
  core[001512] = 04537; code[001512] = &I01512;
  core[001513] = 05703; code[001513] = &I01513;
  core[001571] = 01467; code[001571] = &D01571;
  core[001572] = 01431; code[001572] = &D01572;
  core[001573] = 06042; code[001573] = &P01573;
  core[001574] = 01334; code[001574] = &P01574;
  core[001575] = 01335; code[001575] = &P01575;
  core[001576] = 01333; code[001576] = &D01576;
  core[001577] = 01430; code[001577] = &D01577;
  core[001600] = 04216; code[001600] = &P01600;
  core[001601] = 04552; code[001601] = &L01601;
  core[001602] = 04551; code[001602] = &L01602;
  core[001603] = 01024; code[001603] = &I01603;
  core[001604] = 03207; code[001604] = &I01604;
  core[001605] = 01022; code[001605] = &I01605;
  core[001606] = 07413; code[001606] = &I01606;
  core[001607] = 00000; code[001607] = &D01607;
  core[001610] = 04541; code[001610] = &I01610;
  core[001611] = 04777; code[001611] = &I01611;
  core[001612] = 04452; code[001612] = &I01612;
  core[001613] = 07773; code[001613] = &I01613;
  core[001614] = 05226; code[001614] = &I01614;
  core[001615] = 05232; code[001615] = &I01615;
  core[001616] = 00000; code[001616] = &S01616;
  core[001617] = 04540; code[001617] = &I01617;
  core[001620] = 01376; code[001620] = &I01620;
  core[001621] = 03056; code[001621] = &I01621;
  core[001622] = 01375; code[001622] = &I01622;
  core[001623] = 03057; code[001623] = &I01623;
  core[001624] = 04535; code[001624] = &I01624;
  core[001625] = 05616; code[001625] = &I01625;
  core[001626] = 04545; code[001626] = &L01626;
  core[001627] = 04235; code[001627] = &I01627;
  core[001630] = 04543; code[001630] = &I01630;
  core[001631] = 07402; code[001631] = &I01631;
  core[001632] = 04544; code[001632] = &L01632;
  core[001633] = 05202; code[001633] = &I01633;
  core[001634] = 05201; code[001634] = &I01634;
  core[001635] = 00000; code[001635] = &S01635;
  core[001636] = 04534; code[001636] = &I01636;
  core[001637] = 07775; code[001637] = &I01637;
  core[001640] = 07435; code[001640] = &I01640;
  core[001641] = 07440; code[001641] = &I01641;
  core[001642] = 07445; code[001642] = &I01642;
  core[001643] = 04547; code[001643] = &I01643;
  core[001644] = 04537; code[001644] = &I01644;
  core[001645] = 05635; code[001645] = &I01645;
  core[001646] = 04272; code[001646] = &P01646;
  core[001647] = 04542; code[001647] = &P01647;
  core[001650] = 01065; code[001650] = &L01650;
  core[001651] = 04774; code[001651] = &I01651;
  core[001652] = 03022; code[001652] = &I01652;
  core[001653] = 03023; code[001653] = &I01653;
  core[001654] = 01263; code[001654] = &I01654;
  core[001655] = 03024; code[001655] = &I01655;
  core[001656] = 07331; code[001656] = &I01656;
  core[001657] = 03021; code[001657] = &I01657;
  core[001660] = 07421; code[001660] = &I01660;
  core[001661] = 01022; code[001661] = &I01661;
  core[001662] = 07417; code[001662] = &I01662;
  core[001663] = 00000; code[001663] = &D01663;
  core[001664] = 04541; code[001664] = &I01664;
  core[001665] = 04773; code[001665] = &I01665;
  core[001666] = 04452; code[001666] = &I01666;
  core[001667] = 07773; code[001667] = &I01667;
  core[001670] = 05313; code[001670] = &I01670;
  core[001671] = 05317; code[001671] = &I01671;
  core[001672] = 00000; code[001672] = &S01672;
  core[001673] = 04540; code[001673] = &I01673;
  core[001674] = 03065; code[001674] = &I01674;
  core[001675] = 03263; code[001675] = &I01675;
  core[001676] = 01372; code[001676] = &I01676;
  core[001677] = 03056; code[001677] = &I01677;
  core[001700] = 01371; code[001700] = &I01700;
  core[001701] = 03057; code[001701] = &I01701;
  core[001702] = 01174; code[001702] = &I01702;
  core[001703] = 03114; code[001703] = &I01703;
  core[001704] = 04535; code[001704] = &I01704;
  core[001705] = 05672; code[001705] = &I01705;
  core[001706] = 02263; code[001706] = &P01706;
  core[001707] = 02114; code[001707] = &I01707;
  core[001710] = 05247; code[001710] = &I01710;
  core[001711] = 05712; code[001711] = &I01711;
  core[001712] = 02000; code[001712] = &P01712;
  core[001713] = 04545; code[001713] = &L01713;
  core[001714] = 04322; code[001714] = &I01714;
  core[001715] = 04543; code[001715] = &I01715;
  core[001716] = 07402; code[001716] = &I01716;
  core[001717] = 04544; code[001717] = &L01717;
  core[001720] = 05250; code[001720] = &I01720;
  core[001721] = 05247; code[001721] = &I01721;
  core[001722] = 00000; code[001722] = &S01722;
  core[001723] = 04534; code[001723] = &I01723;
  core[001724] = 07775; code[001724] = &I01724;
  core[001725] = 07453; code[001725] = &I01725;
  core[001726] = 07440; code[001726] = &I01726;
  core[001727] = 07443; code[001727] = &I01727;
  core[001730] = 04547; code[001730] = &I01730;
  core[001731] = 04537; code[001731] = &I01731;
  core[001732] = 05722; code[001732] = &I01732;
  core[001771] = 01706; code[001771] = &D01771;
  core[001772] = 01647; code[001772] = &D01772;
  core[001773] = 06120; code[001773] = &P01773;
  core[001774] = 06473; code[001774] = &P01774;
  core[001775] = 01646; code[001775] = &D01775;
  core[001776] = 01600; code[001776] = &D01776;
  core[001777] = 06042; code[001777] = &P01777;
  core[002000] = 04216; code[002000] = &L02000;
  core[002001] = 04552; code[002001] = &L02001;
  core[002002] = 04551; code[002002] = &L02002;
  core[002003] = 01024; code[002003] = &I02003;
  core[002004] = 03207; code[002004] = &I02004;
  core[002005] = 01022; code[002005] = &I02005;
  core[002006] = 07417; code[002006] = &I02006;
  core[002007] = 00000; code[002007] = &D02007;
  core[002010] = 04541; code[002010] = &I02010;
  core[002011] = 04777; code[002011] = &I02011;
  core[002012] = 04452; code[002012] = &I02012;
  core[002013] = 07773; code[002013] = &I02013;
  core[002014] = 05226; code[002014] = &I02014;
  core[002015] = 05232; code[002015] = &I02015;
  core[002016] = 00000; code[002016] = &S02016;
  core[002017] = 04540; code[002017] = &I02017;
  core[002020] = 01376; code[002020] = &I02020;
  core[002021] = 03056; code[002021] = &I02021;
  core[002022] = 01375; code[002022] = &I02022;
  core[002023] = 03057; code[002023] = &I02023;
  core[002024] = 04535; code[002024] = &I02024;
  core[002025] = 05616; code[002025] = &I02025;
  core[002026] = 04545; code[002026] = &L02026;
  core[002027] = 04235; code[002027] = &I02027;
  core[002030] = 04543; code[002030] = &I02030;
  core[002031] = 07402; code[002031] = &I02031;
  core[002032] = 04544; code[002032] = &L02032;
  core[002033] = 05202; code[002033] = &I02033;
  core[002034] = 05201; code[002034] = &I02034;
  core[002035] = 00000; code[002035] = &S02035;
  core[002036] = 04534; code[002036] = &I02036;
  core[002037] = 07775; code[002037] = &I02037;
  core[002040] = 07453; code[002040] = &I02040;
  core[002041] = 07440; code[002041] = &I02041;
  core[002042] = 07445; code[002042] = &I02042;
  core[002043] = 04547; code[002043] = &I02043;
  core[002044] = 04537; code[002044] = &I02044;
  core[002045] = 05635; code[002045] = &I02045;
  core[002046] = 04272; code[002046] = &I02046;
  core[002047] = 04542; code[002047] = &L02047;
  core[002050] = 01065; code[002050] = &L02050;
  core[002051] = 04774; code[002051] = &I02051;
  core[002052] = 03022; code[002052] = &I02052;
  core[002053] = 03023; code[002053] = &I02053;
  core[002054] = 01263; code[002054] = &I02054;
  core[002055] = 03024; code[002055] = &I02055;
  core[002056] = 07331; code[002056] = &I02056;
  core[002057] = 03021; code[002057] = &I02057;
  core[002060] = 07421; code[002060] = &I02060;
  core[002061] = 01022; code[002061] = &I02061;
  core[002062] = 07415; code[002062] = &I02062;
  core[002063] = 00000; code[002063] = &D02063;
  core[002064] = 04541; code[002064] = &I02064;
  core[002065] = 04773; code[002065] = &I02065;
  core[002066] = 04452; code[002066] = &I02066;
  core[002067] = 07773; code[002067] = &I02067;
  core[002070] = 05313; code[002070] = &I02070;
  core[002071] = 05317; code[002071] = &I02071;
  core[002072] = 00000; code[002072] = &S02072;
  core[002073] = 04540; code[002073] = &I02073;
  core[002074] = 03065; code[002074] = &I02074;
  core[002075] = 03263; code[002075] = &I02075;
  core[002076] = 01372; code[002076] = &I02076;
  core[002077] = 03056; code[002077] = &I02077;
  core[002100] = 01371; code[002100] = &I02100;
  core[002101] = 03057; code[002101] = &I02101;
  core[002102] = 01174; code[002102] = &I02102;
  core[002103] = 03114; code[002103] = &I02103;
  core[002104] = 04535; code[002104] = &I02104;
  core[002105] = 05672; code[002105] = &I02105;
  core[002106] = 02263; code[002106] = &I02106;
  core[002107] = 02114; code[002107] = &I02107;
  core[002110] = 05247; code[002110] = &I02110;
  core[002111] = 05712; code[002111] = &I02111;
  core[002112] = 02200; code[002112] = &P02112;
  core[002113] = 04545; code[002113] = &L02113;
  core[002114] = 04322; code[002114] = &I02114;
  core[002115] = 04543; code[002115] = &I02115;
  core[002116] = 07402; code[002116] = &I02116;
  core[002117] = 04544; code[002117] = &L02117;
  core[002120] = 05250; code[002120] = &I02120;
  core[002121] = 05247; code[002121] = &I02121;
  core[002122] = 00000; code[002122] = &S02122;
  core[002123] = 04534; code[002123] = &I02123;
  core[002124] = 07775; code[002124] = &I02124;
  core[002125] = 07462; code[002125] = &I02125;
  core[002126] = 07440; code[002126] = &I02126;
  core[002127] = 07443; code[002127] = &I02127;
  core[002130] = 04547; code[002130] = &I02130;
  core[002131] = 04537; code[002131] = &I02131;
  core[002132] = 05722; code[002132] = &I02132;
  core[002171] = 02106; code[002171] = &D02171;
  core[002172] = 02047; code[002172] = &D02172;
  core[002173] = 06200; code[002173] = &P02173;
  core[002174] = 06473; code[002174] = &P02174;
  core[002175] = 02046; code[002175] = &D02175;
  core[002176] = 02000; code[002176] = &D02176;
  core[002177] = 06120; code[002177] = &P02177;
  core[002200] = 04216; code[002200] = &L02200;
  core[002201] = 04552; code[002201] = &L02201;
  core[002202] = 04551; code[002202] = &L02202;
  core[002203] = 01024; code[002203] = &I02203;
  core[002204] = 03207; code[002204] = &I02204;
  core[002205] = 01022; code[002205] = &I02205;
  core[002206] = 07415; code[002206] = &I02206;
  core[002207] = 00000; code[002207] = &D02207;
  core[002210] = 04541; code[002210] = &I02210;
  core[002211] = 04777; code[002211] = &I02211;
  core[002212] = 04452; code[002212] = &I02212;
  core[002213] = 07773; code[002213] = &I02213;
  core[002214] = 05226; code[002214] = &I02214;
  core[002215] = 05232; code[002215] = &I02215;
  core[002216] = 00000; code[002216] = &S02216;
  core[002217] = 04540; code[002217] = &I02217;
  core[002220] = 01376; code[002220] = &I02220;
  core[002221] = 03056; code[002221] = &I02221;
  core[002222] = 01375; code[002222] = &I02222;
  core[002223] = 03057; code[002223] = &I02223;
  core[002224] = 04535; code[002224] = &I02224;
  core[002225] = 05616; code[002225] = &I02225;
  core[002226] = 04545; code[002226] = &L02226;
  core[002227] = 04235; code[002227] = &I02227;
  core[002230] = 04543; code[002230] = &I02230;
  core[002231] = 07402; code[002231] = &I02231;
  core[002232] = 04544; code[002232] = &L02232;
  core[002233] = 05202; code[002233] = &I02233;
  core[002234] = 05201; code[002234] = &I02234;
  core[002235] = 00000; code[002235] = &S02235;
  core[002236] = 04534; code[002236] = &I02236;
  core[002237] = 07775; code[002237] = &I02237;
  core[002240] = 07462; code[002240] = &I02240;
  core[002241] = 07440; code[002241] = &I02241;
  core[002242] = 07445; code[002242] = &I02242;
  core[002243] = 04547; code[002243] = &I02243;
  core[002244] = 04537; code[002244] = &I02244;
  core[002245] = 05635; code[002245] = &I02245;
  core[002246] = 04774; code[002246] = &L02246;
  core[002247] = 07320; code[002247] = &I02247;
  core[002250] = 04773; code[002250] = &L02250;
  core[002251] = 07300; code[002251] = &L02251;
  core[002252] = 01044; code[002252] = &I02252;
  core[002253] = 01043; code[002253] = &I02253;
  core[002254] = 07650; code[002254] = &I02254;
  core[002255] = 07430; code[002255] = &I02255;
  core[002256] = 04302; code[002256] = &I02256;
  core[002257] = 04313; code[002257] = &I02257;
  core[002260] = 07331; code[002260] = &I02260;
  core[002261] = 03042; code[002261] = &I02261;
  core[002262] = 01042; code[002262] = &I02262;
  core[002263] = 03021; code[002263] = &D02263;
  core[002264] = 01044; code[002264] = &I02264;
  core[002265] = 07421; code[002265] = &I02265;
  core[002266] = 01043; code[002266] = &I02266;
  core[002267] = 07451; code[002267] = &I02267;
  core[002270] = 00000; code[002270] = &D02270;
  core[002271] = 00000; code[002271] = &D02271;
  core[002272] = 04541; code[002272] = &L02272;
  core[002273] = 04452; code[002273] = &I02273;
  core[002274] = 07775; code[002274] = &I02274;
  core[002275] = 07610; code[002275] = &I02275;
  core[002276] = 05772; code[002276] = &I02276;
  core[002277] = 01371; code[002277] = &I02277;
  core[002300] = 03770; code[002300] = &I02300;
  core[002301] = 05767; code[002301] = &D02301;
  core[002302] = 00000; code[002302] = &S02302;
  core[002303] = 01366; code[002303] = &I02303;
  core[002304] = 03270; code[002304] = &I02304;
  core[002305] = 01364; code[002305] = &I02305;
  core[002306] = 03271; code[002306] = &I02306;
  core[002307] = 01363; code[002307] = &I02307;
  core[002310] = 03770; code[002310] = &I02310;
  core[002311] = 02302; code[002311] = &D02311;
  core[002312] = 05702; code[002312] = &I02312;
  core[002313] = 00000; code[002313] = &S02313;
  core[002314] = 01366; code[002314] = &I02314;
  core[002315] = 03271; code[002315] = &I02315;
  core[002316] = 01364; code[002316] = &I02316;
  core[002317] = 03270; code[002317] = &I02317;
  core[002320] = 01362; code[002320] = &I02320;
  core[002321] = 03770; code[002321] = &I02321;
  core[002322] = 05713; code[002322] = &I02322;
  core[002362] = 07554; code[002362] = &D02362;
  core[002363] = 07545; code[002363] = &D02363;
  core[002364] = 05765; code[002364] = &D02364;
  core[002365] = 02512; code[002365] = &P02365;
  core[002366] = 05272; code[002366] = &D02366;
  core[002367] = 02513; code[002367] = &P02367;
  core[002370] = 05544; code[002370] = &P02370;
  core[002371] = 07565; code[002371] = &D02371;
  core[002372] = 02517; code[002372] = &P02372;
  core[002373] = 02476; code[002373] = &P02373;
  core[002374] = 02400; code[002374] = &P02374;
  core[002375] = 02246; code[002375] = &D02375;
  core[002376] = 02200; code[002376] = &D02376;
  core[002377] = 06200; code[002377] = &P02377;
  core[002400] = 00000; code[002400] = &S02400;
  core[002401] = 04540; code[002401] = &I02401;
  core[002402] = 01377; code[002402] = &I02402;
  core[002403] = 03056; code[002403] = &I02403;
  core[002404] = 01376; code[002404] = &I02404;
  core[002405] = 03057; code[002405] = &I02405;
  core[002406] = 01775; code[002406] = &I02406;
  core[002407] = 03774; code[002407] = &I02407;
  core[002410] = 07344; code[002410] = &I02410;
  core[002411] = 03273; code[002411] = &I02411;
  core[002412] = 07344; code[002412] = &I02412;
  core[002413] = 03274; code[002413] = &I02413;
  core[002414] = 07344; code[002414] = &I02414;
  core[002415] = 03275; code[002415] = &I02415;
  core[002416] = 01373; code[002416] = &I02416;
  core[002417] = 03114; code[002417] = &I02417;
  core[002420] = 04535; code[002420] = &I02420;
  core[002421] = 01115; code[002421] = &I02421;
  core[002422] = 07700; code[002422] = &I02422;
  core[002423] = 05264; code[002423] = &I02423;
  core[002424] = 07403; code[002424] = &I02424;
  core[002425] = 05600; code[002425] = &I02425;
  core[002426] = 02114; code[002426] = &L02426;
  core[002427] = 05772; code[002427] = &I02427;
  core[002430] = 07340; code[002430] = &I02430;
  core[002431] = 03114; code[002431] = &I02431;
  core[002432] = 07240; code[002432] = &I02432;
  core[002433] = 03043; code[002433] = &I02433;
  core[002434] = 03044; code[002434] = &I02434;
  core[002435] = 02273; code[002435] = &I02435;
  core[002436] = 05772; code[002436] = &I02436;
  core[002437] = 07240; code[002437] = &I02437;
  core[002440] = 03114; code[002440] = &I02440;
  core[002441] = 07240; code[002441] = &I02441;
  core[002442] = 03273; code[002442] = &I02442;
  core[002443] = 07240; code[002443] = &I02443;
  core[002444] = 03044; code[002444] = &I02444;
  core[002445] = 03043; code[002445] = &I02445;
  core[002446] = 02274; code[002446] = &D02446;
  core[002447] = 05772; code[002447] = &I02447;
  core[002450] = 07240; code[002450] = &D02450;
  core[002451] = 03114; code[002451] = &D02451;
  core[002452] = 07040; code[002452] = &I02452;
  core[002453] = 03273; code[002453] = &I02453;
  core[002454] = 07040; code[002454] = &I02454;
  core[002455] = 03274; code[002455] = &I02455;
  core[002456] = 07040; code[002456] = &I02456;
  core[002457] = 03044; code[002457] = &I02457;
  core[002460] = 07040; code[002460] = &I02460;
  core[002461] = 03043; code[002461] = &I02461;
  core[002462] = 02275; code[002462] = &I02462;
  core[002463] = 05772; code[002463] = &I02463;
  core[002464] = 07604; code[002464] = &L02464;
  core[002465] = 07006; code[002465] = &I02465;
  core[002466] = 07004; code[002466] = &I02466;
  core[002467] = 07710; code[002467] = &I02467;
  core[002470] = 05777; code[002470] = &I02470;
  core[002471] = 05672; code[002471] = &I02471;
  core[002472] = 02600; code[002472] = &P02472;
  core[002473] = 00000; code[002473] = &D02473;
  core[002474] = 00000; code[002474] = &D02474;
  core[002475] = 00000; code[002475] = &D02475;
  core[002476] = 00000; code[002476] = &D02476;
  core[002477] = 01044; code[002477] = &I02477;
  core[002500] = 07004; code[002500] = &I02500;
  core[002501] = 03044; code[002501] = &I02501;
  core[002502] = 01043; code[002502] = &I02502;
  core[002503] = 07004; code[002503] = &I02503;
  core[002504] = 03043; code[002504] = &I02504;
  core[002505] = 01043; code[002505] = &I02505;
  core[002506] = 03022; code[002506] = &I02506;
  core[002507] = 01044; code[002507] = &I02507;
  core[002510] = 03023; code[002510] = &I02510;
  core[002511] = 05226; code[002511] = &I02511;
  core[002512] = 04541; code[002512] = &L02512;
  core[002513] = 04545; code[002513] = &L02513;
  core[002514] = 04323; code[002514] = &I02514;
  core[002515] = 04543; code[002515] = &I02515;
  core[002516] = 07402; code[002516] = &I02516;
  core[002517] = 04544; code[002517] = &L02517;
  core[002520] = 05772; code[002520] = &I02520;
  core[002521] = 07100; code[002521] = &I02521;
  core[002522] = 05771; code[002522] = &I02522;
  core[002523] = 00000; code[002523] = &S02523;
  core[002524] = 04534; code[002524] = &I02524;
  core[002525] = 07775; code[002525] = &I02525;
  core[002526] = 07465; code[002526] = &I02526;
  core[002527] = 07440; code[002527] = &I02527;
  core[002530] = 07443; code[002530] = &I02530;
  core[002531] = 04537; code[002531] = &I02531;
  core[002532] = 05723; code[002532] = &I02532;
  core[002571] = 02250; code[002571] = &P02571;
  core[002572] = 02251; code[002572] = &P02572;
  core[002573] = 07746; code[002573] = &D02573;
  core[002574] = 07002; code[002574] = &P02574;
  core[002575] = 07045; code[002575] = &P02575;
  core[002576] = 02426; code[002576] = &D02576;
  core[002577] = 02246; code[002577] = &P02577;
  core[002600] = 04221; code[002600] = &L02600;
  core[002601] = 04542; code[002601] = &P02601;
  core[002602] = 07240; code[002602] = &L02602;
  core[002603] = 03022; code[002603] = &I02603;
  core[002604] = 03021; code[002604] = &I02604;
  core[002605] = 01065; code[002605] = &I02605;
  core[002606] = 07421; code[002606] = &I02606;
  core[002607] = 07701; code[002607] = &I02607;
  core[002610] = 03023; code[002610] = &I02610;
  core[002611] = 07240; code[002611] = &I02611;
  core[002612] = 07573; code[002612] = &I02612;
  core[002613] = 04541; code[002613] = &I02613;
  core[002614] = 04777; code[002614] = &I02614;
  core[002615] = 04452; code[002615] = &I02615;
  core[002616] = 07775; code[002616] = &I02616;
  core[002617] = 05234; code[002617] = &I02617;
  core[002620] = 05240; code[002620] = &I02620;
  core[002621] = 00000; code[002621] = &S02621;
  core[002622] = 04540; code[002622] = &I02622;
  core[002623] = 03065; code[002623] = &I02623;
  core[002624] = 01376; code[002624] = &I02624;
  core[002625] = 03056; code[002625] = &I02625;
  core[002626] = 01375; code[002626] = &I02626;
  core[002627] = 03057; code[002627] = &I02627;
  core[002630] = 04535; code[002630] = &I02630;
  core[002631] = 04536; code[002631] = &I02631;
  core[002632] = 07403; code[002632] = &I02632;
  core[002633] = 05621; code[002633] = &I02633;
  core[002634] = 04545; code[002634] = &L02634;
  core[002635] = 04243; code[002635] = &I02635;
  core[002636] = 04543; code[002636] = &I02636;
  core[002637] = 07402; code[002637] = &I02637;
  core[002640] = 04544; code[002640] = &L02640;
  core[002641] = 05202; code[002641] = &I02641;
  core[002642] = 05201; code[002642] = &I02642;
  core[002643] = 00000; code[002643] = &S02643;
  core[002644] = 04534; code[002644] = &I02644;
  core[002645] = 07775; code[002645] = &I02645;
  core[002646] = 07470; code[002646] = &I02646;
  core[002647] = 07440; code[002647] = &I02647;
  core[002650] = 07443; code[002650] = &I02650;
  core[002651] = 04537; code[002651] = &I02651;
  core[002652] = 05643; code[002652] = &I02652;
  core[002653] = 04267; code[002653] = &P02653;
  core[002654] = 04552; code[002654] = &L02654;
  core[002655] = 04556; code[002655] = &L02655;
  core[002656] = 04551; code[002656] = &I02656;
  core[002657] = 01022; code[002657] = &I02657;
  core[002660] = 07573; code[002660] = &I02660;
  core[002661] = 04541; code[002661] = &I02661;
  core[002662] = 04777; code[002662] = &I02662;
  core[002663] = 04452; code[002663] = &I02663;
  core[002664] = 07773; code[002664] = &I02664;
  core[002665] = 05300; code[002665] = &I02665;
  core[002666] = 05304; code[002666] = &I02666;
  core[002667] = 00000; code[002667] = &S02667;
  core[002670] = 04540; code[002670] = &I02670;
  core[002671] = 01375; code[002671] = &I02671;
  core[002672] = 03056; code[002672] = &I02672;
  core[002673] = 01374; code[002673] = &I02673;
  core[002674] = 03057; code[002674] = &I02674;
  core[002675] = 04535; code[002675] = &I02675;
  core[002676] = 04536; code[002676] = &I02676;
  core[002677] = 05667; code[002677] = &I02677;
  core[002700] = 04545; code[002700] = &L02700;
  core[002701] = 04307; code[002701] = &I02701;
  core[002702] = 04543; code[002702] = &I02702;
  core[002703] = 07402; code[002703] = &I02703;
  core[002704] = 04544; code[002704] = &L02704;
  core[002705] = 05255; code[002705] = &I02705;
  core[002706] = 05254; code[002706] = &I02706;
  core[002707] = 00000; code[002707] = &S02707;
  core[002710] = 04534; code[002710] = &I02710;
  core[002711] = 07775; code[002711] = &I02711;
  core[002712] = 07470; code[002712] = &I02712;
  core[002713] = 07440; code[002713] = &I02713;
  core[002714] = 07445; code[002714] = &I02714;
  core[002715] = 04537; code[002715] = &I02715;
  core[002716] = 05707; code[002716] = &I02716;
  core[002717] = 04773; code[002717] = &P02717;
  core[002720] = 04552; code[002720] = &L02720;
  core[002721] = 04556; code[002721] = &L02721;
  core[002722] = 04551; code[002722] = &I02722;
  core[002723] = 01022; code[002723] = &I02723;
  core[002724] = 07575; code[002724] = &I02724;
  core[002725] = 04541; code[002725] = &I02725;
  core[002726] = 04772; code[002726] = &I02726;
  core[002727] = 04452; code[002727] = &I02727;
  core[002730] = 07775; code[002730] = &I02730;
  core[002731] = 05771; code[002731] = &I02731;
  core[002732] = 05770; code[002732] = &I02732;
  core[002770] = 03015; code[002770] = &P02770;
  core[002771] = 03011; code[002771] = &P02771;
  core[002772] = 06311; code[002772] = &P02772;
  core[002773] = 03000; code[002773] = &P02773;
  core[002774] = 02717; code[002774] = &D02774;
  core[002775] = 02653; code[002775] = &D02775;
  core[002776] = 02601; code[002776] = &D02776;
  core[002777] = 06273; code[002777] = &P02777;
  core[003000] = 00000; code[003000] = &S03000;
  core[003001] = 04540; code[003001] = &I03001;
  core[003002] = 01377; code[003002] = &I03002;
  core[003003] = 03056; code[003003] = &I03003;
  core[003004] = 01376; code[003004] = &I03004;
  core[003005] = 03057; code[003005] = &I03005;
  core[003006] = 04535; code[003006] = &I03006;
  core[003007] = 04536; code[003007] = &I03007;
  core[003010] = 05600; code[003010] = &I03010;
  core[003011] = 04545; code[003011] = &L03011;
  core[003012] = 04220; code[003012] = &I03012;
  core[003013] = 04543; code[003013] = &I03013;
  core[003014] = 07402; code[003014] = &I03014;
  core[003015] = 04544; code[003015] = &L03015;
  core[003016] = 05775; code[003016] = &I03016;
  core[003017] = 05774; code[003017] = &I03017;
  core[003020] = 00000; code[003020] = &S03020;
  core[003021] = 04534; code[003021] = &I03021;
  core[003022] = 07775; code[003022] = &I03022;
  core[003023] = 07473; code[003023] = &I03023;
  core[003024] = 07440; code[003024] = &D03024;
  core[003025] = 07443; code[003025] = &I03025;
  core[003026] = 04537; code[003026] = &I03026;
  core[003027] = 05620; code[003027] = &I03027;
  core[003030] = 04267; code[003030] = &I03030;
  core[003031] = 04253; code[003031] = &L03031;
  core[003032] = 01021; code[003032] = &L03032;
  core[003033] = 07104; code[003033] = &I03033;
  core[003034] = 01023; code[003034] = &I03034;
  core[003035] = 07421; code[003035] = &I03035;
  core[003036] = 01024; code[003036] = &I03036;
  core[003037] = 03122; code[003037] = &I03037;
  core[003040] = 01025; code[003040] = &I03040;
  core[003041] = 03121; code[003041] = &I03041;
  core[003042] = 01022; code[003042] = &I03042;
  core[003043] = 07443; code[003043] = &I03043;
  core[003044] = 00121; code[003044] = &I03044;
  core[003045] = 04541; code[003045] = &I03045;
  core[003046] = 04773; code[003046] = &I03046;
  core[003047] = 04452; code[003047] = &I03047;
  core[003050] = 07775; code[003050] = &I03050;
  core[003051] = 05307; code[003051] = &I03051;
  core[003052] = 05325; code[003052] = &I03052;
  core[003053] = 00000; code[003053] = &S03053;
  core[003054] = 04453; code[003054] = &I03054;
  core[003055] = 00000; code[003055] = &D03055;
  core[003056] = 00021; code[003056] = &I03056;
  core[003057] = 07773; code[003057] = &I03057;
  core[003060] = 07326; code[003060] = &I03060;
  core[003061] = 07124; code[003061] = &I03061;
  core[003062] = 01255; code[003062] = &I03062;
  core[003063] = 03255; code[003063] = &I03063;
  core[003064] = 02114; code[003064] = &D03064;
  core[003065] = 05653; code[003065] = &I03065;
  core[003066] = 05575; code[003066] = &I03066;
  core[003067] = 00000; code[003067] = &S03067;
  core[003070] = 04540; code[003070] = &I03070;
  core[003071] = 01372; code[003071] = &I03071;
  core[003072] = 03255; code[003072] = &I03072;
  core[003073] = 01376; code[003073] = &I03073;
  core[003074] = 03056; code[003074] = &I03074;
  core[003075] = 01371; code[003075] = &I03075;
  core[003076] = 03057; code[003076] = &I03076;
  core[003077] = 01370; code[003077] = &I03077;
  core[003100] = 03114; code[003100] = &I03100;
  core[003101] = 01767; code[003101] = &I03101;
  core[003102] = 03766; code[003102] = &I03102;
  core[003103] = 04535; code[003103] = &I03103;
  core[003104] = 04536; code[003104] = &I03104;
  core[003105] = 07403; code[003105] = &I03105;
  core[003106] = 05667; code[003106] = &I03106;
  core[003107] = 01024; code[003107] = &L03107;
  core[003110] = 03040; code[003110] = &I03110;
  core[003111] = 01025; code[003111] = &I03111;
  core[003112] = 03041; code[003112] = &I03112;
  core[003113] = 03024; code[003113] = &I03113;
  core[003114] = 03025; code[003114] = &I03114;
  core[003115] = 04545; code[003115] = &I03115;
  core[003116] = 04330; code[003116] = &I03116;
  core[003117] = 01040; code[003117] = &P03117;
  core[003120] = 03024; code[003120] = &P03120;
  core[003121] = 01041; code[003121] = &P03121;
  core[003122] = 03025; code[003122] = &I03122;
  core[003123] = 04543; code[003123] = &I03123;
  core[003124] = 07402; code[003124] = &I03124;
  core[003125] = 04544; code[003125] = &L03125;
  core[003126] = 05232; code[003126] = &I03126;
  core[003127] = 05231; code[003127] = &I03127;
  core[003130] = 00000; code[003130] = &S03130;
  core[003131] = 04534; code[003131] = &I03131;
  core[003132] = 07775; code[003132] = &I03132;
  core[003133] = 07476; code[003133] = &I03133;
  core[003134] = 07440; code[003134] = &I03134;
  core[003135] = 07443; code[003135] = &I03135;
  core[003136] = 04537; code[003136] = &I03136;
  core[003137] = 05730; code[003137] = &I03137;
  core[003166] = 07016; code[003166] = &P03166;
  core[003167] = 07044; code[003167] = &P03167;
  core[003170] = 07767; code[003170] = &D03170;
  core[003171] = 03200; code[003171] = &D03171;
  core[003172] = 07327; code[003172] = &D03172;
  core[003173] = 06332; code[003173] = &P03173;
  core[003174] = 02720; code[003174] = &P03174;
  core[003175] = 02721; code[003175] = &P03175;
  core[003176] = 03030; code[003176] = &D03176;
  core[003177] = 02717; code[003177] = &D03177;
  core[003200] = 04223; code[003200] = &D03200;
  core[003201] = 04241; code[003201] = &L03201;
  core[003202] = 01021; code[003202] = &L03202;
  core[003203] = 07104; code[003203] = &I03203;
  core[003204] = 01023; code[003204] = &I03204;
  core[003205] = 07421; code[003205] = &I03205;
  core[003206] = 01024; code[003206] = &I03206;
  core[003207] = 03122; code[003207] = &I03207;
  core[003210] = 01025; code[003210] = &I03210;
  core[003211] = 03121; code[003211] = &I03211;
  core[003212] = 01022; code[003212] = &I03212;
  core[003213] = 07443; code[003213] = &I03213;
  core[003214] = 00121; code[003214] = &I03214;
  core[003215] = 04541; code[003215] = &I03215;
  core[003216] = 04777; code[003216] = &I03216;
  core[003217] = 04452; code[003217] = &I03217;
  core[003220] = 07775; code[003220] = &I03220;
  core[003221] = 05257; code[003221] = &I03221;
  core[003222] = 05275; code[003222] = &I03222;
  core[003223] = 00000; code[003223] = &S03223;
  core[003224] = 04540; code[003224] = &I03224;
  core[003225] = 01376; code[003225] = &I03225;
  core[003226] = 03056; code[003226] = &I03226;
  core[003227] = 01375; code[003227] = &I03227;
  core[003230] = 03057; code[003230] = &I03230;
  core[003231] = 01774; code[003231] = &I03231;
  core[003232] = 03773; code[003232] = &I03232;
  core[003233] = 03045; code[003233] = &I03233;
  core[003234] = 03046; code[003234] = &I03234;
  core[003235] = 04535; code[003235] = &I03235;
  core[003236] = 04536; code[003236] = &I03236;
  core[003237] = 07403; code[003237] = &I03237;
  core[003240] = 05623; code[003240] = &I03240;
  core[003241] = 00000; code[003241] = &S03241;
  core[003242] = 04772; code[003242] = &I03242;
  core[003243] = 03022; code[003243] = &I03243;
  core[003244] = 04772; code[003244] = &I03244;
  core[003245] = 03023; code[003245] = &I03245;
  core[003246] = 04772; code[003246] = &I03246;
  core[003247] = 03024; code[003247] = &I03247;
  core[003250] = 04772; code[003250] = &I03250;
  core[003251] = 03025; code[003251] = &I03251;
  core[003252] = 07210; code[003252] = &I03252;
  core[003253] = 03021; code[003253] = &I03253;
  core[003254] = 04573; code[003254] = &I03254;
  core[003255] = 05641; code[003255] = &I03255;
  core[003256] = 05575; code[003256] = &I03256;
  core[003257] = 01024; code[003257] = &L03257;
  core[003260] = 03040; code[003260] = &I03260;
  core[003261] = 01025; code[003261] = &I03261;
  core[003262] = 03041; code[003262] = &I03262;
  core[003263] = 03024; code[003263] = &I03263;
  core[003264] = 03025; code[003264] = &I03264;
  core[003265] = 04545; code[003265] = &I03265;
  core[003266] = 04300; code[003266] = &I03266;
  core[003267] = 01040; code[003267] = &I03267;
  core[003270] = 03024; code[003270] = &I03270;
  core[003271] = 01041; code[003271] = &I03271;
  core[003272] = 03025; code[003272] = &I03272;
  core[003273] = 04543; code[003273] = &I03273;
  core[003274] = 07402; code[003274] = &I03274;
  core[003275] = 04544; code[003275] = &L03275;
  core[003276] = 05202; code[003276] = &I03276;
  core[003277] = 05201; code[003277] = &I03277;
  core[003300] = 00000; code[003300] = &S03300;
  core[003301] = 04534; code[003301] = &I03301;
  core[003302] = 07775; code[003302] = &I03302;
  core[003303] = 07476; code[003303] = &I03303;
  core[003304] = 07440; code[003304] = &I03304;
  core[003305] = 07445; code[003305] = &I03305;
  core[003306] = 04537; code[003306] = &I03306;
  core[003307] = 05700; code[003307] = &I03307;
  core[003310] = 04771; code[003310] = &D03310;
  core[003311] = 04770; code[003311] = &L03311;
  core[003312] = 01042; code[003312] = &L03312;
  core[003313] = 07104; code[003313] = &I03313;
  core[003314] = 01044; code[003314] = &I03314;
  core[003315] = 07421; code[003315] = &I03315;
  core[003316] = 01043; code[003316] = &I03316;
  core[003317] = 07445; code[003317] = &I03317;
  core[003320] = 00121; code[003320] = &I03320;
  core[003321] = 04541; code[003321] = &I03321;
  core[003322] = 01121; code[003322] = &I03322;
  core[003323] = 03037; code[003323] = &I03323;
  core[003324] = 01122; code[003324] = &I03324;
  core[003325] = 03036; code[003325] = &I03325;
  core[003326] = 04452; code[003326] = &I03326;
  core[003327] = 07775; code[003327] = &I03327;
  core[003330] = 05767; code[003330] = &I03330;
  core[003331] = 01044; code[003331] = &D03331;
  core[003332] = 07421; code[003332] = &D03332;
  core[003333] = 01043; code[003333] = &I03333;
  core[003334] = 07575; code[003334] = &I03334;
  core[003335] = 07443; code[003335] = &I03335;
  core[003336] = 00121; code[003336] = &I03336;
  core[003337] = 07451; code[003337] = &D03337;
  core[003340] = 05767; code[003340] = &I03340;
  core[003341] = 05766; code[003341] = &I03341;
  core[003366] = 03435; code[003366] = &P03366;
  core[003367] = 03431; code[003367] = &P03367;
  core[003370] = 03400; code[003370] = &P03370;
  core[003371] = 03413; code[003371] = &P03371;
  core[003372] = 06525; code[003372] = &P03372;
  core[003373] = 07016; code[003373] = &P03373;
  core[003374] = 07044; code[003374] = &P03374;
  core[003375] = 03310; code[003375] = &D03375;
  core[003376] = 03200; code[003376] = &D03376;
  core[003377] = 06332; code[003377] = &P03377;
  core[003400] = 00000; code[003400] = &S03400;
  core[003401] = 04453; code[003401] = &I03401;
  core[003402] = 00000; code[003402] = &D03402;
  core[003403] = 00042; code[003403] = &I03403;
  core[003404] = 07775; code[003404] = &I03404;
  core[003405] = 07325; code[003405] = &I03405;
  core[003406] = 01202; code[003406] = &I03406;
  core[003407] = 03202; code[003407] = &I03407;
  core[003410] = 02114; code[003410] = &I03410;
  core[003411] = 05600; code[003411] = &I03411;
  core[003412] = 05575; code[003412] = &I03412;
  core[003413] = 00000; code[003413] = &S03413;
  core[003414] = 04540; code[003414] = &I03414;
  core[003415] = 01377; code[003415] = &I03415;
  core[003416] = 03202; code[003416] = &I03416;
  core[003417] = 01376; code[003417] = &I03417;
  core[003420] = 03056; code[003420] = &I03420;
  core[003421] = 01375; code[003421] = &I03421;
  core[003422] = 03057; code[003422] = &I03422;
  core[003423] = 01374; code[003423] = &I03423;
  core[003424] = 03114; code[003424] = &I03424;
  core[003425] = 04535; code[003425] = &I03425;
  core[003426] = 04536; code[003426] = &I03426;
  core[003427] = 07403; code[003427] = &I03427;
  core[003430] = 05613; code[003430] = &I03430;
  core[003431] = 04545; code[003431] = &L03431;
  core[003432] = 04240; code[003432] = &I03432;
  core[003433] = 04543; code[003433] = &I03433;
  core[003434] = 07402; code[003434] = &I03434;
  core[003435] = 04544; code[003435] = &L03435;
  core[003436] = 05773; code[003436] = &I03436;
  core[003437] = 05772; code[003437] = &I03437;
  core[003440] = 00000; code[003440] = &S03440;
  core[003441] = 04534; code[003441] = &I03441;
  core[003442] = 07775; code[003442] = &I03442;
  core[003443] = 07501; code[003443] = &I03443;
  core[003444] = 07440; code[003444] = &I03444;
  core[003445] = 07443; code[003445] = &I03445;
  core[003446] = 04771; code[003446] = &I03446;
  core[003447] = 05640; code[003447] = &I03447;
  core[003450] = 04314; code[003450] = &I03450;
  core[003451] = 04302; code[003451] = &L03451;
  core[003452] = 01042; code[003452] = &L03452;
  core[003453] = 07104; code[003453] = &I03453;
  core[003454] = 01044; code[003454] = &I03454;
  core[003455] = 07421; code[003455] = &I03455;
  core[003456] = 01043; code[003456] = &I03456;
  core[003457] = 07445; code[003457] = &I03457;
  core[003460] = 00121; code[003460] = &I03460;
  core[003461] = 04541; code[003461] = &I03461;
  core[003462] = 01121; code[003462] = &I03462;
  core[003463] = 03037; code[003463] = &I03463;
  core[003464] = 01122; code[003464] = &I03464;
  core[003465] = 03036; code[003465] = &I03465;
  core[003466] = 04452; code[003466] = &I03466;
  core[003467] = 07775; code[003467] = &I03467;
  core[003470] = 05326; code[003470] = &I03470;
  core[003471] = 01044; code[003471] = &I03471;
  core[003472] = 07421; code[003472] = &I03472;
  core[003473] = 01043; code[003473] = &I03473;
  core[003474] = 07575; code[003474] = &I03474;
  core[003475] = 07443; code[003475] = &I03475;
  core[003476] = 00121; code[003476] = &I03476;
  core[003477] = 07451; code[003477] = &I03477;
  core[003500] = 05326; code[003500] = &I03500;
  core[003501] = 05332; code[003501] = &I03501;
  core[003502] = 00000; code[003502] = &S03502;
  core[003503] = 04770; code[003503] = &I03503;
  core[003504] = 03043; code[003504] = &I03504;
  core[003505] = 04770; code[003505] = &I03505;
  core[003506] = 03044; code[003506] = &I03506;
  core[003507] = 07010; code[003507] = &I03507;
  core[003510] = 03042; code[003510] = &D03510;
  core[003511] = 04573; code[003511] = &D03511;
  core[003512] = 05702; code[003512] = &D03512;
  core[003513] = 05575; code[003513] = &I03513;
  core[003514] = 00000; code[003514] = &S03514;
  core[003515] = 04540; code[003515] = &I03515;
  core[003516] = 01375; code[003516] = &I03516;
  core[003517] = 03056; code[003517] = &I03517;
  core[003520] = 01367; code[003520] = &I03520;
  core[003521] = 03057; code[003521] = &I03521;
  core[003522] = 04535; code[003522] = &I03522;
  core[003523] = 04536; code[003523] = &I03523;
  core[003524] = 07403; code[003524] = &I03524;
  core[003525] = 05714; code[003525] = &I03525;
  core[003526] = 04545; code[003526] = &L03526;
  core[003527] = 04335; code[003527] = &I03527;
  core[003530] = 04543; code[003530] = &I03530;
  core[003531] = 07402; code[003531] = &I03531;
  core[003532] = 04544; code[003532] = &L03532;
  core[003533] = 05252; code[003533] = &I03533;
  core[003534] = 05251; code[003534] = &I03534;
  core[003535] = 00000; code[003535] = &S03535;
  core[003536] = 04534; code[003536] = &I03536;
  core[003537] = 07775; code[003537] = &I03537;
  core[003540] = 07501; code[003540] = &I03540;
  core[003541] = 07440; code[003541] = &I03541;
  core[003542] = 07445; code[003542] = &I03542;
  core[003543] = 04771; code[003543] = &I03543;
  core[003544] = 05735; code[003544] = &I03544;
  core[003567] = 03600; code[003567] = &D03567;
  core[003570] = 06525; code[003570] = &P03570;
  core[003571] = 07106; code[003571] = &P03571;
  core[003572] = 03311; code[003572] = &P03572;
  core[003573] = 03312; code[003573] = &P03573;
  core[003574] = 07771; code[003574] = &D03574;
  core[003575] = 03450; code[003575] = &D03575;
  core[003576] = 03310; code[003576] = &D03576;
  core[003577] = 07305; code[003577] = &D03577;
  core[003600] = 05257; code[003600] = &L03600;
  core[003601] = 04312; code[003601] = &L03601;
  core[003602] = 07240; code[003602] = &L03602;
  core[003603] = 00305; code[003603] = &I03603;
  core[003604] = 07421; code[003604] = &I03604;
  core[003605] = 07040; code[003605] = &I03605;
  core[003606] = 00304; code[003606] = &I03606;
  core[003607] = 07411; code[003607] = &I03607;
  core[003610] = 03307; code[003610] = &I03610;
  core[003611] = 07501; code[003611] = &I03611;
  core[003612] = 03306; code[003612] = &I03612;
  core[003613] = 07441; code[003613] = &I03613;
  core[003614] = 03300; code[003614] = &I03614;
  core[003615] = 07040; code[003615] = &I03615;
  core[003616] = 00307; code[003616] = &I03616;
  core[003617] = 07140; code[003617] = &I03617;
  core[003620] = 01301; code[003620] = &I03620;
  core[003621] = 07040; code[003621] = &I03621;
  core[003622] = 07440; code[003622] = &I03622;
  core[003623] = 05250; code[003623] = &I03623;
  core[003624] = 07430; code[003624] = &I03624;
  core[003625] = 05250; code[003625] = &I03625;
  core[003626] = 07240; code[003626] = &I03626;
  core[003627] = 00306; code[003627] = &I03627;
  core[003630] = 07440; code[003630] = &I03630;
  core[003631] = 05250; code[003631] = &I03631;
  core[003632] = 07040; code[003632] = &I03632;
  core[003633] = 00300; code[003633] = &I03633;
  core[003634] = 07140; code[003634] = &I03634;
  core[003635] = 01303; code[003635] = &I03635;
  core[003636] = 07040; code[003636] = &I03636;
  core[003637] = 07440; code[003637] = &I03637;
  core[003640] = 05250; code[003640] = &I03640;
  core[003641] = 07430; code[003641] = &I03641;
  core[003642] = 05250; code[003642] = &I03642;
  core[003643] = 07240; code[003643] = &I03643;
  core[003644] = 00303; code[003644] = &I03644;
  core[003645] = 07440; code[003645] = &I03645;
  core[003646] = 05254; code[003646] = &I03646;
  core[003647] = 05272; code[003647] = &I03647;
  core[003650] = 04545; code[003650] = &L03650;
  core[003651] = 04711; code[003651] = &I03651;
  core[003652] = 04543; code[003652] = &I03652;
  core[003653] = 07402; code[003653] = &I03653;
  core[003654] = 04544; code[003654] = &L03654;
  core[003655] = 05202; code[003655] = &I03655;
  core[003656] = 05201; code[003656] = &I03656;
  core[003657] = 07240; code[003657] = &L03657;
  core[003660] = 00327; code[003660] = &I03660;
  core[003661] = 03012; code[003661] = &I03661;
  core[003662] = 07040; code[003662] = &I03662;
  core[003663] = 00330; code[003663] = &I03663;
  core[003664] = 03013; code[003664] = &I03664;
  core[003665] = 07040; code[003665] = &I03665;
  core[003666] = 00302; code[003666] = &I03666;
  core[003667] = 03303; code[003667] = &I03667;
  core[003670] = 04535; code[003670] = &I03670;
  core[003671] = 05201; code[003671] = &I03671;
  core[003672] = 07604; code[003672] = &L03672;
  core[003673] = 07106; code[003673] = &I03673;
  core[003674] = 07006; code[003674] = &I03674;
  core[003675] = 07430; code[003675] = &I03675;
  core[003676] = 05200; code[003676] = &I03676;
  core[003677] = 05710; code[003677] = &I03677;
  core[003700] = 00000; code[003700] = &D03700;
  core[003701] = 06000; code[003701] = &D03701;
  core[003702] = 00027; code[003702] = &D03702;
  core[003703] = 00000; code[003703] = &D03703;
  core[003704] = 00000; code[003704] = &D03704;
  core[003705] = 00000; code[003705] = &D03705;
  core[003706] = 00000; code[003706] = &D03706;
  core[003707] = 00000; code[003707] = &D03707;
  core[003710] = 04200; code[003710] = &P03710;
  core[003711] = 04000; code[003711] = &P03711;
  core[003712] = 00000; code[003712] = &S03712;
  core[003713] = 07240; code[003713] = &I03713;
  core[003714] = 00412; code[003714] = &I03714;
  core[003715] = 03304; code[003715] = &I03715;
  core[003716] = 07040; code[003716] = &D03716;
  core[003717] = 00413; code[003717] = &D03717;
  core[003720] = 03305; code[003720] = &I03720;
  core[003721] = 07040; code[003721] = &I03721;
  core[003722] = 00303; code[003722] = &I03722;
  core[003723] = 07041; code[003723] = &I03723;
  core[003724] = 07040; code[003724] = &I03724;
  core[003725] = 03303; code[003725] = &I03725;
  core[003726] = 05331; code[003726] = &I03726;
  core[003727] = 04060; code[003727] = &D03727;
  core[003730] = 04074; code[003730] = &D03730;
  core[003731] = 07240; code[003731] = &L03731;
  core[003732] = 00303; code[003732] = &I03732;
  core[003733] = 07440; code[003733] = &I03733;
  core[003734] = 05712; code[003734] = &I03734;
  core[003735] = 05272; code[003735] = &I03735;
  core[004000] = 00000; code[004000] = &S04000;
  core[004001] = 04525; code[004001] = &I04001;
  core[004002] = 04326; code[004002] = &I04002;
  core[004003] = 04451; code[004003] = &I04003;
  core[004004] = 07772; code[004004] = &I04004;
  core[004005] = 04777; code[004005] = &I04005;
  core[004006] = 04776; code[004006] = &I04006;
  core[004007] = 04775; code[004007] = &I04007;
  core[004010] = 04774; code[004010] = &I04010;
  core[004011] = 04451; code[004011] = &I04011;
  core[004012] = 07765; code[004012] = &I04012;
  core[004013] = 04777; code[004013] = &I04013;
  core[004014] = 04776; code[004014] = &I04014;
  core[004015] = 04773; code[004015] = &I04015;
  core[004016] = 04774; code[004016] = &I04016;
  core[004017] = 04576; code[004017] = &I04017;
  core[004020] = 04524; code[004020] = &I04020;
  core[004021] = 04451; code[004021] = &I04021;
  core[004022] = 07772; code[004022] = &I04022;
  core[004023] = 01772; code[004023] = &I04023;
  core[004024] = 04771; code[004024] = &I04024;
  core[004025] = 04451; code[004025] = &I04025;
  core[004026] = 07775; code[004026] = &I04026;
  core[004027] = 01770; code[004027] = &I04027;
  core[004030] = 04771; code[004030] = &I04030;
  core[004031] = 04524; code[004031] = &I04031;
  core[004032] = 04767; code[004032] = &I04032;
  core[004033] = 04451; code[004033] = &I04033;
  core[004034] = 07775; code[004034] = &I04034;
  core[004035] = 01766; code[004035] = &I04035;
  core[004036] = 04771; code[004036] = &I04036;
  core[004037] = 04451; code[004037] = &I04037;
  core[004040] = 07775; code[004040] = &I04040;
  core[004041] = 01765; code[004041] = &I04041;
  core[004042] = 04771; code[004042] = &I04042;
  core[004043] = 04524; code[004043] = &I04043;
  core[004044] = 04764; code[004044] = &I04044;
  core[004045] = 04455; code[004045] = &I04045;
  core[004046] = 01763; code[004046] = &I04046;
  core[004047] = 04771; code[004047] = &I04047;
  core[004050] = 04524; code[004050] = &I04050;
  core[004051] = 04762; code[004051] = &I04051;
  core[004052] = 04451; code[004052] = &I04052;
  core[004053] = 07775; code[004053] = &I04053;
  core[004054] = 01761; code[004054] = &I04054;
  core[004055] = 04771; code[004055] = &I04055;
  core[004056] = 04524; code[004056] = &I04056;
  core[004057] = 05600; code[004057] = &I04057;
  core[004060] = 00000; code[004060] = &I04060;
  core[004061] = 07777; code[004061] = &I04061;
  core[004062] = 07777; code[004062] = &I04062;
  core[004063] = 07777; code[004063] = &I04063;
  core[004064] = 07777; code[004064] = &I04064;
  core[004065] = 07777; code[004065] = &I04065;
  core[004066] = 07777; code[004066] = &I04066;
  core[004067] = 07777; code[004067] = &I04067;
  core[004070] = 07777; code[004070] = &I04070;
  core[004071] = 07777; code[004071] = &I04071;
  core[004072] = 07777; code[004072] = &I04072;
  core[004073] = 07777; code[004073] = &I04073;
  core[004074] = 07777; code[004074] = &I04074;
  core[004075] = 07777; code[004075] = &I04075;
  core[004076] = 07776; code[004076] = &I04076;
  core[004077] = 07774; code[004077] = &I04077;
  core[004100] = 07770; code[004100] = &P04100;
  core[004101] = 07760; code[004101] = &I04101;
  core[004102] = 07740; code[004102] = &D04102;
  core[004103] = 07700; code[004103] = &P04103;
  core[004104] = 07600; code[004104] = &P04104;
  core[004105] = 07400; code[004105] = &P04105;
  core[004106] = 07000; code[004106] = &P04106;
  core[004107] = 06000; code[004107] = &P04107;
  core[004110] = 04000; code[004110] = &I04110;
  core[004111] = 00000; code[004111] = &I04111;
  core[004112] = 00000; code[004112] = &I04112;
  core[004113] = 00000; code[004113] = &I04113;
  core[004114] = 00000; code[004114] = &I04114;
  core[004115] = 00000; code[004115] = &I04115;
  core[004116] = 00000; code[004116] = &I04116;
  core[004117] = 00000; code[004117] = &I04117;
  core[004120] = 00000; code[004120] = &I04120;
  core[004121] = 00000; code[004121] = &I04121;
  core[004122] = 00000; code[004122] = &I04122;
  core[004123] = 00000; code[004123] = &D04123;
  core[004124] = 00000; code[004124] = &I04124;
  core[004125] = 00000; code[004125] = &I04125;
  core[004126] = 00000; code[004126] = &S04126;
  core[004127] = 04332; code[004127] = &I04127;
  core[004130] = 04343; code[004130] = &I04130;
  core[004131] = 05726; code[004131] = &I04131;
  core[004132] = 00000; code[004132] = &S04132;
  core[004133] = 07240; code[004133] = &I04133;
  core[004134] = 00760; code[004134] = &I04134;
  core[004135] = 04526; code[004135] = &I04135;
  core[004136] = 01757; code[004136] = &I04136;
  core[004137] = 04526; code[004137] = &I04137;
  core[004140] = 01756; code[004140] = &I04140;
  core[004141] = 04526; code[004141] = &I04141;
  core[004142] = 05732; code[004142] = &I04142;
  core[004143] = 00000; code[004143] = &S04143;
  core[004144] = 07240; code[004144] = &I04144;
  core[004145] = 00755; code[004145] = &I04145;
  core[004146] = 04526; code[004146] = &I04146;
  core[004147] = 05743; code[004147] = &I04147;
  core[004155] = 05477; code[004155] = &P04155;
  core[004156] = 05476; code[004156] = &P04156;
  core[004157] = 05475; code[004157] = &P04157;
  core[004160] = 05474; code[004160] = &P04160;
  core[004161] = 03700; code[004161] = &P04161;
  core[004162] = 05434; code[004162] = &P04162;
  core[004163] = 03703; code[004163] = &P04163;
  core[004164] = 05430; code[004164] = &P04164;
  core[004165] = 03706; code[004165] = &P04165;
  core[004166] = 03707; code[004166] = &P04166;
  core[004167] = 05425; code[004167] = &P04167;
  core[004170] = 03705; code[004170] = &P04170;
  core[004171] = 07200; code[004171] = &P04171;
  core[004172] = 03704; code[004172] = &P04172;
  core[004173] = 00302; code[004173] = &P04173;
  core[004174] = 05467; code[004174] = &P04174;
  core[004175] = 00323; code[004175] = &P04175;
  core[004176] = 05462; code[004176] = &P04176;
  core[004177] = 05455; code[004177] = &P04177;
  core[004200] = 05261; code[004200] = &L04200;
  core[004201] = 04273; code[004201] = &L04201;
  core[004202] = 07240; code[004202] = &L04202;
  core[004203] = 00716; code[004203] = &I04203;
  core[004204] = 07421; code[004204] = &I04204;
  core[004205] = 07240; code[004205] = &I04205;
  core[004206] = 00717; code[004206] = &I04206;
  core[004207] = 07411; code[004207] = &I04207;
  core[004210] = 03725; code[004210] = &I04210;
  core[004211] = 07501; code[004211] = &I04211;
  core[004212] = 03726; code[004212] = &I04212;
  core[004213] = 07441; code[004213] = &I04213;
  core[004214] = 03727; code[004214] = &I04214;
  core[004215] = 07240; code[004215] = &I04215;
  core[004216] = 00725; code[004216] = &D04216;
  core[004217] = 07140; code[004217] = &I04217;
  core[004220] = 01716; code[004220] = &I04220;
  core[004221] = 07040; code[004221] = &I04221;
  core[004222] = 07440; code[004222] = &I04222;
  core[004223] = 05333; code[004223] = &I04223;
  core[004224] = 07430; code[004224] = &I04224;
  core[004225] = 05333; code[004225] = &I04225;
  core[004226] = 07240; code[004226] = &I04226;
  core[004227] = 00726; code[004227] = &I04227;
  core[004230] = 07440; code[004230] = &I04230;
  core[004231] = 05333; code[004231] = &I04231;
  core[004232] = 07240; code[004232] = &I04232;
  core[004233] = 00727; code[004233] = &I04233;
  core[004234] = 07140; code[004234] = &I04234;
  core[004235] = 01331; code[004235] = &I04235;
  core[004236] = 07040; code[004236] = &I04236;
  core[004237] = 07440; code[004237] = &I04237;
  core[004240] = 05333; code[004240] = &I04240;
  core[004241] = 07430; code[004241] = &I04241;
  core[004242] = 05333; code[004242] = &I04242;
  core[004243] = 02315; code[004243] = &I04243;
  core[004244] = 05202; code[004244] = &I04244;
  core[004245] = 07604; code[004245] = &I04245;
  core[004246] = 07106; code[004246] = &I04246;
  core[004247] = 07430; code[004247] = &I04247;
  core[004250] = 05202; code[004250] = &I04250;
  core[004251] = 02322; code[004251] = &I04251;
  core[004252] = 05201; code[004252] = &L04252;
  core[004253] = 07604; code[004253] = &I04253;
  core[004254] = 07106; code[004254] = &I04254;
  core[004255] = 07006; code[004255] = &I04255;
  core[004256] = 07430; code[004256] = &I04256;
  core[004257] = 05200; code[004257] = &I04257;
  core[004260] = 05724; code[004260] = &I04260;
  core[004261] = 07200; code[004261] = &L04261;
  core[004262] = 03315; code[004262] = &I04262;
  core[004263] = 07400; code[004263] = &I04263;
  core[004264] = 07040; code[004264] = &I04264;
  core[004265] = 00323; code[004265] = &I04265;
  core[004266] = 03322; code[004266] = &I04266;
  core[004267] = 01331; code[004267] = &D04267;
  core[004270] = 03730; code[004270] = &I04270;
  core[004271] = 04535; code[004271] = &I04271;
  core[004272] = 05201; code[004272] = &D04272;
  core[004273] = 00000; code[004273] = &S04273;
  core[004274] = 07240; code[004274] = &I04274;
  core[004275] = 00322; code[004275] = &I04275;
  core[004276] = 07040; code[004276] = &I04276;
  core[004277] = 07440; code[004277] = &I04277;
  core[004300] = 05302; code[004300] = &P04300;
  core[004301] = 05307; code[004301] = &I04301;
  core[004302] = 07240; code[004302] = &L04302;
  core[004303] = 00320; code[004303] = &P04303;
  core[004304] = 03716; code[004304] = &P04304;
  core[004305] = 03717; code[004305] = &P04305;
  core[004306] = 05673; code[004306] = &P04306;
  core[004307] = 07240; code[004307] = &P04307;
  core[004310] = 00321; code[004310] = &I04310;
  core[004311] = 03716; code[004311] = &I04311;
  core[004312] = 07040; code[004312] = &I04312;
  core[004313] = 03717; code[004313] = &I04313;
  core[004314] = 05673; code[004314] = &I04314;
  core[004315] = 00000; code[004315] = &D04315;
  core[004316] = 03705; code[004316] = &P04316;
  core[004317] = 03704; code[004317] = &P04317;
  core[004320] = 02525; code[004320] = &D04320;
  core[004321] = 05252; code[004321] = &D04321;
  core[004322] = 00000; code[004322] = &D04322;
  core[004323] = 07776; code[004323] = &D04323;
  core[004324] = 04400; code[004324] = &P04324;
  core[004325] = 03707; code[004325] = &P04325;
  core[004326] = 03706; code[004326] = &P04326;
  core[004327] = 03700; code[004327] = &P04327;
  core[004330] = 03703; code[004330] = &P04330;
  core[004331] = 00014; code[004331] = &D04331;
  core[004332] = 04000; code[004332] = &P04332;
  core[004333] = 04545; code[004333] = &L04333;
  core[004334] = 04732; code[004334] = &I04334;
  core[004335] = 04543; code[004335] = &I04335;
  core[004336] = 07402; code[004336] = &I04336;
  core[004337] = 04544; code[004337] = &I04337;
  core[004340] = 07610; code[004340] = &I04340;
  core[004341] = 05202; code[004341] = &I04341;
  core[004342] = 03315; code[004342] = &I04342;
  core[004343] = 05202; code[004343] = &I04343;
  core[004400] = 05305; code[004400] = &P04400;
  core[004401] = 04253; code[004401] = &L04401;
  core[004402] = 07621; code[004402] = &L04402;
  core[004403] = 07040; code[004403] = &I04403;
  core[004404] = 00725; code[004404] = &I04404;
  core[004405] = 07421; code[004405] = &I04405;
  core[004406] = 07140; code[004406] = &I04406;
  core[004407] = 00726; code[004407] = &I04407;
  core[004410] = 07411; code[004410] = &I04410;
  core[004411] = 03727; code[004411] = &I04411;
  core[004412] = 07501; code[004412] = &I04412;
  core[004413] = 03730; code[004413] = &I04413;
  core[004414] = 07441; code[004414] = &I04414;
  core[004415] = 03734; code[004415] = &I04415;
  core[004416] = 07040; code[004416] = &I04416;
  core[004417] = 00727; code[004417] = &I04417;
  core[004420] = 07040; code[004420] = &I04420;
  core[004421] = 01331; code[004421] = &I04421;
  core[004422] = 07040; code[004422] = &I04422;
  core[004423] = 07440; code[004423] = &I04423;
  core[004424] = 05313; code[004424] = &I04424;
  core[004425] = 07430; code[004425] = &I04425;
  core[004426] = 05313; code[004426] = &I04426;
  core[004427] = 07040; code[004427] = &I04427;
  core[004430] = 00730; code[004430] = &I04430;
  core[004431] = 07040; code[004431] = &I04431;
  core[004432] = 01332; code[004432] = &I04432;
  core[004433] = 07040; code[004433] = &I04433;
  core[004434] = 07440; code[004434] = &I04434;
  core[004435] = 05313; code[004435] = &I04435;
  core[004436] = 07430; code[004436] = &I04436;
  core[004437] = 05313; code[004437] = &I04437;
  core[004440] = 07040; code[004440] = &I04440;
  core[004441] = 00734; code[004441] = &I04441;
  core[004442] = 07041; code[004442] = &I04442;
  core[004443] = 01733; code[004443] = &I04443;
  core[004444] = 07420; code[004444] = &I04444;
  core[004445] = 05313; code[004445] = &I04445;
  core[004446] = 02336; code[004446] = &I04446;
  core[004447] = 05202; code[004447] = &I04447;
  core[004450] = 04544; code[004450] = &L04450;
  core[004451] = 05202; code[004451] = &I04451;
  core[004452] = 05345; code[004452] = &I04452;
  core[004453] = 00000; code[004453] = &S04453;
  core[004454] = 07240; code[004454] = &I04454;
  core[004455] = 00337; code[004455] = &I04455;
  core[004456] = 07040; code[004456] = &I04456;
  core[004457] = 07440; code[004457] = &I04457;
  core[004460] = 05262; code[004460] = &I04460;
  core[004461] = 05271; code[004461] = &I04461;
  core[004462] = 07200; code[004462] = &L04462;
  core[004463] = 03726; code[004463] = &I04463;
  core[004464] = 03725; code[004464] = &I04464;
  core[004465] = 03331; code[004465] = &I04465;
  core[004466] = 03332; code[004466] = &I04466;
  core[004467] = 03733; code[004467] = &I04467;
  core[004470] = 05653; code[004470] = &I04470;
  core[004471] = 07240; code[004471] = &L04471;
  core[004472] = 00335; code[004472] = &I04472;
  core[004473] = 03725; code[004473] = &I04473;
  core[004474] = 07040; code[004474] = &I04474;
  core[004475] = 00340; code[004475] = &I04475;
  core[004476] = 03733; code[004476] = &I04476;
  core[004477] = 03726; code[004477] = &I04477;
  core[004500] = 03332; code[004500] = &P04500;
  core[004501] = 07040; code[004501] = &I04501;
  core[004502] = 00341; code[004502] = &I04502;
  core[004503] = 03331; code[004503] = &P04503;
  core[004504] = 05653; code[004504] = &P04504;
  core[004505] = 07240; code[004505] = &P04505;
  core[004506] = 00342; code[004506] = &P04506;
  core[004507] = 03337; code[004507] = &P04507;
  core[004510] = 03336; code[004510] = &I04510;
  core[004511] = 04535; code[004511] = &I04511;
  core[004512] = 05201; code[004512] = &I04512;
  core[004513] = 04545; code[004513] = &L04513;
  core[004514] = 04743; code[004514] = &I04514;
  core[004515] = 07604; code[004515] = &I04515;
  core[004516] = 07104; code[004516] = &I04516;
  core[004517] = 07430; code[004517] = &I04517;
  core[004520] = 07402; code[004520] = &I04520;
  core[004521] = 05250; code[004521] = &I04521;
  core[004522] = 04546; code[004522] = &L04522;
  core[004523] = 05200; code[004523] = &I04523;
  core[004524] = 05744; code[004524] = &I04524;
  core[004525] = 03705; code[004525] = &P04525;
  core[004526] = 03704; code[004526] = &P04526;
  core[004527] = 03707; code[004527] = &P04527;
  core[004530] = 03706; code[004530] = &P04530;
  core[004531] = 00000; code[004531] = &D04531;
  core[004532] = 00000; code[004532] = &D04532;
  core[004533] = 03703; code[004533] = &P04533;
  core[004534] = 03700; code[004534] = &P04534;
  core[004535] = 00001; code[004535] = &D04535;
  core[004536] = 00000; code[004536] = &D04536;
  core[004537] = 00000; code[004537] = &D04537;
  core[004540] = 00026; code[004540] = &D04540;
  core[004541] = 02000; code[004541] = &D04541;
  core[004542] = 07776; code[004542] = &D04542;
  core[004543] = 04000; code[004543] = &P04543;
  core[004544] = 04600; code[004544] = &P04544;
  core[004545] = 02337; code[004545] = &L04545;
  core[004546] = 05201; code[004546] = &I04546;
  core[004547] = 05322; code[004547] = &I04547;
  core[004600] = 07240; code[004600] = &L04600;
  core[004601] = 07421; code[004601] = &I04601;
  core[004602] = 07501; code[004602] = &I04602;
  core[004603] = 07401; code[004603] = &I04603;
  core[004604] = 07410; code[004604] = &I04604;
  core[004605] = 07402; code[004605] = &I04605;
  core[004606] = 07040; code[004606] = &I04606;
  core[004607] = 07640; code[004607] = &I04607;
  core[004610] = 07402; code[004610] = &I04610;
  core[004611] = 07501; code[004611] = &I04611;
  core[004612] = 07040; code[004612] = &I04612;
  core[004613] = 07440; code[004613] = &I04613;
  core[004614] = 07402; code[004614] = &I04614;
  core[004615] = 07240; code[004615] = &I04615;
  core[004616] = 07421; code[004616] = &I04616;
  core[004617] = 07501; code[004617] = &I04617;
  core[004620] = 07601; code[004620] = &I04620;
  core[004621] = 07410; code[004621] = &I04621;
  core[004622] = 07402; code[004622] = &I04622;
  core[004623] = 07640; code[004623] = &I04623;
  core[004624] = 07402; code[004624] = &I04624;
  core[004625] = 07501; code[004625] = &I04625;
  core[004626] = 07040; code[004626] = &I04626;
  core[004627] = 07440; code[004627] = &I04627;
  core[004630] = 07402; code[004630] = &I04630;
  core[004631] = 07240; code[004631] = &I04631;
  core[004632] = 07421; code[004632] = &I04632;
  core[004633] = 07501; code[004633] = &I04633;
  core[004634] = 07621; code[004634] = &I04634;
  core[004635] = 07501; code[004635] = &I04635;
  core[004636] = 07440; code[004636] = &I04636;
  core[004637] = 07402; code[004637] = &I04637;
  core[004640] = 07200; code[004640] = &I04640;
  core[004641] = 01172; code[004641] = &I04641;
  core[004642] = 07421; code[004642] = &I04642;
  core[004643] = 01171; code[004643] = &I04643;
  core[004644] = 07521; code[004644] = &I04644;
  core[004645] = 01171; code[004645] = &I04645;
  core[004646] = 07040; code[004646] = &I04646;
  core[004647] = 07440; code[004647] = &I04647;
  core[004650] = 07402; code[004650] = &I04650;
  core[004651] = 07501; code[004651] = &I04651;
  core[004652] = 01172; code[004652] = &L04652;
  core[004653] = 07040; code[004653] = &I04653;
  core[004654] = 07440; code[004654] = &I04654;
  core[004655] = 07402; code[004655] = &I04655;
  core[004656] = 07621; code[004656] = &I04656;
  core[004657] = 01171; code[004657] = &I04657;
  core[004660] = 07421; code[004660] = &I04660;
  core[004661] = 01172; code[004661] = &L04661;
  core[004662] = 07701; code[004662] = &I04662;
  core[004663] = 01172; code[004663] = &I04663;
  core[004664] = 07040; code[004664] = &I04664;
  core[004665] = 07440; code[004665] = &I04665;
  core[004666] = 07402; code[004666] = &I04666;
  core[004667] = 07621; code[004667] = &I04667;
  core[004670] = 01115; code[004670] = &I04670;
  core[004671] = 07650; code[004671] = &I04671;
  core[004672] = 05353; code[004672] = &I04672;
  core[004673] = 07431; code[004673] = &I04673;
  core[004674] = 07621; code[004674] = &I04674;
  core[004675] = 01171; code[004675] = &I04675;
  core[004676] = 07421; code[004676] = &I04676;
  core[004677] = 01172; code[004677] = &I04677;
  core[004700] = 07663; code[004700] = &I04700;
  core[004701] = 04703; code[004701] = &I04701;
  core[004702] = 05305; code[004702] = &I04702;
  core[004703] = 05252; code[004703] = &P04703;
  core[004704] = 02525; code[004704] = &I04704;
  core[004705] = 01172; code[004705] = &L04705;
  core[004706] = 07040; code[004706] = &I04706;
  core[004707] = 07440; code[004707] = &I04707;
  core[004710] = 07402; code[004710] = &I04710;
  core[004711] = 07501; code[004711] = &I04711;
  core[004712] = 01171; code[004712] = &I04712;
  core[004713] = 07040; code[004713] = &I04713;
  core[004714] = 07440; code[004714] = &I04714;
  core[004715] = 07402; code[004715] = &I04715;
  core[004716] = 07431; code[004716] = &I04716;
  core[004717] = 07621; code[004717] = &I04717;
  core[004720] = 01171; code[004720] = &I04720;
  core[004721] = 07421; code[004721] = &I04721;
  core[004722] = 07501; code[004722] = &I04722;
  core[004723] = 03332; code[004723] = &I04723;
  core[004724] = 01172; code[004724] = &I04724;
  core[004725] = 03333; code[004725] = &I04725;
  core[004726] = 01172; code[004726] = &I04726;
  core[004727] = 07665; code[004727] = &I04727;
  core[004730] = 04732; code[004730] = &I04730;
  core[004731] = 05334; code[004731] = &I04731;
  core[004732] = 00000; code[004732] = &P04732;
  core[004733] = 00000; code[004733] = &D04733;
  core[004734] = 07501; code[004734] = &L04734;
  core[004735] = 07440; code[004735] = &I04735;
  core[004736] = 07402; code[004736] = &I04736;
  core[004737] = 01332; code[004737] = &I04737;
  core[004740] = 07440; code[004740] = &I04740;
  core[004741] = 07402; code[004741] = &I04741;
  core[004742] = 01333; code[004742] = &I04742;
  core[004743] = 07440; code[004743] = &I04743;
  core[004744] = 07402; code[004744] = &I04744;
  core[004745] = 07431; code[004745] = &I04745;
  core[004746] = 07621; code[004746] = &I04746;
  core[004747] = 07330; code[004747] = &I04747;
  core[004750] = 07411; code[004750] = &I04750;
  core[004751] = 07440; code[004751] = &I04751;
  core[004752] = 07402; code[004752] = &I04752;
  core[004753] = 07447; code[004753] = &L04753;
  core[004754] = 04546; code[004754] = &I04754;
  core[004755] = 05200; code[004755] = &I04755;
  core[004756] = 02117; code[004756] = &I04756;
  core[004757] = 05200; code[004757] = &I04757;
  core[004760] = 05777; code[004760] = &I04760;
  core[004777] = 05261; code[004777] = &P04777;
  core[005000] = 00000; code[005000] = &L05000;
  core[005001] = 07621; code[005001] = &L05001;
  core[005002] = 07451; code[005002] = &I05002;
  core[005003] = 07410; code[005003] = &I05003;
  core[005004] = 07402; code[005004] = &I05004;
  core[005005] = 07431; code[005005] = &I05005;
  core[005006] = 07621; code[005006] = &I05006;
  core[005007] = 07451; code[005007] = &I05007;
  core[005010] = 07402; code[005010] = &I05010;
  core[005011] = 07447; code[005011] = &I05011;
  core[005012] = 07621; code[005012] = &I05012;
  core[005013] = 07451; code[005013] = &I05013;
  core[005014] = 07410; code[005014] = &I05014;
  core[005015] = 07402; code[005015] = &I05015;
  core[005016] = 07431; code[005016] = &I05016;
  core[005017] = 06007; code[005017] = &I05017;
  core[005020] = 07621; code[005020] = &I05020;
  core[005021] = 07451; code[005021] = &I05021;
  core[005022] = 07610; code[005022] = &I05022;
  core[005023] = 07402; code[005023] = &I05023;
  core[005024] = 07200; code[005024] = &I05024;
  core[005025] = 07403; code[005025] = &I05025;
  core[005026] = 07737; code[005026] = &I05026;
  core[005027] = 07441; code[005027] = &I05027;
  core[005030] = 07640; code[005030] = &I05030;
  core[005031] = 07402; code[005031] = &I05031;
  core[005032] = 07403; code[005032] = &I05032;
  core[005033] = 07776; code[005033] = &D05033;
  core[005034] = 07441; code[005034] = &I05034;
  core[005035] = 01233; code[005035] = &I05035;
  core[005036] = 07040; code[005036] = &I05036;
  core[005037] = 07640; code[005037] = &I05037;
  core[005040] = 07402; code[005040] = &I05040;
  core[005041] = 07403; code[005041] = &I05041;
  core[005042] = 07775; code[005042] = &D05042;
  core[005043] = 07441; code[005043] = &I05043;
  core[005044] = 01242; code[005044] = &I05044;
  core[005045] = 07040; code[005045] = &I05045;
  core[005046] = 07640; code[005046] = &I05046;
  core[005047] = 07402; code[005047] = &I05047;
  core[005050] = 07403; code[005050] = &I05050;
  core[005051] = 07773; code[005051] = &D05051;
  core[005052] = 07441; code[005052] = &I05052;
  core[005053] = 01251; code[005053] = &I05053;
  core[005054] = 07040; code[005054] = &I05054;
  core[005055] = 07640; code[005055] = &I05055;
  core[005056] = 07402; code[005056] = &I05056;
  core[005057] = 07403; code[005057] = &I05057;
  core[005060] = 07767; code[005060] = &D05060;
  core[005061] = 07441; code[005061] = &I05061;
  core[005062] = 01260; code[005062] = &I05062;
  core[005063] = 07040; code[005063] = &I05063;
  core[005064] = 07640; code[005064] = &I05064;
  core[005065] = 07402; code[005065] = &I05065;
  core[005066] = 07403; code[005066] = &I05066;
  core[005067] = 07757; code[005067] = &D05067;
  core[005070] = 07441; code[005070] = &I05070;
  core[005071] = 01267; code[005071] = &I05071;
  core[005072] = 07040; code[005072] = &I05072;
  core[005073] = 07640; code[005073] = &I05073;
  core[005074] = 07402; code[005074] = &I05074;
  core[005075] = 07403; code[005075] = &I05075;
  core[005076] = 07765; code[005076] = &D05076;
  core[005077] = 07441; code[005077] = &I05077;
  core[005100] = 01276; code[005100] = &I05100;
  core[005101] = 07040; code[005101] = &I05101;
  core[005102] = 07640; code[005102] = &I05102;
  core[005103] = 07402; code[005103] = &I05103;
  core[005104] = 07403; code[005104] = &I05104;
  core[005105] = 07752; code[005105] = &D05105;
  core[005106] = 07441; code[005106] = &I05106;
  core[005107] = 01305; code[005107] = &I05107;
  core[005110] = 07040; code[005110] = &I05110;
  core[005111] = 07640; code[005111] = &I05111;
  core[005112] = 07402; code[005112] = &I05112;
  core[005113] = 07403; code[005113] = &I05113;
  core[005114] = 00077; code[005114] = &I05114;
  core[005115] = 07441; code[005115] = &I05115;
  core[005116] = 07640; code[005116] = &I05116;
  core[005117] = 07402; code[005117] = &I05117;
  core[005120] = 07403; code[005120] = &I05120;
  core[005121] = 07700; code[005121] = &I05121;
  core[005122] = 07441; code[005122] = &I05122;
  core[005123] = 01123; code[005123] = &I05123;
  core[005124] = 07040; code[005124] = &I05124;
  core[005125] = 07640; code[005125] = &I05125;
  core[005126] = 07402; code[005126] = &I05126;
  core[005127] = 07403; code[005127] = &I05127;
  core[005130] = 07777; code[005130] = &I05130;
  core[005131] = 07240; code[005131] = &I05131;
  core[005132] = 07441; code[005132] = &I05132;
  core[005133] = 07040; code[005133] = &I05133;
  core[005134] = 07440; code[005134] = &I05134;
  core[005135] = 07402; code[005135] = &I05135;
  core[005136] = 07403; code[005136] = &I05136;
  core[005137] = 07752; code[005137] = &D05137;
  core[005140] = 07200; code[005140] = &I05140;
  core[005141] = 01337; code[005141] = &I05141;
  core[005142] = 07441; code[005142] = &I05142;
  core[005143] = 07040; code[005143] = &I05143;
  core[005144] = 07440; code[005144] = &I05144;
  core[005145] = 07402; code[005145] = &I05145;
  core[005146] = 07403; code[005146] = &I05146;
  core[005147] = 07765; code[005147] = &D05147;
  core[005150] = 07200; code[005150] = &I05150;
  core[005151] = 01347; code[005151] = &I05151;
  core[005152] = 07441; code[005152] = &I05152;
  core[005153] = 07040; code[005153] = &I05153;
  core[005154] = 07440; code[005154] = &I05154;
  core[005155] = 07402; code[005155] = &I05155;
  core[005156] = 07431; code[005156] = &I05156;
  core[005157] = 07360; code[005157] = &I05157;
  core[005160] = 07403; code[005160] = &I05160;
  core[005161] = 07430; code[005161] = &I05161;
  core[005162] = 07440; code[005162] = &I05162;
  core[005163] = 07402; code[005163] = &I05163;
  core[005164] = 07441; code[005164] = &I05164;
  core[005165] = 01123; code[005165] = &I05165;
  core[005166] = 07040; code[005166] = &I05166;
  core[005167] = 07440; code[005167] = &I05167;
  core[005170] = 07402; code[005170] = &I05170;
  core[005171] = 05777; code[005171] = &I05171;
  core[005177] = 05200; code[005177] = &P05177;
  core[005200] = 07320; code[005200] = &L05200;
  core[005201] = 01123; code[005201] = &I05201;
  core[005202] = 07403; code[005202] = &D05202;
  core[005203] = 07430; code[005203] = &I05203;
  core[005204] = 07440; code[005204] = &D05204;
  core[005205] = 07402; code[005205] = &I05205;
  core[005206] = 07441; code[005206] = &I05206;
  core[005207] = 07440; code[005207] = &I05207;
  core[005210] = 07402; code[005210] = &I05210;
  core[005211] = 07431; code[005211] = &I05211;
  core[005212] = 07300; code[005212] = &I05212;
  core[005213] = 04554; code[005213] = &I05213;
  core[005214] = 06004; code[005214] = &I05214;
  core[005215] = 00377; code[005215] = &I05215;
  core[005216] = 07006; code[005216] = &I05216;
  core[005217] = 07430; code[005217] = &I05217;
  core[005220] = 07402; code[005220] = &I05220;
  core[005221] = 07431; code[005221] = &I05221;
  core[005222] = 07332; code[005222] = &I05222;
  core[005223] = 04554; code[005223] = &I05223;
  core[005224] = 06004; code[005224] = &I05224;
  core[005225] = 00377; code[005225] = &I05225;
  core[005226] = 07006; code[005226] = &I05226;
  core[005227] = 07420; code[005227] = &D05227;
  core[005230] = 07402; code[005230] = &I05230;
  core[005231] = 07431; code[005231] = &I05231;
  core[005232] = 07300; code[005232] = &D05232;
  core[005233] = 04554; code[005233] = &I05233;
  core[005234] = 06006; code[005234] = &I05234;
  core[005235] = 07410; code[005235] = &I05235;
  core[005236] = 07402; code[005236] = &I05236;
  core[005237] = 07431; code[005237] = &I05237;
  core[005240] = 07332; code[005240] = &I05240;
  core[005241] = 04554; code[005241] = &I05241;
  core[005242] = 06006; code[005242] = &I05242;
  core[005243] = 07402; code[005243] = &I05243;
  core[005244] = 07431; code[005244] = &I05244;
  core[005245] = 07332; code[005245] = &I05245;
  core[005246] = 04554; code[005246] = &I05246;
  core[005247] = 07447; code[005247] = &I05247;
  core[005250] = 06006; code[005250] = &I05250;
  core[005251] = 07610; code[005251] = &I05251;
  core[005252] = 07402; code[005252] = &I05252;
  core[005253] = 04546; code[005253] = &I05253;
  core[005254] = 05776; code[005254] = &I05254;
  core[005255] = 02117; code[005255] = &I05255;
  core[005256] = 05776; code[005256] = &I05256;
  core[005257] = 06007; code[005257] = &I05257;
  core[005260] = 05775; code[005260] = &I05260;
  core[005261] = 04524; code[005261] = &L05261;
  core[005262] = 01115; code[005262] = &I05262;
  core[005263] = 07650; code[005263] = &I05263;
  core[005264] = 05267; code[005264] = &I05264;
  core[005265] = 04450; code[005265] = &I05265;
  core[005266] = 07532; code[005266] = &I05266;
  core[005267] = 01115; code[005267] = &L05267;
  core[005270] = 07140; code[005270] = &I05270;
  core[005271] = 03115; code[005271] = &I05271;
  core[005272] = 06007; code[005272] = &I05272;
  core[005273] = 05774; code[005273] = &I05273;
  core[005274] = 00000; code[005274] = &S05274;
  core[005275] = 07604; code[005275] = &I05275;
  core[005276] = 07112; code[005276] = &I05276;
  core[005277] = 07430; code[005277] = &I05277;
  core[005300] = 05311; code[005300] = &I05300;
  core[005301] = 07200; code[005301] = &L05301;
  core[005302] = 01115; code[005302] = &D05302;
  core[005303] = 07640; code[005303] = &I05303;
  core[005304] = 05307; code[005304] = &I05304;
  core[005305] = 07447; code[005305] = &I05305;
  core[005306] = 05674; code[005306] = &I05306;
  core[005307] = 07431; code[005307] = &L05307;
  core[005310] = 05674; code[005310] = &I05310;
  core[005311] = 07710; code[005311] = &L05311;
  core[005312] = 05315; code[005312] = &I05312;
  core[005313] = 03115; code[005313] = &L05313;
  core[005314] = 05301; code[005314] = &I05314;
  core[005315] = 07140; code[005315] = &L05315;
  core[005316] = 05313; code[005316] = &I05316;
  core[005317] = 00000; code[005317] = &S05317;
  core[005320] = 07200; code[005320] = &I05320;
  core[005321] = 01115; code[005321] = &I05321;
  core[005322] = 07700; code[005322] = &I05322;
  core[005323] = 05575; code[005323] = &I05323;
  core[005324] = 05717; code[005324] = &I05324;
  core[005325] = 00000; code[005325] = &S05325;
  core[005326] = 07604; code[005326] = &I05326;
  core[005327] = 07710; code[005327] = &I05327;
  core[005330] = 05725; code[005330] = &I05330;
  core[005331] = 02325; code[005331] = &I05331;
  core[005332] = 05725; code[005332] = &I05332;
  core[005333] = 00000; code[005333] = &S05333;
  core[005334] = 07604; code[005334] = &I05334;
  core[005335] = 07004; code[005335] = &I05335;
  core[005336] = 07710; code[005336] = &I05336;
  core[005337] = 05733; code[005337] = &I05337;
  core[005340] = 02333; code[005340] = &I05340;
  core[005341] = 05733; code[005341] = &I05341;
  core[005342] = 00000; code[005342] = &S05342;
  core[005343] = 07604; code[005343] = &I05343;
  core[005344] = 07106; code[005344] = &I05344;
  core[005345] = 07710; code[005345] = &I05345;
  core[005346] = 05742; code[005346] = &I05346;
  core[005347] = 02342; code[005347] = &I05347;
  core[005350] = 05742; code[005350] = &I05350;
  core[005374] = 00202; code[005374] = &P05374;
  core[005375] = 00204; code[005375] = &P05375;
  core[005376] = 05001; code[005376] = &P05376;
  core[005377] = 02000; code[005377] = &D05377;
  core[005400] = 00000; code[005400] = &S05400;
  core[005401] = 07604; code[005401] = &I05401;
  core[005402] = 07106; code[005402] = &I05402;
  core[005403] = 07104; code[005403] = &I05403;
  core[005404] = 07710; code[005404] = &I05404;
  core[005405] = 05600; code[005405] = &I05405;
  core[005406] = 02200; code[005406] = &I05406;
  core[005407] = 05600; code[005407] = &I05407;
  core[005410] = 00000; code[005410] = &S05410;
  core[005411] = 03034; code[005411] = &I05411;
  core[005412] = 07701; code[005412] = &I05412;
  core[005413] = 03035; code[005413] = &I05413;
  core[005414] = 07210; code[005414] = &I05414;
  core[005415] = 03033; code[005415] = &I05415;
  core[005416] = 07641; code[005416] = &I05416;
  core[005417] = 03036; code[005417] = &I05417;
  core[005420] = 06004; code[005420] = &I05420;
  core[005421] = 00377; code[005421] = &I05421;
  core[005422] = 07104; code[005422] = &I05422;
  core[005423] = 03037; code[005423] = &I05423;
  core[005424] = 05610; code[005424] = &I05424;
  core[005425] = 00000; code[005425] = &S05425;
  core[005426] = 04776; code[005426] = &I05426;
  core[005427] = 05625; code[005427] = &I05427;
  core[005430] = 00000; code[005430] = &S05430;
  core[005431] = 04237; code[005431] = &I05431;
  core[005432] = 04250; code[005432] = &I05432;
  core[005433] = 05630; code[005433] = &I05433;
  core[005434] = 00000; code[005434] = &S05434;
  core[005435] = 04237; code[005435] = &I05435;
  core[005436] = 05634; code[005436] = &I05436;
  core[005437] = 00000; code[005437] = &S05437;
  core[005440] = 07240; code[005440] = &I05440;
  core[005441] = 00300; code[005441] = &I05441;
  core[005442] = 04526; code[005442] = &I05442;
  core[005443] = 01301; code[005443] = &I05443;
  core[005444] = 04526; code[005444] = &I05444;
  core[005445] = 01302; code[005445] = &I05445;
  core[005446] = 04526; code[005446] = &I05446;
  core[005447] = 05637; code[005447] = &I05447;
  core[005450] = 00000; code[005450] = &S05450;
  core[005451] = 07240; code[005451] = &D05451;
  core[005452] = 00277; code[005452] = &I05452;
  core[005453] = 04526; code[005453] = &I05453;
  core[005454] = 05650; code[005454] = &I05454;
  core[005455] = 00000; code[005455] = &S05455;
  core[005456] = 07200; code[005456] = &I05456;
  core[005457] = 01077; code[005457] = &I05457;
  core[005460] = 04526; code[005460] = &I05460;
  core[005461] = 05655; code[005461] = &I05461;
  core[005462] = 00000; code[005462] = &S05462;
  core[005463] = 07200; code[005463] = &I05463;
  core[005464] = 01375; code[005464] = &I05464;
  core[005465] = 04526; code[005465] = &I05465;
  core[005466] = 05662; code[005466] = &I05466;
  core[005467] = 00000; code[005467] = &S05467;
  core[005470] = 07200; code[005470] = &I05470;
  core[005471] = 01374; code[005471] = &I05471;
  core[005472] = 04526; code[005472] = &I05472;
  core[005473] = 05667; code[005473] = &I05473;
  core[005474] = 00316; code[005474] = &D05474;
  core[005475] = 00315; code[005475] = &D05475;
  core[005476] = 00311; code[005476] = &D05476;
  core[005477] = 00324; code[005477] = &D05477;
  core[005500] = 00323; code[005500] = &D05500;
  core[005501] = 00303; code[005501] = &D05501;
  core[005502] = 00301; code[005502] = &D05502;
  core[005503] = 00000; code[005503] = &S05503;
  core[005504] = 01115; code[005504] = &I05504;
  core[005505] = 07640; code[005505] = &I05505;
  core[005506] = 05315; code[005506] = &I05506;
  core[005507] = 01024; code[005507] = &I05507;
  core[005510] = 07040; code[005510] = &I05510;
  core[005511] = 03313; code[005511] = &D05511;
  core[005512] = 07403; code[005512] = &I05512;
  core[005513] = 00000; code[005513] = &D05513;
  core[005514] = 05703; code[005514] = &I05514;
  core[005515] = 01024; code[005515] = &L05515;
  core[005516] = 07403; code[005516] = &D05516;
  core[005517] = 05703; code[005517] = &I05517;
  core[005520] = 00000; code[005520] = &S05520;
  core[005521] = 07344; code[005521] = &I05521;
  core[005522] = 03120; code[005522] = &I05522;
  core[005523] = 04554; code[005523] = &D05523;
  core[005524] = 01170; code[005524] = &D05524;
  core[005525] = 03773; code[005525] = &I05525;
  core[005526] = 01167; code[005526] = &I05526;
  core[005527] = 03772; code[005527] = &I05527;
  core[005530] = 03114; code[005530] = &I05530;
  core[005531] = 03021; code[005531] = &I05531;
  core[005532] = 03771; code[005532] = &I05532;
  core[005533] = 03770; code[005533] = &I05533;
  core[005534] = 04453; code[005534] = &I05534;
  core[005535] = 00021; code[005535] = &I05535;
  core[005536] = 00022; code[005536] = &I05536;
  core[005537] = 07753; code[005537] = &I05537;
  core[005540] = 05720; code[005540] = &I05540;
  core[005541] = 00000; code[005541] = &S05541;
  core[005542] = 04525; code[005542] = &I05542;
  core[005543] = 04450; code[005543] = &I05543;
  core[005544] = 00000; code[005544] = &D05544;
  core[005545] = 05741; code[005545] = &I05545;
  core[005546] = 00000; code[005546] = &S05546;
  core[005547] = 02065; code[005547] = &I05547;
  core[005550] = 05746; code[005550] = &I05550;
  core[005551] = 07604; code[005551] = &L05551;
  core[005552] = 07106; code[005552] = &I05552;
  core[005553] = 07006; code[005553] = &I05553;
  core[005554] = 07630; code[005554] = &I05554;
  core[005555] = 05456; code[005555] = &I05555;
  core[005556] = 05457; code[005556] = &I05556;
  core[005570] = 07002; code[005570] = &P05570;
  core[005571] = 07016; code[005571] = &P05571;
  core[005572] = 06371; code[005572] = &P05572;
  core[005573] = 06370; code[005573] = &P05573;
  core[005574] = 00251; code[005574] = &D05574;
  core[005575] = 00250; code[005575] = &D05575;
  core[005576] = 04132; code[005576] = &P05576;
  core[005577] = 02000; code[005577] = &D05577;
  core[005600] = 00000; code[005600] = &S05600;
  core[005601] = 07240; code[005601] = &I05601;
  core[005602] = 00070; code[005602] = &I05602;
  core[005603] = 04526; code[005603] = &I05603;
  core[005604] = 01071; code[005604] = &I05604;
  core[005605] = 04526; code[005605] = &I05605;
  core[005606] = 05600; code[005606] = &I05606;
  core[005607] = 00000; code[005607] = &S05607;
  core[005610] = 04524; code[005610] = &I05610;
  core[005611] = 04524; code[005611] = &I05611;
  core[005612] = 05607; code[005612] = &I05612;
  core[005613] = 00000; code[005613] = &S05613;
  core[005614] = 03236; code[005614] = &I05614;
  core[005615] = 01020; code[005615] = &I05615;
  core[005616] = 07040; code[005616] = &I05616;
  core[005617] = 03237; code[005617] = &I05617;
  core[005620] = 01236; code[005620] = &I05620;
  core[005621] = 06046; code[005621] = &I05621;
  core[005622] = 06041; code[005622] = &L05622;
  core[005623] = 05222; code[005623] = &I05623;
  core[005624] = 01166; code[005624] = &I05624;
  core[005625] = 07640; code[005625] = &I05625;
  core[005626] = 05613; code[005626] = &I05626;
  core[005627] = 02237; code[005627] = &L05627;
  core[005630] = 07610; code[005630] = &I05630;
  core[005631] = 05613; code[005631] = &I05631;
  core[005632] = 06046; code[005632] = &I05632;
  core[005633] = 06041; code[005633] = &L05633;
  core[005634] = 05233; code[005634] = &I05634;
  core[005635] = 05227; code[005635] = &I05635;
  core[005636] = 00000; code[005636] = &D05636;
  core[005637] = 00000; code[005637] = &D05637;
  core[005640] = 00000; code[005640] = &S05640;
  core[005641] = 07240; code[005641] = &I05641;
  core[005642] = 00102; code[005642] = &I05642;
  core[005643] = 04245; code[005643] = &I05643;
  core[005644] = 05640; code[005644] = &I05644;
  core[005645] = 00000; code[005645] = &S05645;
  core[005646] = 07440; code[005646] = &I05646;
  core[005647] = 05252; code[005647] = &I05647;
  core[005650] = 04256; code[005650] = &I05650;
  core[005651] = 05645; code[005651] = &I05651;
  core[005652] = 07240; code[005652] = &L05652;
  core[005653] = 00100; code[005653] = &D05653;
  core[005654] = 04526; code[005654] = &I05654;
  core[005655] = 05645; code[005655] = &I05655;
  core[005656] = 00000; code[005656] = &S05656;
  core[005657] = 07240; code[005657] = &I05657;
  core[005660] = 00101; code[005660] = &I05660;
  core[005661] = 04526; code[005661] = &I05661;
  core[005662] = 05656; code[005662] = &I05662;
  core[005663] = 00000; code[005663] = &S05663;
  core[005664] = 07240; code[005664] = &I05664;
  core[005665] = 00104; code[005665] = &I05665;
  core[005666] = 03105; code[005666] = &I05666;
  core[005667] = 02105; code[005667] = &L05667;
  core[005670] = 07410; code[005670] = &I05670;
  core[005671] = 05663; code[005671] = &I05671;
  core[005672] = 07240; code[005672] = &I05672;
  core[005673] = 00106; code[005673] = &D05673;
  core[005674] = 07100; code[005674] = &I05674;
  core[005675] = 07004; code[005675] = &I05675;
  core[005676] = 03106; code[005676] = &I05676;
  core[005677] = 07430; code[005677] = &I05677;
  core[005700] = 05303; code[005700] = &I05700;
  core[005701] = 04256; code[005701] = &I05701;
  core[005702] = 05267; code[005702] = &I05702;
  core[005703] = 07240; code[005703] = &L05703;
  core[005704] = 00100; code[005704] = &I05704;
  core[005705] = 04526; code[005705] = &I05705;
  core[005706] = 05267; code[005706] = &I05706;
  core[005707] = 00000; code[005707] = &S05707;
  core[005710] = 04525; code[005710] = &I05710;
  core[005711] = 01707; code[005711] = &I05711;
  core[005712] = 03116; code[005712] = &I05712;
  core[005713] = 02307; code[005713] = &L05713;
  core[005714] = 01707; code[005714] = &I05714;
  core[005715] = 03317; code[005715] = &I05715;
  core[005716] = 04450; code[005716] = &I05716;
  core[005717] = 00000; code[005717] = &D05717;
  core[005720] = 04455; code[005720] = &I05720;
  core[005721] = 02116; code[005721] = &I05721;
  core[005722] = 05313; code[005722] = &I05722;
  core[005723] = 04454; code[005723] = &I05723;
  core[005724] = 02307; code[005724] = &I05724;
  core[005725] = 05707; code[005725] = &I05725;
  core[005726] = 00000; code[005726] = &S05726;
  core[005727] = 03102; code[005727] = &I05727;
  core[005730] = 04527; code[005730] = &I05730;
  core[005731] = 05726; code[005731] = &I05731;
  core[005732] = 00000; code[005732] = &S05732;
  core[005733] = 04550; code[005733] = &I05733;
  core[005734] = 03022; code[005734] = &I05734;
  core[005735] = 07010; code[005735] = &I05735;
  core[005736] = 03021; code[005736] = &I05736;
  core[005737] = 04550; code[005737] = &I05737;
  core[005740] = 03023; code[005740] = &I05740;
  core[005741] = 07010; code[005741] = &I05741;
  core[005742] = 03025; code[005742] = &I05742;
  core[005743] = 04550; code[005743] = &I05743;
  core[005744] = 00165; code[005744] = &I05744;
  core[005745] = 03024; code[005745] = &I05745;
  core[005746] = 04573; code[005746] = &I05746;
  core[005747] = 05732; code[005747] = &I05747;
  core[005750] = 05575; code[005750] = &I05750;
  core[005751] = 00000; code[005751] = &S05751;
  core[005752] = 07300; code[005752] = &I05752;
  core[005753] = 01023; code[005753] = &I05753;
  core[005754] = 07421; code[005754] = &I05754;
  core[005755] = 04553; code[005755] = &I05755;
  core[005756] = 01021; code[005756] = &I05756;
  core[005757] = 07104; code[005757] = &I05757;
  core[005760] = 05751; code[005760] = &I05760;
  core[005761] = 00000; code[005761] = &S05761;
  core[005762] = 07200; code[005762] = &I05762;
  core[005763] = 01025; code[005763] = &I05763;
  core[005764] = 07110; code[005764] = &I05764;
  core[005765] = 04554; code[005765] = &I05765;
  core[005766] = 05761; code[005766] = &I05766;
  core[005767] = 00000; code[005767] = &S05767;
  core[005770] = 02114; code[005770] = &I05770;
  core[005771] = 05767; code[005771] = &I05771;
  core[005772] = 02120; code[005772] = &I05772;
  core[005773] = 05767; code[005773] = &I05773;
  core[005774] = 02367; code[005774] = &I05774;
  core[005775] = 05767; code[005775] = &I05775;
  core[006000] = 00000; code[006000] = &S06000;
  core[006001] = 03116; code[006001] = &I06001;
  core[006002] = 06214; code[006002] = &I06002;
  core[006003] = 07112; code[006003] = &I06003;
  core[006004] = 07010; code[006004] = &I06004;
  core[006005] = 06224; code[006005] = &I06005;
  core[006006] = 01116; code[006006] = &I06006;
  core[006007] = 06005; code[006007] = &I06007;
  core[006010] = 06002; code[006010] = &I06010;
  core[006011] = 07300; code[006011] = &I06011;
  core[006012] = 05600; code[006012] = &I06012;
  core[006013] = 00000; code[006013] = &S06013;
  core[006014] = 01022; code[006014] = &I06014;
  core[006015] = 07500; code[006015] = &I06015;
  core[006016] = 07120; code[006016] = &I06016;
  core[006017] = 07041; code[006017] = &I06017;
  core[006020] = 03040; code[006020] = &I06020;
  core[006021] = 01023; code[006021] = &I06021;
  core[006022] = 07510; code[006022] = &I06022;
  core[006023] = 07020; code[006023] = &I06023;
  core[006024] = 01040; code[006024] = &I06024;
  core[006025] = 07230; code[006025] = &I06025;
  core[006026] = 03046; code[006026] = &I06026;
  core[006027] = 01022; code[006027] = &I06027;
  core[006030] = 07041; code[006030] = &I06030;
  core[006031] = 01023; code[006031] = &I06031;
  core[006032] = 03043; code[006032] = &I06032;
  core[006033] = 07010; code[006033] = &I06033;
  core[006034] = 03042; code[006034] = &I06034;
  core[006035] = 01023; code[006035] = &I06035;
  core[006036] = 03044; code[006036] = &I06036;
  core[006037] = 01024; code[006037] = &I06037;
  core[006040] = 03045; code[006040] = &I06040;
  core[006041] = 05613; code[006041] = &I06041;
  core[006042] = 00000; code[006042] = &S06042;
  core[006043] = 01024; code[006043] = &I06043;
  core[006044] = 01115; code[006044] = &I06044;
  core[006045] = 07140; code[006045] = &I06045;
  core[006046] = 03045; code[006046] = &I06046;
  core[006047] = 01022; code[006047] = &I06047;
  core[006050] = 03043; code[006050] = &I06050;
  core[006051] = 01023; code[006051] = &I06051;
  core[006052] = 03044; code[006052] = &I06052;
  core[006053] = 01025; code[006053] = &I06053;
  core[006054] = 00115; code[006054] = &I06054;
  core[006055] = 03046; code[006055] = &I06055;
  core[006056] = 01045; code[006056] = &I06056;
  core[006057] = 01377; code[006057] = &I06057;
  core[006060] = 07710; code[006060] = &I06060;
  core[006061] = 05307; code[006061] = &I06061;
  core[006062] = 01045; code[006062] = &I06062;
  core[006063] = 07650; code[006063] = &I06063;
  core[006064] = 05313; code[006064] = &I06064;
  core[006065] = 01044; code[006065] = &I06065;
  core[006066] = 07421; code[006066] = &I06066;
  core[006067] = 01043; code[006067] = &I06067;
  core[006070] = 07521; code[006070] = &L06070;
  core[006071] = 07104; code[006071] = &I06071;
  core[006072] = 07521; code[006072] = &I06072;
  core[006073] = 07004; code[006073] = &I06073;
  core[006074] = 02045; code[006074] = &L06074;
  core[006075] = 05270; code[006075] = &I06075;
  core[006076] = 03043; code[006076] = &I06076;
  core[006077] = 07501; code[006077] = &I06077;
  core[006100] = 03044; code[006100] = &I06100;
  core[006101] = 07210; code[006101] = &I06101;
  core[006102] = 03042; code[006102] = &I06102;
  core[006103] = 01115; code[006103] = &I06103;
  core[006104] = 00165; code[006104] = &I06104;
  core[006105] = 03045; code[006105] = &I06105;
  core[006106] = 05642; code[006106] = &I06106;
  core[006107] = 07340; code[006107] = &L06107;
  core[006110] = 03045; code[006110] = &I06110;
  core[006111] = 07421; code[006111] = &I06111;
  core[006112] = 05274; code[006112] = &I06112;
  core[006113] = 01021; code[006113] = &L06113;
  core[006114] = 03042; code[006114] = &I06114;
  core[006115] = 01165; code[006115] = &I06115;
  core[006116] = 03045; code[006116] = &I06116;
  core[006117] = 05642; code[006117] = &I06117;
  core[006120] = 00000; code[006120] = &S06120;
  core[006121] = 01024; code[006121] = &I06121;
  core[006122] = 01115; code[006122] = &I06122;
  core[006123] = 07140; code[006123] = &I06123;
  core[006124] = 03045; code[006124] = &I06124;
  core[006125] = 01045; code[006125] = &I06125;
  core[006126] = 01164; code[006126] = &I06126;
  core[006127] = 07710; code[006127] = &I06127;
  core[006130] = 05367; code[006130] = &I06130;
  core[006131] = 01022; code[006131] = &I06131;
  core[006132] = 03043; code[006132] = &I06132;
  core[006133] = 01023; code[006133] = &I06133;
  core[006134] = 03044; code[006134] = &I06134;
  core[006135] = 01045; code[006135] = &I06135;
  core[006136] = 07650; code[006136] = &I06136;
  core[006137] = 05364; code[006137] = &I06137;
  core[006140] = 01044; code[006140] = &I06140;
  core[006141] = 07421; code[006141] = &I06141;
  core[006142] = 01043; code[006142] = &I06142;
  core[006143] = 07110; code[006143] = &L06143;
  core[006144] = 07521; code[006144] = &I06144;
  core[006145] = 07010; code[006145] = &I06145;
  core[006146] = 07521; code[006146] = &I06146;
  core[006147] = 02045; code[006147] = &L06147;
  core[006150] = 05343; code[006150] = &I06150;
  core[006151] = 03043; code[006151] = &I06151;
  core[006152] = 07501; code[006152] = &I06152;
  core[006153] = 03044; code[006153] = &I06153;
  core[006154] = 03042; code[006154] = &I06154;
  core[006155] = 07210; code[006155] = &I06155;
  core[006156] = 00115; code[006156] = &I06156;
  core[006157] = 03046; code[006157] = &I06157;
  core[006160] = 01165; code[006160] = &L06160;
  core[006161] = 00115; code[006161] = &I06161;
  core[006162] = 03045; code[006162] = &I06162;
  core[006163] = 05720; code[006163] = &I06163;
  core[006164] = 01025; code[006164] = &L06164;
  core[006165] = 03046; code[006165] = &I06165;
  core[006166] = 05360; code[006166] = &I06166;
  core[006167] = 07340; code[006167] = &L06167;
  core[006170] = 03045; code[006170] = &I06170;
  core[006171] = 07421; code[006171] = &I06171;
  core[006172] = 05347; code[006172] = &I06172;
  core[006177] = 00032; code[006177] = &D06177;
  core[006200] = 00000; code[006200] = &S06200;
  core[006201] = 01024; code[006201] = &I06201;
  core[006202] = 01115; code[006202] = &I06202;
  core[006203] = 07140; code[006203] = &I06203;
  core[006204] = 03045; code[006204] = &I06204;
  core[006205] = 01022; code[006205] = &I06205;
  core[006206] = 03043; code[006206] = &I06206;
  core[006207] = 01023; code[006207] = &I06207;
  core[006210] = 03044; code[006210] = &I06210;
  core[006211] = 01045; code[006211] = &I06211;
  core[006212] = 07650; code[006212] = &I06212;
  core[006213] = 05251; code[006213] = &I06213;
  core[006214] = 01045; code[006214] = &I06214;
  core[006215] = 01164; code[006215] = &I06215;
  core[006216] = 07710; code[006216] = &I06216;
  core[006217] = 05257; code[006217] = &I06217;
  core[006220] = 01044; code[006220] = &I06220;
  core[006221] = 07421; code[006221] = &I06221;
  core[006222] = 01043; code[006222] = &I06222;
  core[006223] = 07100; code[006223] = &L06223;
  core[006224] = 07510; code[006224] = &I06224;
  core[006225] = 07020; code[006225] = &I06225;
  core[006226] = 07010; code[006226] = &I06226;
  core[006227] = 07521; code[006227] = &I06227;
  core[006230] = 07010; code[006230] = &I06230;
  core[006231] = 07521; code[006231] = &I06231;
  core[006232] = 02045; code[006232] = &I06232;
  core[006233] = 05223; code[006233] = &I06233;
  core[006234] = 03043; code[006234] = &I06234;
  core[006235] = 07501; code[006235] = &I06235;
  core[006236] = 03044; code[006236] = &I06236;
  core[006237] = 07210; code[006237] = &L06237;
  core[006240] = 00115; code[006240] = &I06240;
  core[006241] = 03046; code[006241] = &I06241;
  core[006242] = 01043; code[006242] = &I06242;
  core[006243] = 00163; code[006243] = &I06243;
  core[006244] = 03042; code[006244] = &I06244;
  core[006245] = 01165; code[006245] = &L06245;
  core[006246] = 00115; code[006246] = &I06246;
  core[006247] = 03045; code[006247] = &I06247;
  core[006250] = 05600; code[006250] = &I06250;
  core[006251] = 01022; code[006251] = &L06251;
  core[006252] = 00163; code[006252] = &I06252;
  core[006253] = 03042; code[006253] = &I06253;
  core[006254] = 01025; code[006254] = &I06254;
  core[006255] = 03046; code[006255] = &I06255;
  core[006256] = 05245; code[006256] = &I06256;
  core[006257] = 01043; code[006257] = &L06257;
  core[006260] = 00163; code[006260] = &I06260;
  core[006261] = 07104; code[006261] = &I06261;
  core[006262] = 07620; code[006262] = &I06262;
  core[006263] = 05271; code[006263] = &I06263;
  core[006264] = 07040; code[006264] = &I06264;
  core[006265] = 03044; code[006265] = &I06265;
  core[006266] = 07040; code[006266] = &I06266;
  core[006267] = 03043; code[006267] = &L06267;
  core[006270] = 05237; code[006270] = &I06270;
  core[006271] = 03044; code[006271] = &L06271;
  core[006272] = 05267; code[006272] = &I06272;
  core[006273] = 00000; code[006273] = &S06273;
  core[006274] = 01023; code[006274] = &I06274;
  core[006275] = 07101; code[006275] = &I06275;
  core[006276] = 03044; code[006276] = &I06276;
  core[006277] = 07004; code[006277] = &I06277;
  core[006300] = 01022; code[006300] = &I06300;
  core[006301] = 03043; code[006301] = &I06301;
  core[006302] = 07010; code[006302] = &I06302;
  core[006303] = 03042; code[006303] = &I06303;
  core[006304] = 01025; code[006304] = &I06304;
  core[006305] = 03046; code[006305] = &I06305;
  core[006306] = 01024; code[006306] = &I06306;
  core[006307] = 03045; code[006307] = &I06307;
  core[006310] = 05673; code[006310] = &I06310;
  core[006311] = 00000; code[006311] = &S06311;
  core[006312] = 01023; code[006312] = &I06312;
  core[006313] = 07041; code[006313] = &I06313;
  core[006314] = 03044; code[006314] = &I06314;
  core[006315] = 01022; code[006315] = &I06315;
  core[006316] = 07040; code[006316] = &I06316;
  core[006317] = 03043; code[006317] = &I06317;
  core[006320] = 07004; code[006320] = &I06320;
  core[006321] = 01043; code[006321] = &I06321;
  core[006322] = 03043; code[006322] = &I06322;
  core[006323] = 07010; code[006323] = &I06323;
  core[006324] = 03042; code[006324] = &I06324;
  core[006325] = 01025; code[006325] = &I06325;
  core[006326] = 03046; code[006326] = &I06326;
  core[006327] = 01024; code[006327] = &I06327;
  core[006330] = 03045; code[006330] = &I06330;
  core[006331] = 05711; code[006331] = &I06331;
  core[006332] = 00000; code[006332] = &S06332;
  core[006333] = 01023; code[006333] = &I06333;
  core[006334] = 01025; code[006334] = &I06334;
  core[006335] = 03044; code[006335] = &I06335;
  core[006336] = 07204; code[006336] = &I06336;
  core[006337] = 01022; code[006337] = &I06337;
  core[006340] = 01024; code[006340] = &I06340;
  core[006341] = 03043; code[006341] = &I06341;
  core[006342] = 07010; code[006342] = &I06342;
  core[006343] = 03042; code[006343] = &I06343;
  core[006344] = 05732; code[006344] = &I06344;
  core[006345] = 00000; code[006345] = &S06345;
  core[006346] = 01745; code[006346] = &I06346;
  core[006347] = 03374; code[006347] = &I06347;
  core[006350] = 02345; code[006350] = &I06350;
  core[006351] = 01370; code[006351] = &I06351;
  core[006352] = 03372; code[006352] = &I06352;
  core[006353] = 01371; code[006353] = &I06353;
  core[006354] = 03373; code[006354] = &I06354;
  core[006355] = 01772; code[006355] = &L06355;
  core[006356] = 07041; code[006356] = &I06356;
  core[006357] = 01773; code[006357] = &I06357;
  core[006360] = 07640; code[006360] = &I06360;
  core[006361] = 05745; code[006361] = &I06361;
  core[006362] = 02372; code[006362] = &I06362;
  core[006363] = 02373; code[006363] = &I06363;
  core[006364] = 02374; code[006364] = &I06364;
  core[006365] = 05355; code[006365] = &I06365;
  core[006366] = 02345; code[006366] = &I06366;
  core[006367] = 05745; code[006367] = &I06367;
  core[006370] = 00000; code[006370] = &D06370;
  core[006371] = 00000; code[006371] = &D06371;
  core[006372] = 00000; code[006372] = &P06372;
  core[006373] = 00000; code[006373] = &P06373;
  core[006374] = 00000; code[006374] = &D06374;
  core[006400] = 00000; code[006400] = &S06400;
  core[006401] = 07200; code[006401] = &I06401;
  core[006402] = 01600; code[006402] = &I06402;
  core[006403] = 03223; code[006403] = &I06403;
  core[006404] = 02200; code[006404] = &I06404;
  core[006405] = 01600; code[006405] = &I06405;
  core[006406] = 03224; code[006406] = &I06406;
  core[006407] = 02200; code[006407] = &I06407;
  core[006410] = 01600; code[006410] = &D06410;
  core[006411] = 03225; code[006411] = &I06411;
  core[006412] = 02200; code[006412] = &I06412;
  core[006413] = 07200; code[006413] = &L06413;
  core[006414] = 01623; code[006414] = &I06414;
  core[006415] = 03624; code[006415] = &I06415;
  core[006416] = 02223; code[006416] = &I06416;
  core[006417] = 02224; code[006417] = &I06417;
  core[006420] = 02225; code[006420] = &I06420;
  core[006421] = 05213; code[006421] = &I06421;
  core[006422] = 05600; code[006422] = &D06422;
  core[006423] = 00000; code[006423] = &P06423;
  core[006424] = 00000; code[006424] = &P06424;
  core[006425] = 00000; code[006425] = &D06425;
  core[006426] = 00000; code[006426] = &S06426;
  core[006427] = 01377; code[006427] = &I06427;
  core[006430] = 03271; code[006430] = &I06430;
  core[006431] = 01262; code[006431] = &I06431;
  core[006432] = 03243; code[006432] = &I06432;
  core[006433] = 01626; code[006433] = &I06433;
  core[006434] = 02226; code[006434] = &I06434;
  core[006435] = 03270; code[006435] = &I06435;
  core[006436] = 01670; code[006436] = &I06436;
  core[006437] = 03267; code[006437] = &I06437;
  core[006440] = 03270; code[006440] = &L06440;
  core[006441] = 07100; code[006441] = &L06441;
  core[006442] = 01267; code[006442] = &I06442;
  core[006443] = 01263; code[006443] = &D06443;
  core[006444] = 07420; code[006444] = &I06444;
  core[006445] = 05251; code[006445] = &I06445;
  core[006446] = 02270; code[006446] = &I06446;
  core[006447] = 03267; code[006447] = &I06447;
  core[006450] = 05241; code[006450] = &I06450;
  core[006451] = 07200; code[006451] = &L06451;
  core[006452] = 01270; code[006452] = &I06452;
  core[006453] = 01272; code[006453] = &I06453;
  core[006454] = 04526; code[006454] = &I06454;
  core[006455] = 07300; code[006455] = &I06455;
  core[006456] = 02243; code[006456] = &I06456;
  core[006457] = 02271; code[006457] = &I06457;
  core[006460] = 05240; code[006460] = &D06460;
  core[006461] = 05626; code[006461] = &I06461;
  core[006462] = 01263; code[006462] = &D06462;
  core[006463] = 06030; code[006463] = &D06463;
  core[006464] = 07634; code[006464] = &I06464;
  core[006465] = 07766; code[006465] = &I06465;
  core[006466] = 07777; code[006466] = &I06466;
  core[006467] = 00000; code[006467] = &D06467;
  core[006470] = 00000; code[006470] = &P06470;
  core[006471] = 00000; code[006471] = &D06471;
  core[006472] = 00260; code[006472] = &D06472;
  core[006473] = 00000; code[006473] = &S06473;
  core[006474] = 07102; code[006474] = &I06474;
  core[006475] = 07421; code[006475] = &I06475;
  core[006476] = 07501; code[006476] = &I06476;
  core[006477] = 07012; code[006477] = &I06477;
  core[006500] = 07010; code[006500] = &I06500;
  core[006501] = 00376; code[006501] = &I06501;
  core[006502] = 07521; code[006502] = &I06502;
  core[006503] = 07106; code[006503] = &I06503;
  core[006504] = 07004; code[006504] = &I06504;
  core[006505] = 00375; code[006505] = &I06505;
  core[006506] = 07501; code[006506] = &I06506;
  core[006507] = 07421; code[006507] = &P06507;
  core[006510] = 07501; code[006510] = &I06510;
  core[006511] = 00374; code[006511] = &I06511;
  core[006512] = 03324; code[006512] = &I06512;
  core[006513] = 07501; code[006513] = &I06513;
  core[006514] = 00373; code[006514] = &I06514;
  core[006515] = 07112; code[006515] = &I06515;
  core[006516] = 07521; code[006516] = &I06516;
  core[006517] = 00372; code[006517] = &I06517;
  core[006520] = 07106; code[006520] = &I06520;
  core[006521] = 01324; code[006521] = &I06521;
  core[006522] = 07501; code[006522] = &I06522;
  core[006523] = 05673; code[006523] = &I06523;
  core[006524] = 00000; code[006524] = &D06524;
  core[006525] = 00000; code[006525] = &S06525;
  core[006526] = 07200; code[006526] = &I06526;
  core[006527] = 01370; code[006527] = &I06527;
  core[006530] = 01355; code[006530] = &I06530;
  core[006531] = 07640; code[006531] = &I06531;
  core[006532] = 05342; code[006532] = &I06532;
  core[006533] = 01357; code[006533] = &I06533;
  core[006534] = 03355; code[006534] = &I06534;
  core[006535] = 01356; code[006535] = &I06535;
  core[006536] = 07104; code[006536] = &I06536;
  core[006537] = 07430; code[006537] = &I06537;
  core[006540] = 07001; code[006540] = &I06540;
  core[006541] = 03356; code[006541] = &I06541;
  core[006542] = 01356; code[006542] = &L06542;
  core[006543] = 01755; code[006543] = &I06543;
  core[006544] = 03755; code[006544] = &I06544;
  core[006545] = 01371; code[006545] = &I06545;
  core[006546] = 07010; code[006546] = &I06546;
  core[006547] = 01755; code[006547] = &I06547;
  core[006550] = 02355; code[006550] = &I06550;
  core[006551] = 07400; code[006551] = &I06551;
  core[006552] = 03371; code[006552] = &I06552;
  core[006553] = 01371; code[006553] = &I06553;
  core[006554] = 05725; code[006554] = &I06554;
  core[006555] = 06570; code[006555] = &P06555;
  core[006556] = 06543; code[006556] = &D06556;
  core[006557] = 06560; code[006557] = &D06557;
  core[006560] = 06543; code[006560] = &I06560;
  core[006561] = 03210; code[006561] = &I06561;
  core[006562] = 00765; code[006562] = &I06562;
  core[006563] = 05432; code[006563] = &I06563;
  core[006564] = 02107; code[006564] = &I06564;
  core[006565] = 07654; code[006565] = &P06565;
  core[006566] = 04321; code[006566] = &I06566;
  core[006567] = 00176; code[006567] = &I06567;
  core[006570] = 01210; code[006570] = &D06570;
  core[006571] = 00000; code[006571] = &D06571;
  core[006572] = 01111; code[006572] = &D06572;
  core[006573] = 04444; code[006573] = &D06573;
  core[006574] = 02222; code[006574] = &D06574;
  core[006575] = 07070; code[006575] = &D06575;
  core[006576] = 00707; code[006576] = &D06576;
  core[006577] = 07774; code[006577] = &D06577;
  core[006600] = 00000; code[006600] = &S06600;
  core[006601] = 07200; code[006601] = &I06601;
  core[006602] = 01600; code[006602] = &I06602;
  core[006603] = 03263; code[006603] = &I06603;
  core[006604] = 03265; code[006604] = &I06604;
  core[006605] = 02200; code[006605] = &I06605;
  core[006606] = 01663; code[006606] = &L06606;
  core[006607] = 07012; code[006607] = &I06607;
  core[006610] = 07012; code[006610] = &I06610;
  core[006611] = 07012; code[006611] = &I06611;
  core[006612] = 04217; code[006612] = &I06612;
  core[006613] = 01663; code[006613] = &I06613;
  core[006614] = 04217; code[006614] = &I06614;
  core[006615] = 02263; code[006615] = &I06615;
  core[006616] = 05206; code[006616] = &I06616;
  core[006617] = 00000; code[006617] = &S06617;
  core[006620] = 00377; code[006620] = &I06620;
  core[006621] = 03264; code[006621] = &I06621;
  core[006622] = 01265; code[006622] = &I06622;
  core[006623] = 07640; code[006623] = &I06623;
  core[006624] = 05234; code[006624] = &I06624;
  core[006625] = 01264; code[006625] = &I06625;
  core[006626] = 07450; code[006626] = &I06626;
  core[006627] = 05232; code[006627] = &I06627;
  core[006630] = 04253; code[006630] = &L06630;
  core[006631] = 05617; code[006631] = &I06631;
  core[006632] = 02265; code[006632] = &L06632;
  core[006633] = 05617; code[006633] = &I06633;
  core[006634] = 03265; code[006634] = &L06634;
  core[006635] = 01264; code[006635] = &I06635;
  core[006636] = 07041; code[006636] = &I06636;
  core[006637] = 07450; code[006637] = &I06637;
  core[006640] = 05230; code[006640] = &D06640;
  core[006641] = 07001; code[006641] = &I06641;
  core[006642] = 07650; code[006642] = &I06642;
  core[006643] = 05600; code[006643] = &I06643;
  core[006644] = 01266; code[006644] = &I06644;
  core[006645] = 03255; code[006645] = &I06645;
  core[006646] = 01264; code[006646] = &I06646;
  core[006647] = 04253; code[006647] = &I06647;
  core[006650] = 01267; code[006650] = &I06650;
  core[006651] = 03255; code[006651] = &I06651;
  core[006652] = 05617; code[006652] = &I06652;
  core[006653] = 00000; code[006653] = &S06653;
  core[006654] = 01376; code[006654] = &I06654;
  core[006655] = 07510; code[006655] = &D06655;
  core[006656] = 01375; code[006656] = &I06656;
  core[006657] = 01374; code[006657] = &I06657;
  core[006660] = 04526; code[006660] = &I06660;
  core[006661] = 05653; code[006661] = &I06661;
  core[006662] = 00000; code[006662] = &I06662;
  core[006663] = 00000; code[006663] = &P06663;
  core[006664] = 00000; code[006664] = &D06664;
  core[006665] = 00000; code[006665] = &D06665;
  core[006666] = 07500; code[006666] = &D06666;
  core[006667] = 07510; code[006667] = &D06667;
  core[006670] = 00000; code[006670] = &S06670;
  core[006671] = 01670; code[006671] = &I06671;
  core[006672] = 03303; code[006672] = &I06672;
  core[006673] = 02270; code[006673] = &I06673;
  core[006674] = 04450; code[006674] = &L06674;
  core[006675] = 06701; code[006675] = &I06675;
  core[006676] = 02303; code[006676] = &I06676;
  core[006677] = 05274; code[006677] = &I06677;
  core[006700] = 05670; code[006700] = &I06700;
  core[006701] = 04000; code[006701] = &I06701;
  core[006702] = 00100; code[006702] = &I06702;
  core[006703] = 00000; code[006703] = &D06703;
  core[006704] = 00000; code[006704] = &S06704;
  core[006705] = 07300; code[006705] = &I06705;
  core[006706] = 01115; code[006706] = &I06706;
  core[006707] = 07040; code[006707] = &I06707;
  core[006710] = 01373; code[006710] = &I06710;
  core[006711] = 03321; code[006711] = &I06711;
  core[006712] = 04451; code[006712] = &I06712;
  core[006713] = 07774; code[006713] = &I06713;
  core[006714] = 04450; code[006714] = &I06714;
  core[006715] = 06717; code[006715] = &I06715;
  core[006716] = 05704; code[006716] = &I06716;
  core[006717] = 01517; code[006717] = &I06717;
  core[006720] = 00405; code[006720] = &I06720;
  core[006721] = 00000; code[006721] = &D06721;
  core[006722] = 00001; code[006722] = &I06722;
  core[006723] = 00000; code[006723] = &S06723;
  core[006724] = 04451; code[006724] = &I06724;
  core[006725] = 07777; code[006725] = &I06725;
  core[006726] = 05723; code[006726] = &I06726;
  core[006727] = 00000; code[006727] = &S06727;
  core[006730] = 04451; code[006730] = &I06730;
  core[006731] = 07776; code[006731] = &I06731;
  core[006732] = 05727; code[006732] = &I06732;
  core[006733] = 00000; code[006733] = &S06733;
  core[006734] = 04525; code[006734] = &I06734;
  core[006735] = 04451; code[006735] = &I06735;
  core[006736] = 07764; code[006736] = &I06736;
  core[006737] = 04450; code[006737] = &I06737;
  core[006740] = 07407; code[006740] = &I06740;
  core[006741] = 04451; code[006741] = &I06741;
  core[006742] = 07773; code[006742] = &I06742;
  core[006743] = 04450; code[006743] = &I06743;
  core[006744] = 07377; code[006744] = &I06744;
  core[006745] = 04451; code[006745] = &I06745;
  core[006746] = 07767; code[006746] = &I06746;
  core[006747] = 04450; code[006747] = &I06747;
  core[006750] = 07403; code[006750] = &I06750;
  core[006751] = 04451; code[006751] = &I06751;
  core[006752] = 07774; code[006752] = &I06752;
  core[006753] = 04450; code[006753] = &I06753;
  core[006754] = 07456; code[006754] = &I06754;
  core[006755] = 04451; code[006755] = &I06755;
  core[006756] = 07772; code[006756] = &I06756;
  core[006757] = 04450; code[006757] = &I06757;
  core[006760] = 07431; code[006760] = &I06760;
  core[006761] = 05733; code[006761] = &I06761;
  core[006773] = 04002; code[006773] = &D06773;
  core[006774] = 00240; code[006774] = &D06774;
  core[006775] = 00100; code[006775] = &D06775;
  core[006776] = 07740; code[006776] = &D06776;
  core[006777] = 00077; code[006777] = &D06777;
  core[007000] = 00000; code[007000] = &S07000;
  core[007001] = 04576; code[007001] = &I07001;
  core[007002] = 00000; code[007002] = &D07002;
  core[007003] = 04777; code[007003] = &I07003;
  core[007004] = 04525; code[007004] = &I07004;
  core[007005] = 04453; code[007005] = &I07005;
  core[007006] = 00021; code[007006] = &I07006;
  core[007007] = 00026; code[007007] = &I07007;
  core[007010] = 07773; code[007010] = &I07010;
  core[007011] = 04450; code[007011] = &I07011;
  core[007012] = 07412; code[007012] = &I07012;
  core[007013] = 04451; code[007013] = &I07013;
  core[007014] = 07771; code[007014] = &I07014;
  core[007015] = 04246; code[007015] = &I07015;
  core[007016] = 00000; code[007016] = &D07016;
  core[007017] = 04525; code[007017] = &I07017;
  core[007020] = 04450; code[007020] = &I07020;
  core[007021] = 07417; code[007021] = &I07021;
  core[007022] = 04451; code[007022] = &I07022;
  core[007023] = 07773; code[007023] = &I07023;
  core[007024] = 04453; code[007024] = &I07024;
  core[007025] = 00042; code[007025] = &I07025;
  core[007026] = 00026; code[007026] = &I07026;
  core[007027] = 07773; code[007027] = &I07027;
  core[007030] = 04246; code[007030] = &I07030;
  core[007031] = 04525; code[007031] = &I07031;
  core[007032] = 04450; code[007032] = &I07032;
  core[007033] = 07425; code[007033] = &I07033;
  core[007034] = 04451; code[007034] = &I07034;
  core[007035] = 07770; code[007035] = &I07035;
  core[007036] = 04453; code[007036] = &I07036;
  core[007037] = 00033; code[007037] = &I07037;
  core[007040] = 00026; code[007040] = &I07040;
  core[007041] = 07773; code[007041] = &I07041;
  core[007042] = 04246; code[007042] = &I07042;
  core[007043] = 05600; code[007043] = &I07043;
  core[007044] = 04776; code[007044] = &D07044;
  core[007045] = 04775; code[007045] = &D07045;
  core[007046] = 00000; code[007046] = &S07046;
  core[007047] = 01026; code[007047] = &I07047;
  core[007050] = 04555; code[007050] = &I07050;
  core[007051] = 04455; code[007051] = &I07051;
  core[007052] = 01027; code[007052] = &I07052;
  core[007053] = 04774; code[007053] = &I07053;
  core[007054] = 04455; code[007054] = &I07054;
  core[007055] = 01030; code[007055] = &I07055;
  core[007056] = 04774; code[007056] = &I07056;
  core[007057] = 04451; code[007057] = &I07057;
  core[007060] = 07775; code[007060] = &I07060;
  core[007061] = 01032; code[007061] = &I07061;
  core[007062] = 04555; code[007062] = &I07062;
  core[007063] = 04451; code[007063] = &I07063;
  core[007064] = 07774; code[007064] = &I07064;
  core[007065] = 01031; code[007065] = &I07065;
  core[007066] = 04774; code[007066] = &I07066;
  core[007067] = 05646; code[007067] = &I07067;
  core[007070] = 00000; code[007070] = &S07070;
  core[007071] = 04451; code[007071] = &I07071;
  core[007072] = 07775; code[007072] = &I07072;
  core[007073] = 01024; code[007073] = &I07073;
  core[007074] = 07001; code[007074] = &I07074;
  core[007075] = 01115; code[007075] = &I07075;
  core[007076] = 03116; code[007076] = &I07076;
  core[007077] = 04773; code[007077] = &I07077;
  core[007100] = 00116; code[007100] = &I07100;
  core[007101] = 04455; code[007101] = &I07101;
  core[007102] = 04450; code[007102] = &I07102;
  core[007103] = 07447; code[007103] = &I07103;
  core[007104] = 04455; code[007104] = &I07104;
  core[007105] = 05670; code[007105] = &I07105;
  core[007106] = 00000; code[007106] = &S07106;
  core[007107] = 04576; code[007107] = &I07107;
  core[007110] = 04772; code[007110] = &I07110;
  core[007111] = 04525; code[007111] = &I07111;
  core[007112] = 04450; code[007112] = &I07112;
  core[007113] = 07407; code[007113] = &I07113;
  core[007114] = 04451; code[007114] = &I07114;
  core[007115] = 07773; code[007115] = &I07115;
  core[007116] = 01042; code[007116] = &I07116;
  core[007117] = 04555; code[007117] = &I07117;
  core[007120] = 04451; code[007120] = &I07120;
  core[007121] = 07761; code[007121] = &I07121;
  core[007122] = 01033; code[007122] = &I07122;
  core[007123] = 04555; code[007123] = &I07123;
  core[007124] = 04524; code[007124] = &I07124;
  core[007125] = 04450; code[007125] = &I07125;
  core[007126] = 07377; code[007126] = &I07126;
  core[007127] = 04451; code[007127] = &I07127;
  core[007130] = 07774; code[007130] = &I07130;
  core[007131] = 01043; code[007131] = &I07131;
  core[007132] = 04774; code[007132] = &I07132;
  core[007133] = 04451; code[007133] = &I07133;
  core[007134] = 07774; code[007134] = &I07134;
  core[007135] = 01034; code[007135] = &I07135;
  core[007136] = 04774; code[007136] = &I07136;
  core[007137] = 04524; code[007137] = &I07137;
  core[007140] = 04450; code[007140] = &I07140;
  core[007141] = 07514; code[007141] = &I07141;
  core[007142] = 04451; code[007142] = &I07142;
  core[007143] = 07755; code[007143] = &I07143;
  core[007144] = 01036; code[007144] = &I07144;
  core[007145] = 04774; code[007145] = &I07145;
  core[007146] = 04524; code[007146] = &I07146;
  core[007147] = 04450; code[007147] = &I07147;
  core[007150] = 07403; code[007150] = &I07150;
  core[007151] = 04451; code[007151] = &I07151;
  core[007152] = 07774; code[007152] = &I07152;
  core[007153] = 01044; code[007153] = &I07153;
  core[007154] = 04774; code[007154] = &I07154;
  core[007155] = 04451; code[007155] = &I07155;
  core[007156] = 07774; code[007156] = &I07156;
  core[007157] = 01035; code[007157] = &I07157;
  core[007160] = 04774; code[007160] = &I07160;
  core[007161] = 04524; code[007161] = &I07161;
  core[007162] = 04450; code[007162] = &I07162;
  core[007163] = 07520; code[007163] = &I07163;
  core[007164] = 04451; code[007164] = &I07164;
  core[007165] = 07755; code[007165] = &I07165;
  core[007166] = 01037; code[007166] = &I07166;
  core[007167] = 04774; code[007167] = &I07167;
  core[007170] = 05706; code[007170] = &I07170;
  core[007172] = 07204; code[007172] = &P07172;
  core[007173] = 06426; code[007173] = &P07173;
  core[007174] = 07200; code[007174] = &P07174;
  core[007175] = 05541; code[007175] = &P07175;
  core[007176] = 07230; code[007176] = &P07176;
  core[007177] = 06733; code[007177] = &P07177;
  core[007200] = 00000; code[007200] = &S07200;
  core[007201] = 03106; code[007201] = &I07201;
  core[007202] = 04531; code[007202] = &I07202;
  core[007203] = 05600; code[007203] = &I07203;
  core[007204] = 00000; code[007204] = &S07204;
  core[007205] = 04525; code[007205] = &I07205;
  core[007206] = 04454; code[007206] = &I07206;
  core[007207] = 04450; code[007207] = &I07207;
  core[007210] = 07527; code[007210] = &I07210;
  core[007211] = 04451; code[007211] = &I07211;
  core[007212] = 07772; code[007212] = &I07212;
  core[007213] = 04450; code[007213] = &I07213;
  core[007214] = 07504; code[007214] = &I07214;
  core[007215] = 04454; code[007215] = &I07215;
  core[007216] = 04450; code[007216] = &I07216;
  core[007217] = 07501; code[007217] = &I07217;
  core[007220] = 04451; code[007220] = &I07220;
  core[007221] = 07772; code[007221] = &I07221;
  core[007222] = 04450; code[007222] = &I07222;
  core[007223] = 07510; code[007223] = &I07223;
  core[007224] = 04454; code[007224] = &I07224;
  core[007225] = 04450; code[007225] = &I07225;
  core[007226] = 07501; code[007226] = &I07226;
  core[007227] = 05604; code[007227] = &I07227;
  core[007230] = 00000; code[007230] = &S07230;
  core[007231] = 04525; code[007231] = &I07231;
  core[007232] = 04450; code[007232] = &I07232;
  core[007233] = 07536; code[007233] = &I07233;
  core[007234] = 04451; code[007234] = &I07234;
  core[007235] = 07772; code[007235] = &I07235;
  core[007236] = 01040; code[007236] = &I07236;
  core[007237] = 04200; code[007237] = &I07237;
  core[007240] = 04455; code[007240] = &D07240;
  core[007241] = 01041; code[007241] = &I07241;
  core[007242] = 04200; code[007242] = &I07242;
  core[007243] = 05630; code[007243] = &I07243;
  core[007244] = 00000; code[007244] = &I07244;
  core[007245] = 00000; code[007245] = &I07245;
  core[007246] = 07777; code[007246] = &I07246;
  core[007247] = 04000; code[007247] = &I07247;
  core[007250] = 07777; code[007250] = &I07250;
  core[007251] = 00000; code[007251] = &I07251;
  core[007252] = 00000; code[007252] = &L07252;
  core[007253] = 07777; code[007253] = &I07253;
  core[007254] = 07777; code[007254] = &I07254;
  core[007255] = 00000; code[007255] = &I07255;
  core[007256] = 00000; code[007256] = &I07256;
  core[007257] = 00000; code[007257] = &I07257;
  core[007260] = 00000; code[007260] = &I07260;
  core[007261] = 00001; code[007261] = &I07261;
  core[007262] = 00002; code[007262] = &I07262;
  core[007263] = 00000; code[007263] = &I07263;
  core[007264] = 03776; code[007264] = &I07264;
  core[007265] = 03777; code[007265] = &I07265;
  core[007266] = 04000; code[007266] = &I07266;
  core[007267] = 03777; code[007267] = &I07267;
  core[007270] = 03776; code[007270] = &I07270;
  core[007271] = 04000; code[007271] = &I07271;
  core[007272] = 04777; code[007272] = &I07272;
  core[007273] = 04776; code[007273] = &I07273;
  core[007274] = 00000; code[007274] = &I07274;
  core[007275] = 04776; code[007275] = &I07275;
  core[007276] = 04777; code[007276] = &I07276;
  core[007277] = 04000; code[007277] = &I07277;
  core[007300] = 07777; code[007300] = &D07300;
  core[007301] = 03776; code[007301] = &I07301;
  core[007302] = 00000; code[007302] = &I07302;
  core[007303] = 03776; code[007303] = &I07303;
  core[007304] = 07777; code[007304] = &I07304;
  core[007305] = 00000; code[007305] = &I07305;
  core[007306] = 07777; code[007306] = &I07306;
  core[007307] = 07777; code[007307] = &I07307;
  core[007310] = 04000; code[007310] = &I07310;
  core[007311] = 00000; code[007311] = &I07311;
  core[007312] = 00000; code[007312] = &I07312;
  core[007313] = 04000; code[007313] = &I07313;
  core[007314] = 02525; code[007314] = &I07314;
  core[007315] = 05252; code[007315] = &I07315;
  core[007316] = 00000; code[007316] = &I07316;
  core[007317] = 05252; code[007317] = &I07317;
  core[007320] = 02525; code[007320] = &I07320;
  core[007321] = 00000; code[007321] = &I07321;
  core[007322] = 07007; code[007322] = &I07322;
  core[007323] = 00770; code[007323] = &I07323;
  core[007324] = 04000; code[007324] = &I07324;
  core[007325] = 00770; code[007325] = &I07325;
  core[007326] = 07007; code[007326] = &I07326;
  core[007327] = 00000; code[007327] = &I07327;
  core[007330] = 00000; code[007330] = &I07330;
  core[007331] = 00000; code[007331] = &I07331;
  core[007332] = 00000; code[007332] = &I07332;
  core[007333] = 00000; code[007333] = &I07333;
  core[007334] = 04000; code[007334] = &I07334;
  core[007335] = 07777; code[007335] = &I07335;
  core[007336] = 07777; code[007336] = &I07336;
  core[007337] = 00000; code[007337] = &I07337;
  core[007340] = 00000; code[007340] = &I07340;
  core[007341] = 04000; code[007341] = &I07341;
  core[007342] = 00000; code[007342] = &I07342;
  core[007343] = 00000; code[007343] = &I07343;
  core[007344] = 07777; code[007344] = &I07344;
  core[007345] = 07777; code[007345] = &I07345;
  core[007346] = 00000; code[007346] = &I07346;
  core[007347] = 02525; code[007347] = &I07347;
  core[007350] = 05252; code[007350] = &D07350;
  core[007351] = 05252; code[007351] = &I07351;
  core[007352] = 02525; code[007352] = &I07352;
  core[007353] = 04000; code[007353] = &I07353;
  core[007354] = 05252; code[007354] = &I07354;
  core[007355] = 02525; code[007355] = &I07355;
  core[007356] = 02525; code[007356] = &I07356;
  core[007357] = 05252; code[007357] = &I07357;
  core[007360] = 04000; code[007360] = &I07360;
  core[007361] = 00770; code[007361] = &I07361;
  core[007362] = 07007; code[007362] = &I07362;
  core[007363] = 07007; code[007363] = &I07363;
  core[007364] = 00770; code[007364] = &I07364;
  core[007365] = 00000; code[007365] = &I07365;
  core[007366] = 07007; code[007366] = &I07366;
  core[007367] = 00770; code[007367] = &I07367;
  core[007370] = 00770; code[007370] = &P07370;
  core[007371] = 07007; code[007371] = &I07371;
  core[007372] = 00000; code[007372] = &I07372;
  core[007373] = 07777; code[007373] = &I07373;
  core[007374] = 07777; code[007374] = &I07374;
  core[007375] = 07777; code[007375] = &I07375;
  core[007376] = 07777; code[007376] = &P07376;
  core[007377] = 00350; code[007377] = &P07377;
  core[007400] = 00103; code[007400] = &D07400;
  core[007401] = 05100; code[007401] = &I07401;
  core[007402] = 00100; code[007402] = &I07402;
  core[007403] = 00350; code[007403] = &I07403;
  core[007404] = 01521; code[007404] = &I07404;
  core[007405] = 05100; code[007405] = &D07405;
  core[007406] = 00100; code[007406] = &I07406;
  core[007407] = 00350; code[007407] = &I07407;
  core[007410] = 01451; code[007410] = &I07410;
  core[007411] = 00001; code[007411] = &P07411;
  core[007412] = 02022; code[007412] = &I07412;
  core[007413] = 01702; code[007413] = &I07413;
  core[007414] = 01405; code[007414] = &I07414;
  core[007415] = 01500; code[007415] = &I07415;
  core[007416] = 00100; code[007416] = &I07416;
  core[007417] = 02311; code[007417] = &P07417;
  core[007420] = 01525; code[007420] = &I07420;
  core[007421] = 01401; code[007421] = &D07421;
  core[007422] = 02405; code[007422] = &I07422;
  core[007423] = 00400; code[007423] = &I07423;
  core[007424] = 00100; code[007424] = &I07424;
  core[007425] = 00103; code[007425] = &I07425;
  core[007426] = 02425; code[007426] = &I07426;
  core[007427] = 00114; code[007427] = &I07427;
  core[007430] = 00001; code[007430] = &D07430;
  core[007431] = 00350; code[007431] = &I07431;
  core[007432] = 02303; code[007432] = &I07432;
  core[007433] = 05100; code[007433] = &I07433;
  core[007434] = 00100; code[007434] = &I07434;
  core[007435] = 02310; code[007435] = &I07435;
  core[007436] = 01400; code[007436] = &I07436;
  core[007437] = 00100; code[007437] = &I07437;
  core[007440] = 02405; code[007440] = &I07440;
  core[007441] = 02324; code[007441] = &I07441;
  core[007442] = 00001; code[007442] = &I07442;
  core[007443] = 06000; code[007443] = &I07443;
  core[007444] = 00100; code[007444] = &I07444;
  core[007445] = 06100; code[007445] = &I07445;
  core[007446] = 00100; code[007446] = &I07446;
  core[007447] = 02310; code[007447] = &I07447;
  core[007450] = 01106; code[007450] = &I07450;
  core[007451] = 02423; code[007451] = &I07451;
  core[007452] = 00001; code[007452] = &I07452;
  core[007453] = 01423; code[007453] = &I07453;
  core[007454] = 02200; code[007454] = &I07454;
  core[007455] = 00100; code[007455] = &I07455;
  core[007456] = 00350; code[007456] = &I07456;
  core[007457] = 00724; code[007457] = &I07457;
  core[007460] = 05100; code[007460] = &I07460;
  core[007461] = 00100; code[007461] = &I07461;
  core[007462] = 00123; code[007462] = &I07462;
  core[007463] = 02200; code[007463] = &I07463;
  core[007464] = 00100; code[007464] = &I07464;
  core[007465] = 00420; code[007465] = &I07465;
  core[007466] = 02332; code[007466] = &I07466;
  core[007467] = 00001; code[007467] = &I07467;
  core[007470] = 00420; code[007470] = &I07470;
  core[007471] = 01103; code[007471] = &I07471;
  core[007472] = 00001; code[007472] = &I07472;
  core[007473] = 00403; code[007473] = &I07473;
  core[007474] = 01500; code[007474] = &I07474;
  core[007475] = 00100; code[007475] = &I07475;
  core[007476] = 00401; code[007476] = &I07476;
  core[007477] = 00400; code[007477] = &I07477;
  core[007500] = 00100; code[007500] = &P07500;
  core[007501] = 00423; code[007501] = &D07501;
  core[007502] = 02400; code[007502] = &P07502;
  core[007503] = 00100; code[007503] = &P07503;
  core[007504] = 00205; code[007504] = &I07504;
  core[007505] = 00617; code[007505] = &D07505;
  core[007506] = 02205; code[007506] = &I07506;
  core[007507] = 00001; code[007507] = &I07507;
  core[007510] = 00106; code[007510] = &D07510;
  core[007511] = 02405; code[007511] = &D07511;
  core[007512] = 02200; code[007512] = &I07512;
  core[007513] = 00100; code[007513] = &D07513;
  core[007514] = 00350; code[007514] = &I07514;
  core[007515] = 01523; code[007515] = &I07515;
  core[007516] = 01051; code[007516] = &I07516;
  core[007517] = 00001; code[007517] = &I07517;
  core[007520] = 00350; code[007520] = &I07520;
  core[007521] = 01423; code[007521] = &I07521;
  core[007522] = 01051; code[007522] = &I07522;
  core[007523] = 00001; code[007523] = &I07523;
  core[007524] = 02301; code[007524] = &P07524;
  core[007525] = 01500; code[007525] = &D07525;
  core[007526] = 00100; code[007526] = &I07526;
  core[007527] = 02205; code[007527] = &I07527;
  core[007530] = 00700; code[007530] = &I07530;
  core[007531] = 00100; code[007531] = &I07531;
  core[007532] = 01305; code[007532] = &D07532;
  core[007533] = 07040; code[007533] = &I07533;
  core[007534] = 06100; code[007534] = &I07534;
  core[007535] = 00100; code[007535] = &I07535;
  core[007536] = 02417; code[007536] = &I07536;
  core[007537] = 04002; code[007537] = &I07537;
  core[007540] = 00540; code[007540] = &P07540;
  core[007541] = 00104; code[007541] = &I07541;
  core[007542] = 00405; code[007542] = &I07542;
  core[007543] = 00400; code[007543] = &I07543;
  core[007544] = 00100; code[007544] = &I07544;
  core[007545] = 02313; code[007545] = &I07545;
  core[007546] = 01120; code[007546] = &I07546;
  core[007547] = 04017; code[007547] = &I07547;
  core[007550] = 00303; code[007550] = &D07550;
  core[007551] = 02522; code[007551] = &I07551;
  core[007552] = 00504; code[007552] = &I07552;
  core[007553] = 00001; code[007553] = &I07553;
  core[007554] = 01617; code[007554] = &I07554;
  core[007555] = 04023; code[007555] = &I07555;
  core[007556] = 01311; code[007556] = &I07556;
  core[007557] = 02040; code[007557] = &I07557;
  core[007560] = 01703; code[007560] = &I07560;
  core[007561] = 00325; code[007561] = &I07561;
  core[007562] = 02205; code[007562] = &I07562;
  core[007563] = 00400; code[007563] = &I07563;
  core[007564] = 00100; code[007564] = &I07564;
  core[007565] = 02205; code[007565] = &I07565;
  core[007566] = 00740; code[007566] = &I07566;
  core[007567] = 01517; code[007567] = &I07567;
  core[007570] = 00411; code[007570] = &I07570;
  core[007571] = 00611; code[007571] = &I07571;
  core[007572] = 00504; code[007572] = &I07572;
  core[007573] = 00001; code[007573] = &I07573;
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

