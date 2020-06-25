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
int pc = 00147;
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
void D00004() { lac &= (010000|core[000000]);  }
void I00005() { lac &= (010000|core[000000]);  }
void D00006() { hlt = 1;  }
void D00007() {  }
void D00010() { lac &= (010000|core[000000]);  }
void D00020() { lac &= (010000|core[000000]);  }
void D00021() { lac &= (010000|core[000001]);  }
void D00022() { lac &= (010000|core[000002]);  }
void D00023() { lac &= (010000|core[000003]);  }
void D00024() { lac &= (010000|core[000004]);  }
void L00025() { lac &= (010000|core[000006]);  }
void D00026() { lac &= (010000|core[000010]);  }
void D00027() { lac &= (010000|core[000014]);  }
void D00030() { lac &= (010000|core[000020]);  }
void D00031() { lac &= (010000|core[000030]);  }
void D00032() { lac &= (010000|core[000040]);  }
void D00033() { lac &= (010000|core[000060]);  }
void D00034() { lac &= (010000|core[000100]);  }
void D00035() { lac &= (010000|core[000140]);  }
void D00036() { lac &= (010000|core[000000]);  }
void D00037() { lac &= (010000|core[000100]);  }
void D00040() { lac &= (010000|core[(df<<12)+core[0]]);  }
void D00041() { lac &= (010000|core[(df<<12)+core[0]]);  }
void D00042() { lac += core[000000];  }
void D00043() { lac += core[000034];  }
void D00044() { lac += core[(df<<12)+core[0]];  }
void D00045() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void D00046() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void D00047() { core[000112] = lac & 07777; lac &= 010000; code[000112] = &emul8;  }
void D00050() { core[000000] = 00051; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void D00051() { emul8();  }
void L00052() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void D00053() { emul8();  }
void D00054() { emul8();  }
void D00055() { emul8();  }
void D00056() { emul8();  }
void D00057() { emul8();  }
void D00060() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D00061() { emul8();  }
void D00062() { emul8();  }
void D00063() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D00064() { emul8();  }
void D00065() { npc = (ib<<12)+core[127]; inh = 0;  }
void D00066() { core[(df<<12)+core[127]] = lac & 07777; lac &= 010000; code[(df<<12)+core[127]] = &emul8;  }
void D00067() { emul8();  }
void D00070() { npc = 000052; inh = 0;  }
void D00071() { if (++core[(df<<12)+core[85]] == 010000) { core[(df<<12)+core[85]] = 0; npc++; }; code[(df<<12)+core[85]] = &emul8;  }
void D00072() { emul8();  }
void D00073() {  }
void D00074() {  }
void D00075() { lac &= 010000;  }
void D00076() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D00077() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void D00100() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D00101() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void D00102() { lac &= (010000|core[000007]);  }
void I00103() { lac &= (010000|core[000067]);  }
void I00104() { lac &= (010000|core[000017]);  }
void D00105() { lac &= (010000|core[000037]);  }
void D00106() { lac &= (010000|core[000077]);  }
void I00107() { lac &= (010000|core[000177]);  }
void D00110() { lac &= (010000|core[000177]);  }
void D00111() { lac &= (010000|core[(df<<12)+core[127]]);  }
void D00112() { lac += core[(df<<12)+core[127]];  }
void D00113() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D00114() { npc = 000025; inh = 0;  }
void D00115() { if (++core[(df<<12)+core[106]] == 010000) { core[(df<<12)+core[106]] = 0; npc++; }; code[(df<<12)+core[106]] = &emul8;  }
void D00116() { lac &= (010000|core[(df<<12)+core[120]]);  }
void D00117() { lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void D00120() { lac &= (010000|core[000007]);  }
void D00121() { npc = 000140; inh = 0;  }
void D00122() { npc = 000140; inh = 0;  }
void L00144() { lac += core[000067];  }
void I00145() { lac &= 010000;  }
void I00146() { hlt = 1;  }
void L00147() { skp = 0; skp = !skp; npc += skp;  }
void I00150() { hlt = 1;  }
void I00151() { lac &= 010000;  }
void P00152() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00153() { hlt = 1;  }
void I00154() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00155() { skp = 0; skp = !skp; npc += skp;  }
void I00156() { hlt = 1;  }
void I00157() { lac &= 010000;  }
void I00160() { lac += core[000050];  }
void I00161() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00162() { skp = 0; skp = !skp; npc += skp;  }
void I00163() { hlt = 1;  }
void I00164() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00165() { hlt = 1;  }
void I00166() { lac &= 010000;  }
void I00167() { lac += core[000045];  }
void P00170() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00171() { skp = 0; skp = !skp; npc += skp;  }
void I00172() { hlt = 1;  }
void I00173() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00174() { hlt = 1;  }
void I00175() {  }
void I00176() {  }
void P00177() { skp = 0; skp = !skp; npc += skp;  }
void I00200() { npc = 000144; inh = 0;  }
void I00201() { lac &= 010000;  }
void I00202() { lac += core[000042];  }
void I00203() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00204() { skp = 0; skp = !skp; npc += skp;  }
void I00205() { hlt = 1;  }
void I00206() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00207() { hlt = 1;  }
void I00210() { lac &= 010000;  }
void I00211() { lac += core[000040];  }
void I00212() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00213() { skp = 0; skp = !skp; npc += skp;  }
void I00214() { hlt = 1;  }
void I00215() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00216() { hlt = 1;  }
void I00217() { lac &= 010000;  }
void I00220() { lac += core[000036];  }
void I00221() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00222() { skp = 0; skp = !skp; npc += skp;  }
void I00223() { hlt = 1;  }
void I00224() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00225() { hlt = 1;  }
void I00226() { lac &= 010000;  }
void I00227() { lac += core[000034];  }
void I00230() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00231() { skp = 0; skp = !skp; npc += skp;  }
void I00232() { hlt = 1;  }
void I00233() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00234() { hlt = 1;  }
void I00235() { lac &= 010000;  }
void I00236() { lac += core[000032];  }
void I00237() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00240() { skp = 0; skp = !skp; npc += skp;  }
void I00241() { hlt = 1;  }
void I00242() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00243() { hlt = 1;  }
void I00244() { lac &= 010000;  }
void I00245() { lac += core[000030];  }
void I00246() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00247() { skp = 0; skp = !skp; npc += skp;  }
void I00250() { hlt = 1;  }
void I00251() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00252() { hlt = 1;  }
void I00253() { lac &= 010000;  }
void I00254() { lac += core[000026];  }
void I00255() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00256() { skp = 0; skp = !skp; npc += skp;  }
void I00257() { hlt = 1;  }
void I00260() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00261() { hlt = 1;  }
void I00262() { lac &= 010000;  }
void I00263() { lac += core[000024];  }
void I00264() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00265() { skp = 0; skp = !skp; npc += skp;  }
void I00266() { hlt = 1;  }
void I00267() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00270() { hlt = 1;  }
void I00271() { lac &= 010000;  }
void I00272() { lac += core[000022];  }
void I00273() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00274() { skp = 0; skp = !skp; npc += skp;  }
void I00275() { hlt = 1;  }
void I00276() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00277() { hlt = 1;  }
void I00300() { lac &= 010000;  }
void I00301() { lac += core[000021];  }
void I00302() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00303() { skp = 0; skp = !skp; npc += skp;  }
void I00304() { hlt = 1;  }
void I00305() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00306() { hlt = 1;  }
void I00307() { lac &= 010000;  }
void I00310() { lac += core[000066];  }
void I00311() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00312() { hlt = 1;  }
void I00313() { lac &= 010000;  }
void I00314() { lac += core[000050];  }
void I00315() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I00316() { skp = 0; skp = !skp; npc += skp;  }
void I00317() { hlt = 1;  }
void I00320() { lac &= 010000;  }
void I00321() { lac += core[000066];  }
void I00322() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I00323() { skp = 0; skp = !skp; npc += skp;  }
void I00324() { hlt = 1;  }
void I00325() { lac &= 010000;  }
void I00326() { lac += core[000050];  }
void I00327() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I00330() { hlt = 1;  }
void I00331() { lac &= 010000;  }
void I00332() { lac += core[000067];  }
void I00333() { lac ^= 07777;  }
void I00334() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00335() { hlt = 1;  }
void I00336() { lac &= 010000;  }
void I00337() { lac += core[000071];  }
void I00340() { lac ^= 07777;  }
void I00341() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00342() { hlt = 1;  }
void I00343() { lac += core[000071];  }
void I00344() { lac ^= 07777;  }
void I00345() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00346() { hlt = 1;  }
void I00347() { lac &= 010000;  }
void I00350() { lac += core[000070];  }
void I00351() { lac ^= 07777;  }
void I00352() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00353() { hlt = 1;  }
void I00354() { lac += core[000070];  }
void I00355() { lac ^= 07777;  }
void I00356() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00357() { hlt = 1;  }
void I00360() { lac &= 010000;  }
void I00361() { lac += core[000067];  }
void I00362() { lac ^= 07777;  }
void I00363() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00364() { hlt = 1;  }
void I00365() { lac &= 010000;  }
void I00366() { lac++;  }
void I00367() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00370() { skp = 0; skp = !skp; npc += skp;  }
void I00371() { hlt = 1;  }
void I00372() { lac &= 010000;  }
void I00373() { lac += core[000067];  }
void I00374() { lac++;  }
void I00375() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00376() { hlt = 1;  }
void I00377() { lac &= 010000;  }
void I00400() { lac += core[000101];  }
void I00401() { lac++;  }
void I00402() { lac++;  }
void I00403() { lac++;  }
void I00404() { lac++;  }
void I00405() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00406() { hlt = 1;  }
void I00407() { lac &= 010000;  }
void I00410() { lac &= 07777;  }
void I00411() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00412() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00413() { hlt = 1;  }
void I00414() { lac &= 010000;  }
void I00415() { lac &= 07777;  }
void I00416() { lac ^= 010000;  }
void I00417() { lac += core[000050];  }
void I00420() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00421() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00422() { skp = 0; skp = !skp; npc += skp;  }
void I00423() { hlt = 1;  }
void I00424() { lac &= 010000;  }
void I00425() { lac &= 07777;  }
void I00426() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00427() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00430() { skp = 0; skp = !skp; npc += skp;  }
void I00431() { hlt = 1;  }
void I00432() { lac &= 010000;  }
void I00433() { lac &= 07777;  }
void I00434() { lac ^= 010000;  }
void I00435() { lac += core[000050];  }
void I00436() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00437() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00440() { hlt = 1;  }
void I00441() { lac &= 010000;  }
void I00442() { lac += core[000050];  }
void I00443() { lac = (lac<<1) + ((lac>>12)&1);  }
void I00444() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00445() { npc = 000452; inh = 0;  }
void L00446() { lac &= 07777;  }
void I00447() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00450() { hlt = 1;  }
void I00451() { npc = 000456; inh = 0;  }
void L00452() { lac ^= 010000;  }
void I00453() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00454() { hlt = 1;  }
void I00455() { npc = 000446; inh = 0;  }
void L00456() { lac &= 07777;  }
void I00457() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00460() { hlt = 1;  }
void I00461() { lac ^= 010000;  }
void I00462() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00463() { hlt = 1;  }
void I00464() { lac ^= 010000;  }
void I00465() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00466() { hlt = 1;  }
void I00467() { lac &= 010000;  }
void I00470() { lac += core[000067];  }
void I00471() { lac &= 010000;  }
void I00472() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00473() { hlt = 1;  }
void I00474() { lac &= 010000;  }
void I00475() { lac |= swr;  }
void I00476() { lac ^= 07777;  }
void I00477() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00500() { hlt = 1;  }
void I00501() { lac &= 010000;  }
void I00502() { lac &= 07777;  }
void I00503() {  }
void I00504() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00505() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00506() { hlt = 1;  }
void I00507() { lac &= 010000;  }
void I00510() { lac &= 07777;  }
void I00511() {  }
void I00512() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I00513() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00514() { hlt = 1;  }
void I00515() { lac &= 010000;  }
void I00516() { lac += core[000066];  }
void I00517() { lac += core[000050];  }
void I00520() { lac ^= 07777;  }
void I00521() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00522() { hlt = 1;  }
void I00523() { lac &= 010000;  }
void I00524() { lac += core[000065];  }
void I00525() { lac += core[000045];  }
void I00526() { lac ^= 07777;  }
void I00527() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00530() { hlt = 1;  }
void I00531() { lac &= 010000;  }
void I00532() { lac += core[000064];  }
void I00533() { lac += core[000042];  }
void I00534() { lac ^= 07777;  }
void I00535() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00536() { hlt = 1;  }
void I00537() { lac &= 010000;  }
void I00540() { lac += core[000063];  }
void I00541() { lac += core[000040];  }
void I00542() { lac ^= 07777;  }
void I00543() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00544() { hlt = 1;  }
void I00545() { lac &= 010000;  }
void I00546() { lac += core[000062];  }
void I00547() { lac += core[000036];  }
void I00550() { lac ^= 07777;  }
void I00551() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00552() { hlt = 1;  }
void I00553() { lac &= 010000;  }
void I00554() { lac += core[000061];  }
void I00555() { lac += core[000034];  }
void I00556() { lac ^= 07777;  }
void I00557() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00560() { hlt = 1;  }
void I00561() { lac &= 010000;  }
void I00562() { lac += core[000057];  }
void I00563() { lac += core[000032];  }
void I00564() { lac ^= 07777;  }
void I00565() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00566() { hlt = 1;  }
void I00567() { lac &= 010000;  }
void I00570() { lac += core[000056];  }
void I00571() { lac += core[000030];  }
void I00572() { lac ^= 07777;  }
void I00573() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00574() { hlt = 1;  }
void I00575() { lac &= 010000;  }
void I00576() { lac += core[000055];  }
void I00577() { lac += core[000026];  }
void I00600() { lac ^= 07777;  }
void I00601() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00602() { hlt = 1;  }
void I00603() { lac &= 010000;  }
void I00604() { lac += core[000054];  }
void I00605() { lac += core[000024];  }
void I00606() { lac ^= 07777;  }
void I00607() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00610() { hlt = 1;  }
void I00611() { lac &= 010000;  }
void I00612() { lac += core[000053];  }
void I00613() { lac += core[000022];  }
void I00614() { lac ^= 07777;  }
void I00615() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00616() { hlt = 1;  }
void I00617() { lac &= 010000;  }
void I00620() { lac += core[000052];  }
void I00621() { lac += core[000021];  }
void I00622() { lac ^= 07777;  }
void I00623() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00624() { hlt = 1;  }
void I00625() { lac &= 010000;  }
void I00626() { lac &= 07777;  }
void I00627() { lac += core[000050];  }
void I00630() { lac += core[000050];  }
void I00631() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00632() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00633() { hlt = 1;  }
void I00634() { lac &= 010000;  }
void I00635() { lac &= 07777;  }
void I00636() { lac += core[000072];  }
void I00637() { lac += core[000045];  }
void I00640() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00641() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00642() { hlt = 1;  }
void I00643() { lac &= 010000;  }
void I00644() { lac &= 07777;  }
void I00645() { lac += core[000073];  }
void I00646() { lac += core[000042];  }
void I00647() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00650() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00651() { hlt = 1;  }
void I00652() { lac &= 010000;  }
void I00653() { lac &= 07777;  }
void I00654() { lac += core[000074];  }
void I00655() { lac += core[000040];  }
void I00656() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00657() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00660() { hlt = 1;  }
void I00661() { lac &= 010000;  }
void I00662() { lac &= 07777;  }
void I00663() { lac += core[000075];  }
void I00664() { lac += core[000036];  }
void I00665() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00666() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00667() { hlt = 1;  }
void I00670() { lac &= 010000;  }
void I00671() { lac &= 07777;  }
void I00672() { lac += core[000113];  }
void I00673() { lac += core[000034];  }
void I00674() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00675() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00676() { hlt = 1;  }
void I00677() { lac &= 010000;  }
void I00700() { lac &= 07777;  }
void I00701() { lac += core[000076];  }
void I00702() { lac += core[000032];  }
void I00703() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00704() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00705() { hlt = 1;  }
void I00706() { lac &= 010000;  }
void I00707() { lac &= 07777;  }
void I00710() { lac += core[000077];  }
void I00711() { lac += core[000030];  }
void I00712() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00713() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00714() { hlt = 1;  }
void I00715() { lac &= 010000;  }
void I00716() { lac &= 07777;  }
void I00717() { lac += core[000100];  }
void I00720() { lac += core[000026];  }
void I00721() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00722() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00723() { hlt = 1;  }
void I00724() { lac &= 010000;  }
void I00725() { lac &= 07777;  }
void I00726() { lac += core[000101];  }
void I00727() { lac += core[000024];  }
void I00730() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00731() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00732() { hlt = 1;  }
void I00733() { lac &= 010000;  }
void I00734() { lac &= 07777;  }
void I00735() { lac += core[000052];  }
void I00736() { lac += core[000022];  }
void I00737() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00740() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00741() { hlt = 1;  }
void I00742() { lac &= 010000;  }
void I00743() { lac &= 07777;  }
void I00744() { lac += core[000067];  }
void I00745() { lac += core[000021];  }
void I00746() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I00747() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00750() { hlt = 1;  }
void I00751() { lac &= 010000;  }
void I00752() { lac &= 07777;  }
void I00753() { lac ^= 010000;  }
void I00754() { lac += core[000050];  }
void I00755() { lac += core[000050];  }
void I00756() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00757() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00760() { hlt = 1;  }
void I00761() { lac &= 010000;  }
void I00762() { lac &= 07777;  }
void I00763() { lac += core[000066];  }
void I00764() { lac += core[000045];  }
void I00765() { lac += core[000045];  }
void I00766() { lac ^= 07777;  }
void I00767() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I00770() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I00771() { hlt = 1;  }
void I00772() { lac &= 010000;  }
void I00773() { lac &= 07777;  }
void I00774() { lac += core[000065];  }
void I00775() { lac += core[000042];  }
void I00776() { lac += core[000042];  }
void I00777() { lac ^= 07777;  }
void I01000() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01001() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01002() { hlt = 1;  }
void I01003() { lac &= 010000;  }
void I01004() { lac &= 07777;  }
void I01005() { lac += core[000064];  }
void I01006() { lac += core[000040];  }
void I01007() { lac += core[000040];  }
void I01010() { lac ^= 07777;  }
void I01011() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01012() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01013() { hlt = 1;  }
void I01014() { lac &= 010000;  }
void I01015() { lac &= 07777;  }
void I01016() { lac += core[000063];  }
void I01017() { lac += core[000036];  }
void I01020() { lac += core[000036];  }
void I01021() { lac ^= 07777;  }
void I01022() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01023() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01024() { hlt = 1;  }
void I01025() { lac &= 010000;  }
void I01026() { lac &= 07777;  }
void I01027() { lac += core[000062];  }
void I01030() { lac += core[000034];  }
void I01031() { lac += core[000034];  }
void I01032() { lac ^= 07777;  }
void I01033() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01034() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01035() { hlt = 1;  }
void I01036() { lac &= 010000;  }
void I01037() { lac &= 07777;  }
void I01040() { lac += core[000061];  }
void I01041() { lac += core[000032];  }
void I01042() { lac += core[000032];  }
void I01043() { lac ^= 07777;  }
void I01044() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01045() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01046() { hlt = 1;  }
void I01047() { lac &= 010000;  }
void I01050() { lac &= 07777;  }
void I01051() { lac += core[000057];  }
void I01052() { lac += core[000030];  }
void I01053() { lac += core[000030];  }
void I01054() { lac ^= 07777;  }
void I01055() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01056() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01057() { hlt = 1;  }
void I01060() { lac &= 010000;  }
void I01061() { lac &= 07777;  }
void I01062() { lac += core[000056];  }
void I01063() { lac += core[000026];  }
void I01064() { lac += core[000026];  }
void I01065() { lac ^= 07777;  }
void I01066() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01067() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01070() { hlt = 1;  }
void I01071() { lac &= 010000;  }
void I01072() { lac &= 07777;  }
void I01073() { lac += core[000055];  }
void I01074() { lac += core[000024];  }
void I01075() { lac += core[000024];  }
void I01076() { lac ^= 07777;  }
void I01077() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01100() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01101() { hlt = 1;  }
void I01102() { lac &= 010000;  }
void I01103() { lac &= 07777;  }
void I01104() { lac += core[000054];  }
void I01105() { lac += core[000022];  }
void I01106() { lac += core[000022];  }
void I01107() { lac ^= 07777;  }
void I01110() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01111() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01112() { hlt = 1;  }
void I01113() { lac &= 010000;  }
void I01114() { lac &= 07777;  }
void I01115() { lac += core[000053];  }
void I01116() { lac += core[000021];  }
void I01117() { lac += core[000021];  }
void I01120() { lac ^= 07777;  }
void I01121() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01122() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01123() { hlt = 1;  }
void I01124() { lac &= 010000;  }
void I01125() { lac &= 07777;  }
void I01126() { lac += core[000021];  }
void I01127() { lac += core[000023];  }
void I01130() { lac += core[000054];  }
void I01131() { lac ^= 07777;  }
void I01132() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01133() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01134() { hlt = 1;  }
void I01135() { lac &= 010000;  }
void I01136() { lac &= 07777;  }
void I01137() { lac += core[000022];  }
void I01140() { lac += core[000025];  }
void I01141() { lac += core[000055];  }
void I01142() { lac ^= 07777;  }
void I01143() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01144() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01145() { hlt = 1;  }
void I01146() { lac &= 010000;  }
void I01147() { lac &= 07777;  }
void I01150() { lac += core[000024];  }
void I01151() { lac += core[000027];  }
void I01152() { lac += core[000056];  }
void I01153() { lac ^= 07777;  }
void I01154() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01155() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01156() { hlt = 1;  }
void I01157() { lac &= 010000;  }
void I01160() { lac &= 07777;  }
void I01161() { lac += core[000026];  }
void I01162() { lac += core[000031];  }
void I01163() { lac += core[000057];  }
void I01164() { lac ^= 07777;  }
void I01165() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01166() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01167() { hlt = 1;  }
void I01170() { lac &= 010000;  }
void I01171() { lac &= 07777;  }
void I01172() { lac += core[000030];  }
void I01173() { lac += core[000033];  }
void I01174() { lac += core[000061];  }
void I01175() { lac ^= 07777;  }
void I01176() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01177() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01200() { hlt = 1;  }
void I01201() { lac &= 010000;  }
void I01202() { lac &= 07777;  }
void I01203() { lac += core[000032];  }
void I01204() { lac += core[000035];  }
void I01205() { lac += core[000062];  }
void I01206() { lac ^= 07777;  }
void I01207() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01210() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01211() { hlt = 1;  }
void I01212() { lac &= 010000;  }
void I01213() { lac &= 07777;  }
void I01214() { lac += core[000034];  }
void I01215() { lac += core[000037];  }
void I01216() { lac += core[000063];  }
void I01217() { lac ^= 07777;  }
void I01220() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01221() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01222() { hlt = 1;  }
void I01223() { lac &= 010000;  }
void I01224() { lac &= 07777;  }
void I01225() { lac += core[000036];  }
void I01226() { lac += core[000041];  }
void I01227() { lac += core[000064];  }
void I01230() { lac ^= 07777;  }
void I01231() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01232() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01233() { hlt = 1;  }
void I01234() { lac &= 010000;  }
void I01235() { lac &= 07777;  }
void I01236() { lac += core[000040];  }
void I01237() { lac += core[000044];  }
void I01240() { lac += core[000065];  }
void I01241() { lac ^= 07777;  }
void I01242() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01243() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01244() { hlt = 1;  }
void I01245() { lac &= 010000;  }
void I01246() { lac &= 07777;  }
void I01247() { lac += core[000042];  }
void I01250() { lac += core[000046];  }
void I01251() { lac += core[000066];  }
void I01252() { lac ^= 07777;  }
void I01253() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01254() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01255() { hlt = 1;  }
void I01256() { lac &= 010000;  }
void I01257() { lac &= 07777;  }
void I01260() { lac += core[000045];  }
void I01261() { lac += core[000072];  }
void I01262() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01263() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01264() { hlt = 1;  }
void I01265() { lac &= 010000;  }
void I01266() { lac &= 07777;  }
void I01267() { lac += core[000067];  }
void I01270() { lac += core[000021];  }
void I01271() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01272() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01273() { hlt = 1;  }
void I01274() { lac &= 010000;  }
void I01275() { lac &= 07777;  }
void I01276() { lac += core[000023];  }
void I01277() { lac += core[000023];  }
void I01300() { lac += core[000100];  }
void I01301() { lac += core[000021];  }
void I01302() { lac ^= 07777;  }
void I01303() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01304() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01305() { hlt = 1;  }
void I01306() { lac &= 010000;  }
void I01307() { lac &= 07777;  }
void I01310() { lac += core[000025];  }
void I01311() { lac += core[000025];  }
void I01312() { lac += core[000077];  }
void I01313() { lac += core[000023];  }
void I01314() { lac ^= 07777;  }
void I01315() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01316() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01317() { hlt = 1;  }
void I01320() { lac &= 010000;  }
void I01321() { lac &= 07777;  }
void I01322() { lac += core[000027];  }
void I01323() { lac += core[000027];  }
void I01324() { lac += core[000076];  }
void I01325() { lac += core[000102];  }
void I01326() { lac ^= 07777;  }
void I01327() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01330() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01331() { hlt = 1;  }
void I01332() { lac &= 010000;  }
void I01333() { lac &= 07777;  }
void I01334() { lac += core[000031];  }
void I01335() { lac += core[000031];  }
void I01336() { lac += core[000051];  }
void I01337() { lac ^= 07777;  }
void I01340() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01341() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01342() { hlt = 1;  }
void I01343() { lac &= 010000;  }
void I01344() { lac &= 07777;  }
void I01345() { lac += core[000033];  }
void I01346() { lac += core[000033];  }
void I01347() { lac += core[000075];  }
void I01350() { lac += core[000105];  }
void I01351() { lac ^= 07777;  }
void I01352() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01353() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01354() { hlt = 1;  }
void I01355() { lac &= 010000;  }
void I01356() { lac &= 07777;  }
void I01357() { lac += core[000035];  }
void I01360() { lac += core[000035];  }
void I01361() { lac += core[000074];  }
void I01362() { lac += core[000106];  }
void I01363() { lac ^= 07777;  }
void I01364() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01365() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01366() { hlt = 1;  }
void I01367() { lac &= 010000;  }
void I01370() { lac &= 07777;  }
void I01371() { lac += core[000037];  }
void I01372() { lac += core[000037];  }
void I01373() { lac += core[000060];  }
void I01374() { lac ^= 07777;  }
void I01375() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01376() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01377() { hlt = 1;  }
void I01400() { lac &= 010000;  }
void I01401() { lac &= 07777;  }
void I01402() { lac += core[000041];  }
void I01403() { lac += core[000041];  }
void I01404() { lac += core[000072];  }
void I01405() { lac += core[000110];  }
void I01406() { lac ^= 07777;  }
void I01407() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01410() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01411() { hlt = 1;  }
void I01412() { lac &= 010000;  }
void I01413() { lac &= 07777;  }
void I01414() { lac += core[000044];  }
void I01415() { lac += core[000044];  }
void I01416() { lac += core[000050];  }
void I01417() { lac += core[000111];  }
void I01420() { lac ^= 07777;  }
void I01421() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01422() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01423() { hlt = 1;  }
void I01424() { lac &= 010000;  }
void I01425() { lac &= 07777;  }
void I01426() { lac += core[000046];  }
void I01427() { lac += core[000046];  }
void I01430() { lac += core[000112];  }
void I01431() { lac ^= 07777;  }
void I01432() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01433() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01434() { hlt = 1;  }
void I01435() { lac &= 010000;  }
void I01436() { lac &= 07777;  }
void I01437() { lac += core[000072];  }
void I01440() { lac += core[000072];  }
void I01441() { lac += core[000066];  }
void I01442() { lac ^= 07777;  }
void I01443() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01444() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01445() { hlt = 1;  }
void I01446() { lac &= 010000;  }
void I01447() { lac &= 07777;  }
void I01450() { lac += core[000067];  }
void I01451() { lac += core[000067];  }
void I01452() { lac += core[000021];  }
void I01453() { lac ^= 07777;  }
void I01454() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01455() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01456() { hlt = 1;  }
void I01457() { lac &= 010000;  }
void I01460() { lac &= 07777;  }
void I01461() { lac += core[000021];  }
void I01462() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01463() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01464() { hlt = 1;  }
void I01465() { lac &= 010000;  }
void I01466() { lac &= 07777;  }
void I01467() { lac += core[000020];  }
void I01470() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01471() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01472() { hlt = 1;  }
void I01473() { lac &= 010000;  }
void I01474() { lac &= 07777;  }
void I01475() { lac += core[000020];  }
void I01476() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01477() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01500() { hlt = 1;  }
void I01501() { lac &= 010000;  }
void I01502() { lac &= 07777;  }
void I01503() { lac ^= 010000;  }
void I01504() { lac += core[000020];  }
void I01505() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01506() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01507() { hlt = 1;  }
void I01510() { lac &= 010000;  }
void I01511() { lac &= 07777;  }
void I01512() { lac ^= 010000;  }
void I01513() { lac += core[000067];  }
void I01514() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01515() { lac ^= 07777;  }
void I01516() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01517() { hlt = 1;  }
void I01520() { lac &= 010000;  }
void I01521() { lac &= 07777;  }
void I01522() { lac ^= 010000;  }
void I01523() { lac += core[000020];  }
void I01524() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01525() { lac += core[000066];  }
void I01526() { lac ^= 07777;  }
void I01527() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01530() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01531() { hlt = 1;  }
void I01532() { lac &= 010000;  }
void I01533() { lac &= 07777;  }
void I01534() { lac += core[000050];  }
void I01535() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01536() { lac += core[000065];  }
void I01537() { lac ^= 07777;  }
void I01540() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01541() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01542() { hlt = 1;  }
void I01543() { lac &= 010000;  }
void I01544() { lac &= 07777;  }
void I01545() { lac += core[000045];  }
void I01546() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01547() { lac += core[000064];  }
void I01550() { lac ^= 07777;  }
void I01551() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01552() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01553() { hlt = 1;  }
void I01554() { lac &= 010000;  }
void I01555() { lac &= 07777;  }
void I01556() { lac += core[000042];  }
void I01557() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01560() { lac += core[000063];  }
void I01561() { lac ^= 07777;  }
void I01562() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01563() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01564() { hlt = 1;  }
void I01565() { lac &= 010000;  }
void I01566() { lac &= 07777;  }
void I01567() { lac += core[000040];  }
void I01570() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01571() { lac += core[000062];  }
void I01572() { lac ^= 07777;  }
void I01573() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01574() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01575() { hlt = 1;  }
void I01576() { lac &= 010000;  }
void I01577() { lac &= 07777;  }
void I01600() { lac += core[000036];  }
void I01601() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01602() { lac += core[000061];  }
void I01603() { lac ^= 07777;  }
void I01604() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01605() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01606() { hlt = 1;  }
void I01607() { lac &= 010000;  }
void I01610() { lac &= 07777;  }
void I01611() { lac += core[000034];  }
void I01612() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01613() { lac += core[000057];  }
void I01614() { lac ^= 07777;  }
void I01615() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01616() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01617() { hlt = 1;  }
void I01620() { lac &= 010000;  }
void I01621() { lac &= 07777;  }
void I01622() { lac += core[000032];  }
void I01623() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01624() { lac += core[000056];  }
void I01625() { lac ^= 07777;  }
void I01626() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01627() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01630() { hlt = 1;  }
void I01631() { lac &= 010000;  }
void I01632() { lac &= 07777;  }
void I01633() { lac += core[000030];  }
void I01634() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01635() { lac += core[000055];  }
void I01636() { lac ^= 07777;  }
void I01637() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01640() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01641() { hlt = 1;  }
void I01642() { lac &= 010000;  }
void I01643() { lac &= 07777;  }
void I01644() { lac += core[000026];  }
void I01645() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01646() { lac += core[000054];  }
void I01647() { lac ^= 07777;  }
void I01650() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01651() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01652() { hlt = 1;  }
void I01653() { lac &= 010000;  }
void I01654() { lac &= 07777;  }
void I01655() { lac += core[000024];  }
void I01656() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01657() { lac += core[000053];  }
void I01660() { lac ^= 07777;  }
void I01661() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01662() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01663() { hlt = 1;  }
void I01664() { lac &= 010000;  }
void I01665() { lac &= 07777;  }
void I01666() { lac += core[000022];  }
void I01667() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01670() { lac += core[000052];  }
void I01671() { lac ^= 07777;  }
void I01672() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01673() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01674() { hlt = 1;  }
void I01675() { lac &= 010000;  }
void I01676() { lac &= 07777;  }
void I01677() { lac += core[000021];  }
void I01700() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I01701() { lac += core[000067];  }
void I01702() { lac ^= 07777;  }
void I01703() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01704() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01705() { hlt = 1;  }
void I01706() { lac &= 010000;  }
void I01707() { lac &= 07777;  }
void I01710() { lac += core[000022];  }
void I01711() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01712() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I01713() { hlt = 1;  }
void I01714() { lac &= 010000;  }
void I01715() { lac &= 07777;  }
void I01716() { lac += core[000020];  }
void I01717() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01720() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01721() { hlt = 1;  }
void I01722() { lac &= 010000;  }
void I01723() { lac &= 07777;  }
void I01724() { lac += core[000020];  }
void I01725() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01726() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01727() { hlt = 1;  }
void I01730() { lac &= 010000;  }
void I01731() { lac &= 07777;  }
void I01732() { lac ^= 010000;  }
void I01733() { lac += core[000020];  }
void I01734() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01735() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01736() { hlt = 1;  }
void I01737() { lac &= 010000;  }
void I01740() { lac &= 07777;  }
void I01741() { lac ^= 010000;  }
void I01742() { lac += core[000067];  }
void I01743() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01744() { lac ^= 07777;  }
void I01745() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I01746() { hlt = 1;  }
void I01747() { lac &= 010000;  }
void I01750() { lac &= 07777;  }
void I01751() { lac ^= 010000;  }
void I01752() { lac += core[000020];  }
void I01753() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01754() { lac += core[000065];  }
void I01755() { lac ^= 07777;  }
void I01756() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01757() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01760() { hlt = 1;  }
void I01761() { lac &= 010000;  }
void I01762() { lac &= 07777;  }
void I01763() { lac += core[000050];  }
void I01764() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01765() { lac += core[000064];  }
void I01766() { lac ^= 07777;  }
void I01767() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I01770() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I01771() { hlt = 1;  }
void I01772() { lac &= 010000;  }
void I01773() { lac &= 07777;  }
void I01774() { lac += core[000045];  }
void I01775() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I01776() { lac += core[000063];  }
void I01777() { lac ^= 07777;  }
void I02000() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02001() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02002() { hlt = 1;  }
void I02003() { lac &= 010000;  }
void I02004() { lac &= 07777;  }
void I02005() { lac += core[000042];  }
void I02006() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02007() { lac += core[000062];  }
void I02010() { lac ^= 07777;  }
void I02011() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02012() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02013() { hlt = 1;  }
void I02014() { lac &= 010000;  }
void I02015() { lac &= 07777;  }
void I02016() { lac += core[000040];  }
void I02017() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02020() { lac += core[000061];  }
void I02021() { lac ^= 07777;  }
void I02022() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02023() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02024() { hlt = 1;  }
void I02025() { lac &= 010000;  }
void I02026() { lac &= 07777;  }
void I02027() { lac += core[000036];  }
void I02030() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02031() { lac += core[000057];  }
void I02032() { lac ^= 07777;  }
void I02033() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02034() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02035() { hlt = 1;  }
void I02036() { lac &= 010000;  }
void I02037() { lac &= 07777;  }
void I02040() { lac += core[000034];  }
void I02041() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02042() { lac += core[000056];  }
void I02043() { lac ^= 07777;  }
void I02044() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02045() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02046() { hlt = 1;  }
void I02047() { lac &= 010000;  }
void I02050() { lac &= 07777;  }
void I02051() { lac += core[000032];  }
void I02052() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02053() { lac += core[000055];  }
void I02054() { lac ^= 07777;  }
void I02055() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02056() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02057() { hlt = 1;  }
void I02060() { lac &= 010000;  }
void I02061() { lac &= 07777;  }
void I02062() { lac += core[000030];  }
void I02063() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02064() { lac += core[000054];  }
void I02065() { lac ^= 07777;  }
void I02066() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02067() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02070() { hlt = 1;  }
void I02071() { lac &= 010000;  }
void I02072() { lac &= 07777;  }
void I02073() { lac += core[000026];  }
void I02074() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02075() { lac += core[000053];  }
void I02076() { lac ^= 07777;  }
void I02077() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02100() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02101() { hlt = 1;  }
void I02102() { lac &= 010000; lac &= 07777;  }
void I02103() { lac += core[000024];  }
void I02104() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02105() { lac += core[000052];  }
void I02106() { lac ^= 07777;  }
void I02107() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02110() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02111() { hlt = 1;  }
void I02112() { lac &= 010000;  }
void I02113() { lac &= 07777;  }
void I02114() { lac += core[000022];  }
void I02115() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02116() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02117() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02120() { hlt = 1;  }
void I02121() { lac &= 010000;  }
void I02122() { lac &= 07777;  }
void I02123() { lac += core[000021];  }
void I02124() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I02125() { lac += core[000066];  }
void I02126() { lac ^= 07777;  }
void I02127() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02130() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02131() { hlt = 1;  }
void I02132() { lac &= 010000;  }
void I02133() { lac &= 07777;  }
void I02134() { lac += core[000050];  }
void I02135() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02136() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02137() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02140() { hlt = 1;  }
void I02141() { lac &= 010000;  }
void I02142() { lac &= 07777;  }
void I02143() { lac += core[000020];  }
void I02144() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02145() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02146() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02147() { hlt = 1;  }
void I02150() { lac &= 010000;  }
void I02151() { lac &= 07777;  }
void I02152() { lac ^= 010000;  }
void I02153() { lac += core[000020];  }
void I02154() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02155() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02156() { hlt = 1;  }
void I02157() { lac &= 010000;  }
void I02160() { lac &= 07777;  }
void I02161() { lac ^= 010000;  }
void I02162() { lac += core[000067];  }
void I02163() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02164() { lac ^= 07777;  }
void I02165() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02166() { hlt = 1;  }
void I02167() { lac &= 010000;  }
void I02170() { lac &= 07777;  }
void I02171() { lac += core[000045];  }
void I02172() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02173() { lac += core[000066];  }
void I02174() { lac ^= 07777;  }
void I02175() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02176() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02177() { hlt = 1;  }
void I02200() { lac &= 010000;  }
void I02201() { lac &= 07777;  }
void I02202() { lac += core[000042];  }
void I02203() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02204() { lac += core[000065];  }
void I02205() { lac ^= 07777;  }
void I02206() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02207() { hlt = 1;  }
void I02210() { lac &= 010000;  }
void I02211() { lac &= 07777;  }
void I02212() { lac += core[000040];  }
void I02213() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02214() { lac += core[000064];  }
void I02215() { lac ^= 07777;  }
void I02216() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02217() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02220() { hlt = 1;  }
void I02221() { lac &= 010000;  }
void I02222() { lac &= 07777;  }
void I02223() { lac += core[000036];  }
void I02224() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02225() { lac += core[000063];  }
void I02226() { lac ^= 07777;  }
void I02227() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02230() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02231() { hlt = 1;  }
void I02232() { lac &= 010000;  }
void I02233() { lac &= 07777;  }
void I02234() { lac += core[000034];  }
void I02235() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02236() { lac += core[000062];  }
void I02237() { lac ^= 07777;  }
void I02240() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02241() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02242() { hlt = 1;  }
void I02243() { lac &= 010000;  }
void I02244() { lac &= 07777;  }
void I02245() { lac += core[000032];  }
void I02246() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02247() { lac += core[000061];  }
void I02250() { lac ^= 07777;  }
void I02251() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02252() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02253() { hlt = 1;  }
void I02254() { lac &= 010000;  }
void I02255() { lac &= 07777;  }
void I02256() { lac += core[000030];  }
void I02257() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02260() { lac += core[000057];  }
void I02261() { lac ^= 07777;  }
void I02262() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02263() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02264() { hlt = 1;  }
void I02265() { lac &= 010000;  }
void I02266() { lac &= 07777;  }
void I02267() { lac += core[000026];  }
void I02270() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02271() { lac += core[000056];  }
void I02272() { lac ^= 07777;  }
void I02273() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02274() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02275() { hlt = 1;  }
void I02276() { lac &= 010000;  }
void I02277() { lac &= 07777;  }
void I02300() { lac += core[000024];  }
void I02301() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02302() { lac += core[000055];  }
void I02303() { lac ^= 07777;  }
void I02304() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02305() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02306() { hlt = 1;  }
void I02307() { lac &= 010000;  }
void I02310() { lac &= 07777;  }
void I02311() { lac += core[000022];  }
void I02312() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02313() { lac += core[000054];  }
void I02314() { lac ^= 07777;  }
void I02315() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02316() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02317() { hlt = 1;  }
void I02320() { lac &= 010000;  }
void I02321() { lac &= 07777;  }
void I02322() { lac += core[000021];  }
void I02323() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02324() { lac += core[000053];  }
void I02325() { lac ^= 07777;  }
void I02326() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02327() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02330() { hlt = 1;  }
void I02331() { lac &= 010000;  }
void I02332() { lac &= 07777;  }
void I02333() { lac ^= 010000;  }
void I02334() { lac = (lac<<1) + ((lac>>12)&1);  }
void I02335() { lac += core[000052];  }
void I02336() { lac ^= 07777;  }
void I02337() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02340() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02341() { hlt = 1;  }
void I02342() { lac &= 010000;  }
void I02343() { lac &= 07777;  }
void I02344() { lac += core[000045];  }
void I02345() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02346() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02347() { hlt = 1;  }
void I02350() { lac &= 010000;  }
void I02351() { lac &= 07777;  }
void I02352() { lac += core[000020];  }
void I02353() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02354() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02355() { hlt = 1;  }
void I02356() { lac &= 010000;  }
void I02357() { lac &= 07777;  }
void I02360() { lac += core[000020];  }
void I02361() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02362() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02363() { hlt = 1;  }
void I02364() { lac &= 010000;  }
void I02365() { lac &= 07777;  }
void I02366() { lac ^= 010000;  }
void I02367() { lac += core[000020];  }
void I02370() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02371() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02372() { hlt = 1;  }
void I02373() { lac &= 010000;  }
void I02374() { lac &= 07777;  }
void I02375() { lac ^= 010000;  }
void I02376() { lac += core[000067];  }
void I02377() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02400() { lac ^= 07777;  }
void I02401() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02402() { hlt = 1;  }
void I02403() { lac &= 010000;  }
void I02404() { lac &= 07777;  }
void I02405() { lac += core[000050];  }
void I02406() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02407() { lac += core[000052];  }
void I02410() { lac ^= 07777;  }
void I02411() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02412() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02413() { hlt = 1;  }
void I02414() { lac &= 010000;  }
void I02415() { lac &= 07777;  }
void I02416() { lac += core[000045];  }
void I02417() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02420() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02421() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02422() { hlt = 1;  }
void I02423() { lac &= 010000;  }
void I02424() { lac &= 07777;  }
void I02425() { lac += core[000042];  }
void I02426() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02427() { lac += core[000066];  }
void I02430() { lac ^= 07777;  }
void I02431() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02432() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02433() { hlt = 1;  }
void I02434() { lac &= 010000;  }
void I02435() { lac &= 07777;  }
void I02436() { lac += core[000040];  }
void I02437() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02440() { lac += core[000065];  }
void I02441() { lac ^= 07777;  }
void I02442() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02443() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02444() { hlt = 1;  }
void I02445() { lac &= 010000;  }
void I02446() { lac &= 07777;  }
void I02447() { lac += core[000036];  }
void I02450() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02451() { lac += core[000064];  }
void I02452() { lac ^= 07777;  }
void I02453() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02454() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02455() { hlt = 1;  }
void I02456() { lac &= 010000;  }
void I02457() { lac &= 07777;  }
void I02460() { lac += core[000034];  }
void I02461() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02462() { lac += core[000063];  }
void I02463() { lac ^= 07777;  }
void I02464() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02465() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02466() { hlt = 1;  }
void I02467() { lac &= 010000;  }
void I02470() { lac &= 07777;  }
void I02471() { lac += core[000032];  }
void I02472() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02473() { lac += core[000062];  }
void I02474() { lac ^= 07777;  }
void I02475() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02476() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02477() { hlt = 1;  }
void I02500() { lac &= 010000;  }
void I02501() { lac &= 07777;  }
void I02502() { lac += core[000030];  }
void I02503() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02504() { lac += core[000061];  }
void I02505() { lac ^= 07777;  }
void I02506() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02507() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02510() { hlt = 1;  }
void I02511() { lac &= 010000;  }
void I02512() { lac &= 07777;  }
void I02513() { lac += core[000026];  }
void I02514() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02515() { lac += core[000057];  }
void I02516() { lac ^= 07777;  }
void I02517() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02520() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02521() { hlt = 1;  }
void I02522() { lac &= 010000;  }
void I02523() { lac &= 07777;  }
void I02524() { lac += core[000024];  }
void I02525() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02526() { lac += core[000056];  }
void I02527() { lac ^= 07777;  }
void I02530() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02531() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02532() { hlt = 1;  }
void I02533() { lac &= 010000;  }
void I02534() { lac &= 07777;  }
void I02535() { lac += core[000022];  }
void I02536() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02537() { lac += core[000055];  }
void I02540() { lac ^= 07777;  }
void I02541() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02542() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02543() { hlt = 1;  }
void I02544() { lac &= 010000;  }
void I02545() { lac &= 07777;  }
void I02546() { lac += core[000021];  }
void I02547() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02550() { lac += core[000054];  }
void I02551() { lac ^= 07777;  }
void I02552() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02553() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02554() { hlt = 1;  }
void I02555() { lac &= 010000;  }
void I02556() { lac &= 07777;  }
void I02557() { lac ^= 010000;  }
void I02560() { lac = (lac<<2) + ((lac>>11)&3);  }
void I02561() { lac += core[000053];  }
void I02562() { lac ^= 07777;  }
void I02563() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02564() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02565() { hlt = 1;  }
void I02566() { lac &= 010000;  }
void I02567() { lac &= 07777;  }
void I02570() { lac ^= 07777;  }
void I02571() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I02572() { lac ^= 07777;  }
void I02573() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02574() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02575() { hlt = 1;  }
void I02576() { lac &= 010000;  }
void I02577() { lac &= 07777;  }
void I02600() { lac ^= 010000;  }
void I02601() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I02602() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I02603() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02604() { hlt = 1;  }
void I02605() { lac &= 010000;  }
void I02606() { lac &= 07777;  }
void I02607() { lac += core[000113];  }
void I02610() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I02611() { lac += core[000113];  }
void I02612() { lac ^= 07777;  }
void I02613() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02614() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02615() { hlt = 1;  }
void I02616() { lac &= 010000;  }
void I02617() { lac &= 07777;  }
void I02620() { lac += core[000106];  }
void I02621() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I02622() { lac += core[000106];  }
void I02623() { lac ^= 07777;  }
void I02624() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02625() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02626() { hlt = 1;  }
void I02627() { lac &= 010000; lac &= 07777;  }
void I02630() { lac += core[000116];  }
void I02631() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I02632() { lac += core[000116];  }
void I02633() { lac ^= 07777;  }
void I02634() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02635() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02636() { hlt = 1;  }
void I02637() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I02640() { lac += core[000117];  }
void I02641() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I02642() { lac += core[000117];  }
void I02643() { lac ^= 07777;  }
void I02644() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02645() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02646() { hlt = 1;  }
void I02647() { lac &= 010000;  }
void I02650() { lac &= 07777;  }
void I02651() { lac += core[000114];  }
void I02652() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I02653() { lac += core[000114];  }
void I02654() { lac ^= 07777;  }
void I02655() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02656() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02657() { hlt = 1;  }
void I02660() { lac &= 010000;  }
void I02661() { lac &= 07777;  }
void I02662() { lac += core[000115];  }
void I02663() { lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I02664() { lac += core[000115];  }
void I02665() { lac ^= 07777;  }
void I02666() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02667() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02670() { hlt = 1;  }
void I02671() { lac &= 010000;  }
void I02672() { lac &= 07777;  }
void I02673() { lac ^= 07777;  }
void I02674() { lac ^= 010000;  }
void I02675() { lac &= 010000; lac &= 07777;  }
void I02676() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02677() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02700() { hlt = 1;  }
void I02701() { lac &= 010000;  }
void I02702() { lac += core[000071];  }
void I02703() { lac &= 010000; lac ^= 07777;  }
void I02704() { lac ^= 07777;  }
void I02705() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02706() { hlt = 1;  }
void I02707() { lac &= 010000;  }
void I02710() { lac &= 07777;  }
void I02711() { lac ^= 07777;  }
void I02712() { lac &= 07777; lac ^= 07777;  }
void I02713() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02714() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02715() { hlt = 1;  }
void I02716() { lac &= 07777;  }
void I02717() { lac ^= 010000;  }
void I02720() { lac &= 010000;  }
void I02721() { lac ^= 07777;  }
void I02722() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02723() { lac ^= 07777;  }
void I02724() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02725() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02726() { hlt = 1;  }
void I02727() { lac &= 010000;  }
void I02730() { lac &= 07777;  }
void I02731() { lac ^= 07777;  }
void I02732() { lac &= 010000; lac ^= 010000;  }
void I02733() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02734() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02735() { hlt = 1;  }
void I02736() { lac &= 07777;  }
void I02737() { lac ^= 010000;  }
void I02740() { lac &= 07777; lac ^= 010000;  }
void I02741() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02742() { hlt = 1;  }
void I02743() { lac &= 07777;  }
void I02744() { lac &= 07777; lac ^= 010000;  }
void I02745() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02746() { hlt = 1;  }
void I02747() { lac &= 07777; lac ^= 010000;  }
void I02750() { lac &= 010000; lac ^= 07777;  }
void I02751() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I02752() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02753() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02754() { hlt = 1;  }
void I02755() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02756() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I02757() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02760() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02761() { hlt = 1;  }
void I02762() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02763() { lac ^= 010000; lac ^= 07777;  }
void I02764() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I02765() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02766() { hlt = 1;  }
void I02767() { lac &= 010000; lac &= 07777;  }
void I02770() { lac += core[000071];  }
void I02771() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I02772() { lac ^= 07777;  }
void I02773() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I02774() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02775() { hlt = 1;  }
void I02776() { lac &= 010000; lac &= 07777;  }
void I02777() { lac += core[000071];  }
void I03000() { lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03001() { lac += core[000071];  }
void I03002() { lac ^= 07777;  }
void I03003() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03004() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03005() { hlt = 1;  }
void I03006() { lac &= 010000; lac &= 07777;  }
void I03007() { lac ^= 010000;  }
void I03010() { lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03011() { lac ^= 07777;  }
void I03012() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03013() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03014() { hlt = 1;  }
void I03015() { lac &= 010000; lac &= 07777;  }
void I03016() { lac += core[000071];  }
void I03017() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03020() { lac ^= 07777;  }
void I03021() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03022() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03023() { hlt = 1;  }
void I03024() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03025() { lac += core[000070];  }
void I03026() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03027() { lac ^= 07777;  }
void I03030() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03031() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03032() { hlt = 1;  }
void I03033() { lac &= 010000;  }
void I03034() { lac += core[000071];  }
void I03035() { lac &= 010000; lac++;  }
void I03036() { lac += core[000052];  }
void I03037() { lac ^= 07777;  }
void I03040() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03041() { hlt = 1;  }
void I03042() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03043() { lac += core[000052];  }
void I03044() { lac &= 07777; lac++;  }
void I03045() { lac ^= 07777;  }
void I03046() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03047() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03050() { hlt = 1;  }
void I03051() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03052() { lac += core[000071];  }
void I03053() { lac &= 010000; lac &= 07777; lac++;  }
void I03054() { lac += core[000052];  }
void I03055() { lac ^= 07777;  }
void I03056() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03057() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03060() { hlt = 1;  }
void I03061() { lac &= 010000; lac &= 07777;  }
void I03062() { lac ^= 07777; lac++;  }
void I03063() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03064() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03065() { hlt = 1;  }
void I03066() { lac &= 010000; lac &= 07777;  }
void I03067() { lac += core[000071];  }
void I03070() { lac &= 010000; lac ^= 07777; lac++;  }
void I03071() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03072() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03073() { hlt = 1;  }
void I03074() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03075() { lac += core[000021];  }
void I03076() { lac &= 07777; lac ^= 07777; lac++;  }
void I03077() { lac ^= 07777;  }
void I03100() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03101() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03102() { hlt = 1;  }
void I03103() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03104() { lac += core[000071];  }
void I03105() { lac &= 010000; lac &= 07777; lac ^= 07777; lac++;  }
void I03106() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03107() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03110() { hlt = 1;  }
void I03111() { lac &= 010000; lac &= 07777;  }
void I03112() { lac += core[000070];  }
void I03113() { lac &= 010000; lac &= 07777; lac ^= 07777; lac++;  }
void I03114() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03115() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03116() { hlt = 1;  }
void I03117() { lac &= 010000; lac &= 07777;  }
void I03120() { lac += core[000052];  }
void I03121() { lac ^= 010000; lac++;  }
void I03122() { lac ^= 07777;  }
void I03123() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03124() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03125() { hlt = 1;  }
void I03126() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03127() { lac += core[000052];  }
void I03130() { lac ^= 010000; lac++;  }
void I03131() { lac ^= 07777;  }
void I03132() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03133() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03134() { hlt = 1;  }
void I03135() { lac &= 010000; lac &= 07777;  }
void I03136() { lac += core[000071];  }
void I03137() { lac &= 010000; lac ^= 010000; lac++;  }
void I03140() { lac += core[000052];  }
void I03141() { lac ^= 07777;  }
void I03142() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03143() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03144() { hlt = 1;  }
void I03145() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03146() { lac += core[000052];  }
void I03147() { lac &= 07777; lac ^= 010000; lac++;  }
void I03150() { lac ^= 07777;  }
void I03151() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03152() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03153() { hlt = 1;  }
void I03154() { lac &= 010000; lac &= 07777;  }
void I03155() { lac += core[000052];  }
void I03156() { lac &= 07777; lac ^= 010000; lac++;  }
void I03157() { lac ^= 07777;  }
void I03160() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03161() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03162() { hlt = 1;  }
void I03163() { lac &= 010000; lac &= 07777;  }
void I03164() { lac += core[000071];  }
void I03165() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++;  }
void I03166() { lac += core[000052];  }
void I03167() { lac ^= 07777;  }
void I03170() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03171() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03172() { hlt = 1;  }
void I03173() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03174() { lac += core[000071];  }
void I03175() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++;  }
void I03176() { lac += core[000052];  }
void I03177() { lac ^= 07777;  }
void I03200() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03201() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03202() { hlt = 1;  }
void I03203() { lac &= 010000; lac &= 07777;  }
void I03204() { lac += core[000021];  }
void I03205() { lac ^= 010000; lac ^= 07777; lac++;  }
void I03206() { lac ^= 07777;  }
void I03207() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03210() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03211() { hlt = 1;  }
void I03212() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03213() { lac += core[000021];  }
void I03214() { lac ^= 010000; lac ^= 07777; lac++;  }
void I03215() { lac ^= 07777;  }
void I03216() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03217() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03220() { hlt = 1;  }
void I03221() { lac &= 010000; lac &= 07777;  }
void I03222() { lac += core[000071];  }
void I03223() { lac &= 010000; lac ^= 010000; lac ^= 07777; lac++;  }
void I03224() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03225() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03226() { hlt = 1;  }
void I03227() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03230() { lac += core[000071];  }
void I03231() { lac &= 010000; lac ^= 010000; lac ^= 07777; lac++;  }
void I03232() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03233() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03234() { hlt = 1;  }
void I03235() { lac &= 010000; lac &= 07777;  }
void I03236() { lac += core[000021];  }
void I03237() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++;  }
void I03240() { lac ^= 07777;  }
void I03241() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03242() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03243() { hlt = 1;  }
void I03244() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03245() { lac += core[000021];  }
void I03246() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++;  }
void I03247() { lac ^= 07777;  }
void I03250() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03251() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03252() { hlt = 1;  }
void I03253() { lac &= 010000; lac &= 07777;  }
void I03254() { lac += core[000071];  }
void I03255() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++;  }
void I03256() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03257() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03260() { hlt = 1;  }
void I03261() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03262() { lac &= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03263() { lac += core[000066];  }
void I03264() { lac ^= 07777;  }
void I03265() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03266() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03267() { hlt = 1;  }
void I03270() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03271() { lac &= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03272() { lac += core[000052];  }
void I03273() { lac ^= 07777;  }
void I03274() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03275() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03276() { hlt = 1;  }
void I03277() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03300() { lac &= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03301() { lac += core[000065];  }
void I03302() { lac ^= 07777;  }
void I03303() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03304() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03305() { hlt = 1;  }
void I03306() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03307() { lac &= 010000; lac = (lac<<2) + ((lac>>11)&3);  }
void I03310() { lac += core[000053];  }
void I03311() { lac ^= 07777;  }
void I03312() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03313() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03314() { hlt = 1;  }
void I03315() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03316() { lac += core[000032];  }
void I03317() { lac &= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03320() { lac += core[000056];  }
void I03321() { lac ^= 07777;  }
void I03322() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03323() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03324() { hlt = 1;  }
void I03325() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03326() { lac += core[000032];  }
void I03327() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I03330() { lac += core[000061];  }
void I03331() { lac ^= 07777;  }
void I03332() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03333() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03334() { hlt = 1;  }
void I03335() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03336() { lac += core[000032];  }
void I03337() { lac &= 07777; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03340() { lac += core[000055];  }
void I03341() { lac ^= 07777;  }
void I03342() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03343() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03344() { hlt = 1;  }
void I03345() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03346() { lac += core[000032];  }
void I03347() { lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I03350() { lac += core[000062];  }
void I03351() { lac ^= 07777;  }
void I03352() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03353() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03354() { hlt = 1;  }
void I03355() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03356() { lac &= 010000; lac &= 07777; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03357() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03360() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03361() { hlt = 1;  }
void I03362() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03363() { lac &= 010000; lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I03364() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03365() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03366() { hlt = 1;  }
void I03367() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03370() { lac &= 010000; lac &= 07777; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03371() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03372() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03373() { hlt = 1;  }
void I03374() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I03375() { lac &= 010000; lac &= 07777; lac = (lac<<2) + ((lac>>11)&3);  }
void I03376() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03377() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03400() { hlt = 1;  }
void I03401() { lac &= 010000; lac &= 07777;  }
void I03402() { lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03403() { lac += core[000066];  }
void I03404() { lac ^= 07777;  }
void I03405() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03406() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03407() { hlt = 1;  }
void I03410() { lac &= 010000; lac &= 07777;  }
void I03411() { lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03412() { lac += core[000052];  }
void I03413() { lac ^= 07777;  }
void I03414() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03415() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03416() { hlt = 1;  }
void I03417() { lac &= 010000; lac &= 07777;  }
void I03420() { lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03421() { lac += core[000065];  }
void I03422() { lac ^= 07777;  }
void I03423() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03424() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03425() { hlt = 1;  }
void I03426() { lac &= 010000; lac &= 07777;  }
void I03427() { lac ^= 010000; lac = (lac<<2) + ((lac>>11)&3);  }
void I03430() { lac += core[000053];  }
void I03431() { lac ^= 07777;  }
void I03432() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03433() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03434() { hlt = 1;  }
void I03435() { lac &= 010000; lac &= 07777;  }
void I03436() { lac += core[000070];  }
void I03437() { lac &= 010000; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03440() { lac += core[000066];  }
void I03441() { lac ^= 07777;  }
void I03442() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03443() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03444() { hlt = 1;  }
void I03445() { lac &= 010000; lac &= 07777;  }
void I03446() { lac += core[000070];  }
void I03447() { lac &= 010000; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03450() { lac += core[000052];  }
void I03451() { lac ^= 07777;  }
void I03452() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03453() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03454() { hlt = 1;  }
void I03455() { lac &= 010000; lac &= 07777;  }
void I03456() { lac += core[000070];  }
void I03457() { lac &= 010000; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03460() { lac += core[000065];  }
void I03461() { lac ^= 07777;  }
void I03462() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03463() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03464() { hlt = 1;  }
void I03465() { lac &= 010000; lac &= 07777;  }
void I03466() { lac += core[000070];  }
void I03467() { lac &= 010000; lac ^= 010000; lac = (lac<<2) + ((lac>>11)&3);  }
void I03470() { lac += core[000053];  }
void I03471() { lac ^= 07777;  }
void I03472() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03473() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03474() { hlt = 1;  }
void I03475() { lac &= 010000; lac &= 07777;  }
void I03476() { lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03477() { lac = (lac<<1) + ((lac>>12)&1);  }
void I03500() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03501() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03502() { hlt = 1;  }
void I03503() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03504() { lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03505() { lac = (lac<<1) + ((lac>>12)&1);  }
void I03506() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03507() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03510() { hlt = 1;  }
void I03511() { lac &= 010000; lac &= 07777;  }
void I03512() { lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03513() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03514() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03515() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03516() { hlt = 1;  }
void I03517() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03520() { lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03521() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03522() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03523() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03524() { hlt = 1;  }
void I03525() { lac &= 010000; lac &= 07777;  }
void I03526() { lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03527() { lac = (lac<<2) + ((lac>>11)&3);  }
void I03530() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03531() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03532() { hlt = 1;  }
void I03533() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03534() { lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03535() { lac = (lac<<2) + ((lac>>11)&3);  }
void I03536() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03537() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03540() { hlt = 1;  }
void I03541() { lac &= 010000; lac &= 07777;  }
void I03542() { lac &= 07777; lac ^= 010000; lac = (lac<<2) + ((lac>>11)&3);  }
void I03543() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03544() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03545() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03546() { hlt = 1;  }
void I03547() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03550() { lac &= 07777; lac ^= 010000; lac = (lac<<2) + ((lac>>11)&3);  }
void I03551() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03552() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03553() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03554() { hlt = 1;  }
void I03555() { lac &= 010000; lac &= 07777;  }
void I03556() { lac += core[000070];  }
void I03557() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03560() { lac = (lac<<1) + ((lac>>12)&1);  }
void I03561() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03562() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03563() { hlt = 1;  }
void I03564() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03565() { lac += core[000071];  }
void I03566() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03567() { lac = (lac<<1) + ((lac>>12)&1);  }
void I03570() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03571() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03572() { hlt = 1;  }
void I03573() { lac &= 010000; lac &= 07777;  }
void I03574() { lac += core[000071];  }
void I03575() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03576() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03577() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03600() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03601() { hlt = 1;  }
void I03602() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03603() { lac += core[000070];  }
void I03604() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<1) + ((lac>>12)&1);  }
void I03605() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I03606() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03607() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03610() { hlt = 1;  }
void I03611() { lac &= 010000; lac &= 07777;  }
void I03612() { lac += core[000071];  }
void I03613() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03614() { lac = (lac<<2) + ((lac>>11)&3);  }
void I03615() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03616() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03617() { hlt = 1;  }
void I03620() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03621() { lac += core[000070];  }
void I03622() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03623() { lac = (lac<<2) + ((lac>>11)&3);  }
void I03624() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03625() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03626() { hlt = 1;  }
void I03627() { lac &= 010000; lac &= 07777;  }
void I03630() { lac += core[000071];  }
void I03631() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<2) + ((lac>>11)&3);  }
void I03632() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03633() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03634() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03635() { hlt = 1;  }
void I03636() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I03637() { lac += core[000070];  }
void I03640() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = (lac<<2) + ((lac>>11)&3);  }
void I03641() { lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I03642() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I03643() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03644() { hlt = 1;  }
void I03645() { lac &= 010000; lac &= 07777;  }
void I03646() { lac += core[000067];  }
void I03647() { lac ^= 07777; lac++;  }
void I03650() { lac += core[000052];  }
void I03651() { lac ^= 07777;  }
void I03652() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03653() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03654() { hlt = 1;  }
void I03655() { lac &= 010000; lac &= 07777;  }
void I03656() { lac += core[000052];  }
void I03657() { lac ^= 07777; lac++;  }
void I03660() { lac += core[000053];  }
void I03661() { lac ^= 07777;  }
void I03662() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03663() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03664() { hlt = 1;  }
void I03665() { lac &= 010000; lac &= 07777;  }
void I03666() { lac += core[000101];  }
void I03667() { lac ^= 07777; lac++;  }
void I03670() { lac += core[000054];  }
void I03671() { lac ^= 07777;  }
void I03672() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03673() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03674() { hlt = 1;  }
void I03675() { lac &= 010000; lac &= 07777;  }
void I03676() { lac += core[000100];  }
void I03677() { lac ^= 07777; lac++;  }
void I03700() { lac += core[000055];  }
void I03701() { lac ^= 07777;  }
void I03702() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03703() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03704() { hlt = 1;  }
void I03705() { lac &= 010000; lac &= 07777;  }
void I03706() { lac += core[000077];  }
void I03707() { lac ^= 07777; lac++;  }
void I03710() { lac += core[000056];  }
void I03711() { lac ^= 07777;  }
void I03712() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03713() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03714() { hlt = 1;  }
void I03715() { lac &= 010000; lac &= 07777;  }
void I03716() { lac += core[000076];  }
void I03717() { lac ^= 07777; lac++;  }
void I03720() { lac += core[000057];  }
void I03721() { lac ^= 07777;  }
void I03722() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03723() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03724() { hlt = 1;  }
void I03725() { lac &= 010000; lac &= 07777;  }
void I03726() { lac += core[000113];  }
void I03727() { lac ^= 07777; lac++;  }
void I03730() { lac += core[000061];  }
void I03731() { lac ^= 07777;  }
void I03732() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03733() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03734() { hlt = 1;  }
void I03735() { lac &= 010000; lac &= 07777;  }
void I03736() { lac += core[000075];  }
void I03737() { lac ^= 07777; lac++;  }
void I03740() { lac += core[000062];  }
void I03741() { lac ^= 07777;  }
void I03742() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03743() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03744() { hlt = 1;  }
void I03745() { lac &= 010000; lac &= 07777;  }
void I03746() { lac += core[000074];  }
void I03747() { lac ^= 07777; lac++;  }
void I03750() { lac += core[000063];  }
void I03751() { lac ^= 07777;  }
void I03752() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03753() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03754() { hlt = 1;  }
void I03755() { lac &= 010000; lac &= 07777;  }
void I03756() { lac += core[000073];  }
void I03757() { lac ^= 07777; lac++;  }
void I03760() { lac += core[000064];  }
void I03761() { lac ^= 07777;  }
void I03762() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03763() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03764() { hlt = 1;  }
void I03765() { lac &= 010000; lac &= 07777;  }
void I03766() { lac += core[000072];  }
void I03767() { lac ^= 07777; lac++;  }
void I03770() { lac += core[000065];  }
void I03771() { lac ^= 07777;  }
void I03772() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I03773() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03774() { hlt = 1;  }
void I03775() { lac &= 010000; lac &= 07777;  }
void I03776() { lac += core[000050];  }
void I03777() { lac ^= 07777; lac++;  }
void I04000() { lac += core[000066];  }
void I04001() { lac ^= 07777;  }
void I04002() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04003() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04004() { hlt = 1;  }
void I04005() { lac &= 010000; lac &= 07777;  }
void I04006() { lac += core[000020];  }
void I04007() { lac ^= 07777; lac++;  }
void I04010() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I04011() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04012() { hlt = 1;  }
void I04013() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I04014() { lac &= 010000; lac &= 07777; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04015() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04016() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04017() { hlt = 1;  }
void I04020() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04021() { lac &= 010000; lac &= 07777; lac++; lac = (lac<<1) + ((lac>>12)&1);  }
void I04022() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04023() { hlt = 1;  }
void I04024() { lac ^= 07777; lac++;  }
void I04025() { lac += core[000022];  }
void I04026() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04027() { hlt = 1;  }
void I04030() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04031() { lac &= 010000; lac &= 07777; lac++; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04032() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04033() { hlt = 1;  }
void I04034() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I04035() { hlt = 1;  }
void I04036() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04037() { lac &= 010000; lac &= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3);  }
void I04040() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04041() { hlt = 1;  }
void I04042() { lac ^= 07777; lac++;  }
void I04043() { lac += core[000024];  }
void I04044() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04045() { hlt = 1;  }
void I04046() { lac &= 010000; lac &= 07777;  }
void I04047() { lac &= 010000; lac &= 07777; lac ^= 010000; lac++; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I04050() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04051() { hlt = 1;  }
void I04052() { lac &= 010000; lac &= 07777;  }
void I04053() { lac &= 010000; lac &= 07777; lac ^= 07777; lac++; lac = (lac<<1) + ((lac>>12)&1);  }
void I04054() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04055() { hlt = 1;  }
void I04056() { lac ^= 07777; lac++;  }
void I04057() { lac += core[000021];  }
void I04060() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04061() { hlt = 1;  }
void I04062() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04063() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04064() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04065() { hlt = 1;  }
void I04066() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04067() { hlt = 1;  }
void I04070() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04071() { lac = (lac<<2) + ((lac>>11)&3);  }
void I04072() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04073() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04074() { hlt = 1;  }
void I04075() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04076() { lac &= 010000; lac &= 07777; lac ^= 07777; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I04077() { lac ^= 07777;  }
void I04100() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04101() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04102() { hlt = 1;  }
void I04103() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04104() { lac &= 010000; lac &= 07777; lac++; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I04105() { lac += core[000061];  }
void I04106() { lac ^= 07777;  }
void I04107() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04110() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04111() { hlt = 1;  }
void I04112() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04113() { lac &= 010000; lac &= 07777; lac ^= 07777; lac++; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I04114() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04115() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04116() { hlt = 1;  }
void I04117() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04120() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I04121() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04122() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04123() { hlt = 1;  }
void I04124() { lac &= 010000; lac &= 07777;  }
void I04125() { lac += core[000043];  }
void I04126() { lac ^= 010000; lac ^= 07777; lac++; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I04127() { lac += core[000047];  }
void I04130() { lac ^= 07777;  }
void I04131() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04132() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04133() { hlt = 1;  }
void I04134() { lac &= 010000; lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void I04135() { lac ^= 010000; lac ^= 07777; lac++; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void I04136() { lac += core[000051];  }
void I04137() { lac ^= 07777;  }
void I04140() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04141() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04142() { hlt = 1;  }
void I04143() { lac &= 010000; lac ^= 07777;  }
void I04144() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I04145() { hlt = 1;  }
void I04146() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04147() { hlt = 1;  }
void I04150() { lac &= 010000; lac ^= 07777;  }
void I04151() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I04152() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04153() { hlt = 1;  }
void I04154() { lac &= 010000; lac ^= 07777;  }
void I04155() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp;  }
void I04156() { hlt = 1;  }
void I04157() { lac &= 010000;  }
void I04160() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp;  }
void I04161() { hlt = 1;  }
void I04162() { lac &= 010000;  }
void I04163() { lac += core[000066];  }
void I04164() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp;  }
void I04165() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I04166() { hlt = 1;  }
void I04167() { lac &= 010000; lac ^= 07777;  }
void I04170() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I04171() { hlt = 1;  }
void I04172() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04173() { hlt = 1;  }
void I04174() { lac &= 010000;  }
void I04175() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I04176() { hlt = 1;  }
void I04177() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04200() { hlt = 1;  }
void I04201() { lac &= 010000;  }
void I04202() { lac += core[000066];  }
void I04203() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I04204() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04205() { hlt = 1;  }
void I04206() { lac &= 010000; lac &= 07777;  }
void I04207() { lac += core[000070];  }
void I04210() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04211() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04212() { hlt = 1;  }
void I04213() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04214() { lac += core[000071];  }
void I04215() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04216() { hlt = 1;  }
void I04217() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04220() { hlt = 1;  }
void I04221() { lac &= 010000; lac &= 07777;  }
void I04222() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04223() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04224() { hlt = 1;  }
void I04225() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04226() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04227() { hlt = 1;  }
void I04230() { lac &= 010000; lac &= 07777;  }
void I04231() { lac += core[000050];  }
void I04232() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04233() { hlt = 1;  }
void I04234() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04235() { lac += core[000050];  }
void I04236() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04237() { hlt = 1;  }
void I04240() { lac &= 010000; lac &= 07777;  }
void I04241() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04242() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04243() { hlt = 1;  }
void I04244() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04245() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04246() { hlt = 1;  }
void I04247() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04250() { hlt = 1;  }
void I04251() { lac &= 010000; lac &= 07777;  }
void I04252() { lac += core[000050];  }
void I04253() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04254() { hlt = 1;  }
void I04255() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04256() { hlt = 1;  }
void I04257() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04260() { lac += core[000050];  }
void I04261() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04262() { hlt = 1;  }
void I04263() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04264() { hlt = 1;  }
void I04265() { lac &= 010000; lac &= 07777;  }
void I04266() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04267() { hlt = 1;  }
void I04270() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04271() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04272() { hlt = 1;  }
void I04273() { lac &= 010000; lac &= 07777;  }
void I04274() { lac += core[000040];  }
void I04275() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04276() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I04277() { hlt = 1;  }
void I04300() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04301() { lac += core[000032];  }
void I04302() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04303() { hlt = 1;  }
void I04304() { lac &= 010000; lac &= 07777;  }
void I04305() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04306() { hlt = 1;  }
void I04307() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04310() { hlt = 1;  }
void I04311() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04312() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04313() { hlt = 1;  }
void I04314() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04315() { hlt = 1;  }
void I04316() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04317() { lac += core[000036];  }
void I04320() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04321() { hlt = 1;  }
void I04322() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04323() { hlt = 1;  }
void I04324() { lac &= 010000; lac &= 07777;  }
void I04325() { lac += core[000045];  }
void I04326() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04327() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04330() { hlt = 1;  }
void I04331() { lac &= 010000; lac &= 07777;  }
void I04332() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04333() { hlt = 1;  }
void I04334() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04335() { lac += core[000066];  }
void I04336() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04337() { hlt = 1;  }
void I04340() { lac &= 010000; lac &= 07777;  }
void I04341() { lac += core[000050];  }
void I04342() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04343() { hlt = 1;  }
void I04344() { lac &= 010000; lac &= 07777;  }
void I04345() { lac += core[000066];  }
void I04346() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp;  }
void I04347() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I04350() { hlt = 1;  }
void I04351() { lac &= 010000; lac &= 07777;  }
void I04352() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04353() { hlt = 1;  }
void I04354() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04355() { hlt = 1;  }
void I04356() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04357() { lac += core[000066];  }
void I04360() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04361() { hlt = 1;  }
void I04362() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04363() { hlt = 1;  }
void I04364() { lac &= 010000; lac &= 07777;  }
void I04365() { lac += core[000050];  }
void I04366() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04367() { hlt = 1;  }
void I04370() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04371() { hlt = 1;  }
void I04372() { lac &= 010000; lac &= 07777;  }
void I04373() { lac += core[000066];  }
void I04374() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I04375() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04376() { hlt = 1;  }
void I04377() { lac &= 010000; lac &= 07777;  }
void I04400() { skp = 0; skp = !skp; npc += skp;  }
void I04401() { hlt = 1;  }
void I04402() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04403() { skp = 0; skp = !skp; npc += skp;  }
void I04404() { hlt = 1;  }
void I04405() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04406() { lac += core[000066];  }
void I04407() { skp = 0; skp = !skp; npc += skp;  }
void I04410() { hlt = 1;  }
void I04411() { lac &= 010000; lac &= 07777;  }
void I04412() { lac += core[000066];  }
void I04413() { skp = 0; skp = !skp; npc += skp;  }
void I04414() { hlt = 1;  }
void I04415() { lac &= 010000;  }
void I04416() { lac += core[000066];  }
void I04417() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04420() { hlt = 1;  }
void I04421() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04422() { hlt = 1;  }
void I04423() { lac &= 010000;  }
void I04424() { lac += core[000050];  }
void I04425() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04426() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04427() { hlt = 1;  }
void I04430() { lac &= 010000; lac ^= 07777;  }
void I04431() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04432() { hlt = 1;  }
void I04433() { lac &= 010000;  }
void I04434() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04435() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04436() { hlt = 1;  }
void I04437() { lac &= 010000;  }
void I04440() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I04441() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04442() { hlt = 1;  }
void I04443() { lac &= 010000;  }
void I04444() { lac += core[000066];  }
void I04445() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I04446() { hlt = 1;  }
void I04447() { lac &= 010000;  }
void I04450() { lac += core[000050];  }
void I04451() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp;  }
void I04452() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I04453() { hlt = 1;  }
void I04454() { lac &= 010000;  }
void I04455() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04456() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04457() { hlt = 1;  }
void I04460() { lac &= 010000;  }
void I04461() { lac += core[000066];  }
void I04462() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04463() { hlt = 1;  }
void I04464() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04465() { hlt = 1;  }
void I04466() { lac &= 010000;  }
void I04467() { lac += core[000050];  }
void I04470() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04471() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04472() { hlt = 1;  }
void I04473() { lac &= 010000; lac &= 07777;  }
void I04474() { lac += core[000070];  }
void I04475() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04476() { hlt = 1;  }
void I04477() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04500() { hlt = 1;  }
void I04501() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04502() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04503() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04504() { hlt = 1;  }
void I04505() { lac &= 010000; lac &= 07777;  }
void I04506() { lac += core[000066];  }
void I04507() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04510() { hlt = 1;  }
void I04511() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04512() { lac += core[000066];  }
void I04513() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04514() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I04515() { hlt = 1;  }
void I04516() { lac &= 010000; lac &= 07777;  }
void I04517() { lac += core[000050];  }
void I04520() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04521() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I04522() { hlt = 1;  }
void I04523() { lac &= 010000; lac &= 07777;  }
void I04524() { lac += core[000066];  }
void I04525() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04526() { hlt = 1;  }
void I04527() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04530() { hlt = 1;  }
void I04531() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04532() { lac += core[000066];  }
void I04533() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04534() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04535() { hlt = 1;  }
void I04536() { lac &= 010000; lac &= 07777;  }
void I04537() { lac += core[000050];  }
void I04540() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04541() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04542() { hlt = 1;  }
void I04543() { lac &= 010000; lac &= 07777;  }
void I04544() { lac += core[000050];  }
void I04545() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04546() { hlt = 1;  }
void I04547() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04550() { lac += core[000050];  }
void I04551() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04552() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04553() { hlt = 1;  }
void I04554() { lac &= 010000; lac &= 07777;  }
void I04555() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04556() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04557() { hlt = 1;  }
void I04560() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04561() { lac += core[000050];  }
void I04562() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04563() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04564() { hlt = 1;  }
void I04565() { lac &= 010000; lac &= 07777;  }
void I04566() { lac += core[000050];  }
void I04567() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04570() { hlt = 1;  }
void I04571() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04572() { hlt = 1;  }
void I04573() { lac &= 010000; lac &= 07777;  }
void I04574() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04575() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04576() { hlt = 1;  }
void I04577() { lac &= 010000; lac &= 07777;  }
void I04600() { lac += core[000066];  }
void I04601() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04602() { hlt = 1;  }
void I04603() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04604() { lac += core[000066];  }
void I04605() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04606() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04607() { hlt = 1;  }
void I04610() { lac &= 010000; lac &= 07777;  }
void I04611() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04612() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04613() { hlt = 1;  }
void I04614() { lac &= 010000; lac &= 07777;  }
void I04615() { lac += core[000050];  }
void I04616() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04617() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04620() { hlt = 1;  }
void I04621() { lac &= 010000; lac &= 07777;  }
void I04622() { lac += core[000066];  }
void I04623() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04624() { hlt = 1;  }
void I04625() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04626() { hlt = 1;  }
void I04627() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04630() { lac += core[000066];  }
void I04631() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04632() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04633() { hlt = 1;  }
void I04634() { lac &= 010000; lac &= 07777;  }
void I04635() { lac += core[000050];  }
void I04636() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04637() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04640() { hlt = 1;  }
void I04641() { lac &= 010000; lac &= 07777;  }
void I04642() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I04643() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04644() { hlt = 1;  }
void I04645() { lac &= 010000;  }
void I04646() { lac += core[000070];  }
void I04647() { lac &= 010000; lac |= swr;  }
void I04650() { lac ^= 07777;  }
void I04651() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04652() { hlt = 1;  }
void I04653() { lac &= 010000;  }
void I04654() { lac += core[000050];  }
void I04655() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac |= swr;  }
void I04656() { hlt = 1;  }
void I04657() { lac ^= 07777;  }
void I04660() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04661() { hlt = 1;  }
void I04662() { lac &= 010000;  }
void I04663() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac |= swr;  }
void I04664() { hlt = 1;  }
void I04665() { lac ^= 07777;  }
void I04666() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04667() { hlt = 1;  }
void I04670() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I04671() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac |= swr;  }
void I04672() { hlt = 1;  }
void I04673() { lac ^= 07777;  }
void I04674() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04675() { hlt = 1;  }
void I04676() { lac &= 010000; lac &= 07777;  }
void I04677() { lac += core[000066];  }
void I04700() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void I04701() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I04702() { hlt = 1;  }
void I04703() { lac ^= 07777;  }
void I04704() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04705() { hlt = 1;  }
void I04706() { lac &= 010000;  }
void I04707() { skp = 0; skp = !skp; npc += skp; lac |= swr;  }
void I04710() { hlt = 1;  }
void I04711() { lac ^= 07777;  }
void I04712() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04713() { hlt = 1;  }
void I04714() { lac &= 010000;  }
void I04715() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac |= swr;  }
void I04716() { hlt = 1;  }
void I04717() { lac ^= 07777;  }
void I04720() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04721() { hlt = 1;  }
void I04722() { lac &= 010000;  }
void I04723() { lac += core[000040];  }
void I04724() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac |= swr;  }
void I04725() { hlt = 1;  }
void I04726() { lac ^= 07777;  }
void I04727() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04730() { hlt = 1;  }
void I04731() { lac &= 010000; lac &= 07777;  }
void I04732() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac |= swr;  }
void I04733() { hlt = 1;  }
void I04734() { lac ^= 07777;  }
void I04735() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04736() { hlt = 1;  }
void I04737() { lac &= 010000; lac &= 07777;  }
void I04740() { lac += core[000066];  }
void I04741() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I04742() { hlt = 1;  }
void I04743() { lac ^= 07777;  }
void I04744() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04745() { hlt = 1;  }
void I04746() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04747() { emul8();  }
void I04750() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04751() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04752() { hlt = 1;  }
void I04753() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04754() { emul8();  }
void I04755() { lac ^= 07777;  }
void I04756() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04757() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04760() { hlt = 1;  }
void I04761() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I04762() { emul8();  }
void I04763() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I04764() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04765() { hlt = 1;  }
void I04766() { lac &= 010000; lac &= 07777;  }
void I04767() { emul8();  }
void I04770() { lac ^= 07777;  }
void I04771() { emul8();  }
void I04772() { lac ^= 07777;  }
void I04773() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I04774() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04775() { hlt = 1;  }
void I04776() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I04777() { emul8();  }
void I05000() { emul8();  }
void I05001() { lac ^= 07777;  }
void I05002() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I05003() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05004() { hlt = 1;  }
void I05005() { emul8();  }
void I05006() { lac += core[000070];  }
void I05007() { emul8();  }
void I05010() { lac += core[000071];  }
void I05011() { emul8();  }
void I05012() { lac ^= 07777;  }
void I05013() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05014() { hlt = 1;  }
void I05015() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void I05016() { emul8();  }
void I05017() { lac ^= 07777;  }
void I05020() { emul8();  }
void I05021() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05022() { hlt = 1;  }
void I05023() { emul8();  }
void I05024() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I05025() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05026() { hlt = 1;  }
void I05027() { emul8();  }
void I05030() { emul8();  }
void I05031() { lac ^= 07777;  }
void I05032() { emul8();  }
void I05033() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05034() { hlt = 1;  }
void I05035() { emul8();  }
void I05036() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05037() { hlt = 1;  }
void I05040() { lac &= 010000; lac ^= 07777;  }
void I05041() { emul8();  }
void I05042() { emul8();  }
void I05043() { lac ^= 07777;  }
void I05044() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05045() { hlt = 1;  }
void I05046() { emul8();  }
void I05047() { lac ^= 07777;  }
void I05050() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05051() { hlt = 1;  }
void I05052() { emul8();  }
void I05053() { lac += core[000070];  }
void I05054() { emul8();  }
void I05055() { lac += core[000071];  }
void I05056() { emul8();  }
void I05057() { lac += core[000071];  }
void I05060() { lac ^= 07777;  }
void I05061() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05062() { hlt = 1;  }
void I05063() { emul8();  }
void I05064() { lac += core[000071];  }
void I05065() { lac ^= 07777;  }
void I05066() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05067() { hlt = 1;  }
void I05070() { emul8();  }
void I05071() { lac += core[000071];  }
void I05072() { emul8();  }
void I05073() { lac += core[000070];  }
void I05074() { emul8();  }
void I05075() { lac += core[000070];  }
void I05076() { lac ^= 07777;  }
void I05077() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05100() { hlt = 1;  }
void I05101() { emul8();  }
void I05102() { lac += core[000070];  }
void I05103() { lac ^= 07777;  }
void I05104() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05105() { hlt = 1;  }
void I05106() { emul8();  }
void I05107() { lac ^= 07777;  }
void I05110() { emul8();  }
void I05111() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05112() { hlt = 1;  }
void I05113() { emul8();  }
void I05114() { lac ^= 07777;  }
void I05115() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05116() { hlt = 1;  }
void I05117() { emul8();  }
void I05120() { lac ^= 07777;  }
void I05121() { emul8();  }
void I05122() { emul8();  }
void I05123() { lac ^= 07777;  }
void I05124() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05125() { hlt = 1;  }
void I05126() { emul8();  }
void I05127() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05130() { hlt = 1;  }
void I05131() { emul8();  }
void I05132() { lac += core[000070];  }
void I05133() { emul8();  }
void I05134() { lac += core[000071];  }
void I05135() { emul8();  }
void I05136() { lac += core[000071];  }
void I05137() { lac ^= 07777;  }
void I05140() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05141() { hlt = 1;  }
void I05142() { emul8();  }
void I05143() { lac += core[000070];  }
void I05144() { lac ^= 07777;  }
void I05145() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05146() { hlt = 1;  }
void I05147() { emul8();  }
void I05150() { lac += core[000071];  }
void I05151() { emul8();  }
void I05152() { lac += core[000070];  }
void I05153() { emul8();  }
void I05154() { lac += core[000070];  }
void I05155() { lac ^= 07777;  }
void I05156() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05157() { hlt = 1;  }
void I05160() { emul8();  }
void I05161() { lac += core[000071];  }
void I05162() { lac ^= 07777;  }
void I05163() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05164() { hlt = 1;  }
void I05165() { emul8();  }
void I05166() { lac ^= 07777;  }
void I05167() { emul8();  }
void I05170() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05171() { hlt = 1;  }
void I05172() { emul8();  }
void I05173() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05174() { hlt = 1;  }
void I05175() { emul8();  }
void I05176() { lac ^= 07777;  }
void I05177() { emul8();  }
void I05200() { emul8();  }
void I05201() { lac ^= 07777;  }
void I05202() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05203() { hlt = 1;  }
void I05204() { emul8();  }
void I05205() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05206() { hlt = 1;  }
void I05207() { emul8();  }
void I05210() { lac += core[000071];  }
void I05211() { emul8();  }
void I05212() { lac += core[000070];  }
void I05213() { emul8();  }
void I05214() { lac += core[000070];  }
void I05215() { lac ^= 07777;  }
void I05216() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05217() { hlt = 1;  }
void I05220() { emul8();  }
void I05221() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05222() { hlt = 1;  }
void I05223() { lac &= 010000;  }
void I05224() { lac &= (010000|core[000067]);  }
void I05225() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05226() { hlt = 1;  }
void I05227() { lac &= 010000; lac ^= 07777;  }
void I05230() { lac &= (010000|core[000020]);  }
void I05231() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05232() { hlt = 1;  }
void I05233() { lac &= 010000; lac &= 07777; lac ^= 010000;  }
void I05234() { lac += core[000067];  }
void I05235() { lac &= (010000|core[000067]);  }
void I05236() { lac ^= 07777;  }
void I05237() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I05240() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05241() { hlt = 1;  }
void I05242() { lac &= 010000; lac &= 07777;  }
void I05243() { lac += core[000071];  }
void I05244() { lac &= (010000|core[000070]);  }
void I05245() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I05246() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05247() { hlt = 1;  }
void I05250() { lac &= 010000; lac &= 07777;  }
void I05251() { lac += core[000070];  }
void I05252() { lac &= (010000|core[000071]);  }
void I05253() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I05254() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05255() { hlt = 1;  }
void I05256() { lac &= 010000; lac &= 07777;  }
void I05257() { lac += core[000052];  }
void I05260() { lac &= (010000|core[000070]);  }
void I05261() { lac ^= 07777; lac++;  }
void I05262() { lac += core[000070];  }
void I05263() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I05264() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05265() { hlt = 1;  }
void I05266() { lac &= 010000; lac &= 07777;  }
void I05267() { lac += core[000071];  }
void I05270() { lac &= (010000|core[000071]);  }
void I05271() { lac ^= 07777; lac++;  }
void I05272() { lac += core[000071];  }
void I05273() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I05274() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05275() { hlt = 1;  }
void I05276() { lac &= 010000;  }
void I05277() { lac += core[000121];  }
void I05300() { lac++;  }
void I05301() { core[000121] = lac & 07777; lac &= 010000; code[000121] = &emul8;  }
void I05302() { lac += core[000121];  }
void I05303() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I05304() { npc = 000147; inh = 0;  }
void I05305() { lac += core[000122];  }
void I05306() { core[000121] = lac & 07777; lac &= 010000; code[000121] = &emul8;  }
void I05307() { lac += core[000120];  }
void I05310() { emul8();  }
void L05311() { emul8();  }
void I05312() { npc = 005311; inh = 0;  }
void I05313() { emul8();  }
void I05314() { npc = 000147; inh = 0;  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &L00001;
  core[000002] = 00002; code[000002] = &D00002;
  core[000003] = 00003; code[000003] = &D00003;
  core[000004] = 00000; code[000004] = &D00004;
  core[000005] = 00000; code[000005] = &I00005;
  core[000006] = 07402; code[000006] = &D00006;
  core[000007] = 07000; code[000007] = &D00007;
  core[000010] = 00000; code[000010] = &D00010;
  core[000020] = 00000; code[000020] = &D00020;
  core[000021] = 00001; code[000021] = &D00021;
  core[000022] = 00002; code[000022] = &D00022;
  core[000023] = 00003; code[000023] = &D00023;
  core[000024] = 00004; code[000024] = &D00024;
  core[000025] = 00006; code[000025] = &L00025;
  core[000026] = 00010; code[000026] = &D00026;
  core[000027] = 00014; code[000027] = &D00027;
  core[000030] = 00020; code[000030] = &D00030;
  core[000031] = 00030; code[000031] = &D00031;
  core[000032] = 00040; code[000032] = &D00032;
  core[000033] = 00060; code[000033] = &D00033;
  core[000034] = 00100; code[000034] = &D00034;
  core[000035] = 00140; code[000035] = &D00035;
  core[000036] = 00200; code[000036] = &D00036;
  core[000037] = 00300; code[000037] = &D00037;
  core[000040] = 00400; code[000040] = &D00040;
  core[000041] = 00600; code[000041] = &D00041;
  core[000042] = 01000; code[000042] = &D00042;
  core[000043] = 01234; code[000043] = &D00043;
  core[000044] = 01400; code[000044] = &D00044;
  core[000045] = 02000; code[000045] = &D00045;
  core[000046] = 03000; code[000046] = &D00046;
  core[000047] = 03312; code[000047] = &D00047;
  core[000050] = 04000; code[000050] = &D00050;
  core[000051] = 07717; code[000051] = &D00051;
  core[000052] = 07776; code[000052] = &L00052;
  core[000053] = 07775; code[000053] = &D00053;
  core[000054] = 07773; code[000054] = &D00054;
  core[000055] = 07767; code[000055] = &D00055;
  core[000056] = 07757; code[000056] = &D00056;
  core[000057] = 07737; code[000057] = &D00057;
  core[000060] = 07177; code[000060] = &D00060;
  core[000061] = 07677; code[000061] = &D00061;
  core[000062] = 07577; code[000062] = &D00062;
  core[000063] = 07377; code[000063] = &D00063;
  core[000064] = 06777; code[000064] = &D00064;
  core[000065] = 05777; code[000065] = &D00065;
  core[000066] = 03777; code[000066] = &D00066;
  core[000067] = 07777; code[000067] = &D00067;
  core[000070] = 05252; code[000070] = &D00070;
  core[000071] = 02525; code[000071] = &D00071;
  core[000072] = 06000; code[000072] = &D00072;
  core[000073] = 07000; code[000073] = &D00073;
  core[000074] = 07400; code[000074] = &D00074;
  core[000075] = 07600; code[000075] = &D00075;
  core[000076] = 07740; code[000076] = &D00076;
  core[000077] = 07760; code[000077] = &D00077;
  core[000100] = 07770; code[000100] = &D00100;
  core[000101] = 07774; code[000101] = &D00101;
  core[000102] = 00007; code[000102] = &D00102;
  core[000103] = 00067; code[000103] = &I00103;
  core[000104] = 00017; code[000104] = &I00104;
  core[000105] = 00037; code[000105] = &D00105;
  core[000106] = 00077; code[000106] = &D00106;
  core[000107] = 00177; code[000107] = &I00107;
  core[000110] = 00377; code[000110] = &D00110;
  core[000111] = 00777; code[000111] = &D00111;
  core[000112] = 01777; code[000112] = &D00112;
  core[000113] = 07700; code[000113] = &D00113;
  core[000114] = 05225; code[000114] = &D00114;
  core[000115] = 02552; code[000115] = &D00115;
  core[000116] = 00770; code[000116] = &D00116;
  core[000117] = 07007; code[000117] = &D00117;
  core[000120] = 00207; code[000120] = &D00120;
  core[000121] = 05140; code[000121] = &D00121;
  core[000122] = 05140; code[000122] = &D00122;
  core[000144] = 01067; code[000144] = &L00144;
  core[000145] = 07200; code[000145] = &I00145;
  core[000146] = 07402; code[000146] = &I00146;
  core[000147] = 07410; code[000147] = &L00147;
  core[000150] = 07402; code[000150] = &I00150;
  core[000151] = 07200; code[000151] = &I00151;
  core[000152] = 07440; code[000152] = &P00152;
  core[000153] = 07402; code[000153] = &I00153;
  core[000154] = 07450; code[000154] = &I00154;
  core[000155] = 07410; code[000155] = &I00155;
  core[000156] = 07402; code[000156] = &I00156;
  core[000157] = 07200; code[000157] = &I00157;
  core[000160] = 01050; code[000160] = &I00160;
  core[000161] = 07440; code[000161] = &I00161;
  core[000162] = 07410; code[000162] = &I00162;
  core[000163] = 07402; code[000163] = &I00163;
  core[000164] = 07450; code[000164] = &I00164;
  core[000165] = 07402; code[000165] = &I00165;
  core[000166] = 07200; code[000166] = &I00166;
  core[000167] = 01045; code[000167] = &I00167;
  core[000170] = 07440; code[000170] = &P00170;
  core[000171] = 07410; code[000171] = &I00171;
  core[000172] = 07402; code[000172] = &I00172;
  core[000173] = 07450; code[000173] = &I00173;
  core[000174] = 07402; code[000174] = &I00174;
  core[000175] = 07000; code[000175] = &I00175;
  core[000176] = 07000; code[000176] = &I00176;
  core[000177] = 07410; code[000177] = &P00177;
  core[000200] = 05144; code[000200] = &I00200;
  core[000201] = 07200; code[000201] = &I00201;
  core[000202] = 01042; code[000202] = &I00202;
  core[000203] = 07440; code[000203] = &I00203;
  core[000204] = 07410; code[000204] = &I00204;
  core[000205] = 07402; code[000205] = &I00205;
  core[000206] = 07450; code[000206] = &I00206;
  core[000207] = 07402; code[000207] = &I00207;
  core[000210] = 07200; code[000210] = &I00210;
  core[000211] = 01040; code[000211] = &I00211;
  core[000212] = 07440; code[000212] = &I00212;
  core[000213] = 07410; code[000213] = &I00213;
  core[000214] = 07402; code[000214] = &I00214;
  core[000215] = 07450; code[000215] = &I00215;
  core[000216] = 07402; code[000216] = &I00216;
  core[000217] = 07200; code[000217] = &I00217;
  core[000220] = 01036; code[000220] = &I00220;
  core[000221] = 07440; code[000221] = &I00221;
  core[000222] = 07410; code[000222] = &I00222;
  core[000223] = 07402; code[000223] = &I00223;
  core[000224] = 07450; code[000224] = &I00224;
  core[000225] = 07402; code[000225] = &I00225;
  core[000226] = 07200; code[000226] = &I00226;
  core[000227] = 01034; code[000227] = &I00227;
  core[000230] = 07440; code[000230] = &I00230;
  core[000231] = 07410; code[000231] = &I00231;
  core[000232] = 07402; code[000232] = &I00232;
  core[000233] = 07450; code[000233] = &I00233;
  core[000234] = 07402; code[000234] = &I00234;
  core[000235] = 07200; code[000235] = &I00235;
  core[000236] = 01032; code[000236] = &I00236;
  core[000237] = 07440; code[000237] = &I00237;
  core[000240] = 07410; code[000240] = &I00240;
  core[000241] = 07402; code[000241] = &I00241;
  core[000242] = 07450; code[000242] = &I00242;
  core[000243] = 07402; code[000243] = &I00243;
  core[000244] = 07200; code[000244] = &I00244;
  core[000245] = 01030; code[000245] = &I00245;
  core[000246] = 07440; code[000246] = &I00246;
  core[000247] = 07410; code[000247] = &I00247;
  core[000250] = 07402; code[000250] = &I00250;
  core[000251] = 07450; code[000251] = &I00251;
  core[000252] = 07402; code[000252] = &I00252;
  core[000253] = 07200; code[000253] = &I00253;
  core[000254] = 01026; code[000254] = &I00254;
  core[000255] = 07440; code[000255] = &I00255;
  core[000256] = 07410; code[000256] = &I00256;
  core[000257] = 07402; code[000257] = &I00257;
  core[000260] = 07450; code[000260] = &I00260;
  core[000261] = 07402; code[000261] = &I00261;
  core[000262] = 07200; code[000262] = &I00262;
  core[000263] = 01024; code[000263] = &I00263;
  core[000264] = 07440; code[000264] = &I00264;
  core[000265] = 07410; code[000265] = &I00265;
  core[000266] = 07402; code[000266] = &I00266;
  core[000267] = 07450; code[000267] = &I00267;
  core[000270] = 07402; code[000270] = &I00270;
  core[000271] = 07200; code[000271] = &I00271;
  core[000272] = 01022; code[000272] = &I00272;
  core[000273] = 07440; code[000273] = &I00273;
  core[000274] = 07410; code[000274] = &I00274;
  core[000275] = 07402; code[000275] = &I00275;
  core[000276] = 07450; code[000276] = &I00276;
  core[000277] = 07402; code[000277] = &I00277;
  core[000300] = 07200; code[000300] = &I00300;
  core[000301] = 01021; code[000301] = &I00301;
  core[000302] = 07440; code[000302] = &I00302;
  core[000303] = 07410; code[000303] = &I00303;
  core[000304] = 07402; code[000304] = &I00304;
  core[000305] = 07450; code[000305] = &I00305;
  core[000306] = 07402; code[000306] = &I00306;
  core[000307] = 07200; code[000307] = &I00307;
  core[000310] = 01066; code[000310] = &I00310;
  core[000311] = 07510; code[000311] = &I00311;
  core[000312] = 07402; code[000312] = &I00312;
  core[000313] = 07200; code[000313] = &I00313;
  core[000314] = 01050; code[000314] = &I00314;
  core[000315] = 07510; code[000315] = &I00315;
  core[000316] = 07410; code[000316] = &I00316;
  core[000317] = 07402; code[000317] = &I00317;
  core[000320] = 07200; code[000320] = &I00320;
  core[000321] = 01066; code[000321] = &I00321;
  core[000322] = 07500; code[000322] = &I00322;
  core[000323] = 07410; code[000323] = &I00323;
  core[000324] = 07402; code[000324] = &I00324;
  core[000325] = 07200; code[000325] = &I00325;
  core[000326] = 01050; code[000326] = &I00326;
  core[000327] = 07500; code[000327] = &I00327;
  core[000330] = 07402; code[000330] = &I00330;
  core[000331] = 07200; code[000331] = &I00331;
  core[000332] = 01067; code[000332] = &I00332;
  core[000333] = 07040; code[000333] = &I00333;
  core[000334] = 07440; code[000334] = &I00334;
  core[000335] = 07402; code[000335] = &I00335;
  core[000336] = 07200; code[000336] = &I00336;
  core[000337] = 01071; code[000337] = &I00337;
  core[000340] = 07040; code[000340] = &I00340;
  core[000341] = 07450; code[000341] = &I00341;
  core[000342] = 07402; code[000342] = &I00342;
  core[000343] = 01071; code[000343] = &I00343;
  core[000344] = 07040; code[000344] = &I00344;
  core[000345] = 07440; code[000345] = &I00345;
  core[000346] = 07402; code[000346] = &I00346;
  core[000347] = 07200; code[000347] = &I00347;
  core[000350] = 01070; code[000350] = &I00350;
  core[000351] = 07040; code[000351] = &I00351;
  core[000352] = 07450; code[000352] = &I00352;
  core[000353] = 07402; code[000353] = &I00353;
  core[000354] = 01070; code[000354] = &I00354;
  core[000355] = 07040; code[000355] = &I00355;
  core[000356] = 07440; code[000356] = &I00356;
  core[000357] = 07402; code[000357] = &I00357;
  core[000360] = 07200; code[000360] = &I00360;
  core[000361] = 01067; code[000361] = &I00361;
  core[000362] = 07040; code[000362] = &I00362;
  core[000363] = 07440; code[000363] = &I00363;
  core[000364] = 07402; code[000364] = &I00364;
  core[000365] = 07200; code[000365] = &I00365;
  core[000366] = 07001; code[000366] = &I00366;
  core[000367] = 07440; code[000367] = &I00367;
  core[000370] = 07410; code[000370] = &I00370;
  core[000371] = 07402; code[000371] = &I00371;
  core[000372] = 07200; code[000372] = &I00372;
  core[000373] = 01067; code[000373] = &I00373;
  core[000374] = 07001; code[000374] = &I00374;
  core[000375] = 07440; code[000375] = &I00375;
  core[000376] = 07402; code[000376] = &I00376;
  core[000377] = 07200; code[000377] = &I00377;
  core[000400] = 01101; code[000400] = &I00400;
  core[000401] = 07001; code[000401] = &I00401;
  core[000402] = 07001; code[000402] = &I00402;
  core[000403] = 07001; code[000403] = &I00403;
  core[000404] = 07001; code[000404] = &I00404;
  core[000405] = 07440; code[000405] = &I00405;
  core[000406] = 07402; code[000406] = &I00406;
  core[000407] = 07200; code[000407] = &I00407;
  core[000410] = 07100; code[000410] = &I00410;
  core[000411] = 07004; code[000411] = &I00411;
  core[000412] = 07430; code[000412] = &I00412;
  core[000413] = 07402; code[000413] = &I00413;
  core[000414] = 07200; code[000414] = &I00414;
  core[000415] = 07100; code[000415] = &I00415;
  core[000416] = 07020; code[000416] = &I00416;
  core[000417] = 01050; code[000417] = &I00417;
  core[000420] = 07004; code[000420] = &I00420;
  core[000421] = 07430; code[000421] = &I00421;
  core[000422] = 07410; code[000422] = &I00422;
  core[000423] = 07402; code[000423] = &I00423;
  core[000424] = 07200; code[000424] = &I00424;
  core[000425] = 07100; code[000425] = &I00425;
  core[000426] = 07004; code[000426] = &I00426;
  core[000427] = 07420; code[000427] = &I00427;
  core[000430] = 07410; code[000430] = &I00430;
  core[000431] = 07402; code[000431] = &I00431;
  core[000432] = 07200; code[000432] = &I00432;
  core[000433] = 07100; code[000433] = &I00433;
  core[000434] = 07020; code[000434] = &I00434;
  core[000435] = 01050; code[000435] = &I00435;
  core[000436] = 07004; code[000436] = &I00436;
  core[000437] = 07420; code[000437] = &I00437;
  core[000440] = 07402; code[000440] = &I00440;
  core[000441] = 07200; code[000441] = &I00441;
  core[000442] = 01050; code[000442] = &I00442;
  core[000443] = 07004; code[000443] = &I00443;
  core[000444] = 07420; code[000444] = &I00444;
  core[000445] = 05252; code[000445] = &I00445;
  core[000446] = 07100; code[000446] = &L00446;
  core[000447] = 07430; code[000447] = &I00447;
  core[000450] = 07402; code[000450] = &I00450;
  core[000451] = 05256; code[000451] = &I00451;
  core[000452] = 07020; code[000452] = &L00452;
  core[000453] = 07420; code[000453] = &I00453;
  core[000454] = 07402; code[000454] = &I00454;
  core[000455] = 05246; code[000455] = &I00455;
  core[000456] = 07100; code[000456] = &L00456;
  core[000457] = 07430; code[000457] = &I00457;
  core[000460] = 07402; code[000460] = &I00460;
  core[000461] = 07020; code[000461] = &I00461;
  core[000462] = 07420; code[000462] = &I00462;
  core[000463] = 07402; code[000463] = &I00463;
  core[000464] = 07020; code[000464] = &I00464;
  core[000465] = 07430; code[000465] = &I00465;
  core[000466] = 07402; code[000466] = &I00466;
  core[000467] = 07200; code[000467] = &I00467;
  core[000470] = 01067; code[000470] = &I00470;
  core[000471] = 07600; code[000471] = &I00471;
  core[000472] = 07440; code[000472] = &I00472;
  core[000473] = 07402; code[000473] = &I00473;
  core[000474] = 07200; code[000474] = &I00474;
  core[000475] = 07404; code[000475] = &I00475;
  core[000476] = 07040; code[000476] = &I00476;
  core[000477] = 07440; code[000477] = &I00477;
  core[000500] = 07402; code[000500] = &I00500;
  core[000501] = 07200; code[000501] = &I00501;
  core[000502] = 07100; code[000502] = &I00502;
  core[000503] = 07000; code[000503] = &I00503;
  core[000504] = 07450; code[000504] = &I00504;
  core[000505] = 07430; code[000505] = &I00505;
  core[000506] = 07402; code[000506] = &I00506;
  core[000507] = 07200; code[000507] = &I00507;
  core[000510] = 07100; code[000510] = &I00510;
  core[000511] = 07400; code[000511] = &I00511;
  core[000512] = 07450; code[000512] = &I00512;
  core[000513] = 07430; code[000513] = &I00513;
  core[000514] = 07402; code[000514] = &I00514;
  core[000515] = 07200; code[000515] = &I00515;
  core[000516] = 01066; code[000516] = &I00516;
  core[000517] = 01050; code[000517] = &I00517;
  core[000520] = 07040; code[000520] = &I00520;
  core[000521] = 07440; code[000521] = &I00521;
  core[000522] = 07402; code[000522] = &I00522;
  core[000523] = 07200; code[000523] = &I00523;
  core[000524] = 01065; code[000524] = &I00524;
  core[000525] = 01045; code[000525] = &I00525;
  core[000526] = 07040; code[000526] = &I00526;
  core[000527] = 07440; code[000527] = &I00527;
  core[000530] = 07402; code[000530] = &I00530;
  core[000531] = 07200; code[000531] = &I00531;
  core[000532] = 01064; code[000532] = &I00532;
  core[000533] = 01042; code[000533] = &I00533;
  core[000534] = 07040; code[000534] = &I00534;
  core[000535] = 07440; code[000535] = &I00535;
  core[000536] = 07402; code[000536] = &I00536;
  core[000537] = 07200; code[000537] = &I00537;
  core[000540] = 01063; code[000540] = &I00540;
  core[000541] = 01040; code[000541] = &I00541;
  core[000542] = 07040; code[000542] = &I00542;
  core[000543] = 07440; code[000543] = &I00543;
  core[000544] = 07402; code[000544] = &I00544;
  core[000545] = 07200; code[000545] = &I00545;
  core[000546] = 01062; code[000546] = &I00546;
  core[000547] = 01036; code[000547] = &I00547;
  core[000550] = 07040; code[000550] = &I00550;
  core[000551] = 07440; code[000551] = &I00551;
  core[000552] = 07402; code[000552] = &I00552;
  core[000553] = 07200; code[000553] = &I00553;
  core[000554] = 01061; code[000554] = &I00554;
  core[000555] = 01034; code[000555] = &I00555;
  core[000556] = 07040; code[000556] = &I00556;
  core[000557] = 07440; code[000557] = &I00557;
  core[000560] = 07402; code[000560] = &I00560;
  core[000561] = 07200; code[000561] = &I00561;
  core[000562] = 01057; code[000562] = &I00562;
  core[000563] = 01032; code[000563] = &I00563;
  core[000564] = 07040; code[000564] = &I00564;
  core[000565] = 07440; code[000565] = &I00565;
  core[000566] = 07402; code[000566] = &I00566;
  core[000567] = 07200; code[000567] = &I00567;
  core[000570] = 01056; code[000570] = &I00570;
  core[000571] = 01030; code[000571] = &I00571;
  core[000572] = 07040; code[000572] = &I00572;
  core[000573] = 07440; code[000573] = &I00573;
  core[000574] = 07402; code[000574] = &I00574;
  core[000575] = 07200; code[000575] = &I00575;
  core[000576] = 01055; code[000576] = &I00576;
  core[000577] = 01026; code[000577] = &I00577;
  core[000600] = 07040; code[000600] = &I00600;
  core[000601] = 07440; code[000601] = &I00601;
  core[000602] = 07402; code[000602] = &I00602;
  core[000603] = 07200; code[000603] = &I00603;
  core[000604] = 01054; code[000604] = &I00604;
  core[000605] = 01024; code[000605] = &I00605;
  core[000606] = 07040; code[000606] = &I00606;
  core[000607] = 07440; code[000607] = &I00607;
  core[000610] = 07402; code[000610] = &I00610;
  core[000611] = 07200; code[000611] = &I00611;
  core[000612] = 01053; code[000612] = &I00612;
  core[000613] = 01022; code[000613] = &I00613;
  core[000614] = 07040; code[000614] = &I00614;
  core[000615] = 07440; code[000615] = &I00615;
  core[000616] = 07402; code[000616] = &I00616;
  core[000617] = 07200; code[000617] = &I00617;
  core[000620] = 01052; code[000620] = &I00620;
  core[000621] = 01021; code[000621] = &I00621;
  core[000622] = 07040; code[000622] = &I00622;
  core[000623] = 07440; code[000623] = &I00623;
  core[000624] = 07402; code[000624] = &I00624;
  core[000625] = 07200; code[000625] = &I00625;
  core[000626] = 07100; code[000626] = &I00626;
  core[000627] = 01050; code[000627] = &I00627;
  core[000630] = 01050; code[000630] = &I00630;
  core[000631] = 07430; code[000631] = &I00631;
  core[000632] = 07440; code[000632] = &I00632;
  core[000633] = 07402; code[000633] = &I00633;
  core[000634] = 07200; code[000634] = &I00634;
  core[000635] = 07100; code[000635] = &I00635;
  core[000636] = 01072; code[000636] = &I00636;
  core[000637] = 01045; code[000637] = &I00637;
  core[000640] = 07430; code[000640] = &I00640;
  core[000641] = 07440; code[000641] = &I00641;
  core[000642] = 07402; code[000642] = &I00642;
  core[000643] = 07200; code[000643] = &I00643;
  core[000644] = 07100; code[000644] = &I00644;
  core[000645] = 01073; code[000645] = &I00645;
  core[000646] = 01042; code[000646] = &I00646;
  core[000647] = 07430; code[000647] = &I00647;
  core[000650] = 07440; code[000650] = &I00650;
  core[000651] = 07402; code[000651] = &I00651;
  core[000652] = 07200; code[000652] = &I00652;
  core[000653] = 07100; code[000653] = &I00653;
  core[000654] = 01074; code[000654] = &I00654;
  core[000655] = 01040; code[000655] = &I00655;
  core[000656] = 07430; code[000656] = &I00656;
  core[000657] = 07440; code[000657] = &I00657;
  core[000660] = 07402; code[000660] = &I00660;
  core[000661] = 07200; code[000661] = &I00661;
  core[000662] = 07100; code[000662] = &I00662;
  core[000663] = 01075; code[000663] = &I00663;
  core[000664] = 01036; code[000664] = &I00664;
  core[000665] = 07430; code[000665] = &I00665;
  core[000666] = 07440; code[000666] = &I00666;
  core[000667] = 07402; code[000667] = &I00667;
  core[000670] = 07200; code[000670] = &I00670;
  core[000671] = 07100; code[000671] = &I00671;
  core[000672] = 01113; code[000672] = &I00672;
  core[000673] = 01034; code[000673] = &I00673;
  core[000674] = 07430; code[000674] = &I00674;
  core[000675] = 07440; code[000675] = &I00675;
  core[000676] = 07402; code[000676] = &I00676;
  core[000677] = 07200; code[000677] = &I00677;
  core[000700] = 07100; code[000700] = &I00700;
  core[000701] = 01076; code[000701] = &I00701;
  core[000702] = 01032; code[000702] = &I00702;
  core[000703] = 07430; code[000703] = &I00703;
  core[000704] = 07440; code[000704] = &I00704;
  core[000705] = 07402; code[000705] = &I00705;
  core[000706] = 07200; code[000706] = &I00706;
  core[000707] = 07100; code[000707] = &I00707;
  core[000710] = 01077; code[000710] = &I00710;
  core[000711] = 01030; code[000711] = &I00711;
  core[000712] = 07430; code[000712] = &I00712;
  core[000713] = 07440; code[000713] = &I00713;
  core[000714] = 07402; code[000714] = &I00714;
  core[000715] = 07200; code[000715] = &I00715;
  core[000716] = 07100; code[000716] = &I00716;
  core[000717] = 01100; code[000717] = &I00717;
  core[000720] = 01026; code[000720] = &I00720;
  core[000721] = 07430; code[000721] = &I00721;
  core[000722] = 07440; code[000722] = &I00722;
  core[000723] = 07402; code[000723] = &I00723;
  core[000724] = 07200; code[000724] = &I00724;
  core[000725] = 07100; code[000725] = &I00725;
  core[000726] = 01101; code[000726] = &I00726;
  core[000727] = 01024; code[000727] = &I00727;
  core[000730] = 07430; code[000730] = &I00730;
  core[000731] = 07440; code[000731] = &I00731;
  core[000732] = 07402; code[000732] = &I00732;
  core[000733] = 07200; code[000733] = &I00733;
  core[000734] = 07100; code[000734] = &I00734;
  core[000735] = 01052; code[000735] = &I00735;
  core[000736] = 01022; code[000736] = &I00736;
  core[000737] = 07430; code[000737] = &I00737;
  core[000740] = 07440; code[000740] = &I00740;
  core[000741] = 07402; code[000741] = &I00741;
  core[000742] = 07200; code[000742] = &I00742;
  core[000743] = 07100; code[000743] = &I00743;
  core[000744] = 01067; code[000744] = &I00744;
  core[000745] = 01021; code[000745] = &I00745;
  core[000746] = 07430; code[000746] = &I00746;
  core[000747] = 07440; code[000747] = &I00747;
  core[000750] = 07402; code[000750] = &I00750;
  core[000751] = 07200; code[000751] = &I00751;
  core[000752] = 07100; code[000752] = &I00752;
  core[000753] = 07020; code[000753] = &I00753;
  core[000754] = 01050; code[000754] = &I00754;
  core[000755] = 01050; code[000755] = &I00755;
  core[000756] = 07420; code[000756] = &I00756;
  core[000757] = 07440; code[000757] = &I00757;
  core[000760] = 07402; code[000760] = &I00760;
  core[000761] = 07200; code[000761] = &I00761;
  core[000762] = 07100; code[000762] = &I00762;
  core[000763] = 01066; code[000763] = &I00763;
  core[000764] = 01045; code[000764] = &I00764;
  core[000765] = 01045; code[000765] = &I00765;
  core[000766] = 07040; code[000766] = &I00766;
  core[000767] = 07420; code[000767] = &I00767;
  core[000770] = 07440; code[000770] = &I00770;
  core[000771] = 07402; code[000771] = &I00771;
  core[000772] = 07200; code[000772] = &I00772;
  core[000773] = 07100; code[000773] = &I00773;
  core[000774] = 01065; code[000774] = &I00774;
  core[000775] = 01042; code[000775] = &I00775;
  core[000776] = 01042; code[000776] = &I00776;
  core[000777] = 07040; code[000777] = &I00777;
  core[001000] = 07420; code[001000] = &I01000;
  core[001001] = 07440; code[001001] = &I01001;
  core[001002] = 07402; code[001002] = &I01002;
  core[001003] = 07200; code[001003] = &I01003;
  core[001004] = 07100; code[001004] = &I01004;
  core[001005] = 01064; code[001005] = &I01005;
  core[001006] = 01040; code[001006] = &I01006;
  core[001007] = 01040; code[001007] = &I01007;
  core[001010] = 07040; code[001010] = &I01010;
  core[001011] = 07420; code[001011] = &I01011;
  core[001012] = 07440; code[001012] = &I01012;
  core[001013] = 07402; code[001013] = &I01013;
  core[001014] = 07200; code[001014] = &I01014;
  core[001015] = 07100; code[001015] = &I01015;
  core[001016] = 01063; code[001016] = &I01016;
  core[001017] = 01036; code[001017] = &I01017;
  core[001020] = 01036; code[001020] = &I01020;
  core[001021] = 07040; code[001021] = &I01021;
  core[001022] = 07420; code[001022] = &I01022;
  core[001023] = 07440; code[001023] = &I01023;
  core[001024] = 07402; code[001024] = &I01024;
  core[001025] = 07200; code[001025] = &I01025;
  core[001026] = 07100; code[001026] = &I01026;
  core[001027] = 01062; code[001027] = &I01027;
  core[001030] = 01034; code[001030] = &I01030;
  core[001031] = 01034; code[001031] = &I01031;
  core[001032] = 07040; code[001032] = &I01032;
  core[001033] = 07420; code[001033] = &I01033;
  core[001034] = 07440; code[001034] = &I01034;
  core[001035] = 07402; code[001035] = &I01035;
  core[001036] = 07200; code[001036] = &I01036;
  core[001037] = 07100; code[001037] = &I01037;
  core[001040] = 01061; code[001040] = &I01040;
  core[001041] = 01032; code[001041] = &I01041;
  core[001042] = 01032; code[001042] = &I01042;
  core[001043] = 07040; code[001043] = &I01043;
  core[001044] = 07420; code[001044] = &I01044;
  core[001045] = 07440; code[001045] = &I01045;
  core[001046] = 07402; code[001046] = &I01046;
  core[001047] = 07200; code[001047] = &I01047;
  core[001050] = 07100; code[001050] = &I01050;
  core[001051] = 01057; code[001051] = &I01051;
  core[001052] = 01030; code[001052] = &I01052;
  core[001053] = 01030; code[001053] = &I01053;
  core[001054] = 07040; code[001054] = &I01054;
  core[001055] = 07420; code[001055] = &I01055;
  core[001056] = 07440; code[001056] = &I01056;
  core[001057] = 07402; code[001057] = &I01057;
  core[001060] = 07200; code[001060] = &I01060;
  core[001061] = 07100; code[001061] = &I01061;
  core[001062] = 01056; code[001062] = &I01062;
  core[001063] = 01026; code[001063] = &I01063;
  core[001064] = 01026; code[001064] = &I01064;
  core[001065] = 07040; code[001065] = &I01065;
  core[001066] = 07420; code[001066] = &I01066;
  core[001067] = 07440; code[001067] = &I01067;
  core[001070] = 07402; code[001070] = &I01070;
  core[001071] = 07200; code[001071] = &I01071;
  core[001072] = 07100; code[001072] = &I01072;
  core[001073] = 01055; code[001073] = &I01073;
  core[001074] = 01024; code[001074] = &I01074;
  core[001075] = 01024; code[001075] = &I01075;
  core[001076] = 07040; code[001076] = &I01076;
  core[001077] = 07420; code[001077] = &I01077;
  core[001100] = 07440; code[001100] = &I01100;
  core[001101] = 07402; code[001101] = &I01101;
  core[001102] = 07200; code[001102] = &I01102;
  core[001103] = 07100; code[001103] = &I01103;
  core[001104] = 01054; code[001104] = &I01104;
  core[001105] = 01022; code[001105] = &I01105;
  core[001106] = 01022; code[001106] = &I01106;
  core[001107] = 07040; code[001107] = &I01107;
  core[001110] = 07420; code[001110] = &I01110;
  core[001111] = 07440; code[001111] = &I01111;
  core[001112] = 07402; code[001112] = &I01112;
  core[001113] = 07200; code[001113] = &I01113;
  core[001114] = 07100; code[001114] = &I01114;
  core[001115] = 01053; code[001115] = &I01115;
  core[001116] = 01021; code[001116] = &I01116;
  core[001117] = 01021; code[001117] = &I01117;
  core[001120] = 07040; code[001120] = &I01120;
  core[001121] = 07420; code[001121] = &I01121;
  core[001122] = 07430; code[001122] = &I01122;
  core[001123] = 07402; code[001123] = &I01123;
  core[001124] = 07200; code[001124] = &I01124;
  core[001125] = 07100; code[001125] = &I01125;
  core[001126] = 01021; code[001126] = &I01126;
  core[001127] = 01023; code[001127] = &I01127;
  core[001130] = 01054; code[001130] = &I01130;
  core[001131] = 07040; code[001131] = &I01131;
  core[001132] = 07420; code[001132] = &I01132;
  core[001133] = 07440; code[001133] = &I01133;
  core[001134] = 07402; code[001134] = &I01134;
  core[001135] = 07200; code[001135] = &I01135;
  core[001136] = 07100; code[001136] = &I01136;
  core[001137] = 01022; code[001137] = &I01137;
  core[001140] = 01025; code[001140] = &I01140;
  core[001141] = 01055; code[001141] = &I01141;
  core[001142] = 07040; code[001142] = &I01142;
  core[001143] = 07420; code[001143] = &I01143;
  core[001144] = 07440; code[001144] = &I01144;
  core[001145] = 07402; code[001145] = &I01145;
  core[001146] = 07200; code[001146] = &I01146;
  core[001147] = 07100; code[001147] = &I01147;
  core[001150] = 01024; code[001150] = &I01150;
  core[001151] = 01027; code[001151] = &I01151;
  core[001152] = 01056; code[001152] = &I01152;
  core[001153] = 07040; code[001153] = &I01153;
  core[001154] = 07420; code[001154] = &I01154;
  core[001155] = 07440; code[001155] = &I01155;
  core[001156] = 07402; code[001156] = &I01156;
  core[001157] = 07200; code[001157] = &I01157;
  core[001160] = 07100; code[001160] = &I01160;
  core[001161] = 01026; code[001161] = &I01161;
  core[001162] = 01031; code[001162] = &I01162;
  core[001163] = 01057; code[001163] = &I01163;
  core[001164] = 07040; code[001164] = &I01164;
  core[001165] = 07420; code[001165] = &I01165;
  core[001166] = 07440; code[001166] = &I01166;
  core[001167] = 07402; code[001167] = &I01167;
  core[001170] = 07200; code[001170] = &I01170;
  core[001171] = 07100; code[001171] = &I01171;
  core[001172] = 01030; code[001172] = &I01172;
  core[001173] = 01033; code[001173] = &I01173;
  core[001174] = 01061; code[001174] = &I01174;
  core[001175] = 07040; code[001175] = &I01175;
  core[001176] = 07420; code[001176] = &I01176;
  core[001177] = 07440; code[001177] = &I01177;
  core[001200] = 07402; code[001200] = &I01200;
  core[001201] = 07200; code[001201] = &I01201;
  core[001202] = 07100; code[001202] = &I01202;
  core[001203] = 01032; code[001203] = &I01203;
  core[001204] = 01035; code[001204] = &I01204;
  core[001205] = 01062; code[001205] = &I01205;
  core[001206] = 07040; code[001206] = &I01206;
  core[001207] = 07420; code[001207] = &I01207;
  core[001210] = 07440; code[001210] = &I01210;
  core[001211] = 07402; code[001211] = &I01211;
  core[001212] = 07200; code[001212] = &I01212;
  core[001213] = 07100; code[001213] = &I01213;
  core[001214] = 01034; code[001214] = &I01214;
  core[001215] = 01037; code[001215] = &I01215;
  core[001216] = 01063; code[001216] = &I01216;
  core[001217] = 07040; code[001217] = &I01217;
  core[001220] = 07420; code[001220] = &I01220;
  core[001221] = 07440; code[001221] = &I01221;
  core[001222] = 07402; code[001222] = &I01222;
  core[001223] = 07200; code[001223] = &I01223;
  core[001224] = 07100; code[001224] = &I01224;
  core[001225] = 01036; code[001225] = &I01225;
  core[001226] = 01041; code[001226] = &I01226;
  core[001227] = 01064; code[001227] = &I01227;
  core[001230] = 07040; code[001230] = &I01230;
  core[001231] = 07420; code[001231] = &I01231;
  core[001232] = 07440; code[001232] = &I01232;
  core[001233] = 07402; code[001233] = &I01233;
  core[001234] = 07200; code[001234] = &I01234;
  core[001235] = 07100; code[001235] = &I01235;
  core[001236] = 01040; code[001236] = &I01236;
  core[001237] = 01044; code[001237] = &I01237;
  core[001240] = 01065; code[001240] = &I01240;
  core[001241] = 07040; code[001241] = &I01241;
  core[001242] = 07420; code[001242] = &I01242;
  core[001243] = 07440; code[001243] = &I01243;
  core[001244] = 07402; code[001244] = &I01244;
  core[001245] = 07200; code[001245] = &I01245;
  core[001246] = 07100; code[001246] = &I01246;
  core[001247] = 01042; code[001247] = &I01247;
  core[001250] = 01046; code[001250] = &I01250;
  core[001251] = 01066; code[001251] = &I01251;
  core[001252] = 07040; code[001252] = &I01252;
  core[001253] = 07420; code[001253] = &I01253;
  core[001254] = 07440; code[001254] = &I01254;
  core[001255] = 07402; code[001255] = &I01255;
  core[001256] = 07200; code[001256] = &I01256;
  core[001257] = 07100; code[001257] = &I01257;
  core[001260] = 01045; code[001260] = &I01260;
  core[001261] = 01072; code[001261] = &I01261;
  core[001262] = 07430; code[001262] = &I01262;
  core[001263] = 07440; code[001263] = &I01263;
  core[001264] = 07402; code[001264] = &I01264;
  core[001265] = 07200; code[001265] = &I01265;
  core[001266] = 07100; code[001266] = &I01266;
  core[001267] = 01067; code[001267] = &I01267;
  core[001270] = 01021; code[001270] = &I01270;
  core[001271] = 07430; code[001271] = &I01271;
  core[001272] = 07440; code[001272] = &I01272;
  core[001273] = 07402; code[001273] = &I01273;
  core[001274] = 07200; code[001274] = &I01274;
  core[001275] = 07100; code[001275] = &I01275;
  core[001276] = 01023; code[001276] = &I01276;
  core[001277] = 01023; code[001277] = &I01277;
  core[001300] = 01100; code[001300] = &I01300;
  core[001301] = 01021; code[001301] = &I01301;
  core[001302] = 07040; code[001302] = &I01302;
  core[001303] = 07420; code[001303] = &I01303;
  core[001304] = 07440; code[001304] = &I01304;
  core[001305] = 07402; code[001305] = &I01305;
  core[001306] = 07200; code[001306] = &I01306;
  core[001307] = 07100; code[001307] = &I01307;
  core[001310] = 01025; code[001310] = &I01310;
  core[001311] = 01025; code[001311] = &I01311;
  core[001312] = 01077; code[001312] = &I01312;
  core[001313] = 01023; code[001313] = &I01313;
  core[001314] = 07040; code[001314] = &I01314;
  core[001315] = 07420; code[001315] = &I01315;
  core[001316] = 07440; code[001316] = &I01316;
  core[001317] = 07402; code[001317] = &I01317;
  core[001320] = 07200; code[001320] = &I01320;
  core[001321] = 07100; code[001321] = &I01321;
  core[001322] = 01027; code[001322] = &I01322;
  core[001323] = 01027; code[001323] = &I01323;
  core[001324] = 01076; code[001324] = &I01324;
  core[001325] = 01102; code[001325] = &I01325;
  core[001326] = 07040; code[001326] = &I01326;
  core[001327] = 07420; code[001327] = &I01327;
  core[001330] = 07440; code[001330] = &I01330;
  core[001331] = 07402; code[001331] = &I01331;
  core[001332] = 07200; code[001332] = &I01332;
  core[001333] = 07100; code[001333] = &I01333;
  core[001334] = 01031; code[001334] = &I01334;
  core[001335] = 01031; code[001335] = &I01335;
  core[001336] = 01051; code[001336] = &I01336;
  core[001337] = 07040; code[001337] = &I01337;
  core[001340] = 07420; code[001340] = &I01340;
  core[001341] = 07440; code[001341] = &I01341;
  core[001342] = 07402; code[001342] = &I01342;
  core[001343] = 07200; code[001343] = &I01343;
  core[001344] = 07100; code[001344] = &I01344;
  core[001345] = 01033; code[001345] = &I01345;
  core[001346] = 01033; code[001346] = &I01346;
  core[001347] = 01075; code[001347] = &I01347;
  core[001350] = 01105; code[001350] = &I01350;
  core[001351] = 07040; code[001351] = &I01351;
  core[001352] = 07420; code[001352] = &I01352;
  core[001353] = 07440; code[001353] = &I01353;
  core[001354] = 07402; code[001354] = &I01354;
  core[001355] = 07200; code[001355] = &I01355;
  core[001356] = 07100; code[001356] = &I01356;
  core[001357] = 01035; code[001357] = &I01357;
  core[001360] = 01035; code[001360] = &I01360;
  core[001361] = 01074; code[001361] = &I01361;
  core[001362] = 01106; code[001362] = &I01362;
  core[001363] = 07040; code[001363] = &I01363;
  core[001364] = 07420; code[001364] = &I01364;
  core[001365] = 07440; code[001365] = &I01365;
  core[001366] = 07402; code[001366] = &I01366;
  core[001367] = 07200; code[001367] = &I01367;
  core[001370] = 07100; code[001370] = &I01370;
  core[001371] = 01037; code[001371] = &I01371;
  core[001372] = 01037; code[001372] = &I01372;
  core[001373] = 01060; code[001373] = &I01373;
  core[001374] = 07040; code[001374] = &I01374;
  core[001375] = 07420; code[001375] = &I01375;
  core[001376] = 07440; code[001376] = &I01376;
  core[001377] = 07402; code[001377] = &I01377;
  core[001400] = 07200; code[001400] = &I01400;
  core[001401] = 07100; code[001401] = &I01401;
  core[001402] = 01041; code[001402] = &I01402;
  core[001403] = 01041; code[001403] = &I01403;
  core[001404] = 01072; code[001404] = &I01404;
  core[001405] = 01110; code[001405] = &I01405;
  core[001406] = 07040; code[001406] = &I01406;
  core[001407] = 07420; code[001407] = &I01407;
  core[001410] = 07440; code[001410] = &I01410;
  core[001411] = 07402; code[001411] = &I01411;
  core[001412] = 07200; code[001412] = &I01412;
  core[001413] = 07100; code[001413] = &I01413;
  core[001414] = 01044; code[001414] = &I01414;
  core[001415] = 01044; code[001415] = &I01415;
  core[001416] = 01050; code[001416] = &I01416;
  core[001417] = 01111; code[001417] = &I01417;
  core[001420] = 07040; code[001420] = &I01420;
  core[001421] = 07420; code[001421] = &I01421;
  core[001422] = 07440; code[001422] = &I01422;
  core[001423] = 07402; code[001423] = &I01423;
  core[001424] = 07200; code[001424] = &I01424;
  core[001425] = 07100; code[001425] = &I01425;
  core[001426] = 01046; code[001426] = &I01426;
  core[001427] = 01046; code[001427] = &I01427;
  core[001430] = 01112; code[001430] = &I01430;
  core[001431] = 07040; code[001431] = &I01431;
  core[001432] = 07420; code[001432] = &I01432;
  core[001433] = 07440; code[001433] = &I01433;
  core[001434] = 07402; code[001434] = &I01434;
  core[001435] = 07200; code[001435] = &I01435;
  core[001436] = 07100; code[001436] = &I01436;
  core[001437] = 01072; code[001437] = &I01437;
  core[001440] = 01072; code[001440] = &I01440;
  core[001441] = 01066; code[001441] = &I01441;
  core[001442] = 07040; code[001442] = &I01442;
  core[001443] = 07430; code[001443] = &I01443;
  core[001444] = 07440; code[001444] = &I01444;
  core[001445] = 07402; code[001445] = &I01445;
  core[001446] = 07200; code[001446] = &I01446;
  core[001447] = 07100; code[001447] = &I01447;
  core[001450] = 01067; code[001450] = &I01450;
  core[001451] = 01067; code[001451] = &I01451;
  core[001452] = 01021; code[001452] = &I01452;
  core[001453] = 07040; code[001453] = &I01453;
  core[001454] = 07430; code[001454] = &I01454;
  core[001455] = 07440; code[001455] = &I01455;
  core[001456] = 07402; code[001456] = &I01456;
  core[001457] = 07200; code[001457] = &I01457;
  core[001460] = 07100; code[001460] = &I01460;
  core[001461] = 01021; code[001461] = &I01461;
  core[001462] = 07010; code[001462] = &I01462;
  core[001463] = 07420; code[001463] = &I01463;
  core[001464] = 07402; code[001464] = &I01464;
  core[001465] = 07200; code[001465] = &I01465;
  core[001466] = 07100; code[001466] = &I01466;
  core[001467] = 01020; code[001467] = &I01467;
  core[001470] = 07010; code[001470] = &I01470;
  core[001471] = 07440; code[001471] = &I01471;
  core[001472] = 07402; code[001472] = &I01472;
  core[001473] = 07200; code[001473] = &I01473;
  core[001474] = 07100; code[001474] = &I01474;
  core[001475] = 01020; code[001475] = &I01475;
  core[001476] = 07010; code[001476] = &I01476;
  core[001477] = 07430; code[001477] = &I01477;
  core[001500] = 07402; code[001500] = &I01500;
  core[001501] = 07200; code[001501] = &I01501;
  core[001502] = 07100; code[001502] = &I01502;
  core[001503] = 07020; code[001503] = &I01503;
  core[001504] = 01020; code[001504] = &I01504;
  core[001505] = 07010; code[001505] = &I01505;
  core[001506] = 07430; code[001506] = &I01506;
  core[001507] = 07402; code[001507] = &I01507;
  core[001510] = 07200; code[001510] = &I01510;
  core[001511] = 07100; code[001511] = &I01511;
  core[001512] = 07020; code[001512] = &I01512;
  core[001513] = 01067; code[001513] = &I01513;
  core[001514] = 07010; code[001514] = &I01514;
  core[001515] = 07040; code[001515] = &I01515;
  core[001516] = 07440; code[001516] = &I01516;
  core[001517] = 07402; code[001517] = &I01517;
  core[001520] = 07200; code[001520] = &I01520;
  core[001521] = 07100; code[001521] = &I01521;
  core[001522] = 07020; code[001522] = &I01522;
  core[001523] = 01020; code[001523] = &I01523;
  core[001524] = 07010; code[001524] = &I01524;
  core[001525] = 01066; code[001525] = &I01525;
  core[001526] = 07040; code[001526] = &I01526;
  core[001527] = 07450; code[001527] = &I01527;
  core[001530] = 07430; code[001530] = &I01530;
  core[001531] = 07402; code[001531] = &I01531;
  core[001532] = 07200; code[001532] = &I01532;
  core[001533] = 07100; code[001533] = &I01533;
  core[001534] = 01050; code[001534] = &I01534;
  core[001535] = 07010; code[001535] = &I01535;
  core[001536] = 01065; code[001536] = &I01536;
  core[001537] = 07040; code[001537] = &I01537;
  core[001540] = 07450; code[001540] = &I01540;
  core[001541] = 07430; code[001541] = &I01541;
  core[001542] = 07402; code[001542] = &I01542;
  core[001543] = 07200; code[001543] = &I01543;
  core[001544] = 07100; code[001544] = &I01544;
  core[001545] = 01045; code[001545] = &I01545;
  core[001546] = 07010; code[001546] = &I01546;
  core[001547] = 01064; code[001547] = &I01547;
  core[001550] = 07040; code[001550] = &I01550;
  core[001551] = 07450; code[001551] = &I01551;
  core[001552] = 07430; code[001552] = &I01552;
  core[001553] = 07402; code[001553] = &I01553;
  core[001554] = 07200; code[001554] = &I01554;
  core[001555] = 07100; code[001555] = &I01555;
  core[001556] = 01042; code[001556] = &I01556;
  core[001557] = 07010; code[001557] = &I01557;
  core[001560] = 01063; code[001560] = &I01560;
  core[001561] = 07040; code[001561] = &I01561;
  core[001562] = 07450; code[001562] = &I01562;
  core[001563] = 07430; code[001563] = &I01563;
  core[001564] = 07402; code[001564] = &I01564;
  core[001565] = 07200; code[001565] = &I01565;
  core[001566] = 07100; code[001566] = &I01566;
  core[001567] = 01040; code[001567] = &I01567;
  core[001570] = 07010; code[001570] = &I01570;
  core[001571] = 01062; code[001571] = &I01571;
  core[001572] = 07040; code[001572] = &I01572;
  core[001573] = 07450; code[001573] = &I01573;
  core[001574] = 07430; code[001574] = &I01574;
  core[001575] = 07402; code[001575] = &I01575;
  core[001576] = 07200; code[001576] = &I01576;
  core[001577] = 07100; code[001577] = &I01577;
  core[001600] = 01036; code[001600] = &I01600;
  core[001601] = 07010; code[001601] = &I01601;
  core[001602] = 01061; code[001602] = &I01602;
  core[001603] = 07040; code[001603] = &I01603;
  core[001604] = 07450; code[001604] = &I01604;
  core[001605] = 07430; code[001605] = &I01605;
  core[001606] = 07402; code[001606] = &I01606;
  core[001607] = 07200; code[001607] = &I01607;
  core[001610] = 07100; code[001610] = &I01610;
  core[001611] = 01034; code[001611] = &I01611;
  core[001612] = 07010; code[001612] = &I01612;
  core[001613] = 01057; code[001613] = &I01613;
  core[001614] = 07040; code[001614] = &I01614;
  core[001615] = 07450; code[001615] = &I01615;
  core[001616] = 07430; code[001616] = &I01616;
  core[001617] = 07402; code[001617] = &I01617;
  core[001620] = 07200; code[001620] = &I01620;
  core[001621] = 07100; code[001621] = &I01621;
  core[001622] = 01032; code[001622] = &I01622;
  core[001623] = 07010; code[001623] = &I01623;
  core[001624] = 01056; code[001624] = &I01624;
  core[001625] = 07040; code[001625] = &I01625;
  core[001626] = 07450; code[001626] = &I01626;
  core[001627] = 07430; code[001627] = &I01627;
  core[001630] = 07402; code[001630] = &I01630;
  core[001631] = 07200; code[001631] = &I01631;
  core[001632] = 07100; code[001632] = &I01632;
  core[001633] = 01030; code[001633] = &I01633;
  core[001634] = 07010; code[001634] = &I01634;
  core[001635] = 01055; code[001635] = &I01635;
  core[001636] = 07040; code[001636] = &I01636;
  core[001637] = 07450; code[001637] = &I01637;
  core[001640] = 07430; code[001640] = &I01640;
  core[001641] = 07402; code[001641] = &I01641;
  core[001642] = 07200; code[001642] = &I01642;
  core[001643] = 07100; code[001643] = &I01643;
  core[001644] = 01026; code[001644] = &I01644;
  core[001645] = 07010; code[001645] = &I01645;
  core[001646] = 01054; code[001646] = &I01646;
  core[001647] = 07040; code[001647] = &I01647;
  core[001650] = 07450; code[001650] = &I01650;
  core[001651] = 07430; code[001651] = &I01651;
  core[001652] = 07402; code[001652] = &I01652;
  core[001653] = 07200; code[001653] = &I01653;
  core[001654] = 07100; code[001654] = &I01654;
  core[001655] = 01024; code[001655] = &I01655;
  core[001656] = 07010; code[001656] = &I01656;
  core[001657] = 01053; code[001657] = &I01657;
  core[001660] = 07040; code[001660] = &I01660;
  core[001661] = 07450; code[001661] = &I01661;
  core[001662] = 07430; code[001662] = &I01662;
  core[001663] = 07402; code[001663] = &I01663;
  core[001664] = 07200; code[001664] = &I01664;
  core[001665] = 07100; code[001665] = &I01665;
  core[001666] = 01022; code[001666] = &I01666;
  core[001667] = 07010; code[001667] = &I01667;
  core[001670] = 01052; code[001670] = &I01670;
  core[001671] = 07040; code[001671] = &I01671;
  core[001672] = 07450; code[001672] = &I01672;
  core[001673] = 07430; code[001673] = &I01673;
  core[001674] = 07402; code[001674] = &I01674;
  core[001675] = 07200; code[001675] = &I01675;
  core[001676] = 07100; code[001676] = &I01676;
  core[001677] = 01021; code[001677] = &I01677;
  core[001700] = 07010; code[001700] = &I01700;
  core[001701] = 01067; code[001701] = &I01701;
  core[001702] = 07040; code[001702] = &I01702;
  core[001703] = 07450; code[001703] = &I01703;
  core[001704] = 07420; code[001704] = &I01704;
  core[001705] = 07402; code[001705] = &I01705;
  core[001706] = 07200; code[001706] = &I01706;
  core[001707] = 07100; code[001707] = &I01707;
  core[001710] = 01022; code[001710] = &I01710;
  core[001711] = 07012; code[001711] = &I01711;
  core[001712] = 07420; code[001712] = &I01712;
  core[001713] = 07402; code[001713] = &I01713;
  core[001714] = 07200; code[001714] = &I01714;
  core[001715] = 07100; code[001715] = &I01715;
  core[001716] = 01020; code[001716] = &I01716;
  core[001717] = 07012; code[001717] = &I01717;
  core[001720] = 07440; code[001720] = &I01720;
  core[001721] = 07402; code[001721] = &I01721;
  core[001722] = 07200; code[001722] = &I01722;
  core[001723] = 07100; code[001723] = &I01723;
  core[001724] = 01020; code[001724] = &I01724;
  core[001725] = 07012; code[001725] = &I01725;
  core[001726] = 07430; code[001726] = &I01726;
  core[001727] = 07402; code[001727] = &I01727;
  core[001730] = 07200; code[001730] = &I01730;
  core[001731] = 07100; code[001731] = &I01731;
  core[001732] = 07020; code[001732] = &I01732;
  core[001733] = 01020; code[001733] = &I01733;
  core[001734] = 07012; code[001734] = &I01734;
  core[001735] = 07430; code[001735] = &I01735;
  core[001736] = 07402; code[001736] = &I01736;
  core[001737] = 07200; code[001737] = &I01737;
  core[001740] = 07100; code[001740] = &I01740;
  core[001741] = 07020; code[001741] = &I01741;
  core[001742] = 01067; code[001742] = &I01742;
  core[001743] = 07012; code[001743] = &I01743;
  core[001744] = 07040; code[001744] = &I01744;
  core[001745] = 07440; code[001745] = &I01745;
  core[001746] = 07402; code[001746] = &I01746;
  core[001747] = 07200; code[001747] = &I01747;
  core[001750] = 07100; code[001750] = &I01750;
  core[001751] = 07020; code[001751] = &I01751;
  core[001752] = 01020; code[001752] = &I01752;
  core[001753] = 07012; code[001753] = &I01753;
  core[001754] = 01065; code[001754] = &I01754;
  core[001755] = 07040; code[001755] = &I01755;
  core[001756] = 07450; code[001756] = &I01756;
  core[001757] = 07430; code[001757] = &I01757;
  core[001760] = 07402; code[001760] = &I01760;
  core[001761] = 07200; code[001761] = &I01761;
  core[001762] = 07100; code[001762] = &I01762;
  core[001763] = 01050; code[001763] = &I01763;
  core[001764] = 07012; code[001764] = &I01764;
  core[001765] = 01064; code[001765] = &I01765;
  core[001766] = 07040; code[001766] = &I01766;
  core[001767] = 07450; code[001767] = &I01767;
  core[001770] = 07430; code[001770] = &I01770;
  core[001771] = 07402; code[001771] = &I01771;
  core[001772] = 07200; code[001772] = &I01772;
  core[001773] = 07100; code[001773] = &I01773;
  core[001774] = 01045; code[001774] = &I01774;
  core[001775] = 07012; code[001775] = &I01775;
  core[001776] = 01063; code[001776] = &I01776;
  core[001777] = 07040; code[001777] = &I01777;
  core[002000] = 07450; code[002000] = &I02000;
  core[002001] = 07430; code[002001] = &I02001;
  core[002002] = 07402; code[002002] = &I02002;
  core[002003] = 07200; code[002003] = &I02003;
  core[002004] = 07100; code[002004] = &I02004;
  core[002005] = 01042; code[002005] = &I02005;
  core[002006] = 07012; code[002006] = &I02006;
  core[002007] = 01062; code[002007] = &I02007;
  core[002010] = 07040; code[002010] = &I02010;
  core[002011] = 07450; code[002011] = &I02011;
  core[002012] = 07430; code[002012] = &I02012;
  core[002013] = 07402; code[002013] = &I02013;
  core[002014] = 07200; code[002014] = &I02014;
  core[002015] = 07100; code[002015] = &I02015;
  core[002016] = 01040; code[002016] = &I02016;
  core[002017] = 07012; code[002017] = &I02017;
  core[002020] = 01061; code[002020] = &I02020;
  core[002021] = 07040; code[002021] = &I02021;
  core[002022] = 07450; code[002022] = &I02022;
  core[002023] = 07430; code[002023] = &I02023;
  core[002024] = 07402; code[002024] = &I02024;
  core[002025] = 07200; code[002025] = &I02025;
  core[002026] = 07100; code[002026] = &I02026;
  core[002027] = 01036; code[002027] = &I02027;
  core[002030] = 07012; code[002030] = &I02030;
  core[002031] = 01057; code[002031] = &I02031;
  core[002032] = 07040; code[002032] = &I02032;
  core[002033] = 07450; code[002033] = &I02033;
  core[002034] = 07430; code[002034] = &I02034;
  core[002035] = 07402; code[002035] = &I02035;
  core[002036] = 07200; code[002036] = &I02036;
  core[002037] = 07100; code[002037] = &I02037;
  core[002040] = 01034; code[002040] = &I02040;
  core[002041] = 07012; code[002041] = &I02041;
  core[002042] = 01056; code[002042] = &I02042;
  core[002043] = 07040; code[002043] = &I02043;
  core[002044] = 07450; code[002044] = &I02044;
  core[002045] = 07430; code[002045] = &I02045;
  core[002046] = 07402; code[002046] = &I02046;
  core[002047] = 07200; code[002047] = &I02047;
  core[002050] = 07100; code[002050] = &I02050;
  core[002051] = 01032; code[002051] = &I02051;
  core[002052] = 07012; code[002052] = &I02052;
  core[002053] = 01055; code[002053] = &I02053;
  core[002054] = 07040; code[002054] = &I02054;
  core[002055] = 07450; code[002055] = &I02055;
  core[002056] = 07430; code[002056] = &I02056;
  core[002057] = 07402; code[002057] = &I02057;
  core[002060] = 07200; code[002060] = &I02060;
  core[002061] = 07100; code[002061] = &I02061;
  core[002062] = 01030; code[002062] = &I02062;
  core[002063] = 07012; code[002063] = &I02063;
  core[002064] = 01054; code[002064] = &I02064;
  core[002065] = 07040; code[002065] = &I02065;
  core[002066] = 07450; code[002066] = &I02066;
  core[002067] = 07430; code[002067] = &I02067;
  core[002070] = 07402; code[002070] = &I02070;
  core[002071] = 07200; code[002071] = &I02071;
  core[002072] = 07100; code[002072] = &I02072;
  core[002073] = 01026; code[002073] = &I02073;
  core[002074] = 07012; code[002074] = &I02074;
  core[002075] = 01053; code[002075] = &I02075;
  core[002076] = 07040; code[002076] = &I02076;
  core[002077] = 07450; code[002077] = &I02077;
  core[002100] = 07430; code[002100] = &I02100;
  core[002101] = 07402; code[002101] = &I02101;
  core[002102] = 07300; code[002102] = &I02102;
  core[002103] = 01024; code[002103] = &I02103;
  core[002104] = 07012; code[002104] = &I02104;
  core[002105] = 01052; code[002105] = &I02105;
  core[002106] = 07040; code[002106] = &I02106;
  core[002107] = 07450; code[002107] = &I02107;
  core[002110] = 07430; code[002110] = &I02110;
  core[002111] = 07402; code[002111] = &I02111;
  core[002112] = 07200; code[002112] = &I02112;
  core[002113] = 07100; code[002113] = &I02113;
  core[002114] = 01022; code[002114] = &I02114;
  core[002115] = 07012; code[002115] = &I02115;
  core[002116] = 07450; code[002116] = &I02116;
  core[002117] = 07420; code[002117] = &I02117;
  core[002120] = 07402; code[002120] = &I02120;
  core[002121] = 07200; code[002121] = &I02121;
  core[002122] = 07100; code[002122] = &I02122;
  core[002123] = 01021; code[002123] = &I02123;
  core[002124] = 07012; code[002124] = &I02124;
  core[002125] = 01066; code[002125] = &I02125;
  core[002126] = 07040; code[002126] = &I02126;
  core[002127] = 07450; code[002127] = &I02127;
  core[002130] = 07430; code[002130] = &I02130;
  core[002131] = 07402; code[002131] = &I02131;
  core[002132] = 07200; code[002132] = &I02132;
  core[002133] = 07100; code[002133] = &I02133;
  core[002134] = 01050; code[002134] = &I02134;
  core[002135] = 07004; code[002135] = &I02135;
  core[002136] = 07430; code[002136] = &I02136;
  core[002137] = 07440; code[002137] = &I02137;
  core[002140] = 07402; code[002140] = &I02140;
  core[002141] = 07200; code[002141] = &I02141;
  core[002142] = 07100; code[002142] = &I02142;
  core[002143] = 01020; code[002143] = &I02143;
  core[002144] = 07004; code[002144] = &I02144;
  core[002145] = 07420; code[002145] = &I02145;
  core[002146] = 07440; code[002146] = &I02146;
  core[002147] = 07402; code[002147] = &I02147;
  core[002150] = 07200; code[002150] = &I02150;
  core[002151] = 07100; code[002151] = &I02151;
  core[002152] = 07020; code[002152] = &I02152;
  core[002153] = 01020; code[002153] = &I02153;
  core[002154] = 07004; code[002154] = &I02154;
  core[002155] = 07430; code[002155] = &I02155;
  core[002156] = 07402; code[002156] = &I02156;
  core[002157] = 07200; code[002157] = &I02157;
  core[002160] = 07100; code[002160] = &I02160;
  core[002161] = 07020; code[002161] = &I02161;
  core[002162] = 01067; code[002162] = &I02162;
  core[002163] = 07004; code[002163] = &I02163;
  core[002164] = 07040; code[002164] = &I02164;
  core[002165] = 07440; code[002165] = &I02165;
  core[002166] = 07402; code[002166] = &I02166;
  core[002167] = 07200; code[002167] = &I02167;
  core[002170] = 07100; code[002170] = &I02170;
  core[002171] = 01045; code[002171] = &I02171;
  core[002172] = 07004; code[002172] = &I02172;
  core[002173] = 01066; code[002173] = &I02173;
  core[002174] = 07040; code[002174] = &I02174;
  core[002175] = 07450; code[002175] = &I02175;
  core[002176] = 07430; code[002176] = &I02176;
  core[002177] = 07402; code[002177] = &I02177;
  core[002200] = 07200; code[002200] = &I02200;
  core[002201] = 07100; code[002201] = &I02201;
  core[002202] = 01042; code[002202] = &I02202;
  core[002203] = 07004; code[002203] = &I02203;
  core[002204] = 01065; code[002204] = &I02204;
  core[002205] = 07040; code[002205] = &I02205;
  core[002206] = 07440; code[002206] = &I02206;
  core[002207] = 07402; code[002207] = &I02207;
  core[002210] = 07200; code[002210] = &I02210;
  core[002211] = 07100; code[002211] = &I02211;
  core[002212] = 01040; code[002212] = &I02212;
  core[002213] = 07004; code[002213] = &I02213;
  core[002214] = 01064; code[002214] = &I02214;
  core[002215] = 07040; code[002215] = &I02215;
  core[002216] = 07450; code[002216] = &I02216;
  core[002217] = 07430; code[002217] = &I02217;
  core[002220] = 07402; code[002220] = &I02220;
  core[002221] = 07200; code[002221] = &I02221;
  core[002222] = 07100; code[002222] = &I02222;
  core[002223] = 01036; code[002223] = &I02223;
  core[002224] = 07004; code[002224] = &I02224;
  core[002225] = 01063; code[002225] = &I02225;
  core[002226] = 07040; code[002226] = &I02226;
  core[002227] = 07450; code[002227] = &I02227;
  core[002230] = 07430; code[002230] = &I02230;
  core[002231] = 07402; code[002231] = &I02231;
  core[002232] = 07200; code[002232] = &I02232;
  core[002233] = 07100; code[002233] = &I02233;
  core[002234] = 01034; code[002234] = &I02234;
  core[002235] = 07004; code[002235] = &I02235;
  core[002236] = 01062; code[002236] = &I02236;
  core[002237] = 07040; code[002237] = &I02237;
  core[002240] = 07450; code[002240] = &I02240;
  core[002241] = 07430; code[002241] = &I02241;
  core[002242] = 07402; code[002242] = &I02242;
  core[002243] = 07200; code[002243] = &I02243;
  core[002244] = 07100; code[002244] = &I02244;
  core[002245] = 01032; code[002245] = &I02245;
  core[002246] = 07004; code[002246] = &I02246;
  core[002247] = 01061; code[002247] = &I02247;
  core[002250] = 07040; code[002250] = &I02250;
  core[002251] = 07450; code[002251] = &I02251;
  core[002252] = 07430; code[002252] = &I02252;
  core[002253] = 07402; code[002253] = &I02253;
  core[002254] = 07200; code[002254] = &I02254;
  core[002255] = 07100; code[002255] = &I02255;
  core[002256] = 01030; code[002256] = &I02256;
  core[002257] = 07004; code[002257] = &I02257;
  core[002260] = 01057; code[002260] = &I02260;
  core[002261] = 07040; code[002261] = &I02261;
  core[002262] = 07450; code[002262] = &I02262;
  core[002263] = 07430; code[002263] = &I02263;
  core[002264] = 07402; code[002264] = &I02264;
  core[002265] = 07200; code[002265] = &I02265;
  core[002266] = 07100; code[002266] = &I02266;
  core[002267] = 01026; code[002267] = &I02267;
  core[002270] = 07004; code[002270] = &I02270;
  core[002271] = 01056; code[002271] = &I02271;
  core[002272] = 07040; code[002272] = &I02272;
  core[002273] = 07450; code[002273] = &I02273;
  core[002274] = 07430; code[002274] = &I02274;
  core[002275] = 07402; code[002275] = &I02275;
  core[002276] = 07200; code[002276] = &I02276;
  core[002277] = 07100; code[002277] = &I02277;
  core[002300] = 01024; code[002300] = &I02300;
  core[002301] = 07004; code[002301] = &I02301;
  core[002302] = 01055; code[002302] = &I02302;
  core[002303] = 07040; code[002303] = &I02303;
  core[002304] = 07450; code[002304] = &I02304;
  core[002305] = 07430; code[002305] = &I02305;
  core[002306] = 07402; code[002306] = &I02306;
  core[002307] = 07200; code[002307] = &I02307;
  core[002310] = 07100; code[002310] = &I02310;
  core[002311] = 01022; code[002311] = &I02311;
  core[002312] = 07004; code[002312] = &I02312;
  core[002313] = 01054; code[002313] = &I02313;
  core[002314] = 07040; code[002314] = &I02314;
  core[002315] = 07450; code[002315] = &I02315;
  core[002316] = 07430; code[002316] = &I02316;
  core[002317] = 07402; code[002317] = &I02317;
  core[002320] = 07200; code[002320] = &I02320;
  core[002321] = 07100; code[002321] = &I02321;
  core[002322] = 01021; code[002322] = &I02322;
  core[002323] = 07004; code[002323] = &I02323;
  core[002324] = 01053; code[002324] = &I02324;
  core[002325] = 07040; code[002325] = &I02325;
  core[002326] = 07450; code[002326] = &I02326;
  core[002327] = 07430; code[002327] = &I02327;
  core[002330] = 07402; code[002330] = &I02330;
  core[002331] = 07200; code[002331] = &I02331;
  core[002332] = 07100; code[002332] = &I02332;
  core[002333] = 07020; code[002333] = &I02333;
  core[002334] = 07004; code[002334] = &I02334;
  core[002335] = 01052; code[002335] = &I02335;
  core[002336] = 07040; code[002336] = &I02336;
  core[002337] = 07450; code[002337] = &I02337;
  core[002340] = 07430; code[002340] = &I02340;
  core[002341] = 07402; code[002341] = &I02341;
  core[002342] = 07200; code[002342] = &I02342;
  core[002343] = 07100; code[002343] = &I02343;
  core[002344] = 01045; code[002344] = &I02344;
  core[002345] = 07006; code[002345] = &I02345;
  core[002346] = 07420; code[002346] = &I02346;
  core[002347] = 07402; code[002347] = &I02347;
  core[002350] = 07200; code[002350] = &I02350;
  core[002351] = 07100; code[002351] = &I02351;
  core[002352] = 01020; code[002352] = &I02352;
  core[002353] = 07006; code[002353] = &I02353;
  core[002354] = 07440; code[002354] = &I02354;
  core[002355] = 07402; code[002355] = &I02355;
  core[002356] = 07200; code[002356] = &I02356;
  core[002357] = 07100; code[002357] = &I02357;
  core[002360] = 01020; code[002360] = &I02360;
  core[002361] = 07006; code[002361] = &I02361;
  core[002362] = 07430; code[002362] = &I02362;
  core[002363] = 07402; code[002363] = &I02363;
  core[002364] = 07200; code[002364] = &I02364;
  core[002365] = 07100; code[002365] = &I02365;
  core[002366] = 07020; code[002366] = &I02366;
  core[002367] = 01020; code[002367] = &I02367;
  core[002370] = 07006; code[002370] = &I02370;
  core[002371] = 07430; code[002371] = &I02371;
  core[002372] = 07402; code[002372] = &I02372;
  core[002373] = 07200; code[002373] = &I02373;
  core[002374] = 07100; code[002374] = &I02374;
  core[002375] = 07020; code[002375] = &I02375;
  core[002376] = 01067; code[002376] = &I02376;
  core[002377] = 07006; code[002377] = &I02377;
  core[002400] = 07040; code[002400] = &I02400;
  core[002401] = 07440; code[002401] = &I02401;
  core[002402] = 07402; code[002402] = &I02402;
  core[002403] = 07200; code[002403] = &I02403;
  core[002404] = 07100; code[002404] = &I02404;
  core[002405] = 01050; code[002405] = &I02405;
  core[002406] = 07006; code[002406] = &I02406;
  core[002407] = 01052; code[002407] = &I02407;
  core[002410] = 07040; code[002410] = &I02410;
  core[002411] = 07450; code[002411] = &I02411;
  core[002412] = 07430; code[002412] = &I02412;
  core[002413] = 07402; code[002413] = &I02413;
  core[002414] = 07200; code[002414] = &I02414;
  core[002415] = 07100; code[002415] = &I02415;
  core[002416] = 01045; code[002416] = &I02416;
  core[002417] = 07006; code[002417] = &I02417;
  core[002420] = 07450; code[002420] = &I02420;
  core[002421] = 07420; code[002421] = &I02421;
  core[002422] = 07402; code[002422] = &I02422;
  core[002423] = 07200; code[002423] = &I02423;
  core[002424] = 07100; code[002424] = &I02424;
  core[002425] = 01042; code[002425] = &I02425;
  core[002426] = 07006; code[002426] = &I02426;
  core[002427] = 01066; code[002427] = &I02427;
  core[002430] = 07040; code[002430] = &I02430;
  core[002431] = 07450; code[002431] = &I02431;
  core[002432] = 07430; code[002432] = &I02432;
  core[002433] = 07402; code[002433] = &I02433;
  core[002434] = 07200; code[002434] = &I02434;
  core[002435] = 07100; code[002435] = &I02435;
  core[002436] = 01040; code[002436] = &I02436;
  core[002437] = 07006; code[002437] = &I02437;
  core[002440] = 01065; code[002440] = &I02440;
  core[002441] = 07040; code[002441] = &I02441;
  core[002442] = 07450; code[002442] = &I02442;
  core[002443] = 07430; code[002443] = &I02443;
  core[002444] = 07402; code[002444] = &I02444;
  core[002445] = 07200; code[002445] = &I02445;
  core[002446] = 07100; code[002446] = &I02446;
  core[002447] = 01036; code[002447] = &I02447;
  core[002450] = 07006; code[002450] = &I02450;
  core[002451] = 01064; code[002451] = &I02451;
  core[002452] = 07040; code[002452] = &I02452;
  core[002453] = 07450; code[002453] = &I02453;
  core[002454] = 07430; code[002454] = &I02454;
  core[002455] = 07402; code[002455] = &I02455;
  core[002456] = 07200; code[002456] = &I02456;
  core[002457] = 07100; code[002457] = &I02457;
  core[002460] = 01034; code[002460] = &I02460;
  core[002461] = 07006; code[002461] = &I02461;
  core[002462] = 01063; code[002462] = &I02462;
  core[002463] = 07040; code[002463] = &I02463;
  core[002464] = 07450; code[002464] = &I02464;
  core[002465] = 07430; code[002465] = &I02465;
  core[002466] = 07402; code[002466] = &I02466;
  core[002467] = 07200; code[002467] = &I02467;
  core[002470] = 07100; code[002470] = &I02470;
  core[002471] = 01032; code[002471] = &I02471;
  core[002472] = 07006; code[002472] = &I02472;
  core[002473] = 01062; code[002473] = &I02473;
  core[002474] = 07040; code[002474] = &I02474;
  core[002475] = 07450; code[002475] = &I02475;
  core[002476] = 07430; code[002476] = &I02476;
  core[002477] = 07402; code[002477] = &I02477;
  core[002500] = 07200; code[002500] = &I02500;
  core[002501] = 07100; code[002501] = &I02501;
  core[002502] = 01030; code[002502] = &I02502;
  core[002503] = 07006; code[002503] = &I02503;
  core[002504] = 01061; code[002504] = &I02504;
  core[002505] = 07040; code[002505] = &I02505;
  core[002506] = 07450; code[002506] = &I02506;
  core[002507] = 07430; code[002507] = &I02507;
  core[002510] = 07402; code[002510] = &I02510;
  core[002511] = 07200; code[002511] = &I02511;
  core[002512] = 07100; code[002512] = &I02512;
  core[002513] = 01026; code[002513] = &I02513;
  core[002514] = 07006; code[002514] = &I02514;
  core[002515] = 01057; code[002515] = &I02515;
  core[002516] = 07040; code[002516] = &I02516;
  core[002517] = 07450; code[002517] = &I02517;
  core[002520] = 07430; code[002520] = &I02520;
  core[002521] = 07402; code[002521] = &I02521;
  core[002522] = 07200; code[002522] = &I02522;
  core[002523] = 07100; code[002523] = &I02523;
  core[002524] = 01024; code[002524] = &I02524;
  core[002525] = 07006; code[002525] = &I02525;
  core[002526] = 01056; code[002526] = &I02526;
  core[002527] = 07040; code[002527] = &I02527;
  core[002530] = 07450; code[002530] = &I02530;
  core[002531] = 07430; code[002531] = &I02531;
  core[002532] = 07402; code[002532] = &I02532;
  core[002533] = 07200; code[002533] = &I02533;
  core[002534] = 07100; code[002534] = &I02534;
  core[002535] = 01022; code[002535] = &I02535;
  core[002536] = 07006; code[002536] = &I02536;
  core[002537] = 01055; code[002537] = &I02537;
  core[002540] = 07040; code[002540] = &I02540;
  core[002541] = 07450; code[002541] = &I02541;
  core[002542] = 07430; code[002542] = &I02542;
  core[002543] = 07402; code[002543] = &I02543;
  core[002544] = 07200; code[002544] = &I02544;
  core[002545] = 07100; code[002545] = &I02545;
  core[002546] = 01021; code[002546] = &I02546;
  core[002547] = 07006; code[002547] = &I02547;
  core[002550] = 01054; code[002550] = &I02550;
  core[002551] = 07040; code[002551] = &I02551;
  core[002552] = 07450; code[002552] = &I02552;
  core[002553] = 07430; code[002553] = &I02553;
  core[002554] = 07402; code[002554] = &I02554;
  core[002555] = 07200; code[002555] = &I02555;
  core[002556] = 07100; code[002556] = &I02556;
  core[002557] = 07020; code[002557] = &I02557;
  core[002560] = 07006; code[002560] = &I02560;
  core[002561] = 01053; code[002561] = &I02561;
  core[002562] = 07040; code[002562] = &I02562;
  core[002563] = 07450; code[002563] = &I02563;
  core[002564] = 07430; code[002564] = &I02564;
  core[002565] = 07402; code[002565] = &I02565;
  core[002566] = 07200; code[002566] = &I02566;
  core[002567] = 07100; code[002567] = &I02567;
  core[002570] = 07040; code[002570] = &I02570;
  core[002571] = 07002; code[002571] = &I02571;
  core[002572] = 07040; code[002572] = &I02572;
  core[002573] = 07420; code[002573] = &I02573;
  core[002574] = 07440; code[002574] = &I02574;
  core[002575] = 07402; code[002575] = &I02575;
  core[002576] = 07200; code[002576] = &I02576;
  core[002577] = 07100; code[002577] = &I02577;
  core[002600] = 07020; code[002600] = &I02600;
  core[002601] = 07002; code[002601] = &I02601;
  core[002602] = 07450; code[002602] = &I02602;
  core[002603] = 07420; code[002603] = &I02603;
  core[002604] = 07402; code[002604] = &I02604;
  core[002605] = 07200; code[002605] = &I02605;
  core[002606] = 07100; code[002606] = &I02606;
  core[002607] = 01113; code[002607] = &I02607;
  core[002610] = 07002; code[002610] = &I02610;
  core[002611] = 01113; code[002611] = &I02611;
  core[002612] = 07040; code[002612] = &I02612;
  core[002613] = 07420; code[002613] = &I02613;
  core[002614] = 07440; code[002614] = &I02614;
  core[002615] = 07402; code[002615] = &I02615;
  core[002616] = 07200; code[002616] = &I02616;
  core[002617] = 07100; code[002617] = &I02617;
  core[002620] = 01106; code[002620] = &I02620;
  core[002621] = 07002; code[002621] = &I02621;
  core[002622] = 01106; code[002622] = &I02622;
  core[002623] = 07040; code[002623] = &I02623;
  core[002624] = 07420; code[002624] = &I02624;
  core[002625] = 07440; code[002625] = &I02625;
  core[002626] = 07402; code[002626] = &I02626;
  core[002627] = 07300; code[002627] = &I02627;
  core[002630] = 01116; code[002630] = &I02630;
  core[002631] = 07002; code[002631] = &I02631;
  core[002632] = 01116; code[002632] = &I02632;
  core[002633] = 07040; code[002633] = &I02633;
  core[002634] = 07420; code[002634] = &I02634;
  core[002635] = 07440; code[002635] = &I02635;
  core[002636] = 07402; code[002636] = &I02636;
  core[002637] = 07320; code[002637] = &I02637;
  core[002640] = 01117; code[002640] = &I02640;
  core[002641] = 07002; code[002641] = &I02641;
  core[002642] = 01117; code[002642] = &I02642;
  core[002643] = 07040; code[002643] = &I02643;
  core[002644] = 07430; code[002644] = &I02644;
  core[002645] = 07440; code[002645] = &I02645;
  core[002646] = 07402; code[002646] = &I02646;
  core[002647] = 07200; code[002647] = &I02647;
  core[002650] = 07100; code[002650] = &I02650;
  core[002651] = 01114; code[002651] = &I02651;
  core[002652] = 07002; code[002652] = &I02652;
  core[002653] = 01114; code[002653] = &I02653;
  core[002654] = 07040; code[002654] = &I02654;
  core[002655] = 07420; code[002655] = &I02655;
  core[002656] = 07440; code[002656] = &I02656;
  core[002657] = 07402; code[002657] = &I02657;
  core[002660] = 07200; code[002660] = &I02660;
  core[002661] = 07100; code[002661] = &I02661;
  core[002662] = 01115; code[002662] = &I02662;
  core[002663] = 07002; code[002663] = &I02663;
  core[002664] = 01115; code[002664] = &I02664;
  core[002665] = 07040; code[002665] = &I02665;
  core[002666] = 07420; code[002666] = &I02666;
  core[002667] = 07440; code[002667] = &I02667;
  core[002670] = 07402; code[002670] = &I02670;
  core[002671] = 07200; code[002671] = &I02671;
  core[002672] = 07100; code[002672] = &I02672;
  core[002673] = 07040; code[002673] = &I02673;
  core[002674] = 07020; code[002674] = &I02674;
  core[002675] = 07300; code[002675] = &I02675;
  core[002676] = 07420; code[002676] = &I02676;
  core[002677] = 07440; code[002677] = &I02677;
  core[002700] = 07402; code[002700] = &I02700;
  core[002701] = 07200; code[002701] = &I02701;
  core[002702] = 01071; code[002702] = &I02702;
  core[002703] = 07240; code[002703] = &I02703;
  core[002704] = 07040; code[002704] = &I02704;
  core[002705] = 07440; code[002705] = &I02705;
  core[002706] = 07402; code[002706] = &I02706;
  core[002707] = 07200; code[002707] = &I02707;
  core[002710] = 07100; code[002710] = &I02710;
  core[002711] = 07040; code[002711] = &I02711;
  core[002712] = 07140; code[002712] = &I02712;
  core[002713] = 07420; code[002713] = &I02713;
  core[002714] = 07440; code[002714] = &I02714;
  core[002715] = 07402; code[002715] = &I02715;
  core[002716] = 07100; code[002716] = &I02716;
  core[002717] = 07020; code[002717] = &I02717;
  core[002720] = 07200; code[002720] = &I02720;
  core[002721] = 07040; code[002721] = &I02721;
  core[002722] = 07340; code[002722] = &I02722;
  core[002723] = 07040; code[002723] = &I02723;
  core[002724] = 07420; code[002724] = &I02724;
  core[002725] = 07440; code[002725] = &I02725;
  core[002726] = 07402; code[002726] = &I02726;
  core[002727] = 07200; code[002727] = &I02727;
  core[002730] = 07100; code[002730] = &I02730;
  core[002731] = 07040; code[002731] = &I02731;
  core[002732] = 07220; code[002732] = &I02732;
  core[002733] = 07430; code[002733] = &I02733;
  core[002734] = 07440; code[002734] = &I02734;
  core[002735] = 07402; code[002735] = &I02735;
  core[002736] = 07100; code[002736] = &I02736;
  core[002737] = 07020; code[002737] = &I02737;
  core[002740] = 07120; code[002740] = &I02740;
  core[002741] = 07420; code[002741] = &I02741;
  core[002742] = 07402; code[002742] = &I02742;
  core[002743] = 07100; code[002743] = &I02743;
  core[002744] = 07120; code[002744] = &I02744;
  core[002745] = 07420; code[002745] = &I02745;
  core[002746] = 07402; code[002746] = &I02746;
  core[002747] = 07120; code[002747] = &I02747;
  core[002750] = 07240; code[002750] = &I02750;
  core[002751] = 07320; code[002751] = &I02751;
  core[002752] = 07430; code[002752] = &I02752;
  core[002753] = 07440; code[002753] = &I02753;
  core[002754] = 07402; code[002754] = &I02754;
  core[002755] = 07340; code[002755] = &I02755;
  core[002756] = 07320; code[002756] = &I02756;
  core[002757] = 07430; code[002757] = &I02757;
  core[002760] = 07440; code[002760] = &I02760;
  core[002761] = 07402; code[002761] = &I02761;
  core[002762] = 07340; code[002762] = &I02762;
  core[002763] = 07060; code[002763] = &I02763;
  core[002764] = 07430; code[002764] = &I02764;
  core[002765] = 07440; code[002765] = &I02765;
  core[002766] = 07402; code[002766] = &I02766;
  core[002767] = 07300; code[002767] = &I02767;
  core[002770] = 01071; code[002770] = &I02770;
  core[002771] = 07340; code[002771] = &I02771;
  core[002772] = 07040; code[002772] = &I02772;
  core[002773] = 07420; code[002773] = &I02773;
  core[002774] = 07440; code[002774] = &I02774;
  core[002775] = 07402; code[002775] = &I02775;
  core[002776] = 07300; code[002776] = &I02776;
  core[002777] = 01071; code[002777] = &I02777;
  core[003000] = 07160; code[003000] = &I03000;
  core[003001] = 01071; code[003001] = &I03001;
  core[003002] = 07040; code[003002] = &I03002;
  core[003003] = 07430; code[003003] = &I03003;
  core[003004] = 07440; code[003004] = &I03004;
  core[003005] = 07402; code[003005] = &I03005;
  core[003006] = 07300; code[003006] = &I03006;
  core[003007] = 07020; code[003007] = &I03007;
  core[003010] = 07160; code[003010] = &I03010;
  core[003011] = 07040; code[003011] = &I03011;
  core[003012] = 07430; code[003012] = &I03012;
  core[003013] = 07440; code[003013] = &I03013;
  core[003014] = 07402; code[003014] = &I03014;
  core[003015] = 07300; code[003015] = &I03015;
  core[003016] = 01071; code[003016] = &I03016;
  core[003017] = 07360; code[003017] = &I03017;
  core[003020] = 07040; code[003020] = &I03020;
  core[003021] = 07430; code[003021] = &I03021;
  core[003022] = 07440; code[003022] = &I03022;
  core[003023] = 07402; code[003023] = &I03023;
  core[003024] = 07320; code[003024] = &I03024;
  core[003025] = 01070; code[003025] = &I03025;
  core[003026] = 07360; code[003026] = &I03026;
  core[003027] = 07040; code[003027] = &I03027;
  core[003030] = 07430; code[003030] = &I03030;
  core[003031] = 07440; code[003031] = &I03031;
  core[003032] = 07402; code[003032] = &I03032;
  core[003033] = 07200; code[003033] = &I03033;
  core[003034] = 01071; code[003034] = &I03034;
  core[003035] = 07201; code[003035] = &I03035;
  core[003036] = 01052; code[003036] = &I03036;
  core[003037] = 07040; code[003037] = &I03037;
  core[003040] = 07440; code[003040] = &I03040;
  core[003041] = 07402; code[003041] = &I03041;
  core[003042] = 07320; code[003042] = &I03042;
  core[003043] = 01052; code[003043] = &I03043;
  core[003044] = 07101; code[003044] = &I03044;
  core[003045] = 07040; code[003045] = &I03045;
  core[003046] = 07420; code[003046] = &I03046;
  core[003047] = 07440; code[003047] = &I03047;
  core[003050] = 07402; code[003050] = &I03050;
  core[003051] = 07320; code[003051] = &I03051;
  core[003052] = 01071; code[003052] = &I03052;
  core[003053] = 07301; code[003053] = &I03053;
  core[003054] = 01052; code[003054] = &I03054;
  core[003055] = 07040; code[003055] = &I03055;
  core[003056] = 07420; code[003056] = &I03056;
  core[003057] = 07440; code[003057] = &I03057;
  core[003060] = 07402; code[003060] = &I03060;
  core[003061] = 07300; code[003061] = &I03061;
  core[003062] = 07041; code[003062] = &I03062;
  core[003063] = 07430; code[003063] = &I03063;
  core[003064] = 07440; code[003064] = &I03064;
  core[003065] = 07402; code[003065] = &I03065;
  core[003066] = 07300; code[003066] = &I03066;
  core[003067] = 01071; code[003067] = &I03067;
  core[003070] = 07241; code[003070] = &I03070;
  core[003071] = 07430; code[003071] = &I03071;
  core[003072] = 07440; code[003072] = &I03072;
  core[003073] = 07402; code[003073] = &I03073;
  core[003074] = 07320; code[003074] = &I03074;
  core[003075] = 01021; code[003075] = &I03075;
  core[003076] = 07141; code[003076] = &I03076;
  core[003077] = 07040; code[003077] = &I03077;
  core[003100] = 07420; code[003100] = &I03100;
  core[003101] = 07440; code[003101] = &I03101;
  core[003102] = 07402; code[003102] = &I03102;
  core[003103] = 07320; code[003103] = &I03103;
  core[003104] = 01071; code[003104] = &I03104;
  core[003105] = 07341; code[003105] = &I03105;
  core[003106] = 07430; code[003106] = &I03106;
  core[003107] = 07440; code[003107] = &I03107;
  core[003110] = 07402; code[003110] = &I03110;
  core[003111] = 07300; code[003111] = &I03111;
  core[003112] = 01070; code[003112] = &I03112;
  core[003113] = 07341; code[003113] = &I03113;
  core[003114] = 07430; code[003114] = &I03114;
  core[003115] = 07440; code[003115] = &I03115;
  core[003116] = 07402; code[003116] = &I03116;
  core[003117] = 07300; code[003117] = &I03117;
  core[003120] = 01052; code[003120] = &I03120;
  core[003121] = 07021; code[003121] = &I03121;
  core[003122] = 07040; code[003122] = &I03122;
  core[003123] = 07430; code[003123] = &I03123;
  core[003124] = 07440; code[003124] = &I03124;
  core[003125] = 07402; code[003125] = &I03125;
  core[003126] = 07320; code[003126] = &I03126;
  core[003127] = 01052; code[003127] = &I03127;
  core[003130] = 07021; code[003130] = &I03130;
  core[003131] = 07040; code[003131] = &I03131;
  core[003132] = 07420; code[003132] = &I03132;
  core[003133] = 07440; code[003133] = &I03133;
  core[003134] = 07402; code[003134] = &I03134;
  core[003135] = 07300; code[003135] = &I03135;
  core[003136] = 01071; code[003136] = &I03136;
  core[003137] = 07221; code[003137] = &I03137;
  core[003140] = 01052; code[003140] = &I03140;
  core[003141] = 07040; code[003141] = &I03141;
  core[003142] = 07430; code[003142] = &I03142;
  core[003143] = 07440; code[003143] = &I03143;
  core[003144] = 07402; code[003144] = &I03144;
  core[003145] = 07320; code[003145] = &I03145;
  core[003146] = 01052; code[003146] = &I03146;
  core[003147] = 07121; code[003147] = &I03147;
  core[003150] = 07040; code[003150] = &I03150;
  core[003151] = 07430; code[003151] = &I03151;
  core[003152] = 07440; code[003152] = &I03152;
  core[003153] = 07402; code[003153] = &I03153;
  core[003154] = 07300; code[003154] = &I03154;
  core[003155] = 01052; code[003155] = &I03155;
  core[003156] = 07121; code[003156] = &I03156;
  core[003157] = 07040; code[003157] = &I03157;
  core[003160] = 07430; code[003160] = &I03160;
  core[003161] = 07440; code[003161] = &I03161;
  core[003162] = 07402; code[003162] = &I03162;
  core[003163] = 07300; code[003163] = &I03163;
  core[003164] = 01071; code[003164] = &I03164;
  core[003165] = 07321; code[003165] = &I03165;
  core[003166] = 01052; code[003166] = &I03166;
  core[003167] = 07040; code[003167] = &I03167;
  core[003170] = 07430; code[003170] = &I03170;
  core[003171] = 07440; code[003171] = &I03171;
  core[003172] = 07402; code[003172] = &I03172;
  core[003173] = 07320; code[003173] = &I03173;
  core[003174] = 01071; code[003174] = &I03174;
  core[003175] = 07321; code[003175] = &I03175;
  core[003176] = 01052; code[003176] = &I03176;
  core[003177] = 07040; code[003177] = &I03177;
  core[003200] = 07430; code[003200] = &I03200;
  core[003201] = 07440; code[003201] = &I03201;
  core[003202] = 07402; code[003202] = &I03202;
  core[003203] = 07300; code[003203] = &I03203;
  core[003204] = 01021; code[003204] = &I03204;
  core[003205] = 07061; code[003205] = &I03205;
  core[003206] = 07040; code[003206] = &I03206;
  core[003207] = 07430; code[003207] = &I03207;
  core[003210] = 07440; code[003210] = &I03210;
  core[003211] = 07402; code[003211] = &I03211;
  core[003212] = 07320; code[003212] = &I03212;
  core[003213] = 01021; code[003213] = &I03213;
  core[003214] = 07061; code[003214] = &I03214;
  core[003215] = 07040; code[003215] = &I03215;
  core[003216] = 07420; code[003216] = &I03216;
  core[003217] = 07440; code[003217] = &I03217;
  core[003220] = 07402; code[003220] = &I03220;
  core[003221] = 07300; code[003221] = &I03221;
  core[003222] = 01071; code[003222] = &I03222;
  core[003223] = 07261; code[003223] = &I03223;
  core[003224] = 07420; code[003224] = &I03224;
  core[003225] = 07430; code[003225] = &I03225;
  core[003226] = 07402; code[003226] = &I03226;
  core[003227] = 07320; code[003227] = &I03227;
  core[003230] = 01071; code[003230] = &I03230;
  core[003231] = 07261; code[003231] = &I03231;
  core[003232] = 07430; code[003232] = &I03232;
  core[003233] = 07440; code[003233] = &I03233;
  core[003234] = 07402; code[003234] = &I03234;
  core[003235] = 07300; code[003235] = &I03235;
  core[003236] = 01021; code[003236] = &I03236;
  core[003237] = 07161; code[003237] = &I03237;
  core[003240] = 07040; code[003240] = &I03240;
  core[003241] = 07430; code[003241] = &I03241;
  core[003242] = 07440; code[003242] = &I03242;
  core[003243] = 07402; code[003243] = &I03243;
  core[003244] = 07320; code[003244] = &I03244;
  core[003245] = 01021; code[003245] = &I03245;
  core[003246] = 07161; code[003246] = &I03246;
  core[003247] = 07040; code[003247] = &I03247;
  core[003250] = 07430; code[003250] = &I03250;
  core[003251] = 07440; code[003251] = &I03251;
  core[003252] = 07402; code[003252] = &I03252;
  core[003253] = 07300; code[003253] = &I03253;
  core[003254] = 01071; code[003254] = &I03254;
  core[003255] = 07361; code[003255] = &I03255;
  core[003256] = 07420; code[003256] = &I03256;
  core[003257] = 07440; code[003257] = &I03257;
  core[003260] = 07402; code[003260] = &I03260;
  core[003261] = 07360; code[003261] = &I03261;
  core[003262] = 07210; code[003262] = &I03262;
  core[003263] = 01066; code[003263] = &I03263;
  core[003264] = 07040; code[003264] = &I03264;
  core[003265] = 07420; code[003265] = &I03265;
  core[003266] = 07440; code[003266] = &I03266;
  core[003267] = 07402; code[003267] = &I03267;
  core[003270] = 07360; code[003270] = &I03270;
  core[003271] = 07204; code[003271] = &I03271;
  core[003272] = 01052; code[003272] = &I03272;
  core[003273] = 07040; code[003273] = &I03273;
  core[003274] = 07420; code[003274] = &I03274;
  core[003275] = 07440; code[003275] = &I03275;
  core[003276] = 07402; code[003276] = &I03276;
  core[003277] = 07360; code[003277] = &I03277;
  core[003300] = 07212; code[003300] = &I03300;
  core[003301] = 01065; code[003301] = &I03301;
  core[003302] = 07040; code[003302] = &I03302;
  core[003303] = 07420; code[003303] = &I03303;
  core[003304] = 07440; code[003304] = &I03304;
  core[003305] = 07402; code[003305] = &I03305;
  core[003306] = 07360; code[003306] = &I03306;
  core[003307] = 07206; code[003307] = &I03307;
  core[003310] = 01053; code[003310] = &I03310;
  core[003311] = 07040; code[003311] = &I03311;
  core[003312] = 07420; code[003312] = &I03312;
  core[003313] = 07440; code[003313] = &I03313;
  core[003314] = 07402; code[003314] = &I03314;
  core[003315] = 07320; code[003315] = &I03315;
  core[003316] = 01032; code[003316] = &I03316;
  core[003317] = 07110; code[003317] = &I03317;
  core[003320] = 01056; code[003320] = &I03320;
  core[003321] = 07040; code[003321] = &I03321;
  core[003322] = 07420; code[003322] = &I03322;
  core[003323] = 07440; code[003323] = &I03323;
  core[003324] = 07402; code[003324] = &I03324;
  core[003325] = 07320; code[003325] = &I03325;
  core[003326] = 01032; code[003326] = &I03326;
  core[003327] = 07104; code[003327] = &I03327;
  core[003330] = 01061; code[003330] = &I03330;
  core[003331] = 07040; code[003331] = &I03331;
  core[003332] = 07420; code[003332] = &I03332;
  core[003333] = 07440; code[003333] = &I03333;
  core[003334] = 07402; code[003334] = &I03334;
  core[003335] = 07320; code[003335] = &I03335;
  core[003336] = 01032; code[003336] = &I03336;
  core[003337] = 07112; code[003337] = &I03337;
  core[003340] = 01055; code[003340] = &I03340;
  core[003341] = 07040; code[003341] = &I03341;
  core[003342] = 07420; code[003342] = &I03342;
  core[003343] = 07440; code[003343] = &I03343;
  core[003344] = 07402; code[003344] = &I03344;
  core[003345] = 07320; code[003345] = &I03345;
  core[003346] = 01032; code[003346] = &I03346;
  core[003347] = 07106; code[003347] = &I03347;
  core[003350] = 01062; code[003350] = &I03350;
  core[003351] = 07040; code[003351] = &I03351;
  core[003352] = 07420; code[003352] = &I03352;
  core[003353] = 07440; code[003353] = &I03353;
  core[003354] = 07402; code[003354] = &I03354;
  core[003355] = 07360; code[003355] = &I03355;
  core[003356] = 07310; code[003356] = &I03356;
  core[003357] = 07420; code[003357] = &I03357;
  core[003360] = 07440; code[003360] = &I03360;
  core[003361] = 07402; code[003361] = &I03361;
  core[003362] = 07360; code[003362] = &I03362;
  core[003363] = 07304; code[003363] = &I03363;
  core[003364] = 07420; code[003364] = &I03364;
  core[003365] = 07430; code[003365] = &I03365;
  core[003366] = 07402; code[003366] = &I03366;
  core[003367] = 07360; code[003367] = &I03367;
  core[003370] = 07312; code[003370] = &I03370;
  core[003371] = 07420; code[003371] = &I03371;
  core[003372] = 07440; code[003372] = &I03372;
  core[003373] = 07402; code[003373] = &I03373;
  core[003374] = 07360; code[003374] = &I03374;
  core[003375] = 07306; code[003375] = &I03375;
  core[003376] = 07420; code[003376] = &I03376;
  core[003377] = 07440; code[003377] = &I03377;
  core[003400] = 07402; code[003400] = &I03400;
  core[003401] = 07300; code[003401] = &I03401;
  core[003402] = 07030; code[003402] = &I03402;
  core[003403] = 01066; code[003403] = &I03403;
  core[003404] = 07040; code[003404] = &I03404;
  core[003405] = 07420; code[003405] = &I03405;
  core[003406] = 07440; code[003406] = &I03406;
  core[003407] = 07402; code[003407] = &I03407;
  core[003410] = 07300; code[003410] = &I03410;
  core[003411] = 07024; code[003411] = &I03411;
  core[003412] = 01052; code[003412] = &I03412;
  core[003413] = 07040; code[003413] = &I03413;
  core[003414] = 07420; code[003414] = &I03414;
  core[003415] = 07440; code[003415] = &I03415;
  core[003416] = 07402; code[003416] = &I03416;
  core[003417] = 07300; code[003417] = &I03417;
  core[003420] = 07032; code[003420] = &I03420;
  core[003421] = 01065; code[003421] = &I03421;
  core[003422] = 07040; code[003422] = &I03422;
  core[003423] = 07420; code[003423] = &I03423;
  core[003424] = 07440; code[003424] = &I03424;
  core[003425] = 07402; code[003425] = &I03425;
  core[003426] = 07300; code[003426] = &I03426;
  core[003427] = 07026; code[003427] = &I03427;
  core[003430] = 01053; code[003430] = &I03430;
  core[003431] = 07040; code[003431] = &I03431;
  core[003432] = 07420; code[003432] = &I03432;
  core[003433] = 07440; code[003433] = &I03433;
  core[003434] = 07402; code[003434] = &I03434;
  core[003435] = 07300; code[003435] = &I03435;
  core[003436] = 01070; code[003436] = &I03436;
  core[003437] = 07230; code[003437] = &I03437;
  core[003440] = 01066; code[003440] = &I03440;
  core[003441] = 07040; code[003441] = &I03441;
  core[003442] = 07420; code[003442] = &I03442;
  core[003443] = 07440; code[003443] = &I03443;
  core[003444] = 07402; code[003444] = &I03444;
  core[003445] = 07300; code[003445] = &I03445;
  core[003446] = 01070; code[003446] = &I03446;
  core[003447] = 07224; code[003447] = &I03447;
  core[003450] = 01052; code[003450] = &I03450;
  core[003451] = 07040; code[003451] = &I03451;
  core[003452] = 07420; code[003452] = &I03452;
  core[003453] = 07440; code[003453] = &I03453;
  core[003454] = 07402; code[003454] = &I03454;
  core[003455] = 07300; code[003455] = &I03455;
  core[003456] = 01070; code[003456] = &I03456;
  core[003457] = 07232; code[003457] = &I03457;
  core[003460] = 01065; code[003460] = &I03460;
  core[003461] = 07040; code[003461] = &I03461;
  core[003462] = 07420; code[003462] = &I03462;
  core[003463] = 07440; code[003463] = &I03463;
  core[003464] = 07402; code[003464] = &I03464;
  core[003465] = 07300; code[003465] = &I03465;
  core[003466] = 01070; code[003466] = &I03466;
  core[003467] = 07226; code[003467] = &I03467;
  core[003470] = 01053; code[003470] = &I03470;
  core[003471] = 07040; code[003471] = &I03471;
  core[003472] = 07420; code[003472] = &I03472;
  core[003473] = 07440; code[003473] = &I03473;
  core[003474] = 07402; code[003474] = &I03474;
  core[003475] = 07300; code[003475] = &I03475;
  core[003476] = 07130; code[003476] = &I03476;
  core[003477] = 07004; code[003477] = &I03477;
  core[003500] = 07430; code[003500] = &I03500;
  core[003501] = 07440; code[003501] = &I03501;
  core[003502] = 07402; code[003502] = &I03502;
  core[003503] = 07320; code[003503] = &I03503;
  core[003504] = 07130; code[003504] = &I03504;
  core[003505] = 07004; code[003505] = &I03505;
  core[003506] = 07430; code[003506] = &I03506;
  core[003507] = 07440; code[003507] = &I03507;
  core[003510] = 07402; code[003510] = &I03510;
  core[003511] = 07300; code[003511] = &I03511;
  core[003512] = 07124; code[003512] = &I03512;
  core[003513] = 07010; code[003513] = &I03513;
  core[003514] = 07430; code[003514] = &I03514;
  core[003515] = 07440; code[003515] = &I03515;
  core[003516] = 07402; code[003516] = &I03516;
  core[003517] = 07320; code[003517] = &I03517;
  core[003520] = 07124; code[003520] = &I03520;
  core[003521] = 07010; code[003521] = &I03521;
  core[003522] = 07430; code[003522] = &I03522;
  core[003523] = 07440; code[003523] = &I03523;
  core[003524] = 07402; code[003524] = &I03524;
  core[003525] = 07300; code[003525] = &I03525;
  core[003526] = 07132; code[003526] = &I03526;
  core[003527] = 07006; code[003527] = &I03527;
  core[003530] = 07430; code[003530] = &I03530;
  core[003531] = 07440; code[003531] = &I03531;
  core[003532] = 07402; code[003532] = &I03532;
  core[003533] = 07320; code[003533] = &I03533;
  core[003534] = 07132; code[003534] = &I03534;
  core[003535] = 07006; code[003535] = &I03535;
  core[003536] = 07430; code[003536] = &I03536;
  core[003537] = 07440; code[003537] = &I03537;
  core[003540] = 07402; code[003540] = &I03540;
  core[003541] = 07300; code[003541] = &I03541;
  core[003542] = 07126; code[003542] = &I03542;
  core[003543] = 07012; code[003543] = &I03543;
  core[003544] = 07430; code[003544] = &I03544;
  core[003545] = 07440; code[003545] = &I03545;
  core[003546] = 07402; code[003546] = &I03546;
  core[003547] = 07320; code[003547] = &I03547;
  core[003550] = 07126; code[003550] = &I03550;
  core[003551] = 07012; code[003551] = &I03551;
  core[003552] = 07430; code[003552] = &I03552;
  core[003553] = 07440; code[003553] = &I03553;
  core[003554] = 07402; code[003554] = &I03554;
  core[003555] = 07300; code[003555] = &I03555;
  core[003556] = 01070; code[003556] = &I03556;
  core[003557] = 07330; code[003557] = &I03557;
  core[003560] = 07004; code[003560] = &I03560;
  core[003561] = 07430; code[003561] = &I03561;
  core[003562] = 07440; code[003562] = &I03562;
  core[003563] = 07402; code[003563] = &I03563;
  core[003564] = 07320; code[003564] = &I03564;
  core[003565] = 01071; code[003565] = &I03565;
  core[003566] = 07330; code[003566] = &I03566;
  core[003567] = 07004; code[003567] = &I03567;
  core[003570] = 07430; code[003570] = &I03570;
  core[003571] = 07440; code[003571] = &I03571;
  core[003572] = 07402; code[003572] = &I03572;
  core[003573] = 07300; code[003573] = &I03573;
  core[003574] = 01071; code[003574] = &I03574;
  core[003575] = 07324; code[003575] = &I03575;
  core[003576] = 07010; code[003576] = &I03576;
  core[003577] = 07430; code[003577] = &I03577;
  core[003600] = 07440; code[003600] = &I03600;
  core[003601] = 07402; code[003601] = &I03601;
  core[003602] = 07320; code[003602] = &I03602;
  core[003603] = 01070; code[003603] = &I03603;
  core[003604] = 07324; code[003604] = &I03604;
  core[003605] = 07010; code[003605] = &I03605;
  core[003606] = 07430; code[003606] = &I03606;
  core[003607] = 07440; code[003607] = &I03607;
  core[003610] = 07402; code[003610] = &I03610;
  core[003611] = 07300; code[003611] = &I03611;
  core[003612] = 01071; code[003612] = &I03612;
  core[003613] = 07332; code[003613] = &I03613;
  core[003614] = 07006; code[003614] = &I03614;
  core[003615] = 07430; code[003615] = &I03615;
  core[003616] = 07440; code[003616] = &I03616;
  core[003617] = 07402; code[003617] = &I03617;
  core[003620] = 07320; code[003620] = &I03620;
  core[003621] = 01070; code[003621] = &I03621;
  core[003622] = 07332; code[003622] = &I03622;
  core[003623] = 07006; code[003623] = &I03623;
  core[003624] = 07430; code[003624] = &I03624;
  core[003625] = 07440; code[003625] = &I03625;
  core[003626] = 07402; code[003626] = &I03626;
  core[003627] = 07300; code[003627] = &I03627;
  core[003630] = 01071; code[003630] = &I03630;
  core[003631] = 07326; code[003631] = &I03631;
  core[003632] = 07012; code[003632] = &I03632;
  core[003633] = 07430; code[003633] = &I03633;
  core[003634] = 07440; code[003634] = &I03634;
  core[003635] = 07402; code[003635] = &I03635;
  core[003636] = 07320; code[003636] = &I03636;
  core[003637] = 01070; code[003637] = &I03637;
  core[003640] = 07326; code[003640] = &I03640;
  core[003641] = 07012; code[003641] = &I03641;
  core[003642] = 07430; code[003642] = &I03642;
  core[003643] = 07440; code[003643] = &I03643;
  core[003644] = 07402; code[003644] = &I03644;
  core[003645] = 07300; code[003645] = &I03645;
  core[003646] = 01067; code[003646] = &I03646;
  core[003647] = 07041; code[003647] = &I03647;
  core[003650] = 01052; code[003650] = &I03650;
  core[003651] = 07040; code[003651] = &I03651;
  core[003652] = 07420; code[003652] = &I03652;
  core[003653] = 07440; code[003653] = &I03653;
  core[003654] = 07402; code[003654] = &I03654;
  core[003655] = 07300; code[003655] = &I03655;
  core[003656] = 01052; code[003656] = &I03656;
  core[003657] = 07041; code[003657] = &I03657;
  core[003660] = 01053; code[003660] = &I03660;
  core[003661] = 07040; code[003661] = &I03661;
  core[003662] = 07420; code[003662] = &I03662;
  core[003663] = 07440; code[003663] = &I03663;
  core[003664] = 07402; code[003664] = &I03664;
  core[003665] = 07300; code[003665] = &I03665;
  core[003666] = 01101; code[003666] = &I03666;
  core[003667] = 07041; code[003667] = &I03667;
  core[003670] = 01054; code[003670] = &I03670;
  core[003671] = 07040; code[003671] = &I03671;
  core[003672] = 07420; code[003672] = &I03672;
  core[003673] = 07440; code[003673] = &I03673;
  core[003674] = 07402; code[003674] = &I03674;
  core[003675] = 07300; code[003675] = &I03675;
  core[003676] = 01100; code[003676] = &I03676;
  core[003677] = 07041; code[003677] = &I03677;
  core[003700] = 01055; code[003700] = &I03700;
  core[003701] = 07040; code[003701] = &I03701;
  core[003702] = 07420; code[003702] = &I03702;
  core[003703] = 07440; code[003703] = &I03703;
  core[003704] = 07402; code[003704] = &I03704;
  core[003705] = 07300; code[003705] = &I03705;
  core[003706] = 01077; code[003706] = &I03706;
  core[003707] = 07041; code[003707] = &I03707;
  core[003710] = 01056; code[003710] = &I03710;
  core[003711] = 07040; code[003711] = &I03711;
  core[003712] = 07420; code[003712] = &I03712;
  core[003713] = 07440; code[003713] = &I03713;
  core[003714] = 07402; code[003714] = &I03714;
  core[003715] = 07300; code[003715] = &I03715;
  core[003716] = 01076; code[003716] = &I03716;
  core[003717] = 07041; code[003717] = &I03717;
  core[003720] = 01057; code[003720] = &I03720;
  core[003721] = 07040; code[003721] = &I03721;
  core[003722] = 07420; code[003722] = &I03722;
  core[003723] = 07440; code[003723] = &I03723;
  core[003724] = 07402; code[003724] = &I03724;
  core[003725] = 07300; code[003725] = &I03725;
  core[003726] = 01113; code[003726] = &I03726;
  core[003727] = 07041; code[003727] = &I03727;
  core[003730] = 01061; code[003730] = &I03730;
  core[003731] = 07040; code[003731] = &I03731;
  core[003732] = 07420; code[003732] = &I03732;
  core[003733] = 07440; code[003733] = &I03733;
  core[003734] = 07402; code[003734] = &I03734;
  core[003735] = 07300; code[003735] = &I03735;
  core[003736] = 01075; code[003736] = &I03736;
  core[003737] = 07041; code[003737] = &I03737;
  core[003740] = 01062; code[003740] = &I03740;
  core[003741] = 07040; code[003741] = &I03741;
  core[003742] = 07420; code[003742] = &I03742;
  core[003743] = 07440; code[003743] = &I03743;
  core[003744] = 07402; code[003744] = &I03744;
  core[003745] = 07300; code[003745] = &I03745;
  core[003746] = 01074; code[003746] = &I03746;
  core[003747] = 07041; code[003747] = &I03747;
  core[003750] = 01063; code[003750] = &I03750;
  core[003751] = 07040; code[003751] = &I03751;
  core[003752] = 07420; code[003752] = &I03752;
  core[003753] = 07440; code[003753] = &I03753;
  core[003754] = 07402; code[003754] = &I03754;
  core[003755] = 07300; code[003755] = &I03755;
  core[003756] = 01073; code[003756] = &I03756;
  core[003757] = 07041; code[003757] = &I03757;
  core[003760] = 01064; code[003760] = &I03760;
  core[003761] = 07040; code[003761] = &I03761;
  core[003762] = 07420; code[003762] = &I03762;
  core[003763] = 07440; code[003763] = &I03763;
  core[003764] = 07402; code[003764] = &I03764;
  core[003765] = 07300; code[003765] = &I03765;
  core[003766] = 01072; code[003766] = &I03766;
  core[003767] = 07041; code[003767] = &I03767;
  core[003770] = 01065; code[003770] = &I03770;
  core[003771] = 07040; code[003771] = &I03771;
  core[003772] = 07420; code[003772] = &I03772;
  core[003773] = 07440; code[003773] = &I03773;
  core[003774] = 07402; code[003774] = &I03774;
  core[003775] = 07300; code[003775] = &I03775;
  core[003776] = 01050; code[003776] = &I03776;
  core[003777] = 07041; code[003777] = &I03777;
  core[004000] = 01066; code[004000] = &I04000;
  core[004001] = 07040; code[004001] = &I04001;
  core[004002] = 07420; code[004002] = &I04002;
  core[004003] = 07440; code[004003] = &I04003;
  core[004004] = 07402; code[004004] = &I04004;
  core[004005] = 07300; code[004005] = &I04005;
  core[004006] = 01020; code[004006] = &I04006;
  core[004007] = 07041; code[004007] = &I04007;
  core[004010] = 07450; code[004010] = &I04010;
  core[004011] = 07420; code[004011] = &I04011;
  core[004012] = 07402; code[004012] = &I04012;
  core[004013] = 07340; code[004013] = &I04013;
  core[004014] = 07311; code[004014] = &I04014;
  core[004015] = 07430; code[004015] = &I04015;
  core[004016] = 07440; code[004016] = &I04016;
  core[004017] = 07402; code[004017] = &I04017;
  core[004020] = 07360; code[004020] = &I04020;
  core[004021] = 07305; code[004021] = &I04021;
  core[004022] = 07430; code[004022] = &I04022;
  core[004023] = 07402; code[004023] = &I04023;
  core[004024] = 07041; code[004024] = &I04024;
  core[004025] = 01022; code[004025] = &I04025;
  core[004026] = 07440; code[004026] = &I04026;
  core[004027] = 07402; code[004027] = &I04027;
  core[004030] = 07320; code[004030] = &I04030;
  core[004031] = 07313; code[004031] = &I04031;
  core[004032] = 07430; code[004032] = &I04032;
  core[004033] = 07402; code[004033] = &I04033;
  core[004034] = 07500; code[004034] = &I04034;
  core[004035] = 07402; code[004035] = &I04035;
  core[004036] = 07360; code[004036] = &I04036;
  core[004037] = 07307; code[004037] = &I04037;
  core[004040] = 07430; code[004040] = &I04040;
  core[004041] = 07402; code[004041] = &I04041;
  core[004042] = 07041; code[004042] = &I04042;
  core[004043] = 01024; code[004043] = &I04043;
  core[004044] = 07440; code[004044] = &I04044;
  core[004045] = 07402; code[004045] = &I04045;
  core[004046] = 07300; code[004046] = &I04046;
  core[004047] = 07331; code[004047] = &I04047;
  core[004050] = 07520; code[004050] = &I04050;
  core[004051] = 07402; code[004051] = &I04051;
  core[004052] = 07300; code[004052] = &I04052;
  core[004053] = 07345; code[004053] = &I04053;
  core[004054] = 07430; code[004054] = &I04054;
  core[004055] = 07402; code[004055] = &I04055;
  core[004056] = 07041; code[004056] = &I04056;
  core[004057] = 01021; code[004057] = &I04057;
  core[004060] = 07440; code[004060] = &I04060;
  core[004061] = 07402; code[004061] = &I04061;
  core[004062] = 07360; code[004062] = &I04062;
  core[004063] = 07373; code[004063] = &I04063;
  core[004064] = 07440; code[004064] = &I04064;
  core[004065] = 07402; code[004065] = &I04065;
  core[004066] = 07430; code[004066] = &I04066;
  core[004067] = 07402; code[004067] = &I04067;
  core[004070] = 07332; code[004070] = &I04070;
  core[004071] = 07006; code[004071] = &I04071;
  core[004072] = 07430; code[004072] = &I04072;
  core[004073] = 07440; code[004073] = &I04073;
  core[004074] = 07402; code[004074] = &I04074;
  core[004075] = 07360; code[004075] = &I04075;
  core[004076] = 07342; code[004076] = &I04076;
  core[004077] = 07040; code[004077] = &I04077;
  core[004100] = 07420; code[004100] = &I04100;
  core[004101] = 07440; code[004101] = &I04101;
  core[004102] = 07402; code[004102] = &I04102;
  core[004103] = 07360; code[004103] = &I04103;
  core[004104] = 07303; code[004104] = &I04104;
  core[004105] = 01061; code[004105] = &I04105;
  core[004106] = 07040; code[004106] = &I04106;
  core[004107] = 07420; code[004107] = &I04107;
  core[004110] = 07440; code[004110] = &I04110;
  core[004111] = 07402; code[004111] = &I04111;
  core[004112] = 07360; code[004112] = &I04112;
  core[004113] = 07343; code[004113] = &I04113;
  core[004114] = 07430; code[004114] = &I04114;
  core[004115] = 07440; code[004115] = &I04115;
  core[004116] = 07402; code[004116] = &I04116;
  core[004117] = 07360; code[004117] = &I04117;
  core[004120] = 07363; code[004120] = &I04120;
  core[004121] = 07420; code[004121] = &I04121;
  core[004122] = 07440; code[004122] = &I04122;
  core[004123] = 07402; code[004123] = &I04123;
  core[004124] = 07300; code[004124] = &I04124;
  core[004125] = 01043; code[004125] = &I04125;
  core[004126] = 07063; code[004126] = &I04126;
  core[004127] = 01047; code[004127] = &I04127;
  core[004130] = 07040; code[004130] = &I04130;
  core[004131] = 07430; code[004131] = &I04131;
  core[004132] = 07440; code[004132] = &I04132;
  core[004133] = 07402; code[004133] = &I04133;
  core[004134] = 07332; code[004134] = &I04134;
  core[004135] = 07063; code[004135] = &I04135;
  core[004136] = 01051; code[004136] = &I04136;
  core[004137] = 07040; code[004137] = &I04137;
  core[004140] = 07430; code[004140] = &I04140;
  core[004141] = 07440; code[004141] = &I04141;
  core[004142] = 07402; code[004142] = &I04142;
  core[004143] = 07240; code[004143] = &I04143;
  core[004144] = 07700; code[004144] = &I04144;
  core[004145] = 07402; code[004145] = &I04145;
  core[004146] = 07440; code[004146] = &I04146;
  core[004147] = 07402; code[004147] = &I04147;
  core[004150] = 07240; code[004150] = &I04150;
  core[004151] = 07640; code[004151] = &I04151;
  core[004152] = 07440; code[004152] = &I04152;
  core[004153] = 07402; code[004153] = &I04153;
  core[004154] = 07240; code[004154] = &I04154;
  core[004155] = 07540; code[004155] = &I04155;
  core[004156] = 07402; code[004156] = &I04156;
  core[004157] = 07200; code[004157] = &I04157;
  core[004160] = 07540; code[004160] = &I04160;
  core[004161] = 07402; code[004161] = &I04161;
  core[004162] = 07200; code[004162] = &I04162;
  core[004163] = 01066; code[004163] = &I04163;
  core[004164] = 07540; code[004164] = &I04164;
  core[004165] = 07450; code[004165] = &I04165;
  core[004166] = 07402; code[004166] = &I04166;
  core[004167] = 07240; code[004167] = &I04167;
  core[004170] = 07740; code[004170] = &I04170;
  core[004171] = 07402; code[004171] = &I04171;
  core[004172] = 07440; code[004172] = &I04172;
  core[004173] = 07402; code[004173] = &I04173;
  core[004174] = 07200; code[004174] = &I04174;
  core[004175] = 07740; code[004175] = &I04175;
  core[004176] = 07402; code[004176] = &I04176;
  core[004177] = 07440; code[004177] = &I04177;
  core[004200] = 07402; code[004200] = &I04200;
  core[004201] = 07200; code[004201] = &I04201;
  core[004202] = 01066; code[004202] = &I04202;
  core[004203] = 07740; code[004203] = &I04203;
  core[004204] = 07440; code[004204] = &I04204;
  core[004205] = 07402; code[004205] = &I04205;
  core[004206] = 07300; code[004206] = &I04206;
  core[004207] = 01070; code[004207] = &I04207;
  core[004210] = 07620; code[004210] = &I04210;
  core[004211] = 07440; code[004211] = &I04211;
  core[004212] = 07402; code[004212] = &I04212;
  core[004213] = 07320; code[004213] = &I04213;
  core[004214] = 01071; code[004214] = &I04214;
  core[004215] = 07620; code[004215] = &I04215;
  core[004216] = 07402; code[004216] = &I04216;
  core[004217] = 07440; code[004217] = &I04217;
  core[004220] = 07402; code[004220] = &I04220;
  core[004221] = 07300; code[004221] = &I04221;
  core[004222] = 07520; code[004222] = &I04222;
  core[004223] = 07440; code[004223] = &I04223;
  core[004224] = 07402; code[004224] = &I04224;
  core[004225] = 07320; code[004225] = &I04225;
  core[004226] = 07520; code[004226] = &I04226;
  core[004227] = 07402; code[004227] = &I04227;
  core[004230] = 07300; code[004230] = &I04230;
  core[004231] = 01050; code[004231] = &I04231;
  core[004232] = 07520; code[004232] = &I04232;
  core[004233] = 07402; code[004233] = &I04233;
  core[004234] = 07320; code[004234] = &I04234;
  core[004235] = 01050; code[004235] = &I04235;
  core[004236] = 07520; code[004236] = &I04236;
  core[004237] = 07402; code[004237] = &I04237;
  core[004240] = 07300; code[004240] = &I04240;
  core[004241] = 07720; code[004241] = &I04241;
  core[004242] = 07440; code[004242] = &I04242;
  core[004243] = 07402; code[004243] = &I04243;
  core[004244] = 07320; code[004244] = &I04244;
  core[004245] = 07720; code[004245] = &I04245;
  core[004246] = 07402; code[004246] = &I04246;
  core[004247] = 07440; code[004247] = &I04247;
  core[004250] = 07402; code[004250] = &I04250;
  core[004251] = 07300; code[004251] = &I04251;
  core[004252] = 01050; code[004252] = &I04252;
  core[004253] = 07720; code[004253] = &I04253;
  core[004254] = 07402; code[004254] = &I04254;
  core[004255] = 07440; code[004255] = &I04255;
  core[004256] = 07402; code[004256] = &I04256;
  core[004257] = 07320; code[004257] = &I04257;
  core[004260] = 01050; code[004260] = &I04260;
  core[004261] = 07720; code[004261] = &I04261;
  core[004262] = 07402; code[004262] = &I04262;
  core[004263] = 07440; code[004263] = &I04263;
  core[004264] = 07402; code[004264] = &I04264;
  core[004265] = 07300; code[004265] = &I04265;
  core[004266] = 07460; code[004266] = &I04266;
  core[004267] = 07402; code[004267] = &I04267;
  core[004270] = 07320; code[004270] = &I04270;
  core[004271] = 07460; code[004271] = &I04271;
  core[004272] = 07402; code[004272] = &I04272;
  core[004273] = 07300; code[004273] = &I04273;
  core[004274] = 01040; code[004274] = &I04274;
  core[004275] = 07460; code[004275] = &I04275;
  core[004276] = 07450; code[004276] = &I04276;
  core[004277] = 07402; code[004277] = &I04277;
  core[004300] = 07320; code[004300] = &I04300;
  core[004301] = 01032; code[004301] = &I04301;
  core[004302] = 07460; code[004302] = &I04302;
  core[004303] = 07402; code[004303] = &I04303;
  core[004304] = 07300; code[004304] = &I04304;
  core[004305] = 07660; code[004305] = &I04305;
  core[004306] = 07402; code[004306] = &I04306;
  core[004307] = 07440; code[004307] = &I04307;
  core[004310] = 07402; code[004310] = &I04310;
  core[004311] = 07320; code[004311] = &I04311;
  core[004312] = 07660; code[004312] = &I04312;
  core[004313] = 07402; code[004313] = &I04313;
  core[004314] = 07440; code[004314] = &I04314;
  core[004315] = 07402; code[004315] = &I04315;
  core[004316] = 07320; code[004316] = &I04316;
  core[004317] = 01036; code[004317] = &I04317;
  core[004320] = 07660; code[004320] = &I04320;
  core[004321] = 07402; code[004321] = &I04321;
  core[004322] = 07440; code[004322] = &I04322;
  core[004323] = 07402; code[004323] = &I04323;
  core[004324] = 07300; code[004324] = &I04324;
  core[004325] = 01045; code[004325] = &I04325;
  core[004326] = 07660; code[004326] = &I04326;
  core[004327] = 07440; code[004327] = &I04327;
  core[004330] = 07402; code[004330] = &I04330;
  core[004331] = 07300; code[004331] = &I04331;
  core[004332] = 07560; code[004332] = &I04332;
  core[004333] = 07402; code[004333] = &I04333;
  core[004334] = 07320; code[004334] = &I04334;
  core[004335] = 01066; code[004335] = &I04335;
  core[004336] = 07560; code[004336] = &I04336;
  core[004337] = 07402; code[004337] = &I04337;
  core[004340] = 07300; code[004340] = &I04340;
  core[004341] = 01050; code[004341] = &I04341;
  core[004342] = 07560; code[004342] = &I04342;
  core[004343] = 07402; code[004343] = &I04343;
  core[004344] = 07300; code[004344] = &I04344;
  core[004345] = 01066; code[004345] = &I04345;
  core[004346] = 07560; code[004346] = &I04346;
  core[004347] = 07450; code[004347] = &I04347;
  core[004350] = 07402; code[004350] = &I04350;
  core[004351] = 07300; code[004351] = &I04351;
  core[004352] = 07760; code[004352] = &I04352;
  core[004353] = 07402; code[004353] = &I04353;
  core[004354] = 07440; code[004354] = &I04354;
  core[004355] = 07402; code[004355] = &I04355;
  core[004356] = 07320; code[004356] = &I04356;
  core[004357] = 01066; code[004357] = &I04357;
  core[004360] = 07760; code[004360] = &I04360;
  core[004361] = 07402; code[004361] = &I04361;
  core[004362] = 07440; code[004362] = &I04362;
  core[004363] = 07402; code[004363] = &I04363;
  core[004364] = 07300; code[004364] = &I04364;
  core[004365] = 01050; code[004365] = &I04365;
  core[004366] = 07760; code[004366] = &I04366;
  core[004367] = 07402; code[004367] = &I04367;
  core[004370] = 07440; code[004370] = &I04370;
  core[004371] = 07402; code[004371] = &I04371;
  core[004372] = 07300; code[004372] = &I04372;
  core[004373] = 01066; code[004373] = &I04373;
  core[004374] = 07760; code[004374] = &I04374;
  core[004375] = 07440; code[004375] = &I04375;
  core[004376] = 07402; code[004376] = &I04376;
  core[004377] = 07300; code[004377] = &I04377;
  core[004400] = 07410; code[004400] = &I04400;
  core[004401] = 07402; code[004401] = &I04401;
  core[004402] = 07320; code[004402] = &I04402;
  core[004403] = 07410; code[004403] = &I04403;
  core[004404] = 07402; code[004404] = &I04404;
  core[004405] = 07320; code[004405] = &I04405;
  core[004406] = 01066; code[004406] = &I04406;
  core[004407] = 07410; code[004407] = &I04407;
  core[004410] = 07402; code[004410] = &I04410;
  core[004411] = 07300; code[004411] = &I04411;
  core[004412] = 01066; code[004412] = &I04412;
  core[004413] = 07410; code[004413] = &I04413;
  core[004414] = 07402; code[004414] = &I04414;
  core[004415] = 07200; code[004415] = &I04415;
  core[004416] = 01066; code[004416] = &I04416;
  core[004417] = 07710; code[004417] = &I04417;
  core[004420] = 07402; code[004420] = &I04420;
  core[004421] = 07440; code[004421] = &I04421;
  core[004422] = 07402; code[004422] = &I04422;
  core[004423] = 07200; code[004423] = &I04423;
  core[004424] = 01050; code[004424] = &I04424;
  core[004425] = 07710; code[004425] = &I04425;
  core[004426] = 07440; code[004426] = &I04426;
  core[004427] = 07402; code[004427] = &I04427;
  core[004430] = 07240; code[004430] = &I04430;
  core[004431] = 07650; code[004431] = &I04431;
  core[004432] = 07402; code[004432] = &I04432;
  core[004433] = 07200; code[004433] = &I04433;
  core[004434] = 07650; code[004434] = &I04434;
  core[004435] = 07440; code[004435] = &I04435;
  core[004436] = 07402; code[004436] = &I04436;
  core[004437] = 07200; code[004437] = &I04437;
  core[004440] = 07550; code[004440] = &I04440;
  core[004441] = 07440; code[004441] = &I04441;
  core[004442] = 07402; code[004442] = &I04442;
  core[004443] = 07200; code[004443] = &I04443;
  core[004444] = 01066; code[004444] = &I04444;
  core[004445] = 07550; code[004445] = &I04445;
  core[004446] = 07402; code[004446] = &I04446;
  core[004447] = 07200; code[004447] = &I04447;
  core[004450] = 01050; code[004450] = &I04450;
  core[004451] = 07550; code[004451] = &I04451;
  core[004452] = 07450; code[004452] = &I04452;
  core[004453] = 07402; code[004453] = &I04453;
  core[004454] = 07200; code[004454] = &I04454;
  core[004455] = 07750; code[004455] = &I04455;
  core[004456] = 07440; code[004456] = &I04456;
  core[004457] = 07402; code[004457] = &I04457;
  core[004460] = 07200; code[004460] = &I04460;
  core[004461] = 01066; code[004461] = &I04461;
  core[004462] = 07750; code[004462] = &I04462;
  core[004463] = 07402; code[004463] = &I04463;
  core[004464] = 07440; code[004464] = &I04464;
  core[004465] = 07402; code[004465] = &I04465;
  core[004466] = 07200; code[004466] = &I04466;
  core[004467] = 01050; code[004467] = &I04467;
  core[004470] = 07750; code[004470] = &I04470;
  core[004471] = 07440; code[004471] = &I04471;
  core[004472] = 07402; code[004472] = &I04472;
  core[004473] = 07300; code[004473] = &I04473;
  core[004474] = 01070; code[004474] = &I04474;
  core[004475] = 07630; code[004475] = &I04475;
  core[004476] = 07402; code[004476] = &I04476;
  core[004477] = 07440; code[004477] = &I04477;
  core[004500] = 07402; code[004500] = &I04500;
  core[004501] = 07360; code[004501] = &I04501;
  core[004502] = 07630; code[004502] = &I04502;
  core[004503] = 07440; code[004503] = &I04503;
  core[004504] = 07402; code[004504] = &I04504;
  core[004505] = 07300; code[004505] = &I04505;
  core[004506] = 01066; code[004506] = &I04506;
  core[004507] = 07530; code[004507] = &I04507;
  core[004510] = 07402; code[004510] = &I04510;
  core[004511] = 07320; code[004511] = &I04511;
  core[004512] = 01066; code[004512] = &I04512;
  core[004513] = 07530; code[004513] = &I04513;
  core[004514] = 07450; code[004514] = &I04514;
  core[004515] = 07402; code[004515] = &I04515;
  core[004516] = 07300; code[004516] = &I04516;
  core[004517] = 01050; code[004517] = &I04517;
  core[004520] = 07530; code[004520] = &I04520;
  core[004521] = 07500; code[004521] = &I04521;
  core[004522] = 07402; code[004522] = &I04522;
  core[004523] = 07300; code[004523] = &I04523;
  core[004524] = 01066; code[004524] = &I04524;
  core[004525] = 07730; code[004525] = &I04525;
  core[004526] = 07402; code[004526] = &I04526;
  core[004527] = 07440; code[004527] = &I04527;
  core[004530] = 07402; code[004530] = &I04530;
  core[004531] = 07320; code[004531] = &I04531;
  core[004532] = 01066; code[004532] = &I04532;
  core[004533] = 07730; code[004533] = &I04533;
  core[004534] = 07440; code[004534] = &I04534;
  core[004535] = 07402; code[004535] = &I04535;
  core[004536] = 07300; code[004536] = &I04536;
  core[004537] = 01050; code[004537] = &I04537;
  core[004540] = 07730; code[004540] = &I04540;
  core[004541] = 07440; code[004541] = &I04541;
  core[004542] = 07402; code[004542] = &I04542;
  core[004543] = 07300; code[004543] = &I04543;
  core[004544] = 01050; code[004544] = &I04544;
  core[004545] = 07470; code[004545] = &I04545;
  core[004546] = 07402; code[004546] = &I04546;
  core[004547] = 07320; code[004547] = &I04547;
  core[004550] = 01050; code[004550] = &I04550;
  core[004551] = 07470; code[004551] = &I04551;
  core[004552] = 07420; code[004552] = &I04552;
  core[004553] = 07402; code[004553] = &I04553;
  core[004554] = 07300; code[004554] = &I04554;
  core[004555] = 07470; code[004555] = &I04555;
  core[004556] = 07430; code[004556] = &I04556;
  core[004557] = 07402; code[004557] = &I04557;
  core[004560] = 07320; code[004560] = &I04560;
  core[004561] = 01050; code[004561] = &I04561;
  core[004562] = 07670; code[004562] = &I04562;
  core[004563] = 07440; code[004563] = &I04563;
  core[004564] = 07402; code[004564] = &I04564;
  core[004565] = 07300; code[004565] = &I04565;
  core[004566] = 01050; code[004566] = &I04566;
  core[004567] = 07670; code[004567] = &I04567;
  core[004570] = 07402; code[004570] = &I04570;
  core[004571] = 07440; code[004571] = &I04571;
  core[004572] = 07402; code[004572] = &I04572;
  core[004573] = 07300; code[004573] = &I04573;
  core[004574] = 07670; code[004574] = &I04574;
  core[004575] = 07440; code[004575] = &I04575;
  core[004576] = 07402; code[004576] = &I04576;
  core[004577] = 07300; code[004577] = &I04577;
  core[004600] = 01066; code[004600] = &I04600;
  core[004601] = 07570; code[004601] = &I04601;
  core[004602] = 07402; code[004602] = &I04602;
  core[004603] = 07320; code[004603] = &I04603;
  core[004604] = 01066; code[004604] = &I04604;
  core[004605] = 07570; code[004605] = &I04605;
  core[004606] = 07420; code[004606] = &I04606;
  core[004607] = 07402; code[004607] = &I04607;
  core[004610] = 07300; code[004610] = &I04610;
  core[004611] = 07570; code[004611] = &I04611;
  core[004612] = 07430; code[004612] = &I04612;
  core[004613] = 07402; code[004613] = &I04613;
  core[004614] = 07300; code[004614] = &I04614;
  core[004615] = 01050; code[004615] = &I04615;
  core[004616] = 07570; code[004616] = &I04616;
  core[004617] = 07430; code[004617] = &I04617;
  core[004620] = 07402; code[004620] = &I04620;
  core[004621] = 07300; code[004621] = &I04621;
  core[004622] = 01066; code[004622] = &I04622;
  core[004623] = 07770; code[004623] = &I04623;
  core[004624] = 07402; code[004624] = &I04624;
  core[004625] = 07440; code[004625] = &I04625;
  core[004626] = 07402; code[004626] = &I04626;
  core[004627] = 07320; code[004627] = &I04627;
  core[004630] = 01066; code[004630] = &I04630;
  core[004631] = 07770; code[004631] = &I04631;
  core[004632] = 07440; code[004632] = &I04632;
  core[004633] = 07402; code[004633] = &I04633;
  core[004634] = 07300; code[004634] = &I04634;
  core[004635] = 01050; code[004635] = &I04635;
  core[004636] = 07770; code[004636] = &I04636;
  core[004637] = 07440; code[004637] = &I04637;
  core[004640] = 07402; code[004640] = &I04640;
  core[004641] = 07300; code[004641] = &I04641;
  core[004642] = 07770; code[004642] = &I04642;
  core[004643] = 07440; code[004643] = &I04643;
  core[004644] = 07402; code[004644] = &I04644;
  core[004645] = 07200; code[004645] = &I04645;
  core[004646] = 01070; code[004646] = &I04646;
  core[004647] = 07604; code[004647] = &I04647;
  core[004650] = 07040; code[004650] = &I04650;
  core[004651] = 07440; code[004651] = &I04651;
  core[004652] = 07402; code[004652] = &I04652;
  core[004653] = 07200; code[004653] = &I04653;
  core[004654] = 01050; code[004654] = &I04654;
  core[004655] = 07504; code[004655] = &I04655;
  core[004656] = 07402; code[004656] = &I04656;
  core[004657] = 07040; code[004657] = &I04657;
  core[004660] = 07440; code[004660] = &I04660;
  core[004661] = 07402; code[004661] = &I04661;
  core[004662] = 07200; code[004662] = &I04662;
  core[004663] = 07444; code[004663] = &I04663;
  core[004664] = 07402; code[004664] = &I04664;
  core[004665] = 07040; code[004665] = &I04665;
  core[004666] = 07440; code[004666] = &I04666;
  core[004667] = 07402; code[004667] = &I04667;
  core[004670] = 07320; code[004670] = &I04670;
  core[004671] = 07424; code[004671] = &I04671;
  core[004672] = 07402; code[004672] = &I04672;
  core[004673] = 07040; code[004673] = &I04673;
  core[004674] = 07440; code[004674] = &I04674;
  core[004675] = 07402; code[004675] = &I04675;
  core[004676] = 07300; code[004676] = &I04676;
  core[004677] = 01066; code[004677] = &I04677;
  core[004700] = 07764; code[004700] = &I04700;
  core[004701] = 07450; code[004701] = &I04701;
  core[004702] = 07402; code[004702] = &I04702;
  core[004703] = 07040; code[004703] = &I04703;
  core[004704] = 07440; code[004704] = &I04704;
  core[004705] = 07402; code[004705] = &I04705;
  core[004706] = 07200; code[004706] = &I04706;
  core[004707] = 07414; code[004707] = &I04707;
  core[004710] = 07402; code[004710] = &I04710;
  core[004711] = 07040; code[004711] = &I04711;
  core[004712] = 07440; code[004712] = &I04712;
  core[004713] = 07402; code[004713] = &I04713;
  core[004714] = 07200; code[004714] = &I04714;
  core[004715] = 07514; code[004715] = &I04715;
  core[004716] = 07402; code[004716] = &I04716;
  core[004717] = 07040; code[004717] = &I04717;
  core[004720] = 07440; code[004720] = &I04720;
  core[004721] = 07402; code[004721] = &I04721;
  core[004722] = 07200; code[004722] = &I04722;
  core[004723] = 01040; code[004723] = &I04723;
  core[004724] = 07454; code[004724] = &I04724;
  core[004725] = 07402; code[004725] = &I04725;
  core[004726] = 07040; code[004726] = &I04726;
  core[004727] = 07440; code[004727] = &I04727;
  core[004730] = 07402; code[004730] = &I04730;
  core[004731] = 07300; code[004731] = &I04731;
  core[004732] = 07434; code[004732] = &I04732;
  core[004733] = 07402; code[004733] = &I04733;
  core[004734] = 07040; code[004734] = &I04734;
  core[004735] = 07440; code[004735] = &I04735;
  core[004736] = 07402; code[004736] = &I04736;
  core[004737] = 07300; code[004737] = &I04737;
  core[004740] = 01066; code[004740] = &I04740;
  core[004741] = 07774; code[004741] = &I04741;
  core[004742] = 07402; code[004742] = &I04742;
  core[004743] = 07040; code[004743] = &I04743;
  core[004744] = 07440; code[004744] = &I04744;
  core[004745] = 07402; code[004745] = &I04745;
  core[004746] = 07360; code[004746] = &I04746;
  core[004747] = 07601; code[004747] = &I04747;
  core[004750] = 07430; code[004750] = &I04750;
  core[004751] = 07440; code[004751] = &I04751;
  core[004752] = 07402; code[004752] = &I04752;
  core[004753] = 07360; code[004753] = &I04753;
  core[004754] = 07401; code[004754] = &I04754;
  core[004755] = 07040; code[004755] = &I04755;
  core[004756] = 07430; code[004756] = &I04756;
  core[004757] = 07440; code[004757] = &I04757;
  core[004760] = 07402; code[004760] = &I04760;
  core[004761] = 07360; code[004761] = &I04761;
  core[004762] = 07421; code[004762] = &I04762;
  core[004763] = 07430; code[004763] = &I04763;
  core[004764] = 07440; code[004764] = &I04764;
  core[004765] = 07402; code[004765] = &I04765;
  core[004766] = 07300; code[004766] = &I04766;
  core[004767] = 07421; code[004767] = &I04767;
  core[004770] = 07040; code[004770] = &I04770;
  core[004771] = 07501; code[004771] = &I04771;
  core[004772] = 07040; code[004772] = &I04772;
  core[004773] = 07420; code[004773] = &I04773;
  core[004774] = 07440; code[004774] = &I04774;
  core[004775] = 07402; code[004775] = &I04775;
  core[004776] = 07340; code[004776] = &I04776;
  core[004777] = 07421; code[004777] = &I04777;
  core[005000] = 07501; code[005000] = &I05000;
  core[005001] = 07040; code[005001] = &I05001;
  core[005002] = 07420; code[005002] = &I05002;
  core[005003] = 07440; code[005003] = &I05003;
  core[005004] = 07402; code[005004] = &I05004;
  core[005005] = 07601; code[005005] = &I05005;
  core[005006] = 01070; code[005006] = &I05006;
  core[005007] = 07421; code[005007] = &I05007;
  core[005010] = 01071; code[005010] = &I05010;
  core[005011] = 07501; code[005011] = &I05011;
  core[005012] = 07040; code[005012] = &I05012;
  core[005013] = 07440; code[005013] = &I05013;
  core[005014] = 07402; code[005014] = &I05014;
  core[005015] = 07360; code[005015] = &I05015;
  core[005016] = 07421; code[005016] = &I05016;
  core[005017] = 07040; code[005017] = &I05017;
  core[005020] = 07621; code[005020] = &I05020;
  core[005021] = 07440; code[005021] = &I05021;
  core[005022] = 07402; code[005022] = &I05022;
  core[005023] = 07501; code[005023] = &I05023;
  core[005024] = 07430; code[005024] = &I05024;
  core[005025] = 07440; code[005025] = &I05025;
  core[005026] = 07402; code[005026] = &I05026;
  core[005027] = 07601; code[005027] = &I05027;
  core[005030] = 07421; code[005030] = &I05030;
  core[005031] = 07040; code[005031] = &I05031;
  core[005032] = 07701; code[005032] = &I05032;
  core[005033] = 07440; code[005033] = &I05033;
  core[005034] = 07402; code[005034] = &I05034;
  core[005035] = 07501; code[005035] = &I05035;
  core[005036] = 07440; code[005036] = &I05036;
  core[005037] = 07402; code[005037] = &I05037;
  core[005040] = 07240; code[005040] = &I05040;
  core[005041] = 07421; code[005041] = &I05041;
  core[005042] = 07701; code[005042] = &I05042;
  core[005043] = 07040; code[005043] = &I05043;
  core[005044] = 07440; code[005044] = &I05044;
  core[005045] = 07402; code[005045] = &I05045;
  core[005046] = 07501; code[005046] = &I05046;
  core[005047] = 07040; code[005047] = &I05047;
  core[005050] = 07440; code[005050] = &I05050;
  core[005051] = 07402; code[005051] = &I05051;
  core[005052] = 07601; code[005052] = &I05052;
  core[005053] = 01070; code[005053] = &I05053;
  core[005054] = 07421; code[005054] = &I05054;
  core[005055] = 01071; code[005055] = &I05055;
  core[005056] = 07701; code[005056] = &I05056;
  core[005057] = 01071; code[005057] = &I05057;
  core[005060] = 07040; code[005060] = &I05060;
  core[005061] = 07440; code[005061] = &I05061;
  core[005062] = 07402; code[005062] = &I05062;
  core[005063] = 07501; code[005063] = &I05063;
  core[005064] = 01071; code[005064] = &I05064;
  core[005065] = 07040; code[005065] = &I05065;
  core[005066] = 07440; code[005066] = &I05066;
  core[005067] = 07402; code[005067] = &I05067;
  core[005070] = 07601; code[005070] = &I05070;
  core[005071] = 01071; code[005071] = &I05071;
  core[005072] = 07421; code[005072] = &I05072;
  core[005073] = 01070; code[005073] = &I05073;
  core[005074] = 07701; code[005074] = &I05074;
  core[005075] = 01070; code[005075] = &I05075;
  core[005076] = 07040; code[005076] = &I05076;
  core[005077] = 07440; code[005077] = &I05077;
  core[005100] = 07402; code[005100] = &I05100;
  core[005101] = 07501; code[005101] = &I05101;
  core[005102] = 01070; code[005102] = &I05102;
  core[005103] = 07040; code[005103] = &I05103;
  core[005104] = 07440; code[005104] = &I05104;
  core[005105] = 07402; code[005105] = &I05105;
  core[005106] = 07621; code[005106] = &I05106;
  core[005107] = 07040; code[005107] = &I05107;
  core[005110] = 07521; code[005110] = &I05110;
  core[005111] = 07440; code[005111] = &I05111;
  core[005112] = 07402; code[005112] = &I05112;
  core[005113] = 07701; code[005113] = &I05113;
  core[005114] = 07040; code[005114] = &I05114;
  core[005115] = 07440; code[005115] = &I05115;
  core[005116] = 07402; code[005116] = &I05116;
  core[005117] = 07621; code[005117] = &I05117;
  core[005120] = 07040; code[005120] = &I05120;
  core[005121] = 07421; code[005121] = &I05121;
  core[005122] = 07521; code[005122] = &I05122;
  core[005123] = 07040; code[005123] = &I05123;
  core[005124] = 07440; code[005124] = &I05124;
  core[005125] = 07402; code[005125] = &I05125;
  core[005126] = 07701; code[005126] = &I05126;
  core[005127] = 07440; code[005127] = &I05127;
  core[005130] = 07402; code[005130] = &I05130;
  core[005131] = 07621; code[005131] = &I05131;
  core[005132] = 01070; code[005132] = &I05132;
  core[005133] = 07421; code[005133] = &I05133;
  core[005134] = 01071; code[005134] = &I05134;
  core[005135] = 07521; code[005135] = &I05135;
  core[005136] = 01071; code[005136] = &I05136;
  core[005137] = 07040; code[005137] = &I05137;
  core[005140] = 07440; code[005140] = &I05140;
  core[005141] = 07402; code[005141] = &I05141;
  core[005142] = 07701; code[005142] = &I05142;
  core[005143] = 01070; code[005143] = &I05143;
  core[005144] = 07040; code[005144] = &I05144;
  core[005145] = 07440; code[005145] = &I05145;
  core[005146] = 07402; code[005146] = &I05146;
  core[005147] = 07621; code[005147] = &I05147;
  core[005150] = 01071; code[005150] = &I05150;
  core[005151] = 07421; code[005151] = &I05151;
  core[005152] = 01070; code[005152] = &I05152;
  core[005153] = 07521; code[005153] = &I05153;
  core[005154] = 01070; code[005154] = &I05154;
  core[005155] = 07040; code[005155] = &I05155;
  core[005156] = 07440; code[005156] = &I05156;
  core[005157] = 07402; code[005157] = &I05157;
  core[005160] = 07701; code[005160] = &I05160;
  core[005161] = 01071; code[005161] = &I05161;
  core[005162] = 07040; code[005162] = &I05162;
  core[005163] = 07440; code[005163] = &I05163;
  core[005164] = 07402; code[005164] = &I05164;
  core[005165] = 07621; code[005165] = &I05165;
  core[005166] = 07040; code[005166] = &I05166;
  core[005167] = 07721; code[005167] = &I05167;
  core[005170] = 07440; code[005170] = &I05170;
  core[005171] = 07402; code[005171] = &I05171;
  core[005172] = 07701; code[005172] = &I05172;
  core[005173] = 07440; code[005173] = &I05173;
  core[005174] = 07402; code[005174] = &I05174;
  core[005175] = 07621; code[005175] = &I05175;
  core[005176] = 07040; code[005176] = &I05176;
  core[005177] = 07421; code[005177] = &I05177;
  core[005200] = 07721; code[005200] = &I05200;
  core[005201] = 07040; code[005201] = &I05201;
  core[005202] = 07440; code[005202] = &I05202;
  core[005203] = 07402; code[005203] = &I05203;
  core[005204] = 07701; code[005204] = &I05204;
  core[005205] = 07440; code[005205] = &I05205;
  core[005206] = 07402; code[005206] = &I05206;
  core[005207] = 07621; code[005207] = &I05207;
  core[005210] = 01071; code[005210] = &I05210;
  core[005211] = 07421; code[005211] = &I05211;
  core[005212] = 01070; code[005212] = &I05212;
  core[005213] = 07721; code[005213] = &I05213;
  core[005214] = 01070; code[005214] = &I05214;
  core[005215] = 07040; code[005215] = &I05215;
  core[005216] = 07440; code[005216] = &I05216;
  core[005217] = 07402; code[005217] = &I05217;
  core[005220] = 07701; code[005220] = &I05220;
  core[005221] = 07440; code[005221] = &I05221;
  core[005222] = 07402; code[005222] = &I05222;
  core[005223] = 07200; code[005223] = &I05223;
  core[005224] = 00067; code[005224] = &I05224;
  core[005225] = 07440; code[005225] = &I05225;
  core[005226] = 07402; code[005226] = &I05226;
  core[005227] = 07240; code[005227] = &I05227;
  core[005230] = 00020; code[005230] = &I05230;
  core[005231] = 07440; code[005231] = &I05231;
  core[005232] = 07402; code[005232] = &I05232;
  core[005233] = 07320; code[005233] = &I05233;
  core[005234] = 01067; code[005234] = &I05234;
  core[005235] = 00067; code[005235] = &I05235;
  core[005236] = 07040; code[005236] = &I05236;
  core[005237] = 07430; code[005237] = &I05237;
  core[005240] = 07440; code[005240] = &I05240;
  core[005241] = 07402; code[005241] = &I05241;
  core[005242] = 07300; code[005242] = &I05242;
  core[005243] = 01071; code[005243] = &I05243;
  core[005244] = 00070; code[005244] = &I05244;
  core[005245] = 07420; code[005245] = &I05245;
  core[005246] = 07440; code[005246] = &I05246;
  core[005247] = 07402; code[005247] = &I05247;
  core[005250] = 07300; code[005250] = &I05250;
  core[005251] = 01070; code[005251] = &I05251;
  core[005252] = 00071; code[005252] = &I05252;
  core[005253] = 07420; code[005253] = &I05253;
  core[005254] = 07440; code[005254] = &I05254;
  core[005255] = 07402; code[005255] = &I05255;
  core[005256] = 07300; code[005256] = &I05256;
  core[005257] = 01052; code[005257] = &I05257;
  core[005260] = 00070; code[005260] = &I05260;
  core[005261] = 07041; code[005261] = &I05261;
  core[005262] = 01070; code[005262] = &I05262;
  core[005263] = 07430; code[005263] = &I05263;
  core[005264] = 07440; code[005264] = &I05264;
  core[005265] = 07402; code[005265] = &I05265;
  core[005266] = 07300; code[005266] = &I05266;
  core[005267] = 01071; code[005267] = &I05267;
  core[005270] = 00071; code[005270] = &I05270;
  core[005271] = 07041; code[005271] = &I05271;
  core[005272] = 01071; code[005272] = &I05272;
  core[005273] = 07430; code[005273] = &I05273;
  core[005274] = 07440; code[005274] = &I05274;
  core[005275] = 07402; code[005275] = &I05275;
  core[005276] = 07200; code[005276] = &I05276;
  core[005277] = 01121; code[005277] = &I05277;
  core[005300] = 07001; code[005300] = &I05300;
  core[005301] = 03121; code[005301] = &I05301;
  core[005302] = 01121; code[005302] = &I05302;
  core[005303] = 07640; code[005303] = &I05303;
  core[005304] = 05147; code[005304] = &I05304;
  core[005305] = 01122; code[005305] = &I05305;
  core[005306] = 03121; code[005306] = &I05306;
  core[005307] = 01120; code[005307] = &I05307;
  core[005310] = 06046; code[005310] = &I05310;
  core[005311] = 06041; code[005311] = &L05311;
  core[005312] = 05311; code[005312] = &I05312;
  core[005313] = 06042; code[005313] = &I05313;
  core[005314] = 05147; code[005314] = &I05314;
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

