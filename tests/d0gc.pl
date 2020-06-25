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
$core[000005] = 00000; $code[000005] = *I00005; sub I00005 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000006] = 07771; $code[000006] = *D00006; sub D00006 { &emul8; goto &fetch; }
$core[000007] = 00400; $code[000007] = *P00007; sub P00007 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000010] = 00000; $code[000010] = *P00010; sub P00010 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000011] = 00000; $code[000011] = *D00011; sub D00011 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000012] = 00300; $code[000012] = *D00012; sub D00012 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000013] = 00207; $code[000013] = *D00013; sub D00013 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000014] = 00003; $code[000014] = *D00014; sub D00014 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000020] = 01175; $code[000020] = *L00020; sub L00020 { $lac += $core[000175]; goto &fetch; }
$core[000021] = 03010; $code[000021] = *I00021; sub I00021 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000022] = 03410; $code[000022] = *L00022; sub L00022 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000023] = 01010; $code[000023] = *I00023; sub I00023 { $lac += $core[000010]; goto &fetch; }
$core[000024] = 07041; $code[000024] = *I00024; sub I00024 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000025] = 01174; $code[000025] = *I00025; sub I00025 { $lac += $core[000174]; goto &fetch; }
$core[000026] = 07640; $code[000026] = *I00026; sub I00026 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000027] = 05022; $code[000027] = *I00027; sub I00027 { $pc = 000022; $inh = 0; goto &fetch; }
$core[000030] = 07604; $code[000030] = *L00030; sub L00030 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000031] = 07006; $code[000031] = *I00031; sub I00031 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000032] = 07510; $code[000032] = *I00032; sub I00032 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000033] = 05052; $code[000033] = *I00033; sub I00033 { $pc = 000052; $inh = 0; goto &fetch; }
$core[000034] = 04154; $code[000034] = *L00034; sub L00034 { $core[000154] = 00035; $pc = 000154+1; $code[000154] = *emul8; $inh = 0; goto &fetch; }
$core[000035] = 03167; $code[000035] = *I00035; sub I00035 { $core[000167] = $lac & 07777; $lac &= 010000; $code[000167] = *emul8; goto &fetch; }
$core[000036] = 01167; $code[000036] = *I00036; sub I00036 { $lac += $core[000167]; goto &fetch; }
$core[000037] = 07510; $code[000037] = *I00037; sub I00037 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000040] = 05046; $code[000040] = *I00040; sub I00040 { $pc = 000046; $inh = 0; goto &fetch; }
$core[000041] = 07041; $code[000041] = *I00041; sub I00041 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000042] = 01175; $code[000042] = *I00042; sub I00042 { $lac += $core[000175]; goto &fetch; }
$core[000043] = 07710; $code[000043] = *I00043; sub I00043 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000044] = 05052; $code[000044] = *I00044; sub I00044 { $pc = 000052; $inh = 0; goto &fetch; }
$core[000045] = 05034; $code[000045] = *I00045; sub I00045 { $pc = 000034; $inh = 0; goto &fetch; }
$core[000046] = 07041; $code[000046] = *L00046; sub L00046 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000047] = 01174; $code[000047] = *I00047; sub I00047 { $lac += $core[000174]; goto &fetch; }
$core[000050] = 07710; $code[000050] = *I00050; sub I00050 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000051] = 05034; $code[000051] = *I00051; sub I00051 { $pc = 000034; $inh = 0; goto &fetch; }
$core[000052] = 07604; $code[000052] = *L00052; sub L00052 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000053] = 07006; $code[000053] = *I00053; sub I00053 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000054] = 07004; $code[000054] = *I00054; sub I00054 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000055] = 07510; $code[000055] = *I00055; sub I00055 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000056] = 05075; $code[000056] = *I00056; sub I00056 { $pc = 000075; $inh = 0; goto &fetch; }
$core[000057] = 04154; $code[000057] = *L00057; sub L00057 { $core[000154] = 00060; $pc = 000154+1; $code[000154] = *emul8; $inh = 0; goto &fetch; }
$core[000060] = 03166; $code[000060] = *I00060; sub I00060 { $core[000166] = $lac & 07777; $lac &= 010000; $code[000166] = *emul8; goto &fetch; }
$core[000061] = 01166; $code[000061] = *I00061; sub I00061 { $lac += $core[000166]; goto &fetch; }
$core[000062] = 07510; $code[000062] = *I00062; sub I00062 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000063] = 05071; $code[000063] = *I00063; sub I00063 { $pc = 000071; $inh = 0; goto &fetch; }
$core[000064] = 07041; $code[000064] = *I00064; sub I00064 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000065] = 01175; $code[000065] = *I00065; sub I00065 { $lac += $core[000175]; goto &fetch; }
$core[000066] = 07710; $code[000066] = *I00066; sub I00066 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000067] = 05075; $code[000067] = *I00067; sub I00067 { $pc = 000075; $inh = 0; goto &fetch; }
$core[000070] = 05057; $code[000070] = *I00070; sub I00070 { $pc = 000057; $inh = 0; goto &fetch; }
$core[000071] = 07041; $code[000071] = *L00071; sub L00071 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000072] = 01174; $code[000072] = *I00072; sub I00072 { $lac += $core[000174]; goto &fetch; }
$core[000073] = 07710; $code[000073] = *I00073; sub I00073 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000074] = 05057; $code[000074] = *I00074; sub I00074 { $pc = 000057; $inh = 0; goto &fetch; }
$core[000075] = 07604; $code[000075] = *L00075; sub L00075 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000076] = 07006; $code[000076] = *I00076; sub I00076 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000077] = 07006; $code[000077] = *I00077; sub I00077 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000100] = 07710; $code[000100] = *D00100; sub D00100 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000101] = 05104; $code[000101] = *I00101; sub I00101 { $pc = 000104; $inh = 0; goto &fetch; }
$core[000102] = 04154; $code[000102] = *I00102; sub I00102 { $core[000154] = 00103; $pc = 000154+1; $code[000154] = *emul8; $inh = 0; goto &fetch; }
$core[000103] = 03170; $code[000103] = *I00103; sub I00103 { $core[000170] = $lac & 07777; $lac &= 010000; $code[000170] = *emul8; goto &fetch; }
$core[000104] = 01167; $code[000104] = *L00104; sub L00104 { $lac += $core[000167]; goto &fetch; }
$core[000105] = 07041; $code[000105] = *I00105; sub I00105 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000106] = 01166; $code[000106] = *I00106; sub I00106 { $lac += $core[000166]; goto &fetch; }
$core[000107] = 07450; $code[000107] = *I00107; sub I00107 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000110] = 05030; $code[000110] = *I00110; sub I00110 { $pc = 000030; $inh = 0; goto &fetch; }
$core[000111] = 07041; $code[000111] = *I00111; sub I00111 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000112] = 07040; $code[000112] = *I00112; sub I00112 { $lac ^= 07777; goto &fetch; }
$core[000113] = 07650; $code[000113] = *I00113; sub I00113 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000114] = 05030; $code[000114] = *I00114; sub I00114 { $pc = 000030; $inh = 0; goto &fetch; }
$core[000115] = 01171; $code[000115] = *I00115; sub I00115 { $lac += $core[000171]; goto &fetch; }
$core[000116] = 03567; $code[000116] = *I00116; sub I00116 { $core[($df<<12)+$core[119]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[119]] = *emul8; goto &fetch; }
$core[000117] = 01167; $code[000117] = *I00117; sub I00117 { $lac += $core[000167]; goto &fetch; }
$core[000120] = 07001; $code[000120] = *I00120; sub I00120 { $lac++; goto &fetch; }
$core[000121] = 03173; $code[000121] = *I00121; sub I00121 { $core[000173] = $lac & 07777; $lac &= 010000; $code[000173] = *emul8; goto &fetch; }
$core[000122] = 01172; $code[000122] = *I00122; sub I00122 { $lac += $core[000172]; goto &fetch; }
$core[000123] = 03573; $code[000123] = *I00123; sub I00123 { $core[($df<<12)+$core[123]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[123]] = *emul8; goto &fetch; }
$core[000124] = 01170; $code[000124] = *I00124; sub I00124 { $lac += $core[000170]; goto &fetch; }
$core[000125] = 07000; $code[000125] = *P00125; sub P00125 { goto &fetch; }
$core[000126] = 05567; $code[000126] = *I00126; sub I00126 { $pc = ($ib<<12)+$core[119]; $inh = 0; goto &fetch; }
$core[000127] = 07402; $code[000127] = *I00127; sub I00127 { $hlt = 1; goto &fetch; }
$core[000130] = 01566; $code[000130] = *L00130; sub L00130 { $lac += $core[($df<<12)+$core[118]]; goto &fetch; }
$core[000131] = 07041; $code[000131] = *I00131; sub I00131 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000132] = 01170; $code[000132] = *I00132; sub I00132 { $lac += $core[000170]; goto &fetch; }
$core[000133] = 07640; $code[000133] = *I00133; sub I00133 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000134] = 04577; $code[000134] = *I00134; sub I00134 { $core[($ib<<12)+$core[127]] = 00135; $pc = ($ib<<12)+$core[127]+1; $code[($ib<<12)+$core[127]] = *emul8; $inh = 0; goto &fetch; }
$core[000135] = 03566; $code[000135] = *I00135; sub I00135 { $core[($df<<12)+$core[118]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[118]] = *emul8; goto &fetch; }
$core[000136] = 03567; $code[000136] = *I00136; sub I00136 { $core[($df<<12)+$core[119]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[119]] = *emul8; goto &fetch; }
$core[000137] = 03573; $code[000137] = *I00137; sub I00137 { $core[($df<<12)+$core[123]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[123]] = *emul8; goto &fetch; }
$core[000140] = 01011; $code[000140] = *I00140; sub I00140 { $lac += $core[000011]; goto &fetch; }
$core[000141] = 07001; $code[000141] = *I00141; sub I00141 { $lac++; goto &fetch; }
$core[000142] = 03011; $code[000142] = *I00142; sub I00142 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000143] = 01011; $code[000143] = *I00143; sub I00143 { $lac += $core[000011]; goto &fetch; }
$core[000144] = 01012; $code[000144] = *I00144; sub I00144 { $lac += $core[000012]; goto &fetch; }
$core[000145] = 07640; $code[000145] = *I00145; sub I00145 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000146] = 05030; $code[000146] = *I00146; sub I00146 { $pc = 000030; $inh = 0; goto &fetch; }
$core[000147] = 03011; $code[000147] = *I00147; sub I00147 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000150] = 02006; $code[000150] = *I00150; sub I00150 { if (++$core[000006] == 010000) { $core[000006] = 0; $pc++; }$code[000006] = *emul8; goto &fetch; }
$core[000151] = 05030; $code[000151] = *I00151; sub I00151 { $pc = 000030; $inh = 0; goto &fetch; }
$core[000152] = 04407; $code[000152] = *I00152; sub I00152 { $core[($ib<<12)+$core[7]] = 00153; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[000153] = 05030; $code[000153] = *I00153; sub I00153 { &emul8; goto &fetch; }
$core[000154] = 00000; $code[000154] = *S00154; sub S00154 { &emul8; goto &fetch; }
$core[000155] = 07200; $code[000155] = *I00155; sub I00155 { $lac &= 010000; goto &fetch; }
$core[000156] = 01165; $code[000156] = *I00156; sub I00156 { $lac += $core[000165]; goto &fetch; }
$core[000157] = 07104; $code[000157] = *I00157; sub I00157 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000160] = 07430; $code[000160] = *I00160; sub I00160 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000161] = 01014; $code[000161] = *I00161; sub I00161 { $lac += $core[000014]; goto &fetch; }
$core[000162] = 03165; $code[000162] = *I00162; sub I00162 { $core[000165] = $lac & 07777; $lac &= 010000; $code[000165] = *emul8; goto &fetch; }
$core[000163] = 01165; $code[000163] = *I00163; sub I00163 { $lac += $core[000165]; goto &fetch; }
$core[000164] = 05554; $code[000164] = *I00164; sub I00164 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[000165] = 02525; $code[000165] = *D00165; sub D00165 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[000166] = 03000; $code[000166] = *P00166; sub P00166 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000167] = 03001; $code[000167] = *P00167; sub P00167 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[000170] = 02525; $code[000170] = *D00170; sub D00170 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[000171] = 03566; $code[000171] = *D00171; sub D00171 { $core[($df<<12)+$core[118]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[118]] = *emul8; goto &fetch; }
$core[000172] = 05130; $code[000172] = *D00172; sub D00172 { $pc = 000130; $inh = 0; goto &fetch; }
$core[000173] = 03002; $code[000173] = *P00173; sub P00173 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[000174] = 07600; $code[000174] = *D00174; sub D00174 { $lac &= 010000; goto &fetch; }
$core[000175] = 00410; $code[000175] = *D00175; sub D00175 { $core[000010] = 0000 if ++$core[000010] == 010000; $lac &= (010000|$core[($df<<12)+$core[000010]]); goto &fetch; }
$core[000176] = 00000; $code[000176] = *P00176; sub P00176 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000177] = 00201; $code[000177] = *P00177; sub P00177 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000200] = 05020; $code[000200] = *I00200; sub I00200 { $pc = 000020; $inh = 0; goto &fetch; }
$core[000201] = 00000; $code[000201] = *S00201; sub S00201 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000202] = 07604; $code[000202] = *I00202; sub I00202 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000203] = 07004; $code[000203] = *I00203; sub I00203 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000204] = 07710; $code[000204] = *I00204; sub I00204 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000205] = 05601; $code[000205] = *I00205; sub I00205 { $pc = ($ib<<12)+$core[129]; $inh = 0; goto &fetch; }
$core[000206] = 04265; $code[000206] = *I00206; sub I00206 { $core[000265] = 00207; $pc = 000265+1; $code[000265] = *emul8; $inh = 0; goto &fetch; }
$core[000207] = 01175; $code[000207] = *I00207; sub I00207 { $lac += $core[000175]; goto &fetch; }
$core[000210] = 03010; $code[000210] = *I00210; sub I00210 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000211] = 01410; $code[000211] = *L00211; sub L00211 { $core[000010] = 0000 if ++$core[000010] == 010000; $lac += $core[($df<<12)+$core[000010]]; goto &fetch; }
$core[000212] = 07640; $code[000212] = *D00212; sub D00212 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000213] = 04233; $code[000213] = *I00213; sub I00213 { $core[000233] = 00214; $pc = 000233+1; $code[000233] = *emul8; $inh = 0; goto &fetch; }
$core[000214] = 01010; $code[000214] = *I00214; sub I00214 { $lac += $core[000010]; goto &fetch; }
$core[000215] = 07041; $code[000215] = *D00215; sub D00215 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000216] = 01174; $code[000216] = *I00216; sub I00216 { $lac += $core[000174]; goto &fetch; }
$core[000217] = 07640; $code[000217] = *I00217; sub I00217 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000220] = 05211; $code[000220] = *I00220; sub I00220 { $pc = 000211; $inh = 0; goto &fetch; }
$core[000221] = 01374; $code[000221] = *I00221; sub I00221 { $lac += $core[000374]; goto &fetch; }
$core[000222] = 04351; $code[000222] = *I00222; sub I00222 { $core[000351] = 00223; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000223] = 01375; $code[000223] = *I00223; sub I00223 { $lac += $core[000375]; goto &fetch; }
$core[000224] = 04351; $code[000224] = *I00224; sub I00224 { $core[000351] = 00225; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000225] = 01376; $code[000225] = *I00225; sub I00225 { $lac += $core[000376]; goto &fetch; }
$core[000226] = 04351; $code[000226] = *I00226; sub I00226 { $core[000351] = 00227; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000227] = 07604; $code[000227] = *I00227; sub I00227 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000230] = 07700; $code[000230] = *I00230; sub I00230 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000231] = 07402; $code[000231] = *I00231; sub I00231 { $hlt = 1; goto &fetch; }
$core[000232] = 05601; $code[000232] = *I00232; sub I00232 { $pc = ($ib<<12)+$core[129]; $inh = 0; goto &fetch; }
$core[000233] = 00000; $code[000233] = *S00233; sub S00233 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000234] = 01010; $code[000234] = *I00234; sub I00234 { $lac += $core[000010]; goto &fetch; }
$core[000235] = 07041; $code[000235] = *I00235; sub I00235 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000236] = 01167; $code[000236] = *I00236; sub I00236 { $lac += $core[000167]; goto &fetch; }
$core[000237] = 07650; $code[000237] = *I00237; sub I00237 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000240] = 05633; $code[000240] = *D00240; sub D00240 { $pc = ($ib<<12)+$core[155]; $inh = 0; goto &fetch; }
$core[000241] = 01010; $code[000241] = *I00241; sub I00241 { $lac += $core[000010]; goto &fetch; }
$core[000242] = 07041; $code[000242] = *I00242; sub I00242 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000243] = 01173; $code[000243] = *I00243; sub I00243 { $lac += $core[000173]; goto &fetch; }
$core[000244] = 07650; $code[000244] = *I00244; sub I00244 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000245] = 05633; $code[000245] = *I00245; sub I00245 { $pc = ($ib<<12)+$core[155]; $inh = 0; goto &fetch; }
$core[000246] = 01372; $code[000246] = *I00246; sub I00246 { $lac += $core[000372]; goto &fetch; }
$core[000247] = 04351; $code[000247] = *I00247; sub I00247 { $core[000351] = 00250; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000250] = 01010; $code[000250] = *I00250; sub I00250 { $lac += $core[000010]; goto &fetch; }
$core[000251] = 04310; $code[000251] = *I00251; sub I00251 { $core[000310] = 00252; $pc = 000310+1; $code[000310] = *emul8; $inh = 0; goto &fetch; }
$core[000252] = 01010; $code[000252] = *I00252; sub I00252 { $lac += $core[000010]; goto &fetch; }
$core[000253] = 03176; $code[000253] = *I00253; sub I00253 { $core[000176] = $lac & 07777; $lac &= 010000; $code[000176] = *emul8; goto &fetch; }
$core[000254] = 01373; $code[000254] = *I00254; sub I00254 { $lac += $core[000373]; goto &fetch; }
$core[000255] = 04351; $code[000255] = *I00255; sub I00255 { $core[000351] = 00256; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000256] = 01576; $code[000256] = *I00256; sub I00256 { $lac += $core[($df<<12)+$core[126]]; goto &fetch; }
$core[000257] = 04310; $code[000257] = *I00257; sub I00257 { $core[000310] = 00260; $pc = 000310+1; $code[000310] = *emul8; $inh = 0; goto &fetch; }
$core[000260] = 01375; $code[000260] = *D00260; sub D00260 { $lac += $core[000375]; goto &fetch; }
$core[000261] = 04351; $code[000261] = *I00261; sub I00261 { $core[000351] = 00262; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000262] = 01376; $code[000262] = *I00262; sub I00262 { $lac += $core[000376]; goto &fetch; }
$core[000263] = 04351; $code[000263] = *I00263; sub I00263 { $core[000351] = 00264; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000264] = 05633; $code[000264] = *I00264; sub I00264 { $pc = ($ib<<12)+$core[155]; $inh = 0; goto &fetch; }
$core[000265] = 00000; $code[000265] = *S00265; sub S00265 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000266] = 07200; $code[000266] = *I00266; sub I00266 { $lac &= 010000; goto &fetch; }
$core[000267] = 01367; $code[000267] = *I00267; sub I00267 { $lac += $core[000367]; goto &fetch; }
$core[000270] = 04351; $code[000270] = *I00270; sub I00270 { $core[000351] = 00271; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000271] = 01167; $code[000271] = *I00271; sub I00271 { $lac += $core[000167]; goto &fetch; }
$core[000272] = 04310; $code[000272] = *I00272; sub I00272 { $core[000310] = 00273; $pc = 000310+1; $code[000310] = *emul8; $inh = 0; goto &fetch; }
$core[000273] = 01371; $code[000273] = *I00273; sub I00273 { $lac += $core[000371]; goto &fetch; }
$core[000274] = 04351; $code[000274] = *I00274; sub I00274 { $core[000351] = 00275; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000275] = 01166; $code[000275] = *I00275; sub I00275 { $lac += $core[000166]; goto &fetch; }
$core[000276] = 04310; $code[000276] = *I00276; sub I00276 { $core[000310] = 00277; $pc = 000310+1; $code[000310] = *emul8; $inh = 0; goto &fetch; }
$core[000277] = 01377; $code[000277] = *I00277; sub I00277 { $lac += $core[000377]; goto &fetch; }
$core[000300] = 04351; $code[000300] = *I00300; sub I00300 { $core[000351] = 00301; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000301] = 01170; $code[000301] = *D00301; sub D00301 { $lac += $core[000170]; goto &fetch; }
$core[000302] = 04310; $code[000302] = *I00302; sub I00302 { $core[000310] = 00303; $pc = 000310+1; $code[000310] = *emul8; $inh = 0; goto &fetch; }
$core[000303] = 01375; $code[000303] = *D00303; sub D00303 { $lac += $core[000375]; goto &fetch; }
$core[000304] = 04351; $code[000304] = *I00304; sub I00304 { $core[000351] = 00305; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000305] = 01376; $code[000305] = *D00305; sub D00305 { $lac += $core[000376]; goto &fetch; }
$core[000306] = 04351; $code[000306] = *D00306; sub D00306 { $core[000351] = 00307; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000307] = 05665; $code[000307] = *I00307; sub I00307 { $pc = ($ib<<12)+$core[181]; $inh = 0; goto &fetch; }
$core[000310] = 05310; $code[000310] = *P00310; sub P00310 { $pc = 000310; $inh = 0; goto &fetch; }
$core[000311] = 03366; $code[000311] = *I00311; sub I00311 { $core[000366] = $lac & 07777; $lac &= 010000; $code[000366] = *emul8; goto &fetch; }
$core[000312] = 01366; $code[000312] = *I00312; sub I00312 { $lac += $core[000366]; goto &fetch; }
$core[000313] = 07012; $code[000313] = *I00313; sub I00313 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000314] = 07010; $code[000314] = *D00314; sub D00314 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000315] = 03365; $code[000315] = *I00315; sub I00315 { $core[000365] = $lac & 07777; $lac &= 010000; $code[000365] = *emul8; goto &fetch; }
$core[000316] = 01365; $code[000316] = *I00316; sub I00316 { $lac += $core[000365]; goto &fetch; }
$core[000317] = 07012; $code[000317] = *D00317; sub D00317 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000320] = 07010; $code[000320] = *I00320; sub I00320 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000321] = 03364; $code[000321] = *I00321; sub I00321 { $core[000364] = $lac & 07777; $lac &= 010000; $code[000364] = *emul8; goto &fetch; }
$core[000322] = 01364; $code[000322] = *I00322; sub I00322 { $lac += $core[000364]; goto &fetch; }
$core[000323] = 07012; $code[000323] = *I00323; sub I00323 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000324] = 07010; $code[000324] = *I00324; sub I00324 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000325] = 03363; $code[000325] = *I00325; sub I00325 { $core[000363] = $lac & 07777; $lac &= 010000; $code[000363] = *emul8; goto &fetch; }
$core[000326] = 01370; $code[000326] = *I00326; sub I00326 { $lac += $core[000370]; goto &fetch; }
$core[000327] = 04351; $code[000327] = *I00327; sub I00327 { $core[000351] = 00330; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000330] = 01357; $code[000330] = *I00330; sub I00330 { $lac += $core[000357]; goto &fetch; }
$core[000331] = 03360; $code[000331] = *I00331; sub I00331 { $core[000360] = $lac & 07777; $lac &= 010000; $code[000360] = *emul8; goto &fetch; }
$core[000332] = 01363; $code[000332] = *L00332; sub L00332 { $lac += $core[000363]; goto &fetch; }
$core[000333] = 00361; $code[000333] = *I00333; sub I00333 { $lac &= (010000|$core[000361]); goto &fetch; }
$core[000334] = 01362; $code[000334] = *I00334; sub I00334 { $lac += $core[000362]; goto &fetch; }
$core[000335] = 04351; $code[000335] = *I00335; sub I00335 { $core[000351] = 00336; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000336] = 01364; $code[000336] = *I00336; sub I00336 { $lac += $core[000364]; goto &fetch; }
$core[000337] = 03363; $code[000337] = *I00337; sub I00337 { $core[000363] = $lac & 07777; $lac &= 010000; $code[000363] = *emul8; goto &fetch; }
$core[000340] = 01365; $code[000340] = *I00340; sub I00340 { $lac += $core[000365]; goto &fetch; }
$core[000341] = 03364; $code[000341] = *I00341; sub I00341 { $core[000364] = $lac & 07777; $lac &= 010000; $code[000364] = *emul8; goto &fetch; }
$core[000342] = 01366; $code[000342] = *I00342; sub I00342 { $lac += $core[000366]; goto &fetch; }
$core[000343] = 03365; $code[000343] = *I00343; sub I00343 { $core[000365] = $lac & 07777; $lac &= 010000; $code[000365] = *emul8; goto &fetch; }
$core[000344] = 02360; $code[000344] = *I00344; sub I00344 { if (++$core[000360] == 010000) { $core[000360] = 0; $pc++; }$code[000360] = *emul8; goto &fetch; }
$core[000345] = 05332; $code[000345] = *I00345; sub I00345 { $pc = 000332; $inh = 0; goto &fetch; }
$core[000346] = 01370; $code[000346] = *I00346; sub I00346 { $lac += $core[000370]; goto &fetch; }
$core[000347] = 04351; $code[000347] = *I00347; sub I00347 { $core[000351] = 00350; $pc = 000351+1; $code[000351] = *emul8; $inh = 0; goto &fetch; }
$core[000350] = 05710; $code[000350] = *I00350; sub I00350 { $pc = ($ib<<12)+$core[200]; $inh = 0; goto &fetch; }
$core[000351] = 00000; $code[000351] = *S00351; sub S00351 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000352] = 06046; $code[000352] = *I00352; sub I00352 { &emul8; goto &fetch; }
$core[000353] = 06041; $code[000353] = *L00353; sub L00353 { &emul8; goto &fetch; }
$core[000354] = 05353; $code[000354] = *I00354; sub I00354 { $pc = 000353; $inh = 0; goto &fetch; }
$core[000355] = 07200; $code[000355] = *I00355; sub I00355 { $lac &= 010000; goto &fetch; }
$core[000356] = 05751; $code[000356] = *I00356; sub I00356 { $pc = ($ib<<12)+$core[233]; $inh = 0; goto &fetch; }
$core[000357] = 07774; $code[000357] = *D00357; sub D00357 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000360] = 00000; $code[000360] = *D00360; sub D00360 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000361] = 00007; $code[000361] = *D00361; sub D00361 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000362] = 00260; $code[000362] = *D00362; sub D00362 { $lac &= (010000|$core[000260]); goto &fetch; }
$core[000363] = 00000; $code[000363] = *D00363; sub D00363 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000364] = 00000; $code[000364] = *D00364; sub D00364 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000365] = 00000; $code[000365] = *D00365; sub D00365 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000366] = 00000; $code[000366] = *D00366; sub D00366 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000367] = 00306; $code[000367] = *D00367; sub D00367 { $lac &= (010000|$core[000306]); goto &fetch; }
$core[000370] = 00240; $code[000370] = *D00370; sub D00370 { $lac &= (010000|$core[000240]); goto &fetch; }
$core[000371] = 00301; $code[000371] = *D00371; sub D00371 { $lac &= (010000|$core[000301]); goto &fetch; }
$core[000372] = 00314; $code[000372] = *D00372; sub D00372 { $lac &= (010000|$core[000314]); goto &fetch; }
$core[000373] = 00303; $code[000373] = *D00373; sub D00373 { $lac &= (010000|$core[000303]); goto &fetch; }
$core[000374] = 00305; $code[000374] = *D00374; sub D00374 { $lac &= (010000|$core[000305]); goto &fetch; }
$core[000375] = 00215; $code[000375] = *D00375; sub D00375 { $lac &= (010000|$core[000215]); goto &fetch; }
$core[000376] = 00212; $code[000376] = *D00376; sub D00376 { $lac &= (010000|$core[000212]); goto &fetch; }
$core[000377] = 00317; $code[000377] = *D00377; sub D00377 { $lac &= (010000|$core[000317]); goto &fetch; }
$core[000400] = 00000; $code[000400] = *S00400; sub S00400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000401] = 01207; $code[000401] = *I00401; sub I00401 { $lac += $core[000407]; goto &fetch; }
$core[000402] = 03006; $code[000402] = *I00402; sub I00402 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[000403] = 01013; $code[000403] = *I00403; sub I00403 { $lac += $core[000013]; goto &fetch; }
$core[000404] = 06046; $code[000404] = *I00404; sub I00404 { &emul8; goto &fetch; }
$core[000405] = 07200; $code[000405] = *I00405; sub I00405 { $lac &= 010000; goto &fetch; }
$core[000406] = 05600; $code[000406] = *I00406; sub I00406 { $pc = ($ib<<12)+$core[256]; $inh = 0; goto &fetch; }
$core[000407] = 07771; $code[000407] = *D00407; sub D00407 { &emul8; goto &fetch; }
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

