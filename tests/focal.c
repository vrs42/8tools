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
void D00001() { npc = (ib<<12)+core[2]; inh = 0;  }
void P00002() { if (++core[(df<<12)+core[3]] == 010000) { core[(df<<12)+core[3]] = 0; npc++; }; code[(df<<12)+core[3]] = &emul8;  }
void P00003() { emul8();  }
void P00004() { lac &= (010000|core[000000]);  }
void D00005() { lac &= (010000|core[000013]);  }
void D00006() { lac &= (010000|core[000100]);  }
void P00007() { emul8();  }
void P00010() { lac &= (010000|core[000000]);  }
void P00011() { lac &= (010000|core[000000]);  }
void P00012() { lac &= (010000|core[000000]);  }
void P00013() { lac &= (010000|core[000000]);  }
void P00014() { core[000177] = lac & 07777; lac &= 010000; code[000177] = &emul8;  }
void D00015() { lac &= (010000|core[000000]);  }
void P00016() { lac &= (010000|core[000000]);  }
void P00017() { core[(df<<12)+core[24]] = lac & 07777; lac &= 010000; code[(df<<12)+core[24]] = &emul8;  }
void P00020() { lac &= (010000|core[000000]);  }
void P00021() { lac &= (010000|core[000000]);  }
void D00022() { lac &= (010000|core[000056]);  }
void D00023() { emul8();  }
void P00024() { lac &= 010000;  }
void D00025() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void P00026() { lac &= (010000|core[000177]);  }
void D00027() { npc = (ib<<12)+core[127]; inh = 0;  }
void P00030() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D00031() { lac &= (010000|core[000017]);  }
void P00032() { lac &= (010000|core[000077]);  }
void D00033() { lac &= (010000|core[000040]);  }
void D00034() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P00035() { lac &= (010000|core[000002]);  }
void D00036() { lac &= (010000|core[000060]);  }
void D00037() { lac &= (010000|core[000000]);  }
void P00040() { lac &= (010000|core[000000]);  }
void D00041() { lac &= (010000|core[000000]);  }
void D00042() { lac &= (010000|core[000000]);  }
void P00043() { lac &= (010000|core[000000]);  }
void D00044() { lac &= (010000|core[000000]);  }
void D00045() { lac &= (010000|core[000000]);  }
void D00046() { lac &= (010000|core[000000]);  }
void D00047() { lac &= (010000|core[000000]);  }
void P00050() { emul8();  }
void P00051() { lac &= (010000|core[000010]);  }
void P00052() { lac &= 010000; lac &= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void D00053() { lac &= (010000|core[000000]);  }
void P00054() { lac &= (010000|core[000137]);  }
void D00055() { lac &= (010000|core[000014]);  }
void D00056() { lac &= (010000|core[000007]);  }
void D00057() { lac &= (010000|core[000012]);  }
void D00060() { lac &= (010000|core[000015]);  }
void D00061() { lac &= (010000|core[000000]);  }
void D00062() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void P00063() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp;  }
void D00064() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; hlt = 1;  }
void P00065() { emul8();  }
void P00066() { emul8();  }
void D00067() { emul8();  }
void D00070() { emul8();  }
void P00071() { lac &= (010000|core[000077]);  }
void P00072() { emul8();  }
void P00073() { npc = (ib<<12)+core[0]; inh = 0;  }
void D00074() { if (++core[(df<<12)+core[87]] == 010000) { core[(df<<12)+core[87]] = 0; npc++; }; code[(df<<12)+core[87]] = &emul8;  }
void P00075() { core[(df<<12)+core[16]] = lac & 07777; lac &= 010000; code[(df<<12)+core[16]] = &emul8;  }
void I00076() { core[(df<<12)+core[26]] = lac & 07777; lac &= 010000; code[(df<<12)+core[26]] = &emul8;  }
void P00077() { core[(df<<12)+core[26]] = lac & 07777; lac &= 010000; code[(df<<12)+core[26]] = &emul8;  }
void P00100() { if (++core[000056] == 010000) { core[000056] = 0; npc++; }; code[000056] = &emul8;  }
void P00101() { lac &= (010000|core[(df<<12)+core[83]]);  }
void P00102() { lac += core[(df<<12)+core[110]];  }
void P00103() { lac &= (010000|core[(df<<12)+core[65]]);  }
void P00104() { lac &= (010000|core[(df<<12)+core[90]]);  }
void P00105() { lac &= (010000|core[(df<<12)+core[104]]);  }
void P00106() { if (++core[000115] == 010000) { core[000115] = 0; npc++; }; code[000115] = &emul8;  }
void P00107() { core[000023] = lac & 07777; lac &= 010000; code[000023] = &emul8;  }
void P00110() { lac += core[000133];  }
void P00111() { lac &= (010000|core[(df<<12)+core[91]]);  }
void P00112() { if (++core[(df<<12)+core[63]] == 010000) { core[(df<<12)+core[63]] = 0; npc++; }; code[(df<<12)+core[63]] = &emul8;  }
void P00113() { if (++core[(df<<12)+core[51]] == 010000) { core[(df<<12)+core[51]] = 0; npc++; }; code[(df<<12)+core[51]] = &emul8;  }
void P00114() { emul8();  }
void P00115() { lac &= (010000|core[000112]);  }
void P00116() { if (++core[000065] == 010000) { core[000065] = 0; npc++; }; code[000065] = &emul8;  }
void P00117() { if (++core[000017] == 010000) core[000017] = 0000;if (++core[(df<<12)+core[000017]] == 010000) { core[(df<<12)+core[000017]] = 0; npc++; }; code[(df<<12)+core[000017]] = &emul8;  }
void P00120() { lac &= (010000|core[000105]);  }
void P00121() { lac += core[(df<<12)+core[84]];  }
void P00122() { lac += core[(df<<12)+core[91]];  }
void P00123() { if (++core[000077] == 010000) { core[000077] = 0; npc++; }; code[000077] = &emul8;  }
void P00124() { if (++core[(df<<12)+core[41]] == 010000) { core[(df<<12)+core[41]] = 0; npc++; }; code[(df<<12)+core[41]] = &emul8;  }
void P00125() { lac &= (010000|core[(df<<12)+core[75]]);  }
void P00126() { if (++core[(df<<12)+core[94]] == 010000) { core[(df<<12)+core[94]] = 0; npc++; }; code[(df<<12)+core[94]] = &emul8;  }
void P00127() { lac &= (010000|core[000000]);  }
void D00130() { lac &= (010000|core[000000]);  }
void D00131() { lac &= (010000|core[000000]);  }
void P00132() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void P00133() { lac &= (010000|core[000004]);  }
void P00134() { core[(df<<12)+core[26]] = lac & 07777; lac &= 010000; code[(df<<12)+core[26]] = &emul8;  }
void D00135() { lac &= (010000|core[000000]);  }
void P00136() { lac &= (010000|core[000000]);  }
void P00137() { if (++core[(df<<12)+core[61]] == 010000) { core[(df<<12)+core[61]] = 0; npc++; }; code[(df<<12)+core[61]] = &emul8;  }
void P00140() { if (++core[(df<<12)+core[53]] == 010000) { core[(df<<12)+core[53]] = 0; npc++; }; code[(df<<12)+core[53]] = &emul8;  }
void D00141() { lac &= (010000|core[000001]);  }
void D00142() { lac &= (010000|core[000015]);  }
void D00143() { lac &= (010000|core[000000]);  }
void D00144() { lac &= (010000|core[000005]);  }
void P00145() { lac += core[(df<<12)+core[125]];  }
void P00146() { lac &= (010000|core[000000]);  }
void D00147() { lac &= (010000|core[000000]);  }
void P00150() { lac &= (010000|core[000000]);  }
void P00151() { lac &= (010000|core[000001]);  }
void D00152() { lac &= (010000|core[000001]);  }
void D00153() { lac &= (010000|core[000000]);  }
void P00154() { lac &= (010000|core[000000]);  }
void D00155() { core[(df<<12)+core[26]] = lac & 07777; lac &= 010000; code[(df<<12)+core[26]] = &emul8;  }
void P00156() { lac &= (010000|core[000000]);  }
void P00157() { lac &= (010000|core[000000]);  }
void P00160() { if (++core[000034] == 010000) { core[000034] = 0; npc++; }; code[000034] = &emul8;  }
void D00161() { if (++core[(df<<12)+core[51]] == 010000) { core[(df<<12)+core[51]] = 0; npc++; }; code[(df<<12)+core[51]] = &emul8;  }
void D00162() { lac &= (010000|core[000000]);  }
void D00163() { lac &= (010000|core[000000]);  }
void D00164() { lac &= (010000|core[000000]);  }
void P00165() { if (++core[(df<<12)+core[76]] == 010000) { core[(df<<12)+core[76]] = 0; npc++; }; code[(df<<12)+core[76]] = &emul8;  }
void P00176() { core[(df<<12)+core[26]] = lac & 07777; lac &= 010000; code[(df<<12)+core[26]] = &emul8;  }
void P00177() { skp = 0; skp = !skp; npc += skp; lac &= 010000;  }
void I00200() { npc = (ib<<12)+core[126]; inh = 0;  }
void P00201() { lac += core[000227];  }
void I00202() { core[000145] = lac & 07777; lac &= 010000; code[000145] = &emul8;  }
void I00203() { core[000151] = lac & 07777; lac &= 010000; code[000151] = &emul8;  }
void I00204() { lac += core[000226];  }
void I00205() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I00206() { if (++core[000152] == 010000) { core[000152] = 0; npc++; }; code[000152] = &emul8;  }
void I00207() { core[000061] = lac & 07777; lac &= 010000; code[000061] = &emul8;  }
void I00210() { lac += core[000054];  }
void I00211() { core[(ib<<12)+core[74]] = 00212; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void P00212() { lac += core[000074];  }
void I00213() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I00214() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I00215() { lac += core[000074];  }
void P00216() { core[000153] = lac & 07777; lac &= 010000; code[000153] = &emul8;  }
void L00217() { core[(ib<<12)+core[75]] = 00220; npc = (ib<<12)+core[75]+1; code[(ib<<12)+core[75]] = &emul8; inh = 0;  }
void I00220() { core[(ib<<12)+core[72]] = 00221; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I00221() { lac &= (010000|core[000053]);  }
void I00222() { lac &= (010000|core[(df<<12)+core[72]]);  }
void I00223() { core[(ib<<12)+core[71]] = 00224; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I00224() { npc = 000217; inh = 0;  }
void D00225() { core[000000] = 00226; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void D00226() { if (++core[(df<<12)+core[138]] == 010000) { core[(df<<12)+core[138]] = 0; npc++; }; code[(df<<12)+core[138]] = &emul8;  }
void D00227() { lac += core[(df<<12)+core[125]];  }
void L00230() { core[(ib<<12)+core[71]] = 00231; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I00231() { core[(ib<<12)+core[71]] = 00232; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I00232() { lac += core[000074];  }
void L00233() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I00234() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I00235() { core[(ib<<12)+core[70]] = 00236; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I00236() { lac += core[000027];  }
void I00237() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I00240() { core[(ib<<12)+core[81]] = 00241; npc = (ib<<12)+core[81]+1; code[(ib<<12)+core[81]] = &emul8; inh = 0;  }
void I00241() { core[(ib<<12)+core[82]] = 00242; npc = (ib<<12)+core[82]+1; code[(ib<<12)+core[82]] = &emul8; inh = 0;  }
void D00242() { core[(ib<<12)+core[86]] = 00243; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00243() { npc = 000274; inh = 0;  }
void I00244() { emul8();  }
void I00245() { if (++core[000151] == 010000) { core[000151] = 0; npc++; }; code[000151] = &emul8;  }
void I00246() { core[(ib<<12)+core[77]] = 00247; npc = (ib<<12)+core[77]+1; code[(ib<<12)+core[77]] = &emul8; inh = 0;  }
void I00247() { lac += core[000141];  }
void I00250() { lac += core[000225];  }
void I00251() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00252() { core[(ib<<12)+core[86]] = 00253; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00253() { lac += core[000134];  }
void I00254() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void D00255() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I00256() { lac += core[000143];  }
void I00257() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00260() { core[(ib<<12)+core[81]] = 00261; npc = (ib<<12)+core[81]+1; code[(ib<<12)+core[81]] = &emul8; inh = 0;  }
void I00261() { skp = 0; skp = !skp; npc += skp;  }
void L00262() { core[(ib<<12)+core[70]] = 00263; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I00263() { core[(ib<<12)+core[71]] = 00264; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I00264() { lac += core[000142];  }
void I00265() { lac += core[000065];  }
void I00266() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00267() { npc = 000262; inh = 0;  }
void I00270() { core[(ib<<12)+core[65]] = 00271; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I00271() { if (++core[000111] == 010000) { core[000111] = 0; npc++; }; code[000111] = &emul8;  }
void I00272() { core[(ib<<12)+core[79]] = 00273; npc = (ib<<12)+core[79]+1; code[(ib<<12)+core[79]] = &emul8; inh = 0;  }
void I00273() { npc = 000177; inh = 0;  }
void L00274() { core[(ib<<12)+core[65]] = 00275; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I00275() { lac &= (010000|core[(df<<12)+core[142]]);  }
void I00276() { lac += core[(df<<12)+core[101]];  }
void D00277() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00300() { npc = 000177; inh = 0;  }
void I00301() { core[000145] = lac & 07777; lac &= 010000; code[000145] = &emul8;  }
void I00302() { lac += core[000145];  }
void I00303() { lac++;  }
void I00304() { npc = 000233; inh = 0;  }
void S00305() { lac &= (010000|core[000000]);  }
void I00306() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00307() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00310() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00311() { npc = (ib<<12)+core[197]; inh = 0;  }
void S00312() { lac &= (010000|core[000000]);  }
void I00313() { core[(ib<<12)+core[81]] = 00314; npc = (ib<<12)+core[81]+1; code[(ib<<12)+core[81]] = &emul8; inh = 0;  }
void I00314() { lac += core[000225];  }
void I00315() { core[000141] = lac & 07777; lac &= 010000; code[000141] = &emul8;  }
void D00316() { core[(ib<<12)+core[73]] = 00317; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I00317() { emul8();  }
void I00320() { npc = 000370; inh = 0;  }
void I00321() { core[(ib<<12)+core[246]] = 00322; npc = (ib<<12)+core[246]+1; code[(ib<<12)+core[246]] = &emul8; inh = 0;  }
void I00322() { core[(ib<<12)+core[82]] = 00323; npc = (ib<<12)+core[82]+1; code[(ib<<12)+core[82]] = &emul8; inh = 0;  }
void I00323() { core[(ib<<12)+core[70]] = 00324; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I00324() { core[000356] = 00325; npc = 000356+1; code[000356] = &emul8; inh = 0;  }
void I00325() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00326() { lac += core[000127];  }
void I00327() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00330() { core[000356] = 00331; npc = 000356+1; code[000356] = &emul8; inh = 0;  }
void L00331() { lac += core[000143];  }
void L00332() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00333() { core[000141] = lac & 07777; lac &= 010000; code[000141] = &emul8;  }
void I00334() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void I00335() { lac += core[000164];  }
void I00336() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void D00337() { npc = 000347; inh = 0;  }
void I00340() { core[(ib<<12)+core[80]] = 00341; npc = (ib<<12)+core[80]+1; code[(ib<<12)+core[80]] = &emul8; inh = 0;  }
void I00341() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00342() { lac += core[000143];  }
void I00343() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void I00344() { lac += core[000164];  }
void I00345() { lac &= (010000|core[000367]);  }
void I00346() { npc = 000351; inh = 0;  }
void L00347() { if (++core[000141] == 010000) { core[000141] = 0; npc++; }; code[000141] = &emul8;  }
void I00350() { lac += core[000143];  }
void L00351() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00352() { core[(ib<<12)+core[82]] = 00353; npc = (ib<<12)+core[82]+1; code[(ib<<12)+core[82]] = &emul8; inh = 0;  }
void I00353() { npc = 000361; inh = 0;  }
void I00354() { npc = (ib<<12)+core[202]; inh = 0;  }
void I00355() { npc = 000361; inh = 0;  }
void S00356() { lac &= (010000|core[000000]);  }
void I00357() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void I00360() { core[(ib<<12)+core[82]] = 00361; npc = (ib<<12)+core[82]+1; code[(ib<<12)+core[82]] = &emul8; inh = 0;  }
void L00361() { core[(ib<<12)+core[86]] = 00362; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00362() { npc = 000331; inh = 0;  }
void I00363() { core[(ib<<12)+core[70]] = 00364; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I00364() { lac += core[000127];  }
void I00365() { npc = (ib<<12)+core[238]; inh = 0;  }
void P00366() { emul8();  }
void D00367() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void L00370() { core[(ib<<12)+core[65]] = 00371; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I00371() { lac += core[(df<<12)+core[129]];  }
void I00372() { core[(ib<<12)+core[42]] = 00373; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I00373() { core[(ib<<12)+core[67]] = 00374; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I00374() { lac += core[000045];  }
void I00375() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00376() { npc = 000361; inh = 0;  }
void I00377() { core[(ib<<12)+core[7]] = 00400; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I00400() { &emul8;  }
void I00401() { &emul8;  }
void I00402() { &emul8;  }
void I00403() { &emul8;  }
void I00404() { &emul8;  }
void I00405() { &emul8;  }
void I00406() { core[(ib<<12)+core[40]] = 00407; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I00407() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I00410() { core[000164] = lac & 07777; lac &= 010000; code[000164] = &emul8;  }
void I00411() { core[(ib<<12)+core[42]] = 00412; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void D00412() { npc = (ib<<12)+core[267]; inh = 0;  }
void P00413() { lac &= (010000|core[000532]);  }
void P00414() { npc = (ib<<12)+core[376]; inh = 0;  }
void P00415() { npc = (ib<<12)+core[379]; inh = 0;  }
void P00416() { core[(ib<<12)+core[77]] = 00417; npc = (ib<<12)+core[77]+1; code[(ib<<12)+core[77]] = &emul8; inh = 0;  }
void D00417() { lac += core[000145];  }
void I00420() { core[(ib<<12)+core[67]] = 00421; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I00421() { core[(ib<<12)+core[68]] = 00422; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I00422() { lac &= (010000|core[000017]);  }
void L00423() { core[(ib<<12)+core[68]] = 00424; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I00424() { lac &= (010000|core[000141]);  }
void I00425() { lac += core[000141];  }
void I00426() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00427() { npc = 000454; inh = 0;  }
void D00430() { core[(ib<<12)+core[78]] = 00431; npc = (ib<<12)+core[78]+1; code[(ib<<12)+core[78]] = &emul8; inh = 0;  }
void I00431() { npc = 000473; inh = 0;  }
void L00432() { core[(ib<<12)+core[65]] = 00433; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I00433() { lac &= (010000|core[(df<<12)+core[267]]);  }
void I00434() { core[(ib<<12)+core[69]] = 00435; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I00435() { lac &= (010000|core[000141]);  }
void I00436() { lac += core[(df<<12)+core[101]];  }
void I00437() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00440() { npc = 000462; inh = 0;  }
void I00441() { lac++;  }
void I00442() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I00443() { lac += core[000141];  }
void I00444() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00445() { npc = 000451; inh = 0;  }
void I00446() { lac += core[(df<<12)+core[108]];  }
void I00447() { core[(ib<<12)+core[84]] = 00450; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I00450() { npc = 000462; inh = 0;  }
void L00451() { lac += core[(df<<12)+core[108]];  }
void I00452() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void I00453() { npc = 000423; inh = 0;  }
void L00454() { core[(ib<<12)+core[78]] = 00455; npc = (ib<<12)+core[78]+1; code[(ib<<12)+core[78]] = &emul8; inh = 0;  }
void I00455() { core[(ib<<12)+core[86]] = 00456; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00456() { core[(ib<<12)+core[65]] = 00457; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I00457() { lac &= (010000|core[(df<<12)+core[269]]);  }
void I00460() { core[(ib<<12)+core[69]] = 00461; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I00461() { lac &= (010000|core[000141]);  }
void L00462() { core[(ib<<12)+core[69]] = 00463; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I00463() { lac &= (010000|core[000017]);  }
void I00464() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I00465() { core[000145] = lac & 07777; lac &= 010000; code[000145] = &emul8;  }
void L00466() { core[(ib<<12)+core[117]] = 00467; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void I00467() { npc = 000466; inh = 0;  }
void I00470() { npc = (ib<<12)+core[314]; inh = 0;  }
void I00471() { npc = 000416; inh = 0;  }
void P00472() { lac &= (010000|core[(df<<12)+core[270]]);  }
void L00473() { lac += core[000146];  }
void I00474() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00475() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I00476() { core[(ib<<12)+core[84]] = 00477; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I00477() { core[(ib<<12)+core[86]] = 00500; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00500() { npc = 000432; inh = 0;  }
void S00501() { lac &= (010000|core[000000]);  }
void I00502() { core[000532] = lac & 07777; lac &= 010000; code[000532] = &emul8;  }
void I00503() { lac ^= 07777;  }
void I00504() { core[000510] = 00505; npc = 000510+1; code[000510] = &emul8; inh = 0;  }
void I00505() { lac += core[000532];  }
void I00506() { if (++core[000016] == 010000) core[000016] = 0000;core[(df<<12)+core[000016]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000016]] = &emul8;  }
void I00507() { npc = (ib<<12)+core[321]; inh = 0;  }
void S00510() { lac &= (010000|core[000000]);  }
void I00511() { lac += core[000013];  }
void I00512() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I00513() { lac += core[000013];  }
void I00514() { core[000016] = lac & 07777; lac &= 010000; code[000016] = &emul8;  }
void I00515() { lac += core[000013];  }
void I00516() { lac &= 07777; lac ^= 07777; lac++;  }
void I00517() { lac += core[000155];  }
void I00520() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00521() { core[(ib<<12)+core[86]] = 00522; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00522() { npc = (ib<<12)+core[328]; inh = 0;  }
void S00523() { lac &= (010000|core[000000]);  }
void I00524() { lac &= 010000; lac++;  }
void I00525() { lac += core[000523];  }
void I00526() { core[000501] = 00527; npc = 000501+1; code[000501] = &emul8; inh = 0;  }
void I00527() { lac += core[(df<<12)+core[339]];  }
void I00530() { core[000523] = lac & 07777; lac &= 010000; code[000523] = &emul8;  }
void I00531() { npc = (ib<<12)+core[339]; inh = 0;  }
void S00532() { lac &= (010000|core[000000]);  }
void I00533() { lac &= 010000; lac ^= 07777;  }
void I00534() { lac += core[(df<<12)+core[346]];  }
void I00535() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00536() { if (++core[000532] == 010000) { core[000532] = 0; npc++; }; code[000532] = &emul8;  }
void I00537() { lac += core[000066];  }
void I00540() { core[000510] = 00541; npc = 000510+1; code[000510] = &emul8; inh = 0;  }
void I00541() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I00542() { if (++core[000016] == 010000) core[000016] = 0000;core[(df<<12)+core[000016]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000016]] = &emul8;  }
void I00543() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I00544() { if (++core[000016] == 010000) core[000016] = 0000;core[(df<<12)+core[000016]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000016]] = &emul8;  }
void I00545() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I00546() { if (++core[000016] == 010000) core[000016] = 0000;core[(df<<12)+core[000016]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000016]] = &emul8;  }
void I00547() { npc = (ib<<12)+core[346]; inh = 0;  }
void S00550() { lac &= (010000|core[000000]);  }
void I00551() { lac &= 010000; lac ^= 07777;  }
void I00552() { lac += core[(df<<12)+core[360]];  }
void I00553() { if (++core[000550] == 010000) { core[000550] = 0; npc++; }; code[000550] = &emul8;  }
void I00554() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I00555() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I00556() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I00557() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I00560() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I00561() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I00562() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I00563() { npc = (ib<<12)+core[360]; inh = 0;  }
void I00564() { lac &= (010000|core[000412]);  }
void I00565() { lac &= (010000|core[000423]);  }
void I00566() { lac &= (010000|core[000423]);  }
void I00567() { lac &= (010000|core[000417]);  }
void P00570() { lac &= (010000|core[000430]);  }
void I00571() { if (++core[000053] == 010000) { core[000053] = 0; npc++; }; code[000053] = &emul8;  }
void I00572() { emul8();  }
void P00573() { lac += core[000156];  }
void I00574() { lac += core[000145];  }
void I00575() { lac &= 010000; lac &= 07777; lac ^= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00576() { lac += core[000153];  }
void I00577() { if (++core[000014] == 010000) core[000014] = 0000;if (++core[(df<<12)+core[000014]] == 010000) { core[(df<<12)+core[000014]] = 0; npc++; }; code[(df<<12)+core[000014]] = &emul8;  }
void I00600() { if (++core[(df<<12)+core[477]] == 010000) { core[(df<<12)+core[477]] = 0; npc++; }; code[(df<<12)+core[477]] = &emul8;  }
void I00601() { if (++core[(df<<12)+core[477]] == 010000) { core[(df<<12)+core[477]] = 0; npc++; }; code[(df<<12)+core[477]] = &emul8;  }
void I00602() { if (++core[(df<<12)+core[477]] == 010000) { core[(df<<12)+core[477]] = 0; npc++; }; code[(df<<12)+core[477]] = &emul8;  }
void I00603() { if (++core[(df<<12)+core[477]] == 010000) { core[(df<<12)+core[477]] = 0; npc++; }; code[(df<<12)+core[477]] = &emul8;  }
void I00604() { if (++core[(df<<12)+core[477]] == 010000) { core[(df<<12)+core[477]] = 0; npc++; }; code[(df<<12)+core[477]] = &emul8;  }
void I00605() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; hlt = 1;  }
void D00606() { if (++core[(df<<12)+core[477]] == 010000) { core[(df<<12)+core[477]] = 0; npc++; }; code[(df<<12)+core[477]] = &emul8;  }
void D00607() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; hlt = 1;  }
void L00610() { core[(ib<<12)+core[77]] = 00611; npc = (ib<<12)+core[77]+1; code[(ib<<12)+core[77]] = &emul8; inh = 0;  }
void I00611() { core[(ib<<12)+core[78]] = 00612; npc = (ib<<12)+core[78]+1; code[(ib<<12)+core[78]] = &emul8; inh = 0;  }
void I00612() { core[(ib<<12)+core[86]] = 00613; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I00613() { lac += core[000146];  }
void I00614() { core[000145] = lac & 07777; lac &= 010000; code[000145] = &emul8;  }
void L00615() { core[(ib<<12)+core[70]] = 00616; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void L00616() { core[(ib<<12)+core[73]] = 00617; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I00617() { lac &= (010000|core[000057]);  }
void I00620() { npc = (ib<<12)+core[66]; inh = 0;  }
void I00621() { core[(ib<<12)+core[73]] = 00622; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I00622() { lac += core[000140];  }
void I00623() { npc = 000615; inh = 0;  }
void I00624() { lac += core[000142];  }
void I00625() { core[(ib<<12)+core[67]] = 00626; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void L00626() { core[(ib<<12)+core[70]] = 00627; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I00627() { core[(ib<<12)+core[73]] = 00630; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I00630() { if (++core[000002] == 010000) { core[000002] = 0; npc++; }; code[000002] = &emul8;  }
void I00631() { skp = 0; skp = !skp; npc += skp;  }
void I00632() { npc = 000626; inh = 0;  }
void I00633() { core[(ib<<12)+core[81]] = 00634; npc = (ib<<12)+core[81]+1; code[(ib<<12)+core[81]] = &emul8; inh = 0;  }
void I00634() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I00635() { core[(ib<<12)+core[72]] = 00636; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I00636() { lac &= (010000|core[(df<<12)+core[493]]);  }
void I00637() { lac &= (010000|core[000606]);  }
void I00640() { core[(ib<<12)+core[86]] = 00641; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void L00641() { core[(ib<<12)+core[457]] = 00642; npc = (ib<<12)+core[457]+1; code[(ib<<12)+core[457]] = &emul8; inh = 0;  }
void I00642() { core[(ib<<12)+core[77]] = 00643; npc = (ib<<12)+core[77]+1; code[(ib<<12)+core[77]] = &emul8; inh = 0;  }
void I00643() { if (++core[000151] == 010000) { core[000151] = 0; npc++; }; code[000151] = &emul8;  }
void L00644() { core[(ib<<12)+core[78]] = 00645; npc = (ib<<12)+core[78]+1; code[(ib<<12)+core[78]] = &emul8; inh = 0;  }
void I00645() { npc = 000674; inh = 0;  }
void I00646() { lac += core[000143];  }
void I00647() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00650() { core[(ib<<12)+core[76]] = 00651; npc = (ib<<12)+core[76]+1; code[(ib<<12)+core[76]] = &emul8; inh = 0;  }
void L00651() { core[(ib<<12)+core[70]] = 00652; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I00652() { core[(ib<<12)+core[74]] = 00653; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I00653() { lac += core[000142];  }
void I00654() { lac += core[000065];  }
void I00655() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00656() { npc = 000651; inh = 0;  }
void I00657() { lac += core[(df<<12)+core[102]];  }
void L00660() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00661() { npc = 000703; inh = 0;  }
void I00662() { lac++;  }
void I00663() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I00664() { lac += core[000141];  }
void I00665() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00666() { lac += core[(df<<12)+core[108]];  }
void I00667() { core[(ib<<12)+core[84]] = 00670; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I00670() { npc = 000676; inh = 0;  }
void L00671() { lac += core[(df<<12)+core[108]];  }
void I00672() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void I00673() { npc = 000644; inh = 0;  }
void L00674() { lac += core[000146];  }
void I00675() { npc = 000660; inh = 0;  }
void L00676() { lac += core[000141];  }
void I00677() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00700() { npc = 000703; inh = 0;  }
void D00701() { core[(ib<<12)+core[74]] = 00702; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I00702() { npc = 000671; inh = 0;  }
void L00703() { core[(ib<<12)+core[458]] = 00704; npc = (ib<<12)+core[458]+1; code[(ib<<12)+core[458]] = &emul8; inh = 0;  }
void D00704() { core[000151] = lac & 07777; lac &= 010000; code[000151] = &emul8;  }
void L00705() { core[(ib<<12)+core[117]] = 00706; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void D00706() { npc = 000705; inh = 0;  }
void D00707() { npc = 000616; inh = 0;  }
void D00710() { npc = 000641; inh = 0;  }
void P00711() { if (++core[(df<<12)+core[29]] == 010000) { core[(df<<12)+core[29]] = 0; npc++; }; code[(df<<12)+core[29]] = &emul8;  }
void P00712() { if (++core[(df<<12)+core[35]] == 010000) { core[(df<<12)+core[35]] = 0; npc++; }; code[(df<<12)+core[35]] = &emul8;  }
void S00713() { lac &= (010000|core[000000]);  }
void D00714() { core[(ib<<12)+core[81]] = 00715; npc = (ib<<12)+core[81]+1; code[(ib<<12)+core[81]] = &emul8; inh = 0;  }
void D00715() { core[(ib<<12)+core[73]] = 00716; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I00716() { if (++core[000005] == 010000) { core[000005] = 0; npc++; }; code[000005] = &emul8;  }
void D00717() { npc = (ib<<12)+core[459]; inh = 0;  }
void I00720() { if (++core[000713] == 010000) { core[000713] = 0; npc++; }; code[000713] = &emul8;  }
void D00721() { core[(ib<<12)+core[82]] = 00722; npc = (ib<<12)+core[82]+1; code[(ib<<12)+core[82]] = &emul8; inh = 0;  }
void D00722() { npc = (ib<<12)+core[459]; inh = 0;  }
void D00723() { skp = 0; skp = !skp; npc += skp;  }
void D00724() { npc = (ib<<12)+core[459]; inh = 0;  }
void I00725() { lac += core[000142];  }
void I00726() { lac += core[000607];  }
void D00727() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00730() { if (++core[000713] == 010000) { core[000713] = 0; npc++; }; code[000713] = &emul8;  }
void I00731() { if (++core[000713] == 010000) { core[000713] = 0; npc++; }; code[000713] = &emul8;  }
void I00732() { npc = (ib<<12)+core[459]; inh = 0;  }
void S00733() { lac &= (010000|core[000000]);  }
void I00734() { lac += core[(df<<12)+core[475]];  }
void P00735() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void L00736() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I00737() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00740() { npc = 000752; inh = 0;  }
void I00741() { lac ^= 07777; lac++;  }
void I00742() { lac += core[000142];  }
void I00743() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00744() { npc = 000736; inh = 0;  }
void I00745() { lac += core[(df<<12)+core[475]];  }
void I00746() { lac ^= 07777;  }
void I00747() { lac += core[000012];  }
void I00750() { core[000127] = lac & 07777; lac &= 010000; code[000127] = &emul8;  }
void I00751() { skp = 0; skp = !skp; npc += skp;  }
void L00752() { if (++core[000733] == 010000) { core[000733] = 0; npc++; }; code[000733] = &emul8;  }
void I00753() { if (++core[000733] == 010000) { core[000733] = 0; npc++; }; code[000733] = &emul8;  }
void I00754() { lac &= 010000; lac &= 07777;  }
void P00755() { npc = (ib<<12)+core[475]; inh = 0;  }
void I00756() { lac &= (010000|core[000723]);  }
void I00757() { lac &= (010000|core[000706]);  }
void I00760() { lac &= (010000|core[000711]);  }
void I00761() { lac &= (010000|core[000704]);  }
void I00762() { lac &= (010000|core[000707]);  }
void I00763() { lac &= (010000|core[000703]);  }
void I00764() { lac &= (010000|core[000701]);  }
void I00765() { lac &= (010000|core[000724]);  }
void I00766() { lac &= (010000|core[000714]);  }
void I00767() { lac &= (010000|core[000705]);  }
void I00770() { lac &= (010000|core[000727]);  }
void I00771() { lac &= (010000|core[000715]);  }
void I00772() { lac &= (010000|core[000721]);  }
void I00773() { lac &= (010000|core[000722]);  }
void I00774() { lac &= (010000|core[000717]);  }
void I00775() { lac &= (010000|core[000710]);  }
void I00776() { core[(ib<<12)+core[73]] = 00777; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I00777() { lac += core[000022];  }
void P01000() { skp = 0; skp = !skp; npc += skp;  }
void P01001() { core[(ib<<12)+core[86]] = 01002; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01002() { core[(ib<<12)+core[65]] = 01003; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01003() { lac += core[(df<<12)+core[512]];  }
void L01004() { core[(ib<<12)+core[70]] = 01005; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01005() { lac += core[000045];  }
void D01006() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D01007() { npc = (ib<<12)+core[530]; inh = 0;  }
void P01010() { core[(ib<<12)+core[117]] = 01011; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void I01011() { npc = 001010; inh = 0;  }
void I01012() { npc = (ib<<12)+core[579]; inh = 0;  }
void I01013() { lac += core[000045];  }
void I01014() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D01015() { npc = (ib<<12)+core[530]; inh = 0;  }
void P01016() { core[(ib<<12)+core[117]] = 01017; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void I01017() { npc = 001016; inh = 0;  }
void P01020() { npc = (ib<<12)+core[579]; inh = 0;  }
void I01021() { npc = (ib<<12)+core[530]; inh = 0;  }
void P01022() { lac &= (010000|core[(df<<12)+core[520]]);  }
void I01023() { lac &= (010000|core[001050]);  }
void I01024() { core[(ib<<12)+core[65]] = 01025; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01025() { lac += core[(df<<12)+core[4]];  }
void D01026() { core[(ib<<12)+core[81]] = 01027; npc = (ib<<12)+core[81]+1; code[(ib<<12)+core[81]] = &emul8; inh = 0;  }
void I01027() { core[(ib<<12)+core[73]] = 01030; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I01030() { if (++core[000024] == 010000) { core[000024] = 0; npc++; }; code[000024] = &emul8;  }
void I01031() { skp = 0; skp = !skp; npc += skp;  }
void I01032() { core[(ib<<12)+core[86]] = 01033; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01033() { lac += core[000154];  }
void I01034() { core[001132] = lac & 07777; lac &= 010000; code[001132] = &emul8;  }
void I01035() { core[(ib<<12)+core[65]] = 01036; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01036() { lac += core[(df<<12)+core[512]];  }
void I01037() { core[(ib<<12)+core[7]] = 01040; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void D01040() { &emul8;  }
void P01041() { &emul8;  }
void D01042() { core[(ib<<12)+core[117]] = 01043; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void D01043() { core[(ib<<12)+core[86]] = 01044; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void L01044() { npc = (ib<<12)+core[579]; inh = 0;  }
void D01045() { lac += core[001132];  }
void D01046() { core[(ib<<12)+core[67]] = 01047; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I01047() { core[(ib<<12)+core[65]] = 01050; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void D01050() { lac += core[(df<<12)+core[513]];  }
void I01051() { core[(ib<<12)+core[117]] = 01052; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void D01052() { core[(ib<<12)+core[86]] = 01053; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01053() { npc = 001117; inh = 0;  }
void D01054() { core[(ib<<12)+core[68]] = 01055; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I01055() { if (++core[000034] == 010000) { core[000034] = 0; npc++; }; code[000034] = &emul8;  }
void I01056() { core[(ib<<12)+core[65]] = 01057; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01057() { lac += core[(df<<12)+core[513]];  }
void L01060() { core[(ib<<12)+core[68]] = 01061; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I01061() { if (++core[000034] == 010000) { core[000034] = 0; npc++; }; code[000034] = &emul8;  }
void I01062() { core[(ib<<12)+core[596]] = 01063; npc = (ib<<12)+core[596]+1; code[(ib<<12)+core[596]] = &emul8; inh = 0;  }
void I01063() { core[(ib<<12)+core[24]] = 01064; npc = (ib<<12)+core[24]+1; code[(ib<<12)+core[24]] = &emul8; inh = 0;  }
void L01064() { core[(ib<<12)+core[7]] = 01065; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I01065() { &emul8;  }
void I01066() { &emul8;  }
void I01067() { &emul8;  }
void I01070() { &emul8;  }
void I01071() { lac += core[000013];  }
void I01072() { lac += core[001122];  }
void D01073() { core[001132] = lac & 07777; lac &= 010000; code[001132] = &emul8;  }
void D01074() { lac += core[(df<<12)+core[602]];  }
void I01075() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01076() { core[(ib<<12)+core[40]] = 01077; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I01077() { lac += core[000045];  }
void I01100() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I01101() { npc = 001126; inh = 0;  }
void I01102() { core[(ib<<12)+core[65]] = 01103; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void P01103() { lac &= (010000|core[(df<<12)+core[526]]);  }
void I01104() { core[(ib<<12)+core[597]] = 01105; npc = (ib<<12)+core[597]+1; code[(ib<<12)+core[597]] = &emul8; inh = 0;  }
void I01105() { core[(ib<<12)+core[69]] = 01106; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I01106() { if (++core[000034] == 010000) { core[000034] = 0; npc++; }; code[000034] = &emul8;  }
void I01107() { core[(ib<<12)+core[69]] = 01110; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I01110() { lac &= (010000|core[000044]);  }
void I01111() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01112() { core[001132] = lac & 07777; lac &= 010000; code[001132] = &emul8;  }
void I01113() { lac += core[001123];  }
void I01114() { lac += core[000013];  }
void I01115() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01116() { npc = 001064; inh = 0;  }
void L01117() { core[(ib<<12)+core[68]] = 01120; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I01120() { lac += core[(df<<12)+core[123]];  }
void I01121() { npc = 001060; inh = 0;  }
void D01122() { lac &= (010000|core[000011]);  }
void D01123() { emul8();  }
void P01124() { if (++core[(df<<12)+core[29]] == 010000) { core[(df<<12)+core[29]] = 0; npc++; }; code[(df<<12)+core[29]] = &emul8;  }
void P01125() { if (++core[(df<<12)+core[35]] == 010000) { core[(df<<12)+core[35]] = 0; npc++; }; code[(df<<12)+core[35]] = &emul8;  }
void L01126() { lac += core[000005];  }
void I01127() { lac += core[000013];  }
void I01130() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I01131() { npc = (ib<<12)+core[66]; inh = 0;  }
void P01132() { lac &= (010000|core[000000]);  }
void I01133() { lac &= (010000|core[001046]);  }
void D01134() { lac &= (010000|core[001045]);  }
void P01135() { lac &= (010000|core[001042]);  }
void I01136() { lac &= (010000|core[001041]);  }
void I01137() { lac &= (010000|core[001043]);  }
void I01140() { lac &= (010000|core[001044]);  }
void I01141() { lac &= (010000|core[001040]);  }
void D01142() { lac &= (010000|core[001054]);  }
void I01143() { lac &= (010000|core[001073]);  }
void I01144() { lac &= (010000|core[001015]);  }
void I01145() { core[(ib<<12)+core[42]] = 01146; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I01146() { emul8();  }
void I01147() { lac &= 010000;  }
void I01150() { lac += core[001161];  }
void I01151() { emul8();  }
void I01152() { skp = 0; skp = !skp; npc += skp;  }
void I01153() { core[(ib<<12)+core[42]] = 01154; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I01154() { core[001161] = lac & 07777; lac &= 010000; code[001161] = &emul8;  }
void I01155() { npc = (ib<<12)+core[64]; inh = 0;  }
void L01156() { core[(ib<<12)+core[42]] = 01157; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I01157() { lac &= 010000;  }
void I01160() { npc = (ib<<12)+core[64]; inh = 0;  }
void D01161() { lac &= (010000|core[000000]);  }
void L01162() { lac += core[001052];  }
void I01163() { lac += core[001010];  }
void I01164() { lac += core[000024];  }
void I01165() { lac += core[000024];  }
void I01166() { lac &= (010000|core[(df<<12)+core[638]]);  }
void I01167() { if (++core[000016] == 010000) core[000016] = 0000;lac &= (010000|core[(df<<12)+core[000016]]);  }
void I01170() { lac &= (010000|core[(df<<12)+core[520]]);  }
void I01171() { lac &= (010000|core[(df<<12)+core[528]]);  }
void I01172() { lac += core[001006];  }
void I01173() { lac += core[001007];  }
void I01174() { if (++core[(df<<12)+core[605]] == 010000) { core[(df<<12)+core[605]] = 0; npc++; }; code[(df<<12)+core[605]] = &emul8;  }
void I01175() { if (++core[001026] == 010000) { core[001026] = 0; npc++; }; code[001026] = &emul8;  }
void P01176() { lac &= (010000|core[(df<<12)+core[545]]);  }
void I01177() { lac += core[001073];  }
void P01200() { lac &= (010000|core[000177]);  }
void P01201() { lac += core[(df<<12)+core[108]];  }
void I01202() { emul8();  }
void I01203() { core[001274] = lac & 07777; lac &= 010000; code[001274] = &emul8;  }
void I01204() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I01205() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void L01206() { lac &= 010000; lac ^= 07777;  }
void L01207() { core[000131] = lac & 07777; lac &= 010000; code[000131] = &emul8;  }
void L01210() { core[000151] = lac & 07777; lac &= 010000; code[000151] = &emul8;  }
void I01211() { core[(ib<<12)+core[72]] = 01212; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I01212() { lac += core[000132];  }
void I01213() { lac &= (010000|core[(df<<12)+core[22]]);  }
void I01214() { if (++core[000131] == 010000) { core[000131] = 0; npc++; }; code[000131] = &emul8;  }
void I01215() { npc = 001227; inh = 0;  }
void I01216() { core[(ib<<12)+core[65]] = 01217; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01217() { lac += core[(df<<12)+core[4]];  }
void I01220() { core[(ib<<12)+core[670]] = 01221; npc = (ib<<12)+core[670]+1; code[(ib<<12)+core[670]] = &emul8; inh = 0;  }
void I01221() { lac += core[001233];  }
void D01222() { core[(ib<<12)+core[74]] = 01223; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I01223() { core[(ib<<12)+core[662]] = 01224; npc = (ib<<12)+core[662]+1; code[(ib<<12)+core[662]] = &emul8; inh = 0;  }
void I01224() { core[(ib<<12)+core[671]] = 01225; npc = (ib<<12)+core[671]+1; code[(ib<<12)+core[671]] = &emul8; inh = 0;  }
void I01225() { npc = 001206; inh = 0;  }
void P01226() { core[001306] = lac & 07777; lac &= 010000; code[001306] = &emul8;  }
void L01227() { core[(ib<<12)+core[65]] = 01230; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01230() { lac += core[(df<<12)+core[641]];  }
void I01231() { core[(ib<<12)+core[117]] = 01232; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void I01232() { core[(ib<<12)+core[86]] = 01233; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void D01233() { lac &= (010000|core[001272]);  }
void I01234() { core[(ib<<12)+core[672]] = 01235; npc = (ib<<12)+core[672]+1; code[(ib<<12)+core[672]] = &emul8; inh = 0;  }
void L01235() { npc = 001207; inh = 0;  }
void P01236() { if (++core[(df<<12)+core[29]] == 010000) { core[(df<<12)+core[29]] = 0; npc++; }; code[(df<<12)+core[29]] = &emul8;  }
void P01237() { if (++core[(df<<12)+core[35]] == 010000) { core[(df<<12)+core[35]] = 0; npc++; }; code[(df<<12)+core[35]] = &emul8;  }
void P01240() { core[001365] = lac & 07777; lac &= 010000; code[001365] = &emul8;  }
void I01241() { if (++core[000151] == 010000) { core[000151] = 0; npc++; }; code[000151] = &emul8;  }
void L01242() { core[(ib<<12)+core[70]] = 01243; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01243() { core[(ib<<12)+core[72]] = 01244; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I01244() { lac += core[(df<<12)+core[4]];  }
void I01245() { emul8();  }
void I01246() { core[(ib<<12)+core[74]] = 01247; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I01247() { npc = 001242; inh = 0;  }
void I01250() { lac += core[000060];  }
void L01251() { core[(ib<<12)+core[74]] = 01252; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void L01252() { core[(ib<<12)+core[70]] = 01253; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01253() { npc = 001210; inh = 0;  }
void I01254() { lac += core[000060];  }
void I01255() { core[(ib<<12)+core[95]] = 01256; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I01256() { lac += core[000015];  }
void I01257() { npc = 001251; inh = 0;  }
void I01260() { core[(ib<<12)+core[70]] = 01261; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01261() { core[(ib<<12)+core[698]] = 01262; npc = (ib<<12)+core[698]+1; code[(ib<<12)+core[698]] = &emul8; inh = 0;  }
void I01262() { lac += core[000164];  }
void I01263() { core[000051] = lac & 07777; lac &= 010000; code[000051] = &emul8;  }
void I01264() { core[(ib<<12)+core[82]] = 01265; npc = (ib<<12)+core[82]+1; code[(ib<<12)+core[82]] = &emul8; inh = 0;  }
void I01265() { core[(ib<<12)+core[70]] = 01266; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01266() { core[(ib<<12)+core[698]] = 01267; npc = (ib<<12)+core[698]+1; code[(ib<<12)+core[698]] = &emul8; inh = 0;  }
void I01267() { lac += core[000164];  }
void I01270() { core[000133] = lac & 07777; lac &= 010000; code[000133] = &emul8;  }
void I01271() { npc = 001210; inh = 0;  }
void P01272() { emul8();  }
void I01273() { core[(ib<<12)+core[77]] = 01274; npc = (ib<<12)+core[77]+1; code[(ib<<12)+core[77]] = &emul8; inh = 0;  }
void D01274() { core[(ib<<12)+core[78]] = 01275; npc = (ib<<12)+core[78]+1; code[(ib<<12)+core[78]] = &emul8; inh = 0;  }
void L01275() { core[(ib<<12)+core[86]] = 01276; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01276() { lac += core[000134];  }
void I01277() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I01300() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I01301() { lac += core[000143];  }
void I01302() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01303() { npc = 001275; inh = 0;  }
void I01304() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I01305() { lac += core[000010];  }
void D01306() { core[000153] = lac & 07777; lac &= 010000; code[000153] = &emul8;  }
void D01307() { core[(ib<<12)+core[96]] = 01310; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I01310() { core[000061] = lac & 07777; lac &= 010000; code[000061] = &emul8;  }
void I01311() { if (++core[000151] == 010000) { core[000151] = 0; npc++; }; code[000151] = &emul8;  }
void L01312() { core[(ib<<12)+core[70]] = 01313; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01313() { core[(ib<<12)+core[74]] = 01314; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I01314() { core[(ib<<12)+core[72]] = 01315; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I01315() { lac &= (010000|core[000057]);  }
void I01316() { lac += core[001322];  }
void I01317() { core[(ib<<12)+core[71]] = 01320; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I01320() { npc = 001312; inh = 0;  }
void D01321() { lac += core[000134];  }
void D01322() { lac++;  }
void I01323() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I01324() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void L01325() { core[(ib<<12)+core[75]] = 01326; npc = (ib<<12)+core[75]+1; code[(ib<<12)+core[75]] = &emul8; inh = 0;  }
void I01326() { core[(ib<<12)+core[72]] = 01327; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I01327() { lac &= (010000|core[000053]);  }
void I01330() { lac += core[001322];  }
void I01331() { core[(ib<<12)+core[71]] = 01332; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I01332() { npc = 001325; inh = 0;  }
void S01333() { lac &= (010000|core[000000]);  }
void I01334() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01335() { lac += core[000142];  }
void I01336() { lac ^= 07777; lac++;  }
void I01337() { core[000157] = lac & 07777; lac &= 010000; code[000157] = &emul8;  }
void I01340() { lac += core[(df<<12)+core[731]];  }
void I01341() { if (++core[001333] == 010000) { core[001333] = 0; npc++; }; code[001333] = &emul8;  }
void I01342() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void L01343() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I01344() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I01345() { npc = 001357; inh = 0;  }
void I01346() { lac += core[000157];  }
void I01347() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01350() { npc = 001343; inh = 0;  }
void I01351() { lac += core[000012];  }
void I01352() { lac += core[(df<<12)+core[731]];  }
void I01353() { core[001333] = lac & 07777; lac &= 010000; code[001333] = &emul8;  }
void I01354() { lac += core[(df<<12)+core[731]];  }
void I01355() { core[001333] = lac & 07777; lac &= 010000; code[001333] = &emul8;  }
void I01356() { skp = 0; skp = !skp; npc += skp;  }
void L01357() { if (++core[001333] == 010000) { core[001333] = 0; npc++; }; code[001333] = &emul8;  }
void I01360() { lac &= 010000; lac &= 07777;  }
void I01361() { npc = (ib<<12)+core[731]; inh = 0;  }
void I01362() { core[(ib<<12)+core[65]] = 01363; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01363() { lac += core[(df<<12)+core[640]];  }
void I01364() { core[(ib<<12)+core[42]] = 01365; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void L01365() { lac &= 07777; lac ^= 07777; lac++;  }
void I01366() { lac++;  }
void I01367() { lac += core[000053];  }
void I01370() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01371() { npc = 001210; inh = 0;  }
void I01372() { lac += core[000033];  }
void I01373() { core[(ib<<12)+core[74]] = 01374; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I01374() { lac += core[000046];  }
void I01375() { npc = 001365; inh = 0;  }
void I01376() { lac += core[001321];  }
void I01377() { lac += core[001312];  }
void P01400() { lac += core[001507];  }
void I01401() { lac += core[001510];  }
void I01402() { lac &= (010000|core[001463]);  }
void I01403() { lac += core[001531];  }
void I01404() { core[(ib<<12)+core[85]] = 01405; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I01405() { lac &= (010000|core[001442]);  }
void I01406() { lac &= (010000|core[001415]);  }
void I01407() { core[(ib<<12)+core[86]] = 01410; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01410() { lac &= 010000; lac ^= 07777;  }
void I01411() { core[(ib<<12)+core[67]] = 01412; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I01412() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I01413() { core[(ib<<12)+core[71]] = 01414; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I01414() { core[(ib<<12)+core[70]] = 01415; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void P01415() { core[(ib<<12)+core[73]] = 01416; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I01416() { if (++core[000005] == 010000) { core[000005] = 0; npc++; }; code[000005] = &emul8;  }
void I01417() { npc = 001422; inh = 0;  }
void P01420() { lac += core[000142];  }
void I01421() { lac &= (010000|core[000071]);  }
void L01422() { lac += core[000135];  }
void I01423() { core[(ib<<12)+core[67]] = 01424; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void L01424() { core[(ib<<12)+core[73]] = 01425; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I01425() { if (++core[000005] == 010000) { core[000005] = 0; npc++; }; code[000005] = &emul8;  }
void I01426() { npc = 001431; inh = 0;  }
void I01427() { core[(ib<<12)+core[70]] = 01430; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01430() { npc = 001424; inh = 0;  }
void L01431() { core[(ib<<12)+core[83]] = 01432; npc = (ib<<12)+core[83]+1; code[(ib<<12)+core[83]] = &emul8; inh = 0;  }
void I01432() { npc = 001443; inh = 0;  }
void I01433() { lac += core[000130];  }
void I01434() { core[(ib<<12)+core[67]] = 01435; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I01435() { core[(ib<<12)+core[65]] = 01436; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01436() { lac += core[(df<<12)+core[768]];  }
void I01437() { core[(ib<<12)+core[70]] = 01440; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01440() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void D01441() { core[000130] = lac & 07777; lac &= 010000; code[000130] = &emul8;  }
void D01442() { core[(ib<<12)+core[42]] = 01443; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void L01443() { core[001524] = lac & 07777; lac &= 010000; code[001524] = &emul8;  }
void I01444() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01445() { core[000135] = lac & 07777; lac &= 010000; code[000135] = &emul8;  }
void I01446() { lac += core[000134];  }
void L01447() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void D01450() { lac += core[000154];  }
void I01451() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void D01452() { lac += core[000154];  }
void I01453() { lac ^= 07777; lac++;  }
void D01454() { lac += core[000155];  }
void I01455() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01456() { npc = 001467; inh = 0;  }
void I01457() { lac += core[(df<<12)+core[108]];  }
void D01460() { lac ^= 07777; lac++;  }
void I01461() { lac += core[000135];  }
void I01462() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D01463() { npc = 001512; inh = 0;  }
void L01464() { lac += core[000154];  }
void I01465() { lac += core[000144];  }
void I01466() { npc = 001447; inh = 0;  }
void L01467() { if (++core[000013] == 010000) core[000013] = 0000;if (++core[(df<<12)+core[000013]] == 010000) { core[(df<<12)+core[000013]] = 0; npc++; }; code[(df<<12)+core[000013]] = &emul8;  }
void I01470() { core[(ib<<12)+core[86]] = 01471; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01471() { lac += core[000155];  }
void I01472() { lac += core[000005];  }
void I01473() { lac &= 07777; lac ^= 07777; lac++;  }
void I01474() { lac += core[000013];  }
void I01475() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I01476() { core[(ib<<12)+core[86]] = 01477; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01477() { lac += core[000155];  }
void I01500() { lac += core[000144];  }
void I01501() { core[000155] = lac & 07777; lac &= 010000; code[000155] = &emul8;  }
void I01502() { lac += core[000135];  }
void I01503() { core[(df<<12)+core[108]] = lac & 07777; lac &= 010000; code[(df<<12)+core[108]] = &emul8;  }
void I01504() { lac += core[001524];  }
void I01505() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I01506() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void D01507() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void D01510() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I01511() { npc = 001520; inh = 0;  }
void L01512() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void I01513() { lac ^= 07777; lac++;  }
void I01514() { lac += core[001524];  }
void I01515() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01516() { npc = 001464; inh = 0;  }
void I01517() { if (++core[000013] == 010000) { core[000013] = 0; npc++; }; code[000013] = &emul8;  }
void L01520() { if (++core[000154] == 010000) { core[000154] = 0; npc++; }; code[000154] = &emul8;  }
void I01521() { if (++core[000154] == 010000) { core[000154] = 0; npc++; }; code[000154] = &emul8;  }
void I01522() { npc = (ib<<12)+core[66]; inh = 0;  }
void D01523() { lac += core[(df<<12)+core[125]];  }
void S01524() { lac &= (010000|core[000000]);  }
void L01525() { lac += core[000142];  }
void I01526() { lac += core[000063];  }
void I01527() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01530() { npc = (ib<<12)+core[852]; inh = 0;  }
void D01531() { core[(ib<<12)+core[70]] = 01532; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01532() { npc = 001525; inh = 0;  }
void S01533() { lac &= (010000|core[000000]);  }
void I01534() { lac += core[000142];  }
void I01535() { lac += core[000064];  }
void I01536() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01537() { if (++core[001533] == 010000) { core[001533] = 0; npc++; }; code[001533] = &emul8;  }
void I01540() { lac += core[001552];  }
void I01541() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I01542() { npc = 001550; inh = 0;  }
void I01543() { lac += core[001553];  }
void I01544() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I01545() { npc = 001550; inh = 0;  }
void I01546() { core[000127] = lac & 07777; lac &= 010000; code[000127] = &emul8;  }
void I01547() { if (++core[001533] == 010000) { core[001533] = 0; npc++; }; code[001533] = &emul8;  }
void L01550() { lac &= 010000; lac &= 07777;  }
void D01551() { npc = (ib<<12)+core[859]; inh = 0;  }
void D01552() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void D01553() { lac &= (010000|core[000012]);  }
void D01554() { lac += core[001523];  }
void I01555() { core[000145] = lac & 07777; lac &= 010000; code[000145] = &emul8;  }
void L01556() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01557() { core[000157] = lac & 07777; lac &= 010000; code[000157] = &emul8;  }
void I01560() { npc = (ib<<12)+core[111]; inh = 0;  }
void I01561() { lac += core[001562];  }
void D01562() { lac += core[001460];  }
void I01563() { lac += core[001441];  }
void I01564() { lac += core[001450];  }
void I01565() { lac += core[001454];  }
void I01566() { core[000125] = lac & 07777; lac &= 010000; code[000125] = &emul8;  }
void I01567() { lac += core[001452];  }
void I01570() { lac += core[001452];  }
void I01571() { lac &= (010000|core[(df<<12)+core[781]]);  }
void I01572() { lac &= (010000|core[(df<<12)+core[784]]);  }
void D01573() { lac &= (010000|core[000001]);  }
void I01574() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void D01575() { lac &= (010000|core[000000]);  }
void I01576() { lac &= (010000|core[000000]);  }
void I01577() { lac &= (010000|core[000000]);  }
void P01600() { core[(ib<<12)+core[70]] = 01601; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01601() { core[000130] = lac & 07777; lac &= 010000; code[000130] = &emul8;  }
void I01602() { core[(ib<<12)+core[85]] = 01603; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I01603() { npc = 001615; inh = 0;  }
void I01604() { npc = 001732; inh = 0;  }
void I01605() { npc = 001742; inh = 0;  }
void L01606() { core[(ib<<12)+core[65]] = 01607; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01607() { if (++core[000011] == 010000) core[000011] = 0000;lac += core[(df<<12)+core[000011]];  }
void L01610() { core[(ib<<12)+core[85]] = 01611; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I01611() { npc = 001636; inh = 0;  }
void D01612() { lac &= (010000|core[001612]);  }
void I01613() { lac &= (010000|core[001777]);  }
void I01614() { core[(ib<<12)+core[86]] = 01615; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void L01615() { core[(ib<<12)+core[68]] = 01616; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I01616() { lac += core[(df<<12)+core[125]];  }
void I01617() { core[(ib<<12)+core[69]] = 01620; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I01620() { if (++core[000034] == 010000) { core[000034] = 0; npc++; }; code[000034] = &emul8;  }
void I01621() { lac += core[000160];  }
void I01622() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I01623() { lac += core[000034];  }
void I01624() { lac += core[000127];  }
void I01625() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01626() { npc = 001641; inh = 0;  }
void I01627() { lac++;  }
void I01630() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01631() { npc = 001723; inh = 0;  }
void I01632() { lac += core[000127];  }
void D01633() { lac += core[000070];  }
void I01634() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01635() { npc = 001753; inh = 0;  }
void L01636() { core[(ib<<12)+core[83]] = 01637; npc = (ib<<12)+core[83]+1; code[(ib<<12)+core[83]] = &emul8; inh = 0;  }
void I01637() { skp = 0; skp = !skp; npc += skp;  }
void I01640() { core[(ib<<12)+core[86]] = 01641; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void L01641() { lac += core[000127];  }
void I01642() { core[000147] = lac & 07777; lac &= 010000; code[000147] = &emul8;  }
void I01643() { lac += core[000147];  }
void I01644() { lac += core[000070];  }
void I01645() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I01646() { core[000147] = lac & 07777; lac &= 010000; code[000147] = &emul8;  }
void L01647() { lac &= 010000; lac++;  }
void I01650() { lac &= (010000|core[000147]);  }
void I01651() { lac += core[000147];  }
void I01652() { lac ^= 07777; lac++;  }
void I01653() { core[001674] = lac & 07777; lac &= 010000; code[001674] = &emul8;  }
void I01654() { lac++;  }
void I01655() { lac &= (010000|core[000130]);  }
void I01656() { lac += core[000130];  }
void I01657() { lac += core[001674];  }
void I01660() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01661() { npc = 001710; inh = 0;  }
void I01662() { lac += core[000130];  }
void I01663() { lac += core[001731];  }
void I01664() { core[001674] = lac & 07777; lac &= 010000; code[001674] = &emul8;  }
void I01665() { lac += core[(df<<12)+core[956]];  }
void I01666() { core[001674] = lac & 07777; lac &= 010000; code[001674] = &emul8;  }
void I01667() { lac += core[000130];  }
void I01670() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I01671() { core[(ib<<12)+core[69]] = 01672; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I01672() { lac &= (010000|core[000044]);  }
void I01673() { core[(ib<<12)+core[7]] = 01674; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void P01674() { &emul8;  }
void I01675() { emul8();  }
void I01676() { lac &= (010000|core[000000]);  }
void I01677() { lac += core[000160];  }
void I01700() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I01701() { lac += core[000147];  }
void I01702() { lac += core[000130];  }
void I01703() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I01704() { npc = (ib<<12)+core[66]; inh = 0;  }
void I01705() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I01706() { core[000130] = lac & 07777; lac &= 010000; code[000130] = &emul8;  }
void I01707() { npc = 001647; inh = 0;  }
void L01710() { core[(ib<<12)+core[83]] = 01711; npc = (ib<<12)+core[83]+1; code[(ib<<12)+core[83]] = &emul8; inh = 0;  }
void I01711() { skp = 0; skp = !skp; npc += skp;  }
void I01712() { npc = 001755; inh = 0;  }
void I01713() { lac += core[000130];  }
void I01714() { core[(ib<<12)+core[67]] = 01715; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I01715() { lac += core[000154];  }
void I01716() { core[001720] = lac & 07777; lac &= 010000; code[001720] = &emul8;  }
void I01717() { core[(ib<<12)+core[68]] = 01720; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void D01720() { lac &= (010000|core[000000]);  }
void I01721() { lac += core[000147];  }
void I01722() { core[000130] = lac & 07777; lac &= 010000; code[000130] = &emul8;  }
void L01723() { core[(ib<<12)+core[70]] = 01724; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01724() { core[(ib<<12)+core[85]] = 01725; npc = (ib<<12)+core[85]+1; code[(ib<<12)+core[85]] = &emul8; inh = 0;  }
void I01725() { npc = 001753; inh = 0;  }
void I01726() { npc = 001732; inh = 0;  }
void I01727() { npc = 001742; inh = 0;  }
void I01730() { npc = 001606; inh = 0;  }
void D01731() { if (++core[000026] == 010000) { core[000026] = 0; npc++; }; code[000026] = &emul8;  }
void L01732() { core[(ib<<12)+core[68]] = 01733; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I01733() { lac &= (010000|core[000044]);  }
void I01734() { lac += core[000160];  }
void I01735() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I01736() { core[(ib<<12)+core[59]] = 01737; npc = (ib<<12)+core[59]+1; code[(ib<<12)+core[59]] = &emul8; inh = 0;  }
void I01737() { core[(ib<<12)+core[69]] = 01740; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I01740() { lac &= (010000|core[000044]);  }
void I01741() { npc = 001610; inh = 0;  }
void L01742() { core[001674] = lac & 07777; lac &= 010000; code[001674] = &emul8;  }
void I01743() { core[(ib<<12)+core[70]] = 01744; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I01744() { core[(ib<<12)+core[73]] = 01745; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I01745() { if (++core[000005] == 010000) { core[000005] = 0; npc++; }; code[000005] = &emul8;  }
void I01746() { npc = 001764; inh = 0;  }
void I01747() { lac += core[001674];  }
void I01750() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I01751() { lac += core[000142];  }
void I01752() { npc = 001742; inh = 0;  }
void L01753() { core[(ib<<12)+core[83]] = 01754; npc = (ib<<12)+core[83]+1; code[(ib<<12)+core[83]] = &emul8; inh = 0;  }
void I01754() { core[(ib<<12)+core[86]] = 01755; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void L01755() { lac += core[000127];  }
void I01756() { core[(ib<<12)+core[67]] = 01757; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I01757() { lac += core[000130];  }
void I01760() { core[(ib<<12)+core[67]] = 01761; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I01761() { core[(ib<<12)+core[65]] = 01762; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01762() { lac += core[(df<<12)+core[896]];  }
void I01763() { npc = (ib<<12)+core[64]; inh = 0;  }
void L01764() { lac += core[000127];  }
void I01765() { core[(ib<<12)+core[67]] = 01766; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I01766() { lac += core[000130];  }
void I01767() { core[(ib<<12)+core[67]] = 01770; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I01770() { lac += core[001674];  }
void I01771() { core[(ib<<12)+core[67]] = 01772; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I01772() { core[(ib<<12)+core[83]] = 01773; npc = (ib<<12)+core[83]+1; code[(ib<<12)+core[83]] = &emul8; inh = 0;  }
void I01773() { core[(ib<<12)+core[86]] = 01774; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I01774() { core[(ib<<12)+core[65]] = 01775; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I01775() { lac += core[(df<<12)+core[896]];  }
void I01776() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void D01777() { core[(ib<<12)+core[72]] = 02000; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I02000() { if (++core[002007] == 010000) { core[002007] = 0; npc++; }; code[002007] = &emul8;  }
void I02001() { emul8();  }
void I02002() { core[(ib<<12)+core[86]] = 02003; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void D02003() { lac &= (010000|core[002041]);  }
void I02004() { lac &= (010000|core[002042]);  }
void I02005() { lac &= (010000|core[002056]);  }
void I02006() { lac &= (010000|core[002040]);  }
void D02007() { lac &= (010000|core[002053]);  }
void P02010() { lac &= (010000|core[002055]);  }
void I02011() { lac &= (010000|core[002057]);  }
void I02012() { lac &= (010000|core[002052]);  }
void I02013() { lac &= (010000|core[002136]);  }
void I02014() { lac &= (010000|core[002050]);  }
void D02015() { lac &= (010000|core[002133]);  }
void I02016() { lac &= (010000|core[002074]);  }
void I02017() { lac &= (010000|core[002051]);  }
void I02020() { lac &= (010000|core[002135]);  }
void I02021() { lac &= (010000|core[002076]);  }
void I02022() { lac &= (010000|core[002054]);  }
void I02023() { lac &= (010000|core[002073]);  }
void I02024() { lac &= (010000|core[002015]);  }
void I02025() { lac &= (010000|core[002075]);  }
void I02026() { npc = (ib<<12)+core[108]; inh = 0;  }
void I02027() { lac += core[(df<<12)+core[108]];  }
void I02030() { if (++core[(df<<12)+core[108]] == 010000) { core[(df<<12)+core[108]] = 0; npc++; }; code[(df<<12)+core[108]] = &emul8;  }
void I02031() { core[(ib<<12)+core[108]] = 02032; npc = (ib<<12)+core[108]+1; code[(ib<<12)+core[108]] = &emul8; inh = 0;  }
void I02032() { core[(df<<12)+core[108]] = lac & 07777; lac &= 010000; code[(df<<12)+core[108]] = &emul8;  }
void I02033() { lac &= (010000|core[(df<<12)+core[108]]);  }
void D02034() { lac &= (010000|core[000000]);  }
void I02035() { lac &= (010000|core[000000]);  }
void I02036() { lac &= (010000|core[000000]);  }
void D02037() { lac ^= 07777; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D02040() { emul8();  }
void D02041() { lac += core[(df<<12)+core[1120]];  }
void D02042() { lac += core[002154];  }
void I02043() { if (++core[(df<<12)+core[44]] == 010000) { core[(df<<12)+core[44]] = 0; npc++; }; code[(df<<12)+core[44]] = &emul8;  }
void I02044() { lac += core[000154];  }
void I02045() { lac &= (010000|core[(df<<12)+core[108]]);  }
void I02046() { lac &= 010000; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1); lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I02047() { if (++core[002173] == 010000) { core[002173] = 0; npc++; }; code[002173] = &emul8;  }
void D02050() { lac &= (010000|core[(df<<12)+core[96]]);  }
void D02051() { lac &= (010000|core[000177]);  }
void D02052() { lac += core[(df<<12)+core[64]];  }
void D02053() { lac += core[000045];  }
void D02054() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D02055() { core[(ib<<12)+core[40]] = 02056; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void L02056() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void D02057() { core[000130] = lac & 07777; lac &= 010000; code[000130] = &emul8;  }
void I02060() { core[(ib<<12)+core[7]] = 02061; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I02061() { &emul8;  }
void I02062() { &emul8;  }
void I02063() { &emul8;  }
void I02064() { lac += core[000160];  }
void I02065() { core[000154] = lac & 07777; lac &= 010000; code[000154] = &emul8;  }
void I02066() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I02067() { lac ^= 07777; lac++;  }
void I02070() { lac += core[000066];  }
void I02071() { lac += core[000127];  }
void I02072() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void D02073() { core[(ib<<12)+core[86]] = 02074; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void D02074() { core[(ib<<12)+core[70]] = 02075; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void D02075() { npc = (ib<<12)+core[1086]; inh = 0;  }
void P02076() { lac += core[(df<<12)+core[1032]];  }
void S02077() { lac &= (010000|core[000000]);  }
void I02100() { lac += core[000127];  }
void I02101() { lac += core[000070];  }
void I02102() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I02103() { npc = (ib<<12)+core[1087]; inh = 0;  }
void I02104() { lac += core[000127];  }
void I02105() { lac += core[000067];  }
void I02106() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I02107() { if (++core[002077] == 010000) { core[002077] = 0; npc++; }; code[002077] = &emul8;  }
void I02110() { npc = (ib<<12)+core[1087]; inh = 0;  }
void L02111() { core[(ib<<12)+core[78]] = 02112; npc = (ib<<12)+core[78]+1; code[(ib<<12)+core[78]] = &emul8; inh = 0;  }
void I02112() { npc = (ib<<12)+core[66]; inh = 0;  }
void I02113() { if (++core[000151] == 010000) { core[000151] = 0; npc++; }; code[000151] = &emul8;  }
void L02114() { core[(ib<<12)+core[70]] = 02115; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I02115() { lac += core[000142];  }
void I02116() { lac += core[000065];  }
void I02117() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02120() { npc = 002114; inh = 0;  }
void I02121() { lac += core[000017];  }
void I02122() { lac ^= 07777;  }
void I02123() { lac += core[000146];  }
void I02124() { core[000132] = lac & 07777; lac &= 010000; code[000132] = &emul8;  }
void I02125() { lac += core[(df<<12)+core[102]];  }
void I02126() { core[(df<<12)+core[104]] = lac & 07777; lac &= 010000; code[(df<<12)+core[104]] = &emul8;  }
void I02127() { lac += core[000075];  }
void L02130() { core[000157] = lac & 07777; lac &= 010000; code[000157] = &emul8;  }
void I02131() { lac += core[(df<<12)+core[111]];  }
void I02132() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void D02133() { npc = 002146; inh = 0;  }
void I02134() { core[000156] = lac & 07777; lac &= 010000; code[000156] = &emul8;  }
void D02135() { lac += core[000146];  }
void D02136() { lac &= 07777; lac ^= 07777; lac++;  }
void I02137() { lac += core[000156];  }
void P02140() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02141() { lac += core[000132];  }
void I02142() { lac += core[000156];  }
void I02143() { core[(df<<12)+core[111]] = lac & 07777; lac &= 010000; code[(df<<12)+core[111]] = &emul8;  }
void I02144() { lac += core[000156];  }
void I02145() { npc = 002130; inh = 0;  }
void L02146() { lac ^= 07777;  }
void I02147() { lac += core[000146];  }
void I02150() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void I02151() { lac += core[000132];  }
void I02152() { lac ^= 07777;  }
void I02153() { lac += core[000146];  }
void D02154() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I02155() { lac += core[000132];  }
void I02156() { lac += core[000134];  }
void I02157() { core[000134] = lac & 07777; lac &= 010000; code[000134] = &emul8;  }
void I02160() { lac += core[000010];  }
void I02161() { lac ^= 07777;  }
void I02162() { lac += core[000012];  }
void I02163() { core[000156] = lac & 07777; lac &= 010000; code[000156] = &emul8;  }
void I02164() { lac += core[000010];  }
void I02165() { lac += core[000132];  }
void I02166() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L02167() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I02170() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I02171() { if (++core[000156] == 010000) { core[000156] = 0; npc++; }; code[000156] = &emul8;  }
void I02172() { npc = 002167; inh = 0;  }
void D02173() { npc = 002111; inh = 0;  }
void I02174() { emul8();  }
void I02175() { emul8();  }
void I02176() { core[002037] = lac & 07777; lac &= 010000; code[002037] = &emul8;  }
void I02177() { core[002034] = lac & 07777; lac &= 010000; code[002034] = &emul8;  }
void I02200() { core[002303] = lac & 07777; lac &= 010000; code[002303] = &emul8;  }
void I02201() { core[002302] = lac & 07777; lac &= 010000; code[002302] = &emul8;  }
void I02202() { core[002244] = lac & 07777; lac &= 010000; code[002244] = &emul8;  }
void I02203() { core[002243] = lac & 07777; lac &= 010000; code[002243] = &emul8;  }
void I02204() { core[002252] = lac & 07777; lac &= 010000; code[002252] = &emul8;  }
void I02205() { core[002253] = lac & 07777; lac &= 010000; code[002253] = &emul8;  }
void I02206() { core[002256] = lac & 07777; lac &= 010000; code[002256] = &emul8;  }
void I02207() { core[002271] = lac & 07777; lac &= 010000; code[002271] = &emul8;  }
void I02210() { if (++core[(df<<12)+core[91]] == 010000) { core[(df<<12)+core[91]] = 0; npc++; }; code[(df<<12)+core[91]] = &emul8;  }
void I02211() { if (++core[(df<<12)+core[1192]] == 010000) { core[(df<<12)+core[1192]] = 0; npc++; }; code[(df<<12)+core[1192]] = &emul8;  }
void I02212() { if (++core[(df<<12)+core[1182]] == 010000) { core[(df<<12)+core[1182]] = 0; npc++; }; code[(df<<12)+core[1182]] = &emul8;  }
void I02213() { if (++core[(df<<12)+core[117]] == 010000) { core[(df<<12)+core[117]] = 0; npc++; }; code[(df<<12)+core[117]] = &emul8;  }
void I02214() { if (++core[(df<<12)+core[1176]] == 010000) { core[(df<<12)+core[1176]] = 0; npc++; }; code[(df<<12)+core[1176]] = &emul8;  }
void I02215() { if (++core[(df<<12)+core[1171]] == 010000) { core[(df<<12)+core[1171]] = 0; npc++; }; code[(df<<12)+core[1171]] = &emul8;  }
void P02216() { if (++core[(df<<12)+core[79]] == 010000) { core[(df<<12)+core[79]] = 0; npc++; }; code[(df<<12)+core[79]] = &emul8;  }
void I02217() { if (++core[(df<<12)+core[122]] == 010000) { core[(df<<12)+core[122]] = 0; npc++; }; code[(df<<12)+core[122]] = &emul8;  }
void I02220() { if (++core[(df<<12)+core[1172]] == 010000) { core[(df<<12)+core[1172]] = 0; npc++; }; code[(df<<12)+core[1172]] = &emul8;  }
void I02221() { if (++core[(df<<12)+core[1173]] == 010000) { core[(df<<12)+core[1173]] = 0; npc++; }; code[(df<<12)+core[1173]] = &emul8;  }
void I02222() { if (++core[(df<<12)+core[1196]] == 010000) { core[(df<<12)+core[1196]] = 0; npc++; }; code[(df<<12)+core[1196]] = &emul8;  }
void P02223() { if (++core[(df<<12)+core[125]] == 010000) { core[(df<<12)+core[125]] = 0; npc++; }; code[(df<<12)+core[125]] = &emul8;  }
void P02224() { if (++core[(df<<12)+core[1218]] == 010000) { core[(df<<12)+core[1218]] = 0; npc++; }; code[(df<<12)+core[1218]] = &emul8;  }
void P02225() { if (++core[(df<<12)+core[1177]] == 010000) { core[(df<<12)+core[1177]] = 0; npc++; }; code[(df<<12)+core[1177]] = &emul8;  }
void I02226() { lac += core[000142];  }
void I02227() { lac += core[000003];  }
void P02230() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void P02231() { npc = 002240; inh = 0;  }
void L02232() { lac += core[000077];  }
void I02233() { core[000134] = lac & 07777; lac &= 010000; code[000134] = &emul8;  }
void I02234() { core[(df<<12)+core[61]] = lac & 07777; lac &= 010000; code[(df<<12)+core[61]] = &emul8;  }
void L02235() { lac += core[000134];  }
void P02236() { core[000155] = lac & 07777; lac &= 010000; code[000155] = &emul8;  }
void I02237() { npc = 000177; inh = 0;  }
void L02240() { core[(ib<<12)+core[77]] = 02241; npc = (ib<<12)+core[77]+1; code[(ib<<12)+core[77]] = &emul8; inh = 0;  }
void I02241() { lac += core[000143];  }
void I02242() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void D02243() { npc = 002250; inh = 0;  }
void D02244() { lac += core[000134];  }
void I02245() { core[000155] = lac & 07777; lac &= 010000; code[000155] = &emul8;  }
void I02246() { npc = (ib<<12)+core[1191]; inh = 0;  }
void P02247() { lac &= (010000|core[(df<<12)+core[1166]]);  }
void P02250() { lac += core[000134];  }
void I02251() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L02252() { core[(ib<<12)+core[65]] = 02253; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void D02253() { if (++core[000111] == 010000) { core[000111] = 0; npc++; }; code[000111] = &emul8;  }
void P02254() { if (++core[000146] == 010000) { core[000146] = 0; npc++; }; code[000146] = &emul8;  }
void I02255() { lac += core[000141];  }
void D02256() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I02257() { lac += core[(df<<12)+core[102]];  }
void I02260() { core[(ib<<12)+core[84]] = 02261; npc = (ib<<12)+core[84]+1; code[(ib<<12)+core[84]] = &emul8; inh = 0;  }
void I02261() { npc = 002235; inh = 0;  }
void I02262() { lac += core[(df<<12)+core[102]];  }
void I02263() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void I02264() { npc = 002252; inh = 0;  }
void S02265() { lac &= (010000|core[000000]);  }
void I02266() { lac += core[000075];  }
void I02267() { core[000150] = lac & 07777; lac &= 010000; code[000150] = &emul8;  }
void I02270() { lac += core[000075];  }
void L02271() { core[000146] = lac & 07777; lac &= 010000; code[000146] = &emul8;  }
void I02272() { lac += core[000146];  }
void I02273() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I02274() { lac += core[000143];  }
void I02275() { lac ^= 07777; lac++;  }
void I02276() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I02277() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02300() { if (++core[002265] == 010000) { core[002265] = 0; npc++; }; code[002265] = &emul8;  }
void I02301() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void P02302() { npc = 002310; inh = 0;  }
void D02303() { lac += core[000146];  }
void I02304() { core[000150] = lac & 07777; lac &= 010000; code[000150] = &emul8;  }
void I02305() { lac += core[(df<<12)+core[102]];  }
void I02306() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02307() { npc = 002271; inh = 0;  }
void L02310() { lac += core[000146];  }
void I02311() { lac++;  }
void I02312() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I02313() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I02314() { npc = (ib<<12)+core[1205]; inh = 0;  }
void S02315() { lac &= (010000|core[000000]);  }
void L02316() { core[002351] = 02317; npc = 002351+1; code[002351] = &emul8; inh = 0;  }
void L02317() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02320() { lac += core[000006];  }
void I02321() { lac += core[002377];  }
void I02322() { lac += core[000142];  }
void I02323() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02324() { npc = 002337; inh = 0;  }
void I02325() { lac += core[000054];  }
void L02326() { core[000142] = lac & 07777; lac &= 010000; code[000142] = &emul8;  }
void I02327() { lac += core[000151];  }
void I02330() { lac += core[000152];  }
void I02331() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02332() { core[(ib<<12)+core[74]] = 02333; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I02333() { npc = (ib<<12)+core[1229]; inh = 0;  }
void L02334() { core[002351] = 02335; npc = 002351+1; code[002351] = &emul8; inh = 0;  }
void I02335() { lac ^= 07777;  }
void I02336() { npc = 002317; inh = 0;  }
void L02337() { lac += core[000151];  }
void I02340() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02341() { npc = 002347; inh = 0;  }
void I02342() { lac += core[000152];  }
void I02343() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02344() { lac++;  }
void I02345() { core[000152] = lac & 07777; lac &= 010000; code[000152] = &emul8;  }
void I02346() { npc = 002316; inh = 0;  }
void L02347() { lac += core[000032];  }
void I02350() { npc = 002326; inh = 0;  }
void S02351() { lac &= (010000|core[000000]);  }
void I02352() { if (++core[000020] == 010000) { core[000020] = 0; npc++; }; code[000020] = &emul8;  }
void I02353() { npc = 002366; inh = 0;  }
void I02354() { lac += core[000021];  }
void L02355() { lac &= (010000|core[000071]);  }
void I02356() { core[000142] = lac & 07777; lac &= 010000; code[000142] = &emul8;  }
void I02357() { lac += core[000142];  }
void I02360() { lac += core[000023];  }
void I02361() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02362() { npc = 002334; inh = 0;  }
void I02363() { lac += core[000142];  }
void I02364() { lac += core[002376];  }
void I02365() { npc = (ib<<12)+core[1257]; inh = 0;  }
void L02366() { if (++core[000017] == 010000) core[000017] = 0000;lac += core[(df<<12)+core[000017]];  }
void I02367() { core[000021] = lac & 07777; lac &= 010000; code[000021] = &emul8;  }
void I02370() { lac ^= 07777;  }
void I02371() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I02372() { lac += core[000021];  }
void I02373() { core[(ib<<12)+core[80]] = 02374; npc = (ib<<12)+core[80]+1; code[(ib<<12)+core[80]] = &emul8; inh = 0;  }
void I02374() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02375() { npc = 002355; inh = 0;  }
void D02376() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D02377() { emul8();  }
void I02400() { lac &= (010000|core[002513]);  }
void I02401() { lac &= (010000|core[002522]);  }
void I02402() { lac &= (010000|core[002524]);  }
void I02403() { lac &= (010000|core[002520]);  }
void I02404() { lac &= (010000|core[002511]);  }
void I02405() { lac &= (010000|core[002503]);  }
void I02406() { lac &= (010000|core[002472]);  }
void I02407() { lac &= (010000|core[002530]);  }
void I02410() { lac &= (010000|core[002505]);  }
void P02411() { lac &= (010000|core[002516]);  }
void I02412() { lac &= (010000|core[002523]);  }
void I02413() { lac &= (010000|core[002515]);  }
void I02414() { emul8();  }
void I02415() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I02416() { npc = (ib<<12)+core[64]; inh = 0;  }
void S02417() { lac &= (010000|core[000000]);  }
void I02420() { lac += core[(df<<12)+core[104]];  }
void I02421() { core[(df<<12)+core[92]] = lac & 07777; lac &= 010000; code[(df<<12)+core[92]] = &emul8;  }
void I02422() { lac += core[000134];  }
void I02423() { core[(df<<12)+core[104]] = lac & 07777; lac &= 010000; code[(df<<12)+core[104]] = &emul8;  }
void I02424() { lac += core[000135];  }
void I02425() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02426() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I02427() { lac += core[000010];  }
void I02430() { lac++;  }
void I02431() { core[000134] = lac & 07777; lac &= 010000; code[000134] = &emul8;  }
void I02432() { lac += core[000134];  }
void I02433() { core[000155] = lac & 07777; lac &= 010000; code[000155] = &emul8;  }
void I02434() { npc = (ib<<12)+core[1295]; inh = 0;  }
void S02435() { lac &= (010000|core[000000]);  }
void I02436() { core[(ib<<12)+core[68]] = 02437; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I02437() { lac &= (010000|core[000017]);  }
void I02440() { lac += core[000142];  }
void I02441() { core[(ib<<12)+core[67]] = 02442; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void I02442() { npc = (ib<<12)+core[1309]; inh = 0;  }
void S02443() { lac &= (010000|core[000000]);  }
void I02444() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I02445() { core[000142] = lac & 07777; lac &= 010000; code[000142] = &emul8;  }
void I02446() { core[(ib<<12)+core[69]] = 02447; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I02447() { lac &= (010000|core[000017]);  }
void I02450() { npc = (ib<<12)+core[1315]; inh = 0;  }
void S02451() { lac &= (010000|core[000000]);  }
void I02452() { lac &= (010000|core[000024]);  }
void I02453() { lac ^= 07777; lac++;  }
void I02454() { core[000157] = lac & 07777; lac &= 010000; code[000157] = &emul8;  }
void I02455() { lac += core[000143];  }
void I02456() { lac &= (010000|core[000024]);  }
void I02457() { lac += core[000157];  }
void I02460() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02461() { if (++core[002451] == 010000) { core[002451] = 0; npc++; }; code[002451] = &emul8;  }
void I02462() { npc = (ib<<12)+core[1321]; inh = 0;  }
void S02463() { lac &= (010000|core[000000]);  }
void L02464() { core[(ib<<12)+core[96]] = 02465; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void I02465() { core[000142] = lac & 07777; lac &= 010000; code[000142] = &emul8;  }
void I02466() { core[(ib<<12)+core[73]] = 02467; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I02467() { lac += core[(df<<12)+core[1289]];  }
void I02470() { npc = (ib<<12)+core[1331]; inh = 0;  }
void D02471() { core[(ib<<12)+core[74]] = 02472; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void D02472() { lac += core[000142];  }
void I02473() { lac += core[000024];  }
void I02474() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02475() { npc = (ib<<12)+core[1331]; inh = 0;  }
void I02476() { npc = 002464; inh = 0;  }
void S02477() { lac &= (010000|core[000000]);  }
void I02500() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02501() { lac += core[000142];  }
void I02502() { lac += core[000065];  }
void D02503() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02504() { npc = 002510; inh = 0;  }
void D02505() { lac += core[000060];  }
void L02506() { core[(ib<<12)+core[95]] = 02507; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I02507() { npc = (ib<<12)+core[1343]; inh = 0;  }
void L02510() { lac += core[000060];  }
void D02511() { core[(ib<<12)+core[95]] = 02512; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void I02512() { lac += core[000057];  }
void D02513() { npc = 002506; inh = 0;  }
void S02514() { lac &= (010000|core[000000]);  }
void D02515() { core[(ib<<12)+core[73]] = 02516; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void D02516() { lac += core[000141];  }
void D02517() { skp = 0; skp = !skp; npc += skp;  }
void D02520() { npc = 002526; inh = 0;  }
void I02521() { lac += core[000127];  }
void D02522() { if (++core[002514] == 010000) { core[002514] = 0; npc++; }; code[002514] = &emul8;  }
void D02523() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void D02524() { npc = (ib<<12)+core[1356]; inh = 0;  }
void I02525() { if (++core[002514] == 010000) { core[002514] = 0; npc++; }; code[002514] = &emul8;  }
void L02526() { core[(ib<<12)+core[70]] = 02527; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I02527() { npc = (ib<<12)+core[1356]; inh = 0;  }
void D02600() { lac &= (010000|core[000000]);  }
void D02601() { lac &= (010000|core[000000]);  }
void D02602() { emul8();  }
void L02603() { core[002600] = lac & 07777; lac &= 010000; code[002600] = &emul8;  }
void I02604() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I02605() { core[002601] = lac & 07777; lac &= 010000; code[002601] = &emul8;  }
void I02606() { emul8();  }
void I02607() { npc = 002625; inh = 0;  }
void I02610() { emul8();  }
void I02611() { lac &= (010000|core[000026]);  }
void I02612() { lac += core[000015];  }
void I02613() { core[002706] = lac & 07777; lac &= 010000; code[002706] = &emul8;  }
void I02614() { lac += core[002706];  }
void I02615() { lac += core[002602];  }
void I02616() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02617() { npc = 002745; inh = 0;  }
void I02620() { lac += core[002664];  }
void I02621() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02622() { core[(ib<<12)+core[86]] = 02623; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I02623() { lac += core[002706];  }
void I02624() { core[002664] = lac & 07777; lac &= 010000; code[002664] = &emul8;  }
void L02625() { emul8();  }
void I02626() { npc = 002644; inh = 0;  }
void D02627() { emul8();  }
void I02630() { core[002660] = lac & 07777; lac &= 010000; code[002660] = &emul8;  }
void D02631() { lac += core[(df<<12)+core[1459]];  }
void I02632() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02633() { npc = 002644; inh = 0;  }
void D02634() { emul8();  }
void I02635() { core[002660] = lac & 07777; lac &= 010000; code[002660] = &emul8;  }
void I02636() { core[(df<<12)+core[1459]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1459]] = &emul8;  }
void I02637() { lac += core[002663];  }
void I02640() { lac++;  }
void I02641() { lac &= (010000|core[000031]);  }
void I02642() { lac += core[002661];  }
void I02643() { core[002663] = lac & 07777; lac &= 010000; code[002663] = &emul8;  }
void L02644() { emul8();  }
void I02645() { emul8();  }
void I02646() {  }
void I02647() { emul8();  }
void I02650() { npc = 002653; inh = 0;  }
void I02651() { emul8();  }
void I02652() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void L02653() { lac += core[002601];  }
void I02654() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I02655() { lac += core[002600];  }
void I02656() { emul8();  }
void I02657() { npc = (ib<<12)+core[0]; inh = 0;  }
void D02660() { lac &= (010000|core[000001]);  }
void D02661() { core[(df<<12)+core[0]] = lac & 07777; lac &= 010000; code[(df<<12)+core[0]] = &emul8;  }
void P02662() { core[(df<<12)+core[0]] = lac & 07777; lac &= 010000; code[(df<<12)+core[0]] = &emul8;  }
void P02663() { core[(df<<12)+core[0]] = lac & 07777; lac &= 010000; code[(df<<12)+core[0]] = &emul8;  }
void D02664() { lac &= (010000|core[000000]);  }
void S02665() { lac &= (010000|core[000000]);  }
void L02666() { lac += core[002664];  }
void I02667() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I02670() { npc = 002666; inh = 0;  }
void I02671() { core[002675] = lac & 07777; lac &= 010000; code[002675] = &emul8;  }
void I02672() { core[002664] = lac & 07777; lac &= 010000; code[002664] = &emul8;  }
void I02673() { lac += core[002675];  }
void I02674() { npc = (ib<<12)+core[1461]; inh = 0;  }
void S02675() { lac &= (010000|core[000000]);  }
void I02676() { core[002665] = lac & 07777; lac &= 010000; code[002665] = &emul8;  }
void I02677() { lac += core[002665];  }
void I02700() { lac += core[000065];  }
void I02701() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D02702() { core[000053] = lac & 07777; lac &= 010000; code[000053] = &emul8;  }
void I02703() { lac += core[002665];  }
void I02704() { core[(ib<<12)+core[1498]] = 02705; npc = (ib<<12)+core[1498]+1; code[(ib<<12)+core[1498]] = &emul8; inh = 0;  }
void I02705() { if (++core[000053] == 010000) { core[000053] = 0; npc++; }; code[000053] = &emul8;  }
void D02706() { lac &= (010000|core[000000]);  }
void I02707() { emul8();  }
void L02710() { lac += core[(df<<12)+core[1458]];  }
void I02711() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02712() { npc = 002710; inh = 0;  }
void I02713() { lac += core[002660];  }
void I02714() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I02715() { npc = 002722; inh = 0;  }
void I02716() { lac += core[002665];  }
void D02717() { emul8();  }
void I02720() { core[002660] = lac & 07777; lac &= 010000; code[002660] = &emul8;  }
void I02721() { npc = (ib<<12)+core[1469]; inh = 0;  }
void L02722() { lac += core[002665];  }
void I02723() { core[(df<<12)+core[1458]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1458]] = &emul8;  }
void I02724() { lac += core[002662];  }
void I02725() { lac++;  }
void I02726() { lac &= (010000|core[000031]);  }
void I02727() { lac += core[002661];  }
void I02730() { core[002662] = lac & 07777; lac &= 010000; code[002662] = &emul8;  }
void I02731() { npc = (ib<<12)+core[1469]; inh = 0;  }
void P02732() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void P02733() { core[002625] = lac & 07777; lac &= 010000; code[002625] = &emul8;  }
void P02734() { core[002603] = lac & 07777; lac &= 010000; code[002603] = &emul8;  }
void I02735() { core[002736] = lac & 07777; lac &= 010000; code[002736] = &emul8;  }
void D02736() { lac &= (010000|core[000000]);  }
void I02737() { lac &= 010000; lac ^= 07777;  }
void I02740() { lac += core[002736];  }
void I02741() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void I02742() { core[(ib<<12)+core[1499]] = 02743; npc = (ib<<12)+core[1499]+1; code[(ib<<12)+core[1499]] = &emul8; inh = 0;  }
void I02743() { emul8();  }
void I02744() { npc = 002747; inh = 0;  }
void L02745() { lac += core[000015];  }
void I02746() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void L02747() { if (++core[002660] == 010000) { core[002660] = 0; npc++; }; code[002660] = &emul8;  }
void I02750() { lac += core[000025];  }
void I02751() { core[000132] = lac & 07777; lac &= 010000; code[000132] = &emul8;  }
void I02752() { lac ^= 07777;  }
void I02753() { lac += core[002661];  }
void I02754() { core[000011] = lac & 07777; lac &= 010000; code[000011] = &emul8;  }
void L02755() { if (++core[000011] == 010000) core[000011] = 0000;core[(df<<12)+core[000011]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000011]] = &emul8;  }
void I02756() { if (++core[000132] == 010000) { core[000132] = 0; npc++; }; code[000132] = &emul8;  }
void I02757() { npc = 002755; inh = 0;  }
void I02760() { core[002664] = lac & 07777; lac &= 010000; code[002664] = &emul8;  }
void I02761() { lac += core[002661];  }
void I02762() { core[002663] = lac & 07777; lac &= 010000; code[002663] = &emul8;  }
void I02763() { lac += core[002661];  }
void I02764() { core[002662] = lac & 07777; lac &= 010000; code[002662] = &emul8;  }
void I02765() { core[(ib<<12)+core[1500]] = 02766; npc = (ib<<12)+core[1500]+1; code[(ib<<12)+core[1500]] = &emul8; inh = 0;  }
void I02766() { lac += core[000161];  }
void I02767() { core[000113] = lac & 07777; lac &= 010000; code[000113] = &emul8;  }
void I02770() { lac ^= 07777;  }
void I02771() { emul8();  }
void I02772() { lac &= 010000;  }
void I02773() { lac += core[000060];  }
void I02774() { core[(ib<<12)+core[74]] = 02775; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I02775() { lac += core[000032];  }
void I02776() { core[(ib<<12)+core[74]] = 02777; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I02777() { core[(ib<<12)+core[76]] = 03000; npc = (ib<<12)+core[76]+1; code[(ib<<12)+core[76]] = &emul8; inh = 0;  }
void I03000() { if (++core[000145] == 010000) { core[000145] = 0; npc++; }; code[000145] = &emul8;  }
void I03001() { lac += core[(df<<12)+core[101]];  }
void I03002() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I03003() { npc = 003011; inh = 0;  }
void I03004() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void I03005() { lac += core[000062];  }
void I03006() { core[(ib<<12)+core[74]] = 03007; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I03007() { core[(ib<<12)+core[74]] = 03010; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I03010() { core[(ib<<12)+core[76]] = 03011; npc = (ib<<12)+core[76]+1; code[(ib<<12)+core[76]] = &emul8; inh = 0;  }
void L03011() { lac += core[000060];  }
void D03012() { core[(ib<<12)+core[74]] = 03013; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I03013() { npc = 000177; inh = 0;  }
void S03014() { lac &= (010000|core[000000]);  }
void I03015() { core[(ib<<12)+core[80]] = 03016; npc = (ib<<12)+core[80]+1; code[(ib<<12)+core[80]] = &emul8; inh = 0;  }
void I03016() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I03017() { lac ^= 010000;  }
void I03020() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03021() { if (++core[003014] == 010000) { core[003014] = 0; npc++; }; code[003014] = &emul8;  }
void I03022() { npc = (ib<<12)+core[1548]; inh = 0;  }
void S03023() { lac &= (010000|core[000000]);  }
void I03024() { core[(ib<<12)+core[72]] = 03025; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I03025() { core[000055] = lac & 07777; lac &= 010000; code[000055] = &emul8;  }
void I03026() { emul8();  }
void I03027() { lac += core[000142];  }
void I03030() { core[003014] = 03031; npc = 003014+1; code[003014] = &emul8; inh = 0;  }
void I03031() { npc = 003034; inh = 0;  }
void I03032() { lac += core[000071];  }
void I03033() { core[003042] = 03034; npc = 003042+1; code[003042] = &emul8; inh = 0;  }
void L03034() { lac += core[000142];  }
void L03035() { lac &= (010000|core[000071]);  }
void I03036() { core[003042] = 03037; npc = 003042+1; code[003042] = &emul8; inh = 0;  }
void I03037() { npc = (ib<<12)+core[1555]; inh = 0;  }
void I03040() { lac += core[000054];  }
void D03041() { npc = 003035; inh = 0;  }
void S03042() { lac &= (010000|core[000000]);  }
void I03043() { if (++core[000136] == 010000) { core[000136] = 0; npc++; }; code[000136] = &emul8;  }
void I03044() { npc = 003060; inh = 0;  }
void I03045() { lac += core[000135];  }
void I03046() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I03047() { lac += core[000013];  }
void I03050() { lac &= 07777; lac ^= 07777; lac++;  }
void I03051() { lac += core[000005];  }
void D03052() { lac += core[000010];  }
void I03053() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I03054() { core[(ib<<12)+core[86]] = 03055; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I03055() { npc = (ib<<12)+core[1570]; inh = 0;  }
void I03056() { lac &= (010000|core[003077]);  }
void I03057() { lac &= (010000|core[003177]);  }
void L03060() { core[(ib<<12)+core[80]] = 03061; npc = (ib<<12)+core[80]+1; code[(ib<<12)+core[80]] = &emul8; inh = 0;  }
void I03061() { core[000135] = lac & 07777; lac &= 010000; code[000135] = &emul8;  }
void I03062() { lac ^= 07777;  }
void I03063() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03064() { npc = (ib<<12)+core[1570]; inh = 0;  }
void I03065() { lac += core[000010];  }
void I03066() { core[003042] = lac & 07777; lac &= 010000; code[003042] = &emul8;  }
void I03067() { lac += core[000136];  }
void I03070() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03071() { npc = 003077; inh = 0;  }
void I03072() { lac += core[000010];  }
void I03073() { lac ^= 07777; lac++;  }
void I03074() { lac += core[000153];  }
void I03075() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I03076() { npc = 003122; inh = 0;  }
void L03077() { lac += core[003124];  }
void I03100() { core[(ib<<12)+core[74]] = 03101; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I03101() { if (++core[000136] == 010000) { core[000136] = 0; npc++; }; code[000136] = &emul8;  }
void I03102() { npc = 003110; inh = 0;  }
void I03103() { lac += core[(df<<12)+core[1570]];  }
void I03104() { lac &= (010000|core[000071]);  }
void I03105() { lac += core[000023];  }
void I03106() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03107() { npc = 003122; inh = 0;  }
void L03110() { lac += core[(df<<12)+core[1570]];  }
void I03111() { lac &= (010000|core[000062]);  }
void I03112() { core[000135] = lac & 07777; lac &= 010000; code[000135] = &emul8;  }
void I03113() { lac ^= 07777;  }
void I03114() { lac += core[000010];  }
void I03115() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I03116() { lac += core[000135];  }
void I03117() { lac += core[000006];  }
void I03120() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03121() { lac ^= 07777;  }
void L03122() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03123() { npc = (ib<<12)+core[1555]; inh = 0;  }
void D03124() { lac &= (010000|core[003134]);  }
void I03125() { core[(ib<<12)+core[68]] = 03126; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I03126() { lac &= (010000|core[000017]);  }
void I03127() { lac ^= 07777;  }
void I03130() { lac += core[000134];  }
void L03131() { core[000014] = lac & 07777; lac &= 010000; code[000014] = &emul8;  }
void I03132() { lac += core[000014];  }
void I03133() { lac ^= 07777;  }
void D03134() { lac += core[000155];  }
void I03135() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I03136() { npc = 003170; inh = 0;  }
void I03137() { lac += core[003175];  }
void I03140() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I03141() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I03142() { if (++core[000014] == 010000) core[000014] = 0000;lac += core[(df<<12)+core[000014]];  }
void I03143() { core[003176] = lac & 07777; lac &= 010000; code[003176] = &emul8;  }
void I03144() { core[(ib<<12)+core[65]] = 03145; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I03145() { lac += core[003041];  }
void I03146() { if (++core[000014] == 010000) core[000014] = 0000;lac += core[(df<<12)+core[000014]];  }
void I03147() { core[(ib<<12)+core[1660]] = 03150; npc = (ib<<12)+core[1660]+1; code[(ib<<12)+core[1660]] = &emul8; inh = 0;  }
void I03150() { core[(ib<<12)+core[65]] = 03151; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I03151() { lac += core[003041];  }
void I03152() { lac += core[000005];  }
void D03153() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I03154() { core[(ib<<12)+core[65]] = 03155; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void D03155() { lac += core[003174];  }
void I03156() { if (++core[000014] == 010000) { core[000014] = 0; npc++; }; code[000014] = &emul8;  }
void I03157() { core[(ib<<12)+core[7]] = 03160; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I03160() { &emul8;  }
void I03161() { &emul8;  }
void I03162() { core[(ib<<12)+core[58]] = 03163; npc = (ib<<12)+core[58]+1; code[(ib<<12)+core[58]] = &emul8; inh = 0;  }
void I03163() { lac += core[000060];  }
void L03164() { core[(ib<<12)+core[74]] = 03165; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I03165() { lac += core[000014];  }
void I03166() { lac += core[000035];  }
void I03167() { npc = 003131; inh = 0;  }
void L03170() { core[(ib<<12)+core[69]] = 03171; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I03171() { lac &= (010000|core[000017]);  }
void I03172() { npc = (ib<<12)+core[1659]; inh = 0;  }
void P03173() { lac += core[003052];  }
void P03174() { emul8();  }
void D03175() { core[000175] = lac & 07777; lac &= 010000; code[000175] = &emul8;  }
void D03176() { lac &= (010000|core[000000]);  }
void D03177() { npc = 000077; inh = 0;  }
void P03200() { lac += core[(df<<12)+core[105]];  }
void P03201() { emul8();  }
void I03202() { lac += core[(df<<12)+core[64]];  }
void S03203() { lac &= (010000|core[000000]);  }
void I03204() { lac += core[003220];  }
void I03205() { core[(df<<12)+core[1681]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1681]] = &emul8;  }
void I03206() { lac += core[(df<<12)+core[1681]];  }
void I03207() { lac++;  }
void I03210() { core[(df<<12)+core[1682]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1682]] = &emul8;  }
void I03211() { lac += core[(df<<12)+core[1682]];  }
void I03212() { lac += core[000035];  }
void I03213() { core[(df<<12)+core[1683]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1683]] = &emul8;  }
void I03214() { lac += core[(df<<12)+core[1683]];  }
void I03215() { lac += core[000035];  }
void I03216() { core[(df<<12)+core[1684]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1684]] = &emul8;  }
void I03217() { npc = (ib<<12)+core[1667]; inh = 0;  }
void D03220() { emul8();  }
void P03221() { if (++core[(df<<12)+core[1685]] == 010000) { core[(df<<12)+core[1685]] = 0; npc++; }; code[(df<<12)+core[1685]] = &emul8;  }
void P03222() { if (++core[(df<<12)+core[1687]] == 010000) { core[(df<<12)+core[1687]] = 0; npc++; }; code[(df<<12)+core[1687]] = &emul8;  }
void P03223() { if (++core[(df<<12)+core[1692]] == 010000) { core[(df<<12)+core[1692]] = 0; npc++; }; code[(df<<12)+core[1692]] = &emul8;  }
void P03224() { if (++core[(df<<12)+core[1743]] == 010000) { core[(df<<12)+core[1743]] = 0; npc++; }; code[(df<<12)+core[1743]] = &emul8;  }
void S03225() { lac &= (010000|core[000000]);  }
void L03226() { emul8();  }
void P03227() { lac += core[(df<<12)+core[1691]];  }
void I03230() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03231() { npc = 003226; inh = 0;  }
void I03232() { npc = (ib<<12)+core[1685]; inh = 0;  }
void P03233() { if (++core[(df<<12)+core[1712]] == 010000) { core[(df<<12)+core[1712]] = 0; npc++; }; code[(df<<12)+core[1712]] = &emul8;  }
void P03234() { core[003225] = 03235; npc = 003225+1; code[003225] = &emul8; inh = 0;  }
void I03235() { lac += core[000025];  }
void I03236() { skp = 0; skp = !skp; npc += skp;  }
void I03237() { core[003225] = 03240; npc = 003225+1; code[003225] = &emul8; inh = 0;  }
void I03240() { core[003203] = 03241; npc = 003203+1; code[003203] = &emul8; inh = 0;  }
void L03241() { npc = (ib<<12)+core[1698]; inh = 0;  }
void P03242() { emul8();  }
void I03243() { lac += core[003250];  }
void I03244() { lac += core[003247];  }
void I03245() { core[(df<<12)+core[1705]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1705]] = &emul8;  }
void I03246() { npc = 003241; inh = 0;  }
void D03247() { core[(ib<<12)+core[74]] = 03250; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void D03250() { if (++core[(df<<12)+core[54]] == 010000) { core[(df<<12)+core[54]] = 0; npc++; }; code[(df<<12)+core[54]] = &emul8;  }
void P03251() { lac += core[003222];  }
void I03252() { lac += core[003247];  }
void I03253() { core[(df<<12)+core[1709]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1709]] = &emul8;  }
void I03254() { npc = 003241; inh = 0;  }
void P03255() { if (++core[(df<<12)+core[57]] == 010000) { core[(df<<12)+core[57]] = 0; npc++; }; code[(df<<12)+core[57]] = &emul8;  }
void L03256() { core[(ib<<12)+core[70]] = 03257; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I03257() { core[(ib<<12)+core[73]] = 03260; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void P03260() { if (++core[000003] == 010000) { core[000003] = 0; npc++; }; code[000003] = &emul8;  }
void I03261() { skp = 0; skp = !skp; npc += skp;  }
void I03262() { npc = 003256; inh = 0;  }
void I03263() { core[(ib<<12)+core[65]] = 03264; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I03264() { lac += core[(df<<12)+core[1665]];  }
void I03265() { core[(ib<<12)+core[42]] = 03266; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I03266() { core[(df<<12)+core[1720]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1720]] = &emul8;  }
void I03267() { npc = 003241; inh = 0;  }
void P03270() { emul8();  }
void I03271() { core[003225] = 03272; npc = 003225+1; code[003225] = &emul8; inh = 0;  }
void I03272() { emul8();  }
void I03273() { npc = (ib<<12)+core[20]; inh = 0;  }
void I03274() { lac += core[003301];  }
void I03275() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I03276() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I03277() { core[(ib<<12)+core[65]] = 03300; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I03300() { lac += core[003260];  }
void D03301() { if (++core[000036] == 010000) { core[000036] = 0; npc++; }; code[000036] = &emul8;  }
void I03302() { lac &= 010000; lac ^= 07777;  }
void I03303() { core[003305] = lac & 07777; lac &= 010000; code[003305] = &emul8;  }
void I03304() { npc = 003241; inh = 0;  }
void D03305() { lac &= (010000|core[000000]);  }
void S03306() { lac &= (010000|core[000000]);  }
void I03307() { lac += core[000154];  }
void I03310() { core[003225] = lac & 07777; lac &= 010000; code[003225] = &emul8;  }
void I03311() { lac += core[003305];  }
void I03312() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I03313() { npc = 003323; inh = 0;  }
void I03314() { core[(ib<<12)+core[75]] = 03315; npc = (ib<<12)+core[75]+1; code[(ib<<12)+core[75]] = &emul8; inh = 0;  }
void I03315() { lac += core[000142];  }
void I03316() { core[(ib<<12)+core[24]] = 03317; npc = (ib<<12)+core[24]+1; code[(ib<<12)+core[24]] = &emul8; inh = 0;  }
void P03317() { core[(ib<<12)+core[7]] = 03320; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I03320() { &emul8;  }
void I03321() { &emul8;  }
void I03322() { npc = (ib<<12)+core[1734]; inh = 0;  }
void L03323() { lac += core[000013];  }
void I03324() { core[003203] = lac & 07777; lac &= 010000; code[003203] = &emul8;  }
void I03325() { lac += core[003364];  }
void I03326() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I03327() { if (++core[000151] == 010000) { core[000151] = 0; npc++; }; code[000151] = &emul8;  }
void I03330() { lac += core[003363];  }
void I03331() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I03332() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03333() { lac += core[003363];  }
void I03334() { core[000153] = lac & 07777; lac &= 010000; code[000153] = &emul8;  }
void L03335() { core[(ib<<12)+core[75]] = 03336; npc = (ib<<12)+core[75]+1; code[(ib<<12)+core[75]] = &emul8; inh = 0;  }
void I03336() { core[(ib<<12)+core[73]] = 03337; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I03337() { lac &= (010000|core[000032]);  }
void I03340() { npc = 003335; inh = 0;  }
void L03341() { core[(ib<<12)+core[72]] = 03342; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I03342() { npc = (ib<<12)+core[1789]; inh = 0;  }
void I03343() { lac &= (010000|core[(df<<12)+core[1788]]);  }
void I03344() { core[(ib<<12)+core[71]] = 03345; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I03345() { core[(ib<<12)+core[75]] = 03346; npc = (ib<<12)+core[75]+1; code[(ib<<12)+core[75]] = &emul8; inh = 0;  }
void I03346() { npc = 003341; inh = 0;  }
void I03347() { lac += core[000060];  }
void I03350() { core[000142] = lac & 07777; lac &= 010000; code[000142] = &emul8;  }
void I03351() { core[(ib<<12)+core[71]] = 03352; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I03352() { core[(ib<<12)+core[71]] = 03353; npc = (ib<<12)+core[71]+1; code[(ib<<12)+core[71]] = &emul8; inh = 0;  }
void I03353() { lac += core[003203];  }
void I03354() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I03355() { lac += core[003363];  }
void I03356() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I03357() { core[000020] = lac & 07777; lac &= 010000; code[000020] = &emul8;  }
void I03360() { core[(ib<<12)+core[65]] = 03361; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I03361() { lac += core[(df<<12)+core[1664]];  }
void I03362() { npc = 003317; inh = 0;  }
void D03363() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void D03364() { skp = 0; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void S03365() { lac &= (010000|core[000000]);  }
void I03366() { lac += core[003305];  }
void I03367() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03370() { npc = 003373; inh = 0;  }
void I03371() { core[(ib<<12)+core[58]] = 03372; npc = (ib<<12)+core[58]+1; code[(ib<<12)+core[58]] = &emul8; inh = 0;  }
void I03372() { npc = (ib<<12)+core[1781]; inh = 0;  }
void L03373() { core[(ib<<12)+core[42]] = 03374; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void P03374() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void P03375() { lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03376() { core[(ib<<12)+core[95]] = 03377; npc = (ib<<12)+core[95]+1; code[(ib<<12)+core[95]] = &emul8; inh = 0;  }
void D03377() { npc = (ib<<12)+core[1781]; inh = 0;  }
void D03420() { lac &= (010000|core[000000]);  }
void I03421() { lac &= (010000|core[000000]);  }
void I03422() { lac &= (010000|core[003555]);  }
void I03423() { lac &= (010000|core[(df<<12)+core[1807]]);  }
void I03424() { lac &= (010000|core[003501]);  }
void I03425() { lac += core[(df<<12)+core[44]];  }
void I03426() { core[000040] = 03427; npc = 000040+1; code[000040] = &emul8; inh = 0;  }
void I03427() { emul8();  }
void D03430() { emul8();  }
void I03431() { emul8();  }
void L03432() { lac &= 010000; lac &= 07777;  }
void I03433() { lac += core[003577];  }
void I03434() { core[000176] = lac & 07777; lac &= 010000; code[000176] = &emul8;  }
void I03435() { emul8();  }
void I03436() { emul8();  }
void I03437() { emul8();  }
void I03440() { emul8();  }
void P03441() { emul8();  }
void I03442() { emul8();  }
void I03443() { emul8();  }
void I03444() { emul8();  }
void I03445() { emul8();  }
void I03446() { emul8();  }
void I03447() { emul8();  }
void I03450() { emul8();  }
void I03451() { emul8();  }
void I03452() { emul8();  }
void I03453() { lac &= 010000;  }
void I03454() { emul8();  }
void L03455() { if (++core[000014] == 010000) core[000014] = 0000;core[(df<<12)+core[000014]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000014]] = &emul8;  }
void I03456() { if (++core[003576] == 010000) { core[003576] = 0; npc++; }; code[003576] = &emul8;  }
void I03457() { npc = 003455; inh = 0;  }
void I03460() { lac += core[000027];  }
void I03461() { core[000013] = lac & 07777; lac &= 010000; code[000013] = &emul8;  }
void I03462() { emul8();  }
void I03463() { core[(ib<<12)+core[74]] = 03464; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I03464() { core[(ib<<12)+core[74]] = 03465; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I03465() { core[(ib<<12)+core[74]] = 03466; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I03466() { core[(ib<<12)+core[65]] = 03467; npc = (ib<<12)+core[65]+1; code[(ib<<12)+core[65]] = &emul8; inh = 0;  }
void I03467() { lac &= (010000|core[(df<<12)+core[1825]]);  }
void I03470() { npc = (ib<<12)+core[1849]; inh = 0;  }
void P03471() { if (++core[003432] == 010000) { core[003432] = 0; npc++; }; code[003432] = &emul8;  }
void D03576() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void D03577() { if (++core[(df<<12)+core[1894]] == 010000) { core[(df<<12)+core[1894]] = 0; npc++; }; code[(df<<12)+core[1894]] = &emul8;  }
void S05600() { lac &= (010000|core[000000]);  }
void I05601() { core[(ib<<12)+core[24]] = 05602; npc = (ib<<12)+core[24]+1; code[(ib<<12)+core[24]] = &emul8; inh = 0;  }
void I05602() { core[005764] = lac & 07777; lac &= 010000; code[005764] = &emul8;  }
void I05603() { lac ^= 07777;  }
void I05604() { core[005660] = lac & 07777; lac &= 010000; code[005660] = &emul8;  }
void I05605() { lac += core[005763];  }
void I05606() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I05607() { core[(ib<<12)+core[3053]] = 05610; npc = (ib<<12)+core[3053]+1; code[(ib<<12)+core[3053]] = &emul8; inh = 0;  }
void I05610() { core[005765] = lac & 07777; lac &= 010000; code[005765] = &emul8;  }
void I05611() { npc = 005615; inh = 0;  }
void L05612() { if (++core[005660] == 010000) { core[005660] = 0; npc++; }; code[005660] = &emul8;  }
void I05613() { core[(ib<<12)+core[86]] = 05614; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void L05614() { core[(ib<<12)+core[70]] = 05615; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void L05615() { core[(ib<<12)+core[82]] = 05616; npc = (ib<<12)+core[82]+1; code[(ib<<12)+core[82]] = &emul8; inh = 0;  }
void I05616() { npc = 005612; inh = 0;  }
void I05617() { npc = 005650; inh = 0;  }
void I05620() { lac += core[005660];  }
void I05621() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I05622() { lac ^= 07777;  }
void I05623() { lac += core[005764];  }
void I05624() { core[005764] = lac & 07777; lac &= 010000; code[005764] = &emul8;  }
void I05625() { core[005742] = 05626; npc = 005742+1; code[005742] = &emul8; inh = 0;  }
void I05626() { lac += core[000127];  }
void I05627() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I05630() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I05631() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I05632() { core[005713] = 05633; npc = 005713+1; code[005713] = &emul8; inh = 0;  }
void P05633() { lac += core[000162];  }
void I05634() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05635() { npc = 005641; inh = 0;  }
void I05636() { lac += core[000045];  }
void I05637() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I05640() { npc = 005614; inh = 0;  }
void L05641() { lac += core[005761];  }
void I05642() { core[(df<<12)+core[3056]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3056]] = &emul8;  }
void I05643() { lac += core[000162];  }
void I05644() { lac &= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I05645() { core[000162] = lac & 07777; lac &= 010000; code[000162] = &emul8;  }
void I05646() { lac += core[000045];  }
void I05647() { npc = (ib<<12)+core[3058]; inh = 0;  }
void L05650() { core[(ib<<12)+core[73]] = 05651; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I05651() { emul8();  }
void I05652() { npc = 005701; inh = 0;  }
void L05653() { if (++core[005765] == 010000) { core[005765] = 0; npc++; }; code[005765] = &emul8;  }
void I05654() { core[(ib<<12)+core[40]] = 05655; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I05655() { lac += core[005766];  }
void L05656() { core[005660] = lac & 07777; lac &= 010000; code[005660] = &emul8;  }
void I05657() { core[(ib<<12)+core[7]] = 05660; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void D05660() { &emul8;  }
void I05661() { &emul8;  }
void I05662() { &emul8;  }
void I05663() { lac += core[005764];  }
void I05664() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I05665() { npc = (ib<<12)+core[2944]; inh = 0;  }
void I05666() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I05667() { npc = 005673; inh = 0;  }
void I05670() { lac++;  }
void I05671() { core[005764] = lac & 07777; lac &= 010000; code[005764] = &emul8;  }
void I05672() { npc = 005677; inh = 0;  }
void L05673() { lac &= 010000; lac ^= 07777;  }
void I05674() { lac += core[005764];  }
void I05675() { core[005764] = lac & 07777; lac &= 010000; code[005764] = &emul8;  }
void I05676() { lac += core[000066];  }
void L05677() { lac += core[005767];  }
void I05700() { npc = 005656; inh = 0;  }
void L05701() { core[(ib<<12)+core[70]] = 05702; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I05702() { core[(ib<<12)+core[3053]] = 05703; npc = (ib<<12)+core[3053]+1; code[(ib<<12)+core[3053]] = &emul8; inh = 0;  }
void D05703() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I05704() { core[(ib<<12)+core[3055]] = 05705; npc = (ib<<12)+core[3055]+1; code[(ib<<12)+core[3055]] = &emul8; inh = 0;  }
void I05705() { lac += core[000164];  }
void I05706() { if (++core[000040] == 010000) { core[000040] = 0; npc++; }; code[000040] = &emul8;  }
void I05707() { lac ^= 07777; lac++;  }
void I05710() { lac += core[005764];  }
void I05711() { core[005764] = lac & 07777; lac &= 010000; code[005764] = &emul8;  }
void I05712() { npc = 005653; inh = 0;  }
void S05713() { lac &= (010000|core[000000]);  }
void I05714() { lac &= 010000; lac &= 07777;  }
void I05715() { lac += core[000043];  }
void I05716() { lac += core[000047];  }
void I05717() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I05720() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05721() { lac += core[000042];  }
void I05722() { lac += core[000046];  }
void I05723() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I05724() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05725() { lac += core[000041];  }
void I05726() { lac += core[000045];  }
void I05727() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I05730() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05731() { lac += core[000162];  }
void I05732() { core[000162] = lac & 07777; lac &= 010000; code[000162] = &emul8;  }
void D05733() { npc = (ib<<12)+core[3019]; inh = 0;  }
void S05734() { lac &= (010000|core[000000]);  }
void I05735() { core[(ib<<12)+core[3054]] = 05736; npc = (ib<<12)+core[3054]+1; code[(ib<<12)+core[3054]] = &emul8; inh = 0;  }
void I05736() { lac += core[000162];  }
void I05737() { lac = (lac<<1) + ((lac>>12)&1);  }
void I05740() { core[000162] = lac & 07777; lac &= 010000; code[000162] = &emul8;  }
void I05741() { npc = (ib<<12)+core[3036]; inh = 0;  }
void S05742() { lac &= (010000|core[000000]);  }
void I05743() { core[(ib<<12)+core[68]] = 05744; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I05744() { lac &= (010000|core[000045]);  }
void I05745() { core[(ib<<12)+core[69]] = 05746; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I05746() { lac &= (010000|core[000041]);  }
void I05747() { core[000162] = lac & 07777; lac &= 010000; code[000162] = &emul8;  }
void I05750() { core[005734] = 05751; npc = 005734+1; code[005734] = &emul8; inh = 0;  }
void I05751() { core[005734] = 05752; npc = 005734+1; code[005734] = &emul8; inh = 0;  }
void I05752() { core[005713] = 05753; npc = 005713+1; code[005713] = &emul8; inh = 0;  }
void I05753() { core[005734] = 05754; npc = 005734+1; code[005734] = &emul8; inh = 0;  }
void I05754() { npc = (ib<<12)+core[3042]; inh = 0;  }
void P05755() { emul8();  }
void P05756() { lac ^= 010000; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void P05757() { emul8();  }
void P05760() { lac &= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void D05761() { npc = (ib<<12)+core[2971]; inh = 0;  }
void P05762() { lac &= 010000; lac ^= 07777; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D05763() { lac &= (010000|core[000043]);  }
void D05764() { lac &= (010000|core[000000]);  }
void D05765() { lac &= (010000|core[000000]);  }
void D05766() {  }
void D05767() { core[005773] = lac & 07777; lac &= 010000; code[005773] = &emul8;  }
void D05770() { lac &= (010000|core[000004]);  }
void I05771() { if (++core[(df<<12)+core[0]] == 010000) { core[(df<<12)+core[0]] = 0; npc++; }; code[(df<<12)+core[0]] = &emul8;  }
void I05772() { lac &= (010000|core[000000]);  }
void D05773() { emul8();  }
void I05774() { core[000146] = lac & 07777; lac &= 010000; code[000146] = &emul8;  }
void I05775() { core[000147] = lac & 07777; lac &= 010000; code[000147] = &emul8;  }
void I05776() { lac &= (010000|core[005615]);  }
void I05777() { lac &= (010000|core[005614]);  }
void I06000() { lac &= (010000|core[006137]);  }
void I06001() { lac &= (010000|core[006054]);  }
void D06002() { lac &= (010000|core[000000]);  }
void I06003() { lac &= (010000|core[006012]);  }
void D06004() { emul8();  }
void I06005() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I06006() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I06007() { emul8();  }
void S06010() { lac &= (010000|core[000000]);  }
void L06011() { core[000164] = lac & 07777; lac &= 010000; code[000164] = &emul8;  }
void D06012() { core[(ib<<12)+core[82]] = 06013; npc = (ib<<12)+core[82]+1; code[(ib<<12)+core[82]] = &emul8; inh = 0;  }
void I06013() {  }
void I06014() { npc = (ib<<12)+core[3080]; inh = 0;  }
void I06015() { core[(ib<<12)+core[70]] = 06016; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I06016() { lac += core[000164];  }
void I06017() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I06020() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I06021() { npc = 006026; inh = 0;  }
void I06022() { lac += core[000164];  }
void I06023() { lac = (lac<<1) + ((lac>>12)&1);  }
void I06024() { lac += core[000127];  }
void I06025() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void L06026() { core[(ib<<12)+core[86]] = 06027; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I06027() { npc = 006011; inh = 0;  }
void S06030() { lac &= (010000|core[000000]);  }
void I06031() { core[(ib<<12)+core[81]] = 06032; npc = (ib<<12)+core[81]+1; code[(ib<<12)+core[81]] = &emul8; inh = 0;  }
void I06032() { core[000127] = lac & 07777; lac &= 010000; code[000127] = &emul8;  }
void I06033() { core[(ib<<12)+core[73]] = 06034; npc = (ib<<12)+core[73]+1; code[(ib<<12)+core[73]] = &emul8; inh = 0;  }
void I06034() { emul8();  }
void I06035() { core[(ib<<12)+core[70]] = 06036; npc = (ib<<12)+core[70]+1; code[(ib<<12)+core[70]] = &emul8; inh = 0;  }
void I06036() { core[(ib<<12)+core[81]] = 06037; npc = (ib<<12)+core[81]+1; code[(ib<<12)+core[81]] = &emul8; inh = 0;  }
void I06037() { lac &= 010000; lac ^= 07777;  }
void I06040() { lac += core[000127];  }
void I06041() { npc = (ib<<12)+core[3096]; inh = 0;  }
void S06042() { lac &= (010000|core[000000]);  }
void I06043() { core[000164] = lac & 07777; lac &= 010000; code[000164] = &emul8;  }
void I06044() { lac += core[006114];  }
void I06045() { core[006060] = lac & 07777; lac &= 010000; code[006060] = &emul8;  }
void I06046() { core[006010] = lac & 07777; lac &= 010000; code[006010] = &emul8;  }
void I06047() { core[006055] = 06050; npc = 006055+1; code[006055] = &emul8; inh = 0;  }
void I06050() { core[006055] = 06051; npc = 006055+1; code[006055] = &emul8; inh = 0;  }
void I06051() { if (++core[006010] == 010000) { core[006010] = 0; npc++; }; code[006010] = &emul8;  }
void I06052() { core[006055] = 06053; npc = 006055+1; code[006055] = &emul8; inh = 0;  }
void D06053() { core[006055] = 06054; npc = 006055+1; code[006055] = &emul8; inh = 0;  }
void D06054() { npc = (ib<<12)+core[3106]; inh = 0;  }
void S06055() { lac &= (010000|core[000000]);  }
void I06056() { core[000163] = lac & 07777; lac &= 010000; code[000163] = &emul8;  }
void L06057() { lac += core[000164];  }
void D06060() { lac += core[006004];  }
void I06061() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06062() { npc = 006067; inh = 0;  }
void I06063() { core[000164] = lac & 07777; lac &= 010000; code[000164] = &emul8;  }
void I06064() { if (++core[000163] == 010000) { core[000163] = 0; npc++; }; code[000163] = &emul8;  }
void I06065() { if (++core[006010] == 010000) { core[006010] = 0; npc++; }; code[006010] = &emul8;  }
void I06066() { npc = 006057; inh = 0;  }
void L06067() { lac &= 010000; lac &= 07777;  }
void I06070() { if (++core[006060] == 010000) { core[006060] = 0; npc++; }; code[006060] = &emul8;  }
void I06071() { lac += core[006010];  }
void I06072() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06073() { npc = (ib<<12)+core[3117]; inh = 0;  }
void I06074() { lac += core[000163];  }
void I06075() { lac += core[000036];  }
void I06076() { core[(ib<<12)+core[74]] = 06077; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I06077() { npc = (ib<<12)+core[3117]; inh = 0;  }
void S06100() { lac &= (010000|core[000000]);  }
void I06101() { core[000164] = lac & 07777; lac &= 010000; code[000164] = &emul8;  }
void I06102() { lac += core[000164];  }
void I06103() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06104() { lac += core[000035];  }
void D06105() { lac += core[006115];  }
void I06106() { core[(ib<<12)+core[74]] = 06107; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I06107() { lac += core[000164];  }
void I06110() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06111() { lac ^= 07777; lac++;  }
void I06112() { core[006042] = 06113; npc = 006042+1; code[006042] = &emul8; inh = 0;  }
void I06113() { npc = (ib<<12)+core[3136]; inh = 0;  }
void D06114() { lac += core[006004];  }
void D06115() { lac &= (010000|core[006053]);  }
void I06116() { lac &= (010000|core[006055]);  }
void L06117() { lac &= 010000;  }
void I06120() { lac += core[000051];  }
void I06121() { skp = 0; skp = !skp; npc += skp;  }
void L06122() { lac += core[000133];  }
void I06123() { lac ^= 07777; lac++;  }
void I06124() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06125() { lac += core[006147];  }
void I06126() { core[000164] = lac & 07777; lac &= 010000; code[000164] = &emul8;  }
void I06127() { lac += core[000022];  }
void I06130() { core[(ib<<12)+core[74]] = 06131; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void L06131() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I06132() { if (++core[000157] == 010000) { core[000157] = 0; npc++; }; code[000157] = &emul8;  }
void I06133() { npc = 006136; inh = 0;  }
void I06134() { lac &= 010000; lac ^= 07777;  }
void I06135() { core[000157] = lac & 07777; lac &= 010000; code[000157] = &emul8;  }
void L06136() { core[(ib<<12)+core[3176]] = 06137; npc = (ib<<12)+core[3176]+1; code[(ib<<12)+core[3176]] = &emul8; inh = 0;  }
void D06137() { skp = 0; skp = !skp; npc += skp;  }
void I06140() { npc = 006131; inh = 0;  }
void I06141() { lac += core[006146];  }
void I06142() { core[(ib<<12)+core[74]] = 06143; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I06143() { lac += core[000156];  }
void I06144() { core[006100] = 06145; npc = 006100+1; code[006100] = &emul8; inh = 0;  }
void L06145() { npc = (ib<<12)+core[3192]; inh = 0;  }
void D06146() { lac &= (010000|core[006105]);  }
void D06147() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void P06150() { emul8();  }
void S06151() { lac &= (010000|core[000000]);  }
void I06152() { lac += core[000143];  }
void I06153() { core[(ib<<12)+core[80]] = 06154; npc = (ib<<12)+core[80]+1; code[(ib<<12)+core[80]] = &emul8; inh = 0;  }
void I06154() { lac &= (010000|core[000071]);  }
void I06155() { core[006042] = 06156; npc = 006042+1; code[006042] = &emul8; inh = 0;  }
void I06156() { lac += core[000022];  }
void I06157() { core[(ib<<12)+core[74]] = 06160; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I06160() { lac += core[000143];  }
void I06161() { lac &= (010000|core[000026]);  }
void I06162() { core[006042] = 06163; npc = 006042+1; code[006042] = &emul8; inh = 0;  }
void I06163() { lac += core[000033];  }
void I06164() { core[000142] = lac & 07777; lac &= 010000; code[000142] = &emul8;  }
void I06165() { core[(ib<<12)+core[74]] = 06166; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I06166() { npc = (ib<<12)+core[3177]; inh = 0;  }
void D06167() { lac &= (010000|core[000015]);  }
void S06170() { lac &= (010000|core[000000]);  }
void I06171() { lac += core[000045];  }
void I06172() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06173() { npc = 006176; inh = 0;  }
void I06174() { core[(ib<<12)+core[40]] = 06175; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I06175() { lac += core[006167];  }
void L06176() { lac += core[000033];  }
void I06177() { core[(ib<<12)+core[74]] = 06200; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I06200() { lac &= 010000; lac ^= 07777;  }
void I06201() { lac += core[000044];  }
void I06202() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void L06203() { core[000156] = lac & 07777; lac &= 010000; code[000156] = &emul8;  }
void I06204() { lac += core[000044];  }
void I06205() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I06206() { npc = 006220; inh = 0;  }
void I06207() { lac += core[(df<<12)+core[3225]];  }
void I06210() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06211() { npc = 006244; inh = 0;  }
void I06212() { core[(ib<<12)+core[7]] = 06213; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I06213() { &emul8;  }
void I06214() { &emul8;  }
void I06215() { lac &= 010000; lac ^= 07777;  }
void L06216() { lac += core[000156];  }
void I06217() { npc = 006203; inh = 0;  }
void L06220() { core[(ib<<12)+core[7]] = 06221; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I06221() { &emul8;  }
void I06222() { &emul8;  }
void I06223() { lac++;  }
void I06224() { npc = 006216; inh = 0;  }
void D06225() { emul8();  }
void D06226() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void D06227() { lac &= (010000|core[000007]);  }
void D06230() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P06231() { npc = (ib<<12)+core[3320]; inh = 0;  }
void P06232() { npc = (ib<<12)+core[3323]; inh = 0;  }
void P06233() { npc = (ib<<12)+core[3292]; inh = 0;  }
void P06234() { npc = (ib<<12)+core[3298]; inh = 0;  }
void D06235() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac |= swr;  }
void P06236() { emul8();  }
void P06237() { emul8();  }
void L06240() { lac ^= 07777;  }
void I06241() { lac += core[000040];  }
void I06242() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I06243() { npc = 006351; inh = 0;  }
void L06244() { core[(ib<<12)+core[3227]] = 06245; npc = (ib<<12)+core[3227]+1; code[(ib<<12)+core[3227]] = &emul8; inh = 0;  }
void I06245() { lac += core[006235];  }
void I06246() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I06247() { core[(ib<<12)+core[3228]] = 06250; npc = (ib<<12)+core[3228]+1; code[(ib<<12)+core[3228]] = &emul8; inh = 0;  }
void I06250() { lac += core[000162];  }
void I06251() { npc = 006266; inh = 0;  }
void L06252() { lac &= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06253() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void I06254() { lac += core[000045];  }
void I06255() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06256() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I06257() { lac += core[000046];  }
void I06260() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06261() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06262() { lac += core[000047];  }
void I06263() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06264() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I06265() { lac += core[000004];  }
void L06266() { if (++core[000044] == 010000) { core[000044] = 0; npc++; }; code[000044] = &emul8;  }
void I06267() { npc = 006252; inh = 0;  }
void I06270() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I06271() { npc = 006301; inh = 0;  }
void I06272() { lac &= 010000; lac ^= 07777;  }
void I06273() { lac += core[000156];  }
void I06274() { core[000156] = lac & 07777; lac &= 010000; code[000156] = &emul8;  }
void I06275() { lac += core[000045];  }
void I06276() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06277() { core[000156] = lac & 07777; lac &= 010000; code[000156] = &emul8;  }
void I06300() { skp = 0; skp = !skp; npc += skp;  }
void L06301() { if (++core[000012] == 010000) core[000012] = 0000;core[(df<<12)+core[000012]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000012]] = &emul8;  }
void I06302() { lac += core[006225];  }
void I06303() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void L06304() { core[(ib<<12)+core[3228]] = 06305; npc = (ib<<12)+core[3228]+1; code[(ib<<12)+core[3228]] = &emul8; inh = 0;  }
void I06305() { lac += core[000162];  }
void I06306() { if (++core[000012] == 010000) core[000012] = 0000;core[(df<<12)+core[000012]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000012]] = &emul8;  }
void I06307() { if (++core[000044] == 010000) { core[000044] = 0; npc++; }; code[000044] = &emul8;  }
void I06310() { npc = 006304; inh = 0;  }
void I06311() { lac += core[006235];  }
void I06312() { core[000012] = lac & 07777; lac &= 010000; code[000012] = &emul8;  }
void I06313() { lac += core[006225];  }
void I06314() { core[000157] = lac & 07777; lac &= 010000; code[000157] = &emul8;  }
void I06315() { lac += core[000051];  }
void I06316() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06317() { npc = 006340; inh = 0;  }
void I06320() { lac ^= 07777; lac++;  }
void I06321() { lac += core[000133];  }
void I06322() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06323() { npc = 006327; inh = 0;  }
void I06324() { lac &= 010000;  }
void I06325() { lac += core[000051];  }
void I06326() { core[000133] = lac & 07777; lac &= 010000; code[000133] = &emul8;  }
void L06327() { lac += core[000156];  }
void I06330() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I06331() { lac &= 010000;  }
void I06332() { lac += core[000051];  }
void I06333() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void P06334() { npc = 006362; inh = 0;  }
void I06335() { lac += core[006226];  }
void I06336() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I06337() { lac &= 010000;  }
void L06340() { lac += core[006227];  }
void I06341() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void P06342() { lac += core[006235];  }
void I06343() { lac += core[000004];  }
void I06344() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I06345() { lac += core[000004];  }
void I06346() { lac ^= 07777; lac++;  }
void I06347() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void I06350() { lac += core[(df<<12)+core[3225]];  }
void L06351() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void I06352() { lac += core[(df<<12)+core[32]];  }
void I06353() { lac += core[006230];  }
void I06354() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06355() { npc = 006364; inh = 0;  }
void I06356() { core[(df<<12)+core[32]] = lac & 07777; lac &= 010000; code[(df<<12)+core[32]] = &emul8;  }
void I06357() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void I06360() { npc = 006240; inh = 0;  }
void I06361() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void L06362() { if (++core[000156] == 010000) { core[000156] = 0; npc++; }; code[000156] = &emul8;  }
void I06363() { lac &= 010000;  }
void L06364() { lac += core[000051];  }
void I06365() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06366() { npc = (ib<<12)+core[3230]; inh = 0;  }
void I06367() { lac ^= 07777; lac++;  }
void P06370() { core[000164] = lac & 07777; lac &= 010000; code[000164] = &emul8;  }
void I06371() { lac += core[000164];  }
void I06372() { lac += core[000156];  }
void P06373() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp;  }
void I06374() { npc = (ib<<12)+core[3231]; inh = 0;  }
void I06375() { lac += core[000133];  }
void I06376() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I06377() { lac &= 010000;  }
void I06400() { lac ^= 07777; lac++;  }
void I06401() { lac += core[000156];  }
void D06402() { lac &= 07777; lac ^= 07777; lac++;  }
void I06403() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void I06404() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I06405() { npc = 006422; inh = 0;  }
void L06406() { lac += core[000156];  }
void I06407() { lac += core[000004];  }
void I06410() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06411() { npc = 006425; inh = 0;  }
void I06412() { lac += core[000004];  }
void I06413() { lac++;  }
void I06414() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06415() { lac += core[000025];  }
void P06416() { core[006437] = 06417; npc = 006437+1; code[006437] = &emul8; inh = 0;  }
void I06417() { npc = (ib<<12)+core[3365]; inh = 0;  }
void I06420() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void I06421() { npc = 006406; inh = 0;  }
void L06422() { lac += core[000022];  }
void I06423() { core[(ib<<12)+core[74]] = 06424; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I06424() { npc = 006406; inh = 0;  }
void L06425() { lac ^= 07777;  }
void I06426() { lac += core[000156];  }
void I06427() { core[000156] = lac & 07777; lac &= 010000; code[000156] = &emul8;  }
void I06430() { if (++core[000157] == 010000) { core[000157] = 0; npc++; }; code[000157] = &emul8;  }
void I06431() { npc = 006435; inh = 0;  }
void I06432() { lac ^= 07777;  }
void I06433() { core[000157] = lac & 07777; lac &= 010000; code[000157] = &emul8;  }
void I06434() { npc = 006416; inh = 0;  }
void L06435() { if (++core[000012] == 010000) core[000012] = 0000;lac += core[(df<<12)+core[000012]];  }
void I06436() { npc = 006416; inh = 0;  }
void S06437() { lac &= (010000|core[000000]);  }
void I06440() { lac += core[000036];  }
void I06441() { core[(ib<<12)+core[74]] = 06442; npc = (ib<<12)+core[74]+1; code[(ib<<12)+core[74]] = &emul8; inh = 0;  }
void I06442() { if (++core[000164] == 010000) { core[000164] = 0; npc++; }; code[000164] = &emul8;  }
void I06443() { if (++core[006437] == 010000) { core[006437] = 0; npc++; }; code[006437] = &emul8;  }
void I06444() { npc = (ib<<12)+core[3359]; inh = 0;  }
void P06445() { emul8();  }
void L06446() { core[(ib<<12)+core[81]] = 06447; npc = (ib<<12)+core[81]+1; code[(ib<<12)+core[81]] = &emul8; inh = 0;  }
void I06447() { core[(ib<<12)+core[72]] = 06450; npc = (ib<<12)+core[72]+1; code[(ib<<12)+core[72]] = &emul8; inh = 0;  }
void I06450() { if (++core[006577] == 010000) { core[006577] = 0; npc++; }; code[006577] = &emul8;  }
void I06451() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac |= swr;  }
void I06452() { core[(ib<<12)+core[86]] = 06453; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I06453() { lac &= 010000; lac ^= 07777;  }
void I06454() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I06455() { emul8();  }
void I06456() { lac += core[006517];  }
void I06457() { lac += core[000161];  }
void I06460() { core[000113] = lac & 07777; lac &= 010000; code[000113] = &emul8;  }
void L06461() { core[(ib<<12)+core[117]] = 06462; npc = (ib<<12)+core[117]+1; code[(ib<<12)+core[117]] = &emul8; inh = 0;  }
void I06462() { npc = 006461; inh = 0;  }
void I06463() { npc = (ib<<12)+core[3381]; inh = 0;  }
void I06464() { npc = 006446; inh = 0;  }
void P06465() { lac &= (010000|core[(df<<12)+core[3342]]);  }
void P06466() { lac &= (010000|core[000000]);  }
void L06467() { lac += core[000067];  }
void I06470() { core[000156] = lac & 07777; lac &= 010000; code[000156] = &emul8;  }
void I06471() { core[000157] = lac & 07777; lac &= 010000; code[000157] = &emul8;  }
void L06472() { emul8();  }
void I06473() { lac += core[000037];  }
void I06474() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I06475() { npc = 006506; inh = 0;  }
void I06476() { if (++core[000157] == 010000) { core[000157] = 0; npc++; }; code[000157] = &emul8;  }
void I06477() { npc = 006472; inh = 0;  }
void I06500() { if (++core[000156] == 010000) { core[000156] = 0; npc++; }; code[000156] = &emul8;  }
void I06501() { npc = 006472; inh = 0;  }
void I06502() { lac += core[000161];  }
void I06503() { core[000113] = lac & 07777; lac &= 010000; code[000113] = &emul8;  }
void I06504() { lac += core[000054];  }
void I06505() { npc = 006515; inh = 0;  }
void L06506() { lac ^= 07777;  }
void I06507() { core[000037] = lac & 07777; lac &= 010000; code[000037] = &emul8;  }
void I06510() { emul8();  }
void I06511() { lac &= (010000|core[000026]);  }
void I06512() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06513() { npc = 006467; inh = 0;  }
void I06514() { lac += core[000015];  }
void L06515() { core[000142] = lac & 07777; lac &= 010000; code[000142] = &emul8;  }
void I06516() { npc = (ib<<12)+core[3382]; inh = 0;  }
void D06517() { core[000003] = 06520; npc = 000003+1; code[000003] = &emul8; inh = 0;  }
void S06600() { lac &= (010000|core[000000]);  }
void L06601() { lac &= 010000; lac &= 07777;  }
void I06602() { lac += core[(df<<12)+core[3456]];  }
void I06603() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06604() { npc = (ib<<12)+core[3456]; inh = 0;  }
void I06605() { lac &= (010000|core[000015]);  }
void I06606() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06607() { lac += core[006600];  }
void I06610() { lac &= (010000|core[000024]);  }
void I06611() { core[006631] = lac & 07777; lac &= 010000; code[006631] = &emul8;  }
void I06612() { lac += core[(df<<12)+core[3456]];  }
void I06613() { lac &= (010000|core[000026]);  }
void I06614() { lac += core[006631];  }
void I06615() { core[006631] = lac & 07777; lac &= 010000; code[006631] = &emul8;  }
void I06616() { lac += core[(df<<12)+core[3456]];  }
void I06617() { if (++core[006600] == 010000) { core[006600] = 0; npc++; }; code[006600] = &emul8;  }
void I06620() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I06621() { lac = (lac<<2) + ((lac>>11)&3);  }
void I06622() { lac &= (010000|core[000031]);  }
void I06623() { lac += core[006636];  }
void I06624() { core[006635] = lac & 07777; lac &= 010000; code[006635] = &emul8;  }
void I06625() { lac += core[(df<<12)+core[3481]];  }
void I06626() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I06627() { core[006631] = lac & 07777; lac &= 010000; code[006631] = &emul8;  }
void I06630() { core[(ib<<12)+core[68]] = 06631; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void P06631() { lac &= (010000|core[000000]);  }
void I06632() { core[(ib<<12)+core[69]] = 06633; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I06633() { lac &= (010000|core[000040]);  }
void I06634() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void D06635() { npc = (ib<<12)+core[3487]; inh = 0;  }
void D06636() { npc = (ib<<12)+core[3487]; inh = 0;  }
void P06637() { lac |= swr; hlt = 1;  }
void I06640() { emul8();  }
void I06641() { emul8();  }
void I06642() { lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I06643() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06644() { emul8();  }
void I06645() { emul8();  }
void I06646() { emul8();  }
void L06647() { core[(ib<<12)+core[68]] = 06650; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I06650() { lac &= (010000|core[000040]);  }
void I06651() { lac += core[006654];  }
void I06652() { npc = 006656; inh = 0;  }
void I06653() { core[(ib<<12)+core[68]] = 06654; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void D06654() { lac &= (010000|core[000044]);  }
void I06655() { lac += core[006631];  }
void L06656() { core[006660] = lac & 07777; lac &= 010000; code[006660] = &emul8;  }
void I06657() { core[(ib<<12)+core[69]] = 06660; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void D06660() { lac &= (010000|core[000000]);  }
void I06661() { npc = 006601; inh = 0;  }
void S06662() { lac &= (010000|core[000000]);  }
void I06663() { lac += core[000042];  }
void I06664() { lac &= 07777; lac ^= 07777; lac++;  }
void I06665() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I06666() { lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I06667() { lac += core[000041];  }
void I06670() { lac ^= 07777; lac++;  }
void I06671() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I06672() { lac += core[000004];  }
void I06673() { lac &= 07777; lac ^= 07777;  }
void I06674() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void I06675() { npc = (ib<<12)+core[3506]; inh = 0;  }
void S06676() { lac &= (010000|core[000000]);  }
void I06677() { lac &= 010000; lac &= 07777;  }
void I06700() { lac += core[000047];  }
void I06701() { lac ^= 07777; lac++;  }
void I06702() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I06703() { lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I06704() { lac += core[000046];  }
void I06705() { lac ^= 07777; lac++;  }
void I06706() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I06707() { lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I06710() { lac += core[000045];  }
void I06711() { lac ^= 07777; lac++;  }
void I06712() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void P06713() { lac += core[000004];  }
void I06714() { lac &= 07777; lac ^= 07777;  }
void I06715() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void I06716() { npc = (ib<<12)+core[3518]; inh = 0;  }
void I06717() { core[006662] = 06720; npc = 006662+1; code[006662] = &emul8; inh = 0;  }
void I06720() { lac += core[000045];  }
void I06721() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06722() { npc = 006647; inh = 0;  }
void I06723() { lac += core[000041];  }
void I06724() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06725() { npc = 006601; inh = 0;  }
void I06726() { lac += core[000040];  }
void I06727() { lac ^= 07777; lac++;  }
void D06730() { lac += core[000044];  }
void I06731() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06732() { npc = 006757; inh = 0;  }
void I06733() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I06734() { npc = 006746; inh = 0;  }
void I06735() { lac += core[006765];  }
void I06736() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06737() { npc = 006647; inh = 0;  }
void I06740() { lac += core[006764];  }
void I06741() { core[006635] = lac & 07777; lac &= 010000; code[006635] = &emul8;  }
void L06742() { core[(ib<<12)+core[3575]] = 06743; npc = (ib<<12)+core[3575]+1; code[(ib<<12)+core[3575]] = &emul8; inh = 0;  }
void I06743() { if (++core[006635] == 010000) { core[006635] = 0; npc++; }; code[006635] = &emul8;  }
void I06744() { npc = 006742; inh = 0;  }
void D06745() { npc = 006757; inh = 0;  }
void L06746() { lac ^= 07777; lac++;  }
void D06747() { lac += core[006765];  }
void I06750() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I06751() { npc = 006601; inh = 0;  }
void I06752() { lac += core[006764];  }
void I06753() { core[006635] = lac & 07777; lac &= 010000; code[006635] = &emul8;  }
void L06754() { core[(ib<<12)+core[3574]] = 06755; npc = (ib<<12)+core[3574]+1; code[(ib<<12)+core[3574]] = &emul8; inh = 0;  }
void I06755() { if (++core[006635] == 010000) { core[006635] = 0; npc++; }; code[006635] = &emul8;  }
void I06756() { npc = 006754; inh = 0;  }
void L06757() { core[(ib<<12)+core[3575]] = 06760; npc = (ib<<12)+core[3575]+1; code[(ib<<12)+core[3575]] = &emul8; inh = 0;  }
void I06760() { core[(ib<<12)+core[3574]] = 06761; npc = (ib<<12)+core[3574]+1; code[(ib<<12)+core[3574]] = &emul8; inh = 0;  }
void I06761() { core[(ib<<12)+core[3576]] = 06762; npc = (ib<<12)+core[3576]+1; code[(ib<<12)+core[3576]] = &emul8; inh = 0;  }
void I06762() { core[(ib<<12)+core[3577]] = 06763; npc = (ib<<12)+core[3577]+1; code[(ib<<12)+core[3577]] = &emul8; inh = 0;  }
void I06763() { npc = 006601; inh = 0;  }
void D06764() { emul8();  }
void D06765() { lac &= (010000|core[000027]);  }
void P06766() { lac &= 010000; lac ^= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void P06767() { lac &= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void P06770() { npc = (ib<<12)+core[3531]; inh = 0;  }
void P06771() {  }
void I06772() { core[006747] = lac & 07777; lac &= 010000; code[006747] = &emul8;  }
void I06773() { core[006747] = lac & 07777; lac &= 010000; code[006747] = &emul8;  }
void I06774() { core[006730] = lac & 07777; lac &= 010000; code[006730] = &emul8;  }
void I06775() { core[006747] = lac & 07777; lac &= 010000; code[006747] = &emul8;  }
void I06776() { core[006747] = lac & 07777; lac &= 010000; code[006747] = &emul8;  }
void I06777() { core[006745] = lac & 07777; lac &= 010000; code[006745] = &emul8;  }
void S07000() { lac &= (010000|core[000000]);  }
void I07001() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I07002() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void I07003() { lac += core[000045];  }
void I07004() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07005() { lac += core[000046];  }
void I07006() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07007() { lac += core[000047];  }
void I07010() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07011() { npc = 007032; inh = 0;  }
void I07012() { lac += core[000045];  }
void I07013() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07014() { core[(ib<<12)+core[40]] = 07015; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07015() { core[007055] = lac & 07777; lac &= 010000; code[007055] = &emul8;  }
void L07016() { lac += core[000045];  }
void I07017() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I07020() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07021() { npc = 007025; inh = 0;  }
void I07022() { core[007037] = 07023; npc = 007037+1; code[007037] = &emul8; inh = 0;  }
void I07023() { if (++core[007055] == 010000) { core[007055] = 0; npc++; }; code[007055] = &emul8;  }
void I07024() { npc = 007016; inh = 0;  }
void L07025() { if (++core[000004] == 010000) { core[000004] = 0; npc++; }; code[000004] = &emul8;  }
void I07026() { core[(ib<<12)+core[40]] = 07027; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07027() { lac += core[007055];  }
void I07030() { lac ^= 07777; lac++;  }
void I07031() { lac += core[000044];  }
void L07032() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07033() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07034() { npc = (ib<<12)+core[3584]; inh = 0;  }
void P07035() { emul8();  }
void P07036() { emul8();  }
void S07037() { lac &= (010000|core[000000]);  }
void I07040() { lac += core[000047];  }
void I07041() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I07042() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07043() { core[007045] = 07044; npc = 007045+1; code[007045] = &emul8; inh = 0;  }
void I07044() { npc = (ib<<12)+core[3615]; inh = 0;  }
void S07045() { lac &= (010000|core[000000]);  }
void I07046() { lac += core[000046];  }
void I07047() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07050() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I07051() { lac += core[000045];  }
void I07052() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07053() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I07054() { npc = (ib<<12)+core[3621]; inh = 0;  }
void S07055() { lac &= (010000|core[000000]);  }
void I07056() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I07057() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void I07060() { lac += core[000045];  }
void I07061() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07062() { npc = (ib<<12)+core[3613]; inh = 0;  }
void D07063() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07064() { core[(ib<<12)+core[40]] = 07065; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07065() { lac += core[000045];  }
void I07066() { core[000162] = lac & 07777; lac &= 010000; code[000162] = &emul8;  }
void I07067() { lac += core[000046];  }
void I07070() { core[000163] = lac & 07777; lac &= 010000; code[000163] = &emul8;  }
void I07071() { lac += core[000041];  }
void D07072() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07073() { core[(ib<<12)+core[3614]] = 07074; npc = (ib<<12)+core[3614]+1; code[(ib<<12)+core[3614]] = &emul8; inh = 0;  }
void I07074() { lac += core[000004];  }
void I07075() { core[000157] = lac & 07777; lac &= 010000; code[000157] = &emul8;  }
void I07076() { npc = (ib<<12)+core[3629]; inh = 0;  }
void I07077() { lac += core[007063];  }
void I07100() { core[007072] = lac & 07777; lac &= 010000; code[007072] = &emul8;  }
void I07101() { core[007055] = 07102; npc = 007055+1; code[007055] = &emul8; inh = 0;  }
void I07102() { lac += core[000042];  }
void I07103() { core[007133] = 07104; npc = 007133+1; code[007133] = &emul8; inh = 0;  }
void I07104() { lac &= 010000; lac &= 07777; lac++;  }
void I07105() { lac += core[000044];  }
void I07106() { lac += core[000040];  }
void I07107() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07110() { lac += core[007072];  }
void I07111() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07112() { lac += core[007037];  }
void I07113() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I07114() { lac += core[000041];  }
void I07115() { core[007133] = 07116; npc = 007133+1; code[007133] = &emul8; inh = 0;  }
void I07116() { lac += core[000047];  }
void I07117() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07120() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07121() { lac += core[007072];  }
void I07122() { lac += core[000046];  }
void I07123() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I07124() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07125() { lac += core[007037];  }
void I07126() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I07127() { core[007000] = 07130; npc = 007000+1; code[007000] = &emul8; inh = 0;  }
void L07130() { if (++core[000157] == 010000) { core[000157] = 0; npc++; }; code[000157] = &emul8;  }
void I07131() { core[(ib<<12)+core[40]] = 07132; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07132() { npc = (ib<<12)+core[3613]; inh = 0;  }
void S07133() { lac &= (010000|core[000000]);  }
void I07134() { core[007000] = lac & 07777; lac &= 010000; code[007000] = &emul8;  }
void I07135() { core[007037] = lac & 07777; lac &= 010000; code[007037] = &emul8;  }
void I07136() { core[007072] = lac & 07777; lac &= 010000; code[007072] = &emul8;  }
void I07137() { lac += core[007170];  }
void I07140() { core[007055] = lac & 07777; lac &= 010000; code[007055] = &emul8;  }
void I07141() { lac &= 07777;  }
void L07142() { lac += core[007000];  }
void I07143() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07144() { core[007000] = lac & 07777; lac &= 010000; code[007000] = &emul8;  }
void I07145() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I07146() { npc = 007155; inh = 0;  }
void I07147() { lac &= 07777;  }
void I07150() { lac += core[000163];  }
void I07151() { lac += core[007072];  }
void I07152() { core[007072] = lac & 07777; lac &= 010000; code[007072] = &emul8;  }
void I07153() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07154() { lac += core[000162];  }
void L07155() { lac += core[007037];  }
void I07156() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07157() { core[007037] = lac & 07777; lac &= 010000; code[007037] = &emul8;  }
void I07160() { lac += core[007072];  }
void I07161() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07162() { core[007072] = lac & 07777; lac &= 010000; code[007072] = &emul8;  }
void I07163() { if (++core[007055] == 010000) { core[007055] = 0; npc++; }; code[007055] = &emul8;  }
void I07164() { npc = 007142; inh = 0;  }
void I07165() { lac += core[007000];  }
void I07166() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07167() { npc = (ib<<12)+core[3675]; inh = 0;  }
void D07170() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void I07171() { lac += core[000041];  }
void I07172() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07173() { core[(ib<<12)+core[86]] = 07174; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I07174() { lac += core[000062];  }
void I07175() { core[007072] = lac & 07777; lac &= 010000; code[007072] = &emul8;  }
void I07176() { core[007055] = 07177; npc = 007055+1; code[007055] = &emul8; inh = 0;  }
void I07177() { lac += core[000040];  }
void I07200() { lac ^= 07777; lac++;  }
void I07201() { lac += core[000044];  }
void I07202() { lac++;  }
void I07203() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07204() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I07205() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I07206() { lac += core[007314];  }
void I07207() { core[007271] = lac & 07777; lac &= 010000; code[007271] = &emul8;  }
void I07210() { npc = 007226; inh = 0;  }
void L07211() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I07212() { npc = 007216; inh = 0;  }
void I07213() { core[000162] = lac & 07777; lac &= 010000; code[000162] = &emul8;  }
void I07214() { lac += core[000164];  }
void I07215() { core[000163] = lac & 07777; lac &= 010000; code[000163] = &emul8;  }
void L07216() { lac &= 010000;  }
void I07217() { core[(ib<<12)+core[3751]] = 07220; npc = (ib<<12)+core[3751]+1; code[(ib<<12)+core[3751]] = &emul8; inh = 0;  }
void I07220() { lac += core[000163];  }
void I07221() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07222() { core[000163] = lac & 07777; lac &= 010000; code[000163] = &emul8;  }
void I07223() { lac += core[000162];  }
void I07224() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07225() { core[000162] = lac & 07777; lac &= 010000; code[000162] = &emul8;  }
void L07226() { lac &= 07777;  }
void I07227() { lac += core[000042];  }
void I07230() { lac += core[000163];  }
void I07231() { core[000164] = lac & 07777; lac &= 010000; code[000164] = &emul8;  }
void I07232() { lac = (lac<<1) + ((lac>>12)&1);  }
void I07233() { lac += core[000041];  }
void I07234() { lac += core[000162];  }
void I07235() { if (++core[007271] == 010000) { core[007271] = 0; npc++; }; code[007271] = &emul8;  }
void I07236() { npc = 007211; inh = 0;  }
void I07237() { lac &= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07240() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07241() { core[(ib<<12)+core[3752]] = 07242; npc = (ib<<12)+core[3752]+1; code[(ib<<12)+core[3752]] = &emul8; inh = 0;  }
void I07242() { if (++core[000157] == 010000) { core[000157] = 0; npc++; }; code[000157] = &emul8;  }
void I07243() { npc = (ib<<12)+core[3750]; inh = 0;  }
void I07244() { core[(ib<<12)+core[40]] = 07245; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07245() { npc = (ib<<12)+core[3750]; inh = 0;  }
void P07246() { emul8();  }
void P07247() { lac ^= 07777; lac++; lac = (lac<<1) + ((lac>>12)&1);  }
void P07250() {  }
void S07251() { lac &= (010000|core[000000]);  }
void I07252() { lac &= 010000; lac &= 07777;  }
void I07253() { lac += core[000045];  }
void I07254() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I07255() { lac ^= 010000;  }
void L07256() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07257() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I07260() { lac += core[000046];  }
void I07261() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07262() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I07263() { lac += core[000047];  }
void I07264() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07265() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07266() { if (++core[000044] == 010000) { core[000044] = 0; npc++; }; code[000044] = &emul8;  }
void I07267() { npc = (ib<<12)+core[3753]; inh = 0;  }
void I07270() { npc = (ib<<12)+core[3753]; inh = 0;  }
void S07271() { lac &= (010000|core[000000]);  }
void I07272() { lac &= 010000; lac &= 07777;  }
void I07273() { lac += core[000041];  }
void I07274() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I07275() { lac ^= 010000;  }
void I07276() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07277() { core[000041] = lac & 07777; lac &= 010000; code[000041] = &emul8;  }
void I07300() { lac += core[000042];  }
void I07301() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07302() { core[000042] = lac & 07777; lac &= 010000; code[000042] = &emul8;  }
void I07303() { lac += core[000043];  }
void I07304() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07305() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I07306() { if (++core[000040] == 010000) { core[000040] = 0; npc++; }; code[000040] = &emul8;  }
void I07307() { npc = (ib<<12)+core[3769]; inh = 0;  }
void I07310() { npc = (ib<<12)+core[3769]; inh = 0;  }
void S07311() { lac &= (010000|core[000000]);  }
void I07312() { lac &= 010000; lac &= 07777;  }
void P07313() { lac += core[000044];  }
void D07314() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07315() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07316() { lac += core[000044];  }
void I07317() { lac += core[007331];  }
void I07320() { core[007271] = lac & 07777; lac &= 010000; code[007271] = &emul8;  }
void I07321() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I07322() { npc = (ib<<12)+core[3785]; inh = 0;  }
void L07323() { core[007251] = 07324; npc = 007251+1; code[007251] = &emul8; inh = 0;  }
void I07324() { if (++core[007271] == 010000) { core[007271] = 0; npc++; }; code[007271] = &emul8;  }
void I07325() { npc = 007323; inh = 0;  }
void I07326() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07327() { lac += core[000046];  }
void I07330() { npc = (ib<<12)+core[3785]; inh = 0;  }
void D07331() { emul8();  }
void S07332() { lac &= (010000|core[000000]);  }
void I07333() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void I07334() { core[000046] = lac & 07777; lac &= 010000; code[000046] = &emul8;  }
void I07335() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07336() { lac += core[000005];  }
void I07337() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07340() { core[007251] = 07341; npc = 007251+1; code[007251] = &emul8; inh = 0;  }
void I07341() { core[(ib<<12)+core[3752]] = 07342; npc = (ib<<12)+core[3752]+1; code[(ib<<12)+core[3752]] = &emul8; inh = 0;  }
void I07342() { npc = (ib<<12)+core[3802]; inh = 0;  }
void P07343() { lac ^= 010000; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void P07344() { npc = (ib<<12)+core[3787]; inh = 0;  }
void D07345() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void D07346() { core[(ib<<12)+core[17]] = 07347; npc = (ib<<12)+core[17]+1; code[(ib<<12)+core[17]] = &emul8; inh = 0;  }
void I07347() { core[000040] = lac & 07777; lac &= 010000; code[000040] = &emul8;  }
void I07350() { lac &= (010000|core[000001]);  }
void I07351() { core[(ib<<12)+core[7]] = 07352; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I07352() { &emul8;  }
void I07353() { &emul8;  }
void I07354() { core[(ib<<12)+core[68]] = 07355; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I07355() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I07356() { core[(ib<<12)+core[69]] = 07357; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I07357() { lac &= (010000|core[000041]);  }
void I07360() { lac += core[007345];  }
void I07361() { core[000156] = lac & 07777; lac &= 010000; code[000156] = &emul8;  }
void L07362() { core[(ib<<12)+core[3811]] = 07363; npc = (ib<<12)+core[3811]+1; code[(ib<<12)+core[3811]] = &emul8; inh = 0;  }
void I07363() { if (++core[000156] == 010000) { core[000156] = 0; npc++; }; code[000156] = &emul8;  }
void I07364() { npc = 007362; inh = 0;  }
void I07365() { core[(ib<<12)+core[3812]] = 07366; npc = (ib<<12)+core[3812]+1; code[(ib<<12)+core[3812]] = &emul8; inh = 0;  }
void I07366() { core[(ib<<12)+core[3811]] = 07367; npc = (ib<<12)+core[3811]+1; code[(ib<<12)+core[3811]] = &emul8; inh = 0;  }
void I07367() { core[(ib<<12)+core[3812]] = 07370; npc = (ib<<12)+core[3812]+1; code[(ib<<12)+core[3812]] = &emul8; inh = 0;  }
void I07370() { core[(ib<<12)+core[68]] = 07371; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I07371() { lac &= (010000|core[000045]);  }
void I07372() { core[(ib<<12)+core[69]] = 07373; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I07373() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I07374() { core[000047] = lac & 07777; lac &= 010000; code[000047] = &emul8;  }
void I07375() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07376() { lac += core[000045];  }
void I07377() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I07400() { npc = (ib<<12)+core[64]; inh = 0;  }
void I07401() { if (++core[000046] == 010000) { core[000046] = 0; npc++; }; code[000046] = &emul8;  }
void I07402() { skp = 0; skp = !skp; npc += skp;  }
void I07403() { if (++core[000045] == 010000) { core[000045] = 0; npc++; }; code[000045] = &emul8;  }
void I07404() { core[(ib<<12)+core[40]] = 07405; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void I07405() { npc = (ib<<12)+core[64]; inh = 0;  }
void L07406() { lac += core[(df<<12)+core[7]];  }
void I07407() { core[(ib<<12)+core[67]] = 07410; npc = (ib<<12)+core[67]+1; code[(ib<<12)+core[67]] = &emul8; inh = 0;  }
void D07410() { core[(ib<<12)+core[68]] = 07411; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I07411() { lac &= (010000|core[000044]);  }
void I07412() { core[(ib<<12)+core[69]] = 07413; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I07413() { emul8();  }
void I07414() { core[(ib<<12)+core[68]] = 07415; npc = (ib<<12)+core[68]+1; code[(ib<<12)+core[68]] = &emul8; inh = 0;  }
void I07415() { lac &= (010000|core[000040]);  }
void I07416() { core[(ib<<12)+core[69]] = 07417; npc = (ib<<12)+core[69]+1; code[(ib<<12)+core[69]] = &emul8; inh = 0;  }
void I07417() { lac &= (010000|core[000044]);  }
void I07420() { core[(ib<<12)+core[42]] = 07421; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void I07421() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07422() { lac++;  }
void I07423() { lac += core[000045];  }
void I07424() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07425() { core[(ib<<12)+core[86]] = 07426; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I07426() { lac += core[000046];  }
void I07427() { core[007550] = lac & 07777; lac &= 010000; code[007550] = &emul8;  }
void I07430() { core[(ib<<12)+core[7]] = 07431; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I07431() { &emul8;  }
void I07432() { &emul8;  }
void I07433() { lac += core[007550];  }
void I07434() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07435() { npc = 007455; inh = 0;  }
void I07436() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I07437() { npc = 007446; inh = 0;  }
void I07440() { core[(ib<<12)+core[7]] = 07441; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I07441() { &emul8;  }
void I07442() { &emul8;  }
void I07443() { &emul8;  }
void I07444() { &emul8;  }
void I07445() { npc = 007450; inh = 0;  }
void L07446() { lac ^= 07777; lac++;  }
void I07447() { core[007550] = lac & 07777; lac &= 010000; code[007550] = &emul8;  }
void L07450() { core[(ib<<12)+core[7]] = 07451; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void I07451() { &emul8;  }
void I07452() { &emul8;  }
void I07453() { if (++core[007550] == 010000) { core[007550] = 0; npc++; }; code[007550] = &emul8;  }
void I07454() { npc = 007450; inh = 0;  }
void L07455() { if (++core[000013] == 010000) core[000013] = 0000;lac += core[(df<<12)+core[000013]];  }
void I07456() { core[(df<<12)+core[7]] = lac & 07777; lac &= 010000; code[(df<<12)+core[7]] = &emul8;  }
void I07457() { npc = (ib<<12)+core[3888]; inh = 0;  }
void P07460() { emul8();  }
void P07461() { lac += core[(df<<12)+core[123]];  }
void I07462() { lac += core[000045];  }
void I07463() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I07464() { core[(ib<<12)+core[86]] = 07465; npc = (ib<<12)+core[86]+1; code[(ib<<12)+core[86]] = &emul8; inh = 0;  }
void I07465() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07466() { npc = (ib<<12)+core[64]; inh = 0;  }
void I07467() { lac += core[000044];  }
void I07470() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I07471() { lac ^= 010000;  }
void I07472() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07473() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07474() { lac += core[007534];  }
void I07475() { core[000045] = lac & 07777; lac &= 010000; code[000045] = &emul8;  }
void L07476() { core[(ib<<12)+core[7]] = 07477; npc = (ib<<12)+core[7]+1; code[(ib<<12)+core[7]] = &emul8; inh = 0;  }
void D07477() { &emul8;  }
void I07500() { &emul8;  }
void I07501() { &emul8;  }
void I07502() { &emul8;  }
void I07503() { &emul8;  }
void I07504() { lac ^= 07777;  }
void I07505() { lac += core[000044];  }
void I07506() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I07507() { lac += core[000044];  }
void I07510() { lac ^= 07777; lac++;  }
void I07511() { lac += core[007545];  }
void I07512() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07513() { npc = 007476; inh = 0;  }
void I07514() { lac += core[000045];  }
void I07515() { lac ^= 07777; lac++;  }
void I07516() { lac += core[007546];  }
void I07517() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07520() { npc = 007476; inh = 0;  }
void I07521() { lac += core[000046];  }
void I07522() { lac ^= 07777; lac++;  }
void I07523() { lac += core[007547];  }
void I07524() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07525() { npc = (ib<<12)+core[64]; inh = 0;  }
void I07526() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I07527() { lac ^= 07777; lac++;  }
void I07530() { lac++;  }
void I07531() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07532() { npc = (ib<<12)+core[64]; inh = 0;  }
void I07533() { npc = 007476; inh = 0;  }
void D07534() { core[000015] = lac & 07777; lac &= 010000; code[000015] = &emul8;  }
void I07535() { lac += core[000045];  }
void I07536() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07537() { npc = 007543; inh = 0;  }
void L07540() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07541() { lac += core[000034];  }
void I07542() { lac++;  }
void L07543() { core[(ib<<12)+core[24]] = 07544; npc = (ib<<12)+core[24]+1; code[(ib<<12)+core[24]] = &emul8; inh = 0;  }
void I07544() { npc = (ib<<12)+core[64]; inh = 0;  }
void D07545() { lac &= (010000|core[000000]);  }
void D07546() { lac &= (010000|core[000000]);  }
void D07547() { lac &= (010000|core[000000]);  }
void D07550() { lac &= (010000|core[000000]);  }
void preinit() {
  core[000001] = 05402; code[000001] = &D00001;
  core[000002] = 02603; code[000002] = &P00002;
  core[000003] = 07477; code[000003] = &P00003;
  core[000004] = 00000; code[000004] = &P00004;
  core[000005] = 00013; code[000005] = &D00005;
  core[000006] = 00100; code[000006] = &D00006;
  core[000007] = 06600; code[000007] = &P00007;
  core[000010] = 00000; code[000010] = &P00010;
  core[000011] = 00000; code[000011] = &P00011;
  core[000012] = 00000; code[000012] = &P00012;
  core[000013] = 00000; code[000013] = &P00013;
  core[000014] = 03377; code[000014] = &P00014;
  core[000015] = 00200; code[000015] = &D00015;
  core[000016] = 00000; code[000016] = &P00016;
  core[000017] = 03430; code[000017] = &P00017;
  core[000020] = 00000; code[000020] = &P00020;
  core[000021] = 00000; code[000021] = &P00021;
  core[000022] = 00256; code[000022] = &D00022;
  core[000023] = 07701; code[000023] = &D00023;
  core[000024] = 07600; code[000024] = &P00024;
  core[000025] = 07760; code[000025] = &D00025;
  core[000026] = 00177; code[000026] = &P00026;
  core[000027] = 05577; code[000027] = &D00027;
  core[000030] = 07332; code[000030] = &P00030;
  core[000031] = 00017; code[000031] = &D00031;
  core[000032] = 00277; code[000032] = &P00032;
  core[000033] = 00240; code[000033] = &D00033;
  core[000034] = 07776; code[000034] = &D00034;
  core[000035] = 00002; code[000035] = &P00035;
  core[000036] = 00260; code[000036] = &D00036;
  core[000037] = 00000; code[000037] = &D00037;
  core[000040] = 00000; code[000040] = &P00040;
  core[000041] = 00000; code[000041] = &D00041;
  core[000042] = 00000; code[000042] = &D00042;
  core[000043] = 00000; code[000043] = &P00043;
  core[000044] = 00000; code[000044] = &D00044;
  core[000045] = 00000; code[000045] = &D00045;
  core[000046] = 00000; code[000046] = &D00046;
  core[000047] = 00000; code[000047] = &D00047;
  core[000050] = 06676; code[000050] = &P00050;
  core[000051] = 00010; code[000051] = &P00051;
  core[000052] = 07311; code[000052] = &P00052;
  core[000053] = 00000; code[000053] = &D00053;
  core[000054] = 00337; code[000054] = &P00054;
  core[000055] = 00214; code[000055] = &D00055;
  core[000056] = 00207; code[000056] = &D00056;
  core[000057] = 00212; code[000057] = &D00057;
  core[000060] = 00215; code[000060] = &D00060;
  core[000061] = 00000; code[000061] = &D00061;
  core[000062] = 07700; code[000062] = &D00062;
  core[000063] = 07540; code[000063] = &P00063;
  core[000064] = 07522; code[000064] = &D00064;
  core[000065] = 07563; code[000065] = &P00065;
  core[000066] = 07775; code[000066] = &P00066;
  core[000067] = 07773; code[000067] = &D00067;
  core[000070] = 07767; code[000070] = &D00070;
  core[000071] = 00077; code[000071] = &P00071;
  core[000072] = 06170; code[000072] = &P00072;
  core[000073] = 05600; code[000073] = &P00073;
  core[000074] = 02527; code[000074] = &D00074;
  core[000075] = 03420; code[000075] = &P00075;
  core[000076] = 03432; code[000076] = &I00076;
  core[000077] = 03432; code[000077] = &P00077;
  core[000100] = 02056; code[000100] = &P00100;
  core[000101] = 00523; code[000101] = &P00101;
  core[000102] = 01556; code[000102] = &P00102;
  core[000103] = 00501; code[000103] = &P00103;
  core[000104] = 00532; code[000104] = &P00104;
  core[000105] = 00550; code[000105] = &P00105;
  core[000106] = 02315; code[000106] = &P00106;
  core[000107] = 03023; code[000107] = &P00107;
  core[000110] = 01333; code[000110] = &P00110;
  core[000111] = 00733; code[000111] = &P00111;
  core[000112] = 02477; code[000112] = &P00112;
  core[000113] = 02463; code[000113] = &P00113;
  core[000114] = 06151; code[000114] = &P00114;
  core[000115] = 00312; code[000115] = &P00115;
  core[000116] = 02265; code[000116] = &P00116;
  core[000117] = 02417; code[000117] = &P00117;
  core[000120] = 00305; code[000120] = &P00120;
  core[000121] = 01524; code[000121] = &P00121;
  core[000122] = 01533; code[000122] = &P00122;
  core[000123] = 02077; code[000123] = &P00123;
  core[000124] = 02451; code[000124] = &P00124;
  core[000125] = 00713; code[000125] = &P00125;
  core[000126] = 02736; code[000126] = &P00126;
  core[000127] = 00000; code[000127] = &P00127;
  core[000130] = 00000; code[000130] = &D00130;
  core[000131] = 00000; code[000131] = &D00131;
  core[000132] = 07760; code[000132] = &P00132;
  core[000133] = 00004; code[000133] = &P00133;
  core[000134] = 03432; code[000134] = &P00134;
  core[000135] = 00000; code[000135] = &D00135;
  core[000136] = 00000; code[000136] = &P00136;
  core[000137] = 02675; code[000137] = &P00137;
  core[000140] = 02665; code[000140] = &P00140;
  core[000141] = 00001; code[000141] = &D00141;
  core[000142] = 00215; code[000142] = &D00142;
  core[000143] = 00000; code[000143] = &D00143;
  core[000144] = 00005; code[000144] = &D00144;
  core[000145] = 01575; code[000145] = &P00145;
  core[000146] = 00000; code[000146] = &P00146;
  core[000147] = 00000; code[000147] = &D00147;
  core[000150] = 00000; code[000150] = &P00150;
  core[000151] = 00001; code[000151] = &P00151;
  core[000152] = 00001; code[000152] = &D00152;
  core[000153] = 00000; code[000153] = &D00153;
  core[000154] = 00000; code[000154] = &P00154;
  core[000155] = 03432; code[000155] = &D00155;
  core[000156] = 00000; code[000156] = &P00156;
  core[000157] = 00000; code[000157] = &P00157;
  core[000160] = 02034; code[000160] = &P00160;
  core[000161] = 02463; code[000161] = &D00161;
  core[000162] = 00000; code[000162] = &D00162;
  core[000163] = 00000; code[000163] = &D00163;
  core[000164] = 00000; code[000164] = &D00164;
  core[000165] = 02514; code[000165] = &P00165;
  core[000176] = 03432; code[000176] = &P00176;
  core[000177] = 07610; code[000177] = &P00177;
  core[000200] = 05576; code[000200] = &I00200;
  core[000201] = 01227; code[000201] = &P00201;
  core[000202] = 03145; code[000202] = &I00202;
  core[000203] = 03151; code[000203] = &I00203;
  core[000204] = 01226; code[000204] = &I00204;
  core[000205] = 03013; code[000205] = &I00205;
  core[000206] = 02152; code[000206] = &I00206;
  core[000207] = 03061; code[000207] = &I00207;
  core[000210] = 01054; code[000210] = &I00210;
  core[000211] = 04512; code[000211] = &I00211;
  core[000212] = 01074; code[000212] = &P00212;
  core[000213] = 03010; code[000213] = &I00213;
  core[000214] = 03136; code[000214] = &I00214;
  core[000215] = 01074; code[000215] = &I00215;
  core[000216] = 03153; code[000216] = &P00216;
  core[000217] = 04513; code[000217] = &L00217;
  core[000220] = 04510; code[000220] = &I00220;
  core[000221] = 00053; code[000221] = &I00221;
  core[000222] = 00510; code[000222] = &I00222;
  core[000223] = 04507; code[000223] = &I00223;
  core[000224] = 05217; code[000224] = &I00224;
  core[000225] = 04000; code[000225] = &D00225;
  core[000226] = 02612; code[000226] = &D00226;
  core[000227] = 01575; code[000227] = &D00227;
  core[000230] = 04507; code[000230] = &L00230;
  core[000231] = 04507; code[000231] = &I00231;
  core[000232] = 01074; code[000232] = &I00232;
  core[000233] = 03017; code[000233] = &L00233;
  core[000234] = 03020; code[000234] = &I00234;
  core[000235] = 04506; code[000235] = &I00235;
  core[000236] = 01027; code[000236] = &I00236;
  core[000237] = 03013; code[000237] = &I00237;
  core[000240] = 04521; code[000240] = &I00240;
  core[000241] = 04522; code[000241] = &I00241;
  core[000242] = 04526; code[000242] = &D00242;
  core[000243] = 05274; code[000243] = &I00243;
  core[000244] = 06002; code[000244] = &I00244;
  core[000245] = 02151; code[000245] = &I00245;
  core[000246] = 04515; code[000246] = &I00246;
  core[000247] = 01141; code[000247] = &I00247;
  core[000250] = 01225; code[000250] = &I00250;
  core[000251] = 07640; code[000251] = &I00251;
  core[000252] = 04526; code[000252] = &I00252;
  core[000253] = 01134; code[000253] = &I00253;
  core[000254] = 03010; code[000254] = &I00254;
  core[000255] = 03136; code[000255] = &D00255;
  core[000256] = 01143; code[000256] = &I00256;
  core[000257] = 03410; code[000257] = &I00257;
  core[000260] = 04521; code[000260] = &I00260;
  core[000261] = 07410; code[000261] = &I00261;
  core[000262] = 04506; code[000262] = &L00262;
  core[000263] = 04507; code[000263] = &I00263;
  core[000264] = 01142; code[000264] = &I00264;
  core[000265] = 01065; code[000265] = &I00265;
  core[000266] = 07640; code[000266] = &I00266;
  core[000267] = 05262; code[000267] = &I00267;
  core[000270] = 04501; code[000270] = &I00270;
  core[000271] = 02111; code[000271] = &I00271;
  core[000272] = 04517; code[000272] = &I00272;
  core[000273] = 05177; code[000273] = &I00273;
  core[000274] = 04501; code[000274] = &L00274;
  core[000275] = 00616; code[000275] = &I00275;
  core[000276] = 01545; code[000276] = &I00276;
  core[000277] = 07450; code[000277] = &D00277;
  core[000300] = 05177; code[000300] = &I00300;
  core[000301] = 03145; code[000301] = &I00301;
  core[000302] = 01145; code[000302] = &I00302;
  core[000303] = 07001; code[000303] = &I00303;
  core[000304] = 05233; code[000304] = &I00304;
  core[000305] = 00000; code[000305] = &S00305;
  core[000306] = 07106; code[000306] = &I00306;
  core[000307] = 07006; code[000307] = &I00307;
  core[000310] = 07006; code[000310] = &I00310;
  core[000311] = 05705; code[000311] = &I00311;
  core[000312] = 00000; code[000312] = &S00312;
  core[000313] = 04521; code[000313] = &I00313;
  core[000314] = 01225; code[000314] = &I00314;
  core[000315] = 03141; code[000315] = &I00315;
  core[000316] = 04511; code[000316] = &D00316;
  core[000317] = 06114; code[000317] = &I00317;
  core[000320] = 05370; code[000320] = &I00320;
  core[000321] = 04766; code[000321] = &I00321;
  core[000322] = 04522; code[000322] = &I00322;
  core[000323] = 04506; code[000323] = &I00323;
  core[000324] = 04356; code[000324] = &I00324;
  core[000325] = 07106; code[000325] = &I00325;
  core[000326] = 01127; code[000326] = &I00326;
  core[000327] = 07004; code[000327] = &I00327;
  core[000330] = 04356; code[000330] = &I00330;
  core[000331] = 01143; code[000331] = &L00331;
  core[000332] = 07450; code[000332] = &L00332;
  core[000333] = 03141; code[000333] = &I00333;
  core[000334] = 03143; code[000334] = &I00334;
  core[000335] = 01164; code[000335] = &I00335;
  core[000336] = 07450; code[000336] = &I00336;
  core[000337] = 05347; code[000337] = &D00337;
  core[000340] = 04520; code[000340] = &I00340;
  core[000341] = 07004; code[000341] = &I00341;
  core[000342] = 01143; code[000342] = &I00342;
  core[000343] = 03143; code[000343] = &I00343;
  core[000344] = 01164; code[000344] = &I00344;
  core[000345] = 00367; code[000345] = &I00345;
  core[000346] = 05351; code[000346] = &I00346;
  core[000347] = 02141; code[000347] = &L00347;
  core[000350] = 01143; code[000350] = &I00350;
  core[000351] = 07650; code[000351] = &L00351;
  core[000352] = 04522; code[000352] = &I00352;
  core[000353] = 05361; code[000353] = &I00353;
  core[000354] = 05712; code[000354] = &I00354;
  core[000355] = 05361; code[000355] = &I00355;
  core[000356] = 00000; code[000356] = &S00356;
  core[000357] = 03143; code[000357] = &I00357;
  core[000360] = 04522; code[000360] = &I00360;
  core[000361] = 04526; code[000361] = &L00361;
  core[000362] = 05331; code[000362] = &I00362;
  core[000363] = 04506; code[000363] = &I00363;
  core[000364] = 01127; code[000364] = &I00364;
  core[000365] = 05756; code[000365] = &I00365;
  core[000366] = 06010; code[000366] = &P00366;
  core[000367] = 07760; code[000367] = &D00367;
  core[000370] = 04501; code[000370] = &L00370;
  core[000371] = 01601; code[000371] = &I00371;
  core[000372] = 04452; code[000372] = &I00372;
  core[000373] = 04503; code[000373] = &I00373;
  core[000374] = 01045; code[000374] = &I00374;
  core[000375] = 07640; code[000375] = &I00375;
  core[000376] = 05361; code[000376] = &I00376;
  core[000377] = 04407; code[000377] = &I00377;
  core[000400] = 07000; code[000400] = &I00400;
  core[000401] = 02560; code[000401] = &I00401;
  core[000402] = 03614; code[000402] = &I00402;
  core[000403] = 03614; code[000403] = &I00403;
  core[000404] = 02615; code[000404] = &I00404;
  core[000405] = 00000; code[000405] = &I00405;
  core[000406] = 04450; code[000406] = &I00406;
  core[000407] = 01413; code[000407] = &I00407;
  core[000410] = 03164; code[000410] = &I00410;
  core[000411] = 04452; code[000411] = &I00411;
  core[000412] = 05613; code[000412] = &D00412;
  core[000413] = 00332; code[000413] = &P00413;
  core[000414] = 05770; code[000414] = &P00414;
  core[000415] = 05773; code[000415] = &P00415;
  core[000416] = 04515; code[000416] = &P00416;
  core[000417] = 01145; code[000417] = &D00417;
  core[000420] = 04503; code[000420] = &I00420;
  core[000421] = 04504; code[000421] = &I00421;
  core[000422] = 00017; code[000422] = &I00422;
  core[000423] = 04504; code[000423] = &L00423;
  core[000424] = 00141; code[000424] = &I00424;
  core[000425] = 01141; code[000425] = &I00425;
  core[000426] = 07710; code[000426] = &I00426;
  core[000427] = 05254; code[000427] = &I00427;
  core[000430] = 04516; code[000430] = &D00430;
  core[000431] = 05273; code[000431] = &I00431;
  core[000432] = 04501; code[000432] = &L00432;
  core[000433] = 00613; code[000433] = &I00433;
  core[000434] = 04505; code[000434] = &I00434;
  core[000435] = 00141; code[000435] = &I00435;
  core[000436] = 01545; code[000436] = &I00436;
  core[000437] = 07450; code[000437] = &I00437;
  core[000440] = 05262; code[000440] = &I00440;
  core[000441] = 07001; code[000441] = &I00441;
  core[000442] = 03154; code[000442] = &I00442;
  core[000443] = 01141; code[000443] = &I00443;
  core[000444] = 07740; code[000444] = &I00444;
  core[000445] = 05251; code[000445] = &I00445;
  core[000446] = 01554; code[000446] = &I00446;
  core[000447] = 04524; code[000447] = &I00447;
  core[000450] = 05262; code[000450] = &I00450;
  core[000451] = 01554; code[000451] = &L00451;
  core[000452] = 03143; code[000452] = &I00452;
  core[000453] = 05223; code[000453] = &I00453;
  core[000454] = 04516; code[000454] = &L00454;
  core[000455] = 04526; code[000455] = &I00455;
  core[000456] = 04501; code[000456] = &I00456;
  core[000457] = 00615; code[000457] = &I00457;
  core[000460] = 04505; code[000460] = &I00460;
  core[000461] = 00141; code[000461] = &I00461;
  core[000462] = 04505; code[000462] = &L00462;
  core[000463] = 00017; code[000463] = &I00463;
  core[000464] = 01413; code[000464] = &I00464;
  core[000465] = 03145; code[000465] = &I00465;
  core[000466] = 04565; code[000466] = &L00466;
  core[000467] = 05266; code[000467] = &I00467;
  core[000470] = 05672; code[000470] = &I00470;
  core[000471] = 05216; code[000471] = &I00471;
  core[000472] = 00616; code[000472] = &P00472;
  core[000473] = 01146; code[000473] = &L00473;
  core[000474] = 03011; code[000474] = &I00474;
  core[000475] = 01411; code[000475] = &I00475;
  core[000476] = 04524; code[000476] = &I00476;
  core[000477] = 04526; code[000477] = &I00477;
  core[000500] = 05232; code[000500] = &I00500;
  core[000501] = 00000; code[000501] = &S00501;
  core[000502] = 03332; code[000502] = &I00502;
  core[000503] = 07040; code[000503] = &I00503;
  core[000504] = 04310; code[000504] = &I00504;
  core[000505] = 01332; code[000505] = &I00505;
  core[000506] = 03416; code[000506] = &I00506;
  core[000507] = 05701; code[000507] = &I00507;
  core[000510] = 00000; code[000510] = &S00510;
  core[000511] = 01013; code[000511] = &I00511;
  core[000512] = 03013; code[000512] = &I00512;
  core[000513] = 01013; code[000513] = &I00513;
  core[000514] = 03016; code[000514] = &I00514;
  core[000515] = 01013; code[000515] = &I00515;
  core[000516] = 07141; code[000516] = &I00516;
  core[000517] = 01155; code[000517] = &I00517;
  core[000520] = 07630; code[000520] = &I00520;
  core[000521] = 04526; code[000521] = &I00521;
  core[000522] = 05710; code[000522] = &I00522;
  core[000523] = 00000; code[000523] = &S00523;
  core[000524] = 07201; code[000524] = &I00524;
  core[000525] = 01323; code[000525] = &I00525;
  core[000526] = 04301; code[000526] = &I00526;
  core[000527] = 01723; code[000527] = &I00527;
  core[000530] = 03323; code[000530] = &I00530;
  core[000531] = 05723; code[000531] = &I00531;
  core[000532] = 00000; code[000532] = &S00532;
  core[000533] = 07240; code[000533] = &I00533;
  core[000534] = 01732; code[000534] = &I00534;
  core[000535] = 03011; code[000535] = &I00535;
  core[000536] = 02332; code[000536] = &I00536;
  core[000537] = 01066; code[000537] = &I00537;
  core[000540] = 04310; code[000540] = &I00540;
  core[000541] = 01411; code[000541] = &I00541;
  core[000542] = 03416; code[000542] = &I00542;
  core[000543] = 01411; code[000543] = &I00543;
  core[000544] = 03416; code[000544] = &I00544;
  core[000545] = 01411; code[000545] = &I00545;
  core[000546] = 03416; code[000546] = &I00546;
  core[000547] = 05732; code[000547] = &I00547;
  core[000550] = 00000; code[000550] = &S00550;
  core[000551] = 07240; code[000551] = &I00551;
  core[000552] = 01750; code[000552] = &I00552;
  core[000553] = 02350; code[000553] = &I00553;
  core[000554] = 03011; code[000554] = &I00554;
  core[000555] = 01413; code[000555] = &I00555;
  core[000556] = 03411; code[000556] = &I00556;
  core[000557] = 01413; code[000557] = &I00557;
  core[000560] = 03411; code[000560] = &I00560;
  core[000561] = 01413; code[000561] = &I00561;
  core[000562] = 03411; code[000562] = &I00562;
  core[000563] = 05750; code[000563] = &I00563;
  core[000564] = 00212; code[000564] = &I00564;
  core[000565] = 00223; code[000565] = &I00565;
  core[000566] = 00223; code[000566] = &I00566;
  core[000567] = 00217; code[000567] = &I00567;
  core[000570] = 00230; code[000570] = &P00570;
  core[000571] = 02053; code[000571] = &I00571;
  core[000572] = 07535; code[000572] = &I00572;
  core[000573] = 01156; code[000573] = &P00573;
  core[000574] = 01145; code[000574] = &I00574;
  core[000575] = 07351; code[000575] = &I00575;
  core[000576] = 01153; code[000576] = &I00576;
  core[000577] = 02414; code[000577] = &I00577;
  core[000600] = 02735; code[000600] = &I00600;
  core[000601] = 02735; code[000601] = &I00601;
  core[000602] = 02735; code[000602] = &I00602;
  core[000603] = 02735; code[000603] = &I00603;
  core[000604] = 02735; code[000604] = &I00604;
  core[000605] = 07462; code[000605] = &I00605;
  core[000606] = 02735; code[000606] = &D00606;
  core[000607] = 07472; code[000607] = &D00607;
  core[000610] = 04515; code[000610] = &L00610;
  core[000611] = 04516; code[000611] = &I00611;
  core[000612] = 04526; code[000612] = &I00612;
  core[000613] = 01146; code[000613] = &I00613;
  core[000614] = 03145; code[000614] = &I00614;
  core[000615] = 04506; code[000615] = &L00615;
  core[000616] = 04511; code[000616] = &L00616;
  core[000617] = 00057; code[000617] = &I00617;
  core[000620] = 05502; code[000620] = &I00620;
  core[000621] = 04511; code[000621] = &I00621;
  core[000622] = 01140; code[000622] = &I00622;
  core[000623] = 05215; code[000623] = &I00623;
  core[000624] = 01142; code[000624] = &I00624;
  core[000625] = 04503; code[000625] = &I00625;
  core[000626] = 04506; code[000626] = &L00626;
  core[000627] = 04511; code[000627] = &I00627;
  core[000630] = 02002; code[000630] = &I00630;
  core[000631] = 07410; code[000631] = &I00631;
  core[000632] = 05226; code[000632] = &I00632;
  core[000633] = 04521; code[000633] = &I00633;
  core[000634] = 01413; code[000634] = &I00634;
  core[000635] = 04510; code[000635] = &I00635;
  core[000636] = 00755; code[000636] = &I00636;
  core[000637] = 00206; code[000637] = &I00637;
  core[000640] = 04526; code[000640] = &I00640;
  core[000641] = 04711; code[000641] = &L00641;
  core[000642] = 04515; code[000642] = &I00642;
  core[000643] = 02151; code[000643] = &I00643;
  core[000644] = 04516; code[000644] = &L00644;
  core[000645] = 05274; code[000645] = &I00645;
  core[000646] = 01143; code[000646] = &I00646;
  core[000647] = 07640; code[000647] = &I00647;
  core[000650] = 04514; code[000650] = &I00650;
  core[000651] = 04506; code[000651] = &L00651;
  core[000652] = 04512; code[000652] = &I00652;
  core[000653] = 01142; code[000653] = &I00653;
  core[000654] = 01065; code[000654] = &I00654;
  core[000655] = 07640; code[000655] = &I00655;
  core[000656] = 05251; code[000656] = &I00656;
  core[000657] = 01546; code[000657] = &I00657;
  core[000660] = 07450; code[000660] = &L00660;
  core[000661] = 05303; code[000661] = &I00661;
  core[000662] = 07001; code[000662] = &I00662;
  core[000663] = 03154; code[000663] = &I00663;
  core[000664] = 01141; code[000664] = &I00664;
  core[000665] = 07700; code[000665] = &I00665;
  core[000666] = 01554; code[000666] = &I00666;
  core[000667] = 04524; code[000667] = &I00667;
  core[000670] = 05276; code[000670] = &I00670;
  core[000671] = 01554; code[000671] = &L00671;
  core[000672] = 03143; code[000672] = &I00672;
  core[000673] = 05244; code[000673] = &I00673;
  core[000674] = 01146; code[000674] = &L00674;
  core[000675] = 05260; code[000675] = &I00675;
  core[000676] = 01141; code[000676] = &L00676;
  core[000677] = 07750; code[000677] = &I00677;
  core[000700] = 05303; code[000700] = &I00700;
  core[000701] = 04512; code[000701] = &D00701;
  core[000702] = 05271; code[000702] = &I00702;
  core[000703] = 04712; code[000703] = &L00703;
  core[000704] = 03151; code[000704] = &D00704;
  core[000705] = 04565; code[000705] = &L00705;
  core[000706] = 05305; code[000706] = &D00706;
  core[000707] = 05216; code[000707] = &D00707;
  core[000710] = 05241; code[000710] = &D00710;
  core[000711] = 02435; code[000711] = &P00711;
  core[000712] = 02443; code[000712] = &P00712;
  core[000713] = 00000; code[000713] = &S00713;
  core[000714] = 04521; code[000714] = &D00714;
  core[000715] = 04511; code[000715] = &D00715;
  core[000716] = 02005; code[000716] = &I00716;
  core[000717] = 05713; code[000717] = &D00717;
  core[000720] = 02313; code[000720] = &I00720;
  core[000721] = 04522; code[000721] = &D00721;
  core[000722] = 05713; code[000722] = &D00722;
  core[000723] = 07410; code[000723] = &D00723;
  core[000724] = 05713; code[000724] = &D00724;
  core[000725] = 01142; code[000725] = &I00725;
  core[000726] = 01207; code[000726] = &I00726;
  core[000727] = 07640; code[000727] = &D00727;
  core[000730] = 02313; code[000730] = &I00730;
  core[000731] = 02313; code[000731] = &I00731;
  core[000732] = 05713; code[000732] = &I00732;
  core[000733] = 00000; code[000733] = &S00733;
  core[000734] = 01733; code[000734] = &I00734;
  core[000735] = 03012; code[000735] = &P00735;
  core[000736] = 01412; code[000736] = &L00736;
  core[000737] = 07510; code[000737] = &I00737;
  core[000740] = 05352; code[000740] = &I00740;
  core[000741] = 07041; code[000741] = &I00741;
  core[000742] = 01142; code[000742] = &I00742;
  core[000743] = 07640; code[000743] = &I00743;
  core[000744] = 05336; code[000744] = &I00744;
  core[000745] = 01733; code[000745] = &I00745;
  core[000746] = 07040; code[000746] = &I00746;
  core[000747] = 01012; code[000747] = &I00747;
  core[000750] = 03127; code[000750] = &I00750;
  core[000751] = 07410; code[000751] = &I00751;
  core[000752] = 02333; code[000752] = &L00752;
  core[000753] = 02333; code[000753] = &I00753;
  core[000754] = 07300; code[000754] = &I00754;
  core[000755] = 05733; code[000755] = &P00755;
  core[000756] = 00323; code[000756] = &I00756;
  core[000757] = 00306; code[000757] = &I00757;
  core[000760] = 00311; code[000760] = &I00760;
  core[000761] = 00304; code[000761] = &I00761;
  core[000762] = 00307; code[000762] = &I00762;
  core[000763] = 00303; code[000763] = &I00763;
  core[000764] = 00301; code[000764] = &I00764;
  core[000765] = 00324; code[000765] = &I00765;
  core[000766] = 00314; code[000766] = &I00766;
  core[000767] = 00305; code[000767] = &I00767;
  core[000770] = 00327; code[000770] = &I00770;
  core[000771] = 00315; code[000771] = &I00771;
  core[000772] = 00321; code[000772] = &I00772;
  core[000773] = 00322; code[000773] = &I00773;
  core[000774] = 00317; code[000774] = &I00774;
  core[000775] = 00310; code[000775] = &I00775;
  core[000776] = 04511; code[000776] = &I00776;
  core[000777] = 01022; code[000777] = &I00777;
  core[001000] = 07410; code[001000] = &P01000;
  core[001001] = 04526; code[001001] = &P01001;
  core[001002] = 04501; code[001002] = &I01002;
  core[001003] = 01600; code[001003] = &I01003;
  core[001004] = 04506; code[001004] = &L01004;
  core[001005] = 01045; code[001005] = &I01005;
  core[001006] = 07710; code[001006] = &D01006;
  core[001007] = 05622; code[001007] = &D01007;
  core[001010] = 04565; code[001010] = &P01010;
  core[001011] = 05210; code[001011] = &I01011;
  core[001012] = 05703; code[001012] = &I01012;
  core[001013] = 01045; code[001013] = &I01013;
  core[001014] = 07650; code[001014] = &I01014;
  core[001015] = 05622; code[001015] = &D01015;
  core[001016] = 04565; code[001016] = &P01016;
  core[001017] = 05216; code[001017] = &I01017;
  core[001020] = 05703; code[001020] = &P01020;
  core[001021] = 05622; code[001021] = &I01021;
  core[001022] = 00610; code[001022] = &P01022;
  core[001023] = 00250; code[001023] = &I01023;
  core[001024] = 04501; code[001024] = &I01024;
  core[001025] = 01404; code[001025] = &I01025;
  core[001026] = 04521; code[001026] = &D01026;
  core[001027] = 04511; code[001027] = &I01027;
  core[001030] = 02024; code[001030] = &I01030;
  core[001031] = 07410; code[001031] = &I01031;
  core[001032] = 04526; code[001032] = &I01032;
  core[001033] = 01154; code[001033] = &I01033;
  core[001034] = 03332; code[001034] = &I01034;
  core[001035] = 04501; code[001035] = &I01035;
  core[001036] = 01600; code[001036] = &I01036;
  core[001037] = 04407; code[001037] = &I01037;
  core[001040] = 06732; code[001040] = &D01040;
  core[001041] = 00000; code[001041] = &P01041;
  core[001042] = 04565; code[001042] = &D01042;
  core[001043] = 04526; code[001043] = &D01043;
  core[001044] = 05703; code[001044] = &L01044;
  core[001045] = 01332; code[001045] = &D01045;
  core[001046] = 04503; code[001046] = &D01046;
  core[001047] = 04501; code[001047] = &I01047;
  core[001050] = 01601; code[001050] = &D01050;
  core[001051] = 04565; code[001051] = &I01051;
  core[001052] = 04526; code[001052] = &D01052;
  core[001053] = 05317; code[001053] = &I01053;
  core[001054] = 04504; code[001054] = &D01054;
  core[001055] = 02034; code[001055] = &I01055;
  core[001056] = 04501; code[001056] = &I01056;
  core[001057] = 01601; code[001057] = &I01057;
  core[001060] = 04504; code[001060] = &L01060;
  core[001061] = 02034; code[001061] = &I01061;
  core[001062] = 04724; code[001062] = &I01062;
  core[001063] = 04430; code[001063] = &I01063;
  core[001064] = 04407; code[001064] = &L01064;
  core[001065] = 01732; code[001065] = &I01065;
  core[001066] = 06732; code[001066] = &I01066;
  core[001067] = 02560; code[001067] = &I01067;
  core[001070] = 00000; code[001070] = &I01070;
  core[001071] = 01013; code[001071] = &I01071;
  core[001072] = 01322; code[001072] = &I01072;
  core[001073] = 03332; code[001073] = &D01073;
  core[001074] = 01732; code[001074] = &D01074;
  core[001075] = 07710; code[001075] = &I01075;
  core[001076] = 04450; code[001076] = &I01076;
  core[001077] = 01045; code[001077] = &I01077;
  core[001100] = 07740; code[001100] = &I01100;
  core[001101] = 05326; code[001101] = &I01101;
  core[001102] = 04501; code[001102] = &I01102;
  core[001103] = 00616; code[001103] = &P01103;
  core[001104] = 04725; code[001104] = &I01104;
  core[001105] = 04505; code[001105] = &I01105;
  core[001106] = 02034; code[001106] = &I01106;
  core[001107] = 04505; code[001107] = &I01107;
  core[001110] = 00044; code[001110] = &I01110;
  core[001111] = 01413; code[001111] = &I01111;
  core[001112] = 03332; code[001112] = &I01112;
  core[001113] = 01323; code[001113] = &I01113;
  core[001114] = 01013; code[001114] = &I01114;
  core[001115] = 03013; code[001115] = &I01115;
  core[001116] = 05264; code[001116] = &I01116;
  core[001117] = 04504; code[001117] = &L01117;
  core[001120] = 01573; code[001120] = &I01120;
  core[001121] = 05260; code[001121] = &I01121;
  core[001122] = 00011; code[001122] = &D01122;
  core[001123] = 07765; code[001123] = &D01123;
  core[001124] = 02435; code[001124] = &P01124;
  core[001125] = 02443; code[001125] = &P01125;
  core[001126] = 01005; code[001126] = &L01126;
  core[001127] = 01013; code[001127] = &I01127;
  core[001130] = 03013; code[001130] = &I01130;
  core[001131] = 05502; code[001131] = &I01131;
  core[001132] = 00000; code[001132] = &P01132;
  core[001133] = 00246; code[001133] = &I01133;
  core[001134] = 00245; code[001134] = &D01134;
  core[001135] = 00242; code[001135] = &P01135;
  core[001136] = 00241; code[001136] = &I01136;
  core[001137] = 00243; code[001137] = &I01137;
  core[001140] = 00244; code[001140] = &I01140;
  core[001141] = 00240; code[001141] = &I01141;
  core[001142] = 00254; code[001142] = &D01142;
  core[001143] = 00273; code[001143] = &I01143;
  core[001144] = 00215; code[001144] = &I01144;
  core[001145] = 04452; code[001145] = &I01145;
  core[001146] = 06063; code[001146] = &I01146;
  core[001147] = 07200; code[001147] = &I01147;
  core[001150] = 01361; code[001150] = &I01150;
  core[001151] = 06053; code[001151] = &I01151;
  core[001152] = 07410; code[001152] = &I01152;
  core[001153] = 04452; code[001153] = &I01153;
  core[001154] = 03361; code[001154] = &I01154;
  core[001155] = 05500; code[001155] = &I01155;
  core[001156] = 04452; code[001156] = &L01156;
  core[001157] = 07200; code[001157] = &I01157;
  core[001160] = 05500; code[001160] = &I01160;
  core[001161] = 00000; code[001161] = &D01161;
  core[001162] = 01252; code[001162] = &L01162;
  core[001163] = 01210; code[001163] = &I01163;
  core[001164] = 01024; code[001164] = &I01164;
  core[001165] = 01024; code[001165] = &I01165;
  core[001166] = 00776; code[001166] = &I01166;
  core[001167] = 00416; code[001167] = &I01167;
  core[001170] = 00610; code[001170] = &I01170;
  core[001171] = 00620; code[001171] = &I01171;
  core[001172] = 01206; code[001172] = &I01172;
  core[001173] = 01207; code[001173] = &I01173;
  core[001174] = 02735; code[001174] = &I01174;
  core[001175] = 02226; code[001175] = &I01175;
  core[001176] = 00641; code[001176] = &P01176;
  core[001177] = 01273; code[001177] = &I01177;
  core[001200] = 00177; code[001200] = &P01200;
  core[001201] = 01554; code[001201] = &P01201;
  core[001202] = 06446; code[001202] = &I01202;
  core[001203] = 03274; code[001203] = &I01203;
  core[001204] = 03040; code[001204] = &I01204;
  core[001205] = 03065; code[001205] = &I01205;
  core[001206] = 07240; code[001206] = &L01206;
  core[001207] = 03131; code[001207] = &L01207;
  core[001210] = 03151; code[001210] = &L01210;
  core[001211] = 04510; code[001211] = &I01211;
  core[001212] = 01132; code[001212] = &I01212;
  core[001213] = 00426; code[001213] = &I01213;
  core[001214] = 02131; code[001214] = &I01214;
  core[001215] = 05227; code[001215] = &I01215;
  core[001216] = 04501; code[001216] = &I01216;
  core[001217] = 01404; code[001217] = &I01217;
  core[001220] = 04636; code[001220] = &I01220;
  core[001221] = 01233; code[001221] = &I01221;
  core[001222] = 04512; code[001222] = &D01222;
  core[001223] = 04626; code[001223] = &I01223;
  core[001224] = 04637; code[001224] = &I01224;
  core[001225] = 05206; code[001225] = &I01225;
  core[001226] = 03306; code[001226] = &P01226;
  core[001227] = 04501; code[001227] = &L01227;
  core[001230] = 01601; code[001230] = &I01230;
  core[001231] = 04565; code[001231] = &I01231;
  core[001232] = 04526; code[001232] = &I01232;
  core[001233] = 00272; code[001233] = &D01233;
  core[001234] = 04640; code[001234] = &I01234;
  core[001235] = 05207; code[001235] = &L01235;
  core[001236] = 02435; code[001236] = &P01236;
  core[001237] = 02443; code[001237] = &P01237;
  core[001240] = 03365; code[001240] = &P01240;
  core[001241] = 02151; code[001241] = &I01241;
  core[001242] = 04506; code[001242] = &L01242;
  core[001243] = 04510; code[001243] = &I01243;
  core[001244] = 01404; code[001244] = &I01244;
  core[001245] = 07555; code[001245] = &I01245;
  core[001246] = 04512; code[001246] = &I01246;
  core[001247] = 05242; code[001247] = &I01247;
  core[001250] = 01060; code[001250] = &I01250;
  core[001251] = 04512; code[001251] = &L01251;
  core[001252] = 04506; code[001252] = &L01252;
  core[001253] = 05210; code[001253] = &I01253;
  core[001254] = 01060; code[001254] = &I01254;
  core[001255] = 04537; code[001255] = &I01255;
  core[001256] = 01015; code[001256] = &I01256;
  core[001257] = 05251; code[001257] = &I01257;
  core[001260] = 04506; code[001260] = &I01260;
  core[001261] = 04672; code[001261] = &I01261;
  core[001262] = 01164; code[001262] = &I01262;
  core[001263] = 03051; code[001263] = &I01263;
  core[001264] = 04522; code[001264] = &I01264;
  core[001265] = 04506; code[001265] = &I01265;
  core[001266] = 04672; code[001266] = &I01266;
  core[001267] = 01164; code[001267] = &I01267;
  core[001270] = 03133; code[001270] = &I01270;
  core[001271] = 05210; code[001271] = &I01271;
  core[001272] = 06010; code[001272] = &P01272;
  core[001273] = 04515; code[001273] = &I01273;
  core[001274] = 04516; code[001274] = &D01274;
  core[001275] = 04526; code[001275] = &L01275;
  core[001276] = 01134; code[001276] = &I01276;
  core[001277] = 03010; code[001277] = &I01277;
  core[001300] = 03136; code[001300] = &I01300;
  core[001301] = 01143; code[001301] = &I01301;
  core[001302] = 07450; code[001302] = &I01302;
  core[001303] = 05275; code[001303] = &I01303;
  core[001304] = 03410; code[001304] = &I01304;
  core[001305] = 01010; code[001305] = &I01305;
  core[001306] = 03153; code[001306] = &D01306;
  core[001307] = 04540; code[001307] = &D01307;
  core[001310] = 03061; code[001310] = &I01310;
  core[001311] = 02151; code[001311] = &I01311;
  core[001312] = 04506; code[001312] = &L01312;
  core[001313] = 04512; code[001313] = &I01313;
  core[001314] = 04510; code[001314] = &I01314;
  core[001315] = 00057; code[001315] = &I01315;
  core[001316] = 01322; code[001316] = &I01316;
  core[001317] = 04507; code[001317] = &I01317;
  core[001320] = 05312; code[001320] = &I01320;
  core[001321] = 01134; code[001321] = &D01321;
  core[001322] = 07001; code[001322] = &D01322;
  core[001323] = 03010; code[001323] = &I01323;
  core[001324] = 03136; code[001324] = &I01324;
  core[001325] = 04513; code[001325] = &L01325;
  core[001326] = 04510; code[001326] = &I01326;
  core[001327] = 00053; code[001327] = &I01327;
  core[001330] = 01322; code[001330] = &I01330;
  core[001331] = 04507; code[001331] = &I01331;
  core[001332] = 05325; code[001332] = &I01332;
  core[001333] = 00000; code[001333] = &S01333;
  core[001334] = 07450; code[001334] = &I01334;
  core[001335] = 01142; code[001335] = &I01335;
  core[001336] = 07041; code[001336] = &I01336;
  core[001337] = 03157; code[001337] = &I01337;
  core[001340] = 01733; code[001340] = &I01340;
  core[001341] = 02333; code[001341] = &I01341;
  core[001342] = 03012; code[001342] = &I01342;
  core[001343] = 01412; code[001343] = &L01343;
  core[001344] = 07510; code[001344] = &I01344;
  core[001345] = 05357; code[001345] = &I01345;
  core[001346] = 01157; code[001346] = &I01346;
  core[001347] = 07640; code[001347] = &I01347;
  core[001350] = 05343; code[001350] = &I01350;
  core[001351] = 01012; code[001351] = &I01351;
  core[001352] = 01733; code[001352] = &I01352;
  core[001353] = 03333; code[001353] = &I01353;
  core[001354] = 01733; code[001354] = &I01354;
  core[001355] = 03333; code[001355] = &I01355;
  core[001356] = 07410; code[001356] = &I01356;
  core[001357] = 02333; code[001357] = &L01357;
  core[001360] = 07300; code[001360] = &I01360;
  core[001361] = 05733; code[001361] = &I01361;
  core[001362] = 04501; code[001362] = &I01362;
  core[001363] = 01600; code[001363] = &I01363;
  core[001364] = 04452; code[001364] = &I01364;
  core[001365] = 07141; code[001365] = &L01365;
  core[001366] = 07001; code[001366] = &I01366;
  core[001367] = 01053; code[001367] = &I01367;
  core[001370] = 07630; code[001370] = &I01370;
  core[001371] = 05210; code[001371] = &I01371;
  core[001372] = 01033; code[001372] = &I01372;
  core[001373] = 04512; code[001373] = &I01373;
  core[001374] = 01046; code[001374] = &I01374;
  core[001375] = 05365; code[001375] = &I01375;
  core[001376] = 01321; code[001376] = &I01376;
  core[001377] = 01312; code[001377] = &I01377;
  core[001400] = 01307; code[001400] = &P01400;
  core[001401] = 01310; code[001401] = &I01401;
  core[001402] = 00263; code[001402] = &I01402;
  core[001403] = 01331; code[001403] = &I01403;
  core[001404] = 04525; code[001404] = &I01404;
  core[001405] = 00242; code[001405] = &I01405;
  core[001406] = 00215; code[001406] = &I01406;
  core[001407] = 04526; code[001407] = &I01407;
  core[001410] = 07240; code[001410] = &I01410;
  core[001411] = 04503; code[001411] = &I01411;
  core[001412] = 03136; code[001412] = &I01412;
  core[001413] = 04507; code[001413] = &I01413;
  core[001414] = 04506; code[001414] = &I01414;
  core[001415] = 04511; code[001415] = &P01415;
  core[001416] = 02005; code[001416] = &I01416;
  core[001417] = 05222; code[001417] = &I01417;
  core[001420] = 01142; code[001420] = &P01420;
  core[001421] = 00071; code[001421] = &I01421;
  core[001422] = 01135; code[001422] = &L01422;
  core[001423] = 04503; code[001423] = &I01423;
  core[001424] = 04511; code[001424] = &L01424;
  core[001425] = 02005; code[001425] = &I01425;
  core[001426] = 05231; code[001426] = &I01426;
  core[001427] = 04506; code[001427] = &I01427;
  core[001430] = 05224; code[001430] = &I01430;
  core[001431] = 04523; code[001431] = &L01431;
  core[001432] = 05243; code[001432] = &I01432;
  core[001433] = 01130; code[001433] = &I01433;
  core[001434] = 04503; code[001434] = &I01434;
  core[001435] = 04501; code[001435] = &I01435;
  core[001436] = 01600; code[001436] = &I01436;
  core[001437] = 04506; code[001437] = &I01437;
  core[001440] = 01413; code[001440] = &I01440;
  core[001441] = 03130; code[001441] = &D01441;
  core[001442] = 04452; code[001442] = &D01442;
  core[001443] = 03324; code[001443] = &L01443;
  core[001444] = 01413; code[001444] = &I01444;
  core[001445] = 03135; code[001445] = &I01445;
  core[001446] = 01134; code[001446] = &I01446;
  core[001447] = 03154; code[001447] = &L01447;
  core[001450] = 01154; code[001450] = &D01450;
  core[001451] = 03011; code[001451] = &I01451;
  core[001452] = 01154; code[001452] = &D01452;
  core[001453] = 07041; code[001453] = &I01453;
  core[001454] = 01155; code[001454] = &D01454;
  core[001455] = 07750; code[001455] = &I01455;
  core[001456] = 05267; code[001456] = &I01456;
  core[001457] = 01554; code[001457] = &I01457;
  core[001460] = 07041; code[001460] = &D01460;
  core[001461] = 01135; code[001461] = &I01461;
  core[001462] = 07650; code[001462] = &I01462;
  core[001463] = 05312; code[001463] = &D01463;
  core[001464] = 01154; code[001464] = &L01464;
  core[001465] = 01144; code[001465] = &I01465;
  core[001466] = 05247; code[001466] = &I01466;
  core[001467] = 02413; code[001467] = &L01467;
  core[001470] = 04526; code[001470] = &I01470;
  core[001471] = 01155; code[001471] = &I01471;
  core[001472] = 01005; code[001472] = &I01472;
  core[001473] = 07141; code[001473] = &I01473;
  core[001474] = 01013; code[001474] = &I01474;
  core[001475] = 07620; code[001475] = &I01475;
  core[001476] = 04526; code[001476] = &I01476;
  core[001477] = 01155; code[001477] = &I01477;
  core[001500] = 01144; code[001500] = &I01500;
  core[001501] = 03155; code[001501] = &I01501;
  core[001502] = 01135; code[001502] = &I01502;
  core[001503] = 03554; code[001503] = &I01503;
  core[001504] = 01324; code[001504] = &I01504;
  core[001505] = 03411; code[001505] = &I01505;
  core[001506] = 03411; code[001506] = &I01506;
  core[001507] = 03411; code[001507] = &D01507;
  core[001510] = 03411; code[001510] = &D01510;
  core[001511] = 05320; code[001511] = &I01511;
  core[001512] = 01411; code[001512] = &L01512;
  core[001513] = 07041; code[001513] = &I01513;
  core[001514] = 01324; code[001514] = &I01514;
  core[001515] = 07640; code[001515] = &I01515;
  core[001516] = 05264; code[001516] = &I01516;
  core[001517] = 02013; code[001517] = &I01517;
  core[001520] = 02154; code[001520] = &L01520;
  core[001521] = 02154; code[001521] = &I01521;
  core[001522] = 05502; code[001522] = &I01522;
  core[001523] = 01575; code[001523] = &D01523;
  core[001524] = 00000; code[001524] = &S01524;
  core[001525] = 01142; code[001525] = &L01525;
  core[001526] = 01063; code[001526] = &I01526;
  core[001527] = 07640; code[001527] = &I01527;
  core[001530] = 05724; code[001530] = &I01530;
  core[001531] = 04506; code[001531] = &D01531;
  core[001532] = 05325; code[001532] = &I01532;
  core[001533] = 00000; code[001533] = &S01533;
  core[001534] = 01142; code[001534] = &I01534;
  core[001535] = 01064; code[001535] = &I01535;
  core[001536] = 07440; code[001536] = &I01536;
  core[001537] = 02333; code[001537] = &I01537;
  core[001540] = 01352; code[001540] = &I01540;
  core[001541] = 07500; code[001541] = &I01541;
  core[001542] = 05350; code[001542] = &I01542;
  core[001543] = 01353; code[001543] = &I01543;
  core[001544] = 07510; code[001544] = &I01544;
  core[001545] = 05350; code[001545] = &I01545;
  core[001546] = 03127; code[001546] = &I01546;
  core[001547] = 02333; code[001547] = &I01547;
  core[001550] = 07300; code[001550] = &L01550;
  core[001551] = 05733; code[001551] = &D01551;
  core[001552] = 07764; code[001552] = &D01552;
  core[001553] = 00012; code[001553] = &D01553;
  core[001554] = 01323; code[001554] = &D01554;
  core[001555] = 03145; code[001555] = &I01555;
  core[001556] = 01413; code[001556] = &L01556;
  core[001557] = 03157; code[001557] = &I01557;
  core[001560] = 05557; code[001560] = &I01560;
  core[001561] = 01362; code[001561] = &I01561;
  core[001562] = 01260; code[001562] = &D01562;
  core[001563] = 01241; code[001563] = &I01563;
  core[001564] = 01250; code[001564] = &I01564;
  core[001565] = 01254; code[001565] = &I01565;
  core[001566] = 03125; code[001566] = &I01566;
  core[001567] = 01252; code[001567] = &I01567;
  core[001570] = 01252; code[001570] = &I01570;
  core[001571] = 00615; code[001571] = &I01571;
  core[001572] = 00620; code[001572] = &I01572;
  core[001573] = 00001; code[001573] = &D01573;
  core[001574] = 02000; code[001574] = &I01574;
  core[001575] = 00000; code[001575] = &D01575;
  core[001576] = 00000; code[001576] = &I01576;
  core[001577] = 00000; code[001577] = &I01577;
  core[001600] = 04506; code[001600] = &P01600;
  core[001601] = 03130; code[001601] = &I01601;
  core[001602] = 04525; code[001602] = &I01602;
  core[001603] = 05215; code[001603] = &I01603;
  core[001604] = 05332; code[001604] = &I01604;
  core[001605] = 05342; code[001605] = &I01605;
  core[001606] = 04501; code[001606] = &L01606;
  core[001607] = 01411; code[001607] = &I01607;
  core[001610] = 04525; code[001610] = &L01610;
  core[001611] = 05236; code[001611] = &I01611;
  core[001612] = 00212; code[001612] = &D01612;
  core[001613] = 00377; code[001613] = &I01613;
  core[001614] = 04526; code[001614] = &I01614;
  core[001615] = 04504; code[001615] = &L01615;
  core[001616] = 01575; code[001616] = &I01616;
  core[001617] = 04505; code[001617] = &I01617;
  core[001620] = 02034; code[001620] = &I01620;
  core[001621] = 01160; code[001621] = &I01621;
  core[001622] = 03154; code[001622] = &I01622;
  core[001623] = 01034; code[001623] = &I01623;
  core[001624] = 01127; code[001624] = &I01624;
  core[001625] = 07450; code[001625] = &I01625;
  core[001626] = 05241; code[001626] = &I01626;
  core[001627] = 07001; code[001627] = &I01627;
  core[001630] = 07650; code[001630] = &I01630;
  core[001631] = 05323; code[001631] = &I01631;
  core[001632] = 01127; code[001632] = &I01632;
  core[001633] = 01070; code[001633] = &D01633;
  core[001634] = 07710; code[001634] = &I01634;
  core[001635] = 05353; code[001635] = &I01635;
  core[001636] = 04523; code[001636] = &L01636;
  core[001637] = 07410; code[001637] = &I01637;
  core[001640] = 04526; code[001640] = &I01640;
  core[001641] = 01127; code[001641] = &L01641;
  core[001642] = 03147; code[001642] = &I01642;
  core[001643] = 01147; code[001643] = &I01643;
  core[001644] = 01070; code[001644] = &I01644;
  core[001645] = 07700; code[001645] = &I01645;
  core[001646] = 03147; code[001646] = &I01646;
  core[001647] = 07201; code[001647] = &L01647;
  core[001650] = 00147; code[001650] = &I01650;
  core[001651] = 01147; code[001651] = &I01651;
  core[001652] = 07041; code[001652] = &I01652;
  core[001653] = 03274; code[001653] = &I01653;
  core[001654] = 07001; code[001654] = &I01654;
  core[001655] = 00130; code[001655] = &I01655;
  core[001656] = 01130; code[001656] = &I01656;
  core[001657] = 01274; code[001657] = &I01657;
  core[001660] = 07710; code[001660] = &I01660;
  core[001661] = 05310; code[001661] = &I01661;
  core[001662] = 01130; code[001662] = &I01662;
  core[001663] = 01331; code[001663] = &I01663;
  core[001664] = 03274; code[001664] = &I01664;
  core[001665] = 01674; code[001665] = &I01665;
  core[001666] = 03274; code[001666] = &I01666;
  core[001667] = 01130; code[001667] = &I01667;
  core[001670] = 07640; code[001670] = &I01670;
  core[001671] = 04505; code[001671] = &I01671;
  core[001672] = 00044; code[001672] = &I01672;
  core[001673] = 04407; code[001673] = &I01673;
  core[001674] = 00000; code[001674] = &P01674;
  core[001675] = 06560; code[001675] = &I01675;
  core[001676] = 00000; code[001676] = &I01676;
  core[001677] = 01160; code[001677] = &I01677;
  core[001700] = 03154; code[001700] = &I01700;
  core[001701] = 01147; code[001701] = &I01701;
  core[001702] = 01130; code[001702] = &I01702;
  core[001703] = 07650; code[001703] = &I01703;
  core[001704] = 05502; code[001704] = &I01704;
  core[001705] = 01413; code[001705] = &I01705;
  core[001706] = 03130; code[001706] = &I01706;
  core[001707] = 05247; code[001707] = &I01707;
  core[001710] = 04523; code[001710] = &L01710;
  core[001711] = 07410; code[001711] = &I01711;
  core[001712] = 05355; code[001712] = &I01712;
  core[001713] = 01130; code[001713] = &I01713;
  core[001714] = 04503; code[001714] = &I01714;
  core[001715] = 01154; code[001715] = &I01715;
  core[001716] = 03320; code[001716] = &I01716;
  core[001717] = 04504; code[001717] = &I01717;
  core[001720] = 00000; code[001720] = &D01720;
  core[001721] = 01147; code[001721] = &I01721;
  core[001722] = 03130; code[001722] = &I01722;
  core[001723] = 04506; code[001723] = &L01723;
  core[001724] = 04525; code[001724] = &I01724;
  core[001725] = 05353; code[001725] = &I01725;
  core[001726] = 05332; code[001726] = &I01726;
  core[001727] = 05342; code[001727] = &I01727;
  core[001730] = 05206; code[001730] = &I01730;
  core[001731] = 02026; code[001731] = &D01731;
  core[001732] = 04504; code[001732] = &L01732;
  core[001733] = 00044; code[001733] = &I01733;
  core[001734] = 01160; code[001734] = &I01734;
  core[001735] = 03154; code[001735] = &I01735;
  core[001736] = 04473; code[001736] = &I01736;
  core[001737] = 04505; code[001737] = &I01737;
  core[001740] = 00044; code[001740] = &I01740;
  core[001741] = 05210; code[001741] = &I01741;
  core[001742] = 03274; code[001742] = &L01742;
  core[001743] = 04506; code[001743] = &I01743;
  core[001744] = 04511; code[001744] = &I01744;
  core[001745] = 02005; code[001745] = &I01745;
  core[001746] = 05364; code[001746] = &I01746;
  core[001747] = 01274; code[001747] = &I01747;
  core[001750] = 07104; code[001750] = &I01750;
  core[001751] = 01142; code[001751] = &I01751;
  core[001752] = 05342; code[001752] = &I01752;
  core[001753] = 04523; code[001753] = &L01753;
  core[001754] = 04526; code[001754] = &I01754;
  core[001755] = 01127; code[001755] = &L01755;
  core[001756] = 04503; code[001756] = &I01756;
  core[001757] = 01130; code[001757] = &I01757;
  core[001760] = 04503; code[001760] = &I01760;
  core[001761] = 04501; code[001761] = &I01761;
  core[001762] = 01600; code[001762] = &I01762;
  core[001763] = 05500; code[001763] = &I01763;
  core[001764] = 01127; code[001764] = &L01764;
  core[001765] = 04503; code[001765] = &I01765;
  core[001766] = 01130; code[001766] = &I01766;
  core[001767] = 04503; code[001767] = &I01767;
  core[001770] = 01274; code[001770] = &I01770;
  core[001771] = 04503; code[001771] = &I01771;
  core[001772] = 04523; code[001772] = &I01772;
  core[001773] = 04526; code[001773] = &I01773;
  core[001774] = 04501; code[001774] = &I01774;
  core[001775] = 01600; code[001775] = &I01775;
  core[001776] = 01413; code[001776] = &I01776;
  core[001777] = 04510; code[001777] = &D01777;
  core[002000] = 02207; code[002000] = &I02000;
  core[002001] = 06361; code[002001] = &I02001;
  core[002002] = 04526; code[002002] = &I02002;
  core[002003] = 00241; code[002003] = &D02003;
  core[002004] = 00242; code[002004] = &I02004;
  core[002005] = 00256; code[002005] = &I02005;
  core[002006] = 00240; code[002006] = &I02006;
  core[002007] = 00253; code[002007] = &D02007;
  core[002010] = 00255; code[002010] = &P02010;
  core[002011] = 00257; code[002011] = &I02011;
  core[002012] = 00252; code[002012] = &I02012;
  core[002013] = 00336; code[002013] = &I02013;
  core[002014] = 00250; code[002014] = &I02014;
  core[002015] = 00333; code[002015] = &D02015;
  core[002016] = 00274; code[002016] = &I02016;
  core[002017] = 00251; code[002017] = &I02017;
  core[002020] = 00335; code[002020] = &I02020;
  core[002021] = 00276; code[002021] = &I02021;
  core[002022] = 00254; code[002022] = &I02022;
  core[002023] = 00273; code[002023] = &I02023;
  core[002024] = 00215; code[002024] = &I02024;
  core[002025] = 00275; code[002025] = &I02025;
  core[002026] = 05554; code[002026] = &I02026;
  core[002027] = 01554; code[002027] = &I02027;
  core[002030] = 02554; code[002030] = &I02030;
  core[002031] = 04554; code[002031] = &I02031;
  core[002032] = 03554; code[002032] = &I02032;
  core[002033] = 00554; code[002033] = &I02033;
  core[002034] = 00000; code[002034] = &D02034;
  core[002035] = 00000; code[002035] = &I02035;
  core[002036] = 00000; code[002036] = &I02036;
  core[002037] = 07056; code[002037] = &D02037;
  core[002040] = 06473; code[002040] = &D02040;
  core[002041] = 01740; code[002041] = &D02041;
  core[002042] = 01354; code[002042] = &D02042;
  core[002043] = 02454; code[002043] = &I02043;
  core[002044] = 01154; code[002044] = &I02044;
  core[002045] = 00554; code[002045] = &I02045;
  core[002046] = 07254; code[002046] = &I02046;
  core[002047] = 02373; code[002047] = &I02047;
  core[002050] = 00540; code[002050] = &D02050;
  core[002051] = 00177; code[002051] = &D02051;
  core[002052] = 01500; code[002052] = &D02052;
  core[002053] = 01045; code[002053] = &D02053;
  core[002054] = 07710; code[002054] = &D02054;
  core[002055] = 04450; code[002055] = &D02055;
  core[002056] = 01413; code[002056] = &L02056;
  core[002057] = 03130; code[002057] = &D02057;
  core[002060] = 04407; code[002060] = &I02060;
  core[002061] = 07000; code[002061] = &I02061;
  core[002062] = 06234; code[002062] = &I02062;
  core[002063] = 00000; code[002063] = &I02063;
  core[002064] = 01160; code[002064] = &I02064;
  core[002065] = 03154; code[002065] = &I02065;
  core[002066] = 01413; code[002066] = &I02066;
  core[002067] = 07041; code[002067] = &I02067;
  core[002070] = 01066; code[002070] = &I02070;
  core[002071] = 01127; code[002071] = &I02071;
  core[002072] = 07640; code[002072] = &I02072;
  core[002073] = 04526; code[002073] = &D02073;
  core[002074] = 04506; code[002074] = &D02074;
  core[002075] = 05676; code[002075] = &D02075;
  core[002076] = 01610; code[002076] = &P02076;
  core[002077] = 00000; code[002077] = &S02077;
  core[002100] = 01127; code[002100] = &I02100;
  core[002101] = 01070; code[002101] = &I02101;
  core[002102] = 07700; code[002102] = &I02102;
  core[002103] = 05677; code[002103] = &I02103;
  core[002104] = 01127; code[002104] = &I02104;
  core[002105] = 01067; code[002105] = &I02105;
  core[002106] = 07740; code[002106] = &I02106;
  core[002107] = 02277; code[002107] = &I02107;
  core[002110] = 05677; code[002110] = &I02110;
  core[002111] = 04516; code[002111] = &L02111;
  core[002112] = 05502; code[002112] = &I02112;
  core[002113] = 02151; code[002113] = &I02113;
  core[002114] = 04506; code[002114] = &L02114;
  core[002115] = 01142; code[002115] = &I02115;
  core[002116] = 01065; code[002116] = &I02116;
  core[002117] = 07640; code[002117] = &I02117;
  core[002120] = 05314; code[002120] = &I02120;
  core[002121] = 01017; code[002121] = &I02121;
  core[002122] = 07040; code[002122] = &I02122;
  core[002123] = 01146; code[002123] = &I02123;
  core[002124] = 03132; code[002124] = &I02124;
  core[002125] = 01546; code[002125] = &I02125;
  core[002126] = 03550; code[002126] = &I02126;
  core[002127] = 01075; code[002127] = &I02127;
  core[002130] = 03157; code[002130] = &L02130;
  core[002131] = 01557; code[002131] = &I02131;
  core[002132] = 07450; code[002132] = &I02132;
  core[002133] = 05346; code[002133] = &D02133;
  core[002134] = 03156; code[002134] = &I02134;
  core[002135] = 01146; code[002135] = &D02135;
  core[002136] = 07141; code[002136] = &D02136;
  core[002137] = 01156; code[002137] = &I02137;
  core[002140] = 07630; code[002140] = &P02140;
  core[002141] = 01132; code[002141] = &I02141;
  core[002142] = 01156; code[002142] = &I02142;
  core[002143] = 03557; code[002143] = &I02143;
  core[002144] = 01156; code[002144] = &I02144;
  core[002145] = 05330; code[002145] = &I02145;
  core[002146] = 07040; code[002146] = &L02146;
  core[002147] = 01146; code[002147] = &I02147;
  core[002150] = 03011; code[002150] = &I02150;
  core[002151] = 01132; code[002151] = &I02151;
  core[002152] = 07040; code[002152] = &I02152;
  core[002153] = 01146; code[002153] = &I02153;
  core[002154] = 03012; code[002154] = &D02154;
  core[002155] = 01132; code[002155] = &I02155;
  core[002156] = 01134; code[002156] = &I02156;
  core[002157] = 03134; code[002157] = &I02157;
  core[002160] = 01010; code[002160] = &I02160;
  core[002161] = 07040; code[002161] = &I02161;
  core[002162] = 01012; code[002162] = &I02162;
  core[002163] = 03156; code[002163] = &I02163;
  core[002164] = 01010; code[002164] = &I02164;
  core[002165] = 01132; code[002165] = &I02165;
  core[002166] = 03010; code[002166] = &I02166;
  core[002167] = 01412; code[002167] = &L02167;
  core[002170] = 03411; code[002170] = &I02170;
  core[002171] = 02156; code[002171] = &I02171;
  core[002172] = 05367; code[002172] = &I02172;
  core[002173] = 05311; code[002173] = &D02173;
  core[002174] = 06457; code[002174] = &I02174;
  core[002175] = 06453; code[002175] = &I02175;
  core[002176] = 03237; code[002176] = &I02176;
  core[002177] = 03234; code[002177] = &I02177;
  core[002200] = 03303; code[002200] = &I02200;
  core[002201] = 03302; code[002201] = &I02201;
  core[002202] = 03244; code[002202] = &I02202;
  core[002203] = 03243; code[002203] = &I02203;
  core[002204] = 03252; code[002204] = &I02204;
  core[002205] = 03253; code[002205] = &I02205;
  core[002206] = 03256; code[002206] = &I02206;
  core[002207] = 03271; code[002207] = &I02207;
  core[002210] = 02533; code[002210] = &I02210;
  core[002211] = 02650; code[002211] = &I02211;
  core[002212] = 02636; code[002212] = &I02212;
  core[002213] = 02565; code[002213] = &I02213;
  core[002214] = 02630; code[002214] = &I02214;
  core[002215] = 02623; code[002215] = &I02215;
  core[002216] = 02517; code[002216] = &P02216;
  core[002217] = 02572; code[002217] = &I02217;
  core[002220] = 02624; code[002220] = &I02220;
  core[002221] = 02625; code[002221] = &I02221;
  core[002222] = 02654; code[002222] = &I02222;
  core[002223] = 02575; code[002223] = &P02223;
  core[002224] = 02702; code[002224] = &P02224;
  core[002225] = 02631; code[002225] = &P02225;
  core[002226] = 01142; code[002226] = &I02226;
  core[002227] = 01003; code[002227] = &I02227;
  core[002230] = 07640; code[002230] = &P02230;
  core[002231] = 05240; code[002231] = &P02231;
  core[002232] = 01077; code[002232] = &L02232;
  core[002233] = 03134; code[002233] = &I02233;
  core[002234] = 03475; code[002234] = &I02234;
  core[002235] = 01134; code[002235] = &L02235;
  core[002236] = 03155; code[002236] = &P02236;
  core[002237] = 05177; code[002237] = &I02237;
  core[002240] = 04515; code[002240] = &L02240;
  core[002241] = 01143; code[002241] = &I02241;
  core[002242] = 07640; code[002242] = &I02242;
  core[002243] = 05250; code[002243] = &D02243;
  core[002244] = 01134; code[002244] = &D02244;
  core[002245] = 03155; code[002245] = &I02245;
  core[002246] = 05647; code[002246] = &I02246;
  core[002247] = 00616; code[002247] = &P02247;
  core[002250] = 01134; code[002250] = &P02250;
  core[002251] = 03010; code[002251] = &I02251;
  core[002252] = 04501; code[002252] = &L02252;
  core[002253] = 02111; code[002253] = &D02253;
  core[002254] = 02146; code[002254] = &P02254;
  core[002255] = 01141; code[002255] = &I02255;
  core[002256] = 07700; code[002256] = &D02256;
  core[002257] = 01546; code[002257] = &I02257;
  core[002260] = 04524; code[002260] = &I02260;
  core[002261] = 05235; code[002261] = &I02261;
  core[002262] = 01546; code[002262] = &I02262;
  core[002263] = 03143; code[002263] = &I02263;
  core[002264] = 05252; code[002264] = &I02264;
  core[002265] = 00000; code[002265] = &S02265;
  core[002266] = 01075; code[002266] = &I02266;
  core[002267] = 03150; code[002267] = &I02267;
  core[002270] = 01075; code[002270] = &I02270;
  core[002271] = 03146; code[002271] = &L02271;
  core[002272] = 01146; code[002272] = &I02272;
  core[002273] = 03012; code[002273] = &I02273;
  core[002274] = 01143; code[002274] = &I02274;
  core[002275] = 07041; code[002275] = &I02275;
  core[002276] = 01412; code[002276] = &I02276;
  core[002277] = 07450; code[002277] = &I02277;
  core[002300] = 02265; code[002300] = &I02300;
  core[002301] = 07700; code[002301] = &I02301;
  core[002302] = 05310; code[002302] = &P02302;
  core[002303] = 01146; code[002303] = &D02303;
  core[002304] = 03150; code[002304] = &I02304;
  core[002305] = 01546; code[002305] = &I02305;
  core[002306] = 07440; code[002306] = &I02306;
  core[002307] = 05271; code[002307] = &I02307;
  core[002310] = 01146; code[002310] = &L02310;
  core[002311] = 07001; code[002311] = &I02311;
  core[002312] = 03017; code[002312] = &I02312;
  core[002313] = 03020; code[002313] = &I02313;
  core[002314] = 05665; code[002314] = &I02314;
  core[002315] = 00000; code[002315] = &S02315;
  core[002316] = 04351; code[002316] = &L02316;
  core[002317] = 07710; code[002317] = &L02317;
  core[002320] = 01006; code[002320] = &I02320;
  core[002321] = 01377; code[002321] = &I02321;
  core[002322] = 01142; code[002322] = &I02322;
  core[002323] = 07450; code[002323] = &I02323;
  core[002324] = 05337; code[002324] = &I02324;
  core[002325] = 01054; code[002325] = &I02325;
  core[002326] = 03142; code[002326] = &L02326;
  core[002327] = 01151; code[002327] = &I02327;
  core[002330] = 01152; code[002330] = &I02330;
  core[002331] = 07650; code[002331] = &I02331;
  core[002332] = 04512; code[002332] = &I02332;
  core[002333] = 05715; code[002333] = &I02333;
  core[002334] = 04351; code[002334] = &L02334;
  core[002335] = 07040; code[002335] = &I02335;
  core[002336] = 05317; code[002336] = &I02336;
  core[002337] = 01151; code[002337] = &L02337;
  core[002340] = 07640; code[002340] = &I02340;
  core[002341] = 05347; code[002341] = &I02341;
  core[002342] = 01152; code[002342] = &I02342;
  core[002343] = 07650; code[002343] = &I02343;
  core[002344] = 07001; code[002344] = &I02344;
  core[002345] = 03152; code[002345] = &I02345;
  core[002346] = 05316; code[002346] = &I02346;
  core[002347] = 01032; code[002347] = &L02347;
  core[002350] = 05326; code[002350] = &I02350;
  core[002351] = 00000; code[002351] = &S02351;
  core[002352] = 02020; code[002352] = &I02352;
  core[002353] = 05366; code[002353] = &I02353;
  core[002354] = 01021; code[002354] = &I02354;
  core[002355] = 00071; code[002355] = &L02355;
  core[002356] = 03142; code[002356] = &I02356;
  core[002357] = 01142; code[002357] = &I02357;
  core[002360] = 01023; code[002360] = &I02360;
  core[002361] = 07650; code[002361] = &I02361;
  core[002362] = 05334; code[002362] = &I02362;
  core[002363] = 01142; code[002363] = &I02363;
  core[002364] = 01376; code[002364] = &I02364;
  core[002365] = 05751; code[002365] = &I02365;
  core[002366] = 01417; code[002366] = &L02366;
  core[002367] = 03021; code[002367] = &I02367;
  core[002370] = 07040; code[002370] = &I02370;
  core[002371] = 03020; code[002371] = &I02371;
  core[002372] = 01021; code[002372] = &I02372;
  core[002373] = 04520; code[002373] = &I02373;
  core[002374] = 07004; code[002374] = &I02374;
  core[002375] = 05355; code[002375] = &I02375;
  core[002376] = 07740; code[002376] = &D02376;
  core[002377] = 07641; code[002377] = &D02377;
  core[002400] = 00313; code[002400] = &I02400;
  core[002401] = 00322; code[002401] = &I02401;
  core[002402] = 00324; code[002402] = &I02402;
  core[002403] = 00320; code[002403] = &I02403;
  core[002404] = 00311; code[002404] = &I02404;
  core[002405] = 00303; code[002405] = &I02405;
  core[002406] = 00272; code[002406] = &I02406;
  core[002407] = 00330; code[002407] = &I02407;
  core[002410] = 00305; code[002410] = &I02410;
  core[002411] = 00316; code[002411] = &P02411;
  core[002412] = 00323; code[002412] = &I02412;
  core[002413] = 00315; code[002413] = &I02413;
  core[002414] = 06004; code[002414] = &I02414;
  core[002415] = 03045; code[002415] = &I02415;
  core[002416] = 05500; code[002416] = &I02416;
  core[002417] = 00000; code[002417] = &S02417;
  core[002420] = 01550; code[002420] = &I02420;
  core[002421] = 03534; code[002421] = &I02421;
  core[002422] = 01134; code[002422] = &I02422;
  core[002423] = 03550; code[002423] = &I02423;
  core[002424] = 01135; code[002424] = &I02424;
  core[002425] = 07440; code[002425] = &I02425;
  core[002426] = 03410; code[002426] = &I02426;
  core[002427] = 01010; code[002427] = &I02427;
  core[002430] = 07001; code[002430] = &I02430;
  core[002431] = 03134; code[002431] = &I02431;
  core[002432] = 01134; code[002432] = &I02432;
  core[002433] = 03155; code[002433] = &I02433;
  core[002434] = 05617; code[002434] = &I02434;
  core[002435] = 00000; code[002435] = &S02435;
  core[002436] = 04504; code[002436] = &I02436;
  core[002437] = 00017; code[002437] = &I02437;
  core[002440] = 01142; code[002440] = &I02440;
  core[002441] = 04503; code[002441] = &I02441;
  core[002442] = 05635; code[002442] = &I02442;
  core[002443] = 00000; code[002443] = &S02443;
  core[002444] = 01413; code[002444] = &I02444;
  core[002445] = 03142; code[002445] = &I02445;
  core[002446] = 04505; code[002446] = &I02446;
  core[002447] = 00017; code[002447] = &I02447;
  core[002450] = 05643; code[002450] = &I02450;
  core[002451] = 00000; code[002451] = &S02451;
  core[002452] = 00024; code[002452] = &I02452;
  core[002453] = 07041; code[002453] = &I02453;
  core[002454] = 03157; code[002454] = &I02454;
  core[002455] = 01143; code[002455] = &I02455;
  core[002456] = 00024; code[002456] = &I02456;
  core[002457] = 01157; code[002457] = &I02457;
  core[002460] = 07650; code[002460] = &I02460;
  core[002461] = 02251; code[002461] = &I02461;
  core[002462] = 05651; code[002462] = &I02462;
  core[002463] = 00000; code[002463] = &S02463;
  core[002464] = 04540; code[002464] = &L02464;
  core[002465] = 03142; code[002465] = &I02465;
  core[002466] = 04511; code[002466] = &I02466;
  core[002467] = 01611; code[002467] = &I02467;
  core[002470] = 05663; code[002470] = &I02470;
  core[002471] = 04512; code[002471] = &D02471;
  core[002472] = 01142; code[002472] = &D02472;
  core[002473] = 01024; code[002473] = &I02473;
  core[002474] = 07640; code[002474] = &I02474;
  core[002475] = 05663; code[002475] = &I02475;
  core[002476] = 05264; code[002476] = &I02476;
  core[002477] = 00000; code[002477] = &S02477;
  core[002500] = 07450; code[002500] = &I02500;
  core[002501] = 01142; code[002501] = &I02501;
  core[002502] = 01065; code[002502] = &I02502;
  core[002503] = 07450; code[002503] = &D02503;
  core[002504] = 05310; code[002504] = &I02504;
  core[002505] = 01060; code[002505] = &D02505;
  core[002506] = 04537; code[002506] = &L02506;
  core[002507] = 05677; code[002507] = &I02507;
  core[002510] = 01060; code[002510] = &L02510;
  core[002511] = 04537; code[002511] = &D02511;
  core[002512] = 01057; code[002512] = &I02512;
  core[002513] = 05306; code[002513] = &D02513;
  core[002514] = 00000; code[002514] = &S02514;
  core[002515] = 04511; code[002515] = &D02515;
  core[002516] = 01141; code[002516] = &D02516;
  core[002517] = 07410; code[002517] = &D02517;
  core[002520] = 05326; code[002520] = &D02520;
  core[002521] = 01127; code[002521] = &I02521;
  core[002522] = 02314; code[002522] = &D02522;
  core[002523] = 07640; code[002523] = &D02523;
  core[002524] = 05714; code[002524] = &D02524;
  core[002525] = 02314; code[002525] = &I02525;
  core[002526] = 04506; code[002526] = &L02526;
  core[002527] = 05714; code[002527] = &I02527;
  core[002600] = 00000; code[002600] = &D02600;
  core[002601] = 00000; code[002601] = &D02601;
  core[002602] = 07575; code[002602] = &D02602;
  core[002603] = 03200; code[002603] = &L02603;
  core[002604] = 07010; code[002604] = &I02604;
  core[002605] = 03201; code[002605] = &I02605;
  core[002606] = 06031; code[002606] = &I02606;
  core[002607] = 05225; code[002607] = &I02607;
  core[002610] = 06036; code[002610] = &I02610;
  core[002611] = 00026; code[002611] = &I02611;
  core[002612] = 01015; code[002612] = &I02612;
  core[002613] = 03306; code[002613] = &I02613;
  core[002614] = 01306; code[002614] = &I02614;
  core[002615] = 01202; code[002615] = &I02615;
  core[002616] = 07650; code[002616] = &I02616;
  core[002617] = 05345; code[002617] = &I02617;
  core[002620] = 01264; code[002620] = &I02620;
  core[002621] = 07640; code[002621] = &I02621;
  core[002622] = 04526; code[002622] = &I02622;
  core[002623] = 01306; code[002623] = &I02623;
  core[002624] = 03264; code[002624] = &I02624;
  core[002625] = 06041; code[002625] = &L02625;
  core[002626] = 05244; code[002626] = &I02626;
  core[002627] = 06042; code[002627] = &D02627;
  core[002630] = 03260; code[002630] = &I02630;
  core[002631] = 01663; code[002631] = &D02631;
  core[002632] = 07450; code[002632] = &I02632;
  core[002633] = 05244; code[002633] = &I02633;
  core[002634] = 06044; code[002634] = &D02634;
  core[002635] = 03260; code[002635] = &I02635;
  core[002636] = 03663; code[002636] = &I02636;
  core[002637] = 01263; code[002637] = &I02637;
  core[002640] = 07001; code[002640] = &I02640;
  core[002641] = 00031; code[002641] = &I02641;
  core[002642] = 01261; code[002642] = &I02642;
  core[002643] = 03263; code[002643] = &I02643;
  core[002644] = 06244; code[002644] = &L02644;
  core[002645] = 06101; code[002645] = &I02645;
  core[002646] = 07000; code[002646] = &I02646;
  core[002647] = 06011; code[002647] = &I02647;
  core[002650] = 05253; code[002650] = &I02650;
  core[002651] = 06012; code[002651] = &I02651;
  core[002652] = 03037; code[002652] = &I02652;
  core[002653] = 01201; code[002653] = &L02653;
  core[002654] = 07104; code[002654] = &I02654;
  core[002655] = 01200; code[002655] = &I02655;
  core[002656] = 06001; code[002656] = &I02656;
  core[002657] = 05400; code[002657] = &I02657;
  core[002660] = 00001; code[002660] = &D02660;
  core[002661] = 03400; code[002661] = &D02661;
  core[002662] = 03400; code[002662] = &P02662;
  core[002663] = 03400; code[002663] = &P02663;
  core[002664] = 00000; code[002664] = &D02664;
  core[002665] = 00000; code[002665] = &S02665;
  core[002666] = 01264; code[002666] = &L02666;
  core[002667] = 07550; code[002667] = &I02667;
  core[002670] = 05266; code[002670] = &I02670;
  core[002671] = 03275; code[002671] = &I02671;
  core[002672] = 03264; code[002672] = &I02672;
  core[002673] = 01275; code[002673] = &I02673;
  core[002674] = 05665; code[002674] = &I02674;
  core[002675] = 00000; code[002675] = &S02675;
  core[002676] = 03265; code[002676] = &I02676;
  core[002677] = 01265; code[002677] = &I02677;
  core[002700] = 01065; code[002700] = &I02700;
  core[002701] = 07650; code[002701] = &I02701;
  core[002702] = 03053; code[002702] = &D02702;
  core[002703] = 01265; code[002703] = &I02703;
  core[002704] = 04732; code[002704] = &I02704;
  core[002705] = 02053; code[002705] = &I02705;
  core[002706] = 00000; code[002706] = &D02706;
  core[002707] = 06001; code[002707] = &I02707;
  core[002710] = 01662; code[002710] = &L02710;
  core[002711] = 07640; code[002711] = &I02711;
  core[002712] = 05310; code[002712] = &I02712;
  core[002713] = 01260; code[002713] = &I02713;
  core[002714] = 07640; code[002714] = &I02714;
  core[002715] = 05322; code[002715] = &I02715;
  core[002716] = 01265; code[002716] = &I02716;
  core[002717] = 06046; code[002717] = &D02717;
  core[002720] = 03260; code[002720] = &I02720;
  core[002721] = 05675; code[002721] = &I02721;
  core[002722] = 01265; code[002722] = &L02722;
  core[002723] = 03662; code[002723] = &I02723;
  core[002724] = 01262; code[002724] = &I02724;
  core[002725] = 07001; code[002725] = &I02725;
  core[002726] = 00031; code[002726] = &I02726;
  core[002727] = 01261; code[002727] = &I02727;
  core[002730] = 03262; code[002730] = &I02730;
  core[002731] = 05675; code[002731] = &I02731;
  core[002732] = 03014; code[002732] = &P02732;
  core[002733] = 03225; code[002733] = &P02733;
  core[002734] = 03203; code[002734] = &P02734;
  core[002735] = 03336; code[002735] = &I02735;
  core[002736] = 00000; code[002736] = &D02736;
  core[002737] = 07240; code[002737] = &I02737;
  core[002740] = 01336; code[002740] = &I02740;
  core[002741] = 03143; code[002741] = &I02741;
  core[002742] = 04733; code[002742] = &I02742;
  core[002743] = 06002; code[002743] = &I02743;
  core[002744] = 05347; code[002744] = &I02744;
  core[002745] = 01015; code[002745] = &L02745;
  core[002746] = 03143; code[002746] = &I02746;
  core[002747] = 02260; code[002747] = &L02747;
  core[002750] = 01025; code[002750] = &I02750;
  core[002751] = 03132; code[002751] = &I02751;
  core[002752] = 07040; code[002752] = &I02752;
  core[002753] = 01261; code[002753] = &I02753;
  core[002754] = 03011; code[002754] = &I02754;
  core[002755] = 03411; code[002755] = &L02755;
  core[002756] = 02132; code[002756] = &I02756;
  core[002757] = 05355; code[002757] = &I02757;
  core[002760] = 03264; code[002760] = &I02760;
  core[002761] = 01261; code[002761] = &I02761;
  core[002762] = 03263; code[002762] = &I02762;
  core[002763] = 01261; code[002763] = &I02763;
  core[002764] = 03262; code[002764] = &I02764;
  core[002765] = 04734; code[002765] = &I02765;
  core[002766] = 01161; code[002766] = &I02766;
  core[002767] = 03113; code[002767] = &I02767;
  core[002770] = 07040; code[002770] = &I02770;
  core[002771] = 06046; code[002771] = &I02771;
  core[002772] = 07200; code[002772] = &I02772;
  core[002773] = 01060; code[002773] = &I02773;
  core[002774] = 04512; code[002774] = &I02774;
  core[002775] = 01032; code[002775] = &I02775;
  core[002776] = 04512; code[002776] = &I02776;
  core[002777] = 04514; code[002777] = &I02777;
  core[003000] = 02145; code[003000] = &I03000;
  core[003001] = 01545; code[003001] = &I03001;
  core[003002] = 07450; code[003002] = &I03002;
  core[003003] = 05211; code[003003] = &I03003;
  core[003004] = 03143; code[003004] = &I03004;
  core[003005] = 01062; code[003005] = &I03005;
  core[003006] = 04512; code[003006] = &I03006;
  core[003007] = 04512; code[003007] = &I03007;
  core[003010] = 04514; code[003010] = &I03010;
  core[003011] = 01060; code[003011] = &L03011;
  core[003012] = 04512; code[003012] = &D03012;
  core[003013] = 05177; code[003013] = &I03013;
  core[003014] = 00000; code[003014] = &S03014;
  core[003015] = 04520; code[003015] = &I03015;
  core[003016] = 07710; code[003016] = &I03016;
  core[003017] = 07020; code[003017] = &I03017;
  core[003020] = 07420; code[003020] = &I03020;
  core[003021] = 02214; code[003021] = &I03021;
  core[003022] = 05614; code[003022] = &I03022;
  core[003023] = 00000; code[003023] = &S03023;
  core[003024] = 04510; code[003024] = &I03024;
  core[003025] = 03055; code[003025] = &I03025;
  core[003026] = 06126; code[003026] = &I03026;
  core[003027] = 01142; code[003027] = &I03027;
  core[003030] = 04214; code[003030] = &I03030;
  core[003031] = 05234; code[003031] = &I03031;
  core[003032] = 01071; code[003032] = &I03032;
  core[003033] = 04242; code[003033] = &I03033;
  core[003034] = 01142; code[003034] = &L03034;
  core[003035] = 00071; code[003035] = &L03035;
  core[003036] = 04242; code[003036] = &I03036;
  core[003037] = 05623; code[003037] = &I03037;
  core[003040] = 01054; code[003040] = &I03040;
  core[003041] = 05235; code[003041] = &D03041;
  core[003042] = 00000; code[003042] = &S03042;
  core[003043] = 02136; code[003043] = &I03043;
  core[003044] = 05260; code[003044] = &I03044;
  core[003045] = 01135; code[003045] = &I03045;
  core[003046] = 03410; code[003046] = &I03046;
  core[003047] = 01013; code[003047] = &I03047;
  core[003050] = 07141; code[003050] = &I03050;
  core[003051] = 01005; code[003051] = &I03051;
  core[003052] = 01010; code[003052] = &D03052;
  core[003053] = 07630; code[003053] = &I03053;
  core[003054] = 04526; code[003054] = &I03054;
  core[003055] = 05642; code[003055] = &I03055;
  core[003056] = 00277; code[003056] = &I03056;
  core[003057] = 00377; code[003057] = &I03057;
  core[003060] = 04520; code[003060] = &L03060;
  core[003061] = 03135; code[003061] = &I03061;
  core[003062] = 07040; code[003062] = &I03062;
  core[003063] = 03136; code[003063] = &I03063;
  core[003064] = 05642; code[003064] = &I03064;
  core[003065] = 01010; code[003065] = &I03065;
  core[003066] = 03242; code[003066] = &I03066;
  core[003067] = 01136; code[003067] = &I03067;
  core[003070] = 07640; code[003070] = &I03070;
  core[003071] = 05277; code[003071] = &I03071;
  core[003072] = 01010; code[003072] = &I03072;
  core[003073] = 07041; code[003073] = &I03073;
  core[003074] = 01153; code[003074] = &I03074;
  core[003075] = 07700; code[003075] = &I03075;
  core[003076] = 05322; code[003076] = &I03076;
  core[003077] = 01324; code[003077] = &L03077;
  core[003100] = 04512; code[003100] = &I03100;
  core[003101] = 02136; code[003101] = &I03101;
  core[003102] = 05310; code[003102] = &I03102;
  core[003103] = 01642; code[003103] = &I03103;
  core[003104] = 00071; code[003104] = &I03104;
  core[003105] = 01023; code[003105] = &I03105;
  core[003106] = 07640; code[003106] = &I03106;
  core[003107] = 05322; code[003107] = &I03107;
  core[003110] = 01642; code[003110] = &L03110;
  core[003111] = 00062; code[003111] = &I03111;
  core[003112] = 03135; code[003112] = &I03112;
  core[003113] = 07040; code[003113] = &I03113;
  core[003114] = 01010; code[003114] = &I03114;
  core[003115] = 03010; code[003115] = &I03115;
  core[003116] = 01135; code[003116] = &I03116;
  core[003117] = 01006; code[003117] = &I03117;
  core[003120] = 07640; code[003120] = &I03120;
  core[003121] = 07040; code[003121] = &I03121;
  core[003122] = 03136; code[003122] = &L03122;
  core[003123] = 05623; code[003123] = &I03123;
  core[003124] = 00334; code[003124] = &D03124;
  core[003125] = 04504; code[003125] = &I03125;
  core[003126] = 00017; code[003126] = &I03126;
  core[003127] = 07040; code[003127] = &I03127;
  core[003130] = 01134; code[003130] = &I03130;
  core[003131] = 03014; code[003131] = &L03131;
  core[003132] = 01014; code[003132] = &I03132;
  core[003133] = 07040; code[003133] = &I03133;
  core[003134] = 01155; code[003134] = &D03134;
  core[003135] = 07650; code[003135] = &I03135;
  core[003136] = 05370; code[003136] = &I03136;
  core[003137] = 01375; code[003137] = &I03137;
  core[003140] = 03017; code[003140] = &I03140;
  core[003141] = 03020; code[003141] = &I03141;
  core[003142] = 01414; code[003142] = &I03142;
  core[003143] = 03376; code[003143] = &I03143;
  core[003144] = 04501; code[003144] = &I03144;
  core[003145] = 01241; code[003145] = &I03145;
  core[003146] = 01414; code[003146] = &I03146;
  core[003147] = 04774; code[003147] = &I03147;
  core[003150] = 04501; code[003150] = &I03150;
  core[003151] = 01241; code[003151] = &I03151;
  core[003152] = 01005; code[003152] = &I03152;
  core[003153] = 03046; code[003153] = &D03153;
  core[003154] = 04501; code[003154] = &I03154;
  core[003155] = 01374; code[003155] = &D03155;
  core[003156] = 02014; code[003156] = &I03156;
  core[003157] = 04407; code[003157] = &I03157;
  core[003160] = 05414; code[003160] = &I03160;
  core[003161] = 00000; code[003161] = &I03161;
  core[003162] = 04472; code[003162] = &I03162;
  core[003163] = 01060; code[003163] = &I03163;
  core[003164] = 04512; code[003164] = &L03164;
  core[003165] = 01014; code[003165] = &I03165;
  core[003166] = 01035; code[003166] = &I03166;
  core[003167] = 05331; code[003167] = &I03167;
  core[003170] = 04505; code[003170] = &L03170;
  core[003171] = 00017; code[003171] = &I03171;
  core[003172] = 05773; code[003172] = &I03172;
  core[003173] = 01252; code[003173] = &P03173;
  core[003174] = 06100; code[003174] = &P03174;
  core[003175] = 03175; code[003175] = &D03175;
  core[003176] = 00000; code[003176] = &D03176;
  core[003177] = 05077; code[003177] = &D03177;
  core[003200] = 01551; code[003200] = &P03200;
  core[003201] = 07577; code[003201] = &P03201;
  core[003202] = 01500; code[003202] = &I03202;
  core[003203] = 00000; code[003203] = &S03203;
  core[003204] = 01220; code[003204] = &I03204;
  core[003205] = 03621; code[003205] = &I03205;
  core[003206] = 01621; code[003206] = &I03206;
  core[003207] = 07001; code[003207] = &I03207;
  core[003210] = 03622; code[003210] = &I03210;
  core[003211] = 01622; code[003211] = &I03211;
  core[003212] = 01035; code[003212] = &I03212;
  core[003213] = 03623; code[003213] = &I03213;
  core[003214] = 01623; code[003214] = &I03214;
  core[003215] = 01035; code[003215] = &I03215;
  core[003216] = 03624; code[003216] = &I03216;
  core[003217] = 05603; code[003217] = &I03217;
  core[003220] = 06041; code[003220] = &D03220;
  core[003221] = 02625; code[003221] = &P03221;
  core[003222] = 02627; code[003222] = &P03222;
  core[003223] = 02634; code[003223] = &P03223;
  core[003224] = 02717; code[003224] = &P03224;
  core[003225] = 00000; code[003225] = &S03225;
  core[003226] = 06001; code[003226] = &L03226;
  core[003227] = 01633; code[003227] = &P03227;
  core[003230] = 07640; code[003230] = &I03230;
  core[003231] = 05226; code[003231] = &I03231;
  core[003232] = 05625; code[003232] = &I03232;
  core[003233] = 02660; code[003233] = &P03233;
  core[003234] = 04225; code[003234] = &P03234;
  core[003235] = 01025; code[003235] = &I03235;
  core[003236] = 07410; code[003236] = &I03236;
  core[003237] = 04225; code[003237] = &I03237;
  core[003240] = 04203; code[003240] = &I03240;
  core[003241] = 05642; code[003241] = &L03241;
  core[003242] = 06461; code[003242] = &P03242;
  core[003243] = 01250; code[003243] = &I03243;
  core[003244] = 01247; code[003244] = &I03244;
  core[003245] = 03651; code[003245] = &I03245;
  core[003246] = 05241; code[003246] = &I03246;
  core[003247] = 04512; code[003247] = &D03247;
  core[003250] = 02466; code[003250] = &D03250;
  core[003251] = 01222; code[003251] = &P03251;
  core[003252] = 01247; code[003252] = &I03252;
  core[003253] = 03655; code[003253] = &I03253;
  core[003254] = 05241; code[003254] = &I03254;
  core[003255] = 02471; code[003255] = &P03255;
  core[003256] = 04506; code[003256] = &L03256;
  core[003257] = 04511; code[003257] = &I03257;
  core[003260] = 02003; code[003260] = &P03260;
  core[003261] = 07410; code[003261] = &I03261;
  core[003262] = 05256; code[003262] = &I03262;
  core[003263] = 04501; code[003263] = &I03263;
  core[003264] = 01601; code[003264] = &I03264;
  core[003265] = 04452; code[003265] = &I03265;
  core[003266] = 03670; code[003266] = &I03266;
  core[003267] = 05241; code[003267] = &I03267;
  core[003270] = 06002; code[003270] = &P03270;
  core[003271] = 04225; code[003271] = &I03271;
  core[003272] = 06002; code[003272] = &I03272;
  core[003273] = 05424; code[003273] = &I03273;
  core[003274] = 01301; code[003274] = &I03274;
  core[003275] = 03017; code[003275] = &I03275;
  core[003276] = 03020; code[003276] = &I03276;
  core[003277] = 04501; code[003277] = &I03277;
  core[003300] = 01260; code[003300] = &I03300;
  core[003301] = 02036; code[003301] = &D03301;
  core[003302] = 07240; code[003302] = &I03302;
  core[003303] = 03305; code[003303] = &I03303;
  core[003304] = 05241; code[003304] = &I03304;
  core[003305] = 00000; code[003305] = &D03305;
  core[003306] = 00000; code[003306] = &S03306;
  core[003307] = 01154; code[003307] = &I03307;
  core[003310] = 03225; code[003310] = &I03310;
  core[003311] = 01305; code[003311] = &I03311;
  core[003312] = 07650; code[003312] = &I03312;
  core[003313] = 05323; code[003313] = &I03313;
  core[003314] = 04513; code[003314] = &I03314;
  core[003315] = 01142; code[003315] = &I03315;
  core[003316] = 04430; code[003316] = &I03316;
  core[003317] = 04407; code[003317] = &P03317;
  core[003320] = 06625; code[003320] = &I03320;
  core[003321] = 00000; code[003321] = &I03321;
  core[003322] = 05706; code[003322] = &I03322;
  core[003323] = 01013; code[003323] = &L03323;
  core[003324] = 03203; code[003324] = &I03324;
  core[003325] = 01364; code[003325] = &I03325;
  core[003326] = 03013; code[003326] = &I03326;
  core[003327] = 02151; code[003327] = &I03327;
  core[003330] = 01363; code[003330] = &I03330;
  core[003331] = 03010; code[003331] = &I03331;
  core[003332] = 03136; code[003332] = &I03332;
  core[003333] = 01363; code[003333] = &I03333;
  core[003334] = 03153; code[003334] = &I03334;
  core[003335] = 04513; code[003335] = &L03335;
  core[003336] = 04511; code[003336] = &I03336;
  core[003337] = 00032; code[003337] = &I03337;
  core[003340] = 05335; code[003340] = &I03340;
  core[003341] = 04510; code[003341] = &L03341;
  core[003342] = 05775; code[003342] = &I03342;
  core[003343] = 00774; code[003343] = &I03343;
  core[003344] = 04507; code[003344] = &I03344;
  core[003345] = 04513; code[003345] = &I03345;
  core[003346] = 05341; code[003346] = &I03346;
  core[003347] = 01060; code[003347] = &I03347;
  core[003350] = 03142; code[003350] = &I03350;
  core[003351] = 04507; code[003351] = &I03351;
  core[003352] = 04507; code[003352] = &I03352;
  core[003353] = 01203; code[003353] = &I03353;
  core[003354] = 03013; code[003354] = &I03354;
  core[003355] = 01363; code[003355] = &I03355;
  core[003356] = 03017; code[003356] = &I03356;
  core[003357] = 03020; code[003357] = &I03357;
  core[003360] = 04501; code[003360] = &I03360;
  core[003361] = 01600; code[003361] = &I03361;
  core[003362] = 05317; code[003362] = &I03362;
  core[003363] = 07550; code[003363] = &D03363;
  core[003364] = 07612; code[003364] = &D03364;
  core[003365] = 00000; code[003365] = &S03365;
  core[003366] = 01305; code[003366] = &I03366;
  core[003367] = 07640; code[003367] = &I03367;
  core[003370] = 05373; code[003370] = &I03370;
  core[003371] = 04472; code[003371] = &I03371;
  core[003372] = 05765; code[003372] = &I03372;
  core[003373] = 04452; code[003373] = &L03373;
  core[003374] = 07450; code[003374] = &P03374;
  core[003375] = 07130; code[003375] = &P03375;
  core[003376] = 04537; code[003376] = &I03376;
  core[003377] = 05765; code[003377] = &D03377;
  core[003420] = 00000; code[003420] = &D03420;
  core[003421] = 00000; code[003421] = &I03421;
  core[003422] = 00355; code[003422] = &I03422;
  core[003423] = 00617; code[003423] = &I03423;
  core[003424] = 00301; code[003424] = &I03424;
  core[003425] = 01454; code[003425] = &I03425;
  core[003426] = 04040; code[003426] = &I03426;
  core[003427] = 06557; code[003427] = &I03427;
  core[003430] = 06671; code[003430] = &D03430;
  core[003431] = 07715; code[003431] = &I03431;
  core[003432] = 07300; code[003432] = &L03432;
  core[003433] = 01377; code[003433] = &I03433;
  core[003434] = 03176; code[003434] = &I03434;
  core[003435] = 06002; code[003435] = &I03435;
  core[003436] = 06022; code[003436] = &I03436;
  core[003437] = 06032; code[003437] = &I03437;
  core[003440] = 06203; code[003440] = &I03440;
  core[003441] = 06402; code[003441] = &P03441;
  core[003442] = 06412; code[003442] = &I03442;
  core[003443] = 06422; code[003443] = &I03443;
  core[003444] = 06432; code[003444] = &I03444;
  core[003445] = 06442; code[003445] = &I03445;
  core[003446] = 06452; code[003446] = &I03446;
  core[003447] = 06462; code[003447] = &I03447;
  core[003450] = 06472; code[003450] = &I03450;
  core[003451] = 06764; code[003451] = &I03451;
  core[003452] = 06772; code[003452] = &I03452;
  core[003453] = 07200; code[003453] = &I03453;
  core[003454] = 06046; code[003454] = &I03454;
  core[003455] = 03414; code[003455] = &L03455;
  core[003456] = 02376; code[003456] = &I03456;
  core[003457] = 05255; code[003457] = &I03457;
  core[003460] = 01027; code[003460] = &I03460;
  core[003461] = 03013; code[003461] = &I03461;
  core[003462] = 06001; code[003462] = &I03462;
  core[003463] = 04512; code[003463] = &I03463;
  core[003464] = 04512; code[003464] = &I03464;
  core[003465] = 04512; code[003465] = &I03465;
  core[003466] = 04501; code[003466] = &I03466;
  core[003467] = 00641; code[003467] = &I03467;
  core[003470] = 05671; code[003470] = &I03470;
  core[003471] = 02232; code[003471] = &P03471;
  core[003576] = 07760; code[003576] = &D03576;
  core[003577] = 02746; code[003577] = &D03577;
  core[005600] = 00000; code[005600] = &S05600;
  core[005601] = 04430; code[005601] = &I05601;
  core[005602] = 03364; code[005602] = &I05602;
  core[005603] = 07040; code[005603] = &I05603;
  core[005604] = 03260; code[005604] = &I05604;
  core[005605] = 01363; code[005605] = &I05605;
  core[005606] = 03044; code[005606] = &I05606;
  core[005607] = 04755; code[005607] = &I05607;
  core[005610] = 03365; code[005610] = &I05610;
  core[005611] = 05215; code[005611] = &I05611;
  core[005612] = 02260; code[005612] = &L05612;
  core[005613] = 04526; code[005613] = &I05613;
  core[005614] = 04506; code[005614] = &L05614;
  core[005615] = 04522; code[005615] = &L05615;
  core[005616] = 05212; code[005616] = &I05616;
  core[005617] = 05250; code[005617] = &I05617;
  core[005620] = 01260; code[005620] = &I05620;
  core[005621] = 07700; code[005621] = &I05621;
  core[005622] = 07040; code[005622] = &I05622;
  core[005623] = 01364; code[005623] = &I05623;
  core[005624] = 03364; code[005624] = &I05624;
  core[005625] = 04342; code[005625] = &I05625;
  core[005626] = 01127; code[005626] = &I05626;
  core[005627] = 03043; code[005627] = &I05627;
  core[005630] = 03042; code[005630] = &I05630;
  core[005631] = 03041; code[005631] = &I05631;
  core[005632] = 04313; code[005632] = &I05632;
  core[005633] = 01162; code[005633] = &P05633;
  core[005634] = 07640; code[005634] = &I05634;
  core[005635] = 05241; code[005635] = &I05635;
  core[005636] = 01045; code[005636] = &I05636;
  core[005637] = 07700; code[005637] = &I05637;
  core[005640] = 05214; code[005640] = &I05640;
  core[005641] = 01361; code[005641] = &L05641;
  core[005642] = 03760; code[005642] = &I05642;
  core[005643] = 01162; code[005643] = &I05643;
  core[005644] = 07110; code[005644] = &I05644;
  core[005645] = 03162; code[005645] = &I05645;
  core[005646] = 01045; code[005646] = &I05646;
  core[005647] = 05762; code[005647] = &I05647;
  core[005650] = 04511; code[005650] = &L05650;
  core[005651] = 06145; code[005651] = &I05651;
  core[005652] = 05301; code[005652] = &I05652;
  core[005653] = 02365; code[005653] = &L05653;
  core[005654] = 04450; code[005654] = &I05654;
  core[005655] = 01366; code[005655] = &I05655;
  core[005656] = 03260; code[005656] = &L05656;
  core[005657] = 04407; code[005657] = &I05657;
  core[005660] = 07000; code[005660] = &D05660;
  core[005661] = 06554; code[005661] = &I05661;
  core[005662] = 00000; code[005662] = &I05662;
  core[005663] = 01364; code[005663] = &I05663;
  core[005664] = 07450; code[005664] = &I05664;
  core[005665] = 05600; code[005665] = &I05665;
  core[005666] = 07500; code[005666] = &I05666;
  core[005667] = 05273; code[005667] = &I05667;
  core[005670] = 07001; code[005670] = &I05670;
  core[005671] = 03364; code[005671] = &I05671;
  core[005672] = 05277; code[005672] = &I05672;
  core[005673] = 07240; code[005673] = &L05673;
  core[005674] = 01364; code[005674] = &I05674;
  core[005675] = 03364; code[005675] = &I05675;
  core[005676] = 01066; code[005676] = &I05676;
  core[005677] = 01367; code[005677] = &L05677;
  core[005700] = 05256; code[005700] = &I05700;
  core[005701] = 04506; code[005701] = &L05701;
  core[005702] = 04755; code[005702] = &I05702;
  core[005703] = 03040; code[005703] = &D05703;
  core[005704] = 04757; code[005704] = &I05704;
  core[005705] = 01164; code[005705] = &I05705;
  core[005706] = 02040; code[005706] = &I05706;
  core[005707] = 07041; code[005707] = &I05707;
  core[005710] = 01364; code[005710] = &I05710;
  core[005711] = 03364; code[005711] = &I05711;
  core[005712] = 05253; code[005712] = &I05712;
  core[005713] = 00000; code[005713] = &S05713;
  core[005714] = 07300; code[005714] = &I05714;
  core[005715] = 01043; code[005715] = &I05715;
  core[005716] = 01047; code[005716] = &I05716;
  core[005717] = 03047; code[005717] = &I05717;
  core[005720] = 07004; code[005720] = &I05720;
  core[005721] = 01042; code[005721] = &I05721;
  core[005722] = 01046; code[005722] = &I05722;
  core[005723] = 03046; code[005723] = &I05723;
  core[005724] = 07004; code[005724] = &I05724;
  core[005725] = 01041; code[005725] = &I05725;
  core[005726] = 01045; code[005726] = &I05726;
  core[005727] = 03045; code[005727] = &I05727;
  core[005730] = 07004; code[005730] = &I05730;
  core[005731] = 01162; code[005731] = &I05731;
  core[005732] = 03162; code[005732] = &I05732;
  core[005733] = 05713; code[005733] = &D05733;
  core[005734] = 00000; code[005734] = &S05734;
  core[005735] = 04756; code[005735] = &I05735;
  core[005736] = 01162; code[005736] = &I05736;
  core[005737] = 07004; code[005737] = &I05737;
  core[005740] = 03162; code[005740] = &I05740;
  core[005741] = 05734; code[005741] = &I05741;
  core[005742] = 00000; code[005742] = &S05742;
  core[005743] = 04504; code[005743] = &I05743;
  core[005744] = 00045; code[005744] = &I05744;
  core[005745] = 04505; code[005745] = &I05745;
  core[005746] = 00041; code[005746] = &I05746;
  core[005747] = 03162; code[005747] = &I05747;
  core[005750] = 04334; code[005750] = &I05750;
  core[005751] = 04334; code[005751] = &I05751;
  core[005752] = 04313; code[005752] = &I05752;
  core[005753] = 04334; code[005753] = &I05753;
  core[005754] = 05742; code[005754] = &I05754;
  core[005755] = 06030; code[005755] = &P05755;
  core[005756] = 07037; code[005756] = &P05756;
  core[005757] = 06010; code[005757] = &P05757;
  core[005760] = 07251; code[005760] = &P05760;
  core[005761] = 05633; code[005761] = &D05761;
  core[005762] = 07256; code[005762] = &P05762;
  core[005763] = 00043; code[005763] = &D05763;
  core[005764] = 00000; code[005764] = &D05764;
  core[005765] = 00000; code[005765] = &D05765;
  core[005766] = 07000; code[005766] = &D05766;
  core[005767] = 03373; code[005767] = &D05767;
  core[005770] = 00004; code[005770] = &D05770;
  core[005771] = 02400; code[005771] = &I05771;
  core[005772] = 00000; code[005772] = &I05772;
  core[005773] = 07775; code[005773] = &D05773;
  core[005774] = 03146; code[005774] = &I05774;
  core[005775] = 03147; code[005775] = &I05775;
  core[005776] = 00215; code[005776] = &I05776;
  core[005777] = 00214; code[005777] = &I05777;
  core[006000] = 00337; code[006000] = &I06000;
  core[006001] = 00254; code[006001] = &I06001;
  core[006002] = 00000; code[006002] = &D06002;
  core[006003] = 00212; code[006003] = &I06003;
  core[006004] = 06030; code[006004] = &D06004;
  core[006005] = 07634; code[006005] = &I06005;
  core[006006] = 07766; code[006006] = &I06006;
  core[006007] = 07777; code[006007] = &I06007;
  core[006010] = 00000; code[006010] = &S06010;
  core[006011] = 03164; code[006011] = &L06011;
  core[006012] = 04522; code[006012] = &D06012;
  core[006013] = 07000; code[006013] = &I06013;
  core[006014] = 05610; code[006014] = &I06014;
  core[006015] = 04506; code[006015] = &I06015;
  core[006016] = 01164; code[006016] = &I06016;
  core[006017] = 07106; code[006017] = &I06017;
  core[006020] = 07530; code[006020] = &I06020;
  core[006021] = 05226; code[006021] = &I06021;
  core[006022] = 01164; code[006022] = &I06022;
  core[006023] = 07004; code[006023] = &I06023;
  core[006024] = 01127; code[006024] = &I06024;
  core[006025] = 07530; code[006025] = &I06025;
  core[006026] = 04526; code[006026] = &L06026;
  core[006027] = 05211; code[006027] = &I06027;
  core[006030] = 00000; code[006030] = &S06030;
  core[006031] = 04521; code[006031] = &I06031;
  core[006032] = 03127; code[006032] = &I06032;
  core[006033] = 04511; code[006033] = &I06033;
  core[006034] = 06114; code[006034] = &I06034;
  core[006035] = 04506; code[006035] = &I06035;
  core[006036] = 04521; code[006036] = &I06036;
  core[006037] = 07240; code[006037] = &I06037;
  core[006040] = 01127; code[006040] = &I06040;
  core[006041] = 05630; code[006041] = &I06041;
  core[006042] = 00000; code[006042] = &S06042;
  core[006043] = 03164; code[006043] = &I06043;
  core[006044] = 01314; code[006044] = &I06044;
  core[006045] = 03260; code[006045] = &I06045;
  core[006046] = 03210; code[006046] = &I06046;
  core[006047] = 04255; code[006047] = &I06047;
  core[006050] = 04255; code[006050] = &I06050;
  core[006051] = 02210; code[006051] = &I06051;
  core[006052] = 04255; code[006052] = &I06052;
  core[006053] = 04255; code[006053] = &D06053;
  core[006054] = 05642; code[006054] = &D06054;
  core[006055] = 00000; code[006055] = &S06055;
  core[006056] = 03163; code[006056] = &I06056;
  core[006057] = 01164; code[006057] = &L06057;
  core[006060] = 01204; code[006060] = &D06060;
  core[006061] = 07510; code[006061] = &I06061;
  core[006062] = 05267; code[006062] = &I06062;
  core[006063] = 03164; code[006063] = &I06063;
  core[006064] = 02163; code[006064] = &I06064;
  core[006065] = 02210; code[006065] = &I06065;
  core[006066] = 05257; code[006066] = &I06066;
  core[006067] = 07300; code[006067] = &L06067;
  core[006070] = 02260; code[006070] = &I06070;
  core[006071] = 01210; code[006071] = &I06071;
  core[006072] = 07650; code[006072] = &I06072;
  core[006073] = 05655; code[006073] = &I06073;
  core[006074] = 01163; code[006074] = &I06074;
  core[006075] = 01036; code[006075] = &I06075;
  core[006076] = 04512; code[006076] = &I06076;
  core[006077] = 05655; code[006077] = &I06077;
  core[006100] = 00000; code[006100] = &S06100;
  core[006101] = 03164; code[006101] = &I06101;
  core[006102] = 01164; code[006102] = &I06102;
  core[006103] = 07710; code[006103] = &I06103;
  core[006104] = 01035; code[006104] = &I06104;
  core[006105] = 01315; code[006105] = &D06105;
  core[006106] = 04512; code[006106] = &I06106;
  core[006107] = 01164; code[006107] = &I06107;
  core[006110] = 07510; code[006110] = &I06110;
  core[006111] = 07041; code[006111] = &I06111;
  core[006112] = 04242; code[006112] = &I06112;
  core[006113] = 05700; code[006113] = &I06113;
  core[006114] = 01204; code[006114] = &D06114;
  core[006115] = 00253; code[006115] = &D06115;
  core[006116] = 00255; code[006116] = &I06116;
  core[006117] = 07200; code[006117] = &L06117;
  core[006120] = 01051; code[006120] = &I06120;
  core[006121] = 07410; code[006121] = &I06121;
  core[006122] = 01133; code[006122] = &L06122;
  core[006123] = 07041; code[006123] = &I06123;
  core[006124] = 07450; code[006124] = &I06124;
  core[006125] = 01347; code[006125] = &I06125;
  core[006126] = 03164; code[006126] = &I06126;
  core[006127] = 01022; code[006127] = &I06127;
  core[006130] = 04512; code[006130] = &I06130;
  core[006131] = 01412; code[006131] = &L06131;
  core[006132] = 02157; code[006132] = &I06132;
  core[006133] = 05336; code[006133] = &I06133;
  core[006134] = 07240; code[006134] = &I06134;
  core[006135] = 03157; code[006135] = &I06135;
  core[006136] = 04750; code[006136] = &L06136;
  core[006137] = 07410; code[006137] = &D06137;
  core[006140] = 05331; code[006140] = &I06140;
  core[006141] = 01346; code[006141] = &I06141;
  core[006142] = 04512; code[006142] = &I06142;
  core[006143] = 01156; code[006143] = &I06143;
  core[006144] = 04300; code[006144] = &I06144;
  core[006145] = 05770; code[006145] = &L06145;
  core[006146] = 00305; code[006146] = &D06146;
  core[006147] = 07772; code[006147] = &D06147;
  core[006150] = 06437; code[006150] = &P06150;
  core[006151] = 00000; code[006151] = &S06151;
  core[006152] = 01143; code[006152] = &I06152;
  core[006153] = 04520; code[006153] = &I06153;
  core[006154] = 00071; code[006154] = &I06154;
  core[006155] = 04242; code[006155] = &I06155;
  core[006156] = 01022; code[006156] = &I06156;
  core[006157] = 04512; code[006157] = &I06157;
  core[006160] = 01143; code[006160] = &I06160;
  core[006161] = 00026; code[006161] = &I06161;
  core[006162] = 04242; code[006162] = &I06162;
  core[006163] = 01033; code[006163] = &I06163;
  core[006164] = 03142; code[006164] = &I06164;
  core[006165] = 04512; code[006165] = &I06165;
  core[006166] = 05751; code[006166] = &I06166;
  core[006167] = 00015; code[006167] = &D06167;
  core[006170] = 00000; code[006170] = &S06170;
  core[006171] = 01045; code[006171] = &I06171;
  core[006172] = 07700; code[006172] = &I06172;
  core[006173] = 05376; code[006173] = &I06173;
  core[006174] = 04450; code[006174] = &I06174;
  core[006175] = 01367; code[006175] = &I06175;
  core[006176] = 01033; code[006176] = &L06176;
  core[006177] = 04512; code[006177] = &I06177;
  core[006200] = 07240; code[006200] = &I06200;
  core[006201] = 01044; code[006201] = &I06201;
  core[006202] = 03044; code[006202] = &I06202;
  core[006203] = 03156; code[006203] = &L06203;
  core[006204] = 01044; code[006204] = &I06204;
  core[006205] = 07500; code[006205] = &I06205;
  core[006206] = 05220; code[006206] = &I06206;
  core[006207] = 01631; code[006207] = &I06207;
  core[006210] = 07700; code[006210] = &I06210;
  core[006211] = 05244; code[006211] = &I06211;
  core[006212] = 04407; code[006212] = &I06212;
  core[006213] = 03631; code[006213] = &I06213;
  core[006214] = 00000; code[006214] = &I06214;
  core[006215] = 07240; code[006215] = &I06215;
  core[006216] = 01156; code[006216] = &L06216;
  core[006217] = 05203; code[006217] = &I06217;
  core[006220] = 04407; code[006220] = &L06220;
  core[006221] = 03632; code[006221] = &I06221;
  core[006222] = 00000; code[006222] = &I06222;
  core[006223] = 07001; code[006223] = &I06223;
  core[006224] = 05216; code[006224] = &I06224;
  core[006225] = 07771; code[006225] = &D06225;
  core[006226] = 07772; code[006226] = &D06226;
  core[006227] = 00007; code[006227] = &D06227;
  core[006230] = 07766; code[006230] = &D06230;
  core[006231] = 05770; code[006231] = &P06231;
  core[006232] = 05773; code[006232] = &P06232;
  core[006233] = 05734; code[006233] = &P06233;
  core[006234] = 05742; code[006234] = &P06234;
  core[006235] = 07544; code[006235] = &D06235;
  core[006236] = 06122; code[006236] = &P06236;
  core[006237] = 06117; code[006237] = &P06237;
  core[006240] = 07040; code[006240] = &L06240;
  core[006241] = 01040; code[006241] = &I06241;
  core[006242] = 03040; code[006242] = &I06242;
  core[006243] = 05351; code[006243] = &I06243;
  core[006244] = 04633; code[006244] = &L06244;
  core[006245] = 01235; code[006245] = &I06245;
  core[006246] = 03012; code[006246] = &I06246;
  core[006247] = 04634; code[006247] = &I06247;
  core[006250] = 01162; code[006250] = &I06250;
  core[006251] = 05266; code[006251] = &I06251;
  core[006252] = 07110; code[006252] = &L06252;
  core[006253] = 03004; code[006253] = &I06253;
  core[006254] = 01045; code[006254] = &I06254;
  core[006255] = 07010; code[006255] = &I06255;
  core[006256] = 03045; code[006256] = &I06256;
  core[006257] = 01046; code[006257] = &I06257;
  core[006260] = 07010; code[006260] = &I06260;
  core[006261] = 03046; code[006261] = &I06261;
  core[006262] = 01047; code[006262] = &I06262;
  core[006263] = 07010; code[006263] = &I06263;
  core[006264] = 03047; code[006264] = &I06264;
  core[006265] = 01004; code[006265] = &I06265;
  core[006266] = 02044; code[006266] = &L06266;
  core[006267] = 05252; code[006267] = &I06267;
  core[006270] = 07440; code[006270] = &I06270;
  core[006271] = 05301; code[006271] = &I06271;
  core[006272] = 07240; code[006272] = &I06272;
  core[006273] = 01156; code[006273] = &I06273;
  core[006274] = 03156; code[006274] = &I06274;
  core[006275] = 01045; code[006275] = &I06275;
  core[006276] = 07650; code[006276] = &I06276;
  core[006277] = 03156; code[006277] = &I06277;
  core[006300] = 07410; code[006300] = &I06300;
  core[006301] = 03412; code[006301] = &L06301;
  core[006302] = 01225; code[006302] = &I06302;
  core[006303] = 03044; code[006303] = &I06303;
  core[006304] = 04634; code[006304] = &L06304;
  core[006305] = 01162; code[006305] = &I06305;
  core[006306] = 03412; code[006306] = &I06306;
  core[006307] = 02044; code[006307] = &I06307;
  core[006310] = 05304; code[006310] = &I06310;
  core[006311] = 01235; code[006311] = &I06311;
  core[006312] = 03012; code[006312] = &I06312;
  core[006313] = 01225; code[006313] = &I06313;
  core[006314] = 03157; code[006314] = &I06314;
  core[006315] = 01051; code[006315] = &I06315;
  core[006316] = 07450; code[006316] = &I06316;
  core[006317] = 05340; code[006317] = &I06317;
  core[006320] = 07041; code[006320] = &I06320;
  core[006321] = 01133; code[006321] = &I06321;
  core[006322] = 07550; code[006322] = &I06322;
  core[006323] = 05327; code[006323] = &I06323;
  core[006324] = 07200; code[006324] = &I06324;
  core[006325] = 01051; code[006325] = &I06325;
  core[006326] = 03133; code[006326] = &I06326;
  core[006327] = 01156; code[006327] = &L06327;
  core[006330] = 07500; code[006330] = &I06330;
  core[006331] = 07200; code[006331] = &I06331;
  core[006332] = 01051; code[006332] = &I06332;
  core[006333] = 07510; code[006333] = &I06333;
  core[006334] = 05362; code[006334] = &P06334;
  core[006335] = 01226; code[006335] = &I06335;
  core[006336] = 07500; code[006336] = &I06336;
  core[006337] = 07200; code[006337] = &I06337;
  core[006340] = 01227; code[006340] = &L06340;
  core[006341] = 03004; code[006341] = &I06341;
  core[006342] = 01235; code[006342] = &P06342;
  core[006343] = 01004; code[006343] = &I06343;
  core[006344] = 03040; code[006344] = &I06344;
  core[006345] = 01004; code[006345] = &I06345;
  core[006346] = 07041; code[006346] = &I06346;
  core[006347] = 03004; code[006347] = &I06347;
  core[006350] = 01631; code[006350] = &I06350;
  core[006351] = 02440; code[006351] = &L06351;
  core[006352] = 01440; code[006352] = &I06352;
  core[006353] = 01230; code[006353] = &I06353;
  core[006354] = 07710; code[006354] = &I06354;
  core[006355] = 05364; code[006355] = &I06355;
  core[006356] = 03440; code[006356] = &I06356;
  core[006357] = 02004; code[006357] = &I06357;
  core[006360] = 05240; code[006360] = &I06360;
  core[006361] = 02440; code[006361] = &I06361;
  core[006362] = 02156; code[006362] = &L06362;
  core[006363] = 07200; code[006363] = &I06363;
  core[006364] = 01051; code[006364] = &L06364;
  core[006365] = 07450; code[006365] = &I06365;
  core[006366] = 05636; code[006366] = &I06366;
  core[006367] = 07041; code[006367] = &I06367;
  core[006370] = 03164; code[006370] = &P06370;
  core[006371] = 01164; code[006371] = &I06371;
  core[006372] = 01156; code[006372] = &I06372;
  core[006373] = 07540; code[006373] = &P06373;
  core[006374] = 05637; code[006374] = &I06374;
  core[006375] = 01133; code[006375] = &I06375;
  core[006376] = 07500; code[006376] = &I06376;
  core[006377] = 07200; code[006377] = &I06377;
  core[006400] = 07041; code[006400] = &I06400;
  core[006401] = 01156; code[006401] = &I06401;
  core[006402] = 07141; code[006402] = &D06402;
  core[006403] = 03004; code[006403] = &I06403;
  core[006404] = 07430; code[006404] = &I06404;
  core[006405] = 05222; code[006405] = &I06405;
  core[006406] = 01156; code[006406] = &L06406;
  core[006407] = 01004; code[006407] = &I06407;
  core[006410] = 07650; code[006410] = &I06410;
  core[006411] = 05225; code[006411] = &I06411;
  core[006412] = 01004; code[006412] = &I06412;
  core[006413] = 07001; code[006413] = &I06413;
  core[006414] = 07710; code[006414] = &I06414;
  core[006415] = 01025; code[006415] = &I06415;
  core[006416] = 04237; code[006416] = &P06416;
  core[006417] = 05645; code[006417] = &I06417;
  core[006420] = 02004; code[006420] = &I06420;
  core[006421] = 05206; code[006421] = &I06421;
  core[006422] = 01022; code[006422] = &L06422;
  core[006423] = 04512; code[006423] = &I06423;
  core[006424] = 05206; code[006424] = &I06424;
  core[006425] = 07040; code[006425] = &L06425;
  core[006426] = 01156; code[006426] = &I06426;
  core[006427] = 03156; code[006427] = &I06427;
  core[006430] = 02157; code[006430] = &I06430;
  core[006431] = 05235; code[006431] = &I06431;
  core[006432] = 07040; code[006432] = &I06432;
  core[006433] = 03157; code[006433] = &I06433;
  core[006434] = 05216; code[006434] = &I06434;
  core[006435] = 01412; code[006435] = &L06435;
  core[006436] = 05216; code[006436] = &I06436;
  core[006437] = 00000; code[006437] = &S06437;
  core[006440] = 01036; code[006440] = &I06440;
  core[006441] = 04512; code[006441] = &I06441;
  core[006442] = 02164; code[006442] = &I06442;
  core[006443] = 02237; code[006443] = &I06443;
  core[006444] = 05637; code[006444] = &I06444;
  core[006445] = 06145; code[006445] = &P06445;
  core[006446] = 04521; code[006446] = &L06446;
  core[006447] = 04510; code[006447] = &I06447;
  core[006450] = 02377; code[006450] = &I06450;
  core[006451] = 07574; code[006451] = &I06451;
  core[006452] = 04526; code[006452] = &I06452;
  core[006453] = 07240; code[006453] = &I06453;
  core[006454] = 03037; code[006454] = &I06454;
  core[006455] = 06014; code[006455] = &I06455;
  core[006456] = 01317; code[006456] = &I06456;
  core[006457] = 01161; code[006457] = &I06457;
  core[006460] = 03113; code[006460] = &I06460;
  core[006461] = 04565; code[006461] = &L06461;
  core[006462] = 05261; code[006462] = &I06462;
  core[006463] = 05665; code[006463] = &I06463;
  core[006464] = 05246; code[006464] = &I06464;
  core[006465] = 00616; code[006465] = &P06465;
  core[006466] = 00000; code[006466] = &P06466;
  core[006467] = 01067; code[006467] = &L06467;
  core[006470] = 03156; code[006470] = &I06470;
  core[006471] = 03157; code[006471] = &I06471;
  core[006472] = 06001; code[006472] = &L06472;
  core[006473] = 01037; code[006473] = &I06473;
  core[006474] = 07700; code[006474] = &I06474;
  core[006475] = 05306; code[006475] = &I06475;
  core[006476] = 02157; code[006476] = &I06476;
  core[006477] = 05272; code[006477] = &I06477;
  core[006500] = 02156; code[006500] = &I06500;
  core[006501] = 05272; code[006501] = &I06501;
  core[006502] = 01161; code[006502] = &I06502;
  core[006503] = 03113; code[006503] = &I06503;
  core[006504] = 01054; code[006504] = &I06504;
  core[006505] = 05315; code[006505] = &I06505;
  core[006506] = 07040; code[006506] = &L06506;
  core[006507] = 03037; code[006507] = &I06507;
  core[006510] = 06016; code[006510] = &I06510;
  core[006511] = 00026; code[006511] = &I06511;
  core[006512] = 07450; code[006512] = &I06512;
  core[006513] = 05267; code[006513] = &I06513;
  core[006514] = 01015; code[006514] = &I06514;
  core[006515] = 03142; code[006515] = &L06515;
  core[006516] = 05666; code[006516] = &I06516;
  core[006517] = 04003; code[006517] = &D06517;
  core[006600] = 00000; code[006600] = &S06600;
  core[006601] = 07300; code[006601] = &L06601;
  core[006602] = 01600; code[006602] = &I06602;
  core[006603] = 07450; code[006603] = &I06603;
  core[006604] = 05600; code[006604] = &I06604;
  core[006605] = 00015; code[006605] = &I06605;
  core[006606] = 07640; code[006606] = &I06606;
  core[006607] = 01200; code[006607] = &I06607;
  core[006610] = 00024; code[006610] = &I06610;
  core[006611] = 03231; code[006611] = &I06611;
  core[006612] = 01600; code[006612] = &I06612;
  core[006613] = 00026; code[006613] = &I06613;
  core[006614] = 01231; code[006614] = &I06614;
  core[006615] = 03231; code[006615] = &I06615;
  core[006616] = 01600; code[006616] = &I06616;
  core[006617] = 02200; code[006617] = &I06617;
  core[006620] = 07106; code[006620] = &I06620;
  core[006621] = 07006; code[006621] = &I06621;
  core[006622] = 00031; code[006622] = &I06622;
  core[006623] = 01236; code[006623] = &I06623;
  core[006624] = 03235; code[006624] = &I06624;
  core[006625] = 01631; code[006625] = &I06625;
  core[006626] = 07430; code[006626] = &I06626;
  core[006627] = 03231; code[006627] = &I06627;
  core[006630] = 04504; code[006630] = &I06630;
  core[006631] = 00000; code[006631] = &P06631;
  core[006632] = 04505; code[006632] = &I06632;
  core[006633] = 00040; code[006633] = &I06633;
  core[006634] = 03043; code[006634] = &I06634;
  core[006635] = 05637; code[006635] = &D06635;
  core[006636] = 05637; code[006636] = &D06636;
  core[006637] = 07406; code[006637] = &P06637;
  core[006640] = 06720; code[006640] = &I06640;
  core[006641] = 06717; code[006641] = &I06641;
  core[006642] = 07077; code[006642] = &I06642;
  core[006643] = 07171; code[006643] = &I06643;
  core[006644] = 06647; code[006644] = &I06644;
  core[006645] = 06653; code[006645] = &I06645;
  core[006646] = 06762; code[006646] = &I06646;
  core[006647] = 04504; code[006647] = &L06647;
  core[006650] = 00040; code[006650] = &I06650;
  core[006651] = 01254; code[006651] = &I06651;
  core[006652] = 05256; code[006652] = &I06652;
  core[006653] = 04504; code[006653] = &I06653;
  core[006654] = 00044; code[006654] = &D06654;
  core[006655] = 01231; code[006655] = &I06655;
  core[006656] = 03260; code[006656] = &L06656;
  core[006657] = 04505; code[006657] = &I06657;
  core[006660] = 00000; code[006660] = &D06660;
  core[006661] = 05201; code[006661] = &I06661;
  core[006662] = 00000; code[006662] = &S06662;
  core[006663] = 01042; code[006663] = &I06663;
  core[006664] = 07141; code[006664] = &I06664;
  core[006665] = 03042; code[006665] = &I06665;
  core[006666] = 07024; code[006666] = &I06666;
  core[006667] = 01041; code[006667] = &I06667;
  core[006670] = 07041; code[006670] = &I06670;
  core[006671] = 03041; code[006671] = &I06671;
  core[006672] = 01004; code[006672] = &I06672;
  core[006673] = 07140; code[006673] = &I06673;
  core[006674] = 03004; code[006674] = &I06674;
  core[006675] = 05662; code[006675] = &I06675;
  core[006676] = 00000; code[006676] = &S06676;
  core[006677] = 07300; code[006677] = &I06677;
  core[006700] = 01047; code[006700] = &I06700;
  core[006701] = 07041; code[006701] = &I06701;
  core[006702] = 03047; code[006702] = &I06702;
  core[006703] = 07024; code[006703] = &I06703;
  core[006704] = 01046; code[006704] = &I06704;
  core[006705] = 07041; code[006705] = &I06705;
  core[006706] = 03046; code[006706] = &I06706;
  core[006707] = 07024; code[006707] = &I06707;
  core[006710] = 01045; code[006710] = &I06710;
  core[006711] = 07041; code[006711] = &I06711;
  core[006712] = 03045; code[006712] = &I06712;
  core[006713] = 01004; code[006713] = &P06713;
  core[006714] = 07140; code[006714] = &I06714;
  core[006715] = 03004; code[006715] = &I06715;
  core[006716] = 05676; code[006716] = &I06716;
  core[006717] = 04262; code[006717] = &I06717;
  core[006720] = 01045; code[006720] = &I06720;
  core[006721] = 07650; code[006721] = &I06721;
  core[006722] = 05247; code[006722] = &I06722;
  core[006723] = 01041; code[006723] = &I06723;
  core[006724] = 07650; code[006724] = &I06724;
  core[006725] = 05201; code[006725] = &I06725;
  core[006726] = 01040; code[006726] = &I06726;
  core[006727] = 07041; code[006727] = &I06727;
  core[006730] = 01044; code[006730] = &D06730;
  core[006731] = 07450; code[006731] = &I06731;
  core[006732] = 05357; code[006732] = &I06732;
  core[006733] = 07500; code[006733] = &I06733;
  core[006734] = 05346; code[006734] = &I06734;
  core[006735] = 01365; code[006735] = &I06735;
  core[006736] = 07510; code[006736] = &I06736;
  core[006737] = 05247; code[006737] = &I06737;
  core[006740] = 01364; code[006740] = &I06740;
  core[006741] = 03235; code[006741] = &I06741;
  core[006742] = 04767; code[006742] = &L06742;
  core[006743] = 02235; code[006743] = &I06743;
  core[006744] = 05342; code[006744] = &I06744;
  core[006745] = 05357; code[006745] = &D06745;
  core[006746] = 07041; code[006746] = &L06746;
  core[006747] = 01365; code[006747] = &D06747;
  core[006750] = 07510; code[006750] = &I06750;
  core[006751] = 05201; code[006751] = &I06751;
  core[006752] = 01364; code[006752] = &I06752;
  core[006753] = 03235; code[006753] = &I06753;
  core[006754] = 04766; code[006754] = &L06754;
  core[006755] = 02235; code[006755] = &I06755;
  core[006756] = 05354; code[006756] = &I06756;
  core[006757] = 04767; code[006757] = &L06757;
  core[006760] = 04766; code[006760] = &I06760;
  core[006761] = 04770; code[006761] = &I06761;
  core[006762] = 04771; code[006762] = &I06762;
  core[006763] = 05201; code[006763] = &I06763;
  core[006764] = 07751; code[006764] = &D06764;
  core[006765] = 00027; code[006765] = &D06765;
  core[006766] = 07271; code[006766] = &P06766;
  core[006767] = 07251; code[006767] = &P06767;
  core[006770] = 05713; code[006770] = &P06770;
  core[006771] = 07000; code[006771] = &P06771;
  core[006772] = 03347; code[006772] = &I06772;
  core[006773] = 03347; code[006773] = &I06773;
  core[006774] = 03330; code[006774] = &I06774;
  core[006775] = 03347; code[006775] = &I06775;
  core[006776] = 03347; code[006776] = &I06776;
  core[006777] = 03345; code[006777] = &I06777;
  core[007000] = 00000; code[007000] = &S07000;
  core[007001] = 07340; code[007001] = &I07001;
  core[007002] = 03004; code[007002] = &I07002;
  core[007003] = 01045; code[007003] = &I07003;
  core[007004] = 07450; code[007004] = &I07004;
  core[007005] = 01046; code[007005] = &I07005;
  core[007006] = 07450; code[007006] = &I07006;
  core[007007] = 01047; code[007007] = &I07007;
  core[007010] = 07650; code[007010] = &I07010;
  core[007011] = 05232; code[007011] = &I07011;
  core[007012] = 01045; code[007012] = &I07012;
  core[007013] = 07710; code[007013] = &I07013;
  core[007014] = 04450; code[007014] = &I07014;
  core[007015] = 03255; code[007015] = &I07015;
  core[007016] = 01045; code[007016] = &L07016;
  core[007017] = 07104; code[007017] = &I07017;
  core[007020] = 07710; code[007020] = &I07020;
  core[007021] = 05225; code[007021] = &I07021;
  core[007022] = 04237; code[007022] = &I07022;
  core[007023] = 02255; code[007023] = &I07023;
  core[007024] = 05216; code[007024] = &I07024;
  core[007025] = 02004; code[007025] = &L07025;
  core[007026] = 04450; code[007026] = &I07026;
  core[007027] = 01255; code[007027] = &I07027;
  core[007030] = 07041; code[007030] = &I07030;
  core[007031] = 01044; code[007031] = &I07031;
  core[007032] = 03044; code[007032] = &L07032;
  core[007033] = 03047; code[007033] = &I07033;
  core[007034] = 05600; code[007034] = &I07034;
  core[007035] = 06601; code[007035] = &P07035;
  core[007036] = 06662; code[007036] = &P07036;
  core[007037] = 00000; code[007037] = &S07037;
  core[007040] = 01047; code[007040] = &I07040;
  core[007041] = 07104; code[007041] = &I07041;
  core[007042] = 03047; code[007042] = &I07042;
  core[007043] = 04245; code[007043] = &I07043;
  core[007044] = 05637; code[007044] = &I07044;
  core[007045] = 00000; code[007045] = &S07045;
  core[007046] = 01046; code[007046] = &I07046;
  core[007047] = 07004; code[007047] = &I07047;
  core[007050] = 03046; code[007050] = &I07050;
  core[007051] = 01045; code[007051] = &I07051;
  core[007052] = 07004; code[007052] = &I07052;
  core[007053] = 03045; code[007053] = &I07053;
  core[007054] = 05645; code[007054] = &I07054;
  core[007055] = 00000; code[007055] = &S07055;
  core[007056] = 07340; code[007056] = &I07056;
  core[007057] = 03004; code[007057] = &I07057;
  core[007060] = 01045; code[007060] = &I07060;
  core[007061] = 07450; code[007061] = &I07061;
  core[007062] = 05635; code[007062] = &I07062;
  core[007063] = 07710; code[007063] = &D07063;
  core[007064] = 04450; code[007064] = &I07064;
  core[007065] = 01045; code[007065] = &I07065;
  core[007066] = 03162; code[007066] = &I07066;
  core[007067] = 01046; code[007067] = &I07067;
  core[007070] = 03163; code[007070] = &I07070;
  core[007071] = 01041; code[007071] = &I07071;
  core[007072] = 07710; code[007072] = &D07072;
  core[007073] = 04636; code[007073] = &I07073;
  core[007074] = 01004; code[007074] = &I07074;
  core[007075] = 03157; code[007075] = &I07075;
  core[007076] = 05655; code[007076] = &I07076;
  core[007077] = 01263; code[007077] = &I07077;
  core[007100] = 03272; code[007100] = &I07100;
  core[007101] = 04255; code[007101] = &I07101;
  core[007102] = 01042; code[007102] = &I07102;
  core[007103] = 04333; code[007103] = &I07103;
  core[007104] = 07301; code[007104] = &I07104;
  core[007105] = 01044; code[007105] = &I07105;
  core[007106] = 01040; code[007106] = &I07106;
  core[007107] = 03044; code[007107] = &I07107;
  core[007110] = 01272; code[007110] = &I07110;
  core[007111] = 03047; code[007111] = &I07111;
  core[007112] = 01237; code[007112] = &I07112;
  core[007113] = 03046; code[007113] = &I07113;
  core[007114] = 01041; code[007114] = &I07114;
  core[007115] = 04333; code[007115] = &I07115;
  core[007116] = 01047; code[007116] = &I07116;
  core[007117] = 03047; code[007117] = &I07117;
  core[007120] = 07004; code[007120] = &I07120;
  core[007121] = 01272; code[007121] = &I07121;
  core[007122] = 01046; code[007122] = &I07122;
  core[007123] = 03046; code[007123] = &I07123;
  core[007124] = 07004; code[007124] = &I07124;
  core[007125] = 01237; code[007125] = &I07125;
  core[007126] = 03045; code[007126] = &I07126;
  core[007127] = 04200; code[007127] = &I07127;
  core[007130] = 02157; code[007130] = &L07130;
  core[007131] = 04450; code[007131] = &I07131;
  core[007132] = 05635; code[007132] = &I07132;
  core[007133] = 00000; code[007133] = &S07133;
  core[007134] = 03200; code[007134] = &I07134;
  core[007135] = 03237; code[007135] = &I07135;
  core[007136] = 03272; code[007136] = &I07136;
  core[007137] = 01370; code[007137] = &I07137;
  core[007140] = 03255; code[007140] = &I07140;
  core[007141] = 07100; code[007141] = &I07141;
  core[007142] = 01200; code[007142] = &L07142;
  core[007143] = 07010; code[007143] = &I07143;
  core[007144] = 03200; code[007144] = &I07144;
  core[007145] = 07420; code[007145] = &I07145;
  core[007146] = 05355; code[007146] = &I07146;
  core[007147] = 07100; code[007147] = &I07147;
  core[007150] = 01163; code[007150] = &I07150;
  core[007151] = 01272; code[007151] = &I07151;
  core[007152] = 03272; code[007152] = &I07152;
  core[007153] = 07004; code[007153] = &I07153;
  core[007154] = 01162; code[007154] = &I07154;
  core[007155] = 01237; code[007155] = &L07155;
  core[007156] = 07010; code[007156] = &I07156;
  core[007157] = 03237; code[007157] = &I07157;
  core[007160] = 01272; code[007160] = &I07160;
  core[007161] = 07010; code[007161] = &I07161;
  core[007162] = 03272; code[007162] = &I07162;
  core[007163] = 02255; code[007163] = &I07163;
  core[007164] = 05342; code[007164] = &I07164;
  core[007165] = 01200; code[007165] = &I07165;
  core[007166] = 07010; code[007166] = &I07166;
  core[007167] = 05733; code[007167] = &I07167;
  core[007170] = 07764; code[007170] = &D07170;
  core[007171] = 01041; code[007171] = &I07171;
  core[007172] = 07650; code[007172] = &I07172;
  core[007173] = 04526; code[007173] = &I07173;
  core[007174] = 01062; code[007174] = &I07174;
  core[007175] = 03272; code[007175] = &I07175;
  core[007176] = 04255; code[007176] = &I07176;
  core[007177] = 01040; code[007177] = &I07177;
  core[007200] = 07041; code[007200] = &I07200;
  core[007201] = 01044; code[007201] = &I07201;
  core[007202] = 07001; code[007202] = &I07202;
  core[007203] = 03044; code[007203] = &I07203;
  core[007204] = 03045; code[007204] = &I07204;
  core[007205] = 03046; code[007205] = &I07205;
  core[007206] = 01314; code[007206] = &I07206;
  core[007207] = 03271; code[007207] = &I07207;
  core[007210] = 05226; code[007210] = &I07210;
  core[007211] = 07420; code[007211] = &L07211;
  core[007212] = 05216; code[007212] = &I07212;
  core[007213] = 03162; code[007213] = &I07213;
  core[007214] = 01164; code[007214] = &I07214;
  core[007215] = 03163; code[007215] = &I07215;
  core[007216] = 07200; code[007216] = &L07216;
  core[007217] = 04647; code[007217] = &I07217;
  core[007220] = 01163; code[007220] = &I07220;
  core[007221] = 07004; code[007221] = &I07221;
  core[007222] = 03163; code[007222] = &I07222;
  core[007223] = 01162; code[007223] = &I07223;
  core[007224] = 07004; code[007224] = &I07224;
  core[007225] = 03162; code[007225] = &I07225;
  core[007226] = 07100; code[007226] = &L07226;
  core[007227] = 01042; code[007227] = &I07227;
  core[007230] = 01163; code[007230] = &I07230;
  core[007231] = 03164; code[007231] = &I07231;
  core[007232] = 07004; code[007232] = &I07232;
  core[007233] = 01041; code[007233] = &I07233;
  core[007234] = 01162; code[007234] = &I07234;
  core[007235] = 02271; code[007235] = &I07235;
  core[007236] = 05211; code[007236] = &I07236;
  core[007237] = 07210; code[007237] = &I07237;
  core[007240] = 03047; code[007240] = &I07240;
  core[007241] = 04650; code[007241] = &I07241;
  core[007242] = 02157; code[007242] = &I07242;
  core[007243] = 05646; code[007243] = &I07243;
  core[007244] = 04450; code[007244] = &I07244;
  core[007245] = 05646; code[007245] = &I07245;
  core[007246] = 06601; code[007246] = &P07246;
  core[007247] = 07045; code[007247] = &P07247;
  core[007250] = 07000; code[007250] = &P07250;
  core[007251] = 00000; code[007251] = &S07251;
  core[007252] = 07300; code[007252] = &I07252;
  core[007253] = 01045; code[007253] = &I07253;
  core[007254] = 07510; code[007254] = &I07254;
  core[007255] = 07020; code[007255] = &I07255;
  core[007256] = 07010; code[007256] = &L07256;
  core[007257] = 03045; code[007257] = &I07257;
  core[007260] = 01046; code[007260] = &I07260;
  core[007261] = 07010; code[007261] = &I07261;
  core[007262] = 03046; code[007262] = &I07262;
  core[007263] = 01047; code[007263] = &I07263;
  core[007264] = 07010; code[007264] = &I07264;
  core[007265] = 03047; code[007265] = &I07265;
  core[007266] = 02044; code[007266] = &I07266;
  core[007267] = 05651; code[007267] = &I07267;
  core[007270] = 05651; code[007270] = &I07270;
  core[007271] = 00000; code[007271] = &S07271;
  core[007272] = 07300; code[007272] = &I07272;
  core[007273] = 01041; code[007273] = &I07273;
  core[007274] = 07510; code[007274] = &I07274;
  core[007275] = 07020; code[007275] = &I07275;
  core[007276] = 07010; code[007276] = &I07276;
  core[007277] = 03041; code[007277] = &I07277;
  core[007300] = 01042; code[007300] = &I07300;
  core[007301] = 07010; code[007301] = &I07301;
  core[007302] = 03042; code[007302] = &I07302;
  core[007303] = 01043; code[007303] = &I07303;
  core[007304] = 07010; code[007304] = &I07304;
  core[007305] = 03043; code[007305] = &I07305;
  core[007306] = 02040; code[007306] = &I07306;
  core[007307] = 05671; code[007307] = &I07307;
  core[007310] = 05671; code[007310] = &I07310;
  core[007311] = 00000; code[007311] = &S07311;
  core[007312] = 07300; code[007312] = &I07312;
  core[007313] = 01044; code[007313] = &P07313;
  core[007314] = 07750; code[007314] = &D07314;
  core[007315] = 03044; code[007315] = &I07315;
  core[007316] = 01044; code[007316] = &I07316;
  core[007317] = 01331; code[007317] = &I07317;
  core[007320] = 03271; code[007320] = &I07320;
  core[007321] = 07430; code[007321] = &I07321;
  core[007322] = 05711; code[007322] = &I07322;
  core[007323] = 04251; code[007323] = &L07323;
  core[007324] = 02271; code[007324] = &I07324;
  core[007325] = 05323; code[007325] = &I07325;
  core[007326] = 03047; code[007326] = &I07326;
  core[007327] = 01046; code[007327] = &I07327;
  core[007330] = 05711; code[007330] = &I07330;
  core[007331] = 07751; code[007331] = &D07331;
  core[007332] = 00000; code[007332] = &S07332;
  core[007333] = 03045; code[007333] = &I07333;
  core[007334] = 03046; code[007334] = &I07334;
  core[007335] = 03047; code[007335] = &I07335;
  core[007336] = 01005; code[007336] = &I07336;
  core[007337] = 03044; code[007337] = &I07337;
  core[007340] = 04251; code[007340] = &I07340;
  core[007341] = 04650; code[007341] = &I07341;
  core[007342] = 05732; code[007342] = &I07342;
  core[007343] = 07037; code[007343] = &P07343;
  core[007344] = 05713; code[007344] = &P07344;
  core[007345] = 07774; code[007345] = &D07345;
  core[007346] = 04421; code[007346] = &D07346;
  core[007347] = 03040; code[007347] = &I07347;
  core[007350] = 00001; code[007350] = &I07350;
  core[007351] = 04407; code[007351] = &I07351;
  core[007352] = 05346; code[007352] = &I07352;
  core[007353] = 00000; code[007353] = &I07353;
  core[007354] = 04504; code[007354] = &I07354;
  core[007355] = 07346; code[007355] = &I07355;
  core[007356] = 04505; code[007356] = &I07356;
  core[007357] = 00041; code[007357] = &I07357;
  core[007360] = 01345; code[007360] = &I07360;
  core[007361] = 03156; code[007361] = &I07361;
  core[007362] = 04743; code[007362] = &L07362;
  core[007363] = 02156; code[007363] = &I07363;
  core[007364] = 05362; code[007364] = &I07364;
  core[007365] = 04744; code[007365] = &I07365;
  core[007366] = 04743; code[007366] = &I07366;
  core[007367] = 04744; code[007367] = &I07367;
  core[007370] = 04504; code[007370] = &I07370;
  core[007371] = 00045; code[007371] = &I07371;
  core[007372] = 04505; code[007372] = &I07372;
  core[007373] = 07346; code[007373] = &I07373;
  core[007374] = 03047; code[007374] = &I07374;
  core[007375] = 03044; code[007375] = &I07375;
  core[007376] = 01045; code[007376] = &I07376;
  core[007377] = 07700; code[007377] = &I07377;
  core[007400] = 05500; code[007400] = &I07400;
  core[007401] = 02046; code[007401] = &I07401;
  core[007402] = 07410; code[007402] = &I07402;
  core[007403] = 02045; code[007403] = &I07403;
  core[007404] = 04450; code[007404] = &I07404;
  core[007405] = 05500; code[007405] = &I07405;
  core[007406] = 01407; code[007406] = &L07406;
  core[007407] = 04503; code[007407] = &I07407;
  core[007410] = 04504; code[007410] = &D07410;
  core[007411] = 00044; code[007411] = &I07411;
  core[007412] = 04505; code[007412] = &I07412;
  core[007413] = 07545; code[007413] = &I07413;
  core[007414] = 04504; code[007414] = &I07414;
  core[007415] = 00040; code[007415] = &I07415;
  core[007416] = 04505; code[007416] = &I07416;
  core[007417] = 00044; code[007417] = &I07417;
  core[007420] = 04452; code[007420] = &I07420;
  core[007421] = 07710; code[007421] = &I07421;
  core[007422] = 07001; code[007422] = &I07422;
  core[007423] = 01045; code[007423] = &I07423;
  core[007424] = 07640; code[007424] = &I07424;
  core[007425] = 04526; code[007425] = &I07425;
  core[007426] = 01046; code[007426] = &I07426;
  core[007427] = 03350; code[007427] = &I07427;
  core[007430] = 04407; code[007430] = &I07430;
  core[007431] = 05661; code[007431] = &I07431;
  core[007432] = 00000; code[007432] = &I07432;
  core[007433] = 01350; code[007433] = &I07433;
  core[007434] = 07450; code[007434] = &I07434;
  core[007435] = 05255; code[007435] = &I07435;
  core[007436] = 07500; code[007436] = &I07436;
  core[007437] = 05246; code[007437] = &I07437;
  core[007440] = 04407; code[007440] = &I07440;
  core[007441] = 04345; code[007441] = &I07441;
  core[007442] = 06345; code[007442] = &I07442;
  core[007443] = 05661; code[007443] = &I07443;
  core[007444] = 00000; code[007444] = &I07444;
  core[007445] = 05250; code[007445] = &I07445;
  core[007446] = 07041; code[007446] = &L07446;
  core[007447] = 03350; code[007447] = &I07447;
  core[007450] = 04407; code[007450] = &L07450;
  core[007451] = 03345; code[007451] = &I07451;
  core[007452] = 00000; code[007452] = &I07452;
  core[007453] = 02350; code[007453] = &I07453;
  core[007454] = 05250; code[007454] = &I07454;
  core[007455] = 01413; code[007455] = &L07455;
  core[007456] = 03407; code[007456] = &I07456;
  core[007457] = 05660; code[007457] = &I07457;
  core[007460] = 06601; code[007460] = &P07460;
  core[007461] = 01573; code[007461] = &P07461;
  core[007462] = 01045; code[007462] = &I07462;
  core[007463] = 07510; code[007463] = &I07463;
  core[007464] = 04526; code[007464] = &I07464;
  core[007465] = 07650; code[007465] = &I07465;
  core[007466] = 05500; code[007466] = &I07466;
  core[007467] = 01044; code[007467] = &I07467;
  core[007470] = 07510; code[007470] = &I07470;
  core[007471] = 07020; code[007471] = &I07471;
  core[007472] = 07010; code[007472] = &I07472;
  core[007473] = 03044; code[007473] = &I07473;
  core[007474] = 01334; code[007474] = &I07474;
  core[007475] = 03045; code[007475] = &I07475;
  core[007476] = 04407; code[007476] = &L07476;
  core[007477] = 06345; code[007477] = &D07477;
  core[007500] = 05560; code[007500] = &I07500;
  core[007501] = 04345; code[007501] = &I07501;
  core[007502] = 01345; code[007502] = &I07502;
  core[007503] = 00000; code[007503] = &I07503;
  core[007504] = 07040; code[007504] = &I07504;
  core[007505] = 01044; code[007505] = &I07505;
  core[007506] = 03044; code[007506] = &I07506;
  core[007507] = 01044; code[007507] = &I07507;
  core[007510] = 07041; code[007510] = &I07510;
  core[007511] = 01345; code[007511] = &I07511;
  core[007512] = 07640; code[007512] = &I07512;
  core[007513] = 05276; code[007513] = &I07513;
  core[007514] = 01045; code[007514] = &I07514;
  core[007515] = 07041; code[007515] = &I07515;
  core[007516] = 01346; code[007516] = &I07516;
  core[007517] = 07640; code[007517] = &I07517;
  core[007520] = 05276; code[007520] = &I07520;
  core[007521] = 01046; code[007521] = &I07521;
  core[007522] = 07041; code[007522] = &I07522;
  core[007523] = 01347; code[007523] = &I07523;
  core[007524] = 07450; code[007524] = &I07524;
  core[007525] = 05500; code[007525] = &I07525;
  core[007526] = 07500; code[007526] = &I07526;
  core[007527] = 07041; code[007527] = &I07527;
  core[007530] = 07001; code[007530] = &I07530;
  core[007531] = 07650; code[007531] = &I07531;
  core[007532] = 05500; code[007532] = &I07532;
  core[007533] = 05276; code[007533] = &I07533;
  core[007534] = 03015; code[007534] = &D07534;
  core[007535] = 01045; code[007535] = &I07535;
  core[007536] = 07450; code[007536] = &I07536;
  core[007537] = 05343; code[007537] = &I07537;
  core[007540] = 07710; code[007540] = &L07540;
  core[007541] = 01034; code[007541] = &I07541;
  core[007542] = 07001; code[007542] = &I07542;
  core[007543] = 04430; code[007543] = &L07543;
  core[007544] = 05500; code[007544] = &I07544;
  core[007545] = 00000; code[007545] = &D07545;
  core[007546] = 00000; code[007546] = &D07546;
  core[007547] = 00000; code[007547] = &D07547;
  core[007550] = 00000; code[007550] = &D07550;
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

