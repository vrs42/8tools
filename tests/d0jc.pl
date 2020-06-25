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
$core[000004] = 00000; $code[000004] = *I00004; sub I00004 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000005] = 00000; $code[000005] = *P00005; sub P00005 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000006] = 07041; $code[000006] = *L00006; sub L00006 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000007] = 01135; $code[000007] = *D00007; sub D00007 { $lac += $core[000135]; goto &fetch; }
$core[000010] = 07640; $code[000010] = *I00010; sub I00010 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000011] = 05551; $code[000011] = *I00011; sub I00011 { $pc = ($ib<<12)+$core[105]; $inh = 0; goto &fetch; }
$core[000012] = 01132; $code[000012] = *D00012; sub D00012 { $lac += $core[000132]; goto &fetch; }
$core[000013] = 07041; $code[000013] = *I00013; sub I00013 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000014] = 01000; $code[000014] = *I00014; sub I00014 { $lac += $core[000000]; goto &fetch; }
$core[000015] = 07640; $code[000015] = *D00015; sub D00015 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000016] = 05551; $code[000016] = *I00016; sub I00016 { $pc = ($ib<<12)+$core[105]; $inh = 0; goto &fetch; }
$core[000017] = 01155; $code[000017] = *L00017; sub L00017 { $lac += $core[000155]; goto &fetch; }
$core[000020] = 03533; $code[000020] = *D00020; sub D00020 { $core[($df<<12)+$core[91]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[91]] = *emul8; goto &fetch; }
$core[000021] = 01155; $code[000021] = *I00021; sub I00021 { $lac += $core[000155]; goto &fetch; }
$core[000022] = 03531; $code[000022] = *I00022; sub I00022 { $core[($df<<12)+$core[89]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[89]] = *emul8; goto &fetch; }
$core[000023] = 07040; $code[000023] = *I00023; sub I00023 { $lac ^= 07777; goto &fetch; }
$core[000024] = 01000; $code[000024] = *I00024; sub I00024 { $lac += $core[000000]; goto &fetch; }
$core[000025] = 03000; $code[000025] = *I00025; sub I00025 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000026] = 01155; $code[000026] = *I00026; sub I00026 { $lac += $core[000155]; goto &fetch; }
$core[000027] = 03400; $code[000027] = *I00027; sub I00027 { $core[($df<<12)+$core[0]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[000030] = 01155; $code[000030] = *I00030; sub I00030 { $lac += $core[000155]; goto &fetch; }
$core[000031] = 03534; $code[000031] = *I00031; sub I00031 { $core[($df<<12)+$core[92]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[92]] = *emul8; goto &fetch; }
$core[000032] = 07001; $code[000032] = *P00032; sub P00032 { $lac++; goto &fetch; }
$core[000033] = 01043; $code[000033] = *I00033; sub I00033 { $lac += $core[000043]; goto &fetch; }
$core[000034] = 03043; $code[000034] = *I00034; sub I00034 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[000035] = 01043; $code[000035] = *I00035; sub I00035 { $lac += $core[000043]; goto &fetch; }
$core[000036] = 07640; $code[000036] = *I00036; sub I00036 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000037] = 05442; $code[000037] = *I00037; sub I00037 { $pc = ($ib<<12)+$core[34]; $inh = 0; goto &fetch; }
$core[000040] = 05441; $code[000040] = *D00040; sub D00040 { $pc = ($ib<<12)+$core[33]; $inh = 0; goto &fetch; }
$core[000041] = 00346; $code[000041] = *P00041; sub P00041 { $lac &= (010000|$core[000146]); goto &fetch; }
$core[000042] = 00220; $code[000042] = *P00042; sub P00042 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[000043] = 00000; $code[000043] = *D00043; sub D00043 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000044] = 00000; $code[000044] = *D00044; sub D00044 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000045] = 07763; $code[000045] = *D00045; sub D00045 { &emul8; goto &fetch; }
$core[000046] = 07475; $code[000046] = *D00046; sub D00046 { &emul8; goto &fetch; }
$core[000047] = 00215; $code[000047] = *D00047; sub D00047 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000050] = 00212; $code[000050] = *D00050; sub D00050 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000051] = 00212; $code[000051] = *D00051; sub D00051 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000052] = 00306; $code[000052] = *I00052; sub I00052 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[000053] = 00240; $code[000053] = *I00053; sub I00053 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000054] = 00000; $code[000054] = *D00054; sub D00054 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000055] = 00000; $code[000055] = *D00055; sub D00055 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000056] = 00000; $code[000056] = *D00056; sub D00056 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000057] = 00000; $code[000057] = *P00057; sub P00057 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000060] = 00240; $code[000060] = *D00060; sub D00060 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000061] = 00324; $code[000061] = *I00061; sub I00061 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[000062] = 00317; $code[000062] = *I00062; sub I00062 { $lac &= (010000|$core[000117]); goto &fetch; }
$core[000063] = 00240; $code[000063] = *I00063; sub I00063 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000064] = 00000; $code[000064] = *D00064; sub D00064 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000065] = 00000; $code[000065] = *D00065; sub D00065 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000066] = 00000; $code[000066] = *D00066; sub D00066 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000067] = 00000; $code[000067] = *D00067; sub D00067 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000070] = 00215; $code[000070] = *I00070; sub I00070 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000071] = 00212; $code[000071] = *I00071; sub I00071 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000072] = 00377; $code[000072] = *I00072; sub I00072 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[000073] = 00250; $code[000073] = *I00073; sub I00073 { $lac &= (010000|$core[000050]); goto &fetch; }
$core[000074] = 00324; $code[000074] = *I00074; sub I00074 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[000075] = 00317; $code[000075] = *D00075; sub D00075 { $lac &= (010000|$core[000117]); goto &fetch; }
$core[000076] = 00251; $code[000076] = *I00076; sub I00076 { $lac &= (010000|$core[000051]); goto &fetch; }
$core[000077] = 00240; $code[000077] = *I00077; sub I00077 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000100] = 00275; $code[000100] = *I00100; sub I00100 { $lac &= (010000|$core[000075]); goto &fetch; }
$core[000101] = 00240; $code[000101] = *I00101; sub I00101 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000102] = 00000; $code[000102] = *D00102; sub D00102 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000103] = 00000; $code[000103] = *D00103; sub D00103 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000104] = 00000; $code[000104] = *D00104; sub D00104 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000105] = 00000; $code[000105] = *D00105; sub D00105 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000106] = 00215; $code[000106] = *D00106; sub D00106 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000107] = 00212; $code[000107] = *P00107; sub P00107 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000110] = 00377; $code[000110] = *I00110; sub I00110 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[000111] = 00250; $code[000111] = *I00111; sub I00111 { $lac &= (010000|$core[000050]); goto &fetch; }
$core[000112] = 00000; $code[000112] = *D00112; sub D00112 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000113] = 00000; $code[000113] = *D00113; sub D00113 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000114] = 00000; $code[000114] = *D00114; sub D00114 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000115] = 00000; $code[000115] = *D00115; sub D00115 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000116] = 00251; $code[000116] = *I00116; sub I00116 { $lac &= (010000|$core[000051]); goto &fetch; }
$core[000117] = 00240; $code[000117] = *D00117; sub D00117 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000120] = 00275; $code[000120] = *I00120; sub I00120 { $lac &= (010000|$core[000075]); goto &fetch; }
$core[000121] = 00240; $code[000121] = *I00121; sub I00121 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000122] = 00000; $code[000122] = *D00122; sub D00122 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000123] = 00000; $code[000123] = *D00123; sub D00123 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000124] = 00000; $code[000124] = *D00124; sub D00124 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000125] = 00000; $code[000125] = *P00125; sub P00125 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000126] = 00207; $code[000126] = *I00126; sub I00126 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000127] = 00000; $code[000127] = *P00127; sub P00127 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000130] = 07571; $code[000130] = *D00130; sub D00130 { &emul8; goto &fetch; }
$core[000131] = 00000; $code[000131] = *P00131; sub P00131 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000132] = 00000; $code[000132] = *D00132; sub D00132 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000133] = 00000; $code[000133] = *P00133; sub P00133 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000134] = 00000; $code[000134] = *P00134; sub P00134 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000135] = 00000; $code[000135] = *D00135; sub D00135 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000136] = 02525; $code[000136] = *D00136; sub D00136 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[000137] = 00003; $code[000137] = *D00137; sub D00137 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000140] = 07200; $code[000140] = *D00140; sub D00140 { $lac &= 010000; goto &fetch; }
$core[000141] = 00200; $code[000141] = *D00141; sub D00141 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000142] = 06001; $code[000142] = *D00142; sub D00142 { &emul8; goto &fetch; }
$core[000143] = 00000; $code[000143] = *D00143; sub D00143 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000144] = 00000; $code[000144] = *D00144; sub D00144 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000145] = 00000; $code[000145] = *D00145; sub D00145 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000146] = 00000; $code[000146] = *D00146; sub D00146 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000147] = 00007; $code[000147] = *D00147; sub D00147 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000150] = 00260; $code[000150] = *D00150; sub D00150 { $lac &= (010000|$core[000060]); goto &fetch; }
$core[000151] = 00400; $code[000151] = *P00151; sub P00151 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000152] = 00327; $code[000152] = *P00152; sub P00152 { $lac &= (010000|$core[000127]); goto &fetch; }
$core[000153] = 00330; $code[000153] = *P00153; sub P00153 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000154] = 00047; $code[000154] = *D00154; sub D00154 { $lac &= (010000|$core[000047]); goto &fetch; }
$core[000155] = 07402; $code[000155] = *D00155; sub D00155 { $hlt = 1; goto &fetch; }
$core[000156] = 04531; $code[000156] = *D00156; sub D00156 { $core[($ib<<12)+$core[89]] = 00157; $pc = ($ib<<12)+$core[89]+1; $code[($ib<<12)+$core[89]] = *emul8; $inh = 0; goto &fetch; }
$core[000157] = 00000; $code[000157] = *S00157; sub S00157 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000160] = 03000; $code[000160] = *I00160; sub I00160 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000161] = 01172; $code[000161] = *I00161; sub I00161 { $lac += $core[000172]; goto &fetch; }
$core[000162] = 03001; $code[000162] = *I00162; sub I00162 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[000163] = 01173; $code[000163] = *I00163; sub I00163 { $lac += $core[000173]; goto &fetch; }
$core[000164] = 03002; $code[000164] = *I00164; sub I00164 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[000165] = 01174; $code[000165] = *I00165; sub I00165 { $lac += $core[000174]; goto &fetch; }
$core[000166] = 03003; $code[000166] = *I00166; sub I00166 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[000167] = 01175; $code[000167] = *I00167; sub I00167 { $lac += $core[000175]; goto &fetch; }
$core[000170] = 03576; $code[000170] = *I00170; sub I00170 { $core[($df<<12)+$core[126]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[126]] = *emul8; goto &fetch; }
$core[000171] = 05557; $code[000171] = *I00171; sub I00171 { $pc = ($ib<<12)+$core[111]; $inh = 0; goto &fetch; }
$core[000172] = 07200; $code[000172] = *D00172; sub D00172 { $lac &= 010000; goto &fetch; }
$core[000173] = 01531; $code[000173] = *D00173; sub D00173 { $lac += $core[($df<<12)+$core[89]]; goto &fetch; }
$core[000174] = 05006; $code[000174] = *D00174; sub D00174 { $pc = 000006; $inh = 0; goto &fetch; }
$core[000175] = 07200; $code[000175] = *D00175; sub D00175 { $lac &= 010000; goto &fetch; }
$core[000176] = 00200; $code[000176] = *P00176; sub P00176 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000200] = 04157; $code[000200] = *D00200; sub D00200 { $core[000157] = 00201; $pc = 000157+1; $code[000157] = *emul8; $inh = 0; goto &fetch; }
$core[000201] = 01140; $code[000201] = *I00201; sub I00201 { $lac += $core[000140]; goto &fetch; }
$core[000202] = 07041; $code[000202] = *I00202; sub I00202 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000203] = 03131; $code[000203] = *I00203; sub I00203 { $core[000131] = $lac & 07777; $lac &= 010000; $code[000131] = *emul8; goto &fetch; }
$core[000204] = 01155; $code[000204] = *L00204; sub L00204 { $lac += $core[000155]; goto &fetch; }
$core[000205] = 03531; $code[000205] = *I00205; sub I00205 { $core[($df<<12)+$core[89]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[89]] = *emul8; goto &fetch; }
$core[000206] = 01131; $code[000206] = *I00206; sub I00206 { $lac += $core[000131]; goto &fetch; }
$core[000207] = 07001; $code[000207] = *I00207; sub I00207 { $lac++; goto &fetch; }
$core[000210] = 03131; $code[000210] = *I00210; sub I00210 { $core[000131] = $lac & 07777; $lac &= 010000; $code[000131] = *emul8; goto &fetch; }
$core[000211] = 01131; $code[000211] = *I00211; sub I00211 { $lac += $core[000131]; goto &fetch; }
$core[000212] = 01141; $code[000212] = *D00212; sub D00212 { $lac += $core[000141]; goto &fetch; }
$core[000213] = 07640; $code[000213] = *I00213; sub I00213 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000214] = 05204; $code[000214] = *I00214; sub I00214 { $pc = 000204; $inh = 0; goto &fetch; }
$core[000215] = 01045; $code[000215] = *D00215; sub D00215 { $lac += $core[000045]; goto &fetch; }
$core[000216] = 03044; $code[000216] = *I00216; sub I00216 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[000217] = 03043; $code[000217] = *I00217; sub I00217 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[000220] = 07604; $code[000220] = *L00220; sub L00220 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000221] = 07004; $code[000221] = *I00221; sub I00221 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000222] = 07006; $code[000222] = *I00222; sub I00222 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000223] = 07630; $code[000223] = *I00223; sub I00223 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000224] = 05246; $code[000224] = *I00224; sub I00224 { $pc = 000246; $inh = 0; goto &fetch; }
$core[000225] = 01136; $code[000225] = *L00225; sub L00225 { $lac += $core[000136]; goto &fetch; }
$core[000226] = 07104; $code[000226] = *I00226; sub I00226 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000227] = 07430; $code[000227] = *I00227; sub I00227 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000230] = 01137; $code[000230] = *I00230; sub I00230 { $lac += $core[000137]; goto &fetch; }
$core[000231] = 03136; $code[000231] = *I00231; sub I00231 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[000232] = 01136; $code[000232] = *I00232; sub I00232 { $lac += $core[000136]; goto &fetch; }
$core[000233] = 07510; $code[000233] = *I00233; sub I00233 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000234] = 05241; $code[000234] = *I00234; sub I00234 { $pc = 000241; $inh = 0; goto &fetch; }
$core[000235] = 01140; $code[000235] = *I00235; sub I00235 { $lac += $core[000140]; goto &fetch; }
$core[000236] = 07710; $code[000236] = *I00236; sub I00236 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000237] = 05225; $code[000237] = *I00237; sub I00237 { $pc = 000225; $inh = 0; goto &fetch; }
$core[000240] = 05244; $code[000240] = *I00240; sub I00240 { $pc = 000244; $inh = 0; goto &fetch; }
$core[000241] = 01141; $code[000241] = *L00241; sub L00241 { $lac += $core[000141]; goto &fetch; }
$core[000242] = 07700; $code[000242] = *I00242; sub I00242 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000243] = 05225; $code[000243] = *I00243; sub I00243 { $pc = 000225; $inh = 0; goto &fetch; }
$core[000244] = 01136; $code[000244] = *L00244; sub L00244 { $lac += $core[000136]; goto &fetch; }
$core[000245] = 03133; $code[000245] = *I00245; sub I00245 { $core[000133] = $lac & 07777; $lac &= 010000; $code[000133] = *emul8; goto &fetch; }
$core[000246] = 01133; $code[000246] = *L00246; sub L00246 { $lac += $core[000133]; goto &fetch; }
$core[000247] = 07001; $code[000247] = *I00247; sub I00247 { $lac++; goto &fetch; }
$core[000250] = 03135; $code[000250] = *I00250; sub I00250 { $core[000135] = $lac & 07777; $lac &= 010000; $code[000135] = *emul8; goto &fetch; }
$core[000251] = 07040; $code[000251] = *I00251; sub I00251 { $lac ^= 07777; goto &fetch; }
$core[000252] = 01133; $code[000252] = *I00252; sub I00252 { $lac += $core[000133]; goto &fetch; }
$core[000253] = 03134; $code[000253] = *I00253; sub I00253 { $core[000134] = $lac & 07777; $lac &= 010000; $code[000134] = *emul8; goto &fetch; }
$core[000254] = 07604; $code[000254] = *I00254; sub I00254 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000255] = 07006; $code[000255] = *I00255; sub I00255 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000256] = 07006; $code[000256] = *I00256; sub I00256 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000257] = 07630; $code[000257] = *I00257; sub I00257 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000260] = 05302; $code[000260] = *I00260; sub I00260 { $pc = 000302; $inh = 0; goto &fetch; }
$core[000261] = 01136; $code[000261] = *L00261; sub L00261 { $lac += $core[000136]; goto &fetch; }
$core[000262] = 07104; $code[000262] = *I00262; sub I00262 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000263] = 07430; $code[000263] = *I00263; sub I00263 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000264] = 01137; $code[000264] = *I00264; sub I00264 { $lac += $core[000137]; goto &fetch; }
$core[000265] = 03136; $code[000265] = *I00265; sub I00265 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[000266] = 01136; $code[000266] = *I00266; sub I00266 { $lac += $core[000136]; goto &fetch; }
$core[000267] = 07510; $code[000267] = *I00267; sub I00267 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000270] = 05275; $code[000270] = *I00270; sub I00270 { $pc = 000275; $inh = 0; goto &fetch; }
$core[000271] = 01140; $code[000271] = *I00271; sub I00271 { $lac += $core[000140]; goto &fetch; }
$core[000272] = 07710; $code[000272] = *I00272; sub I00272 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000273] = 05261; $code[000273] = *I00273; sub I00273 { $pc = 000261; $inh = 0; goto &fetch; }
$core[000274] = 05300; $code[000274] = *I00274; sub I00274 { $pc = 000300; $inh = 0; goto &fetch; }
$core[000275] = 01141; $code[000275] = *L00275; sub L00275 { $lac += $core[000141]; goto &fetch; }
$core[000276] = 07700; $code[000276] = *I00276; sub I00276 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000277] = 05261; $code[000277] = *I00277; sub I00277 { $pc = 000261; $inh = 0; goto &fetch; }
$core[000300] = 01136; $code[000300] = *L00300; sub L00300 { $lac += $core[000136]; goto &fetch; }
$core[000301] = 03131; $code[000301] = *I00301; sub I00301 { $core[000131] = $lac & 07777; $lac &= 010000; $code[000131] = *emul8; goto &fetch; }
$core[000302] = 01131; $code[000302] = *L00302; sub L00302 { $lac += $core[000131]; goto &fetch; }
$core[000303] = 07001; $code[000303] = *D00303; sub D00303 { $lac++; goto &fetch; }
$core[000304] = 03132; $code[000304] = *I00304; sub I00304 { $core[000132] = $lac & 07777; $lac &= 010000; $code[000132] = *emul8; goto &fetch; }
$core[000305] = 01133; $code[000305] = *I00305; sub I00305 { $lac += $core[000133]; goto &fetch; }
$core[000306] = 07041; $code[000306] = *I00306; sub I00306 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000307] = 01131; $code[000307] = *I00307; sub I00307 { $lac += $core[000131]; goto &fetch; }
$core[000310] = 07650; $code[000310] = *I00310; sub I00310 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000311] = 05220; $code[000311] = *I00311; sub I00311 { $pc = 000220; $inh = 0; goto &fetch; }
$core[000312] = 07040; $code[000312] = *D00312; sub D00312 { $lac ^= 07777; goto &fetch; }
$core[000313] = 06041; $code[000313] = *I00313; sub I00313 { &emul8; goto &fetch; }
$core[000314] = 06046; $code[000314] = *I00314; sub I00314 { &emul8; goto &fetch; }
$core[000315] = 06041; $code[000315] = *L00315; sub L00315 { &emul8; goto &fetch; }
$core[000316] = 05315; $code[000316] = *I00316; sub I00316 { $pc = 000315; $inh = 0; goto &fetch; }
$core[000317] = 07200; $code[000317] = *I00317; sub I00317 { $lac &= 010000; goto &fetch; }
$core[000320] = 01142; $code[000320] = *I00320; sub I00320 { $lac += $core[000142]; goto &fetch; }
$core[000321] = 03534; $code[000321] = *I00321; sub I00321 { $core[($df<<12)+$core[92]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[92]] = *emul8; goto &fetch; }
$core[000322] = 01156; $code[000322] = *I00322; sub I00322 { $lac += $core[000156]; goto &fetch; }
$core[000323] = 03533; $code[000323] = *I00323; sub I00323 { $core[($df<<12)+$core[91]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[91]] = *emul8; goto &fetch; }
$core[000324] = 03000; $code[000324] = *I00324; sub I00324 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000325] = 05534; $code[000325] = *I00325; sub I00325 { $pc = ($ib<<12)+$core[92]; $inh = 0; goto &fetch; }
$core[000326] = 07402; $code[000326] = *I00326; sub I00326 { $hlt = 1; goto &fetch; }
$core[000327] = 00000; $code[000327] = *P00327; sub P00327 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000330] = 03146; $code[000330] = *L00330; sub L00330 { $core[000146] = $lac & 07777; $lac &= 010000; $code[000146] = *emul8; goto &fetch; }
$core[000331] = 01146; $code[000331] = *I00331; sub I00331 { $lac += $core[000146]; goto &fetch; }
$core[000332] = 07012; $code[000332] = *I00332; sub I00332 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000333] = 07010; $code[000333] = *I00333; sub I00333 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000334] = 03145; $code[000334] = *I00334; sub I00334 { $core[000145] = $lac & 07777; $lac &= 010000; $code[000145] = *emul8; goto &fetch; }
$core[000335] = 01145; $code[000335] = *I00335; sub I00335 { $lac += $core[000145]; goto &fetch; }
$core[000336] = 07012; $code[000336] = *I00336; sub I00336 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000337] = 07010; $code[000337] = *I00337; sub I00337 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000340] = 03144; $code[000340] = *I00340; sub I00340 { $core[000144] = $lac & 07777; $lac &= 010000; $code[000144] = *emul8; goto &fetch; }
$core[000341] = 01144; $code[000341] = *I00341; sub I00341 { $lac += $core[000144]; goto &fetch; }
$core[000342] = 07012; $code[000342] = *I00342; sub I00342 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000343] = 07010; $code[000343] = *I00343; sub I00343 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000344] = 03143; $code[000344] = *I00344; sub I00344 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[000345] = 05727; $code[000345] = *I00345; sub I00345 { $pc = ($ib<<12)+$core[215]; $inh = 0; goto &fetch; }
$core[000346] = 01044; $code[000346] = *L00346; sub L00346 { $lac += $core[000044]; goto &fetch; }
$core[000347] = 07001; $code[000347] = *I00347; sub I00347 { $lac++; goto &fetch; }
$core[000350] = 03044; $code[000350] = *I00350; sub I00350 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[000351] = 01044; $code[000351] = *I00351; sub I00351 { $lac += $core[000044]; goto &fetch; }
$core[000352] = 07640; $code[000352] = *I00352; sub I00352 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000353] = 05442; $code[000353] = *I00353; sub I00353 { $pc = ($ib<<12)+$core[34]; $inh = 0; goto &fetch; }
$core[000354] = 01373; $code[000354] = *I00354; sub I00354 { $lac += $core[000373]; goto &fetch; }
$core[000355] = 03127; $code[000355] = *I00355; sub I00355 { $core[000127] = $lac & 07777; $lac &= 010000; $code[000127] = *emul8; goto &fetch; }
$core[000356] = 01127; $code[000356] = *L00356; sub L00356 { $lac += $core[000127]; goto &fetch; }
$core[000357] = 07001; $code[000357] = *I00357; sub I00357 { $lac++; goto &fetch; }
$core[000360] = 03127; $code[000360] = *I00360; sub I00360 { $core[000127] = $lac & 07777; $lac &= 010000; $code[000127] = *emul8; goto &fetch; }
$core[000361] = 01527; $code[000361] = *I00361; sub I00361 { $lac += $core[($df<<12)+$core[87]]; goto &fetch; }
$core[000362] = 06046; $code[000362] = *I00362; sub I00362 { &emul8; goto &fetch; }
$core[000363] = 06041; $code[000363] = *L00363; sub L00363 { &emul8; goto &fetch; }
$core[000364] = 05363; $code[000364] = *I00364; sub I00364 { $pc = 000363; $inh = 0; goto &fetch; }
$core[000365] = 01046; $code[000365] = *I00365; sub I00365 { $lac += $core[000046]; goto &fetch; }
$core[000366] = 07640; $code[000366] = *I00366; sub I00366 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000367] = 05356; $code[000367] = *I00367; sub I00367 { $pc = 000356; $inh = 0; goto &fetch; }
$core[000370] = 01045; $code[000370] = *I00370; sub I00370 { $lac += $core[000045]; goto &fetch; }
$core[000371] = 03044; $code[000371] = *I00371; sub I00371 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[000372] = 05442; $code[000372] = *I00372; sub I00372 { $pc = ($ib<<12)+$core[34]; $inh = 0; goto &fetch; }
$core[000373] = 00373; $code[000373] = *D00373; sub D00373 { $lac &= (010000|$core[000373]); goto &fetch; }
$core[000374] = 00215; $code[000374] = *I00374; sub I00374 { $lac &= (010000|$core[000215]); goto &fetch; }
$core[000375] = 00212; $code[000375] = *I00375; sub I00375 { $lac &= (010000|$core[000212]); goto &fetch; }
$core[000376] = 00312; $code[000376] = *I00376; sub I00376 { $lac &= (010000|$core[000312]); goto &fetch; }
$core[000377] = 00303; $code[000377] = *I00377; sub I00377 { $lac &= (010000|$core[000303]); goto &fetch; }
$core[000400] = 01204; $code[000400] = *L00400; sub L00400 { $lac += $core[000404]; goto &fetch; }
$core[000401] = 03552; $code[000401] = *I00401; sub I00401 { $core[($df<<12)+$core[106]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[106]] = *emul8; goto &fetch; }
$core[000402] = 01133; $code[000402] = *I00402; sub I00402 { $lac += $core[000133]; goto &fetch; }
$core[000403] = 05553; $code[000403] = *I00403; sub I00403 { $pc = ($ib<<12)+$core[107]; $inh = 0; goto &fetch; }
$core[000404] = 00405; $code[000404] = *D00404; sub D00404 { $lac &= (010000|$core[($df<<12)+$core[5]]); goto &fetch; }
$core[000405] = 01143; $code[000405] = *I00405; sub I00405 { $lac += $core[000143]; goto &fetch; }
$core[000406] = 00147; $code[000406] = *I00406; sub I00406 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000407] = 01150; $code[000407] = *I00407; sub I00407 { $lac += $core[000150]; goto &fetch; }
$core[000410] = 03054; $code[000410] = *I00410; sub I00410 { $core[000054] = $lac & 07777; $lac &= 010000; $code[000054] = *emul8; goto &fetch; }
$core[000411] = 01144; $code[000411] = *I00411; sub I00411 { $lac += $core[000144]; goto &fetch; }
$core[000412] = 00147; $code[000412] = *I00412; sub I00412 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000413] = 01150; $code[000413] = *I00413; sub I00413 { $lac += $core[000150]; goto &fetch; }
$core[000414] = 03055; $code[000414] = *I00414; sub I00414 { $core[000055] = $lac & 07777; $lac &= 010000; $code[000055] = *emul8; goto &fetch; }
$core[000415] = 01145; $code[000415] = *I00415; sub I00415 { $lac += $core[000145]; goto &fetch; }
$core[000416] = 00147; $code[000416] = *I00416; sub I00416 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000417] = 01150; $code[000417] = *I00417; sub I00417 { $lac += $core[000150]; goto &fetch; }
$core[000420] = 03056; $code[000420] = *I00420; sub I00420 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[000421] = 01146; $code[000421] = *I00421; sub I00421 { $lac += $core[000146]; goto &fetch; }
$core[000422] = 00147; $code[000422] = *I00422; sub I00422 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000423] = 01150; $code[000423] = *I00423; sub I00423 { $lac += $core[000150]; goto &fetch; }
$core[000424] = 03057; $code[000424] = *I00424; sub I00424 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[000425] = 01231; $code[000425] = *I00425; sub I00425 { $lac += $core[000431]; goto &fetch; }
$core[000426] = 03552; $code[000426] = *I00426; sub I00426 { $core[($df<<12)+$core[106]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[106]] = *emul8; goto &fetch; }
$core[000427] = 01131; $code[000427] = *I00427; sub I00427 { $lac += $core[000131]; goto &fetch; }
$core[000430] = 05553; $code[000430] = *I00430; sub I00430 { $pc = ($ib<<12)+$core[107]; $inh = 0; goto &fetch; }
$core[000431] = 00432; $code[000431] = *D00431; sub D00431 { $lac &= (010000|$core[($df<<12)+$core[26]]); goto &fetch; }
$core[000432] = 01143; $code[000432] = *I00432; sub I00432 { $lac += $core[000143]; goto &fetch; }
$core[000433] = 00147; $code[000433] = *I00433; sub I00433 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000434] = 01150; $code[000434] = *I00434; sub I00434 { $lac += $core[000150]; goto &fetch; }
$core[000435] = 03064; $code[000435] = *I00435; sub I00435 { $core[000064] = $lac & 07777; $lac &= 010000; $code[000064] = *emul8; goto &fetch; }
$core[000436] = 01144; $code[000436] = *I00436; sub I00436 { $lac += $core[000144]; goto &fetch; }
$core[000437] = 00147; $code[000437] = *I00437; sub I00437 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000440] = 01150; $code[000440] = *I00440; sub I00440 { $lac += $core[000150]; goto &fetch; }
$core[000441] = 03065; $code[000441] = *I00441; sub I00441 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[000442] = 01145; $code[000442] = *I00442; sub I00442 { $lac += $core[000145]; goto &fetch; }
$core[000443] = 00147; $code[000443] = *I00443; sub I00443 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000444] = 01150; $code[000444] = *I00444; sub I00444 { $lac += $core[000150]; goto &fetch; }
$core[000445] = 03066; $code[000445] = *I00445; sub I00445 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[000446] = 01146; $code[000446] = *I00446; sub I00446 { $lac += $core[000146]; goto &fetch; }
$core[000447] = 00147; $code[000447] = *I00447; sub I00447 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000450] = 01150; $code[000450] = *I00450; sub I00450 { $lac += $core[000150]; goto &fetch; }
$core[000451] = 03067; $code[000451] = *I00451; sub I00451 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000452] = 01256; $code[000452] = *I00452; sub I00452 { $lac += $core[000456]; goto &fetch; }
$core[000453] = 03552; $code[000453] = *I00453; sub I00453 { $core[($df<<12)+$core[106]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[106]] = *emul8; goto &fetch; }
$core[000454] = 01531; $code[000454] = *I00454; sub I00454 { $lac += $core[($df<<12)+$core[89]]; goto &fetch; }
$core[000455] = 05553; $code[000455] = *I00455; sub I00455 { $pc = ($ib<<12)+$core[107]; $inh = 0; goto &fetch; }
$core[000456] = 00457; $code[000456] = *D00456; sub D00456 { $lac &= (010000|$core[($df<<12)+$core[47]]); goto &fetch; }
$core[000457] = 01143; $code[000457] = *I00457; sub I00457 { $lac += $core[000143]; goto &fetch; }
$core[000460] = 00147; $code[000460] = *I00460; sub I00460 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000461] = 01150; $code[000461] = *I00461; sub I00461 { $lac += $core[000150]; goto &fetch; }
$core[000462] = 03102; $code[000462] = *I00462; sub I00462 { $core[000102] = $lac & 07777; $lac &= 010000; $code[000102] = *emul8; goto &fetch; }
$core[000463] = 01144; $code[000463] = *I00463; sub I00463 { $lac += $core[000144]; goto &fetch; }
$core[000464] = 00147; $code[000464] = *I00464; sub I00464 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000465] = 01150; $code[000465] = *I00465; sub I00465 { $lac += $core[000150]; goto &fetch; }
$core[000466] = 03103; $code[000466] = *I00466; sub I00466 { $core[000103] = $lac & 07777; $lac &= 010000; $code[000103] = *emul8; goto &fetch; }
$core[000467] = 01145; $code[000467] = *I00467; sub I00467 { $lac += $core[000145]; goto &fetch; }
$core[000470] = 00147; $code[000470] = *I00470; sub I00470 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000471] = 01150; $code[000471] = *I00471; sub I00471 { $lac += $core[000150]; goto &fetch; }
$core[000472] = 03104; $code[000472] = *I00472; sub I00472 { $core[000104] = $lac & 07777; $lac &= 010000; $code[000104] = *emul8; goto &fetch; }
$core[000473] = 01146; $code[000473] = *I00473; sub I00473 { $lac += $core[000146]; goto &fetch; }
$core[000474] = 00147; $code[000474] = *I00474; sub I00474 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000475] = 01150; $code[000475] = *I00475; sub I00475 { $lac += $core[000150]; goto &fetch; }
$core[000476] = 03105; $code[000476] = *I00476; sub I00476 { $core[000105] = $lac & 07777; $lac &= 010000; $code[000105] = *emul8; goto &fetch; }
$core[000477] = 07040; $code[000477] = *I00477; sub I00477 { $lac ^= 07777; goto &fetch; }
$core[000500] = 01000; $code[000500] = *I00500; sub I00500 { $lac += $core[000000]; goto &fetch; }
$core[000501] = 03000; $code[000501] = *I00501; sub I00501 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000502] = 01306; $code[000502] = *I00502; sub I00502 { $lac += $core[000506]; goto &fetch; }
$core[000503] = 03552; $code[000503] = *I00503; sub I00503 { $core[($df<<12)+$core[106]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[106]] = *emul8; goto &fetch; }
$core[000504] = 01000; $code[000504] = *I00504; sub I00504 { $lac += $core[000000]; goto &fetch; }
$core[000505] = 05553; $code[000505] = *I00505; sub I00505 { $pc = ($ib<<12)+$core[107]; $inh = 0; goto &fetch; }
$core[000506] = 00507; $code[000506] = *D00506; sub D00506 { $lac &= (010000|$core[($df<<12)+$core[71]]); goto &fetch; }
$core[000507] = 01143; $code[000507] = *I00507; sub I00507 { $lac += $core[000143]; goto &fetch; }
$core[000510] = 00147; $code[000510] = *I00510; sub I00510 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000511] = 01150; $code[000511] = *I00511; sub I00511 { $lac += $core[000150]; goto &fetch; }
$core[000512] = 03112; $code[000512] = *I00512; sub I00512 { $core[000112] = $lac & 07777; $lac &= 010000; $code[000112] = *emul8; goto &fetch; }
$core[000513] = 01144; $code[000513] = *I00513; sub I00513 { $lac += $core[000144]; goto &fetch; }
$core[000514] = 00147; $code[000514] = *I00514; sub I00514 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000515] = 01150; $code[000515] = *I00515; sub I00515 { $lac += $core[000150]; goto &fetch; }
$core[000516] = 03113; $code[000516] = *I00516; sub I00516 { $core[000113] = $lac & 07777; $lac &= 010000; $code[000113] = *emul8; goto &fetch; }
$core[000517] = 01145; $code[000517] = *I00517; sub I00517 { $lac += $core[000145]; goto &fetch; }
$core[000520] = 00147; $code[000520] = *I00520; sub I00520 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000521] = 01150; $code[000521] = *I00521; sub I00521 { $lac += $core[000150]; goto &fetch; }
$core[000522] = 03114; $code[000522] = *I00522; sub I00522 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[000523] = 01146; $code[000523] = *I00523; sub I00523 { $lac += $core[000146]; goto &fetch; }
$core[000524] = 00147; $code[000524] = *I00524; sub I00524 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000525] = 01150; $code[000525] = *I00525; sub I00525 { $lac += $core[000150]; goto &fetch; }
$core[000526] = 03115; $code[000526] = *I00526; sub I00526 { $core[000115] = $lac & 07777; $lac &= 010000; $code[000115] = *emul8; goto &fetch; }
$core[000527] = 01333; $code[000527] = *I00527; sub I00527 { $lac += $core[000533]; goto &fetch; }
$core[000530] = 03552; $code[000530] = *I00530; sub I00530 { $core[($df<<12)+$core[106]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[106]] = *emul8; goto &fetch; }
$core[000531] = 01400; $code[000531] = *I00531; sub I00531 { $lac += $core[($df<<12)+$core[0]]; goto &fetch; }
$core[000532] = 05553; $code[000532] = *I00532; sub I00532 { $pc = ($ib<<12)+$core[107]; $inh = 0; goto &fetch; }
$core[000533] = 00534; $code[000533] = *D00533; sub D00533 { $lac &= (010000|$core[($df<<12)+$core[92]]); goto &fetch; }
$core[000534] = 01143; $code[000534] = *I00534; sub I00534 { $lac += $core[000143]; goto &fetch; }
$core[000535] = 00147; $code[000535] = *I00535; sub I00535 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000536] = 01150; $code[000536] = *I00536; sub I00536 { $lac += $core[000150]; goto &fetch; }
$core[000537] = 03122; $code[000537] = *I00537; sub I00537 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[000540] = 01144; $code[000540] = *I00540; sub I00540 { $lac += $core[000144]; goto &fetch; }
$core[000541] = 00147; $code[000541] = *I00541; sub I00541 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000542] = 01150; $code[000542] = *I00542; sub I00542 { $lac += $core[000150]; goto &fetch; }
$core[000543] = 03123; $code[000543] = *I00543; sub I00543 { $core[000123] = $lac & 07777; $lac &= 010000; $code[000123] = *emul8; goto &fetch; }
$core[000544] = 01145; $code[000544] = *I00544; sub I00544 { $lac += $core[000145]; goto &fetch; }
$core[000545] = 00147; $code[000545] = *I00545; sub I00545 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000546] = 01150; $code[000546] = *I00546; sub I00546 { $lac += $core[000150]; goto &fetch; }
$core[000547] = 03124; $code[000547] = *I00547; sub I00547 { $core[000124] = $lac & 07777; $lac &= 010000; $code[000124] = *emul8; goto &fetch; }
$core[000550] = 01146; $code[000550] = *I00550; sub I00550 { $lac += $core[000146]; goto &fetch; }
$core[000551] = 00147; $code[000551] = *I00551; sub I00551 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[000552] = 01150; $code[000552] = *I00552; sub I00552 { $lac += $core[000150]; goto &fetch; }
$core[000553] = 03125; $code[000553] = *I00553; sub I00553 { $core[000125] = $lac & 07777; $lac &= 010000; $code[000125] = *emul8; goto &fetch; }
$core[000554] = 01154; $code[000554] = *I00554; sub I00554 { $lac += $core[000154]; goto &fetch; }
$core[000555] = 03127; $code[000555] = *I00555; sub I00555 { $core[000127] = $lac & 07777; $lac &= 010000; $code[000127] = *emul8; goto &fetch; }
$core[000556] = 01527; $code[000556] = *L00556; sub L00556 { $lac += $core[($df<<12)+$core[87]]; goto &fetch; }
$core[000557] = 06046; $code[000557] = *I00557; sub I00557 { &emul8; goto &fetch; }
$core[000560] = 06041; $code[000560] = *L00560; sub L00560 { &emul8; goto &fetch; }
$core[000561] = 05360; $code[000561] = *I00561; sub I00561 { $pc = 000560; $inh = 0; goto &fetch; }
$core[000562] = 07201; $code[000562] = *I00562; sub I00562 { $lac &= 010000; $lac++; goto &fetch; }
$core[000563] = 01127; $code[000563] = *I00563; sub I00563 { $lac += $core[000127]; goto &fetch; }
$core[000564] = 03127; $code[000564] = *I00564; sub I00564 { $core[000127] = $lac & 07777; $lac &= 010000; $code[000127] = *emul8; goto &fetch; }
$core[000565] = 01527; $code[000565] = *I00565; sub I00565 { $lac += $core[($df<<12)+$core[87]]; goto &fetch; }
$core[000566] = 01130; $code[000566] = *I00566; sub I00566 { $lac += $core[000130]; goto &fetch; }
$core[000567] = 07640; $code[000567] = *I00567; sub I00567 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000570] = 05356; $code[000570] = *I00570; sub I00570 { $pc = 000556; $inh = 0; goto &fetch; }
$core[000571] = 07604; $code[000571] = *I00571; sub I00571 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000572] = 07700; $code[000572] = *I00572; sub I00572 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000573] = 07402; $code[000573] = *I00573; sub I00573 { $hlt = 1; goto &fetch; }
$core[000574] = 05017; $code[000574] = *I00574; sub I00574 { $pc = 000017; $inh = 0; goto &fetch; }
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

