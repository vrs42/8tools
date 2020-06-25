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
$core[000003] = 00003; $code[000003] = *P00003; sub P00003 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000004] = 00000; $code[000004] = *D00004; sub D00004 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000005] = 00000; $code[000005] = *P00005; sub P00005 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000006] = 00000; $code[000006] = *D00006; sub D00006 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000007] = 00000; $code[000007] = *D00007; sub D00007 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000020] = 00000; $code[000020] = *P00020; sub P00020 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000021] = 04400; $code[000021] = *D00021; sub D00021 { $core[($ib<<12)+$core[0]] = 00022; $pc = ($ib<<12)+$core[0]+1; $code[($ib<<12)+$core[0]] = *emul8; $inh = 0; goto &fetch; }
$core[000022] = 00234; $code[000022] = *P00022; sub P00022 { $lac &= (010000|$core[000034]); goto &fetch; }
$core[000023] = 00274; $code[000023] = *P00023; sub P00023 { $lac &= (010000|$core[000074]); goto &fetch; }
$core[000024] = 01565; $code[000024] = *P00024; sub P00024 { $lac += $core[($df<<12)+$core[117]]; goto &fetch; }
$core[000025] = 00200; $code[000025] = *D00025; sub D00025 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000026] = 00400; $code[000026] = *P00026; sub P00026 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000027] = 00326; $code[000027] = *P00027; sub P00027 { $lac &= (010000|$core[000126]); goto &fetch; }
$core[000030] = 01200; $code[000030] = *P00030; sub P00030 { $lac += $core[000000]; goto &fetch; }
$core[000031] = 01400; $code[000031] = *P00031; sub P00031 { $lac += $core[($df<<12)+$core[0]]; goto &fetch; }
$core[000032] = 01650; $code[000032] = *P00032; sub P00032 { $lac += $core[($df<<12)+$core[40]]; goto &fetch; }
$core[000033] = 01676; $code[000033] = *P00033; sub P00033 { $lac += $core[($df<<12)+$core[62]]; goto &fetch; }
$core[000034] = 01600; $code[000034] = *P00034; sub P00034 { $lac += $core[($df<<12)+$core[0]]; goto &fetch; }
$core[000035] = 01610; $code[000035] = *P00035; sub P00035 { $core[000010] = 0000 if ++$core[000010] == 010000; $lac += $core[($df<<12)+$core[000010]]; goto &fetch; }
$core[000036] = 01620; $code[000036] = *P00036; sub P00036 { $lac += $core[($df<<12)+$core[16]]; goto &fetch; }
$core[000037] = 01630; $code[000037] = *P00037; sub P00037 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[000040] = 01640; $code[000040] = *P00040; sub P00040 { $lac += $core[($df<<12)+$core[32]]; goto &fetch; }
$core[000041] = 02464; $code[000041] = *P00041; sub P00041 { if (++$core[($df<<12)+$core[52]] == 010000) { $core[($df<<12)+$core[52]] = 0; $pc++; }$code[($df<<12)+$core[52]] = *emul8; goto &fetch; }
$core[000042] = 02600; $code[000042] = *P00042; sub P00042 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[000043] = 01726; $code[000043] = *P00043; sub P00043 { $lac += $core[($df<<12)+$core[86]]; goto &fetch; }
$core[000044] = 01732; $code[000044] = *P00044; sub P00044 { $lac += $core[($df<<12)+$core[90]]; goto &fetch; }
$core[000045] = 01736; $code[000045] = *P00045; sub P00045 { $lac += $core[($df<<12)+$core[94]]; goto &fetch; }
$core[000046] = 01753; $code[000046] = *P00046; sub P00046 { $lac += $core[($df<<12)+$core[107]]; goto &fetch; }
$core[000047] = 02000; $code[000047] = *P00047; sub P00047 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[000050] = 01771; $code[000050] = *P00050; sub P00050 { $lac += $core[($df<<12)+$core[121]]; goto &fetch; }
$core[000051] = 02064; $code[000051] = *P00051; sub P00051 { if (++$core[000064] == 010000) { $core[000064] = 0; $pc++; }$code[000064] = *emul8; goto &fetch; }
$core[000052] = 02200; $code[000052] = *P00052; sub P00052 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[000053] = 02145; $code[000053] = *P00053; sub P00053 { if (++$core[000145] == 010000) { $core[000145] = 0; $pc++; }$code[000145] = *emul8; goto &fetch; }
$core[000054] = 02014; $code[000054] = *P00054; sub P00054 { if (++$core[000014] == 010000) { $core[000014] = 0; $pc++; }$code[000014] = *emul8; goto &fetch; }
$core[000055] = 02230; $code[000055] = *P00055; sub P00055 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[000056] = 02400; $code[000056] = *P00056; sub P00056 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[000057] = 02256; $code[000057] = *P00057; sub P00057 { if (++$core[000056] == 010000) { $core[000056] = 0; $pc++; }$code[000056] = *emul8; goto &fetch; }
$core[000060] = 02423; $code[000060] = *P00060; sub P00060 { if (++$core[($df<<12)+$core[19]] == 010000) { $core[($df<<12)+$core[19]] = 0; $pc++; }$code[($df<<12)+$core[19]] = *emul8; goto &fetch; }
$core[000061] = 02215; $code[000061] = *P00061; sub P00061 { if (++$core[000015] == 010000) { $core[000015] = 0; $pc++; }$code[000015] = *emul8; goto &fetch; }
$core[000062] = 03000; $code[000062] = *P00062; sub P00062 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000063] = 03012; $code[000063] = *P00063; sub P00063 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[000064] = 03025; $code[000064] = *P00064; sub P00064 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[000065] = 02542; $code[000065] = *P00065; sub P00065 { if (++$core[($df<<12)+$core[98]] == 010000) { $core[($df<<12)+$core[98]] = 0; $pc++; }$code[($df<<12)+$core[98]] = *emul8; goto &fetch; }
$core[000066] = 02563; $code[000066] = *P00066; sub P00066 { if (++$core[($df<<12)+$core[115]] == 010000) { $core[($df<<12)+$core[115]] = 0; $pc++; }$code[($df<<12)+$core[115]] = *emul8; goto &fetch; }
$core[000067] = 02741; $code[000067] = *P00067; sub P00067 { if (++$core[($df<<12)+$core[97]] == 010000) { $core[($df<<12)+$core[97]] = 0; $pc++; }$code[($df<<12)+$core[97]] = *emul8; goto &fetch; }
$core[000070] = 02567; $code[000070] = *P00070; sub P00070 { if (++$core[($df<<12)+$core[119]] == 010000) { $core[($df<<12)+$core[119]] = 0; $pc++; }$code[($df<<12)+$core[119]] = *emul8; goto &fetch; }
$core[000071] = 05000; $code[000071] = *D00071; sub D00071 { $pc = 000000; $inh = 0; goto &fetch; }
$core[000072] = 04150; $code[000072] = *P00072; sub P00072 { $core[000150] = 00073; $pc = 000150+1; $code[000150] = *emul8; $inh = 0; goto &fetch; }
$core[000073] = 04200; $code[000073] = *P00073; sub P00073 { $core[000000] = 00074; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000074] = 01000; $code[000074] = *P00074; sub P00074 { $lac += $core[000000]; goto &fetch; }
$core[000075] = 01046; $code[000075] = *P00075; sub P00075 { $lac += $core[000046]; goto &fetch; }
$core[000076] = 03756; $code[000076] = *P00076; sub P00076 { $core[($df<<12)+$core[110]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[110]] = *emul8; goto &fetch; }
$core[000077] = 00000; $code[000077] = *P00077; sub P00077 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000100] = 00000; $code[000100] = *L00100; sub L00100 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000101] = 00000; $code[000101] = *P00101; sub P00101 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000102] = 00000; $code[000102] = *P00102; sub P00102 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000103] = 00000; $code[000103] = *P00103; sub P00103 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000104] = 00000; $code[000104] = *P00104; sub P00104 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000105] = 00000; $code[000105] = *D00105; sub D00105 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000106] = 00000; $code[000106] = *D00106; sub D00106 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000107] = 00000; $code[000107] = *P00107; sub P00107 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000110] = 00000; $code[000110] = *D00110; sub D00110 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000111] = 00000; $code[000111] = *D00111; sub D00111 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000112] = 00000; $code[000112] = *P00112; sub P00112 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000113] = 00000; $code[000113] = *D00113; sub D00113 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000114] = 00000; $code[000114] = *P00114; sub P00114 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000115] = 00000; $code[000115] = *P00115; sub P00115 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000116] = 00000; $code[000116] = *P00116; sub P00116 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000117] = 00000; $code[000117] = *P00117; sub P00117 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000120] = 00000; $code[000120] = *P00120; sub P00120 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000121] = 00000; $code[000121] = *P00121; sub P00121 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000122] = 00000; $code[000122] = *P00122; sub P00122 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000123] = 00000; $code[000123] = *P00123; sub P00123 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000124] = 00000; $code[000124] = *D00124; sub D00124 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000125] = 00000; $code[000125] = *P00125; sub P00125 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000126] = 00000; $code[000126] = *P00126; sub P00126 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000127] = 00000; $code[000127] = *D00127; sub D00127 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000130] = 00000; $code[000130] = *P00130; sub P00130 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000131] = 00000; $code[000131] = *P00131; sub P00131 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000132] = 00000; $code[000132] = *P00132; sub P00132 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000133] = 00000; $code[000133] = *D00133; sub D00133 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000134] = 00000; $code[000134] = *P00134; sub P00134 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000135] = 00000; $code[000135] = *D00135; sub D00135 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000136] = 07776; $code[000136] = *P00136; sub P00136 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000137] = 00002; $code[000137] = *P00137; sub P00137 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000140] = 00000; $code[000140] = *P00140; sub P00140 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000141] = 00000; $code[000141] = *P00141; sub P00141 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000142] = 07766; $code[000142] = *P00142; sub P00142 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000143] = 00000; $code[000143] = *D00143; sub D00143 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000144] = 00000; $code[000144] = *D00144; sub D00144 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000145] = 07771; $code[000145] = *P00145; sub P00145 { &emul8; goto &fetch; }
$core[000146] = 00000; $code[000146] = *D00146; sub D00146 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000147] = 00002; $code[000147] = *P00147; sub P00147 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000150] = 00003; $code[000150] = *D00150; sub D00150 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000151] = 00004; $code[000151] = *P00151; sub P00151 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[000152] = 00006; $code[000152] = *D00152; sub D00152 { $lac &= (010000|$core[000006]); goto &fetch; }
$core[000153] = 00000; $code[000153] = *P00153; sub P00153 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000154] = 00707; $code[000154] = *D00154; sub D00154 { $lac &= (010000|$core[($df<<12)+$core[71]]); goto &fetch; }
$core[000155] = 06060; $code[000155] = *P00155; sub P00155 { &emul8; goto &fetch; }
$core[000156] = 07700; $code[000156] = *P00156; sub P00156 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000157] = 00000; $code[000157] = *D00157; sub D00157 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000160] = 00000; $code[000160] = *S00160; sub S00160 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000161] = 00000; $code[000161] = *P00161; sub P00161 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000162] = 05560; $code[000162] = *I00162; sub I00162 { $pc = ($ib<<12)+$core[112]; $inh = 0; goto &fetch; }
$core[000163] = 04446; $code[000163] = *P00163; sub P00163 { $core[($ib<<12)+$core[38]] = 00164; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[000164] = 07777; $code[000164] = *P00164; sub P00164 { &emul8; goto &fetch; }
$core[000165] = 04426; $code[000165] = *P00165; sub P00165 { $core[($ib<<12)+$core[22]] = 00166; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[000166] = 04372; $code[000166] = *I00166; sub I00166 { $core[000172] = 00167; $pc = 000172+1; $code[000172] = *emul8; $inh = 0; goto &fetch; }
$core[000167] = 05777; $code[000167] = *P00167; sub P00167 { $pc = ($ib<<12)+$core[127]; $inh = 0; goto &fetch; }
$core[000170] = 04426; $code[000170] = *L00170; sub L00170 { $core[($ib<<12)+$core[22]] = 00171; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[000171] = 02175; $code[000171] = *P00171; sub P00171 { if (++$core[000175] == 010000) { $core[000175] = 0; $pc++; }$code[000175] = *emul8; goto &fetch; }
$core[000172] = 05776; $code[000172] = *P00172; sub P00172 { $pc = ($ib<<12)+$core[126]; $inh = 0; goto &fetch; }
$core[000173] = 06201; $code[000173] = *D00173; sub D00173 { &emul8; goto &fetch; }
$core[000174] = 06000; $code[000174] = *D00174; sub D00174 { &emul8; goto &fetch; }
$core[000175] = 00007; $code[000175] = *P00175; sub P00175 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000176] = 00205; $code[000176] = *P00176; sub P00176 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[000177] = 00203; $code[000177] = *P00177; sub P00177 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000200] = 06032; $code[000200] = *I00200; sub I00200 { &emul8; goto &fetch; }
$core[000201] = 07402; $code[000201] = *I00201; sub I00201 { $hlt = 1; goto &fetch; }
$core[000202] = 04777; $code[000202] = *I00202; sub I00202 { $core[($ib<<12)+$core[255]] = 00203; $pc = ($ib<<12)+$core[255]+1; $code[($ib<<12)+$core[255]] = *emul8; $inh = 0; goto &fetch; }
$core[000203] = 01142; $code[000203] = *L00203; sub L00203 { $lac += $core[000142]; goto &fetch; }
$core[000204] = 03143; $code[000204] = *I00204; sub I00204 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[000205] = 01145; $code[000205] = *L00205; sub L00205 { $lac += $core[000145]; goto &fetch; }
$core[000206] = 03146; $code[000206] = *I00206; sub I00206 { $core[000146] = $lac & 07777; $lac &= 010000; $code[000146] = *emul8; goto &fetch; }
$core[000207] = 06001; $code[000207] = *I00207; sub I00207 { &emul8; goto &fetch; }
$core[000210] = 07200; $code[000210] = *L00210; sub L00210 { $lac &= 010000; goto &fetch; }
$core[000211] = 01021; $code[000211] = *I00211; sub I00211 { $lac += $core[000021]; goto &fetch; }
$core[000212] = 03103; $code[000212] = *I00212; sub I00212 { $core[000103] = $lac & 07777; $lac &= 010000; $code[000103] = *emul8; goto &fetch; }
$core[000213] = 04260; $code[000213] = *L00213; sub L00213 { $core[000260] = 00214; $pc = 000260+1; $code[000260] = *emul8; $inh = 0; goto &fetch; }
$core[000214] = 07604; $code[000214] = *I00214; sub I00214 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000215] = 07004; $code[000215] = *I00215; sub I00215 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000216] = 07500; $code[000216] = *I00216; sub I00216 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000217] = 05776; $code[000217] = *I00217; sub I00217 { $pc = ($ib<<12)+$core[254]; $inh = 0; goto &fetch; }
$core[000220] = 07604; $code[000220] = *L00220; sub L00220 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000221] = 00175; $code[000221] = *I00221; sub I00221 { $lac &= (010000|$core[000175]); goto &fetch; }
$core[000222] = 07041; $code[000222] = *I00222; sub I00222 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000223] = 01102; $code[000223] = *I00223; sub I00223 { $lac += $core[000102]; goto &fetch; }
$core[000224] = 07650; $code[000224] = *I00224; sub I00224 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000225] = 05775; $code[000225] = *I00225; sub I00225 { $pc = ($ib<<12)+$core[253]; $inh = 0; goto &fetch; }
$core[000226] = 01103; $code[000226] = *I00226; sub I00226 { $lac += $core[000103]; goto &fetch; }
$core[000227] = 07001; $code[000227] = *I00227; sub I00227 { $lac++; goto &fetch; }
$core[000230] = 07640; $code[000230] = *I00230; sub I00230 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000231] = 05213; $code[000231] = *I00231; sub I00231 { $pc = 000213; $inh = 0; goto &fetch; }
$core[000232] = 07402; $code[000232] = *I00232; sub I00232 { $hlt = 1; goto &fetch; }
$core[000233] = 05210; $code[000233] = *I00233; sub I00233 { $pc = 000210; $inh = 0; goto &fetch; }
$core[000234] = 04274; $code[000234] = *L00234; sub L00234 { $core[000274] = 00235; $pc = 000274+1; $code[000274] = *emul8; $inh = 0; goto &fetch; }
$core[000235] = 05774; $code[000235] = *I00235; sub I00235 { $pc = ($ib<<12)+$core[252]; $inh = 0; goto &fetch; }
$core[000236] = 07510; $code[000236] = *L00236; sub L00236 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000237] = 05303; $code[000237] = *I00237; sub I00237 { $pc = 000303; $inh = 0; goto &fetch; }
$core[000240] = 03100; $code[000240] = *I00240; sub I00240 { $core[000100] = $lac & 07777; $lac &= 010000; $code[000100] = *emul8; goto &fetch; }
$core[000241] = 01103; $code[000241] = *I00241; sub I00241 { $lac += $core[000103]; goto &fetch; }
$core[000242] = 07001; $code[000242] = *I00242; sub I00242 { $lac++; goto &fetch; }
$core[000243] = 07640; $code[000243] = *I00243; sub I00243 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000244] = 05213; $code[000244] = *I00244; sub I00244 { $pc = 000213; $inh = 0; goto &fetch; }
$core[000245] = 01100; $code[000245] = *I00245; sub I00245 { $lac += $core[000100]; goto &fetch; }
$core[000246] = 07004; $code[000246] = *I00246; sub I00246 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000247] = 07510; $code[000247] = *I00247; sub I00247 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000250] = 05253; $code[000250] = *I00250; sub I00250 { $pc = 000253; $inh = 0; goto &fetch; }
$core[000251] = 07402; $code[000251] = *I00251; sub I00251 { $hlt = 1; goto &fetch; }
$core[000252] = 05234; $code[000252] = *I00252; sub I00252 { $pc = 000234; $inh = 0; goto &fetch; }
$core[000253] = 02146; $code[000253] = *L00253; sub L00253 { if (++$core[000146] == 010000) { $core[000146] = 0; $pc++; }$code[000146] = *emul8; goto &fetch; }
$core[000254] = 05210; $code[000254] = *I00254; sub I00254 { $pc = 000210; $inh = 0; goto &fetch; }
$core[000255] = 02143; $code[000255] = *I00255; sub I00255 { if (++$core[000143] == 010000) { $core[000143] = 0; $pc++; }$code[000143] = *emul8; goto &fetch; }
$core[000256] = 05170; $code[000256] = *I00256; sub I00256 { $pc = 000170; $inh = 0; goto &fetch; }
$core[000257] = 05163; $code[000257] = *I00257; sub I00257 { $pc = 000163; $inh = 0; goto &fetch; }
$core[000260] = 00000; $code[000260] = *S00260; sub S00260 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000261] = 01503; $code[000261] = *I00261; sub I00261 { $lac += $core[($df<<12)+$core[67]]; goto &fetch; }
$core[000262] = 03102; $code[000262] = *I00262; sub I00262 { $core[000102] = $lac & 07777; $lac &= 010000; $code[000102] = *emul8; goto &fetch; }
$core[000263] = 02103; $code[000263] = *I00263; sub I00263 { if (++$core[000103] == 010000) { $core[000103] = 0; $pc++; }$code[000103] = *emul8; goto &fetch; }
$core[000264] = 01103; $code[000264] = *I00264; sub I00264 { $lac += $core[000103]; goto &fetch; }
$core[000265] = 03077; $code[000265] = *I00265; sub I00265 { $core[000077] = $lac & 07777; $lac &= 010000; $code[000077] = *emul8; goto &fetch; }
$core[000266] = 02103; $code[000266] = *I00266; sub I00266 { if (++$core[000103] == 010000) { $core[000103] = 0; $pc++; }$code[000103] = *emul8; goto &fetch; }
$core[000267] = 01103; $code[000267] = *I00267; sub I00267 { $lac += $core[000103]; goto &fetch; }
$core[000270] = 03101; $code[000270] = *I00270; sub I00270 { $core[000101] = $lac & 07777; $lac &= 010000; $code[000101] = *emul8; goto &fetch; }
$core[000271] = 01477; $code[000271] = *I00271; sub I00271 { $lac += $core[($df<<12)+$core[63]]; goto &fetch; }
$core[000272] = 03103; $code[000272] = *I00272; sub I00272 { $core[000103] = $lac & 07777; $lac &= 010000; $code[000103] = *emul8; goto &fetch; }
$core[000273] = 05660; $code[000273] = *I00273; sub I00273 { $pc = ($ib<<12)+$core[176]; $inh = 0; goto &fetch; }
$core[000274] = 00000; $code[000274] = *S00274; sub S00274 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000275] = 07604; $code[000275] = *I00275; sub I00275 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000276] = 07700; $code[000276] = *I00276; sub I00276 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000277] = 05674; $code[000277] = *I00277; sub I00277 { $pc = ($ib<<12)+$core[188]; $inh = 0; goto &fetch; }
$core[000300] = 01102; $code[000300] = *I00300; sub I00300 { $lac += $core[000102]; goto &fetch; }
$core[000301] = 07402; $code[000301] = *I00301; sub I00301 { $hlt = 1; goto &fetch; }
$core[000302] = 05674; $code[000302] = *I00302; sub I00302 { $pc = ($ib<<12)+$core[188]; $inh = 0; goto &fetch; }
$core[000303] = 07200; $code[000303] = *L00303; sub L00303 { $lac &= 010000; goto &fetch; }
$core[000304] = 01020; $code[000304] = *I00304; sub I00304 { $lac += $core[000020]; goto &fetch; }
$core[000305] = 07640; $code[000305] = *I00305; sub I00305 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000306] = 05312; $code[000306] = *I00306; sub I00306 { $pc = 000312; $inh = 0; goto &fetch; }
$core[000307] = 03773; $code[000307] = *I00307; sub I00307 { $core[($df<<12)+$core[251]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[251]] = *emul8; goto &fetch; }
$core[000310] = 07447; $code[000310] = *I00310; sub I00310 { &emul8; goto &fetch; }
$core[000311] = 05501; $code[000311] = *I00311; sub I00311 { $pc = ($ib<<12)+$core[65]; $inh = 0; goto &fetch; }
$core[000312] = 07201; $code[000312] = *L00312; sub L00312 { $lac &= 010000; $lac++; goto &fetch; }
$core[000313] = 03773; $code[000313] = *I00313; sub I00313 { $core[($df<<12)+$core[251]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[251]] = *emul8; goto &fetch; }
$core[000314] = 07431; $code[000314] = *I00314; sub I00314 { &emul8; goto &fetch; }
$core[000315] = 05501; $code[000315] = *I00315; sub I00315 { $pc = ($ib<<12)+$core[65]; $inh = 0; goto &fetch; }
$core[000316] = 07300; $code[000316] = *L00316; sub L00316 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000317] = 01102; $code[000317] = *I00317; sub I00317 { $lac += $core[000102]; goto &fetch; }
$core[000320] = 07402; $code[000320] = *I00320; sub I00320 { $hlt = 1; goto &fetch; }
$core[000321] = 07300; $code[000321] = *P00321; sub P00321 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000322] = 01021; $code[000322] = *I00322; sub I00322 { $lac += $core[000021]; goto &fetch; }
$core[000323] = 03103; $code[000323] = *I00323; sub I00323 { $core[000103] = $lac & 07777; $lac &= 010000; $code[000103] = *emul8; goto &fetch; }
$core[000324] = 04260; $code[000324] = *I00324; sub I00324 { $core[000260] = 00325; $pc = 000260+1; $code[000260] = *emul8; $inh = 0; goto &fetch; }
$core[000325] = 05220; $code[000325] = *I00325; sub I00325 { $pc = 000220; $inh = 0; goto &fetch; }
$core[000326] = 00000; $code[000326] = *S00326; sub S00326 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000327] = 07200; $code[000327] = *I00327; sub I00327 { $lac &= 010000; goto &fetch; }
$core[000330] = 01371; $code[000330] = *I00330; sub I00330 { $lac += $core[000371]; goto &fetch; }
$core[000331] = 01356; $code[000331] = *I00331; sub I00331 { $lac += $core[000356]; goto &fetch; }
$core[000332] = 07640; $code[000332] = *I00332; sub I00332 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000333] = 05343; $code[000333] = *I00333; sub I00333 { $pc = 000343; $inh = 0; goto &fetch; }
$core[000334] = 01360; $code[000334] = *I00334; sub I00334 { $lac += $core[000360]; goto &fetch; }
$core[000335] = 03356; $code[000335] = *I00335; sub I00335 { $core[000356] = $lac & 07777; $lac &= 010000; $code[000356] = *emul8; goto &fetch; }
$core[000336] = 01357; $code[000336] = *I00336; sub I00336 { $lac += $core[000357]; goto &fetch; }
$core[000337] = 07104; $code[000337] = *I00337; sub I00337 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000340] = 07430; $code[000340] = *I00340; sub I00340 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000341] = 07001; $code[000341] = *I00341; sub I00341 { $lac++; goto &fetch; }
$core[000342] = 03357; $code[000342] = *I00342; sub I00342 { $core[000357] = $lac & 07777; $lac &= 010000; $code[000357] = *emul8; goto &fetch; }
$core[000343] = 01357; $code[000343] = *L00343; sub L00343 { $lac += $core[000357]; goto &fetch; }
$core[000344] = 01756; $code[000344] = *I00344; sub I00344 { $lac += $core[($df<<12)+$core[238]]; goto &fetch; }
$core[000345] = 03756; $code[000345] = *I00345; sub I00345 { $core[($df<<12)+$core[238]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[238]] = *emul8; goto &fetch; }
$core[000346] = 01372; $code[000346] = *I00346; sub I00346 { $lac += $core[000372]; goto &fetch; }
$core[000347] = 07010; $code[000347] = *I00347; sub I00347 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000350] = 01756; $code[000350] = *P00350; sub P00350 { $lac += $core[($df<<12)+$core[238]]; goto &fetch; }
$core[000351] = 02356; $code[000351] = *I00351; sub I00351 { if (++$core[000356] == 010000) { $core[000356] = 0; $pc++; }$code[000356] = *emul8; goto &fetch; }
$core[000352] = 07000; $code[000352] = *I00352; sub I00352 { goto &fetch; }
$core[000353] = 03372; $code[000353] = *I00353; sub I00353 { $core[000372] = $lac & 07777; $lac &= 010000; $code[000372] = *emul8; goto &fetch; }
$core[000354] = 01372; $code[000354] = *I00354; sub I00354 { $lac += $core[000372]; goto &fetch; }
$core[000355] = 05726; $code[000355] = *I00355; sub I00355 { $pc = ($ib<<12)+$core[214]; $inh = 0; goto &fetch; }
$core[000356] = 00371; $code[000356] = *P00356; sub P00356 { $lac &= (010000|$core[000371]); goto &fetch; }
$core[000357] = 06543; $code[000357] = *D00357; sub D00357 { &emul8; goto &fetch; }
$core[000360] = 00361; $code[000360] = *D00360; sub D00360 { $lac &= (010000|$core[000361]); goto &fetch; }
$core[000361] = 06543; $code[000361] = *D00361; sub D00361 { &emul8; goto &fetch; }
$core[000362] = 03210; $code[000362] = *I00362; sub I00362 { $core[000210] = $lac & 07777; $lac &= 010000; $code[000210] = *emul8; goto &fetch; }
$core[000363] = 00765; $code[000363] = *I00363; sub I00363 { $lac &= (010000|$core[($df<<12)+$core[245]]); goto &fetch; }
$core[000364] = 05432; $code[000364] = *I00364; sub I00364 { $pc = ($ib<<12)+$core[26]; $inh = 0; goto &fetch; }
$core[000365] = 02107; $code[000365] = *P00365; sub P00365 { if (++$core[000107] == 010000) { $core[000107] = 0; $pc++; }$code[000107] = *emul8; goto &fetch; }
$core[000366] = 07654; $code[000366] = *I00366; sub I00366 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000367] = 04321; $code[000367] = *I00367; sub I00367 { $core[000321] = 00370; $pc = 000321+1; $code[000321] = *emul8; $inh = 0; goto &fetch; }
$core[000370] = 01076; $code[000370] = *I00370; sub I00370 { $lac += $core[000076]; goto &fetch; }
$core[000371] = 07407; $code[000371] = *D00371; sub D00371 { &emul8; goto &fetch; }
$core[000372] = 00000; $code[000372] = *D00372; sub D00372 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000373] = 02455; $code[000373] = *P00373; sub P00373 { if (++$core[($df<<12)+$core[45]] == 010000) { $core[($df<<12)+$core[45]] = 0; $pc++; }$code[($df<<12)+$core[45]] = *emul8; goto &fetch; }
$core[000374] = 04721; $code[000374] = *P00374; sub P00374 { $core[($ib<<12)+$core[209]] = 00375; $pc = ($ib<<12)+$core[209]+1; $code[($ib<<12)+$core[209]] = *emul8; $inh = 0; goto &fetch; }
$core[000375] = 04572; $code[000375] = *P00375; sub P00375 { $core[($ib<<12)+$core[122]] = 00376; $pc = ($ib<<12)+$core[122]+1; $code[($ib<<12)+$core[122]] = *emul8; $inh = 0; goto &fetch; }
$core[000376] = 01360; $code[000376] = *P00376; sub P00376 { $lac += $core[000360]; goto &fetch; }
$core[000377] = 04750; $code[000377] = *P00377; sub P00377 { $core[($ib<<12)+$core[232]] = 00400; $pc = ($ib<<12)+$core[232]+1; $code[($ib<<12)+$core[232]] = *emul8; $inh = 0; goto &fetch; }
$core[000400] = 00000; $code[000400] = *S00400; sub S00400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000401] = 07200; $code[000401] = *I00401; sub I00401 { $lac &= 010000; goto &fetch; }
$core[000402] = 01600; $code[000402] = *I00402; sub I00402 { $lac += $core[($df<<12)+$core[256]]; goto &fetch; }
$core[000403] = 03262; $code[000403] = *I00403; sub I00403 { $core[000462] = $lac & 07777; $lac &= 010000; $code[000462] = *emul8; goto &fetch; }
$core[000404] = 03264; $code[000404] = *I00404; sub I00404 { $core[000464] = $lac & 07777; $lac &= 010000; $code[000464] = *emul8; goto &fetch; }
$core[000405] = 02200; $code[000405] = *P00405; sub P00405 { if (++$core[000400] == 010000) { $core[000400] = 0; $pc++; }$code[000400] = *emul8; goto &fetch; }
$core[000406] = 01662; $code[000406] = *L00406; sub L00406 { $lac += $core[($df<<12)+$core[306]]; goto &fetch; }
$core[000407] = 07012; $code[000407] = *I00407; sub I00407 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000410] = 07012; $code[000410] = *I00410; sub I00410 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000411] = 07012; $code[000411] = *I00411; sub I00411 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000412] = 04217; $code[000412] = *I00412; sub I00412 { $core[000417] = 00413; $pc = 000417+1; $code[000417] = *emul8; $inh = 0; goto &fetch; }
$core[000413] = 01662; $code[000413] = *I00413; sub I00413 { $lac += $core[($df<<12)+$core[306]]; goto &fetch; }
$core[000414] = 04217; $code[000414] = *I00414; sub I00414 { $core[000417] = 00415; $pc = 000417+1; $code[000417] = *emul8; $inh = 0; goto &fetch; }
$core[000415] = 02262; $code[000415] = *I00415; sub I00415 { if (++$core[000462] == 010000) { $core[000462] = 0; $pc++; }$code[000462] = *emul8; goto &fetch; }
$core[000416] = 05206; $code[000416] = *I00416; sub I00416 { $pc = 000406; $inh = 0; goto &fetch; }
$core[000417] = 00000; $code[000417] = *S00417; sub S00417 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000420] = 00265; $code[000420] = *I00420; sub I00420 { $lac &= (010000|$core[000465]); goto &fetch; }
$core[000421] = 03263; $code[000421] = *I00421; sub I00421 { $core[000463] = $lac & 07777; $lac &= 010000; $code[000463] = *emul8; goto &fetch; }
$core[000422] = 01264; $code[000422] = *D00422; sub D00422 { $lac += $core[000464]; goto &fetch; }
$core[000423] = 07640; $code[000423] = *I00423; sub I00423 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000424] = 05234; $code[000424] = *I00424; sub I00424 { $pc = 000434; $inh = 0; goto &fetch; }
$core[000425] = 01263; $code[000425] = *I00425; sub I00425 { $lac += $core[000463]; goto &fetch; }
$core[000426] = 07450; $code[000426] = *I00426; sub I00426 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000427] = 05232; $code[000427] = *I00427; sub I00427 { $pc = 000432; $inh = 0; goto &fetch; }
$core[000430] = 04253; $code[000430] = *L00430; sub L00430 { $core[000453] = 00431; $pc = 000453+1; $code[000453] = *emul8; $inh = 0; goto &fetch; }
$core[000431] = 05617; $code[000431] = *I00431; sub I00431 { $pc = ($ib<<12)+$core[271]; $inh = 0; goto &fetch; }
$core[000432] = 02264; $code[000432] = *L00432; sub L00432 { if (++$core[000464] == 010000) { $core[000464] = 0; $pc++; }$code[000464] = *emul8; goto &fetch; }
$core[000433] = 05617; $code[000433] = *I00433; sub I00433 { $pc = ($ib<<12)+$core[271]; $inh = 0; goto &fetch; }
$core[000434] = 03264; $code[000434] = *L00434; sub L00434 { $core[000464] = $lac & 07777; $lac &= 010000; $code[000464] = *emul8; goto &fetch; }
$core[000435] = 01263; $code[000435] = *I00435; sub I00435 { $lac += $core[000463]; goto &fetch; }
$core[000436] = 07041; $code[000436] = *I00436; sub I00436 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000437] = 07450; $code[000437] = *I00437; sub I00437 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000440] = 05230; $code[000440] = *D00440; sub D00440 { $pc = 000430; $inh = 0; goto &fetch; }
$core[000441] = 07001; $code[000441] = *I00441; sub I00441 { $lac++; goto &fetch; }
$core[000442] = 07650; $code[000442] = *I00442; sub I00442 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000443] = 05600; $code[000443] = *I00443; sub I00443 { $pc = ($ib<<12)+$core[256]; $inh = 0; goto &fetch; }
$core[000444] = 01271; $code[000444] = *I00444; sub I00444 { $lac += $core[000471]; goto &fetch; }
$core[000445] = 03255; $code[000445] = *I00445; sub I00445 { $core[000455] = $lac & 07777; $lac &= 010000; $code[000455] = *emul8; goto &fetch; }
$core[000446] = 01263; $code[000446] = *I00446; sub I00446 { $lac += $core[000463]; goto &fetch; }
$core[000447] = 04253; $code[000447] = *I00447; sub I00447 { $core[000453] = 00450; $pc = 000453+1; $code[000453] = *emul8; $inh = 0; goto &fetch; }
$core[000450] = 01272; $code[000450] = *I00450; sub I00450 { $lac += $core[000472]; goto &fetch; }
$core[000451] = 03255; $code[000451] = *I00451; sub I00451 { $core[000455] = $lac & 07777; $lac &= 010000; $code[000455] = *emul8; goto &fetch; }
$core[000452] = 05617; $code[000452] = *I00452; sub I00452 { $pc = ($ib<<12)+$core[271]; $inh = 0; goto &fetch; }
$core[000453] = 00000; $code[000453] = *S00453; sub S00453 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000454] = 01266; $code[000454] = *I00454; sub I00454 { $lac += $core[000466]; goto &fetch; }
$core[000455] = 07510; $code[000455] = *D00455; sub D00455 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000456] = 01267; $code[000456] = *I00456; sub I00456 { $lac += $core[000467]; goto &fetch; }
$core[000457] = 01270; $code[000457] = *I00457; sub I00457 { $lac += $core[000470]; goto &fetch; }
$core[000460] = 04474; $code[000460] = *I00460; sub I00460 { $core[($ib<<12)+$core[60]] = 00461; $pc = ($ib<<12)+$core[60]+1; $code[($ib<<12)+$core[60]] = *emul8; $inh = 0; goto &fetch; }
$core[000461] = 05653; $code[000461] = *I00461; sub I00461 { $pc = ($ib<<12)+$core[299]; $inh = 0; goto &fetch; }
$core[000462] = 00000; $code[000462] = *P00462; sub P00462 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000463] = 00000; $code[000463] = *D00463; sub D00463 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000464] = 00000; $code[000464] = *D00464; sub D00464 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000465] = 00077; $code[000465] = *D00465; sub D00465 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[000466] = 07740; $code[000466] = *D00466; sub D00466 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000467] = 00100; $code[000467] = *D00467; sub D00467 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000470] = 00240; $code[000470] = *D00470; sub D00470 { $lac &= (010000|$core[000440]); goto &fetch; }
$core[000471] = 07500; $code[000471] = *D00471; sub D00471 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000472] = 07510; $code[000472] = *D00472; sub D00472 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000473] = 00000; $code[000473] = *I00473; sub I00473 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000474] = 00000; $code[000474] = *I00474; sub I00474 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000475] = 00000; $code[000475] = *I00475; sub I00475 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000476] = 00000; $code[000476] = *I00476; sub I00476 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000477] = 00000; $code[000477] = *I00477; sub I00477 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000500] = 00000; $code[000500] = *I00500; sub I00500 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000501] = 00000; $code[000501] = *I00501; sub I00501 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000502] = 00000; $code[000502] = *I00502; sub I00502 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000503] = 00000; $code[000503] = *D00503; sub D00503 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000504] = 00000; $code[000504] = *I00504; sub I00504 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000505] = 00000; $code[000505] = *I00505; sub I00505 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000506] = 00000; $code[000506] = *I00506; sub I00506 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000507] = 00000; $code[000507] = *I00507; sub I00507 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000510] = 00000; $code[000510] = *I00510; sub I00510 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000511] = 00000; $code[000511] = *I00511; sub I00511 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000512] = 00000; $code[000512] = *I00512; sub I00512 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000513] = 00000; $code[000513] = *I00513; sub I00513 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000514] = 00000; $code[000514] = *I00514; sub I00514 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000515] = 00000; $code[000515] = *I00515; sub I00515 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000516] = 00000; $code[000516] = *I00516; sub I00516 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000517] = 00000; $code[000517] = *I00517; sub I00517 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000520] = 00000; $code[000520] = *I00520; sub I00520 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000521] = 00000; $code[000521] = *I00521; sub I00521 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000522] = 00000; $code[000522] = *I00522; sub I00522 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000523] = 00000; $code[000523] = *I00523; sub I00523 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000524] = 00000; $code[000524] = *I00524; sub I00524 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000525] = 00000; $code[000525] = *I00525; sub I00525 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000526] = 00000; $code[000526] = *I00526; sub I00526 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000527] = 00000; $code[000527] = *I00527; sub I00527 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000530] = 00000; $code[000530] = *I00530; sub I00530 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000531] = 00000; $code[000531] = *I00531; sub I00531 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000532] = 00000; $code[000532] = *I00532; sub I00532 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000533] = 00000; $code[000533] = *I00533; sub I00533 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000534] = 00000; $code[000534] = *I00534; sub I00534 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000535] = 00000; $code[000535] = *I00535; sub I00535 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000536] = 00000; $code[000536] = *I00536; sub I00536 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000537] = 00000; $code[000537] = *I00537; sub I00537 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000540] = 00000; $code[000540] = *I00540; sub I00540 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000541] = 00000; $code[000541] = *I00541; sub I00541 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000542] = 00000; $code[000542] = *I00542; sub I00542 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000543] = 00000; $code[000543] = *I00543; sub I00543 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000544] = 00000; $code[000544] = *I00544; sub I00544 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000545] = 06000; $code[000545] = *I00545; sub I00545 { &emul8; goto &fetch; }
$core[000546] = 00100; $code[000546] = *I00546; sub I00546 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000547] = 06100; $code[000547] = *I00547; sub I00547 { &emul8; goto &fetch; }
$core[000550] = 00100; $code[000550] = *I00550; sub I00550 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000551] = 01525; $code[000551] = *I00551; sub I00551 { $lac += $core[($df<<12)+$core[85]]; goto &fetch; }
$core[000552] = 03105; $code[000552] = *I00552; sub I00552 { $core[000105] = $lac & 07777; $lac &= 010000; $code[000105] = *emul8; goto &fetch; }
$core[000553] = 02222; $code[000553] = *I00553; sub I00553 { if (++$core[000422] == 010000) { $core[000422] = 0; $pc++; }$code[000422] = *emul8; goto &fetch; }
$core[000554] = 00001; $code[000554] = *I00554; sub I00554 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000555] = 00411; $code[000555] = *I00555; sub I00555 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac &= (010000|$core[($df<<12)+$core[000011]]); goto &fetch; }
$core[000556] = 02605; $code[000556] = *I00556; sub I00556 { if (++$core[($df<<12)+$core[261]] == 010000) { $core[($df<<12)+$core[261]] = 0; $pc++; }$code[($df<<12)+$core[261]] = *emul8; goto &fetch; }
$core[000557] = 02222; $code[000557] = *I00557; sub I00557 { if (++$core[000422] == 010000) { $core[000422] = 0; $pc++; }$code[000422] = *emul8; goto &fetch; }
$core[000560] = 00001; $code[000560] = *I00560; sub I00560 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000561] = 02303; $code[000561] = *I00561; sub I00561 { if (++$core[000503] == 010000) { $core[000503] = 0; $pc++; }$code[000503] = *emul8; goto &fetch; }
$core[000562] = 06000; $code[000562] = *I00562; sub I00562 { &emul8; goto &fetch; }
$core[000563] = 00100; $code[000563] = *I00563; sub I00563 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000564] = 02303; $code[000564] = *I00564; sub I00564 { if (++$core[000503] == 010000) { $core[000503] = 0; $pc++; }$code[000503] = *emul8; goto &fetch; }
$core[000565] = 06100; $code[000565] = *I00565; sub I00565 { &emul8; goto &fetch; }
$core[000566] = 00100; $code[000566] = *I00566; sub I00566 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000567] = 02303; $code[000567] = *I00567; sub I00567 { if (++$core[000503] == 010000) { $core[000503] = 0; $pc++; }$code[000503] = *emul8; goto &fetch; }
$core[000570] = 06200; $code[000570] = *I00570; sub I00570 { &emul8; goto &fetch; }
$core[000571] = 00100; $code[000571] = *I00571; sub I00571 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000572] = 02303; $code[000572] = *I00572; sub I00572 { if (++$core[000503] == 010000) { $core[000503] = 0; $pc++; }$code[000503] = *emul8; goto &fetch; }
$core[000573] = 06300; $code[000573] = *I00573; sub I00573 { &emul8; goto &fetch; }
$core[000574] = 00100; $code[000574] = *I00574; sub I00574 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000575] = 02303; $code[000575] = *I00575; sub I00575 { if (++$core[000503] == 010000) { $core[000503] = 0; $pc++; }$code[000503] = *emul8; goto &fetch; }
$core[000576] = 06400; $code[000576] = *I00576; sub I00576 { &emul8; goto &fetch; }
$core[000577] = 00100; $code[000577] = *I00577; sub I00577 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000600] = 02303; $code[000600] = *D00600; sub D00600 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000601] = 06500; $code[000601] = *D00601; sub D00601 { &emul8; goto &fetch; }
$core[000602] = 00100; $code[000602] = *I00602; sub I00602 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000603] = 02303; $code[000603] = *I00603; sub I00603 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000604] = 06600; $code[000604] = *I00604; sub I00604 { &emul8; goto &fetch; }
$core[000605] = 00100; $code[000605] = *I00605; sub I00605 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000606] = 02303; $code[000606] = *I00606; sub I00606 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000607] = 06700; $code[000607] = *I00607; sub I00607 { &emul8; goto &fetch; }
$core[000610] = 00100; $code[000610] = *I00610; sub I00610 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000611] = 02303; $code[000611] = *I00611; sub I00611 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000612] = 07000; $code[000612] = *I00612; sub I00612 { goto &fetch; }
$core[000613] = 00100; $code[000613] = *I00613; sub I00613 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000614] = 02303; $code[000614] = *I00614; sub I00614 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000615] = 07100; $code[000615] = *I00615; sub I00615 { $lac &= 07777; goto &fetch; }
$core[000616] = 00100; $code[000616] = *P00616; sub P00616 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000617] = 02303; $code[000617] = *D00617; sub D00617 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000620] = 06160; $code[000620] = *I00620; sub I00620 { &emul8; goto &fetch; }
$core[000621] = 00001; $code[000621] = *I00621; sub I00621 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000622] = 02303; $code[000622] = *I00622; sub I00622 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000623] = 06161; $code[000623] = *D00623; sub D00623 { &emul8; goto &fetch; }
$core[000624] = 00001; $code[000624] = *I00624; sub I00624 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000625] = 02303; $code[000625] = *D00625; sub D00625 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000626] = 06162; $code[000626] = *I00626; sub I00626 { &emul8; goto &fetch; }
$core[000627] = 00001; $code[000627] = *I00627; sub I00627 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000630] = 02303; $code[000630] = *D00630; sub D00630 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000631] = 06163; $code[000631] = *I00631; sub I00631 { &emul8; goto &fetch; }
$core[000632] = 00001; $code[000632] = *I00632; sub I00632 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000633] = 02303; $code[000633] = *I00633; sub I00633 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000634] = 00316; $code[000634] = *D00634; sub D00634 { $lac &= (010000|$core[000716]); goto &fetch; }
$core[000635] = 02400; $code[000635] = *I00635; sub I00635 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[000636] = 00100; $code[000636] = *I00636; sub I00636 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000637] = 00616; $code[000637] = *I00637; sub I00637 { $lac &= (010000|$core[($df<<12)+$core[398]]); goto &fetch; }
$core[000640] = 02223; $code[000640] = *D00640; sub D00640 { if (++$core[000623] == 010000) { $core[000623] = 0; $pc++; }$code[000623] = *emul8; goto &fetch; }
$core[000641] = 01424; $code[000641] = *I00641; sub I00641 { $lac += $core[($df<<12)+$core[20]]; goto &fetch; }
$core[000642] = 00001; $code[000642] = *I00642; sub I00642 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000643] = 02022; $code[000643] = *I00643; sub I00643 { if (++$core[000022] == 010000) { $core[000022] = 0; $pc++; }$code[000022] = *emul8; goto &fetch; }
$core[000644] = 01702; $code[000644] = *I00644; sub I00644 { $lac += $core[($df<<12)+$core[450]]; goto &fetch; }
$core[000645] = 00001; $code[000645] = *I00645; sub I00645 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000646] = 00717; $code[000646] = *I00646; sub I00646 { $lac &= (010000|$core[($df<<12)+$core[463]]); goto &fetch; }
$core[000647] = 01704; $code[000647] = *I00647; sub I00647 { $lac += $core[($df<<12)+$core[452]]; goto &fetch; }
$core[000650] = 00001; $code[000650] = *I00650; sub I00650 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000651] = 00201; $code[000651] = *D00651; sub D00651 { $lac &= (010000|$core[000601]); goto &fetch; }
$core[000652] = 00400; $code[000652] = *I00652; sub I00652 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000653] = 00100; $code[000653] = *I00653; sub I00653 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000654] = 02303; $code[000654] = *D00654; sub D00654 { if (++$core[000703] == 010000) { $core[000703] = 0; $pc++; }$code[000703] = *emul8; goto &fetch; }
$core[000655] = 00100; $code[000655] = *I00655; sub I00655 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000656] = 00100; $code[000656] = *I00656; sub I00656 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000657] = 01400; $code[000657] = *I00657; sub I00657 { $lac += $core[($df<<12)+$core[0]]; goto &fetch; }
$core[000660] = 00100; $code[000660] = *I00660; sub I00660 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000661] = 00350; $code[000661] = *I00661; sub I00661 { $lac &= (010000|$core[000750]); goto &fetch; }
$core[000662] = 00103; $code[000662] = *I00662; sub I00662 { $lac &= (010000|$core[000103]); goto &fetch; }
$core[000663] = 05100; $code[000663] = *I00663; sub I00663 { $pc = 000100; $inh = 0; goto &fetch; }
$core[000664] = 00100; $code[000664] = *I00664; sub I00664 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000665] = 00350; $code[000665] = *I00665; sub I00665 { $lac &= (010000|$core[000750]); goto &fetch; }
$core[000666] = 01521; $code[000666] = *I00666; sub I00666 { $lac += $core[($df<<12)+$core[81]]; goto &fetch; }
$core[000667] = 05100; $code[000667] = *I00667; sub I00667 { $pc = 000100; $inh = 0; goto &fetch; }
$core[000670] = 00100; $code[000670] = *I00670; sub I00670 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000671] = 00350; $code[000671] = *I00671; sub I00671 { $lac &= (010000|$core[000750]); goto &fetch; }
$core[000672] = 01502; $code[000672] = *I00672; sub I00672 { $lac += $core[($df<<12)+$core[66]]; goto &fetch; }
$core[000673] = 05100; $code[000673] = *I00673; sub I00673 { $pc = 000100; $inh = 0; goto &fetch; }
$core[000674] = 00100; $code[000674] = *I00674; sub I00674 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000675] = 00522; $code[000675] = *I00675; sub I00675 { $lac &= (010000|$core[($df<<12)+$core[82]]); goto &fetch; }
$core[000676] = 02217; $code[000676] = *I00676; sub I00676 { if (++$core[000617] == 010000) { $core[000617] = 0; $pc++; }$code[000617] = *emul8; goto &fetch; }
$core[000677] = 02223; $code[000677] = *I00677; sub I00677 { if (++$core[000623] == 010000) { $core[000623] = 0; $pc++; }$code[000623] = *emul8; goto &fetch; }
$core[000700] = 04020; $code[000700] = *I00700; sub I00700 { $core[000020] = 00701; $pc = 000020+1; $code[000020] = *emul8; $inh = 0; goto &fetch; }
$core[000701] = 00522; $code[000701] = *I00701; sub I00701 { $lac &= (010000|$core[($df<<12)+$core[82]]); goto &fetch; }
$core[000702] = 04010; $code[000702] = *P00702; sub P00702 { $core[000010] = 00703; $pc = 000010+1; $code[000010] = *emul8; $inh = 0; goto &fetch; }
$core[000703] = 02516; $code[000703] = *D00703; sub D00703 { if (++$core[($df<<12)+$core[78]] == 010000) { $core[($df<<12)+$core[78]] = 0; $pc++; }$code[($df<<12)+$core[78]] = *emul8; goto &fetch; }
$core[000704] = 00422; $code[000704] = *P00704; sub P00704 { $lac &= (010000|$core[($df<<12)+$core[18]]); goto &fetch; }
$core[000705] = 00504; $code[000705] = *I00705; sub I00705 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[000706] = 07240; $code[000706] = *I00706; sub I00706 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000707] = 00001; $code[000707] = *I00707; sub I00707 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000710] = 00530; $code[000710] = *I00710; sub I00710 { $lac &= (010000|$core[($df<<12)+$core[88]]); goto &fetch; }
$core[000711] = 00522; $code[000711] = *I00711; sub I00711 { $lac &= (010000|$core[($df<<12)+$core[82]]); goto &fetch; }
$core[000712] = 02200; $code[000712] = *I00712; sub I00712 { if (++$core[000600] == 010000) { $core[000600] = 0; $pc++; }$code[000600] = *emul8; goto &fetch; }
$core[000713] = 00100; $code[000713] = *I00713; sub I00713 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000714] = 00130; $code[000714] = *I00714; sub I00714 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000715] = 00234; $code[000715] = *I00715; sub I00715 { $lac &= (010000|$core[000634]); goto &fetch; }
$core[000716] = 00240; $code[000716] = *D00716; sub D00716 { $lac &= (010000|$core[000640]); goto &fetch; }
$core[000717] = 07540; $code[000717] = *P00717; sub P00717 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000720] = 00140; $code[000720] = *I00720; sub I00720 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[000721] = 00001; $code[000721] = *I00721; sub I00721 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000722] = 00130; $code[000722] = *I00722; sub I00722 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000723] = 00234; $code[000723] = *I00723; sub I00723 { $lac &= (010000|$core[000634]); goto &fetch; }
$core[000724] = 00230; $code[000724] = *I00724; sub I00724 { $lac &= (010000|$core[000630]); goto &fetch; }
$core[000725] = 00234; $code[000725] = *I00725; sub I00725 { $lac &= (010000|$core[000634]); goto &fetch; }
$core[000726] = 00140; $code[000726] = *I00726; sub I00726 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[000727] = 07540; $code[000727] = *I00727; sub I00727 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000730] = 00240; $code[000730] = *I00730; sub I00730 { $lac &= (010000|$core[000640]); goto &fetch; }
$core[000731] = 00001; $code[000731] = *I00731; sub I00731 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000732] = 00130; $code[000732] = *I00732; sub I00732 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000733] = 00234; $code[000733] = *I00733; sub I00733 { $lac &= (010000|$core[000634]); goto &fetch; }
$core[000734] = 00230; $code[000734] = *I00734; sub I00734 { $lac &= (010000|$core[000630]); goto &fetch; }
$core[000735] = 00234; $code[000735] = *I00735; sub I00735 { $lac &= (010000|$core[000634]); goto &fetch; }
$core[000736] = 00130; $code[000736] = *I00736; sub I00736 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000737] = 00134; $code[000737] = *I00737; sub I00737 { $lac &= (010000|$core[000134]); goto &fetch; }
$core[000740] = 00140; $code[000740] = *I00740; sub I00740 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[000741] = 07540; $code[000741] = *I00741; sub I00741 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000742] = 00240; $code[000742] = *I00742; sub I00742 { $lac &= (010000|$core[000640]); goto &fetch; }
$core[000743] = 00001; $code[000743] = *I00743; sub I00743 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000744] = 00130; $code[000744] = *I00744; sub I00744 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000745] = 00234; $code[000745] = *I00745; sub I00745 { $lac &= (010000|$core[000634]); goto &fetch; }
$core[000746] = 00230; $code[000746] = *I00746; sub I00746 { $lac &= (010000|$core[000630]); goto &fetch; }
$core[000747] = 00234; $code[000747] = *I00747; sub I00747 { $lac &= (010000|$core[000634]); goto &fetch; }
$core[000750] = 00130; $code[000750] = *D00750; sub D00750 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000751] = 00134; $code[000751] = *I00751; sub I00751 { $lac &= (010000|$core[000134]); goto &fetch; }
$core[000752] = 00130; $code[000752] = *I00752; sub I00752 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[000753] = 00134; $code[000753] = *I00753; sub I00753 { $lac &= (010000|$core[000134]); goto &fetch; }
$core[000754] = 00240; $code[000754] = *I00754; sub I00754 { $lac &= (010000|$core[000640]); goto &fetch; }
$core[000755] = 07540; $code[000755] = *I00755; sub I00755 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000756] = 00140; $code[000756] = *I00756; sub I00756 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[000757] = 00001; $code[000757] = *I00757; sub I00757 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000760] = 00140; $code[000760] = *I00760; sub I00760 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[000761] = 07540; $code[000761] = *I00761; sub I00761 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000762] = 04040; $code[000762] = *I00762; sub I00762 { $core[000040] = 00763; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[000763] = 04040; $code[000763] = *I00763; sub I00763 { $core[000040] = 00764; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[000764] = 04040; $code[000764] = *I00764; sub I00764 { $core[000040] = 00765; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[000765] = 00240; $code[000765] = *I00765; sub I00765 { $lac &= (010000|$core[000640]); goto &fetch; }
$core[000766] = 07540; $code[000766] = *I00766; sub I00766 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000767] = 04040; $code[000767] = *I00767; sub I00767 { $core[000040] = 00770; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[000770] = 04040; $code[000770] = *I00770; sub I00770 { $core[000040] = 00771; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[000771] = 00015; $code[000771] = *I00771; sub I00771 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000772] = 00012; $code[000772] = *I00772; sub I00772 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000773] = 00001; $code[000773] = *I00773; sub I00773 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[001000] = 00000; $code[001000] = *S01000; sub S01000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001001] = 02215; $code[001001] = *I01001; sub I01001 { if (++$core[001015] == 010000) { $core[001015] = 0; $pc++; }$code[001015] = *emul8; goto &fetch; }
$core[001002] = 06046; $code[001002] = *I01002; sub I01002 { &emul8; goto &fetch; }
$core[001003] = 07200; $code[001003] = *I01003; sub I01003 { $lac &= 010000; goto &fetch; }
$core[001004] = 01215; $code[001004] = *L01004; sub L01004 { $lac += $core[001015]; goto &fetch; }
$core[001005] = 07640; $code[001005] = *I01005; sub I01005 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001006] = 07410; $code[001006] = *I01006; sub I01006 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001007] = 05212; $code[001007] = *I01007; sub I01007 { $pc = 001012; $inh = 0; goto &fetch; }
$core[001010] = 06041; $code[001010] = *I01010; sub I01010 { &emul8; goto &fetch; }
$core[001011] = 05204; $code[001011] = *I01011; sub I01011 { $pc = 001004; $inh = 0; goto &fetch; }
$core[001012] = 06042; $code[001012] = *L01012; sub L01012 { &emul8; goto &fetch; }
$core[001013] = 03215; $code[001013] = *I01013; sub I01013 { $core[001015] = $lac & 07777; $lac &= 010000; $code[001015] = *emul8; goto &fetch; }
$core[001014] = 05600; $code[001014] = *I01014; sub I01014 { $pc = ($ib<<12)+$core[512]; $inh = 0; goto &fetch; }
$core[001015] = 00000; $code[001015] = *D01015; sub D01015 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001016] = 00000; $code[001016] = *D01016; sub D01016 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001017] = 03216; $code[001017] = *I01017; sub I01017 { $core[001016] = $lac & 07777; $lac &= 010000; $code[001016] = *emul8; goto &fetch; }
$core[001020] = 07010; $code[001020] = *I01020; sub I01020 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001021] = 03157; $code[001021] = *I01021; sub I01021 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[001022] = 06201; $code[001022] = *I01022; sub I01022 { &emul8; goto &fetch; }
$core[001023] = 01777; $code[001023] = *I01023; sub I01023 { $lac += $core[($df<<12)+$core[639]]; goto &fetch; }
$core[001024] = 03000; $code[001024] = *I01024; sub I01024 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[001025] = 04160; $code[001025] = *I01025; sub I01025 { $core[000160] = 01026; $pc = 000160+1; $code[000160] = *emul8; $inh = 0; goto &fetch; }
$core[001026] = 06041; $code[001026] = *I01026; sub I01026 { &emul8; goto &fetch; }
$core[001027] = 05233; $code[001027] = *I01027; sub I01027 { $pc = 001033; $inh = 0; goto &fetch; }
$core[001030] = 06042; $code[001030] = *I01030; sub I01030 { &emul8; goto &fetch; }
$core[001031] = 03215; $code[001031] = *I01031; sub I01031 { $core[001015] = $lac & 07777; $lac &= 010000; $code[001015] = *emul8; goto &fetch; }
$core[001032] = 05236; $code[001032] = *I01032; sub I01032 { $pc = 001036; $inh = 0; goto &fetch; }
$core[001033] = 06031; $code[001033] = *L01033; sub L01033 { &emul8; goto &fetch; }
$core[001034] = 05244; $code[001034] = *I01034; sub I01034 { $pc = 001044; $inh = 0; goto &fetch; }
$core[001035] = 06032; $code[001035] = *I01035; sub I01035 { &emul8; goto &fetch; }
$core[001036] = 07300; $code[001036] = *L01036; sub L01036 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001037] = 01157; $code[001037] = *I01037; sub I01037 { $lac += $core[000157]; goto &fetch; }
$core[001040] = 07004; $code[001040] = *I01040; sub I01040 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001041] = 01216; $code[001041] = *I01041; sub I01041 { $lac += $core[001016]; goto &fetch; }
$core[001042] = 06001; $code[001042] = *I01042; sub I01042 { &emul8; goto &fetch; }
$core[001043] = 05400; $code[001043] = *I01043; sub I01043 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[001044] = 07402; $code[001044] = *L01044; sub L01044 { $hlt = 1; goto &fetch; }
$core[001045] = 05236; $code[001045] = *I01045; sub I01045 { $pc = 001036; $inh = 0; goto &fetch; }
$core[001046] = 00000; $code[001046] = *S01046; sub S01046 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001047] = 04426; $code[001047] = *I01047; sub I01047 { $core[($ib<<12)+$core[22]] = 01050; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001050] = 00710; $code[001050] = *I01050; sub I01050 { $lac &= (010000|$core[($df<<12)+$core[584]]); goto &fetch; }
$core[001051] = 04445; $code[001051] = *P01051; sub P01051 { $core[($ib<<12)+$core[37]] = 01052; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[001052] = 07773; $code[001052] = *I01052; sub I01052 { &emul8; goto &fetch; }
$core[001053] = 04447; $code[001053] = *I01053; sub I01053 { $core[($ib<<12)+$core[39]] = 01054; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[001054] = 04476; $code[001054] = *I01054; sub I01054 { $core[($ib<<12)+$core[62]] = 01055; $pc = ($ib<<12)+$core[62]+1; $code[($ib<<12)+$core[62]] = *emul8; $inh = 0; goto &fetch; }
$core[001055] = 04446; $code[001055] = *I01055; sub I01055 { $core[($ib<<12)+$core[38]] = 01056; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[001056] = 07776; $code[001056] = *I01056; sub I01056 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[001057] = 04426; $code[001057] = *I01057; sub I01057 { $core[($ib<<12)+$core[22]] = 01060; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001060] = 00646; $code[001060] = *I01060; sub I01060 { $lac &= (010000|$core[($df<<12)+$core[550]]); goto &fetch; }
$core[001061] = 04445; $code[001061] = *I01061; sub I01061 { $core[($ib<<12)+$core[37]] = 01062; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[001062] = 07772; $code[001062] = *I01062; sub I01062 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[001063] = 04455; $code[001063] = *I01063; sub I01063 { $core[($ib<<12)+$core[45]] = 01064; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[001064] = 00112; $code[001064] = *I01064; sub I01064 { $lac &= (010000|$core[000112]); goto &fetch; }
$core[001065] = 07776; $code[001065] = *I01065; sub I01065 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[001066] = 04426; $code[001066] = *I01066; sub I01066 { $core[($ib<<12)+$core[22]] = 01067; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001067] = 00651; $code[001067] = *I01067; sub I01067 { $lac &= (010000|$core[($df<<12)+$core[553]]); goto &fetch; }
$core[001070] = 04445; $code[001070] = *I01070; sub I01070 { $core[($ib<<12)+$core[37]] = 01071; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[001071] = 07771; $code[001071] = *D01071; sub D01071 { &emul8; goto &fetch; }
$core[001072] = 04455; $code[001072] = *I01072; sub I01072 { $core[($ib<<12)+$core[45]] = 01073; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[001073] = 00116; $code[001073] = *I01073; sub I01073 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[001074] = 07776; $code[001074] = *I01074; sub I01074 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[001075] = 05646; $code[001075] = *I01075; sub I01075 { $pc = ($ib<<12)+$core[550]; $inh = 0; goto &fetch; }
$core[001076] = 00000; $code[001076] = *S01076; sub S01076 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001077] = 01111; $code[001077] = *I01077; sub I01077 { $lac += $core[000111]; goto &fetch; }
$core[001100] = 03006; $code[001100] = *I01100; sub I01100 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[001101] = 01020; $code[001101] = *I01101; sub I01101 { $lac += $core[000020]; goto &fetch; }
$core[001102] = 07650; $code[001102] = *I01102; sub I01102 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001103] = 05676; $code[001103] = *I01103; sub I01103 { $pc = ($ib<<12)+$core[574]; $inh = 0; goto &fetch; }
$core[001104] = 01776; $code[001104] = *I01104; sub I01104 { $lac += $core[($df<<12)+$core[638]]; goto &fetch; }
$core[001105] = 07001; $code[001105] = *I01105; sub I01105 { $lac++; goto &fetch; }
$core[001106] = 03006; $code[001106] = *I01106; sub I01106 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[001107] = 05676; $code[001107] = *I01107; sub I01107 { $pc = ($ib<<12)+$core[574]; $inh = 0; goto &fetch; }
$core[001110] = 00000; $code[001110] = *S01110; sub S01110 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001111] = 01775; $code[001111] = *I01111; sub I01111 { $lac += $core[($df<<12)+$core[637]]; goto &fetch; }
$core[001112] = 03121; $code[001112] = *I01112; sub I01112 { $core[000121] = $lac & 07777; $lac &= 010000; $code[000121] = *emul8; goto &fetch; }
$core[001113] = 01020; $code[001113] = *I01113; sub I01113 { $lac += $core[000020]; goto &fetch; }
$core[001114] = 07650; $code[001114] = *I01114; sub I01114 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001115] = 05710; $code[001115] = *I01115; sub I01115 { $pc = ($ib<<12)+$core[584]; $inh = 0; goto &fetch; }
$core[001116] = 01775; $code[001116] = *I01116; sub I01116 { $lac += $core[($df<<12)+$core[637]]; goto &fetch; }
$core[001117] = 03005; $code[001117] = *I01117; sub I01117 { $core[000005] = $lac & 07777; $lac &= 010000; $code[000005] = *emul8; goto &fetch; }
$core[001120] = 01405; $code[001120] = *I01120; sub I01120 { $lac += $core[($df<<12)+$core[5]]; goto &fetch; }
$core[001121] = 03121; $code[001121] = *I01121; sub I01121 { $core[000121] = $lac & 07777; $lac &= 010000; $code[000121] = *emul8; goto &fetch; }
$core[001122] = 05710; $code[001122] = *I01122; sub I01122 { $pc = ($ib<<12)+$core[584]; $inh = 0; goto &fetch; }
$core[001123] = 00000; $code[001123] = *S01123; sub S01123 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001124] = 01111; $code[001124] = *I01124; sub I01124 { $lac += $core[000111]; goto &fetch; }
$core[001125] = 03006; $code[001125] = *I01125; sub I01125 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[001126] = 01020; $code[001126] = *I01126; sub I01126 { $lac += $core[000020]; goto &fetch; }
$core[001127] = 07650; $code[001127] = *I01127; sub I01127 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001130] = 05723; $code[001130] = *I01130; sub I01130 { $pc = ($ib<<12)+$core[595]; $inh = 0; goto &fetch; }
$core[001131] = 01774; $code[001131] = *I01131; sub I01131 { $lac += $core[($df<<12)+$core[636]]; goto &fetch; }
$core[001132] = 01147; $code[001132] = *I01132; sub I01132 { $lac += $core[000147]; goto &fetch; }
$core[001133] = 03006; $code[001133] = *I01133; sub I01133 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[001134] = 05723; $code[001134] = *I01134; sub I01134 { $pc = ($ib<<12)+$core[595]; $inh = 0; goto &fetch; }
$core[001135] = 00000; $code[001135] = *S01135; sub S01135 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001136] = 01773; $code[001136] = *I01136; sub I01136 { $lac += $core[($df<<12)+$core[635]]; goto &fetch; }
$core[001137] = 03121; $code[001137] = *I01137; sub I01137 { $core[000121] = $lac & 07777; $lac &= 010000; $code[000121] = *emul8; goto &fetch; }
$core[001140] = 01020; $code[001140] = *I01140; sub I01140 { $lac += $core[000020]; goto &fetch; }
$core[001141] = 07650; $code[001141] = *I01141; sub I01141 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001142] = 05735; $code[001142] = *I01142; sub I01142 { $pc = ($ib<<12)+$core[605]; $inh = 0; goto &fetch; }
$core[001143] = 01773; $code[001143] = *I01143; sub I01143 { $lac += $core[($df<<12)+$core[635]]; goto &fetch; }
$core[001144] = 03005; $code[001144] = *I01144; sub I01144 { $core[000005] = $lac & 07777; $lac &= 010000; $code[000005] = *emul8; goto &fetch; }
$core[001145] = 01405; $code[001145] = *I01145; sub I01145 { $lac += $core[($df<<12)+$core[5]]; goto &fetch; }
$core[001146] = 03121; $code[001146] = *I01146; sub I01146 { $core[000121] = $lac & 07777; $lac &= 010000; $code[000121] = *emul8; goto &fetch; }
$core[001147] = 05735; $code[001147] = *I01147; sub I01147 { $pc = ($ib<<12)+$core[605]; $inh = 0; goto &fetch; }
$core[001150] = 00000; $code[001150] = *S01150; sub S01150 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001151] = 07200; $code[001151] = *I01151; sub I01151 { $lac &= 010000; goto &fetch; }
$core[001152] = 01020; $code[001152] = *I01152; sub I01152 { $lac += $core[000020]; goto &fetch; }
$core[001153] = 07640; $code[001153] = *I01153; sub I01153 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001154] = 05357; $code[001154] = *I01154; sub I01154 { $pc = 001157; $inh = 0; goto &fetch; }
$core[001155] = 01104; $code[001155] = *I01155; sub I01155 { $lac += $core[000104]; goto &fetch; }
$core[001156] = 05750; $code[001156] = *I01156; sub I01156 { $pc = ($ib<<12)+$core[616]; $inh = 0; goto &fetch; }
$core[001157] = 01007; $code[001157] = *L01157; sub L01157 { $lac += $core[000007]; goto &fetch; }
$core[001160] = 05750; $code[001160] = *I01160; sub I01160 { $pc = ($ib<<12)+$core[616]; $inh = 0; goto &fetch; }
$core[001161] = 00000; $code[001161] = *S01161; sub S01161 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001162] = 07200; $code[001162] = *I01162; sub I01162 { $lac &= 010000; goto &fetch; }
$core[001163] = 01020; $code[001163] = *I01163; sub I01163 { $lac += $core[000020]; goto &fetch; }
$core[001164] = 07640; $code[001164] = *I01164; sub I01164 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001165] = 05370; $code[001165] = *I01165; sub I01165 { $pc = 001170; $inh = 0; goto &fetch; }
$core[001166] = 01105; $code[001166] = *I01166; sub I01166 { $lac += $core[000105]; goto &fetch; }
$core[001167] = 05761; $code[001167] = *I01167; sub I01167 { $pc = ($ib<<12)+$core[625]; $inh = 0; goto &fetch; }
$core[001170] = 01007; $code[001170] = *L01170; sub L01170 { $lac += $core[000007]; goto &fetch; }
$core[001171] = 07001; $code[001171] = *I01171; sub I01171 { $lac++; goto &fetch; }
$core[001172] = 05761; $code[001172] = *I01172; sub I01172 { $pc = ($ib<<12)+$core[625]; $inh = 0; goto &fetch; }
$core[001173] = 01472; $code[001173] = *P01173; sub P01173 { $lac += $core[($df<<12)+$core[58]]; goto &fetch; }
$core[001174] = 01415; $code[001174] = *P01174; sub P01174 { $core[000015] = 0000 if ++$core[000015] == 010000; $lac += $core[($df<<12)+$core[000015]]; goto &fetch; }
$core[001175] = 01271; $code[001175] = *P01175; sub P01175 { $lac += $core[001071]; goto &fetch; }
$core[001176] = 01215; $code[001176] = *P01176; sub P01176 { $lac += $core[001015]; goto &fetch; }
$core[001177] = 00000; $code[001177] = *P01177; sub P01177 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001200] = 00000; $code[001200] = *P01200; sub P01200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001201] = 07200; $code[001201] = *I01201; sub I01201 { $lac &= 010000; goto &fetch; }
$core[001202] = 03106; $code[001202] = *I01202; sub I01202 { $core[000106] = $lac & 07777; $lac &= 010000; $code[000106] = *emul8; goto &fetch; }
$core[001203] = 04432; $code[001203] = *I01203; sub I01203 { $core[($ib<<12)+$core[26]] = 01204; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[001204] = 00106; $code[001204] = *I01204; sub I01204 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[001205] = 00107; $code[001205] = *I01205; sub I01205 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[001206] = 07752; $code[001206] = *I01206; sub I01206 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[001207] = 01600; $code[001207] = *I01207; sub I01207 { $lac += $core[($df<<12)+$core[640]]; goto &fetch; }
$core[001210] = 03215; $code[001210] = *I01210; sub I01210 { $core[001215] = $lac & 07777; $lac &= 010000; $code[001215] = *emul8; goto &fetch; }
$core[001211] = 02200; $code[001211] = *I01211; sub I01211 { if (++$core[001200] == 010000) { $core[001200] = 0; $pc++; }$code[001200] = *emul8; goto &fetch; }
$core[001212] = 01600; $code[001212] = *I01212; sub I01212 { $lac += $core[($df<<12)+$core[640]]; goto &fetch; }
$core[001213] = 03144; $code[001213] = *I01213; sub I01213 { $core[000144] = $lac & 07777; $lac &= 010000; $code[000144] = *emul8; goto &fetch; }
$core[001214] = 04432; $code[001214] = *L01214; sub L01214 { $core[($ib<<12)+$core[26]] = 01215; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[001215] = 00000; $code[001215] = *D01215; sub D01215 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001216] = 00110; $code[001216] = *I01216; sub I01216 { $lac &= (010000|$core[000110]); goto &fetch; }
$core[001217] = 07776; $code[001217] = *I01217; sub I01217 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[001220] = 04777; $code[001220] = *I01220; sub I01220 { $core[($ib<<12)+$core[767]] = 01221; $pc = ($ib<<12)+$core[767]+1; $code[($ib<<12)+$core[767]] = *emul8; $inh = 0; goto &fetch; }
$core[001221] = 01215; $code[001221] = *I01221; sub I01221 { $lac += $core[001215]; goto &fetch; }
$core[001222] = 01147; $code[001222] = *I01222; sub I01222 { $lac += $core[000147]; goto &fetch; }
$core[001223] = 03225; $code[001223] = *I01223; sub I01223 { $core[001225] = $lac & 07777; $lac &= 010000; $code[001225] = *emul8; goto &fetch; }
$core[001224] = 04432; $code[001224] = *I01224; sub I01224 { $core[($ib<<12)+$core[26]] = 01225; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[001225] = 00000; $code[001225] = *D01225; sub D01225 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001226] = 00113; $code[001226] = *I01226; sub I01226 { $lac &= (010000|$core[000113]); goto &fetch; }
$core[001227] = 07776; $code[001227] = *I01227; sub I01227 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[001230] = 01111; $code[001230] = *I01230; sub I01230 { $lac += $core[000111]; goto &fetch; }
$core[001231] = 03115; $code[001231] = *I01231; sub I01231 { $core[000115] = $lac & 07777; $lac &= 010000; $code[000115] = *emul8; goto &fetch; }
$core[001232] = 03112; $code[001232] = *I01232; sub I01232 { $core[000112] = $lac & 07777; $lac &= 010000; $code[000112] = *emul8; goto &fetch; }
$core[001233] = 04263; $code[001233] = *L01233; sub L01233 { $core[001263] = 01234; $pc = 001263+1; $code[001263] = *emul8; $inh = 0; goto &fetch; }
$core[001234] = 04273; $code[001234] = *I01234; sub I01234 { $core[001273] = 01235; $pc = 001273+1; $code[001273] = *emul8; $inh = 0; goto &fetch; }
$core[001235] = 04433; $code[001235] = *I01235; sub I01235 { $core[($ib<<12)+$core[27]] = 01236; $pc = ($ib<<12)+$core[27]+1; $code[($ib<<12)+$core[27]] = *emul8; $inh = 0; goto &fetch; }
$core[001236] = 07774; $code[001236] = *I01236; sub I01236 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001237] = 05251; $code[001237] = *I01237; sub I01237 { $pc = 001251; $inh = 0; goto &fetch; }
$core[001240] = 04434; $code[001240] = *L01240; sub L01240 { $core[($ib<<12)+$core[28]] = 01241; $pc = ($ib<<12)+$core[28]+1; $code[($ib<<12)+$core[28]] = *emul8; $inh = 0; goto &fetch; }
$core[001241] = 05233; $code[001241] = *I01241; sub I01241 { $pc = 001233; $inh = 0; goto &fetch; }
$core[001242] = 02144; $code[001242] = *I01242; sub I01242 { if (++$core[000144] == 010000) { $core[000144] = 0; $pc++; }$code[000144] = *emul8; goto &fetch; }
$core[001243] = 05245; $code[001243] = *I01243; sub I01243 { $pc = 001245; $inh = 0; goto &fetch; }
$core[001244] = 05422; $code[001244] = *I01244; sub I01244 { $pc = ($ib<<12)+$core[18]; $inh = 0; goto &fetch; }
$core[001245] = 01215; $code[001245] = *L01245; sub L01245 { $lac += $core[001215]; goto &fetch; }
$core[001246] = 01151; $code[001246] = *I01246; sub I01246 { $lac += $core[000151]; goto &fetch; }
$core[001247] = 03215; $code[001247] = *I01247; sub I01247 { $core[001215] = $lac & 07777; $lac &= 010000; $code[001215] = *emul8; goto &fetch; }
$core[001250] = 05214; $code[001250] = *I01250; sub I01250 { $pc = 001214; $inh = 0; goto &fetch; }
$core[001251] = 04435; $code[001251] = *L01251; sub L01251 { $core[($ib<<12)+$core[29]] = 01252; $pc = ($ib<<12)+$core[29]+1; $code[($ib<<12)+$core[29]] = *emul8; $inh = 0; goto &fetch; }
$core[001252] = 05257; $code[001252] = *I01252; sub I01252 { $pc = 001257; $inh = 0; goto &fetch; }
$core[001253] = 04305; $code[001253] = *I01253; sub I01253 { $core[001305] = 01254; $pc = 001305+1; $code[001305] = *emul8; $inh = 0; goto &fetch; }
$core[001254] = 04435; $code[001254] = *I01254; sub I01254 { $core[($ib<<12)+$core[29]] = 01255; $pc = ($ib<<12)+$core[29]+1; $code[($ib<<12)+$core[29]] = *emul8; $inh = 0; goto &fetch; }
$core[001255] = 07410; $code[001255] = *I01255; sub I01255 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001256] = 05240; $code[001256] = *I01256; sub I01256 { $pc = 001240; $inh = 0; goto &fetch; }
$core[001257] = 04312; $code[001257] = *L01257; sub L01257 { $core[001312] = 01260; $pc = 001312+1; $code[001312] = *emul8; $inh = 0; goto &fetch; }
$core[001260] = 04325; $code[001260] = *I01260; sub I01260 { $core[001325] = 01261; $pc = 001325+1; $code[001325] = *emul8; $inh = 0; goto &fetch; }
$core[001261] = 04347; $code[001261] = *I01261; sub I01261 { $core[001347] = 01262; $pc = 001347+1; $code[001347] = *emul8; $inh = 0; goto &fetch; }
$core[001262] = 05240; $code[001262] = *I01262; sub I01262 { $pc = 001240; $inh = 0; goto &fetch; }
$core[001263] = 00000; $code[001263] = *S01263; sub S01263 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001264] = 07200; $code[001264] = *I01264; sub I01264 { $lac &= 010000; goto &fetch; }
$core[001265] = 01006; $code[001265] = *I01265; sub I01265 { $lac += $core[000006]; goto &fetch; }
$core[001266] = 03271; $code[001266] = *I01266; sub I01266 { $core[001271] = $lac & 07777; $lac &= 010000; $code[001271] = *emul8; goto &fetch; }
$core[001267] = 01110; $code[001267] = *I01267; sub I01267 { $lac += $core[000110]; goto &fetch; }
$core[001270] = 07425; $code[001270] = *I01270; sub I01270 { &emul8; goto &fetch; }
$core[001271] = 00000; $code[001271] = *D01271; sub D01271 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001272] = 05663; $code[001272] = *I01272; sub I01272 { $pc = ($ib<<12)+$core[691]; $inh = 0; goto &fetch; }
$core[001273] = 00000; $code[001273] = *S01273; sub S01273 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001274] = 03117; $code[001274] = *I01274; sub I01274 { $core[000117] = $lac & 07777; $lac &= 010000; $code[000117] = *emul8; goto &fetch; }
$core[001275] = 07004; $code[001275] = *I01275; sub I01275 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001276] = 03116; $code[001276] = *I01276; sub I01276 { $core[000116] = $lac & 07777; $lac &= 010000; $code[000116] = *emul8; goto &fetch; }
$core[001277] = 07501; $code[001277] = *I01277; sub I01277 { &emul8; goto &fetch; }
$core[001300] = 03120; $code[001300] = *I01300; sub I01300 { $core[000120] = $lac & 07777; $lac &= 010000; $code[000120] = *emul8; goto &fetch; }
$core[001301] = 04776; $code[001301] = *I01301; sub I01301 { $core[($ib<<12)+$core[766]] = 01302; $pc = ($ib<<12)+$core[766]+1; $code[($ib<<12)+$core[766]] = *emul8; $inh = 0; goto &fetch; }
$core[001302] = 07441; $code[001302] = *I01302; sub I01302 { &emul8; goto &fetch; }
$core[001303] = 03132; $code[001303] = *D01303; sub D01303 { $core[000132] = $lac & 07777; $lac &= 010000; $code[000132] = *emul8; goto &fetch; }
$core[001304] = 05673; $code[001304] = *I01304; sub I01304 { $pc = ($ib<<12)+$core[699]; $inh = 0; goto &fetch; }
$core[001305] = 00000; $code[001305] = *S01305; sub S01305 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001306] = 07200; $code[001306] = *I01306; sub I01306 { $lac &= 010000; goto &fetch; }
$core[001307] = 01102; $code[001307] = *I01307; sub I01307 { $lac += $core[000102]; goto &fetch; }
$core[001310] = 07402; $code[001310] = *I01310; sub I01310 { $hlt = 1; goto &fetch; }
$core[001311] = 05705; $code[001311] = *I01311; sub I01311 { $pc = ($ib<<12)+$core[709]; $inh = 0; goto &fetch; }
$core[001312] = 00000; $code[001312] = *S01312; sub S01312 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001313] = 04446; $code[001313] = *I01313; sub I01313 { $core[($ib<<12)+$core[38]] = 01314; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[001314] = 07776; $code[001314] = *I01314; sub I01314 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[001315] = 04426; $code[001315] = *I01315; sub I01315 { $core[($ib<<12)+$core[22]] = 01316; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001316] = 00551; $code[001316] = *I01316; sub I01316 { $lac &= (010000|$core[($df<<12)+$core[105]]); goto &fetch; }
$core[001317] = 04445; $code[001317] = *I01317; sub I01317 { $core[($ib<<12)+$core[37]] = 01320; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[001320] = 07774; $code[001320] = *I01320; sub I01320 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001321] = 04454; $code[001321] = *I01321; sub I01321 { $core[($ib<<12)+$core[44]] = 01322; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[001322] = 04436; $code[001322] = *I01322; sub I01322 { $core[($ib<<12)+$core[30]] = 01323; $pc = ($ib<<12)+$core[30]+1; $code[($ib<<12)+$core[30]] = *emul8; $inh = 0; goto &fetch; }
$core[001323] = 04305; $code[001323] = *I01323; sub I01323 { $core[001305] = 01324; $pc = 001305+1; $code[001305] = *emul8; $inh = 0; goto &fetch; }
$core[001324] = 05712; $code[001324] = *I01324; sub I01324 { $pc = ($ib<<12)+$core[714]; $inh = 0; goto &fetch; }
$core[001325] = 00000; $code[001325] = *S01325; sub S01325 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001326] = 04437; $code[001326] = *I01326; sub I01326 { $core[($ib<<12)+$core[31]] = 01327; $pc = ($ib<<12)+$core[31]+1; $code[($ib<<12)+$core[31]] = *emul8; $inh = 0; goto &fetch; }
$core[001327] = 05725; $code[001327] = *I01327; sub I01327 { $pc = ($ib<<12)+$core[725]; $inh = 0; goto &fetch; }
$core[001330] = 04424; $code[001330] = *I01330; sub I01330 { $core[($ib<<12)+$core[20]] = 01331; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[001331] = 00141; $code[001331] = *I01331; sub I01331 { $lac &= (010000|$core[000141]); goto &fetch; }
$core[001332] = 07634; $code[001332] = *I01332; sub I01332 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001333] = 03140; $code[001333] = *I01333; sub I01333 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[001334] = 04263; $code[001334] = *I01334; sub I01334 { $core[001263] = 01335; $pc = 001263+1; $code[001263] = *emul8; $inh = 0; goto &fetch; }
$core[001335] = 04273; $code[001335] = *L01335; sub L01335 { $core[001273] = 01336; $pc = 001273+1; $code[001273] = *emul8; $inh = 0; goto &fetch; }
$core[001336] = 04433; $code[001336] = *I01336; sub I01336 { $core[($ib<<12)+$core[27]] = 01337; $pc = ($ib<<12)+$core[27]+1; $code[($ib<<12)+$core[27]] = *emul8; $inh = 0; goto &fetch; }
$core[001337] = 07774; $code[001337] = *I01337; sub I01337 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001340] = 02140; $code[001340] = *I01340; sub I01340 { if (++$core[000140] == 010000) { $core[000140] = 0; $pc++; }$code[000140] = *emul8; goto &fetch; }
$core[001341] = 02141; $code[001341] = *I01341; sub I01341 { if (++$core[000141] == 010000) { $core[000141] = 0; $pc++; }$code[000141] = *emul8; goto &fetch; }
$core[001342] = 05335; $code[001342] = *I01342; sub I01342 { $pc = 001335; $inh = 0; goto &fetch; }
$core[001343] = 04451; $code[001343] = *I01343; sub I01343 { $core[($ib<<12)+$core[41]] = 01344; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[001344] = 04436; $code[001344] = *I01344; sub I01344 { $core[($ib<<12)+$core[30]] = 01345; $pc = ($ib<<12)+$core[30]+1; $code[($ib<<12)+$core[30]] = *emul8; $inh = 0; goto &fetch; }
$core[001345] = 04305; $code[001345] = *I01345; sub I01345 { $core[001305] = 01346; $pc = 001305+1; $code[001305] = *emul8; $inh = 0; goto &fetch; }
$core[001346] = 05725; $code[001346] = *I01346; sub I01346 { $pc = ($ib<<12)+$core[725]; $inh = 0; goto &fetch; }
$core[001347] = 00000; $code[001347] = *S01347; sub S01347 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001350] = 04440; $code[001350] = *I01350; sub I01350 { $core[($ib<<12)+$core[32]] = 01351; $pc = ($ib<<12)+$core[32]+1; $code[($ib<<12)+$core[32]] = *emul8; $inh = 0; goto &fetch; }
$core[001351] = 05747; $code[001351] = *I01351; sub I01351 { $pc = ($ib<<12)+$core[743]; $inh = 0; goto &fetch; }
$core[001352] = 04441; $code[001352] = *I01352; sub I01352 { $core[($ib<<12)+$core[33]] = 01353; $pc = ($ib<<12)+$core[33]+1; $code[($ib<<12)+$core[33]] = *emul8; $inh = 0; goto &fetch; }
$core[001353] = 04456; $code[001353] = *I01353; sub I01353 { $core[($ib<<12)+$core[46]] = 01354; $pc = ($ib<<12)+$core[46]+1; $code[($ib<<12)+$core[46]] = *emul8; $inh = 0; goto &fetch; }
$core[001354] = 04457; $code[001354] = *I01354; sub I01354 { $core[($ib<<12)+$core[47]] = 01355; $pc = ($ib<<12)+$core[47]+1; $code[($ib<<12)+$core[47]] = *emul8; $inh = 0; goto &fetch; }
$core[001355] = 04461; $code[001355] = *I01355; sub I01355 { $core[($ib<<12)+$core[49]] = 01356; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[001356] = 04263; $code[001356] = *L01356; sub L01356 { $core[001263] = 01357; $pc = 001263+1; $code[001263] = *emul8; $inh = 0; goto &fetch; }
$core[001357] = 05356; $code[001357] = *I01357; sub I01357 { $pc = 001356; $inh = 0; goto &fetch; }
$core[001360] = 07604; $code[001360] = *L01360; sub L01360 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001361] = 07012; $code[001361] = *I01361; sub I01361 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001362] = 07420; $code[001362] = *I01362; sub I01362 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001363] = 05366; $code[001363] = *I01363; sub I01363 { $pc = 001366; $inh = 0; goto &fetch; }
$core[001364] = 07710; $code[001364] = *I01364; sub I01364 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001365] = 05371; $code[001365] = *I01365; sub I01365 { $pc = 001371; $inh = 0; goto &fetch; }
$core[001366] = 07300; $code[001366] = *L01366; sub L01366 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001367] = 03020; $code[001367] = *I01367; sub I01367 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[001370] = 05775; $code[001370] = *I01370; sub I01370 { $pc = ($ib<<12)+$core[765]; $inh = 0; goto &fetch; }
$core[001371] = 07240; $code[001371] = *L01371; sub L01371 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001372] = 03020; $code[001372] = *I01372; sub I01372 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[001373] = 05775; $code[001373] = *I01373; sub I01373 { $pc = ($ib<<12)+$core[765]; $inh = 0; goto &fetch; }
$core[001375] = 00303; $code[001375] = *P01375; sub P01375 { $lac &= (010000|$core[001303]); goto &fetch; }
$core[001376] = 01110; $code[001376] = *P01376; sub P01376 { $lac += $core[000110]; goto &fetch; }
$core[001377] = 01076; $code[001377] = *P01377; sub P01377 { $lac += $core[000076]; goto &fetch; }
$core[001400] = 00000; $code[001400] = *P01400; sub P01400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001401] = 07200; $code[001401] = *I01401; sub I01401 { $lac &= 010000; goto &fetch; }
$core[001402] = 03106; $code[001402] = *I01402; sub I01402 { $core[000106] = $lac & 07777; $lac &= 010000; $code[000106] = *emul8; goto &fetch; }
$core[001403] = 04432; $code[001403] = *I01403; sub I01403 { $core[($ib<<12)+$core[26]] = 01404; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[001404] = 00106; $code[001404] = *I01404; sub I01404 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[001405] = 00107; $code[001405] = *I01405; sub I01405 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[001406] = 07752; $code[001406] = *I01406; sub I01406 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[001407] = 01600; $code[001407] = *I01407; sub I01407 { $lac += $core[($df<<12)+$core[768]]; goto &fetch; }
$core[001410] = 03215; $code[001410] = *I01410; sub I01410 { $core[001415] = $lac & 07777; $lac &= 010000; $code[001415] = *emul8; goto &fetch; }
$core[001411] = 02200; $code[001411] = *I01411; sub I01411 { if (++$core[001400] == 010000) { $core[001400] = 0; $pc++; }$code[001400] = *emul8; goto &fetch; }
$core[001412] = 01600; $code[001412] = *I01412; sub I01412 { $lac += $core[($df<<12)+$core[768]]; goto &fetch; }
$core[001413] = 03144; $code[001413] = *I01413; sub I01413 { $core[000144] = $lac & 07777; $lac &= 010000; $code[000144] = *emul8; goto &fetch; }
$core[001414] = 04432; $code[001414] = *L01414; sub L01414 { $core[($ib<<12)+$core[26]] = 01415; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[001415] = 00000; $code[001415] = *D01415; sub D01415 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001416] = 00107; $code[001416] = *I01416; sub I01416 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[001417] = 07775; $code[001417] = *I01417; sub I01417 { &emul8; goto &fetch; }
$core[001420] = 04777; $code[001420] = *I01420; sub I01420 { $core[($ib<<12)+$core[895]] = 01421; $pc = ($ib<<12)+$core[895]+1; $code[($ib<<12)+$core[895]] = *emul8; $inh = 0; goto &fetch; }
$core[001421] = 01215; $code[001421] = *I01421; sub I01421 { $lac += $core[001415]; goto &fetch; }
$core[001422] = 01150; $code[001422] = *I01422; sub I01422 { $lac += $core[000150]; goto &fetch; }
$core[001423] = 03225; $code[001423] = *I01423; sub I01423 { $core[001425] = $lac & 07777; $lac &= 010000; $code[001425] = *emul8; goto &fetch; }
$core[001424] = 04432; $code[001424] = *I01424; sub I01424 { $core[($ib<<12)+$core[26]] = 01425; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[001425] = 00000; $code[001425] = *D01425; sub D01425 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001426] = 00112; $code[001426] = *I01426; sub I01426 { $lac &= (010000|$core[000112]); goto &fetch; }
$core[001427] = 07775; $code[001427] = *I01427; sub I01427 { &emul8; goto &fetch; }
$core[001430] = 01111; $code[001430] = *I01430; sub I01430 { $lac += $core[000111]; goto &fetch; }
$core[001431] = 03115; $code[001431] = *I01431; sub I01431 { $core[000115] = $lac & 07777; $lac &= 010000; $code[000115] = *emul8; goto &fetch; }
$core[001432] = 04262; $code[001432] = *L01432; sub L01432 { $core[001462] = 01433; $pc = 001462+1; $code[001462] = *emul8; $inh = 0; goto &fetch; }
$core[001433] = 04274; $code[001433] = *I01433; sub I01433 { $core[001474] = 01434; $pc = 001474+1; $code[001474] = *emul8; $inh = 0; goto &fetch; }
$core[001434] = 04433; $code[001434] = *I01434; sub I01434 { $core[($ib<<12)+$core[27]] = 01435; $pc = ($ib<<12)+$core[27]+1; $code[($ib<<12)+$core[27]] = *emul8; $inh = 0; goto &fetch; }
$core[001435] = 07774; $code[001435] = *I01435; sub I01435 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001436] = 05250; $code[001436] = *I01436; sub I01436 { $pc = 001450; $inh = 0; goto &fetch; }
$core[001437] = 04434; $code[001437] = *L01437; sub L01437 { $core[($ib<<12)+$core[28]] = 01440; $pc = ($ib<<12)+$core[28]+1; $code[($ib<<12)+$core[28]] = *emul8; $inh = 0; goto &fetch; }
$core[001440] = 05232; $code[001440] = *I01440; sub I01440 { $pc = 001432; $inh = 0; goto &fetch; }
$core[001441] = 02144; $code[001441] = *I01441; sub I01441 { if (++$core[000144] == 010000) { $core[000144] = 0; $pc++; }$code[000144] = *emul8; goto &fetch; }
$core[001442] = 05244; $code[001442] = *I01442; sub I01442 { $pc = 001444; $inh = 0; goto &fetch; }
$core[001443] = 05422; $code[001443] = *I01443; sub I01443 { $pc = ($ib<<12)+$core[18]; $inh = 0; goto &fetch; }
$core[001444] = 01215; $code[001444] = *L01444; sub L01444 { $lac += $core[001415]; goto &fetch; }
$core[001445] = 01152; $code[001445] = *I01445; sub I01445 { $lac += $core[000152]; goto &fetch; }
$core[001446] = 03215; $code[001446] = *I01446; sub I01446 { $core[001415] = $lac & 07777; $lac &= 010000; $code[001415] = *emul8; goto &fetch; }
$core[001447] = 05214; $code[001447] = *I01447; sub I01447 { $pc = 001414; $inh = 0; goto &fetch; }
$core[001450] = 04435; $code[001450] = *L01450; sub L01450 { $core[($ib<<12)+$core[29]] = 01451; $pc = ($ib<<12)+$core[29]+1; $code[($ib<<12)+$core[29]] = *emul8; $inh = 0; goto &fetch; }
$core[001451] = 05256; $code[001451] = *I01451; sub I01451 { $pc = 001456; $inh = 0; goto &fetch; }
$core[001452] = 04306; $code[001452] = *I01452; sub I01452 { $core[001506] = 01453; $pc = 001506+1; $code[001506] = *emul8; $inh = 0; goto &fetch; }
$core[001453] = 04435; $code[001453] = *I01453; sub I01453 { $core[($ib<<12)+$core[29]] = 01454; $pc = ($ib<<12)+$core[29]+1; $code[($ib<<12)+$core[29]] = *emul8; $inh = 0; goto &fetch; }
$core[001454] = 07410; $code[001454] = *I01454; sub I01454 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001455] = 05237; $code[001455] = *I01455; sub I01455 { $pc = 001437; $inh = 0; goto &fetch; }
$core[001456] = 04313; $code[001456] = *L01456; sub L01456 { $core[001513] = 01457; $pc = 001513+1; $code[001513] = *emul8; $inh = 0; goto &fetch; }
$core[001457] = 04326; $code[001457] = *I01457; sub I01457 { $core[001526] = 01460; $pc = 001526+1; $code[001526] = *emul8; $inh = 0; goto &fetch; }
$core[001460] = 04350; $code[001460] = *I01460; sub I01460 { $core[001550] = 01461; $pc = 001550+1; $code[001550] = *emul8; $inh = 0; goto &fetch; }
$core[001461] = 05237; $code[001461] = *I01461; sub I01461 { $pc = 001437; $inh = 0; goto &fetch; }
$core[001462] = 00000; $code[001462] = *S01462; sub S01462 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001463] = 07200; $code[001463] = *I01463; sub I01463 { $lac &= 010000; goto &fetch; }
$core[001464] = 01006; $code[001464] = *I01464; sub I01464 { $lac += $core[000006]; goto &fetch; }
$core[001465] = 03272; $code[001465] = *I01465; sub I01465 { $core[001472] = $lac & 07777; $lac &= 010000; $code[001472] = *emul8; goto &fetch; }
$core[001466] = 01110; $code[001466] = *I01466; sub I01466 { $lac += $core[000110]; goto &fetch; }
$core[001467] = 07421; $code[001467] = *I01467; sub I01467 { &emul8; goto &fetch; }
$core[001470] = 01107; $code[001470] = *I01470; sub I01470 { $lac += $core[000107]; goto &fetch; }
$core[001471] = 07407; $code[001471] = *I01471; sub I01471 { &emul8; goto &fetch; }
$core[001472] = 00000; $code[001472] = *D01472; sub D01472 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001473] = 05662; $code[001473] = *I01473; sub I01473 { $pc = ($ib<<12)+$core[818]; $inh = 0; goto &fetch; }
$core[001474] = 00000; $code[001474] = *S01474; sub S01474 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001475] = 03117; $code[001475] = *I01475; sub I01475 { $core[000117] = $lac & 07777; $lac &= 010000; $code[000117] = *emul8; goto &fetch; }
$core[001476] = 07004; $code[001476] = *I01476; sub I01476 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001477] = 03116; $code[001477] = *I01477; sub I01477 { $core[000116] = $lac & 07777; $lac &= 010000; $code[000116] = *emul8; goto &fetch; }
$core[001500] = 07501; $code[001500] = *I01500; sub I01500 { &emul8; goto &fetch; }
$core[001501] = 03120; $code[001501] = *I01501; sub I01501 { $core[000120] = $lac & 07777; $lac &= 010000; $code[000120] = *emul8; goto &fetch; }
$core[001502] = 04776; $code[001502] = *I01502; sub I01502 { $core[($ib<<12)+$core[894]] = 01503; $pc = ($ib<<12)+$core[894]+1; $code[($ib<<12)+$core[894]] = *emul8; $inh = 0; goto &fetch; }
$core[001503] = 07441; $code[001503] = *I01503; sub I01503 { &emul8; goto &fetch; }
$core[001504] = 03132; $code[001504] = *I01504; sub I01504 { $core[000132] = $lac & 07777; $lac &= 010000; $code[000132] = *emul8; goto &fetch; }
$core[001505] = 05674; $code[001505] = *I01505; sub I01505 { $pc = ($ib<<12)+$core[828]; $inh = 0; goto &fetch; }
$core[001506] = 00000; $code[001506] = *S01506; sub S01506 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001507] = 07200; $code[001507] = *I01507; sub I01507 { $lac &= 010000; goto &fetch; }
$core[001510] = 01102; $code[001510] = *I01510; sub I01510 { $lac += $core[000102]; goto &fetch; }
$core[001511] = 07402; $code[001511] = *I01511; sub I01511 { $hlt = 1; goto &fetch; }
$core[001512] = 05706; $code[001512] = *I01512; sub I01512 { $pc = ($ib<<12)+$core[838]; $inh = 0; goto &fetch; }
$core[001513] = 00000; $code[001513] = *S01513; sub S01513 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001514] = 04446; $code[001514] = *I01514; sub I01514 { $core[($ib<<12)+$core[38]] = 01515; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[001515] = 07776; $code[001515] = *I01515; sub I01515 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[001516] = 04426; $code[001516] = *I01516; sub I01516 { $core[($ib<<12)+$core[22]] = 01517; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001517] = 00555; $code[001517] = *D01517; sub D01517 { $lac &= (010000|$core[($df<<12)+$core[109]]); goto &fetch; }
$core[001520] = 04445; $code[001520] = *I01520; sub I01520 { $core[($ib<<12)+$core[37]] = 01521; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[001521] = 07774; $code[001521] = *I01521; sub I01521 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001522] = 04454; $code[001522] = *I01522; sub I01522 { $core[($ib<<12)+$core[44]] = 01523; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[001523] = 04436; $code[001523] = *I01523; sub I01523 { $core[($ib<<12)+$core[30]] = 01524; $pc = ($ib<<12)+$core[30]+1; $code[($ib<<12)+$core[30]] = *emul8; $inh = 0; goto &fetch; }
$core[001524] = 04306; $code[001524] = *I01524; sub I01524 { $core[001506] = 01525; $pc = 001506+1; $code[001506] = *emul8; $inh = 0; goto &fetch; }
$core[001525] = 05713; $code[001525] = *I01525; sub I01525 { $pc = ($ib<<12)+$core[843]; $inh = 0; goto &fetch; }
$core[001526] = 00000; $code[001526] = *S01526; sub S01526 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001527] = 04437; $code[001527] = *I01527; sub I01527 { $core[($ib<<12)+$core[31]] = 01530; $pc = ($ib<<12)+$core[31]+1; $code[($ib<<12)+$core[31]] = *emul8; $inh = 0; goto &fetch; }
$core[001530] = 05726; $code[001530] = *I01530; sub I01530 { $pc = ($ib<<12)+$core[854]; $inh = 0; goto &fetch; }
$core[001531] = 04424; $code[001531] = *I01531; sub I01531 { $core[($ib<<12)+$core[20]] = 01532; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[001532] = 00141; $code[001532] = *I01532; sub I01532 { $lac &= (010000|$core[000141]); goto &fetch; }
$core[001533] = 07634; $code[001533] = *I01533; sub I01533 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001534] = 03140; $code[001534] = *I01534; sub I01534 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[001535] = 04262; $code[001535] = *I01535; sub I01535 { $core[001462] = 01536; $pc = 001462+1; $code[001462] = *emul8; $inh = 0; goto &fetch; }
$core[001536] = 04274; $code[001536] = *L01536; sub L01536 { $core[001474] = 01537; $pc = 001474+1; $code[001474] = *emul8; $inh = 0; goto &fetch; }
$core[001537] = 04433; $code[001537] = *I01537; sub I01537 { $core[($ib<<12)+$core[27]] = 01540; $pc = ($ib<<12)+$core[27]+1; $code[($ib<<12)+$core[27]] = *emul8; $inh = 0; goto &fetch; }
$core[001540] = 07774; $code[001540] = *I01540; sub I01540 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001541] = 02140; $code[001541] = *I01541; sub I01541 { if (++$core[000140] == 010000) { $core[000140] = 0; $pc++; }$code[000140] = *emul8; goto &fetch; }
$core[001542] = 02141; $code[001542] = *I01542; sub I01542 { if (++$core[000141] == 010000) { $core[000141] = 0; $pc++; }$code[000141] = *emul8; goto &fetch; }
$core[001543] = 05336; $code[001543] = *I01543; sub I01543 { $pc = 001536; $inh = 0; goto &fetch; }
$core[001544] = 04451; $code[001544] = *I01544; sub I01544 { $core[($ib<<12)+$core[41]] = 01545; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[001545] = 04436; $code[001545] = *I01545; sub I01545 { $core[($ib<<12)+$core[30]] = 01546; $pc = ($ib<<12)+$core[30]+1; $code[($ib<<12)+$core[30]] = *emul8; $inh = 0; goto &fetch; }
$core[001546] = 04306; $code[001546] = *I01546; sub I01546 { $core[001506] = 01547; $pc = 001506+1; $code[001506] = *emul8; $inh = 0; goto &fetch; }
$core[001547] = 05726; $code[001547] = *I01547; sub I01547 { $pc = ($ib<<12)+$core[854]; $inh = 0; goto &fetch; }
$core[001550] = 00000; $code[001550] = *S01550; sub S01550 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001551] = 04440; $code[001551] = *I01551; sub I01551 { $core[($ib<<12)+$core[32]] = 01552; $pc = ($ib<<12)+$core[32]+1; $code[($ib<<12)+$core[32]] = *emul8; $inh = 0; goto &fetch; }
$core[001552] = 05750; $code[001552] = *I01552; sub I01552 { $pc = ($ib<<12)+$core[872]; $inh = 0; goto &fetch; }
$core[001553] = 04442; $code[001553] = *I01553; sub I01553 { $core[($ib<<12)+$core[34]] = 01554; $pc = ($ib<<12)+$core[34]+1; $code[($ib<<12)+$core[34]] = *emul8; $inh = 0; goto &fetch; }
$core[001554] = 04456; $code[001554] = *I01554; sub I01554 { $core[($ib<<12)+$core[46]] = 01555; $pc = ($ib<<12)+$core[46]+1; $code[($ib<<12)+$core[46]] = *emul8; $inh = 0; goto &fetch; }
$core[001555] = 01134; $code[001555] = *I01555; sub I01555 { $lac += $core[000134]; goto &fetch; }
$core[001556] = 07640; $code[001556] = *I01556; sub I01556 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001557] = 05362; $code[001557] = *I01557; sub I01557 { $pc = 001562; $inh = 0; goto &fetch; }
$core[001560] = 04457; $code[001560] = *I01560; sub I01560 { $core[($ib<<12)+$core[47]] = 01561; $pc = ($ib<<12)+$core[47]+1; $code[($ib<<12)+$core[47]] = *emul8; $inh = 0; goto &fetch; }
$core[001561] = 04460; $code[001561] = *I01561; sub I01561 { $core[($ib<<12)+$core[48]] = 01562; $pc = ($ib<<12)+$core[48]+1; $code[($ib<<12)+$core[48]] = *emul8; $inh = 0; goto &fetch; }
$core[001562] = 04461; $code[001562] = *L01562; sub L01562 { $core[($ib<<12)+$core[49]] = 01563; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[001563] = 04262; $code[001563] = *L01563; sub L01563 { $core[001462] = 01564; $pc = 001462+1; $code[001462] = *emul8; $inh = 0; goto &fetch; }
$core[001564] = 05363; $code[001564] = *I01564; sub I01564 { $pc = 001563; $inh = 0; goto &fetch; }
$core[001565] = 00000; $code[001565] = *S01565; sub S01565 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001566] = 07300; $code[001566] = *I01566; sub I01566 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001567] = 01765; $code[001567] = *I01567; sub I01567 { $lac += $core[($df<<12)+$core[885]]; goto &fetch; }
$core[001570] = 03077; $code[001570] = *I01570; sub I01570 { $core[000077] = $lac & 07777; $lac &= 010000; $code[000077] = *emul8; goto &fetch; }
$core[001571] = 02365; $code[001571] = *I01571; sub I01571 { if (++$core[001565] == 010000) { $core[001565] = 0; $pc++; }$code[001565] = *emul8; goto &fetch; }
$core[001572] = 01765; $code[001572] = *I01572; sub I01572 { $lac += $core[($df<<12)+$core[885]]; goto &fetch; }
$core[001573] = 03477; $code[001573] = *I01573; sub I01573 { $core[($df<<12)+$core[63]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[63]] = *emul8; goto &fetch; }
$core[001574] = 02365; $code[001574] = *I01574; sub I01574 { if (++$core[001565] == 010000) { $core[001565] = 0; $pc++; }$code[001565] = *emul8; goto &fetch; }
$core[001575] = 05765; $code[001575] = *I01575; sub I01575 { $pc = ($ib<<12)+$core[885]; $inh = 0; goto &fetch; }
$core[001576] = 01135; $code[001576] = *P01576; sub P01576 { $lac += $core[000135]; goto &fetch; }
$core[001577] = 01123; $code[001577] = *P01577; sub P01577 { $lac += $core[000123]; goto &fetch; }
$core[001600] = 00000; $code[001600] = *S01600; sub S01600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001601] = 07604; $code[001601] = *I01601; sub I01601 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001602] = 00207; $code[001602] = *I01602; sub I01602 { $lac &= (010000|$core[001607]); goto &fetch; }
$core[001603] = 07640; $code[001603] = *I01603; sub I01603 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001604] = 05600; $code[001604] = *I01604; sub I01604 { $pc = ($ib<<12)+$core[896]; $inh = 0; goto &fetch; }
$core[001605] = 02200; $code[001605] = *I01605; sub I01605 { if (++$core[001600] == 010000) { $core[001600] = 0; $pc++; }$code[001600] = *emul8; goto &fetch; }
$core[001606] = 05600; $code[001606] = *I01606; sub I01606 { $pc = ($ib<<12)+$core[896]; $inh = 0; goto &fetch; }
$core[001607] = 00200; $code[001607] = *D01607; sub D01607 { $lac &= (010000|$core[001600]); goto &fetch; }
$core[001610] = 00000; $code[001610] = *S01610; sub S01610 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001611] = 07604; $code[001611] = *I01611; sub I01611 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001612] = 00217; $code[001612] = *I01612; sub I01612 { $lac &= (010000|$core[001617]); goto &fetch; }
$core[001613] = 07650; $code[001613] = *I01613; sub I01613 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001614] = 05610; $code[001614] = *I01614; sub I01614 { $pc = ($ib<<12)+$core[904]; $inh = 0; goto &fetch; }
$core[001615] = 02210; $code[001615] = *I01615; sub I01615 { if (++$core[001610] == 010000) { $core[001610] = 0; $pc++; }$code[001610] = *emul8; goto &fetch; }
$core[001616] = 05610; $code[001616] = *I01616; sub I01616 { $pc = ($ib<<12)+$core[904]; $inh = 0; goto &fetch; }
$core[001617] = 00100; $code[001617] = *D01617; sub D01617 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[001620] = 00000; $code[001620] = *S01620; sub S01620 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001621] = 07604; $code[001621] = *I01621; sub I01621 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001622] = 00227; $code[001622] = *I01622; sub I01622 { $lac &= (010000|$core[001627]); goto &fetch; }
$core[001623] = 07640; $code[001623] = *I01623; sub I01623 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001624] = 05620; $code[001624] = *I01624; sub I01624 { $pc = ($ib<<12)+$core[912]; $inh = 0; goto &fetch; }
$core[001625] = 02220; $code[001625] = *I01625; sub I01625 { if (++$core[001620] == 010000) { $core[001620] = 0; $pc++; }$code[001620] = *emul8; goto &fetch; }
$core[001626] = 05620; $code[001626] = *I01626; sub I01626 { $pc = ($ib<<12)+$core[912]; $inh = 0; goto &fetch; }
$core[001627] = 00040; $code[001627] = *D01627; sub D01627 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[001630] = 00000; $code[001630] = *S01630; sub S01630 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001631] = 07604; $code[001631] = *I01631; sub I01631 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001632] = 00237; $code[001632] = *I01632; sub I01632 { $lac &= (010000|$core[001637]); goto &fetch; }
$core[001633] = 07650; $code[001633] = *I01633; sub I01633 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001634] = 05630; $code[001634] = *I01634; sub I01634 { $pc = ($ib<<12)+$core[920]; $inh = 0; goto &fetch; }
$core[001635] = 02230; $code[001635] = *I01635; sub I01635 { if (++$core[001630] == 010000) { $core[001630] = 0; $pc++; }$code[001630] = *emul8; goto &fetch; }
$core[001636] = 05630; $code[001636] = *I01636; sub I01636 { $pc = ($ib<<12)+$core[920]; $inh = 0; goto &fetch; }
$core[001637] = 00020; $code[001637] = *D01637; sub D01637 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[001640] = 00000; $code[001640] = *S01640; sub S01640 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001641] = 07604; $code[001641] = *I01641; sub I01641 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001642] = 00247; $code[001642] = *I01642; sub I01642 { $lac &= (010000|$core[001647]); goto &fetch; }
$core[001643] = 07650; $code[001643] = *I01643; sub I01643 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001644] = 05640; $code[001644] = *I01644; sub I01644 { $pc = ($ib<<12)+$core[928]; $inh = 0; goto &fetch; }
$core[001645] = 02240; $code[001645] = *I01645; sub I01645 { if (++$core[001640] == 010000) { $core[001640] = 0; $pc++; }$code[001640] = *emul8; goto &fetch; }
$core[001646] = 05640; $code[001646] = *I01646; sub I01646 { $pc = ($ib<<12)+$core[928]; $inh = 0; goto &fetch; }
$core[001647] = 00010; $code[001647] = *D01647; sub D01647 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[001650] = 00000; $code[001650] = *S01650; sub S01650 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001651] = 07200; $code[001651] = *I01651; sub I01651 { $lac &= 010000; goto &fetch; }
$core[001652] = 01650; $code[001652] = *I01652; sub I01652 { $lac += $core[($df<<12)+$core[936]]; goto &fetch; }
$core[001653] = 03273; $code[001653] = *I01653; sub I01653 { $core[001673] = $lac & 07777; $lac &= 010000; $code[001673] = *emul8; goto &fetch; }
$core[001654] = 02250; $code[001654] = *I01654; sub I01654 { if (++$core[001650] == 010000) { $core[001650] = 0; $pc++; }$code[001650] = *emul8; goto &fetch; }
$core[001655] = 01650; $code[001655] = *I01655; sub I01655 { $lac += $core[($df<<12)+$core[936]]; goto &fetch; }
$core[001656] = 03274; $code[001656] = *I01656; sub I01656 { $core[001674] = $lac & 07777; $lac &= 010000; $code[001674] = *emul8; goto &fetch; }
$core[001657] = 02250; $code[001657] = *I01657; sub I01657 { if (++$core[001650] == 010000) { $core[001650] = 0; $pc++; }$code[001650] = *emul8; goto &fetch; }
$core[001660] = 01650; $code[001660] = *I01660; sub I01660 { $lac += $core[($df<<12)+$core[936]]; goto &fetch; }
$core[001661] = 03275; $code[001661] = *I01661; sub I01661 { $core[001675] = $lac & 07777; $lac &= 010000; $code[001675] = *emul8; goto &fetch; }
$core[001662] = 02250; $code[001662] = *I01662; sub I01662 { if (++$core[001650] == 010000) { $core[001650] = 0; $pc++; }$code[001650] = *emul8; goto &fetch; }
$core[001663] = 07200; $code[001663] = *L01663; sub L01663 { $lac &= 010000; goto &fetch; }
$core[001664] = 01673; $code[001664] = *I01664; sub I01664 { $lac += $core[($df<<12)+$core[955]]; goto &fetch; }
$core[001665] = 03674; $code[001665] = *I01665; sub I01665 { $core[($df<<12)+$core[956]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[956]] = *emul8; goto &fetch; }
$core[001666] = 02273; $code[001666] = *I01666; sub I01666 { if (++$core[001673] == 010000) { $core[001673] = 0; $pc++; }$code[001673] = *emul8; goto &fetch; }
$core[001667] = 02274; $code[001667] = *I01667; sub I01667 { if (++$core[001674] == 010000) { $core[001674] = 0; $pc++; }$code[001674] = *emul8; goto &fetch; }
$core[001670] = 02275; $code[001670] = *I01670; sub I01670 { if (++$core[001675] == 010000) { $core[001675] = 0; $pc++; }$code[001675] = *emul8; goto &fetch; }
$core[001671] = 05263; $code[001671] = *P01671; sub P01671 { $pc = 001663; $inh = 0; goto &fetch; }
$core[001672] = 05650; $code[001672] = *I01672; sub I01672 { $pc = ($ib<<12)+$core[936]; $inh = 0; goto &fetch; }
$core[001673] = 00000; $code[001673] = *P01673; sub P01673 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001674] = 00000; $code[001674] = *P01674; sub P01674 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001675] = 00000; $code[001675] = *D01675; sub D01675 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001676] = 00000; $code[001676] = *S01676; sub S01676 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001677] = 01676; $code[001677] = *I01677; sub I01677 { $lac += $core[($df<<12)+$core[958]]; goto &fetch; }
$core[001700] = 03325; $code[001700] = *I01700; sub I01700 { $core[001725] = $lac & 07777; $lac &= 010000; $code[001725] = *emul8; goto &fetch; }
$core[001701] = 02276; $code[001701] = *I01701; sub I01701 { if (++$core[001676] == 010000) { $core[001676] = 0; $pc++; }$code[001676] = *emul8; goto &fetch; }
$core[001702] = 01321; $code[001702] = *I01702; sub I01702 { $lac += $core[001721]; goto &fetch; }
$core[001703] = 03323; $code[001703] = *I01703; sub I01703 { $core[001723] = $lac & 07777; $lac &= 010000; $code[001723] = *emul8; goto &fetch; }
$core[001704] = 01322; $code[001704] = *I01704; sub I01704 { $lac += $core[001722]; goto &fetch; }
$core[001705] = 03324; $code[001705] = *I01705; sub I01705 { $core[001724] = $lac & 07777; $lac &= 010000; $code[001724] = *emul8; goto &fetch; }
$core[001706] = 01723; $code[001706] = *L01706; sub L01706 { $lac += $core[($df<<12)+$core[979]]; goto &fetch; }
$core[001707] = 07041; $code[001707] = *I01707; sub I01707 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001710] = 01724; $code[001710] = *I01710; sub I01710 { $lac += $core[($df<<12)+$core[980]]; goto &fetch; }
$core[001711] = 07640; $code[001711] = *I01711; sub I01711 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001712] = 05676; $code[001712] = *I01712; sub I01712 { $pc = ($ib<<12)+$core[958]; $inh = 0; goto &fetch; }
$core[001713] = 02323; $code[001713] = *I01713; sub I01713 { if (++$core[001723] == 010000) { $core[001723] = 0; $pc++; }$code[001723] = *emul8; goto &fetch; }
$core[001714] = 02324; $code[001714] = *I01714; sub I01714 { if (++$core[001724] == 010000) { $core[001724] = 0; $pc++; }$code[001724] = *emul8; goto &fetch; }
$core[001715] = 02325; $code[001715] = *I01715; sub I01715 { if (++$core[001725] == 010000) { $core[001725] = 0; $pc++; }$code[001725] = *emul8; goto &fetch; }
$core[001716] = 05306; $code[001716] = *I01716; sub I01716 { $pc = 001706; $inh = 0; goto &fetch; }
$core[001717] = 02276; $code[001717] = *I01717; sub I01717 { if (++$core[001676] == 010000) { $core[001676] = 0; $pc++; }$code[001676] = *emul8; goto &fetch; }
$core[001720] = 05676; $code[001720] = *I01720; sub I01720 { $pc = ($ib<<12)+$core[958]; $inh = 0; goto &fetch; }
$core[001721] = 00112; $code[001721] = *D01721; sub D01721 { $lac &= (010000|$core[000112]); goto &fetch; }
$core[001722] = 00116; $code[001722] = *D01722; sub D01722 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[001723] = 00000; $code[001723] = *P01723; sub P01723 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001724] = 00000; $code[001724] = *P01724; sub P01724 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001725] = 00000; $code[001725] = *D01725; sub D01725 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001726] = 00000; $code[001726] = *S01726; sub S01726 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001727] = 04426; $code[001727] = *I01727; sub I01727 { $core[($ib<<12)+$core[22]] = 01730; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001730] = 00545; $code[001730] = *I01730; sub I01730 { $lac &= (010000|$core[($df<<12)+$core[101]]); goto &fetch; }
$core[001731] = 05726; $code[001731] = *I01731; sub I01731 { $pc = ($ib<<12)+$core[982]; $inh = 0; goto &fetch; }
$core[001732] = 00000; $code[001732] = *S01732; sub S01732 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001733] = 04426; $code[001733] = *I01733; sub I01733 { $core[($ib<<12)+$core[22]] = 01734; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001734] = 00547; $code[001734] = *I01734; sub I01734 { $lac &= (010000|$core[($df<<12)+$core[103]]); goto &fetch; }
$core[001735] = 05732; $code[001735] = *I01735; sub I01735 { $pc = ($ib<<12)+$core[986]; $inh = 0; goto &fetch; }
$core[001736] = 00000; $code[001736] = *S01736; sub S01736 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001737] = 07200; $code[001737] = *I01737; sub I01737 { $lac &= 010000; goto &fetch; }
$core[001740] = 01736; $code[001740] = *I01740; sub I01740 { $lac += $core[($df<<12)+$core[990]]; goto &fetch; }
$core[001741] = 03352; $code[001741] = *I01741; sub I01741 { $core[001752] = $lac & 07777; $lac &= 010000; $code[001752] = *emul8; goto &fetch; }
$core[001742] = 02336; $code[001742] = *I01742; sub I01742 { if (++$core[001736] == 010000) { $core[001736] = 0; $pc++; }$code[001736] = *emul8; goto &fetch; }
$core[001743] = 04426; $code[001743] = *L01743; sub L01743 { $core[($ib<<12)+$core[22]] = 01744; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001744] = 01750; $code[001744] = *I01744; sub I01744 { $lac += $core[($df<<12)+$core[1000]]; goto &fetch; }
$core[001745] = 02352; $code[001745] = *I01745; sub I01745 { if (++$core[001752] == 010000) { $core[001752] = 0; $pc++; }$code[001752] = *emul8; goto &fetch; }
$core[001746] = 05343; $code[001746] = *I01746; sub I01746 { $pc = 001743; $inh = 0; goto &fetch; }
$core[001747] = 05736; $code[001747] = *I01747; sub I01747 { $pc = ($ib<<12)+$core[990]; $inh = 0; goto &fetch; }
$core[001750] = 04000; $code[001750] = *P01750; sub P01750 { $core[000000] = 01751; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[001751] = 00100; $code[001751] = *I01751; sub I01751 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[001752] = 00000; $code[001752] = *D01752; sub D01752 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001753] = 00000; $code[001753] = *S01753; sub S01753 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001754] = 07200; $code[001754] = *I01754; sub I01754 { $lac &= 010000; goto &fetch; }
$core[001755] = 01753; $code[001755] = *I01755; sub I01755 { $lac += $core[($df<<12)+$core[1003]]; goto &fetch; }
$core[001756] = 03370; $code[001756] = *I01756; sub I01756 { $core[001770] = $lac & 07777; $lac &= 010000; $code[001770] = *emul8; goto &fetch; }
$core[001757] = 02353; $code[001757] = *I01757; sub I01757 { if (++$core[001753] == 010000) { $core[001753] = 0; $pc++; }$code[001753] = *emul8; goto &fetch; }
$core[001760] = 04426; $code[001760] = *L01760; sub L01760 { $core[($ib<<12)+$core[22]] = 01761; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001761] = 01765; $code[001761] = *I01761; sub I01761 { $lac += $core[($df<<12)+$core[1013]]; goto &fetch; }
$core[001762] = 02370; $code[001762] = *I01762; sub I01762 { if (++$core[001770] == 010000) { $core[001770] = 0; $pc++; }$code[001770] = *emul8; goto &fetch; }
$core[001763] = 05360; $code[001763] = *I01763; sub I01763 { $pc = 001760; $inh = 0; goto &fetch; }
$core[001764] = 05753; $code[001764] = *I01764; sub I01764 { $pc = ($ib<<12)+$core[1003]; $inh = 0; goto &fetch; }
$core[001765] = 00015; $code[001765] = *P01765; sub P01765 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[001766] = 00012; $code[001766] = *I01766; sub I01766 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[001767] = 00001; $code[001767] = *I01767; sub I01767 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[001770] = 00000; $code[001770] = *D01770; sub D01770 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001771] = 00000; $code[001771] = *S01771; sub S01771 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001772] = 04445; $code[001772] = *I01772; sub I01772 { $core[($ib<<12)+$core[37]] = 01773; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[001773] = 07766; $code[001773] = *I01773; sub I01773 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[001774] = 04426; $code[001774] = *I01774; sub I01774 { $core[($ib<<12)+$core[22]] = 01775; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[001775] = 00671; $code[001775] = *I01775; sub I01775 { $lac &= (010000|$core[($df<<12)+$core[953]]); goto &fetch; }
$core[001776] = 05771; $code[001776] = *I01776; sub I01776 { $pc = ($ib<<12)+$core[1017]; $inh = 0; goto &fetch; }
$core[002000] = 00000; $code[002000] = *S02000; sub S02000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002001] = 04426; $code[002001] = *I02001; sub I02001 { $core[($ib<<12)+$core[22]] = 02002; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002002] = 00657; $code[002002] = *I02002; sub I02002 { $lac &= (010000|$core[($df<<12)+$core[1071]]); goto &fetch; }
$core[002003] = 04445; $code[002003] = *I02003; sub I02003 { $core[($ib<<12)+$core[37]] = 02004; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002004] = 07771; $code[002004] = *I02004; sub I02004 { &emul8; goto &fetch; }
$core[002005] = 04426; $code[002005] = *I02005; sub I02005 { $core[($ib<<12)+$core[22]] = 02006; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002006] = 00661; $code[002006] = *I02006; sub I02006 { $lac &= (010000|$core[($df<<12)+$core[1073]]); goto &fetch; }
$core[002007] = 04445; $code[002007] = *I02007; sub I02007 { $core[($ib<<12)+$core[37]] = 02010; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002010] = 07766; $code[002010] = *I02010; sub I02010 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002011] = 04426; $code[002011] = *I02011; sub I02011 { $core[($ib<<12)+$core[22]] = 02012; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002012] = 00665; $code[002012] = *I02012; sub I02012 { $lac &= (010000|$core[($df<<12)+$core[1077]]); goto &fetch; }
$core[002013] = 05600; $code[002013] = *I02013; sub I02013 { $pc = ($ib<<12)+$core[1024]; $inh = 0; goto &fetch; }
$core[002014] = 00000; $code[002014] = *S02014; sub S02014 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002015] = 04447; $code[002015] = *I02015; sub I02015 { $core[($ib<<12)+$core[39]] = 02016; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[002016] = 04450; $code[002016] = *I02016; sub I02016 { $core[($ib<<12)+$core[40]] = 02017; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[002017] = 04476; $code[002017] = *I02017; sub I02017 { $core[($ib<<12)+$core[62]] = 02020; $pc = ($ib<<12)+$core[62]+1; $code[($ib<<12)+$core[62]] = *emul8; $inh = 0; goto &fetch; }
$core[002020] = 04446; $code[002020] = *I02020; sub I02020 { $core[($ib<<12)+$core[38]] = 02021; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002021] = 07776; $code[002021] = *I02021; sub I02021 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002022] = 04426; $code[002022] = *I02022; sub I02022 { $core[($ib<<12)+$core[22]] = 02023; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002023] = 00643; $code[002023] = *I02023; sub I02023 { $lac &= (010000|$core[($df<<12)+$core[1059]]); goto &fetch; }
$core[002024] = 04445; $code[002024] = *I02024; sub I02024 { $core[($ib<<12)+$core[37]] = 02025; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002025] = 07772; $code[002025] = *I02025; sub I02025 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[002026] = 04455; $code[002026] = *I02026; sub I02026 { $core[($ib<<12)+$core[45]] = 02027; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002027] = 00106; $code[002027] = *I02027; sub I02027 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[002030] = 07775; $code[002030] = *I02030; sub I02030 { &emul8; goto &fetch; }
$core[002031] = 04446; $code[002031] = *I02031; sub I02031 { $core[($ib<<12)+$core[38]] = 02032; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002032] = 07777; $code[002032] = *I02032; sub I02032 { &emul8; goto &fetch; }
$core[002033] = 04426; $code[002033] = *I02033; sub I02033 { $core[($ib<<12)+$core[22]] = 02034; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002034] = 00646; $code[002034] = *I02034; sub I02034 { $lac &= (010000|$core[($df<<12)+$core[1062]]); goto &fetch; }
$core[002035] = 04445; $code[002035] = *I02035; sub I02035 { $core[($ib<<12)+$core[37]] = 02036; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002036] = 07772; $code[002036] = *I02036; sub I02036 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[002037] = 04455; $code[002037] = *I02037; sub I02037 { $core[($ib<<12)+$core[45]] = 02040; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002040] = 00112; $code[002040] = *I02040; sub I02040 { $lac &= (010000|$core[000112]); goto &fetch; }
$core[002041] = 07775; $code[002041] = *I02041; sub I02041 { &emul8; goto &fetch; }
$core[002042] = 04426; $code[002042] = *I02042; sub I02042 { $core[($ib<<12)+$core[22]] = 02043; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002043] = 00651; $code[002043] = *P02043; sub P02043 { $lac &= (010000|$core[($df<<12)+$core[1065]]); goto &fetch; }
$core[002044] = 04445; $code[002044] = *I02044; sub I02044 { $core[($ib<<12)+$core[37]] = 02045; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002045] = 07771; $code[002045] = *I02045; sub I02045 { &emul8; goto &fetch; }
$core[002046] = 04455; $code[002046] = *P02046; sub P02046 { $core[($ib<<12)+$core[45]] = 02047; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002047] = 00116; $code[002047] = *I02047; sub I02047 { $lac &= (010000|$core[000116]); goto &fetch; }
$core[002050] = 07775; $code[002050] = *I02050; sub I02050 { &emul8; goto &fetch; }
$core[002051] = 04446; $code[002051] = *P02051; sub P02051 { $core[($ib<<12)+$core[38]] = 02052; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002052] = 07777; $code[002052] = *I02052; sub I02052 { &emul8; goto &fetch; }
$core[002053] = 04426; $code[002053] = *I02053; sub I02053 { $core[($ib<<12)+$core[22]] = 02054; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002054] = 00654; $code[002054] = *P02054; sub P02054 { $lac &= (010000|$core[($df<<12)+$core[1068]]); goto &fetch; }
$core[002055] = 04445; $code[002055] = *I02055; sub I02055 { $core[($ib<<12)+$core[37]] = 02056; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002056] = 07770; $code[002056] = *I02056; sub I02056 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002057] = 04453; $code[002057] = *P02057; sub P02057 { $core[($ib<<12)+$core[43]] = 02060; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[002060] = 00132; $code[002060] = *D02060; sub D02060 { $lac &= (010000|$core[000132]); goto &fetch; }
$core[002061] = 04446; $code[002061] = *P02061; sub P02061 { $core[($ib<<12)+$core[38]] = 02062; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002062] = 07777; $code[002062] = *I02062; sub I02062 { &emul8; goto &fetch; }
$core[002063] = 05614; $code[002063] = *I02063; sub I02063 { $pc = ($ib<<12)+$core[1036]; $inh = 0; goto &fetch; }
$core[002064] = 00000; $code[002064] = *S02064; sub S02064 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002065] = 04446; $code[002065] = *P02065; sub P02065 { $core[($ib<<12)+$core[38]] = 02066; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002066] = 07776; $code[002066] = *I02066; sub I02066 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002067] = 04426; $code[002067] = *I02067; sub I02067 { $core[($ib<<12)+$core[22]] = 02070; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002070] = 00675; $code[002070] = *I02070; sub I02070 { $lac &= (010000|$core[($df<<12)+$core[1085]]); goto &fetch; }
$core[002071] = 04277; $code[002071] = *I02071; sub I02071 { $core[002077] = 02072; $pc = 002077+1; $code[002077] = *emul8; $inh = 0; goto &fetch; }
$core[002072] = 00140; $code[002072] = *I02072; sub I02072 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[002073] = 04476; $code[002073] = *I02073; sub I02073 { $core[($ib<<12)+$core[62]] = 02074; $pc = ($ib<<12)+$core[62]+1; $code[($ib<<12)+$core[62]] = *emul8; $inh = 0; goto &fetch; }
$core[002074] = 04446; $code[002074] = *I02074; sub I02074 { $core[($ib<<12)+$core[38]] = 02075; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002075] = 07777; $code[002075] = *P02075; sub P02075 { &emul8; goto &fetch; }
$core[002076] = 05664; $code[002076] = *I02076; sub I02076 { $pc = ($ib<<12)+$core[1076]; $inh = 0; goto &fetch; }
$core[002077] = 00000; $code[002077] = *S02077; sub S02077 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002100] = 04424; $code[002100] = *I02100; sub I02100 { $core[($ib<<12)+$core[20]] = 02101; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[002101] = 02143; $code[002101] = *I02101; sub I02101 { if (++$core[000143] == 010000) { $core[000143] = 0; $pc++; }$code[000143] = *emul8; goto &fetch; }
$core[002102] = 07774; $code[002102] = *I02102; sub I02102 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002103] = 01334; $code[002103] = *I02103; sub I02103 { $lac += $core[002134]; goto &fetch; }
$core[002104] = 03315; $code[002104] = *I02104; sub I02104 { $core[002115] = $lac & 07777; $lac &= 010000; $code[002115] = *emul8; goto &fetch; }
$core[002105] = 01677; $code[002105] = *I02105; sub I02105 { $lac += $core[($df<<12)+$core[1087]]; goto &fetch; }
$core[002106] = 02277; $code[002106] = *I02106; sub I02106 { if (++$core[002077] == 010000) { $core[002077] = 0; $pc++; }$code[002077] = *emul8; goto &fetch; }
$core[002107] = 03342; $code[002107] = *D02107; sub D02107 { $core[002142] = $lac & 07777; $lac &= 010000; $code[002142] = *emul8; goto &fetch; }
$core[002110] = 01742; $code[002110] = *I02110; sub I02110 { $lac += $core[($df<<12)+$core[1122]]; goto &fetch; }
$core[002111] = 03341; $code[002111] = *I02111; sub I02111 { $core[002141] = $lac & 07777; $lac &= 010000; $code[002141] = *emul8; goto &fetch; }
$core[002112] = 03342; $code[002112] = *L02112; sub L02112 { $core[002142] = $lac & 07777; $lac &= 010000; $code[002142] = *emul8; goto &fetch; }
$core[002113] = 07100; $code[002113] = *L02113; sub L02113 { $lac &= 07777; goto &fetch; }
$core[002114] = 01341; $code[002114] = *I02114; sub I02114 { $lac += $core[002141]; goto &fetch; }
$core[002115] = 01335; $code[002115] = *D02115; sub D02115 { $lac += $core[002135]; goto &fetch; }
$core[002116] = 07420; $code[002116] = *I02116; sub I02116 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002117] = 05323; $code[002117] = *I02117; sub I02117 { $pc = 002123; $inh = 0; goto &fetch; }
$core[002120] = 02342; $code[002120] = *I02120; sub I02120 { if (++$core[002142] == 010000) { $core[002142] = 0; $pc++; }$code[002142] = *emul8; goto &fetch; }
$core[002121] = 03341; $code[002121] = *I02121; sub I02121 { $core[002141] = $lac & 07777; $lac &= 010000; $code[002141] = *emul8; goto &fetch; }
$core[002122] = 05313; $code[002122] = *I02122; sub I02122 { $pc = 002113; $inh = 0; goto &fetch; }
$core[002123] = 07200; $code[002123] = *L02123; sub L02123 { $lac &= 010000; goto &fetch; }
$core[002124] = 01342; $code[002124] = *I02124; sub I02124 { $lac += $core[002142]; goto &fetch; }
$core[002125] = 01344; $code[002125] = *I02125; sub I02125 { $lac += $core[002144]; goto &fetch; }
$core[002126] = 04474; $code[002126] = *I02126; sub I02126 { $core[($ib<<12)+$core[60]] = 02127; $pc = ($ib<<12)+$core[60]+1; $code[($ib<<12)+$core[60]] = *emul8; $inh = 0; goto &fetch; }
$core[002127] = 07300; $code[002127] = *I02127; sub I02127 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002130] = 02315; $code[002130] = *I02130; sub I02130 { if (++$core[002115] == 010000) { $core[002115] = 0; $pc++; }$code[002115] = *emul8; goto &fetch; }
$core[002131] = 02343; $code[002131] = *I02131; sub I02131 { if (++$core[002143] == 010000) { $core[002143] = 0; $pc++; }$code[002143] = *emul8; goto &fetch; }
$core[002132] = 05312; $code[002132] = *I02132; sub I02132 { $pc = 002112; $inh = 0; goto &fetch; }
$core[002133] = 05677; $code[002133] = *I02133; sub I02133 { $pc = ($ib<<12)+$core[1087]; $inh = 0; goto &fetch; }
$core[002134] = 01335; $code[002134] = *D02134; sub D02134 { $lac += $core[002135]; goto &fetch; }
$core[002135] = 06030; $code[002135] = *D02135; sub D02135 { &emul8; goto &fetch; }
$core[002136] = 07634; $code[002136] = *I02136; sub I02136 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002137] = 07766; $code[002137] = *I02137; sub I02137 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002140] = 07777; $code[002140] = *I02140; sub I02140 { &emul8; goto &fetch; }
$core[002141] = 00000; $code[002141] = *D02141; sub D02141 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002142] = 00000; $code[002142] = *P02142; sub P02142 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002143] = 00000; $code[002143] = *D02143; sub D02143 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002144] = 00260; $code[002144] = *D02144; sub D02144 { $lac &= (010000|$core[002060]); goto &fetch; }
$core[002145] = 00000; $code[002145] = *S02145; sub S02145 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002146] = 04445; $code[002146] = *I02146; sub I02146 { $core[($ib<<12)+$core[37]] = 02147; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002147] = 07775; $code[002147] = *I02147; sub I02147 { &emul8; goto &fetch; }
$core[002150] = 04424; $code[002150] = *I02150; sub I02150 { $core[($ib<<12)+$core[20]] = 02151; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[002151] = 02174; $code[002151] = *I02151; sub I02151 { if (++$core[000174] == 010000) { $core[000174] = 0; $pc++; }$code[000174] = *emul8; goto &fetch; }
$core[002152] = 07764; $code[002152] = *I02152; sub I02152 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002153] = 01745; $code[002153] = *I02153; sub I02153 { $lac += $core[($df<<12)+$core[1125]]; goto &fetch; }
$core[002154] = 03373; $code[002154] = *I02154; sub I02154 { $core[002173] = $lac & 07777; $lac &= 010000; $code[002173] = *emul8; goto &fetch; }
$core[002155] = 02345; $code[002155] = *I02155; sub I02155 { if (++$core[002145] == 010000) { $core[002145] = 0; $pc++; }$code[002145] = *emul8; goto &fetch; }
$core[002156] = 01773; $code[002156] = *I02156; sub I02156 { $lac += $core[($df<<12)+$core[1147]]; goto &fetch; }
$core[002157] = 03373; $code[002157] = *I02157; sub I02157 { $core[002173] = $lac & 07777; $lac &= 010000; $code[002173] = *emul8; goto &fetch; }
$core[002160] = 01373; $code[002160] = *L02160; sub L02160 { $lac += $core[002173]; goto &fetch; }
$core[002161] = 07004; $code[002161] = *I02161; sub I02161 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002162] = 03373; $code[002162] = *I02162; sub I02162 { $core[002173] = $lac & 07777; $lac &= 010000; $code[002173] = *emul8; goto &fetch; }
$core[002163] = 07430; $code[002163] = *I02163; sub I02163 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002164] = 05367; $code[002164] = *I02164; sub I02164 { $pc = 002167; $inh = 0; goto &fetch; }
$core[002165] = 04443; $code[002165] = *I02165; sub I02165 { $core[($ib<<12)+$core[35]] = 02166; $pc = ($ib<<12)+$core[35]+1; $code[($ib<<12)+$core[35]] = *emul8; $inh = 0; goto &fetch; }
$core[002166] = 07410; $code[002166] = *I02166; sub I02166 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002167] = 04444; $code[002167] = *L02167; sub L02167 { $core[($ib<<12)+$core[36]] = 02170; $pc = ($ib<<12)+$core[36]+1; $code[($ib<<12)+$core[36]] = *emul8; $inh = 0; goto &fetch; }
$core[002170] = 02374; $code[002170] = *I02170; sub I02170 { if (++$core[002174] == 010000) { $core[002174] = 0; $pc++; }$code[002174] = *emul8; goto &fetch; }
$core[002171] = 05360; $code[002171] = *I02171; sub I02171 { $pc = 002160; $inh = 0; goto &fetch; }
$core[002172] = 05745; $code[002172] = *I02172; sub I02172 { $pc = ($ib<<12)+$core[1125]; $inh = 0; goto &fetch; }
$core[002173] = 00000; $code[002173] = *P02173; sub P02173 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002174] = 00000; $code[002174] = *D02174; sub D02174 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002175] = 00007; $code[002175] = *D02175; sub D02175 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[002176] = 00001; $code[002176] = *I02176; sub I02176 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[002200] = 00000; $code[002200] = *S02200; sub S02200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002201] = 07200; $code[002201] = *I02201; sub I02201 { $lac &= 010000; goto &fetch; }
$core[002202] = 01600; $code[002202] = *I02202; sub I02202 { $lac += $core[($df<<12)+$core[1152]]; goto &fetch; }
$core[002203] = 03214; $code[002203] = *P02203; sub P02203 { $core[002214] = $lac & 07777; $lac &= 010000; $code[002214] = *emul8; goto &fetch; }
$core[002204] = 02200; $code[002204] = *I02204; sub I02204 { if (++$core[002200] == 010000) { $core[002200] = 0; $pc++; }$code[002200] = *emul8; goto &fetch; }
$core[002205] = 01614; $code[002205] = *I02205; sub I02205 { $lac += $core[($df<<12)+$core[1164]]; goto &fetch; }
$core[002206] = 07640; $code[002206] = *P02206; sub P02206 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002207] = 05212; $code[002207] = *I02207; sub I02207 { $pc = 002212; $inh = 0; goto &fetch; }
$core[002210] = 04443; $code[002210] = *I02210; sub I02210 { $core[($ib<<12)+$core[35]] = 02211; $pc = ($ib<<12)+$core[35]+1; $code[($ib<<12)+$core[35]] = *emul8; $inh = 0; goto &fetch; }
$core[002211] = 05600; $code[002211] = *P02211; sub P02211 { $pc = ($ib<<12)+$core[1152]; $inh = 0; goto &fetch; }
$core[002212] = 04444; $code[002212] = *L02212; sub L02212 { $core[($ib<<12)+$core[36]] = 02213; $pc = ($ib<<12)+$core[36]+1; $code[($ib<<12)+$core[36]] = *emul8; $inh = 0; goto &fetch; }
$core[002213] = 05600; $code[002213] = *I02213; sub I02213 { $pc = ($ib<<12)+$core[1152]; $inh = 0; goto &fetch; }
$core[002214] = 00000; $code[002214] = *P02214; sub P02214 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002215] = 00000; $code[002215] = *S02215; sub S02215 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002216] = 04446; $code[002216] = *I02216; sub I02216 { $core[($ib<<12)+$core[38]] = 02217; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002217] = 07777; $code[002217] = *P02217; sub P02217 { &emul8; goto &fetch; }
$core[002220] = 04426; $code[002220] = *I02220; sub I02220 { $core[($ib<<12)+$core[22]] = 02221; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002221] = 00637; $code[002221] = *I02221; sub I02221 { $lac &= (010000|$core[($df<<12)+$core[1183]]); goto &fetch; }
$core[002222] = 04445; $code[002222] = *P02222; sub P02222 { $core[($ib<<12)+$core[37]] = 02223; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002223] = 07774; $code[002223] = *I02223; sub I02223 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002224] = 04455; $code[002224] = *I02224; sub I02224 { $core[($ib<<12)+$core[45]] = 02225; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002225] = 00126; $code[002225] = *I02225; sub I02225 { $lac &= (010000|$core[000126]); goto &fetch; }
$core[002226] = 07776; $code[002226] = *I02226; sub I02226 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002227] = 05615; $code[002227] = *I02227; sub I02227 { $pc = ($ib<<12)+$core[1165]; $inh = 0; goto &fetch; }
$core[002230] = 00000; $code[002230] = *S02230; sub S02230 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002231] = 07200; $code[002231] = *I02231; sub I02231 { $lac &= 010000; goto &fetch; }
$core[002232] = 01630; $code[002232] = *I02232; sub I02232 { $lac += $core[($df<<12)+$core[1176]]; goto &fetch; }
$core[002233] = 03244; $code[002233] = *I02233; sub I02233 { $core[002244] = $lac & 07777; $lac &= 010000; $code[002244] = *emul8; goto &fetch; }
$core[002234] = 01244; $code[002234] = *I02234; sub I02234 { $lac += $core[002244]; goto &fetch; }
$core[002235] = 07001; $code[002235] = *I02235; sub I02235 { $lac++; goto &fetch; }
$core[002236] = 03246; $code[002236] = *I02236; sub I02236 { $core[002246] = $lac & 07777; $lac &= 010000; $code[002246] = *emul8; goto &fetch; }
$core[002237] = 02230; $code[002237] = *P02237; sub P02237 { if (++$core[002230] == 010000) { $core[002230] = 0; $pc++; }$code[002230] = *emul8; goto &fetch; }
$core[002240] = 01630; $code[002240] = *I02240; sub I02240 { $lac += $core[($df<<12)+$core[1176]]; goto &fetch; }
$core[002241] = 03255; $code[002241] = *I02241; sub I02241 { $core[002255] = $lac & 07777; $lac &= 010000; $code[002255] = *emul8; goto &fetch; }
$core[002242] = 02230; $code[002242] = *I02242; sub I02242 { if (++$core[002230] == 010000) { $core[002230] = 0; $pc++; }$code[002230] = *emul8; goto &fetch; }
$core[002243] = 04452; $code[002243] = *I02243; sub I02243 { $core[($ib<<12)+$core[42]] = 02244; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[002244] = 00000; $code[002244] = *D02244; sub D02244 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002245] = 04453; $code[002245] = *L02245; sub L02245 { $core[($ib<<12)+$core[43]] = 02246; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[002246] = 00000; $code[002246] = *D02246; sub D02246 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002247] = 02246; $code[002247] = *I02247; sub I02247 { if (++$core[002246] == 010000) { $core[002246] = 0; $pc++; }$code[002246] = *emul8; goto &fetch; }
$core[002250] = 02255; $code[002250] = *I02250; sub I02250 { if (++$core[002255] == 010000) { $core[002255] = 0; $pc++; }$code[002255] = *emul8; goto &fetch; }
$core[002251] = 05245; $code[002251] = *I02251; sub I02251 { $pc = 002245; $inh = 0; goto &fetch; }
$core[002252] = 04446; $code[002252] = *I02252; sub I02252 { $core[($ib<<12)+$core[38]] = 02253; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002253] = 07777; $code[002253] = *I02253; sub I02253 { &emul8; goto &fetch; }
$core[002254] = 05630; $code[002254] = *I02254; sub I02254 { $pc = ($ib<<12)+$core[1176]; $inh = 0; goto &fetch; }
$core[002255] = 00000; $code[002255] = *D02255; sub D02255 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002256] = 00000; $code[002256] = *S02256; sub S02256 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002257] = 04426; $code[002257] = *I02257; sub I02257 { $core[($ib<<12)+$core[22]] = 02260; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002260] = 00564; $code[002260] = *I02260; sub I02260 { $lac &= (010000|$core[($df<<12)+$core[116]]); goto &fetch; }
$core[002261] = 04445; $code[002261] = *I02261; sub I02261 { $core[($ib<<12)+$core[37]] = 02262; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002262] = 07771; $code[002262] = *I02262; sub I02262 { &emul8; goto &fetch; }
$core[002263] = 04455; $code[002263] = *I02263; sub I02263 { $core[($ib<<12)+$core[45]] = 02264; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002264] = 00476; $code[002264] = *I02264; sub I02264 { $lac &= (010000|$core[($df<<12)+$core[62]]); goto &fetch; }
$core[002265] = 07776; $code[002265] = *I02265; sub I02265 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002266] = 04426; $code[002266] = *I02266; sub I02266 { $core[($ib<<12)+$core[22]] = 02267; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002267] = 00567; $code[002267] = *I02267; sub I02267 { $lac &= (010000|$core[($df<<12)+$core[119]]); goto &fetch; }
$core[002270] = 04445; $code[002270] = *I02270; sub I02270 { $core[($ib<<12)+$core[37]] = 02271; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002271] = 07771; $code[002271] = *I02271; sub I02271 { &emul8; goto &fetch; }
$core[002272] = 04455; $code[002272] = *I02272; sub I02272 { $core[($ib<<12)+$core[45]] = 02273; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002273] = 00501; $code[002273] = *I02273; sub I02273 { $lac &= (010000|$core[($df<<12)+$core[65]]); goto &fetch; }
$core[002274] = 07776; $code[002274] = *I02274; sub I02274 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002275] = 04426; $code[002275] = *I02275; sub I02275 { $core[($ib<<12)+$core[22]] = 02276; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002276] = 00572; $code[002276] = *I02276; sub I02276 { $lac &= (010000|$core[($df<<12)+$core[122]]); goto &fetch; }
$core[002277] = 04445; $code[002277] = *I02277; sub I02277 { $core[($ib<<12)+$core[37]] = 02300; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002300] = 07771; $code[002300] = *I02300; sub I02300 { &emul8; goto &fetch; }
$core[002301] = 04455; $code[002301] = *I02301; sub I02301 { $core[($ib<<12)+$core[45]] = 02302; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002302] = 00504; $code[002302] = *I02302; sub I02302 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[002303] = 07776; $code[002303] = *I02303; sub I02303 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002304] = 04426; $code[002304] = *I02304; sub I02304 { $core[($ib<<12)+$core[22]] = 02305; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002305] = 00575; $code[002305] = *I02305; sub I02305 { $lac &= (010000|$core[($df<<12)+$core[125]]); goto &fetch; }
$core[002306] = 04445; $code[002306] = *I02306; sub I02306 { $core[($ib<<12)+$core[37]] = 02307; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002307] = 07771; $code[002307] = *I02307; sub I02307 { &emul8; goto &fetch; }
$core[002310] = 04455; $code[002310] = *I02310; sub I02310 { $core[($ib<<12)+$core[45]] = 02311; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002311] = 00507; $code[002311] = *I02311; sub I02311 { $lac &= (010000|$core[($df<<12)+$core[71]]); goto &fetch; }
$core[002312] = 07776; $code[002312] = *I02312; sub I02312 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002313] = 04426; $code[002313] = *I02313; sub I02313 { $core[($ib<<12)+$core[22]] = 02314; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002314] = 00600; $code[002314] = *I02314; sub I02314 { $lac &= (010000|$core[($df<<12)+$core[1152]]); goto &fetch; }
$core[002315] = 04445; $code[002315] = *I02315; sub I02315 { $core[($ib<<12)+$core[37]] = 02316; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002316] = 07771; $code[002316] = *I02316; sub I02316 { &emul8; goto &fetch; }
$core[002317] = 04455; $code[002317] = *I02317; sub I02317 { $core[($ib<<12)+$core[45]] = 02320; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002320] = 00512; $code[002320] = *I02320; sub I02320 { $lac &= (010000|$core[($df<<12)+$core[74]]); goto &fetch; }
$core[002321] = 07776; $code[002321] = *I02321; sub I02321 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002322] = 04426; $code[002322] = *I02322; sub I02322 { $core[($ib<<12)+$core[22]] = 02323; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002323] = 00603; $code[002323] = *I02323; sub I02323 { $lac &= (010000|$core[($df<<12)+$core[1155]]); goto &fetch; }
$core[002324] = 04445; $code[002324] = *I02324; sub I02324 { $core[($ib<<12)+$core[37]] = 02325; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002325] = 07771; $code[002325] = *I02325; sub I02325 { &emul8; goto &fetch; }
$core[002326] = 04455; $code[002326] = *I02326; sub I02326 { $core[($ib<<12)+$core[45]] = 02327; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002327] = 00515; $code[002327] = *I02327; sub I02327 { $lac &= (010000|$core[($df<<12)+$core[77]]); goto &fetch; }
$core[002330] = 07776; $code[002330] = *I02330; sub I02330 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002331] = 04426; $code[002331] = *I02331; sub I02331 { $core[($ib<<12)+$core[22]] = 02332; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002332] = 00606; $code[002332] = *I02332; sub I02332 { $lac &= (010000|$core[($df<<12)+$core[1158]]); goto &fetch; }
$core[002333] = 04445; $code[002333] = *I02333; sub I02333 { $core[($ib<<12)+$core[37]] = 02334; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002334] = 07771; $code[002334] = *I02334; sub I02334 { &emul8; goto &fetch; }
$core[002335] = 04455; $code[002335] = *I02335; sub I02335 { $core[($ib<<12)+$core[45]] = 02336; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002336] = 00520; $code[002336] = *I02336; sub I02336 { $lac &= (010000|$core[($df<<12)+$core[80]]); goto &fetch; }
$core[002337] = 07776; $code[002337] = *I02337; sub I02337 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002340] = 04426; $code[002340] = *I02340; sub I02340 { $core[($ib<<12)+$core[22]] = 02341; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002341] = 00611; $code[002341] = *I02341; sub I02341 { $lac &= (010000|$core[($df<<12)+$core[1161]]); goto &fetch; }
$core[002342] = 04445; $code[002342] = *I02342; sub I02342 { $core[($ib<<12)+$core[37]] = 02343; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002343] = 07771; $code[002343] = *I02343; sub I02343 { &emul8; goto &fetch; }
$core[002344] = 04455; $code[002344] = *I02344; sub I02344 { $core[($ib<<12)+$core[45]] = 02345; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002345] = 00523; $code[002345] = *I02345; sub I02345 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[002346] = 07776; $code[002346] = *I02346; sub I02346 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002347] = 04426; $code[002347] = *I02347; sub I02347 { $core[($ib<<12)+$core[22]] = 02350; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002350] = 00614; $code[002350] = *I02350; sub I02350 { $lac &= (010000|$core[($df<<12)+$core[1164]]); goto &fetch; }
$core[002351] = 04445; $code[002351] = *I02351; sub I02351 { $core[($ib<<12)+$core[37]] = 02352; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002352] = 07771; $code[002352] = *I02352; sub I02352 { &emul8; goto &fetch; }
$core[002353] = 04455; $code[002353] = *I02353; sub I02353 { $core[($ib<<12)+$core[45]] = 02354; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002354] = 00526; $code[002354] = *I02354; sub I02354 { $lac &= (010000|$core[($df<<12)+$core[86]]); goto &fetch; }
$core[002355] = 07776; $code[002355] = *I02355; sub I02355 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002356] = 04426; $code[002356] = *I02356; sub I02356 { $core[($ib<<12)+$core[22]] = 02357; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002357] = 00617; $code[002357] = *I02357; sub I02357 { $lac &= (010000|$core[($df<<12)+$core[1167]]); goto &fetch; }
$core[002360] = 04445; $code[002360] = *I02360; sub I02360 { $core[($ib<<12)+$core[37]] = 02361; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002361] = 07772; $code[002361] = *I02361; sub I02361 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[002362] = 04455; $code[002362] = *I02362; sub I02362 { $core[($ib<<12)+$core[45]] = 02363; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002363] = 00531; $code[002363] = *I02363; sub I02363 { $lac &= (010000|$core[($df<<12)+$core[89]]); goto &fetch; }
$core[002364] = 07776; $code[002364] = *I02364; sub I02364 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002365] = 04426; $code[002365] = *I02365; sub I02365 { $core[($ib<<12)+$core[22]] = 02366; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002366] = 00622; $code[002366] = *I02366; sub I02366 { $lac &= (010000|$core[($df<<12)+$core[1170]]); goto &fetch; }
$core[002367] = 04445; $code[002367] = *I02367; sub I02367 { $core[($ib<<12)+$core[37]] = 02370; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002370] = 07772; $code[002370] = *I02370; sub I02370 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[002371] = 04455; $code[002371] = *I02371; sub I02371 { $core[($ib<<12)+$core[45]] = 02372; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002372] = 00534; $code[002372] = *I02372; sub I02372 { $lac &= (010000|$core[($df<<12)+$core[92]]); goto &fetch; }
$core[002373] = 07776; $code[002373] = *I02373; sub I02373 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002374] = 05656; $code[002374] = *I02374; sub I02374 { $pc = ($ib<<12)+$core[1198]; $inh = 0; goto &fetch; }
$core[002400] = 00000; $code[002400] = *S02400; sub S02400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002401] = 04446; $code[002401] = *I02401; sub I02401 { $core[($ib<<12)+$core[38]] = 02402; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002402] = 07776; $code[002402] = *I02402; sub I02402 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002403] = 04426; $code[002403] = *I02403; sub I02403 { $core[($ib<<12)+$core[22]] = 02404; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002404] = 00633; $code[002404] = *I02404; sub I02404 { $lac &= (010000|$core[($df<<12)+$core[1307]]); goto &fetch; }
$core[002405] = 04445; $code[002405] = *I02405; sub I02405 { $core[($ib<<12)+$core[37]] = 02406; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002406] = 07773; $code[002406] = *I02406; sub I02406 { &emul8; goto &fetch; }
$core[002407] = 04447; $code[002407] = *I02407; sub I02407 { $core[($ib<<12)+$core[39]] = 02410; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[002410] = 04476; $code[002410] = *I02410; sub I02410 { $core[($ib<<12)+$core[62]] = 02411; $pc = ($ib<<12)+$core[62]+1; $code[($ib<<12)+$core[62]] = *emul8; $inh = 0; goto &fetch; }
$core[002411] = 04446; $code[002411] = *I02411; sub I02411 { $core[($ib<<12)+$core[38]] = 02412; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002412] = 07776; $code[002412] = *I02412; sub I02412 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002413] = 04426; $code[002413] = *I02413; sub I02413 { $core[($ib<<12)+$core[22]] = 02414; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002414] = 00561; $code[002414] = *I02414; sub I02414 { $lac &= (010000|$core[($df<<12)+$core[113]]); goto &fetch; }
$core[002415] = 04445; $code[002415] = *I02415; sub I02415 { $core[($ib<<12)+$core[37]] = 02416; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002416] = 07771; $code[002416] = *I02416; sub I02416 { &emul8; goto &fetch; }
$core[002417] = 04455; $code[002417] = *I02417; sub I02417 { $core[($ib<<12)+$core[45]] = 02420; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002420] = 00473; $code[002420] = *I02420; sub I02420 { $lac &= (010000|$core[($df<<12)+$core[59]]); goto &fetch; }
$core[002421] = 07776; $code[002421] = *I02421; sub I02421 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002422] = 05600; $code[002422] = *I02422; sub I02422 { $pc = ($ib<<12)+$core[1280]; $inh = 0; goto &fetch; }
$core[002423] = 00000; $code[002423] = *S02423; sub S02423 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002424] = 04426; $code[002424] = *I02424; sub I02424 { $core[($ib<<12)+$core[22]] = 02425; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002425] = 00625; $code[002425] = *P02425; sub P02425 { $lac &= (010000|$core[($df<<12)+$core[1301]]); goto &fetch; }
$core[002426] = 04445; $code[002426] = *I02426; sub I02426 { $core[($ib<<12)+$core[37]] = 02427; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002427] = 07772; $code[002427] = *I02427; sub I02427 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[002430] = 04455; $code[002430] = *P02430; sub P02430 { $core[($ib<<12)+$core[45]] = 02431; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002431] = 00537; $code[002431] = *I02431; sub I02431 { $lac &= (010000|$core[($df<<12)+$core[95]]); goto &fetch; }
$core[002432] = 07776; $code[002432] = *I02432; sub I02432 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002433] = 04426; $code[002433] = *P02433; sub P02433 { $core[($ib<<12)+$core[22]] = 02434; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[002434] = 00630; $code[002434] = *I02434; sub I02434 { $lac &= (010000|$core[($df<<12)+$core[1304]]); goto &fetch; }
$core[002435] = 04445; $code[002435] = *I02435; sub I02435 { $core[($ib<<12)+$core[37]] = 02436; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002436] = 07772; $code[002436] = *I02436; sub I02436 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[002437] = 04455; $code[002437] = *I02437; sub I02437 { $core[($ib<<12)+$core[45]] = 02440; $pc = ($ib<<12)+$core[45]+1; $code[($ib<<12)+$core[45]] = *emul8; $inh = 0; goto &fetch; }
$core[002440] = 00542; $code[002440] = *I02440; sub I02440 { $lac &= (010000|$core[($df<<12)+$core[98]]); goto &fetch; }
$core[002441] = 07776; $code[002441] = *I02441; sub I02441 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002442] = 05623; $code[002442] = *I02442; sub I02442 { $pc = ($ib<<12)+$core[1299]; $inh = 0; goto &fetch; }
$core[002443] = 00000; $code[002443] = *S02443; sub S02443 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002444] = 07300; $code[002444] = *I02444; sub I02444 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002445] = 01124; $code[002445] = *I02445; sub I02445 { $lac += $core[000124]; goto &fetch; }
$core[002446] = 07010; $code[002446] = *I02446; sub I02446 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002447] = 07630; $code[002447] = *I02447; sub I02447 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002450] = 04462; $code[002450] = *I02450; sub I02450 { $core[($ib<<12)+$core[50]] = 02451; $pc = ($ib<<12)+$core[50]+1; $code[($ib<<12)+$core[50]] = *emul8; $inh = 0; goto &fetch; }
$core[002451] = 01124; $code[002451] = *I02451; sub I02451 { $lac += $core[000124]; goto &fetch; }
$core[002452] = 07421; $code[002452] = *I02452; sub I02452 { &emul8; goto &fetch; }
$core[002453] = 01123; $code[002453] = *I02453; sub I02453 { $lac += $core[000123]; goto &fetch; }
$core[002454] = 07417; $code[002454] = *I02454; sub I02454 { &emul8; goto &fetch; }
$core[002455] = 00000; $code[002455] = *D02455; sub D02455 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002456] = 01122; $code[002456] = *I02456; sub I02456 { $lac += $core[000122]; goto &fetch; }
$core[002457] = 03123; $code[002457] = *I02457; sub I02457 { $core[000123] = $lac & 07777; $lac &= 010000; $code[000123] = *emul8; goto &fetch; }
$core[002460] = 03122; $code[002460] = *I02460; sub I02460 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[002461] = 07701; $code[002461] = *I02461; sub I02461 { &emul8; goto &fetch; }
$core[002462] = 03124; $code[002462] = *I02462; sub I02462 { $core[000124] = $lac & 07777; $lac &= 010000; $code[000124] = *emul8; goto &fetch; }
$core[002463] = 05643; $code[002463] = *I02463; sub I02463 { $pc = ($ib<<12)+$core[1315]; $inh = 0; goto &fetch; }
$core[002464] = 00000; $code[002464] = *S02464; sub S02464 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002465] = 04432; $code[002465] = *I02465; sub I02465 { $core[($ib<<12)+$core[26]] = 02466; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[002466] = 00106; $code[002466] = *I02466; sub I02466 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[002467] = 00122; $code[002467] = *I02467; sub I02467 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[002470] = 07774; $code[002470] = *I02470; sub I02470 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002471] = 03122; $code[002471] = *I02471; sub I02471 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[002472] = 03123; $code[002472] = *I02472; sub I02472 { $core[000123] = $lac & 07777; $lac &= 010000; $code[000123] = *emul8; goto &fetch; }
$core[002473] = 04467; $code[002473] = *I02473; sub I02473 { $core[($ib<<12)+$core[55]] = 02474; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002474] = 00473; $code[002474] = *I02474; sub I02474 { $lac &= (010000|$core[($df<<12)+$core[59]]); goto &fetch; }
$core[002475] = 04243; $code[002475] = *I02475; sub I02475 { $core[002443] = 02476; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002476] = 04467; $code[002476] = *I02476; sub I02476 { $core[($ib<<12)+$core[55]] = 02477; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002477] = 00476; $code[002477] = *I02477; sub I02477 { $lac &= (010000|$core[($df<<12)+$core[62]]); goto &fetch; }
$core[002500] = 04243; $code[002500] = *I02500; sub I02500 { $core[002443] = 02501; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002501] = 04467; $code[002501] = *I02501; sub I02501 { $core[($ib<<12)+$core[55]] = 02502; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002502] = 00501; $code[002502] = *I02502; sub I02502 { $lac &= (010000|$core[($df<<12)+$core[65]]); goto &fetch; }
$core[002503] = 04243; $code[002503] = *I02503; sub I02503 { $core[002443] = 02504; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002504] = 04467; $code[002504] = *I02504; sub I02504 { $core[($ib<<12)+$core[55]] = 02505; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002505] = 00504; $code[002505] = *I02505; sub I02505 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[002506] = 04243; $code[002506] = *I02506; sub I02506 { $core[002443] = 02507; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002507] = 04467; $code[002507] = *I02507; sub I02507 { $core[($ib<<12)+$core[55]] = 02510; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002510] = 00507; $code[002510] = *I02510; sub I02510 { $lac &= (010000|$core[($df<<12)+$core[71]]); goto &fetch; }
$core[002511] = 04243; $code[002511] = *I02511; sub I02511 { $core[002443] = 02512; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002512] = 04467; $code[002512] = *I02512; sub I02512 { $core[($ib<<12)+$core[55]] = 02513; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002513] = 00512; $code[002513] = *I02513; sub I02513 { $lac &= (010000|$core[($df<<12)+$core[74]]); goto &fetch; }
$core[002514] = 04243; $code[002514] = *I02514; sub I02514 { $core[002443] = 02515; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002515] = 04467; $code[002515] = *I02515; sub I02515 { $core[($ib<<12)+$core[55]] = 02516; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002516] = 00515; $code[002516] = *I02516; sub I02516 { $lac &= (010000|$core[($df<<12)+$core[77]]); goto &fetch; }
$core[002517] = 04243; $code[002517] = *I02517; sub I02517 { $core[002443] = 02520; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002520] = 04467; $code[002520] = *I02520; sub I02520 { $core[($ib<<12)+$core[55]] = 02521; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002521] = 00520; $code[002521] = *I02521; sub I02521 { $lac &= (010000|$core[($df<<12)+$core[80]]); goto &fetch; }
$core[002522] = 04243; $code[002522] = *I02522; sub I02522 { $core[002443] = 02523; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002523] = 04467; $code[002523] = *I02523; sub I02523 { $core[($ib<<12)+$core[55]] = 02524; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002524] = 00523; $code[002524] = *I02524; sub I02524 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[002525] = 04243; $code[002525] = *I02525; sub I02525 { $core[002443] = 02526; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002526] = 04467; $code[002526] = *I02526; sub I02526 { $core[($ib<<12)+$core[55]] = 02527; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002527] = 00526; $code[002527] = *I02527; sub I02527 { $lac &= (010000|$core[($df<<12)+$core[86]]); goto &fetch; }
$core[002530] = 04243; $code[002530] = *I02530; sub I02530 { $core[002443] = 02531; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002531] = 04467; $code[002531] = *I02531; sub I02531 { $core[($ib<<12)+$core[55]] = 02532; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002532] = 00531; $code[002532] = *I02532; sub I02532 { $lac &= (010000|$core[($df<<12)+$core[89]]); goto &fetch; }
$core[002533] = 04243; $code[002533] = *I02533; sub I02533 { $core[002443] = 02534; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002534] = 04467; $code[002534] = *I02534; sub I02534 { $core[($ib<<12)+$core[55]] = 02535; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002535] = 00534; $code[002535] = *I02535; sub I02535 { $lac &= (010000|$core[($df<<12)+$core[92]]); goto &fetch; }
$core[002536] = 04243; $code[002536] = *I02536; sub I02536 { $core[002443] = 02537; $pc = 002443+1; $code[002443] = *emul8; $inh = 0; goto &fetch; }
$core[002537] = 04467; $code[002537] = *I02537; sub I02537 { $core[($ib<<12)+$core[55]] = 02540; $pc = ($ib<<12)+$core[55]+1; $code[($ib<<12)+$core[55]] = *emul8; $inh = 0; goto &fetch; }
$core[002540] = 00126; $code[002540] = *I02540; sub I02540 { $lac &= (010000|$core[000126]); goto &fetch; }
$core[002541] = 05664; $code[002541] = *I02541; sub I02541 { $pc = ($ib<<12)+$core[1332]; $inh = 0; goto &fetch; }
$core[002542] = 00000; $code[002542] = *S02542; sub S02542 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002543] = 07320; $code[002543] = *I02543; sub I02543 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002544] = 01124; $code[002544] = *I02544; sub I02544 { $lac += $core[000124]; goto &fetch; }
$core[002545] = 07004; $code[002545] = *I02545; sub I02545 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002546] = 03124; $code[002546] = *I02546; sub I02546 { $core[000124] = $lac & 07777; $lac &= 010000; $code[000124] = *emul8; goto &fetch; }
$core[002547] = 07010; $code[002547] = *I02547; sub I02547 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002550] = 03133; $code[002550] = *I02550; sub I02550 { $core[000133] = $lac & 07777; $lac &= 010000; $code[000133] = *emul8; goto &fetch; }
$core[002551] = 05742; $code[002551] = *I02551; sub I02551 { $pc = ($ib<<12)+$core[1378]; $inh = 0; goto &fetch; }
$core[002552] = 00000; $code[002552] = *S02552; sub S02552 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002553] = 01124; $code[002553] = *I02553; sub I02553 { $lac += $core[000124]; goto &fetch; }
$core[002554] = 00137; $code[002554] = *I02554; sub I02554 { $lac &= (010000|$core[000137]); goto &fetch; }
$core[002555] = 07112; $code[002555] = *I02555; sub I02555 { $lac &= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[002556] = 07010; $code[002556] = *I02556; sub I02556 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002557] = 01122; $code[002557] = *I02557; sub I02557 { $lac += $core[000122]; goto &fetch; }
$core[002560] = 07640; $code[002560] = *I02560; sub I02560 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002561] = 04367; $code[002561] = *I02561; sub I02561 { $core[002567] = 02562; $pc = 002567+1; $code[002567] = *emul8; $inh = 0; goto &fetch; }
$core[002562] = 05752; $code[002562] = *I02562; sub I02562 { $pc = ($ib<<12)+$core[1386]; $inh = 0; goto &fetch; }
$core[002563] = 00000; $code[002563] = *S02563; sub S02563 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002564] = 04342; $code[002564] = *I02564; sub I02564 { $core[002542] = 02565; $pc = 002542+1; $code[002542] = *emul8; $inh = 0; goto &fetch; }
$core[002565] = 04352; $code[002565] = *I02565; sub I02565 { $core[002552] = 02566; $pc = 002552+1; $code[002552] = *emul8; $inh = 0; goto &fetch; }
$core[002566] = 05763; $code[002566] = *I02566; sub I02566 { $pc = ($ib<<12)+$core[1395]; $inh = 0; goto &fetch; }
$core[002567] = 00000; $code[002567] = *S02567; sub S02567 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002570] = 07300; $code[002570] = *I02570; sub I02570 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002571] = 01124; $code[002571] = *I02571; sub I02571 { $lac += $core[000124]; goto &fetch; }
$core[002572] = 00136; $code[002572] = *I02572; sub I02572 { $lac &= (010000|$core[000136]); goto &fetch; }
$core[002573] = 03124; $code[002573] = *I02573; sub I02573 { $core[000124] = $lac & 07777; $lac &= 010000; $code[000124] = *emul8; goto &fetch; }
$core[002574] = 05767; $code[002574] = *I02574; sub I02574 { $pc = ($ib<<12)+$core[1399]; $inh = 0; goto &fetch; }
$core[002600] = 00000; $code[002600] = *S02600; sub S02600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002601] = 04432; $code[002601] = *I02601; sub I02601 { $core[($ib<<12)+$core[26]] = 02602; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[002602] = 00106; $code[002602] = *I02602; sub I02602 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[002603] = 00122; $code[002603] = *I02603; sub I02603 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[002604] = 07774; $code[002604] = *I02604; sub I02604 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002605] = 03134; $code[002605] = *I02605; sub I02605 { $core[000134] = $lac & 07777; $lac &= 010000; $code[000134] = *emul8; goto &fetch; }
$core[002606] = 03122; $code[002606] = *I02606; sub I02606 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[002607] = 04341; $code[002607] = *I02607; sub I02607 { $core[002741] = 02610; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002610] = 00473; $code[002610] = *I02610; sub I02610 { $lac &= (010000|$core[($df<<12)+$core[59]]); goto &fetch; }
$core[002611] = 04463; $code[002611] = *I02611; sub I02611 { $core[($ib<<12)+$core[51]] = 02612; $pc = ($ib<<12)+$core[51]+1; $code[($ib<<12)+$core[51]] = *emul8; $inh = 0; goto &fetch; }
$core[002612] = 01122; $code[002612] = *I02612; sub I02612 { $lac += $core[000122]; goto &fetch; }
$core[002613] = 07640; $code[002613] = *I02613; sub I02613 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002614] = 05227; $code[002614] = *I02614; sub I02614 { $pc = 002627; $inh = 0; goto &fetch; }
$core[002615] = 04465; $code[002615] = *I02615; sub I02615 { $core[($ib<<12)+$core[53]] = 02616; $pc = ($ib<<12)+$core[53]+1; $code[($ib<<12)+$core[53]] = *emul8; $inh = 0; goto &fetch; }
$core[002616] = 04470; $code[002616] = *I02616; sub I02616 { $core[($ib<<12)+$core[56]] = 02617; $pc = ($ib<<12)+$core[56]+1; $code[($ib<<12)+$core[56]] = *emul8; $inh = 0; goto &fetch; }
$core[002617] = 01133; $code[002617] = *I02617; sub I02617 { $lac += $core[000133]; goto &fetch; }
$core[002620] = 07004; $code[002620] = *I02620; sub I02620 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002621] = 01123; $code[002621] = *I02621; sub I02621 { $lac += $core[000123]; goto &fetch; }
$core[002622] = 07024; $code[002622] = *I02622; sub I02622 { $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002623] = 03123; $code[002623] = *I02623; sub I02623 { $core[000123] = $lac & 07777; $lac &= 010000; $code[000123] = *emul8; goto &fetch; }
$core[002624] = 07010; $code[002624] = *I02624; sub I02624 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002625] = 03122; $code[002625] = *I02625; sub I02625 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[002626] = 05241; $code[002626] = *I02626; sub I02626 { $pc = 002641; $inh = 0; goto &fetch; }
$core[002627] = 07201; $code[002627] = *L02627; sub L02627 { $lac &= 010000; $lac++; goto &fetch; }
$core[002630] = 03126; $code[002630] = *I02630; sub I02630 { $core[000126] = $lac & 07777; $lac &= 010000; $code[000126] = *emul8; goto &fetch; }
$core[002631] = 07320; $code[002631] = *I02631; sub I02631 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002632] = 01110; $code[002632] = *I02632; sub I02632 { $lac += $core[000110]; goto &fetch; }
$core[002633] = 07004; $code[002633] = *I02633; sub I02633 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002634] = 03130; $code[002634] = *I02634; sub I02634 { $core[000130] = $lac & 07777; $lac &= 010000; $code[000130] = *emul8; goto &fetch; }
$core[002635] = 01107; $code[002635] = *I02635; sub I02635 { $lac += $core[000107]; goto &fetch; }
$core[002636] = 03127; $code[002636] = *I02636; sub I02636 { $core[000127] = $lac & 07777; $lac &= 010000; $code[000127] = *emul8; goto &fetch; }
$core[002637] = 02134; $code[002637] = *I02637; sub I02637 { if (++$core[000134] == 010000) { $core[000134] = 0; $pc++; }$code[000134] = *emul8; goto &fetch; }
$core[002640] = 05600; $code[002640] = *I02640; sub I02640 { $pc = ($ib<<12)+$core[1408]; $inh = 0; goto &fetch; }
$core[002641] = 04341; $code[002641] = *L02641; sub L02641 { $core[002741] = 02642; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002642] = 00476; $code[002642] = *I02642; sub I02642 { $lac &= (010000|$core[($df<<12)+$core[62]]); goto &fetch; }
$core[002643] = 04463; $code[002643] = *I02643; sub I02643 { $core[($ib<<12)+$core[51]] = 02644; $pc = ($ib<<12)+$core[51]+1; $code[($ib<<12)+$core[51]] = *emul8; $inh = 0; goto &fetch; }
$core[002644] = 04466; $code[002644] = *I02644; sub I02644 { $core[($ib<<12)+$core[54]] = 02645; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002645] = 04360; $code[002645] = *I02645; sub I02645 { $core[002760] = 02646; $pc = 002760+1; $code[002760] = *emul8; $inh = 0; goto &fetch; }
$core[002646] = 04341; $code[002646] = *I02646; sub I02646 { $core[002741] = 02647; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002647] = 00501; $code[002647] = *I02647; sub I02647 { $lac &= (010000|$core[($df<<12)+$core[65]]); goto &fetch; }
$core[002650] = 04353; $code[002650] = *I02650; sub I02650 { $core[002753] = 02651; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002651] = 04341; $code[002651] = *I02651; sub I02651 { $core[002741] = 02652; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002652] = 00504; $code[002652] = *I02652; sub I02652 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[002653] = 04353; $code[002653] = *I02653; sub I02653 { $core[002753] = 02654; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002654] = 04341; $code[002654] = *I02654; sub I02654 { $core[002741] = 02655; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002655] = 00507; $code[002655] = *I02655; sub I02655 { $lac &= (010000|$core[($df<<12)+$core[71]]); goto &fetch; }
$core[002656] = 04353; $code[002656] = *I02656; sub I02656 { $core[002753] = 02657; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002657] = 04341; $code[002657] = *I02657; sub I02657 { $core[002741] = 02660; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002660] = 00512; $code[002660] = *I02660; sub I02660 { $lac &= (010000|$core[($df<<12)+$core[74]]); goto &fetch; }
$core[002661] = 04353; $code[002661] = *I02661; sub I02661 { $core[002753] = 02662; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002662] = 04341; $code[002662] = *I02662; sub I02662 { $core[002741] = 02663; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002663] = 00515; $code[002663] = *I02663; sub I02663 { $lac &= (010000|$core[($df<<12)+$core[77]]); goto &fetch; }
$core[002664] = 04353; $code[002664] = *I02664; sub I02664 { $core[002753] = 02665; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002665] = 04341; $code[002665] = *I02665; sub I02665 { $core[002741] = 02666; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002666] = 00520; $code[002666] = *I02666; sub I02666 { $lac &= (010000|$core[($df<<12)+$core[80]]); goto &fetch; }
$core[002667] = 04353; $code[002667] = *I02667; sub I02667 { $core[002753] = 02670; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002670] = 04341; $code[002670] = *I02670; sub I02670 { $core[002741] = 02671; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002671] = 00523; $code[002671] = *I02671; sub I02671 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[002672] = 04353; $code[002672] = *I02672; sub I02672 { $core[002753] = 02673; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002673] = 04341; $code[002673] = *I02673; sub I02673 { $core[002741] = 02674; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002674] = 00526; $code[002674] = *I02674; sub I02674 { $lac &= (010000|$core[($df<<12)+$core[86]]); goto &fetch; }
$core[002675] = 04353; $code[002675] = *I02675; sub I02675 { $core[002753] = 02676; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002676] = 04341; $code[002676] = *I02676; sub I02676 { $core[002741] = 02677; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002677] = 00531; $code[002677] = *I02677; sub I02677 { $lac &= (010000|$core[($df<<12)+$core[89]]); goto &fetch; }
$core[002700] = 04353; $code[002700] = *I02700; sub I02700 { $core[002753] = 02701; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002701] = 04341; $code[002701] = *I02701; sub I02701 { $core[002741] = 02702; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002702] = 00534; $code[002702] = *I02702; sub I02702 { $lac &= (010000|$core[($df<<12)+$core[92]]); goto &fetch; }
$core[002703] = 04353; $code[002703] = *I02703; sub I02703 { $core[002753] = 02704; $pc = 002753+1; $code[002753] = *emul8; $inh = 0; goto &fetch; }
$core[002704] = 04341; $code[002704] = *I02704; sub I02704 { $core[002741] = 02705; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002705] = 00537; $code[002705] = *I02705; sub I02705 { $lac &= (010000|$core[($df<<12)+$core[95]]); goto &fetch; }
$core[002706] = 04464; $code[002706] = *I02706; sub I02706 { $core[($ib<<12)+$core[52]] = 02707; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002707] = 04466; $code[002707] = *I02707; sub I02707 { $core[($ib<<12)+$core[54]] = 02710; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002710] = 04341; $code[002710] = *I02710; sub I02710 { $core[002741] = 02711; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002711] = 00542; $code[002711] = *I02711; sub I02711 { $lac &= (010000|$core[($df<<12)+$core[98]]); goto &fetch; }
$core[002712] = 07300; $code[002712] = *I02712; sub I02712 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002713] = 01124; $code[002713] = *I02713; sub I02713 { $lac += $core[000124]; goto &fetch; }
$core[002714] = 07012; $code[002714] = *I02714; sub I02714 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[002715] = 07430; $code[002715] = *I02715; sub I02715 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002716] = 05323; $code[002716] = *I02716; sub I02716 { $pc = 002723; $inh = 0; goto &fetch; }
$core[002717] = 07710; $code[002717] = *I02717; sub I02717 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002720] = 05336; $code[002720] = *I02720; sub I02720 { $pc = 002736; $inh = 0; goto &fetch; }
$core[002721] = 04462; $code[002721] = *I02721; sub I02721 { $core[($ib<<12)+$core[50]] = 02722; $pc = ($ib<<12)+$core[50]+1; $code[($ib<<12)+$core[50]] = *emul8; $inh = 0; goto &fetch; }
$core[002722] = 05336; $code[002722] = *I02722; sub I02722 { $pc = 002736; $inh = 0; goto &fetch; }
$core[002723] = 07710; $code[002723] = *L02723; sub L02723 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002724] = 05327; $code[002724] = *I02724; sub I02724 { $pc = 002727; $inh = 0; goto &fetch; }
$core[002725] = 04463; $code[002725] = *I02725; sub I02725 { $core[($ib<<12)+$core[51]] = 02726; $pc = ($ib<<12)+$core[51]+1; $code[($ib<<12)+$core[51]] = *emul8; $inh = 0; goto &fetch; }
$core[002726] = 05336; $code[002726] = *I02726; sub I02726 { $pc = 002736; $inh = 0; goto &fetch; }
$core[002727] = 01122; $code[002727] = *L02727; sub L02727 { $lac += $core[000122]; goto &fetch; }
$core[002730] = 07104; $code[002730] = *I02730; sub I02730 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002731] = 01123; $code[002731] = *I02731; sub I02731 { $lac += $core[000123]; goto &fetch; }
$core[002732] = 07060; $code[002732] = *I02732; sub I02732 { $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002733] = 03123; $code[002733] = *I02733; sub I02733 { $core[000123] = $lac & 07777; $lac &= 010000; $code[000123] = *emul8; goto &fetch; }
$core[002734] = 07004; $code[002734] = *I02734; sub I02734 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002735] = 03122; $code[002735] = *I02735; sub I02735 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[002736] = 04341; $code[002736] = *L02736; sub L02736 { $core[002741] = 02737; $pc = 002741+1; $code[002741] = *emul8; $inh = 0; goto &fetch; }
$core[002737] = 00126; $code[002737] = *I02737; sub I02737 { $lac &= (010000|$core[000126]); goto &fetch; }
$core[002740] = 05600; $code[002740] = *I02740; sub I02740 { $pc = ($ib<<12)+$core[1408]; $inh = 0; goto &fetch; }
$core[002741] = 00000; $code[002741] = *S02741; sub S02741 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002742] = 07200; $code[002742] = *I02742; sub I02742 { $lac &= 010000; goto &fetch; }
$core[002743] = 01741; $code[002743] = *I02743; sub I02743 { $lac += $core[($df<<12)+$core[1505]]; goto &fetch; }
$core[002744] = 03347; $code[002744] = *I02744; sub I02744 { $core[002747] = $lac & 07777; $lac &= 010000; $code[002747] = *emul8; goto &fetch; }
$core[002745] = 04432; $code[002745] = *I02745; sub I02745 { $core[($ib<<12)+$core[26]] = 02746; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[002746] = 00122; $code[002746] = *I02746; sub I02746 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[002747] = 00000; $code[002747] = *D02747; sub D02747 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002750] = 07775; $code[002750] = *I02750; sub I02750 { &emul8; goto &fetch; }
$core[002751] = 02341; $code[002751] = *I02751; sub I02751 { if (++$core[002741] == 010000) { $core[002741] = 0; $pc++; }$code[002741] = *emul8; goto &fetch; }
$core[002752] = 05741; $code[002752] = *I02752; sub I02752 { $pc = ($ib<<12)+$core[1505]; $inh = 0; goto &fetch; }
$core[002753] = 00000; $code[002753] = *S02753; sub S02753 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002754] = 04464; $code[002754] = *I02754; sub I02754 { $core[($ib<<12)+$core[52]] = 02755; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002755] = 04466; $code[002755] = *I02755; sub I02755 { $core[($ib<<12)+$core[54]] = 02756; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[002756] = 04360; $code[002756] = *I02756; sub I02756 { $core[002760] = 02757; $pc = 002760+1; $code[002760] = *emul8; $inh = 0; goto &fetch; }
$core[002757] = 05753; $code[002757] = *I02757; sub I02757 { $pc = ($ib<<12)+$core[1515]; $inh = 0; goto &fetch; }
$core[002760] = 00000; $code[002760] = *S02760; sub S02760 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002761] = 07200; $code[002761] = *I02761; sub I02761 { $lac &= 010000; goto &fetch; }
$core[002762] = 01124; $code[002762] = *I02762; sub I02762 { $lac += $core[000124]; goto &fetch; }
$core[002763] = 07012; $code[002763] = *I02763; sub I02763 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[002764] = 07630; $code[002764] = *I02764; sub I02764 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002765] = 07040; $code[002765] = *I02765; sub I02765 { $lac ^= 07777; goto &fetch; }
$core[002766] = 01133; $code[002766] = *I02766; sub I02766 { $lac += $core[000133]; goto &fetch; }
$core[002767] = 07004; $code[002767] = *I02767; sub I02767 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002770] = 07200; $code[002770] = *I02770; sub I02770 { $lac &= 010000; goto &fetch; }
$core[002771] = 01123; $code[002771] = *I02771; sub I02771 { $lac += $core[000123]; goto &fetch; }
$core[002772] = 07004; $code[002772] = *I02772; sub I02772 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002773] = 03123; $code[002773] = *I02773; sub I02773 { $core[000123] = $lac & 07777; $lac &= 010000; $code[000123] = *emul8; goto &fetch; }
$core[002774] = 07010; $code[002774] = *I02774; sub I02774 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002775] = 03122; $code[002775] = *I02775; sub I02775 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[002776] = 05760; $code[002776] = *I02776; sub I02776 { $pc = ($ib<<12)+$core[1520]; $inh = 0; goto &fetch; }
$core[003000] = 00000; $code[003000] = *S03000; sub S03000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003001] = 07300; $code[003001] = *I03001; sub I03001 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003002] = 01122; $code[003002] = *I03002; sub I03002 { $lac += $core[000122]; goto &fetch; }
$core[003003] = 07004; $code[003003] = *I03003; sub I03003 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003004] = 01123; $code[003004] = *I03004; sub I03004 { $lac += $core[000123]; goto &fetch; }
$core[003005] = 01125; $code[003005] = *I03005; sub I03005 { $lac += $core[000125]; goto &fetch; }
$core[003006] = 03123; $code[003006] = *I03006; sub I03006 { $core[000123] = $lac & 07777; $lac &= 010000; $code[000123] = *emul8; goto &fetch; }
$core[003007] = 07010; $code[003007] = *I03007; sub I03007 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003010] = 03122; $code[003010] = *I03010; sub I03010 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[003011] = 05600; $code[003011] = *I03011; sub I03011 { $pc = ($ib<<12)+$core[1536]; $inh = 0; goto &fetch; }
$core[003012] = 00000; $code[003012] = *S03012; sub S03012 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003013] = 07300; $code[003013] = *I03013; sub I03013 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003014] = 01122; $code[003014] = *I03014; sub I03014 { $lac += $core[000122]; goto &fetch; }
$core[003015] = 07004; $code[003015] = *I03015; sub I03015 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003016] = 01123; $code[003016] = *I03016; sub I03016 { $lac += $core[000123]; goto &fetch; }
$core[003017] = 07060; $code[003017] = *I03017; sub I03017 { $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[003020] = 01125; $code[003020] = *I03020; sub I03020 { $lac += $core[000125]; goto &fetch; }
$core[003021] = 03123; $code[003021] = *I03021; sub I03021 { $core[000123] = $lac & 07777; $lac &= 010000; $code[000123] = *emul8; goto &fetch; }
$core[003022] = 07010; $code[003022] = *I03022; sub I03022 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003023] = 03122; $code[003023] = *I03023; sub I03023 { $core[000122] = $lac & 07777; $lac &= 010000; $code[000122] = *emul8; goto &fetch; }
$core[003024] = 05612; $code[003024] = *I03024; sub I03024 { $pc = ($ib<<12)+$core[1546]; $inh = 0; goto &fetch; }
$core[003025] = 00000; $code[003025] = *S03025; sub S03025 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003026] = 07300; $code[003026] = *I03026; sub I03026 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003027] = 01124; $code[003027] = *I03027; sub I03027 { $lac += $core[000124]; goto &fetch; }
$core[003030] = 07012; $code[003030] = *I03030; sub I03030 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003031] = 07010; $code[003031] = *I03031; sub I03031 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003032] = 00174; $code[003032] = *I03032; sub I03032 { $lac &= (010000|$core[000174]); goto &fetch; }
$core[003033] = 01174; $code[003033] = *I03033; sub I03033 { $lac += $core[000174]; goto &fetch; }
$core[003034] = 07500; $code[003034] = *I03034; sub I03034 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[003035] = 05240; $code[003035] = *I03035; sub I03035 { $pc = 003040; $inh = 0; goto &fetch; }
$core[003036] = 04200; $code[003036] = *I03036; sub I03036 { $core[003000] = 03037; $pc = 003000+1; $code[003000] = *emul8; $inh = 0; goto &fetch; }
$core[003037] = 05625; $code[003037] = *I03037; sub I03037 { $pc = ($ib<<12)+$core[1557]; $inh = 0; goto &fetch; }
$core[003040] = 04212; $code[003040] = *L03040; sub L03040 { $core[003012] = 03041; $pc = 003012+1; $code[003012] = *emul8; $inh = 0; goto &fetch; }
$core[003041] = 05625; $code[003041] = *I03041; sub I03041 { $pc = ($ib<<12)+$core[1557]; $inh = 0; goto &fetch; }
$core[003042] = 00000; $code[003042] = *I03042; sub I03042 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003043] = 00000; $code[003043] = *I03043; sub I03043 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003044] = 00000; $code[003044] = *I03044; sub I03044 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003045] = 00000; $code[003045] = *I03045; sub I03045 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003046] = 00001; $code[003046] = *I03046; sub I03046 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003047] = 00000; $code[003047] = *I03047; sub I03047 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003050] = 00000; $code[003050] = *I03050; sub I03050 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003051] = 00000; $code[003051] = *I03051; sub I03051 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003052] = 00000; $code[003052] = *I03052; sub I03052 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003053] = 00001; $code[003053] = *I03053; sub I03053 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003054] = 00000; $code[003054] = *I03054; sub I03054 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003055] = 00000; $code[003055] = *I03055; sub I03055 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003056] = 00001; $code[003056] = *I03056; sub I03056 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003057] = 00001; $code[003057] = *I03057; sub I03057 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003060] = 00000; $code[003060] = *I03060; sub I03060 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003061] = 00001; $code[003061] = *I03061; sub I03061 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003062] = 00001; $code[003062] = *I03062; sub I03062 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003063] = 00003; $code[003063] = *I03063; sub I03063 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003064] = 00000; $code[003064] = *I03064; sub I03064 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003065] = 00003; $code[003065] = *I03065; sub I03065 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003066] = 00001; $code[003066] = *I03066; sub I03066 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003067] = 00007; $code[003067] = *I03067; sub I03067 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003070] = 00000; $code[003070] = *I03070; sub I03070 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003071] = 00007; $code[003071] = *I03071; sub I03071 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003072] = 00001; $code[003072] = *I03072; sub I03072 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003073] = 00017; $code[003073] = *I03073; sub I03073 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003074] = 00000; $code[003074] = *I03074; sub I03074 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003075] = 00017; $code[003075] = *I03075; sub I03075 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003076] = 00001; $code[003076] = *I03076; sub I03076 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003077] = 00037; $code[003077] = *I03077; sub I03077 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003100] = 00000; $code[003100] = *I03100; sub I03100 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003101] = 00037; $code[003101] = *I03101; sub I03101 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003102] = 00001; $code[003102] = *I03102; sub I03102 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003103] = 00077; $code[003103] = *I03103; sub I03103 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003104] = 00000; $code[003104] = *I03104; sub I03104 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003105] = 00077; $code[003105] = *I03105; sub I03105 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003106] = 00001; $code[003106] = *I03106; sub I03106 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003107] = 00177; $code[003107] = *I03107; sub I03107 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003110] = 00000; $code[003110] = *I03110; sub I03110 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003111] = 00177; $code[003111] = *I03111; sub I03111 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003112] = 00001; $code[003112] = *I03112; sub I03112 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003113] = 00377; $code[003113] = *I03113; sub I03113 { $lac &= (010000|$core[003177]); goto &fetch; }
$core[003114] = 00000; $code[003114] = *I03114; sub I03114 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003115] = 00377; $code[003115] = *I03115; sub I03115 { $lac &= (010000|$core[003177]); goto &fetch; }
$core[003116] = 00001; $code[003116] = *I03116; sub I03116 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003117] = 00777; $code[003117] = *I03117; sub I03117 { $lac &= (010000|$core[($df<<12)+$core[1663]]); goto &fetch; }
$core[003120] = 00000; $code[003120] = *I03120; sub I03120 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003121] = 00777; $code[003121] = *I03121; sub I03121 { $lac &= (010000|$core[($df<<12)+$core[1663]]); goto &fetch; }
$core[003122] = 00001; $code[003122] = *I03122; sub I03122 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003123] = 01777; $code[003123] = *I03123; sub I03123 { $lac += $core[($df<<12)+$core[1663]]; goto &fetch; }
$core[003124] = 00000; $code[003124] = *I03124; sub I03124 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003125] = 01777; $code[003125] = *I03125; sub I03125 { $lac += $core[($df<<12)+$core[1663]]; goto &fetch; }
$core[003126] = 00001; $code[003126] = *I03126; sub I03126 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003127] = 03777; $code[003127] = *I03127; sub I03127 { $core[($df<<12)+$core[1663]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1663]] = *emul8; goto &fetch; }
$core[003130] = 00000; $code[003130] = *I03130; sub I03130 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003131] = 03777; $code[003131] = *I03131; sub I03131 { $core[($df<<12)+$core[1663]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1663]] = *emul8; goto &fetch; }
$core[003132] = 00001; $code[003132] = *I03132; sub I03132 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003133] = 07777; $code[003133] = *I03133; sub I03133 { &emul8; goto &fetch; }
$core[003134] = 00000; $code[003134] = *I03134; sub I03134 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003135] = 07777; $code[003135] = *I03135; sub I03135 { &emul8; goto &fetch; }
$core[003136] = 00003; $code[003136] = *I03136; sub I03136 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003137] = 00001; $code[003137] = *I03137; sub I03137 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003140] = 00000; $code[003140] = *I03140; sub I03140 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003141] = 00003; $code[003141] = *I03141; sub I03141 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003142] = 00007; $code[003142] = *I03142; sub I03142 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003143] = 00001; $code[003143] = *I03143; sub I03143 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003144] = 00000; $code[003144] = *I03144; sub I03144 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003145] = 00007; $code[003145] = *I03145; sub I03145 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003146] = 00017; $code[003146] = *I03146; sub I03146 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003147] = 00001; $code[003147] = *I03147; sub I03147 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003150] = 00000; $code[003150] = *I03150; sub I03150 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003151] = 00017; $code[003151] = *I03151; sub I03151 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003152] = 00037; $code[003152] = *I03152; sub I03152 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003153] = 00001; $code[003153] = *I03153; sub I03153 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003154] = 00000; $code[003154] = *I03154; sub I03154 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003155] = 00037; $code[003155] = *I03155; sub I03155 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003156] = 00077; $code[003156] = *I03156; sub I03156 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003157] = 00001; $code[003157] = *I03157; sub I03157 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003160] = 00000; $code[003160] = *I03160; sub I03160 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003161] = 00077; $code[003161] = *I03161; sub I03161 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003162] = 00177; $code[003162] = *I03162; sub I03162 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003163] = 00001; $code[003163] = *I03163; sub I03163 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003164] = 00000; $code[003164] = *I03164; sub I03164 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003165] = 00177; $code[003165] = *I03165; sub I03165 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003166] = 00377; $code[003166] = *I03166; sub I03166 { $lac &= (010000|$core[003177]); goto &fetch; }
$core[003167] = 00001; $code[003167] = *I03167; sub I03167 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003170] = 00000; $code[003170] = *I03170; sub I03170 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003171] = 00377; $code[003171] = *I03171; sub I03171 { $lac &= (010000|$core[003177]); goto &fetch; }
$core[003172] = 00777; $code[003172] = *I03172; sub I03172 { $lac &= (010000|$core[($df<<12)+$core[1663]]); goto &fetch; }
$core[003173] = 00001; $code[003173] = *I03173; sub I03173 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003174] = 00000; $code[003174] = *I03174; sub I03174 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003175] = 00777; $code[003175] = *I03175; sub I03175 { $lac &= (010000|$core[($df<<12)+$core[1663]]); goto &fetch; }
$core[003176] = 01777; $code[003176] = *I03176; sub I03176 { $lac += $core[($df<<12)+$core[1663]]; goto &fetch; }
$core[003177] = 00001; $code[003177] = *P03177; sub P03177 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003200] = 00000; $code[003200] = *I03200; sub I03200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003201] = 01777; $code[003201] = *I03201; sub I03201 { $lac += $core[($df<<12)+$core[1791]]; goto &fetch; }
$core[003202] = 03777; $code[003202] = *I03202; sub I03202 { $core[($df<<12)+$core[1791]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1791]] = *emul8; goto &fetch; }
$core[003203] = 00001; $code[003203] = *I03203; sub I03203 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003204] = 00000; $code[003204] = *I03204; sub I03204 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003205] = 03777; $code[003205] = *I03205; sub I03205 { $core[($df<<12)+$core[1791]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1791]] = *emul8; goto &fetch; }
$core[003206] = 07777; $code[003206] = *I03206; sub I03206 { &emul8; goto &fetch; }
$core[003207] = 00001; $code[003207] = *I03207; sub I03207 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003210] = 00000; $code[003210] = *I03210; sub I03210 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003211] = 07777; $code[003211] = *I03211; sub I03211 { &emul8; goto &fetch; }
$core[003212] = 00003; $code[003212] = *I03212; sub I03212 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003213] = 07777; $code[003213] = *I03213; sub I03213 { &emul8; goto &fetch; }
$core[003214] = 00002; $code[003214] = *D03214; sub D03214 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[003215] = 07775; $code[003215] = *P03215; sub P03215 { &emul8; goto &fetch; }
$core[003216] = 00007; $code[003216] = *I03216; sub I03216 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003217] = 07777; $code[003217] = *I03217; sub I03217 { &emul8; goto &fetch; }
$core[003220] = 00006; $code[003220] = *I03220; sub I03220 { $lac &= (010000|$core[000006]); goto &fetch; }
$core[003221] = 07771; $code[003221] = *I03221; sub I03221 { &emul8; goto &fetch; }
$core[003222] = 00017; $code[003222] = *I03222; sub I03222 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003223] = 07777; $code[003223] = *I03223; sub I03223 { &emul8; goto &fetch; }
$core[003224] = 00016; $code[003224] = *I03224; sub I03224 { $lac &= (010000|$core[000016]); goto &fetch; }
$core[003225] = 07761; $code[003225] = *I03225; sub I03225 { &emul8; goto &fetch; }
$core[003226] = 00037; $code[003226] = *I03226; sub I03226 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003227] = 07777; $code[003227] = *I03227; sub I03227 { &emul8; goto &fetch; }
$core[003230] = 00036; $code[003230] = *I03230; sub I03230 { $lac &= (010000|$core[000036]); goto &fetch; }
$core[003231] = 07741; $code[003231] = *I03231; sub I03231 { &emul8; goto &fetch; }
$core[003232] = 00077; $code[003232] = *I03232; sub I03232 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003233] = 07777; $code[003233] = *I03233; sub I03233 { &emul8; goto &fetch; }
$core[003234] = 00076; $code[003234] = *I03234; sub I03234 { $lac &= (010000|$core[000076]); goto &fetch; }
$core[003235] = 07701; $code[003235] = *I03235; sub I03235 { &emul8; goto &fetch; }
$core[003236] = 00177; $code[003236] = *I03236; sub I03236 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003237] = 07777; $code[003237] = *I03237; sub I03237 { &emul8; goto &fetch; }
$core[003240] = 00176; $code[003240] = *I03240; sub I03240 { $lac &= (010000|$core[000176]); goto &fetch; }
$core[003241] = 07601; $code[003241] = *I03241; sub I03241 { &emul8; goto &fetch; }
$core[003242] = 00377; $code[003242] = *I03242; sub I03242 { $lac &= (010000|$core[003377]); goto &fetch; }
$core[003243] = 07777; $code[003243] = *I03243; sub I03243 { &emul8; goto &fetch; }
$core[003244] = 00376; $code[003244] = *I03244; sub I03244 { $lac &= (010000|$core[003376]); goto &fetch; }
$core[003245] = 07401; $code[003245] = *I03245; sub I03245 { &emul8; goto &fetch; }
$core[003246] = 00777; $code[003246] = *I03246; sub I03246 { $lac &= (010000|$core[($df<<12)+$core[1791]]); goto &fetch; }
$core[003247] = 07777; $code[003247] = *I03247; sub I03247 { &emul8; goto &fetch; }
$core[003250] = 00776; $code[003250] = *I03250; sub I03250 { $lac &= (010000|$core[($df<<12)+$core[1790]]); goto &fetch; }
$core[003251] = 07001; $code[003251] = *I03251; sub I03251 { $lac++; goto &fetch; }
$core[003252] = 01777; $code[003252] = *L03252; sub L03252 { $lac += $core[($df<<12)+$core[1791]]; goto &fetch; }
$core[003253] = 07777; $code[003253] = *I03253; sub I03253 { &emul8; goto &fetch; }
$core[003254] = 01776; $code[003254] = *I03254; sub I03254 { $lac += $core[($df<<12)+$core[1790]]; goto &fetch; }
$core[003255] = 06001; $code[003255] = *I03255; sub I03255 { &emul8; goto &fetch; }
$core[003256] = 03777; $code[003256] = *I03256; sub I03256 { $core[($df<<12)+$core[1791]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1791]] = *emul8; goto &fetch; }
$core[003257] = 07777; $code[003257] = *I03257; sub I03257 { &emul8; goto &fetch; }
$core[003260] = 03776; $code[003260] = *I03260; sub I03260 { $core[($df<<12)+$core[1790]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1790]] = *emul8; goto &fetch; }
$core[003261] = 04001; $code[003261] = *I03261; sub I03261 { $core[000001] = 03262; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[003262] = 07777; $code[003262] = *I03262; sub I03262 { &emul8; goto &fetch; }
$core[003263] = 07777; $code[003263] = *I03263; sub I03263 { &emul8; goto &fetch; }
$core[003264] = 07776; $code[003264] = *I03264; sub I03264 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[003265] = 00001; $code[003265] = *I03265; sub I03265 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003266] = 07777; $code[003266] = *I03266; sub I03266 { &emul8; goto &fetch; }
$core[003267] = 00003; $code[003267] = *I03267; sub I03267 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003270] = 00002; $code[003270] = *I03270; sub I03270 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[003271] = 07775; $code[003271] = *I03271; sub I03271 { &emul8; goto &fetch; }
$core[003272] = 07777; $code[003272] = *I03272; sub I03272 { &emul8; goto &fetch; }
$core[003273] = 00007; $code[003273] = *I03273; sub I03273 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003274] = 00006; $code[003274] = *I03274; sub I03274 { $lac &= (010000|$core[000006]); goto &fetch; }
$core[003275] = 07771; $code[003275] = *I03275; sub I03275 { &emul8; goto &fetch; }
$core[003276] = 07777; $code[003276] = *I03276; sub I03276 { &emul8; goto &fetch; }
$core[003277] = 00017; $code[003277] = *I03277; sub I03277 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003300] = 00016; $code[003300] = *I03300; sub I03300 { $lac &= (010000|$core[000016]); goto &fetch; }
$core[003301] = 07761; $code[003301] = *I03301; sub I03301 { &emul8; goto &fetch; }
$core[003302] = 07777; $code[003302] = *I03302; sub I03302 { &emul8; goto &fetch; }
$core[003303] = 00037; $code[003303] = *I03303; sub I03303 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003304] = 00036; $code[003304] = *I03304; sub I03304 { $lac &= (010000|$core[000036]); goto &fetch; }
$core[003305] = 07741; $code[003305] = *I03305; sub I03305 { &emul8; goto &fetch; }
$core[003306] = 07777; $code[003306] = *I03306; sub I03306 { &emul8; goto &fetch; }
$core[003307] = 00077; $code[003307] = *I03307; sub I03307 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003310] = 00076; $code[003310] = *I03310; sub I03310 { $lac &= (010000|$core[000076]); goto &fetch; }
$core[003311] = 07701; $code[003311] = *I03311; sub I03311 { &emul8; goto &fetch; }
$core[003312] = 07777; $code[003312] = *I03312; sub I03312 { &emul8; goto &fetch; }
$core[003313] = 00177; $code[003313] = *I03313; sub I03313 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003314] = 00176; $code[003314] = *I03314; sub I03314 { $lac &= (010000|$core[000176]); goto &fetch; }
$core[003315] = 07601; $code[003315] = *I03315; sub I03315 { &emul8; goto &fetch; }
$core[003316] = 07777; $code[003316] = *I03316; sub I03316 { &emul8; goto &fetch; }
$core[003317] = 00377; $code[003317] = *I03317; sub I03317 { $lac &= (010000|$core[003377]); goto &fetch; }
$core[003320] = 00376; $code[003320] = *I03320; sub I03320 { $lac &= (010000|$core[003376]); goto &fetch; }
$core[003321] = 07401; $code[003321] = *I03321; sub I03321 { &emul8; goto &fetch; }
$core[003322] = 07777; $code[003322] = *I03322; sub I03322 { &emul8; goto &fetch; }
$core[003323] = 00777; $code[003323] = *I03323; sub I03323 { $lac &= (010000|$core[($df<<12)+$core[1791]]); goto &fetch; }
$core[003324] = 00776; $code[003324] = *I03324; sub I03324 { $lac &= (010000|$core[($df<<12)+$core[1790]]); goto &fetch; }
$core[003325] = 07001; $code[003325] = *I03325; sub I03325 { $lac++; goto &fetch; }
$core[003326] = 07777; $code[003326] = *I03326; sub I03326 { &emul8; goto &fetch; }
$core[003327] = 01777; $code[003327] = *I03327; sub I03327 { $lac += $core[($df<<12)+$core[1791]]; goto &fetch; }
$core[003330] = 01776; $code[003330] = *I03330; sub I03330 { $lac += $core[($df<<12)+$core[1790]]; goto &fetch; }
$core[003331] = 06001; $code[003331] = *I03331; sub I03331 { &emul8; goto &fetch; }
$core[003332] = 07777; $code[003332] = *I03332; sub I03332 { &emul8; goto &fetch; }
$core[003333] = 03777; $code[003333] = *I03333; sub I03333 { $core[($df<<12)+$core[1791]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1791]] = *emul8; goto &fetch; }
$core[003334] = 03776; $code[003334] = *I03334; sub I03334 { $core[($df<<12)+$core[1790]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1790]] = *emul8; goto &fetch; }
$core[003335] = 04001; $code[003335] = *I03335; sub I03335 { $core[000001] = 03336; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[003336] = 00001; $code[003336] = *I03336; sub I03336 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003337] = 04000; $code[003337] = *I03337; sub I03337 { $core[000000] = 03340; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[003340] = 00000; $code[003340] = *I03340; sub I03340 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003341] = 04000; $code[003341] = *I03341; sub I03341 { $core[000000] = 03342; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[003342] = 04000; $code[003342] = *I03342; sub I03342 { $core[000000] = 03343; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[003343] = 00001; $code[003343] = *I03343; sub I03343 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003344] = 00000; $code[003344] = *I03344; sub I03344 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003345] = 04000; $code[003345] = *I03345; sub I03345 { $core[000000] = 03346; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[003346] = 00001; $code[003346] = *I03346; sub I03346 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003347] = 05252; $code[003347] = *I03347; sub I03347 { $pc = 003252; $inh = 0; goto &fetch; }
$core[003350] = 00000; $code[003350] = *I03350; sub I03350 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003351] = 05252; $code[003351] = *I03351; sub I03351 { $pc = 003252; $inh = 0; goto &fetch; }
$core[003352] = 00001; $code[003352] = *I03352; sub I03352 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003353] = 02525; $code[003353] = *I03353; sub I03353 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[003354] = 00000; $code[003354] = *I03354; sub I03354 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003355] = 02525; $code[003355] = *I03355; sub I03355 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[003356] = 05252; $code[003356] = *I03356; sub I03356 { $pc = 003252; $inh = 0; goto &fetch; }
$core[003357] = 00001; $code[003357] = *I03357; sub I03357 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003360] = 00000; $code[003360] = *I03360; sub I03360 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003361] = 05252; $code[003361] = *I03361; sub I03361 { $pc = 003252; $inh = 0; goto &fetch; }
$core[003362] = 02525; $code[003362] = *I03362; sub I03362 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[003363] = 00001; $code[003363] = *I03363; sub I03363 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003364] = 00000; $code[003364] = *I03364; sub I03364 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003365] = 02525; $code[003365] = *I03365; sub I03365 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[003366] = 05252; $code[003366] = *I03366; sub I03366 { $pc = 003252; $inh = 0; goto &fetch; }
$core[003367] = 02525; $code[003367] = *I03367; sub I03367 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[003370] = 01615; $code[003370] = *I03370; sub I03370 { $lac += $core[($df<<12)+$core[1677]]; goto &fetch; }
$core[003371] = 06162; $code[003371] = *I03371; sub I03371 { &emul8; goto &fetch; }
$core[003372] = 02525; $code[003372] = *I03372; sub I03372 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[003373] = 05252; $code[003373] = *I03373; sub I03373 { $pc = 003252; $inh = 0; goto &fetch; }
$core[003374] = 01615; $code[003374] = *I03374; sub I03374 { $lac += $core[($df<<12)+$core[1677]]; goto &fetch; }
$core[003375] = 06162; $code[003375] = *I03375; sub I03375 { &emul8; goto &fetch; }
$core[003376] = 00000; $code[003376] = *P03376; sub P03376 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003377] = 00000; $code[003377] = *P03377; sub P03377 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003400] = 00000; $code[003400] = *I03400; sub I03400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003401] = 00001; $code[003401] = *I03401; sub I03401 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003402] = 00000; $code[003402] = *I03402; sub I03402 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003403] = 00001; $code[003403] = *I03403; sub I03403 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003404] = 07777; $code[003404] = *I03404; sub I03404 { &emul8; goto &fetch; }
$core[003405] = 00000; $code[003405] = *I03405; sub I03405 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003406] = 07777; $code[003406] = *I03406; sub I03406 { &emul8; goto &fetch; }
$core[003407] = 00001; $code[003407] = *I03407; sub I03407 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003410] = 07777; $code[003410] = *I03410; sub I03410 { &emul8; goto &fetch; }
$core[003411] = 00001; $code[003411] = *I03411; sub I03411 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003412] = 00000; $code[003412] = *I03412; sub I03412 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003413] = 00000; $code[003413] = *I03413; sub I03413 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003414] = 00001; $code[003414] = *I03414; sub I03414 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003415] = 00000; $code[003415] = *I03415; sub I03415 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003416] = 00000; $code[003416] = *I03416; sub I03416 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003417] = 00000; $code[003417] = *I03417; sub I03417 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003420] = 00000; $code[003420] = *I03420; sub I03420 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003421] = 00000; $code[003421] = *I03421; sub I03421 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003422] = 00003; $code[003422] = *I03422; sub I03422 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003423] = 00000; $code[003423] = *I03423; sub I03423 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003424] = 00000; $code[003424] = *I03424; sub I03424 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003425] = 00000; $code[003425] = *I03425; sub I03425 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003426] = 00000; $code[003426] = *I03426; sub I03426 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003427] = 00000; $code[003427] = *I03427; sub I03427 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003430] = 00007; $code[003430] = *I03430; sub I03430 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003431] = 00000; $code[003431] = *I03431; sub I03431 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003432] = 00000; $code[003432] = *I03432; sub I03432 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003433] = 00000; $code[003433] = *I03433; sub I03433 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003434] = 00000; $code[003434] = *I03434; sub I03434 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003435] = 00000; $code[003435] = *I03435; sub I03435 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003436] = 00017; $code[003436] = *I03436; sub I03436 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003437] = 00000; $code[003437] = *I03437; sub I03437 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003440] = 00000; $code[003440] = *I03440; sub I03440 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003441] = 00000; $code[003441] = *I03441; sub I03441 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003442] = 00000; $code[003442] = *I03442; sub I03442 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003443] = 00000; $code[003443] = *I03443; sub I03443 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003444] = 00037; $code[003444] = *I03444; sub I03444 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003445] = 00000; $code[003445] = *I03445; sub I03445 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003446] = 00000; $code[003446] = *I03446; sub I03446 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003447] = 00000; $code[003447] = *I03447; sub I03447 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003450] = 00000; $code[003450] = *I03450; sub I03450 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003451] = 00000; $code[003451] = *I03451; sub I03451 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003452] = 00077; $code[003452] = *I03452; sub I03452 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003453] = 00000; $code[003453] = *I03453; sub I03453 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003454] = 00000; $code[003454] = *I03454; sub I03454 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003455] = 00000; $code[003455] = *I03455; sub I03455 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003456] = 00000; $code[003456] = *I03456; sub I03456 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003457] = 00000; $code[003457] = *I03457; sub I03457 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003460] = 00177; $code[003460] = *I03460; sub I03460 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003461] = 00000; $code[003461] = *I03461; sub I03461 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003462] = 00000; $code[003462] = *I03462; sub I03462 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003463] = 00000; $code[003463] = *I03463; sub I03463 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003464] = 00000; $code[003464] = *I03464; sub I03464 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003465] = 00000; $code[003465] = *I03465; sub I03465 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003466] = 00377; $code[003466] = *I03466; sub I03466 { $lac &= (010000|$core[003577]); goto &fetch; }
$core[003467] = 00000; $code[003467] = *I03467; sub I03467 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003470] = 00000; $code[003470] = *I03470; sub I03470 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003471] = 00000; $code[003471] = *I03471; sub I03471 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003472] = 00000; $code[003472] = *I03472; sub I03472 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003473] = 00000; $code[003473] = *I03473; sub I03473 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003474] = 00777; $code[003474] = *I03474; sub I03474 { $lac &= (010000|$core[($df<<12)+$core[1919]]); goto &fetch; }
$core[003475] = 00000; $code[003475] = *I03475; sub I03475 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003476] = 00000; $code[003476] = *I03476; sub I03476 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003477] = 00000; $code[003477] = *I03477; sub I03477 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003500] = 00000; $code[003500] = *I03500; sub I03500 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003501] = 00000; $code[003501] = *I03501; sub I03501 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003502] = 01777; $code[003502] = *I03502; sub I03502 { $lac += $core[($df<<12)+$core[1919]]; goto &fetch; }
$core[003503] = 00000; $code[003503] = *I03503; sub I03503 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003504] = 00000; $code[003504] = *I03504; sub I03504 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003505] = 00000; $code[003505] = *I03505; sub I03505 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003506] = 00000; $code[003506] = *I03506; sub I03506 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003507] = 00000; $code[003507] = *I03507; sub I03507 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003510] = 03777; $code[003510] = *I03510; sub I03510 { $core[($df<<12)+$core[1919]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1919]] = *emul8; goto &fetch; }
$core[003511] = 00000; $code[003511] = *I03511; sub I03511 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003512] = 00000; $code[003512] = *I03512; sub I03512 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003513] = 00000; $code[003513] = *I03513; sub I03513 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003514] = 00000; $code[003514] = *I03514; sub I03514 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003515] = 00000; $code[003515] = *I03515; sub I03515 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003516] = 07777; $code[003516] = *I03516; sub I03516 { &emul8; goto &fetch; }
$core[003517] = 00000; $code[003517] = *I03517; sub I03517 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003520] = 00000; $code[003520] = *I03520; sub I03520 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003521] = 00000; $code[003521] = *I03521; sub I03521 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003522] = 00000; $code[003522] = *I03522; sub I03522 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003523] = 00001; $code[003523] = *I03523; sub I03523 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003524] = 07777; $code[003524] = *I03524; sub I03524 { &emul8; goto &fetch; }
$core[003525] = 00000; $code[003525] = *I03525; sub I03525 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003526] = 00001; $code[003526] = *I03526; sub I03526 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003527] = 00000; $code[003527] = *I03527; sub I03527 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003530] = 00000; $code[003530] = *I03530; sub I03530 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003531] = 00003; $code[003531] = *I03531; sub I03531 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003532] = 07777; $code[003532] = *I03532; sub I03532 { &emul8; goto &fetch; }
$core[003533] = 00000; $code[003533] = *I03533; sub I03533 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003534] = 00003; $code[003534] = *I03534; sub I03534 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003535] = 00000; $code[003535] = *I03535; sub I03535 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003536] = 00000; $code[003536] = *I03536; sub I03536 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003537] = 00007; $code[003537] = *I03537; sub I03537 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003540] = 07777; $code[003540] = *I03540; sub I03540 { &emul8; goto &fetch; }
$core[003541] = 00000; $code[003541] = *I03541; sub I03541 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003542] = 00007; $code[003542] = *I03542; sub I03542 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003543] = 00000; $code[003543] = *I03543; sub I03543 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003544] = 00000; $code[003544] = *I03544; sub I03544 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003545] = 00017; $code[003545] = *I03545; sub I03545 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003546] = 07777; $code[003546] = *I03546; sub I03546 { &emul8; goto &fetch; }
$core[003547] = 00000; $code[003547] = *I03547; sub I03547 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003550] = 00017; $code[003550] = *I03550; sub I03550 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003551] = 00000; $code[003551] = *I03551; sub I03551 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003552] = 00000; $code[003552] = *I03552; sub I03552 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003553] = 00037; $code[003553] = *I03553; sub I03553 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003554] = 07777; $code[003554] = *I03554; sub I03554 { &emul8; goto &fetch; }
$core[003555] = 00000; $code[003555] = *I03555; sub I03555 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003556] = 00037; $code[003556] = *I03556; sub I03556 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003557] = 00000; $code[003557] = *I03557; sub I03557 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003560] = 00000; $code[003560] = *I03560; sub I03560 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003561] = 00077; $code[003561] = *I03561; sub I03561 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003562] = 07777; $code[003562] = *I03562; sub I03562 { &emul8; goto &fetch; }
$core[003563] = 00000; $code[003563] = *I03563; sub I03563 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003564] = 00077; $code[003564] = *I03564; sub I03564 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003565] = 00000; $code[003565] = *I03565; sub I03565 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003566] = 00000; $code[003566] = *I03566; sub I03566 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003567] = 00377; $code[003567] = *I03567; sub I03567 { $lac &= (010000|$core[003577]); goto &fetch; }
$core[003570] = 07777; $code[003570] = *I03570; sub I03570 { &emul8; goto &fetch; }
$core[003571] = 00000; $code[003571] = *I03571; sub I03571 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003572] = 00377; $code[003572] = *I03572; sub I03572 { $lac &= (010000|$core[003577]); goto &fetch; }
$core[003573] = 00000; $code[003573] = *I03573; sub I03573 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003574] = 00000; $code[003574] = *I03574; sub I03574 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003575] = 00777; $code[003575] = *I03575; sub I03575 { $lac &= (010000|$core[($df<<12)+$core[1919]]); goto &fetch; }
$core[003576] = 07777; $code[003576] = *I03576; sub I03576 { &emul8; goto &fetch; }
$core[003577] = 00000; $code[003577] = *P03577; sub P03577 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003600] = 00777; $code[003600] = *I03600; sub I03600 { $lac &= (010000|$core[($df<<12)+$core[2047]]); goto &fetch; }
$core[003601] = 00000; $code[003601] = *I03601; sub I03601 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003602] = 00000; $code[003602] = *I03602; sub I03602 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003603] = 01777; $code[003603] = *I03603; sub I03603 { $lac += $core[($df<<12)+$core[2047]]; goto &fetch; }
$core[003604] = 07777; $code[003604] = *I03604; sub I03604 { &emul8; goto &fetch; }
$core[003605] = 00000; $code[003605] = *I03605; sub I03605 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003606] = 01777; $code[003606] = *I03606; sub I03606 { $lac += $core[($df<<12)+$core[2047]]; goto &fetch; }
$core[003607] = 00000; $code[003607] = *I03607; sub I03607 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003610] = 00000; $code[003610] = *I03610; sub I03610 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003611] = 03777; $code[003611] = *I03611; sub I03611 { $core[($df<<12)+$core[2047]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2047]] = *emul8; goto &fetch; }
$core[003612] = 07777; $code[003612] = *I03612; sub I03612 { &emul8; goto &fetch; }
$core[003613] = 00000; $code[003613] = *I03613; sub I03613 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003614] = 03777; $code[003614] = *I03614; sub I03614 { $core[($df<<12)+$core[2047]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2047]] = *emul8; goto &fetch; }
$core[003615] = 00000; $code[003615] = *I03615; sub I03615 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003616] = 00001; $code[003616] = *I03616; sub I03616 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003617] = 00000; $code[003617] = *I03617; sub I03617 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003620] = 07777; $code[003620] = *I03620; sub I03620 { &emul8; goto &fetch; }
$core[003621] = 00000; $code[003621] = *I03621; sub I03621 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003622] = 00001; $code[003622] = *I03622; sub I03622 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003623] = 00001; $code[003623] = *I03623; sub I03623 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003624] = 00003; $code[003624] = *I03624; sub I03624 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003625] = 00000; $code[003625] = *I03625; sub I03625 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003626] = 07777; $code[003626] = *I03626; sub I03626 { &emul8; goto &fetch; }
$core[003627] = 00000; $code[003627] = *I03627; sub I03627 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003630] = 00003; $code[003630] = *I03630; sub I03630 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003631] = 00003; $code[003631] = *I03631; sub I03631 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003632] = 00007; $code[003632] = *I03632; sub I03632 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003633] = 00000; $code[003633] = *I03633; sub I03633 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003634] = 07777; $code[003634] = *I03634; sub I03634 { &emul8; goto &fetch; }
$core[003635] = 00000; $code[003635] = *I03635; sub I03635 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003636] = 00007; $code[003636] = *I03636; sub I03636 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003637] = 00007; $code[003637] = *I03637; sub I03637 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003640] = 00017; $code[003640] = *I03640; sub I03640 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003641] = 00000; $code[003641] = *I03641; sub I03641 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003642] = 07777; $code[003642] = *I03642; sub I03642 { &emul8; goto &fetch; }
$core[003643] = 00000; $code[003643] = *I03643; sub I03643 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003644] = 00017; $code[003644] = *I03644; sub I03644 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003645] = 00017; $code[003645] = *I03645; sub I03645 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003646] = 00037; $code[003646] = *I03646; sub I03646 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003647] = 00000; $code[003647] = *I03647; sub I03647 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003650] = 07777; $code[003650] = *I03650; sub I03650 { &emul8; goto &fetch; }
$core[003651] = 00000; $code[003651] = *I03651; sub I03651 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003652] = 00037; $code[003652] = *L03652; sub L03652 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003653] = 00037; $code[003653] = *I03653; sub I03653 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[003654] = 00077; $code[003654] = *I03654; sub I03654 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003655] = 00000; $code[003655] = *I03655; sub I03655 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003656] = 07777; $code[003656] = *I03656; sub I03656 { &emul8; goto &fetch; }
$core[003657] = 00000; $code[003657] = *I03657; sub I03657 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003660] = 00077; $code[003660] = *I03660; sub I03660 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003661] = 00077; $code[003661] = *I03661; sub I03661 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[003662] = 00177; $code[003662] = *I03662; sub I03662 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003663] = 00000; $code[003663] = *I03663; sub I03663 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003664] = 07777; $code[003664] = *I03664; sub I03664 { &emul8; goto &fetch; }
$core[003665] = 00000; $code[003665] = *I03665; sub I03665 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003666] = 00177; $code[003666] = *I03666; sub I03666 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003667] = 00177; $code[003667] = *I03667; sub I03667 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[003670] = 00377; $code[003670] = *I03670; sub I03670 { $lac &= (010000|$core[003777]); goto &fetch; }
$core[003671] = 00000; $code[003671] = *I03671; sub I03671 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003672] = 07777; $code[003672] = *I03672; sub I03672 { &emul8; goto &fetch; }
$core[003673] = 00000; $code[003673] = *I03673; sub I03673 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003674] = 00377; $code[003674] = *I03674; sub I03674 { $lac &= (010000|$core[003777]); goto &fetch; }
$core[003675] = 00377; $code[003675] = *I03675; sub I03675 { $lac &= (010000|$core[003777]); goto &fetch; }
$core[003676] = 00777; $code[003676] = *I03676; sub I03676 { $lac &= (010000|$core[($df<<12)+$core[2047]]); goto &fetch; }
$core[003677] = 00000; $code[003677] = *I03677; sub I03677 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003700] = 07777; $code[003700] = *I03700; sub I03700 { &emul8; goto &fetch; }
$core[003701] = 00000; $code[003701] = *I03701; sub I03701 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003702] = 00777; $code[003702] = *I03702; sub I03702 { $lac &= (010000|$core[($df<<12)+$core[2047]]); goto &fetch; }
$core[003703] = 00777; $code[003703] = *I03703; sub I03703 { $lac &= (010000|$core[($df<<12)+$core[2047]]); goto &fetch; }
$core[003704] = 01777; $code[003704] = *I03704; sub I03704 { $lac += $core[($df<<12)+$core[2047]]; goto &fetch; }
$core[003705] = 00000; $code[003705] = *I03705; sub I03705 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003706] = 07777; $code[003706] = *I03706; sub I03706 { &emul8; goto &fetch; }
$core[003707] = 00000; $code[003707] = *P03707; sub P03707 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003710] = 01777; $code[003710] = *I03710; sub I03710 { $lac += $core[($df<<12)+$core[2047]]; goto &fetch; }
$core[003711] = 01777; $code[003711] = *I03711; sub I03711 { $lac += $core[($df<<12)+$core[2047]]; goto &fetch; }
$core[003712] = 03777; $code[003712] = *I03712; sub I03712 { $core[($df<<12)+$core[2047]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2047]] = *emul8; goto &fetch; }
$core[003713] = 00000; $code[003713] = *I03713; sub I03713 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003714] = 07777; $code[003714] = *I03714; sub I03714 { &emul8; goto &fetch; }
$core[003715] = 00000; $code[003715] = *I03715; sub I03715 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003716] = 03777; $code[003716] = *I03716; sub I03716 { $core[($df<<12)+$core[2047]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2047]] = *emul8; goto &fetch; }
$core[003717] = 03777; $code[003717] = *I03717; sub I03717 { $core[($df<<12)+$core[2047]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2047]] = *emul8; goto &fetch; }
$core[003720] = 00000; $code[003720] = *I03720; sub I03720 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003721] = 07777; $code[003721] = *I03721; sub I03721 { &emul8; goto &fetch; }
$core[003722] = 00001; $code[003722] = *I03722; sub I03722 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003723] = 00000; $code[003723] = *I03723; sub I03723 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003724] = 00000; $code[003724] = *I03724; sub I03724 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003725] = 07777; $code[003725] = *I03725; sub I03725 { &emul8; goto &fetch; }
$core[003726] = 00001; $code[003726] = *I03726; sub I03726 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003727] = 02525; $code[003727] = *I03727; sub I03727 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[003730] = 00002; $code[003730] = *I03730; sub I03730 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[003731] = 00000; $code[003731] = *I03731; sub I03731 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003732] = 00001; $code[003732] = *I03732; sub I03732 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003733] = 05252; $code[003733] = *I03733; sub I03733 { $pc = 003652; $inh = 0; goto &fetch; }
$core[003734] = 00000; $code[003734] = *I03734; sub I03734 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003735] = 05252; $code[003735] = *I03735; sub I03735 { $pc = 003652; $inh = 0; goto &fetch; }
$core[003736] = 00002; $code[003736] = *I03736; sub I03736 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[003737] = 00000; $code[003737] = *I03737; sub I03737 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003740] = 00000; $code[003740] = *I03740; sub I03740 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003741] = 02525; $code[003741] = *I03741; sub I03741 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[003742] = 00007; $code[003742] = *I03742; sub I03742 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003743] = 00707; $code[003743] = *I03743; sub I03743 { $lac &= (010000|$core[($df<<12)+$core[1991]]); goto &fetch; }
$core[003744] = 00010; $code[003744] = *I03744; sub I03744 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[003745] = 00000; $code[003745] = *I03745; sub I03745 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003746] = 00007; $code[003746] = *I03746; sub I03746 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[003747] = 07070; $code[003747] = *I03747; sub I03747 { $lac ^= 010000; $lac ^= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003750] = 00000; $code[003750] = *I03750; sub I03750 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003751] = 07070; $code[003751] = *I03751; sub I03751 { $lac ^= 010000; $lac ^= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003752] = 00010; $code[003752] = *I03752; sub I03752 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[003753] = 00000; $code[003753] = *I03753; sub I03753 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003754] = 00000; $code[003754] = *I03754; sub I03754 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003755] = 00707; $code[003755] = *I03755; sub I03755 { $lac &= (010000|$core[($df<<12)+$core[1991]]); goto &fetch; }
$core[003756] = 00000; $code[003756] = *S03756; sub S03756 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003757] = 07300; $code[003757] = *I03757; sub I03757 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003760] = 01020; $code[003760] = *I03760; sub I03760 { $lac += $core[000020]; goto &fetch; }
$core[003761] = 07040; $code[003761] = *I03761; sub I03761 { $lac ^= 07777; goto &fetch; }
$core[003762] = 01377; $code[003762] = *I03762; sub I03762 { $lac += $core[003777]; goto &fetch; }
$core[003763] = 03373; $code[003763] = *I03763; sub I03763 { $core[003773] = $lac & 07777; $lac &= 010000; $code[003773] = *emul8; goto &fetch; }
$core[003764] = 04445; $code[003764] = *I03764; sub I03764 { $core[($ib<<12)+$core[37]] = 03765; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[003765] = 07774; $code[003765] = *I03765; sub I03765 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003766] = 04426; $code[003766] = *I03766; sub I03766 { $core[($ib<<12)+$core[22]] = 03767; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[003767] = 03771; $code[003767] = *I03767; sub I03767 { $core[($df<<12)+$core[2041]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2041]] = *emul8; goto &fetch; }
$core[003770] = 05756; $code[003770] = *I03770; sub I03770 { $pc = ($ib<<12)+$core[2030]; $inh = 0; goto &fetch; }
$core[003771] = 01517; $code[003771] = *P03771; sub P03771 { $lac += $core[($df<<12)+$core[79]]; goto &fetch; }
$core[003772] = 00405; $code[003772] = *I03772; sub I03772 { $lac &= (010000|$core[($df<<12)+$core[5]]); goto &fetch; }
$core[003773] = 00000; $code[003773] = *D03773; sub D03773 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003774] = 00001; $code[003774] = *I03774; sub I03774 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[003777] = 04002; $code[003777] = *P03777; sub P03777 { $core[000002] = 04000; $pc = 000002+1; $code[000002] = *emul8; $inh = 0; goto &fetch; }
$core[004000] = 00000; $code[004000] = *P04000; sub P04000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004001] = 04777; $code[004001] = *I04001; sub I04001 { $core[($ib<<12)+$core[2175]] = 04002; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004002] = 03212; $code[004002] = *D04002; sub D04002 { $core[004012] = $lac & 07777; $lac &= 010000; $code[004012] = *emul8; goto &fetch; }
$core[004003] = 04777; $code[004003] = *I04003; sub I04003 { $core[($ib<<12)+$core[2175]] = 04004; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004004] = 03214; $code[004004] = *I04004; sub I04004 { $core[004014] = $lac & 07777; $lac &= 010000; $code[004014] = *emul8; goto &fetch; }
$core[004005] = 05600; $code[004005] = *I04005; sub I04005 { $pc = ($ib<<12)+$core[2048]; $inh = 0; goto &fetch; }
$core[004006] = 00000; $code[004006] = *P04006; sub P04006 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004007] = 07200; $code[004007] = *I04007; sub I04007 { $lac &= 010000; goto &fetch; }
$core[004010] = 01104; $code[004010] = *L04010; sub L04010 { $lac += $core[000104]; goto &fetch; }
$core[004011] = 07425; $code[004011] = *I04011; sub I04011 { &emul8; goto &fetch; }
$core[004012] = 00000; $code[004012] = *D04012; sub D04012 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004013] = 07407; $code[004013] = *I04013; sub I04013 { &emul8; goto &fetch; }
$core[004014] = 00000; $code[004014] = *D04014; sub D04014 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004015] = 05606; $code[004015] = *I04015; sub I04015 { $pc = ($ib<<12)+$core[2054]; $inh = 0; goto &fetch; }
$core[004016] = 00000; $code[004016] = *P04016; sub P04016 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004017] = 04777; $code[004017] = *I04017; sub I04017 { $core[($ib<<12)+$core[2175]] = 04020; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004020] = 03234; $code[004020] = *I04020; sub I04020 { $core[004034] = $lac & 07777; $lac &= 010000; $code[004034] = *emul8; goto &fetch; }
$core[004021] = 04777; $code[004021] = *I04021; sub I04021 { $core[($ib<<12)+$core[2175]] = 04022; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004022] = 03236; $code[004022] = *I04022; sub I04022 { $core[004036] = $lac & 07777; $lac &= 010000; $code[004036] = *emul8; goto &fetch; }
$core[004023] = 04777; $code[004023] = *I04023; sub I04023 { $core[($ib<<12)+$core[2175]] = 04024; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004024] = 03240; $code[004024] = *I04024; sub I04024 { $core[004040] = $lac & 07777; $lac &= 010000; $code[004040] = *emul8; goto &fetch; }
$core[004025] = 04776; $code[004025] = *I04025; sub I04025 { $core[($ib<<12)+$core[2174]] = 04026; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004026] = 03242; $code[004026] = *I04026; sub I04026 { $core[004042] = $lac & 07777; $lac &= 010000; $code[004042] = *emul8; goto &fetch; }
$core[004027] = 05616; $code[004027] = *I04027; sub I04027 { $pc = ($ib<<12)+$core[2062]; $inh = 0; goto &fetch; }
$core[004030] = 00000; $code[004030] = *P04030; sub P04030 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004031] = 07200; $code[004031] = *I04031; sub I04031 { $lac &= 010000; goto &fetch; }
$core[004032] = 01104; $code[004032] = *I04032; sub I04032 { $lac += $core[000104]; goto &fetch; }
$core[004033] = 07425; $code[004033] = *I04033; sub I04033 { &emul8; goto &fetch; }
$core[004034] = 00000; $code[004034] = *D04034; sub D04034 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004035] = 07407; $code[004035] = *I04035; sub I04035 { &emul8; goto &fetch; }
$core[004036] = 00000; $code[004036] = *D04036; sub D04036 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004037] = 07405; $code[004037] = *I04037; sub I04037 { &emul8; goto &fetch; }
$core[004040] = 00000; $code[004040] = *D04040; sub D04040 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004041] = 07407; $code[004041] = *I04041; sub I04041 { &emul8; goto &fetch; }
$core[004042] = 00000; $code[004042] = *D04042; sub D04042 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004043] = 05630; $code[004043] = *I04043; sub I04043 { $pc = ($ib<<12)+$core[2072]; $inh = 0; goto &fetch; }
$core[004044] = 00000; $code[004044] = *P04044; sub P04044 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004045] = 04777; $code[004045] = *I04045; sub I04045 { $core[($ib<<12)+$core[2175]] = 04046; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004046] = 03266; $code[004046] = *I04046; sub I04046 { $core[004066] = $lac & 07777; $lac &= 010000; $code[004066] = *emul8; goto &fetch; }
$core[004047] = 04777; $code[004047] = *I04047; sub I04047 { $core[($ib<<12)+$core[2175]] = 04050; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004050] = 03270; $code[004050] = *I04050; sub I04050 { $core[004070] = $lac & 07777; $lac &= 010000; $code[004070] = *emul8; goto &fetch; }
$core[004051] = 04777; $code[004051] = *I04051; sub I04051 { $core[($ib<<12)+$core[2175]] = 04052; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004052] = 03272; $code[004052] = *I04052; sub I04052 { $core[004072] = $lac & 07777; $lac &= 010000; $code[004072] = *emul8; goto &fetch; }
$core[004053] = 04776; $code[004053] = *I04053; sub I04053 { $core[($ib<<12)+$core[2174]] = 04054; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004054] = 03274; $code[004054] = *I04054; sub I04054 { $core[004074] = $lac & 07777; $lac &= 010000; $code[004074] = *emul8; goto &fetch; }
$core[004055] = 04776; $code[004055] = *I04055; sub I04055 { $core[($ib<<12)+$core[2174]] = 04056; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004056] = 03276; $code[004056] = *I04056; sub I04056 { $core[004076] = $lac & 07777; $lac &= 010000; $code[004076] = *emul8; goto &fetch; }
$core[004057] = 04776; $code[004057] = *I04057; sub I04057 { $core[($ib<<12)+$core[2174]] = 04060; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004060] = 03300; $code[004060] = *I04060; sub I04060 { $core[004100] = $lac & 07777; $lac &= 010000; $code[004100] = *emul8; goto &fetch; }
$core[004061] = 05644; $code[004061] = *I04061; sub I04061 { $pc = ($ib<<12)+$core[2084]; $inh = 0; goto &fetch; }
$core[004062] = 00000; $code[004062] = *P04062; sub P04062 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004063] = 07200; $code[004063] = *I04063; sub I04063 { $lac &= 010000; goto &fetch; }
$core[004064] = 01104; $code[004064] = *I04064; sub I04064 { $lac += $core[000104]; goto &fetch; }
$core[004065] = 07425; $code[004065] = *I04065; sub I04065 { &emul8; goto &fetch; }
$core[004066] = 00000; $code[004066] = *D04066; sub D04066 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004067] = 07407; $code[004067] = *I04067; sub I04067 { &emul8; goto &fetch; }
$core[004070] = 00000; $code[004070] = *D04070; sub D04070 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004071] = 07405; $code[004071] = *I04071; sub I04071 { &emul8; goto &fetch; }
$core[004072] = 00000; $code[004072] = *D04072; sub D04072 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004073] = 07407; $code[004073] = *I04073; sub I04073 { &emul8; goto &fetch; }
$core[004074] = 00000; $code[004074] = *D04074; sub D04074 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004075] = 07405; $code[004075] = *I04075; sub I04075 { &emul8; goto &fetch; }
$core[004076] = 00000; $code[004076] = *D04076; sub D04076 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004077] = 07407; $code[004077] = *I04077; sub I04077 { &emul8; goto &fetch; }
$core[004100] = 00000; $code[004100] = *D04100; sub D04100 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004101] = 05662; $code[004101] = *I04101; sub I04101 { $pc = ($ib<<12)+$core[2098]; $inh = 0; goto &fetch; }
$core[004102] = 00000; $code[004102] = *P04102; sub P04102 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004103] = 04777; $code[004103] = *I04103; sub I04103 { $core[($ib<<12)+$core[2175]] = 04104; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004104] = 03330; $code[004104] = *I04104; sub I04104 { $core[004130] = $lac & 07777; $lac &= 010000; $code[004130] = *emul8; goto &fetch; }
$core[004105] = 04777; $code[004105] = *I04105; sub I04105 { $core[($ib<<12)+$core[2175]] = 04106; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004106] = 03332; $code[004106] = *I04106; sub I04106 { $core[004132] = $lac & 07777; $lac &= 010000; $code[004132] = *emul8; goto &fetch; }
$core[004107] = 04777; $code[004107] = *I04107; sub I04107 { $core[($ib<<12)+$core[2175]] = 04110; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004110] = 03334; $code[004110] = *I04110; sub I04110 { $core[004134] = $lac & 07777; $lac &= 010000; $code[004134] = *emul8; goto &fetch; }
$core[004111] = 04776; $code[004111] = *I04111; sub I04111 { $core[($ib<<12)+$core[2174]] = 04112; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004112] = 03336; $code[004112] = *I04112; sub I04112 { $core[004136] = $lac & 07777; $lac &= 010000; $code[004136] = *emul8; goto &fetch; }
$core[004113] = 04776; $code[004113] = *I04113; sub I04113 { $core[($ib<<12)+$core[2174]] = 04114; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004114] = 03340; $code[004114] = *I04114; sub I04114 { $core[004140] = $lac & 07777; $lac &= 010000; $code[004140] = *emul8; goto &fetch; }
$core[004115] = 04776; $code[004115] = *I04115; sub I04115 { $core[($ib<<12)+$core[2174]] = 04116; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004116] = 03342; $code[004116] = *I04116; sub I04116 { $core[004142] = $lac & 07777; $lac &= 010000; $code[004142] = *emul8; goto &fetch; }
$core[004117] = 04776; $code[004117] = *I04117; sub I04117 { $core[($ib<<12)+$core[2174]] = 04120; $pc = ($ib<<12)+$core[2174]+1; $code[($ib<<12)+$core[2174]] = *emul8; $inh = 0; goto &fetch; }
$core[004120] = 03344; $code[004120] = *I04120; sub I04120 { $core[004144] = $lac & 07777; $lac &= 010000; $code[004144] = *emul8; goto &fetch; }
$core[004121] = 04777; $code[004121] = *I04121; sub I04121 { $core[($ib<<12)+$core[2175]] = 04122; $pc = ($ib<<12)+$core[2175]+1; $code[($ib<<12)+$core[2175]] = *emul8; $inh = 0; goto &fetch; }
$core[004122] = 03346; $code[004122] = *I04122; sub I04122 { $core[004146] = $lac & 07777; $lac &= 010000; $code[004146] = *emul8; goto &fetch; }
$core[004123] = 05702; $code[004123] = *I04123; sub I04123 { $pc = ($ib<<12)+$core[2114]; $inh = 0; goto &fetch; }
$core[004124] = 00000; $code[004124] = *P04124; sub P04124 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004125] = 07200; $code[004125] = *I04125; sub I04125 { $lac &= 010000; goto &fetch; }
$core[004126] = 01104; $code[004126] = *I04126; sub I04126 { $lac += $core[000104]; goto &fetch; }
$core[004127] = 07425; $code[004127] = *I04127; sub I04127 { &emul8; goto &fetch; }
$core[004130] = 00000; $code[004130] = *D04130; sub D04130 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004131] = 07407; $code[004131] = *I04131; sub I04131 { &emul8; goto &fetch; }
$core[004132] = 00000; $code[004132] = *D04132; sub D04132 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004133] = 07405; $code[004133] = *I04133; sub I04133 { &emul8; goto &fetch; }
$core[004134] = 00000; $code[004134] = *D04134; sub D04134 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004135] = 07407; $code[004135] = *I04135; sub I04135 { &emul8; goto &fetch; }
$core[004136] = 00000; $code[004136] = *D04136; sub D04136 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004137] = 07405; $code[004137] = *I04137; sub I04137 { &emul8; goto &fetch; }
$core[004140] = 00000; $code[004140] = *D04140; sub D04140 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004141] = 07407; $code[004141] = *I04141; sub I04141 { &emul8; goto &fetch; }
$core[004142] = 00000; $code[004142] = *D04142; sub D04142 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004143] = 07405; $code[004143] = *I04143; sub I04143 { &emul8; goto &fetch; }
$core[004144] = 00000; $code[004144] = *D04144; sub D04144 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004145] = 07407; $code[004145] = *I04145; sub I04145 { &emul8; goto &fetch; }
$core[004146] = 00000; $code[004146] = *D04146; sub D04146 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004147] = 05724; $code[004147] = *I04147; sub I04147 { $pc = ($ib<<12)+$core[2132]; $inh = 0; goto &fetch; }
$core[004150] = 00000; $code[004150] = *S04150; sub S04150 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004151] = 04424; $code[004151] = *I04151; sub I04151 { $core[($ib<<12)+$core[20]] = 04152; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004152] = 04167; $code[004152] = *I04152; sub I04152 { $core[000167] = 04153; $pc = 000167+1; $code[000167] = *emul8; $inh = 0; goto &fetch; }
$core[004153] = 05210; $code[004153] = *I04153; sub I04153 { $pc = 004010; $inh = 0; goto &fetch; }
$core[004154] = 01071; $code[004154] = *I04154; sub I04154 { $lac += $core[000071]; goto &fetch; }
$core[004155] = 03370; $code[004155] = *I04155; sub I04155 { $core[004170] = $lac & 07777; $lac &= 010000; $code[004170] = *emul8; goto &fetch; }
$core[004156] = 04427; $code[004156] = *L04156; sub L04156 { $core[($ib<<12)+$core[23]] = 04157; $pc = ($ib<<12)+$core[23]+1; $code[($ib<<12)+$core[23]] = *emul8; $inh = 0; goto &fetch; }
$core[004157] = 07450; $code[004157] = *I04157; sub I04157 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004160] = 05356; $code[004160] = *I04160; sub I04160 { $pc = 004156; $inh = 0; goto &fetch; }
$core[004161] = 03770; $code[004161] = *I04161; sub I04161 { $core[($df<<12)+$core[2168]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2168]] = *emul8; goto &fetch; }
$core[004162] = 02370; $code[004162] = *I04162; sub I04162 { if (++$core[004170] == 010000) { $core[004170] = 0; $pc++; }$code[004170] = *emul8; goto &fetch; }
$core[004163] = 02367; $code[004163] = *I04163; sub I04163 { if (++$core[004167] == 010000) { $core[004167] = 0; $pc++; }$code[004167] = *emul8; goto &fetch; }
$core[004164] = 05356; $code[004164] = *I04164; sub I04164 { $pc = 004156; $inh = 0; goto &fetch; }
$core[004165] = 02135; $code[004165] = *I04165; sub I04165 { if (++$core[000135] == 010000) { $core[000135] = 0; $pc++; }$code[000135] = *emul8; goto &fetch; }
$core[004166] = 05750; $code[004166] = *I04166; sub I04166 { $pc = ($ib<<12)+$core[2152]; $inh = 0; goto &fetch; }
$core[004167] = 00000; $code[004167] = *D04167; sub D04167 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004170] = 00000; $code[004170] = *P04170; sub P04170 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004176] = 01150; $code[004176] = *P04176; sub P04176 { $lac += $core[000150]; goto &fetch; }
$core[004177] = 01161; $code[004177] = *P04177; sub P04177 { $lac += $core[000161]; goto &fetch; }
$core[004200] = 00000; $code[004200] = *S04200; sub S04200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004201] = 03106; $code[004201] = *I04201; sub I04201 { $core[000106] = $lac & 07777; $lac &= 010000; $code[000106] = *emul8; goto &fetch; }
$core[004202] = 04432; $code[004202] = *I04202; sub I04202 { $core[($ib<<12)+$core[26]] = 04203; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004203] = 00106; $code[004203] = *I04203; sub I04203 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[004204] = 00107; $code[004204] = *I04204; sub I04204 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[004205] = 07752; $code[004205] = *I04205; sub I04205 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[004206] = 01600; $code[004206] = *I04206; sub I04206 { $lac += $core[($df<<12)+$core[2176]]; goto &fetch; }
$core[004207] = 03323; $code[004207] = *I04207; sub I04207 { $core[004323] = $lac & 07777; $lac &= 010000; $code[004323] = *emul8; goto &fetch; }
$core[004210] = 02200; $code[004210] = *I04210; sub I04210 { if (++$core[004200] == 010000) { $core[004200] = 0; $pc++; }$code[004200] = *emul8; goto &fetch; }
$core[004211] = 01600; $code[004211] = *I04211; sub I04211 { $lac += $core[($df<<12)+$core[2176]]; goto &fetch; }
$core[004212] = 03153; $code[004212] = *I04212; sub I04212 { $core[000153] = $lac & 07777; $lac &= 010000; $code[000153] = *emul8; goto &fetch; }
$core[004213] = 02200; $code[004213] = *I04213; sub I04213 { if (++$core[004200] == 010000) { $core[004200] = 0; $pc++; }$code[004200] = *emul8; goto &fetch; }
$core[004214] = 01600; $code[004214] = *I04214; sub I04214 { $lac += $core[($df<<12)+$core[2176]]; goto &fetch; }
$core[004215] = 03114; $code[004215] = *I04215; sub I04215 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[004216] = 01514; $code[004216] = *I04216; sub I04216 { $lac += $core[($df<<12)+$core[76]]; goto &fetch; }
$core[004217] = 03114; $code[004217] = *I04217; sub I04217 { $core[000114] = $lac & 07777; $lac &= 010000; $code[000114] = *emul8; goto &fetch; }
$core[004220] = 02200; $code[004220] = *I04220; sub I04220 { if (++$core[004200] == 010000) { $core[004200] = 0; $pc++; }$code[004200] = *emul8; goto &fetch; }
$core[004221] = 01600; $code[004221] = *I04221; sub I04221 { $lac += $core[($df<<12)+$core[2176]]; goto &fetch; }
$core[004222] = 03262; $code[004222] = *I04222; sub I04222 { $core[004262] = $lac & 07777; $lac &= 010000; $code[004262] = *emul8; goto &fetch; }
$core[004223] = 02200; $code[004223] = *I04223; sub I04223 { if (++$core[004200] == 010000) { $core[004200] = 0; $pc++; }$code[004200] = *emul8; goto &fetch; }
$core[004224] = 04723; $code[004224] = *I04224; sub I04224 { $core[($ib<<12)+$core[2259]] = 04225; $pc = ($ib<<12)+$core[2259]+1; $code[($ib<<12)+$core[2259]] = *emul8; $inh = 0; goto &fetch; }
$core[004225] = 04227; $code[004225] = *L04225; sub L04225 { $core[004227] = 04226; $pc = 004227+1; $code[004227] = *emul8; $inh = 0; goto &fetch; }
$core[004226] = 05237; $code[004226] = *I04226; sub I04226 { $pc = 004237; $inh = 0; goto &fetch; }
$core[004227] = 00000; $code[004227] = *S04227; sub S04227 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004230] = 04553; $code[004230] = *I04230; sub I04230 { $core[($ib<<12)+$core[107]] = 04231; $pc = ($ib<<12)+$core[107]+1; $code[($ib<<12)+$core[107]] = *emul8; $inh = 0; goto &fetch; }
$core[004231] = 03117; $code[004231] = *I04231; sub I04231 { $core[000117] = $lac & 07777; $lac &= 010000; $code[000117] = *emul8; goto &fetch; }
$core[004232] = 07010; $code[004232] = *I04232; sub I04232 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004233] = 03116; $code[004233] = *I04233; sub I04233 { $core[000116] = $lac & 07777; $lac &= 010000; $code[000116] = *emul8; goto &fetch; }
$core[004234] = 07501; $code[004234] = *I04234; sub I04234 { &emul8; goto &fetch; }
$core[004235] = 03120; $code[004235] = *I04235; sub I04235 { $core[000120] = $lac & 07777; $lac &= 010000; $code[000120] = *emul8; goto &fetch; }
$core[004236] = 05627; $code[004236] = *I04236; sub I04236 { $pc = ($ib<<12)+$core[2199]; $inh = 0; goto &fetch; }
$core[004237] = 04433; $code[004237] = *L04237; sub L04237 { $core[($ib<<12)+$core[27]] = 04240; $pc = ($ib<<12)+$core[27]+1; $code[($ib<<12)+$core[27]] = *emul8; $inh = 0; goto &fetch; }
$core[004240] = 07775; $code[004240] = *I04240; sub I04240 { &emul8; goto &fetch; }
$core[004241] = 05245; $code[004241] = *I04241; sub I04241 { $pc = 004245; $inh = 0; goto &fetch; }
$core[004242] = 04434; $code[004242] = *L04242; sub L04242 { $core[($ib<<12)+$core[28]] = 04243; $pc = ($ib<<12)+$core[28]+1; $code[($ib<<12)+$core[28]] = *emul8; $inh = 0; goto &fetch; }
$core[004243] = 05225; $code[004243] = *P04243; sub P04243 { $pc = 004225; $inh = 0; goto &fetch; }
$core[004244] = 05600; $code[004244] = *I04244; sub I04244 { $pc = ($ib<<12)+$core[2176]; $inh = 0; goto &fetch; }
$core[004245] = 04435; $code[004245] = *L04245; sub L04245 { $core[($ib<<12)+$core[29]] = 04246; $pc = ($ib<<12)+$core[29]+1; $code[($ib<<12)+$core[29]] = *emul8; $inh = 0; goto &fetch; }
$core[004246] = 05253; $code[004246] = *I04246; sub I04246 { $pc = 004253; $inh = 0; goto &fetch; }
$core[004247] = 04324; $code[004247] = *I04247; sub I04247 { $core[004324] = 04250; $pc = 004324+1; $code[004324] = *emul8; $inh = 0; goto &fetch; }
$core[004250] = 04435; $code[004250] = *I04250; sub I04250 { $core[($ib<<12)+$core[29]] = 04251; $pc = ($ib<<12)+$core[29]+1; $code[($ib<<12)+$core[29]] = *emul8; $inh = 0; goto &fetch; }
$core[004251] = 07410; $code[004251] = *I04251; sub I04251 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004252] = 05242; $code[004252] = *I04252; sub I04252 { $pc = 004242; $inh = 0; goto &fetch; }
$core[004253] = 04446; $code[004253] = *L04253; sub L04253 { $core[($ib<<12)+$core[38]] = 04254; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[004254] = 07776; $code[004254] = *I04254; sub I04254 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004255] = 04426; $code[004255] = *I04255; sub I04255 { $core[($ib<<12)+$core[22]] = 04256; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[004256] = 00643; $code[004256] = *I04256; sub I04256 { $lac &= (010000|$core[($df<<12)+$core[2211]]); goto &fetch; }
$core[004257] = 04445; $code[004257] = *I04257; sub I04257 { $core[($ib<<12)+$core[37]] = 04260; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[004260] = 07776; $code[004260] = *I04260; sub I04260 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004261] = 04426; $code[004261] = *I04261; sub I04261 { $core[($ib<<12)+$core[22]] = 04262; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[004262] = 00000; $code[004262] = *D04262; sub D04262 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004263] = 04446; $code[004263] = *I04263; sub I04263 { $core[($ib<<12)+$core[38]] = 04264; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[004264] = 07776; $code[004264] = *I04264; sub I04264 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004265] = 04331; $code[004265] = *I04265; sub I04265 { $core[004331] = 04266; $pc = 004331+1; $code[004331] = *emul8; $inh = 0; goto &fetch; }
$core[004266] = 00104; $code[004266] = *I04266; sub I04266 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[004267] = 00762; $code[004267] = *I04267; sub I04267 { $lac &= (010000|$core[($df<<12)+$core[2290]]); goto &fetch; }
$core[004270] = 04331; $code[004270] = *I04270; sub I04270 { $core[004331] = 04271; $pc = 004331+1; $code[004331] = *emul8; $inh = 0; goto &fetch; }
$core[004271] = 00105; $code[004271] = *I04271; sub I04271 { $lac &= (010000|$core[000105]); goto &fetch; }
$core[004272] = 00767; $code[004272] = *I04272; sub I04272 { $lac &= (010000|$core[($df<<12)+$core[2295]]); goto &fetch; }
$core[004273] = 04426; $code[004273] = *I04273; sub I04273 { $core[($ib<<12)+$core[22]] = 04274; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[004274] = 00760; $code[004274] = *I04274; sub I04274 { $lac &= (010000|$core[($df<<12)+$core[2288]]); goto &fetch; }
$core[004275] = 04475; $code[004275] = *I04275; sub I04275 { $core[($ib<<12)+$core[61]] = 04276; $pc = ($ib<<12)+$core[61]+1; $code[($ib<<12)+$core[61]] = *emul8; $inh = 0; goto &fetch; }
$core[004276] = 04436; $code[004276] = *I04276; sub I04276 { $core[($ib<<12)+$core[30]] = 04277; $pc = ($ib<<12)+$core[30]+1; $code[($ib<<12)+$core[30]] = *emul8; $inh = 0; goto &fetch; }
$core[004277] = 04324; $code[004277] = *I04277; sub I04277 { $core[004324] = 04300; $pc = 004324+1; $code[004324] = *emul8; $inh = 0; goto &fetch; }
$core[004300] = 04437; $code[004300] = *I04300; sub I04300 { $core[($ib<<12)+$core[31]] = 04301; $pc = ($ib<<12)+$core[31]+1; $code[($ib<<12)+$core[31]] = *emul8; $inh = 0; goto &fetch; }
$core[004301] = 05317; $code[004301] = *I04301; sub I04301 { $pc = 004317; $inh = 0; goto &fetch; }
$core[004302] = 04424; $code[004302] = *I04302; sub I04302 { $core[($ib<<12)+$core[20]] = 04303; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004303] = 00141; $code[004303] = *I04303; sub I04303 { $lac &= (010000|$core[000141]); goto &fetch; }
$core[004304] = 07634; $code[004304] = *I04304; sub I04304 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004305] = 03140; $code[004305] = *D04305; sub D04305 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[004306] = 04227; $code[004306] = *L04306; sub L04306 { $core[004227] = 04307; $pc = 004227+1; $code[004227] = *emul8; $inh = 0; goto &fetch; }
$core[004307] = 04433; $code[004307] = *I04307; sub I04307 { $core[($ib<<12)+$core[27]] = 04310; $pc = ($ib<<12)+$core[27]+1; $code[($ib<<12)+$core[27]] = *emul8; $inh = 0; goto &fetch; }
$core[004310] = 07775; $code[004310] = *I04310; sub I04310 { &emul8; goto &fetch; }
$core[004311] = 02140; $code[004311] = *I04311; sub I04311 { if (++$core[000140] == 010000) { $core[000140] = 0; $pc++; }$code[000140] = *emul8; goto &fetch; }
$core[004312] = 02141; $code[004312] = *I04312; sub I04312 { if (++$core[000141] == 010000) { $core[000141] = 0; $pc++; }$code[000141] = *emul8; goto &fetch; }
$core[004313] = 05306; $code[004313] = *I04313; sub I04313 { $pc = 004306; $inh = 0; goto &fetch; }
$core[004314] = 04451; $code[004314] = *I04314; sub I04314 { $core[($ib<<12)+$core[41]] = 04315; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[004315] = 04436; $code[004315] = *I04315; sub I04315 { $core[($ib<<12)+$core[30]] = 04316; $pc = ($ib<<12)+$core[30]+1; $code[($ib<<12)+$core[30]] = *emul8; $inh = 0; goto &fetch; }
$core[004316] = 04324; $code[004316] = *I04316; sub I04316 { $core[004324] = 04317; $pc = 004324+1; $code[004324] = *emul8; $inh = 0; goto &fetch; }
$core[004317] = 04440; $code[004317] = *L04317; sub L04317 { $core[($ib<<12)+$core[32]] = 04320; $pc = ($ib<<12)+$core[32]+1; $code[($ib<<12)+$core[32]] = *emul8; $inh = 0; goto &fetch; }
$core[004320] = 05242; $code[004320] = *I04320; sub I04320 { $pc = 004242; $inh = 0; goto &fetch; }
$core[004321] = 04553; $code[004321] = *L04321; sub L04321 { $core[($ib<<12)+$core[107]] = 04322; $pc = ($ib<<12)+$core[107]+1; $code[($ib<<12)+$core[107]] = *emul8; $inh = 0; goto &fetch; }
$core[004322] = 05321; $code[004322] = *I04322; sub I04322 { $pc = 004321; $inh = 0; goto &fetch; }
$core[004323] = 00000; $code[004323] = *P04323; sub P04323 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004324] = 00000; $code[004324] = *S04324; sub S04324 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004325] = 07200; $code[004325] = *I04325; sub I04325 { $lac &= 010000; goto &fetch; }
$core[004326] = 01102; $code[004326] = *I04326; sub I04326 { $lac += $core[000102]; goto &fetch; }
$core[004327] = 07402; $code[004327] = *I04327; sub I04327 { $hlt = 1; goto &fetch; }
$core[004330] = 05724; $code[004330] = *I04330; sub I04330 { $pc = ($ib<<12)+$core[2260]; $inh = 0; goto &fetch; }
$core[004331] = 00000; $code[004331] = *S04331; sub S04331 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004332] = 01731; $code[004332] = *I04332; sub I04332 { $lac += $core[($df<<12)+$core[2265]]; goto &fetch; }
$core[004333] = 03367; $code[004333] = *I04333; sub I04333 { $core[004367] = $lac & 07777; $lac &= 010000; $code[004367] = *emul8; goto &fetch; }
$core[004334] = 02331; $code[004334] = *I04334; sub I04334 { if (++$core[004331] == 010000) { $core[004331] = 0; $pc++; }$code[004331] = *emul8; goto &fetch; }
$core[004335] = 01731; $code[004335] = *I04335; sub I04335 { $lac += $core[($df<<12)+$core[2265]]; goto &fetch; }
$core[004336] = 03370; $code[004336] = *I04336; sub I04336 { $core[004370] = $lac & 07777; $lac &= 010000; $code[004370] = *emul8; goto &fetch; }
$core[004337] = 02331; $code[004337] = *I04337; sub I04337 { if (++$core[004331] == 010000) { $core[004331] = 0; $pc++; }$code[004331] = *emul8; goto &fetch; }
$core[004340] = 01156; $code[004340] = *I04340; sub I04340 { $lac += $core[000156]; goto &fetch; }
$core[004341] = 00767; $code[004341] = *I04341; sub I04341 { $lac &= (010000|$core[($df<<12)+$core[2295]]); goto &fetch; }
$core[004342] = 07112; $code[004342] = *I04342; sub I04342 { $lac &= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004343] = 07012; $code[004343] = *I04343; sub I04343 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004344] = 07012; $code[004344] = *I04344; sub I04344 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004345] = 04354; $code[004345] = *I04345; sub I04345 { $core[004354] = 04346; $pc = 004354+1; $code[004354] = *emul8; $inh = 0; goto &fetch; }
$core[004346] = 02370; $code[004346] = *I04346; sub I04346 { if (++$core[004370] == 010000) { $core[004370] = 0; $pc++; }$code[004370] = *emul8; goto &fetch; }
$core[004347] = 01156; $code[004347] = *I04347; sub I04347 { $lac += $core[000156]; goto &fetch; }
$core[004350] = 07040; $code[004350] = *I04350; sub I04350 { $lac ^= 07777; goto &fetch; }
$core[004351] = 00767; $code[004351] = *I04351; sub I04351 { $lac &= (010000|$core[($df<<12)+$core[2295]]); goto &fetch; }
$core[004352] = 04354; $code[004352] = *I04352; sub I04352 { $core[004354] = 04353; $pc = 004354+1; $code[004354] = *emul8; $inh = 0; goto &fetch; }
$core[004353] = 05731; $code[004353] = *I04353; sub I04353 { $pc = ($ib<<12)+$core[2265]; $inh = 0; goto &fetch; }
$core[004354] = 00000; $code[004354] = *S04354; sub S04354 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004355] = 03371; $code[004355] = *I04355; sub I04355 { $core[004371] = $lac & 07777; $lac &= 010000; $code[004371] = *emul8; goto &fetch; }
$core[004356] = 01371; $code[004356] = *I04356; sub I04356 { $lac += $core[004371]; goto &fetch; }
$core[004357] = 07006; $code[004357] = *I04357; sub I04357 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004360] = 07004; $code[004360] = *P04360; sub P04360 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004361] = 00154; $code[004361] = *I04361; sub I04361 { $lac &= (010000|$core[000154]); goto &fetch; }
$core[004362] = 01371; $code[004362] = *P04362; sub P04362 { $lac += $core[004371]; goto &fetch; }
$core[004363] = 00154; $code[004363] = *I04363; sub I04363 { $lac &= (010000|$core[000154]); goto &fetch; }
$core[004364] = 01155; $code[004364] = *I04364; sub I04364 { $lac += $core[000155]; goto &fetch; }
$core[004365] = 03770; $code[004365] = *I04365; sub I04365 { $core[($df<<12)+$core[2296]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2296]] = *emul8; goto &fetch; }
$core[004366] = 05754; $code[004366] = *I04366; sub I04366 { $pc = ($ib<<12)+$core[2284]; $inh = 0; goto &fetch; }
$core[004367] = 00000; $code[004367] = *P04367; sub P04367 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004370] = 00000; $code[004370] = *P04370; sub P04370 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004371] = 00000; $code[004371] = *D04371; sub D04371 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004372] = 00007; $code[004372] = *I04372; sub I04372 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[004373] = 01305; $code[004373] = *I04373; sub I04373 { $lac += $core[004305]; goto &fetch; }
$core[004374] = 07040; $code[004374] = *I04374; sub I04374 { $lac ^= 07777; goto &fetch; }
$core[004375] = 06200; $code[004375] = *I04375; sub I04375 { &emul8; goto &fetch; }
$core[004376] = 00100; $code[004376] = *I04376; sub I04376 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[004400] = 00000; $code[004400] = *P04400; sub P04400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004401] = 04405; $code[004401] = *I04401; sub I04401 { $core[($ib<<12)+$core[5]] = 04402; $pc = ($ib<<12)+$core[5]+1; $code[($ib<<12)+$core[5]] = *emul8; $inh = 0; goto &fetch; }
$core[004402] = 04430; $code[004402] = *I04402; sub I04402 { $core[($ib<<12)+$core[24]] = 04403; $pc = ($ib<<12)+$core[24]+1; $code[($ib<<12)+$core[24]] = *emul8; $inh = 0; goto &fetch; }
$core[004403] = 03042; $code[004403] = *I04403; sub I04403 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[004404] = 07711; $code[004404] = *I04404; sub I04404 { &emul8; goto &fetch; }
$core[004405] = 00001; $code[004405] = *I04405; sub I04405 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[004406] = 04461; $code[004406] = *I04406; sub I04406 { $core[($ib<<12)+$core[49]] = 04407; $pc = ($ib<<12)+$core[49]+1; $code[($ib<<12)+$core[49]] = *emul8; $inh = 0; goto &fetch; }
$core[004407] = 04424; $code[004407] = *I04407; sub I04407 { $core[($ib<<12)+$core[20]] = 04410; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004410] = 04457; $code[004410] = *L04410; sub L04410 { $core[($ib<<12)+$core[47]] = 04411; $pc = ($ib<<12)+$core[47]+1; $code[($ib<<12)+$core[47]] = *emul8; $inh = 0; goto &fetch; }
$core[004411] = 05210; $code[004411] = *I04411; sub I04411 { $pc = 004410; $inh = 0; goto &fetch; }
$core[004412] = 01071; $code[004412] = *I04412; sub I04412 { $lac += $core[000071]; goto &fetch; }
$core[004413] = 03260; $code[004413] = *I04413; sub I04413 { $core[004460] = $lac & 07777; $lac &= 010000; $code[004460] = *emul8; goto &fetch; }
$core[004414] = 04427; $code[004414] = *L04414; sub L04414 { $core[($ib<<12)+$core[23]] = 04415; $pc = ($ib<<12)+$core[23]+1; $code[($ib<<12)+$core[23]] = *emul8; $inh = 0; goto &fetch; }
$core[004415] = 03660; $code[004415] = *I04415; sub I04415 { $core[($df<<12)+$core[2352]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2352]] = *emul8; goto &fetch; }
$core[004416] = 02260; $code[004416] = *I04416; sub I04416 { if (++$core[004460] == 010000) { $core[004460] = 0; $pc++; }$code[004460] = *emul8; goto &fetch; }
$core[004417] = 02257; $code[004417] = *I04417; sub I04417 { if (++$core[004457] == 010000) { $core[004457] = 0; $pc++; }$code[004457] = *emul8; goto &fetch; }
$core[004420] = 05214; $code[004420] = *I04420; sub I04420 { $pc = 004414; $inh = 0; goto &fetch; }
$core[004421] = 03106; $code[004421] = *I04421; sub I04421 { $core[000106] = $lac & 07777; $lac &= 010000; $code[000106] = *emul8; goto &fetch; }
$core[004422] = 04432; $code[004422] = *I04422; sub I04422 { $core[($ib<<12)+$core[26]] = 04423; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004423] = 00106; $code[004423] = *I04423; sub I04423 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[004424] = 00107; $code[004424] = *I04424; sub I04424 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[004425] = 07751; $code[004425] = *I04425; sub I04425 { &emul8; goto &fetch; }
$core[004426] = 04424; $code[004426] = *D04426; sub D04426 { $core[($ib<<12)+$core[20]] = 04427; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004427] = 04457; $code[004427] = *I04427; sub I04427 { $core[($ib<<12)+$core[47]] = 04430; $pc = ($ib<<12)+$core[47]+1; $code[($ib<<12)+$core[47]] = *emul8; $inh = 0; goto &fetch; }
$core[004430] = 07242; $code[004430] = *I04430; sub I04430 { $lac &= 010000; $lac ^= 07777; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[004431] = 01071; $code[004431] = *I04431; sub I04431 { $lac += $core[000071]; goto &fetch; }
$core[004432] = 03234; $code[004432] = *D04432; sub D04432 { $core[004434] = $lac & 07777; $lac &= 010000; $code[004434] = *emul8; goto &fetch; }
$core[004433] = 04432; $code[004433] = *L04433; sub L04433 { $core[($ib<<12)+$core[26]] = 04434; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004434] = 00000; $code[004434] = *D04434; sub D04434 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004435] = 00110; $code[004435] = *I04435; sub I04435 { $lac &= (010000|$core[000110]); goto &fetch; }
$core[004436] = 07776; $code[004436] = *I04436; sub I04436 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004437] = 04441; $code[004437] = *I04437; sub I04437 { $core[($ib<<12)+$core[33]] = 04440; $pc = ($ib<<12)+$core[33]+1; $code[($ib<<12)+$core[33]] = *emul8; $inh = 0; goto &fetch; }
$core[004440] = 01234; $code[004440] = *I04440; sub I04440 { $lac += $core[004434]; goto &fetch; }
$core[004441] = 01147; $code[004441] = *I04441; sub I04441 { $lac += $core[000147]; goto &fetch; }
$core[004442] = 03245; $code[004442] = *I04442; sub I04442 { $core[004445] = $lac & 07777; $lac &= 010000; $code[004445] = *emul8; goto &fetch; }
$core[004443] = 04432; $code[004443] = *I04443; sub I04443 { $core[($ib<<12)+$core[26]] = 04444; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004444] = 00127; $code[004444] = *I04444; sub I04444 { $lac &= (010000|$core[000127]); goto &fetch; }
$core[004445] = 00000; $code[004445] = *D04445; sub D04445 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004446] = 07776; $code[004446] = *D04446; sub D04446 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004447] = 01245; $code[004447] = *I04447; sub I04447 { $lac += $core[004445]; goto &fetch; }
$core[004450] = 01147; $code[004450] = *I04450; sub I04450 { $lac += $core[000147]; goto &fetch; }
$core[004451] = 03234; $code[004451] = *I04451; sub I04451 { $core[004434] = $lac & 07777; $lac &= 010000; $code[004434] = *emul8; goto &fetch; }
$core[004452] = 02257; $code[004452] = *I04452; sub I04452 { if (++$core[004457] == 010000) { $core[004457] = 0; $pc++; }$code[004457] = *emul8; goto &fetch; }
$core[004453] = 05233; $code[004453] = *D04453; sub D04453 { $pc = 004433; $inh = 0; goto &fetch; }
$core[004454] = 04430; $code[004454] = *I04454; sub I04454 { $core[($ib<<12)+$core[24]] = 04455; $pc = ($ib<<12)+$core[24]+1; $code[($ib<<12)+$core[24]] = *emul8; $inh = 0; goto &fetch; }
$core[004455] = 05000; $code[004455] = *D04455; sub D04455 { $pc = 000000; $inh = 0; goto &fetch; }
$core[004456] = 07242; $code[004456] = *I04456; sub I04456 { $lac &= 010000; $lac ^= 07777; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[004457] = 00000; $code[004457] = *D04457; sub D04457 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004460] = 00000; $code[004460] = *P04460; sub P04460 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004461] = 00002; $code[004461] = *I04461; sub I04461 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[004462] = 04466; $code[004462] = *I04462; sub I04462 { $core[($ib<<12)+$core[54]] = 04463; $pc = ($ib<<12)+$core[54]+1; $code[($ib<<12)+$core[54]] = *emul8; $inh = 0; goto &fetch; }
$core[004463] = 04431; $code[004463] = *I04463; sub I04463 { $core[($ib<<12)+$core[25]] = 04464; $pc = ($ib<<12)+$core[25]+1; $code[($ib<<12)+$core[25]] = *emul8; $inh = 0; goto &fetch; }
$core[004464] = 03376; $code[004464] = *I04464; sub I04464 { $core[004576] = $lac & 07777; $lac &= 010000; $code[004576] = *emul8; goto &fetch; }
$core[004465] = 07730; $code[004465] = *I04465; sub I04465 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004466] = 00003; $code[004466] = *I04466; sub I04466 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[004467] = 04542; $code[004467] = *I04467; sub I04467 { $core[($ib<<12)+$core[98]] = 04470; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[004470] = 04424; $code[004470] = *I04470; sub I04470 { $core[($ib<<12)+$core[20]] = 04471; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004471] = 04540; $code[004471] = *I04471; sub I04471 { $core[($ib<<12)+$core[96]] = 04472; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[004472] = 05210; $code[004472] = *I04472; sub I04472 { $pc = 004410; $inh = 0; goto &fetch; }
$core[004473] = 01071; $code[004473] = *I04473; sub I04473 { $lac += $core[000071]; goto &fetch; }
$core[004474] = 03341; $code[004474] = *I04474; sub I04474 { $core[004541] = $lac & 07777; $lac &= 010000; $code[004541] = *emul8; goto &fetch; }
$core[004475] = 04427; $code[004475] = *L04475; sub L04475 { $core[($ib<<12)+$core[23]] = 04476; $pc = ($ib<<12)+$core[23]+1; $code[($ib<<12)+$core[23]] = *emul8; $inh = 0; goto &fetch; }
$core[004476] = 03741; $code[004476] = *I04476; sub I04476 { $core[($df<<12)+$core[2401]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2401]] = *emul8; goto &fetch; }
$core[004477] = 02341; $code[004477] = *I04477; sub I04477 { if (++$core[004541] == 010000) { $core[004541] = 0; $pc++; }$code[004541] = *emul8; goto &fetch; }
$core[004500] = 02340; $code[004500] = *I04500; sub I04500 { if (++$core[004540] == 010000) { $core[004540] = 0; $pc++; }$code[004540] = *emul8; goto &fetch; }
$core[004501] = 05275; $code[004501] = *I04501; sub I04501 { $pc = 004475; $inh = 0; goto &fetch; }
$core[004502] = 03106; $code[004502] = *I04502; sub I04502 { $core[000106] = $lac & 07777; $lac &= 010000; $code[000106] = *emul8; goto &fetch; }
$core[004503] = 04432; $code[004503] = *I04503; sub I04503 { $core[($ib<<12)+$core[26]] = 04504; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004504] = 00106; $code[004504] = *I04504; sub I04504 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[004505] = 00107; $code[004505] = *I04505; sub I04505 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[004506] = 07751; $code[004506] = *I04506; sub I04506 { &emul8; goto &fetch; }
$core[004507] = 04424; $code[004507] = *I04507; sub I04507 { $core[($ib<<12)+$core[20]] = 04510; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004510] = 04540; $code[004510] = *I04510; sub I04510 { $core[($ib<<12)+$core[96]] = 04511; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[004511] = 07427; $code[004511] = *I04511; sub I04511 { &emul8; goto &fetch; }
$core[004512] = 01071; $code[004512] = *I04512; sub I04512 { $lac += $core[000071]; goto &fetch; }
$core[004513] = 03315; $code[004513] = *I04513; sub I04513 { $core[004515] = $lac & 07777; $lac &= 010000; $code[004515] = *emul8; goto &fetch; }
$core[004514] = 04432; $code[004514] = *P04514; sub P04514 { $core[($ib<<12)+$core[26]] = 04515; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004515] = 00000; $code[004515] = *D04515; sub D04515 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004516] = 00107; $code[004516] = *I04516; sub I04516 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[004517] = 07775; $code[004517] = *I04517; sub I04517 { &emul8; goto &fetch; }
$core[004520] = 04442; $code[004520] = *I04520; sub I04520 { $core[($ib<<12)+$core[34]] = 04521; $pc = ($ib<<12)+$core[34]+1; $code[($ib<<12)+$core[34]] = *emul8; $inh = 0; goto &fetch; }
$core[004521] = 01315; $code[004521] = *I04521; sub I04521 { $lac += $core[004515]; goto &fetch; }
$core[004522] = 01150; $code[004522] = *I04522; sub I04522 { $lac += $core[000150]; goto &fetch; }
$core[004523] = 03326; $code[004523] = *I04523; sub I04523 { $core[004526] = $lac & 07777; $lac &= 010000; $code[004526] = *emul8; goto &fetch; }
$core[004524] = 04432; $code[004524] = *I04524; sub I04524 { $core[($ib<<12)+$core[26]] = 04525; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004525] = 00126; $code[004525] = *I04525; sub I04525 { $lac &= (010000|$core[000126]); goto &fetch; }
$core[004526] = 00000; $code[004526] = *D04526; sub D04526 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004527] = 07775; $code[004527] = *I04527; sub I04527 { &emul8; goto &fetch; }
$core[004530] = 01326; $code[004530] = *I04530; sub I04530 { $lac += $core[004526]; goto &fetch; }
$core[004531] = 01150; $code[004531] = *I04531; sub I04531 { $lac += $core[000150]; goto &fetch; }
$core[004532] = 03315; $code[004532] = *I04532; sub I04532 { $core[004515] = $lac & 07777; $lac &= 010000; $code[004515] = *emul8; goto &fetch; }
$core[004533] = 02340; $code[004533] = *I04533; sub I04533 { if (++$core[004540] == 010000) { $core[004540] = 0; $pc++; }$code[004540] = *emul8; goto &fetch; }
$core[004534] = 05314; $code[004534] = *I04534; sub I04534 { $pc = 004514; $inh = 0; goto &fetch; }
$core[004535] = 04431; $code[004535] = *I04535; sub I04535 { $core[($ib<<12)+$core[25]] = 04536; $pc = ($ib<<12)+$core[25]+1; $code[($ib<<12)+$core[25]] = *emul8; $inh = 0; goto &fetch; }
$core[004536] = 05000; $code[004536] = *I04536; sub I04536 { $pc = 000000; $inh = 0; goto &fetch; }
$core[004537] = 07427; $code[004537] = *I04537; sub I04537 { &emul8; goto &fetch; }
$core[004540] = 00000; $code[004540] = *D04540; sub D04540 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004541] = 00000; $code[004541] = *P04541; sub P04541 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004542] = 00004; $code[004542] = *I04542; sub I04542 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[004543] = 04600; $code[004543] = *I04543; sub I04543 { $core[($ib<<12)+$core[2304]] = 04544; $pc = ($ib<<12)+$core[2304]+1; $code[($ib<<12)+$core[2304]] = *emul8; $inh = 0; goto &fetch; }
$core[004544] = 04472; $code[004544] = *I04544; sub I04544 { $core[($ib<<12)+$core[58]] = 04545; $pc = ($ib<<12)+$core[58]+1; $code[($ib<<12)+$core[58]] = *emul8; $inh = 0; goto &fetch; }
$core[004545] = 04424; $code[004545] = *I04545; sub I04545 { $core[($ib<<12)+$core[20]] = 04546; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004546] = 00144; $code[004546] = *I04546; sub I04546 { $lac &= (010000|$core[000144]); goto &fetch; }
$core[004547] = 06504; $code[004547] = *I04547; sub I04547 { &emul8; goto &fetch; }
$core[004550] = 01071; $code[004550] = *I04550; sub I04550 { $lac += $core[000071]; goto &fetch; }
$core[004551] = 03353; $code[004551] = *I04551; sub I04551 { $core[004553] = $lac & 07777; $lac &= 010000; $code[004553] = *emul8; goto &fetch; }
$core[004552] = 04432; $code[004552] = *L04552; sub L04552 { $core[($ib<<12)+$core[26]] = 04553; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004553] = 00000; $code[004553] = *D04553; sub D04553 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004554] = 00104; $code[004554] = *I04554; sub I04554 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[004555] = 07776; $code[004555] = *I04555; sub I04555 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004556] = 01353; $code[004556] = *I04556; sub I04556 { $lac += $core[004553]; goto &fetch; }
$core[004557] = 03007; $code[004557] = *I04557; sub I04557 { $core[000007] = $lac & 07777; $lac &= 010000; $code[000007] = *emul8; goto &fetch; }
$core[004560] = 04473; $code[004560] = *D04560; sub D04560 { $core[($ib<<12)+$core[59]] = 04561; $pc = ($ib<<12)+$core[59]+1; $code[($ib<<12)+$core[59]] = *emul8; $inh = 0; goto &fetch; }
$core[004561] = 04000; $code[004561] = *I04561; sub I04561 { $core[000000] = 04562; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[004562] = 04006; $code[004562] = *I04562; sub I04562 { $core[000006] = 04563; $pc = 000006+1; $code[000006] = *emul8; $inh = 0; goto &fetch; }
$core[004563] = 00104; $code[004563] = *I04563; sub I04563 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[004564] = 00714; $code[004564] = *I04564; sub I04564 { $lac &= (010000|$core[($df<<12)+$core[2380]]); goto &fetch; }
$core[004565] = 02353; $code[004565] = *I04565; sub I04565 { if (++$core[004553] == 010000) { $core[004553] = 0; $pc++; }$code[004553] = *emul8; goto &fetch; }
$core[004566] = 02353; $code[004566] = *I04566; sub I04566 { if (++$core[004553] == 010000) { $core[004553] = 0; $pc++; }$code[004553] = *emul8; goto &fetch; }
$core[004567] = 02144; $code[004567] = *I04567; sub I04567 { if (++$core[000144] == 010000) { $core[000144] = 0; $pc++; }$code[000144] = *emul8; goto &fetch; }
$core[004570] = 05352; $code[004570] = *I04570; sub I04570 { $pc = 004552; $inh = 0; goto &fetch; }
$core[004571] = 05422; $code[004571] = *I04571; sub I04571 { $pc = ($ib<<12)+$core[18]; $inh = 0; goto &fetch; }
$core[004572] = 07300; $code[004572] = *L04572; sub L04572 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004573] = 01102; $code[004573] = *I04573; sub I04573 { $lac += $core[000102]; goto &fetch; }
$core[004574] = 07402; $code[004574] = *I04574; sub I04574 { $hlt = 1; goto &fetch; }
$core[004575] = 05777; $code[004575] = *I04575; sub I04575 { $pc = ($ib<<12)+$core[2431]; $inh = 0; goto &fetch; }
$core[004577] = 01360; $code[004577] = *P04577; sub P04577 { $lac += $core[004560]; goto &fetch; }
$core[004600] = 00005; $code[004600] = *I04600; sub I04600 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[004601] = 04633; $code[004601] = *I04601; sub I04601 { $core[($ib<<12)+$core[2459]] = 04602; $pc = ($ib<<12)+$core[2459]+1; $code[($ib<<12)+$core[2459]] = *emul8; $inh = 0; goto &fetch; }
$core[004602] = 07200; $code[004602] = *I04602; sub I04602 { $lac &= 010000; goto &fetch; }
$core[004603] = 01135; $code[004603] = *I04603; sub I04603 { $lac += $core[000135]; goto &fetch; }
$core[004604] = 07650; $code[004604] = *I04604; sub I04604 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004605] = 04472; $code[004605] = *I04605; sub I04605 { $core[($ib<<12)+$core[58]] = 04606; $pc = ($ib<<12)+$core[58]+1; $code[($ib<<12)+$core[58]] = *emul8; $inh = 0; goto &fetch; }
$core[004606] = 04424; $code[004606] = *I04606; sub I04606 { $core[($ib<<12)+$core[20]] = 04607; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004607] = 00144; $code[004607] = *I04607; sub I04607 { $lac &= (010000|$core[000144]); goto &fetch; }
$core[004610] = 06504; $code[004610] = *I04610; sub I04610 { &emul8; goto &fetch; }
$core[004611] = 01071; $code[004611] = *I04611; sub I04611 { $lac += $core[000071]; goto &fetch; }
$core[004612] = 03214; $code[004612] = *I04612; sub I04612 { $core[004614] = $lac & 07777; $lac &= 010000; $code[004614] = *emul8; goto &fetch; }
$core[004613] = 04432; $code[004613] = *L04613; sub L04613 { $core[($ib<<12)+$core[26]] = 04614; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004614] = 00000; $code[004614] = *D04614; sub D04614 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004615] = 00104; $code[004615] = *I04615; sub I04615 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[004616] = 07776; $code[004616] = *I04616; sub I04616 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004617] = 01214; $code[004617] = *I04617; sub I04617 { $lac += $core[004614]; goto &fetch; }
$core[004620] = 03007; $code[004620] = *I04620; sub I04620 { $core[000007] = $lac & 07777; $lac &= 010000; $code[000007] = *emul8; goto &fetch; }
$core[004621] = 04473; $code[004621] = *I04621; sub I04621 { $core[($ib<<12)+$core[59]] = 04622; $pc = ($ib<<12)+$core[59]+1; $code[($ib<<12)+$core[59]] = *emul8; $inh = 0; goto &fetch; }
$core[004622] = 04016; $code[004622] = *I04622; sub I04622 { $core[000016] = 04623; $pc = 000016+1; $code[000016] = *emul8; $inh = 0; goto &fetch; }
$core[004623] = 04030; $code[004623] = *I04623; sub I04623 { $core[000030] = 04624; $pc = 000030+1; $code[000030] = *emul8; $inh = 0; goto &fetch; }
$core[004624] = 00105; $code[004624] = *I04624; sub I04624 { $lac &= (010000|$core[000105]); goto &fetch; }
$core[004625] = 00722; $code[004625] = *I04625; sub I04625 { $lac &= (010000|$core[($df<<12)+$core[2514]]); goto &fetch; }
$core[004626] = 02214; $code[004626] = *I04626; sub I04626 { if (++$core[004614] == 010000) { $core[004614] = 0; $pc++; }$code[004614] = *emul8; goto &fetch; }
$core[004627] = 02214; $code[004627] = *I04627; sub I04627 { if (++$core[004614] == 010000) { $core[004614] = 0; $pc++; }$code[004614] = *emul8; goto &fetch; }
$core[004630] = 02144; $code[004630] = *I04630; sub I04630 { if (++$core[000144] == 010000) { $core[000144] = 0; $pc++; }$code[000144] = *emul8; goto &fetch; }
$core[004631] = 05213; $code[004631] = *I04631; sub I04631 { $pc = 004613; $inh = 0; goto &fetch; }
$core[004632] = 05422; $code[004632] = *I04632; sub I04632 { $pc = ($ib<<12)+$core[18]; $inh = 0; goto &fetch; }
$core[004633] = 00006; $code[004633] = *P04633; sub P04633 { $lac &= (010000|$core[000006]); goto &fetch; }
$core[004634] = 04666; $code[004634] = *I04634; sub I04634 { $core[($ib<<12)+$core[2486]] = 04635; $pc = ($ib<<12)+$core[2486]+1; $code[($ib<<12)+$core[2486]] = *emul8; $inh = 0; goto &fetch; }
$core[004635] = 07200; $code[004635] = *I04635; sub I04635 { $lac &= 010000; goto &fetch; }
$core[004636] = 01135; $code[004636] = *D04636; sub D04636 { $lac += $core[000135]; goto &fetch; }
$core[004637] = 07650; $code[004637] = *I04637; sub I04637 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004640] = 04472; $code[004640] = *I04640; sub I04640 { $core[($ib<<12)+$core[58]] = 04641; $pc = ($ib<<12)+$core[58]+1; $code[($ib<<12)+$core[58]] = *emul8; $inh = 0; goto &fetch; }
$core[004641] = 04424; $code[004641] = *I04641; sub I04641 { $core[($ib<<12)+$core[20]] = 04642; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004642] = 00144; $code[004642] = *I04642; sub I04642 { $lac &= (010000|$core[000144]); goto &fetch; }
$core[004643] = 06504; $code[004643] = *I04643; sub I04643 { &emul8; goto &fetch; }
$core[004644] = 01071; $code[004644] = *I04644; sub I04644 { $lac += $core[000071]; goto &fetch; }
$core[004645] = 03247; $code[004645] = *I04645; sub I04645 { $core[004647] = $lac & 07777; $lac &= 010000; $code[004647] = *emul8; goto &fetch; }
$core[004646] = 04432; $code[004646] = *L04646; sub L04646 { $core[($ib<<12)+$core[26]] = 04647; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004647] = 00000; $code[004647] = *D04647; sub D04647 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004650] = 00104; $code[004650] = *I04650; sub I04650 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[004651] = 07776; $code[004651] = *I04651; sub I04651 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004652] = 01247; $code[004652] = *I04652; sub I04652 { $lac += $core[004647]; goto &fetch; }
$core[004653] = 03007; $code[004653] = *I04653; sub I04653 { $core[000007] = $lac & 07777; $lac &= 010000; $code[000007] = *emul8; goto &fetch; }
$core[004654] = 04473; $code[004654] = *I04654; sub I04654 { $core[($ib<<12)+$core[59]] = 04655; $pc = ($ib<<12)+$core[59]+1; $code[($ib<<12)+$core[59]] = *emul8; $inh = 0; goto &fetch; }
$core[004655] = 04044; $code[004655] = *I04655; sub I04655 { $core[000044] = 04656; $pc = 000044+1; $code[000044] = *emul8; $inh = 0; goto &fetch; }
$core[004656] = 04062; $code[004656] = *I04656; sub I04656 { $core[000062] = 04657; $pc = 000062+1; $code[000062] = *emul8; $inh = 0; goto &fetch; }
$core[004657] = 00105; $code[004657] = *I04657; sub I04657 { $lac &= (010000|$core[000105]); goto &fetch; }
$core[004660] = 00732; $code[004660] = *I04660; sub I04660 { $lac &= (010000|$core[($df<<12)+$core[2522]]); goto &fetch; }
$core[004661] = 02247; $code[004661] = *I04661; sub I04661 { if (++$core[004647] == 010000) { $core[004647] = 0; $pc++; }$code[004647] = *emul8; goto &fetch; }
$core[004662] = 02247; $code[004662] = *I04662; sub I04662 { if (++$core[004647] == 010000) { $core[004647] = 0; $pc++; }$code[004647] = *emul8; goto &fetch; }
$core[004663] = 02144; $code[004663] = *I04663; sub I04663 { if (++$core[000144] == 010000) { $core[000144] = 0; $pc++; }$code[000144] = *emul8; goto &fetch; }
$core[004664] = 05246; $code[004664] = *I04664; sub I04664 { $pc = 004646; $inh = 0; goto &fetch; }
$core[004665] = 05422; $code[004665] = *I04665; sub I04665 { $pc = ($ib<<12)+$core[18]; $inh = 0; goto &fetch; }
$core[004666] = 00007; $code[004666] = *P04666; sub P04666 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[004667] = 07777; $code[004667] = *I04667; sub I04667 { &emul8; goto &fetch; }
$core[004670] = 07200; $code[004670] = *I04670; sub I04670 { $lac &= 010000; goto &fetch; }
$core[004671] = 01135; $code[004671] = *I04671; sub I04671 { $lac += $core[000135]; goto &fetch; }
$core[004672] = 07650; $code[004672] = *I04672; sub I04672 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004673] = 04472; $code[004673] = *I04673; sub I04673 { $core[($ib<<12)+$core[58]] = 04674; $pc = ($ib<<12)+$core[58]+1; $code[($ib<<12)+$core[58]] = *emul8; $inh = 0; goto &fetch; }
$core[004674] = 04424; $code[004674] = *I04674; sub I04674 { $core[($ib<<12)+$core[20]] = 04675; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[004675] = 00144; $code[004675] = *I04675; sub I04675 { $lac &= (010000|$core[000144]); goto &fetch; }
$core[004676] = 06504; $code[004676] = *I04676; sub I04676 { &emul8; goto &fetch; }
$core[004677] = 01071; $code[004677] = *I04677; sub I04677 { $lac += $core[000071]; goto &fetch; }
$core[004700] = 03302; $code[004700] = *I04700; sub I04700 { $core[004702] = $lac & 07777; $lac &= 010000; $code[004702] = *emul8; goto &fetch; }
$core[004701] = 04432; $code[004701] = *L04701; sub L04701 { $core[($ib<<12)+$core[26]] = 04702; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[004702] = 00000; $code[004702] = *D04702; sub D04702 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004703] = 00104; $code[004703] = *I04703; sub I04703 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[004704] = 07776; $code[004704] = *I04704; sub I04704 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[004705] = 01302; $code[004705] = *I04705; sub I04705 { $lac += $core[004702]; goto &fetch; }
$core[004706] = 03007; $code[004706] = *I04706; sub I04706 { $core[000007] = $lac & 07777; $lac &= 010000; $code[000007] = *emul8; goto &fetch; }
$core[004707] = 04473; $code[004707] = *I04707; sub I04707 { $core[($ib<<12)+$core[59]] = 04710; $pc = ($ib<<12)+$core[59]+1; $code[($ib<<12)+$core[59]] = *emul8; $inh = 0; goto &fetch; }
$core[004710] = 04102; $code[004710] = *I04710; sub I04710 { $core[000102] = 04711; $pc = 000102+1; $code[000102] = *emul8; $inh = 0; goto &fetch; }
$core[004711] = 04124; $code[004711] = *I04711; sub I04711 { $core[000124] = 04712; $pc = 000124+1; $code[000124] = *emul8; $inh = 0; goto &fetch; }
$core[004712] = 00104; $code[004712] = *I04712; sub I04712 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[004713] = 00744; $code[004713] = *I04713; sub I04713 { $lac &= (010000|$core[($df<<12)+$core[2532]]); goto &fetch; }
$core[004714] = 02302; $code[004714] = *I04714; sub I04714 { if (++$core[004702] == 010000) { $core[004702] = 0; $pc++; }$code[004702] = *emul8; goto &fetch; }
$core[004715] = 02302; $code[004715] = *I04715; sub I04715 { if (++$core[004702] == 010000) { $core[004702] = 0; $pc++; }$code[004702] = *emul8; goto &fetch; }
$core[004716] = 02144; $code[004716] = *D04716; sub D04716 { if (++$core[000144] == 010000) { $core[000144] = 0; $pc++; }$code[000144] = *emul8; goto &fetch; }
$core[004717] = 05301; $code[004717] = *I04717; sub I04717 { $pc = 004701; $inh = 0; goto &fetch; }
$core[004720] = 05422; $code[004720] = *I04720; sub I04720 { $pc = ($ib<<12)+$core[18]; $inh = 0; goto &fetch; }
$core[004721] = 07604; $code[004721] = *L04721; sub L04721 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004722] = 07132; $code[004722] = *P04722; sub P04722 { $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[004723] = 07430; $code[004723] = *I04723; sub I04723 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004724] = 05336; $code[004724] = *I04724; sub I04724 { $pc = 004736; $inh = 0; goto &fetch; }
$core[004725] = 00020; $code[004725] = *I04725; sub I04725 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[004726] = 07650; $code[004726] = *I04726; sub I04726 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004727] = 05777; $code[004727] = *I04727; sub I04727 { $pc = ($ib<<12)+$core[2559]; $inh = 0; goto &fetch; }
$core[004730] = 03020; $code[004730] = *I04730; sub I04730 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[004731] = 07604; $code[004731] = *L04731; sub L04731 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004732] = 07106; $code[004732] = *P04732; sub P04732 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[004733] = 07430; $code[004733] = *I04733; sub I04733 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004734] = 05776; $code[004734] = *I04734; sub I04734 { $pc = ($ib<<12)+$core[2558]; $inh = 0; goto &fetch; }
$core[004735] = 05775; $code[004735] = *I04735; sub I04735 { $pc = ($ib<<12)+$core[2557]; $inh = 0; goto &fetch; }
$core[004736] = 07510; $code[004736] = *L04736; sub L04736 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004737] = 05344; $code[004737] = *I04737; sub I04737 { $pc = 004744; $inh = 0; goto &fetch; }
$core[004740] = 00020; $code[004740] = *I04740; sub I04740 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[004741] = 07450; $code[004741] = *I04741; sub I04741 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004742] = 05331; $code[004742] = *I04742; sub I04742 { $pc = 004731; $inh = 0; goto &fetch; }
$core[004743] = 05774; $code[004743] = *I04743; sub I04743 { $pc = ($ib<<12)+$core[2556]; $inh = 0; goto &fetch; }
$core[004744] = 00020; $code[004744] = *P04744; sub P04744 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[004745] = 07650; $code[004745] = *I04745; sub I04745 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004746] = 05777; $code[004746] = *I04746; sub I04746 { $pc = ($ib<<12)+$core[2559]; $inh = 0; goto &fetch; }
$core[004747] = 05331; $code[004747] = *I04747; sub I04747 { $pc = 004731; $inh = 0; goto &fetch; }
$core[004750] = 00000; $code[004750] = *S04750; sub S04750 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004751] = 07300; $code[004751] = *I04751; sub I04751 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004752] = 06224; $code[004752] = *I04752; sub I04752 { &emul8; goto &fetch; }
$core[004753] = 01173; $code[004753] = *I04753; sub I04753 { $lac += $core[000173]; goto &fetch; }
$core[004754] = 03161; $code[004754] = *I04754; sub I04754 { $core[000161] = $lac & 07777; $lac &= 010000; $code[000161] = *emul8; goto &fetch; }
$core[004755] = 06201; $code[004755] = *I04755; sub I04755 { &emul8; goto &fetch; }
$core[004756] = 01373; $code[004756] = *I04756; sub I04756 { $lac += $core[004773]; goto &fetch; }
$core[004757] = 03772; $code[004757] = *I04757; sub I04757 { $core[($df<<12)+$core[2554]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2554]] = *emul8; goto &fetch; }
$core[004760] = 01371; $code[004760] = *I04760; sub I04760 { $lac += $core[004771]; goto &fetch; }
$core[004761] = 03770; $code[004761] = *I04761; sub I04761 { $core[($df<<12)+$core[2552]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2552]] = *emul8; goto &fetch; }
$core[004762] = 01367; $code[004762] = *I04762; sub I04762 { $lac += $core[004767]; goto &fetch; }
$core[004763] = 03766; $code[004763] = *I04763; sub I04763 { $core[($df<<12)+$core[2550]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2550]] = *emul8; goto &fetch; }
$core[004764] = 04160; $code[004764] = *I04764; sub I04764 { $core[000160] = 04765; $pc = 000160+1; $code[000160] = *emul8; $inh = 0; goto &fetch; }
$core[004765] = 05750; $code[004765] = *I04765; sub I04765 { $pc = ($ib<<12)+$core[2536]; $inh = 0; goto &fetch; }
$core[004766] = 00003; $code[004766] = *P04766; sub P04766 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[004767] = 01017; $code[004767] = *D04767; sub D04767 { $lac += $core[000017]; goto &fetch; }
$core[004770] = 00002; $code[004770] = *P04770; sub P04770 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[004771] = 05403; $code[004771] = *D04771; sub D04771 { $pc = ($ib<<12)+$core[3]; $inh = 0; goto &fetch; }
$core[004772] = 00001; $code[004772] = *P04772; sub P04772 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[004773] = 06244; $code[004773] = *D04773; sub D04773 { &emul8; goto &fetch; }
$core[004774] = 01366; $code[004774] = *P04774; sub P04774 { $lac += $core[004766]; goto &fetch; }
$core[004775] = 00236; $code[004775] = *P04775; sub P04775 { $lac &= (010000|$core[004636]); goto &fetch; }
$core[004776] = 00316; $code[004776] = *P04776; sub P04776 { $lac &= (010000|$core[004716]); goto &fetch; }
$core[004777] = 01371; $code[004777] = *P04777; sub P04777 { $lac += $core[004771]; goto &fetch; }
$core[005000] = 00000; $code[005000] = *I05000; sub I05000 { $lac &= (010000|$core[000000]); goto &fetch; }
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

