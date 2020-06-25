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
void P00017() { core[000177] = 00020; npc = 000177+1; code[000177] = &emul8; inh = 0;  }
void S00020() { lac &= (010000|core[000000]);  }
void I00021() { emul8();  }
void L00022() { emul8();  }
void I00023() { npc = 000022; inh = 0;  }
void I00024() { lac &= 010000;  }
void I00025() { npc = (ib<<12)+core[16]; inh = 0;  }
void S00026() { lac &= (010000|core[000000]);  }
void I00027() { lac &= 010000; lac ^= 07777;  }
void I00030() { lac &= (010000|core[000104]);  }
void I00031() { core[000020] = 00032; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00032() { lac &= 010000; lac ^= 07777;  }
void I00033() { lac &= (010000|core[000103]);  }
void I00034() { core[000020] = 00035; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00035() { lac &= 010000; lac ^= 07777;  }
void I00036() { lac &= (010000|core[000103]);  }
void I00037() { core[000020] = 00040; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void D00040() { npc = (ib<<12)+core[22]; inh = 0;  }
void S00041() { lac &= (010000|core[000000]);  }
void I00042() { lac &= 010000; lac ^= 07777;  }
void I00043() { lac &= (010000|core[000104]);  }
void I00044() { core[000020] = 00045; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00045() { lac &= 010000; lac ^= 07777;  }
void I00046() { lac &= (010000|core[000103]);  }
void I00047() { core[000020] = 00050; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00050() { npc = (ib<<12)+core[33]; inh = 0;  }
void D00051() { lac &= (010000|core[000000]);  }
void D00052() { lac &= (010000|core[000000]);  }
void D00053() { lac &= (010000|core[000000]);  }
void D00054() { lac &= (010000|core[000000]);  }
void D00055() { lac &= (010000|core[000000]);  }
void D00056() { lac &= (010000|core[000000]);  }
void D00057() { lac &= (010000|core[000000]);  }
void D00060() { core[000000] = 00061; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void D00061() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void D00062() { lac += core[000000];  }
void D00063() { lac &= (010000|core[(df<<12)+core[0]]);  }
void P00064() { lac &= (010000|core[000000]);  }
void P00065() { lac &= (010000|core[000100]);  }
void I00066() { lac &= (010000|core[000040]);  }
void I00067() { lac &= (010000|core[000020]);  }
void I00070() { lac &= (010000|core[000010]);  }
void I00071() { lac &= (010000|core[000004]);  }
void D00072() { lac &= (010000|core[000002]);  }
void I00073() { lac &= (010000|core[000001]);  }
void D00074() { lac &= (010000|core[000057]);  }
void D00075() { lac &= (010000|core[000122]);  }
void D00076() { lac &= (010000|core[000101]);  }
void D00077() { lac &= (010000|core[000114]);  }
void D00100() { lac &= (010000|core[000124]);  }
void D00101() { lac &= (010000|core[000120]);  }
void D00102() { lac &= (010000|core[000040]);  }
void D00103() { lac &= (010000|core[000012]);  }
void D00104() { lac &= (010000|core[000015]);  }
void D00105() { lac &= (010000|core[000060]);  }
void D00106() { lac &= (010000|core[000061]);  }
void P00107() { lac &= (010000|core[000117]);  }
void D00110() { lac &= (010000|core[000113]);  }
void D00111() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void D00112() { lac &= (010000|core[000000]);  }
void D00113() { lac &= (010000|core[000062]);  }
void D00114() { lac &= (010000|core[000102]);  }
void D00115() { lac &= (010000|core[000000]);  }
void D00116() { lac &= (010000|core[000000]);  }
void D00117() { lac &= (010000|core[000000]);  }
void D00120() { lac &= (010000|core[000000]);  }
void P00121() { lac &= (010000|core[000000]);  }
void D00122() { lac &= (010000|core[000000]);  }
void D00123() { lac &= (010000|core[000000]);  }
void D00124() { lac &= (010000|core[000000]);  }
void P00125() { lac &= (010000|core[000000]);  }
void D00126() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void D00127() { lac &= (010000|core[000000]);  }
void D00130() { lac &= (010000|core[000107]);  }
void D00131() { lac &= (010000|core[000104]);  }
void D00132() { lac &= (010000|core[000130]);  }
void D00133() { lac &= (010000|core[000131]);  }
void D00134() { lac &= (010000|core[000000]);  }
void D00135() { lac &= (010000|core[000000]);  }
void D00136() { lac &= (010000|core[000000]);  }
void D00137() { emul8();  }
void D00140() { lac &= (010000|core[000000]);  }
void I00141() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void S00142() { lac &= (010000|core[000000]);  }
void I00143() { lac &= 010000; lac ^= 07777;  }
void I00144() { lac &= (010000|core[000140]);  }
void I00145() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00146() { npc = 000150; inh = 0;  }
void I00147() { npc = 000152; inh = 0;  }
void L00150() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I00151() { npc = (ib<<12)+core[98]; inh = 0;  }
void L00152() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00153() { npc = (ib<<12)+core[98]; inh = 0;  }
void L00200() { lac &= 010000; lac ^= 07777;  }
void I00201() { core[000124] = lac & 07777; lac &= 010000; code[000124] = &emul8;  }
void I00202() { lac &= 010000; lac ^= 07777;  }
void I00203() { core[000135] = lac & 07777; lac &= 010000; code[000135] = &emul8;  }
void I00204() { lac &= 010000; lac ^= 07777;  }
void I00205() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I00206() { lac &= 010000; lac ^= 07777;  }
void I00207() { core[000121] = lac & 07777; lac &= 010000; code[000121] = &emul8;  }
void I00210() { core[000134] = lac & 07777; lac &= 010000; code[000134] = &emul8;  }
void I00211() { core[000115] = lac & 07777; lac &= 010000; code[000115] = &emul8;  }
void I00212() { npc = 000223; inh = 0;  }
void I00213() { core[000120] = lac & 07777; lac &= 010000; code[000120] = &emul8;  }
void L00214() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I00215() { lac &= (010000|core[000135]);  }
void I00216() { lac += core[000136];  }
void I00217() { core[000122] = lac & 07777; lac &= 010000; code[000122] = &emul8;  }
void I00220() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00221() { core[000134] = lac & 07777; lac &= 010000; code[000134] = &emul8;  }
void I00222() { npc = (ib<<12)+core[223]; inh = 0;  }
void L00223() { npc = (ib<<12)+core[148]; inh = 0;  }
void P00224() { core[000020] = 00225; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void L00225() { lac &= 010000; lac ^= 07777;  }
void I00226() { lac &= (010000|core[000135]);  }
void I00227() { core[000115] = lac & 07777; lac &= 010000; code[000115] = &emul8;  }
void I00230() { lac &= 010000; lac ^= 07777;  }
void I00231() { lac &= (010000|core[000136]);  }
void I00232() { core[000116] = lac & 07777; lac &= 010000; code[000116] = &emul8;  }
void I00233() { core[000235] = 00234; npc = 000235+1; code[000235] = &emul8; inh = 0;  }
void I00234() { npc = 000214; inh = 0;  }
void S00235() { lac &= (010000|core[000000]);  }
void I00236() { lac &= 010000; lac &= 07777;  }
void I00237() { core[000121] = lac & 07777; lac &= 010000; code[000121] = &emul8;  }
void I00240() { core[000120] = lac & 07777; lac &= 010000; code[000120] = &emul8;  }
void I00241() { lac ^= 07777;  }
void I00242() { lac &= (010000|core[000111]);  }
void I00243() { core[000123] = lac & 07777; lac &= 010000; code[000123] = &emul8;  }
void L00244() { lac ^= 07777;  }
void I00245() { lac &= (010000|core[000115]);  }
void I00246() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00247() { core[000115] = lac & 07777; lac &= 010000; code[000115] = &emul8;  }
void I00250() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00251() { core[000117] = lac & 07777; lac &= 010000; code[000117] = &emul8;  }
void I00252() { lac ^= 07777;  }
void I00253() { lac &= (010000|core[000116]);  }
void I00254() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00255() { core[000116] = lac & 07777; lac &= 010000; code[000116] = &emul8;  }
void I00256() { lac ^= 07777;  }
void I00257() { lac &= (010000|core[000117]);  }
void I00260() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00261() { npc = 000302; inh = 0;  }
void I00262() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00263() { npc = 000305; inh = 0;  }
void I00264() { lac &= 010000; lac &= 07777;  }
void L00265() { lac ^= 07777;  }
void I00266() { lac &= (010000|core[000120]);  }
void I00267() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00270() { lac ^= 07777;  }
void I00271() { lac &= (010000|core[000117]);  }
void L00272() { core[000120] = lac & 07777; lac &= 010000; code[000120] = &emul8;  }
void I00273() { lac ^= 07777;  }
void I00274() { lac &= (010000|core[000121]);  }
void I00275() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I00276() { core[000121] = lac & 07777; lac &= 010000; code[000121] = &emul8;  }
void I00277() { if (++core[000123] == 010000) { core[000123] = 0; npc++; }; code[000123] = &emul8;  }
void I00300() { npc = 000244; inh = 0;  }
void I00301() { npc = (ib<<12)+core[157]; inh = 0;  }
void L00302() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00303() { npc = 000265; inh = 0;  }
void I00304() { lac &= 010000; lac ^= 010000;  }
void L00305() { lac ^= 07777;  }
void I00306() { lac &= (010000|core[000120]);  }
void I00307() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00310() { lac &= 07777;  }
void I00311() { npc = 000272; inh = 0;  }
void L00312() { core[000041] = 00313; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void I00313() { lac &= 010000; lac ^= 07777;  }
void I00314() { lac &= (010000|core[000076]);  }
void I00315() { core[000020] = 00316; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00316() { lac &= 010000; lac ^= 07777;  }
void D00317() { lac &= (010000|core[000131]);  }
void I00320() { core[000020] = 00321; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00321() { lac &= 010000; lac ^= 07777;  }
void I00322() { lac &= (010000|core[000131]);  }
void I00323() { core[000020] = 00324; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00324() { lac &= 010000; lac ^= 07777;  }
void I00325() { lac &= (010000|core[000102]);  }
void I00326() { core[000020] = 00327; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00327() { lac &= 010000; lac ^= 07777;  }
void I00330() { lac &= (010000|core[000107]);  }
void I00331() { core[000020] = 00332; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00332() { lac &= 010000; lac ^= 07777;  }
void I00333() { lac &= (010000|core[000110]);  }
void I00334() { core[000020] = 00335; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00335() { npc = (ib<<12)+core[222]; inh = 0;  }
void P00336() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void P00337() { core[000051] = 00340; npc = 000051+1; code[000051] = &emul8; inh = 0;  }
void P00400() { lac &= 010000; lac |= swr;  }
void I00401() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I00402() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00403() { core[000416] = 00404; npc = 000416+1; code[000416] = &emul8; inh = 0;  }
void I00404() { lac &= 010000; lac |= swr;  }
void I00405() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00406() { hlt = 1;  }
void L00407() { lac &= 010000; lac |= swr;  }
void I00410() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I00411() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00412() { npc = (ib<<12)+core[268]; inh = 0;  }
void I00413() { npc = (ib<<12)+core[269]; inh = 0;  }
void P00414() { lac &= (010000|core[000425]);  }
void P00415() { lac &= (010000|core[000423]);  }
void S00416() { lac &= (010000|core[000000]);  }
void I00417() { lac &= 010000; lac ^= 07777;  }
void I00420() { lac &= (010000|core[000124]);  }
void I00421() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00422() { core[000521] = 00423; npc = 000521+1; code[000521] = &emul8; inh = 0;  }
void D00423() {  }
void I00424() { core[000041] = 00425; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void D00425() { core[000020] = 00426; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void P00426() { lac &= 010000; lac ^= 07777;  }
void I00427() { lac &= (010000|core[000120]);  }
void I00430() { core[(ib<<12)+core[285]] = 00431; npc = (ib<<12)+core[285]+1; code[(ib<<12)+core[285]] = &emul8; inh = 0;  }
void I00431() { lac &= 010000; lac ^= 07777;  }
void I00432() { lac &= (010000|core[000102]);  }
void I00433() { core[000020] = 00434; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00434() { npc = 000436; inh = 0;  }
void P00435() { if (++core[(df<<12)+core[287]] == 010000) { core[(df<<12)+core[287]] = 0; npc++; }; code[(df<<12)+core[287]] = &emul8;  }
void L00436() { lac &= 010000; lac ^= 07777;  }
void P00437() { lac &= (010000|core[000121]);  }
void I00440() { core[000125] = lac & 07777; lac &= 010000; code[000125] = &emul8;  }
void I00441() { core[000466] = 00442; npc = 000466+1; code[000466] = &emul8; inh = 0;  }
void I00442() { lac &= 010000; lac ^= 07777;  }
void I00443() { lac &= (010000|core[000134]);  }
void I00444() { core[(ib<<12)+core[285]] = 00445; npc = (ib<<12)+core[285]+1; code[(ib<<12)+core[285]] = &emul8; inh = 0;  }
void I00445() { lac &= 010000; lac ^= 07777;  }
void I00446() { lac &= (010000|core[000102]);  }
void I00447() { core[000020] = 00450; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00450() { npc = 000451; inh = 0;  }
void L00451() { lac &= 010000; lac ^= 07777;  }
void I00452() { lac &= (010000|core[000122]);  }
void I00453() { core[000125] = lac & 07777; lac &= 010000; code[000125] = &emul8;  }
void I00454() { core[000466] = 00455; npc = 000466+1; code[000466] = &emul8; inh = 0;  }
void I00455() { lac &= 010000; lac ^= 07777;  }
void I00456() { lac &= (010000|core[000135]);  }
void I00457() { core[000125] = lac & 07777; lac &= 010000; code[000125] = &emul8;  }
void I00460() { core[000466] = 00461; npc = 000466+1; code[000466] = &emul8; inh = 0;  }
void I00461() { lac &= 010000; lac ^= 07777;  }
void I00462() { lac &= (010000|core[000136]);  }
void I00463() { core[000125] = lac & 07777; lac &= 010000; code[000125] = &emul8;  }
void I00464() { core[000466] = 00465; npc = 000466+1; code[000466] = &emul8; inh = 0;  }
void I00465() { npc = (ib<<12)+core[270]; inh = 0;  }
void S00466() { lac &= (010000|core[000000]);  }
void I00467() { lac &= 010000; lac ^= 07777;  }
void I00470() { lac &= (010000|core[000137]);  }
void I00471() { core[000112] = lac & 07777; lac &= 010000; code[000112] = &emul8;  }
void L00472() { if (++core[000112] == 010000) { core[000112] = 0; npc++; }; code[000112] = &emul8;  }
void I00473() { skp = 0; skp = !skp; npc += skp;  }
void I00474() { npc = 000512; inh = 0;  }
void I00475() { lac &= 010000; lac ^= 07777;  }
void I00476() { lac &= (010000|core[000125]);  }
void I00477() { lac &= 07777;  }
void I00500() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00501() { core[000125] = lac & 07777; lac &= 010000; code[000125] = &emul8;  }
void P00502() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00503() { npc = 000506; inh = 0;  }
void I00504() { core[(ib<<12)+core[372]] = 00505; npc = (ib<<12)+core[372]+1; code[(ib<<12)+core[372]] = &emul8; inh = 0;  }
void I00505() { npc = 000472; inh = 0;  }
void L00506() { lac &= 010000; lac ^= 07777;  }
void I00507() { lac &= (010000|core[000106]);  }
void I00510() { core[000020] = 00511; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00511() { npc = 000472; inh = 0;  }
void L00512() { lac &= 010000; lac ^= 07777;  }
void I00513() { lac &= (010000|core[000102]);  }
void I00514() { core[000020] = 00515; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00515() { lac &= 010000; lac ^= 07777;  }
void I00516() { lac &= (010000|core[000102]);  }
void I00517() { core[000020] = 00520; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00520() { npc = (ib<<12)+core[310]; inh = 0;  }
void S00521() { lac &= (010000|core[000000]);  }
void I00522() { lac &= 010000;  }
void I00523() { core[000124] = lac & 07777; lac &= 010000; code[000124] = &emul8;  }
void I00524() { lac &= 010000; lac ^= 07777;  }
void I00525() { lac &= (010000|core[000126]);  }
void I00526() { core[000127] = lac & 07777; lac &= 010000; code[000127] = &emul8;  }
void I00527() { core[000041] = 00530; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void L00530() { lac &= 010000; lac ^= 07777;  }
void I00531() { lac &= (010000|core[000102]);  }
void I00532() { core[000020] = 00533; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00533() { if (++core[000127] == 010000) { core[000127] = 0; npc++; }; code[000127] = &emul8;  }
void I00534() { npc = 000530; inh = 0;  }
void I00535() { lac &= 010000; lac ^= 07777;  }
void I00536() { lac &= (010000|core[000130]);  }
void I00537() { core[000020] = 00540; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00540() { lac &= 010000; lac ^= 07777;  }
void I00541() { lac &= (010000|core[000107]);  }
void I00542() { core[000020] = 00543; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00543() { lac &= 010000; lac ^= 07777;  }
void I00544() { lac &= (010000|core[000107]);  }
void I00545() { core[000020] = 00546; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00546() { lac &= 010000; lac ^= 07777;  }
void I00547() { lac &= (010000|core[000131]);  }
void I00550() { core[000020] = 00551; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00551() { core[(ib<<12)+core[370]] = 00552; npc = (ib<<12)+core[370]+1; code[(ib<<12)+core[370]] = &emul8; inh = 0;  }
void I00552() { lac &= 010000; lac ^= 07777;  }
void I00553() { lac &= (010000|core[000114]);  }
void I00554() { core[000020] = 00555; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00555() { lac &= 010000; lac ^= 07777;  }
void I00556() { lac &= (010000|core[000076]);  }
void I00557() { core[000020] = 00560; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00560() { npc = (ib<<12)+core[369]; inh = 0;  }
void P00561() { lac &= (010000|core[(df<<12)+core[256]]);  }
void P00562() { lac &= (010000|core[(df<<12)+core[278]]);  }
void L00563() { npc = (ib<<12)+core[337]; inh = 0;  }
void P00564() { if (++core[(df<<12)+core[322]] == 010000) { core[(df<<12)+core[322]] = 0; npc++; }; code[(df<<12)+core[322]] = &emul8;  }
void L00600() { lac &= 010000; lac ^= 07777;  }
void I00601() { lac &= (010000|core[000131]);  }
void I00602() { core[000020] = 00603; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00603() { core[000626] = 00604; npc = 000626+1; code[000626] = &emul8; inh = 0;  }
void I00604() { lac &= 010000; lac ^= 07777;  }
void I00605() { lac &= (010000|core[000132]);  }
void I00606() { core[000020] = 00607; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00607() { lac &= 010000; lac ^= 07777;  }
void I00610() { lac &= (010000|core[000102]);  }
void I00611() { core[000020] = 00612; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00612() { core[000640] = 00613; npc = 000640+1; code[000640] = &emul8; inh = 0;  }
void I00613() { core[000626] = 00614; npc = 000626+1; code[000626] = &emul8; inh = 0;  }
void I00614() { lac &= 010000; lac ^= 07777;  }
void I00615() { lac &= (010000|core[000133]);  }
void I00616() { core[000020] = 00617; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00617() { lac &= 010000; lac ^= 07777;  }
void I00620() { lac &= (010000|core[000102]);  }
void I00621() { core[000020] = 00622; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00622() { core[000640] = 00623; npc = 000640+1; code[000640] = &emul8; inh = 0;  }
void I00623() { core[000041] = 00624; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void I00624() { npc = (ib<<12)+core[405]; inh = 0;  }
void P00625() { lac &= (010000|core[(df<<12)+core[115]]);  }
void S00626() { lac &= (010000|core[000000]);  }
void I00627() { lac &= 010000; lac ^= 07777;  }
void I00630() { lac &= (010000|core[000111]);  }
void I00631() { core[000127] = lac & 07777; lac &= 010000; code[000127] = &emul8;  }
void L00632() { lac &= 010000; lac ^= 07777;  }
void I00633() { lac &= (010000|core[000102]);  }
void I00634() { core[000020] = 00635; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00635() { if (++core[000127] == 010000) { core[000127] = 0; npc++; }; code[000127] = &emul8;  }
void I00636() { npc = 000632; inh = 0;  }
void I00637() { npc = (ib<<12)+core[406]; inh = 0;  }
void S00640() { lac &= (010000|core[000000]);  }
void I00641() { lac &= 010000; lac ^= 07777;  }
void I00642() { lac &= (010000|core[000076]);  }
void I00643() { core[000020] = 00644; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00644() { lac &= 010000; lac ^= 07777;  }
void I00645() { lac &= (010000|core[000075]);  }
void I00646() { core[000020] = 00647; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00647() { lac &= 010000; lac ^= 07777;  }
void I00650() { lac &= (010000|core[000130]);  }
void I00651() { core[000020] = 00652; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I00652() { npc = (ib<<12)+core[416]; inh = 0;  }
void L02000() { core[002116] = 02001; npc = 002116+1; code[002116] = &emul8; inh = 0;  }
void I02001() { core[000142] = 02002; npc = 000142+1; code[000142] = &emul8; inh = 0;  }
void I02002() { lac &= (010000|core[000051]);  }
void I02003() { lac++;  }
void I02004() { core[000051] = lac & 07777; lac &= 010000; code[000051] = &emul8;  }
void I02005() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02006() { npc = 002015; inh = 0;  }
void I02007() { lac += core[000060];  }
void I02010() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void L02011() { core[002152] = 02012; npc = 002152+1; code[002152] = &emul8; inh = 0;  }
void I02012() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02013() { npc = 002020; inh = 0;  }
void I02014() { npc = 002074; inh = 0;  }
void L02015() { lac &= 010000;  }
void I02016() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void I02017() { npc = 002011; inh = 0;  }
void L02020() { lac &= 010000; lac ^= 07777;  }
void I02021() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I02022() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02023() { lac &= (010000|core[000140]);  }
void I02024() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02025() { npc = 002072; inh = 0;  }
void I02026() { lac &= 07777; lac ^= 07777;  }
void L02027() { lac &= (010000|core[000051]);  }
void I02030() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02031() { core[000052] = lac & 07777; lac &= 010000; code[000052] = &emul8;  }
void I02032() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02033() { lac += core[000060];  }
void I02034() { core[000053] = lac & 07777; lac &= 010000; code[000053] = &emul8;  }
void I02035() { lac &= 010000; lac ^= 07777;  }
void I02036() { lac &= (010000|core[000052]);  }
void I02037() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I02040() { core[000054] = lac & 07777; lac &= 010000; code[000054] = &emul8;  }
void I02041() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02042() { lac += core[000060];  }
void I02043() { core[000055] = lac & 07777; lac &= 010000; code[000055] = &emul8;  }
void I02044() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02045() { lac &= (010000|core[000054]);  }
void I02046() { lac ^= 07777;  }
void I02047() { lac += core[000051];  }
void I02050() { lac ^= 07777;  }
void I02051() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02052() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02053() { npc = (ib<<12)+core[1101]; inh = 0;  }
void I02054() { lac += core[000060];  }
void I02055() { lac &= (010000|core[000051]);  }
void I02056() { lac ^= 07777;  }
void I02057() { lac += core[000053];  }
void I02060() { lac ^= 07777;  }
void I02061() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02062() { npc = (ib<<12)+core[1101]; inh = 0;  }
void I02063() { lac += core[000055];  }
void I02064() { lac ^= 07777;  }
void I02065() { lac += core[000140];  }
void I02066() { lac ^= 07777;  }
void I02067() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02070() { npc = (ib<<12)+core[1101]; inh = 0;  }
void I02071() { npc = (ib<<12)+core[1129]; inh = 0;  }
void L02072() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I02073() { npc = 002027; inh = 0;  }
void L02074() { core[002116] = 02075; npc = 002116+1; code[002116] = &emul8; inh = 0;  }
void I02075() { core[000142] = 02076; npc = 000142+1; code[000142] = &emul8; inh = 0;  }
void I02076() { lac &= (010000|core[000051]);  }
void I02077() { lac++;  }
void I02100() { core[000051] = lac & 07777; lac &= 010000; code[000051] = &emul8;  }
void I02101() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02102() { npc = 002111; inh = 0;  }
void I02103() { lac += core[000060];  }
void I02104() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void L02105() { core[002163] = 02106; npc = 002163+1; code[002163] = &emul8; inh = 0;  }
void I02106() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02107() { npc = (ib<<12)+core[1100]; inh = 0;  }
void I02110() { npc = 002132; inh = 0;  }
void L02111() { lac &= 010000;  }
void I02112() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void I02113() { npc = 002105; inh = 0;  }
void P02114() { if (++core[002000] == 010000) { core[002000] = 0; npc++; }; code[002000] = &emul8;  }
void P02115() { if (++core[(df<<12)+core[0]] == 010000) { core[(df<<12)+core[0]] = 0; npc++; }; code[(df<<12)+core[0]] = &emul8;  }
void S02116() { lac &= (010000|core[000000]);  }
void I02117() { lac &= 010000; lac &= 07777;  }
void I02120() { core[000051] = lac & 07777; lac &= 010000; code[000051] = &emul8;  }
void I02121() { core[000052] = lac & 07777; lac &= 010000; code[000052] = &emul8;  }
void I02122() { core[000054] = lac & 07777; lac &= 010000; code[000054] = &emul8;  }
void I02123() { core[000053] = lac & 07777; lac &= 010000; code[000053] = &emul8;  }
void I02124() { core[000055] = lac & 07777; lac &= 010000; code[000055] = &emul8;  }
void I02125() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void I02126() {  }
void I02127() {  }
void I02130() {  }
void I02131() { npc = (ib<<12)+core[1102]; inh = 0;  }
void L02132() { lac &= 010000;  }
void I02133() { core[000041] = 02134; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void I02134() { lac += core[000075];  }
void I02135() { core[000020] = 02136; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02136() { lac += core[000107];  }
void I02137() { core[000020] = 02140; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02140() { lac += core[000100];  }
void I02141() { core[000020] = 02142; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02142() { core[000041] = 02143; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void I02143() { lac += core[000113];  }
void I02144() { core[000020] = 02145; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02145() { lac += core[000114];  }
void I02146() { core[000020] = 02147; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02147() { npc = (ib<<12)+core[1128]; inh = 0;  }
void P02150() { lac &= (010000|core[002000]);  }
void P02151() { if (++core[(df<<12)+core[81]] == 010000) { core[(df<<12)+core[81]] = 0; npc++; }; code[(df<<12)+core[81]] = &emul8;  }
void S02152() { lac &= (010000|core[000000]);  }
void I02153() { lac += core[000140];  }
void I02154() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02155() { skp = 0; skp = !skp; npc += skp;  }
void I02156() { npc = 002020; inh = 0;  }
void I02157() { lac &= 010000; lac ^= 07777;  }
void I02160() { lac &= (010000|core[000051]);  }
void I02161() { lac ^= 07777;  }
void I02162() { npc = (ib<<12)+core[1130]; inh = 0;  }
void S02163() { lac &= (010000|core[000000]);  }
void I02164() { lac += core[000140];  }
void I02165() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02166() { skp = 0; skp = !skp; npc += skp;  }
void I02167() { npc = (ib<<12)+core[1100]; inh = 0;  }
void I02170() { lac &= 010000; lac ^= 07777;  }
void I02171() { lac &= (010000|core[000051]);  }
void I02172() { lac ^= 07777;  }
void I02173() { npc = (ib<<12)+core[1139]; inh = 0;  }
void L02200() { lac &= 010000; lac &= 07777;  }
void I02201() { core[000056] = lac & 07777; lac &= 010000; code[000056] = &emul8;  }
void I02202() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02203() { lac &= (010000|core[000140]);  }
void I02204() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02205() { npc = 002250; inh = 0;  }
void I02206() { lac &= 07777; lac ^= 07777;  }
void L02207() { lac &= (010000|core[000051]);  }
void I02210() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02211() { core[000054] = lac & 07777; lac &= 010000; code[000054] = &emul8;  }
void I02212() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02213() { lac += core[000072];  }
void I02214() { core[000055] = lac & 07777; lac &= 010000; code[000055] = &emul8;  }
void I02215() { lac += core[000054];  }
void I02216() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02217() { core[000052] = lac & 07777; lac &= 010000; code[000052] = &emul8;  }
void I02220() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02221() { lac += core[000060];  }
void I02222() { core[000053] = lac & 07777; lac &= 010000; code[000053] = &emul8;  }
void I02223() { lac &= 07777;  }
void I02224() { lac += core[000052];  }
void I02225() { lac ^= 07777;  }
void I02226() { lac += core[000051];  }
void I02227() { lac ^= 07777;  }
void I02230() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02231() { npc = (ib<<12)+core[1194]; inh = 0;  }
void I02232() { lac += core[000072];  }
void I02233() { lac &= (010000|core[000051]);  }
void I02234() { lac ^= 07777;  }
void I02235() { lac += core[000055];  }
void I02236() { lac ^= 07777;  }
void I02237() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02240() { npc = (ib<<12)+core[1194]; inh = 0;  }
void I02241() { lac += core[000053];  }
void I02242() { lac ^= 07777;  }
void I02243() { lac += core[000140];  }
void I02244() { lac ^= 07777;  }
void I02245() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02246() { npc = (ib<<12)+core[1194]; inh = 0;  }
void I02247() { npc = (ib<<12)+core[1195]; inh = 0;  }
void L02250() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I02251() { npc = 002207; inh = 0;  }
void P02252() { if (++core[(df<<12)+core[6]] == 010000) { core[(df<<12)+core[6]] = 0; npc++; }; code[(df<<12)+core[6]] = &emul8;  }
void P02253() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void P02400() { lac &= 010000;  }
void I02401() { lac += core[002444];  }
void I02402() { core[002415] = lac & 07777; lac &= 010000; code[002415] = &emul8;  }
void I02403() { lac += core[002445];  }
void I02404() { core[002414] = lac & 07777; lac &= 010000; code[002414] = &emul8;  }
void I02405() { npc = 002416; inh = 0;  }
void L02406() { lac &= 010000;  }
void I02407() { lac += core[002450];  }
void I02410() { core[002415] = lac & 07777; lac &= 010000; code[002415] = &emul8;  }
void I02411() { lac += core[002451];  }
void I02412() { core[002414] = lac & 07777; lac &= 010000; code[002414] = &emul8;  }
void I02413() { npc = 002416; inh = 0;  }
void P02414() { lac &= (010000|core[000000]);  }
void P02415() { lac &= (010000|core[000000]);  }
void P02416() { lac &= 010000; lac |= swr;  }
void I02417() { lac &= (010000|core[000062]);  }
void I02420() { lac ^= 07777;  }
void I02421() { lac += core[000062];  }
void I02422() { lac ^= 07777;  }
void I02423() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02424() { core[002455] = 02425; npc = 002455+1; code[002455] = &emul8; inh = 0;  }
void I02425() { lac &= 010000; lac |= swr;  }
void I02426() { lac &= (010000|core[000060]);  }
void I02427() { lac ^= 07777;  }
void I02430() { lac += core[000060];  }
void I02431() { lac ^= 07777;  }
void I02432() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02433() { hlt = 1;  }
void L02434() { lac &= 010000; lac |= swr;  }
void I02435() { lac &= (010000|core[000061]);  }
void I02436() { lac ^= 07777;  }
void I02437() { lac += core[000061];  }
void I02440() { lac ^= 07777;  }
void I02441() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02442() { npc = (ib<<12)+core[1293]; inh = 0;  }
void I02443() { npc = (ib<<12)+core[1292]; inh = 0;  }
void D02444() { if (++core[000020] == 010000) { core[000020] = 0; npc++; }; code[000020] = &emul8;  }
void D02445() { if (++core[000001] == 010000) { core[000001] = 0; npc++; }; code[000001] = &emul8;  }
void I02446() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I02447() { if (++core[000074] == 010000) { core[000074] = 0; npc++; }; code[000074] = &emul8;  }
void P02450() { if (++core[002400] == 010000) { core[002400] = 0; npc++; }; code[002400] = &emul8;  }
void D02451() { if (++core[000075] == 010000) { core[000075] = 0; npc++; }; code[000075] = &emul8;  }
void I02452() { if (++core[(df<<12)+core[52]] == 010000) { core[(df<<12)+core[52]] = 0; npc++; }; code[(df<<12)+core[52]] = &emul8;  }
void I02453() { if (++core[(df<<12)+core[53]] == 010000) { core[(df<<12)+core[53]] = 0; npc++; }; code[(df<<12)+core[53]] = &emul8;  }
void D02454() { if (++core[(df<<12)+core[1320]] == 010000) { core[(df<<12)+core[1320]] = 0; npc++; }; code[(df<<12)+core[1320]] = &emul8;  }
void S02455() { lac &= (010000|core[000000]);  }
void I02456() { core[000026] = 02457; npc = 000026+1; code[000026] = &emul8; inh = 0;  }
void I02457() { core[(ib<<12)+core[1356]] = 02460; npc = (ib<<12)+core[1356]+1; code[(ib<<12)+core[1356]] = &emul8; inh = 0;  }
void I02460() { lac &= 010000;  }
void I02461() { lac += core[000056];  }
void I02462() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02463() { npc = 002466; inh = 0;  }
void I02464() { core[(ib<<12)+core[1357]] = 02465; npc = (ib<<12)+core[1357]+1; code[(ib<<12)+core[1357]] = &emul8; inh = 0;  }
void I02465() { npc = (ib<<12)+core[1325]; inh = 0;  }
void L02466() { lac &= 010000;  }
void I02467() { lac += core[002454];  }
void I02470() { core[(df<<12)+core[1356]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1356]] = &emul8;  }
void I02471() { core[000041] = 02472; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void I02472() { lac &= 010000;  }
void I02473() { lac += core[000075];  }
void I02474() { core[000020] = 02475; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02475() { lac += core[000076];  }
void P02476() { core[000020] = 02477; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02477() { lac += core[000077];  }
void I02500() { core[000020] = 02501; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02501() { lac += core[000102];  }
void P02502() { core[000020] = 02503; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02503() { lac += core[000053];  }
void I02504() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02505() { npc = (ib<<12)+core[1358]; inh = 0;  }
void I02506() { core[(ib<<12)+core[1359]] = 02507; npc = (ib<<12)+core[1359]+1; code[(ib<<12)+core[1359]] = &emul8; inh = 0;  }
void L02507() { lac += core[000102];  }
void I02510() { core[000020] = 02511; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02511() { lac += core[000052];  }
void I02512() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02513() { npc = (ib<<12)+core[1360]; inh = 0;  }
void P02514() { if (++core[(df<<12)+core[1280]] == 010000) { core[(df<<12)+core[1280]] = 0; npc++; }; code[(df<<12)+core[1280]] = &emul8;  }
void P02515() { if (++core[(df<<12)+core[1370]] == 010000) { core[(df<<12)+core[1370]] = 0; npc++; }; code[(df<<12)+core[1370]] = &emul8;  }
void P02516() { if (++core[(df<<12)+core[1342]] == 010000) { core[(df<<12)+core[1342]] = 0; npc++; }; code[(df<<12)+core[1342]] = &emul8;  }
void P02517() { if (++core[(df<<12)+core[1346]] == 010000) { core[(df<<12)+core[1346]] = 0; npc++; }; code[(df<<12)+core[1346]] = &emul8;  }
void P02520() { if (++core[(df<<12)+core[1294]] == 010000) { core[(df<<12)+core[1294]] = 0; npc++; }; code[(df<<12)+core[1294]] = &emul8;  }
void L02521() { lac &= 010000;  }
void I02522() { lac += core[002445];  }
void I02523() { core[002414] = lac & 07777; lac &= 010000; code[002414] = &emul8;  }
void I02524() { npc = 002434; inh = 0;  }
void L02525() { lac &= 010000;  }
void I02526() { lac += core[002451];  }
void I02527() { core[002414] = lac & 07777; lac &= 010000; code[002414] = &emul8;  }
void I02530() { npc = 002434; inh = 0;  }
void S02600() { lac &= (010000|core[000000]);  }
void I02601() { lac += core[000101];  }
void I02602() { core[000020] = 02603; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02603() { lac += core[000076];  }
void I02604() { core[000020] = 02605; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02605() { lac += core[000100];  }
void I02606() { core[000020] = 02607; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02607() { lac += core[000102];  }
void I02610() { core[000020] = 02611; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02611() { core[002761] = 02612; npc = 002761+1; code[002761] = &emul8; inh = 0;  }
void I02612() { lac += core[000102];  }
void I02613() { core[000020] = 02614; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02614() { lac += core[000051];  }
void I02615() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void L02616() { core[002631] = 02617; npc = 002631+1; code[002631] = &emul8; inh = 0;  }
void I02617() { lac &= (010000|core[000137]);  }
void I02620() { core[000112] = lac & 07777; lac &= 010000; code[000112] = &emul8;  }
void L02621() { if (++core[000112] == 010000) { core[000112] = 0; npc++; }; code[000112] = &emul8;  }
void I02622() { skp = 0; skp = !skp; npc += skp;  }
void I02623() { npc = (ib<<12)+core[1408]; inh = 0;  }
void I02624() { lac &= 010000;  }
void I02625() { lac += core[000057];  }
void I02626() { if (++core[000010] == 010000) core[000010] = 0000;lac &= (010000|core[(df<<12)+core[000010]]);  }
void I02627() { core[002637] = 02630; npc = 002637+1; code[002637] = &emul8; inh = 0;  }
void I02630() { npc = 002621; inh = 0;  }
void S02631() { lac &= (010000|core[000000]);  }
void I02632() { lac &= 010000;  }
void I02633() { lac += core[000074];  }
void I02634() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void I02635() { lac &= 010000; lac ^= 07777;  }
void I02636() { npc = (ib<<12)+core[1433]; inh = 0;  }
void S02637() { lac &= (010000|core[000000]);  }
void I02640() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02641() { npc = 002644; inh = 0;  }
void I02642() { core[002702] = 02643; npc = 002702+1; code[002702] = &emul8; inh = 0;  }
void I02643() { npc = (ib<<12)+core[1439]; inh = 0;  }
void L02644() { lac &= 010000; lac ^= 07777;  }
void I02645() { lac &= (010000|core[000106]);  }
void I02646() { core[000020] = 02647; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02647() { npc = (ib<<12)+core[1439]; inh = 0;  }
void I02650() { lac &= 010000;  }
void I02651() { lac += core[002673];  }
void I02652() { core[002600] = lac & 07777; lac &= 010000; code[002600] = &emul8;  }
void I02653() { core[000041] = 02654; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void I02654() { lac &= 010000;  }
void I02655() { lac += core[000075];  }
void I02656() { core[000020] = 02657; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02657() { lac += core[000076];  }
void I02660() { core[000020] = 02661; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02661() { core[002723] = 02662; npc = 002723+1; code[002723] = &emul8; inh = 0;  }
void I02662() { lac += core[000055];  }
void I02663() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02664() { npc = 002707; inh = 0;  }
void I02665() { core[002702] = 02666; npc = 002702+1; code[002702] = &emul8; inh = 0;  }
void L02666() { lac += core[000102];  }
void I02667() { core[000020] = 02670; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02670() { lac += core[000054];  }
void I02671() { core[000057] = lac & 07777; lac &= 010000; code[000057] = &emul8;  }
void I02672() { npc = 002616; inh = 0;  }
void D02673() { if (++core[(df<<12)+core[53]] == 010000) { core[(df<<12)+core[53]] = 0; npc++; }; code[(df<<12)+core[53]] = &emul8;  }
void P02674() { if (++core[(df<<12)+core[71]] == 010000) { core[(df<<12)+core[71]] = 0; npc++; }; code[(df<<12)+core[71]] = &emul8;  }
void D02675() { if (++core[(df<<12)+core[1508]] == 010000) { core[(df<<12)+core[1508]] = 0; npc++; }; code[(df<<12)+core[1508]] = &emul8;  }
void L02676() { lac &= 010000; lac ^= 07777;  }
void I02677() { lac &= (010000|core[000106]);  }
void I02700() { core[000020] = 02701; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02701() { npc = (ib<<12)+core[1468]; inh = 0;  }
void S02702() { lac &= (010000|core[000000]);  }
void I02703() { lac &= 010000; lac ^= 07777;  }
void I02704() { lac &= (010000|core[000105]);  }
void I02705() { core[000020] = 02706; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02706() { npc = (ib<<12)+core[1474]; inh = 0;  }
void L02707() { lac &= 010000;  }
void I02710() { lac += core[000106];  }
void I02711() { core[000020] = 02712; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02712() { npc = 002666; inh = 0;  }
void S02713() { lac &= (010000|core[000000]);  }
void I02714() { lac &= 010000;  }
void I02715() { core[000041] = 02716; npc = 000041+1; code[000041] = &emul8; inh = 0;  }
void I02716() { lac += core[000075];  }
void I02717() { core[000020] = 02720; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02720() { lac += core[000100];  }
void I02721() { core[000020] = 02722; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02722() { npc = (ib<<12)+core[1483]; inh = 0;  }
void S02723() { lac &= (010000|core[000000]);  }
void I02724() { lac &= 010000;  }
void I02725() { lac += core[000075];  }
void I02726() { core[000020] = 02727; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02727() { lac += core[000102];  }
void I02730() { core[000020] = 02731; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02731() { npc = (ib<<12)+core[1491]; inh = 0;  }
void I02732() { lac &= 010000;  }
void I02733() { lac += core[002675];  }
void I02734() { core[002600] = lac & 07777; lac &= 010000; code[002600] = &emul8;  }
void I02735() { core[002713] = 02736; npc = 002713+1; code[002713] = &emul8; inh = 0;  }
void I02736() { core[002723] = 02737; npc = 002723+1; code[002723] = &emul8; inh = 0;  }
void I02737() { lac += core[000055];  }
void I02740() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02741() { npc = 002707; inh = 0;  }
void I02742() { core[002702] = 02743; npc = 002702+1; code[002702] = &emul8; inh = 0;  }
void I02743() { npc = 002666; inh = 0;  }
void P02744() { lac &= 010000;  }
void I02745() { lac += core[002673];  }
void I02746() { core[002600] = lac & 07777; lac &= 010000; code[002600] = &emul8;  }
void I02747() { core[002713] = 02750; npc = 002713+1; code[002713] = &emul8; inh = 0;  }
void I02750() { lac += core[000077];  }
void I02751() { core[000020] = 02752; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02752() { lac += core[000102];  }
void I02753() { core[000020] = 02754; npc = 000020+1; code[000020] = &emul8; inh = 0;  }
void I02754() { lac += core[000053];  }
void I02755() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02756() { npc = 002676; inh = 0;  }
void I02757() { core[002702] = 02760; npc = 002702+1; code[002702] = &emul8; inh = 0;  }
void I02760() { npc = (ib<<12)+core[1468]; inh = 0;  }
void S02761() { lac &= (010000|core[000000]);  }
void I02762() { lac += core[000140];  }
void I02763() { core[002637] = 02764; npc = 002637+1; code[002637] = &emul8; inh = 0;  }
void I02764() { npc = (ib<<12)+core[1521]; inh = 0;  }
void L04000() { lac &= 010000;  }
void I04001() { if (++core[000017] == 010000) core[000017] = 0000;lac += core[(df<<12)+core[000017]];  }
void I04002() { core[000135] = lac & 07777; lac &= 010000; code[000135] = &emul8;  }
void I04003() { if (++core[000017] == 010000) core[000017] = 0000;lac += core[(df<<12)+core[000017]];  }
void I04004() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04005() { if (++core[004016] == 010000) { core[004016] = 0; npc++; }; code[004016] = &emul8;  }
void I04006() { npc = (ib<<12)+core[2087]; inh = 0;  }
void I04007() { lac += core[004015];  }
void I04010() { core[000017] = lac & 07777; lac &= 010000; code[000017] = &emul8;  }
void I04011() { lac += core[004014];  }
void I04012() { core[004016] = lac & 07777; lac &= 010000; code[004016] = &emul8;  }
void I04013() { npc = (ib<<12)+core[2087]; inh = 0;  }
void D04014() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void D04015() { core[000177] = 04016; npc = 000177+1; code[000177] = &emul8; inh = 0;  }
void D04016() { lac &= (010000|core[000000]);  }
void D04017() { lac &= (010000|core[000000]);  }
void L04020() { lac &= 010000; lac &= 07777;  }
void I04021() { if (++core[004017] == 010000) { core[004017] = 0; npc++; }; code[004017] = &emul8;  }
void I04022() {  }
void I04023() { lac += core[004017];  }
void I04024() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void D04025() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04026() { npc = 004030; inh = 0;  }
void I04027() { npc = 004000; inh = 0;  }
void L04030() { lac &= 010000; lac |= swr;  }
void I04031() { lac &= (010000|core[000063]);  }
void I04032() {  }
void I04033() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04034() { npc = (ib<<12)+core[2088]; inh = 0;  }
void I04035() { lac &= 010000; lac ^= 07777;  }
void I04036() { lac &= (010000|core[000121]);  }
void I04037() {  }
void I04040() { core[000135] = lac & 07777; lac &= 010000; code[000135] = &emul8;  }
void I04041() { lac ^= 07777;  }
void I04042() { lac &= (010000|core[000121]);  }
void I04043() { lac++;  }
void I04044() { if (++core[000010] == 010000) core[000010] = 0000;lac += core[(df<<12)+core[000010]];  }
void I04045() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04046() { npc = (ib<<12)+core[2087]; inh = 0;  }
void P04047() { lac &= (010000|core[004025]);  }
void P04050() { lac &= (010000|core[004112]);  }
void L04051() { lac &= 010000; lac ^= 07777;  }
void I04052() { lac &= (010000|core[000121]);  }
void I04053() { lac ^= 07777;  }
void I04054() { lac &= (010000|core[000122]);  }
void I04055() { core[004075] = lac & 07777; lac &= 010000; code[004075] = &emul8;  }
void I04056() { lac &= 010000; lac ^= 07777;  }
void I04057() { lac &= (010000|core[000122]);  }
void I04060() { lac ^= 07777;  }
void I04061() { lac &= (010000|core[000121]);  }
void I04062() { core[004074] = lac & 07777; lac &= 010000; code[004074] = &emul8;  }
void I04063() { lac &= 010000; lac ^= 07777;  }
void I04064() { lac &= (010000|core[004075]);  }
void I04065() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04066() { npc = (ib<<12)+core[2110]; inh = 0;  }
void I04067() { lac &= 010000; lac ^= 07777;  }
void I04070() { lac &= (010000|core[004074]);  }
void I04071() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04072() { npc = (ib<<12)+core[2110]; inh = 0;  }
void I04073() { npc = 004077; inh = 0;  }
void D04074() { lac &= (010000|core[000000]);  }
void D04075() { lac &= (010000|core[000000]);  }
void P04076() { lac &= (010000|core[(df<<12)+core[0]]);  }
void L04077() { lac &= 010000; lac ^= 07777;  }
void I04100() { lac &= (010000|core[000134]);  }
void I04101() { lac ^= 07777;  }
void I04102() { lac &= (010000|core[000120]);  }
void I04103() { core[004122] = lac & 07777; lac &= 010000; code[004122] = &emul8;  }
void I04104() { lac &= 010000; lac ^= 07777;  }
void I04105() { lac &= (010000|core[000120]);  }
void I04106() { lac ^= 07777;  }
void I04107() { lac &= (010000|core[000134]);  }
void I04110() { core[004123] = lac & 07777; lac &= 010000; code[004123] = &emul8;  }
void I04111() { lac &= 010000; lac ^= 07777;  }
void D04112() { lac &= (010000|core[004122]);  }
void I04113() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04114() { npc = (ib<<12)+core[2110]; inh = 0;  }
void I04115() { lac &= 010000; lac ^= 07777;  }
void I04116() { lac &= (010000|core[004123]);  }
void I04117() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04120() { npc = (ib<<12)+core[2110]; inh = 0;  }
void I04121() { npc = (ib<<12)+core[2132]; inh = 0;  }
void D04122() { lac &= (010000|core[000000]);  }
void D04123() { lac &= (010000|core[000000]);  }
void P04124() { lac &= (010000|core[(df<<12)+core[7]]);  }
void D04200() { emul8();  }
void I04201() { emul8();  }
void I04202() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I04203() { emul8();  }
void I04204() { emul8();  }
void I04205() { emul8();  }
void I04206() { emul8();  }
void I04207() { emul8();  }
void I04210() { emul8();  }
void I04211() { emul8();  }
void I04212() { emul8();  }
void I04213() { emul8();  }
void I04214() { emul8();  }
void I04215() { emul8();  }
void I04216() { emul8();  }
void I04217() { emul8();  }
void I04220() { emul8();  }
void I04221() { emul8();  }
void I04222() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04223() { emul8();  }
void I04224() { emul8();  }
void I04225() { emul8();  }
void I04226() { npc = (ib<<12)+core[2303]; inh = 0;  }
void I04227() { emul8();  }
void I04230() { core[(df<<12)+core[2303]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2303]] = &emul8;  }
void I04231() { emul8();  }
void I04232() { emul8();  }
void I04233() { emul8();  }
void I04234() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I04235() { emul8();  }
void I04236() { emul8();  }
void I04237() { emul8();  }
void I04240() { emul8();  }
void I04241() { emul8();  }
void I04242() { emul8();  }
void I04243() { emul8();  }
void I04244() { emul8();  }
void I04245() { emul8();  }
void I04246() { emul8();  }
void I04247() { emul8();  }
void I04250() { emul8();  }
void I04251() { emul8();  }
void I04252() { emul8();  }
void I04253() { emul8();  }
void I04254() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04255() { emul8();  }
void I04256() { emul8();  }
void I04257() { npc = (ib<<12)+core[2303]; inh = 0;  }
void I04260() { emul8();  }
void I04261() { core[(df<<12)+core[2303]] = lac & 07777; lac &= 010000; code[(df<<12)+core[2303]] = &emul8;  }
void I04262() { emul8();  }
void I04263() { lac &= (010000|core[000001]);  }
void I04264() { emul8();  }
void I04265() { lac &= (010000|core[000002]);  }
void I04266() { emul8();  }
void I04267() { lac &= (010000|core[000004]);  }
void I04270() { emul8();  }
void I04271() { lac &= (010000|core[000010]);  }
void I04272() { emul8();  }
void I04273() { lac &= (010000|core[000020]);  }
void I04274() { emul8();  }
void I04275() { lac &= (010000|core[000040]);  }
void I04276() { emul8();  }
void I04277() { lac &= (010000|core[000100]);  }
void I04300() { emul8();  }
void I04301() { lac &= (010000|core[004200]);  }
void I04302() { emul8();  }
void I04303() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I04304() { emul8();  }
void I04305() { lac += core[000000];  }
void I04306() { emul8();  }
void I04307() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I04310() { emul8();  }
void I04311() { core[000000] = 04312; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I04312() { lac &= (010000|core[000001]);  }
void I04313() { emul8();  }
void I04314() { lac &= (010000|core[000002]);  }
void I04315() { emul8();  }
void I04316() { lac &= (010000|core[000004]);  }
void I04317() { emul8();  }
void I04320() { lac &= (010000|core[000010]);  }
void I04321() { emul8();  }
void I04322() { lac &= (010000|core[004200]);  }
void I04323() { emul8();  }
void I04324() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I04325() { emul8();  }
void I04326() { lac &= (010000|core[000100]);  }
void I04327() { emul8();  }
void I04330() { lac &= (010000|core[004200]);  }
void I04331() { emul8();  }
void I04332() { lac &= (010000|core[(df<<12)+core[0]]);  }
void I04333() { emul8();  }
void I04334() { lac += core[000000];  }
void I04335() { emul8();  }
void I04336() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void I04337() { emul8();  }
void I04340() { core[000000] = 04341; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void I04341() { emul8();  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &L00001;
  core[000002] = 00002; code[000002] = &D00002;
  core[000003] = 00003; code[000003] = &D00003;
  core[000017] = 04177; code[000017] = &P00017;
  core[000020] = 00000; code[000020] = &S00020;
  core[000021] = 06046; code[000021] = &I00021;
  core[000022] = 06041; code[000022] = &L00022;
  core[000023] = 05022; code[000023] = &I00023;
  core[000024] = 07200; code[000024] = &I00024;
  core[000025] = 05420; code[000025] = &I00025;
  core[000026] = 00000; code[000026] = &S00026;
  core[000027] = 07240; code[000027] = &I00027;
  core[000030] = 00104; code[000030] = &I00030;
  core[000031] = 04020; code[000031] = &I00031;
  core[000032] = 07240; code[000032] = &I00032;
  core[000033] = 00103; code[000033] = &I00033;
  core[000034] = 04020; code[000034] = &I00034;
  core[000035] = 07240; code[000035] = &I00035;
  core[000036] = 00103; code[000036] = &I00036;
  core[000037] = 04020; code[000037] = &I00037;
  core[000040] = 05426; code[000040] = &D00040;
  core[000041] = 00000; code[000041] = &S00041;
  core[000042] = 07240; code[000042] = &I00042;
  core[000043] = 00104; code[000043] = &I00043;
  core[000044] = 04020; code[000044] = &I00044;
  core[000045] = 07240; code[000045] = &I00045;
  core[000046] = 00103; code[000046] = &I00046;
  core[000047] = 04020; code[000047] = &I00047;
  core[000050] = 05441; code[000050] = &I00050;
  core[000051] = 00000; code[000051] = &D00051;
  core[000052] = 00000; code[000052] = &D00052;
  core[000053] = 00000; code[000053] = &D00053;
  core[000054] = 00000; code[000054] = &D00054;
  core[000055] = 00000; code[000055] = &D00055;
  core[000056] = 00000; code[000056] = &D00056;
  core[000057] = 00000; code[000057] = &D00057;
  core[000060] = 04000; code[000060] = &D00060;
  core[000061] = 02000; code[000061] = &D00061;
  core[000062] = 01000; code[000062] = &D00062;
  core[000063] = 00400; code[000063] = &D00063;
  core[000064] = 00200; code[000064] = &P00064;
  core[000065] = 00100; code[000065] = &P00065;
  core[000066] = 00040; code[000066] = &I00066;
  core[000067] = 00020; code[000067] = &I00067;
  core[000070] = 00010; code[000070] = &I00070;
  core[000071] = 00004; code[000071] = &I00071;
  core[000072] = 00002; code[000072] = &D00072;
  core[000073] = 00001; code[000073] = &I00073;
  core[000074] = 00057; code[000074] = &D00074;
  core[000075] = 00322; code[000075] = &D00075;
  core[000076] = 00301; code[000076] = &D00076;
  core[000077] = 00314; code[000077] = &D00077;
  core[000100] = 00324; code[000100] = &D00100;
  core[000101] = 00320; code[000101] = &D00101;
  core[000102] = 00240; code[000102] = &D00102;
  core[000103] = 00212; code[000103] = &D00103;
  core[000104] = 00215; code[000104] = &D00104;
  core[000105] = 00060; code[000105] = &D00105;
  core[000106] = 00061; code[000106] = &D00106;
  core[000107] = 00317; code[000107] = &P00107;
  core[000110] = 00313; code[000110] = &D00110;
  core[000111] = 07764; code[000111] = &D00111;
  core[000112] = 00000; code[000112] = &D00112;
  core[000113] = 00262; code[000113] = &D00113;
  core[000114] = 00302; code[000114] = &D00114;
  core[000115] = 00000; code[000115] = &D00115;
  core[000116] = 00000; code[000116] = &D00116;
  core[000117] = 00000; code[000117] = &D00117;
  core[000120] = 00000; code[000120] = &D00120;
  core[000121] = 00000; code[000121] = &P00121;
  core[000122] = 00000; code[000122] = &D00122;
  core[000123] = 00000; code[000123] = &D00123;
  core[000124] = 00000; code[000124] = &D00124;
  core[000125] = 00000; code[000125] = &P00125;
  core[000126] = 07776; code[000126] = &D00126;
  core[000127] = 00000; code[000127] = &D00127;
  core[000130] = 00307; code[000130] = &D00130;
  core[000131] = 00304; code[000131] = &D00131;
  core[000132] = 00330; code[000132] = &D00132;
  core[000133] = 00331; code[000133] = &D00133;
  core[000134] = 00000; code[000134] = &D00134;
  core[000135] = 00000; code[000135] = &D00135;
  core[000136] = 00000; code[000136] = &D00136;
  core[000137] = 07763; code[000137] = &D00137;
  core[000140] = 00000; code[000140] = &D00140;
  core[000141] = 07377; code[000141] = &I00141;
  core[000142] = 00000; code[000142] = &S00142;
  core[000143] = 07240; code[000143] = &I00143;
  core[000144] = 00140; code[000144] = &I00144;
  core[000145] = 07440; code[000145] = &I00145;
  core[000146] = 05150; code[000146] = &I00146;
  core[000147] = 05152; code[000147] = &I00147;
  core[000150] = 07360; code[000150] = &L00150;
  core[000151] = 05542; code[000151] = &I00151;
  core[000152] = 07340; code[000152] = &L00152;
  core[000153] = 05542; code[000153] = &I00153;
  core[000200] = 07240; code[000200] = &L00200;
  core[000201] = 03124; code[000201] = &I00201;
  core[000202] = 07240; code[000202] = &I00202;
  core[000203] = 03135; code[000203] = &I00203;
  core[000204] = 07240; code[000204] = &I00204;
  core[000205] = 03136; code[000205] = &I00205;
  core[000206] = 07240; code[000206] = &I00206;
  core[000207] = 03121; code[000207] = &I00207;
  core[000210] = 03134; code[000210] = &I00210;
  core[000211] = 03115; code[000211] = &I00211;
  core[000212] = 05223; code[000212] = &I00212;
  core[000213] = 03120; code[000213] = &I00213;
  core[000214] = 07340; code[000214] = &L00214;
  core[000215] = 00135; code[000215] = &I00215;
  core[000216] = 01136; code[000216] = &I00216;
  core[000217] = 03122; code[000217] = &I00217;
  core[000220] = 07004; code[000220] = &I00220;
  core[000221] = 03134; code[000221] = &I00221;
  core[000222] = 05737; code[000222] = &I00222;
  core[000223] = 05624; code[000223] = &L00223;
  core[000224] = 04020; code[000224] = &P00224;
  core[000225] = 07240; code[000225] = &L00225;
  core[000226] = 00135; code[000226] = &I00226;
  core[000227] = 03115; code[000227] = &I00227;
  core[000230] = 07240; code[000230] = &I00230;
  core[000231] = 00136; code[000231] = &I00231;
  core[000232] = 03116; code[000232] = &I00232;
  core[000233] = 04235; code[000233] = &I00233;
  core[000234] = 05214; code[000234] = &I00234;
  core[000235] = 00000; code[000235] = &S00235;
  core[000236] = 07300; code[000236] = &I00236;
  core[000237] = 03121; code[000237] = &I00237;
  core[000240] = 03120; code[000240] = &I00240;
  core[000241] = 07040; code[000241] = &I00241;
  core[000242] = 00111; code[000242] = &I00242;
  core[000243] = 03123; code[000243] = &I00243;
  core[000244] = 07040; code[000244] = &L00244;
  core[000245] = 00115; code[000245] = &I00245;
  core[000246] = 07010; code[000246] = &I00246;
  core[000247] = 03115; code[000247] = &I00247;
  core[000250] = 07004; code[000250] = &I00250;
  core[000251] = 03117; code[000251] = &I00251;
  core[000252] = 07040; code[000252] = &I00252;
  core[000253] = 00116; code[000253] = &I00253;
  core[000254] = 07010; code[000254] = &I00254;
  core[000255] = 03116; code[000255] = &I00255;
  core[000256] = 07040; code[000256] = &I00256;
  core[000257] = 00117; code[000257] = &I00257;
  core[000260] = 07420; code[000260] = &I00260;
  core[000261] = 05302; code[000261] = &I00261;
  core[000262] = 07450; code[000262] = &I00262;
  core[000263] = 05305; code[000263] = &I00263;
  core[000264] = 07300; code[000264] = &I00264;
  core[000265] = 07040; code[000265] = &L00265;
  core[000266] = 00120; code[000266] = &I00266;
  core[000267] = 07010; code[000267] = &I00267;
  core[000270] = 07040; code[000270] = &I00270;
  core[000271] = 00117; code[000271] = &I00271;
  core[000272] = 03120; code[000272] = &L00272;
  core[000273] = 07040; code[000273] = &I00273;
  core[000274] = 00121; code[000274] = &I00274;
  core[000275] = 07010; code[000275] = &I00275;
  core[000276] = 03121; code[000276] = &I00276;
  core[000277] = 02123; code[000277] = &I00277;
  core[000300] = 05244; code[000300] = &I00300;
  core[000301] = 05635; code[000301] = &I00301;
  core[000302] = 07450; code[000302] = &L00302;
  core[000303] = 05265; code[000303] = &I00303;
  core[000304] = 07220; code[000304] = &I00304;
  core[000305] = 07040; code[000305] = &L00305;
  core[000306] = 00120; code[000306] = &I00306;
  core[000307] = 07440; code[000307] = &I00307;
  core[000310] = 07100; code[000310] = &I00310;
  core[000311] = 05272; code[000311] = &I00311;
  core[000312] = 04041; code[000312] = &L00312;
  core[000313] = 07240; code[000313] = &I00313;
  core[000314] = 00076; code[000314] = &I00314;
  core[000315] = 04020; code[000315] = &I00315;
  core[000316] = 07240; code[000316] = &I00316;
  core[000317] = 00131; code[000317] = &D00317;
  core[000320] = 04020; code[000320] = &I00320;
  core[000321] = 07240; code[000321] = &I00321;
  core[000322] = 00131; code[000322] = &I00322;
  core[000323] = 04020; code[000323] = &I00323;
  core[000324] = 07240; code[000324] = &I00324;
  core[000325] = 00102; code[000325] = &I00325;
  core[000326] = 04020; code[000326] = &I00326;
  core[000327] = 07240; code[000327] = &I00327;
  core[000330] = 00107; code[000330] = &I00330;
  core[000331] = 04020; code[000331] = &I00331;
  core[000332] = 07240; code[000332] = &I00332;
  core[000333] = 00110; code[000333] = &I00333;
  core[000334] = 04020; code[000334] = &I00334;
  core[000335] = 05736; code[000335] = &I00335;
  core[000336] = 02000; code[000336] = &P00336;
  core[000337] = 04051; code[000337] = &P00337;
  core[000400] = 07604; code[000400] = &P00400;
  core[000401] = 07106; code[000401] = &I00401;
  core[000402] = 07510; code[000402] = &I00402;
  core[000403] = 04216; code[000403] = &I00403;
  core[000404] = 07604; code[000404] = &I00404;
  core[000405] = 07510; code[000405] = &I00405;
  core[000406] = 07402; code[000406] = &I00406;
  core[000407] = 07604; code[000407] = &L00407;
  core[000410] = 07104; code[000410] = &I00410;
  core[000411] = 07510; code[000411] = &I00411;
  core[000412] = 05614; code[000412] = &I00412;
  core[000413] = 05615; code[000413] = &I00413;
  core[000414] = 00225; code[000414] = &P00414;
  core[000415] = 00223; code[000415] = &P00415;
  core[000416] = 00000; code[000416] = &S00416;
  core[000417] = 07240; code[000417] = &I00417;
  core[000420] = 00124; code[000420] = &I00420;
  core[000421] = 07440; code[000421] = &I00421;
  core[000422] = 04321; code[000422] = &I00422;
  core[000423] = 07000; code[000423] = &D00423;
  core[000424] = 04041; code[000424] = &I00424;
  core[000425] = 04020; code[000425] = &D00425;
  core[000426] = 07240; code[000426] = &P00426;
  core[000427] = 00120; code[000427] = &I00427;
  core[000430] = 04635; code[000430] = &I00430;
  core[000431] = 07240; code[000431] = &I00431;
  core[000432] = 00102; code[000432] = &I00432;
  core[000433] = 04020; code[000433] = &I00433;
  core[000434] = 05236; code[000434] = &I00434;
  core[000435] = 02637; code[000435] = &P00435;
  core[000436] = 07240; code[000436] = &L00436;
  core[000437] = 00121; code[000437] = &P00437;
  core[000440] = 03125; code[000440] = &I00440;
  core[000441] = 04266; code[000441] = &I00441;
  core[000442] = 07240; code[000442] = &I00442;
  core[000443] = 00134; code[000443] = &I00443;
  core[000444] = 04635; code[000444] = &I00444;
  core[000445] = 07240; code[000445] = &I00445;
  core[000446] = 00102; code[000446] = &I00446;
  core[000447] = 04020; code[000447] = &I00447;
  core[000450] = 05251; code[000450] = &I00450;
  core[000451] = 07240; code[000451] = &L00451;
  core[000452] = 00122; code[000452] = &I00452;
  core[000453] = 03125; code[000453] = &I00453;
  core[000454] = 04266; code[000454] = &I00454;
  core[000455] = 07240; code[000455] = &I00455;
  core[000456] = 00135; code[000456] = &I00456;
  core[000457] = 03125; code[000457] = &I00457;
  core[000460] = 04266; code[000460] = &I00460;
  core[000461] = 07240; code[000461] = &I00461;
  core[000462] = 00136; code[000462] = &I00462;
  core[000463] = 03125; code[000463] = &I00463;
  core[000464] = 04266; code[000464] = &I00464;
  core[000465] = 05616; code[000465] = &I00465;
  core[000466] = 00000; code[000466] = &S00466;
  core[000467] = 07240; code[000467] = &I00467;
  core[000470] = 00137; code[000470] = &I00470;
  core[000471] = 03112; code[000471] = &I00471;
  core[000472] = 02112; code[000472] = &L00472;
  core[000473] = 07410; code[000473] = &I00473;
  core[000474] = 05312; code[000474] = &I00474;
  core[000475] = 07240; code[000475] = &I00475;
  core[000476] = 00125; code[000476] = &I00476;
  core[000477] = 07100; code[000477] = &I00477;
  core[000500] = 07004; code[000500] = &I00500;
  core[000501] = 03125; code[000501] = &I00501;
  core[000502] = 07430; code[000502] = &P00502;
  core[000503] = 05306; code[000503] = &I00503;
  core[000504] = 04764; code[000504] = &I00504;
  core[000505] = 05272; code[000505] = &I00505;
  core[000506] = 07240; code[000506] = &L00506;
  core[000507] = 00106; code[000507] = &I00507;
  core[000510] = 04020; code[000510] = &I00510;
  core[000511] = 05272; code[000511] = &I00511;
  core[000512] = 07240; code[000512] = &L00512;
  core[000513] = 00102; code[000513] = &I00513;
  core[000514] = 04020; code[000514] = &I00514;
  core[000515] = 07240; code[000515] = &I00515;
  core[000516] = 00102; code[000516] = &I00516;
  core[000517] = 04020; code[000517] = &I00517;
  core[000520] = 05666; code[000520] = &I00520;
  core[000521] = 00000; code[000521] = &S00521;
  core[000522] = 07200; code[000522] = &I00522;
  core[000523] = 03124; code[000523] = &I00523;
  core[000524] = 07240; code[000524] = &I00524;
  core[000525] = 00126; code[000525] = &I00525;
  core[000526] = 03127; code[000526] = &I00526;
  core[000527] = 04041; code[000527] = &I00527;
  core[000530] = 07240; code[000530] = &L00530;
  core[000531] = 00102; code[000531] = &I00531;
  core[000532] = 04020; code[000532] = &I00532;
  core[000533] = 02127; code[000533] = &I00533;
  core[000534] = 05330; code[000534] = &I00534;
  core[000535] = 07240; code[000535] = &I00535;
  core[000536] = 00130; code[000536] = &I00536;
  core[000537] = 04020; code[000537] = &I00537;
  core[000540] = 07240; code[000540] = &I00540;
  core[000541] = 00107; code[000541] = &I00541;
  core[000542] = 04020; code[000542] = &I00542;
  core[000543] = 07240; code[000543] = &I00543;
  core[000544] = 00107; code[000544] = &I00544;
  core[000545] = 04020; code[000545] = &I00545;
  core[000546] = 07240; code[000546] = &I00546;
  core[000547] = 00131; code[000547] = &I00547;
  core[000550] = 04020; code[000550] = &I00550;
  core[000551] = 04762; code[000551] = &I00551;
  core[000552] = 07240; code[000552] = &I00552;
  core[000553] = 00114; code[000553] = &I00553;
  core[000554] = 04020; code[000554] = &I00554;
  core[000555] = 07240; code[000555] = &I00555;
  core[000556] = 00076; code[000556] = &I00556;
  core[000557] = 04020; code[000557] = &I00557;
  core[000560] = 05761; code[000560] = &I00560;
  core[000561] = 00600; code[000561] = &P00561;
  core[000562] = 00626; code[000562] = &P00562;
  core[000563] = 05721; code[000563] = &L00563;
  core[000564] = 02702; code[000564] = &P00564;
  core[000600] = 07240; code[000600] = &L00600;
  core[000601] = 00131; code[000601] = &I00601;
  core[000602] = 04020; code[000602] = &I00602;
  core[000603] = 04226; code[000603] = &I00603;
  core[000604] = 07240; code[000604] = &I00604;
  core[000605] = 00132; code[000605] = &I00605;
  core[000606] = 04020; code[000606] = &I00606;
  core[000607] = 07240; code[000607] = &I00607;
  core[000610] = 00102; code[000610] = &I00610;
  core[000611] = 04020; code[000611] = &I00611;
  core[000612] = 04240; code[000612] = &I00612;
  core[000613] = 04226; code[000613] = &I00613;
  core[000614] = 07240; code[000614] = &I00614;
  core[000615] = 00133; code[000615] = &I00615;
  core[000616] = 04020; code[000616] = &I00616;
  core[000617] = 07240; code[000617] = &I00617;
  core[000620] = 00102; code[000620] = &I00620;
  core[000621] = 04020; code[000621] = &I00621;
  core[000622] = 04240; code[000622] = &I00622;
  core[000623] = 04041; code[000623] = &I00623;
  core[000624] = 05625; code[000624] = &I00624;
  core[000625] = 00563; code[000625] = &P00625;
  core[000626] = 00000; code[000626] = &S00626;
  core[000627] = 07240; code[000627] = &I00627;
  core[000630] = 00111; code[000630] = &I00630;
  core[000631] = 03127; code[000631] = &I00631;
  core[000632] = 07240; code[000632] = &L00632;
  core[000633] = 00102; code[000633] = &I00633;
  core[000634] = 04020; code[000634] = &I00634;
  core[000635] = 02127; code[000635] = &I00635;
  core[000636] = 05232; code[000636] = &I00636;
  core[000637] = 05626; code[000637] = &I00637;
  core[000640] = 00000; code[000640] = &S00640;
  core[000641] = 07240; code[000641] = &I00641;
  core[000642] = 00076; code[000642] = &I00642;
  core[000643] = 04020; code[000643] = &I00643;
  core[000644] = 07240; code[000644] = &I00644;
  core[000645] = 00075; code[000645] = &I00645;
  core[000646] = 04020; code[000646] = &I00646;
  core[000647] = 07240; code[000647] = &I00647;
  core[000650] = 00130; code[000650] = &I00650;
  core[000651] = 04020; code[000651] = &I00651;
  core[000652] = 05640; code[000652] = &I00652;
  core[002000] = 04316; code[002000] = &L02000;
  core[002001] = 04142; code[002001] = &I02001;
  core[002002] = 00051; code[002002] = &I02002;
  core[002003] = 07001; code[002003] = &I02003;
  core[002004] = 03051; code[002004] = &I02004;
  core[002005] = 07420; code[002005] = &I02005;
  core[002006] = 05215; code[002006] = &I02006;
  core[002007] = 01060; code[002007] = &I02007;
  core[002010] = 03140; code[002010] = &I02010;
  core[002011] = 04352; code[002011] = &L02011;
  core[002012] = 07440; code[002012] = &I02012;
  core[002013] = 05220; code[002013] = &I02013;
  core[002014] = 05274; code[002014] = &I02014;
  core[002015] = 07200; code[002015] = &L02015;
  core[002016] = 03140; code[002016] = &I02016;
  core[002017] = 05211; code[002017] = &I02017;
  core[002020] = 07240; code[002020] = &L02020;
  core[002021] = 03056; code[002021] = &I02021;
  core[002022] = 07340; code[002022] = &I02022;
  core[002023] = 00140; code[002023] = &I02023;
  core[002024] = 07440; code[002024] = &I02024;
  core[002025] = 05272; code[002025] = &I02025;
  core[002026] = 07140; code[002026] = &I02026;
  core[002027] = 00051; code[002027] = &L02027;
  core[002030] = 07004; code[002030] = &I02030;
  core[002031] = 03052; code[002031] = &I02031;
  core[002032] = 07430; code[002032] = &I02032;
  core[002033] = 01060; code[002033] = &I02033;
  core[002034] = 03053; code[002034] = &I02034;
  core[002035] = 07240; code[002035] = &I02035;
  core[002036] = 00052; code[002036] = &I02036;
  core[002037] = 07010; code[002037] = &I02037;
  core[002040] = 03054; code[002040] = &I02040;
  core[002041] = 07430; code[002041] = &I02041;
  core[002042] = 01060; code[002042] = &I02042;
  core[002043] = 03055; code[002043] = &I02043;
  core[002044] = 07340; code[002044] = &I02044;
  core[002045] = 00054; code[002045] = &I02045;
  core[002046] = 07040; code[002046] = &I02046;
  core[002047] = 01051; code[002047] = &I02047;
  core[002050] = 07040; code[002050] = &I02050;
  core[002051] = 07450; code[002051] = &I02051;
  core[002052] = 07430; code[002052] = &I02052;
  core[002053] = 05715; code[002053] = &I02053;
  core[002054] = 01060; code[002054] = &I02054;
  core[002055] = 00051; code[002055] = &I02055;
  core[002056] = 07040; code[002056] = &I02056;
  core[002057] = 01053; code[002057] = &I02057;
  core[002060] = 07040; code[002060] = &I02060;
  core[002061] = 07440; code[002061] = &I02061;
  core[002062] = 05715; code[002062] = &I02062;
  core[002063] = 01055; code[002063] = &I02063;
  core[002064] = 07040; code[002064] = &I02064;
  core[002065] = 01140; code[002065] = &I02065;
  core[002066] = 07040; code[002066] = &I02066;
  core[002067] = 07440; code[002067] = &I02067;
  core[002070] = 05715; code[002070] = &I02070;
  core[002071] = 05751; code[002071] = &I02071;
  core[002072] = 07360; code[002072] = &L02072;
  core[002073] = 05227; code[002073] = &I02073;
  core[002074] = 04316; code[002074] = &L02074;
  core[002075] = 04142; code[002075] = &I02075;
  core[002076] = 00051; code[002076] = &I02076;
  core[002077] = 07001; code[002077] = &I02077;
  core[002100] = 03051; code[002100] = &I02100;
  core[002101] = 07420; code[002101] = &I02101;
  core[002102] = 05311; code[002102] = &I02102;
  core[002103] = 01060; code[002103] = &I02103;
  core[002104] = 03140; code[002104] = &I02104;
  core[002105] = 04363; code[002105] = &L02105;
  core[002106] = 07440; code[002106] = &I02106;
  core[002107] = 05714; code[002107] = &I02107;
  core[002110] = 05332; code[002110] = &I02110;
  core[002111] = 07200; code[002111] = &L02111;
  core[002112] = 03140; code[002112] = &I02112;
  core[002113] = 05305; code[002113] = &I02113;
  core[002114] = 02200; code[002114] = &P02114;
  core[002115] = 02400; code[002115] = &P02115;
  core[002116] = 00000; code[002116] = &S02116;
  core[002117] = 07300; code[002117] = &I02117;
  core[002120] = 03051; code[002120] = &I02120;
  core[002121] = 03052; code[002121] = &I02121;
  core[002122] = 03054; code[002122] = &I02122;
  core[002123] = 03053; code[002123] = &I02123;
  core[002124] = 03055; code[002124] = &I02124;
  core[002125] = 03140; code[002125] = &I02125;
  core[002126] = 07000; code[002126] = &I02126;
  core[002127] = 07000; code[002127] = &I02127;
  core[002130] = 07000; code[002130] = &I02130;
  core[002131] = 05716; code[002131] = &I02131;
  core[002132] = 07200; code[002132] = &L02132;
  core[002133] = 04041; code[002133] = &I02133;
  core[002134] = 01075; code[002134] = &I02134;
  core[002135] = 04020; code[002135] = &I02135;
  core[002136] = 01107; code[002136] = &I02136;
  core[002137] = 04020; code[002137] = &I02137;
  core[002140] = 01100; code[002140] = &I02140;
  core[002141] = 04020; code[002141] = &I02141;
  core[002142] = 04041; code[002142] = &I02142;
  core[002143] = 01113; code[002143] = &I02143;
  core[002144] = 04020; code[002144] = &I02144;
  core[002145] = 01114; code[002145] = &I02145;
  core[002146] = 04020; code[002146] = &I02146;
  core[002147] = 05750; code[002147] = &I02147;
  core[002150] = 00200; code[002150] = &P02150;
  core[002151] = 02521; code[002151] = &P02151;
  core[002152] = 00000; code[002152] = &S02152;
  core[002153] = 01140; code[002153] = &I02153;
  core[002154] = 07440; code[002154] = &I02154;
  core[002155] = 07410; code[002155] = &I02155;
  core[002156] = 05220; code[002156] = &I02156;
  core[002157] = 07240; code[002157] = &I02157;
  core[002160] = 00051; code[002160] = &I02160;
  core[002161] = 07040; code[002161] = &I02161;
  core[002162] = 05752; code[002162] = &I02162;
  core[002163] = 00000; code[002163] = &S02163;
  core[002164] = 01140; code[002164] = &I02164;
  core[002165] = 07440; code[002165] = &I02165;
  core[002166] = 07410; code[002166] = &I02166;
  core[002167] = 05714; code[002167] = &I02167;
  core[002170] = 07240; code[002170] = &I02170;
  core[002171] = 00051; code[002171] = &I02171;
  core[002172] = 07040; code[002172] = &I02172;
  core[002173] = 05763; code[002173] = &I02173;
  core[002200] = 07300; code[002200] = &L02200;
  core[002201] = 03056; code[002201] = &I02201;
  core[002202] = 07340; code[002202] = &I02202;
  core[002203] = 00140; code[002203] = &I02203;
  core[002204] = 07440; code[002204] = &I02204;
  core[002205] = 05250; code[002205] = &I02205;
  core[002206] = 07140; code[002206] = &I02206;
  core[002207] = 00051; code[002207] = &L02207;
  core[002210] = 07012; code[002210] = &I02210;
  core[002211] = 03054; code[002211] = &I02211;
  core[002212] = 07430; code[002212] = &I02212;
  core[002213] = 01072; code[002213] = &I02213;
  core[002214] = 03055; code[002214] = &I02214;
  core[002215] = 01054; code[002215] = &I02215;
  core[002216] = 07006; code[002216] = &I02216;
  core[002217] = 03052; code[002217] = &I02217;
  core[002220] = 07430; code[002220] = &I02220;
  core[002221] = 01060; code[002221] = &I02221;
  core[002222] = 03053; code[002222] = &I02222;
  core[002223] = 07100; code[002223] = &I02223;
  core[002224] = 01052; code[002224] = &I02224;
  core[002225] = 07040; code[002225] = &I02225;
  core[002226] = 01051; code[002226] = &I02226;
  core[002227] = 07040; code[002227] = &I02227;
  core[002230] = 07440; code[002230] = &I02230;
  core[002231] = 05652; code[002231] = &I02231;
  core[002232] = 01072; code[002232] = &I02232;
  core[002233] = 00051; code[002233] = &I02233;
  core[002234] = 07040; code[002234] = &I02234;
  core[002235] = 01055; code[002235] = &I02235;
  core[002236] = 07040; code[002236] = &I02236;
  core[002237] = 07440; code[002237] = &I02237;
  core[002240] = 05652; code[002240] = &I02240;
  core[002241] = 01053; code[002241] = &I02241;
  core[002242] = 07040; code[002242] = &I02242;
  core[002243] = 01140; code[002243] = &I02243;
  core[002244] = 07040; code[002244] = &I02244;
  core[002245] = 07440; code[002245] = &I02245;
  core[002246] = 05652; code[002246] = &I02246;
  core[002247] = 05653; code[002247] = &I02247;
  core[002250] = 07360; code[002250] = &L02250;
  core[002251] = 05207; code[002251] = &I02251;
  core[002252] = 02406; code[002252] = &P02252;
  core[002253] = 02525; code[002253] = &P02253;
  core[002400] = 07200; code[002400] = &P02400;
  core[002401] = 01244; code[002401] = &I02401;
  core[002402] = 03215; code[002402] = &I02402;
  core[002403] = 01245; code[002403] = &I02403;
  core[002404] = 03214; code[002404] = &I02404;
  core[002405] = 05216; code[002405] = &I02405;
  core[002406] = 07200; code[002406] = &L02406;
  core[002407] = 01250; code[002407] = &I02407;
  core[002410] = 03215; code[002410] = &I02410;
  core[002411] = 01251; code[002411] = &I02411;
  core[002412] = 03214; code[002412] = &I02412;
  core[002413] = 05216; code[002413] = &I02413;
  core[002414] = 00000; code[002414] = &P02414;
  core[002415] = 00000; code[002415] = &P02415;
  core[002416] = 07604; code[002416] = &P02416;
  core[002417] = 00062; code[002417] = &I02417;
  core[002420] = 07040; code[002420] = &I02420;
  core[002421] = 01062; code[002421] = &I02421;
  core[002422] = 07040; code[002422] = &I02422;
  core[002423] = 07450; code[002423] = &I02423;
  core[002424] = 04255; code[002424] = &I02424;
  core[002425] = 07604; code[002425] = &I02425;
  core[002426] = 00060; code[002426] = &I02426;
  core[002427] = 07040; code[002427] = &I02427;
  core[002430] = 01060; code[002430] = &I02430;
  core[002431] = 07040; code[002431] = &I02431;
  core[002432] = 07450; code[002432] = &I02432;
  core[002433] = 07402; code[002433] = &I02433;
  core[002434] = 07604; code[002434] = &L02434;
  core[002435] = 00061; code[002435] = &I02435;
  core[002436] = 07040; code[002436] = &I02436;
  core[002437] = 01061; code[002437] = &I02437;
  core[002440] = 07040; code[002440] = &I02440;
  core[002441] = 07450; code[002441] = &I02441;
  core[002442] = 05615; code[002442] = &I02442;
  core[002443] = 05614; code[002443] = &I02443;
  core[002444] = 02020; code[002444] = &D02444;
  core[002445] = 02001; code[002445] = &D02445;
  core[002446] = 02000; code[002446] = &I02446;
  core[002447] = 02074; code[002447] = &I02447;
  core[002450] = 02200; code[002450] = &P02450;
  core[002451] = 02075; code[002451] = &D02451;
  core[002452] = 02464; code[002452] = &I02452;
  core[002453] = 02465; code[002453] = &I02453;
  core[002454] = 02650; code[002454] = &D02454;
  core[002455] = 00000; code[002455] = &S02455;
  core[002456] = 04026; code[002456] = &I02456;
  core[002457] = 04714; code[002457] = &I02457;
  core[002460] = 07200; code[002460] = &I02460;
  core[002461] = 01056; code[002461] = &I02461;
  core[002462] = 07440; code[002462] = &I02462;
  core[002463] = 05266; code[002463] = &I02463;
  core[002464] = 04715; code[002464] = &I02464;
  core[002465] = 05655; code[002465] = &I02465;
  core[002466] = 07200; code[002466] = &L02466;
  core[002467] = 01254; code[002467] = &I02467;
  core[002470] = 03714; code[002470] = &I02470;
  core[002471] = 04041; code[002471] = &I02471;
  core[002472] = 07200; code[002472] = &I02472;
  core[002473] = 01075; code[002473] = &I02473;
  core[002474] = 04020; code[002474] = &I02474;
  core[002475] = 01076; code[002475] = &I02475;
  core[002476] = 04020; code[002476] = &P02476;
  core[002477] = 01077; code[002477] = &I02477;
  core[002500] = 04020; code[002500] = &I02500;
  core[002501] = 01102; code[002501] = &I02501;
  core[002502] = 04020; code[002502] = &P02502;
  core[002503] = 01053; code[002503] = &I02503;
  core[002504] = 07440; code[002504] = &I02504;
  core[002505] = 05716; code[002505] = &I02505;
  core[002506] = 04717; code[002506] = &I02506;
  core[002507] = 01102; code[002507] = &L02507;
  core[002510] = 04020; code[002510] = &I02510;
  core[002511] = 01052; code[002511] = &I02511;
  core[002512] = 03057; code[002512] = &I02512;
  core[002513] = 05720; code[002513] = &I02513;
  core[002514] = 02600; code[002514] = &P02514;
  core[002515] = 02732; code[002515] = &P02515;
  core[002516] = 02676; code[002516] = &P02516;
  core[002517] = 02702; code[002517] = &P02517;
  core[002520] = 02616; code[002520] = &P02520;
  core[002521] = 07200; code[002521] = &L02521;
  core[002522] = 01245; code[002522] = &I02522;
  core[002523] = 03214; code[002523] = &I02523;
  core[002524] = 05234; code[002524] = &I02524;
  core[002525] = 07200; code[002525] = &L02525;
  core[002526] = 01251; code[002526] = &I02526;
  core[002527] = 03214; code[002527] = &I02527;
  core[002530] = 05234; code[002530] = &I02530;
  core[002600] = 00000; code[002600] = &S02600;
  core[002601] = 01101; code[002601] = &I02601;
  core[002602] = 04020; code[002602] = &I02602;
  core[002603] = 01076; code[002603] = &I02603;
  core[002604] = 04020; code[002604] = &I02604;
  core[002605] = 01100; code[002605] = &I02605;
  core[002606] = 04020; code[002606] = &I02606;
  core[002607] = 01102; code[002607] = &I02607;
  core[002610] = 04020; code[002610] = &I02610;
  core[002611] = 04361; code[002611] = &I02611;
  core[002612] = 01102; code[002612] = &I02612;
  core[002613] = 04020; code[002613] = &I02613;
  core[002614] = 01051; code[002614] = &I02614;
  core[002615] = 03057; code[002615] = &I02615;
  core[002616] = 04231; code[002616] = &L02616;
  core[002617] = 00137; code[002617] = &I02617;
  core[002620] = 03112; code[002620] = &I02620;
  core[002621] = 02112; code[002621] = &L02621;
  core[002622] = 07410; code[002622] = &I02622;
  core[002623] = 05600; code[002623] = &I02623;
  core[002624] = 07200; code[002624] = &I02624;
  core[002625] = 01057; code[002625] = &I02625;
  core[002626] = 00410; code[002626] = &I02626;
  core[002627] = 04237; code[002627] = &I02627;
  core[002630] = 05221; code[002630] = &I02630;
  core[002631] = 00000; code[002631] = &S02631;
  core[002632] = 07200; code[002632] = &I02632;
  core[002633] = 01074; code[002633] = &I02633;
  core[002634] = 03010; code[002634] = &I02634;
  core[002635] = 07240; code[002635] = &I02635;
  core[002636] = 05631; code[002636] = &I02636;
  core[002637] = 00000; code[002637] = &S02637;
  core[002640] = 07440; code[002640] = &I02640;
  core[002641] = 05244; code[002641] = &I02641;
  core[002642] = 04302; code[002642] = &I02642;
  core[002643] = 05637; code[002643] = &I02643;
  core[002644] = 07240; code[002644] = &L02644;
  core[002645] = 00106; code[002645] = &I02645;
  core[002646] = 04020; code[002646] = &I02646;
  core[002647] = 05637; code[002647] = &I02647;
  core[002650] = 07200; code[002650] = &I02650;
  core[002651] = 01273; code[002651] = &I02651;
  core[002652] = 03200; code[002652] = &I02652;
  core[002653] = 04041; code[002653] = &I02653;
  core[002654] = 07200; code[002654] = &I02654;
  core[002655] = 01075; code[002655] = &I02655;
  core[002656] = 04020; code[002656] = &I02656;
  core[002657] = 01076; code[002657] = &I02657;
  core[002660] = 04020; code[002660] = &I02660;
  core[002661] = 04323; code[002661] = &I02661;
  core[002662] = 01055; code[002662] = &I02662;
  core[002663] = 07440; code[002663] = &I02663;
  core[002664] = 05307; code[002664] = &I02664;
  core[002665] = 04302; code[002665] = &I02665;
  core[002666] = 01102; code[002666] = &L02666;
  core[002667] = 04020; code[002667] = &I02667;
  core[002670] = 01054; code[002670] = &I02670;
  core[002671] = 03057; code[002671] = &I02671;
  core[002672] = 05216; code[002672] = &I02672;
  core[002673] = 02465; code[002673] = &D02673;
  core[002674] = 02507; code[002674] = &P02674;
  core[002675] = 02744; code[002675] = &D02675;
  core[002676] = 07240; code[002676] = &L02676;
  core[002677] = 00106; code[002677] = &I02677;
  core[002700] = 04020; code[002700] = &I02700;
  core[002701] = 05674; code[002701] = &I02701;
  core[002702] = 00000; code[002702] = &S02702;
  core[002703] = 07240; code[002703] = &I02703;
  core[002704] = 00105; code[002704] = &I02704;
  core[002705] = 04020; code[002705] = &I02705;
  core[002706] = 05702; code[002706] = &I02706;
  core[002707] = 07200; code[002707] = &L02707;
  core[002710] = 01106; code[002710] = &I02710;
  core[002711] = 04020; code[002711] = &I02711;
  core[002712] = 05266; code[002712] = &I02712;
  core[002713] = 00000; code[002713] = &S02713;
  core[002714] = 07200; code[002714] = &I02714;
  core[002715] = 04041; code[002715] = &I02715;
  core[002716] = 01075; code[002716] = &I02716;
  core[002717] = 04020; code[002717] = &I02717;
  core[002720] = 01100; code[002720] = &I02720;
  core[002721] = 04020; code[002721] = &I02721;
  core[002722] = 05713; code[002722] = &I02722;
  core[002723] = 00000; code[002723] = &S02723;
  core[002724] = 07200; code[002724] = &I02724;
  core[002725] = 01075; code[002725] = &I02725;
  core[002726] = 04020; code[002726] = &I02726;
  core[002727] = 01102; code[002727] = &I02727;
  core[002730] = 04020; code[002730] = &I02730;
  core[002731] = 05723; code[002731] = &I02731;
  core[002732] = 07200; code[002732] = &I02732;
  core[002733] = 01275; code[002733] = &I02733;
  core[002734] = 03200; code[002734] = &I02734;
  core[002735] = 04313; code[002735] = &I02735;
  core[002736] = 04323; code[002736] = &I02736;
  core[002737] = 01055; code[002737] = &I02737;
  core[002740] = 07440; code[002740] = &I02740;
  core[002741] = 05307; code[002741] = &I02741;
  core[002742] = 04302; code[002742] = &I02742;
  core[002743] = 05266; code[002743] = &I02743;
  core[002744] = 07200; code[002744] = &P02744;
  core[002745] = 01273; code[002745] = &I02745;
  core[002746] = 03200; code[002746] = &I02746;
  core[002747] = 04313; code[002747] = &I02747;
  core[002750] = 01077; code[002750] = &I02750;
  core[002751] = 04020; code[002751] = &I02751;
  core[002752] = 01102; code[002752] = &I02752;
  core[002753] = 04020; code[002753] = &I02753;
  core[002754] = 01053; code[002754] = &I02754;
  core[002755] = 07440; code[002755] = &I02755;
  core[002756] = 05276; code[002756] = &I02756;
  core[002757] = 04302; code[002757] = &I02757;
  core[002760] = 05674; code[002760] = &I02760;
  core[002761] = 00000; code[002761] = &S02761;
  core[002762] = 01140; code[002762] = &I02762;
  core[002763] = 04237; code[002763] = &I02763;
  core[002764] = 05761; code[002764] = &I02764;
  core[004000] = 07200; code[004000] = &L04000;
  core[004001] = 01417; code[004001] = &I04001;
  core[004002] = 03135; code[004002] = &I04002;
  core[004003] = 01417; code[004003] = &I04003;
  core[004004] = 03136; code[004004] = &I04004;
  core[004005] = 02216; code[004005] = &I04005;
  core[004006] = 05647; code[004006] = &I04006;
  core[004007] = 01215; code[004007] = &I04007;
  core[004010] = 03017; code[004010] = &I04010;
  core[004011] = 01214; code[004011] = &I04011;
  core[004012] = 03216; code[004012] = &I04012;
  core[004013] = 05647; code[004013] = &I04013;
  core[004014] = 07634; code[004014] = &D04014;
  core[004015] = 04177; code[004015] = &D04015;
  core[004016] = 00000; code[004016] = &D04016;
  core[004017] = 00000; code[004017] = &D04017;
  core[004020] = 07300; code[004020] = &L04020;
  core[004021] = 02217; code[004021] = &I04021;
  core[004022] = 07000; code[004022] = &I04022;
  core[004023] = 01217; code[004023] = &I04023;
  core[004024] = 07010; code[004024] = &I04024;
  core[004025] = 07630; code[004025] = &D04025;
  core[004026] = 05230; code[004026] = &I04026;
  core[004027] = 05200; code[004027] = &I04027;
  core[004030] = 07604; code[004030] = &L04030;
  core[004031] = 00063; code[004031] = &I04031;
  core[004032] = 07000; code[004032] = &I04032;
  core[004033] = 07440; code[004033] = &I04033;
  core[004034] = 05650; code[004034] = &I04034;
  core[004035] = 07240; code[004035] = &I04035;
  core[004036] = 00121; code[004036] = &I04036;
  core[004037] = 07000; code[004037] = &I04037;
  core[004040] = 03135; code[004040] = &I04040;
  core[004041] = 07040; code[004041] = &I04041;
  core[004042] = 00121; code[004042] = &I04042;
  core[004043] = 07001; code[004043] = &I04043;
  core[004044] = 01410; code[004044] = &I04044;
  core[004045] = 03136; code[004045] = &I04045;
  core[004046] = 05647; code[004046] = &I04046;
  core[004047] = 00225; code[004047] = &P04047;
  core[004050] = 00312; code[004050] = &P04050;
  core[004051] = 07240; code[004051] = &L04051;
  core[004052] = 00121; code[004052] = &I04052;
  core[004053] = 07040; code[004053] = &I04053;
  core[004054] = 00122; code[004054] = &I04054;
  core[004055] = 03275; code[004055] = &I04055;
  core[004056] = 07240; code[004056] = &I04056;
  core[004057] = 00122; code[004057] = &I04057;
  core[004060] = 07040; code[004060] = &I04060;
  core[004061] = 00121; code[004061] = &I04061;
  core[004062] = 03274; code[004062] = &I04062;
  core[004063] = 07240; code[004063] = &I04063;
  core[004064] = 00275; code[004064] = &I04064;
  core[004065] = 07440; code[004065] = &I04065;
  core[004066] = 05676; code[004066] = &I04066;
  core[004067] = 07240; code[004067] = &I04067;
  core[004070] = 00274; code[004070] = &I04070;
  core[004071] = 07440; code[004071] = &I04071;
  core[004072] = 05676; code[004072] = &I04072;
  core[004073] = 05277; code[004073] = &I04073;
  core[004074] = 00000; code[004074] = &D04074;
  core[004075] = 00000; code[004075] = &D04075;
  core[004076] = 00400; code[004076] = &P04076;
  core[004077] = 07240; code[004077] = &L04077;
  core[004100] = 00134; code[004100] = &I04100;
  core[004101] = 07040; code[004101] = &I04101;
  core[004102] = 00120; code[004102] = &I04102;
  core[004103] = 03322; code[004103] = &I04103;
  core[004104] = 07240; code[004104] = &I04104;
  core[004105] = 00120; code[004105] = &I04105;
  core[004106] = 07040; code[004106] = &I04106;
  core[004107] = 00134; code[004107] = &I04107;
  core[004110] = 03323; code[004110] = &I04110;
  core[004111] = 07240; code[004111] = &I04111;
  core[004112] = 00322; code[004112] = &D04112;
  core[004113] = 07440; code[004113] = &I04113;
  core[004114] = 05676; code[004114] = &I04114;
  core[004115] = 07240; code[004115] = &I04115;
  core[004116] = 00323; code[004116] = &I04116;
  core[004117] = 07440; code[004117] = &I04117;
  core[004120] = 05676; code[004120] = &I04120;
  core[004121] = 05724; code[004121] = &I04121;
  core[004122] = 00000; code[004122] = &D04122;
  core[004123] = 00000; code[004123] = &D04123;
  core[004124] = 00407; code[004124] = &P04124;
  core[004200] = 07777; code[004200] = &D04200;
  core[004201] = 07777; code[004201] = &I04201;
  core[004202] = 07776; code[004202] = &I04202;
  core[004203] = 07777; code[004203] = &I04203;
  core[004204] = 07775; code[004204] = &I04204;
  core[004205] = 07777; code[004205] = &I04205;
  core[004206] = 07773; code[004206] = &I04206;
  core[004207] = 07777; code[004207] = &I04207;
  core[004210] = 07767; code[004210] = &I04210;
  core[004211] = 07777; code[004211] = &I04211;
  core[004212] = 07757; code[004212] = &I04212;
  core[004213] = 07777; code[004213] = &I04213;
  core[004214] = 07737; code[004214] = &I04214;
  core[004215] = 07777; code[004215] = &I04215;
  core[004216] = 07677; code[004216] = &I04216;
  core[004217] = 07777; code[004217] = &I04217;
  core[004220] = 07577; code[004220] = &I04220;
  core[004221] = 07777; code[004221] = &I04221;
  core[004222] = 07377; code[004222] = &I04222;
  core[004223] = 07777; code[004223] = &I04223;
  core[004224] = 06777; code[004224] = &I04224;
  core[004225] = 07777; code[004225] = &I04225;
  core[004226] = 05777; code[004226] = &I04226;
  core[004227] = 07777; code[004227] = &I04227;
  core[004230] = 03777; code[004230] = &I04230;
  core[004231] = 07777; code[004231] = &I04231;
  core[004232] = 07777; code[004232] = &I04232;
  core[004233] = 07777; code[004233] = &I04233;
  core[004234] = 07776; code[004234] = &I04234;
  core[004235] = 07777; code[004235] = &I04235;
  core[004236] = 07775; code[004236] = &I04236;
  core[004237] = 07777; code[004237] = &I04237;
  core[004240] = 07773; code[004240] = &I04240;
  core[004241] = 07777; code[004241] = &I04241;
  core[004242] = 07767; code[004242] = &I04242;
  core[004243] = 07777; code[004243] = &I04243;
  core[004244] = 07757; code[004244] = &I04244;
  core[004245] = 07777; code[004245] = &I04245;
  core[004246] = 07737; code[004246] = &I04246;
  core[004247] = 07777; code[004247] = &I04247;
  core[004250] = 07677; code[004250] = &I04250;
  core[004251] = 07777; code[004251] = &I04251;
  core[004252] = 07577; code[004252] = &I04252;
  core[004253] = 07777; code[004253] = &I04253;
  core[004254] = 07377; code[004254] = &I04254;
  core[004255] = 06777; code[004255] = &I04255;
  core[004256] = 07777; code[004256] = &I04256;
  core[004257] = 05777; code[004257] = &I04257;
  core[004260] = 07777; code[004260] = &I04260;
  core[004261] = 03777; code[004261] = &I04261;
  core[004262] = 07777; code[004262] = &I04262;
  core[004263] = 00001; code[004263] = &I04263;
  core[004264] = 07777; code[004264] = &I04264;
  core[004265] = 00002; code[004265] = &I04265;
  core[004266] = 07777; code[004266] = &I04266;
  core[004267] = 00004; code[004267] = &I04267;
  core[004270] = 07777; code[004270] = &I04270;
  core[004271] = 00010; code[004271] = &I04271;
  core[004272] = 07777; code[004272] = &I04272;
  core[004273] = 00020; code[004273] = &I04273;
  core[004274] = 07777; code[004274] = &I04274;
  core[004275] = 00040; code[004275] = &I04275;
  core[004276] = 07777; code[004276] = &I04276;
  core[004277] = 00100; code[004277] = &I04277;
  core[004300] = 07777; code[004300] = &I04300;
  core[004301] = 00200; code[004301] = &I04301;
  core[004302] = 07777; code[004302] = &I04302;
  core[004303] = 00400; code[004303] = &I04303;
  core[004304] = 07777; code[004304] = &I04304;
  core[004305] = 01000; code[004305] = &I04305;
  core[004306] = 07777; code[004306] = &I04306;
  core[004307] = 02000; code[004307] = &I04307;
  core[004310] = 07777; code[004310] = &I04310;
  core[004311] = 04000; code[004311] = &I04311;
  core[004312] = 00001; code[004312] = &I04312;
  core[004313] = 07777; code[004313] = &I04313;
  core[004314] = 00002; code[004314] = &I04314;
  core[004315] = 07777; code[004315] = &I04315;
  core[004316] = 00004; code[004316] = &I04316;
  core[004317] = 07777; code[004317] = &I04317;
  core[004320] = 00010; code[004320] = &I04320;
  core[004321] = 07777; code[004321] = &I04321;
  core[004322] = 00200; code[004322] = &I04322;
  core[004323] = 07777; code[004323] = &I04323;
  core[004324] = 00400; code[004324] = &I04324;
  core[004325] = 07777; code[004325] = &I04325;
  core[004326] = 00100; code[004326] = &I04326;
  core[004327] = 07777; code[004327] = &I04327;
  core[004330] = 00200; code[004330] = &I04330;
  core[004331] = 07777; code[004331] = &I04331;
  core[004332] = 00400; code[004332] = &I04332;
  core[004333] = 07777; code[004333] = &I04333;
  core[004334] = 01000; code[004334] = &I04334;
  core[004335] = 07777; code[004335] = &I04335;
  core[004336] = 02000; code[004336] = &I04336;
  core[004337] = 07777; code[004337] = &I04337;
  core[004340] = 04000; code[004340] = &I04340;
  core[004341] = 07777; code[004341] = &I04341;
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

