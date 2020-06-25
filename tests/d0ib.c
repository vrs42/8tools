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
void L00002() { lac &= (010000|core[000002]);  }
void D00003() { lac &= (010000|core[000003]);  }
void L00004() { lac &= (010000|core[000000]);  }
void D00005() { lac &= (010000|core[000000]);  }
void I00006() { hlt = 1;  }
void I00007() { hlt = 1;  }
void P00010() { hlt = 1;  }
void D00011() { hlt = 1;  }
void I00012() { hlt = 1;  }
void I00013() { hlt = 1;  }
void I00014() { hlt = 1;  }
void I00015() { hlt = 1;  }
void I00016() { hlt = 1;  }
void I00017() { hlt = 1;  }
void P00020() { hlt = 1;  }
void D00021() { hlt = 1;  }
void P00022() { lac &= (010000|core[000000]);  }
void P00023() { lac &= (010000|core[000001]);  }
void P00024() { lac &= (010000|core[000002]);  }
void P00025() { lac &= (010000|core[000004]);  }
void P00026() { lac &= (010000|core[000010]);  }
void P00027() { lac &= (010000|core[000020]);  }
void P00030() { lac &= (010000|core[000040]);  }
void P00031() { lac &= (010000|core[000100]);  }
void P00032() { lac &= (010000|core[000000]);  }
void P00033() { lac &= (010000|core[(df<<12)+core[0]]);  }
void P00034() { lac += core[000000];  }
void P00035() { if (++core[000000] == 010000) { core[000000] = 0; npc++; }; code[000000] = &emul8;  }
void P00036() { core[000000] = 00037; npc = 000000+1; code[000000] = &emul8; inh = 0;  }
void P00037() { core[(df<<12)+core[127]] = lac & 07777; lac &= 010000; code[(df<<12)+core[127]] = &emul8;  }
void P00042() { npc = (ib<<12)+core[127]; inh = 0;  }
void P00043() { emul8();  }
void P00044() { lac &= 010000; lac &= 07777; lac ^= 010000; lac ^= 07777; lac++; lac = (lac<<2) + ((lac>>11)&3); lac = ((lac&017777)>>2) + ((lac&3)<<11);  }
void P00045() { emul8();  }
void P00046() { emul8();  }
void P00047() { emul8();  }
void P00050() { emul8();  }
void P00051() { emul8();  }
void P00052() { emul8();  }
void P00053() { emul8();  }
void P00054() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P00055() { emul8();  }
void P00056() { core[(ib<<12)+core[16]] = 00057; npc = (ib<<12)+core[16]+1; code[(ib<<12)+core[16]] = &emul8; inh = 0;  }
void P00057() { core[(ib<<12)+core[32]] = 00060; npc = (ib<<12)+core[32]+1; code[(ib<<12)+core[32]] = &emul8; inh = 0;  }
void P00060() { core[(ib<<12)+core[48]] = 00061; npc = (ib<<12)+core[48]+1; code[(ib<<12)+core[48]] = &emul8; inh = 0;  }
void P00061() { core[(ib<<12)+core[64]] = 00062; npc = (ib<<12)+core[64]+1; code[(ib<<12)+core[64]] = &emul8; inh = 0;  }
void P00062() { core[(ib<<12)+core[80]] = 00063; npc = (ib<<12)+core[80]+1; code[(ib<<12)+core[80]] = &emul8; inh = 0;  }
void P00063() { core[(ib<<12)+core[96]] = 00064; npc = (ib<<12)+core[96]+1; code[(ib<<12)+core[96]] = &emul8; inh = 0;  }
void P00064() { core[(ib<<12)+core[112]] = 00065; npc = (ib<<12)+core[112]+1; code[(ib<<12)+core[112]] = &emul8; inh = 0;  }
void P00065() { npc = 000000; inh = 0;  }
void P00066() { npc = 000020; inh = 0;  }
void P00067() { npc = 000040; inh = 0;  }
void P00070() { npc = 000060; inh = 0;  }
void P00071() { npc = 000100; inh = 0;  }
void P00072() { npc = 000120; inh = 0;  }
void P00073() { npc = 000140; inh = 0;  }
void P00074() { npc = 000160; inh = 0;  }
void P00075() { npc = 000000; inh = 0;  }
void P00076() { npc = 000020; inh = 0;  }
void P00102() { npc = 000040; inh = 0;  }
void P00103() { npc = 000060; inh = 0;  }
void P00104() { npc = 000100; inh = 0;  }
void P00105() { npc = 000120; inh = 0;  }
void P00106() { npc = 000140; inh = 0;  }
void P00107() { npc = 000160; inh = 0;  }
void P00110() { npc = (ib<<12)+core[0]; inh = 0;  }
void P00111() { npc = (ib<<12)+core[16]; inh = 0;  }
void P00112() { npc = (ib<<12)+core[32]; inh = 0;  }
void D00113() { emul8();  }
void D00114() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void D00115() { emul8();  }
void D00116() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void D00117() { emul8();  }
void P00120() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void D00121() { emul8();  }
void D00122() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void D00123() { emul8();  }
void D00124() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void D00125() { emul8();  }
void D00126() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void D00127() { emul8();  }
void D00130() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; hlt = 1;  }
void D00131() { emul8();  }
void D00132() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void D00133() { emul8();  }
void D00134() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void D00135() { emul8();  }
void D00136() { lac &= (010000|core[000000]);  }
void P00137() { if (++core[000010] == 010000) core[000010] = 0000;if (++core[(df<<12)+core[000010]] == 010000) { core[(df<<12)+core[000010]] = 0; npc++; }; code[(df<<12)+core[000010]] = &emul8;  }
void P00140() { if (++core[(df<<12)+core[32]] == 010000) { core[(df<<12)+core[32]] = 0; npc++; }; code[(df<<12)+core[32]] = &emul8;  }
void P00141() { if (++core[(df<<12)+core[56]] == 010000) { core[(df<<12)+core[56]] = 0; npc++; }; code[(df<<12)+core[56]] = &emul8;  }
void P00142() { if (++core[(df<<12)+core[80]] == 010000) { core[(df<<12)+core[80]] = 0; npc++; }; code[(df<<12)+core[80]] = &emul8;  }
void P00143() { if (++core[(df<<12)+core[0]] == 010000) { core[(df<<12)+core[0]] = 0; npc++; }; code[(df<<12)+core[0]] = &emul8;  }
void P00144() { if (++core[(df<<12)+core[24]] == 010000) { core[(df<<12)+core[24]] = 0; npc++; }; code[(df<<12)+core[24]] = &emul8;  }
void P00145() { if (++core[(df<<12)+core[48]] == 010000) { core[(df<<12)+core[48]] = 0; npc++; }; code[(df<<12)+core[48]] = &emul8;  }
void P00146() { if (++core[(df<<12)+core[72]] == 010000) { core[(df<<12)+core[72]] = 0; npc++; }; code[(df<<12)+core[72]] = &emul8;  }
void P00147() { if (++core[(df<<12)+core[96]] == 010000) { core[(df<<12)+core[96]] = 0; npc++; }; code[(df<<12)+core[96]] = &emul8;  }
void P00150() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void P00151() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void P00152() { core[000060] = lac & 07777; lac &= 010000; code[000060] = &emul8;  }
void P00153() { core[000110] = lac & 07777; lac &= 010000; code[000110] = &emul8;  }
void P00154() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void P00155() { core[000000] = lac & 07777; lac &= 010000; code[000000] = &emul8;  }
void P00156() { core[000030] = lac & 07777; lac &= 010000; code[000030] = &emul8;  }
void P00157() { core[000060] = lac & 07777; lac &= 010000; code[000060] = &emul8;  }
void P00160() { core[000110] = lac & 07777; lac &= 010000; code[000110] = &emul8;  }
void P00161() { core[000140] = lac & 07777; lac &= 010000; code[000140] = &emul8;  }
void P00162() { core[(df<<12)+core[0]] = lac & 07777; lac &= 010000; code[(df<<12)+core[0]] = &emul8;  }
void P00163() { core[(df<<12)+core[24]] = lac & 07777; lac &= 010000; code[(df<<12)+core[24]] = &emul8;  }
void P00164() { core[(df<<12)+core[48]] = lac & 07777; lac &= 010000; code[(df<<12)+core[48]] = &emul8;  }
void P00165() { core[(df<<12)+core[72]] = lac & 07777; lac &= 010000; code[(df<<12)+core[72]] = &emul8;  }
void P00166() { core[(df<<12)+core[96]] = lac & 07777; lac &= 010000; code[(df<<12)+core[96]] = &emul8;  }
void S00170() { lac &= (010000|core[000000]);  }
void I00171() { lac += core[000175];  }
void P00172() { if (++core[000010] == 010000) core[000010] = 0000;core[(df<<12)+core[000010]] = lac & 07777; lac &= 010000; code[(df<<12)+core[000010]] = &emul8;  }
void I00173() { lac += core[000010];  }
void I00174() { npc = (ib<<12)+core[120]; inh = 0;  }
void D00175() { hlt = 1;  }
void P00200() { npc = (ib<<12)+core[129]; inh = 0;  }
void P00201() { lac &= (010000|core[(df<<12)+core[128]]);  }
void L00600() { lac &= 010000;  }
void P00601() { lac += core[(df<<12)+core[43]];  }
void I00602() { core[000743] = lac & 07777; lac &= 010000; code[000743] = &emul8;  }
void I00603() { lac += core[(df<<12)+core[42]];  }
void I00604() { core[000744] = lac & 07777; lac &= 010000; code[000744] = &emul8;  }
void I00605() { lac += core[(df<<12)+core[478]];  }
void I00606() { core[000745] = lac & 07777; lac &= 010000; code[000745] = &emul8;  }
void I00607() { lac += core[(df<<12)+core[41]];  }
void I00610() { core[000746] = lac & 07777; lac &= 010000; code[000746] = &emul8;  }
void I00611() { lac += core[(df<<12)+core[479]];  }
void I00612() { core[000747] = lac & 07777; lac &= 010000; code[000747] = &emul8;  }
void I00613() { lac += core[(df<<12)+core[40]];  }
void I00614() { core[000750] = lac & 07777; lac &= 010000; code[000750] = &emul8;  }
void I00615() { lac += core[(df<<12)+core[480]];  }
void I00616() { core[000751] = lac & 07777; lac &= 010000; code[000751] = &emul8;  }
void I00617() { lac += core[(df<<12)+core[39]];  }
void I00620() { core[000752] = lac & 07777; lac &= 010000; code[000752] = &emul8;  }
void I00621() { lac += core[(df<<12)+core[481]];  }
void I00622() { core[000753] = lac & 07777; lac &= 010000; code[000753] = &emul8;  }
void I00623() { lac += core[(df<<12)+core[38]];  }
void I00624() { core[000754] = lac & 07777; lac &= 010000; code[000754] = &emul8;  }
void I00625() { lac += core[(df<<12)+core[482]];  }
void I00626() { core[000755] = lac & 07777; lac &= 010000; code[000755] = &emul8;  }
void I00627() { lac += core[(df<<12)+core[45]];  }
void I00630() { core[000756] = lac & 07777; lac &= 010000; code[000756] = &emul8;  }
void I00631() { lac &= 010000; lac &= 07777;  }
void I00632() { lac += core[000664];  }
void I00633() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L00634() { core[000170] = 00635; npc = 000170+1; code[000170] = &emul8; inh = 0;  }
void I00635() { lac += core[000665];  }
void I00636() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00637() { npc = 000634; inh = 0;  }
void I00640() { lac += core[000666];  }
void I00641() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L00642() { core[000170] = 00643; npc = 000170+1; code[000170] = &emul8; inh = 0;  }
void I00643() { lac += core[000667];  }
void I00644() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00645() { npc = 000642; inh = 0;  }
void I00646() { lac += core[000670];  }
void I00647() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L00650() { core[000170] = 00651; npc = 000170+1; code[000170] = &emul8; inh = 0;  }
void I00651() { lac += core[000671];  }
void I00652() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00653() { npc = 000650; inh = 0;  }
void I00654() { lac += core[000672];  }
void I00655() { core[000010] = lac & 07777; lac &= 010000; code[000010] = &emul8;  }
void L00656() { core[000170] = 00657; npc = 000170+1; code[000170] = &emul8; inh = 0;  }
void I00657() { lac += core[000673];  }
void I00660() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I00661() { npc = 000656; inh = 0;  }
void I00662() { npc = 000700; inh = 0;  }
void P00663() { core[000600] = 00664; npc = 000600+1; code[000600] = &emul8; inh = 0;  }
void D00664() { lac &= (010000|core[000175]);  }
void D00665() { lac &= 010000; lac++;  }
void D00666() { lac &= (010000|core[(df<<12)+core[494]]);  }
void D00667() { emul8();  }
void D00670() { core[(df<<12)+core[122]] = lac & 07777; lac &= 010000; code[(df<<12)+core[122]] = &emul8;  }
void D00671() { core[(df<<12)+core[385]] = lac & 07777; lac &= 010000; code[(df<<12)+core[385]] = &emul8;  }
void D00672() { npc = (ib<<12)+core[41]; inh = 0;  }
void D00673() { lac &= (010000|core[000600]);  }
void L00700() { lac += core[000703];  }
void I00701() { core[000600] = lac & 07777; lac &= 010000; code[000600] = &emul8;  }
void I00702() { npc = 000703; inh = 0;  }
void L00703() { npc = (ib<<12)+core[435]; inh = 0;  }
void I00704() { lac &= 010000;  }
void I00705() { lac += core[000743];  }
void I00706() { core[(df<<12)+core[43]] = lac & 07777; lac &= 010000; code[(df<<12)+core[43]] = &emul8;  }
void I00707() { lac += core[000744];  }
void I00710() { core[(df<<12)+core[42]] = lac & 07777; lac &= 010000; code[(df<<12)+core[42]] = &emul8;  }
void I00711() { lac += core[000745];  }
void I00712() { core[(df<<12)+core[478]] = lac & 07777; lac &= 010000; code[(df<<12)+core[478]] = &emul8;  }
void I00713() { lac += core[000746];  }
void I00714() { core[(df<<12)+core[41]] = lac & 07777; lac &= 010000; code[(df<<12)+core[41]] = &emul8;  }
void I00715() { lac += core[000747];  }
void I00716() { core[(df<<12)+core[479]] = lac & 07777; lac &= 010000; code[(df<<12)+core[479]] = &emul8;  }
void I00717() { lac += core[000750];  }
void I00720() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I00721() { lac += core[000751];  }
void I00722() { core[(df<<12)+core[480]] = lac & 07777; lac &= 010000; code[(df<<12)+core[480]] = &emul8;  }
void I00723() { lac += core[000752];  }
void I00724() { core[(df<<12)+core[39]] = lac & 07777; lac &= 010000; code[(df<<12)+core[39]] = &emul8;  }
void I00725() { lac += core[000753];  }
void I00726() { core[(df<<12)+core[481]] = lac & 07777; lac &= 010000; code[(df<<12)+core[481]] = &emul8;  }
void I00727() { lac += core[000754];  }
void I00730() { core[(df<<12)+core[38]] = lac & 07777; lac &= 010000; code[(df<<12)+core[38]] = &emul8;  }
void I00731() { lac += core[000755];  }
void I00732() { core[(df<<12)+core[482]] = lac & 07777; lac &= 010000; code[(df<<12)+core[482]] = &emul8;  }
void I00733() { lac += core[000756];  }
void I00734() { core[(df<<12)+core[45]] = lac & 07777; lac &= 010000; code[(df<<12)+core[45]] = &emul8;  }
void I00735() { hlt = 1;  }
void P00736() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void P00737() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void P00740() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void P00741() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void P00742() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void D00743() { lac &= (010000|core[000000]);  }
void D00744() { lac &= (010000|core[000000]);  }
void D00745() { lac &= (010000|core[000000]);  }
void D00746() { lac &= (010000|core[000000]);  }
void D00747() { lac += core[(df<<12)+core[482]];  }
void D00750() { lac &= (010000|core[000000]);  }
void D00751() { lac &= (010000|core[000000]);  }
void D00752() { lac &= (010000|core[000000]);  }
void D00753() { lac &= (010000|core[000000]);  }
void D00754() { lac &= (010000|core[000000]);  }
void D00755() { lac &= (010000|core[000000]);  }
void P00756() { lac &= (010000|core[000000]);  }
void L02002() { core[002003] = 02003; npc = 002003+1; code[002003] = &emul8; inh = 0;  }
void L02003() { npc = 002003; inh = 0;  }
void I02004() { lac += core[000136];  }
void I02005() { lac += core[002022];  }
void I02006() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02007() { hlt = 1;  }
void I02010() { lac += core[002024];  }
void I02011() { lac ^= 07777; lac++;  }
void I02012() { lac += core[002003];  }
void I02013() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02014() { hlt = 1;  }
void I02015() { core[002003] = lac & 07777; lac &= 010000; code[002003] = &emul8;  }
void I02016() { lac += core[000136];  }
void I02017() { lac++;  }
void I02020() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02021() { skp = 0; skp = !skp; npc += skp;  }
void D02022() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; hlt = 1;  }
void I02023() { skp = 0; skp = !skp; npc += skp;  }
void D02024() { if (++core[000003] == 010000) { core[000003] = 0; npc++; }; code[000003] = &emul8;  }
void I02025() { core[002027] = 02026; npc = 002027+1; code[002027] = &emul8; inh = 0;  }
void I02026() { hlt = 1;  }
void L02027() { npc = 002027; inh = 0;  }
void I02030() { lac += core[000136];  }
void I02031() { lac += core[002046];  }
void I02032() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02033() { hlt = 1;  }
void I02034() { lac += core[002050];  }
void I02035() { lac ^= 07777; lac++;  }
void I02036() { lac += core[002027];  }
void I02037() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02040() { hlt = 1;  }
void I02041() { core[002027] = lac & 07777; lac &= 010000; code[002027] = &emul8;  }
void I02042() { lac += core[000136];  }
void I02043() { lac++;  }
void I02044() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02045() { skp = 0; skp = !skp; npc += skp;  }
void D02046() { emul8();  }
void I02047() { skp = 0; skp = !skp; npc += skp;  }
void D02050() { if (++core[000026] == 010000) { core[000026] = 0; npc++; }; code[000026] = &emul8;  }
void I02051() { core[002054] = 02052; npc = 002054+1; code[002054] = &emul8; inh = 0;  }
void I02052() { hlt = 1;  }
void I02053() { hlt = 1;  }
void L02054() { npc = 002054; inh = 0;  }
void I02055() { lac += core[000136];  }
void I02056() { lac += core[002075];  }
void I02057() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02060() { hlt = 1;  }
void I02061() { lac += core[002073];  }
void I02062() { lac ^= 07777; lac++;  }
void I02063() { lac += core[002054];  }
void I02064() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02065() { hlt = 1;  }
void I02066() { core[002054] = lac & 07777; lac &= 010000; code[002054] = &emul8;  }
void I02067() { lac += core[000136];  }
void I02070() { lac++;  }
void I02071() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02072() { skp = 0; skp = !skp; npc += skp;  }
void D02073() { if (++core[000052] == 010000) { core[000052] = 0; npc++; }; code[000052] = &emul8;  }
void I02074() { skp = 0; skp = !skp; npc += skp;  }
void D02075() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void I02076() { core[002102] = 02077; npc = 002102+1; code[002102] = &emul8; inh = 0;  }
void I02077() { hlt = 1;  }
void I02100() { hlt = 1;  }
void I02101() { hlt = 1;  }
void L02102() { npc = 002102; inh = 0;  }
void I02103() { lac += core[000136];  }
void I02104() { lac += core[002123];  }
void I02105() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02106() { hlt = 1;  }
void I02107() { lac += core[002121];  }
void I02110() { lac ^= 07777; lac++;  }
void I02111() { lac += core[002102];  }
void I02112() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02113() { hlt = 1;  }
void I02114() { core[002102] = lac & 07777; lac &= 010000; code[002102] = &emul8;  }
void I02115() { lac += core[000136];  }
void I02116() { lac++;  }
void I02117() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02120() { skp = 0; skp = !skp; npc += skp;  }
void D02121() { if (++core[000077] == 010000) { core[000077] = 0; npc++; }; code[000077] = &emul8;  }
void I02122() { skp = 0; skp = !skp; npc += skp;  }
void D02123() { emul8();  }
void I02124() { core[002130] = 02125; npc = 002130+1; code[002130] = &emul8; inh = 0;  }
void I02125() { hlt = 1;  }
void I02126() { hlt = 1;  }
void I02127() { hlt = 1;  }
void L02130() { npc = 002130; inh = 0;  }
void I02131() { lac += core[000136];  }
void I02132() { lac += core[002151];  }
void I02133() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02134() { hlt = 1;  }
void I02135() { lac += core[002147];  }
void I02136() { lac ^= 07777; lac++;  }
void I02137() { lac += core[002130];  }
void I02140() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02141() { hlt = 1;  }
void I02142() { core[002130] = lac & 07777; lac &= 010000; code[002130] = &emul8;  }
void I02143() { lac += core[000136];  }
void I02144() { lac++;  }
void I02145() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02146() { skp = 0; skp = !skp; npc += skp;  }
void D02147() { if (++core[000125] == 010000) { core[000125] = 0; npc++; }; code[000125] = &emul8;  }
void I02150() { skp = 0; skp = !skp; npc += skp;  }
void D02151() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void I02152() { core[002156] = 02153; npc = 002156+1; code[002156] = &emul8; inh = 0;  }
void I02153() { hlt = 1;  }
void I02154() { hlt = 1;  }
void I02155() { hlt = 1;  }
void L02156() { npc = 002156; inh = 0;  }
void I02157() { lac += core[000136];  }
void I02160() { lac += core[002177];  }
void I02161() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02162() { hlt = 1;  }
void I02163() { lac += core[002175];  }
void I02164() { lac ^= 07777; lac++;  }
void I02165() { lac += core[002156];  }
void I02166() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02167() { hlt = 1;  }
void I02170() { core[002156] = lac & 07777; lac &= 010000; code[002156] = &emul8;  }
void I02171() { lac += core[000136];  }
void I02172() { lac++;  }
void I02173() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02174() { skp = 0; skp = !skp; npc += skp;  }
void D02175() { if (++core[000153] == 010000) { core[000153] = 0; npc++; }; code[000153] = &emul8;  }
void I02176() { skp = 0; skp = !skp; npc += skp;  }
void D02177() { emul8();  }
void I02200() {  }
void I02201() { core[002202] = 02202; npc = 002202+1; code[002202] = &emul8; inh = 0;  }
void L02202() { npc = 002202; inh = 0;  }
void I02203() { lac += core[000136];  }
void I02204() { lac += core[002221];  }
void I02205() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02206() { hlt = 1;  }
void I02207() { lac += core[002202];  }
void I02210() { lac ^= 07777; lac++;  }
void I02211() { lac += core[002223];  }
void I02212() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02213() { hlt = 1;  }
void I02214() { core[002202] = lac & 07777; lac &= 010000; code[002202] = &emul8;  }
void I02215() { lac += core[000136];  }
void I02216() { lac++;  }
void I02217() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02220() { skp = 0; skp = !skp; npc += skp;  }
void D02221() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void I02222() { skp = 0; skp = !skp; npc += skp;  }
void D02223() { if (++core[002202] == 010000) { core[002202] = 0; npc++; }; code[002202] = &emul8;  }
void I02224() { core[002226] = 02225; npc = 002226+1; code[002226] = &emul8; inh = 0;  }
void D02225() { hlt = 1;  }
void L02226() { npc = 002226; inh = 0;  }
void I02227() { lac += core[000136];  }
void I02230() { lac += core[002245];  }
void I02231() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02232() { hlt = 1;  }
void I02233() { lac += core[002247];  }
void I02234() { lac ^= 07777; lac++;  }
void I02235() { lac += core[002226];  }
void I02236() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02237() { hlt = 1;  }
void I02240() { core[002226] = lac & 07777; lac &= 010000; code[002226] = &emul8;  }
void I02241() { lac += core[000136];  }
void I02242() { lac++;  }
void I02243() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02244() { skp = 0; skp = !skp; npc += skp;  }
void D02245() { emul8();  }
void I02246() { skp = 0; skp = !skp; npc += skp;  }
void D02247() { if (++core[002225] == 010000) { core[002225] = 0; npc++; }; code[002225] = &emul8;  }
void I02250() { core[002253] = 02251; npc = 002253+1; code[002253] = &emul8; inh = 0;  }
void D02251() { hlt = 1;  }
void I02252() { hlt = 1;  }
void L02253() { npc = 002253; inh = 0;  }
void I02254() { lac += core[000136];  }
void I02255() { lac += core[002274];  }
void I02256() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02257() { hlt = 1;  }
void I02260() { lac += core[002253];  }
void I02261() { lac ^= 07777; lac++;  }
void I02262() { lac += core[002272];  }
void I02263() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02264() { hlt = 1;  }
void I02265() { core[002253] = lac & 07777; lac &= 010000; code[002253] = &emul8;  }
void I02266() { lac += core[000136];  }
void I02267() { lac++;  }
void I02270() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02271() { skp = 0; skp = !skp; npc += skp;  }
void D02272() { if (++core[002251] == 010000) { core[002251] = 0; npc++; }; code[002251] = &emul8;  }
void I02273() { skp = 0; skp = !skp; npc += skp;  }
void D02274() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void I02275() { core[002301] = 02276; npc = 002301+1; code[002301] = &emul8; inh = 0;  }
void D02276() { hlt = 1;  }
void I02277() { hlt = 1;  }
void I02300() { hlt = 1;  }
void L02301() { npc = 002301; inh = 0;  }
void I02302() { lac += core[000136];  }
void I02303() { lac += core[002322];  }
void I02304() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02305() { hlt = 1;  }
void I02306() { lac += core[002301];  }
void I02307() { lac ^= 07777; lac++;  }
void I02310() { lac += core[002320];  }
void I02311() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02312() { hlt = 1;  }
void I02313() { core[002301] = lac & 07777; lac &= 010000; code[002301] = &emul8;  }
void I02314() { lac += core[000136];  }
void I02315() { lac++;  }
void I02316() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02317() { skp = 0; skp = !skp; npc += skp;  }
void D02320() { if (++core[002276] == 010000) { core[002276] = 0; npc++; }; code[002276] = &emul8;  }
void I02321() { skp = 0; skp = !skp; npc += skp;  }
void D02322() { emul8();  }
void I02323() { core[002330] = 02324; npc = 002330+1; code[002330] = &emul8; inh = 0;  }
void D02324() { hlt = 1;  }
void I02325() { hlt = 1;  }
void I02326() { hlt = 1;  }
void I02327() { hlt = 1;  }
void L02330() { npc = 002330; inh = 0;  }
void I02331() { lac += core[000136];  }
void I02332() { lac += core[002351];  }
void I02333() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02334() { hlt = 1;  }
void I02335() { lac += core[002330];  }
void I02336() { lac ^= 07777; lac++;  }
void I02337() { lac += core[002347];  }
void I02340() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02341() { hlt = 1;  }
void I02342() { core[002330] = lac & 07777; lac &= 010000; code[002330] = &emul8;  }
void I02343() { lac += core[000136];  }
void I02344() { lac++;  }
void I02345() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02346() { skp = 0; skp = !skp; npc += skp;  }
void D02347() { if (++core[002324] == 010000) { core[002324] = 0; npc++; }; code[002324] = &emul8;  }
void I02350() { skp = 0; skp = !skp; npc += skp;  }
void D02351() { skp = 0; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void I02352() { core[002356] = 02353; npc = 002356+1; code[002356] = &emul8; inh = 0;  }
void D02353() { hlt = 1;  }
void I02354() { hlt = 1;  }
void I02355() { hlt = 1;  }
void L02356() { npc = 002356; inh = 0;  }
void I02357() { lac += core[000136];  }
void I02360() { lac += core[002377];  }
void I02361() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02362() { hlt = 1;  }
void I02363() { lac += core[002356];  }
void I02364() { lac ^= 07777; lac++;  }
void I02365() { lac += core[002375];  }
void I02366() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02367() { hlt = 1;  }
void I02370() { core[002356] = lac & 07777; lac &= 010000; code[002356] = &emul8;  }
void I02371() { lac += core[000136];  }
void I02372() { lac++;  }
void I02373() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02374() { skp = 0; skp = !skp; npc += skp;  }
void D02375() { if (++core[002353] == 010000) { core[002353] = 0; npc++; }; code[002353] = &emul8;  }
void I02376() { skp = 0; skp = !skp; npc += skp;  }
void D02377() { emul8();  }
void I02400() { lac += core[002405];  }
void I02401() { core[(df<<12)+core[45]] = lac & 07777; lac &= 010000; code[(df<<12)+core[45]] = &emul8;  }
void I02402() { lac += core[002406];  }
void I02403() { core[(df<<12)+core[19]] = lac & 07777; lac &= 010000; code[(df<<12)+core[19]] = &emul8;  }
void I02404() { npc = (ib<<12)+core[19]; inh = 0;  }
void D02405() { npc = (ib<<12)+core[95]; inh = 0;  }
void D02406() { core[(ib<<12)+core[44]] = 02407; npc = (ib<<12)+core[44]+1; code[(ib<<12)+core[44]] = &emul8; inh = 0;  }
void L02410() { lac += core[000136];  }
void I02411() { lac += core[002433];  }
void I02412() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02413() { hlt = 1;  }
void I02414() { lac += core[(df<<12)+core[44]];  }
void I02415() { lac += core[000054];  }
void I02416() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02417() { hlt = 1;  }
void I02420() { core[(df<<12)+core[44]] = lac & 07777; lac &= 010000; code[(df<<12)+core[44]] = &emul8;  }
void I02421() { lac += core[000136];  }
void I02422() { lac++;  }
void I02423() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02424() { lac += core[002431];  }
void I02425() { core[(df<<12)+core[44]] = lac & 07777; lac &= 010000; code[(df<<12)+core[44]] = &emul8;  }
void I02426() { lac += core[002432];  }
void I02427() { core[(df<<12)+core[20]] = lac & 07777; lac &= 010000; code[(df<<12)+core[20]] = &emul8;  }
void I02430() { npc = (ib<<12)+core[20]; inh = 0;  }
void D02431() { npc = (ib<<12)+core[96]; inh = 0;  }
void D02432() { core[(ib<<12)+core[43]] = 02433; npc = (ib<<12)+core[43]+1; code[(ib<<12)+core[43]] = &emul8; inh = 0;  }
void D02433() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void L02440() { lac += core[000136];  }
void I02441() { lac += core[002463];  }
void I02442() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02443() { hlt = 1;  }
void I02444() { lac += core[(df<<12)+core[43]];  }
void I02445() { lac += core[000053];  }
void I02446() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02447() { hlt = 1;  }
void I02450() { core[(df<<12)+core[43]] = lac & 07777; lac &= 010000; code[(df<<12)+core[43]] = &emul8;  }
void I02451() { lac += core[000136];  }
void I02452() { lac++;  }
void I02453() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02454() { lac += core[002461];  }
void I02455() { core[(df<<12)+core[1332]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1332]] = &emul8;  }
void I02456() { lac += core[002462];  }
void I02457() { core[(df<<12)+core[21]] = lac & 07777; lac &= 010000; code[(df<<12)+core[21]] = &emul8;  }
void I02460() { npc = (ib<<12)+core[21]; inh = 0;  }
void D02461() { npc = (ib<<12)+core[97]; inh = 0;  }
void D02462() { core[(ib<<12)+core[42]] = 02463; npc = (ib<<12)+core[42]+1; code[(ib<<12)+core[42]] = &emul8; inh = 0;  }
void D02463() { emul8();  }
void P02464() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void L02470() { lac += core[000136];  }
void I02471() { lac += core[002513];  }
void I02472() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02473() { hlt = 1;  }
void I02474() { lac += core[(df<<12)+core[42]];  }
void I02475() { lac += core[000052];  }
void I02476() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02477() { hlt = 1;  }
void I02500() { core[(df<<12)+core[42]] = lac & 07777; lac &= 010000; code[(df<<12)+core[42]] = &emul8;  }
void I02501() { lac += core[000136];  }
void I02502() { lac++;  }
void I02503() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02504() { lac += core[002511];  }
void I02505() { core[(df<<12)+core[1356]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1356]] = &emul8;  }
void I02506() { lac += core[002512];  }
void I02507() { core[(df<<12)+core[22]] = lac & 07777; lac &= 010000; code[(df<<12)+core[22]] = &emul8;  }
void I02510() { npc = (ib<<12)+core[22]; inh = 0;  }
void D02511() { npc = (ib<<12)+core[98]; inh = 0;  }
void D02512() { core[(ib<<12)+core[41]] = 02513; npc = (ib<<12)+core[41]+1; code[(ib<<12)+core[41]] = &emul8; inh = 0;  }
void D02513() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void P02514() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void L02520() { lac += core[000136];  }
void I02521() { lac += core[002543];  }
void I02522() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02523() { hlt = 1;  }
void I02524() { lac += core[(df<<12)+core[41]];  }
void I02525() { lac += core[000051];  }
void I02526() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02527() { hlt = 1;  }
void I02530() { core[(df<<12)+core[41]] = lac & 07777; lac &= 010000; code[(df<<12)+core[41]] = &emul8;  }
void I02531() { lac += core[000136];  }
void I02532() { lac++;  }
void I02533() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02534() { lac += core[002541];  }
void I02535() { core[(df<<12)+core[1380]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1380]] = &emul8;  }
void I02536() { lac += core[002542];  }
void I02537() { core[(df<<12)+core[23]] = lac & 07777; lac &= 010000; code[(df<<12)+core[23]] = &emul8;  }
void I02540() { npc = (ib<<12)+core[23]; inh = 0;  }
void D02541() { npc = (ib<<12)+core[99]; inh = 0;  }
void D02542() { core[(ib<<12)+core[40]] = 02543; npc = (ib<<12)+core[40]+1; code[(ib<<12)+core[40]] = &emul8; inh = 0;  }
void D02543() { emul8();  }
void P02544() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void L02600() { lac += core[000136];  }
void I02601() { lac += core[002623];  }
void I02602() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02603() { hlt = 1;  }
void I02604() { lac += core[(df<<12)+core[40]];  }
void I02605() { lac += core[000050];  }
void I02606() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02607() { hlt = 1;  }
void I02610() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I02611() { lac += core[000136];  }
void I02612() { lac++;  }
void I02613() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02614() { lac += core[002621];  }
void I02615() { core[(df<<12)+core[1428]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1428]] = &emul8;  }
void I02616() { lac += core[002622];  }
void I02617() { core[(df<<12)+core[24]] = lac & 07777; lac &= 010000; code[(df<<12)+core[24]] = &emul8;  }
void I02620() { npc = (ib<<12)+core[24]; inh = 0;  }
void D02621() { npc = (ib<<12)+core[100]; inh = 0;  }
void D02622() { core[(ib<<12)+core[39]] = 02623; npc = (ib<<12)+core[39]+1; code[(ib<<12)+core[39]] = &emul8; inh = 0;  }
void D02623() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000; hlt = 1;  }
void P02624() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void L02630() { lac += core[000136];  }
void I02631() { lac += core[002653];  }
void I02632() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02633() { hlt = 1;  }
void I02634() { lac += core[(df<<12)+core[39]];  }
void I02635() { lac += core[000047];  }
void I02636() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02637() { hlt = 1;  }
void I02640() { core[(df<<12)+core[39]] = lac & 07777; lac &= 010000; code[(df<<12)+core[39]] = &emul8;  }
void I02641() { lac += core[000136];  }
void I02642() { lac++;  }
void I02643() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02644() { lac += core[002651];  }
void I02645() { core[(df<<12)+core[1452]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1452]] = &emul8;  }
void I02646() { lac += core[002652];  }
void I02647() { core[(df<<12)+core[25]] = lac & 07777; lac &= 010000; code[(df<<12)+core[25]] = &emul8;  }
void I02650() { npc = (ib<<12)+core[25]; inh = 0;  }
void D02651() { npc = (ib<<12)+core[101]; inh = 0;  }
void D02652() { core[(ib<<12)+core[38]] = 02653; npc = (ib<<12)+core[38]+1; code[(ib<<12)+core[38]] = &emul8; inh = 0;  }
void D02653() { emul8();  }
void P02654() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void L02660() { lac += core[000136];  }
void I02661() { lac += core[002703];  }
void I02662() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02663() { hlt = 1;  }
void I02664() { lac += core[(df<<12)+core[38]];  }
void I02665() { lac += core[000046];  }
void I02666() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02667() { hlt = 1;  }
void I02670() { core[(df<<12)+core[38]] = lac & 07777; lac &= 010000; code[(df<<12)+core[38]] = &emul8;  }
void I02671() { lac += core[000136];  }
void I02672() { lac++;  }
void I02673() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02674() { lac += core[002701];  }
void I02675() { core[(df<<12)+core[1476]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1476]] = &emul8;  }
void I02676() { lac += core[002702];  }
void I02677() { core[(df<<12)+core[26]] = lac & 07777; lac &= 010000; code[(df<<12)+core[26]] = &emul8;  }
void I02700() { npc = (ib<<12)+core[26]; inh = 0;  }
void D02701() { npc = (ib<<12)+core[102]; inh = 0;  }
void D02702() { core[(ib<<12)+core[37]] = 02703; npc = (ib<<12)+core[37]+1; code[(ib<<12)+core[37]] = &emul8; inh = 0;  }
void D02703() { skp = 0; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void P02704() { lac &= 010000;  }
void L02710() { lac += core[000136];  }
void I02711() { lac += core[002733];  }
void I02712() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02713() { hlt = 1;  }
void I02714() { lac += core[(df<<12)+core[37]];  }
void I02715() { lac += core[000045];  }
void I02716() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02717() { hlt = 1;  }
void I02720() { core[(df<<12)+core[37]] = lac & 07777; lac &= 010000; code[(df<<12)+core[37]] = &emul8;  }
void I02721() { lac += core[000136];  }
void I02722() { lac++;  }
void I02723() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02724() { lac += core[002731];  }
void I02725() { core[(df<<12)+core[1500]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1500]] = &emul8;  }
void I02726() { lac += core[002732];  }
void I02727() { core[(df<<12)+core[27]] = lac & 07777; lac &= 010000; code[(df<<12)+core[27]] = &emul8;  }
void I02730() { npc = (ib<<12)+core[27]; inh = 0;  }
void D02731() { npc = (ib<<12)+core[103]; inh = 0;  }
void D02732() { core[(ib<<12)+core[36]] = 02733; npc = (ib<<12)+core[36]+1; code[(ib<<12)+core[36]] = &emul8; inh = 0;  }
void D02733() { emul8();  }
void P02734() {  }
void L02740() { lac += core[000136];  }
void I02741() { lac += core[002763];  }
void I02742() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02743() { hlt = 1;  }
void I02744() { lac += core[(df<<12)+core[36]];  }
void I02745() { lac += core[000044];  }
void I02746() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I02747() { hlt = 1;  }
void I02750() { core[(df<<12)+core[36]] = lac & 07777; lac &= 010000; code[(df<<12)+core[36]] = &emul8;  }
void I02751() { lac += core[000136];  }
void I02752() { lac++;  }
void I02753() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I02754() { lac += core[002761];  }
void I02755() { core[(df<<12)+core[1524]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1524]] = &emul8;  }
void I02756() { lac += core[002762];  }
void I02757() { core[(df<<12)+core[28]] = lac & 07777; lac &= 010000; code[(df<<12)+core[28]] = &emul8;  }
void I02760() { npc = (ib<<12)+core[28]; inh = 0;  }
void D02761() { npc = (ib<<12)+core[104]; inh = 0;  }
void D02762() { core[(ib<<12)+core[35]] = 02763; npc = (ib<<12)+core[35]+1; code[(ib<<12)+core[35]] = &emul8; inh = 0;  }
void D02763() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P02764() {  }
void L03000() { lac += core[000136];  }
void I03001() { lac += core[003023];  }
void I03002() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03003() { hlt = 1;  }
void I03004() { lac += core[(df<<12)+core[35]];  }
void I03005() { lac += core[000043];  }
void I03006() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03007() { hlt = 1;  }
void I03010() { core[(df<<12)+core[35]] = lac & 07777; lac &= 010000; code[(df<<12)+core[35]] = &emul8;  }
void I03011() { lac += core[000136];  }
void I03012() { lac++;  }
void I03013() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03014() { lac += core[003021];  }
void I03015() { core[(df<<12)+core[1556]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1556]] = &emul8;  }
void I03016() { lac += core[003022];  }
void I03017() { core[(df<<12)+core[29]] = lac & 07777; lac &= 010000; code[(df<<12)+core[29]] = &emul8;  }
void I03020() { npc = (ib<<12)+core[29]; inh = 0;  }
void D03021() { npc = (ib<<12)+core[105]; inh = 0;  }
void D03022() { core[(ib<<12)+core[34]] = 03023; npc = (ib<<12)+core[34]+1; code[(ib<<12)+core[34]] = &emul8; inh = 0;  }
void D03023() { emul8();  }
void P03024() { emul8();  }
void L03030() { lac += core[000136];  }
void I03031() { lac += core[003053];  }
void I03032() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03033() { hlt = 1;  }
void I03034() { lac += core[(df<<12)+core[34]];  }
void I03035() { lac += core[000042];  }
void I03036() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03037() { hlt = 1;  }
void I03040() { core[(df<<12)+core[34]] = lac & 07777; lac &= 010000; code[(df<<12)+core[34]] = &emul8;  }
void I03041() { lac += core[000136];  }
void I03042() { lac++;  }
void I03043() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03044() { lac += core[003051];  }
void I03045() { core[(df<<12)+core[1580]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1580]] = &emul8;  }
void I03046() { lac += core[003052];  }
void I03047() { core[(df<<12)+core[31]] = lac & 07777; lac &= 010000; code[(df<<12)+core[31]] = &emul8;  }
void I03050() { npc = (ib<<12)+core[31]; inh = 0;  }
void D03051() { npc = (ib<<12)+core[106]; inh = 0;  }
void D03052() { core[(ib<<12)+core[30]] = 03053; npc = (ib<<12)+core[30]+1; code[(ib<<12)+core[30]] = &emul8; inh = 0;  }
void D03053() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void P03054() { core[000001] = 03055; npc = 000001+1; code[000001] = &emul8; inh = 0;  }
void L03060() { lac += core[000136];  }
void I03061() { lac += core[003103];  }
void I03062() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03063() { hlt = 1;  }
void I03064() { lac += core[(df<<12)+core[30]];  }
void I03065() { lac += core[000036];  }
void I03066() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03067() { hlt = 1;  }
void I03070() { core[(df<<12)+core[30]] = lac & 07777; lac &= 010000; code[(df<<12)+core[30]] = &emul8;  }
void I03071() { lac += core[000136];  }
void I03072() { lac++;  }
void I03073() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03074() { lac += core[003101];  }
void I03075() { core[(df<<12)+core[1604]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1604]] = &emul8;  }
void I03076() { lac += core[003102];  }
void I03077() { core[(df<<12)+core[34]] = lac & 07777; lac &= 010000; code[(df<<12)+core[34]] = &emul8;  }
void I03100() { npc = (ib<<12)+core[34]; inh = 0;  }
void D03101() { npc = (ib<<12)+core[107]; inh = 0;  }
void D03102() { core[(ib<<12)+core[29]] = 03103; npc = (ib<<12)+core[29]+1; code[(ib<<12)+core[29]] = &emul8; inh = 0;  }
void D03103() { emul8();  }
void P03104() { if (++core[000001] == 010000) { core[000001] = 0; npc++; }; code[000001] = &emul8;  }
void L03110() { lac += core[000136];  }
void I03111() { lac += core[003133];  }
void I03112() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03113() { hlt = 1;  }
void I03114() { lac += core[(df<<12)+core[29]];  }
void I03115() { lac += core[000035];  }
void I03116() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03117() { hlt = 1;  }
void I03120() { core[(df<<12)+core[29]] = lac & 07777; lac &= 010000; code[(df<<12)+core[29]] = &emul8;  }
void I03121() { lac += core[000136];  }
void I03122() { lac++;  }
void I03123() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03124() { lac += core[003131];  }
void I03125() { core[(df<<12)+core[1628]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1628]] = &emul8;  }
void I03126() { lac += core[003132];  }
void I03127() { core[(df<<12)+core[35]] = lac & 07777; lac &= 010000; code[(df<<12)+core[35]] = &emul8;  }
void I03130() { npc = (ib<<12)+core[35]; inh = 0;  }
void D03131() { npc = (ib<<12)+core[108]; inh = 0;  }
void D03132() { core[(ib<<12)+core[28]] = 03133; npc = (ib<<12)+core[28]+1; code[(ib<<12)+core[28]] = &emul8; inh = 0;  }
void D03133() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void P03134() { lac += core[000001];  }
void L03140() { lac += core[000136];  }
void I03141() { lac += core[003163];  }
void I03142() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03143() { hlt = 1;  }
void I03144() { lac += core[(df<<12)+core[28]];  }
void I03145() { lac += core[000034];  }
void I03146() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03147() { hlt = 1;  }
void I03150() { core[(df<<12)+core[28]] = lac & 07777; lac &= 010000; code[(df<<12)+core[28]] = &emul8;  }
void I03151() { lac += core[000136];  }
void I03152() { lac++;  }
void I03153() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03154() { lac += core[003161];  }
void I03155() { core[(df<<12)+core[1652]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1652]] = &emul8;  }
void I03156() { lac += core[003162];  }
void I03157() { core[(df<<12)+core[36]] = lac & 07777; lac &= 010000; code[(df<<12)+core[36]] = &emul8;  }
void I03160() { npc = (ib<<12)+core[36]; inh = 0;  }
void D03161() { npc = (ib<<12)+core[109]; inh = 0;  }
void D03162() { core[(ib<<12)+core[27]] = 03163; npc = (ib<<12)+core[27]+1; code[(ib<<12)+core[27]] = &emul8; inh = 0;  }
void D03163() { emul8();  }
void P03164() { lac &= (010000|core[(df<<12)+core[1]]);  }
void L03200() { lac += core[000136];  }
void D03201() { lac += core[003223];  }
void I03202() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03203() { hlt = 1;  }
void I03204() { lac += core[(df<<12)+core[27]];  }
void I03205() { lac += core[000033];  }
void I03206() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03207() { hlt = 1;  }
void I03210() { core[(df<<12)+core[27]] = lac & 07777; lac &= 010000; code[(df<<12)+core[27]] = &emul8;  }
void I03211() { lac += core[000136];  }
void I03212() { lac++;  }
void I03213() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03214() { lac += core[003221];  }
void I03215() { core[(df<<12)+core[1684]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1684]] = &emul8;  }
void I03216() { lac += core[003222];  }
void I03217() { core[(df<<12)+core[37]] = lac & 07777; lac &= 010000; code[(df<<12)+core[37]] = &emul8;  }
void I03220() { npc = (ib<<12)+core[37]; inh = 0;  }
void D03221() { npc = (ib<<12)+core[110]; inh = 0;  }
void D03222() { core[(ib<<12)+core[26]] = 03223; npc = (ib<<12)+core[26]+1; code[(ib<<12)+core[26]] = &emul8; inh = 0;  }
void D03223() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void P03224() { lac &= (010000|core[003201]);  }
void L03230() { lac += core[000136];  }
void I03231() { lac += core[003253];  }
void I03232() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03233() { hlt = 1;  }
void I03234() { lac += core[(df<<12)+core[26]];  }
void I03235() { lac += core[000032];  }
void I03236() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03237() { hlt = 1;  }
void I03240() { core[(df<<12)+core[26]] = lac & 07777; lac &= 010000; code[(df<<12)+core[26]] = &emul8;  }
void I03241() { lac += core[000136];  }
void I03242() { lac++;  }
void I03243() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03244() { lac += core[003251];  }
void I03245() { core[(df<<12)+core[1708]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1708]] = &emul8;  }
void I03246() { lac += core[003252];  }
void I03247() { core[(df<<12)+core[38]] = lac & 07777; lac &= 010000; code[(df<<12)+core[38]] = &emul8;  }
void I03250() { npc = (ib<<12)+core[38]; inh = 0;  }
void D03251() { npc = (ib<<12)+core[111]; inh = 0;  }
void D03252() { core[(ib<<12)+core[25]] = 03253; npc = (ib<<12)+core[25]+1; code[(ib<<12)+core[25]] = &emul8; inh = 0;  }
void D03253() { emul8();  }
void P03254() { lac &= (010000|core[000101]);  }
void L03260() { lac += core[000136];  }
void I03261() { lac += core[003303];  }
void I03262() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03263() { hlt = 1;  }
void I03264() { lac += core[(df<<12)+core[25]];  }
void I03265() { lac += core[000031];  }
void I03266() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03267() { hlt = 1;  }
void I03270() { core[(df<<12)+core[25]] = lac & 07777; lac &= 010000; code[(df<<12)+core[25]] = &emul8;  }
void I03271() { lac += core[000136];  }
void I03272() { lac++;  }
void I03273() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03274() { lac += core[003301];  }
void I03275() { core[(df<<12)+core[1732]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1732]] = &emul8;  }
void I03276() { lac += core[003302];  }
void I03277() { core[(df<<12)+core[39]] = lac & 07777; lac &= 010000; code[(df<<12)+core[39]] = &emul8;  }
void I03300() { npc = (ib<<12)+core[39]; inh = 0;  }
void D03301() { npc = (ib<<12)+core[112]; inh = 0;  }
void D03302() { core[(ib<<12)+core[24]] = 03303; npc = (ib<<12)+core[24]+1; code[(ib<<12)+core[24]] = &emul8; inh = 0;  }
void D03303() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void P03304() { lac &= (010000|core[000041]);  }
void L03310() { lac += core[000136];  }
void I03311() { lac += core[003333];  }
void I03312() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03313() { hlt = 1;  }
void I03314() { lac += core[(df<<12)+core[24]];  }
void I03315() { lac += core[000030];  }
void I03316() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03317() { hlt = 1;  }
void I03320() { core[(df<<12)+core[24]] = lac & 07777; lac &= 010000; code[(df<<12)+core[24]] = &emul8;  }
void I03321() { lac += core[000136];  }
void I03322() { lac++;  }
void I03323() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03324() { lac += core[003331];  }
void I03325() { core[(df<<12)+core[1756]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1756]] = &emul8;  }
void I03326() { lac += core[003332];  }
void I03327() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I03330() { npc = (ib<<12)+core[40]; inh = 0;  }
void D03331() { npc = (ib<<12)+core[113]; inh = 0;  }
void D03332() { core[(ib<<12)+core[23]] = 03333; npc = (ib<<12)+core[23]+1; code[(ib<<12)+core[23]] = &emul8; inh = 0;  }
void D03333() { emul8();  }
void P03334() { lac &= (010000|core[000021]);  }
void L03340() { lac += core[000136];  }
void I03341() { lac += core[003363];  }
void I03342() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03343() { hlt = 1;  }
void I03344() { lac += core[(df<<12)+core[23]];  }
void I03345() { lac += core[000027];  }
void I03346() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03347() { hlt = 1;  }
void I03350() { core[(df<<12)+core[23]] = lac & 07777; lac &= 010000; code[(df<<12)+core[23]] = &emul8;  }
void I03351() { lac += core[000136];  }
void I03352() { lac++;  }
void I03353() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03354() { lac += core[003361];  }
void I03355() { core[(df<<12)+core[1780]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1780]] = &emul8;  }
void I03356() { lac += core[003362];  }
void I03357() { core[(df<<12)+core[41]] = lac & 07777; lac &= 010000; code[(df<<12)+core[41]] = &emul8;  }
void I03360() { npc = (ib<<12)+core[41]; inh = 0;  }
void D03361() { npc = (ib<<12)+core[114]; inh = 0;  }
void D03362() { core[(ib<<12)+core[22]] = 03363; npc = (ib<<12)+core[22]+1; code[(ib<<12)+core[22]] = &emul8; inh = 0;  }
void D03363() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void P03364() { lac &= (010000|core[000011]);  }
void L03400() { lac += core[000136];  }
void I03401() { lac += core[003423];  }
void I03402() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03403() { hlt = 1;  }
void I03404() { lac += core[(df<<12)+core[22]];  }
void I03405() { lac += core[000026];  }
void I03406() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void D03407() { hlt = 1;  }
void D03410() { core[(df<<12)+core[22]] = lac & 07777; lac &= 010000; code[(df<<12)+core[22]] = &emul8;  }
void I03411() { lac += core[000136];  }
void I03412() { lac++;  }
void I03413() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03414() { lac += core[003421];  }
void I03415() { core[(df<<12)+core[1812]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1812]] = &emul8;  }
void I03416() { lac += core[003422];  }
void I03417() { core[(df<<12)+core[42]] = lac & 07777; lac &= 010000; code[(df<<12)+core[42]] = &emul8;  }
void I03420() { npc = (ib<<12)+core[42]; inh = 0;  }
void D03421() { npc = (ib<<12)+core[115]; inh = 0;  }
void D03422() { core[(ib<<12)+core[21]] = 03423; npc = (ib<<12)+core[21]+1; code[(ib<<12)+core[21]] = &emul8; inh = 0;  }
void D03423() { emul8();  }
void P03424() { lac &= (010000|core[000005]);  }
void L03430() { lac += core[000136];  }
void I03431() { lac += core[003453];  }
void I03432() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03433() { hlt = 1;  }
void I03434() { lac += core[(df<<12)+core[21]];  }
void I03435() { lac += core[000025];  }
void I03436() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03437() { hlt = 1;  }
void I03440() { core[(df<<12)+core[21]] = lac & 07777; lac &= 010000; code[(df<<12)+core[21]] = &emul8;  }
void I03441() { lac += core[000136];  }
void I03442() { lac++;  }
void I03443() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03444() { lac += core[003451];  }
void I03445() { core[(df<<12)+core[1836]] = lac & 07777; lac &= 010000; code[(df<<12)+core[1836]] = &emul8;  }
void I03446() { lac += core[003452];  }
void I03447() { core[(df<<12)+core[43]] = lac & 07777; lac &= 010000; code[(df<<12)+core[43]] = &emul8;  }
void I03450() { npc = (ib<<12)+core[43]; inh = 0;  }
void D03451() { npc = (ib<<12)+core[116]; inh = 0;  }
void D03452() { core[(ib<<12)+core[20]] = 03453; npc = (ib<<12)+core[20]+1; code[(ib<<12)+core[20]] = &emul8; inh = 0;  }
void D03453() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; hlt = 1;  }
void P03454() { lac &= (010000|core[000003]);  }
void L03460() { lac += core[000136];  }
void I03461() { lac += core[003503];  }
void I03462() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03463() { hlt = 1;  }
void I03464() { lac += core[(df<<12)+core[20]];  }
void I03465() { lac += core[000024];  }
void I03466() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03467() { hlt = 1;  }
void I03470() { core[(df<<12)+core[20]] = lac & 07777; lac &= 010000; code[(df<<12)+core[20]] = &emul8;  }
void I03471() { lac += core[000136];  }
void I03472() { lac++;  }
void I03473() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03474() { lac += core[003501];  }
void I03475() { core[(df<<12)+core[20]] = lac & 07777; lac &= 010000; code[(df<<12)+core[20]] = &emul8;  }
void I03476() { lac += core[003502];  }
void I03477() { core[(df<<12)+core[44]] = lac & 07777; lac &= 010000; code[(df<<12)+core[44]] = &emul8;  }
void I03500() { npc = (ib<<12)+core[44]; inh = 0;  }
void D03501() { npc = (ib<<12)+core[117]; inh = 0;  }
void D03502() { core[(ib<<12)+core[19]] = 03503; npc = (ib<<12)+core[19]+1; code[(ib<<12)+core[19]] = &emul8; inh = 0;  }
void D03503() { emul8();  }
void L03510() { lac += core[000136];  }
void I03511() { lac += core[003533];  }
void I03512() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03513() { hlt = 1;  }
void I03514() { lac += core[(df<<12)+core[19]];  }
void I03515() { lac += core[000023];  }
void I03516() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03517() { hlt = 1;  }
void I03520() { core[(df<<12)+core[19]] = lac & 07777; lac &= 010000; code[(df<<12)+core[19]] = &emul8;  }
void I03521() { lac += core[000136];  }
void I03522() { lac++;  }
void I03523() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I03524() { lac += core[003531];  }
void I03525() { core[(df<<12)+core[19]] = lac & 07777; lac &= 010000; code[(df<<12)+core[19]] = &emul8;  }
void I03526() { lac += core[003532];  }
void I03527() { core[(df<<12)+core[45]] = lac & 07777; lac &= 010000; code[(df<<12)+core[45]] = &emul8;  }
void I03530() { npc = (ib<<12)+core[45]; inh = 0;  }
void D03531() { npc = (ib<<12)+core[118]; inh = 0;  }
void D03532() { core[(ib<<12)+core[18]] = 03533; npc = (ib<<12)+core[18]+1; code[(ib<<12)+core[18]] = &emul8; inh = 0;  }
void D03533() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000;  }
void L03540() { lac += core[000136];  }
void I03541() { lac += core[003570];  }
void I03542() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03543() { hlt = 1;  }
void I03544() { lac += core[(df<<12)+core[18]];  }
void I03545() { lac += core[000022];  }
void I03546() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I03547() { hlt = 1;  }
void I03550() { core[(df<<12)+core[18]] = lac & 07777; lac &= 010000; code[(df<<12)+core[18]] = &emul8;  }
void I03551() { lac += core[003571];  }
void I03552() { lac++;  }
void I03553() { core[003571] = lac & 07777; lac &= 010000; code[003571] = &emul8;  }
void I03554() { lac += core[003571];  }
void I03555() { lac += core[003572];  }
void I03556() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp; lac &= 010000;  }
void I03557() { npc = (ib<<12)+core[1910]; inh = 0;  }
void I03560() { core[003571] = lac & 07777; lac &= 010000; code[003571] = &emul8;  }
void I03561() { lac += core[003567];  }
void I03562() { emul8();  }
void L03563() { emul8();  }
void I03564() { npc = 003563; inh = 0;  }
void I03565() { npc = (ib<<12)+core[1910]; inh = 0;  }
void P03566() { core[003400] = 03567; npc = 003400+1; code[003400] = &emul8; inh = 0;  }
void D03567() { lac &= (010000|core[003407]);  }
void D03570() { emul8();  }
void D03571() { lac &= (010000|core[000000]);  }
void D03572() { lac += core[003400];  }
void L04200() { lac &= 010000;  }
void I04201() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04202() { npc = 004203; inh = 0;  }
void L04203() { lac += core[000136];  }
void I04204() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04205() { hlt = 1;  }
void I04206() { lac += core[000136];  }
void I04207() { lac++;  }
void I04210() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04211() { npc = 004213; inh = 0;  }
void I04212() { hlt = 1;  }
void L04213() { lac += core[000136];  }
void I04214() { lac += core[000113];  }
void I04215() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04216() { hlt = 1;  }
void I04217() { lac += core[000136];  }
void I04220() { lac++;  }
void I04221() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04222() { npc = 004225; inh = 0;  }
void I04223() { hlt = 1;  }
void I04224() { hlt = 1;  }
void L04225() { lac += core[000136];  }
void I04226() { lac += core[000114];  }
void I04227() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04230() { hlt = 1;  }
void I04231() { lac += core[000136];  }
void I04232() { lac++;  }
void I04233() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04234() { npc = 004240; inh = 0;  }
void I04235() { hlt = 1;  }
void I04236() { hlt = 1;  }
void I04237() { hlt = 1;  }
void L04240() { lac += core[000136];  }
void I04241() { lac += core[000115];  }
void I04242() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04243() { hlt = 1;  }
void I04244() { lac += core[000136];  }
void I04245() { lac++;  }
void I04246() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04247() { npc = 004254; inh = 0;  }
void I04250() { hlt = 1;  }
void I04251() { hlt = 1;  }
void I04252() { hlt = 1;  }
void I04253() { hlt = 1;  }
void L04254() { lac += core[000136];  }
void I04255() { lac += core[000116];  }
void I04256() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04257() { hlt = 1;  }
void I04260() { lac += core[000136];  }
void I04261() { lac++;  }
void I04262() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04263() { npc = 004271; inh = 0;  }
void I04264() { hlt = 1;  }
void I04265() { hlt = 1;  }
void I04266() { hlt = 1;  }
void I04267() { hlt = 1;  }
void I04270() { hlt = 1;  }
void L04271() { lac += core[000136];  }
void I04272() { lac += core[000117];  }
void I04273() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04274() { hlt = 1;  }
void I04275() { lac += core[000136];  }
void I04276() { lac++;  }
void I04277() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04300() { npc = 004307; inh = 0;  }
void I04301() { hlt = 1;  }
void I04302() { hlt = 1;  }
void I04303() { hlt = 1;  }
void I04304() { hlt = 1;  }
void I04305() { hlt = 1;  }
void I04306() { hlt = 1;  }
void L04307() { lac += core[000136];  }
void I04310() { lac += core[000120];  }
void I04311() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04312() { hlt = 1;  }
void I04313() { lac += core[000136];  }
void I04314() { lac++;  }
void I04315() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04316() { npc = 004326; inh = 0;  }
void I04317() { hlt = 1;  }
void I04320() { hlt = 1;  }
void I04321() { hlt = 1;  }
void I04322() { hlt = 1;  }
void I04323() { hlt = 1;  }
void I04324() { hlt = 1;  }
void I04325() { hlt = 1;  }
void L04326() { lac += core[000136];  }
void I04327() { lac += core[000121];  }
void I04330() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04331() { hlt = 1;  }
void I04332() { lac += core[000136];  }
void I04333() { lac++;  }
void I04334() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04335() { npc = 004346; inh = 0;  }
void I04336() { hlt = 1;  }
void I04337() { hlt = 1;  }
void I04340() { hlt = 1;  }
void I04341() { hlt = 1;  }
void I04342() { hlt = 1;  }
void I04343() { hlt = 1;  }
void I04344() { hlt = 1;  }
void I04345() { hlt = 1;  }
void L04346() { lac += core[000136];  }
void I04347() { lac += core[000122];  }
void I04350() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04351() { hlt = 1;  }
void I04352() { lac += core[000136];  }
void I04353() { lac++;  }
void I04354() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04355() { npc = 004367; inh = 0;  }
void I04356() { hlt = 1;  }
void I04357() { hlt = 1;  }
void I04360() { hlt = 1;  }
void I04361() { hlt = 1;  }
void I04362() { hlt = 1;  }
void I04363() { hlt = 1;  }
void I04364() { hlt = 1;  }
void I04365() { hlt = 1;  }
void I04366() { hlt = 1;  }
void L04367() { lac += core[000136];  }
void I04370() { lac += core[000123];  }
void I04371() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04372() { hlt = 1;  }
void I04373() { lac += core[000136];  }
void I04374() { lac++;  }
void I04375() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04376() {  }
void I04377() {  }
void I04400() { npc = 004401; inh = 0;  }
void L04401() { lac += core[000136];  }
void I04402() { lac += core[000124];  }
void I04403() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04404() { hlt = 1;  }
void I04405() { lac += core[000136];  }
void I04406() { lac++;  }
void I04407() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04410() { npc = 004412; inh = 0;  }
void I04411() { hlt = 1;  }
void L04412() { lac += core[000136];  }
void I04413() { lac += core[000125];  }
void I04414() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04415() { hlt = 1;  }
void I04416() { lac += core[000136];  }
void I04417() { lac++;  }
void I04420() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04421() { npc = 004424; inh = 0;  }
void I04422() { hlt = 1;  }
void I04423() { hlt = 1;  }
void L04424() { lac += core[000136];  }
void I04425() { lac += core[000126];  }
void I04426() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04427() { hlt = 1;  }
void I04430() { lac += core[000136];  }
void I04431() { lac++;  }
void I04432() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04433() { npc = 004437; inh = 0;  }
void I04434() { hlt = 1;  }
void I04435() { hlt = 1;  }
void I04436() { hlt = 1;  }
void L04437() { lac += core[000136];  }
void I04440() { lac += core[000127];  }
void I04441() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04442() { hlt = 1;  }
void I04443() { lac += core[000136];  }
void I04444() { lac++;  }
void I04445() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04446() { npc = 004453; inh = 0;  }
void I04447() { hlt = 1;  }
void I04450() { hlt = 1;  }
void I04451() { hlt = 1;  }
void I04452() { hlt = 1;  }
void L04453() { lac += core[000136];  }
void I04454() { lac += core[000130];  }
void I04455() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04456() { hlt = 1;  }
void I04457() { lac += core[000136];  }
void I04460() { lac++;  }
void I04461() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04462() { npc = 004470; inh = 0;  }
void I04463() { hlt = 1;  }
void I04464() { hlt = 1;  }
void I04465() { hlt = 1;  }
void I04466() { hlt = 1;  }
void I04467() { hlt = 1;  }
void L04470() { lac += core[000136];  }
void I04471() { lac += core[000131];  }
void I04472() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04473() { hlt = 1;  }
void I04474() { lac += core[000136];  }
void I04475() { lac++;  }
void I04476() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04477() { npc = 004506; inh = 0;  }
void I04500() { hlt = 1;  }
void I04501() { hlt = 1;  }
void I04502() { hlt = 1;  }
void I04503() { hlt = 1;  }
void I04504() { hlt = 1;  }
void I04505() { hlt = 1;  }
void L04506() { lac += core[000136];  }
void I04507() { lac += core[000132];  }
void I04510() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04511() { hlt = 1;  }
void I04512() { lac += core[000136];  }
void I04513() { lac++;  }
void I04514() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04515() { npc = 004525; inh = 0;  }
void I04516() { hlt = 1;  }
void I04517() { hlt = 1;  }
void I04520() { hlt = 1;  }
void I04521() { hlt = 1;  }
void I04522() { hlt = 1;  }
void I04523() { hlt = 1;  }
void I04524() { hlt = 1;  }
void L04525() { lac += core[000136];  }
void I04526() { lac += core[000133];  }
void I04527() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04530() { hlt = 1;  }
void I04531() { lac += core[000136];  }
void I04532() { lac++;  }
void I04533() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04534() { npc = 004545; inh = 0;  }
void I04535() { hlt = 1;  }
void I04536() { hlt = 1;  }
void I04537() { hlt = 1;  }
void I04540() { hlt = 1;  }
void I04541() { hlt = 1;  }
void I04542() { hlt = 1;  }
void I04543() { hlt = 1;  }
void I04544() { hlt = 1;  }
void L04545() { lac += core[000136];  }
void I04546() { lac += core[000134];  }
void I04547() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04550() { hlt = 1;  }
void I04551() { lac += core[000136];  }
void I04552() { lac++;  }
void I04553() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04554() { npc = 004566; inh = 0;  }
void I04555() { hlt = 1;  }
void I04556() { hlt = 1;  }
void I04557() { hlt = 1;  }
void I04560() { hlt = 1;  }
void I04561() { hlt = 1;  }
void I04562() { hlt = 1;  }
void I04563() { hlt = 1;  }
void I04564() { hlt = 1;  }
void I04565() { hlt = 1;  }
void L04566() { lac += core[000136];  }
void I04567() { lac += core[000135];  }
void I04570() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04571() { hlt = 1;  }
void I04572() { lac += core[000136];  }
void I04573() { lac++;  }
void I04574() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04575() {  }
void I04576() {  }
void I04577() {  }
void I04600() { lac += core[004605];  }
void I04601() { core[(df<<12)+core[45]] = lac & 07777; lac &= 010000; code[(df<<12)+core[45]] = &emul8;  }
void I04602() { lac += core[004606];  }
void I04603() { core[(df<<12)+core[18]] = lac & 07777; lac &= 010000; code[(df<<12)+core[18]] = &emul8;  }
void I04604() { npc = (ib<<12)+core[45]; inh = 0;  }
void D04605() { npc = (ib<<12)+core[18]; inh = 0;  }
void D04606() { npc = (ib<<12)+core[46]; inh = 0;  }
void L04620() { lac += core[000136];  }
void I04621() { lac += core[004636];  }
void I04622() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04623() { hlt = 1;  }
void I04624() { lac += core[000136];  }
void I04625() { lac++;  }
void I04626() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04627() { lac += core[004634];  }
void I04630() { core[(df<<12)+core[44]] = lac & 07777; lac &= 010000; code[(df<<12)+core[44]] = &emul8;  }
void I04631() { lac += core[004635];  }
void I04632() { core[(df<<12)+core[19]] = lac & 07777; lac &= 010000; code[(df<<12)+core[19]] = &emul8;  }
void I04633() { npc = (ib<<12)+core[44]; inh = 0;  }
void D04634() { npc = (ib<<12)+core[19]; inh = 0;  }
void D04635() { npc = (ib<<12)+core[47]; inh = 0;  }
void D04636() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void L04640() { lac += core[000136];  }
void I04641() { lac += core[004656];  }
void I04642() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04643() { hlt = 1;  }
void I04644() { lac += core[000136];  }
void I04645() { lac++;  }
void I04646() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04647() { lac += core[004654];  }
void I04650() { core[(df<<12)+core[43]] = lac & 07777; lac &= 010000; code[(df<<12)+core[43]] = &emul8;  }
void I04651() { lac += core[004655];  }
void I04652() { core[(df<<12)+core[20]] = lac & 07777; lac &= 010000; code[(df<<12)+core[20]] = &emul8;  }
void I04653() { npc = (ib<<12)+core[43]; inh = 0;  }
void D04654() { npc = (ib<<12)+core[20]; inh = 0;  }
void D04655() { npc = (ib<<12)+core[2480]; inh = 0;  }
void D04656() { emul8();  }
void P04660() { lac += core[000136];  }
void I04661() { lac += core[004676];  }
void I04662() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04663() { hlt = 1;  }
void I04664() { lac += core[000136];  }
void I04665() { lac++;  }
void I04666() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04667() { lac += core[004674];  }
void I04670() { core[(df<<12)+core[42]] = lac & 07777; lac &= 010000; code[(df<<12)+core[42]] = &emul8;  }
void I04671() { lac += core[004675];  }
void I04672() { core[(df<<12)+core[21]] = lac & 07777; lac &= 010000; code[(df<<12)+core[21]] = &emul8;  }
void I04673() { npc = (ib<<12)+core[42]; inh = 0;  }
void D04674() { npc = (ib<<12)+core[21]; inh = 0;  }
void D04675() { npc = (ib<<12)+core[49]; inh = 0;  }
void D04676() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void L04700() { lac += core[000136];  }
void I04701() { lac += core[004716];  }
void I04702() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04703() { hlt = 1;  }
void I04704() { lac += core[000136];  }
void I04705() { lac++;  }
void I04706() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04707() { lac += core[004714];  }
void I04710() { core[(df<<12)+core[41]] = lac & 07777; lac &= 010000; code[(df<<12)+core[41]] = &emul8;  }
void I04711() { lac += core[004715];  }
void I04712() { core[(df<<12)+core[22]] = lac & 07777; lac &= 010000; code[(df<<12)+core[22]] = &emul8;  }
void I04713() { npc = (ib<<12)+core[41]; inh = 0;  }
void D04714() { npc = (ib<<12)+core[22]; inh = 0;  }
void D04715() { npc = (ib<<12)+core[50]; inh = 0;  }
void D04716() { emul8();  }
void L04720() { lac += core[000136];  }
void I04721() { lac += core[004736];  }
void I04722() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04723() { hlt = 1;  }
void I04724() { lac += core[000136];  }
void I04725() { lac++;  }
void I04726() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04727() { lac += core[004734];  }
void I04730() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I04731() { lac += core[004735];  }
void I04732() { core[(df<<12)+core[23]] = lac & 07777; lac &= 010000; code[(df<<12)+core[23]] = &emul8;  }
void I04733() { npc = (ib<<12)+core[40]; inh = 0;  }
void D04734() { npc = (ib<<12)+core[23]; inh = 0;  }
void D04735() { npc = (ib<<12)+core[51]; inh = 0;  }
void D04736() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void L04740() { lac += core[000136];  }
void I04741() { lac += core[004756];  }
void I04742() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04743() { hlt = 1;  }
void I04744() { lac += core[000136];  }
void I04745() { lac++;  }
void I04746() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04747() { lac += core[004754];  }
void I04750() { core[(df<<12)+core[39]] = lac & 07777; lac &= 010000; code[(df<<12)+core[39]] = &emul8;  }
void I04751() { lac += core[004755];  }
void I04752() { core[(df<<12)+core[24]] = lac & 07777; lac &= 010000; code[(df<<12)+core[24]] = &emul8;  }
void I04753() { npc = (ib<<12)+core[39]; inh = 0;  }
void D04754() { npc = (ib<<12)+core[24]; inh = 0;  }
void D04755() { npc = (ib<<12)+core[52]; inh = 0;  }
void D04756() { emul8();  }
void L04760() { lac += core[000136];  }
void I04761() { lac += core[004776];  }
void I04762() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I04763() { hlt = 1;  }
void I04764() { lac += core[000136];  }
void I04765() { lac++;  }
void I04766() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I04767() { lac += core[004774];  }
void I04770() { core[(df<<12)+core[38]] = lac & 07777; lac &= 010000; code[(df<<12)+core[38]] = &emul8;  }
void I04771() { lac += core[004775];  }
void I04772() { core[(df<<12)+core[25]] = lac & 07777; lac &= 010000; code[(df<<12)+core[25]] = &emul8;  }
void I04773() { npc = (ib<<12)+core[38]; inh = 0;  }
void D04774() { npc = (ib<<12)+core[25]; inh = 0;  }
void D04775() { npc = (ib<<12)+core[53]; inh = 0;  }
void D04776() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void L05000() { lac += core[000136];  }
void D05001() { lac += core[005016];  }
void I05002() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05003() { hlt = 1;  }
void I05004() { lac += core[000136];  }
void I05005() { lac++;  }
void I05006() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05007() { lac += core[005014];  }
void I05010() { core[(df<<12)+core[37]] = lac & 07777; lac &= 010000; code[(df<<12)+core[37]] = &emul8;  }
void I05011() { lac += core[005015];  }
void I05012() { core[(df<<12)+core[26]] = lac & 07777; lac &= 010000; code[(df<<12)+core[26]] = &emul8;  }
void I05013() { npc = (ib<<12)+core[37]; inh = 0;  }
void D05014() { npc = (ib<<12)+core[26]; inh = 0;  }
void D05015() { npc = (ib<<12)+core[54]; inh = 0;  }
void D05016() { emul8();  }
void L05020() { lac += core[000136];  }
void I05021() { lac += core[005036];  }
void I05022() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05023() { hlt = 1;  }
void I05024() { lac += core[000136];  }
void I05025() { lac++;  }
void I05026() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05027() { lac += core[005034];  }
void I05030() { core[(df<<12)+core[36]] = lac & 07777; lac &= 010000; code[(df<<12)+core[36]] = &emul8;  }
void I05031() { lac += core[005035];  }
void I05032() { core[(df<<12)+core[27]] = lac & 07777; lac &= 010000; code[(df<<12)+core[27]] = &emul8;  }
void I05033() { npc = (ib<<12)+core[36]; inh = 0;  }
void D05034() { npc = (ib<<12)+core[27]; inh = 0;  }
void D05035() { npc = (ib<<12)+core[55]; inh = 0;  }
void D05036() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void L05040() { lac += core[000136];  }
void I05041() { lac += core[005056];  }
void I05042() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05043() { hlt = 1;  }
void I05044() { lac += core[000136];  }
void I05045() { lac++;  }
void I05046() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05047() { lac += core[005054];  }
void I05050() { core[(df<<12)+core[35]] = lac & 07777; lac &= 010000; code[(df<<12)+core[35]] = &emul8;  }
void I05051() { lac += core[005055];  }
void I05052() { core[(df<<12)+core[28]] = lac & 07777; lac &= 010000; code[(df<<12)+core[28]] = &emul8;  }
void I05053() { npc = (ib<<12)+core[35]; inh = 0;  }
void D05054() { npc = (ib<<12)+core[28]; inh = 0;  }
void D05055() { npc = (ib<<12)+core[56]; inh = 0;  }
void D05056() { emul8();  }
void L05060() { lac += core[000136];  }
void I05061() { lac += core[005076];  }
void I05062() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05063() { hlt = 1;  }
void I05064() { lac += core[000136];  }
void I05065() { lac++;  }
void I05066() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05067() { lac += core[005074];  }
void I05070() { core[(df<<12)+core[34]] = lac & 07777; lac &= 010000; code[(df<<12)+core[34]] = &emul8;  }
void I05071() { lac += core[005075];  }
void I05072() { core[(df<<12)+core[29]] = lac & 07777; lac &= 010000; code[(df<<12)+core[29]] = &emul8;  }
void I05073() { npc = (ib<<12)+core[34]; inh = 0;  }
void D05074() { npc = (ib<<12)+core[29]; inh = 0;  }
void D05075() { npc = (ib<<12)+core[57]; inh = 0;  }
void D05076() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000; hlt = 1;  }
void L05100() { lac += core[000136];  }
void I05101() { lac += core[005116];  }
void I05102() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05103() { hlt = 1;  }
void I05104() { lac += core[000136];  }
void I05105() { lac++;  }
void I05106() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05107() { lac += core[005114];  }
void I05110() { core[(df<<12)+core[31]] = lac & 07777; lac &= 010000; code[(df<<12)+core[31]] = &emul8;  }
void I05111() { lac += core[005115];  }
void I05112() { core[(df<<12)+core[30]] = lac & 07777; lac &= 010000; code[(df<<12)+core[30]] = &emul8;  }
void I05113() { npc = (ib<<12)+core[31]; inh = 0;  }
void D05114() { npc = (ib<<12)+core[30]; inh = 0;  }
void D05115() { npc = (ib<<12)+core[58]; inh = 0;  }
void D05116() { emul8();  }
void L05120() { lac += core[000136];  }
void I05121() { lac += core[005136];  }
void I05122() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05123() { hlt = 1;  }
void I05124() { lac += core[000136];  }
void I05125() { lac++;  }
void I05126() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05127() { lac += core[005134];  }
void I05130() { core[(df<<12)+core[18]] = lac & 07777; lac &= 010000; code[(df<<12)+core[18]] = &emul8;  }
void I05131() { lac += core[005135];  }
void I05132() { core[(df<<12)+core[45]] = lac & 07777; lac &= 010000; code[(df<<12)+core[45]] = &emul8;  }
void I05133() { npc = (ib<<12)+core[18]; inh = 0;  }
void D05134() { npc = (ib<<12)+core[45]; inh = 0;  }
void D05135() { npc = (ib<<12)+core[59]; inh = 0;  }
void D05136() { skp = 0; if (!(lac&07777)) skp = 1; if (lac&04000) skp = 1; npc += skp; lac &= 010000;  }
void L05140() { lac += core[000136];  }
void I05141() { lac += core[005156];  }
void I05142() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05143() { hlt = 1;  }
void I05144() { lac += core[000136];  }
void I05145() { lac++;  }
void I05146() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05147() { lac += core[005154];  }
void I05150() { core[(df<<12)+core[19]] = lac & 07777; lac &= 010000; code[(df<<12)+core[19]] = &emul8;  }
void I05151() { lac += core[005155];  }
void I05152() { core[(df<<12)+core[44]] = lac & 07777; lac &= 010000; code[(df<<12)+core[44]] = &emul8;  }
void I05153() { npc = (ib<<12)+core[19]; inh = 0;  }
void D05154() { npc = (ib<<12)+core[44]; inh = 0;  }
void D05155() { npc = (ib<<12)+core[60]; inh = 0;  }
void D05156() { emul8();  }
void L05160() { lac += core[000136];  }
void I05161() { lac += core[005176];  }
void I05162() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05163() { hlt = 1;  }
void I05164() { lac += core[000136];  }
void I05165() { lac++;  }
void I05166() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05167() { lac += core[005174];  }
void I05170() { core[(df<<12)+core[20]] = lac & 07777; lac &= 010000; code[(df<<12)+core[20]] = &emul8;  }
void I05171() { lac += core[005175];  }
void I05172() { core[(df<<12)+core[43]] = lac & 07777; lac &= 010000; code[(df<<12)+core[43]] = &emul8;  }
void I05173() { npc = (ib<<12)+core[20]; inh = 0;  }
void D05174() { npc = (ib<<12)+core[43]; inh = 0;  }
void D05175() { npc = (ib<<12)+core[61]; inh = 0;  }
void D05176() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void L05200() { lac += core[000136];  }
void I05201() { lac += core[005216];  }
void I05202() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05203() { hlt = 1;  }
void I05204() { lac += core[000136];  }
void I05205() { lac++;  }
void I05206() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05207() { lac += core[005214];  }
void I05210() { core[(df<<12)+core[21]] = lac & 07777; lac &= 010000; code[(df<<12)+core[21]] = &emul8;  }
void I05211() { lac += core[005215];  }
void I05212() { core[(df<<12)+core[42]] = lac & 07777; lac &= 010000; code[(df<<12)+core[42]] = &emul8;  }
void I05213() { npc = (ib<<12)+core[21]; inh = 0;  }
void D05214() { npc = (ib<<12)+core[42]; inh = 0;  }
void D05215() { npc = (ib<<12)+core[62]; inh = 0;  }
void D05216() { emul8();  }
void L05220() { lac += core[000136];  }
void I05221() { lac += core[005236];  }
void I05222() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05223() { hlt = 1;  }
void I05224() { lac += core[000136];  }
void I05225() { lac++;  }
void I05226() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05227() { lac += core[005234];  }
void I05230() { core[(df<<12)+core[22]] = lac & 07777; lac &= 010000; code[(df<<12)+core[22]] = &emul8;  }
void I05231() { lac += core[005235];  }
void I05232() { core[(df<<12)+core[41]] = lac & 07777; lac &= 010000; code[(df<<12)+core[41]] = &emul8;  }
void I05233() { npc = (ib<<12)+core[22]; inh = 0;  }
void D05234() { npc = (ib<<12)+core[41]; inh = 0;  }
void D05235() { npc = (ib<<12)+core[66]; inh = 0;  }
void D05236() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; lac |= swr;  }
void L05240() { lac += core[000136];  }
void I05241() { lac += core[005256];  }
void I05242() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05243() { hlt = 1;  }
void I05244() { lac += core[000136];  }
void I05245() { lac++;  }
void I05246() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05247() { lac += core[005254];  }
void I05250() { core[(df<<12)+core[23]] = lac & 07777; lac &= 010000; code[(df<<12)+core[23]] = &emul8;  }
void I05251() { lac += core[005255];  }
void I05252() { core[(df<<12)+core[40]] = lac & 07777; lac &= 010000; code[(df<<12)+core[40]] = &emul8;  }
void I05253() { npc = (ib<<12)+core[23]; inh = 0;  }
void D05254() { npc = (ib<<12)+core[40]; inh = 0;  }
void D05255() { npc = (ib<<12)+core[67]; inh = 0;  }
void D05256() { emul8();  }
void L05260() { lac += core[000136];  }
void I05261() { lac += core[005276];  }
void I05262() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05263() { hlt = 1;  }
void I05264() { lac += core[000136];  }
void I05265() { lac++;  }
void I05266() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05267() { lac += core[005274];  }
void I05270() { core[(df<<12)+core[24]] = lac & 07777; lac &= 010000; code[(df<<12)+core[24]] = &emul8;  }
void I05271() { lac += core[005275];  }
void I05272() { core[(df<<12)+core[39]] = lac & 07777; lac &= 010000; code[(df<<12)+core[39]] = &emul8;  }
void I05273() { npc = (ib<<12)+core[24]; inh = 0;  }
void D05274() { npc = (ib<<12)+core[39]; inh = 0;  }
void D05275() { npc = (ib<<12)+core[68]; inh = 0;  }
void D05276() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000; hlt = 1;  }
void L05300() { lac += core[000136];  }
void I05301() { lac += core[005316];  }
void I05302() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05303() { hlt = 1;  }
void I05304() { lac += core[000136];  }
void I05305() { lac++;  }
void I05306() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05307() { lac += core[005314];  }
void I05310() { core[(df<<12)+core[25]] = lac & 07777; lac &= 010000; code[(df<<12)+core[25]] = &emul8;  }
void I05311() { lac += core[005315];  }
void I05312() { core[(df<<12)+core[38]] = lac & 07777; lac &= 010000; code[(df<<12)+core[38]] = &emul8;  }
void I05313() { npc = (ib<<12)+core[25]; inh = 0;  }
void D05314() { npc = (ib<<12)+core[38]; inh = 0;  }
void D05315() { npc = (ib<<12)+core[69]; inh = 0;  }
void D05316() { emul8();  }
void L05320() { lac += core[000136];  }
void I05321() { lac += core[005336];  }
void I05322() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05323() { hlt = 1;  }
void I05324() { lac += core[000136];  }
void I05325() { lac++;  }
void I05326() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05327() { lac += core[005334];  }
void I05330() { core[(df<<12)+core[26]] = lac & 07777; lac &= 010000; code[(df<<12)+core[26]] = &emul8;  }
void I05331() { lac += core[005335];  }
void I05332() { core[(df<<12)+core[37]] = lac & 07777; lac &= 010000; code[(df<<12)+core[37]] = &emul8;  }
void I05333() { npc = (ib<<12)+core[26]; inh = 0;  }
void D05334() { npc = (ib<<12)+core[37]; inh = 0;  }
void D05335() { npc = (ib<<12)+core[70]; inh = 0;  }
void D05336() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; skp = !skp; npc += skp; lac &= 010000;  }
void L05340() { lac += core[000136];  }
void I05341() { lac += core[005356];  }
void I05342() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05343() { hlt = 1;  }
void I05344() { lac += core[000136];  }
void I05345() { lac++;  }
void I05346() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05347() { lac += core[005354];  }
void I05350() { core[(df<<12)+core[27]] = lac & 07777; lac &= 010000; code[(df<<12)+core[27]] = &emul8;  }
void I05351() { lac += core[005355];  }
void I05352() { core[(df<<12)+core[36]] = lac & 07777; lac &= 010000; code[(df<<12)+core[36]] = &emul8;  }
void I05353() { npc = (ib<<12)+core[27]; inh = 0;  }
void D05354() { npc = (ib<<12)+core[36]; inh = 0;  }
void D05355() { npc = (ib<<12)+core[71]; inh = 0;  }
void D05356() { emul8();  }
void L05360() { lac += core[000136];  }
void I05361() { lac += core[005376];  }
void I05362() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05363() { hlt = 1;  }
void I05364() { lac += core[000136];  }
void I05365() { lac++;  }
void I05366() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05367() { lac += core[005374];  }
void I05370() { core[(df<<12)+core[28]] = lac & 07777; lac &= 010000; code[(df<<12)+core[28]] = &emul8;  }
void I05371() { lac += core[005375];  }
void I05372() { core[(df<<12)+core[35]] = lac & 07777; lac &= 010000; code[(df<<12)+core[35]] = &emul8;  }
void I05373() { npc = (ib<<12)+core[28]; inh = 0;  }
void D05374() { npc = (ib<<12)+core[35]; inh = 0;  }
void D05375() { npc = (ib<<12)+core[72]; inh = 0;  }
void D05376() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr; hlt = 1;  }
void L05400() { lac += core[000136];  }
void I05401() { lac += core[005416];  }
void I05402() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05403() { hlt = 1;  }
void I05404() { lac += core[000136];  }
void I05405() { lac++;  }
void I05406() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05407() { lac += core[005414];  }
void I05410() { core[(df<<12)+core[29]] = lac & 07777; lac &= 010000; code[(df<<12)+core[29]] = &emul8;  }
void I05411() { lac += core[005415];  }
void I05412() { core[(df<<12)+core[34]] = lac & 07777; lac &= 010000; code[(df<<12)+core[34]] = &emul8;  }
void I05413() { npc = (ib<<12)+core[29]; inh = 0;  }
void D05414() { npc = (ib<<12)+core[34]; inh = 0;  }
void D05415() { npc = (ib<<12)+core[73]; inh = 0;  }
void D05416() { emul8();  }
void L05420() { lac += core[000136];  }
void I05421() { lac += core[005436];  }
void I05422() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05423() { hlt = 1;  }
void I05424() { lac += core[000136];  }
void I05425() { lac++;  }
void I05426() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05427() { lac += core[005434];  }
void I05430() { core[(df<<12)+core[30]] = lac & 07777; lac &= 010000; code[(df<<12)+core[30]] = &emul8;  }
void I05431() { lac += core[005435];  }
void I05432() { core[(df<<12)+core[31]] = lac & 07777; lac &= 010000; code[(df<<12)+core[31]] = &emul8;  }
void I05433() { npc = (ib<<12)+core[30]; inh = 0;  }
void D05434() { npc = (ib<<12)+core[31]; inh = 0;  }
void D05435() { npc = (ib<<12)+core[74]; inh = 0;  }
void D05436() { skp = 0; if (lac&04000) skp = 1; if (lac&010000) skp = 1; npc += skp; lac &= 010000; lac |= swr;  }
void L05440() { lac += core[000136];  }
void I05441() { lac += core[005450];  }
void I05442() { skp = 0; if (!(lac&07777)) skp = 1; npc += skp;  }
void I05443() { hlt = 1;  }
void I05444() { lac += core[000136];  }
void I05445() { lac++;  }
void I05446() { core[000136] = lac & 07777; lac &= 010000; code[000136] = &emul8;  }
void I05447() { npc = (ib<<12)+core[2857]; inh = 0;  }
void D05450() { emul8();  }
void P05451() { if (++core[000002] == 010000) { core[000002] = 0; npc++; }; code[000002] = &emul8;  }
void preinit() {
  core[000000] = 00000; code[000000] = &S00000;
  core[000001] = 05001; code[000001] = &P00001;
  core[000002] = 00002; code[000002] = &L00002;
  core[000003] = 00003; code[000003] = &D00003;
  core[000004] = 00000; code[000004] = &L00004;
  core[000005] = 00000; code[000005] = &D00005;
  core[000006] = 07402; code[000006] = &I00006;
  core[000007] = 07402; code[000007] = &I00007;
  core[000010] = 07402; code[000010] = &P00010;
  core[000011] = 07402; code[000011] = &D00011;
  core[000012] = 07402; code[000012] = &I00012;
  core[000013] = 07402; code[000013] = &I00013;
  core[000014] = 07402; code[000014] = &I00014;
  core[000015] = 07402; code[000015] = &I00015;
  core[000016] = 07402; code[000016] = &I00016;
  core[000017] = 07402; code[000017] = &I00017;
  core[000020] = 07402; code[000020] = &P00020;
  core[000021] = 07402; code[000021] = &D00021;
  core[000022] = 00000; code[000022] = &P00022;
  core[000023] = 00001; code[000023] = &P00023;
  core[000024] = 00002; code[000024] = &P00024;
  core[000025] = 00004; code[000025] = &P00025;
  core[000026] = 00010; code[000026] = &P00026;
  core[000027] = 00020; code[000027] = &P00027;
  core[000030] = 00040; code[000030] = &P00030;
  core[000031] = 00100; code[000031] = &P00031;
  core[000032] = 00200; code[000032] = &P00032;
  core[000033] = 00400; code[000033] = &P00033;
  core[000034] = 01000; code[000034] = &P00034;
  core[000035] = 02000; code[000035] = &P00035;
  core[000036] = 04000; code[000036] = &P00036;
  core[000037] = 03777; code[000037] = &P00037;
  core[000042] = 05777; code[000042] = &P00042;
  core[000043] = 06777; code[000043] = &P00043;
  core[000044] = 07377; code[000044] = &P00044;
  core[000045] = 07577; code[000045] = &P00045;
  core[000046] = 07677; code[000046] = &P00046;
  core[000047] = 07737; code[000047] = &P00047;
  core[000050] = 07757; code[000050] = &P00050;
  core[000051] = 07767; code[000051] = &P00051;
  core[000052] = 07773; code[000052] = &P00052;
  core[000053] = 07775; code[000053] = &P00053;
  core[000054] = 07776; code[000054] = &P00054;
  core[000055] = 07777; code[000055] = &P00055;
  core[000056] = 04620; code[000056] = &P00056;
  core[000057] = 04640; code[000057] = &P00057;
  core[000060] = 04660; code[000060] = &P00060;
  core[000061] = 04700; code[000061] = &P00061;
  core[000062] = 04720; code[000062] = &P00062;
  core[000063] = 04740; code[000063] = &P00063;
  core[000064] = 04760; code[000064] = &P00064;
  core[000065] = 05000; code[000065] = &P00065;
  core[000066] = 05020; code[000066] = &P00066;
  core[000067] = 05040; code[000067] = &P00067;
  core[000070] = 05060; code[000070] = &P00070;
  core[000071] = 05100; code[000071] = &P00071;
  core[000072] = 05120; code[000072] = &P00072;
  core[000073] = 05140; code[000073] = &P00073;
  core[000074] = 05160; code[000074] = &P00074;
  core[000075] = 05200; code[000075] = &P00075;
  core[000076] = 05220; code[000076] = &P00076;
  core[000102] = 05240; code[000102] = &P00102;
  core[000103] = 05260; code[000103] = &P00103;
  core[000104] = 05300; code[000104] = &P00104;
  core[000105] = 05320; code[000105] = &P00105;
  core[000106] = 05340; code[000106] = &P00106;
  core[000107] = 05360; code[000107] = &P00107;
  core[000110] = 05400; code[000110] = &P00110;
  core[000111] = 05420; code[000111] = &P00111;
  core[000112] = 05440; code[000112] = &P00112;
  core[000113] = 07777; code[000113] = &D00113;
  core[000114] = 07776; code[000114] = &D00114;
  core[000115] = 07775; code[000115] = &D00115;
  core[000116] = 07774; code[000116] = &D00116;
  core[000117] = 07773; code[000117] = &D00117;
  core[000120] = 07772; code[000120] = &P00120;
  core[000121] = 07771; code[000121] = &D00121;
  core[000122] = 07770; code[000122] = &D00122;
  core[000123] = 07767; code[000123] = &D00123;
  core[000124] = 07766; code[000124] = &D00124;
  core[000125] = 07765; code[000125] = &D00125;
  core[000126] = 07764; code[000126] = &D00126;
  core[000127] = 07763; code[000127] = &D00127;
  core[000130] = 07762; code[000130] = &D00130;
  core[000131] = 07761; code[000131] = &D00131;
  core[000132] = 07760; code[000132] = &D00132;
  core[000133] = 07757; code[000133] = &D00133;
  core[000134] = 07756; code[000134] = &D00134;
  core[000135] = 07755; code[000135] = &D00135;
  core[000136] = 00000; code[000136] = &D00136;
  core[000137] = 02410; code[000137] = &P00137;
  core[000140] = 02440; code[000140] = &P00140;
  core[000141] = 02470; code[000141] = &P00141;
  core[000142] = 02520; code[000142] = &P00142;
  core[000143] = 02600; code[000143] = &P00143;
  core[000144] = 02630; code[000144] = &P00144;
  core[000145] = 02660; code[000145] = &P00145;
  core[000146] = 02710; code[000146] = &P00146;
  core[000147] = 02740; code[000147] = &P00147;
  core[000150] = 03000; code[000150] = &P00150;
  core[000151] = 03030; code[000151] = &P00151;
  core[000152] = 03060; code[000152] = &P00152;
  core[000153] = 03110; code[000153] = &P00153;
  core[000154] = 03140; code[000154] = &P00154;
  core[000155] = 03200; code[000155] = &P00155;
  core[000156] = 03230; code[000156] = &P00156;
  core[000157] = 03260; code[000157] = &P00157;
  core[000160] = 03310; code[000160] = &P00160;
  core[000161] = 03340; code[000161] = &P00161;
  core[000162] = 03400; code[000162] = &P00162;
  core[000163] = 03430; code[000163] = &P00163;
  core[000164] = 03460; code[000164] = &P00164;
  core[000165] = 03510; code[000165] = &P00165;
  core[000166] = 03540; code[000166] = &P00166;
  core[000170] = 00000; code[000170] = &S00170;
  core[000171] = 01175; code[000171] = &I00171;
  core[000172] = 03410; code[000172] = &P00172;
  core[000173] = 01010; code[000173] = &I00173;
  core[000174] = 05570; code[000174] = &I00174;
  core[000175] = 07402; code[000175] = &D00175;
  core[000200] = 05601; code[000200] = &P00200;
  core[000201] = 00600; code[000201] = &P00201;
  core[000600] = 07200; code[000600] = &L00600;
  core[000601] = 01453; code[000601] = &P00601;
  core[000602] = 03343; code[000602] = &I00602;
  core[000603] = 01452; code[000603] = &I00603;
  core[000604] = 03344; code[000604] = &I00604;
  core[000605] = 01736; code[000605] = &I00605;
  core[000606] = 03345; code[000606] = &I00606;
  core[000607] = 01451; code[000607] = &I00607;
  core[000610] = 03346; code[000610] = &I00610;
  core[000611] = 01737; code[000611] = &I00611;
  core[000612] = 03347; code[000612] = &I00612;
  core[000613] = 01450; code[000613] = &I00613;
  core[000614] = 03350; code[000614] = &I00614;
  core[000615] = 01740; code[000615] = &I00615;
  core[000616] = 03351; code[000616] = &I00616;
  core[000617] = 01447; code[000617] = &I00617;
  core[000620] = 03352; code[000620] = &I00620;
  core[000621] = 01741; code[000621] = &I00621;
  core[000622] = 03353; code[000622] = &I00622;
  core[000623] = 01446; code[000623] = &I00623;
  core[000624] = 03354; code[000624] = &I00624;
  core[000625] = 01742; code[000625] = &I00625;
  core[000626] = 03355; code[000626] = &I00626;
  core[000627] = 01455; code[000627] = &I00627;
  core[000630] = 03356; code[000630] = &I00630;
  core[000631] = 07300; code[000631] = &I00631;
  core[000632] = 01264; code[000632] = &I00632;
  core[000633] = 03010; code[000633] = &I00633;
  core[000634] = 04170; code[000634] = &L00634;
  core[000635] = 01265; code[000635] = &I00635;
  core[000636] = 07640; code[000636] = &I00636;
  core[000637] = 05234; code[000637] = &I00637;
  core[000640] = 01266; code[000640] = &I00640;
  core[000641] = 03010; code[000641] = &I00641;
  core[000642] = 04170; code[000642] = &L00642;
  core[000643] = 01267; code[000643] = &I00643;
  core[000644] = 07640; code[000644] = &I00644;
  core[000645] = 05242; code[000645] = &I00645;
  core[000646] = 01270; code[000646] = &I00646;
  core[000647] = 03010; code[000647] = &I00647;
  core[000650] = 04170; code[000650] = &L00650;
  core[000651] = 01271; code[000651] = &I00651;
  core[000652] = 07640; code[000652] = &I00652;
  core[000653] = 05250; code[000653] = &I00653;
  core[000654] = 01272; code[000654] = &I00654;
  core[000655] = 03010; code[000655] = &I00655;
  core[000656] = 04170; code[000656] = &L00656;
  core[000657] = 01273; code[000657] = &I00657;
  core[000660] = 07640; code[000660] = &I00660;
  core[000661] = 05256; code[000661] = &I00661;
  core[000662] = 05300; code[000662] = &I00662;
  core[000663] = 04200; code[000663] = &P00663;
  core[000664] = 00175; code[000664] = &D00664;
  core[000665] = 07201; code[000665] = &D00665;
  core[000666] = 00756; code[000666] = &D00666;
  core[000667] = 06001; code[000667] = &D00667;
  core[000670] = 03572; code[000670] = &D00670;
  core[000671] = 03601; code[000671] = &D00671;
  core[000672] = 05451; code[000672] = &D00672;
  core[000673] = 00200; code[000673] = &D00673;
  core[000700] = 01303; code[000700] = &L00700;
  core[000701] = 03200; code[000701] = &I00701;
  core[000702] = 05303; code[000702] = &I00702;
  core[000703] = 05663; code[000703] = &L00703;
  core[000704] = 07200; code[000704] = &I00704;
  core[000705] = 01343; code[000705] = &I00705;
  core[000706] = 03453; code[000706] = &I00706;
  core[000707] = 01344; code[000707] = &I00707;
  core[000710] = 03452; code[000710] = &I00710;
  core[000711] = 01345; code[000711] = &I00711;
  core[000712] = 03736; code[000712] = &I00712;
  core[000713] = 01346; code[000713] = &I00713;
  core[000714] = 03451; code[000714] = &I00714;
  core[000715] = 01347; code[000715] = &I00715;
  core[000716] = 03737; code[000716] = &I00716;
  core[000717] = 01350; code[000717] = &I00717;
  core[000720] = 03450; code[000720] = &I00720;
  core[000721] = 01351; code[000721] = &I00721;
  core[000722] = 03740; code[000722] = &I00722;
  core[000723] = 01352; code[000723] = &I00723;
  core[000724] = 03447; code[000724] = &I00724;
  core[000725] = 01353; code[000725] = &I00725;
  core[000726] = 03741; code[000726] = &I00726;
  core[000727] = 01354; code[000727] = &I00727;
  core[000730] = 03446; code[000730] = &I00730;
  core[000731] = 01355; code[000731] = &I00731;
  core[000732] = 03742; code[000732] = &I00732;
  core[000733] = 01356; code[000733] = &I00733;
  core[000734] = 03455; code[000734] = &I00734;
  core[000735] = 07402; code[000735] = &I00735;
  core[000736] = 07774; code[000736] = &P00736;
  core[000737] = 07770; code[000737] = &P00737;
  core[000740] = 07760; code[000740] = &P00740;
  core[000741] = 07740; code[000741] = &P00741;
  core[000742] = 07700; code[000742] = &P00742;
  core[000743] = 00000; code[000743] = &D00743;
  core[000744] = 00000; code[000744] = &D00744;
  core[000745] = 00000; code[000745] = &D00745;
  core[000746] = 00000; code[000746] = &D00746;
  core[000747] = 01742; code[000747] = &D00747;
  core[000750] = 00000; code[000750] = &D00750;
  core[000751] = 00000; code[000751] = &D00751;
  core[000752] = 00000; code[000752] = &D00752;
  core[000753] = 00000; code[000753] = &D00753;
  core[000754] = 00000; code[000754] = &D00754;
  core[000755] = 00000; code[000755] = &D00755;
  core[000756] = 00000; code[000756] = &P00756;
  core[002002] = 04203; code[002002] = &L02002;
  core[002003] = 05203; code[002003] = &L02003;
  core[002004] = 01136; code[002004] = &I02004;
  core[002005] = 01222; code[002005] = &I02005;
  core[002006] = 07440; code[002006] = &I02006;
  core[002007] = 07402; code[002007] = &I02007;
  core[002010] = 01224; code[002010] = &I02010;
  core[002011] = 07041; code[002011] = &I02011;
  core[002012] = 01203; code[002012] = &I02012;
  core[002013] = 07440; code[002013] = &I02013;
  core[002014] = 07402; code[002014] = &I02014;
  core[002015] = 03203; code[002015] = &I02015;
  core[002016] = 01136; code[002016] = &I02016;
  core[002017] = 07001; code[002017] = &I02017;
  core[002020] = 03136; code[002020] = &I02020;
  core[002021] = 07410; code[002021] = &I02021;
  core[002022] = 07722; code[002022] = &D02022;
  core[002023] = 07410; code[002023] = &I02023;
  core[002024] = 02003; code[002024] = &D02024;
  core[002025] = 04227; code[002025] = &I02025;
  core[002026] = 07402; code[002026] = &I02026;
  core[002027] = 05227; code[002027] = &L02027;
  core[002030] = 01136; code[002030] = &I02030;
  core[002031] = 01246; code[002031] = &I02031;
  core[002032] = 07440; code[002032] = &I02032;
  core[002033] = 07402; code[002033] = &I02033;
  core[002034] = 01250; code[002034] = &I02034;
  core[002035] = 07041; code[002035] = &I02035;
  core[002036] = 01227; code[002036] = &I02036;
  core[002037] = 07440; code[002037] = &I02037;
  core[002040] = 07402; code[002040] = &I02040;
  core[002041] = 03227; code[002041] = &I02041;
  core[002042] = 01136; code[002042] = &I02042;
  core[002043] = 07001; code[002043] = &I02043;
  core[002044] = 03136; code[002044] = &I02044;
  core[002045] = 07410; code[002045] = &I02045;
  core[002046] = 07721; code[002046] = &D02046;
  core[002047] = 07410; code[002047] = &I02047;
  core[002050] = 02026; code[002050] = &D02050;
  core[002051] = 04254; code[002051] = &I02051;
  core[002052] = 07402; code[002052] = &I02052;
  core[002053] = 07402; code[002053] = &I02053;
  core[002054] = 05254; code[002054] = &L02054;
  core[002055] = 01136; code[002055] = &I02055;
  core[002056] = 01275; code[002056] = &I02056;
  core[002057] = 07440; code[002057] = &I02057;
  core[002060] = 07402; code[002060] = &I02060;
  core[002061] = 01273; code[002061] = &I02061;
  core[002062] = 07041; code[002062] = &I02062;
  core[002063] = 01254; code[002063] = &I02063;
  core[002064] = 07440; code[002064] = &I02064;
  core[002065] = 07402; code[002065] = &I02065;
  core[002066] = 03254; code[002066] = &I02066;
  core[002067] = 01136; code[002067] = &I02067;
  core[002070] = 07001; code[002070] = &I02070;
  core[002071] = 03136; code[002071] = &I02071;
  core[002072] = 07410; code[002072] = &I02072;
  core[002073] = 02052; code[002073] = &D02073;
  core[002074] = 07410; code[002074] = &I02074;
  core[002075] = 07720; code[002075] = &D02075;
  core[002076] = 04302; code[002076] = &I02076;
  core[002077] = 07402; code[002077] = &I02077;
  core[002100] = 07402; code[002100] = &I02100;
  core[002101] = 07402; code[002101] = &I02101;
  core[002102] = 05302; code[002102] = &L02102;
  core[002103] = 01136; code[002103] = &I02103;
  core[002104] = 01323; code[002104] = &I02104;
  core[002105] = 07440; code[002105] = &I02105;
  core[002106] = 07402; code[002106] = &I02106;
  core[002107] = 01321; code[002107] = &I02107;
  core[002110] = 07041; code[002110] = &I02110;
  core[002111] = 01302; code[002111] = &I02111;
  core[002112] = 07440; code[002112] = &I02112;
  core[002113] = 07402; code[002113] = &I02113;
  core[002114] = 03302; code[002114] = &I02114;
  core[002115] = 01136; code[002115] = &I02115;
  core[002116] = 07001; code[002116] = &I02116;
  core[002117] = 03136; code[002117] = &I02117;
  core[002120] = 07410; code[002120] = &I02120;
  core[002121] = 02077; code[002121] = &D02121;
  core[002122] = 07410; code[002122] = &I02122;
  core[002123] = 07717; code[002123] = &D02123;
  core[002124] = 04330; code[002124] = &I02124;
  core[002125] = 07402; code[002125] = &I02125;
  core[002126] = 07402; code[002126] = &I02126;
  core[002127] = 07402; code[002127] = &I02127;
  core[002130] = 05330; code[002130] = &L02130;
  core[002131] = 01136; code[002131] = &I02131;
  core[002132] = 01351; code[002132] = &I02132;
  core[002133] = 07440; code[002133] = &I02133;
  core[002134] = 07402; code[002134] = &I02134;
  core[002135] = 01347; code[002135] = &I02135;
  core[002136] = 07041; code[002136] = &I02136;
  core[002137] = 01330; code[002137] = &I02137;
  core[002140] = 07440; code[002140] = &I02140;
  core[002141] = 07402; code[002141] = &I02141;
  core[002142] = 03330; code[002142] = &I02142;
  core[002143] = 01136; code[002143] = &I02143;
  core[002144] = 07001; code[002144] = &I02144;
  core[002145] = 03136; code[002145] = &I02145;
  core[002146] = 07410; code[002146] = &I02146;
  core[002147] = 02125; code[002147] = &D02147;
  core[002150] = 07410; code[002150] = &I02150;
  core[002151] = 07716; code[002151] = &D02151;
  core[002152] = 04356; code[002152] = &I02152;
  core[002153] = 07402; code[002153] = &I02153;
  core[002154] = 07402; code[002154] = &I02154;
  core[002155] = 07402; code[002155] = &I02155;
  core[002156] = 05356; code[002156] = &L02156;
  core[002157] = 01136; code[002157] = &I02157;
  core[002160] = 01377; code[002160] = &I02160;
  core[002161] = 07440; code[002161] = &I02161;
  core[002162] = 07402; code[002162] = &I02162;
  core[002163] = 01375; code[002163] = &I02163;
  core[002164] = 07041; code[002164] = &I02164;
  core[002165] = 01356; code[002165] = &I02165;
  core[002166] = 07440; code[002166] = &I02166;
  core[002167] = 07402; code[002167] = &I02167;
  core[002170] = 03356; code[002170] = &I02170;
  core[002171] = 01136; code[002171] = &I02171;
  core[002172] = 07001; code[002172] = &I02172;
  core[002173] = 03136; code[002173] = &I02173;
  core[002174] = 07410; code[002174] = &I02174;
  core[002175] = 02153; code[002175] = &D02175;
  core[002176] = 07410; code[002176] = &I02176;
  core[002177] = 07715; code[002177] = &D02177;
  core[002200] = 07000; code[002200] = &I02200;
  core[002201] = 04202; code[002201] = &I02201;
  core[002202] = 05202; code[002202] = &L02202;
  core[002203] = 01136; code[002203] = &I02203;
  core[002204] = 01221; code[002204] = &I02204;
  core[002205] = 07440; code[002205] = &I02205;
  core[002206] = 07402; code[002206] = &I02206;
  core[002207] = 01202; code[002207] = &I02207;
  core[002210] = 07041; code[002210] = &I02210;
  core[002211] = 01223; code[002211] = &I02211;
  core[002212] = 07440; code[002212] = &I02212;
  core[002213] = 07402; code[002213] = &I02213;
  core[002214] = 03202; code[002214] = &I02214;
  core[002215] = 01136; code[002215] = &I02215;
  core[002216] = 07001; code[002216] = &I02216;
  core[002217] = 03136; code[002217] = &I02217;
  core[002220] = 07410; code[002220] = &I02220;
  core[002221] = 07714; code[002221] = &D02221;
  core[002222] = 07410; code[002222] = &I02222;
  core[002223] = 02202; code[002223] = &D02223;
  core[002224] = 04226; code[002224] = &I02224;
  core[002225] = 07402; code[002225] = &D02225;
  core[002226] = 05226; code[002226] = &L02226;
  core[002227] = 01136; code[002227] = &I02227;
  core[002230] = 01245; code[002230] = &I02230;
  core[002231] = 07440; code[002231] = &I02231;
  core[002232] = 07402; code[002232] = &I02232;
  core[002233] = 01247; code[002233] = &I02233;
  core[002234] = 07041; code[002234] = &I02234;
  core[002235] = 01226; code[002235] = &I02235;
  core[002236] = 07440; code[002236] = &I02236;
  core[002237] = 07402; code[002237] = &I02237;
  core[002240] = 03226; code[002240] = &I02240;
  core[002241] = 01136; code[002241] = &I02241;
  core[002242] = 07001; code[002242] = &I02242;
  core[002243] = 03136; code[002243] = &I02243;
  core[002244] = 07410; code[002244] = &I02244;
  core[002245] = 07713; code[002245] = &D02245;
  core[002246] = 07410; code[002246] = &I02246;
  core[002247] = 02225; code[002247] = &D02247;
  core[002250] = 04253; code[002250] = &I02250;
  core[002251] = 07402; code[002251] = &D02251;
  core[002252] = 07402; code[002252] = &I02252;
  core[002253] = 05253; code[002253] = &L02253;
  core[002254] = 01136; code[002254] = &I02254;
  core[002255] = 01274; code[002255] = &I02255;
  core[002256] = 07440; code[002256] = &I02256;
  core[002257] = 07402; code[002257] = &I02257;
  core[002260] = 01253; code[002260] = &I02260;
  core[002261] = 07041; code[002261] = &I02261;
  core[002262] = 01272; code[002262] = &I02262;
  core[002263] = 07440; code[002263] = &I02263;
  core[002264] = 07402; code[002264] = &I02264;
  core[002265] = 03253; code[002265] = &I02265;
  core[002266] = 01136; code[002266] = &I02266;
  core[002267] = 07001; code[002267] = &I02267;
  core[002270] = 03136; code[002270] = &I02270;
  core[002271] = 07410; code[002271] = &I02271;
  core[002272] = 02251; code[002272] = &D02272;
  core[002273] = 07410; code[002273] = &I02273;
  core[002274] = 07712; code[002274] = &D02274;
  core[002275] = 04301; code[002275] = &I02275;
  core[002276] = 07402; code[002276] = &D02276;
  core[002277] = 07402; code[002277] = &I02277;
  core[002300] = 07402; code[002300] = &I02300;
  core[002301] = 05301; code[002301] = &L02301;
  core[002302] = 01136; code[002302] = &I02302;
  core[002303] = 01322; code[002303] = &I02303;
  core[002304] = 07440; code[002304] = &I02304;
  core[002305] = 07402; code[002305] = &I02305;
  core[002306] = 01301; code[002306] = &I02306;
  core[002307] = 07041; code[002307] = &I02307;
  core[002310] = 01320; code[002310] = &I02310;
  core[002311] = 07440; code[002311] = &I02311;
  core[002312] = 07402; code[002312] = &I02312;
  core[002313] = 03301; code[002313] = &I02313;
  core[002314] = 01136; code[002314] = &I02314;
  core[002315] = 07001; code[002315] = &I02315;
  core[002316] = 03136; code[002316] = &I02316;
  core[002317] = 07410; code[002317] = &I02317;
  core[002320] = 02276; code[002320] = &D02320;
  core[002321] = 07410; code[002321] = &I02321;
  core[002322] = 07711; code[002322] = &D02322;
  core[002323] = 04330; code[002323] = &I02323;
  core[002324] = 07402; code[002324] = &D02324;
  core[002325] = 07402; code[002325] = &I02325;
  core[002326] = 07402; code[002326] = &I02326;
  core[002327] = 07402; code[002327] = &I02327;
  core[002330] = 05330; code[002330] = &L02330;
  core[002331] = 01136; code[002331] = &I02331;
  core[002332] = 01351; code[002332] = &I02332;
  core[002333] = 07440; code[002333] = &I02333;
  core[002334] = 07402; code[002334] = &I02334;
  core[002335] = 01330; code[002335] = &I02335;
  core[002336] = 07041; code[002336] = &I02336;
  core[002337] = 01347; code[002337] = &I02337;
  core[002340] = 07440; code[002340] = &I02340;
  core[002341] = 07402; code[002341] = &I02341;
  core[002342] = 03330; code[002342] = &I02342;
  core[002343] = 01136; code[002343] = &I02343;
  core[002344] = 07001; code[002344] = &I02344;
  core[002345] = 03136; code[002345] = &I02345;
  core[002346] = 07410; code[002346] = &I02346;
  core[002347] = 02324; code[002347] = &D02347;
  core[002350] = 07410; code[002350] = &I02350;
  core[002351] = 07710; code[002351] = &D02351;
  core[002352] = 04356; code[002352] = &I02352;
  core[002353] = 07402; code[002353] = &D02353;
  core[002354] = 07402; code[002354] = &I02354;
  core[002355] = 07402; code[002355] = &I02355;
  core[002356] = 05356; code[002356] = &L02356;
  core[002357] = 01136; code[002357] = &I02357;
  core[002360] = 01377; code[002360] = &I02360;
  core[002361] = 07440; code[002361] = &I02361;
  core[002362] = 07402; code[002362] = &I02362;
  core[002363] = 01356; code[002363] = &I02363;
  core[002364] = 07041; code[002364] = &I02364;
  core[002365] = 01375; code[002365] = &I02365;
  core[002366] = 07440; code[002366] = &I02366;
  core[002367] = 07402; code[002367] = &I02367;
  core[002370] = 03356; code[002370] = &I02370;
  core[002371] = 01136; code[002371] = &I02371;
  core[002372] = 07001; code[002372] = &I02372;
  core[002373] = 03136; code[002373] = &I02373;
  core[002374] = 07410; code[002374] = &I02374;
  core[002375] = 02353; code[002375] = &D02375;
  core[002376] = 07410; code[002376] = &I02376;
  core[002377] = 07707; code[002377] = &D02377;
  core[002400] = 01205; code[002400] = &I02400;
  core[002401] = 03455; code[002401] = &I02401;
  core[002402] = 01206; code[002402] = &I02402;
  core[002403] = 03423; code[002403] = &I02403;
  core[002404] = 05423; code[002404] = &I02404;
  core[002405] = 05537; code[002405] = &D02405;
  core[002406] = 04454; code[002406] = &D02406;
  core[002410] = 01136; code[002410] = &L02410;
  core[002411] = 01233; code[002411] = &I02411;
  core[002412] = 07440; code[002412] = &I02412;
  core[002413] = 07402; code[002413] = &I02413;
  core[002414] = 01454; code[002414] = &I02414;
  core[002415] = 01054; code[002415] = &I02415;
  core[002416] = 07440; code[002416] = &I02416;
  core[002417] = 07402; code[002417] = &I02417;
  core[002420] = 03454; code[002420] = &I02420;
  core[002421] = 01136; code[002421] = &I02421;
  core[002422] = 07001; code[002422] = &I02422;
  core[002423] = 03136; code[002423] = &I02423;
  core[002424] = 01231; code[002424] = &I02424;
  core[002425] = 03454; code[002425] = &I02425;
  core[002426] = 01232; code[002426] = &I02426;
  core[002427] = 03424; code[002427] = &I02427;
  core[002430] = 05424; code[002430] = &I02430;
  core[002431] = 05540; code[002431] = &D02431;
  core[002432] = 04453; code[002432] = &D02432;
  core[002433] = 07706; code[002433] = &D02433;
  core[002440] = 01136; code[002440] = &L02440;
  core[002441] = 01263; code[002441] = &I02441;
  core[002442] = 07440; code[002442] = &I02442;
  core[002443] = 07402; code[002443] = &I02443;
  core[002444] = 01453; code[002444] = &I02444;
  core[002445] = 01053; code[002445] = &I02445;
  core[002446] = 07440; code[002446] = &I02446;
  core[002447] = 07402; code[002447] = &I02447;
  core[002450] = 03453; code[002450] = &I02450;
  core[002451] = 01136; code[002451] = &I02451;
  core[002452] = 07001; code[002452] = &I02452;
  core[002453] = 03136; code[002453] = &I02453;
  core[002454] = 01261; code[002454] = &I02454;
  core[002455] = 03664; code[002455] = &I02455;
  core[002456] = 01262; code[002456] = &I02456;
  core[002457] = 03425; code[002457] = &I02457;
  core[002460] = 05425; code[002460] = &I02460;
  core[002461] = 05541; code[002461] = &D02461;
  core[002462] = 04452; code[002462] = &D02462;
  core[002463] = 07705; code[002463] = &D02463;
  core[002464] = 07774; code[002464] = &P02464;
  core[002470] = 01136; code[002470] = &L02470;
  core[002471] = 01313; code[002471] = &I02471;
  core[002472] = 07440; code[002472] = &I02472;
  core[002473] = 07402; code[002473] = &I02473;
  core[002474] = 01452; code[002474] = &I02474;
  core[002475] = 01052; code[002475] = &I02475;
  core[002476] = 07440; code[002476] = &I02476;
  core[002477] = 07402; code[002477] = &I02477;
  core[002500] = 03452; code[002500] = &I02500;
  core[002501] = 01136; code[002501] = &I02501;
  core[002502] = 07001; code[002502] = &I02502;
  core[002503] = 03136; code[002503] = &I02503;
  core[002504] = 01311; code[002504] = &I02504;
  core[002505] = 03714; code[002505] = &I02505;
  core[002506] = 01312; code[002506] = &I02506;
  core[002507] = 03426; code[002507] = &I02507;
  core[002510] = 05426; code[002510] = &I02510;
  core[002511] = 05542; code[002511] = &D02511;
  core[002512] = 04451; code[002512] = &D02512;
  core[002513] = 07704; code[002513] = &D02513;
  core[002514] = 07770; code[002514] = &P02514;
  core[002520] = 01136; code[002520] = &L02520;
  core[002521] = 01343; code[002521] = &I02521;
  core[002522] = 07440; code[002522] = &I02522;
  core[002523] = 07402; code[002523] = &I02523;
  core[002524] = 01451; code[002524] = &I02524;
  core[002525] = 01051; code[002525] = &I02525;
  core[002526] = 07440; code[002526] = &I02526;
  core[002527] = 07402; code[002527] = &I02527;
  core[002530] = 03451; code[002530] = &I02530;
  core[002531] = 01136; code[002531] = &I02531;
  core[002532] = 07001; code[002532] = &I02532;
  core[002533] = 03136; code[002533] = &I02533;
  core[002534] = 01341; code[002534] = &I02534;
  core[002535] = 03744; code[002535] = &I02535;
  core[002536] = 01342; code[002536] = &I02536;
  core[002537] = 03427; code[002537] = &I02537;
  core[002540] = 05427; code[002540] = &I02540;
  core[002541] = 05543; code[002541] = &D02541;
  core[002542] = 04450; code[002542] = &D02542;
  core[002543] = 07703; code[002543] = &D02543;
  core[002544] = 07760; code[002544] = &P02544;
  core[002600] = 01136; code[002600] = &L02600;
  core[002601] = 01223; code[002601] = &I02601;
  core[002602] = 07440; code[002602] = &I02602;
  core[002603] = 07402; code[002603] = &I02603;
  core[002604] = 01450; code[002604] = &I02604;
  core[002605] = 01050; code[002605] = &I02605;
  core[002606] = 07440; code[002606] = &I02606;
  core[002607] = 07402; code[002607] = &I02607;
  core[002610] = 03450; code[002610] = &I02610;
  core[002611] = 01136; code[002611] = &I02611;
  core[002612] = 07001; code[002612] = &I02612;
  core[002613] = 03136; code[002613] = &I02613;
  core[002614] = 01221; code[002614] = &I02614;
  core[002615] = 03624; code[002615] = &I02615;
  core[002616] = 01222; code[002616] = &I02616;
  core[002617] = 03430; code[002617] = &I02617;
  core[002620] = 05430; code[002620] = &I02620;
  core[002621] = 05544; code[002621] = &D02621;
  core[002622] = 04447; code[002622] = &D02622;
  core[002623] = 07702; code[002623] = &D02623;
  core[002624] = 07740; code[002624] = &P02624;
  core[002630] = 01136; code[002630] = &L02630;
  core[002631] = 01253; code[002631] = &I02631;
  core[002632] = 07440; code[002632] = &I02632;
  core[002633] = 07402; code[002633] = &I02633;
  core[002634] = 01447; code[002634] = &I02634;
  core[002635] = 01047; code[002635] = &I02635;
  core[002636] = 07440; code[002636] = &I02636;
  core[002637] = 07402; code[002637] = &I02637;
  core[002640] = 03447; code[002640] = &I02640;
  core[002641] = 01136; code[002641] = &I02641;
  core[002642] = 07001; code[002642] = &I02642;
  core[002643] = 03136; code[002643] = &I02643;
  core[002644] = 01251; code[002644] = &I02644;
  core[002645] = 03654; code[002645] = &I02645;
  core[002646] = 01252; code[002646] = &I02646;
  core[002647] = 03431; code[002647] = &I02647;
  core[002650] = 05431; code[002650] = &I02650;
  core[002651] = 05545; code[002651] = &D02651;
  core[002652] = 04446; code[002652] = &D02652;
  core[002653] = 07701; code[002653] = &D02653;
  core[002654] = 07700; code[002654] = &P02654;
  core[002660] = 01136; code[002660] = &L02660;
  core[002661] = 01303; code[002661] = &I02661;
  core[002662] = 07440; code[002662] = &I02662;
  core[002663] = 07402; code[002663] = &I02663;
  core[002664] = 01446; code[002664] = &I02664;
  core[002665] = 01046; code[002665] = &I02665;
  core[002666] = 07440; code[002666] = &I02666;
  core[002667] = 07402; code[002667] = &I02667;
  core[002670] = 03446; code[002670] = &I02670;
  core[002671] = 01136; code[002671] = &I02671;
  core[002672] = 07001; code[002672] = &I02672;
  core[002673] = 03136; code[002673] = &I02673;
  core[002674] = 01301; code[002674] = &I02674;
  core[002675] = 03704; code[002675] = &I02675;
  core[002676] = 01302; code[002676] = &I02676;
  core[002677] = 03432; code[002677] = &I02677;
  core[002700] = 05432; code[002700] = &I02700;
  core[002701] = 05546; code[002701] = &D02701;
  core[002702] = 04445; code[002702] = &D02702;
  core[002703] = 07700; code[002703] = &D02703;
  core[002704] = 07600; code[002704] = &P02704;
  core[002710] = 01136; code[002710] = &L02710;
  core[002711] = 01333; code[002711] = &I02711;
  core[002712] = 07440; code[002712] = &I02712;
  core[002713] = 07402; code[002713] = &I02713;
  core[002714] = 01445; code[002714] = &I02714;
  core[002715] = 01045; code[002715] = &I02715;
  core[002716] = 07440; code[002716] = &I02716;
  core[002717] = 07402; code[002717] = &I02717;
  core[002720] = 03445; code[002720] = &I02720;
  core[002721] = 01136; code[002721] = &I02721;
  core[002722] = 07001; code[002722] = &I02722;
  core[002723] = 03136; code[002723] = &I02723;
  core[002724] = 01331; code[002724] = &I02724;
  core[002725] = 03734; code[002725] = &I02725;
  core[002726] = 01332; code[002726] = &I02726;
  core[002727] = 03433; code[002727] = &I02727;
  core[002730] = 05433; code[002730] = &I02730;
  core[002731] = 05547; code[002731] = &D02731;
  core[002732] = 04444; code[002732] = &D02732;
  core[002733] = 07677; code[002733] = &D02733;
  core[002734] = 07400; code[002734] = &P02734;
  core[002740] = 01136; code[002740] = &L02740;
  core[002741] = 01363; code[002741] = &I02741;
  core[002742] = 07440; code[002742] = &I02742;
  core[002743] = 07402; code[002743] = &I02743;
  core[002744] = 01444; code[002744] = &I02744;
  core[002745] = 01044; code[002745] = &I02745;
  core[002746] = 07440; code[002746] = &I02746;
  core[002747] = 07402; code[002747] = &I02747;
  core[002750] = 03444; code[002750] = &I02750;
  core[002751] = 01136; code[002751] = &I02751;
  core[002752] = 07001; code[002752] = &I02752;
  core[002753] = 03136; code[002753] = &I02753;
  core[002754] = 01361; code[002754] = &I02754;
  core[002755] = 03764; code[002755] = &I02755;
  core[002756] = 01362; code[002756] = &I02756;
  core[002757] = 03434; code[002757] = &I02757;
  core[002760] = 05434; code[002760] = &I02760;
  core[002761] = 05550; code[002761] = &D02761;
  core[002762] = 04443; code[002762] = &D02762;
  core[002763] = 07676; code[002763] = &D02763;
  core[002764] = 07000; code[002764] = &P02764;
  core[003000] = 01136; code[003000] = &L03000;
  core[003001] = 01223; code[003001] = &I03001;
  core[003002] = 07440; code[003002] = &I03002;
  core[003003] = 07402; code[003003] = &I03003;
  core[003004] = 01443; code[003004] = &I03004;
  core[003005] = 01043; code[003005] = &I03005;
  core[003006] = 07440; code[003006] = &I03006;
  core[003007] = 07402; code[003007] = &I03007;
  core[003010] = 03443; code[003010] = &I03010;
  core[003011] = 01136; code[003011] = &I03011;
  core[003012] = 07001; code[003012] = &I03012;
  core[003013] = 03136; code[003013] = &I03013;
  core[003014] = 01221; code[003014] = &I03014;
  core[003015] = 03624; code[003015] = &I03015;
  core[003016] = 01222; code[003016] = &I03016;
  core[003017] = 03435; code[003017] = &I03017;
  core[003020] = 05435; code[003020] = &I03020;
  core[003021] = 05551; code[003021] = &D03021;
  core[003022] = 04442; code[003022] = &D03022;
  core[003023] = 07675; code[003023] = &D03023;
  core[003024] = 06000; code[003024] = &P03024;
  core[003030] = 01136; code[003030] = &L03030;
  core[003031] = 01253; code[003031] = &I03031;
  core[003032] = 07440; code[003032] = &I03032;
  core[003033] = 07402; code[003033] = &I03033;
  core[003034] = 01442; code[003034] = &I03034;
  core[003035] = 01042; code[003035] = &I03035;
  core[003036] = 07440; code[003036] = &I03036;
  core[003037] = 07402; code[003037] = &I03037;
  core[003040] = 03442; code[003040] = &I03040;
  core[003041] = 01136; code[003041] = &I03041;
  core[003042] = 07001; code[003042] = &I03042;
  core[003043] = 03136; code[003043] = &I03043;
  core[003044] = 01251; code[003044] = &I03044;
  core[003045] = 03654; code[003045] = &I03045;
  core[003046] = 01252; code[003046] = &I03046;
  core[003047] = 03437; code[003047] = &I03047;
  core[003050] = 05437; code[003050] = &I03050;
  core[003051] = 05552; code[003051] = &D03051;
  core[003052] = 04436; code[003052] = &D03052;
  core[003053] = 07674; code[003053] = &D03053;
  core[003054] = 04001; code[003054] = &P03054;
  core[003060] = 01136; code[003060] = &L03060;
  core[003061] = 01303; code[003061] = &I03061;
  core[003062] = 07440; code[003062] = &I03062;
  core[003063] = 07402; code[003063] = &I03063;
  core[003064] = 01436; code[003064] = &I03064;
  core[003065] = 01036; code[003065] = &I03065;
  core[003066] = 07440; code[003066] = &I03066;
  core[003067] = 07402; code[003067] = &I03067;
  core[003070] = 03436; code[003070] = &I03070;
  core[003071] = 01136; code[003071] = &I03071;
  core[003072] = 07001; code[003072] = &I03072;
  core[003073] = 03136; code[003073] = &I03073;
  core[003074] = 01301; code[003074] = &I03074;
  core[003075] = 03704; code[003075] = &I03075;
  core[003076] = 01302; code[003076] = &I03076;
  core[003077] = 03442; code[003077] = &I03077;
  core[003100] = 05442; code[003100] = &I03100;
  core[003101] = 05553; code[003101] = &D03101;
  core[003102] = 04435; code[003102] = &D03102;
  core[003103] = 07673; code[003103] = &D03103;
  core[003104] = 02001; code[003104] = &P03104;
  core[003110] = 01136; code[003110] = &L03110;
  core[003111] = 01333; code[003111] = &I03111;
  core[003112] = 07440; code[003112] = &I03112;
  core[003113] = 07402; code[003113] = &I03113;
  core[003114] = 01435; code[003114] = &I03114;
  core[003115] = 01035; code[003115] = &I03115;
  core[003116] = 07440; code[003116] = &I03116;
  core[003117] = 07402; code[003117] = &I03117;
  core[003120] = 03435; code[003120] = &I03120;
  core[003121] = 01136; code[003121] = &I03121;
  core[003122] = 07001; code[003122] = &I03122;
  core[003123] = 03136; code[003123] = &I03123;
  core[003124] = 01331; code[003124] = &I03124;
  core[003125] = 03734; code[003125] = &I03125;
  core[003126] = 01332; code[003126] = &I03126;
  core[003127] = 03443; code[003127] = &I03127;
  core[003130] = 05443; code[003130] = &I03130;
  core[003131] = 05554; code[003131] = &D03131;
  core[003132] = 04434; code[003132] = &D03132;
  core[003133] = 07672; code[003133] = &D03133;
  core[003134] = 01001; code[003134] = &P03134;
  core[003140] = 01136; code[003140] = &L03140;
  core[003141] = 01363; code[003141] = &I03141;
  core[003142] = 07440; code[003142] = &I03142;
  core[003143] = 07402; code[003143] = &I03143;
  core[003144] = 01434; code[003144] = &I03144;
  core[003145] = 01034; code[003145] = &I03145;
  core[003146] = 07440; code[003146] = &I03146;
  core[003147] = 07402; code[003147] = &I03147;
  core[003150] = 03434; code[003150] = &I03150;
  core[003151] = 01136; code[003151] = &I03151;
  core[003152] = 07001; code[003152] = &I03152;
  core[003153] = 03136; code[003153] = &I03153;
  core[003154] = 01361; code[003154] = &I03154;
  core[003155] = 03764; code[003155] = &I03155;
  core[003156] = 01362; code[003156] = &I03156;
  core[003157] = 03444; code[003157] = &I03157;
  core[003160] = 05444; code[003160] = &I03160;
  core[003161] = 05555; code[003161] = &D03161;
  core[003162] = 04433; code[003162] = &D03162;
  core[003163] = 07671; code[003163] = &D03163;
  core[003164] = 00401; code[003164] = &P03164;
  core[003200] = 01136; code[003200] = &L03200;
  core[003201] = 01223; code[003201] = &D03201;
  core[003202] = 07440; code[003202] = &I03202;
  core[003203] = 07402; code[003203] = &I03203;
  core[003204] = 01433; code[003204] = &I03204;
  core[003205] = 01033; code[003205] = &I03205;
  core[003206] = 07440; code[003206] = &I03206;
  core[003207] = 07402; code[003207] = &I03207;
  core[003210] = 03433; code[003210] = &I03210;
  core[003211] = 01136; code[003211] = &I03211;
  core[003212] = 07001; code[003212] = &I03212;
  core[003213] = 03136; code[003213] = &I03213;
  core[003214] = 01221; code[003214] = &I03214;
  core[003215] = 03624; code[003215] = &I03215;
  core[003216] = 01222; code[003216] = &I03216;
  core[003217] = 03445; code[003217] = &I03217;
  core[003220] = 05445; code[003220] = &I03220;
  core[003221] = 05556; code[003221] = &D03221;
  core[003222] = 04432; code[003222] = &D03222;
  core[003223] = 07670; code[003223] = &D03223;
  core[003224] = 00201; code[003224] = &P03224;
  core[003230] = 01136; code[003230] = &L03230;
  core[003231] = 01253; code[003231] = &I03231;
  core[003232] = 07440; code[003232] = &I03232;
  core[003233] = 07402; code[003233] = &I03233;
  core[003234] = 01432; code[003234] = &I03234;
  core[003235] = 01032; code[003235] = &I03235;
  core[003236] = 07440; code[003236] = &I03236;
  core[003237] = 07402; code[003237] = &I03237;
  core[003240] = 03432; code[003240] = &I03240;
  core[003241] = 01136; code[003241] = &I03241;
  core[003242] = 07001; code[003242] = &I03242;
  core[003243] = 03136; code[003243] = &I03243;
  core[003244] = 01251; code[003244] = &I03244;
  core[003245] = 03654; code[003245] = &I03245;
  core[003246] = 01252; code[003246] = &I03246;
  core[003247] = 03446; code[003247] = &I03247;
  core[003250] = 05446; code[003250] = &I03250;
  core[003251] = 05557; code[003251] = &D03251;
  core[003252] = 04431; code[003252] = &D03252;
  core[003253] = 07667; code[003253] = &D03253;
  core[003254] = 00101; code[003254] = &P03254;
  core[003260] = 01136; code[003260] = &L03260;
  core[003261] = 01303; code[003261] = &I03261;
  core[003262] = 07440; code[003262] = &I03262;
  core[003263] = 07402; code[003263] = &I03263;
  core[003264] = 01431; code[003264] = &I03264;
  core[003265] = 01031; code[003265] = &I03265;
  core[003266] = 07440; code[003266] = &I03266;
  core[003267] = 07402; code[003267] = &I03267;
  core[003270] = 03431; code[003270] = &I03270;
  core[003271] = 01136; code[003271] = &I03271;
  core[003272] = 07001; code[003272] = &I03272;
  core[003273] = 03136; code[003273] = &I03273;
  core[003274] = 01301; code[003274] = &I03274;
  core[003275] = 03704; code[003275] = &I03275;
  core[003276] = 01302; code[003276] = &I03276;
  core[003277] = 03447; code[003277] = &I03277;
  core[003300] = 05447; code[003300] = &I03300;
  core[003301] = 05560; code[003301] = &D03301;
  core[003302] = 04430; code[003302] = &D03302;
  core[003303] = 07666; code[003303] = &D03303;
  core[003304] = 00041; code[003304] = &P03304;
  core[003310] = 01136; code[003310] = &L03310;
  core[003311] = 01333; code[003311] = &I03311;
  core[003312] = 07440; code[003312] = &I03312;
  core[003313] = 07402; code[003313] = &I03313;
  core[003314] = 01430; code[003314] = &I03314;
  core[003315] = 01030; code[003315] = &I03315;
  core[003316] = 07440; code[003316] = &I03316;
  core[003317] = 07402; code[003317] = &I03317;
  core[003320] = 03430; code[003320] = &I03320;
  core[003321] = 01136; code[003321] = &I03321;
  core[003322] = 07001; code[003322] = &I03322;
  core[003323] = 03136; code[003323] = &I03323;
  core[003324] = 01331; code[003324] = &I03324;
  core[003325] = 03734; code[003325] = &I03325;
  core[003326] = 01332; code[003326] = &I03326;
  core[003327] = 03450; code[003327] = &I03327;
  core[003330] = 05450; code[003330] = &I03330;
  core[003331] = 05561; code[003331] = &D03331;
  core[003332] = 04427; code[003332] = &D03332;
  core[003333] = 07665; code[003333] = &D03333;
  core[003334] = 00021; code[003334] = &P03334;
  core[003340] = 01136; code[003340] = &L03340;
  core[003341] = 01363; code[003341] = &I03341;
  core[003342] = 07440; code[003342] = &I03342;
  core[003343] = 07402; code[003343] = &I03343;
  core[003344] = 01427; code[003344] = &I03344;
  core[003345] = 01027; code[003345] = &I03345;
  core[003346] = 07440; code[003346] = &I03346;
  core[003347] = 07402; code[003347] = &I03347;
  core[003350] = 03427; code[003350] = &I03350;
  core[003351] = 01136; code[003351] = &I03351;
  core[003352] = 07001; code[003352] = &I03352;
  core[003353] = 03136; code[003353] = &I03353;
  core[003354] = 01361; code[003354] = &I03354;
  core[003355] = 03764; code[003355] = &I03355;
  core[003356] = 01362; code[003356] = &I03356;
  core[003357] = 03451; code[003357] = &I03357;
  core[003360] = 05451; code[003360] = &I03360;
  core[003361] = 05562; code[003361] = &D03361;
  core[003362] = 04426; code[003362] = &D03362;
  core[003363] = 07664; code[003363] = &D03363;
  core[003364] = 00011; code[003364] = &P03364;
  core[003400] = 01136; code[003400] = &L03400;
  core[003401] = 01223; code[003401] = &I03401;
  core[003402] = 07440; code[003402] = &I03402;
  core[003403] = 07402; code[003403] = &I03403;
  core[003404] = 01426; code[003404] = &I03404;
  core[003405] = 01026; code[003405] = &I03405;
  core[003406] = 07440; code[003406] = &I03406;
  core[003407] = 07402; code[003407] = &D03407;
  core[003410] = 03426; code[003410] = &D03410;
  core[003411] = 01136; code[003411] = &I03411;
  core[003412] = 07001; code[003412] = &I03412;
  core[003413] = 03136; code[003413] = &I03413;
  core[003414] = 01221; code[003414] = &I03414;
  core[003415] = 03624; code[003415] = &I03415;
  core[003416] = 01222; code[003416] = &I03416;
  core[003417] = 03452; code[003417] = &I03417;
  core[003420] = 05452; code[003420] = &I03420;
  core[003421] = 05563; code[003421] = &D03421;
  core[003422] = 04425; code[003422] = &D03422;
  core[003423] = 07663; code[003423] = &D03423;
  core[003424] = 00005; code[003424] = &P03424;
  core[003430] = 01136; code[003430] = &L03430;
  core[003431] = 01253; code[003431] = &I03431;
  core[003432] = 07440; code[003432] = &I03432;
  core[003433] = 07402; code[003433] = &I03433;
  core[003434] = 01425; code[003434] = &I03434;
  core[003435] = 01025; code[003435] = &I03435;
  core[003436] = 07440; code[003436] = &I03436;
  core[003437] = 07402; code[003437] = &I03437;
  core[003440] = 03425; code[003440] = &I03440;
  core[003441] = 01136; code[003441] = &I03441;
  core[003442] = 07001; code[003442] = &I03442;
  core[003443] = 03136; code[003443] = &I03443;
  core[003444] = 01251; code[003444] = &I03444;
  core[003445] = 03654; code[003445] = &I03445;
  core[003446] = 01252; code[003446] = &I03446;
  core[003447] = 03453; code[003447] = &I03447;
  core[003450] = 05453; code[003450] = &I03450;
  core[003451] = 05564; code[003451] = &D03451;
  core[003452] = 04424; code[003452] = &D03452;
  core[003453] = 07662; code[003453] = &D03453;
  core[003454] = 00003; code[003454] = &P03454;
  core[003460] = 01136; code[003460] = &L03460;
  core[003461] = 01303; code[003461] = &I03461;
  core[003462] = 07440; code[003462] = &I03462;
  core[003463] = 07402; code[003463] = &I03463;
  core[003464] = 01424; code[003464] = &I03464;
  core[003465] = 01024; code[003465] = &I03465;
  core[003466] = 07440; code[003466] = &I03466;
  core[003467] = 07402; code[003467] = &I03467;
  core[003470] = 03424; code[003470] = &I03470;
  core[003471] = 01136; code[003471] = &I03471;
  core[003472] = 07001; code[003472] = &I03472;
  core[003473] = 03136; code[003473] = &I03473;
  core[003474] = 01301; code[003474] = &I03474;
  core[003475] = 03424; code[003475] = &I03475;
  core[003476] = 01302; code[003476] = &I03476;
  core[003477] = 03454; code[003477] = &I03477;
  core[003500] = 05454; code[003500] = &I03500;
  core[003501] = 05565; code[003501] = &D03501;
  core[003502] = 04423; code[003502] = &D03502;
  core[003503] = 07661; code[003503] = &D03503;
  core[003510] = 01136; code[003510] = &L03510;
  core[003511] = 01333; code[003511] = &I03511;
  core[003512] = 07440; code[003512] = &I03512;
  core[003513] = 07402; code[003513] = &I03513;
  core[003514] = 01423; code[003514] = &I03514;
  core[003515] = 01023; code[003515] = &I03515;
  core[003516] = 07440; code[003516] = &I03516;
  core[003517] = 07402; code[003517] = &I03517;
  core[003520] = 03423; code[003520] = &I03520;
  core[003521] = 01136; code[003521] = &I03521;
  core[003522] = 07001; code[003522] = &I03522;
  core[003523] = 03136; code[003523] = &I03523;
  core[003524] = 01331; code[003524] = &I03524;
  core[003525] = 03423; code[003525] = &I03525;
  core[003526] = 01332; code[003526] = &I03526;
  core[003527] = 03455; code[003527] = &I03527;
  core[003530] = 05455; code[003530] = &I03530;
  core[003531] = 05566; code[003531] = &D03531;
  core[003532] = 04422; code[003532] = &D03532;
  core[003533] = 07660; code[003533] = &D03533;
  core[003540] = 01136; code[003540] = &L03540;
  core[003541] = 01370; code[003541] = &I03541;
  core[003542] = 07440; code[003542] = &I03542;
  core[003543] = 07402; code[003543] = &I03543;
  core[003544] = 01422; code[003544] = &I03544;
  core[003545] = 01022; code[003545] = &I03545;
  core[003546] = 07440; code[003546] = &I03546;
  core[003547] = 07402; code[003547] = &I03547;
  core[003550] = 03422; code[003550] = &I03550;
  core[003551] = 01371; code[003551] = &I03551;
  core[003552] = 07001; code[003552] = &I03552;
  core[003553] = 03371; code[003553] = &I03553;
  core[003554] = 01371; code[003554] = &I03554;
  core[003555] = 01372; code[003555] = &I03555;
  core[003556] = 07640; code[003556] = &I03556;
  core[003557] = 05766; code[003557] = &I03557;
  core[003560] = 03371; code[003560] = &I03560;
  core[003561] = 01367; code[003561] = &I03561;
  core[003562] = 06046; code[003562] = &I03562;
  core[003563] = 06041; code[003563] = &L03563;
  core[003564] = 05363; code[003564] = &I03564;
  core[003565] = 05766; code[003565] = &I03565;
  core[003566] = 04200; code[003566] = &P03566;
  core[003567] = 00207; code[003567] = &D03567;
  core[003570] = 07657; code[003570] = &D03570;
  core[003571] = 00000; code[003571] = &D03571;
  core[003572] = 01200; code[003572] = &D03572;
  core[004200] = 07200; code[004200] = &L04200;
  core[004201] = 03136; code[004201] = &I04201;
  core[004202] = 05203; code[004202] = &I04202;
  core[004203] = 01136; code[004203] = &L04203;
  core[004204] = 07440; code[004204] = &I04204;
  core[004205] = 07402; code[004205] = &I04205;
  core[004206] = 01136; code[004206] = &I04206;
  core[004207] = 07001; code[004207] = &I04207;
  core[004210] = 03136; code[004210] = &I04210;
  core[004211] = 05213; code[004211] = &I04211;
  core[004212] = 07402; code[004212] = &I04212;
  core[004213] = 01136; code[004213] = &L04213;
  core[004214] = 01113; code[004214] = &I04214;
  core[004215] = 07440; code[004215] = &I04215;
  core[004216] = 07402; code[004216] = &I04216;
  core[004217] = 01136; code[004217] = &I04217;
  core[004220] = 07001; code[004220] = &I04220;
  core[004221] = 03136; code[004221] = &I04221;
  core[004222] = 05225; code[004222] = &I04222;
  core[004223] = 07402; code[004223] = &I04223;
  core[004224] = 07402; code[004224] = &I04224;
  core[004225] = 01136; code[004225] = &L04225;
  core[004226] = 01114; code[004226] = &I04226;
  core[004227] = 07440; code[004227] = &I04227;
  core[004230] = 07402; code[004230] = &I04230;
  core[004231] = 01136; code[004231] = &I04231;
  core[004232] = 07001; code[004232] = &I04232;
  core[004233] = 03136; code[004233] = &I04233;
  core[004234] = 05240; code[004234] = &I04234;
  core[004235] = 07402; code[004235] = &I04235;
  core[004236] = 07402; code[004236] = &I04236;
  core[004237] = 07402; code[004237] = &I04237;
  core[004240] = 01136; code[004240] = &L04240;
  core[004241] = 01115; code[004241] = &I04241;
  core[004242] = 07440; code[004242] = &I04242;
  core[004243] = 07402; code[004243] = &I04243;
  core[004244] = 01136; code[004244] = &I04244;
  core[004245] = 07001; code[004245] = &I04245;
  core[004246] = 03136; code[004246] = &I04246;
  core[004247] = 05254; code[004247] = &I04247;
  core[004250] = 07402; code[004250] = &I04250;
  core[004251] = 07402; code[004251] = &I04251;
  core[004252] = 07402; code[004252] = &I04252;
  core[004253] = 07402; code[004253] = &I04253;
  core[004254] = 01136; code[004254] = &L04254;
  core[004255] = 01116; code[004255] = &I04255;
  core[004256] = 07440; code[004256] = &I04256;
  core[004257] = 07402; code[004257] = &I04257;
  core[004260] = 01136; code[004260] = &I04260;
  core[004261] = 07001; code[004261] = &I04261;
  core[004262] = 03136; code[004262] = &I04262;
  core[004263] = 05271; code[004263] = &I04263;
  core[004264] = 07402; code[004264] = &I04264;
  core[004265] = 07402; code[004265] = &I04265;
  core[004266] = 07402; code[004266] = &I04266;
  core[004267] = 07402; code[004267] = &I04267;
  core[004270] = 07402; code[004270] = &I04270;
  core[004271] = 01136; code[004271] = &L04271;
  core[004272] = 01117; code[004272] = &I04272;
  core[004273] = 07440; code[004273] = &I04273;
  core[004274] = 07402; code[004274] = &I04274;
  core[004275] = 01136; code[004275] = &I04275;
  core[004276] = 07001; code[004276] = &I04276;
  core[004277] = 03136; code[004277] = &I04277;
  core[004300] = 05307; code[004300] = &I04300;
  core[004301] = 07402; code[004301] = &I04301;
  core[004302] = 07402; code[004302] = &I04302;
  core[004303] = 07402; code[004303] = &I04303;
  core[004304] = 07402; code[004304] = &I04304;
  core[004305] = 07402; code[004305] = &I04305;
  core[004306] = 07402; code[004306] = &I04306;
  core[004307] = 01136; code[004307] = &L04307;
  core[004310] = 01120; code[004310] = &I04310;
  core[004311] = 07440; code[004311] = &I04311;
  core[004312] = 07402; code[004312] = &I04312;
  core[004313] = 01136; code[004313] = &I04313;
  core[004314] = 07001; code[004314] = &I04314;
  core[004315] = 03136; code[004315] = &I04315;
  core[004316] = 05326; code[004316] = &I04316;
  core[004317] = 07402; code[004317] = &I04317;
  core[004320] = 07402; code[004320] = &I04320;
  core[004321] = 07402; code[004321] = &I04321;
  core[004322] = 07402; code[004322] = &I04322;
  core[004323] = 07402; code[004323] = &I04323;
  core[004324] = 07402; code[004324] = &I04324;
  core[004325] = 07402; code[004325] = &I04325;
  core[004326] = 01136; code[004326] = &L04326;
  core[004327] = 01121; code[004327] = &I04327;
  core[004330] = 07440; code[004330] = &I04330;
  core[004331] = 07402; code[004331] = &I04331;
  core[004332] = 01136; code[004332] = &I04332;
  core[004333] = 07001; code[004333] = &I04333;
  core[004334] = 03136; code[004334] = &I04334;
  core[004335] = 05346; code[004335] = &I04335;
  core[004336] = 07402; code[004336] = &I04336;
  core[004337] = 07402; code[004337] = &I04337;
  core[004340] = 07402; code[004340] = &I04340;
  core[004341] = 07402; code[004341] = &I04341;
  core[004342] = 07402; code[004342] = &I04342;
  core[004343] = 07402; code[004343] = &I04343;
  core[004344] = 07402; code[004344] = &I04344;
  core[004345] = 07402; code[004345] = &I04345;
  core[004346] = 01136; code[004346] = &L04346;
  core[004347] = 01122; code[004347] = &I04347;
  core[004350] = 07440; code[004350] = &I04350;
  core[004351] = 07402; code[004351] = &I04351;
  core[004352] = 01136; code[004352] = &I04352;
  core[004353] = 07001; code[004353] = &I04353;
  core[004354] = 03136; code[004354] = &I04354;
  core[004355] = 05367; code[004355] = &I04355;
  core[004356] = 07402; code[004356] = &I04356;
  core[004357] = 07402; code[004357] = &I04357;
  core[004360] = 07402; code[004360] = &I04360;
  core[004361] = 07402; code[004361] = &I04361;
  core[004362] = 07402; code[004362] = &I04362;
  core[004363] = 07402; code[004363] = &I04363;
  core[004364] = 07402; code[004364] = &I04364;
  core[004365] = 07402; code[004365] = &I04365;
  core[004366] = 07402; code[004366] = &I04366;
  core[004367] = 01136; code[004367] = &L04367;
  core[004370] = 01123; code[004370] = &I04370;
  core[004371] = 07440; code[004371] = &I04371;
  core[004372] = 07402; code[004372] = &I04372;
  core[004373] = 01136; code[004373] = &I04373;
  core[004374] = 07001; code[004374] = &I04374;
  core[004375] = 03136; code[004375] = &I04375;
  core[004376] = 07000; code[004376] = &I04376;
  core[004377] = 07000; code[004377] = &I04377;
  core[004400] = 05201; code[004400] = &I04400;
  core[004401] = 01136; code[004401] = &L04401;
  core[004402] = 01124; code[004402] = &I04402;
  core[004403] = 07440; code[004403] = &I04403;
  core[004404] = 07402; code[004404] = &I04404;
  core[004405] = 01136; code[004405] = &I04405;
  core[004406] = 07001; code[004406] = &I04406;
  core[004407] = 03136; code[004407] = &I04407;
  core[004410] = 05212; code[004410] = &I04410;
  core[004411] = 07402; code[004411] = &I04411;
  core[004412] = 01136; code[004412] = &L04412;
  core[004413] = 01125; code[004413] = &I04413;
  core[004414] = 07440; code[004414] = &I04414;
  core[004415] = 07402; code[004415] = &I04415;
  core[004416] = 01136; code[004416] = &I04416;
  core[004417] = 07001; code[004417] = &I04417;
  core[004420] = 03136; code[004420] = &I04420;
  core[004421] = 05224; code[004421] = &I04421;
  core[004422] = 07402; code[004422] = &I04422;
  core[004423] = 07402; code[004423] = &I04423;
  core[004424] = 01136; code[004424] = &L04424;
  core[004425] = 01126; code[004425] = &I04425;
  core[004426] = 07440; code[004426] = &I04426;
  core[004427] = 07402; code[004427] = &I04427;
  core[004430] = 01136; code[004430] = &I04430;
  core[004431] = 07001; code[004431] = &I04431;
  core[004432] = 03136; code[004432] = &I04432;
  core[004433] = 05237; code[004433] = &I04433;
  core[004434] = 07402; code[004434] = &I04434;
  core[004435] = 07402; code[004435] = &I04435;
  core[004436] = 07402; code[004436] = &I04436;
  core[004437] = 01136; code[004437] = &L04437;
  core[004440] = 01127; code[004440] = &I04440;
  core[004441] = 07440; code[004441] = &I04441;
  core[004442] = 07402; code[004442] = &I04442;
  core[004443] = 01136; code[004443] = &I04443;
  core[004444] = 07001; code[004444] = &I04444;
  core[004445] = 03136; code[004445] = &I04445;
  core[004446] = 05253; code[004446] = &I04446;
  core[004447] = 07402; code[004447] = &I04447;
  core[004450] = 07402; code[004450] = &I04450;
  core[004451] = 07402; code[004451] = &I04451;
  core[004452] = 07402; code[004452] = &I04452;
  core[004453] = 01136; code[004453] = &L04453;
  core[004454] = 01130; code[004454] = &I04454;
  core[004455] = 07440; code[004455] = &I04455;
  core[004456] = 07402; code[004456] = &I04456;
  core[004457] = 01136; code[004457] = &I04457;
  core[004460] = 07001; code[004460] = &I04460;
  core[004461] = 03136; code[004461] = &I04461;
  core[004462] = 05270; code[004462] = &I04462;
  core[004463] = 07402; code[004463] = &I04463;
  core[004464] = 07402; code[004464] = &I04464;
  core[004465] = 07402; code[004465] = &I04465;
  core[004466] = 07402; code[004466] = &I04466;
  core[004467] = 07402; code[004467] = &I04467;
  core[004470] = 01136; code[004470] = &L04470;
  core[004471] = 01131; code[004471] = &I04471;
  core[004472] = 07440; code[004472] = &I04472;
  core[004473] = 07402; code[004473] = &I04473;
  core[004474] = 01136; code[004474] = &I04474;
  core[004475] = 07001; code[004475] = &I04475;
  core[004476] = 03136; code[004476] = &I04476;
  core[004477] = 05306; code[004477] = &I04477;
  core[004500] = 07402; code[004500] = &I04500;
  core[004501] = 07402; code[004501] = &I04501;
  core[004502] = 07402; code[004502] = &I04502;
  core[004503] = 07402; code[004503] = &I04503;
  core[004504] = 07402; code[004504] = &I04504;
  core[004505] = 07402; code[004505] = &I04505;
  core[004506] = 01136; code[004506] = &L04506;
  core[004507] = 01132; code[004507] = &I04507;
  core[004510] = 07440; code[004510] = &I04510;
  core[004511] = 07402; code[004511] = &I04511;
  core[004512] = 01136; code[004512] = &I04512;
  core[004513] = 07001; code[004513] = &I04513;
  core[004514] = 03136; code[004514] = &I04514;
  core[004515] = 05325; code[004515] = &I04515;
  core[004516] = 07402; code[004516] = &I04516;
  core[004517] = 07402; code[004517] = &I04517;
  core[004520] = 07402; code[004520] = &I04520;
  core[004521] = 07402; code[004521] = &I04521;
  core[004522] = 07402; code[004522] = &I04522;
  core[004523] = 07402; code[004523] = &I04523;
  core[004524] = 07402; code[004524] = &I04524;
  core[004525] = 01136; code[004525] = &L04525;
  core[004526] = 01133; code[004526] = &I04526;
  core[004527] = 07440; code[004527] = &I04527;
  core[004530] = 07402; code[004530] = &I04530;
  core[004531] = 01136; code[004531] = &I04531;
  core[004532] = 07001; code[004532] = &I04532;
  core[004533] = 03136; code[004533] = &I04533;
  core[004534] = 05345; code[004534] = &I04534;
  core[004535] = 07402; code[004535] = &I04535;
  core[004536] = 07402; code[004536] = &I04536;
  core[004537] = 07402; code[004537] = &I04537;
  core[004540] = 07402; code[004540] = &I04540;
  core[004541] = 07402; code[004541] = &I04541;
  core[004542] = 07402; code[004542] = &I04542;
  core[004543] = 07402; code[004543] = &I04543;
  core[004544] = 07402; code[004544] = &I04544;
  core[004545] = 01136; code[004545] = &L04545;
  core[004546] = 01134; code[004546] = &I04546;
  core[004547] = 07440; code[004547] = &I04547;
  core[004550] = 07402; code[004550] = &I04550;
  core[004551] = 01136; code[004551] = &I04551;
  core[004552] = 07001; code[004552] = &I04552;
  core[004553] = 03136; code[004553] = &I04553;
  core[004554] = 05366; code[004554] = &I04554;
  core[004555] = 07402; code[004555] = &I04555;
  core[004556] = 07402; code[004556] = &I04556;
  core[004557] = 07402; code[004557] = &I04557;
  core[004560] = 07402; code[004560] = &I04560;
  core[004561] = 07402; code[004561] = &I04561;
  core[004562] = 07402; code[004562] = &I04562;
  core[004563] = 07402; code[004563] = &I04563;
  core[004564] = 07402; code[004564] = &I04564;
  core[004565] = 07402; code[004565] = &I04565;
  core[004566] = 01136; code[004566] = &L04566;
  core[004567] = 01135; code[004567] = &I04567;
  core[004570] = 07440; code[004570] = &I04570;
  core[004571] = 07402; code[004571] = &I04571;
  core[004572] = 01136; code[004572] = &I04572;
  core[004573] = 07001; code[004573] = &I04573;
  core[004574] = 03136; code[004574] = &I04574;
  core[004575] = 07000; code[004575] = &I04575;
  core[004576] = 07000; code[004576] = &I04576;
  core[004577] = 07000; code[004577] = &I04577;
  core[004600] = 01205; code[004600] = &I04600;
  core[004601] = 03455; code[004601] = &I04601;
  core[004602] = 01206; code[004602] = &I04602;
  core[004603] = 03422; code[004603] = &I04603;
  core[004604] = 05455; code[004604] = &I04604;
  core[004605] = 05422; code[004605] = &D04605;
  core[004606] = 05456; code[004606] = &D04606;
  core[004620] = 01136; code[004620] = &L04620;
  core[004621] = 01236; code[004621] = &I04621;
  core[004622] = 07440; code[004622] = &I04622;
  core[004623] = 07402; code[004623] = &I04623;
  core[004624] = 01136; code[004624] = &I04624;
  core[004625] = 07001; code[004625] = &I04625;
  core[004626] = 03136; code[004626] = &I04626;
  core[004627] = 01234; code[004627] = &I04627;
  core[004630] = 03454; code[004630] = &I04630;
  core[004631] = 01235; code[004631] = &I04631;
  core[004632] = 03423; code[004632] = &I04632;
  core[004633] = 05454; code[004633] = &I04633;
  core[004634] = 05423; code[004634] = &D04634;
  core[004635] = 05457; code[004635] = &D04635;
  core[004636] = 07754; code[004636] = &D04636;
  core[004640] = 01136; code[004640] = &L04640;
  core[004641] = 01256; code[004641] = &I04641;
  core[004642] = 07440; code[004642] = &I04642;
  core[004643] = 07402; code[004643] = &I04643;
  core[004644] = 01136; code[004644] = &I04644;
  core[004645] = 07001; code[004645] = &I04645;
  core[004646] = 03136; code[004646] = &I04646;
  core[004647] = 01254; code[004647] = &I04647;
  core[004650] = 03453; code[004650] = &I04650;
  core[004651] = 01255; code[004651] = &I04651;
  core[004652] = 03424; code[004652] = &I04652;
  core[004653] = 05453; code[004653] = &I04653;
  core[004654] = 05424; code[004654] = &D04654;
  core[004655] = 05660; code[004655] = &D04655;
  core[004656] = 07753; code[004656] = &D04656;
  core[004660] = 01136; code[004660] = &P04660;
  core[004661] = 01276; code[004661] = &I04661;
  core[004662] = 07440; code[004662] = &I04662;
  core[004663] = 07402; code[004663] = &I04663;
  core[004664] = 01136; code[004664] = &I04664;
  core[004665] = 07001; code[004665] = &I04665;
  core[004666] = 03136; code[004666] = &I04666;
  core[004667] = 01274; code[004667] = &I04667;
  core[004670] = 03452; code[004670] = &I04670;
  core[004671] = 01275; code[004671] = &I04671;
  core[004672] = 03425; code[004672] = &I04672;
  core[004673] = 05452; code[004673] = &I04673;
  core[004674] = 05425; code[004674] = &D04674;
  core[004675] = 05461; code[004675] = &D04675;
  core[004676] = 07752; code[004676] = &D04676;
  core[004700] = 01136; code[004700] = &L04700;
  core[004701] = 01316; code[004701] = &I04701;
  core[004702] = 07440; code[004702] = &I04702;
  core[004703] = 07402; code[004703] = &I04703;
  core[004704] = 01136; code[004704] = &I04704;
  core[004705] = 07001; code[004705] = &I04705;
  core[004706] = 03136; code[004706] = &I04706;
  core[004707] = 01314; code[004707] = &I04707;
  core[004710] = 03451; code[004710] = &I04710;
  core[004711] = 01315; code[004711] = &I04711;
  core[004712] = 03426; code[004712] = &I04712;
  core[004713] = 05451; code[004713] = &I04713;
  core[004714] = 05426; code[004714] = &D04714;
  core[004715] = 05462; code[004715] = &D04715;
  core[004716] = 07751; code[004716] = &D04716;
  core[004720] = 01136; code[004720] = &L04720;
  core[004721] = 01336; code[004721] = &I04721;
  core[004722] = 07440; code[004722] = &I04722;
  core[004723] = 07402; code[004723] = &I04723;
  core[004724] = 01136; code[004724] = &I04724;
  core[004725] = 07001; code[004725] = &I04725;
  core[004726] = 03136; code[004726] = &I04726;
  core[004727] = 01334; code[004727] = &I04727;
  core[004730] = 03450; code[004730] = &I04730;
  core[004731] = 01335; code[004731] = &I04731;
  core[004732] = 03427; code[004732] = &I04732;
  core[004733] = 05450; code[004733] = &I04733;
  core[004734] = 05427; code[004734] = &D04734;
  core[004735] = 05463; code[004735] = &D04735;
  core[004736] = 07750; code[004736] = &D04736;
  core[004740] = 01136; code[004740] = &L04740;
  core[004741] = 01356; code[004741] = &I04741;
  core[004742] = 07440; code[004742] = &I04742;
  core[004743] = 07402; code[004743] = &I04743;
  core[004744] = 01136; code[004744] = &I04744;
  core[004745] = 07001; code[004745] = &I04745;
  core[004746] = 03136; code[004746] = &I04746;
  core[004747] = 01354; code[004747] = &I04747;
  core[004750] = 03447; code[004750] = &I04750;
  core[004751] = 01355; code[004751] = &I04751;
  core[004752] = 03430; code[004752] = &I04752;
  core[004753] = 05447; code[004753] = &I04753;
  core[004754] = 05430; code[004754] = &D04754;
  core[004755] = 05464; code[004755] = &D04755;
  core[004756] = 07747; code[004756] = &D04756;
  core[004760] = 01136; code[004760] = &L04760;
  core[004761] = 01376; code[004761] = &I04761;
  core[004762] = 07440; code[004762] = &I04762;
  core[004763] = 07402; code[004763] = &I04763;
  core[004764] = 01136; code[004764] = &I04764;
  core[004765] = 07001; code[004765] = &I04765;
  core[004766] = 03136; code[004766] = &I04766;
  core[004767] = 01374; code[004767] = &I04767;
  core[004770] = 03446; code[004770] = &I04770;
  core[004771] = 01375; code[004771] = &I04771;
  core[004772] = 03431; code[004772] = &I04772;
  core[004773] = 05446; code[004773] = &I04773;
  core[004774] = 05431; code[004774] = &D04774;
  core[004775] = 05465; code[004775] = &D04775;
  core[004776] = 07746; code[004776] = &D04776;
  core[005000] = 01136; code[005000] = &L05000;
  core[005001] = 01216; code[005001] = &D05001;
  core[005002] = 07440; code[005002] = &I05002;
  core[005003] = 07402; code[005003] = &I05003;
  core[005004] = 01136; code[005004] = &I05004;
  core[005005] = 07001; code[005005] = &I05005;
  core[005006] = 03136; code[005006] = &I05006;
  core[005007] = 01214; code[005007] = &I05007;
  core[005010] = 03445; code[005010] = &I05010;
  core[005011] = 01215; code[005011] = &I05011;
  core[005012] = 03432; code[005012] = &I05012;
  core[005013] = 05445; code[005013] = &I05013;
  core[005014] = 05432; code[005014] = &D05014;
  core[005015] = 05466; code[005015] = &D05015;
  core[005016] = 07745; code[005016] = &D05016;
  core[005020] = 01136; code[005020] = &L05020;
  core[005021] = 01236; code[005021] = &I05021;
  core[005022] = 07440; code[005022] = &I05022;
  core[005023] = 07402; code[005023] = &I05023;
  core[005024] = 01136; code[005024] = &I05024;
  core[005025] = 07001; code[005025] = &I05025;
  core[005026] = 03136; code[005026] = &I05026;
  core[005027] = 01234; code[005027] = &I05027;
  core[005030] = 03444; code[005030] = &I05030;
  core[005031] = 01235; code[005031] = &I05031;
  core[005032] = 03433; code[005032] = &I05032;
  core[005033] = 05444; code[005033] = &I05033;
  core[005034] = 05433; code[005034] = &D05034;
  core[005035] = 05467; code[005035] = &D05035;
  core[005036] = 07744; code[005036] = &D05036;
  core[005040] = 01136; code[005040] = &L05040;
  core[005041] = 01256; code[005041] = &I05041;
  core[005042] = 07440; code[005042] = &I05042;
  core[005043] = 07402; code[005043] = &I05043;
  core[005044] = 01136; code[005044] = &I05044;
  core[005045] = 07001; code[005045] = &I05045;
  core[005046] = 03136; code[005046] = &I05046;
  core[005047] = 01254; code[005047] = &I05047;
  core[005050] = 03443; code[005050] = &I05050;
  core[005051] = 01255; code[005051] = &I05051;
  core[005052] = 03434; code[005052] = &I05052;
  core[005053] = 05443; code[005053] = &I05053;
  core[005054] = 05434; code[005054] = &D05054;
  core[005055] = 05470; code[005055] = &D05055;
  core[005056] = 07743; code[005056] = &D05056;
  core[005060] = 01136; code[005060] = &L05060;
  core[005061] = 01276; code[005061] = &I05061;
  core[005062] = 07440; code[005062] = &I05062;
  core[005063] = 07402; code[005063] = &I05063;
  core[005064] = 01136; code[005064] = &I05064;
  core[005065] = 07001; code[005065] = &I05065;
  core[005066] = 03136; code[005066] = &I05066;
  core[005067] = 01274; code[005067] = &I05067;
  core[005070] = 03442; code[005070] = &I05070;
  core[005071] = 01275; code[005071] = &I05071;
  core[005072] = 03435; code[005072] = &I05072;
  core[005073] = 05442; code[005073] = &I05073;
  core[005074] = 05435; code[005074] = &D05074;
  core[005075] = 05471; code[005075] = &D05075;
  core[005076] = 07742; code[005076] = &D05076;
  core[005100] = 01136; code[005100] = &L05100;
  core[005101] = 01316; code[005101] = &I05101;
  core[005102] = 07440; code[005102] = &I05102;
  core[005103] = 07402; code[005103] = &I05103;
  core[005104] = 01136; code[005104] = &I05104;
  core[005105] = 07001; code[005105] = &I05105;
  core[005106] = 03136; code[005106] = &I05106;
  core[005107] = 01314; code[005107] = &I05107;
  core[005110] = 03437; code[005110] = &I05110;
  core[005111] = 01315; code[005111] = &I05111;
  core[005112] = 03436; code[005112] = &I05112;
  core[005113] = 05437; code[005113] = &I05113;
  core[005114] = 05436; code[005114] = &D05114;
  core[005115] = 05472; code[005115] = &D05115;
  core[005116] = 07741; code[005116] = &D05116;
  core[005120] = 01136; code[005120] = &L05120;
  core[005121] = 01336; code[005121] = &I05121;
  core[005122] = 07440; code[005122] = &I05122;
  core[005123] = 07402; code[005123] = &I05123;
  core[005124] = 01136; code[005124] = &I05124;
  core[005125] = 07001; code[005125] = &I05125;
  core[005126] = 03136; code[005126] = &I05126;
  core[005127] = 01334; code[005127] = &I05127;
  core[005130] = 03422; code[005130] = &I05130;
  core[005131] = 01335; code[005131] = &I05131;
  core[005132] = 03455; code[005132] = &I05132;
  core[005133] = 05422; code[005133] = &I05133;
  core[005134] = 05455; code[005134] = &D05134;
  core[005135] = 05473; code[005135] = &D05135;
  core[005136] = 07740; code[005136] = &D05136;
  core[005140] = 01136; code[005140] = &L05140;
  core[005141] = 01356; code[005141] = &I05141;
  core[005142] = 07440; code[005142] = &I05142;
  core[005143] = 07402; code[005143] = &I05143;
  core[005144] = 01136; code[005144] = &I05144;
  core[005145] = 07001; code[005145] = &I05145;
  core[005146] = 03136; code[005146] = &I05146;
  core[005147] = 01354; code[005147] = &I05147;
  core[005150] = 03423; code[005150] = &I05150;
  core[005151] = 01355; code[005151] = &I05151;
  core[005152] = 03454; code[005152] = &I05152;
  core[005153] = 05423; code[005153] = &I05153;
  core[005154] = 05454; code[005154] = &D05154;
  core[005155] = 05474; code[005155] = &D05155;
  core[005156] = 07737; code[005156] = &D05156;
  core[005160] = 01136; code[005160] = &L05160;
  core[005161] = 01376; code[005161] = &I05161;
  core[005162] = 07440; code[005162] = &I05162;
  core[005163] = 07402; code[005163] = &I05163;
  core[005164] = 01136; code[005164] = &I05164;
  core[005165] = 07001; code[005165] = &I05165;
  core[005166] = 03136; code[005166] = &I05166;
  core[005167] = 01374; code[005167] = &I05167;
  core[005170] = 03424; code[005170] = &I05170;
  core[005171] = 01375; code[005171] = &I05171;
  core[005172] = 03453; code[005172] = &I05172;
  core[005173] = 05424; code[005173] = &I05173;
  core[005174] = 05453; code[005174] = &D05174;
  core[005175] = 05475; code[005175] = &D05175;
  core[005176] = 07736; code[005176] = &D05176;
  core[005200] = 01136; code[005200] = &L05200;
  core[005201] = 01216; code[005201] = &I05201;
  core[005202] = 07440; code[005202] = &I05202;
  core[005203] = 07402; code[005203] = &I05203;
  core[005204] = 01136; code[005204] = &I05204;
  core[005205] = 07001; code[005205] = &I05205;
  core[005206] = 03136; code[005206] = &I05206;
  core[005207] = 01214; code[005207] = &I05207;
  core[005210] = 03425; code[005210] = &I05210;
  core[005211] = 01215; code[005211] = &I05211;
  core[005212] = 03452; code[005212] = &I05212;
  core[005213] = 05425; code[005213] = &I05213;
  core[005214] = 05452; code[005214] = &D05214;
  core[005215] = 05476; code[005215] = &D05215;
  core[005216] = 07735; code[005216] = &D05216;
  core[005220] = 01136; code[005220] = &L05220;
  core[005221] = 01236; code[005221] = &I05221;
  core[005222] = 07440; code[005222] = &I05222;
  core[005223] = 07402; code[005223] = &I05223;
  core[005224] = 01136; code[005224] = &I05224;
  core[005225] = 07001; code[005225] = &I05225;
  core[005226] = 03136; code[005226] = &I05226;
  core[005227] = 01234; code[005227] = &I05227;
  core[005230] = 03426; code[005230] = &I05230;
  core[005231] = 01235; code[005231] = &I05231;
  core[005232] = 03451; code[005232] = &I05232;
  core[005233] = 05426; code[005233] = &I05233;
  core[005234] = 05451; code[005234] = &D05234;
  core[005235] = 05502; code[005235] = &D05235;
  core[005236] = 07734; code[005236] = &D05236;
  core[005240] = 01136; code[005240] = &L05240;
  core[005241] = 01256; code[005241] = &I05241;
  core[005242] = 07440; code[005242] = &I05242;
  core[005243] = 07402; code[005243] = &I05243;
  core[005244] = 01136; code[005244] = &I05244;
  core[005245] = 07001; code[005245] = &I05245;
  core[005246] = 03136; code[005246] = &I05246;
  core[005247] = 01254; code[005247] = &I05247;
  core[005250] = 03427; code[005250] = &I05250;
  core[005251] = 01255; code[005251] = &I05251;
  core[005252] = 03450; code[005252] = &I05252;
  core[005253] = 05427; code[005253] = &I05253;
  core[005254] = 05450; code[005254] = &D05254;
  core[005255] = 05503; code[005255] = &D05255;
  core[005256] = 07733; code[005256] = &D05256;
  core[005260] = 01136; code[005260] = &L05260;
  core[005261] = 01276; code[005261] = &I05261;
  core[005262] = 07440; code[005262] = &I05262;
  core[005263] = 07402; code[005263] = &I05263;
  core[005264] = 01136; code[005264] = &I05264;
  core[005265] = 07001; code[005265] = &I05265;
  core[005266] = 03136; code[005266] = &I05266;
  core[005267] = 01274; code[005267] = &I05267;
  core[005270] = 03430; code[005270] = &I05270;
  core[005271] = 01275; code[005271] = &I05271;
  core[005272] = 03447; code[005272] = &I05272;
  core[005273] = 05430; code[005273] = &I05273;
  core[005274] = 05447; code[005274] = &D05274;
  core[005275] = 05504; code[005275] = &D05275;
  core[005276] = 07732; code[005276] = &D05276;
  core[005300] = 01136; code[005300] = &L05300;
  core[005301] = 01316; code[005301] = &I05301;
  core[005302] = 07440; code[005302] = &I05302;
  core[005303] = 07402; code[005303] = &I05303;
  core[005304] = 01136; code[005304] = &I05304;
  core[005305] = 07001; code[005305] = &I05305;
  core[005306] = 03136; code[005306] = &I05306;
  core[005307] = 01314; code[005307] = &I05307;
  core[005310] = 03431; code[005310] = &I05310;
  core[005311] = 01315; code[005311] = &I05311;
  core[005312] = 03446; code[005312] = &I05312;
  core[005313] = 05431; code[005313] = &I05313;
  core[005314] = 05446; code[005314] = &D05314;
  core[005315] = 05505; code[005315] = &D05315;
  core[005316] = 07731; code[005316] = &D05316;
  core[005320] = 01136; code[005320] = &L05320;
  core[005321] = 01336; code[005321] = &I05321;
  core[005322] = 07440; code[005322] = &I05322;
  core[005323] = 07402; code[005323] = &I05323;
  core[005324] = 01136; code[005324] = &I05324;
  core[005325] = 07001; code[005325] = &I05325;
  core[005326] = 03136; code[005326] = &I05326;
  core[005327] = 01334; code[005327] = &I05327;
  core[005330] = 03432; code[005330] = &I05330;
  core[005331] = 01335; code[005331] = &I05331;
  core[005332] = 03445; code[005332] = &I05332;
  core[005333] = 05432; code[005333] = &I05333;
  core[005334] = 05445; code[005334] = &D05334;
  core[005335] = 05506; code[005335] = &D05335;
  core[005336] = 07730; code[005336] = &D05336;
  core[005340] = 01136; code[005340] = &L05340;
  core[005341] = 01356; code[005341] = &I05341;
  core[005342] = 07440; code[005342] = &I05342;
  core[005343] = 07402; code[005343] = &I05343;
  core[005344] = 01136; code[005344] = &I05344;
  core[005345] = 07001; code[005345] = &I05345;
  core[005346] = 03136; code[005346] = &I05346;
  core[005347] = 01354; code[005347] = &I05347;
  core[005350] = 03433; code[005350] = &I05350;
  core[005351] = 01355; code[005351] = &I05351;
  core[005352] = 03444; code[005352] = &I05352;
  core[005353] = 05433; code[005353] = &I05353;
  core[005354] = 05444; code[005354] = &D05354;
  core[005355] = 05507; code[005355] = &D05355;
  core[005356] = 07727; code[005356] = &D05356;
  core[005360] = 01136; code[005360] = &L05360;
  core[005361] = 01376; code[005361] = &I05361;
  core[005362] = 07440; code[005362] = &I05362;
  core[005363] = 07402; code[005363] = &I05363;
  core[005364] = 01136; code[005364] = &I05364;
  core[005365] = 07001; code[005365] = &I05365;
  core[005366] = 03136; code[005366] = &I05366;
  core[005367] = 01374; code[005367] = &I05367;
  core[005370] = 03434; code[005370] = &I05370;
  core[005371] = 01375; code[005371] = &I05371;
  core[005372] = 03443; code[005372] = &I05372;
  core[005373] = 05434; code[005373] = &I05373;
  core[005374] = 05443; code[005374] = &D05374;
  core[005375] = 05510; code[005375] = &D05375;
  core[005376] = 07726; code[005376] = &D05376;
  core[005400] = 01136; code[005400] = &L05400;
  core[005401] = 01216; code[005401] = &I05401;
  core[005402] = 07440; code[005402] = &I05402;
  core[005403] = 07402; code[005403] = &I05403;
  core[005404] = 01136; code[005404] = &I05404;
  core[005405] = 07001; code[005405] = &I05405;
  core[005406] = 03136; code[005406] = &I05406;
  core[005407] = 01214; code[005407] = &I05407;
  core[005410] = 03435; code[005410] = &I05410;
  core[005411] = 01215; code[005411] = &I05411;
  core[005412] = 03442; code[005412] = &I05412;
  core[005413] = 05435; code[005413] = &I05413;
  core[005414] = 05442; code[005414] = &D05414;
  core[005415] = 05511; code[005415] = &D05415;
  core[005416] = 07725; code[005416] = &D05416;
  core[005420] = 01136; code[005420] = &L05420;
  core[005421] = 01236; code[005421] = &I05421;
  core[005422] = 07440; code[005422] = &I05422;
  core[005423] = 07402; code[005423] = &I05423;
  core[005424] = 01136; code[005424] = &I05424;
  core[005425] = 07001; code[005425] = &I05425;
  core[005426] = 03136; code[005426] = &I05426;
  core[005427] = 01234; code[005427] = &I05427;
  core[005430] = 03436; code[005430] = &I05430;
  core[005431] = 01235; code[005431] = &I05431;
  core[005432] = 03437; code[005432] = &I05432;
  core[005433] = 05436; code[005433] = &I05433;
  core[005434] = 05437; code[005434] = &D05434;
  core[005435] = 05512; code[005435] = &D05435;
  core[005436] = 07724; code[005436] = &D05436;
  core[005440] = 01136; code[005440] = &L05440;
  core[005441] = 01250; code[005441] = &I05441;
  core[005442] = 07440; code[005442] = &I05442;
  core[005443] = 07402; code[005443] = &I05443;
  core[005444] = 01136; code[005444] = &I05444;
  core[005445] = 07001; code[005445] = &I05445;
  core[005446] = 03136; code[005446] = &I05446;
  core[005447] = 05651; code[005447] = &I05447;
  core[005450] = 07723; code[005450] = &D05450;
  core[005451] = 02002; code[005451] = &P05451;
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

