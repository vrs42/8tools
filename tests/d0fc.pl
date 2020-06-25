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
$core[000002] = 00002; $code[000002] = *P00002; sub P00002 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000003] = 00003; $code[000003] = *D00003; sub D00003 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000004] = 00000; $code[000004] = *D00004; sub D00004 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000005] = 00000; $code[000005] = *I00005; sub I00005 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000006] = 00202; $code[000006] = *D00006; sub D00006 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000007] = 00547; $code[000007] = *P00007; sub P00007 { $lac &= (010000|$core[($df<<12)+$core[103]]); goto &fetch; }
$core[000010] = 00007; $code[000010] = *D00010; sub D00010 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000011] = 00000; $code[000011] = *P00011; sub P00011 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000012] = 00000; $code[000012] = *P00012; sub P00012 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000013] = 07401; $code[000013] = *P00013; sub P00013 { &emul8; goto &fetch; }
$core[000014] = 03607; $code[000014] = *P00014; sub P00014 { $core[($df<<12)+$core[7]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[7]] = *emul8; goto &fetch; }
$core[000015] = 00003; $code[000015] = *D00015; sub D00015 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000016] = 02421; $code[000016] = *D00016; sub D00016 { if (++$core[($df<<12)+$core[17]] == 010000) { $core[($df<<12)+$core[17]] = 0; $pc++; }$code[($df<<12)+$core[17]] = *emul8; goto &fetch; }
$core[000017] = 05116; $code[000017] = *D00017; sub D00017 { $pc = 000116; $inh = 0; goto &fetch; }
$core[000020] = 05141; $code[000020] = *D00020; sub D00020 { $pc = 000141; $inh = 0; goto &fetch; }
$core[000021] = 00000; $code[000021] = *P00021; sub P00021 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000022] = 00000; $code[000022] = *D00022; sub D00022 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000023] = 00000; $code[000023] = *D00023; sub D00023 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000024] = 00000; $code[000024] = *D00024; sub D00024 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000025] = 00004; $code[000025] = *D00025; sub D00025 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[000026] = 00400; $code[000026] = *P00026; sub P00026 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000027] = 00200; $code[000027] = *D00027; sub D00027 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000030] = 00100; $code[000030] = *D00030; sub D00030 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000031] = 00000; $code[000031] = *D00031; sub D00031 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000032] = 00257; $code[000032] = *D00032; sub D00032 { $lac &= (010000|$core[000057]); goto &fetch; }
$core[000033] = 00201; $code[000033] = *P00033; sub P00033 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000034] = 00206; $code[000034] = *P00034; sub P00034 { $lac &= (010000|$core[000006]); goto &fetch; }
$core[000035] = 00413; $code[000035] = *P00035; sub P00035 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac &= (010000|$core[($df<<12)+$core[000013]]); goto &fetch; }
$core[000036] = 01014; $code[000036] = *D00036; sub D00036 { $lac += $core[000014]; goto &fetch; }
$core[000037] = 00600; $code[000037] = *P00037; sub P00037 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000040] = 04441; $code[000040] = *L00040; sub L00040 { $core[($ib<<12)+$core[33]] = 00041; $pc = ($ib<<12)+$core[33]+1; $code[($ib<<12)+$core[33]] = *emul8; $inh = 0; goto &fetch; }
$core[000041] = 00614; $code[000041] = *P00041; sub P00041 { $core[000014] = 0000 if ++$core[000014] == 010000; $lac &= (010000|$core[($df<<12)+$core[000014]]); goto &fetch; }
$core[000042] = 00015; $code[000042] = *I00042; sub I00042 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000043] = 07640; $code[000043] = *I00043; sub I00043 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000044] = 05426; $code[000044] = *I00044; sub I00044 { $pc = ($ib<<12)+$core[22]; $inh = 0; goto &fetch; }
$core[000045] = 01036; $code[000045] = *I00045; sub I00045 { $lac += $core[000036]; goto &fetch; }
$core[000046] = 03165; $code[000046] = *I00046; sub I00046 { $core[000165] = $lac & 07777; $lac &= 010000; $code[000165] = *emul8; goto &fetch; }
$core[000047] = 07604; $code[000047] = *L00047; sub L00047 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000050] = 00030; $code[000050] = *I00050; sub I00050 { $lac &= (010000|$core[000030]); goto &fetch; }
$core[000051] = 07440; $code[000051] = *I00051; sub I00051 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000052] = 05055; $code[000052] = *I00052; sub I00052 { $pc = 000055; $inh = 0; goto &fetch; }
$core[000053] = 04164; $code[000053] = *I00053; sub I00053 { $core[000164] = 00054; $pc = 000164+1; $code[000164] = *emul8; $inh = 0; goto &fetch; }
$core[000054] = 03022; $code[000054] = *D00054; sub D00054 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[000055] = 07604; $code[000055] = *L00055; sub L00055 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000056] = 00027; $code[000056] = *I00056; sub I00056 { $lac &= (010000|$core[000027]); goto &fetch; }
$core[000057] = 07640; $code[000057] = *D00057; sub D00057 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000060] = 05065; $code[000060] = *I00060; sub I00060 { $pc = 000065; $inh = 0; goto &fetch; }
$core[000061] = 04164; $code[000061] = *I00061; sub I00061 { $core[000164] = 00062; $pc = 000164+1; $code[000164] = *emul8; $inh = 0; goto &fetch; }
$core[000062] = 03021; $code[000062] = *D00062; sub D00062 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[000063] = 01021; $code[000063] = *I00063; sub I00063 { $lac += $core[000021]; goto &fetch; }
$core[000064] = 04151; $code[000064] = *I00064; sub I00064 { $core[000151] = 00065; $pc = 000151+1; $code[000151] = *emul8; $inh = 0; goto &fetch; }
$core[000065] = 07604; $code[000065] = *L00065; sub L00065 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000066] = 00026; $code[000066] = *I00066; sub I00066 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[000067] = 07640; $code[000067] = *I00067; sub I00067 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000070] = 05075; $code[000070] = *I00070; sub I00070 { $pc = 000075; $inh = 0; goto &fetch; }
$core[000071] = 04164; $code[000071] = *I00071; sub I00071 { $core[000164] = 00072; $pc = 000164+1; $code[000164] = *emul8; $inh = 0; goto &fetch; }
$core[000072] = 03002; $code[000072] = *D00072; sub D00072 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[000073] = 01002; $code[000073] = *I00073; sub I00073 { $lac += $core[000002]; goto &fetch; }
$core[000074] = 04151; $code[000074] = *I00074; sub I00074 { $core[000151] = 00075; $pc = 000151+1; $code[000151] = *emul8; $inh = 0; goto &fetch; }
$core[000075] = 07240; $code[000075] = *L00075; sub L00075 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000076] = 01002; $code[000076] = *I00076; sub I00076 { $lac += $core[000002]; goto &fetch; }
$core[000077] = 03011; $code[000077] = *D00077; sub D00077 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000100] = 01016; $code[000100] = *D00100; sub D00100 { $lac += $core[000016]; goto &fetch; }
$core[000101] = 03411; $code[000101] = *I00101; sub I00101 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[000102] = 01017; $code[000102] = *I00102; sub I00102 { $lac += $core[000017]; goto &fetch; }
$core[000103] = 03411; $code[000103] = *I00103; sub I00103 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[000104] = 01020; $code[000104] = *I00104; sub I00104 { $lac += $core[000020]; goto &fetch; }
$core[000105] = 03411; $code[000105] = *I00105; sub I00105 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[000106] = 01022; $code[000106] = *I00106; sub I00106 { $lac += $core[000022]; goto &fetch; }
$core[000107] = 03421; $code[000107] = *I00107; sub I00107 { $core[($df<<12)+$core[17]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[17]] = *emul8; goto &fetch; }
$core[000110] = 01022; $code[000110] = *I00110; sub I00110 { $lac += $core[000022]; goto &fetch; }
$core[000111] = 03023; $code[000111] = *L00111; sub L00111 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[000112] = 01023; $code[000112] = *I00112; sub I00112 { $lac += $core[000023]; goto &fetch; }
$core[000113] = 07001; $code[000113] = *I00113; sub I00113 { $lac++; goto &fetch; }
$core[000114] = 03024; $code[000114] = *I00114; sub I00114 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[000115] = 05407; $code[000115] = *P00115; sub P00115 { $pc = ($ib<<12)+$core[7]; $inh = 0; goto &fetch; }
$core[000116] = 07604; $code[000116] = *L00116; sub L00116 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000117] = 07004; $code[000117] = *I00117; sub I00117 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000120] = 07710; $code[000120] = *I00120; sub I00120 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000121] = 05132; $code[000121] = *I00121; sub I00121 { $pc = 000132; $inh = 0; goto &fetch; }
$core[000122] = 01421; $code[000122] = *I00122; sub I00122 { $lac += $core[($df<<12)+$core[17]]; goto &fetch; }
$core[000123] = 07041; $code[000123] = *I00123; sub I00123 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000124] = 01024; $code[000124] = *I00124; sub I00124 { $lac += $core[000024]; goto &fetch; }
$core[000125] = 07640; $code[000125] = *I00125; sub I00125 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000126] = 05433; $code[000126] = *I00126; sub I00126 { $pc = ($ib<<12)+$core[27]; $inh = 0; goto &fetch; }
$core[000127] = 01421; $code[000127] = *I00127; sub I00127 { $lac += $core[($df<<12)+$core[17]]; goto &fetch; }
$core[000130] = 07650; $code[000130] = *I00130; sub I00130 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000131] = 05433; $code[000131] = *I00131; sub I00131 { $pc = ($ib<<12)+$core[27]; $inh = 0; goto &fetch; }
$core[000132] = 07604; $code[000132] = *L00132; sub L00132 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000133] = 00025; $code[000133] = *I00133; sub I00133 { $lac &= (010000|$core[000025]); goto &fetch; }
$core[000134] = 07650; $code[000134] = *I00134; sub I00134 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000135] = 05047; $code[000135] = *I00135; sub I00135 { $pc = 000047; $inh = 0; goto &fetch; }
$core[000136] = 07001; $code[000136] = *I00136; sub I00136 { $lac++; goto &fetch; }
$core[000137] = 01023; $code[000137] = *I00137; sub I00137 { $lac += $core[000023]; goto &fetch; }
$core[000140] = 05111; $code[000140] = *I00140; sub I00140 { $pc = 000111; $inh = 0; goto &fetch; }
$core[000141] = 07604; $code[000141] = *L00141; sub L00141 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000142] = 07004; $code[000142] = *I00142; sub I00142 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000143] = 07710; $code[000143] = *I00143; sub I00143 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000144] = 05047; $code[000144] = *P00144; sub P00144 { $pc = 000047; $inh = 0; goto &fetch; }
$core[000145] = 01421; $code[000145] = *I00145; sub I00145 { $lac += $core[($df<<12)+$core[17]]; goto &fetch; }
$core[000146] = 07640; $code[000146] = *I00146; sub I00146 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000147] = 05434; $code[000147] = *P00147; sub P00147 { $pc = ($ib<<12)+$core[28]; $inh = 0; goto &fetch; }
$core[000150] = 05047; $code[000150] = *I00150; sub I00150 { $pc = 000047; $inh = 0; goto &fetch; }
$core[000151] = 00000; $code[000151] = *S00151; sub S00151 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000152] = 07510; $code[000152] = *I00152; sub I00152 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000153] = 05160; $code[000153] = *I00153; sub I00153 { $pc = 000160; $inh = 0; goto &fetch; }
$core[000154] = 01003; $code[000154] = *I00154; sub I00154 { $lac += $core[000003]; goto &fetch; }
$core[000155] = 07700; $code[000155] = *I00155; sub I00155 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000156] = 05551; $code[000156] = *I00156; sub I00156 { $pc = ($ib<<12)+$core[105]; $inh = 0; goto &fetch; }
$core[000157] = 05165; $code[000157] = *I00157; sub I00157 { $pc = 000165; $inh = 0; goto &fetch; }
$core[000160] = 01006; $code[000160] = *L00160; sub L00160 { $lac += $core[000006]; goto &fetch; }
$core[000161] = 07700; $code[000161] = *I00161; sub I00161 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000162] = 05165; $code[000162] = *I00162; sub I00162 { $pc = 000165; $inh = 0; goto &fetch; }
$core[000163] = 05551; $code[000163] = *I00163; sub I00163 { $pc = ($ib<<12)+$core[105]; $inh = 0; goto &fetch; }
$core[000164] = 00000; $code[000164] = *S00164; sub S00164 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000165] = 01014; $code[000165] = *L00165; sub L00165 { $lac += $core[000014]; goto &fetch; }
$core[000166] = 07104; $code[000166] = *I00166; sub I00166 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000167] = 07430; $code[000167] = *P00167; sub P00167 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000170] = 01015; $code[000170] = *I00170; sub I00170 { $lac += $core[000015]; goto &fetch; }
$core[000171] = 03014; $code[000171] = *I00171; sub I00171 { $core[000014] = $lac & 07777; $lac &= 010000; $code[000014] = *emul8; goto &fetch; }
$core[000172] = 01014; $code[000172] = *I00172; sub I00172 { $lac += $core[000014]; goto &fetch; }
$core[000173] = 05564; $code[000173] = *I00173; sub I00173 { $pc = ($ib<<12)+$core[116]; $inh = 0; goto &fetch; }
$core[000174] = 01000; $code[000174] = *D00174; sub D00174 { $lac += $core[000000]; goto &fetch; }
$core[000175] = 00000; $code[000175] = *D00175; sub D00175 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000200] = 05040; $code[000200] = *I00200; sub I00200 { $pc = 000040; $inh = 0; goto &fetch; }
$core[000201] = 01340; $code[000201] = *L00201; sub L00201 { $lac += $core[000340]; goto &fetch; }
$core[000202] = 03332; $code[000202] = *I00202; sub I00202 { $core[000332] = $lac & 07777; $lac &= 010000; $code[000332] = *emul8; goto &fetch; }
$core[000203] = 07040; $code[000203] = *I00203; sub I00203 { $lac ^= 07777; goto &fetch; }
$core[000204] = 03031; $code[000204] = *I00204; sub I00204 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[000205] = 05210; $code[000205] = *I00205; sub I00205 { $pc = 000210; $inh = 0; goto &fetch; }
$core[000206] = 01331; $code[000206] = *L00206; sub L00206 { $lac += $core[000331]; goto &fetch; }
$core[000207] = 03332; $code[000207] = *I00207; sub I00207 { $core[000332] = $lac & 07777; $lac &= 010000; $code[000332] = *emul8; goto &fetch; }
$core[000210] = 01002; $code[000210] = *L00210; sub L00210 { $lac += $core[000002]; goto &fetch; }
$core[000211] = 03011; $code[000211] = *I00211; sub I00211 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000212] = 01370; $code[000212] = *D00212; sub D00212 { $lac += $core[000370]; goto &fetch; }
$core[000213] = 04342; $code[000213] = *I00213; sub I00213 { $core[000342] = 00214; $pc = 000342+1; $code[000342] = *emul8; $inh = 0; goto &fetch; }
$core[000214] = 01021; $code[000214] = *I00214; sub I00214 { $lac += $core[000021]; goto &fetch; }
$core[000215] = 03011; $code[000215] = *D00215; sub D00215 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000216] = 01371; $code[000216] = *I00216; sub I00216 { $lac += $core[000371]; goto &fetch; }
$core[000217] = 04342; $code[000217] = *I00217; sub I00217 { $core[000342] = 00220; $pc = 000342+1; $code[000342] = *emul8; $inh = 0; goto &fetch; }
$core[000220] = 01022; $code[000220] = *I00220; sub I00220 { $lac += $core[000022]; goto &fetch; }
$core[000221] = 03011; $code[000221] = *I00221; sub I00221 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000222] = 01372; $code[000222] = *I00222; sub I00222 { $lac += $core[000372]; goto &fetch; }
$core[000223] = 04342; $code[000223] = *I00223; sub I00223 { $core[000342] = 00224; $pc = 000342+1; $code[000342] = *emul8; $inh = 0; goto &fetch; }
$core[000224] = 01023; $code[000224] = *I00224; sub I00224 { $lac += $core[000023]; goto &fetch; }
$core[000225] = 03011; $code[000225] = *I00225; sub I00225 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000226] = 01373; $code[000226] = *I00226; sub I00226 { $lac += $core[000373]; goto &fetch; }
$core[000227] = 04342; $code[000227] = *I00227; sub I00227 { $core[000342] = 00230; $pc = 000342+1; $code[000342] = *emul8; $inh = 0; goto &fetch; }
$core[000230] = 01421; $code[000230] = *I00230; sub I00230 { $lac += $core[($df<<12)+$core[17]]; goto &fetch; }
$core[000231] = 03011; $code[000231] = *I00231; sub I00231 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000232] = 01374; $code[000232] = *I00232; sub I00232 { $lac += $core[000374]; goto &fetch; }
$core[000233] = 04342; $code[000233] = *I00233; sub I00233 { $core[000342] = 00234; $pc = 000342+1; $code[000342] = *emul8; $inh = 0; goto &fetch; }
$core[000234] = 06002; $code[000234] = *I00234; sub I00234 { &emul8; goto &fetch; }
$core[000235] = 01032; $code[000235] = *I00235; sub I00235 { $lac += $core[000032]; goto &fetch; }
$core[000236] = 03011; $code[000236] = *I00236; sub I00236 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000237] = 01411; $code[000237] = *L00237; sub L00237 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[000240] = 06046; $code[000240] = *D00240; sub D00240 { &emul8; goto &fetch; }
$core[000241] = 06041; $code[000241] = *L00241; sub L00241 { &emul8; goto &fetch; }
$core[000242] = 05241; $code[000242] = *I00242; sub I00242 { $pc = 000241; $inh = 0; goto &fetch; }
$core[000243] = 01013; $code[000243] = *I00243; sub I00243 { $lac += $core[000013]; goto &fetch; }
$core[000244] = 07640; $code[000244] = *I00244; sub I00244 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000245] = 05237; $code[000245] = *I00245; sub I00245 { $pc = 000237; $inh = 0; goto &fetch; }
$core[000246] = 06042; $code[000246] = *I00246; sub I00246 { &emul8; goto &fetch; }
$core[000247] = 06001; $code[000247] = *I00247; sub I00247 { &emul8; goto &fetch; }
$core[000250] = 07604; $code[000250] = *I00250; sub I00250 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000251] = 07700; $code[000251] = *I00251; sub I00251 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000252] = 07402; $code[000252] = *I00252; sub I00252 { $hlt = 1; goto &fetch; }
$core[000253] = 01031; $code[000253] = *I00253; sub I00253 { $lac += $core[000031]; goto &fetch; }
$core[000254] = 07650; $code[000254] = *I00254; sub I00254 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000255] = 05047; $code[000255] = *I00255; sub I00255 { $pc = 000047; $inh = 0; goto &fetch; }
$core[000256] = 03031; $code[000256] = *I00256; sub I00256 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[000257] = 05132; $code[000257] = *I00257; sub I00257 { $pc = 000132; $inh = 0; goto &fetch; }
$core[000260] = 00306; $code[000260] = *D00260; sub D00260 { $lac &= (010000|$core[000306]); goto &fetch; }
$core[000261] = 00240; $code[000261] = *D00261; sub D00261 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000262] = 00000; $code[000262] = *I00262; sub I00262 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000263] = 00000; $code[000263] = *I00263; sub I00263 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000264] = 00000; $code[000264] = *I00264; sub I00264 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000265] = 00000; $code[000265] = *I00265; sub I00265 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000266] = 00240; $code[000266] = *I00266; sub I00266 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000267] = 00240; $code[000267] = *I00267; sub I00267 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000270] = 00324; $code[000270] = *I00270; sub I00270 { $lac &= (010000|$core[000324]); goto &fetch; }
$core[000271] = 00240; $code[000271] = *D00271; sub D00271 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000272] = 00000; $code[000272] = *I00272; sub I00272 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000273] = 00000; $code[000273] = *I00273; sub I00273 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000274] = 00000; $code[000274] = *I00274; sub I00274 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000275] = 00000; $code[000275] = *I00275; sub I00275 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000276] = 00215; $code[000276] = *I00276; sub I00276 { $lac &= (010000|$core[000215]); goto &fetch; }
$core[000277] = 00212; $code[000277] = *I00277; sub I00277 { $lac &= (010000|$core[000212]); goto &fetch; }
$core[000300] = 00215; $code[000300] = *I00300; sub I00300 { $lac &= (010000|$core[000215]); goto &fetch; }
$core[000301] = 00215; $code[000301] = *I00301; sub I00301 { $lac &= (010000|$core[000215]); goto &fetch; }
$core[000302] = 00317; $code[000302] = *I00302; sub I00302 { $lac &= (010000|$core[000317]); goto &fetch; }
$core[000303] = 00240; $code[000303] = *D00303; sub D00303 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000304] = 00000; $code[000304] = *I00304; sub I00304 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000305] = 00000; $code[000305] = *I00305; sub I00305 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000306] = 00000; $code[000306] = *D00306; sub D00306 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000307] = 00000; $code[000307] = *I00307; sub I00307 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000310] = 00240; $code[000310] = *I00310; sub I00310 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000311] = 00240; $code[000311] = *I00311; sub I00311 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000312] = 00306; $code[000312] = *I00312; sub I00312 { $lac &= (010000|$core[000306]); goto &fetch; }
$core[000313] = 00240; $code[000313] = *D00313; sub D00313 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000314] = 00000; $code[000314] = *I00314; sub I00314 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000315] = 00000; $code[000315] = *I00315; sub I00315 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000316] = 00000; $code[000316] = *D00316; sub D00316 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000317] = 00000; $code[000317] = *D00317; sub D00317 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000320] = 00240; $code[000320] = *I00320; sub I00320 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000321] = 00240; $code[000321] = *I00321; sub I00321 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000322] = 00322; $code[000322] = *D00322; sub D00322 { $lac &= (010000|$core[000322]); goto &fetch; }
$core[000323] = 00240; $code[000323] = *D00323; sub D00323 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000324] = 00000; $code[000324] = *D00324; sub D00324 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000325] = 00000; $code[000325] = *I00325; sub I00325 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000326] = 00000; $code[000326] = *I00326; sub I00326 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000327] = 00000; $code[000327] = *I00327; sub I00327 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000330] = 00240; $code[000330] = *I00330; sub I00330 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000331] = 00240; $code[000331] = *D00331; sub D00331 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000332] = 00316; $code[000332] = *D00332; sub D00332 { $lac &= (010000|$core[000316]); goto &fetch; }
$core[000333] = 00323; $code[000333] = *I00333; sub I00333 { $lac &= (010000|$core[000323]); goto &fetch; }
$core[000334] = 00215; $code[000334] = *I00334; sub I00334 { $lac &= (010000|$core[000215]); goto &fetch; }
$core[000335] = 00212; $code[000335] = *I00335; sub I00335 { $lac &= (010000|$core[000212]); goto &fetch; }
$core[000336] = 00212; $code[000336] = *I00336; sub I00336 { $lac &= (010000|$core[000212]); goto &fetch; }
$core[000337] = 00377; $code[000337] = *I00337; sub I00337 { $lac &= (010000|$core[000377]); goto &fetch; }
$core[000340] = 00316; $code[000340] = *D00340; sub D00340 { $lac &= (010000|$core[000316]); goto &fetch; }
$core[000341] = 00323; $code[000341] = *I00341; sub I00341 { $lac &= (010000|$core[000323]); goto &fetch; }
$core[000342] = 00000; $code[000342] = *S00342; sub S00342 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000343] = 03012; $code[000343] = *I00343; sub I00343 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[000344] = 01011; $code[000344] = *I00344; sub I00344 { $lac += $core[000011]; goto &fetch; }
$core[000345] = 07006; $code[000345] = *I00345; sub I00345 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000346] = 07006; $code[000346] = *I00346; sub I00346 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000347] = 04362; $code[000347] = *I00347; sub I00347 { $core[000362] = 00350; $pc = 000362+1; $code[000362] = *emul8; $inh = 0; goto &fetch; }
$core[000350] = 07012; $code[000350] = *I00350; sub I00350 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000351] = 07012; $code[000351] = *I00351; sub I00351 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000352] = 07012; $code[000352] = *I00352; sub I00352 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000353] = 04362; $code[000353] = *I00353; sub I00353 { $core[000362] = 00354; $pc = 000362+1; $code[000362] = *emul8; $inh = 0; goto &fetch; }
$core[000354] = 07012; $code[000354] = *I00354; sub I00354 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000355] = 07010; $code[000355] = *I00355; sub I00355 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000356] = 04362; $code[000356] = *I00356; sub I00356 { $core[000362] = 00357; $pc = 000362+1; $code[000362] = *emul8; $inh = 0; goto &fetch; }
$core[000357] = 04362; $code[000357] = *I00357; sub I00357 { $core[000362] = 00360; $pc = 000362+1; $code[000362] = *emul8; $inh = 0; goto &fetch; }
$core[000360] = 07200; $code[000360] = *I00360; sub I00360 { $lac &= 010000; goto &fetch; }
$core[000361] = 05742; $code[000361] = *I00361; sub I00361 { $pc = ($ib<<12)+$core[226]; $inh = 0; goto &fetch; }
$core[000362] = 00000; $code[000362] = *S00362; sub S00362 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000363] = 00010; $code[000363] = *I00363; sub I00363 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[000364] = 01375; $code[000364] = *I00364; sub I00364 { $lac += $core[000375]; goto &fetch; }
$core[000365] = 03412; $code[000365] = *I00365; sub I00365 { $core[000012] = 0000 if ++$core[000012] == 010000; $core[($df<<12)+$core[000012]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000012]] = *emul8; goto &fetch; }
$core[000366] = 01011; $code[000366] = *I00366; sub I00366 { $lac += $core[000011]; goto &fetch; }
$core[000367] = 05762; $code[000367] = *I00367; sub I00367 { $pc = ($ib<<12)+$core[242]; $inh = 0; goto &fetch; }
$core[000370] = 00261; $code[000370] = *D00370; sub D00370 { $lac &= (010000|$core[000261]); goto &fetch; }
$core[000371] = 00271; $code[000371] = *D00371; sub D00371 { $lac &= (010000|$core[000271]); goto &fetch; }
$core[000372] = 00303; $code[000372] = *D00372; sub D00372 { $lac &= (010000|$core[000303]); goto &fetch; }
$core[000373] = 00313; $code[000373] = *D00373; sub D00373 { $lac &= (010000|$core[000313]); goto &fetch; }
$core[000374] = 00323; $code[000374] = *D00374; sub D00374 { $lac &= (010000|$core[000323]); goto &fetch; }
$core[000375] = 00260; $code[000375] = *D00375; sub D00375 { $lac &= (010000|$core[000260]); goto &fetch; }
$core[000400] = 01003; $code[000400] = *L00400; sub L00400 { $lac += $core[000003]; goto &fetch; }
$core[000401] = 07041; $code[000401] = *I00401; sub I00401 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000402] = 03310; $code[000402] = *I00402; sub I00402 { $core[000510] = $lac & 07777; $lac &= 010000; $code[000510] = *emul8; goto &fetch; }
$core[000403] = 01003; $code[000403] = *I00403; sub I00403 { $lac += $core[000003]; goto &fetch; }
$core[000404] = 07040; $code[000404] = *I00404; sub I00404 { $lac ^= 07777; goto &fetch; }
$core[000405] = 03311; $code[000405] = *I00405; sub I00405 { $core[000511] = $lac & 07777; $lac &= 010000; $code[000511] = *emul8; goto &fetch; }
$core[000406] = 01346; $code[000406] = *I00406; sub I00406 { $lac += $core[000546]; goto &fetch; }
$core[000407] = 03313; $code[000407] = *I00407; sub I00407 { $core[000513] = $lac & 07777; $lac &= 010000; $code[000513] = *emul8; goto &fetch; }
$core[000410] = 01314; $code[000410] = *I00410; sub I00410 { $lac += $core[000514]; goto &fetch; }
$core[000411] = 03165; $code[000411] = *I00411; sub I00411 { $core[000165] = $lac & 07777; $lac &= 010000; $code[000165] = *emul8; goto &fetch; }
$core[000412] = 05047; $code[000412] = *D00412; sub D00412 { $pc = 000047; $inh = 0; goto &fetch; }
$core[000413] = 01164; $code[000413] = *L00413; sub L00413 { $lac += $core[000164]; goto &fetch; }
$core[000414] = 07041; $code[000414] = *I00414; sub I00414 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000415] = 01305; $code[000415] = *D00415; sub D00415 { $lac += $core[000505]; goto &fetch; }
$core[000416] = 07650; $code[000416] = *I00416; sub I00416 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000417] = 05303; $code[000417] = *I00417; sub I00417 { $pc = 000503; $inh = 0; goto &fetch; }
$core[000420] = 01164; $code[000420] = *I00420; sub I00420 { $lac += $core[000164]; goto &fetch; }
$core[000421] = 07041; $code[000421] = *I00421; sub I00421 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000422] = 01306; $code[000422] = *I00422; sub I00422 { $lac += $core[000506]; goto &fetch; }
$core[000423] = 07650; $code[000423] = *I00423; sub I00423 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000424] = 05301; $code[000424] = *I00424; sub I00424 { $pc = 000501; $inh = 0; goto &fetch; }
$core[000425] = 05226; $code[000425] = *I00425; sub I00425 { $pc = 000426; $inh = 0; goto &fetch; }
$core[000426] = 01713; $code[000426] = *L00426; sub L00426 { $lac += $core[($df<<12)+$core[331]]; goto &fetch; }
$core[000427] = 03312; $code[000427] = *I00427; sub I00427 { $core[000512] = $lac & 07777; $lac &= 010000; $code[000512] = *emul8; goto &fetch; }
$core[000430] = 01312; $code[000430] = *I00430; sub I00430 { $lac += $core[000512]; goto &fetch; }
$core[000431] = 07450; $code[000431] = *I00431; sub I00431 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000432] = 05240; $code[000432] = *I00432; sub I00432 { $pc = 000440; $inh = 0; goto &fetch; }
$core[000433] = 07201; $code[000433] = *I00433; sub I00433 { $lac &= 010000; $lac++; goto &fetch; }
$core[000434] = 01313; $code[000434] = *I00434; sub I00434 { $lac += $core[000513]; goto &fetch; }
$core[000435] = 03313; $code[000435] = *I00435; sub I00435 { $core[000513] = $lac & 07777; $lac &= 010000; $code[000513] = *emul8; goto &fetch; }
$core[000436] = 01312; $code[000436] = *I00436; sub I00436 { $lac += $core[000512]; goto &fetch; }
$core[000437] = 05564; $code[000437] = *I00437; sub I00437 { $pc = ($ib<<12)+$core[116]; $inh = 0; goto &fetch; }
$core[000440] = 01345; $code[000440] = *L00440; sub L00440 { $lac += $core[000545]; goto &fetch; }
$core[000441] = 03313; $code[000441] = *I00441; sub I00441 { $core[000513] = $lac & 07777; $lac &= 010000; $code[000513] = *emul8; goto &fetch; }
$core[000442] = 07001; $code[000442] = *I00442; sub I00442 { $lac++; goto &fetch; }
$core[000443] = 01311; $code[000443] = *I00443; sub I00443 { $lac += $core[000511]; goto &fetch; }
$core[000444] = 03311; $code[000444] = *I00444; sub I00444 { $core[000511] = $lac & 07777; $lac &= 010000; $code[000511] = *emul8; goto &fetch; }
$core[000445] = 01311; $code[000445] = *I00445; sub I00445 { $lac += $core[000511]; goto &fetch; }
$core[000446] = 07041; $code[000446] = *I00446; sub I00446 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000447] = 01310; $code[000447] = *I00447; sub I00447 { $lac += $core[000510]; goto &fetch; }
$core[000450] = 07640; $code[000450] = *I00450; sub I00450 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000451] = 05255; $code[000451] = *I00451; sub I00451 { $pc = 000455; $inh = 0; goto &fetch; }
$core[000452] = 01311; $code[000452] = *I00452; sub I00452 { $lac += $core[000511]; goto &fetch; }
$core[000453] = 01015; $code[000453] = *I00453; sub I00453 { $lac += $core[000015]; goto &fetch; }
$core[000454] = 03311; $code[000454] = *I00454; sub I00454 { $core[000511] = $lac & 07777; $lac &= 010000; $code[000511] = *emul8; goto &fetch; }
$core[000455] = 01311; $code[000455] = *L00455; sub L00455 { $lac += $core[000511]; goto &fetch; }
$core[000456] = 07500; $code[000456] = *I00456; sub I00456 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000457] = 05276; $code[000457] = *I00457; sub I00457 { $pc = 000476; $inh = 0; goto &fetch; }
$core[000460] = 01006; $code[000460] = *I00460; sub I00460 { $lac += $core[000006]; goto &fetch; }
$core[000461] = 07710; $code[000461] = *I00461; sub I00461 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000462] = 05276; $code[000462] = *I00462; sub I00462 { $pc = 000476; $inh = 0; goto &fetch; }
$core[000463] = 07201; $code[000463] = *I00463; sub I00463 { $lac &= 010000; $lac++; goto &fetch; }
$core[000464] = 01310; $code[000464] = *I00464; sub I00464 { $lac += $core[000510]; goto &fetch; }
$core[000465] = 03310; $code[000465] = *I00465; sub I00465 { $core[000510] = $lac & 07777; $lac &= 010000; $code[000510] = *emul8; goto &fetch; }
$core[000466] = 01003; $code[000466] = *I00466; sub I00466 { $lac += $core[000003]; goto &fetch; }
$core[000467] = 07041; $code[000467] = *I00467; sub I00467 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000470] = 03311; $code[000470] = *I00470; sub I00470 { $core[000511] = $lac & 07777; $lac &= 010000; $code[000511] = *emul8; goto &fetch; }
$core[000471] = 01310; $code[000471] = *I00471; sub I00471 { $lac += $core[000510]; goto &fetch; }
$core[000472] = 01006; $code[000472] = *I00472; sub I00472 { $lac += $core[000006]; goto &fetch; }
$core[000473] = 07710; $code[000473] = *I00473; sub I00473 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000474] = 05276; $code[000474] = *I00474; sub I00474 { $pc = 000476; $inh = 0; goto &fetch; }
$core[000475] = 05200; $code[000475] = *I00475; sub I00475 { $pc = 000400; $inh = 0; goto &fetch; }
$core[000476] = 07200; $code[000476] = *L00476; sub L00476 { $lac &= 010000; goto &fetch; }
$core[000477] = 01312; $code[000477] = *I00477; sub I00477 { $lac += $core[000512]; goto &fetch; }
$core[000500] = 05564; $code[000500] = *I00500; sub I00500 { $pc = ($ib<<12)+$core[116]; $inh = 0; goto &fetch; }
$core[000501] = 01311; $code[000501] = *L00501; sub L00501 { $lac += $core[000511]; goto &fetch; }
$core[000502] = 05564; $code[000502] = *I00502; sub I00502 { $pc = ($ib<<12)+$core[116]; $inh = 0; goto &fetch; }
$core[000503] = 01310; $code[000503] = *L00503; sub L00503 { $lac += $core[000510]; goto &fetch; }
$core[000504] = 05564; $code[000504] = *I00504; sub I00504 { $pc = ($ib<<12)+$core[116]; $inh = 0; goto &fetch; }
$core[000505] = 00072; $code[000505] = *D00505; sub D00505 { $lac &= (010000|$core[000072]); goto &fetch; }
$core[000506] = 00062; $code[000506] = *D00506; sub D00506 { $lac &= (010000|$core[000062]); goto &fetch; }
$core[000507] = 00054; $code[000507] = *I00507; sub I00507 { $lac &= (010000|$core[000054]); goto &fetch; }
$core[000510] = 00000; $code[000510] = *D00510; sub D00510 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000511] = 00000; $code[000511] = *D00511; sub D00511 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000512] = 00000; $code[000512] = *D00512; sub D00512 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000513] = 00000; $code[000513] = *P00513; sub P00513 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000514] = 05435; $code[000514] = *D00514; sub D00514 { $pc = ($ib<<12)+$core[29]; $inh = 0; goto &fetch; }
$core[000515] = 07776; $code[000515] = *I00515; sub I00515 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000516] = 07775; $code[000516] = *I00516; sub I00516 { &emul8; goto &fetch; }
$core[000517] = 07773; $code[000517] = *I00517; sub I00517 { &emul8; goto &fetch; }
$core[000520] = 07767; $code[000520] = *I00520; sub I00520 { &emul8; goto &fetch; }
$core[000521] = 07757; $code[000521] = *I00521; sub I00521 { &emul8; goto &fetch; }
$core[000522] = 07737; $code[000522] = *I00522; sub I00522 { &emul8; goto &fetch; }
$core[000523] = 07677; $code[000523] = *I00523; sub I00523 { &emul8; goto &fetch; }
$core[000524] = 07577; $code[000524] = *I00524; sub I00524 { &emul8; goto &fetch; }
$core[000525] = 07377; $code[000525] = *I00525; sub I00525 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000526] = 06777; $code[000526] = *I00526; sub I00526 { &emul8; goto &fetch; }
$core[000527] = 05777; $code[000527] = *I00527; sub I00527 { $pc = ($ib<<12)+$core[383]; $inh = 0; goto &fetch; }
$core[000530] = 03777; $code[000530] = *I00530; sub I00530 { $core[($df<<12)+$core[383]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[383]] = *emul8; goto &fetch; }
$core[000531] = 00001; $code[000531] = *I00531; sub I00531 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000532] = 00003; $code[000532] = *I00532; sub I00532 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000533] = 00007; $code[000533] = *I00533; sub I00533 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000534] = 00017; $code[000534] = *I00534; sub I00534 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[000535] = 00037; $code[000535] = *I00535; sub I00535 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[000536] = 00077; $code[000536] = *I00536; sub I00536 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[000537] = 00177; $code[000537] = *I00537; sub I00537 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[000540] = 00377; $code[000540] = *I00540; sub I00540 { $lac &= (010000|$core[000577]); goto &fetch; }
$core[000541] = 00777; $code[000541] = *I00541; sub I00541 { $lac &= (010000|$core[($df<<12)+$core[383]]); goto &fetch; }
$core[000542] = 01777; $code[000542] = *I00542; sub I00542 { $lac += $core[($df<<12)+$core[383]]; goto &fetch; }
$core[000543] = 03777; $code[000543] = *I00543; sub I00543 { $core[($df<<12)+$core[383]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[383]] = *emul8; goto &fetch; }
$core[000544] = 00000; $code[000544] = *I00544; sub I00544 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000545] = 00515; $code[000545] = *D00545; sub D00545 { $lac &= (010000|$core[($df<<12)+$core[77]]); goto &fetch; }
$core[000546] = 00544; $code[000546] = *D00546; sub D00546 { $lac &= (010000|$core[($df<<12)+$core[100]]); goto &fetch; }
$core[000547] = 01375; $code[000547] = *L00547; sub L00547 { $lac += $core[000575]; goto &fetch; }
$core[000550] = 07001; $code[000550] = *I00550; sub I00550 { $lac++; goto &fetch; }
$core[000551] = 03375; $code[000551] = *I00551; sub I00551 { $core[000575] = $lac & 07777; $lac &= 010000; $code[000575] = *emul8; goto &fetch; }
$core[000552] = 01375; $code[000552] = *I00552; sub I00552 { $lac += $core[000575]; goto &fetch; }
$core[000553] = 07640; $code[000553] = *I00553; sub I00553 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000554] = 05437; $code[000554] = *I00554; sub I00554 { $pc = ($ib<<12)+$core[31]; $inh = 0; goto &fetch; }
$core[000555] = 01175; $code[000555] = *I00555; sub I00555 { $lac += $core[000175]; goto &fetch; }
$core[000556] = 01174; $code[000556] = *I00556; sub I00556 { $lac += $core[000174]; goto &fetch; }
$core[000557] = 03175; $code[000557] = *I00557; sub I00557 { $core[000175] = $lac & 07777; $lac &= 010000; $code[000175] = *emul8; goto &fetch; }
$core[000560] = 01175; $code[000560] = *I00560; sub I00560 { $lac += $core[000175]; goto &fetch; }
$core[000561] = 07640; $code[000561] = *I00561; sub I00561 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000562] = 05437; $code[000562] = *I00562; sub I00562 { $pc = ($ib<<12)+$core[31]; $inh = 0; goto &fetch; }
$core[000563] = 06002; $code[000563] = *I00563; sub I00563 { &emul8; goto &fetch; }
$core[000564] = 01376; $code[000564] = *I00564; sub I00564 { $lac += $core[000576]; goto &fetch; }
$core[000565] = 03011; $code[000565] = *I00565; sub I00565 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000566] = 05767; $code[000566] = *I00566; sub I00566 { $pc = ($ib<<12)+$core[375]; $inh = 0; goto &fetch; }
$core[000567] = 07602; $code[000567] = *P00567; sub P00567 { $lac &= 010000; $hlt = 1; goto &fetch; }
$core[000570] = 00215; $code[000570] = *I00570; sub I00570 { $lac &= (010000|$core[000415]); goto &fetch; }
$core[000571] = 00212; $code[000571] = *I00571; sub I00571 { $lac &= (010000|$core[000412]); goto &fetch; }
$core[000572] = 00306; $code[000572] = *I00572; sub I00572 { $lac &= (010000|$core[000506]); goto &fetch; }
$core[000573] = 00303; $code[000573] = *I00573; sub I00573 { $lac &= (010000|$core[000503]); goto &fetch; }
$core[000574] = 00377; $code[000574] = *I00574; sub I00574 { $lac &= (010000|$core[000577]); goto &fetch; }
$core[000575] = 00000; $code[000575] = *D00575; sub D00575 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000576] = 00567; $code[000576] = *D00576; sub D00576 { $lac &= (010000|$core[($df<<12)+$core[119]]); goto &fetch; }
$core[000600] = 01021; $code[000600] = *L00600; sub L00600 { $lac += $core[000021]; goto &fetch; }
$core[000601] = 07041; $code[000601] = *I00601; sub I00601 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000602] = 01002; $code[000602] = *I00602; sub I00602 { $lac += $core[000002]; goto &fetch; }
$core[000603] = 07450; $code[000603] = *I00603; sub I00603 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000604] = 05055; $code[000604] = *I00604; sub I00604 { $pc = 000055; $inh = 0; goto &fetch; }
$core[000605] = 07001; $code[000605] = *I00605; sub I00605 { $lac++; goto &fetch; }
$core[000606] = 07450; $code[000606] = *I00606; sub I00606 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000607] = 05055; $code[000607] = *I00607; sub I00607 { $pc = 000055; $inh = 0; goto &fetch; }
$core[000610] = 07001; $code[000610] = *I00610; sub I00610 { $lac++; goto &fetch; }
$core[000611] = 07650; $code[000611] = *I00611; sub I00611 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000612] = 05055; $code[000612] = *I00612; sub I00612 { $pc = 000055; $inh = 0; goto &fetch; }
$core[000613] = 05402; $code[000613] = *I00613; sub I00613 { $pc = ($ib<<12)+$core[2]; $inh = 0; goto &fetch; }
$core[000614] = 00000; $code[000614] = *S00614; sub S00614 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000615] = 03000; $code[000615] = *I00615; sub I00615 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000616] = 01232; $code[000616] = *I00616; sub I00616 { $lac += $core[000632]; goto &fetch; }
$core[000617] = 03001; $code[000617] = *I00617; sub I00617 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[000620] = 01233; $code[000620] = *I00620; sub I00620 { $lac += $core[000633]; goto &fetch; }
$core[000621] = 03002; $code[000621] = *I00621; sub I00621 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[000622] = 01234; $code[000622] = *I00622; sub I00622 { $lac += $core[000634]; goto &fetch; }
$core[000623] = 03003; $code[000623] = *I00623; sub I00623 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[000624] = 01235; $code[000624] = *I00624; sub I00624 { $lac += $core[000635]; goto &fetch; }
$core[000625] = 03040; $code[000625] = *I00625; sub I00625 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[000626] = 01236; $code[000626] = *I00626; sub I00626 { $lac += $core[000636]; goto &fetch; }
$core[000627] = 03041; $code[000627] = *I00627; sub I00627 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[000630] = 06001; $code[000630] = *I00630; sub I00630 { &emul8; goto &fetch; }
$core[000631] = 05614; $code[000631] = *I00631; sub I00631 { $pc = ($ib<<12)+$core[396]; $inh = 0; goto &fetch; }
$core[000632] = 07402; $code[000632] = *D00632; sub D00632 { $hlt = 1; goto &fetch; }
$core[000633] = 00000; $code[000633] = *D00633; sub D00633 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000634] = 07157; $code[000634] = *D00634; sub D00634 { $lac &= 07777; $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000635] = 06001; $code[000635] = *D00635; sub D00635 { &emul8; goto &fetch; }
$core[000636] = 07604; $code[000636] = *D00636; sub D00636 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007602] = 01411; $code[007602] = *L07602; sub L07602 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[007603] = 06046; $code[007603] = *I07603; sub I07603 { &emul8; goto &fetch; }
$core[007604] = 06041; $code[007604] = *L07604; sub L07604 { &emul8; goto &fetch; }
$core[007605] = 05204; $code[007605] = *I07605; sub I07605 { $pc = 007604; $inh = 0; goto &fetch; }
$core[007606] = 01013; $code[007606] = *I07606; sub I07606 { $lac += $core[000013]; goto &fetch; }
$core[007607] = 07640; $code[007607] = *I07607; sub I07607 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007610] = 05202; $code[007610] = *I07610; sub I07610 { $pc = 007602; $inh = 0; goto &fetch; }
$core[007611] = 05217; $code[007611] = *I07611; sub I07611 { $pc = 007617; $inh = 0; goto &fetch; }
$core[007617] = 06042; $code[007617] = *L07617; sub L07617 { &emul8; goto &fetch; }
$core[007620] = 06001; $code[007620] = *I07620; sub I07620 { &emul8; goto &fetch; }
$core[007621] = 05437; $code[007621] = *I07621; sub I07621 { $pc = ($ib<<12)+$core[31]; $inh = 0; goto &fetch; }
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

