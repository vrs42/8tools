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
$swr = 0000;
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
$core[000002] = 00002; $code[000002] = *S00002; sub S00002 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000003] = 00003; $code[000003] = *P00003; sub P00003 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000004] = 00000; $code[000004] = *S00004; sub S00004 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000010] = 00000; $code[000010] = *P00010; sub P00010 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000011] = 00000; $code[000011] = *P00011; sub P00011 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000012] = 00000; $code[000012] = *P00012; sub P00012 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000020] = 00000; $code[000020] = *P00020; sub P00020 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000021] = 00022; $code[000021] = *P00021; sub P00021 { $lac &= (010000|$core[000022]); goto &fetch; }
$core[000022] = 07777; $code[000022] = *P00022; sub P00022 { &emul8; goto &fetch; }
$core[000023] = 00000; $code[000023] = *D00023; sub D00023 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000024] = 00000; $code[000024] = *P00024; sub P00024 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000025] = 00000; $code[000025] = *P00025; sub P00025 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000026] = 00000; $code[000026] = *L00026; sub L00026 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000027] = 00000; $code[000027] = *D00027; sub D00027 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000030] = 00000; $code[000030] = *P00030; sub P00030 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000031] = 00000; $code[000031] = *D00031; sub D00031 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000032] = 00000; $code[000032] = *D00032; sub D00032 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000033] = 00000; $code[000033] = *D00033; sub D00033 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000034] = 00000; $code[000034] = *P00034; sub P00034 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000035] = 00000; $code[000035] = *D00035; sub D00035 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000036] = 00000; $code[000036] = *P00036; sub P00036 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000037] = 00000; $code[000037] = *P00037; sub P00037 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000040] = 00000; $code[000040] = *S00040; sub S00040 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000041] = 00037; $code[000041] = *L00041; sub L00041 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[000042] = 00000; $code[000042] = *I00042; sub I00042 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000043] = 00000; $code[000043] = *D00043; sub D00043 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000044] = 00000; $code[000044] = *D00044; sub D00044 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000045] = 00000; $code[000045] = *D00045; sub D00045 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000046] = 01600; $code[000046] = *P00046; sub P00046 { $lac += $core[($df<<12)+$core[0]]; goto &fetch; }
$core[000047] = 01652; $code[000047] = *P00047; sub P00047 { $lac += $core[($df<<12)+$core[42]]; goto &fetch; }
$core[000050] = 01133; $code[000050] = *P00050; sub P00050 { $lac += $core[000133]; goto &fetch; }
$core[000051] = 01200; $code[000051] = *P00051; sub P00051 { $lac += $core[000000]; goto &fetch; }
$core[000052] = 00756; $code[000052] = *P00052; sub P00052 { $lac &= (010000|$core[($df<<12)+$core[110]]); goto &fetch; }
$core[000053] = 01157; $code[000053] = *D00053; sub D00053 { $lac += $core[000157]; goto &fetch; }
$core[000054] = 01140; $code[000054] = *D00054; sub D00054 { $lac += $core[000140]; goto &fetch; }
$core[000055] = 01657; $code[000055] = *P00055; sub P00055 { $lac += $core[($df<<12)+$core[47]]; goto &fetch; }
$core[000056] = 01000; $code[000056] = *P00056; sub P00056 { $lac += $core[000000]; goto &fetch; }
$core[000057] = 01031; $code[000057] = *P00057; sub P00057 { $lac += $core[000031]; goto &fetch; }
$core[000060] = 00504; $code[000060] = *P00060; sub P00060 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[000061] = 00523; $code[000061] = *P00061; sub P00061 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[000062] = 03000; $code[000062] = *P00062; sub P00062 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000063] = 03730; $code[000063] = *P00063; sub P00063 { $core[($df<<12)+$core[88]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[88]] = *emul8; goto &fetch; }
$core[000064] = 03017; $code[000064] = *P00064; sub P00064 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[000065] = 03037; $code[000065] = *P00065; sub P00065 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[000066] = 03027; $code[000066] = *P00066; sub P00066 { $core[000027] = $lac & 07777; $lac &= 010000; $code[000027] = *emul8; goto &fetch; }
$core[000067] = 03046; $code[000067] = *P00067; sub P00067 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[000070] = 07775; $code[000070] = *D00070; sub D00070 { &emul8; goto &fetch; }
$core[000071] = 07776; $code[000071] = *P00071; sub P00071 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000072] = 07777; $code[000072] = *P00072; sub P00072 { &emul8; goto &fetch; }
$core[000073] = 03512; $code[000073] = *P00073; sub P00073 { $core[($df<<12)+$core[74]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[74]] = *emul8; goto &fetch; }
$core[000074] = 00410; $code[000074] = *P00074; sub P00074 { $core[000010] = 0000 if ++$core[000010] == 010000; $lac &= (010000|$core[($df<<12)+$core[000010]]); goto &fetch; }
$core[000075] = 00552; $code[000075] = *P00075; sub P00075 { $lac &= (010000|$core[($df<<12)+$core[106]]); goto &fetch; }
$core[000076] = 00240; $code[000076] = *D00076; sub D00076 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000077] = 00260; $code[000077] = *D00077; sub D00077 { $lac &= (010000|$core[000060]); goto &fetch; }
$core[000100] = 00261; $code[000100] = *L00100; sub L00100 { $lac &= (010000|$core[000061]); goto &fetch; }
$core[000101] = 06000; $code[000101] = *P00101; sub P00101 { &emul8; goto &fetch; }
$core[000102] = 00102; $code[000102] = *P00102; sub P00102 { $lac &= (010000|$core[000102]); goto &fetch; }
$core[000103] = 04000; $code[000103] = *D00103; sub D00103 { $core[000000] = 00104; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000104] = 02000; $code[000104] = *P00104; sub P00104 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[000105] = 01000; $code[000105] = *D00105; sub D00105 { $lac += $core[000000]; goto &fetch; }
$core[000106] = 00400; $code[000106] = *D00106; sub D00106 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000107] = 00200; $code[000107] = *P00107; sub P00107 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000110] = 00100; $code[000110] = *P00110; sub P00110 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000111] = 00040; $code[000111] = *D00111; sub D00111 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000112] = 00020; $code[000112] = *P00112; sub P00112 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[000113] = 00010; $code[000113] = *D00113; sub D00113 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[000114] = 00004; $code[000114] = *P00114; sub P00114 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[000115] = 00002; $code[000115] = *P00115; sub P00115 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000116] = 00001; $code[000116] = *P00116; sub P00116 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000117] = 00000; $code[000117] = *I00117; sub I00117 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000120] = 04000; $code[000120] = *I00120; sub I00120 { $core[000000] = 00121; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000121] = 00001; $code[000121] = *I00121; sub I00121 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000122] = 02004; $code[000122] = *P00122; sub P00122 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[000123] = 02043; $code[000123] = *P00123; sub P00123 { if (++$core[000043] == 010000) { $core[000043] = 0; $pc++; }$code[000043] = *emul8; goto &fetch; }
$core[000124] = 02076; $code[000124] = *D00124; sub D00124 { if (++$core[000076] == 010000) { $core[000076] = 0; $pc++; }$code[000076] = *emul8; goto &fetch; }
$core[000125] = 02200; $code[000125] = *D00125; sub D00125 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[000126] = 02232; $code[000126] = *D00126; sub D00126 { if (++$core[000032] == 010000) { $core[000032] = 0; $pc++; }$code[000032] = *emul8; goto &fetch; }
$core[000127] = 02270; $code[000127] = *D00127; sub D00127 { if (++$core[000070] == 010000) { $core[000070] = 0; $pc++; }$code[000070] = *emul8; goto &fetch; }
$core[000130] = 02400; $code[000130] = *P00130; sub P00130 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[000131] = 02436; $code[000131] = *D00131; sub D00131 { if (++$core[($df<<12)+$core[30]] == 010000) { $core[($df<<12)+$core[30]] = 0; $pc++; }$code[($df<<12)+$core[30]] = *emul8; goto &fetch; }
$core[000132] = 02472; $code[000132] = *D00132; sub D00132 { if (++$core[($df<<12)+$core[58]] == 010000) { $core[($df<<12)+$core[58]] = 0; $pc++; }$code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[000133] = 02600; $code[000133] = *D00133; sub D00133 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[000134] = 02634; $code[000134] = *D00134; sub D00134 { if (++$core[($df<<12)+$core[28]] == 010000) { $core[($df<<12)+$core[28]] = 0; $pc++; }$code[($df<<12)+$core[28]] = *emul8; goto &fetch; }
$core[000135] = 02667; $code[000135] = *D00135; sub D00135 { if (++$core[($df<<12)+$core[55]] == 010000) { $core[($df<<12)+$core[55]] = 0; $pc++; }$code[($df<<12)+$core[55]] = *emul8; goto &fetch; }
$core[000136] = 01376; $code[000136] = *D00136; sub D00136 { $lac += $core[000176]; goto &fetch; }
$core[000137] = 07001; $code[000137] = *D00137; sub D00137 { $lac++; goto &fetch; }
$core[000140] = 05404; $code[000140] = *P00140; sub P00140 { $pc = ($ib<<12)+$core[4]; $inh = 0; goto &fetch; }
$core[000141] = 05402; $code[000141] = *D00141; sub D00141 { $pc = ($ib<<12)+$core[2]; $inh = 0; goto &fetch; }
$core[000142] = 07070; $code[000142] = *D00142; sub D00142 { $lac ^= 010000; $lac ^= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000143] = 02376; $code[000143] = *D00143; sub D00143 { if (++$core[000176] == 010000) { $core[000176] = 0; $pc++; }$code[000176] = *emul8; goto &fetch; }
$core[000144] = 02000; $code[000144] = *P00144; sub P00144 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[000145] = 02410; $code[000145] = *D00145; sub D00145 { $core[000010] = 0000 if ++$core[000010] == 010000; if (++$core[($df<<12)+$core[000010]] == 010000) { $core[($df<<12)+$core[000010]] = 0; $pc++; }$code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000146] = 04000; $code[000146] = *D00146; sub D00146 { $core[000000] = 00147; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000147] = 04776; $code[000147] = *D00147; sub D00147 { $core[($ib<<12)+$core[126]] = 00150; $pc = ($ib<<12)+$core[126]+1; $code[($ib<<12)+$core[126]] = *emul8; $inh = 0; goto &fetch; }
$core[000150] = 04410; $code[000150] = *P00150; sub P00150 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($ib<<12)+$core[000010]] = 00151; $pc = ($ib<<12)+$core[000010]+1; $code[($ib<<12)+$core[000010]] = *emul8; $inh = 0; goto &fetch; }
$core[000151] = 05403; $code[000151] = *D00151; sub D00151 { $pc = ($ib<<12)+$core[3]; $inh = 0; goto &fetch; }
$core[000152] = 05401; $code[000152] = *P00152; sub P00152 { $pc = ($ib<<12)+$core[1]; $inh = 0; goto &fetch; }
$core[000153] = 04377; $code[000153] = *D00153; sub D00153 { $core[000177] = 00154; $pc = 000177+1; $code[000177] = *emul8; $inh = 0; goto &fetch; }
$core[000154] = 02004; $code[000154] = *P00154; sub P00154 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[000155] = 05301; $code[000155] = *D00155; sub D00155 { $pc = 000101; $inh = 0; goto &fetch; }
$core[000156] = 06007; $code[000156] = *P00156; sub P00156 { &emul8; goto &fetch; }
$core[000157] = 07604; $code[000157] = *D00157; sub D00157 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000160] = 00106; $code[000160] = *I00160; sub I00160 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[000161] = 07650; $code[000161] = *I00161; sub I00161 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000162] = 05177; $code[000162] = *I00162; sub I00162 { $pc = 000177; $inh = 0; goto &fetch; }
$core[000163] = 07240; $code[000163] = *I00163; sub I00163 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000164] = 00170; $code[000164] = *I00164; sub I00164 { $lac &= (010000|$core[000170]); goto &fetch; }
$core[000165] = 03024; $code[000165] = *P00165; sub P00165 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[000166] = 05567; $code[000166] = *I00166; sub I00166 { $pc = ($ib<<12)+$core[119]; $inh = 0; goto &fetch; }
$core[000167] = 00202; $code[000167] = *P00167; sub P00167 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000170] = 00000; $code[000170] = *D00170; sub D00170 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000171] = 00000; $code[000171] = *P00171; sub P00171 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000172] = 00007; $code[000172] = *D00172; sub D00172 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000173] = 00070; $code[000173] = *D00173; sub D00173 { $lac &= (010000|$core[000070]); goto &fetch; }
$core[000174] = 00000; $code[000174] = *D00174; sub D00174 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000175] = 00000; $code[000175] = *D00175; sub D00175 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000176] = 00000; $code[000176] = *P00176; sub P00176 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000177] = 07410; $code[000177] = *L00177; sub L00177 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000200] = 05156; $code[000200] = *L00200; sub L00200 { $pc = 000156; $inh = 0; goto &fetch; }
$core[000201] = 03024; $code[000201] = *I00201; sub I00201 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[000202] = 03023; $code[000202] = *L00202; sub L00202 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[000203] = 03035; $code[000203] = *I00203; sub I00203 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[000204] = 07340; $code[000204] = *L00204; sub L00204 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000205] = 00023; $code[000205] = *I00205; sub I00205 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000206] = 07421; $code[000206] = *I00206; sub I00206 { &emul8; goto &fetch; }
$core[000207] = 07040; $code[000207] = *I00207; sub I00207 { $lac ^= 07777; goto &fetch; }
$core[000210] = 00024; $code[000210] = *I00210; sub I00210 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000211] = 07501; $code[000211] = *I00211; sub I00211 { &emul8; goto &fetch; }
$core[000212] = 03027; $code[000212] = *I00212; sub I00212 { $core[000027] = $lac & 07777; $lac &= 010000; $code[000027] = *emul8; goto &fetch; }
$core[000213] = 07501; $code[000213] = *I00213; sub I00213 { &emul8; goto &fetch; }
$core[000214] = 07040; $code[000214] = *I00214; sub I00214 { $lac ^= 07777; goto &fetch; }
$core[000215] = 00024; $code[000215] = *I00215; sub I00215 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000216] = 07421; $code[000216] = *I00216; sub I00216 { &emul8; goto &fetch; }
$core[000217] = 07040; $code[000217] = *I00217; sub I00217 { $lac ^= 07777; goto &fetch; }
$core[000220] = 00024; $code[000220] = *I00220; sub I00220 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000221] = 07040; $code[000221] = *I00221; sub I00221 { $lac ^= 07777; goto &fetch; }
$core[000222] = 00023; $code[000222] = *I00222; sub I00222 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000223] = 07501; $code[000223] = *I00223; sub I00223 { &emul8; goto &fetch; }
$core[000224] = 03025; $code[000224] = *I00224; sub I00224 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[000225] = 03026; $code[000225] = *I00225; sub I00225 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[000226] = 07040; $code[000226] = *I00226; sub I00226 { $lac ^= 07777; goto &fetch; }
$core[000227] = 00023; $code[000227] = *I00227; sub I00227 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000230] = 00024; $code[000230] = *I00230; sub I00230 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000231] = 07450; $code[000231] = *I00231; sub I00231 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000232] = 05274; $code[000232] = *I00232; sub I00232 { $pc = 000274; $inh = 0; goto &fetch; }
$core[000233] = 07421; $code[000233] = *I00233; sub I00233 { &emul8; goto &fetch; }
$core[000234] = 07521; $code[000234] = *L00234; sub L00234 { &emul8; goto &fetch; }
$core[000235] = 00027; $code[000235] = *I00235; sub I00235 { $lac &= (010000|$core[000027]); goto &fetch; }
$core[000236] = 07450; $code[000236] = *I00236; sub I00236 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000237] = 05244; $code[000237] = *I00237; sub I00237 { $pc = 000244; $inh = 0; goto &fetch; }
$core[000240] = 07104; $code[000240] = *I00240; sub I00240 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000241] = 07521; $code[000241] = *I00241; sub I00241 { &emul8; goto &fetch; }
$core[000242] = 07501; $code[000242] = *I00242; sub I00242 { &emul8; goto &fetch; }
$core[000243] = 05234; $code[000243] = *I00243; sub I00243 { $pc = 000234; $inh = 0; goto &fetch; }
$core[000244] = 07501; $code[000244] = *L00244; sub L00244 { &emul8; goto &fetch; }
$core[000245] = 00027; $code[000245] = *I00245; sub I00245 { $lac &= (010000|$core[000027]); goto &fetch; }
$core[000246] = 00103; $code[000246] = *I00246; sub I00246 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[000247] = 07450; $code[000247] = *I00247; sub I00247 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000250] = 05253; $code[000250] = *I00250; sub I00250 { $pc = 000253; $inh = 0; goto &fetch; }
$core[000251] = 03026; $code[000251] = *I00251; sub I00251 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[000252] = 05260; $code[000252] = *I00252; sub I00252 { $pc = 000260; $inh = 0; goto &fetch; }
$core[000253] = 07130; $code[000253] = *L00253; sub L00253 { $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000254] = 00023; $code[000254] = *I00254; sub I00254 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000255] = 00024; $code[000255] = *I00255; sub I00255 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000256] = 07440; $code[000256] = *I00256; sub I00256 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000257] = 03026; $code[000257] = *I00257; sub I00257 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[000260] = 07501; $code[000260] = *L00260; sub L00260 { &emul8; goto &fetch; }
$core[000261] = 03030; $code[000261] = *I00261; sub I00261 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[000262] = 07501; $code[000262] = *I00262; sub I00262 { &emul8; goto &fetch; }
$core[000263] = 07040; $code[000263] = *I00263; sub I00263 { $lac ^= 07777; goto &fetch; }
$core[000264] = 00025; $code[000264] = *I00264; sub I00264 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[000265] = 07421; $code[000265] = *I00265; sub I00265 { &emul8; goto &fetch; }
$core[000266] = 07040; $code[000266] = *I00266; sub I00266 { $lac ^= 07777; goto &fetch; }
$core[000267] = 00025; $code[000267] = *I00267; sub I00267 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[000270] = 07040; $code[000270] = *I00270; sub I00270 { $lac ^= 07777; goto &fetch; }
$core[000271] = 00030; $code[000271] = *I00271; sub I00271 { $lac &= (010000|$core[000030]); goto &fetch; }
$core[000272] = 07501; $code[000272] = *I00272; sub I00272 { &emul8; goto &fetch; }
$core[000273] = 03025; $code[000273] = *I00273; sub I00273 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[000274] = 07340; $code[000274] = *L00274; sub L00274 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000275] = 00023; $code[000275] = *I00275; sub I00275 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000276] = 01024; $code[000276] = *I00276; sub I00276 { $lac += $core[000024]; goto &fetch; }
$core[000277] = 07000; $code[000277] = *I00277; sub I00277 { goto &fetch; }
$core[000300] = 03031; $code[000300] = *I00300; sub I00300 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[000301] = 07010; $code[000301] = *I00301; sub I00301 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000302] = 03032; $code[000302] = *I00302; sub I00302 { $core[000032] = $lac & 07777; $lac &= 010000; $code[000032] = *emul8; goto &fetch; }
$core[000303] = 07040; $code[000303] = *I00303; sub I00303 { $lac ^= 07777; goto &fetch; }
$core[000304] = 00024; $code[000304] = *I00304; sub I00304 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000305] = 01023; $code[000305] = *I00305; sub I00305 { $lac += $core[000023]; goto &fetch; }
$core[000306] = 07000; $code[000306] = *I00306; sub I00306 { goto &fetch; }
$core[000307] = 03033; $code[000307] = *I00307; sub I00307 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[000310] = 07010; $code[000310] = *I00310; sub I00310 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000311] = 03034; $code[000311] = *I00311; sub I00311 { $core[000034] = $lac & 07777; $lac &= 010000; $code[000034] = *emul8; goto &fetch; }
$core[000312] = 07000; $code[000312] = *I00312; sub I00312 { goto &fetch; }
$core[000313] = 07340; $code[000313] = *I00313; sub I00313 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000314] = 00031; $code[000314] = *I00314; sub I00314 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[000315] = 07040; $code[000315] = *I00315; sub I00315 { $lac ^= 07777; goto &fetch; }
$core[000316] = 00033; $code[000316] = *I00316; sub I00316 { $lac &= (010000|$core[000033]); goto &fetch; }
$core[000317] = 07440; $code[000317] = *I00317; sub I00317 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000320] = 05377; $code[000320] = *I00320; sub I00320 { $pc = 000377; $inh = 0; goto &fetch; }
$core[000321] = 07040; $code[000321] = *I00321; sub I00321 { $lac ^= 07777; goto &fetch; }
$core[000322] = 00033; $code[000322] = *I00322; sub I00322 { $lac &= (010000|$core[000033]); goto &fetch; }
$core[000323] = 07040; $code[000323] = *I00323; sub I00323 { $lac ^= 07777; goto &fetch; }
$core[000324] = 00031; $code[000324] = *I00324; sub I00324 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[000325] = 07440; $code[000325] = *I00325; sub I00325 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000326] = 05377; $code[000326] = *I00326; sub I00326 { $pc = 000377; $inh = 0; goto &fetch; }
$core[000327] = 07340; $code[000327] = *I00327; sub I00327 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000330] = 00031; $code[000330] = *I00330; sub I00330 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[000331] = 07040; $code[000331] = *I00331; sub I00331 { $lac ^= 07777; goto &fetch; }
$core[000332] = 00025; $code[000332] = *I00332; sub I00332 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[000333] = 07440; $code[000333] = *I00333; sub I00333 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000334] = 05377; $code[000334] = *I00334; sub I00334 { $pc = 000377; $inh = 0; goto &fetch; }
$core[000335] = 07040; $code[000335] = *I00335; sub I00335 { $lac ^= 07777; goto &fetch; }
$core[000336] = 00025; $code[000336] = *I00336; sub I00336 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[000337] = 07040; $code[000337] = *I00337; sub I00337 { $lac ^= 07777; goto &fetch; }
$core[000340] = 00031; $code[000340] = *I00340; sub I00340 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[000341] = 07440; $code[000341] = *I00341; sub I00341 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000342] = 05377; $code[000342] = *I00342; sub I00342 { $pc = 000377; $inh = 0; goto &fetch; }
$core[000343] = 07340; $code[000343] = *I00343; sub I00343 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000344] = 00032; $code[000344] = *I00344; sub I00344 { $lac &= (010000|$core[000032]); goto &fetch; }
$core[000345] = 07004; $code[000345] = *I00345; sub I00345 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000346] = 07240; $code[000346] = *I00346; sub I00346 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000347] = 00034; $code[000347] = *I00347; sub I00347 { $lac &= (010000|$core[000034]); goto &fetch; }
$core[000350] = 07640; $code[000350] = *I00350; sub I00350 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000351] = 07020; $code[000351] = *I00351; sub I00351 { $lac ^= 010000; goto &fetch; }
$core[000352] = 07430; $code[000352] = *I00352; sub I00352 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000353] = 05377; $code[000353] = *I00353; sub I00353 { $pc = 000377; $inh = 0; goto &fetch; }
$core[000354] = 07340; $code[000354] = *I00354; sub I00354 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000355] = 00032; $code[000355] = *I00355; sub I00355 { $lac &= (010000|$core[000032]); goto &fetch; }
$core[000356] = 07004; $code[000356] = *I00356; sub I00356 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000357] = 07240; $code[000357] = *I00357; sub I00357 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000360] = 00026; $code[000360] = *I00360; sub I00360 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[000361] = 07640; $code[000361] = *I00361; sub I00361 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000362] = 07020; $code[000362] = *I00362; sub I00362 { $lac ^= 010000; goto &fetch; }
$core[000363] = 07430; $code[000363] = *I00363; sub I00363 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000364] = 05377; $code[000364] = *I00364; sub I00364 { $pc = 000377; $inh = 0; goto &fetch; }
$core[000365] = 05474; $code[000365] = *I00365; sub I00365 { $pc = ($ib<<12)+$core[60]; $inh = 0; goto &fetch; }
$core[000366] = 02023; $code[000366] = *L00366; sub L00366 { if (++$core[000023] == 010000) { $core[000023] = 0; $pc++; }$code[000023] = *emul8; goto &fetch; }
$core[000367] = 05204; $code[000367] = *I00367; sub I00367 { $pc = 000204; $inh = 0; goto &fetch; }
$core[000370] = 02024; $code[000370] = *I00370; sub I00370 { if (++$core[000024] == 010000) { $core[000024] = 0; $pc++; }$code[000024] = *emul8; goto &fetch; }
$core[000371] = 07410; $code[000371] = *I00371; sub I00371 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000372] = 05475; $code[000372] = *I00372; sub I00372 { $pc = ($ib<<12)+$core[61]; $inh = 0; goto &fetch; }
$core[000373] = 07240; $code[000373] = *I00373; sub I00373 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000374] = 00024; $code[000374] = *I00374; sub I00374 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000375] = 03023; $code[000375] = *I00375; sub I00375 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[000376] = 05204; $code[000376] = *I00376; sub I00376 { $pc = 000204; $inh = 0; goto &fetch; }
$core[000377] = 07000; $code[000377] = *L00377; sub L00377 { goto &fetch; }
$core[000400] = 07604; $code[000400] = *L00400; sub L00400 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000401] = 00104; $code[000401] = *I00401; sub I00401 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[000402] = 07650; $code[000402] = *I00402; sub I00402 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000403] = 04217; $code[000403] = *I00403; sub I00403 { $core[000417] = 00404; $pc = 000417+1; $code[000417] = *emul8; $inh = 0; goto &fetch; }
$core[000404] = 07604; $code[000404] = *L00404; sub L00404 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000405] = 00103; $code[000405] = *I00405; sub I00405 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[000406] = 07650; $code[000406] = *I00406; sub I00406 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000407] = 04277; $code[000407] = *I00407; sub I00407 { $core[000477] = 00410; $pc = 000477+1; $code[000477] = *emul8; $inh = 0; goto &fetch; }
$core[000410] = 07604; $code[000410] = *L00410; sub L00410 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000411] = 00105; $code[000411] = *I00411; sub I00411 { $lac &= (010000|$core[000105]); goto &fetch; }
$core[000412] = 07640; $code[000412] = *I00412; sub I00412 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000413] = 05615; $code[000413] = *I00413; sub I00413 { $pc = ($ib<<12)+$core[269]; $inh = 0; goto &fetch; }
$core[000414] = 05616; $code[000414] = *I00414; sub I00414 { $pc = ($ib<<12)+$core[270]; $inh = 0; goto &fetch; }
$core[000415] = 00274; $code[000415] = *P00415; sub P00415 { $lac &= (010000|$core[000474]); goto &fetch; }
$core[000416] = 00366; $code[000416] = *P00416; sub P00416 { $lac &= (010000|$core[000566]); goto &fetch; }
$core[000417] = 00000; $code[000417] = *D00417; sub D00417 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000420] = 07340; $code[000420] = *I00420; sub I00420 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000421] = 00035; $code[000421] = *I00421; sub I00421 { $lac &= (010000|$core[000035]); goto &fetch; }
$core[000422] = 07650; $code[000422] = *I00422; sub I00422 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000423] = 04267; $code[000423] = *I00423; sub I00423 { $core[000467] = 00424; $pc = 000467+1; $code[000467] = *emul8; $inh = 0; goto &fetch; }
$core[000424] = 07040; $code[000424] = *I00424; sub I00424 { $lac ^= 07777; goto &fetch; }
$core[000425] = 00023; $code[000425] = *I00425; sub I00425 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000426] = 03037; $code[000426] = *I00426; sub I00426 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[000427] = 04323; $code[000427] = *I00427; sub I00427 { $core[000523] = 00430; $pc = 000523+1; $code[000523] = *emul8; $inh = 0; goto &fetch; }
$core[000430] = 07040; $code[000430] = *I00430; sub I00430 { $lac ^= 07777; goto &fetch; }
$core[000431] = 00024; $code[000431] = *I00431; sub I00431 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000432] = 03037; $code[000432] = *I00432; sub I00432 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[000433] = 04323; $code[000433] = *I00433; sub I00433 { $core[000523] = 00434; $pc = 000523+1; $code[000523] = *emul8; $inh = 0; goto &fetch; }
$core[000434] = 07040; $code[000434] = *I00434; sub I00434 { $lac ^= 07777; goto &fetch; }
$core[000435] = 00026; $code[000435] = *I00435; sub I00435 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[000436] = 03040; $code[000436] = *I00436; sub I00436 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[000437] = 07040; $code[000437] = *I00437; sub I00437 { $lac ^= 07777; goto &fetch; }
$core[000440] = 00025; $code[000440] = *I00440; sub I00440 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[000441] = 03037; $code[000441] = *I00441; sub I00441 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[000442] = 04304; $code[000442] = *I00442; sub I00442 { $core[000504] = 00443; $pc = 000504+1; $code[000504] = *emul8; $inh = 0; goto &fetch; }
$core[000443] = 04323; $code[000443] = *I00443; sub I00443 { $core[000523] = 00444; $pc = 000523+1; $code[000523] = *emul8; $inh = 0; goto &fetch; }
$core[000444] = 07040; $code[000444] = *I00444; sub I00444 { $lac ^= 07777; goto &fetch; }
$core[000445] = 00032; $code[000445] = *I00445; sub I00445 { $lac &= (010000|$core[000032]); goto &fetch; }
$core[000446] = 03040; $code[000446] = *I00446; sub I00446 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[000447] = 07040; $code[000447] = *I00447; sub I00447 { $lac ^= 07777; goto &fetch; }
$core[000450] = 00031; $code[000450] = *I00450; sub I00450 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[000451] = 03037; $code[000451] = *I00451; sub I00451 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[000452] = 04304; $code[000452] = *I00452; sub I00452 { $core[000504] = 00453; $pc = 000504+1; $code[000504] = *emul8; $inh = 0; goto &fetch; }
$core[000453] = 04323; $code[000453] = *I00453; sub I00453 { $core[000523] = 00454; $pc = 000523+1; $code[000523] = *emul8; $inh = 0; goto &fetch; }
$core[000454] = 07040; $code[000454] = *I00454; sub I00454 { $lac ^= 07777; goto &fetch; }
$core[000455] = 00034; $code[000455] = *I00455; sub I00455 { $lac &= (010000|$core[000034]); goto &fetch; }
$core[000456] = 03040; $code[000456] = *I00456; sub I00456 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[000457] = 07040; $code[000457] = *I00457; sub I00457 { $lac ^= 07777; goto &fetch; }
$core[000460] = 00033; $code[000460] = *I00460; sub I00460 { $lac &= (010000|$core[000033]); goto &fetch; }
$core[000461] = 03037; $code[000461] = *I00461; sub I00461 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[000462] = 04304; $code[000462] = *I00462; sub I00462 { $core[000504] = 00463; $pc = 000504+1; $code[000504] = *emul8; $inh = 0; goto &fetch; }
$core[000463] = 04323; $code[000463] = *I00463; sub I00463 { $core[000523] = 00464; $pc = 000523+1; $code[000523] = *emul8; $inh = 0; goto &fetch; }
$core[000464] = 04446; $code[000464] = *I00464; sub I00464 { $core[($ib<<12)+$core[38]] = 00465; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[000465] = 05742; $code[000465] = *I00465; sub I00465 { $pc = ($ib<<12)+$core[354]; $inh = 0; goto &fetch; }
$core[000466] = 05204; $code[000466] = *I00466; sub I00466 { $pc = 000404; $inh = 0; goto &fetch; }
$core[000467] = 00000; $code[000467] = *S00467; sub S00467 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000470] = 04446; $code[000470] = *I00470; sub I00470 { $core[($ib<<12)+$core[38]] = 00471; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[000471] = 05417; $code[000471] = *I00471; sub I00471 { $core[000017] = 0000 if ++$core[000017] == 010000; $pc = ($ib<<12)+$core[000017]; $inh = 0; goto &fetch; }
$core[000472] = 04446; $code[000472] = *I00472; sub I00472 { $core[($ib<<12)+$core[38]] = 00473; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[000473] = 05177; $code[000473] = *I00473; sub I00473 { $pc = 000177; $inh = 0; goto &fetch; }
$core[000474] = 07240; $code[000474] = *D00474; sub D00474 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000475] = 03035; $code[000475] = *I00475; sub I00475 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[000476] = 05667; $code[000476] = *I00476; sub I00476 { $pc = ($ib<<12)+$core[311]; $inh = 0; goto &fetch; }
$core[000477] = 00000; $code[000477] = *S00477; sub S00477 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000500] = 07240; $code[000500] = *I00500; sub I00500 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000501] = 00351; $code[000501] = *I00501; sub I00501 { $lac &= (010000|$core[000551]); goto &fetch; }
$core[000502] = 07402; $code[000502] = *I00502; sub I00502 { $hlt = 1; goto &fetch; }
$core[000503] = 05677; $code[000503] = *I00503; sub I00503 { $pc = ($ib<<12)+$core[319]; $inh = 0; goto &fetch; }
$core[000504] = 00000; $code[000504] = *S00504; sub S00504 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000505] = 07340; $code[000505] = *I00505; sub I00505 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000506] = 00040; $code[000506] = *I00506; sub I00506 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000507] = 07640; $code[000507] = *D00507; sub D00507 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000510] = 05320; $code[000510] = *I00510; sub I00510 { $pc = 000520; $inh = 0; goto &fetch; }
$core[000511] = 07040; $code[000511] = *I00511; sub I00511 { $lac ^= 07777; goto &fetch; }
$core[000512] = 00077; $code[000512] = *I00512; sub I00512 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[000513] = 04447; $code[000513] = *L00513; sub L00513 { $core[($ib<<12)+$core[39]] = 00514; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[000514] = 07040; $code[000514] = *I00514; sub I00514 { $lac ^= 07777; goto &fetch; }
$core[000515] = 00076; $code[000515] = *I00515; sub I00515 { $lac &= (010000|$core[000076]); goto &fetch; }
$core[000516] = 04447; $code[000516] = *I00516; sub I00516 { $core[($ib<<12)+$core[39]] = 00517; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[000517] = 05704; $code[000517] = *I00517; sub I00517 { $pc = ($ib<<12)+$core[324]; $inh = 0; goto &fetch; }
$core[000520] = 07040; $code[000520] = *L00520; sub L00520 { $lac ^= 07777; goto &fetch; }
$core[000521] = 00100; $code[000521] = *P00521; sub P00521 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000522] = 05313; $code[000522] = *I00522; sub I00522 { $pc = 000513; $inh = 0; goto &fetch; }
$core[000523] = 00000; $code[000523] = *S00523; sub S00523 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000524] = 07340; $code[000524] = *I00524; sub I00524 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000525] = 00102; $code[000525] = *I00525; sub I00525 { $lac &= (010000|$core[000102]); goto &fetch; }
$core[000526] = 03011; $code[000526] = *I00526; sub I00526 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000527] = 07040; $code[000527] = *L00527; sub L00527 { $lac ^= 07777; goto &fetch; }
$core[000530] = 00411; $code[000530] = *I00530; sub I00530 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac &= (010000|$core[($df<<12)+$core[000011]]); goto &fetch; }
$core[000531] = 07450; $code[000531] = *I00531; sub I00531 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000532] = 05345; $code[000532] = *I00532; sub I00532 { $pc = 000545; $inh = 0; goto &fetch; }
$core[000533] = 00037; $code[000533] = *I00533; sub I00533 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[000534] = 07640; $code[000534] = *I00534; sub I00534 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000535] = 05342; $code[000535] = *I00535; sub I00535 { $pc = 000542; $inh = 0; goto &fetch; }
$core[000536] = 07040; $code[000536] = *I00536; sub I00536 { $lac ^= 07777; goto &fetch; }
$core[000537] = 00077; $code[000537] = *I00537; sub I00537 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[000540] = 04447; $code[000540] = *L00540; sub L00540 { $core[($ib<<12)+$core[39]] = 00541; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[000541] = 05327; $code[000541] = *I00541; sub I00541 { $pc = 000527; $inh = 0; goto &fetch; }
$core[000542] = 07040; $code[000542] = *P00542; sub P00542 { $lac ^= 07777; goto &fetch; }
$core[000543] = 00100; $code[000543] = *I00543; sub I00543 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000544] = 05340; $code[000544] = *I00544; sub I00544 { $pc = 000540; $inh = 0; goto &fetch; }
$core[000545] = 07040; $code[000545] = *L00545; sub L00545 { $lac ^= 07777; goto &fetch; }
$core[000546] = 00076; $code[000546] = *I00546; sub I00546 { $lac &= (010000|$core[000076]); goto &fetch; }
$core[000547] = 04447; $code[000547] = *I00547; sub I00547 { $core[($ib<<12)+$core[39]] = 00550; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[000550] = 05723; $code[000550] = *I00550; sub I00550 { $pc = ($ib<<12)+$core[339]; $inh = 0; goto &fetch; }
$core[000551] = 00204; $code[000551] = *D00551; sub D00551 { $lac &= (010000|$core[000404]); goto &fetch; }
$core[000552] = 07604; $code[000552] = *L00552; sub L00552 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000553] = 00115; $code[000553] = *I00553; sub I00553 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[000554] = 07650; $code[000554] = *I00554; sub I00554 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000555] = 05370; $code[000555] = *I00555; sub I00555 { $pc = 000570; $inh = 0; goto &fetch; }
$core[000556] = 07604; $code[000556] = *L00556; sub L00556 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000557] = 00114; $code[000557] = *I00557; sub I00557 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[000560] = 07640; $code[000560] = *I00560; sub I00560 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000561] = 07402; $code[000561] = *I00561; sub I00561 { $hlt = 1; goto &fetch; }
$core[000562] = 07604; $code[000562] = *I00562; sub I00562 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000563] = 00116; $code[000563] = *I00563; sub I00563 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[000564] = 07650; $code[000564] = *I00564; sub I00564 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000565] = 05377; $code[000565] = *I00565; sub I00565 { $pc = 000577; $inh = 0; goto &fetch; }
$core[000566] = 05767; $code[000566] = *D00566; sub D00566 { $pc = ($ib<<12)+$core[375]; $inh = 0; goto &fetch; }
$core[000567] = 00204; $code[000567] = *P00567; sub P00567 { $lac &= (010000|$core[000404]); goto &fetch; }
$core[000570] = 04446; $code[000570] = *L00570; sub L00570 { $core[($ib<<12)+$core[38]] = 00571; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[000571] = 05721; $code[000571] = *I00571; sub I00571 { $pc = ($ib<<12)+$core[337]; $inh = 0; goto &fetch; }
$core[000572] = 05356; $code[000572] = *I00572; sub I00572 { $pc = 000556; $inh = 0; goto &fetch; }
$core[000577] = 07000; $code[000577] = *L00577; sub L00577 { goto &fetch; }
$core[000600] = 04752; $code[000600] = *L00600; sub L00600 { $core[($ib<<12)+$core[490]] = 00601; $pc = ($ib<<12)+$core[490]+1; $code[($ib<<12)+$core[490]] = *emul8; $inh = 0; goto &fetch; }
$core[000601] = 07340; $code[000601] = *L00601; sub L00601 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000602] = 00052; $code[000602] = *I00602; sub I00602 { $lac &= (010000|$core[000052]); goto &fetch; }
$core[000603] = 03012; $code[000603] = *I00603; sub I00603 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[000604] = 04451; $code[000604] = *I00604; sub I00604 { $core[($ib<<12)+$core[41]] = 00605; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[000605] = 07340; $code[000605] = *L00605; sub L00605 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000606] = 00024; $code[000606] = *I00606; sub I00606 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000607] = 07640; $code[000607] = *I00607; sub I00607 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000610] = 07020; $code[000610] = *I00610; sub I00610 { $lac ^= 010000; goto &fetch; }
$core[000611] = 07040; $code[000611] = *I00611; sub I00611 { $lac ^= 07777; goto &fetch; }
$core[000612] = 00023; $code[000612] = *I00612; sub I00612 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000613] = 07004; $code[000613] = *I00613; sub I00613 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000614] = 07000; $code[000614] = *I00614; sub I00614 { goto &fetch; }
$core[000615] = 03031; $code[000615] = *I00615; sub I00615 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[000616] = 07430; $code[000616] = *I00616; sub I00616 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000617] = 07040; $code[000617] = *I00617; sub I00617 { $lac ^= 07777; goto &fetch; }
$core[000620] = 03033; $code[000620] = *I00620; sub I00620 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[000621] = 04456; $code[000621] = *I00621; sub I00621 { $core[($ib<<12)+$core[46]] = 00622; $pc = ($ib<<12)+$core[46]+1; $code[($ib<<12)+$core[46]] = *emul8; $inh = 0; goto &fetch; }
$core[000622] = 05205; $code[000622] = *I00622; sub I00622 { $pc = 000605; $inh = 0; goto &fetch; }
$core[000623] = 04457; $code[000623] = *I00623; sub I00623 { $core[($ib<<12)+$core[47]] = 00624; $pc = ($ib<<12)+$core[47]+1; $code[($ib<<12)+$core[47]] = *emul8; $inh = 0; goto &fetch; }
$core[000624] = 05201; $code[000624] = *I00624; sub I00624 { $pc = 000601; $inh = 0; goto &fetch; }
$core[000625] = 04753; $code[000625] = *I00625; sub I00625 { $core[($ib<<12)+$core[491]] = 00626; $pc = ($ib<<12)+$core[491]+1; $code[($ib<<12)+$core[491]] = *emul8; $inh = 0; goto &fetch; }
$core[000626] = 07340; $code[000626] = *L00626; sub L00626 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000627] = 00102; $code[000627] = *I00627; sub I00627 { $lac &= (010000|$core[000102]); goto &fetch; }
$core[000630] = 03012; $code[000630] = *I00630; sub I00630 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[000631] = 04451; $code[000631] = *I00631; sub I00631 { $core[($ib<<12)+$core[41]] = 00632; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[000632] = 07340; $code[000632] = *L00632; sub L00632 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000633] = 00024; $code[000633] = *I00633; sub I00633 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000634] = 07640; $code[000634] = *I00634; sub I00634 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000635] = 07020; $code[000635] = *I00635; sub I00635 { $lac ^= 010000; goto &fetch; }
$core[000636] = 07040; $code[000636] = *D00636; sub D00636 { $lac ^= 07777; goto &fetch; }
$core[000637] = 00023; $code[000637] = *I00637; sub I00637 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000640] = 07010; $code[000640] = *I00640; sub I00640 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000641] = 07000; $code[000641] = *I00641; sub I00641 { goto &fetch; }
$core[000642] = 03031; $code[000642] = *I00642; sub I00642 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[000643] = 07430; $code[000643] = *I00643; sub I00643 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000644] = 07040; $code[000644] = *I00644; sub I00644 { $lac ^= 07777; goto &fetch; }
$core[000645] = 03033; $code[000645] = *I00645; sub I00645 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[000646] = 04456; $code[000646] = *I00646; sub I00646 { $core[($ib<<12)+$core[46]] = 00647; $pc = ($ib<<12)+$core[46]+1; $code[($ib<<12)+$core[46]] = *emul8; $inh = 0; goto &fetch; }
$core[000647] = 05232; $code[000647] = *I00647; sub I00647 { $pc = 000632; $inh = 0; goto &fetch; }
$core[000650] = 04457; $code[000650] = *I00650; sub I00650 { $core[($ib<<12)+$core[47]] = 00651; $pc = ($ib<<12)+$core[47]+1; $code[($ib<<12)+$core[47]] = *emul8; $inh = 0; goto &fetch; }
$core[000651] = 05226; $code[000651] = *I00651; sub I00651 { $pc = 000626; $inh = 0; goto &fetch; }
$core[000652] = 04754; $code[000652] = *I00652; sub I00652 { $core[($ib<<12)+$core[492]] = 00653; $pc = ($ib<<12)+$core[492]+1; $code[($ib<<12)+$core[492]] = *emul8; $inh = 0; goto &fetch; }
$core[000653] = 07340; $code[000653] = *L00653; sub L00653 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000654] = 00053; $code[000654] = *I00654; sub I00654 { $lac &= (010000|$core[000053]); goto &fetch; }
$core[000655] = 03012; $code[000655] = *I00655; sub I00655 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[000656] = 04451; $code[000656] = *I00656; sub I00656 { $core[($ib<<12)+$core[41]] = 00657; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[000657] = 07340; $code[000657] = *L00657; sub L00657 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000660] = 00024; $code[000660] = *I00660; sub I00660 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000661] = 07640; $code[000661] = *I00661; sub I00661 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000662] = 07020; $code[000662] = *I00662; sub I00662 { $lac ^= 010000; goto &fetch; }
$core[000663] = 07040; $code[000663] = *I00663; sub I00663 { $lac ^= 07777; goto &fetch; }
$core[000664] = 00023; $code[000664] = *I00664; sub I00664 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000665] = 07006; $code[000665] = *I00665; sub I00665 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000666] = 07000; $code[000666] = *I00666; sub I00666 { goto &fetch; }
$core[000667] = 03031; $code[000667] = *I00667; sub I00667 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[000670] = 07430; $code[000670] = *I00670; sub I00670 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000671] = 07040; $code[000671] = *I00671; sub I00671 { $lac ^= 07777; goto &fetch; }
$core[000672] = 03033; $code[000672] = *I00672; sub I00672 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[000673] = 04456; $code[000673] = *I00673; sub I00673 { $core[($ib<<12)+$core[46]] = 00674; $pc = ($ib<<12)+$core[46]+1; $code[($ib<<12)+$core[46]] = *emul8; $inh = 0; goto &fetch; }
$core[000674] = 05257; $code[000674] = *I00674; sub I00674 { $pc = 000657; $inh = 0; goto &fetch; }
$core[000675] = 04457; $code[000675] = *I00675; sub I00675 { $core[($ib<<12)+$core[47]] = 00676; $pc = ($ib<<12)+$core[47]+1; $code[($ib<<12)+$core[47]] = *emul8; $inh = 0; goto &fetch; }
$core[000676] = 05253; $code[000676] = *I00676; sub I00676 { $pc = 000653; $inh = 0; goto &fetch; }
$core[000677] = 04755; $code[000677] = *I00677; sub I00677 { $core[($ib<<12)+$core[493]] = 00700; $pc = ($ib<<12)+$core[493]+1; $code[($ib<<12)+$core[493]] = *emul8; $inh = 0; goto &fetch; }
$core[000700] = 07340; $code[000700] = *L00700; sub L00700 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000701] = 00054; $code[000701] = *I00701; sub I00701 { $lac &= (010000|$core[000054]); goto &fetch; }
$core[000702] = 03012; $code[000702] = *I00702; sub I00702 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[000703] = 04451; $code[000703] = *I00703; sub I00703 { $core[($ib<<12)+$core[41]] = 00704; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[000704] = 07340; $code[000704] = *L00704; sub L00704 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000705] = 00024; $code[000705] = *I00705; sub I00705 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000706] = 07640; $code[000706] = *I00706; sub I00706 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000707] = 07020; $code[000707] = *I00707; sub I00707 { $lac ^= 010000; goto &fetch; }
$core[000710] = 07040; $code[000710] = *I00710; sub I00710 { $lac ^= 07777; goto &fetch; }
$core[000711] = 00023; $code[000711] = *I00711; sub I00711 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000712] = 07012; $code[000712] = *I00712; sub I00712 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000713] = 07000; $code[000713] = *I00713; sub I00713 { goto &fetch; }
$core[000714] = 03031; $code[000714] = *I00714; sub I00714 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[000715] = 07430; $code[000715] = *I00715; sub I00715 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000716] = 07040; $code[000716] = *I00716; sub I00716 { $lac ^= 07777; goto &fetch; }
$core[000717] = 03033; $code[000717] = *I00717; sub I00717 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[000720] = 04456; $code[000720] = *I00720; sub I00720 { $core[($ib<<12)+$core[46]] = 00721; $pc = ($ib<<12)+$core[46]+1; $code[($ib<<12)+$core[46]] = *emul8; $inh = 0; goto &fetch; }
$core[000721] = 05304; $code[000721] = *I00721; sub I00721 { $pc = 000704; $inh = 0; goto &fetch; }
$core[000722] = 04457; $code[000722] = *I00722; sub I00722 { $core[($ib<<12)+$core[47]] = 00723; $pc = ($ib<<12)+$core[47]+1; $code[($ib<<12)+$core[47]] = *emul8; $inh = 0; goto &fetch; }
$core[000723] = 05300; $code[000723] = *D00723; sub D00723 { $pc = 000700; $inh = 0; goto &fetch; }
$core[000724] = 04756; $code[000724] = *I00724; sub I00724 { $core[($ib<<12)+$core[494]] = 00725; $pc = ($ib<<12)+$core[494]+1; $code[($ib<<12)+$core[494]] = *emul8; $inh = 0; goto &fetch; }
$core[000725] = 07340; $code[000725] = *L00725; sub L00725 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000726] = 00055; $code[000726] = *I00726; sub I00726 { $lac &= (010000|$core[000055]); goto &fetch; }
$core[000727] = 03012; $code[000727] = *I00727; sub I00727 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[000730] = 04776; $code[000730] = *I00730; sub I00730 { $core[($ib<<12)+$core[510]] = 00731; $pc = ($ib<<12)+$core[510]+1; $code[($ib<<12)+$core[510]] = *emul8; $inh = 0; goto &fetch; }
$core[000731] = 07340; $code[000731] = *L00731; sub L00731 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[000732] = 00024; $code[000732] = *I00732; sub I00732 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[000733] = 07640; $code[000733] = *I00733; sub I00733 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000734] = 07020; $code[000734] = *I00734; sub I00734 { $lac ^= 010000; goto &fetch; }
$core[000735] = 07040; $code[000735] = *I00735; sub I00735 { $lac ^= 07777; goto &fetch; }
$core[000736] = 00023; $code[000736] = *I00736; sub I00736 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[000737] = 07002; $code[000737] = *I00737; sub I00737 { $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[000740] = 07000; $code[000740] = *I00740; sub I00740 { goto &fetch; }
$core[000741] = 03031; $code[000741] = *I00741; sub I00741 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[000742] = 07430; $code[000742] = *I00742; sub I00742 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000743] = 07040; $code[000743] = *I00743; sub I00743 { $lac ^= 07777; goto &fetch; }
$core[000744] = 03033; $code[000744] = *I00744; sub I00744 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[000745] = 04456; $code[000745] = *I00745; sub I00745 { $core[($ib<<12)+$core[46]] = 00746; $pc = ($ib<<12)+$core[46]+1; $code[($ib<<12)+$core[46]] = *emul8; $inh = 0; goto &fetch; }
$core[000746] = 05331; $code[000746] = *I00746; sub I00746 { $pc = 000731; $inh = 0; goto &fetch; }
$core[000747] = 04457; $code[000747] = *I00747; sub I00747 { $core[($ib<<12)+$core[47]] = 00750; $pc = ($ib<<12)+$core[47]+1; $code[($ib<<12)+$core[47]] = *emul8; $inh = 0; goto &fetch; }
$core[000750] = 05325; $code[000750] = *I00750; sub I00750 { $pc = 000725; $inh = 0; goto &fetch; }
$core[000751] = 05777; $code[000751] = *I00751; sub I00751 { $pc = ($ib<<12)+$core[511]; $inh = 0; goto &fetch; }
$core[000752] = 01400; $code[000752] = *P00752; sub P00752 { $lac += $core[($df<<12)+$core[0]]; goto &fetch; }
$core[000753] = 01410; $code[000753] = *P00753; sub P00753 { $core[000010] = 0000 if ++$core[000010] == 010000; $lac += $core[($df<<12)+$core[000010]]; goto &fetch; }
$core[000754] = 01420; $code[000754] = *P00754; sub P00754 { $lac += $core[($df<<12)+$core[16]]; goto &fetch; }
$core[000755] = 01430; $code[000755] = *P00755; sub P00755 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[000756] = 01440; $code[000756] = *P00756; sub P00756 { $lac += $core[($df<<12)+$core[32]]; goto &fetch; }
$core[000757] = 00001; $code[000757] = *I00757; sub I00757 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000760] = 00002; $code[000760] = *I00760; sub I00760 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000761] = 00004; $code[000761] = *I00761; sub I00761 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[000762] = 00010; $code[000762] = *I00762; sub I00762 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[000763] = 00020; $code[000763] = *I00763; sub I00763 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[000764] = 00040; $code[000764] = *I00764; sub I00764 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000765] = 00100; $code[000765] = *I00765; sub I00765 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000766] = 00200; $code[000766] = *I00766; sub I00766 { $lac &= (010000|$core[000600]); goto &fetch; }
$core[000767] = 00400; $code[000767] = *I00767; sub I00767 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000770] = 01000; $code[000770] = *I00770; sub I00770 { $lac += $core[000000]; goto &fetch; }
$core[000771] = 02000; $code[000771] = *I00771; sub I00771 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[000772] = 04000; $code[000772] = *I00772; sub I00772 { $core[000000] = 00773; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000773] = 00000; $code[000773] = *I00773; sub I00773 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000774] = 00001; $code[000774] = *I00774; sub I00774 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000775] = 04000; $code[000775] = *I00775; sub I00775 { $core[000000] = 00776; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000776] = 01236; $code[000776] = *P00776; sub P00776 { $lac += $core[000636]; goto &fetch; }
$core[000777] = 01323; $code[000777] = *P00777; sub P00777 { $lac += $core[000723]; goto &fetch; }
$core[001000] = 00000; $code[001000] = *S01000; sub S01000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001001] = 07340; $code[001001] = *I01001; sub I01001 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001002] = 00025; $code[001002] = *I01002; sub I01002 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[001003] = 07040; $code[001003] = *I01003; sub I01003 { $lac ^= 07777; goto &fetch; }
$core[001004] = 00031; $code[001004] = *I01004; sub I01004 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[001005] = 07440; $code[001005] = *I01005; sub I01005 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001006] = 05226; $code[001006] = *I01006; sub I01006 { $pc = 001026; $inh = 0; goto &fetch; }
$core[001007] = 07040; $code[001007] = *I01007; sub I01007 { $lac ^= 07777; goto &fetch; }
$core[001010] = 00031; $code[001010] = *I01010; sub I01010 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[001011] = 07040; $code[001011] = *I01011; sub I01011 { $lac ^= 07777; goto &fetch; }
$core[001012] = 00025; $code[001012] = *I01012; sub I01012 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[001013] = 07440; $code[001013] = *I01013; sub I01013 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001014] = 05226; $code[001014] = *I01014; sub I01014 { $pc = 001026; $inh = 0; goto &fetch; }
$core[001015] = 07340; $code[001015] = *I01015; sub I01015 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001016] = 00026; $code[001016] = *I01016; sub I01016 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[001017] = 07640; $code[001017] = *I01017; sub I01017 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001020] = 07020; $code[001020] = *I01020; sub I01020 { $lac ^= 010000; goto &fetch; }
$core[001021] = 07040; $code[001021] = *I01021; sub I01021 { $lac ^= 07777; goto &fetch; }
$core[001022] = 00033; $code[001022] = *I01022; sub I01022 { $lac &= (010000|$core[000033]); goto &fetch; }
$core[001023] = 07440; $code[001023] = *I01023; sub I01023 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001024] = 07020; $code[001024] = *I01024; sub I01024 { $lac ^= 010000; goto &fetch; }
$core[001025] = 07430; $code[001025] = *I01025; sub I01025 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001026] = 05246; $code[001026] = *L01026; sub L01026 { $pc = 001046; $inh = 0; goto &fetch; }
$core[001027] = 02200; $code[001027] = *L01027; sub L01027 { if (++$core[001000] == 010000) { $core[001000] = 0; $pc++; }$code[001000] = *emul8; goto &fetch; }
$core[001030] = 05600; $code[001030] = *L01030; sub L01030 { $pc = ($ib<<12)+$core[512]; $inh = 0; goto &fetch; }
$core[001031] = 00000; $code[001031] = *S01031; sub S01031 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001032] = 07340; $code[001032] = *I01032; sub I01032 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001033] = 00024; $code[001033] = *I01033; sub I01033 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[001034] = 07640; $code[001034] = *I01034; sub I01034 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001035] = 05244; $code[001035] = *I01035; sub I01035 { $pc = 001044; $inh = 0; goto &fetch; }
$core[001036] = 07040; $code[001036] = *I01036; sub I01036 { $lac ^= 07777; goto &fetch; }
$core[001037] = 03024; $code[001037] = *I01037; sub I01037 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001040] = 02023; $code[001040] = *I01040; sub I01040 { if (++$core[000023] == 010000) { $core[000023] = 0; $pc++; }$code[000023] = *emul8; goto &fetch; }
$core[001041] = 05631; $code[001041] = *I01041; sub I01041 { $pc = ($ib<<12)+$core[537]; $inh = 0; goto &fetch; }
$core[001042] = 02231; $code[001042] = *I01042; sub I01042 { if (++$core[001031] == 010000) { $core[001031] = 0; $pc++; }$code[001031] = *emul8; goto &fetch; }
$core[001043] = 05631; $code[001043] = *I01043; sub I01043 { $pc = ($ib<<12)+$core[537]; $inh = 0; goto &fetch; }
$core[001044] = 03024; $code[001044] = *L01044; sub L01044 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001045] = 05631; $code[001045] = *I01045; sub I01045 { $pc = ($ib<<12)+$core[537]; $inh = 0; goto &fetch; }
$core[001046] = 07604; $code[001046] = *L01046; sub L01046 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001047] = 00104; $code[001047] = *I01047; sub I01047 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[001050] = 07650; $code[001050] = *I01050; sub I01050 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001051] = 04271; $code[001051] = *I01051; sub I01051 { $core[001071] = 01052; $pc = 001071+1; $code[001071] = *emul8; $inh = 0; goto &fetch; }
$core[001052] = 07604; $code[001052] = *I01052; sub I01052 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001053] = 00103; $code[001053] = *I01053; sub I01053 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[001054] = 07650; $code[001054] = *I01054; sub I01054 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001055] = 05263; $code[001055] = *I01055; sub I01055 { $pc = 001063; $inh = 0; goto &fetch; }
$core[001056] = 07604; $code[001056] = *L01056; sub L01056 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001057] = 00105; $code[001057] = *I01057; sub I01057 { $lac &= (010000|$core[000105]); goto &fetch; }
$core[001060] = 07650; $code[001060] = *I01060; sub I01060 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001061] = 05227; $code[001061] = *I01061; sub I01061 { $pc = 001027; $inh = 0; goto &fetch; }
$core[001062] = 05230; $code[001062] = *I01062; sub I01062 { $pc = 001030; $inh = 0; goto &fetch; }
$core[001063] = 07340; $code[001063] = *L01063; sub L01063 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001064] = 00451; $code[001064] = *I01064; sub I01064 { $lac &= (010000|$core[($df<<12)+$core[41]]); goto &fetch; }
$core[001065] = 01270; $code[001065] = *I01065; sub I01065 { $lac += $core[001070]; goto &fetch; }
$core[001066] = 07402; $code[001066] = *I01066; sub I01066 { $hlt = 1; goto &fetch; }
$core[001067] = 05256; $code[001067] = *I01067; sub I01067 { $pc = 001056; $inh = 0; goto &fetch; }
$core[001070] = 07774; $code[001070] = *D01070; sub D01070 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001071] = 00000; $code[001071] = *S01071; sub S01071 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001072] = 07340; $code[001072] = *I01072; sub I01072 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001073] = 00035; $code[001073] = *I01073; sub I01073 { $lac &= (010000|$core[000035]); goto &fetch; }
$core[001074] = 07650; $code[001074] = *I01074; sub I01074 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001075] = 04331; $code[001075] = *I01075; sub I01075 { $core[001131] = 01076; $pc = 001131+1; $code[001131] = *emul8; $inh = 0; goto &fetch; }
$core[001076] = 07040; $code[001076] = *I01076; sub I01076 { $lac ^= 07777; goto &fetch; }
$core[001077] = 00023; $code[001077] = *L01077; sub L01077 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[001100] = 03037; $code[001100] = *I01100; sub I01100 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[001101] = 07040; $code[001101] = *I01101; sub I01101 { $lac ^= 07777; goto &fetch; }
$core[001102] = 00024; $code[001102] = *I01102; sub I01102 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[001103] = 03040; $code[001103] = *I01103; sub I01103 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[001104] = 04460; $code[001104] = *I01104; sub I01104 { $core[($ib<<12)+$core[48]] = 01105; $pc = ($ib<<12)+$core[48]+1; $code[($ib<<12)+$core[48]] = *emul8; $inh = 0; goto &fetch; }
$core[001105] = 04461; $code[001105] = *I01105; sub I01105 { $core[($ib<<12)+$core[49]] = 01106; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[001106] = 07040; $code[001106] = *I01106; sub I01106 { $lac ^= 07777; goto &fetch; }
$core[001107] = 00025; $code[001107] = *I01107; sub I01107 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[001110] = 03037; $code[001110] = *I01110; sub I01110 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[001111] = 07040; $code[001111] = *I01111; sub I01111 { $lac ^= 07777; goto &fetch; }
$core[001112] = 00026; $code[001112] = *I01112; sub I01112 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[001113] = 03040; $code[001113] = *I01113; sub I01113 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[001114] = 04460; $code[001114] = *I01114; sub I01114 { $core[($ib<<12)+$core[48]] = 01115; $pc = ($ib<<12)+$core[48]+1; $code[($ib<<12)+$core[48]] = *emul8; $inh = 0; goto &fetch; }
$core[001115] = 04461; $code[001115] = *I01115; sub I01115 { $core[($ib<<12)+$core[49]] = 01116; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[001116] = 07040; $code[001116] = *I01116; sub I01116 { $lac ^= 07777; goto &fetch; }
$core[001117] = 00031; $code[001117] = *I01117; sub I01117 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[001120] = 03037; $code[001120] = *I01120; sub I01120 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[001121] = 07040; $code[001121] = *I01121; sub I01121 { $lac ^= 07777; goto &fetch; }
$core[001122] = 00033; $code[001122] = *I01122; sub I01122 { $lac &= (010000|$core[000033]); goto &fetch; }
$core[001123] = 03040; $code[001123] = *I01123; sub I01123 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[001124] = 04460; $code[001124] = *I01124; sub I01124 { $core[($ib<<12)+$core[48]] = 01125; $pc = ($ib<<12)+$core[48]+1; $code[($ib<<12)+$core[48]] = *emul8; $inh = 0; goto &fetch; }
$core[001125] = 04461; $code[001125] = *I01125; sub I01125 { $core[($ib<<12)+$core[49]] = 01126; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[001126] = 04446; $code[001126] = *I01126; sub I01126 { $core[($ib<<12)+$core[38]] = 01127; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[001127] = 05742; $code[001127] = *I01127; sub I01127 { $pc = ($ib<<12)+$core[610]; $inh = 0; goto &fetch; }
$core[001130] = 05671; $code[001130] = *I01130; sub I01130 { $pc = ($ib<<12)+$core[569]; $inh = 0; goto &fetch; }
$core[001131] = 00000; $code[001131] = *S01131; sub S01131 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001132] = 04446; $code[001132] = *I01132; sub I01132 { $core[($ib<<12)+$core[38]] = 01133; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[001133] = 00000; $code[001133] = *D01133; sub D01133 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001134] = 04446; $code[001134] = *I01134; sub I01134 { $core[($ib<<12)+$core[38]] = 01135; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[001135] = 05244; $code[001135] = *I01135; sub I01135 { $pc = 001044; $inh = 0; goto &fetch; }
$core[001136] = 07240; $code[001136] = *I01136; sub I01136 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001137] = 03035; $code[001137] = *I01137; sub I01137 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[001140] = 05731; $code[001140] = *I01140; sub I01140 { $pc = ($ib<<12)+$core[601]; $inh = 0; goto &fetch; }
$core[001141] = 02000; $code[001141] = *I01141; sub I01141 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[001142] = 00400; $code[001142] = *P01142; sub P01142 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[001143] = 00100; $code[001143] = *I01143; sub I01143 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[001144] = 00020; $code[001144] = *I01144; sub I01144 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[001145] = 00004; $code[001145] = *I01145; sub I01145 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[001146] = 00001; $code[001146] = *I01146; sub I01146 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[001147] = 04000; $code[001147] = *I01147; sub I01147 { $core[000000] = 01150; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[001150] = 01000; $code[001150] = *I01150; sub I01150 { $lac += $core[000000]; goto &fetch; }
$core[001151] = 00200; $code[001151] = *I01151; sub I01151 { $lac &= (010000|$core[001000]); goto &fetch; }
$core[001152] = 00040; $code[001152] = *I01152; sub I01152 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[001153] = 00010; $code[001153] = *I01153; sub I01153 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[001154] = 00002; $code[001154] = *I01154; sub I01154 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[001155] = 00000; $code[001155] = *I01155; sub I01155 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001156] = 02000; $code[001156] = *I01156; sub I01156 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[001157] = 00002; $code[001157] = *I01157; sub I01157 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[001160] = 00002; $code[001160] = *I01160; sub I01160 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[001161] = 00010; $code[001161] = *I01161; sub I01161 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[001162] = 00040; $code[001162] = *I01162; sub I01162 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[001163] = 00200; $code[001163] = *I01163; sub I01163 { $lac &= (010000|$core[001000]); goto &fetch; }
$core[001164] = 01000; $code[001164] = *I01164; sub I01164 { $lac += $core[000000]; goto &fetch; }
$core[001165] = 04000; $code[001165] = *I01165; sub I01165 { $core[000000] = 01166; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[001166] = 00001; $code[001166] = *I01166; sub I01166 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[001167] = 00004; $code[001167] = *I01167; sub I01167 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[001170] = 00020; $code[001170] = *I01170; sub I01170 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[001171] = 00100; $code[001171] = *I01171; sub I01171 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[001172] = 00400; $code[001172] = *I01172; sub I01172 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[001173] = 02000; $code[001173] = *I01173; sub I01173 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[001174] = 00000; $code[001174] = *I01174; sub I01174 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001175] = 00002; $code[001175] = *I01175; sub I01175 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[001176] = 02000; $code[001176] = *I01176; sub I01176 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[001200] = 00000; $code[001200] = *S01200; sub S01200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001201] = 07300; $code[001201] = *I01201; sub I01201 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001202] = 03025; $code[001202] = *I01202; sub I01202 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[001203] = 03026; $code[001203] = *I01203; sub I01203 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[001204] = 07040; $code[001204] = *I01204; sub I01204 { $lac ^= 07777; goto &fetch; }
$core[001205] = 00412; $code[001205] = *I01205; sub I01205 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac &= (010000|$core[($df<<12)+$core[000012]]); goto &fetch; }
$core[001206] = 03037; $code[001206] = *I01206; sub I01206 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[001207] = 07040; $code[001207] = *L01207; sub L01207 { $lac ^= 07777; goto &fetch; }
$core[001210] = 00412; $code[001210] = *I01210; sub I01210 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac &= (010000|$core[($df<<12)+$core[000012]]); goto &fetch; }
$core[001211] = 07450; $code[001211] = *I01211; sub I01211 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001212] = 05303; $code[001212] = *I01212; sub I01212 { $pc = 001303; $inh = 0; goto &fetch; }
$core[001213] = 03040; $code[001213] = *I01213; sub I01213 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[001214] = 07040; $code[001214] = *I01214; sub I01214 { $lac ^= 07777; goto &fetch; }
$core[001215] = 00023; $code[001215] = *I01215; sub I01215 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[001216] = 00037; $code[001216] = *I01216; sub I01216 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[001217] = 07440; $code[001217] = *I01217; sub I01217 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001220] = 04225; $code[001220] = *I01220; sub I01220 { $core[001225] = 01221; $pc = 001225+1; $code[001225] = *emul8; $inh = 0; goto &fetch; }
$core[001221] = 07040; $code[001221] = *I01221; sub I01221 { $lac ^= 07777; goto &fetch; }
$core[001222] = 00040; $code[001222] = *I01222; sub I01222 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[001223] = 03037; $code[001223] = *I01223; sub I01223 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[001224] = 05207; $code[001224] = *I01224; sub I01224 { $pc = 001207; $inh = 0; goto &fetch; }
$core[001225] = 00000; $code[001225] = *S01225; sub S01225 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001226] = 07240; $code[001226] = *I01226; sub I01226 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001227] = 00040; $code[001227] = *I01227; sub I01227 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[001230] = 07421; $code[001230] = *I01230; sub I01230 { &emul8; goto &fetch; }
$core[001231] = 07040; $code[001231] = *I01231; sub I01231 { $lac ^= 07777; goto &fetch; }
$core[001232] = 00025; $code[001232] = *I01232; sub I01232 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[001233] = 07501; $code[001233] = *I01233; sub I01233 { &emul8; goto &fetch; }
$core[001234] = 03025; $code[001234] = *I01234; sub I01234 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[001235] = 05625; $code[001235] = *I01235; sub I01235 { $pc = ($ib<<12)+$core[661]; $inh = 0; goto &fetch; }
$core[001236] = 00000; $code[001236] = *S01236; sub S01236 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001237] = 07340; $code[001237] = *I01237; sub I01237 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001240] = 00236; $code[001240] = *I01240; sub I01240 { $lac &= (010000|$core[001236]); goto &fetch; }
$core[001241] = 03451; $code[001241] = *I01241; sub I01241 { $core[($df<<12)+$core[41]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[41]] = *emul8; goto &fetch; }
$core[001242] = 03025; $code[001242] = *I01242; sub I01242 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[001243] = 03026; $code[001243] = *I01243; sub I01243 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[001244] = 07040; $code[001244] = *L01244; sub L01244 { $lac ^= 07777; goto &fetch; }
$core[001245] = 00412; $code[001245] = *I01245; sub I01245 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac &= (010000|$core[($df<<12)+$core[000012]]); goto &fetch; }
$core[001246] = 07450; $code[001246] = *I01246; sub I01246 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001247] = 05277; $code[001247] = *I01247; sub I01247 { $pc = 001277; $inh = 0; goto &fetch; }
$core[001250] = 03037; $code[001250] = *I01250; sub I01250 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[001251] = 07040; $code[001251] = *I01251; sub I01251 { $lac ^= 07777; goto &fetch; }
$core[001252] = 00412; $code[001252] = *I01252; sub I01252 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac &= (010000|$core[($df<<12)+$core[000012]]); goto &fetch; }
$core[001253] = 03040; $code[001253] = *I01253; sub I01253 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[001254] = 07040; $code[001254] = *I01254; sub I01254 { $lac ^= 07777; goto &fetch; }
$core[001255] = 00023; $code[001255] = *I01255; sub I01255 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[001256] = 00037; $code[001256] = *I01256; sub I01256 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[001257] = 07440; $code[001257] = *I01257; sub I01257 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001260] = 04225; $code[001260] = *I01260; sub I01260 { $core[001225] = 01261; $pc = 001225+1; $code[001225] = *emul8; $inh = 0; goto &fetch; }
$core[001261] = 07040; $code[001261] = *I01261; sub I01261 { $lac ^= 07777; goto &fetch; }
$core[001262] = 00037; $code[001262] = *I01262; sub I01262 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[001263] = 07421; $code[001263] = *I01263; sub I01263 { &emul8; goto &fetch; }
$core[001264] = 07040; $code[001264] = *I01264; sub I01264 { $lac ^= 07777; goto &fetch; }
$core[001265] = 00040; $code[001265] = *I01265; sub I01265 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[001266] = 03037; $code[001266] = *I01266; sub I01266 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[001267] = 07501; $code[001267] = *I01267; sub I01267 { &emul8; goto &fetch; }
$core[001270] = 03040; $code[001270] = *I01270; sub I01270 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[001271] = 07040; $code[001271] = *I01271; sub I01271 { $lac ^= 07777; goto &fetch; }
$core[001272] = 00023; $code[001272] = *I01272; sub I01272 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[001273] = 00037; $code[001273] = *I01273; sub I01273 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[001274] = 07440; $code[001274] = *I01274; sub I01274 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001275] = 04225; $code[001275] = *I01275; sub I01275 { $core[001225] = 01276; $pc = 001225+1; $code[001225] = *emul8; $inh = 0; goto &fetch; }
$core[001276] = 05244; $code[001276] = *I01276; sub I01276 { $pc = 001244; $inh = 0; goto &fetch; }
$core[001277] = 07340; $code[001277] = *L01277; sub L01277 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001300] = 00024; $code[001300] = *I01300; sub I01300 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[001301] = 03026; $code[001301] = *I01301; sub I01301 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[001302] = 05636; $code[001302] = *I01302; sub I01302 { $pc = ($ib<<12)+$core[670]; $inh = 0; goto &fetch; }
$core[001303] = 07340; $code[001303] = *L01303; sub L01303 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001304] = 00412; $code[001304] = *I01304; sub I01304 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac &= (010000|$core[($df<<12)+$core[000012]]); goto &fetch; }
$core[001305] = 03040; $code[001305] = *I01305; sub I01305 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[001306] = 07040; $code[001306] = *I01306; sub I01306 { $lac ^= 07777; goto &fetch; }
$core[001307] = 00116; $code[001307] = *I01307; sub I01307 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[001310] = 00024; $code[001310] = *I01310; sub I01310 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[001311] = 07440; $code[001311] = *I01311; sub I01311 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001312] = 04225; $code[001312] = *I01312; sub I01312 { $core[001225] = 01313; $pc = 001225+1; $code[001225] = *emul8; $inh = 0; goto &fetch; }
$core[001313] = 07040; $code[001313] = *I01313; sub I01313 { $lac ^= 07777; goto &fetch; }
$core[001314] = 00412; $code[001314] = *I01314; sub I01314 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac &= (010000|$core[($df<<12)+$core[000012]]); goto &fetch; }
$core[001315] = 00023; $code[001315] = *I01315; sub I01315 { $lac &= (010000|$core[000023]); goto &fetch; }
$core[001316] = 07440; $code[001316] = *I01316; sub I01316 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001317] = 07240; $code[001317] = *I01317; sub I01317 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001320] = 00116; $code[001320] = *I01320; sub I01320 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[001321] = 03026; $code[001321] = *I01321; sub I01321 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[001322] = 05600; $code[001322] = *I01322; sub I01322 { $pc = ($ib<<12)+$core[640]; $inh = 0; goto &fetch; }
$core[001323] = 07604; $code[001323] = *L01323; sub L01323 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001324] = 00115; $code[001324] = *I01324; sub I01324 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[001325] = 07650; $code[001325] = *P01325; sub P01325 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001326] = 05342; $code[001326] = *I01326; sub I01326 { $pc = 001342; $inh = 0; goto &fetch; }
$core[001327] = 07604; $code[001327] = *L01327; sub L01327 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001330] = 00114; $code[001330] = *I01330; sub I01330 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[001331] = 07640; $code[001331] = *I01331; sub I01331 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001332] = 07402; $code[001332] = *I01332; sub I01332 { $hlt = 1; goto &fetch; }
$core[001333] = 07604; $code[001333] = *I01333; sub I01333 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001334] = 00116; $code[001334] = *I01334; sub I01334 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[001335] = 07650; $code[001335] = *I01335; sub I01335 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001336] = 05740; $code[001336] = *I01336; sub I01336 { $pc = ($ib<<12)+$core[736]; $inh = 0; goto &fetch; }
$core[001337] = 05741; $code[001337] = *I01337; sub I01337 { $pc = ($ib<<12)+$core[737]; $inh = 0; goto &fetch; }
$core[001340] = 02000; $code[001340] = *P01340; sub P01340 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[001341] = 00600; $code[001341] = *P01341; sub P01341 { $lac &= (010000|$core[($df<<12)+$core[640]]); goto &fetch; }
$core[001342] = 04446; $code[001342] = *L01342; sub L01342 { $core[($ib<<12)+$core[38]] = 01343; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[001343] = 05725; $code[001343] = *I01343; sub I01343 { $pc = ($ib<<12)+$core[725]; $inh = 0; goto &fetch; }
$core[001344] = 05327; $code[001344] = *I01344; sub I01344 { $pc = 001327; $inh = 0; goto &fetch; }
$core[001400] = 00000; $code[001400] = *S01400; sub S01400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001401] = 07340; $code[001401] = *I01401; sub I01401 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001402] = 00250; $code[001402] = *I01402; sub I01402 { $lac &= (010000|$core[001450]); goto &fetch; }
$core[001403] = 03450; $code[001403] = *I01403; sub I01403 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[001404] = 03035; $code[001404] = *I01404; sub I01404 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[001405] = 03024; $code[001405] = *D01405; sub D01405 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001406] = 03023; $code[001406] = *I01406; sub I01406 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[001407] = 05600; $code[001407] = *I01407; sub I01407 { $pc = ($ib<<12)+$core[768]; $inh = 0; goto &fetch; }
$core[001410] = 00000; $code[001410] = *S01410; sub S01410 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001411] = 07340; $code[001411] = *I01411; sub I01411 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001412] = 00251; $code[001412] = *I01412; sub I01412 { $lac &= (010000|$core[001451]); goto &fetch; }
$core[001413] = 03450; $code[001413] = *I01413; sub I01413 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[001414] = 03035; $code[001414] = *I01414; sub I01414 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[001415] = 03024; $code[001415] = *I01415; sub I01415 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001416] = 03023; $code[001416] = *I01416; sub I01416 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[001417] = 05610; $code[001417] = *I01417; sub I01417 { $pc = ($ib<<12)+$core[776]; $inh = 0; goto &fetch; }
$core[001420] = 00000; $code[001420] = *S01420; sub S01420 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001421] = 07340; $code[001421] = *I01421; sub I01421 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001422] = 00252; $code[001422] = *I01422; sub I01422 { $lac &= (010000|$core[001452]); goto &fetch; }
$core[001423] = 03450; $code[001423] = *I01423; sub I01423 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[001424] = 03035; $code[001424] = *I01424; sub I01424 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[001425] = 03024; $code[001425] = *I01425; sub I01425 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001426] = 03023; $code[001426] = *I01426; sub I01426 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[001427] = 05620; $code[001427] = *I01427; sub I01427 { $pc = ($ib<<12)+$core[784]; $inh = 0; goto &fetch; }
$core[001430] = 00000; $code[001430] = *S01430; sub S01430 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001431] = 07340; $code[001431] = *I01431; sub I01431 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001432] = 00253; $code[001432] = *I01432; sub I01432 { $lac &= (010000|$core[001453]); goto &fetch; }
$core[001433] = 03450; $code[001433] = *I01433; sub I01433 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[001434] = 03035; $code[001434] = *I01434; sub I01434 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[001435] = 03024; $code[001435] = *I01435; sub I01435 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001436] = 03023; $code[001436] = *I01436; sub I01436 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[001437] = 05630; $code[001437] = *I01437; sub I01437 { $pc = ($ib<<12)+$core[792]; $inh = 0; goto &fetch; }
$core[001440] = 00000; $code[001440] = *S01440; sub S01440 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001441] = 07340; $code[001441] = *I01441; sub I01441 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[001442] = 00254; $code[001442] = *I01442; sub I01442 { $lac &= (010000|$core[001454]); goto &fetch; }
$core[001443] = 03450; $code[001443] = *I01443; sub I01443 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[001444] = 03035; $code[001444] = *I01444; sub I01444 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[001445] = 03024; $code[001445] = *I01445; sub I01445 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001446] = 03023; $code[001446] = *I01446; sub I01446 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[001447] = 05640; $code[001447] = *I01447; sub I01447 { $pc = ($ib<<12)+$core[800]; $inh = 0; goto &fetch; }
$core[001450] = 05440; $code[001450] = *D01450; sub D01450 { $pc = ($ib<<12)+$core[32]; $inh = 0; goto &fetch; }
$core[001451] = 05461; $code[001451] = *D01451; sub D01451 { $pc = ($ib<<12)+$core[49]; $inh = 0; goto &fetch; }
$core[001452] = 05502; $code[001452] = *D01452; sub D01452 { $pc = ($ib<<12)+$core[66]; $inh = 0; goto &fetch; }
$core[001453] = 05523; $code[001453] = *D01453; sub D01453 { $pc = ($ib<<12)+$core[83]; $inh = 0; goto &fetch; }
$core[001454] = 05544; $code[001454] = *D01454; sub D01454 { $pc = ($ib<<12)+$core[100]; $inh = 0; goto &fetch; }
$core[001600] = 00000; $code[001600] = *S01600; sub S01600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001601] = 07300; $code[001601] = *I01601; sub I01601 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001602] = 01600; $code[001602] = *I01602; sub I01602 { $lac += $core[($df<<12)+$core[896]]; goto &fetch; }
$core[001603] = 03011; $code[001603] = *I01603; sub I01603 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[001604] = 02200; $code[001604] = *I01604; sub I01604 { if (++$core[001600] == 010000) { $core[001600] = 0; $pc++; }$code[001600] = *emul8; goto &fetch; }
$core[001605] = 01411; $code[001605] = *L01605; sub L01605 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[001606] = 03036; $code[001606] = *I01606; sub I01606 { $core[000036] = $lac & 07777; $lac &= 010000; $code[000036] = *emul8; goto &fetch; }
$core[001607] = 01036; $code[001607] = *I01607; sub I01607 { $lac += $core[000036]; goto &fetch; }
$core[001610] = 07012; $code[001610] = *I01610; sub I01610 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001611] = 07012; $code[001611] = *I01611; sub I01611 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001612] = 07012; $code[001612] = *D01612; sub D01612 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001613] = 04217; $code[001613] = *I01613; sub I01613 { $core[001617] = 01614; $pc = 001617+1; $code[001617] = *emul8; $inh = 0; goto &fetch; }
$core[001614] = 01036; $code[001614] = *I01614; sub I01614 { $lac += $core[000036]; goto &fetch; }
$core[001615] = 04217; $code[001615] = *D01615; sub D01615 { $core[001617] = 01616; $pc = 001617+1; $code[001617] = *emul8; $inh = 0; goto &fetch; }
$core[001616] = 05205; $code[001616] = *I01616; sub I01616 { $pc = 001605; $inh = 0; goto &fetch; }
$core[001617] = 00000; $code[001617] = *S01617; sub S01617 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001620] = 00245; $code[001620] = *I01620; sub I01620 { $lac &= (010000|$core[001645]); goto &fetch; }
$core[001621] = 07450; $code[001621] = *I01621; sub I01621 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001622] = 05600; $code[001622] = *I01622; sub I01622 { $pc = ($ib<<12)+$core[896]; $inh = 0; goto &fetch; }
$core[001623] = 01246; $code[001623] = *I01623; sub I01623 { $lac += $core[001646]; goto &fetch; }
$core[001624] = 07510; $code[001624] = *I01624; sub I01624 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001625] = 05230; $code[001625] = *I01625; sub I01625 { $pc = 001630; $inh = 0; goto &fetch; }
$core[001626] = 01076; $code[001626] = *I01626; sub I01626 { $lac += $core[000076]; goto &fetch; }
$core[001627] = 05243; $code[001627] = *I01627; sub I01627 { $pc = 001643; $inh = 0; goto &fetch; }
$core[001630] = 07001; $code[001630] = *L01630; sub L01630 { $lac++; goto &fetch; }
$core[001631] = 07440; $code[001631] = *I01631; sub I01631 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001632] = 05235; $code[001632] = *I01632; sub I01632 { $pc = 001635; $inh = 0; goto &fetch; }
$core[001633] = 01251; $code[001633] = *I01633; sub I01633 { $lac += $core[001651]; goto &fetch; }
$core[001634] = 05243; $code[001634] = *I01634; sub I01634 { $pc = 001643; $inh = 0; goto &fetch; }
$core[001635] = 07001; $code[001635] = *L01635; sub L01635 { $lac++; goto &fetch; }
$core[001636] = 07440; $code[001636] = *I01636; sub I01636 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001637] = 05242; $code[001637] = *I01637; sub I01637 { $pc = 001642; $inh = 0; goto &fetch; }
$core[001640] = 01250; $code[001640] = *I01640; sub I01640 { $lac += $core[001650]; goto &fetch; }
$core[001641] = 05243; $code[001641] = *I01641; sub I01641 { $pc = 001643; $inh = 0; goto &fetch; }
$core[001642] = 01247; $code[001642] = *L01642; sub L01642 { $lac += $core[001647]; goto &fetch; }
$core[001643] = 04447; $code[001643] = *L01643; sub L01643 { $core[($ib<<12)+$core[39]] = 01644; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[001644] = 05617; $code[001644] = *I01644; sub I01644 { $pc = ($ib<<12)+$core[911]; $inh = 0; goto &fetch; }
$core[001645] = 00077; $code[001645] = *D01645; sub D01645 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[001646] = 07740; $code[001646] = *D01646; sub D01646 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001647] = 00336; $code[001647] = *D01647; sub D01647 { $lac &= (010000|$core[001736]); goto &fetch; }
$core[001650] = 00212; $code[001650] = *D01650; sub D01650 { $lac &= (010000|$core[001612]); goto &fetch; }
$core[001651] = 00215; $code[001651] = *D01651; sub D01651 { $lac &= (010000|$core[001615]); goto &fetch; }
$core[001652] = 00000; $code[001652] = *S01652; sub S01652 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001653] = 06046; $code[001653] = *I01653; sub I01653 { &emul8; goto &fetch; }
$core[001654] = 06041; $code[001654] = *L01654; sub L01654 { &emul8; goto &fetch; }
$core[001655] = 05254; $code[001655] = *I01655; sub I01655 { $pc = 001654; $inh = 0; goto &fetch; }
$core[001656] = 07200; $code[001656] = *I01656; sub I01656 { $lac &= 010000; goto &fetch; }
$core[001657] = 05652; $code[001657] = *D01657; sub D01657 { $pc = ($ib<<12)+$core[938]; $inh = 0; goto &fetch; }
$core[001660] = 00001; $code[001660] = *I01660; sub I01660 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[001661] = 00100; $code[001661] = *I01661; sub I01661 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[001662] = 00002; $code[001662] = *I01662; sub I01662 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[001663] = 00200; $code[001663] = *I01663; sub I01663 { $lac &= (010000|$core[001600]); goto &fetch; }
$core[001664] = 00004; $code[001664] = *I01664; sub I01664 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[001665] = 00400; $code[001665] = *I01665; sub I01665 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[001666] = 00010; $code[001666] = *I01666; sub I01666 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[001667] = 01000; $code[001667] = *I01667; sub I01667 { $lac += $core[000000]; goto &fetch; }
$core[001670] = 00020; $code[001670] = *I01670; sub I01670 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[001671] = 02000; $code[001671] = *I01671; sub I01671 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[001672] = 00040; $code[001672] = *I01672; sub I01672 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[001673] = 04000; $code[001673] = *I01673; sub I01673 { $core[000000] = 01674; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[001674] = 00000; $code[001674] = *I01674; sub I01674 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002000] = 07300; $code[002000] = *L02000; sub L02000 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002001] = 01122; $code[002001] = *I02001; sub I02001 { $lac += $core[000122]; goto &fetch; }
$core[002002] = 03154; $code[002002] = *I02002; sub I02002 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002003] = 03020; $code[002003] = *I02003; sub I02003 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[002004] = 07300; $code[002004] = *L02004; sub L02004 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002005] = 07300; $code[002005] = *I02005; sub I02005 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002006] = 03471; $code[002006] = *I02006; sub I02006 { $core[($df<<12)+$core[57]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[57]] = *emul8; goto &fetch; }
$core[002007] = 01136; $code[002007] = *I02007; sub I02007 { $lac += $core[000136]; goto &fetch; }
$core[002010] = 03472; $code[002010] = *I02010; sub I02010 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002011] = 01332; $code[002011] = *I02011; sub I02011 { $lac += $core[002132]; goto &fetch; }
$core[002012] = 03000; $code[002012] = *I02012; sub I02012 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002013] = 01137; $code[002013] = *I02013; sub I02013 { $lac += $core[000137]; goto &fetch; }
$core[002014] = 03001; $code[002014] = *I02014; sub I02014 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002015] = 01140; $code[002015] = *I02015; sub I02015 { $lac += $core[000140]; goto &fetch; }
$core[002016] = 03002; $code[002016] = *I02016; sub I02016 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002017] = 07240; $code[002017] = *I02017; sub I02017 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002020] = 03003; $code[002020] = *I02020; sub I02020 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[002021] = 01327; $code[002021] = *I02021; sub I02021 { $lac += $core[002127]; goto &fetch; }
$core[002022] = 03004; $code[002022] = *I02022; sub I02022 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[002023] = 07300; $code[002023] = *L02023; sub L02023 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002024] = 05472; $code[002024] = *I02024; sub I02024 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002025] = 07000; $code[002025] = *I02025; sub I02025 { goto &fetch; }
$core[002026] = 07000; $code[002026] = *I02026; sub I02026 { goto &fetch; }
$core[002027] = 04464; $code[002027] = *I02027; sub I02027 { $core[($ib<<12)+$core[52]] = 02030; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002030] = 07430; $code[002030] = *I02030; sub I02030 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002031] = 07440; $code[002031] = *I02031; sub I02031 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002032] = 04465; $code[002032] = *I02032; sub I02032 { $core[($ib<<12)+$core[53]] = 02033; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002033] = 07410; $code[002033] = *I02033; sub I02033 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002034] = 04466; $code[002034] = *I02034; sub I02034 { $core[($ib<<12)+$core[54]] = 02035; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002035] = 04467; $code[002035] = *I02035; sub I02035 { $core[($ib<<12)+$core[55]] = 02036; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002036] = 05223; $code[002036] = *I02036; sub I02036 { $pc = 002023; $inh = 0; goto &fetch; }
$core[002037] = 07200; $code[002037] = *I02037; sub I02037 { $lac &= 010000; goto &fetch; }
$core[002040] = 01123; $code[002040] = *I02040; sub I02040 { $lac += $core[000123]; goto &fetch; }
$core[002041] = 03154; $code[002041] = *I02041; sub I02041 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002042] = 05554; $code[002042] = *I02042; sub I02042 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002043] = 07300; $code[002043] = *L02043; sub L02043 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002044] = 07340; $code[002044] = *I02044; sub I02044 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002045] = 03471; $code[002045] = *I02045; sub I02045 { $core[($df<<12)+$core[57]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[57]] = *emul8; goto &fetch; }
$core[002046] = 01136; $code[002046] = *I02046; sub I02046 { $lac += $core[000136]; goto &fetch; }
$core[002047] = 03472; $code[002047] = *I02047; sub I02047 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002050] = 01137; $code[002050] = *I02050; sub I02050 { $lac += $core[000137]; goto &fetch; }
$core[002051] = 03000; $code[002051] = *I02051; sub I02051 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002052] = 01141; $code[002052] = *I02052; sub I02052 { $lac += $core[000141]; goto &fetch; }
$core[002053] = 03001; $code[002053] = *I02053; sub I02053 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002054] = 01330; $code[002054] = *I02054; sub I02054 { $lac += $core[002130]; goto &fetch; }
$core[002055] = 03002; $code[002055] = *I02055; sub I02055 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002056] = 07300; $code[002056] = *L02056; sub L02056 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002057] = 05472; $code[002057] = *I02057; sub I02057 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002060] = 07000; $code[002060] = *I02060; sub I02060 { goto &fetch; }
$core[002061] = 07000; $code[002061] = *I02061; sub I02061 { goto &fetch; }
$core[002062] = 04464; $code[002062] = *I02062; sub I02062 { $core[($ib<<12)+$core[52]] = 02063; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002063] = 07430; $code[002063] = *I02063; sub I02063 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002064] = 07440; $code[002064] = *I02064; sub I02064 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002065] = 04465; $code[002065] = *I02065; sub I02065 { $core[($ib<<12)+$core[53]] = 02066; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002066] = 07410; $code[002066] = *I02066; sub I02066 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002067] = 04466; $code[002067] = *I02067; sub I02067 { $core[($ib<<12)+$core[54]] = 02070; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002070] = 04467; $code[002070] = *I02070; sub I02070 { $core[($ib<<12)+$core[55]] = 02071; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002071] = 05256; $code[002071] = *I02071; sub I02071 { $pc = 002056; $inh = 0; goto &fetch; }
$core[002072] = 07200; $code[002072] = *I02072; sub I02072 { $lac &= 010000; goto &fetch; }
$core[002073] = 01124; $code[002073] = *I02073; sub I02073 { $lac += $core[000124]; goto &fetch; }
$core[002074] = 03154; $code[002074] = *I02074; sub I02074 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002075] = 05554; $code[002075] = *I02075; sub I02075 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002076] = 07300; $code[002076] = *I02076; sub I02076 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002077] = 01137; $code[002077] = *I02077; sub I02077 { $lac += $core[000137]; goto &fetch; }
$core[002100] = 03471; $code[002100] = *I02100; sub I02100 { $core[($df<<12)+$core[57]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[57]] = *emul8; goto &fetch; }
$core[002101] = 01333; $code[002101] = *I02101; sub I02101 { $lac += $core[002133]; goto &fetch; }
$core[002102] = 03472; $code[002102] = *I02102; sub I02102 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002103] = 01152; $code[002103] = *I02103; sub I02103 { $lac += $core[000152]; goto &fetch; }
$core[002104] = 03000; $code[002104] = *I02104; sub I02104 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002105] = 01331; $code[002105] = *I02105; sub I02105 { $lac += $core[002131]; goto &fetch; }
$core[002106] = 03001; $code[002106] = *I02106; sub I02106 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002107] = 07300; $code[002107] = *L02107; sub L02107 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002110] = 05471; $code[002110] = *I02110; sub I02110 { $pc = ($ib<<12)+$core[57]; $inh = 0; goto &fetch; }
$core[002111] = 07000; $code[002111] = *I02111; sub I02111 { goto &fetch; }
$core[002112] = 07000; $code[002112] = *I02112; sub I02112 { goto &fetch; }
$core[002113] = 04464; $code[002113] = *I02113; sub I02113 { $core[($ib<<12)+$core[52]] = 02114; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002114] = 07430; $code[002114] = *I02114; sub I02114 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002115] = 07440; $code[002115] = *I02115; sub I02115 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002116] = 04465; $code[002116] = *I02116; sub I02116 { $core[($ib<<12)+$core[53]] = 02117; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002117] = 07410; $code[002117] = *I02117; sub I02117 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002120] = 04466; $code[002120] = *I02120; sub I02120 { $core[($ib<<12)+$core[54]] = 02121; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002121] = 04467; $code[002121] = *I02121; sub I02121 { $core[($ib<<12)+$core[55]] = 02122; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002122] = 05307; $code[002122] = *I02122; sub I02122 { $pc = 002107; $inh = 0; goto &fetch; }
$core[002123] = 07200; $code[002123] = *I02123; sub I02123 { $lac &= 010000; goto &fetch; }
$core[002124] = 01125; $code[002124] = *I02124; sub I02124 { $lac += $core[000125]; goto &fetch; }
$core[002125] = 03154; $code[002125] = *I02125; sub I02125 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002126] = 05554; $code[002126] = *I02126; sub I02126 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002127] = 02025; $code[002127] = *D02127; sub D02127 { if (++$core[000025] == 010000) { $core[000025] = 0; $pc++; }$code[000025] = *emul8; goto &fetch; }
$core[002130] = 02060; $code[002130] = *D02130; sub D02130 { if (++$core[000060] == 010000) { $core[000060] = 0; $pc++; }$code[000060] = *emul8; goto &fetch; }
$core[002131] = 02111; $code[002131] = *D02131; sub D02131 { if (++$core[000111] == 010000) { $core[000111] = 0; $pc++; }$code[000111] = *emul8; goto &fetch; }
$core[002132] = 01003; $code[002132] = *D02132; sub D02132 { $lac += $core[000003]; goto &fetch; }
$core[002133] = 01421; $code[002133] = *D02133; sub D02133 { $lac += $core[($df<<12)+$core[17]]; goto &fetch; }
$core[002200] = 07300; $code[002200] = *I02200; sub I02200 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002201] = 07340; $code[002201] = *I02201; sub I02201 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002202] = 03471; $code[002202] = *I02202; sub I02202 { $core[($df<<12)+$core[57]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[57]] = *emul8; goto &fetch; }
$core[002203] = 01136; $code[002203] = *I02203; sub I02203 { $lac += $core[000136]; goto &fetch; }
$core[002204] = 03472; $code[002204] = *I02204; sub I02204 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002205] = 01142; $code[002205] = *I02205; sub I02205 { $lac += $core[000142]; goto &fetch; }
$core[002206] = 03000; $code[002206] = *I02206; sub I02206 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002207] = 01141; $code[002207] = *I02207; sub I02207 { $lac += $core[000141]; goto &fetch; }
$core[002210] = 03001; $code[002210] = *I02210; sub I02210 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002211] = 01324; $code[002211] = *I02211; sub I02211 { $lac += $core[002324]; goto &fetch; }
$core[002212] = 03002; $code[002212] = *I02212; sub I02212 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002213] = 07340; $code[002213] = *L02213; sub L02213 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002214] = 05472; $code[002214] = *I02214; sub I02214 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002215] = 07000; $code[002215] = *D02215; sub D02215 { goto &fetch; }
$core[002216] = 07000; $code[002216] = *I02216; sub I02216 { goto &fetch; }
$core[002217] = 04464; $code[002217] = *I02217; sub I02217 { $core[($ib<<12)+$core[52]] = 02220; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002220] = 07430; $code[002220] = *I02220; sub I02220 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002221] = 07440; $code[002221] = *I02221; sub I02221 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002222] = 04465; $code[002222] = *I02222; sub I02222 { $core[($ib<<12)+$core[53]] = 02223; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002223] = 07410; $code[002223] = *I02223; sub I02223 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002224] = 04466; $code[002224] = *I02224; sub I02224 { $core[($ib<<12)+$core[54]] = 02225; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002225] = 04467; $code[002225] = *I02225; sub I02225 { $core[($ib<<12)+$core[55]] = 02226; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002226] = 05213; $code[002226] = *I02226; sub I02226 { $pc = 002213; $inh = 0; goto &fetch; }
$core[002227] = 01126; $code[002227] = *I02227; sub I02227 { $lac += $core[000126]; goto &fetch; }
$core[002230] = 03154; $code[002230] = *I02230; sub I02230 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002231] = 05554; $code[002231] = *I02231; sub I02231 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002232] = 07300; $code[002232] = *I02232; sub I02232 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002233] = 07300; $code[002233] = *I02233; sub I02233 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002234] = 01143; $code[002234] = *I02234; sub I02234 { $lac += $core[000143]; goto &fetch; }
$core[002235] = 03472; $code[002235] = *I02235; sub I02235 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002236] = 01137; $code[002236] = *I02236; sub I02236 { $lac += $core[000137]; goto &fetch; }
$core[002237] = 03000; $code[002237] = *I02237; sub I02237 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002240] = 01137; $code[002240] = *I02240; sub I02240 { $lac += $core[000137]; goto &fetch; }
$core[002241] = 03001; $code[002241] = *I02241; sub I02241 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002242] = 01151; $code[002242] = *I02242; sub I02242 { $lac += $core[000151]; goto &fetch; }
$core[002243] = 03002; $code[002243] = *I02243; sub I02243 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002244] = 01325; $code[002244] = *I02244; sub I02244 { $lac += $core[002325]; goto &fetch; }
$core[002245] = 03003; $code[002245] = *I02245; sub I02245 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[002246] = 07340; $code[002246] = *L02246; sub L02246 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002247] = 03471; $code[002247] = *I02247; sub I02247 { $core[($df<<12)+$core[57]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[57]] = *emul8; goto &fetch; }
$core[002250] = 07040; $code[002250] = *I02250; sub I02250 { $lac ^= 07777; goto &fetch; }
$core[002251] = 05472; $code[002251] = *I02251; sub I02251 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002252] = 07000; $code[002252] = *D02252; sub D02252 { goto &fetch; }
$core[002253] = 07000; $code[002253] = *I02253; sub I02253 { goto &fetch; }
$core[002254] = 04464; $code[002254] = *I02254; sub I02254 { $core[($ib<<12)+$core[52]] = 02255; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002255] = 07430; $code[002255] = *I02255; sub I02255 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002256] = 07440; $code[002256] = *I02256; sub I02256 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002257] = 04465; $code[002257] = *I02257; sub I02257 { $core[($ib<<12)+$core[53]] = 02260; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002260] = 07410; $code[002260] = *I02260; sub I02260 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002261] = 04466; $code[002261] = *I02261; sub I02261 { $core[($ib<<12)+$core[54]] = 02262; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002262] = 04467; $code[002262] = *I02262; sub I02262 { $core[($ib<<12)+$core[55]] = 02263; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002263] = 05246; $code[002263] = *I02263; sub I02263 { $pc = 002246; $inh = 0; goto &fetch; }
$core[002264] = 07200; $code[002264] = *I02264; sub I02264 { $lac &= 010000; goto &fetch; }
$core[002265] = 01127; $code[002265] = *I02265; sub I02265 { $lac += $core[000127]; goto &fetch; }
$core[002266] = 03154; $code[002266] = *I02266; sub I02266 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002267] = 05554; $code[002267] = *I02267; sub I02267 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002270] = 07300; $code[002270] = *I02270; sub I02270 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002271] = 07300; $code[002271] = *I02271; sub I02271 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002272] = 01144; $code[002272] = *I02272; sub I02272 { $lac += $core[000144]; goto &fetch; }
$core[002273] = 03472; $code[002273] = *I02273; sub I02273 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002274] = 01137; $code[002274] = *I02274; sub I02274 { $lac += $core[000137]; goto &fetch; }
$core[002275] = 03001; $code[002275] = *I02275; sub I02275 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002276] = 01151; $code[002276] = *I02276; sub I02276 { $lac += $core[000151]; goto &fetch; }
$core[002277] = 03002; $code[002277] = *I02277; sub I02277 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002300] = 01326; $code[002300] = *I02300; sub I02300 { $lac += $core[002326]; goto &fetch; }
$core[002301] = 03003; $code[002301] = *I02301; sub I02301 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[002302] = 07340; $code[002302] = *L02302; sub L02302 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002303] = 03000; $code[002303] = *I02303; sub I02303 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002304] = 07240; $code[002304] = *I02304; sub I02304 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002305] = 05472; $code[002305] = *I02305; sub I02305 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002306] = 07000; $code[002306] = *D02306; sub D02306 { goto &fetch; }
$core[002307] = 07000; $code[002307] = *I02307; sub I02307 { goto &fetch; }
$core[002310] = 04464; $code[002310] = *I02310; sub I02310 { $core[($ib<<12)+$core[52]] = 02311; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002311] = 07430; $code[002311] = *I02311; sub I02311 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002312] = 07440; $code[002312] = *I02312; sub I02312 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002313] = 04465; $code[002313] = *I02313; sub I02313 { $core[($ib<<12)+$core[53]] = 02314; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002314] = 07410; $code[002314] = *I02314; sub I02314 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002315] = 04466; $code[002315] = *I02315; sub I02315 { $core[($ib<<12)+$core[54]] = 02316; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002316] = 04467; $code[002316] = *I02316; sub I02316 { $core[($ib<<12)+$core[55]] = 02317; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002317] = 05302; $code[002317] = *I02317; sub I02317 { $pc = 002302; $inh = 0; goto &fetch; }
$core[002320] = 07200; $code[002320] = *I02320; sub I02320 { $lac &= 010000; goto &fetch; }
$core[002321] = 01130; $code[002321] = *I02321; sub I02321 { $lac += $core[000130]; goto &fetch; }
$core[002322] = 03154; $code[002322] = *I02322; sub I02322 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002323] = 05554; $code[002323] = *I02323; sub I02323 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002324] = 02215; $code[002324] = *D02324; sub D02324 { if (++$core[002215] == 010000) { $core[002215] = 0; $pc++; }$code[002215] = *emul8; goto &fetch; }
$core[002325] = 02252; $code[002325] = *D02325; sub D02325 { if (++$core[002252] == 010000) { $core[002252] = 0; $pc++; }$code[002252] = *emul8; goto &fetch; }
$core[002326] = 02306; $code[002326] = *D02326; sub D02326 { if (++$core[002306] == 010000) { $core[002306] = 0; $pc++; }$code[002306] = *emul8; goto &fetch; }
$core[002400] = 07300; $code[002400] = *D02400; sub D02400 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002401] = 07300; $code[002401] = *I02401; sub I02401 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002402] = 01145; $code[002402] = *I02402; sub I02402 { $lac += $core[000145]; goto &fetch; }
$core[002403] = 03472; $code[002403] = *I02403; sub I02403 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002404] = 01137; $code[002404] = *I02404; sub I02404 { $lac += $core[000137]; goto &fetch; }
$core[002405] = 03001; $code[002405] = *I02405; sub I02405 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002406] = 01151; $code[002406] = *I02406; sub I02406 { $lac += $core[000151]; goto &fetch; }
$core[002407] = 03002; $code[002407] = *I02407; sub I02407 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002410] = 01326; $code[002410] = *I02410; sub I02410 { $lac += $core[002526]; goto &fetch; }
$core[002411] = 03003; $code[002411] = *I02411; sub I02411 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[002412] = 07340; $code[002412] = *L02412; sub L02412 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002413] = 03010; $code[002413] = *I02413; sub I02413 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[002414] = 07040; $code[002414] = *I02414; sub I02414 { $lac ^= 07777; goto &fetch; }
$core[002415] = 03000; $code[002415] = *I02415; sub I02415 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002416] = 07040; $code[002416] = *I02416; sub I02416 { $lac ^= 07777; goto &fetch; }
$core[002417] = 05472; $code[002417] = *I02417; sub I02417 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002420] = 07000; $code[002420] = *I02420; sub I02420 { goto &fetch; }
$core[002421] = 07000; $code[002421] = *I02421; sub I02421 { goto &fetch; }
$core[002422] = 04464; $code[002422] = *I02422; sub I02422 { $core[($ib<<12)+$core[52]] = 02423; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002423] = 07430; $code[002423] = *I02423; sub I02423 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002424] = 07440; $code[002424] = *I02424; sub I02424 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002425] = 04465; $code[002425] = *D02425; sub D02425 { $core[($ib<<12)+$core[53]] = 02426; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002426] = 07410; $code[002426] = *I02426; sub I02426 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002427] = 04466; $code[002427] = *I02427; sub I02427 { $core[($ib<<12)+$core[54]] = 02430; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002430] = 04467; $code[002430] = *I02430; sub I02430 { $core[($ib<<12)+$core[55]] = 02431; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002431] = 05212; $code[002431] = *I02431; sub I02431 { $pc = 002412; $inh = 0; goto &fetch; }
$core[002432] = 07200; $code[002432] = *I02432; sub I02432 { $lac &= 010000; goto &fetch; }
$core[002433] = 01131; $code[002433] = *I02433; sub I02433 { $lac += $core[000131]; goto &fetch; }
$core[002434] = 03154; $code[002434] = *I02434; sub I02434 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002435] = 05554; $code[002435] = *I02435; sub I02435 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002436] = 07300; $code[002436] = *I02436; sub I02436 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002437] = 07300; $code[002437] = *I02437; sub I02437 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002440] = 01137; $code[002440] = *I02440; sub I02440 { $lac += $core[000137]; goto &fetch; }
$core[002441] = 03000; $code[002441] = *I02441; sub I02441 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002442] = 01137; $code[002442] = *I02442; sub I02442 { $lac += $core[000137]; goto &fetch; }
$core[002443] = 03001; $code[002443] = *I02443; sub I02443 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002444] = 01140; $code[002444] = *I02444; sub I02444 { $lac += $core[000140]; goto &fetch; }
$core[002445] = 03002; $code[002445] = *I02445; sub I02445 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002446] = 01327; $code[002446] = *I02446; sub I02446 { $lac += $core[002527]; goto &fetch; }
$core[002447] = 03004; $code[002447] = *I02447; sub I02447 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[002450] = 07300; $code[002450] = *L02450; sub L02450 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002451] = 01146; $code[002451] = *I02451; sub I02451 { $lac += $core[000146]; goto &fetch; }
$core[002452] = 03472; $code[002452] = *I02452; sub I02452 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002453] = 07240; $code[002453] = *I02453; sub I02453 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002454] = 05472; $code[002454] = *I02454; sub I02454 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002455] = 07000; $code[002455] = *I02455; sub I02455 { goto &fetch; }
$core[002456] = 07000; $code[002456] = *I02456; sub I02456 { goto &fetch; }
$core[002457] = 07430; $code[002457] = *I02457; sub I02457 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002460] = 07440; $code[002460] = *I02460; sub I02460 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002461] = 04465; $code[002461] = *I02461; sub I02461 { $core[($ib<<12)+$core[53]] = 02462; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002462] = 07410; $code[002462] = *I02462; sub I02462 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002463] = 04466; $code[002463] = *I02463; sub I02463 { $core[($ib<<12)+$core[54]] = 02464; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002464] = 04467; $code[002464] = *I02464; sub I02464 { $core[($ib<<12)+$core[55]] = 02465; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002465] = 05250; $code[002465] = *I02465; sub I02465 { $pc = 002450; $inh = 0; goto &fetch; }
$core[002466] = 07200; $code[002466] = *I02466; sub I02466 { $lac &= 010000; goto &fetch; }
$core[002467] = 01132; $code[002467] = *I02467; sub I02467 { $lac += $core[000132]; goto &fetch; }
$core[002470] = 03154; $code[002470] = *I02470; sub I02470 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002471] = 05554; $code[002471] = *I02471; sub I02471 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002472] = 07300; $code[002472] = *I02472; sub I02472 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002473] = 07340; $code[002473] = *I02473; sub I02473 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002474] = 03471; $code[002474] = *I02474; sub I02474 { $core[($df<<12)+$core[57]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[57]] = *emul8; goto &fetch; }
$core[002475] = 01137; $code[002475] = *I02475; sub I02475 { $lac += $core[000137]; goto &fetch; }
$core[002476] = 03000; $code[002476] = *I02476; sub I02476 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002477] = 01141; $code[002477] = *I02477; sub I02477 { $lac += $core[000141]; goto &fetch; }
$core[002500] = 03001; $code[002500] = *I02500; sub I02500 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002501] = 01330; $code[002501] = *I02501; sub I02501 { $lac += $core[002530]; goto &fetch; }
$core[002502] = 03002; $code[002502] = *I02502; sub I02502 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002503] = 07300; $code[002503] = *L02503; sub L02503 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002504] = 01147; $code[002504] = *I02504; sub I02504 { $lac += $core[000147]; goto &fetch; }
$core[002505] = 03472; $code[002505] = *I02505; sub I02505 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002506] = 07240; $code[002506] = *I02506; sub I02506 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002507] = 05472; $code[002507] = *I02507; sub I02507 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002510] = 07000; $code[002510] = *I02510; sub I02510 { goto &fetch; }
$core[002511] = 07000; $code[002511] = *I02511; sub I02511 { goto &fetch; }
$core[002512] = 04464; $code[002512] = *I02512; sub I02512 { $core[($ib<<12)+$core[52]] = 02513; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002513] = 07430; $code[002513] = *I02513; sub I02513 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002514] = 07440; $code[002514] = *I02514; sub I02514 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002515] = 04465; $code[002515] = *I02515; sub I02515 { $core[($ib<<12)+$core[53]] = 02516; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002516] = 07410; $code[002516] = *I02516; sub I02516 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002517] = 04466; $code[002517] = *I02517; sub I02517 { $core[($ib<<12)+$core[54]] = 02520; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002520] = 04467; $code[002520] = *I02520; sub I02520 { $core[($ib<<12)+$core[55]] = 02521; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002521] = 05303; $code[002521] = *I02521; sub I02521 { $pc = 002503; $inh = 0; goto &fetch; }
$core[002522] = 07200; $code[002522] = *I02522; sub I02522 { $lac &= 010000; goto &fetch; }
$core[002523] = 01133; $code[002523] = *I02523; sub I02523 { $lac += $core[000133]; goto &fetch; }
$core[002524] = 03154; $code[002524] = *I02524; sub I02524 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002525] = 05554; $code[002525] = *I02525; sub I02525 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002526] = 02420; $code[002526] = *D02526; sub D02526 { if (++$core[($df<<12)+$core[16]] == 010000) { $core[($df<<12)+$core[16]] = 0; $pc++; }$code[($df<<12)+$core[16]] = *emul8; goto &fetch; }
$core[002527] = 02455; $code[002527] = *D02527; sub D02527 { if (++$core[($df<<12)+$core[45]] == 010000) { $core[($df<<12)+$core[45]] = 0; $pc++; }$code[($df<<12)+$core[45]] = *emul8; goto &fetch; }
$core[002530] = 02510; $code[002530] = *D02530; sub D02530 { if (++$core[($df<<12)+$core[72]] == 010000) { $core[($df<<12)+$core[72]] = 0; $pc++; }$code[($df<<12)+$core[72]] = *emul8; goto &fetch; }
$core[002600] = 07300; $code[002600] = *D02600; sub D02600 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002601] = 07300; $code[002601] = *I02601; sub I02601 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002602] = 01150; $code[002602] = *I02602; sub I02602 { $lac += $core[000150]; goto &fetch; }
$core[002603] = 03472; $code[002603] = *I02603; sub I02603 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002604] = 01137; $code[002604] = *I02604; sub I02604 { $lac += $core[000137]; goto &fetch; }
$core[002605] = 03001; $code[002605] = *I02605; sub I02605 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002606] = 01151; $code[002606] = *I02606; sub I02606 { $lac += $core[000151]; goto &fetch; }
$core[002607] = 03002; $code[002607] = *I02607; sub I02607 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002610] = 01315; $code[002610] = *I02610; sub I02610 { $lac += $core[002715]; goto &fetch; }
$core[002611] = 03003; $code[002611] = *I02611; sub I02611 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[002612] = 07340; $code[002612] = *L02612; sub L02612 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002613] = 03010; $code[002613] = *I02613; sub I02613 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[002614] = 07040; $code[002614] = *I02614; sub I02614 { $lac ^= 07777; goto &fetch; }
$core[002615] = 05472; $code[002615] = *I02615; sub I02615 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002616] = 07000; $code[002616] = *P02616; sub P02616 { goto &fetch; }
$core[002617] = 07000; $code[002617] = *I02617; sub I02617 { goto &fetch; }
$core[002620] = 04464; $code[002620] = *I02620; sub I02620 { $core[($ib<<12)+$core[52]] = 02621; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002621] = 07430; $code[002621] = *I02621; sub I02621 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002622] = 07440; $code[002622] = *I02622; sub I02622 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002623] = 04465; $code[002623] = *I02623; sub I02623 { $core[($ib<<12)+$core[53]] = 02624; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002624] = 07410; $code[002624] = *I02624; sub I02624 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002625] = 04466; $code[002625] = *I02625; sub I02625 { $core[($ib<<12)+$core[54]] = 02626; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002626] = 04467; $code[002626] = *I02626; sub I02626 { $core[($ib<<12)+$core[55]] = 02627; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002627] = 05212; $code[002627] = *I02627; sub I02627 { $pc = 002612; $inh = 0; goto &fetch; }
$core[002630] = 07200; $code[002630] = *I02630; sub I02630 { $lac &= 010000; goto &fetch; }
$core[002631] = 01134; $code[002631] = *I02631; sub I02631 { $lac += $core[000134]; goto &fetch; }
$core[002632] = 03154; $code[002632] = *I02632; sub I02632 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002633] = 05554; $code[002633] = *I02633; sub I02633 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002634] = 07300; $code[002634] = *I02634; sub I02634 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002635] = 07300; $code[002635] = *I02635; sub I02635 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002636] = 01137; $code[002636] = *I02636; sub I02636 { $lac += $core[000137]; goto &fetch; }
$core[002637] = 03000; $code[002637] = *I02637; sub I02637 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002640] = 01141; $code[002640] = *I02640; sub I02640 { $lac += $core[000141]; goto &fetch; }
$core[002641] = 03001; $code[002641] = *I02641; sub I02641 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002642] = 01316; $code[002642] = *I02642; sub I02642 { $lac += $core[002716]; goto &fetch; }
$core[002643] = 03002; $code[002643] = *I02643; sub I02643 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[002644] = 07300; $code[002644] = *L02644; sub L02644 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002645] = 01153; $code[002645] = *I02645; sub I02645 { $lac += $core[000153]; goto &fetch; }
$core[002646] = 03472; $code[002646] = *I02646; sub I02646 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002647] = 07240; $code[002647] = *I02647; sub I02647 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002650] = 05472; $code[002650] = *I02650; sub I02650 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002651] = 07000; $code[002651] = *P02651; sub P02651 { goto &fetch; }
$core[002652] = 07000; $code[002652] = *I02652; sub I02652 { goto &fetch; }
$core[002653] = 04464; $code[002653] = *I02653; sub I02653 { $core[($ib<<12)+$core[52]] = 02654; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002654] = 07430; $code[002654] = *I02654; sub I02654 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002655] = 07440; $code[002655] = *I02655; sub I02655 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002656] = 04465; $code[002656] = *I02656; sub I02656 { $core[($ib<<12)+$core[53]] = 02657; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002657] = 07410; $code[002657] = *I02657; sub I02657 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002660] = 04466; $code[002660] = *I02660; sub I02660 { $core[($ib<<12)+$core[54]] = 02661; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002661] = 04467; $code[002661] = *I02661; sub I02661 { $core[($ib<<12)+$core[55]] = 02662; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002662] = 05244; $code[002662] = *I02662; sub I02662 { $pc = 002644; $inh = 0; goto &fetch; }
$core[002663] = 07200; $code[002663] = *I02663; sub I02663 { $lac &= 010000; goto &fetch; }
$core[002664] = 01135; $code[002664] = *I02664; sub I02664 { $lac += $core[000135]; goto &fetch; }
$core[002665] = 03154; $code[002665] = *I02665; sub I02665 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002666] = 05554; $code[002666] = *I02666; sub I02666 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002667] = 07300; $code[002667] = *I02667; sub I02667 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002670] = 07300; $code[002670] = *I02670; sub I02670 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002671] = 01137; $code[002671] = *I02671; sub I02671 { $lac += $core[000137]; goto &fetch; }
$core[002672] = 03472; $code[002672] = *I02672; sub I02672 { $core[($df<<12)+$core[58]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[58]] = *emul8; goto &fetch; }
$core[002673] = 01152; $code[002673] = *I02673; sub I02673 { $lac += $core[000152]; goto &fetch; }
$core[002674] = 03000; $code[002674] = *I02674; sub I02674 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[002675] = 01317; $code[002675] = *I02675; sub I02675 { $lac += $core[002717]; goto &fetch; }
$core[002676] = 03001; $code[002676] = *I02676; sub I02676 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[002677] = 07340; $code[002677] = *L02677; sub L02677 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002700] = 05472; $code[002700] = *I02700; sub I02700 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[002701] = 07000; $code[002701] = *P02701; sub P02701 { goto &fetch; }
$core[002702] = 07000; $code[002702] = *I02702; sub I02702 { goto &fetch; }
$core[002703] = 04464; $code[002703] = *I02703; sub I02703 { $core[($ib<<12)+$core[52]] = 02704; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002704] = 07430; $code[002704] = *I02704; sub I02704 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002705] = 07440; $code[002705] = *I02705; sub I02705 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002706] = 04465; $code[002706] = *I02706; sub I02706 { $core[($ib<<12)+$core[53]] = 02707; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002707] = 07410; $code[002707] = *I02707; sub I02707 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002710] = 04466; $code[002710] = *I02710; sub I02710 { $core[($ib<<12)+$core[54]] = 02711; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002711] = 04467; $code[002711] = *I02711; sub I02711 { $core[($ib<<12)+$core[55]] = 02712; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002712] = 05277; $code[002712] = *I02712; sub I02712 { $pc = 002677; $inh = 0; goto &fetch; }
$core[002713] = 05714; $code[002713] = *I02713; sub I02713 { $pc = ($ib<<12)+$core[1484]; $inh = 0; goto &fetch; }
$core[002714] = 03200; $code[002714] = *P02714; sub P02714 { $core[002600] = $lac & 07777; $lac &= 010000; $code[002600] = *emul8; goto &fetch; }
$core[002715] = 02616; $code[002715] = *D02715; sub D02715 { if (++$core[($df<<12)+$core[1422]] == 010000) { $core[($df<<12)+$core[1422]] = 0; $pc++; }$code[($df<<12)+$core[1422]] = *emul8; goto &fetch; }
$core[002716] = 02651; $code[002716] = *D02716; sub D02716 { if (++$core[($df<<12)+$core[1449]] == 010000) { $core[($df<<12)+$core[1449]] = 0; $pc++; }$code[($df<<12)+$core[1449]] = *emul8; goto &fetch; }
$core[002717] = 02701; $code[002717] = *D02717; sub D02717 { if (++$core[($df<<12)+$core[1473]] == 010000) { $core[($df<<12)+$core[1473]] = 0; $pc++; }$code[($df<<12)+$core[1473]] = *emul8; goto &fetch; }
$core[003000] = 00000; $code[003000] = *S03000; sub S03000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003001] = 07340; $code[003001] = *I03001; sub I03001 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003002] = 00040; $code[003002] = *I03002; sub I03002 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[003003] = 07040; $code[003003] = *I03003; sub I03003 { $lac ^= 07777; goto &fetch; }
$core[003004] = 00037; $code[003004] = *I03004; sub I03004 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003005] = 07640; $code[003005] = *I03005; sub I03005 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003006] = 05600; $code[003006] = *I03006; sub I03006 { $pc = ($ib<<12)+$core[1536]; $inh = 0; goto &fetch; }
$core[003007] = 07040; $code[003007] = *I03007; sub I03007 { $lac ^= 07777; goto &fetch; }
$core[003010] = 00037; $code[003010] = *I03010; sub I03010 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003011] = 07040; $code[003011] = *I03011; sub I03011 { $lac ^= 07777; goto &fetch; }
$core[003012] = 00040; $code[003012] = *I03012; sub I03012 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[003013] = 07640; $code[003013] = *I03013; sub I03013 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003014] = 05600; $code[003014] = *I03014; sub I03014 { $pc = ($ib<<12)+$core[1536]; $inh = 0; goto &fetch; }
$core[003015] = 02200; $code[003015] = *I03015; sub I03015 { if (++$core[003000] == 010000) { $core[003000] = 0; $pc++; }$code[003000] = *emul8; goto &fetch; }
$core[003016] = 05600; $code[003016] = *I03016; sub I03016 { $pc = ($ib<<12)+$core[1536]; $inh = 0; goto &fetch; }
$core[003017] = 00000; $code[003017] = *S03017; sub S03017 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003020] = 03025; $code[003020] = *I03020; sub I03020 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[003021] = 07430; $code[003021] = *I03021; sub I03021 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003022] = 07040; $code[003022] = *I03022; sub I03022 { $lac ^= 07777; goto &fetch; }
$core[003023] = 03026; $code[003023] = *I03023; sub I03023 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[003024] = 07040; $code[003024] = *L03024; sub L03024 { $lac ^= 07777; goto &fetch; }
$core[003025] = 00025; $code[003025] = *I03025; sub I03025 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[003026] = 05617; $code[003026] = *I03026; sub I03026 { $pc = ($ib<<12)+$core[1551]; $inh = 0; goto &fetch; }
$core[003027] = 00000; $code[003027] = *S03027; sub S03027 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003030] = 07604; $code[003030] = *I03030; sub I03030 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003031] = 00103; $code[003031] = *I03031; sub I03031 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[003032] = 07640; $code[003032] = *I03032; sub I03032 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003033] = 05627; $code[003033] = *I03033; sub I03033 { $pc = ($ib<<12)+$core[1559]; $inh = 0; goto &fetch; }
$core[003034] = 01154; $code[003034] = *I03034; sub I03034 { $lac += $core[000154]; goto &fetch; }
$core[003035] = 07402; $code[003035] = *I03035; sub I03035 { $hlt = 1; goto &fetch; }
$core[003036] = 05627; $code[003036] = *I03036; sub I03036 { $pc = ($ib<<12)+$core[1559]; $inh = 0; goto &fetch; }
$core[003037] = 00000; $code[003037] = *S03037; sub S03037 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003040] = 07604; $code[003040] = *I03040; sub I03040 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003041] = 00104; $code[003041] = *I03041; sub I03041 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[003042] = 07450; $code[003042] = *I03042; sub I03042 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003043] = 04256; $code[003043] = *I03043; sub I03043 { $core[003056] = 03044; $pc = 003056+1; $code[003056] = *emul8; $inh = 0; goto &fetch; }
$core[003044] = 02237; $code[003044] = *I03044; sub I03044 { if (++$core[003037] == 010000) { $core[003037] = 0; $pc++; }$code[003037] = *emul8; goto &fetch; }
$core[003045] = 05637; $code[003045] = *I03045; sub I03045 { $pc = ($ib<<12)+$core[1567]; $inh = 0; goto &fetch; }
$core[003046] = 00000; $code[003046] = *S03046; sub S03046 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003047] = 07604; $code[003047] = *I03047; sub I03047 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003050] = 00105; $code[003050] = *I03050; sub I03050 { $lac &= (010000|$core[000105]); goto &fetch; }
$core[003051] = 07650; $code[003051] = *I03051; sub I03051 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003052] = 05254; $code[003052] = *I03052; sub I03052 { $pc = 003054; $inh = 0; goto &fetch; }
$core[003053] = 05646; $code[003053] = *I03053; sub I03053 { $pc = ($ib<<12)+$core[1574]; $inh = 0; goto &fetch; }
$core[003054] = 02246; $code[003054] = *L03054; sub L03054 { if (++$core[003046] == 010000) { $core[003046] = 0; $pc++; }$code[003046] = *emul8; goto &fetch; }
$core[003055] = 05646; $code[003055] = *I03055; sub I03055 { $pc = ($ib<<12)+$core[1574]; $inh = 0; goto &fetch; }
$core[003056] = 00000; $code[003056] = *S03056; sub S03056 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003057] = 04446; $code[003057] = *I03057; sub I03057 { $core[($ib<<12)+$core[38]] = 03060; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[003060] = 05744; $code[003060] = *I03060; sub I03060 { $pc = ($ib<<12)+$core[1636]; $inh = 0; goto &fetch; }
$core[003061] = 01037; $code[003061] = *I03061; sub I03061 { $lac += $core[000037]; goto &fetch; }
$core[003062] = 04673; $code[003062] = *I03062; sub I03062 { $core[($ib<<12)+$core[1595]] = 03063; $pc = ($ib<<12)+$core[1595]+1; $code[($ib<<12)+$core[1595]] = *emul8; $inh = 0; goto &fetch; }
$core[003063] = 07340; $code[003063] = *I03063; sub I03063 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003064] = 00025; $code[003064] = *I03064; sub I03064 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[003065] = 03037; $code[003065] = *I03065; sub I03065 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[003066] = 00026; $code[003066] = *I03066; sub I03066 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[003067] = 03040; $code[003067] = *I03067; sub I03067 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[003070] = 04460; $code[003070] = *I03070; sub I03070 { $core[($ib<<12)+$core[48]] = 03071; $pc = ($ib<<12)+$core[48]+1; $code[($ib<<12)+$core[48]] = *emul8; $inh = 0; goto &fetch; }
$core[003071] = 04461; $code[003071] = *I03071; sub I03071 { $core[($ib<<12)+$core[49]] = 03072; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[003072] = 05656; $code[003072] = *I03072; sub I03072 { $pc = ($ib<<12)+$core[1582]; $inh = 0; goto &fetch; }
$core[003073] = 03227; $code[003073] = *P03073; sub P03073 { $core[003027] = $lac & 07777; $lac &= 010000; $code[003027] = *emul8; goto &fetch; }
$core[003200] = 07300; $code[003200] = *L03200; sub L03200 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003201] = 02020; $code[003201] = *I03201; sub I03201 { if (++$core[000020] == 010000) { $core[000020] = 0; $pc++; }$code[000020] = *emul8; goto &fetch; }
$core[003202] = 05224; $code[003202] = *I03202; sub I03202 { $pc = 003224; $inh = 0; goto &fetch; }
$core[003203] = 07604; $code[003203] = *I03203; sub I03203 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003204] = 00115; $code[003204] = *I03204; sub I03204 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[003205] = 07650; $code[003205] = *I03205; sub I03205 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003206] = 05221; $code[003206] = *I03206; sub I03206 { $pc = 003221; $inh = 0; goto &fetch; }
$core[003207] = 07604; $code[003207] = *L03207; sub L03207 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003210] = 00114; $code[003210] = *I03210; sub I03210 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[003211] = 07640; $code[003211] = *I03211; sub I03211 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003212] = 07402; $code[003212] = *I03212; sub I03212 { $hlt = 1; goto &fetch; }
$core[003213] = 07604; $code[003213] = *I03213; sub I03213 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003214] = 00116; $code[003214] = *I03214; sub I03214 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[003215] = 07640; $code[003215] = *I03215; sub I03215 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003216] = 05224; $code[003216] = *I03216; sub I03216 { $pc = 003224; $inh = 0; goto &fetch; }
$core[003217] = 05620; $code[003217] = *I03217; sub I03217 { $pc = ($ib<<12)+$core[1680]; $inh = 0; goto &fetch; }
$core[003220] = 03400; $code[003220] = *P03220; sub P03220 { $core[($df<<12)+$core[0]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[003221] = 04446; $code[003221] = *L03221; sub L03221 { $core[($ib<<12)+$core[38]] = 03222; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[003222] = 05732; $code[003222] = *I03222; sub I03222 { $pc = ($ib<<12)+$core[1754]; $inh = 0; goto &fetch; }
$core[003223] = 05207; $code[003223] = *I03223; sub I03223 { $pc = 003207; $inh = 0; goto &fetch; }
$core[003224] = 01122; $code[003224] = *L03224; sub L03224 { $lac += $core[000122]; goto &fetch; }
$core[003225] = 03154; $code[003225] = *I03225; sub I03225 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[003226] = 05554; $code[003226] = *I03226; sub I03226 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[003227] = 00000; $code[003227] = *S03227; sub S03227 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003230] = 03037; $code[003230] = *I03230; sub I03230 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[003231] = 01037; $code[003231] = *I03231; sub I03231 { $lac += $core[000037]; goto &fetch; }
$core[003232] = 00172; $code[003232] = *I03232; sub I03232 { $lac &= (010000|$core[000172]); goto &fetch; }
$core[003233] = 03264; $code[003233] = *I03233; sub I03233 { $core[003264] = $lac & 07777; $lac &= 010000; $code[003264] = *emul8; goto &fetch; }
$core[003234] = 01037; $code[003234] = *I03234; sub I03234 { $lac += $core[000037]; goto &fetch; }
$core[003235] = 07006; $code[003235] = *I03235; sub I03235 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003236] = 07004; $code[003236] = *I03236; sub I03236 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003237] = 00266; $code[003237] = *I03237; sub I03237 { $lac &= (010000|$core[003266]); goto &fetch; }
$core[003240] = 01264; $code[003240] = *I03240; sub I03240 { $lac += $core[003264]; goto &fetch; }
$core[003241] = 01267; $code[003241] = *I03241; sub I03241 { $lac += $core[003267]; goto &fetch; }
$core[003242] = 03264; $code[003242] = *I03242; sub I03242 { $core[003264] = $lac & 07777; $lac &= 010000; $code[003264] = *emul8; goto &fetch; }
$core[003243] = 01037; $code[003243] = *I03243; sub I03243 { $lac += $core[000037]; goto &fetch; }
$core[003244] = 07012; $code[003244] = *I03244; sub I03244 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003245] = 07012; $code[003245] = *I03245; sub I03245 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003246] = 07012; $code[003246] = *I03246; sub I03246 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003247] = 00172; $code[003247] = *I03247; sub I03247 { $lac &= (010000|$core[000172]); goto &fetch; }
$core[003250] = 03263; $code[003250] = *I03250; sub I03250 { $core[003263] = $lac & 07777; $lac &= 010000; $code[003263] = *emul8; goto &fetch; }
$core[003251] = 01037; $code[003251] = *I03251; sub I03251 { $lac += $core[000037]; goto &fetch; }
$core[003252] = 07012; $code[003252] = *I03252; sub I03252 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003253] = 07010; $code[003253] = *I03253; sub I03253 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003254] = 00266; $code[003254] = *I03254; sub I03254 { $lac &= (010000|$core[003266]); goto &fetch; }
$core[003255] = 01263; $code[003255] = *I03255; sub I03255 { $lac += $core[003263]; goto &fetch; }
$core[003256] = 01267; $code[003256] = *I03256; sub I03256 { $lac += $core[003267]; goto &fetch; }
$core[003257] = 03263; $code[003257] = *I03257; sub I03257 { $core[003263] = $lac & 07777; $lac &= 010000; $code[003263] = *emul8; goto &fetch; }
$core[003260] = 04446; $code[003260] = *I03260; sub I03260 { $core[($ib<<12)+$core[38]] = 03261; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[003261] = 03262; $code[003261] = *I03261; sub I03261 { $core[003262] = $lac & 07777; $lac &= 010000; $code[003262] = *emul8; goto &fetch; }
$core[003262] = 05627; $code[003262] = *D03262; sub D03262 { $pc = ($ib<<12)+$core[1687]; $inh = 0; goto &fetch; }
$core[003263] = 00000; $code[003263] = *D03263; sub D03263 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003264] = 00000; $code[003264] = *D03264; sub D03264 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003265] = 04000; $code[003265] = *I03265; sub I03265 { $core[000000] = 03266; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[003266] = 00700; $code[003266] = *D03266; sub D03266 { $lac &= (010000|$core[($df<<12)+$core[1728]]); goto &fetch; }
$core[003267] = 06060; $code[003267] = *D03267; sub D03267 { &emul8; goto &fetch; }
$core[003400] = 07300; $code[003400] = *P03400; sub P03400 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003401] = 04473; $code[003401] = *I03401; sub I03401 { $core[($ib<<12)+$core[59]] = 03402; $pc = ($ib<<12)+$core[59]+1; $code[($ib<<12)+$core[59]] = *emul8; $inh = 0; goto &fetch; }
$core[003402] = 07300; $code[003402] = *L03402; sub L03402 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003403] = 01041; $code[003403] = *I03403; sub I03403 { $lac += $core[000041]; goto &fetch; }
$core[003404] = 01043; $code[003404] = *I03404; sub I03404 { $lac += $core[000043]; goto &fetch; }
$core[003405] = 01043; $code[003405] = *I03405; sub I03405 { $lac += $core[000043]; goto &fetch; }
$core[003406] = 01041; $code[003406] = *I03406; sub I03406 { $lac += $core[000041]; goto &fetch; }
$core[003407] = 01041; $code[003407] = *I03407; sub I03407 { $lac += $core[000041]; goto &fetch; }
$core[003410] = 01041; $code[003410] = *I03410; sub I03410 { $lac += $core[000041]; goto &fetch; }
$core[003411] = 01043; $code[003411] = *I03411; sub I03411 { $lac += $core[000043]; goto &fetch; }
$core[003412] = 01043; $code[003412] = *I03412; sub I03412 { $lac += $core[000043]; goto &fetch; }
$core[003413] = 01041; $code[003413] = *I03413; sub I03413 { $lac += $core[000041]; goto &fetch; }
$core[003414] = 01041; $code[003414] = *I03414; sub I03414 { $lac += $core[000041]; goto &fetch; }
$core[003415] = 01043; $code[003415] = *I03415; sub I03415 { $lac += $core[000043]; goto &fetch; }
$core[003416] = 01041; $code[003416] = *I03416; sub I03416 { $lac += $core[000041]; goto &fetch; }
$core[003417] = 01043; $code[003417] = *I03417; sub I03417 { $lac += $core[000043]; goto &fetch; }
$core[003420] = 01043; $code[003420] = *I03420; sub I03420 { $lac += $core[000043]; goto &fetch; }
$core[003421] = 01041; $code[003421] = *I03421; sub I03421 { $lac += $core[000041]; goto &fetch; }
$core[003422] = 01041; $code[003422] = *I03422; sub I03422 { $lac += $core[000041]; goto &fetch; }
$core[003423] = 01043; $code[003423] = *I03423; sub I03423 { $lac += $core[000043]; goto &fetch; }
$core[003424] = 01043; $code[003424] = *I03424; sub I03424 { $lac += $core[000043]; goto &fetch; }
$core[003425] = 01043; $code[003425] = *I03425; sub I03425 { $lac += $core[000043]; goto &fetch; }
$core[003426] = 01041; $code[003426] = *I03426; sub I03426 { $lac += $core[000041]; goto &fetch; }
$core[003427] = 01043; $code[003427] = *I03427; sub I03427 { $lac += $core[000043]; goto &fetch; }
$core[003430] = 01041; $code[003430] = *I03430; sub I03430 { $lac += $core[000041]; goto &fetch; }
$core[003431] = 01041; $code[003431] = *I03431; sub I03431 { $lac += $core[000041]; goto &fetch; }
$core[003432] = 01041; $code[003432] = *I03432; sub I03432 { $lac += $core[000041]; goto &fetch; }
$core[003433] = 01043; $code[003433] = *I03433; sub I03433 { $lac += $core[000043]; goto &fetch; }
$core[003434] = 01043; $code[003434] = *I03434; sub I03434 { $lac += $core[000043]; goto &fetch; }
$core[003435] = 07000; $code[003435] = *I03435; sub I03435 { goto &fetch; }
$core[003436] = 04464; $code[003436] = *I03436; sub I03436 { $core[($ib<<12)+$core[52]] = 03437; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[003437] = 07430; $code[003437] = *I03437; sub I03437 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003440] = 07440; $code[003440] = *I03440; sub I03440 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003441] = 04646; $code[003441] = *I03441; sub I03441 { $core[($ib<<12)+$core[1830]] = 03442; $pc = ($ib<<12)+$core[1830]+1; $code[($ib<<12)+$core[1830]] = *emul8; $inh = 0; goto &fetch; }
$core[003442] = 04467; $code[003442] = *I03442; sub I03442 { $core[($ib<<12)+$core[55]] = 03443; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[003443] = 05202; $code[003443] = *I03443; sub I03443 { $pc = 003402; $inh = 0; goto &fetch; }
$core[003444] = 05645; $code[003444] = *I03444; sub I03444 { $pc = ($ib<<12)+$core[1829]; $inh = 0; goto &fetch; }
$core[003445] = 03600; $code[003445] = *P03445; sub P03445 { $core[($df<<12)+$core[1792]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1792]] = *emul8; goto &fetch; }
$core[003446] = 03447; $code[003446] = *P03446; sub P03446 { $core[($df<<12)+$core[39]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[39]] = *emul8; goto &fetch; }
$core[003447] = 00000; $code[003447] = *S03447; sub S03447 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003450] = 07604; $code[003450] = *I03450; sub I03450 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003451] = 00104; $code[003451] = *I03451; sub I03451 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[003452] = 07640; $code[003452] = *I03452; sub I03452 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003453] = 05302; $code[003453] = *I03453; sub I03453 { $pc = 003502; $inh = 0; goto &fetch; }
$core[003454] = 04446; $code[003454] = *I03454; sub I03454 { $core[($ib<<12)+$core[38]] = 03455; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[003455] = 05565; $code[003455] = *I03455; sub I03455 { $pc = ($ib<<12)+$core[117]; $inh = 0; goto &fetch; }
$core[003456] = 04446; $code[003456] = *I03456; sub I03456 { $core[($ib<<12)+$core[38]] = 03457; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[003457] = 05316; $code[003457] = *I03457; sub I03457 { $pc = 003516; $inh = 0; goto &fetch; }
$core[003460] = 07340; $code[003460] = *I03460; sub I03460 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003461] = 00041; $code[003461] = *I03461; sub I03461 { $lac &= (010000|$core[000041]); goto &fetch; }
$core[003462] = 03037; $code[003462] = *I03462; sub I03462 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[003463] = 04461; $code[003463] = *I03463; sub I03463 { $core[($ib<<12)+$core[49]] = 03464; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[003464] = 07340; $code[003464] = *I03464; sub I03464 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003465] = 00043; $code[003465] = *I03465; sub I03465 { $lac &= (010000|$core[000043]); goto &fetch; }
$core[003466] = 03037; $code[003466] = *I03466; sub I03466 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[003467] = 04461; $code[003467] = *I03467; sub I03467 { $core[($ib<<12)+$core[49]] = 03470; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[003470] = 07340; $code[003470] = *I03470; sub I03470 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003471] = 00025; $code[003471] = *I03471; sub I03471 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[003472] = 03037; $code[003472] = *I03472; sub I03472 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[003473] = 07040; $code[003473] = *I03473; sub I03473 { $lac ^= 07777; goto &fetch; }
$core[003474] = 00026; $code[003474] = *I03474; sub I03474 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[003475] = 03040; $code[003475] = *I03475; sub I03475 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[003476] = 04460; $code[003476] = *I03476; sub I03476 { $core[($ib<<12)+$core[48]] = 03477; $pc = ($ib<<12)+$core[48]+1; $code[($ib<<12)+$core[48]] = *emul8; $inh = 0; goto &fetch; }
$core[003477] = 04461; $code[003477] = *I03477; sub I03477 { $core[($ib<<12)+$core[49]] = 03500; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[003500] = 04446; $code[003500] = *I03500; sub I03500 { $core[($ib<<12)+$core[38]] = 03501; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[003501] = 05742; $code[003501] = *I03501; sub I03501 { $pc = ($ib<<12)+$core[1890]; $inh = 0; goto &fetch; }
$core[003502] = 07604; $code[003502] = *L03502; sub L03502 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003503] = 00103; $code[003503] = *I03503; sub I03503 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[003504] = 07640; $code[003504] = *I03504; sub I03504 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003505] = 05647; $code[003505] = *I03505; sub I03505 { $pc = ($ib<<12)+$core[1831]; $inh = 0; goto &fetch; }
$core[003506] = 07300; $code[003506] = *I03506; sub I03506 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003507] = 01247; $code[003507] = *I03507; sub I03507 { $lac += $core[003447]; goto &fetch; }
$core[003510] = 07402; $code[003510] = *I03510; sub I03510 { $hlt = 1; goto &fetch; }
$core[003511] = 05647; $code[003511] = *I03511; sub I03511 { $pc = ($ib<<12)+$core[1831]; $inh = 0; goto &fetch; }
$core[003512] = 00000; $code[003512] = *S03512; sub S03512 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003513] = 07300; $code[003513] = *I03513; sub I03513 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003514] = 01041; $code[003514] = *I03514; sub I03514 { $lac += $core[000041]; goto &fetch; }
$core[003515] = 07004; $code[003515] = *I03515; sub I03515 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003516] = 07430; $code[003516] = *L03516; sub L03516 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003517] = 01342; $code[003517] = *I03517; sub I03517 { $lac += $core[003542]; goto &fetch; }
$core[003520] = 03041; $code[003520] = *I03520; sub I03520 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[003521] = 01041; $code[003521] = *I03521; sub I03521 { $lac += $core[000041]; goto &fetch; }
$core[003522] = 07041; $code[003522] = *I03522; sub I03522 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003523] = 03043; $code[003523] = *I03523; sub I03523 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[003524] = 07100; $code[003524] = *I03524; sub I03524 { $lac &= 07777; goto &fetch; }
$core[003525] = 01341; $code[003525] = *I03525; sub I03525 { $lac += $core[003541]; goto &fetch; }
$core[003526] = 07004; $code[003526] = *I03526; sub I03526 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003527] = 07430; $code[003527] = *I03527; sub I03527 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003530] = 01342; $code[003530] = *I03530; sub I03530 { $lac += $core[003542]; goto &fetch; }
$core[003531] = 03341; $code[003531] = *I03531; sub I03531 { $core[003541] = $lac & 07777; $lac &= 010000; $code[003541] = *emul8; goto &fetch; }
$core[003532] = 07430; $code[003532] = *I03532; sub I03532 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003533] = 07040; $code[003533] = *I03533; sub I03533 { $lac ^= 07777; goto &fetch; }
$core[003534] = 03044; $code[003534] = *I03534; sub I03534 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[003535] = 01044; $code[003535] = *I03535; sub I03535 { $lac += $core[000044]; goto &fetch; }
$core[003536] = 07040; $code[003536] = *I03536; sub I03536 { $lac ^= 07777; goto &fetch; }
$core[003537] = 03045; $code[003537] = *I03537; sub I03537 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[003540] = 05712; $code[003540] = *I03540; sub I03540 { $pc = ($ib<<12)+$core[1866]; $inh = 0; goto &fetch; }
$core[003541] = 00001; $code[003541] = *D03541; sub D03541 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003542] = 00003; $code[003542] = *P03542; sub P03542 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003600] = 07340; $code[003600] = *L03600; sub L03600 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003601] = 00041; $code[003601] = *I03601; sub I03601 { $lac &= (010000|$core[000041]); goto &fetch; }
$core[003602] = 03346; $code[003602] = *I03602; sub I03602 { $core[003746] = $lac & 07777; $lac &= 010000; $code[003746] = *emul8; goto &fetch; }
$core[003603] = 07040; $code[003603] = *I03603; sub I03603 { $lac ^= 07777; goto &fetch; }
$core[003604] = 00041; $code[003604] = *I03604; sub I03604 { $lac &= (010000|$core[000041]); goto &fetch; }
$core[003605] = 07040; $code[003605] = *I03605; sub I03605 { $lac ^= 07777; goto &fetch; }
$core[003606] = 03347; $code[003606] = *I03606; sub I03606 { $core[003747] = $lac & 07777; $lac &= 010000; $code[003747] = *emul8; goto &fetch; }
$core[003607] = 07040; $code[003607] = *I03607; sub I03607 { $lac ^= 07777; goto &fetch; }
$core[003610] = 00103; $code[003610] = *I03610; sub I03610 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[003611] = 03352; $code[003611] = *I03611; sub I03611 { $core[003752] = $lac & 07777; $lac &= 010000; $code[003752] = *emul8; goto &fetch; }
$core[003612] = 07040; $code[003612] = *L03612; sub L03612 { $lac ^= 07777; goto &fetch; }
$core[003613] = 00352; $code[003613] = *I03613; sub I03613 { $lac &= (010000|$core[003752]); goto &fetch; }
$core[003614] = 07040; $code[003614] = *I03614; sub I03614 { $lac ^= 07777; goto &fetch; }
$core[003615] = 03353; $code[003615] = *I03615; sub I03615 { $core[003753] = $lac & 07777; $lac &= 010000; $code[003753] = *emul8; goto &fetch; }
$core[003616] = 07040; $code[003616] = *I03616; sub I03616 { $lac ^= 07777; goto &fetch; }
$core[003617] = 00346; $code[003617] = *I03617; sub I03617 { $lac &= (010000|$core[003746]); goto &fetch; }
$core[003620] = 00352; $code[003620] = *I03620; sub I03620 { $lac &= (010000|$core[003752]); goto &fetch; }
$core[003621] = 07440; $code[003621] = *I03621; sub I03621 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003622] = 05232; $code[003622] = *I03622; sub I03622 { $pc = 003632; $inh = 0; goto &fetch; }
$core[003623] = 07040; $code[003623] = *I03623; sub I03623 { $lac ^= 07777; goto &fetch; }
$core[003624] = 00346; $code[003624] = *I03624; sub I03624 { $lac &= (010000|$core[003746]); goto &fetch; }
$core[003625] = 04301; $code[003625] = *I03625; sub I03625 { $core[003701] = 03626; $pc = 003701+1; $code[003701] = *emul8; $inh = 0; goto &fetch; }
$core[003626] = 07040; $code[003626] = *I03626; sub I03626 { $lac ^= 07777; goto &fetch; }
$core[003627] = 00347; $code[003627] = *I03627; sub I03627 { $lac &= (010000|$core[003747]); goto &fetch; }
$core[003630] = 03351; $code[003630] = *I03630; sub I03630 { $core[003751] = $lac & 07777; $lac &= 010000; $code[003751] = *emul8; goto &fetch; }
$core[003631] = 05240; $code[003631] = *I03631; sub I03631 { $pc = 003640; $inh = 0; goto &fetch; }
$core[003632] = 07240; $code[003632] = *L03632; sub L03632 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003633] = 00347; $code[003633] = *I03633; sub I03633 { $lac &= (010000|$core[003747]); goto &fetch; }
$core[003634] = 04315; $code[003634] = *I03634; sub I03634 { $core[003715] = 03635; $pc = 003715+1; $code[003715] = *emul8; $inh = 0; goto &fetch; }
$core[003635] = 07040; $code[003635] = *I03635; sub I03635 { $lac ^= 07777; goto &fetch; }
$core[003636] = 00346; $code[003636] = *I03636; sub I03636 { $lac &= (010000|$core[003746]); goto &fetch; }
$core[003637] = 03351; $code[003637] = *I03637; sub I03637 { $core[003751] = $lac & 07777; $lac &= 010000; $code[003751] = *emul8; goto &fetch; }
$core[003640] = 07340; $code[003640] = *L03640; sub L03640 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003641] = 00350; $code[003641] = *I03641; sub I03641 { $lac &= (010000|$core[003750]); goto &fetch; }
$core[003642] = 01351; $code[003642] = *I03642; sub I03642 { $lac += $core[003751]; goto &fetch; }
$core[003643] = 07430; $code[003643] = *I03643; sub I03643 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003644] = 07001; $code[003644] = *I03644; sub I03644 { $lac++; goto &fetch; }
$core[003645] = 04464; $code[003645] = *I03645; sub I03645 { $core[($ib<<12)+$core[52]] = 03646; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[003646] = 04463; $code[003646] = *I03646; sub I03646 { $core[($ib<<12)+$core[51]] = 03647; $pc = ($ib<<12)+$core[51]+1; $code[($ib<<12)+$core[51]] = *emul8; $inh = 0; goto &fetch; }
$core[003647] = 07410; $code[003647] = *I03647; sub I03647 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003650] = 04756; $code[003650] = *I03650; sub I03650 { $core[($ib<<12)+$core[2030]] = 03651; $pc = ($ib<<12)+$core[2030]+1; $code[($ib<<12)+$core[2030]] = *emul8; $inh = 0; goto &fetch; }
$core[003651] = 04467; $code[003651] = *I03651; sub I03651 { $core[($ib<<12)+$core[55]] = 03652; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[003652] = 05240; $code[003652] = *I03652; sub I03652 { $pc = 003640; $inh = 0; goto &fetch; }
$core[003653] = 05254; $code[003653] = *I03653; sub I03653 { $pc = 003654; $inh = 0; goto &fetch; }
$core[003654] = 07340; $code[003654] = *L03654; sub L03654 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003655] = 00351; $code[003655] = *I03655; sub I03655 { $lac &= (010000|$core[003751]); goto &fetch; }
$core[003656] = 01350; $code[003656] = *I03656; sub I03656 { $lac += $core[003750]; goto &fetch; }
$core[003657] = 07430; $code[003657] = *I03657; sub I03657 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003660] = 07001; $code[003660] = *I03660; sub I03660 { $lac++; goto &fetch; }
$core[003661] = 04464; $code[003661] = *I03661; sub I03661 { $core[($ib<<12)+$core[52]] = 03662; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[003662] = 04463; $code[003662] = *I03662; sub I03662 { $core[($ib<<12)+$core[51]] = 03663; $pc = ($ib<<12)+$core[51]+1; $code[($ib<<12)+$core[51]] = *emul8; $inh = 0; goto &fetch; }
$core[003663] = 07410; $code[003663] = *I03663; sub I03663 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003664] = 04756; $code[003664] = *I03664; sub I03664 { $core[($ib<<12)+$core[2030]] = 03665; $pc = ($ib<<12)+$core[2030]+1; $code[($ib<<12)+$core[2030]] = *emul8; $inh = 0; goto &fetch; }
$core[003665] = 04467; $code[003665] = *I03665; sub I03665 { $core[($ib<<12)+$core[55]] = 03666; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[003666] = 05254; $code[003666] = *I03666; sub I03666 { $pc = 003654; $inh = 0; goto &fetch; }
$core[003667] = 07340; $code[003667] = *I03667; sub I03667 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003670] = 00352; $code[003670] = *I03670; sub I03670 { $lac &= (010000|$core[003752]); goto &fetch; }
$core[003671] = 07010; $code[003671] = *I03671; sub I03671 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003672] = 03352; $code[003672] = *I03672; sub I03672 { $core[003752] = $lac & 07777; $lac &= 010000; $code[003752] = *emul8; goto &fetch; }
$core[003673] = 07420; $code[003673] = *I03673; sub I03673 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003674] = 05212; $code[003674] = *I03674; sub I03674 { $pc = 003612; $inh = 0; goto &fetch; }
$core[003675] = 04467; $code[003675] = *I03675; sub I03675 { $core[($ib<<12)+$core[55]] = 03676; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[003676] = 05200; $code[003676] = *I03676; sub I03676 { $pc = 003600; $inh = 0; goto &fetch; }
$core[003677] = 05700; $code[003677] = *I03677; sub I03677 { $pc = ($ib<<12)+$core[1984]; $inh = 0; goto &fetch; }
$core[003700] = 04200; $code[003700] = *P03700; sub P03700 { $core[003600] = 03701; $pc = 003600+1; $code[003600] = *emul8; $inh = 0; goto &fetch; }
$core[003701] = 00000; $code[003701] = *S03701; sub S03701 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003702] = 00353; $code[003702] = *I03702; sub I03702 { $lac &= (010000|$core[003753]); goto &fetch; }
$core[003703] = 07040; $code[003703] = *I03703; sub I03703 { $lac ^= 07777; goto &fetch; }
$core[003704] = 03354; $code[003704] = *I03704; sub I03704 { $core[003754] = $lac & 07777; $lac &= 010000; $code[003754] = *emul8; goto &fetch; }
$core[003705] = 07040; $code[003705] = *I03705; sub I03705 { $lac ^= 07777; goto &fetch; }
$core[003706] = 00347; $code[003706] = *I03706; sub I03706 { $lac &= (010000|$core[003747]); goto &fetch; }
$core[003707] = 00352; $code[003707] = *I03707; sub I03707 { $lac &= (010000|$core[003752]); goto &fetch; }
$core[003710] = 07040; $code[003710] = *I03710; sub I03710 { $lac ^= 07777; goto &fetch; }
$core[003711] = 00354; $code[003711] = *I03711; sub I03711 { $lac &= (010000|$core[003754]); goto &fetch; }
$core[003712] = 07040; $code[003712] = *I03712; sub I03712 { $lac ^= 07777; goto &fetch; }
$core[003713] = 03350; $code[003713] = *I03713; sub I03713 { $core[003750] = $lac & 07777; $lac &= 010000; $code[003750] = *emul8; goto &fetch; }
$core[003714] = 05701; $code[003714] = *I03714; sub I03714 { $pc = ($ib<<12)+$core[1985]; $inh = 0; goto &fetch; }
$core[003715] = 00000; $code[003715] = *S03715; sub S03715 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003716] = 00352; $code[003716] = *I03716; sub I03716 { $lac &= (010000|$core[003752]); goto &fetch; }
$core[003717] = 07040; $code[003717] = *I03717; sub I03717 { $lac ^= 07777; goto &fetch; }
$core[003720] = 03354; $code[003720] = *I03720; sub I03720 { $core[003754] = $lac & 07777; $lac &= 010000; $code[003754] = *emul8; goto &fetch; }
$core[003721] = 07040; $code[003721] = *I03721; sub I03721 { $lac ^= 07777; goto &fetch; }
$core[003722] = 00346; $code[003722] = *I03722; sub I03722 { $lac &= (010000|$core[003746]); goto &fetch; }
$core[003723] = 00353; $code[003723] = *I03723; sub I03723 { $lac &= (010000|$core[003753]); goto &fetch; }
$core[003724] = 07040; $code[003724] = *I03724; sub I03724 { $lac ^= 07777; goto &fetch; }
$core[003725] = 00354; $code[003725] = *I03725; sub I03725 { $lac &= (010000|$core[003754]); goto &fetch; }
$core[003726] = 03350; $code[003726] = *I03726; sub I03726 { $core[003750] = $lac & 07777; $lac &= 010000; $code[003750] = *emul8; goto &fetch; }
$core[003727] = 05715; $code[003727] = *I03727; sub I03727 { $pc = ($ib<<12)+$core[1997]; $inh = 0; goto &fetch; }
$core[003730] = 00000; $code[003730] = *S03730; sub S03730 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003731] = 07040; $code[003731] = *I03731; sub I03731 { $lac ^= 07777; goto &fetch; }
$core[003732] = 03355; $code[003732] = *I03732; sub I03732 { $core[003755] = $lac & 07777; $lac &= 010000; $code[003755] = *emul8; goto &fetch; }
$core[003733] = 07040; $code[003733] = *I03733; sub I03733 { $lac ^= 07777; goto &fetch; }
$core[003734] = 00025; $code[003734] = *I03734; sub I03734 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[003735] = 00353; $code[003735] = *I03735; sub I03735 { $lac &= (010000|$core[003753]); goto &fetch; }
$core[003736] = 07440; $code[003736] = *D03736; sub D03736 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003737] = 05344; $code[003737] = *I03737; sub I03737 { $pc = 003744; $inh = 0; goto &fetch; }
$core[003740] = 07040; $code[003740] = *I03740; sub I03740 { $lac ^= 07777; goto &fetch; }
$core[003741] = 00352; $code[003741] = *I03741; sub I03741 { $lac &= (010000|$core[003752]); goto &fetch; }
$core[003742] = 00355; $code[003742] = *I03742; sub I03742 { $lac &= (010000|$core[003755]); goto &fetch; }
$core[003743] = 07440; $code[003743] = *I03743; sub I03743 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003744] = 02330; $code[003744] = *L03744; sub L03744 { if (++$core[003730] == 010000) { $core[003730] = 0; $pc++; }$code[003730] = *emul8; goto &fetch; }
$core[003745] = 05730; $code[003745] = *I03745; sub I03745 { $pc = ($ib<<12)+$core[2008]; $inh = 0; goto &fetch; }
$core[003746] = 00000; $code[003746] = *D03746; sub D03746 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003747] = 00000; $code[003747] = *D03747; sub D03747 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003750] = 00000; $code[003750] = *D03750; sub D03750 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003751] = 00000; $code[003751] = *D03751; sub D03751 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003752] = 00000; $code[003752] = *D03752; sub D03752 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003753] = 00000; $code[003753] = *D03753; sub D03753 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003754] = 00000; $code[003754] = *D03754; sub D03754 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003755] = 00000; $code[003755] = *D03755; sub D03755 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003756] = 04000; $code[003756] = *P03756; sub P03756 { $core[000000] = 03757; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[004000] = 00000; $code[004000] = *S04000; sub S04000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004001] = 07604; $code[004001] = *I04001; sub I04001 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004002] = 00104; $code[004002] = *I04002; sub I04002 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[004003] = 07640; $code[004003] = *I04003; sub I04003 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004004] = 05233; $code[004004] = *I04004; sub I04004 { $pc = 004033; $inh = 0; goto &fetch; }
$core[004005] = 04446; $code[004005] = *P04005; sub P04005 { $core[($ib<<12)+$core[38]] = 04006; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[004006] = 05605; $code[004006] = *I04006; sub I04006 { $pc = ($ib<<12)+$core[2053]; $inh = 0; goto &fetch; }
$core[004007] = 04446; $code[004007] = *I04007; sub I04007 { $core[($ib<<12)+$core[38]] = 04010; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[004010] = 05364; $code[004010] = *I04010; sub I04010 { $pc = 004164; $inh = 0; goto &fetch; }
$core[004011] = 07340; $code[004011] = *I04011; sub I04011 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[004012] = 00777; $code[004012] = *I04012; sub I04012 { $lac &= (010000|$core[($df<<12)+$core[2175]]); goto &fetch; }
$core[004013] = 03037; $code[004013] = *I04013; sub I04013 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[004014] = 04461; $code[004014] = *I04014; sub I04014 { $core[($ib<<12)+$core[49]] = 04015; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[004015] = 07040; $code[004015] = *I04015; sub I04015 { $lac ^= 07777; goto &fetch; }
$core[004016] = 00776; $code[004016] = *I04016; sub I04016 { $lac &= (010000|$core[($df<<12)+$core[2174]]); goto &fetch; }
$core[004017] = 03037; $code[004017] = *I04017; sub I04017 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[004020] = 04461; $code[004020] = *I04020; sub I04020 { $core[($ib<<12)+$core[49]] = 04021; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[004021] = 07040; $code[004021] = *I04021; sub I04021 { $lac ^= 07777; goto &fetch; }
$core[004022] = 00775; $code[004022] = *D04022; sub D04022 { $lac &= (010000|$core[($df<<12)+$core[2173]]); goto &fetch; }
$core[004023] = 03037; $code[004023] = *I04023; sub I04023 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[004024] = 04461; $code[004024] = *D04024; sub D04024 { $core[($ib<<12)+$core[49]] = 04025; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[004025] = 07040; $code[004025] = *I04025; sub I04025 { $lac ^= 07777; goto &fetch; }
$core[004026] = 00025; $code[004026] = *I04026; sub I04026 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[004027] = 03037; $code[004027] = *I04027; sub I04027 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[004030] = 04461; $code[004030] = *I04030; sub I04030 { $core[($ib<<12)+$core[49]] = 04031; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[004031] = 04446; $code[004031] = *I04031; sub I04031 { $core[($ib<<12)+$core[38]] = 04032; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[004032] = 05742; $code[004032] = *I04032; sub I04032 { $pc = ($ib<<12)+$core[2146]; $inh = 0; goto &fetch; }
$core[004033] = 07604; $code[004033] = *L04033; sub L04033 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004034] = 00103; $code[004034] = *I04034; sub I04034 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[004035] = 07640; $code[004035] = *I04035; sub I04035 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004036] = 05600; $code[004036] = *I04036; sub I04036 { $pc = ($ib<<12)+$core[2048]; $inh = 0; goto &fetch; }
$core[004037] = 07300; $code[004037] = *I04037; sub I04037 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004040] = 01200; $code[004040] = *D04040; sub D04040 { $lac += $core[004000]; goto &fetch; }
$core[004041] = 07402; $code[004041] = *I04041; sub I04041 { $hlt = 1; goto &fetch; }
$core[004042] = 05600; $code[004042] = *I04042; sub I04042 { $pc = ($ib<<12)+$core[2048]; $inh = 0; goto &fetch; }
$core[004175] = 03752; $code[004175] = *P04175; sub P04175 { $core[($df<<12)+$core[2154]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2154]] = *emul8; goto &fetch; }
$core[004176] = 03751; $code[004176] = *P04176; sub P04176 { $core[($df<<12)+$core[2153]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2153]] = *emul8; goto &fetch; }
$core[004177] = 03750; $code[004177] = *P04177; sub P04177 { $core[($df<<12)+$core[2152]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2152]] = *emul8; goto &fetch; }
$core[004200] = 07300; $code[004200] = *L04200; sub L04200 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004201] = 01044; $code[004201] = *I04201; sub I04201 { $lac += $core[000044]; goto &fetch; }
$core[004202] = 07440; $code[004202] = *I04202; sub I04202 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004203] = 07220; $code[004203] = *I04203; sub I04203 { $lac &= 010000; $lac ^= 010000; goto &fetch; }
$core[004204] = 01041; $code[004204] = *I04204; sub I04204 { $lac += $core[000041]; goto &fetch; }
$core[004205] = 07010; $code[004205] = *I04205; sub I04205 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004206] = 07010; $code[004206] = *I04206; sub I04206 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004207] = 07010; $code[004207] = *I04207; sub I04207 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004210] = 07010; $code[004210] = *I04210; sub I04210 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004211] = 07010; $code[004211] = *I04211; sub I04211 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004212] = 07010; $code[004212] = *I04212; sub I04212 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004213] = 07010; $code[004213] = *I04213; sub I04213 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004214] = 07010; $code[004214] = *I04214; sub I04214 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004215] = 07010; $code[004215] = *I04215; sub I04215 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004216] = 07010; $code[004216] = *I04216; sub I04216 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004217] = 07010; $code[004217] = *I04217; sub I04217 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004220] = 07010; $code[004220] = *I04220; sub I04220 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004221] = 07010; $code[004221] = *I04221; sub I04221 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004222] = 07010; $code[004222] = *I04222; sub I04222 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004223] = 07010; $code[004223] = *I04223; sub I04223 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004224] = 07010; $code[004224] = *I04224; sub I04224 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004225] = 07010; $code[004225] = *I04225; sub I04225 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004226] = 07010; $code[004226] = *I04226; sub I04226 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004227] = 07010; $code[004227] = *I04227; sub I04227 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004230] = 07010; $code[004230] = *I04230; sub I04230 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004231] = 07010; $code[004231] = *I04231; sub I04231 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004232] = 07010; $code[004232] = *I04232; sub I04232 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004233] = 07010; $code[004233] = *I04233; sub I04233 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004234] = 07010; $code[004234] = *I04234; sub I04234 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004235] = 07010; $code[004235] = *I04235; sub I04235 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004236] = 07010; $code[004236] = *I04236; sub I04236 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004237] = 07000; $code[004237] = *I04237; sub I04237 { goto &fetch; }
$core[004240] = 07000; $code[004240] = *I04240; sub I04240 { goto &fetch; }
$core[004241] = 04464; $code[004241] = *I04241; sub I04241 { $core[($ib<<12)+$core[52]] = 04242; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[004242] = 01043; $code[004242] = *I04242; sub I04242 { $lac += $core[000043]; goto &fetch; }
$core[004243] = 07640; $code[004243] = *I04243; sub I04243 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004244] = 05250; $code[004244] = *I04244; sub I04244 { $pc = 004250; $inh = 0; goto &fetch; }
$core[004245] = 01044; $code[004245] = *I04245; sub I04245 { $lac += $core[000044]; goto &fetch; }
$core[004246] = 03037; $code[004246] = *I04246; sub I04246 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[004247] = 01026; $code[004247] = *I04247; sub I04247 { $lac += $core[000026]; goto &fetch; }
$core[004250] = 03040; $code[004250] = *L04250; sub L04250 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[004251] = 04462; $code[004251] = *I04251; sub I04251 { $core[($ib<<12)+$core[50]] = 04252; $pc = ($ib<<12)+$core[50]+1; $code[($ib<<12)+$core[50]] = *emul8; $inh = 0; goto &fetch; }
$core[004252] = 04735; $code[004252] = *I04252; sub I04252 { $core[($ib<<12)+$core[2269]] = 04253; $pc = ($ib<<12)+$core[2269]+1; $code[($ib<<12)+$core[2269]] = *emul8; $inh = 0; goto &fetch; }
$core[004253] = 04467; $code[004253] = *I04253; sub I04253 { $core[($ib<<12)+$core[55]] = 04254; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[004254] = 05200; $code[004254] = *I04254; sub I04254 { $pc = 004200; $inh = 0; goto &fetch; }
$core[004255] = 07300; $code[004255] = *L04255; sub L04255 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004256] = 01044; $code[004256] = *I04256; sub I04256 { $lac += $core[000044]; goto &fetch; }
$core[004257] = 07440; $code[004257] = *I04257; sub I04257 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004260] = 07220; $code[004260] = *I04260; sub I04260 { $lac &= 010000; $lac ^= 010000; goto &fetch; }
$core[004261] = 01041; $code[004261] = *I04261; sub I04261 { $lac += $core[000041]; goto &fetch; }
$core[004262] = 07004; $code[004262] = *I04262; sub I04262 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004263] = 07004; $code[004263] = *I04263; sub I04263 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004264] = 07004; $code[004264] = *I04264; sub I04264 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004265] = 07004; $code[004265] = *I04265; sub I04265 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004266] = 07004; $code[004266] = *I04266; sub I04266 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004267] = 07004; $code[004267] = *I04267; sub I04267 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004270] = 07004; $code[004270] = *I04270; sub I04270 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004271] = 07004; $code[004271] = *I04271; sub I04271 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004272] = 07004; $code[004272] = *I04272; sub I04272 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004273] = 07004; $code[004273] = *I04273; sub I04273 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004274] = 07004; $code[004274] = *I04274; sub I04274 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004275] = 07004; $code[004275] = *I04275; sub I04275 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004276] = 07004; $code[004276] = *I04276; sub I04276 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004277] = 07004; $code[004277] = *I04277; sub I04277 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004300] = 07004; $code[004300] = *I04300; sub I04300 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004301] = 07004; $code[004301] = *I04301; sub I04301 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004302] = 07004; $code[004302] = *I04302; sub I04302 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004303] = 07004; $code[004303] = *I04303; sub I04303 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004304] = 07004; $code[004304] = *I04304; sub I04304 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004305] = 07004; $code[004305] = *I04305; sub I04305 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004306] = 07004; $code[004306] = *I04306; sub I04306 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004307] = 07004; $code[004307] = *I04307; sub I04307 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004310] = 07004; $code[004310] = *I04310; sub I04310 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004311] = 07004; $code[004311] = *I04311; sub I04311 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004312] = 07004; $code[004312] = *I04312; sub I04312 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004313] = 07004; $code[004313] = *I04313; sub I04313 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004314] = 07000; $code[004314] = *I04314; sub I04314 { goto &fetch; }
$core[004315] = 07000; $code[004315] = *I04315; sub I04315 { goto &fetch; }
$core[004316] = 04464; $code[004316] = *I04316; sub I04316 { $core[($ib<<12)+$core[52]] = 04317; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[004317] = 01043; $code[004317] = *I04317; sub I04317 { $lac += $core[000043]; goto &fetch; }
$core[004320] = 07440; $code[004320] = *I04320; sub I04320 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004321] = 05325; $code[004321] = *I04321; sub I04321 { $pc = 004325; $inh = 0; goto &fetch; }
$core[004322] = 01044; $code[004322] = *I04322; sub I04322 { $lac += $core[000044]; goto &fetch; }
$core[004323] = 03037; $code[004323] = *I04323; sub I04323 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[004324] = 01026; $code[004324] = *I04324; sub I04324 { $lac += $core[000026]; goto &fetch; }
$core[004325] = 03040; $code[004325] = *L04325; sub L04325 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[004326] = 04462; $code[004326] = *I04326; sub I04326 { $core[($ib<<12)+$core[50]] = 04327; $pc = ($ib<<12)+$core[50]+1; $code[($ib<<12)+$core[50]] = *emul8; $inh = 0; goto &fetch; }
$core[004327] = 04734; $code[004327] = *I04327; sub I04327 { $core[($ib<<12)+$core[2268]] = 04330; $pc = ($ib<<12)+$core[2268]+1; $code[($ib<<12)+$core[2268]] = *emul8; $inh = 0; goto &fetch; }
$core[004330] = 04467; $code[004330] = *I04330; sub I04330 { $core[($ib<<12)+$core[55]] = 04331; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[004331] = 05255; $code[004331] = *I04331; sub I04331 { $pc = 004255; $inh = 0; goto &fetch; }
$core[004332] = 05733; $code[004332] = *I04332; sub I04332 { $pc = ($ib<<12)+$core[2267]; $inh = 0; goto &fetch; }
$core[004333] = 04400; $code[004333] = *P04333; sub P04333 { $core[($ib<<12)+$core[0]] = 04334; $pc = ($ib<<12)+$core[0]+1; $code[($ib<<12)+$core[0]] = *emul8; $inh = 0; goto &fetch; }
$core[004334] = 05013; $code[004334] = *P04334; sub P04334 { $pc = 000013; $inh = 0; goto &fetch; }
$core[004335] = 05000; $code[004335] = *P04335; sub P04335 { $pc = 000000; $inh = 0; goto &fetch; }
$core[004400] = 07300; $code[004400] = *P04400; sub P04400 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004401] = 01044; $code[004401] = *I04401; sub I04401 { $lac += $core[000044]; goto &fetch; }
$core[004402] = 07440; $code[004402] = *I04402; sub I04402 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004403] = 07220; $code[004403] = *I04403; sub I04403 { $lac &= 010000; $lac ^= 010000; goto &fetch; }
$core[004404] = 01041; $code[004404] = *I04404; sub I04404 { $lac += $core[000041]; goto &fetch; }
$core[004405] = 07006; $code[004405] = *I04405; sub I04405 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004406] = 07006; $code[004406] = *I04406; sub I04406 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004407] = 07006; $code[004407] = *I04407; sub I04407 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004410] = 07006; $code[004410] = *I04410; sub I04410 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004411] = 07006; $code[004411] = *I04411; sub I04411 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004412] = 07006; $code[004412] = *I04412; sub I04412 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004413] = 07006; $code[004413] = *I04413; sub I04413 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004414] = 07006; $code[004414] = *I04414; sub I04414 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004415] = 07006; $code[004415] = *I04415; sub I04415 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004416] = 07006; $code[004416] = *I04416; sub I04416 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004417] = 07006; $code[004417] = *I04417; sub I04417 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004420] = 07006; $code[004420] = *I04420; sub I04420 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004421] = 07006; $code[004421] = *I04421; sub I04421 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004422] = 07006; $code[004422] = *I04422; sub I04422 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004423] = 07006; $code[004423] = *I04423; sub I04423 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004424] = 07006; $code[004424] = *I04424; sub I04424 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004425] = 07006; $code[004425] = *I04425; sub I04425 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004426] = 07006; $code[004426] = *I04426; sub I04426 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004427] = 07006; $code[004427] = *I04427; sub I04427 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004430] = 07006; $code[004430] = *I04430; sub I04430 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004431] = 07006; $code[004431] = *I04431; sub I04431 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004432] = 07006; $code[004432] = *I04432; sub I04432 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004433] = 07006; $code[004433] = *I04433; sub I04433 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004434] = 07006; $code[004434] = *I04434; sub I04434 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004435] = 07006; $code[004435] = *I04435; sub I04435 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004436] = 07006; $code[004436] = *I04436; sub I04436 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004437] = 07000; $code[004437] = *I04437; sub I04437 { goto &fetch; }
$core[004440] = 07000; $code[004440] = *I04440; sub I04440 { goto &fetch; }
$core[004441] = 04464; $code[004441] = *I04441; sub I04441 { $core[($ib<<12)+$core[52]] = 04442; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[004442] = 01043; $code[004442] = *I04442; sub I04442 { $lac += $core[000043]; goto &fetch; }
$core[004443] = 07440; $code[004443] = *I04443; sub I04443 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004444] = 05250; $code[004444] = *I04444; sub I04444 { $pc = 004450; $inh = 0; goto &fetch; }
$core[004445] = 01044; $code[004445] = *I04445; sub I04445 { $lac += $core[000044]; goto &fetch; }
$core[004446] = 03037; $code[004446] = *L04446; sub L04446 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[004447] = 01026; $code[004447] = *I04447; sub I04447 { $lac += $core[000026]; goto &fetch; }
$core[004450] = 03040; $code[004450] = *L04450; sub L04450 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[004451] = 04462; $code[004451] = *I04451; sub I04451 { $core[($ib<<12)+$core[50]] = 04452; $pc = ($ib<<12)+$core[50]+1; $code[($ib<<12)+$core[50]] = *emul8; $inh = 0; goto &fetch; }
$core[004452] = 04771; $code[004452] = *I04452; sub I04452 { $core[($ib<<12)+$core[2425]] = 04453; $pc = ($ib<<12)+$core[2425]+1; $code[($ib<<12)+$core[2425]] = *emul8; $inh = 0; goto &fetch; }
$core[004453] = 04467; $code[004453] = *I04453; sub I04453 { $core[($ib<<12)+$core[55]] = 04454; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[004454] = 05200; $code[004454] = *I04454; sub I04454 { $pc = 004400; $inh = 0; goto &fetch; }
$core[004455] = 07300; $code[004455] = *L04455; sub L04455 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004456] = 01044; $code[004456] = *I04456; sub I04456 { $lac += $core[000044]; goto &fetch; }
$core[004457] = 07440; $code[004457] = *I04457; sub I04457 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004460] = 07220; $code[004460] = *L04460; sub L04460 { $lac &= 010000; $lac ^= 010000; goto &fetch; }
$core[004461] = 01041; $code[004461] = *I04461; sub I04461 { $lac += $core[000041]; goto &fetch; }
$core[004462] = 07012; $code[004462] = *I04462; sub I04462 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004463] = 07012; $code[004463] = *I04463; sub I04463 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004464] = 07012; $code[004464] = *I04464; sub I04464 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004465] = 07012; $code[004465] = *I04465; sub I04465 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004466] = 07012; $code[004466] = *I04466; sub I04466 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004467] = 07012; $code[004467] = *I04467; sub I04467 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004470] = 07012; $code[004470] = *I04470; sub I04470 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004471] = 07012; $code[004471] = *I04471; sub I04471 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004472] = 07012; $code[004472] = *I04472; sub I04472 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004473] = 07012; $code[004473] = *I04473; sub I04473 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004474] = 07012; $code[004474] = *I04474; sub I04474 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004475] = 07012; $code[004475] = *I04475; sub I04475 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004476] = 07012; $code[004476] = *I04476; sub I04476 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004477] = 07012; $code[004477] = *I04477; sub I04477 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004500] = 07012; $code[004500] = *I04500; sub I04500 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004501] = 07012; $code[004501] = *I04501; sub I04501 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004502] = 07012; $code[004502] = *I04502; sub I04502 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004503] = 07012; $code[004503] = *I04503; sub I04503 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004504] = 07012; $code[004504] = *I04504; sub I04504 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004505] = 07012; $code[004505] = *I04505; sub I04505 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004506] = 07012; $code[004506] = *I04506; sub I04506 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004507] = 07012; $code[004507] = *I04507; sub I04507 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004510] = 07012; $code[004510] = *I04510; sub I04510 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004511] = 07012; $code[004511] = *I04511; sub I04511 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004512] = 07012; $code[004512] = *I04512; sub I04512 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004513] = 07012; $code[004513] = *I04513; sub I04513 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004514] = 07000; $code[004514] = *I04514; sub I04514 { goto &fetch; }
$core[004515] = 07000; $code[004515] = *I04515; sub I04515 { goto &fetch; }
$core[004516] = 04464; $code[004516] = *I04516; sub I04516 { $core[($ib<<12)+$core[52]] = 04517; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[004517] = 01043; $code[004517] = *I04517; sub I04517 { $lac += $core[000043]; goto &fetch; }
$core[004520] = 07440; $code[004520] = *I04520; sub I04520 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004521] = 05325; $code[004521] = *I04521; sub I04521 { $pc = 004525; $inh = 0; goto &fetch; }
$core[004522] = 01044; $code[004522] = *I04522; sub I04522 { $lac += $core[000044]; goto &fetch; }
$core[004523] = 03037; $code[004523] = *I04523; sub I04523 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[004524] = 01026; $code[004524] = *I04524; sub I04524 { $lac += $core[000026]; goto &fetch; }
$core[004525] = 03040; $code[004525] = *L04525; sub L04525 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[004526] = 04462; $code[004526] = *I04526; sub I04526 { $core[($ib<<12)+$core[50]] = 04527; $pc = ($ib<<12)+$core[50]+1; $code[($ib<<12)+$core[50]] = *emul8; $inh = 0; goto &fetch; }
$core[004527] = 04770; $code[004527] = *I04527; sub I04527 { $core[($ib<<12)+$core[2424]] = 04530; $pc = ($ib<<12)+$core[2424]+1; $code[($ib<<12)+$core[2424]] = *emul8; $inh = 0; goto &fetch; }
$core[004530] = 04467; $code[004530] = *I04530; sub I04530 { $core[($ib<<12)+$core[55]] = 04531; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[004531] = 05255; $code[004531] = *I04531; sub I04531 { $pc = 004455; $inh = 0; goto &fetch; }
$core[004532] = 02020; $code[004532] = *I04532; sub I04532 { if (++$core[000020] == 010000) { $core[000020] = 0; $pc++; }$code[000020] = *emul8; goto &fetch; }
$core[004533] = 05366; $code[004533] = *I04533; sub I04533 { $pc = 004566; $inh = 0; goto &fetch; }
$core[004534] = 07604; $code[004534] = *I04534; sub I04534 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004535] = 00115; $code[004535] = *P04535; sub P04535 { $lac &= (010000|$core[000115]); goto &fetch; }
$core[004536] = 07650; $code[004536] = *I04536; sub I04536 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004537] = 05363; $code[004537] = *I04537; sub I04537 { $pc = 004563; $inh = 0; goto &fetch; }
$core[004540] = 07604; $code[004540] = *L04540; sub L04540 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004541] = 00114; $code[004541] = *I04541; sub I04541 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[004542] = 07640; $code[004542] = *I04542; sub I04542 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004543] = 07402; $code[004543] = *I04543; sub I04543 { $hlt = 1; goto &fetch; }
$core[004544] = 07604; $code[004544] = *I04544; sub I04544 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004545] = 00116; $code[004545] = *I04545; sub I04545 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[004546] = 07640; $code[004546] = *I04546; sub I04546 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004547] = 05366; $code[004547] = *I04547; sub I04547 { $pc = 004566; $inh = 0; goto &fetch; }
$core[004550] = 07604; $code[004550] = *L04550; sub L04550 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004551] = 00173; $code[004551] = *I04551; sub I04551 { $lac &= (010000|$core[000173]); goto &fetch; }
$core[004552] = 07110; $code[004552] = *I04552; sub I04552 { $lac &= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004553] = 07012; $code[004553] = *I04553; sub I04553 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004554] = 03175; $code[004554] = *I04554; sub I04554 { $core[000175] = $lac & 07777; $lac &= 010000; $code[000175] = *emul8; goto &fetch; }
$core[004555] = 07604; $code[004555] = *I04555; sub I04555 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004556] = 00107; $code[004556] = *I04556; sub I04556 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[004557] = 07640; $code[004557] = *I04557; sub I04557 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004560] = 05772; $code[004560] = *I04560; sub I04560 { $pc = ($ib<<12)+$core[2426]; $inh = 0; goto &fetch; }
$core[004561] = 05762; $code[004561] = *I04561; sub I04561 { $pc = ($ib<<12)+$core[2418]; $inh = 0; goto &fetch; }
$core[004562] = 00200; $code[004562] = *P04562; sub P04562 { $lac &= (010000|$core[004400]); goto &fetch; }
$core[004563] = 04446; $code[004563] = *L04563; sub L04563 { $core[($ib<<12)+$core[38]] = 04564; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[004564] = 05735; $code[004564] = *I04564; sub I04564 { $pc = ($ib<<12)+$core[2397]; $inh = 0; goto &fetch; }
$core[004565] = 05340; $code[004565] = *I04565; sub I04565 { $pc = 004540; $inh = 0; goto &fetch; }
$core[004566] = 05767; $code[004566] = *L04566; sub L04566 { $pc = ($ib<<12)+$core[2423]; $inh = 0; goto &fetch; }
$core[004567] = 03400; $code[004567] = *P04567; sub P04567 { $core[($df<<12)+$core[0]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[004570] = 05026; $code[004570] = *P04570; sub P04570 { $pc = 000026; $inh = 0; goto &fetch; }
$core[004571] = 05041; $code[004571] = *P04571; sub P04571 { $pc = 000041; $inh = 0; goto &fetch; }
$core[004572] = 04600; $code[004572] = *P04572; sub P04572 { $core[($ib<<12)+$core[2304]] = 04573; $pc = ($ib<<12)+$core[2304]+1; $code[($ib<<12)+$core[2304]] = *emul8; $inh = 0; goto &fetch; }
$core[004600] = 04231; $code[004600] = *L04600; sub L04600 { $core[004631] = 04601; $pc = 004631+1; $code[004631] = *emul8; $inh = 0; goto &fetch; }
$core[004601] = 04264; $code[004601] = *I04601; sub I04601 { $core[004664] = 04602; $pc = 004664+1; $code[004664] = *emul8; $inh = 0; goto &fetch; }
$core[004602] = 07346; $code[004602] = *I04602; sub I04602 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004603] = 04341; $code[004603] = *I04603; sub I04603 { $core[004741] = 04604; $pc = 004741+1; $code[004741] = *emul8; $inh = 0; goto &fetch; }
$core[004604] = 04331; $code[004604] = *I04604; sub I04604 { $core[004731] = 04605; $pc = 004731+1; $code[004731] = *emul8; $inh = 0; goto &fetch; }
$core[004605] = 04352; $code[004605] = *I04605; sub I04605 { $core[004752] = 04606; $pc = 004752+1; $code[004752] = *emul8; $inh = 0; goto &fetch; }
$core[004606] = 04446; $code[004606] = *I04606; sub I04606 { $core[($ib<<12)+$core[38]] = 04607; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[004607] = 05755; $code[004607] = *I04607; sub I04607 { $pc = ($ib<<12)+$core[2541]; $inh = 0; goto &fetch; }
$core[004610] = 04360; $code[004610] = *I04610; sub I04610 { $core[004760] = 04611; $pc = 004760+1; $code[004760] = *emul8; $inh = 0; goto &fetch; }
$core[004611] = 04331; $code[004611] = *I04611; sub I04611 { $core[004731] = 04612; $pc = 004731+1; $code[004731] = *emul8; $inh = 0; goto &fetch; }
$core[004612] = 07344; $code[004612] = *D04612; sub D04612 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004613] = 04341; $code[004613] = *I04613; sub I04613 { $core[004741] = 04614; $pc = 004741+1; $code[004741] = *emul8; $inh = 0; goto &fetch; }
$core[004614] = 01175; $code[004614] = *I04614; sub I04614 { $lac += $core[000175]; goto &fetch; }
$core[004615] = 07041; $code[004615] = *D04615; sub D04615 { $lac ^= 07777; $lac++; goto &fetch; }
$core[004616] = 01174; $code[004616] = *I04616; sub I04616 { $lac += $core[000174]; goto &fetch; }
$core[004617] = 07650; $code[004617] = *I04617; sub I04617 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004620] = 05223; $code[004620] = *I04620; sub I04620 { $pc = 004623; $inh = 0; goto &fetch; }
$core[004621] = 07602; $code[004621] = *I04621; sub I04621 { $lac &= 010000; $hlt = 1; goto &fetch; }
$core[004622] = 05770; $code[004622] = *I04622; sub I04622 { $pc = ($ib<<12)+$core[2552]; $inh = 0; goto &fetch; }
$core[004623] = 01314; $code[004623] = *L04623; sub L04623 { $lac += $core[004714]; goto &fetch; }
$core[004624] = 01115; $code[004624] = *I04624; sub I04624 { $lac += $core[000115]; goto &fetch; }
$core[004625] = 03226; $code[004625] = *I04625; sub I04625 { $core[004626] = $lac & 07777; $lac &= 010000; $code[004626] = *emul8; goto &fetch; }
$core[004626] = 00000; $code[004626] = *D04626; sub D04626 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004627] = 05630; $code[004627] = *I04627; sub I04627 { $pc = ($ib<<12)+$core[2456]; $inh = 0; goto &fetch; }
$core[004630] = 00200; $code[004630] = *P04630; sub P04630 { $lac &= (010000|$core[004600]); goto &fetch; }
$core[004631] = 00000; $code[004631] = *S04631; sub S04631 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004632] = 07300; $code[004632] = *I04632; sub I04632 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004633] = 03174; $code[004633] = *I04633; sub I04633 { $core[000174] = $lac & 07777; $lac &= 010000; $code[000174] = *emul8; goto &fetch; }
$core[004634] = 01371; $code[004634] = *I04634; sub I04634 { $lac += $core[004771]; goto &fetch; }
$core[004635] = 03176; $code[004635] = *I04635; sub I04635 { $core[000176] = $lac & 07777; $lac &= 010000; $code[000176] = *emul8; goto &fetch; }
$core[004636] = 06201; $code[004636] = *I04636; sub I04636 { &emul8; goto &fetch; }
$core[004637] = 03571; $code[004637] = *I04637; sub I04637 { $core[($df<<12)+$core[121]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[121]] = *emul8; goto &fetch; }
$core[004640] = 01372; $code[004640] = *I04640; sub I04640 { $lac += $core[004772]; goto &fetch; }
$core[004641] = 01113; $code[004641] = *L04641; sub L04641 { $lac += $core[000113]; goto &fetch; }
$core[004642] = 03243; $code[004642] = *I04642; sub I04642 { $core[004643] = $lac & 07777; $lac &= 010000; $code[004643] = *emul8; goto &fetch; }
$core[004643] = 00000; $code[004643] = *D04643; sub D04643 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004644] = 07340; $code[004644] = *I04644; sub I04644 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[004645] = 03571; $code[004645] = *I04645; sub I04645 { $core[($df<<12)+$core[121]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[121]] = *emul8; goto &fetch; }
$core[004646] = 01571; $code[004646] = *I04646; sub I04646 { $lac += $core[($df<<12)+$core[121]]; goto &fetch; }
$core[004647] = 07650; $code[004647] = *I04647; sub I04647 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004650] = 05255; $code[004650] = *I04650; sub I04650 { $pc = 004655; $inh = 0; goto &fetch; }
$core[004651] = 02174; $code[004651] = *I04651; sub I04651 { if (++$core[000174] == 010000) { $core[000174] = 0; $pc++; }$code[000174] = *emul8; goto &fetch; }
$core[004652] = 01243; $code[004652] = *D04652; sub D04652 { $lac += $core[004643]; goto &fetch; }
$core[004653] = 02176; $code[004653] = *I04653; sub I04653 { if (++$core[000176] == 010000) { $core[000176] = 0; $pc++; }$code[000176] = *emul8; goto &fetch; }
$core[004654] = 05241; $code[004654] = *I04654; sub I04654 { $pc = 004641; $inh = 0; goto &fetch; }
$core[004655] = 07300; $code[004655] = *L04655; sub L04655 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004656] = 06201; $code[004656] = *I04656; sub I04656 { &emul8; goto &fetch; }
$core[004657] = 01571; $code[004657] = *I04657; sub I04657 { $lac += $core[($df<<12)+$core[121]]; goto &fetch; }
$core[004660] = 07650; $code[004660] = *I04660; sub I04660 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004661] = 05631; $code[004661] = *I04661; sub I04661 { $pc = ($ib<<12)+$core[2457]; $inh = 0; goto &fetch; }
$core[004662] = 07602; $code[004662] = *I04662; sub I04662 { $lac &= 010000; $hlt = 1; goto &fetch; }
$core[004663] = 05274; $code[004663] = *I04663; sub I04663 { $pc = 004674; $inh = 0; goto &fetch; }
$core[004664] = 00000; $code[004664] = *S04664; sub S04664 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004665] = 07300; $code[004665] = *I04665; sub I04665 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004666] = 03176; $code[004666] = *I04666; sub I04666 { $core[000176] = $lac & 07777; $lac &= 010000; $code[000176] = *emul8; goto &fetch; }
$core[004667] = 06224; $code[004667] = *I04667; sub I04667 { &emul8; goto &fetch; }
$core[004670] = 01113; $code[004670] = *I04670; sub I04670 { $lac += $core[000113]; goto &fetch; }
$core[004671] = 00375; $code[004671] = *I04671; sub I04671 { $lac &= (010000|$core[004775]); goto &fetch; }
$core[004672] = 03312; $code[004672] = *I04672; sub I04672 { $core[004712] = $lac & 07777; $lac &= 010000; $code[004712] = *emul8; goto &fetch; }
$core[004673] = 07301; $code[004673] = *I04673; sub I04673 { $lac &= 010000; $lac &= 07777; $lac++; goto &fetch; }
$core[004674] = 01174; $code[004674] = *L04674; sub L04674 { $lac += $core[000174]; goto &fetch; }
$core[004675] = 07004; $code[004675] = *I04675; sub I04675 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004676] = 07006; $code[004676] = *I04676; sub I04676 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004677] = 07041; $code[004677] = *I04677; sub I04677 { $lac ^= 07777; $lac++; goto &fetch; }
$core[004700] = 01312; $code[004700] = *I04700; sub I04700 { $lac += $core[004712]; goto &fetch; }
$core[004701] = 07620; $code[004701] = *I04701; sub I04701 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004702] = 01312; $code[004702] = *I04702; sub I04702 { $lac += $core[004712]; goto &fetch; }
$core[004703] = 01372; $code[004703] = *I04703; sub I04703 { $lac += $core[004772]; goto &fetch; }
$core[004704] = 03314; $code[004704] = *I04704; sub I04704 { $core[004714] = $lac & 07777; $lac &= 010000; $code[004714] = *emul8; goto &fetch; }
$core[004705] = 06224; $code[004705] = *I04705; sub I04705 { &emul8; goto &fetch; }
$core[004706] = 01372; $code[004706] = *I04706; sub I04706 { $lac += $core[004772]; goto &fetch; }
$core[004707] = 03312; $code[004707] = *I04707; sub I04707 { $core[004712] = $lac & 07777; $lac &= 010000; $code[004712] = *emul8; goto &fetch; }
$core[004710] = 01312; $code[004710] = *I04710; sub I04710 { $lac += $core[004712]; goto &fetch; }
$core[004711] = 03317; $code[004711] = *I04711; sub I04711 { $core[004717] = $lac & 07777; $lac &= 010000; $code[004717] = *emul8; goto &fetch; }
$core[004712] = 00000; $code[004712] = *L04712; sub L04712 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004713] = 01576; $code[004713] = *I04713; sub I04713 { $lac += $core[($df<<12)+$core[126]]; goto &fetch; }
$core[004714] = 00000; $code[004714] = *D04714; sub D04714 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004715] = 03576; $code[004715] = *I04715; sub I04715 { $core[($df<<12)+$core[126]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[126]] = *emul8; goto &fetch; }
$core[004716] = 01576; $code[004716] = *I04716; sub I04716 { $lac += $core[($df<<12)+$core[126]]; goto &fetch; }
$core[004717] = 00000; $code[004717] = *D04717; sub D04717 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004720] = 07041; $code[004720] = *I04720; sub I04720 { $lac ^= 07777; $lac++; goto &fetch; }
$core[004721] = 01576; $code[004721] = *I04721; sub I04721 { $lac += $core[($df<<12)+$core[126]]; goto &fetch; }
$core[004722] = 07650; $code[004722] = *I04722; sub I04722 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004723] = 05326; $code[004723] = *I04723; sub I04723 { $pc = 004726; $inh = 0; goto &fetch; }
$core[004724] = 07602; $code[004724] = *I04724; sub I04724 { $lac &= 010000; $hlt = 1; goto &fetch; }
$core[004725] = 05312; $code[004725] = *I04725; sub I04725 { $pc = 004712; $inh = 0; goto &fetch; }
$core[004726] = 02176; $code[004726] = *L04726; sub L04726 { if (++$core[000176] == 010000) { $core[000176] = 0; $pc++; }$code[000176] = *emul8; goto &fetch; }
$core[004727] = 05312; $code[004727] = *I04727; sub I04727 { $pc = 004712; $inh = 0; goto &fetch; }
$core[004730] = 05664; $code[004730] = *I04730; sub I04730 { $pc = ($ib<<12)+$core[2484]; $inh = 0; goto &fetch; }
$core[004731] = 00000; $code[004731] = *S04731; sub S04731 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004732] = 01371; $code[004732] = *I04732; sub I04732 { $lac += $core[004771]; goto &fetch; }
$core[004733] = 03176; $code[004733] = *I04733; sub I04733 { $core[000176] = $lac & 07777; $lac &= 010000; $code[000176] = *emul8; goto &fetch; }
$core[004734] = 01376; $code[004734] = *L04734; sub L04734 { $lac += $core[004776]; goto &fetch; }
$core[004735] = 04447; $code[004735] = *I04735; sub I04735 { $core[($ib<<12)+$core[39]] = 04736; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[004736] = 02176; $code[004736] = *I04736; sub I04736 { if (++$core[000176] == 010000) { $core[000176] = 0; $pc++; }$code[000176] = *emul8; goto &fetch; }
$core[004737] = 05334; $code[004737] = *I04737; sub I04737 { $pc = 004734; $inh = 0; goto &fetch; }
$core[004740] = 05731; $code[004740] = *I04740; sub I04740 { $pc = ($ib<<12)+$core[2521]; $inh = 0; goto &fetch; }
$core[004741] = 00000; $code[004741] = *S04741; sub S04741 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004742] = 03176; $code[004742] = *I04742; sub I04742 { $core[000176] = $lac & 07777; $lac &= 010000; $code[000176] = *emul8; goto &fetch; }
$core[004743] = 01374; $code[004743] = *L04743; sub L04743 { $lac += $core[004774]; goto &fetch; }
$core[004744] = 04447; $code[004744] = *I04744; sub I04744 { $core[($ib<<12)+$core[39]] = 04745; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[004745] = 01373; $code[004745] = *I04745; sub I04745 { $lac += $core[004773]; goto &fetch; }
$core[004746] = 04447; $code[004746] = *I04746; sub I04746 { $core[($ib<<12)+$core[39]] = 04747; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[004747] = 02176; $code[004747] = *I04747; sub I04747 { if (++$core[000176] == 010000) { $core[000176] = 0; $pc++; }$code[000176] = *emul8; goto &fetch; }
$core[004750] = 05343; $code[004750] = *I04750; sub I04750 { $pc = 004743; $inh = 0; goto &fetch; }
$core[004751] = 05741; $code[004751] = *I04751; sub I04751 { $pc = ($ib<<12)+$core[2529]; $inh = 0; goto &fetch; }
$core[004752] = 00000; $code[004752] = *S04752; sub S04752 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004753] = 01174; $code[004753] = *I04753; sub I04753 { $lac += $core[000174]; goto &fetch; }
$core[004754] = 00172; $code[004754] = *I04754; sub I04754 { $lac &= (010000|$core[000172]); goto &fetch; }
$core[004755] = 01077; $code[004755] = *P04755; sub P04755 { $lac += $core[000077]; goto &fetch; }
$core[004756] = 04447; $code[004756] = *I04756; sub I04756 { $core[($ib<<12)+$core[39]] = 04757; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[004757] = 05752; $code[004757] = *I04757; sub I04757 { $pc = ($ib<<12)+$core[2538]; $inh = 0; goto &fetch; }
$core[004760] = 00000; $code[004760] = *S04760; sub S04760 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004761] = 01314; $code[004761] = *I04761; sub I04761 { $lac += $core[004714]; goto &fetch; }
$core[004762] = 00173; $code[004762] = *I04762; sub I04762 { $lac &= (010000|$core[000173]); goto &fetch; }
$core[004763] = 07010; $code[004763] = *I04763; sub I04763 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004764] = 07012; $code[004764] = *I04764; sub I04764 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004765] = 01077; $code[004765] = *I04765; sub I04765 { $lac += $core[000077]; goto &fetch; }
$core[004766] = 04447; $code[004766] = *I04766; sub I04766 { $core[($ib<<12)+$core[39]] = 04767; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[004767] = 05760; $code[004767] = *I04767; sub I04767 { $pc = ($ib<<12)+$core[2544]; $inh = 0; goto &fetch; }
$core[004770] = 04550; $code[004770] = *P04770; sub P04770 { $core[($ib<<12)+$core[104]] = 04771; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[004771] = 07771; $code[004771] = *D04771; sub D04771 { &emul8; goto &fetch; }
$core[004772] = 06201; $code[004772] = *D04772; sub D04772 { &emul8; goto &fetch; }
$core[004773] = 00212; $code[004773] = *D04773; sub D04773 { $lac &= (010000|$core[004612]); goto &fetch; }
$core[004774] = 00215; $code[004774] = *D04774; sub D04774 { $lac &= (010000|$core[004615]); goto &fetch; }
$core[004775] = 00170; $code[004775] = *D04775; sub D04775 { $lac &= (010000|$core[000170]); goto &fetch; }
$core[004776] = 00252; $code[004776] = *D04776; sub D04776 { $lac &= (010000|$core[004652]); goto &fetch; }
$core[005000] = 00000; $code[005000] = *D05000; sub D05000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005001] = 07604; $code[005001] = *L05001; sub L05001 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005002] = 00104; $code[005002] = *I05002; sub I05002 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[005003] = 07640; $code[005003] = *I05003; sub I05003 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005004] = 05210; $code[005004] = *I05004; sub I05004 { $pc = 005010; $inh = 0; goto &fetch; }
$core[005005] = 04446; $code[005005] = *I05005; sub I05005 { $core[($ib<<12)+$core[38]] = 05006; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[005006] = 05625; $code[005006] = *I05006; sub I05006 { $pc = ($ib<<12)+$core[2581]; $inh = 0; goto &fetch; }
$core[005007] = 04264; $code[005007] = *I05007; sub I05007 { $core[005064] = 05010; $pc = 005064+1; $code[005064] = *emul8; $inh = 0; goto &fetch; }
$core[005010] = 07300; $code[005010] = *L05010; sub L05010 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005011] = 01200; $code[005011] = *I05011; sub I05011 { $lac += $core[005000]; goto &fetch; }
$core[005012] = 05253; $code[005012] = *I05012; sub I05012 { $pc = 005053; $inh = 0; goto &fetch; }
$core[005013] = 00000; $code[005013] = *D05013; sub D05013 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005014] = 07604; $code[005014] = *I05014; sub I05014 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005015] = 00104; $code[005015] = *I05015; sub I05015 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[005016] = 07640; $code[005016] = *I05016; sub I05016 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005017] = 05223; $code[005017] = *I05017; sub I05017 { $pc = 005023; $inh = 0; goto &fetch; }
$core[005020] = 04446; $code[005020] = *I05020; sub I05020 { $core[($ib<<12)+$core[38]] = 05021; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[005021] = 05644; $code[005021] = *I05021; sub I05021 { $pc = ($ib<<12)+$core[2596]; $inh = 0; goto &fetch; }
$core[005022] = 04264; $code[005022] = *I05022; sub I05022 { $core[005064] = 05023; $pc = 005064+1; $code[005064] = *emul8; $inh = 0; goto &fetch; }
$core[005023] = 07300; $code[005023] = *L05023; sub L05023 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005024] = 01213; $code[005024] = *I05024; sub I05024 { $lac += $core[005013]; goto &fetch; }
$core[005025] = 05253; $code[005025] = *P05025; sub P05025 { $pc = 005053; $inh = 0; goto &fetch; }
$core[005026] = 00000; $code[005026] = *D05026; sub D05026 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005027] = 07604; $code[005027] = *I05027; sub I05027 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005030] = 00104; $code[005030] = *I05030; sub I05030 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[005031] = 07640; $code[005031] = *I05031; sub I05031 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005032] = 05236; $code[005032] = *I05032; sub I05032 { $pc = 005036; $inh = 0; goto &fetch; }
$core[005033] = 04446; $code[005033] = *I05033; sub I05033 { $core[($ib<<12)+$core[38]] = 05034; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[005034] = 05663; $code[005034] = *I05034; sub I05034 { $pc = ($ib<<12)+$core[2611]; $inh = 0; goto &fetch; }
$core[005035] = 04264; $code[005035] = *I05035; sub I05035 { $core[005064] = 05036; $pc = 005064+1; $code[005064] = *emul8; $inh = 0; goto &fetch; }
$core[005036] = 07300; $code[005036] = *L05036; sub L05036 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005037] = 01226; $code[005037] = *I05037; sub I05037 { $lac += $core[005026]; goto &fetch; }
$core[005040] = 05253; $code[005040] = *I05040; sub I05040 { $pc = 005053; $inh = 0; goto &fetch; }
$core[005041] = 00000; $code[005041] = *D05041; sub D05041 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005042] = 07604; $code[005042] = *I05042; sub I05042 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005043] = 00104; $code[005043] = *I05043; sub I05043 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[005044] = 07640; $code[005044] = *P05044; sub P05044 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005045] = 05251; $code[005045] = *I05045; sub I05045 { $pc = 005051; $inh = 0; goto &fetch; }
$core[005046] = 04446; $code[005046] = *I05046; sub I05046 { $core[($ib<<12)+$core[38]] = 05047; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[005047] = 05702; $code[005047] = *I05047; sub I05047 { $pc = ($ib<<12)+$core[2626]; $inh = 0; goto &fetch; }
$core[005050] = 04264; $code[005050] = *I05050; sub I05050 { $core[005064] = 05051; $pc = 005064+1; $code[005064] = *emul8; $inh = 0; goto &fetch; }
$core[005051] = 07300; $code[005051] = *L05051; sub L05051 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005052] = 01241; $code[005052] = *I05052; sub I05052 { $lac += $core[005041]; goto &fetch; }
$core[005053] = 03263; $code[005053] = *L05053; sub L05053 { $core[005063] = $lac & 07777; $lac &= 010000; $code[005063] = *emul8; goto &fetch; }
$core[005054] = 07604; $code[005054] = *I05054; sub I05054 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005055] = 00103; $code[005055] = *I05055; sub I05055 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[005056] = 07640; $code[005056] = *I05056; sub I05056 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005057] = 05262; $code[005057] = *I05057; sub I05057 { $pc = 005062; $inh = 0; goto &fetch; }
$core[005060] = 01263; $code[005060] = *I05060; sub I05060 { $lac += $core[005063]; goto &fetch; }
$core[005061] = 07402; $code[005061] = *I05061; sub I05061 { $hlt = 1; goto &fetch; }
$core[005062] = 05663; $code[005062] = *L05062; sub L05062 { $pc = ($ib<<12)+$core[2611]; $inh = 0; goto &fetch; }
$core[005063] = 00000; $code[005063] = *P05063; sub P05063 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005064] = 00000; $code[005064] = *S05064; sub S05064 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005065] = 04446; $code[005065] = *I05065; sub I05065 { $core[($ib<<12)+$core[38]] = 05066; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[005066] = 05347; $code[005066] = *I05066; sub I05066 { $pc = 005147; $inh = 0; goto &fetch; }
$core[005067] = 07340; $code[005067] = *I05067; sub I05067 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[005070] = 00044; $code[005070] = *I05070; sub I05070 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[005071] = 03040; $code[005071] = *I05071; sub I05071 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[005072] = 07040; $code[005072] = *I05072; sub I05072 { $lac ^= 07777; goto &fetch; }
$core[005073] = 00041; $code[005073] = *I05073; sub I05073 { $lac &= (010000|$core[000041]); goto &fetch; }
$core[005074] = 03037; $code[005074] = *I05074; sub I05074 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[005075] = 04460; $code[005075] = *I05075; sub I05075 { $core[($ib<<12)+$core[48]] = 05076; $pc = ($ib<<12)+$core[48]+1; $code[($ib<<12)+$core[48]] = *emul8; $inh = 0; goto &fetch; }
$core[005076] = 04461; $code[005076] = *I05076; sub I05076 { $core[($ib<<12)+$core[49]] = 05077; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[005077] = 07040; $code[005077] = *I05077; sub I05077 { $lac ^= 07777; goto &fetch; }
$core[005100] = 00026; $code[005100] = *I05100; sub I05100 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[005101] = 03040; $code[005101] = *I05101; sub I05101 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[005102] = 04460; $code[005102] = *P05102; sub P05102 { $core[($ib<<12)+$core[48]] = 05103; $pc = ($ib<<12)+$core[48]+1; $code[($ib<<12)+$core[48]] = *emul8; $inh = 0; goto &fetch; }
$core[005103] = 07040; $code[005103] = *I05103; sub I05103 { $lac ^= 07777; goto &fetch; }
$core[005104] = 00025; $code[005104] = *I05104; sub I05104 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[005105] = 03037; $code[005105] = *I05105; sub I05105 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[005106] = 04461; $code[005106] = *I05106; sub I05106 { $core[($ib<<12)+$core[49]] = 05107; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[005107] = 04446; $code[005107] = *I05107; sub I05107 { $core[($ib<<12)+$core[38]] = 05110; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[005110] = 05742; $code[005110] = *I05110; sub I05110 { $pc = ($ib<<12)+$core[2658]; $inh = 0; goto &fetch; }
$core[005111] = 05664; $code[005111] = *I05111; sub I05111 { $pc = ($ib<<12)+$core[2612]; $inh = 0; goto &fetch; }
$core[005200] = 03736; $code[005200] = *P05200; sub P05200 { $core[($df<<12)+$core[2782]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2782]] = *emul8; goto &fetch; }
$core[005201] = 04040; $code[005201] = *P05201; sub P05201 { $core[000040] = 05202; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005202] = 04001; $code[005202] = *I05202; sub I05202 { $core[000001] = 05203; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[005203] = 02207; $code[005203] = *I05203; sub I05203 { if (++$core[005207] == 010000) { $core[005207] = 0; $pc++; }$code[005207] = *emul8; goto &fetch; }
$core[005204] = 06140; $code[005204] = *P05204; sub P05204 { &emul8; goto &fetch; }
$core[005205] = 04040; $code[005205] = *D05205; sub D05205 { $core[000040] = 05206; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005206] = 04040; $code[005206] = *I05206; sub I05206 { $core[000040] = 05207; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005207] = 04040; $code[005207] = *D05207; sub D05207 { $core[000040] = 05210; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005210] = 04040; $code[005210] = *I05210; sub I05210 { $core[000040] = 05211; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005211] = 00122; $code[005211] = *D05211; sub D05211 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[005212] = 00762; $code[005212] = *I05212; sub I05212 { $lac &= (010000|$core[($df<<12)+$core[2802]]); goto &fetch; }
$core[005213] = 04040; $code[005213] = *I05213; sub I05213 { $core[000040] = 05214; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005214] = 04040; $code[005214] = *I05214; sub I05214 { $core[000040] = 05215; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005215] = 04040; $code[005215] = *I05215; sub I05215 { $core[000040] = 05216; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005216] = 04040; $code[005216] = *D05216; sub D05216 { $core[000040] = 05217; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005217] = 04023; $code[005217] = *I05217; sub I05217 { $core[000023] = 05220; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[005220] = 01115; $code[005220] = *I05220; sub I05220 { $lac += $core[000115]; goto &fetch; }
$core[005221] = 02514; $code[005221] = *I05221; sub I05221 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[005222] = 00124; $code[005222] = *I05222; sub I05222 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[005223] = 00504; $code[005223] = *I05223; sub I05223 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005224] = 04040; $code[005224] = *I05224; sub I05224 { $core[000040] = 05225; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005225] = 04040; $code[005225] = *I05225; sub I05225 { $core[000040] = 05226; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005226] = 04040; $code[005226] = *I05226; sub I05226 { $core[000040] = 05227; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005227] = 04001; $code[005227] = *I05227; sub I05227 { $core[000001] = 05230; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[005230] = 02207; $code[005230] = *I05230; sub I05230 { if (++$core[005207] == 010000) { $core[005207] = 0; $pc++; }$code[005207] = *emul8; goto &fetch; }
$core[005231] = 06153; $code[005231] = *I05231; sub I05231 { &emul8; goto &fetch; }
$core[005232] = 00122; $code[005232] = *I05232; sub I05232 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[005233] = 00762; $code[005233] = *I05233; sub I05233 { $lac &= (010000|$core[($df<<12)+$core[2802]]); goto &fetch; }
$core[005234] = 04040; $code[005234] = *I05234; sub I05234 { $core[000040] = 05235; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005235] = 04040; $code[005235] = *I05235; sub I05235 { $core[000040] = 05236; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005236] = 04001; $code[005236] = *I05236; sub I05236 { $core[000001] = 05237; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[005237] = 02207; $code[005237] = *I05237; sub I05237 { if (++$core[005207] == 010000) { $core[005207] = 0; $pc++; }$code[005207] = *emul8; goto &fetch; }
$core[005240] = 06253; $code[005240] = *I05240; sub I05240 { &emul8; goto &fetch; }
$core[005241] = 00122; $code[005241] = *I05241; sub I05241 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[005242] = 00761; $code[005242] = *I05242; sub I05242 { $lac &= (010000|$core[($df<<12)+$core[2801]]); goto &fetch; }
$core[005243] = 03736; $code[005243] = *I05243; sub I05243 { $core[($df<<12)+$core[2782]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2782]] = *emul8; goto &fetch; }
$core[005244] = 00000; $code[005244] = *I05244; sub I05244 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005245] = 03736; $code[005245] = *I05245; sub I05245 { $core[($df<<12)+$core[2782]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2782]] = *emul8; goto &fetch; }
$core[005246] = 04040; $code[005246] = *I05246; sub I05246 { $core[000040] = 05247; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005247] = 04040; $code[005247] = *I05247; sub I05247 { $core[000040] = 05250; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005250] = 04017; $code[005250] = *I05250; sub I05250 { $core[000017] = 05251; $pc = 000017+1; $code[000017] = *emul8; $inh = 0; goto &fetch; }
$core[005251] = 02211; $code[005251] = *I05251; sub I05251 { if (++$core[005211] == 010000) { $core[005211] = 0; $pc++; }$code[005211] = *emul8; goto &fetch; }
$core[005252] = 00711; $code[005252] = *I05252; sub I05252 { $lac &= (010000|$core[($df<<12)+$core[2761]]); goto &fetch; }
$core[005253] = 01601; $code[005253] = *L05253; sub L05253 { $lac += $core[($df<<12)+$core[2689]]; goto &fetch; }
$core[005254] = 01440; $code[005254] = *I05254; sub I05254 { $lac += $core[($df<<12)+$core[32]]; goto &fetch; }
$core[005255] = 04040; $code[005255] = *I05255; sub I05255 { $core[000040] = 05256; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005256] = 04040; $code[005256] = *I05256; sub I05256 { $core[000040] = 05257; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005257] = 04023; $code[005257] = *I05257; sub I05257 { $core[000023] = 05260; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[005260] = 01115; $code[005260] = *I05260; sub I05260 { $lac += $core[000115]; goto &fetch; }
$core[005261] = 02514; $code[005261] = *I05261; sub I05261 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[005262] = 00124; $code[005262] = *I05262; sub I05262 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[005263] = 00504; $code[005263] = *I05263; sub I05263 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005264] = 04040; $code[005264] = *I05264; sub I05264 { $core[000040] = 05265; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005265] = 04040; $code[005265] = *I05265; sub I05265 { $core[000040] = 05266; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005266] = 04040; $code[005266] = *I05266; sub I05266 { $core[000040] = 05267; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005267] = 04001; $code[005267] = *I05267; sub I05267 { $core[000001] = 05270; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[005270] = 00324; $code[005270] = *I05270; sub I05270 { $lac &= (010000|$core[005324]); goto &fetch; }
$core[005271] = 02501; $code[005271] = *I05271; sub I05271 { if (++$core[($df<<12)+$core[65]] == 010000) { $core[($df<<12)+$core[65]] = 0; $pc++; }$code[($df<<12)+$core[65]] = *emul8; goto &fetch; }
$core[005272] = 01437; $code[005272] = *I05272; sub I05272 { $lac += $core[($df<<12)+$core[31]]; goto &fetch; }
$core[005273] = 03600; $code[005273] = *I05273; sub I05273 { $core[($df<<12)+$core[2688]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2688]] = *emul8; goto &fetch; }
$core[005274] = 03736; $code[005274] = *I05274; sub I05274 { $core[($df<<12)+$core[2782]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2782]] = *emul8; goto &fetch; }
$core[005275] = 02201; $code[005275] = *I05275; sub I05275 { if (++$core[005201] == 010000) { $core[005201] = 0; $pc++; }$code[005201] = *emul8; goto &fetch; }
$core[005276] = 01604; $code[005276] = *I05276; sub I05276 { $lac += $core[($df<<12)+$core[2692]]; goto &fetch; }
$core[005277] = 00140; $code[005277] = *I05277; sub I05277 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[005300] = 04040; $code[005300] = *I05300; sub I05300 { $core[000040] = 05301; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005301] = 04040; $code[005301] = *I05301; sub I05301 { $core[000040] = 05302; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005302] = 04040; $code[005302] = *I05302; sub I05302 { $core[000040] = 05303; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005303] = 04022; $code[005303] = *I05303; sub I05303 { $core[000022] = 05304; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005304] = 00116; $code[005304] = *I05304; sub I05304 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[005305] = 00403; $code[005305] = *I05305; sub I05305 { $lac &= (010000|$core[($df<<12)+$core[3]]); goto &fetch; }
$core[005306] = 04040; $code[005306] = *I05306; sub I05306 { $core[000040] = 05307; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005307] = 04040; $code[005307] = *I05307; sub I05307 { $core[000040] = 05310; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005310] = 04040; $code[005310] = *I05310; sub I05310 { $core[000040] = 05311; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005311] = 04040; $code[005311] = *P05311; sub P05311 { $core[000040] = 05312; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005312] = 02205; $code[005312] = *I05312; sub I05312 { if (++$core[005205] == 010000) { $core[005205] = 0; $pc++; }$code[005205] = *emul8; goto &fetch; }
$core[005313] = 02325; $code[005313] = *I05313; sub I05313 { if (++$core[005325] == 010000) { $core[005325] = 0; $pc++; }$code[005325] = *emul8; goto &fetch; }
$core[005314] = 01424; $code[005314] = *I05314; sub I05314 { $lac += $core[($df<<12)+$core[20]]; goto &fetch; }
$core[005315] = 03736; $code[005315] = *I05315; sub I05315 { $core[($df<<12)+$core[2782]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2782]] = *emul8; goto &fetch; }
$core[005316] = 00000; $code[005316] = *I05316; sub I05316 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005317] = 03736; $code[005317] = *I05317; sub I05317 { $core[($df<<12)+$core[2782]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2782]] = *emul8; goto &fetch; }
$core[005320] = 02201; $code[005320] = *I05320; sub I05320 { if (++$core[005201] == 010000) { $core[005201] = 0; $pc++; }$code[005201] = *emul8; goto &fetch; }
$core[005321] = 01604; $code[005321] = *I05321; sub I05321 { $lac += $core[($df<<12)+$core[2692]]; goto &fetch; }
$core[005322] = 00140; $code[005322] = *P05322; sub P05322 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[005323] = 04040; $code[005323] = *I05323; sub I05323 { $core[000040] = 05324; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005324] = 04040; $code[005324] = *D05324; sub D05324 { $core[000040] = 05325; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005325] = 04040; $code[005325] = *D05325; sub D05325 { $core[000040] = 05326; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005326] = 04002; $code[005326] = *I05326; sub I05326 { $core[000002] = 05327; $pc = 000002+1; $code[000002] = *emul8; $inh = 0; goto &fetch; }
$core[005327] = 02017; $code[005327] = *I05327; sub I05327 { if (++$core[000017] == 010000) { $core[000017] = 0; $pc++; }$code[000017] = *emul8; goto &fetch; }
$core[005330] = 02340; $code[005330] = *I05330; sub I05330 { if (++$core[005340] == 010000) { $core[005340] = 0; $pc++; }$code[005340] = *emul8; goto &fetch; }
$core[005331] = 04040; $code[005331] = *I05331; sub I05331 { $core[000040] = 05332; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005332] = 04040; $code[005332] = *I05332; sub I05332 { $core[000040] = 05333; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005333] = 04040; $code[005333] = *I05333; sub I05333 { $core[000040] = 05334; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005334] = 04040; $code[005334] = *I05334; sub I05334 { $core[000040] = 05335; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005335] = 00216; $code[005335] = *I05335; sub I05335 { $lac &= (010000|$core[005216]); goto &fetch; }
$core[005336] = 00507; $code[005336] = *P05336; sub P05336 { $lac &= (010000|$core[($df<<12)+$core[71]]); goto &fetch; }
$core[005337] = 04040; $code[005337] = *I05337; sub I05337 { $core[000040] = 05340; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005340] = 04040; $code[005340] = *D05340; sub D05340 { $core[000040] = 05341; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005341] = 04040; $code[005341] = *I05341; sub I05341 { $core[000040] = 05342; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005342] = 04040; $code[005342] = *I05342; sub I05342 { $core[000040] = 05343; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005343] = 04022; $code[005343] = *I05343; sub I05343 { $core[000022] = 05344; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005344] = 00523; $code[005344] = *I05344; sub I05344 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[005345] = 02514; $code[005345] = *I05345; sub I05345 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[005346] = 02437; $code[005346] = *I05346; sub I05346 { if (++$core[($df<<12)+$core[31]] == 010000) { $core[($df<<12)+$core[31]] = 0; $pc++; }$code[($df<<12)+$core[31]] = *emul8; goto &fetch; }
$core[005347] = 03600; $code[005347] = *I05347; sub I05347 { $core[($df<<12)+$core[2688]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2688]] = *emul8; goto &fetch; }
$core[005350] = 03736; $code[005350] = *I05350; sub I05350 { $core[($df<<12)+$core[2782]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2782]] = *emul8; goto &fetch; }
$core[005351] = 01722; $code[005351] = *I05351; sub I05351 { $lac += $core[($df<<12)+$core[2770]]; goto &fetch; }
$core[005352] = 01107; $code[005352] = *I05352; sub I05352 { $lac += $core[000107]; goto &fetch; }
$core[005353] = 01116; $code[005353] = *I05353; sub I05353 { $lac += $core[000116]; goto &fetch; }
$core[005354] = 00114; $code[005354] = *I05354; sub I05354 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[005355] = 04040; $code[005355] = *I05355; sub I05355 { $core[000040] = 05356; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005356] = 04040; $code[005356] = *I05356; sub I05356 { $core[000040] = 05357; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005357] = 04040; $code[005357] = *I05357; sub I05357 { $core[000040] = 05360; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005360] = 00103; $code[005360] = *I05360; sub I05360 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[005361] = 02425; $code[005361] = *P05361; sub P05361 { if (++$core[($df<<12)+$core[21]] == 010000) { $core[($df<<12)+$core[21]] = 0; $pc++; }$code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[005362] = 00114; $code[005362] = *P05362; sub P05362 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[005363] = 03736; $code[005363] = *I05363; sub I05363 { $core[($df<<12)+$core[2782]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2782]] = *emul8; goto &fetch; }
$core[005364] = 00000; $code[005364] = *I05364; sub I05364 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005365] = 03736; $code[005365] = *I05365; sub I05365 { $core[($df<<12)+$core[2782]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2782]] = *emul8; goto &fetch; }
$core[005366] = 04040; $code[005366] = *I05366; sub I05366 { $core[000040] = 05367; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005367] = 04040; $code[005367] = *I05367; sub I05367 { $core[000040] = 05370; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005370] = 00122; $code[005370] = *I05370; sub I05370 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[005371] = 00761; $code[005371] = *I05371; sub I05371 { $lac &= (010000|$core[($df<<12)+$core[2801]]); goto &fetch; }
$core[005372] = 04040; $code[005372] = *I05372; sub I05372 { $core[000040] = 05373; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005373] = 04040; $code[005373] = *I05373; sub I05373 { $core[000040] = 05374; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005374] = 04040; $code[005374] = *I05374; sub I05374 { $core[000040] = 05375; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005375] = 04040; $code[005375] = *I05375; sub I05375 { $core[000040] = 05376; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005376] = 04001; $code[005376] = *I05376; sub I05376 { $core[000001] = 05377; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[005377] = 02207; $code[005377] = *I05377; sub I05377 { if (++$core[005207] == 010000) { $core[005207] = 0; $pc++; }$code[005207] = *emul8; goto &fetch; }
$core[005400] = 06240; $code[005400] = *I05400; sub I05400 { &emul8; goto &fetch; }
$core[005401] = 04040; $code[005401] = *P05401; sub P05401 { $core[000040] = 05402; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005402] = 04040; $code[005402] = *I05402; sub I05402 { $core[000040] = 05403; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005403] = 04040; $code[005403] = *I05403; sub I05403 { $core[000040] = 05404; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005404] = 00530; $code[005404] = *D05404; sub D05404 { $lac &= (010000|$core[($df<<12)+$core[88]]); goto &fetch; }
$core[005405] = 02005; $code[005405] = *I05405; sub I05405 { if (++$core[000005] == 010000) { $core[000005] = 0; $pc++; }$code[000005] = *emul8; goto &fetch; }
$core[005406] = 00324; $code[005406] = *I05406; sub I05406 { $lac &= (010000|$core[005524]); goto &fetch; }
$core[005407] = 00504; $code[005407] = *I05407; sub I05407 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005410] = 04040; $code[005410] = *I05410; sub I05410 { $core[000040] = 05411; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005411] = 04040; $code[005411] = *I05411; sub I05411 { $core[000040] = 05412; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005412] = 04040; $code[005412] = *I05412; sub I05412 { $core[000040] = 05413; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005413] = 00103; $code[005413] = *I05413; sub I05413 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[005414] = 02425; $code[005414] = *I05414; sub I05414 { if (++$core[($df<<12)+$core[21]] == 010000) { $core[($df<<12)+$core[21]] = 0; $pc++; }$code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[005415] = 00114; $code[005415] = *I05415; sub I05415 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[005416] = 03736; $code[005416] = *I05416; sub I05416 { $core[($df<<12)+$core[2910]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005417] = 00000; $code[005417] = *I05417; sub I05417 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005420] = 03736; $code[005420] = *I05420; sub I05420 { $core[($df<<12)+$core[2910]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005421] = 04040; $code[005421] = *I05421; sub I05421 { $core[000040] = 05422; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005422] = 04040; $code[005422] = *I05422; sub I05422 { $core[000040] = 05423; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005423] = 04023; $code[005423] = *I05423; sub I05423 { $core[000023] = 05424; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[005424] = 01115; $code[005424] = *I05424; sub I05424 { $lac += $core[000115]; goto &fetch; }
$core[005425] = 02514; $code[005425] = *I05425; sub I05425 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[005426] = 00124; $code[005426] = *I05426; sub I05426 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[005427] = 00504; $code[005427] = *I05427; sub I05427 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005430] = 04001; $code[005430] = *I05430; sub I05430 { $core[000001] = 05431; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[005431] = 00404; $code[005431] = *I05431; sub I05431 { $lac &= (010000|$core[($df<<12)+$core[4]]); goto &fetch; }
$core[005432] = 04024; $code[005432] = *I05432; sub I05432 { $core[000024] = 05433; $pc = 000024+1; $code[000024] = *emul8; $inh = 0; goto &fetch; }
$core[005433] = 00523; $code[005433] = *I05433; sub I05433 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[005434] = 02440; $code[005434] = *I05434; sub I05434 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[005435] = 00601; $code[005435] = *I05435; sub I05435 { $lac &= (010000|$core[($df<<12)+$core[2817]]); goto &fetch; }
$core[005436] = 01114; $code[005436] = *I05436; sub I05436 { $lac += $core[000114]; goto &fetch; }
$core[005437] = 00504; $code[005437] = *I05437; sub I05437 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005440] = 00000; $code[005440] = *I05440; sub I05440 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005441] = 03736; $code[005441] = *I05441; sub I05441 { $core[($df<<12)+$core[2910]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005442] = 04040; $code[005442] = *I05442; sub I05442 { $core[000040] = 05443; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005443] = 04040; $code[005443] = *I05443; sub I05443 { $core[000040] = 05444; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005444] = 04023; $code[005444] = *I05444; sub I05444 { $core[000023] = 05445; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[005445] = 01115; $code[005445] = *I05445; sub I05445 { $lac += $core[000115]; goto &fetch; }
$core[005446] = 02514; $code[005446] = *I05446; sub I05446 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[005447] = 00124; $code[005447] = *I05447; sub I05447 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[005450] = 00504; $code[005450] = *I05450; sub I05450 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005451] = 04022; $code[005451] = *I05451; sub I05451 { $core[000022] = 05452; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005452] = 00114; $code[005452] = *I05452; sub I05452 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[005453] = 04024; $code[005453] = *I05453; sub I05453 { $core[000024] = 05454; $pc = 000024+1; $code[000024] = *emul8; $inh = 0; goto &fetch; }
$core[005454] = 00523; $code[005454] = *I05454; sub I05454 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[005455] = 02440; $code[005455] = *I05455; sub I05455 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[005456] = 00601; $code[005456] = *I05456; sub I05456 { $lac &= (010000|$core[($df<<12)+$core[2817]]); goto &fetch; }
$core[005457] = 01114; $code[005457] = *I05457; sub I05457 { $lac += $core[000114]; goto &fetch; }
$core[005460] = 00504; $code[005460] = *I05460; sub I05460 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005461] = 00000; $code[005461] = *I05461; sub I05461 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005462] = 03736; $code[005462] = *I05462; sub I05462 { $core[($df<<12)+$core[2910]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005463] = 04040; $code[005463] = *I05463; sub I05463 { $core[000040] = 05464; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005464] = 04040; $code[005464] = *I05464; sub I05464 { $core[000040] = 05465; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005465] = 04023; $code[005465] = *I05465; sub I05465 { $core[000023] = 05466; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[005466] = 01115; $code[005466] = *I05466; sub I05466 { $lac += $core[000115]; goto &fetch; }
$core[005467] = 02514; $code[005467] = *I05467; sub I05467 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[005470] = 00124; $code[005470] = *I05470; sub I05470 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[005471] = 00504; $code[005471] = *I05471; sub I05471 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005472] = 04022; $code[005472] = *I05472; sub I05472 { $core[000022] = 05473; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005473] = 00122; $code[005473] = *I05473; sub I05473 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[005474] = 04024; $code[005474] = *I05474; sub I05474 { $core[000024] = 05475; $pc = 000024+1; $code[000024] = *emul8; $inh = 0; goto &fetch; }
$core[005475] = 00523; $code[005475] = *I05475; sub I05475 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[005476] = 02440; $code[005476] = *I05476; sub I05476 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[005477] = 00601; $code[005477] = *I05477; sub I05477 { $lac &= (010000|$core[($df<<12)+$core[2817]]); goto &fetch; }
$core[005500] = 01114; $code[005500] = *I05500; sub I05500 { $lac += $core[000114]; goto &fetch; }
$core[005501] = 00504; $code[005501] = *I05501; sub I05501 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005502] = 00000; $code[005502] = *I05502; sub I05502 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005503] = 03736; $code[005503] = *I05503; sub I05503 { $core[($df<<12)+$core[2910]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005504] = 04040; $code[005504] = *I05504; sub I05504 { $core[000040] = 05505; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005505] = 04040; $code[005505] = *I05505; sub I05505 { $core[000040] = 05506; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005506] = 04023; $code[005506] = *I05506; sub I05506 { $core[000023] = 05507; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[005507] = 01115; $code[005507] = *I05507; sub I05507 { $lac += $core[000115]; goto &fetch; }
$core[005510] = 02514; $code[005510] = *I05510; sub I05510 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[005511] = 00124; $code[005511] = *I05511; sub I05511 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[005512] = 00504; $code[005512] = *I05512; sub I05512 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005513] = 04022; $code[005513] = *I05513; sub I05513 { $core[000022] = 05514; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005514] = 02414; $code[005514] = *I05514; sub I05514 { $core[000014] = 0000 if ++$core[000014] == 010000; if (++$core[($df<<12)+$core[000014]] == 010000) { $core[($df<<12)+$core[000014]] = 0; $pc++; }$code[($df<<12)+$core[000014]] = *emul8; goto &fetch; }
$core[005515] = 04024; $code[005515] = *I05515; sub I05515 { $core[000024] = 05516; $pc = 000024+1; $code[000024] = *emul8; $inh = 0; goto &fetch; }
$core[005516] = 00523; $code[005516] = *I05516; sub I05516 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[005517] = 02440; $code[005517] = *I05517; sub I05517 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[005520] = 00601; $code[005520] = *I05520; sub I05520 { $lac &= (010000|$core[($df<<12)+$core[2817]]); goto &fetch; }
$core[005521] = 01114; $code[005521] = *I05521; sub I05521 { $lac += $core[000114]; goto &fetch; }
$core[005522] = 00504; $code[005522] = *I05522; sub I05522 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005523] = 00000; $code[005523] = *I05523; sub I05523 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005524] = 03736; $code[005524] = *D05524; sub D05524 { $core[($df<<12)+$core[2910]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005525] = 04040; $code[005525] = *I05525; sub I05525 { $core[000040] = 05526; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005526] = 04040; $code[005526] = *I05526; sub I05526 { $core[000040] = 05527; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005527] = 04023; $code[005527] = *D05527; sub D05527 { $core[000023] = 05530; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[005530] = 01115; $code[005530] = *I05530; sub I05530 { $lac += $core[000115]; goto &fetch; }
$core[005531] = 02514; $code[005531] = *I05531; sub I05531 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[005532] = 00124; $code[005532] = *I05532; sub I05532 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[005533] = 00504; $code[005533] = *I05533; sub I05533 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005534] = 04022; $code[005534] = *I05534; sub I05534 { $core[000022] = 05535; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005535] = 02422; $code[005535] = *I05535; sub I05535 { if (++$core[($df<<12)+$core[18]] == 010000) { $core[($df<<12)+$core[18]] = 0; $pc++; }$code[($df<<12)+$core[18]] = *emul8; goto &fetch; }
$core[005536] = 04024; $code[005536] = *P05536; sub P05536 { $core[000024] = 05537; $pc = 000024+1; $code[000024] = *emul8; $inh = 0; goto &fetch; }
$core[005537] = 00523; $code[005537] = *I05537; sub I05537 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[005540] = 02440; $code[005540] = *I05540; sub I05540 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[005541] = 00601; $code[005541] = *I05541; sub I05541 { $lac &= (010000|$core[($df<<12)+$core[2817]]); goto &fetch; }
$core[005542] = 01114; $code[005542] = *I05542; sub I05542 { $lac += $core[000114]; goto &fetch; }
$core[005543] = 00504; $code[005543] = *I05543; sub I05543 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005544] = 00000; $code[005544] = *I05544; sub I05544 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005545] = 03736; $code[005545] = *I05545; sub I05545 { $core[($df<<12)+$core[2910]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005546] = 04040; $code[005546] = *I05546; sub I05546 { $core[000040] = 05547; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005547] = 04040; $code[005547] = *I05547; sub I05547 { $core[000040] = 05550; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005550] = 04023; $code[005550] = *I05550; sub I05550 { $core[000023] = 05551; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[005551] = 01115; $code[005551] = *I05551; sub I05551 { $lac += $core[000115]; goto &fetch; }
$core[005552] = 02514; $code[005552] = *I05552; sub I05552 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[005553] = 00124; $code[005553] = *I05553; sub I05553 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[005554] = 00504; $code[005554] = *I05554; sub I05554 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005555] = 04002; $code[005555] = *I05555; sub I05555 { $core[000002] = 05556; $pc = 000002+1; $code[000002] = *emul8; $inh = 0; goto &fetch; }
$core[005556] = 02327; $code[005556] = *I05556; sub I05556 { if (++$core[005527] == 010000) { $core[005527] = 0; $pc++; }$code[005527] = *emul8; goto &fetch; }
$core[005557] = 04024; $code[005557] = *I05557; sub I05557 { $core[000024] = 05560; $pc = 000024+1; $code[000024] = *emul8; $inh = 0; goto &fetch; }
$core[005560] = 00523; $code[005560] = *I05560; sub I05560 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[005561] = 02440; $code[005561] = *I05561; sub I05561 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[005562] = 00601; $code[005562] = *I05562; sub I05562 { $lac &= (010000|$core[($df<<12)+$core[2817]]); goto &fetch; }
$core[005563] = 01114; $code[005563] = *I05563; sub I05563 { $lac += $core[000114]; goto &fetch; }
$core[005564] = 00504; $code[005564] = *I05564; sub I05564 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[005565] = 00000; $code[005565] = *I05565; sub I05565 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005566] = 03736; $code[005566] = *I05566; sub I05566 { $core[($df<<12)+$core[2910]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005567] = 04040; $code[005567] = *I05567; sub I05567 { $core[000040] = 05570; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005570] = 04040; $code[005570] = *I05570; sub I05570 { $core[000040] = 05571; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005571] = 04022; $code[005571] = *I05571; sub I05571 { $core[000022] = 05572; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005572] = 00116; $code[005572] = *I05572; sub I05572 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[005573] = 00417; $code[005573] = *I05573; sub I05573 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[005574] = 01540; $code[005574] = *I05574; sub I05574 { $lac += $core[($df<<12)+$core[96]]; goto &fetch; }
$core[005575] = 00104; $code[005575] = *I05575; sub I05575 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[005576] = 00440; $code[005576] = *I05576; sub I05576 { $lac &= (010000|$core[($df<<12)+$core[32]]); goto &fetch; }
$core[005577] = 02405; $code[005577] = *I05577; sub I05577 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[005600] = 02324; $code[005600] = *P05600; sub P05600 { if (++$core[005724] == 010000) { $core[005724] = 0; $pc++; }$code[005724] = *emul8; goto &fetch; }
$core[005601] = 04061; $code[005601] = *D05601; sub D05601 { $core[000061] = 05602; $pc = 000061+1; $code[000061] = *emul8; $inh = 0; goto &fetch; }
$core[005602] = 04006; $code[005602] = *I05602; sub I05602 { $core[000006] = 05603; $pc = 000006+1; $code[000006] = *emul8; $inh = 0; goto &fetch; }
$core[005603] = 00111; $code[005603] = *P05603; sub P05603 { $lac &= (010000|$core[000111]); goto &fetch; }
$core[005604] = 01405; $code[005604] = *P05604; sub P05604 { $lac += $core[($df<<12)+$core[5]]; goto &fetch; }
$core[005605] = 00400; $code[005605] = *I05605; sub I05605 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[005606] = 03736; $code[005606] = *I05606; sub I05606 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005607] = 04040; $code[005607] = *I05607; sub I05607 { $core[000040] = 05610; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005610] = 04040; $code[005610] = *I05610; sub I05610 { $core[000040] = 05611; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005611] = 04022; $code[005611] = *I05611; sub I05611 { $core[000022] = 05612; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005612] = 00116; $code[005612] = *I05612; sub I05612 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[005613] = 00417; $code[005613] = *P05613; sub P05613 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[005614] = 01540; $code[005614] = *I05614; sub I05614 { $lac += $core[($df<<12)+$core[96]]; goto &fetch; }
$core[005615] = 00104; $code[005615] = *I05615; sub I05615 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[005616] = 00440; $code[005616] = *I05616; sub I05616 { $lac &= (010000|$core[($df<<12)+$core[32]]); goto &fetch; }
$core[005617] = 02405; $code[005617] = *D05617; sub D05617 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[005620] = 02324; $code[005620] = *I05620; sub I05620 { if (++$core[005724] == 010000) { $core[005724] = 0; $pc++; }$code[005724] = *emul8; goto &fetch; }
$core[005621] = 04062; $code[005621] = *I05621; sub I05621 { $core[000062] = 05622; $pc = 000062+1; $code[000062] = *emul8; $inh = 0; goto &fetch; }
$core[005622] = 04006; $code[005622] = *I05622; sub I05622 { $core[000006] = 05623; $pc = 000006+1; $code[000006] = *emul8; $inh = 0; goto &fetch; }
$core[005623] = 00111; $code[005623] = *I05623; sub I05623 { $lac &= (010000|$core[000111]); goto &fetch; }
$core[005624] = 01405; $code[005624] = *D05624; sub D05624 { $lac += $core[($df<<12)+$core[5]]; goto &fetch; }
$core[005625] = 00400; $code[005625] = *I05625; sub I05625 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[005626] = 03736; $code[005626] = *I05626; sub I05626 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005627] = 04040; $code[005627] = *I05627; sub I05627 { $core[000040] = 05630; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005630] = 04040; $code[005630] = *I05630; sub I05630 { $core[000040] = 05631; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005631] = 04022; $code[005631] = *I05631; sub I05631 { $core[000022] = 05632; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005632] = 00116; $code[005632] = *I05632; sub I05632 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[005633] = 00417; $code[005633] = *I05633; sub I05633 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[005634] = 01540; $code[005634] = *I05634; sub I05634 { $lac += $core[($df<<12)+$core[96]]; goto &fetch; }
$core[005635] = 02201; $code[005635] = *I05635; sub I05635 { if (++$core[005601] == 010000) { $core[005601] = 0; $pc++; }$code[005601] = *emul8; goto &fetch; }
$core[005636] = 02240; $code[005636] = *I05636; sub I05636 { if (++$core[005640] == 010000) { $core[005640] = 0; $pc++; }$code[005640] = *emul8; goto &fetch; }
$core[005637] = 02405; $code[005637] = *D05637; sub D05637 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[005640] = 02324; $code[005640] = *D05640; sub D05640 { if (++$core[005724] == 010000) { $core[005724] = 0; $pc++; }$code[005724] = *emul8; goto &fetch; }
$core[005641] = 04006; $code[005641] = *I05641; sub I05641 { $core[000006] = 05642; $pc = 000006+1; $code[000006] = *emul8; $inh = 0; goto &fetch; }
$core[005642] = 00111; $code[005642] = *I05642; sub I05642 { $lac &= (010000|$core[000111]); goto &fetch; }
$core[005643] = 01405; $code[005643] = *I05643; sub I05643 { $lac += $core[($df<<12)+$core[5]]; goto &fetch; }
$core[005644] = 00400; $code[005644] = *I05644; sub I05644 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[005645] = 03736; $code[005645] = *I05645; sub I05645 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005646] = 04040; $code[005646] = *I05646; sub I05646 { $core[000040] = 05647; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005647] = 04040; $code[005647] = *I05647; sub I05647 { $core[000040] = 05650; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005650] = 04022; $code[005650] = *I05650; sub I05650 { $core[000022] = 05651; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005651] = 00116; $code[005651] = *I05651; sub I05651 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[005652] = 00417; $code[005652] = *I05652; sub I05652 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[005653] = 01540; $code[005653] = *I05653; sub I05653 { $lac += $core[($df<<12)+$core[96]]; goto &fetch; }
$core[005654] = 02201; $code[005654] = *I05654; sub I05654 { if (++$core[005601] == 010000) { $core[005601] = 0; $pc++; }$code[005601] = *emul8; goto &fetch; }
$core[005655] = 01440; $code[005655] = *I05655; sub I05655 { $lac += $core[($df<<12)+$core[32]]; goto &fetch; }
$core[005656] = 02405; $code[005656] = *I05656; sub I05656 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[005657] = 02324; $code[005657] = *I05657; sub I05657 { if (++$core[005724] == 010000) { $core[005724] = 0; $pc++; }$code[005724] = *emul8; goto &fetch; }
$core[005660] = 04006; $code[005660] = *I05660; sub I05660 { $core[000006] = 05661; $pc = 000006+1; $code[000006] = *emul8; $inh = 0; goto &fetch; }
$core[005661] = 00111; $code[005661] = *I05661; sub I05661 { $lac &= (010000|$core[000111]); goto &fetch; }
$core[005662] = 01405; $code[005662] = *I05662; sub I05662 { $lac += $core[($df<<12)+$core[5]]; goto &fetch; }
$core[005663] = 00400; $code[005663] = *I05663; sub I05663 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[005664] = 03736; $code[005664] = *I05664; sub I05664 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005665] = 04040; $code[005665] = *I05665; sub I05665 { $core[000040] = 05666; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005666] = 04040; $code[005666] = *I05666; sub I05666 { $core[000040] = 05667; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005667] = 04022; $code[005667] = *I05667; sub I05667 { $core[000022] = 05670; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005670] = 00116; $code[005670] = *I05670; sub I05670 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[005671] = 00417; $code[005671] = *I05671; sub I05671 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[005672] = 01540; $code[005672] = *I05672; sub I05672 { $lac += $core[($df<<12)+$core[96]]; goto &fetch; }
$core[005673] = 02224; $code[005673] = *I05673; sub I05673 { if (++$core[005624] == 010000) { $core[005624] = 0; $pc++; }$code[005624] = *emul8; goto &fetch; }
$core[005674] = 01440; $code[005674] = *I05674; sub I05674 { $lac += $core[($df<<12)+$core[32]]; goto &fetch; }
$core[005675] = 02405; $code[005675] = *I05675; sub I05675 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[005676] = 02324; $code[005676] = *I05676; sub I05676 { if (++$core[005724] == 010000) { $core[005724] = 0; $pc++; }$code[005724] = *emul8; goto &fetch; }
$core[005677] = 04006; $code[005677] = *I05677; sub I05677 { $core[000006] = 05700; $pc = 000006+1; $code[000006] = *emul8; $inh = 0; goto &fetch; }
$core[005700] = 00111; $code[005700] = *I05700; sub I05700 { $lac &= (010000|$core[000111]); goto &fetch; }
$core[005701] = 01405; $code[005701] = *I05701; sub I05701 { $lac += $core[($df<<12)+$core[5]]; goto &fetch; }
$core[005702] = 00400; $code[005702] = *I05702; sub I05702 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[005703] = 03736; $code[005703] = *I05703; sub I05703 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005704] = 04040; $code[005704] = *I05704; sub I05704 { $core[000040] = 05705; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005705] = 04040; $code[005705] = *I05705; sub I05705 { $core[000040] = 05706; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[005706] = 04022; $code[005706] = *P05706; sub P05706 { $core[000022] = 05707; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[005707] = 00116; $code[005707] = *I05707; sub I05707 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[005710] = 00417; $code[005710] = *I05710; sub I05710 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[005711] = 01540; $code[005711] = *D05711; sub D05711 { $lac += $core[($df<<12)+$core[96]]; goto &fetch; }
$core[005712] = 02224; $code[005712] = *I05712; sub I05712 { if (++$core[005624] == 010000) { $core[005624] = 0; $pc++; }$code[005624] = *emul8; goto &fetch; }
$core[005713] = 02240; $code[005713] = *I05713; sub I05713 { if (++$core[005640] == 010000) { $core[005640] = 0; $pc++; }$code[005640] = *emul8; goto &fetch; }
$core[005714] = 02405; $code[005714] = *I05714; sub I05714 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[005715] = 02324; $code[005715] = *P05715; sub P05715 { if (++$core[005724] == 010000) { $core[005724] = 0; $pc++; }$code[005724] = *emul8; goto &fetch; }
$core[005716] = 04006; $code[005716] = *I05716; sub I05716 { $core[000006] = 05717; $pc = 000006+1; $code[000006] = *emul8; $inh = 0; goto &fetch; }
$core[005717] = 00111; $code[005717] = *I05717; sub I05717 { $lac &= (010000|$core[000111]); goto &fetch; }
$core[005720] = 01405; $code[005720] = *I05720; sub I05720 { $lac += $core[($df<<12)+$core[5]]; goto &fetch; }
$core[005721] = 00400; $code[005721] = *I05721; sub I05721 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[005722] = 03736; $code[005722] = *P05722; sub P05722 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005723] = 02311; $code[005723] = *I05723; sub I05723 { if (++$core[005711] == 010000) { $core[005711] = 0; $pc++; }$code[005711] = *emul8; goto &fetch; }
$core[005724] = 01501; $code[005724] = *P05724; sub P05724 { $lac += $core[($df<<12)+$core[65]]; goto &fetch; }
$core[005725] = 00400; $code[005725] = *I05725; sub I05725 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[005726] = 03736; $code[005726] = *I05726; sub I05726 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005727] = 02311; $code[005727] = *I05727; sub I05727 { if (++$core[005711] == 010000) { $core[005711] = 0; $pc++; }$code[005711] = *emul8; goto &fetch; }
$core[005730] = 01522; $code[005730] = *I05730; sub I05730 { $lac += $core[($df<<12)+$core[82]]; goto &fetch; }
$core[005731] = 01724; $code[005731] = *I05731; sub I05731 { $lac += $core[($df<<12)+$core[3028]]; goto &fetch; }
$core[005732] = 00000; $code[005732] = *I05732; sub I05732 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005733] = 03736; $code[005733] = *I05733; sub I05733 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005734] = 00603; $code[005734] = *I05734; sub I05734 { $lac &= (010000|$core[($df<<12)+$core[2947]]); goto &fetch; }
$core[005735] = 02400; $code[005735] = *I05735; sub I05735 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[005736] = 03736; $code[005736] = *P05736; sub P05736 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005737] = 02201; $code[005737] = *I05737; sub I05737 { if (++$core[005601] == 010000) { $core[005601] = 0; $pc++; }$code[005601] = *emul8; goto &fetch; }
$core[005740] = 01604; $code[005740] = *D05740; sub D05740 { $lac += $core[($df<<12)+$core[2948]]; goto &fetch; }
$core[005741] = 01715; $code[005741] = *I05741; sub I05741 { $lac += $core[($df<<12)+$core[3021]]; goto &fetch; }
$core[005742] = 00000; $code[005742] = *I05742; sub I05742 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005743] = 03736; $code[005743] = *I05743; sub I05743 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005744] = 00000; $code[005744] = *I05744; sub I05744 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005745] = 03736; $code[005745] = *I05745; sub I05745 { $core[($df<<12)+$core[3038]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3038]] = *emul8; goto &fetch; }
$core[005746] = 04004; $code[005746] = *I05746; sub I05746 { $core[000004] = 05747; $pc = 000004+1; $code[000004] = *emul8; $inh = 0; goto &fetch; }
$core[005747] = 00124; $code[005747] = *I05747; sub I05747 { $lac &= (010000|$core[000124]); goto &fetch; }
$core[005750] = 00140; $code[005750] = *I05750; sub I05750 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[005751] = 00522; $code[005751] = *I05751; sub I05751 { $lac &= (010000|$core[($df<<12)+$core[82]]); goto &fetch; }
$core[005752] = 02217; $code[005752] = *I05752; sub I05752 { if (++$core[005617] == 010000) { $core[005617] = 0; $pc++; }$code[005617] = *emul8; goto &fetch; }
$core[005753] = 02237; $code[005753] = *I05753; sub I05753 { if (++$core[005637] == 010000) { $core[005637] = 0; $pc++; }$code[005637] = *emul8; goto &fetch; }
$core[005754] = 03600; $code[005754] = *I05754; sub I05754 { $core[($df<<12)+$core[2944]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2944]] = *emul8; goto &fetch; }
$core[005755] = 07777; $code[005755] = *I05755; sub I05755 { &emul8; goto &fetch; }
$core[005756] = 04005; $code[005756] = *I05756; sub I05756 { $core[000005] = 05757; $pc = 000005+1; $code[000005] = *emul8; $inh = 0; goto &fetch; }
$core[005757] = 03024; $code[005757] = *I05757; sub I05757 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[005760] = 00516; $code[005760] = *I05760; sub I05760 { $lac &= (010000|$core[($df<<12)+$core[78]]); goto &fetch; }
$core[005761] = 00405; $code[005761] = *I05761; sub I05761 { $lac &= (010000|$core[($df<<12)+$core[5]]); goto &fetch; }
$core[005762] = 00440; $code[005762] = *I05762; sub I05762 { $lac &= (010000|$core[($df<<12)+$core[32]]); goto &fetch; }
$core[005763] = 00201; $code[005763] = *I05763; sub I05763 { $lac &= (010000|$core[005601]); goto &fetch; }
$core[005764] = 01613; $code[005764] = *I05764; sub I05764 { $lac += $core[($df<<12)+$core[2955]]; goto &fetch; }
$core[005765] = 02340; $code[005765] = *I05765; sub I05765 { if (++$core[005740] == 010000) { $core[005740] = 0; $pc++; }$code[005740] = *emul8; goto &fetch; }
$core[005766] = 01706; $code[005766] = *I05766; sub I05766 { $lac += $core[($df<<12)+$core[3014]]; goto &fetch; }
$core[005767] = 04015; $code[005767] = *I05767; sub I05767 { $core[000015] = 05770; $pc = 000015+1; $code[000015] = *emul8; $inh = 0; goto &fetch; }
$core[005770] = 00515; $code[005770] = *I05770; sub I05770 { $lac &= (010000|$core[($df<<12)+$core[77]]); goto &fetch; }
$core[005771] = 01722; $code[005771] = *I05771; sub I05771 { $lac += $core[($df<<12)+$core[3026]]; goto &fetch; }
$core[005772] = 03140; $code[005772] = *I05772; sub I05772 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[005773] = 02417; $code[005773] = *I05773; sub I05773 { $core[000017] = 0000 if ++$core[000017] == 010000; if (++$core[($df<<12)+$core[000017]] == 010000) { $core[($df<<12)+$core[000017]] = 0; $pc++; }$code[($df<<12)+$core[000017]] = *emul8; goto &fetch; }
$core[005774] = 04002; $code[005774] = *I05774; sub I05774 { $core[000002] = 05775; $pc = 000002+1; $code[000002] = *emul8; $inh = 0; goto &fetch; }
$core[005775] = 00116; $code[005775] = *I05775; sub I05775 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[005776] = 01340; $code[005776] = *I05776; sub I05776 { $lac += $core[005740]; goto &fetch; }
$core[005777] = 00000; $code[005777] = *I05777; sub I05777 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007600] = 07300; $code[007600] = *I07600; sub I07600 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[007601] = 01155; $code[007601] = *I07601; sub I07601 { $lac += $core[000155]; goto &fetch; }
$core[007602] = 03377; $code[007602] = *I07602; sub I07602 { $core[007777] = $lac & 07777; $lac &= 010000; $code[007777] = *emul8; goto &fetch; }
$core[007603] = 05377; $code[007603] = *I07603; sub I07603 { $pc = 007777; $inh = 0; goto &fetch; }
$core[007775] = 00000; $code[007775] = *I07775; sub I07775 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007776] = 00000; $code[007776] = *L07776; sub L07776 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007777] = 00000; $code[007777] = *L07777; sub L07777 { $lac &= (010000|$core[000000]); goto &fetch; }
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

