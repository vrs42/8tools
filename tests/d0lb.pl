#!/usr/bin/perl

# Boilerplate startup.

use Term::ReadKey;
ReadMode 'ultra-raw';
# Use ^E for force hlt.

#
# Wave a wand to set all uninitialized memory to HLT.
for ($loc = 0; $loc < 0100000; $loc++) {
  $core[$loc] = 07402; $code[$loc] = *emul8;
}

#
# IF is in $pc, CIF sets $ib.
# BUGBUG: Guessing at starting address!
$df = $ib = 0; $pc = 00200;
$swr = 07777;
# LINK is in $lac.
$hlt = $ion = $ionn = $um = $rib = $lac = $mq = $modeb = $sc = 0;
# I/O Devices.
$ttof = $ttofn = 0; # Teleprinter flag is clear
$ttie = 1;
# Run-time behavior.
$interact = 0;
$trace = 0;
$echar = 0205; # Usually ^E

#
# Run-time Command line parsing.  Command lines can use:
# =0nnnnn to specify a starting address.
# %0nnnnn to specify switch register contents.
# !0nnnnn to specify an exit character other than ^E.
# -i to activate interaction after HLT.
# -t to activate trace output on STDERR.
# Other stuff on the command line is retained with the intent
#   to eventually add code to pass file specs to USR when OS/8
#   support is added.
@usr = ();
foreach (@ARGV) {
  $pc = $1 if /^\=(0\d+)/;
  $swr = $1 if /^\%(0\d+)/;
  $echar = $1 if /^\!(0\d+)/;
  next if /^[=\%!](0\d+)/;
  die "Number is not octal: '$1'\n" if s/^[=\%!](\d+)//;
  $interact = 1 if $_ eq "-i";
  next if $_ eq "-i";
  $trace = 1 if $_ eq "-t";
  next if $_ eq "-t";
  die "Unsupported option '$1'\n" if /^-(.*)/;
  next if /^-(.*)/;
  s/_/</; # Sneaks '<' past the shell
  y/A-Z/a-z/; # Monocase for USR
  push(@usr, $_);
}

#
# Compiled code:
$core[000000] = 00000; $code[000000] = *S00000; sub S00000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000001] = 05001; $code[000001] = *P00001; sub P00001 { $pc = 000001; $inh = 0; goto &fetch; }
$core[000002] = 00002; $code[000002] = *D00002; sub D00002 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000003] = 00003; $code[000003] = *P00003; sub P00003 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000010] = 00000; $code[000010] = *P00010; sub P00010 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000011] = 00000; $code[000011] = *P00011; sub P00011 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000012] = 00000; $code[000012] = *P00012; sub P00012 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000013] = 00000; $code[000013] = *P00013; sub P00013 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000020] = 00000; $code[000020] = *P00020; sub P00020 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000021] = 00000; $code[000021] = *D00021; sub D00021 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000022] = 00000; $code[000022] = *D00022; sub D00022 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000023] = 00000; $code[000023] = *P00023; sub P00023 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000024] = 00000; $code[000024] = *D00024; sub D00024 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000025] = 00000; $code[000025] = *P00025; sub P00025 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000026] = 00000; $code[000026] = *P00026; sub P00026 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000027] = 00000; $code[000027] = *D00027; sub D00027 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000030] = 00000; $code[000030] = *P00030; sub P00030 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000031] = 00000; $code[000031] = *P00031; sub P00031 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000032] = 00000; $code[000032] = *P00032; sub P00032 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000033] = 00000; $code[000033] = *L00033; sub L00033 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000034] = 00000; $code[000034] = *P00034; sub P00034 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000035] = 00000; $code[000035] = *P00035; sub P00035 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000036] = 00000; $code[000036] = *D00036; sub D00036 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000037] = 00000; $code[000037] = *D00037; sub D00037 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000040] = 00000; $code[000040] = *P00040; sub P00040 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000041] = 00000; $code[000041] = *D00041; sub D00041 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000042] = 00000; $code[000042] = *D00042; sub D00042 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000043] = 00000; $code[000043] = *D00043; sub D00043 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000044] = 00000; $code[000044] = *P00044; sub P00044 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000045] = 00000; $code[000045] = *P00045; sub P00045 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000046] = 00000; $code[000046] = *D00046; sub D00046 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000047] = 00000; $code[000047] = *D00047; sub D00047 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000050] = 06600; $code[000050] = *P00050; sub P00050 { &emul8; goto &fetch; }
$core[000051] = 06670; $code[000051] = *P00051; sub P00051 { &emul8; goto &fetch; }
$core[000052] = 06345; $code[000052] = *P00052; sub P00052 { &emul8; goto &fetch; }
$core[000053] = 06400; $code[000053] = *P00053; sub P00053 { &emul8; goto &fetch; }
$core[000054] = 06723; $code[000054] = *P00054; sub P00054 { &emul8; goto &fetch; }
$core[000055] = 06727; $code[000055] = *P00055; sub P00055 { &emul8; goto &fetch; }
$core[000056] = 00000; $code[000056] = *P00056; sub P00056 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000057] = 00000; $code[000057] = *P00057; sub P00057 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000060] = 00400; $code[000060] = *D00060; sub D00060 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000061] = 00503; $code[000061] = *D00061; sub D00061 { $lac &= (010000|$core[($df<<12)+$core[67]]); goto &fetch; }
$core[000062] = 00650; $code[000062] = *P00062; sub P00062 { $lac &= (010000|$core[($df<<12)+$core[40]]); goto &fetch; }
$core[000063] = 00000; $code[000063] = *P00063; sub P00063 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000064] = 00000; $code[000064] = *D00064; sub D00064 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000065] = 00000; $code[000065] = *D00065; sub D00065 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000066] = 00000; $code[000066] = *D00066; sub D00066 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000067] = 00000; $code[000067] = *P00067; sub P00067 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000070] = 00215; $code[000070] = *D00070; sub D00070 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000071] = 00212; $code[000071] = *D00071; sub D00071 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000072] = 00315; $code[000072] = *D00072; sub D00072 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[000073] = 00321; $code[000073] = *P00073; sub P00073 { $lac &= (010000|$core[000121]); goto &fetch; }
$core[000074] = 00314; $code[000074] = *P00074; sub P00074 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[000075] = 00324; $code[000075] = *P00075; sub P00075 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[000076] = 00301; $code[000076] = *P00076; sub P00076 { $lac &= (010000|$core[000101]); goto &fetch; }
$core[000077] = 00303; $code[000077] = *P00077; sub P00077 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[000100] = 00261; $code[000100] = *P00100; sub P00100 { $lac &= (010000|$core[000061]); goto &fetch; }
$core[000101] = 00260; $code[000101] = *D00101; sub D00101 { $lac &= (010000|$core[000060]); goto &fetch; }
$core[000102] = 00000; $code[000102] = *D00102; sub D00102 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000103] = 00255; $code[000103] = *P00103; sub P00103 { $lac &= (010000|$core[000055]); goto &fetch; }
$core[000104] = 07763; $code[000104] = *P00104; sub P00104 { &emul8; goto &fetch; }
$core[000105] = 00000; $code[000105] = *D00105; sub D00105 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000106] = 00000; $code[000106] = *D00106; sub D00106 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000107] = 01000; $code[000107] = *P00107; sub P00107 { $lac += $core[000000]; goto &fetch; }
$core[000110] = 01135; $code[000110] = *D00110; sub D00110 { $lac += $core[000135]; goto &fetch; }
$core[000111] = 00326; $code[000111] = *D00111; sub D00111 { $lac &= (010000|$core[000126]); goto &fetch; }
$core[000112] = 00263; $code[000112] = *P00112; sub P00112 { $lac &= (010000|$core[000063]); goto &fetch; }
$core[000113] = 00262; $code[000113] = *P00113; sub P00113 { $lac &= (010000|$core[000062]); goto &fetch; }
$core[000114] = 00000; $code[000114] = *D00114; sub D00114 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000115] = 00000; $code[000115] = *D00115; sub D00115 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000116] = 00000; $code[000116] = *D00116; sub D00116 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000117] = 00000; $code[000117] = *P00117; sub P00117 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000120] = 00000; $code[000120] = *P00120; sub P00120 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000121] = 00000; $code[000121] = *P00121; sub P00121 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000122] = 00000; $code[000122] = *P00122; sub P00122 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000123] = 07740; $code[000123] = *P00123; sub P00123 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000124] = 05600; $code[000124] = *P00124; sub P00124 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[000125] = 05607; $code[000125] = *P00125; sub P00125 { $pc = ($ib<<12)+$core[7]; $inh = 0; goto &fetch; }
$core[000126] = 05613; $code[000126] = *P00126; sub P00126 { $core[000013] = 0000 if ++$core[000013] == 010000; $pc = ($ib<<12)+$core[000013]; $inh = 0; goto &fetch; }
$core[000127] = 05640; $code[000127] = *P00127; sub P00127 { $pc = ($ib<<12)+$core[32]; $inh = 0; goto &fetch; }
$core[000130] = 05656; $code[000130] = *P00130; sub P00130 { $pc = ($ib<<12)+$core[46]; $inh = 0; goto &fetch; }
$core[000131] = 05663; $code[000131] = *P00131; sub P00131 { $pc = ($ib<<12)+$core[51]; $inh = 0; goto &fetch; }
$core[000132] = 05645; $code[000132] = *P00132; sub P00132 { $pc = ($ib<<12)+$core[37]; $inh = 0; goto &fetch; }
$core[000133] = 05652; $code[000133] = *L00133; sub L00133 { $pc = ($ib<<12)+$core[42]; $inh = 0; goto &fetch; }
$core[000134] = 05707; $code[000134] = *P00134; sub P00134 { $pc = ($ib<<12)+$core[71]; $inh = 0; goto &fetch; }
$core[000135] = 05274; $code[000135] = *P00135; sub P00135 { $pc = 000074; $inh = 0; goto &fetch; }
$core[000136] = 05317; $code[000136] = *P00136; sub P00136 { $pc = 000117; $inh = 0; goto &fetch; }
$core[000137] = 07000; $code[000137] = *P00137; sub P00137 { goto &fetch; }
$core[000140] = 05520; $code[000140] = *P00140; sub P00140 { $pc = ($ib<<12)+$core[80]; $inh = 0; goto &fetch; }
$core[000141] = 05410; $code[000141] = *P00141; sub P00141 { $core[000010] = 0000 if ++$core[000010] == 010000; $pc = ($ib<<12)+$core[000010]; $inh = 0; goto &fetch; }
$core[000142] = 05546; $code[000142] = *P00142; sub P00142 { $pc = ($ib<<12)+$core[102]; $inh = 0; goto &fetch; }
$core[000143] = 05325; $code[000143] = *P00143; sub P00143 { $pc = 000125; $inh = 0; goto &fetch; }
$core[000144] = 05333; $code[000144] = *P00144; sub P00144 { $pc = 000133; $inh = 0; goto &fetch; }
$core[000145] = 05342; $code[000145] = *P00145; sub P00145 { $pc = 000142; $inh = 0; goto &fetch; }
$core[000146] = 05400; $code[000146] = *P00146; sub P00146 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[000147] = 07070; $code[000147] = *P00147; sub P00147 { $lac ^= 010000; $lac ^= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000150] = 06525; $code[000150] = *P00150; sub P00150 { &emul8; goto &fetch; }
$core[000151] = 05751; $code[000151] = *P00151; sub P00151 { $pc = ($ib<<12)+$core[105]; $inh = 0; goto &fetch; }
$core[000152] = 05732; $code[000152] = *P00152; sub P00152 { $pc = ($ib<<12)+$core[90]; $inh = 0; goto &fetch; }
$core[000153] = 05761; $code[000153] = *P00153; sub P00153 { $pc = ($ib<<12)+$core[113]; $inh = 0; goto &fetch; }
$core[000154] = 06000; $code[000154] = *P00154; sub P00154 { &emul8; goto &fetch; }
$core[000155] = 05726; $code[000155] = *P00155; sub P00155 { $pc = ($ib<<12)+$core[86]; $inh = 0; goto &fetch; }
$core[000156] = 05503; $code[000156] = *P00156; sub P00156 { $pc = ($ib<<12)+$core[67]; $inh = 0; goto &fetch; }
$core[000163] = 04000; $code[000163] = *D00163; sub D00163 { $core[000000] = 00164; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000164] = 00031; $code[000164] = *D00164; sub D00164 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[000165] = 00037; $code[000165] = *D00165; sub D00165 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[000166] = 07563; $code[000166] = *D00166; sub D00166 { &emul8; goto &fetch; }
$core[000167] = 00033; $code[000167] = *P00167; sub P00167 { $lac &= (010000|$core[000033]); goto &fetch; }
$core[000170] = 00042; $code[000170] = *D00170; sub D00170 { $lac &= (010000|$core[000042]); goto &fetch; }
$core[000171] = 02525; $code[000171] = *D00171; sub D00171 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[000172] = 05252; $code[000172] = *D00172; sub D00172 { $pc = 000052; $inh = 0; goto &fetch; }
$core[000173] = 05767; $code[000173] = *P00173; sub P00173 { $pc = ($ib<<12)+$core[119]; $inh = 0; goto &fetch; }
$core[000174] = 07741; $code[000174] = *D00174; sub D00174 { &emul8; goto &fetch; }
$core[000175] = 05551; $code[000175] = *P00175; sub P00175 { $pc = ($ib<<12)+$core[105]; $inh = 0; goto &fetch; }
$core[000176] = 06704; $code[000176] = *P00176; sub P00176 { &emul8; goto &fetch; }
$core[000177] = 05000; $code[000177] = *P00177; sub P00177 { $pc = 000000; $inh = 0; goto &fetch; }
$core[000200] = 06007; $code[000200] = *I00200; sub I00200 { &emul8; goto &fetch; }
$core[000201] = 03115; $code[000201] = *I00201; sub I00201 { $core[000115] = $lac & 07777; $lac &= 010000; $code[000115] = *emul8; goto &fetch; }
$core[000202] = 07621; $code[000202] = *L00202; sub L00202 { &emul8; goto &fetch; }
$core[000203] = 04577; $code[000203] = *I00203; sub I00203 { $core[($ib<<12)+$core[127]] = 00204; $pc = ($ib<<12)+$core[127]+1; $code[($ib<<12)+$core[127]] = *emul8; $inh = 0; goto &fetch; }
$core[000204] = 05244; $code[000204] = *L00204; sub L00204 { $pc = 000244; $inh = 0; goto &fetch; }
$core[000205] = 04542; $code[000205] = *L00205; sub L00205 { $core[($ib<<12)+$core[98]] = 00206; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[000206] = 07360; $code[000206] = *L00206; sub L00206 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[000207] = 00065; $code[000207] = *I00207; sub I00207 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[000210] = 03063; $code[000210] = *I00210; sub I00210 { $core[000063] = $lac & 07777; $lac &= 010000; $code[000063] = *emul8; goto &fetch; }
$core[000211] = 07240; $code[000211] = *I00211; sub I00211 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000212] = 03064; $code[000212] = *I00212; sub I00212 { $core[000064] = $lac & 07777; $lac &= 010000; $code[000064] = *emul8; goto &fetch; }
$core[000213] = 01063; $code[000213] = *I00213; sub I00213 { $lac += $core[000063]; goto &fetch; }
$core[000214] = 07421; $code[000214] = *I00214; sub I00214 { &emul8; goto &fetch; }
$core[000215] = 03067; $code[000215] = *I00215; sub I00215 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000216] = 07620; $code[000216] = *I00216; sub I00216 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000217] = 05345; $code[000217] = *I00217; sub I00217 { $pc = 000345; $inh = 0; goto &fetch; }
$core[000220] = 07240; $code[000220] = *I00220; sub I00220 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000221] = 03066; $code[000221] = *I00221; sub I00221 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[000222] = 01067; $code[000222] = *L00222; sub L00222 { $lac += $core[000067]; goto &fetch; }
$core[000223] = 07640; $code[000223] = *I00223; sub I00223 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000224] = 05231; $code[000224] = *I00224; sub I00224 { $pc = 000231; $inh = 0; goto &fetch; }
$core[000225] = 01066; $code[000225] = *I00225; sub I00225 { $lac += $core[000066]; goto &fetch; }
$core[000226] = 07450; $code[000226] = *I00226; sub I00226 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000227] = 05231; $code[000227] = *I00227; sub I00227 { $pc = 000231; $inh = 0; goto &fetch; }
$core[000230] = 05237; $code[000230] = *I00230; sub I00230 { $pc = 000237; $inh = 0; goto &fetch; }
$core[000231] = 04545; $code[000231] = *L00231; sub L00231 { $core[($ib<<12)+$core[101]] = 00232; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000232] = 04254; $code[000232] = *I00232; sub I00232 { $core[000254] = 00233; $pc = 000254+1; $code[000254] = *emul8; $inh = 0; goto &fetch; }
$core[000233] = 07704; $code[000233] = *I00233; sub I00233 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000234] = 07004; $code[000234] = *I00234; sub I00234 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000235] = 07430; $code[000235] = *I00235; sub I00235 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000236] = 07402; $code[000236] = *I00236; sub I00236 { $hlt = 1; goto &fetch; }
$core[000237] = 07604; $code[000237] = *L00237; sub L00237 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000240] = 07106; $code[000240] = *I00240; sub I00240 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000241] = 07430; $code[000241] = *I00241; sub I00241 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000242] = 05206; $code[000242] = *I00242; sub I00242 { $pc = 000206; $inh = 0; goto &fetch; }
$core[000243] = 05205; $code[000243] = *I00243; sub I00243 { $pc = 000205; $inh = 0; goto &fetch; }
$core[000244] = 07300; $code[000244] = *L00244; sub L00244 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000245] = 03065; $code[000245] = *I00245; sub I00245 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[000246] = 01344; $code[000246] = *I00246; sub I00246 { $lac += $core[000344]; goto &fetch; }
$core[000247] = 03056; $code[000247] = *I00247; sub I00247 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[000250] = 01060; $code[000250] = *I00250; sub I00250 { $lac += $core[000060]; goto &fetch; }
$core[000251] = 03057; $code[000251] = *I00251; sub I00251 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[000252] = 04535; $code[000252] = *I00252; sub I00252 { $core[($ib<<12)+$core[93]] = 00253; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[000253] = 05205; $code[000253] = *I00253; sub I00253 { $pc = 000205; $inh = 0; goto &fetch; }
$core[000254] = 00000; $code[000254] = *S00254; sub S00254 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000255] = 04525; $code[000255] = *L00255; sub L00255 { $core[($ib<<12)+$core[85]] = 00256; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[000256] = 04302; $code[000256] = *I00256; sub I00256 { $core[000302] = 00257; $pc = 000302+1; $code[000302] = *emul8; $inh = 0; goto &fetch; }
$core[000257] = 04311; $code[000257] = *I00257; sub I00257 { $core[000311] = 00260; $pc = 000311+1; $code[000311] = *emul8; $inh = 0; goto &fetch; }
$core[000260] = 04316; $code[000260] = *I00260; sub I00260 { $core[000316] = 00261; $pc = 000316+1; $code[000316] = *emul8; $inh = 0; goto &fetch; }
$core[000261] = 04576; $code[000261] = *L00261; sub L00261 { $core[($ib<<12)+$core[126]] = 00262; $pc = ($ib<<12)+$core[126]+1; $code[($ib<<12)+$core[126]] = *emul8; $inh = 0; goto &fetch; }
$core[000262] = 04524; $code[000262] = *D00262; sub D00262 { $core[($ib<<12)+$core[84]] = 00263; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[000263] = 04455; $code[000263] = *D00263; sub D00263 { $core[($ib<<12)+$core[45]] = 00264; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[000264] = 04323; $code[000264] = *I00264; sub I00264 { $core[000323] = 00265; $pc = 000323+1; $code[000323] = *emul8; $inh = 0; goto &fetch; }
$core[000265] = 04455; $code[000265] = *I00265; sub I00265 { $core[($ib<<12)+$core[45]] = 00266; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[000266] = 04332; $code[000266] = *I00266; sub I00266 { $core[000332] = 00267; $pc = 000332+1; $code[000332] = *emul8; $inh = 0; goto &fetch; }
$core[000267] = 04454; $code[000267] = *I00267; sub I00267 { $core[($ib<<12)+$core[44]] = 00270; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[000270] = 04740; $code[000270] = *I00270; sub I00270 { $core[($ib<<12)+$core[224]] = 00271; $pc = ($ib<<12)+$core[224]+1; $code[($ib<<12)+$core[224]] = *emul8; $inh = 0; goto &fetch; }
$core[000271] = 04524; $code[000271] = *I00271; sub I00271 { $core[($ib<<12)+$core[84]] = 00272; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[000272] = 04530; $code[000272] = *I00272; sub I00272 { $core[($ib<<12)+$core[88]] = 00273; $pc = ($ib<<12)+$core[88]+1; $code[($ib<<12)+$core[88]] = *emul8; $inh = 0; goto &fetch; }
$core[000273] = 04741; $code[000273] = *I00273; sub I00273 { $core[($ib<<12)+$core[225]] = 00274; $pc = ($ib<<12)+$core[225]+1; $code[($ib<<12)+$core[225]] = *emul8; $inh = 0; goto &fetch; }
$core[000274] = 04323; $code[000274] = *I00274; sub I00274 { $core[000323] = 00275; $pc = 000323+1; $code[000323] = *emul8; $inh = 0; goto &fetch; }
$core[000275] = 04455; $code[000275] = *I00275; sub I00275 { $core[($ib<<12)+$core[45]] = 00276; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[000276] = 04742; $code[000276] = *I00276; sub I00276 { $core[($ib<<12)+$core[226]] = 00277; $pc = ($ib<<12)+$core[226]+1; $code[($ib<<12)+$core[226]] = *emul8; $inh = 0; goto &fetch; }
$core[000277] = 04454; $code[000277] = *I00277; sub I00277 { $core[($ib<<12)+$core[44]] = 00300; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[000300] = 04743; $code[000300] = *I00300; sub I00300 { $core[($ib<<12)+$core[227]] = 00301; $pc = ($ib<<12)+$core[227]+1; $code[($ib<<12)+$core[227]] = *emul8; $inh = 0; goto &fetch; }
$core[000301] = 05654; $code[000301] = *L00301; sub L00301 { $pc = ($ib<<12)+$core[172]; $inh = 0; goto &fetch; }
$core[000302] = 00000; $code[000302] = *S00302; sub S00302 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000303] = 07240; $code[000303] = *L00303; sub L00303 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000304] = 00072; $code[000304] = *I00304; sub I00304 { $lac &= (010000|$core[000072]); goto &fetch; }
$core[000305] = 04526; $code[000305] = *I00305; sub I00305 { $core[($ib<<12)+$core[86]] = 00306; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000306] = 01073; $code[000306] = *I00306; sub I00306 { $lac += $core[000073]; goto &fetch; }
$core[000307] = 04526; $code[000307] = *I00307; sub I00307 { $core[($ib<<12)+$core[86]] = 00310; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000310] = 05702; $code[000310] = *I00310; sub I00310 { $pc = ($ib<<12)+$core[194]; $inh = 0; goto &fetch; }
$core[000311] = 00000; $code[000311] = *S00311; sub S00311 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000312] = 07240; $code[000312] = *I00312; sub I00312 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000313] = 00074; $code[000313] = *I00313; sub I00313 { $lac &= (010000|$core[000074]); goto &fetch; }
$core[000314] = 04526; $code[000314] = *L00314; sub L00314 { $core[($ib<<12)+$core[86]] = 00315; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000315] = 05711; $code[000315] = *I00315; sub I00315 { $pc = ($ib<<12)+$core[201]; $inh = 0; goto &fetch; }
$core[000316] = 00000; $code[000316] = *S00316; sub S00316 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000317] = 07240; $code[000317] = *I00317; sub I00317 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000320] = 00075; $code[000320] = *D00320; sub D00320 { $lac &= (010000|$core[000075]); goto &fetch; }
$core[000321] = 04526; $code[000321] = *D00321; sub D00321 { $core[($ib<<12)+$core[86]] = 00322; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000322] = 05716; $code[000322] = *I00322; sub I00322 { $pc = ($ib<<12)+$core[206]; $inh = 0; goto &fetch; }
$core[000323] = 00000; $code[000323] = *S00323; sub S00323 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000324] = 07240; $code[000324] = *L00324; sub L00324 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000325] = 00076; $code[000325] = *I00325; sub I00325 { $lac &= (010000|$core[000076]); goto &fetch; }
$core[000326] = 04526; $code[000326] = *I00326; sub I00326 { $core[($ib<<12)+$core[86]] = 00327; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000327] = 01077; $code[000327] = *I00327; sub I00327 { $lac += $core[000077]; goto &fetch; }
$core[000330] = 04526; $code[000330] = *I00330; sub I00330 { $core[($ib<<12)+$core[86]] = 00331; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000331] = 05723; $code[000331] = *I00331; sub I00331 { $pc = ($ib<<12)+$core[211]; $inh = 0; goto &fetch; }
$core[000332] = 00000; $code[000332] = *S00332; sub S00332 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000333] = 07240; $code[000333] = *I00333; sub I00333 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000334] = 00064; $code[000334] = *I00334; sub I00334 { $lac &= (010000|$core[000064]); goto &fetch; }
$core[000335] = 03102; $code[000335] = *I00335; sub I00335 { $core[000102] = $lac & 07777; $lac &= 010000; $code[000102] = *emul8; goto &fetch; }
$core[000336] = 04527; $code[000336] = *I00336; sub I00336 { $core[($ib<<12)+$core[87]] = 00337; $pc = ($ib<<12)+$core[87]+1; $code[($ib<<12)+$core[87]] = *emul8; $inh = 0; goto &fetch; }
$core[000337] = 05732; $code[000337] = *I00337; sub I00337 { $pc = ($ib<<12)+$core[218]; $inh = 0; goto &fetch; }
$core[000340] = 00362; $code[000340] = *P00340; sub P00340 { $lac &= (010000|$core[000362]); goto &fetch; }
$core[000341] = 00355; $code[000341] = *P00341; sub P00341 { $lac &= (010000|$core[000355]); goto &fetch; }
$core[000342] = 00347; $code[000342] = *P00342; sub P00342 { $lac &= (010000|$core[000347]); goto &fetch; }
$core[000343] = 00370; $code[000343] = *P00343; sub P00343 { $lac &= (010000|$core[000370]); goto &fetch; }
$core[000344] = 00204; $code[000344] = *D00344; sub D00344 { $lac &= (010000|$core[000204]); goto &fetch; }
$core[000345] = 03066; $code[000345] = *L00345; sub L00345 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[000346] = 05222; $code[000346] = *I00346; sub I00346 { $pc = 000222; $inh = 0; goto &fetch; }
$core[000347] = 00000; $code[000347] = *S00347; sub S00347 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000350] = 07240; $code[000350] = *D00350; sub D00350 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000351] = 00066; $code[000351] = *I00351; sub I00351 { $lac &= (010000|$core[000066]); goto &fetch; }
$core[000352] = 03102; $code[000352] = *I00352; sub I00352 { $core[000102] = $lac & 07777; $lac &= 010000; $code[000102] = *emul8; goto &fetch; }
$core[000353] = 04527; $code[000353] = *I00353; sub I00353 { $core[($ib<<12)+$core[87]] = 00354; $pc = ($ib<<12)+$core[87]+1; $code[($ib<<12)+$core[87]] = *emul8; $inh = 0; goto &fetch; }
$core[000354] = 05747; $code[000354] = *I00354; sub I00354 { $pc = ($ib<<12)+$core[231]; $inh = 0; goto &fetch; }
$core[000355] = 00000; $code[000355] = *S00355; sub S00355 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000356] = 07240; $code[000356] = *I00356; sub I00356 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000357] = 00103; $code[000357] = *I00357; sub I00357 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[000360] = 04526; $code[000360] = *I00360; sub I00360 { $core[($ib<<12)+$core[86]] = 00361; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000361] = 05755; $code[000361] = *I00361; sub I00361 { $pc = ($ib<<12)+$core[237]; $inh = 0; goto &fetch; }
$core[000362] = 00000; $code[000362] = *S00362; sub S00362 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000363] = 07240; $code[000363] = *I00363; sub I00363 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000364] = 00063; $code[000364] = *I00364; sub I00364 { $lac &= (010000|$core[000063]); goto &fetch; }
$core[000365] = 03106; $code[000365] = *I00365; sub I00365 { $core[000106] = $lac & 07777; $lac &= 010000; $code[000106] = *emul8; goto &fetch; }
$core[000366] = 04531; $code[000366] = *I00366; sub I00366 { $core[($ib<<12)+$core[89]] = 00367; $pc = ($ib<<12)+$core[89]+1; $code[($ib<<12)+$core[89]] = *emul8; $inh = 0; goto &fetch; }
$core[000367] = 05762; $code[000367] = *I00367; sub I00367 { $pc = ($ib<<12)+$core[242]; $inh = 0; goto &fetch; }
$core[000370] = 00000; $code[000370] = *S00370; sub S00370 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000371] = 07240; $code[000371] = *I00371; sub I00371 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000372] = 00067; $code[000372] = *I00372; sub I00372 { $lac &= (010000|$core[000067]); goto &fetch; }
$core[000373] = 03106; $code[000373] = *I00373; sub I00373 { $core[000106] = $lac & 07777; $lac &= 010000; $code[000106] = *emul8; goto &fetch; }
$core[000374] = 04531; $code[000374] = *I00374; sub I00374 { $core[($ib<<12)+$core[89]] = 00375; $pc = ($ib<<12)+$core[89]+1; $code[($ib<<12)+$core[89]] = *emul8; $inh = 0; goto &fetch; }
$core[000375] = 05770; $code[000375] = *I00375; sub I00375 { $pc = ($ib<<12)+$core[248]; $inh = 0; goto &fetch; }
$core[000400] = 05227; $code[000400] = *P00400; sub P00400 { $pc = 000427; $inh = 0; goto &fetch; }
$core[000401] = 04542; $code[000401] = *L00401; sub L00401 { $core[($ib<<12)+$core[98]] = 00402; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[000402] = 07340; $code[000402] = *L00402; sub L00402 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000403] = 00065; $code[000403] = *I00403; sub I00403 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[000404] = 03063; $code[000404] = *I00404; sub I00404 { $core[000063] = $lac & 07777; $lac &= 010000; $code[000063] = *emul8; goto &fetch; }
$core[000405] = 03064; $code[000405] = *P00405; sub P00405 { $core[000064] = $lac & 07777; $lac &= 010000; $code[000064] = *emul8; goto &fetch; }
$core[000406] = 07040; $code[000406] = *I00406; sub I00406 { $lac ^= 07777; goto &fetch; }
$core[000407] = 00063; $code[000407] = *I00407; sub I00407 { $lac &= (010000|$core[000063]); goto &fetch; }
$core[000410] = 07421; $code[000410] = *I00410; sub I00410 { &emul8; goto &fetch; }
$core[000411] = 03067; $code[000411] = *I00411; sub I00411 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000412] = 07620; $code[000412] = *I00412; sub I00412 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000413] = 05301; $code[000413] = *I00413; sub I00413 { $pc = 000501; $inh = 0; goto &fetch; }
$core[000414] = 07240; $code[000414] = *I00414; sub I00414 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000415] = 03066; $code[000415] = *I00415; sub I00415 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[000416] = 07040; $code[000416] = *L00416; sub L00416 { $lac ^= 07777; goto &fetch; }
$core[000417] = 00067; $code[000417] = *I00417; sub I00417 { $lac &= (010000|$core[000067]); goto &fetch; }
$core[000420] = 07440; $code[000420] = *I00420; sub I00420 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000421] = 05237; $code[000421] = *I00421; sub I00421 { $pc = 000437; $inh = 0; goto &fetch; }
$core[000422] = 07240; $code[000422] = *I00422; sub I00422 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000423] = 00066; $code[000423] = *I00423; sub I00423 { $lac &= (010000|$core[000066]); goto &fetch; }
$core[000424] = 07440; $code[000424] = *I00424; sub I00424 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000425] = 05237; $code[000425] = *I00425; sub I00425 { $pc = 000437; $inh = 0; goto &fetch; }
$core[000426] = 05250; $code[000426] = *I00426; sub I00426 { $pc = 000450; $inh = 0; goto &fetch; }
$core[000427] = 07300; $code[000427] = *L00427; sub L00427 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000430] = 03065; $code[000430] = *I00430; sub I00430 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[000431] = 01060; $code[000431] = *I00431; sub I00431 { $lac += $core[000060]; goto &fetch; }
$core[000432] = 03056; $code[000432] = *I00432; sub I00432 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[000433] = 01061; $code[000433] = *I00433; sub I00433 { $lac += $core[000061]; goto &fetch; }
$core[000434] = 03057; $code[000434] = *I00434; sub I00434 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[000435] = 04535; $code[000435] = *I00435; sub I00435 { $core[($ib<<12)+$core[93]] = 00436; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[000436] = 05201; $code[000436] = *I00436; sub I00436 { $pc = 000401; $inh = 0; goto &fetch; }
$core[000437] = 07604; $code[000437] = *L00437; sub L00437 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000440] = 07106; $code[000440] = *I00440; sub I00440 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000441] = 07004; $code[000441] = *I00441; sub I00441 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000442] = 07430; $code[000442] = *I00442; sub I00442 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000443] = 05256; $code[000443] = *I00443; sub I00443 { $pc = 000456; $inh = 0; goto &fetch; }
$core[000444] = 07604; $code[000444] = *I00444; sub I00444 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000445] = 07104; $code[000445] = *I00445; sub I00445 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000446] = 07430; $code[000446] = *P00446; sub P00446 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000447] = 07402; $code[000447] = *I00447; sub I00447 { $hlt = 1; goto &fetch; }
$core[000450] = 07604; $code[000450] = *L00450; sub L00450 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000451] = 07106; $code[000451] = *I00451; sub I00451 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000452] = 07430; $code[000452] = *I00452; sub I00452 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000453] = 05202; $code[000453] = *I00453; sub I00453 { $pc = 000402; $inh = 0; goto &fetch; }
$core[000454] = 05201; $code[000454] = *D00454; sub D00454 { $pc = 000401; $inh = 0; goto &fetch; }
$core[000455] = 00444; $code[000455] = *D00455; sub D00455 { $lac &= (010000|$core[($df<<12)+$core[36]]); goto &fetch; }
$core[000456] = 07240; $code[000456] = *L00456; sub L00456 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000457] = 00255; $code[000457] = *I00457; sub I00457 { $lac &= (010000|$core[000455]); goto &fetch; }
$core[000460] = 03700; $code[000460] = *I00460; sub I00460 { $core[($df<<12)+$core[320]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[320]] = *emul8; goto &fetch; }
$core[000461] = 04525; $code[000461] = *D00461; sub D00461 { $core[($ib<<12)+$core[85]] = 00462; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[000462] = 04670; $code[000462] = *I00462; sub I00462 { $core[($ib<<12)+$core[312]] = 00463; $pc = ($ib<<12)+$core[312]+1; $code[($ib<<12)+$core[312]] = *emul8; $inh = 0; goto &fetch; }
$core[000463] = 04671; $code[000463] = *I00463; sub I00463 { $core[($ib<<12)+$core[313]] = 00464; $pc = ($ib<<12)+$core[313]+1; $code[($ib<<12)+$core[313]] = *emul8; $inh = 0; goto &fetch; }
$core[000464] = 04672; $code[000464] = *I00464; sub I00464 { $core[($ib<<12)+$core[314]] = 00465; $pc = ($ib<<12)+$core[314]+1; $code[($ib<<12)+$core[314]] = *emul8; $inh = 0; goto &fetch; }
$core[000465] = 04273; $code[000465] = *I00465; sub I00465 { $core[000473] = 00466; $pc = 000473+1; $code[000473] = *emul8; $inh = 0; goto &fetch; }
$core[000466] = 05667; $code[000466] = *I00466; sub I00466 { $pc = ($ib<<12)+$core[311]; $inh = 0; goto &fetch; }
$core[000467] = 00261; $code[000467] = *P00467; sub P00467 { $lac &= (010000|$core[000461]); goto &fetch; }
$core[000470] = 00302; $code[000470] = *P00470; sub P00470 { $lac &= (010000|$core[000502]); goto &fetch; }
$core[000471] = 00311; $code[000471] = *P00471; sub P00471 { $lac &= (010000|$core[000511]); goto &fetch; }
$core[000472] = 00316; $code[000472] = *P00472; sub P00472 { $lac &= (010000|$core[000516]); goto &fetch; }
$core[000473] = 00000; $code[000473] = *S00473; sub S00473 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000474] = 07240; $code[000474] = *I00474; sub I00474 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000475] = 00100; $code[000475] = *I00475; sub I00475 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000476] = 04526; $code[000476] = *I00476; sub I00476 { $core[($ib<<12)+$core[86]] = 00477; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000477] = 05673; $code[000477] = *I00477; sub I00477 { $pc = ($ib<<12)+$core[315]; $inh = 0; goto &fetch; }
$core[000500] = 00254; $code[000500] = *P00500; sub P00500 { $lac &= (010000|$core[000454]); goto &fetch; }
$core[000501] = 03066; $code[000501] = *L00501; sub L00501 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[000502] = 05216; $code[000502] = *D00502; sub D00502 { $pc = 000416; $inh = 0; goto &fetch; }
$core[000503] = 05340; $code[000503] = *I00503; sub I00503 { $pc = 000540; $inh = 0; goto &fetch; }
$core[000504] = 04542; $code[000504] = *L00504; sub L00504 { $core[($ib<<12)+$core[98]] = 00505; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[000505] = 07360; $code[000505] = *L00505; sub L00505 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[000506] = 00065; $code[000506] = *I00506; sub I00506 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[000507] = 03063; $code[000507] = *I00507; sub I00507 { $core[000063] = $lac & 07777; $lac &= 010000; $code[000063] = *emul8; goto &fetch; }
$core[000510] = 07240; $code[000510] = *I00510; sub I00510 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000511] = 03064; $code[000511] = *D00511; sub D00511 { $core[000064] = $lac & 07777; $lac &= 010000; $code[000064] = *emul8; goto &fetch; }
$core[000512] = 07040; $code[000512] = *I00512; sub I00512 { $lac ^= 07777; goto &fetch; }
$core[000513] = 00063; $code[000513] = *I00513; sub I00513 { $lac &= (010000|$core[000063]); goto &fetch; }
$core[000514] = 07421; $code[000514] = *I00514; sub I00514 { &emul8; goto &fetch; }
$core[000515] = 07501; $code[000515] = *I00515; sub I00515 { &emul8; goto &fetch; }
$core[000516] = 03067; $code[000516] = *D00516; sub D00516 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000517] = 07620; $code[000517] = *I00517; sub I00517 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000520] = 05777; $code[000520] = *I00520; sub I00520 { $pc = ($ib<<12)+$core[383]; $inh = 0; goto &fetch; }
$core[000521] = 07240; $code[000521] = *I00521; sub I00521 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000522] = 03066; $code[000522] = *I00522; sub I00522 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[000523] = 07040; $code[000523] = *L00523; sub L00523 { $lac ^= 07777; goto &fetch; }
$core[000524] = 00063; $code[000524] = *I00524; sub I00524 { $lac &= (010000|$core[000063]); goto &fetch; }
$core[000525] = 07140; $code[000525] = *I00525; sub I00525 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000526] = 01067; $code[000526] = *I00526; sub I00526 { $lac += $core[000067]; goto &fetch; }
$core[000527] = 07040; $code[000527] = *I00527; sub I00527 { $lac ^= 07777; goto &fetch; }
$core[000530] = 07450; $code[000530] = *I00530; sub I00530 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000531] = 07430; $code[000531] = *I00531; sub I00531 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000532] = 05350; $code[000532] = *I00532; sub I00532 { $pc = 000550; $inh = 0; goto &fetch; }
$core[000533] = 07240; $code[000533] = *I00533; sub I00533 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000534] = 00066; $code[000534] = *I00534; sub I00534 { $lac &= (010000|$core[000066]); goto &fetch; }
$core[000535] = 07450; $code[000535] = *I00535; sub I00535 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000536] = 05350; $code[000536] = *I00536; sub I00536 { $pc = 000550; $inh = 0; goto &fetch; }
$core[000537] = 05363; $code[000537] = *I00537; sub I00537 { $pc = 000563; $inh = 0; goto &fetch; }
$core[000540] = 07300; $code[000540] = *L00540; sub L00540 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000541] = 03065; $code[000541] = *I00541; sub I00541 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[000542] = 01061; $code[000542] = *I00542; sub I00542 { $lac += $core[000061]; goto &fetch; }
$core[000543] = 03056; $code[000543] = *I00543; sub I00543 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[000544] = 01062; $code[000544] = *I00544; sub I00544 { $lac += $core[000062]; goto &fetch; }
$core[000545] = 03057; $code[000545] = *I00545; sub I00545 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[000546] = 04535; $code[000546] = *I00546; sub I00546 { $core[($ib<<12)+$core[93]] = 00547; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[000547] = 05304; $code[000547] = *I00547; sub I00547 { $pc = 000504; $inh = 0; goto &fetch; }
$core[000550] = 07604; $code[000550] = *L00550; sub L00550 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000551] = 07106; $code[000551] = *I00551; sub I00551 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000552] = 07004; $code[000552] = *I00552; sub I00552 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000553] = 07420; $code[000553] = *I00553; sub I00553 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000554] = 05357; $code[000554] = *I00554; sub I00554 { $pc = 000557; $inh = 0; goto &fetch; }
$core[000555] = 04776; $code[000555] = *I00555; sub I00555 { $core[($ib<<12)+$core[382]] = 00556; $pc = ($ib<<12)+$core[382]+1; $code[($ib<<12)+$core[382]] = *emul8; $inh = 0; goto &fetch; }
$core[000556] = 04775; $code[000556] = *I00556; sub I00556 { $core[($ib<<12)+$core[381]] = 00557; $pc = ($ib<<12)+$core[381]+1; $code[($ib<<12)+$core[381]] = *emul8; $inh = 0; goto &fetch; }
$core[000557] = 07604; $code[000557] = *L00557; sub L00557 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000560] = 07104; $code[000560] = *I00560; sub I00560 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000561] = 07430; $code[000561] = *I00561; sub I00561 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000562] = 07402; $code[000562] = *I00562; sub I00562 { $hlt = 1; goto &fetch; }
$core[000563] = 07604; $code[000563] = *L00563; sub L00563 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000564] = 07106; $code[000564] = *I00564; sub I00564 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000565] = 07430; $code[000565] = *I00565; sub I00565 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000566] = 05305; $code[000566] = *I00566; sub I00566 { $pc = 000505; $inh = 0; goto &fetch; }
$core[000567] = 05304; $code[000567] = *I00567; sub I00567 { $pc = 000504; $inh = 0; goto &fetch; }
$core[000575] = 00605; $code[000575] = *P00575; sub P00575 { $lac &= (010000|$core[($df<<12)+$core[261]]); goto &fetch; }
$core[000576] = 00600; $code[000576] = *P00576; sub P00576 { $lac &= (010000|$core[($df<<12)+$core[256]]); goto &fetch; }
$core[000577] = 00646; $code[000577] = *P00577; sub P00577 { $lac &= (010000|$core[($df<<12)+$core[294]]); goto &fetch; }
$core[000600] = 00000; $code[000600] = *S00600; sub S00600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000601] = 04525; $code[000601] = *I00601; sub I00601 { $core[($ib<<12)+$core[85]] = 00602; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[000602] = 04777; $code[000602] = *I00602; sub I00602 { $core[($ib<<12)+$core[511]] = 00603; $pc = ($ib<<12)+$core[511]+1; $code[($ib<<12)+$core[511]] = *emul8; $inh = 0; goto &fetch; }
$core[000603] = 04232; $code[000603] = *I00603; sub I00603 { $core[000632] = 00604; $pc = 000632+1; $code[000632] = *emul8; $inh = 0; goto &fetch; }
$core[000604] = 05600; $code[000604] = *I00604; sub I00604 { $pc = ($ib<<12)+$core[384]; $inh = 0; goto &fetch; }
$core[000605] = 00000; $code[000605] = *S00605; sub S00605 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000606] = 04576; $code[000606] = *I00606; sub I00606 { $core[($ib<<12)+$core[126]] = 00607; $pc = ($ib<<12)+$core[126]+1; $code[($ib<<12)+$core[126]] = *emul8; $inh = 0; goto &fetch; }
$core[000607] = 04524; $code[000607] = *I00607; sub I00607 { $core[($ib<<12)+$core[84]] = 00610; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[000610] = 04451; $code[000610] = *I00610; sub I00610 { $core[($ib<<12)+$core[41]] = 00611; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[000611] = 07773; $code[000611] = *I00611; sub I00611 { &emul8; goto &fetch; }
$core[000612] = 04776; $code[000612] = *I00612; sub I00612 { $core[($ib<<12)+$core[510]] = 00613; $pc = ($ib<<12)+$core[510]+1; $code[($ib<<12)+$core[510]] = *emul8; $inh = 0; goto &fetch; }
$core[000613] = 04455; $code[000613] = *I00613; sub I00613 { $core[($ib<<12)+$core[45]] = 00614; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[000614] = 04775; $code[000614] = *I00614; sub I00614 { $core[($ib<<12)+$core[509]] = 00615; $pc = ($ib<<12)+$core[509]+1; $code[($ib<<12)+$core[509]] = *emul8; $inh = 0; goto &fetch; }
$core[000615] = 04454; $code[000615] = *I00615; sub I00615 { $core[($ib<<12)+$core[44]] = 00616; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[000616] = 04774; $code[000616] = *I00616; sub I00616 { $core[($ib<<12)+$core[508]] = 00617; $pc = ($ib<<12)+$core[508]+1; $code[($ib<<12)+$core[508]] = *emul8; $inh = 0; goto &fetch; }
$core[000617] = 04524; $code[000617] = *I00617; sub I00617 { $core[($ib<<12)+$core[84]] = 00620; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[000620] = 04777; $code[000620] = *I00620; sub I00620 { $core[($ib<<12)+$core[511]] = 00621; $pc = ($ib<<12)+$core[511]+1; $code[($ib<<12)+$core[511]] = *emul8; $inh = 0; goto &fetch; }
$core[000621] = 04773; $code[000621] = *I00621; sub I00621 { $core[($ib<<12)+$core[507]] = 00622; $pc = ($ib<<12)+$core[507]+1; $code[($ib<<12)+$core[507]] = *emul8; $inh = 0; goto &fetch; }
$core[000622] = 04454; $code[000622] = *I00622; sub I00622 { $core[($ib<<12)+$core[44]] = 00623; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[000623] = 04777; $code[000623] = *I00623; sub I00623 { $core[($ib<<12)+$core[511]] = 00624; $pc = ($ib<<12)+$core[511]+1; $code[($ib<<12)+$core[511]] = *emul8; $inh = 0; goto &fetch; }
$core[000624] = 04241; $code[000624] = *I00624; sub I00624 { $core[000641] = 00625; $pc = 000641+1; $code[000641] = *emul8; $inh = 0; goto &fetch; }
$core[000625] = 04455; $code[000625] = *I00625; sub I00625 { $core[($ib<<12)+$core[45]] = 00626; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[000626] = 04772; $code[000626] = *I00626; sub I00626 { $core[($ib<<12)+$core[506]] = 00627; $pc = ($ib<<12)+$core[506]+1; $code[($ib<<12)+$core[506]] = *emul8; $inh = 0; goto &fetch; }
$core[000627] = 04454; $code[000627] = *I00627; sub I00627 { $core[($ib<<12)+$core[44]] = 00630; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[000630] = 04771; $code[000630] = *I00630; sub I00630 { $core[($ib<<12)+$core[505]] = 00631; $pc = ($ib<<12)+$core[505]+1; $code[($ib<<12)+$core[505]] = *emul8; $inh = 0; goto &fetch; }
$core[000631] = 05605; $code[000631] = *I00631; sub I00631 { $pc = ($ib<<12)+$core[389]; $inh = 0; goto &fetch; }
$core[000632] = 00000; $code[000632] = *S00632; sub S00632 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000633] = 07240; $code[000633] = *I00633; sub I00633 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000634] = 00076; $code[000634] = *I00634; sub I00634 { $lac &= (010000|$core[000076]); goto &fetch; }
$core[000635] = 04526; $code[000635] = *I00635; sub I00635 { $core[($ib<<12)+$core[86]] = 00636; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000636] = 01075; $code[000636] = *I00636; sub I00636 { $lac += $core[000075]; goto &fetch; }
$core[000637] = 04526; $code[000637] = *I00637; sub I00637 { $core[($ib<<12)+$core[86]] = 00640; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000640] = 05632; $code[000640] = *I00640; sub I00640 { $pc = ($ib<<12)+$core[410]; $inh = 0; goto &fetch; }
$core[000641] = 00000; $code[000641] = *S00641; sub S00641 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000642] = 07240; $code[000642] = *I00642; sub I00642 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000643] = 00076; $code[000643] = *I00643; sub I00643 { $lac &= (010000|$core[000076]); goto &fetch; }
$core[000644] = 04526; $code[000644] = *I00644; sub I00644 { $core[($ib<<12)+$core[86]] = 00645; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000645] = 05641; $code[000645] = *I00645; sub I00645 { $pc = ($ib<<12)+$core[417]; $inh = 0; goto &fetch; }
$core[000646] = 03066; $code[000646] = *L00646; sub L00646 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[000647] = 05770; $code[000647] = *I00647; sub I00647 { $pc = ($ib<<12)+$core[504]; $inh = 0; goto &fetch; }
$core[000650] = 04304; $code[000650] = *L00650; sub L00650 { $core[000704] = 00651; $pc = 000704+1; $code[000704] = *emul8; $inh = 0; goto &fetch; }
$core[000651] = 04542; $code[000651] = *L00651; sub L00651 { $core[($ib<<12)+$core[98]] = 00652; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[000652] = 07340; $code[000652] = *L00652; sub L00652 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000653] = 00065; $code[000653] = *I00653; sub I00653 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[000654] = 03063; $code[000654] = *I00654; sub I00654 { $core[000063] = $lac & 07777; $lac &= 010000; $code[000063] = *emul8; goto &fetch; }
$core[000655] = 03064; $code[000655] = *I00655; sub I00655 { $core[000064] = $lac & 07777; $lac &= 010000; $code[000064] = *emul8; goto &fetch; }
$core[000656] = 07040; $code[000656] = *I00656; sub I00656 { $lac ^= 07777; goto &fetch; }
$core[000657] = 00063; $code[000657] = *I00657; sub I00657 { $lac &= (010000|$core[000063]); goto &fetch; }
$core[000660] = 07421; $code[000660] = *I00660; sub I00660 { &emul8; goto &fetch; }
$core[000661] = 07501; $code[000661] = *I00661; sub I00661 { &emul8; goto &fetch; }
$core[000662] = 03067; $code[000662] = *I00662; sub I00662 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000663] = 07620; $code[000663] = *I00663; sub I00663 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000664] = 05340; $code[000664] = *I00664; sub I00664 { $pc = 000740; $inh = 0; goto &fetch; }
$core[000665] = 07240; $code[000665] = *I00665; sub I00665 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000666] = 03066; $code[000666] = *I00666; sub I00666 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[000667] = 07040; $code[000667] = *L00667; sub L00667 { $lac ^= 07777; goto &fetch; }
$core[000670] = 00063; $code[000670] = *I00670; sub I00670 { $lac &= (010000|$core[000063]); goto &fetch; }
$core[000671] = 07140; $code[000671] = *I00671; sub I00671 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000672] = 01067; $code[000672] = *I00672; sub I00672 { $lac += $core[000067]; goto &fetch; }
$core[000673] = 07040; $code[000673] = *I00673; sub I00673 { $lac ^= 07777; goto &fetch; }
$core[000674] = 07450; $code[000674] = *I00674; sub I00674 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000675] = 07430; $code[000675] = *I00675; sub I00675 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000676] = 05314; $code[000676] = *I00676; sub I00676 { $pc = 000714; $inh = 0; goto &fetch; }
$core[000677] = 07240; $code[000677] = *I00677; sub I00677 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000700] = 00066; $code[000700] = *I00700; sub I00700 { $lac &= (010000|$core[000066]); goto &fetch; }
$core[000701] = 07440; $code[000701] = *I00701; sub I00701 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000702] = 05314; $code[000702] = *D00702; sub D00702 { $pc = 000714; $inh = 0; goto &fetch; }
$core[000703] = 05330; $code[000703] = *I00703; sub I00703 { $pc = 000730; $inh = 0; goto &fetch; }
$core[000704] = 07300; $code[000704] = *I00704; sub I00704 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000705] = 03065; $code[000705] = *I00705; sub I00705 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[000706] = 01062; $code[000706] = *I00706; sub I00706 { $lac += $core[000062]; goto &fetch; }
$core[000707] = 03056; $code[000707] = *I00707; sub I00707 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[000710] = 01107; $code[000710] = *I00710; sub I00710 { $lac += $core[000107]; goto &fetch; }
$core[000711] = 03057; $code[000711] = *D00711; sub D00711 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[000712] = 04535; $code[000712] = *I00712; sub I00712 { $core[($ib<<12)+$core[93]] = 00713; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[000713] = 05251; $code[000713] = *I00713; sub I00713 { $pc = 000651; $inh = 0; goto &fetch; }
$core[000714] = 07604; $code[000714] = *L00714; sub L00714 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000715] = 07106; $code[000715] = *I00715; sub I00715 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000716] = 07004; $code[000716] = *I00716; sub I00716 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000717] = 07420; $code[000717] = *I00717; sub I00717 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000720] = 05324; $code[000720] = *I00720; sub I00720 { $pc = 000724; $inh = 0; goto &fetch; }
$core[000721] = 04735; $code[000721] = *I00721; sub I00721 { $core[($ib<<12)+$core[477]] = 00722; $pc = ($ib<<12)+$core[477]+1; $code[($ib<<12)+$core[477]] = *emul8; $inh = 0; goto &fetch; }
$core[000722] = 04736; $code[000722] = *I00722; sub I00722 { $core[($ib<<12)+$core[478]] = 00723; $pc = ($ib<<12)+$core[478]+1; $code[($ib<<12)+$core[478]] = *emul8; $inh = 0; goto &fetch; }
$core[000723] = 04737; $code[000723] = *D00723; sub D00723 { $core[($ib<<12)+$core[479]] = 00724; $pc = ($ib<<12)+$core[479]+1; $code[($ib<<12)+$core[479]] = *emul8; $inh = 0; goto &fetch; }
$core[000724] = 07604; $code[000724] = *L00724; sub L00724 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000725] = 07104; $code[000725] = *I00725; sub I00725 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000726] = 07430; $code[000726] = *I00726; sub I00726 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000727] = 07402; $code[000727] = *I00727; sub I00727 { $hlt = 1; goto &fetch; }
$core[000730] = 07604; $code[000730] = *L00730; sub L00730 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000731] = 07106; $code[000731] = *I00731; sub I00731 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000732] = 07430; $code[000732] = *D00732; sub D00732 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000733] = 05252; $code[000733] = *I00733; sub I00733 { $pc = 000652; $inh = 0; goto &fetch; }
$core[000734] = 05251; $code[000734] = *I00734; sub I00734 { $pc = 000651; $inh = 0; goto &fetch; }
$core[000735] = 00600; $code[000735] = *P00735; sub P00735 { $lac &= (010000|$core[($df<<12)+$core[384]]); goto &fetch; }
$core[000736] = 00473; $code[000736] = *P00736; sub P00736 { $lac &= (010000|$core[($df<<12)+$core[59]]); goto &fetch; }
$core[000737] = 00605; $code[000737] = *P00737; sub P00737 { $lac &= (010000|$core[($df<<12)+$core[389]]); goto &fetch; }
$core[000740] = 03066; $code[000740] = *L00740; sub L00740 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[000741] = 05267; $code[000741] = *I00741; sub I00741 { $pc = 000667; $inh = 0; goto &fetch; }
$core[000770] = 00523; $code[000770] = *P00770; sub P00770 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[000771] = 00370; $code[000771] = *P00771; sub P00771 { $lac &= (010000|$core[000770]); goto &fetch; }
$core[000772] = 00347; $code[000772] = *P00772; sub P00772 { $lac &= (010000|$core[000747]); goto &fetch; }
$core[000773] = 00311; $code[000773] = *P00773; sub P00773 { $lac &= (010000|$core[000711]); goto &fetch; }
$core[000774] = 00362; $code[000774] = *P00774; sub P00774 { $lac &= (010000|$core[000762]); goto &fetch; }
$core[000775] = 00332; $code[000775] = *P00775; sub P00775 { $lac &= (010000|$core[000732]); goto &fetch; }
$core[000776] = 00323; $code[000776] = *P00776; sub P00776 { $lac &= (010000|$core[000723]); goto &fetch; }
$core[000777] = 00302; $code[000777] = *P00777; sub P00777 { $lac &= (010000|$core[000702]); goto &fetch; }
$core[001000] = 05232; $code[001000] = *P01000; sub P01000 { $pc = 001032; $inh = 0; goto &fetch; }
$core[001001] = 04542; $code[001001] = *L01001; sub L01001 { $core[($ib<<12)+$core[98]] = 01002; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001002] = 07360; $code[001002] = *L01002; sub L01002 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[001003] = 00065; $code[001003] = *I01003; sub I01003 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[001004] = 07040; $code[001004] = *I01004; sub I01004 { $lac ^= 07777; goto &fetch; }
$core[001005] = 03063; $code[001005] = *I01005; sub I01005 { $core[000063] = $lac & 07777; $lac &= 010000; $code[000063] = *emul8; goto &fetch; }
$core[001006] = 07040; $code[001006] = *I01006; sub I01006 { $lac ^= 07777; goto &fetch; }
$core[001007] = 03064; $code[001007] = *I01007; sub I01007 { $core[000064] = $lac & 07777; $lac &= 010000; $code[000064] = *emul8; goto &fetch; }
$core[001010] = 01065; $code[001010] = *D01010; sub D01010 { $lac += $core[000065]; goto &fetch; }
$core[001011] = 07421; $code[001011] = *I01011; sub I01011 { &emul8; goto &fetch; }
$core[001012] = 01063; $code[001012] = *I01012; sub I01012 { $lac += $core[000063]; goto &fetch; }
$core[001013] = 07501; $code[001013] = *I01013; sub I01013 { &emul8; goto &fetch; }
$core[001014] = 03067; $code[001014] = *I01014; sub I01014 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[001015] = 07620; $code[001015] = *I01015; sub I01015 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001016] = 05333; $code[001016] = *I01016; sub I01016 { $pc = 001133; $inh = 0; goto &fetch; }
$core[001017] = 07240; $code[001017] = *I01017; sub I01017 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001020] = 03066; $code[001020] = *I01020; sub I01020 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[001021] = 01067; $code[001021] = *L01021; sub L01021 { $lac += $core[000067]; goto &fetch; }
$core[001022] = 07040; $code[001022] = *I01022; sub I01022 { $lac ^= 07777; goto &fetch; }
$core[001023] = 07440; $code[001023] = *D01023; sub D01023 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001024] = 05242; $code[001024] = *I01024; sub I01024 { $pc = 001042; $inh = 0; goto &fetch; }
$core[001025] = 07040; $code[001025] = *I01025; sub I01025 { $lac ^= 07777; goto &fetch; }
$core[001026] = 00066; $code[001026] = *I01026; sub I01026 { $lac &= (010000|$core[000066]); goto &fetch; }
$core[001027] = 07450; $code[001027] = *I01027; sub I01027 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001030] = 05242; $code[001030] = *I01030; sub I01030 { $pc = 001042; $inh = 0; goto &fetch; }
$core[001031] = 05255; $code[001031] = *I01031; sub I01031 { $pc = 001055; $inh = 0; goto &fetch; }
$core[001032] = 07300; $code[001032] = *L01032; sub L01032 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001033] = 03065; $code[001033] = *I01033; sub I01033 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[001034] = 01107; $code[001034] = *I01034; sub I01034 { $lac += $core[000107]; goto &fetch; }
$core[001035] = 03056; $code[001035] = *I01035; sub I01035 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001036] = 01110; $code[001036] = *I01036; sub I01036 { $lac += $core[000110]; goto &fetch; }
$core[001037] = 03057; $code[001037] = *I01037; sub I01037 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[001040] = 04535; $code[001040] = *D01040; sub D01040 { $core[($ib<<12)+$core[93]] = 01041; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[001041] = 05201; $code[001041] = *D01041; sub D01041 { $pc = 001001; $inh = 0; goto &fetch; }
$core[001042] = 07604; $code[001042] = *L01042; sub L01042 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001043] = 07106; $code[001043] = *I01043; sub I01043 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[001044] = 07004; $code[001044] = *I01044; sub I01044 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001045] = 07420; $code[001045] = *I01045; sub I01045 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001046] = 05251; $code[001046] = *I01046; sub I01046 { $pc = 001051; $inh = 0; goto &fetch; }
$core[001047] = 04662; $code[001047] = *I01047; sub I01047 { $core[($ib<<12)+$core[562]] = 01050; $pc = ($ib<<12)+$core[562]+1; $code[($ib<<12)+$core[562]] = *emul8; $inh = 0; goto &fetch; }
$core[001050] = 04263; $code[001050] = *I01050; sub I01050 { $core[001063] = 01051; $pc = 001063+1; $code[001063] = *emul8; $inh = 0; goto &fetch; }
$core[001051] = 07604; $code[001051] = *L01051; sub L01051 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001052] = 07104; $code[001052] = *I01052; sub I01052 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001053] = 07430; $code[001053] = *I01053; sub I01053 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001054] = 07402; $code[001054] = *I01054; sub I01054 { $hlt = 1; goto &fetch; }
$core[001055] = 07604; $code[001055] = *L01055; sub L01055 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001056] = 07106; $code[001056] = *I01056; sub I01056 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[001057] = 07430; $code[001057] = *I01057; sub I01057 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001060] = 05202; $code[001060] = *I01060; sub I01060 { $pc = 001002; $inh = 0; goto &fetch; }
$core[001061] = 05201; $code[001061] = *I01061; sub I01061 { $pc = 001001; $inh = 0; goto &fetch; }
$core[001062] = 00600; $code[001062] = *P01062; sub P01062 { $lac &= (010000|$core[($df<<12)+$core[512]]); goto &fetch; }
$core[001063] = 00000; $code[001063] = *S01063; sub S01063 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001064] = 04326; $code[001064] = *I01064; sub I01064 { $core[001126] = 01065; $pc = 001126+1; $code[001126] = *emul8; $inh = 0; goto &fetch; }
$core[001065] = 04576; $code[001065] = *I01065; sub I01065 { $core[($ib<<12)+$core[126]] = 01066; $pc = ($ib<<12)+$core[126]+1; $code[($ib<<12)+$core[126]] = *emul8; $inh = 0; goto &fetch; }
$core[001066] = 04524; $code[001066] = *L01066; sub L01066 { $core[($ib<<12)+$core[84]] = 01067; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[001067] = 04455; $code[001067] = *I01067; sub I01067 { $core[($ib<<12)+$core[45]] = 01070; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[001070] = 04454; $code[001070] = *I01070; sub I01070 { $core[($ib<<12)+$core[44]] = 01071; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[001071] = 04777; $code[001071] = *I01071; sub I01071 { $core[($ib<<12)+$core[639]] = 01072; $pc = ($ib<<12)+$core[639]+1; $code[($ib<<12)+$core[639]] = *emul8; $inh = 0; goto &fetch; }
$core[001072] = 04455; $code[001072] = *I01072; sub I01072 { $core[($ib<<12)+$core[45]] = 01073; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[001073] = 04776; $code[001073] = *I01073; sub I01073 { $core[($ib<<12)+$core[638]] = 01074; $pc = ($ib<<12)+$core[638]+1; $code[($ib<<12)+$core[638]] = *emul8; $inh = 0; goto &fetch; }
$core[001074] = 04454; $code[001074] = *I01074; sub I01074 { $core[($ib<<12)+$core[44]] = 01075; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[001075] = 04775; $code[001075] = *I01075; sub I01075 { $core[($ib<<12)+$core[637]] = 01076; $pc = ($ib<<12)+$core[637]+1; $code[($ib<<12)+$core[637]] = *emul8; $inh = 0; goto &fetch; }
$core[001076] = 04524; $code[001076] = *I01076; sub I01076 { $core[($ib<<12)+$core[84]] = 01077; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[001077] = 04455; $code[001077] = *I01077; sub I01077 { $core[($ib<<12)+$core[45]] = 01100; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[001100] = 04454; $code[001100] = *I01100; sub I01100 { $core[($ib<<12)+$core[44]] = 01101; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[001101] = 04774; $code[001101] = *I01101; sub I01101 { $core[($ib<<12)+$core[636]] = 01102; $pc = ($ib<<12)+$core[636]+1; $code[($ib<<12)+$core[636]] = *emul8; $inh = 0; goto &fetch; }
$core[001102] = 04455; $code[001102] = *D01102; sub D01102 { $core[($ib<<12)+$core[45]] = 01103; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[001103] = 04455; $code[001103] = *I01103; sub I01103 { $core[($ib<<12)+$core[45]] = 01104; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[001104] = 07200; $code[001104] = *I01104; sub I01104 { $lac &= 010000; goto &fetch; }
$core[001105] = 01065; $code[001105] = *I01105; sub I01105 { $lac += $core[000065]; goto &fetch; }
$core[001106] = 03063; $code[001106] = *I01106; sub I01106 { $core[000063] = $lac & 07777; $lac &= 010000; $code[000063] = *emul8; goto &fetch; }
$core[001107] = 04775; $code[001107] = *I01107; sub I01107 { $core[($ib<<12)+$core[637]] = 01110; $pc = ($ib<<12)+$core[637]+1; $code[($ib<<12)+$core[637]] = *emul8; $inh = 0; goto &fetch; }
$core[001110] = 04524; $code[001110] = *I01110; sub I01110 { $core[($ib<<12)+$core[84]] = 01111; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[001111] = 04774; $code[001111] = *I01111; sub I01111 { $core[($ib<<12)+$core[636]] = 01112; $pc = ($ib<<12)+$core[636]+1; $code[($ib<<12)+$core[636]] = *emul8; $inh = 0; goto &fetch; }
$core[001112] = 04321; $code[001112] = *I01112; sub I01112 { $core[001121] = 01113; $pc = 001121+1; $code[001121] = *emul8; $inh = 0; goto &fetch; }
$core[001113] = 04777; $code[001113] = *I01113; sub I01113 { $core[($ib<<12)+$core[639]] = 01114; $pc = ($ib<<12)+$core[639]+1; $code[($ib<<12)+$core[639]] = *emul8; $inh = 0; goto &fetch; }
$core[001114] = 04455; $code[001114] = *I01114; sub I01114 { $core[($ib<<12)+$core[45]] = 01115; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[001115] = 04773; $code[001115] = *I01115; sub I01115 { $core[($ib<<12)+$core[635]] = 01116; $pc = ($ib<<12)+$core[635]+1; $code[($ib<<12)+$core[635]] = *emul8; $inh = 0; goto &fetch; }
$core[001116] = 04454; $code[001116] = *I01116; sub I01116 { $core[($ib<<12)+$core[44]] = 01117; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[001117] = 04772; $code[001117] = *I01117; sub I01117 { $core[($ib<<12)+$core[634]] = 01120; $pc = ($ib<<12)+$core[634]+1; $code[($ib<<12)+$core[634]] = *emul8; $inh = 0; goto &fetch; }
$core[001120] = 05663; $code[001120] = *I01120; sub I01120 { $pc = ($ib<<12)+$core[563]; $inh = 0; goto &fetch; }
$core[001121] = 00000; $code[001121] = *S01121; sub S01121 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001122] = 07240; $code[001122] = *I01122; sub I01122 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001123] = 00111; $code[001123] = *D01123; sub D01123 { $lac &= (010000|$core[000111]); goto &fetch; }
$core[001124] = 04526; $code[001124] = *I01124; sub I01124 { $core[($ib<<12)+$core[86]] = 01125; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001125] = 05721; $code[001125] = *I01125; sub I01125 { $pc = ($ib<<12)+$core[593]; $inh = 0; goto &fetch; }
$core[001126] = 00000; $code[001126] = *S01126; sub S01126 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001127] = 07240; $code[001127] = *I01127; sub I01127 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001130] = 00113; $code[001130] = *I01130; sub I01130 { $lac &= (010000|$core[000113]); goto &fetch; }
$core[001131] = 04526; $code[001131] = *I01131; sub I01131 { $core[($ib<<12)+$core[86]] = 01132; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001132] = 05726; $code[001132] = *D01132; sub D01132 { $pc = ($ib<<12)+$core[598]; $inh = 0; goto &fetch; }
$core[001133] = 03066; $code[001133] = *L01133; sub L01133 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[001134] = 05221; $code[001134] = *I01134; sub I01134 { $pc = 001021; $inh = 0; goto &fetch; }
$core[001135] = 05771; $code[001135] = *I01135; sub I01135 { $pc = ($ib<<12)+$core[633]; $inh = 0; goto &fetch; }
$core[001136] = 04542; $code[001136] = *L01136; sub L01136 { $core[($ib<<12)+$core[98]] = 01137; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001137] = 07340; $code[001137] = *L01137; sub L01137 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001140] = 00065; $code[001140] = *I01140; sub I01140 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[001141] = 07040; $code[001141] = *I01141; sub I01141 { $lac ^= 07777; goto &fetch; }
$core[001142] = 03063; $code[001142] = *I01142; sub I01142 { $core[000063] = $lac & 07777; $lac &= 010000; $code[000063] = *emul8; goto &fetch; }
$core[001143] = 03064; $code[001143] = *I01143; sub I01143 { $core[000064] = $lac & 07777; $lac &= 010000; $code[000064] = *emul8; goto &fetch; }
$core[001144] = 07040; $code[001144] = *I01144; sub I01144 { $lac ^= 07777; goto &fetch; }
$core[001145] = 00065; $code[001145] = *I01145; sub I01145 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[001146] = 07421; $code[001146] = *I01146; sub I01146 { &emul8; goto &fetch; }
$core[001147] = 01063; $code[001147] = *D01147; sub D01147 { $lac += $core[000063]; goto &fetch; }
$core[001150] = 07501; $code[001150] = *I01150; sub I01150 { &emul8; goto &fetch; }
$core[001151] = 03067; $code[001151] = *I01151; sub I01151 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[001152] = 07620; $code[001152] = *I01152; sub I01152 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001153] = 07410; $code[001153] = *I01153; sub I01153 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001154] = 07240; $code[001154] = *I01154; sub I01154 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001155] = 03066; $code[001155] = *I01155; sub I01155 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[001156] = 01067; $code[001156] = *I01156; sub I01156 { $lac += $core[000067]; goto &fetch; }
$core[001157] = 07040; $code[001157] = *I01157; sub I01157 { $lac ^= 07777; goto &fetch; }
$core[001160] = 07440; $code[001160] = *I01160; sub I01160 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001161] = 05770; $code[001161] = *I01161; sub I01161 { $pc = ($ib<<12)+$core[632]; $inh = 0; goto &fetch; }
$core[001162] = 07040; $code[001162] = *D01162; sub D01162 { $lac ^= 07777; goto &fetch; }
$core[001163] = 00066; $code[001163] = *I01163; sub I01163 { $lac &= (010000|$core[000066]); goto &fetch; }
$core[001164] = 07440; $code[001164] = *I01164; sub I01164 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001165] = 05770; $code[001165] = *I01165; sub I01165 { $pc = ($ib<<12)+$core[632]; $inh = 0; goto &fetch; }
$core[001166] = 05767; $code[001166] = *I01166; sub I01166 { $pc = ($ib<<12)+$core[631]; $inh = 0; goto &fetch; }
$core[001167] = 01223; $code[001167] = *P01167; sub P01167 { $lac += $core[001023]; goto &fetch; }
$core[001170] = 01210; $code[001170] = *P01170; sub P01170 { $lac += $core[001010]; goto &fetch; }
$core[001171] = 01200; $code[001171] = *P01171; sub P01171 { $lac += $core[001000]; goto &fetch; }
$core[001172] = 00370; $code[001172] = *P01172; sub P01172 { $lac &= (010000|$core[001170]); goto &fetch; }
$core[001173] = 00347; $code[001173] = *P01173; sub P01173 { $lac &= (010000|$core[001147]); goto &fetch; }
$core[001174] = 00302; $code[001174] = *P01174; sub P01174 { $lac &= (010000|$core[001102]); goto &fetch; }
$core[001175] = 00362; $code[001175] = *P01175; sub P01175 { $lac &= (010000|$core[001162]); goto &fetch; }
$core[001176] = 00332; $code[001176] = *P01176; sub P01176 { $lac &= (010000|$core[001132]); goto &fetch; }
$core[001177] = 00323; $code[001177] = *P01177; sub P01177 { $lac &= (010000|$core[001123]); goto &fetch; }
$core[001200] = 07300; $code[001200] = *P01200; sub P01200 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001201] = 03065; $code[001201] = *I01201; sub I01201 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[001202] = 01110; $code[001202] = *I01202; sub I01202 { $lac += $core[000110]; goto &fetch; }
$core[001203] = 03056; $code[001203] = *I01203; sub I01203 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001204] = 01377; $code[001204] = *I01204; sub I01204 { $lac += $core[001377]; goto &fetch; }
$core[001205] = 03057; $code[001205] = *I01205; sub I01205 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[001206] = 04535; $code[001206] = *I01206; sub I01206 { $core[($ib<<12)+$core[93]] = 01207; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[001207] = 05776; $code[001207] = *I01207; sub I01207 { $pc = ($ib<<12)+$core[766]; $inh = 0; goto &fetch; }
$core[001210] = 07604; $code[001210] = *L01210; sub L01210 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001211] = 07106; $code[001211] = *I01211; sub I01211 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[001212] = 07004; $code[001212] = *I01212; sub I01212 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001213] = 07420; $code[001213] = *I01213; sub I01213 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001214] = 05217; $code[001214] = *I01214; sub I01214 { $pc = 001217; $inh = 0; goto &fetch; }
$core[001215] = 04630; $code[001215] = *I01215; sub I01215 { $core[($ib<<12)+$core[664]] = 01216; $pc = ($ib<<12)+$core[664]+1; $code[($ib<<12)+$core[664]] = *emul8; $inh = 0; goto &fetch; }
$core[001216] = 05233; $code[001216] = *I01216; sub I01216 { $pc = 001233; $inh = 0; goto &fetch; }
$core[001217] = 07604; $code[001217] = *L01217; sub L01217 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001220] = 07104; $code[001220] = *I01220; sub I01220 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001221] = 07430; $code[001221] = *I01221; sub I01221 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001222] = 07402; $code[001222] = *I01222; sub I01222 { $hlt = 1; goto &fetch; }
$core[001223] = 07604; $code[001223] = *L01223; sub L01223 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001224] = 07106; $code[001224] = *I01224; sub I01224 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[001225] = 07430; $code[001225] = *I01225; sub I01225 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001226] = 05775; $code[001226] = *I01226; sub I01226 { $pc = ($ib<<12)+$core[765]; $inh = 0; goto &fetch; }
$core[001227] = 05776; $code[001227] = *I01227; sub I01227 { $pc = ($ib<<12)+$core[766]; $inh = 0; goto &fetch; }
$core[001230] = 00600; $code[001230] = *P01230; sub P01230 { $lac &= (010000|$core[($df<<12)+$core[640]]); goto &fetch; }
$core[001231] = 01217; $code[001231] = *D01231; sub D01231 { $lac += $core[001217]; goto &fetch; }
$core[001232] = 01063; $code[001232] = *P01232; sub P01232 { $lac += $core[000063]; goto &fetch; }
$core[001233] = 04240; $code[001233] = *L01233; sub L01233 { $core[001240] = 01234; $pc = 001240+1; $code[001240] = *emul8; $inh = 0; goto &fetch; }
$core[001234] = 04576; $code[001234] = *I01234; sub I01234 { $core[($ib<<12)+$core[126]] = 01235; $pc = ($ib<<12)+$core[126]+1; $code[($ib<<12)+$core[126]] = *emul8; $inh = 0; goto &fetch; }
$core[001235] = 01231; $code[001235] = *I01235; sub I01235 { $lac += $core[001231]; goto &fetch; }
$core[001236] = 03632; $code[001236] = *I01236; sub I01236 { $core[($df<<12)+$core[666]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[666]] = *emul8; goto &fetch; }
$core[001237] = 05774; $code[001237] = *I01237; sub I01237 { $pc = ($ib<<12)+$core[764]; $inh = 0; goto &fetch; }
$core[001240] = 00000; $code[001240] = *S01240; sub S01240 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001241] = 07240; $code[001241] = *I01241; sub I01241 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001242] = 00112; $code[001242] = *I01242; sub I01242 { $lac &= (010000|$core[000112]); goto &fetch; }
$core[001243] = 04526; $code[001243] = *I01243; sub I01243 { $core[($ib<<12)+$core[86]] = 01244; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001244] = 05640; $code[001244] = *I01244; sub I01244 { $pc = ($ib<<12)+$core[672]; $inh = 0; goto &fetch; }
$core[001245] = 04315; $code[001245] = *D01245; sub D01245 { $core[001315] = 01246; $pc = 001315+1; $code[001315] = *emul8; $inh = 0; goto &fetch; }
$core[001246] = 04263; $code[001246] = *L01246; sub L01246 { $core[001263] = 01247; $pc = 001263+1; $code[001263] = *emul8; $inh = 0; goto &fetch; }
$core[001247] = 01021; $code[001247] = *L01247; sub L01247 { $lac += $core[000021]; goto &fetch; }
$core[001250] = 07104; $code[001250] = *I01250; sub I01250 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001251] = 01023; $code[001251] = *I01251; sub I01251 { $lac += $core[000023]; goto &fetch; }
$core[001252] = 07421; $code[001252] = *I01252; sub I01252 { &emul8; goto &fetch; }
$core[001253] = 01022; $code[001253] = *I01253; sub I01253 { $lac += $core[000022]; goto &fetch; }
$core[001254] = 07457; $code[001254] = *I01254; sub I01254 { &emul8; goto &fetch; }
$core[001255] = 04541; $code[001255] = *I01255; sub I01255 { $core[($ib<<12)+$core[97]] = 01256; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[001256] = 04773; $code[001256] = *I01256; sub I01256 { $core[($ib<<12)+$core[763]] = 01257; $pc = ($ib<<12)+$core[763]+1; $code[($ib<<12)+$core[763]] = *emul8; $inh = 0; goto &fetch; }
$core[001257] = 04452; $code[001257] = *I01257; sub I01257 { $core[($ib<<12)+$core[42]] = 01260; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001260] = 07773; $code[001260] = *I01260; sub I01260 { &emul8; goto &fetch; }
$core[001261] = 05276; $code[001261] = *I01261; sub I01261 { $pc = 001276; $inh = 0; goto &fetch; }
$core[001262] = 05302; $code[001262] = *I01262; sub I01262 { $pc = 001302; $inh = 0; goto &fetch; }
$core[001263] = 00000; $code[001263] = *S01263; sub S01263 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001264] = 04453; $code[001264] = *I01264; sub I01264 { $core[($ib<<12)+$core[43]] = 01265; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[001265] = 00000; $code[001265] = *D01265; sub D01265 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001266] = 00021; $code[001266] = *I01266; sub I01266 { $lac &= (010000|$core[000021]); goto &fetch; }
$core[001267] = 07775; $code[001267] = *I01267; sub I01267 { &emul8; goto &fetch; }
$core[001270] = 07325; $code[001270] = *I01270; sub I01270 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001271] = 01265; $code[001271] = *I01271; sub I01271 { $lac += $core[001265]; goto &fetch; }
$core[001272] = 03265; $code[001272] = *I01272; sub I01272 { $core[001265] = $lac & 07777; $lac &= 010000; $code[001265] = *emul8; goto &fetch; }
$core[001273] = 02114; $code[001273] = *I01273; sub I01273 { if (++$core[000114] == 010000) { $core[000114] = 0; $pc++; }$code[000114] = *emul8; goto &fetch; }
$core[001274] = 05663; $code[001274] = *I01274; sub I01274 { $pc = ($ib<<12)+$core[691]; $inh = 0; goto &fetch; }
$core[001275] = 05575; $code[001275] = *I01275; sub I01275 { $pc = ($ib<<12)+$core[125]; $inh = 0; goto &fetch; }
$core[001276] = 04545; $code[001276] = *L01276; sub L01276 { $core[($ib<<12)+$core[101]] = 01277; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001277] = 04305; $code[001277] = *I01277; sub I01277 { $core[001305] = 01300; $pc = 001305+1; $code[001305] = *emul8; $inh = 0; goto &fetch; }
$core[001300] = 04543; $code[001300] = *I01300; sub I01300 { $core[($ib<<12)+$core[99]] = 01301; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001301] = 07402; $code[001301] = *I01301; sub I01301 { $hlt = 1; goto &fetch; }
$core[001302] = 04544; $code[001302] = *L01302; sub L01302 { $core[($ib<<12)+$core[100]] = 01303; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001303] = 05247; $code[001303] = *I01303; sub I01303 { $pc = 001247; $inh = 0; goto &fetch; }
$core[001304] = 05246; $code[001304] = *I01304; sub I01304 { $pc = 001246; $inh = 0; goto &fetch; }
$core[001305] = 00000; $code[001305] = *S01305; sub S01305 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001306] = 04534; $code[001306] = *I01306; sub I01306 { $core[($ib<<12)+$core[92]] = 01307; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[001307] = 07775; $code[001307] = *I01307; sub I01307 { &emul8; goto &fetch; }
$core[001310] = 07524; $code[001310] = *I01310; sub I01310 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[001311] = 07440; $code[001311] = *I01311; sub I01311 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001312] = 07443; $code[001312] = *I01312; sub I01312 { &emul8; goto &fetch; }
$core[001313] = 04537; $code[001313] = *I01313; sub I01313 { $core[($ib<<12)+$core[95]] = 01314; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[001314] = 05705; $code[001314] = *I01314; sub I01314 { $pc = ($ib<<12)+$core[709]; $inh = 0; goto &fetch; }
$core[001315] = 00000; $code[001315] = *S01315; sub S01315 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001316] = 04540; $code[001316] = *I01316; sub I01316 { $core[($ib<<12)+$core[96]] = 01317; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001317] = 01372; $code[001317] = *I01317; sub I01317 { $lac += $core[001372]; goto &fetch; }
$core[001320] = 03265; $code[001320] = *I01320; sub I01320 { $core[001265] = $lac & 07777; $lac &= 010000; $code[001265] = *emul8; goto &fetch; }
$core[001321] = 01377; $code[001321] = *I01321; sub I01321 { $lac += $core[001377]; goto &fetch; }
$core[001322] = 03056; $code[001322] = *I01322; sub I01322 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001323] = 01371; $code[001323] = *I01323; sub I01323 { $lac += $core[001371]; goto &fetch; }
$core[001324] = 03057; $code[001324] = *I01324; sub I01324 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[001325] = 01370; $code[001325] = *I01325; sub I01325 { $lac += $core[001370]; goto &fetch; }
$core[001326] = 03114; $code[001326] = *I01326; sub I01326 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[001327] = 04535; $code[001327] = *I01327; sub I01327 { $core[($ib<<12)+$core[93]] = 01330; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[001330] = 04536; $code[001330] = *I01330; sub I01330 { $core[($ib<<12)+$core[94]] = 01331; $pc = ($ib<<12)+$core[94]+1; $code[($ib<<12)+$core[94]] = *emul8; $inh = 0; goto &fetch; }
$core[001331] = 07403; $code[001331] = *I01331; sub I01331 { &emul8; goto &fetch; }
$core[001332] = 05715; $code[001332] = *I01332; sub I01332 { $pc = ($ib<<12)+$core[717]; $inh = 0; goto &fetch; }
$core[001333] = 04767; $code[001333] = *D01333; sub D01333 { $core[($ib<<12)+$core[759]] = 01334; $pc = ($ib<<12)+$core[759]+1; $code[($ib<<12)+$core[759]] = *emul8; $inh = 0; goto &fetch; }
$core[001334] = 04552; $code[001334] = *L01334; sub L01334 { $core[($ib<<12)+$core[106]] = 01335; $pc = ($ib<<12)+$core[106]+1; $code[($ib<<12)+$core[106]] = *emul8; $inh = 0; goto &fetch; }
$core[001335] = 01023; $code[001335] = *L01335; sub L01335 { $lac += $core[000023]; goto &fetch; }
$core[001336] = 07421; $code[001336] = *I01336; sub I01336 { &emul8; goto &fetch; }
$core[001337] = 04553; $code[001337] = *I01337; sub I01337 { $core[($ib<<12)+$core[107]] = 01340; $pc = ($ib<<12)+$core[107]+1; $code[($ib<<12)+$core[107]] = *emul8; $inh = 0; goto &fetch; }
$core[001340] = 04556; $code[001340] = *I01340; sub I01340 { $core[($ib<<12)+$core[110]] = 01341; $pc = ($ib<<12)+$core[110]+1; $code[($ib<<12)+$core[110]] = *emul8; $inh = 0; goto &fetch; }
$core[001341] = 01021; $code[001341] = *I01341; sub I01341 { $lac += $core[000021]; goto &fetch; }
$core[001342] = 07104; $code[001342] = *I01342; sub I01342 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001343] = 01022; $code[001343] = *I01343; sub I01343 { $lac += $core[000022]; goto &fetch; }
$core[001344] = 07457; $code[001344] = *I01344; sub I01344 { &emul8; goto &fetch; }
$core[001345] = 04541; $code[001345] = *I01345; sub I01345 { $core[($ib<<12)+$core[97]] = 01346; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[001346] = 04773; $code[001346] = *I01346; sub I01346 { $core[($ib<<12)+$core[763]] = 01347; $pc = ($ib<<12)+$core[763]+1; $code[($ib<<12)+$core[763]] = *emul8; $inh = 0; goto &fetch; }
$core[001347] = 04452; $code[001347] = *I01347; sub I01347 { $core[($ib<<12)+$core[42]] = 01350; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001350] = 07773; $code[001350] = *I01350; sub I01350 { &emul8; goto &fetch; }
$core[001351] = 05766; $code[001351] = *I01351; sub I01351 { $pc = ($ib<<12)+$core[758]; $inh = 0; goto &fetch; }
$core[001352] = 05765; $code[001352] = *I01352; sub I01352 { $pc = ($ib<<12)+$core[757]; $inh = 0; goto &fetch; }
$core[001365] = 01415; $code[001365] = *P01365; sub P01365 { $core[000015] = 0000 if ++$core[000015] == 010000; $lac += $core[($df<<12)+$core[000015]]; goto &fetch; }
$core[001366] = 01411; $code[001366] = *P01366; sub P01366 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[001367] = 01400; $code[001367] = *P01367; sub P01367 { $lac += $core[($df<<12)+$core[0]]; goto &fetch; }
$core[001370] = 07764; $code[001370] = *D01370; sub D01370 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001371] = 01333; $code[001371] = *D01371; sub D01371 { $lac += $core[001333]; goto &fetch; }
$core[001372] = 07244; $code[001372] = *D01372; sub D01372 { $lac &= 010000; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001373] = 06013; $code[001373] = *P01373; sub P01373 { &emul8; goto &fetch; }
$core[001374] = 01066; $code[001374] = *P01374; sub P01374 { $lac += $core[000066]; goto &fetch; }
$core[001375] = 01137; $code[001375] = *P01375; sub P01375 { $lac += $core[000137]; goto &fetch; }
$core[001376] = 01136; $code[001376] = *P01376; sub P01376 { $lac += $core[000136]; goto &fetch; }
$core[001377] = 01245; $code[001377] = *D01377; sub D01377 { $lac += $core[001245]; goto &fetch; }
$core[001400] = 00000; $code[001400] = *S01400; sub S01400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001401] = 04540; $code[001401] = *I01401; sub I01401 { $core[($ib<<12)+$core[96]] = 01402; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001402] = 01377; $code[001402] = *I01402; sub I01402 { $lac += $core[001577]; goto &fetch; }
$core[001403] = 03057; $code[001403] = *I01403; sub I01403 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[001404] = 01376; $code[001404] = *I01404; sub I01404 { $lac += $core[001576]; goto &fetch; }
$core[001405] = 03056; $code[001405] = *I01405; sub I01405 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001406] = 04535; $code[001406] = *I01406; sub I01406 { $core[($ib<<12)+$core[93]] = 01407; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[001407] = 04536; $code[001407] = *I01407; sub I01407 { $core[($ib<<12)+$core[94]] = 01410; $pc = ($ib<<12)+$core[94]+1; $code[($ib<<12)+$core[94]] = *emul8; $inh = 0; goto &fetch; }
$core[001410] = 05600; $code[001410] = *I01410; sub I01410 { $pc = ($ib<<12)+$core[768]; $inh = 0; goto &fetch; }
$core[001411] = 04545; $code[001411] = *L01411; sub L01411 { $core[($ib<<12)+$core[101]] = 01412; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001412] = 04220; $code[001412] = *I01412; sub I01412 { $core[001420] = 01413; $pc = 001420+1; $code[001420] = *emul8; $inh = 0; goto &fetch; }
$core[001413] = 04543; $code[001413] = *I01413; sub I01413 { $core[($ib<<12)+$core[99]] = 01414; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001414] = 07402; $code[001414] = *I01414; sub I01414 { $hlt = 1; goto &fetch; }
$core[001415] = 04544; $code[001415] = *L01415; sub L01415 { $core[($ib<<12)+$core[100]] = 01416; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001416] = 05775; $code[001416] = *I01416; sub I01416 { $pc = ($ib<<12)+$core[893]; $inh = 0; goto &fetch; }
$core[001417] = 05774; $code[001417] = *I01417; sub I01417 { $pc = ($ib<<12)+$core[892]; $inh = 0; goto &fetch; }
$core[001420] = 00000; $code[001420] = *S01420; sub S01420 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001421] = 04534; $code[001421] = *I01421; sub I01421 { $core[($ib<<12)+$core[92]] = 01422; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[001422] = 07775; $code[001422] = *I01422; sub I01422 { &emul8; goto &fetch; }
$core[001423] = 07524; $code[001423] = *I01423; sub I01423 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[001424] = 07440; $code[001424] = *I01424; sub I01424 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001425] = 07445; $code[001425] = *I01425; sub I01425 { &emul8; goto &fetch; }
$core[001426] = 04537; $code[001426] = *I01426; sub I01426 { $core[($ib<<12)+$core[95]] = 01427; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[001427] = 05620; $code[001427] = *I01427; sub I01427 { $pc = ($ib<<12)+$core[784]; $inh = 0; goto &fetch; }
$core[001430] = 04253; $code[001430] = *I01430; sub I01430 { $core[001453] = 01431; $pc = 001453+1; $code[001453] = *emul8; $inh = 0; goto &fetch; }
$core[001431] = 04542; $code[001431] = *L01431; sub L01431 { $core[($ib<<12)+$core[98]] = 01432; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001432] = 07331; $code[001432] = *L01432; sub L01432 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001433] = 03021; $code[001433] = *I01433; sub I01433 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[001434] = 01065; $code[001434] = *I01434; sub I01434 { $lac += $core[000065]; goto &fetch; }
$core[001435] = 03023; $code[001435] = *I01435; sub I01435 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[001436] = 03022; $code[001436] = *I01436; sub I01436 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[001437] = 01244; $code[001437] = *I01437; sub I01437 { $lac += $core[001444]; goto &fetch; }
$core[001440] = 03024; $code[001440] = *I01440; sub I01440 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001441] = 01065; $code[001441] = *I01441; sub I01441 { $lac += $core[000065]; goto &fetch; }
$core[001442] = 07421; $code[001442] = *I01442; sub I01442 { &emul8; goto &fetch; }
$core[001443] = 07413; $code[001443] = *I01443; sub I01443 { &emul8; goto &fetch; }
$core[001444] = 00000; $code[001444] = *D01444; sub D01444 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001445] = 04541; $code[001445] = *I01445; sub I01445 { $core[($ib<<12)+$core[97]] = 01446; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[001446] = 04773; $code[001446] = *I01446; sub I01446 { $core[($ib<<12)+$core[891]] = 01447; $pc = ($ib<<12)+$core[891]+1; $code[($ib<<12)+$core[891]] = *emul8; $inh = 0; goto &fetch; }
$core[001447] = 04452; $code[001447] = *I01447; sub I01447 { $core[($ib<<12)+$core[42]] = 01450; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001450] = 07773; $code[001450] = *I01450; sub I01450 { &emul8; goto &fetch; }
$core[001451] = 05274; $code[001451] = *I01451; sub I01451 { $pc = 001474; $inh = 0; goto &fetch; }
$core[001452] = 05300; $code[001452] = *I01452; sub I01452 { $pc = 001500; $inh = 0; goto &fetch; }
$core[001453] = 00000; $code[001453] = *S01453; sub S01453 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001454] = 04540; $code[001454] = *I01454; sub I01454 { $core[($ib<<12)+$core[96]] = 01455; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001455] = 03065; $code[001455] = *I01455; sub I01455 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[001456] = 03244; $code[001456] = *I01456; sub I01456 { $core[001444] = $lac & 07777; $lac &= 010000; $code[001444] = *emul8; goto &fetch; }
$core[001457] = 01372; $code[001457] = *I01457; sub I01457 { $lac += $core[001572]; goto &fetch; }
$core[001460] = 03056; $code[001460] = *I01460; sub I01460 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001461] = 01371; $code[001461] = *I01461; sub I01461 { $lac += $core[001571]; goto &fetch; }
$core[001462] = 03057; $code[001462] = *I01462; sub I01462 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[001463] = 01174; $code[001463] = *I01463; sub I01463 { $lac += $core[000174]; goto &fetch; }
$core[001464] = 03114; $code[001464] = *I01464; sub I01464 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[001465] = 04535; $code[001465] = *I01465; sub I01465 { $core[($ib<<12)+$core[93]] = 01466; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[001466] = 05653; $code[001466] = *I01466; sub I01466 { $pc = ($ib<<12)+$core[811]; $inh = 0; goto &fetch; }
$core[001467] = 02244; $code[001467] = *I01467; sub I01467 { if (++$core[001444] == 010000) { $core[001444] = 0; $pc++; }$code[001444] = *emul8; goto &fetch; }
$core[001470] = 02114; $code[001470] = *I01470; sub I01470 { if (++$core[000114] == 010000) { $core[000114] = 0; $pc++; }$code[000114] = *emul8; goto &fetch; }
$core[001471] = 05231; $code[001471] = *I01471; sub I01471 { $pc = 001431; $inh = 0; goto &fetch; }
$core[001472] = 05673; $code[001472] = *I01472; sub I01472 { $pc = ($ib<<12)+$core[827]; $inh = 0; goto &fetch; }
$core[001473] = 01600; $code[001473] = *P01473; sub P01473 { $lac += $core[($df<<12)+$core[768]]; goto &fetch; }
$core[001474] = 04545; $code[001474] = *L01474; sub L01474 { $core[($ib<<12)+$core[101]] = 01475; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001475] = 04303; $code[001475] = *I01475; sub I01475 { $core[001503] = 01476; $pc = 001503+1; $code[001503] = *emul8; $inh = 0; goto &fetch; }
$core[001476] = 04543; $code[001476] = *I01476; sub I01476 { $core[($ib<<12)+$core[99]] = 01477; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001477] = 07402; $code[001477] = *I01477; sub I01477 { $hlt = 1; goto &fetch; }
$core[001500] = 04544; $code[001500] = *L01500; sub L01500 { $core[($ib<<12)+$core[100]] = 01501; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001501] = 05232; $code[001501] = *I01501; sub I01501 { $pc = 001432; $inh = 0; goto &fetch; }
$core[001502] = 05231; $code[001502] = *I01502; sub I01502 { $pc = 001431; $inh = 0; goto &fetch; }
$core[001503] = 00000; $code[001503] = *S01503; sub S01503 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001504] = 04534; $code[001504] = *I01504; sub I01504 { $core[($ib<<12)+$core[92]] = 01505; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[001505] = 07775; $code[001505] = *I01505; sub I01505 { &emul8; goto &fetch; }
$core[001506] = 07435; $code[001506] = *I01506; sub I01506 { &emul8; goto &fetch; }
$core[001507] = 07440; $code[001507] = *I01507; sub I01507 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001510] = 07443; $code[001510] = *I01510; sub I01510 { &emul8; goto &fetch; }
$core[001511] = 04547; $code[001511] = *I01511; sub I01511 { $core[($ib<<12)+$core[103]] = 01512; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001512] = 04537; $code[001512] = *I01512; sub I01512 { $core[($ib<<12)+$core[95]] = 01513; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[001513] = 05703; $code[001513] = *I01513; sub I01513 { $pc = ($ib<<12)+$core[835]; $inh = 0; goto &fetch; }
$core[001571] = 01467; $code[001571] = *D01571; sub D01571 { $lac += $core[($df<<12)+$core[55]]; goto &fetch; }
$core[001572] = 01431; $code[001572] = *D01572; sub D01572 { $lac += $core[($df<<12)+$core[25]]; goto &fetch; }
$core[001573] = 06042; $code[001573] = *P01573; sub P01573 { &emul8; goto &fetch; }
$core[001574] = 01334; $code[001574] = *P01574; sub P01574 { $lac += $core[001534]; goto &fetch; }
$core[001575] = 01335; $code[001575] = *P01575; sub P01575 { $lac += $core[001535]; goto &fetch; }
$core[001576] = 01333; $code[001576] = *D01576; sub D01576 { $lac += $core[001533]; goto &fetch; }
$core[001577] = 01430; $code[001577] = *D01577; sub D01577 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[001600] = 04216; $code[001600] = *P01600; sub P01600 { $core[001616] = 01601; $pc = 001616+1; $code[001616] = *emul8; $inh = 0; goto &fetch; }
$core[001601] = 04552; $code[001601] = *L01601; sub L01601 { $core[($ib<<12)+$core[106]] = 01602; $pc = ($ib<<12)+$core[106]+1; $code[($ib<<12)+$core[106]] = *emul8; $inh = 0; goto &fetch; }
$core[001602] = 04551; $code[001602] = *L01602; sub L01602 { $core[($ib<<12)+$core[105]] = 01603; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[001603] = 01024; $code[001603] = *I01603; sub I01603 { $lac += $core[000024]; goto &fetch; }
$core[001604] = 03207; $code[001604] = *I01604; sub I01604 { $core[001607] = $lac & 07777; $lac &= 010000; $code[001607] = *emul8; goto &fetch; }
$core[001605] = 01022; $code[001605] = *I01605; sub I01605 { $lac += $core[000022]; goto &fetch; }
$core[001606] = 07413; $code[001606] = *I01606; sub I01606 { &emul8; goto &fetch; }
$core[001607] = 00000; $code[001607] = *D01607; sub D01607 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001610] = 04541; $code[001610] = *I01610; sub I01610 { $core[($ib<<12)+$core[97]] = 01611; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[001611] = 04777; $code[001611] = *I01611; sub I01611 { $core[($ib<<12)+$core[1023]] = 01612; $pc = ($ib<<12)+$core[1023]+1; $code[($ib<<12)+$core[1023]] = *emul8; $inh = 0; goto &fetch; }
$core[001612] = 04452; $code[001612] = *I01612; sub I01612 { $core[($ib<<12)+$core[42]] = 01613; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001613] = 07773; $code[001613] = *I01613; sub I01613 { &emul8; goto &fetch; }
$core[001614] = 05226; $code[001614] = *I01614; sub I01614 { $pc = 001626; $inh = 0; goto &fetch; }
$core[001615] = 05232; $code[001615] = *I01615; sub I01615 { $pc = 001632; $inh = 0; goto &fetch; }
$core[001616] = 00000; $code[001616] = *S01616; sub S01616 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001617] = 04540; $code[001617] = *I01617; sub I01617 { $core[($ib<<12)+$core[96]] = 01620; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001620] = 01376; $code[001620] = *I01620; sub I01620 { $lac += $core[001776]; goto &fetch; }
$core[001621] = 03056; $code[001621] = *I01621; sub I01621 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001622] = 01375; $code[001622] = *I01622; sub I01622 { $lac += $core[001775]; goto &fetch; }
$core[001623] = 03057; $code[001623] = *I01623; sub I01623 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[001624] = 04535; $code[001624] = *I01624; sub I01624 { $core[($ib<<12)+$core[93]] = 01625; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[001625] = 05616; $code[001625] = *I01625; sub I01625 { $pc = ($ib<<12)+$core[910]; $inh = 0; goto &fetch; }
$core[001626] = 04545; $code[001626] = *L01626; sub L01626 { $core[($ib<<12)+$core[101]] = 01627; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001627] = 04235; $code[001627] = *I01627; sub I01627 { $core[001635] = 01630; $pc = 001635+1; $code[001635] = *emul8; $inh = 0; goto &fetch; }
$core[001630] = 04543; $code[001630] = *I01630; sub I01630 { $core[($ib<<12)+$core[99]] = 01631; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001631] = 07402; $code[001631] = *I01631; sub I01631 { $hlt = 1; goto &fetch; }
$core[001632] = 04544; $code[001632] = *L01632; sub L01632 { $core[($ib<<12)+$core[100]] = 01633; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001633] = 05202; $code[001633] = *I01633; sub I01633 { $pc = 001602; $inh = 0; goto &fetch; }
$core[001634] = 05201; $code[001634] = *I01634; sub I01634 { $pc = 001601; $inh = 0; goto &fetch; }
$core[001635] = 00000; $code[001635] = *S01635; sub S01635 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001636] = 04534; $code[001636] = *I01636; sub I01636 { $core[($ib<<12)+$core[92]] = 01637; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[001637] = 07775; $code[001637] = *I01637; sub I01637 { &emul8; goto &fetch; }
$core[001640] = 07435; $code[001640] = *I01640; sub I01640 { &emul8; goto &fetch; }
$core[001641] = 07440; $code[001641] = *I01641; sub I01641 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001642] = 07445; $code[001642] = *I01642; sub I01642 { &emul8; goto &fetch; }
$core[001643] = 04547; $code[001643] = *I01643; sub I01643 { $core[($ib<<12)+$core[103]] = 01644; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001644] = 04537; $code[001644] = *I01644; sub I01644 { $core[($ib<<12)+$core[95]] = 01645; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[001645] = 05635; $code[001645] = *I01645; sub I01645 { $pc = ($ib<<12)+$core[925]; $inh = 0; goto &fetch; }
$core[001646] = 04272; $code[001646] = *P01646; sub P01646 { $core[001672] = 01647; $pc = 001672+1; $code[001672] = *emul8; $inh = 0; goto &fetch; }
$core[001647] = 04542; $code[001647] = *P01647; sub P01647 { $core[($ib<<12)+$core[98]] = 01650; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001650] = 01065; $code[001650] = *L01650; sub L01650 { $lac += $core[000065]; goto &fetch; }
$core[001651] = 04774; $code[001651] = *I01651; sub I01651 { $core[($ib<<12)+$core[1020]] = 01652; $pc = ($ib<<12)+$core[1020]+1; $code[($ib<<12)+$core[1020]] = *emul8; $inh = 0; goto &fetch; }
$core[001652] = 03022; $code[001652] = *I01652; sub I01652 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[001653] = 03023; $code[001653] = *I01653; sub I01653 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[001654] = 01263; $code[001654] = *I01654; sub I01654 { $lac += $core[001663]; goto &fetch; }
$core[001655] = 03024; $code[001655] = *I01655; sub I01655 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001656] = 07331; $code[001656] = *I01656; sub I01656 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001657] = 03021; $code[001657] = *I01657; sub I01657 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[001660] = 07421; $code[001660] = *I01660; sub I01660 { &emul8; goto &fetch; }
$core[001661] = 01022; $code[001661] = *I01661; sub I01661 { $lac += $core[000022]; goto &fetch; }
$core[001662] = 07417; $code[001662] = *I01662; sub I01662 { &emul8; goto &fetch; }
$core[001663] = 00000; $code[001663] = *D01663; sub D01663 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001664] = 04541; $code[001664] = *I01664; sub I01664 { $core[($ib<<12)+$core[97]] = 01665; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[001665] = 04773; $code[001665] = *I01665; sub I01665 { $core[($ib<<12)+$core[1019]] = 01666; $pc = ($ib<<12)+$core[1019]+1; $code[($ib<<12)+$core[1019]] = *emul8; $inh = 0; goto &fetch; }
$core[001666] = 04452; $code[001666] = *I01666; sub I01666 { $core[($ib<<12)+$core[42]] = 01667; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001667] = 07773; $code[001667] = *I01667; sub I01667 { &emul8; goto &fetch; }
$core[001670] = 05313; $code[001670] = *I01670; sub I01670 { $pc = 001713; $inh = 0; goto &fetch; }
$core[001671] = 05317; $code[001671] = *I01671; sub I01671 { $pc = 001717; $inh = 0; goto &fetch; }
$core[001672] = 00000; $code[001672] = *S01672; sub S01672 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001673] = 04540; $code[001673] = *I01673; sub I01673 { $core[($ib<<12)+$core[96]] = 01674; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001674] = 03065; $code[001674] = *I01674; sub I01674 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[001675] = 03263; $code[001675] = *I01675; sub I01675 { $core[001663] = $lac & 07777; $lac &= 010000; $code[001663] = *emul8; goto &fetch; }
$core[001676] = 01372; $code[001676] = *I01676; sub I01676 { $lac += $core[001772]; goto &fetch; }
$core[001677] = 03056; $code[001677] = *I01677; sub I01677 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001700] = 01371; $code[001700] = *I01700; sub I01700 { $lac += $core[001771]; goto &fetch; }
$core[001701] = 03057; $code[001701] = *I01701; sub I01701 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[001702] = 01174; $code[001702] = *I01702; sub I01702 { $lac += $core[000174]; goto &fetch; }
$core[001703] = 03114; $code[001703] = *I01703; sub I01703 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[001704] = 04535; $code[001704] = *I01704; sub I01704 { $core[($ib<<12)+$core[93]] = 01705; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[001705] = 05672; $code[001705] = *I01705; sub I01705 { $pc = ($ib<<12)+$core[954]; $inh = 0; goto &fetch; }
$core[001706] = 02263; $code[001706] = *P01706; sub P01706 { if (++$core[001663] == 010000) { $core[001663] = 0; $pc++; }$code[001663] = *emul8; goto &fetch; }
$core[001707] = 02114; $code[001707] = *I01707; sub I01707 { if (++$core[000114] == 010000) { $core[000114] = 0; $pc++; }$code[000114] = *emul8; goto &fetch; }
$core[001710] = 05247; $code[001710] = *I01710; sub I01710 { $pc = 001647; $inh = 0; goto &fetch; }
$core[001711] = 05712; $code[001711] = *I01711; sub I01711 { $pc = ($ib<<12)+$core[970]; $inh = 0; goto &fetch; }
$core[001712] = 02000; $code[001712] = *P01712; sub P01712 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[001713] = 04545; $code[001713] = *L01713; sub L01713 { $core[($ib<<12)+$core[101]] = 01714; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001714] = 04322; $code[001714] = *I01714; sub I01714 { $core[001722] = 01715; $pc = 001722+1; $code[001722] = *emul8; $inh = 0; goto &fetch; }
$core[001715] = 04543; $code[001715] = *I01715; sub I01715 { $core[($ib<<12)+$core[99]] = 01716; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001716] = 07402; $code[001716] = *I01716; sub I01716 { $hlt = 1; goto &fetch; }
$core[001717] = 04544; $code[001717] = *L01717; sub L01717 { $core[($ib<<12)+$core[100]] = 01720; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001720] = 05250; $code[001720] = *I01720; sub I01720 { $pc = 001650; $inh = 0; goto &fetch; }
$core[001721] = 05247; $code[001721] = *I01721; sub I01721 { $pc = 001647; $inh = 0; goto &fetch; }
$core[001722] = 00000; $code[001722] = *S01722; sub S01722 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001723] = 04534; $code[001723] = *I01723; sub I01723 { $core[($ib<<12)+$core[92]] = 01724; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[001724] = 07775; $code[001724] = *I01724; sub I01724 { &emul8; goto &fetch; }
$core[001725] = 07453; $code[001725] = *I01725; sub I01725 { &emul8; goto &fetch; }
$core[001726] = 07440; $code[001726] = *I01726; sub I01726 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001727] = 07443; $code[001727] = *I01727; sub I01727 { &emul8; goto &fetch; }
$core[001730] = 04547; $code[001730] = *I01730; sub I01730 { $core[($ib<<12)+$core[103]] = 01731; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001731] = 04537; $code[001731] = *I01731; sub I01731 { $core[($ib<<12)+$core[95]] = 01732; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[001732] = 05722; $code[001732] = *I01732; sub I01732 { $pc = ($ib<<12)+$core[978]; $inh = 0; goto &fetch; }
$core[001771] = 01706; $code[001771] = *D01771; sub D01771 { $lac += $core[($df<<12)+$core[966]]; goto &fetch; }
$core[001772] = 01647; $code[001772] = *D01772; sub D01772 { $lac += $core[($df<<12)+$core[935]]; goto &fetch; }
$core[001773] = 06120; $code[001773] = *P01773; sub P01773 { &emul8; goto &fetch; }
$core[001774] = 06473; $code[001774] = *P01774; sub P01774 { &emul8; goto &fetch; }
$core[001775] = 01646; $code[001775] = *D01775; sub D01775 { $lac += $core[($df<<12)+$core[934]]; goto &fetch; }
$core[001776] = 01600; $code[001776] = *D01776; sub D01776 { $lac += $core[($df<<12)+$core[896]]; goto &fetch; }
$core[001777] = 06042; $code[001777] = *P01777; sub P01777 { &emul8; goto &fetch; }
$core[002000] = 04216; $code[002000] = *L02000; sub L02000 { $core[002016] = 02001; $pc = 002016+1; $code[002016] = *emul8; $inh = 0; goto &fetch; }
$core[002001] = 04552; $code[002001] = *L02001; sub L02001 { $core[($ib<<12)+$core[106]] = 02002; $pc = ($ib<<12)+$core[106]+1; $code[($ib<<12)+$core[106]] = *emul8; $inh = 0; goto &fetch; }
$core[002002] = 04551; $code[002002] = *L02002; sub L02002 { $core[($ib<<12)+$core[105]] = 02003; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002003] = 01024; $code[002003] = *I02003; sub I02003 { $lac += $core[000024]; goto &fetch; }
$core[002004] = 03207; $code[002004] = *I02004; sub I02004 { $core[002007] = $lac & 07777; $lac &= 010000; $code[002007] = *emul8; goto &fetch; }
$core[002005] = 01022; $code[002005] = *I02005; sub I02005 { $lac += $core[000022]; goto &fetch; }
$core[002006] = 07417; $code[002006] = *I02006; sub I02006 { &emul8; goto &fetch; }
$core[002007] = 00000; $code[002007] = *D02007; sub D02007 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002010] = 04541; $code[002010] = *I02010; sub I02010 { $core[($ib<<12)+$core[97]] = 02011; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[002011] = 04777; $code[002011] = *I02011; sub I02011 { $core[($ib<<12)+$core[1151]] = 02012; $pc = ($ib<<12)+$core[1151]+1; $code[($ib<<12)+$core[1151]] = *emul8; $inh = 0; goto &fetch; }
$core[002012] = 04452; $code[002012] = *I02012; sub I02012 { $core[($ib<<12)+$core[42]] = 02013; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[002013] = 07773; $code[002013] = *I02013; sub I02013 { &emul8; goto &fetch; }
$core[002014] = 05226; $code[002014] = *I02014; sub I02014 { $pc = 002026; $inh = 0; goto &fetch; }
$core[002015] = 05232; $code[002015] = *I02015; sub I02015 { $pc = 002032; $inh = 0; goto &fetch; }
$core[002016] = 00000; $code[002016] = *S02016; sub S02016 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002017] = 04540; $code[002017] = *I02017; sub I02017 { $core[($ib<<12)+$core[96]] = 02020; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[002020] = 01376; $code[002020] = *I02020; sub I02020 { $lac += $core[002176]; goto &fetch; }
$core[002021] = 03056; $code[002021] = *I02021; sub I02021 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[002022] = 01375; $code[002022] = *I02022; sub I02022 { $lac += $core[002175]; goto &fetch; }
$core[002023] = 03057; $code[002023] = *I02023; sub I02023 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[002024] = 04535; $code[002024] = *I02024; sub I02024 { $core[($ib<<12)+$core[93]] = 02025; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[002025] = 05616; $code[002025] = *I02025; sub I02025 { $pc = ($ib<<12)+$core[1038]; $inh = 0; goto &fetch; }
$core[002026] = 04545; $code[002026] = *L02026; sub L02026 { $core[($ib<<12)+$core[101]] = 02027; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[002027] = 04235; $code[002027] = *I02027; sub I02027 { $core[002035] = 02030; $pc = 002035+1; $code[002035] = *emul8; $inh = 0; goto &fetch; }
$core[002030] = 04543; $code[002030] = *I02030; sub I02030 { $core[($ib<<12)+$core[99]] = 02031; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[002031] = 07402; $code[002031] = *I02031; sub I02031 { $hlt = 1; goto &fetch; }
$core[002032] = 04544; $code[002032] = *L02032; sub L02032 { $core[($ib<<12)+$core[100]] = 02033; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[002033] = 05202; $code[002033] = *I02033; sub I02033 { $pc = 002002; $inh = 0; goto &fetch; }
$core[002034] = 05201; $code[002034] = *I02034; sub I02034 { $pc = 002001; $inh = 0; goto &fetch; }
$core[002035] = 00000; $code[002035] = *S02035; sub S02035 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002036] = 04534; $code[002036] = *I02036; sub I02036 { $core[($ib<<12)+$core[92]] = 02037; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[002037] = 07775; $code[002037] = *I02037; sub I02037 { &emul8; goto &fetch; }
$core[002040] = 07453; $code[002040] = *I02040; sub I02040 { &emul8; goto &fetch; }
$core[002041] = 07440; $code[002041] = *I02041; sub I02041 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002042] = 07445; $code[002042] = *I02042; sub I02042 { &emul8; goto &fetch; }
$core[002043] = 04547; $code[002043] = *I02043; sub I02043 { $core[($ib<<12)+$core[103]] = 02044; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[002044] = 04537; $code[002044] = *I02044; sub I02044 { $core[($ib<<12)+$core[95]] = 02045; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[002045] = 05635; $code[002045] = *I02045; sub I02045 { $pc = ($ib<<12)+$core[1053]; $inh = 0; goto &fetch; }
$core[002046] = 04272; $code[002046] = *I02046; sub I02046 { $core[002072] = 02047; $pc = 002072+1; $code[002072] = *emul8; $inh = 0; goto &fetch; }
$core[002047] = 04542; $code[002047] = *L02047; sub L02047 { $core[($ib<<12)+$core[98]] = 02050; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[002050] = 01065; $code[002050] = *L02050; sub L02050 { $lac += $core[000065]; goto &fetch; }
$core[002051] = 04774; $code[002051] = *I02051; sub I02051 { $core[($ib<<12)+$core[1148]] = 02052; $pc = ($ib<<12)+$core[1148]+1; $code[($ib<<12)+$core[1148]] = *emul8; $inh = 0; goto &fetch; }
$core[002052] = 03022; $code[002052] = *I02052; sub I02052 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[002053] = 03023; $code[002053] = *I02053; sub I02053 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[002054] = 01263; $code[002054] = *I02054; sub I02054 { $lac += $core[002063]; goto &fetch; }
$core[002055] = 03024; $code[002055] = *I02055; sub I02055 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[002056] = 07331; $code[002056] = *I02056; sub I02056 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002057] = 03021; $code[002057] = *I02057; sub I02057 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[002060] = 07421; $code[002060] = *I02060; sub I02060 { &emul8; goto &fetch; }
$core[002061] = 01022; $code[002061] = *I02061; sub I02061 { $lac += $core[000022]; goto &fetch; }
$core[002062] = 07415; $code[002062] = *I02062; sub I02062 { &emul8; goto &fetch; }
$core[002063] = 00000; $code[002063] = *D02063; sub D02063 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002064] = 04541; $code[002064] = *I02064; sub I02064 { $core[($ib<<12)+$core[97]] = 02065; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[002065] = 04773; $code[002065] = *I02065; sub I02065 { $core[($ib<<12)+$core[1147]] = 02066; $pc = ($ib<<12)+$core[1147]+1; $code[($ib<<12)+$core[1147]] = *emul8; $inh = 0; goto &fetch; }
$core[002066] = 04452; $code[002066] = *I02066; sub I02066 { $core[($ib<<12)+$core[42]] = 02067; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[002067] = 07773; $code[002067] = *I02067; sub I02067 { &emul8; goto &fetch; }
$core[002070] = 05313; $code[002070] = *I02070; sub I02070 { $pc = 002113; $inh = 0; goto &fetch; }
$core[002071] = 05317; $code[002071] = *I02071; sub I02071 { $pc = 002117; $inh = 0; goto &fetch; }
$core[002072] = 00000; $code[002072] = *S02072; sub S02072 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002073] = 04540; $code[002073] = *I02073; sub I02073 { $core[($ib<<12)+$core[96]] = 02074; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[002074] = 03065; $code[002074] = *I02074; sub I02074 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[002075] = 03263; $code[002075] = *I02075; sub I02075 { $core[002063] = $lac & 07777; $lac &= 010000; $code[002063] = *emul8; goto &fetch; }
$core[002076] = 01372; $code[002076] = *I02076; sub I02076 { $lac += $core[002172]; goto &fetch; }
$core[002077] = 03056; $code[002077] = *I02077; sub I02077 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[002100] = 01371; $code[002100] = *I02100; sub I02100 { $lac += $core[002171]; goto &fetch; }
$core[002101] = 03057; $code[002101] = *I02101; sub I02101 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[002102] = 01174; $code[002102] = *I02102; sub I02102 { $lac += $core[000174]; goto &fetch; }
$core[002103] = 03114; $code[002103] = *I02103; sub I02103 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[002104] = 04535; $code[002104] = *I02104; sub I02104 { $core[($ib<<12)+$core[93]] = 02105; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[002105] = 05672; $code[002105] = *I02105; sub I02105 { $pc = ($ib<<12)+$core[1082]; $inh = 0; goto &fetch; }
$core[002106] = 02263; $code[002106] = *I02106; sub I02106 { if (++$core[002063] == 010000) { $core[002063] = 0; $pc++; }$code[002063] = *emul8; goto &fetch; }
$core[002107] = 02114; $code[002107] = *I02107; sub I02107 { if (++$core[000114] == 010000) { $core[000114] = 0; $pc++; }$code[000114] = *emul8; goto &fetch; }
$core[002110] = 05247; $code[002110] = *I02110; sub I02110 { $pc = 002047; $inh = 0; goto &fetch; }
$core[002111] = 05712; $code[002111] = *I02111; sub I02111 { $pc = ($ib<<12)+$core[1098]; $inh = 0; goto &fetch; }
$core[002112] = 02200; $code[002112] = *P02112; sub P02112 { if (++$core[002000] == 010000) { $core[002000] = 0; $pc++; }$code[002000] = *emul8; goto &fetch; }
$core[002113] = 04545; $code[002113] = *L02113; sub L02113 { $core[($ib<<12)+$core[101]] = 02114; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[002114] = 04322; $code[002114] = *I02114; sub I02114 { $core[002122] = 02115; $pc = 002122+1; $code[002122] = *emul8; $inh = 0; goto &fetch; }
$core[002115] = 04543; $code[002115] = *I02115; sub I02115 { $core[($ib<<12)+$core[99]] = 02116; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[002116] = 07402; $code[002116] = *I02116; sub I02116 { $hlt = 1; goto &fetch; }
$core[002117] = 04544; $code[002117] = *L02117; sub L02117 { $core[($ib<<12)+$core[100]] = 02120; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[002120] = 05250; $code[002120] = *I02120; sub I02120 { $pc = 002050; $inh = 0; goto &fetch; }
$core[002121] = 05247; $code[002121] = *I02121; sub I02121 { $pc = 002047; $inh = 0; goto &fetch; }
$core[002122] = 00000; $code[002122] = *S02122; sub S02122 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002123] = 04534; $code[002123] = *I02123; sub I02123 { $core[($ib<<12)+$core[92]] = 02124; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[002124] = 07775; $code[002124] = *I02124; sub I02124 { &emul8; goto &fetch; }
$core[002125] = 07462; $code[002125] = *I02125; sub I02125 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $hlt = 1; goto &fetch; }
$core[002126] = 07440; $code[002126] = *I02126; sub I02126 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002127] = 07443; $code[002127] = *I02127; sub I02127 { &emul8; goto &fetch; }
$core[002130] = 04547; $code[002130] = *I02130; sub I02130 { $core[($ib<<12)+$core[103]] = 02131; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[002131] = 04537; $code[002131] = *I02131; sub I02131 { $core[($ib<<12)+$core[95]] = 02132; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[002132] = 05722; $code[002132] = *I02132; sub I02132 { $pc = ($ib<<12)+$core[1106]; $inh = 0; goto &fetch; }
$core[002171] = 02106; $code[002171] = *D02171; sub D02171 { if (++$core[000106] == 010000) { $core[000106] = 0; $pc++; }$code[000106] = *emul8; goto &fetch; }
$core[002172] = 02047; $code[002172] = *D02172; sub D02172 { if (++$core[000047] == 010000) { $core[000047] = 0; $pc++; }$code[000047] = *emul8; goto &fetch; }
$core[002173] = 06200; $code[002173] = *P02173; sub P02173 { &emul8; goto &fetch; }
$core[002174] = 06473; $code[002174] = *P02174; sub P02174 { &emul8; goto &fetch; }
$core[002175] = 02046; $code[002175] = *D02175; sub D02175 { if (++$core[000046] == 010000) { $core[000046] = 0; $pc++; }$code[000046] = *emul8; goto &fetch; }
$core[002176] = 02000; $code[002176] = *D02176; sub D02176 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[002177] = 06120; $code[002177] = *P02177; sub P02177 { &emul8; goto &fetch; }
$core[002200] = 04216; $code[002200] = *L02200; sub L02200 { $core[002216] = 02201; $pc = 002216+1; $code[002216] = *emul8; $inh = 0; goto &fetch; }
$core[002201] = 04552; $code[002201] = *L02201; sub L02201 { $core[($ib<<12)+$core[106]] = 02202; $pc = ($ib<<12)+$core[106]+1; $code[($ib<<12)+$core[106]] = *emul8; $inh = 0; goto &fetch; }
$core[002202] = 04551; $code[002202] = *L02202; sub L02202 { $core[($ib<<12)+$core[105]] = 02203; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002203] = 01024; $code[002203] = *I02203; sub I02203 { $lac += $core[000024]; goto &fetch; }
$core[002204] = 03207; $code[002204] = *I02204; sub I02204 { $core[002207] = $lac & 07777; $lac &= 010000; $code[002207] = *emul8; goto &fetch; }
$core[002205] = 01022; $code[002205] = *I02205; sub I02205 { $lac += $core[000022]; goto &fetch; }
$core[002206] = 07415; $code[002206] = *I02206; sub I02206 { &emul8; goto &fetch; }
$core[002207] = 00000; $code[002207] = *D02207; sub D02207 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002210] = 04541; $code[002210] = *I02210; sub I02210 { $core[($ib<<12)+$core[97]] = 02211; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[002211] = 04777; $code[002211] = *I02211; sub I02211 { $core[($ib<<12)+$core[1279]] = 02212; $pc = ($ib<<12)+$core[1279]+1; $code[($ib<<12)+$core[1279]] = *emul8; $inh = 0; goto &fetch; }
$core[002212] = 04452; $code[002212] = *I02212; sub I02212 { $core[($ib<<12)+$core[42]] = 02213; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[002213] = 07773; $code[002213] = *I02213; sub I02213 { &emul8; goto &fetch; }
$core[002214] = 05226; $code[002214] = *I02214; sub I02214 { $pc = 002226; $inh = 0; goto &fetch; }
$core[002215] = 05232; $code[002215] = *I02215; sub I02215 { $pc = 002232; $inh = 0; goto &fetch; }
$core[002216] = 00000; $code[002216] = *S02216; sub S02216 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002217] = 04540; $code[002217] = *I02217; sub I02217 { $core[($ib<<12)+$core[96]] = 02220; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[002220] = 01376; $code[002220] = *I02220; sub I02220 { $lac += $core[002376]; goto &fetch; }
$core[002221] = 03056; $code[002221] = *I02221; sub I02221 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[002222] = 01375; $code[002222] = *I02222; sub I02222 { $lac += $core[002375]; goto &fetch; }
$core[002223] = 03057; $code[002223] = *I02223; sub I02223 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[002224] = 04535; $code[002224] = *I02224; sub I02224 { $core[($ib<<12)+$core[93]] = 02225; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[002225] = 05616; $code[002225] = *I02225; sub I02225 { $pc = ($ib<<12)+$core[1166]; $inh = 0; goto &fetch; }
$core[002226] = 04545; $code[002226] = *L02226; sub L02226 { $core[($ib<<12)+$core[101]] = 02227; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[002227] = 04235; $code[002227] = *I02227; sub I02227 { $core[002235] = 02230; $pc = 002235+1; $code[002235] = *emul8; $inh = 0; goto &fetch; }
$core[002230] = 04543; $code[002230] = *I02230; sub I02230 { $core[($ib<<12)+$core[99]] = 02231; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[002231] = 07402; $code[002231] = *I02231; sub I02231 { $hlt = 1; goto &fetch; }
$core[002232] = 04544; $code[002232] = *L02232; sub L02232 { $core[($ib<<12)+$core[100]] = 02233; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[002233] = 05202; $code[002233] = *I02233; sub I02233 { $pc = 002202; $inh = 0; goto &fetch; }
$core[002234] = 05201; $code[002234] = *I02234; sub I02234 { $pc = 002201; $inh = 0; goto &fetch; }
$core[002235] = 00000; $code[002235] = *S02235; sub S02235 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002236] = 04534; $code[002236] = *I02236; sub I02236 { $core[($ib<<12)+$core[92]] = 02237; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[002237] = 07775; $code[002237] = *I02237; sub I02237 { &emul8; goto &fetch; }
$core[002240] = 07462; $code[002240] = *I02240; sub I02240 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $hlt = 1; goto &fetch; }
$core[002241] = 07440; $code[002241] = *I02241; sub I02241 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002242] = 07445; $code[002242] = *I02242; sub I02242 { &emul8; goto &fetch; }
$core[002243] = 04547; $code[002243] = *I02243; sub I02243 { $core[($ib<<12)+$core[103]] = 02244; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[002244] = 04537; $code[002244] = *I02244; sub I02244 { $core[($ib<<12)+$core[95]] = 02245; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[002245] = 05635; $code[002245] = *I02245; sub I02245 { $pc = ($ib<<12)+$core[1181]; $inh = 0; goto &fetch; }
$core[002246] = 04774; $code[002246] = *L02246; sub L02246 { $core[($ib<<12)+$core[1276]] = 02247; $pc = ($ib<<12)+$core[1276]+1; $code[($ib<<12)+$core[1276]] = *emul8; $inh = 0; goto &fetch; }
$core[002247] = 07320; $code[002247] = *I02247; sub I02247 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002250] = 04773; $code[002250] = *L02250; sub L02250 { $core[($ib<<12)+$core[1275]] = 02251; $pc = ($ib<<12)+$core[1275]+1; $code[($ib<<12)+$core[1275]] = *emul8; $inh = 0; goto &fetch; }
$core[002251] = 07300; $code[002251] = *L02251; sub L02251 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002252] = 01044; $code[002252] = *I02252; sub I02252 { $lac += $core[000044]; goto &fetch; }
$core[002253] = 01043; $code[002253] = *I02253; sub I02253 { $lac += $core[000043]; goto &fetch; }
$core[002254] = 07650; $code[002254] = *I02254; sub I02254 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002255] = 07430; $code[002255] = *I02255; sub I02255 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002256] = 04302; $code[002256] = *I02256; sub I02256 { $core[002302] = 02257; $pc = 002302+1; $code[002302] = *emul8; $inh = 0; goto &fetch; }
$core[002257] = 04313; $code[002257] = *I02257; sub I02257 { $core[002313] = 02260; $pc = 002313+1; $code[002313] = *emul8; $inh = 0; goto &fetch; }
$core[002260] = 07331; $code[002260] = *I02260; sub I02260 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002261] = 03042; $code[002261] = *I02261; sub I02261 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[002262] = 01042; $code[002262] = *I02262; sub I02262 { $lac += $core[000042]; goto &fetch; }
$core[002263] = 03021; $code[002263] = *D02263; sub D02263 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[002264] = 01044; $code[002264] = *I02264; sub I02264 { $lac += $core[000044]; goto &fetch; }
$core[002265] = 07421; $code[002265] = *I02265; sub I02265 { &emul8; goto &fetch; }
$core[002266] = 01043; $code[002266] = *I02266; sub I02266 { $lac += $core[000043]; goto &fetch; }
$core[002267] = 07451; $code[002267] = *I02267; sub I02267 { &emul8; goto &fetch; }
$core[002270] = 00000; $code[002270] = *D02270; sub D02270 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002271] = 00000; $code[002271] = *D02271; sub D02271 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002272] = 04541; $code[002272] = *L02272; sub L02272 { $core[($ib<<12)+$core[97]] = 02273; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[002273] = 04452; $code[002273] = *I02273; sub I02273 { $core[($ib<<12)+$core[42]] = 02274; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[002274] = 07775; $code[002274] = *I02274; sub I02274 { &emul8; goto &fetch; }
$core[002275] = 07610; $code[002275] = *I02275; sub I02275 { $skp = 0; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002276] = 05772; $code[002276] = *I02276; sub I02276 { $pc = ($ib<<12)+$core[1274]; $inh = 0; goto &fetch; }
$core[002277] = 01371; $code[002277] = *I02277; sub I02277 { $lac += $core[002371]; goto &fetch; }
$core[002300] = 03770; $code[002300] = *I02300; sub I02300 { $core[($df<<12)+$core[1272]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1272]] = *emul8; goto &fetch; }
$core[002301] = 05767; $code[002301] = *D02301; sub D02301 { $pc = ($ib<<12)+$core[1271]; $inh = 0; goto &fetch; }
$core[002302] = 00000; $code[002302] = *S02302; sub S02302 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002303] = 01366; $code[002303] = *I02303; sub I02303 { $lac += $core[002366]; goto &fetch; }
$core[002304] = 03270; $code[002304] = *I02304; sub I02304 { $core[002270] = $lac & 07777; $lac &= 010000; $code[002270] = *emul8; goto &fetch; }
$core[002305] = 01364; $code[002305] = *I02305; sub I02305 { $lac += $core[002364]; goto &fetch; }
$core[002306] = 03271; $code[002306] = *I02306; sub I02306 { $core[002271] = $lac & 07777; $lac &= 010000; $code[002271] = *emul8; goto &fetch; }
$core[002307] = 01363; $code[002307] = *I02307; sub I02307 { $lac += $core[002363]; goto &fetch; }
$core[002310] = 03770; $code[002310] = *I02310; sub I02310 { $core[($df<<12)+$core[1272]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1272]] = *emul8; goto &fetch; }
$core[002311] = 02302; $code[002311] = *D02311; sub D02311 { if (++$core[002302] == 010000) { $core[002302] = 0; $pc++; }$code[002302] = *emul8; goto &fetch; }
$core[002312] = 05702; $code[002312] = *I02312; sub I02312 { $pc = ($ib<<12)+$core[1218]; $inh = 0; goto &fetch; }
$core[002313] = 00000; $code[002313] = *S02313; sub S02313 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002314] = 01366; $code[002314] = *I02314; sub I02314 { $lac += $core[002366]; goto &fetch; }
$core[002315] = 03271; $code[002315] = *I02315; sub I02315 { $core[002271] = $lac & 07777; $lac &= 010000; $code[002271] = *emul8; goto &fetch; }
$core[002316] = 01364; $code[002316] = *I02316; sub I02316 { $lac += $core[002364]; goto &fetch; }
$core[002317] = 03270; $code[002317] = *I02317; sub I02317 { $core[002270] = $lac & 07777; $lac &= 010000; $code[002270] = *emul8; goto &fetch; }
$core[002320] = 01362; $code[002320] = *I02320; sub I02320 { $lac += $core[002362]; goto &fetch; }
$core[002321] = 03770; $code[002321] = *I02321; sub I02321 { $core[($df<<12)+$core[1272]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1272]] = *emul8; goto &fetch; }
$core[002322] = 05713; $code[002322] = *I02322; sub I02322 { $pc = ($ib<<12)+$core[1227]; $inh = 0; goto &fetch; }
$core[002362] = 07554; $code[002362] = *D02362; sub D02362 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[002363] = 07545; $code[002363] = *D02363; sub D02363 { &emul8; goto &fetch; }
$core[002364] = 05765; $code[002364] = *D02364; sub D02364 { $pc = ($ib<<12)+$core[1269]; $inh = 0; goto &fetch; }
$core[002365] = 02512; $code[002365] = *P02365; sub P02365 { if (++$core[($df<<12)+$core[74]] == 010000) { $core[($df<<12)+$core[74]] = 0; $pc++; }$code[($df<<12)+$core[74]] = *emul8; goto &fetch; }
$core[002366] = 05272; $code[002366] = *D02366; sub D02366 { $pc = 002272; $inh = 0; goto &fetch; }
$core[002367] = 02513; $code[002367] = *P02367; sub P02367 { if (++$core[($df<<12)+$core[75]] == 010000) { $core[($df<<12)+$core[75]] = 0; $pc++; }$code[($df<<12)+$core[75]] = *emul8; goto &fetch; }
$core[002370] = 05544; $code[002370] = *P02370; sub P02370 { $pc = ($ib<<12)+$core[100]; $inh = 0; goto &fetch; }
$core[002371] = 07565; $code[002371] = *D02371; sub D02371 { &emul8; goto &fetch; }
$core[002372] = 02517; $code[002372] = *P02372; sub P02372 { if (++$core[($df<<12)+$core[79]] == 010000) { $core[($df<<12)+$core[79]] = 0; $pc++; }$code[($df<<12)+$core[79]] = *emul8; goto &fetch; }
$core[002373] = 02476; $code[002373] = *P02373; sub P02373 { if (++$core[($df<<12)+$core[62]] == 010000) { $core[($df<<12)+$core[62]] = 0; $pc++; }$code[($df<<12)+$core[62]] = *emul8; goto &fetch; }
$core[002374] = 02400; $code[002374] = *P02374; sub P02374 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[002375] = 02246; $code[002375] = *D02375; sub D02375 { if (++$core[002246] == 010000) { $core[002246] = 0; $pc++; }$code[002246] = *emul8; goto &fetch; }
$core[002376] = 02200; $code[002376] = *D02376; sub D02376 { if (++$core[002200] == 010000) { $core[002200] = 0; $pc++; }$code[002200] = *emul8; goto &fetch; }
$core[002377] = 06200; $code[002377] = *P02377; sub P02377 { &emul8; goto &fetch; }
$core[002400] = 00000; $code[002400] = *S02400; sub S02400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002401] = 04540; $code[002401] = *I02401; sub I02401 { $core[($ib<<12)+$core[96]] = 02402; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[002402] = 01377; $code[002402] = *I02402; sub I02402 { $lac += $core[002577]; goto &fetch; }
$core[002403] = 03056; $code[002403] = *I02403; sub I02403 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[002404] = 01376; $code[002404] = *I02404; sub I02404 { $lac += $core[002576]; goto &fetch; }
$core[002405] = 03057; $code[002405] = *I02405; sub I02405 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[002406] = 01775; $code[002406] = *I02406; sub I02406 { $lac += $core[($df<<12)+$core[1405]]; goto &fetch; }
$core[002407] = 03774; $code[002407] = *I02407; sub I02407 { $core[($df<<12)+$core[1404]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1404]] = *emul8; goto &fetch; }
$core[002410] = 07344; $code[002410] = *I02410; sub I02410 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002411] = 03273; $code[002411] = *I02411; sub I02411 { $core[002473] = $lac & 07777; $lac &= 010000; $code[002473] = *emul8; goto &fetch; }
$core[002412] = 07344; $code[002412] = *I02412; sub I02412 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002413] = 03274; $code[002413] = *I02413; sub I02413 { $core[002474] = $lac & 07777; $lac &= 010000; $code[002474] = *emul8; goto &fetch; }
$core[002414] = 07344; $code[002414] = *I02414; sub I02414 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002415] = 03275; $code[002415] = *I02415; sub I02415 { $core[002475] = $lac & 07777; $lac &= 010000; $code[002475] = *emul8; goto &fetch; }
$core[002416] = 01373; $code[002416] = *I02416; sub I02416 { $lac += $core[002573]; goto &fetch; }
$core[002417] = 03114; $code[002417] = *I02417; sub I02417 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[002420] = 04535; $code[002420] = *I02420; sub I02420 { $core[($ib<<12)+$core[93]] = 02421; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[002421] = 01115; $code[002421] = *I02421; sub I02421 { $lac += $core[000115]; goto &fetch; }
$core[002422] = 07700; $code[002422] = *I02422; sub I02422 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002423] = 05264; $code[002423] = *I02423; sub I02423 { $pc = 002464; $inh = 0; goto &fetch; }
$core[002424] = 07403; $code[002424] = *I02424; sub I02424 { &emul8; goto &fetch; }
$core[002425] = 05600; $code[002425] = *I02425; sub I02425 { $pc = ($ib<<12)+$core[1280]; $inh = 0; goto &fetch; }
$core[002426] = 02114; $code[002426] = *L02426; sub L02426 { if (++$core[000114] == 010000) { $core[000114] = 0; $pc++; }$code[000114] = *emul8; goto &fetch; }
$core[002427] = 05772; $code[002427] = *I02427; sub I02427 { $pc = ($ib<<12)+$core[1402]; $inh = 0; goto &fetch; }
$core[002430] = 07340; $code[002430] = *I02430; sub I02430 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002431] = 03114; $code[002431] = *I02431; sub I02431 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[002432] = 07240; $code[002432] = *I02432; sub I02432 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002433] = 03043; $code[002433] = *I02433; sub I02433 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[002434] = 03044; $code[002434] = *I02434; sub I02434 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[002435] = 02273; $code[002435] = *I02435; sub I02435 { if (++$core[002473] == 010000) { $core[002473] = 0; $pc++; }$code[002473] = *emul8; goto &fetch; }
$core[002436] = 05772; $code[002436] = *I02436; sub I02436 { $pc = ($ib<<12)+$core[1402]; $inh = 0; goto &fetch; }
$core[002437] = 07240; $code[002437] = *I02437; sub I02437 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002440] = 03114; $code[002440] = *I02440; sub I02440 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[002441] = 07240; $code[002441] = *I02441; sub I02441 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002442] = 03273; $code[002442] = *I02442; sub I02442 { $core[002473] = $lac & 07777; $lac &= 010000; $code[002473] = *emul8; goto &fetch; }
$core[002443] = 07240; $code[002443] = *I02443; sub I02443 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002444] = 03044; $code[002444] = *I02444; sub I02444 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[002445] = 03043; $code[002445] = *I02445; sub I02445 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[002446] = 02274; $code[002446] = *D02446; sub D02446 { if (++$core[002474] == 010000) { $core[002474] = 0; $pc++; }$code[002474] = *emul8; goto &fetch; }
$core[002447] = 05772; $code[002447] = *I02447; sub I02447 { $pc = ($ib<<12)+$core[1402]; $inh = 0; goto &fetch; }
$core[002450] = 07240; $code[002450] = *D02450; sub D02450 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002451] = 03114; $code[002451] = *D02451; sub D02451 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[002452] = 07040; $code[002452] = *I02452; sub I02452 { $lac ^= 07777; goto &fetch; }
$core[002453] = 03273; $code[002453] = *I02453; sub I02453 { $core[002473] = $lac & 07777; $lac &= 010000; $code[002473] = *emul8; goto &fetch; }
$core[002454] = 07040; $code[002454] = *I02454; sub I02454 { $lac ^= 07777; goto &fetch; }
$core[002455] = 03274; $code[002455] = *I02455; sub I02455 { $core[002474] = $lac & 07777; $lac &= 010000; $code[002474] = *emul8; goto &fetch; }
$core[002456] = 07040; $code[002456] = *I02456; sub I02456 { $lac ^= 07777; goto &fetch; }
$core[002457] = 03044; $code[002457] = *I02457; sub I02457 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[002460] = 07040; $code[002460] = *I02460; sub I02460 { $lac ^= 07777; goto &fetch; }
$core[002461] = 03043; $code[002461] = *I02461; sub I02461 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[002462] = 02275; $code[002462] = *I02462; sub I02462 { if (++$core[002475] == 010000) { $core[002475] = 0; $pc++; }$code[002475] = *emul8; goto &fetch; }
$core[002463] = 05772; $code[002463] = *I02463; sub I02463 { $pc = ($ib<<12)+$core[1402]; $inh = 0; goto &fetch; }
$core[002464] = 07604; $code[002464] = *L02464; sub L02464 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002465] = 07006; $code[002465] = *I02465; sub I02465 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002466] = 07004; $code[002466] = *I02466; sub I02466 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002467] = 07710; $code[002467] = *I02467; sub I02467 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002470] = 05777; $code[002470] = *I02470; sub I02470 { $pc = ($ib<<12)+$core[1407]; $inh = 0; goto &fetch; }
$core[002471] = 05672; $code[002471] = *I02471; sub I02471 { $pc = ($ib<<12)+$core[1338]; $inh = 0; goto &fetch; }
$core[002472] = 02600; $code[002472] = *P02472; sub P02472 { if (++$core[($df<<12)+$core[1280]] == 010000) { $core[($df<<12)+$core[1280]] = 0; $pc++; }$code[($df<<12)+$core[1280]] = *emul8; goto &fetch; }
$core[002473] = 00000; $code[002473] = *D02473; sub D02473 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002474] = 00000; $code[002474] = *D02474; sub D02474 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002475] = 00000; $code[002475] = *D02475; sub D02475 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002476] = 00000; $code[002476] = *D02476; sub D02476 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002477] = 01044; $code[002477] = *I02477; sub I02477 { $lac += $core[000044]; goto &fetch; }
$core[002500] = 07004; $code[002500] = *I02500; sub I02500 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002501] = 03044; $code[002501] = *I02501; sub I02501 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[002502] = 01043; $code[002502] = *I02502; sub I02502 { $lac += $core[000043]; goto &fetch; }
$core[002503] = 07004; $code[002503] = *I02503; sub I02503 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002504] = 03043; $code[002504] = *I02504; sub I02504 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[002505] = 01043; $code[002505] = *I02505; sub I02505 { $lac += $core[000043]; goto &fetch; }
$core[002506] = 03022; $code[002506] = *I02506; sub I02506 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[002507] = 01044; $code[002507] = *I02507; sub I02507 { $lac += $core[000044]; goto &fetch; }
$core[002510] = 03023; $code[002510] = *I02510; sub I02510 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[002511] = 05226; $code[002511] = *I02511; sub I02511 { $pc = 002426; $inh = 0; goto &fetch; }
$core[002512] = 04541; $code[002512] = *L02512; sub L02512 { $core[($ib<<12)+$core[97]] = 02513; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[002513] = 04545; $code[002513] = *L02513; sub L02513 { $core[($ib<<12)+$core[101]] = 02514; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[002514] = 04323; $code[002514] = *I02514; sub I02514 { $core[002523] = 02515; $pc = 002523+1; $code[002523] = *emul8; $inh = 0; goto &fetch; }
$core[002515] = 04543; $code[002515] = *I02515; sub I02515 { $core[($ib<<12)+$core[99]] = 02516; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[002516] = 07402; $code[002516] = *I02516; sub I02516 { $hlt = 1; goto &fetch; }
$core[002517] = 04544; $code[002517] = *L02517; sub L02517 { $core[($ib<<12)+$core[100]] = 02520; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[002520] = 05772; $code[002520] = *I02520; sub I02520 { $pc = ($ib<<12)+$core[1402]; $inh = 0; goto &fetch; }
$core[002521] = 07100; $code[002521] = *I02521; sub I02521 { $lac &= 07777; goto &fetch; }
$core[002522] = 05771; $code[002522] = *I02522; sub I02522 { $pc = ($ib<<12)+$core[1401]; $inh = 0; goto &fetch; }
$core[002523] = 00000; $code[002523] = *S02523; sub S02523 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002524] = 04534; $code[002524] = *I02524; sub I02524 { $core[($ib<<12)+$core[92]] = 02525; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[002525] = 07775; $code[002525] = *I02525; sub I02525 { &emul8; goto &fetch; }
$core[002526] = 07465; $code[002526] = *I02526; sub I02526 { &emul8; goto &fetch; }
$core[002527] = 07440; $code[002527] = *I02527; sub I02527 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002530] = 07443; $code[002530] = *I02530; sub I02530 { &emul8; goto &fetch; }
$core[002531] = 04537; $code[002531] = *I02531; sub I02531 { $core[($ib<<12)+$core[95]] = 02532; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[002532] = 05723; $code[002532] = *I02532; sub I02532 { $pc = ($ib<<12)+$core[1363]; $inh = 0; goto &fetch; }
$core[002571] = 02250; $code[002571] = *P02571; sub P02571 { if (++$core[002450] == 010000) { $core[002450] = 0; $pc++; }$code[002450] = *emul8; goto &fetch; }
$core[002572] = 02251; $code[002572] = *P02572; sub P02572 { if (++$core[002451] == 010000) { $core[002451] = 0; $pc++; }$code[002451] = *emul8; goto &fetch; }
$core[002573] = 07746; $code[002573] = *D02573; sub D02573 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002574] = 07002; $code[002574] = *P02574; sub P02574 { $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[002575] = 07045; $code[002575] = *P02575; sub P02575 { $lac ^= 07777; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002576] = 02426; $code[002576] = *D02576; sub D02576 { if (++$core[($df<<12)+$core[22]] == 010000) { $core[($df<<12)+$core[22]] = 0; $pc++; }$code[($df<<12)+$core[22]] = *emul8; goto &fetch; }
$core[002577] = 02246; $code[002577] = *P02577; sub P02577 { if (++$core[002446] == 010000) { $core[002446] = 0; $pc++; }$code[002446] = *emul8; goto &fetch; }
$core[002600] = 04221; $code[002600] = *L02600; sub L02600 { $core[002621] = 02601; $pc = 002621+1; $code[002621] = *emul8; $inh = 0; goto &fetch; }
$core[002601] = 04542; $code[002601] = *P02601; sub P02601 { $core[($ib<<12)+$core[98]] = 02602; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[002602] = 07240; $code[002602] = *L02602; sub L02602 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002603] = 03022; $code[002603] = *I02603; sub I02603 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[002604] = 03021; $code[002604] = *I02604; sub I02604 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[002605] = 01065; $code[002605] = *I02605; sub I02605 { $lac += $core[000065]; goto &fetch; }
$core[002606] = 07421; $code[002606] = *I02606; sub I02606 { &emul8; goto &fetch; }
$core[002607] = 07701; $code[002607] = *I02607; sub I02607 { &emul8; goto &fetch; }
$core[002610] = 03023; $code[002610] = *I02610; sub I02610 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[002611] = 07240; $code[002611] = *I02611; sub I02611 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002612] = 07573; $code[002612] = *I02612; sub I02612 { &emul8; goto &fetch; }
$core[002613] = 04541; $code[002613] = *I02613; sub I02613 { $core[($ib<<12)+$core[97]] = 02614; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[002614] = 04777; $code[002614] = *I02614; sub I02614 { $core[($ib<<12)+$core[1535]] = 02615; $pc = ($ib<<12)+$core[1535]+1; $code[($ib<<12)+$core[1535]] = *emul8; $inh = 0; goto &fetch; }
$core[002615] = 04452; $code[002615] = *I02615; sub I02615 { $core[($ib<<12)+$core[42]] = 02616; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[002616] = 07775; $code[002616] = *I02616; sub I02616 { &emul8; goto &fetch; }
$core[002617] = 05234; $code[002617] = *I02617; sub I02617 { $pc = 002634; $inh = 0; goto &fetch; }
$core[002620] = 05240; $code[002620] = *I02620; sub I02620 { $pc = 002640; $inh = 0; goto &fetch; }
$core[002621] = 00000; $code[002621] = *S02621; sub S02621 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002622] = 04540; $code[002622] = *I02622; sub I02622 { $core[($ib<<12)+$core[96]] = 02623; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[002623] = 03065; $code[002623] = *I02623; sub I02623 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[002624] = 01376; $code[002624] = *I02624; sub I02624 { $lac += $core[002776]; goto &fetch; }
$core[002625] = 03056; $code[002625] = *I02625; sub I02625 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[002626] = 01375; $code[002626] = *I02626; sub I02626 { $lac += $core[002775]; goto &fetch; }
$core[002627] = 03057; $code[002627] = *I02627; sub I02627 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[002630] = 04535; $code[002630] = *I02630; sub I02630 { $core[($ib<<12)+$core[93]] = 02631; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[002631] = 04536; $code[002631] = *I02631; sub I02631 { $core[($ib<<12)+$core[94]] = 02632; $pc = ($ib<<12)+$core[94]+1; $code[($ib<<12)+$core[94]] = *emul8; $inh = 0; goto &fetch; }
$core[002632] = 07403; $code[002632] = *I02632; sub I02632 { &emul8; goto &fetch; }
$core[002633] = 05621; $code[002633] = *I02633; sub I02633 { $pc = ($ib<<12)+$core[1425]; $inh = 0; goto &fetch; }
$core[002634] = 04545; $code[002634] = *L02634; sub L02634 { $core[($ib<<12)+$core[101]] = 02635; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[002635] = 04243; $code[002635] = *I02635; sub I02635 { $core[002643] = 02636; $pc = 002643+1; $code[002643] = *emul8; $inh = 0; goto &fetch; }
$core[002636] = 04543; $code[002636] = *I02636; sub I02636 { $core[($ib<<12)+$core[99]] = 02637; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[002637] = 07402; $code[002637] = *I02637; sub I02637 { $hlt = 1; goto &fetch; }
$core[002640] = 04544; $code[002640] = *L02640; sub L02640 { $core[($ib<<12)+$core[100]] = 02641; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[002641] = 05202; $code[002641] = *I02641; sub I02641 { $pc = 002602; $inh = 0; goto &fetch; }
$core[002642] = 05201; $code[002642] = *I02642; sub I02642 { $pc = 002601; $inh = 0; goto &fetch; }
$core[002643] = 00000; $code[002643] = *S02643; sub S02643 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002644] = 04534; $code[002644] = *I02644; sub I02644 { $core[($ib<<12)+$core[92]] = 02645; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[002645] = 07775; $code[002645] = *I02645; sub I02645 { &emul8; goto &fetch; }
$core[002646] = 07470; $code[002646] = *I02646; sub I02646 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002647] = 07440; $code[002647] = *I02647; sub I02647 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002650] = 07443; $code[002650] = *I02650; sub I02650 { &emul8; goto &fetch; }
$core[002651] = 04537; $code[002651] = *I02651; sub I02651 { $core[($ib<<12)+$core[95]] = 02652; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[002652] = 05643; $code[002652] = *I02652; sub I02652 { $pc = ($ib<<12)+$core[1443]; $inh = 0; goto &fetch; }
$core[002653] = 04267; $code[002653] = *P02653; sub P02653 { $core[002667] = 02654; $pc = 002667+1; $code[002667] = *emul8; $inh = 0; goto &fetch; }
$core[002654] = 04552; $code[002654] = *L02654; sub L02654 { $core[($ib<<12)+$core[106]] = 02655; $pc = ($ib<<12)+$core[106]+1; $code[($ib<<12)+$core[106]] = *emul8; $inh = 0; goto &fetch; }
$core[002655] = 04556; $code[002655] = *L02655; sub L02655 { $core[($ib<<12)+$core[110]] = 02656; $pc = ($ib<<12)+$core[110]+1; $code[($ib<<12)+$core[110]] = *emul8; $inh = 0; goto &fetch; }
$core[002656] = 04551; $code[002656] = *I02656; sub I02656 { $core[($ib<<12)+$core[105]] = 02657; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002657] = 01022; $code[002657] = *I02657; sub I02657 { $lac += $core[000022]; goto &fetch; }
$core[002660] = 07573; $code[002660] = *I02660; sub I02660 { &emul8; goto &fetch; }
$core[002661] = 04541; $code[002661] = *I02661; sub I02661 { $core[($ib<<12)+$core[97]] = 02662; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[002662] = 04777; $code[002662] = *I02662; sub I02662 { $core[($ib<<12)+$core[1535]] = 02663; $pc = ($ib<<12)+$core[1535]+1; $code[($ib<<12)+$core[1535]] = *emul8; $inh = 0; goto &fetch; }
$core[002663] = 04452; $code[002663] = *I02663; sub I02663 { $core[($ib<<12)+$core[42]] = 02664; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[002664] = 07773; $code[002664] = *I02664; sub I02664 { &emul8; goto &fetch; }
$core[002665] = 05300; $code[002665] = *I02665; sub I02665 { $pc = 002700; $inh = 0; goto &fetch; }
$core[002666] = 05304; $code[002666] = *I02666; sub I02666 { $pc = 002704; $inh = 0; goto &fetch; }
$core[002667] = 00000; $code[002667] = *S02667; sub S02667 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002670] = 04540; $code[002670] = *I02670; sub I02670 { $core[($ib<<12)+$core[96]] = 02671; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[002671] = 01375; $code[002671] = *I02671; sub I02671 { $lac += $core[002775]; goto &fetch; }
$core[002672] = 03056; $code[002672] = *I02672; sub I02672 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[002673] = 01374; $code[002673] = *I02673; sub I02673 { $lac += $core[002774]; goto &fetch; }
$core[002674] = 03057; $code[002674] = *I02674; sub I02674 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[002675] = 04535; $code[002675] = *I02675; sub I02675 { $core[($ib<<12)+$core[93]] = 02676; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[002676] = 04536; $code[002676] = *I02676; sub I02676 { $core[($ib<<12)+$core[94]] = 02677; $pc = ($ib<<12)+$core[94]+1; $code[($ib<<12)+$core[94]] = *emul8; $inh = 0; goto &fetch; }
$core[002677] = 05667; $code[002677] = *I02677; sub I02677 { $pc = ($ib<<12)+$core[1463]; $inh = 0; goto &fetch; }
$core[002700] = 04545; $code[002700] = *L02700; sub L02700 { $core[($ib<<12)+$core[101]] = 02701; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[002701] = 04307; $code[002701] = *I02701; sub I02701 { $core[002707] = 02702; $pc = 002707+1; $code[002707] = *emul8; $inh = 0; goto &fetch; }
$core[002702] = 04543; $code[002702] = *I02702; sub I02702 { $core[($ib<<12)+$core[99]] = 02703; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[002703] = 07402; $code[002703] = *I02703; sub I02703 { $hlt = 1; goto &fetch; }
$core[002704] = 04544; $code[002704] = *L02704; sub L02704 { $core[($ib<<12)+$core[100]] = 02705; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[002705] = 05255; $code[002705] = *I02705; sub I02705 { $pc = 002655; $inh = 0; goto &fetch; }
$core[002706] = 05254; $code[002706] = *I02706; sub I02706 { $pc = 002654; $inh = 0; goto &fetch; }
$core[002707] = 00000; $code[002707] = *S02707; sub S02707 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002710] = 04534; $code[002710] = *I02710; sub I02710 { $core[($ib<<12)+$core[92]] = 02711; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[002711] = 07775; $code[002711] = *I02711; sub I02711 { &emul8; goto &fetch; }
$core[002712] = 07470; $code[002712] = *I02712; sub I02712 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002713] = 07440; $code[002713] = *I02713; sub I02713 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002714] = 07445; $code[002714] = *I02714; sub I02714 { &emul8; goto &fetch; }
$core[002715] = 04537; $code[002715] = *I02715; sub I02715 { $core[($ib<<12)+$core[95]] = 02716; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[002716] = 05707; $code[002716] = *I02716; sub I02716 { $pc = ($ib<<12)+$core[1479]; $inh = 0; goto &fetch; }
$core[002717] = 04773; $code[002717] = *P02717; sub P02717 { $core[($ib<<12)+$core[1531]] = 02720; $pc = ($ib<<12)+$core[1531]+1; $code[($ib<<12)+$core[1531]] = *emul8; $inh = 0; goto &fetch; }
$core[002720] = 04552; $code[002720] = *L02720; sub L02720 { $core[($ib<<12)+$core[106]] = 02721; $pc = ($ib<<12)+$core[106]+1; $code[($ib<<12)+$core[106]] = *emul8; $inh = 0; goto &fetch; }
$core[002721] = 04556; $code[002721] = *L02721; sub L02721 { $core[($ib<<12)+$core[110]] = 02722; $pc = ($ib<<12)+$core[110]+1; $code[($ib<<12)+$core[110]] = *emul8; $inh = 0; goto &fetch; }
$core[002722] = 04551; $code[002722] = *I02722; sub I02722 { $core[($ib<<12)+$core[105]] = 02723; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002723] = 01022; $code[002723] = *I02723; sub I02723 { $lac += $core[000022]; goto &fetch; }
$core[002724] = 07575; $code[002724] = *I02724; sub I02724 { &emul8; goto &fetch; }
$core[002725] = 04541; $code[002725] = *I02725; sub I02725 { $core[($ib<<12)+$core[97]] = 02726; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[002726] = 04772; $code[002726] = *I02726; sub I02726 { $core[($ib<<12)+$core[1530]] = 02727; $pc = ($ib<<12)+$core[1530]+1; $code[($ib<<12)+$core[1530]] = *emul8; $inh = 0; goto &fetch; }
$core[002727] = 04452; $code[002727] = *I02727; sub I02727 { $core[($ib<<12)+$core[42]] = 02730; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[002730] = 07775; $code[002730] = *I02730; sub I02730 { &emul8; goto &fetch; }
$core[002731] = 05771; $code[002731] = *I02731; sub I02731 { $pc = ($ib<<12)+$core[1529]; $inh = 0; goto &fetch; }
$core[002732] = 05770; $code[002732] = *I02732; sub I02732 { $pc = ($ib<<12)+$core[1528]; $inh = 0; goto &fetch; }
$core[002770] = 03015; $code[002770] = *P02770; sub P02770 { $core[000015] = $lac & 07777; $lac &= 010000; $code[000015] = *emul8; goto &fetch; }
$core[002771] = 03011; $code[002771] = *P02771; sub P02771 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[002772] = 06311; $code[002772] = *P02772; sub P02772 { &emul8; goto &fetch; }
$core[002773] = 03000; $code[002773] = *P02773; sub P02773 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002774] = 02717; $code[002774] = *D02774; sub D02774 { if (++$core[($df<<12)+$core[1487]] == 010000) { $core[($df<<12)+$core[1487]] = 0; $pc++; }$code[($df<<12)+$core[1487]] = *emul8; goto &fetch; }
$core[002775] = 02653; $code[002775] = *D02775; sub D02775 { if (++$core[($df<<12)+$core[1451]] == 010000) { $core[($df<<12)+$core[1451]] = 0; $pc++; }$code[($df<<12)+$core[1451]] = *emul8; goto &fetch; }
$core[002776] = 02601; $code[002776] = *D02776; sub D02776 { if (++$core[($df<<12)+$core[1409]] == 010000) { $core[($df<<12)+$core[1409]] = 0; $pc++; }$code[($df<<12)+$core[1409]] = *emul8; goto &fetch; }
$core[002777] = 06273; $code[002777] = *P02777; sub P02777 { &emul8; goto &fetch; }
$core[003000] = 00000; $code[003000] = *S03000; sub S03000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003001] = 04540; $code[003001] = *I03001; sub I03001 { $core[($ib<<12)+$core[96]] = 03002; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[003002] = 01377; $code[003002] = *I03002; sub I03002 { $lac += $core[003177]; goto &fetch; }
$core[003003] = 03056; $code[003003] = *I03003; sub I03003 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[003004] = 01376; $code[003004] = *I03004; sub I03004 { $lac += $core[003176]; goto &fetch; }
$core[003005] = 03057; $code[003005] = *I03005; sub I03005 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[003006] = 04535; $code[003006] = *I03006; sub I03006 { $core[($ib<<12)+$core[93]] = 03007; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[003007] = 04536; $code[003007] = *I03007; sub I03007 { $core[($ib<<12)+$core[94]] = 03010; $pc = ($ib<<12)+$core[94]+1; $code[($ib<<12)+$core[94]] = *emul8; $inh = 0; goto &fetch; }
$core[003010] = 05600; $code[003010] = *I03010; sub I03010 { $pc = ($ib<<12)+$core[1536]; $inh = 0; goto &fetch; }
$core[003011] = 04545; $code[003011] = *L03011; sub L03011 { $core[($ib<<12)+$core[101]] = 03012; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003012] = 04220; $code[003012] = *I03012; sub I03012 { $core[003020] = 03013; $pc = 003020+1; $code[003020] = *emul8; $inh = 0; goto &fetch; }
$core[003013] = 04543; $code[003013] = *I03013; sub I03013 { $core[($ib<<12)+$core[99]] = 03014; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[003014] = 07402; $code[003014] = *I03014; sub I03014 { $hlt = 1; goto &fetch; }
$core[003015] = 04544; $code[003015] = *L03015; sub L03015 { $core[($ib<<12)+$core[100]] = 03016; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[003016] = 05775; $code[003016] = *I03016; sub I03016 { $pc = ($ib<<12)+$core[1661]; $inh = 0; goto &fetch; }
$core[003017] = 05774; $code[003017] = *I03017; sub I03017 { $pc = ($ib<<12)+$core[1660]; $inh = 0; goto &fetch; }
$core[003020] = 00000; $code[003020] = *S03020; sub S03020 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003021] = 04534; $code[003021] = *I03021; sub I03021 { $core[($ib<<12)+$core[92]] = 03022; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[003022] = 07775; $code[003022] = *I03022; sub I03022 { &emul8; goto &fetch; }
$core[003023] = 07473; $code[003023] = *I03023; sub I03023 { &emul8; goto &fetch; }
$core[003024] = 07440; $code[003024] = *D03024; sub D03024 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003025] = 07443; $code[003025] = *I03025; sub I03025 { &emul8; goto &fetch; }
$core[003026] = 04537; $code[003026] = *I03026; sub I03026 { $core[($ib<<12)+$core[95]] = 03027; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[003027] = 05620; $code[003027] = *I03027; sub I03027 { $pc = ($ib<<12)+$core[1552]; $inh = 0; goto &fetch; }
$core[003030] = 04267; $code[003030] = *I03030; sub I03030 { $core[003067] = 03031; $pc = 003067+1; $code[003067] = *emul8; $inh = 0; goto &fetch; }
$core[003031] = 04253; $code[003031] = *L03031; sub L03031 { $core[003053] = 03032; $pc = 003053+1; $code[003053] = *emul8; $inh = 0; goto &fetch; }
$core[003032] = 01021; $code[003032] = *L03032; sub L03032 { $lac += $core[000021]; goto &fetch; }
$core[003033] = 07104; $code[003033] = *I03033; sub I03033 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003034] = 01023; $code[003034] = *I03034; sub I03034 { $lac += $core[000023]; goto &fetch; }
$core[003035] = 07421; $code[003035] = *I03035; sub I03035 { &emul8; goto &fetch; }
$core[003036] = 01024; $code[003036] = *I03036; sub I03036 { $lac += $core[000024]; goto &fetch; }
$core[003037] = 03122; $code[003037] = *I03037; sub I03037 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[003040] = 01025; $code[003040] = *I03040; sub I03040 { $lac += $core[000025]; goto &fetch; }
$core[003041] = 03121; $code[003041] = *I03041; sub I03041 { $core[000121] = $lac & 07777; $lac &= 010000; $code[000121] = *emul8; goto &fetch; }
$core[003042] = 01022; $code[003042] = *I03042; sub I03042 { $lac += $core[000022]; goto &fetch; }
$core[003043] = 07443; $code[003043] = *I03043; sub I03043 { &emul8; goto &fetch; }
$core[003044] = 00121; $code[003044] = *I03044; sub I03044 { $lac &= (010000|$core[000121]); goto &fetch; }
$core[003045] = 04541; $code[003045] = *I03045; sub I03045 { $core[($ib<<12)+$core[97]] = 03046; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[003046] = 04773; $code[003046] = *I03046; sub I03046 { $core[($ib<<12)+$core[1659]] = 03047; $pc = ($ib<<12)+$core[1659]+1; $code[($ib<<12)+$core[1659]] = *emul8; $inh = 0; goto &fetch; }
$core[003047] = 04452; $code[003047] = *I03047; sub I03047 { $core[($ib<<12)+$core[42]] = 03050; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[003050] = 07775; $code[003050] = *I03050; sub I03050 { &emul8; goto &fetch; }
$core[003051] = 05307; $code[003051] = *I03051; sub I03051 { $pc = 003107; $inh = 0; goto &fetch; }
$core[003052] = 05325; $code[003052] = *I03052; sub I03052 { $pc = 003125; $inh = 0; goto &fetch; }
$core[003053] = 00000; $code[003053] = *S03053; sub S03053 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003054] = 04453; $code[003054] = *I03054; sub I03054 { $core[($ib<<12)+$core[43]] = 03055; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[003055] = 00000; $code[003055] = *D03055; sub D03055 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003056] = 00021; $code[003056] = *I03056; sub I03056 { $lac &= (010000|$core[000021]); goto &fetch; }
$core[003057] = 07773; $code[003057] = *I03057; sub I03057 { &emul8; goto &fetch; }
$core[003060] = 07326; $code[003060] = *I03060; sub I03060 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003061] = 07124; $code[003061] = *I03061; sub I03061 { $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003062] = 01255; $code[003062] = *I03062; sub I03062 { $lac += $core[003055]; goto &fetch; }
$core[003063] = 03255; $code[003063] = *I03063; sub I03063 { $core[003055] = $lac & 07777; $lac &= 010000; $code[003055] = *emul8; goto &fetch; }
$core[003064] = 02114; $code[003064] = *D03064; sub D03064 { if (++$core[000114] == 010000) { $core[000114] = 0; $pc++; }$code[000114] = *emul8; goto &fetch; }
$core[003065] = 05653; $code[003065] = *I03065; sub I03065 { $pc = ($ib<<12)+$core[1579]; $inh = 0; goto &fetch; }
$core[003066] = 05575; $code[003066] = *I03066; sub I03066 { $pc = ($ib<<12)+$core[125]; $inh = 0; goto &fetch; }
$core[003067] = 00000; $code[003067] = *S03067; sub S03067 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003070] = 04540; $code[003070] = *I03070; sub I03070 { $core[($ib<<12)+$core[96]] = 03071; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[003071] = 01372; $code[003071] = *I03071; sub I03071 { $lac += $core[003172]; goto &fetch; }
$core[003072] = 03255; $code[003072] = *I03072; sub I03072 { $core[003055] = $lac & 07777; $lac &= 010000; $code[003055] = *emul8; goto &fetch; }
$core[003073] = 01376; $code[003073] = *I03073; sub I03073 { $lac += $core[003176]; goto &fetch; }
$core[003074] = 03056; $code[003074] = *I03074; sub I03074 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[003075] = 01371; $code[003075] = *I03075; sub I03075 { $lac += $core[003171]; goto &fetch; }
$core[003076] = 03057; $code[003076] = *I03076; sub I03076 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[003077] = 01370; $code[003077] = *I03077; sub I03077 { $lac += $core[003170]; goto &fetch; }
$core[003100] = 03114; $code[003100] = *I03100; sub I03100 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[003101] = 01767; $code[003101] = *I03101; sub I03101 { $lac += $core[($df<<12)+$core[1655]]; goto &fetch; }
$core[003102] = 03766; $code[003102] = *I03102; sub I03102 { $core[($df<<12)+$core[1654]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1654]] = *emul8; goto &fetch; }
$core[003103] = 04535; $code[003103] = *I03103; sub I03103 { $core[($ib<<12)+$core[93]] = 03104; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[003104] = 04536; $code[003104] = *I03104; sub I03104 { $core[($ib<<12)+$core[94]] = 03105; $pc = ($ib<<12)+$core[94]+1; $code[($ib<<12)+$core[94]] = *emul8; $inh = 0; goto &fetch; }
$core[003105] = 07403; $code[003105] = *I03105; sub I03105 { &emul8; goto &fetch; }
$core[003106] = 05667; $code[003106] = *I03106; sub I03106 { $pc = ($ib<<12)+$core[1591]; $inh = 0; goto &fetch; }
$core[003107] = 01024; $code[003107] = *L03107; sub L03107 { $lac += $core[000024]; goto &fetch; }
$core[003110] = 03040; $code[003110] = *I03110; sub I03110 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[003111] = 01025; $code[003111] = *I03111; sub I03111 { $lac += $core[000025]; goto &fetch; }
$core[003112] = 03041; $code[003112] = *I03112; sub I03112 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[003113] = 03024; $code[003113] = *I03113; sub I03113 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[003114] = 03025; $code[003114] = *I03114; sub I03114 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[003115] = 04545; $code[003115] = *I03115; sub I03115 { $core[($ib<<12)+$core[101]] = 03116; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003116] = 04330; $code[003116] = *I03116; sub I03116 { $core[003130] = 03117; $pc = 003130+1; $code[003130] = *emul8; $inh = 0; goto &fetch; }
$core[003117] = 01040; $code[003117] = *P03117; sub P03117 { $lac += $core[000040]; goto &fetch; }
$core[003120] = 03024; $code[003120] = *P03120; sub P03120 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[003121] = 01041; $code[003121] = *P03121; sub P03121 { $lac += $core[000041]; goto &fetch; }
$core[003122] = 03025; $code[003122] = *I03122; sub I03122 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[003123] = 04543; $code[003123] = *I03123; sub I03123 { $core[($ib<<12)+$core[99]] = 03124; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[003124] = 07402; $code[003124] = *I03124; sub I03124 { $hlt = 1; goto &fetch; }
$core[003125] = 04544; $code[003125] = *L03125; sub L03125 { $core[($ib<<12)+$core[100]] = 03126; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[003126] = 05232; $code[003126] = *I03126; sub I03126 { $pc = 003032; $inh = 0; goto &fetch; }
$core[003127] = 05231; $code[003127] = *I03127; sub I03127 { $pc = 003031; $inh = 0; goto &fetch; }
$core[003130] = 00000; $code[003130] = *S03130; sub S03130 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003131] = 04534; $code[003131] = *I03131; sub I03131 { $core[($ib<<12)+$core[92]] = 03132; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[003132] = 07775; $code[003132] = *I03132; sub I03132 { &emul8; goto &fetch; }
$core[003133] = 07476; $code[003133] = *I03133; sub I03133 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[003134] = 07440; $code[003134] = *I03134; sub I03134 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003135] = 07443; $code[003135] = *I03135; sub I03135 { &emul8; goto &fetch; }
$core[003136] = 04537; $code[003136] = *I03136; sub I03136 { $core[($ib<<12)+$core[95]] = 03137; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[003137] = 05730; $code[003137] = *I03137; sub I03137 { $pc = ($ib<<12)+$core[1624]; $inh = 0; goto &fetch; }
$core[003166] = 07016; $code[003166] = *P03166; sub P03166 { $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003167] = 07044; $code[003167] = *P03167; sub P03167 { $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003170] = 07767; $code[003170] = *D03170; sub D03170 { &emul8; goto &fetch; }
$core[003171] = 03200; $code[003171] = *D03171; sub D03171 { $core[003000] = $lac & 07777; $lac &= 010000; $code[003000] = *emul8; goto &fetch; }
$core[003172] = 07327; $code[003172] = *D03172; sub D03172 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003173] = 06332; $code[003173] = *P03173; sub P03173 { &emul8; goto &fetch; }
$core[003174] = 02720; $code[003174] = *P03174; sub P03174 { if (++$core[($df<<12)+$core[1616]] == 010000) { $core[($df<<12)+$core[1616]] = 0; $pc++; }$code[($df<<12)+$core[1616]] = *emul8; goto &fetch; }
$core[003175] = 02721; $code[003175] = *P03175; sub P03175 { if (++$core[($df<<12)+$core[1617]] == 010000) { $core[($df<<12)+$core[1617]] = 0; $pc++; }$code[($df<<12)+$core[1617]] = *emul8; goto &fetch; }
$core[003176] = 03030; $code[003176] = *D03176; sub D03176 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[003177] = 02717; $code[003177] = *D03177; sub D03177 { if (++$core[($df<<12)+$core[1615]] == 010000) { $core[($df<<12)+$core[1615]] = 0; $pc++; }$code[($df<<12)+$core[1615]] = *emul8; goto &fetch; }
$core[003200] = 04223; $code[003200] = *D03200; sub D03200 { $core[003223] = 03201; $pc = 003223+1; $code[003223] = *emul8; $inh = 0; goto &fetch; }
$core[003201] = 04241; $code[003201] = *L03201; sub L03201 { $core[003241] = 03202; $pc = 003241+1; $code[003241] = *emul8; $inh = 0; goto &fetch; }
$core[003202] = 01021; $code[003202] = *L03202; sub L03202 { $lac += $core[000021]; goto &fetch; }
$core[003203] = 07104; $code[003203] = *I03203; sub I03203 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003204] = 01023; $code[003204] = *I03204; sub I03204 { $lac += $core[000023]; goto &fetch; }
$core[003205] = 07421; $code[003205] = *I03205; sub I03205 { &emul8; goto &fetch; }
$core[003206] = 01024; $code[003206] = *I03206; sub I03206 { $lac += $core[000024]; goto &fetch; }
$core[003207] = 03122; $code[003207] = *I03207; sub I03207 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[003210] = 01025; $code[003210] = *I03210; sub I03210 { $lac += $core[000025]; goto &fetch; }
$core[003211] = 03121; $code[003211] = *I03211; sub I03211 { $core[000121] = $lac & 07777; $lac &= 010000; $code[000121] = *emul8; goto &fetch; }
$core[003212] = 01022; $code[003212] = *I03212; sub I03212 { $lac += $core[000022]; goto &fetch; }
$core[003213] = 07443; $code[003213] = *I03213; sub I03213 { &emul8; goto &fetch; }
$core[003214] = 00121; $code[003214] = *I03214; sub I03214 { $lac &= (010000|$core[000121]); goto &fetch; }
$core[003215] = 04541; $code[003215] = *I03215; sub I03215 { $core[($ib<<12)+$core[97]] = 03216; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[003216] = 04777; $code[003216] = *I03216; sub I03216 { $core[($ib<<12)+$core[1791]] = 03217; $pc = ($ib<<12)+$core[1791]+1; $code[($ib<<12)+$core[1791]] = *emul8; $inh = 0; goto &fetch; }
$core[003217] = 04452; $code[003217] = *I03217; sub I03217 { $core[($ib<<12)+$core[42]] = 03220; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[003220] = 07775; $code[003220] = *I03220; sub I03220 { &emul8; goto &fetch; }
$core[003221] = 05257; $code[003221] = *I03221; sub I03221 { $pc = 003257; $inh = 0; goto &fetch; }
$core[003222] = 05275; $code[003222] = *I03222; sub I03222 { $pc = 003275; $inh = 0; goto &fetch; }
$core[003223] = 00000; $code[003223] = *S03223; sub S03223 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003224] = 04540; $code[003224] = *I03224; sub I03224 { $core[($ib<<12)+$core[96]] = 03225; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[003225] = 01376; $code[003225] = *I03225; sub I03225 { $lac += $core[003376]; goto &fetch; }
$core[003226] = 03056; $code[003226] = *I03226; sub I03226 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[003227] = 01375; $code[003227] = *I03227; sub I03227 { $lac += $core[003375]; goto &fetch; }
$core[003230] = 03057; $code[003230] = *I03230; sub I03230 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[003231] = 01774; $code[003231] = *I03231; sub I03231 { $lac += $core[($df<<12)+$core[1788]]; goto &fetch; }
$core[003232] = 03773; $code[003232] = *I03232; sub I03232 { $core[($df<<12)+$core[1787]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1787]] = *emul8; goto &fetch; }
$core[003233] = 03045; $code[003233] = *I03233; sub I03233 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[003234] = 03046; $code[003234] = *I03234; sub I03234 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[003235] = 04535; $code[003235] = *I03235; sub I03235 { $core[($ib<<12)+$core[93]] = 03236; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[003236] = 04536; $code[003236] = *I03236; sub I03236 { $core[($ib<<12)+$core[94]] = 03237; $pc = ($ib<<12)+$core[94]+1; $code[($ib<<12)+$core[94]] = *emul8; $inh = 0; goto &fetch; }
$core[003237] = 07403; $code[003237] = *I03237; sub I03237 { &emul8; goto &fetch; }
$core[003240] = 05623; $code[003240] = *I03240; sub I03240 { $pc = ($ib<<12)+$core[1683]; $inh = 0; goto &fetch; }
$core[003241] = 00000; $code[003241] = *S03241; sub S03241 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003242] = 04772; $code[003242] = *I03242; sub I03242 { $core[($ib<<12)+$core[1786]] = 03243; $pc = ($ib<<12)+$core[1786]+1; $code[($ib<<12)+$core[1786]] = *emul8; $inh = 0; goto &fetch; }
$core[003243] = 03022; $code[003243] = *I03243; sub I03243 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[003244] = 04772; $code[003244] = *I03244; sub I03244 { $core[($ib<<12)+$core[1786]] = 03245; $pc = ($ib<<12)+$core[1786]+1; $code[($ib<<12)+$core[1786]] = *emul8; $inh = 0; goto &fetch; }
$core[003245] = 03023; $code[003245] = *I03245; sub I03245 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[003246] = 04772; $code[003246] = *I03246; sub I03246 { $core[($ib<<12)+$core[1786]] = 03247; $pc = ($ib<<12)+$core[1786]+1; $code[($ib<<12)+$core[1786]] = *emul8; $inh = 0; goto &fetch; }
$core[003247] = 03024; $code[003247] = *I03247; sub I03247 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[003250] = 04772; $code[003250] = *I03250; sub I03250 { $core[($ib<<12)+$core[1786]] = 03251; $pc = ($ib<<12)+$core[1786]+1; $code[($ib<<12)+$core[1786]] = *emul8; $inh = 0; goto &fetch; }
$core[003251] = 03025; $code[003251] = *I03251; sub I03251 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[003252] = 07210; $code[003252] = *I03252; sub I03252 { $lac &= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003253] = 03021; $code[003253] = *I03253; sub I03253 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[003254] = 04573; $code[003254] = *I03254; sub I03254 { $core[($ib<<12)+$core[123]] = 03255; $pc = ($ib<<12)+$core[123]+1; $code[($ib<<12)+$core[123]] = *emul8; $inh = 0; goto &fetch; }
$core[003255] = 05641; $code[003255] = *I03255; sub I03255 { $pc = ($ib<<12)+$core[1697]; $inh = 0; goto &fetch; }
$core[003256] = 05575; $code[003256] = *I03256; sub I03256 { $pc = ($ib<<12)+$core[125]; $inh = 0; goto &fetch; }
$core[003257] = 01024; $code[003257] = *L03257; sub L03257 { $lac += $core[000024]; goto &fetch; }
$core[003260] = 03040; $code[003260] = *I03260; sub I03260 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[003261] = 01025; $code[003261] = *I03261; sub I03261 { $lac += $core[000025]; goto &fetch; }
$core[003262] = 03041; $code[003262] = *I03262; sub I03262 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[003263] = 03024; $code[003263] = *I03263; sub I03263 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[003264] = 03025; $code[003264] = *I03264; sub I03264 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[003265] = 04545; $code[003265] = *I03265; sub I03265 { $core[($ib<<12)+$core[101]] = 03266; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003266] = 04300; $code[003266] = *I03266; sub I03266 { $core[003300] = 03267; $pc = 003300+1; $code[003300] = *emul8; $inh = 0; goto &fetch; }
$core[003267] = 01040; $code[003267] = *I03267; sub I03267 { $lac += $core[000040]; goto &fetch; }
$core[003270] = 03024; $code[003270] = *I03270; sub I03270 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[003271] = 01041; $code[003271] = *I03271; sub I03271 { $lac += $core[000041]; goto &fetch; }
$core[003272] = 03025; $code[003272] = *I03272; sub I03272 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[003273] = 04543; $code[003273] = *I03273; sub I03273 { $core[($ib<<12)+$core[99]] = 03274; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[003274] = 07402; $code[003274] = *I03274; sub I03274 { $hlt = 1; goto &fetch; }
$core[003275] = 04544; $code[003275] = *L03275; sub L03275 { $core[($ib<<12)+$core[100]] = 03276; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[003276] = 05202; $code[003276] = *I03276; sub I03276 { $pc = 003202; $inh = 0; goto &fetch; }
$core[003277] = 05201; $code[003277] = *I03277; sub I03277 { $pc = 003201; $inh = 0; goto &fetch; }
$core[003300] = 00000; $code[003300] = *S03300; sub S03300 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003301] = 04534; $code[003301] = *I03301; sub I03301 { $core[($ib<<12)+$core[92]] = 03302; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[003302] = 07775; $code[003302] = *I03302; sub I03302 { &emul8; goto &fetch; }
$core[003303] = 07476; $code[003303] = *I03303; sub I03303 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[003304] = 07440; $code[003304] = *I03304; sub I03304 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003305] = 07445; $code[003305] = *I03305; sub I03305 { &emul8; goto &fetch; }
$core[003306] = 04537; $code[003306] = *I03306; sub I03306 { $core[($ib<<12)+$core[95]] = 03307; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[003307] = 05700; $code[003307] = *I03307; sub I03307 { $pc = ($ib<<12)+$core[1728]; $inh = 0; goto &fetch; }
$core[003310] = 04771; $code[003310] = *D03310; sub D03310 { $core[($ib<<12)+$core[1785]] = 03311; $pc = ($ib<<12)+$core[1785]+1; $code[($ib<<12)+$core[1785]] = *emul8; $inh = 0; goto &fetch; }
$core[003311] = 04770; $code[003311] = *L03311; sub L03311 { $core[($ib<<12)+$core[1784]] = 03312; $pc = ($ib<<12)+$core[1784]+1; $code[($ib<<12)+$core[1784]] = *emul8; $inh = 0; goto &fetch; }
$core[003312] = 01042; $code[003312] = *L03312; sub L03312 { $lac += $core[000042]; goto &fetch; }
$core[003313] = 07104; $code[003313] = *I03313; sub I03313 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003314] = 01044; $code[003314] = *I03314; sub I03314 { $lac += $core[000044]; goto &fetch; }
$core[003315] = 07421; $code[003315] = *I03315; sub I03315 { &emul8; goto &fetch; }
$core[003316] = 01043; $code[003316] = *I03316; sub I03316 { $lac += $core[000043]; goto &fetch; }
$core[003317] = 07445; $code[003317] = *I03317; sub I03317 { &emul8; goto &fetch; }
$core[003320] = 00121; $code[003320] = *I03320; sub I03320 { $lac &= (010000|$core[000121]); goto &fetch; }
$core[003321] = 04541; $code[003321] = *I03321; sub I03321 { $core[($ib<<12)+$core[97]] = 03322; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[003322] = 01121; $code[003322] = *I03322; sub I03322 { $lac += $core[000121]; goto &fetch; }
$core[003323] = 03037; $code[003323] = *I03323; sub I03323 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[003324] = 01122; $code[003324] = *I03324; sub I03324 { $lac += $core[000122]; goto &fetch; }
$core[003325] = 03036; $code[003325] = *I03325; sub I03325 { $core[000036] = $lac & 07777; $lac &= 010000; $code[000036] = *emul8; goto &fetch; }
$core[003326] = 04452; $code[003326] = *I03326; sub I03326 { $core[($ib<<12)+$core[42]] = 03327; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[003327] = 07775; $code[003327] = *I03327; sub I03327 { &emul8; goto &fetch; }
$core[003330] = 05767; $code[003330] = *I03330; sub I03330 { $pc = ($ib<<12)+$core[1783]; $inh = 0; goto &fetch; }
$core[003331] = 01044; $code[003331] = *D03331; sub D03331 { $lac += $core[000044]; goto &fetch; }
$core[003332] = 07421; $code[003332] = *D03332; sub D03332 { &emul8; goto &fetch; }
$core[003333] = 01043; $code[003333] = *I03333; sub I03333 { $lac += $core[000043]; goto &fetch; }
$core[003334] = 07575; $code[003334] = *I03334; sub I03334 { &emul8; goto &fetch; }
$core[003335] = 07443; $code[003335] = *I03335; sub I03335 { &emul8; goto &fetch; }
$core[003336] = 00121; $code[003336] = *I03336; sub I03336 { $lac &= (010000|$core[000121]); goto &fetch; }
$core[003337] = 07451; $code[003337] = *D03337; sub D03337 { &emul8; goto &fetch; }
$core[003340] = 05767; $code[003340] = *I03340; sub I03340 { $pc = ($ib<<12)+$core[1783]; $inh = 0; goto &fetch; }
$core[003341] = 05766; $code[003341] = *I03341; sub I03341 { $pc = ($ib<<12)+$core[1782]; $inh = 0; goto &fetch; }
$core[003366] = 03435; $code[003366] = *P03366; sub P03366 { $core[($df<<12)+$core[29]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[29]] = *emul8; goto &fetch; }
$core[003367] = 03431; $code[003367] = *P03367; sub P03367 { $core[($df<<12)+$core[25]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[25]] = *emul8; goto &fetch; }
$core[003370] = 03400; $code[003370] = *P03370; sub P03370 { $core[($df<<12)+$core[0]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[003371] = 03413; $code[003371] = *P03371; sub P03371 { $core[000013] = 0000 if ++$core[000013] == 010000; $core[($df<<12)+$core[000013]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000013]] = *emul8; goto &fetch; }
$core[003372] = 06525; $code[003372] = *P03372; sub P03372 { &emul8; goto &fetch; }
$core[003373] = 07016; $code[003373] = *P03373; sub P03373 { $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003374] = 07044; $code[003374] = *P03374; sub P03374 { $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003375] = 03310; $code[003375] = *D03375; sub D03375 { $core[003310] = $lac & 07777; $lac &= 010000; $code[003310] = *emul8; goto &fetch; }
$core[003376] = 03200; $code[003376] = *D03376; sub D03376 { $core[003200] = $lac & 07777; $lac &= 010000; $code[003200] = *emul8; goto &fetch; }
$core[003377] = 06332; $code[003377] = *P03377; sub P03377 { &emul8; goto &fetch; }
$core[003400] = 00000; $code[003400] = *S03400; sub S03400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003401] = 04453; $code[003401] = *I03401; sub I03401 { $core[($ib<<12)+$core[43]] = 03402; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[003402] = 00000; $code[003402] = *D03402; sub D03402 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003403] = 00042; $code[003403] = *I03403; sub I03403 { $lac &= (010000|$core[000042]); goto &fetch; }
$core[003404] = 07775; $code[003404] = *I03404; sub I03404 { &emul8; goto &fetch; }
$core[003405] = 07325; $code[003405] = *I03405; sub I03405 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003406] = 01202; $code[003406] = *I03406; sub I03406 { $lac += $core[003402]; goto &fetch; }
$core[003407] = 03202; $code[003407] = *I03407; sub I03407 { $core[003402] = $lac & 07777; $lac &= 010000; $code[003402] = *emul8; goto &fetch; }
$core[003410] = 02114; $code[003410] = *I03410; sub I03410 { if (++$core[000114] == 010000) { $core[000114] = 0; $pc++; }$code[000114] = *emul8; goto &fetch; }
$core[003411] = 05600; $code[003411] = *I03411; sub I03411 { $pc = ($ib<<12)+$core[1792]; $inh = 0; goto &fetch; }
$core[003412] = 05575; $code[003412] = *I03412; sub I03412 { $pc = ($ib<<12)+$core[125]; $inh = 0; goto &fetch; }
$core[003413] = 00000; $code[003413] = *S03413; sub S03413 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003414] = 04540; $code[003414] = *I03414; sub I03414 { $core[($ib<<12)+$core[96]] = 03415; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[003415] = 01377; $code[003415] = *I03415; sub I03415 { $lac += $core[003577]; goto &fetch; }
$core[003416] = 03202; $code[003416] = *I03416; sub I03416 { $core[003402] = $lac & 07777; $lac &= 010000; $code[003402] = *emul8; goto &fetch; }
$core[003417] = 01376; $code[003417] = *I03417; sub I03417 { $lac += $core[003576]; goto &fetch; }
$core[003420] = 03056; $code[003420] = *I03420; sub I03420 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[003421] = 01375; $code[003421] = *I03421; sub I03421 { $lac += $core[003575]; goto &fetch; }
$core[003422] = 03057; $code[003422] = *I03422; sub I03422 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[003423] = 01374; $code[003423] = *I03423; sub I03423 { $lac += $core[003574]; goto &fetch; }
$core[003424] = 03114; $code[003424] = *I03424; sub I03424 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[003425] = 04535; $code[003425] = *I03425; sub I03425 { $core[($ib<<12)+$core[93]] = 03426; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[003426] = 04536; $code[003426] = *I03426; sub I03426 { $core[($ib<<12)+$core[94]] = 03427; $pc = ($ib<<12)+$core[94]+1; $code[($ib<<12)+$core[94]] = *emul8; $inh = 0; goto &fetch; }
$core[003427] = 07403; $code[003427] = *I03427; sub I03427 { &emul8; goto &fetch; }
$core[003430] = 05613; $code[003430] = *I03430; sub I03430 { $pc = ($ib<<12)+$core[1803]; $inh = 0; goto &fetch; }
$core[003431] = 04545; $code[003431] = *L03431; sub L03431 { $core[($ib<<12)+$core[101]] = 03432; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003432] = 04240; $code[003432] = *I03432; sub I03432 { $core[003440] = 03433; $pc = 003440+1; $code[003440] = *emul8; $inh = 0; goto &fetch; }
$core[003433] = 04543; $code[003433] = *I03433; sub I03433 { $core[($ib<<12)+$core[99]] = 03434; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[003434] = 07402; $code[003434] = *I03434; sub I03434 { $hlt = 1; goto &fetch; }
$core[003435] = 04544; $code[003435] = *L03435; sub L03435 { $core[($ib<<12)+$core[100]] = 03436; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[003436] = 05773; $code[003436] = *I03436; sub I03436 { $pc = ($ib<<12)+$core[1915]; $inh = 0; goto &fetch; }
$core[003437] = 05772; $code[003437] = *I03437; sub I03437 { $pc = ($ib<<12)+$core[1914]; $inh = 0; goto &fetch; }
$core[003440] = 00000; $code[003440] = *S03440; sub S03440 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003441] = 04534; $code[003441] = *I03441; sub I03441 { $core[($ib<<12)+$core[92]] = 03442; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[003442] = 07775; $code[003442] = *I03442; sub I03442 { &emul8; goto &fetch; }
$core[003443] = 07501; $code[003443] = *I03443; sub I03443 { &emul8; goto &fetch; }
$core[003444] = 07440; $code[003444] = *I03444; sub I03444 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003445] = 07443; $code[003445] = *I03445; sub I03445 { &emul8; goto &fetch; }
$core[003446] = 04771; $code[003446] = *I03446; sub I03446 { $core[($ib<<12)+$core[1913]] = 03447; $pc = ($ib<<12)+$core[1913]+1; $code[($ib<<12)+$core[1913]] = *emul8; $inh = 0; goto &fetch; }
$core[003447] = 05640; $code[003447] = *I03447; sub I03447 { $pc = ($ib<<12)+$core[1824]; $inh = 0; goto &fetch; }
$core[003450] = 04314; $code[003450] = *I03450; sub I03450 { $core[003514] = 03451; $pc = 003514+1; $code[003514] = *emul8; $inh = 0; goto &fetch; }
$core[003451] = 04302; $code[003451] = *L03451; sub L03451 { $core[003502] = 03452; $pc = 003502+1; $code[003502] = *emul8; $inh = 0; goto &fetch; }
$core[003452] = 01042; $code[003452] = *L03452; sub L03452 { $lac += $core[000042]; goto &fetch; }
$core[003453] = 07104; $code[003453] = *I03453; sub I03453 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003454] = 01044; $code[003454] = *I03454; sub I03454 { $lac += $core[000044]; goto &fetch; }
$core[003455] = 07421; $code[003455] = *I03455; sub I03455 { &emul8; goto &fetch; }
$core[003456] = 01043; $code[003456] = *I03456; sub I03456 { $lac += $core[000043]; goto &fetch; }
$core[003457] = 07445; $code[003457] = *I03457; sub I03457 { &emul8; goto &fetch; }
$core[003460] = 00121; $code[003460] = *I03460; sub I03460 { $lac &= (010000|$core[000121]); goto &fetch; }
$core[003461] = 04541; $code[003461] = *I03461; sub I03461 { $core[($ib<<12)+$core[97]] = 03462; $pc = ($ib<<12)+$core[97]+1; $code[($ib<<12)+$core[97]] = *emul8; $inh = 0; goto &fetch; }
$core[003462] = 01121; $code[003462] = *I03462; sub I03462 { $lac += $core[000121]; goto &fetch; }
$core[003463] = 03037; $code[003463] = *I03463; sub I03463 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[003464] = 01122; $code[003464] = *I03464; sub I03464 { $lac += $core[000122]; goto &fetch; }
$core[003465] = 03036; $code[003465] = *I03465; sub I03465 { $core[000036] = $lac & 07777; $lac &= 010000; $code[000036] = *emul8; goto &fetch; }
$core[003466] = 04452; $code[003466] = *I03466; sub I03466 { $core[($ib<<12)+$core[42]] = 03467; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[003467] = 07775; $code[003467] = *I03467; sub I03467 { &emul8; goto &fetch; }
$core[003470] = 05326; $code[003470] = *I03470; sub I03470 { $pc = 003526; $inh = 0; goto &fetch; }
$core[003471] = 01044; $code[003471] = *I03471; sub I03471 { $lac += $core[000044]; goto &fetch; }
$core[003472] = 07421; $code[003472] = *I03472; sub I03472 { &emul8; goto &fetch; }
$core[003473] = 01043; $code[003473] = *I03473; sub I03473 { $lac += $core[000043]; goto &fetch; }
$core[003474] = 07575; $code[003474] = *I03474; sub I03474 { &emul8; goto &fetch; }
$core[003475] = 07443; $code[003475] = *I03475; sub I03475 { &emul8; goto &fetch; }
$core[003476] = 00121; $code[003476] = *I03476; sub I03476 { $lac &= (010000|$core[000121]); goto &fetch; }
$core[003477] = 07451; $code[003477] = *I03477; sub I03477 { &emul8; goto &fetch; }
$core[003500] = 05326; $code[003500] = *I03500; sub I03500 { $pc = 003526; $inh = 0; goto &fetch; }
$core[003501] = 05332; $code[003501] = *I03501; sub I03501 { $pc = 003532; $inh = 0; goto &fetch; }
$core[003502] = 00000; $code[003502] = *S03502; sub S03502 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003503] = 04770; $code[003503] = *I03503; sub I03503 { $core[($ib<<12)+$core[1912]] = 03504; $pc = ($ib<<12)+$core[1912]+1; $code[($ib<<12)+$core[1912]] = *emul8; $inh = 0; goto &fetch; }
$core[003504] = 03043; $code[003504] = *I03504; sub I03504 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[003505] = 04770; $code[003505] = *I03505; sub I03505 { $core[($ib<<12)+$core[1912]] = 03506; $pc = ($ib<<12)+$core[1912]+1; $code[($ib<<12)+$core[1912]] = *emul8; $inh = 0; goto &fetch; }
$core[003506] = 03044; $code[003506] = *I03506; sub I03506 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[003507] = 07010; $code[003507] = *I03507; sub I03507 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003510] = 03042; $code[003510] = *D03510; sub D03510 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[003511] = 04573; $code[003511] = *D03511; sub D03511 { $core[($ib<<12)+$core[123]] = 03512; $pc = ($ib<<12)+$core[123]+1; $code[($ib<<12)+$core[123]] = *emul8; $inh = 0; goto &fetch; }
$core[003512] = 05702; $code[003512] = *D03512; sub D03512 { $pc = ($ib<<12)+$core[1858]; $inh = 0; goto &fetch; }
$core[003513] = 05575; $code[003513] = *I03513; sub I03513 { $pc = ($ib<<12)+$core[125]; $inh = 0; goto &fetch; }
$core[003514] = 00000; $code[003514] = *S03514; sub S03514 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003515] = 04540; $code[003515] = *I03515; sub I03515 { $core[($ib<<12)+$core[96]] = 03516; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[003516] = 01375; $code[003516] = *I03516; sub I03516 { $lac += $core[003575]; goto &fetch; }
$core[003517] = 03056; $code[003517] = *I03517; sub I03517 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[003520] = 01367; $code[003520] = *I03520; sub I03520 { $lac += $core[003567]; goto &fetch; }
$core[003521] = 03057; $code[003521] = *I03521; sub I03521 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[003522] = 04535; $code[003522] = *I03522; sub I03522 { $core[($ib<<12)+$core[93]] = 03523; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[003523] = 04536; $code[003523] = *I03523; sub I03523 { $core[($ib<<12)+$core[94]] = 03524; $pc = ($ib<<12)+$core[94]+1; $code[($ib<<12)+$core[94]] = *emul8; $inh = 0; goto &fetch; }
$core[003524] = 07403; $code[003524] = *I03524; sub I03524 { &emul8; goto &fetch; }
$core[003525] = 05714; $code[003525] = *I03525; sub I03525 { $pc = ($ib<<12)+$core[1868]; $inh = 0; goto &fetch; }
$core[003526] = 04545; $code[003526] = *L03526; sub L03526 { $core[($ib<<12)+$core[101]] = 03527; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003527] = 04335; $code[003527] = *I03527; sub I03527 { $core[003535] = 03530; $pc = 003535+1; $code[003535] = *emul8; $inh = 0; goto &fetch; }
$core[003530] = 04543; $code[003530] = *I03530; sub I03530 { $core[($ib<<12)+$core[99]] = 03531; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[003531] = 07402; $code[003531] = *I03531; sub I03531 { $hlt = 1; goto &fetch; }
$core[003532] = 04544; $code[003532] = *L03532; sub L03532 { $core[($ib<<12)+$core[100]] = 03533; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[003533] = 05252; $code[003533] = *I03533; sub I03533 { $pc = 003452; $inh = 0; goto &fetch; }
$core[003534] = 05251; $code[003534] = *I03534; sub I03534 { $pc = 003451; $inh = 0; goto &fetch; }
$core[003535] = 00000; $code[003535] = *S03535; sub S03535 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003536] = 04534; $code[003536] = *I03536; sub I03536 { $core[($ib<<12)+$core[92]] = 03537; $pc = ($ib<<12)+$core[92]+1; $code[($ib<<12)+$core[92]] = *emul8; $inh = 0; goto &fetch; }
$core[003537] = 07775; $code[003537] = *I03537; sub I03537 { &emul8; goto &fetch; }
$core[003540] = 07501; $code[003540] = *I03540; sub I03540 { &emul8; goto &fetch; }
$core[003541] = 07440; $code[003541] = *I03541; sub I03541 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003542] = 07445; $code[003542] = *I03542; sub I03542 { &emul8; goto &fetch; }
$core[003543] = 04771; $code[003543] = *I03543; sub I03543 { $core[($ib<<12)+$core[1913]] = 03544; $pc = ($ib<<12)+$core[1913]+1; $code[($ib<<12)+$core[1913]] = *emul8; $inh = 0; goto &fetch; }
$core[003544] = 05735; $code[003544] = *I03544; sub I03544 { $pc = ($ib<<12)+$core[1885]; $inh = 0; goto &fetch; }
$core[003567] = 03600; $code[003567] = *D03567; sub D03567 { $core[($df<<12)+$core[1792]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1792]] = *emul8; goto &fetch; }
$core[003570] = 06525; $code[003570] = *P03570; sub P03570 { &emul8; goto &fetch; }
$core[003571] = 07106; $code[003571] = *P03571; sub P03571 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003572] = 03311; $code[003572] = *P03572; sub P03572 { $core[003511] = $lac & 07777; $lac &= 010000; $code[003511] = *emul8; goto &fetch; }
$core[003573] = 03312; $code[003573] = *P03573; sub P03573 { $core[003512] = $lac & 07777; $lac &= 010000; $code[003512] = *emul8; goto &fetch; }
$core[003574] = 07771; $code[003574] = *D03574; sub D03574 { &emul8; goto &fetch; }
$core[003575] = 03450; $code[003575] = *D03575; sub D03575 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[003576] = 03310; $code[003576] = *D03576; sub D03576 { $core[003510] = $lac & 07777; $lac &= 010000; $code[003510] = *emul8; goto &fetch; }
$core[003577] = 07305; $code[003577] = *D03577; sub D03577 { $lac &= 010000; $lac &= 07777; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003600] = 05257; $code[003600] = *L03600; sub L03600 { $pc = 003657; $inh = 0; goto &fetch; }
$core[003601] = 04312; $code[003601] = *L03601; sub L03601 { $core[003712] = 03602; $pc = 003712+1; $code[003712] = *emul8; $inh = 0; goto &fetch; }
$core[003602] = 07240; $code[003602] = *L03602; sub L03602 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003603] = 00305; $code[003603] = *I03603; sub I03603 { $lac &= (010000|$core[003705]); goto &fetch; }
$core[003604] = 07421; $code[003604] = *I03604; sub I03604 { &emul8; goto &fetch; }
$core[003605] = 07040; $code[003605] = *I03605; sub I03605 { $lac ^= 07777; goto &fetch; }
$core[003606] = 00304; $code[003606] = *I03606; sub I03606 { $lac &= (010000|$core[003704]); goto &fetch; }
$core[003607] = 07411; $code[003607] = *I03607; sub I03607 { &emul8; goto &fetch; }
$core[003610] = 03307; $code[003610] = *I03610; sub I03610 { $core[003707] = $lac & 07777; $lac &= 010000; $code[003707] = *emul8; goto &fetch; }
$core[003611] = 07501; $code[003611] = *I03611; sub I03611 { &emul8; goto &fetch; }
$core[003612] = 03306; $code[003612] = *I03612; sub I03612 { $core[003706] = $lac & 07777; $lac &= 010000; $code[003706] = *emul8; goto &fetch; }
$core[003613] = 07441; $code[003613] = *I03613; sub I03613 { &emul8; goto &fetch; }
$core[003614] = 03300; $code[003614] = *I03614; sub I03614 { $core[003700] = $lac & 07777; $lac &= 010000; $code[003700] = *emul8; goto &fetch; }
$core[003615] = 07040; $code[003615] = *I03615; sub I03615 { $lac ^= 07777; goto &fetch; }
$core[003616] = 00307; $code[003616] = *I03616; sub I03616 { $lac &= (010000|$core[003707]); goto &fetch; }
$core[003617] = 07140; $code[003617] = *I03617; sub I03617 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003620] = 01301; $code[003620] = *I03620; sub I03620 { $lac += $core[003701]; goto &fetch; }
$core[003621] = 07040; $code[003621] = *I03621; sub I03621 { $lac ^= 07777; goto &fetch; }
$core[003622] = 07440; $code[003622] = *I03622; sub I03622 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003623] = 05250; $code[003623] = *I03623; sub I03623 { $pc = 003650; $inh = 0; goto &fetch; }
$core[003624] = 07430; $code[003624] = *I03624; sub I03624 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003625] = 05250; $code[003625] = *I03625; sub I03625 { $pc = 003650; $inh = 0; goto &fetch; }
$core[003626] = 07240; $code[003626] = *I03626; sub I03626 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003627] = 00306; $code[003627] = *I03627; sub I03627 { $lac &= (010000|$core[003706]); goto &fetch; }
$core[003630] = 07440; $code[003630] = *I03630; sub I03630 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003631] = 05250; $code[003631] = *I03631; sub I03631 { $pc = 003650; $inh = 0; goto &fetch; }
$core[003632] = 07040; $code[003632] = *I03632; sub I03632 { $lac ^= 07777; goto &fetch; }
$core[003633] = 00300; $code[003633] = *I03633; sub I03633 { $lac &= (010000|$core[003700]); goto &fetch; }
$core[003634] = 07140; $code[003634] = *I03634; sub I03634 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003635] = 01303; $code[003635] = *I03635; sub I03635 { $lac += $core[003703]; goto &fetch; }
$core[003636] = 07040; $code[003636] = *I03636; sub I03636 { $lac ^= 07777; goto &fetch; }
$core[003637] = 07440; $code[003637] = *I03637; sub I03637 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003640] = 05250; $code[003640] = *I03640; sub I03640 { $pc = 003650; $inh = 0; goto &fetch; }
$core[003641] = 07430; $code[003641] = *I03641; sub I03641 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003642] = 05250; $code[003642] = *I03642; sub I03642 { $pc = 003650; $inh = 0; goto &fetch; }
$core[003643] = 07240; $code[003643] = *I03643; sub I03643 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003644] = 00303; $code[003644] = *I03644; sub I03644 { $lac &= (010000|$core[003703]); goto &fetch; }
$core[003645] = 07440; $code[003645] = *I03645; sub I03645 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003646] = 05254; $code[003646] = *I03646; sub I03646 { $pc = 003654; $inh = 0; goto &fetch; }
$core[003647] = 05272; $code[003647] = *I03647; sub I03647 { $pc = 003672; $inh = 0; goto &fetch; }
$core[003650] = 04545; $code[003650] = *L03650; sub L03650 { $core[($ib<<12)+$core[101]] = 03651; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003651] = 04711; $code[003651] = *I03651; sub I03651 { $core[($ib<<12)+$core[1993]] = 03652; $pc = ($ib<<12)+$core[1993]+1; $code[($ib<<12)+$core[1993]] = *emul8; $inh = 0; goto &fetch; }
$core[003652] = 04543; $code[003652] = *I03652; sub I03652 { $core[($ib<<12)+$core[99]] = 03653; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[003653] = 07402; $code[003653] = *I03653; sub I03653 { $hlt = 1; goto &fetch; }
$core[003654] = 04544; $code[003654] = *L03654; sub L03654 { $core[($ib<<12)+$core[100]] = 03655; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[003655] = 05202; $code[003655] = *I03655; sub I03655 { $pc = 003602; $inh = 0; goto &fetch; }
$core[003656] = 05201; $code[003656] = *I03656; sub I03656 { $pc = 003601; $inh = 0; goto &fetch; }
$core[003657] = 07240; $code[003657] = *L03657; sub L03657 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003660] = 00327; $code[003660] = *I03660; sub I03660 { $lac &= (010000|$core[003727]); goto &fetch; }
$core[003661] = 03012; $code[003661] = *I03661; sub I03661 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[003662] = 07040; $code[003662] = *I03662; sub I03662 { $lac ^= 07777; goto &fetch; }
$core[003663] = 00330; $code[003663] = *I03663; sub I03663 { $lac &= (010000|$core[003730]); goto &fetch; }
$core[003664] = 03013; $code[003664] = *I03664; sub I03664 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[003665] = 07040; $code[003665] = *I03665; sub I03665 { $lac ^= 07777; goto &fetch; }
$core[003666] = 00302; $code[003666] = *I03666; sub I03666 { $lac &= (010000|$core[003702]); goto &fetch; }
$core[003667] = 03303; $code[003667] = *I03667; sub I03667 { $core[003703] = $lac & 07777; $lac &= 010000; $code[003703] = *emul8; goto &fetch; }
$core[003670] = 04535; $code[003670] = *I03670; sub I03670 { $core[($ib<<12)+$core[93]] = 03671; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[003671] = 05201; $code[003671] = *I03671; sub I03671 { $pc = 003601; $inh = 0; goto &fetch; }
$core[003672] = 07604; $code[003672] = *L03672; sub L03672 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003673] = 07106; $code[003673] = *I03673; sub I03673 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003674] = 07006; $code[003674] = *I03674; sub I03674 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003675] = 07430; $code[003675] = *I03675; sub I03675 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003676] = 05200; $code[003676] = *I03676; sub I03676 { $pc = 003600; $inh = 0; goto &fetch; }
$core[003677] = 05710; $code[003677] = *I03677; sub I03677 { $pc = ($ib<<12)+$core[1992]; $inh = 0; goto &fetch; }
$core[003700] = 00000; $code[003700] = *D03700; sub D03700 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003701] = 06000; $code[003701] = *D03701; sub D03701 { &emul8; goto &fetch; }
$core[003702] = 00027; $code[003702] = *D03702; sub D03702 { $lac &= (010000|$core[000027]); goto &fetch; }
$core[003703] = 00000; $code[003703] = *D03703; sub D03703 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003704] = 00000; $code[003704] = *D03704; sub D03704 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003705] = 00000; $code[003705] = *D03705; sub D03705 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003706] = 00000; $code[003706] = *D03706; sub D03706 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003707] = 00000; $code[003707] = *D03707; sub D03707 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003710] = 04200; $code[003710] = *P03710; sub P03710 { $core[003600] = 03711; $pc = 003600+1; $code[003600] = *emul8; $inh = 0; goto &fetch; }
$core[003711] = 04000; $code[003711] = *P03711; sub P03711 { $core[000000] = 03712; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[003712] = 00000; $code[003712] = *S03712; sub S03712 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003713] = 07240; $code[003713] = *I03713; sub I03713 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003714] = 00412; $code[003714] = *I03714; sub I03714 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac &= (010000|$core[($df<<12)+$core[000012]]); goto &fetch; }
$core[003715] = 03304; $code[003715] = *I03715; sub I03715 { $core[003704] = $lac & 07777; $lac &= 010000; $code[003704] = *emul8; goto &fetch; }
$core[003716] = 07040; $code[003716] = *D03716; sub D03716 { $lac ^= 07777; goto &fetch; }
$core[003717] = 00413; $code[003717] = *D03717; sub D03717 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac &= (010000|$core[($df<<12)+$core[000013]]); goto &fetch; }
$core[003720] = 03305; $code[003720] = *I03720; sub I03720 { $core[003705] = $lac & 07777; $lac &= 010000; $code[003705] = *emul8; goto &fetch; }
$core[003721] = 07040; $code[003721] = *I03721; sub I03721 { $lac ^= 07777; goto &fetch; }
$core[003722] = 00303; $code[003722] = *I03722; sub I03722 { $lac &= (010000|$core[003703]); goto &fetch; }
$core[003723] = 07041; $code[003723] = *I03723; sub I03723 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003724] = 07040; $code[003724] = *I03724; sub I03724 { $lac ^= 07777; goto &fetch; }
$core[003725] = 03303; $code[003725] = *I03725; sub I03725 { $core[003703] = $lac & 07777; $lac &= 010000; $code[003703] = *emul8; goto &fetch; }
$core[003726] = 05331; $code[003726] = *I03726; sub I03726 { $pc = 003731; $inh = 0; goto &fetch; }
$core[003727] = 04060; $code[003727] = *D03727; sub D03727 { $core[000060] = 03730; $pc = 000060+1; $code[000060] = *emul8; $inh = 0; goto &fetch; }
$core[003730] = 04074; $code[003730] = *D03730; sub D03730 { $core[000074] = 03731; $pc = 000074+1; $code[000074] = *emul8; $inh = 0; goto &fetch; }
$core[003731] = 07240; $code[003731] = *L03731; sub L03731 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003732] = 00303; $code[003732] = *I03732; sub I03732 { $lac &= (010000|$core[003703]); goto &fetch; }
$core[003733] = 07440; $code[003733] = *I03733; sub I03733 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003734] = 05712; $code[003734] = *I03734; sub I03734 { $pc = ($ib<<12)+$core[1994]; $inh = 0; goto &fetch; }
$core[003735] = 05272; $code[003735] = *I03735; sub I03735 { $pc = 003672; $inh = 0; goto &fetch; }
$core[004000] = 00000; $code[004000] = *S04000; sub S04000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004001] = 04525; $code[004001] = *I04001; sub I04001 { $core[($ib<<12)+$core[85]] = 04002; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[004002] = 04326; $code[004002] = *I04002; sub I04002 { $core[004126] = 04003; $pc = 004126+1; $code[004126] = *emul8; $inh = 0; goto &fetch; }
$core[004003] = 04451; $code[004003] = *I04003; sub I04003 { $core[($ib<<12)+$core[41]] = 04004; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[004004] = 07772; $code[004004] = *I04004; sub I04004 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[004005] = 04777; $code[004005] = *I04005; sub I04005 { $core[($ib<<12)+$core[2175]] = 04006; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004006] = 04776; $code[004006] = *I04006; sub I04006 { $core[($ib<<12)+$core[2174]] = 04007; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004007] = 04775; $code[004007] = *I04007; sub I04007 { $core[($ib<<12)+$core[2173]] = 04010; $pc = ($ib<<12)+$core[2173]+1; $code[($ib<<12)+$core[2173]] = *emul8; $inh = 0; goto &fetch; }
$core[004010] = 04774; $code[004010] = *I04010; sub I04010 { $core[($ib<<12)+$core[2172]] = 04011; $pc = ($ib<<12)+$core[2172]+1; $code[($ib<<12)+$core[2172]] = *emul8; $inh = 0; goto &fetch; }
$core[004011] = 04451; $code[004011] = *I04011; sub I04011 { $core[($ib<<12)+$core[41]] = 04012; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[004012] = 07765; $code[004012] = *I04012; sub I04012 { &emul8; goto &fetch; }
$core[004013] = 04777; $code[004013] = *I04013; sub I04013 { $core[($ib<<12)+$core[2175]] = 04014; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004014] = 04776; $code[004014] = *I04014; sub I04014 { $core[($ib<<12)+$core[2174]] = 04015; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004015] = 04773; $code[004015] = *I04015; sub I04015 { $core[($ib<<12)+$core[2171]] = 04016; $pc = ($ib<<12)+$core[2171]+1; $code[($ib<<12)+$core[2171]] = *emul8; $inh = 0; goto &fetch; }
$core[004016] = 04774; $code[004016] = *I04016; sub I04016 { $core[($ib<<12)+$core[2172]] = 04017; $pc = ($ib<<12)+$core[2172]+1; $code[($ib<<12)+$core[2172]] = *emul8; $inh = 0; goto &fetch; }
$core[004017] = 04576; $code[004017] = *I04017; sub I04017 { $core[($ib<<12)+$core[126]] = 04020; $pc = ($ib<<12)+$core[126]+1; $code[($ib<<12)+$core[126]] = *emul8; $inh = 0; goto &fetch; }
$core[004020] = 04524; $code[004020] = *I04020; sub I04020 { $core[($ib<<12)+$core[84]] = 04021; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[004021] = 04451; $code[004021] = *I04021; sub I04021 { $core[($ib<<12)+$core[41]] = 04022; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[004022] = 07772; $code[004022] = *I04022; sub I04022 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[004023] = 01772; $code[004023] = *I04023; sub I04023 { $lac += $core[($df<<12)+$core[2170]]; goto &fetch; }
$core[004024] = 04771; $code[004024] = *I04024; sub I04024 { $core[($ib<<12)+$core[2169]] = 04025; $pc = ($ib<<12)+$core[2169]+1; $code[($ib<<12)+$core[2169]] = *emul8; $inh = 0; goto &fetch; }
$core[004025] = 04451; $code[004025] = *I04025; sub I04025 { $core[($ib<<12)+$core[41]] = 04026; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[004026] = 07775; $code[004026] = *I04026; sub I04026 { &emul8; goto &fetch; }
$core[004027] = 01770; $code[004027] = *I04027; sub I04027 { $lac += $core[($df<<12)+$core[2168]]; goto &fetch; }
$core[004030] = 04771; $code[004030] = *I04030; sub I04030 { $core[($ib<<12)+$core[2169]] = 04031; $pc = ($ib<<12)+$core[2169]+1; $code[($ib<<12)+$core[2169]] = *emul8; $inh = 0; goto &fetch; }
$core[004031] = 04524; $code[004031] = *I04031; sub I04031 { $core[($ib<<12)+$core[84]] = 04032; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[004032] = 04767; $code[004032] = *I04032; sub I04032 { $core[($ib<<12)+$core[2167]] = 04033; $pc = ($ib<<12)+$core[2167]+1; $code[($ib<<12)+$core[2167]] = *emul8; $inh = 0; goto &fetch; }
$core[004033] = 04451; $code[004033] = *I04033; sub I04033 { $core[($ib<<12)+$core[41]] = 04034; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[004034] = 07775; $code[004034] = *I04034; sub I04034 { &emul8; goto &fetch; }
$core[004035] = 01766; $code[004035] = *I04035; sub I04035 { $lac += $core[($df<<12)+$core[2166]]; goto &fetch; }
$core[004036] = 04771; $code[004036] = *I04036; sub I04036 { $core[($ib<<12)+$core[2169]] = 04037; $pc = ($ib<<12)+$core[2169]+1; $code[($ib<<12)+$core[2169]] = *emul8; $inh = 0; goto &fetch; }
$core[004037] = 04451; $code[004037] = *I04037; sub I04037 { $core[($ib<<12)+$core[41]] = 04040; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[004040] = 07775; $code[004040] = *I04040; sub I04040 { &emul8; goto &fetch; }
$core[004041] = 01765; $code[004041] = *I04041; sub I04041 { $lac += $core[($df<<12)+$core[2165]]; goto &fetch; }
$core[004042] = 04771; $code[004042] = *I04042; sub I04042 { $core[($ib<<12)+$core[2169]] = 04043; $pc = ($ib<<12)+$core[2169]+1; $code[($ib<<12)+$core[2169]] = *emul8; $inh = 0; goto &fetch; }
$core[004043] = 04524; $code[004043] = *I04043; sub I04043 { $core[($ib<<12)+$core[84]] = 04044; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[004044] = 04764; $code[004044] = *I04044; sub I04044 { $core[($ib<<12)+$core[2164]] = 04045; $pc = ($ib<<12)+$core[2164]+1; $code[($ib<<12)+$core[2164]] = *emul8; $inh = 0; goto &fetch; }
$core[004045] = 04455; $code[004045] = *I04045; sub I04045 { $core[($ib<<12)+$core[45]] = 04046; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[004046] = 01763; $code[004046] = *I04046; sub I04046 { $lac += $core[($df<<12)+$core[2163]]; goto &fetch; }
$core[004047] = 04771; $code[004047] = *I04047; sub I04047 { $core[($ib<<12)+$core[2169]] = 04050; $pc = ($ib<<12)+$core[2169]+1; $code[($ib<<12)+$core[2169]] = *emul8; $inh = 0; goto &fetch; }
$core[004050] = 04524; $code[004050] = *I04050; sub I04050 { $core[($ib<<12)+$core[84]] = 04051; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[004051] = 04762; $code[004051] = *I04051; sub I04051 { $core[($ib<<12)+$core[2162]] = 04052; $pc = ($ib<<12)+$core[2162]+1; $code[($ib<<12)+$core[2162]] = *emul8; $inh = 0; goto &fetch; }
$core[004052] = 04451; $code[004052] = *I04052; sub I04052 { $core[($ib<<12)+$core[41]] = 04053; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[004053] = 07775; $code[004053] = *I04053; sub I04053 { &emul8; goto &fetch; }
$core[004054] = 01761; $code[004054] = *I04054; sub I04054 { $lac += $core[($df<<12)+$core[2161]]; goto &fetch; }
$core[004055] = 04771; $code[004055] = *I04055; sub I04055 { $core[($ib<<12)+$core[2169]] = 04056; $pc = ($ib<<12)+$core[2169]+1; $code[($ib<<12)+$core[2169]] = *emul8; $inh = 0; goto &fetch; }
$core[004056] = 04524; $code[004056] = *I04056; sub I04056 { $core[($ib<<12)+$core[84]] = 04057; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[004057] = 05600; $code[004057] = *I04057; sub I04057 { $pc = ($ib<<12)+$core[2048]; $inh = 0; goto &fetch; }
$core[004060] = 00000; $code[004060] = *I04060; sub I04060 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004061] = 07777; $code[004061] = *I04061; sub I04061 { &emul8; goto &fetch; }
$core[004062] = 07777; $code[004062] = *I04062; sub I04062 { &emul8; goto &fetch; }
$core[004063] = 07777; $code[004063] = *I04063; sub I04063 { &emul8; goto &fetch; }
$core[004064] = 07777; $code[004064] = *I04064; sub I04064 { &emul8; goto &fetch; }
$core[004065] = 07777; $code[004065] = *I04065; sub I04065 { &emul8; goto &fetch; }
$core[004066] = 07777; $code[004066] = *I04066; sub I04066 { &emul8; goto &fetch; }
$core[004067] = 07777; $code[004067] = *I04067; sub I04067 { &emul8; goto &fetch; }
$core[004070] = 07777; $code[004070] = *I04070; sub I04070 { &emul8; goto &fetch; }
$core[004071] = 07777; $code[004071] = *I04071; sub I04071 { &emul8; goto &fetch; }
$core[004072] = 07777; $code[004072] = *I04072; sub I04072 { &emul8; goto &fetch; }
$core[004073] = 07777; $code[004073] = *I04073; sub I04073 { &emul8; goto &fetch; }
$core[004074] = 07777; $code[004074] = *I04074; sub I04074 { &emul8; goto &fetch; }
$core[004075] = 07777; $code[004075] = *I04075; sub I04075 { &emul8; goto &fetch; }
$core[004076] = 07776; $code[004076] = *I04076; sub I04076 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004077] = 07774; $code[004077] = *I04077; sub I04077 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004100] = 07770; $code[004100] = *P04100; sub P04100 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004101] = 07760; $code[004101] = *I04101; sub I04101 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004102] = 07740; $code[004102] = *D04102; sub D04102 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004103] = 07700; $code[004103] = *P04103; sub P04103 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004104] = 07600; $code[004104] = *P04104; sub P04104 { $lac &= 010000; goto &fetch; }
$core[004105] = 07400; $code[004105] = *P04105; sub P04105 { goto &fetch; }
$core[004106] = 07000; $code[004106] = *P04106; sub P04106 { goto &fetch; }
$core[004107] = 06000; $code[004107] = *P04107; sub P04107 { &emul8; goto &fetch; }
$core[004110] = 04000; $code[004110] = *I04110; sub I04110 { $core[000000] = 04111; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[004111] = 00000; $code[004111] = *I04111; sub I04111 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004112] = 00000; $code[004112] = *I04112; sub I04112 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004113] = 00000; $code[004113] = *I04113; sub I04113 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004114] = 00000; $code[004114] = *I04114; sub I04114 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004115] = 00000; $code[004115] = *I04115; sub I04115 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004116] = 00000; $code[004116] = *I04116; sub I04116 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004117] = 00000; $code[004117] = *I04117; sub I04117 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004120] = 00000; $code[004120] = *I04120; sub I04120 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004121] = 00000; $code[004121] = *I04121; sub I04121 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004122] = 00000; $code[004122] = *I04122; sub I04122 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004123] = 00000; $code[004123] = *D04123; sub D04123 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004124] = 00000; $code[004124] = *I04124; sub I04124 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004125] = 00000; $code[004125] = *I04125; sub I04125 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004126] = 00000; $code[004126] = *S04126; sub S04126 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004127] = 04332; $code[004127] = *I04127; sub I04127 { $core[004132] = 04130; $pc = 004132+1; $code[004132] = *emul8; $inh = 0; goto &fetch; }
$core[004130] = 04343; $code[004130] = *I04130; sub I04130 { $core[004143] = 04131; $pc = 004143+1; $code[004143] = *emul8; $inh = 0; goto &fetch; }
$core[004131] = 05726; $code[004131] = *I04131; sub I04131 { $pc = ($ib<<12)+$core[2134]; $inh = 0; goto &fetch; }
$core[004132] = 00000; $code[004132] = *S04132; sub S04132 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004133] = 07240; $code[004133] = *I04133; sub I04133 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004134] = 00760; $code[004134] = *I04134; sub I04134 { $lac &= (010000|$core[($df<<12)+$core[2160]]); goto &fetch; }
$core[004135] = 04526; $code[004135] = *I04135; sub I04135 { $core[($ib<<12)+$core[86]] = 04136; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[004136] = 01757; $code[004136] = *I04136; sub I04136 { $lac += $core[($df<<12)+$core[2159]]; goto &fetch; }
$core[004137] = 04526; $code[004137] = *I04137; sub I04137 { $core[($ib<<12)+$core[86]] = 04140; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[004140] = 01756; $code[004140] = *I04140; sub I04140 { $lac += $core[($df<<12)+$core[2158]]; goto &fetch; }
$core[004141] = 04526; $code[004141] = *I04141; sub I04141 { $core[($ib<<12)+$core[86]] = 04142; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[004142] = 05732; $code[004142] = *I04142; sub I04142 { $pc = ($ib<<12)+$core[2138]; $inh = 0; goto &fetch; }
$core[004143] = 00000; $code[004143] = *S04143; sub S04143 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004144] = 07240; $code[004144] = *I04144; sub I04144 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004145] = 00755; $code[004145] = *I04145; sub I04145 { $lac &= (010000|$core[($df<<12)+$core[2157]]); goto &fetch; }
$core[004146] = 04526; $code[004146] = *I04146; sub I04146 { $core[($ib<<12)+$core[86]] = 04147; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[004147] = 05743; $code[004147] = *I04147; sub I04147 { $pc = ($ib<<12)+$core[2147]; $inh = 0; goto &fetch; }
$core[004155] = 05477; $code[004155] = *P04155; sub P04155 { $pc = ($ib<<12)+$core[63]; $inh = 0; goto &fetch; }
$core[004156] = 05476; $code[004156] = *P04156; sub P04156 { $pc = ($ib<<12)+$core[62]; $inh = 0; goto &fetch; }
$core[004157] = 05475; $code[004157] = *P04157; sub P04157 { $pc = ($ib<<12)+$core[61]; $inh = 0; goto &fetch; }
$core[004160] = 05474; $code[004160] = *P04160; sub P04160 { $pc = ($ib<<12)+$core[60]; $inh = 0; goto &fetch; }
$core[004161] = 03700; $code[004161] = *P04161; sub P04161 { $core[($df<<12)+$core[2112]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2112]] = *emul8; goto &fetch; }
$core[004162] = 05434; $code[004162] = *P04162; sub P04162 { $pc = ($ib<<12)+$core[28]; $inh = 0; goto &fetch; }
$core[004163] = 03703; $code[004163] = *P04163; sub P04163 { $core[($df<<12)+$core[2115]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2115]] = *emul8; goto &fetch; }
$core[004164] = 05430; $code[004164] = *P04164; sub P04164 { $pc = ($ib<<12)+$core[24]; $inh = 0; goto &fetch; }
$core[004165] = 03706; $code[004165] = *P04165; sub P04165 { $core[($df<<12)+$core[2118]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2118]] = *emul8; goto &fetch; }
$core[004166] = 03707; $code[004166] = *P04166; sub P04166 { $core[($df<<12)+$core[2119]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2119]] = *emul8; goto &fetch; }
$core[004167] = 05425; $code[004167] = *P04167; sub P04167 { $pc = ($ib<<12)+$core[21]; $inh = 0; goto &fetch; }
$core[004170] = 03705; $code[004170] = *P04170; sub P04170 { $core[($df<<12)+$core[2117]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2117]] = *emul8; goto &fetch; }
$core[004171] = 07200; $code[004171] = *P04171; sub P04171 { $lac &= 010000; goto &fetch; }
$core[004172] = 03704; $code[004172] = *P04172; sub P04172 { $core[($df<<12)+$core[2116]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2116]] = *emul8; goto &fetch; }
$core[004173] = 00302; $code[004173] = *P04173; sub P04173 { $lac &= (010000|$core[004102]); goto &fetch; }
$core[004174] = 05467; $code[004174] = *P04174; sub P04174 { $pc = ($ib<<12)+$core[55]; $inh = 0; goto &fetch; }
$core[004175] = 00323; $code[004175] = *P04175; sub P04175 { $lac &= (010000|$core[004123]); goto &fetch; }
$core[004176] = 05462; $code[004176] = *P04176; sub P04176 { $pc = ($ib<<12)+$core[50]; $inh = 0; goto &fetch; }
$core[004177] = 05455; $code[004177] = *P04177; sub P04177 { $pc = ($ib<<12)+$core[45]; $inh = 0; goto &fetch; }
$core[004200] = 05261; $code[004200] = *L04200; sub L04200 { $pc = 004261; $inh = 0; goto &fetch; }
$core[004201] = 04273; $code[004201] = *L04201; sub L04201 { $core[004273] = 04202; $pc = 004273+1; $code[004273] = *emul8; $inh = 0; goto &fetch; }
$core[004202] = 07240; $code[004202] = *L04202; sub L04202 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004203] = 00716; $code[004203] = *I04203; sub I04203 { $lac &= (010000|$core[($df<<12)+$core[2254]]); goto &fetch; }
$core[004204] = 07421; $code[004204] = *I04204; sub I04204 { &emul8; goto &fetch; }
$core[004205] = 07240; $code[004205] = *I04205; sub I04205 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004206] = 00717; $code[004206] = *I04206; sub I04206 { $lac &= (010000|$core[($df<<12)+$core[2255]]); goto &fetch; }
$core[004207] = 07411; $code[004207] = *I04207; sub I04207 { &emul8; goto &fetch; }
$core[004210] = 03725; $code[004210] = *I04210; sub I04210 { $core[($df<<12)+$core[2261]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2261]] = *emul8; goto &fetch; }
$core[004211] = 07501; $code[004211] = *I04211; sub I04211 { &emul8; goto &fetch; }
$core[004212] = 03726; $code[004212] = *I04212; sub I04212 { $core[($df<<12)+$core[2262]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2262]] = *emul8; goto &fetch; }
$core[004213] = 07441; $code[004213] = *I04213; sub I04213 { &emul8; goto &fetch; }
$core[004214] = 03727; $code[004214] = *I04214; sub I04214 { $core[($df<<12)+$core[2263]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2263]] = *emul8; goto &fetch; }
$core[004215] = 07240; $code[004215] = *I04215; sub I04215 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004216] = 00725; $code[004216] = *D04216; sub D04216 { $lac &= (010000|$core[($df<<12)+$core[2261]]); goto &fetch; }
$core[004217] = 07140; $code[004217] = *I04217; sub I04217 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[004220] = 01716; $code[004220] = *I04220; sub I04220 { $lac += $core[($df<<12)+$core[2254]]; goto &fetch; }
$core[004221] = 07040; $code[004221] = *I04221; sub I04221 { $lac ^= 07777; goto &fetch; }
$core[004222] = 07440; $code[004222] = *I04222; sub I04222 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004223] = 05333; $code[004223] = *I04223; sub I04223 { $pc = 004333; $inh = 0; goto &fetch; }
$core[004224] = 07430; $code[004224] = *I04224; sub I04224 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004225] = 05333; $code[004225] = *I04225; sub I04225 { $pc = 004333; $inh = 0; goto &fetch; }
$core[004226] = 07240; $code[004226] = *I04226; sub I04226 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004227] = 00726; $code[004227] = *I04227; sub I04227 { $lac &= (010000|$core[($df<<12)+$core[2262]]); goto &fetch; }
$core[004230] = 07440; $code[004230] = *I04230; sub I04230 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004231] = 05333; $code[004231] = *I04231; sub I04231 { $pc = 004333; $inh = 0; goto &fetch; }
$core[004232] = 07240; $code[004232] = *I04232; sub I04232 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004233] = 00727; $code[004233] = *I04233; sub I04233 { $lac &= (010000|$core[($df<<12)+$core[2263]]); goto &fetch; }
$core[004234] = 07140; $code[004234] = *I04234; sub I04234 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[004235] = 01331; $code[004235] = *I04235; sub I04235 { $lac += $core[004331]; goto &fetch; }
$core[004236] = 07040; $code[004236] = *I04236; sub I04236 { $lac ^= 07777; goto &fetch; }
$core[004237] = 07440; $code[004237] = *I04237; sub I04237 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004240] = 05333; $code[004240] = *I04240; sub I04240 { $pc = 004333; $inh = 0; goto &fetch; }
$core[004241] = 07430; $code[004241] = *I04241; sub I04241 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004242] = 05333; $code[004242] = *I04242; sub I04242 { $pc = 004333; $inh = 0; goto &fetch; }
$core[004243] = 02315; $code[004243] = *I04243; sub I04243 { if (++$core[004315] == 010000) { $core[004315] = 0; $pc++; }$code[004315] = *emul8; goto &fetch; }
$core[004244] = 05202; $code[004244] = *I04244; sub I04244 { $pc = 004202; $inh = 0; goto &fetch; }
$core[004245] = 07604; $code[004245] = *I04245; sub I04245 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004246] = 07106; $code[004246] = *I04246; sub I04246 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004247] = 07430; $code[004247] = *I04247; sub I04247 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004250] = 05202; $code[004250] = *I04250; sub I04250 { $pc = 004202; $inh = 0; goto &fetch; }
$core[004251] = 02322; $code[004251] = *I04251; sub I04251 { if (++$core[004322] == 010000) { $core[004322] = 0; $pc++; }$code[004322] = *emul8; goto &fetch; }
$core[004252] = 05201; $code[004252] = *L04252; sub L04252 { $pc = 004201; $inh = 0; goto &fetch; }
$core[004253] = 07604; $code[004253] = *I04253; sub I04253 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004254] = 07106; $code[004254] = *I04254; sub I04254 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004255] = 07006; $code[004255] = *I04255; sub I04255 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004256] = 07430; $code[004256] = *I04256; sub I04256 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004257] = 05200; $code[004257] = *I04257; sub I04257 { $pc = 004200; $inh = 0; goto &fetch; }
$core[004260] = 05724; $code[004260] = *I04260; sub I04260 { $pc = ($ib<<12)+$core[2260]; $inh = 0; goto &fetch; }
$core[004261] = 07200; $code[004261] = *L04261; sub L04261 { $lac &= 010000; goto &fetch; }
$core[004262] = 03315; $code[004262] = *I04262; sub I04262 { $core[004315] = $lac & 07777; $lac &= 010000; $code[004315] = *emul8; goto &fetch; }
$core[004263] = 07400; $code[004263] = *I04263; sub I04263 { goto &fetch; }
$core[004264] = 07040; $code[004264] = *I04264; sub I04264 { $lac ^= 07777; goto &fetch; }
$core[004265] = 00323; $code[004265] = *I04265; sub I04265 { $lac &= (010000|$core[004323]); goto &fetch; }
$core[004266] = 03322; $code[004266] = *I04266; sub I04266 { $core[004322] = $lac & 07777; $lac &= 010000; $code[004322] = *emul8; goto &fetch; }
$core[004267] = 01331; $code[004267] = *D04267; sub D04267 { $lac += $core[004331]; goto &fetch; }
$core[004270] = 03730; $code[004270] = *I04270; sub I04270 { $core[($df<<12)+$core[2264]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2264]] = *emul8; goto &fetch; }
$core[004271] = 04535; $code[004271] = *I04271; sub I04271 { $core[($ib<<12)+$core[93]] = 04272; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[004272] = 05201; $code[004272] = *D04272; sub D04272 { $pc = 004201; $inh = 0; goto &fetch; }
$core[004273] = 00000; $code[004273] = *S04273; sub S04273 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004274] = 07240; $code[004274] = *I04274; sub I04274 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004275] = 00322; $code[004275] = *I04275; sub I04275 { $lac &= (010000|$core[004322]); goto &fetch; }
$core[004276] = 07040; $code[004276] = *I04276; sub I04276 { $lac ^= 07777; goto &fetch; }
$core[004277] = 07440; $code[004277] = *I04277; sub I04277 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004300] = 05302; $code[004300] = *P04300; sub P04300 { $pc = 004302; $inh = 0; goto &fetch; }
$core[004301] = 05307; $code[004301] = *I04301; sub I04301 { $pc = 004307; $inh = 0; goto &fetch; }
$core[004302] = 07240; $code[004302] = *L04302; sub L04302 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004303] = 00320; $code[004303] = *P04303; sub P04303 { $lac &= (010000|$core[004320]); goto &fetch; }
$core[004304] = 03716; $code[004304] = *P04304; sub P04304 { $core[($df<<12)+$core[2254]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2254]] = *emul8; goto &fetch; }
$core[004305] = 03717; $code[004305] = *P04305; sub P04305 { $core[($df<<12)+$core[2255]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2255]] = *emul8; goto &fetch; }
$core[004306] = 05673; $code[004306] = *P04306; sub P04306 { $pc = ($ib<<12)+$core[2235]; $inh = 0; goto &fetch; }
$core[004307] = 07240; $code[004307] = *P04307; sub P04307 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004310] = 00321; $code[004310] = *I04310; sub I04310 { $lac &= (010000|$core[004321]); goto &fetch; }
$core[004311] = 03716; $code[004311] = *I04311; sub I04311 { $core[($df<<12)+$core[2254]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2254]] = *emul8; goto &fetch; }
$core[004312] = 07040; $code[004312] = *I04312; sub I04312 { $lac ^= 07777; goto &fetch; }
$core[004313] = 03717; $code[004313] = *I04313; sub I04313 { $core[($df<<12)+$core[2255]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2255]] = *emul8; goto &fetch; }
$core[004314] = 05673; $code[004314] = *I04314; sub I04314 { $pc = ($ib<<12)+$core[2235]; $inh = 0; goto &fetch; }
$core[004315] = 00000; $code[004315] = *D04315; sub D04315 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004316] = 03705; $code[004316] = *P04316; sub P04316 { $core[($df<<12)+$core[2245]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2245]] = *emul8; goto &fetch; }
$core[004317] = 03704; $code[004317] = *P04317; sub P04317 { $core[($df<<12)+$core[2244]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2244]] = *emul8; goto &fetch; }
$core[004320] = 02525; $code[004320] = *D04320; sub D04320 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[004321] = 05252; $code[004321] = *D04321; sub D04321 { $pc = 004252; $inh = 0; goto &fetch; }
$core[004322] = 00000; $code[004322] = *D04322; sub D04322 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004323] = 07776; $code[004323] = *D04323; sub D04323 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004324] = 04400; $code[004324] = *P04324; sub P04324 { $core[($ib<<12)+$core[0]] = 04325; $pc = ($ib<<12)+$core[0]+1; $code[($ib<<12)+$core[0]] = *emul8; $inh = 0; goto &fetch; }
$core[004325] = 03707; $code[004325] = *P04325; sub P04325 { $core[($df<<12)+$core[2247]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2247]] = *emul8; goto &fetch; }
$core[004326] = 03706; $code[004326] = *P04326; sub P04326 { $core[($df<<12)+$core[2246]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2246]] = *emul8; goto &fetch; }
$core[004327] = 03700; $code[004327] = *P04327; sub P04327 { $core[($df<<12)+$core[2240]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2240]] = *emul8; goto &fetch; }
$core[004330] = 03703; $code[004330] = *P04330; sub P04330 { $core[($df<<12)+$core[2243]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2243]] = *emul8; goto &fetch; }
$core[004331] = 00014; $code[004331] = *D04331; sub D04331 { $lac &= (010000|$core[000014]); goto &fetch; }
$core[004332] = 04000; $code[004332] = *P04332; sub P04332 { $core[000000] = 04333; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[004333] = 04545; $code[004333] = *L04333; sub L04333 { $core[($ib<<12)+$core[101]] = 04334; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[004334] = 04732; $code[004334] = *I04334; sub I04334 { $core[($ib<<12)+$core[2266]] = 04335; $pc = ($ib<<12)+$core[2266]+1; $code[($ib<<12)+$core[2266]] = *emul8; $inh = 0; goto &fetch; }
$core[004335] = 04543; $code[004335] = *I04335; sub I04335 { $core[($ib<<12)+$core[99]] = 04336; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[004336] = 07402; $code[004336] = *I04336; sub I04336 { $hlt = 1; goto &fetch; }
$core[004337] = 04544; $code[004337] = *I04337; sub I04337 { $core[($ib<<12)+$core[100]] = 04340; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[004340] = 07610; $code[004340] = *I04340; sub I04340 { $skp = 0; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004341] = 05202; $code[004341] = *I04341; sub I04341 { $pc = 004202; $inh = 0; goto &fetch; }
$core[004342] = 03315; $code[004342] = *I04342; sub I04342 { $core[004315] = $lac & 07777; $lac &= 010000; $code[004315] = *emul8; goto &fetch; }
$core[004343] = 05202; $code[004343] = *I04343; sub I04343 { $pc = 004202; $inh = 0; goto &fetch; }
$core[004400] = 05305; $code[004400] = *P04400; sub P04400 { $pc = 004505; $inh = 0; goto &fetch; }
$core[004401] = 04253; $code[004401] = *L04401; sub L04401 { $core[004453] = 04402; $pc = 004453+1; $code[004453] = *emul8; $inh = 0; goto &fetch; }
$core[004402] = 07621; $code[004402] = *L04402; sub L04402 { &emul8; goto &fetch; }
$core[004403] = 07040; $code[004403] = *I04403; sub I04403 { $lac ^= 07777; goto &fetch; }
$core[004404] = 00725; $code[004404] = *I04404; sub I04404 { $lac &= (010000|$core[($df<<12)+$core[2389]]); goto &fetch; }
$core[004405] = 07421; $code[004405] = *I04405; sub I04405 { &emul8; goto &fetch; }
$core[004406] = 07140; $code[004406] = *I04406; sub I04406 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[004407] = 00726; $code[004407] = *I04407; sub I04407 { $lac &= (010000|$core[($df<<12)+$core[2390]]); goto &fetch; }
$core[004410] = 07411; $code[004410] = *I04410; sub I04410 { &emul8; goto &fetch; }
$core[004411] = 03727; $code[004411] = *I04411; sub I04411 { $core[($df<<12)+$core[2391]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2391]] = *emul8; goto &fetch; }
$core[004412] = 07501; $code[004412] = *I04412; sub I04412 { &emul8; goto &fetch; }
$core[004413] = 03730; $code[004413] = *I04413; sub I04413 { $core[($df<<12)+$core[2392]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2392]] = *emul8; goto &fetch; }
$core[004414] = 07441; $code[004414] = *I04414; sub I04414 { &emul8; goto &fetch; }
$core[004415] = 03734; $code[004415] = *I04415; sub I04415 { $core[($df<<12)+$core[2396]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2396]] = *emul8; goto &fetch; }
$core[004416] = 07040; $code[004416] = *I04416; sub I04416 { $lac ^= 07777; goto &fetch; }
$core[004417] = 00727; $code[004417] = *I04417; sub I04417 { $lac &= (010000|$core[($df<<12)+$core[2391]]); goto &fetch; }
$core[004420] = 07040; $code[004420] = *I04420; sub I04420 { $lac ^= 07777; goto &fetch; }
$core[004421] = 01331; $code[004421] = *I04421; sub I04421 { $lac += $core[004531]; goto &fetch; }
$core[004422] = 07040; $code[004422] = *I04422; sub I04422 { $lac ^= 07777; goto &fetch; }
$core[004423] = 07440; $code[004423] = *I04423; sub I04423 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004424] = 05313; $code[004424] = *I04424; sub I04424 { $pc = 004513; $inh = 0; goto &fetch; }
$core[004425] = 07430; $code[004425] = *I04425; sub I04425 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004426] = 05313; $code[004426] = *I04426; sub I04426 { $pc = 004513; $inh = 0; goto &fetch; }
$core[004427] = 07040; $code[004427] = *I04427; sub I04427 { $lac ^= 07777; goto &fetch; }
$core[004430] = 00730; $code[004430] = *I04430; sub I04430 { $lac &= (010000|$core[($df<<12)+$core[2392]]); goto &fetch; }
$core[004431] = 07040; $code[004431] = *I04431; sub I04431 { $lac ^= 07777; goto &fetch; }
$core[004432] = 01332; $code[004432] = *I04432; sub I04432 { $lac += $core[004532]; goto &fetch; }
$core[004433] = 07040; $code[004433] = *I04433; sub I04433 { $lac ^= 07777; goto &fetch; }
$core[004434] = 07440; $code[004434] = *I04434; sub I04434 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004435] = 05313; $code[004435] = *I04435; sub I04435 { $pc = 004513; $inh = 0; goto &fetch; }
$core[004436] = 07430; $code[004436] = *I04436; sub I04436 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004437] = 05313; $code[004437] = *I04437; sub I04437 { $pc = 004513; $inh = 0; goto &fetch; }
$core[004440] = 07040; $code[004440] = *I04440; sub I04440 { $lac ^= 07777; goto &fetch; }
$core[004441] = 00734; $code[004441] = *I04441; sub I04441 { $lac &= (010000|$core[($df<<12)+$core[2396]]); goto &fetch; }
$core[004442] = 07041; $code[004442] = *I04442; sub I04442 { $lac ^= 07777; $lac++; goto &fetch; }
$core[004443] = 01733; $code[004443] = *I04443; sub I04443 { $lac += $core[($df<<12)+$core[2395]]; goto &fetch; }
$core[004444] = 07420; $code[004444] = *I04444; sub I04444 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[004445] = 05313; $code[004445] = *I04445; sub I04445 { $pc = 004513; $inh = 0; goto &fetch; }
$core[004446] = 02336; $code[004446] = *I04446; sub I04446 { if (++$core[004536] == 010000) { $core[004536] = 0; $pc++; }$code[004536] = *emul8; goto &fetch; }
$core[004447] = 05202; $code[004447] = *I04447; sub I04447 { $pc = 004402; $inh = 0; goto &fetch; }
$core[004450] = 04544; $code[004450] = *L04450; sub L04450 { $core[($ib<<12)+$core[100]] = 04451; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[004451] = 05202; $code[004451] = *I04451; sub I04451 { $pc = 004402; $inh = 0; goto &fetch; }
$core[004452] = 05345; $code[004452] = *I04452; sub I04452 { $pc = 004545; $inh = 0; goto &fetch; }
$core[004453] = 00000; $code[004453] = *S04453; sub S04453 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004454] = 07240; $code[004454] = *I04454; sub I04454 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004455] = 00337; $code[004455] = *I04455; sub I04455 { $lac &= (010000|$core[004537]); goto &fetch; }
$core[004456] = 07040; $code[004456] = *I04456; sub I04456 { $lac ^= 07777; goto &fetch; }
$core[004457] = 07440; $code[004457] = *I04457; sub I04457 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004460] = 05262; $code[004460] = *I04460; sub I04460 { $pc = 004462; $inh = 0; goto &fetch; }
$core[004461] = 05271; $code[004461] = *I04461; sub I04461 { $pc = 004471; $inh = 0; goto &fetch; }
$core[004462] = 07200; $code[004462] = *L04462; sub L04462 { $lac &= 010000; goto &fetch; }
$core[004463] = 03726; $code[004463] = *I04463; sub I04463 { $core[($df<<12)+$core[2390]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2390]] = *emul8; goto &fetch; }
$core[004464] = 03725; $code[004464] = *I04464; sub I04464 { $core[($df<<12)+$core[2389]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2389]] = *emul8; goto &fetch; }
$core[004465] = 03331; $code[004465] = *I04465; sub I04465 { $core[004531] = $lac & 07777; $lac &= 010000; $code[004531] = *emul8; goto &fetch; }
$core[004466] = 03332; $code[004466] = *I04466; sub I04466 { $core[004532] = $lac & 07777; $lac &= 010000; $code[004532] = *emul8; goto &fetch; }
$core[004467] = 03733; $code[004467] = *I04467; sub I04467 { $core[($df<<12)+$core[2395]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2395]] = *emul8; goto &fetch; }
$core[004470] = 05653; $code[004470] = *I04470; sub I04470 { $pc = ($ib<<12)+$core[2347]; $inh = 0; goto &fetch; }
$core[004471] = 07240; $code[004471] = *L04471; sub L04471 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004472] = 00335; $code[004472] = *I04472; sub I04472 { $lac &= (010000|$core[004535]); goto &fetch; }
$core[004473] = 03725; $code[004473] = *I04473; sub I04473 { $core[($df<<12)+$core[2389]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2389]] = *emul8; goto &fetch; }
$core[004474] = 07040; $code[004474] = *I04474; sub I04474 { $lac ^= 07777; goto &fetch; }
$core[004475] = 00340; $code[004475] = *I04475; sub I04475 { $lac &= (010000|$core[004540]); goto &fetch; }
$core[004476] = 03733; $code[004476] = *I04476; sub I04476 { $core[($df<<12)+$core[2395]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2395]] = *emul8; goto &fetch; }
$core[004477] = 03726; $code[004477] = *I04477; sub I04477 { $core[($df<<12)+$core[2390]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2390]] = *emul8; goto &fetch; }
$core[004500] = 03332; $code[004500] = *P04500; sub P04500 { $core[004532] = $lac & 07777; $lac &= 010000; $code[004532] = *emul8; goto &fetch; }
$core[004501] = 07040; $code[004501] = *I04501; sub I04501 { $lac ^= 07777; goto &fetch; }
$core[004502] = 00341; $code[004502] = *I04502; sub I04502 { $lac &= (010000|$core[004541]); goto &fetch; }
$core[004503] = 03331; $code[004503] = *P04503; sub P04503 { $core[004531] = $lac & 07777; $lac &= 010000; $code[004531] = *emul8; goto &fetch; }
$core[004504] = 05653; $code[004504] = *P04504; sub P04504 { $pc = ($ib<<12)+$core[2347]; $inh = 0; goto &fetch; }
$core[004505] = 07240; $code[004505] = *P04505; sub P04505 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004506] = 00342; $code[004506] = *P04506; sub P04506 { $lac &= (010000|$core[004542]); goto &fetch; }
$core[004507] = 03337; $code[004507] = *P04507; sub P04507 { $core[004537] = $lac & 07777; $lac &= 010000; $code[004537] = *emul8; goto &fetch; }
$core[004510] = 03336; $code[004510] = *I04510; sub I04510 { $core[004536] = $lac & 07777; $lac &= 010000; $code[004536] = *emul8; goto &fetch; }
$core[004511] = 04535; $code[004511] = *I04511; sub I04511 { $core[($ib<<12)+$core[93]] = 04512; $pc = ($ib<<12)+$core[93]+1; $code[($ib<<12)+$core[93]] = *emul8; $inh = 0; goto &fetch; }
$core[004512] = 05201; $code[004512] = *I04512; sub I04512 { $pc = 004401; $inh = 0; goto &fetch; }
$core[004513] = 04545; $code[004513] = *L04513; sub L04513 { $core[($ib<<12)+$core[101]] = 04514; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[004514] = 04743; $code[004514] = *I04514; sub I04514 { $core[($ib<<12)+$core[2403]] = 04515; $pc = ($ib<<12)+$core[2403]+1; $code[($ib<<12)+$core[2403]] = *emul8; $inh = 0; goto &fetch; }
$core[004515] = 07604; $code[004515] = *I04515; sub I04515 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004516] = 07104; $code[004516] = *I04516; sub I04516 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004517] = 07430; $code[004517] = *I04517; sub I04517 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004520] = 07402; $code[004520] = *I04520; sub I04520 { $hlt = 1; goto &fetch; }
$core[004521] = 05250; $code[004521] = *I04521; sub I04521 { $pc = 004450; $inh = 0; goto &fetch; }
$core[004522] = 04546; $code[004522] = *L04522; sub L04522 { $core[($ib<<12)+$core[102]] = 04523; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[004523] = 05200; $code[004523] = *I04523; sub I04523 { $pc = 004400; $inh = 0; goto &fetch; }
$core[004524] = 05744; $code[004524] = *I04524; sub I04524 { $pc = ($ib<<12)+$core[2404]; $inh = 0; goto &fetch; }
$core[004525] = 03705; $code[004525] = *P04525; sub P04525 { $core[($df<<12)+$core[2373]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2373]] = *emul8; goto &fetch; }
$core[004526] = 03704; $code[004526] = *P04526; sub P04526 { $core[($df<<12)+$core[2372]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2372]] = *emul8; goto &fetch; }
$core[004527] = 03707; $code[004527] = *P04527; sub P04527 { $core[($df<<12)+$core[2375]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2375]] = *emul8; goto &fetch; }
$core[004530] = 03706; $code[004530] = *P04530; sub P04530 { $core[($df<<12)+$core[2374]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2374]] = *emul8; goto &fetch; }
$core[004531] = 00000; $code[004531] = *D04531; sub D04531 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004532] = 00000; $code[004532] = *D04532; sub D04532 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004533] = 03703; $code[004533] = *P04533; sub P04533 { $core[($df<<12)+$core[2371]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2371]] = *emul8; goto &fetch; }
$core[004534] = 03700; $code[004534] = *P04534; sub P04534 { $core[($df<<12)+$core[2368]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2368]] = *emul8; goto &fetch; }
$core[004535] = 00001; $code[004535] = *D04535; sub D04535 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[004536] = 00000; $code[004536] = *D04536; sub D04536 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004537] = 00000; $code[004537] = *D04537; sub D04537 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004540] = 00026; $code[004540] = *D04540; sub D04540 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[004541] = 02000; $code[004541] = *D04541; sub D04541 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[004542] = 07776; $code[004542] = *D04542; sub D04542 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004543] = 04000; $code[004543] = *P04543; sub P04543 { $core[000000] = 04544; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[004544] = 04600; $code[004544] = *P04544; sub P04544 { $core[($ib<<12)+$core[2304]] = 04545; $pc = ($ib<<12)+$core[2304]+1; $code[($ib<<12)+$core[2304]] = *emul8; $inh = 0; goto &fetch; }
$core[004545] = 02337; $code[004545] = *L04545; sub L04545 { if (++$core[004537] == 010000) { $core[004537] = 0; $pc++; }$code[004537] = *emul8; goto &fetch; }
$core[004546] = 05201; $code[004546] = *I04546; sub I04546 { $pc = 004401; $inh = 0; goto &fetch; }
$core[004547] = 05322; $code[004547] = *I04547; sub I04547 { $pc = 004522; $inh = 0; goto &fetch; }
$core[004600] = 07240; $code[004600] = *L04600; sub L04600 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004601] = 07421; $code[004601] = *I04601; sub I04601 { &emul8; goto &fetch; }
$core[004602] = 07501; $code[004602] = *I04602; sub I04602 { &emul8; goto &fetch; }
$core[004603] = 07401; $code[004603] = *I04603; sub I04603 { &emul8; goto &fetch; }
$core[004604] = 07410; $code[004604] = *I04604; sub I04604 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004605] = 07402; $code[004605] = *I04605; sub I04605 { $hlt = 1; goto &fetch; }
$core[004606] = 07040; $code[004606] = *I04606; sub I04606 { $lac ^= 07777; goto &fetch; }
$core[004607] = 07640; $code[004607] = *I04607; sub I04607 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004610] = 07402; $code[004610] = *I04610; sub I04610 { $hlt = 1; goto &fetch; }
$core[004611] = 07501; $code[004611] = *I04611; sub I04611 { &emul8; goto &fetch; }
$core[004612] = 07040; $code[004612] = *I04612; sub I04612 { $lac ^= 07777; goto &fetch; }
$core[004613] = 07440; $code[004613] = *I04613; sub I04613 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004614] = 07402; $code[004614] = *I04614; sub I04614 { $hlt = 1; goto &fetch; }
$core[004615] = 07240; $code[004615] = *I04615; sub I04615 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004616] = 07421; $code[004616] = *I04616; sub I04616 { &emul8; goto &fetch; }
$core[004617] = 07501; $code[004617] = *I04617; sub I04617 { &emul8; goto &fetch; }
$core[004620] = 07601; $code[004620] = *I04620; sub I04620 { &emul8; goto &fetch; }
$core[004621] = 07410; $code[004621] = *I04621; sub I04621 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004622] = 07402; $code[004622] = *I04622; sub I04622 { $hlt = 1; goto &fetch; }
$core[004623] = 07640; $code[004623] = *I04623; sub I04623 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004624] = 07402; $code[004624] = *I04624; sub I04624 { $hlt = 1; goto &fetch; }
$core[004625] = 07501; $code[004625] = *I04625; sub I04625 { &emul8; goto &fetch; }
$core[004626] = 07040; $code[004626] = *I04626; sub I04626 { $lac ^= 07777; goto &fetch; }
$core[004627] = 07440; $code[004627] = *I04627; sub I04627 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004630] = 07402; $code[004630] = *I04630; sub I04630 { $hlt = 1; goto &fetch; }
$core[004631] = 07240; $code[004631] = *I04631; sub I04631 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004632] = 07421; $code[004632] = *I04632; sub I04632 { &emul8; goto &fetch; }
$core[004633] = 07501; $code[004633] = *I04633; sub I04633 { &emul8; goto &fetch; }
$core[004634] = 07621; $code[004634] = *I04634; sub I04634 { &emul8; goto &fetch; }
$core[004635] = 07501; $code[004635] = *I04635; sub I04635 { &emul8; goto &fetch; }
$core[004636] = 07440; $code[004636] = *I04636; sub I04636 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004637] = 07402; $code[004637] = *I04637; sub I04637 { $hlt = 1; goto &fetch; }
$core[004640] = 07200; $code[004640] = *I04640; sub I04640 { $lac &= 010000; goto &fetch; }
$core[004641] = 01172; $code[004641] = *I04641; sub I04641 { $lac += $core[000172]; goto &fetch; }
$core[004642] = 07421; $code[004642] = *I04642; sub I04642 { &emul8; goto &fetch; }
$core[004643] = 01171; $code[004643] = *I04643; sub I04643 { $lac += $core[000171]; goto &fetch; }
$core[004644] = 07521; $code[004644] = *I04644; sub I04644 { &emul8; goto &fetch; }
$core[004645] = 01171; $code[004645] = *I04645; sub I04645 { $lac += $core[000171]; goto &fetch; }
$core[004646] = 07040; $code[004646] = *I04646; sub I04646 { $lac ^= 07777; goto &fetch; }
$core[004647] = 07440; $code[004647] = *I04647; sub I04647 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004650] = 07402; $code[004650] = *I04650; sub I04650 { $hlt = 1; goto &fetch; }
$core[004651] = 07501; $code[004651] = *I04651; sub I04651 { &emul8; goto &fetch; }
$core[004652] = 01172; $code[004652] = *L04652; sub L04652 { $lac += $core[000172]; goto &fetch; }
$core[004653] = 07040; $code[004653] = *I04653; sub I04653 { $lac ^= 07777; goto &fetch; }
$core[004654] = 07440; $code[004654] = *I04654; sub I04654 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004655] = 07402; $code[004655] = *I04655; sub I04655 { $hlt = 1; goto &fetch; }
$core[004656] = 07621; $code[004656] = *I04656; sub I04656 { &emul8; goto &fetch; }
$core[004657] = 01171; $code[004657] = *I04657; sub I04657 { $lac += $core[000171]; goto &fetch; }
$core[004660] = 07421; $code[004660] = *I04660; sub I04660 { &emul8; goto &fetch; }
$core[004661] = 01172; $code[004661] = *L04661; sub L04661 { $lac += $core[000172]; goto &fetch; }
$core[004662] = 07701; $code[004662] = *I04662; sub I04662 { &emul8; goto &fetch; }
$core[004663] = 01172; $code[004663] = *I04663; sub I04663 { $lac += $core[000172]; goto &fetch; }
$core[004664] = 07040; $code[004664] = *I04664; sub I04664 { $lac ^= 07777; goto &fetch; }
$core[004665] = 07440; $code[004665] = *I04665; sub I04665 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004666] = 07402; $code[004666] = *I04666; sub I04666 { $hlt = 1; goto &fetch; }
$core[004667] = 07621; $code[004667] = *I04667; sub I04667 { &emul8; goto &fetch; }
$core[004670] = 01115; $code[004670] = *I04670; sub I04670 { $lac += $core[000115]; goto &fetch; }
$core[004671] = 07650; $code[004671] = *I04671; sub I04671 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004672] = 05353; $code[004672] = *I04672; sub I04672 { $pc = 004753; $inh = 0; goto &fetch; }
$core[004673] = 07431; $code[004673] = *I04673; sub I04673 { &emul8; goto &fetch; }
$core[004674] = 07621; $code[004674] = *I04674; sub I04674 { &emul8; goto &fetch; }
$core[004675] = 01171; $code[004675] = *I04675; sub I04675 { $lac += $core[000171]; goto &fetch; }
$core[004676] = 07421; $code[004676] = *I04676; sub I04676 { &emul8; goto &fetch; }
$core[004677] = 01172; $code[004677] = *I04677; sub I04677 { $lac += $core[000172]; goto &fetch; }
$core[004700] = 07663; $code[004700] = *I04700; sub I04700 { &emul8; goto &fetch; }
$core[004701] = 04703; $code[004701] = *I04701; sub I04701 { $core[($ib<<12)+$core[2499]] = 04702; $pc = ($ib<<12)+$core[2499]+1; $code[($ib<<12)+$core[2499]] = *emul8; $inh = 0; goto &fetch; }
$core[004702] = 05305; $code[004702] = *I04702; sub I04702 { $pc = 004705; $inh = 0; goto &fetch; }
$core[004703] = 05252; $code[004703] = *P04703; sub P04703 { $pc = 004652; $inh = 0; goto &fetch; }
$core[004704] = 02525; $code[004704] = *I04704; sub I04704 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[004705] = 01172; $code[004705] = *L04705; sub L04705 { $lac += $core[000172]; goto &fetch; }
$core[004706] = 07040; $code[004706] = *I04706; sub I04706 { $lac ^= 07777; goto &fetch; }
$core[004707] = 07440; $code[004707] = *I04707; sub I04707 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004710] = 07402; $code[004710] = *I04710; sub I04710 { $hlt = 1; goto &fetch; }
$core[004711] = 07501; $code[004711] = *I04711; sub I04711 { &emul8; goto &fetch; }
$core[004712] = 01171; $code[004712] = *I04712; sub I04712 { $lac += $core[000171]; goto &fetch; }
$core[004713] = 07040; $code[004713] = *I04713; sub I04713 { $lac ^= 07777; goto &fetch; }
$core[004714] = 07440; $code[004714] = *I04714; sub I04714 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004715] = 07402; $code[004715] = *I04715; sub I04715 { $hlt = 1; goto &fetch; }
$core[004716] = 07431; $code[004716] = *I04716; sub I04716 { &emul8; goto &fetch; }
$core[004717] = 07621; $code[004717] = *I04717; sub I04717 { &emul8; goto &fetch; }
$core[004720] = 01171; $code[004720] = *I04720; sub I04720 { $lac += $core[000171]; goto &fetch; }
$core[004721] = 07421; $code[004721] = *I04721; sub I04721 { &emul8; goto &fetch; }
$core[004722] = 07501; $code[004722] = *I04722; sub I04722 { &emul8; goto &fetch; }
$core[004723] = 03332; $code[004723] = *I04723; sub I04723 { $core[004732] = $lac & 07777; $lac &= 010000; $code[004732] = *emul8; goto &fetch; }
$core[004724] = 01172; $code[004724] = *I04724; sub I04724 { $lac += $core[000172]; goto &fetch; }
$core[004725] = 03333; $code[004725] = *I04725; sub I04725 { $core[004733] = $lac & 07777; $lac &= 010000; $code[004733] = *emul8; goto &fetch; }
$core[004726] = 01172; $code[004726] = *I04726; sub I04726 { $lac += $core[000172]; goto &fetch; }
$core[004727] = 07665; $code[004727] = *I04727; sub I04727 { &emul8; goto &fetch; }
$core[004730] = 04732; $code[004730] = *I04730; sub I04730 { $core[($ib<<12)+$core[2522]] = 04731; $pc = ($ib<<12)+$core[2522]+1; $code[($ib<<12)+$core[2522]] = *emul8; $inh = 0; goto &fetch; }
$core[004731] = 05334; $code[004731] = *I04731; sub I04731 { $pc = 004734; $inh = 0; goto &fetch; }
$core[004732] = 00000; $code[004732] = *P04732; sub P04732 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004733] = 00000; $code[004733] = *D04733; sub D04733 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004734] = 07501; $code[004734] = *L04734; sub L04734 { &emul8; goto &fetch; }
$core[004735] = 07440; $code[004735] = *I04735; sub I04735 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004736] = 07402; $code[004736] = *I04736; sub I04736 { $hlt = 1; goto &fetch; }
$core[004737] = 01332; $code[004737] = *I04737; sub I04737 { $lac += $core[004732]; goto &fetch; }
$core[004740] = 07440; $code[004740] = *I04740; sub I04740 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004741] = 07402; $code[004741] = *I04741; sub I04741 { $hlt = 1; goto &fetch; }
$core[004742] = 01333; $code[004742] = *I04742; sub I04742 { $lac += $core[004733]; goto &fetch; }
$core[004743] = 07440; $code[004743] = *I04743; sub I04743 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004744] = 07402; $code[004744] = *I04744; sub I04744 { $hlt = 1; goto &fetch; }
$core[004745] = 07431; $code[004745] = *I04745; sub I04745 { &emul8; goto &fetch; }
$core[004746] = 07621; $code[004746] = *I04746; sub I04746 { &emul8; goto &fetch; }
$core[004747] = 07330; $code[004747] = *I04747; sub I04747 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004750] = 07411; $code[004750] = *I04750; sub I04750 { &emul8; goto &fetch; }
$core[004751] = 07440; $code[004751] = *I04751; sub I04751 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004752] = 07402; $code[004752] = *I04752; sub I04752 { $hlt = 1; goto &fetch; }
$core[004753] = 07447; $code[004753] = *L04753; sub L04753 { &emul8; goto &fetch; }
$core[004754] = 04546; $code[004754] = *I04754; sub I04754 { $core[($ib<<12)+$core[102]] = 04755; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[004755] = 05200; $code[004755] = *I04755; sub I04755 { $pc = 004600; $inh = 0; goto &fetch; }
$core[004756] = 02117; $code[004756] = *I04756; sub I04756 { if (++$core[000117] == 010000) { $core[000117] = 0; $pc++; }$code[000117] = *emul8; goto &fetch; }
$core[004757] = 05200; $code[004757] = *I04757; sub I04757 { $pc = 004600; $inh = 0; goto &fetch; }
$core[004760] = 05777; $code[004760] = *I04760; sub I04760 { $pc = ($ib<<12)+$core[2559]; $inh = 0; goto &fetch; }
$core[004777] = 05261; $code[004777] = *P04777; sub P04777 { $pc = 004661; $inh = 0; goto &fetch; }
$core[005000] = 00000; $code[005000] = *L05000; sub L05000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005001] = 07621; $code[005001] = *L05001; sub L05001 { &emul8; goto &fetch; }
$core[005002] = 07451; $code[005002] = *I05002; sub I05002 { &emul8; goto &fetch; }
$core[005003] = 07410; $code[005003] = *I05003; sub I05003 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005004] = 07402; $code[005004] = *I05004; sub I05004 { $hlt = 1; goto &fetch; }
$core[005005] = 07431; $code[005005] = *I05005; sub I05005 { &emul8; goto &fetch; }
$core[005006] = 07621; $code[005006] = *I05006; sub I05006 { &emul8; goto &fetch; }
$core[005007] = 07451; $code[005007] = *I05007; sub I05007 { &emul8; goto &fetch; }
$core[005010] = 07402; $code[005010] = *I05010; sub I05010 { $hlt = 1; goto &fetch; }
$core[005011] = 07447; $code[005011] = *I05011; sub I05011 { &emul8; goto &fetch; }
$core[005012] = 07621; $code[005012] = *I05012; sub I05012 { &emul8; goto &fetch; }
$core[005013] = 07451; $code[005013] = *I05013; sub I05013 { &emul8; goto &fetch; }
$core[005014] = 07410; $code[005014] = *I05014; sub I05014 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005015] = 07402; $code[005015] = *I05015; sub I05015 { $hlt = 1; goto &fetch; }
$core[005016] = 07431; $code[005016] = *I05016; sub I05016 { &emul8; goto &fetch; }
$core[005017] = 06007; $code[005017] = *I05017; sub I05017 { &emul8; goto &fetch; }
$core[005020] = 07621; $code[005020] = *I05020; sub I05020 { &emul8; goto &fetch; }
$core[005021] = 07451; $code[005021] = *I05021; sub I05021 { &emul8; goto &fetch; }
$core[005022] = 07610; $code[005022] = *I05022; sub I05022 { $skp = 0; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005023] = 07402; $code[005023] = *I05023; sub I05023 { $hlt = 1; goto &fetch; }
$core[005024] = 07200; $code[005024] = *I05024; sub I05024 { $lac &= 010000; goto &fetch; }
$core[005025] = 07403; $code[005025] = *I05025; sub I05025 { &emul8; goto &fetch; }
$core[005026] = 07737; $code[005026] = *I05026; sub I05026 { &emul8; goto &fetch; }
$core[005027] = 07441; $code[005027] = *I05027; sub I05027 { &emul8; goto &fetch; }
$core[005030] = 07640; $code[005030] = *I05030; sub I05030 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005031] = 07402; $code[005031] = *I05031; sub I05031 { $hlt = 1; goto &fetch; }
$core[005032] = 07403; $code[005032] = *I05032; sub I05032 { &emul8; goto &fetch; }
$core[005033] = 07776; $code[005033] = *D05033; sub D05033 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[005034] = 07441; $code[005034] = *I05034; sub I05034 { &emul8; goto &fetch; }
$core[005035] = 01233; $code[005035] = *I05035; sub I05035 { $lac += $core[005033]; goto &fetch; }
$core[005036] = 07040; $code[005036] = *I05036; sub I05036 { $lac ^= 07777; goto &fetch; }
$core[005037] = 07640; $code[005037] = *I05037; sub I05037 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005040] = 07402; $code[005040] = *I05040; sub I05040 { $hlt = 1; goto &fetch; }
$core[005041] = 07403; $code[005041] = *I05041; sub I05041 { &emul8; goto &fetch; }
$core[005042] = 07775; $code[005042] = *D05042; sub D05042 { &emul8; goto &fetch; }
$core[005043] = 07441; $code[005043] = *I05043; sub I05043 { &emul8; goto &fetch; }
$core[005044] = 01242; $code[005044] = *I05044; sub I05044 { $lac += $core[005042]; goto &fetch; }
$core[005045] = 07040; $code[005045] = *I05045; sub I05045 { $lac ^= 07777; goto &fetch; }
$core[005046] = 07640; $code[005046] = *I05046; sub I05046 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005047] = 07402; $code[005047] = *I05047; sub I05047 { $hlt = 1; goto &fetch; }
$core[005050] = 07403; $code[005050] = *I05050; sub I05050 { &emul8; goto &fetch; }
$core[005051] = 07773; $code[005051] = *D05051; sub D05051 { &emul8; goto &fetch; }
$core[005052] = 07441; $code[005052] = *I05052; sub I05052 { &emul8; goto &fetch; }
$core[005053] = 01251; $code[005053] = *I05053; sub I05053 { $lac += $core[005051]; goto &fetch; }
$core[005054] = 07040; $code[005054] = *I05054; sub I05054 { $lac ^= 07777; goto &fetch; }
$core[005055] = 07640; $code[005055] = *I05055; sub I05055 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005056] = 07402; $code[005056] = *I05056; sub I05056 { $hlt = 1; goto &fetch; }
$core[005057] = 07403; $code[005057] = *I05057; sub I05057 { &emul8; goto &fetch; }
$core[005060] = 07767; $code[005060] = *D05060; sub D05060 { &emul8; goto &fetch; }
$core[005061] = 07441; $code[005061] = *I05061; sub I05061 { &emul8; goto &fetch; }
$core[005062] = 01260; $code[005062] = *I05062; sub I05062 { $lac += $core[005060]; goto &fetch; }
$core[005063] = 07040; $code[005063] = *I05063; sub I05063 { $lac ^= 07777; goto &fetch; }
$core[005064] = 07640; $code[005064] = *I05064; sub I05064 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005065] = 07402; $code[005065] = *I05065; sub I05065 { $hlt = 1; goto &fetch; }
$core[005066] = 07403; $code[005066] = *I05066; sub I05066 { &emul8; goto &fetch; }
$core[005067] = 07757; $code[005067] = *D05067; sub D05067 { &emul8; goto &fetch; }
$core[005070] = 07441; $code[005070] = *I05070; sub I05070 { &emul8; goto &fetch; }
$core[005071] = 01267; $code[005071] = *I05071; sub I05071 { $lac += $core[005067]; goto &fetch; }
$core[005072] = 07040; $code[005072] = *I05072; sub I05072 { $lac ^= 07777; goto &fetch; }
$core[005073] = 07640; $code[005073] = *I05073; sub I05073 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005074] = 07402; $code[005074] = *I05074; sub I05074 { $hlt = 1; goto &fetch; }
$core[005075] = 07403; $code[005075] = *I05075; sub I05075 { &emul8; goto &fetch; }
$core[005076] = 07765; $code[005076] = *D05076; sub D05076 { &emul8; goto &fetch; }
$core[005077] = 07441; $code[005077] = *I05077; sub I05077 { &emul8; goto &fetch; }
$core[005100] = 01276; $code[005100] = *I05100; sub I05100 { $lac += $core[005076]; goto &fetch; }
$core[005101] = 07040; $code[005101] = *I05101; sub I05101 { $lac ^= 07777; goto &fetch; }
$core[005102] = 07640; $code[005102] = *I05102; sub I05102 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005103] = 07402; $code[005103] = *I05103; sub I05103 { $hlt = 1; goto &fetch; }
$core[005104] = 07403; $code[005104] = *I05104; sub I05104 { &emul8; goto &fetch; }
$core[005105] = 07752; $code[005105] = *D05105; sub D05105 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[005106] = 07441; $code[005106] = *I05106; sub I05106 { &emul8; goto &fetch; }
$core[005107] = 01305; $code[005107] = *I05107; sub I05107 { $lac += $core[005105]; goto &fetch; }
$core[005110] = 07040; $code[005110] = *I05110; sub I05110 { $lac ^= 07777; goto &fetch; }
$core[005111] = 07640; $code[005111] = *I05111; sub I05111 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005112] = 07402; $code[005112] = *I05112; sub I05112 { $hlt = 1; goto &fetch; }
$core[005113] = 07403; $code[005113] = *I05113; sub I05113 { &emul8; goto &fetch; }
$core[005114] = 00077; $code[005114] = *I05114; sub I05114 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[005115] = 07441; $code[005115] = *I05115; sub I05115 { &emul8; goto &fetch; }
$core[005116] = 07640; $code[005116] = *I05116; sub I05116 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005117] = 07402; $code[005117] = *I05117; sub I05117 { $hlt = 1; goto &fetch; }
$core[005120] = 07403; $code[005120] = *I05120; sub I05120 { &emul8; goto &fetch; }
$core[005121] = 07700; $code[005121] = *I05121; sub I05121 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005122] = 07441; $code[005122] = *I05122; sub I05122 { &emul8; goto &fetch; }
$core[005123] = 01123; $code[005123] = *I05123; sub I05123 { $lac += $core[000123]; goto &fetch; }
$core[005124] = 07040; $code[005124] = *I05124; sub I05124 { $lac ^= 07777; goto &fetch; }
$core[005125] = 07640; $code[005125] = *I05125; sub I05125 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005126] = 07402; $code[005126] = *I05126; sub I05126 { $hlt = 1; goto &fetch; }
$core[005127] = 07403; $code[005127] = *I05127; sub I05127 { &emul8; goto &fetch; }
$core[005130] = 07777; $code[005130] = *I05130; sub I05130 { &emul8; goto &fetch; }
$core[005131] = 07240; $code[005131] = *I05131; sub I05131 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005132] = 07441; $code[005132] = *I05132; sub I05132 { &emul8; goto &fetch; }
$core[005133] = 07040; $code[005133] = *I05133; sub I05133 { $lac ^= 07777; goto &fetch; }
$core[005134] = 07440; $code[005134] = *I05134; sub I05134 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005135] = 07402; $code[005135] = *I05135; sub I05135 { $hlt = 1; goto &fetch; }
$core[005136] = 07403; $code[005136] = *I05136; sub I05136 { &emul8; goto &fetch; }
$core[005137] = 07752; $code[005137] = *D05137; sub D05137 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[005140] = 07200; $code[005140] = *I05140; sub I05140 { $lac &= 010000; goto &fetch; }
$core[005141] = 01337; $code[005141] = *I05141; sub I05141 { $lac += $core[005137]; goto &fetch; }
$core[005142] = 07441; $code[005142] = *I05142; sub I05142 { &emul8; goto &fetch; }
$core[005143] = 07040; $code[005143] = *I05143; sub I05143 { $lac ^= 07777; goto &fetch; }
$core[005144] = 07440; $code[005144] = *I05144; sub I05144 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005145] = 07402; $code[005145] = *I05145; sub I05145 { $hlt = 1; goto &fetch; }
$core[005146] = 07403; $code[005146] = *I05146; sub I05146 { &emul8; goto &fetch; }
$core[005147] = 07765; $code[005147] = *D05147; sub D05147 { &emul8; goto &fetch; }
$core[005150] = 07200; $code[005150] = *I05150; sub I05150 { $lac &= 010000; goto &fetch; }
$core[005151] = 01347; $code[005151] = *I05151; sub I05151 { $lac += $core[005147]; goto &fetch; }
$core[005152] = 07441; $code[005152] = *I05152; sub I05152 { &emul8; goto &fetch; }
$core[005153] = 07040; $code[005153] = *I05153; sub I05153 { $lac ^= 07777; goto &fetch; }
$core[005154] = 07440; $code[005154] = *I05154; sub I05154 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005155] = 07402; $code[005155] = *I05155; sub I05155 { $hlt = 1; goto &fetch; }
$core[005156] = 07431; $code[005156] = *I05156; sub I05156 { &emul8; goto &fetch; }
$core[005157] = 07360; $code[005157] = *I05157; sub I05157 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[005160] = 07403; $code[005160] = *I05160; sub I05160 { &emul8; goto &fetch; }
$core[005161] = 07430; $code[005161] = *I05161; sub I05161 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005162] = 07440; $code[005162] = *I05162; sub I05162 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005163] = 07402; $code[005163] = *I05163; sub I05163 { $hlt = 1; goto &fetch; }
$core[005164] = 07441; $code[005164] = *I05164; sub I05164 { &emul8; goto &fetch; }
$core[005165] = 01123; $code[005165] = *I05165; sub I05165 { $lac += $core[000123]; goto &fetch; }
$core[005166] = 07040; $code[005166] = *I05166; sub I05166 { $lac ^= 07777; goto &fetch; }
$core[005167] = 07440; $code[005167] = *I05167; sub I05167 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005170] = 07402; $code[005170] = *I05170; sub I05170 { $hlt = 1; goto &fetch; }
$core[005171] = 05777; $code[005171] = *I05171; sub I05171 { $pc = ($ib<<12)+$core[2687]; $inh = 0; goto &fetch; }
$core[005177] = 05200; $code[005177] = *P05177; sub P05177 { $pc = 005000; $inh = 0; goto &fetch; }
$core[005200] = 07320; $code[005200] = *L05200; sub L05200 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[005201] = 01123; $code[005201] = *I05201; sub I05201 { $lac += $core[000123]; goto &fetch; }
$core[005202] = 07403; $code[005202] = *D05202; sub D05202 { &emul8; goto &fetch; }
$core[005203] = 07430; $code[005203] = *I05203; sub I05203 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005204] = 07440; $code[005204] = *D05204; sub D05204 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005205] = 07402; $code[005205] = *I05205; sub I05205 { $hlt = 1; goto &fetch; }
$core[005206] = 07441; $code[005206] = *I05206; sub I05206 { &emul8; goto &fetch; }
$core[005207] = 07440; $code[005207] = *I05207; sub I05207 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005210] = 07402; $code[005210] = *I05210; sub I05210 { $hlt = 1; goto &fetch; }
$core[005211] = 07431; $code[005211] = *I05211; sub I05211 { &emul8; goto &fetch; }
$core[005212] = 07300; $code[005212] = *I05212; sub I05212 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005213] = 04554; $code[005213] = *I05213; sub I05213 { $core[($ib<<12)+$core[108]] = 05214; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[005214] = 06004; $code[005214] = *I05214; sub I05214 { &emul8; goto &fetch; }
$core[005215] = 00377; $code[005215] = *I05215; sub I05215 { $lac &= (010000|$core[005377]); goto &fetch; }
$core[005216] = 07006; $code[005216] = *I05216; sub I05216 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[005217] = 07430; $code[005217] = *I05217; sub I05217 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005220] = 07402; $code[005220] = *I05220; sub I05220 { $hlt = 1; goto &fetch; }
$core[005221] = 07431; $code[005221] = *I05221; sub I05221 { &emul8; goto &fetch; }
$core[005222] = 07332; $code[005222] = *I05222; sub I05222 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[005223] = 04554; $code[005223] = *I05223; sub I05223 { $core[($ib<<12)+$core[108]] = 05224; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[005224] = 06004; $code[005224] = *I05224; sub I05224 { &emul8; goto &fetch; }
$core[005225] = 00377; $code[005225] = *I05225; sub I05225 { $lac &= (010000|$core[005377]); goto &fetch; }
$core[005226] = 07006; $code[005226] = *I05226; sub I05226 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[005227] = 07420; $code[005227] = *D05227; sub D05227 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[005230] = 07402; $code[005230] = *I05230; sub I05230 { $hlt = 1; goto &fetch; }
$core[005231] = 07431; $code[005231] = *I05231; sub I05231 { &emul8; goto &fetch; }
$core[005232] = 07300; $code[005232] = *D05232; sub D05232 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005233] = 04554; $code[005233] = *I05233; sub I05233 { $core[($ib<<12)+$core[108]] = 05234; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[005234] = 06006; $code[005234] = *I05234; sub I05234 { &emul8; goto &fetch; }
$core[005235] = 07410; $code[005235] = *I05235; sub I05235 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005236] = 07402; $code[005236] = *I05236; sub I05236 { $hlt = 1; goto &fetch; }
$core[005237] = 07431; $code[005237] = *I05237; sub I05237 { &emul8; goto &fetch; }
$core[005240] = 07332; $code[005240] = *I05240; sub I05240 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[005241] = 04554; $code[005241] = *I05241; sub I05241 { $core[($ib<<12)+$core[108]] = 05242; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[005242] = 06006; $code[005242] = *I05242; sub I05242 { &emul8; goto &fetch; }
$core[005243] = 07402; $code[005243] = *I05243; sub I05243 { $hlt = 1; goto &fetch; }
$core[005244] = 07431; $code[005244] = *I05244; sub I05244 { &emul8; goto &fetch; }
$core[005245] = 07332; $code[005245] = *I05245; sub I05245 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[005246] = 04554; $code[005246] = *I05246; sub I05246 { $core[($ib<<12)+$core[108]] = 05247; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[005247] = 07447; $code[005247] = *I05247; sub I05247 { &emul8; goto &fetch; }
$core[005250] = 06006; $code[005250] = *I05250; sub I05250 { &emul8; goto &fetch; }
$core[005251] = 07610; $code[005251] = *I05251; sub I05251 { $skp = 0; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005252] = 07402; $code[005252] = *I05252; sub I05252 { $hlt = 1; goto &fetch; }
$core[005253] = 04546; $code[005253] = *I05253; sub I05253 { $core[($ib<<12)+$core[102]] = 05254; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[005254] = 05776; $code[005254] = *I05254; sub I05254 { $pc = ($ib<<12)+$core[2814]; $inh = 0; goto &fetch; }
$core[005255] = 02117; $code[005255] = *I05255; sub I05255 { if (++$core[000117] == 010000) { $core[000117] = 0; $pc++; }$code[000117] = *emul8; goto &fetch; }
$core[005256] = 05776; $code[005256] = *I05256; sub I05256 { $pc = ($ib<<12)+$core[2814]; $inh = 0; goto &fetch; }
$core[005257] = 06007; $code[005257] = *I05257; sub I05257 { &emul8; goto &fetch; }
$core[005260] = 05775; $code[005260] = *I05260; sub I05260 { $pc = ($ib<<12)+$core[2813]; $inh = 0; goto &fetch; }
$core[005261] = 04524; $code[005261] = *L05261; sub L05261 { $core[($ib<<12)+$core[84]] = 05262; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[005262] = 01115; $code[005262] = *I05262; sub I05262 { $lac += $core[000115]; goto &fetch; }
$core[005263] = 07650; $code[005263] = *I05263; sub I05263 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005264] = 05267; $code[005264] = *I05264; sub I05264 { $pc = 005267; $inh = 0; goto &fetch; }
$core[005265] = 04450; $code[005265] = *I05265; sub I05265 { $core[($ib<<12)+$core[40]] = 05266; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[005266] = 07532; $code[005266] = *I05266; sub I05266 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $hlt = 1; goto &fetch; }
$core[005267] = 01115; $code[005267] = *L05267; sub L05267 { $lac += $core[000115]; goto &fetch; }
$core[005270] = 07140; $code[005270] = *I05270; sub I05270 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[005271] = 03115; $code[005271] = *I05271; sub I05271 { $core[000115] = $lac & 07777; $lac &= 010000; $code[000115] = *emul8; goto &fetch; }
$core[005272] = 06007; $code[005272] = *I05272; sub I05272 { &emul8; goto &fetch; }
$core[005273] = 05774; $code[005273] = *I05273; sub I05273 { $pc = ($ib<<12)+$core[2812]; $inh = 0; goto &fetch; }
$core[005274] = 00000; $code[005274] = *S05274; sub S05274 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005275] = 07604; $code[005275] = *I05275; sub I05275 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005276] = 07112; $code[005276] = *I05276; sub I05276 { $lac &= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[005277] = 07430; $code[005277] = *I05277; sub I05277 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005300] = 05311; $code[005300] = *I05300; sub I05300 { $pc = 005311; $inh = 0; goto &fetch; }
$core[005301] = 07200; $code[005301] = *L05301; sub L05301 { $lac &= 010000; goto &fetch; }
$core[005302] = 01115; $code[005302] = *D05302; sub D05302 { $lac += $core[000115]; goto &fetch; }
$core[005303] = 07640; $code[005303] = *I05303; sub I05303 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005304] = 05307; $code[005304] = *I05304; sub I05304 { $pc = 005307; $inh = 0; goto &fetch; }
$core[005305] = 07447; $code[005305] = *I05305; sub I05305 { &emul8; goto &fetch; }
$core[005306] = 05674; $code[005306] = *I05306; sub I05306 { $pc = ($ib<<12)+$core[2748]; $inh = 0; goto &fetch; }
$core[005307] = 07431; $code[005307] = *L05307; sub L05307 { &emul8; goto &fetch; }
$core[005310] = 05674; $code[005310] = *I05310; sub I05310 { $pc = ($ib<<12)+$core[2748]; $inh = 0; goto &fetch; }
$core[005311] = 07710; $code[005311] = *L05311; sub L05311 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005312] = 05315; $code[005312] = *I05312; sub I05312 { $pc = 005315; $inh = 0; goto &fetch; }
$core[005313] = 03115; $code[005313] = *L05313; sub L05313 { $core[000115] = $lac & 07777; $lac &= 010000; $code[000115] = *emul8; goto &fetch; }
$core[005314] = 05301; $code[005314] = *I05314; sub I05314 { $pc = 005301; $inh = 0; goto &fetch; }
$core[005315] = 07140; $code[005315] = *L05315; sub L05315 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[005316] = 05313; $code[005316] = *I05316; sub I05316 { $pc = 005313; $inh = 0; goto &fetch; }
$core[005317] = 00000; $code[005317] = *S05317; sub S05317 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005320] = 07200; $code[005320] = *I05320; sub I05320 { $lac &= 010000; goto &fetch; }
$core[005321] = 01115; $code[005321] = *I05321; sub I05321 { $lac += $core[000115]; goto &fetch; }
$core[005322] = 07700; $code[005322] = *I05322; sub I05322 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005323] = 05575; $code[005323] = *I05323; sub I05323 { $pc = ($ib<<12)+$core[125]; $inh = 0; goto &fetch; }
$core[005324] = 05717; $code[005324] = *I05324; sub I05324 { $pc = ($ib<<12)+$core[2767]; $inh = 0; goto &fetch; }
$core[005325] = 00000; $code[005325] = *S05325; sub S05325 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005326] = 07604; $code[005326] = *I05326; sub I05326 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005327] = 07710; $code[005327] = *I05327; sub I05327 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005330] = 05725; $code[005330] = *I05330; sub I05330 { $pc = ($ib<<12)+$core[2773]; $inh = 0; goto &fetch; }
$core[005331] = 02325; $code[005331] = *I05331; sub I05331 { if (++$core[005325] == 010000) { $core[005325] = 0; $pc++; }$code[005325] = *emul8; goto &fetch; }
$core[005332] = 05725; $code[005332] = *I05332; sub I05332 { $pc = ($ib<<12)+$core[2773]; $inh = 0; goto &fetch; }
$core[005333] = 00000; $code[005333] = *S05333; sub S05333 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005334] = 07604; $code[005334] = *I05334; sub I05334 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005335] = 07004; $code[005335] = *I05335; sub I05335 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005336] = 07710; $code[005336] = *I05336; sub I05336 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005337] = 05733; $code[005337] = *I05337; sub I05337 { $pc = ($ib<<12)+$core[2779]; $inh = 0; goto &fetch; }
$core[005340] = 02333; $code[005340] = *I05340; sub I05340 { if (++$core[005333] == 010000) { $core[005333] = 0; $pc++; }$code[005333] = *emul8; goto &fetch; }
$core[005341] = 05733; $code[005341] = *I05341; sub I05341 { $pc = ($ib<<12)+$core[2779]; $inh = 0; goto &fetch; }
$core[005342] = 00000; $code[005342] = *S05342; sub S05342 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005343] = 07604; $code[005343] = *I05343; sub I05343 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005344] = 07106; $code[005344] = *I05344; sub I05344 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[005345] = 07710; $code[005345] = *I05345; sub I05345 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005346] = 05742; $code[005346] = *I05346; sub I05346 { $pc = ($ib<<12)+$core[2786]; $inh = 0; goto &fetch; }
$core[005347] = 02342; $code[005347] = *I05347; sub I05347 { if (++$core[005342] == 010000) { $core[005342] = 0; $pc++; }$code[005342] = *emul8; goto &fetch; }
$core[005350] = 05742; $code[005350] = *I05350; sub I05350 { $pc = ($ib<<12)+$core[2786]; $inh = 0; goto &fetch; }
$core[005374] = 00202; $code[005374] = *P05374; sub P05374 { $lac &= (010000|$core[005202]); goto &fetch; }
$core[005375] = 00204; $code[005375] = *P05375; sub P05375 { $lac &= (010000|$core[005204]); goto &fetch; }
$core[005376] = 05001; $code[005376] = *P05376; sub P05376 { $pc = 000001; $inh = 0; goto &fetch; }
$core[005377] = 02000; $code[005377] = *D05377; sub D05377 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[005400] = 00000; $code[005400] = *S05400; sub S05400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005401] = 07604; $code[005401] = *I05401; sub I05401 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005402] = 07106; $code[005402] = *I05402; sub I05402 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[005403] = 07104; $code[005403] = *I05403; sub I05403 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005404] = 07710; $code[005404] = *I05404; sub I05404 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005405] = 05600; $code[005405] = *I05405; sub I05405 { $pc = ($ib<<12)+$core[2816]; $inh = 0; goto &fetch; }
$core[005406] = 02200; $code[005406] = *I05406; sub I05406 { if (++$core[005400] == 010000) { $core[005400] = 0; $pc++; }$code[005400] = *emul8; goto &fetch; }
$core[005407] = 05600; $code[005407] = *I05407; sub I05407 { $pc = ($ib<<12)+$core[2816]; $inh = 0; goto &fetch; }
$core[005410] = 00000; $code[005410] = *S05410; sub S05410 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005411] = 03034; $code[005411] = *I05411; sub I05411 { $core[000034] = $lac & 07777; $lac &= 010000; $code[000034] = *emul8; goto &fetch; }
$core[005412] = 07701; $code[005412] = *I05412; sub I05412 { &emul8; goto &fetch; }
$core[005413] = 03035; $code[005413] = *I05413; sub I05413 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[005414] = 07210; $code[005414] = *I05414; sub I05414 { $lac &= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005415] = 03033; $code[005415] = *I05415; sub I05415 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[005416] = 07641; $code[005416] = *I05416; sub I05416 { &emul8; goto &fetch; }
$core[005417] = 03036; $code[005417] = *I05417; sub I05417 { $core[000036] = $lac & 07777; $lac &= 010000; $code[000036] = *emul8; goto &fetch; }
$core[005420] = 06004; $code[005420] = *I05420; sub I05420 { &emul8; goto &fetch; }
$core[005421] = 00377; $code[005421] = *I05421; sub I05421 { $lac &= (010000|$core[005577]); goto &fetch; }
$core[005422] = 07104; $code[005422] = *I05422; sub I05422 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005423] = 03037; $code[005423] = *I05423; sub I05423 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[005424] = 05610; $code[005424] = *I05424; sub I05424 { $pc = ($ib<<12)+$core[2824]; $inh = 0; goto &fetch; }
$core[005425] = 00000; $code[005425] = *S05425; sub S05425 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005426] = 04776; $code[005426] = *I05426; sub I05426 { $core[($ib<<12)+$core[2942]] = 05427; $pc = ($ib<<12)+$core[2942]+1; $code[($ib<<12)+$core[2942]] = *emul8; $inh = 0; goto &fetch; }
$core[005427] = 05625; $code[005427] = *I05427; sub I05427 { $pc = ($ib<<12)+$core[2837]; $inh = 0; goto &fetch; }
$core[005430] = 00000; $code[005430] = *S05430; sub S05430 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005431] = 04237; $code[005431] = *I05431; sub I05431 { $core[005437] = 05432; $pc = 005437+1; $code[005437] = *emul8; $inh = 0; goto &fetch; }
$core[005432] = 04250; $code[005432] = *I05432; sub I05432 { $core[005450] = 05433; $pc = 005450+1; $code[005450] = *emul8; $inh = 0; goto &fetch; }
$core[005433] = 05630; $code[005433] = *I05433; sub I05433 { $pc = ($ib<<12)+$core[2840]; $inh = 0; goto &fetch; }
$core[005434] = 00000; $code[005434] = *S05434; sub S05434 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005435] = 04237; $code[005435] = *I05435; sub I05435 { $core[005437] = 05436; $pc = 005437+1; $code[005437] = *emul8; $inh = 0; goto &fetch; }
$core[005436] = 05634; $code[005436] = *I05436; sub I05436 { $pc = ($ib<<12)+$core[2844]; $inh = 0; goto &fetch; }
$core[005437] = 00000; $code[005437] = *S05437; sub S05437 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005440] = 07240; $code[005440] = *I05440; sub I05440 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005441] = 00300; $code[005441] = *I05441; sub I05441 { $lac &= (010000|$core[005500]); goto &fetch; }
$core[005442] = 04526; $code[005442] = *I05442; sub I05442 { $core[($ib<<12)+$core[86]] = 05443; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005443] = 01301; $code[005443] = *I05443; sub I05443 { $lac += $core[005501]; goto &fetch; }
$core[005444] = 04526; $code[005444] = *I05444; sub I05444 { $core[($ib<<12)+$core[86]] = 05445; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005445] = 01302; $code[005445] = *I05445; sub I05445 { $lac += $core[005502]; goto &fetch; }
$core[005446] = 04526; $code[005446] = *I05446; sub I05446 { $core[($ib<<12)+$core[86]] = 05447; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005447] = 05637; $code[005447] = *I05447; sub I05447 { $pc = ($ib<<12)+$core[2847]; $inh = 0; goto &fetch; }
$core[005450] = 00000; $code[005450] = *S05450; sub S05450 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005451] = 07240; $code[005451] = *D05451; sub D05451 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005452] = 00277; $code[005452] = *I05452; sub I05452 { $lac &= (010000|$core[005477]); goto &fetch; }
$core[005453] = 04526; $code[005453] = *I05453; sub I05453 { $core[($ib<<12)+$core[86]] = 05454; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005454] = 05650; $code[005454] = *I05454; sub I05454 { $pc = ($ib<<12)+$core[2856]; $inh = 0; goto &fetch; }
$core[005455] = 00000; $code[005455] = *S05455; sub S05455 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005456] = 07200; $code[005456] = *I05456; sub I05456 { $lac &= 010000; goto &fetch; }
$core[005457] = 01077; $code[005457] = *I05457; sub I05457 { $lac += $core[000077]; goto &fetch; }
$core[005460] = 04526; $code[005460] = *I05460; sub I05460 { $core[($ib<<12)+$core[86]] = 05461; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005461] = 05655; $code[005461] = *I05461; sub I05461 { $pc = ($ib<<12)+$core[2861]; $inh = 0; goto &fetch; }
$core[005462] = 00000; $code[005462] = *S05462; sub S05462 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005463] = 07200; $code[005463] = *I05463; sub I05463 { $lac &= 010000; goto &fetch; }
$core[005464] = 01375; $code[005464] = *I05464; sub I05464 { $lac += $core[005575]; goto &fetch; }
$core[005465] = 04526; $code[005465] = *I05465; sub I05465 { $core[($ib<<12)+$core[86]] = 05466; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005466] = 05662; $code[005466] = *I05466; sub I05466 { $pc = ($ib<<12)+$core[2866]; $inh = 0; goto &fetch; }
$core[005467] = 00000; $code[005467] = *S05467; sub S05467 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005470] = 07200; $code[005470] = *I05470; sub I05470 { $lac &= 010000; goto &fetch; }
$core[005471] = 01374; $code[005471] = *I05471; sub I05471 { $lac += $core[005574]; goto &fetch; }
$core[005472] = 04526; $code[005472] = *I05472; sub I05472 { $core[($ib<<12)+$core[86]] = 05473; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005473] = 05667; $code[005473] = *I05473; sub I05473 { $pc = ($ib<<12)+$core[2871]; $inh = 0; goto &fetch; }
$core[005474] = 00316; $code[005474] = *D05474; sub D05474 { $lac &= (010000|$core[005516]); goto &fetch; }
$core[005475] = 00315; $code[005475] = *D05475; sub D05475 { $lac &= (010000|$core[005515]); goto &fetch; }
$core[005476] = 00311; $code[005476] = *D05476; sub D05476 { $lac &= (010000|$core[005511]); goto &fetch; }
$core[005477] = 00324; $code[005477] = *D05477; sub D05477 { $lac &= (010000|$core[005524]); goto &fetch; }
$core[005500] = 00323; $code[005500] = *D05500; sub D05500 { $lac &= (010000|$core[005523]); goto &fetch; }
$core[005501] = 00303; $code[005501] = *D05501; sub D05501 { $lac &= (010000|$core[005503]); goto &fetch; }
$core[005502] = 00301; $code[005502] = *D05502; sub D05502 { $lac &= (010000|$core[005501]); goto &fetch; }
$core[005503] = 00000; $code[005503] = *S05503; sub S05503 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005504] = 01115; $code[005504] = *I05504; sub I05504 { $lac += $core[000115]; goto &fetch; }
$core[005505] = 07640; $code[005505] = *I05505; sub I05505 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005506] = 05315; $code[005506] = *I05506; sub I05506 { $pc = 005515; $inh = 0; goto &fetch; }
$core[005507] = 01024; $code[005507] = *I05507; sub I05507 { $lac += $core[000024]; goto &fetch; }
$core[005510] = 07040; $code[005510] = *I05510; sub I05510 { $lac ^= 07777; goto &fetch; }
$core[005511] = 03313; $code[005511] = *D05511; sub D05511 { $core[005513] = $lac & 07777; $lac &= 010000; $code[005513] = *emul8; goto &fetch; }
$core[005512] = 07403; $code[005512] = *I05512; sub I05512 { &emul8; goto &fetch; }
$core[005513] = 00000; $code[005513] = *D05513; sub D05513 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005514] = 05703; $code[005514] = *I05514; sub I05514 { $pc = ($ib<<12)+$core[2883]; $inh = 0; goto &fetch; }
$core[005515] = 01024; $code[005515] = *L05515; sub L05515 { $lac += $core[000024]; goto &fetch; }
$core[005516] = 07403; $code[005516] = *D05516; sub D05516 { &emul8; goto &fetch; }
$core[005517] = 05703; $code[005517] = *I05517; sub I05517 { $pc = ($ib<<12)+$core[2883]; $inh = 0; goto &fetch; }
$core[005520] = 00000; $code[005520] = *S05520; sub S05520 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005521] = 07344; $code[005521] = *I05521; sub I05521 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005522] = 03120; $code[005522] = *I05522; sub I05522 { $core[000120] = $lac & 07777; $lac &= 010000; $code[000120] = *emul8; goto &fetch; }
$core[005523] = 04554; $code[005523] = *D05523; sub D05523 { $core[($ib<<12)+$core[108]] = 05524; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[005524] = 01170; $code[005524] = *D05524; sub D05524 { $lac += $core[000170]; goto &fetch; }
$core[005525] = 03773; $code[005525] = *I05525; sub I05525 { $core[($df<<12)+$core[2939]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2939]] = *emul8; goto &fetch; }
$core[005526] = 01167; $code[005526] = *I05526; sub I05526 { $lac += $core[000167]; goto &fetch; }
$core[005527] = 03772; $code[005527] = *I05527; sub I05527 { $core[($df<<12)+$core[2938]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2938]] = *emul8; goto &fetch; }
$core[005530] = 03114; $code[005530] = *I05530; sub I05530 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[005531] = 03021; $code[005531] = *I05531; sub I05531 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[005532] = 03771; $code[005532] = *I05532; sub I05532 { $core[($df<<12)+$core[2937]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2937]] = *emul8; goto &fetch; }
$core[005533] = 03770; $code[005533] = *I05533; sub I05533 { $core[($df<<12)+$core[2936]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2936]] = *emul8; goto &fetch; }
$core[005534] = 04453; $code[005534] = *I05534; sub I05534 { $core[($ib<<12)+$core[43]] = 05535; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[005535] = 00021; $code[005535] = *I05535; sub I05535 { $lac &= (010000|$core[000021]); goto &fetch; }
$core[005536] = 00022; $code[005536] = *I05536; sub I05536 { $lac &= (010000|$core[000022]); goto &fetch; }
$core[005537] = 07753; $code[005537] = *I05537; sub I05537 { &emul8; goto &fetch; }
$core[005540] = 05720; $code[005540] = *I05540; sub I05540 { $pc = ($ib<<12)+$core[2896]; $inh = 0; goto &fetch; }
$core[005541] = 00000; $code[005541] = *S05541; sub S05541 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005542] = 04525; $code[005542] = *I05542; sub I05542 { $core[($ib<<12)+$core[85]] = 05543; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[005543] = 04450; $code[005543] = *I05543; sub I05543 { $core[($ib<<12)+$core[40]] = 05544; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[005544] = 00000; $code[005544] = *D05544; sub D05544 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005545] = 05741; $code[005545] = *I05545; sub I05545 { $pc = ($ib<<12)+$core[2913]; $inh = 0; goto &fetch; }
$core[005546] = 00000; $code[005546] = *S05546; sub S05546 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005547] = 02065; $code[005547] = *I05547; sub I05547 { if (++$core[000065] == 010000) { $core[000065] = 0; $pc++; }$code[000065] = *emul8; goto &fetch; }
$core[005550] = 05746; $code[005550] = *I05550; sub I05550 { $pc = ($ib<<12)+$core[2918]; $inh = 0; goto &fetch; }
$core[005551] = 07604; $code[005551] = *L05551; sub L05551 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005552] = 07106; $code[005552] = *I05552; sub I05552 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[005553] = 07006; $code[005553] = *I05553; sub I05553 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[005554] = 07630; $code[005554] = *I05554; sub I05554 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005555] = 05456; $code[005555] = *I05555; sub I05555 { $pc = ($ib<<12)+$core[46]; $inh = 0; goto &fetch; }
$core[005556] = 05457; $code[005556] = *I05556; sub I05556 { $pc = ($ib<<12)+$core[47]; $inh = 0; goto &fetch; }
$core[005570] = 07002; $code[005570] = *P05570; sub P05570 { $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[005571] = 07016; $code[005571] = *P05571; sub P05571 { $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[005572] = 06371; $code[005572] = *P05572; sub P05572 { &emul8; goto &fetch; }
$core[005573] = 06370; $code[005573] = *P05573; sub P05573 { &emul8; goto &fetch; }
$core[005574] = 00251; $code[005574] = *D05574; sub D05574 { $lac &= (010000|$core[005451]); goto &fetch; }
$core[005575] = 00250; $code[005575] = *D05575; sub D05575 { $lac &= (010000|$core[005450]); goto &fetch; }
$core[005576] = 04132; $code[005576] = *P05576; sub P05576 { $core[000132] = 05577; $pc = 000132+1; $code[000132] = *emul8; $inh = 0; goto &fetch; }
$core[005577] = 02000; $code[005577] = *D05577; sub D05577 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[005600] = 00000; $code[005600] = *S05600; sub S05600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005601] = 07240; $code[005601] = *I05601; sub I05601 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005602] = 00070; $code[005602] = *I05602; sub I05602 { $lac &= (010000|$core[000070]); goto &fetch; }
$core[005603] = 04526; $code[005603] = *I05603; sub I05603 { $core[($ib<<12)+$core[86]] = 05604; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005604] = 01071; $code[005604] = *I05604; sub I05604 { $lac += $core[000071]; goto &fetch; }
$core[005605] = 04526; $code[005605] = *I05605; sub I05605 { $core[($ib<<12)+$core[86]] = 05606; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005606] = 05600; $code[005606] = *I05606; sub I05606 { $pc = ($ib<<12)+$core[2944]; $inh = 0; goto &fetch; }
$core[005607] = 00000; $code[005607] = *S05607; sub S05607 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005610] = 04524; $code[005610] = *I05610; sub I05610 { $core[($ib<<12)+$core[84]] = 05611; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[005611] = 04524; $code[005611] = *I05611; sub I05611 { $core[($ib<<12)+$core[84]] = 05612; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[005612] = 05607; $code[005612] = *I05612; sub I05612 { $pc = ($ib<<12)+$core[2951]; $inh = 0; goto &fetch; }
$core[005613] = 00000; $code[005613] = *S05613; sub S05613 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005614] = 03236; $code[005614] = *I05614; sub I05614 { $core[005636] = $lac & 07777; $lac &= 010000; $code[005636] = *emul8; goto &fetch; }
$core[005615] = 01020; $code[005615] = *I05615; sub I05615 { $lac += $core[000020]; goto &fetch; }
$core[005616] = 07040; $code[005616] = *I05616; sub I05616 { $lac ^= 07777; goto &fetch; }
$core[005617] = 03237; $code[005617] = *I05617; sub I05617 { $core[005637] = $lac & 07777; $lac &= 010000; $code[005637] = *emul8; goto &fetch; }
$core[005620] = 01236; $code[005620] = *I05620; sub I05620 { $lac += $core[005636]; goto &fetch; }
$core[005621] = 06046; $code[005621] = *I05621; sub I05621 { &emul8; goto &fetch; }
$core[005622] = 06041; $code[005622] = *L05622; sub L05622 { &emul8; goto &fetch; }
$core[005623] = 05222; $code[005623] = *I05623; sub I05623 { $pc = 005622; $inh = 0; goto &fetch; }
$core[005624] = 01166; $code[005624] = *I05624; sub I05624 { $lac += $core[000166]; goto &fetch; }
$core[005625] = 07640; $code[005625] = *I05625; sub I05625 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005626] = 05613; $code[005626] = *I05626; sub I05626 { $pc = ($ib<<12)+$core[2955]; $inh = 0; goto &fetch; }
$core[005627] = 02237; $code[005627] = *L05627; sub L05627 { if (++$core[005637] == 010000) { $core[005637] = 0; $pc++; }$code[005637] = *emul8; goto &fetch; }
$core[005630] = 07610; $code[005630] = *I05630; sub I05630 { $skp = 0; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005631] = 05613; $code[005631] = *I05631; sub I05631 { $pc = ($ib<<12)+$core[2955]; $inh = 0; goto &fetch; }
$core[005632] = 06046; $code[005632] = *I05632; sub I05632 { &emul8; goto &fetch; }
$core[005633] = 06041; $code[005633] = *L05633; sub L05633 { &emul8; goto &fetch; }
$core[005634] = 05233; $code[005634] = *I05634; sub I05634 { $pc = 005633; $inh = 0; goto &fetch; }
$core[005635] = 05227; $code[005635] = *I05635; sub I05635 { $pc = 005627; $inh = 0; goto &fetch; }
$core[005636] = 00000; $code[005636] = *D05636; sub D05636 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005637] = 00000; $code[005637] = *D05637; sub D05637 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005640] = 00000; $code[005640] = *S05640; sub S05640 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005641] = 07240; $code[005641] = *I05641; sub I05641 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005642] = 00102; $code[005642] = *I05642; sub I05642 { $lac &= (010000|$core[000102]); goto &fetch; }
$core[005643] = 04245; $code[005643] = *I05643; sub I05643 { $core[005645] = 05644; $pc = 005645+1; $code[005645] = *emul8; $inh = 0; goto &fetch; }
$core[005644] = 05640; $code[005644] = *I05644; sub I05644 { $pc = ($ib<<12)+$core[2976]; $inh = 0; goto &fetch; }
$core[005645] = 00000; $code[005645] = *S05645; sub S05645 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005646] = 07440; $code[005646] = *I05646; sub I05646 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005647] = 05252; $code[005647] = *I05647; sub I05647 { $pc = 005652; $inh = 0; goto &fetch; }
$core[005650] = 04256; $code[005650] = *I05650; sub I05650 { $core[005656] = 05651; $pc = 005656+1; $code[005656] = *emul8; $inh = 0; goto &fetch; }
$core[005651] = 05645; $code[005651] = *I05651; sub I05651 { $pc = ($ib<<12)+$core[2981]; $inh = 0; goto &fetch; }
$core[005652] = 07240; $code[005652] = *L05652; sub L05652 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005653] = 00100; $code[005653] = *D05653; sub D05653 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[005654] = 04526; $code[005654] = *I05654; sub I05654 { $core[($ib<<12)+$core[86]] = 05655; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005655] = 05645; $code[005655] = *I05655; sub I05655 { $pc = ($ib<<12)+$core[2981]; $inh = 0; goto &fetch; }
$core[005656] = 00000; $code[005656] = *S05656; sub S05656 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005657] = 07240; $code[005657] = *I05657; sub I05657 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005660] = 00101; $code[005660] = *I05660; sub I05660 { $lac &= (010000|$core[000101]); goto &fetch; }
$core[005661] = 04526; $code[005661] = *I05661; sub I05661 { $core[($ib<<12)+$core[86]] = 05662; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005662] = 05656; $code[005662] = *I05662; sub I05662 { $pc = ($ib<<12)+$core[2990]; $inh = 0; goto &fetch; }
$core[005663] = 00000; $code[005663] = *S05663; sub S05663 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005664] = 07240; $code[005664] = *I05664; sub I05664 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005665] = 00104; $code[005665] = *I05665; sub I05665 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[005666] = 03105; $code[005666] = *I05666; sub I05666 { $core[000105] = $lac & 07777; $lac &= 010000; $code[000105] = *emul8; goto &fetch; }
$core[005667] = 02105; $code[005667] = *L05667; sub L05667 { if (++$core[000105] == 010000) { $core[000105] = 0; $pc++; }$code[000105] = *emul8; goto &fetch; }
$core[005670] = 07410; $code[005670] = *I05670; sub I05670 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005671] = 05663; $code[005671] = *I05671; sub I05671 { $pc = ($ib<<12)+$core[2995]; $inh = 0; goto &fetch; }
$core[005672] = 07240; $code[005672] = *I05672; sub I05672 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005673] = 00106; $code[005673] = *D05673; sub D05673 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[005674] = 07100; $code[005674] = *I05674; sub I05674 { $lac &= 07777; goto &fetch; }
$core[005675] = 07004; $code[005675] = *I05675; sub I05675 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005676] = 03106; $code[005676] = *I05676; sub I05676 { $core[000106] = $lac & 07777; $lac &= 010000; $code[000106] = *emul8; goto &fetch; }
$core[005677] = 07430; $code[005677] = *I05677; sub I05677 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005700] = 05303; $code[005700] = *I05700; sub I05700 { $pc = 005703; $inh = 0; goto &fetch; }
$core[005701] = 04256; $code[005701] = *I05701; sub I05701 { $core[005656] = 05702; $pc = 005656+1; $code[005656] = *emul8; $inh = 0; goto &fetch; }
$core[005702] = 05267; $code[005702] = *I05702; sub I05702 { $pc = 005667; $inh = 0; goto &fetch; }
$core[005703] = 07240; $code[005703] = *L05703; sub L05703 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005704] = 00100; $code[005704] = *I05704; sub I05704 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[005705] = 04526; $code[005705] = *I05705; sub I05705 { $core[($ib<<12)+$core[86]] = 05706; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005706] = 05267; $code[005706] = *I05706; sub I05706 { $pc = 005667; $inh = 0; goto &fetch; }
$core[005707] = 00000; $code[005707] = *S05707; sub S05707 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005710] = 04525; $code[005710] = *I05710; sub I05710 { $core[($ib<<12)+$core[85]] = 05711; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[005711] = 01707; $code[005711] = *I05711; sub I05711 { $lac += $core[($df<<12)+$core[3015]]; goto &fetch; }
$core[005712] = 03116; $code[005712] = *I05712; sub I05712 { $core[000116] = $lac & 07777; $lac &= 010000; $code[000116] = *emul8; goto &fetch; }
$core[005713] = 02307; $code[005713] = *L05713; sub L05713 { if (++$core[005707] == 010000) { $core[005707] = 0; $pc++; }$code[005707] = *emul8; goto &fetch; }
$core[005714] = 01707; $code[005714] = *I05714; sub I05714 { $lac += $core[($df<<12)+$core[3015]]; goto &fetch; }
$core[005715] = 03317; $code[005715] = *I05715; sub I05715 { $core[005717] = $lac & 07777; $lac &= 010000; $code[005717] = *emul8; goto &fetch; }
$core[005716] = 04450; $code[005716] = *I05716; sub I05716 { $core[($ib<<12)+$core[40]] = 05717; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[005717] = 00000; $code[005717] = *D05717; sub D05717 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005720] = 04455; $code[005720] = *I05720; sub I05720 { $core[($ib<<12)+$core[45]] = 05721; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[005721] = 02116; $code[005721] = *I05721; sub I05721 { if (++$core[000116] == 010000) { $core[000116] = 0; $pc++; }$code[000116] = *emul8; goto &fetch; }
$core[005722] = 05313; $code[005722] = *I05722; sub I05722 { $pc = 005713; $inh = 0; goto &fetch; }
$core[005723] = 04454; $code[005723] = *I05723; sub I05723 { $core[($ib<<12)+$core[44]] = 05724; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[005724] = 02307; $code[005724] = *I05724; sub I05724 { if (++$core[005707] == 010000) { $core[005707] = 0; $pc++; }$code[005707] = *emul8; goto &fetch; }
$core[005725] = 05707; $code[005725] = *I05725; sub I05725 { $pc = ($ib<<12)+$core[3015]; $inh = 0; goto &fetch; }
$core[005726] = 00000; $code[005726] = *S05726; sub S05726 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005727] = 03102; $code[005727] = *I05727; sub I05727 { $core[000102] = $lac & 07777; $lac &= 010000; $code[000102] = *emul8; goto &fetch; }
$core[005730] = 04527; $code[005730] = *I05730; sub I05730 { $core[($ib<<12)+$core[87]] = 05731; $pc = ($ib<<12)+$core[87]+1; $code[($ib<<12)+$core[87]] = *emul8; $inh = 0; goto &fetch; }
$core[005731] = 05726; $code[005731] = *I05731; sub I05731 { $pc = ($ib<<12)+$core[3030]; $inh = 0; goto &fetch; }
$core[005732] = 00000; $code[005732] = *S05732; sub S05732 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005733] = 04550; $code[005733] = *I05733; sub I05733 { $core[($ib<<12)+$core[104]] = 05734; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[005734] = 03022; $code[005734] = *I05734; sub I05734 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[005735] = 07010; $code[005735] = *I05735; sub I05735 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005736] = 03021; $code[005736] = *I05736; sub I05736 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[005737] = 04550; $code[005737] = *I05737; sub I05737 { $core[($ib<<12)+$core[104]] = 05740; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[005740] = 03023; $code[005740] = *I05740; sub I05740 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[005741] = 07010; $code[005741] = *I05741; sub I05741 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005742] = 03025; $code[005742] = *I05742; sub I05742 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[005743] = 04550; $code[005743] = *I05743; sub I05743 { $core[($ib<<12)+$core[104]] = 05744; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[005744] = 00165; $code[005744] = *I05744; sub I05744 { $lac &= (010000|$core[000165]); goto &fetch; }
$core[005745] = 03024; $code[005745] = *I05745; sub I05745 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[005746] = 04573; $code[005746] = *I05746; sub I05746 { $core[($ib<<12)+$core[123]] = 05747; $pc = ($ib<<12)+$core[123]+1; $code[($ib<<12)+$core[123]] = *emul8; $inh = 0; goto &fetch; }
$core[005747] = 05732; $code[005747] = *I05747; sub I05747 { $pc = ($ib<<12)+$core[3034]; $inh = 0; goto &fetch; }
$core[005750] = 05575; $code[005750] = *I05750; sub I05750 { $pc = ($ib<<12)+$core[125]; $inh = 0; goto &fetch; }
$core[005751] = 00000; $code[005751] = *S05751; sub S05751 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005752] = 07300; $code[005752] = *I05752; sub I05752 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005753] = 01023; $code[005753] = *I05753; sub I05753 { $lac += $core[000023]; goto &fetch; }
$core[005754] = 07421; $code[005754] = *I05754; sub I05754 { &emul8; goto &fetch; }
$core[005755] = 04553; $code[005755] = *I05755; sub I05755 { $core[($ib<<12)+$core[107]] = 05756; $pc = ($ib<<12)+$core[107]+1; $code[($ib<<12)+$core[107]] = *emul8; $inh = 0; goto &fetch; }
$core[005756] = 01021; $code[005756] = *I05756; sub I05756 { $lac += $core[000021]; goto &fetch; }
$core[005757] = 07104; $code[005757] = *I05757; sub I05757 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005760] = 05751; $code[005760] = *I05760; sub I05760 { $pc = ($ib<<12)+$core[3049]; $inh = 0; goto &fetch; }
$core[005761] = 00000; $code[005761] = *S05761; sub S05761 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005762] = 07200; $code[005762] = *I05762; sub I05762 { $lac &= 010000; goto &fetch; }
$core[005763] = 01025; $code[005763] = *I05763; sub I05763 { $lac += $core[000025]; goto &fetch; }
$core[005764] = 07110; $code[005764] = *I05764; sub I05764 { $lac &= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005765] = 04554; $code[005765] = *I05765; sub I05765 { $core[($ib<<12)+$core[108]] = 05766; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[005766] = 05761; $code[005766] = *I05766; sub I05766 { $pc = ($ib<<12)+$core[3057]; $inh = 0; goto &fetch; }
$core[005767] = 00000; $code[005767] = *S05767; sub S05767 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005770] = 02114; $code[005770] = *I05770; sub I05770 { if (++$core[000114] == 010000) { $core[000114] = 0; $pc++; }$code[000114] = *emul8; goto &fetch; }
$core[005771] = 05767; $code[005771] = *I05771; sub I05771 { $pc = ($ib<<12)+$core[3063]; $inh = 0; goto &fetch; }
$core[005772] = 02120; $code[005772] = *I05772; sub I05772 { if (++$core[000120] == 010000) { $core[000120] = 0; $pc++; }$code[000120] = *emul8; goto &fetch; }
$core[005773] = 05767; $code[005773] = *I05773; sub I05773 { $pc = ($ib<<12)+$core[3063]; $inh = 0; goto &fetch; }
$core[005774] = 02367; $code[005774] = *I05774; sub I05774 { if (++$core[005767] == 010000) { $core[005767] = 0; $pc++; }$code[005767] = *emul8; goto &fetch; }
$core[005775] = 05767; $code[005775] = *I05775; sub I05775 { $pc = ($ib<<12)+$core[3063]; $inh = 0; goto &fetch; }
$core[006000] = 00000; $code[006000] = *S06000; sub S06000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006001] = 03116; $code[006001] = *I06001; sub I06001 { $core[000116] = $lac & 07777; $lac &= 010000; $code[000116] = *emul8; goto &fetch; }
$core[006002] = 06214; $code[006002] = *I06002; sub I06002 { &emul8; goto &fetch; }
$core[006003] = 07112; $code[006003] = *I06003; sub I06003 { $lac &= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006004] = 07010; $code[006004] = *I06004; sub I06004 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006005] = 06224; $code[006005] = *I06005; sub I06005 { &emul8; goto &fetch; }
$core[006006] = 01116; $code[006006] = *I06006; sub I06006 { $lac += $core[000116]; goto &fetch; }
$core[006007] = 06005; $code[006007] = *I06007; sub I06007 { &emul8; goto &fetch; }
$core[006010] = 06002; $code[006010] = *I06010; sub I06010 { &emul8; goto &fetch; }
$core[006011] = 07300; $code[006011] = *I06011; sub I06011 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006012] = 05600; $code[006012] = *I06012; sub I06012 { $pc = ($ib<<12)+$core[3072]; $inh = 0; goto &fetch; }
$core[006013] = 00000; $code[006013] = *S06013; sub S06013 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006014] = 01022; $code[006014] = *I06014; sub I06014 { $lac += $core[000022]; goto &fetch; }
$core[006015] = 07500; $code[006015] = *I06015; sub I06015 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006016] = 07120; $code[006016] = *I06016; sub I06016 { $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[006017] = 07041; $code[006017] = *I06017; sub I06017 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006020] = 03040; $code[006020] = *I06020; sub I06020 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[006021] = 01023; $code[006021] = *I06021; sub I06021 { $lac += $core[000023]; goto &fetch; }
$core[006022] = 07510; $code[006022] = *I06022; sub I06022 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006023] = 07020; $code[006023] = *I06023; sub I06023 { $lac ^= 010000; goto &fetch; }
$core[006024] = 01040; $code[006024] = *I06024; sub I06024 { $lac += $core[000040]; goto &fetch; }
$core[006025] = 07230; $code[006025] = *I06025; sub I06025 { $lac &= 010000; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006026] = 03046; $code[006026] = *I06026; sub I06026 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006027] = 01022; $code[006027] = *I06027; sub I06027 { $lac += $core[000022]; goto &fetch; }
$core[006030] = 07041; $code[006030] = *I06030; sub I06030 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006031] = 01023; $code[006031] = *I06031; sub I06031 { $lac += $core[000023]; goto &fetch; }
$core[006032] = 03043; $code[006032] = *I06032; sub I06032 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006033] = 07010; $code[006033] = *I06033; sub I06033 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006034] = 03042; $code[006034] = *I06034; sub I06034 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006035] = 01023; $code[006035] = *I06035; sub I06035 { $lac += $core[000023]; goto &fetch; }
$core[006036] = 03044; $code[006036] = *I06036; sub I06036 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006037] = 01024; $code[006037] = *I06037; sub I06037 { $lac += $core[000024]; goto &fetch; }
$core[006040] = 03045; $code[006040] = *I06040; sub I06040 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006041] = 05613; $code[006041] = *I06041; sub I06041 { $pc = ($ib<<12)+$core[3083]; $inh = 0; goto &fetch; }
$core[006042] = 00000; $code[006042] = *S06042; sub S06042 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006043] = 01024; $code[006043] = *I06043; sub I06043 { $lac += $core[000024]; goto &fetch; }
$core[006044] = 01115; $code[006044] = *I06044; sub I06044 { $lac += $core[000115]; goto &fetch; }
$core[006045] = 07140; $code[006045] = *I06045; sub I06045 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006046] = 03045; $code[006046] = *I06046; sub I06046 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006047] = 01022; $code[006047] = *I06047; sub I06047 { $lac += $core[000022]; goto &fetch; }
$core[006050] = 03043; $code[006050] = *I06050; sub I06050 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006051] = 01023; $code[006051] = *I06051; sub I06051 { $lac += $core[000023]; goto &fetch; }
$core[006052] = 03044; $code[006052] = *I06052; sub I06052 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006053] = 01025; $code[006053] = *I06053; sub I06053 { $lac += $core[000025]; goto &fetch; }
$core[006054] = 00115; $code[006054] = *I06054; sub I06054 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[006055] = 03046; $code[006055] = *I06055; sub I06055 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006056] = 01045; $code[006056] = *I06056; sub I06056 { $lac += $core[000045]; goto &fetch; }
$core[006057] = 01377; $code[006057] = *I06057; sub I06057 { $lac += $core[006177]; goto &fetch; }
$core[006060] = 07710; $code[006060] = *I06060; sub I06060 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006061] = 05307; $code[006061] = *I06061; sub I06061 { $pc = 006107; $inh = 0; goto &fetch; }
$core[006062] = 01045; $code[006062] = *I06062; sub I06062 { $lac += $core[000045]; goto &fetch; }
$core[006063] = 07650; $code[006063] = *I06063; sub I06063 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006064] = 05313; $code[006064] = *I06064; sub I06064 { $pc = 006113; $inh = 0; goto &fetch; }
$core[006065] = 01044; $code[006065] = *I06065; sub I06065 { $lac += $core[000044]; goto &fetch; }
$core[006066] = 07421; $code[006066] = *I06066; sub I06066 { &emul8; goto &fetch; }
$core[006067] = 01043; $code[006067] = *I06067; sub I06067 { $lac += $core[000043]; goto &fetch; }
$core[006070] = 07521; $code[006070] = *L06070; sub L06070 { &emul8; goto &fetch; }
$core[006071] = 07104; $code[006071] = *I06071; sub I06071 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006072] = 07521; $code[006072] = *I06072; sub I06072 { &emul8; goto &fetch; }
$core[006073] = 07004; $code[006073] = *I06073; sub I06073 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006074] = 02045; $code[006074] = *L06074; sub L06074 { if (++$core[000045] == 010000) { $core[000045] = 0; $pc++; }$code[000045] = *emul8; goto &fetch; }
$core[006075] = 05270; $code[006075] = *I06075; sub I06075 { $pc = 006070; $inh = 0; goto &fetch; }
$core[006076] = 03043; $code[006076] = *I06076; sub I06076 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006077] = 07501; $code[006077] = *I06077; sub I06077 { &emul8; goto &fetch; }
$core[006100] = 03044; $code[006100] = *I06100; sub I06100 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006101] = 07210; $code[006101] = *I06101; sub I06101 { $lac &= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006102] = 03042; $code[006102] = *I06102; sub I06102 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006103] = 01115; $code[006103] = *I06103; sub I06103 { $lac += $core[000115]; goto &fetch; }
$core[006104] = 00165; $code[006104] = *I06104; sub I06104 { $lac &= (010000|$core[000165]); goto &fetch; }
$core[006105] = 03045; $code[006105] = *I06105; sub I06105 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006106] = 05642; $code[006106] = *I06106; sub I06106 { $pc = ($ib<<12)+$core[3106]; $inh = 0; goto &fetch; }
$core[006107] = 07340; $code[006107] = *L06107; sub L06107 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006110] = 03045; $code[006110] = *I06110; sub I06110 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006111] = 07421; $code[006111] = *I06111; sub I06111 { &emul8; goto &fetch; }
$core[006112] = 05274; $code[006112] = *I06112; sub I06112 { $pc = 006074; $inh = 0; goto &fetch; }
$core[006113] = 01021; $code[006113] = *L06113; sub L06113 { $lac += $core[000021]; goto &fetch; }
$core[006114] = 03042; $code[006114] = *I06114; sub I06114 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006115] = 01165; $code[006115] = *I06115; sub I06115 { $lac += $core[000165]; goto &fetch; }
$core[006116] = 03045; $code[006116] = *I06116; sub I06116 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006117] = 05642; $code[006117] = *I06117; sub I06117 { $pc = ($ib<<12)+$core[3106]; $inh = 0; goto &fetch; }
$core[006120] = 00000; $code[006120] = *S06120; sub S06120 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006121] = 01024; $code[006121] = *I06121; sub I06121 { $lac += $core[000024]; goto &fetch; }
$core[006122] = 01115; $code[006122] = *I06122; sub I06122 { $lac += $core[000115]; goto &fetch; }
$core[006123] = 07140; $code[006123] = *I06123; sub I06123 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006124] = 03045; $code[006124] = *I06124; sub I06124 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006125] = 01045; $code[006125] = *I06125; sub I06125 { $lac += $core[000045]; goto &fetch; }
$core[006126] = 01164; $code[006126] = *I06126; sub I06126 { $lac += $core[000164]; goto &fetch; }
$core[006127] = 07710; $code[006127] = *I06127; sub I06127 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006130] = 05367; $code[006130] = *I06130; sub I06130 { $pc = 006167; $inh = 0; goto &fetch; }
$core[006131] = 01022; $code[006131] = *I06131; sub I06131 { $lac += $core[000022]; goto &fetch; }
$core[006132] = 03043; $code[006132] = *I06132; sub I06132 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006133] = 01023; $code[006133] = *I06133; sub I06133 { $lac += $core[000023]; goto &fetch; }
$core[006134] = 03044; $code[006134] = *I06134; sub I06134 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006135] = 01045; $code[006135] = *I06135; sub I06135 { $lac += $core[000045]; goto &fetch; }
$core[006136] = 07650; $code[006136] = *I06136; sub I06136 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006137] = 05364; $code[006137] = *I06137; sub I06137 { $pc = 006164; $inh = 0; goto &fetch; }
$core[006140] = 01044; $code[006140] = *I06140; sub I06140 { $lac += $core[000044]; goto &fetch; }
$core[006141] = 07421; $code[006141] = *I06141; sub I06141 { &emul8; goto &fetch; }
$core[006142] = 01043; $code[006142] = *I06142; sub I06142 { $lac += $core[000043]; goto &fetch; }
$core[006143] = 07110; $code[006143] = *L06143; sub L06143 { $lac &= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006144] = 07521; $code[006144] = *I06144; sub I06144 { &emul8; goto &fetch; }
$core[006145] = 07010; $code[006145] = *I06145; sub I06145 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006146] = 07521; $code[006146] = *I06146; sub I06146 { &emul8; goto &fetch; }
$core[006147] = 02045; $code[006147] = *L06147; sub L06147 { if (++$core[000045] == 010000) { $core[000045] = 0; $pc++; }$code[000045] = *emul8; goto &fetch; }
$core[006150] = 05343; $code[006150] = *I06150; sub I06150 { $pc = 006143; $inh = 0; goto &fetch; }
$core[006151] = 03043; $code[006151] = *I06151; sub I06151 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006152] = 07501; $code[006152] = *I06152; sub I06152 { &emul8; goto &fetch; }
$core[006153] = 03044; $code[006153] = *I06153; sub I06153 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006154] = 03042; $code[006154] = *I06154; sub I06154 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006155] = 07210; $code[006155] = *I06155; sub I06155 { $lac &= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006156] = 00115; $code[006156] = *I06156; sub I06156 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[006157] = 03046; $code[006157] = *I06157; sub I06157 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006160] = 01165; $code[006160] = *L06160; sub L06160 { $lac += $core[000165]; goto &fetch; }
$core[006161] = 00115; $code[006161] = *I06161; sub I06161 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[006162] = 03045; $code[006162] = *I06162; sub I06162 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006163] = 05720; $code[006163] = *I06163; sub I06163 { $pc = ($ib<<12)+$core[3152]; $inh = 0; goto &fetch; }
$core[006164] = 01025; $code[006164] = *L06164; sub L06164 { $lac += $core[000025]; goto &fetch; }
$core[006165] = 03046; $code[006165] = *I06165; sub I06165 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006166] = 05360; $code[006166] = *I06166; sub I06166 { $pc = 006160; $inh = 0; goto &fetch; }
$core[006167] = 07340; $code[006167] = *L06167; sub L06167 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006170] = 03045; $code[006170] = *I06170; sub I06170 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006171] = 07421; $code[006171] = *I06171; sub I06171 { &emul8; goto &fetch; }
$core[006172] = 05347; $code[006172] = *I06172; sub I06172 { $pc = 006147; $inh = 0; goto &fetch; }
$core[006177] = 00032; $code[006177] = *D06177; sub D06177 { $lac &= (010000|$core[000032]); goto &fetch; }
$core[006200] = 00000; $code[006200] = *S06200; sub S06200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006201] = 01024; $code[006201] = *I06201; sub I06201 { $lac += $core[000024]; goto &fetch; }
$core[006202] = 01115; $code[006202] = *I06202; sub I06202 { $lac += $core[000115]; goto &fetch; }
$core[006203] = 07140; $code[006203] = *I06203; sub I06203 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006204] = 03045; $code[006204] = *I06204; sub I06204 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006205] = 01022; $code[006205] = *I06205; sub I06205 { $lac += $core[000022]; goto &fetch; }
$core[006206] = 03043; $code[006206] = *I06206; sub I06206 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006207] = 01023; $code[006207] = *I06207; sub I06207 { $lac += $core[000023]; goto &fetch; }
$core[006210] = 03044; $code[006210] = *I06210; sub I06210 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006211] = 01045; $code[006211] = *I06211; sub I06211 { $lac += $core[000045]; goto &fetch; }
$core[006212] = 07650; $code[006212] = *I06212; sub I06212 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006213] = 05251; $code[006213] = *I06213; sub I06213 { $pc = 006251; $inh = 0; goto &fetch; }
$core[006214] = 01045; $code[006214] = *I06214; sub I06214 { $lac += $core[000045]; goto &fetch; }
$core[006215] = 01164; $code[006215] = *I06215; sub I06215 { $lac += $core[000164]; goto &fetch; }
$core[006216] = 07710; $code[006216] = *I06216; sub I06216 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006217] = 05257; $code[006217] = *I06217; sub I06217 { $pc = 006257; $inh = 0; goto &fetch; }
$core[006220] = 01044; $code[006220] = *I06220; sub I06220 { $lac += $core[000044]; goto &fetch; }
$core[006221] = 07421; $code[006221] = *I06221; sub I06221 { &emul8; goto &fetch; }
$core[006222] = 01043; $code[006222] = *I06222; sub I06222 { $lac += $core[000043]; goto &fetch; }
$core[006223] = 07100; $code[006223] = *L06223; sub L06223 { $lac &= 07777; goto &fetch; }
$core[006224] = 07510; $code[006224] = *I06224; sub I06224 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006225] = 07020; $code[006225] = *I06225; sub I06225 { $lac ^= 010000; goto &fetch; }
$core[006226] = 07010; $code[006226] = *I06226; sub I06226 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006227] = 07521; $code[006227] = *I06227; sub I06227 { &emul8; goto &fetch; }
$core[006230] = 07010; $code[006230] = *I06230; sub I06230 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006231] = 07521; $code[006231] = *I06231; sub I06231 { &emul8; goto &fetch; }
$core[006232] = 02045; $code[006232] = *I06232; sub I06232 { if (++$core[000045] == 010000) { $core[000045] = 0; $pc++; }$code[000045] = *emul8; goto &fetch; }
$core[006233] = 05223; $code[006233] = *I06233; sub I06233 { $pc = 006223; $inh = 0; goto &fetch; }
$core[006234] = 03043; $code[006234] = *I06234; sub I06234 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006235] = 07501; $code[006235] = *I06235; sub I06235 { &emul8; goto &fetch; }
$core[006236] = 03044; $code[006236] = *I06236; sub I06236 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006237] = 07210; $code[006237] = *L06237; sub L06237 { $lac &= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006240] = 00115; $code[006240] = *I06240; sub I06240 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[006241] = 03046; $code[006241] = *I06241; sub I06241 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006242] = 01043; $code[006242] = *I06242; sub I06242 { $lac += $core[000043]; goto &fetch; }
$core[006243] = 00163; $code[006243] = *I06243; sub I06243 { $lac &= (010000|$core[000163]); goto &fetch; }
$core[006244] = 03042; $code[006244] = *I06244; sub I06244 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006245] = 01165; $code[006245] = *L06245; sub L06245 { $lac += $core[000165]; goto &fetch; }
$core[006246] = 00115; $code[006246] = *I06246; sub I06246 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[006247] = 03045; $code[006247] = *I06247; sub I06247 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006250] = 05600; $code[006250] = *I06250; sub I06250 { $pc = ($ib<<12)+$core[3200]; $inh = 0; goto &fetch; }
$core[006251] = 01022; $code[006251] = *L06251; sub L06251 { $lac += $core[000022]; goto &fetch; }
$core[006252] = 00163; $code[006252] = *I06252; sub I06252 { $lac &= (010000|$core[000163]); goto &fetch; }
$core[006253] = 03042; $code[006253] = *I06253; sub I06253 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006254] = 01025; $code[006254] = *I06254; sub I06254 { $lac += $core[000025]; goto &fetch; }
$core[006255] = 03046; $code[006255] = *I06255; sub I06255 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006256] = 05245; $code[006256] = *I06256; sub I06256 { $pc = 006245; $inh = 0; goto &fetch; }
$core[006257] = 01043; $code[006257] = *L06257; sub L06257 { $lac += $core[000043]; goto &fetch; }
$core[006260] = 00163; $code[006260] = *I06260; sub I06260 { $lac &= (010000|$core[000163]); goto &fetch; }
$core[006261] = 07104; $code[006261] = *I06261; sub I06261 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006262] = 07620; $code[006262] = *I06262; sub I06262 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006263] = 05271; $code[006263] = *I06263; sub I06263 { $pc = 006271; $inh = 0; goto &fetch; }
$core[006264] = 07040; $code[006264] = *I06264; sub I06264 { $lac ^= 07777; goto &fetch; }
$core[006265] = 03044; $code[006265] = *I06265; sub I06265 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006266] = 07040; $code[006266] = *I06266; sub I06266 { $lac ^= 07777; goto &fetch; }
$core[006267] = 03043; $code[006267] = *L06267; sub L06267 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006270] = 05237; $code[006270] = *I06270; sub I06270 { $pc = 006237; $inh = 0; goto &fetch; }
$core[006271] = 03044; $code[006271] = *L06271; sub L06271 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006272] = 05267; $code[006272] = *I06272; sub I06272 { $pc = 006267; $inh = 0; goto &fetch; }
$core[006273] = 00000; $code[006273] = *S06273; sub S06273 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006274] = 01023; $code[006274] = *I06274; sub I06274 { $lac += $core[000023]; goto &fetch; }
$core[006275] = 07101; $code[006275] = *I06275; sub I06275 { $lac &= 07777; $lac++; goto &fetch; }
$core[006276] = 03044; $code[006276] = *I06276; sub I06276 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006277] = 07004; $code[006277] = *I06277; sub I06277 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006300] = 01022; $code[006300] = *I06300; sub I06300 { $lac += $core[000022]; goto &fetch; }
$core[006301] = 03043; $code[006301] = *I06301; sub I06301 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006302] = 07010; $code[006302] = *I06302; sub I06302 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006303] = 03042; $code[006303] = *I06303; sub I06303 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006304] = 01025; $code[006304] = *I06304; sub I06304 { $lac += $core[000025]; goto &fetch; }
$core[006305] = 03046; $code[006305] = *I06305; sub I06305 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006306] = 01024; $code[006306] = *I06306; sub I06306 { $lac += $core[000024]; goto &fetch; }
$core[006307] = 03045; $code[006307] = *I06307; sub I06307 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006310] = 05673; $code[006310] = *I06310; sub I06310 { $pc = ($ib<<12)+$core[3259]; $inh = 0; goto &fetch; }
$core[006311] = 00000; $code[006311] = *S06311; sub S06311 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006312] = 01023; $code[006312] = *I06312; sub I06312 { $lac += $core[000023]; goto &fetch; }
$core[006313] = 07041; $code[006313] = *I06313; sub I06313 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006314] = 03044; $code[006314] = *I06314; sub I06314 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006315] = 01022; $code[006315] = *I06315; sub I06315 { $lac += $core[000022]; goto &fetch; }
$core[006316] = 07040; $code[006316] = *I06316; sub I06316 { $lac ^= 07777; goto &fetch; }
$core[006317] = 03043; $code[006317] = *I06317; sub I06317 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006320] = 07004; $code[006320] = *I06320; sub I06320 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006321] = 01043; $code[006321] = *I06321; sub I06321 { $lac += $core[000043]; goto &fetch; }
$core[006322] = 03043; $code[006322] = *I06322; sub I06322 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006323] = 07010; $code[006323] = *I06323; sub I06323 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006324] = 03042; $code[006324] = *I06324; sub I06324 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006325] = 01025; $code[006325] = *I06325; sub I06325 { $lac += $core[000025]; goto &fetch; }
$core[006326] = 03046; $code[006326] = *I06326; sub I06326 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006327] = 01024; $code[006327] = *I06327; sub I06327 { $lac += $core[000024]; goto &fetch; }
$core[006330] = 03045; $code[006330] = *I06330; sub I06330 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006331] = 05711; $code[006331] = *I06331; sub I06331 { $pc = ($ib<<12)+$core[3273]; $inh = 0; goto &fetch; }
$core[006332] = 00000; $code[006332] = *S06332; sub S06332 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006333] = 01023; $code[006333] = *I06333; sub I06333 { $lac += $core[000023]; goto &fetch; }
$core[006334] = 01025; $code[006334] = *I06334; sub I06334 { $lac += $core[000025]; goto &fetch; }
$core[006335] = 03044; $code[006335] = *I06335; sub I06335 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006336] = 07204; $code[006336] = *I06336; sub I06336 { $lac &= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006337] = 01022; $code[006337] = *I06337; sub I06337 { $lac += $core[000022]; goto &fetch; }
$core[006340] = 01024; $code[006340] = *I06340; sub I06340 { $lac += $core[000024]; goto &fetch; }
$core[006341] = 03043; $code[006341] = *I06341; sub I06341 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006342] = 07010; $code[006342] = *I06342; sub I06342 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006343] = 03042; $code[006343] = *I06343; sub I06343 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006344] = 05732; $code[006344] = *I06344; sub I06344 { $pc = ($ib<<12)+$core[3290]; $inh = 0; goto &fetch; }
$core[006345] = 00000; $code[006345] = *S06345; sub S06345 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006346] = 01745; $code[006346] = *I06346; sub I06346 { $lac += $core[($df<<12)+$core[3301]]; goto &fetch; }
$core[006347] = 03374; $code[006347] = *I06347; sub I06347 { $core[006374] = $lac & 07777; $lac &= 010000; $code[006374] = *emul8; goto &fetch; }
$core[006350] = 02345; $code[006350] = *I06350; sub I06350 { if (++$core[006345] == 010000) { $core[006345] = 0; $pc++; }$code[006345] = *emul8; goto &fetch; }
$core[006351] = 01370; $code[006351] = *I06351; sub I06351 { $lac += $core[006370]; goto &fetch; }
$core[006352] = 03372; $code[006352] = *I06352; sub I06352 { $core[006372] = $lac & 07777; $lac &= 010000; $code[006372] = *emul8; goto &fetch; }
$core[006353] = 01371; $code[006353] = *I06353; sub I06353 { $lac += $core[006371]; goto &fetch; }
$core[006354] = 03373; $code[006354] = *I06354; sub I06354 { $core[006373] = $lac & 07777; $lac &= 010000; $code[006373] = *emul8; goto &fetch; }
$core[006355] = 01772; $code[006355] = *L06355; sub L06355 { $lac += $core[($df<<12)+$core[3322]]; goto &fetch; }
$core[006356] = 07041; $code[006356] = *I06356; sub I06356 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006357] = 01773; $code[006357] = *I06357; sub I06357 { $lac += $core[($df<<12)+$core[3323]]; goto &fetch; }
$core[006360] = 07640; $code[006360] = *I06360; sub I06360 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006361] = 05745; $code[006361] = *I06361; sub I06361 { $pc = ($ib<<12)+$core[3301]; $inh = 0; goto &fetch; }
$core[006362] = 02372; $code[006362] = *I06362; sub I06362 { if (++$core[006372] == 010000) { $core[006372] = 0; $pc++; }$code[006372] = *emul8; goto &fetch; }
$core[006363] = 02373; $code[006363] = *I06363; sub I06363 { if (++$core[006373] == 010000) { $core[006373] = 0; $pc++; }$code[006373] = *emul8; goto &fetch; }
$core[006364] = 02374; $code[006364] = *I06364; sub I06364 { if (++$core[006374] == 010000) { $core[006374] = 0; $pc++; }$code[006374] = *emul8; goto &fetch; }
$core[006365] = 05355; $code[006365] = *I06365; sub I06365 { $pc = 006355; $inh = 0; goto &fetch; }
$core[006366] = 02345; $code[006366] = *I06366; sub I06366 { if (++$core[006345] == 010000) { $core[006345] = 0; $pc++; }$code[006345] = *emul8; goto &fetch; }
$core[006367] = 05745; $code[006367] = *I06367; sub I06367 { $pc = ($ib<<12)+$core[3301]; $inh = 0; goto &fetch; }
$core[006370] = 00000; $code[006370] = *D06370; sub D06370 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006371] = 00000; $code[006371] = *D06371; sub D06371 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006372] = 00000; $code[006372] = *P06372; sub P06372 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006373] = 00000; $code[006373] = *P06373; sub P06373 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006374] = 00000; $code[006374] = *D06374; sub D06374 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006400] = 00000; $code[006400] = *S06400; sub S06400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006401] = 07200; $code[006401] = *I06401; sub I06401 { $lac &= 010000; goto &fetch; }
$core[006402] = 01600; $code[006402] = *I06402; sub I06402 { $lac += $core[($df<<12)+$core[3328]]; goto &fetch; }
$core[006403] = 03223; $code[006403] = *I06403; sub I06403 { $core[006423] = $lac & 07777; $lac &= 010000; $code[006423] = *emul8; goto &fetch; }
$core[006404] = 02200; $code[006404] = *I06404; sub I06404 { if (++$core[006400] == 010000) { $core[006400] = 0; $pc++; }$code[006400] = *emul8; goto &fetch; }
$core[006405] = 01600; $code[006405] = *I06405; sub I06405 { $lac += $core[($df<<12)+$core[3328]]; goto &fetch; }
$core[006406] = 03224; $code[006406] = *I06406; sub I06406 { $core[006424] = $lac & 07777; $lac &= 010000; $code[006424] = *emul8; goto &fetch; }
$core[006407] = 02200; $code[006407] = *I06407; sub I06407 { if (++$core[006400] == 010000) { $core[006400] = 0; $pc++; }$code[006400] = *emul8; goto &fetch; }
$core[006410] = 01600; $code[006410] = *D06410; sub D06410 { $lac += $core[($df<<12)+$core[3328]]; goto &fetch; }
$core[006411] = 03225; $code[006411] = *I06411; sub I06411 { $core[006425] = $lac & 07777; $lac &= 010000; $code[006425] = *emul8; goto &fetch; }
$core[006412] = 02200; $code[006412] = *I06412; sub I06412 { if (++$core[006400] == 010000) { $core[006400] = 0; $pc++; }$code[006400] = *emul8; goto &fetch; }
$core[006413] = 07200; $code[006413] = *L06413; sub L06413 { $lac &= 010000; goto &fetch; }
$core[006414] = 01623; $code[006414] = *I06414; sub I06414 { $lac += $core[($df<<12)+$core[3347]]; goto &fetch; }
$core[006415] = 03624; $code[006415] = *I06415; sub I06415 { $core[($df<<12)+$core[3348]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3348]] = *emul8; goto &fetch; }
$core[006416] = 02223; $code[006416] = *I06416; sub I06416 { if (++$core[006423] == 010000) { $core[006423] = 0; $pc++; }$code[006423] = *emul8; goto &fetch; }
$core[006417] = 02224; $code[006417] = *I06417; sub I06417 { if (++$core[006424] == 010000) { $core[006424] = 0; $pc++; }$code[006424] = *emul8; goto &fetch; }
$core[006420] = 02225; $code[006420] = *I06420; sub I06420 { if (++$core[006425] == 010000) { $core[006425] = 0; $pc++; }$code[006425] = *emul8; goto &fetch; }
$core[006421] = 05213; $code[006421] = *I06421; sub I06421 { $pc = 006413; $inh = 0; goto &fetch; }
$core[006422] = 05600; $code[006422] = *D06422; sub D06422 { $pc = ($ib<<12)+$core[3328]; $inh = 0; goto &fetch; }
$core[006423] = 00000; $code[006423] = *P06423; sub P06423 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006424] = 00000; $code[006424] = *P06424; sub P06424 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006425] = 00000; $code[006425] = *D06425; sub D06425 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006426] = 00000; $code[006426] = *S06426; sub S06426 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006427] = 01377; $code[006427] = *I06427; sub I06427 { $lac += $core[006577]; goto &fetch; }
$core[006430] = 03271; $code[006430] = *I06430; sub I06430 { $core[006471] = $lac & 07777; $lac &= 010000; $code[006471] = *emul8; goto &fetch; }
$core[006431] = 01262; $code[006431] = *I06431; sub I06431 { $lac += $core[006462]; goto &fetch; }
$core[006432] = 03243; $code[006432] = *I06432; sub I06432 { $core[006443] = $lac & 07777; $lac &= 010000; $code[006443] = *emul8; goto &fetch; }
$core[006433] = 01626; $code[006433] = *I06433; sub I06433 { $lac += $core[($df<<12)+$core[3350]]; goto &fetch; }
$core[006434] = 02226; $code[006434] = *I06434; sub I06434 { if (++$core[006426] == 010000) { $core[006426] = 0; $pc++; }$code[006426] = *emul8; goto &fetch; }
$core[006435] = 03270; $code[006435] = *I06435; sub I06435 { $core[006470] = $lac & 07777; $lac &= 010000; $code[006470] = *emul8; goto &fetch; }
$core[006436] = 01670; $code[006436] = *I06436; sub I06436 { $lac += $core[($df<<12)+$core[3384]]; goto &fetch; }
$core[006437] = 03267; $code[006437] = *I06437; sub I06437 { $core[006467] = $lac & 07777; $lac &= 010000; $code[006467] = *emul8; goto &fetch; }
$core[006440] = 03270; $code[006440] = *L06440; sub L06440 { $core[006470] = $lac & 07777; $lac &= 010000; $code[006470] = *emul8; goto &fetch; }
$core[006441] = 07100; $code[006441] = *L06441; sub L06441 { $lac &= 07777; goto &fetch; }
$core[006442] = 01267; $code[006442] = *I06442; sub I06442 { $lac += $core[006467]; goto &fetch; }
$core[006443] = 01263; $code[006443] = *D06443; sub D06443 { $lac += $core[006463]; goto &fetch; }
$core[006444] = 07420; $code[006444] = *I06444; sub I06444 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[006445] = 05251; $code[006445] = *I06445; sub I06445 { $pc = 006451; $inh = 0; goto &fetch; }
$core[006446] = 02270; $code[006446] = *I06446; sub I06446 { if (++$core[006470] == 010000) { $core[006470] = 0; $pc++; }$code[006470] = *emul8; goto &fetch; }
$core[006447] = 03267; $code[006447] = *I06447; sub I06447 { $core[006467] = $lac & 07777; $lac &= 010000; $code[006467] = *emul8; goto &fetch; }
$core[006450] = 05241; $code[006450] = *I06450; sub I06450 { $pc = 006441; $inh = 0; goto &fetch; }
$core[006451] = 07200; $code[006451] = *L06451; sub L06451 { $lac &= 010000; goto &fetch; }
$core[006452] = 01270; $code[006452] = *I06452; sub I06452 { $lac += $core[006470]; goto &fetch; }
$core[006453] = 01272; $code[006453] = *I06453; sub I06453 { $lac += $core[006472]; goto &fetch; }
$core[006454] = 04526; $code[006454] = *I06454; sub I06454 { $core[($ib<<12)+$core[86]] = 06455; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[006455] = 07300; $code[006455] = *I06455; sub I06455 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006456] = 02243; $code[006456] = *I06456; sub I06456 { if (++$core[006443] == 010000) { $core[006443] = 0; $pc++; }$code[006443] = *emul8; goto &fetch; }
$core[006457] = 02271; $code[006457] = *I06457; sub I06457 { if (++$core[006471] == 010000) { $core[006471] = 0; $pc++; }$code[006471] = *emul8; goto &fetch; }
$core[006460] = 05240; $code[006460] = *D06460; sub D06460 { $pc = 006440; $inh = 0; goto &fetch; }
$core[006461] = 05626; $code[006461] = *I06461; sub I06461 { $pc = ($ib<<12)+$core[3350]; $inh = 0; goto &fetch; }
$core[006462] = 01263; $code[006462] = *D06462; sub D06462 { $lac += $core[006463]; goto &fetch; }
$core[006463] = 06030; $code[006463] = *D06463; sub D06463 { &emul8; goto &fetch; }
$core[006464] = 07634; $code[006464] = *I06464; sub I06464 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006465] = 07766; $code[006465] = *I06465; sub I06465 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[006466] = 07777; $code[006466] = *I06466; sub I06466 { &emul8; goto &fetch; }
$core[006467] = 00000; $code[006467] = *D06467; sub D06467 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006470] = 00000; $code[006470] = *P06470; sub P06470 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006471] = 00000; $code[006471] = *D06471; sub D06471 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006472] = 00260; $code[006472] = *D06472; sub D06472 { $lac &= (010000|$core[006460]); goto &fetch; }
$core[006473] = 00000; $code[006473] = *S06473; sub S06473 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006474] = 07102; $code[006474] = *I06474; sub I06474 { $lac &= 07777; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[006475] = 07421; $code[006475] = *I06475; sub I06475 { &emul8; goto &fetch; }
$core[006476] = 07501; $code[006476] = *I06476; sub I06476 { &emul8; goto &fetch; }
$core[006477] = 07012; $code[006477] = *I06477; sub I06477 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006500] = 07010; $code[006500] = *I06500; sub I06500 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006501] = 00376; $code[006501] = *I06501; sub I06501 { $lac &= (010000|$core[006576]); goto &fetch; }
$core[006502] = 07521; $code[006502] = *I06502; sub I06502 { &emul8; goto &fetch; }
$core[006503] = 07106; $code[006503] = *I06503; sub I06503 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[006504] = 07004; $code[006504] = *I06504; sub I06504 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006505] = 00375; $code[006505] = *I06505; sub I06505 { $lac &= (010000|$core[006575]); goto &fetch; }
$core[006506] = 07501; $code[006506] = *I06506; sub I06506 { &emul8; goto &fetch; }
$core[006507] = 07421; $code[006507] = *P06507; sub P06507 { &emul8; goto &fetch; }
$core[006510] = 07501; $code[006510] = *I06510; sub I06510 { &emul8; goto &fetch; }
$core[006511] = 00374; $code[006511] = *I06511; sub I06511 { $lac &= (010000|$core[006574]); goto &fetch; }
$core[006512] = 03324; $code[006512] = *I06512; sub I06512 { $core[006524] = $lac & 07777; $lac &= 010000; $code[006524] = *emul8; goto &fetch; }
$core[006513] = 07501; $code[006513] = *I06513; sub I06513 { &emul8; goto &fetch; }
$core[006514] = 00373; $code[006514] = *I06514; sub I06514 { $lac &= (010000|$core[006573]); goto &fetch; }
$core[006515] = 07112; $code[006515] = *I06515; sub I06515 { $lac &= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006516] = 07521; $code[006516] = *I06516; sub I06516 { &emul8; goto &fetch; }
$core[006517] = 00372; $code[006517] = *I06517; sub I06517 { $lac &= (010000|$core[006572]); goto &fetch; }
$core[006520] = 07106; $code[006520] = *I06520; sub I06520 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[006521] = 01324; $code[006521] = *I06521; sub I06521 { $lac += $core[006524]; goto &fetch; }
$core[006522] = 07501; $code[006522] = *I06522; sub I06522 { &emul8; goto &fetch; }
$core[006523] = 05673; $code[006523] = *I06523; sub I06523 { $pc = ($ib<<12)+$core[3387]; $inh = 0; goto &fetch; }
$core[006524] = 00000; $code[006524] = *D06524; sub D06524 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006525] = 00000; $code[006525] = *S06525; sub S06525 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006526] = 07200; $code[006526] = *I06526; sub I06526 { $lac &= 010000; goto &fetch; }
$core[006527] = 01370; $code[006527] = *I06527; sub I06527 { $lac += $core[006570]; goto &fetch; }
$core[006530] = 01355; $code[006530] = *I06530; sub I06530 { $lac += $core[006555]; goto &fetch; }
$core[006531] = 07640; $code[006531] = *I06531; sub I06531 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006532] = 05342; $code[006532] = *I06532; sub I06532 { $pc = 006542; $inh = 0; goto &fetch; }
$core[006533] = 01357; $code[006533] = *I06533; sub I06533 { $lac += $core[006557]; goto &fetch; }
$core[006534] = 03355; $code[006534] = *I06534; sub I06534 { $core[006555] = $lac & 07777; $lac &= 010000; $code[006555] = *emul8; goto &fetch; }
$core[006535] = 01356; $code[006535] = *I06535; sub I06535 { $lac += $core[006556]; goto &fetch; }
$core[006536] = 07104; $code[006536] = *I06536; sub I06536 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006537] = 07430; $code[006537] = *I06537; sub I06537 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006540] = 07001; $code[006540] = *I06540; sub I06540 { $lac++; goto &fetch; }
$core[006541] = 03356; $code[006541] = *I06541; sub I06541 { $core[006556] = $lac & 07777; $lac &= 010000; $code[006556] = *emul8; goto &fetch; }
$core[006542] = 01356; $code[006542] = *L06542; sub L06542 { $lac += $core[006556]; goto &fetch; }
$core[006543] = 01755; $code[006543] = *I06543; sub I06543 { $lac += $core[($df<<12)+$core[3437]]; goto &fetch; }
$core[006544] = 03755; $code[006544] = *I06544; sub I06544 { $core[($df<<12)+$core[3437]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3437]] = *emul8; goto &fetch; }
$core[006545] = 01371; $code[006545] = *I06545; sub I06545 { $lac += $core[006571]; goto &fetch; }
$core[006546] = 07010; $code[006546] = *I06546; sub I06546 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006547] = 01755; $code[006547] = *I06547; sub I06547 { $lac += $core[($df<<12)+$core[3437]]; goto &fetch; }
$core[006550] = 02355; $code[006550] = *I06550; sub I06550 { if (++$core[006555] == 010000) { $core[006555] = 0; $pc++; }$code[006555] = *emul8; goto &fetch; }
$core[006551] = 07400; $code[006551] = *I06551; sub I06551 { goto &fetch; }
$core[006552] = 03371; $code[006552] = *I06552; sub I06552 { $core[006571] = $lac & 07777; $lac &= 010000; $code[006571] = *emul8; goto &fetch; }
$core[006553] = 01371; $code[006553] = *I06553; sub I06553 { $lac += $core[006571]; goto &fetch; }
$core[006554] = 05725; $code[006554] = *I06554; sub I06554 { $pc = ($ib<<12)+$core[3413]; $inh = 0; goto &fetch; }
$core[006555] = 06570; $code[006555] = *P06555; sub P06555 { &emul8; goto &fetch; }
$core[006556] = 06543; $code[006556] = *D06556; sub D06556 { &emul8; goto &fetch; }
$core[006557] = 06560; $code[006557] = *D06557; sub D06557 { &emul8; goto &fetch; }
$core[006560] = 06543; $code[006560] = *I06560; sub I06560 { &emul8; goto &fetch; }
$core[006561] = 03210; $code[006561] = *I06561; sub I06561 { $core[006410] = $lac & 07777; $lac &= 010000; $code[006410] = *emul8; goto &fetch; }
$core[006562] = 00765; $code[006562] = *I06562; sub I06562 { $lac &= (010000|$core[($df<<12)+$core[3445]]); goto &fetch; }
$core[006563] = 05432; $code[006563] = *I06563; sub I06563 { $pc = ($ib<<12)+$core[26]; $inh = 0; goto &fetch; }
$core[006564] = 02107; $code[006564] = *I06564; sub I06564 { if (++$core[000107] == 010000) { $core[000107] = 0; $pc++; }$code[000107] = *emul8; goto &fetch; }
$core[006565] = 07654; $code[006565] = *P06565; sub P06565 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006566] = 04321; $code[006566] = *I06566; sub I06566 { $core[006521] = 06567; $pc = 006521+1; $code[006521] = *emul8; $inh = 0; goto &fetch; }
$core[006567] = 00176; $code[006567] = *I06567; sub I06567 { $lac &= (010000|$core[000176]); goto &fetch; }
$core[006570] = 01210; $code[006570] = *D06570; sub D06570 { $lac += $core[006410]; goto &fetch; }
$core[006571] = 00000; $code[006571] = *D06571; sub D06571 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006572] = 01111; $code[006572] = *D06572; sub D06572 { $lac += $core[000111]; goto &fetch; }
$core[006573] = 04444; $code[006573] = *D06573; sub D06573 { $core[($ib<<12)+$core[36]] = 06574; $pc = ($ib<<12)+$core[36]+1; $code[($ib<<12)+$core[36]] = *emul8; $inh = 0; goto &fetch; }
$core[006574] = 02222; $code[006574] = *D06574; sub D06574 { if (++$core[006422] == 010000) { $core[006422] = 0; $pc++; }$code[006422] = *emul8; goto &fetch; }
$core[006575] = 07070; $code[006575] = *D06575; sub D06575 { $lac ^= 010000; $lac ^= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006576] = 00707; $code[006576] = *D06576; sub D06576 { $lac &= (010000|$core[($df<<12)+$core[3399]]); goto &fetch; }
$core[006577] = 07774; $code[006577] = *D06577; sub D06577 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006600] = 00000; $code[006600] = *S06600; sub S06600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006601] = 07200; $code[006601] = *I06601; sub I06601 { $lac &= 010000; goto &fetch; }
$core[006602] = 01600; $code[006602] = *I06602; sub I06602 { $lac += $core[($df<<12)+$core[3456]]; goto &fetch; }
$core[006603] = 03263; $code[006603] = *I06603; sub I06603 { $core[006663] = $lac & 07777; $lac &= 010000; $code[006663] = *emul8; goto &fetch; }
$core[006604] = 03265; $code[006604] = *I06604; sub I06604 { $core[006665] = $lac & 07777; $lac &= 010000; $code[006665] = *emul8; goto &fetch; }
$core[006605] = 02200; $code[006605] = *I06605; sub I06605 { if (++$core[006600] == 010000) { $core[006600] = 0; $pc++; }$code[006600] = *emul8; goto &fetch; }
$core[006606] = 01663; $code[006606] = *L06606; sub L06606 { $lac += $core[($df<<12)+$core[3507]]; goto &fetch; }
$core[006607] = 07012; $code[006607] = *I06607; sub I06607 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006610] = 07012; $code[006610] = *I06610; sub I06610 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006611] = 07012; $code[006611] = *I06611; sub I06611 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006612] = 04217; $code[006612] = *I06612; sub I06612 { $core[006617] = 06613; $pc = 006617+1; $code[006617] = *emul8; $inh = 0; goto &fetch; }
$core[006613] = 01663; $code[006613] = *I06613; sub I06613 { $lac += $core[($df<<12)+$core[3507]]; goto &fetch; }
$core[006614] = 04217; $code[006614] = *I06614; sub I06614 { $core[006617] = 06615; $pc = 006617+1; $code[006617] = *emul8; $inh = 0; goto &fetch; }
$core[006615] = 02263; $code[006615] = *I06615; sub I06615 { if (++$core[006663] == 010000) { $core[006663] = 0; $pc++; }$code[006663] = *emul8; goto &fetch; }
$core[006616] = 05206; $code[006616] = *I06616; sub I06616 { $pc = 006606; $inh = 0; goto &fetch; }
$core[006617] = 00000; $code[006617] = *S06617; sub S06617 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006620] = 00377; $code[006620] = *I06620; sub I06620 { $lac &= (010000|$core[006777]); goto &fetch; }
$core[006621] = 03264; $code[006621] = *I06621; sub I06621 { $core[006664] = $lac & 07777; $lac &= 010000; $code[006664] = *emul8; goto &fetch; }
$core[006622] = 01265; $code[006622] = *I06622; sub I06622 { $lac += $core[006665]; goto &fetch; }
$core[006623] = 07640; $code[006623] = *I06623; sub I06623 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006624] = 05234; $code[006624] = *I06624; sub I06624 { $pc = 006634; $inh = 0; goto &fetch; }
$core[006625] = 01264; $code[006625] = *I06625; sub I06625 { $lac += $core[006664]; goto &fetch; }
$core[006626] = 07450; $code[006626] = *I06626; sub I06626 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006627] = 05232; $code[006627] = *I06627; sub I06627 { $pc = 006632; $inh = 0; goto &fetch; }
$core[006630] = 04253; $code[006630] = *L06630; sub L06630 { $core[006653] = 06631; $pc = 006653+1; $code[006653] = *emul8; $inh = 0; goto &fetch; }
$core[006631] = 05617; $code[006631] = *I06631; sub I06631 { $pc = ($ib<<12)+$core[3471]; $inh = 0; goto &fetch; }
$core[006632] = 02265; $code[006632] = *L06632; sub L06632 { if (++$core[006665] == 010000) { $core[006665] = 0; $pc++; }$code[006665] = *emul8; goto &fetch; }
$core[006633] = 05617; $code[006633] = *I06633; sub I06633 { $pc = ($ib<<12)+$core[3471]; $inh = 0; goto &fetch; }
$core[006634] = 03265; $code[006634] = *L06634; sub L06634 { $core[006665] = $lac & 07777; $lac &= 010000; $code[006665] = *emul8; goto &fetch; }
$core[006635] = 01264; $code[006635] = *I06635; sub I06635 { $lac += $core[006664]; goto &fetch; }
$core[006636] = 07041; $code[006636] = *I06636; sub I06636 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006637] = 07450; $code[006637] = *I06637; sub I06637 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006640] = 05230; $code[006640] = *D06640; sub D06640 { $pc = 006630; $inh = 0; goto &fetch; }
$core[006641] = 07001; $code[006641] = *I06641; sub I06641 { $lac++; goto &fetch; }
$core[006642] = 07650; $code[006642] = *I06642; sub I06642 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006643] = 05600; $code[006643] = *I06643; sub I06643 { $pc = ($ib<<12)+$core[3456]; $inh = 0; goto &fetch; }
$core[006644] = 01266; $code[006644] = *I06644; sub I06644 { $lac += $core[006666]; goto &fetch; }
$core[006645] = 03255; $code[006645] = *I06645; sub I06645 { $core[006655] = $lac & 07777; $lac &= 010000; $code[006655] = *emul8; goto &fetch; }
$core[006646] = 01264; $code[006646] = *I06646; sub I06646 { $lac += $core[006664]; goto &fetch; }
$core[006647] = 04253; $code[006647] = *I06647; sub I06647 { $core[006653] = 06650; $pc = 006653+1; $code[006653] = *emul8; $inh = 0; goto &fetch; }
$core[006650] = 01267; $code[006650] = *I06650; sub I06650 { $lac += $core[006667]; goto &fetch; }
$core[006651] = 03255; $code[006651] = *I06651; sub I06651 { $core[006655] = $lac & 07777; $lac &= 010000; $code[006655] = *emul8; goto &fetch; }
$core[006652] = 05617; $code[006652] = *I06652; sub I06652 { $pc = ($ib<<12)+$core[3471]; $inh = 0; goto &fetch; }
$core[006653] = 00000; $code[006653] = *S06653; sub S06653 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006654] = 01376; $code[006654] = *I06654; sub I06654 { $lac += $core[006776]; goto &fetch; }
$core[006655] = 07510; $code[006655] = *D06655; sub D06655 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006656] = 01375; $code[006656] = *I06656; sub I06656 { $lac += $core[006775]; goto &fetch; }
$core[006657] = 01374; $code[006657] = *I06657; sub I06657 { $lac += $core[006774]; goto &fetch; }
$core[006660] = 04526; $code[006660] = *I06660; sub I06660 { $core[($ib<<12)+$core[86]] = 06661; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[006661] = 05653; $code[006661] = *I06661; sub I06661 { $pc = ($ib<<12)+$core[3499]; $inh = 0; goto &fetch; }
$core[006662] = 00000; $code[006662] = *I06662; sub I06662 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006663] = 00000; $code[006663] = *P06663; sub P06663 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006664] = 00000; $code[006664] = *D06664; sub D06664 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006665] = 00000; $code[006665] = *D06665; sub D06665 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006666] = 07500; $code[006666] = *D06666; sub D06666 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006667] = 07510; $code[006667] = *D06667; sub D06667 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006670] = 00000; $code[006670] = *S06670; sub S06670 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006671] = 01670; $code[006671] = *I06671; sub I06671 { $lac += $core[($df<<12)+$core[3512]]; goto &fetch; }
$core[006672] = 03303; $code[006672] = *I06672; sub I06672 { $core[006703] = $lac & 07777; $lac &= 010000; $code[006703] = *emul8; goto &fetch; }
$core[006673] = 02270; $code[006673] = *I06673; sub I06673 { if (++$core[006670] == 010000) { $core[006670] = 0; $pc++; }$code[006670] = *emul8; goto &fetch; }
$core[006674] = 04450; $code[006674] = *L06674; sub L06674 { $core[($ib<<12)+$core[40]] = 06675; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[006675] = 06701; $code[006675] = *I06675; sub I06675 { &emul8; goto &fetch; }
$core[006676] = 02303; $code[006676] = *I06676; sub I06676 { if (++$core[006703] == 010000) { $core[006703] = 0; $pc++; }$code[006703] = *emul8; goto &fetch; }
$core[006677] = 05274; $code[006677] = *I06677; sub I06677 { $pc = 006674; $inh = 0; goto &fetch; }
$core[006700] = 05670; $code[006700] = *I06700; sub I06700 { $pc = ($ib<<12)+$core[3512]; $inh = 0; goto &fetch; }
$core[006701] = 04000; $code[006701] = *I06701; sub I06701 { $core[000000] = 06702; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[006702] = 00100; $code[006702] = *I06702; sub I06702 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[006703] = 00000; $code[006703] = *D06703; sub D06703 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006704] = 00000; $code[006704] = *S06704; sub S06704 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006705] = 07300; $code[006705] = *I06705; sub I06705 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006706] = 01115; $code[006706] = *I06706; sub I06706 { $lac += $core[000115]; goto &fetch; }
$core[006707] = 07040; $code[006707] = *I06707; sub I06707 { $lac ^= 07777; goto &fetch; }
$core[006710] = 01373; $code[006710] = *I06710; sub I06710 { $lac += $core[006773]; goto &fetch; }
$core[006711] = 03321; $code[006711] = *I06711; sub I06711 { $core[006721] = $lac & 07777; $lac &= 010000; $code[006721] = *emul8; goto &fetch; }
$core[006712] = 04451; $code[006712] = *I06712; sub I06712 { $core[($ib<<12)+$core[41]] = 06713; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[006713] = 07774; $code[006713] = *I06713; sub I06713 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006714] = 04450; $code[006714] = *I06714; sub I06714 { $core[($ib<<12)+$core[40]] = 06715; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[006715] = 06717; $code[006715] = *I06715; sub I06715 { &emul8; goto &fetch; }
$core[006716] = 05704; $code[006716] = *I06716; sub I06716 { $pc = ($ib<<12)+$core[3524]; $inh = 0; goto &fetch; }
$core[006717] = 01517; $code[006717] = *I06717; sub I06717 { $lac += $core[($df<<12)+$core[79]]; goto &fetch; }
$core[006720] = 00405; $code[006720] = *I06720; sub I06720 { $lac &= (010000|$core[($df<<12)+$core[5]]); goto &fetch; }
$core[006721] = 00000; $code[006721] = *D06721; sub D06721 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006722] = 00001; $code[006722] = *I06722; sub I06722 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[006723] = 00000; $code[006723] = *S06723; sub S06723 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006724] = 04451; $code[006724] = *I06724; sub I06724 { $core[($ib<<12)+$core[41]] = 06725; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[006725] = 07777; $code[006725] = *I06725; sub I06725 { &emul8; goto &fetch; }
$core[006726] = 05723; $code[006726] = *I06726; sub I06726 { $pc = ($ib<<12)+$core[3539]; $inh = 0; goto &fetch; }
$core[006727] = 00000; $code[006727] = *S06727; sub S06727 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006730] = 04451; $code[006730] = *I06730; sub I06730 { $core[($ib<<12)+$core[41]] = 06731; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[006731] = 07776; $code[006731] = *I06731; sub I06731 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[006732] = 05727; $code[006732] = *I06732; sub I06732 { $pc = ($ib<<12)+$core[3543]; $inh = 0; goto &fetch; }
$core[006733] = 00000; $code[006733] = *S06733; sub S06733 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006734] = 04525; $code[006734] = *I06734; sub I06734 { $core[($ib<<12)+$core[85]] = 06735; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[006735] = 04451; $code[006735] = *I06735; sub I06735 { $core[($ib<<12)+$core[41]] = 06736; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[006736] = 07764; $code[006736] = *I06736; sub I06736 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006737] = 04450; $code[006737] = *I06737; sub I06737 { $core[($ib<<12)+$core[40]] = 06740; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[006740] = 07407; $code[006740] = *I06740; sub I06740 { &emul8; goto &fetch; }
$core[006741] = 04451; $code[006741] = *I06741; sub I06741 { $core[($ib<<12)+$core[41]] = 06742; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[006742] = 07773; $code[006742] = *I06742; sub I06742 { &emul8; goto &fetch; }
$core[006743] = 04450; $code[006743] = *I06743; sub I06743 { $core[($ib<<12)+$core[40]] = 06744; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[006744] = 07377; $code[006744] = *I06744; sub I06744 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006745] = 04451; $code[006745] = *I06745; sub I06745 { $core[($ib<<12)+$core[41]] = 06746; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[006746] = 07767; $code[006746] = *I06746; sub I06746 { &emul8; goto &fetch; }
$core[006747] = 04450; $code[006747] = *I06747; sub I06747 { $core[($ib<<12)+$core[40]] = 06750; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[006750] = 07403; $code[006750] = *I06750; sub I06750 { &emul8; goto &fetch; }
$core[006751] = 04451; $code[006751] = *I06751; sub I06751 { $core[($ib<<12)+$core[41]] = 06752; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[006752] = 07774; $code[006752] = *I06752; sub I06752 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006753] = 04450; $code[006753] = *I06753; sub I06753 { $core[($ib<<12)+$core[40]] = 06754; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[006754] = 07456; $code[006754] = *I06754; sub I06754 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[006755] = 04451; $code[006755] = *I06755; sub I06755 { $core[($ib<<12)+$core[41]] = 06756; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[006756] = 07772; $code[006756] = *I06756; sub I06756 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[006757] = 04450; $code[006757] = *I06757; sub I06757 { $core[($ib<<12)+$core[40]] = 06760; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[006760] = 07431; $code[006760] = *I06760; sub I06760 { &emul8; goto &fetch; }
$core[006761] = 05733; $code[006761] = *I06761; sub I06761 { $pc = ($ib<<12)+$core[3547]; $inh = 0; goto &fetch; }
$core[006773] = 04002; $code[006773] = *D06773; sub D06773 { $core[000002] = 06774; $pc = 000002+1; $code[000002] = *emul8; $inh = 0; goto &fetch; }
$core[006774] = 00240; $code[006774] = *D06774; sub D06774 { $lac &= (010000|$core[006640]); goto &fetch; }
$core[006775] = 00100; $code[006775] = *D06775; sub D06775 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[006776] = 07740; $code[006776] = *D06776; sub D06776 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006777] = 00077; $code[006777] = *D06777; sub D06777 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[007000] = 00000; $code[007000] = *S07000; sub S07000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007001] = 04576; $code[007001] = *I07001; sub I07001 { $core[($ib<<12)+$core[126]] = 07002; $pc = ($ib<<12)+$core[126]+1; $code[($ib<<12)+$core[126]] = *emul8; $inh = 0; goto &fetch; }
$core[007002] = 00000; $code[007002] = *D07002; sub D07002 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007003] = 04777; $code[007003] = *I07003; sub I07003 { $core[($ib<<12)+$core[3711]] = 07004; $pc = ($ib<<12)+$core[3711]+1; $code[($ib<<12)+$core[3711]] = *emul8; $inh = 0; goto &fetch; }
$core[007004] = 04525; $code[007004] = *I07004; sub I07004 { $core[($ib<<12)+$core[85]] = 07005; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[007005] = 04453; $code[007005] = *I07005; sub I07005 { $core[($ib<<12)+$core[43]] = 07006; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[007006] = 00021; $code[007006] = *I07006; sub I07006 { $lac &= (010000|$core[000021]); goto &fetch; }
$core[007007] = 00026; $code[007007] = *I07007; sub I07007 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[007010] = 07773; $code[007010] = *I07010; sub I07010 { &emul8; goto &fetch; }
$core[007011] = 04450; $code[007011] = *I07011; sub I07011 { $core[($ib<<12)+$core[40]] = 07012; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007012] = 07412; $code[007012] = *I07012; sub I07012 { $skp = 0; $skp = !$skp; $pc += $skp; $hlt = 1; goto &fetch; }
$core[007013] = 04451; $code[007013] = *I07013; sub I07013 { $core[($ib<<12)+$core[41]] = 07014; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007014] = 07771; $code[007014] = *I07014; sub I07014 { &emul8; goto &fetch; }
$core[007015] = 04246; $code[007015] = *I07015; sub I07015 { $core[007046] = 07016; $pc = 007046+1; $code[007046] = *emul8; $inh = 0; goto &fetch; }
$core[007016] = 00000; $code[007016] = *D07016; sub D07016 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007017] = 04525; $code[007017] = *I07017; sub I07017 { $core[($ib<<12)+$core[85]] = 07020; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[007020] = 04450; $code[007020] = *I07020; sub I07020 { $core[($ib<<12)+$core[40]] = 07021; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007021] = 07417; $code[007021] = *I07021; sub I07021 { &emul8; goto &fetch; }
$core[007022] = 04451; $code[007022] = *I07022; sub I07022 { $core[($ib<<12)+$core[41]] = 07023; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007023] = 07773; $code[007023] = *I07023; sub I07023 { &emul8; goto &fetch; }
$core[007024] = 04453; $code[007024] = *I07024; sub I07024 { $core[($ib<<12)+$core[43]] = 07025; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[007025] = 00042; $code[007025] = *I07025; sub I07025 { $lac &= (010000|$core[000042]); goto &fetch; }
$core[007026] = 00026; $code[007026] = *I07026; sub I07026 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[007027] = 07773; $code[007027] = *I07027; sub I07027 { &emul8; goto &fetch; }
$core[007030] = 04246; $code[007030] = *I07030; sub I07030 { $core[007046] = 07031; $pc = 007046+1; $code[007046] = *emul8; $inh = 0; goto &fetch; }
$core[007031] = 04525; $code[007031] = *I07031; sub I07031 { $core[($ib<<12)+$core[85]] = 07032; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[007032] = 04450; $code[007032] = *I07032; sub I07032 { $core[($ib<<12)+$core[40]] = 07033; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007033] = 07425; $code[007033] = *I07033; sub I07033 { &emul8; goto &fetch; }
$core[007034] = 04451; $code[007034] = *I07034; sub I07034 { $core[($ib<<12)+$core[41]] = 07035; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007035] = 07770; $code[007035] = *I07035; sub I07035 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007036] = 04453; $code[007036] = *I07036; sub I07036 { $core[($ib<<12)+$core[43]] = 07037; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[007037] = 00033; $code[007037] = *I07037; sub I07037 { $lac &= (010000|$core[000033]); goto &fetch; }
$core[007040] = 00026; $code[007040] = *I07040; sub I07040 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[007041] = 07773; $code[007041] = *I07041; sub I07041 { &emul8; goto &fetch; }
$core[007042] = 04246; $code[007042] = *I07042; sub I07042 { $core[007046] = 07043; $pc = 007046+1; $code[007046] = *emul8; $inh = 0; goto &fetch; }
$core[007043] = 05600; $code[007043] = *I07043; sub I07043 { $pc = ($ib<<12)+$core[3584]; $inh = 0; goto &fetch; }
$core[007044] = 04776; $code[007044] = *D07044; sub D07044 { $core[($ib<<12)+$core[3710]] = 07045; $pc = ($ib<<12)+$core[3710]+1; $code[($ib<<12)+$core[3710]] = *emul8; $inh = 0; goto &fetch; }
$core[007045] = 04775; $code[007045] = *D07045; sub D07045 { $core[($ib<<12)+$core[3709]] = 07046; $pc = ($ib<<12)+$core[3709]+1; $code[($ib<<12)+$core[3709]] = *emul8; $inh = 0; goto &fetch; }
$core[007046] = 00000; $code[007046] = *S07046; sub S07046 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007047] = 01026; $code[007047] = *I07047; sub I07047 { $lac += $core[000026]; goto &fetch; }
$core[007050] = 04555; $code[007050] = *I07050; sub I07050 { $core[($ib<<12)+$core[109]] = 07051; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[007051] = 04455; $code[007051] = *I07051; sub I07051 { $core[($ib<<12)+$core[45]] = 07052; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[007052] = 01027; $code[007052] = *I07052; sub I07052 { $lac += $core[000027]; goto &fetch; }
$core[007053] = 04774; $code[007053] = *I07053; sub I07053 { $core[($ib<<12)+$core[3708]] = 07054; $pc = ($ib<<12)+$core[3708]+1; $code[($ib<<12)+$core[3708]] = *emul8; $inh = 0; goto &fetch; }
$core[007054] = 04455; $code[007054] = *I07054; sub I07054 { $core[($ib<<12)+$core[45]] = 07055; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[007055] = 01030; $code[007055] = *I07055; sub I07055 { $lac += $core[000030]; goto &fetch; }
$core[007056] = 04774; $code[007056] = *I07056; sub I07056 { $core[($ib<<12)+$core[3708]] = 07057; $pc = ($ib<<12)+$core[3708]+1; $code[($ib<<12)+$core[3708]] = *emul8; $inh = 0; goto &fetch; }
$core[007057] = 04451; $code[007057] = *I07057; sub I07057 { $core[($ib<<12)+$core[41]] = 07060; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007060] = 07775; $code[007060] = *I07060; sub I07060 { &emul8; goto &fetch; }
$core[007061] = 01032; $code[007061] = *I07061; sub I07061 { $lac += $core[000032]; goto &fetch; }
$core[007062] = 04555; $code[007062] = *I07062; sub I07062 { $core[($ib<<12)+$core[109]] = 07063; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[007063] = 04451; $code[007063] = *I07063; sub I07063 { $core[($ib<<12)+$core[41]] = 07064; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007064] = 07774; $code[007064] = *I07064; sub I07064 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007065] = 01031; $code[007065] = *I07065; sub I07065 { $lac += $core[000031]; goto &fetch; }
$core[007066] = 04774; $code[007066] = *I07066; sub I07066 { $core[($ib<<12)+$core[3708]] = 07067; $pc = ($ib<<12)+$core[3708]+1; $code[($ib<<12)+$core[3708]] = *emul8; $inh = 0; goto &fetch; }
$core[007067] = 05646; $code[007067] = *I07067; sub I07067 { $pc = ($ib<<12)+$core[3622]; $inh = 0; goto &fetch; }
$core[007070] = 00000; $code[007070] = *S07070; sub S07070 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007071] = 04451; $code[007071] = *I07071; sub I07071 { $core[($ib<<12)+$core[41]] = 07072; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007072] = 07775; $code[007072] = *I07072; sub I07072 { &emul8; goto &fetch; }
$core[007073] = 01024; $code[007073] = *I07073; sub I07073 { $lac += $core[000024]; goto &fetch; }
$core[007074] = 07001; $code[007074] = *I07074; sub I07074 { $lac++; goto &fetch; }
$core[007075] = 01115; $code[007075] = *I07075; sub I07075 { $lac += $core[000115]; goto &fetch; }
$core[007076] = 03116; $code[007076] = *I07076; sub I07076 { $core[000116] = $lac & 07777; $lac &= 010000; $code[000116] = *emul8; goto &fetch; }
$core[007077] = 04773; $code[007077] = *I07077; sub I07077 { $core[($ib<<12)+$core[3707]] = 07100; $pc = ($ib<<12)+$core[3707]+1; $code[($ib<<12)+$core[3707]] = *emul8; $inh = 0; goto &fetch; }
$core[007100] = 00116; $code[007100] = *I07100; sub I07100 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[007101] = 04455; $code[007101] = *I07101; sub I07101 { $core[($ib<<12)+$core[45]] = 07102; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[007102] = 04450; $code[007102] = *I07102; sub I07102 { $core[($ib<<12)+$core[40]] = 07103; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007103] = 07447; $code[007103] = *I07103; sub I07103 { &emul8; goto &fetch; }
$core[007104] = 04455; $code[007104] = *I07104; sub I07104 { $core[($ib<<12)+$core[45]] = 07105; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[007105] = 05670; $code[007105] = *I07105; sub I07105 { $pc = ($ib<<12)+$core[3640]; $inh = 0; goto &fetch; }
$core[007106] = 00000; $code[007106] = *S07106; sub S07106 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007107] = 04576; $code[007107] = *I07107; sub I07107 { $core[($ib<<12)+$core[126]] = 07110; $pc = ($ib<<12)+$core[126]+1; $code[($ib<<12)+$core[126]] = *emul8; $inh = 0; goto &fetch; }
$core[007110] = 04772; $code[007110] = *I07110; sub I07110 { $core[($ib<<12)+$core[3706]] = 07111; $pc = ($ib<<12)+$core[3706]+1; $code[($ib<<12)+$core[3706]] = *emul8; $inh = 0; goto &fetch; }
$core[007111] = 04525; $code[007111] = *I07111; sub I07111 { $core[($ib<<12)+$core[85]] = 07112; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[007112] = 04450; $code[007112] = *I07112; sub I07112 { $core[($ib<<12)+$core[40]] = 07113; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007113] = 07407; $code[007113] = *I07113; sub I07113 { &emul8; goto &fetch; }
$core[007114] = 04451; $code[007114] = *I07114; sub I07114 { $core[($ib<<12)+$core[41]] = 07115; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007115] = 07773; $code[007115] = *I07115; sub I07115 { &emul8; goto &fetch; }
$core[007116] = 01042; $code[007116] = *I07116; sub I07116 { $lac += $core[000042]; goto &fetch; }
$core[007117] = 04555; $code[007117] = *I07117; sub I07117 { $core[($ib<<12)+$core[109]] = 07120; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[007120] = 04451; $code[007120] = *I07120; sub I07120 { $core[($ib<<12)+$core[41]] = 07121; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007121] = 07761; $code[007121] = *I07121; sub I07121 { &emul8; goto &fetch; }
$core[007122] = 01033; $code[007122] = *I07122; sub I07122 { $lac += $core[000033]; goto &fetch; }
$core[007123] = 04555; $code[007123] = *I07123; sub I07123 { $core[($ib<<12)+$core[109]] = 07124; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[007124] = 04524; $code[007124] = *I07124; sub I07124 { $core[($ib<<12)+$core[84]] = 07125; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[007125] = 04450; $code[007125] = *I07125; sub I07125 { $core[($ib<<12)+$core[40]] = 07126; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007126] = 07377; $code[007126] = *I07126; sub I07126 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[007127] = 04451; $code[007127] = *I07127; sub I07127 { $core[($ib<<12)+$core[41]] = 07130; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007130] = 07774; $code[007130] = *I07130; sub I07130 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007131] = 01043; $code[007131] = *I07131; sub I07131 { $lac += $core[000043]; goto &fetch; }
$core[007132] = 04774; $code[007132] = *I07132; sub I07132 { $core[($ib<<12)+$core[3708]] = 07133; $pc = ($ib<<12)+$core[3708]+1; $code[($ib<<12)+$core[3708]] = *emul8; $inh = 0; goto &fetch; }
$core[007133] = 04451; $code[007133] = *I07133; sub I07133 { $core[($ib<<12)+$core[41]] = 07134; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007134] = 07774; $code[007134] = *I07134; sub I07134 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007135] = 01034; $code[007135] = *I07135; sub I07135 { $lac += $core[000034]; goto &fetch; }
$core[007136] = 04774; $code[007136] = *I07136; sub I07136 { $core[($ib<<12)+$core[3708]] = 07137; $pc = ($ib<<12)+$core[3708]+1; $code[($ib<<12)+$core[3708]] = *emul8; $inh = 0; goto &fetch; }
$core[007137] = 04524; $code[007137] = *I07137; sub I07137 { $core[($ib<<12)+$core[84]] = 07140; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[007140] = 04450; $code[007140] = *I07140; sub I07140 { $core[($ib<<12)+$core[40]] = 07141; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007141] = 07514; $code[007141] = *I07141; sub I07141 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[007142] = 04451; $code[007142] = *I07142; sub I07142 { $core[($ib<<12)+$core[41]] = 07143; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007143] = 07755; $code[007143] = *I07143; sub I07143 { &emul8; goto &fetch; }
$core[007144] = 01036; $code[007144] = *I07144; sub I07144 { $lac += $core[000036]; goto &fetch; }
$core[007145] = 04774; $code[007145] = *I07145; sub I07145 { $core[($ib<<12)+$core[3708]] = 07146; $pc = ($ib<<12)+$core[3708]+1; $code[($ib<<12)+$core[3708]] = *emul8; $inh = 0; goto &fetch; }
$core[007146] = 04524; $code[007146] = *I07146; sub I07146 { $core[($ib<<12)+$core[84]] = 07147; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[007147] = 04450; $code[007147] = *I07147; sub I07147 { $core[($ib<<12)+$core[40]] = 07150; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007150] = 07403; $code[007150] = *I07150; sub I07150 { &emul8; goto &fetch; }
$core[007151] = 04451; $code[007151] = *I07151; sub I07151 { $core[($ib<<12)+$core[41]] = 07152; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007152] = 07774; $code[007152] = *I07152; sub I07152 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007153] = 01044; $code[007153] = *I07153; sub I07153 { $lac += $core[000044]; goto &fetch; }
$core[007154] = 04774; $code[007154] = *I07154; sub I07154 { $core[($ib<<12)+$core[3708]] = 07155; $pc = ($ib<<12)+$core[3708]+1; $code[($ib<<12)+$core[3708]] = *emul8; $inh = 0; goto &fetch; }
$core[007155] = 04451; $code[007155] = *I07155; sub I07155 { $core[($ib<<12)+$core[41]] = 07156; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007156] = 07774; $code[007156] = *I07156; sub I07156 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007157] = 01035; $code[007157] = *I07157; sub I07157 { $lac += $core[000035]; goto &fetch; }
$core[007160] = 04774; $code[007160] = *I07160; sub I07160 { $core[($ib<<12)+$core[3708]] = 07161; $pc = ($ib<<12)+$core[3708]+1; $code[($ib<<12)+$core[3708]] = *emul8; $inh = 0; goto &fetch; }
$core[007161] = 04524; $code[007161] = *I07161; sub I07161 { $core[($ib<<12)+$core[84]] = 07162; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[007162] = 04450; $code[007162] = *I07162; sub I07162 { $core[($ib<<12)+$core[40]] = 07163; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007163] = 07520; $code[007163] = *I07163; sub I07163 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[007164] = 04451; $code[007164] = *I07164; sub I07164 { $core[($ib<<12)+$core[41]] = 07165; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007165] = 07755; $code[007165] = *I07165; sub I07165 { &emul8; goto &fetch; }
$core[007166] = 01037; $code[007166] = *I07166; sub I07166 { $lac += $core[000037]; goto &fetch; }
$core[007167] = 04774; $code[007167] = *I07167; sub I07167 { $core[($ib<<12)+$core[3708]] = 07170; $pc = ($ib<<12)+$core[3708]+1; $code[($ib<<12)+$core[3708]] = *emul8; $inh = 0; goto &fetch; }
$core[007170] = 05706; $code[007170] = *I07170; sub I07170 { $pc = ($ib<<12)+$core[3654]; $inh = 0; goto &fetch; }
$core[007172] = 07204; $code[007172] = *P07172; sub P07172 { $lac &= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007173] = 06426; $code[007173] = *P07173; sub P07173 { &emul8; goto &fetch; }
$core[007174] = 07200; $code[007174] = *P07174; sub P07174 { $lac &= 010000; goto &fetch; }
$core[007175] = 05541; $code[007175] = *P07175; sub P07175 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[007176] = 07230; $code[007176] = *P07176; sub P07176 { $lac &= 010000; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007177] = 06733; $code[007177] = *P07177; sub P07177 { &emul8; goto &fetch; }
$core[007200] = 00000; $code[007200] = *S07200; sub S07200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007201] = 03106; $code[007201] = *I07201; sub I07201 { $core[000106] = $lac & 07777; $lac &= 010000; $code[000106] = *emul8; goto &fetch; }
$core[007202] = 04531; $code[007202] = *I07202; sub I07202 { $core[($ib<<12)+$core[89]] = 07203; $pc = ($ib<<12)+$core[89]+1; $code[($ib<<12)+$core[89]] = *emul8; $inh = 0; goto &fetch; }
$core[007203] = 05600; $code[007203] = *I07203; sub I07203 { $pc = ($ib<<12)+$core[3712]; $inh = 0; goto &fetch; }
$core[007204] = 00000; $code[007204] = *S07204; sub S07204 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007205] = 04525; $code[007205] = *I07205; sub I07205 { $core[($ib<<12)+$core[85]] = 07206; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[007206] = 04454; $code[007206] = *I07206; sub I07206 { $core[($ib<<12)+$core[44]] = 07207; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[007207] = 04450; $code[007207] = *I07207; sub I07207 { $core[($ib<<12)+$core[40]] = 07210; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007210] = 07527; $code[007210] = *I07210; sub I07210 { &emul8; goto &fetch; }
$core[007211] = 04451; $code[007211] = *I07211; sub I07211 { $core[($ib<<12)+$core[41]] = 07212; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007212] = 07772; $code[007212] = *I07212; sub I07212 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[007213] = 04450; $code[007213] = *I07213; sub I07213 { $core[($ib<<12)+$core[40]] = 07214; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007214] = 07504; $code[007214] = *I07214; sub I07214 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[007215] = 04454; $code[007215] = *I07215; sub I07215 { $core[($ib<<12)+$core[44]] = 07216; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[007216] = 04450; $code[007216] = *I07216; sub I07216 { $core[($ib<<12)+$core[40]] = 07217; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007217] = 07501; $code[007217] = *I07217; sub I07217 { &emul8; goto &fetch; }
$core[007220] = 04451; $code[007220] = *I07220; sub I07220 { $core[($ib<<12)+$core[41]] = 07221; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007221] = 07772; $code[007221] = *I07221; sub I07221 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[007222] = 04450; $code[007222] = *I07222; sub I07222 { $core[($ib<<12)+$core[40]] = 07223; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007223] = 07510; $code[007223] = *I07223; sub I07223 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007224] = 04454; $code[007224] = *I07224; sub I07224 { $core[($ib<<12)+$core[44]] = 07225; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[007225] = 04450; $code[007225] = *I07225; sub I07225 { $core[($ib<<12)+$core[40]] = 07226; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007226] = 07501; $code[007226] = *I07226; sub I07226 { &emul8; goto &fetch; }
$core[007227] = 05604; $code[007227] = *I07227; sub I07227 { $pc = ($ib<<12)+$core[3716]; $inh = 0; goto &fetch; }
$core[007230] = 00000; $code[007230] = *S07230; sub S07230 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007231] = 04525; $code[007231] = *I07231; sub I07231 { $core[($ib<<12)+$core[85]] = 07232; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[007232] = 04450; $code[007232] = *I07232; sub I07232 { $core[($ib<<12)+$core[40]] = 07233; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007233] = 07536; $code[007233] = *I07233; sub I07233 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[007234] = 04451; $code[007234] = *I07234; sub I07234 { $core[($ib<<12)+$core[41]] = 07235; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007235] = 07772; $code[007235] = *I07235; sub I07235 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[007236] = 01040; $code[007236] = *I07236; sub I07236 { $lac += $core[000040]; goto &fetch; }
$core[007237] = 04200; $code[007237] = *I07237; sub I07237 { $core[007200] = 07240; $pc = 007200+1; $code[007200] = *emul8; $inh = 0; goto &fetch; }
$core[007240] = 04455; $code[007240] = *D07240; sub D07240 { $core[($ib<<12)+$core[45]] = 07241; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[007241] = 01041; $code[007241] = *I07241; sub I07241 { $lac += $core[000041]; goto &fetch; }
$core[007242] = 04200; $code[007242] = *I07242; sub I07242 { $core[007200] = 07243; $pc = 007200+1; $code[007200] = *emul8; $inh = 0; goto &fetch; }
$core[007243] = 05630; $code[007243] = *I07243; sub I07243 { $pc = ($ib<<12)+$core[3736]; $inh = 0; goto &fetch; }
$core[007244] = 00000; $code[007244] = *I07244; sub I07244 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007245] = 00000; $code[007245] = *I07245; sub I07245 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007246] = 07777; $code[007246] = *I07246; sub I07246 { &emul8; goto &fetch; }
$core[007247] = 04000; $code[007247] = *I07247; sub I07247 { $core[000000] = 07250; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007250] = 07777; $code[007250] = *I07250; sub I07250 { &emul8; goto &fetch; }
$core[007251] = 00000; $code[007251] = *I07251; sub I07251 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007252] = 00000; $code[007252] = *L07252; sub L07252 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007253] = 07777; $code[007253] = *I07253; sub I07253 { &emul8; goto &fetch; }
$core[007254] = 07777; $code[007254] = *I07254; sub I07254 { &emul8; goto &fetch; }
$core[007255] = 00000; $code[007255] = *I07255; sub I07255 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007256] = 00000; $code[007256] = *I07256; sub I07256 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007257] = 00000; $code[007257] = *I07257; sub I07257 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007260] = 00000; $code[007260] = *I07260; sub I07260 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007261] = 00001; $code[007261] = *I07261; sub I07261 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007262] = 00002; $code[007262] = *I07262; sub I07262 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[007263] = 00000; $code[007263] = *I07263; sub I07263 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007264] = 03776; $code[007264] = *I07264; sub I07264 { $core[($df<<12)+$core[3838]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3838]] = *emul8; goto &fetch; }
$core[007265] = 03777; $code[007265] = *I07265; sub I07265 { $core[($df<<12)+$core[3839]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3839]] = *emul8; goto &fetch; }
$core[007266] = 04000; $code[007266] = *I07266; sub I07266 { $core[000000] = 07267; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007267] = 03777; $code[007267] = *I07267; sub I07267 { $core[($df<<12)+$core[3839]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3839]] = *emul8; goto &fetch; }
$core[007270] = 03776; $code[007270] = *I07270; sub I07270 { $core[($df<<12)+$core[3838]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3838]] = *emul8; goto &fetch; }
$core[007271] = 04000; $code[007271] = *I07271; sub I07271 { $core[000000] = 07272; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007272] = 04777; $code[007272] = *I07272; sub I07272 { $core[($ib<<12)+$core[3839]] = 07273; $pc = ($ib<<12)+$core[3839]+1; $code[($ib<<12)+$core[3839]] = *emul8; $inh = 0; goto &fetch; }
$core[007273] = 04776; $code[007273] = *I07273; sub I07273 { $core[($ib<<12)+$core[3838]] = 07274; $pc = ($ib<<12)+$core[3838]+1; $code[($ib<<12)+$core[3838]] = *emul8; $inh = 0; goto &fetch; }
$core[007274] = 00000; $code[007274] = *I07274; sub I07274 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007275] = 04776; $code[007275] = *I07275; sub I07275 { $core[($ib<<12)+$core[3838]] = 07276; $pc = ($ib<<12)+$core[3838]+1; $code[($ib<<12)+$core[3838]] = *emul8; $inh = 0; goto &fetch; }
$core[007276] = 04777; $code[007276] = *I07276; sub I07276 { $core[($ib<<12)+$core[3839]] = 07277; $pc = ($ib<<12)+$core[3839]+1; $code[($ib<<12)+$core[3839]] = *emul8; $inh = 0; goto &fetch; }
$core[007277] = 04000; $code[007277] = *I07277; sub I07277 { $core[000000] = 07300; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007300] = 07777; $code[007300] = *D07300; sub D07300 { &emul8; goto &fetch; }
$core[007301] = 03776; $code[007301] = *I07301; sub I07301 { $core[($df<<12)+$core[3838]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3838]] = *emul8; goto &fetch; }
$core[007302] = 00000; $code[007302] = *I07302; sub I07302 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007303] = 03776; $code[007303] = *I07303; sub I07303 { $core[($df<<12)+$core[3838]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3838]] = *emul8; goto &fetch; }
$core[007304] = 07777; $code[007304] = *I07304; sub I07304 { &emul8; goto &fetch; }
$core[007305] = 00000; $code[007305] = *I07305; sub I07305 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007306] = 07777; $code[007306] = *I07306; sub I07306 { &emul8; goto &fetch; }
$core[007307] = 07777; $code[007307] = *I07307; sub I07307 { &emul8; goto &fetch; }
$core[007310] = 04000; $code[007310] = *I07310; sub I07310 { $core[000000] = 07311; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007311] = 00000; $code[007311] = *I07311; sub I07311 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007312] = 00000; $code[007312] = *I07312; sub I07312 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007313] = 04000; $code[007313] = *I07313; sub I07313 { $core[000000] = 07314; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007314] = 02525; $code[007314] = *I07314; sub I07314 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[007315] = 05252; $code[007315] = *I07315; sub I07315 { $pc = 007252; $inh = 0; goto &fetch; }
$core[007316] = 00000; $code[007316] = *I07316; sub I07316 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007317] = 05252; $code[007317] = *I07317; sub I07317 { $pc = 007252; $inh = 0; goto &fetch; }
$core[007320] = 02525; $code[007320] = *I07320; sub I07320 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[007321] = 00000; $code[007321] = *I07321; sub I07321 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007322] = 07007; $code[007322] = *I07322; sub I07322 { $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007323] = 00770; $code[007323] = *I07323; sub I07323 { $lac &= (010000|$core[($df<<12)+$core[3832]]); goto &fetch; }
$core[007324] = 04000; $code[007324] = *I07324; sub I07324 { $core[000000] = 07325; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007325] = 00770; $code[007325] = *I07325; sub I07325 { $lac &= (010000|$core[($df<<12)+$core[3832]]); goto &fetch; }
$core[007326] = 07007; $code[007326] = *I07326; sub I07326 { $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007327] = 00000; $code[007327] = *I07327; sub I07327 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007330] = 00000; $code[007330] = *I07330; sub I07330 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007331] = 00000; $code[007331] = *I07331; sub I07331 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007332] = 00000; $code[007332] = *I07332; sub I07332 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007333] = 00000; $code[007333] = *I07333; sub I07333 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007334] = 04000; $code[007334] = *I07334; sub I07334 { $core[000000] = 07335; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007335] = 07777; $code[007335] = *I07335; sub I07335 { &emul8; goto &fetch; }
$core[007336] = 07777; $code[007336] = *I07336; sub I07336 { &emul8; goto &fetch; }
$core[007337] = 00000; $code[007337] = *I07337; sub I07337 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007340] = 00000; $code[007340] = *I07340; sub I07340 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007341] = 04000; $code[007341] = *I07341; sub I07341 { $core[000000] = 07342; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007342] = 00000; $code[007342] = *I07342; sub I07342 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007343] = 00000; $code[007343] = *I07343; sub I07343 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007344] = 07777; $code[007344] = *I07344; sub I07344 { &emul8; goto &fetch; }
$core[007345] = 07777; $code[007345] = *I07345; sub I07345 { &emul8; goto &fetch; }
$core[007346] = 00000; $code[007346] = *I07346; sub I07346 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007347] = 02525; $code[007347] = *I07347; sub I07347 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[007350] = 05252; $code[007350] = *D07350; sub D07350 { $pc = 007252; $inh = 0; goto &fetch; }
$core[007351] = 05252; $code[007351] = *I07351; sub I07351 { $pc = 007252; $inh = 0; goto &fetch; }
$core[007352] = 02525; $code[007352] = *I07352; sub I07352 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[007353] = 04000; $code[007353] = *I07353; sub I07353 { $core[000000] = 07354; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007354] = 05252; $code[007354] = *I07354; sub I07354 { $pc = 007252; $inh = 0; goto &fetch; }
$core[007355] = 02525; $code[007355] = *I07355; sub I07355 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[007356] = 02525; $code[007356] = *I07356; sub I07356 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[007357] = 05252; $code[007357] = *I07357; sub I07357 { $pc = 007252; $inh = 0; goto &fetch; }
$core[007360] = 04000; $code[007360] = *I07360; sub I07360 { $core[000000] = 07361; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007361] = 00770; $code[007361] = *I07361; sub I07361 { $lac &= (010000|$core[($df<<12)+$core[3832]]); goto &fetch; }
$core[007362] = 07007; $code[007362] = *I07362; sub I07362 { $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007363] = 07007; $code[007363] = *I07363; sub I07363 { $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007364] = 00770; $code[007364] = *I07364; sub I07364 { $lac &= (010000|$core[($df<<12)+$core[3832]]); goto &fetch; }
$core[007365] = 00000; $code[007365] = *I07365; sub I07365 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007366] = 07007; $code[007366] = *I07366; sub I07366 { $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007367] = 00770; $code[007367] = *I07367; sub I07367 { $lac &= (010000|$core[($df<<12)+$core[3832]]); goto &fetch; }
$core[007370] = 00770; $code[007370] = *P07370; sub P07370 { $lac &= (010000|$core[($df<<12)+$core[3832]]); goto &fetch; }
$core[007371] = 07007; $code[007371] = *I07371; sub I07371 { $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007372] = 00000; $code[007372] = *I07372; sub I07372 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007373] = 07777; $code[007373] = *I07373; sub I07373 { &emul8; goto &fetch; }
$core[007374] = 07777; $code[007374] = *I07374; sub I07374 { &emul8; goto &fetch; }
$core[007375] = 07777; $code[007375] = *I07375; sub I07375 { &emul8; goto &fetch; }
$core[007376] = 07777; $code[007376] = *P07376; sub P07376 { &emul8; goto &fetch; }
$core[007377] = 00350; $code[007377] = *P07377; sub P07377 { $lac &= (010000|$core[007350]); goto &fetch; }
$core[007400] = 00103; $code[007400] = *D07400; sub D07400 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[007401] = 05100; $code[007401] = *I07401; sub I07401 { $pc = 000100; $inh = 0; goto &fetch; }
$core[007402] = 00100; $code[007402] = *I07402; sub I07402 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007403] = 00350; $code[007403] = *I07403; sub I07403 { $lac &= (010000|$core[007550]); goto &fetch; }
$core[007404] = 01521; $code[007404] = *I07404; sub I07404 { $lac += $core[($df<<12)+$core[81]]; goto &fetch; }
$core[007405] = 05100; $code[007405] = *D07405; sub D07405 { $pc = 000100; $inh = 0; goto &fetch; }
$core[007406] = 00100; $code[007406] = *I07406; sub I07406 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007407] = 00350; $code[007407] = *I07407; sub I07407 { $lac &= (010000|$core[007550]); goto &fetch; }
$core[007410] = 01451; $code[007410] = *I07410; sub I07410 { $lac += $core[($df<<12)+$core[41]]; goto &fetch; }
$core[007411] = 00001; $code[007411] = *P07411; sub P07411 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007412] = 02022; $code[007412] = *I07412; sub I07412 { if (++$core[000022] == 010000) { $core[000022] = 0; $pc++; }$code[000022] = *emul8; goto &fetch; }
$core[007413] = 01702; $code[007413] = *I07413; sub I07413 { $lac += $core[($df<<12)+$core[3906]]; goto &fetch; }
$core[007414] = 01405; $code[007414] = *I07414; sub I07414 { $lac += $core[($df<<12)+$core[5]]; goto &fetch; }
$core[007415] = 01500; $code[007415] = *I07415; sub I07415 { $lac += $core[($df<<12)+$core[64]]; goto &fetch; }
$core[007416] = 00100; $code[007416] = *I07416; sub I07416 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007417] = 02311; $code[007417] = *P07417; sub P07417 { if (++$core[007511] == 010000) { $core[007511] = 0; $pc++; }$code[007511] = *emul8; goto &fetch; }
$core[007420] = 01525; $code[007420] = *I07420; sub I07420 { $lac += $core[($df<<12)+$core[85]]; goto &fetch; }
$core[007421] = 01401; $code[007421] = *D07421; sub D07421 { $lac += $core[($df<<12)+$core[1]]; goto &fetch; }
$core[007422] = 02405; $code[007422] = *I07422; sub I07422 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[007423] = 00400; $code[007423] = *I07423; sub I07423 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[007424] = 00100; $code[007424] = *I07424; sub I07424 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007425] = 00103; $code[007425] = *I07425; sub I07425 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[007426] = 02425; $code[007426] = *I07426; sub I07426 { if (++$core[($df<<12)+$core[21]] == 010000) { $core[($df<<12)+$core[21]] = 0; $pc++; }$code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[007427] = 00114; $code[007427] = *I07427; sub I07427 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[007430] = 00001; $code[007430] = *D07430; sub D07430 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007431] = 00350; $code[007431] = *I07431; sub I07431 { $lac &= (010000|$core[007550]); goto &fetch; }
$core[007432] = 02303; $code[007432] = *I07432; sub I07432 { if (++$core[007503] == 010000) { $core[007503] = 0; $pc++; }$code[007503] = *emul8; goto &fetch; }
$core[007433] = 05100; $code[007433] = *I07433; sub I07433 { $pc = 000100; $inh = 0; goto &fetch; }
$core[007434] = 00100; $code[007434] = *I07434; sub I07434 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007435] = 02310; $code[007435] = *I07435; sub I07435 { if (++$core[007510] == 010000) { $core[007510] = 0; $pc++; }$code[007510] = *emul8; goto &fetch; }
$core[007436] = 01400; $code[007436] = *I07436; sub I07436 { $lac += $core[($df<<12)+$core[0]]; goto &fetch; }
$core[007437] = 00100; $code[007437] = *I07437; sub I07437 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007440] = 02405; $code[007440] = *I07440; sub I07440 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[007441] = 02324; $code[007441] = *I07441; sub I07441 { if (++$core[007524] == 010000) { $core[007524] = 0; $pc++; }$code[007524] = *emul8; goto &fetch; }
$core[007442] = 00001; $code[007442] = *I07442; sub I07442 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007443] = 06000; $code[007443] = *I07443; sub I07443 { &emul8; goto &fetch; }
$core[007444] = 00100; $code[007444] = *I07444; sub I07444 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007445] = 06100; $code[007445] = *I07445; sub I07445 { &emul8; goto &fetch; }
$core[007446] = 00100; $code[007446] = *I07446; sub I07446 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007447] = 02310; $code[007447] = *I07447; sub I07447 { if (++$core[007510] == 010000) { $core[007510] = 0; $pc++; }$code[007510] = *emul8; goto &fetch; }
$core[007450] = 01106; $code[007450] = *I07450; sub I07450 { $lac += $core[000106]; goto &fetch; }
$core[007451] = 02423; $code[007451] = *I07451; sub I07451 { if (++$core[($df<<12)+$core[19]] == 010000) { $core[($df<<12)+$core[19]] = 0; $pc++; }$code[($df<<12)+$core[19]] = *emul8; goto &fetch; }
$core[007452] = 00001; $code[007452] = *I07452; sub I07452 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007453] = 01423; $code[007453] = *I07453; sub I07453 { $lac += $core[($df<<12)+$core[19]]; goto &fetch; }
$core[007454] = 02200; $code[007454] = *I07454; sub I07454 { if (++$core[007400] == 010000) { $core[007400] = 0; $pc++; }$code[007400] = *emul8; goto &fetch; }
$core[007455] = 00100; $code[007455] = *I07455; sub I07455 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007456] = 00350; $code[007456] = *I07456; sub I07456 { $lac &= (010000|$core[007550]); goto &fetch; }
$core[007457] = 00724; $code[007457] = *I07457; sub I07457 { $lac &= (010000|$core[($df<<12)+$core[3924]]); goto &fetch; }
$core[007460] = 05100; $code[007460] = *I07460; sub I07460 { $pc = 000100; $inh = 0; goto &fetch; }
$core[007461] = 00100; $code[007461] = *I07461; sub I07461 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007462] = 00123; $code[007462] = *I07462; sub I07462 { $lac &= (010000|$core[000123]); goto &fetch; }
$core[007463] = 02200; $code[007463] = *I07463; sub I07463 { if (++$core[007400] == 010000) { $core[007400] = 0; $pc++; }$code[007400] = *emul8; goto &fetch; }
$core[007464] = 00100; $code[007464] = *I07464; sub I07464 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007465] = 00420; $code[007465] = *I07465; sub I07465 { $lac &= (010000|$core[($df<<12)+$core[16]]); goto &fetch; }
$core[007466] = 02332; $code[007466] = *I07466; sub I07466 { if (++$core[007532] == 010000) { $core[007532] = 0; $pc++; }$code[007532] = *emul8; goto &fetch; }
$core[007467] = 00001; $code[007467] = *I07467; sub I07467 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007470] = 00420; $code[007470] = *I07470; sub I07470 { $lac &= (010000|$core[($df<<12)+$core[16]]); goto &fetch; }
$core[007471] = 01103; $code[007471] = *I07471; sub I07471 { $lac += $core[000103]; goto &fetch; }
$core[007472] = 00001; $code[007472] = *I07472; sub I07472 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007473] = 00403; $code[007473] = *I07473; sub I07473 { $lac &= (010000|$core[($df<<12)+$core[3]]); goto &fetch; }
$core[007474] = 01500; $code[007474] = *I07474; sub I07474 { $lac += $core[($df<<12)+$core[64]]; goto &fetch; }
$core[007475] = 00100; $code[007475] = *I07475; sub I07475 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007476] = 00401; $code[007476] = *I07476; sub I07476 { $lac &= (010000|$core[($df<<12)+$core[1]]); goto &fetch; }
$core[007477] = 00400; $code[007477] = *I07477; sub I07477 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[007500] = 00100; $code[007500] = *P07500; sub P07500 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007501] = 00423; $code[007501] = *D07501; sub D07501 { $lac &= (010000|$core[($df<<12)+$core[19]]); goto &fetch; }
$core[007502] = 02400; $code[007502] = *P07502; sub P07502 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[007503] = 00100; $code[007503] = *P07503; sub P07503 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007504] = 00205; $code[007504] = *I07504; sub I07504 { $lac &= (010000|$core[007405]); goto &fetch; }
$core[007505] = 00617; $code[007505] = *D07505; sub D07505 { $lac &= (010000|$core[($df<<12)+$core[3855]]); goto &fetch; }
$core[007506] = 02205; $code[007506] = *I07506; sub I07506 { if (++$core[007405] == 010000) { $core[007405] = 0; $pc++; }$code[007405] = *emul8; goto &fetch; }
$core[007507] = 00001; $code[007507] = *I07507; sub I07507 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007510] = 00106; $code[007510] = *D07510; sub D07510 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[007511] = 02405; $code[007511] = *D07511; sub D07511 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[007512] = 02200; $code[007512] = *I07512; sub I07512 { if (++$core[007400] == 010000) { $core[007400] = 0; $pc++; }$code[007400] = *emul8; goto &fetch; }
$core[007513] = 00100; $code[007513] = *D07513; sub D07513 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007514] = 00350; $code[007514] = *I07514; sub I07514 { $lac &= (010000|$core[007550]); goto &fetch; }
$core[007515] = 01523; $code[007515] = *I07515; sub I07515 { $lac += $core[($df<<12)+$core[83]]; goto &fetch; }
$core[007516] = 01051; $code[007516] = *I07516; sub I07516 { $lac += $core[000051]; goto &fetch; }
$core[007517] = 00001; $code[007517] = *I07517; sub I07517 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007520] = 00350; $code[007520] = *I07520; sub I07520 { $lac &= (010000|$core[007550]); goto &fetch; }
$core[007521] = 01423; $code[007521] = *I07521; sub I07521 { $lac += $core[($df<<12)+$core[19]]; goto &fetch; }
$core[007522] = 01051; $code[007522] = *I07522; sub I07522 { $lac += $core[000051]; goto &fetch; }
$core[007523] = 00001; $code[007523] = *I07523; sub I07523 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007524] = 02301; $code[007524] = *P07524; sub P07524 { if (++$core[007501] == 010000) { $core[007501] = 0; $pc++; }$code[007501] = *emul8; goto &fetch; }
$core[007525] = 01500; $code[007525] = *D07525; sub D07525 { $lac += $core[($df<<12)+$core[64]]; goto &fetch; }
$core[007526] = 00100; $code[007526] = *I07526; sub I07526 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007527] = 02205; $code[007527] = *I07527; sub I07527 { if (++$core[007405] == 010000) { $core[007405] = 0; $pc++; }$code[007405] = *emul8; goto &fetch; }
$core[007530] = 00700; $code[007530] = *I07530; sub I07530 { $lac &= (010000|$core[($df<<12)+$core[3904]]); goto &fetch; }
$core[007531] = 00100; $code[007531] = *I07531; sub I07531 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007532] = 01305; $code[007532] = *D07532; sub D07532 { $lac += $core[007505]; goto &fetch; }
$core[007533] = 07040; $code[007533] = *I07533; sub I07533 { $lac ^= 07777; goto &fetch; }
$core[007534] = 06100; $code[007534] = *I07534; sub I07534 { &emul8; goto &fetch; }
$core[007535] = 00100; $code[007535] = *I07535; sub I07535 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007536] = 02417; $code[007536] = *I07536; sub I07536 { $core[000017] = 0000 if ++$core[000017] == 010000; if (++$core[($df<<12)+$core[000017]] == 010000) { $core[($df<<12)+$core[000017]] = 0; $pc++; }$code[($df<<12)+$core[000017]] = *emul8; goto &fetch; }
$core[007537] = 04002; $code[007537] = *I07537; sub I07537 { $core[000002] = 07540; $pc = 000002+1; $code[000002] = *emul8; $inh = 0; goto &fetch; }
$core[007540] = 00540; $code[007540] = *P07540; sub P07540 { $lac &= (010000|$core[($df<<12)+$core[96]]); goto &fetch; }
$core[007541] = 00104; $code[007541] = *I07541; sub I07541 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[007542] = 00405; $code[007542] = *I07542; sub I07542 { $lac &= (010000|$core[($df<<12)+$core[5]]); goto &fetch; }
$core[007543] = 00400; $code[007543] = *I07543; sub I07543 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[007544] = 00100; $code[007544] = *I07544; sub I07544 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007545] = 02313; $code[007545] = *I07545; sub I07545 { if (++$core[007513] == 010000) { $core[007513] = 0; $pc++; }$code[007513] = *emul8; goto &fetch; }
$core[007546] = 01120; $code[007546] = *I07546; sub I07546 { $lac += $core[000120]; goto &fetch; }
$core[007547] = 04017; $code[007547] = *I07547; sub I07547 { $core[000017] = 07550; $pc = 000017+1; $code[000017] = *emul8; $inh = 0; goto &fetch; }
$core[007550] = 00303; $code[007550] = *D07550; sub D07550 { $lac &= (010000|$core[007503]); goto &fetch; }
$core[007551] = 02522; $code[007551] = *I07551; sub I07551 { if (++$core[($df<<12)+$core[82]] == 010000) { $core[($df<<12)+$core[82]] = 0; $pc++; }$code[($df<<12)+$core[82]] = *emul8; goto &fetch; }
$core[007552] = 00504; $code[007552] = *I07552; sub I07552 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[007553] = 00001; $code[007553] = *I07553; sub I07553 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007554] = 01617; $code[007554] = *I07554; sub I07554 { $lac += $core[($df<<12)+$core[3855]]; goto &fetch; }
$core[007555] = 04023; $code[007555] = *I07555; sub I07555 { $core[000023] = 07556; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[007556] = 01311; $code[007556] = *I07556; sub I07556 { $lac += $core[007511]; goto &fetch; }
$core[007557] = 02040; $code[007557] = *I07557; sub I07557 { if (++$core[000040] == 010000) { $core[000040] = 0; $pc++; }$code[000040] = *emul8; goto &fetch; }
$core[007560] = 01703; $code[007560] = *I07560; sub I07560 { $lac += $core[($df<<12)+$core[3907]]; goto &fetch; }
$core[007561] = 00325; $code[007561] = *I07561; sub I07561 { $lac &= (010000|$core[007525]); goto &fetch; }
$core[007562] = 02205; $code[007562] = *I07562; sub I07562 { if (++$core[007405] == 010000) { $core[007405] = 0; $pc++; }$code[007405] = *emul8; goto &fetch; }
$core[007563] = 00400; $code[007563] = *I07563; sub I07563 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[007564] = 00100; $code[007564] = *I07564; sub I07564 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[007565] = 02205; $code[007565] = *I07565; sub I07565 { if (++$core[007405] == 010000) { $core[007405] = 0; $pc++; }$code[007405] = *emul8; goto &fetch; }
$core[007566] = 00740; $code[007566] = *I07566; sub I07566 { $lac &= (010000|$core[($df<<12)+$core[3936]]); goto &fetch; }
$core[007567] = 01517; $code[007567] = *I07567; sub I07567 { $lac += $core[($df<<12)+$core[79]]; goto &fetch; }
$core[007570] = 00411; $code[007570] = *I07570; sub I07570 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac &= (010000|$core[($df<<12)+$core[000011]]); goto &fetch; }
$core[007571] = 00611; $code[007571] = *I07571; sub I07571 { $lac &= (010000|$core[($df<<12)+$core[3849]]); goto &fetch; }
$core[007572] = 00504; $code[007572] = *I07572; sub I07572 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[007573] = 00001; $code[007573] = *I07573; sub I07573 { $lac &= (010000|$core[000001]); goto &fetch; }
# End of compiled code.

#
# More boilerplate.

#
# Emulate the hard stuff:
#   IOT instructions.
#   Group 3 OPR instructions (dependent on mode A or B).
#   Code modified at runtime.
sub emul8 {
  # $pc has already been incremented by the caller.  Back it
  # up, and have a look at the instruction that got us here.
  $inst = $core[$pc-1];
  $op = $inst >> 9;
  if ($op < 6) {
    #
    # Operation refences memory
    # Note: Direct EA is always in the current field!
    $ea = $pc & 070000;
    $ea += $inst & 0177;
    $ea += $pc & 07600 if $inst & 0200; # Page bit set
    if ($inst & 0400) { # Indirect reference
      if (($ea&07770) == 0010) { # Autoindex
        $core[$ea] = 0000 if ++$core[$ea] == 010000;
      }
      if ($op < 4) {
        $ea = ($df<<12)+$core[$ea];
      } else {
        $ea = ($ib<<12)+$core[$ea];
      }
    }
    if ($op == 0) {
      $lac &= (010000|$core[$ea]);
    } elsif ($op == 1) {
      $lac += $core[$ea];
    } elsif ($op == 2) {
      if (++$core[$ea] == 010000) {
        $core[$ea] = 0; $pc++;
      }
      $code[$ea] = *emul8;
    } elsif ($op == 3) {
      $core[$ea] = $lac & 07777; $lac &= 010000;
      $code[$ea] = *emul8;
    } elsif ($op == 4) {
      $core[$ea] = $pc; $pc = $ea+1;
      $code[$ea] = *emul8;
      $inh = 0;
    } else { # $op == 5
      $pc = $ea;
      $inh = 0;
    }
  } elsif ($op == 6) {
    #
    # IOT -- hair ensues.
# BUGBUG: Should do more here.
    if (($inst&07770) == 06000) { # Interrupt control
      $pc += $ion, $ion = $ionn = 0 if ($inst&07) == 00; # SKON
      $ionn = 1 if ($inst&07) == 01; # ION
      $ion = $ionn = 0 if ($inst&07) == 02; # IOF
      $pc += $irq if ($inst&07) == 03; # SRQ
      $lac = ($lac&010000)+(($lac>>1)&04000)+($gt<<10)+($irq<<9)+($inh<<8)+($ion<<7)+$rif if ($inst&07) == 04; # GTF
      if (($inst&07) == 05) { # RTF
        # Contrary to documentation, RTF ignores IE and enables interrupts.
        ($l, $gt, $inh, $ionn, $rif) = ($lac&04000, !!($lac&02000), !!($lac&0400), 1|!!($lac&0200), $lac&0177);
        $lac = $l<<1 | ($lac&07777);
      }
      $pc += $gt if ($inst&07) == 06; # SGT
      $lac = $ion = $ionn = $ttof = $ttofn = $ttif = 0 if ($inst&07) == 07; # CAF
    } elsif (($inst&07700) == 06200) { # MMU
      $fld = ($inst>>3) & 07;
      if ($inst & 04) { # More decoding based on $fld
        $lac |= $df<<3 if $fld == 01; # RDF
        $lac |= $pc>>12 if $fld == 02; # RIF
        $lac |= $ib if $fld == 03; # RIB
        ($um, $ib, $df) = ($rif>>6, ($rif>>3)&07, $rif&07)if $fld == 04; # RMF
      } else { # $fld is new IB, DF, or both
        $df = $fld if $inst & 01; # CDF
        if ($inst & 02) { # CIF
          $ib = $fld; # Save for next JMP, JMS
          $inh = 1; # CIF sets inhibit to delay interrupts.
        }
      }
    } elsif (($inst&07770) == 06010) { # High spped reader
    } elsif (($inst&07770) == 06030) { # Keyboard device
      $ttif = 0 if $inst == 06030; # Clear input flag, no rrun
      $pc += $ttif if $inst & 01; # Skip if ready
      $lac &= 010000, $ttif = 0 if $inst & 02; # Clear flag, set rrun
      $lac |= $ttib if ($inst&05) == 04; # OR in the last character
      $ttie = $lac & 01 if ($inst&05) == 05; # TTY interrupt enable
    } elsif (($inst&07770) == 06040) { # Teleprinter device
      $ttof = $ttofn = 1 if $inst == 06040; # Set printer flag
      $pc += $ttof if $inst == 06041; # Skip if ready
      $ttof = $ttofn = 0 if $inst == 06042; # Clear flag
      if ($inst & 04) { # Output a character
        print pack("C", $lac&0177);
        $ttofn = 1;
      }
    } elsif (($inst&07770) == 06070) { # VC8/I
    } elsif (($inst&07770) == 06100) { # Memory Parity, Power Low
    } elsif (($inst&07740) == 06140) { # 6140-6177 LINC, Type 338 display
    } elsif (($inst&07770) == 06330) { # LAB-8
    } elsif (($inst&07770) == 06340) { # LAB-8
    } elsif (($inst&07760) == 06760) { # 6760-6777 DECTape
    } else {
      $inst = sprintf("%05o", $inst);
      warn "IOT $inst treated as NOP\r\n";
    }
  } else { # $op == 7
    # Must be an OPR.
    if (($inst & 0400) == 0000) {
      #
      # Group 1 -- shifts, clears, complements
      # These are clearest when printed in chronological order.
      # The timing is model dependent, with the PDP-8I having the
      # strictest ordering.
      $lac &= 010000 if $inst & 0200; # T1 CLA
      $lac &= 07777  if $inst & 0100; # T1 CLL
      $lac ^= 010000 if $inst & 0020; # T2 CML
      $lac ^= 07777  if $inst & 0040; # T2 CMA
      $lac++  if ($inst & 0001) == 001; # T3 IAC
      $lac = ($lac<<1) + (($lac>>12)&1) if ($inst & 0006) == 004; # T4 RAL
      $lac = ($lac<<2) + (($lac>>11)&3) if ($inst & 0006) == 006; # T4 RTL
      $lac = ($lac&017777>>1) + (($lac&1)<<12) if ($inst & 0012) == 010; # T4 RAR
      $lac = ($lac&017777>>2) + (($lac&3)<<11) if ($inst & 0012) == 012; # T4 RTR
      $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077) if ($inst & 0016) == 002; # T4 BSW
    } elsif (($inst & 0401) == 0400) {
      #
      # Group 2 -- Skips, hlt, read switches
      # These are clearest when printed in chronological order.
      # The timing here is not model dependent.
      $skp = 0  if ($inst & 0170) != 0000; # T1 may skip
      $skp = !($lac&07777)  if $inst & 0040; # T1 SZA
      $skp |= ($lac&04000)  if $inst & 0100; # T1 SMA
      $skp |= ($lac&010000) if $inst & 0020; # T1 SNL
      $skp = !$skp  if $inst & 0010; # T1 SKP
      $pc += $skp  if ($inst & 0170) != 0000; # T1 SKP
      $lac &= 010000 if $inst & 0200; # T2 CLA
      $lac |= $swr if ($inst & 0004); # T3 OSR
      $hlt = 1 if ($inst & 0002); # T4 HLT
    } else {
      #
      # Group 3 -- Extended Arithmetic Unit
      # Where to find the operand (if any) depends on the mode (A or B).
      $lac &= 010000 if $inst & 0200; # T1 CLA
      if (($inst & 0120) == 0100) {
        $lac |= $mq; # T2 MQA
      } elsif (($inst & 0120) == 0020) {
        $mq = $lac & 07777; # T2 MQL
        $lac &= 010000;
      } elsif (($inst & 0120) == 0120) {
        ($lac, $mq) = (($lac&010000)+$mq, $lac & 07777); # T2 SWP
      }
      if ($modeb) {
# BUGBUG: This EAE stuff is basically unimplemented as yet!
# BUGBUG: Fetch an operand from the instruction stream.
# Addresses in the next word.
    $inst = sprintf("%05o", $inst);
warn "EAE Mode B $inst treated as NOP";
      } else { # mode A
# BUGBUG: Fetch an operand from the instruction stream.
# Operands in the next word.
        $lac |= $sc if $inst & 0040; # T2 SCA
        if (($inst & 016) == 002) { # T3 SCL
          print '$sc = (~$core[++$pc]) & 037; ';
        } elsif (($inst & 016) == 004) { # T3 MUY
          ++$pc;
          print '($lac, $mq) = (($mq*$core[',$pc,']+$lac)>>12, ($mq*$core[',$pc,']+$lac)&07777; ';
        } elsif (($inst & 016) == 006) { # T3 DVI
          ++$pc;
          print '$lnktmp = $lac < $core[',$pc,']? 010000 : 0; $lac &= 07777; ';
          print '($lac, $mq) = (int(($lac<<12+$mq) / $core[',$pc,']), (($lac<<12+$mq) % $core[',$pc,'])); ';
          print '$lac += $lnktmp; '
        } elsif (($inst & 016) == 010) { # T3 NMI
        } elsif (($inst & 016) == 012) { # T3 SHL
        } elsif (($inst & 016) == 014) { # T3 ASR
        } elsif (($inst & 016) == 016) { # T3 LSR
        }
      }
    }
  }
  goto &fetch;
}

#
# The main execution loop.
sub fetch {
  # Return if we are halted
# $hlt = 1 if ++$vrs > 100000;
  return $lac if $hlt;
  # This cruft is here because interrupt based programs don't
  # necessarily poll the input device.
  # What we want is to allow (but not encourage) over-run, 
  # with the new character replacing the old.
  # Note that we don't get here at all until the program
  # asks about keyboard ready..
  $ttit = ReadKey(-1); # Get a character, if any.
  if (defined $ttit) {
    $ttib = 0200 | ord($ttit); # Remember the character
    $ttif = 1; # ... and set the flag.
    if ($ttib == 0205) { # Type ^E to hlt
      ReadMode 'normal';
      $hlt++;
    }
  }
  $irq = ($ttie&$ttof) | ($ttie&$ttif); # TODO: OR in others here too.
  if ($ion && !$inh) {
    # Interrupts are allowed, so do them.
    if ($irq) {
      # Interrupt does a JMS 00000.
      # BUGBUG: Should fiddle with extended memory here.
      $rib = ($um<<6)+($lac>>9)+$df;
      $core[00000] = $pc& 07777;
      $pc = 00001;
      $ion = $ionn = 0;
    } 
  } 
  $ion = $ionn; # Allow one instruction after ION.
  $ttof = $ttofn; # Allow at least one after TLS, before interrupt.
  if ($trace) {
    $txt = sprintf("%05o %04o %02o %05o:%04o\r\n", $lac, $mq, $sc, $pc, $core[$pc]);
    warn $txt;
  }
  *verb = $code[$pc++];
  goto &verb;
}
#
# Start things up!
&fetch(); 
#
# Return means a HLT was done.
ReadMode 'normal';
exit $lac&07777; 

