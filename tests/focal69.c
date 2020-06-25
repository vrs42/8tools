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
void P00001() { npc = (ib<<12)+core[3]; inh = 0;  }
void P00002() { npc = (ib<<12)+core[3]; inh = 0;  }
void P00003() { if (++core[(df<<12)+core[3]] == 010000) { core[(df<<12)+core[3]] = 0; npc++; }; code[(df<<12)+core[3]] = &emul8;  }
void D00004() { lac &= (010000|core[000004]);  }
void P00005() { lac &= (010000|core[000013]);  }
void D00006() { lac &= (010000|core[000100]);  }
void P00007() { emul8();  }
void P00010() { lac &= (010000|core[000000]);  }
void P00011() { lac &= (010000|core[000000]);  }
void P00012() { lac &= (010000|core[000000]);  }
void P00013() { core[000170] = 00014; npc = 000170+1; code[000170] = &emul8; inh = 0;  }
void P00014() { core[000117] = lac & 07777; lac &= 010000; code[000117] = &emul8;  }
void P00015() { lac &= (010000|core[000000]);  }
void P00016() { hlt = 1;  }
void P00017() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void P00020() { lac &= (010000|core[000000]);  }
void P00021() { lac &= (010000|core[000000]);  }
void P00022() { if (++core[(df<<12)+core[7]] == 010000) { core[(df<<12)+core[7]] = 0; npc++; }; code[(df<<12)+core[7]] = &emul8;  }
void P00023() { lac &= (010000|core[000000]);  }
void P00024() { lac &= (010000|core[000000]);  }
void P00025() { lac &= (010000|core[000000]);  }
void D00026() { lac &= (010000|core[000001]);  }
void P00027() { lac &= (010000|core[000000]);  }
void P00030() { lac &= (010000|core[000000]);  }
void P00031() { core[(df<<12)+core[112]] = lac & 07777; lac &= 010000; code[(df<<12)+core[112]] = &emul8;  }
void D00032() { lac &= (010000|core[000000]);  }
void D00033() { lac &= (010000|core[000000]);  }
void P00034() { lac &= (010000|core[000000]);  }
void P00035() { core[000170] = 00036; npc = 000170+1; code[000170] = &emul8; inh = 0;  }
void P00036() { lac &= (010000|core[000000]);  }
void P00037() { lac &= (010000|core[000000]);  }
void P00040() { lac &= (010000|core[000000]);  }
void D00041() { lac &= (010000|core[000000]);  }
void P00042() { lac &= (010000|core[000000]);  }
void P00043() { lac &= (010000|core[000000]);  }
void D00044() { lac &= (010000|core[000000]);  }
void D00045() { lac &= (010000|core[000000]);  }
void D00046() { lac &= (010000|core[000000]);  }
void D00047() { lac &= (010000|core[000000]);  }
void P00050() { lac &= (010000|core[000000]);  }
void P00051() { emul8();  }
void D00052() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void P00053() { emul8();  }
void P00054() { lac &= (010000|core[000000]);  }
void P00055() { lac &= (010000|core[000000]);  }
void D00056() { lac &= (010000|core[000000]);  }
void P00057() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void P00060() { core[(df<<12)+core[112]] = lac & 07777; lac &= 010000; code[(df<<12)+core[112]] = &emul8;  }
void P00061() { lac += core[000154];  }
void P00062() { if (++core[000014] == 010000) core[000014] = 0000;if (++core[(df<<12)+core[000014]] == 010000) { core[(df<<12)+core[000014]] = 0; npc++; }; code[(df<<12)+core[000014]] = &emul8;  }
void P00063() { if (++core[(df<<12)+core[62]] == 010000) { core[(df<<12)+core[62]] = 0; npc++; }; code[(df<<12)+core[62]] = &emul8;  }
void P00064() { if (++core[(df<<12)+core[54]] == 010000) { core[(df<<12)+core[54]] = 0; npc++; }; code[(df<<12)+core[54]] = &emul8;  }
void P00065() { lac &= (010000|core[000001]);  }
void P00066() { lac &= (010000|core[000015]);  }
void D00067() { lac &= (010000|core[000000]);  }
void D00070() { lac &= (010000|core[000005]);  }
void P00071() { lac &= (010000|core[000000]);  }
void I00072() { lac &= (010000|core[000014]);  }
void D00073() { lac &= (010000|core[000007]);  }
void P00074() { lac &= (010000|core[000003]);  }
void D00075() { lac &= (010000|core[000137]);  }
void P00076() { lac &= (010000|core[000012]);  }
void P00077() { lac &= (010000|core[000015]);  }
void P00100() { hlt = 1;  }
void P00101() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void P00102() { lac &= (010000|core[000056]);  }
void D00103() { emul8();  }
void P00104() { lac &= 010000;  }
void D00105() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void D00106() { lac &= (010000|core[000177]);  }
void P00107() { lac &= (010000|core[000017]);  }
void D00110() { lac &= (010000|core[000077]);  }
void D00111() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void D00112() { emul8();  }
void D00113() { lac &= (010000|core[000060]);  }
void P00114() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp;  }
void P00115() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; hlt = 1;  }
void D00116() { emul8();  }
void P00117() { emul8();  }
void P00120() { emul8();  }
void P00121() { emul8();  }
void P00122() { lac &= (010000|core[000077]);  }
void P00123() { lac &= (010000|core[000000]);  }
void P00124() { core[000000] = 00125; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void P00125() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void P00126() { if (++core[000155] == 010000) { core[000155] = 0; npc++; }; code[000155] = &emul8;  }
void P00127() { npc = (ib<<12)+core[77]; inh = 0;  }
void P00130() { emul8();  }
void P00131() { emul8();  }
void P00132() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void P00133() { core[000006] = lac & 07777; lac &= 010000; code[000006] = &emul8;  }
void P00134() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void P00135() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void P00136() { if (++core[000017] == 010000) { core[000017] = 0; npc++; }; code[000017] = &emul8;  }
void D00137() { if (++core[(df<<12)+core[7]] == 010000) { core[(df<<12)+core[7]] = 0; npc++; }; code[(df<<12)+core[7]] = &emul8;  }
void P00140() { lac &= (010000|core[(df<<12)+core[81]]);  }
void P00141() { lac += core[(df<<12)+core[117]];  }
void P00142() { lac &= (010000|core[(df<<12)+core[63]]);  }
void P00143() { lac &= (010000|core[(df<<12)+core[92]]);  }
void P00144() { lac &= (010000|core[(df<<12)+core[108]]);  }
void P00145() { if (++core[000074] == 010000) { core[000074] = 0; npc++; }; code[000074] = &emul8;  }
void P00146() { if (++core[(df<<12)+core[66]] == 010000) { core[(df<<12)+core[66]] = 0; npc++; }; code[(df<<12)+core[66]] = &emul8;  }
void P00147() { lac += core[000114];  }
void P00150() { lac &= (010000|core[(df<<12)+core[81]]);  }
void P00151() { if (++core[(df<<12)+core[53]] == 010000) { core[(df<<12)+core[53]] = 0; npc++; }; code[(df<<12)+core[53]] = &emul8;  }
void P00152() { if (++core[000155] == 010000) { core[000155] = 0; npc++; }; code[000155] = &emul8;  }
void P00153() { if (++core[(df<<12)+core[21]] == 010000) { core[(df<<12)+core[21]] = 0; npc++; }; code[(df<<12)+core[21]] = &emul8;  }
void P00154() { lac &= (010000|core[000102]);  }
void P00155() { if (++core[000042] == 010000) { core[000042] = 0; npc++; }; code[000042] = &emul8;  }
void P00156() { if (++core[000160] == 010000) { core[000160] = 0; npc++; }; code[000160] = &emul8;  }
void P00157() { if (++core[000013] == 010000) core[000013] = 0000;lac &= (010000|core[(df<<12)+core[000013]]);  }
void P00160() { lac += core[(df<<12)+core[79]];  }
void P00161() { lac += core[(df<<12)+core[91]];  }
void P00162() { if (++core[000035] == 010000) { core[000035] = 0; npc++; }; code[000035] = &emul8;  }
void P00163() { lac &= (010000|core[(df<<12)+core[100]]);  }
void P00164() { lac &= (010000|core[(df<<12)+core[64]]);  }
void P00165() { if (++core[000062] == 010000) { core[000062] = 0; npc++; }; code[000062] = &emul8;  }
void P00166() { if (++core[(df<<12)+core[86]] == 010000) { core[(df<<12)+core[86]] = 0; npc++; }; code[(df<<12)+core[86]] = &emul8;  }
void P00176() { core[000171] = 00177; npc = 000171+1; code[000171] = &emul8; inh = 0;  }
void L00177() { skp = 0; skp = !skp; npc += skp; lac &= 010000;  }
void P00200() { npc = (ib<<12)+core[126]; inh = 0;  }
void I00201() { lac += core[000137];  }
void I00202() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void D00203() { lac++;  }
void I00204() { core[000100] = lac & 07777; lac &= 010000; code[000100] = &emul8;  }
void I00205() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void I00206() { lac += core[000226];  }
void I00207() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I00210() { lac += core[000225];  }
void P00211() { core[(ib<<12)+core[105]] = 00212; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void L00212() { lac += core[000132];  }
void I00213() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00214() { core[000062] = lac & 07777; lac &= 010000; code[000062] = &emul8;  }
void D00215() { lac += core[000132];  }
void I00216() { core[000027] = lac & 07777; lac &= 010000; code[000027] = &emul8;  }
void L00217() { core[(ib<<12)+core[106]] = 00220; npc = (ib<<12)+core[106]+1; code[(ib<<12)+core[106]] = &emul8; inh = 0;  }
void D00220() { core[(ib<<12)+core[103]] = 00221; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I00221() { lac &= (010000|core[000073]);  }
void I00222() { lac &= (010000|core[(df<<12)+core[60]]);  }
void I00223() { core[(ib<<12)+core[102]] = 00224; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I00224() { npc = 000217; inh = 0;  }
void D00225() { lac &= (010000|core[000252]);  }
void D00226() { core[000220] = lac & 07777; lac &= 010000; code[000220] = &emul8;  }
void I00227() { core[(ib<<12)+core[102]] = 00230; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I00230() { core[(ib<<12)+core[102]] = 00231; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I00231() { lac += core[000132];  }
void L00232() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I00233() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I00234() { core[(ib<<12)+core[101]] = 00235; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I00235() { lac += core[000035];  }
void I00236() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I00237() { core[(ib<<12)+core[112]] = 00240; npc = (ib<<12)+core[112]+1; code[(ib<<12)+core[112]] = &emul8; inh = 0;  }
void I00240() { core[(ib<<12)+core[113]] = 00241; npc = (ib<<12)+core[113]+1; code[(ib<<12)+core[113]] = &emul8; inh = 0;  }
void I00241() { npc = 000362; inh = 0;  }
void D00242() { npc = 000271; inh = 0;  }
void I00243() { if (++core[000026] == 010000) { core[000026] = 0; npc++; }; code[000026] = &emul8;  }
void I00244() { core[(ib<<12)+core[108]] = 00245; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I00245() { lac += core[000124];  }
void I00246() { lac += core[000065];  }
void I00247() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00250() { core[(ib<<12)+core[118]] = 00251; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I00251() { lac += core[000060];  }
void D00252() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00253() { core[000062] = lac & 07777; lac &= 010000; code[000062] = &emul8;  }
void I00254() { lac += core[000067];  }
void I00255() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void D00256() { core[(ib<<12)+core[112]] = 00257; npc = (ib<<12)+core[112]+1; code[(ib<<12)+core[112]] = &emul8; inh = 0;  }
void I00257() { skp = 0; skp = !skp; npc += skp;  }
void L00260() { core[(ib<<12)+core[101]] = 00261; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I00261() { core[(ib<<12)+core[102]] = 00262; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I00262() { lac += core[000066];  }
void I00263() { lac += core[000116];  }
void I00264() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00265() { npc = 000260; inh = 0;  }
void I00266() { core[(ib<<12)+core[117]] = 00267; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void I00267() { core[(ib<<12)+core[110]] = 00270; npc = (ib<<12)+core[110]+1; code[(ib<<12)+core[110]] = &emul8; inh = 0;  }
void I00270() { npc = 000177; inh = 0;  }
void L00271() { core[(ib<<12)+core[96]] = 00272; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I00272() { lac &= (010000|core[(df<<12)+core[137]]);  }
void D00273() { lac += core[(df<<12)+core[18]];  }
void I00274() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00275() { npc = 000177; inh = 0;  }
void I00276() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void I00277() { lac += core[000022];  }
void I00300() { lac++;  }
void I00301() { npc = 000232; inh = 0;  }
void S00302() { lac &= (010000|core[000000]);  }
void D00303() { core[(ib<<12)+core[112]] = 00304; npc = (ib<<12)+core[112]+1; code[(ib<<12)+core[112]] = &emul8; inh = 0;  }
void I00304() { lac += core[000066];  }
void I00305() { lac += core[000112];  }
void I00306() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00307() { npc = 000322; inh = 0;  }
void I00310() { core[000036] = lac & 07777; lac &= 010000; code[000036] = &emul8;  }
void I00311() { core[(ib<<12)+core[249]] = 00312; npc = (ib<<12)+core[249]+1; code[(ib<<12)+core[249]] = &emul8; inh = 0;  }
void I00312() { lac += core[000047];  }
void I00313() { lac &= (010000|core[000372]);  }
void I00314() { lac += core[000046];  }
void I00315() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00316() { core[(ib<<12)+core[118]] = 00317; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I00317() { lac += core[000047];  }
void I00320() { core[(ib<<12)+core[111]] = 00321; npc = (ib<<12)+core[111]+1; code[(ib<<12)+core[111]] = &emul8; inh = 0;  }
void D00321() { lac = (lac<<1) + ((lac>>12)&1);  }
void L00322() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00323() { core[(ib<<12)+core[113]] = 00324; npc = (ib<<12)+core[113]+1; code[(ib<<12)+core[113]] = &emul8; inh = 0;  }
void D00324() { core[(ib<<12)+core[101]] = 00325; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I00325() { core[(ib<<12)+core[113]] = 00326; npc = (ib<<12)+core[113]+1; code[(ib<<12)+core[113]] = &emul8; inh = 0;  }
void I00326() { npc = 000340; inh = 0;  }
void I00327() { npc = 000352; inh = 0;  }
void I00330() { lac += core[000054];  }
void I00331() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00332() { lac += core[000054];  }
void I00333() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00334() { lac += core[000067];  }
void I00335() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00336() { core[(ib<<12)+core[101]] = 00337; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I00337() { core[(ib<<12)+core[113]] = 00340; npc = (ib<<12)+core[113]+1; code[(ib<<12)+core[113]] = &emul8; inh = 0;  }
void L00340() { core[(ib<<12)+core[118]] = 00341; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I00341() { npc = 000352; inh = 0;  }
void I00342() { lac += core[000054];  }
void I00343() { lac += core[000067];  }
void I00344() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00345() { core[(ib<<12)+core[101]] = 00346; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I00346() { core[(ib<<12)+core[113]] = 00347; npc = (ib<<12)+core[113]+1; code[(ib<<12)+core[113]] = &emul8; inh = 0;  }
void I00347() { npc = 000340; inh = 0;  }
void I00350() { skp = 0; skp = !skp; npc += skp;  }
void I00351() { core[(ib<<12)+core[118]] = 00352; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void L00352() { lac &= 07777;  }
void I00353() { lac += core[000067];  }
void I00354() { lac &= (010000|core[000104]);  }
void I00355() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00356() { lac ^= 010000;  }
void I00357() { lac += core[000067];  }
void I00360() { lac &= (010000|core[000106]);  }
void I00361() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void L00362() { core[(ib<<12)+core[118]] = 00363; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I00363() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00364() { lac += core[000373];  }
void I00365() { lac ^= 010000;  }
void I00366() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00367() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I00370() { npc = (ib<<12)+core[194]; inh = 0;  }
void P00371() { npc = (ib<<12)+core[128]; inh = 0;  }
void D00372() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D00373() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I00374() { if (++core[000014] == 010000) { core[000014] = 0; npc++; }; code[000014] = &emul8;  }
void I00375() { if (++core[000010] == 010000) { core[000010] = 0; npc++; }; code[000010] = &emul8;  }
void I00376() { lac += core[000160];  }
void I00377() { lac += core[000142];  }
void L00400() { lac += core[(df<<12)+core[107]];  }
void I00401() { lac += core[000543];  }
void I00402() { npc = 000000; inh = 0;  }
void I00403() { core[(ib<<12)+core[272]] = 00404; npc = (ib<<12)+core[272]+1; code[(ib<<12)+core[272]] = &emul8; inh = 0;  }
void I00404() { npc = 000040; inh = 0;  }
void L00405() { npc = 000405; inh = 0;  }
void P00406() { npc = 000400; inh = 0;  }
void I00407() {  }
void P00410() { if (++core[(df<<12)+core[341]] == 010000) { core[(df<<12)+core[341]] = 0; npc++; }; code[(df<<12)+core[341]] = &emul8;  }
void P00411() { if (++core[(df<<12)+core[341]] == 010000) { core[(df<<12)+core[341]] = 0; npc++; }; code[(df<<12)+core[341]] = &emul8;  }
void D00412() { if (++core[(df<<12)+core[341]] == 010000) { core[(df<<12)+core[341]] = 0; npc++; }; code[(df<<12)+core[341]] = &emul8;  }
void S00413() { lac &= (010000|core[000000]);  }
void I00414() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00415() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00416() { lac = (lac<<2) + ((lac>>11)&3);  }
void L00417() { npc = (ib<<12)+core[267]; inh = 0;  }
void P00420() { core[(ib<<12)+core[108]] = 00421; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I00421() { lac += core[000022];  }
void I00422() { core[(ib<<12)+core[98]] = 00423; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I00423() { core[(ib<<12)+core[99]] = 00424; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I00424() { lac &= (010000|core[000017]);  }
void L00425() { core[(ib<<12)+core[99]] = 00426; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I00426() { lac &= (010000|core[000065]);  }
void D00427() { lac += core[000065];  }
void I00430() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00431() { npc = 000463; inh = 0;  }
void I00432() { core[(ib<<12)+core[109]] = 00433; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I00433() {  }
void I00434() { lac += core[000023];  }
void I00435() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00436() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I00437() { core[(ib<<12)+core[115]] = 00440; npc = (ib<<12)+core[115]+1; code[(ib<<12)+core[115]] = &emul8; inh = 0;  }
void I00440() { core[(ib<<12)+core[118]] = 00441; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I00441() { core[(ib<<12)+core[96]] = 00442; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I00442() { lac &= (010000|core[(df<<12)+core[262]]);  }
void I00443() { core[(ib<<12)+core[100]] = 00444; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I00444() { lac &= (010000|core[000065]);  }
void I00445() { lac += core[(df<<12)+core[18]];  }
void I00446() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00447() { npc = 000471; inh = 0;  }
void I00450() { lac++;  }
void I00451() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void I00452() { lac += core[000065];  }
void I00453() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00454() { npc = 000460; inh = 0;  }
void I00455() { lac += core[(df<<12)+core[24]];  }
void I00456() { core[(ib<<12)+core[115]] = 00457; npc = (ib<<12)+core[115]+1; code[(ib<<12)+core[115]] = &emul8; inh = 0;  }
void I00457() { npc = 000471; inh = 0;  }
void L00460() { lac += core[(df<<12)+core[24]];  }
void I00461() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00462() { npc = 000425; inh = 0;  }
void L00463() { core[(ib<<12)+core[109]] = 00464; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I00464() { core[(ib<<12)+core[118]] = 00465; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I00465() { core[(ib<<12)+core[96]] = 00466; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I00466() { lac &= (010000|core[(df<<12)+core[264]]);  }
void I00467() { core[(ib<<12)+core[100]] = 00470; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I00470() { lac &= (010000|core[000065]);  }
void L00471() { core[(ib<<12)+core[100]] = 00472; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I00472() { lac &= (010000|core[000017]);  }
void I00473() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I00474() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void I00475() { npc = (ib<<12)+core[318]; inh = 0;  }
void P00476() { lac &= (010000|core[(df<<12)+core[265]]);  }
void S00477() { lac &= (010000|core[000000]);  }
void I00500() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I00501() { lac ^= 07777;  }
void I00502() { core[000510] = 00503; npc = 000510+1; code[000510] = &emul8; inh = 0;  }
void I00503() { lac += core[000071];  }
void I00504() { if (++core[000013] == 010000) core[000013] = 0000;core[(df<<12)+core[000013]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000013]] = &emul8;  }
void I00505() { lac ^= 07777;  }
void I00506() { core[000510] = 00507; npc = 000510+1; code[000510] = &emul8; inh = 0;  }
void I00507() { npc = (ib<<12)+core[319]; inh = 0;  }
void S00510() { lac &= (010000|core[000000]);  }
void I00511() { lac += core[000013];  }
void I00512() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I00513() { lac += core[000013];  }
void I00514() { lac &= 07777; lac ^= 07777; lac++;  }
void I00515() { lac += core[000031];  }
void I00516() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00517() { core[(ib<<12)+core[118]] = 00520; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I00520() { npc = (ib<<12)+core[328]; inh = 0;  }
void P00521() { lac &= (010000|core[000000]);  }
void I00522() { lac += core[(df<<12)+core[337]];  }
void I00523() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I00524() { lac ^= 07777;  }
void P00525() { core[000510] = 00526; npc = 000510+1; code[000510] = &emul8; inh = 0;  }
void I00526() { lac += core[000521];  }
void I00527() { lac++;  }
void I00530() { if (++core[000013] == 010000) core[000013] = 0000;core[(df<<12)+core[000013]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000013]] = &emul8;  }
void I00531() { lac ^= 07777;  }
void I00532() { core[000510] = 00533; npc = 000510+1; code[000510] = &emul8; inh = 0;  }
void I00533() { npc = (ib<<12)+core[57]; inh = 0;  }
void S00534() { lac &= (010000|core[000000]);  }
void I00535() { lac &= 010000; lac ^= 07777;  }
void I00536() { lac += core[(df<<12)+core[348]];  }
void I00537() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void P00540() { if (++core[000534] == 010000) { core[000534] = 0; npc++; }; code[000534] = &emul8;  }
void I00541() { lac += core[000117];  }
void I00542() { core[000510] = 00543; npc = 000510+1; code[000510] = &emul8; inh = 0;  }
void D00543() { lac += core[000117];  }
void I00544() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void L00545() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I00546() { if (++core[000013] == 010000) core[000013] = 0000;core[(df<<12)+core[000013]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000013]] = &emul8;  }
void I00547() { if (++core[000071] == 010000) { core[000071] = 0; npc++; }; code[000071] = &emul8;  }
void I00550() { npc = 000545; inh = 0;  }
void I00551() { lac += core[000117];  }
void I00552() { core[000510] = 00553; npc = 000510+1; code[000510] = &emul8; inh = 0;  }
void I00553() { npc = (ib<<12)+core[348]; inh = 0;  }
void S00554() { lac &= (010000|core[000000]);  }
void I00555() { lac &= 010000; lac ^= 07777;  }
void I00556() { lac += core[(df<<12)+core[364]];  }
void I00557() { if (++core[000554] == 010000) { core[000554] = 0; npc++; }; code[000554] = &emul8;  }
void I00560() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00561() { lac += core[000117];  }
void I00562() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void L00563() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I00564() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I00565() { if (++core[000071] == 010000) { core[000071] = 0; npc++; }; code[000071] = &emul8;  }
void I00566() { npc = 000563; inh = 0;  }
void I00567() { npc = (ib<<12)+core[364]; inh = 0;  }
void I00570() { if (++core[(df<<12)+core[352]] == 010000) { core[(df<<12)+core[352]] = 0; npc++; }; code[(df<<12)+core[352]] = &emul8;  }
void I00571() { lac &= (010000|core[000412]);  }
void I00572() { lac &= (010000|core[000417]);  }
void I00573() { lac &= (010000|core[000427]);  }
void I00574() { lac += core[000075];  }
void I00575() { lac += core[000137];  }
void I00576() { if (++core[(df<<12)+core[341]] == 010000) { core[(df<<12)+core[341]] = 0; npc++; }; code[(df<<12)+core[341]] = &emul8;  }
void I00577() { lac += core[000065];  }
void I00600() { lac &= (010000|core[(df<<12)+core[392]]);  }
void I00601() { lac &= (010000|core[(df<<12)+core[396]]);  }
void D00602() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; hlt = 1;  }
void L00603() { core[(ib<<12)+core[108]] = 00604; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I00604() { core[(ib<<12)+core[109]] = 00605; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I00605() { core[(ib<<12)+core[118]] = 00606; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I00606() { lac += core[000023];  }
void I00607() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void P00610() { core[(ib<<12)+core[101]] = 00611; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void L00611() { lac += core[000066];  }
void I00612() { lac += core[000116];  }
void I00613() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void P00614() { npc = (ib<<12)+core[97]; inh = 0;  }
void I00615() { core[(ib<<12)+core[104]] = 00616; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void I00616() { lac += core[000776];  }
void I00617() { npc = 000610; inh = 0;  }
void I00620() { lac += core[000066];  }
void I00621() { lac &= (010000|core[000075]);  }
void I00622() { core[(ib<<12)+core[98]] = 00623; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void L00623() { core[(ib<<12)+core[101]] = 00624; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I00624() { core[(ib<<12)+core[104]] = 00625; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void I00625() { lac += core[000776];  }
void I00626() { skp = 0; skp = !skp; npc += skp;  }
void I00627() { npc = 000623; inh = 0;  }
void I00630() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I00631() { core[(ib<<12)+core[103]] = 00632; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I00632() { lac &= (010000|core[(df<<12)+core[507]]);  }
void I00633() { lac &= (010000|core[000167]);  }
void I00634() { core[(ib<<12)+core[118]] = 00635; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I00635() { core[(ib<<12)+core[108]] = 00636; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I00636() { if (++core[000026] == 010000) { core[000026] = 0; npc++; }; code[000026] = &emul8;  }
void L00637() { core[(ib<<12)+core[109]] = 00640; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I00640() { npc = 000667; inh = 0;  }
void I00641() { lac += core[000067];  }
void I00642() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00643() { core[(ib<<12)+core[107]] = 00644; npc = (ib<<12)+core[107]+1; code[(ib<<12)+core[107]] = &emul8; inh = 0;  }
void L00644() { core[(ib<<12)+core[101]] = 00645; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I00645() { core[(ib<<12)+core[105]] = 00646; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I00646() { lac += core[000066];  }
void I00647() { lac += core[000116];  }
void I00650() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00651() { npc = 000644; inh = 0;  }
void I00652() { lac += core[(df<<12)+core[19]];  }
void L00653() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00654() { npc = 000671; inh = 0;  }
void I00655() { lac++;  }
void I00656() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void I00657() { lac += core[000065];  }
void I00660() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00661() { lac += core[(df<<12)+core[24]];  }
void I00662() { core[(ib<<12)+core[115]] = 00663; npc = (ib<<12)+core[115]+1; code[(ib<<12)+core[115]] = &emul8; inh = 0;  }
void I00663() { npc = 000673; inh = 0;  }
void L00664() { lac += core[(df<<12)+core[24]];  }
void I00665() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00666() { npc = 000637; inh = 0;  }
void L00667() { lac += core[000023];  }
void I00670() { npc = 000653; inh = 0;  }
void L00671() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void I00672() { npc = (ib<<12)+core[97]; inh = 0;  }
void L00673() { lac += core[000065];  }
void I00674() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00675() { npc = 000671; inh = 0;  }
void I00676() { core[(ib<<12)+core[105]] = 00677; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I00677() { npc = 000664; inh = 0;  }
void S00700() { lac &= (010000|core[000000]);  }
void I00701() { core[(ib<<12)+core[112]] = 00702; npc = (ib<<12)+core[112]+1; code[(ib<<12)+core[112]] = &emul8; inh = 0;  }
void I00702() { core[(ib<<12)+core[104]] = 00703; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void I00703() { lac += core[(df<<12)+core[503]];  }
void D00704() { npc = (ib<<12)+core[448]; inh = 0;  }
void I00705() { lac += core[000066];  }
void D00706() { if (++core[000700] == 010000) { core[000700] = 0; npc++; }; code[000700] = &emul8;  }
void I00707() { lac += core[000602];  }
void I00710() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D00711() { npc = 000717; inh = 0;  }
void I00712() { core[(ib<<12)+core[113]] = 00713; npc = (ib<<12)+core[113]+1; code[(ib<<12)+core[113]] = &emul8; inh = 0;  }
void I00713() { npc = (ib<<12)+core[448]; inh = 0;  }
void I00714() { skp = 0; skp = !skp; npc += skp;  }
void I00715() { npc = (ib<<12)+core[448]; inh = 0;  }
void I00716() { if (++core[000700] == 010000) { core[000700] = 0; npc++; }; code[000700] = &emul8;  }
void L00717() { if (++core[000700] == 010000) { core[000700] = 0; npc++; }; code[000700] = &emul8;  }
void I00720() { npc = (ib<<12)+core[448]; inh = 0;  }
void S00721() { lac &= (010000|core[000000]);  }
void I00722() { lac += core[(df<<12)+core[465]];  }
void D00723() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void L00724() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I00725() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00726() { npc = 000740; inh = 0;  }
void I00727() { lac ^= 07777; lac++;  }
void I00730() { lac += core[000066];  }
void I00731() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00732() { npc = 000724; inh = 0;  }
void I00733() { lac += core[(df<<12)+core[465]];  }
void I00734() { lac ^= 07777;  }
void I00735() { lac += core[000012];  }
void I00736() { core[000054] = lac & 07777; lac &= 010000; code[000054] = &emul8;  }
void I00737() { skp = 0; skp = !skp; npc += skp;  }
void L00740() { if (++core[000721] == 010000) { core[000721] = 0; npc++; }; code[000721] = &emul8;  }
void I00741() { if (++core[000721] == 010000) { core[000721] = 0; npc++; }; code[000721] = &emul8;  }
void I00742() { lac &= 010000; lac &= 07777;  }
void I00743() { npc = (ib<<12)+core[465]; inh = 0;  }
void S00744() { lac &= (010000|core[000000]);  }
void I00745() { lac &= (010000|core[000104]);  }
void I00746() { lac ^= 07777; lac++;  }
void I00747() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I00750() { lac += core[000067];  }
void I00751() { lac &= (010000|core[000104]);  }
void I00752() { lac += core[000071];  }
void I00753() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00754() { if (++core[000744] == 010000) { core[000744] = 0; npc++; }; code[000744] = &emul8;  }
void I00755() { npc = (ib<<12)+core[484]; inh = 0;  }
void S00756() { lac &= (010000|core[000000]);  }
void I00757() { lac += core[000036];  }
void I00760() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00761() { npc = 000764; inh = 0;  }
void I00762() { core[(ib<<12)+core[101]] = 00763; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I00763() { npc = (ib<<12)+core[494]; inh = 0;  }
void L00764() { core[(ib<<12)+core[106]] = 00765; npc = (ib<<12)+core[106]+1; code[(ib<<12)+core[106]] = &emul8; inh = 0;  }
void I00765() { core[(ib<<12)+core[103]] = 00766; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I00766() { emul8();  }
void P00767() { core[(df<<12)+core[2]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2]] = &emul8;  }
void I00770() { npc = (ib<<12)+core[494]; inh = 0;  }
void I00771() { lac += core[000035];  }
void I00772() { lac &= (010000|core[(df<<12)+core[392]]);  }
void P00773() { lac &= (010000|core[(df<<12)+core[396]]);  }
void I00774() { lac &= (010000|core[000723]);  }
void I00775() { lac &= (010000|core[000706]);  }
void D00776() { lac &= (010000|core[000711]);  }
void I00777() { lac &= (010000|core[000704]);  }
void I01000() { lac &= (010000|core[001107]);  }
void P01001() { lac &= (010000|core[001103]);  }
void D01002() { lac &= (010000|core[001101]);  }
void P01003() { lac &= (010000|core[001124]);  }
void D01004() { lac &= (010000|core[001114]);  }
void I01005() { lac &= (010000|core[001105]);  }
void I01006() { lac &= (010000|core[001127]);  }
void I01007() { lac &= (010000|core[001115]);  }
void P01010() { lac &= (010000|core[001121]);  }
void I01011() { lac &= (010000|core[001122]);  }
void P01012() { lac &= (010000|core[001012]);  }
void I01013() { core[(ib<<12)+core[116]] = 01014; npc = (ib<<12)+core[116]+1; code[(ib<<12)+core[116]] = &emul8; inh = 0;  }
void P01014() { core[(ib<<12)+core[543]] = 01015; npc = (ib<<12)+core[543]+1; code[(ib<<12)+core[543]] = &emul8; inh = 0;  }
void I01015() { if (++core[000013] == 010000) { core[000013] = 0; npc++; }; code[000013] = &emul8;  }
void I01016() { core[(ib<<12)+core[544]] = 01017; npc = (ib<<12)+core[544]+1; code[(ib<<12)+core[544]] = &emul8; inh = 0;  }
void I01017() { lac += core[000111];  }
void I01020() { core[000032] = lac & 07777; lac &= 010000; code[000032] = &emul8;  }
void I01021() { lac += core[000045];  }
void I01022() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I01023() { if (++core[000032] == 010000) { core[000032] = 0; npc++; }; code[000032] = &emul8;  }
void I01024() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void L01025() { if (++core[000032] == 010000) { core[000032] = 0; npc++; }; code[000032] = &emul8;  }
void I01026() { skp = 0; skp = !skp; npc += skp;  }
void I01027() { npc = (ib<<12)+core[631]; inh = 0;  }
void L01030() { core[(ib<<12)+core[103]] = 01031; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01031() { lac += core[001177];  }
void I01032() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01033() { core[(ib<<12)+core[101]] = 01034; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01034() { npc = 001030; inh = 0;  }
void P01035() { core[(ib<<12)+core[101]] = 01036; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01036() { npc = 001025; inh = 0;  }
void P01037() { lac += core[(df<<12)+core[513]];  }
void P01040() { if (++core[000047] == 010000) { core[000047] = 0; npc++; }; code[000047] = &emul8;  }
void D01041() { core[(ib<<12)+core[96]] = 01042; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01042() { lac += core[(df<<12)+core[3]];  }
void I01043() { core[(ib<<12)+core[112]] = 01044; npc = (ib<<12)+core[112]+1; code[(ib<<12)+core[112]] = &emul8; inh = 0;  }
void I01044() { lac += core[000066];  }
void I01045() { lac += core[001135];  }
void I01046() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01047() { core[(ib<<12)+core[118]] = 01050; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I01050() { lac += core[000030];  }
void I01051() { core[(ib<<12)+core[98]] = 01052; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I01052() { core[(ib<<12)+core[96]] = 01053; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01053() { lac += core[(df<<12)+core[522]];  }
void D01054() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01055() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void D01056() { core[(ib<<12)+core[7]] = 01057; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I01057() { &emul8;  }
void I01060() { &emul8;  }
void I01061() { core[(ib<<12)+core[103]] = 01062; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01062() { lac += core[001177];  }
void I01063() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01064() { core[(ib<<12)+core[118]] = 01065; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I01065() { lac += core[000030];  }
void I01066() { core[(ib<<12)+core[98]] = 01067; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I01067() { core[(ib<<12)+core[96]] = 01070; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01070() { lac += core[(df<<12)+core[522]];  }
void I01071() { core[(ib<<12)+core[103]] = 01072; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01072() { lac += core[001177];  }
void I01073() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1); lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01074() { core[(ib<<12)+core[118]] = 01075; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I01075() { core[(ib<<12)+core[99]] = 01076; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I01076() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void I01077() { core[(ib<<12)+core[96]] = 01100; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01100() { lac += core[(df<<12)+core[522]];  }
void L01101() { core[(ib<<12)+core[99]] = 01102; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I01102() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void D01103() { core[(ib<<12)+core[99]] = 01104; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I01104() { lac &= (010000|core[000017]);  }
void D01105() { core[(ib<<12)+core[96]] = 01106; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void D01106() { lac &= (010000|core[(df<<12)+core[520]]);  }
void D01107() { core[(ib<<12)+core[100]] = 01110; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I01110() { lac &= (010000|core[000017]);  }
void I01111() { core[(ib<<12)+core[100]] = 01112; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I01112() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void I01113() { core[(ib<<12)+core[100]] = 01114; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void D01114() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void D01115() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01116() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void I01117() { core[(ib<<12)+core[7]] = 01120; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I01120() { &emul8;  }
void D01121() { &emul8;  }
void D01122() { &emul8;  }
void I01123() { &emul8;  }
void D01124() { &emul8;  }
void D01125() { lac += core[000045];  }
void D01126() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D01127() { npc = (ib<<12)+core[97]; inh = 0;  }
void I01130() { lac += core[000030];  }
void I01131() { core[(ib<<12)+core[98]] = 01132; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I01132() { core[(ib<<12)+core[99]] = 01133; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void P01133() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01134() { npc = 001101; inh = 0;  }
void D01135() { emul8();  }
void D01136() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac |= swr;  }
void I01137() { core[(ib<<12)+core[99]] = 01140; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I01140() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void I01141() { npc = 001101; inh = 0;  }
void I01142() { core[(ib<<12)+core[43]] = 01143; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I01143() { core[(ib<<12)+core[98]] = 01144; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I01144() { lac += core[000066];  }
void I01145() { lac += core[001136];  }
void I01146() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01147() { core[(ib<<12)+core[118]] = 01150; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I01150() { core[(ib<<12)+core[96]] = 01151; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01151() { lac += core[(df<<12)+core[522]];  }
void I01152() { core[(ib<<12)+core[43]] = 01153; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void D01153() { emul8();  }
void I01154() { lac &= 010000;  }
void I01155() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void D01156() { emul8();  }
void I01157() { skp = 0; skp = !skp; npc += skp;  }
void I01160() { core[(ib<<12)+core[43]] = 01161; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I01161() { lac &= 010000;  }
void I01162() { npc = (ib<<12)+core[94]; inh = 0;  }
void I01163() { lac += core[000041];  }
void I01164() { lac += core[000041];  }
void I01165() { lac += core[000013];  }
void I01166() { lac &= (010000|core[(df<<12)+core[16]]);  }
void P01167() { lac &= (010000|core[(df<<12)+core[515]]);  }
void I01170() { lac &= (010000|core[(df<<12)+core[524]]);  }
void I01171() { lac += core[001002];  }
void I01172() { lac += core[001003];  }
void I01173() { emul8();  }
void I01174() { if (++core[001004] == 010000) { core[001004] = 0; npc++; }; code[001004] = &emul8;  }
void I01175() { lac &= (010000|core[(df<<12)+core[541]]);  }
void I01176() { lac += core[001056];  }
void D01177() { lac &= (010000|core[000177]);  }
void I01200() { lac += core[(df<<12)+core[115]];  }
void I01201() { emul8();  }
void L01202() { lac &= 010000; lac ^= 07777;  }
void L01203() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void L01204() { core[000026] = lac & 07777; lac &= 010000; code[000026] = &emul8;  }
void I01205() { core[(ib<<12)+core[103]] = 01206; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01206() { lac += core[001371];  }
void I01207() { lac &= (010000|core[000176]);  }
void I01210() { if (++core[000056] == 010000) { core[000056] = 0; npc++; }; code[000056] = &emul8;  }
void I01211() { npc = 001226; inh = 0;  }
void I01212() { core[(ib<<12)+core[96]] = 01213; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void P01213() { lac += core[(df<<12)+core[3]];  }
void I01214() { lac += core[000066];  }
void I01215() { core[(ib<<12)+core[98]] = 01216; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I01216() { lac += core[001255];  }
void I01217() { core[(ib<<12)+core[105]] = 01220; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I01220() { if (++core[000036] == 010000) { core[000036] = 0; npc++; }; code[000036] = &emul8;  }
void I01221() { lac++;  }
void I01222() { core[(ib<<12)+core[89]] = 01223; npc = (ib<<12)+core[89]+1; code[(ib<<12)+core[89]] = &emul8; inh = 0;  }
void I01223() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01224() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I01225() { npc = 001202; inh = 0;  }
void L01226() { core[(ib<<12)+core[96]] = 01227; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01227() { lac += core[(df<<12)+core[651]];  }
void I01230() { core[(ib<<12)+core[88]] = 01231; npc = (ib<<12)+core[88]+1; code[(ib<<12)+core[88]] = &emul8; inh = 0;  }
void I01231() { npc = 001203; inh = 0;  }
void I01232() { if (++core[000026] == 010000) { core[000026] = 0; npc++; }; code[000026] = &emul8;  }
void L01233() { core[(ib<<12)+core[101]] = 01234; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01234() { core[(ib<<12)+core[103]] = 01235; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01235() { lac += core[(df<<12)+core[3]];  }
void I01236() { lac &= (010000|core[(df<<12)+core[763]]);  }
void I01237() { core[(ib<<12)+core[105]] = 01240; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void D01240() { npc = 001233; inh = 0;  }
void D01241() { core[(ib<<12)+core[101]] = 01242; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void D01242() { core[(ib<<12)+core[108]] = 01243; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void D01243() { lac += core[000067];  }
void D01244() { core[000052] = lac & 07777; lac &= 010000; code[000052] = &emul8;  }
void D01245() { npc = 001204; inh = 0;  }
void I01246() { lac += core[000077];  }
void I01247() { core[(ib<<12)+core[51]] = 01250; npc = (ib<<12)+core[51]+1; code[(ib<<12)+core[51]] = &emul8; inh = 0;  }
void I01250() { lac ^= 07777;  }
void I01251() { lac += core[000077];  }
void I01252() { core[(ib<<12)+core[105]] = 01253; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I01253() { core[(ib<<12)+core[101]] = 01254; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01254() { npc = 001204; inh = 0;  }
void D01255() { lac &= (010000|core[001272]);  }
void I01256() { core[(ib<<12)+core[108]] = 01257; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I01257() { core[(ib<<12)+core[109]] = 01260; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I01260() { core[(ib<<12)+core[118]] = 01261; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void D01261() { lac += core[000060];  }
void I01262() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I01263() { core[000062] = lac & 07777; lac &= 010000; code[000062] = &emul8;  }
void I01264() { lac += core[000067];  }
void I01265() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I01266() { lac += core[000010];  }
void I01267() { core[000027] = lac & 07777; lac &= 010000; code[000027] = &emul8;  }
void D01270() { core[(ib<<12)+core[52]] = 01271; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void D01271() { core[000100] = lac & 07777; lac &= 010000; code[000100] = &emul8;  }
void D01272() { if (++core[000026] == 010000) { core[000026] = 0; npc++; }; code[000026] = &emul8;  }
void L01273() { core[(ib<<12)+core[101]] = 01274; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01274() { core[(ib<<12)+core[105]] = 01275; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I01275() { core[(ib<<12)+core[103]] = 01276; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01276() { lac &= (010000|core[000076]);  }
void I01277() { lac += core[001271];  }
void I01300() { core[(ib<<12)+core[102]] = 01301; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I01301() { npc = 001273; inh = 0;  }
void D01302() { lac += core[000060];  }
void I01303() { lac++;  }
void I01304() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I01305() { core[000062] = lac & 07777; lac &= 010000; code[000062] = &emul8;  }
void L01306() { core[(ib<<12)+core[106]] = 01307; npc = (ib<<12)+core[106]+1; code[(ib<<12)+core[106]] = &emul8; inh = 0;  }
void I01307() { core[(ib<<12)+core[103]] = 01310; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01310() { lac &= (010000|core[000071]);  }
void I01311() { lac += core[001271];  }
void D01312() { core[(ib<<12)+core[102]] = 01313; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I01313() { npc = 001306; inh = 0;  }
void S01314() { lac &= (010000|core[000000]);  }
void I01315() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01316() { lac += core[000066];  }
void I01317() { lac ^= 07777; lac++;  }
void I01320() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I01321() { lac += core[(df<<12)+core[716]];  }
void I01322() { if (++core[001314] == 010000) { core[001314] = 0; npc++; }; code[001314] = &emul8;  }
void I01323() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void L01324() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I01325() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I01326() { npc = 001340; inh = 0;  }
void I01327() { lac += core[000071];  }
void I01330() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01331() { npc = 001324; inh = 0;  }
void I01332() { lac += core[000012];  }
void I01333() { lac += core[(df<<12)+core[716]];  }
void I01334() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I01335() { lac += core[(df<<12)+core[57]];  }
void L01336() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I01337() { npc = (ib<<12)+core[57]; inh = 0;  }
void P01340() { if (++core[001314] == 010000) { core[001314] = 0; npc++; }; code[001314] = &emul8;  }
void I01341() { lac &= 010000; lac &= 07777;  }
void I01342() { npc = (ib<<12)+core[716]; inh = 0;  }
void I01343() { core[(ib<<12)+core[43]] = 01344; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I01344() {  }
void I01345() { emul8();  }
void L01346() { emul8();  }
void I01347() { npc = 001346; inh = 0;  }
void I01350() { emul8();  }
void I01351() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I01352() { emul8();  }
void I01353() { npc = (ib<<12)+core[94]; inh = 0;  }
void P01354() { lac &= (010000|core[000000]);  }
void I01355() { emul8();  }
void I01356() { emul8();  }
void L01357() { emul8();  }
void I01360() { npc = 001357; inh = 0;  }
void I01361() { lac &= 010000;  }
void I01362() { npc = (ib<<12)+core[748]; inh = 0;  }
void I01363() { lac += core[001273];  }
void I01364() { lac += core[001270];  }
void I01365() { if (++core[(df<<12)+core[736]] == 010000) { core[(df<<12)+core[736]] = 0; npc++; }; code[(df<<12)+core[736]] = &emul8;  }
void I01366() { lac += core[001302];  }
void I01367() { lac += core[001271];  }
void I01370() { lac &= (010000|core[001261]);  }
void D01371() { lac += core[001312];  }
void I01372() { lac &= (010000|core[001245]);  }
void P01373() { lac &= (010000|core[001242]);  }
void I01374() { lac &= (010000|core[001241]);  }
void I01375() { lac &= (010000|core[001243]);  }
void I01376() { lac &= (010000|core[001244]);  }
void I01377() { lac &= (010000|core[001240]);  }
void I01400() { lac &= (010000|core[001454]);  }
void P01401() { lac &= (010000|core[001473]);  }
void I01402() { lac &= (010000|core[001415]);  }
void D01403() { core[(ib<<12)+core[116]] = 01404; npc = (ib<<12)+core[116]+1; code[(ib<<12)+core[116]] = &emul8; inh = 0;  }
void I01404() { lac &= (010000|core[001442]);  }
void I01405() { lac &= (010000|core[001415]);  }
void I01406() { core[(ib<<12)+core[118]] = 01407; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I01407() { core[000062] = lac & 07777; lac &= 010000; code[000062] = &emul8;  }
void P01410() { core[(ib<<12)+core[102]] = 01411; npc = (ib<<12)+core[102]+1; code[(ib<<12)+core[102]] = &emul8; inh = 0;  }
void I01411() { core[(ib<<12)+core[101]] = 01412; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01412() { core[(ib<<12)+core[104]] = 01413; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void D01413() { lac += core[(df<<12)+core[887]];  }
void I01414() { npc = 001426; inh = 0;  }
void D01415() { lac += core[000066];  }
void I01416() { lac &= (010000|core[000122]);  }
void I01417() { lac += core[000061];  }
void I01420() { core[000061] = lac & 07777; lac &= 010000; code[000061] = &emul8;  }
void L01421() { core[(ib<<12)+core[101]] = 01422; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01422() { core[(ib<<12)+core[104]] = 01423; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void D01423() { lac += core[(df<<12)+core[887]];  }
void I01424() { npc = 001426; inh = 0;  }
void I01425() { npc = 001421; inh = 0;  }
void L01426() { core[(ib<<12)+core[114]] = 01427; npc = (ib<<12)+core[114]+1; code[(ib<<12)+core[114]] = &emul8; inh = 0;  }
void I01427() { npc = 001437; inh = 0;  }
void I01430() { lac += core[000061];  }
void I01431() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void D01432() { core[(ib<<12)+core[816]] = 01433; npc = (ib<<12)+core[816]+1; code[(ib<<12)+core[816]] = &emul8; inh = 0;  }
void I01433() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01434() { core[000061] = lac & 07777; lac &= 010000; code[000061] = &emul8;  }
void I01435() { core[(ib<<12)+core[815]] = 01436; npc = (ib<<12)+core[815]+1; code[(ib<<12)+core[815]] = &emul8; inh = 0;  }
void I01436() { core[(ib<<12)+core[43]] = 01437; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void L01437() { core[001517] = lac & 07777; lac &= 010000; code[001517] = &emul8;  }
void I01440() { lac += core[000060];  }
void L01441() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void D01442() { lac += core[000030];  }
void I01443() { lac ^= 07777; lac++;  }
void I01444() { lac += core[000031];  }
void I01445() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D01446() { npc = 001461; inh = 0;  }
void I01447() { lac += core[(df<<12)+core[24]];  }
void I01450() { lac ^= 07777; lac++;  }
void D01451() { lac += core[000061];  }
void I01452() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D01453() { npc = 001505; inh = 0;  }
void L01454() { lac += core[000030];  }
void I01455() { lac += core[000070];  }
void I01456() { npc = 001441; inh = 0;  }
void P01457() { if (++core[000047] == 010000) { core[000047] = 0; npc++; }; code[000047] = &emul8;  }
void P01460() { lac += core[(df<<12)+core[769]];  }
void L01461() { lac += core[000031];  }
void I01462() { lac += core[000005];  }
void I01463() { lac &= 07777; lac ^= 07777; lac++;  }
void I01464() { lac += core[000013];  }
void I01465() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I01466() { core[(ib<<12)+core[118]] = 01467; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I01467() { lac += core[000031];  }
void I01470() { lac += core[000070];  }
void I01471() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I01472() { lac += core[000061];  }
void D01473() { core[(df<<12)+core[24]] = lac & 07777; lac &= 010000; code[(df<<12)+core[24]] = &emul8;  }
void I01474() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void I01475() { lac += core[001517];  }
void I01476() { core[(df<<12)+core[24]] = lac & 07777; lac &= 010000; code[(df<<12)+core[24]] = &emul8;  }
void I01477() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void I01500() { core[(ib<<12)+core[7]] = 01501; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I01501() { &emul8;  }
void I01502() { &emul8;  }
void I01503() { &emul8;  }
void I01504() { npc = (ib<<12)+core[97]; inh = 0;  }
void L01505() { lac += core[000030];  }
void I01506() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I01507() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I01510() { lac ^= 07777; lac++;  }
void I01511() { lac += core[001517];  }
void I01512() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01513() { npc = 001454; inh = 0;  }
void I01514() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void I01515() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void I01516() { npc = (ib<<12)+core[97]; inh = 0;  }
void S01517() { lac &= (010000|core[000000]);  }
void L01520() { lac += core[000066];  }
void I01521() { lac += core[000114];  }
void I01522() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01523() { npc = (ib<<12)+core[847]; inh = 0;  }
void I01524() { core[(ib<<12)+core[101]] = 01525; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01525() { npc = 001520; inh = 0;  }
void D01526() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void D01527() { emul8();  }
void D01530() { lac &= (010000|core[000000]);  }
void I01531() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I01532() { lac &= (010000|core[000000]);  }
void S01533() { lac &= (010000|core[000000]);  }
void I01534() { lac += core[000066];  }
void I01535() { lac += core[000115];  }
void I01536() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01537() { if (++core[001533] == 010000) { core[001533] = 0; npc++; }; code[001533] = &emul8;  }
void I01540() { lac += core[000066];  }
void I01541() { lac += core[001526];  }
void I01542() { core[000054] = lac & 07777; lac &= 010000; code[000054] = &emul8;  }
void I01543() { lac += core[000054];  }
void I01544() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01545() { npc = (ib<<12)+core[859]; inh = 0;  }
void I01546() { lac += core[000066];  }
void I01547() { lac += core[001527];  }
void D01550() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01551() { if (++core[001533] == 010000) { core[001533] = 0; npc++; }; code[001533] = &emul8;  }
void I01552() { npc = (ib<<12)+core[859]; inh = 0;  }
void I01553() { core[(ib<<12)+core[7]] = 01554; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I01554() { &emul8;  }
void I01555() { &emul8;  }
void I01556() { &emul8;  }
void I01557() { &emul8;  }
void I01560() { core[001530] = lac & 07777; lac &= 010000; code[001530] = &emul8;  }
void I01561() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I01562() { npc = (ib<<12)+core[94]; inh = 0;  }
void I01563() { lac += core[000137];  }
void I01564() { core[000022] = lac & 07777; lac &= 010000; code[000022] = &emul8;  }
void L01565() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01566() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void P01567() { npc = (ib<<12)+core[57]; inh = 0;  }
void I01570() { lac += core[001441];  }
void I01571() { lac += core[001432];  }
void I01572() { lac += core[001451];  }
void I01573() { lac += core[001446];  }
void I01574() { core[000052] = lac & 07777; lac &= 010000; code[000052] = &emul8;  }
void I01575() { lac += core[001453];  }
void I01576() { lac += core[001453];  }
void I01577() { lac &= (010000|core[(df<<12)+core[776]]);  }
void I01600() { lac &= (010000|core[(df<<12)+core[908]]);  }
void D01601() { lac &= (010000|core[000000]);  }
void I01602() { lac += core[000054];  }
void I01603() { core[(ib<<12)+core[98]] = 01604; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I01604() { lac += core[000055];  }
void I01605() { core[(ib<<12)+core[98]] = 01606; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I01606() { lac += core[000056];  }
void I01607() { core[(ib<<12)+core[98]] = 01610; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I01610() { lac += core[001601];  }
void I01611() { core[(ib<<12)+core[98]] = 01612; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void D01612() { core[(ib<<12)+core[101]] = 01613; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01613() { core[000055] = lac & 07777; lac &= 010000; code[000055] = &emul8;  }
void P01614() { core[(ib<<12)+core[116]] = 01615; npc = (ib<<12)+core[116]+1; code[(ib<<12)+core[116]] = &emul8; inh = 0;  }
void I01615() { npc = 001627; inh = 0;  }
void I01616() { npc = 001732; inh = 0;  }
void I01617() { npc = 001743; inh = 0;  }
void L01620() { core[(ib<<12)+core[96]] = 01621; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01621() { lac += core[(df<<12)+core[7]];  }
void L01622() { core[(ib<<12)+core[116]] = 01623; npc = (ib<<12)+core[116]+1; code[(ib<<12)+core[116]] = &emul8; inh = 0;  }
void I01623() { npc = 001644; inh = 0;  }
void I01624() { lac &= (010000|core[001612]);  }
void I01625() { lac &= (010000|core[001777]);  }
void I01626() { core[(ib<<12)+core[118]] = 01627; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void L01627() { lac += core[000137];  }
void I01630() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void I01631() { lac += core[000111];  }
void I01632() { lac += core[000054];  }
void I01633() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01634() { npc = 001647; inh = 0;  }
void I01635() { lac++;  }
void I01636() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01637() { npc = 001723; inh = 0;  }
void D01640() { lac += core[000054];  }
void I01641() { lac += core[000121];  }
void I01642() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01643() { npc = 001763; inh = 0;  }
void L01644() { core[(ib<<12)+core[114]] = 01645; npc = (ib<<12)+core[114]+1; code[(ib<<12)+core[114]] = &emul8; inh = 0;  }
void I01645() { skp = 0; skp = !skp; npc += skp;  }
void I01646() { core[(ib<<12)+core[118]] = 01647; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void L01647() { lac += core[000054];  }
void D01650() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void I01651() { lac += core[000024];  }
void D01652() { lac += core[000121];  }
void D01653() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I01654() { core[000024] = lac & 07777; lac &= 010000; code[000024] = &emul8;  }
void L01655() { lac += core[000024];  }
void I01656() { lac ^= 07777; lac++;  }
void D01657() { lac += core[000055];  }
void I01660() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01661() { npc = 001710; inh = 0;  }
void I01662() { lac += core[000055];  }
void I01663() { lac &= 07777; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01664() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01665() { lac += core[001731];  }
void I01666() { core[001674] = lac & 07777; lac &= 010000; code[001674] = &emul8;  }
void I01667() { lac += core[000055];  }
void I01670() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01671() { core[(ib<<12)+core[100]] = 01672; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I01672() { lac &= (010000|core[000044]);  }
void I01673() { core[(ib<<12)+core[7]] = 01674; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void D01674() { &emul8;  }
void I01675() { emul8();  }
void I01676() { lac &= (010000|core[000000]);  }
void I01677() { lac += core[000125];  }
void I01700() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void I01701() { lac += core[000024];  }
void I01702() { lac += core[000055];  }
void I01703() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01704() { npc = (ib<<12)+core[97]; inh = 0;  }
void I01705() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01706() { core[000055] = lac & 07777; lac &= 010000; code[000055] = &emul8;  }
void I01707() { npc = 001655; inh = 0;  }
void L01710() { core[(ib<<12)+core[114]] = 01711; npc = (ib<<12)+core[114]+1; code[(ib<<12)+core[114]] = &emul8; inh = 0;  }
void I01711() { skp = 0; skp = !skp; npc += skp;  }
void I01712() { npc = 001765; inh = 0;  }
void I01713() { lac += core[000055];  }
void I01714() { core[(ib<<12)+core[98]] = 01715; npc = (ib<<12)+core[98]+1; code[(ib<<12)+core[98]] = &emul8; inh = 0;  }
void I01715() { lac += core[000030];  }
void I01716() { core[001720] = lac & 07777; lac &= 010000; code[001720] = &emul8;  }
void I01717() { core[(ib<<12)+core[99]] = 01720; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void D01720() { lac &= (010000|core[000000]);  }
void I01721() { lac += core[000024];  }
void I01722() { core[000055] = lac & 07777; lac &= 010000; code[000055] = &emul8;  }
void L01723() { core[(ib<<12)+core[101]] = 01724; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01724() { core[(ib<<12)+core[116]] = 01725; npc = (ib<<12)+core[116]+1; code[(ib<<12)+core[116]] = &emul8; inh = 0;  }
void L01725() { npc = 001763; inh = 0;  }
void I01726() { npc = 001732; inh = 0;  }
void I01727() { npc = 001743; inh = 0;  }
void I01730() { npc = 001620; inh = 0;  }
void D01731() { lac &= (010000|core[(df<<12)+core[24]]);  }
void L01732() { core[(ib<<12)+core[99]] = 01733; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void D01733() { lac &= (010000|core[000044]);  }
void I01734() { lac += core[000125];  }
void I01735() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void D01736() { core[000036] = lac & 07777; lac &= 010000; code[000036] = &emul8;  }
void I01737() { core[(ib<<12)+core[89]] = 01740; npc = (ib<<12)+core[89]+1; code[(ib<<12)+core[89]] = &emul8; inh = 0;  }
void I01740() { core[(ib<<12)+core[100]] = 01741; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I01741() { lac &= (010000|core[000044]);  }
void I01742() { npc = 001622; inh = 0;  }
void L01743() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I01744() { core[(ib<<12)+core[101]] = 01745; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I01745() { core[(ib<<12)+core[104]] = 01746; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void I01746() { lac += core[(df<<12)+core[1015]];  }
void I01747() { npc = 001754; inh = 0;  }
void I01750() { lac += core[000056];  }
void I01751() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I01752() { lac += core[000066];  }
void I01753() { npc = 001743; inh = 0;  }
void L01754() { core[(ib<<12)+core[114]] = 01755; npc = (ib<<12)+core[114]+1; code[(ib<<12)+core[114]] = &emul8; inh = 0;  }
void I01755() { core[(ib<<12)+core[118]] = 01756; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I01756() { core[001601] = 01757; npc = 001601+1; code[001601] = &emul8; inh = 0;  }
void I01757() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01760() { core[(ib<<12)+core[103]] = 01761; npc = (ib<<12)+core[103]+1; code[(ib<<12)+core[103]] = &emul8; inh = 0;  }
void I01761() { if (++core[000164] == 010000) { core[000164] = 0; npc++; }; code[000164] = &emul8;  }
void I01762() { emul8();  }
void L01763() { core[(ib<<12)+core[114]] = 01764; npc = (ib<<12)+core[114]+1; code[(ib<<12)+core[114]] = &emul8; inh = 0;  }
void I01764() { core[(ib<<12)+core[118]] = 01765; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void L01765() { core[001601] = 01766; npc = 001601+1; code[001601] = &emul8; inh = 0;  }
void I01766() { if (++core[000013] == 010000) { core[000013] = 0; npc++; }; code[000013] = &emul8;  }
void P01767() { npc = (ib<<12)+core[94]; inh = 0;  }
void I01770() { lac &= (010000|core[001640]);  }
void I01771() { lac &= (010000|core[001653]);  }
void I01772() { lac &= (010000|core[001655]);  }
void I01773() { lac &= (010000|core[001657]);  }
void I01774() { lac &= (010000|core[001652]);  }
void I01775() { lac &= (010000|core[001736]);  }
void I01776() { lac &= (010000|core[001650]);  }
void D01777() { lac &= (010000|core[001733]);  }
void I02000() { lac &= (010000|core[002074]);  }
void I02001() { lac &= (010000|core[002051]);  }
void I02002() { lac &= (010000|core[002135]);  }
void I02003() { lac &= (010000|core[002076]);  }
void I02004() { lac &= (010000|core[002054]);  }
void I02005() { lac &= (010000|core[002073]);  }
void I02006() { lac &= (010000|core[002015]);  }
void I02007() { lac &= (010000|core[002075]);  }
void I02010() { core[(ib<<12)+core[99]] = 02011; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I02011() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void I02012() { core[(ib<<12)+core[100]] = 02013; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I02013() { lac &= (010000|core[000044]);  }
void I02014() { lac += core[002031];  }
void D02015() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02016() { core[(ib<<12)+core[41]] = 02017; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void L02017() { core[(ib<<12)+core[7]] = 02020; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I02020() { &emul8;  }
void I02021() { &emul8;  }
void P02022() { &emul8;  }
void P02023() { lac += core[000125];  }
void P02024() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void P02025() { core[002047] = 02026; npc = 002047+1; code[002047] = &emul8; inh = 0;  }
void I02026() { npc = (ib<<12)+core[1047]; inh = 0;  }
void P02027() { lac += core[(df<<12)+core[1042]];  }
void P02030() { lac &= (010000|core[000000]);  }
void D02031() { lac &= (010000|core[000000]);  }
void I02032() { lac &= (010000|core[000000]);  }
void I02033() { lac &= (010000|core[000000]);  }
void D02034() { lac &= (010000|core[000003]);  }
void S02035() { lac &= (010000|core[000000]);  }
void P02036() { lac += core[000054];  }
void I02037() { lac += core[000121];  }
void I02040() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I02041() { npc = (ib<<12)+core[1053]; inh = 0;  }
void I02042() { lac += core[000054];  }
void I02043() { lac += core[000120];  }
void I02044() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I02045() { if (++core[002035] == 010000) { core[002035] = 0; npc++; }; code[002035] = &emul8;  }
void I02046() { npc = (ib<<12)+core[1053]; inh = 0;  }
void S02047() { lac &= (010000|core[000000]);  }
void P02050() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void D02051() { core[000055] = lac & 07777; lac &= 010000; code[000055] = &emul8;  }
void D02052() { lac += core[002034];  }
void I02053() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void P02054() { lac ^= 07777; lac++;  }
void L02055() { lac += core[000054];  }
void I02056() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02057() { core[(ib<<12)+core[118]] = 02060; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I02060() { core[(ib<<12)+core[101]] = 02061; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I02061() { npc = (ib<<12)+core[1063]; inh = 0;  }
void S02062() { lac &= (010000|core[000000]);  }
void L02063() { emul8();  }
void I02064() { core[(ib<<12)+core[109]] = 02065; npc = (ib<<12)+core[109]+1; code[(ib<<12)+core[109]] = &emul8; inh = 0;  }
void I02065() { npc = (ib<<12)+core[1074]; inh = 0;  }
void I02066() { if (++core[000026] == 010000) { core[000026] = 0; npc++; }; code[000026] = &emul8;  }
void L02067() { core[(ib<<12)+core[101]] = 02070; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I02070() { lac += core[000066];  }
void I02071() { lac += core[000116];  }
void I02072() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void D02073() { npc = 002067; inh = 0;  }
void D02074() { lac += core[000017];  }
void D02075() { lac ^= 07777;  }
void D02076() { lac += core[000023];  }
void I02077() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02100() { lac += core[000133];  }
void I02101() { lac ^= 07777; lac++;  }
void I02102() { lac += core[000023];  }
void I02103() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02104() { npc = 000177; inh = 0;  }
void I02105() {  }
void I02106() { lac += core[(df<<12)+core[19]];  }
void I02107() { core[(df<<12)+core[21]] = lac & 07777; lac &= 010000; code[(df<<12)+core[21]] = &emul8;  }
void I02110() { lac += core[000133];  }
void L02111() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I02112() { lac += core[(df<<12)+core[57]];  }
void I02113() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02114() { npc = 002127; inh = 0;  }
void I02115() { core[000032] = lac & 07777; lac &= 010000; code[000032] = &emul8;  }
void I02116() { lac += core[000023];  }
void I02117() { lac &= 07777; lac ^= 07777; lac++;  }
void I02120() { lac += core[000032];  }
void I02121() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02122() { lac += core[000057];  }
void I02123() { lac += core[000032];  }
void I02124() { core[(df<<12)+core[57]] = lac & 07777; lac &= 010000; code[(df<<12)+core[57]] = &emul8;  }
void I02125() { lac += core[000032];  }
void I02126() { npc = 002111; inh = 0;  }
void L02127() { lac ^= 07777;  }
void I02130() { lac += core[000023];  }
void I02131() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I02132() { lac += core[000057];  }
void I02133() { lac ^= 07777;  }
void I02134() { lac += core[000023];  }
void D02135() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I02136() { lac += core[000057];  }
void I02137() { lac += core[000060];  }
void I02140() { core[000060] = lac & 07777; lac &= 010000; code[000060] = &emul8;  }
void I02141() { lac += core[000010];  }
void I02142() { lac ^= 07777;  }
void I02143() { lac += core[000012];  }
void I02144() { core[000032] = lac & 07777; lac &= 010000; code[000032] = &emul8;  }
void I02145() { lac += core[000010];  }
void I02146() { lac += core[000057];  }
void I02147() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L02150() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I02151() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I02152() { if (++core[000032] == 010000) { core[000032] = 0; npc++; }; code[000032] = &emul8;  }
void I02153() { npc = 002150; inh = 0;  }
void I02154() { npc = 002063; inh = 0;  }
void S02155() { lac &= (010000|core[000000]);  }
void I02156() { core[(ib<<12)+core[52]] = 02157; npc = (ib<<12)+core[52]+1; code[(ib<<12)+core[52]] = &emul8; inh = 0;  }
void I02157() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I02160() { core[(ib<<12)+core[104]] = 02161; npc = (ib<<12)+core[104]+1; code[(ib<<12)+core[104]] = &emul8; inh = 0;  }
void I02161() { lac += core[(df<<12)+core[1043]];  }
void I02162() { npc = (ib<<12)+core[1133]; inh = 0;  }
void I02163() { core[(ib<<12)+core[105]] = 02164; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02164() { npc = (ib<<12)+core[1133]; inh = 0;  }
void I02165() { if (++core[(df<<12)+core[91]] == 010000) { core[(df<<12)+core[91]] = 0; npc++; }; code[(df<<12)+core[91]] = &emul8;  }
void I02166() { if (++core[(df<<12)+core[1064]] == 010000) { core[(df<<12)+core[1064]] = 0; npc++; }; code[(df<<12)+core[1064]] = &emul8;  }
void I02167() { if (++core[(df<<12)+core[1054]] == 010000) { core[(df<<12)+core[1054]] = 0; npc++; }; code[(df<<12)+core[1054]] = &emul8;  }
void I02170() { if (++core[(df<<12)+core[117]] == 010000) { core[(df<<12)+core[117]] = 0; npc++; }; code[(df<<12)+core[117]] = &emul8;  }
void I02171() { if (++core[(df<<12)+core[1048]] == 010000) { core[(df<<12)+core[1048]] = 0; npc++; }; code[(df<<12)+core[1048]] = &emul8;  }
void I02172() { if (++core[(df<<12)+core[79]] == 010000) { core[(df<<12)+core[79]] = 0; npc++; }; code[(df<<12)+core[79]] = &emul8;  }
void I02173() { if (++core[(df<<12)+core[122]] == 010000) { core[(df<<12)+core[122]] = 0; npc++; }; code[(df<<12)+core[122]] = &emul8;  }
void I02174() { if (++core[(df<<12)+core[1044]] == 010000) { core[(df<<12)+core[1044]] = 0; npc++; }; code[(df<<12)+core[1044]] = &emul8;  }
void I02175() { if (++core[(df<<12)+core[1045]] == 010000) { core[(df<<12)+core[1045]] = 0; npc++; }; code[(df<<12)+core[1045]] = &emul8;  }
void I02176() { if (++core[(df<<12)+core[1068]] == 010000) { core[(df<<12)+core[1068]] = 0; npc++; }; code[(df<<12)+core[1068]] = &emul8;  }
void I02177() { if (++core[(df<<12)+core[125]] == 010000) { core[(df<<12)+core[125]] = 0; npc++; }; code[(df<<12)+core[125]] = &emul8;  }
void I02200() { if (++core[(df<<12)+core[1218]] == 010000) { core[(df<<12)+core[1218]] = 0; npc++; }; code[(df<<12)+core[1218]] = &emul8;  }
void I02201() { if (++core[(df<<12)+core[1177]] == 010000) { core[(df<<12)+core[1177]] = 0; npc++; }; code[(df<<12)+core[1177]] = &emul8;  }
void I02202() { if (++core[(df<<12)+core[119]] == 010000) { core[(df<<12)+core[119]] = 0; npc++; }; code[(df<<12)+core[119]] = &emul8;  }
void I02203() { lac &= (010000|core[002330]);  }
void I02204() { core[(ib<<12)+core[116]] = 02205; npc = (ib<<12)+core[116]+1; code[(ib<<12)+core[116]] = &emul8; inh = 0;  }
void I02205() { npc = 002237; inh = 0;  }
void I02206() { npc = 002222; inh = 0;  }
void I02207() { npc = 002213; inh = 0;  }
void I02210() { lac += core[000066];  }
void I02211() { lac += core[000112];  }
void I02212() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void L02213() { core[(ib<<12)+core[118]] = 02214; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void L02214() { lac += core[000135];  }
void I02215() { core[000060] = lac & 07777; lac &= 010000; code[000060] = &emul8;  }
void I02216() { core[(df<<12)+core[91]] = lac & 07777; lac &= 010000; code[(df<<12)+core[91]] = &emul8;  }
void L02217() { lac += core[000060];  }
void I02220() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I02221() { npc = 000177; inh = 0;  }
void L02222() { core[(ib<<12)+core[108]] = 02223; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I02223() { lac += core[000060];  }
void I02224() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L02225() { core[(ib<<12)+core[117]] = 02226; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void I02226() { if (++core[000023] == 010000) { core[000023] = 0; npc++; }; code[000023] = &emul8;  }
void I02227() { lac += core[000065];  }
void I02230() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void P02231() { lac += core[(df<<12)+core[19]];  }
void I02232() { core[(ib<<12)+core[115]] = 02233; npc = (ib<<12)+core[115]+1; code[(ib<<12)+core[115]] = &emul8; inh = 0;  }
void I02233() { npc = 002217; inh = 0;  }
void I02234() { lac += core[(df<<12)+core[19]];  }
void I02235() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I02236() { npc = 002225; inh = 0;  }
void L02237() { lac += core[000060];  }
void I02240() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I02241() { npc = (ib<<12)+core[97]; inh = 0;  }
void S02242() { lac &= (010000|core[000000]);  }
void I02243() { lac += core[000133];  }
void I02244() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I02245() { lac += core[000133];  }
void L02246() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void I02247() { lac += core[000023];  }
void I02250() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I02251() { lac += core[000067];  }
void I02252() { lac &= 07777; lac ^= 07777; lac++;  }
void D02253() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I02254() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02255() { npc = 002266; inh = 0;  }
void I02256() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02257() { npc = 002267; inh = 0;  }
void I02260() { lac += core[000023];  }
void I02261() { core[000025] = lac & 07777; lac &= 010000; code[000025] = &emul8;  }
void I02262() { lac += core[(df<<12)+core[19]];  }
void I02263() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02264() { npc = 002246; inh = 0;  }
void I02265() { skp = 0; skp = !skp; npc += skp;  }
void L02266() { if (++core[002242] == 010000) { core[002242] = 0; npc++; }; code[002242] = &emul8;  }
void L02267() { lac += core[000023];  }
void I02270() { lac++;  }
void I02271() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02272() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I02273() { npc = (ib<<12)+core[1186]; inh = 0;  }
void S02274() { lac &= (010000|core[000000]);  }
void L02275() { core[002330] = 02276; npc = 002330+1; code[002330] = &emul8; inh = 0;  }
void L02276() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02277() { lac += core[000006];  }
void I02300() { lac += core[002357];  }
void I02301() { lac += core[000066];  }
void P02302() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02303() { npc = 002316; inh = 0;  }
void I02304() { lac += core[000075];  }
void L02305() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I02306() { lac += core[000026];  }
void I02307() { lac += core[000100];  }
void I02310() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02311() { core[(ib<<12)+core[105]] = 02312; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02312() { npc = (ib<<12)+core[1212]; inh = 0;  }
void L02313() { core[002330] = 02314; npc = 002330+1; code[002330] = &emul8; inh = 0;  }
void D02314() { lac ^= 07777;  }
void I02315() { npc = 002276; inh = 0;  }
void L02316() { lac += core[000026];  }
void I02317() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02320() { npc = 002326; inh = 0;  }
void I02321() { lac += core[000100];  }
void I02322() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02323() { lac++;  }
void I02324() { core[000100] = lac & 07777; lac &= 010000; code[000100] = &emul8;  }
void I02325() { npc = 002275; inh = 0;  }
void L02326() { lac += core[000110];  }
void I02327() { npc = 002305; inh = 0;  }
void S02330() { lac &= (010000|core[000000]);  }
void I02331() { if (++core[000020] == 010000) { core[000020] = 0; npc++; }; code[000020] = &emul8;  }
void I02332() { npc = 002345; inh = 0;  }
void I02333() { lac += core[000021];  }
void L02334() { lac &= (010000|core[000122]);  }
void I02335() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I02336() { lac += core[000066];  }
void I02337() { lac += core[000103];  }
void I02340() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02341() { npc = 002313; inh = 0;  }
void I02342() { lac += core[000066];  }
void I02343() { lac += core[002356];  }
void L02344() { npc = (ib<<12)+core[1240]; inh = 0;  }
void L02345() { if (++core[000017] == 010000) core[000017] = 0000;lac += core[(df<<12)+core[000017]];  }
void I02346() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I02347() { lac ^= 07777;  }
void I02350() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I02351() { lac += core[000021];  }
void I02352() { lac &= 07777; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02353() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02354() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02355() { npc = 002334; inh = 0;  }
void D02356() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D02357() { emul8();  }
void S02360() { lac &= (010000|core[000000]);  }
void I02361() {  }
void I02362() { lac += core[(df<<12)+core[21]];  }
void I02363() { core[(df<<12)+core[48]] = lac & 07777; lac &= 010000; code[(df<<12)+core[48]] = &emul8;  }
void I02364() { lac += core[000060];  }
void I02365() { core[(df<<12)+core[21]] = lac & 07777; lac &= 010000; code[(df<<12)+core[21]] = &emul8;  }
void I02366() { lac += core[000061];  }
void I02367() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02370() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I02371() { lac += core[000010];  }
void I02372() { lac++;  }
void I02373() { core[000060] = lac & 07777; lac &= 010000; code[000060] = &emul8;  }
void I02374() { lac += core[000060];  }
void I02375() { core[000031] = lac & 07777; lac &= 010000; code[000031] = &emul8;  }
void I02376() { npc = (ib<<12)+core[1264]; inh = 0;  }
void I02377() { lac += core[002253];  }
void I02400() { lac &= (010000|core[(df<<12)+core[1292]]);  }
void I02401() { emul8();  }
void I02402() { lac &= (010000|core[(df<<12)+core[1391]]);  }
void I02403() { lac &= (010000|core[(df<<12)+core[1391]]);  }
void I02404() { emul8();  }
void I02405() { lac &= (010000|core[000001]);  }
void I02406() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void D02407() { lac &= (010000|core[000000]);  }
void I02410() { lac &= (010000|core[000000]);  }
void I02411() { lac &= (010000|core[000000]);  }
void I02412() { lac &= (010000|core[000000]);  }
void D02413() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void S02414() { lac &= (010000|core[000000]);  }
void L02415() { emul8();  }
void I02416() { npc = 002415; inh = 0;  }
void I02417() { emul8();  }
void I02420() { lac &= (010000|core[000106]);  }
void I02421() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02422() { npc = 002415; inh = 0;  }
void I02423() { lac += core[000123];  }
void I02424() { npc = (ib<<12)+core[1292]; inh = 0;  }
void S02425() { lac &= (010000|core[000000]);  }
void I02426() { lac += core[000067];  }
void I02427() { core[(ib<<12)+core[111]] = 02430; npc = (ib<<12)+core[111]+1; code[(ib<<12)+core[111]] = &emul8; inh = 0;  }
void I02430() { lac &= (010000|core[000122]);  }
void I02431() { core[002442] = 02432; npc = 002442+1; code[002442] = &emul8; inh = 0;  }
void I02432() { lac += core[000102];  }
void I02433() { core[(ib<<12)+core[105]] = 02434; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02434() { lac += core[000067];  }
void I02435() { core[002442] = 02436; npc = 002442+1; code[002442] = &emul8; inh = 0;  }
void I02436() { lac += core[002556];  }
void I02437() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I02440() { core[(ib<<12)+core[105]] = 02441; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02441() { npc = (ib<<12)+core[1301]; inh = 0;  }
void S02442() { lac &= (010000|core[000000]);  }
void I02443() { lac &= (010000|core[000106]);  }
void I02444() { core[000032] = lac & 07777; lac &= 010000; code[000032] = &emul8;  }
void I02445() { lac += core[000113];  }
void I02446() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I02447() { npc = 002452; inh = 0;  }
void L02450() { if (++core[000033] == 010000) { core[000033] = 0; npc++; }; code[000033] = &emul8;  }
void I02451() { core[000032] = lac & 07777; lac &= 010000; code[000032] = &emul8;  }
void L02452() { lac += core[000032];  }
void I02453() { lac += core[002413];  }
void I02454() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I02455() { npc = 002450; inh = 0;  }
void I02456() { lac &= 010000;  }
void I02457() { lac += core[000033];  }
void I02460() { core[(ib<<12)+core[105]] = 02461; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02461() { lac += core[000032];  }
void D02462() { lac += core[000113];  }
void I02463() { core[(ib<<12)+core[105]] = 02464; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02464() { npc = (ib<<12)+core[1314]; inh = 0;  }
void S02465() { lac &= (010000|core[000000]);  }
void I02466() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02467() { lac += core[000066];  }
void I02470() { lac += core[000116];  }
void I02471() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02472() { npc = 002476; inh = 0;  }
void I02473() { lac += core[000077];  }
void L02474() { core[(ib<<12)+core[51]] = 02475; npc = (ib<<12)+core[51]+1; code[(ib<<12)+core[51]] = &emul8; inh = 0;  }
void I02475() { npc = (ib<<12)+core[1333]; inh = 0;  }
void L02476() { lac += core[000077];  }
void I02477() { core[(ib<<12)+core[51]] = 02500; npc = (ib<<12)+core[51]+1; code[(ib<<12)+core[51]] = &emul8; inh = 0;  }
void I02500() { lac += core[000076];  }
void I02501() { npc = 002474; inh = 0;  }
void S02502() { lac &= (010000|core[000000]);  }
void I02503() { lac += core[000110];  }
void I02504() { lac ^= 07777; lac++;  }
void I02505() { lac += core[000066];  }
void I02506() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02507() { lac += core[002552];  }
void I02510() { lac += core[000101];  }
void I02511() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02512() { npc = (ib<<12)+core[1389]; inh = 0;  }
void I02513() { lac += core[002553];  }
void I02514() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I02515() { lac += core[000071];  }
void I02516() { lac &= (010000|core[002554]);  }
void D02517() { lac += core[002556];  }
void I02520() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02521() { lac += core[002554];  }
void I02522() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02523() { npc = 002532; inh = 0;  }
void L02524() { lac += core[000071];  }
void I02525() { lac &= (010000|core[000122]);  }
void I02526() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02527() { core[002535] = 02530; npc = 002535+1; code[002535] = &emul8; inh = 0;  }
void L02530() {  }
void I02531() { npc = (ib<<12)+core[1346]; inh = 0;  }
void L02532() { lac += core[000122];  }
void I02533() { core[002535] = 02534; npc = 002535+1; code[002535] = &emul8; inh = 0;  }
void I02534() { npc = 002524; inh = 0;  }
void S02535() { lac &= (010000|core[000000]);  }
void I02536() { if (++core[000062] == 010000) { core[000062] = 0; npc++; }; code[000062] = &emul8;  }
void I02537() { npc = 002557; inh = 0;  }
void I02540() { lac += core[000061];  }
void I02541() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I02542() { core[000061] = lac & 07777; lac &= 010000; code[000061] = &emul8;  }
void I02543() { lac += core[000013];  }
void I02544() { lac &= 07777; lac ^= 07777; lac++;  }
void I02545() { lac += core[000005];  }
void I02546() { lac += core[000010];  }
void I02547() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I02550() { npc = (ib<<12)+core[1373]; inh = 0;  }
void I02551() { core[(ib<<12)+core[118]] = 02552; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void D02552() { lac &= (010000|core[000040]);  }
void D02553() { lac &= (010000|core[002577]);  }
void D02554() { lac &= (010000|core[000140]);  }
void P02555() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void D02556() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void P02557() { core[(ib<<12)+core[111]] = 02560; npc = (ib<<12)+core[111]+1; code[(ib<<12)+core[111]] = &emul8; inh = 0;  }
void I02560() { core[000061] = lac & 07777; lac &= 010000; code[000061] = &emul8;  }
void I02561() { lac ^= 07777;  }
void I02562() { core[000062] = lac & 07777; lac &= 010000; code[000062] = &emul8;  }
void I02563() { npc = (ib<<12)+core[1373]; inh = 0;  }
void D02600() { lac &= (010000|core[000000]);  }
void D02601() { lac &= (010000|core[000000]);  }
void D02602() { emul8();  }
void L02603() { core[002600] = lac & 07777; lac &= 010000; code[002600] = &emul8;  }
void I02604() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I02605() { core[002601] = lac & 07777; lac &= 010000; code[002601] = &emul8;  }
void I02606() { emul8();  }
void I02607() { npc = 002625; inh = 0;  }
void I02610() { emul8();  }
void I02611() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02612() { lac += core[(df<<12)+core[1461]];  }
void I02613() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02614() { npc = 002625; inh = 0;  }
void I02615() { emul8();  }
void I02616() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02617() { core[(df<<12)+core[1461]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1461]] = &emul8;  }
void I02620() { lac += core[002665];  }
void I02621() { lac++;  }
void I02622() { lac &= (010000|core[000107]);  }
void I02623() { lac += core[002663];  }
void I02624() { core[002665] = lac & 07777; lac &= 010000; code[002665] = &emul8;  }
void L02625() { emul8();  }
void I02626() { npc = 002646; inh = 0;  }
void I02627() { emul8();  }
void I02630() { lac &= (010000|core[000106]);  }
void I02631() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02632() { npc = 002646; inh = 0;  }
void I02633() { lac += core[000123];  }
void I02634() { core[002662] = lac & 07777; lac &= 010000; code[002662] = &emul8;  }
void I02635() { lac += core[002662];  }
void I02636() { lac += core[002602];  }
void I02637() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02640() { npc = 002740; inh = 0;  }
void I02641() { lac += core[000034];  }
void I02642() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02643() { core[(ib<<12)+core[118]] = 02644; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I02644() { lac += core[002662];  }
void I02645() { core[000034] = lac & 07777; lac &= 010000; code[000034] = &emul8;  }
void L02646() { emul8();  }
void I02647() { npc = 002652; inh = 0;  }
void I02650() { emul8();  }
void I02651() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void L02652() { emul8();  }
void I02653() { emul8();  }
void D02654() {  }
void I02655() { lac += core[002601];  }
void I02656() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I02657() { lac += core[002600];  }
void I02660() { emul8();  }
void D02661() { npc = (ib<<12)+core[0]; inh = 0;  }
void D02662() { lac &= (010000|core[000000]);  }
void D02663() { core[000120] = lac & 07777; lac &= 010000; code[000120] = &emul8;  }
void P02664() { core[000120] = lac & 07777; lac &= 010000; code[000120] = &emul8;  }
void P02665() { core[000120] = lac & 07777; lac &= 010000; code[000120] = &emul8;  }
void S02666() { lac &= (010000|core[000000]);  }
void L02667() { lac += core[000034];  }
void I02670() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I02671() { npc = 002667; inh = 0;  }
void I02672() { core[002676] = lac & 07777; lac &= 010000; code[002676] = &emul8;  }
void I02673() { core[000034] = lac & 07777; lac &= 010000; code[000034] = &emul8;  }
void I02674() { lac += core[002676];  }
void D02675() { npc = (ib<<12)+core[1462]; inh = 0;  }
void S02676() { lac &= (010000|core[000000]);  }
void I02677() { core[002666] = lac & 07777; lac &= 010000; code[002666] = &emul8;  }
void I02700() { emul8();  }
void L02701() { lac += core[(df<<12)+core[1460]];  }
void I02702() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02703() { npc = 002701; inh = 0;  }
void I02704() { emul8();  }
void I02705() { lac += core[000016];  }
void I02706() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02707() { npc = 002714; inh = 0;  }
void I02710() { lac += core[002666];  }
void I02711() { emul8();  }
void I02712() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I02713() { npc = 002723; inh = 0;  }
void L02714() { lac += core[002666];  }
void I02715() { core[(df<<12)+core[1460]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1460]] = &emul8;  }
void I02716() { lac += core[002664];  }
void I02717() { lac++;  }
void I02720() { lac &= (010000|core[000107]);  }
void I02721() { lac += core[002663];  }
void I02722() { core[002664] = lac & 07777; lac &= 010000; code[002664] = &emul8;  }
void L02723() { emul8();  }
void I02724() { npc = (ib<<12)+core[1470]; inh = 0;  }
void D02725() { core[002726] = lac & 07777; lac &= 010000; code[002726] = &emul8;  }
void D02726() { lac &= (010000|core[000000]);  }
void I02727() { lac &= 010000; lac ^= 07777;  }
void I02730() { lac += core[002726];  }
void I02731() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I02732() { emul8();  }
void L02733() { lac += core[000016];  }
void I02734() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02735() { npc = 002733; inh = 0;  }
void I02736() { emul8();  }
void I02737() { npc = 002742; inh = 0;  }
void L02740() { lac += core[000123];  }
void I02741() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void L02742() { if (++core[000016] == 010000) { core[000016] = 0; npc++; }; code[000016] = &emul8;  }
void I02743() { lac += core[000105];  }
void I02744() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02745() { lac ^= 07777;  }
void I02746() { lac += core[002663];  }
void I02747() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I02750() {  }
void L02751() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I02752() { if (++core[000057] == 010000) { core[000057] = 0; npc++; }; code[000057] = &emul8;  }
void I02753() { npc = 002751; inh = 0;  }
void I02754() { core[000034] = lac & 07777; lac &= 010000; code[000034] = &emul8;  }
void I02755() { lac += core[002663];  }
void I02756() { core[002665] = lac & 07777; lac &= 010000; code[002665] = &emul8;  }
void I02757() { lac += core[002663];  }
void I02760() { core[002664] = lac & 07777; lac &= 010000; code[002664] = &emul8;  }
void I02761() { lac ^= 07777;  }
void I02762() { emul8();  }
void I02763() { lac += core[000101];  }
void I02764() { core[(ib<<12)+core[105]] = 02765; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02765() { core[(ib<<12)+core[107]] = 02766; npc = (ib<<12)+core[107]+1; code[(ib<<12)+core[107]] = &emul8; inh = 0;  }
void I02766() { if (++core[000022] == 010000) { core[000022] = 0; npc++; }; code[000022] = &emul8;  }
void I02767() { lac += core[(df<<12)+core[18]];  }
void I02770() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02771() { npc = 002777; inh = 0;  }
void I02772() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I02773() { lac += core[000101];  }
void I02774() { core[(ib<<12)+core[105]] = 02775; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02775() { core[(ib<<12)+core[105]] = 02776; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I02776() { core[(ib<<12)+core[107]] = 02777; npc = (ib<<12)+core[107]+1; code[(ib<<12)+core[107]] = &emul8; inh = 0;  }
void L02777() { lac += core[000077];  }
void I03000() { core[(ib<<12)+core[105]] = 03001; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I03001() { lac += core[000126];  }
void I03002() { core[000152] = lac & 07777; lac &= 010000; code[000152] = &emul8;  }
void I03003() { npc = 000177; inh = 0;  }
void L03004() { lac += core[000062];  }
void I03005() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03006() { npc = 003014; inh = 0;  }
void I03007() { lac += core[000010];  }
void I03010() { lac ^= 07777; lac++;  }
void I03011() { lac += core[000027];  }
void I03012() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I03013() { npc = (ib<<12)+core[1569]; inh = 0;  }
void L03014() { lac += core[003051];  }
void I03015() { core[(ib<<12)+core[105]] = 03016; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I03016() { lac += core[000010];  }
void I03017() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I03020() {  }
void I03021() { if (++core[000062] == 010000) { core[000062] = 0; npc++; }; code[000062] = &emul8;  }
void I03022() { npc = 003042; inh = 0;  }
void I03023() { lac += core[(df<<12)+core[57]];  }
void I03024() { lac &= (010000|core[000122]);  }
void I03025() { lac += core[000103];  }
void I03026() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03027() { npc = 003037; inh = 0;  }
void L03030() { lac ^= 07777;  }
void L03031() { core[000062] = lac & 07777; lac &= 010000; code[000062] = &emul8;  }
void I03032() { lac ^= 07777;  }
void I03033() { lac += core[000010];  }
void I03034() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I03035() { lac += core[(df<<12)+core[57]];  }
void I03036() { lac &= (010000|core[000101]);  }
void L03037() { core[000061] = lac & 07777; lac &= 010000; code[000061] = &emul8;  }
void I03040() { npc = (ib<<12)+core[1569]; inh = 0;  }
void P03041() { if (++core[(df<<12)+core[88]] == 010000) { core[(df<<12)+core[88]] = 0; npc++; }; code[(df<<12)+core[88]] = &emul8;  }
void L03042() { lac += core[(df<<12)+core[57]];  }
void I03043() { lac &= (010000|core[000101]);  }
void I03044() { lac += core[000006];  }
void L03045() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03046() { npc = 003030; inh = 0;  }
void I03047() { core[(df<<12)+core[57]] = lac & 07777; lac &= 010000; code[(df<<12)+core[57]] = &emul8;  }
void I03050() { npc = 003031; inh = 0;  }
void D03051() { lac &= (010000|core[003134]);  }
void I03052() { lac += core[000060];  }
void L03053() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void I03054() { lac += core[000031];  }
void I03055() { lac ^= 07777; lac++;  }
void I03056() { lac += core[000030];  }
void I03057() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I03060() { npc = (ib<<12)+core[97]; inh = 0;  }
void I03061() { lac += core[(df<<12)+core[24]];  }
void I03062() { core[003116] = lac & 07777; lac &= 010000; code[003116] = &emul8;  }
void I03063() { lac += core[003115];  }
void I03064() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I03065() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I03066() { core[(ib<<12)+core[101]] = 03067; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03067() { core[(ib<<12)+core[105]] = 03070; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I03070() { core[(ib<<12)+core[101]] = 03071; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03071() { core[(ib<<12)+core[105]] = 03072; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I03072() { core[(ib<<12)+core[101]] = 03073; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03073() { core[(ib<<12)+core[105]] = 03074; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I03074() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void I03075() { lac += core[(df<<12)+core[24]];  }
void I03076() { core[(ib<<12)+core[1612]] = 03077; npc = (ib<<12)+core[1612]+1; code[(ib<<12)+core[1612]] = &emul8; inh = 0;  }
void I03077() { core[(ib<<12)+core[101]] = 03100; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I03100() { core[(ib<<12)+core[105]] = 03101; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I03101() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void I03102() { core[(ib<<12)+core[7]] = 03103; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I03103() { &emul8;  }
void I03104() { &emul8;  }
void I03105() { core[(ib<<12)+core[88]] = 03106; npc = (ib<<12)+core[88]+1; code[(ib<<12)+core[88]] = &emul8; inh = 0;  }
void I03106() { lac += core[000077];  }
void I03107() { core[(ib<<12)+core[105]] = 03110; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I03110() { lac += core[000070];  }
void I03111() { lac += core[000111];  }
void I03112() { lac += core[000030];  }
void I03113() { npc = 003053; inh = 0;  }
void P03114() { if (++core[(df<<12)+core[34]] == 010000) { core[(df<<12)+core[34]] = 0; npc++; }; code[(df<<12)+core[34]] = &emul8;  }
void D03115() { core[000115] = lac & 07777; lac &= 010000; code[000115] = &emul8;  }
void D03116() { lac &= (010000|core[000000]);  }
void D03117() { npc = 000051; inh = 0;  }
void D03120() { lac &= (010000|core[000000]);  }
void D03206() { core[003217] = lac & 07777; lac &= 010000; code[003217] = &emul8;  }
void P03207() { lac &= (010000|core[000000]);  }
void I03210() { lac &= (010000|core[003355]);  }
void I03211() { lac &= (010000|core[(df<<12)+core[1679]]);  }
void D03212() { lac &= (010000|core[003301]);  }
void I03213() { lac += core[(df<<12)+core[44]];  }
void I03214() { emul8();  }
void D03215() { emul8();  }
void I03216() { emul8();  }
void P03217() { core[003235] = lac & 07777; lac &= 010000; code[003235] = &emul8;  }
void I03220() { lac &= (010000|core[003212]);  }
void I03221() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03222() { core[000142] = 03223; npc = 000142+1; code[000142] = &emul8; inh = 0;  }
void I03223() { lac &= (010000|core[003317]);  }
void D03224() { lac += core[(df<<12)+core[1671]];  }
void I03225() { if (++core[003201] == 010000) { core[003201] = 0; npc++; }; code[003201] = &emul8;  }
void I03226() { if (++core[(df<<12)+core[21]] == 010000) { core[(df<<12)+core[21]] = 0; npc++; }; code[(df<<12)+core[21]] = &emul8;  }
void I03227() { lac += core[(df<<12)+core[1]];  }
void I03230() { if (++core[000011] == 010000) core[000011] = 0000;if (++core[(df<<12)+core[000011]] == 010000) { core[(df<<12)+core[000011]] = 0; npc++; }; code[(df<<12)+core[000011]] = &emul8;  }
void D03231() { lac += core[(df<<12)+core[1742]];  }
void D03232() { if (++core[003341] == 010000) { core[003341] = 0; npc++; }; code[003341] = &emul8;  }
void D03233() { core[000142] = 03234; npc = 000142+1; code[000142] = &emul8; inh = 0;  }
void I03234() { emul8();  }
void D03235() { core[003272] = lac & 07777; lac &= 010000; code[003272] = &emul8;  }
void D03236() { lac &= (010000|core[003224]);  }
void I03237() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void P03240() { core[000041] = 03241; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void I03241() { core[003231] = 03242; npc = 003231+1; code[003231] = &emul8; inh = 0;  }
void P03242() { lac += core[(df<<12)+core[1749]];  }
void I03243() { core[000010] = 03244; npc = 000010+1; code[000010] = &emul8; inh = 0;  }
void I03244() { lac &= (010000|core[000126]);  }
void I03245() { lac &= (010000|core[(df<<12)+core[96]]);  }
void I03246() { if (++core[003325] == 010000) { core[003325] = 0; npc++; }; code[003325] = &emul8;  }
void I03247() { lac &= (010000|core[003303]);  }
void I03250() { lac &= (010000|core[(df<<12)+core[83]]);  }
void I03251() { if (++core[003306] == 010000) { core[003306] = 0; npc++; }; code[003306] = &emul8;  }
void I03252() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void I03253() { lac += core[(df<<12)+core[25]];  }
void I03254() { core[000014] = 03255; npc = 000014+1; code[000014] = &emul8; inh = 0;  }
void I03255() { lac += core[(df<<12)+core[1729]];  }
void I03256() { lac &= (010000|core[(df<<12)+core[5]]);  }
void I03257() { lac &= (010000|core[(df<<12)+core[32]]);  }
void I03260() { core[(ib<<12)+core[1734]] = 03261; npc = (ib<<12)+core[1734]+1; code[(ib<<12)+core[1734]] = &emul8; inh = 0;  }
void I03261() { lac += core[(df<<12)+core[1731]];  }
void P03262() { lac &= (010000|core[000114]);  }
void P03263() { npc = (ib<<12)+core[49]; inh = 0;  }
void P03264() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I03265() { lac &= 07777; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I03266() { core[000017] = 03267; npc = 000017+1; code[000017] = &emul8; inh = 0;  }
void I03267() { lac += core[(df<<12)+core[1696]];  }
void I03270() { lac &= (010000|core[000140]);  }
void P03271() { emul8();  }
void D03272() { core[003330] = lac & 07777; lac &= 010000; code[003330] = &emul8;  }
void I03273() { lac &= (010000|core[003231]);  }
void I03274() { if (++core[003305] == 010000) { core[003305] = 0; npc++; }; code[003305] = &emul8;  }
void I03275() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03276() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void I03277() { if (++core[000075] == 010000) { core[000075] = 0; npc++; }; code[000075] = &emul8;  }
void I03300() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void P03301() { if (++core[000052] == 010000) { core[000052] = 0; npc++; }; code[000052] = &emul8;  }
void I03302() { emul8();  }
void P03303() { emul8();  }
void I03304() { lac &= 010000; lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void D03305() { core[000061] = 03306; npc = 000061+1; code[000061] = &emul8; inh = 0;  }
void P03306() { npc = (ib<<12)+core[1714]; inh = 0;  }
void I03307() { emul8();  }
void I03310() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I03311() { core[000061] = 03312; npc = 000061+1; code[000061] = &emul8; inh = 0;  }
void I03312() { npc = (ib<<12)+core[1721]; inh = 0;  }
void I03313() { lac &= 010000; lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I03314() { lac += core[(df<<12)+core[1760]];  }
void I03315() { emul8();  }
void P03316() { core[000024] = 03317; npc = 000024+1; code[000024] = &emul8; inh = 0;  }
void D03317() { core[000041] = 03320; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void I03320() { core[003220] = 03321; npc = 003220+1; code[003220] = &emul8; inh = 0;  }
void I03321() { if (++core[003217] == 010000) { core[003217] = 0; npc++; }; code[003217] = &emul8;  }
void I03322() { lac &= (010000|core[003305]);  }
void I03323() { lac &= (010000|core[(df<<12)+core[68]]);  }
void I03324() { npc = (ib<<12)+core[1698]; inh = 0;  }
void P03325() { core[000141] = 03326; npc = 000141+1; code[000141] = &emul8; inh = 0;  }
void I03326() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I03327() { emul8();  }
void D03330() { core[003354] = lac & 07777; lac &= 010000; code[003354] = &emul8;  }
void I03331() { lac &= (010000|core[003232]);  }
void I03332() { lac += core[000106];  }
void I03333() { core[000050] = 03334; npc = 000050+1; code[000050] = &emul8; inh = 0;  }
void I03334() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void I03335() { if (++core[000055] == 010000) { core[000055] = 0; npc++; }; code[000055] = &emul8;  }
void I03336() { emul8();  }
void I03337() { core[000061] = 03340; npc = 000061+1; code[000061] = &emul8; inh = 0;  }
void P03340() { npc = (ib<<12)+core[1715]; inh = 0;  }
void D03341() { emul8();  }
void I03342() { emul8();  }
void I03343() { emul8();  }
void I03344() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03345() { core[000042] = 03346; npc = 000042+1; code[000042] = &emul8; inh = 0;  }
void I03346() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void I03347() { if (++core[000055] == 010000) { core[000055] = 0; npc++; }; code[000055] = &emul8;  }
void I03350() { lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03351() { lac += core[(df<<12)+core[34]];  }
void I03352() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I03353() { emul8();  }
void D03354() { core[003365] = lac & 07777; lac &= 010000; code[003365] = &emul8;  }
void D03355() { lac &= (010000|core[003233]);  }
void I03356() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03357() { core[003220] = 03360; npc = 003220+1; code[003220] = &emul8; inh = 0;  }
void I03360() { lac &= (010000|core[(df<<12)+core[16]]);  }
void I03361() { npc = (ib<<12)+core[113]; inh = 0;  }
void I03362() { emul8();  }
void I03363() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I03364() { emul8();  }
void D03365() { core[(df<<12)+core[3]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3]] = &emul8;  }
void I03366() { lac &= (010000|core[003236]);  }
void I03367() { lac += core[000140];  }
void I03370() { npc = 000020; inh = 0;  }
void I03371() { lac &= (010000|core[(df<<12)+core[16]]);  }
void I03372() { npc = (ib<<12)+core[117]; inh = 0;  }
void I03373() { npc = 000161; inh = 0;  }
void I03374() { npc = (ib<<12)+core[1716]; inh = 0;  }
void I03375() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03376() { core[000042] = 03377; npc = 000042+1; code[000042] = &emul8; inh = 0;  }
void I03377() { lac += core[(df<<12)+core[1]];  }
void I03400() { lac &= (010000|core[003455]);  }
void P03401() { lac ^= 07777; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void D03402() { emul8();  }
void P03403() { core[(df<<12)+core[17]] = lac & 07777; lac &= 010000; code[(df<<12)+core[17]] = &emul8;  }
void I03404() { lac &= (010000|core[003450]);  }
void D03405() { lac += core[000140];  }
void I03406() { npc = 000020; inh = 0;  }
void I03407() { lac &= (010000|core[(df<<12)+core[16]]);  }
void I03410() { npc = (ib<<12)+core[116]; inh = 0;  }
void I03411() { npc = 000161; inh = 0;  }
void I03412() { npc = (ib<<12)+core[1845]; inh = 0;  }
void I03413() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03414() { core[000042] = 03415; npc = 000042+1; code[000042] = &emul8; inh = 0;  }
void I03415() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I03416() { lac += core[(df<<12)+core[1795]];  }
void I03417() { npc = (ib<<12)+core[120]; inh = 0;  }
void I03420() { emul8();  }
void D03421() { core[(df<<12)+core[35]] = lac & 07777; lac &= 010000; code[(df<<12)+core[35]] = &emul8;  }
void I03422() { lac &= (010000|core[003462]);  }
void I03423() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03424() { core[003420] = 03425; npc = 003420+1; code[003420] = &emul8; inh = 0;  }
void I03425() { lac &= (010000|core[(df<<12)+core[16]]);  }
void I03426() { npc = (ib<<12)+core[98]; inh = 0;  }
void I03427() { lac &= 010000; lac &= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03430() { lac &= (010000|core[(df<<12)+core[1824]]);  }
void I03431() { npc = 000020; inh = 0;  }
void I03432() { lac &= (010000|core[(df<<12)+core[16]]);  }
void I03433() { npc = (ib<<12)+core[115]; inh = 0;  }
void I03434() { npc = 000161; inh = 0;  }
void I03435() { npc = (ib<<12)+core[1846]; inh = 0;  }
void I03436() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03437() { core[000042] = 03440; npc = 000042+1; code[000042] = &emul8; inh = 0;  }
void P03440() { lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03441() { lac += core[000142];  }
void P03442() { emul8();  }
void I03443() { core[(df<<12)+core[47]] = lac & 07777; lac &= 010000; code[(df<<12)+core[47]] = &emul8;  }
void I03444() { lac &= (010000|core[003474]);  }
void I03445() { lac += core[000106];  }
void I03446() { core[000050] = 03447; npc = 000050+1; code[000050] = &emul8; inh = 0;  }
void I03447() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void D03450() { if (++core[000055] == 010000) { core[000055] = 0; npc++; }; code[000055] = &emul8;  }
void I03451() { emul8();  }
void I03452() { emul8();  }
void I03453() { emul8();  }
void I03454() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void D03455() { core[003470] = 03456; npc = 003470+1; code[003470] = &emul8; inh = 0;  }
void I03456() { emul8();  }
void I03457() { core[(df<<12)+core[60]] = lac & 07777; lac &= 010000; code[(df<<12)+core[60]] = &emul8;  }
void I03460() { lac &= (010000|core[003506]);  }
void I03461() { lac += core[000106];  }
void D03462() { core[000050] = 03463; npc = 000050+1; code[000050] = &emul8; inh = 0;  }
void I03463() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void P03464() { if (++core[000055] == 010000) { core[000055] = 0; npc++; }; code[000055] = &emul8;  }
void P03465() { emul8();  }
void P03466() { emul8();  }
void I03467() { lac ^= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03470() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void P03471() { core[003470] = 03472; npc = 003470+1; code[003470] = &emul8; inh = 0;  }
void I03472() { npc = (ib<<12)+core[1875]; inh = 0;  }
void I03473() { emul8();  }
void D03474() { core[(df<<12)+core[71]] = lac & 07777; lac &= 010000; code[(df<<12)+core[71]] = &emul8;  }
void I03475() { lac &= (010000|core[003520]);  }
void I03476() { lac += core[000106];  }
void I03477() { core[000050] = 03500; npc = 000050+1; code[000050] = &emul8; inh = 0;  }
void I03500() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void I03501() { if (++core[000051] == 010000) { core[000051] = 0; npc++; }; code[000051] = &emul8;  }
void I03502() { emul8();  }
void I03503() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03504() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void D03505() { core[003465] = 03506; npc = 003465+1; code[003465] = &emul8; inh = 0;  }
void D03506() { emul8();  }
void P03507() { core[(df<<12)+core[82]] = lac & 07777; lac &= 010000; code[(df<<12)+core[82]] = &emul8;  }
void D03510() { lac &= (010000|core[003532]);  }
void I03511() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03512() { core[003440] = 03513; npc = 003440+1; code[003440] = &emul8; inh = 0;  }
void I03513() { lac &= (010000|core[003517]);  }
void I03514() { lac += core[(df<<12)+core[80]];  }
void I03515() { if (++core[(df<<12)+core[84]] == 010000) { core[(df<<12)+core[84]] = 0; npc++; }; code[(df<<12)+core[84]] = &emul8;  }
void I03516() { lac &= (010000|core[(df<<12)+core[82]]);  }
void D03517() { npc = (ib<<12)+core[1826]; inh = 0;  }
void D03520() { core[000141] = 03521; npc = 000141+1; code[000141] = &emul8; inh = 0;  }
void I03521() { emul8();  }
void D03522() { core[(df<<12)+core[89]] = lac & 07777; lac &= 010000; code[(df<<12)+core[89]] = &emul8;  }
void P03523() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I03524() { if (++core[003505] == 010000) { core[003505] = 0; npc++; }; code[003505] = &emul8;  }
void I03525() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03526() { core[000006] = lac & 07777; lac &= 010000; code[000006] = &emul8;  }
void I03527() { emul8();  }
void I03530() { emul8();  }
void I03531() { core[(df<<12)+core[102]] = lac & 07777; lac &= 010000; code[(df<<12)+core[102]] = &emul8;  }
void D03532() { lac &= (010000|core[(df<<12)+core[20]]);  }
void I03533() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03534() { core[000142] = 03535; npc = 000142+1; code[000142] = &emul8; inh = 0;  }
void I03535() { if (++core[003510] == 010000) { core[003510] = 0; npc++; }; code[003510] = &emul8;  }
void I03536() { lac &= (010000|core[000114]);  }
void I03537() { lac += core[(df<<12)+core[32]];  }
void I03540() { lac += core[000140];  }
void I03541() { if (++core[003405] == 010000) { core[003405] = 0; npc++; }; code[003405] = &emul8;  }
void I03542() { if (++core[(df<<12)+core[1]] == 010000) { core[(df<<12)+core[1]] = 0; npc++; }; code[(df<<12)+core[1]] = &emul8;  }
void I03543() { lac += core[000116];  }
void I03544() { core[000042] = 03545; npc = 000042+1; code[000042] = &emul8; inh = 0;  }
void I03545() { emul8();  }
void I03546() { core[(df<<12)+core[114]] = lac & 07777; lac &= 010000; code[(df<<12)+core[114]] = &emul8;  }
void I03547() { lac &= (010000|core[(df<<12)+core[25]]);  }
void I03550() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03551() { core[003414] = 03552; npc = 003414+1; code[003414] = &emul8; inh = 0;  }
void I03552() { lac += core[(df<<12)+core[1863]];  }
void I03553() { npc = (ib<<12)+core[32]; inh = 0;  }
void I03554() { lac &= (010000|core[(df<<12)+core[88]]);  }
void I03555() { if (++core[000054] == 010000) { core[000054] = 0; npc++; }; code[000054] = &emul8;  }
void I03556() { core[000001] = 03557; npc = 000001+1; code[000001] = &emul8; inh = 0;  }
void I03557() { if (++core[000016] == 010000) core[000016] = 0000;if (++core[(df<<12)+core[000016]] == 010000) { core[(df<<12)+core[000016]] = 0; npc++; }; code[(df<<12)+core[000016]] = &emul8;  }
void I03560() { core[000037] = 03561; npc = 000037+1; code[000037] = &emul8; inh = 0;  }
void I03561() { emul8();  }
void I03562() { core[(df<<12)+core[1793]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1793]] = &emul8;  }
void I03563() { lac &= (010000|core[(df<<12)+core[30]]);  }
void I03564() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I03565() { core[000061] = 03566; npc = 000061+1; code[000061] = &emul8; inh = 0;  }
void I03566() { emul8();  }
void I03567() { lac += core[000106];  }
void I03570() { core[000050] = 03571; npc = 000050+1; code[000050] = &emul8; inh = 0;  }
void I03571() { if (++core[003405] == 010000) { core[003405] = 0; npc++; }; code[003405] = &emul8;  }
void I03572() { npc = 000162; inh = 0;  }
void I03573() { npc = (ib<<12)+core[1849]; inh = 0;  }
void I03574() { npc = (ib<<12)+core[50]; inh = 0;  }
void I03575() { npc = (ib<<12)+core[1844]; inh = 0;  }
void I03576() { npc = (ib<<12)+core[50]; inh = 0;  }
void I03577() { npc = (ib<<12)+core[1844]; inh = 0;  }
void I03600() { emul8();  }
void I03601() { core[(df<<12)+core[1946]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1946]] = &emul8;  }
void I03602() { lac &= (010000|core[(df<<12)+core[40]]);  }
void I03603() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I03604() { core[000062] = 03605; npc = 000062+1; code[000062] = &emul8; inh = 0;  }
void P03605() { npc = (ib<<12)+core[1970]; inh = 0;  }
void I03606() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03607() { core[000042] = 03610; npc = 000042+1; code[000042] = &emul8; inh = 0;  }
void I03610() { if (++core[003711] == 010000) { core[003711] = 0; npc++; }; code[003711] = &emul8;  }
void I03611() { lac += core[(df<<12)+core[1925]];  }
void I03612() { npc = (ib<<12)+core[32]; inh = 0;  }
void I03613() { lac &= (010000|core[003717]);  }
void I03614() { if (++core[003711] == 010000) { core[003711] = 0; npc++; }; code[003711] = &emul8;  }
void I03615() { lac += core[(df<<12)+core[1925]];  }
void I03616() { core[000037] = 03617; npc = 000037+1; code[000037] = &emul8; inh = 0;  }
void P03617() { core[003673] = 03620; npc = 003673+1; code[003673] = &emul8; inh = 0;  }
void I03620() { if (++core[000017] == 010000) core[000017] = 0000;lac &= (010000|core[(df<<12)+core[000017]]);  }
void I03621() { core[000061] = 03622; npc = 000061+1; code[000061] = &emul8; inh = 0;  }
void I03622() { emul8();  }
void P03623() { lac += core[000106];  }
void I03624() { core[000050] = 03625; npc = 000050+1; code[000050] = &emul8; inh = 0;  }
void I03625() { if (++core[003605] == 010000) { core[003605] = 0; npc++; }; code[003605] = &emul8;  }
void I03626() { npc = 000162; inh = 0;  }
void I03627() { npc = (ib<<12)+core[1973]; inh = 0;  }
void I03630() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I03631() { emul8();  }
void P03632() { core[(df<<12)+core[1954]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1954]] = &emul8;  }
void I03633() { lac &= (010000|core[(df<<12)+core[50]]);  }
void I03634() { if (++core[003740] == 010000) { core[003740] = 0; npc++; }; code[003740] = &emul8;  }
void I03635() { core[000006] = lac & 07777; lac &= 010000; code[000006] = &emul8;  }
void I03636() { emul8();  }
void I03637() { emul8();  }
void D03640() { core[000022] = 03641; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I03641() { emul8();  }
void P03642() { core[(df<<12)+core[1960]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1960]] = &emul8;  }
void I03643() { lac &= (010000|core[(df<<12)+core[90]]);  }
void I03644() { if (++core[003740] == 010000) { core[003740] = 0; npc++; }; code[003740] = &emul8;  }
void I03645() { core[000006] = lac & 07777; lac &= 010000; code[000006] = &emul8;  }
void I03646() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I03647() { emul8();  }
void P03650() { core[(df<<12)+core[1979]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1979]] = &emul8;  }
void I03651() { if (++core[(df<<12)+core[40]] == 010000) { core[(df<<12)+core[40]] = 0; npc++; }; code[(df<<12)+core[40]] = &emul8;  }
void I03652() { lac &= (010000|core[000140]);  }
void I03653() { if (++core[003605] == 010000) { core[003605] = 0; npc++; }; code[003605] = &emul8;  }
void I03654() { lac &= 010000; lac &= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03655() { core[000050] = 03656; npc = 000050+1; code[000050] = &emul8; inh = 0;  }
void I03656() { if (++core[003605] == 010000) { core[003605] = 0; npc++; }; code[003605] = &emul8;  }
void I03657() { npc = (ib<<12)+core[112]; inh = 0;  }
void I03660() { core[000105] = lac & 07777; lac &= 010000; code[000105] = &emul8;  }
void I03661() { if (++core[003751] == 010000) { core[003751] = 0; npc++; }; code[003751] = &emul8;  }
void P03662() { core[000061] = 03663; npc = 000061+1; code[000061] = &emul8; inh = 0;  }
void I03663() { emul8();  }
void P03664() { emul8();  }
void P03665() { emul8();  }
void I03666() { npc = (ib<<12)+core[1972]; inh = 0;  }
void I03667() { emul8();  }
void P03670() { emul8();  }
void I03671() { npc = (ib<<12)+core[1973]; inh = 0;  }
void I03672() { emul8();  }
void P03673() { core[(df<<12)+core[1988]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1988]] = &emul8;  }
void I03674() { if (++core[(df<<12)+core[45]] == 010000) { core[(df<<12)+core[45]] = 0; npc++; }; code[(df<<12)+core[45]] = &emul8;  }
void I03675() { core[000023] = 03676; npc = 000023+1; code[000023] = &emul8; inh = 0;  }
void I03676() { lac &= (010000|core[(df<<12)+core[84]]);  }
void I03677() { core[000022] = 03700; npc = 000022+1; code[000022] = &emul8; inh = 0;  }
void I03700() { lac &= (010000|core[(df<<12)+core[125]]);  }
void I03701() { npc = (ib<<12)+core[113]; inh = 0;  }
void I03702() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I03703() { emul8();  }
void P03704() { core[(df<<12)+core[2001]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2001]] = &emul8;  }
void P03705() { if (++core[(df<<12)+core[50]] == 010000) { core[(df<<12)+core[50]] = 0; npc++; }; code[(df<<12)+core[50]] = &emul8;  }
void I03706() { lac += core[000106];  }
void I03707() { core[000050] = 03710; npc = 000050+1; code[000050] = &emul8; inh = 0;  }
void I03710() { if (++core[003605] == 010000) { core[003605] = 0; npc++; }; code[003605] = &emul8;  }
void D03711() { npc = (ib<<12)+core[112]; inh = 0;  }
void I03712() { lac += core[(df<<12)+core[1935]];  }
void I03713() { npc = 000161; inh = 0;  }
void I03714() { emul8();  }
void I03715() { emul8();  }
void I03716() { emul8();  }
void D03717() { npc = (ib<<12)+core[1976]; inh = 0;  }
void I03720() { emul8();  }
void P03721() { core[(df<<12)+core[2024]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2024]] = &emul8;  }
void P03722() { if (++core[(df<<12)+core[60]] == 010000) { core[(df<<12)+core[60]] = 0; npc++; }; code[(df<<12)+core[60]] = &emul8;  }
void I03723() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03724() { core[000142] = 03725; npc = 000142+1; code[000142] = &emul8; inh = 0;  }
void I03725() { if (++core[000014] == 010000) { core[000014] = 0; npc++; }; code[000014] = &emul8;  }
void I03726() { lac &= (010000|core[(df<<12)+core[65]]);  }
void I03727() { if (++core[003705] == 010000) { core[003705] = 0; npc++; }; code[003705] = &emul8;  }
void I03730() { core[000001] = 03731; npc = 000001+1; code[000001] = &emul8; inh = 0;  }
void P03731() { lac += core[(df<<12)+core[1939]];  }
void I03732() { if (++core[(df<<12)+core[1989]] == 010000) { core[(df<<12)+core[1989]] = 0; npc++; }; code[(df<<12)+core[1989]] = &emul8;  }
void I03733() { if (++core[003640] == 010000) { core[003640] = 0; npc++; }; code[003640] = &emul8;  }
void I03734() { core[(ib<<12)+core[2009]] = 03735; npc = (ib<<12)+core[2009]+1; code[(ib<<12)+core[2009]] = &emul8; inh = 0;  }
void I03735() { lac &= (010000|core[(df<<12)+core[83]]);  }
void I03736() { core[(ib<<12)+core[2016]] = 03737; npc = (ib<<12)+core[2016]+1; code[(ib<<12)+core[2016]] = &emul8; inh = 0;  }
void I03737() { lac += core[(df<<12)+core[2002]];  }
void P03740() { core[000047] = 03741; npc = 000047+1; code[000047] = &emul8; inh = 0;  }
void I03741() { lac += core[(df<<12)+core[1935]];  }
void I03742() { core[(ib<<12)+core[2016]] = 03743; npc = (ib<<12)+core[2016]+1; code[(ib<<12)+core[2016]] = &emul8; inh = 0;  }
void I03743() { core[003673] = 03744; npc = 003673+1; code[003673] = &emul8; inh = 0;  }
void I03744() { lac &= (010000|core[(df<<12)+core[2016]]);  }
void I03745() { emul8();  }
void I03746() { npc = (ib<<12)+core[1972]; inh = 0;  }
void I03747() { emul8();  }
void P03750() { lac &= (010000|core[000000]);  }
void D03751() { if (++core[(df<<12)+core[80]] == 010000) { core[(df<<12)+core[80]] = 0; npc++; }; code[(df<<12)+core[80]] = &emul8;  }
void I03752() { if (++core[003705] == 010000) { core[003705] = 0; npc++; }; code[003705] = &emul8;  }
void I03753() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I03754() { if (++core[003605] == 010000) { core[003605] = 0; npc++; }; code[003605] = &emul8;  }
void I03755() { emul8();  }
void I03756() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I03757() { emul8();  }
void D04370() { if (++core[(df<<12)+core[2273]] == 010000) { core[(df<<12)+core[2273]] = 0; npc++; }; code[(df<<12)+core[2273]] = &emul8;  }
void L04371() { lac += core[004370];  }
void I04372() { core[000176] = lac & 07777; lac &= 010000; code[000176] = &emul8;  }
void I04373() { emul8();  }
void I04374() { emul8();  }
void I04375() { emul8();  }
void I04376() { emul8();  }
void I04377() { emul8();  }
void I04400() { emul8();  }
void I04401() { emul8();  }
void I04402() { lac &= 010000; lac &= 07777;  }
void L04403() { if (++core[000014] == 010000) core[000014] = 0000;core[(df<<12)+core[000014]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000014]] = &emul8;  }
void I04404() { if (++core[000057] == 010000) { core[000057] = 0; npc++; }; code[000057] = &emul8;  }
void I04405() { npc = 004403; inh = 0;  }
void I04406() { lac += core[004562];  }
void D04407() { core[004571] = 04410; npc = 004571+1; code[004571] = &emul8; inh = 0;  }
void I04410() { lac += core[004570];  }
void I04411() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void D04412() { lac ^= 07777;  }
void I04413() { emul8();  }
void D04414() { lac &= 010000;  }
void I04415() { emul8();  }
void I04416() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void P04417() { npc = 004426; inh = 0;  }
void I04420() { lac += core[004565];  }
void I04421() { emul8();  }
void I04422() { lac += core[004566];  }
void I04423() { emul8();  }
void I04424() { lac &= 010000;  }
void I04425() { npc = 004510; inh = 0;  }
void L04426() { emul8();  }
void I04427() { lac &= (010000|core[000017]);  }
void I04430() { lac &= (010000|core[000002]);  }
void I04431() { lac++;  }
void I04432() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04433() { npc = 004506; inh = 0;  }
void I04434() { lac &= 07777; lac++;  }
void I04435() { emul8();  }
void I04436() { emul8();  }
void I04437() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I04440() { npc = 004446; inh = 0;  }
void I04441() { lac += core[004550];  }
void I04442() { core[(df<<12)+core[2410]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2410]] = &emul8;  }
void I04443() { lac += core[004551];  }
void I04444() { core[(df<<12)+core[2411]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2411]] = &emul8;  }
void I04445() { npc = 004507; inh = 0;  }
void L04446() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1); lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04447() { lac += core[004567];  }
void I04450() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04451() { npc = 004465; inh = 0;  }
void I04452() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void L04453() { lac += core[004566];  }
void P04454() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04455() { npc = 004512; inh = 0;  }
void I04456() { lac += core[000100];  }
void I04457() { core[(df<<12)+core[2420]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2420]] = &emul8;  }
void I04460() { lac += core[004412];  }
void P04461() { core[(df<<12)+core[2419]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2419]] = &emul8;  }
void I04462() { npc = 004513; inh = 0;  }
void I04463() { if (++core[(df<<12)+core[2417]] == 010000) { core[(df<<12)+core[2417]] = 0; npc++; }; code[(df<<12)+core[2417]] = &emul8;  }
void I04464() { npc = 004514; inh = 0;  }
void L04465() { emul8();  }
void L04466() { emul8();  }
void I04467() { emul8();  }
void I04470() { emul8();  }
void I04471() { emul8();  }
void I04472() { emul8();  }
void I04473() { emul8();  }
void I04474() { emul8();  }
void I04475() { emul8();  }
void I04476() { if (++core[000057] == 010000) { core[000057] = 0; npc++; }; code[000057] = &emul8;  }
void I04477() { emul8();  }
void I04500() { npc = 004466; inh = 0;  }
void I04501() { lac += core[000057];  }
void I04502() { lac += core[000130];  }
void I04503() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04504() { npc = 004511; inh = 0;  }
void I04505() { if (++core[(df<<12)+core[24]] == 010000) { core[(df<<12)+core[24]] = 0; npc++; }; code[(df<<12)+core[24]] = &emul8;  }
void L04506() { if (++core[(df<<12)+core[24]] == 010000) { core[(df<<12)+core[24]] = 0; npc++; }; code[(df<<12)+core[24]] = &emul8;  }
void L04507() { if (++core[(df<<12)+core[24]] == 010000) { core[(df<<12)+core[24]] = 0; npc++; }; code[(df<<12)+core[24]] = &emul8;  }
void L04510() { if (++core[(df<<12)+core[24]] == 010000) { core[(df<<12)+core[24]] = 0; npc++; }; code[(df<<12)+core[24]] = &emul8;  }
void L04511() { if (++core[(df<<12)+core[24]] == 010000) { core[(df<<12)+core[24]] = 0; npc++; }; code[(df<<12)+core[24]] = &emul8;  }
void L04512() { if (++core[(df<<12)+core[24]] == 010000) { core[(df<<12)+core[24]] = 0; npc++; }; code[(df<<12)+core[24]] = &emul8;  }
void L04513() { if (++core[(df<<12)+core[24]] == 010000) { core[(df<<12)+core[24]] = 0; npc++; }; code[(df<<12)+core[24]] = &emul8;  }
void L04514() { emul8();  }
void I04515() { emul8();  }
void I04516() { core[(ib<<12)+core[96]] = 04517; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I04517() { lac &= (010000|core[(df<<12)+core[17]]);  }
void I04520() { emul8();  }
void I04521() { lac += core[004560];  }
void I04522() { core[004571] = 04523; npc = 004571+1; code[004571] = &emul8; inh = 0;  }
void I04523() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I04524() { npc = 004544; inh = 0;  }
void P04525() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04526() { lac += core[004566];  }
void I04527() { lac += core[000120];  }
void I04530() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I04531() { lac += core[004554];  }
void I04532() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void L04533() { lac += core[004555];  }
void I04534() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I04535() { if (++core[000057] == 010000) { core[000057] = 0; npc++; }; code[000057] = &emul8;  }
void I04536() { npc = 004533; inh = 0;  }
void I04537() { lac += core[004560];  }
void I04540() { core[004571] = 04541; npc = 004571+1; code[004571] = &emul8; inh = 0;  }
void I04541() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04542() { lac += core[000104];  }
void I04543() { lac += core[004556];  }
void L04544() { lac += core[004557];  }
void D04545() { core[000035] = lac & 07777; lac &= 010000; code[000035] = &emul8;  }
void D04546() { npc = (ib<<12)+core[2407]; inh = 0;  }
void P04547() { if (++core[004414] == 010000) { core[004414] = 0; npc++; }; code[004414] = &emul8;  }
void D04550() { emul8();  }
void L04551() { emul8();  }
void P04552() { lac += core[000153];  }
void P04553() { lac += core[000156];  }
void D04554() { lac &= (010000|core[(df<<12)+core[1]]);  }
void D04555() { if (++core[(df<<12)+core[2389]] == 010000) { core[(df<<12)+core[2389]] = 0; npc++; }; code[(df<<12)+core[2389]] = &emul8;  }
void D04556() { lac &= (010000|core[(df<<12)+core[112]]);  }
void D04557() { core[(ib<<12)+core[2319]] = 04560; npc = (ib<<12)+core[2319]+1; code[(ib<<12)+core[2319]] = &emul8; inh = 0;  }
void D04560() { core[000006] = lac & 07777; lac &= 010000; code[000006] = &emul8;  }
void P04561() { if (++core[(df<<12)+core[2353]] == 010000) { core[(df<<12)+core[2353]] = 0; npc++; }; code[(df<<12)+core[2353]] = &emul8;  }
void D04562() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void P04563() { emul8();  }
void P04564() { if (++core[(df<<12)+core[2348]] == 010000) { core[(df<<12)+core[2348]] = 0; npc++; }; code[(df<<12)+core[2348]] = &emul8;  }
void D04565() { lac &= (010000|core[000007]);  }
void D04566() { lac &= (010000|core[000002]);  }
void D04567() { core[000002] = 04570; npc = 000002+1; code[000002] = &emul8; inh = 0;  }
void D04570() { core[(ib<<12)+core[50]] = 04571; npc = (ib<<12)+core[50]+1; code[(ib<<12)+core[50]] = &emul8; inh = 0;  }
void P04571() { if (++core[004544] == 010000) { core[004544] = 0; npc++; }; code[004544] = &emul8;  }
void I04572() { core[000061] = lac & 07777; lac &= 010000; code[000061] = &emul8;  }
void I04573() { core[(ib<<12)+core[96]] = 04574; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I04574() { lac += core[(df<<12)+core[31]];  }
void I04575() { if (++core[000030] == 010000) { core[000030] = 0; npc++; }; code[000030] = &emul8;  }
void I04576() { lac += core[(df<<12)+core[24]];  }
void I04577() { npc = (ib<<12)+core[2425]; inh = 0;  }
void I04620() { lac += core[000045];  }
void I04621() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04622() { core[(ib<<12)+core[2516]] = 04623; npc = (ib<<12)+core[2516]+1; code[(ib<<12)+core[2516]] = &emul8; inh = 0;  }
void I04623() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I04624() { core[(ib<<12)+core[7]] = 04625; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I04625() { &emul8;  }
void I04626() { &emul8;  }
void I04627() { &emul8;  }
void I04630() { core[(ib<<12)+core[43]] = 04631; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I04631() { core[004725] = lac & 07777; lac &= 010000; code[004725] = &emul8;  }
void I04632() { core[(ib<<12)+core[7]] = 04633; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I04633() { &emul8;  }
void I04634() { &emul8;  }
void I04635() { &emul8;  }
void I04636() { &emul8;  }
void D04637() { &emul8;  }
void I04640() { &emul8;  }
void I04641() { &emul8;  }
void I04642() { &emul8;  }
void P04643() { &emul8;  }
void I04644() { &emul8;  }
void I04645() { &emul8;  }
void P04646() { &emul8;  }
void I04647() { &emul8;  }
void I04650() { &emul8;  }
void I04651() { &emul8;  }
void I04652() { &emul8;  }
void I04653() { &emul8;  }
void I04654() { &emul8;  }
void I04655() { &emul8;  }
void I04656() { &emul8;  }
void I04657() { &emul8;  }
void I04660() { &emul8;  }
void I04661() { &emul8;  }
void I04662() { lac += core[004725];  }
void I04663() { lac += core[000044];  }
void I04664() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I04665() { if (++core[000033] == 010000) { core[000033] = 0; npc++; }; code[000033] = &emul8;  }
void I04666() { npc = (ib<<12)+core[94]; inh = 0;  }
void I04667() { core[(ib<<12)+core[7]] = 04670; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I04670() { &emul8;  }
void I04671() { &emul8;  }
void I04672() { &emul8;  }
void I04673() { &emul8;  }
void I04674() { npc = (ib<<12)+core[94]; inh = 0;  }
void P04675() { npc = 004722; inh = 0;  }
void P04676() { npc = 004726; inh = 0;  }
void D04677() { lac &= (010000|core[000004]);  }
void I04700() { if (++core[004772] == 010000) { core[004772] = 0; npc++; }; code[004772] = &emul8;  }
void I04701() { lac += core[(df<<12)+core[2]];  }
void I04702() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I04703() { if (++core[000157] == 010000) { core[000157] = 0; npc++; }; code[000157] = &emul8;  }
void D04704() { npc = 000157; inh = 0;  }
void P04705() { lac &= (010000|core[000012]);  }
void D04706() { npc = (ib<<12)+core[44]; inh = 0;  }
void I04707() { lac &= (010000|core[004743]);  }
void D04710() { lac &= (010000|core[000007]);  }
void I04711() { if (++core[(df<<12)+core[118]] == 010000) { core[(df<<12)+core[118]] = 0; npc++; }; code[(df<<12)+core[118]] = &emul8;  }
void I04712() { npc = 004741; inh = 0;  }
void D04713() { lac &= (010000|core[000001]);  }
void I04714() { if (++core[(df<<12)+core[2501]] == 010000) { core[(df<<12)+core[2501]] = 0; npc++; }; code[(df<<12)+core[2501]] = &emul8;  }
void I04715() { if (++core[(df<<12)+core[29]] == 010000) { core[(df<<12)+core[29]] = 0; npc++; }; code[(df<<12)+core[29]] = &emul8;  }
void D04716() { lac &= (010000|core[000001]);  }
void I04717() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I04720() { lac &= (010000|core[000000]);  }
void D04721() { lac &= (010000|core[000002]);  }
void L04722() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void D04723() { lac &= (010000|core[000000]);  }
void P04724() { npc = 000163; inh = 0;  }
void D04725() { lac &= (010000|core[000000]);  }
void L04726() { lac &= (010000|core[000000]);  }
void I04727() { lac &= (010000|core[000000]);  }
void I04730() { lac &= (010000|core[000000]);  }
void I04731() { lac &= (010000|core[000000]);  }
void L04732() { core[(ib<<12)+core[7]] = 04733; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I04733() { &emul8;  }
void I04734() { &emul8;  }
void I04735() { &emul8;  }
void I04736() { &emul8;  }
void I04737() { &emul8;  }
void I04740() { &emul8;  }
void L04741() { &emul8;  }
void I04742() { &emul8;  }
void D04743() { &emul8;  }
void I04744() { &emul8;  }
void I04745() { &emul8;  }
void I04746() { &emul8;  }
void I04747() { &emul8;  }
void I04750() { &emul8;  }
void I04751() { &emul8;  }
void I04752() { &emul8;  }
void I04753() { npc = (ib<<12)+core[2540]; inh = 0;  }
void P04754() { npc = 000024; inh = 0;  }
void D04755() { lac &= (010000|core[000000]);  }
void I04756() { if (++core[(df<<12)+core[31]] == 010000) { core[(df<<12)+core[31]] = 0; npc++; }; code[(df<<12)+core[31]] = &emul8;  }
void I04757() { lac += core[(df<<12)+core[2467]];  }
void D04760() { emul8();  }
void I04761() { core[004704] = lac & 07777; lac &= 010000; code[004704] = &emul8;  }
void I04762() { core[(ib<<12)+core[28]] = 04763; npc = (ib<<12)+core[28]+1; code[(ib<<12)+core[28]] = &emul8; inh = 0;  }
void I04763() { emul8();  }
void I04764() { core[004706] = lac & 07777; lac &= 010000; code[004706] = &emul8;  }
void I04765() { npc = (ib<<12)+core[44]; inh = 0;  }
void D04766() { lac &= (010000|core[000000]);  }
void I04767() { if (++core[(df<<12)+core[31]] == 010000) { core[(df<<12)+core[31]] = 0; npc++; }; code[(df<<12)+core[31]] = &emul8;  }
void I04770() { lac += core[(df<<12)+core[2470]];  }
void D04771() { lac &= (010000|core[000000]);  }
void D04772() { if (++core[(df<<12)+core[23]] == 010000) { core[(df<<12)+core[23]] = 0; npc++; }; code[(df<<12)+core[23]] = &emul8;  }
void I04773() { if (++core[004723] == 010000) { core[004723] = 0; npc++; }; code[004723] = &emul8;  }
void D04774() { emul8();  }
void I04775() { core[(df<<12)+core[23]] = lac & 07777; lac &= 010000; code[(df<<12)+core[23]] = &emul8;  }
void I04776() { lac ^= 07777; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I05000() { lac += core[000045];  }
void I05001() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05002() { core[005163] = 05003; npc = 005163+1; code[005163] = &emul8; inh = 0;  }
void I05003() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I05004() { core[(ib<<12)+core[7]] = 05005; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05005() { &emul8;  }
void I05006() { &emul8;  }
void I05007() { &emul8;  }
void I05010() { lac += core[000045];  }
void I05011() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05012() { npc = 005021; inh = 0;  }
void P05013() { core[(ib<<12)+core[7]] = 05014; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05014() { &emul8;  }
void I05015() { &emul8;  }
void I05016() { &emul8;  }
void I05017() { &emul8;  }
void I05020() { lac &= 010000; lac ^= 07777;  }
void L05021() { core[005162] = lac & 07777; lac &= 010000; code[005162] = &emul8;  }
void I05022() { npc = (ib<<12)+core[2579]; inh = 0;  }
void P05023() { core[(ib<<12)+core[2650]] = 05024; npc = (ib<<12)+core[2650]+1; code[(ib<<12)+core[2650]] = &emul8; inh = 0;  }
void L05024() { if (++core[005162] == 010000) { core[005162] = 0; npc++; }; code[005162] = &emul8;  }
void I05025() { npc = (ib<<12)+core[2588]; inh = 0;  }
void I05026() { core[(ib<<12)+core[7]] = 05027; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05027() { &emul8;  }
void I05030() { &emul8;  }
void I05031() { &emul8;  }
void I05032() { &emul8;  }
void I05033() { npc = (ib<<12)+core[2588]; inh = 0;  }
void P05034() { npc = 005102; inh = 0;  }
void P05035() { npc = 005122; inh = 0;  }
void D05036() { npc = 005116; inh = 0;  }
void P05037() { core[(ib<<12)+core[2638]] = 05040; npc = (ib<<12)+core[2638]+1; code[(ib<<12)+core[2638]] = &emul8; inh = 0;  }
void I05040() { lac += core[000045];  }
void I05041() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I05042() { core[(ib<<12)+core[118]] = 05043; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I05043() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05044() { core[(ib<<12)+core[41]] = 05045; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I05045() { core[(ib<<12)+core[7]] = 05046; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05046() { &emul8;  }
void I05047() { &emul8;  }
void I05050() { &emul8;  }
void I05051() { lac += core[000045];  }
void I05052() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I05053() { npc = (ib<<12)+core[94]; inh = 0;  }
void I05054() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I05055() { npc = 005064; inh = 0;  }
void I05056() { core[(ib<<12)+core[7]] = 05057; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05057() { &emul8;  }
void I05060() { &emul8;  }
void I05061() { &emul8;  }
void I05062() { &emul8;  }
void I05063() { lac &= 010000; lac ^= 07777;  }
void L05064() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I05065() { lac += core[000005];  }
void I05066() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I05067() { lac ^= 07777;  }
void I05070() { lac += core[(df<<12)+core[2670]];  }
void I05071() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I05072() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I05073() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I05074() { lac++;  }
void I05075() { core[(df<<12)+core[2670]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2670]] = &emul8;  }
void I05076() { core[(ib<<12)+core[7]] = 05077; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05077() { &emul8;  }
void I05100() { &emul8;  }
void D05101() { &emul8;  }
void L05102() { &emul8;  }
void I05103() { &emul8;  }
void I05104() { &emul8;  }
void I05105() { &emul8;  }
void I05106() { &emul8;  }
void D05107() { &emul8;  }
void I05110() { &emul8;  }
void I05111() { &emul8;  }
void I05112() { &emul8;  }
void I05113() { &emul8;  }
void I05114() { &emul8;  }
void I05115() { &emul8;  }
void P05116() { &emul8;  }
void I05117() { &emul8;  }
void I05120() { &emul8;  }
void I05121() { &emul8;  }
void L05122() { &emul8;  }
void I05123() { &emul8;  }
void I05124() { &emul8;  }
void I05125() { npc = (ib<<12)+core[2588]; inh = 0;  }
void P05126() { lac &= (010000|core[000000]);  }
void I05127() { core[(df<<12)+core[2687]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2687]] = &emul8;  }
void I05130() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000; hlt = 1;  }
void D05131() { emul8();  }
void P05132() { core[000000] = 05133; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I05133() { core[000100] = 05134; npc = 000100+1; code[000100] = &emul8; inh = 0;  }
void D05134() { emul8();  }
void P05135() { if (++core[(df<<12)+core[79]] == 010000) { core[(df<<12)+core[79]] = 0; npc++; }; code[(df<<12)+core[79]] = &emul8;  }
void I05136() { lac &= (010000|core[005107]);  }
void D05137() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I05140() { core[000113] = 05141; npc = 000113+1; code[000113] = &emul8; inh = 0;  }
void I05141() { lac &= 010000; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void D05142() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I05143() { if (++core[(df<<12)+core[93]] == 010000) { core[(df<<12)+core[93]] = 0; npc++; }; code[(df<<12)+core[93]] = &emul8;  }
void I05144() { core[005101] = lac & 07777; lac &= 010000; code[005101] = &emul8;  }
void D05145() { emul8();  }
void P05146() { core[(ib<<12)+core[2662]] = 05147; npc = (ib<<12)+core[2662]+1; code[(ib<<12)+core[2662]] = &emul8; inh = 0;  }
void I05147() { lac &= (010000|core[(df<<12)+core[2681]]);  }
void D05150() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I05151() { if (++core[005036] == 010000) { core[005036] = 0; npc++; }; code[005036] = &emul8;  }
void I05152() { core[005104] = 05153; npc = 005104+1; code[005104] = &emul8; inh = 0;  }
void D05153() { emul8();  }
void I05154() { core[(ib<<12)+core[100]] = 05155; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I05155() { lac += core[(df<<12)+core[2653]];  }
void P05156() { core[(ib<<12)+core[2646]] = 05157; npc = (ib<<12)+core[2646]+1; code[(ib<<12)+core[2646]] = &emul8; inh = 0;  }
void D05157() { lac &= (010000|core[000000]);  }
void I05160() { if (++core[(df<<12)+core[2571]] == 010000) { core[(df<<12)+core[2571]] = 0; npc++; }; code[(df<<12)+core[2571]] = &emul8;  }
void I05161() { if (++core[000014] == 010000) core[000014] = 0000;core[(ib<<12)+core[000014]] = 05162; npc = (ib<<12)+core[000014]+1; code[(ib<<12)+core[000014]] = &emul8; inh = 0;  }
void D05162() { lac &= (010000|core[000000]);  }
void S05163() { lac &= (010000|core[000000]);  }
void I05164() { core[(ib<<12)+core[41]] = 05165; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I05165() { lac &= 010000; lac ^= 07777;  }
void I05166() { npc = (ib<<12)+core[2675]; inh = 0;  }
void D05200() { core[(ib<<12)+core[7]] = 05201; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05201() { &emul8;  }
void I05202() { &emul8;  }
void I05203() { &emul8;  }
void I05204() { &emul8;  }
void I05205() { lac += core[000045];  }
void I05206() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I05207() { npc = 005215; inh = 0;  }
void I05210() { lac += core[000045];  }
void I05211() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I05212() { npc = (ib<<12)+core[94]; inh = 0;  }
void I05213() { core[(ib<<12)+core[41]] = 05214; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I05214() { lac ^= 07777;  }
void L05215() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I05216() { core[(ib<<12)+core[7]] = 05217; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05217() { &emul8;  }
void I05220() { &emul8;  }
void I05221() { &emul8;  }
void I05222() { core[(ib<<12)+core[43]] = 05223; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I05223() { core[(ib<<12)+core[7]] = 05224; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05224() { &emul8;  }
void I05225() { &emul8;  }
void I05226() { &emul8;  }
void I05227() { &emul8;  }
void I05230() { &emul8;  }
void I05231() { &emul8;  }
void I05232() { &emul8;  }
void I05233() { &emul8;  }
void I05234() { lac += core[000045];  }
void D05235() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05236() { npc = 005245; inh = 0;  }
void I05237() { core[(ib<<12)+core[7]] = 05240; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05240() { &emul8;  }
void I05241() { &emul8;  }
void I05242() { lac += core[000033];  }
void I05243() { lac ^= 07777;  }
void I05244() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void L05245() { core[(ib<<12)+core[7]] = 05246; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05246() { &emul8;  }
void I05247() { &emul8;  }
void I05250() { &emul8;  }
void I05251() { lac += core[000045];  }
void I05252() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05253() { npc = 005261; inh = 0;  }
void I05254() { core[(ib<<12)+core[7]] = 05255; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05255() { &emul8;  }
void I05256() { &emul8;  }
void I05257() { &emul8;  }
void I05260() { &emul8;  }
void L05261() { core[(ib<<12)+core[7]] = 05262; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I05262() { &emul8;  }
void I05263() { &emul8;  }
void I05264() { &emul8;  }
void I05265() { &emul8;  }
void I05266() { &emul8;  }
void I05267() { &emul8;  }
void I05270() { &emul8;  }
void I05271() { &emul8;  }
void I05272() { &emul8;  }
void I05273() { &emul8;  }
void I05274() { &emul8;  }
void I05275() { &emul8;  }
void I05276() { &emul8;  }
void I05277() { &emul8;  }
void I05300() { &emul8;  }
void I05301() { &emul8;  }
void L05302() { if (++core[000033] == 010000) { core[000033] = 0; npc++; }; code[000033] = &emul8;  }
void I05303() { npc = (ib<<12)+core[94]; inh = 0;  }
void I05304() { core[(ib<<12)+core[41]] = 05305; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I05305() { npc = (ib<<12)+core[94]; inh = 0;  }
void D05306() { lac &= (010000|core[000003]);  }
void I05307() { core[000110] = lac & 07777; lac &= 010000; code[000110] = &emul8;  }
void I05310() { core[(df<<12)+core[2798]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2798]] = &emul8;  }
void I05311() { core[005235] = lac & 07777; lac &= 010000; code[005235] = &emul8;  }
void D05312() { lac &= (010000|core[000002]);  }
void I05313() { core[000110] = lac & 07777; lac &= 010000; code[000110] = &emul8;  }
void I05314() { core[(df<<12)+core[2798]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2798]] = &emul8;  }
void I05315() { core[005235] = lac & 07777; lac &= 010000; code[005235] = &emul8;  }
void D05316() { lac &= (010000|core[000001]);  }
void I05317() { core[000110] = lac & 07777; lac &= 010000; code[000110] = &emul8;  }
void I05320() { core[(df<<12)+core[2798]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2798]] = &emul8;  }
void I05321() { core[005235] = lac & 07777; lac &= 010000; code[005235] = &emul8;  }
void D05322() { lac &= (010000|core[000000]);  }
void I05323() { lac &= (010000|core[000000]);  }
void I05324() { lac &= (010000|core[000000]);  }
void L05325() { lac &= (010000|core[000000]);  }
void D05326() { lac &= (010000|core[000000]);  }
void I05327() { lac &= (010000|core[000000]);  }
void I05330() { lac &= (010000|core[000000]);  }
void I05331() { lac &= (010000|core[000000]);  }
void I05332() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void I05333() { if (++core[(df<<12)+core[1]] == 010000) { core[(df<<12)+core[1]] = 0; npc++; }; code[(df<<12)+core[1]] = &emul8;  }
void I05334() { lac++; lac = (lac<<1) + ((lac>>12)&1); lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I05335() { lac += core[000042];  }
void P05336() { emul8();  }
void I05337() { npc = (ib<<12)+core[52]; inh = 0;  }
void I05340() { npc = (ib<<12)+core[76]; inh = 0;  }
void I05341() { emul8();  }
void D05342() { emul8();  }
void I05343() { if (++core[(df<<12)+core[25]] == 010000) { core[(df<<12)+core[25]] = 0; npc++; }; code[(df<<12)+core[25]] = &emul8;  }
void I05344() { npc = 005361; inh = 0;  }
void I05345() { core[(ib<<12)+core[2782]] = 05346; npc = (ib<<12)+core[2782]+1; code[(ib<<12)+core[2782]] = &emul8; inh = 0;  }
void D05346() { lac &= (010000|core[000000]);  }
void I05347() { npc = 005325; inh = 0;  }
void I05350() { if (++core[000014] == 010000) core[000014] = 0000;lac &= (010000|core[(df<<12)+core[000014]]);  }
void I05351() { core[000167] = lac & 07777; lac &= 010000; code[000167] = &emul8;  }
void S05400() { lac &= (010000|core[000000]);  }
void I05401() { core[005534] = lac & 07777; lac &= 010000; code[005534] = &emul8;  }
void I05402() { lac += core[000052];  }
void D05403() { core[(ib<<12)+core[111]] = 05404; npc = (ib<<12)+core[111]+1; code[(ib<<12)+core[111]] = &emul8; inh = 0;  }
void I05404() { lac &= (010000|core[000122]);  }
void I05405() { core[000032] = lac & 07777; lac &= 010000; code[000032] = &emul8;  }
void I05406() { lac += core[000032];  }
void I05407() { lac ^= 07777; lac++;  }
void I05410() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I05411() { lac += core[005526];  }
void I05412() { core[005535] = lac & 07777; lac &= 010000; code[005535] = &emul8;  }
void I05413() { lac += core[000052];  }
void I05414() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I05415() { npc = 005441; inh = 0;  }
void I05416() { lac &= (010000|core[000122]);  }
void I05417() { core[005533] = lac & 07777; lac &= 010000; code[005533] = &emul8;  }
void I05420() { lac += core[005535];  }
void I05421() { lac += core[005533];  }
void I05422() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I05423() { npc = 005430; inh = 0;  }
void I05424() { lac &= 010000; lac ^= 07777;  }
void I05425() { lac += core[000032];  }
void I05426() { core[005533] = lac & 07777; lac &= 010000; code[005533] = &emul8;  }
void I05427() { lac ^= 07777;  }
void L05430() { lac += core[000033];  }
void I05431() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I05432() { lac &= 010000;  }
void I05433() { lac += core[000032];  }
void I05434() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I05435() { npc = 005463; inh = 0;  }
void I05436() { lac += core[005526];  }
void I05437() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I05440() { lac &= 010000;  }
void L05441() { lac += core[005527];  }
void I05442() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I05443() { lac += core[(df<<12)+core[2905]];  }
void I05444() { lac += core[000071];  }
void I05445() { core[005536] = lac & 07777; lac &= 010000; code[005536] = &emul8;  }
void I05446() { lac += core[000071];  }
void I05447() { lac ^= 07777; lac++;  }
void I05450() { core[000071] = lac & 07777; lac &= 010000; code[000071] = &emul8;  }
void I05451() { lac += core[005525];  }
void L05452() { if (++core[(df<<12)+core[2910]] == 010000) { core[(df<<12)+core[2910]] = 0; npc++; }; code[(df<<12)+core[2910]] = &emul8;  }
void I05453() { lac += core[(df<<12)+core[2910]];  }
void I05454() { lac += core[005530];  }
void I05455() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05456() { npc = 005465; inh = 0;  }
void I05457() { core[(df<<12)+core[2910]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2910]] = &emul8;  }
void I05460() { if (++core[000071] == 010000) { core[000071] = 0; npc++; }; code[000071] = &emul8;  }
void L05461() { npc = 005521; inh = 0;  }
void I05462() { if (++core[(df<<12)+core[2910]] == 010000) { core[(df<<12)+core[2910]] = 0; npc++; }; code[(df<<12)+core[2910]] = &emul8;  }
void L05463() { if (++core[000033] == 010000) { core[000033] = 0; npc++; }; code[000033] = &emul8;  }
void I05464() { lac &= 010000;  }
void L05465() { lac += core[000052];  }
void I05466() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05467() { npc = 005556; inh = 0;  }
void I05470() { lac += core[005535];  }
void D05471() { lac += core[000033];  }
void I05472() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp;  }
void I05473() { npc = 005555; inh = 0;  }
void I05474() { lac += core[005533];  }
void I05475() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I05476() { lac &= 010000;  }
void I05477() { lac ^= 07777; lac++;  }
void I05500() { lac += core[000033];  }
void I05501() { lac ^= 07777; lac++;  }
void I05502() { core[000032] = lac & 07777; lac &= 010000; code[000032] = &emul8;  }
void L05503() { lac += core[000033];  }
void I05504() { lac += core[000032];  }
void I05505() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05506() { npc = 005543; inh = 0;  }
void I05507() { lac += core[000032];  }
void I05510() { lac++;  }
void I05511() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05512() { lac += core[000105];  }
void L05513() { core[005536] = 05514; npc = 005536+1; code[005536] = &emul8; inh = 0;  }
void I05514() { if (++core[000032] == 010000) { core[000032] = 0; npc++; }; code[000032] = &emul8;  }
void I05515() { npc = 005503; inh = 0;  }
void I05516() { lac += core[000102];  }
void I05517() { core[(ib<<12)+core[105]] = 05520; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I05520() { npc = 005503; inh = 0;  }
void L05521() { lac ^= 07777;  }
void I05522() { lac += core[005536];  }
void I05523() { core[005536] = lac & 07777; lac &= 010000; code[005536] = &emul8;  }
void I05524() { npc = 005452; inh = 0;  }
void D05525() { lac &= (010000|core[000005]);  }
void D05526() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void D05527() { lac &= (010000|core[000007]);  }
void D05530() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P05531() { emul8();  }
void P05532() { emul8();  }
void D05533() { lac &= (010000|core[000000]);  }
void D05534() { lac &= (010000|core[000000]);  }
void D05535() { lac &= (010000|core[000000]);  }
void S05536() { lac &= (010000|core[000000]);  }
void I05537() { core[(ib<<12)+core[2906]] = 05540; npc = (ib<<12)+core[2906]+1; code[(ib<<12)+core[2906]] = &emul8; inh = 0;  }
void I05540() { if (++core[005535] == 010000) { core[005535] = 0; npc++; }; code[005535] = &emul8;  }
void D05541() { npc = (ib<<12)+core[2910]; inh = 0;  }
void I05542() { npc = (ib<<12)+core[2816]; inh = 0;  }
void L05543() { lac ^= 07777;  }
void I05544() { lac += core[000033];  }
void I05545() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I05546() { if (++core[005534] == 010000) { core[005534] = 0; npc++; }; code[005534] = &emul8;  }
void I05547() { npc = 005553; inh = 0;  }
void I05550() { lac ^= 07777;  }
void I05551() { core[005534] = lac & 07777; lac &= 010000; code[005534] = &emul8;  }
void I05552() { npc = 005513; inh = 0;  }
void L05553() { if (++core[000014] == 010000) core[000014] = 0000;lac += core[(df<<12)+core[000014]];  }
void I05554() { npc = 005513; inh = 0;  }
void L05555() { lac &= 010000;  }
void L05556() { core[(ib<<12)+core[2906]] = 05557; npc = (ib<<12)+core[2906]+1; code[(ib<<12)+core[2906]] = &emul8; inh = 0;  }
void I05557() { lac += core[000102];  }
void I05560() { core[(ib<<12)+core[105]] = 05561; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I05561() { if (++core[005400] == 010000) { core[005400] = 0; npc++; }; code[005400] = &emul8;  }
void L05562() { if (++core[000014] == 010000) core[000014] = 0000;lac += core[(df<<12)+core[000014]];  }
void L05563() { core[005536] = 05564; npc = 005536+1; code[005536] = &emul8; inh = 0;  }
void I05564() { if (++core[005534] == 010000) { core[005534] = 0; npc++; }; code[005534] = &emul8;  }
void I05565() { npc = 005562; inh = 0;  }
void I05566() { lac ^= 07777;  }
void I05567() { core[005534] = lac & 07777; lac &= 010000; code[005534] = &emul8;  }
void I05570() { npc = 005563; inh = 0;  }
void S05571() { lac &= (010000|core[000000]);  }
void I05572() { lac += core[000045];  }
void I05573() { core[000050] = lac & 07777; lac &= 010000; code[000050] = &emul8;  }
void I05574() { lac += core[000045];  }
void I05575() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void L05576() { core[(ib<<12)+core[41]] = 05577; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I05577() { npc = (ib<<12)+core[2937]; inh = 0;  }
void S05600() { lac &= (010000|core[000000]);  }
void I05601() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I05602() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I05603() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I05604() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I05605() { core[005714] = lac & 07777; lac &= 010000; code[005714] = &emul8;  }
void I05606() { core[000050] = lac & 07777; lac &= 010000; code[000050] = &emul8;  }
void I05607() { lac += core[000066];  }
void I05610() { lac += core[005664];  }
void I05611() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I05612() { npc = 005620; inh = 0;  }
void I05613() { lac += core[000111];  }
void I05614() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05615() { npc = 005621; inh = 0;  }
void I05616() { lac ^= 07777;  }
void I05617() { core[000050] = lac & 07777; lac &= 010000; code[000050] = &emul8;  }
void L05620() { core[(ib<<12)+core[2998]] = 05621; npc = (ib<<12)+core[2998]+1; code[(ib<<12)+core[2998]] = &emul8; inh = 0;  }
void L05621() { lac += core[000066];  }
void I05622() { lac += core[005665];  }
void I05623() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05624() { npc = 005620; inh = 0;  }
void I05625() { core[005627] = 05626; npc = 005627+1; code[005627] = &emul8; inh = 0;  }
void I05626() { npc = (ib<<12)+core[2944]; inh = 0;  }
void S05627() { lac &= (010000|core[000000]);  }
void L05630() { lac += core[000066];  }
void I05631() { lac += core[005662];  }
void I05632() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05633() { npc = (ib<<12)+core[2967]; inh = 0;  }
void I05634() { core[(ib<<12)+core[113]] = 05635; npc = (ib<<12)+core[113]+1; code[(ib<<12)+core[113]] = &emul8; inh = 0;  }
void I05635() { npc = (ib<<12)+core[2967]; inh = 0;  }
void I05636() { npc = 005647; inh = 0;  }
void I05637() { lac += core[000054];  }
void L05640() { core[005713] = lac & 07777; lac &= 010000; code[005713] = &emul8;  }
void I05641() { core[005667] = 05642; npc = 005667+1; code[005667] = &emul8; inh = 0;  }
void I05642() { if (++core[005714] == 010000) { core[005714] = 0; npc++; }; code[005714] = &emul8;  }
void I05643() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05644() { core[(ib<<12)+core[118]] = 05645; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I05645() { core[(ib<<12)+core[2998]] = 05646; npc = (ib<<12)+core[2998]+1; code[(ib<<12)+core[2998]] = &emul8; inh = 0;  }
void I05646() { npc = 005630; inh = 0;  }
void L05647() { lac += core[000066];  }
void I05650() { lac += core[000112];  }
void I05651() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I05652() { npc = (ib<<12)+core[2967]; inh = 0;  }
void I05653() { lac += core[000066];  }
void I05654() { lac += core[005663];  }
void I05655() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I05656() { npc = (ib<<12)+core[2967]; inh = 0;  }
void I05657() { lac += core[000066];  }
void I05660() { lac &= (010000|core[000122]);  }
void I05661() { npc = 005640; inh = 0;  }
void D05662() { emul8();  }
void D05663() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac |= swr; hlt = 1;  }
void D05664() { emul8();  }
void D05665() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp;  }
void P05666() { lac &= (010000|core[(df<<12)+core[3054]]);  }
void S05667() { lac &= (010000|core[000000]);  }
void I05670() { lac += core[000047];  }
void I05671() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I05672() { lac += core[000046];  }
void I05673() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I05674() { lac += core[000045];  }
void I05675() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I05676() { core[005712] = lac & 07777; lac &= 010000; code[005712] = &emul8;  }
void I05677() { core[005715] = 05700; npc = 005715+1; code[005715] = &emul8; inh = 0;  }
void I05700() { core[005715] = 05701; npc = 005715+1; code[005715] = &emul8; inh = 0;  }
void I05701() { core[005733] = 05702; npc = 005733+1; code[005733] = &emul8; inh = 0;  }
void I05702() { core[005715] = 05703; npc = 005715+1; code[005715] = &emul8; inh = 0;  }
void I05703() { lac += core[005713];  }
void I05704() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I05705() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I05706() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I05707() { core[005733] = 05710; npc = 005733+1; code[005733] = &emul8; inh = 0;  }
void I05710() { lac += core[005712];  }
void I05711() { npc = (ib<<12)+core[2999]; inh = 0;  }
void D05712() { lac &= (010000|core[000000]);  }
void D05713() { lac &= (010000|core[000000]);  }
void D05714() { lac &= (010000|core[000000]);  }
void S05715() { lac &= (010000|core[000000]);  }
void I05716() { lac += core[000047];  }
void I05717() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I05720() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I05721() { lac += core[000046];  }
void I05722() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05723() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I05724() { lac += core[000045];  }
void I05725() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05726() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I05727() { lac += core[005712];  }
void I05730() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05731() { core[005712] = lac & 07777; lac &= 010000; code[005712] = &emul8;  }
void I05732() { npc = (ib<<12)+core[3021]; inh = 0;  }
void S05733() { lac &= (010000|core[000000]);  }
void I05734() { lac &= 010000; lac &= 07777;  }
void I05735() { lac += core[000047];  }
void I05736() { lac += core[000043];  }
void I05737() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I05740() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05741() { lac += core[000046];  }
void I05742() { lac += core[000042];  }
void I05743() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I05744() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05745() { lac += core[000045];  }
void I05746() { lac += core[000041];  }
void I05747() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I05750() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05751() { lac += core[005712];  }
void I05752() { core[005712] = lac & 07777; lac &= 010000; code[005712] = &emul8;  }
void I05753() { npc = (ib<<12)+core[3035]; inh = 0;  }
void S05754() { lac &= (010000|core[000000]);  }
void I05755() { lac &= 010000; lac &= 07777;  }
void P05756() { lac += core[000041];  }
void I05757() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I05760() { lac &= 07777; lac ^= 010000;  }
void I05761() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I05762() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I05763() { lac += core[000042];  }
void I05764() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I05765() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I05766() { lac += core[000043];  }
void I05767() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I05770() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I05771() { if (++core[000040] == 010000) { core[000040] = 0; npc++; }; code[000040] = &emul8;  }
void I05772() { npc = (ib<<12)+core[3052]; inh = 0;  }
void I05773() { npc = (ib<<12)+core[3052]; inh = 0;  }
void S06000() { lac &= (010000|core[000000]);  }
void I06001() { lac += core[006135];  }
void I06002() { core[(ib<<12)+core[105]] = 06003; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I06003() { lac += core[000045];  }
void I06004() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06005() { lac += core[006134];  }
void I06006() { lac += core[006136];  }
void I06007() { core[(ib<<12)+core[105]] = 06010; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I06010() { core[(ib<<12)+core[3179]] = 06011; npc = (ib<<12)+core[3179]+1; code[(ib<<12)+core[3179]] = &emul8; inh = 0;  }
void L06011() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I06012() { lac += core[000044];  }
void I06013() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06014() { npc = 006027; inh = 0;  }
void I06015() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I06016() { lac += core[006141];  }
void I06017() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06020() { npc = 006034; inh = 0;  }
void I06021() { core[(ib<<12)+core[7]] = 06022; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I06022() { &emul8;  }
void I06023() { &emul8;  }
void I06024() { lac++;  }
void L06025() { lac += core[000033];  }
void I06026() { npc = 006011; inh = 0;  }
void L06027() { core[(ib<<12)+core[7]] = 06030; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I06030() { &emul8;  }
void I06031() { &emul8;  }
void I06032() { lac ^= 07777;  }
void I06033() { npc = 006025; inh = 0;  }
void L06034() { core[(df<<12)+core[3173]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3173]] = &emul8;  }
void I06035() { core[(df<<12)+core[3174]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3174]] = &emul8;  }
void I06036() { lac += core[006150];  }
void I06037() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I06040() { lac += core[000044];  }
void I06041() { lac &= 07777; lac ^= 07777;  }
void I06042() { core[006154] = lac & 07777; lac &= 010000; code[006154] = &emul8;  }
void I06043() { lac += core[006143];  }
void I06044() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void L06045() { core[(ib<<12)+core[87]] = 06046; npc = (ib<<12)+core[87]+1; code[(ib<<12)+core[87]] = &emul8; inh = 0;  }
void I06046() { if (++core[006154] == 010000) { core[006154] = 0; npc++; }; code[006154] = &emul8;  }
void I06047() { npc = 006045; inh = 0;  }
void I06050() { lac += core[(df<<12)+core[3174]];  }
void I06051() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06052() { npc = 006070; inh = 0;  }
void I06053() { lac += core[006142];  }
void I06054() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D06055() { npc = 006064; inh = 0;  }
void I06056() { lac++;  }
void I06057() { if (++core[000014] == 010000) core[000014] = 0000;core[(df<<12)+core[000014]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000014]] = &emul8;  }
void I06060() { if (++core[000044] == 010000) { core[000044] = 0; npc++; }; code[000044] = &emul8;  }
void I06061() { lac += core[006142];  }
void I06062() { if (++core[000033] == 010000) { core[000033] = 0; npc++; }; code[000033] = &emul8;  }
void I06063() {  }
void L06064() { lac += core[(df<<12)+core[3174]];  }
void I06065() { if (++core[000033] == 010000) { core[000033] = 0; npc++; }; code[000033] = &emul8;  }
void I06066() {  }
void P06067() { skp = 0; skp = !skp; npc += skp;  }
void L06070() { core[(ib<<12)+core[3175]] = 06071; npc = (ib<<12)+core[3175]+1; code[(ib<<12)+core[3175]] = &emul8; inh = 0;  }
void I06071() { if (++core[000014] == 010000) core[000014] = 0000;core[(df<<12)+core[000014]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000014]] = &emul8;  }
void I06072() { if (++core[000044] == 010000) { core[000044] = 0; npc++; }; code[000044] = &emul8;  }
void I06073() { npc = 006070; inh = 0;  }
void I06074() { lac += core[006150];  }
void D06075() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I06076() { lac += core[006143];  }
void I06077() { core[(ib<<12)+core[3177]] = 06100; npc = (ib<<12)+core[3177]+1; code[(ib<<12)+core[3177]] = &emul8; inh = 0;  }
void I06100() { npc = (ib<<12)+core[3072]; inh = 0;  }
void I06101() { lac += core[006133];  }
void I06102() { core[(ib<<12)+core[105]] = 06103; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I06103() { lac += core[000033];  }
void I06104() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void D06105() { lac ^= 07777; lac++;  }
void I06106() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06107() { lac += core[000033];  }
void I06110() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06111() { lac += core[000111];  }
void P06112() { lac += core[006136];  }
void P06113() { core[(ib<<12)+core[105]] = 06114; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I06114() { lac += core[000045];  }
void L06115() { if (++core[000044] == 010000) { core[000044] = 0; npc++; }; code[000044] = &emul8;  }
void I06116() { lac += core[006137];  }
void I06117() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I06120() { npc = 006115; inh = 0;  }
void I06121() { lac += core[006140];  }
void I06122() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06123() { lac ^= 07777;  }
void I06124() { lac += core[000044];  }
void I06125() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I06126() { core[006154] = 06127; npc = 006154+1; code[006154] = &emul8; inh = 0;  }
void I06127() { lac += core[000045];  }
void I06130() { core[(ib<<12)+core[3162]] = 06131; npc = (ib<<12)+core[3162]+1; code[(ib<<12)+core[3162]] = &emul8; inh = 0;  }
void I06131() { npc = (ib<<12)+core[3072]; inh = 0;  }
void P06132() { if (++core[(df<<12)+core[34]] == 010000) { core[(df<<12)+core[34]] = 0; npc++; }; code[(df<<12)+core[34]] = &emul8;  }
void D06133() { lac &= (010000|core[006105]);  }
void D06134() { emul8();  }
void D06135() { lac &= (010000|core[006075]);  }
void D06136() { lac &= (010000|core[006055]);  }
void D06137() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void D06140() { lac &= (010000|core[000144]);  }
void D06141() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void D06142() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void D06143() { emul8();  }
void P06144() { emul8();  }
void P06145() { npc = (ib<<12)+core[3147]; inh = 0;  }
void P06146() { npc = (ib<<12)+core[3146]; inh = 0;  }
void P06147() { npc = (ib<<12)+core[3127]; inh = 0;  }
void D06150() { emul8();  }
void P06151() { npc = (ib<<12)+core[0]; inh = 0;  }
void P06152() { emul8();  }
void P06153() { npc = (ib<<12)+core[121]; inh = 0;  }
void S06154() { lac &= (010000|core[000000]);  }
void I06155() { lac += core[000113];  }
void L06156() { core[(ib<<12)+core[105]] = 06157; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I06157() { npc = (ib<<12)+core[3180]; inh = 0;  }
void S06200() { lac &= (010000|core[000000]);  }
void I06201() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void L06202() { core[(ib<<12)+core[3270]] = 06203; npc = (ib<<12)+core[3270]+1; code[(ib<<12)+core[3270]] = &emul8; inh = 0;  }
void I06203() { lac += core[000066];  }
void I06204() { lac += core[000114];  }
void I06205() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06206() { npc = 006202; inh = 0;  }
void I06207() { core[(ib<<12)+core[3266]] = 06210; npc = (ib<<12)+core[3266]+1; code[(ib<<12)+core[3266]] = &emul8; inh = 0;  }
void I06210() { lac += core[000066];  }
void P06211() { lac += core[000115];  }
void D06212() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06213() { npc = 006221; inh = 0;  }
void I06214() { core[(ib<<12)+core[3270]] = 06215; npc = (ib<<12)+core[3270]+1; code[(ib<<12)+core[3270]] = &emul8; inh = 0;  }
void I06215() { core[(df<<12)+core[3269]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3269]] = &emul8;  }
void I06216() { core[(ib<<12)+core[3267]] = 06217; npc = (ib<<12)+core[3267]+1; code[(ib<<12)+core[3267]] = &emul8; inh = 0;  }
void I06217() { lac += core[(df<<12)+core[3269]];  }
void I06220() { lac ^= 07777; lac++;  }
void L06221() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I06222() { lac += core[006310];  }
void I06223() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06224() { core[(ib<<12)+core[3268]] = 06225; npc = (ib<<12)+core[3268]+1; code[(ib<<12)+core[3268]] = &emul8; inh = 0;  }
void I06225() { core[(ib<<12)+core[3271]] = 06226; npc = (ib<<12)+core[3271]+1; code[(ib<<12)+core[3271]] = &emul8; inh = 0;  }
void I06226() { core[(ib<<12)+core[7]] = 06227; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void P06227() { &emul8;  }
void I06230() { &emul8;  }
void I06231() { lac += core[000066];  }
void I06232() { lac += core[006301];  }
void I06233() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06234() { npc = 006246; inh = 0;  }
void I06235() { core[(ib<<12)+core[3270]] = 06236; npc = (ib<<12)+core[3270]+1; code[(ib<<12)+core[3270]] = &emul8; inh = 0;  }
void I06236() { core[(ib<<12)+core[3266]] = 06237; npc = (ib<<12)+core[3266]+1; code[(ib<<12)+core[3266]] = &emul8; inh = 0;  }
void I06237() { core[(ib<<12)+core[3268]] = 06240; npc = (ib<<12)+core[3268]+1; code[(ib<<12)+core[3268]] = &emul8; inh = 0;  }
void I06240() { lac += core[000047];  }
void I06241() { lac += core[000033];  }
void I06242() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I06243() { core[(ib<<12)+core[7]] = 06244; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I06244() { &emul8;  }
void I06245() { &emul8;  }
void L06246() { lac += core[000033];  }
void I06247() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06250() { npc = (ib<<12)+core[3200]; inh = 0;  }
void I06251() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06252() { npc = 006261; inh = 0;  }
void I06253() { core[(ib<<12)+core[7]] = 06254; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I06254() { &emul8;  }
void I06255() { &emul8;  }
void I06256() { &emul8;  }
void I06257() { lac++;  }
void I06260() { npc = 006266; inh = 0;  }
void L06261() { core[(ib<<12)+core[7]] = 06262; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I06262() { &emul8;  }
void I06263() { &emul8;  }
void I06264() { &emul8;  }
void I06265() { lac ^= 07777;  }
void L06266() { lac += core[000033];  }
void I06267() { core[000033] = lac & 07777; lac &= 010000; code[000033] = &emul8;  }
void I06270() { npc = 006246; inh = 0;  }
void D06271() { lac &= (010000|core[000004]);  }
void I06272() { if (++core[(df<<12)+core[0]] == 010000) { core[(df<<12)+core[0]] = 0; npc++; }; code[(df<<12)+core[0]] = &emul8;  }
void I06273() { lac &= (010000|core[000000]);  }
void I06274() { lac &= (010000|core[000000]);  }
void D06275() { emul8();  }
void I06276() { core[000146] = lac & 07777; lac &= 010000; code[000146] = &emul8;  }
void I06277() { core[000147] = lac & 07777; lac &= 010000; code[000147] = &emul8;  }
void I06300() { core[000150] = lac & 07777; lac &= 010000; code[000150] = &emul8;  }
void D06301() { emul8();  }
void P06302() { npc = (ib<<12)+core[3200]; inh = 0;  }
void P06303() { npc = (ib<<12)+core[3223]; inh = 0;  }
void P06304() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void P06305() { npc = (ib<<12)+core[3276]; inh = 0;  }
void P06306() { lac &= (010000|core[(df<<12)+core[3310]]);  }
void P06307() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = (lac<<1) + ((lac>>12)&1); lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void D06310() { lac &= (010000|core[000043]);  }
void P06321() { lac &= (010000|core[000000]);  }
void L06322() { lac += core[000105];  }
void I06323() { core[006343] = lac & 07777; lac &= 010000; code[006343] = &emul8;  }
void L06324() { lac += core[000037];  }
void I06325() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D06326() { npc = 006364; inh = 0;  }
void I06327() { if (++core[000032] == 010000) { core[000032] = 0; npc++; }; code[000032] = &emul8;  }
void I06330() { npc = 006324; inh = 0;  }
void I06331() { if (++core[006343] == 010000) { core[006343] = 0; npc++; }; code[006343] = &emul8;  }
void I06332() { npc = 006324; inh = 0;  }
void I06333() { core[006343] = 06334; npc = 006343+1; code[006343] = &emul8; inh = 0;  }
void I06334() { lac += core[000013];  }
void I06335() { lac += core[006376];  }
void I06336() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I06337() { npc = (ib<<12)+core[3298]; inh = 0;  }
void I06340() { if (++core[000013] == 010000) { core[000013] = 0; npc++; }; code[000013] = &emul8;  }
void I06341() { npc = (ib<<12)+core[97]; inh = 0;  }
void P06342() { lac &= (010000|core[006212]);  }
void S06343() { lac &= (010000|core[000000]);  }
void I06344() { lac += core[006375];  }
void I06345() { lac ^= 07777;  }
void I06346() { core[006375] = lac & 07777; lac &= 010000; code[006375] = &emul8;  }
void I06347() { lac &= 07777; lac ^= 07777;  }
void I06350() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I06351() { lac += core[006375];  }
void I06352() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I06353() { emul8();  }
void I06354() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06355() { lac += core[006377];  }
void P06356() { lac += core[000126];  }
void I06357() { core[000152] = lac & 07777; lac &= 010000; code[000152] = &emul8;  }
void I06360() { npc = (ib<<12)+core[3299]; inh = 0;  }
void I06361() { core[006343] = 06362; npc = 006343+1; code[006343] = &emul8; inh = 0;  }
void I06362() { npc = (ib<<12)+core[3315]; inh = 0;  }
void P06363() { lac &= (010000|core[(df<<12)+core[3209]]);  }
void L06364() { lac ^= 07777;  }
void I06365() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I06366() { emul8();  }
void I06367() { lac &= (010000|core[000106]);  }
void I06370() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06371() { npc = 006322; inh = 0;  }
void I06372() { lac += core[000123];  }
void I06373() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I06374() { npc = (ib<<12)+core[3281]; inh = 0;  }
void D06375() { lac &= (010000|core[000000]);  }
void D06376() { core[(ib<<12)+core[111]] = 06377; npc = (ib<<12)+core[111]+1; code[(ib<<12)+core[111]] = &emul8; inh = 0;  }
void D06377() { core[000144] = 06400; npc = 000144+1; code[000144] = &emul8; inh = 0;  }
void S06400() { lac &= (010000|core[000000]);  }
void L06401() { lac &= 010000; lac &= 07777;  }
void I06402() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I06403() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06404() { lac += core[(df<<12)+core[3328]];  }
void I06405() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06406() { npc = (ib<<12)+core[3328]; inh = 0;  }
void I06407() { core[006462] = lac & 07777; lac &= 010000; code[006462] = &emul8;  }
void I06410() { lac += core[006462];  }
void I06411() { lac &= (010000|core[000123]);  }
void I06412() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06413() { npc = 006416; inh = 0;  }
void I06414() { lac += core[000104];  }
void I06415() { lac &= (010000|core[006400]);  }
void L06416() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I06417() { lac += core[000106];  }
void I06420() { lac &= (010000|core[006462]);  }
void I06421() { lac += core[000040];  }
void I06422() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I06423() { lac += core[006463];  }
void I06424() { lac &= (010000|core[006462]);  }
void I06425() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06426() { npc = 006431; inh = 0;  }
void I06427() { lac += core[(df<<12)+core[32]];  }
void L06430() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void L06431() { if (++core[006400] == 010000) { core[006400] = 0; npc++; }; code[006400] = &emul8;  }
void I06432() { lac ^= 07777;  }
void I06433() { lac += core[000040];  }
void I06434() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I06435() { lac += core[006462];  }
void I06436() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I06437() { lac = (lac<<2) + ((lac>>11)&3);  }
void I06440() { lac &= (010000|core[000107]);  }
void I06441() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06442() { npc = 006467; inh = 0;  }
void I06443() { lac += core[006464];  }
void I06444() { core[006462] = lac & 07777; lac &= 010000; code[006462] = &emul8;  }
void I06445() { lac += core[(df<<12)+core[3378]];  }
void I06446() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06447() { npc = 006465; inh = 0;  }
void I06450() { core[006462] = lac & 07777; lac &= 010000; code[006462] = &emul8;  }
void I06451() { lac += core[006504];  }
void I06452() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I06453() { lac += core[000117];  }
void I06454() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void L06455() { if (++core[000015] == 010000) core[000015] = 0000;lac += core[(df<<12)+core[000015]];  }
void I06456() { if (++core[000014] == 010000) core[000014] = 0000;core[(df<<12)+core[000014]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000014]] = &emul8;  }
void I06457() { if (++core[000057] == 010000) { core[000057] = 0; npc++; }; code[000057] = &emul8;  }
void I06460() { npc = 006455; inh = 0;  }
void I06461() { npc = (ib<<12)+core[3378]; inh = 0;  }
void P06462() { lac &= (010000|core[000000]);  }
void D06463() { lac &= (010000|core[(df<<12)+core[0]]);  }
void D06464() { emul8();  }
void L06465() { lac += core[006503];  }
void I06466() { npc = 006473; inh = 0;  }
void L06467() { lac += core[006503];  }
void I06470() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I06471() { lac ^= 07777;  }
void I06472() { lac += core[000040];  }
void L06473() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I06474() { lac += core[000117];  }
void I06475() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void L06476() { if (++core[000014] == 010000) core[000014] = 0000;lac += core[(df<<12)+core[000014]];  }
void I06477() { if (++core[000015] == 010000) core[000015] = 0000;core[(df<<12)+core[000015]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000015]] = &emul8;  }
void I06500() { if (++core[000057] == 010000) { core[000057] = 0; npc++; }; code[000057] = &emul8;  }
void I06501() { npc = 006476; inh = 0;  }
void I06502() { npc = 006401; inh = 0;  }
void D06503() { lac &= (010000|core[000043]);  }
void D06504() { lac &= (010000|core[000037]);  }
void I06505() { core[(ib<<12)+core[3445]] = 06506; npc = (ib<<12)+core[3445]+1; code[(ib<<12)+core[3445]] = &emul8; inh = 0;  }
void I06506() { core[(ib<<12)+core[3448]] = 06507; npc = (ib<<12)+core[3448]+1; code[(ib<<12)+core[3448]] = &emul8; inh = 0;  }
void I06507() { npc = 006401; inh = 0;  }
void I06510() { core[(ib<<12)+core[3450]] = 06511; npc = (ib<<12)+core[3450]+1; code[(ib<<12)+core[3450]] = &emul8; inh = 0;  }
void I06511() { core[(ib<<12)+core[3449]] = 06512; npc = (ib<<12)+core[3449]+1; code[(ib<<12)+core[3449]] = &emul8; inh = 0;  }
void I06512() { core[(ib<<12)+core[3451]] = 06513; npc = (ib<<12)+core[3451]+1; code[(ib<<12)+core[3451]] = &emul8; inh = 0;  }
void I06513() { core[(ib<<12)+core[3447]] = 06514; npc = (ib<<12)+core[3447]+1; code[(ib<<12)+core[3447]] = &emul8; inh = 0;  }
void I06514() { npc = 006401; inh = 0;  }
void I06515() { lac += core[000045];  }
void I06516() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06517() { npc = 006525; inh = 0;  }
void L06520() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06521() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06522() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06523() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I06524() { npc = 006401; inh = 0;  }
void L06525() { core[(ib<<12)+core[99]] = 06526; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I06526() { lac &= (010000|core[000044]);  }
void I06527() { core[(ib<<12)+core[99]] = 06530; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I06530() { lac &= (010000|core[000040]);  }
void I06531() { core[(ib<<12)+core[100]] = 06532; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I06532() { lac &= (010000|core[000044]);  }
void P06533() { core[(ib<<12)+core[43]] = 06534; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void I06534() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06535() { npc = 006542; inh = 0;  }
void I06536() { lac ^= 07777;  }
void I06537() { core[006462] = lac & 07777; lac &= 010000; code[006462] = &emul8;  }
void I06540() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06541() { lac += core[000045];  }
void L06542() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06543() { core[(ib<<12)+core[118]] = 06544; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I06544() { core[(ib<<12)+core[99]] = 06545; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void I06545() { if (++core[(df<<12)+core[5]] == 010000) { core[(df<<12)+core[5]] = 0; npc++; }; code[(df<<12)+core[5]] = &emul8;  }
void I06546() { core[(ib<<12)+core[100]] = 06547; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I06547() { lac &= (010000|core[000044]);  }
void I06550() { core[(ib<<12)+core[100]] = 06551; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I06551() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I06552() { npc = 006560; inh = 0;  }
void L06553() { core[(ib<<12)+core[99]] = 06554; npc = (ib<<12)+core[99]+1; code[(ib<<12)+core[99]] = &emul8; inh = 0;  }
void P06554() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I06555() { core[(ib<<12)+core[100]] = 06556; npc = (ib<<12)+core[100]+1; code[(ib<<12)+core[100]] = &emul8; inh = 0;  }
void I06556() { lac &= (010000|core[000040]);  }
void I06557() { core[(ib<<12)+core[3446]] = 06560; npc = (ib<<12)+core[3446]+1; code[(ib<<12)+core[3446]] = &emul8; inh = 0;  }
void L06560() { if (++core[006462] == 010000) { core[006462] = 0; npc++; }; code[006462] = &emul8;  }
void I06561() { npc = 006553; inh = 0;  }
void I06562() { npc = 006401; inh = 0;  }
void I06563() { core[(ib<<12)+core[3446]] = 06564; npc = (ib<<12)+core[3446]+1; code[(ib<<12)+core[3446]] = &emul8; inh = 0;  }
void I06564() { npc = 006401; inh = 0;  }
void P06565() { lac &= 07777; lac ^= 07777; lac++; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void P06566() { lac = (lac<<1) + ((lac>>12)&1);  }
void P06567() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = (lac<<1) + ((lac>>12)&1); lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void P06570() { emul8();  }
void P06571() { npc = (ib<<12)+core[3436]; inh = 0;  }
void P06572() { emul8();  }
void P06573() { npc = (ib<<12)+core[3419]; inh = 0;  }
void I06574() { emul8();  }
void I06575() { emul8();  }
void I06576() { lac &= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I06577() { emul8();  }
void I06600() { emul8();  }
void I06601() { lac &= (010000|core[000000]);  }
void I06602() { emul8();  }
void S06603() { lac &= (010000|core[000000]);  }
void I06604() { lac &= 010000; lac &= 07777;  }
void I06605() { lac += core[000047];  }
void I06606() { lac ^= 07777; lac++;  }
void I06607() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I06610() { lac += core[000046];  }
void I06611() { lac ^= 07777;  }
void I06612() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I06613() { lac &= 07777; lac++;  }
void I06614() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06615() { lac += core[000045];  }
void I06616() { lac ^= 07777;  }
void I06617() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I06620() { lac &= 07777; lac++;  }
void I06621() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06622() { npc = (ib<<12)+core[3459]; inh = 0;  }
void S06623() { lac &= (010000|core[000000]);  }
void I06624() { lac += core[000045];  }
void I06625() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06626() { lac += core[000046];  }
void I06627() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06630() { npc = 006711; inh = 0;  }
void I06631() { lac += core[000041];  }
void I06632() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06633() { lac += core[000042];  }
void I06634() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06635() { lac += core[000043];  }
void I06636() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06637() { npc = (ib<<12)+core[3475]; inh = 0;  }
void I06640() { lac += core[000040];  }
void I06641() { lac ^= 07777; lac++;  }
void I06642() { lac += core[000044];  }
void I06643() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06644() { npc = 006673; inh = 0;  }
void I06645() { core[006603] = lac & 07777; lac &= 010000; code[006603] = &emul8;  }
void I06646() { lac += core[006603];  }
void I06647() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I06650() { lac ^= 07777; lac++;  }
void I06651() { core[006722] = lac & 07777; lac &= 010000; code[006722] = &emul8;  }
void I06652() { lac += core[006722];  }
void I06653() { lac += core[006736];  }
void I06654() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06655() { npc = 006675; inh = 0;  }
void I06656() { lac += core[006603];  }
void I06657() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06660() { npc = 006665; inh = 0;  }
void L06661() { core[006757] = 06662; npc = 006757+1; code[006757] = &emul8; inh = 0;  }
void I06662() { if (++core[006722] == 010000) { core[006722] = 0; npc++; }; code[006722] = &emul8;  }
void I06663() { npc = 006661; inh = 0;  }
void I06664() { npc = 006673; inh = 0;  }
void L06665() { lac ^= 07777;  }
void I06666() { lac += core[000040];  }
void I06667() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void L06670() { core[(ib<<12)+core[3539]] = 06671; npc = (ib<<12)+core[3539]+1; code[(ib<<12)+core[3539]] = &emul8; inh = 0;  }
void I06671() { if (++core[006722] == 010000) { core[006722] = 0; npc++; }; code[006722] = &emul8;  }
void I06672() { npc = 006670; inh = 0;  }
void L06673() { if (++core[006623] == 010000) { core[006623] = 0; npc++; }; code[006623] = &emul8;  }
void I06674() { npc = (ib<<12)+core[3475]; inh = 0;  }
void L06675() { lac += core[000040];  }
void I06676() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06677() { npc = 006704; inh = 0;  }
void I06700() { lac += core[000044];  }
void I06701() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06702() { npc = (ib<<12)+core[3475]; inh = 0;  }
void I06703() { npc = 006706; inh = 0;  }
void L06704() { lac += core[000044];  }
void I06705() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void L06706() { lac += core[006603];  }
void I06707() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06710() { npc = (ib<<12)+core[3475]; inh = 0;  }
void L06711() { lac += core[000040];  }
void I06712() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I06713() { lac += core[000041];  }
void I06714() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06715() { lac += core[000042];  }
void I06716() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06717() { lac += core[000043];  }
void I06720() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I06721() { npc = (ib<<12)+core[3475]; inh = 0;  }
void D06722() { lac &= (010000|core[000000]);  }
void P06723() { npc = (ib<<12)+core[3564]; inh = 0;  }
void S06724() { lac &= (010000|core[000000]);  }
void I06725() { core[(ib<<12)+core[3561]] = 06726; npc = (ib<<12)+core[3561]+1; code[(ib<<12)+core[3561]] = &emul8; inh = 0;  }
void I06726() { lac += core[000044];  }
void I06727() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06730() { npc = 006753; inh = 0;  }
void I06731() { lac++;  }
void I06732() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I06733() { lac += core[006750];  }
void I06734() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I06735() { core[006623] = 06736; npc = 006623+1; code[006623] = &emul8; inh = 0;  }
void D06736() { lac &= (010000|core[000027]);  }
void D06737() { if (++core[000047] == 010000) { core[000047] = 0; npc++; }; code[000047] = &emul8;  }
void I06740() { npc = 006744; inh = 0;  }
void I06741() { if (++core[000046] == 010000) { core[000046] = 0; npc++; }; code[000046] = &emul8;  }
void I06742() { skp = 0; skp = !skp; npc += skp;  }
void I06743() { if (++core[000045] == 010000) { core[000045] = 0; npc++; }; code[000045] = &emul8;  }
void L06744() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I06745() { core[(ib<<12)+core[3562]] = 06746; npc = (ib<<12)+core[3562]+1; code[(ib<<12)+core[3562]] = &emul8; inh = 0;  }
void I06746() { lac += core[000046];  }
void I06747() { npc = (ib<<12)+core[3540]; inh = 0;  }
void D06750() { lac &= (010000|core[000027]);  }
void P06751() { npc = (ib<<12)+core[121]; inh = 0;  }
void P06752() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void L06753() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void P06754() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06755() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06756() { npc = 006744; inh = 0;  }
void S06757() { lac &= (010000|core[000000]);  }
void I06760() { lac &= 010000; lac &= 07777;  }
void I06761() { lac += core[000045];  }
void I06762() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06763() { lac ^= 010000;  }
void I06764() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06765() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06766() { lac += core[000046];  }
void I06767() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06770() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06771() { lac += core[000047];  }
void I06772() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06773() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I06774() { if (++core[000044] == 010000) { core[000044] = 0; npc++; }; code[000044] = &emul8;  }
void I06775() { npc = (ib<<12)+core[3567]; inh = 0;  }
void I06776() { npc = (ib<<12)+core[3567]; inh = 0;  }
void I06777() { lac &= (010000|core[006737]);  }
void I07000() { lac &= (010000|core[007177]);  }
void I07001() { lac &= (010000|core[007012]);  }
void I07002() { lac &= (010000|core[007175]);  }
void I07003() { emul8();  }
void S07004() { lac &= (010000|core[000000]);  }
void I07005() { lac++;  }
void I07006() { lac += core[000040];  }
void I07007() { core[007124] = 07010; npc = 007124+1; code[007124] = &emul8; inh = 0;  }
void I07010() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07011() { core[007153] = 07012; npc = 007153+1; code[007153] = &emul8; inh = 0;  }
void D07012() { core[007101] = lac & 07777; lac &= 010000; code[007101] = &emul8;  }
void I07013() { core[007100] = lac & 07777; lac &= 010000; code[007100] = &emul8;  }
void I07014() { core[007077] = lac & 07777; lac &= 010000; code[007077] = &emul8;  }
void I07015() { core[007076] = lac & 07777; lac &= 010000; code[007076] = &emul8;  }
void I07016() { lac += core[000045];  }
void I07017() { core[(df<<12)+core[3689]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3689]] = &emul8;  }
void I07020() { lac += core[000041];  }
void I07021() { core[(ib<<12)+core[3690]] = 07022; npc = (ib<<12)+core[3690]+1; code[(ib<<12)+core[3690]] = &emul8; inh = 0;  }
void I07022() { lac &= (010000|core[000002]);  }
void I07023() { lac += core[000042];  }
void I07024() { core[(ib<<12)+core[3690]] = 07025; npc = (ib<<12)+core[3690]+1; code[(ib<<12)+core[3690]] = &emul8; inh = 0;  }
void I07025() { lac &= (010000|core[000003]);  }
void I07026() { lac += core[000046];  }
void I07027() { core[(df<<12)+core[3689]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3689]] = &emul8;  }
void I07030() { lac += core[000041];  }
void I07031() { core[(ib<<12)+core[3690]] = 07032; npc = (ib<<12)+core[3690]+1; code[(ib<<12)+core[3690]] = &emul8; inh = 0;  }
void I07032() { lac &= (010000|core[000003]);  }
void I07033() { lac += core[000042];  }
void I07034() { core[(ib<<12)+core[3690]] = 07035; npc = (ib<<12)+core[3690]+1; code[(ib<<12)+core[3690]] = &emul8; inh = 0;  }
void I07035() { lac &= (010000|core[000004]);  }
void I07036() { npc = 007063; inh = 0;  }
void I07037() { core[007074] = lac & 07777; lac &= 010000; code[007074] = &emul8;  }
void I07040() { lac += core[000043];  }
void D07041() { core[(df<<12)+core[3689]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3689]] = &emul8;  }
void D07042() { lac += core[000045];  }
void I07043() { core[(ib<<12)+core[3690]] = 07044; npc = (ib<<12)+core[3690]+1; code[(ib<<12)+core[3690]] = &emul8; inh = 0;  }
void I07044() { lac &= (010000|core[000004]);  }
void I07045() { lac += core[000046];  }
void I07046() { core[(ib<<12)+core[3690]] = 07047; npc = (ib<<12)+core[3690]+1; code[(ib<<12)+core[3690]] = &emul8; inh = 0;  }
void I07047() { lac &= (010000|core[000005]);  }
void I07050() { lac += core[000047];  }
void I07051() { core[(df<<12)+core[3689]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3689]] = &emul8;  }
void I07052() { lac += core[000041];  }
void I07053() { core[(ib<<12)+core[3690]] = 07054; npc = (ib<<12)+core[3690]+1; code[(ib<<12)+core[3690]] = &emul8; inh = 0;  }
void I07054() { lac &= (010000|core[000004]);  }
void I07055() { lac += core[000042];  }
void I07056() { core[(ib<<12)+core[3690]] = 07057; npc = (ib<<12)+core[3690]+1; code[(ib<<12)+core[3690]] = &emul8; inh = 0;  }
void D07057() { lac &= (010000|core[000005]);  }
void I07060() { lac += core[000043];  }
void I07061() { core[(ib<<12)+core[3690]] = 07062; npc = (ib<<12)+core[3690]+1; code[(ib<<12)+core[3690]] = &emul8; inh = 0;  }
void I07062() { lac &= (010000|core[000006]);  }
void L07063() { lac += core[007101];  }
void I07064() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I07065() { lac += core[007100];  }
void I07066() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I07067() { lac += core[007077];  }
void I07070() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07071() { core[007101] = 07072; npc = 007101+1; code[007101] = &emul8; inh = 0;  }
void I07072() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07073() { npc = (ib<<12)+core[3588]; inh = 0;  }
void S07101() { lac &= (010000|core[000000]);  }
void I07102() { if (++core[000050] == 010000) { core[000050] = 0; npc++; }; code[000050] = &emul8;  }
void I07103() { core[(ib<<12)+core[41]] = 07104; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07104() { core[(ib<<12)+core[3687]] = 07105; npc = (ib<<12)+core[3687]+1; code[(ib<<12)+core[3687]] = &emul8; inh = 0;  }
void I07105() { if (++core[000047] == 010000) { core[000047] = 0; npc++; }; code[000047] = &emul8;  }
void I07106() { npc = (ib<<12)+core[3649]; inh = 0;  }
void I07107() { lac += core[000041];  }
void I07110() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07111() { core[(ib<<12)+core[118]] = 07112; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I07112() { lac += core[000040];  }
void I07113() { lac ^= 07777; lac++;  }
void I07114() { lac++;  }
void I07115() { core[007124] = 07116; npc = 007124+1; code[007124] = &emul8; inh = 0;  }
void I07116() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I07117() { core[007153] = 07120; npc = 007153+1; code[007153] = &emul8; inh = 0;  }
void I07120() { core[(ib<<12)+core[3688]] = 07121; npc = (ib<<12)+core[3688]+1; code[(ib<<12)+core[3688]] = &emul8; inh = 0;  }
void I07121() { core[007101] = 07122; npc = 007101+1; code[007101] = &emul8; inh = 0;  }
void I07122() { npc = (ib<<12)+core[3667]; inh = 0;  }
void P07123() { emul8();  }
void S07124() { lac &= (010000|core[000000]);  }
void I07125() { lac += core[000044];  }
void I07126() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07127() { lac += core[000124];  }
void I07130() { lac &= (010000|core[000045]);  }
void I07131() { lac += core[000041];  }
void I07132() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I07133() { lac ^= 07777;  }
void I07134() { core[000050] = lac & 07777; lac &= 010000; code[000050] = &emul8;  }
void I07135() { lac += core[000045];  }
void I07136() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07137() { npc = (ib<<12)+core[3686]; inh = 0;  }
void I07140() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07141() { core[(ib<<12)+core[41]] = 07142; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void I07142() { lac += core[000041];  }
void I07143() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07144() { npc = (ib<<12)+core[3686]; inh = 0;  }
void I07145() { npc = (ib<<12)+core[3668]; inh = 0;  }
void P07146() { emul8();  }
void P07147() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = (lac<<1) + ((lac>>12)&1); lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void P07150() { lac &= 010000; lac ^= 010000; lac ^= 07777; lac++;  }
void P07151() { lac &= 010000; lac ^= 07777; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void P07152() { lac &= 010000;  }
void S07153() { lac &= (010000|core[000000]);  }
void I07154() { lac &= 010000; lac &= 07777;  }
void I07155() { lac += core[000043];  }
void I07156() { lac ^= 07777; lac++;  }
void I07157() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I07160() { lac += core[000042];  }
void I07161() { lac ^= 07777;  }
void I07162() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I07163() { lac &= 07777; lac++;  }
void I07164() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I07165() { lac += core[000041];  }
void L07166() { lac ^= 07777;  }
void I07167() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I07170() { lac &= 07777; lac++;  }
void I07171() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I07172() { npc = (ib<<12)+core[3691]; inh = 0;  }
void S07173() { lac &= (010000|core[000000]);  }
void I07174() { lac += core[000050];  }
void D07175() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07176() { core[(ib<<12)+core[41]] = 07177; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void D07177() { npc = (ib<<12)+core[3707]; inh = 0;  }
void S07200() { lac &= (010000|core[000000]);  }
void I07201() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07202() { npc = (ib<<12)+core[3712]; inh = 0;  }
void I07203() { core[007254] = lac & 07777; lac &= 010000; code[007254] = &emul8;  }
void I07204() { core[007253] = lac & 07777; lac &= 010000; code[007253] = &emul8;  }
void I07205() { lac += core[007257];  }
void I07206() { core[007255] = lac & 07777; lac &= 010000; code[007255] = &emul8;  }
void I07207() { lac &= 07777;  }
void L07210() { lac += core[007254];  }
void I07211() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07212() { core[007254] = lac & 07777; lac &= 010000; code[007254] = &emul8;  }
void I07213() { lac += core[007253];  }
void I07214() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I07215() { npc = 007220; inh = 0;  }
void I07216() { lac &= 07777;  }
void I07217() { lac += core[007256];  }
void L07220() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07221() { core[007253] = lac & 07777; lac &= 010000; code[007253] = &emul8;  }
void I07222() { if (++core[007255] == 010000) { core[007255] = 0; npc++; }; code[007255] = &emul8;  }
void I07223() { npc = 007210; inh = 0;  }
void I07224() { lac += core[007254];  }
void I07225() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07226() { core[007255] = lac & 07777; lac &= 010000; code[007255] = &emul8;  }
void I07227() { lac += core[(df<<12)+core[3712]];  }
void I07230() { lac ^= 07777; lac++;  }
void I07231() { lac += core[007252];  }
void I07232() { core[007254] = lac & 07777; lac &= 010000; code[007254] = &emul8;  }
void I07233() { lac += core[007255];  }
void I07234() { lac &= 07777;  }
void I07235() { lac += core[(df<<12)+core[3756]];  }
void I07236() { core[(df<<12)+core[3756]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3756]] = &emul8;  }
void I07237() { if (++core[007254] == 010000) { core[007254] = 0; npc++; }; code[007254] = &emul8;  }
void I07240() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07241() { lac += core[007253];  }
void I07242() { lac += core[(df<<12)+core[3756]];  }
void I07243() { core[(df<<12)+core[3756]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3756]] = &emul8;  }
void I07244() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I07245() { npc = (ib<<12)+core[3712]; inh = 0;  }
void L07246() { if (++core[007254] == 010000) { core[007254] = 0; npc++; }; code[007254] = &emul8;  }
void I07247() { if (++core[(df<<12)+core[3756]] == 010000) { core[(df<<12)+core[3756]] = 0; npc++; }; code[(df<<12)+core[3756]] = &emul8;  }
void I07250() { npc = (ib<<12)+core[3712]; inh = 0;  }
void I07251() { npc = 007246; inh = 0;  }
void D07252() { lac &= 07777; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void D07253() { lac &= (010000|core[000000]);  }
void P07254() { lac &= (010000|core[000000]);  }
void D07255() { lac &= (010000|core[000000]);  }
void D07256() { lac &= (010000|core[000000]);  }
void D07257() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void D07260() { emul8();  }
void S07261() { lac &= (010000|core[000000]);  }
void I07262() { core[007200] = lac & 07777; lac &= 010000; code[007200] = &emul8;  }
void I07263() { core[007254] = lac & 07777; lac &= 010000; code[007254] = &emul8;  }
void I07264() { lac += core[007260];  }
void I07265() { core[007255] = lac & 07777; lac &= 010000; code[007255] = &emul8;  }
void I07266() { skp = 0; skp = !skp; npc += skp;  }
void L07267() { core[(ib<<12)+core[87]] = 07270; npc = (ib<<12)+core[87]+1; code[(ib<<12)+core[87]] = &emul8; inh = 0;  }
void I07270() { lac &= 07777;  }
void I07271() { lac += core[000042];  }
void I07272() { lac += core[000046];  }
void I07273() { core[007256] = lac & 07777; lac &= 010000; code[007256] = &emul8;  }
void I07274() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07275() { lac += core[000045];  }
void I07276() { lac += core[000041];  }
void I07277() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I07300() { npc = 007304; inh = 0;  }
void I07301() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I07302() { lac += core[007256];  }
void I07303() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void L07304() { lac &= 010000;  }
void I07305() { lac += core[007254];  }
void I07306() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07307() { core[007254] = lac & 07777; lac &= 010000; code[007254] = &emul8;  }
void I07310() { lac += core[007200];  }
void I07311() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07312() { core[007200] = lac & 07777; lac &= 010000; code[007200] = &emul8;  }
void I07313() { if (++core[007255] == 010000) { core[007255] = 0; npc++; }; code[007255] = &emul8;  }
void I07314() { npc = 007267; inh = 0;  }
void I07315() { lac += core[007254];  }
void I07316() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I07317() { lac += core[007200];  }
void I07320() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I07321() { npc = (ib<<12)+core[3761]; inh = 0;  }
void I07322() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07323() { core[007335] = lac & 07777; lac &= 010000; code[007335] = &emul8;  }
void I07324() { if (++core[007255] == 010000) { core[007255] = 0; npc++; }; code[007255] = &emul8;  }
void I07325() { npc = 007267; inh = 0;  }
void I07326() { lac += core[007335];  }
void I07327() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I07330() { lac += core[007200];  }
void I07331() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I07332() { lac += core[007254];  }
void I07333() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07334() { npc = (ib<<12)+core[3761]; inh = 0;  }
void S07335() { lac &= (010000|core[000000]);  }
void I07336() { core[(ib<<12)+core[3837]] = 07337; npc = (ib<<12)+core[3837]+1; code[(ib<<12)+core[3837]] = &emul8; inh = 0;  }
void I07337() { core[007366] = 07340; npc = 007366+1; code[007366] = &emul8; inh = 0;  }
void I07340() { lac += core[000045];  }
void I07341() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07342() { lac += core[000047];  }
void I07343() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07344() { lac += core[000046];  }
void I07345() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07346() { npc = 007363; inh = 0;  }
void L07347() { lac += core[000045];  }
void I07350() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I07351() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07352() { npc = 007360; inh = 0;  }
void I07353() { core[(ib<<12)+core[87]] = 07354; npc = (ib<<12)+core[87]+1; code[(ib<<12)+core[87]] = &emul8; inh = 0;  }
void I07354() { lac &= 07777; lac ^= 07777;  }
void I07355() { lac += core[000044];  }
void I07356() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07357() { npc = 007347; inh = 0;  }
void L07360() { core[(ib<<12)+core[3838]] = 07361; npc = (ib<<12)+core[3838]+1; code[(ib<<12)+core[3838]] = &emul8; inh = 0;  }
void I07361() { core[007366] = 07362; npc = 007366+1; code[007366] = &emul8; inh = 0;  }
void I07362() { npc = (ib<<12)+core[3805]; inh = 0;  }
void L07363() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07364() { npc = (ib<<12)+core[3805]; inh = 0;  }
void P07365() { emul8();  }
void S07366() { lac &= (010000|core[000000]);  }
void I07367() { lac += core[000045];  }
void I07370() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I07371() { lac ^= 07777; lac++;  }
void I07372() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07373() { core[(ib<<12)+core[3829]] = 07374; npc = (ib<<12)+core[3829]+1; code[(ib<<12)+core[3829]] = &emul8; inh = 0;  }
void I07374() { npc = (ib<<12)+core[3830]; inh = 0;  }
void P07375() { npc = (ib<<12)+core[121]; inh = 0;  }
void P07376() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I07400() { core[(ib<<12)+core[7]] = 07401; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I07401() { &emul8;  }
void D07402() { &emul8;  }
void I07403() { lac += core[000045];  }
void I07404() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07405() { core[(ib<<12)+core[118]] = 07406; npc = (ib<<12)+core[118]+1; code[(ib<<12)+core[118]] = &emul8; inh = 0;  }
void I07406() { lac += core[000044];  }
void I07407() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void L07410() { lac ^= 010000;  }
void I07411() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07412() { core[007470] = lac & 07777; lac &= 010000; code[007470] = &emul8;  }
void I07413() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I07414() { if (++core[007470] == 010000) { core[007470] = 0; npc++; }; code[007470] = &emul8;  }
void I07415() {  }
void I07416() { lac += core[007467];  }
void I07417() { core[007471] = lac & 07777; lac &= 010000; code[007471] = &emul8;  }
void I07420() { core[007472] = lac & 07777; lac &= 010000; code[007472] = &emul8;  }
void I07421() { core[007473] = lac & 07777; lac &= 010000; code[007473] = &emul8;  }
void I07422() { lac += core[007475];  }
void I07423() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07424() { lac += core[007476];  }
void I07425() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07426() { npc = 007465; inh = 0;  }
void L07427() { core[(ib<<12)+core[7]] = 07430; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I07430() { &emul8;  }
void I07431() { &emul8;  }
void I07432() { &emul8;  }
void I07433() { &emul8;  }
void I07434() { lac &= 010000; lac ^= 07777;  }
void I07435() { lac += core[000044];  }
void I07436() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07437() { lac += core[000044];  }
void I07440() { lac ^= 07777; lac++;  }
void I07441() { lac += core[007470];  }
void I07442() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07443() { npc = 007461; inh = 0;  }
void I07444() { lac += core[000045];  }
void I07445() { lac ^= 07777; lac++;  }
void I07446() { lac += core[007471];  }
void I07447() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void D07450() { npc = 007461; inh = 0;  }
void I07451() { lac += core[000046];  }
void I07452() { lac ^= 07777; lac++;  }
void I07453() { lac += core[007472];  }
void I07454() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I07455() { lac ^= 07777; lac++;  }
void I07456() { lac++;  }
void I07457() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I07460() { npc = (ib<<12)+core[94]; inh = 0;  }
void L07461() { core[(ib<<12)+core[7]] = 07462; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I07462() { &emul8;  }
void I07463() { &emul8;  }
void I07464() { npc = 007427; inh = 0;  }
void L07465() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07466() { npc = (ib<<12)+core[94]; inh = 0;  }
void D07467() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void L07470() { lac &= (010000|core[000000]);  }
void D07471() { lac &= (010000|core[000000]);  }
void D07472() { lac &= (010000|core[000000]);  }
void D07473() { lac &= (010000|core[000000]);  }
void D07474() { lac &= (010000|core[000000]);  }
void D07475() { lac &= (010000|core[000000]);  }
void D07476() { lac &= (010000|core[000000]);  }
void I07477() { emul8();  }
void I07503() { lac += core[000133];  }
void I07504() { core[007527] = 07505; npc = 007527+1; code[007527] = &emul8; inh = 0;  }
void I07505() { lac += core[000060];  }
void I07506() { core[007527] = 07507; npc = 007527+1; code[007527] = &emul8; inh = 0;  }
void I07507() { lac += core[000031];  }
void I07510() { core[007527] = 07511; npc = 007527+1; code[007527] = &emul8; inh = 0;  }
void I07511() { lac += core[000035];  }
void I07512() { core[007527] = 07513; npc = 007527+1; code[007527] = &emul8; inh = 0;  }
void I07513() { npc = 007516; inh = 0;  }
void L07514() { core[(ib<<12)+core[101]] = 07515; npc = (ib<<12)+core[101]+1; code[(ib<<12)+core[101]] = &emul8; inh = 0;  }
void I07515() { core[(ib<<12)+core[105]] = 07516; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void L07516() { lac += core[000066];  }
void I07517() { lac += core[000116];  }
void I07520() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07521() { npc = 007514; inh = 0;  }
void L07522() { lac += core[000016];  }
void I07523() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07524() { npc = 007522; inh = 0;  }
void I07525() { emul8();  }
void I07526() { npc = (ib<<12)+core[68]; inh = 0;  }
void S07527() { lac &= (010000|core[000000]);  }
void I07530() { core[000032] = lac & 07777; lac &= 010000; code[000032] = &emul8;  }
void I07531() { lac += core[000032];  }
void I07532() { lac = (lac<<2) + ((lac>>11)&3);  }
void I07533() { lac = (lac<<2) + ((lac>>11)&3);  }
void I07534() { core[007550] = 07535; npc = 007550+1; code[007550] = &emul8; inh = 0;  }
void I07535() { core[(ib<<12)+core[111]] = 07536; npc = (ib<<12)+core[111]+1; code[(ib<<12)+core[111]] = &emul8; inh = 0;  }
void I07536() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07537() { core[007550] = 07540; npc = 007550+1; code[007550] = &emul8; inh = 0;  }
void L07540() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I07541() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07542() { core[007550] = 07543; npc = 007550+1; code[007550] = &emul8; inh = 0;  }
void I07543() { core[007550] = 07544; npc = 007550+1; code[007550] = &emul8; inh = 0;  }
void I07544() { lac &= 010000;  }
void I07545() { lac += core[000077];  }
void I07546() { core[(ib<<12)+core[105]] = 07547; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I07547() { npc = (ib<<12)+core[3927]; inh = 0;  }
void S07550() { lac &= (010000|core[000000]);  }
void I07551() { lac &= (010000|core[007556]);  }
void I07552() { lac += core[000113];  }
void I07553() { core[(ib<<12)+core[105]] = 07554; npc = (ib<<12)+core[105]+1; code[(ib<<12)+core[105]] = &emul8; inh = 0;  }
void I07554() { lac += core[000032];  }
void I07555() { npc = (ib<<12)+core[3944]; inh = 0;  }
void D07556() { lac &= (010000|core[000007]);  }
void preinit() {
  core[000001] = 05403; code[000001] = &P00001;
  core[000002] = 05403; code[000002] = &P00002;
  core[000003] = 02603; code[000003] = &P00003;
  core[000004] = 00004; code[000004] = &D00004;
  core[000005] = 00013; code[000005] = &P00005;
  core[000006] = 00100; code[000006] = &D00006;
  core[000007] = 06400; code[000007] = &P00007;
  core[000010] = 00000; code[000010] = &P00010;
  core[000011] = 00000; code[000011] = &P00011;
  core[000012] = 00000; code[000012] = &P00012;
  core[000013] = 04370; code[000013] = &P00013;
  core[000014] = 03117; code[000014] = &P00014;
  core[000015] = 00000; code[000015] = &P00015;
  core[000016] = 07402; code[000016] = &P00016;
  core[000017] = 03215; code[000017] = &P00017;
  core[000020] = 00000; code[000020] = &P00020;
  core[000021] = 00000; code[000021] = &P00021;
  core[000022] = 02407; code[000022] = &P00022;
  core[000023] = 00000; code[000023] = &P00023;
  core[000024] = 00000; code[000024] = &P00024;
  core[000025] = 00000; code[000025] = &P00025;
  core[000026] = 00001; code[000026] = &D00026;
  core[000027] = 00000; code[000027] = &P00027;
  core[000030] = 00000; code[000030] = &P00030;
  core[000031] = 03760; code[000031] = &P00031;
  core[000032] = 00000; code[000032] = &D00032;
  core[000033] = 00000; code[000033] = &D00033;
  core[000034] = 00000; code[000034] = &P00034;
  core[000035] = 04370; code[000035] = &P00035;
  core[000036] = 00000; code[000036] = &P00036;
  core[000037] = 00000; code[000037] = &P00037;
  core[000040] = 00000; code[000040] = &P00040;
  core[000041] = 00000; code[000041] = &D00041;
  core[000042] = 00000; code[000042] = &P00042;
  core[000043] = 00000; code[000043] = &P00043;
  core[000044] = 00000; code[000044] = &D00044;
  core[000045] = 00000; code[000045] = &D00045;
  core[000046] = 00000; code[000046] = &D00046;
  core[000047] = 00000; code[000047] = &D00047;
  core[000050] = 00000; code[000050] = &P00050;
  core[000051] = 06603; code[000051] = &P00051;
  core[000052] = 02004; code[000052] = &D00052;
  core[000053] = 06724; code[000053] = &P00053;
  core[000054] = 00000; code[000054] = &P00054;
  core[000055] = 00000; code[000055] = &P00055;
  core[000056] = 00000; code[000056] = &D00056;
  core[000057] = 07760; code[000057] = &P00057;
  core[000060] = 03760; code[000060] = &P00060;
  core[000061] = 01354; code[000061] = &P00061;
  core[000062] = 02414; code[000062] = &P00062;
  core[000063] = 02676; code[000063] = &P00063;
  core[000064] = 02666; code[000064] = &P00064;
  core[000065] = 00001; code[000065] = &P00065;
  core[000066] = 00215; code[000066] = &P00066;
  core[000067] = 00000; code[000067] = &D00067;
  core[000070] = 00005; code[000070] = &D00070;
  core[000071] = 00000; code[000071] = &P00071;
  core[000072] = 00214; code[000072] = &I00072;
  core[000073] = 00207; code[000073] = &D00073;
  core[000074] = 00203; code[000074] = &P00074;
  core[000075] = 00337; code[000075] = &D00075;
  core[000076] = 00212; code[000076] = &P00076;
  core[000077] = 00215; code[000077] = &P00077;
  core[000100] = 07402; code[000100] = &P00100;
  core[000101] = 07700; code[000101] = &P00101;
  core[000102] = 00256; code[000102] = &P00102;
  core[000103] = 07701; code[000103] = &D00103;
  core[000104] = 07600; code[000104] = &P00104;
  core[000105] = 07760; code[000105] = &D00105;
  core[000106] = 00177; code[000106] = &D00106;
  core[000107] = 00017; code[000107] = &P00107;
  core[000110] = 00277; code[000110] = &D00110;
  core[000111] = 07776; code[000111] = &D00111;
  core[000112] = 07477; code[000112] = &D00112;
  core[000113] = 00260; code[000113] = &D00113;
  core[000114] = 07540; code[000114] = &P00114;
  core[000115] = 07522; code[000115] = &P00115;
  core[000116] = 07563; code[000116] = &D00116;
  core[000117] = 07775; code[000117] = &P00117;
  core[000120] = 07773; code[000120] = &P00120;
  core[000121] = 07767; code[000121] = &P00121;
  core[000122] = 00077; code[000122] = &P00122;
  core[000123] = 00200; code[000123] = &P00123;
  core[000124] = 04000; code[000124] = &P00124;
  core[000125] = 02030; code[000125] = &P00125;
  core[000126] = 02155; code[000126] = &P00126;
  core[000127] = 05715; code[000127] = &P00127;
  core[000130] = 06000; code[000130] = &P00130;
  core[000131] = 06200; code[000131] = &P00131;
  core[000132] = 03140; code[000132] = &P00132;
  core[000133] = 03206; code[000133] = &P00133;
  core[000134] = 03140; code[000134] = &P00134;
  core[000135] = 03217; code[000135] = &P00135;
  core[000136] = 02017; code[000136] = &P00136;
  core[000137] = 02407; code[000137] = &D00137;
  core[000140] = 00521; code[000140] = &P00140;
  core[000141] = 01565; code[000141] = &P00141;
  core[000142] = 00477; code[000142] = &P00142;
  core[000143] = 00534; code[000143] = &P00143;
  core[000144] = 00554; code[000144] = &P00144;
  core[000145] = 02274; code[000145] = &P00145;
  core[000146] = 02502; code[000146] = &P00146;
  core[000147] = 01314; code[000147] = &P00147;
  core[000150] = 00721; code[000150] = &P00150;
  core[000151] = 02465; code[000151] = &P00151;
  core[000152] = 02155; code[000152] = &P00152;
  core[000153] = 02425; code[000153] = &P00153;
  core[000154] = 00302; code[000154] = &P00154;
  core[000155] = 02242; code[000155] = &P00155;
  core[000156] = 02360; code[000156] = &P00156;
  core[000157] = 00413; code[000157] = &P00157;
  core[000160] = 01517; code[000160] = &P00160;
  core[000161] = 01533; code[000161] = &P00161;
  core[000162] = 02035; code[000162] = &P00162;
  core[000163] = 00744; code[000163] = &P00163;
  core[000164] = 00700; code[000164] = &P00164;
  core[000165] = 02062; code[000165] = &P00165;
  core[000166] = 02726; code[000166] = &P00166;
  core[000176] = 04371; code[000176] = &P00176;
  core[000177] = 07610; code[000177] = &L00177;
  core[000200] = 05576; code[000200] = &P00200;
  core[000201] = 01137; code[000201] = &I00201;
  core[000202] = 03022; code[000202] = &I00202;
  core[000203] = 07001; code[000203] = &D00203;
  core[000204] = 03100; code[000204] = &I00204;
  core[000205] = 03026; code[000205] = &I00205;
  core[000206] = 01226; code[000206] = &I00206;
  core[000207] = 03013; code[000207] = &I00207;
  core[000210] = 01225; code[000210] = &I00210;
  core[000211] = 04551; code[000211] = &P00211;
  core[000212] = 01132; code[000212] = &L00212;
  core[000213] = 03010; code[000213] = &I00213;
  core[000214] = 03062; code[000214] = &I00214;
  core[000215] = 01132; code[000215] = &D00215;
  core[000216] = 03027; code[000216] = &I00216;
  core[000217] = 04552; code[000217] = &L00217;
  core[000220] = 04547; code[000220] = &D00220;
  core[000221] = 00073; code[000221] = &I00221;
  core[000222] = 00474; code[000222] = &I00222;
  core[000223] = 04546; code[000223] = &I00223;
  core[000224] = 05217; code[000224] = &I00224;
  core[000225] = 00252; code[000225] = &D00225;
  core[000226] = 03220; code[000226] = &D00226;
  core[000227] = 04546; code[000227] = &I00227;
  core[000230] = 04546; code[000230] = &I00230;
  core[000231] = 01132; code[000231] = &I00231;
  core[000232] = 03017; code[000232] = &L00232;
  core[000233] = 03020; code[000233] = &I00233;
  core[000234] = 04545; code[000234] = &I00234;
  core[000235] = 01035; code[000235] = &I00235;
  core[000236] = 03013; code[000236] = &I00236;
  core[000237] = 04560; code[000237] = &I00237;
  core[000240] = 04561; code[000240] = &I00240;
  core[000241] = 05362; code[000241] = &I00241;
  core[000242] = 05271; code[000242] = &D00242;
  core[000243] = 02026; code[000243] = &I00243;
  core[000244] = 04554; code[000244] = &I00244;
  core[000245] = 01124; code[000245] = &I00245;
  core[000246] = 01065; code[000246] = &I00246;
  core[000247] = 07640; code[000247] = &I00247;
  core[000250] = 04566; code[000250] = &I00250;
  core[000251] = 01060; code[000251] = &I00251;
  core[000252] = 03010; code[000252] = &D00252;
  core[000253] = 03062; code[000253] = &I00253;
  core[000254] = 01067; code[000254] = &I00254;
  core[000255] = 03410; code[000255] = &I00255;
  core[000256] = 04560; code[000256] = &D00256;
  core[000257] = 07410; code[000257] = &I00257;
  core[000260] = 04545; code[000260] = &L00260;
  core[000261] = 04546; code[000261] = &I00261;
  core[000262] = 01066; code[000262] = &I00262;
  core[000263] = 01116; code[000263] = &I00263;
  core[000264] = 07640; code[000264] = &I00264;
  core[000265] = 05260; code[000265] = &I00265;
  core[000266] = 04565; code[000266] = &I00266;
  core[000267] = 04556; code[000267] = &I00267;
  core[000270] = 05177; code[000270] = &I00270;
  core[000271] = 04540; code[000271] = &L00271;
  core[000272] = 00611; code[000272] = &I00272;
  core[000273] = 01422; code[000273] = &D00273;
  core[000274] = 07450; code[000274] = &I00274;
  core[000275] = 05177; code[000275] = &I00275;
  core[000276] = 03022; code[000276] = &I00276;
  core[000277] = 01022; code[000277] = &I00277;
  core[000300] = 07001; code[000300] = &I00300;
  core[000301] = 05232; code[000301] = &I00301;
  core[000302] = 00000; code[000302] = &S00302;
  core[000303] = 04560; code[000303] = &D00303;
  core[000304] = 01066; code[000304] = &I00304;
  core[000305] = 01112; code[000305] = &I00305;
  core[000306] = 07650; code[000306] = &I00306;
  core[000307] = 05322; code[000307] = &I00307;
  core[000310] = 03036; code[000310] = &I00310;
  core[000311] = 04771; code[000311] = &I00311;
  core[000312] = 01047; code[000312] = &I00312;
  core[000313] = 00372; code[000313] = &I00313;
  core[000314] = 01046; code[000314] = &I00314;
  core[000315] = 07640; code[000315] = &I00315;
  core[000316] = 04566; code[000316] = &I00316;
  core[000317] = 01047; code[000317] = &I00317;
  core[000320] = 04557; code[000320] = &I00320;
  core[000321] = 07004; code[000321] = &D00321;
  core[000322] = 03067; code[000322] = &L00322;
  core[000323] = 04561; code[000323] = &I00323;
  core[000324] = 04545; code[000324] = &D00324;
  core[000325] = 04561; code[000325] = &I00325;
  core[000326] = 05340; code[000326] = &I00326;
  core[000327] = 05352; code[000327] = &I00327;
  core[000330] = 01054; code[000330] = &I00330;
  core[000331] = 07106; code[000331] = &I00331;
  core[000332] = 01054; code[000332] = &I00332;
  core[000333] = 07004; code[000333] = &I00333;
  core[000334] = 01067; code[000334] = &I00334;
  core[000335] = 03067; code[000335] = &I00335;
  core[000336] = 04545; code[000336] = &I00336;
  core[000337] = 04561; code[000337] = &I00337;
  core[000340] = 04566; code[000340] = &L00340;
  core[000341] = 05352; code[000341] = &I00341;
  core[000342] = 01054; code[000342] = &I00342;
  core[000343] = 01067; code[000343] = &I00343;
  core[000344] = 03067; code[000344] = &I00344;
  core[000345] = 04545; code[000345] = &I00345;
  core[000346] = 04561; code[000346] = &I00346;
  core[000347] = 05340; code[000347] = &I00347;
  core[000350] = 07410; code[000350] = &I00350;
  core[000351] = 04566; code[000351] = &I00351;
  core[000352] = 07100; code[000352] = &L00352;
  core[000353] = 01067; code[000353] = &I00353;
  core[000354] = 00104; code[000354] = &I00354;
  core[000355] = 07640; code[000355] = &I00355;
  core[000356] = 07020; code[000356] = &I00356;
  core[000357] = 01067; code[000357] = &I00357;
  core[000360] = 00106; code[000360] = &I00360;
  core[000361] = 07460; code[000361] = &I00361;
  core[000362] = 04566; code[000362] = &L00362;
  core[000363] = 07640; code[000363] = &I00363;
  core[000364] = 01373; code[000364] = &I00364;
  core[000365] = 07020; code[000365] = &I00365;
  core[000366] = 07004; code[000366] = &I00366;
  core[000367] = 03065; code[000367] = &I00367;
  core[000370] = 05702; code[000370] = &I00370;
  core[000371] = 05600; code[000371] = &P00371;
  core[000372] = 07740; code[000372] = &D00372;
  core[000373] = 02000; code[000373] = &D00373;
  core[000374] = 02014; code[000374] = &I00374;
  core[000375] = 02010; code[000375] = &I00375;
  core[000376] = 01160; code[000376] = &I00376;
  core[000377] = 01142; code[000377] = &I00377;
  core[000400] = 01553; code[000400] = &L00400;
  core[000401] = 01343; code[000401] = &I00401;
  core[000402] = 05000; code[000402] = &I00402;
  core[000403] = 04620; code[000403] = &I00403;
  core[000404] = 05040; code[000404] = &I00404;
  core[000405] = 05205; code[000405] = &L00405;
  core[000406] = 05200; code[000406] = &P00406;
  core[000407] = 07400; code[000407] = &I00407;
  core[000410] = 02725; code[000410] = &P00410;
  core[000411] = 02725; code[000411] = &P00411;
  core[000412] = 02725; code[000412] = &D00412;
  core[000413] = 00000; code[000413] = &S00413;
  core[000414] = 07106; code[000414] = &I00414;
  core[000415] = 07006; code[000415] = &I00415;
  core[000416] = 07006; code[000416] = &I00416;
  core[000417] = 05613; code[000417] = &L00417;
  core[000420] = 04554; code[000420] = &P00420;
  core[000421] = 01022; code[000421] = &I00421;
  core[000422] = 04542; code[000422] = &I00422;
  core[000423] = 04543; code[000423] = &I00423;
  core[000424] = 00017; code[000424] = &I00424;
  core[000425] = 04543; code[000425] = &L00425;
  core[000426] = 00065; code[000426] = &I00426;
  core[000427] = 01065; code[000427] = &D00427;
  core[000430] = 07710; code[000430] = &I00430;
  core[000431] = 05263; code[000431] = &I00431;
  core[000432] = 04555; code[000432] = &I00432;
  core[000433] = 07000; code[000433] = &I00433;
  core[000434] = 01023; code[000434] = &I00434;
  core[000435] = 03011; code[000435] = &I00435;
  core[000436] = 01411; code[000436] = &I00436;
  core[000437] = 04563; code[000437] = &I00437;
  core[000440] = 04566; code[000440] = &I00440;
  core[000441] = 04540; code[000441] = &I00441;
  core[000442] = 00606; code[000442] = &I00442;
  core[000443] = 04544; code[000443] = &I00443;
  core[000444] = 00065; code[000444] = &I00444;
  core[000445] = 01422; code[000445] = &I00445;
  core[000446] = 07450; code[000446] = &I00446;
  core[000447] = 05271; code[000447] = &I00447;
  core[000450] = 07001; code[000450] = &I00450;
  core[000451] = 03030; code[000451] = &I00451;
  core[000452] = 01065; code[000452] = &I00452;
  core[000453] = 07740; code[000453] = &I00453;
  core[000454] = 05260; code[000454] = &I00454;
  core[000455] = 01430; code[000455] = &I00455;
  core[000456] = 04563; code[000456] = &I00456;
  core[000457] = 05271; code[000457] = &I00457;
  core[000460] = 01430; code[000460] = &L00460;
  core[000461] = 03067; code[000461] = &I00461;
  core[000462] = 05225; code[000462] = &I00462;
  core[000463] = 04555; code[000463] = &L00463;
  core[000464] = 04566; code[000464] = &I00464;
  core[000465] = 04540; code[000465] = &I00465;
  core[000466] = 00610; code[000466] = &I00466;
  core[000467] = 04544; code[000467] = &I00467;
  core[000470] = 00065; code[000470] = &I00470;
  core[000471] = 04544; code[000471] = &L00471;
  core[000472] = 00017; code[000472] = &I00472;
  core[000473] = 01413; code[000473] = &I00473;
  core[000474] = 03022; code[000474] = &I00474;
  core[000475] = 05676; code[000475] = &I00475;
  core[000476] = 00611; code[000476] = &P00476;
  core[000477] = 00000; code[000477] = &S00477;
  core[000500] = 03071; code[000500] = &I00500;
  core[000501] = 07040; code[000501] = &I00501;
  core[000502] = 04310; code[000502] = &I00502;
  core[000503] = 01071; code[000503] = &I00503;
  core[000504] = 03413; code[000504] = &I00504;
  core[000505] = 07040; code[000505] = &I00505;
  core[000506] = 04310; code[000506] = &I00506;
  core[000507] = 05677; code[000507] = &I00507;
  core[000510] = 00000; code[000510] = &S00510;
  core[000511] = 01013; code[000511] = &I00511;
  core[000512] = 03013; code[000512] = &I00512;
  core[000513] = 01013; code[000513] = &I00513;
  core[000514] = 07141; code[000514] = &I00514;
  core[000515] = 01031; code[000515] = &I00515;
  core[000516] = 07630; code[000516] = &I00516;
  core[000517] = 04566; code[000517] = &I00517;
  core[000520] = 05710; code[000520] = &I00520;
  core[000521] = 00000; code[000521] = &P00521;
  core[000522] = 01721; code[000522] = &I00522;
  core[000523] = 03071; code[000523] = &I00523;
  core[000524] = 07040; code[000524] = &I00524;
  core[000525] = 04310; code[000525] = &P00525;
  core[000526] = 01321; code[000526] = &I00526;
  core[000527] = 07001; code[000527] = &I00527;
  core[000530] = 03413; code[000530] = &I00530;
  core[000531] = 07040; code[000531] = &I00531;
  core[000532] = 04310; code[000532] = &I00532;
  core[000533] = 05471; code[000533] = &I00533;
  core[000534] = 00000; code[000534] = &S00534;
  core[000535] = 07240; code[000535] = &I00535;
  core[000536] = 01734; code[000536] = &I00536;
  core[000537] = 03011; code[000537] = &I00537;
  core[000540] = 02334; code[000540] = &P00540;
  core[000541] = 01117; code[000541] = &I00541;
  core[000542] = 04310; code[000542] = &I00542;
  core[000543] = 01117; code[000543] = &D00543;
  core[000544] = 03071; code[000544] = &I00544;
  core[000545] = 01411; code[000545] = &L00545;
  core[000546] = 03413; code[000546] = &I00546;
  core[000547] = 02071; code[000547] = &I00547;
  core[000550] = 05345; code[000550] = &I00550;
  core[000551] = 01117; code[000551] = &I00551;
  core[000552] = 04310; code[000552] = &I00552;
  core[000553] = 05734; code[000553] = &I00553;
  core[000554] = 00000; code[000554] = &S00554;
  core[000555] = 07240; code[000555] = &I00555;
  core[000556] = 01754; code[000556] = &I00556;
  core[000557] = 02354; code[000557] = &I00557;
  core[000560] = 03011; code[000560] = &I00560;
  core[000561] = 01117; code[000561] = &I00561;
  core[000562] = 03071; code[000562] = &I00562;
  core[000563] = 01413; code[000563] = &L00563;
  core[000564] = 03411; code[000564] = &I00564;
  core[000565] = 02071; code[000565] = &I00565;
  core[000566] = 05363; code[000566] = &I00566;
  core[000567] = 05754; code[000567] = &I00567;
  core[000570] = 02740; code[000570] = &I00570;
  core[000571] = 00212; code[000571] = &I00571;
  core[000572] = 00217; code[000572] = &I00572;
  core[000573] = 00227; code[000573] = &I00573;
  core[000574] = 01075; code[000574] = &I00574;
  core[000575] = 01137; code[000575] = &I00575;
  core[000576] = 02725; code[000576] = &I00576;
  core[000577] = 01065; code[000577] = &I00577;
  core[000600] = 00610; code[000600] = &I00600;
  core[000601] = 00614; code[000601] = &I00601;
  core[000602] = 07472; code[000602] = &D00602;
  core[000603] = 04554; code[000603] = &L00603;
  core[000604] = 04555; code[000604] = &I00604;
  core[000605] = 04566; code[000605] = &I00605;
  core[000606] = 01023; code[000606] = &I00606;
  core[000607] = 03022; code[000607] = &I00607;
  core[000610] = 04545; code[000610] = &P00610;
  core[000611] = 01066; code[000611] = &L00611;
  core[000612] = 01116; code[000612] = &I00612;
  core[000613] = 07650; code[000613] = &I00613;
  core[000614] = 05541; code[000614] = &P00614;
  core[000615] = 04550; code[000615] = &I00615;
  core[000616] = 01376; code[000616] = &I00616;
  core[000617] = 05210; code[000617] = &I00617;
  core[000620] = 01066; code[000620] = &I00620;
  core[000621] = 00075; code[000621] = &I00621;
  core[000622] = 04542; code[000622] = &I00622;
  core[000623] = 04545; code[000623] = &L00623;
  core[000624] = 04550; code[000624] = &I00624;
  core[000625] = 01376; code[000625] = &I00625;
  core[000626] = 07410; code[000626] = &I00626;
  core[000627] = 05223; code[000627] = &I00627;
  core[000630] = 01413; code[000630] = &I00630;
  core[000631] = 04547; code[000631] = &I00631;
  core[000632] = 00773; code[000632] = &I00632;
  core[000633] = 00167; code[000633] = &I00633;
  core[000634] = 04566; code[000634] = &I00634;
  core[000635] = 04554; code[000635] = &I00635;
  core[000636] = 02026; code[000636] = &I00636;
  core[000637] = 04555; code[000637] = &L00637;
  core[000640] = 05267; code[000640] = &I00640;
  core[000641] = 01067; code[000641] = &I00641;
  core[000642] = 07640; code[000642] = &I00642;
  core[000643] = 04553; code[000643] = &I00643;
  core[000644] = 04545; code[000644] = &L00644;
  core[000645] = 04551; code[000645] = &I00645;
  core[000646] = 01066; code[000646] = &I00646;
  core[000647] = 01116; code[000647] = &I00647;
  core[000650] = 07640; code[000650] = &I00650;
  core[000651] = 05244; code[000651] = &I00651;
  core[000652] = 01423; code[000652] = &I00652;
  core[000653] = 07450; code[000653] = &L00653;
  core[000654] = 05271; code[000654] = &I00654;
  core[000655] = 07001; code[000655] = &I00655;
  core[000656] = 03030; code[000656] = &I00656;
  core[000657] = 01065; code[000657] = &I00657;
  core[000660] = 07700; code[000660] = &I00660;
  core[000661] = 01430; code[000661] = &I00661;
  core[000662] = 04563; code[000662] = &I00662;
  core[000663] = 05273; code[000663] = &I00663;
  core[000664] = 01430; code[000664] = &L00664;
  core[000665] = 03067; code[000665] = &I00665;
  core[000666] = 05237; code[000666] = &I00666;
  core[000667] = 01023; code[000667] = &L00667;
  core[000670] = 05253; code[000670] = &I00670;
  core[000671] = 03026; code[000671] = &L00671;
  core[000672] = 05541; code[000672] = &I00672;
  core[000673] = 01065; code[000673] = &L00673;
  core[000674] = 07750; code[000674] = &I00674;
  core[000675] = 05271; code[000675] = &I00675;
  core[000676] = 04551; code[000676] = &I00676;
  core[000677] = 05264; code[000677] = &I00677;
  core[000700] = 00000; code[000700] = &S00700;
  core[000701] = 04560; code[000701] = &I00701;
  core[000702] = 04550; code[000702] = &I00702;
  core[000703] = 01767; code[000703] = &I00703;
  core[000704] = 05700; code[000704] = &D00704;
  core[000705] = 01066; code[000705] = &I00705;
  core[000706] = 02300; code[000706] = &D00706;
  core[000707] = 01202; code[000707] = &I00707;
  core[000710] = 07650; code[000710] = &I00710;
  core[000711] = 05317; code[000711] = &D00711;
  core[000712] = 04561; code[000712] = &I00712;
  core[000713] = 05700; code[000713] = &I00713;
  core[000714] = 07410; code[000714] = &I00714;
  core[000715] = 05700; code[000715] = &I00715;
  core[000716] = 02300; code[000716] = &I00716;
  core[000717] = 02300; code[000717] = &L00717;
  core[000720] = 05700; code[000720] = &I00720;
  core[000721] = 00000; code[000721] = &S00721;
  core[000722] = 01721; code[000722] = &I00722;
  core[000723] = 03012; code[000723] = &D00723;
  core[000724] = 01412; code[000724] = &L00724;
  core[000725] = 07510; code[000725] = &I00725;
  core[000726] = 05340; code[000726] = &I00726;
  core[000727] = 07041; code[000727] = &I00727;
  core[000730] = 01066; code[000730] = &I00730;
  core[000731] = 07640; code[000731] = &I00731;
  core[000732] = 05324; code[000732] = &I00732;
  core[000733] = 01721; code[000733] = &I00733;
  core[000734] = 07040; code[000734] = &I00734;
  core[000735] = 01012; code[000735] = &I00735;
  core[000736] = 03054; code[000736] = &I00736;
  core[000737] = 07410; code[000737] = &I00737;
  core[000740] = 02321; code[000740] = &L00740;
  core[000741] = 02321; code[000741] = &I00741;
  core[000742] = 07300; code[000742] = &I00742;
  core[000743] = 05721; code[000743] = &I00743;
  core[000744] = 00000; code[000744] = &S00744;
  core[000745] = 00104; code[000745] = &I00745;
  core[000746] = 07041; code[000746] = &I00746;
  core[000747] = 03071; code[000747] = &I00747;
  core[000750] = 01067; code[000750] = &I00750;
  core[000751] = 00104; code[000751] = &I00751;
  core[000752] = 01071; code[000752] = &I00752;
  core[000753] = 07650; code[000753] = &I00753;
  core[000754] = 02344; code[000754] = &I00754;
  core[000755] = 05744; code[000755] = &I00755;
  core[000756] = 00000; code[000756] = &S00756;
  core[000757] = 01036; code[000757] = &I00757;
  core[000760] = 07640; code[000760] = &I00760;
  core[000761] = 05364; code[000761] = &I00761;
  core[000762] = 04545; code[000762] = &I00762;
  core[000763] = 05756; code[000763] = &I00763;
  core[000764] = 04552; code[000764] = &L00764;
  core[000765] = 04547; code[000765] = &I00765;
  core[000766] = 06776; code[000766] = &I00766;
  core[000767] = 03402; code[000767] = &P00767;
  core[000770] = 05756; code[000770] = &I00770;
  core[000771] = 01035; code[000771] = &I00771;
  core[000772] = 00610; code[000772] = &I00772;
  core[000773] = 00614; code[000773] = &P00773;
  core[000774] = 00323; code[000774] = &I00774;
  core[000775] = 00306; code[000775] = &I00775;
  core[000776] = 00311; code[000776] = &D00776;
  core[000777] = 00304; code[000777] = &I00777;
  core[001000] = 00307; code[001000] = &I01000;
  core[001001] = 00303; code[001001] = &P01001;
  core[001002] = 00301; code[001002] = &D01002;
  core[001003] = 00324; code[001003] = &P01003;
  core[001004] = 00314; code[001004] = &D01004;
  core[001005] = 00305; code[001005] = &I01005;
  core[001006] = 00327; code[001006] = &I01006;
  core[001007] = 00315; code[001007] = &I01007;
  core[001010] = 00321; code[001010] = &P01010;
  core[001011] = 00322; code[001011] = &I01011;
  core[001012] = 00212; code[001012] = &P01012;
  core[001013] = 04564; code[001013] = &I01013;
  core[001014] = 04637; code[001014] = &P01014;
  core[001015] = 02013; code[001015] = &I01015;
  core[001016] = 04640; code[001016] = &I01016;
  core[001017] = 01111; code[001017] = &I01017;
  core[001020] = 03032; code[001020] = &I01020;
  core[001021] = 01045; code[001021] = &I01021;
  core[001022] = 07510; code[001022] = &I01022;
  core[001023] = 02032; code[001023] = &I01023;
  core[001024] = 07750; code[001024] = &I01024;
  core[001025] = 02032; code[001025] = &L01025;
  core[001026] = 07410; code[001026] = &I01026;
  core[001027] = 05767; code[001027] = &I01027;
  core[001030] = 04547; code[001030] = &L01030;
  core[001031] = 01377; code[001031] = &I01031;
  core[001032] = 07371; code[001032] = &I01032;
  core[001033] = 04545; code[001033] = &I01033;
  core[001034] = 05230; code[001034] = &I01034;
  core[001035] = 04545; code[001035] = &P01035;
  core[001036] = 05225; code[001036] = &I01036;
  core[001037] = 01601; code[001037] = &P01037;
  core[001040] = 02047; code[001040] = &P01040;
  core[001041] = 04540; code[001041] = &D01041;
  core[001042] = 01403; code[001042] = &I01042;
  core[001043] = 04560; code[001043] = &I01043;
  core[001044] = 01066; code[001044] = &I01044;
  core[001045] = 01335; code[001045] = &I01045;
  core[001046] = 07440; code[001046] = &I01046;
  core[001047] = 04566; code[001047] = &I01047;
  core[001050] = 01030; code[001050] = &I01050;
  core[001051] = 04542; code[001051] = &I01051;
  core[001052] = 04540; code[001052] = &I01052;
  core[001053] = 01612; code[001053] = &I01053;
  core[001054] = 01413; code[001054] = &D01054;
  core[001055] = 03030; code[001055] = &I01055;
  core[001056] = 04407; code[001056] = &D01056;
  core[001057] = 06430; code[001057] = &I01057;
  core[001060] = 00000; code[001060] = &I01060;
  core[001061] = 04547; code[001061] = &I01061;
  core[001062] = 01377; code[001062] = &I01062;
  core[001063] = 07177; code[001063] = &I01063;
  core[001064] = 04566; code[001064] = &I01064;
  core[001065] = 01030; code[001065] = &I01065;
  core[001066] = 04542; code[001066] = &I01066;
  core[001067] = 04540; code[001067] = &I01067;
  core[001070] = 01612; code[001070] = &I01070;
  core[001071] = 04547; code[001071] = &I01071;
  core[001072] = 01377; code[001072] = &I01072;
  core[001073] = 07174; code[001073] = &I01073;
  core[001074] = 04566; code[001074] = &I01074;
  core[001075] = 04543; code[001075] = &I01075;
  core[001076] = 02030; code[001076] = &I01076;
  core[001077] = 04540; code[001077] = &I01077;
  core[001100] = 01612; code[001100] = &I01100;
  core[001101] = 04543; code[001101] = &L01101;
  core[001102] = 02030; code[001102] = &I01102;
  core[001103] = 04543; code[001103] = &D01103;
  core[001104] = 00017; code[001104] = &I01104;
  core[001105] = 04540; code[001105] = &D01105;
  core[001106] = 00610; code[001106] = &D01106;
  core[001107] = 04544; code[001107] = &D01107;
  core[001110] = 00017; code[001110] = &I01110;
  core[001111] = 04544; code[001111] = &I01111;
  core[001112] = 02030; code[001112] = &I01112;
  core[001113] = 04544; code[001113] = &I01113;
  core[001114] = 07470; code[001114] = &D01114;
  core[001115] = 01413; code[001115] = &D01115;
  core[001116] = 03030; code[001116] = &I01116;
  core[001117] = 04407; code[001117] = &I01117;
  core[001120] = 00430; code[001120] = &I01120;
  core[001121] = 01733; code[001121] = &D01121;
  core[001122] = 06430; code[001122] = &D01122;
  core[001123] = 02525; code[001123] = &I01123;
  core[001124] = 00000; code[001124] = &D01124;
  core[001125] = 01045; code[001125] = &D01125;
  core[001126] = 07740; code[001126] = &D01126;
  core[001127] = 05541; code[001127] = &D01127;
  core[001130] = 01030; code[001130] = &I01130;
  core[001131] = 04542; code[001131] = &I01131;
  core[001132] = 04543; code[001132] = &I01132;
  core[001133] = 07470; code[001133] = &P01133;
  core[001134] = 05301; code[001134] = &I01134;
  core[001135] = 07503; code[001135] = &D01135;
  core[001136] = 07524; code[001136] = &D01136;
  core[001137] = 04543; code[001137] = &I01137;
  core[001140] = 02405; code[001140] = &I01140;
  core[001141] = 05301; code[001141] = &I01141;
  core[001142] = 04453; code[001142] = &I01142;
  core[001143] = 04542; code[001143] = &I01143;
  core[001144] = 01066; code[001144] = &I01144;
  core[001145] = 01336; code[001145] = &I01145;
  core[001146] = 07640; code[001146] = &I01146;
  core[001147] = 04566; code[001147] = &I01147;
  core[001150] = 04540; code[001150] = &I01150;
  core[001151] = 01612; code[001151] = &I01151;
  core[001152] = 04453; code[001152] = &I01152;
  core[001153] = 06063; code[001153] = &D01153;
  core[001154] = 07200; code[001154] = &I01154;
  core[001155] = 01413; code[001155] = &I01155;
  core[001156] = 06057; code[001156] = &D01156;
  core[001157] = 07410; code[001157] = &I01157;
  core[001160] = 04453; code[001160] = &I01160;
  core[001161] = 07200; code[001161] = &I01161;
  core[001162] = 05536; code[001162] = &I01162;
  core[001163] = 01041; code[001163] = &I01163;
  core[001164] = 01041; code[001164] = &I01164;
  core[001165] = 01013; code[001165] = &I01165;
  core[001166] = 00420; code[001166] = &I01166;
  core[001167] = 00603; code[001167] = &P01167;
  core[001170] = 00614; code[001170] = &I01170;
  core[001171] = 01202; code[001171] = &I01171;
  core[001172] = 01203; code[001172] = &I01172;
  core[001173] = 07503; code[001173] = &I01173;
  core[001174] = 02204; code[001174] = &I01174;
  core[001175] = 00635; code[001175] = &I01175;
  core[001176] = 01256; code[001176] = &I01176;
  core[001177] = 00177; code[001177] = &D01177;
  core[001200] = 01563; code[001200] = &I01200;
  core[001201] = 06361; code[001201] = &I01201;
  core[001202] = 07240; code[001202] = &L01202;
  core[001203] = 03056; code[001203] = &L01203;
  core[001204] = 03026; code[001204] = &L01204;
  core[001205] = 04547; code[001205] = &I01205;
  core[001206] = 01371; code[001206] = &I01206;
  core[001207] = 00176; code[001207] = &I01207;
  core[001210] = 02056; code[001210] = &I01210;
  core[001211] = 05226; code[001211] = &I01211;
  core[001212] = 04540; code[001212] = &I01212;
  core[001213] = 01403; code[001213] = &P01213;
  core[001214] = 01066; code[001214] = &I01214;
  core[001215] = 04542; code[001215] = &I01215;
  core[001216] = 01255; code[001216] = &I01216;
  core[001217] = 04551; code[001217] = &I01217;
  core[001220] = 02036; code[001220] = &I01220;
  core[001221] = 07001; code[001221] = &I01221;
  core[001222] = 04531; code[001222] = &I01222;
  core[001223] = 01413; code[001223] = &I01223;
  core[001224] = 03066; code[001224] = &I01224;
  core[001225] = 05202; code[001225] = &I01225;
  core[001226] = 04540; code[001226] = &L01226;
  core[001227] = 01613; code[001227] = &I01227;
  core[001230] = 04530; code[001230] = &I01230;
  core[001231] = 05203; code[001231] = &I01231;
  core[001232] = 02026; code[001232] = &I01232;
  core[001233] = 04545; code[001233] = &L01233;
  core[001234] = 04547; code[001234] = &I01234;
  core[001235] = 01403; code[001235] = &I01235;
  core[001236] = 00773; code[001236] = &I01236;
  core[001237] = 04551; code[001237] = &I01237;
  core[001240] = 05233; code[001240] = &D01240;
  core[001241] = 04545; code[001241] = &D01241;
  core[001242] = 04554; code[001242] = &D01242;
  core[001243] = 01067; code[001243] = &D01243;
  core[001244] = 03052; code[001244] = &D01244;
  core[001245] = 05204; code[001245] = &D01245;
  core[001246] = 01077; code[001246] = &I01246;
  core[001247] = 04463; code[001247] = &I01247;
  core[001250] = 07040; code[001250] = &I01250;
  core[001251] = 01077; code[001251] = &I01251;
  core[001252] = 04551; code[001252] = &I01252;
  core[001253] = 04545; code[001253] = &I01253;
  core[001254] = 05204; code[001254] = &I01254;
  core[001255] = 00272; code[001255] = &D01255;
  core[001256] = 04554; code[001256] = &I01256;
  core[001257] = 04555; code[001257] = &I01257;
  core[001260] = 04566; code[001260] = &I01260;
  core[001261] = 01060; code[001261] = &D01261;
  core[001262] = 03010; code[001262] = &I01262;
  core[001263] = 03062; code[001263] = &I01263;
  core[001264] = 01067; code[001264] = &I01264;
  core[001265] = 03410; code[001265] = &I01265;
  core[001266] = 01010; code[001266] = &I01266;
  core[001267] = 03027; code[001267] = &I01267;
  core[001270] = 04464; code[001270] = &D01270;
  core[001271] = 03100; code[001271] = &D01271;
  core[001272] = 02026; code[001272] = &D01272;
  core[001273] = 04545; code[001273] = &L01273;
  core[001274] = 04551; code[001274] = &I01274;
  core[001275] = 04547; code[001275] = &I01275;
  core[001276] = 00076; code[001276] = &I01276;
  core[001277] = 01271; code[001277] = &I01277;
  core[001300] = 04546; code[001300] = &I01300;
  core[001301] = 05273; code[001301] = &I01301;
  core[001302] = 01060; code[001302] = &D01302;
  core[001303] = 07001; code[001303] = &I01303;
  core[001304] = 03010; code[001304] = &I01304;
  core[001305] = 03062; code[001305] = &I01305;
  core[001306] = 04552; code[001306] = &L01306;
  core[001307] = 04547; code[001307] = &I01307;
  core[001310] = 00071; code[001310] = &I01310;
  core[001311] = 01271; code[001311] = &I01311;
  core[001312] = 04546; code[001312] = &D01312;
  core[001313] = 05306; code[001313] = &I01313;
  core[001314] = 00000; code[001314] = &S01314;
  core[001315] = 07450; code[001315] = &I01315;
  core[001316] = 01066; code[001316] = &I01316;
  core[001317] = 07041; code[001317] = &I01317;
  core[001320] = 03071; code[001320] = &I01320;
  core[001321] = 01714; code[001321] = &I01321;
  core[001322] = 02314; code[001322] = &I01322;
  core[001323] = 03012; code[001323] = &I01323;
  core[001324] = 01412; code[001324] = &L01324;
  core[001325] = 07510; code[001325] = &I01325;
  core[001326] = 05340; code[001326] = &I01326;
  core[001327] = 01071; code[001327] = &I01327;
  core[001330] = 07640; code[001330] = &I01330;
  core[001331] = 05324; code[001331] = &I01331;
  core[001332] = 01012; code[001332] = &I01332;
  core[001333] = 01714; code[001333] = &I01333;
  core[001334] = 03071; code[001334] = &I01334;
  core[001335] = 01471; code[001335] = &I01335;
  core[001336] = 03071; code[001336] = &L01336;
  core[001337] = 05471; code[001337] = &I01337;
  core[001340] = 02314; code[001340] = &P01340;
  core[001341] = 07300; code[001341] = &I01341;
  core[001342] = 05714; code[001342] = &I01342;
  core[001343] = 04453; code[001343] = &I01343;
  core[001344] = 07000; code[001344] = &I01344;
  core[001345] = 06375; code[001345] = &I01345;
  core[001346] = 06332; code[001346] = &L01346;
  core[001347] = 05346; code[001347] = &I01347;
  core[001350] = 06362; code[001350] = &I01350;
  core[001351] = 03046; code[001351] = &I01351;
  core[001352] = 06001; code[001352] = &I01352;
  core[001353] = 05536; code[001353] = &I01353;
  core[001354] = 00000; code[001354] = &P01354;
  core[001355] = 06046; code[001355] = &I01355;
  core[001356] = 06026; code[001356] = &I01356;
  core[001357] = 06041; code[001357] = &L01357;
  core[001360] = 05357; code[001360] = &I01360;
  core[001361] = 07200; code[001361] = &I01361;
  core[001362] = 05754; code[001362] = &I01362;
  core[001363] = 01273; code[001363] = &I01363;
  core[001364] = 01270; code[001364] = &I01364;
  core[001365] = 02740; code[001365] = &I01365;
  core[001366] = 01302; code[001366] = &I01366;
  core[001367] = 01271; code[001367] = &I01367;
  core[001370] = 00261; code[001370] = &I01370;
  core[001371] = 01312; code[001371] = &D01371;
  core[001372] = 00245; code[001372] = &I01372;
  core[001373] = 00242; code[001373] = &P01373;
  core[001374] = 00241; code[001374] = &I01374;
  core[001375] = 00243; code[001375] = &I01375;
  core[001376] = 00244; code[001376] = &I01376;
  core[001377] = 00240; code[001377] = &I01377;
  core[001400] = 00254; code[001400] = &I01400;
  core[001401] = 00273; code[001401] = &P01401;
  core[001402] = 00215; code[001402] = &I01402;
  core[001403] = 04564; code[001403] = &D01403;
  core[001404] = 00242; code[001404] = &I01404;
  core[001405] = 00215; code[001405] = &I01405;
  core[001406] = 04566; code[001406] = &I01406;
  core[001407] = 03062; code[001407] = &I01407;
  core[001410] = 04546; code[001410] = &P01410;
  core[001411] = 04545; code[001411] = &I01411;
  core[001412] = 04550; code[001412] = &I01412;
  core[001413] = 01767; code[001413] = &D01413;
  core[001414] = 05226; code[001414] = &I01414;
  core[001415] = 01066; code[001415] = &D01415;
  core[001416] = 00122; code[001416] = &I01416;
  core[001417] = 01061; code[001417] = &I01417;
  core[001420] = 03061; code[001420] = &I01420;
  core[001421] = 04545; code[001421] = &L01421;
  core[001422] = 04550; code[001422] = &I01422;
  core[001423] = 01767; code[001423] = &D01423;
  core[001424] = 05226; code[001424] = &I01424;
  core[001425] = 05221; code[001425] = &I01425;
  core[001426] = 04562; code[001426] = &L01426;
  core[001427] = 05237; code[001427] = &I01427;
  core[001430] = 01061; code[001430] = &I01430;
  core[001431] = 03056; code[001431] = &I01431;
  core[001432] = 04660; code[001432] = &D01432;
  core[001433] = 01413; code[001433] = &I01433;
  core[001434] = 03061; code[001434] = &I01434;
  core[001435] = 04657; code[001435] = &I01435;
  core[001436] = 04453; code[001436] = &I01436;
  core[001437] = 03317; code[001437] = &L01437;
  core[001440] = 01060; code[001440] = &I01440;
  core[001441] = 03030; code[001441] = &L01441;
  core[001442] = 01030; code[001442] = &D01442;
  core[001443] = 07041; code[001443] = &I01443;
  core[001444] = 01031; code[001444] = &I01444;
  core[001445] = 07750; code[001445] = &I01445;
  core[001446] = 05261; code[001446] = &D01446;
  core[001447] = 01430; code[001447] = &I01447;
  core[001450] = 07041; code[001450] = &I01450;
  core[001451] = 01061; code[001451] = &D01451;
  core[001452] = 07650; code[001452] = &I01452;
  core[001453] = 05305; code[001453] = &D01453;
  core[001454] = 01030; code[001454] = &L01454;
  core[001455] = 01070; code[001455] = &I01455;
  core[001456] = 05241; code[001456] = &I01456;
  core[001457] = 02047; code[001457] = &P01457;
  core[001460] = 01601; code[001460] = &P01460;
  core[001461] = 01031; code[001461] = &L01461;
  core[001462] = 01005; code[001462] = &I01462;
  core[001463] = 07141; code[001463] = &I01463;
  core[001464] = 01013; code[001464] = &I01464;
  core[001465] = 07620; code[001465] = &I01465;
  core[001466] = 04566; code[001466] = &I01466;
  core[001467] = 01031; code[001467] = &I01467;
  core[001470] = 01070; code[001470] = &I01470;
  core[001471] = 03031; code[001471] = &I01471;
  core[001472] = 01061; code[001472] = &I01472;
  core[001473] = 03430; code[001473] = &D01473;
  core[001474] = 02030; code[001474] = &I01474;
  core[001475] = 01317; code[001475] = &I01475;
  core[001476] = 03430; code[001476] = &I01476;
  core[001477] = 02030; code[001477] = &I01477;
  core[001500] = 04407; code[001500] = &I01500;
  core[001501] = 00537; code[001501] = &I01501;
  core[001502] = 06430; code[001502] = &I01502;
  core[001503] = 00000; code[001503] = &I01503;
  core[001504] = 05541; code[001504] = &I01504;
  core[001505] = 01030; code[001505] = &L01505;
  core[001506] = 03011; code[001506] = &I01506;
  core[001507] = 01411; code[001507] = &I01507;
  core[001510] = 07041; code[001510] = &I01510;
  core[001511] = 01317; code[001511] = &I01511;
  core[001512] = 07640; code[001512] = &I01512;
  core[001513] = 05254; code[001513] = &I01513;
  core[001514] = 02030; code[001514] = &I01514;
  core[001515] = 02030; code[001515] = &I01515;
  core[001516] = 05541; code[001516] = &I01516;
  core[001517] = 00000; code[001517] = &S01517;
  core[001520] = 01066; code[001520] = &L01520;
  core[001521] = 01114; code[001521] = &I01521;
  core[001522] = 07640; code[001522] = &I01522;
  core[001523] = 05717; code[001523] = &I01523;
  core[001524] = 04545; code[001524] = &I01524;
  core[001525] = 05320; code[001525] = &I01525;
  core[001526] = 07520; code[001526] = &D01526;
  core[001527] = 07507; code[001527] = &D01527;
  core[001530] = 00000; code[001530] = &D01530;
  core[001531] = 02000; code[001531] = &I01531;
  core[001532] = 00000; code[001532] = &I01532;
  core[001533] = 00000; code[001533] = &S01533;
  core[001534] = 01066; code[001534] = &I01534;
  core[001535] = 01115; code[001535] = &I01535;
  core[001536] = 07640; code[001536] = &I01536;
  core[001537] = 02333; code[001537] = &I01537;
  core[001540] = 01066; code[001540] = &I01540;
  core[001541] = 01326; code[001541] = &I01541;
  core[001542] = 03054; code[001542] = &I01542;
  core[001543] = 01054; code[001543] = &I01543;
  core[001544] = 07710; code[001544] = &I01544;
  core[001545] = 05733; code[001545] = &I01545;
  core[001546] = 01066; code[001546] = &I01546;
  core[001547] = 01327; code[001547] = &I01547;
  core[001550] = 07750; code[001550] = &D01550;
  core[001551] = 02333; code[001551] = &I01551;
  core[001552] = 05733; code[001552] = &I01552;
  core[001553] = 04407; code[001553] = &I01553;
  core[001554] = 01330; code[001554] = &I01554;
  core[001555] = 04350; code[001555] = &I01555;
  core[001556] = 06330; code[001556] = &I01556;
  core[001557] = 00000; code[001557] = &I01557;
  core[001560] = 03330; code[001560] = &I01560;
  core[001561] = 03044; code[001561] = &I01561;
  core[001562] = 05536; code[001562] = &I01562;
  core[001563] = 01137; code[001563] = &I01563;
  core[001564] = 03022; code[001564] = &I01564;
  core[001565] = 01413; code[001565] = &L01565;
  core[001566] = 03071; code[001566] = &I01566;
  core[001567] = 05471; code[001567] = &P01567;
  core[001570] = 01241; code[001570] = &I01570;
  core[001571] = 01232; code[001571] = &I01571;
  core[001572] = 01251; code[001572] = &I01572;
  core[001573] = 01246; code[001573] = &I01573;
  core[001574] = 03052; code[001574] = &I01574;
  core[001575] = 01253; code[001575] = &I01575;
  core[001576] = 01253; code[001576] = &I01576;
  core[001577] = 00610; code[001577] = &I01577;
  core[001600] = 00614; code[001600] = &I01600;
  core[001601] = 00000; code[001601] = &D01601;
  core[001602] = 01054; code[001602] = &I01602;
  core[001603] = 04542; code[001603] = &I01603;
  core[001604] = 01055; code[001604] = &I01604;
  core[001605] = 04542; code[001605] = &I01605;
  core[001606] = 01056; code[001606] = &I01606;
  core[001607] = 04542; code[001607] = &I01607;
  core[001610] = 01201; code[001610] = &I01610;
  core[001611] = 04542; code[001611] = &I01611;
  core[001612] = 04545; code[001612] = &D01612;
  core[001613] = 03055; code[001613] = &I01613;
  core[001614] = 04564; code[001614] = &P01614;
  core[001615] = 05227; code[001615] = &I01615;
  core[001616] = 05332; code[001616] = &I01616;
  core[001617] = 05343; code[001617] = &I01617;
  core[001620] = 04540; code[001620] = &L01620;
  core[001621] = 01407; code[001621] = &I01621;
  core[001622] = 04564; code[001622] = &L01622;
  core[001623] = 05244; code[001623] = &I01623;
  core[001624] = 00212; code[001624] = &I01624;
  core[001625] = 00377; code[001625] = &I01625;
  core[001626] = 04566; code[001626] = &I01626;
  core[001627] = 01137; code[001627] = &L01627;
  core[001630] = 03030; code[001630] = &I01630;
  core[001631] = 01111; code[001631] = &I01631;
  core[001632] = 01054; code[001632] = &I01632;
  core[001633] = 07450; code[001633] = &I01633;
  core[001634] = 05247; code[001634] = &I01634;
  core[001635] = 07001; code[001635] = &I01635;
  core[001636] = 07650; code[001636] = &I01636;
  core[001637] = 05323; code[001637] = &I01637;
  core[001640] = 01054; code[001640] = &D01640;
  core[001641] = 01121; code[001641] = &I01641;
  core[001642] = 07710; code[001642] = &I01642;
  core[001643] = 05363; code[001643] = &I01643;
  core[001644] = 04562; code[001644] = &L01644;
  core[001645] = 07410; code[001645] = &I01645;
  core[001646] = 04566; code[001646] = &I01646;
  core[001647] = 01054; code[001647] = &L01647;
  core[001650] = 03024; code[001650] = &D01650;
  core[001651] = 01024; code[001651] = &I01651;
  core[001652] = 01121; code[001652] = &D01652;
  core[001653] = 07700; code[001653] = &D01653;
  core[001654] = 03024; code[001654] = &I01654;
  core[001655] = 01024; code[001655] = &L01655;
  core[001656] = 07041; code[001656] = &I01656;
  core[001657] = 01055; code[001657] = &D01657;
  core[001660] = 07710; code[001660] = &I01660;
  core[001661] = 05310; code[001661] = &I01661;
  core[001662] = 01055; code[001662] = &I01662;
  core[001663] = 07112; code[001663] = &I01663;
  core[001664] = 07012; code[001664] = &I01664;
  core[001665] = 01331; code[001665] = &I01665;
  core[001666] = 03274; code[001666] = &I01666;
  core[001667] = 01055; code[001667] = &I01667;
  core[001670] = 07640; code[001670] = &I01670;
  core[001671] = 04544; code[001671] = &I01671;
  core[001672] = 00044; code[001672] = &I01672;
  core[001673] = 04407; code[001673] = &I01673;
  core[001674] = 00000; code[001674] = &D01674;
  core[001675] = 06525; code[001675] = &I01675;
  core[001676] = 00000; code[001676] = &I01676;
  core[001677] = 01125; code[001677] = &I01677;
  core[001700] = 03030; code[001700] = &I01700;
  core[001701] = 01024; code[001701] = &I01701;
  core[001702] = 01055; code[001702] = &I01702;
  core[001703] = 07650; code[001703] = &I01703;
  core[001704] = 05541; code[001704] = &I01704;
  core[001705] = 01413; code[001705] = &I01705;
  core[001706] = 03055; code[001706] = &I01706;
  core[001707] = 05255; code[001707] = &I01707;
  core[001710] = 04562; code[001710] = &L01710;
  core[001711] = 07410; code[001711] = &I01711;
  core[001712] = 05365; code[001712] = &I01712;
  core[001713] = 01055; code[001713] = &I01713;
  core[001714] = 04542; code[001714] = &I01714;
  core[001715] = 01030; code[001715] = &I01715;
  core[001716] = 03320; code[001716] = &I01716;
  core[001717] = 04543; code[001717] = &I01717;
  core[001720] = 00000; code[001720] = &D01720;
  core[001721] = 01024; code[001721] = &I01721;
  core[001722] = 03055; code[001722] = &I01722;
  core[001723] = 04545; code[001723] = &L01723;
  core[001724] = 04564; code[001724] = &I01724;
  core[001725] = 05363; code[001725] = &L01725;
  core[001726] = 05332; code[001726] = &I01726;
  core[001727] = 05343; code[001727] = &I01727;
  core[001730] = 05220; code[001730] = &I01730;
  core[001731] = 00430; code[001731] = &D01731;
  core[001732] = 04543; code[001732] = &L01732;
  core[001733] = 00044; code[001733] = &D01733;
  core[001734] = 01125; code[001734] = &I01734;
  core[001735] = 03030; code[001735] = &I01735;
  core[001736] = 03036; code[001736] = &D01736;
  core[001737] = 04531; code[001737] = &I01737;
  core[001740] = 04544; code[001740] = &I01740;
  core[001741] = 00044; code[001741] = &I01741;
  core[001742] = 05222; code[001742] = &I01742;
  core[001743] = 03056; code[001743] = &L01743;
  core[001744] = 04545; code[001744] = &I01744;
  core[001745] = 04550; code[001745] = &I01745;
  core[001746] = 01767; code[001746] = &I01746;
  core[001747] = 05354; code[001747] = &I01747;
  core[001750] = 01056; code[001750] = &I01750;
  core[001751] = 07104; code[001751] = &I01751;
  core[001752] = 01066; code[001752] = &I01752;
  core[001753] = 05343; code[001753] = &I01753;
  core[001754] = 04562; code[001754] = &L01754;
  core[001755] = 04566; code[001755] = &I01755;
  core[001756] = 04201; code[001756] = &I01756;
  core[001757] = 01413; code[001757] = &I01757;
  core[001760] = 04547; code[001760] = &I01760;
  core[001761] = 02164; code[001761] = &I01761;
  core[001762] = 06207; code[001762] = &I01762;
  core[001763] = 04562; code[001763] = &L01763;
  core[001764] = 04566; code[001764] = &I01764;
  core[001765] = 04201; code[001765] = &L01765;
  core[001766] = 02013; code[001766] = &I01766;
  core[001767] = 05536; code[001767] = &P01767;
  core[001770] = 00240; code[001770] = &I01770;
  core[001771] = 00253; code[001771] = &I01771;
  core[001772] = 00255; code[001772] = &I01772;
  core[001773] = 00257; code[001773] = &I01773;
  core[001774] = 00252; code[001774] = &I01774;
  core[001775] = 00336; code[001775] = &I01775;
  core[001776] = 00250; code[001776] = &I01776;
  core[001777] = 00333; code[001777] = &D01777;
  core[002000] = 00274; code[002000] = &I02000;
  core[002001] = 00251; code[002001] = &I02001;
  core[002002] = 00335; code[002002] = &I02002;
  core[002003] = 00276; code[002003] = &I02003;
  core[002004] = 00254; code[002004] = &I02004;
  core[002005] = 00273; code[002005] = &I02005;
  core[002006] = 00215; code[002006] = &I02006;
  core[002007] = 00275; code[002007] = &I02007;
  core[002010] = 04543; code[002010] = &I02010;
  core[002011] = 02405; code[002011] = &I02011;
  core[002012] = 04544; code[002012] = &I02012;
  core[002013] = 00044; code[002013] = &I02013;
  core[002014] = 01231; code[002014] = &I02014;
  core[002015] = 07710; code[002015] = &D02015;
  core[002016] = 04451; code[002016] = &I02016;
  core[002017] = 04407; code[002017] = &L02017;
  core[002020] = 07000; code[002020] = &I02020;
  core[002021] = 06230; code[002021] = &I02021;
  core[002022] = 00000; code[002022] = &P02022;
  core[002023] = 01125; code[002023] = &P02023;
  core[002024] = 03030; code[002024] = &P02024;
  core[002025] = 04247; code[002025] = &P02025;
  core[002026] = 05627; code[002026] = &I02026;
  core[002027] = 01622; code[002027] = &P02027;
  core[002030] = 00000; code[002030] = &P02030;
  core[002031] = 00000; code[002031] = &D02031;
  core[002032] = 00000; code[002032] = &I02032;
  core[002033] = 00000; code[002033] = &I02033;
  core[002034] = 00003; code[002034] = &D02034;
  core[002035] = 00000; code[002035] = &S02035;
  core[002036] = 01054; code[002036] = &P02036;
  core[002037] = 01121; code[002037] = &I02037;
  core[002040] = 07700; code[002040] = &I02040;
  core[002041] = 05635; code[002041] = &I02041;
  core[002042] = 01054; code[002042] = &I02042;
  core[002043] = 01120; code[002043] = &I02043;
  core[002044] = 07740; code[002044] = &I02044;
  core[002045] = 02235; code[002045] = &I02045;
  core[002046] = 05635; code[002046] = &I02046;
  core[002047] = 00000; code[002047] = &S02047;
  core[002050] = 01413; code[002050] = &P02050;
  core[002051] = 03055; code[002051] = &D02051;
  core[002052] = 01234; code[002052] = &D02052;
  core[002053] = 01413; code[002053] = &I02053;
  core[002054] = 07041; code[002054] = &P02054;
  core[002055] = 01054; code[002055] = &L02055;
  core[002056] = 07640; code[002056] = &I02056;
  core[002057] = 04566; code[002057] = &I02057;
  core[002060] = 04545; code[002060] = &I02060;
  core[002061] = 05647; code[002061] = &I02061;
  core[002062] = 00000; code[002062] = &S02062;
  core[002063] = 06002; code[002063] = &L02063;
  core[002064] = 04555; code[002064] = &I02064;
  core[002065] = 05662; code[002065] = &I02065;
  core[002066] = 02026; code[002066] = &I02066;
  core[002067] = 04545; code[002067] = &L02067;
  core[002070] = 01066; code[002070] = &I02070;
  core[002071] = 01116; code[002071] = &I02071;
  core[002072] = 07640; code[002072] = &I02072;
  core[002073] = 05267; code[002073] = &D02073;
  core[002074] = 01017; code[002074] = &D02074;
  core[002075] = 07040; code[002075] = &D02075;
  core[002076] = 01023; code[002076] = &D02076;
  core[002077] = 03057; code[002077] = &I02077;
  core[002100] = 01133; code[002100] = &I02100;
  core[002101] = 07041; code[002101] = &I02101;
  core[002102] = 01023; code[002102] = &I02102;
  core[002103] = 07650; code[002103] = &I02103;
  core[002104] = 05177; code[002104] = &I02104;
  core[002105] = 07000; code[002105] = &I02105;
  core[002106] = 01423; code[002106] = &I02106;
  core[002107] = 03425; code[002107] = &I02107;
  core[002110] = 01133; code[002110] = &I02110;
  core[002111] = 03071; code[002111] = &L02111;
  core[002112] = 01471; code[002112] = &I02112;
  core[002113] = 07450; code[002113] = &I02113;
  core[002114] = 05327; code[002114] = &I02114;
  core[002115] = 03032; code[002115] = &I02115;
  core[002116] = 01023; code[002116] = &I02116;
  core[002117] = 07141; code[002117] = &I02117;
  core[002120] = 01032; code[002120] = &I02120;
  core[002121] = 07630; code[002121] = &I02121;
  core[002122] = 01057; code[002122] = &I02122;
  core[002123] = 01032; code[002123] = &I02123;
  core[002124] = 03471; code[002124] = &I02124;
  core[002125] = 01032; code[002125] = &I02125;
  core[002126] = 05311; code[002126] = &I02126;
  core[002127] = 07040; code[002127] = &L02127;
  core[002130] = 01023; code[002130] = &I02130;
  core[002131] = 03011; code[002131] = &I02131;
  core[002132] = 01057; code[002132] = &I02132;
  core[002133] = 07040; code[002133] = &I02133;
  core[002134] = 01023; code[002134] = &I02134;
  core[002135] = 03012; code[002135] = &D02135;
  core[002136] = 01057; code[002136] = &I02136;
  core[002137] = 01060; code[002137] = &I02137;
  core[002140] = 03060; code[002140] = &I02140;
  core[002141] = 01010; code[002141] = &I02141;
  core[002142] = 07040; code[002142] = &I02142;
  core[002143] = 01012; code[002143] = &I02143;
  core[002144] = 03032; code[002144] = &I02144;
  core[002145] = 01010; code[002145] = &I02145;
  core[002146] = 01057; code[002146] = &I02146;
  core[002147] = 03010; code[002147] = &I02147;
  core[002150] = 01412; code[002150] = &L02150;
  core[002151] = 03411; code[002151] = &I02151;
  core[002152] = 02032; code[002152] = &I02152;
  core[002153] = 05350; code[002153] = &I02153;
  core[002154] = 05263; code[002154] = &I02154;
  core[002155] = 00000; code[002155] = &S02155;
  core[002156] = 04464; code[002156] = &I02156;
  core[002157] = 03066; code[002157] = &I02157;
  core[002160] = 04550; code[002160] = &I02160;
  core[002161] = 01623; code[002161] = &I02161;
  core[002162] = 05755; code[002162] = &I02162;
  core[002163] = 04551; code[002163] = &I02163;
  core[002164] = 05755; code[002164] = &I02164;
  core[002165] = 02533; code[002165] = &I02165;
  core[002166] = 02650; code[002166] = &I02166;
  core[002167] = 02636; code[002167] = &I02167;
  core[002170] = 02565; code[002170] = &I02170;
  core[002171] = 02630; code[002171] = &I02171;
  core[002172] = 02517; code[002172] = &I02172;
  core[002173] = 02572; code[002173] = &I02173;
  core[002174] = 02624; code[002174] = &I02174;
  core[002175] = 02625; code[002175] = &I02175;
  core[002176] = 02654; code[002176] = &I02176;
  core[002177] = 02575; code[002177] = &I02177;
  core[002200] = 02702; code[002200] = &I02200;
  core[002201] = 02631; code[002201] = &I02201;
  core[002202] = 02567; code[002202] = &I02202;
  core[002203] = 00330; code[002203] = &I02203;
  core[002204] = 04564; code[002204] = &I02204;
  core[002205] = 05237; code[002205] = &I02205;
  core[002206] = 05222; code[002206] = &I02206;
  core[002207] = 05213; code[002207] = &I02207;
  core[002210] = 01066; code[002210] = &I02210;
  core[002211] = 01112; code[002211] = &I02211;
  core[002212] = 07440; code[002212] = &I02212;
  core[002213] = 04566; code[002213] = &L02213;
  core[002214] = 01135; code[002214] = &L02214;
  core[002215] = 03060; code[002215] = &I02215;
  core[002216] = 03533; code[002216] = &I02216;
  core[002217] = 01060; code[002217] = &L02217;
  core[002220] = 03031; code[002220] = &I02220;
  core[002221] = 05177; code[002221] = &I02221;
  core[002222] = 04554; code[002222] = &L02222;
  core[002223] = 01060; code[002223] = &I02223;
  core[002224] = 03010; code[002224] = &I02224;
  core[002225] = 04565; code[002225] = &L02225;
  core[002226] = 02023; code[002226] = &I02226;
  core[002227] = 01065; code[002227] = &I02227;
  core[002230] = 07700; code[002230] = &I02230;
  core[002231] = 01423; code[002231] = &P02231;
  core[002232] = 04563; code[002232] = &I02232;
  core[002233] = 05217; code[002233] = &I02233;
  core[002234] = 01423; code[002234] = &I02234;
  core[002235] = 03067; code[002235] = &I02235;
  core[002236] = 05225; code[002236] = &I02236;
  core[002237] = 01060; code[002237] = &L02237;
  core[002240] = 03031; code[002240] = &I02240;
  core[002241] = 05541; code[002241] = &I02241;
  core[002242] = 00000; code[002242] = &S02242;
  core[002243] = 01133; code[002243] = &I02243;
  core[002244] = 03025; code[002244] = &I02244;
  core[002245] = 01133; code[002245] = &I02245;
  core[002246] = 03023; code[002246] = &L02246;
  core[002247] = 01023; code[002247] = &I02247;
  core[002250] = 03011; code[002250] = &I02250;
  core[002251] = 01067; code[002251] = &I02251;
  core[002252] = 07141; code[002252] = &I02252;
  core[002253] = 01411; code[002253] = &D02253;
  core[002254] = 07450; code[002254] = &I02254;
  core[002255] = 05266; code[002255] = &I02255;
  core[002256] = 07630; code[002256] = &I02256;
  core[002257] = 05267; code[002257] = &I02257;
  core[002260] = 01023; code[002260] = &I02260;
  core[002261] = 03025; code[002261] = &I02261;
  core[002262] = 01423; code[002262] = &I02262;
  core[002263] = 07440; code[002263] = &I02263;
  core[002264] = 05246; code[002264] = &I02264;
  core[002265] = 07410; code[002265] = &I02265;
  core[002266] = 02242; code[002266] = &L02266;
  core[002267] = 01023; code[002267] = &L02267;
  core[002270] = 07001; code[002270] = &I02270;
  core[002271] = 03017; code[002271] = &I02271;
  core[002272] = 03020; code[002272] = &I02272;
  core[002273] = 05642; code[002273] = &I02273;
  core[002274] = 00000; code[002274] = &S02274;
  core[002275] = 04330; code[002275] = &L02275;
  core[002276] = 07710; code[002276] = &L02276;
  core[002277] = 01006; code[002277] = &I02277;
  core[002300] = 01357; code[002300] = &I02300;
  core[002301] = 01066; code[002301] = &I02301;
  core[002302] = 07450; code[002302] = &P02302;
  core[002303] = 05316; code[002303] = &I02303;
  core[002304] = 01075; code[002304] = &I02304;
  core[002305] = 03066; code[002305] = &L02305;
  core[002306] = 01026; code[002306] = &I02306;
  core[002307] = 01100; code[002307] = &I02307;
  core[002310] = 07650; code[002310] = &I02310;
  core[002311] = 04551; code[002311] = &I02311;
  core[002312] = 05674; code[002312] = &I02312;
  core[002313] = 04330; code[002313] = &L02313;
  core[002314] = 07040; code[002314] = &D02314;
  core[002315] = 05276; code[002315] = &I02315;
  core[002316] = 01026; code[002316] = &L02316;
  core[002317] = 07640; code[002317] = &I02317;
  core[002320] = 05326; code[002320] = &I02320;
  core[002321] = 01100; code[002321] = &I02321;
  core[002322] = 07650; code[002322] = &I02322;
  core[002323] = 07001; code[002323] = &I02323;
  core[002324] = 03100; code[002324] = &I02324;
  core[002325] = 05275; code[002325] = &I02325;
  core[002326] = 01110; code[002326] = &L02326;
  core[002327] = 05305; code[002327] = &I02327;
  core[002330] = 00000; code[002330] = &S02330;
  core[002331] = 02020; code[002331] = &I02331;
  core[002332] = 05345; code[002332] = &I02332;
  core[002333] = 01021; code[002333] = &I02333;
  core[002334] = 00122; code[002334] = &L02334;
  core[002335] = 03066; code[002335] = &I02335;
  core[002336] = 01066; code[002336] = &I02336;
  core[002337] = 01103; code[002337] = &I02337;
  core[002340] = 07650; code[002340] = &I02340;
  core[002341] = 05313; code[002341] = &I02341;
  core[002342] = 01066; code[002342] = &I02342;
  core[002343] = 01356; code[002343] = &I02343;
  core[002344] = 05730; code[002344] = &L02344;
  core[002345] = 01417; code[002345] = &L02345;
  core[002346] = 03021; code[002346] = &I02346;
  core[002347] = 07040; code[002347] = &I02347;
  core[002350] = 03020; code[002350] = &I02350;
  core[002351] = 01021; code[002351] = &I02351;
  core[002352] = 07112; code[002352] = &I02352;
  core[002353] = 07012; code[002353] = &I02353;
  core[002354] = 07012; code[002354] = &I02354;
  core[002355] = 05334; code[002355] = &I02355;
  core[002356] = 07740; code[002356] = &D02356;
  core[002357] = 07641; code[002357] = &D02357;
  core[002360] = 00000; code[002360] = &S02360;
  core[002361] = 07000; code[002361] = &I02361;
  core[002362] = 01425; code[002362] = &I02362;
  core[002363] = 03460; code[002363] = &I02363;
  core[002364] = 01060; code[002364] = &I02364;
  core[002365] = 03425; code[002365] = &I02365;
  core[002366] = 01061; code[002366] = &I02366;
  core[002367] = 07440; code[002367] = &I02367;
  core[002370] = 03410; code[002370] = &I02370;
  core[002371] = 01010; code[002371] = &I02371;
  core[002372] = 07001; code[002372] = &I02372;
  core[002373] = 03060; code[002373] = &I02373;
  core[002374] = 01060; code[002374] = &I02374;
  core[002375] = 03031; code[002375] = &I02375;
  core[002376] = 05760; code[002376] = &I02376;
  core[002377] = 01253; code[002377] = &I02377;
  core[002400] = 00614; code[002400] = &I02400;
  core[002401] = 06202; code[002401] = &I02401;
  core[002402] = 00757; code[002402] = &I02402;
  core[002403] = 00757; code[002403] = &I02403;
  core[002404] = 06250; code[002404] = &I02404;
  core[002405] = 00001; code[002405] = &I02405;
  core[002406] = 02000; code[002406] = &I02406;
  core[002407] = 00000; code[002407] = &D02407;
  core[002410] = 00000; code[002410] = &I02410;
  core[002411] = 00000; code[002411] = &I02411;
  core[002412] = 00000; code[002412] = &I02412;
  core[002413] = 07766; code[002413] = &D02413;
  core[002414] = 00000; code[002414] = &S02414;
  core[002415] = 06031; code[002415] = &L02415;
  core[002416] = 05215; code[002416] = &I02416;
  core[002417] = 06036; code[002417] = &I02417;
  core[002420] = 00106; code[002420] = &I02420;
  core[002421] = 07450; code[002421] = &I02421;
  core[002422] = 05215; code[002422] = &I02422;
  core[002423] = 01123; code[002423] = &I02423;
  core[002424] = 05614; code[002424] = &I02424;
  core[002425] = 00000; code[002425] = &S02425;
  core[002426] = 01067; code[002426] = &I02426;
  core[002427] = 04557; code[002427] = &I02427;
  core[002430] = 00122; code[002430] = &I02430;
  core[002431] = 04242; code[002431] = &I02431;
  core[002432] = 01102; code[002432] = &I02432;
  core[002433] = 04551; code[002433] = &I02433;
  core[002434] = 01067; code[002434] = &I02434;
  core[002435] = 04242; code[002435] = &I02435;
  core[002436] = 01356; code[002436] = &I02436;
  core[002437] = 03066; code[002437] = &I02437;
  core[002440] = 04551; code[002440] = &I02440;
  core[002441] = 05625; code[002441] = &I02441;
  core[002442] = 00000; code[002442] = &S02442;
  core[002443] = 00106; code[002443] = &I02443;
  core[002444] = 03032; code[002444] = &I02444;
  core[002445] = 01113; code[002445] = &I02445;
  core[002446] = 03033; code[002446] = &I02446;
  core[002447] = 05252; code[002447] = &I02447;
  core[002450] = 02033; code[002450] = &L02450;
  core[002451] = 03032; code[002451] = &I02451;
  core[002452] = 01032; code[002452] = &L02452;
  core[002453] = 01213; code[002453] = &I02453;
  core[002454] = 07500; code[002454] = &I02454;
  core[002455] = 05250; code[002455] = &I02455;
  core[002456] = 07200; code[002456] = &I02456;
  core[002457] = 01033; code[002457] = &I02457;
  core[002460] = 04551; code[002460] = &I02460;
  core[002461] = 01032; code[002461] = &I02461;
  core[002462] = 01113; code[002462] = &D02462;
  core[002463] = 04551; code[002463] = &I02463;
  core[002464] = 05642; code[002464] = &I02464;
  core[002465] = 00000; code[002465] = &S02465;
  core[002466] = 07450; code[002466] = &I02466;
  core[002467] = 01066; code[002467] = &I02467;
  core[002470] = 01116; code[002470] = &I02470;
  core[002471] = 07450; code[002471] = &I02471;
  core[002472] = 05276; code[002472] = &I02472;
  core[002473] = 01077; code[002473] = &I02473;
  core[002474] = 04463; code[002474] = &L02474;
  core[002475] = 05665; code[002475] = &I02475;
  core[002476] = 01077; code[002476] = &L02476;
  core[002477] = 04463; code[002477] = &I02477;
  core[002500] = 01076; code[002500] = &I02500;
  core[002501] = 05274; code[002501] = &I02501;
  core[002502] = 00000; code[002502] = &S02502;
  core[002503] = 01110; code[002503] = &I02503;
  core[002504] = 07041; code[002504] = &I02504;
  core[002505] = 01066; code[002505] = &I02505;
  core[002506] = 07450; code[002506] = &I02506;
  core[002507] = 01352; code[002507] = &I02507;
  core[002510] = 01101; code[002510] = &I02510;
  core[002511] = 07450; code[002511] = &I02511;
  core[002512] = 05755; code[002512] = &I02512;
  core[002513] = 01353; code[002513] = &I02513;
  core[002514] = 03071; code[002514] = &I02514;
  core[002515] = 01071; code[002515] = &I02515;
  core[002516] = 00354; code[002516] = &I02516;
  core[002517] = 01356; code[002517] = &D02517;
  core[002520] = 07440; code[002520] = &I02520;
  core[002521] = 01354; code[002521] = &I02521;
  core[002522] = 07650; code[002522] = &I02522;
  core[002523] = 05332; code[002523] = &I02523;
  core[002524] = 01071; code[002524] = &L02524;
  core[002525] = 00122; code[002525] = &I02525;
  core[002526] = 07440; code[002526] = &I02526;
  core[002527] = 04335; code[002527] = &I02527;
  core[002530] = 07000; code[002530] = &L02530;
  core[002531] = 05702; code[002531] = &I02531;
  core[002532] = 01122; code[002532] = &L02532;
  core[002533] = 04335; code[002533] = &I02533;
  core[002534] = 05324; code[002534] = &I02534;
  core[002535] = 00000; code[002535] = &S02535;
  core[002536] = 02062; code[002536] = &I02536;
  core[002537] = 05357; code[002537] = &I02537;
  core[002540] = 01061; code[002540] = &I02540;
  core[002541] = 03410; code[002541] = &I02541;
  core[002542] = 03061; code[002542] = &I02542;
  core[002543] = 01013; code[002543] = &I02543;
  core[002544] = 07141; code[002544] = &I02544;
  core[002545] = 01005; code[002545] = &I02545;
  core[002546] = 01010; code[002546] = &I02546;
  core[002547] = 07620; code[002547] = &I02547;
  core[002550] = 05735; code[002550] = &I02550;
  core[002551] = 04566; code[002551] = &I02551;
  core[002552] = 00040; code[002552] = &D02552;
  core[002553] = 00377; code[002553] = &D02553;
  core[002554] = 00140; code[002554] = &D02554;
  core[002555] = 03004; code[002555] = &P02555;
  core[002556] = 07640; code[002556] = &D02556;
  core[002557] = 04557; code[002557] = &P02557;
  core[002560] = 03061; code[002560] = &I02560;
  core[002561] = 07040; code[002561] = &I02561;
  core[002562] = 03062; code[002562] = &I02562;
  core[002563] = 05735; code[002563] = &I02563;
  core[002600] = 00000; code[002600] = &D02600;
  core[002601] = 00000; code[002601] = &D02601;
  core[002602] = 07575; code[002602] = &D02602;
  core[002603] = 03200; code[002603] = &L02603;
  core[002604] = 07010; code[002604] = &I02604;
  core[002605] = 03201; code[002605] = &I02605;
  core[002606] = 06041; code[002606] = &I02606;
  core[002607] = 05225; code[002607] = &I02607;
  core[002610] = 06042; code[002610] = &I02610;
  core[002611] = 03016; code[002611] = &I02611;
  core[002612] = 01665; code[002612] = &I02612;
  core[002613] = 07450; code[002613] = &I02613;
  core[002614] = 05225; code[002614] = &I02614;
  core[002615] = 06044; code[002615] = &I02615;
  core[002616] = 03016; code[002616] = &I02616;
  core[002617] = 03665; code[002617] = &I02617;
  core[002620] = 01265; code[002620] = &I02620;
  core[002621] = 07001; code[002621] = &I02621;
  core[002622] = 00107; code[002622] = &I02622;
  core[002623] = 01263; code[002623] = &I02623;
  core[002624] = 03265; code[002624] = &I02624;
  core[002625] = 06031; code[002625] = &L02625;
  core[002626] = 05246; code[002626] = &I02626;
  core[002627] = 06036; code[002627] = &I02627;
  core[002630] = 00106; code[002630] = &I02630;
  core[002631] = 07450; code[002631] = &I02631;
  core[002632] = 05246; code[002632] = &I02632;
  core[002633] = 01123; code[002633] = &I02633;
  core[002634] = 03262; code[002634] = &I02634;
  core[002635] = 01262; code[002635] = &I02635;
  core[002636] = 01202; code[002636] = &I02636;
  core[002637] = 07650; code[002637] = &I02637;
  core[002640] = 05340; code[002640] = &I02640;
  core[002641] = 01034; code[002641] = &I02641;
  core[002642] = 07640; code[002642] = &I02642;
  core[002643] = 04566; code[002643] = &I02643;
  core[002644] = 01262; code[002644] = &I02644;
  core[002645] = 03034; code[002645] = &I02645;
  core[002646] = 06011; code[002646] = &L02646;
  core[002647] = 05252; code[002647] = &I02647;
  core[002650] = 06012; code[002650] = &I02650;
  core[002651] = 03037; code[002651] = &I02651;
  core[002652] = 06244; code[002652] = &L02652;
  core[002653] = 06101; code[002653] = &I02653;
  core[002654] = 07000; code[002654] = &D02654;
  core[002655] = 01201; code[002655] = &I02655;
  core[002656] = 07104; code[002656] = &I02656;
  core[002657] = 01200; code[002657] = &I02657;
  core[002660] = 06001; code[002660] = &I02660;
  core[002661] = 05400; code[002661] = &D02661;
  core[002662] = 00000; code[002662] = &D02662;
  core[002663] = 03120; code[002663] = &D02663;
  core[002664] = 03120; code[002664] = &P02664;
  core[002665] = 03120; code[002665] = &P02665;
  core[002666] = 00000; code[002666] = &S02666;
  core[002667] = 01034; code[002667] = &L02667;
  core[002670] = 07550; code[002670] = &I02670;
  core[002671] = 05267; code[002671] = &I02671;
  core[002672] = 03276; code[002672] = &I02672;
  core[002673] = 03034; code[002673] = &I02673;
  core[002674] = 01276; code[002674] = &I02674;
  core[002675] = 05666; code[002675] = &D02675;
  core[002676] = 00000; code[002676] = &S02676;
  core[002677] = 03266; code[002677] = &I02677;
  core[002700] = 06001; code[002700] = &I02700;
  core[002701] = 01664; code[002701] = &L02701;
  core[002702] = 07640; code[002702] = &I02702;
  core[002703] = 05301; code[002703] = &I02703;
  core[002704] = 06002; code[002704] = &I02704;
  core[002705] = 01016; code[002705] = &I02705;
  core[002706] = 07640; code[002706] = &I02706;
  core[002707] = 05314; code[002707] = &I02707;
  core[002710] = 01266; code[002710] = &I02710;
  core[002711] = 06046; code[002711] = &I02711;
  core[002712] = 03016; code[002712] = &I02712;
  core[002713] = 05323; code[002713] = &I02713;
  core[002714] = 01266; code[002714] = &L02714;
  core[002715] = 03664; code[002715] = &I02715;
  core[002716] = 01264; code[002716] = &I02716;
  core[002717] = 07001; code[002717] = &I02717;
  core[002720] = 00107; code[002720] = &I02720;
  core[002721] = 01263; code[002721] = &I02721;
  core[002722] = 03264; code[002722] = &I02722;
  core[002723] = 06001; code[002723] = &L02723;
  core[002724] = 05676; code[002724] = &I02724;
  core[002725] = 03326; code[002725] = &D02725;
  core[002726] = 00000; code[002726] = &D02726;
  core[002727] = 07240; code[002727] = &I02727;
  core[002730] = 01326; code[002730] = &I02730;
  core[002731] = 03067; code[002731] = &I02731;
  core[002732] = 06001; code[002732] = &I02732;
  core[002733] = 01016; code[002733] = &L02733;
  core[002734] = 07640; code[002734] = &I02734;
  core[002735] = 05333; code[002735] = &I02735;
  core[002736] = 06002; code[002736] = &I02736;
  core[002737] = 05342; code[002737] = &I02737;
  core[002740] = 01123; code[002740] = &L02740;
  core[002741] = 03067; code[002741] = &I02741;
  core[002742] = 02016; code[002742] = &L02742;
  core[002743] = 01105; code[002743] = &I02743;
  core[002744] = 03057; code[002744] = &I02744;
  core[002745] = 07040; code[002745] = &I02745;
  core[002746] = 01263; code[002746] = &I02746;
  core[002747] = 03010; code[002747] = &I02747;
  core[002750] = 07000; code[002750] = &I02750;
  core[002751] = 03410; code[002751] = &L02751;
  core[002752] = 02057; code[002752] = &I02752;
  core[002753] = 05351; code[002753] = &I02753;
  core[002754] = 03034; code[002754] = &I02754;
  core[002755] = 01263; code[002755] = &I02755;
  core[002756] = 03265; code[002756] = &I02756;
  core[002757] = 01263; code[002757] = &I02757;
  core[002760] = 03264; code[002760] = &I02760;
  core[002761] = 07040; code[002761] = &I02761;
  core[002762] = 06046; code[002762] = &I02762;
  core[002763] = 01101; code[002763] = &I02763;
  core[002764] = 04551; code[002764] = &I02764;
  core[002765] = 04553; code[002765] = &I02765;
  core[002766] = 02022; code[002766] = &I02766;
  core[002767] = 01422; code[002767] = &I02767;
  core[002770] = 07450; code[002770] = &I02770;
  core[002771] = 05377; code[002771] = &I02771;
  core[002772] = 03067; code[002772] = &I02772;
  core[002773] = 01101; code[002773] = &I02773;
  core[002774] = 04551; code[002774] = &I02774;
  core[002775] = 04551; code[002775] = &I02775;
  core[002776] = 04553; code[002776] = &I02776;
  core[002777] = 01077; code[002777] = &L02777;
  core[003000] = 04551; code[003000] = &I03000;
  core[003001] = 01126; code[003001] = &I03001;
  core[003002] = 03152; code[003002] = &I03002;
  core[003003] = 05177; code[003003] = &I03003;
  core[003004] = 01062; code[003004] = &L03004;
  core[003005] = 07640; code[003005] = &I03005;
  core[003006] = 05214; code[003006] = &I03006;
  core[003007] = 01010; code[003007] = &I03007;
  core[003010] = 07041; code[003010] = &I03010;
  core[003011] = 01027; code[003011] = &I03011;
  core[003012] = 07700; code[003012] = &I03012;
  core[003013] = 05641; code[003013] = &I03013;
  core[003014] = 01251; code[003014] = &L03014;
  core[003015] = 04551; code[003015] = &I03015;
  core[003016] = 01010; code[003016] = &I03016;
  core[003017] = 03071; code[003017] = &I03017;
  core[003020] = 07000; code[003020] = &I03020;
  core[003021] = 02062; code[003021] = &I03021;
  core[003022] = 05242; code[003022] = &I03022;
  core[003023] = 01471; code[003023] = &I03023;
  core[003024] = 00122; code[003024] = &I03024;
  core[003025] = 01103; code[003025] = &I03025;
  core[003026] = 07640; code[003026] = &I03026;
  core[003027] = 05237; code[003027] = &I03027;
  core[003030] = 07040; code[003030] = &L03030;
  core[003031] = 03062; code[003031] = &L03031;
  core[003032] = 07040; code[003032] = &I03032;
  core[003033] = 01010; code[003033] = &I03033;
  core[003034] = 03010; code[003034] = &I03034;
  core[003035] = 01471; code[003035] = &I03035;
  core[003036] = 00101; code[003036] = &I03036;
  core[003037] = 03061; code[003037] = &L03037;
  core[003040] = 05641; code[003040] = &I03040;
  core[003041] = 02530; code[003041] = &P03041;
  core[003042] = 01471; code[003042] = &L03042;
  core[003043] = 00101; code[003043] = &I03043;
  core[003044] = 01006; code[003044] = &I03044;
  core[003045] = 07640; code[003045] = &L03045;
  core[003046] = 05230; code[003046] = &I03046;
  core[003047] = 03471; code[003047] = &I03047;
  core[003050] = 05231; code[003050] = &I03050;
  core[003051] = 00334; code[003051] = &D03051;
  core[003052] = 01060; code[003052] = &I03052;
  core[003053] = 03030; code[003053] = &L03053;
  core[003054] = 01031; code[003054] = &I03054;
  core[003055] = 07041; code[003055] = &I03055;
  core[003056] = 01030; code[003056] = &I03056;
  core[003057] = 07650; code[003057] = &I03057;
  core[003060] = 05541; code[003060] = &I03060;
  core[003061] = 01430; code[003061] = &I03061;
  core[003062] = 03316; code[003062] = &I03062;
  core[003063] = 01315; code[003063] = &I03063;
  core[003064] = 03017; code[003064] = &I03064;
  core[003065] = 03020; code[003065] = &I03065;
  core[003066] = 04545; code[003066] = &I03066;
  core[003067] = 04551; code[003067] = &I03067;
  core[003070] = 04545; code[003070] = &I03070;
  core[003071] = 04551; code[003071] = &I03071;
  core[003072] = 04545; code[003072] = &I03072;
  core[003073] = 04551; code[003073] = &I03073;
  core[003074] = 02030; code[003074] = &I03074;
  core[003075] = 01430; code[003075] = &I03075;
  core[003076] = 04714; code[003076] = &I03076;
  core[003077] = 04545; code[003077] = &I03077;
  core[003100] = 04551; code[003100] = &I03100;
  core[003101] = 02030; code[003101] = &I03101;
  core[003102] = 04407; code[003102] = &I03102;
  core[003103] = 00430; code[003103] = &I03103;
  core[003104] = 00000; code[003104] = &I03104;
  core[003105] = 04530; code[003105] = &I03105;
  core[003106] = 01077; code[003106] = &I03106;
  core[003107] = 04551; code[003107] = &I03107;
  core[003110] = 01070; code[003110] = &I03110;
  core[003111] = 01111; code[003111] = &I03111;
  core[003112] = 01030; code[003112] = &I03112;
  core[003113] = 05253; code[003113] = &I03113;
  core[003114] = 02442; code[003114] = &P03114;
  core[003115] = 03115; code[003115] = &D03115;
  core[003116] = 00000; code[003116] = &D03116;
  core[003117] = 05051; code[003117] = &D03117;
  core[003120] = 00000; code[003120] = &D03120;
  core[003206] = 03217; code[003206] = &D03206;
  core[003207] = 00000; code[003207] = &P03207;
  core[003210] = 00355; code[003210] = &I03210;
  core[003211] = 00617; code[003211] = &I03211;
  core[003212] = 00301; code[003212] = &D03212;
  core[003213] = 01454; code[003213] = &I03213;
  core[003214] = 06171; code[003214] = &I03214;
  core[003215] = 06671; code[003215] = &D03215;
  core[003216] = 07715; code[003216] = &I03216;
  core[003217] = 03235; code[003217] = &P03217;
  core[003220] = 00212; code[003220] = &I03220;
  core[003221] = 02440; code[003221] = &I03221;
  core[003222] = 04142; code[003222] = &I03222;
  core[003223] = 00317; code[003223] = &I03223;
  core[003224] = 01607; code[003224] = &D03224;
  core[003225] = 02201; code[003225] = &I03225;
  core[003226] = 02425; code[003226] = &I03226;
  core[003227] = 01401; code[003227] = &I03227;
  core[003230] = 02411; code[003230] = &I03230;
  core[003231] = 01716; code[003231] = &D03231;
  core[003232] = 02341; code[003232] = &D03232;
  core[003233] = 04142; code[003233] = &D03233;
  core[003234] = 07715; code[003234] = &I03234;
  core[003235] = 03272; code[003235] = &D03235;
  core[003236] = 00224; code[003236] = &D03236;
  core[003237] = 02440; code[003237] = &I03237;
  core[003240] = 04041; code[003240] = &P03240;
  core[003241] = 04231; code[003241] = &I03241;
  core[003242] = 01725; code[003242] = &P03242;
  core[003243] = 04010; code[003243] = &I03243;
  core[003244] = 00126; code[003244] = &I03244;
  core[003245] = 00540; code[003245] = &I03245;
  core[003246] = 02325; code[003246] = &I03246;
  core[003247] = 00303; code[003247] = &I03247;
  core[003250] = 00523; code[003250] = &I03250;
  core[003251] = 02306; code[003251] = &I03251;
  core[003252] = 02514; code[003252] = &I03252;
  core[003253] = 01431; code[003253] = &I03253;
  core[003254] = 04014; code[003254] = &I03254;
  core[003255] = 01701; code[003255] = &I03255;
  core[003256] = 00405; code[003256] = &I03256;
  core[003257] = 00440; code[003257] = &I03257;
  core[003260] = 04706; code[003260] = &I03260;
  core[003261] = 01703; code[003261] = &I03261;
  core[003262] = 00114; code[003262] = &P03262;
  core[003263] = 05461; code[003263] = &P03263;
  core[003264] = 07166; code[003264] = &P03264;
  core[003265] = 07147; code[003265] = &I03265;
  core[003266] = 04017; code[003266] = &I03266;
  core[003267] = 01640; code[003267] = &I03267;
  core[003270] = 00140; code[003270] = &I03270;
  core[003271] = 07715; code[003271] = &P03271;
  core[003272] = 03330; code[003272] = &D03272;
  core[003273] = 00231; code[003273] = &I03273;
  core[003274] = 02305; code[003274] = &I03274;
  core[003275] = 02440; code[003275] = &I03275;
  core[003276] = 02004; code[003276] = &I03276;
  core[003277] = 02075; code[003277] = &I03277;
  core[003300] = 02004; code[003300] = &I03300;
  core[003301] = 02052; code[003301] = &P03301;
  core[003302] = 06236; code[003302] = &I03302;
  core[003303] = 06161; code[003303] = &P03303;
  core[003304] = 07304; code[003304] = &I03304;
  core[003305] = 04061; code[003305] = &D03305;
  core[003306] = 05662; code[003306] = &P03306;
  core[003307] = 06673; code[003307] = &I03307;
  core[003310] = 00417; code[003310] = &I03310;
  core[003311] = 04061; code[003311] = &I03311;
  core[003312] = 05671; code[003312] = &I03312;
  core[003313] = 07304; code[003313] = &I03313;
  core[003314] = 01740; code[003314] = &I03314;
  core[003315] = 06273; code[003315] = &I03315;
  core[003316] = 04024; code[003316] = &P03316;
  core[003317] = 04041; code[003317] = &D03317;
  core[003320] = 04220; code[003320] = &I03320;
  core[003321] = 02217; code[003321] = &I03321;
  core[003322] = 00305; code[003322] = &I03322;
  core[003323] = 00504; code[003323] = &I03323;
  core[003324] = 05642; code[003324] = &I03324;
  core[003325] = 04141; code[003325] = &P03325;
  core[003326] = 07322; code[003326] = &I03326;
  core[003327] = 07715; code[003327] = &I03327;
  core[003330] = 03354; code[003330] = &D03330;
  core[003331] = 00232; code[003331] = &I03331;
  core[003332] = 01106; code[003332] = &I03332;
  core[003333] = 04050; code[003333] = &I03333;
  core[003334] = 02004; code[003334] = &I03334;
  core[003335] = 02055; code[003335] = &I03335;
  core[003336] = 06651; code[003336] = &I03336;
  core[003337] = 04061; code[003337] = &I03337;
  core[003340] = 05663; code[003340] = &P03340;
  core[003341] = 06054; code[003341] = &D03341;
  core[003342] = 06156; code[003342] = &I03342;
  core[003343] = 06267; code[003343] = &I03343;
  core[003344] = 07324; code[003344] = &I03344;
  core[003345] = 04042; code[003345] = &I03345;
  core[003346] = 02004; code[003346] = &I03346;
  core[003347] = 02055; code[003347] = &I03347;
  core[003350] = 07057; code[003350] = &I03350;
  core[003351] = 01442; code[003351] = &I03351;
  core[003352] = 07322; code[003352] = &I03352;
  core[003353] = 07715; code[003353] = &I03353;
  core[003354] = 03365; code[003354] = &D03354;
  core[003355] = 00233; code[003355] = &D03355;
  core[003356] = 02440; code[003356] = &I03356;
  core[003357] = 04220; code[003357] = &I03357;
  core[003360] = 00420; code[003360] = &I03360;
  core[003361] = 05561; code[003361] = &I03361;
  core[003362] = 06242; code[003362] = &I03362;
  core[003363] = 07322; code[003363] = &I03363;
  core[003364] = 07715; code[003364] = &I03364;
  core[003365] = 03403; code[003365] = &D03365;
  core[003366] = 00236; code[003366] = &I03366;
  core[003367] = 01140; code[003367] = &I03367;
  core[003370] = 05020; code[003370] = &I03370;
  core[003371] = 00420; code[003371] = &I03371;
  core[003372] = 05565; code[003372] = &I03372;
  core[003373] = 05161; code[003373] = &I03373;
  core[003374] = 05664; code[003374] = &I03374;
  core[003375] = 07324; code[003375] = &I03375;
  core[003376] = 04042; code[003376] = &I03376;
  core[003377] = 01401; code[003377] = &I03377;
  core[003400] = 00255; code[003400] = &I03400;
  core[003401] = 07042; code[003401] = &P03401;
  core[003402] = 07715; code[003402] = &D03402;
  core[003403] = 03421; code[003403] = &P03403;
  core[003404] = 00250; code[003404] = &I03404;
  core[003405] = 01140; code[003405] = &D03405;
  core[003406] = 05020; code[003406] = &I03406;
  core[003407] = 00420; code[003407] = &I03407;
  core[003410] = 05564; code[003410] = &I03410;
  core[003411] = 05161; code[003411] = &I03411;
  core[003412] = 05665; code[003412] = &I03412;
  core[003413] = 07324; code[003413] = &I03413;
  core[003414] = 04042; code[003414] = &I03414;
  core[003415] = 01411; code[003415] = &I03415;
  core[003416] = 01603; code[003416] = &I03416;
  core[003417] = 05570; code[003417] = &I03417;
  core[003420] = 07715; code[003420] = &I03420;
  core[003421] = 03443; code[003421] = &D03421;
  core[003422] = 00262; code[003422] = &I03422;
  core[003423] = 02440; code[003423] = &I03423;
  core[003424] = 04220; code[003424] = &I03424;
  core[003425] = 00420; code[003425] = &I03425;
  core[003426] = 05542; code[003426] = &I03426;
  core[003427] = 07311; code[003427] = &I03427;
  core[003430] = 00640; code[003430] = &I03430;
  core[003431] = 05020; code[003431] = &I03431;
  core[003432] = 00420; code[003432] = &I03432;
  core[003433] = 05563; code[003433] = &I03433;
  core[003434] = 05161; code[003434] = &I03434;
  core[003435] = 05666; code[003435] = &I03435;
  core[003436] = 07324; code[003436] = &I03436;
  core[003437] = 04042; code[003437] = &I03437;
  core[003440] = 07057; code[003440] = &P03440;
  core[003441] = 01142; code[003441] = &I03441;
  core[003442] = 07715; code[003442] = &P03442;
  core[003443] = 03457; code[003443] = &I03443;
  core[003444] = 00274; code[003444] = &I03444;
  core[003445] = 01106; code[003445] = &I03445;
  core[003446] = 04050; code[003446] = &I03446;
  core[003447] = 02004; code[003447] = &I03447;
  core[003450] = 02055; code[003450] = &D03450;
  core[003451] = 06251; code[003451] = &I03451;
  core[003452] = 06156; code[003452] = &I03452;
  core[003453] = 06773; code[003453] = &I03453;
  core[003454] = 02440; code[003454] = &I03454;
  core[003455] = 04270; code[003455] = &D03455;
  core[003456] = 07715; code[003456] = &I03456;
  core[003457] = 03474; code[003457] = &I03457;
  core[003460] = 00306; code[003460] = &I03460;
  core[003461] = 01106; code[003461] = &I03461;
  core[003462] = 04050; code[003462] = &D03462;
  core[003463] = 02004; code[003463] = &I03463;
  core[003464] = 02055; code[003464] = &P03464;
  core[003465] = 06151; code[003465] = &P03465;
  core[003466] = 06156; code[003466] = &P03466;
  core[003467] = 07073; code[003467] = &I03467;
  core[003470] = 02440; code[003470] = &I03470;
  core[003471] = 04270; code[003471] = &P03471;
  core[003472] = 05723; code[003472] = &I03472;
  core[003473] = 07715; code[003473] = &I03473;
  core[003474] = 03507; code[003474] = &D03474;
  core[003475] = 00320; code[003475] = &I03475;
  core[003476] = 01106; code[003476] = &I03476;
  core[003477] = 04050; code[003477] = &I03477;
  core[003500] = 02004; code[003500] = &I03500;
  core[003501] = 02051; code[003501] = &I03501;
  core[003502] = 06156; code[003502] = &I03502;
  core[003503] = 07173; code[003503] = &I03503;
  core[003504] = 02440; code[003504] = &I03504;
  core[003505] = 04265; code[003505] = &D03505;
  core[003506] = 07715; code[003506] = &D03506;
  core[003507] = 03522; code[003507] = &P03507;
  core[003510] = 00332; code[003510] = &D03510;
  core[003511] = 02440; code[003511] = &I03511;
  core[003512] = 04240; code[003512] = &I03512;
  core[003513] = 00317; code[003513] = &I03513;
  core[003514] = 01520; code[003514] = &I03514;
  core[003515] = 02524; code[003515] = &I03515;
  core[003516] = 00522; code[003516] = &I03516;
  core[003517] = 05642; code[003517] = &D03517;
  core[003520] = 04141; code[003520] = &D03520;
  core[003521] = 07715; code[003521] = &I03521;
  core[003522] = 03531; code[003522] = &D03522;
  core[003523] = 00417; code[003523] = &P03523;
  core[003524] = 02305; code[003524] = &I03524;
  core[003525] = 02440; code[003525] = &I03525;
  core[003526] = 03006; code[003526] = &I03526;
  core[003527] = 07561; code[003527] = &I03527;
  core[003530] = 07715; code[003530] = &I03530;
  core[003531] = 03546; code[003531] = &I03531;
  core[003532] = 00424; code[003532] = &D03532;
  core[003533] = 02440; code[003533] = &I03533;
  core[003534] = 04142; code[003534] = &I03534;
  core[003535] = 02310; code[003535] = &I03535;
  core[003536] = 00114; code[003536] = &I03536;
  core[003537] = 01440; code[003537] = &I03537;
  core[003540] = 01140; code[003540] = &I03540;
  core[003541] = 02205; code[003541] = &I03541;
  core[003542] = 02401; code[003542] = &I03542;
  core[003543] = 01116; code[003543] = &I03543;
  core[003544] = 04042; code[003544] = &I03544;
  core[003545] = 07715; code[003545] = &I03545;
  core[003546] = 03562; code[003546] = &I03546;
  core[003547] = 00431; code[003547] = &I03547;
  core[003550] = 02440; code[003550] = &I03550;
  core[003551] = 04214; code[003551] = &I03551;
  core[003552] = 01707; code[003552] = &I03552;
  core[003553] = 05440; code[003553] = &I03553;
  core[003554] = 00530; code[003554] = &I03554;
  core[003555] = 02054; code[003555] = &I03555;
  core[003556] = 04001; code[003556] = &I03556;
  core[003557] = 02416; code[003557] = &I03557;
  core[003560] = 04037; code[003560] = &I03560;
  core[003561] = 07715; code[003561] = &I03561;
  core[003562] = 03601; code[003562] = &I03562;
  core[003563] = 00436; code[003563] = &I03563;
  core[003564] = 00417; code[003564] = &I03564;
  core[003565] = 04061; code[003565] = &I03565;
  core[003566] = 06073; code[003566] = &I03566;
  core[003567] = 01106; code[003567] = &I03567;
  core[003570] = 04050; code[003570] = &I03570;
  core[003571] = 02205; code[003571] = &I03571;
  core[003572] = 05162; code[003572] = &I03572;
  core[003573] = 05671; code[003573] = &I03573;
  core[003574] = 05462; code[003574] = &I03574;
  core[003575] = 05664; code[003575] = &I03575;
  core[003576] = 05462; code[003576] = &I03576;
  core[003577] = 05664; code[003577] = &I03577;
  core[003600] = 07715; code[003600] = &I03600;
  core[003601] = 03632; code[003601] = &I03601;
  core[003602] = 00450; code[003602] = &I03602;
  core[003603] = 00417; code[003603] = &I03603;
  core[003604] = 04062; code[003604] = &I03604;
  core[003605] = 05662; code[003605] = &P03605;
  core[003606] = 07324; code[003606] = &I03606;
  core[003607] = 04042; code[003607] = &I03607;
  core[003610] = 02311; code[003610] = &I03610;
  core[003611] = 01605; code[003611] = &I03611;
  core[003612] = 05440; code[003612] = &I03612;
  core[003613] = 00317; code[003613] = &I03613;
  core[003614] = 02311; code[003614] = &I03614;
  core[003615] = 01605; code[003615] = &I03615;
  core[003616] = 04037; code[003616] = &I03616;
  core[003617] = 04273; code[003617] = &P03617;
  core[003620] = 00417; code[003620] = &I03620;
  core[003621] = 04061; code[003621] = &I03621;
  core[003622] = 06073; code[003622] = &I03622;
  core[003623] = 01106; code[003623] = &P03623;
  core[003624] = 04050; code[003624] = &I03624;
  core[003625] = 02205; code[003625] = &I03625;
  core[003626] = 05162; code[003626] = &I03626;
  core[003627] = 05665; code[003627] = &I03627;
  core[003630] = 07322; code[003630] = &I03630;
  core[003631] = 07715; code[003631] = &I03631;
  core[003632] = 03642; code[003632] = &P03632;
  core[003633] = 00462; code[003633] = &I03633;
  core[003634] = 02340; code[003634] = &I03634;
  core[003635] = 03006; code[003635] = &I03635;
  core[003636] = 07555; code[003636] = &I03636;
  core[003637] = 06173; code[003637] = &I03637;
  core[003640] = 04022; code[003640] = &D03640;
  core[003641] = 07715; code[003641] = &I03641;
  core[003642] = 03650; code[003642] = &P03642;
  core[003643] = 00532; code[003643] = &I03643;
  core[003644] = 02340; code[003644] = &I03644;
  core[003645] = 03006; code[003645] = &I03645;
  core[003646] = 07560; code[003646] = &I03646;
  core[003647] = 07715; code[003647] = &I03647;
  core[003650] = 03673; code[003650] = &P03650;
  core[003651] = 02450; code[003651] = &I03651;
  core[003652] = 00140; code[003652] = &I03652;
  core[003653] = 02205; code[003653] = &I03653;
  core[003654] = 07311; code[003654] = &I03654;
  core[003655] = 04050; code[003655] = &I03655;
  core[003656] = 02205; code[003656] = &I03656;
  core[003657] = 05560; code[003657] = &I03657;
  core[003660] = 03105; code[003660] = &I03660;
  core[003661] = 02351; code[003661] = &I03661;
  core[003662] = 04061; code[003662] = &P03662;
  core[003663] = 06056; code[003663] = &I03663;
  core[003664] = 06554; code[003664] = &P03664;
  core[003665] = 06160; code[003665] = &P03665;
  core[003666] = 05664; code[003666] = &I03666;
  core[003667] = 06554; code[003667] = &I03667;
  core[003670] = 06160; code[003670] = &P03670;
  core[003671] = 05665; code[003671] = &I03671;
  core[003672] = 07715; code[003672] = &I03672;
  core[003673] = 03704; code[003673] = &P03673;
  core[003674] = 02455; code[003674] = &I03674;
  core[003675] = 04023; code[003675] = &I03675;
  core[003676] = 00524; code[003676] = &I03676;
  core[003677] = 04022; code[003677] = &I03677;
  core[003700] = 00575; code[003700] = &I03700;
  core[003701] = 05561; code[003701] = &I03701;
  core[003702] = 07322; code[003702] = &I03702;
  core[003703] = 07715; code[003703] = &I03703;
  core[003704] = 03721; code[003704] = &P03704;
  core[003705] = 02462; code[003705] = &P03705;
  core[003706] = 01106; code[003706] = &I03706;
  core[003707] = 04050; code[003707] = &I03707;
  core[003710] = 02205; code[003710] = &I03710;
  core[003711] = 05560; code[003711] = &D03711;
  core[003712] = 01617; code[003712] = &I03712;
  core[003713] = 05161; code[003713] = &I03713;
  core[003714] = 06056; code[003714] = &I03714;
  core[003715] = 06654; code[003715] = &I03715;
  core[003716] = 06160; code[003716] = &I03716;
  core[003717] = 05670; code[003717] = &D03717;
  core[003720] = 07715; code[003720] = &I03720;
  core[003721] = 03750; code[003721] = &P03721;
  core[003722] = 02474; code[003722] = &P03722;
  core[003723] = 02440; code[003723] = &I03723;
  core[003724] = 04142; code[003724] = &I03724;
  core[003725] = 02014; code[003725] = &I03725;
  core[003726] = 00501; code[003726] = &I03726;
  core[003727] = 02305; code[003727] = &I03727;
  core[003730] = 04001; code[003730] = &I03730;
  core[003731] = 01623; code[003731] = &P03731;
  core[003732] = 02705; code[003732] = &I03732;
  core[003733] = 02240; code[003733] = &I03733;
  core[003734] = 04731; code[003734] = &I03734;
  core[003735] = 00523; code[003735] = &I03735;
  core[003736] = 04740; code[003736] = &I03736;
  core[003737] = 01722; code[003737] = &I03737;
  core[003740] = 04047; code[003740] = &P03740;
  core[003741] = 01617; code[003741] = &I03741;
  core[003742] = 04740; code[003742] = &I03742;
  core[003743] = 04273; code[003743] = &I03743;
  core[003744] = 00740; code[003744] = &I03744;
  core[003745] = 06160; code[003745] = &I03745;
  core[003746] = 05664; code[003746] = &I03746;
  core[003747] = 07715; code[003747] = &I03747;
  core[003750] = 00000; code[003750] = &P03750;
  core[003751] = 02520; code[003751] = &D03751;
  core[003752] = 02305; code[003752] = &I03752;
  core[003753] = 02440; code[003753] = &I03753;
  core[003754] = 02205; code[003754] = &I03754;
  core[003755] = 07561; code[003755] = &I03755;
  core[003756] = 07322; code[003756] = &I03756;
  core[003757] = 07715; code[003757] = &I03757;
  core[004370] = 02741; code[004370] = &D04370;
  core[004371] = 01370; code[004371] = &L04371;
  core[004372] = 03176; code[004372] = &I04372;
  core[004373] = 06142; code[004373] = &I04373;
  core[004374] = 06077; code[004374] = &I04374;
  core[004375] = 06152; code[004375] = &I04375;
  core[004376] = 06762; code[004376] = &I04376;
  core[004377] = 06012; code[004377] = &I04377;
  core[004400] = 06346; code[004400] = &I04400;
  core[004401] = 06772; code[004401] = &I04401;
  core[004402] = 07300; code[004402] = &I04402;
  core[004403] = 03414; code[004403] = &L04403;
  core[004404] = 02057; code[004404] = &I04404;
  core[004405] = 05203; code[004405] = &I04405;
  core[004406] = 01362; code[004406] = &I04406;
  core[004407] = 04371; code[004407] = &D04407;
  core[004410] = 01370; code[004410] = &I04410;
  core[004411] = 03000; code[004411] = &I04411;
  core[004412] = 07040; code[004412] = &D04412;
  core[004413] = 06167; code[004413] = &I04413;
  core[004414] = 07200; code[004414] = &D04414;
  core[004415] = 06171; code[004415] = &I04415;
  core[004416] = 07650; code[004416] = &I04416;
  core[004417] = 05226; code[004417] = &P04417;
  core[004420] = 01365; code[004420] = &I04420;
  core[004421] = 06141; code[004421] = &I04421;
  core[004422] = 01366; code[004422] = &I04422;
  core[004423] = 06141; code[004423] = &I04423;
  core[004424] = 07200; code[004424] = &I04424;
  core[004425] = 05310; code[004425] = &I04425;
  core[004426] = 06141; code[004426] = &L04426;
  core[004427] = 00017; code[004427] = &I04427;
  core[004430] = 00002; code[004430] = &I04430;
  core[004431] = 07001; code[004431] = &I04431;
  core[004432] = 07650; code[004432] = &I04432;
  core[004433] = 05306; code[004433] = &I04433;
  core[004434] = 07101; code[004434] = &I04434;
  core[004435] = 06344; code[004435] = &I04435;
  core[004436] = 06331; code[004436] = &I04436;
  core[004437] = 07700; code[004437] = &I04437;
  core[004440] = 05246; code[004440] = &I04440;
  core[004441] = 01350; code[004441] = &I04441;
  core[004442] = 03752; code[004442] = &I04442;
  core[004443] = 01351; code[004443] = &I04443;
  core[004444] = 03753; code[004444] = &I04444;
  core[004445] = 05307; code[004445] = &I04445;
  core[004446] = 07354; code[004446] = &L04446;
  core[004447] = 01367; code[004447] = &I04447;
  core[004450] = 07650; code[004450] = &I04450;
  core[004451] = 05265; code[004451] = &I04451;
  core[004452] = 07344; code[004452] = &I04452;
  core[004453] = 01366; code[004453] = &L04453;
  core[004454] = 07650; code[004454] = &P04454;
  core[004455] = 05312; code[004455] = &I04455;
  core[004456] = 01100; code[004456] = &I04456;
  core[004457] = 03764; code[004457] = &I04457;
  core[004460] = 01212; code[004460] = &I04460;
  core[004461] = 03763; code[004461] = &P04461;
  core[004462] = 05313; code[004462] = &I04462;
  core[004463] = 02761; code[004463] = &I04463;
  core[004464] = 05314; code[004464] = &I04464;
  core[004465] = 06046; code[004465] = &L04465;
  core[004466] = 06000; code[004466] = &L04466;
  core[004467] = 06000; code[004467] = &I04467;
  core[004470] = 06000; code[004470] = &I04470;
  core[004471] = 06000; code[004471] = &I04471;
  core[004472] = 06000; code[004472] = &I04472;
  core[004473] = 06000; code[004473] = &I04473;
  core[004474] = 06000; code[004474] = &I04474;
  core[004475] = 06000; code[004475] = &I04475;
  core[004476] = 02057; code[004476] = &I04476;
  core[004477] = 06041; code[004477] = &I04477;
  core[004500] = 05266; code[004500] = &I04500;
  core[004501] = 01057; code[004501] = &I04501;
  core[004502] = 01130; code[004502] = &I04502;
  core[004503] = 07710; code[004503] = &I04503;
  core[004504] = 05311; code[004504] = &I04504;
  core[004505] = 02430; code[004505] = &I04505;
  core[004506] = 02430; code[004506] = &L04506;
  core[004507] = 02430; code[004507] = &L04507;
  core[004510] = 02430; code[004510] = &L04510;
  core[004511] = 02430; code[004511] = &L04511;
  core[004512] = 02430; code[004512] = &L04512;
  core[004513] = 02430; code[004513] = &L04513;
  core[004514] = 06046; code[004514] = &L04514;
  core[004515] = 06001; code[004515] = &I04515;
  core[004516] = 04540; code[004516] = &I04516;
  core[004517] = 00421; code[004517] = &I04517;
  core[004520] = 06002; code[004520] = &I04520;
  core[004521] = 01360; code[004521] = &I04521;
  core[004522] = 04371; code[004522] = &I04522;
  core[004523] = 07450; code[004523] = &I04523;
  core[004524] = 05344; code[004524] = &I04524;
  core[004525] = 07710; code[004525] = &P04525;
  core[004526] = 01366; code[004526] = &I04526;
  core[004527] = 01120; code[004527] = &I04527;
  core[004530] = 03057; code[004530] = &I04530;
  core[004531] = 01354; code[004531] = &I04531;
  core[004532] = 03011; code[004532] = &I04532;
  core[004533] = 01355; code[004533] = &L04533;
  core[004534] = 03411; code[004534] = &I04534;
  core[004535] = 02057; code[004535] = &I04535;
  core[004536] = 05333; code[004536] = &I04536;
  core[004537] = 01360; code[004537] = &I04537;
  core[004540] = 04371; code[004540] = &I04540;
  core[004541] = 07710; code[004541] = &I04541;
  core[004542] = 01104; code[004542] = &I04542;
  core[004543] = 01356; code[004543] = &I04543;
  core[004544] = 01357; code[004544] = &L04544;
  core[004545] = 03035; code[004545] = &D04545;
  core[004546] = 05747; code[004546] = &D04546;
  core[004547] = 02214; code[004547] = &P04547;
  core[004550] = 06313; code[004550] = &D04550;
  core[004551] = 06307; code[004551] = &L04551;
  core[004552] = 01153; code[004552] = &P04552;
  core[004553] = 01156; code[004553] = &P04553;
  core[004554] = 00401; code[004554] = &D04554;
  core[004555] = 02725; code[004555] = &D04555;
  core[004556] = 00560; code[004556] = &D04556;
  core[004557] = 04617; code[004557] = &D04557;
  core[004560] = 03006; code[004560] = &D04560;
  core[004561] = 02661; code[004561] = &P04561;
  core[004562] = 02004; code[004562] = &D04562;
  core[004563] = 06322; code[004563] = &P04563;
  core[004564] = 02654; code[004564] = &P04564;
  core[004565] = 00007; code[004565] = &D04565;
  core[004566] = 00002; code[004566] = &D04566;
  core[004567] = 04002; code[004567] = &D04567;
  core[004570] = 04462; code[004570] = &D04570;
  core[004571] = 02344; code[004571] = &P04571;
  core[004572] = 03061; code[004572] = &I04572;
  core[004573] = 04540; code[004573] = &I04573;
  core[004574] = 01437; code[004574] = &I04574;
  core[004575] = 02030; code[004575] = &I04575;
  core[004576] = 01430; code[004576] = &I04576;
  core[004577] = 05771; code[004577] = &I04577;
  core[004620] = 01045; code[004620] = &I04620;
  core[004621] = 07710; code[004621] = &I04621;
  core[004622] = 04724; code[004622] = &I04622;
  core[004623] = 03033; code[004623] = &I04623;
  core[004624] = 04407; code[004624] = &I04624;
  core[004625] = 04313; code[004625] = &I04625;
  core[004626] = 06675; code[004626] = &I04626;
  core[004627] = 00000; code[004627] = &I04627;
  core[004630] = 04453; code[004630] = &I04630;
  core[004631] = 03325; code[004631] = &I04631;
  core[004632] = 04407; code[004632] = &I04632;
  core[004633] = 07000; code[004633] = &I04633;
  core[004634] = 06676; code[004634] = &I04634;
  core[004635] = 00675; code[004635] = &I04635;
  core[004636] = 02676; code[004636] = &I04636;
  core[004637] = 06675; code[004637] = &D04637;
  core[004640] = 04675; code[004640] = &I04640;
  core[004641] = 06676; code[004641] = &I04641;
  core[004642] = 01310; code[004642] = &I04642;
  core[004643] = 06326; code[004643] = &P04643;
  core[004644] = 00305; code[004644] = &I04644;
  core[004645] = 03326; code[004645] = &I04645;
  core[004646] = 02675; code[004646] = &P04646;
  core[004647] = 01277; code[004647] = &I04647;
  core[004650] = 06326; code[004650] = &I04650;
  core[004651] = 00302; code[004651] = &I04651;
  core[004652] = 04676; code[004652] = &I04652;
  core[004653] = 01326; code[004653] = &I04653;
  core[004654] = 06326; code[004654] = &I04654;
  core[004655] = 00675; code[004655] = &I04655;
  core[004656] = 03326; code[004656] = &I04656;
  core[004657] = 04321; code[004657] = &I04657;
  core[004660] = 01316; code[004660] = &I04660;
  core[004661] = 00000; code[004661] = &I04661;
  core[004662] = 01325; code[004662] = &I04662;
  core[004663] = 01044; code[004663] = &I04663;
  core[004664] = 03044; code[004664] = &I04664;
  core[004665] = 02033; code[004665] = &I04665;
  core[004666] = 05536; code[004666] = &I04666;
  core[004667] = 04407; code[004667] = &I04667;
  core[004670] = 06675; code[004670] = &I04670;
  core[004671] = 00316; code[004671] = &I04671;
  core[004672] = 03675; code[004672] = &I04672;
  core[004673] = 00000; code[004673] = &I04673;
  core[004674] = 05536; code[004674] = &I04674;
  core[004675] = 05322; code[004675] = &P04675;
  core[004676] = 05326; code[004676] = &P04676;
  core[004677] = 00004; code[004677] = &D04677;
  core[004700] = 02372; code[004700] = &I04700;
  core[004701] = 01402; code[004701] = &I04701;
  core[004702] = 07774; code[004702] = &I04702;
  core[004703] = 02157; code[004703] = &I04703;
  core[004704] = 05157; code[004704] = &D04704;
  core[004705] = 00012; code[004705] = &P04705;
  core[004706] = 05454; code[004706] = &D04706;
  core[004707] = 00343; code[004707] = &I04707;
  core[004710] = 00007; code[004710] = &D04710;
  core[004711] = 02566; code[004711] = &I04711;
  core[004712] = 05341; code[004712] = &I04712;
  core[004713] = 00001; code[004713] = &D04713;
  core[004714] = 02705; code[004714] = &I04714;
  core[004715] = 02435; code[004715] = &I04715;
  core[004716] = 00001; code[004716] = &D04716;
  core[004717] = 02000; code[004717] = &I04717;
  core[004720] = 00000; code[004720] = &I04720;
  core[004721] = 00002; code[004721] = &D04721;
  core[004722] = 02000; code[004722] = &L04722;
  core[004723] = 00000; code[004723] = &D04723;
  core[004724] = 05163; code[004724] = &P04724;
  core[004725] = 00000; code[004725] = &D04725;
  core[004726] = 00000; code[004726] = &L04726;
  core[004727] = 00000; code[004727] = &I04727;
  core[004730] = 00000; code[004730] = &I04730;
  core[004731] = 00000; code[004731] = &I04731;
  core[004732] = 04407; code[004732] = &L04732;
  core[004733] = 00675; code[004733] = &I04733;
  core[004734] = 04675; code[004734] = &I04734;
  core[004735] = 06676; code[004735] = &I04735;
  core[004736] = 04374; code[004736] = &I04736;
  core[004737] = 01371; code[004737] = &I04737;
  core[004740] = 04676; code[004740] = &I04740;
  core[004741] = 01366; code[004741] = &L04741;
  core[004742] = 06326; code[004742] = &I04742;
  core[004743] = 00363; code[004743] = &D04743;
  core[004744] = 04676; code[004744] = &I04744;
  core[004745] = 01360; code[004745] = &I04745;
  core[004746] = 04676; code[004746] = &I04746;
  core[004747] = 01355; code[004747] = &I04747;
  core[004750] = 04675; code[004750] = &I04750;
  core[004751] = 03326; code[004751] = &I04751;
  core[004752] = 00000; code[004752] = &I04752;
  core[004753] = 05754; code[004753] = &I04753;
  core[004754] = 05024; code[004754] = &P04754;
  core[004755] = 00000; code[004755] = &D04755;
  core[004756] = 02437; code[004756] = &I04756;
  core[004757] = 01643; code[004757] = &I04757;
  core[004760] = 07777; code[004760] = &D04760;
  core[004761] = 03304; code[004761] = &I04761;
  core[004762] = 04434; code[004762] = &I04762;
  core[004763] = 07773; code[004763] = &I04763;
  core[004764] = 03306; code[004764] = &I04764;
  core[004765] = 05454; code[004765] = &I04765;
  core[004766] = 00000; code[004766] = &D04766;
  core[004767] = 02437; code[004767] = &I04767;
  core[004770] = 01646; code[004770] = &I04770;
  core[004771] = 00000; code[004771] = &D04771;
  core[004772] = 02427; code[004772] = &D04772;
  core[004773] = 02323; code[004773] = &I04773;
  core[004774] = 07775; code[004774] = &D04774;
  core[004775] = 03427; code[004775] = &I04775;
  core[004776] = 07052; code[004776] = &I04776;
  core[005000] = 01045; code[005000] = &I05000;
  core[005001] = 07710; code[005001] = &I05001;
  core[005002] = 04363; code[005002] = &I05002;
  core[005003] = 03033; code[005003] = &I05003;
  core[005004] = 04407; code[005004] = &I05004;
  core[005005] = 06635; code[005005] = &I05005;
  core[005006] = 02637; code[005006] = &I05006;
  core[005007] = 00000; code[005007] = &I05007;
  core[005010] = 01045; code[005010] = &I05010;
  core[005011] = 07710; code[005011] = &I05011;
  core[005012] = 05221; code[005012] = &I05012;
  core[005013] = 04407; code[005013] = &P05013;
  core[005014] = 00637; code[005014] = &I05014;
  core[005015] = 03635; code[005015] = &I05015;
  core[005016] = 06635; code[005016] = &I05016;
  core[005017] = 00000; code[005017] = &I05017;
  core[005020] = 07240; code[005020] = &I05020;
  core[005021] = 03362; code[005021] = &L05021;
  core[005022] = 05623; code[005022] = &I05022;
  core[005023] = 04732; code[005023] = &P05023;
  core[005024] = 02362; code[005024] = &L05024;
  core[005025] = 05634; code[005025] = &I05025;
  core[005026] = 04407; code[005026] = &I05026;
  core[005027] = 06635; code[005027] = &I05027;
  core[005030] = 00636; code[005030] = &I05030;
  core[005031] = 02635; code[005031] = &I05031;
  core[005032] = 00000; code[005032] = &I05032;
  core[005033] = 05634; code[005033] = &I05033;
  core[005034] = 05302; code[005034] = &P05034;
  core[005035] = 05322; code[005035] = &P05035;
  core[005036] = 05316; code[005036] = &D05036;
  core[005037] = 04716; code[005037] = &P05037;
  core[005040] = 01045; code[005040] = &I05040;
  core[005041] = 07450; code[005041] = &I05041;
  core[005042] = 04566; code[005042] = &I05042;
  core[005043] = 07710; code[005043] = &I05043;
  core[005044] = 04451; code[005044] = &I05044;
  core[005045] = 04407; code[005045] = &I05045;
  core[005046] = 06756; code[005046] = &I05046;
  core[005047] = 02637; code[005047] = &I05047;
  core[005050] = 00000; code[005050] = &I05050;
  core[005051] = 01045; code[005051] = &I05051;
  core[005052] = 07450; code[005052] = &I05052;
  core[005053] = 05536; code[005053] = &I05053;
  core[005054] = 07700; code[005054] = &I05054;
  core[005055] = 05264; code[005055] = &I05055;
  core[005056] = 04407; code[005056] = &I05056;
  core[005057] = 00637; code[005057] = &I05057;
  core[005060] = 03756; code[005060] = &I05060;
  core[005061] = 06756; code[005061] = &I05061;
  core[005062] = 00000; code[005062] = &I05062;
  core[005063] = 07240; code[005063] = &I05063;
  core[005064] = 03033; code[005064] = &L05064;
  core[005065] = 01005; code[005065] = &I05065;
  core[005066] = 03044; code[005066] = &I05066;
  core[005067] = 07040; code[005067] = &I05067;
  core[005070] = 01756; code[005070] = &I05070;
  core[005071] = 03045; code[005071] = &I05071;
  core[005072] = 03046; code[005072] = &I05072;
  core[005073] = 03047; code[005073] = &I05073;
  core[005074] = 07001; code[005074] = &I05074;
  core[005075] = 03756; code[005075] = &I05075;
  core[005076] = 04407; code[005076] = &I05076;
  core[005077] = 04357; code[005077] = &I05077;
  core[005100] = 06635; code[005100] = &I05100;
  core[005101] = 00756; code[005101] = &D05101;
  core[005102] = 02637; code[005102] = &L05102;
  core[005103] = 06756; code[005103] = &I05103;
  core[005104] = 04353; code[005104] = &I05104;
  core[005105] = 01350; code[005105] = &I05105;
  core[005106] = 04756; code[005106] = &I05106;
  core[005107] = 01345; code[005107] = &D05107;
  core[005110] = 04756; code[005110] = &I05110;
  core[005111] = 01342; code[005111] = &I05111;
  core[005112] = 04756; code[005112] = &I05112;
  core[005113] = 01337; code[005113] = &I05113;
  core[005114] = 04756; code[005114] = &I05114;
  core[005115] = 01334; code[005115] = &I05115;
  core[005116] = 04756; code[005116] = &P05116;
  core[005117] = 01331; code[005117] = &I05117;
  core[005120] = 04756; code[005120] = &I05120;
  core[005121] = 01326; code[005121] = &I05121;
  core[005122] = 04756; code[005122] = &L05122;
  core[005123] = 01635; code[005123] = &I05123;
  core[005124] = 00000; code[005124] = &I05124;
  core[005125] = 05634; code[005125] = &I05125;
  core[005126] = 00000; code[005126] = &P05126;
  core[005127] = 03777; code[005127] = &I05127;
  core[005130] = 07742; code[005130] = &I05130;
  core[005131] = 07777; code[005131] = &D05131;
  core[005132] = 04000; code[005132] = &P05132;
  core[005133] = 04100; code[005133] = &I05133;
  core[005134] = 07777; code[005134] = &D05134;
  core[005135] = 02517; code[005135] = &P05135;
  core[005136] = 00307; code[005136] = &I05136;
  core[005137] = 07776; code[005137] = &D05137;
  core[005140] = 04113; code[005140] = &I05140;
  core[005141] = 07211; code[005141] = &I05141;
  core[005142] = 07776; code[005142] = &D05142;
  core[005143] = 02535; code[005143] = &I05143;
  core[005144] = 03301; code[005144] = &I05144;
  core[005145] = 07775; code[005145] = &D05145;
  core[005146] = 04746; code[005146] = &P05146;
  core[005147] = 00771; code[005147] = &I05147;
  core[005150] = 07774; code[005150] = &D05150;
  core[005151] = 02236; code[005151] = &I05151;
  core[005152] = 04304; code[005152] = &I05152;
  core[005153] = 07771; code[005153] = &D05153;
  core[005154] = 04544; code[005154] = &I05154;
  core[005155] = 01735; code[005155] = &I05155;
  core[005156] = 04726; code[005156] = &P05156;
  core[005157] = 00000; code[005157] = &D05157;
  core[005160] = 02613; code[005160] = &I05160;
  core[005161] = 04414; code[005161] = &I05161;
  core[005162] = 00000; code[005162] = &D05162;
  core[005163] = 00000; code[005163] = &S05163;
  core[005164] = 04451; code[005164] = &I05164;
  core[005165] = 07240; code[005165] = &I05165;
  core[005166] = 05763; code[005166] = &I05166;
  core[005200] = 04407; code[005200] = &D05200;
  core[005201] = 06322; code[005201] = &I05201;
  core[005202] = 00316; code[005202] = &I05202;
  core[005203] = 02322; code[005203] = &I05203;
  core[005204] = 00000; code[005204] = &I05204;
  core[005205] = 01045; code[005205] = &I05205;
  core[005206] = 07740; code[005206] = &I05206;
  core[005207] = 05215; code[005207] = &I05207;
  core[005210] = 01045; code[005210] = &I05210;
  core[005211] = 07700; code[005211] = &I05211;
  core[005212] = 05536; code[005212] = &I05212;
  core[005213] = 04451; code[005213] = &I05213;
  core[005214] = 07040; code[005214] = &I05214;
  core[005215] = 03033; code[005215] = &L05215;
  core[005216] = 04407; code[005216] = &I05216;
  core[005217] = 03306; code[005217] = &I05217;
  core[005220] = 06326; code[005220] = &I05220;
  core[005221] = 00000; code[005221] = &I05221;
  core[005222] = 04453; code[005222] = &I05222;
  core[005223] = 04407; code[005223] = &I05223;
  core[005224] = 07000; code[005224] = &I05224;
  core[005225] = 06322; code[005225] = &I05225;
  core[005226] = 00326; code[005226] = &I05226;
  core[005227] = 02322; code[005227] = &I05227;
  core[005230] = 04306; code[005230] = &I05230;
  core[005231] = 06322; code[005231] = &I05231;
  core[005232] = 02312; code[005232] = &I05232;
  core[005233] = 00000; code[005233] = &I05233;
  core[005234] = 01045; code[005234] = &I05234;
  core[005235] = 07710; code[005235] = &D05235;
  core[005236] = 05245; code[005236] = &I05236;
  core[005237] = 04407; code[005237] = &I05237;
  core[005240] = 06322; code[005240] = &I05240;
  core[005241] = 00000; code[005241] = &I05241;
  core[005242] = 01033; code[005242] = &I05242;
  core[005243] = 07040; code[005243] = &I05243;
  core[005244] = 03033; code[005244] = &I05244;
  core[005245] = 04407; code[005245] = &L05245;
  core[005246] = 00322; code[005246] = &I05246;
  core[005247] = 02316; code[005247] = &I05247;
  core[005250] = 00000; code[005250] = &I05250;
  core[005251] = 01045; code[005251] = &I05251;
  core[005252] = 07710; code[005252] = &I05252;
  core[005253] = 05261; code[005253] = &I05253;
  core[005254] = 04407; code[005254] = &I05254;
  core[005255] = 00312; code[005255] = &I05255;
  core[005256] = 02322; code[005256] = &I05256;
  core[005257] = 06322; code[005257] = &I05257;
  core[005260] = 00000; code[005260] = &I05260;
  core[005261] = 04407; code[005261] = &L05261;
  core[005262] = 00322; code[005262] = &I05262;
  core[005263] = 03316; code[005263] = &I05263;
  core[005264] = 06322; code[005264] = &I05264;
  core[005265] = 04322; code[005265] = &I05265;
  core[005266] = 06326; code[005266] = &I05266;
  core[005267] = 00332; code[005267] = &I05267;
  core[005270] = 04326; code[005270] = &I05270;
  core[005271] = 01336; code[005271] = &I05271;
  core[005272] = 04326; code[005272] = &I05272;
  core[005273] = 01342; code[005273] = &I05273;
  core[005274] = 04326; code[005274] = &I05274;
  core[005275] = 01346; code[005275] = &I05275;
  core[005276] = 04326; code[005276] = &I05276;
  core[005277] = 01316; code[005277] = &I05277;
  core[005300] = 04322; code[005300] = &I05300;
  core[005301] = 00000; code[005301] = &I05301;
  core[005302] = 02033; code[005302] = &L05302;
  core[005303] = 05536; code[005303] = &I05303;
  core[005304] = 04451; code[005304] = &I05304;
  core[005305] = 05536; code[005305] = &I05305;
  core[005306] = 00003; code[005306] = &D05306;
  core[005307] = 03110; code[005307] = &I05307;
  core[005310] = 03756; code[005310] = &I05310;
  core[005311] = 03235; code[005311] = &I05311;
  core[005312] = 00002; code[005312] = &D05312;
  core[005313] = 03110; code[005313] = &I05313;
  core[005314] = 03756; code[005314] = &I05314;
  core[005315] = 03235; code[005315] = &I05315;
  core[005316] = 00001; code[005316] = &D05316;
  core[005317] = 03110; code[005317] = &I05317;
  core[005320] = 03756; code[005320] = &I05320;
  core[005321] = 03235; code[005321] = &I05321;
  core[005322] = 00000; code[005322] = &D05322;
  core[005323] = 00000; code[005323] = &I05323;
  core[005324] = 00000; code[005324] = &I05324;
  core[005325] = 00000; code[005325] = &L05325;
  core[005326] = 00000; code[005326] = &D05326;
  core[005327] = 00000; code[005327] = &I05327;
  core[005330] = 00000; code[005330] = &I05330;
  core[005331] = 00000; code[005331] = &I05331;
  core[005332] = 07764; code[005332] = &I05332;
  core[005333] = 02401; code[005333] = &I05333;
  core[005334] = 07015; code[005334] = &I05334;
  core[005335] = 01042; code[005335] = &I05335;
  core[005336] = 07771; code[005336] = &P05336;
  core[005337] = 05464; code[005337] = &I05337;
  core[005340] = 05514; code[005340] = &I05340;
  core[005341] = 06150; code[005341] = &I05341;
  core[005342] = 07775; code[005342] = &D05342;
  core[005343] = 02431; code[005343] = &I05343;
  core[005344] = 05361; code[005344] = &I05344;
  core[005345] = 04736; code[005345] = &I05345;
  core[005346] = 00000; code[005346] = &D05346;
  core[005347] = 05325; code[005347] = &I05347;
  core[005350] = 00414; code[005350] = &I05350;
  core[005351] = 03167; code[005351] = &I05351;
  core[005400] = 00000; code[005400] = &S05400;
  core[005401] = 03334; code[005401] = &I05401;
  core[005402] = 01052; code[005402] = &I05402;
  core[005403] = 04557; code[005403] = &D05403;
  core[005404] = 00122; code[005404] = &I05404;
  core[005405] = 03032; code[005405] = &I05405;
  core[005406] = 01032; code[005406] = &I05406;
  core[005407] = 07041; code[005407] = &I05407;
  core[005410] = 07450; code[005410] = &I05410;
  core[005411] = 01326; code[005411] = &I05411;
  core[005412] = 03335; code[005412] = &I05412;
  core[005413] = 01052; code[005413] = &I05413;
  core[005414] = 07450; code[005414] = &I05414;
  core[005415] = 05241; code[005415] = &I05415;
  core[005416] = 00122; code[005416] = &I05416;
  core[005417] = 03333; code[005417] = &I05417;
  core[005420] = 01335; code[005420] = &I05420;
  core[005421] = 01333; code[005421] = &I05421;
  core[005422] = 07510; code[005422] = &I05422;
  core[005423] = 05230; code[005423] = &I05423;
  core[005424] = 07240; code[005424] = &I05424;
  core[005425] = 01032; code[005425] = &I05425;
  core[005426] = 03333; code[005426] = &I05426;
  core[005427] = 07040; code[005427] = &I05427;
  core[005430] = 01033; code[005430] = &L05430;
  core[005431] = 07500; code[005431] = &I05431;
  core[005432] = 07200; code[005432] = &I05432;
  core[005433] = 01032; code[005433] = &I05433;
  core[005434] = 07510; code[005434] = &I05434;
  core[005435] = 05263; code[005435] = &I05435;
  core[005436] = 01326; code[005436] = &I05436;
  core[005437] = 07500; code[005437] = &I05437;
  core[005440] = 07200; code[005440] = &I05440;
  core[005441] = 01327; code[005441] = &L05441;
  core[005442] = 03071; code[005442] = &I05442;
  core[005443] = 01731; code[005443] = &I05443;
  core[005444] = 01071; code[005444] = &I05444;
  core[005445] = 03336; code[005445] = &I05445;
  core[005446] = 01071; code[005446] = &I05446;
  core[005447] = 07041; code[005447] = &I05447;
  core[005450] = 03071; code[005450] = &I05450;
  core[005451] = 01325; code[005451] = &I05451;
  core[005452] = 02736; code[005452] = &L05452;
  core[005453] = 01736; code[005453] = &I05453;
  core[005454] = 01330; code[005454] = &I05454;
  core[005455] = 07710; code[005455] = &I05455;
  core[005456] = 05265; code[005456] = &I05456;
  core[005457] = 03736; code[005457] = &I05457;
  core[005460] = 02071; code[005460] = &I05460;
  core[005461] = 05321; code[005461] = &L05461;
  core[005462] = 02736; code[005462] = &I05462;
  core[005463] = 02033; code[005463] = &L05463;
  core[005464] = 07200; code[005464] = &I05464;
  core[005465] = 01052; code[005465] = &L05465;
  core[005466] = 07650; code[005466] = &I05466;
  core[005467] = 05356; code[005467] = &I05467;
  core[005470] = 01335; code[005470] = &I05470;
  core[005471] = 01033; code[005471] = &D05471;
  core[005472] = 07540; code[005472] = &I05472;
  core[005473] = 05355; code[005473] = &I05473;
  core[005474] = 01333; code[005474] = &I05474;
  core[005475] = 07500; code[005475] = &I05475;
  core[005476] = 07200; code[005476] = &I05476;
  core[005477] = 07041; code[005477] = &I05477;
  core[005500] = 01033; code[005500] = &I05500;
  core[005501] = 07041; code[005501] = &I05501;
  core[005502] = 03032; code[005502] = &I05502;
  core[005503] = 01033; code[005503] = &L05503;
  core[005504] = 01032; code[005504] = &I05504;
  core[005505] = 07650; code[005505] = &I05505;
  core[005506] = 05343; code[005506] = &I05506;
  core[005507] = 01032; code[005507] = &I05507;
  core[005510] = 07001; code[005510] = &I05510;
  core[005511] = 07710; code[005511] = &I05511;
  core[005512] = 01105; code[005512] = &I05512;
  core[005513] = 04336; code[005513] = &L05513;
  core[005514] = 02032; code[005514] = &I05514;
  core[005515] = 05303; code[005515] = &I05515;
  core[005516] = 01102; code[005516] = &I05516;
  core[005517] = 04551; code[005517] = &I05517;
  core[005520] = 05303; code[005520] = &I05520;
  core[005521] = 07040; code[005521] = &L05521;
  core[005522] = 01336; code[005522] = &I05522;
  core[005523] = 03336; code[005523] = &I05523;
  core[005524] = 05252; code[005524] = &I05524;
  core[005525] = 00005; code[005525] = &D05525;
  core[005526] = 07772; code[005526] = &D05526;
  core[005527] = 00007; code[005527] = &D05527;
  core[005530] = 07766; code[005530] = &D05530;
  core[005531] = 06150; code[005531] = &P05531;
  core[005532] = 06154; code[005532] = &P05532;
  core[005533] = 00000; code[005533] = &D05533;
  core[005534] = 00000; code[005534] = &D05534;
  core[005535] = 00000; code[005535] = &D05535;
  core[005536] = 00000; code[005536] = &S05536;
  core[005537] = 04732; code[005537] = &I05537;
  core[005540] = 02335; code[005540] = &I05540;
  core[005541] = 05736; code[005541] = &D05541;
  core[005542] = 05600; code[005542] = &I05542;
  core[005543] = 07040; code[005543] = &L05543;
  core[005544] = 01033; code[005544] = &I05544;
  core[005545] = 03033; code[005545] = &I05545;
  core[005546] = 02334; code[005546] = &I05546;
  core[005547] = 05353; code[005547] = &I05547;
  core[005550] = 07040; code[005550] = &I05550;
  core[005551] = 03334; code[005551] = &I05551;
  core[005552] = 05313; code[005552] = &I05552;
  core[005553] = 01414; code[005553] = &L05553;
  core[005554] = 05313; code[005554] = &I05554;
  core[005555] = 07200; code[005555] = &L05555;
  core[005556] = 04732; code[005556] = &L05556;
  core[005557] = 01102; code[005557] = &I05557;
  core[005560] = 04551; code[005560] = &I05560;
  core[005561] = 02200; code[005561] = &I05561;
  core[005562] = 01414; code[005562] = &L05562;
  core[005563] = 04336; code[005563] = &L05563;
  core[005564] = 02334; code[005564] = &I05564;
  core[005565] = 05362; code[005565] = &I05565;
  core[005566] = 07040; code[005566] = &I05566;
  core[005567] = 03334; code[005567] = &I05567;
  core[005570] = 05363; code[005570] = &I05570;
  core[005571] = 00000; code[005571] = &S05571;
  core[005572] = 01045; code[005572] = &I05572;
  core[005573] = 03050; code[005573] = &I05573;
  core[005574] = 01045; code[005574] = &I05574;
  core[005575] = 07710; code[005575] = &I05575;
  core[005576] = 04451; code[005576] = &L05576;
  core[005577] = 05771; code[005577] = &I05577;
  core[005600] = 00000; code[005600] = &S05600;
  core[005601] = 03046; code[005601] = &I05601;
  core[005602] = 03044; code[005602] = &I05602;
  core[005603] = 03045; code[005603] = &I05603;
  core[005604] = 03047; code[005604] = &I05604;
  core[005605] = 03314; code[005605] = &I05605;
  core[005606] = 03050; code[005606] = &I05606;
  core[005607] = 01066; code[005607] = &I05607;
  core[005610] = 01264; code[005610] = &I05610;
  core[005611] = 07450; code[005611] = &I05611;
  core[005612] = 05220; code[005612] = &I05612;
  core[005613] = 01111; code[005613] = &I05613;
  core[005614] = 07640; code[005614] = &I05614;
  core[005615] = 05221; code[005615] = &I05615;
  core[005616] = 07040; code[005616] = &I05616;
  core[005617] = 03050; code[005617] = &I05617;
  core[005620] = 04666; code[005620] = &L05620;
  core[005621] = 01066; code[005621] = &L05621;
  core[005622] = 01265; code[005622] = &I05622;
  core[005623] = 07650; code[005623] = &I05623;
  core[005624] = 05220; code[005624] = &I05624;
  core[005625] = 04227; code[005625] = &I05625;
  core[005626] = 05600; code[005626] = &I05626;
  core[005627] = 00000; code[005627] = &S05627;
  core[005630] = 01066; code[005630] = &L05630;
  core[005631] = 01262; code[005631] = &I05631;
  core[005632] = 07650; code[005632] = &I05632;
  core[005633] = 05627; code[005633] = &I05633;
  core[005634] = 04561; code[005634] = &I05634;
  core[005635] = 05627; code[005635] = &I05635;
  core[005636] = 05247; code[005636] = &I05636;
  core[005637] = 01054; code[005637] = &I05637;
  core[005640] = 03313; code[005640] = &L05640;
  core[005641] = 04267; code[005641] = &I05641;
  core[005642] = 02314; code[005642] = &I05642;
  core[005643] = 07640; code[005643] = &I05643;
  core[005644] = 04566; code[005644] = &I05644;
  core[005645] = 04666; code[005645] = &I05645;
  core[005646] = 05230; code[005646] = &I05646;
  core[005647] = 01066; code[005647] = &L05647;
  core[005650] = 01112; code[005650] = &I05650;
  core[005651] = 07710; code[005651] = &I05651;
  core[005652] = 05627; code[005652] = &I05652;
  core[005653] = 01066; code[005653] = &I05653;
  core[005654] = 01263; code[005654] = &I05654;
  core[005655] = 07740; code[005655] = &I05655;
  core[005656] = 05627; code[005656] = &I05656;
  core[005657] = 01066; code[005657] = &I05657;
  core[005660] = 00122; code[005660] = &I05660;
  core[005661] = 05240; code[005661] = &I05661;
  core[005662] = 07473; code[005662] = &D05662;
  core[005663] = 07446; code[005663] = &D05663;
  core[005664] = 07525; code[005664] = &D05664;
  core[005665] = 07540; code[005665] = &D05665;
  core[005666] = 00756; code[005666] = &P05666;
  core[005667] = 00000; code[005667] = &S05667;
  core[005670] = 01047; code[005670] = &I05670;
  core[005671] = 03043; code[005671] = &I05671;
  core[005672] = 01046; code[005672] = &I05672;
  core[005673] = 03042; code[005673] = &I05673;
  core[005674] = 01045; code[005674] = &I05674;
  core[005675] = 03041; code[005675] = &I05675;
  core[005676] = 03312; code[005676] = &I05676;
  core[005677] = 04315; code[005677] = &I05677;
  core[005700] = 04315; code[005700] = &I05700;
  core[005701] = 04333; code[005701] = &I05701;
  core[005702] = 04315; code[005702] = &I05702;
  core[005703] = 01313; code[005703] = &I05703;
  core[005704] = 03043; code[005704] = &I05704;
  core[005705] = 03042; code[005705] = &I05705;
  core[005706] = 03041; code[005706] = &I05706;
  core[005707] = 04333; code[005707] = &I05707;
  core[005710] = 01312; code[005710] = &I05710;
  core[005711] = 05667; code[005711] = &I05711;
  core[005712] = 00000; code[005712] = &D05712;
  core[005713] = 00000; code[005713] = &D05713;
  core[005714] = 00000; code[005714] = &D05714;
  core[005715] = 00000; code[005715] = &S05715;
  core[005716] = 01047; code[005716] = &I05716;
  core[005717] = 07104; code[005717] = &I05717;
  core[005720] = 03047; code[005720] = &I05720;
  core[005721] = 01046; code[005721] = &I05721;
  core[005722] = 07004; code[005722] = &I05722;
  core[005723] = 03046; code[005723] = &I05723;
  core[005724] = 01045; code[005724] = &I05724;
  core[005725] = 07004; code[005725] = &I05725;
  core[005726] = 03045; code[005726] = &I05726;
  core[005727] = 01312; code[005727] = &I05727;
  core[005730] = 07004; code[005730] = &I05730;
  core[005731] = 03312; code[005731] = &I05731;
  core[005732] = 05715; code[005732] = &I05732;
  core[005733] = 00000; code[005733] = &S05733;
  core[005734] = 07300; code[005734] = &I05734;
  core[005735] = 01047; code[005735] = &I05735;
  core[005736] = 01043; code[005736] = &I05736;
  core[005737] = 03047; code[005737] = &I05737;
  core[005740] = 07004; code[005740] = &I05740;
  core[005741] = 01046; code[005741] = &I05741;
  core[005742] = 01042; code[005742] = &I05742;
  core[005743] = 03046; code[005743] = &I05743;
  core[005744] = 07004; code[005744] = &I05744;
  core[005745] = 01045; code[005745] = &I05745;
  core[005746] = 01041; code[005746] = &I05746;
  core[005747] = 03045; code[005747] = &I05747;
  core[005750] = 07004; code[005750] = &I05750;
  core[005751] = 01312; code[005751] = &I05751;
  core[005752] = 03312; code[005752] = &I05752;
  core[005753] = 05733; code[005753] = &I05753;
  core[005754] = 00000; code[005754] = &S05754;
  core[005755] = 07300; code[005755] = &I05755;
  core[005756] = 01041; code[005756] = &P05756;
  core[005757] = 07510; code[005757] = &I05757;
  core[005760] = 07120; code[005760] = &I05760;
  core[005761] = 07010; code[005761] = &I05761;
  core[005762] = 03041; code[005762] = &I05762;
  core[005763] = 01042; code[005763] = &I05763;
  core[005764] = 07010; code[005764] = &I05764;
  core[005765] = 03042; code[005765] = &I05765;
  core[005766] = 01043; code[005766] = &I05766;
  core[005767] = 07010; code[005767] = &I05767;
  core[005770] = 03043; code[005770] = &I05770;
  core[005771] = 02040; code[005771] = &I05771;
  core[005772] = 05754; code[005772] = &I05772;
  core[005773] = 05754; code[005773] = &I05773;
  core[006000] = 00000; code[006000] = &S06000;
  core[006001] = 01335; code[006001] = &I06001;
  core[006002] = 04551; code[006002] = &I06002;
  core[006003] = 01045; code[006003] = &I06003;
  core[006004] = 07700; code[006004] = &I06004;
  core[006005] = 01334; code[006005] = &I06005;
  core[006006] = 01336; code[006006] = &I06006;
  core[006007] = 04551; code[006007] = &I06007;
  core[006010] = 04753; code[006010] = &I06010;
  core[006011] = 03033; code[006011] = &L06011;
  core[006012] = 01044; code[006012] = &I06012;
  core[006013] = 07510; code[006013] = &I06013;
  core[006014] = 05227; code[006014] = &I06014;
  core[006015] = 07440; code[006015] = &I06015;
  core[006016] = 01341; code[006016] = &I06016;
  core[006017] = 07750; code[006017] = &I06017;
  core[006020] = 05234; code[006020] = &I06020;
  core[006021] = 04407; code[006021] = &I06021;
  core[006022] = 04744; code[006022] = &I06022;
  core[006023] = 00000; code[006023] = &I06023;
  core[006024] = 07001; code[006024] = &I06024;
  core[006025] = 01033; code[006025] = &L06025;
  core[006026] = 05211; code[006026] = &I06026;
  core[006027] = 04407; code[006027] = &L06027;
  core[006030] = 04752; code[006030] = &I06030;
  core[006031] = 00000; code[006031] = &I06031;
  core[006032] = 07040; code[006032] = &I06032;
  core[006033] = 05225; code[006033] = &I06033;
  core[006034] = 03745; code[006034] = &L06034;
  core[006035] = 03746; code[006035] = &I06035;
  core[006036] = 01350; code[006036] = &I06036;
  core[006037] = 03014; code[006037] = &I06037;
  core[006040] = 01044; code[006040] = &I06040;
  core[006041] = 07140; code[006041] = &I06041;
  core[006042] = 03354; code[006042] = &I06042;
  core[006043] = 01343; code[006043] = &I06043;
  core[006044] = 03044; code[006044] = &I06044;
  core[006045] = 04527; code[006045] = &L06045;
  core[006046] = 02354; code[006046] = &I06046;
  core[006047] = 05245; code[006047] = &I06047;
  core[006050] = 01746; code[006050] = &I06050;
  core[006051] = 07450; code[006051] = &I06051;
  core[006052] = 05270; code[006052] = &I06052;
  core[006053] = 01342; code[006053] = &I06053;
  core[006054] = 07710; code[006054] = &I06054;
  core[006055] = 05264; code[006055] = &D06055;
  core[006056] = 07001; code[006056] = &I06056;
  core[006057] = 03414; code[006057] = &I06057;
  core[006060] = 02044; code[006060] = &I06060;
  core[006061] = 01342; code[006061] = &I06061;
  core[006062] = 02033; code[006062] = &I06062;
  core[006063] = 07000; code[006063] = &I06063;
  core[006064] = 01746; code[006064] = &L06064;
  core[006065] = 02033; code[006065] = &I06065;
  core[006066] = 07000; code[006066] = &I06066;
  core[006067] = 07410; code[006067] = &P06067;
  core[006070] = 04747; code[006070] = &L06070;
  core[006071] = 03414; code[006071] = &I06071;
  core[006072] = 02044; code[006072] = &I06072;
  core[006073] = 05270; code[006073] = &I06073;
  core[006074] = 01350; code[006074] = &I06074;
  core[006075] = 03014; code[006075] = &D06075;
  core[006076] = 01343; code[006076] = &I06076;
  core[006077] = 04751; code[006077] = &I06077;
  core[006100] = 05600; code[006100] = &I06100;
  core[006101] = 01333; code[006101] = &I06101;
  core[006102] = 04551; code[006102] = &I06102;
  core[006103] = 01033; code[006103] = &I06103;
  core[006104] = 07510; code[006104] = &I06104;
  core[006105] = 07041; code[006105] = &D06105;
  core[006106] = 03045; code[006106] = &I06106;
  core[006107] = 01033; code[006107] = &I06107;
  core[006110] = 07700; code[006110] = &I06110;
  core[006111] = 01111; code[006111] = &I06111;
  core[006112] = 01336; code[006112] = &P06112;
  core[006113] = 04551; code[006113] = &P06113;
  core[006114] = 01045; code[006114] = &I06114;
  core[006115] = 02044; code[006115] = &L06115;
  core[006116] = 01337; code[006116] = &I06116;
  core[006117] = 07500; code[006117] = &I06117;
  core[006120] = 05315; code[006120] = &I06120;
  core[006121] = 01340; code[006121] = &I06121;
  core[006122] = 03045; code[006122] = &I06122;
  core[006123] = 07040; code[006123] = &I06123;
  core[006124] = 01044; code[006124] = &I06124;
  core[006125] = 07440; code[006125] = &I06125;
  core[006126] = 04354; code[006126] = &I06126;
  core[006127] = 01045; code[006127] = &I06127;
  core[006130] = 04732; code[006130] = &I06130;
  core[006131] = 05600; code[006131] = &I06131;
  core[006132] = 02442; code[006132] = &P06132;
  core[006133] = 00305; code[006133] = &D06133;
  core[006134] = 07763; code[006134] = &D06134;
  core[006135] = 00275; code[006135] = &D06135;
  core[006136] = 00255; code[006136] = &D06136;
  core[006137] = 07634; code[006137] = &D06137;
  core[006140] = 00144; code[006140] = &D06140;
  core[006141] = 07774; code[006141] = &D06141;
  core[006142] = 07766; code[006142] = &D06142;
  core[006143] = 07771; code[006143] = &D06143;
  core[006144] = 06275; code[006144] = &P06144;
  core[006145] = 05713; code[006145] = &P06145;
  core[006146] = 05712; code[006146] = &P06146;
  core[006147] = 05667; code[006147] = &P06147;
  core[006150] = 07467; code[006150] = &D06150;
  core[006151] = 05400; code[006151] = &P06151;
  core[006152] = 06271; code[006152] = &P06152;
  core[006153] = 05571; code[006153] = &P06153;
  core[006154] = 00000; code[006154] = &S06154;
  core[006155] = 01113; code[006155] = &I06155;
  core[006156] = 04551; code[006156] = &L06156;
  core[006157] = 05754; code[006157] = &I06157;
  core[006200] = 00000; code[006200] = &S06200;
  core[006201] = 07640; code[006201] = &I06201;
  core[006202] = 04706; code[006202] = &L06202;
  core[006203] = 01066; code[006203] = &I06203;
  core[006204] = 01114; code[006204] = &I06204;
  core[006205] = 07650; code[006205] = &I06205;
  core[006206] = 05202; code[006206] = &I06206;
  core[006207] = 04702; code[006207] = &I06207;
  core[006210] = 01066; code[006210] = &I06210;
  core[006211] = 01115; code[006211] = &P06211;
  core[006212] = 07640; code[006212] = &D06212;
  core[006213] = 05221; code[006213] = &I06213;
  core[006214] = 04706; code[006214] = &I06214;
  core[006215] = 03705; code[006215] = &I06215;
  core[006216] = 04703; code[006216] = &I06216;
  core[006217] = 01705; code[006217] = &I06217;
  core[006220] = 07041; code[006220] = &I06220;
  core[006221] = 03033; code[006221] = &L06221;
  core[006222] = 01310; code[006222] = &I06222;
  core[006223] = 03044; code[006223] = &I06223;
  core[006224] = 04704; code[006224] = &I06224;
  core[006225] = 04707; code[006225] = &I06225;
  core[006226] = 04407; code[006226] = &I06226;
  core[006227] = 06430; code[006227] = &P06227;
  core[006230] = 00000; code[006230] = &I06230;
  core[006231] = 01066; code[006231] = &I06231;
  core[006232] = 01301; code[006232] = &I06232;
  core[006233] = 07640; code[006233] = &I06233;
  core[006234] = 05246; code[006234] = &I06234;
  core[006235] = 04706; code[006235] = &I06235;
  core[006236] = 04702; code[006236] = &I06236;
  core[006237] = 04704; code[006237] = &I06237;
  core[006240] = 01047; code[006240] = &I06240;
  core[006241] = 01033; code[006241] = &I06241;
  core[006242] = 03033; code[006242] = &I06242;
  core[006243] = 04407; code[006243] = &I06243;
  core[006244] = 00430; code[006244] = &I06244;
  core[006245] = 00000; code[006245] = &I06245;
  core[006246] = 01033; code[006246] = &L06246;
  core[006247] = 07450; code[006247] = &I06247;
  core[006250] = 05600; code[006250] = &I06250;
  core[006251] = 07700; code[006251] = &I06251;
  core[006252] = 05261; code[006252] = &I06252;
  core[006253] = 04407; code[006253] = &I06253;
  core[006254] = 04275; code[006254] = &I06254;
  core[006255] = 06430; code[006255] = &I06255;
  core[006256] = 00000; code[006256] = &I06256;
  core[006257] = 07001; code[006257] = &I06257;
  core[006260] = 05266; code[006260] = &I06260;
  core[006261] = 04407; code[006261] = &L06261;
  core[006262] = 04271; code[006262] = &I06262;
  core[006263] = 06430; code[006263] = &I06263;
  core[006264] = 00000; code[006264] = &I06264;
  core[006265] = 07040; code[006265] = &I06265;
  core[006266] = 01033; code[006266] = &L06266;
  core[006267] = 03033; code[006267] = &I06267;
  core[006270] = 05246; code[006270] = &I06270;
  core[006271] = 00004; code[006271] = &D06271;
  core[006272] = 02400; code[006272] = &I06272;
  core[006273] = 00000; code[006273] = &I06273;
  core[006274] = 00000; code[006274] = &I06274;
  core[006275] = 07775; code[006275] = &D06275;
  core[006276] = 03146; code[006276] = &I06276;
  core[006277] = 03147; code[006277] = &I06277;
  core[006300] = 03150; code[006300] = &I06300;
  core[006301] = 07473; code[006301] = &D06301;
  core[006302] = 05600; code[006302] = &P06302;
  core[006303] = 05627; code[006303] = &P06303;
  core[006304] = 07173; code[006304] = &P06304;
  core[006305] = 05714; code[006305] = &P06305;
  core[006306] = 00756; code[006306] = &P06306;
  core[006307] = 07335; code[006307] = &P06307;
  core[006310] = 00043; code[006310] = &D06310;
  core[006321] = 00000; code[006321] = &P06321;
  core[006322] = 01105; code[006322] = &L06322;
  core[006323] = 03343; code[006323] = &I06323;
  core[006324] = 01037; code[006324] = &L06324;
  core[006325] = 07700; code[006325] = &I06325;
  core[006326] = 05364; code[006326] = &D06326;
  core[006327] = 02032; code[006327] = &I06327;
  core[006330] = 05324; code[006330] = &I06330;
  core[006331] = 02343; code[006331] = &I06331;
  core[006332] = 05324; code[006332] = &I06332;
  core[006333] = 04343; code[006333] = &I06333;
  core[006334] = 01013; code[006334] = &I06334;
  core[006335] = 01376; code[006335] = &I06335;
  core[006336] = 07620; code[006336] = &I06336;
  core[006337] = 05742; code[006337] = &I06337;
  core[006340] = 02013; code[006340] = &I06340;
  core[006341] = 05541; code[006341] = &I06341;
  core[006342] = 00212; code[006342] = &P06342;
  core[006343] = 00000; code[006343] = &S06343;
  core[006344] = 01375; code[006344] = &I06344;
  core[006345] = 07040; code[006345] = &I06345;
  core[006346] = 03375; code[006346] = &I06346;
  core[006347] = 07140; code[006347] = &I06347;
  core[006350] = 03037; code[006350] = &I06350;
  core[006351] = 01375; code[006351] = &I06351;
  core[006352] = 07440; code[006352] = &I06352;
  core[006353] = 06014; code[006353] = &I06353;
  core[006354] = 07640; code[006354] = &I06354;
  core[006355] = 01377; code[006355] = &I06355;
  core[006356] = 01126; code[006356] = &P06356;
  core[006357] = 03152; code[006357] = &I06357;
  core[006360] = 05743; code[006360] = &I06360;
  core[006361] = 04343; code[006361] = &I06361;
  core[006362] = 05763; code[006362] = &I06362;
  core[006363] = 00611; code[006363] = &P06363;
  core[006364] = 07040; code[006364] = &L06364;
  core[006365] = 03037; code[006365] = &I06365;
  core[006366] = 06016; code[006366] = &I06366;
  core[006367] = 00106; code[006367] = &I06367;
  core[006370] = 07450; code[006370] = &I06370;
  core[006371] = 05322; code[006371] = &I06371;
  core[006372] = 01123; code[006372] = &I06372;
  core[006373] = 03066; code[006373] = &I06373;
  core[006374] = 05721; code[006374] = &I06374;
  core[006375] = 00000; code[006375] = &D06375;
  core[006376] = 04557; code[006376] = &D06376;
  core[006377] = 04144; code[006377] = &D06377;
  core[006400] = 00000; code[006400] = &S06400;
  core[006401] = 07300; code[006401] = &L06401;
  core[006402] = 03047; code[006402] = &I06402;
  core[006403] = 03043; code[006403] = &I06403;
  core[006404] = 01600; code[006404] = &I06404;
  core[006405] = 07450; code[006405] = &I06405;
  core[006406] = 05600; code[006406] = &I06406;
  core[006407] = 03262; code[006407] = &I06407;
  core[006410] = 01262; code[006410] = &I06410;
  core[006411] = 00123; code[006411] = &I06411;
  core[006412] = 07650; code[006412] = &I06412;
  core[006413] = 05216; code[006413] = &I06413;
  core[006414] = 01104; code[006414] = &I06414;
  core[006415] = 00200; code[006415] = &I06415;
  core[006416] = 03040; code[006416] = &L06416;
  core[006417] = 01106; code[006417] = &I06417;
  core[006420] = 00262; code[006420] = &I06420;
  core[006421] = 01040; code[006421] = &I06421;
  core[006422] = 03040; code[006422] = &I06422;
  core[006423] = 01263; code[006423] = &I06423;
  core[006424] = 00262; code[006424] = &I06424;
  core[006425] = 07650; code[006425] = &I06425;
  core[006426] = 05231; code[006426] = &I06426;
  core[006427] = 01440; code[006427] = &I06427;
  core[006430] = 03040; code[006430] = &L06430;
  core[006431] = 02200; code[006431] = &L06431;
  core[006432] = 07040; code[006432] = &I06432;
  core[006433] = 01040; code[006433] = &I06433;
  core[006434] = 03015; code[006434] = &I06434;
  core[006435] = 01262; code[006435] = &I06435;
  core[006436] = 07106; code[006436] = &I06436;
  core[006437] = 07006; code[006437] = &I06437;
  core[006440] = 00107; code[006440] = &I06440;
  core[006441] = 07450; code[006441] = &I06441;
  core[006442] = 05267; code[006442] = &I06442;
  core[006443] = 01264; code[006443] = &I06443;
  core[006444] = 03262; code[006444] = &I06444;
  core[006445] = 01662; code[006445] = &I06445;
  core[006446] = 07450; code[006446] = &I06446;
  core[006447] = 05265; code[006447] = &I06447;
  core[006450] = 03262; code[006450] = &I06450;
  core[006451] = 01304; code[006451] = &I06451;
  core[006452] = 03014; code[006452] = &I06452;
  core[006453] = 01117; code[006453] = &I06453;
  core[006454] = 03057; code[006454] = &I06454;
  core[006455] = 01415; code[006455] = &L06455;
  core[006456] = 03414; code[006456] = &I06456;
  core[006457] = 02057; code[006457] = &I06457;
  core[006460] = 05255; code[006460] = &I06460;
  core[006461] = 05662; code[006461] = &I06461;
  core[006462] = 00000; code[006462] = &P06462;
  core[006463] = 00400; code[006463] = &D06463;
  core[006464] = 06573; code[006464] = &D06464;
  core[006465] = 01303; code[006465] = &L06465;
  core[006466] = 05273; code[006466] = &I06466;
  core[006467] = 01303; code[006467] = &L06467;
  core[006470] = 03015; code[006470] = &I06470;
  core[006471] = 07040; code[006471] = &I06471;
  core[006472] = 01040; code[006472] = &I06472;
  core[006473] = 03014; code[006473] = &L06473;
  core[006474] = 01117; code[006474] = &I06474;
  core[006475] = 03057; code[006475] = &I06475;
  core[006476] = 01414; code[006476] = &L06476;
  core[006477] = 03415; code[006477] = &I06477;
  core[006500] = 02057; code[006500] = &I06500;
  core[006501] = 05276; code[006501] = &I06501;
  core[006502] = 05201; code[006502] = &I06502;
  core[006503] = 00043; code[006503] = &D06503;
  core[006504] = 00037; code[006504] = &D06504;
  core[006505] = 04765; code[006505] = &I06505;
  core[006506] = 04770; code[006506] = &I06506;
  core[006507] = 05201; code[006507] = &I06507;
  core[006510] = 04772; code[006510] = &I06510;
  core[006511] = 04771; code[006511] = &I06511;
  core[006512] = 04773; code[006512] = &I06512;
  core[006513] = 04767; code[006513] = &I06513;
  core[006514] = 05201; code[006514] = &I06514;
  core[006515] = 01045; code[006515] = &I06515;
  core[006516] = 07640; code[006516] = &I06516;
  core[006517] = 05325; code[006517] = &I06517;
  core[006520] = 03044; code[006520] = &L06520;
  core[006521] = 03045; code[006521] = &I06521;
  core[006522] = 03046; code[006522] = &I06522;
  core[006523] = 03047; code[006523] = &I06523;
  core[006524] = 05201; code[006524] = &I06524;
  core[006525] = 04543; code[006525] = &L06525;
  core[006526] = 00044; code[006526] = &I06526;
  core[006527] = 04543; code[006527] = &I06527;
  core[006530] = 00040; code[006530] = &I06530;
  core[006531] = 04544; code[006531] = &I06531;
  core[006532] = 00044; code[006532] = &I06532;
  core[006533] = 04453; code[006533] = &P06533;
  core[006534] = 07510; code[006534] = &I06534;
  core[006535] = 05342; code[006535] = &I06535;
  core[006536] = 07040; code[006536] = &I06536;
  core[006537] = 03262; code[006537] = &I06537;
  core[006540] = 03043; code[006540] = &I06540;
  core[006541] = 01045; code[006541] = &I06541;
  core[006542] = 07640; code[006542] = &L06542;
  core[006543] = 04566; code[006543] = &I06543;
  core[006544] = 04543; code[006544] = &I06544;
  core[006545] = 02405; code[006545] = &I06545;
  core[006546] = 04544; code[006546] = &I06546;
  core[006547] = 00044; code[006547] = &I06547;
  core[006550] = 04544; code[006550] = &I06550;
  core[006551] = 07470; code[006551] = &I06551;
  core[006552] = 05360; code[006552] = &I06552;
  core[006553] = 04543; code[006553] = &L06553;
  core[006554] = 07470; code[006554] = &P06554;
  core[006555] = 04544; code[006555] = &I06555;
  core[006556] = 00040; code[006556] = &I06556;
  core[006557] = 04766; code[006557] = &I06557;
  core[006560] = 02262; code[006560] = &L06560;
  core[006561] = 05353; code[006561] = &I06561;
  core[006562] = 05201; code[006562] = &I06562;
  core[006563] = 04766; code[006563] = &I06563;
  core[006564] = 05201; code[006564] = &I06564;
  core[006565] = 07153; code[006565] = &P06565;
  core[006566] = 07004; code[006566] = &P06566;
  core[006567] = 07335; code[006567] = &P06567;
  core[006570] = 06623; code[006570] = &P06570;
  core[006571] = 05754; code[006571] = &P06571;
  core[006572] = 06757; code[006572] = &P06572;
  core[006573] = 05733; code[006573] = &P06573;
  core[006574] = 06506; code[006574] = &I06574;
  core[006575] = 06505; code[006575] = &I06575;
  core[006576] = 07107; code[006576] = &I06576;
  core[006577] = 06563; code[006577] = &I06577;
  core[006600] = 06515; code[006600] = &I06600;
  core[006601] = 00000; code[006601] = &I06601;
  core[006602] = 06513; code[006602] = &I06602;
  core[006603] = 00000; code[006603] = &S06603;
  core[006604] = 07300; code[006604] = &I06604;
  core[006605] = 01047; code[006605] = &I06605;
  core[006606] = 07041; code[006606] = &I06606;
  core[006607] = 03047; code[006607] = &I06607;
  core[006610] = 01046; code[006610] = &I06610;
  core[006611] = 07040; code[006611] = &I06611;
  core[006612] = 07430; code[006612] = &I06612;
  core[006613] = 07101; code[006613] = &I06613;
  core[006614] = 03046; code[006614] = &I06614;
  core[006615] = 01045; code[006615] = &I06615;
  core[006616] = 07040; code[006616] = &I06616;
  core[006617] = 07430; code[006617] = &I06617;
  core[006620] = 07101; code[006620] = &I06620;
  core[006621] = 03045; code[006621] = &I06621;
  core[006622] = 05603; code[006622] = &I06622;
  core[006623] = 00000; code[006623] = &S06623;
  core[006624] = 01045; code[006624] = &I06624;
  core[006625] = 07450; code[006625] = &I06625;
  core[006626] = 01046; code[006626] = &I06626;
  core[006627] = 07650; code[006627] = &I06627;
  core[006630] = 05311; code[006630] = &I06630;
  core[006631] = 01041; code[006631] = &I06631;
  core[006632] = 07450; code[006632] = &I06632;
  core[006633] = 01042; code[006633] = &I06633;
  core[006634] = 07450; code[006634] = &I06634;
  core[006635] = 01043; code[006635] = &I06635;
  core[006636] = 07650; code[006636] = &I06636;
  core[006637] = 05623; code[006637] = &I06637;
  core[006640] = 01040; code[006640] = &I06640;
  core[006641] = 07041; code[006641] = &I06641;
  core[006642] = 01044; code[006642] = &I06642;
  core[006643] = 07450; code[006643] = &I06643;
  core[006644] = 05273; code[006644] = &I06644;
  core[006645] = 03203; code[006645] = &I06645;
  core[006646] = 01203; code[006646] = &I06646;
  core[006647] = 07500; code[006647] = &I06647;
  core[006650] = 07041; code[006650] = &I06650;
  core[006651] = 03322; code[006651] = &I06651;
  core[006652] = 01322; code[006652] = &I06652;
  core[006653] = 01336; code[006653] = &I06653;
  core[006654] = 07710; code[006654] = &I06654;
  core[006655] = 05275; code[006655] = &I06655;
  core[006656] = 01203; code[006656] = &I06656;
  core[006657] = 07700; code[006657] = &I06657;
  core[006660] = 05265; code[006660] = &I06660;
  core[006661] = 04357; code[006661] = &L06661;
  core[006662] = 02322; code[006662] = &I06662;
  core[006663] = 05261; code[006663] = &I06663;
  core[006664] = 05273; code[006664] = &I06664;
  core[006665] = 07040; code[006665] = &L06665;
  core[006666] = 01040; code[006666] = &I06666;
  core[006667] = 03040; code[006667] = &I06667;
  core[006670] = 04723; code[006670] = &L06670;
  core[006671] = 02322; code[006671] = &I06671;
  core[006672] = 05270; code[006672] = &I06672;
  core[006673] = 02223; code[006673] = &L06673;
  core[006674] = 05623; code[006674] = &I06674;
  core[006675] = 01040; code[006675] = &L06675;
  core[006676] = 07700; code[006676] = &I06676;
  core[006677] = 05304; code[006677] = &I06677;
  core[006700] = 01044; code[006700] = &I06700;
  core[006701] = 07700; code[006701] = &I06701;
  core[006702] = 05623; code[006702] = &I06702;
  core[006703] = 05306; code[006703] = &I06703;
  core[006704] = 01044; code[006704] = &L06704;
  core[006705] = 07700; code[006705] = &I06705;
  core[006706] = 01203; code[006706] = &L06706;
  core[006707] = 07740; code[006707] = &I06707;
  core[006710] = 05623; code[006710] = &I06710;
  core[006711] = 01040; code[006711] = &L06711;
  core[006712] = 03044; code[006712] = &I06712;
  core[006713] = 01041; code[006713] = &I06713;
  core[006714] = 03045; code[006714] = &I06714;
  core[006715] = 01042; code[006715] = &I06715;
  core[006716] = 03046; code[006716] = &I06716;
  core[006717] = 01043; code[006717] = &I06717;
  core[006720] = 03047; code[006720] = &I06720;
  core[006721] = 05623; code[006721] = &I06721;
  core[006722] = 00000; code[006722] = &D06722;
  core[006723] = 05754; code[006723] = &P06723;
  core[006724] = 00000; code[006724] = &S06724;
  core[006725] = 04751; code[006725] = &I06725;
  core[006726] = 01044; code[006726] = &I06726;
  core[006727] = 07750; code[006727] = &I06727;
  core[006730] = 05353; code[006730] = &I06730;
  core[006731] = 07001; code[006731] = &I06731;
  core[006732] = 03043; code[006732] = &I06732;
  core[006733] = 01350; code[006733] = &I06733;
  core[006734] = 03040; code[006734] = &I06734;
  core[006735] = 04223; code[006735] = &I06735;
  core[006736] = 00027; code[006736] = &D06736;
  core[006737] = 02047; code[006737] = &D06737;
  core[006740] = 05344; code[006740] = &I06740;
  core[006741] = 02046; code[006741] = &I06741;
  core[006742] = 07410; code[006742] = &I06742;
  core[006743] = 02045; code[006743] = &I06743;
  core[006744] = 03047; code[006744] = &L06744;
  core[006745] = 04752; code[006745] = &I06745;
  core[006746] = 01046; code[006746] = &I06746;
  core[006747] = 05724; code[006747] = &I06747;
  core[006750] = 00027; code[006750] = &D06750;
  core[006751] = 05571; code[006751] = &P06751;
  core[006752] = 07173; code[006752] = &P06752;
  core[006753] = 03044; code[006753] = &L06753;
  core[006754] = 03045; code[006754] = &P06754;
  core[006755] = 03046; code[006755] = &I06755;
  core[006756] = 05344; code[006756] = &I06756;
  core[006757] = 00000; code[006757] = &S06757;
  core[006760] = 07300; code[006760] = &I06760;
  core[006761] = 01045; code[006761] = &I06761;
  core[006762] = 07510; code[006762] = &I06762;
  core[006763] = 07020; code[006763] = &I06763;
  core[006764] = 07010; code[006764] = &I06764;
  core[006765] = 03045; code[006765] = &I06765;
  core[006766] = 01046; code[006766] = &I06766;
  core[006767] = 07010; code[006767] = &I06767;
  core[006770] = 03046; code[006770] = &I06770;
  core[006771] = 01047; code[006771] = &I06771;
  core[006772] = 07010; code[006772] = &I06772;
  core[006773] = 03047; code[006773] = &I06773;
  core[006774] = 02044; code[006774] = &I06774;
  core[006775] = 05757; code[006775] = &I06775;
  core[006776] = 05757; code[006776] = &I06776;
  core[006777] = 00337; code[006777] = &I06777;
  core[007000] = 00377; code[007000] = &I07000;
  core[007001] = 00212; code[007001] = &I07001;
  core[007002] = 00375; code[007002] = &I07002;
  core[007003] = 07777; code[007003] = &I07003;
  core[007004] = 00000; code[007004] = &S07004;
  core[007005] = 07001; code[007005] = &I07005;
  core[007006] = 01040; code[007006] = &I07006;
  core[007007] = 04324; code[007007] = &I07007;
  core[007010] = 07710; code[007010] = &I07010;
  core[007011] = 04353; code[007011] = &I07011;
  core[007012] = 03301; code[007012] = &D07012;
  core[007013] = 03300; code[007013] = &I07013;
  core[007014] = 03277; code[007014] = &I07014;
  core[007015] = 03276; code[007015] = &I07015;
  core[007016] = 01045; code[007016] = &I07016;
  core[007017] = 03751; code[007017] = &I07017;
  core[007020] = 01041; code[007020] = &I07020;
  core[007021] = 04752; code[007021] = &I07021;
  core[007022] = 00002; code[007022] = &I07022;
  core[007023] = 01042; code[007023] = &I07023;
  core[007024] = 04752; code[007024] = &I07024;
  core[007025] = 00003; code[007025] = &I07025;
  core[007026] = 01046; code[007026] = &I07026;
  core[007027] = 03751; code[007027] = &I07027;
  core[007030] = 01041; code[007030] = &I07030;
  core[007031] = 04752; code[007031] = &I07031;
  core[007032] = 00003; code[007032] = &I07032;
  core[007033] = 01042; code[007033] = &I07033;
  core[007034] = 04752; code[007034] = &I07034;
  core[007035] = 00004; code[007035] = &I07035;
  core[007036] = 05263; code[007036] = &I07036;
  core[007037] = 03274; code[007037] = &I07037;
  core[007040] = 01043; code[007040] = &I07040;
  core[007041] = 03751; code[007041] = &D07041;
  core[007042] = 01045; code[007042] = &D07042;
  core[007043] = 04752; code[007043] = &I07043;
  core[007044] = 00004; code[007044] = &I07044;
  core[007045] = 01046; code[007045] = &I07045;
  core[007046] = 04752; code[007046] = &I07046;
  core[007047] = 00005; code[007047] = &I07047;
  core[007050] = 01047; code[007050] = &I07050;
  core[007051] = 03751; code[007051] = &I07051;
  core[007052] = 01041; code[007052] = &I07052;
  core[007053] = 04752; code[007053] = &I07053;
  core[007054] = 00004; code[007054] = &I07054;
  core[007055] = 01042; code[007055] = &I07055;
  core[007056] = 04752; code[007056] = &I07056;
  core[007057] = 00005; code[007057] = &D07057;
  core[007060] = 01043; code[007060] = &I07060;
  core[007061] = 04752; code[007061] = &I07061;
  core[007062] = 00006; code[007062] = &I07062;
  core[007063] = 01301; code[007063] = &L07063;
  core[007064] = 03045; code[007064] = &I07064;
  core[007065] = 01300; code[007065] = &I07065;
  core[007066] = 03046; code[007066] = &I07066;
  core[007067] = 01277; code[007067] = &I07067;
  core[007070] = 03047; code[007070] = &I07070;
  core[007071] = 04301; code[007071] = &I07071;
  core[007072] = 03047; code[007072] = &I07072;
  core[007073] = 05604; code[007073] = &I07073;
  core[007101] = 00000; code[007101] = &S07101;
  core[007102] = 02050; code[007102] = &I07102;
  core[007103] = 04451; code[007103] = &I07103;
  core[007104] = 04747; code[007104] = &I07104;
  core[007105] = 02047; code[007105] = &I07105;
  core[007106] = 05701; code[007106] = &I07106;
  core[007107] = 01041; code[007107] = &I07107;
  core[007110] = 07650; code[007110] = &I07110;
  core[007111] = 04566; code[007111] = &I07111;
  core[007112] = 01040; code[007112] = &I07112;
  core[007113] = 07041; code[007113] = &I07113;
  core[007114] = 07001; code[007114] = &I07114;
  core[007115] = 04324; code[007115] = &I07115;
  core[007116] = 07700; code[007116] = &I07116;
  core[007117] = 04353; code[007117] = &I07117;
  core[007120] = 04750; code[007120] = &I07120;
  core[007121] = 04301; code[007121] = &I07121;
  core[007122] = 05723; code[007122] = &I07122;
  core[007123] = 06401; code[007123] = &P07123;
  core[007124] = 00000; code[007124] = &S07124;
  core[007125] = 01044; code[007125] = &I07125;
  core[007126] = 03044; code[007126] = &I07126;
  core[007127] = 01124; code[007127] = &I07127;
  core[007130] = 00045; code[007130] = &I07130;
  core[007131] = 01041; code[007131] = &I07131;
  core[007132] = 07700; code[007132] = &I07132;
  core[007133] = 07040; code[007133] = &I07133;
  core[007134] = 03050; code[007134] = &I07134;
  core[007135] = 01045; code[007135] = &I07135;
  core[007136] = 07450; code[007136] = &I07136;
  core[007137] = 05746; code[007137] = &I07137;
  core[007140] = 07710; code[007140] = &I07140;
  core[007141] = 04451; code[007141] = &I07141;
  core[007142] = 01041; code[007142] = &I07142;
  core[007143] = 07450; code[007143] = &I07143;
  core[007144] = 05746; code[007144] = &I07144;
  core[007145] = 05724; code[007145] = &I07145;
  core[007146] = 06520; code[007146] = &P07146;
  core[007147] = 07335; code[007147] = &P07147;
  core[007150] = 07261; code[007150] = &P07150;
  core[007151] = 07256; code[007151] = &P07151;
  core[007152] = 07200; code[007152] = &P07152;
  core[007153] = 00000; code[007153] = &S07153;
  core[007154] = 07300; code[007154] = &I07154;
  core[007155] = 01043; code[007155] = &I07155;
  core[007156] = 07041; code[007156] = &I07156;
  core[007157] = 03043; code[007157] = &I07157;
  core[007160] = 01042; code[007160] = &I07160;
  core[007161] = 07040; code[007161] = &I07161;
  core[007162] = 07430; code[007162] = &I07162;
  core[007163] = 07101; code[007163] = &I07163;
  core[007164] = 03042; code[007164] = &I07164;
  core[007165] = 01041; code[007165] = &I07165;
  core[007166] = 07040; code[007166] = &L07166;
  core[007167] = 07430; code[007167] = &I07167;
  core[007170] = 07101; code[007170] = &I07170;
  core[007171] = 03041; code[007171] = &I07171;
  core[007172] = 05753; code[007172] = &I07172;
  core[007173] = 00000; code[007173] = &S07173;
  core[007174] = 01050; code[007174] = &I07174;
  core[007175] = 07710; code[007175] = &D07175;
  core[007176] = 04451; code[007176] = &I07176;
  core[007177] = 05773; code[007177] = &D07177;
  core[007200] = 00000; code[007200] = &S07200;
  core[007201] = 07450; code[007201] = &I07201;
  core[007202] = 05600; code[007202] = &I07202;
  core[007203] = 03254; code[007203] = &I07203;
  core[007204] = 03253; code[007204] = &I07204;
  core[007205] = 01257; code[007205] = &I07205;
  core[007206] = 03255; code[007206] = &I07206;
  core[007207] = 07100; code[007207] = &I07207;
  core[007210] = 01254; code[007210] = &L07210;
  core[007211] = 07010; code[007211] = &I07211;
  core[007212] = 03254; code[007212] = &I07212;
  core[007213] = 01253; code[007213] = &I07213;
  core[007214] = 07420; code[007214] = &I07214;
  core[007215] = 05220; code[007215] = &I07215;
  core[007216] = 07100; code[007216] = &I07216;
  core[007217] = 01256; code[007217] = &I07217;
  core[007220] = 07010; code[007220] = &L07220;
  core[007221] = 03253; code[007221] = &I07221;
  core[007222] = 02255; code[007222] = &I07222;
  core[007223] = 05210; code[007223] = &I07223;
  core[007224] = 01254; code[007224] = &I07224;
  core[007225] = 07010; code[007225] = &I07225;
  core[007226] = 03255; code[007226] = &I07226;
  core[007227] = 01600; code[007227] = &I07227;
  core[007230] = 07041; code[007230] = &I07230;
  core[007231] = 01252; code[007231] = &I07231;
  core[007232] = 03254; code[007232] = &I07232;
  core[007233] = 01255; code[007233] = &I07233;
  core[007234] = 07100; code[007234] = &I07234;
  core[007235] = 01654; code[007235] = &I07235;
  core[007236] = 03654; code[007236] = &I07236;
  core[007237] = 02254; code[007237] = &I07237;
  core[007240] = 07004; code[007240] = &I07240;
  core[007241] = 01253; code[007241] = &I07241;
  core[007242] = 01654; code[007242] = &I07242;
  core[007243] = 03654; code[007243] = &I07243;
  core[007244] = 07420; code[007244] = &I07244;
  core[007245] = 05600; code[007245] = &I07245;
  core[007246] = 02254; code[007246] = &L07246;
  core[007247] = 02654; code[007247] = &I07247;
  core[007250] = 05600; code[007250] = &I07250;
  core[007251] = 05246; code[007251] = &I07251;
  core[007252] = 07102; code[007252] = &D07252;
  core[007253] = 00000; code[007253] = &D07253;
  core[007254] = 00000; code[007254] = &P07254;
  core[007255] = 00000; code[007255] = &D07255;
  core[007256] = 00000; code[007256] = &D07256;
  core[007257] = 07764; code[007257] = &D07257;
  core[007260] = 07751; code[007260] = &D07260;
  core[007261] = 00000; code[007261] = &S07261;
  core[007262] = 03200; code[007262] = &I07262;
  core[007263] = 03254; code[007263] = &I07263;
  core[007264] = 01260; code[007264] = &I07264;
  core[007265] = 03255; code[007265] = &I07265;
  core[007266] = 07410; code[007266] = &I07266;
  core[007267] = 04527; code[007267] = &L07267;
  core[007270] = 07100; code[007270] = &I07270;
  core[007271] = 01042; code[007271] = &I07271;
  core[007272] = 01046; code[007272] = &I07272;
  core[007273] = 03256; code[007273] = &I07273;
  core[007274] = 07004; code[007274] = &I07274;
  core[007275] = 01045; code[007275] = &I07275;
  core[007276] = 01041; code[007276] = &I07276;
  core[007277] = 07420; code[007277] = &I07277;
  core[007300] = 05304; code[007300] = &I07300;
  core[007301] = 03045; code[007301] = &I07301;
  core[007302] = 01256; code[007302] = &I07302;
  core[007303] = 03046; code[007303] = &I07303;
  core[007304] = 07200; code[007304] = &L07304;
  core[007305] = 01254; code[007305] = &I07305;
  core[007306] = 07004; code[007306] = &I07306;
  core[007307] = 03254; code[007307] = &I07307;
  core[007310] = 01200; code[007310] = &I07310;
  core[007311] = 07004; code[007311] = &I07311;
  core[007312] = 03200; code[007312] = &I07312;
  core[007313] = 02255; code[007313] = &I07313;
  core[007314] = 05267; code[007314] = &I07314;
  core[007315] = 01254; code[007315] = &I07315;
  core[007316] = 03046; code[007316] = &I07316;
  core[007317] = 01200; code[007317] = &I07317;
  core[007320] = 03045; code[007320] = &I07320;
  core[007321] = 05661; code[007321] = &I07321;
  core[007322] = 07004; code[007322] = &I07322;
  core[007323] = 03335; code[007323] = &I07323;
  core[007324] = 02255; code[007324] = &I07324;
  core[007325] = 05267; code[007325] = &I07325;
  core[007326] = 01335; code[007326] = &I07326;
  core[007327] = 03045; code[007327] = &I07327;
  core[007330] = 01200; code[007330] = &I07330;
  core[007331] = 03046; code[007331] = &I07331;
  core[007332] = 01254; code[007332] = &I07332;
  core[007333] = 03047; code[007333] = &I07333;
  core[007334] = 05661; code[007334] = &I07334;
  core[007335] = 00000; code[007335] = &S07335;
  core[007336] = 04775; code[007336] = &I07336;
  core[007337] = 04366; code[007337] = &I07337;
  core[007340] = 01045; code[007340] = &I07340;
  core[007341] = 07450; code[007341] = &I07341;
  core[007342] = 01047; code[007342] = &I07342;
  core[007343] = 07450; code[007343] = &I07343;
  core[007344] = 01046; code[007344] = &I07344;
  core[007345] = 07650; code[007345] = &I07345;
  core[007346] = 05363; code[007346] = &I07346;
  core[007347] = 01045; code[007347] = &L07347;
  core[007350] = 07104; code[007350] = &I07350;
  core[007351] = 07710; code[007351] = &I07351;
  core[007352] = 05360; code[007352] = &I07352;
  core[007353] = 04527; code[007353] = &I07353;
  core[007354] = 07140; code[007354] = &I07354;
  core[007355] = 01044; code[007355] = &I07355;
  core[007356] = 03044; code[007356] = &I07356;
  core[007357] = 05347; code[007357] = &I07357;
  core[007360] = 04776; code[007360] = &L07360;
  core[007361] = 04366; code[007361] = &I07361;
  core[007362] = 05735; code[007362] = &I07362;
  core[007363] = 03044; code[007363] = &L07363;
  core[007364] = 05735; code[007364] = &I07364;
  core[007365] = 06757; code[007365] = &P07365;
  core[007366] = 00000; code[007366] = &S07366;
  core[007367] = 01045; code[007367] = &I07367;
  core[007370] = 07510; code[007370] = &I07370;
  core[007371] = 07041; code[007371] = &I07371;
  core[007372] = 07710; code[007372] = &I07372;
  core[007373] = 04765; code[007373] = &I07373;
  core[007374] = 05766; code[007374] = &I07374;
  core[007375] = 05571; code[007375] = &P07375;
  core[007376] = 07173; code[007376] = &P07376;
  core[007400] = 04407; code[007400] = &I07400;
  core[007401] = 06274; code[007401] = &I07401;
  core[007402] = 00000; code[007402] = &D07402;
  core[007403] = 01045; code[007403] = &I07403;
  core[007404] = 07710; code[007404] = &I07404;
  core[007405] = 04566; code[007405] = &I07405;
  core[007406] = 01044; code[007406] = &I07406;
  core[007407] = 07510; code[007407] = &I07407;
  core[007410] = 07020; code[007410] = &L07410;
  core[007411] = 07010; code[007411] = &I07411;
  core[007412] = 03270; code[007412] = &I07412;
  core[007413] = 07430; code[007413] = &I07413;
  core[007414] = 02270; code[007414] = &I07414;
  core[007415] = 07000; code[007415] = &I07415;
  core[007416] = 01267; code[007416] = &I07416;
  core[007417] = 03271; code[007417] = &I07417;
  core[007420] = 03272; code[007420] = &I07420;
  core[007421] = 03273; code[007421] = &I07421;
  core[007422] = 01275; code[007422] = &I07422;
  core[007423] = 07450; code[007423] = &I07423;
  core[007424] = 01276; code[007424] = &I07424;
  core[007425] = 07650; code[007425] = &I07425;
  core[007426] = 05265; code[007426] = &I07426;
  core[007427] = 04407; code[007427] = &L07427;
  core[007430] = 00274; code[007430] = &I07430;
  core[007431] = 03270; code[007431] = &I07431;
  core[007432] = 01270; code[007432] = &I07432;
  core[007433] = 00000; code[007433] = &I07433;
  core[007434] = 07240; code[007434] = &I07434;
  core[007435] = 01044; code[007435] = &I07435;
  core[007436] = 03044; code[007436] = &I07436;
  core[007437] = 01044; code[007437] = &I07437;
  core[007440] = 07041; code[007440] = &I07440;
  core[007441] = 01270; code[007441] = &I07441;
  core[007442] = 07640; code[007442] = &I07442;
  core[007443] = 05261; code[007443] = &I07443;
  core[007444] = 01045; code[007444] = &I07444;
  core[007445] = 07041; code[007445] = &I07445;
  core[007446] = 01271; code[007446] = &I07446;
  core[007447] = 07640; code[007447] = &I07447;
  core[007450] = 05261; code[007450] = &D07450;
  core[007451] = 01046; code[007451] = &I07451;
  core[007452] = 07041; code[007452] = &I07452;
  core[007453] = 01272; code[007453] = &I07453;
  core[007454] = 07500; code[007454] = &I07454;
  core[007455] = 07041; code[007455] = &I07455;
  core[007456] = 07001; code[007456] = &I07456;
  core[007457] = 07700; code[007457] = &I07457;
  core[007460] = 05536; code[007460] = &I07460;
  core[007461] = 04407; code[007461] = &L07461;
  core[007462] = 06270; code[007462] = &I07462;
  core[007463] = 00000; code[007463] = &I07463;
  core[007464] = 05227; code[007464] = &I07464;
  core[007465] = 03044; code[007465] = &L07465;
  core[007466] = 05536; code[007466] = &I07466;
  core[007467] = 03015; code[007467] = &D07467;
  core[007470] = 00000; code[007470] = &L07470;
  core[007471] = 00000; code[007471] = &D07471;
  core[007472] = 00000; code[007472] = &D07472;
  core[007473] = 00000; code[007473] = &D07473;
  core[007474] = 00000; code[007474] = &D07474;
  core[007475] = 00000; code[007475] = &D07475;
  core[007476] = 00000; code[007476] = &D07476;
  core[007477] = 07503; code[007477] = &I07477;
  core[007503] = 01133; code[007503] = &I07503;
  core[007504] = 04327; code[007504] = &I07504;
  core[007505] = 01060; code[007505] = &I07505;
  core[007506] = 04327; code[007506] = &I07506;
  core[007507] = 01031; code[007507] = &I07507;
  core[007510] = 04327; code[007510] = &I07510;
  core[007511] = 01035; code[007511] = &I07511;
  core[007512] = 04327; code[007512] = &I07512;
  core[007513] = 05316; code[007513] = &I07513;
  core[007514] = 04545; code[007514] = &L07514;
  core[007515] = 04551; code[007515] = &I07515;
  core[007516] = 01066; code[007516] = &L07516;
  core[007517] = 01116; code[007517] = &I07517;
  core[007520] = 07640; code[007520] = &I07520;
  core[007521] = 05314; code[007521] = &I07521;
  core[007522] = 01016; code[007522] = &L07522;
  core[007523] = 07640; code[007523] = &I07523;
  core[007524] = 05322; code[007524] = &I07524;
  core[007525] = 06002; code[007525] = &I07525;
  core[007526] = 05504; code[007526] = &I07526;
  core[007527] = 00000; code[007527] = &S07527;
  core[007530] = 03032; code[007530] = &I07530;
  core[007531] = 01032; code[007531] = &I07531;
  core[007532] = 07006; code[007532] = &I07532;
  core[007533] = 07006; code[007533] = &I07533;
  core[007534] = 04350; code[007534] = &I07534;
  core[007535] = 04557; code[007535] = &I07535;
  core[007536] = 07004; code[007536] = &I07536;
  core[007537] = 04350; code[007537] = &I07537;
  core[007540] = 07012; code[007540] = &L07540;
  core[007541] = 07010; code[007541] = &I07541;
  core[007542] = 04350; code[007542] = &I07542;
  core[007543] = 04350; code[007543] = &I07543;
  core[007544] = 07200; code[007544] = &I07544;
  core[007545] = 01077; code[007545] = &I07545;
  core[007546] = 04551; code[007546] = &I07546;
  core[007547] = 05727; code[007547] = &I07547;
  core[007550] = 00000; code[007550] = &S07550;
  core[007551] = 00356; code[007551] = &I07551;
  core[007552] = 01113; code[007552] = &I07552;
  core[007553] = 04551; code[007553] = &I07553;
  core[007554] = 01032; code[007554] = &I07554;
  core[007555] = 05750; code[007555] = &I07555;
  core[007556] = 00007; code[007556] = &D07556;
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

