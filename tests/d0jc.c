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
void P00005() { lac &= (010000|core[000000]);  }
void L00006() { lac ^= 07777; lac++;  }
void D00007() { lac += core[000135];  }
void I00010() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00011() { npc = (ib<<12)+core[105]; inh = 0;  }
void D00012() { lac += core[000132];  }
void I00013() { lac ^= 07777; lac++;  }
void I00014() { lac += core[000000];  }
void D00015() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00016() { npc = (ib<<12)+core[105]; inh = 0;  }
void L00017() { lac += core[000155];  }
void D00020() { core[(df<<12)+core[91]] = lac & 07777; lac &= 010000; code[(df<<12)+core[91]] = &emul8;  }
void I00021() { lac += core[000155];  }
void I00022() { core[(df<<12)+core[89]] = lac & 07777; lac &= 010000; code[(df<<12)+core[89]] = &emul8;  }
void I00023() { lac ^= 07777;  }
void I00024() { lac += core[000000];  }
void I00025() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00026() { lac += core[000155];  }
void I00027() { core[(df<<12)+core[0]] = lac & 07777; lac &= 010000; code[(df<<12)+core[0]] = &emul8;  }
void I00030() { lac += core[000155];  }
void I00031() { core[(df<<12)+core[92]] = lac & 07777; lac &= 010000; code[(df<<12)+core[92]] = &emul8;  }
void P00032() { lac++;  }
void I00033() { lac += core[000043];  }
void I00034() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void I00035() { lac += core[000043];  }
void I00036() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00037() { npc = (ib<<12)+core[34]; inh = 0;  }
void D00040() { npc = (ib<<12)+core[33]; inh = 0;  }
void P00041() { lac &= (010000|core[000146]);  }
void P00042() { lac &= (010000|core[000020]);  }
void D00043() { lac &= (010000|core[000000]);  }
void D00044() { lac &= (010000|core[000000]);  }
void D00045() { emul8();  }
void D00046() { emul8();  }
void D00047() { lac &= (010000|core[000015]);  }
void D00050() { lac &= (010000|core[000012]);  }
void D00051() { lac &= (010000|core[000012]);  }
void I00052() { lac &= (010000|core[000106]);  }
void I00053() { lac &= (010000|core[000040]);  }
void D00054() { lac &= (010000|core[000000]);  }
void D00055() { lac &= (010000|core[000000]);  }
void D00056() { lac &= (010000|core[000000]);  }
void P00057() { lac &= (010000|core[000000]);  }
void D00060() { lac &= (010000|core[000040]);  }
void I00061() { lac &= (010000|core[000124]);  }
void I00062() { lac &= (010000|core[000117]);  }
void I00063() { lac &= (010000|core[000040]);  }
void D00064() { lac &= (010000|core[000000]);  }
void D00065() { lac &= (010000|core[000000]);  }
void D00066() { lac &= (010000|core[000000]);  }
void D00067() { lac &= (010000|core[000000]);  }
void I00070() { lac &= (010000|core[000015]);  }
void I00071() { lac &= (010000|core[000012]);  }
void I00072() { lac &= (010000|core[000177]);  }
void I00073() { lac &= (010000|core[000050]);  }
void I00074() { lac &= (010000|core[000124]);  }
void D00075() { lac &= (010000|core[000117]);  }
void I00076() { lac &= (010000|core[000051]);  }
void I00077() { lac &= (010000|core[000040]);  }
void I00100() { lac &= (010000|core[000075]);  }
void I00101() { lac &= (010000|core[000040]);  }
void D00102() { lac &= (010000|core[000000]);  }
void D00103() { lac &= (010000|core[000000]);  }
void D00104() { lac &= (010000|core[000000]);  }
void D00105() { lac &= (010000|core[000000]);  }
void D00106() { lac &= (010000|core[000015]);  }
void P00107() { lac &= (010000|core[000012]);  }
void I00110() { lac &= (010000|core[000177]);  }
void I00111() { lac &= (010000|core[000050]);  }
void D00112() { lac &= (010000|core[000000]);  }
void D00113() { lac &= (010000|core[000000]);  }
void D00114() { lac &= (010000|core[000000]);  }
void D00115() { lac &= (010000|core[000000]);  }
void I00116() { lac &= (010000|core[000051]);  }
void D00117() { lac &= (010000|core[000040]);  }
void I00120() { lac &= (010000|core[000075]);  }
void I00121() { lac &= (010000|core[000040]);  }
void D00122() { lac &= (010000|core[000000]);  }
void D00123() { lac &= (010000|core[000000]);  }
void D00124() { lac &= (010000|core[000000]);  }
void P00125() { lac &= (010000|core[000000]);  }
void I00126() { lac &= (010000|core[000007]);  }
void P00127() { lac &= (010000|core[000000]);  }
void D00130() { emul8();  }
void P00131() { lac &= (010000|core[000000]);  }
void D00132() { lac &= (010000|core[000000]);  }
void P00133() { lac &= (010000|core[000000]);  }
void P00134() { lac &= (010000|core[000000]);  }
void D00135() { lac &= (010000|core[000000]);  }
void D00136() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void D00137() { lac &= (010000|core[000003]);  }
void D00140() { lac &= 010000;  }
void D00141() { lac &= (010000|core[000000]);  }
void D00142() { emul8();  }
void D00143() { lac &= (010000|core[000000]);  }
void D00144() { lac &= (010000|core[000000]);  }
void D00145() { lac &= (010000|core[000000]);  }
void D00146() { lac &= (010000|core[000000]);  }
void D00147() { lac &= (010000|core[000007]);  }
void D00150() { lac &= (010000|core[000060]);  }
void P00151() { lac &= (010000|core[(df<<12)+core[0]]);  }
void P00152() { lac &= (010000|core[000127]);  }
void P00153() { lac &= (010000|core[000130]);  }
void D00154() { lac &= (010000|core[000047]);  }
void D00155() { hlt = 1;  }
void D00156() { core[(ib<<12)+core[89]] = 00157; npc = (ib<<12)+core[89]+1; code[(ib<<12)+core[89]] = &emul8; inh = 0;  }
void S00157() { lac &= (010000|core[000000]);  }
void I00160() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00161() { lac += core[000172];  }
void I00162() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I00163() { lac += core[000173];  }
void I00164() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I00165() { lac += core[000174];  }
void I00166() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I00167() { lac += core[000175];  }
void I00170() { core[(df<<12)+core[126]] = lac & 07777; lac &= 010000; code[(df<<12)+core[126]] = &emul8;  }
void I00171() { npc = (ib<<12)+core[111]; inh = 0;  }
void D00172() { lac &= 010000;  }
void D00173() { lac += core[(df<<12)+core[89]];  }
void D00174() { npc = 000006; inh = 0;  }
void D00175() { lac &= 010000;  }
void P00176() { lac &= (010000|core[000000]);  }
void D00200() { core[000157] = 00201; npc = 000157+1; code[000157] = &emul8; inh = 0;  }
void I00201() { lac += core[000140];  }
void I00202() { lac ^= 07777; lac++;  }
void I00203() { core[000131] = lac & 07777; lac &= 010000; code[000131] = &emul8;  }
void L00204() { lac += core[000155];  }
void I00205() { core[(df<<12)+core[89]] = lac & 07777; lac &= 010000; code[(df<<12)+core[89]] = &emul8;  }
void I00206() { lac += core[000131];  }
void I00207() { lac++;  }
void I00210() { core[000131] = lac & 07777; lac &= 010000; code[000131] = &emul8;  }
void I00211() { lac += core[000131];  }
void D00212() { lac += core[000141];  }
void I00213() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00214() { npc = 000204; inh = 0;  }
void D00215() { lac += core[000045];  }
void I00216() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I00217() { core[000043] = lac & 07777; lac &= 010000; code[000043] = &emul8;  }
void L00220() { lac &= 010000; lac |= swr;  }
void I00221() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00222() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00223() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00224() { npc = 000246; inh = 0;  }
void L00225() { lac += core[000136];  }
void I00226() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I00227() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00230() { lac += core[000137];  }
void I00231() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I00232() { lac += core[000136];  }
void I00233() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00234() { npc = 000241; inh = 0;  }
void I00235() { lac += core[000140];  }
void I00236() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00237() { npc = 000225; inh = 0;  }
void I00240() { npc = 000244; inh = 0;  }
void L00241() { lac += core[000141];  }
void I00242() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00243() { npc = 000225; inh = 0;  }
void L00244() { lac += core[000136];  }
void I00245() { core[000133] = lac & 07777; lac &= 010000; code[000133] = &emul8;  }
void L00246() { lac += core[000133];  }
void I00247() { lac++;  }
void I00250() { core[000135] = lac & 07777; lac &= 010000; code[000135] = &emul8;  }
void I00251() { lac ^= 07777;  }
void I00252() { lac += core[000133];  }
void I00253() { core[000134] = lac & 07777; lac &= 010000; code[000134] = &emul8;  }
void I00254() { lac &= 010000; lac |= swr;  }
void I00255() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00256() { lac = (lac<<2) + ((lac>>11)&3);  }
void I00257() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00260() { npc = 000302; inh = 0;  }
void L00261() { lac += core[000136];  }
void I00262() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I00263() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00264() { lac += core[000137];  }
void I00265() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I00266() { lac += core[000136];  }
void I00267() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00270() { npc = 000275; inh = 0;  }
void I00271() { lac += core[000140];  }
void I00272() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00273() { npc = 000261; inh = 0;  }
void I00274() { npc = 000300; inh = 0;  }
void L00275() { lac += core[000141];  }
void I00276() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00277() { npc = 000261; inh = 0;  }
void L00300() { lac += core[000136];  }
void I00301() { core[000131] = lac & 07777; lac &= 010000; code[000131] = &emul8;  }
void L00302() { lac += core[000131];  }
void D00303() { lac++;  }
void I00304() { core[000132] = lac & 07777; lac &= 010000; code[000132] = &emul8;  }
void I00305() { lac += core[000133];  }
void I00306() { lac ^= 07777; lac++;  }
void I00307() { lac += core[000131];  }
void I00310() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I00311() { npc = 000220; inh = 0;  }
void D00312() { lac ^= 07777;  }
void I00313() { emul8();  }
void I00314() { emul8();  }
void L00315() { emul8();  }
void I00316() { npc = 000315; inh = 0;  }
void I00317() { lac &= 010000;  }
void I00320() { lac += core[000142];  }
void I00321() { core[(df<<12)+core[92]] = lac & 07777; lac &= 010000; code[(df<<12)+core[92]] = &emul8;  }
void I00322() { lac += core[000156];  }
void I00323() { core[(df<<12)+core[91]] = lac & 07777; lac &= 010000; code[(df<<12)+core[91]] = &emul8;  }
void I00324() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00325() { npc = (ib<<12)+core[92]; inh = 0;  }
void I00326() { hlt = 1;  }
void P00327() { lac &= (010000|core[000000]);  }
void L00330() { core[000146] = lac & 07777; lac &= 010000; code[000146] = &emul8;  }
void I00331() { lac += core[000146];  }
void I00332() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00333() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00334() { core[000145] = lac & 07777; lac &= 010000; code[000145] = &emul8;  }
void I00335() { lac += core[000145];  }
void I00336() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00337() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00340() { core[000144] = lac & 07777; lac &= 010000; code[000144] = &emul8;  }
void I00341() { lac += core[000144];  }
void I00342() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I00343() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00344() { core[000143] = lac & 07777; lac &= 010000; code[000143] = &emul8;  }
void I00345() { npc = (ib<<12)+core[215]; inh = 0;  }
void L00346() { lac += core[000044];  }
void I00347() { lac++;  }
void I00350() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I00351() { lac += core[000044];  }
void I00352() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00353() { npc = (ib<<12)+core[34]; inh = 0;  }
void I00354() { lac += core[000373];  }
void I00355() { core[000127] = lac & 07777; lac &= 010000; code[000127] = &emul8;  }
void L00356() { lac += core[000127];  }
void I00357() { lac++;  }
void I00360() { core[000127] = lac & 07777; lac &= 010000; code[000127] = &emul8;  }
void I00361() { lac += core[(df<<12)+core[87]];  }
void I00362() { emul8();  }
void L00363() { emul8();  }
void I00364() { npc = 000363; inh = 0;  }
void I00365() { lac += core[000046];  }
void I00366() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00367() { npc = 000356; inh = 0;  }
void I00370() { lac += core[000045];  }
void I00371() { core[000044] = lac & 07777; lac &= 010000; code[000044] = &emul8;  }
void I00372() { npc = (ib<<12)+core[34]; inh = 0;  }
void D00373() { lac &= (010000|core[000373]);  }
void I00374() { lac &= (010000|core[000215]);  }
void I00375() { lac &= (010000|core[000212]);  }
void I00376() { lac &= (010000|core[000312]);  }
void I00377() { lac &= (010000|core[000303]);  }
void L00400() { lac += core[000404];  }
void I00401() { core[(df<<12)+core[106]] = lac & 07777; lac &= 010000; code[(df<<12)+core[106]] = &emul8;  }
void I00402() { lac += core[000133];  }
void I00403() { npc = (ib<<12)+core[107]; inh = 0;  }
void D00404() { lac &= (010000|core[(df<<12)+core[5]]);  }
void I00405() { lac += core[000143];  }
void I00406() { lac &= (010000|core[000147]);  }
void I00407() { lac += core[000150];  }
void I00410() { core[000054] = lac & 07777; lac &= 010000; code[000054] = &emul8;  }
void I00411() { lac += core[000144];  }
void I00412() { lac &= (010000|core[000147]);  }
void I00413() { lac += core[000150];  }
void I00414() { core[000055] = lac & 07777; lac &= 010000; code[000055] = &emul8;  }
void I00415() { lac += core[000145];  }
void I00416() { lac &= (010000|core[000147]);  }
void I00417() { lac += core[000150];  }
void I00420() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I00421() { lac += core[000146];  }
void I00422() { lac &= (010000|core[000147]);  }
void I00423() { lac += core[000150];  }
void I00424() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I00425() { lac += core[000431];  }
void I00426() { core[(df<<12)+core[106]] = lac & 07777; lac &= 010000; code[(df<<12)+core[106]] = &emul8;  }
void I00427() { lac += core[000131];  }
void I00430() { npc = (ib<<12)+core[107]; inh = 0;  }
void D00431() { lac &= (010000|core[(df<<12)+core[26]]);  }
void I00432() { lac += core[000143];  }
void I00433() { lac &= (010000|core[000147]);  }
void I00434() { lac += core[000150];  }
void I00435() { core[000064] = lac & 07777; lac &= 010000; code[000064] = &emul8;  }
void I00436() { lac += core[000144];  }
void I00437() { lac &= (010000|core[000147]);  }
void I00440() { lac += core[000150];  }
void I00441() { core[000065] = lac & 07777; lac &= 010000; code[000065] = &emul8;  }
void I00442() { lac += core[000145];  }
void I00443() { lac &= (010000|core[000147]);  }
void I00444() { lac += core[000150];  }
void I00445() { core[000066] = lac & 07777; lac &= 010000; code[000066] = &emul8;  }
void I00446() { lac += core[000146];  }
void I00447() { lac &= (010000|core[000147]);  }
void I00450() { lac += core[000150];  }
void I00451() { core[000067] = lac & 07777; lac &= 010000; code[000067] = &emul8;  }
void I00452() { lac += core[000456];  }
void I00453() { core[(df<<12)+core[106]] = lac & 07777; lac &= 010000; code[(df<<12)+core[106]] = &emul8;  }
void I00454() { lac += core[(df<<12)+core[89]];  }
void I00455() { npc = (ib<<12)+core[107]; inh = 0;  }
void D00456() { lac &= (010000|core[(df<<12)+core[47]]);  }
void I00457() { lac += core[000143];  }
void I00460() { lac &= (010000|core[000147]);  }
void I00461() { lac += core[000150];  }
void I00462() { core[000102] = lac & 07777; lac &= 010000; code[000102] = &emul8;  }
void I00463() { lac += core[000144];  }
void I00464() { lac &= (010000|core[000147]);  }
void I00465() { lac += core[000150];  }
void I00466() { core[000103] = lac & 07777; lac &= 010000; code[000103] = &emul8;  }
void I00467() { lac += core[000145];  }
void I00470() { lac &= (010000|core[000147]);  }
void I00471() { lac += core[000150];  }
void I00472() { core[000104] = lac & 07777; lac &= 010000; code[000104] = &emul8;  }
void I00473() { lac += core[000146];  }
void I00474() { lac &= (010000|core[000147]);  }
void I00475() { lac += core[000150];  }
void I00476() { core[000105] = lac & 07777; lac &= 010000; code[000105] = &emul8;  }
void I00477() { lac ^= 07777;  }
void I00500() { lac += core[000000];  }
void I00501() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I00502() { lac += core[000506];  }
void I00503() { core[(df<<12)+core[106]] = lac & 07777; lac &= 010000; code[(df<<12)+core[106]] = &emul8;  }
void I00504() { lac += core[000000];  }
void I00505() { npc = (ib<<12)+core[107]; inh = 0;  }
void D00506() { lac &= (010000|core[(df<<12)+core[71]]);  }
void I00507() { lac += core[000143];  }
void I00510() { lac &= (010000|core[000147]);  }
void I00511() { lac += core[000150];  }
void I00512() { core[000112] = lac & 07777; lac &= 010000; code[000112] = &emul8;  }
void I00513() { lac += core[000144];  }
void I00514() { lac &= (010000|core[000147]);  }
void I00515() { lac += core[000150];  }
void I00516() { core[000113] = lac & 07777; lac &= 010000; code[000113] = &emul8;  }
void I00517() { lac += core[000145];  }
void I00520() { lac &= (010000|core[000147]);  }
void I00521() { lac += core[000150];  }
void I00522() { core[000114] = lac & 07777; lac &= 010000; code[000114] = &emul8;  }
void I00523() { lac += core[000146];  }
void I00524() { lac &= (010000|core[000147]);  }
void I00525() { lac += core[000150];  }
void I00526() { core[000115] = lac & 07777; lac &= 010000; code[000115] = &emul8;  }
void I00527() { lac += core[000533];  }
void I00530() { core[(df<<12)+core[106]] = lac & 07777; lac &= 010000; code[(df<<12)+core[106]] = &emul8;  }
void I00531() { lac += core[(df<<12)+core[0]];  }
void I00532() { npc = (ib<<12)+core[107]; inh = 0;  }
void D00533() { lac &= (010000|core[(df<<12)+core[92]]);  }
void I00534() { lac += core[000143];  }
void I00535() { lac &= (010000|core[000147]);  }
void I00536() { lac += core[000150];  }
void I00537() { core[000122] = lac & 07777; lac &= 010000; code[000122] = &emul8;  }
void I00540() { lac += core[000144];  }
void I00541() { lac &= (010000|core[000147]);  }
void I00542() { lac += core[000150];  }
void I00543() { core[000123] = lac & 07777; lac &= 010000; code[000123] = &emul8;  }
void I00544() { lac += core[000145];  }
void I00545() { lac &= (010000|core[000147]);  }
void I00546() { lac += core[000150];  }
void I00547() { core[000124] = lac & 07777; lac &= 010000; code[000124] = &emul8;  }
void I00550() { lac += core[000146];  }
void I00551() { lac &= (010000|core[000147]);  }
void I00552() { lac += core[000150];  }
void I00553() { core[000125] = lac & 07777; lac &= 010000; code[000125] = &emul8;  }
void I00554() { lac += core[000154];  }
void I00555() { core[000127] = lac & 07777; lac &= 010000; code[000127] = &emul8;  }
void L00556() { lac += core[(df<<12)+core[87]];  }
void I00557() { emul8();  }
void L00560() { emul8();  }
void I00561() { npc = 000560; inh = 0;  }
void I00562() { lac &= 010000; lac++;  }
void I00563() { lac += core[000127];  }
void I00564() { core[000127] = lac & 07777; lac &= 010000; code[000127] = &emul8;  }
void I00565() { lac += core[(df<<12)+core[87]];  }
void I00566() { lac += core[000130];  }
void I00567() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00570() { npc = 000556; inh = 0;  }
void I00571() { lac &= 010000; lac |= swr;  }
void I00572() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I00573() { hlt = 1;  }
void I00574() { npc = 000017; inh = 0;  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &L00001;
  core[000002] = 00002; code[000002] = &D00002;
  core[000003] = 00003; code[000003] = &D00003;
  core[000004] = 00000; code[000004] = &I00004;
  core[000005] = 00000; code[000005] = &P00005;
  core[000006] = 07041; code[000006] = &L00006;
  core[000007] = 01135; code[000007] = &D00007;
  core[000010] = 07640; code[000010] = &I00010;
  core[000011] = 05551; code[000011] = &I00011;
  core[000012] = 01132; code[000012] = &D00012;
  core[000013] = 07041; code[000013] = &I00013;
  core[000014] = 01000; code[000014] = &I00014;
  core[000015] = 07640; code[000015] = &D00015;
  core[000016] = 05551; code[000016] = &I00016;
  core[000017] = 01155; code[000017] = &L00017;
  core[000020] = 03533; code[000020] = &D00020;
  core[000021] = 01155; code[000021] = &I00021;
  core[000022] = 03531; code[000022] = &I00022;
  core[000023] = 07040; code[000023] = &I00023;
  core[000024] = 01000; code[000024] = &I00024;
  core[000025] = 03000; code[000025] = &I00025;
  core[000026] = 01155; code[000026] = &I00026;
  core[000027] = 03400; code[000027] = &I00027;
  core[000030] = 01155; code[000030] = &I00030;
  core[000031] = 03534; code[000031] = &I00031;
  core[000032] = 07001; code[000032] = &P00032;
  core[000033] = 01043; code[000033] = &I00033;
  core[000034] = 03043; code[000034] = &I00034;
  core[000035] = 01043; code[000035] = &I00035;
  core[000036] = 07640; code[000036] = &I00036;
  core[000037] = 05442; code[000037] = &I00037;
  core[000040] = 05441; code[000040] = &D00040;
  core[000041] = 00346; code[000041] = &P00041;
  core[000042] = 00220; code[000042] = &P00042;
  core[000043] = 00000; code[000043] = &D00043;
  core[000044] = 00000; code[000044] = &D00044;
  core[000045] = 07763; code[000045] = &D00045;
  core[000046] = 07475; code[000046] = &D00046;
  core[000047] = 00215; code[000047] = &D00047;
  core[000050] = 00212; code[000050] = &D00050;
  core[000051] = 00212; code[000051] = &D00051;
  core[000052] = 00306; code[000052] = &I00052;
  core[000053] = 00240; code[000053] = &I00053;
  core[000054] = 00000; code[000054] = &D00054;
  core[000055] = 00000; code[000055] = &D00055;
  core[000056] = 00000; code[000056] = &D00056;
  core[000057] = 00000; code[000057] = &P00057;
  core[000060] = 00240; code[000060] = &D00060;
  core[000061] = 00324; code[000061] = &I00061;
  core[000062] = 00317; code[000062] = &I00062;
  core[000063] = 00240; code[000063] = &I00063;
  core[000064] = 00000; code[000064] = &D00064;
  core[000065] = 00000; code[000065] = &D00065;
  core[000066] = 00000; code[000066] = &D00066;
  core[000067] = 00000; code[000067] = &D00067;
  core[000070] = 00215; code[000070] = &I00070;
  core[000071] = 00212; code[000071] = &I00071;
  core[000072] = 00377; code[000072] = &I00072;
  core[000073] = 00250; code[000073] = &I00073;
  core[000074] = 00324; code[000074] = &I00074;
  core[000075] = 00317; code[000075] = &D00075;
  core[000076] = 00251; code[000076] = &I00076;
  core[000077] = 00240; code[000077] = &I00077;
  core[000100] = 00275; code[000100] = &I00100;
  core[000101] = 00240; code[000101] = &I00101;
  core[000102] = 00000; code[000102] = &D00102;
  core[000103] = 00000; code[000103] = &D00103;
  core[000104] = 00000; code[000104] = &D00104;
  core[000105] = 00000; code[000105] = &D00105;
  core[000106] = 00215; code[000106] = &D00106;
  core[000107] = 00212; code[000107] = &P00107;
  core[000110] = 00377; code[000110] = &I00110;
  core[000111] = 00250; code[000111] = &I00111;
  core[000112] = 00000; code[000112] = &D00112;
  core[000113] = 00000; code[000113] = &D00113;
  core[000114] = 00000; code[000114] = &D00114;
  core[000115] = 00000; code[000115] = &D00115;
  core[000116] = 00251; code[000116] = &I00116;
  core[000117] = 00240; code[000117] = &D00117;
  core[000120] = 00275; code[000120] = &I00120;
  core[000121] = 00240; code[000121] = &I00121;
  core[000122] = 00000; code[000122] = &D00122;
  core[000123] = 00000; code[000123] = &D00123;
  core[000124] = 00000; code[000124] = &D00124;
  core[000125] = 00000; code[000125] = &P00125;
  core[000126] = 00207; code[000126] = &I00126;
  core[000127] = 00000; code[000127] = &P00127;
  core[000130] = 07571; code[000130] = &D00130;
  core[000131] = 00000; code[000131] = &P00131;
  core[000132] = 00000; code[000132] = &D00132;
  core[000133] = 00000; code[000133] = &P00133;
  core[000134] = 00000; code[000134] = &P00134;
  core[000135] = 00000; code[000135] = &D00135;
  core[000136] = 02525; code[000136] = &D00136;
  core[000137] = 00003; code[000137] = &D00137;
  core[000140] = 07200; code[000140] = &D00140;
  core[000141] = 00200; code[000141] = &D00141;
  core[000142] = 06001; code[000142] = &D00142;
  core[000143] = 00000; code[000143] = &D00143;
  core[000144] = 00000; code[000144] = &D00144;
  core[000145] = 00000; code[000145] = &D00145;
  core[000146] = 00000; code[000146] = &D00146;
  core[000147] = 00007; code[000147] = &D00147;
  core[000150] = 00260; code[000150] = &D00150;
  core[000151] = 00400; code[000151] = &P00151;
  core[000152] = 00327; code[000152] = &P00152;
  core[000153] = 00330; code[000153] = &P00153;
  core[000154] = 00047; code[000154] = &D00154;
  core[000155] = 07402; code[000155] = &D00155;
  core[000156] = 04531; code[000156] = &D00156;
  core[000157] = 00000; code[000157] = &S00157;
  core[000160] = 03000; code[000160] = &I00160;
  core[000161] = 01172; code[000161] = &I00161;
  core[000162] = 03001; code[000162] = &I00162;
  core[000163] = 01173; code[000163] = &I00163;
  core[000164] = 03002; code[000164] = &I00164;
  core[000165] = 01174; code[000165] = &I00165;
  core[000166] = 03003; code[000166] = &I00166;
  core[000167] = 01175; code[000167] = &I00167;
  core[000170] = 03576; code[000170] = &I00170;
  core[000171] = 05557; code[000171] = &I00171;
  core[000172] = 07200; code[000172] = &D00172;
  core[000173] = 01531; code[000173] = &D00173;
  core[000174] = 05006; code[000174] = &D00174;
  core[000175] = 07200; code[000175] = &D00175;
  core[000176] = 00200; code[000176] = &P00176;
  core[000200] = 04157; code[000200] = &D00200;
  core[000201] = 01140; code[000201] = &I00201;
  core[000202] = 07041; code[000202] = &I00202;
  core[000203] = 03131; code[000203] = &I00203;
  core[000204] = 01155; code[000204] = &L00204;
  core[000205] = 03531; code[000205] = &I00205;
  core[000206] = 01131; code[000206] = &I00206;
  core[000207] = 07001; code[000207] = &I00207;
  core[000210] = 03131; code[000210] = &I00210;
  core[000211] = 01131; code[000211] = &I00211;
  core[000212] = 01141; code[000212] = &D00212;
  core[000213] = 07640; code[000213] = &I00213;
  core[000214] = 05204; code[000214] = &I00214;
  core[000215] = 01045; code[000215] = &D00215;
  core[000216] = 03044; code[000216] = &I00216;
  core[000217] = 03043; code[000217] = &I00217;
  core[000220] = 07604; code[000220] = &L00220;
  core[000221] = 07004; code[000221] = &I00221;
  core[000222] = 07006; code[000222] = &I00222;
  core[000223] = 07630; code[000223] = &I00223;
  core[000224] = 05246; code[000224] = &I00224;
  core[000225] = 01136; code[000225] = &L00225;
  core[000226] = 07104; code[000226] = &I00226;
  core[000227] = 07430; code[000227] = &I00227;
  core[000230] = 01137; code[000230] = &I00230;
  core[000231] = 03136; code[000231] = &I00231;
  core[000232] = 01136; code[000232] = &I00232;
  core[000233] = 07510; code[000233] = &I00233;
  core[000234] = 05241; code[000234] = &I00234;
  core[000235] = 01140; code[000235] = &I00235;
  core[000236] = 07710; code[000236] = &I00236;
  core[000237] = 05225; code[000237] = &I00237;
  core[000240] = 05244; code[000240] = &I00240;
  core[000241] = 01141; code[000241] = &L00241;
  core[000242] = 07700; code[000242] = &I00242;
  core[000243] = 05225; code[000243] = &I00243;
  core[000244] = 01136; code[000244] = &L00244;
  core[000245] = 03133; code[000245] = &I00245;
  core[000246] = 01133; code[000246] = &L00246;
  core[000247] = 07001; code[000247] = &I00247;
  core[000250] = 03135; code[000250] = &I00250;
  core[000251] = 07040; code[000251] = &I00251;
  core[000252] = 01133; code[000252] = &I00252;
  core[000253] = 03134; code[000253] = &I00253;
  core[000254] = 07604; code[000254] = &I00254;
  core[000255] = 07006; code[000255] = &I00255;
  core[000256] = 07006; code[000256] = &I00256;
  core[000257] = 07630; code[000257] = &I00257;
  core[000260] = 05302; code[000260] = &I00260;
  core[000261] = 01136; code[000261] = &L00261;
  core[000262] = 07104; code[000262] = &I00262;
  core[000263] = 07430; code[000263] = &I00263;
  core[000264] = 01137; code[000264] = &I00264;
  core[000265] = 03136; code[000265] = &I00265;
  core[000266] = 01136; code[000266] = &I00266;
  core[000267] = 07510; code[000267] = &I00267;
  core[000270] = 05275; code[000270] = &I00270;
  core[000271] = 01140; code[000271] = &I00271;
  core[000272] = 07710; code[000272] = &I00272;
  core[000273] = 05261; code[000273] = &I00273;
  core[000274] = 05300; code[000274] = &I00274;
  core[000275] = 01141; code[000275] = &L00275;
  core[000276] = 07700; code[000276] = &I00276;
  core[000277] = 05261; code[000277] = &I00277;
  core[000300] = 01136; code[000300] = &L00300;
  core[000301] = 03131; code[000301] = &I00301;
  core[000302] = 01131; code[000302] = &L00302;
  core[000303] = 07001; code[000303] = &D00303;
  core[000304] = 03132; code[000304] = &I00304;
  core[000305] = 01133; code[000305] = &I00305;
  core[000306] = 07041; code[000306] = &I00306;
  core[000307] = 01131; code[000307] = &I00307;
  core[000310] = 07650; code[000310] = &I00310;
  core[000311] = 05220; code[000311] = &I00311;
  core[000312] = 07040; code[000312] = &D00312;
  core[000313] = 06041; code[000313] = &I00313;
  core[000314] = 06046; code[000314] = &I00314;
  core[000315] = 06041; code[000315] = &L00315;
  core[000316] = 05315; code[000316] = &I00316;
  core[000317] = 07200; code[000317] = &I00317;
  core[000320] = 01142; code[000320] = &I00320;
  core[000321] = 03534; code[000321] = &I00321;
  core[000322] = 01156; code[000322] = &I00322;
  core[000323] = 03533; code[000323] = &I00323;
  core[000324] = 03000; code[000324] = &I00324;
  core[000325] = 05534; code[000325] = &I00325;
  core[000326] = 07402; code[000326] = &I00326;
  core[000327] = 00000; code[000327] = &P00327;
  core[000330] = 03146; code[000330] = &L00330;
  core[000331] = 01146; code[000331] = &I00331;
  core[000332] = 07012; code[000332] = &I00332;
  core[000333] = 07010; code[000333] = &I00333;
  core[000334] = 03145; code[000334] = &I00334;
  core[000335] = 01145; code[000335] = &I00335;
  core[000336] = 07012; code[000336] = &I00336;
  core[000337] = 07010; code[000337] = &I00337;
  core[000340] = 03144; code[000340] = &I00340;
  core[000341] = 01144; code[000341] = &I00341;
  core[000342] = 07012; code[000342] = &I00342;
  core[000343] = 07010; code[000343] = &I00343;
  core[000344] = 03143; code[000344] = &I00344;
  core[000345] = 05727; code[000345] = &I00345;
  core[000346] = 01044; code[000346] = &L00346;
  core[000347] = 07001; code[000347] = &I00347;
  core[000350] = 03044; code[000350] = &I00350;
  core[000351] = 01044; code[000351] = &I00351;
  core[000352] = 07640; code[000352] = &I00352;
  core[000353] = 05442; code[000353] = &I00353;
  core[000354] = 01373; code[000354] = &I00354;
  core[000355] = 03127; code[000355] = &I00355;
  core[000356] = 01127; code[000356] = &L00356;
  core[000357] = 07001; code[000357] = &I00357;
  core[000360] = 03127; code[000360] = &I00360;
  core[000361] = 01527; code[000361] = &I00361;
  core[000362] = 06046; code[000362] = &I00362;
  core[000363] = 06041; code[000363] = &L00363;
  core[000364] = 05363; code[000364] = &I00364;
  core[000365] = 01046; code[000365] = &I00365;
  core[000366] = 07640; code[000366] = &I00366;
  core[000367] = 05356; code[000367] = &I00367;
  core[000370] = 01045; code[000370] = &I00370;
  core[000371] = 03044; code[000371] = &I00371;
  core[000372] = 05442; code[000372] = &I00372;
  core[000373] = 00373; code[000373] = &D00373;
  core[000374] = 00215; code[000374] = &I00374;
  core[000375] = 00212; code[000375] = &I00375;
  core[000376] = 00312; code[000376] = &I00376;
  core[000377] = 00303; code[000377] = &I00377;
  core[000400] = 01204; code[000400] = &L00400;
  core[000401] = 03552; code[000401] = &I00401;
  core[000402] = 01133; code[000402] = &I00402;
  core[000403] = 05553; code[000403] = &I00403;
  core[000404] = 00405; code[000404] = &D00404;
  core[000405] = 01143; code[000405] = &I00405;
  core[000406] = 00147; code[000406] = &I00406;
  core[000407] = 01150; code[000407] = &I00407;
  core[000410] = 03054; code[000410] = &I00410;
  core[000411] = 01144; code[000411] = &I00411;
  core[000412] = 00147; code[000412] = &I00412;
  core[000413] = 01150; code[000413] = &I00413;
  core[000414] = 03055; code[000414] = &I00414;
  core[000415] = 01145; code[000415] = &I00415;
  core[000416] = 00147; code[000416] = &I00416;
  core[000417] = 01150; code[000417] = &I00417;
  core[000420] = 03056; code[000420] = &I00420;
  core[000421] = 01146; code[000421] = &I00421;
  core[000422] = 00147; code[000422] = &I00422;
  core[000423] = 01150; code[000423] = &I00423;
  core[000424] = 03057; code[000424] = &I00424;
  core[000425] = 01231; code[000425] = &I00425;
  core[000426] = 03552; code[000426] = &I00426;
  core[000427] = 01131; code[000427] = &I00427;
  core[000430] = 05553; code[000430] = &I00430;
  core[000431] = 00432; code[000431] = &D00431;
  core[000432] = 01143; code[000432] = &I00432;
  core[000433] = 00147; code[000433] = &I00433;
  core[000434] = 01150; code[000434] = &I00434;
  core[000435] = 03064; code[000435] = &I00435;
  core[000436] = 01144; code[000436] = &I00436;
  core[000437] = 00147; code[000437] = &I00437;
  core[000440] = 01150; code[000440] = &I00440;
  core[000441] = 03065; code[000441] = &I00441;
  core[000442] = 01145; code[000442] = &I00442;
  core[000443] = 00147; code[000443] = &I00443;
  core[000444] = 01150; code[000444] = &I00444;
  core[000445] = 03066; code[000445] = &I00445;
  core[000446] = 01146; code[000446] = &I00446;
  core[000447] = 00147; code[000447] = &I00447;
  core[000450] = 01150; code[000450] = &I00450;
  core[000451] = 03067; code[000451] = &I00451;
  core[000452] = 01256; code[000452] = &I00452;
  core[000453] = 03552; code[000453] = &I00453;
  core[000454] = 01531; code[000454] = &I00454;
  core[000455] = 05553; code[000455] = &I00455;
  core[000456] = 00457; code[000456] = &D00456;
  core[000457] = 01143; code[000457] = &I00457;
  core[000460] = 00147; code[000460] = &I00460;
  core[000461] = 01150; code[000461] = &I00461;
  core[000462] = 03102; code[000462] = &I00462;
  core[000463] = 01144; code[000463] = &I00463;
  core[000464] = 00147; code[000464] = &I00464;
  core[000465] = 01150; code[000465] = &I00465;
  core[000466] = 03103; code[000466] = &I00466;
  core[000467] = 01145; code[000467] = &I00467;
  core[000470] = 00147; code[000470] = &I00470;
  core[000471] = 01150; code[000471] = &I00471;
  core[000472] = 03104; code[000472] = &I00472;
  core[000473] = 01146; code[000473] = &I00473;
  core[000474] = 00147; code[000474] = &I00474;
  core[000475] = 01150; code[000475] = &I00475;
  core[000476] = 03105; code[000476] = &I00476;
  core[000477] = 07040; code[000477] = &I00477;
  core[000500] = 01000; code[000500] = &I00500;
  core[000501] = 03000; code[000501] = &I00501;
  core[000502] = 01306; code[000502] = &I00502;
  core[000503] = 03552; code[000503] = &I00503;
  core[000504] = 01000; code[000504] = &I00504;
  core[000505] = 05553; code[000505] = &I00505;
  core[000506] = 00507; code[000506] = &D00506;
  core[000507] = 01143; code[000507] = &I00507;
  core[000510] = 00147; code[000510] = &I00510;
  core[000511] = 01150; code[000511] = &I00511;
  core[000512] = 03112; code[000512] = &I00512;
  core[000513] = 01144; code[000513] = &I00513;
  core[000514] = 00147; code[000514] = &I00514;
  core[000515] = 01150; code[000515] = &I00515;
  core[000516] = 03113; code[000516] = &I00516;
  core[000517] = 01145; code[000517] = &I00517;
  core[000520] = 00147; code[000520] = &I00520;
  core[000521] = 01150; code[000521] = &I00521;
  core[000522] = 03114; code[000522] = &I00522;
  core[000523] = 01146; code[000523] = &I00523;
  core[000524] = 00147; code[000524] = &I00524;
  core[000525] = 01150; code[000525] = &I00525;
  core[000526] = 03115; code[000526] = &I00526;
  core[000527] = 01333; code[000527] = &I00527;
  core[000530] = 03552; code[000530] = &I00530;
  core[000531] = 01400; code[000531] = &I00531;
  core[000532] = 05553; code[000532] = &I00532;
  core[000533] = 00534; code[000533] = &D00533;
  core[000534] = 01143; code[000534] = &I00534;
  core[000535] = 00147; code[000535] = &I00535;
  core[000536] = 01150; code[000536] = &I00536;
  core[000537] = 03122; code[000537] = &I00537;
  core[000540] = 01144; code[000540] = &I00540;
  core[000541] = 00147; code[000541] = &I00541;
  core[000542] = 01150; code[000542] = &I00542;
  core[000543] = 03123; code[000543] = &I00543;
  core[000544] = 01145; code[000544] = &I00544;
  core[000545] = 00147; code[000545] = &I00545;
  core[000546] = 01150; code[000546] = &I00546;
  core[000547] = 03124; code[000547] = &I00547;
  core[000550] = 01146; code[000550] = &I00550;
  core[000551] = 00147; code[000551] = &I00551;
  core[000552] = 01150; code[000552] = &I00552;
  core[000553] = 03125; code[000553] = &I00553;
  core[000554] = 01154; code[000554] = &I00554;
  core[000555] = 03127; code[000555] = &I00555;
  core[000556] = 01527; code[000556] = &L00556;
  core[000557] = 06046; code[000557] = &I00557;
  core[000560] = 06041; code[000560] = &L00560;
  core[000561] = 05360; code[000561] = &I00561;
  core[000562] = 07201; code[000562] = &I00562;
  core[000563] = 01127; code[000563] = &I00563;
  core[000564] = 03127; code[000564] = &I00564;
  core[000565] = 01527; code[000565] = &I00565;
  core[000566] = 01130; code[000566] = &I00566;
  core[000567] = 07640; code[000567] = &I00567;
  core[000570] = 05356; code[000570] = &I00570;
  core[000571] = 07604; code[000571] = &I00571;
  core[000572] = 07700; code[000572] = &I00572;
  core[000573] = 07402; code[000573] = &I00573;
  core[000574] = 05017; code[000574] = &I00574;
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

