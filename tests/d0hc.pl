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
$core[000001] = 05001; $code[000001] = *L00001; sub L00001 { $pc = 000001; $inh = 0; goto &fetch; }
$core[000002] = 00002; $code[000002] = *D00002; sub D00002 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000003] = 00003; $code[000003] = *D00003; sub D00003 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000004] = 00000; $code[000004] = *D00004; sub D00004 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000005] = 00000; $code[000005] = *D00005; sub D00005 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000006] = 07640; $code[000006] = *I00006; sub I00006 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000007] = 05534; $code[000007] = *D00007; sub D00007 { $pc = ($ib<<12)+$core[92]; $inh = 0; goto &fetch; }
$core[000010] = 01115; $code[000010] = *L00010; sub L00010 { $lac += $core[000115]; goto &fetch; }
$core[000011] = 03517; $code[000011] = *I00011; sub I00011 { $core[($df<<12)+$core[79]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[79]] = *emul8; goto &fetch; }
$core[000012] = 01115; $code[000012] = *D00012; sub D00012 { $lac += $core[000115]; goto &fetch; }
$core[000013] = 03520; $code[000013] = *I00013; sub I00013 { $core[($df<<12)+$core[80]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[80]] = *emul8; goto &fetch; }
$core[000014] = 03000; $code[000014] = *I00014; sub I00014 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000015] = 07001; $code[000015] = *D00015; sub D00015 { $lac++; goto &fetch; }
$core[000016] = 01140; $code[000016] = *I00016; sub I00016 { $lac += $core[000140]; goto &fetch; }
$core[000017] = 03140; $code[000017] = *I00017; sub I00017 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[000020] = 01140; $code[000020] = *D00020; sub D00020 { $lac += $core[000140]; goto &fetch; }
$core[000021] = 07640; $code[000021] = *I00021; sub I00021 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000022] = 05027; $code[000022] = *I00022; sub I00022 { $pc = 000027; $inh = 0; goto &fetch; }
$core[000023] = 05424; $code[000023] = *I00023; sub I00023 { $pc = ($ib<<12)+$core[20]; $inh = 0; goto &fetch; }
$core[000024] = 00316; $code[000024] = *P00024; sub P00024 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[000025] = 01142; $code[000025] = *L00025; sub L00025 { $lac += $core[000142]; goto &fetch; }
$core[000026] = 03141; $code[000026] = *I00026; sub I00026 { $core[000141] = $lac & 07777; $lac &= 010000; $code[000141] = *emul8; goto &fetch; }
$core[000027] = 07604; $code[000027] = *L00027; sub L00027 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000030] = 07004; $code[000030] = *I00030; sub I00030 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000031] = 07006; $code[000031] = *I00031; sub I00031 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000032] = 07630; $code[000032] = *I00032; sub I00032 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000033] = 05057; $code[000033] = *I00033; sub I00033 { $pc = 000057; $inh = 0; goto &fetch; }
$core[000034] = 01121; $code[000034] = *L00034; sub L00034 { $lac += $core[000121]; goto &fetch; }
$core[000035] = 07104; $code[000035] = *I00035; sub I00035 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000036] = 07430; $code[000036] = *I00036; sub I00036 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000037] = 01122; $code[000037] = *I00037; sub I00037 { $lac += $core[000122]; goto &fetch; }
$core[000040] = 03121; $code[000040] = *D00040; sub D00040 { $core[000121] = $lac & 07777; $lac &= 010000; $code[000121] = *emul8; goto &fetch; }
$core[000041] = 07100; $code[000041] = *I00041; sub I00041 { $lac &= 07777; goto &fetch; }
$core[000042] = 01121; $code[000042] = *I00042; sub I00042 { $lac += $core[000121]; goto &fetch; }
$core[000043] = 01124; $code[000043] = *I00043; sub I00043 { $lac += $core[000124]; goto &fetch; }
$core[000044] = 07630; $code[000044] = *I00044; sub I00044 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000045] = 05034; $code[000045] = *I00045; sub I00045 { $pc = 000034; $inh = 0; goto &fetch; }
$core[000046] = 01121; $code[000046] = *I00046; sub I00046 { $lac += $core[000121]; goto &fetch; }
$core[000047] = 01123; $code[000047] = *I00047; sub I00047 { $lac += $core[000123]; goto &fetch; }
$core[000050] = 07620; $code[000050] = *I00050; sub I00050 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000051] = 05034; $code[000051] = *I00051; sub I00051 { $pc = 000034; $inh = 0; goto &fetch; }
$core[000052] = 01121; $code[000052] = *I00052; sub I00052 { $lac += $core[000121]; goto &fetch; }
$core[000053] = 03117; $code[000053] = *I00053; sub I00053 { $core[000117] = $lac & 07777; $lac &= 010000; $code[000117] = *emul8; goto &fetch; }
$core[000054] = 07040; $code[000054] = *I00054; sub I00054 { $lac ^= 07777; goto &fetch; }
$core[000055] = 01117; $code[000055] = *I00055; sub I00055 { $lac += $core[000117]; goto &fetch; }
$core[000056] = 03120; $code[000056] = *I00056; sub I00056 { $core[000120] = $lac & 07777; $lac &= 010000; $code[000120] = *emul8; goto &fetch; }
$core[000057] = 07604; $code[000057] = *L00057; sub L00057 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000060] = 07006; $code[000060] = *D00060; sub D00060 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000061] = 07006; $code[000061] = *I00061; sub I00061 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000062] = 07630; $code[000062] = *I00062; sub I00062 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000063] = 05104; $code[000063] = *I00063; sub I00063 { $pc = 000104; $inh = 0; goto &fetch; }
$core[000064] = 01121; $code[000064] = *L00064; sub L00064 { $lac += $core[000121]; goto &fetch; }
$core[000065] = 07104; $code[000065] = *I00065; sub I00065 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000066] = 07430; $code[000066] = *I00066; sub I00066 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000067] = 01122; $code[000067] = *I00067; sub I00067 { $lac += $core[000122]; goto &fetch; }
$core[000070] = 03121; $code[000070] = *I00070; sub I00070 { $core[000121] = $lac & 07777; $lac &= 010000; $code[000121] = *emul8; goto &fetch; }
$core[000071] = 07100; $code[000071] = *I00071; sub I00071 { $lac &= 07777; goto &fetch; }
$core[000072] = 01121; $code[000072] = *I00072; sub I00072 { $lac += $core[000121]; goto &fetch; }
$core[000073] = 01124; $code[000073] = *I00073; sub I00073 { $lac += $core[000124]; goto &fetch; }
$core[000074] = 07630; $code[000074] = *I00074; sub I00074 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000075] = 05064; $code[000075] = *D00075; sub D00075 { $pc = 000064; $inh = 0; goto &fetch; }
$core[000076] = 01121; $code[000076] = *I00076; sub I00076 { $lac += $core[000121]; goto &fetch; }
$core[000077] = 01123; $code[000077] = *I00077; sub I00077 { $lac += $core[000123]; goto &fetch; }
$core[000100] = 07620; $code[000100] = *I00100; sub I00100 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000101] = 05064; $code[000101] = *I00101; sub I00101 { $pc = 000064; $inh = 0; goto &fetch; }
$core[000102] = 01121; $code[000102] = *I00102; sub I00102 { $lac += $core[000121]; goto &fetch; }
$core[000103] = 03116; $code[000103] = *I00103; sub I00103 { $core[000116] = $lac & 07777; $lac &= 010000; $code[000116] = *emul8; goto &fetch; }
$core[000104] = 01125; $code[000104] = *L00104; sub L00104 { $lac += $core[000125]; goto &fetch; }
$core[000105] = 03517; $code[000105] = *I00105; sub I00105 { $core[($df<<12)+$core[79]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[79]] = *emul8; goto &fetch; }
$core[000106] = 01126; $code[000106] = *D00106; sub D00106 { $lac += $core[000126]; goto &fetch; }
$core[000107] = 03520; $code[000107] = *I00107; sub I00107 { $core[($df<<12)+$core[80]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[80]] = *emul8; goto &fetch; }
$core[000110] = 06041; $code[000110] = *I00110; sub I00110 { &emul8; goto &fetch; }
$core[000111] = 06046; $code[000111] = *I00111; sub I00111 { &emul8; goto &fetch; }
$core[000112] = 06041; $code[000112] = *L00112; sub L00112 { &emul8; goto &fetch; }
$core[000113] = 05112; $code[000113] = *I00113; sub I00113 { $pc = 000112; $inh = 0; goto &fetch; }
$core[000114] = 05520; $code[000114] = *I00114; sub I00114 { $pc = ($ib<<12)+$core[80]; $inh = 0; goto &fetch; }
$core[000115] = 07402; $code[000115] = *D00115; sub D00115 { $hlt = 1; goto &fetch; }
$core[000116] = 00000; $code[000116] = *P00116; sub P00116 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000117] = 00000; $code[000117] = *P00117; sub P00117 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000120] = 00000; $code[000120] = *P00120; sub P00120 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000121] = 02525; $code[000121] = *D00121; sub D00121 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[000122] = 00003; $code[000122] = *D00122; sub D00122 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000123] = 07400; $code[000123] = *D00123; sub D00123 { goto &fetch; }
$core[000124] = 00200; $code[000124] = *D00124; sub D00124 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000125] = 05516; $code[000125] = *P00125; sub P00125 { $pc = ($ib<<12)+$core[78]; $inh = 0; goto &fetch; }
$core[000126] = 06001; $code[000126] = *D00126; sub D00126 { &emul8; goto &fetch; }
$core[000127] = 00260; $code[000127] = *D00127; sub D00127 { $lac &= (010000|$core[000060]); goto &fetch; }
$core[000130] = 00007; $code[000130] = *D00130; sub D00130 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000131] = 00000; $code[000131] = *D00131; sub D00131 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000132] = 00000; $code[000132] = *D00132; sub D00132 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000133] = 00000; $code[000133] = *D00133; sub D00133 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000134] = 00220; $code[000134] = *P00134; sub P00134 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[000135] = 00000; $code[000135] = *P00135; sub P00135 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000136] = 07571; $code[000136] = *D00136; sub D00136 { &emul8; goto &fetch; }
$core[000137] = 00143; $code[000137] = *D00137; sub D00137 { $lac &= (010000|$core[000143]); goto &fetch; }
$core[000140] = 00000; $code[000140] = *D00140; sub D00140 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000141] = 00000; $code[000141] = *D00141; sub D00141 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000142] = 07761; $code[000142] = *D00142; sub D00142 { &emul8; goto &fetch; }
$core[000143] = 00215; $code[000143] = *D00143; sub D00143 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000144] = 00212; $code[000144] = *I00144; sub I00144 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000145] = 00212; $code[000145] = *I00145; sub I00145 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000146] = 00306; $code[000146] = *I00146; sub I00146 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[000147] = 00240; $code[000147] = *I00147; sub I00147 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000150] = 00000; $code[000150] = *D00150; sub D00150 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000151] = 00000; $code[000151] = *D00151; sub D00151 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000152] = 00000; $code[000152] = *D00152; sub D00152 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000153] = 00000; $code[000153] = *D00153; sub D00153 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000154] = 00240; $code[000154] = *I00154; sub I00154 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000155] = 00324; $code[000155] = *I00155; sub I00155 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[000156] = 00240; $code[000156] = *I00156; sub I00156 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000157] = 00000; $code[000157] = *D00157; sub D00157 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000160] = 00000; $code[000160] = *D00160; sub D00160 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000161] = 00000; $code[000161] = *D00161; sub D00161 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000162] = 00000; $code[000162] = *D00162; sub D00162 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000163] = 00215; $code[000163] = *I00163; sub I00163 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000164] = 00212; $code[000164] = *I00164; sub I00164 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000165] = 00377; $code[000165] = *I00165; sub I00165 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[000166] = 00332; $code[000166] = *I00166; sub I00166 { $lac &= (010000|$core[000132]); goto &fetch; }
$core[000167] = 00240; $code[000167] = *I00167; sub I00167 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000170] = 00275; $code[000170] = *I00170; sub I00170 { $lac &= (010000|$core[000075]); goto &fetch; }
$core[000171] = 00240; $code[000171] = *I00171; sub I00171 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000172] = 00000; $code[000172] = *D00172; sub D00172 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000173] = 00000; $code[000173] = *D00173; sub D00173 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000174] = 00000; $code[000174] = *D00174; sub D00174 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000175] = 00000; $code[000175] = *D00175; sub D00175 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000176] = 00207; $code[000176] = *I00176; sub I00176 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000200] = 05770; $code[000200] = *L00200; sub L00200 { $pc = ($ib<<12)+$core[248]; $inh = 0; goto &fetch; }
$core[000201] = 07041; $code[000201] = *I00201; sub I00201 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000202] = 03116; $code[000202] = *I00202; sub I00202 { $core[000116] = $lac & 07777; $lac &= 010000; $code[000116] = *emul8; goto &fetch; }
$core[000203] = 01115; $code[000203] = *L00203; sub L00203 { $lac += $core[000115]; goto &fetch; }
$core[000204] = 03516; $code[000204] = *I00204; sub I00204 { $core[($df<<12)+$core[78]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[78]] = *emul8; goto &fetch; }
$core[000205] = 01116; $code[000205] = *I00205; sub I00205 { $lac += $core[000116]; goto &fetch; }
$core[000206] = 07001; $code[000206] = *I00206; sub I00206 { $lac++; goto &fetch; }
$core[000207] = 03116; $code[000207] = *I00207; sub I00207 { $core[000116] = $lac & 07777; $lac &= 010000; $code[000116] = *emul8; goto &fetch; }
$core[000210] = 01116; $code[000210] = *I00210; sub I00210 { $lac += $core[000116]; goto &fetch; }
$core[000211] = 01124; $code[000211] = *I00211; sub I00211 { $lac += $core[000124]; goto &fetch; }
$core[000212] = 07640; $code[000212] = *D00212; sub D00212 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000213] = 05203; $code[000213] = *I00213; sub I00213 { $pc = 000203; $inh = 0; goto &fetch; }
$core[000214] = 01367; $code[000214] = *I00214; sub I00214 { $lac += $core[000367]; goto &fetch; }
$core[000215] = 03141; $code[000215] = *D00215; sub D00215 { $core[000141] = $lac & 07777; $lac &= 010000; $code[000141] = *emul8; goto &fetch; }
$core[000216] = 03140; $code[000216] = *I00216; sub I00216 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[000217] = 05027; $code[000217] = *I00217; sub I00217 { $pc = 000027; $inh = 0; goto &fetch; }
$core[000220] = 01117; $code[000220] = *L00220; sub L00220 { $lac += $core[000117]; goto &fetch; }
$core[000221] = 04341; $code[000221] = *I00221; sub I00221 { $core[000341] = 00222; $pc = 000341+1; $code[000341] = *emul8; $inh = 0; goto &fetch; }
$core[000222] = 03150; $code[000222] = *I00222; sub I00222 { $core[000150] = $lac & 07777; $lac &= 010000; $code[000150] = *emul8; goto &fetch; }
$core[000223] = 01131; $code[000223] = *I00223; sub I00223 { $lac += $core[000131]; goto &fetch; }
$core[000224] = 00130; $code[000224] = *I00224; sub I00224 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000225] = 01127; $code[000225] = *I00225; sub I00225 { $lac += $core[000127]; goto &fetch; }
$core[000226] = 03151; $code[000226] = *I00226; sub I00226 { $core[000151] = $lac & 07777; $lac &= 010000; $code[000151] = *emul8; goto &fetch; }
$core[000227] = 01132; $code[000227] = *I00227; sub I00227 { $lac += $core[000132]; goto &fetch; }
$core[000230] = 00130; $code[000230] = *I00230; sub I00230 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000231] = 01127; $code[000231] = *I00231; sub I00231 { $lac += $core[000127]; goto &fetch; }
$core[000232] = 03152; $code[000232] = *I00232; sub I00232 { $core[000152] = $lac & 07777; $lac &= 010000; $code[000152] = *emul8; goto &fetch; }
$core[000233] = 01133; $code[000233] = *I00233; sub I00233 { $lac += $core[000133]; goto &fetch; }
$core[000234] = 00130; $code[000234] = *I00234; sub I00234 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000235] = 01127; $code[000235] = *I00235; sub I00235 { $lac += $core[000127]; goto &fetch; }
$core[000236] = 03153; $code[000236] = *I00236; sub I00236 { $core[000153] = $lac & 07777; $lac &= 010000; $code[000153] = *emul8; goto &fetch; }
$core[000237] = 01116; $code[000237] = *I00237; sub I00237 { $lac += $core[000116]; goto &fetch; }
$core[000240] = 04341; $code[000240] = *I00240; sub I00240 { $core[000341] = 00241; $pc = 000341+1; $code[000341] = *emul8; $inh = 0; goto &fetch; }
$core[000241] = 03157; $code[000241] = *I00241; sub I00241 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[000242] = 01131; $code[000242] = *I00242; sub I00242 { $lac += $core[000131]; goto &fetch; }
$core[000243] = 00130; $code[000243] = *I00243; sub I00243 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000244] = 01127; $code[000244] = *I00244; sub I00244 { $lac += $core[000127]; goto &fetch; }
$core[000245] = 03160; $code[000245] = *I00245; sub I00245 { $core[000160] = $lac & 07777; $lac &= 010000; $code[000160] = *emul8; goto &fetch; }
$core[000246] = 01132; $code[000246] = *I00246; sub I00246 { $lac += $core[000132]; goto &fetch; }
$core[000247] = 00130; $code[000247] = *I00247; sub I00247 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000250] = 01127; $code[000250] = *I00250; sub I00250 { $lac += $core[000127]; goto &fetch; }
$core[000251] = 03161; $code[000251] = *I00251; sub I00251 { $core[000161] = $lac & 07777; $lac &= 010000; $code[000161] = *emul8; goto &fetch; }
$core[000252] = 01133; $code[000252] = *I00252; sub I00252 { $lac += $core[000133]; goto &fetch; }
$core[000253] = 00130; $code[000253] = *I00253; sub I00253 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000254] = 01127; $code[000254] = *I00254; sub I00254 { $lac += $core[000127]; goto &fetch; }
$core[000255] = 03162; $code[000255] = *I00255; sub I00255 { $core[000162] = $lac & 07777; $lac &= 010000; $code[000162] = *emul8; goto &fetch; }
$core[000256] = 01000; $code[000256] = *I00256; sub I00256 { $lac += $core[000000]; goto &fetch; }
$core[000257] = 04341; $code[000257] = *I00257; sub I00257 { $core[000341] = 00260; $pc = 000341+1; $code[000341] = *emul8; $inh = 0; goto &fetch; }
$core[000260] = 03172; $code[000260] = *I00260; sub I00260 { $core[000172] = $lac & 07777; $lac &= 010000; $code[000172] = *emul8; goto &fetch; }
$core[000261] = 01131; $code[000261] = *I00261; sub I00261 { $lac += $core[000131]; goto &fetch; }
$core[000262] = 00130; $code[000262] = *I00262; sub I00262 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000263] = 01127; $code[000263] = *I00263; sub I00263 { $lac += $core[000127]; goto &fetch; }
$core[000264] = 03173; $code[000264] = *I00264; sub I00264 { $core[000173] = $lac & 07777; $lac &= 010000; $code[000173] = *emul8; goto &fetch; }
$core[000265] = 01132; $code[000265] = *I00265; sub I00265 { $lac += $core[000132]; goto &fetch; }
$core[000266] = 00130; $code[000266] = *I00266; sub I00266 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000267] = 01127; $code[000267] = *I00267; sub I00267 { $lac += $core[000127]; goto &fetch; }
$core[000270] = 03174; $code[000270] = *I00270; sub I00270 { $core[000174] = $lac & 07777; $lac &= 010000; $code[000174] = *emul8; goto &fetch; }
$core[000271] = 01133; $code[000271] = *I00271; sub I00271 { $lac += $core[000133]; goto &fetch; }
$core[000272] = 00130; $code[000272] = *I00272; sub I00272 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000273] = 01127; $code[000273] = *I00273; sub I00273 { $lac += $core[000127]; goto &fetch; }
$core[000274] = 03175; $code[000274] = *I00274; sub I00274 { $core[000175] = $lac & 07777; $lac &= 010000; $code[000175] = *emul8; goto &fetch; }
$core[000275] = 01137; $code[000275] = *I00275; sub I00275 { $lac += $core[000137]; goto &fetch; }
$core[000276] = 03135; $code[000276] = *I00276; sub I00276 { $core[000135] = $lac & 07777; $lac &= 010000; $code[000135] = *emul8; goto &fetch; }
$core[000277] = 01535; $code[000277] = *L00277; sub L00277 { $lac += $core[($df<<12)+$core[93]]; goto &fetch; }
$core[000300] = 06046; $code[000300] = *I00300; sub I00300 { &emul8; goto &fetch; }
$core[000301] = 06041; $code[000301] = *L00301; sub L00301 { &emul8; goto &fetch; }
$core[000302] = 05301; $code[000302] = *I00302; sub I00302 { $pc = 000301; $inh = 0; goto &fetch; }
$core[000303] = 07201; $code[000303] = *D00303; sub D00303 { $lac &= 010000; $lac++; goto &fetch; }
$core[000304] = 01135; $code[000304] = *I00304; sub I00304 { $lac += $core[000135]; goto &fetch; }
$core[000305] = 03135; $code[000305] = *I00305; sub I00305 { $core[000135] = $lac & 07777; $lac &= 010000; $code[000135] = *emul8; goto &fetch; }
$core[000306] = 01535; $code[000306] = *I00306; sub I00306 { $lac += $core[($df<<12)+$core[93]]; goto &fetch; }
$core[000307] = 01136; $code[000307] = *I00307; sub I00307 { $lac += $core[000136]; goto &fetch; }
$core[000310] = 07640; $code[000310] = *D00310; sub D00310 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000311] = 05277; $code[000311] = *I00311; sub I00311 { $pc = 000277; $inh = 0; goto &fetch; }
$core[000312] = 07604; $code[000312] = *I00312; sub I00312 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000313] = 07700; $code[000313] = *I00313; sub I00313 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000314] = 07402; $code[000314] = *I00314; sub I00314 { $hlt = 1; goto &fetch; }
$core[000315] = 05010; $code[000315] = *I00315; sub I00315 { $pc = 000010; $inh = 0; goto &fetch; }
$core[000316] = 01141; $code[000316] = *L00316; sub L00316 { $lac += $core[000141]; goto &fetch; }
$core[000317] = 07001; $code[000317] = *I00317; sub I00317 { $lac++; goto &fetch; }
$core[000320] = 03141; $code[000320] = *I00320; sub I00320 { $core[000141] = $lac & 07777; $lac &= 010000; $code[000141] = *emul8; goto &fetch; }
$core[000321] = 01141; $code[000321] = *I00321; sub I00321 { $lac += $core[000141]; goto &fetch; }
$core[000322] = 07640; $code[000322] = *I00322; sub I00322 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000323] = 05027; $code[000323] = *I00323; sub I00323 { $pc = 000027; $inh = 0; goto &fetch; }
$core[000324] = 01361; $code[000324] = *I00324; sub I00324 { $lac += $core[000361]; goto &fetch; }
$core[000325] = 03135; $code[000325] = *I00325; sub I00325 { $core[000135] = $lac & 07777; $lac &= 010000; $code[000135] = *emul8; goto &fetch; }
$core[000326] = 01135; $code[000326] = *L00326; sub L00326 { $lac += $core[000135]; goto &fetch; }
$core[000327] = 07001; $code[000327] = *I00327; sub I00327 { $lac++; goto &fetch; }
$core[000330] = 03135; $code[000330] = *I00330; sub I00330 { $core[000135] = $lac & 07777; $lac &= 010000; $code[000135] = *emul8; goto &fetch; }
$core[000331] = 01535; $code[000331] = *I00331; sub I00331 { $lac += $core[($df<<12)+$core[93]]; goto &fetch; }
$core[000332] = 06046; $code[000332] = *I00332; sub I00332 { &emul8; goto &fetch; }
$core[000333] = 06041; $code[000333] = *L00333; sub L00333 { &emul8; goto &fetch; }
$core[000334] = 05333; $code[000334] = *I00334; sub I00334 { $pc = 000333; $inh = 0; goto &fetch; }
$core[000335] = 01366; $code[000335] = *I00335; sub I00335 { $lac += $core[000366]; goto &fetch; }
$core[000336] = 07640; $code[000336] = *I00336; sub I00336 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000337] = 05326; $code[000337] = *I00337; sub I00337 { $pc = 000326; $inh = 0; goto &fetch; }
$core[000340] = 05025; $code[000340] = *I00340; sub I00340 { $pc = 000025; $inh = 0; goto &fetch; }
$core[000341] = 00000; $code[000341] = *S00341; sub S00341 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000342] = 03133; $code[000342] = *I00342; sub I00342 { $core[000133] = $lac & 07777; $lac &= 010000; $code[000133] = *emul8; goto &fetch; }
$core[000343] = 01133; $code[000343] = *I00343; sub I00343 { $lac += $core[000133]; goto &fetch; }
$core[000344] = 07012; $code[000344] = *I00344; sub I00344 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000345] = 07010; $code[000345] = *I00345; sub I00345 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000346] = 03132; $code[000346] = *I00346; sub I00346 { $core[000132] = $lac & 07777; $lac &= 010000; $code[000132] = *emul8; goto &fetch; }
$core[000347] = 01132; $code[000347] = *I00347; sub I00347 { $lac += $core[000132]; goto &fetch; }
$core[000350] = 07012; $code[000350] = *I00350; sub I00350 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000351] = 07010; $code[000351] = *I00351; sub I00351 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000352] = 03131; $code[000352] = *I00352; sub I00352 { $core[000131] = $lac & 07777; $lac &= 010000; $code[000131] = *emul8; goto &fetch; }
$core[000353] = 01131; $code[000353] = *I00353; sub I00353 { $lac += $core[000131]; goto &fetch; }
$core[000354] = 07012; $code[000354] = *I00354; sub I00354 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000355] = 07010; $code[000355] = *I00355; sub I00355 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000356] = 00130; $code[000356] = *I00356; sub I00356 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000357] = 01127; $code[000357] = *I00357; sub I00357 { $lac += $core[000127]; goto &fetch; }
$core[000360] = 05741; $code[000360] = *I00360; sub I00360 { $pc = ($ib<<12)+$core[225]; $inh = 0; goto &fetch; }
$core[000361] = 00361; $code[000361] = *D00361; sub D00361 { $lac &= (010000|$core[000361]); goto &fetch; }
$core[000362] = 00215; $code[000362] = *I00362; sub I00362 { $lac &= (010000|$core[000215]); goto &fetch; }
$core[000363] = 00212; $code[000363] = *I00363; sub I00363 { $lac &= (010000|$core[000212]); goto &fetch; }
$core[000364] = 00310; $code[000364] = *I00364; sub I00364 { $lac &= (010000|$core[000310]); goto &fetch; }
$core[000365] = 00303; $code[000365] = *I00365; sub I00365 { $lac &= (010000|$core[000303]); goto &fetch; }
$core[000366] = 07475; $code[000366] = *D00366; sub D00366 { &emul8; goto &fetch; }
$core[000367] = 07763; $code[000367] = *D00367; sub D00367 { &emul8; goto &fetch; }
$core[000370] = 00400; $code[000370] = *P00370; sub P00370 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000400] = 03000; $code[000400] = *L00400; sub L00400 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000401] = 01215; $code[000401] = *I00401; sub I00401 { $lac += $core[000415]; goto &fetch; }
$core[000402] = 03001; $code[000402] = *I00402; sub I00402 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[000403] = 01216; $code[000403] = *I00403; sub I00403 { $lac += $core[000416]; goto &fetch; }
$core[000404] = 03002; $code[000404] = *I00404; sub I00404 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[000405] = 01217; $code[000405] = *I00405; sub I00405 { $lac += $core[000417]; goto &fetch; }
$core[000406] = 03003; $code[000406] = *I00406; sub I00406 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[000407] = 01220; $code[000407] = *I00407; sub I00407 { $lac += $core[000420]; goto &fetch; }
$core[000410] = 03621; $code[000410] = *I00410; sub I00410 { $core[($df<<12)+$core[273]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[273]] = *emul8; goto &fetch; }
$core[000411] = 07300; $code[000411] = *I00411; sub I00411 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000412] = 03004; $code[000412] = *I00412; sub I00412 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[000413] = 03005; $code[000413] = *I00413; sub I00413 { $core[000005] = $lac & 07777; $lac &= 010000; $code[000005] = *emul8; goto &fetch; }
$core[000414] = 05621; $code[000414] = *I00414; sub I00414 { $pc = ($ib<<12)+$core[273]; $inh = 0; goto &fetch; }
$core[000415] = 01116; $code[000415] = *D00415; sub D00415 { $lac += $core[000116]; goto &fetch; }
$core[000416] = 07041; $code[000416] = *D00416; sub D00416 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000417] = 01000; $code[000417] = *D00417; sub D00417 { $lac += $core[000000]; goto &fetch; }
$core[000420] = 01123; $code[000420] = *D00420; sub D00420 { $lac += $core[000123]; goto &fetch; }
$core[000421] = 00200; $code[000421] = *P00421; sub P00421 { $lac &= (010000|$core[000400]); goto &fetch; }
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

