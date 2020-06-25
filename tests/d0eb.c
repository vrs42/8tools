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
void D00004() { lac &= (010000|core[000000]);  }
void D00005() { lac &= (010000|core[000000]);  }
void I00200() { emul8();  }
void I00201() { npc = (ib<<12)+core[130]; inh = 0;  }
void P00202() { emul8();  }
void L06600() { lac &= 010000; lac &= 07777;  }
void I06601() { core[006776] = lac & 07777; lac &= 010000; code[006776] = &emul8;  }
void L06602() { lac &= 010000; lac |= swr;  }
void I06603() { lac &= (010000|core[006771]);  }
void I06604() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06605() { npc = 006624; inh = 0;  }
void I06606() { core[(ib<<12)+core[3558]] = 06607; npc = (ib<<12)+core[3558]+1; code[(ib<<12)+core[3558]] = &emul8; inh = 0;  }
void I06607() { core[006755] = lac & 07777; lac &= 010000; code[006755] = &emul8;  }
void I06610() { lac ^= 07777;  }
void I06611() { lac &= (010000|core[000001]);  }
void I06612() { core[006753] = lac & 07777; lac &= 010000; code[006753] = &emul8;  }
void I06613() { lac ^= 07777;  }
void I06614() { lac &= (010000|core[000002]);  }
void I06615() { core[006754] = lac & 07777; lac &= 010000; code[006754] = &emul8;  }
void I06616() { lac ^= 07777;  }
void I06617() { lac &= (010000|core[000003]);  }
void I06620() { core[006756] = lac & 07777; lac &= 010000; code[006756] = &emul8;  }
void I06621() { lac ^= 07777;  }
void I06622() { lac &= (010000|core[000004]);  }
void I06623() { core[006757] = lac & 07777; lac &= 010000; code[006757] = &emul8;  }
void L06624() { lac &= 010000; lac |= swr;  }
void I06625() { lac &= (010000|core[006772]);  }
void I06626() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06627() { npc = 006634; inh = 0;  }
void I06630() { lac ^= 07777;  }
void I06631() { lac &= (010000|core[006760]);  }
void I06632() { core[(ib<<12)+core[3562]] = 06633; npc = (ib<<12)+core[3562]+1; code[(ib<<12)+core[3562]] = &emul8; inh = 0;  }
void I06633() { core[006760] = lac & 07777; lac &= 010000; code[006760] = &emul8;  }
void L06634() { lac &= 010000; lac |= swr;  }
void I06635() { lac &= (010000|core[006773]);  }
void I06636() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06637() { npc = 006644; inh = 0;  }
void I06640() { lac ^= 07777;  }
void I06641() { lac &= (010000|core[006761]);  }
void I06642() { core[(ib<<12)+core[3562]] = 06643; npc = (ib<<12)+core[3562]+1; code[(ib<<12)+core[3562]] = &emul8; inh = 0;  }
void I06643() { core[006761] = lac & 07777; lac &= 010000; code[006761] = &emul8;  }
void L06644() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I06645() { lac &= (010000|core[006753]);  }
void I06646() { core[(df<<12)+core[3564]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3564]] = &emul8;  }
void I06647() { lac ^= 07777;  }
void I06650() { lac &= (010000|core[006755]);  }
void I06651() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06652() { npc = 006702; inh = 0;  }
void I06653() { lac ^= 07777;  }
void I06654() { lac &= (010000|core[006756]);  }
void I06655() { lac &= (010000|core[006767]);  }
void I06656() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I06657() { npc = 006676; inh = 0;  }
void I06660() { lac ^= 07777;  }
void I06661() { lac &= (010000|core[006756]);  }
void I06662() { lac &= (010000|core[006775]);  }
void I06663() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I06664() { npc = 006676; inh = 0;  }
void I06665() { lac ^= 07777;  }
void I06666() { lac &= (010000|core[006757]);  }
void I06667() { lac ^= 07777; lac++;  }
void I06670() { lac ^= 07777;  }
void I06671() { core[(df<<12)+core[3566]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3566]] = &emul8;  }
void L06672() { lac ^= 07777;  }
void I06673() { lac &= (010000|core[006760]);  }
void I06674() { core[(df<<12)+core[3567]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3567]] = &emul8;  }
void I06675() { npc = 006705; inh = 0;  }
void L06676() { lac ^= 07777;  }
void I06677() { lac &= (010000|core[006757]);  }
void I06700() { core[(df<<12)+core[3566]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3566]] = &emul8;  }
void I06701() { npc = 006672; inh = 0;  }
void L06702() { lac ^= 07777;  }
void I06703() { lac &= (010000|core[006760]);  }
void I06704() { core[(df<<12)+core[3566]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3566]] = &emul8;  }
void L06705() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I06706() { lac &= (010000|core[006760]);  }
void I06707() { emul8();  }
void I06710() { lac ^= 07777;  }
void I06711() { lac &= (010000|core[006761]);  }
void I06712() { core[(ib<<12)+core[3561]] = 06713; npc = (ib<<12)+core[3561]+1; code[(ib<<12)+core[3561]] = &emul8; inh = 0;  }
void I06713() { core[006763] = lac & 07777; lac &= 010000; code[006763] = &emul8;  }
void I06714() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06715() { core[006762] = lac & 07777; lac &= 010000; code[006762] = &emul8;  }
void I06716() { lac ^= 07777;  }
void I06717() { lac &= (010000|core[006747]);  }
void I06720() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void I06721() { lac ^= 07777;  }
void I06722() { lac &= (010000|core[006754]);  }
void I06723() { lac++;  }
void I06724() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I06725() { npc = 006602; inh = 0;  }
void I06726() { core[006745] = lac & 07777; lac &= 010000; code[006745] = &emul8;  }
void I06727() { lac ^= 07777;  }
void I06730() { lac &= (010000|core[006766]);  }
void I06731() { core[(df<<12)+core[3557]] = lac & 07777; lac &= 010000; code[(df<<12)+core[3557]] = &emul8;  }
void I06732() { lac &= 07777; lac ^= 07777;  }
void I06733() { lac &= (010000|core[006761]);  }
void I06734() { npc = (ib<<12)+core[3564]; inh = 0;  }
void I06735() { core[006764] = lac & 07777; lac &= 010000; code[006764] = &emul8;  }
void I06736() { lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I06737() { core[006765] = lac & 07777; lac &= 010000; code[006765] = &emul8;  }
void I06740() { core[(ib<<12)+core[3580]] = 06741; npc = (ib<<12)+core[3580]+1; code[(ib<<12)+core[3580]] = &emul8; inh = 0;  }
void I06741() { if (++core[006776] == 010000) { core[006776] = 0; npc++; }; code[006776] = &emul8;  }
void I06742() { npc = 006602; inh = 0;  }
void I06743() { core[(ib<<12)+core[3560]] = 06744; npc = (ib<<12)+core[3560]+1; code[(ib<<12)+core[3560]] = &emul8; inh = 0;  }
void I06744() { npc = 006602; inh = 0;  }
void P06745() { lac &= (010000|core[000000]);  }
void P06746() {  }
void D06747() { emul8();  }
void P06750() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; hlt = 1;  }
void P06751() { lac &= 010000;  }
void P06752() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void D06753() { lac &= (010000|core[000000]);  }
void P06754() { lac &= (010000|core[000000]);  }
void D06755() { lac &= (010000|core[000000]);  }
void P06756() { lac &= (010000|core[000000]);  }
void P06757() { lac &= (010000|core[000000]);  }
void D06760() { lac &= (010000|core[000021]);  }
void D06761() { lac &= (010000|core[000037]);  }
void D06762() { lac &= (010000|core[000000]);  }
void D06763() { lac &= (010000|core[000000]);  }
void D06764() { lac &= (010000|core[000000]);  }
void D06765() { lac &= (010000|core[000000]);  }
void D06766() { npc = (ib<<12)+core[0]; inh = 0;  }
void D06767() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I06770() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D06771() { lac &= (010000|core[000001]);  }
void D06772() { lac &= (010000|core[000002]);  }
void D06773() { lac &= (010000|core[000004]);  }
void P06774() { lac &= 010000; lac &= 07777; lac++; lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void D06775() { lac &= (010000|core[000010]);  }
void D06776() { lac &= (010000|core[000000]);  }
void S07000() { lac &= (010000|core[000000]);  }
void L07001() { lac ^= 07777;  }
void I07002() { lac &= (010000|core[007150]);  }
void I07003() { core[(ib<<12)+core[3698]] = 07004; npc = (ib<<12)+core[3698]+1; code[(ib<<12)+core[3698]] = &emul8; inh = 0;  }
void I07004() { core[007150] = lac & 07777; lac &= 010000; code[007150] = &emul8;  }
void I07005() { lac ^= 07777;  }
void I07006() { lac &= (010000|core[007150]);  }
void I07007() { emul8();  }
void I07010() { lac ^= 07777;  }
void I07011() { lac &= (010000|core[007165]);  }
void I07012() { emul8();  }
void I07013() { lac &= (010000|core[007152]);  }
void I07014() { core[000001] = lac & 07777; lac &= 010000; code[000001] = &emul8;  }
void I07015() { lac ^= 07777;  }
void I07016() { lac &= (010000|core[000001]);  }
void I07017() { lac &= (010000|core[007155]);  }
void I07020() { core[007161] = lac & 07777; lac &= 010000; code[007161] = &emul8;  }
void L07021() { lac ^= 07777;  }
void I07022() { lac &= (010000|core[007153]);  }
void I07023() { core[(ib<<12)+core[3698]] = 07024; npc = (ib<<12)+core[3698]+1; code[(ib<<12)+core[3698]] = &emul8; inh = 0;  }
void I07024() { core[007153] = lac & 07777; lac &= 010000; code[007153] = &emul8;  }
void I07025() { lac ^= 07777;  }
void I07026() { lac &= (010000|core[007153]);  }
void I07027() { core[(ib<<12)+core[3711]] = 07030; npc = (ib<<12)+core[3711]+1; code[(ib<<12)+core[3711]] = &emul8; inh = 0;  }
void I07030() { npc = 007021; inh = 0;  }
void I07031() { lac ^= 07777;  }
void I07032() { lac &= (010000|core[007153]);  }
void I07033() { lac &= (010000|core[007154]);  }
void I07034() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07035() { npc = 007044; inh = 0;  }
void I07036() { lac ^= 07777;  }
void I07037() { lac &= (010000|core[007153]);  }
void L07040() { core[(ib<<12)+core[3710]] = 07041; npc = (ib<<12)+core[3710]+1; code[(ib<<12)+core[3710]] = &emul8; inh = 0;  }
void I07041() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I07042() { npc = 007021; inh = 0;  }
void I07043() { npc = 007055; inh = 0;  }
void L07044() { lac ^= 07777;  }
void I07045() { lac &= (010000|core[000001]);  }
void I07046() { lac &= (010000|core[007157]);  }
void I07047() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07050() { npc = 007055; inh = 0;  }
void I07051() { lac ^= 07777;  }
void I07052() { lac &= (010000|core[007153]);  }
void I07053() { lac &= (010000|core[007155]);  }
void I07054() { npc = 007040; inh = 0;  }
void L07055() { lac ^= 07777;  }
void I07056() { lac &= (010000|core[007161]);  }
void I07057() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07060() { npc = 007001; inh = 0;  }
void I07061() { lac ^= 07777;  }
void I07062() { lac &= (010000|core[007153]);  }
void I07063() { core[000002] = lac & 07777; lac &= 010000; code[000002] = &emul8;  }
void I07064() { lac ^= 07777;  }
void I07065() { lac &= (010000|core[000001]);  }
void I07066() { lac &= (010000|core[007157]);  }
void I07067() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07070() { npc = 007107; inh = 0;  }
void I07071() { lac ^= 07777;  }
void I07072() { lac &= (010000|core[000002]);  }
void I07073() { lac &= (010000|core[007154]);  }
void I07074() { emul8();  }
void I07075() { lac ^= 07777;  }
void I07076() { lac &= (010000|core[007161]);  }
void I07077() { emul8();  }
void I07100() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void L07101() { lac ^= 07777;  }
void I07102() { lac &= (010000|core[000001]);  }
void I07103() { lac &= (010000|core[007156]);  }
void I07104() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07105() { npc = 007113; inh = 0;  }
void I07106() { npc = (ib<<12)+core[3584]; inh = 0;  }
void L07107() { lac ^= 07777;  }
void I07110() { lac &= (010000|core[007161]);  }
void I07111() { core[000003] = lac & 07777; lac &= 010000; code[000003] = &emul8;  }
void I07112() { npc = 007101; inh = 0;  }
void L07113() { lac ^= 07777;  }
void I07114() { lac &= (010000|core[007160]);  }
void I07115() { core[(ib<<12)+core[3698]] = 07116; npc = (ib<<12)+core[3698]+1; code[(ib<<12)+core[3698]] = &emul8; inh = 0;  }
void I07116() { core[007160] = lac & 07777; lac &= 010000; code[007160] = &emul8;  }
void I07117() { lac ^= 07777;  }
void I07120() { lac &= (010000|core[007160]);  }
void I07121() { core[(ib<<12)+core[3711]] = 07122; npc = (ib<<12)+core[3711]+1; code[(ib<<12)+core[3711]] = &emul8; inh = 0;  }
void I07122() { npc = 007113; inh = 0;  }
void I07123() { lac ^= 07777;  }
void I07124() { lac &= (010000|core[000002]);  }
void I07125() { core[(ib<<12)+core[3709]] = 07126; npc = (ib<<12)+core[3709]+1; code[(ib<<12)+core[3709]] = &emul8; inh = 0;  }
void I07126() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I07127() { npc = 007113; inh = 0;  }
void I07130() { lac ^= 07777;  }
void I07131() { lac &= (010000|core[000003]);  }
void I07132() { core[(ib<<12)+core[3709]] = 07133; npc = (ib<<12)+core[3709]+1; code[(ib<<12)+core[3709]] = &emul8; inh = 0;  }
void I07133() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void I07134() { npc = 007113; inh = 0;  }
void I07135() { lac ^= 07777;  }
void I07136() { lac &= (010000|core[007160]);  }
void I07137() { lac ^= 07777; lac++;  }
void I07140() { lac ^= 07777;  }
void I07141() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I07142() { npc = 007113; inh = 0;  }
void I07143() { lac ^= 07777;  }
void I07144() { lac &= (010000|core[007160]);  }
void I07145() { core[000004] = lac & 07777; lac &= 010000; code[000004] = &emul8;  }
void I07146() { lac ^= 07777;  }
void I07147() { npc = (ib<<12)+core[3584]; inh = 0;  }
void D07150() { lac &= (010000|core[000001]);  }
void I07151() { lac &= (010000|core[000003]);  }
void D07152() { lac += core[(df<<12)+core[3711]];  }
void D07153() { lac &= (010000|core[000005]);  }
void D07154() { lac &= 010000;  }
void D07155() { lac &= (010000|core[000177]);  }
void D07156() { lac &= (010000|core[(df<<12)+core[0]]);  }
void D07157() { lac &= (010000|core[007000]);  }
void D07160() { lac &= (010000|core[000015]);  }
void D07161() { lac &= (010000|core[000000]);  }
void P07162() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I07163() { lac &= 010000;  }
void D07164() { lac += core[007001];  }
void D07165() { lac += core[000000];  }
void P07175() { emul8();  }
void P07176() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac |= swr;  }
void P07177() { lac &= 010000; lac &= 07777; lac++; lac = (lac&010000) + ((lac&077)<<6) + ((lac>>6)&077);  }
void S07200() { lac &= (010000|core[000000]);  }
void I07201() { core[007344] = lac & 07777; lac &= 010000; code[007344] = &emul8;  }
void I07202() { emul8();  }
void I07203() { core[007343] = lac & 07777; lac &= 010000; code[007343] = &emul8;  }
void I07204() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I07205() { lac &= (010000|core[007343]);  }
void I07206() { emul8();  }
void I07207() { lac ^= 07777;  }
void I07210() { lac &= (010000|core[007344]);  }
void I07211() { emul8();  }
void I07212() { core[007345] = lac & 07777; lac &= 010000; code[007345] = &emul8;  }
void I07213() { emul8();  }
void I07214() { lac ^= 07777;  }
void I07215() { lac &= (010000|core[007344]);  }
void I07216() { emul8();  }
void I07217() { lac ^= 07777;  }
void I07220() { lac &= (010000|core[007344]);  }
void I07221() { lac ^= 07777;  }
void I07222() { lac &= (010000|core[007343]);  }
void I07223() { emul8();  }
void I07224() { core[007346] = lac & 07777; lac &= 010000; code[007346] = &emul8;  }
void I07225() { core[007347] = lac & 07777; lac &= 010000; code[007347] = &emul8;  }
void I07226() { lac ^= 07777;  }
void I07227() { lac &= (010000|core[007343]);  }
void I07230() { lac &= (010000|core[007344]);  }
void I07231() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07232() { npc = 007274; inh = 0;  }
void I07233() { emul8();  }
void L07234() { emul8();  }
void I07235() { lac &= (010000|core[007345]);  }
void I07236() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07237() { npc = 007244; inh = 0;  }
void I07240() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I07241() { emul8();  }
void I07242() { emul8();  }
void I07243() { npc = 007234; inh = 0;  }
void L07244() { emul8();  }
void I07245() { lac &= (010000|core[007345]);  }
void I07246() { lac &= (010000|core[007350]);  }
void I07247() { skp = 0; if (!(lac&07777)) skp = 1; skp = !skp; npc += skp;  }
void I07250() { npc = 007253; inh = 0;  }
void I07251() { core[007347] = lac & 07777; lac &= 010000; code[007347] = &emul8;  }
void I07252() { npc = 007260; inh = 0;  }
void L07253() { lac &= 07777; lac ^= 010000; lac = ((lac&017777)>>1) + ((lac&1)<<12);  }
void I07254() { lac &= (010000|core[007343]);  }
void I07255() { lac &= (010000|core[007344]);  }
void I07256() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I07257() { core[007347] = lac & 07777; lac &= 010000; code[007347] = &emul8;  }
void L07260() { emul8();  }
void I07261() { core[007351] = lac & 07777; lac &= 010000; code[007351] = &emul8;  }
void I07262() { emul8();  }
void I07263() { lac ^= 07777;  }
void I07264() { lac &= (010000|core[007346]);  }
void I07265() { emul8();  }
void I07266() { lac ^= 07777;  }
void I07267() { lac &= (010000|core[007346]);  }
void I07270() { lac ^= 07777;  }
void I07271() { lac &= (010000|core[007351]);  }
void I07272() { emul8();  }
void I07273() { core[007346] = lac & 07777; lac &= 010000; code[007346] = &emul8;  }
void L07274() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I07275() { lac &= (010000|core[007347]);  }
void I07276() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07277() { lac ^= 010000;  }
void I07300() { lac ^= 07777;  }
void I07301() { lac &= (010000|core[007346]);  }
void I07302() { npc = (ib<<12)+core[3712]; inh = 0;  }
void S07303() { lac &= (010000|core[000000]);  }
void I07304() { emul8();  }
void I07305() { lac ^= 07777;  }
void I07306() { lac &= (010000|core[(df<<12)+core[3839]]);  }
void I07307() { core[007200] = 07310; npc = 007200+1; code[007200] = &emul8; inh = 0;  }
void I07310() { skp = 0; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I07311() { if (++core[007303] == 010000) { core[007303] = 0; npc++; }; code[007303] = &emul8;  }
void I07312() { npc = (ib<<12)+core[3779]; inh = 0;  }
void S07313() { lac &= (010000|core[000000]);  }
void I07314() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I07315() { lac &= (010000|core[(df<<12)+core[3838]]);  }
void I07316() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07317() { lac ^= 010000;  }
void I07320() { lac ^= 07777;  }
void I07321() { lac &= (010000|core[(df<<12)+core[3837]]);  }
void I07322() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07323() { lac ^= 010000;  }
void I07324() { skp = 0; if (lac&010000) skp = 1; skp = !skp; npc += skp;  }
void I07325() { npc = 007341; inh = 0;  }
void I07326() { lac &= 010000; lac &= 07777; lac ^= 07777;  }
void I07327() { lac &= (010000|core[(df<<12)+core[3836]]);  }
void I07330() { lac ^= 07777;  }
void I07331() { lac &= (010000|core[(df<<12)+core[3835]]);  }
void I07332() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I07333() { npc = 007341; inh = 0;  }
void I07334() { lac ^= 07777;  }
void I07335() { lac &= (010000|core[(df<<12)+core[3835]]);  }
void I07336() { lac ^= 07777;  }
void I07337() { lac &= (010000|core[(df<<12)+core[3836]]);  }
void I07340() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void L07341() { core[(ib<<12)+core[3818]] = 07342; npc = (ib<<12)+core[3818]+1; code[(ib<<12)+core[3818]] = &emul8; inh = 0;  }
void I07342() { npc = (ib<<12)+core[3787]; inh = 0;  }
void D07343() { lac &= (010000|core[000000]);  }
void D07344() { lac &= (010000|core[000000]);  }
void D07345() { lac &= (010000|core[000000]);  }
void D07346() { lac &= (010000|core[000000]);  }
void D07347() { lac &= (010000|core[000000]);  }
void D07350() { core[000000] = 07351; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void D07351() { lac &= (010000|core[000000]);  }
void P07352() {  }
void P07373() { emul8();  }
void P07374() { emul8();  }
void P07375() { emul8();  }
void P07376() { emul8();  }
void P07377() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void S07400() { lac &= (010000|core[000000]);  }
void I07401() { lac &= 010000; lac |= swr;  }
void I07402() { lac &= (010000|core[007467]);  }
void I07403() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07404() { npc = (ib<<12)+core[3840]; inh = 0;  }
void I07405() { lac &= 010000; lac ^= 07777;  }
void I07406() { lac &= (010000|core[(df<<12)+core[3967]]);  }
void I07407() { hlt = 1;  }
void I07410() { lac &= 010000; lac ^= 07777;  }
void I07411() { lac &= (010000|core[(df<<12)+core[3966]]);  }
void D07412() { hlt = 1;  }
void I07413() { lac &= 010000; lac ^= 07777;  }
void I07414() { lac &= (010000|core[(df<<12)+core[3965]]);  }
void D07415() { hlt = 1;  }
void I07416() { lac &= 010000; lac ^= 07777;  }
void I07417() { lac &= (010000|core[(df<<12)+core[3964]]);  }
void I07420() { hlt = 1;  }
void I07421() { lac &= 010000; lac ^= 07777;  }
void I07422() { lac &= (010000|core[(df<<12)+core[3963]]);  }
void I07423() { hlt = 1;  }
void I07424() { lac &= 010000; lac ^= 07777;  }
void I07425() { lac &= (010000|core[(df<<12)+core[3962]]);  }
void I07426() { hlt = 1;  }
void I07427() { npc = (ib<<12)+core[3840]; inh = 0;  }
void S07430() { lac &= (010000|core[000000]);  }
void I07431() { lac &= 07777; lac = (lac<<1) + ((lac>>12)&1);  }
void I07432() { skp = 0; if (lac&010000) skp = 1; npc += skp;  }
void I07433() { npc = 007440; inh = 0;  }
void I07434() { emul8();  }
void I07435() { lac ^= 07777;  }
void I07436() { lac &= (010000|core[007441]);  }
void I07437() { core[(ib<<12)+core[3961]] = 07440; npc = (ib<<12)+core[3961]+1; code[(ib<<12)+core[3961]] = &emul8; inh = 0;  }
void L07440() { npc = (ib<<12)+core[3864]; inh = 0;  }
void D07441() { lac &= (010000|core[000003]);  }
void S07442() { lac &= (010000|core[000000]);  }
void I07443() { lac &= 010000; lac |= swr;  }
void I07444() { lac &= (010000|core[007470]);  }
void I07445() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I07446() { npc = (ib<<12)+core[3874]; inh = 0;  }
void I07447() { lac ^= 07777;  }
void I07450() { lac &= (010000|core[007471]);  }
void I07451() { core[007461] = 07452; npc = 007461+1; code[007461] = &emul8; inh = 0;  }
void I07452() { lac ^= 07777;  }
void I07453() { lac &= (010000|core[007472]);  }
void I07454() { core[007461] = 07455; npc = 007461+1; code[007461] = &emul8; inh = 0;  }
void I07455() { lac ^= 07777;  }
void I07456() { lac &= (010000|core[007473]);  }
void I07457() { core[007461] = 07460; npc = 007461+1; code[007461] = &emul8; inh = 0;  }
void I07460() { npc = (ib<<12)+core[3874]; inh = 0;  }
void S07461() { lac &= (010000|core[000000]);  }
void I07462() { emul8();  }
void L07463() { emul8();  }
void I07464() { npc = 007463; inh = 0;  }
void I07465() { lac &= 010000;  }
void I07466() { npc = (ib<<12)+core[3889]; inh = 0;  }
void D07467() { core[000000] = 07470; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void D07470() { lac &= (010000|core[(df<<12)+core[0]]);  }
void D07471() { lac &= (010000|core[007415]);  }
void D07472() { lac &= (010000|core[007412]);  }
void D07473() { lac &= (010000|core[007524]);  }
void S07474() { lac &= (010000|core[000000]);  }
void I07475() { lac ^= 07777; lac++;  }
void I07476() { emul8();  }
void I07477() { lac ^= 07777;  }
void I07500() { lac &= (010000|core[(df<<12)+core[3960]]);  }
void I07501() { core[(ib<<12)+core[3961]] = 07502; npc = (ib<<12)+core[3961]+1; code[(ib<<12)+core[3961]] = &emul8; inh = 0;  }
void I07502() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I07503() { lac ^= 07777; lac++;  }
void I07504() { lac++;  }
void I07505() { lac++;  }
void I07506() { npc = (ib<<12)+core[3900]; inh = 0;  }
void S07507() { lac &= (010000|core[000000]);  }
void I07510() { lac ^= 07777; lac++;  }
void I07511() { emul8();  }
void I07512() { lac ^= 07777;  }
void I07513() { lac &= (010000|core[(df<<12)+core[3959]]);  }
void I07514() { core[(ib<<12)+core[3961]] = 07515; npc = (ib<<12)+core[3961]+1; code[(ib<<12)+core[3961]] = &emul8; inh = 0;  }
void I07515() { skp = 0; if (lac&04000) skp = 1; npc += skp;  }
void I07516() { lac ^= 07777; lac++;  }
void I07517() { lac++;  }
void I07520() { lac++;  }
void I07521() { npc = (ib<<12)+core[3911]; inh = 0;  }
void P07567() { lac &= 07777; lac ^= 010000; lac ^= 07777;  }
void P07570() { lac &= 07777; lac ^= 010000; lac ^= 07777; lac++;  }
void P07571() { lac &= 010000;  }
void P07572() { emul8();  }
void P07573() { emul8();  }
void P07574() { emul8();  }
void P07575() { emul8();  }
void P07576() { emul8();  }
void P07577() { emul8();  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &L00001;
  core[000002] = 00002; code[000002] = &D00002;
  core[000003] = 00003; code[000003] = &D00003;
  core[000004] = 00000; code[000004] = &D00004;
  core[000005] = 00000; code[000005] = &D00005;
  core[000200] = 06007; code[000200] = &I00200;
  core[000201] = 05602; code[000201] = &I00201;
  core[000202] = 06600; code[000202] = &P00202;
  core[006600] = 07300; code[006600] = &L06600;
  core[006601] = 03376; code[006601] = &I06601;
  core[006602] = 07604; code[006602] = &L06602;
  core[006603] = 00371; code[006603] = &I06603;
  core[006604] = 07640; code[006604] = &I06604;
  core[006605] = 05224; code[006605] = &I06605;
  core[006606] = 04746; code[006606] = &I06606;
  core[006607] = 03355; code[006607] = &I06607;
  core[006610] = 07040; code[006610] = &I06610;
  core[006611] = 00001; code[006611] = &I06611;
  core[006612] = 03353; code[006612] = &I06612;
  core[006613] = 07040; code[006613] = &I06613;
  core[006614] = 00002; code[006614] = &I06614;
  core[006615] = 03354; code[006615] = &I06615;
  core[006616] = 07040; code[006616] = &I06616;
  core[006617] = 00003; code[006617] = &I06617;
  core[006620] = 03356; code[006620] = &I06620;
  core[006621] = 07040; code[006621] = &I06621;
  core[006622] = 00004; code[006622] = &I06622;
  core[006623] = 03357; code[006623] = &I06623;
  core[006624] = 07604; code[006624] = &L06624;
  core[006625] = 00372; code[006625] = &I06625;
  core[006626] = 07640; code[006626] = &I06626;
  core[006627] = 05234; code[006627] = &I06627;
  core[006630] = 07040; code[006630] = &I06630;
  core[006631] = 00360; code[006631] = &I06631;
  core[006632] = 04752; code[006632] = &I06632;
  core[006633] = 03360; code[006633] = &I06633;
  core[006634] = 07604; code[006634] = &L06634;
  core[006635] = 00373; code[006635] = &I06635;
  core[006636] = 07640; code[006636] = &I06636;
  core[006637] = 05244; code[006637] = &I06637;
  core[006640] = 07040; code[006640] = &I06640;
  core[006641] = 00361; code[006641] = &I06641;
  core[006642] = 04752; code[006642] = &I06642;
  core[006643] = 03361; code[006643] = &I06643;
  core[006644] = 07340; code[006644] = &L06644;
  core[006645] = 00353; code[006645] = &I06645;
  core[006646] = 03754; code[006646] = &I06646;
  core[006647] = 07040; code[006647] = &I06647;
  core[006650] = 00355; code[006650] = &I06650;
  core[006651] = 07650; code[006651] = &I06651;
  core[006652] = 05302; code[006652] = &I06652;
  core[006653] = 07040; code[006653] = &I06653;
  core[006654] = 00356; code[006654] = &I06654;
  core[006655] = 00367; code[006655] = &I06655;
  core[006656] = 07640; code[006656] = &I06656;
  core[006657] = 05276; code[006657] = &I06657;
  core[006660] = 07040; code[006660] = &I06660;
  core[006661] = 00356; code[006661] = &I06661;
  core[006662] = 00375; code[006662] = &I06662;
  core[006663] = 07650; code[006663] = &I06663;
  core[006664] = 05276; code[006664] = &I06664;
  core[006665] = 07040; code[006665] = &I06665;
  core[006666] = 00357; code[006666] = &I06666;
  core[006667] = 07041; code[006667] = &I06667;
  core[006670] = 07040; code[006670] = &I06670;
  core[006671] = 03756; code[006671] = &I06671;
  core[006672] = 07040; code[006672] = &L06672;
  core[006673] = 00360; code[006673] = &I06673;
  core[006674] = 03757; code[006674] = &I06674;
  core[006675] = 05305; code[006675] = &I06675;
  core[006676] = 07040; code[006676] = &L06676;
  core[006677] = 00357; code[006677] = &I06677;
  core[006700] = 03756; code[006700] = &I06700;
  core[006701] = 05272; code[006701] = &I06701;
  core[006702] = 07040; code[006702] = &L06702;
  core[006703] = 00360; code[006703] = &I06703;
  core[006704] = 03756; code[006704] = &I06704;
  core[006705] = 07340; code[006705] = &L06705;
  core[006706] = 00360; code[006706] = &I06706;
  core[006707] = 07421; code[006707] = &I06707;
  core[006710] = 07040; code[006710] = &I06710;
  core[006711] = 00361; code[006711] = &I06711;
  core[006712] = 04751; code[006712] = &I06712;
  core[006713] = 03363; code[006713] = &I06713;
  core[006714] = 07010; code[006714] = &I06714;
  core[006715] = 03362; code[006715] = &I06715;
  core[006716] = 07040; code[006716] = &I06716;
  core[006717] = 00347; code[006717] = &I06717;
  core[006720] = 03000; code[006720] = &I06720;
  core[006721] = 07040; code[006721] = &I06721;
  core[006722] = 00354; code[006722] = &I06722;
  core[006723] = 07001; code[006723] = &I06723;
  core[006724] = 07450; code[006724] = &I06724;
  core[006725] = 05202; code[006725] = &I06725;
  core[006726] = 03345; code[006726] = &I06726;
  core[006727] = 07040; code[006727] = &I06727;
  core[006730] = 00366; code[006730] = &I06730;
  core[006731] = 03745; code[006731] = &I06731;
  core[006732] = 07140; code[006732] = &I06732;
  core[006733] = 00361; code[006733] = &I06733;
  core[006734] = 05754; code[006734] = &I06734;
  core[006735] = 03364; code[006735] = &I06735;
  core[006736] = 07010; code[006736] = &I06736;
  core[006737] = 03365; code[006737] = &I06737;
  core[006740] = 04774; code[006740] = &I06740;
  core[006741] = 02376; code[006741] = &I06741;
  core[006742] = 05202; code[006742] = &I06742;
  core[006743] = 04750; code[006743] = &I06743;
  core[006744] = 05202; code[006744] = &I06744;
  core[006745] = 00000; code[006745] = &P06745;
  core[006746] = 07000; code[006746] = &P06746;
  core[006747] = 06735; code[006747] = &D06747;
  core[006750] = 07442; code[006750] = &P06750;
  core[006751] = 07200; code[006751] = &P06751;
  core[006752] = 07430; code[006752] = &P06752;
  core[006753] = 00000; code[006753] = &D06753;
  core[006754] = 00000; code[006754] = &P06754;
  core[006755] = 00000; code[006755] = &D06755;
  core[006756] = 00000; code[006756] = &P06756;
  core[006757] = 00000; code[006757] = &P06757;
  core[006760] = 00021; code[006760] = &D06760;
  core[006761] = 00037; code[006761] = &D06761;
  core[006762] = 00000; code[006762] = &D06762;
  core[006763] = 00000; code[006763] = &D06763;
  core[006764] = 00000; code[006764] = &D06764;
  core[006765] = 00000; code[006765] = &D06765;
  core[006766] = 05400; code[006766] = &D06766;
  core[006767] = 07760; code[006767] = &D06767;
  core[006770] = 07770; code[006770] = &I06770;
  core[006771] = 00001; code[006771] = &D06771;
  core[006772] = 00002; code[006772] = &D06772;
  core[006773] = 00004; code[006773] = &D06773;
  core[006774] = 07313; code[006774] = &P06774;
  core[006775] = 00010; code[006775] = &D06775;
  core[006776] = 00000; code[006776] = &D06776;
  core[007000] = 00000; code[007000] = &S07000;
  core[007001] = 07040; code[007001] = &L07001;
  core[007002] = 00350; code[007002] = &I07002;
  core[007003] = 04762; code[007003] = &I07003;
  core[007004] = 03350; code[007004] = &I07004;
  core[007005] = 07040; code[007005] = &I07005;
  core[007006] = 00350; code[007006] = &I07006;
  core[007007] = 07421; code[007007] = &I07007;
  core[007010] = 07040; code[007010] = &I07010;
  core[007011] = 00365; code[007011] = &I07011;
  core[007012] = 07501; code[007012] = &I07012;
  core[007013] = 00352; code[007013] = &I07013;
  core[007014] = 03001; code[007014] = &I07014;
  core[007015] = 07040; code[007015] = &I07015;
  core[007016] = 00001; code[007016] = &I07016;
  core[007017] = 00355; code[007017] = &I07017;
  core[007020] = 03361; code[007020] = &I07020;
  core[007021] = 07040; code[007021] = &L07021;
  core[007022] = 00353; code[007022] = &I07022;
  core[007023] = 04762; code[007023] = &I07023;
  core[007024] = 03353; code[007024] = &I07024;
  core[007025] = 07040; code[007025] = &I07025;
  core[007026] = 00353; code[007026] = &I07026;
  core[007027] = 04777; code[007027] = &I07027;
  core[007030] = 05221; code[007030] = &I07030;
  core[007031] = 07040; code[007031] = &I07031;
  core[007032] = 00353; code[007032] = &I07032;
  core[007033] = 00354; code[007033] = &I07033;
  core[007034] = 07640; code[007034] = &I07034;
  core[007035] = 05244; code[007035] = &I07035;
  core[007036] = 07040; code[007036] = &I07036;
  core[007037] = 00353; code[007037] = &I07037;
  core[007040] = 04776; code[007040] = &L07040;
  core[007041] = 07700; code[007041] = &I07041;
  core[007042] = 05221; code[007042] = &I07042;
  core[007043] = 05255; code[007043] = &I07043;
  core[007044] = 07040; code[007044] = &L07044;
  core[007045] = 00001; code[007045] = &I07045;
  core[007046] = 00357; code[007046] = &I07046;
  core[007047] = 07650; code[007047] = &I07047;
  core[007050] = 05255; code[007050] = &I07050;
  core[007051] = 07040; code[007051] = &I07051;
  core[007052] = 00353; code[007052] = &I07052;
  core[007053] = 00355; code[007053] = &I07053;
  core[007054] = 05240; code[007054] = &I07054;
  core[007055] = 07040; code[007055] = &L07055;
  core[007056] = 00361; code[007056] = &I07056;
  core[007057] = 07650; code[007057] = &I07057;
  core[007060] = 05201; code[007060] = &I07060;
  core[007061] = 07040; code[007061] = &I07061;
  core[007062] = 00353; code[007062] = &I07062;
  core[007063] = 03002; code[007063] = &I07063;
  core[007064] = 07040; code[007064] = &I07064;
  core[007065] = 00001; code[007065] = &I07065;
  core[007066] = 00357; code[007066] = &I07066;
  core[007067] = 07650; code[007067] = &I07067;
  core[007070] = 05307; code[007070] = &I07070;
  core[007071] = 07040; code[007071] = &I07071;
  core[007072] = 00002; code[007072] = &I07072;
  core[007073] = 00354; code[007073] = &I07073;
  core[007074] = 07421; code[007074] = &I07074;
  core[007075] = 07040; code[007075] = &I07075;
  core[007076] = 00361; code[007076] = &I07076;
  core[007077] = 07501; code[007077] = &I07077;
  core[007100] = 03003; code[007100] = &I07100;
  core[007101] = 07040; code[007101] = &L07101;
  core[007102] = 00001; code[007102] = &I07102;
  core[007103] = 00356; code[007103] = &I07103;
  core[007104] = 07640; code[007104] = &I07104;
  core[007105] = 05313; code[007105] = &I07105;
  core[007106] = 05600; code[007106] = &I07106;
  core[007107] = 07040; code[007107] = &L07107;
  core[007110] = 00361; code[007110] = &I07110;
  core[007111] = 03003; code[007111] = &I07111;
  core[007112] = 05301; code[007112] = &I07112;
  core[007113] = 07040; code[007113] = &L07113;
  core[007114] = 00360; code[007114] = &I07114;
  core[007115] = 04762; code[007115] = &I07115;
  core[007116] = 03360; code[007116] = &I07116;
  core[007117] = 07040; code[007117] = &I07117;
  core[007120] = 00360; code[007120] = &I07120;
  core[007121] = 04777; code[007121] = &I07121;
  core[007122] = 05313; code[007122] = &I07122;
  core[007123] = 07040; code[007123] = &I07123;
  core[007124] = 00002; code[007124] = &I07124;
  core[007125] = 04775; code[007125] = &I07125;
  core[007126] = 07700; code[007126] = &I07126;
  core[007127] = 05313; code[007127] = &I07127;
  core[007130] = 07040; code[007130] = &I07130;
  core[007131] = 00003; code[007131] = &I07131;
  core[007132] = 04775; code[007132] = &I07132;
  core[007133] = 07700; code[007133] = &I07133;
  core[007134] = 05313; code[007134] = &I07134;
  core[007135] = 07040; code[007135] = &I07135;
  core[007136] = 00360; code[007136] = &I07136;
  core[007137] = 07041; code[007137] = &I07137;
  core[007140] = 07040; code[007140] = &I07140;
  core[007141] = 07650; code[007141] = &I07141;
  core[007142] = 05313; code[007142] = &I07142;
  core[007143] = 07040; code[007143] = &I07143;
  core[007144] = 00360; code[007144] = &I07144;
  core[007145] = 03004; code[007145] = &I07145;
  core[007146] = 07040; code[007146] = &I07146;
  core[007147] = 05600; code[007147] = &I07147;
  core[007150] = 00001; code[007150] = &D07150;
  core[007151] = 00003; code[007151] = &I07151;
  core[007152] = 01777; code[007152] = &D07152;
  core[007153] = 00005; code[007153] = &D07153;
  core[007154] = 07600; code[007154] = &D07154;
  core[007155] = 00177; code[007155] = &D07155;
  core[007156] = 00400; code[007156] = &D07156;
  core[007157] = 00200; code[007157] = &D07157;
  core[007160] = 00015; code[007160] = &D07160;
  core[007161] = 00000; code[007161] = &D07161;
  core[007162] = 07430; code[007162] = &P07162;
  core[007163] = 07200; code[007163] = &I07163;
  core[007164] = 01201; code[007164] = &D07164;
  core[007165] = 01000; code[007165] = &D07165;
  core[007175] = 07507; code[007175] = &P07175;
  core[007176] = 07474; code[007176] = &P07176;
  core[007177] = 07303; code[007177] = &P07177;
  core[007200] = 00000; code[007200] = &S07200;
  core[007201] = 03344; code[007201] = &I07201;
  core[007202] = 07501; code[007202] = &I07202;
  core[007203] = 03343; code[007203] = &I07203;
  core[007204] = 07340; code[007204] = &I07204;
  core[007205] = 00343; code[007205] = &I07205;
  core[007206] = 07421; code[007206] = &I07206;
  core[007207] = 07040; code[007207] = &I07207;
  core[007210] = 00344; code[007210] = &I07210;
  core[007211] = 07501; code[007211] = &I07211;
  core[007212] = 03345; code[007212] = &I07212;
  core[007213] = 07501; code[007213] = &I07213;
  core[007214] = 07040; code[007214] = &I07214;
  core[007215] = 00344; code[007215] = &I07215;
  core[007216] = 07421; code[007216] = &I07216;
  core[007217] = 07040; code[007217] = &I07217;
  core[007220] = 00344; code[007220] = &I07220;
  core[007221] = 07040; code[007221] = &I07221;
  core[007222] = 00343; code[007222] = &I07222;
  core[007223] = 07501; code[007223] = &I07223;
  core[007224] = 03346; code[007224] = &I07224;
  core[007225] = 03347; code[007225] = &I07225;
  core[007226] = 07040; code[007226] = &I07226;
  core[007227] = 00343; code[007227] = &I07227;
  core[007230] = 00344; code[007230] = &I07230;
  core[007231] = 07450; code[007231] = &I07231;
  core[007232] = 05274; code[007232] = &I07232;
  core[007233] = 07421; code[007233] = &I07233;
  core[007234] = 07521; code[007234] = &L07234;
  core[007235] = 00345; code[007235] = &I07235;
  core[007236] = 07450; code[007236] = &I07236;
  core[007237] = 05244; code[007237] = &I07237;
  core[007240] = 07104; code[007240] = &I07240;
  core[007241] = 07521; code[007241] = &I07241;
  core[007242] = 07501; code[007242] = &I07242;
  core[007243] = 05234; code[007243] = &I07243;
  core[007244] = 07501; code[007244] = &L07244;
  core[007245] = 00345; code[007245] = &I07245;
  core[007246] = 00350; code[007246] = &I07246;
  core[007247] = 07450; code[007247] = &I07247;
  core[007250] = 05253; code[007250] = &I07250;
  core[007251] = 03347; code[007251] = &I07251;
  core[007252] = 05260; code[007252] = &I07252;
  core[007253] = 07130; code[007253] = &L07253;
  core[007254] = 00343; code[007254] = &I07254;
  core[007255] = 00344; code[007255] = &I07255;
  core[007256] = 07440; code[007256] = &I07256;
  core[007257] = 03347; code[007257] = &I07257;
  core[007260] = 07501; code[007260] = &L07260;
  core[007261] = 03351; code[007261] = &I07261;
  core[007262] = 07501; code[007262] = &I07262;
  core[007263] = 07040; code[007263] = &I07263;
  core[007264] = 00346; code[007264] = &I07264;
  core[007265] = 07421; code[007265] = &I07265;
  core[007266] = 07040; code[007266] = &I07266;
  core[007267] = 00346; code[007267] = &I07267;
  core[007270] = 07040; code[007270] = &I07270;
  core[007271] = 00351; code[007271] = &I07271;
  core[007272] = 07501; code[007272] = &I07272;
  core[007273] = 03346; code[007273] = &I07273;
  core[007274] = 07340; code[007274] = &L07274;
  core[007275] = 00347; code[007275] = &I07275;
  core[007276] = 07640; code[007276] = &I07276;
  core[007277] = 07020; code[007277] = &I07277;
  core[007300] = 07040; code[007300] = &I07300;
  core[007301] = 00346; code[007301] = &I07301;
  core[007302] = 05600; code[007302] = &I07302;
  core[007303] = 00000; code[007303] = &S07303;
  core[007304] = 07421; code[007304] = &I07304;
  core[007305] = 07040; code[007305] = &I07305;
  core[007306] = 00777; code[007306] = &I07306;
  core[007307] = 04200; code[007307] = &I07307;
  core[007310] = 07620; code[007310] = &I07310;
  core[007311] = 02303; code[007311] = &I07311;
  core[007312] = 05703; code[007312] = &I07312;
  core[007313] = 00000; code[007313] = &S07313;
  core[007314] = 07340; code[007314] = &I07314;
  core[007315] = 00776; code[007315] = &I07315;
  core[007316] = 07640; code[007316] = &I07316;
  core[007317] = 07020; code[007317] = &I07317;
  core[007320] = 07040; code[007320] = &I07320;
  core[007321] = 00775; code[007321] = &I07321;
  core[007322] = 07640; code[007322] = &I07322;
  core[007323] = 07020; code[007323] = &I07323;
  core[007324] = 07430; code[007324] = &I07324;
  core[007325] = 05341; code[007325] = &I07325;
  core[007326] = 07340; code[007326] = &I07326;
  core[007327] = 00774; code[007327] = &I07327;
  core[007330] = 07040; code[007330] = &I07330;
  core[007331] = 00773; code[007331] = &I07331;
  core[007332] = 07440; code[007332] = &I07332;
  core[007333] = 05341; code[007333] = &I07333;
  core[007334] = 07040; code[007334] = &I07334;
  core[007335] = 00773; code[007335] = &I07335;
  core[007336] = 07040; code[007336] = &I07336;
  core[007337] = 00774; code[007337] = &I07337;
  core[007340] = 07640; code[007340] = &I07340;
  core[007341] = 04752; code[007341] = &L07341;
  core[007342] = 05713; code[007342] = &I07342;
  core[007343] = 00000; code[007343] = &D07343;
  core[007344] = 00000; code[007344] = &D07344;
  core[007345] = 00000; code[007345] = &D07345;
  core[007346] = 00000; code[007346] = &D07346;
  core[007347] = 00000; code[007347] = &D07347;
  core[007350] = 04000; code[007350] = &D07350;
  core[007351] = 00000; code[007351] = &D07351;
  core[007352] = 07400; code[007352] = &P07352;
  core[007373] = 06763; code[007373] = &P07373;
  core[007374] = 06764; code[007374] = &P07374;
  core[007375] = 06765; code[007375] = &P07375;
  core[007376] = 06762; code[007376] = &P07376;
  core[007377] = 07164; code[007377] = &P07377;
  core[007400] = 00000; code[007400] = &S07400;
  core[007401] = 07604; code[007401] = &I07401;
  core[007402] = 00267; code[007402] = &I07402;
  core[007403] = 07640; code[007403] = &I07403;
  core[007404] = 05600; code[007404] = &I07404;
  core[007405] = 07240; code[007405] = &I07405;
  core[007406] = 00777; code[007406] = &I07406;
  core[007407] = 07402; code[007407] = &I07407;
  core[007410] = 07240; code[007410] = &I07410;
  core[007411] = 00776; code[007411] = &I07411;
  core[007412] = 07402; code[007412] = &D07412;
  core[007413] = 07240; code[007413] = &I07413;
  core[007414] = 00775; code[007414] = &I07414;
  core[007415] = 07402; code[007415] = &D07415;
  core[007416] = 07240; code[007416] = &I07416;
  core[007417] = 00774; code[007417] = &I07417;
  core[007420] = 07402; code[007420] = &I07420;
  core[007421] = 07240; code[007421] = &I07421;
  core[007422] = 00773; code[007422] = &I07422;
  core[007423] = 07402; code[007423] = &I07423;
  core[007424] = 07240; code[007424] = &I07424;
  core[007425] = 00772; code[007425] = &I07425;
  core[007426] = 07402; code[007426] = &I07426;
  core[007427] = 05600; code[007427] = &I07427;
  core[007430] = 00000; code[007430] = &S07430;
  core[007431] = 07104; code[007431] = &I07431;
  core[007432] = 07420; code[007432] = &I07432;
  core[007433] = 05240; code[007433] = &I07433;
  core[007434] = 07421; code[007434] = &I07434;
  core[007435] = 07040; code[007435] = &I07435;
  core[007436] = 00241; code[007436] = &I07436;
  core[007437] = 04771; code[007437] = &I07437;
  core[007440] = 05630; code[007440] = &L07440;
  core[007441] = 00003; code[007441] = &D07441;
  core[007442] = 00000; code[007442] = &S07442;
  core[007443] = 07604; code[007443] = &I07443;
  core[007444] = 00270; code[007444] = &I07444;
  core[007445] = 07640; code[007445] = &I07445;
  core[007446] = 05642; code[007446] = &I07446;
  core[007447] = 07040; code[007447] = &I07447;
  core[007450] = 00271; code[007450] = &I07450;
  core[007451] = 04261; code[007451] = &I07451;
  core[007452] = 07040; code[007452] = &I07452;
  core[007453] = 00272; code[007453] = &I07453;
  core[007454] = 04261; code[007454] = &I07454;
  core[007455] = 07040; code[007455] = &I07455;
  core[007456] = 00273; code[007456] = &I07456;
  core[007457] = 04261; code[007457] = &I07457;
  core[007460] = 05642; code[007460] = &I07460;
  core[007461] = 00000; code[007461] = &S07461;
  core[007462] = 06046; code[007462] = &I07462;
  core[007463] = 06041; code[007463] = &L07463;
  core[007464] = 05263; code[007464] = &I07464;
  core[007465] = 07200; code[007465] = &I07465;
  core[007466] = 05661; code[007466] = &I07466;
  core[007467] = 04000; code[007467] = &D07467;
  core[007470] = 00400; code[007470] = &D07470;
  core[007471] = 00215; code[007471] = &D07471;
  core[007472] = 00212; code[007472] = &D07472;
  core[007473] = 00324; code[007473] = &D07473;
  core[007474] = 00000; code[007474] = &S07474;
  core[007475] = 07041; code[007475] = &I07475;
  core[007476] = 07421; code[007476] = &I07476;
  core[007477] = 07040; code[007477] = &I07477;
  core[007500] = 00770; code[007500] = &I07500;
  core[007501] = 04771; code[007501] = &I07501;
  core[007502] = 07500; code[007502] = &I07502;
  core[007503] = 07041; code[007503] = &I07503;
  core[007504] = 07001; code[007504] = &I07504;
  core[007505] = 07001; code[007505] = &I07505;
  core[007506] = 05674; code[007506] = &I07506;
  core[007507] = 00000; code[007507] = &S07507;
  core[007510] = 07041; code[007510] = &I07510;
  core[007511] = 07421; code[007511] = &I07511;
  core[007512] = 07040; code[007512] = &I07512;
  core[007513] = 00767; code[007513] = &I07513;
  core[007514] = 04771; code[007514] = &I07514;
  core[007515] = 07500; code[007515] = &I07515;
  core[007516] = 07041; code[007516] = &I07516;
  core[007517] = 07001; code[007517] = &I07517;
  core[007520] = 07001; code[007520] = &I07520;
  core[007521] = 05707; code[007521] = &I07521;
  core[007567] = 07160; code[007567] = &P07567;
  core[007570] = 07161; code[007570] = &P07570;
  core[007571] = 07200; code[007571] = &P07571;
  core[007572] = 06757; code[007572] = &P07572;
  core[007573] = 06756; code[007573] = &P07573;
  core[007574] = 06754; code[007574] = &P07574;
  core[007575] = 06753; code[007575] = &P07575;
  core[007576] = 06761; code[007576] = &P07576;
  core[007577] = 06760; code[007577] = &P07577;
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

