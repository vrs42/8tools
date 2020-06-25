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
$core[000002] = 00002; $code[000002] = *L00002; sub L00002 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000003] = 00003; $code[000003] = *D00003; sub D00003 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000004] = 00000; $code[000004] = *L00004; sub L00004 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000005] = 00000; $code[000005] = *D00005; sub D00005 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000006] = 07402; $code[000006] = *I00006; sub I00006 { $hlt = 1; goto &fetch; }
$core[000007] = 07402; $code[000007] = *I00007; sub I00007 { $hlt = 1; goto &fetch; }
$core[000010] = 07402; $code[000010] = *P00010; sub P00010 { $hlt = 1; goto &fetch; }
$core[000011] = 07402; $code[000011] = *D00011; sub D00011 { $hlt = 1; goto &fetch; }
$core[000012] = 07402; $code[000012] = *I00012; sub I00012 { $hlt = 1; goto &fetch; }
$core[000013] = 07402; $code[000013] = *I00013; sub I00013 { $hlt = 1; goto &fetch; }
$core[000014] = 07402; $code[000014] = *I00014; sub I00014 { $hlt = 1; goto &fetch; }
$core[000015] = 07402; $code[000015] = *I00015; sub I00015 { $hlt = 1; goto &fetch; }
$core[000016] = 07402; $code[000016] = *I00016; sub I00016 { $hlt = 1; goto &fetch; }
$core[000017] = 07402; $code[000017] = *I00017; sub I00017 { $hlt = 1; goto &fetch; }
$core[000020] = 07402; $code[000020] = *P00020; sub P00020 { $hlt = 1; goto &fetch; }
$core[000021] = 07402; $code[000021] = *D00021; sub D00021 { $hlt = 1; goto &fetch; }
$core[000022] = 00000; $code[000022] = *P00022; sub P00022 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000023] = 00001; $code[000023] = *P00023; sub P00023 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000024] = 00002; $code[000024] = *P00024; sub P00024 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000025] = 00004; $code[000025] = *P00025; sub P00025 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[000026] = 00010; $code[000026] = *P00026; sub P00026 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[000027] = 00020; $code[000027] = *P00027; sub P00027 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[000030] = 00040; $code[000030] = *P00030; sub P00030 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000031] = 00100; $code[000031] = *P00031; sub P00031 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000032] = 00200; $code[000032] = *P00032; sub P00032 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000033] = 00400; $code[000033] = *P00033; sub P00033 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000034] = 01000; $code[000034] = *P00034; sub P00034 { $lac += $core[000000]; goto &fetch; }
$core[000035] = 02000; $code[000035] = *P00035; sub P00035 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[000036] = 04000; $code[000036] = *P00036; sub P00036 { $core[000000] = 00037; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000037] = 03777; $code[000037] = *P00037; sub P00037 { $core[($df<<12)+$core[127]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[127]] = *emul8; goto &fetch; }
$core[000042] = 05777; $code[000042] = *P00042; sub P00042 { $pc = ($ib<<12)+$core[127]; $inh = 0; goto &fetch; }
$core[000043] = 06777; $code[000043] = *P00043; sub P00043 { &emul8; goto &fetch; }
$core[000044] = 07377; $code[000044] = *P00044; sub P00044 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000045] = 07577; $code[000045] = *P00045; sub P00045 { &emul8; goto &fetch; }
$core[000046] = 07677; $code[000046] = *P00046; sub P00046 { &emul8; goto &fetch; }
$core[000047] = 07737; $code[000047] = *P00047; sub P00047 { &emul8; goto &fetch; }
$core[000050] = 07757; $code[000050] = *P00050; sub P00050 { &emul8; goto &fetch; }
$core[000051] = 07767; $code[000051] = *P00051; sub P00051 { &emul8; goto &fetch; }
$core[000052] = 07773; $code[000052] = *P00052; sub P00052 { &emul8; goto &fetch; }
$core[000053] = 07775; $code[000053] = *P00053; sub P00053 { &emul8; goto &fetch; }
$core[000054] = 07776; $code[000054] = *P00054; sub P00054 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000055] = 07777; $code[000055] = *P00055; sub P00055 { &emul8; goto &fetch; }
$core[000056] = 04620; $code[000056] = *P00056; sub P00056 { $core[($ib<<12)+$core[16]] = 00057; $pc = ($ib<<12)+$core[16]+1; $code[($ib<<12)+$core[16]] = *emul8; $inh = 0; goto &fetch; }
$core[000057] = 04640; $code[000057] = *P00057; sub P00057 { $core[($ib<<12)+$core[32]] = 00060; $pc = ($ib<<12)+$core[32]+1; $code[($ib<<12)+$core[32]] = *emul8; $inh = 0; goto &fetch; }
$core[000060] = 04660; $code[000060] = *P00060; sub P00060 { $core[($ib<<12)+$core[48]] = 00061; $pc = ($ib<<12)+$core[48]+1; $code[($ib<<12)+$core[48]] = *emul8; $inh = 0; goto &fetch; }
$core[000061] = 04700; $code[000061] = *P00061; sub P00061 { $core[($ib<<12)+$core[64]] = 00062; $pc = ($ib<<12)+$core[64]+1; $code[($ib<<12)+$core[64]] = *emul8; $inh = 0; goto &fetch; }
$core[000062] = 04720; $code[000062] = *P00062; sub P00062 { $core[($ib<<12)+$core[80]] = 00063; $pc = ($ib<<12)+$core[80]+1; $code[($ib<<12)+$core[80]] = *emul8; $inh = 0; goto &fetch; }
$core[000063] = 04740; $code[000063] = *P00063; sub P00063 { $core[($ib<<12)+$core[96]] = 00064; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[000064] = 04760; $code[000064] = *P00064; sub P00064 { $core[($ib<<12)+$core[112]] = 00065; $pc = ($ib<<12)+$core[112]+1; $code[($ib<<12)+$core[112]] = *emul8; $inh = 0; goto &fetch; }
$core[000065] = 05000; $code[000065] = *P00065; sub P00065 { $pc = 000000; $inh = 0; goto &fetch; }
$core[000066] = 05020; $code[000066] = *P00066; sub P00066 { $pc = 000020; $inh = 0; goto &fetch; }
$core[000067] = 05040; $code[000067] = *P00067; sub P00067 { $pc = 000040; $inh = 0; goto &fetch; }
$core[000070] = 05060; $code[000070] = *P00070; sub P00070 { $pc = 000060; $inh = 0; goto &fetch; }
$core[000071] = 05100; $code[000071] = *P00071; sub P00071 { $pc = 000100; $inh = 0; goto &fetch; }
$core[000072] = 05120; $code[000072] = *P00072; sub P00072 { $pc = 000120; $inh = 0; goto &fetch; }
$core[000073] = 05140; $code[000073] = *P00073; sub P00073 { $pc = 000140; $inh = 0; goto &fetch; }
$core[000074] = 05160; $code[000074] = *P00074; sub P00074 { $pc = 000160; $inh = 0; goto &fetch; }
$core[000075] = 05200; $code[000075] = *P00075; sub P00075 { $pc = 000000; $inh = 0; goto &fetch; }
$core[000076] = 05220; $code[000076] = *P00076; sub P00076 { $pc = 000020; $inh = 0; goto &fetch; }
$core[000102] = 05240; $code[000102] = *P00102; sub P00102 { $pc = 000040; $inh = 0; goto &fetch; }
$core[000103] = 05260; $code[000103] = *P00103; sub P00103 { $pc = 000060; $inh = 0; goto &fetch; }
$core[000104] = 05300; $code[000104] = *P00104; sub P00104 { $pc = 000100; $inh = 0; goto &fetch; }
$core[000105] = 05320; $code[000105] = *P00105; sub P00105 { $pc = 000120; $inh = 0; goto &fetch; }
$core[000106] = 05340; $code[000106] = *P00106; sub P00106 { $pc = 000140; $inh = 0; goto &fetch; }
$core[000107] = 05360; $code[000107] = *P00107; sub P00107 { $pc = 000160; $inh = 0; goto &fetch; }
$core[000110] = 05400; $code[000110] = *P00110; sub P00110 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[000111] = 05420; $code[000111] = *P00111; sub P00111 { $pc = ($ib<<12)+$core[16]; $inh = 0; goto &fetch; }
$core[000112] = 05440; $code[000112] = *P00112; sub P00112 { $pc = ($ib<<12)+$core[32]; $inh = 0; goto &fetch; }
$core[000113] = 07777; $code[000113] = *D00113; sub D00113 { &emul8; goto &fetch; }
$core[000114] = 07776; $code[000114] = *D00114; sub D00114 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000115] = 07775; $code[000115] = *D00115; sub D00115 { &emul8; goto &fetch; }
$core[000116] = 07774; $code[000116] = *D00116; sub D00116 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000117] = 07773; $code[000117] = *D00117; sub D00117 { &emul8; goto &fetch; }
$core[000120] = 07772; $code[000120] = *P00120; sub P00120 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[000121] = 07771; $code[000121] = *D00121; sub D00121 { &emul8; goto &fetch; }
$core[000122] = 07770; $code[000122] = *D00122; sub D00122 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000123] = 07767; $code[000123] = *D00123; sub D00123 { &emul8; goto &fetch; }
$core[000124] = 07766; $code[000124] = *D00124; sub D00124 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000125] = 07765; $code[000125] = *D00125; sub D00125 { &emul8; goto &fetch; }
$core[000126] = 07764; $code[000126] = *D00126; sub D00126 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000127] = 07763; $code[000127] = *D00127; sub D00127 { &emul8; goto &fetch; }
$core[000130] = 07762; $code[000130] = *D00130; sub D00130 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[000131] = 07761; $code[000131] = *D00131; sub D00131 { &emul8; goto &fetch; }
$core[000132] = 07760; $code[000132] = *D00132; sub D00132 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000133] = 07757; $code[000133] = *D00133; sub D00133 { &emul8; goto &fetch; }
$core[000134] = 07756; $code[000134] = *D00134; sub D00134 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000135] = 07755; $code[000135] = *D00135; sub D00135 { &emul8; goto &fetch; }
$core[000136] = 00000; $code[000136] = *D00136; sub D00136 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000137] = 02410; $code[000137] = *P00137; sub P00137 { $core[000010] = 0000 if ++$core[000010] == 010000; if (++$core[($df<<12)+$core[000010]] == 010000) { $core[($df<<12)+$core[000010]] = 0; $pc++; }$code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000140] = 02440; $code[000140] = *P00140; sub P00140 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[000141] = 02470; $code[000141] = *P00141; sub P00141 { if (++$core[($df<<12)+$core[56]] == 010000) { $core[($df<<12)+$core[56]] = 0; $pc++; }$code[($df<<12)+$core[56]] = *emul8; goto &fetch; }
$core[000142] = 02520; $code[000142] = *P00142; sub P00142 { if (++$core[($df<<12)+$core[80]] == 010000) { $core[($df<<12)+$core[80]] = 0; $pc++; }$code[($df<<12)+$core[80]] = *emul8; goto &fetch; }
$core[000143] = 02600; $code[000143] = *P00143; sub P00143 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[000144] = 02630; $code[000144] = *P00144; sub P00144 { if (++$core[($df<<12)+$core[24]] == 010000) { $core[($df<<12)+$core[24]] = 0; $pc++; }$code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[000145] = 02660; $code[000145] = *P00145; sub P00145 { if (++$core[($df<<12)+$core[48]] == 010000) { $core[($df<<12)+$core[48]] = 0; $pc++; }$code[($df<<12)+$core[48]] = *emul8; goto &fetch; }
$core[000146] = 02710; $code[000146] = *P00146; sub P00146 { if (++$core[($df<<12)+$core[72]] == 010000) { $core[($df<<12)+$core[72]] = 0; $pc++; }$code[($df<<12)+$core[72]] = *emul8; goto &fetch; }
$core[000147] = 02740; $code[000147] = *P00147; sub P00147 { if (++$core[($df<<12)+$core[96]] == 010000) { $core[($df<<12)+$core[96]] = 0; $pc++; }$code[($df<<12)+$core[96]] = *emul8; goto &fetch; }
$core[000150] = 03000; $code[000150] = *P00150; sub P00150 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000151] = 03030; $code[000151] = *P00151; sub P00151 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[000152] = 03060; $code[000152] = *P00152; sub P00152 { $core[000060] = $lac & 07777; $lac &= 010000; $code[000060] = *emul8; goto &fetch; }
$core[000153] = 03110; $code[000153] = *P00153; sub P00153 { $core[000110] = $lac & 07777; $lac &= 010000; $code[000110] = *emul8; goto &fetch; }
$core[000154] = 03140; $code[000154] = *P00154; sub P00154 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[000155] = 03200; $code[000155] = *P00155; sub P00155 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000156] = 03230; $code[000156] = *P00156; sub P00156 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[000157] = 03260; $code[000157] = *P00157; sub P00157 { $core[000060] = $lac & 07777; $lac &= 010000; $code[000060] = *emul8; goto &fetch; }
$core[000160] = 03310; $code[000160] = *P00160; sub P00160 { $core[000110] = $lac & 07777; $lac &= 010000; $code[000110] = *emul8; goto &fetch; }
$core[000161] = 03340; $code[000161] = *P00161; sub P00161 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[000162] = 03400; $code[000162] = *P00162; sub P00162 { $core[($df<<12)+$core[0]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[000163] = 03430; $code[000163] = *P00163; sub P00163 { $core[($df<<12)+$core[24]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[000164] = 03460; $code[000164] = *P00164; sub P00164 { $core[($df<<12)+$core[48]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[48]] = *emul8; goto &fetch; }
$core[000165] = 03510; $code[000165] = *P00165; sub P00165 { $core[($df<<12)+$core[72]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[72]] = *emul8; goto &fetch; }
$core[000166] = 03540; $code[000166] = *P00166; sub P00166 { $core[($df<<12)+$core[96]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[96]] = *emul8; goto &fetch; }
$core[000170] = 00000; $code[000170] = *S00170; sub S00170 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000171] = 01175; $code[000171] = *I00171; sub I00171 { $lac += $core[000175]; goto &fetch; }
$core[000172] = 03410; $code[000172] = *P00172; sub P00172 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000173] = 01010; $code[000173] = *I00173; sub I00173 { $lac += $core[000010]; goto &fetch; }
$core[000174] = 05570; $code[000174] = *I00174; sub I00174 { $pc = ($ib<<12)+$core[120]; $inh = 0; goto &fetch; }
$core[000175] = 07402; $code[000175] = *D00175; sub D00175 { $hlt = 1; goto &fetch; }
$core[000200] = 05601; $code[000200] = *P00200; sub P00200 { $pc = ($ib<<12)+$core[129]; $inh = 0; goto &fetch; }
$core[000201] = 00600; $code[000201] = *P00201; sub P00201 { $lac &= (010000|$core[($df<<12)+$core[128]]); goto &fetch; }
$core[000600] = 07200; $code[000600] = *L00600; sub L00600 { $lac &= 010000; goto &fetch; }
$core[000601] = 01453; $code[000601] = *P00601; sub P00601 { $lac += $core[($df<<12)+$core[43]]; goto &fetch; }
$core[000602] = 03343; $code[000602] = *I00602; sub I00602 { $core[000743] = $lac & 07777; $lac &= 010000; $code[000743] = *emul8; goto &fetch; }
$core[000603] = 01452; $code[000603] = *I00603; sub I00603 { $lac += $core[($df<<12)+$core[42]]; goto &fetch; }
$core[000604] = 03344; $code[000604] = *I00604; sub I00604 { $core[000744] = $lac & 07777; $lac &= 010000; $code[000744] = *emul8; goto &fetch; }
$core[000605] = 01736; $code[000605] = *I00605; sub I00605 { $lac += $core[($df<<12)+$core[478]]; goto &fetch; }
$core[000606] = 03345; $code[000606] = *I00606; sub I00606 { $core[000745] = $lac & 07777; $lac &= 010000; $code[000745] = *emul8; goto &fetch; }
$core[000607] = 01451; $code[000607] = *I00607; sub I00607 { $lac += $core[($df<<12)+$core[41]]; goto &fetch; }
$core[000610] = 03346; $code[000610] = *I00610; sub I00610 { $core[000746] = $lac & 07777; $lac &= 010000; $code[000746] = *emul8; goto &fetch; }
$core[000611] = 01737; $code[000611] = *I00611; sub I00611 { $lac += $core[($df<<12)+$core[479]]; goto &fetch; }
$core[000612] = 03347; $code[000612] = *I00612; sub I00612 { $core[000747] = $lac & 07777; $lac &= 010000; $code[000747] = *emul8; goto &fetch; }
$core[000613] = 01450; $code[000613] = *I00613; sub I00613 { $lac += $core[($df<<12)+$core[40]]; goto &fetch; }
$core[000614] = 03350; $code[000614] = *I00614; sub I00614 { $core[000750] = $lac & 07777; $lac &= 010000; $code[000750] = *emul8; goto &fetch; }
$core[000615] = 01740; $code[000615] = *I00615; sub I00615 { $lac += $core[($df<<12)+$core[480]]; goto &fetch; }
$core[000616] = 03351; $code[000616] = *I00616; sub I00616 { $core[000751] = $lac & 07777; $lac &= 010000; $code[000751] = *emul8; goto &fetch; }
$core[000617] = 01447; $code[000617] = *I00617; sub I00617 { $lac += $core[($df<<12)+$core[39]]; goto &fetch; }
$core[000620] = 03352; $code[000620] = *I00620; sub I00620 { $core[000752] = $lac & 07777; $lac &= 010000; $code[000752] = *emul8; goto &fetch; }
$core[000621] = 01741; $code[000621] = *I00621; sub I00621 { $lac += $core[($df<<12)+$core[481]]; goto &fetch; }
$core[000622] = 03353; $code[000622] = *I00622; sub I00622 { $core[000753] = $lac & 07777; $lac &= 010000; $code[000753] = *emul8; goto &fetch; }
$core[000623] = 01446; $code[000623] = *I00623; sub I00623 { $lac += $core[($df<<12)+$core[38]]; goto &fetch; }
$core[000624] = 03354; $code[000624] = *I00624; sub I00624 { $core[000754] = $lac & 07777; $lac &= 010000; $code[000754] = *emul8; goto &fetch; }
$core[000625] = 01742; $code[000625] = *I00625; sub I00625 { $lac += $core[($df<<12)+$core[482]]; goto &fetch; }
$core[000626] = 03355; $code[000626] = *I00626; sub I00626 { $core[000755] = $lac & 07777; $lac &= 010000; $code[000755] = *emul8; goto &fetch; }
$core[000627] = 01455; $code[000627] = *I00627; sub I00627 { $lac += $core[($df<<12)+$core[45]]; goto &fetch; }
$core[000630] = 03356; $code[000630] = *I00630; sub I00630 { $core[000756] = $lac & 07777; $lac &= 010000; $code[000756] = *emul8; goto &fetch; }
$core[000631] = 07300; $code[000631] = *I00631; sub I00631 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000632] = 01264; $code[000632] = *I00632; sub I00632 { $lac += $core[000664]; goto &fetch; }
$core[000633] = 03010; $code[000633] = *I00633; sub I00633 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000634] = 04170; $code[000634] = *L00634; sub L00634 { $core[000170] = 00635; $pc = 000170+1; $code[000170] = *emul8; $inh = 0; goto &fetch; }
$core[000635] = 01265; $code[000635] = *I00635; sub I00635 { $lac += $core[000665]; goto &fetch; }
$core[000636] = 07640; $code[000636] = *I00636; sub I00636 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000637] = 05234; $code[000637] = *I00637; sub I00637 { $pc = 000634; $inh = 0; goto &fetch; }
$core[000640] = 01266; $code[000640] = *I00640; sub I00640 { $lac += $core[000666]; goto &fetch; }
$core[000641] = 03010; $code[000641] = *I00641; sub I00641 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000642] = 04170; $code[000642] = *L00642; sub L00642 { $core[000170] = 00643; $pc = 000170+1; $code[000170] = *emul8; $inh = 0; goto &fetch; }
$core[000643] = 01267; $code[000643] = *I00643; sub I00643 { $lac += $core[000667]; goto &fetch; }
$core[000644] = 07640; $code[000644] = *I00644; sub I00644 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000645] = 05242; $code[000645] = *I00645; sub I00645 { $pc = 000642; $inh = 0; goto &fetch; }
$core[000646] = 01270; $code[000646] = *I00646; sub I00646 { $lac += $core[000670]; goto &fetch; }
$core[000647] = 03010; $code[000647] = *I00647; sub I00647 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000650] = 04170; $code[000650] = *L00650; sub L00650 { $core[000170] = 00651; $pc = 000170+1; $code[000170] = *emul8; $inh = 0; goto &fetch; }
$core[000651] = 01271; $code[000651] = *I00651; sub I00651 { $lac += $core[000671]; goto &fetch; }
$core[000652] = 07640; $code[000652] = *I00652; sub I00652 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000653] = 05250; $code[000653] = *I00653; sub I00653 { $pc = 000650; $inh = 0; goto &fetch; }
$core[000654] = 01272; $code[000654] = *I00654; sub I00654 { $lac += $core[000672]; goto &fetch; }
$core[000655] = 03010; $code[000655] = *I00655; sub I00655 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000656] = 04170; $code[000656] = *L00656; sub L00656 { $core[000170] = 00657; $pc = 000170+1; $code[000170] = *emul8; $inh = 0; goto &fetch; }
$core[000657] = 01273; $code[000657] = *I00657; sub I00657 { $lac += $core[000673]; goto &fetch; }
$core[000660] = 07640; $code[000660] = *I00660; sub I00660 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000661] = 05256; $code[000661] = *I00661; sub I00661 { $pc = 000656; $inh = 0; goto &fetch; }
$core[000662] = 05300; $code[000662] = *I00662; sub I00662 { $pc = 000700; $inh = 0; goto &fetch; }
$core[000663] = 04200; $code[000663] = *P00663; sub P00663 { $core[000600] = 00664; $pc = 000600+1; $code[000600] = *emul8; $inh = 0; goto &fetch; }
$core[000664] = 00175; $code[000664] = *D00664; sub D00664 { $lac &= (010000|$core[000175]); goto &fetch; }
$core[000665] = 07201; $code[000665] = *D00665; sub D00665 { $lac &= 010000; $lac++; goto &fetch; }
$core[000666] = 00756; $code[000666] = *D00666; sub D00666 { $lac &= (010000|$core[($df<<12)+$core[494]]); goto &fetch; }
$core[000667] = 06001; $code[000667] = *D00667; sub D00667 { &emul8; goto &fetch; }
$core[000670] = 03572; $code[000670] = *D00670; sub D00670 { $core[($df<<12)+$core[122]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[122]] = *emul8; goto &fetch; }
$core[000671] = 03601; $code[000671] = *D00671; sub D00671 { $core[($df<<12)+$core[385]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[385]] = *emul8; goto &fetch; }
$core[000672] = 05451; $code[000672] = *D00672; sub D00672 { $pc = ($ib<<12)+$core[41]; $inh = 0; goto &fetch; }
$core[000673] = 00200; $code[000673] = *D00673; sub D00673 { $lac &= (010000|$core[000600]); goto &fetch; }
$core[000700] = 01303; $code[000700] = *L00700; sub L00700 { $lac += $core[000703]; goto &fetch; }
$core[000701] = 03200; $code[000701] = *I00701; sub I00701 { $core[000600] = $lac & 07777; $lac &= 010000; $code[000600] = *emul8; goto &fetch; }
$core[000702] = 05303; $code[000702] = *I00702; sub I00702 { $pc = 000703; $inh = 0; goto &fetch; }
$core[000703] = 05663; $code[000703] = *L00703; sub L00703 { $pc = ($ib<<12)+$core[435]; $inh = 0; goto &fetch; }
$core[000704] = 07200; $code[000704] = *I00704; sub I00704 { $lac &= 010000; goto &fetch; }
$core[000705] = 01343; $code[000705] = *I00705; sub I00705 { $lac += $core[000743]; goto &fetch; }
$core[000706] = 03453; $code[000706] = *I00706; sub I00706 { $core[($df<<12)+$core[43]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[43]] = *emul8; goto &fetch; }
$core[000707] = 01344; $code[000707] = *I00707; sub I00707 { $lac += $core[000744]; goto &fetch; }
$core[000710] = 03452; $code[000710] = *I00710; sub I00710 { $core[($df<<12)+$core[42]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[42]] = *emul8; goto &fetch; }
$core[000711] = 01345; $code[000711] = *I00711; sub I00711 { $lac += $core[000745]; goto &fetch; }
$core[000712] = 03736; $code[000712] = *I00712; sub I00712 { $core[($df<<12)+$core[478]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[478]] = *emul8; goto &fetch; }
$core[000713] = 01346; $code[000713] = *I00713; sub I00713 { $lac += $core[000746]; goto &fetch; }
$core[000714] = 03451; $code[000714] = *I00714; sub I00714 { $core[($df<<12)+$core[41]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[41]] = *emul8; goto &fetch; }
$core[000715] = 01347; $code[000715] = *I00715; sub I00715 { $lac += $core[000747]; goto &fetch; }
$core[000716] = 03737; $code[000716] = *I00716; sub I00716 { $core[($df<<12)+$core[479]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[479]] = *emul8; goto &fetch; }
$core[000717] = 01350; $code[000717] = *I00717; sub I00717 { $lac += $core[000750]; goto &fetch; }
$core[000720] = 03450; $code[000720] = *I00720; sub I00720 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[000721] = 01351; $code[000721] = *I00721; sub I00721 { $lac += $core[000751]; goto &fetch; }
$core[000722] = 03740; $code[000722] = *I00722; sub I00722 { $core[($df<<12)+$core[480]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[480]] = *emul8; goto &fetch; }
$core[000723] = 01352; $code[000723] = *I00723; sub I00723 { $lac += $core[000752]; goto &fetch; }
$core[000724] = 03447; $code[000724] = *I00724; sub I00724 { $core[($df<<12)+$core[39]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[39]] = *emul8; goto &fetch; }
$core[000725] = 01353; $code[000725] = *I00725; sub I00725 { $lac += $core[000753]; goto &fetch; }
$core[000726] = 03741; $code[000726] = *I00726; sub I00726 { $core[($df<<12)+$core[481]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[481]] = *emul8; goto &fetch; }
$core[000727] = 01354; $code[000727] = *I00727; sub I00727 { $lac += $core[000754]; goto &fetch; }
$core[000730] = 03446; $code[000730] = *I00730; sub I00730 { $core[($df<<12)+$core[38]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[38]] = *emul8; goto &fetch; }
$core[000731] = 01355; $code[000731] = *I00731; sub I00731 { $lac += $core[000755]; goto &fetch; }
$core[000732] = 03742; $code[000732] = *I00732; sub I00732 { $core[($df<<12)+$core[482]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[482]] = *emul8; goto &fetch; }
$core[000733] = 01356; $code[000733] = *I00733; sub I00733 { $lac += $core[000756]; goto &fetch; }
$core[000734] = 03455; $code[000734] = *I00734; sub I00734 { $core[($df<<12)+$core[45]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[45]] = *emul8; goto &fetch; }
$core[000735] = 07402; $code[000735] = *I00735; sub I00735 { $hlt = 1; goto &fetch; }
$core[000736] = 07774; $code[000736] = *P00736; sub P00736 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000737] = 07770; $code[000737] = *P00737; sub P00737 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000740] = 07760; $code[000740] = *P00740; sub P00740 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000741] = 07740; $code[000741] = *P00741; sub P00741 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000742] = 07700; $code[000742] = *P00742; sub P00742 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000743] = 00000; $code[000743] = *D00743; sub D00743 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000744] = 00000; $code[000744] = *D00744; sub D00744 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000745] = 00000; $code[000745] = *D00745; sub D00745 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000746] = 00000; $code[000746] = *D00746; sub D00746 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000747] = 01742; $code[000747] = *D00747; sub D00747 { $lac += $core[($df<<12)+$core[482]]; goto &fetch; }
$core[000750] = 00000; $code[000750] = *D00750; sub D00750 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000751] = 00000; $code[000751] = *D00751; sub D00751 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000752] = 00000; $code[000752] = *D00752; sub D00752 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000753] = 00000; $code[000753] = *D00753; sub D00753 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000754] = 00000; $code[000754] = *D00754; sub D00754 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000755] = 00000; $code[000755] = *D00755; sub D00755 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000756] = 00000; $code[000756] = *P00756; sub P00756 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002002] = 04203; $code[002002] = *L02002; sub L02002 { $core[002003] = 02003; $pc = 002003+1; $code[002003] = *emul8; $inh = 0; goto &fetch; }
$core[002003] = 05203; $code[002003] = *L02003; sub L02003 { $pc = 002003; $inh = 0; goto &fetch; }
$core[002004] = 01136; $code[002004] = *I02004; sub I02004 { $lac += $core[000136]; goto &fetch; }
$core[002005] = 01222; $code[002005] = *I02005; sub I02005 { $lac += $core[002022]; goto &fetch; }
$core[002006] = 07440; $code[002006] = *I02006; sub I02006 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002007] = 07402; $code[002007] = *I02007; sub I02007 { $hlt = 1; goto &fetch; }
$core[002010] = 01224; $code[002010] = *I02010; sub I02010 { $lac += $core[002024]; goto &fetch; }
$core[002011] = 07041; $code[002011] = *I02011; sub I02011 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002012] = 01203; $code[002012] = *I02012; sub I02012 { $lac += $core[002003]; goto &fetch; }
$core[002013] = 07440; $code[002013] = *I02013; sub I02013 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002014] = 07402; $code[002014] = *I02014; sub I02014 { $hlt = 1; goto &fetch; }
$core[002015] = 03203; $code[002015] = *I02015; sub I02015 { $core[002003] = $lac & 07777; $lac &= 010000; $code[002003] = *emul8; goto &fetch; }
$core[002016] = 01136; $code[002016] = *I02016; sub I02016 { $lac += $core[000136]; goto &fetch; }
$core[002017] = 07001; $code[002017] = *I02017; sub I02017 { $lac++; goto &fetch; }
$core[002020] = 03136; $code[002020] = *I02020; sub I02020 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002021] = 07410; $code[002021] = *I02021; sub I02021 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002022] = 07722; $code[002022] = *D02022; sub D02022 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[002023] = 07410; $code[002023] = *I02023; sub I02023 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002024] = 02003; $code[002024] = *D02024; sub D02024 { if (++$core[000003] == 010000) { $core[000003] = 0; $pc++; }$code[000003] = *emul8; goto &fetch; }
$core[002025] = 04227; $code[002025] = *I02025; sub I02025 { $core[002027] = 02026; $pc = 002027+1; $code[002027] = *emul8; $inh = 0; goto &fetch; }
$core[002026] = 07402; $code[002026] = *I02026; sub I02026 { $hlt = 1; goto &fetch; }
$core[002027] = 05227; $code[002027] = *L02027; sub L02027 { $pc = 002027; $inh = 0; goto &fetch; }
$core[002030] = 01136; $code[002030] = *I02030; sub I02030 { $lac += $core[000136]; goto &fetch; }
$core[002031] = 01246; $code[002031] = *I02031; sub I02031 { $lac += $core[002046]; goto &fetch; }
$core[002032] = 07440; $code[002032] = *I02032; sub I02032 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002033] = 07402; $code[002033] = *I02033; sub I02033 { $hlt = 1; goto &fetch; }
$core[002034] = 01250; $code[002034] = *I02034; sub I02034 { $lac += $core[002050]; goto &fetch; }
$core[002035] = 07041; $code[002035] = *I02035; sub I02035 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002036] = 01227; $code[002036] = *I02036; sub I02036 { $lac += $core[002027]; goto &fetch; }
$core[002037] = 07440; $code[002037] = *I02037; sub I02037 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002040] = 07402; $code[002040] = *I02040; sub I02040 { $hlt = 1; goto &fetch; }
$core[002041] = 03227; $code[002041] = *I02041; sub I02041 { $core[002027] = $lac & 07777; $lac &= 010000; $code[002027] = *emul8; goto &fetch; }
$core[002042] = 01136; $code[002042] = *I02042; sub I02042 { $lac += $core[000136]; goto &fetch; }
$core[002043] = 07001; $code[002043] = *I02043; sub I02043 { $lac++; goto &fetch; }
$core[002044] = 03136; $code[002044] = *I02044; sub I02044 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002045] = 07410; $code[002045] = *I02045; sub I02045 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002046] = 07721; $code[002046] = *D02046; sub D02046 { &emul8; goto &fetch; }
$core[002047] = 07410; $code[002047] = *I02047; sub I02047 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002050] = 02026; $code[002050] = *D02050; sub D02050 { if (++$core[000026] == 010000) { $core[000026] = 0; $pc++; }$code[000026] = *emul8; goto &fetch; }
$core[002051] = 04254; $code[002051] = *I02051; sub I02051 { $core[002054] = 02052; $pc = 002054+1; $code[002054] = *emul8; $inh = 0; goto &fetch; }
$core[002052] = 07402; $code[002052] = *I02052; sub I02052 { $hlt = 1; goto &fetch; }
$core[002053] = 07402; $code[002053] = *I02053; sub I02053 { $hlt = 1; goto &fetch; }
$core[002054] = 05254; $code[002054] = *L02054; sub L02054 { $pc = 002054; $inh = 0; goto &fetch; }
$core[002055] = 01136; $code[002055] = *I02055; sub I02055 { $lac += $core[000136]; goto &fetch; }
$core[002056] = 01275; $code[002056] = *I02056; sub I02056 { $lac += $core[002075]; goto &fetch; }
$core[002057] = 07440; $code[002057] = *I02057; sub I02057 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002060] = 07402; $code[002060] = *I02060; sub I02060 { $hlt = 1; goto &fetch; }
$core[002061] = 01273; $code[002061] = *I02061; sub I02061 { $lac += $core[002073]; goto &fetch; }
$core[002062] = 07041; $code[002062] = *I02062; sub I02062 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002063] = 01254; $code[002063] = *I02063; sub I02063 { $lac += $core[002054]; goto &fetch; }
$core[002064] = 07440; $code[002064] = *I02064; sub I02064 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002065] = 07402; $code[002065] = *I02065; sub I02065 { $hlt = 1; goto &fetch; }
$core[002066] = 03254; $code[002066] = *I02066; sub I02066 { $core[002054] = $lac & 07777; $lac &= 010000; $code[002054] = *emul8; goto &fetch; }
$core[002067] = 01136; $code[002067] = *I02067; sub I02067 { $lac += $core[000136]; goto &fetch; }
$core[002070] = 07001; $code[002070] = *I02070; sub I02070 { $lac++; goto &fetch; }
$core[002071] = 03136; $code[002071] = *I02071; sub I02071 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002072] = 07410; $code[002072] = *I02072; sub I02072 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002073] = 02052; $code[002073] = *D02073; sub D02073 { if (++$core[000052] == 010000) { $core[000052] = 0; $pc++; }$code[000052] = *emul8; goto &fetch; }
$core[002074] = 07410; $code[002074] = *I02074; sub I02074 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002075] = 07720; $code[002075] = *D02075; sub D02075 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002076] = 04302; $code[002076] = *I02076; sub I02076 { $core[002102] = 02077; $pc = 002102+1; $code[002102] = *emul8; $inh = 0; goto &fetch; }
$core[002077] = 07402; $code[002077] = *I02077; sub I02077 { $hlt = 1; goto &fetch; }
$core[002100] = 07402; $code[002100] = *I02100; sub I02100 { $hlt = 1; goto &fetch; }
$core[002101] = 07402; $code[002101] = *I02101; sub I02101 { $hlt = 1; goto &fetch; }
$core[002102] = 05302; $code[002102] = *L02102; sub L02102 { $pc = 002102; $inh = 0; goto &fetch; }
$core[002103] = 01136; $code[002103] = *I02103; sub I02103 { $lac += $core[000136]; goto &fetch; }
$core[002104] = 01323; $code[002104] = *I02104; sub I02104 { $lac += $core[002123]; goto &fetch; }
$core[002105] = 07440; $code[002105] = *I02105; sub I02105 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002106] = 07402; $code[002106] = *I02106; sub I02106 { $hlt = 1; goto &fetch; }
$core[002107] = 01321; $code[002107] = *I02107; sub I02107 { $lac += $core[002121]; goto &fetch; }
$core[002110] = 07041; $code[002110] = *I02110; sub I02110 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002111] = 01302; $code[002111] = *I02111; sub I02111 { $lac += $core[002102]; goto &fetch; }
$core[002112] = 07440; $code[002112] = *I02112; sub I02112 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002113] = 07402; $code[002113] = *I02113; sub I02113 { $hlt = 1; goto &fetch; }
$core[002114] = 03302; $code[002114] = *I02114; sub I02114 { $core[002102] = $lac & 07777; $lac &= 010000; $code[002102] = *emul8; goto &fetch; }
$core[002115] = 01136; $code[002115] = *I02115; sub I02115 { $lac += $core[000136]; goto &fetch; }
$core[002116] = 07001; $code[002116] = *I02116; sub I02116 { $lac++; goto &fetch; }
$core[002117] = 03136; $code[002117] = *I02117; sub I02117 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002120] = 07410; $code[002120] = *I02120; sub I02120 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002121] = 02077; $code[002121] = *D02121; sub D02121 { if (++$core[000077] == 010000) { $core[000077] = 0; $pc++; }$code[000077] = *emul8; goto &fetch; }
$core[002122] = 07410; $code[002122] = *I02122; sub I02122 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002123] = 07717; $code[002123] = *D02123; sub D02123 { &emul8; goto &fetch; }
$core[002124] = 04330; $code[002124] = *I02124; sub I02124 { $core[002130] = 02125; $pc = 002130+1; $code[002130] = *emul8; $inh = 0; goto &fetch; }
$core[002125] = 07402; $code[002125] = *I02125; sub I02125 { $hlt = 1; goto &fetch; }
$core[002126] = 07402; $code[002126] = *I02126; sub I02126 { $hlt = 1; goto &fetch; }
$core[002127] = 07402; $code[002127] = *I02127; sub I02127 { $hlt = 1; goto &fetch; }
$core[002130] = 05330; $code[002130] = *L02130; sub L02130 { $pc = 002130; $inh = 0; goto &fetch; }
$core[002131] = 01136; $code[002131] = *I02131; sub I02131 { $lac += $core[000136]; goto &fetch; }
$core[002132] = 01351; $code[002132] = *I02132; sub I02132 { $lac += $core[002151]; goto &fetch; }
$core[002133] = 07440; $code[002133] = *I02133; sub I02133 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002134] = 07402; $code[002134] = *I02134; sub I02134 { $hlt = 1; goto &fetch; }
$core[002135] = 01347; $code[002135] = *I02135; sub I02135 { $lac += $core[002147]; goto &fetch; }
$core[002136] = 07041; $code[002136] = *I02136; sub I02136 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002137] = 01330; $code[002137] = *I02137; sub I02137 { $lac += $core[002130]; goto &fetch; }
$core[002140] = 07440; $code[002140] = *I02140; sub I02140 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002141] = 07402; $code[002141] = *I02141; sub I02141 { $hlt = 1; goto &fetch; }
$core[002142] = 03330; $code[002142] = *I02142; sub I02142 { $core[002130] = $lac & 07777; $lac &= 010000; $code[002130] = *emul8; goto &fetch; }
$core[002143] = 01136; $code[002143] = *I02143; sub I02143 { $lac += $core[000136]; goto &fetch; }
$core[002144] = 07001; $code[002144] = *I02144; sub I02144 { $lac++; goto &fetch; }
$core[002145] = 03136; $code[002145] = *I02145; sub I02145 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002146] = 07410; $code[002146] = *I02146; sub I02146 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002147] = 02125; $code[002147] = *D02147; sub D02147 { if (++$core[000125] == 010000) { $core[000125] = 0; $pc++; }$code[000125] = *emul8; goto &fetch; }
$core[002150] = 07410; $code[002150] = *I02150; sub I02150 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002151] = 07716; $code[002151] = *D02151; sub D02151 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002152] = 04356; $code[002152] = *I02152; sub I02152 { $core[002156] = 02153; $pc = 002156+1; $code[002156] = *emul8; $inh = 0; goto &fetch; }
$core[002153] = 07402; $code[002153] = *I02153; sub I02153 { $hlt = 1; goto &fetch; }
$core[002154] = 07402; $code[002154] = *I02154; sub I02154 { $hlt = 1; goto &fetch; }
$core[002155] = 07402; $code[002155] = *I02155; sub I02155 { $hlt = 1; goto &fetch; }
$core[002156] = 05356; $code[002156] = *L02156; sub L02156 { $pc = 002156; $inh = 0; goto &fetch; }
$core[002157] = 01136; $code[002157] = *I02157; sub I02157 { $lac += $core[000136]; goto &fetch; }
$core[002160] = 01377; $code[002160] = *I02160; sub I02160 { $lac += $core[002177]; goto &fetch; }
$core[002161] = 07440; $code[002161] = *I02161; sub I02161 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002162] = 07402; $code[002162] = *I02162; sub I02162 { $hlt = 1; goto &fetch; }
$core[002163] = 01375; $code[002163] = *I02163; sub I02163 { $lac += $core[002175]; goto &fetch; }
$core[002164] = 07041; $code[002164] = *I02164; sub I02164 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002165] = 01356; $code[002165] = *I02165; sub I02165 { $lac += $core[002156]; goto &fetch; }
$core[002166] = 07440; $code[002166] = *I02166; sub I02166 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002167] = 07402; $code[002167] = *I02167; sub I02167 { $hlt = 1; goto &fetch; }
$core[002170] = 03356; $code[002170] = *I02170; sub I02170 { $core[002156] = $lac & 07777; $lac &= 010000; $code[002156] = *emul8; goto &fetch; }
$core[002171] = 01136; $code[002171] = *I02171; sub I02171 { $lac += $core[000136]; goto &fetch; }
$core[002172] = 07001; $code[002172] = *I02172; sub I02172 { $lac++; goto &fetch; }
$core[002173] = 03136; $code[002173] = *I02173; sub I02173 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002174] = 07410; $code[002174] = *I02174; sub I02174 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002175] = 02153; $code[002175] = *D02175; sub D02175 { if (++$core[000153] == 010000) { $core[000153] = 0; $pc++; }$code[000153] = *emul8; goto &fetch; }
$core[002176] = 07410; $code[002176] = *I02176; sub I02176 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002177] = 07715; $code[002177] = *D02177; sub D02177 { &emul8; goto &fetch; }
$core[002200] = 07000; $code[002200] = *I02200; sub I02200 { goto &fetch; }
$core[002201] = 04202; $code[002201] = *I02201; sub I02201 { $core[002202] = 02202; $pc = 002202+1; $code[002202] = *emul8; $inh = 0; goto &fetch; }
$core[002202] = 05202; $code[002202] = *L02202; sub L02202 { $pc = 002202; $inh = 0; goto &fetch; }
$core[002203] = 01136; $code[002203] = *I02203; sub I02203 { $lac += $core[000136]; goto &fetch; }
$core[002204] = 01221; $code[002204] = *I02204; sub I02204 { $lac += $core[002221]; goto &fetch; }
$core[002205] = 07440; $code[002205] = *I02205; sub I02205 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002206] = 07402; $code[002206] = *I02206; sub I02206 { $hlt = 1; goto &fetch; }
$core[002207] = 01202; $code[002207] = *I02207; sub I02207 { $lac += $core[002202]; goto &fetch; }
$core[002210] = 07041; $code[002210] = *I02210; sub I02210 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002211] = 01223; $code[002211] = *I02211; sub I02211 { $lac += $core[002223]; goto &fetch; }
$core[002212] = 07440; $code[002212] = *I02212; sub I02212 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002213] = 07402; $code[002213] = *I02213; sub I02213 { $hlt = 1; goto &fetch; }
$core[002214] = 03202; $code[002214] = *I02214; sub I02214 { $core[002202] = $lac & 07777; $lac &= 010000; $code[002202] = *emul8; goto &fetch; }
$core[002215] = 01136; $code[002215] = *I02215; sub I02215 { $lac += $core[000136]; goto &fetch; }
$core[002216] = 07001; $code[002216] = *I02216; sub I02216 { $lac++; goto &fetch; }
$core[002217] = 03136; $code[002217] = *I02217; sub I02217 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002220] = 07410; $code[002220] = *I02220; sub I02220 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002221] = 07714; $code[002221] = *D02221; sub D02221 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002222] = 07410; $code[002222] = *I02222; sub I02222 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002223] = 02202; $code[002223] = *D02223; sub D02223 { if (++$core[002202] == 010000) { $core[002202] = 0; $pc++; }$code[002202] = *emul8; goto &fetch; }
$core[002224] = 04226; $code[002224] = *I02224; sub I02224 { $core[002226] = 02225; $pc = 002226+1; $code[002226] = *emul8; $inh = 0; goto &fetch; }
$core[002225] = 07402; $code[002225] = *D02225; sub D02225 { $hlt = 1; goto &fetch; }
$core[002226] = 05226; $code[002226] = *L02226; sub L02226 { $pc = 002226; $inh = 0; goto &fetch; }
$core[002227] = 01136; $code[002227] = *I02227; sub I02227 { $lac += $core[000136]; goto &fetch; }
$core[002230] = 01245; $code[002230] = *I02230; sub I02230 { $lac += $core[002245]; goto &fetch; }
$core[002231] = 07440; $code[002231] = *I02231; sub I02231 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002232] = 07402; $code[002232] = *I02232; sub I02232 { $hlt = 1; goto &fetch; }
$core[002233] = 01247; $code[002233] = *I02233; sub I02233 { $lac += $core[002247]; goto &fetch; }
$core[002234] = 07041; $code[002234] = *I02234; sub I02234 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002235] = 01226; $code[002235] = *I02235; sub I02235 { $lac += $core[002226]; goto &fetch; }
$core[002236] = 07440; $code[002236] = *I02236; sub I02236 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002237] = 07402; $code[002237] = *I02237; sub I02237 { $hlt = 1; goto &fetch; }
$core[002240] = 03226; $code[002240] = *I02240; sub I02240 { $core[002226] = $lac & 07777; $lac &= 010000; $code[002226] = *emul8; goto &fetch; }
$core[002241] = 01136; $code[002241] = *I02241; sub I02241 { $lac += $core[000136]; goto &fetch; }
$core[002242] = 07001; $code[002242] = *I02242; sub I02242 { $lac++; goto &fetch; }
$core[002243] = 03136; $code[002243] = *I02243; sub I02243 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002244] = 07410; $code[002244] = *I02244; sub I02244 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002245] = 07713; $code[002245] = *D02245; sub D02245 { &emul8; goto &fetch; }
$core[002246] = 07410; $code[002246] = *I02246; sub I02246 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002247] = 02225; $code[002247] = *D02247; sub D02247 { if (++$core[002225] == 010000) { $core[002225] = 0; $pc++; }$code[002225] = *emul8; goto &fetch; }
$core[002250] = 04253; $code[002250] = *I02250; sub I02250 { $core[002253] = 02251; $pc = 002253+1; $code[002253] = *emul8; $inh = 0; goto &fetch; }
$core[002251] = 07402; $code[002251] = *D02251; sub D02251 { $hlt = 1; goto &fetch; }
$core[002252] = 07402; $code[002252] = *I02252; sub I02252 { $hlt = 1; goto &fetch; }
$core[002253] = 05253; $code[002253] = *L02253; sub L02253 { $pc = 002253; $inh = 0; goto &fetch; }
$core[002254] = 01136; $code[002254] = *I02254; sub I02254 { $lac += $core[000136]; goto &fetch; }
$core[002255] = 01274; $code[002255] = *I02255; sub I02255 { $lac += $core[002274]; goto &fetch; }
$core[002256] = 07440; $code[002256] = *I02256; sub I02256 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002257] = 07402; $code[002257] = *I02257; sub I02257 { $hlt = 1; goto &fetch; }
$core[002260] = 01253; $code[002260] = *I02260; sub I02260 { $lac += $core[002253]; goto &fetch; }
$core[002261] = 07041; $code[002261] = *I02261; sub I02261 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002262] = 01272; $code[002262] = *I02262; sub I02262 { $lac += $core[002272]; goto &fetch; }
$core[002263] = 07440; $code[002263] = *I02263; sub I02263 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002264] = 07402; $code[002264] = *I02264; sub I02264 { $hlt = 1; goto &fetch; }
$core[002265] = 03253; $code[002265] = *I02265; sub I02265 { $core[002253] = $lac & 07777; $lac &= 010000; $code[002253] = *emul8; goto &fetch; }
$core[002266] = 01136; $code[002266] = *I02266; sub I02266 { $lac += $core[000136]; goto &fetch; }
$core[002267] = 07001; $code[002267] = *I02267; sub I02267 { $lac++; goto &fetch; }
$core[002270] = 03136; $code[002270] = *I02270; sub I02270 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002271] = 07410; $code[002271] = *I02271; sub I02271 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002272] = 02251; $code[002272] = *D02272; sub D02272 { if (++$core[002251] == 010000) { $core[002251] = 0; $pc++; }$code[002251] = *emul8; goto &fetch; }
$core[002273] = 07410; $code[002273] = *I02273; sub I02273 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002274] = 07712; $code[002274] = *D02274; sub D02274 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[002275] = 04301; $code[002275] = *I02275; sub I02275 { $core[002301] = 02276; $pc = 002301+1; $code[002301] = *emul8; $inh = 0; goto &fetch; }
$core[002276] = 07402; $code[002276] = *D02276; sub D02276 { $hlt = 1; goto &fetch; }
$core[002277] = 07402; $code[002277] = *I02277; sub I02277 { $hlt = 1; goto &fetch; }
$core[002300] = 07402; $code[002300] = *I02300; sub I02300 { $hlt = 1; goto &fetch; }
$core[002301] = 05301; $code[002301] = *L02301; sub L02301 { $pc = 002301; $inh = 0; goto &fetch; }
$core[002302] = 01136; $code[002302] = *I02302; sub I02302 { $lac += $core[000136]; goto &fetch; }
$core[002303] = 01322; $code[002303] = *I02303; sub I02303 { $lac += $core[002322]; goto &fetch; }
$core[002304] = 07440; $code[002304] = *I02304; sub I02304 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002305] = 07402; $code[002305] = *I02305; sub I02305 { $hlt = 1; goto &fetch; }
$core[002306] = 01301; $code[002306] = *I02306; sub I02306 { $lac += $core[002301]; goto &fetch; }
$core[002307] = 07041; $code[002307] = *I02307; sub I02307 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002310] = 01320; $code[002310] = *I02310; sub I02310 { $lac += $core[002320]; goto &fetch; }
$core[002311] = 07440; $code[002311] = *I02311; sub I02311 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002312] = 07402; $code[002312] = *I02312; sub I02312 { $hlt = 1; goto &fetch; }
$core[002313] = 03301; $code[002313] = *I02313; sub I02313 { $core[002301] = $lac & 07777; $lac &= 010000; $code[002301] = *emul8; goto &fetch; }
$core[002314] = 01136; $code[002314] = *I02314; sub I02314 { $lac += $core[000136]; goto &fetch; }
$core[002315] = 07001; $code[002315] = *I02315; sub I02315 { $lac++; goto &fetch; }
$core[002316] = 03136; $code[002316] = *I02316; sub I02316 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002317] = 07410; $code[002317] = *I02317; sub I02317 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002320] = 02276; $code[002320] = *D02320; sub D02320 { if (++$core[002276] == 010000) { $core[002276] = 0; $pc++; }$code[002276] = *emul8; goto &fetch; }
$core[002321] = 07410; $code[002321] = *I02321; sub I02321 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002322] = 07711; $code[002322] = *D02322; sub D02322 { &emul8; goto &fetch; }
$core[002323] = 04330; $code[002323] = *I02323; sub I02323 { $core[002330] = 02324; $pc = 002330+1; $code[002330] = *emul8; $inh = 0; goto &fetch; }
$core[002324] = 07402; $code[002324] = *D02324; sub D02324 { $hlt = 1; goto &fetch; }
$core[002325] = 07402; $code[002325] = *I02325; sub I02325 { $hlt = 1; goto &fetch; }
$core[002326] = 07402; $code[002326] = *I02326; sub I02326 { $hlt = 1; goto &fetch; }
$core[002327] = 07402; $code[002327] = *I02327; sub I02327 { $hlt = 1; goto &fetch; }
$core[002330] = 05330; $code[002330] = *L02330; sub L02330 { $pc = 002330; $inh = 0; goto &fetch; }
$core[002331] = 01136; $code[002331] = *I02331; sub I02331 { $lac += $core[000136]; goto &fetch; }
$core[002332] = 01351; $code[002332] = *I02332; sub I02332 { $lac += $core[002351]; goto &fetch; }
$core[002333] = 07440; $code[002333] = *I02333; sub I02333 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002334] = 07402; $code[002334] = *I02334; sub I02334 { $hlt = 1; goto &fetch; }
$core[002335] = 01330; $code[002335] = *I02335; sub I02335 { $lac += $core[002330]; goto &fetch; }
$core[002336] = 07041; $code[002336] = *I02336; sub I02336 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002337] = 01347; $code[002337] = *I02337; sub I02337 { $lac += $core[002347]; goto &fetch; }
$core[002340] = 07440; $code[002340] = *I02340; sub I02340 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002341] = 07402; $code[002341] = *I02341; sub I02341 { $hlt = 1; goto &fetch; }
$core[002342] = 03330; $code[002342] = *I02342; sub I02342 { $core[002330] = $lac & 07777; $lac &= 010000; $code[002330] = *emul8; goto &fetch; }
$core[002343] = 01136; $code[002343] = *I02343; sub I02343 { $lac += $core[000136]; goto &fetch; }
$core[002344] = 07001; $code[002344] = *I02344; sub I02344 { $lac++; goto &fetch; }
$core[002345] = 03136; $code[002345] = *I02345; sub I02345 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002346] = 07410; $code[002346] = *I02346; sub I02346 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002347] = 02324; $code[002347] = *D02347; sub D02347 { if (++$core[002324] == 010000) { $core[002324] = 0; $pc++; }$code[002324] = *emul8; goto &fetch; }
$core[002350] = 07410; $code[002350] = *I02350; sub I02350 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002351] = 07710; $code[002351] = *D02351; sub D02351 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002352] = 04356; $code[002352] = *I02352; sub I02352 { $core[002356] = 02353; $pc = 002356+1; $code[002356] = *emul8; $inh = 0; goto &fetch; }
$core[002353] = 07402; $code[002353] = *D02353; sub D02353 { $hlt = 1; goto &fetch; }
$core[002354] = 07402; $code[002354] = *I02354; sub I02354 { $hlt = 1; goto &fetch; }
$core[002355] = 07402; $code[002355] = *I02355; sub I02355 { $hlt = 1; goto &fetch; }
$core[002356] = 05356; $code[002356] = *L02356; sub L02356 { $pc = 002356; $inh = 0; goto &fetch; }
$core[002357] = 01136; $code[002357] = *I02357; sub I02357 { $lac += $core[000136]; goto &fetch; }
$core[002360] = 01377; $code[002360] = *I02360; sub I02360 { $lac += $core[002377]; goto &fetch; }
$core[002361] = 07440; $code[002361] = *I02361; sub I02361 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002362] = 07402; $code[002362] = *I02362; sub I02362 { $hlt = 1; goto &fetch; }
$core[002363] = 01356; $code[002363] = *I02363; sub I02363 { $lac += $core[002356]; goto &fetch; }
$core[002364] = 07041; $code[002364] = *I02364; sub I02364 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002365] = 01375; $code[002365] = *I02365; sub I02365 { $lac += $core[002375]; goto &fetch; }
$core[002366] = 07440; $code[002366] = *I02366; sub I02366 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002367] = 07402; $code[002367] = *I02367; sub I02367 { $hlt = 1; goto &fetch; }
$core[002370] = 03356; $code[002370] = *I02370; sub I02370 { $core[002356] = $lac & 07777; $lac &= 010000; $code[002356] = *emul8; goto &fetch; }
$core[002371] = 01136; $code[002371] = *I02371; sub I02371 { $lac += $core[000136]; goto &fetch; }
$core[002372] = 07001; $code[002372] = *I02372; sub I02372 { $lac++; goto &fetch; }
$core[002373] = 03136; $code[002373] = *I02373; sub I02373 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002374] = 07410; $code[002374] = *I02374; sub I02374 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002375] = 02353; $code[002375] = *D02375; sub D02375 { if (++$core[002353] == 010000) { $core[002353] = 0; $pc++; }$code[002353] = *emul8; goto &fetch; }
$core[002376] = 07410; $code[002376] = *I02376; sub I02376 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002377] = 07707; $code[002377] = *D02377; sub D02377 { &emul8; goto &fetch; }
$core[002400] = 01205; $code[002400] = *I02400; sub I02400 { $lac += $core[002405]; goto &fetch; }
$core[002401] = 03455; $code[002401] = *I02401; sub I02401 { $core[($df<<12)+$core[45]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[45]] = *emul8; goto &fetch; }
$core[002402] = 01206; $code[002402] = *I02402; sub I02402 { $lac += $core[002406]; goto &fetch; }
$core[002403] = 03423; $code[002403] = *I02403; sub I02403 { $core[($df<<12)+$core[19]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[19]] = *emul8; goto &fetch; }
$core[002404] = 05423; $code[002404] = *I02404; sub I02404 { $pc = ($ib<<12)+$core[19]; $inh = 0; goto &fetch; }
$core[002405] = 05537; $code[002405] = *D02405; sub D02405 { $pc = ($ib<<12)+$core[95]; $inh = 0; goto &fetch; }
$core[002406] = 04454; $code[002406] = *D02406; sub D02406 { $core[($ib<<12)+$core[44]] = 02407; $pc = ($ib<<12)+$core[44]+1; $code[($ib<<12)+$core[44]] = *emul8; $inh = 0; goto &fetch; }
$core[002410] = 01136; $code[002410] = *L02410; sub L02410 { $lac += $core[000136]; goto &fetch; }
$core[002411] = 01233; $code[002411] = *I02411; sub I02411 { $lac += $core[002433]; goto &fetch; }
$core[002412] = 07440; $code[002412] = *I02412; sub I02412 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002413] = 07402; $code[002413] = *I02413; sub I02413 { $hlt = 1; goto &fetch; }
$core[002414] = 01454; $code[002414] = *I02414; sub I02414 { $lac += $core[($df<<12)+$core[44]]; goto &fetch; }
$core[002415] = 01054; $code[002415] = *I02415; sub I02415 { $lac += $core[000054]; goto &fetch; }
$core[002416] = 07440; $code[002416] = *I02416; sub I02416 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002417] = 07402; $code[002417] = *I02417; sub I02417 { $hlt = 1; goto &fetch; }
$core[002420] = 03454; $code[002420] = *I02420; sub I02420 { $core[($df<<12)+$core[44]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[44]] = *emul8; goto &fetch; }
$core[002421] = 01136; $code[002421] = *I02421; sub I02421 { $lac += $core[000136]; goto &fetch; }
$core[002422] = 07001; $code[002422] = *I02422; sub I02422 { $lac++; goto &fetch; }
$core[002423] = 03136; $code[002423] = *I02423; sub I02423 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002424] = 01231; $code[002424] = *I02424; sub I02424 { $lac += $core[002431]; goto &fetch; }
$core[002425] = 03454; $code[002425] = *I02425; sub I02425 { $core[($df<<12)+$core[44]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[44]] = *emul8; goto &fetch; }
$core[002426] = 01232; $code[002426] = *I02426; sub I02426 { $lac += $core[002432]; goto &fetch; }
$core[002427] = 03424; $code[002427] = *I02427; sub I02427 { $core[($df<<12)+$core[20]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[20]] = *emul8; goto &fetch; }
$core[002430] = 05424; $code[002430] = *I02430; sub I02430 { $pc = ($ib<<12)+$core[20]; $inh = 0; goto &fetch; }
$core[002431] = 05540; $code[002431] = *D02431; sub D02431 { $pc = ($ib<<12)+$core[96]; $inh = 0; goto &fetch; }
$core[002432] = 04453; $code[002432] = *D02432; sub D02432 { $core[($ib<<12)+$core[43]] = 02433; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[002433] = 07706; $code[002433] = *D02433; sub D02433 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002440] = 01136; $code[002440] = *L02440; sub L02440 { $lac += $core[000136]; goto &fetch; }
$core[002441] = 01263; $code[002441] = *I02441; sub I02441 { $lac += $core[002463]; goto &fetch; }
$core[002442] = 07440; $code[002442] = *I02442; sub I02442 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002443] = 07402; $code[002443] = *I02443; sub I02443 { $hlt = 1; goto &fetch; }
$core[002444] = 01453; $code[002444] = *I02444; sub I02444 { $lac += $core[($df<<12)+$core[43]]; goto &fetch; }
$core[002445] = 01053; $code[002445] = *I02445; sub I02445 { $lac += $core[000053]; goto &fetch; }
$core[002446] = 07440; $code[002446] = *I02446; sub I02446 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002447] = 07402; $code[002447] = *I02447; sub I02447 { $hlt = 1; goto &fetch; }
$core[002450] = 03453; $code[002450] = *I02450; sub I02450 { $core[($df<<12)+$core[43]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[43]] = *emul8; goto &fetch; }
$core[002451] = 01136; $code[002451] = *I02451; sub I02451 { $lac += $core[000136]; goto &fetch; }
$core[002452] = 07001; $code[002452] = *I02452; sub I02452 { $lac++; goto &fetch; }
$core[002453] = 03136; $code[002453] = *I02453; sub I02453 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002454] = 01261; $code[002454] = *I02454; sub I02454 { $lac += $core[002461]; goto &fetch; }
$core[002455] = 03664; $code[002455] = *I02455; sub I02455 { $core[($df<<12)+$core[1332]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1332]] = *emul8; goto &fetch; }
$core[002456] = 01262; $code[002456] = *I02456; sub I02456 { $lac += $core[002462]; goto &fetch; }
$core[002457] = 03425; $code[002457] = *I02457; sub I02457 { $core[($df<<12)+$core[21]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[002460] = 05425; $code[002460] = *I02460; sub I02460 { $pc = ($ib<<12)+$core[21]; $inh = 0; goto &fetch; }
$core[002461] = 05541; $code[002461] = *D02461; sub D02461 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[002462] = 04452; $code[002462] = *D02462; sub D02462 { $core[($ib<<12)+$core[42]] = 02463; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[002463] = 07705; $code[002463] = *D02463; sub D02463 { &emul8; goto &fetch; }
$core[002464] = 07774; $code[002464] = *P02464; sub P02464 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002470] = 01136; $code[002470] = *L02470; sub L02470 { $lac += $core[000136]; goto &fetch; }
$core[002471] = 01313; $code[002471] = *I02471; sub I02471 { $lac += $core[002513]; goto &fetch; }
$core[002472] = 07440; $code[002472] = *I02472; sub I02472 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002473] = 07402; $code[002473] = *I02473; sub I02473 { $hlt = 1; goto &fetch; }
$core[002474] = 01452; $code[002474] = *I02474; sub I02474 { $lac += $core[($df<<12)+$core[42]]; goto &fetch; }
$core[002475] = 01052; $code[002475] = *I02475; sub I02475 { $lac += $core[000052]; goto &fetch; }
$core[002476] = 07440; $code[002476] = *I02476; sub I02476 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002477] = 07402; $code[002477] = *I02477; sub I02477 { $hlt = 1; goto &fetch; }
$core[002500] = 03452; $code[002500] = *I02500; sub I02500 { $core[($df<<12)+$core[42]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[42]] = *emul8; goto &fetch; }
$core[002501] = 01136; $code[002501] = *I02501; sub I02501 { $lac += $core[000136]; goto &fetch; }
$core[002502] = 07001; $code[002502] = *I02502; sub I02502 { $lac++; goto &fetch; }
$core[002503] = 03136; $code[002503] = *I02503; sub I02503 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002504] = 01311; $code[002504] = *I02504; sub I02504 { $lac += $core[002511]; goto &fetch; }
$core[002505] = 03714; $code[002505] = *I02505; sub I02505 { $core[($df<<12)+$core[1356]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1356]] = *emul8; goto &fetch; }
$core[002506] = 01312; $code[002506] = *I02506; sub I02506 { $lac += $core[002512]; goto &fetch; }
$core[002507] = 03426; $code[002507] = *I02507; sub I02507 { $core[($df<<12)+$core[22]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[22]] = *emul8; goto &fetch; }
$core[002510] = 05426; $code[002510] = *I02510; sub I02510 { $pc = ($ib<<12)+$core[22]; $inh = 0; goto &fetch; }
$core[002511] = 05542; $code[002511] = *D02511; sub D02511 { $pc = ($ib<<12)+$core[98]; $inh = 0; goto &fetch; }
$core[002512] = 04451; $code[002512] = *D02512; sub D02512 { $core[($ib<<12)+$core[41]] = 02513; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[002513] = 07704; $code[002513] = *D02513; sub D02513 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[002514] = 07770; $code[002514] = *P02514; sub P02514 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002520] = 01136; $code[002520] = *L02520; sub L02520 { $lac += $core[000136]; goto &fetch; }
$core[002521] = 01343; $code[002521] = *I02521; sub I02521 { $lac += $core[002543]; goto &fetch; }
$core[002522] = 07440; $code[002522] = *I02522; sub I02522 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002523] = 07402; $code[002523] = *I02523; sub I02523 { $hlt = 1; goto &fetch; }
$core[002524] = 01451; $code[002524] = *I02524; sub I02524 { $lac += $core[($df<<12)+$core[41]]; goto &fetch; }
$core[002525] = 01051; $code[002525] = *I02525; sub I02525 { $lac += $core[000051]; goto &fetch; }
$core[002526] = 07440; $code[002526] = *I02526; sub I02526 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002527] = 07402; $code[002527] = *I02527; sub I02527 { $hlt = 1; goto &fetch; }
$core[002530] = 03451; $code[002530] = *I02530; sub I02530 { $core[($df<<12)+$core[41]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[41]] = *emul8; goto &fetch; }
$core[002531] = 01136; $code[002531] = *I02531; sub I02531 { $lac += $core[000136]; goto &fetch; }
$core[002532] = 07001; $code[002532] = *I02532; sub I02532 { $lac++; goto &fetch; }
$core[002533] = 03136; $code[002533] = *I02533; sub I02533 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002534] = 01341; $code[002534] = *I02534; sub I02534 { $lac += $core[002541]; goto &fetch; }
$core[002535] = 03744; $code[002535] = *I02535; sub I02535 { $core[($df<<12)+$core[1380]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1380]] = *emul8; goto &fetch; }
$core[002536] = 01342; $code[002536] = *I02536; sub I02536 { $lac += $core[002542]; goto &fetch; }
$core[002537] = 03427; $code[002537] = *I02537; sub I02537 { $core[($df<<12)+$core[23]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[23]] = *emul8; goto &fetch; }
$core[002540] = 05427; $code[002540] = *I02540; sub I02540 { $pc = ($ib<<12)+$core[23]; $inh = 0; goto &fetch; }
$core[002541] = 05543; $code[002541] = *D02541; sub D02541 { $pc = ($ib<<12)+$core[99]; $inh = 0; goto &fetch; }
$core[002542] = 04450; $code[002542] = *D02542; sub D02542 { $core[($ib<<12)+$core[40]] = 02543; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[002543] = 07703; $code[002543] = *D02543; sub D02543 { &emul8; goto &fetch; }
$core[002544] = 07760; $code[002544] = *P02544; sub P02544 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002600] = 01136; $code[002600] = *L02600; sub L02600 { $lac += $core[000136]; goto &fetch; }
$core[002601] = 01223; $code[002601] = *I02601; sub I02601 { $lac += $core[002623]; goto &fetch; }
$core[002602] = 07440; $code[002602] = *I02602; sub I02602 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002603] = 07402; $code[002603] = *I02603; sub I02603 { $hlt = 1; goto &fetch; }
$core[002604] = 01450; $code[002604] = *I02604; sub I02604 { $lac += $core[($df<<12)+$core[40]]; goto &fetch; }
$core[002605] = 01050; $code[002605] = *I02605; sub I02605 { $lac += $core[000050]; goto &fetch; }
$core[002606] = 07440; $code[002606] = *I02606; sub I02606 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002607] = 07402; $code[002607] = *I02607; sub I02607 { $hlt = 1; goto &fetch; }
$core[002610] = 03450; $code[002610] = *I02610; sub I02610 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[002611] = 01136; $code[002611] = *I02611; sub I02611 { $lac += $core[000136]; goto &fetch; }
$core[002612] = 07001; $code[002612] = *I02612; sub I02612 { $lac++; goto &fetch; }
$core[002613] = 03136; $code[002613] = *I02613; sub I02613 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002614] = 01221; $code[002614] = *I02614; sub I02614 { $lac += $core[002621]; goto &fetch; }
$core[002615] = 03624; $code[002615] = *I02615; sub I02615 { $core[($df<<12)+$core[1428]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1428]] = *emul8; goto &fetch; }
$core[002616] = 01222; $code[002616] = *I02616; sub I02616 { $lac += $core[002622]; goto &fetch; }
$core[002617] = 03430; $code[002617] = *I02617; sub I02617 { $core[($df<<12)+$core[24]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[002620] = 05430; $code[002620] = *I02620; sub I02620 { $pc = ($ib<<12)+$core[24]; $inh = 0; goto &fetch; }
$core[002621] = 05544; $code[002621] = *D02621; sub D02621 { $pc = ($ib<<12)+$core[100]; $inh = 0; goto &fetch; }
$core[002622] = 04447; $code[002622] = *D02622; sub D02622 { $core[($ib<<12)+$core[39]] = 02623; $pc = ($ib<<12)+$core[39]+1; $code[($ib<<12)+$core[39]] = *emul8; $inh = 0; goto &fetch; }
$core[002623] = 07702; $code[002623] = *D02623; sub D02623 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[002624] = 07740; $code[002624] = *P02624; sub P02624 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002630] = 01136; $code[002630] = *L02630; sub L02630 { $lac += $core[000136]; goto &fetch; }
$core[002631] = 01253; $code[002631] = *I02631; sub I02631 { $lac += $core[002653]; goto &fetch; }
$core[002632] = 07440; $code[002632] = *I02632; sub I02632 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002633] = 07402; $code[002633] = *I02633; sub I02633 { $hlt = 1; goto &fetch; }
$core[002634] = 01447; $code[002634] = *I02634; sub I02634 { $lac += $core[($df<<12)+$core[39]]; goto &fetch; }
$core[002635] = 01047; $code[002635] = *I02635; sub I02635 { $lac += $core[000047]; goto &fetch; }
$core[002636] = 07440; $code[002636] = *I02636; sub I02636 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002637] = 07402; $code[002637] = *I02637; sub I02637 { $hlt = 1; goto &fetch; }
$core[002640] = 03447; $code[002640] = *I02640; sub I02640 { $core[($df<<12)+$core[39]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[39]] = *emul8; goto &fetch; }
$core[002641] = 01136; $code[002641] = *I02641; sub I02641 { $lac += $core[000136]; goto &fetch; }
$core[002642] = 07001; $code[002642] = *I02642; sub I02642 { $lac++; goto &fetch; }
$core[002643] = 03136; $code[002643] = *I02643; sub I02643 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002644] = 01251; $code[002644] = *I02644; sub I02644 { $lac += $core[002651]; goto &fetch; }
$core[002645] = 03654; $code[002645] = *I02645; sub I02645 { $core[($df<<12)+$core[1452]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1452]] = *emul8; goto &fetch; }
$core[002646] = 01252; $code[002646] = *I02646; sub I02646 { $lac += $core[002652]; goto &fetch; }
$core[002647] = 03431; $code[002647] = *I02647; sub I02647 { $core[($df<<12)+$core[25]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[25]] = *emul8; goto &fetch; }
$core[002650] = 05431; $code[002650] = *I02650; sub I02650 { $pc = ($ib<<12)+$core[25]; $inh = 0; goto &fetch; }
$core[002651] = 05545; $code[002651] = *D02651; sub D02651 { $pc = ($ib<<12)+$core[101]; $inh = 0; goto &fetch; }
$core[002652] = 04446; $code[002652] = *D02652; sub D02652 { $core[($ib<<12)+$core[38]] = 02653; $pc = ($ib<<12)+$core[38]+1; $code[($ib<<12)+$core[38]] = *emul8; $inh = 0; goto &fetch; }
$core[002653] = 07701; $code[002653] = *D02653; sub D02653 { &emul8; goto &fetch; }
$core[002654] = 07700; $code[002654] = *P02654; sub P02654 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002660] = 01136; $code[002660] = *L02660; sub L02660 { $lac += $core[000136]; goto &fetch; }
$core[002661] = 01303; $code[002661] = *I02661; sub I02661 { $lac += $core[002703]; goto &fetch; }
$core[002662] = 07440; $code[002662] = *I02662; sub I02662 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002663] = 07402; $code[002663] = *I02663; sub I02663 { $hlt = 1; goto &fetch; }
$core[002664] = 01446; $code[002664] = *I02664; sub I02664 { $lac += $core[($df<<12)+$core[38]]; goto &fetch; }
$core[002665] = 01046; $code[002665] = *I02665; sub I02665 { $lac += $core[000046]; goto &fetch; }
$core[002666] = 07440; $code[002666] = *I02666; sub I02666 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002667] = 07402; $code[002667] = *I02667; sub I02667 { $hlt = 1; goto &fetch; }
$core[002670] = 03446; $code[002670] = *I02670; sub I02670 { $core[($df<<12)+$core[38]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[38]] = *emul8; goto &fetch; }
$core[002671] = 01136; $code[002671] = *I02671; sub I02671 { $lac += $core[000136]; goto &fetch; }
$core[002672] = 07001; $code[002672] = *I02672; sub I02672 { $lac++; goto &fetch; }
$core[002673] = 03136; $code[002673] = *I02673; sub I02673 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002674] = 01301; $code[002674] = *I02674; sub I02674 { $lac += $core[002701]; goto &fetch; }
$core[002675] = 03704; $code[002675] = *I02675; sub I02675 { $core[($df<<12)+$core[1476]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1476]] = *emul8; goto &fetch; }
$core[002676] = 01302; $code[002676] = *I02676; sub I02676 { $lac += $core[002702]; goto &fetch; }
$core[002677] = 03432; $code[002677] = *I02677; sub I02677 { $core[($df<<12)+$core[26]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[26]] = *emul8; goto &fetch; }
$core[002700] = 05432; $code[002700] = *I02700; sub I02700 { $pc = ($ib<<12)+$core[26]; $inh = 0; goto &fetch; }
$core[002701] = 05546; $code[002701] = *D02701; sub D02701 { $pc = ($ib<<12)+$core[102]; $inh = 0; goto &fetch; }
$core[002702] = 04445; $code[002702] = *D02702; sub D02702 { $core[($ib<<12)+$core[37]] = 02703; $pc = ($ib<<12)+$core[37]+1; $code[($ib<<12)+$core[37]] = *emul8; $inh = 0; goto &fetch; }
$core[002703] = 07700; $code[002703] = *D02703; sub D02703 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002704] = 07600; $code[002704] = *P02704; sub P02704 { $lac &= 010000; goto &fetch; }
$core[002710] = 01136; $code[002710] = *L02710; sub L02710 { $lac += $core[000136]; goto &fetch; }
$core[002711] = 01333; $code[002711] = *I02711; sub I02711 { $lac += $core[002733]; goto &fetch; }
$core[002712] = 07440; $code[002712] = *I02712; sub I02712 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002713] = 07402; $code[002713] = *I02713; sub I02713 { $hlt = 1; goto &fetch; }
$core[002714] = 01445; $code[002714] = *I02714; sub I02714 { $lac += $core[($df<<12)+$core[37]]; goto &fetch; }
$core[002715] = 01045; $code[002715] = *I02715; sub I02715 { $lac += $core[000045]; goto &fetch; }
$core[002716] = 07440; $code[002716] = *I02716; sub I02716 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002717] = 07402; $code[002717] = *I02717; sub I02717 { $hlt = 1; goto &fetch; }
$core[002720] = 03445; $code[002720] = *I02720; sub I02720 { $core[($df<<12)+$core[37]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[37]] = *emul8; goto &fetch; }
$core[002721] = 01136; $code[002721] = *I02721; sub I02721 { $lac += $core[000136]; goto &fetch; }
$core[002722] = 07001; $code[002722] = *I02722; sub I02722 { $lac++; goto &fetch; }
$core[002723] = 03136; $code[002723] = *I02723; sub I02723 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002724] = 01331; $code[002724] = *I02724; sub I02724 { $lac += $core[002731]; goto &fetch; }
$core[002725] = 03734; $code[002725] = *I02725; sub I02725 { $core[($df<<12)+$core[1500]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1500]] = *emul8; goto &fetch; }
$core[002726] = 01332; $code[002726] = *I02726; sub I02726 { $lac += $core[002732]; goto &fetch; }
$core[002727] = 03433; $code[002727] = *I02727; sub I02727 { $core[($df<<12)+$core[27]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[27]] = *emul8; goto &fetch; }
$core[002730] = 05433; $code[002730] = *I02730; sub I02730 { $pc = ($ib<<12)+$core[27]; $inh = 0; goto &fetch; }
$core[002731] = 05547; $code[002731] = *D02731; sub D02731 { $pc = ($ib<<12)+$core[103]; $inh = 0; goto &fetch; }
$core[002732] = 04444; $code[002732] = *D02732; sub D02732 { $core[($ib<<12)+$core[36]] = 02733; $pc = ($ib<<12)+$core[36]+1; $code[($ib<<12)+$core[36]] = *emul8; $inh = 0; goto &fetch; }
$core[002733] = 07677; $code[002733] = *D02733; sub D02733 { &emul8; goto &fetch; }
$core[002734] = 07400; $code[002734] = *P02734; sub P02734 { goto &fetch; }
$core[002740] = 01136; $code[002740] = *L02740; sub L02740 { $lac += $core[000136]; goto &fetch; }
$core[002741] = 01363; $code[002741] = *I02741; sub I02741 { $lac += $core[002763]; goto &fetch; }
$core[002742] = 07440; $code[002742] = *I02742; sub I02742 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002743] = 07402; $code[002743] = *I02743; sub I02743 { $hlt = 1; goto &fetch; }
$core[002744] = 01444; $code[002744] = *I02744; sub I02744 { $lac += $core[($df<<12)+$core[36]]; goto &fetch; }
$core[002745] = 01044; $code[002745] = *I02745; sub I02745 { $lac += $core[000044]; goto &fetch; }
$core[002746] = 07440; $code[002746] = *I02746; sub I02746 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002747] = 07402; $code[002747] = *I02747; sub I02747 { $hlt = 1; goto &fetch; }
$core[002750] = 03444; $code[002750] = *I02750; sub I02750 { $core[($df<<12)+$core[36]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[36]] = *emul8; goto &fetch; }
$core[002751] = 01136; $code[002751] = *I02751; sub I02751 { $lac += $core[000136]; goto &fetch; }
$core[002752] = 07001; $code[002752] = *I02752; sub I02752 { $lac++; goto &fetch; }
$core[002753] = 03136; $code[002753] = *I02753; sub I02753 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[002754] = 01361; $code[002754] = *I02754; sub I02754 { $lac += $core[002761]; goto &fetch; }
$core[002755] = 03764; $code[002755] = *I02755; sub I02755 { $core[($df<<12)+$core[1524]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1524]] = *emul8; goto &fetch; }
$core[002756] = 01362; $code[002756] = *I02756; sub I02756 { $lac += $core[002762]; goto &fetch; }
$core[002757] = 03434; $code[002757] = *I02757; sub I02757 { $core[($df<<12)+$core[28]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[28]] = *emul8; goto &fetch; }
$core[002760] = 05434; $code[002760] = *I02760; sub I02760 { $pc = ($ib<<12)+$core[28]; $inh = 0; goto &fetch; }
$core[002761] = 05550; $code[002761] = *D02761; sub D02761 { $pc = ($ib<<12)+$core[104]; $inh = 0; goto &fetch; }
$core[002762] = 04443; $code[002762] = *D02762; sub D02762 { $core[($ib<<12)+$core[35]] = 02763; $pc = ($ib<<12)+$core[35]+1; $code[($ib<<12)+$core[35]] = *emul8; $inh = 0; goto &fetch; }
$core[002763] = 07676; $code[002763] = *D02763; sub D02763 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002764] = 07000; $code[002764] = *P02764; sub P02764 { goto &fetch; }
$core[003000] = 01136; $code[003000] = *L03000; sub L03000 { $lac += $core[000136]; goto &fetch; }
$core[003001] = 01223; $code[003001] = *I03001; sub I03001 { $lac += $core[003023]; goto &fetch; }
$core[003002] = 07440; $code[003002] = *I03002; sub I03002 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003003] = 07402; $code[003003] = *I03003; sub I03003 { $hlt = 1; goto &fetch; }
$core[003004] = 01443; $code[003004] = *I03004; sub I03004 { $lac += $core[($df<<12)+$core[35]]; goto &fetch; }
$core[003005] = 01043; $code[003005] = *I03005; sub I03005 { $lac += $core[000043]; goto &fetch; }
$core[003006] = 07440; $code[003006] = *I03006; sub I03006 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003007] = 07402; $code[003007] = *I03007; sub I03007 { $hlt = 1; goto &fetch; }
$core[003010] = 03443; $code[003010] = *I03010; sub I03010 { $core[($df<<12)+$core[35]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[35]] = *emul8; goto &fetch; }
$core[003011] = 01136; $code[003011] = *I03011; sub I03011 { $lac += $core[000136]; goto &fetch; }
$core[003012] = 07001; $code[003012] = *I03012; sub I03012 { $lac++; goto &fetch; }
$core[003013] = 03136; $code[003013] = *I03013; sub I03013 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003014] = 01221; $code[003014] = *I03014; sub I03014 { $lac += $core[003021]; goto &fetch; }
$core[003015] = 03624; $code[003015] = *I03015; sub I03015 { $core[($df<<12)+$core[1556]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1556]] = *emul8; goto &fetch; }
$core[003016] = 01222; $code[003016] = *I03016; sub I03016 { $lac += $core[003022]; goto &fetch; }
$core[003017] = 03435; $code[003017] = *I03017; sub I03017 { $core[($df<<12)+$core[29]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[29]] = *emul8; goto &fetch; }
$core[003020] = 05435; $code[003020] = *I03020; sub I03020 { $pc = ($ib<<12)+$core[29]; $inh = 0; goto &fetch; }
$core[003021] = 05551; $code[003021] = *D03021; sub D03021 { $pc = ($ib<<12)+$core[105]; $inh = 0; goto &fetch; }
$core[003022] = 04442; $code[003022] = *D03022; sub D03022 { $core[($ib<<12)+$core[34]] = 03023; $pc = ($ib<<12)+$core[34]+1; $code[($ib<<12)+$core[34]] = *emul8; $inh = 0; goto &fetch; }
$core[003023] = 07675; $code[003023] = *D03023; sub D03023 { &emul8; goto &fetch; }
$core[003024] = 06000; $code[003024] = *P03024; sub P03024 { &emul8; goto &fetch; }
$core[003030] = 01136; $code[003030] = *L03030; sub L03030 { $lac += $core[000136]; goto &fetch; }
$core[003031] = 01253; $code[003031] = *I03031; sub I03031 { $lac += $core[003053]; goto &fetch; }
$core[003032] = 07440; $code[003032] = *I03032; sub I03032 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003033] = 07402; $code[003033] = *I03033; sub I03033 { $hlt = 1; goto &fetch; }
$core[003034] = 01442; $code[003034] = *I03034; sub I03034 { $lac += $core[($df<<12)+$core[34]]; goto &fetch; }
$core[003035] = 01042; $code[003035] = *I03035; sub I03035 { $lac += $core[000042]; goto &fetch; }
$core[003036] = 07440; $code[003036] = *I03036; sub I03036 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003037] = 07402; $code[003037] = *I03037; sub I03037 { $hlt = 1; goto &fetch; }
$core[003040] = 03442; $code[003040] = *I03040; sub I03040 { $core[($df<<12)+$core[34]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[34]] = *emul8; goto &fetch; }
$core[003041] = 01136; $code[003041] = *I03041; sub I03041 { $lac += $core[000136]; goto &fetch; }
$core[003042] = 07001; $code[003042] = *I03042; sub I03042 { $lac++; goto &fetch; }
$core[003043] = 03136; $code[003043] = *I03043; sub I03043 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003044] = 01251; $code[003044] = *I03044; sub I03044 { $lac += $core[003051]; goto &fetch; }
$core[003045] = 03654; $code[003045] = *I03045; sub I03045 { $core[($df<<12)+$core[1580]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1580]] = *emul8; goto &fetch; }
$core[003046] = 01252; $code[003046] = *I03046; sub I03046 { $lac += $core[003052]; goto &fetch; }
$core[003047] = 03437; $code[003047] = *I03047; sub I03047 { $core[($df<<12)+$core[31]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[31]] = *emul8; goto &fetch; }
$core[003050] = 05437; $code[003050] = *I03050; sub I03050 { $pc = ($ib<<12)+$core[31]; $inh = 0; goto &fetch; }
$core[003051] = 05552; $code[003051] = *D03051; sub D03051 { $pc = ($ib<<12)+$core[106]; $inh = 0; goto &fetch; }
$core[003052] = 04436; $code[003052] = *D03052; sub D03052 { $core[($ib<<12)+$core[30]] = 03053; $pc = ($ib<<12)+$core[30]+1; $code[($ib<<12)+$core[30]] = *emul8; $inh = 0; goto &fetch; }
$core[003053] = 07674; $code[003053] = *D03053; sub D03053 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003054] = 04001; $code[003054] = *P03054; sub P03054 { $core[000001] = 03055; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[003060] = 01136; $code[003060] = *L03060; sub L03060 { $lac += $core[000136]; goto &fetch; }
$core[003061] = 01303; $code[003061] = *I03061; sub I03061 { $lac += $core[003103]; goto &fetch; }
$core[003062] = 07440; $code[003062] = *I03062; sub I03062 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003063] = 07402; $code[003063] = *I03063; sub I03063 { $hlt = 1; goto &fetch; }
$core[003064] = 01436; $code[003064] = *I03064; sub I03064 { $lac += $core[($df<<12)+$core[30]]; goto &fetch; }
$core[003065] = 01036; $code[003065] = *I03065; sub I03065 { $lac += $core[000036]; goto &fetch; }
$core[003066] = 07440; $code[003066] = *I03066; sub I03066 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003067] = 07402; $code[003067] = *I03067; sub I03067 { $hlt = 1; goto &fetch; }
$core[003070] = 03436; $code[003070] = *I03070; sub I03070 { $core[($df<<12)+$core[30]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[30]] = *emul8; goto &fetch; }
$core[003071] = 01136; $code[003071] = *I03071; sub I03071 { $lac += $core[000136]; goto &fetch; }
$core[003072] = 07001; $code[003072] = *I03072; sub I03072 { $lac++; goto &fetch; }
$core[003073] = 03136; $code[003073] = *I03073; sub I03073 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003074] = 01301; $code[003074] = *I03074; sub I03074 { $lac += $core[003101]; goto &fetch; }
$core[003075] = 03704; $code[003075] = *I03075; sub I03075 { $core[($df<<12)+$core[1604]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1604]] = *emul8; goto &fetch; }
$core[003076] = 01302; $code[003076] = *I03076; sub I03076 { $lac += $core[003102]; goto &fetch; }
$core[003077] = 03442; $code[003077] = *I03077; sub I03077 { $core[($df<<12)+$core[34]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[34]] = *emul8; goto &fetch; }
$core[003100] = 05442; $code[003100] = *I03100; sub I03100 { $pc = ($ib<<12)+$core[34]; $inh = 0; goto &fetch; }
$core[003101] = 05553; $code[003101] = *D03101; sub D03101 { $pc = ($ib<<12)+$core[107]; $inh = 0; goto &fetch; }
$core[003102] = 04435; $code[003102] = *D03102; sub D03102 { $core[($ib<<12)+$core[29]] = 03103; $pc = ($ib<<12)+$core[29]+1; $code[($ib<<12)+$core[29]] = *emul8; $inh = 0; goto &fetch; }
$core[003103] = 07673; $code[003103] = *D03103; sub D03103 { &emul8; goto &fetch; }
$core[003104] = 02001; $code[003104] = *P03104; sub P03104 { if (++$core[000001] == 010000) { $core[000001] = 0; $pc++; }$code[000001] = *emul8; goto &fetch; }
$core[003110] = 01136; $code[003110] = *L03110; sub L03110 { $lac += $core[000136]; goto &fetch; }
$core[003111] = 01333; $code[003111] = *I03111; sub I03111 { $lac += $core[003133]; goto &fetch; }
$core[003112] = 07440; $code[003112] = *I03112; sub I03112 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003113] = 07402; $code[003113] = *I03113; sub I03113 { $hlt = 1; goto &fetch; }
$core[003114] = 01435; $code[003114] = *I03114; sub I03114 { $lac += $core[($df<<12)+$core[29]]; goto &fetch; }
$core[003115] = 01035; $code[003115] = *I03115; sub I03115 { $lac += $core[000035]; goto &fetch; }
$core[003116] = 07440; $code[003116] = *I03116; sub I03116 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003117] = 07402; $code[003117] = *I03117; sub I03117 { $hlt = 1; goto &fetch; }
$core[003120] = 03435; $code[003120] = *I03120; sub I03120 { $core[($df<<12)+$core[29]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[29]] = *emul8; goto &fetch; }
$core[003121] = 01136; $code[003121] = *I03121; sub I03121 { $lac += $core[000136]; goto &fetch; }
$core[003122] = 07001; $code[003122] = *I03122; sub I03122 { $lac++; goto &fetch; }
$core[003123] = 03136; $code[003123] = *I03123; sub I03123 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003124] = 01331; $code[003124] = *I03124; sub I03124 { $lac += $core[003131]; goto &fetch; }
$core[003125] = 03734; $code[003125] = *I03125; sub I03125 { $core[($df<<12)+$core[1628]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1628]] = *emul8; goto &fetch; }
$core[003126] = 01332; $code[003126] = *I03126; sub I03126 { $lac += $core[003132]; goto &fetch; }
$core[003127] = 03443; $code[003127] = *I03127; sub I03127 { $core[($df<<12)+$core[35]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[35]] = *emul8; goto &fetch; }
$core[003130] = 05443; $code[003130] = *I03130; sub I03130 { $pc = ($ib<<12)+$core[35]; $inh = 0; goto &fetch; }
$core[003131] = 05554; $code[003131] = *D03131; sub D03131 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[003132] = 04434; $code[003132] = *D03132; sub D03132 { $core[($ib<<12)+$core[28]] = 03133; $pc = ($ib<<12)+$core[28]+1; $code[($ib<<12)+$core[28]] = *emul8; $inh = 0; goto &fetch; }
$core[003133] = 07672; $code[003133] = *D03133; sub D03133 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[003134] = 01001; $code[003134] = *P03134; sub P03134 { $lac += $core[000001]; goto &fetch; }
$core[003140] = 01136; $code[003140] = *L03140; sub L03140 { $lac += $core[000136]; goto &fetch; }
$core[003141] = 01363; $code[003141] = *I03141; sub I03141 { $lac += $core[003163]; goto &fetch; }
$core[003142] = 07440; $code[003142] = *I03142; sub I03142 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003143] = 07402; $code[003143] = *I03143; sub I03143 { $hlt = 1; goto &fetch; }
$core[003144] = 01434; $code[003144] = *I03144; sub I03144 { $lac += $core[($df<<12)+$core[28]]; goto &fetch; }
$core[003145] = 01034; $code[003145] = *I03145; sub I03145 { $lac += $core[000034]; goto &fetch; }
$core[003146] = 07440; $code[003146] = *I03146; sub I03146 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003147] = 07402; $code[003147] = *I03147; sub I03147 { $hlt = 1; goto &fetch; }
$core[003150] = 03434; $code[003150] = *I03150; sub I03150 { $core[($df<<12)+$core[28]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[28]] = *emul8; goto &fetch; }
$core[003151] = 01136; $code[003151] = *I03151; sub I03151 { $lac += $core[000136]; goto &fetch; }
$core[003152] = 07001; $code[003152] = *I03152; sub I03152 { $lac++; goto &fetch; }
$core[003153] = 03136; $code[003153] = *I03153; sub I03153 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003154] = 01361; $code[003154] = *I03154; sub I03154 { $lac += $core[003161]; goto &fetch; }
$core[003155] = 03764; $code[003155] = *I03155; sub I03155 { $core[($df<<12)+$core[1652]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1652]] = *emul8; goto &fetch; }
$core[003156] = 01362; $code[003156] = *I03156; sub I03156 { $lac += $core[003162]; goto &fetch; }
$core[003157] = 03444; $code[003157] = *I03157; sub I03157 { $core[($df<<12)+$core[36]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[36]] = *emul8; goto &fetch; }
$core[003160] = 05444; $code[003160] = *I03160; sub I03160 { $pc = ($ib<<12)+$core[36]; $inh = 0; goto &fetch; }
$core[003161] = 05555; $code[003161] = *D03161; sub D03161 { $pc = ($ib<<12)+$core[109]; $inh = 0; goto &fetch; }
$core[003162] = 04433; $code[003162] = *D03162; sub D03162 { $core[($ib<<12)+$core[27]] = 03163; $pc = ($ib<<12)+$core[27]+1; $code[($ib<<12)+$core[27]] = *emul8; $inh = 0; goto &fetch; }
$core[003163] = 07671; $code[003163] = *D03163; sub D03163 { &emul8; goto &fetch; }
$core[003164] = 00401; $code[003164] = *P03164; sub P03164 { $lac &= (010000|$core[($df<<12)+$core[1]]); goto &fetch; }
$core[003200] = 01136; $code[003200] = *L03200; sub L03200 { $lac += $core[000136]; goto &fetch; }
$core[003201] = 01223; $code[003201] = *D03201; sub D03201 { $lac += $core[003223]; goto &fetch; }
$core[003202] = 07440; $code[003202] = *I03202; sub I03202 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003203] = 07402; $code[003203] = *I03203; sub I03203 { $hlt = 1; goto &fetch; }
$core[003204] = 01433; $code[003204] = *I03204; sub I03204 { $lac += $core[($df<<12)+$core[27]]; goto &fetch; }
$core[003205] = 01033; $code[003205] = *I03205; sub I03205 { $lac += $core[000033]; goto &fetch; }
$core[003206] = 07440; $code[003206] = *I03206; sub I03206 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003207] = 07402; $code[003207] = *I03207; sub I03207 { $hlt = 1; goto &fetch; }
$core[003210] = 03433; $code[003210] = *I03210; sub I03210 { $core[($df<<12)+$core[27]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[27]] = *emul8; goto &fetch; }
$core[003211] = 01136; $code[003211] = *I03211; sub I03211 { $lac += $core[000136]; goto &fetch; }
$core[003212] = 07001; $code[003212] = *I03212; sub I03212 { $lac++; goto &fetch; }
$core[003213] = 03136; $code[003213] = *I03213; sub I03213 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003214] = 01221; $code[003214] = *I03214; sub I03214 { $lac += $core[003221]; goto &fetch; }
$core[003215] = 03624; $code[003215] = *I03215; sub I03215 { $core[($df<<12)+$core[1684]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1684]] = *emul8; goto &fetch; }
$core[003216] = 01222; $code[003216] = *I03216; sub I03216 { $lac += $core[003222]; goto &fetch; }
$core[003217] = 03445; $code[003217] = *I03217; sub I03217 { $core[($df<<12)+$core[37]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[37]] = *emul8; goto &fetch; }
$core[003220] = 05445; $code[003220] = *I03220; sub I03220 { $pc = ($ib<<12)+$core[37]; $inh = 0; goto &fetch; }
$core[003221] = 05556; $code[003221] = *D03221; sub D03221 { $pc = ($ib<<12)+$core[110]; $inh = 0; goto &fetch; }
$core[003222] = 04432; $code[003222] = *D03222; sub D03222 { $core[($ib<<12)+$core[26]] = 03223; $pc = ($ib<<12)+$core[26]+1; $code[($ib<<12)+$core[26]] = *emul8; $inh = 0; goto &fetch; }
$core[003223] = 07670; $code[003223] = *D03223; sub D03223 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003224] = 00201; $code[003224] = *P03224; sub P03224 { $lac &= (010000|$core[003201]); goto &fetch; }
$core[003230] = 01136; $code[003230] = *L03230; sub L03230 { $lac += $core[000136]; goto &fetch; }
$core[003231] = 01253; $code[003231] = *I03231; sub I03231 { $lac += $core[003253]; goto &fetch; }
$core[003232] = 07440; $code[003232] = *I03232; sub I03232 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003233] = 07402; $code[003233] = *I03233; sub I03233 { $hlt = 1; goto &fetch; }
$core[003234] = 01432; $code[003234] = *I03234; sub I03234 { $lac += $core[($df<<12)+$core[26]]; goto &fetch; }
$core[003235] = 01032; $code[003235] = *I03235; sub I03235 { $lac += $core[000032]; goto &fetch; }
$core[003236] = 07440; $code[003236] = *I03236; sub I03236 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003237] = 07402; $code[003237] = *I03237; sub I03237 { $hlt = 1; goto &fetch; }
$core[003240] = 03432; $code[003240] = *I03240; sub I03240 { $core[($df<<12)+$core[26]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[26]] = *emul8; goto &fetch; }
$core[003241] = 01136; $code[003241] = *I03241; sub I03241 { $lac += $core[000136]; goto &fetch; }
$core[003242] = 07001; $code[003242] = *I03242; sub I03242 { $lac++; goto &fetch; }
$core[003243] = 03136; $code[003243] = *I03243; sub I03243 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003244] = 01251; $code[003244] = *I03244; sub I03244 { $lac += $core[003251]; goto &fetch; }
$core[003245] = 03654; $code[003245] = *I03245; sub I03245 { $core[($df<<12)+$core[1708]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1708]] = *emul8; goto &fetch; }
$core[003246] = 01252; $code[003246] = *I03246; sub I03246 { $lac += $core[003252]; goto &fetch; }
$core[003247] = 03446; $code[003247] = *I03247; sub I03247 { $core[($df<<12)+$core[38]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[38]] = *emul8; goto &fetch; }
$core[003250] = 05446; $code[003250] = *I03250; sub I03250 { $pc = ($ib<<12)+$core[38]; $inh = 0; goto &fetch; }
$core[003251] = 05557; $code[003251] = *D03251; sub D03251 { $pc = ($ib<<12)+$core[111]; $inh = 0; goto &fetch; }
$core[003252] = 04431; $code[003252] = *D03252; sub D03252 { $core[($ib<<12)+$core[25]] = 03253; $pc = ($ib<<12)+$core[25]+1; $code[($ib<<12)+$core[25]] = *emul8; $inh = 0; goto &fetch; }
$core[003253] = 07667; $code[003253] = *D03253; sub D03253 { &emul8; goto &fetch; }
$core[003254] = 00101; $code[003254] = *P03254; sub P03254 { $lac &= (010000|$core[000101]); goto &fetch; }
$core[003260] = 01136; $code[003260] = *L03260; sub L03260 { $lac += $core[000136]; goto &fetch; }
$core[003261] = 01303; $code[003261] = *I03261; sub I03261 { $lac += $core[003303]; goto &fetch; }
$core[003262] = 07440; $code[003262] = *I03262; sub I03262 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003263] = 07402; $code[003263] = *I03263; sub I03263 { $hlt = 1; goto &fetch; }
$core[003264] = 01431; $code[003264] = *I03264; sub I03264 { $lac += $core[($df<<12)+$core[25]]; goto &fetch; }
$core[003265] = 01031; $code[003265] = *I03265; sub I03265 { $lac += $core[000031]; goto &fetch; }
$core[003266] = 07440; $code[003266] = *I03266; sub I03266 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003267] = 07402; $code[003267] = *I03267; sub I03267 { $hlt = 1; goto &fetch; }
$core[003270] = 03431; $code[003270] = *I03270; sub I03270 { $core[($df<<12)+$core[25]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[25]] = *emul8; goto &fetch; }
$core[003271] = 01136; $code[003271] = *I03271; sub I03271 { $lac += $core[000136]; goto &fetch; }
$core[003272] = 07001; $code[003272] = *I03272; sub I03272 { $lac++; goto &fetch; }
$core[003273] = 03136; $code[003273] = *I03273; sub I03273 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003274] = 01301; $code[003274] = *I03274; sub I03274 { $lac += $core[003301]; goto &fetch; }
$core[003275] = 03704; $code[003275] = *I03275; sub I03275 { $core[($df<<12)+$core[1732]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1732]] = *emul8; goto &fetch; }
$core[003276] = 01302; $code[003276] = *I03276; sub I03276 { $lac += $core[003302]; goto &fetch; }
$core[003277] = 03447; $code[003277] = *I03277; sub I03277 { $core[($df<<12)+$core[39]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[39]] = *emul8; goto &fetch; }
$core[003300] = 05447; $code[003300] = *I03300; sub I03300 { $pc = ($ib<<12)+$core[39]; $inh = 0; goto &fetch; }
$core[003301] = 05560; $code[003301] = *D03301; sub D03301 { $pc = ($ib<<12)+$core[112]; $inh = 0; goto &fetch; }
$core[003302] = 04430; $code[003302] = *D03302; sub D03302 { $core[($ib<<12)+$core[24]] = 03303; $pc = ($ib<<12)+$core[24]+1; $code[($ib<<12)+$core[24]] = *emul8; $inh = 0; goto &fetch; }
$core[003303] = 07666; $code[003303] = *D03303; sub D03303 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[003304] = 00041; $code[003304] = *P03304; sub P03304 { $lac &= (010000|$core[000041]); goto &fetch; }
$core[003310] = 01136; $code[003310] = *L03310; sub L03310 { $lac += $core[000136]; goto &fetch; }
$core[003311] = 01333; $code[003311] = *I03311; sub I03311 { $lac += $core[003333]; goto &fetch; }
$core[003312] = 07440; $code[003312] = *I03312; sub I03312 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003313] = 07402; $code[003313] = *I03313; sub I03313 { $hlt = 1; goto &fetch; }
$core[003314] = 01430; $code[003314] = *I03314; sub I03314 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[003315] = 01030; $code[003315] = *I03315; sub I03315 { $lac += $core[000030]; goto &fetch; }
$core[003316] = 07440; $code[003316] = *I03316; sub I03316 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003317] = 07402; $code[003317] = *I03317; sub I03317 { $hlt = 1; goto &fetch; }
$core[003320] = 03430; $code[003320] = *I03320; sub I03320 { $core[($df<<12)+$core[24]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[003321] = 01136; $code[003321] = *I03321; sub I03321 { $lac += $core[000136]; goto &fetch; }
$core[003322] = 07001; $code[003322] = *I03322; sub I03322 { $lac++; goto &fetch; }
$core[003323] = 03136; $code[003323] = *I03323; sub I03323 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003324] = 01331; $code[003324] = *I03324; sub I03324 { $lac += $core[003331]; goto &fetch; }
$core[003325] = 03734; $code[003325] = *I03325; sub I03325 { $core[($df<<12)+$core[1756]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1756]] = *emul8; goto &fetch; }
$core[003326] = 01332; $code[003326] = *I03326; sub I03326 { $lac += $core[003332]; goto &fetch; }
$core[003327] = 03450; $code[003327] = *I03327; sub I03327 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[003330] = 05450; $code[003330] = *I03330; sub I03330 { $pc = ($ib<<12)+$core[40]; $inh = 0; goto &fetch; }
$core[003331] = 05561; $code[003331] = *D03331; sub D03331 { $pc = ($ib<<12)+$core[113]; $inh = 0; goto &fetch; }
$core[003332] = 04427; $code[003332] = *D03332; sub D03332 { $core[($ib<<12)+$core[23]] = 03333; $pc = ($ib<<12)+$core[23]+1; $code[($ib<<12)+$core[23]] = *emul8; $inh = 0; goto &fetch; }
$core[003333] = 07665; $code[003333] = *D03333; sub D03333 { &emul8; goto &fetch; }
$core[003334] = 00021; $code[003334] = *P03334; sub P03334 { $lac &= (010000|$core[000021]); goto &fetch; }
$core[003340] = 01136; $code[003340] = *L03340; sub L03340 { $lac += $core[000136]; goto &fetch; }
$core[003341] = 01363; $code[003341] = *I03341; sub I03341 { $lac += $core[003363]; goto &fetch; }
$core[003342] = 07440; $code[003342] = *I03342; sub I03342 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003343] = 07402; $code[003343] = *I03343; sub I03343 { $hlt = 1; goto &fetch; }
$core[003344] = 01427; $code[003344] = *I03344; sub I03344 { $lac += $core[($df<<12)+$core[23]]; goto &fetch; }
$core[003345] = 01027; $code[003345] = *I03345; sub I03345 { $lac += $core[000027]; goto &fetch; }
$core[003346] = 07440; $code[003346] = *I03346; sub I03346 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003347] = 07402; $code[003347] = *I03347; sub I03347 { $hlt = 1; goto &fetch; }
$core[003350] = 03427; $code[003350] = *I03350; sub I03350 { $core[($df<<12)+$core[23]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[23]] = *emul8; goto &fetch; }
$core[003351] = 01136; $code[003351] = *I03351; sub I03351 { $lac += $core[000136]; goto &fetch; }
$core[003352] = 07001; $code[003352] = *I03352; sub I03352 { $lac++; goto &fetch; }
$core[003353] = 03136; $code[003353] = *I03353; sub I03353 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003354] = 01361; $code[003354] = *I03354; sub I03354 { $lac += $core[003361]; goto &fetch; }
$core[003355] = 03764; $code[003355] = *I03355; sub I03355 { $core[($df<<12)+$core[1780]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1780]] = *emul8; goto &fetch; }
$core[003356] = 01362; $code[003356] = *I03356; sub I03356 { $lac += $core[003362]; goto &fetch; }
$core[003357] = 03451; $code[003357] = *I03357; sub I03357 { $core[($df<<12)+$core[41]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[41]] = *emul8; goto &fetch; }
$core[003360] = 05451; $code[003360] = *I03360; sub I03360 { $pc = ($ib<<12)+$core[41]; $inh = 0; goto &fetch; }
$core[003361] = 05562; $code[003361] = *D03361; sub D03361 { $pc = ($ib<<12)+$core[114]; $inh = 0; goto &fetch; }
$core[003362] = 04426; $code[003362] = *D03362; sub D03362 { $core[($ib<<12)+$core[22]] = 03363; $pc = ($ib<<12)+$core[22]+1; $code[($ib<<12)+$core[22]] = *emul8; $inh = 0; goto &fetch; }
$core[003363] = 07664; $code[003363] = *D03363; sub D03363 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[003364] = 00011; $code[003364] = *P03364; sub P03364 { $lac &= (010000|$core[000011]); goto &fetch; }
$core[003400] = 01136; $code[003400] = *L03400; sub L03400 { $lac += $core[000136]; goto &fetch; }
$core[003401] = 01223; $code[003401] = *I03401; sub I03401 { $lac += $core[003423]; goto &fetch; }
$core[003402] = 07440; $code[003402] = *I03402; sub I03402 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003403] = 07402; $code[003403] = *I03403; sub I03403 { $hlt = 1; goto &fetch; }
$core[003404] = 01426; $code[003404] = *I03404; sub I03404 { $lac += $core[($df<<12)+$core[22]]; goto &fetch; }
$core[003405] = 01026; $code[003405] = *I03405; sub I03405 { $lac += $core[000026]; goto &fetch; }
$core[003406] = 07440; $code[003406] = *I03406; sub I03406 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003407] = 07402; $code[003407] = *D03407; sub D03407 { $hlt = 1; goto &fetch; }
$core[003410] = 03426; $code[003410] = *D03410; sub D03410 { $core[($df<<12)+$core[22]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[22]] = *emul8; goto &fetch; }
$core[003411] = 01136; $code[003411] = *I03411; sub I03411 { $lac += $core[000136]; goto &fetch; }
$core[003412] = 07001; $code[003412] = *I03412; sub I03412 { $lac++; goto &fetch; }
$core[003413] = 03136; $code[003413] = *I03413; sub I03413 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003414] = 01221; $code[003414] = *I03414; sub I03414 { $lac += $core[003421]; goto &fetch; }
$core[003415] = 03624; $code[003415] = *I03415; sub I03415 { $core[($df<<12)+$core[1812]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1812]] = *emul8; goto &fetch; }
$core[003416] = 01222; $code[003416] = *I03416; sub I03416 { $lac += $core[003422]; goto &fetch; }
$core[003417] = 03452; $code[003417] = *I03417; sub I03417 { $core[($df<<12)+$core[42]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[42]] = *emul8; goto &fetch; }
$core[003420] = 05452; $code[003420] = *I03420; sub I03420 { $pc = ($ib<<12)+$core[42]; $inh = 0; goto &fetch; }
$core[003421] = 05563; $code[003421] = *D03421; sub D03421 { $pc = ($ib<<12)+$core[115]; $inh = 0; goto &fetch; }
$core[003422] = 04425; $code[003422] = *D03422; sub D03422 { $core[($ib<<12)+$core[21]] = 03423; $pc = ($ib<<12)+$core[21]+1; $code[($ib<<12)+$core[21]] = *emul8; $inh = 0; goto &fetch; }
$core[003423] = 07663; $code[003423] = *D03423; sub D03423 { &emul8; goto &fetch; }
$core[003424] = 00005; $code[003424] = *P03424; sub P03424 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[003430] = 01136; $code[003430] = *L03430; sub L03430 { $lac += $core[000136]; goto &fetch; }
$core[003431] = 01253; $code[003431] = *I03431; sub I03431 { $lac += $core[003453]; goto &fetch; }
$core[003432] = 07440; $code[003432] = *I03432; sub I03432 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003433] = 07402; $code[003433] = *I03433; sub I03433 { $hlt = 1; goto &fetch; }
$core[003434] = 01425; $code[003434] = *I03434; sub I03434 { $lac += $core[($df<<12)+$core[21]]; goto &fetch; }
$core[003435] = 01025; $code[003435] = *I03435; sub I03435 { $lac += $core[000025]; goto &fetch; }
$core[003436] = 07440; $code[003436] = *I03436; sub I03436 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003437] = 07402; $code[003437] = *I03437; sub I03437 { $hlt = 1; goto &fetch; }
$core[003440] = 03425; $code[003440] = *I03440; sub I03440 { $core[($df<<12)+$core[21]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[003441] = 01136; $code[003441] = *I03441; sub I03441 { $lac += $core[000136]; goto &fetch; }
$core[003442] = 07001; $code[003442] = *I03442; sub I03442 { $lac++; goto &fetch; }
$core[003443] = 03136; $code[003443] = *I03443; sub I03443 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003444] = 01251; $code[003444] = *I03444; sub I03444 { $lac += $core[003451]; goto &fetch; }
$core[003445] = 03654; $code[003445] = *I03445; sub I03445 { $core[($df<<12)+$core[1836]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1836]] = *emul8; goto &fetch; }
$core[003446] = 01252; $code[003446] = *I03446; sub I03446 { $lac += $core[003452]; goto &fetch; }
$core[003447] = 03453; $code[003447] = *I03447; sub I03447 { $core[($df<<12)+$core[43]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[43]] = *emul8; goto &fetch; }
$core[003450] = 05453; $code[003450] = *I03450; sub I03450 { $pc = ($ib<<12)+$core[43]; $inh = 0; goto &fetch; }
$core[003451] = 05564; $code[003451] = *D03451; sub D03451 { $pc = ($ib<<12)+$core[116]; $inh = 0; goto &fetch; }
$core[003452] = 04424; $code[003452] = *D03452; sub D03452 { $core[($ib<<12)+$core[20]] = 03453; $pc = ($ib<<12)+$core[20]+1; $code[($ib<<12)+$core[20]] = *emul8; $inh = 0; goto &fetch; }
$core[003453] = 07662; $code[003453] = *D03453; sub D03453 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[003454] = 00003; $code[003454] = *P03454; sub P03454 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[003460] = 01136; $code[003460] = *L03460; sub L03460 { $lac += $core[000136]; goto &fetch; }
$core[003461] = 01303; $code[003461] = *I03461; sub I03461 { $lac += $core[003503]; goto &fetch; }
$core[003462] = 07440; $code[003462] = *I03462; sub I03462 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003463] = 07402; $code[003463] = *I03463; sub I03463 { $hlt = 1; goto &fetch; }
$core[003464] = 01424; $code[003464] = *I03464; sub I03464 { $lac += $core[($df<<12)+$core[20]]; goto &fetch; }
$core[003465] = 01024; $code[003465] = *I03465; sub I03465 { $lac += $core[000024]; goto &fetch; }
$core[003466] = 07440; $code[003466] = *I03466; sub I03466 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003467] = 07402; $code[003467] = *I03467; sub I03467 { $hlt = 1; goto &fetch; }
$core[003470] = 03424; $code[003470] = *I03470; sub I03470 { $core[($df<<12)+$core[20]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[20]] = *emul8; goto &fetch; }
$core[003471] = 01136; $code[003471] = *I03471; sub I03471 { $lac += $core[000136]; goto &fetch; }
$core[003472] = 07001; $code[003472] = *I03472; sub I03472 { $lac++; goto &fetch; }
$core[003473] = 03136; $code[003473] = *I03473; sub I03473 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003474] = 01301; $code[003474] = *I03474; sub I03474 { $lac += $core[003501]; goto &fetch; }
$core[003475] = 03424; $code[003475] = *I03475; sub I03475 { $core[($df<<12)+$core[20]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[20]] = *emul8; goto &fetch; }
$core[003476] = 01302; $code[003476] = *I03476; sub I03476 { $lac += $core[003502]; goto &fetch; }
$core[003477] = 03454; $code[003477] = *I03477; sub I03477 { $core[($df<<12)+$core[44]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[44]] = *emul8; goto &fetch; }
$core[003500] = 05454; $code[003500] = *I03500; sub I03500 { $pc = ($ib<<12)+$core[44]; $inh = 0; goto &fetch; }
$core[003501] = 05565; $code[003501] = *D03501; sub D03501 { $pc = ($ib<<12)+$core[117]; $inh = 0; goto &fetch; }
$core[003502] = 04423; $code[003502] = *D03502; sub D03502 { $core[($ib<<12)+$core[19]] = 03503; $pc = ($ib<<12)+$core[19]+1; $code[($ib<<12)+$core[19]] = *emul8; $inh = 0; goto &fetch; }
$core[003503] = 07661; $code[003503] = *D03503; sub D03503 { &emul8; goto &fetch; }
$core[003510] = 01136; $code[003510] = *L03510; sub L03510 { $lac += $core[000136]; goto &fetch; }
$core[003511] = 01333; $code[003511] = *I03511; sub I03511 { $lac += $core[003533]; goto &fetch; }
$core[003512] = 07440; $code[003512] = *I03512; sub I03512 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003513] = 07402; $code[003513] = *I03513; sub I03513 { $hlt = 1; goto &fetch; }
$core[003514] = 01423; $code[003514] = *I03514; sub I03514 { $lac += $core[($df<<12)+$core[19]]; goto &fetch; }
$core[003515] = 01023; $code[003515] = *I03515; sub I03515 { $lac += $core[000023]; goto &fetch; }
$core[003516] = 07440; $code[003516] = *I03516; sub I03516 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003517] = 07402; $code[003517] = *I03517; sub I03517 { $hlt = 1; goto &fetch; }
$core[003520] = 03423; $code[003520] = *I03520; sub I03520 { $core[($df<<12)+$core[19]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[19]] = *emul8; goto &fetch; }
$core[003521] = 01136; $code[003521] = *I03521; sub I03521 { $lac += $core[000136]; goto &fetch; }
$core[003522] = 07001; $code[003522] = *I03522; sub I03522 { $lac++; goto &fetch; }
$core[003523] = 03136; $code[003523] = *I03523; sub I03523 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003524] = 01331; $code[003524] = *I03524; sub I03524 { $lac += $core[003531]; goto &fetch; }
$core[003525] = 03423; $code[003525] = *I03525; sub I03525 { $core[($df<<12)+$core[19]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[19]] = *emul8; goto &fetch; }
$core[003526] = 01332; $code[003526] = *I03526; sub I03526 { $lac += $core[003532]; goto &fetch; }
$core[003527] = 03455; $code[003527] = *I03527; sub I03527 { $core[($df<<12)+$core[45]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[45]] = *emul8; goto &fetch; }
$core[003530] = 05455; $code[003530] = *I03530; sub I03530 { $pc = ($ib<<12)+$core[45]; $inh = 0; goto &fetch; }
$core[003531] = 05566; $code[003531] = *D03531; sub D03531 { $pc = ($ib<<12)+$core[118]; $inh = 0; goto &fetch; }
$core[003532] = 04422; $code[003532] = *D03532; sub D03532 { $core[($ib<<12)+$core[18]] = 03533; $pc = ($ib<<12)+$core[18]+1; $code[($ib<<12)+$core[18]] = *emul8; $inh = 0; goto &fetch; }
$core[003533] = 07660; $code[003533] = *D03533; sub D03533 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003540] = 01136; $code[003540] = *L03540; sub L03540 { $lac += $core[000136]; goto &fetch; }
$core[003541] = 01370; $code[003541] = *I03541; sub I03541 { $lac += $core[003570]; goto &fetch; }
$core[003542] = 07440; $code[003542] = *I03542; sub I03542 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003543] = 07402; $code[003543] = *I03543; sub I03543 { $hlt = 1; goto &fetch; }
$core[003544] = 01422; $code[003544] = *I03544; sub I03544 { $lac += $core[($df<<12)+$core[18]]; goto &fetch; }
$core[003545] = 01022; $code[003545] = *I03545; sub I03545 { $lac += $core[000022]; goto &fetch; }
$core[003546] = 07440; $code[003546] = *I03546; sub I03546 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003547] = 07402; $code[003547] = *I03547; sub I03547 { $hlt = 1; goto &fetch; }
$core[003550] = 03422; $code[003550] = *I03550; sub I03550 { $core[($df<<12)+$core[18]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[18]] = *emul8; goto &fetch; }
$core[003551] = 01371; $code[003551] = *I03551; sub I03551 { $lac += $core[003571]; goto &fetch; }
$core[003552] = 07001; $code[003552] = *I03552; sub I03552 { $lac++; goto &fetch; }
$core[003553] = 03371; $code[003553] = *I03553; sub I03553 { $core[003571] = $lac & 07777; $lac &= 010000; $code[003571] = *emul8; goto &fetch; }
$core[003554] = 01371; $code[003554] = *I03554; sub I03554 { $lac += $core[003571]; goto &fetch; }
$core[003555] = 01372; $code[003555] = *I03555; sub I03555 { $lac += $core[003572]; goto &fetch; }
$core[003556] = 07640; $code[003556] = *I03556; sub I03556 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003557] = 05766; $code[003557] = *I03557; sub I03557 { $pc = ($ib<<12)+$core[1910]; $inh = 0; goto &fetch; }
$core[003560] = 03371; $code[003560] = *I03560; sub I03560 { $core[003571] = $lac & 07777; $lac &= 010000; $code[003571] = *emul8; goto &fetch; }
$core[003561] = 01367; $code[003561] = *I03561; sub I03561 { $lac += $core[003567]; goto &fetch; }
$core[003562] = 06046; $code[003562] = *I03562; sub I03562 { &emul8; goto &fetch; }
$core[003563] = 06041; $code[003563] = *L03563; sub L03563 { &emul8; goto &fetch; }
$core[003564] = 05363; $code[003564] = *I03564; sub I03564 { $pc = 003563; $inh = 0; goto &fetch; }
$core[003565] = 05766; $code[003565] = *I03565; sub I03565 { $pc = ($ib<<12)+$core[1910]; $inh = 0; goto &fetch; }
$core[003566] = 04200; $code[003566] = *P03566; sub P03566 { $core[003400] = 03567; $pc = 003400+1; $code[003400] = *emul8; $inh = 0; goto &fetch; }
$core[003567] = 00207; $code[003567] = *D03567; sub D03567 { $lac &= (010000|$core[003407]); goto &fetch; }
$core[003570] = 07657; $code[003570] = *D03570; sub D03570 { &emul8; goto &fetch; }
$core[003571] = 00000; $code[003571] = *D03571; sub D03571 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003572] = 01200; $code[003572] = *D03572; sub D03572 { $lac += $core[003400]; goto &fetch; }
$core[004200] = 07200; $code[004200] = *L04200; sub L04200 { $lac &= 010000; goto &fetch; }
$core[004201] = 03136; $code[004201] = *I04201; sub I04201 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004202] = 05203; $code[004202] = *I04202; sub I04202 { $pc = 004203; $inh = 0; goto &fetch; }
$core[004203] = 01136; $code[004203] = *L04203; sub L04203 { $lac += $core[000136]; goto &fetch; }
$core[004204] = 07440; $code[004204] = *I04204; sub I04204 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004205] = 07402; $code[004205] = *I04205; sub I04205 { $hlt = 1; goto &fetch; }
$core[004206] = 01136; $code[004206] = *I04206; sub I04206 { $lac += $core[000136]; goto &fetch; }
$core[004207] = 07001; $code[004207] = *I04207; sub I04207 { $lac++; goto &fetch; }
$core[004210] = 03136; $code[004210] = *I04210; sub I04210 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004211] = 05213; $code[004211] = *I04211; sub I04211 { $pc = 004213; $inh = 0; goto &fetch; }
$core[004212] = 07402; $code[004212] = *I04212; sub I04212 { $hlt = 1; goto &fetch; }
$core[004213] = 01136; $code[004213] = *L04213; sub L04213 { $lac += $core[000136]; goto &fetch; }
$core[004214] = 01113; $code[004214] = *I04214; sub I04214 { $lac += $core[000113]; goto &fetch; }
$core[004215] = 07440; $code[004215] = *I04215; sub I04215 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004216] = 07402; $code[004216] = *I04216; sub I04216 { $hlt = 1; goto &fetch; }
$core[004217] = 01136; $code[004217] = *I04217; sub I04217 { $lac += $core[000136]; goto &fetch; }
$core[004220] = 07001; $code[004220] = *I04220; sub I04220 { $lac++; goto &fetch; }
$core[004221] = 03136; $code[004221] = *I04221; sub I04221 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004222] = 05225; $code[004222] = *I04222; sub I04222 { $pc = 004225; $inh = 0; goto &fetch; }
$core[004223] = 07402; $code[004223] = *I04223; sub I04223 { $hlt = 1; goto &fetch; }
$core[004224] = 07402; $code[004224] = *I04224; sub I04224 { $hlt = 1; goto &fetch; }
$core[004225] = 01136; $code[004225] = *L04225; sub L04225 { $lac += $core[000136]; goto &fetch; }
$core[004226] = 01114; $code[004226] = *I04226; sub I04226 { $lac += $core[000114]; goto &fetch; }
$core[004227] = 07440; $code[004227] = *I04227; sub I04227 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004230] = 07402; $code[004230] = *I04230; sub I04230 { $hlt = 1; goto &fetch; }
$core[004231] = 01136; $code[004231] = *I04231; sub I04231 { $lac += $core[000136]; goto &fetch; }
$core[004232] = 07001; $code[004232] = *I04232; sub I04232 { $lac++; goto &fetch; }
$core[004233] = 03136; $code[004233] = *I04233; sub I04233 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004234] = 05240; $code[004234] = *I04234; sub I04234 { $pc = 004240; $inh = 0; goto &fetch; }
$core[004235] = 07402; $code[004235] = *I04235; sub I04235 { $hlt = 1; goto &fetch; }
$core[004236] = 07402; $code[004236] = *I04236; sub I04236 { $hlt = 1; goto &fetch; }
$core[004237] = 07402; $code[004237] = *I04237; sub I04237 { $hlt = 1; goto &fetch; }
$core[004240] = 01136; $code[004240] = *L04240; sub L04240 { $lac += $core[000136]; goto &fetch; }
$core[004241] = 01115; $code[004241] = *I04241; sub I04241 { $lac += $core[000115]; goto &fetch; }
$core[004242] = 07440; $code[004242] = *I04242; sub I04242 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004243] = 07402; $code[004243] = *I04243; sub I04243 { $hlt = 1; goto &fetch; }
$core[004244] = 01136; $code[004244] = *I04244; sub I04244 { $lac += $core[000136]; goto &fetch; }
$core[004245] = 07001; $code[004245] = *I04245; sub I04245 { $lac++; goto &fetch; }
$core[004246] = 03136; $code[004246] = *I04246; sub I04246 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004247] = 05254; $code[004247] = *I04247; sub I04247 { $pc = 004254; $inh = 0; goto &fetch; }
$core[004250] = 07402; $code[004250] = *I04250; sub I04250 { $hlt = 1; goto &fetch; }
$core[004251] = 07402; $code[004251] = *I04251; sub I04251 { $hlt = 1; goto &fetch; }
$core[004252] = 07402; $code[004252] = *I04252; sub I04252 { $hlt = 1; goto &fetch; }
$core[004253] = 07402; $code[004253] = *I04253; sub I04253 { $hlt = 1; goto &fetch; }
$core[004254] = 01136; $code[004254] = *L04254; sub L04254 { $lac += $core[000136]; goto &fetch; }
$core[004255] = 01116; $code[004255] = *I04255; sub I04255 { $lac += $core[000116]; goto &fetch; }
$core[004256] = 07440; $code[004256] = *I04256; sub I04256 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004257] = 07402; $code[004257] = *I04257; sub I04257 { $hlt = 1; goto &fetch; }
$core[004260] = 01136; $code[004260] = *I04260; sub I04260 { $lac += $core[000136]; goto &fetch; }
$core[004261] = 07001; $code[004261] = *I04261; sub I04261 { $lac++; goto &fetch; }
$core[004262] = 03136; $code[004262] = *I04262; sub I04262 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004263] = 05271; $code[004263] = *I04263; sub I04263 { $pc = 004271; $inh = 0; goto &fetch; }
$core[004264] = 07402; $code[004264] = *I04264; sub I04264 { $hlt = 1; goto &fetch; }
$core[004265] = 07402; $code[004265] = *I04265; sub I04265 { $hlt = 1; goto &fetch; }
$core[004266] = 07402; $code[004266] = *I04266; sub I04266 { $hlt = 1; goto &fetch; }
$core[004267] = 07402; $code[004267] = *I04267; sub I04267 { $hlt = 1; goto &fetch; }
$core[004270] = 07402; $code[004270] = *I04270; sub I04270 { $hlt = 1; goto &fetch; }
$core[004271] = 01136; $code[004271] = *L04271; sub L04271 { $lac += $core[000136]; goto &fetch; }
$core[004272] = 01117; $code[004272] = *I04272; sub I04272 { $lac += $core[000117]; goto &fetch; }
$core[004273] = 07440; $code[004273] = *I04273; sub I04273 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004274] = 07402; $code[004274] = *I04274; sub I04274 { $hlt = 1; goto &fetch; }
$core[004275] = 01136; $code[004275] = *I04275; sub I04275 { $lac += $core[000136]; goto &fetch; }
$core[004276] = 07001; $code[004276] = *I04276; sub I04276 { $lac++; goto &fetch; }
$core[004277] = 03136; $code[004277] = *I04277; sub I04277 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004300] = 05307; $code[004300] = *I04300; sub I04300 { $pc = 004307; $inh = 0; goto &fetch; }
$core[004301] = 07402; $code[004301] = *I04301; sub I04301 { $hlt = 1; goto &fetch; }
$core[004302] = 07402; $code[004302] = *I04302; sub I04302 { $hlt = 1; goto &fetch; }
$core[004303] = 07402; $code[004303] = *I04303; sub I04303 { $hlt = 1; goto &fetch; }
$core[004304] = 07402; $code[004304] = *I04304; sub I04304 { $hlt = 1; goto &fetch; }
$core[004305] = 07402; $code[004305] = *I04305; sub I04305 { $hlt = 1; goto &fetch; }
$core[004306] = 07402; $code[004306] = *I04306; sub I04306 { $hlt = 1; goto &fetch; }
$core[004307] = 01136; $code[004307] = *L04307; sub L04307 { $lac += $core[000136]; goto &fetch; }
$core[004310] = 01120; $code[004310] = *I04310; sub I04310 { $lac += $core[000120]; goto &fetch; }
$core[004311] = 07440; $code[004311] = *I04311; sub I04311 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004312] = 07402; $code[004312] = *I04312; sub I04312 { $hlt = 1; goto &fetch; }
$core[004313] = 01136; $code[004313] = *I04313; sub I04313 { $lac += $core[000136]; goto &fetch; }
$core[004314] = 07001; $code[004314] = *I04314; sub I04314 { $lac++; goto &fetch; }
$core[004315] = 03136; $code[004315] = *I04315; sub I04315 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004316] = 05326; $code[004316] = *I04316; sub I04316 { $pc = 004326; $inh = 0; goto &fetch; }
$core[004317] = 07402; $code[004317] = *I04317; sub I04317 { $hlt = 1; goto &fetch; }
$core[004320] = 07402; $code[004320] = *I04320; sub I04320 { $hlt = 1; goto &fetch; }
$core[004321] = 07402; $code[004321] = *I04321; sub I04321 { $hlt = 1; goto &fetch; }
$core[004322] = 07402; $code[004322] = *I04322; sub I04322 { $hlt = 1; goto &fetch; }
$core[004323] = 07402; $code[004323] = *I04323; sub I04323 { $hlt = 1; goto &fetch; }
$core[004324] = 07402; $code[004324] = *I04324; sub I04324 { $hlt = 1; goto &fetch; }
$core[004325] = 07402; $code[004325] = *I04325; sub I04325 { $hlt = 1; goto &fetch; }
$core[004326] = 01136; $code[004326] = *L04326; sub L04326 { $lac += $core[000136]; goto &fetch; }
$core[004327] = 01121; $code[004327] = *I04327; sub I04327 { $lac += $core[000121]; goto &fetch; }
$core[004330] = 07440; $code[004330] = *I04330; sub I04330 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004331] = 07402; $code[004331] = *I04331; sub I04331 { $hlt = 1; goto &fetch; }
$core[004332] = 01136; $code[004332] = *I04332; sub I04332 { $lac += $core[000136]; goto &fetch; }
$core[004333] = 07001; $code[004333] = *I04333; sub I04333 { $lac++; goto &fetch; }
$core[004334] = 03136; $code[004334] = *I04334; sub I04334 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004335] = 05346; $code[004335] = *I04335; sub I04335 { $pc = 004346; $inh = 0; goto &fetch; }
$core[004336] = 07402; $code[004336] = *I04336; sub I04336 { $hlt = 1; goto &fetch; }
$core[004337] = 07402; $code[004337] = *I04337; sub I04337 { $hlt = 1; goto &fetch; }
$core[004340] = 07402; $code[004340] = *I04340; sub I04340 { $hlt = 1; goto &fetch; }
$core[004341] = 07402; $code[004341] = *I04341; sub I04341 { $hlt = 1; goto &fetch; }
$core[004342] = 07402; $code[004342] = *I04342; sub I04342 { $hlt = 1; goto &fetch; }
$core[004343] = 07402; $code[004343] = *I04343; sub I04343 { $hlt = 1; goto &fetch; }
$core[004344] = 07402; $code[004344] = *I04344; sub I04344 { $hlt = 1; goto &fetch; }
$core[004345] = 07402; $code[004345] = *I04345; sub I04345 { $hlt = 1; goto &fetch; }
$core[004346] = 01136; $code[004346] = *L04346; sub L04346 { $lac += $core[000136]; goto &fetch; }
$core[004347] = 01122; $code[004347] = *I04347; sub I04347 { $lac += $core[000122]; goto &fetch; }
$core[004350] = 07440; $code[004350] = *I04350; sub I04350 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004351] = 07402; $code[004351] = *I04351; sub I04351 { $hlt = 1; goto &fetch; }
$core[004352] = 01136; $code[004352] = *I04352; sub I04352 { $lac += $core[000136]; goto &fetch; }
$core[004353] = 07001; $code[004353] = *I04353; sub I04353 { $lac++; goto &fetch; }
$core[004354] = 03136; $code[004354] = *I04354; sub I04354 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004355] = 05367; $code[004355] = *I04355; sub I04355 { $pc = 004367; $inh = 0; goto &fetch; }
$core[004356] = 07402; $code[004356] = *I04356; sub I04356 { $hlt = 1; goto &fetch; }
$core[004357] = 07402; $code[004357] = *I04357; sub I04357 { $hlt = 1; goto &fetch; }
$core[004360] = 07402; $code[004360] = *I04360; sub I04360 { $hlt = 1; goto &fetch; }
$core[004361] = 07402; $code[004361] = *I04361; sub I04361 { $hlt = 1; goto &fetch; }
$core[004362] = 07402; $code[004362] = *I04362; sub I04362 { $hlt = 1; goto &fetch; }
$core[004363] = 07402; $code[004363] = *I04363; sub I04363 { $hlt = 1; goto &fetch; }
$core[004364] = 07402; $code[004364] = *I04364; sub I04364 { $hlt = 1; goto &fetch; }
$core[004365] = 07402; $code[004365] = *I04365; sub I04365 { $hlt = 1; goto &fetch; }
$core[004366] = 07402; $code[004366] = *I04366; sub I04366 { $hlt = 1; goto &fetch; }
$core[004367] = 01136; $code[004367] = *L04367; sub L04367 { $lac += $core[000136]; goto &fetch; }
$core[004370] = 01123; $code[004370] = *I04370; sub I04370 { $lac += $core[000123]; goto &fetch; }
$core[004371] = 07440; $code[004371] = *I04371; sub I04371 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004372] = 07402; $code[004372] = *I04372; sub I04372 { $hlt = 1; goto &fetch; }
$core[004373] = 01136; $code[004373] = *I04373; sub I04373 { $lac += $core[000136]; goto &fetch; }
$core[004374] = 07001; $code[004374] = *I04374; sub I04374 { $lac++; goto &fetch; }
$core[004375] = 03136; $code[004375] = *I04375; sub I04375 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004376] = 07000; $code[004376] = *I04376; sub I04376 { goto &fetch; }
$core[004377] = 07000; $code[004377] = *I04377; sub I04377 { goto &fetch; }
$core[004400] = 05201; $code[004400] = *I04400; sub I04400 { $pc = 004401; $inh = 0; goto &fetch; }
$core[004401] = 01136; $code[004401] = *L04401; sub L04401 { $lac += $core[000136]; goto &fetch; }
$core[004402] = 01124; $code[004402] = *I04402; sub I04402 { $lac += $core[000124]; goto &fetch; }
$core[004403] = 07440; $code[004403] = *I04403; sub I04403 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004404] = 07402; $code[004404] = *I04404; sub I04404 { $hlt = 1; goto &fetch; }
$core[004405] = 01136; $code[004405] = *I04405; sub I04405 { $lac += $core[000136]; goto &fetch; }
$core[004406] = 07001; $code[004406] = *I04406; sub I04406 { $lac++; goto &fetch; }
$core[004407] = 03136; $code[004407] = *I04407; sub I04407 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004410] = 05212; $code[004410] = *I04410; sub I04410 { $pc = 004412; $inh = 0; goto &fetch; }
$core[004411] = 07402; $code[004411] = *I04411; sub I04411 { $hlt = 1; goto &fetch; }
$core[004412] = 01136; $code[004412] = *L04412; sub L04412 { $lac += $core[000136]; goto &fetch; }
$core[004413] = 01125; $code[004413] = *I04413; sub I04413 { $lac += $core[000125]; goto &fetch; }
$core[004414] = 07440; $code[004414] = *I04414; sub I04414 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004415] = 07402; $code[004415] = *I04415; sub I04415 { $hlt = 1; goto &fetch; }
$core[004416] = 01136; $code[004416] = *I04416; sub I04416 { $lac += $core[000136]; goto &fetch; }
$core[004417] = 07001; $code[004417] = *I04417; sub I04417 { $lac++; goto &fetch; }
$core[004420] = 03136; $code[004420] = *I04420; sub I04420 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004421] = 05224; $code[004421] = *I04421; sub I04421 { $pc = 004424; $inh = 0; goto &fetch; }
$core[004422] = 07402; $code[004422] = *I04422; sub I04422 { $hlt = 1; goto &fetch; }
$core[004423] = 07402; $code[004423] = *I04423; sub I04423 { $hlt = 1; goto &fetch; }
$core[004424] = 01136; $code[004424] = *L04424; sub L04424 { $lac += $core[000136]; goto &fetch; }
$core[004425] = 01126; $code[004425] = *I04425; sub I04425 { $lac += $core[000126]; goto &fetch; }
$core[004426] = 07440; $code[004426] = *I04426; sub I04426 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004427] = 07402; $code[004427] = *I04427; sub I04427 { $hlt = 1; goto &fetch; }
$core[004430] = 01136; $code[004430] = *I04430; sub I04430 { $lac += $core[000136]; goto &fetch; }
$core[004431] = 07001; $code[004431] = *I04431; sub I04431 { $lac++; goto &fetch; }
$core[004432] = 03136; $code[004432] = *I04432; sub I04432 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004433] = 05237; $code[004433] = *I04433; sub I04433 { $pc = 004437; $inh = 0; goto &fetch; }
$core[004434] = 07402; $code[004434] = *I04434; sub I04434 { $hlt = 1; goto &fetch; }
$core[004435] = 07402; $code[004435] = *I04435; sub I04435 { $hlt = 1; goto &fetch; }
$core[004436] = 07402; $code[004436] = *I04436; sub I04436 { $hlt = 1; goto &fetch; }
$core[004437] = 01136; $code[004437] = *L04437; sub L04437 { $lac += $core[000136]; goto &fetch; }
$core[004440] = 01127; $code[004440] = *I04440; sub I04440 { $lac += $core[000127]; goto &fetch; }
$core[004441] = 07440; $code[004441] = *I04441; sub I04441 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004442] = 07402; $code[004442] = *I04442; sub I04442 { $hlt = 1; goto &fetch; }
$core[004443] = 01136; $code[004443] = *I04443; sub I04443 { $lac += $core[000136]; goto &fetch; }
$core[004444] = 07001; $code[004444] = *I04444; sub I04444 { $lac++; goto &fetch; }
$core[004445] = 03136; $code[004445] = *I04445; sub I04445 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004446] = 05253; $code[004446] = *I04446; sub I04446 { $pc = 004453; $inh = 0; goto &fetch; }
$core[004447] = 07402; $code[004447] = *I04447; sub I04447 { $hlt = 1; goto &fetch; }
$core[004450] = 07402; $code[004450] = *I04450; sub I04450 { $hlt = 1; goto &fetch; }
$core[004451] = 07402; $code[004451] = *I04451; sub I04451 { $hlt = 1; goto &fetch; }
$core[004452] = 07402; $code[004452] = *I04452; sub I04452 { $hlt = 1; goto &fetch; }
$core[004453] = 01136; $code[004453] = *L04453; sub L04453 { $lac += $core[000136]; goto &fetch; }
$core[004454] = 01130; $code[004454] = *I04454; sub I04454 { $lac += $core[000130]; goto &fetch; }
$core[004455] = 07440; $code[004455] = *I04455; sub I04455 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004456] = 07402; $code[004456] = *I04456; sub I04456 { $hlt = 1; goto &fetch; }
$core[004457] = 01136; $code[004457] = *I04457; sub I04457 { $lac += $core[000136]; goto &fetch; }
$core[004460] = 07001; $code[004460] = *I04460; sub I04460 { $lac++; goto &fetch; }
$core[004461] = 03136; $code[004461] = *I04461; sub I04461 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004462] = 05270; $code[004462] = *I04462; sub I04462 { $pc = 004470; $inh = 0; goto &fetch; }
$core[004463] = 07402; $code[004463] = *I04463; sub I04463 { $hlt = 1; goto &fetch; }
$core[004464] = 07402; $code[004464] = *I04464; sub I04464 { $hlt = 1; goto &fetch; }
$core[004465] = 07402; $code[004465] = *I04465; sub I04465 { $hlt = 1; goto &fetch; }
$core[004466] = 07402; $code[004466] = *I04466; sub I04466 { $hlt = 1; goto &fetch; }
$core[004467] = 07402; $code[004467] = *I04467; sub I04467 { $hlt = 1; goto &fetch; }
$core[004470] = 01136; $code[004470] = *L04470; sub L04470 { $lac += $core[000136]; goto &fetch; }
$core[004471] = 01131; $code[004471] = *I04471; sub I04471 { $lac += $core[000131]; goto &fetch; }
$core[004472] = 07440; $code[004472] = *I04472; sub I04472 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004473] = 07402; $code[004473] = *I04473; sub I04473 { $hlt = 1; goto &fetch; }
$core[004474] = 01136; $code[004474] = *I04474; sub I04474 { $lac += $core[000136]; goto &fetch; }
$core[004475] = 07001; $code[004475] = *I04475; sub I04475 { $lac++; goto &fetch; }
$core[004476] = 03136; $code[004476] = *I04476; sub I04476 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004477] = 05306; $code[004477] = *I04477; sub I04477 { $pc = 004506; $inh = 0; goto &fetch; }
$core[004500] = 07402; $code[004500] = *I04500; sub I04500 { $hlt = 1; goto &fetch; }
$core[004501] = 07402; $code[004501] = *I04501; sub I04501 { $hlt = 1; goto &fetch; }
$core[004502] = 07402; $code[004502] = *I04502; sub I04502 { $hlt = 1; goto &fetch; }
$core[004503] = 07402; $code[004503] = *I04503; sub I04503 { $hlt = 1; goto &fetch; }
$core[004504] = 07402; $code[004504] = *I04504; sub I04504 { $hlt = 1; goto &fetch; }
$core[004505] = 07402; $code[004505] = *I04505; sub I04505 { $hlt = 1; goto &fetch; }
$core[004506] = 01136; $code[004506] = *L04506; sub L04506 { $lac += $core[000136]; goto &fetch; }
$core[004507] = 01132; $code[004507] = *I04507; sub I04507 { $lac += $core[000132]; goto &fetch; }
$core[004510] = 07440; $code[004510] = *I04510; sub I04510 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004511] = 07402; $code[004511] = *I04511; sub I04511 { $hlt = 1; goto &fetch; }
$core[004512] = 01136; $code[004512] = *I04512; sub I04512 { $lac += $core[000136]; goto &fetch; }
$core[004513] = 07001; $code[004513] = *I04513; sub I04513 { $lac++; goto &fetch; }
$core[004514] = 03136; $code[004514] = *I04514; sub I04514 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004515] = 05325; $code[004515] = *I04515; sub I04515 { $pc = 004525; $inh = 0; goto &fetch; }
$core[004516] = 07402; $code[004516] = *I04516; sub I04516 { $hlt = 1; goto &fetch; }
$core[004517] = 07402; $code[004517] = *I04517; sub I04517 { $hlt = 1; goto &fetch; }
$core[004520] = 07402; $code[004520] = *I04520; sub I04520 { $hlt = 1; goto &fetch; }
$core[004521] = 07402; $code[004521] = *I04521; sub I04521 { $hlt = 1; goto &fetch; }
$core[004522] = 07402; $code[004522] = *I04522; sub I04522 { $hlt = 1; goto &fetch; }
$core[004523] = 07402; $code[004523] = *I04523; sub I04523 { $hlt = 1; goto &fetch; }
$core[004524] = 07402; $code[004524] = *I04524; sub I04524 { $hlt = 1; goto &fetch; }
$core[004525] = 01136; $code[004525] = *L04525; sub L04525 { $lac += $core[000136]; goto &fetch; }
$core[004526] = 01133; $code[004526] = *I04526; sub I04526 { $lac += $core[000133]; goto &fetch; }
$core[004527] = 07440; $code[004527] = *I04527; sub I04527 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004530] = 07402; $code[004530] = *I04530; sub I04530 { $hlt = 1; goto &fetch; }
$core[004531] = 01136; $code[004531] = *I04531; sub I04531 { $lac += $core[000136]; goto &fetch; }
$core[004532] = 07001; $code[004532] = *I04532; sub I04532 { $lac++; goto &fetch; }
$core[004533] = 03136; $code[004533] = *I04533; sub I04533 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004534] = 05345; $code[004534] = *I04534; sub I04534 { $pc = 004545; $inh = 0; goto &fetch; }
$core[004535] = 07402; $code[004535] = *I04535; sub I04535 { $hlt = 1; goto &fetch; }
$core[004536] = 07402; $code[004536] = *I04536; sub I04536 { $hlt = 1; goto &fetch; }
$core[004537] = 07402; $code[004537] = *I04537; sub I04537 { $hlt = 1; goto &fetch; }
$core[004540] = 07402; $code[004540] = *I04540; sub I04540 { $hlt = 1; goto &fetch; }
$core[004541] = 07402; $code[004541] = *I04541; sub I04541 { $hlt = 1; goto &fetch; }
$core[004542] = 07402; $code[004542] = *I04542; sub I04542 { $hlt = 1; goto &fetch; }
$core[004543] = 07402; $code[004543] = *I04543; sub I04543 { $hlt = 1; goto &fetch; }
$core[004544] = 07402; $code[004544] = *I04544; sub I04544 { $hlt = 1; goto &fetch; }
$core[004545] = 01136; $code[004545] = *L04545; sub L04545 { $lac += $core[000136]; goto &fetch; }
$core[004546] = 01134; $code[004546] = *I04546; sub I04546 { $lac += $core[000134]; goto &fetch; }
$core[004547] = 07440; $code[004547] = *I04547; sub I04547 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004550] = 07402; $code[004550] = *I04550; sub I04550 { $hlt = 1; goto &fetch; }
$core[004551] = 01136; $code[004551] = *I04551; sub I04551 { $lac += $core[000136]; goto &fetch; }
$core[004552] = 07001; $code[004552] = *I04552; sub I04552 { $lac++; goto &fetch; }
$core[004553] = 03136; $code[004553] = *I04553; sub I04553 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004554] = 05366; $code[004554] = *I04554; sub I04554 { $pc = 004566; $inh = 0; goto &fetch; }
$core[004555] = 07402; $code[004555] = *I04555; sub I04555 { $hlt = 1; goto &fetch; }
$core[004556] = 07402; $code[004556] = *I04556; sub I04556 { $hlt = 1; goto &fetch; }
$core[004557] = 07402; $code[004557] = *I04557; sub I04557 { $hlt = 1; goto &fetch; }
$core[004560] = 07402; $code[004560] = *I04560; sub I04560 { $hlt = 1; goto &fetch; }
$core[004561] = 07402; $code[004561] = *I04561; sub I04561 { $hlt = 1; goto &fetch; }
$core[004562] = 07402; $code[004562] = *I04562; sub I04562 { $hlt = 1; goto &fetch; }
$core[004563] = 07402; $code[004563] = *I04563; sub I04563 { $hlt = 1; goto &fetch; }
$core[004564] = 07402; $code[004564] = *I04564; sub I04564 { $hlt = 1; goto &fetch; }
$core[004565] = 07402; $code[004565] = *I04565; sub I04565 { $hlt = 1; goto &fetch; }
$core[004566] = 01136; $code[004566] = *L04566; sub L04566 { $lac += $core[000136]; goto &fetch; }
$core[004567] = 01135; $code[004567] = *I04567; sub I04567 { $lac += $core[000135]; goto &fetch; }
$core[004570] = 07440; $code[004570] = *I04570; sub I04570 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004571] = 07402; $code[004571] = *I04571; sub I04571 { $hlt = 1; goto &fetch; }
$core[004572] = 01136; $code[004572] = *I04572; sub I04572 { $lac += $core[000136]; goto &fetch; }
$core[004573] = 07001; $code[004573] = *I04573; sub I04573 { $lac++; goto &fetch; }
$core[004574] = 03136; $code[004574] = *I04574; sub I04574 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004575] = 07000; $code[004575] = *I04575; sub I04575 { goto &fetch; }
$core[004576] = 07000; $code[004576] = *I04576; sub I04576 { goto &fetch; }
$core[004577] = 07000; $code[004577] = *I04577; sub I04577 { goto &fetch; }
$core[004600] = 01205; $code[004600] = *I04600; sub I04600 { $lac += $core[004605]; goto &fetch; }
$core[004601] = 03455; $code[004601] = *I04601; sub I04601 { $core[($df<<12)+$core[45]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[45]] = *emul8; goto &fetch; }
$core[004602] = 01206; $code[004602] = *I04602; sub I04602 { $lac += $core[004606]; goto &fetch; }
$core[004603] = 03422; $code[004603] = *I04603; sub I04603 { $core[($df<<12)+$core[18]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[18]] = *emul8; goto &fetch; }
$core[004604] = 05455; $code[004604] = *I04604; sub I04604 { $pc = ($ib<<12)+$core[45]; $inh = 0; goto &fetch; }
$core[004605] = 05422; $code[004605] = *D04605; sub D04605 { $pc = ($ib<<12)+$core[18]; $inh = 0; goto &fetch; }
$core[004606] = 05456; $code[004606] = *D04606; sub D04606 { $pc = ($ib<<12)+$core[46]; $inh = 0; goto &fetch; }
$core[004620] = 01136; $code[004620] = *L04620; sub L04620 { $lac += $core[000136]; goto &fetch; }
$core[004621] = 01236; $code[004621] = *I04621; sub I04621 { $lac += $core[004636]; goto &fetch; }
$core[004622] = 07440; $code[004622] = *I04622; sub I04622 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004623] = 07402; $code[004623] = *I04623; sub I04623 { $hlt = 1; goto &fetch; }
$core[004624] = 01136; $code[004624] = *I04624; sub I04624 { $lac += $core[000136]; goto &fetch; }
$core[004625] = 07001; $code[004625] = *I04625; sub I04625 { $lac++; goto &fetch; }
$core[004626] = 03136; $code[004626] = *I04626; sub I04626 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004627] = 01234; $code[004627] = *I04627; sub I04627 { $lac += $core[004634]; goto &fetch; }
$core[004630] = 03454; $code[004630] = *I04630; sub I04630 { $core[($df<<12)+$core[44]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[44]] = *emul8; goto &fetch; }
$core[004631] = 01235; $code[004631] = *I04631; sub I04631 { $lac += $core[004635]; goto &fetch; }
$core[004632] = 03423; $code[004632] = *I04632; sub I04632 { $core[($df<<12)+$core[19]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[19]] = *emul8; goto &fetch; }
$core[004633] = 05454; $code[004633] = *I04633; sub I04633 { $pc = ($ib<<12)+$core[44]; $inh = 0; goto &fetch; }
$core[004634] = 05423; $code[004634] = *D04634; sub D04634 { $pc = ($ib<<12)+$core[19]; $inh = 0; goto &fetch; }
$core[004635] = 05457; $code[004635] = *D04635; sub D04635 { $pc = ($ib<<12)+$core[47]; $inh = 0; goto &fetch; }
$core[004636] = 07754; $code[004636] = *D04636; sub D04636 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004640] = 01136; $code[004640] = *L04640; sub L04640 { $lac += $core[000136]; goto &fetch; }
$core[004641] = 01256; $code[004641] = *I04641; sub I04641 { $lac += $core[004656]; goto &fetch; }
$core[004642] = 07440; $code[004642] = *I04642; sub I04642 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004643] = 07402; $code[004643] = *I04643; sub I04643 { $hlt = 1; goto &fetch; }
$core[004644] = 01136; $code[004644] = *I04644; sub I04644 { $lac += $core[000136]; goto &fetch; }
$core[004645] = 07001; $code[004645] = *I04645; sub I04645 { $lac++; goto &fetch; }
$core[004646] = 03136; $code[004646] = *I04646; sub I04646 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004647] = 01254; $code[004647] = *I04647; sub I04647 { $lac += $core[004654]; goto &fetch; }
$core[004650] = 03453; $code[004650] = *I04650; sub I04650 { $core[($df<<12)+$core[43]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[43]] = *emul8; goto &fetch; }
$core[004651] = 01255; $code[004651] = *I04651; sub I04651 { $lac += $core[004655]; goto &fetch; }
$core[004652] = 03424; $code[004652] = *I04652; sub I04652 { $core[($df<<12)+$core[20]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[20]] = *emul8; goto &fetch; }
$core[004653] = 05453; $code[004653] = *I04653; sub I04653 { $pc = ($ib<<12)+$core[43]; $inh = 0; goto &fetch; }
$core[004654] = 05424; $code[004654] = *D04654; sub D04654 { $pc = ($ib<<12)+$core[20]; $inh = 0; goto &fetch; }
$core[004655] = 05660; $code[004655] = *D04655; sub D04655 { $pc = ($ib<<12)+$core[2480]; $inh = 0; goto &fetch; }
$core[004656] = 07753; $code[004656] = *D04656; sub D04656 { &emul8; goto &fetch; }
$core[004660] = 01136; $code[004660] = *P04660; sub P04660 { $lac += $core[000136]; goto &fetch; }
$core[004661] = 01276; $code[004661] = *I04661; sub I04661 { $lac += $core[004676]; goto &fetch; }
$core[004662] = 07440; $code[004662] = *I04662; sub I04662 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004663] = 07402; $code[004663] = *I04663; sub I04663 { $hlt = 1; goto &fetch; }
$core[004664] = 01136; $code[004664] = *I04664; sub I04664 { $lac += $core[000136]; goto &fetch; }
$core[004665] = 07001; $code[004665] = *I04665; sub I04665 { $lac++; goto &fetch; }
$core[004666] = 03136; $code[004666] = *I04666; sub I04666 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004667] = 01274; $code[004667] = *I04667; sub I04667 { $lac += $core[004674]; goto &fetch; }
$core[004670] = 03452; $code[004670] = *I04670; sub I04670 { $core[($df<<12)+$core[42]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[42]] = *emul8; goto &fetch; }
$core[004671] = 01275; $code[004671] = *I04671; sub I04671 { $lac += $core[004675]; goto &fetch; }
$core[004672] = 03425; $code[004672] = *I04672; sub I04672 { $core[($df<<12)+$core[21]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[004673] = 05452; $code[004673] = *I04673; sub I04673 { $pc = ($ib<<12)+$core[42]; $inh = 0; goto &fetch; }
$core[004674] = 05425; $code[004674] = *D04674; sub D04674 { $pc = ($ib<<12)+$core[21]; $inh = 0; goto &fetch; }
$core[004675] = 05461; $code[004675] = *D04675; sub D04675 { $pc = ($ib<<12)+$core[49]; $inh = 0; goto &fetch; }
$core[004676] = 07752; $code[004676] = *D04676; sub D04676 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[004700] = 01136; $code[004700] = *L04700; sub L04700 { $lac += $core[000136]; goto &fetch; }
$core[004701] = 01316; $code[004701] = *I04701; sub I04701 { $lac += $core[004716]; goto &fetch; }
$core[004702] = 07440; $code[004702] = *I04702; sub I04702 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004703] = 07402; $code[004703] = *I04703; sub I04703 { $hlt = 1; goto &fetch; }
$core[004704] = 01136; $code[004704] = *I04704; sub I04704 { $lac += $core[000136]; goto &fetch; }
$core[004705] = 07001; $code[004705] = *I04705; sub I04705 { $lac++; goto &fetch; }
$core[004706] = 03136; $code[004706] = *I04706; sub I04706 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004707] = 01314; $code[004707] = *I04707; sub I04707 { $lac += $core[004714]; goto &fetch; }
$core[004710] = 03451; $code[004710] = *I04710; sub I04710 { $core[($df<<12)+$core[41]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[41]] = *emul8; goto &fetch; }
$core[004711] = 01315; $code[004711] = *I04711; sub I04711 { $lac += $core[004715]; goto &fetch; }
$core[004712] = 03426; $code[004712] = *I04712; sub I04712 { $core[($df<<12)+$core[22]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[22]] = *emul8; goto &fetch; }
$core[004713] = 05451; $code[004713] = *I04713; sub I04713 { $pc = ($ib<<12)+$core[41]; $inh = 0; goto &fetch; }
$core[004714] = 05426; $code[004714] = *D04714; sub D04714 { $pc = ($ib<<12)+$core[22]; $inh = 0; goto &fetch; }
$core[004715] = 05462; $code[004715] = *D04715; sub D04715 { $pc = ($ib<<12)+$core[50]; $inh = 0; goto &fetch; }
$core[004716] = 07751; $code[004716] = *D04716; sub D04716 { &emul8; goto &fetch; }
$core[004720] = 01136; $code[004720] = *L04720; sub L04720 { $lac += $core[000136]; goto &fetch; }
$core[004721] = 01336; $code[004721] = *I04721; sub I04721 { $lac += $core[004736]; goto &fetch; }
$core[004722] = 07440; $code[004722] = *I04722; sub I04722 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004723] = 07402; $code[004723] = *I04723; sub I04723 { $hlt = 1; goto &fetch; }
$core[004724] = 01136; $code[004724] = *I04724; sub I04724 { $lac += $core[000136]; goto &fetch; }
$core[004725] = 07001; $code[004725] = *I04725; sub I04725 { $lac++; goto &fetch; }
$core[004726] = 03136; $code[004726] = *I04726; sub I04726 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004727] = 01334; $code[004727] = *I04727; sub I04727 { $lac += $core[004734]; goto &fetch; }
$core[004730] = 03450; $code[004730] = *I04730; sub I04730 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[004731] = 01335; $code[004731] = *I04731; sub I04731 { $lac += $core[004735]; goto &fetch; }
$core[004732] = 03427; $code[004732] = *I04732; sub I04732 { $core[($df<<12)+$core[23]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[23]] = *emul8; goto &fetch; }
$core[004733] = 05450; $code[004733] = *I04733; sub I04733 { $pc = ($ib<<12)+$core[40]; $inh = 0; goto &fetch; }
$core[004734] = 05427; $code[004734] = *D04734; sub D04734 { $pc = ($ib<<12)+$core[23]; $inh = 0; goto &fetch; }
$core[004735] = 05463; $code[004735] = *D04735; sub D04735 { $pc = ($ib<<12)+$core[51]; $inh = 0; goto &fetch; }
$core[004736] = 07750; $code[004736] = *D04736; sub D04736 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004740] = 01136; $code[004740] = *L04740; sub L04740 { $lac += $core[000136]; goto &fetch; }
$core[004741] = 01356; $code[004741] = *I04741; sub I04741 { $lac += $core[004756]; goto &fetch; }
$core[004742] = 07440; $code[004742] = *I04742; sub I04742 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004743] = 07402; $code[004743] = *I04743; sub I04743 { $hlt = 1; goto &fetch; }
$core[004744] = 01136; $code[004744] = *I04744; sub I04744 { $lac += $core[000136]; goto &fetch; }
$core[004745] = 07001; $code[004745] = *I04745; sub I04745 { $lac++; goto &fetch; }
$core[004746] = 03136; $code[004746] = *I04746; sub I04746 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004747] = 01354; $code[004747] = *I04747; sub I04747 { $lac += $core[004754]; goto &fetch; }
$core[004750] = 03447; $code[004750] = *I04750; sub I04750 { $core[($df<<12)+$core[39]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[39]] = *emul8; goto &fetch; }
$core[004751] = 01355; $code[004751] = *I04751; sub I04751 { $lac += $core[004755]; goto &fetch; }
$core[004752] = 03430; $code[004752] = *I04752; sub I04752 { $core[($df<<12)+$core[24]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[004753] = 05447; $code[004753] = *I04753; sub I04753 { $pc = ($ib<<12)+$core[39]; $inh = 0; goto &fetch; }
$core[004754] = 05430; $code[004754] = *D04754; sub D04754 { $pc = ($ib<<12)+$core[24]; $inh = 0; goto &fetch; }
$core[004755] = 05464; $code[004755] = *D04755; sub D04755 { $pc = ($ib<<12)+$core[52]; $inh = 0; goto &fetch; }
$core[004756] = 07747; $code[004756] = *D04756; sub D04756 { &emul8; goto &fetch; }
$core[004760] = 01136; $code[004760] = *L04760; sub L04760 { $lac += $core[000136]; goto &fetch; }
$core[004761] = 01376; $code[004761] = *I04761; sub I04761 { $lac += $core[004776]; goto &fetch; }
$core[004762] = 07440; $code[004762] = *I04762; sub I04762 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004763] = 07402; $code[004763] = *I04763; sub I04763 { $hlt = 1; goto &fetch; }
$core[004764] = 01136; $code[004764] = *I04764; sub I04764 { $lac += $core[000136]; goto &fetch; }
$core[004765] = 07001; $code[004765] = *I04765; sub I04765 { $lac++; goto &fetch; }
$core[004766] = 03136; $code[004766] = *I04766; sub I04766 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[004767] = 01374; $code[004767] = *I04767; sub I04767 { $lac += $core[004774]; goto &fetch; }
$core[004770] = 03446; $code[004770] = *I04770; sub I04770 { $core[($df<<12)+$core[38]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[38]] = *emul8; goto &fetch; }
$core[004771] = 01375; $code[004771] = *I04771; sub I04771 { $lac += $core[004775]; goto &fetch; }
$core[004772] = 03431; $code[004772] = *I04772; sub I04772 { $core[($df<<12)+$core[25]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[25]] = *emul8; goto &fetch; }
$core[004773] = 05446; $code[004773] = *I04773; sub I04773 { $pc = ($ib<<12)+$core[38]; $inh = 0; goto &fetch; }
$core[004774] = 05431; $code[004774] = *D04774; sub D04774 { $pc = ($ib<<12)+$core[25]; $inh = 0; goto &fetch; }
$core[004775] = 05465; $code[004775] = *D04775; sub D04775 { $pc = ($ib<<12)+$core[53]; $inh = 0; goto &fetch; }
$core[004776] = 07746; $code[004776] = *D04776; sub D04776 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[005000] = 01136; $code[005000] = *L05000; sub L05000 { $lac += $core[000136]; goto &fetch; }
$core[005001] = 01216; $code[005001] = *D05001; sub D05001 { $lac += $core[005016]; goto &fetch; }
$core[005002] = 07440; $code[005002] = *I05002; sub I05002 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005003] = 07402; $code[005003] = *I05003; sub I05003 { $hlt = 1; goto &fetch; }
$core[005004] = 01136; $code[005004] = *I05004; sub I05004 { $lac += $core[000136]; goto &fetch; }
$core[005005] = 07001; $code[005005] = *I05005; sub I05005 { $lac++; goto &fetch; }
$core[005006] = 03136; $code[005006] = *I05006; sub I05006 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005007] = 01214; $code[005007] = *I05007; sub I05007 { $lac += $core[005014]; goto &fetch; }
$core[005010] = 03445; $code[005010] = *I05010; sub I05010 { $core[($df<<12)+$core[37]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[37]] = *emul8; goto &fetch; }
$core[005011] = 01215; $code[005011] = *I05011; sub I05011 { $lac += $core[005015]; goto &fetch; }
$core[005012] = 03432; $code[005012] = *I05012; sub I05012 { $core[($df<<12)+$core[26]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[26]] = *emul8; goto &fetch; }
$core[005013] = 05445; $code[005013] = *I05013; sub I05013 { $pc = ($ib<<12)+$core[37]; $inh = 0; goto &fetch; }
$core[005014] = 05432; $code[005014] = *D05014; sub D05014 { $pc = ($ib<<12)+$core[26]; $inh = 0; goto &fetch; }
$core[005015] = 05466; $code[005015] = *D05015; sub D05015 { $pc = ($ib<<12)+$core[54]; $inh = 0; goto &fetch; }
$core[005016] = 07745; $code[005016] = *D05016; sub D05016 { &emul8; goto &fetch; }
$core[005020] = 01136; $code[005020] = *L05020; sub L05020 { $lac += $core[000136]; goto &fetch; }
$core[005021] = 01236; $code[005021] = *I05021; sub I05021 { $lac += $core[005036]; goto &fetch; }
$core[005022] = 07440; $code[005022] = *I05022; sub I05022 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005023] = 07402; $code[005023] = *I05023; sub I05023 { $hlt = 1; goto &fetch; }
$core[005024] = 01136; $code[005024] = *I05024; sub I05024 { $lac += $core[000136]; goto &fetch; }
$core[005025] = 07001; $code[005025] = *I05025; sub I05025 { $lac++; goto &fetch; }
$core[005026] = 03136; $code[005026] = *I05026; sub I05026 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005027] = 01234; $code[005027] = *I05027; sub I05027 { $lac += $core[005034]; goto &fetch; }
$core[005030] = 03444; $code[005030] = *I05030; sub I05030 { $core[($df<<12)+$core[36]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[36]] = *emul8; goto &fetch; }
$core[005031] = 01235; $code[005031] = *I05031; sub I05031 { $lac += $core[005035]; goto &fetch; }
$core[005032] = 03433; $code[005032] = *I05032; sub I05032 { $core[($df<<12)+$core[27]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[27]] = *emul8; goto &fetch; }
$core[005033] = 05444; $code[005033] = *I05033; sub I05033 { $pc = ($ib<<12)+$core[36]; $inh = 0; goto &fetch; }
$core[005034] = 05433; $code[005034] = *D05034; sub D05034 { $pc = ($ib<<12)+$core[27]; $inh = 0; goto &fetch; }
$core[005035] = 05467; $code[005035] = *D05035; sub D05035 { $pc = ($ib<<12)+$core[55]; $inh = 0; goto &fetch; }
$core[005036] = 07744; $code[005036] = *D05036; sub D05036 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005040] = 01136; $code[005040] = *L05040; sub L05040 { $lac += $core[000136]; goto &fetch; }
$core[005041] = 01256; $code[005041] = *I05041; sub I05041 { $lac += $core[005056]; goto &fetch; }
$core[005042] = 07440; $code[005042] = *I05042; sub I05042 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005043] = 07402; $code[005043] = *I05043; sub I05043 { $hlt = 1; goto &fetch; }
$core[005044] = 01136; $code[005044] = *I05044; sub I05044 { $lac += $core[000136]; goto &fetch; }
$core[005045] = 07001; $code[005045] = *I05045; sub I05045 { $lac++; goto &fetch; }
$core[005046] = 03136; $code[005046] = *I05046; sub I05046 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005047] = 01254; $code[005047] = *I05047; sub I05047 { $lac += $core[005054]; goto &fetch; }
$core[005050] = 03443; $code[005050] = *I05050; sub I05050 { $core[($df<<12)+$core[35]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[35]] = *emul8; goto &fetch; }
$core[005051] = 01255; $code[005051] = *I05051; sub I05051 { $lac += $core[005055]; goto &fetch; }
$core[005052] = 03434; $code[005052] = *I05052; sub I05052 { $core[($df<<12)+$core[28]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[28]] = *emul8; goto &fetch; }
$core[005053] = 05443; $code[005053] = *I05053; sub I05053 { $pc = ($ib<<12)+$core[35]; $inh = 0; goto &fetch; }
$core[005054] = 05434; $code[005054] = *D05054; sub D05054 { $pc = ($ib<<12)+$core[28]; $inh = 0; goto &fetch; }
$core[005055] = 05470; $code[005055] = *D05055; sub D05055 { $pc = ($ib<<12)+$core[56]; $inh = 0; goto &fetch; }
$core[005056] = 07743; $code[005056] = *D05056; sub D05056 { &emul8; goto &fetch; }
$core[005060] = 01136; $code[005060] = *L05060; sub L05060 { $lac += $core[000136]; goto &fetch; }
$core[005061] = 01276; $code[005061] = *I05061; sub I05061 { $lac += $core[005076]; goto &fetch; }
$core[005062] = 07440; $code[005062] = *I05062; sub I05062 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005063] = 07402; $code[005063] = *I05063; sub I05063 { $hlt = 1; goto &fetch; }
$core[005064] = 01136; $code[005064] = *I05064; sub I05064 { $lac += $core[000136]; goto &fetch; }
$core[005065] = 07001; $code[005065] = *I05065; sub I05065 { $lac++; goto &fetch; }
$core[005066] = 03136; $code[005066] = *I05066; sub I05066 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005067] = 01274; $code[005067] = *I05067; sub I05067 { $lac += $core[005074]; goto &fetch; }
$core[005070] = 03442; $code[005070] = *I05070; sub I05070 { $core[($df<<12)+$core[34]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[34]] = *emul8; goto &fetch; }
$core[005071] = 01275; $code[005071] = *I05071; sub I05071 { $lac += $core[005075]; goto &fetch; }
$core[005072] = 03435; $code[005072] = *I05072; sub I05072 { $core[($df<<12)+$core[29]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[29]] = *emul8; goto &fetch; }
$core[005073] = 05442; $code[005073] = *I05073; sub I05073 { $pc = ($ib<<12)+$core[34]; $inh = 0; goto &fetch; }
$core[005074] = 05435; $code[005074] = *D05074; sub D05074 { $pc = ($ib<<12)+$core[29]; $inh = 0; goto &fetch; }
$core[005075] = 05471; $code[005075] = *D05075; sub D05075 { $pc = ($ib<<12)+$core[57]; $inh = 0; goto &fetch; }
$core[005076] = 07742; $code[005076] = *D05076; sub D05076 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[005100] = 01136; $code[005100] = *L05100; sub L05100 { $lac += $core[000136]; goto &fetch; }
$core[005101] = 01316; $code[005101] = *I05101; sub I05101 { $lac += $core[005116]; goto &fetch; }
$core[005102] = 07440; $code[005102] = *I05102; sub I05102 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005103] = 07402; $code[005103] = *I05103; sub I05103 { $hlt = 1; goto &fetch; }
$core[005104] = 01136; $code[005104] = *I05104; sub I05104 { $lac += $core[000136]; goto &fetch; }
$core[005105] = 07001; $code[005105] = *I05105; sub I05105 { $lac++; goto &fetch; }
$core[005106] = 03136; $code[005106] = *I05106; sub I05106 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005107] = 01314; $code[005107] = *I05107; sub I05107 { $lac += $core[005114]; goto &fetch; }
$core[005110] = 03437; $code[005110] = *I05110; sub I05110 { $core[($df<<12)+$core[31]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[31]] = *emul8; goto &fetch; }
$core[005111] = 01315; $code[005111] = *I05111; sub I05111 { $lac += $core[005115]; goto &fetch; }
$core[005112] = 03436; $code[005112] = *I05112; sub I05112 { $core[($df<<12)+$core[30]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[30]] = *emul8; goto &fetch; }
$core[005113] = 05437; $code[005113] = *I05113; sub I05113 { $pc = ($ib<<12)+$core[31]; $inh = 0; goto &fetch; }
$core[005114] = 05436; $code[005114] = *D05114; sub D05114 { $pc = ($ib<<12)+$core[30]; $inh = 0; goto &fetch; }
$core[005115] = 05472; $code[005115] = *D05115; sub D05115 { $pc = ($ib<<12)+$core[58]; $inh = 0; goto &fetch; }
$core[005116] = 07741; $code[005116] = *D05116; sub D05116 { &emul8; goto &fetch; }
$core[005120] = 01136; $code[005120] = *L05120; sub L05120 { $lac += $core[000136]; goto &fetch; }
$core[005121] = 01336; $code[005121] = *I05121; sub I05121 { $lac += $core[005136]; goto &fetch; }
$core[005122] = 07440; $code[005122] = *I05122; sub I05122 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005123] = 07402; $code[005123] = *I05123; sub I05123 { $hlt = 1; goto &fetch; }
$core[005124] = 01136; $code[005124] = *I05124; sub I05124 { $lac += $core[000136]; goto &fetch; }
$core[005125] = 07001; $code[005125] = *I05125; sub I05125 { $lac++; goto &fetch; }
$core[005126] = 03136; $code[005126] = *I05126; sub I05126 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005127] = 01334; $code[005127] = *I05127; sub I05127 { $lac += $core[005134]; goto &fetch; }
$core[005130] = 03422; $code[005130] = *I05130; sub I05130 { $core[($df<<12)+$core[18]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[18]] = *emul8; goto &fetch; }
$core[005131] = 01335; $code[005131] = *I05131; sub I05131 { $lac += $core[005135]; goto &fetch; }
$core[005132] = 03455; $code[005132] = *I05132; sub I05132 { $core[($df<<12)+$core[45]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[45]] = *emul8; goto &fetch; }
$core[005133] = 05422; $code[005133] = *I05133; sub I05133 { $pc = ($ib<<12)+$core[18]; $inh = 0; goto &fetch; }
$core[005134] = 05455; $code[005134] = *D05134; sub D05134 { $pc = ($ib<<12)+$core[45]; $inh = 0; goto &fetch; }
$core[005135] = 05473; $code[005135] = *D05135; sub D05135 { $pc = ($ib<<12)+$core[59]; $inh = 0; goto &fetch; }
$core[005136] = 07740; $code[005136] = *D05136; sub D05136 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005140] = 01136; $code[005140] = *L05140; sub L05140 { $lac += $core[000136]; goto &fetch; }
$core[005141] = 01356; $code[005141] = *I05141; sub I05141 { $lac += $core[005156]; goto &fetch; }
$core[005142] = 07440; $code[005142] = *I05142; sub I05142 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005143] = 07402; $code[005143] = *I05143; sub I05143 { $hlt = 1; goto &fetch; }
$core[005144] = 01136; $code[005144] = *I05144; sub I05144 { $lac += $core[000136]; goto &fetch; }
$core[005145] = 07001; $code[005145] = *I05145; sub I05145 { $lac++; goto &fetch; }
$core[005146] = 03136; $code[005146] = *I05146; sub I05146 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005147] = 01354; $code[005147] = *I05147; sub I05147 { $lac += $core[005154]; goto &fetch; }
$core[005150] = 03423; $code[005150] = *I05150; sub I05150 { $core[($df<<12)+$core[19]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[19]] = *emul8; goto &fetch; }
$core[005151] = 01355; $code[005151] = *I05151; sub I05151 { $lac += $core[005155]; goto &fetch; }
$core[005152] = 03454; $code[005152] = *I05152; sub I05152 { $core[($df<<12)+$core[44]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[44]] = *emul8; goto &fetch; }
$core[005153] = 05423; $code[005153] = *I05153; sub I05153 { $pc = ($ib<<12)+$core[19]; $inh = 0; goto &fetch; }
$core[005154] = 05454; $code[005154] = *D05154; sub D05154 { $pc = ($ib<<12)+$core[44]; $inh = 0; goto &fetch; }
$core[005155] = 05474; $code[005155] = *D05155; sub D05155 { $pc = ($ib<<12)+$core[60]; $inh = 0; goto &fetch; }
$core[005156] = 07737; $code[005156] = *D05156; sub D05156 { &emul8; goto &fetch; }
$core[005160] = 01136; $code[005160] = *L05160; sub L05160 { $lac += $core[000136]; goto &fetch; }
$core[005161] = 01376; $code[005161] = *I05161; sub I05161 { $lac += $core[005176]; goto &fetch; }
$core[005162] = 07440; $code[005162] = *I05162; sub I05162 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005163] = 07402; $code[005163] = *I05163; sub I05163 { $hlt = 1; goto &fetch; }
$core[005164] = 01136; $code[005164] = *I05164; sub I05164 { $lac += $core[000136]; goto &fetch; }
$core[005165] = 07001; $code[005165] = *I05165; sub I05165 { $lac++; goto &fetch; }
$core[005166] = 03136; $code[005166] = *I05166; sub I05166 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005167] = 01374; $code[005167] = *I05167; sub I05167 { $lac += $core[005174]; goto &fetch; }
$core[005170] = 03424; $code[005170] = *I05170; sub I05170 { $core[($df<<12)+$core[20]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[20]] = *emul8; goto &fetch; }
$core[005171] = 01375; $code[005171] = *I05171; sub I05171 { $lac += $core[005175]; goto &fetch; }
$core[005172] = 03453; $code[005172] = *I05172; sub I05172 { $core[($df<<12)+$core[43]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[43]] = *emul8; goto &fetch; }
$core[005173] = 05424; $code[005173] = *I05173; sub I05173 { $pc = ($ib<<12)+$core[20]; $inh = 0; goto &fetch; }
$core[005174] = 05453; $code[005174] = *D05174; sub D05174 { $pc = ($ib<<12)+$core[43]; $inh = 0; goto &fetch; }
$core[005175] = 05475; $code[005175] = *D05175; sub D05175 { $pc = ($ib<<12)+$core[61]; $inh = 0; goto &fetch; }
$core[005176] = 07736; $code[005176] = *D05176; sub D05176 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[005200] = 01136; $code[005200] = *L05200; sub L05200 { $lac += $core[000136]; goto &fetch; }
$core[005201] = 01216; $code[005201] = *I05201; sub I05201 { $lac += $core[005216]; goto &fetch; }
$core[005202] = 07440; $code[005202] = *I05202; sub I05202 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005203] = 07402; $code[005203] = *I05203; sub I05203 { $hlt = 1; goto &fetch; }
$core[005204] = 01136; $code[005204] = *I05204; sub I05204 { $lac += $core[000136]; goto &fetch; }
$core[005205] = 07001; $code[005205] = *I05205; sub I05205 { $lac++; goto &fetch; }
$core[005206] = 03136; $code[005206] = *I05206; sub I05206 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005207] = 01214; $code[005207] = *I05207; sub I05207 { $lac += $core[005214]; goto &fetch; }
$core[005210] = 03425; $code[005210] = *I05210; sub I05210 { $core[($df<<12)+$core[21]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[005211] = 01215; $code[005211] = *I05211; sub I05211 { $lac += $core[005215]; goto &fetch; }
$core[005212] = 03452; $code[005212] = *I05212; sub I05212 { $core[($df<<12)+$core[42]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[42]] = *emul8; goto &fetch; }
$core[005213] = 05425; $code[005213] = *I05213; sub I05213 { $pc = ($ib<<12)+$core[21]; $inh = 0; goto &fetch; }
$core[005214] = 05452; $code[005214] = *D05214; sub D05214 { $pc = ($ib<<12)+$core[42]; $inh = 0; goto &fetch; }
$core[005215] = 05476; $code[005215] = *D05215; sub D05215 { $pc = ($ib<<12)+$core[62]; $inh = 0; goto &fetch; }
$core[005216] = 07735; $code[005216] = *D05216; sub D05216 { &emul8; goto &fetch; }
$core[005220] = 01136; $code[005220] = *L05220; sub L05220 { $lac += $core[000136]; goto &fetch; }
$core[005221] = 01236; $code[005221] = *I05221; sub I05221 { $lac += $core[005236]; goto &fetch; }
$core[005222] = 07440; $code[005222] = *I05222; sub I05222 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005223] = 07402; $code[005223] = *I05223; sub I05223 { $hlt = 1; goto &fetch; }
$core[005224] = 01136; $code[005224] = *I05224; sub I05224 { $lac += $core[000136]; goto &fetch; }
$core[005225] = 07001; $code[005225] = *I05225; sub I05225 { $lac++; goto &fetch; }
$core[005226] = 03136; $code[005226] = *I05226; sub I05226 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005227] = 01234; $code[005227] = *I05227; sub I05227 { $lac += $core[005234]; goto &fetch; }
$core[005230] = 03426; $code[005230] = *I05230; sub I05230 { $core[($df<<12)+$core[22]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[22]] = *emul8; goto &fetch; }
$core[005231] = 01235; $code[005231] = *I05231; sub I05231 { $lac += $core[005235]; goto &fetch; }
$core[005232] = 03451; $code[005232] = *I05232; sub I05232 { $core[($df<<12)+$core[41]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[41]] = *emul8; goto &fetch; }
$core[005233] = 05426; $code[005233] = *I05233; sub I05233 { $pc = ($ib<<12)+$core[22]; $inh = 0; goto &fetch; }
$core[005234] = 05451; $code[005234] = *D05234; sub D05234 { $pc = ($ib<<12)+$core[41]; $inh = 0; goto &fetch; }
$core[005235] = 05502; $code[005235] = *D05235; sub D05235 { $pc = ($ib<<12)+$core[66]; $inh = 0; goto &fetch; }
$core[005236] = 07734; $code[005236] = *D05236; sub D05236 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005240] = 01136; $code[005240] = *L05240; sub L05240 { $lac += $core[000136]; goto &fetch; }
$core[005241] = 01256; $code[005241] = *I05241; sub I05241 { $lac += $core[005256]; goto &fetch; }
$core[005242] = 07440; $code[005242] = *I05242; sub I05242 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005243] = 07402; $code[005243] = *I05243; sub I05243 { $hlt = 1; goto &fetch; }
$core[005244] = 01136; $code[005244] = *I05244; sub I05244 { $lac += $core[000136]; goto &fetch; }
$core[005245] = 07001; $code[005245] = *I05245; sub I05245 { $lac++; goto &fetch; }
$core[005246] = 03136; $code[005246] = *I05246; sub I05246 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005247] = 01254; $code[005247] = *I05247; sub I05247 { $lac += $core[005254]; goto &fetch; }
$core[005250] = 03427; $code[005250] = *I05250; sub I05250 { $core[($df<<12)+$core[23]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[23]] = *emul8; goto &fetch; }
$core[005251] = 01255; $code[005251] = *I05251; sub I05251 { $lac += $core[005255]; goto &fetch; }
$core[005252] = 03450; $code[005252] = *I05252; sub I05252 { $core[($df<<12)+$core[40]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[005253] = 05427; $code[005253] = *I05253; sub I05253 { $pc = ($ib<<12)+$core[23]; $inh = 0; goto &fetch; }
$core[005254] = 05450; $code[005254] = *D05254; sub D05254 { $pc = ($ib<<12)+$core[40]; $inh = 0; goto &fetch; }
$core[005255] = 05503; $code[005255] = *D05255; sub D05255 { $pc = ($ib<<12)+$core[67]; $inh = 0; goto &fetch; }
$core[005256] = 07733; $code[005256] = *D05256; sub D05256 { &emul8; goto &fetch; }
$core[005260] = 01136; $code[005260] = *L05260; sub L05260 { $lac += $core[000136]; goto &fetch; }
$core[005261] = 01276; $code[005261] = *I05261; sub I05261 { $lac += $core[005276]; goto &fetch; }
$core[005262] = 07440; $code[005262] = *I05262; sub I05262 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005263] = 07402; $code[005263] = *I05263; sub I05263 { $hlt = 1; goto &fetch; }
$core[005264] = 01136; $code[005264] = *I05264; sub I05264 { $lac += $core[000136]; goto &fetch; }
$core[005265] = 07001; $code[005265] = *I05265; sub I05265 { $lac++; goto &fetch; }
$core[005266] = 03136; $code[005266] = *I05266; sub I05266 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005267] = 01274; $code[005267] = *I05267; sub I05267 { $lac += $core[005274]; goto &fetch; }
$core[005270] = 03430; $code[005270] = *I05270; sub I05270 { $core[($df<<12)+$core[24]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[005271] = 01275; $code[005271] = *I05271; sub I05271 { $lac += $core[005275]; goto &fetch; }
$core[005272] = 03447; $code[005272] = *I05272; sub I05272 { $core[($df<<12)+$core[39]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[39]] = *emul8; goto &fetch; }
$core[005273] = 05430; $code[005273] = *I05273; sub I05273 { $pc = ($ib<<12)+$core[24]; $inh = 0; goto &fetch; }
$core[005274] = 05447; $code[005274] = *D05274; sub D05274 { $pc = ($ib<<12)+$core[39]; $inh = 0; goto &fetch; }
$core[005275] = 05504; $code[005275] = *D05275; sub D05275 { $pc = ($ib<<12)+$core[68]; $inh = 0; goto &fetch; }
$core[005276] = 07732; $code[005276] = *D05276; sub D05276 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[005300] = 01136; $code[005300] = *L05300; sub L05300 { $lac += $core[000136]; goto &fetch; }
$core[005301] = 01316; $code[005301] = *I05301; sub I05301 { $lac += $core[005316]; goto &fetch; }
$core[005302] = 07440; $code[005302] = *I05302; sub I05302 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005303] = 07402; $code[005303] = *I05303; sub I05303 { $hlt = 1; goto &fetch; }
$core[005304] = 01136; $code[005304] = *I05304; sub I05304 { $lac += $core[000136]; goto &fetch; }
$core[005305] = 07001; $code[005305] = *I05305; sub I05305 { $lac++; goto &fetch; }
$core[005306] = 03136; $code[005306] = *I05306; sub I05306 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005307] = 01314; $code[005307] = *I05307; sub I05307 { $lac += $core[005314]; goto &fetch; }
$core[005310] = 03431; $code[005310] = *I05310; sub I05310 { $core[($df<<12)+$core[25]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[25]] = *emul8; goto &fetch; }
$core[005311] = 01315; $code[005311] = *I05311; sub I05311 { $lac += $core[005315]; goto &fetch; }
$core[005312] = 03446; $code[005312] = *I05312; sub I05312 { $core[($df<<12)+$core[38]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[38]] = *emul8; goto &fetch; }
$core[005313] = 05431; $code[005313] = *I05313; sub I05313 { $pc = ($ib<<12)+$core[25]; $inh = 0; goto &fetch; }
$core[005314] = 05446; $code[005314] = *D05314; sub D05314 { $pc = ($ib<<12)+$core[38]; $inh = 0; goto &fetch; }
$core[005315] = 05505; $code[005315] = *D05315; sub D05315 { $pc = ($ib<<12)+$core[69]; $inh = 0; goto &fetch; }
$core[005316] = 07731; $code[005316] = *D05316; sub D05316 { &emul8; goto &fetch; }
$core[005320] = 01136; $code[005320] = *L05320; sub L05320 { $lac += $core[000136]; goto &fetch; }
$core[005321] = 01336; $code[005321] = *I05321; sub I05321 { $lac += $core[005336]; goto &fetch; }
$core[005322] = 07440; $code[005322] = *I05322; sub I05322 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005323] = 07402; $code[005323] = *I05323; sub I05323 { $hlt = 1; goto &fetch; }
$core[005324] = 01136; $code[005324] = *I05324; sub I05324 { $lac += $core[000136]; goto &fetch; }
$core[005325] = 07001; $code[005325] = *I05325; sub I05325 { $lac++; goto &fetch; }
$core[005326] = 03136; $code[005326] = *I05326; sub I05326 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005327] = 01334; $code[005327] = *I05327; sub I05327 { $lac += $core[005334]; goto &fetch; }
$core[005330] = 03432; $code[005330] = *I05330; sub I05330 { $core[($df<<12)+$core[26]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[26]] = *emul8; goto &fetch; }
$core[005331] = 01335; $code[005331] = *I05331; sub I05331 { $lac += $core[005335]; goto &fetch; }
$core[005332] = 03445; $code[005332] = *I05332; sub I05332 { $core[($df<<12)+$core[37]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[37]] = *emul8; goto &fetch; }
$core[005333] = 05432; $code[005333] = *I05333; sub I05333 { $pc = ($ib<<12)+$core[26]; $inh = 0; goto &fetch; }
$core[005334] = 05445; $code[005334] = *D05334; sub D05334 { $pc = ($ib<<12)+$core[37]; $inh = 0; goto &fetch; }
$core[005335] = 05506; $code[005335] = *D05335; sub D05335 { $pc = ($ib<<12)+$core[70]; $inh = 0; goto &fetch; }
$core[005336] = 07730; $code[005336] = *D05336; sub D05336 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005340] = 01136; $code[005340] = *L05340; sub L05340 { $lac += $core[000136]; goto &fetch; }
$core[005341] = 01356; $code[005341] = *I05341; sub I05341 { $lac += $core[005356]; goto &fetch; }
$core[005342] = 07440; $code[005342] = *I05342; sub I05342 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005343] = 07402; $code[005343] = *I05343; sub I05343 { $hlt = 1; goto &fetch; }
$core[005344] = 01136; $code[005344] = *I05344; sub I05344 { $lac += $core[000136]; goto &fetch; }
$core[005345] = 07001; $code[005345] = *I05345; sub I05345 { $lac++; goto &fetch; }
$core[005346] = 03136; $code[005346] = *I05346; sub I05346 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005347] = 01354; $code[005347] = *I05347; sub I05347 { $lac += $core[005354]; goto &fetch; }
$core[005350] = 03433; $code[005350] = *I05350; sub I05350 { $core[($df<<12)+$core[27]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[27]] = *emul8; goto &fetch; }
$core[005351] = 01355; $code[005351] = *I05351; sub I05351 { $lac += $core[005355]; goto &fetch; }
$core[005352] = 03444; $code[005352] = *I05352; sub I05352 { $core[($df<<12)+$core[36]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[36]] = *emul8; goto &fetch; }
$core[005353] = 05433; $code[005353] = *I05353; sub I05353 { $pc = ($ib<<12)+$core[27]; $inh = 0; goto &fetch; }
$core[005354] = 05444; $code[005354] = *D05354; sub D05354 { $pc = ($ib<<12)+$core[36]; $inh = 0; goto &fetch; }
$core[005355] = 05507; $code[005355] = *D05355; sub D05355 { $pc = ($ib<<12)+$core[71]; $inh = 0; goto &fetch; }
$core[005356] = 07727; $code[005356] = *D05356; sub D05356 { &emul8; goto &fetch; }
$core[005360] = 01136; $code[005360] = *L05360; sub L05360 { $lac += $core[000136]; goto &fetch; }
$core[005361] = 01376; $code[005361] = *I05361; sub I05361 { $lac += $core[005376]; goto &fetch; }
$core[005362] = 07440; $code[005362] = *I05362; sub I05362 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005363] = 07402; $code[005363] = *I05363; sub I05363 { $hlt = 1; goto &fetch; }
$core[005364] = 01136; $code[005364] = *I05364; sub I05364 { $lac += $core[000136]; goto &fetch; }
$core[005365] = 07001; $code[005365] = *I05365; sub I05365 { $lac++; goto &fetch; }
$core[005366] = 03136; $code[005366] = *I05366; sub I05366 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005367] = 01374; $code[005367] = *I05367; sub I05367 { $lac += $core[005374]; goto &fetch; }
$core[005370] = 03434; $code[005370] = *I05370; sub I05370 { $core[($df<<12)+$core[28]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[28]] = *emul8; goto &fetch; }
$core[005371] = 01375; $code[005371] = *I05371; sub I05371 { $lac += $core[005375]; goto &fetch; }
$core[005372] = 03443; $code[005372] = *I05372; sub I05372 { $core[($df<<12)+$core[35]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[35]] = *emul8; goto &fetch; }
$core[005373] = 05434; $code[005373] = *I05373; sub I05373 { $pc = ($ib<<12)+$core[28]; $inh = 0; goto &fetch; }
$core[005374] = 05443; $code[005374] = *D05374; sub D05374 { $pc = ($ib<<12)+$core[35]; $inh = 0; goto &fetch; }
$core[005375] = 05510; $code[005375] = *D05375; sub D05375 { $pc = ($ib<<12)+$core[72]; $inh = 0; goto &fetch; }
$core[005376] = 07726; $code[005376] = *D05376; sub D05376 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[005400] = 01136; $code[005400] = *L05400; sub L05400 { $lac += $core[000136]; goto &fetch; }
$core[005401] = 01216; $code[005401] = *I05401; sub I05401 { $lac += $core[005416]; goto &fetch; }
$core[005402] = 07440; $code[005402] = *I05402; sub I05402 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005403] = 07402; $code[005403] = *I05403; sub I05403 { $hlt = 1; goto &fetch; }
$core[005404] = 01136; $code[005404] = *I05404; sub I05404 { $lac += $core[000136]; goto &fetch; }
$core[005405] = 07001; $code[005405] = *I05405; sub I05405 { $lac++; goto &fetch; }
$core[005406] = 03136; $code[005406] = *I05406; sub I05406 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005407] = 01214; $code[005407] = *I05407; sub I05407 { $lac += $core[005414]; goto &fetch; }
$core[005410] = 03435; $code[005410] = *I05410; sub I05410 { $core[($df<<12)+$core[29]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[29]] = *emul8; goto &fetch; }
$core[005411] = 01215; $code[005411] = *I05411; sub I05411 { $lac += $core[005415]; goto &fetch; }
$core[005412] = 03442; $code[005412] = *I05412; sub I05412 { $core[($df<<12)+$core[34]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[34]] = *emul8; goto &fetch; }
$core[005413] = 05435; $code[005413] = *I05413; sub I05413 { $pc = ($ib<<12)+$core[29]; $inh = 0; goto &fetch; }
$core[005414] = 05442; $code[005414] = *D05414; sub D05414 { $pc = ($ib<<12)+$core[34]; $inh = 0; goto &fetch; }
$core[005415] = 05511; $code[005415] = *D05415; sub D05415 { $pc = ($ib<<12)+$core[73]; $inh = 0; goto &fetch; }
$core[005416] = 07725; $code[005416] = *D05416; sub D05416 { &emul8; goto &fetch; }
$core[005420] = 01136; $code[005420] = *L05420; sub L05420 { $lac += $core[000136]; goto &fetch; }
$core[005421] = 01236; $code[005421] = *I05421; sub I05421 { $lac += $core[005436]; goto &fetch; }
$core[005422] = 07440; $code[005422] = *I05422; sub I05422 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005423] = 07402; $code[005423] = *I05423; sub I05423 { $hlt = 1; goto &fetch; }
$core[005424] = 01136; $code[005424] = *I05424; sub I05424 { $lac += $core[000136]; goto &fetch; }
$core[005425] = 07001; $code[005425] = *I05425; sub I05425 { $lac++; goto &fetch; }
$core[005426] = 03136; $code[005426] = *I05426; sub I05426 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005427] = 01234; $code[005427] = *I05427; sub I05427 { $lac += $core[005434]; goto &fetch; }
$core[005430] = 03436; $code[005430] = *I05430; sub I05430 { $core[($df<<12)+$core[30]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[30]] = *emul8; goto &fetch; }
$core[005431] = 01235; $code[005431] = *I05431; sub I05431 { $lac += $core[005435]; goto &fetch; }
$core[005432] = 03437; $code[005432] = *I05432; sub I05432 { $core[($df<<12)+$core[31]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[31]] = *emul8; goto &fetch; }
$core[005433] = 05436; $code[005433] = *I05433; sub I05433 { $pc = ($ib<<12)+$core[30]; $inh = 0; goto &fetch; }
$core[005434] = 05437; $code[005434] = *D05434; sub D05434 { $pc = ($ib<<12)+$core[31]; $inh = 0; goto &fetch; }
$core[005435] = 05512; $code[005435] = *D05435; sub D05435 { $pc = ($ib<<12)+$core[74]; $inh = 0; goto &fetch; }
$core[005436] = 07724; $code[005436] = *D05436; sub D05436 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005440] = 01136; $code[005440] = *L05440; sub L05440 { $lac += $core[000136]; goto &fetch; }
$core[005441] = 01250; $code[005441] = *I05441; sub I05441 { $lac += $core[005450]; goto &fetch; }
$core[005442] = 07440; $code[005442] = *I05442; sub I05442 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[005443] = 07402; $code[005443] = *I05443; sub I05443 { $hlt = 1; goto &fetch; }
$core[005444] = 01136; $code[005444] = *I05444; sub I05444 { $lac += $core[000136]; goto &fetch; }
$core[005445] = 07001; $code[005445] = *I05445; sub I05445 { $lac++; goto &fetch; }
$core[005446] = 03136; $code[005446] = *I05446; sub I05446 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[005447] = 05651; $code[005447] = *I05447; sub I05447 { $pc = ($ib<<12)+$core[2857]; $inh = 0; goto &fetch; }
$core[005450] = 07723; $code[005450] = *D05450; sub D05450 { &emul8; goto &fetch; }
$core[005451] = 02002; $code[005451] = *P05451; sub P05451 { if (++$core[000002] == 010000) { $core[000002] = 0; $pc++; }$code[000002] = *emul8; goto &fetch; }
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

