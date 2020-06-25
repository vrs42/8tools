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
$core[000001] = 05402; $code[000001] = *D00001; sub D00001 { $pc = ($ib<<12)+$core[2]; $inh = 0; goto &fetch; }
$core[000002] = 02603; $code[000002] = *P00002; sub P00002 { if (++$core[($df<<12)+$core[3]] == 010000) { $core[($df<<12)+$core[3]] = 0; $pc++; }$code[($df<<12)+$core[3]] = *emul8; goto &fetch; }
$core[000003] = 07477; $code[000003] = *P00003; sub P00003 { &emul8; goto &fetch; }
$core[000004] = 00000; $code[000004] = *P00004; sub P00004 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000005] = 00013; $code[000005] = *D00005; sub D00005 { $lac &= (010000|$core[000013]); goto &fetch; }
$core[000006] = 00100; $code[000006] = *D00006; sub D00006 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000007] = 06600; $code[000007] = *P00007; sub P00007 { &emul8; goto &fetch; }
$core[000010] = 00000; $code[000010] = *P00010; sub P00010 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000011] = 00000; $code[000011] = *P00011; sub P00011 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000012] = 00000; $code[000012] = *P00012; sub P00012 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000013] = 00000; $code[000013] = *P00013; sub P00013 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000014] = 03377; $code[000014] = *P00014; sub P00014 { $core[000177] = $lac & 07777; $lac &= 010000; $code[000177] = *emul8; goto &fetch; }
$core[000015] = 00200; $code[000015] = *D00015; sub D00015 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000016] = 00000; $code[000016] = *P00016; sub P00016 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000017] = 03430; $code[000017] = *P00017; sub P00017 { $core[($df<<12)+$core[24]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[000020] = 00000; $code[000020] = *P00020; sub P00020 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000021] = 00000; $code[000021] = *P00021; sub P00021 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000022] = 00256; $code[000022] = *D00022; sub D00022 { $lac &= (010000|$core[000056]); goto &fetch; }
$core[000023] = 07701; $code[000023] = *D00023; sub D00023 { &emul8; goto &fetch; }
$core[000024] = 07600; $code[000024] = *P00024; sub P00024 { $lac &= 010000; goto &fetch; }
$core[000025] = 07760; $code[000025] = *D00025; sub D00025 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000026] = 00177; $code[000026] = *P00026; sub P00026 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[000027] = 05577; $code[000027] = *D00027; sub D00027 { $pc = ($ib<<12)+$core[127]; $inh = 0; goto &fetch; }
$core[000030] = 07332; $code[000030] = *P00030; sub P00030 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000031] = 00017; $code[000031] = *D00031; sub D00031 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[000032] = 00277; $code[000032] = *P00032; sub P00032 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[000033] = 00240; $code[000033] = *D00033; sub D00033 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000034] = 07776; $code[000034] = *D00034; sub D00034 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000035] = 00002; $code[000035] = *P00035; sub P00035 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000036] = 00260; $code[000036] = *D00036; sub D00036 { $lac &= (010000|$core[000060]); goto &fetch; }
$core[000037] = 00000; $code[000037] = *D00037; sub D00037 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000040] = 00000; $code[000040] = *P00040; sub P00040 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000041] = 00000; $code[000041] = *D00041; sub D00041 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000042] = 00000; $code[000042] = *D00042; sub D00042 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000043] = 00000; $code[000043] = *P00043; sub P00043 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000044] = 00000; $code[000044] = *D00044; sub D00044 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000045] = 00000; $code[000045] = *D00045; sub D00045 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000046] = 00000; $code[000046] = *D00046; sub D00046 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000047] = 00000; $code[000047] = *D00047; sub D00047 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000050] = 06676; $code[000050] = *P00050; sub P00050 { &emul8; goto &fetch; }
$core[000051] = 00010; $code[000051] = *P00051; sub P00051 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[000052] = 07311; $code[000052] = *P00052; sub P00052 { $lac &= 010000; $lac &= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000053] = 00000; $code[000053] = *D00053; sub D00053 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000054] = 00337; $code[000054] = *P00054; sub P00054 { $lac &= (010000|$core[000137]); goto &fetch; }
$core[000055] = 00214; $code[000055] = *D00055; sub D00055 { $lac &= (010000|$core[000014]); goto &fetch; }
$core[000056] = 00207; $code[000056] = *D00056; sub D00056 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000057] = 00212; $code[000057] = *D00057; sub D00057 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000060] = 00215; $code[000060] = *D00060; sub D00060 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000061] = 00000; $code[000061] = *D00061; sub D00061 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000062] = 07700; $code[000062] = *D00062; sub D00062 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000063] = 07540; $code[000063] = *P00063; sub P00063 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000064] = 07522; $code[000064] = *D00064; sub D00064 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $hlt = 1; goto &fetch; }
$core[000065] = 07563; $code[000065] = *P00065; sub P00065 { &emul8; goto &fetch; }
$core[000066] = 07775; $code[000066] = *P00066; sub P00066 { &emul8; goto &fetch; }
$core[000067] = 07773; $code[000067] = *D00067; sub D00067 { &emul8; goto &fetch; }
$core[000070] = 07767; $code[000070] = *D00070; sub D00070 { &emul8; goto &fetch; }
$core[000071] = 00077; $code[000071] = *P00071; sub P00071 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[000072] = 06170; $code[000072] = *P00072; sub P00072 { &emul8; goto &fetch; }
$core[000073] = 05600; $code[000073] = *P00073; sub P00073 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[000074] = 02527; $code[000074] = *D00074; sub D00074 { if (++$core[($df<<12)+$core[87]] == 010000) { $core[($df<<12)+$core[87]] = 0; $pc++; }$code[($df<<12)+$core[87]] = *emul8; goto &fetch; }
$core[000075] = 03420; $code[000075] = *P00075; sub P00075 { $core[($df<<12)+$core[16]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[16]] = *emul8; goto &fetch; }
$core[000076] = 03432; $code[000076] = *I00076; sub I00076 { $core[($df<<12)+$core[26]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[26]] = *emul8; goto &fetch; }
$core[000077] = 03432; $code[000077] = *P00077; sub P00077 { $core[($df<<12)+$core[26]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[26]] = *emul8; goto &fetch; }
$core[000100] = 02056; $code[000100] = *P00100; sub P00100 { if (++$core[000056] == 010000) { $core[000056] = 0; $pc++; }$code[000056] = *emul8; goto &fetch; }
$core[000101] = 00523; $code[000101] = *P00101; sub P00101 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[000102] = 01556; $code[000102] = *P00102; sub P00102 { $lac += $core[($df<<12)+$core[110]]; goto &fetch; }
$core[000103] = 00501; $code[000103] = *P00103; sub P00103 { $lac &= (010000|$core[($df<<12)+$core[65]]); goto &fetch; }
$core[000104] = 00532; $code[000104] = *P00104; sub P00104 { $lac &= (010000|$core[($df<<12)+$core[90]]); goto &fetch; }
$core[000105] = 00550; $code[000105] = *P00105; sub P00105 { $lac &= (010000|$core[($df<<12)+$core[104]]); goto &fetch; }
$core[000106] = 02315; $code[000106] = *P00106; sub P00106 { if (++$core[000115] == 010000) { $core[000115] = 0; $pc++; }$code[000115] = *emul8; goto &fetch; }
$core[000107] = 03023; $code[000107] = *P00107; sub P00107 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[000110] = 01333; $code[000110] = *P00110; sub P00110 { $lac += $core[000133]; goto &fetch; }
$core[000111] = 00733; $code[000111] = *P00111; sub P00111 { $lac &= (010000|$core[($df<<12)+$core[91]]); goto &fetch; }
$core[000112] = 02477; $code[000112] = *P00112; sub P00112 { if (++$core[($df<<12)+$core[63]] == 010000) { $core[($df<<12)+$core[63]] = 0; $pc++; }$code[($df<<12)+$core[63]] = *emul8; goto &fetch; }
$core[000113] = 02463; $code[000113] = *P00113; sub P00113 { if (++$core[($df<<12)+$core[51]] == 010000) { $core[($df<<12)+$core[51]] = 0; $pc++; }$code[($df<<12)+$core[51]] = *emul8; goto &fetch; }
$core[000114] = 06151; $code[000114] = *P00114; sub P00114 { &emul8; goto &fetch; }
$core[000115] = 00312; $code[000115] = *P00115; sub P00115 { $lac &= (010000|$core[000112]); goto &fetch; }
$core[000116] = 02265; $code[000116] = *P00116; sub P00116 { if (++$core[000065] == 010000) { $core[000065] = 0; $pc++; }$code[000065] = *emul8; goto &fetch; }
$core[000117] = 02417; $code[000117] = *P00117; sub P00117 { $core[000017] = 0000 if ++$core[000017] == 010000; if (++$core[($df<<12)+$core[000017]] == 010000) { $core[($df<<12)+$core[000017]] = 0; $pc++; }$code[($df<<12)+$core[000017]] = *emul8; goto &fetch; }
$core[000120] = 00305; $code[000120] = *P00120; sub P00120 { $lac &= (010000|$core[000105]); goto &fetch; }
$core[000121] = 01524; $code[000121] = *P00121; sub P00121 { $lac += $core[($df<<12)+$core[84]]; goto &fetch; }
$core[000122] = 01533; $code[000122] = *P00122; sub P00122 { $lac += $core[($df<<12)+$core[91]]; goto &fetch; }
$core[000123] = 02077; $code[000123] = *P00123; sub P00123 { if (++$core[000077] == 010000) { $core[000077] = 0; $pc++; }$code[000077] = *emul8; goto &fetch; }
$core[000124] = 02451; $code[000124] = *P00124; sub P00124 { if (++$core[($df<<12)+$core[41]] == 010000) { $core[($df<<12)+$core[41]] = 0; $pc++; }$code[($df<<12)+$core[41]] = *emul8; goto &fetch; }
$core[000125] = 00713; $code[000125] = *P00125; sub P00125 { $lac &= (010000|$core[($df<<12)+$core[75]]); goto &fetch; }
$core[000126] = 02736; $code[000126] = *P00126; sub P00126 { if (++$core[($df<<12)+$core[94]] == 010000) { $core[($df<<12)+$core[94]] = 0; $pc++; }$code[($df<<12)+$core[94]] = *emul8; goto &fetch; }
$core[000127] = 00000; $code[000127] = *P00127; sub P00127 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000130] = 00000; $code[000130] = *D00130; sub D00130 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000131] = 00000; $code[000131] = *D00131; sub D00131 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000132] = 07760; $code[000132] = *P00132; sub P00132 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000133] = 00004; $code[000133] = *P00133; sub P00133 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[000134] = 03432; $code[000134] = *P00134; sub P00134 { $core[($df<<12)+$core[26]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[26]] = *emul8; goto &fetch; }
$core[000135] = 00000; $code[000135] = *D00135; sub D00135 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000136] = 00000; $code[000136] = *P00136; sub P00136 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000137] = 02675; $code[000137] = *P00137; sub P00137 { if (++$core[($df<<12)+$core[61]] == 010000) { $core[($df<<12)+$core[61]] = 0; $pc++; }$code[($df<<12)+$core[61]] = *emul8; goto &fetch; }
$core[000140] = 02665; $code[000140] = *P00140; sub P00140 { if (++$core[($df<<12)+$core[53]] == 010000) { $core[($df<<12)+$core[53]] = 0; $pc++; }$code[($df<<12)+$core[53]] = *emul8; goto &fetch; }
$core[000141] = 00001; $code[000141] = *D00141; sub D00141 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000142] = 00215; $code[000142] = *D00142; sub D00142 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000143] = 00000; $code[000143] = *D00143; sub D00143 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000144] = 00005; $code[000144] = *D00144; sub D00144 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[000145] = 01575; $code[000145] = *P00145; sub P00145 { $lac += $core[($df<<12)+$core[125]]; goto &fetch; }
$core[000146] = 00000; $code[000146] = *P00146; sub P00146 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000147] = 00000; $code[000147] = *D00147; sub D00147 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000150] = 00000; $code[000150] = *P00150; sub P00150 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000151] = 00001; $code[000151] = *P00151; sub P00151 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000152] = 00001; $code[000152] = *D00152; sub D00152 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000153] = 00000; $code[000153] = *D00153; sub D00153 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000154] = 00000; $code[000154] = *P00154; sub P00154 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000155] = 03432; $code[000155] = *D00155; sub D00155 { $core[($df<<12)+$core[26]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[26]] = *emul8; goto &fetch; }
$core[000156] = 00000; $code[000156] = *P00156; sub P00156 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000157] = 00000; $code[000157] = *P00157; sub P00157 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000160] = 02034; $code[000160] = *P00160; sub P00160 { if (++$core[000034] == 010000) { $core[000034] = 0; $pc++; }$code[000034] = *emul8; goto &fetch; }
$core[000161] = 02463; $code[000161] = *D00161; sub D00161 { if (++$core[($df<<12)+$core[51]] == 010000) { $core[($df<<12)+$core[51]] = 0; $pc++; }$code[($df<<12)+$core[51]] = *emul8; goto &fetch; }
$core[000162] = 00000; $code[000162] = *D00162; sub D00162 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000163] = 00000; $code[000163] = *D00163; sub D00163 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000164] = 00000; $code[000164] = *D00164; sub D00164 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000165] = 02514; $code[000165] = *P00165; sub P00165 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[000176] = 03432; $code[000176] = *P00176; sub P00176 { $core[($df<<12)+$core[26]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[26]] = *emul8; goto &fetch; }
$core[000177] = 07610; $code[000177] = *P00177; sub P00177 { $skp = 0; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000200] = 05576; $code[000200] = *I00200; sub I00200 { $pc = ($ib<<12)+$core[126]; $inh = 0; goto &fetch; }
$core[000201] = 01227; $code[000201] = *P00201; sub P00201 { $lac += $core[000227]; goto &fetch; }
$core[000202] = 03145; $code[000202] = *I00202; sub I00202 { $core[000145] = $lac & 07777; $lac &= 010000; $code[000145] = *emul8; goto &fetch; }
$core[000203] = 03151; $code[000203] = *I00203; sub I00203 { $core[000151] = $lac & 07777; $lac &= 010000; $code[000151] = *emul8; goto &fetch; }
$core[000204] = 01226; $code[000204] = *I00204; sub I00204 { $lac += $core[000226]; goto &fetch; }
$core[000205] = 03013; $code[000205] = *I00205; sub I00205 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[000206] = 02152; $code[000206] = *I00206; sub I00206 { if (++$core[000152] == 010000) { $core[000152] = 0; $pc++; }$code[000152] = *emul8; goto &fetch; }
$core[000207] = 03061; $code[000207] = *I00207; sub I00207 { $core[000061] = $lac & 07777; $lac &= 010000; $code[000061] = *emul8; goto &fetch; }
$core[000210] = 01054; $code[000210] = *I00210; sub I00210 { $lac += $core[000054]; goto &fetch; }
$core[000211] = 04512; $code[000211] = *I00211; sub I00211 { $core[($ib<<12)+$core[74]] = 00212; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[000212] = 01074; $code[000212] = *P00212; sub P00212 { $lac += $core[000074]; goto &fetch; }
$core[000213] = 03010; $code[000213] = *I00213; sub I00213 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000214] = 03136; $code[000214] = *I00214; sub I00214 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[000215] = 01074; $code[000215] = *I00215; sub I00215 { $lac += $core[000074]; goto &fetch; }
$core[000216] = 03153; $code[000216] = *P00216; sub P00216 { $core[000153] = $lac & 07777; $lac &= 010000; $code[000153] = *emul8; goto &fetch; }
$core[000217] = 04513; $code[000217] = *L00217; sub L00217 { $core[($ib<<12)+$core[75]] = 00220; $pc = ($ib<<12)+$core[75]+1; $code[($ib<<12)+$core[75]] = *emul8; $inh = 0; goto &fetch; }
$core[000220] = 04510; $code[000220] = *I00220; sub I00220 { $core[($ib<<12)+$core[72]] = 00221; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[000221] = 00053; $code[000221] = *I00221; sub I00221 { $lac &= (010000|$core[000053]); goto &fetch; }
$core[000222] = 00510; $code[000222] = *I00222; sub I00222 { $lac &= (010000|$core[($df<<12)+$core[72]]); goto &fetch; }
$core[000223] = 04507; $code[000223] = *I00223; sub I00223 { $core[($ib<<12)+$core[71]] = 00224; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[000224] = 05217; $code[000224] = *I00224; sub I00224 { $pc = 000217; $inh = 0; goto &fetch; }
$core[000225] = 04000; $code[000225] = *D00225; sub D00225 { $core[000000] = 00226; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000226] = 02612; $code[000226] = *D00226; sub D00226 { if (++$core[($df<<12)+$core[138]] == 010000) { $core[($df<<12)+$core[138]] = 0; $pc++; }$code[($df<<12)+$core[138]] = *emul8; goto &fetch; }
$core[000227] = 01575; $code[000227] = *D00227; sub D00227 { $lac += $core[($df<<12)+$core[125]]; goto &fetch; }
$core[000230] = 04507; $code[000230] = *L00230; sub L00230 { $core[($ib<<12)+$core[71]] = 00231; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[000231] = 04507; $code[000231] = *I00231; sub I00231 { $core[($ib<<12)+$core[71]] = 00232; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[000232] = 01074; $code[000232] = *I00232; sub I00232 { $lac += $core[000074]; goto &fetch; }
$core[000233] = 03017; $code[000233] = *L00233; sub L00233 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[000234] = 03020; $code[000234] = *I00234; sub I00234 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[000235] = 04506; $code[000235] = *I00235; sub I00235 { $core[($ib<<12)+$core[70]] = 00236; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[000236] = 01027; $code[000236] = *I00236; sub I00236 { $lac += $core[000027]; goto &fetch; }
$core[000237] = 03013; $code[000237] = *I00237; sub I00237 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[000240] = 04521; $code[000240] = *I00240; sub I00240 { $core[($ib<<12)+$core[81]] = 00241; $pc = ($ib<<12)+$core[81]+1; $code[($ib<<12)+$core[81]] = *emul8; $inh = 0; goto &fetch; }
$core[000241] = 04522; $code[000241] = *I00241; sub I00241 { $core[($ib<<12)+$core[82]] = 00242; $pc = ($ib<<12)+$core[82]+1; $code[($ib<<12)+$core[82]] = *emul8; $inh = 0; goto &fetch; }
$core[000242] = 04526; $code[000242] = *D00242; sub D00242 { $core[($ib<<12)+$core[86]] = 00243; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000243] = 05274; $code[000243] = *I00243; sub I00243 { $pc = 000274; $inh = 0; goto &fetch; }
$core[000244] = 06002; $code[000244] = *I00244; sub I00244 { &emul8; goto &fetch; }
$core[000245] = 02151; $code[000245] = *I00245; sub I00245 { if (++$core[000151] == 010000) { $core[000151] = 0; $pc++; }$code[000151] = *emul8; goto &fetch; }
$core[000246] = 04515; $code[000246] = *I00246; sub I00246 { $core[($ib<<12)+$core[77]] = 00247; $pc = ($ib<<12)+$core[77]+1; $code[($ib<<12)+$core[77]] = *emul8; $inh = 0; goto &fetch; }
$core[000247] = 01141; $code[000247] = *I00247; sub I00247 { $lac += $core[000141]; goto &fetch; }
$core[000250] = 01225; $code[000250] = *I00250; sub I00250 { $lac += $core[000225]; goto &fetch; }
$core[000251] = 07640; $code[000251] = *I00251; sub I00251 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000252] = 04526; $code[000252] = *I00252; sub I00252 { $core[($ib<<12)+$core[86]] = 00253; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000253] = 01134; $code[000253] = *I00253; sub I00253 { $lac += $core[000134]; goto &fetch; }
$core[000254] = 03010; $code[000254] = *I00254; sub I00254 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000255] = 03136; $code[000255] = *D00255; sub D00255 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[000256] = 01143; $code[000256] = *I00256; sub I00256 { $lac += $core[000143]; goto &fetch; }
$core[000257] = 03410; $code[000257] = *I00257; sub I00257 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000260] = 04521; $code[000260] = *I00260; sub I00260 { $core[($ib<<12)+$core[81]] = 00261; $pc = ($ib<<12)+$core[81]+1; $code[($ib<<12)+$core[81]] = *emul8; $inh = 0; goto &fetch; }
$core[000261] = 07410; $code[000261] = *I00261; sub I00261 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000262] = 04506; $code[000262] = *L00262; sub L00262 { $core[($ib<<12)+$core[70]] = 00263; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[000263] = 04507; $code[000263] = *I00263; sub I00263 { $core[($ib<<12)+$core[71]] = 00264; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[000264] = 01142; $code[000264] = *I00264; sub I00264 { $lac += $core[000142]; goto &fetch; }
$core[000265] = 01065; $code[000265] = *I00265; sub I00265 { $lac += $core[000065]; goto &fetch; }
$core[000266] = 07640; $code[000266] = *I00266; sub I00266 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000267] = 05262; $code[000267] = *I00267; sub I00267 { $pc = 000262; $inh = 0; goto &fetch; }
$core[000270] = 04501; $code[000270] = *I00270; sub I00270 { $core[($ib<<12)+$core[65]] = 00271; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[000271] = 02111; $code[000271] = *I00271; sub I00271 { if (++$core[000111] == 010000) { $core[000111] = 0; $pc++; }$code[000111] = *emul8; goto &fetch; }
$core[000272] = 04517; $code[000272] = *I00272; sub I00272 { $core[($ib<<12)+$core[79]] = 00273; $pc = ($ib<<12)+$core[79]+1; $code[($ib<<12)+$core[79]] = *emul8; $inh = 0; goto &fetch; }
$core[000273] = 05177; $code[000273] = *I00273; sub I00273 { $pc = 000177; $inh = 0; goto &fetch; }
$core[000274] = 04501; $code[000274] = *L00274; sub L00274 { $core[($ib<<12)+$core[65]] = 00275; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[000275] = 00616; $code[000275] = *I00275; sub I00275 { $lac &= (010000|$core[($df<<12)+$core[142]]); goto &fetch; }
$core[000276] = 01545; $code[000276] = *I00276; sub I00276 { $lac += $core[($df<<12)+$core[101]]; goto &fetch; }
$core[000277] = 07450; $code[000277] = *D00277; sub D00277 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000300] = 05177; $code[000300] = *I00300; sub I00300 { $pc = 000177; $inh = 0; goto &fetch; }
$core[000301] = 03145; $code[000301] = *I00301; sub I00301 { $core[000145] = $lac & 07777; $lac &= 010000; $code[000145] = *emul8; goto &fetch; }
$core[000302] = 01145; $code[000302] = *I00302; sub I00302 { $lac += $core[000145]; goto &fetch; }
$core[000303] = 07001; $code[000303] = *I00303; sub I00303 { $lac++; goto &fetch; }
$core[000304] = 05233; $code[000304] = *I00304; sub I00304 { $pc = 000233; $inh = 0; goto &fetch; }
$core[000305] = 00000; $code[000305] = *S00305; sub S00305 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000306] = 07106; $code[000306] = *I00306; sub I00306 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000307] = 07006; $code[000307] = *I00307; sub I00307 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000310] = 07006; $code[000310] = *I00310; sub I00310 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000311] = 05705; $code[000311] = *I00311; sub I00311 { $pc = ($ib<<12)+$core[197]; $inh = 0; goto &fetch; }
$core[000312] = 00000; $code[000312] = *S00312; sub S00312 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000313] = 04521; $code[000313] = *I00313; sub I00313 { $core[($ib<<12)+$core[81]] = 00314; $pc = ($ib<<12)+$core[81]+1; $code[($ib<<12)+$core[81]] = *emul8; $inh = 0; goto &fetch; }
$core[000314] = 01225; $code[000314] = *I00314; sub I00314 { $lac += $core[000225]; goto &fetch; }
$core[000315] = 03141; $code[000315] = *I00315; sub I00315 { $core[000141] = $lac & 07777; $lac &= 010000; $code[000141] = *emul8; goto &fetch; }
$core[000316] = 04511; $code[000316] = *D00316; sub D00316 { $core[($ib<<12)+$core[73]] = 00317; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[000317] = 06114; $code[000317] = *I00317; sub I00317 { &emul8; goto &fetch; }
$core[000320] = 05370; $code[000320] = *I00320; sub I00320 { $pc = 000370; $inh = 0; goto &fetch; }
$core[000321] = 04766; $code[000321] = *I00321; sub I00321 { $core[($ib<<12)+$core[246]] = 00322; $pc = ($ib<<12)+$core[246]+1; $code[($ib<<12)+$core[246]] = *emul8; $inh = 0; goto &fetch; }
$core[000322] = 04522; $code[000322] = *I00322; sub I00322 { $core[($ib<<12)+$core[82]] = 00323; $pc = ($ib<<12)+$core[82]+1; $code[($ib<<12)+$core[82]] = *emul8; $inh = 0; goto &fetch; }
$core[000323] = 04506; $code[000323] = *I00323; sub I00323 { $core[($ib<<12)+$core[70]] = 00324; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[000324] = 04356; $code[000324] = *I00324; sub I00324 { $core[000356] = 00325; $pc = 000356+1; $code[000356] = *emul8; $inh = 0; goto &fetch; }
$core[000325] = 07106; $code[000325] = *I00325; sub I00325 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000326] = 01127; $code[000326] = *I00326; sub I00326 { $lac += $core[000127]; goto &fetch; }
$core[000327] = 07004; $code[000327] = *I00327; sub I00327 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000330] = 04356; $code[000330] = *I00330; sub I00330 { $core[000356] = 00331; $pc = 000356+1; $code[000356] = *emul8; $inh = 0; goto &fetch; }
$core[000331] = 01143; $code[000331] = *L00331; sub L00331 { $lac += $core[000143]; goto &fetch; }
$core[000332] = 07450; $code[000332] = *L00332; sub L00332 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000333] = 03141; $code[000333] = *I00333; sub I00333 { $core[000141] = $lac & 07777; $lac &= 010000; $code[000141] = *emul8; goto &fetch; }
$core[000334] = 03143; $code[000334] = *I00334; sub I00334 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[000335] = 01164; $code[000335] = *I00335; sub I00335 { $lac += $core[000164]; goto &fetch; }
$core[000336] = 07450; $code[000336] = *I00336; sub I00336 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000337] = 05347; $code[000337] = *D00337; sub D00337 { $pc = 000347; $inh = 0; goto &fetch; }
$core[000340] = 04520; $code[000340] = *I00340; sub I00340 { $core[($ib<<12)+$core[80]] = 00341; $pc = ($ib<<12)+$core[80]+1; $code[($ib<<12)+$core[80]] = *emul8; $inh = 0; goto &fetch; }
$core[000341] = 07004; $code[000341] = *I00341; sub I00341 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000342] = 01143; $code[000342] = *I00342; sub I00342 { $lac += $core[000143]; goto &fetch; }
$core[000343] = 03143; $code[000343] = *I00343; sub I00343 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[000344] = 01164; $code[000344] = *I00344; sub I00344 { $lac += $core[000164]; goto &fetch; }
$core[000345] = 00367; $code[000345] = *I00345; sub I00345 { $lac &= (010000|$core[000367]); goto &fetch; }
$core[000346] = 05351; $code[000346] = *I00346; sub I00346 { $pc = 000351; $inh = 0; goto &fetch; }
$core[000347] = 02141; $code[000347] = *L00347; sub L00347 { if (++$core[000141] == 010000) { $core[000141] = 0; $pc++; }$code[000141] = *emul8; goto &fetch; }
$core[000350] = 01143; $code[000350] = *I00350; sub I00350 { $lac += $core[000143]; goto &fetch; }
$core[000351] = 07650; $code[000351] = *L00351; sub L00351 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000352] = 04522; $code[000352] = *I00352; sub I00352 { $core[($ib<<12)+$core[82]] = 00353; $pc = ($ib<<12)+$core[82]+1; $code[($ib<<12)+$core[82]] = *emul8; $inh = 0; goto &fetch; }
$core[000353] = 05361; $code[000353] = *I00353; sub I00353 { $pc = 000361; $inh = 0; goto &fetch; }
$core[000354] = 05712; $code[000354] = *I00354; sub I00354 { $pc = ($ib<<12)+$core[202]; $inh = 0; goto &fetch; }
$core[000355] = 05361; $code[000355] = *I00355; sub I00355 { $pc = 000361; $inh = 0; goto &fetch; }
$core[000356] = 00000; $code[000356] = *S00356; sub S00356 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000357] = 03143; $code[000357] = *I00357; sub I00357 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[000360] = 04522; $code[000360] = *I00360; sub I00360 { $core[($ib<<12)+$core[82]] = 00361; $pc = ($ib<<12)+$core[82]+1; $code[($ib<<12)+$core[82]] = *emul8; $inh = 0; goto &fetch; }
$core[000361] = 04526; $code[000361] = *L00361; sub L00361 { $core[($ib<<12)+$core[86]] = 00362; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000362] = 05331; $code[000362] = *I00362; sub I00362 { $pc = 000331; $inh = 0; goto &fetch; }
$core[000363] = 04506; $code[000363] = *I00363; sub I00363 { $core[($ib<<12)+$core[70]] = 00364; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[000364] = 01127; $code[000364] = *I00364; sub I00364 { $lac += $core[000127]; goto &fetch; }
$core[000365] = 05756; $code[000365] = *I00365; sub I00365 { $pc = ($ib<<12)+$core[238]; $inh = 0; goto &fetch; }
$core[000366] = 06010; $code[000366] = *P00366; sub P00366 { &emul8; goto &fetch; }
$core[000367] = 07760; $code[000367] = *D00367; sub D00367 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000370] = 04501; $code[000370] = *L00370; sub L00370 { $core[($ib<<12)+$core[65]] = 00371; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[000371] = 01601; $code[000371] = *I00371; sub I00371 { $lac += $core[($df<<12)+$core[129]]; goto &fetch; }
$core[000372] = 04452; $code[000372] = *I00372; sub I00372 { $core[($ib<<12)+$core[42]] = 00373; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[000373] = 04503; $code[000373] = *I00373; sub I00373 { $core[($ib<<12)+$core[67]] = 00374; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[000374] = 01045; $code[000374] = *I00374; sub I00374 { $lac += $core[000045]; goto &fetch; }
$core[000375] = 07640; $code[000375] = *I00375; sub I00375 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000376] = 05361; $code[000376] = *I00376; sub I00376 { $pc = 000361; $inh = 0; goto &fetch; }
$core[000377] = 04407; $code[000377] = *I00377; sub I00377 { $core[($ib<<12)+$core[7]] = 00400; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[000400] = 07000; $code[000400] = *I00400; sub I00400 { &emul8; goto &fetch; }
$core[000401] = 02560; $code[000401] = *I00401; sub I00401 { &emul8; goto &fetch; }
$core[000402] = 03614; $code[000402] = *I00402; sub I00402 { &emul8; goto &fetch; }
$core[000403] = 03614; $code[000403] = *I00403; sub I00403 { &emul8; goto &fetch; }
$core[000404] = 02615; $code[000404] = *I00404; sub I00404 { &emul8; goto &fetch; }
$core[000405] = 00000; $code[000405] = *I00405; sub I00405 { &emul8; goto &fetch; }
$core[000406] = 04450; $code[000406] = *I00406; sub I00406 { $core[($ib<<12)+$core[40]] = 00407; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[000407] = 01413; $code[000407] = *I00407; sub I00407 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[000410] = 03164; $code[000410] = *I00410; sub I00410 { $core[000164] = $lac & 07777; $lac &= 010000; $code[000164] = *emul8; goto &fetch; }
$core[000411] = 04452; $code[000411] = *I00411; sub I00411 { $core[($ib<<12)+$core[42]] = 00412; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[000412] = 05613; $code[000412] = *D00412; sub D00412 { $pc = ($ib<<12)+$core[267]; $inh = 0; goto &fetch; }
$core[000413] = 00332; $code[000413] = *P00413; sub P00413 { $lac &= (010000|$core[000532]); goto &fetch; }
$core[000414] = 05770; $code[000414] = *P00414; sub P00414 { $pc = ($ib<<12)+$core[376]; $inh = 0; goto &fetch; }
$core[000415] = 05773; $code[000415] = *P00415; sub P00415 { $pc = ($ib<<12)+$core[379]; $inh = 0; goto &fetch; }
$core[000416] = 04515; $code[000416] = *P00416; sub P00416 { $core[($ib<<12)+$core[77]] = 00417; $pc = ($ib<<12)+$core[77]+1; $code[($ib<<12)+$core[77]] = *emul8; $inh = 0; goto &fetch; }
$core[000417] = 01145; $code[000417] = *D00417; sub D00417 { $lac += $core[000145]; goto &fetch; }
$core[000420] = 04503; $code[000420] = *I00420; sub I00420 { $core[($ib<<12)+$core[67]] = 00421; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[000421] = 04504; $code[000421] = *I00421; sub I00421 { $core[($ib<<12)+$core[68]] = 00422; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[000422] = 00017; $code[000422] = *I00422; sub I00422 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[000423] = 04504; $code[000423] = *L00423; sub L00423 { $core[($ib<<12)+$core[68]] = 00424; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[000424] = 00141; $code[000424] = *I00424; sub I00424 { $lac &= (010000|$core[000141]); goto &fetch; }
$core[000425] = 01141; $code[000425] = *I00425; sub I00425 { $lac += $core[000141]; goto &fetch; }
$core[000426] = 07710; $code[000426] = *I00426; sub I00426 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000427] = 05254; $code[000427] = *I00427; sub I00427 { $pc = 000454; $inh = 0; goto &fetch; }
$core[000430] = 04516; $code[000430] = *D00430; sub D00430 { $core[($ib<<12)+$core[78]] = 00431; $pc = ($ib<<12)+$core[78]+1; $code[($ib<<12)+$core[78]] = *emul8; $inh = 0; goto &fetch; }
$core[000431] = 05273; $code[000431] = *I00431; sub I00431 { $pc = 000473; $inh = 0; goto &fetch; }
$core[000432] = 04501; $code[000432] = *L00432; sub L00432 { $core[($ib<<12)+$core[65]] = 00433; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[000433] = 00613; $code[000433] = *I00433; sub I00433 { $lac &= (010000|$core[($df<<12)+$core[267]]); goto &fetch; }
$core[000434] = 04505; $code[000434] = *I00434; sub I00434 { $core[($ib<<12)+$core[69]] = 00435; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[000435] = 00141; $code[000435] = *I00435; sub I00435 { $lac &= (010000|$core[000141]); goto &fetch; }
$core[000436] = 01545; $code[000436] = *I00436; sub I00436 { $lac += $core[($df<<12)+$core[101]]; goto &fetch; }
$core[000437] = 07450; $code[000437] = *I00437; sub I00437 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000440] = 05262; $code[000440] = *I00440; sub I00440 { $pc = 000462; $inh = 0; goto &fetch; }
$core[000441] = 07001; $code[000441] = *I00441; sub I00441 { $lac++; goto &fetch; }
$core[000442] = 03154; $code[000442] = *I00442; sub I00442 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[000443] = 01141; $code[000443] = *I00443; sub I00443 { $lac += $core[000141]; goto &fetch; }
$core[000444] = 07740; $code[000444] = *I00444; sub I00444 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000445] = 05251; $code[000445] = *I00445; sub I00445 { $pc = 000451; $inh = 0; goto &fetch; }
$core[000446] = 01554; $code[000446] = *I00446; sub I00446 { $lac += $core[($df<<12)+$core[108]]; goto &fetch; }
$core[000447] = 04524; $code[000447] = *I00447; sub I00447 { $core[($ib<<12)+$core[84]] = 00450; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[000450] = 05262; $code[000450] = *I00450; sub I00450 { $pc = 000462; $inh = 0; goto &fetch; }
$core[000451] = 01554; $code[000451] = *L00451; sub L00451 { $lac += $core[($df<<12)+$core[108]]; goto &fetch; }
$core[000452] = 03143; $code[000452] = *I00452; sub I00452 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[000453] = 05223; $code[000453] = *I00453; sub I00453 { $pc = 000423; $inh = 0; goto &fetch; }
$core[000454] = 04516; $code[000454] = *L00454; sub L00454 { $core[($ib<<12)+$core[78]] = 00455; $pc = ($ib<<12)+$core[78]+1; $code[($ib<<12)+$core[78]] = *emul8; $inh = 0; goto &fetch; }
$core[000455] = 04526; $code[000455] = *I00455; sub I00455 { $core[($ib<<12)+$core[86]] = 00456; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000456] = 04501; $code[000456] = *I00456; sub I00456 { $core[($ib<<12)+$core[65]] = 00457; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[000457] = 00615; $code[000457] = *I00457; sub I00457 { $lac &= (010000|$core[($df<<12)+$core[269]]); goto &fetch; }
$core[000460] = 04505; $code[000460] = *I00460; sub I00460 { $core[($ib<<12)+$core[69]] = 00461; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[000461] = 00141; $code[000461] = *I00461; sub I00461 { $lac &= (010000|$core[000141]); goto &fetch; }
$core[000462] = 04505; $code[000462] = *L00462; sub L00462 { $core[($ib<<12)+$core[69]] = 00463; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[000463] = 00017; $code[000463] = *I00463; sub I00463 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[000464] = 01413; $code[000464] = *I00464; sub I00464 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[000465] = 03145; $code[000465] = *I00465; sub I00465 { $core[000145] = $lac & 07777; $lac &= 010000; $code[000145] = *emul8; goto &fetch; }
$core[000466] = 04565; $code[000466] = *L00466; sub L00466 { $core[($ib<<12)+$core[117]] = 00467; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[000467] = 05266; $code[000467] = *I00467; sub I00467 { $pc = 000466; $inh = 0; goto &fetch; }
$core[000470] = 05672; $code[000470] = *I00470; sub I00470 { $pc = ($ib<<12)+$core[314]; $inh = 0; goto &fetch; }
$core[000471] = 05216; $code[000471] = *I00471; sub I00471 { $pc = 000416; $inh = 0; goto &fetch; }
$core[000472] = 00616; $code[000472] = *P00472; sub P00472 { $lac &= (010000|$core[($df<<12)+$core[270]]); goto &fetch; }
$core[000473] = 01146; $code[000473] = *L00473; sub L00473 { $lac += $core[000146]; goto &fetch; }
$core[000474] = 03011; $code[000474] = *I00474; sub I00474 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000475] = 01411; $code[000475] = *I00475; sub I00475 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[000476] = 04524; $code[000476] = *I00476; sub I00476 { $core[($ib<<12)+$core[84]] = 00477; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[000477] = 04526; $code[000477] = *I00477; sub I00477 { $core[($ib<<12)+$core[86]] = 00500; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000500] = 05232; $code[000500] = *I00500; sub I00500 { $pc = 000432; $inh = 0; goto &fetch; }
$core[000501] = 00000; $code[000501] = *S00501; sub S00501 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000502] = 03332; $code[000502] = *I00502; sub I00502 { $core[000532] = $lac & 07777; $lac &= 010000; $code[000532] = *emul8; goto &fetch; }
$core[000503] = 07040; $code[000503] = *I00503; sub I00503 { $lac ^= 07777; goto &fetch; }
$core[000504] = 04310; $code[000504] = *I00504; sub I00504 { $core[000510] = 00505; $pc = 000510+1; $code[000510] = *emul8; $inh = 0; goto &fetch; }
$core[000505] = 01332; $code[000505] = *I00505; sub I00505 { $lac += $core[000532]; goto &fetch; }
$core[000506] = 03416; $code[000506] = *I00506; sub I00506 { $core[000016] = 0000 if ++$core[000016] == 010000; $core[($df<<12)+$core[000016]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000016]] = *emul8; goto &fetch; }
$core[000507] = 05701; $code[000507] = *I00507; sub I00507 { $pc = ($ib<<12)+$core[321]; $inh = 0; goto &fetch; }
$core[000510] = 00000; $code[000510] = *S00510; sub S00510 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000511] = 01013; $code[000511] = *I00511; sub I00511 { $lac += $core[000013]; goto &fetch; }
$core[000512] = 03013; $code[000512] = *I00512; sub I00512 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[000513] = 01013; $code[000513] = *I00513; sub I00513 { $lac += $core[000013]; goto &fetch; }
$core[000514] = 03016; $code[000514] = *I00514; sub I00514 { $core[000016] = $lac & 07777; $lac &= 010000; $code[000016] = *emul8; goto &fetch; }
$core[000515] = 01013; $code[000515] = *I00515; sub I00515 { $lac += $core[000013]; goto &fetch; }
$core[000516] = 07141; $code[000516] = *I00516; sub I00516 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[000517] = 01155; $code[000517] = *I00517; sub I00517 { $lac += $core[000155]; goto &fetch; }
$core[000520] = 07630; $code[000520] = *I00520; sub I00520 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000521] = 04526; $code[000521] = *I00521; sub I00521 { $core[($ib<<12)+$core[86]] = 00522; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000522] = 05710; $code[000522] = *I00522; sub I00522 { $pc = ($ib<<12)+$core[328]; $inh = 0; goto &fetch; }
$core[000523] = 00000; $code[000523] = *S00523; sub S00523 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000524] = 07201; $code[000524] = *I00524; sub I00524 { $lac &= 010000; $lac++; goto &fetch; }
$core[000525] = 01323; $code[000525] = *I00525; sub I00525 { $lac += $core[000523]; goto &fetch; }
$core[000526] = 04301; $code[000526] = *I00526; sub I00526 { $core[000501] = 00527; $pc = 000501+1; $code[000501] = *emul8; $inh = 0; goto &fetch; }
$core[000527] = 01723; $code[000527] = *I00527; sub I00527 { $lac += $core[($df<<12)+$core[339]]; goto &fetch; }
$core[000530] = 03323; $code[000530] = *I00530; sub I00530 { $core[000523] = $lac & 07777; $lac &= 010000; $code[000523] = *emul8; goto &fetch; }
$core[000531] = 05723; $code[000531] = *I00531; sub I00531 { $pc = ($ib<<12)+$core[339]; $inh = 0; goto &fetch; }
$core[000532] = 00000; $code[000532] = *S00532; sub S00532 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000533] = 07240; $code[000533] = *I00533; sub I00533 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000534] = 01732; $code[000534] = *I00534; sub I00534 { $lac += $core[($df<<12)+$core[346]]; goto &fetch; }
$core[000535] = 03011; $code[000535] = *I00535; sub I00535 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000536] = 02332; $code[000536] = *I00536; sub I00536 { if (++$core[000532] == 010000) { $core[000532] = 0; $pc++; }$code[000532] = *emul8; goto &fetch; }
$core[000537] = 01066; $code[000537] = *I00537; sub I00537 { $lac += $core[000066]; goto &fetch; }
$core[000540] = 04310; $code[000540] = *I00540; sub I00540 { $core[000510] = 00541; $pc = 000510+1; $code[000510] = *emul8; $inh = 0; goto &fetch; }
$core[000541] = 01411; $code[000541] = *I00541; sub I00541 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[000542] = 03416; $code[000542] = *I00542; sub I00542 { $core[000016] = 0000 if ++$core[000016] == 010000; $core[($df<<12)+$core[000016]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000016]] = *emul8; goto &fetch; }
$core[000543] = 01411; $code[000543] = *I00543; sub I00543 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[000544] = 03416; $code[000544] = *I00544; sub I00544 { $core[000016] = 0000 if ++$core[000016] == 010000; $core[($df<<12)+$core[000016]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000016]] = *emul8; goto &fetch; }
$core[000545] = 01411; $code[000545] = *I00545; sub I00545 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[000546] = 03416; $code[000546] = *I00546; sub I00546 { $core[000016] = 0000 if ++$core[000016] == 010000; $core[($df<<12)+$core[000016]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000016]] = *emul8; goto &fetch; }
$core[000547] = 05732; $code[000547] = *I00547; sub I00547 { $pc = ($ib<<12)+$core[346]; $inh = 0; goto &fetch; }
$core[000550] = 00000; $code[000550] = *S00550; sub S00550 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000551] = 07240; $code[000551] = *I00551; sub I00551 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000552] = 01750; $code[000552] = *I00552; sub I00552 { $lac += $core[($df<<12)+$core[360]]; goto &fetch; }
$core[000553] = 02350; $code[000553] = *I00553; sub I00553 { if (++$core[000550] == 010000) { $core[000550] = 0; $pc++; }$code[000550] = *emul8; goto &fetch; }
$core[000554] = 03011; $code[000554] = *I00554; sub I00554 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000555] = 01413; $code[000555] = *I00555; sub I00555 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[000556] = 03411; $code[000556] = *I00556; sub I00556 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[000557] = 01413; $code[000557] = *I00557; sub I00557 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[000560] = 03411; $code[000560] = *I00560; sub I00560 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[000561] = 01413; $code[000561] = *I00561; sub I00561 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[000562] = 03411; $code[000562] = *I00562; sub I00562 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[000563] = 05750; $code[000563] = *I00563; sub I00563 { $pc = ($ib<<12)+$core[360]; $inh = 0; goto &fetch; }
$core[000564] = 00212; $code[000564] = *I00564; sub I00564 { $lac &= (010000|$core[000412]); goto &fetch; }
$core[000565] = 00223; $code[000565] = *I00565; sub I00565 { $lac &= (010000|$core[000423]); goto &fetch; }
$core[000566] = 00223; $code[000566] = *I00566; sub I00566 { $lac &= (010000|$core[000423]); goto &fetch; }
$core[000567] = 00217; $code[000567] = *I00567; sub I00567 { $lac &= (010000|$core[000417]); goto &fetch; }
$core[000570] = 00230; $code[000570] = *P00570; sub P00570 { $lac &= (010000|$core[000430]); goto &fetch; }
$core[000571] = 02053; $code[000571] = *I00571; sub I00571 { if (++$core[000053] == 010000) { $core[000053] = 0; $pc++; }$code[000053] = *emul8; goto &fetch; }
$core[000572] = 07535; $code[000572] = *I00572; sub I00572 { &emul8; goto &fetch; }
$core[000573] = 01156; $code[000573] = *P00573; sub P00573 { $lac += $core[000156]; goto &fetch; }
$core[000574] = 01145; $code[000574] = *I00574; sub I00574 { $lac += $core[000145]; goto &fetch; }
$core[000575] = 07351; $code[000575] = *I00575; sub I00575 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000576] = 01153; $code[000576] = *I00576; sub I00576 { $lac += $core[000153]; goto &fetch; }
$core[000577] = 02414; $code[000577] = *I00577; sub I00577 { $core[000014] = 0000 if ++$core[000014] == 010000; if (++$core[($df<<12)+$core[000014]] == 010000) { $core[($df<<12)+$core[000014]] = 0; $pc++; }$code[($df<<12)+$core[000014]] = *emul8; goto &fetch; }
$core[000600] = 02735; $code[000600] = *I00600; sub I00600 { if (++$core[($df<<12)+$core[477]] == 010000) { $core[($df<<12)+$core[477]] = 0; $pc++; }$code[($df<<12)+$core[477]] = *emul8; goto &fetch; }
$core[000601] = 02735; $code[000601] = *I00601; sub I00601 { if (++$core[($df<<12)+$core[477]] == 010000) { $core[($df<<12)+$core[477]] = 0; $pc++; }$code[($df<<12)+$core[477]] = *emul8; goto &fetch; }
$core[000602] = 02735; $code[000602] = *I00602; sub I00602 { if (++$core[($df<<12)+$core[477]] == 010000) { $core[($df<<12)+$core[477]] = 0; $pc++; }$code[($df<<12)+$core[477]] = *emul8; goto &fetch; }
$core[000603] = 02735; $code[000603] = *I00603; sub I00603 { if (++$core[($df<<12)+$core[477]] == 010000) { $core[($df<<12)+$core[477]] = 0; $pc++; }$code[($df<<12)+$core[477]] = *emul8; goto &fetch; }
$core[000604] = 02735; $code[000604] = *I00604; sub I00604 { if (++$core[($df<<12)+$core[477]] == 010000) { $core[($df<<12)+$core[477]] = 0; $pc++; }$code[($df<<12)+$core[477]] = *emul8; goto &fetch; }
$core[000605] = 07462; $code[000605] = *I00605; sub I00605 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $hlt = 1; goto &fetch; }
$core[000606] = 02735; $code[000606] = *D00606; sub D00606 { if (++$core[($df<<12)+$core[477]] == 010000) { $core[($df<<12)+$core[477]] = 0; $pc++; }$code[($df<<12)+$core[477]] = *emul8; goto &fetch; }
$core[000607] = 07472; $code[000607] = *D00607; sub D00607 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $hlt = 1; goto &fetch; }
$core[000610] = 04515; $code[000610] = *L00610; sub L00610 { $core[($ib<<12)+$core[77]] = 00611; $pc = ($ib<<12)+$core[77]+1; $code[($ib<<12)+$core[77]] = *emul8; $inh = 0; goto &fetch; }
$core[000611] = 04516; $code[000611] = *I00611; sub I00611 { $core[($ib<<12)+$core[78]] = 00612; $pc = ($ib<<12)+$core[78]+1; $code[($ib<<12)+$core[78]] = *emul8; $inh = 0; goto &fetch; }
$core[000612] = 04526; $code[000612] = *I00612; sub I00612 { $core[($ib<<12)+$core[86]] = 00613; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000613] = 01146; $code[000613] = *I00613; sub I00613 { $lac += $core[000146]; goto &fetch; }
$core[000614] = 03145; $code[000614] = *I00614; sub I00614 { $core[000145] = $lac & 07777; $lac &= 010000; $code[000145] = *emul8; goto &fetch; }
$core[000615] = 04506; $code[000615] = *L00615; sub L00615 { $core[($ib<<12)+$core[70]] = 00616; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[000616] = 04511; $code[000616] = *L00616; sub L00616 { $core[($ib<<12)+$core[73]] = 00617; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[000617] = 00057; $code[000617] = *I00617; sub I00617 { $lac &= (010000|$core[000057]); goto &fetch; }
$core[000620] = 05502; $code[000620] = *I00620; sub I00620 { $pc = ($ib<<12)+$core[66]; $inh = 0; goto &fetch; }
$core[000621] = 04511; $code[000621] = *I00621; sub I00621 { $core[($ib<<12)+$core[73]] = 00622; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[000622] = 01140; $code[000622] = *I00622; sub I00622 { $lac += $core[000140]; goto &fetch; }
$core[000623] = 05215; $code[000623] = *I00623; sub I00623 { $pc = 000615; $inh = 0; goto &fetch; }
$core[000624] = 01142; $code[000624] = *I00624; sub I00624 { $lac += $core[000142]; goto &fetch; }
$core[000625] = 04503; $code[000625] = *I00625; sub I00625 { $core[($ib<<12)+$core[67]] = 00626; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[000626] = 04506; $code[000626] = *L00626; sub L00626 { $core[($ib<<12)+$core[70]] = 00627; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[000627] = 04511; $code[000627] = *I00627; sub I00627 { $core[($ib<<12)+$core[73]] = 00630; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[000630] = 02002; $code[000630] = *I00630; sub I00630 { if (++$core[000002] == 010000) { $core[000002] = 0; $pc++; }$code[000002] = *emul8; goto &fetch; }
$core[000631] = 07410; $code[000631] = *I00631; sub I00631 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000632] = 05226; $code[000632] = *I00632; sub I00632 { $pc = 000626; $inh = 0; goto &fetch; }
$core[000633] = 04521; $code[000633] = *I00633; sub I00633 { $core[($ib<<12)+$core[81]] = 00634; $pc = ($ib<<12)+$core[81]+1; $code[($ib<<12)+$core[81]] = *emul8; $inh = 0; goto &fetch; }
$core[000634] = 01413; $code[000634] = *I00634; sub I00634 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[000635] = 04510; $code[000635] = *I00635; sub I00635 { $core[($ib<<12)+$core[72]] = 00636; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[000636] = 00755; $code[000636] = *I00636; sub I00636 { $lac &= (010000|$core[($df<<12)+$core[493]]); goto &fetch; }
$core[000637] = 00206; $code[000637] = *I00637; sub I00637 { $lac &= (010000|$core[000606]); goto &fetch; }
$core[000640] = 04526; $code[000640] = *I00640; sub I00640 { $core[($ib<<12)+$core[86]] = 00641; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[000641] = 04711; $code[000641] = *L00641; sub L00641 { $core[($ib<<12)+$core[457]] = 00642; $pc = ($ib<<12)+$core[457]+1; $code[($ib<<12)+$core[457]] = *emul8; $inh = 0; goto &fetch; }
$core[000642] = 04515; $code[000642] = *I00642; sub I00642 { $core[($ib<<12)+$core[77]] = 00643; $pc = ($ib<<12)+$core[77]+1; $code[($ib<<12)+$core[77]] = *emul8; $inh = 0; goto &fetch; }
$core[000643] = 02151; $code[000643] = *I00643; sub I00643 { if (++$core[000151] == 010000) { $core[000151] = 0; $pc++; }$code[000151] = *emul8; goto &fetch; }
$core[000644] = 04516; $code[000644] = *L00644; sub L00644 { $core[($ib<<12)+$core[78]] = 00645; $pc = ($ib<<12)+$core[78]+1; $code[($ib<<12)+$core[78]] = *emul8; $inh = 0; goto &fetch; }
$core[000645] = 05274; $code[000645] = *I00645; sub I00645 { $pc = 000674; $inh = 0; goto &fetch; }
$core[000646] = 01143; $code[000646] = *I00646; sub I00646 { $lac += $core[000143]; goto &fetch; }
$core[000647] = 07640; $code[000647] = *I00647; sub I00647 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000650] = 04514; $code[000650] = *I00650; sub I00650 { $core[($ib<<12)+$core[76]] = 00651; $pc = ($ib<<12)+$core[76]+1; $code[($ib<<12)+$core[76]] = *emul8; $inh = 0; goto &fetch; }
$core[000651] = 04506; $code[000651] = *L00651; sub L00651 { $core[($ib<<12)+$core[70]] = 00652; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[000652] = 04512; $code[000652] = *I00652; sub I00652 { $core[($ib<<12)+$core[74]] = 00653; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[000653] = 01142; $code[000653] = *I00653; sub I00653 { $lac += $core[000142]; goto &fetch; }
$core[000654] = 01065; $code[000654] = *I00654; sub I00654 { $lac += $core[000065]; goto &fetch; }
$core[000655] = 07640; $code[000655] = *I00655; sub I00655 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000656] = 05251; $code[000656] = *I00656; sub I00656 { $pc = 000651; $inh = 0; goto &fetch; }
$core[000657] = 01546; $code[000657] = *I00657; sub I00657 { $lac += $core[($df<<12)+$core[102]]; goto &fetch; }
$core[000660] = 07450; $code[000660] = *L00660; sub L00660 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000661] = 05303; $code[000661] = *I00661; sub I00661 { $pc = 000703; $inh = 0; goto &fetch; }
$core[000662] = 07001; $code[000662] = *I00662; sub I00662 { $lac++; goto &fetch; }
$core[000663] = 03154; $code[000663] = *I00663; sub I00663 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[000664] = 01141; $code[000664] = *I00664; sub I00664 { $lac += $core[000141]; goto &fetch; }
$core[000665] = 07700; $code[000665] = *I00665; sub I00665 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000666] = 01554; $code[000666] = *I00666; sub I00666 { $lac += $core[($df<<12)+$core[108]]; goto &fetch; }
$core[000667] = 04524; $code[000667] = *I00667; sub I00667 { $core[($ib<<12)+$core[84]] = 00670; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[000670] = 05276; $code[000670] = *I00670; sub I00670 { $pc = 000676; $inh = 0; goto &fetch; }
$core[000671] = 01554; $code[000671] = *L00671; sub L00671 { $lac += $core[($df<<12)+$core[108]]; goto &fetch; }
$core[000672] = 03143; $code[000672] = *I00672; sub I00672 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[000673] = 05244; $code[000673] = *I00673; sub I00673 { $pc = 000644; $inh = 0; goto &fetch; }
$core[000674] = 01146; $code[000674] = *L00674; sub L00674 { $lac += $core[000146]; goto &fetch; }
$core[000675] = 05260; $code[000675] = *I00675; sub I00675 { $pc = 000660; $inh = 0; goto &fetch; }
$core[000676] = 01141; $code[000676] = *L00676; sub L00676 { $lac += $core[000141]; goto &fetch; }
$core[000677] = 07750; $code[000677] = *I00677; sub I00677 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000700] = 05303; $code[000700] = *I00700; sub I00700 { $pc = 000703; $inh = 0; goto &fetch; }
$core[000701] = 04512; $code[000701] = *D00701; sub D00701 { $core[($ib<<12)+$core[74]] = 00702; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[000702] = 05271; $code[000702] = *I00702; sub I00702 { $pc = 000671; $inh = 0; goto &fetch; }
$core[000703] = 04712; $code[000703] = *L00703; sub L00703 { $core[($ib<<12)+$core[458]] = 00704; $pc = ($ib<<12)+$core[458]+1; $code[($ib<<12)+$core[458]] = *emul8; $inh = 0; goto &fetch; }
$core[000704] = 03151; $code[000704] = *D00704; sub D00704 { $core[000151] = $lac & 07777; $lac &= 010000; $code[000151] = *emul8; goto &fetch; }
$core[000705] = 04565; $code[000705] = *L00705; sub L00705 { $core[($ib<<12)+$core[117]] = 00706; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[000706] = 05305; $code[000706] = *D00706; sub D00706 { $pc = 000705; $inh = 0; goto &fetch; }
$core[000707] = 05216; $code[000707] = *D00707; sub D00707 { $pc = 000616; $inh = 0; goto &fetch; }
$core[000710] = 05241; $code[000710] = *D00710; sub D00710 { $pc = 000641; $inh = 0; goto &fetch; }
$core[000711] = 02435; $code[000711] = *P00711; sub P00711 { if (++$core[($df<<12)+$core[29]] == 010000) { $core[($df<<12)+$core[29]] = 0; $pc++; }$code[($df<<12)+$core[29]] = *emul8; goto &fetch; }
$core[000712] = 02443; $code[000712] = *P00712; sub P00712 { if (++$core[($df<<12)+$core[35]] == 010000) { $core[($df<<12)+$core[35]] = 0; $pc++; }$code[($df<<12)+$core[35]] = *emul8; goto &fetch; }
$core[000713] = 00000; $code[000713] = *S00713; sub S00713 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000714] = 04521; $code[000714] = *D00714; sub D00714 { $core[($ib<<12)+$core[81]] = 00715; $pc = ($ib<<12)+$core[81]+1; $code[($ib<<12)+$core[81]] = *emul8; $inh = 0; goto &fetch; }
$core[000715] = 04511; $code[000715] = *D00715; sub D00715 { $core[($ib<<12)+$core[73]] = 00716; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[000716] = 02005; $code[000716] = *I00716; sub I00716 { if (++$core[000005] == 010000) { $core[000005] = 0; $pc++; }$code[000005] = *emul8; goto &fetch; }
$core[000717] = 05713; $code[000717] = *D00717; sub D00717 { $pc = ($ib<<12)+$core[459]; $inh = 0; goto &fetch; }
$core[000720] = 02313; $code[000720] = *I00720; sub I00720 { if (++$core[000713] == 010000) { $core[000713] = 0; $pc++; }$code[000713] = *emul8; goto &fetch; }
$core[000721] = 04522; $code[000721] = *D00721; sub D00721 { $core[($ib<<12)+$core[82]] = 00722; $pc = ($ib<<12)+$core[82]+1; $code[($ib<<12)+$core[82]] = *emul8; $inh = 0; goto &fetch; }
$core[000722] = 05713; $code[000722] = *D00722; sub D00722 { $pc = ($ib<<12)+$core[459]; $inh = 0; goto &fetch; }
$core[000723] = 07410; $code[000723] = *D00723; sub D00723 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000724] = 05713; $code[000724] = *D00724; sub D00724 { $pc = ($ib<<12)+$core[459]; $inh = 0; goto &fetch; }
$core[000725] = 01142; $code[000725] = *I00725; sub I00725 { $lac += $core[000142]; goto &fetch; }
$core[000726] = 01207; $code[000726] = *I00726; sub I00726 { $lac += $core[000607]; goto &fetch; }
$core[000727] = 07640; $code[000727] = *D00727; sub D00727 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000730] = 02313; $code[000730] = *I00730; sub I00730 { if (++$core[000713] == 010000) { $core[000713] = 0; $pc++; }$code[000713] = *emul8; goto &fetch; }
$core[000731] = 02313; $code[000731] = *I00731; sub I00731 { if (++$core[000713] == 010000) { $core[000713] = 0; $pc++; }$code[000713] = *emul8; goto &fetch; }
$core[000732] = 05713; $code[000732] = *I00732; sub I00732 { $pc = ($ib<<12)+$core[459]; $inh = 0; goto &fetch; }
$core[000733] = 00000; $code[000733] = *S00733; sub S00733 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000734] = 01733; $code[000734] = *I00734; sub I00734 { $lac += $core[($df<<12)+$core[475]]; goto &fetch; }
$core[000735] = 03012; $code[000735] = *P00735; sub P00735 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[000736] = 01412; $code[000736] = *L00736; sub L00736 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac += $core[($df<<12)+$core[000012]]; goto &fetch; }
$core[000737] = 07510; $code[000737] = *I00737; sub I00737 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000740] = 05352; $code[000740] = *I00740; sub I00740 { $pc = 000752; $inh = 0; goto &fetch; }
$core[000741] = 07041; $code[000741] = *I00741; sub I00741 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000742] = 01142; $code[000742] = *I00742; sub I00742 { $lac += $core[000142]; goto &fetch; }
$core[000743] = 07640; $code[000743] = *I00743; sub I00743 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000744] = 05336; $code[000744] = *I00744; sub I00744 { $pc = 000736; $inh = 0; goto &fetch; }
$core[000745] = 01733; $code[000745] = *I00745; sub I00745 { $lac += $core[($df<<12)+$core[475]]; goto &fetch; }
$core[000746] = 07040; $code[000746] = *I00746; sub I00746 { $lac ^= 07777; goto &fetch; }
$core[000747] = 01012; $code[000747] = *I00747; sub I00747 { $lac += $core[000012]; goto &fetch; }
$core[000750] = 03127; $code[000750] = *I00750; sub I00750 { $core[000127] = $lac & 07777; $lac &= 010000; $code[000127] = *emul8; goto &fetch; }
$core[000751] = 07410; $code[000751] = *I00751; sub I00751 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000752] = 02333; $code[000752] = *L00752; sub L00752 { if (++$core[000733] == 010000) { $core[000733] = 0; $pc++; }$code[000733] = *emul8; goto &fetch; }
$core[000753] = 02333; $code[000753] = *I00753; sub I00753 { if (++$core[000733] == 010000) { $core[000733] = 0; $pc++; }$code[000733] = *emul8; goto &fetch; }
$core[000754] = 07300; $code[000754] = *I00754; sub I00754 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000755] = 05733; $code[000755] = *P00755; sub P00755 { $pc = ($ib<<12)+$core[475]; $inh = 0; goto &fetch; }
$core[000756] = 00323; $code[000756] = *I00756; sub I00756 { $lac &= (010000|$core[000723]); goto &fetch; }
$core[000757] = 00306; $code[000757] = *I00757; sub I00757 { $lac &= (010000|$core[000706]); goto &fetch; }
$core[000760] = 00311; $code[000760] = *I00760; sub I00760 { $lac &= (010000|$core[000711]); goto &fetch; }
$core[000761] = 00304; $code[000761] = *I00761; sub I00761 { $lac &= (010000|$core[000704]); goto &fetch; }
$core[000762] = 00307; $code[000762] = *I00762; sub I00762 { $lac &= (010000|$core[000707]); goto &fetch; }
$core[000763] = 00303; $code[000763] = *I00763; sub I00763 { $lac &= (010000|$core[000703]); goto &fetch; }
$core[000764] = 00301; $code[000764] = *I00764; sub I00764 { $lac &= (010000|$core[000701]); goto &fetch; }
$core[000765] = 00324; $code[000765] = *I00765; sub I00765 { $lac &= (010000|$core[000724]); goto &fetch; }
$core[000766] = 00314; $code[000766] = *I00766; sub I00766 { $lac &= (010000|$core[000714]); goto &fetch; }
$core[000767] = 00305; $code[000767] = *I00767; sub I00767 { $lac &= (010000|$core[000705]); goto &fetch; }
$core[000770] = 00327; $code[000770] = *I00770; sub I00770 { $lac &= (010000|$core[000727]); goto &fetch; }
$core[000771] = 00315; $code[000771] = *I00771; sub I00771 { $lac &= (010000|$core[000715]); goto &fetch; }
$core[000772] = 00321; $code[000772] = *I00772; sub I00772 { $lac &= (010000|$core[000721]); goto &fetch; }
$core[000773] = 00322; $code[000773] = *I00773; sub I00773 { $lac &= (010000|$core[000722]); goto &fetch; }
$core[000774] = 00317; $code[000774] = *I00774; sub I00774 { $lac &= (010000|$core[000717]); goto &fetch; }
$core[000775] = 00310; $code[000775] = *I00775; sub I00775 { $lac &= (010000|$core[000710]); goto &fetch; }
$core[000776] = 04511; $code[000776] = *I00776; sub I00776 { $core[($ib<<12)+$core[73]] = 00777; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[000777] = 01022; $code[000777] = *I00777; sub I00777 { $lac += $core[000022]; goto &fetch; }
$core[001000] = 07410; $code[001000] = *P01000; sub P01000 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001001] = 04526; $code[001001] = *P01001; sub P01001 { $core[($ib<<12)+$core[86]] = 01002; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001002] = 04501; $code[001002] = *I01002; sub I01002 { $core[($ib<<12)+$core[65]] = 01003; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001003] = 01600; $code[001003] = *I01003; sub I01003 { $lac += $core[($df<<12)+$core[512]]; goto &fetch; }
$core[001004] = 04506; $code[001004] = *L01004; sub L01004 { $core[($ib<<12)+$core[70]] = 01005; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001005] = 01045; $code[001005] = *I01005; sub I01005 { $lac += $core[000045]; goto &fetch; }
$core[001006] = 07710; $code[001006] = *D01006; sub D01006 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001007] = 05622; $code[001007] = *D01007; sub D01007 { $pc = ($ib<<12)+$core[530]; $inh = 0; goto &fetch; }
$core[001010] = 04565; $code[001010] = *P01010; sub P01010 { $core[($ib<<12)+$core[117]] = 01011; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[001011] = 05210; $code[001011] = *I01011; sub I01011 { $pc = 001010; $inh = 0; goto &fetch; }
$core[001012] = 05703; $code[001012] = *I01012; sub I01012 { $pc = ($ib<<12)+$core[579]; $inh = 0; goto &fetch; }
$core[001013] = 01045; $code[001013] = *I01013; sub I01013 { $lac += $core[000045]; goto &fetch; }
$core[001014] = 07650; $code[001014] = *I01014; sub I01014 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001015] = 05622; $code[001015] = *D01015; sub D01015 { $pc = ($ib<<12)+$core[530]; $inh = 0; goto &fetch; }
$core[001016] = 04565; $code[001016] = *P01016; sub P01016 { $core[($ib<<12)+$core[117]] = 01017; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[001017] = 05216; $code[001017] = *I01017; sub I01017 { $pc = 001016; $inh = 0; goto &fetch; }
$core[001020] = 05703; $code[001020] = *P01020; sub P01020 { $pc = ($ib<<12)+$core[579]; $inh = 0; goto &fetch; }
$core[001021] = 05622; $code[001021] = *I01021; sub I01021 { $pc = ($ib<<12)+$core[530]; $inh = 0; goto &fetch; }
$core[001022] = 00610; $code[001022] = *P01022; sub P01022 { $lac &= (010000|$core[($df<<12)+$core[520]]); goto &fetch; }
$core[001023] = 00250; $code[001023] = *I01023; sub I01023 { $lac &= (010000|$core[001050]); goto &fetch; }
$core[001024] = 04501; $code[001024] = *I01024; sub I01024 { $core[($ib<<12)+$core[65]] = 01025; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001025] = 01404; $code[001025] = *I01025; sub I01025 { $lac += $core[($df<<12)+$core[4]]; goto &fetch; }
$core[001026] = 04521; $code[001026] = *D01026; sub D01026 { $core[($ib<<12)+$core[81]] = 01027; $pc = ($ib<<12)+$core[81]+1; $code[($ib<<12)+$core[81]] = *emul8; $inh = 0; goto &fetch; }
$core[001027] = 04511; $code[001027] = *I01027; sub I01027 { $core[($ib<<12)+$core[73]] = 01030; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[001030] = 02024; $code[001030] = *I01030; sub I01030 { if (++$core[000024] == 010000) { $core[000024] = 0; $pc++; }$code[000024] = *emul8; goto &fetch; }
$core[001031] = 07410; $code[001031] = *I01031; sub I01031 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001032] = 04526; $code[001032] = *I01032; sub I01032 { $core[($ib<<12)+$core[86]] = 01033; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001033] = 01154; $code[001033] = *I01033; sub I01033 { $lac += $core[000154]; goto &fetch; }
$core[001034] = 03332; $code[001034] = *I01034; sub I01034 { $core[001132] = $lac & 07777; $lac &= 010000; $code[001132] = *emul8; goto &fetch; }
$core[001035] = 04501; $code[001035] = *I01035; sub I01035 { $core[($ib<<12)+$core[65]] = 01036; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001036] = 01600; $code[001036] = *I01036; sub I01036 { $lac += $core[($df<<12)+$core[512]]; goto &fetch; }
$core[001037] = 04407; $code[001037] = *I01037; sub I01037 { $core[($ib<<12)+$core[7]] = 01040; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[001040] = 06732; $code[001040] = *D01040; sub D01040 { &emul8; goto &fetch; }
$core[001041] = 00000; $code[001041] = *P01041; sub P01041 { &emul8; goto &fetch; }
$core[001042] = 04565; $code[001042] = *D01042; sub D01042 { $core[($ib<<12)+$core[117]] = 01043; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[001043] = 04526; $code[001043] = *D01043; sub D01043 { $core[($ib<<12)+$core[86]] = 01044; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001044] = 05703; $code[001044] = *L01044; sub L01044 { $pc = ($ib<<12)+$core[579]; $inh = 0; goto &fetch; }
$core[001045] = 01332; $code[001045] = *D01045; sub D01045 { $lac += $core[001132]; goto &fetch; }
$core[001046] = 04503; $code[001046] = *D01046; sub D01046 { $core[($ib<<12)+$core[67]] = 01047; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001047] = 04501; $code[001047] = *I01047; sub I01047 { $core[($ib<<12)+$core[65]] = 01050; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001050] = 01601; $code[001050] = *D01050; sub D01050 { $lac += $core[($df<<12)+$core[513]]; goto &fetch; }
$core[001051] = 04565; $code[001051] = *I01051; sub I01051 { $core[($ib<<12)+$core[117]] = 01052; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[001052] = 04526; $code[001052] = *D01052; sub D01052 { $core[($ib<<12)+$core[86]] = 01053; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001053] = 05317; $code[001053] = *I01053; sub I01053 { $pc = 001117; $inh = 0; goto &fetch; }
$core[001054] = 04504; $code[001054] = *D01054; sub D01054 { $core[($ib<<12)+$core[68]] = 01055; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[001055] = 02034; $code[001055] = *I01055; sub I01055 { if (++$core[000034] == 010000) { $core[000034] = 0; $pc++; }$code[000034] = *emul8; goto &fetch; }
$core[001056] = 04501; $code[001056] = *I01056; sub I01056 { $core[($ib<<12)+$core[65]] = 01057; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001057] = 01601; $code[001057] = *I01057; sub I01057 { $lac += $core[($df<<12)+$core[513]]; goto &fetch; }
$core[001060] = 04504; $code[001060] = *L01060; sub L01060 { $core[($ib<<12)+$core[68]] = 01061; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[001061] = 02034; $code[001061] = *I01061; sub I01061 { if (++$core[000034] == 010000) { $core[000034] = 0; $pc++; }$code[000034] = *emul8; goto &fetch; }
$core[001062] = 04724; $code[001062] = *I01062; sub I01062 { $core[($ib<<12)+$core[596]] = 01063; $pc = ($ib<<12)+$core[596]+1; $code[($ib<<12)+$core[596]] = *emul8; $inh = 0; goto &fetch; }
$core[001063] = 04430; $code[001063] = *I01063; sub I01063 { $core[($ib<<12)+$core[24]] = 01064; $pc = ($ib<<12)+$core[24]+1; $code[($ib<<12)+$core[24]] = *emul8; $inh = 0; goto &fetch; }
$core[001064] = 04407; $code[001064] = *L01064; sub L01064 { $core[($ib<<12)+$core[7]] = 01065; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[001065] = 01732; $code[001065] = *I01065; sub I01065 { &emul8; goto &fetch; }
$core[001066] = 06732; $code[001066] = *I01066; sub I01066 { &emul8; goto &fetch; }
$core[001067] = 02560; $code[001067] = *I01067; sub I01067 { &emul8; goto &fetch; }
$core[001070] = 00000; $code[001070] = *I01070; sub I01070 { &emul8; goto &fetch; }
$core[001071] = 01013; $code[001071] = *I01071; sub I01071 { $lac += $core[000013]; goto &fetch; }
$core[001072] = 01322; $code[001072] = *I01072; sub I01072 { $lac += $core[001122]; goto &fetch; }
$core[001073] = 03332; $code[001073] = *D01073; sub D01073 { $core[001132] = $lac & 07777; $lac &= 010000; $code[001132] = *emul8; goto &fetch; }
$core[001074] = 01732; $code[001074] = *D01074; sub D01074 { $lac += $core[($df<<12)+$core[602]]; goto &fetch; }
$core[001075] = 07710; $code[001075] = *I01075; sub I01075 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001076] = 04450; $code[001076] = *I01076; sub I01076 { $core[($ib<<12)+$core[40]] = 01077; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[001077] = 01045; $code[001077] = *I01077; sub I01077 { $lac += $core[000045]; goto &fetch; }
$core[001100] = 07740; $code[001100] = *I01100; sub I01100 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001101] = 05326; $code[001101] = *I01101; sub I01101 { $pc = 001126; $inh = 0; goto &fetch; }
$core[001102] = 04501; $code[001102] = *I01102; sub I01102 { $core[($ib<<12)+$core[65]] = 01103; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001103] = 00616; $code[001103] = *P01103; sub P01103 { $lac &= (010000|$core[($df<<12)+$core[526]]); goto &fetch; }
$core[001104] = 04725; $code[001104] = *I01104; sub I01104 { $core[($ib<<12)+$core[597]] = 01105; $pc = ($ib<<12)+$core[597]+1; $code[($ib<<12)+$core[597]] = *emul8; $inh = 0; goto &fetch; }
$core[001105] = 04505; $code[001105] = *I01105; sub I01105 { $core[($ib<<12)+$core[69]] = 01106; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[001106] = 02034; $code[001106] = *I01106; sub I01106 { if (++$core[000034] == 010000) { $core[000034] = 0; $pc++; }$code[000034] = *emul8; goto &fetch; }
$core[001107] = 04505; $code[001107] = *I01107; sub I01107 { $core[($ib<<12)+$core[69]] = 01110; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[001110] = 00044; $code[001110] = *I01110; sub I01110 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[001111] = 01413; $code[001111] = *I01111; sub I01111 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001112] = 03332; $code[001112] = *I01112; sub I01112 { $core[001132] = $lac & 07777; $lac &= 010000; $code[001132] = *emul8; goto &fetch; }
$core[001113] = 01323; $code[001113] = *I01113; sub I01113 { $lac += $core[001123]; goto &fetch; }
$core[001114] = 01013; $code[001114] = *I01114; sub I01114 { $lac += $core[000013]; goto &fetch; }
$core[001115] = 03013; $code[001115] = *I01115; sub I01115 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[001116] = 05264; $code[001116] = *I01116; sub I01116 { $pc = 001064; $inh = 0; goto &fetch; }
$core[001117] = 04504; $code[001117] = *L01117; sub L01117 { $core[($ib<<12)+$core[68]] = 01120; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[001120] = 01573; $code[001120] = *I01120; sub I01120 { $lac += $core[($df<<12)+$core[123]]; goto &fetch; }
$core[001121] = 05260; $code[001121] = *I01121; sub I01121 { $pc = 001060; $inh = 0; goto &fetch; }
$core[001122] = 00011; $code[001122] = *D01122; sub D01122 { $lac &= (010000|$core[000011]); goto &fetch; }
$core[001123] = 07765; $code[001123] = *D01123; sub D01123 { &emul8; goto &fetch; }
$core[001124] = 02435; $code[001124] = *P01124; sub P01124 { if (++$core[($df<<12)+$core[29]] == 010000) { $core[($df<<12)+$core[29]] = 0; $pc++; }$code[($df<<12)+$core[29]] = *emul8; goto &fetch; }
$core[001125] = 02443; $code[001125] = *P01125; sub P01125 { if (++$core[($df<<12)+$core[35]] == 010000) { $core[($df<<12)+$core[35]] = 0; $pc++; }$code[($df<<12)+$core[35]] = *emul8; goto &fetch; }
$core[001126] = 01005; $code[001126] = *L01126; sub L01126 { $lac += $core[000005]; goto &fetch; }
$core[001127] = 01013; $code[001127] = *I01127; sub I01127 { $lac += $core[000013]; goto &fetch; }
$core[001130] = 03013; $code[001130] = *I01130; sub I01130 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[001131] = 05502; $code[001131] = *I01131; sub I01131 { $pc = ($ib<<12)+$core[66]; $inh = 0; goto &fetch; }
$core[001132] = 00000; $code[001132] = *P01132; sub P01132 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001133] = 00246; $code[001133] = *I01133; sub I01133 { $lac &= (010000|$core[001046]); goto &fetch; }
$core[001134] = 00245; $code[001134] = *D01134; sub D01134 { $lac &= (010000|$core[001045]); goto &fetch; }
$core[001135] = 00242; $code[001135] = *P01135; sub P01135 { $lac &= (010000|$core[001042]); goto &fetch; }
$core[001136] = 00241; $code[001136] = *I01136; sub I01136 { $lac &= (010000|$core[001041]); goto &fetch; }
$core[001137] = 00243; $code[001137] = *I01137; sub I01137 { $lac &= (010000|$core[001043]); goto &fetch; }
$core[001140] = 00244; $code[001140] = *I01140; sub I01140 { $lac &= (010000|$core[001044]); goto &fetch; }
$core[001141] = 00240; $code[001141] = *I01141; sub I01141 { $lac &= (010000|$core[001040]); goto &fetch; }
$core[001142] = 00254; $code[001142] = *D01142; sub D01142 { $lac &= (010000|$core[001054]); goto &fetch; }
$core[001143] = 00273; $code[001143] = *I01143; sub I01143 { $lac &= (010000|$core[001073]); goto &fetch; }
$core[001144] = 00215; $code[001144] = *I01144; sub I01144 { $lac &= (010000|$core[001015]); goto &fetch; }
$core[001145] = 04452; $code[001145] = *I01145; sub I01145 { $core[($ib<<12)+$core[42]] = 01146; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001146] = 06063; $code[001146] = *I01146; sub I01146 { &emul8; goto &fetch; }
$core[001147] = 07200; $code[001147] = *I01147; sub I01147 { $lac &= 010000; goto &fetch; }
$core[001150] = 01361; $code[001150] = *I01150; sub I01150 { $lac += $core[001161]; goto &fetch; }
$core[001151] = 06053; $code[001151] = *I01151; sub I01151 { &emul8; goto &fetch; }
$core[001152] = 07410; $code[001152] = *I01152; sub I01152 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001153] = 04452; $code[001153] = *I01153; sub I01153 { $core[($ib<<12)+$core[42]] = 01154; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001154] = 03361; $code[001154] = *I01154; sub I01154 { $core[001161] = $lac & 07777; $lac &= 010000; $code[001161] = *emul8; goto &fetch; }
$core[001155] = 05500; $code[001155] = *I01155; sub I01155 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[001156] = 04452; $code[001156] = *L01156; sub L01156 { $core[($ib<<12)+$core[42]] = 01157; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001157] = 07200; $code[001157] = *I01157; sub I01157 { $lac &= 010000; goto &fetch; }
$core[001160] = 05500; $code[001160] = *I01160; sub I01160 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[001161] = 00000; $code[001161] = *D01161; sub D01161 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001162] = 01252; $code[001162] = *L01162; sub L01162 { $lac += $core[001052]; goto &fetch; }
$core[001163] = 01210; $code[001163] = *I01163; sub I01163 { $lac += $core[001010]; goto &fetch; }
$core[001164] = 01024; $code[001164] = *I01164; sub I01164 { $lac += $core[000024]; goto &fetch; }
$core[001165] = 01024; $code[001165] = *I01165; sub I01165 { $lac += $core[000024]; goto &fetch; }
$core[001166] = 00776; $code[001166] = *I01166; sub I01166 { $lac &= (010000|$core[($df<<12)+$core[638]]); goto &fetch; }
$core[001167] = 00416; $code[001167] = *I01167; sub I01167 { $core[000016] = 0000 if ++$core[000016] == 010000; $lac &= (010000|$core[($df<<12)+$core[000016]]); goto &fetch; }
$core[001170] = 00610; $code[001170] = *I01170; sub I01170 { $lac &= (010000|$core[($df<<12)+$core[520]]); goto &fetch; }
$core[001171] = 00620; $code[001171] = *I01171; sub I01171 { $lac &= (010000|$core[($df<<12)+$core[528]]); goto &fetch; }
$core[001172] = 01206; $code[001172] = *I01172; sub I01172 { $lac += $core[001006]; goto &fetch; }
$core[001173] = 01207; $code[001173] = *I01173; sub I01173 { $lac += $core[001007]; goto &fetch; }
$core[001174] = 02735; $code[001174] = *I01174; sub I01174 { if (++$core[($df<<12)+$core[605]] == 010000) { $core[($df<<12)+$core[605]] = 0; $pc++; }$code[($df<<12)+$core[605]] = *emul8; goto &fetch; }
$core[001175] = 02226; $code[001175] = *I01175; sub I01175 { if (++$core[001026] == 010000) { $core[001026] = 0; $pc++; }$code[001026] = *emul8; goto &fetch; }
$core[001176] = 00641; $code[001176] = *P01176; sub P01176 { $lac &= (010000|$core[($df<<12)+$core[545]]); goto &fetch; }
$core[001177] = 01273; $code[001177] = *I01177; sub I01177 { $lac += $core[001073]; goto &fetch; }
$core[001200] = 00177; $code[001200] = *P01200; sub P01200 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[001201] = 01554; $code[001201] = *P01201; sub P01201 { $lac += $core[($df<<12)+$core[108]]; goto &fetch; }
$core[001202] = 06446; $code[001202] = *I01202; sub I01202 { &emul8; goto &fetch; }
$core[001203] = 03274; $code[001203] = *I01203; sub I01203 { $core[001274] = $lac & 07777; $lac &= 010000; $code[001274] = *emul8; goto &fetch; }
$core[001204] = 03040; $code[001204] = *I01204; sub I01204 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[001205] = 03065; $code[001205] = *I01205; sub I01205 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[001206] = 07240; $code[001206] = *L01206; sub L01206 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001207] = 03131; $code[001207] = *L01207; sub L01207 { $core[000131] = $lac & 07777; $lac &= 010000; $code[000131] = *emul8; goto &fetch; }
$core[001210] = 03151; $code[001210] = *L01210; sub L01210 { $core[000151] = $lac & 07777; $lac &= 010000; $code[000151] = *emul8; goto &fetch; }
$core[001211] = 04510; $code[001211] = *I01211; sub I01211 { $core[($ib<<12)+$core[72]] = 01212; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[001212] = 01132; $code[001212] = *I01212; sub I01212 { $lac += $core[000132]; goto &fetch; }
$core[001213] = 00426; $code[001213] = *I01213; sub I01213 { $lac &= (010000|$core[($df<<12)+$core[22]]); goto &fetch; }
$core[001214] = 02131; $code[001214] = *I01214; sub I01214 { if (++$core[000131] == 010000) { $core[000131] = 0; $pc++; }$code[000131] = *emul8; goto &fetch; }
$core[001215] = 05227; $code[001215] = *I01215; sub I01215 { $pc = 001227; $inh = 0; goto &fetch; }
$core[001216] = 04501; $code[001216] = *I01216; sub I01216 { $core[($ib<<12)+$core[65]] = 01217; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001217] = 01404; $code[001217] = *I01217; sub I01217 { $lac += $core[($df<<12)+$core[4]]; goto &fetch; }
$core[001220] = 04636; $code[001220] = *I01220; sub I01220 { $core[($ib<<12)+$core[670]] = 01221; $pc = ($ib<<12)+$core[670]+1; $code[($ib<<12)+$core[670]] = *emul8; $inh = 0; goto &fetch; }
$core[001221] = 01233; $code[001221] = *I01221; sub I01221 { $lac += $core[001233]; goto &fetch; }
$core[001222] = 04512; $code[001222] = *D01222; sub D01222 { $core[($ib<<12)+$core[74]] = 01223; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[001223] = 04626; $code[001223] = *I01223; sub I01223 { $core[($ib<<12)+$core[662]] = 01224; $pc = ($ib<<12)+$core[662]+1; $code[($ib<<12)+$core[662]] = *emul8; $inh = 0; goto &fetch; }
$core[001224] = 04637; $code[001224] = *I01224; sub I01224 { $core[($ib<<12)+$core[671]] = 01225; $pc = ($ib<<12)+$core[671]+1; $code[($ib<<12)+$core[671]] = *emul8; $inh = 0; goto &fetch; }
$core[001225] = 05206; $code[001225] = *I01225; sub I01225 { $pc = 001206; $inh = 0; goto &fetch; }
$core[001226] = 03306; $code[001226] = *P01226; sub P01226 { $core[001306] = $lac & 07777; $lac &= 010000; $code[001306] = *emul8; goto &fetch; }
$core[001227] = 04501; $code[001227] = *L01227; sub L01227 { $core[($ib<<12)+$core[65]] = 01230; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001230] = 01601; $code[001230] = *I01230; sub I01230 { $lac += $core[($df<<12)+$core[641]]; goto &fetch; }
$core[001231] = 04565; $code[001231] = *I01231; sub I01231 { $core[($ib<<12)+$core[117]] = 01232; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[001232] = 04526; $code[001232] = *I01232; sub I01232 { $core[($ib<<12)+$core[86]] = 01233; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001233] = 00272; $code[001233] = *D01233; sub D01233 { $lac &= (010000|$core[001272]); goto &fetch; }
$core[001234] = 04640; $code[001234] = *I01234; sub I01234 { $core[($ib<<12)+$core[672]] = 01235; $pc = ($ib<<12)+$core[672]+1; $code[($ib<<12)+$core[672]] = *emul8; $inh = 0; goto &fetch; }
$core[001235] = 05207; $code[001235] = *L01235; sub L01235 { $pc = 001207; $inh = 0; goto &fetch; }
$core[001236] = 02435; $code[001236] = *P01236; sub P01236 { if (++$core[($df<<12)+$core[29]] == 010000) { $core[($df<<12)+$core[29]] = 0; $pc++; }$code[($df<<12)+$core[29]] = *emul8; goto &fetch; }
$core[001237] = 02443; $code[001237] = *P01237; sub P01237 { if (++$core[($df<<12)+$core[35]] == 010000) { $core[($df<<12)+$core[35]] = 0; $pc++; }$code[($df<<12)+$core[35]] = *emul8; goto &fetch; }
$core[001240] = 03365; $code[001240] = *P01240; sub P01240 { $core[001365] = $lac & 07777; $lac &= 010000; $code[001365] = *emul8; goto &fetch; }
$core[001241] = 02151; $code[001241] = *I01241; sub I01241 { if (++$core[000151] == 010000) { $core[000151] = 0; $pc++; }$code[000151] = *emul8; goto &fetch; }
$core[001242] = 04506; $code[001242] = *L01242; sub L01242 { $core[($ib<<12)+$core[70]] = 01243; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001243] = 04510; $code[001243] = *I01243; sub I01243 { $core[($ib<<12)+$core[72]] = 01244; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[001244] = 01404; $code[001244] = *I01244; sub I01244 { $lac += $core[($df<<12)+$core[4]]; goto &fetch; }
$core[001245] = 07555; $code[001245] = *I01245; sub I01245 { &emul8; goto &fetch; }
$core[001246] = 04512; $code[001246] = *I01246; sub I01246 { $core[($ib<<12)+$core[74]] = 01247; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[001247] = 05242; $code[001247] = *I01247; sub I01247 { $pc = 001242; $inh = 0; goto &fetch; }
$core[001250] = 01060; $code[001250] = *I01250; sub I01250 { $lac += $core[000060]; goto &fetch; }
$core[001251] = 04512; $code[001251] = *L01251; sub L01251 { $core[($ib<<12)+$core[74]] = 01252; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[001252] = 04506; $code[001252] = *L01252; sub L01252 { $core[($ib<<12)+$core[70]] = 01253; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001253] = 05210; $code[001253] = *I01253; sub I01253 { $pc = 001210; $inh = 0; goto &fetch; }
$core[001254] = 01060; $code[001254] = *I01254; sub I01254 { $lac += $core[000060]; goto &fetch; }
$core[001255] = 04537; $code[001255] = *I01255; sub I01255 { $core[($ib<<12)+$core[95]] = 01256; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[001256] = 01015; $code[001256] = *I01256; sub I01256 { $lac += $core[000015]; goto &fetch; }
$core[001257] = 05251; $code[001257] = *I01257; sub I01257 { $pc = 001251; $inh = 0; goto &fetch; }
$core[001260] = 04506; $code[001260] = *I01260; sub I01260 { $core[($ib<<12)+$core[70]] = 01261; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001261] = 04672; $code[001261] = *I01261; sub I01261 { $core[($ib<<12)+$core[698]] = 01262; $pc = ($ib<<12)+$core[698]+1; $code[($ib<<12)+$core[698]] = *emul8; $inh = 0; goto &fetch; }
$core[001262] = 01164; $code[001262] = *I01262; sub I01262 { $lac += $core[000164]; goto &fetch; }
$core[001263] = 03051; $code[001263] = *I01263; sub I01263 { $core[000051] = $lac & 07777; $lac &= 010000; $code[000051] = *emul8; goto &fetch; }
$core[001264] = 04522; $code[001264] = *I01264; sub I01264 { $core[($ib<<12)+$core[82]] = 01265; $pc = ($ib<<12)+$core[82]+1; $code[($ib<<12)+$core[82]] = *emul8; $inh = 0; goto &fetch; }
$core[001265] = 04506; $code[001265] = *I01265; sub I01265 { $core[($ib<<12)+$core[70]] = 01266; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001266] = 04672; $code[001266] = *I01266; sub I01266 { $core[($ib<<12)+$core[698]] = 01267; $pc = ($ib<<12)+$core[698]+1; $code[($ib<<12)+$core[698]] = *emul8; $inh = 0; goto &fetch; }
$core[001267] = 01164; $code[001267] = *I01267; sub I01267 { $lac += $core[000164]; goto &fetch; }
$core[001270] = 03133; $code[001270] = *I01270; sub I01270 { $core[000133] = $lac & 07777; $lac &= 010000; $code[000133] = *emul8; goto &fetch; }
$core[001271] = 05210; $code[001271] = *I01271; sub I01271 { $pc = 001210; $inh = 0; goto &fetch; }
$core[001272] = 06010; $code[001272] = *P01272; sub P01272 { &emul8; goto &fetch; }
$core[001273] = 04515; $code[001273] = *I01273; sub I01273 { $core[($ib<<12)+$core[77]] = 01274; $pc = ($ib<<12)+$core[77]+1; $code[($ib<<12)+$core[77]] = *emul8; $inh = 0; goto &fetch; }
$core[001274] = 04516; $code[001274] = *D01274; sub D01274 { $core[($ib<<12)+$core[78]] = 01275; $pc = ($ib<<12)+$core[78]+1; $code[($ib<<12)+$core[78]] = *emul8; $inh = 0; goto &fetch; }
$core[001275] = 04526; $code[001275] = *L01275; sub L01275 { $core[($ib<<12)+$core[86]] = 01276; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001276] = 01134; $code[001276] = *I01276; sub I01276 { $lac += $core[000134]; goto &fetch; }
$core[001277] = 03010; $code[001277] = *I01277; sub I01277 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[001300] = 03136; $code[001300] = *I01300; sub I01300 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[001301] = 01143; $code[001301] = *I01301; sub I01301 { $lac += $core[000143]; goto &fetch; }
$core[001302] = 07450; $code[001302] = *I01302; sub I01302 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001303] = 05275; $code[001303] = *I01303; sub I01303 { $pc = 001275; $inh = 0; goto &fetch; }
$core[001304] = 03410; $code[001304] = *I01304; sub I01304 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[001305] = 01010; $code[001305] = *I01305; sub I01305 { $lac += $core[000010]; goto &fetch; }
$core[001306] = 03153; $code[001306] = *D01306; sub D01306 { $core[000153] = $lac & 07777; $lac &= 010000; $code[000153] = *emul8; goto &fetch; }
$core[001307] = 04540; $code[001307] = *D01307; sub D01307 { $core[($ib<<12)+$core[96]] = 01310; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001310] = 03061; $code[001310] = *I01310; sub I01310 { $core[000061] = $lac & 07777; $lac &= 010000; $code[000061] = *emul8; goto &fetch; }
$core[001311] = 02151; $code[001311] = *I01311; sub I01311 { if (++$core[000151] == 010000) { $core[000151] = 0; $pc++; }$code[000151] = *emul8; goto &fetch; }
$core[001312] = 04506; $code[001312] = *L01312; sub L01312 { $core[($ib<<12)+$core[70]] = 01313; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001313] = 04512; $code[001313] = *I01313; sub I01313 { $core[($ib<<12)+$core[74]] = 01314; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[001314] = 04510; $code[001314] = *I01314; sub I01314 { $core[($ib<<12)+$core[72]] = 01315; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[001315] = 00057; $code[001315] = *I01315; sub I01315 { $lac &= (010000|$core[000057]); goto &fetch; }
$core[001316] = 01322; $code[001316] = *I01316; sub I01316 { $lac += $core[001322]; goto &fetch; }
$core[001317] = 04507; $code[001317] = *I01317; sub I01317 { $core[($ib<<12)+$core[71]] = 01320; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[001320] = 05312; $code[001320] = *I01320; sub I01320 { $pc = 001312; $inh = 0; goto &fetch; }
$core[001321] = 01134; $code[001321] = *D01321; sub D01321 { $lac += $core[000134]; goto &fetch; }
$core[001322] = 07001; $code[001322] = *D01322; sub D01322 { $lac++; goto &fetch; }
$core[001323] = 03010; $code[001323] = *I01323; sub I01323 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[001324] = 03136; $code[001324] = *I01324; sub I01324 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[001325] = 04513; $code[001325] = *L01325; sub L01325 { $core[($ib<<12)+$core[75]] = 01326; $pc = ($ib<<12)+$core[75]+1; $code[($ib<<12)+$core[75]] = *emul8; $inh = 0; goto &fetch; }
$core[001326] = 04510; $code[001326] = *I01326; sub I01326 { $core[($ib<<12)+$core[72]] = 01327; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[001327] = 00053; $code[001327] = *I01327; sub I01327 { $lac &= (010000|$core[000053]); goto &fetch; }
$core[001330] = 01322; $code[001330] = *I01330; sub I01330 { $lac += $core[001322]; goto &fetch; }
$core[001331] = 04507; $code[001331] = *I01331; sub I01331 { $core[($ib<<12)+$core[71]] = 01332; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[001332] = 05325; $code[001332] = *I01332; sub I01332 { $pc = 001325; $inh = 0; goto &fetch; }
$core[001333] = 00000; $code[001333] = *S01333; sub S01333 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001334] = 07450; $code[001334] = *I01334; sub I01334 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001335] = 01142; $code[001335] = *I01335; sub I01335 { $lac += $core[000142]; goto &fetch; }
$core[001336] = 07041; $code[001336] = *I01336; sub I01336 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001337] = 03157; $code[001337] = *I01337; sub I01337 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[001340] = 01733; $code[001340] = *I01340; sub I01340 { $lac += $core[($df<<12)+$core[731]]; goto &fetch; }
$core[001341] = 02333; $code[001341] = *I01341; sub I01341 { if (++$core[001333] == 010000) { $core[001333] = 0; $pc++; }$code[001333] = *emul8; goto &fetch; }
$core[001342] = 03012; $code[001342] = *I01342; sub I01342 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[001343] = 01412; $code[001343] = *L01343; sub L01343 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac += $core[($df<<12)+$core[000012]]; goto &fetch; }
$core[001344] = 07510; $code[001344] = *I01344; sub I01344 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001345] = 05357; $code[001345] = *I01345; sub I01345 { $pc = 001357; $inh = 0; goto &fetch; }
$core[001346] = 01157; $code[001346] = *I01346; sub I01346 { $lac += $core[000157]; goto &fetch; }
$core[001347] = 07640; $code[001347] = *I01347; sub I01347 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001350] = 05343; $code[001350] = *I01350; sub I01350 { $pc = 001343; $inh = 0; goto &fetch; }
$core[001351] = 01012; $code[001351] = *I01351; sub I01351 { $lac += $core[000012]; goto &fetch; }
$core[001352] = 01733; $code[001352] = *I01352; sub I01352 { $lac += $core[($df<<12)+$core[731]]; goto &fetch; }
$core[001353] = 03333; $code[001353] = *I01353; sub I01353 { $core[001333] = $lac & 07777; $lac &= 010000; $code[001333] = *emul8; goto &fetch; }
$core[001354] = 01733; $code[001354] = *I01354; sub I01354 { $lac += $core[($df<<12)+$core[731]]; goto &fetch; }
$core[001355] = 03333; $code[001355] = *I01355; sub I01355 { $core[001333] = $lac & 07777; $lac &= 010000; $code[001333] = *emul8; goto &fetch; }
$core[001356] = 07410; $code[001356] = *I01356; sub I01356 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001357] = 02333; $code[001357] = *L01357; sub L01357 { if (++$core[001333] == 010000) { $core[001333] = 0; $pc++; }$code[001333] = *emul8; goto &fetch; }
$core[001360] = 07300; $code[001360] = *I01360; sub I01360 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001361] = 05733; $code[001361] = *I01361; sub I01361 { $pc = ($ib<<12)+$core[731]; $inh = 0; goto &fetch; }
$core[001362] = 04501; $code[001362] = *I01362; sub I01362 { $core[($ib<<12)+$core[65]] = 01363; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001363] = 01600; $code[001363] = *I01363; sub I01363 { $lac += $core[($df<<12)+$core[640]]; goto &fetch; }
$core[001364] = 04452; $code[001364] = *I01364; sub I01364 { $core[($ib<<12)+$core[42]] = 01365; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001365] = 07141; $code[001365] = *L01365; sub L01365 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[001366] = 07001; $code[001366] = *I01366; sub I01366 { $lac++; goto &fetch; }
$core[001367] = 01053; $code[001367] = *I01367; sub I01367 { $lac += $core[000053]; goto &fetch; }
$core[001370] = 07630; $code[001370] = *I01370; sub I01370 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001371] = 05210; $code[001371] = *I01371; sub I01371 { $pc = 001210; $inh = 0; goto &fetch; }
$core[001372] = 01033; $code[001372] = *I01372; sub I01372 { $lac += $core[000033]; goto &fetch; }
$core[001373] = 04512; $code[001373] = *I01373; sub I01373 { $core[($ib<<12)+$core[74]] = 01374; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[001374] = 01046; $code[001374] = *I01374; sub I01374 { $lac += $core[000046]; goto &fetch; }
$core[001375] = 05365; $code[001375] = *I01375; sub I01375 { $pc = 001365; $inh = 0; goto &fetch; }
$core[001376] = 01321; $code[001376] = *I01376; sub I01376 { $lac += $core[001321]; goto &fetch; }
$core[001377] = 01312; $code[001377] = *I01377; sub I01377 { $lac += $core[001312]; goto &fetch; }
$core[001400] = 01307; $code[001400] = *P01400; sub P01400 { $lac += $core[001507]; goto &fetch; }
$core[001401] = 01310; $code[001401] = *I01401; sub I01401 { $lac += $core[001510]; goto &fetch; }
$core[001402] = 00263; $code[001402] = *I01402; sub I01402 { $lac &= (010000|$core[001463]); goto &fetch; }
$core[001403] = 01331; $code[001403] = *I01403; sub I01403 { $lac += $core[001531]; goto &fetch; }
$core[001404] = 04525; $code[001404] = *I01404; sub I01404 { $core[($ib<<12)+$core[85]] = 01405; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[001405] = 00242; $code[001405] = *I01405; sub I01405 { $lac &= (010000|$core[001442]); goto &fetch; }
$core[001406] = 00215; $code[001406] = *I01406; sub I01406 { $lac &= (010000|$core[001415]); goto &fetch; }
$core[001407] = 04526; $code[001407] = *I01407; sub I01407 { $core[($ib<<12)+$core[86]] = 01410; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001410] = 07240; $code[001410] = *I01410; sub I01410 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001411] = 04503; $code[001411] = *I01411; sub I01411 { $core[($ib<<12)+$core[67]] = 01412; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001412] = 03136; $code[001412] = *I01412; sub I01412 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[001413] = 04507; $code[001413] = *I01413; sub I01413 { $core[($ib<<12)+$core[71]] = 01414; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[001414] = 04506; $code[001414] = *I01414; sub I01414 { $core[($ib<<12)+$core[70]] = 01415; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001415] = 04511; $code[001415] = *P01415; sub P01415 { $core[($ib<<12)+$core[73]] = 01416; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[001416] = 02005; $code[001416] = *I01416; sub I01416 { if (++$core[000005] == 010000) { $core[000005] = 0; $pc++; }$code[000005] = *emul8; goto &fetch; }
$core[001417] = 05222; $code[001417] = *I01417; sub I01417 { $pc = 001422; $inh = 0; goto &fetch; }
$core[001420] = 01142; $code[001420] = *P01420; sub P01420 { $lac += $core[000142]; goto &fetch; }
$core[001421] = 00071; $code[001421] = *I01421; sub I01421 { $lac &= (010000|$core[000071]); goto &fetch; }
$core[001422] = 01135; $code[001422] = *L01422; sub L01422 { $lac += $core[000135]; goto &fetch; }
$core[001423] = 04503; $code[001423] = *I01423; sub I01423 { $core[($ib<<12)+$core[67]] = 01424; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001424] = 04511; $code[001424] = *L01424; sub L01424 { $core[($ib<<12)+$core[73]] = 01425; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[001425] = 02005; $code[001425] = *I01425; sub I01425 { if (++$core[000005] == 010000) { $core[000005] = 0; $pc++; }$code[000005] = *emul8; goto &fetch; }
$core[001426] = 05231; $code[001426] = *I01426; sub I01426 { $pc = 001431; $inh = 0; goto &fetch; }
$core[001427] = 04506; $code[001427] = *I01427; sub I01427 { $core[($ib<<12)+$core[70]] = 01430; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001430] = 05224; $code[001430] = *I01430; sub I01430 { $pc = 001424; $inh = 0; goto &fetch; }
$core[001431] = 04523; $code[001431] = *L01431; sub L01431 { $core[($ib<<12)+$core[83]] = 01432; $pc = ($ib<<12)+$core[83]+1; $code[($ib<<12)+$core[83]] = *emul8; $inh = 0; goto &fetch; }
$core[001432] = 05243; $code[001432] = *I01432; sub I01432 { $pc = 001443; $inh = 0; goto &fetch; }
$core[001433] = 01130; $code[001433] = *I01433; sub I01433 { $lac += $core[000130]; goto &fetch; }
$core[001434] = 04503; $code[001434] = *I01434; sub I01434 { $core[($ib<<12)+$core[67]] = 01435; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001435] = 04501; $code[001435] = *I01435; sub I01435 { $core[($ib<<12)+$core[65]] = 01436; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001436] = 01600; $code[001436] = *I01436; sub I01436 { $lac += $core[($df<<12)+$core[768]]; goto &fetch; }
$core[001437] = 04506; $code[001437] = *I01437; sub I01437 { $core[($ib<<12)+$core[70]] = 01440; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001440] = 01413; $code[001440] = *I01440; sub I01440 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001441] = 03130; $code[001441] = *D01441; sub D01441 { $core[000130] = $lac & 07777; $lac &= 010000; $code[000130] = *emul8; goto &fetch; }
$core[001442] = 04452; $code[001442] = *D01442; sub D01442 { $core[($ib<<12)+$core[42]] = 01443; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[001443] = 03324; $code[001443] = *L01443; sub L01443 { $core[001524] = $lac & 07777; $lac &= 010000; $code[001524] = *emul8; goto &fetch; }
$core[001444] = 01413; $code[001444] = *I01444; sub I01444 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001445] = 03135; $code[001445] = *I01445; sub I01445 { $core[000135] = $lac & 07777; $lac &= 010000; $code[000135] = *emul8; goto &fetch; }
$core[001446] = 01134; $code[001446] = *I01446; sub I01446 { $lac += $core[000134]; goto &fetch; }
$core[001447] = 03154; $code[001447] = *L01447; sub L01447 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[001450] = 01154; $code[001450] = *D01450; sub D01450 { $lac += $core[000154]; goto &fetch; }
$core[001451] = 03011; $code[001451] = *I01451; sub I01451 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[001452] = 01154; $code[001452] = *D01452; sub D01452 { $lac += $core[000154]; goto &fetch; }
$core[001453] = 07041; $code[001453] = *I01453; sub I01453 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001454] = 01155; $code[001454] = *D01454; sub D01454 { $lac += $core[000155]; goto &fetch; }
$core[001455] = 07750; $code[001455] = *I01455; sub I01455 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001456] = 05267; $code[001456] = *I01456; sub I01456 { $pc = 001467; $inh = 0; goto &fetch; }
$core[001457] = 01554; $code[001457] = *I01457; sub I01457 { $lac += $core[($df<<12)+$core[108]]; goto &fetch; }
$core[001460] = 07041; $code[001460] = *D01460; sub D01460 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001461] = 01135; $code[001461] = *I01461; sub I01461 { $lac += $core[000135]; goto &fetch; }
$core[001462] = 07650; $code[001462] = *I01462; sub I01462 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001463] = 05312; $code[001463] = *D01463; sub D01463 { $pc = 001512; $inh = 0; goto &fetch; }
$core[001464] = 01154; $code[001464] = *L01464; sub L01464 { $lac += $core[000154]; goto &fetch; }
$core[001465] = 01144; $code[001465] = *I01465; sub I01465 { $lac += $core[000144]; goto &fetch; }
$core[001466] = 05247; $code[001466] = *I01466; sub I01466 { $pc = 001447; $inh = 0; goto &fetch; }
$core[001467] = 02413; $code[001467] = *L01467; sub L01467 { $core[000013] = 0000 if ++$core[000013] == 010000; if (++$core[($df<<12)+$core[000013]] == 010000) { $core[($df<<12)+$core[000013]] = 0; $pc++; }$code[($df<<12)+$core[000013]] = *emul8; goto &fetch; }
$core[001470] = 04526; $code[001470] = *I01470; sub I01470 { $core[($ib<<12)+$core[86]] = 01471; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001471] = 01155; $code[001471] = *I01471; sub I01471 { $lac += $core[000155]; goto &fetch; }
$core[001472] = 01005; $code[001472] = *I01472; sub I01472 { $lac += $core[000005]; goto &fetch; }
$core[001473] = 07141; $code[001473] = *I01473; sub I01473 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[001474] = 01013; $code[001474] = *I01474; sub I01474 { $lac += $core[000013]; goto &fetch; }
$core[001475] = 07620; $code[001475] = *I01475; sub I01475 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001476] = 04526; $code[001476] = *I01476; sub I01476 { $core[($ib<<12)+$core[86]] = 01477; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001477] = 01155; $code[001477] = *I01477; sub I01477 { $lac += $core[000155]; goto &fetch; }
$core[001500] = 01144; $code[001500] = *I01500; sub I01500 { $lac += $core[000144]; goto &fetch; }
$core[001501] = 03155; $code[001501] = *I01501; sub I01501 { $core[000155] = $lac & 07777; $lac &= 010000; $code[000155] = *emul8; goto &fetch; }
$core[001502] = 01135; $code[001502] = *I01502; sub I01502 { $lac += $core[000135]; goto &fetch; }
$core[001503] = 03554; $code[001503] = *I01503; sub I01503 { $core[($df<<12)+$core[108]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[108]] = *emul8; goto &fetch; }
$core[001504] = 01324; $code[001504] = *I01504; sub I01504 { $lac += $core[001524]; goto &fetch; }
$core[001505] = 03411; $code[001505] = *I01505; sub I01505 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[001506] = 03411; $code[001506] = *I01506; sub I01506 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[001507] = 03411; $code[001507] = *D01507; sub D01507 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[001510] = 03411; $code[001510] = *D01510; sub D01510 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[001511] = 05320; $code[001511] = *I01511; sub I01511 { $pc = 001520; $inh = 0; goto &fetch; }
$core[001512] = 01411; $code[001512] = *L01512; sub L01512 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[001513] = 07041; $code[001513] = *I01513; sub I01513 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001514] = 01324; $code[001514] = *I01514; sub I01514 { $lac += $core[001524]; goto &fetch; }
$core[001515] = 07640; $code[001515] = *I01515; sub I01515 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001516] = 05264; $code[001516] = *I01516; sub I01516 { $pc = 001464; $inh = 0; goto &fetch; }
$core[001517] = 02013; $code[001517] = *I01517; sub I01517 { if (++$core[000013] == 010000) { $core[000013] = 0; $pc++; }$code[000013] = *emul8; goto &fetch; }
$core[001520] = 02154; $code[001520] = *L01520; sub L01520 { if (++$core[000154] == 010000) { $core[000154] = 0; $pc++; }$code[000154] = *emul8; goto &fetch; }
$core[001521] = 02154; $code[001521] = *I01521; sub I01521 { if (++$core[000154] == 010000) { $core[000154] = 0; $pc++; }$code[000154] = *emul8; goto &fetch; }
$core[001522] = 05502; $code[001522] = *I01522; sub I01522 { $pc = ($ib<<12)+$core[66]; $inh = 0; goto &fetch; }
$core[001523] = 01575; $code[001523] = *D01523; sub D01523 { $lac += $core[($df<<12)+$core[125]]; goto &fetch; }
$core[001524] = 00000; $code[001524] = *S01524; sub S01524 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001525] = 01142; $code[001525] = *L01525; sub L01525 { $lac += $core[000142]; goto &fetch; }
$core[001526] = 01063; $code[001526] = *I01526; sub I01526 { $lac += $core[000063]; goto &fetch; }
$core[001527] = 07640; $code[001527] = *I01527; sub I01527 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001530] = 05724; $code[001530] = *I01530; sub I01530 { $pc = ($ib<<12)+$core[852]; $inh = 0; goto &fetch; }
$core[001531] = 04506; $code[001531] = *D01531; sub D01531 { $core[($ib<<12)+$core[70]] = 01532; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001532] = 05325; $code[001532] = *I01532; sub I01532 { $pc = 001525; $inh = 0; goto &fetch; }
$core[001533] = 00000; $code[001533] = *S01533; sub S01533 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001534] = 01142; $code[001534] = *I01534; sub I01534 { $lac += $core[000142]; goto &fetch; }
$core[001535] = 01064; $code[001535] = *I01535; sub I01535 { $lac += $core[000064]; goto &fetch; }
$core[001536] = 07440; $code[001536] = *I01536; sub I01536 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001537] = 02333; $code[001537] = *I01537; sub I01537 { if (++$core[001533] == 010000) { $core[001533] = 0; $pc++; }$code[001533] = *emul8; goto &fetch; }
$core[001540] = 01352; $code[001540] = *I01540; sub I01540 { $lac += $core[001552]; goto &fetch; }
$core[001541] = 07500; $code[001541] = *I01541; sub I01541 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[001542] = 05350; $code[001542] = *I01542; sub I01542 { $pc = 001550; $inh = 0; goto &fetch; }
$core[001543] = 01353; $code[001543] = *I01543; sub I01543 { $lac += $core[001553]; goto &fetch; }
$core[001544] = 07510; $code[001544] = *I01544; sub I01544 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001545] = 05350; $code[001545] = *I01545; sub I01545 { $pc = 001550; $inh = 0; goto &fetch; }
$core[001546] = 03127; $code[001546] = *I01546; sub I01546 { $core[000127] = $lac & 07777; $lac &= 010000; $code[000127] = *emul8; goto &fetch; }
$core[001547] = 02333; $code[001547] = *I01547; sub I01547 { if (++$core[001533] == 010000) { $core[001533] = 0; $pc++; }$code[001533] = *emul8; goto &fetch; }
$core[001550] = 07300; $code[001550] = *L01550; sub L01550 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001551] = 05733; $code[001551] = *D01551; sub D01551 { $pc = ($ib<<12)+$core[859]; $inh = 0; goto &fetch; }
$core[001552] = 07764; $code[001552] = *D01552; sub D01552 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[001553] = 00012; $code[001553] = *D01553; sub D01553 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[001554] = 01323; $code[001554] = *D01554; sub D01554 { $lac += $core[001523]; goto &fetch; }
$core[001555] = 03145; $code[001555] = *I01555; sub I01555 { $core[000145] = $lac & 07777; $lac &= 010000; $code[000145] = *emul8; goto &fetch; }
$core[001556] = 01413; $code[001556] = *L01556; sub L01556 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001557] = 03157; $code[001557] = *I01557; sub I01557 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[001560] = 05557; $code[001560] = *I01560; sub I01560 { $pc = ($ib<<12)+$core[111]; $inh = 0; goto &fetch; }
$core[001561] = 01362; $code[001561] = *I01561; sub I01561 { $lac += $core[001562]; goto &fetch; }
$core[001562] = 01260; $code[001562] = *D01562; sub D01562 { $lac += $core[001460]; goto &fetch; }
$core[001563] = 01241; $code[001563] = *I01563; sub I01563 { $lac += $core[001441]; goto &fetch; }
$core[001564] = 01250; $code[001564] = *I01564; sub I01564 { $lac += $core[001450]; goto &fetch; }
$core[001565] = 01254; $code[001565] = *I01565; sub I01565 { $lac += $core[001454]; goto &fetch; }
$core[001566] = 03125; $code[001566] = *I01566; sub I01566 { $core[000125] = $lac & 07777; $lac &= 010000; $code[000125] = *emul8; goto &fetch; }
$core[001567] = 01252; $code[001567] = *I01567; sub I01567 { $lac += $core[001452]; goto &fetch; }
$core[001570] = 01252; $code[001570] = *I01570; sub I01570 { $lac += $core[001452]; goto &fetch; }
$core[001571] = 00615; $code[001571] = *I01571; sub I01571 { $lac &= (010000|$core[($df<<12)+$core[781]]); goto &fetch; }
$core[001572] = 00620; $code[001572] = *I01572; sub I01572 { $lac &= (010000|$core[($df<<12)+$core[784]]); goto &fetch; }
$core[001573] = 00001; $code[001573] = *D01573; sub D01573 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[001574] = 02000; $code[001574] = *I01574; sub I01574 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[001575] = 00000; $code[001575] = *D01575; sub D01575 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001576] = 00000; $code[001576] = *I01576; sub I01576 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001577] = 00000; $code[001577] = *I01577; sub I01577 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001600] = 04506; $code[001600] = *P01600; sub P01600 { $core[($ib<<12)+$core[70]] = 01601; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001601] = 03130; $code[001601] = *I01601; sub I01601 { $core[000130] = $lac & 07777; $lac &= 010000; $code[000130] = *emul8; goto &fetch; }
$core[001602] = 04525; $code[001602] = *I01602; sub I01602 { $core[($ib<<12)+$core[85]] = 01603; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[001603] = 05215; $code[001603] = *I01603; sub I01603 { $pc = 001615; $inh = 0; goto &fetch; }
$core[001604] = 05332; $code[001604] = *I01604; sub I01604 { $pc = 001732; $inh = 0; goto &fetch; }
$core[001605] = 05342; $code[001605] = *I01605; sub I01605 { $pc = 001742; $inh = 0; goto &fetch; }
$core[001606] = 04501; $code[001606] = *L01606; sub L01606 { $core[($ib<<12)+$core[65]] = 01607; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001607] = 01411; $code[001607] = *I01607; sub I01607 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[001610] = 04525; $code[001610] = *L01610; sub L01610 { $core[($ib<<12)+$core[85]] = 01611; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[001611] = 05236; $code[001611] = *I01611; sub I01611 { $pc = 001636; $inh = 0; goto &fetch; }
$core[001612] = 00212; $code[001612] = *D01612; sub D01612 { $lac &= (010000|$core[001612]); goto &fetch; }
$core[001613] = 00377; $code[001613] = *I01613; sub I01613 { $lac &= (010000|$core[001777]); goto &fetch; }
$core[001614] = 04526; $code[001614] = *I01614; sub I01614 { $core[($ib<<12)+$core[86]] = 01615; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001615] = 04504; $code[001615] = *L01615; sub L01615 { $core[($ib<<12)+$core[68]] = 01616; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[001616] = 01575; $code[001616] = *I01616; sub I01616 { $lac += $core[($df<<12)+$core[125]]; goto &fetch; }
$core[001617] = 04505; $code[001617] = *I01617; sub I01617 { $core[($ib<<12)+$core[69]] = 01620; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[001620] = 02034; $code[001620] = *I01620; sub I01620 { if (++$core[000034] == 010000) { $core[000034] = 0; $pc++; }$code[000034] = *emul8; goto &fetch; }
$core[001621] = 01160; $code[001621] = *I01621; sub I01621 { $lac += $core[000160]; goto &fetch; }
$core[001622] = 03154; $code[001622] = *I01622; sub I01622 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[001623] = 01034; $code[001623] = *I01623; sub I01623 { $lac += $core[000034]; goto &fetch; }
$core[001624] = 01127; $code[001624] = *I01624; sub I01624 { $lac += $core[000127]; goto &fetch; }
$core[001625] = 07450; $code[001625] = *I01625; sub I01625 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001626] = 05241; $code[001626] = *I01626; sub I01626 { $pc = 001641; $inh = 0; goto &fetch; }
$core[001627] = 07001; $code[001627] = *I01627; sub I01627 { $lac++; goto &fetch; }
$core[001630] = 07650; $code[001630] = *I01630; sub I01630 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001631] = 05323; $code[001631] = *I01631; sub I01631 { $pc = 001723; $inh = 0; goto &fetch; }
$core[001632] = 01127; $code[001632] = *I01632; sub I01632 { $lac += $core[000127]; goto &fetch; }
$core[001633] = 01070; $code[001633] = *D01633; sub D01633 { $lac += $core[000070]; goto &fetch; }
$core[001634] = 07710; $code[001634] = *I01634; sub I01634 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001635] = 05353; $code[001635] = *I01635; sub I01635 { $pc = 001753; $inh = 0; goto &fetch; }
$core[001636] = 04523; $code[001636] = *L01636; sub L01636 { $core[($ib<<12)+$core[83]] = 01637; $pc = ($ib<<12)+$core[83]+1; $code[($ib<<12)+$core[83]] = *emul8; $inh = 0; goto &fetch; }
$core[001637] = 07410; $code[001637] = *I01637; sub I01637 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001640] = 04526; $code[001640] = *I01640; sub I01640 { $core[($ib<<12)+$core[86]] = 01641; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001641] = 01127; $code[001641] = *L01641; sub L01641 { $lac += $core[000127]; goto &fetch; }
$core[001642] = 03147; $code[001642] = *I01642; sub I01642 { $core[000147] = $lac & 07777; $lac &= 010000; $code[000147] = *emul8; goto &fetch; }
$core[001643] = 01147; $code[001643] = *I01643; sub I01643 { $lac += $core[000147]; goto &fetch; }
$core[001644] = 01070; $code[001644] = *I01644; sub I01644 { $lac += $core[000070]; goto &fetch; }
$core[001645] = 07700; $code[001645] = *I01645; sub I01645 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001646] = 03147; $code[001646] = *I01646; sub I01646 { $core[000147] = $lac & 07777; $lac &= 010000; $code[000147] = *emul8; goto &fetch; }
$core[001647] = 07201; $code[001647] = *L01647; sub L01647 { $lac &= 010000; $lac++; goto &fetch; }
$core[001650] = 00147; $code[001650] = *I01650; sub I01650 { $lac &= (010000|$core[000147]); goto &fetch; }
$core[001651] = 01147; $code[001651] = *I01651; sub I01651 { $lac += $core[000147]; goto &fetch; }
$core[001652] = 07041; $code[001652] = *I01652; sub I01652 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001653] = 03274; $code[001653] = *I01653; sub I01653 { $core[001674] = $lac & 07777; $lac &= 010000; $code[001674] = *emul8; goto &fetch; }
$core[001654] = 07001; $code[001654] = *I01654; sub I01654 { $lac++; goto &fetch; }
$core[001655] = 00130; $code[001655] = *I01655; sub I01655 { $lac &= (010000|$core[000130]); goto &fetch; }
$core[001656] = 01130; $code[001656] = *I01656; sub I01656 { $lac += $core[000130]; goto &fetch; }
$core[001657] = 01274; $code[001657] = *I01657; sub I01657 { $lac += $core[001674]; goto &fetch; }
$core[001660] = 07710; $code[001660] = *I01660; sub I01660 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001661] = 05310; $code[001661] = *I01661; sub I01661 { $pc = 001710; $inh = 0; goto &fetch; }
$core[001662] = 01130; $code[001662] = *I01662; sub I01662 { $lac += $core[000130]; goto &fetch; }
$core[001663] = 01331; $code[001663] = *I01663; sub I01663 { $lac += $core[001731]; goto &fetch; }
$core[001664] = 03274; $code[001664] = *I01664; sub I01664 { $core[001674] = $lac & 07777; $lac &= 010000; $code[001674] = *emul8; goto &fetch; }
$core[001665] = 01674; $code[001665] = *I01665; sub I01665 { $lac += $core[($df<<12)+$core[956]]; goto &fetch; }
$core[001666] = 03274; $code[001666] = *I01666; sub I01666 { $core[001674] = $lac & 07777; $lac &= 010000; $code[001674] = *emul8; goto &fetch; }
$core[001667] = 01130; $code[001667] = *I01667; sub I01667 { $lac += $core[000130]; goto &fetch; }
$core[001670] = 07640; $code[001670] = *I01670; sub I01670 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001671] = 04505; $code[001671] = *I01671; sub I01671 { $core[($ib<<12)+$core[69]] = 01672; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[001672] = 00044; $code[001672] = *I01672; sub I01672 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[001673] = 04407; $code[001673] = *I01673; sub I01673 { $core[($ib<<12)+$core[7]] = 01674; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[001674] = 00000; $code[001674] = *P01674; sub P01674 { &emul8; goto &fetch; }
$core[001675] = 06560; $code[001675] = *I01675; sub I01675 { &emul8; goto &fetch; }
$core[001676] = 00000; $code[001676] = *I01676; sub I01676 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001677] = 01160; $code[001677] = *I01677; sub I01677 { $lac += $core[000160]; goto &fetch; }
$core[001700] = 03154; $code[001700] = *I01700; sub I01700 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[001701] = 01147; $code[001701] = *I01701; sub I01701 { $lac += $core[000147]; goto &fetch; }
$core[001702] = 01130; $code[001702] = *I01702; sub I01702 { $lac += $core[000130]; goto &fetch; }
$core[001703] = 07650; $code[001703] = *I01703; sub I01703 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001704] = 05502; $code[001704] = *I01704; sub I01704 { $pc = ($ib<<12)+$core[66]; $inh = 0; goto &fetch; }
$core[001705] = 01413; $code[001705] = *I01705; sub I01705 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001706] = 03130; $code[001706] = *I01706; sub I01706 { $core[000130] = $lac & 07777; $lac &= 010000; $code[000130] = *emul8; goto &fetch; }
$core[001707] = 05247; $code[001707] = *I01707; sub I01707 { $pc = 001647; $inh = 0; goto &fetch; }
$core[001710] = 04523; $code[001710] = *L01710; sub L01710 { $core[($ib<<12)+$core[83]] = 01711; $pc = ($ib<<12)+$core[83]+1; $code[($ib<<12)+$core[83]] = *emul8; $inh = 0; goto &fetch; }
$core[001711] = 07410; $code[001711] = *I01711; sub I01711 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001712] = 05355; $code[001712] = *I01712; sub I01712 { $pc = 001755; $inh = 0; goto &fetch; }
$core[001713] = 01130; $code[001713] = *I01713; sub I01713 { $lac += $core[000130]; goto &fetch; }
$core[001714] = 04503; $code[001714] = *I01714; sub I01714 { $core[($ib<<12)+$core[67]] = 01715; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001715] = 01154; $code[001715] = *I01715; sub I01715 { $lac += $core[000154]; goto &fetch; }
$core[001716] = 03320; $code[001716] = *I01716; sub I01716 { $core[001720] = $lac & 07777; $lac &= 010000; $code[001720] = *emul8; goto &fetch; }
$core[001717] = 04504; $code[001717] = *I01717; sub I01717 { $core[($ib<<12)+$core[68]] = 01720; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[001720] = 00000; $code[001720] = *D01720; sub D01720 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001721] = 01147; $code[001721] = *I01721; sub I01721 { $lac += $core[000147]; goto &fetch; }
$core[001722] = 03130; $code[001722] = *I01722; sub I01722 { $core[000130] = $lac & 07777; $lac &= 010000; $code[000130] = *emul8; goto &fetch; }
$core[001723] = 04506; $code[001723] = *L01723; sub L01723 { $core[($ib<<12)+$core[70]] = 01724; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001724] = 04525; $code[001724] = *I01724; sub I01724 { $core[($ib<<12)+$core[85]] = 01725; $pc = ($ib<<12)+$core[85]+1; $code[($ib<<12)+$core[85]] = *emul8; $inh = 0; goto &fetch; }
$core[001725] = 05353; $code[001725] = *I01725; sub I01725 { $pc = 001753; $inh = 0; goto &fetch; }
$core[001726] = 05332; $code[001726] = *I01726; sub I01726 { $pc = 001732; $inh = 0; goto &fetch; }
$core[001727] = 05342; $code[001727] = *I01727; sub I01727 { $pc = 001742; $inh = 0; goto &fetch; }
$core[001730] = 05206; $code[001730] = *I01730; sub I01730 { $pc = 001606; $inh = 0; goto &fetch; }
$core[001731] = 02026; $code[001731] = *D01731; sub D01731 { if (++$core[000026] == 010000) { $core[000026] = 0; $pc++; }$code[000026] = *emul8; goto &fetch; }
$core[001732] = 04504; $code[001732] = *L01732; sub L01732 { $core[($ib<<12)+$core[68]] = 01733; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[001733] = 00044; $code[001733] = *I01733; sub I01733 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[001734] = 01160; $code[001734] = *I01734; sub I01734 { $lac += $core[000160]; goto &fetch; }
$core[001735] = 03154; $code[001735] = *I01735; sub I01735 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[001736] = 04473; $code[001736] = *I01736; sub I01736 { $core[($ib<<12)+$core[59]] = 01737; $pc = ($ib<<12)+$core[59]+1; $code[($ib<<12)+$core[59]] = *emul8; $inh = 0; goto &fetch; }
$core[001737] = 04505; $code[001737] = *I01737; sub I01737 { $core[($ib<<12)+$core[69]] = 01740; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[001740] = 00044; $code[001740] = *I01740; sub I01740 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[001741] = 05210; $code[001741] = *I01741; sub I01741 { $pc = 001610; $inh = 0; goto &fetch; }
$core[001742] = 03274; $code[001742] = *L01742; sub L01742 { $core[001674] = $lac & 07777; $lac &= 010000; $code[001674] = *emul8; goto &fetch; }
$core[001743] = 04506; $code[001743] = *I01743; sub I01743 { $core[($ib<<12)+$core[70]] = 01744; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[001744] = 04511; $code[001744] = *I01744; sub I01744 { $core[($ib<<12)+$core[73]] = 01745; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[001745] = 02005; $code[001745] = *I01745; sub I01745 { if (++$core[000005] == 010000) { $core[000005] = 0; $pc++; }$code[000005] = *emul8; goto &fetch; }
$core[001746] = 05364; $code[001746] = *I01746; sub I01746 { $pc = 001764; $inh = 0; goto &fetch; }
$core[001747] = 01274; $code[001747] = *I01747; sub I01747 { $lac += $core[001674]; goto &fetch; }
$core[001750] = 07104; $code[001750] = *I01750; sub I01750 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001751] = 01142; $code[001751] = *I01751; sub I01751 { $lac += $core[000142]; goto &fetch; }
$core[001752] = 05342; $code[001752] = *I01752; sub I01752 { $pc = 001742; $inh = 0; goto &fetch; }
$core[001753] = 04523; $code[001753] = *L01753; sub L01753 { $core[($ib<<12)+$core[83]] = 01754; $pc = ($ib<<12)+$core[83]+1; $code[($ib<<12)+$core[83]] = *emul8; $inh = 0; goto &fetch; }
$core[001754] = 04526; $code[001754] = *I01754; sub I01754 { $core[($ib<<12)+$core[86]] = 01755; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001755] = 01127; $code[001755] = *L01755; sub L01755 { $lac += $core[000127]; goto &fetch; }
$core[001756] = 04503; $code[001756] = *I01756; sub I01756 { $core[($ib<<12)+$core[67]] = 01757; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001757] = 01130; $code[001757] = *I01757; sub I01757 { $lac += $core[000130]; goto &fetch; }
$core[001760] = 04503; $code[001760] = *I01760; sub I01760 { $core[($ib<<12)+$core[67]] = 01761; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001761] = 04501; $code[001761] = *I01761; sub I01761 { $core[($ib<<12)+$core[65]] = 01762; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001762] = 01600; $code[001762] = *I01762; sub I01762 { $lac += $core[($df<<12)+$core[896]]; goto &fetch; }
$core[001763] = 05500; $code[001763] = *I01763; sub I01763 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[001764] = 01127; $code[001764] = *L01764; sub L01764 { $lac += $core[000127]; goto &fetch; }
$core[001765] = 04503; $code[001765] = *I01765; sub I01765 { $core[($ib<<12)+$core[67]] = 01766; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001766] = 01130; $code[001766] = *I01766; sub I01766 { $lac += $core[000130]; goto &fetch; }
$core[001767] = 04503; $code[001767] = *I01767; sub I01767 { $core[($ib<<12)+$core[67]] = 01770; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001770] = 01274; $code[001770] = *I01770; sub I01770 { $lac += $core[001674]; goto &fetch; }
$core[001771] = 04503; $code[001771] = *I01771; sub I01771 { $core[($ib<<12)+$core[67]] = 01772; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[001772] = 04523; $code[001772] = *I01772; sub I01772 { $core[($ib<<12)+$core[83]] = 01773; $pc = ($ib<<12)+$core[83]+1; $code[($ib<<12)+$core[83]] = *emul8; $inh = 0; goto &fetch; }
$core[001773] = 04526; $code[001773] = *I01773; sub I01773 { $core[($ib<<12)+$core[86]] = 01774; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[001774] = 04501; $code[001774] = *I01774; sub I01774 { $core[($ib<<12)+$core[65]] = 01775; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[001775] = 01600; $code[001775] = *I01775; sub I01775 { $lac += $core[($df<<12)+$core[896]]; goto &fetch; }
$core[001776] = 01413; $code[001776] = *I01776; sub I01776 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001777] = 04510; $code[001777] = *D01777; sub D01777 { $core[($ib<<12)+$core[72]] = 02000; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[002000] = 02207; $code[002000] = *I02000; sub I02000 { if (++$core[002007] == 010000) { $core[002007] = 0; $pc++; }$code[002007] = *emul8; goto &fetch; }
$core[002001] = 06361; $code[002001] = *I02001; sub I02001 { &emul8; goto &fetch; }
$core[002002] = 04526; $code[002002] = *I02002; sub I02002 { $core[($ib<<12)+$core[86]] = 02003; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[002003] = 00241; $code[002003] = *D02003; sub D02003 { $lac &= (010000|$core[002041]); goto &fetch; }
$core[002004] = 00242; $code[002004] = *I02004; sub I02004 { $lac &= (010000|$core[002042]); goto &fetch; }
$core[002005] = 00256; $code[002005] = *I02005; sub I02005 { $lac &= (010000|$core[002056]); goto &fetch; }
$core[002006] = 00240; $code[002006] = *I02006; sub I02006 { $lac &= (010000|$core[002040]); goto &fetch; }
$core[002007] = 00253; $code[002007] = *D02007; sub D02007 { $lac &= (010000|$core[002053]); goto &fetch; }
$core[002010] = 00255; $code[002010] = *P02010; sub P02010 { $lac &= (010000|$core[002055]); goto &fetch; }
$core[002011] = 00257; $code[002011] = *I02011; sub I02011 { $lac &= (010000|$core[002057]); goto &fetch; }
$core[002012] = 00252; $code[002012] = *I02012; sub I02012 { $lac &= (010000|$core[002052]); goto &fetch; }
$core[002013] = 00336; $code[002013] = *I02013; sub I02013 { $lac &= (010000|$core[002136]); goto &fetch; }
$core[002014] = 00250; $code[002014] = *I02014; sub I02014 { $lac &= (010000|$core[002050]); goto &fetch; }
$core[002015] = 00333; $code[002015] = *D02015; sub D02015 { $lac &= (010000|$core[002133]); goto &fetch; }
$core[002016] = 00274; $code[002016] = *I02016; sub I02016 { $lac &= (010000|$core[002074]); goto &fetch; }
$core[002017] = 00251; $code[002017] = *I02017; sub I02017 { $lac &= (010000|$core[002051]); goto &fetch; }
$core[002020] = 00335; $code[002020] = *I02020; sub I02020 { $lac &= (010000|$core[002135]); goto &fetch; }
$core[002021] = 00276; $code[002021] = *I02021; sub I02021 { $lac &= (010000|$core[002076]); goto &fetch; }
$core[002022] = 00254; $code[002022] = *I02022; sub I02022 { $lac &= (010000|$core[002054]); goto &fetch; }
$core[002023] = 00273; $code[002023] = *I02023; sub I02023 { $lac &= (010000|$core[002073]); goto &fetch; }
$core[002024] = 00215; $code[002024] = *I02024; sub I02024 { $lac &= (010000|$core[002015]); goto &fetch; }
$core[002025] = 00275; $code[002025] = *I02025; sub I02025 { $lac &= (010000|$core[002075]); goto &fetch; }
$core[002026] = 05554; $code[002026] = *I02026; sub I02026 { $pc = ($ib<<12)+$core[108]; $inh = 0; goto &fetch; }
$core[002027] = 01554; $code[002027] = *I02027; sub I02027 { $lac += $core[($df<<12)+$core[108]]; goto &fetch; }
$core[002030] = 02554; $code[002030] = *I02030; sub I02030 { if (++$core[($df<<12)+$core[108]] == 010000) { $core[($df<<12)+$core[108]] = 0; $pc++; }$code[($df<<12)+$core[108]] = *emul8; goto &fetch; }
$core[002031] = 04554; $code[002031] = *I02031; sub I02031 { $core[($ib<<12)+$core[108]] = 02032; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[002032] = 03554; $code[002032] = *I02032; sub I02032 { $core[($df<<12)+$core[108]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[108]] = *emul8; goto &fetch; }
$core[002033] = 00554; $code[002033] = *I02033; sub I02033 { $lac &= (010000|$core[($df<<12)+$core[108]]); goto &fetch; }
$core[002034] = 00000; $code[002034] = *D02034; sub D02034 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002035] = 00000; $code[002035] = *I02035; sub I02035 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002036] = 00000; $code[002036] = *I02036; sub I02036 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002037] = 07056; $code[002037] = *D02037; sub D02037 { $lac ^= 07777; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[002040] = 06473; $code[002040] = *D02040; sub D02040 { &emul8; goto &fetch; }
$core[002041] = 01740; $code[002041] = *D02041; sub D02041 { $lac += $core[($df<<12)+$core[1120]]; goto &fetch; }
$core[002042] = 01354; $code[002042] = *D02042; sub D02042 { $lac += $core[002154]; goto &fetch; }
$core[002043] = 02454; $code[002043] = *I02043; sub I02043 { if (++$core[($df<<12)+$core[44]] == 010000) { $core[($df<<12)+$core[44]] = 0; $pc++; }$code[($df<<12)+$core[44]] = *emul8; goto &fetch; }
$core[002044] = 01154; $code[002044] = *I02044; sub I02044 { $lac += $core[000154]; goto &fetch; }
$core[002045] = 00554; $code[002045] = *I02045; sub I02045 { $lac &= (010000|$core[($df<<12)+$core[108]]); goto &fetch; }
$core[002046] = 07254; $code[002046] = *I02046; sub I02046 { $lac &= 010000; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002047] = 02373; $code[002047] = *I02047; sub I02047 { if (++$core[002173] == 010000) { $core[002173] = 0; $pc++; }$code[002173] = *emul8; goto &fetch; }
$core[002050] = 00540; $code[002050] = *D02050; sub D02050 { $lac &= (010000|$core[($df<<12)+$core[96]]); goto &fetch; }
$core[002051] = 00177; $code[002051] = *D02051; sub D02051 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[002052] = 01500; $code[002052] = *D02052; sub D02052 { $lac += $core[($df<<12)+$core[64]]; goto &fetch; }
$core[002053] = 01045; $code[002053] = *D02053; sub D02053 { $lac += $core[000045]; goto &fetch; }
$core[002054] = 07710; $code[002054] = *D02054; sub D02054 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002055] = 04450; $code[002055] = *D02055; sub D02055 { $core[($ib<<12)+$core[40]] = 02056; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[002056] = 01413; $code[002056] = *L02056; sub L02056 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[002057] = 03130; $code[002057] = *D02057; sub D02057 { $core[000130] = $lac & 07777; $lac &= 010000; $code[000130] = *emul8; goto &fetch; }
$core[002060] = 04407; $code[002060] = *I02060; sub I02060 { $core[($ib<<12)+$core[7]] = 02061; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[002061] = 07000; $code[002061] = *I02061; sub I02061 { &emul8; goto &fetch; }
$core[002062] = 06234; $code[002062] = *I02062; sub I02062 { &emul8; goto &fetch; }
$core[002063] = 00000; $code[002063] = *I02063; sub I02063 { &emul8; goto &fetch; }
$core[002064] = 01160; $code[002064] = *I02064; sub I02064 { $lac += $core[000160]; goto &fetch; }
$core[002065] = 03154; $code[002065] = *I02065; sub I02065 { $core[000154] = $lac & 07777; $lac &= 010000; $code[000154] = *emul8; goto &fetch; }
$core[002066] = 01413; $code[002066] = *I02066; sub I02066 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[002067] = 07041; $code[002067] = *I02067; sub I02067 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002070] = 01066; $code[002070] = *I02070; sub I02070 { $lac += $core[000066]; goto &fetch; }
$core[002071] = 01127; $code[002071] = *I02071; sub I02071 { $lac += $core[000127]; goto &fetch; }
$core[002072] = 07640; $code[002072] = *I02072; sub I02072 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002073] = 04526; $code[002073] = *D02073; sub D02073 { $core[($ib<<12)+$core[86]] = 02074; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[002074] = 04506; $code[002074] = *D02074; sub D02074 { $core[($ib<<12)+$core[70]] = 02075; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[002075] = 05676; $code[002075] = *D02075; sub D02075 { $pc = ($ib<<12)+$core[1086]; $inh = 0; goto &fetch; }
$core[002076] = 01610; $code[002076] = *P02076; sub P02076 { $lac += $core[($df<<12)+$core[1032]]; goto &fetch; }
$core[002077] = 00000; $code[002077] = *S02077; sub S02077 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002100] = 01127; $code[002100] = *I02100; sub I02100 { $lac += $core[000127]; goto &fetch; }
$core[002101] = 01070; $code[002101] = *I02101; sub I02101 { $lac += $core[000070]; goto &fetch; }
$core[002102] = 07700; $code[002102] = *I02102; sub I02102 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002103] = 05677; $code[002103] = *I02103; sub I02103 { $pc = ($ib<<12)+$core[1087]; $inh = 0; goto &fetch; }
$core[002104] = 01127; $code[002104] = *I02104; sub I02104 { $lac += $core[000127]; goto &fetch; }
$core[002105] = 01067; $code[002105] = *I02105; sub I02105 { $lac += $core[000067]; goto &fetch; }
$core[002106] = 07740; $code[002106] = *I02106; sub I02106 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002107] = 02277; $code[002107] = *I02107; sub I02107 { if (++$core[002077] == 010000) { $core[002077] = 0; $pc++; }$code[002077] = *emul8; goto &fetch; }
$core[002110] = 05677; $code[002110] = *I02110; sub I02110 { $pc = ($ib<<12)+$core[1087]; $inh = 0; goto &fetch; }
$core[002111] = 04516; $code[002111] = *L02111; sub L02111 { $core[($ib<<12)+$core[78]] = 02112; $pc = ($ib<<12)+$core[78]+1; $code[($ib<<12)+$core[78]] = *emul8; $inh = 0; goto &fetch; }
$core[002112] = 05502; $code[002112] = *I02112; sub I02112 { $pc = ($ib<<12)+$core[66]; $inh = 0; goto &fetch; }
$core[002113] = 02151; $code[002113] = *I02113; sub I02113 { if (++$core[000151] == 010000) { $core[000151] = 0; $pc++; }$code[000151] = *emul8; goto &fetch; }
$core[002114] = 04506; $code[002114] = *L02114; sub L02114 { $core[($ib<<12)+$core[70]] = 02115; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[002115] = 01142; $code[002115] = *I02115; sub I02115 { $lac += $core[000142]; goto &fetch; }
$core[002116] = 01065; $code[002116] = *I02116; sub I02116 { $lac += $core[000065]; goto &fetch; }
$core[002117] = 07640; $code[002117] = *I02117; sub I02117 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002120] = 05314; $code[002120] = *I02120; sub I02120 { $pc = 002114; $inh = 0; goto &fetch; }
$core[002121] = 01017; $code[002121] = *I02121; sub I02121 { $lac += $core[000017]; goto &fetch; }
$core[002122] = 07040; $code[002122] = *I02122; sub I02122 { $lac ^= 07777; goto &fetch; }
$core[002123] = 01146; $code[002123] = *I02123; sub I02123 { $lac += $core[000146]; goto &fetch; }
$core[002124] = 03132; $code[002124] = *I02124; sub I02124 { $core[000132] = $lac & 07777; $lac &= 010000; $code[000132] = *emul8; goto &fetch; }
$core[002125] = 01546; $code[002125] = *I02125; sub I02125 { $lac += $core[($df<<12)+$core[102]]; goto &fetch; }
$core[002126] = 03550; $code[002126] = *I02126; sub I02126 { $core[($df<<12)+$core[104]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[104]] = *emul8; goto &fetch; }
$core[002127] = 01075; $code[002127] = *I02127; sub I02127 { $lac += $core[000075]; goto &fetch; }
$core[002130] = 03157; $code[002130] = *L02130; sub L02130 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[002131] = 01557; $code[002131] = *I02131; sub I02131 { $lac += $core[($df<<12)+$core[111]]; goto &fetch; }
$core[002132] = 07450; $code[002132] = *I02132; sub I02132 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002133] = 05346; $code[002133] = *D02133; sub D02133 { $pc = 002146; $inh = 0; goto &fetch; }
$core[002134] = 03156; $code[002134] = *I02134; sub I02134 { $core[000156] = $lac & 07777; $lac &= 010000; $code[000156] = *emul8; goto &fetch; }
$core[002135] = 01146; $code[002135] = *D02135; sub D02135 { $lac += $core[000146]; goto &fetch; }
$core[002136] = 07141; $code[002136] = *D02136; sub D02136 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[002137] = 01156; $code[002137] = *I02137; sub I02137 { $lac += $core[000156]; goto &fetch; }
$core[002140] = 07630; $code[002140] = *P02140; sub P02140 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002141] = 01132; $code[002141] = *I02141; sub I02141 { $lac += $core[000132]; goto &fetch; }
$core[002142] = 01156; $code[002142] = *I02142; sub I02142 { $lac += $core[000156]; goto &fetch; }
$core[002143] = 03557; $code[002143] = *I02143; sub I02143 { $core[($df<<12)+$core[111]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[111]] = *emul8; goto &fetch; }
$core[002144] = 01156; $code[002144] = *I02144; sub I02144 { $lac += $core[000156]; goto &fetch; }
$core[002145] = 05330; $code[002145] = *I02145; sub I02145 { $pc = 002130; $inh = 0; goto &fetch; }
$core[002146] = 07040; $code[002146] = *L02146; sub L02146 { $lac ^= 07777; goto &fetch; }
$core[002147] = 01146; $code[002147] = *I02147; sub I02147 { $lac += $core[000146]; goto &fetch; }
$core[002150] = 03011; $code[002150] = *I02150; sub I02150 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[002151] = 01132; $code[002151] = *I02151; sub I02151 { $lac += $core[000132]; goto &fetch; }
$core[002152] = 07040; $code[002152] = *I02152; sub I02152 { $lac ^= 07777; goto &fetch; }
$core[002153] = 01146; $code[002153] = *I02153; sub I02153 { $lac += $core[000146]; goto &fetch; }
$core[002154] = 03012; $code[002154] = *D02154; sub D02154 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[002155] = 01132; $code[002155] = *I02155; sub I02155 { $lac += $core[000132]; goto &fetch; }
$core[002156] = 01134; $code[002156] = *I02156; sub I02156 { $lac += $core[000134]; goto &fetch; }
$core[002157] = 03134; $code[002157] = *I02157; sub I02157 { $core[000134] = $lac & 07777; $lac &= 010000; $code[000134] = *emul8; goto &fetch; }
$core[002160] = 01010; $code[002160] = *I02160; sub I02160 { $lac += $core[000010]; goto &fetch; }
$core[002161] = 07040; $code[002161] = *I02161; sub I02161 { $lac ^= 07777; goto &fetch; }
$core[002162] = 01012; $code[002162] = *I02162; sub I02162 { $lac += $core[000012]; goto &fetch; }
$core[002163] = 03156; $code[002163] = *I02163; sub I02163 { $core[000156] = $lac & 07777; $lac &= 010000; $code[000156] = *emul8; goto &fetch; }
$core[002164] = 01010; $code[002164] = *I02164; sub I02164 { $lac += $core[000010]; goto &fetch; }
$core[002165] = 01132; $code[002165] = *I02165; sub I02165 { $lac += $core[000132]; goto &fetch; }
$core[002166] = 03010; $code[002166] = *I02166; sub I02166 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[002167] = 01412; $code[002167] = *L02167; sub L02167 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac += $core[($df<<12)+$core[000012]]; goto &fetch; }
$core[002170] = 03411; $code[002170] = *I02170; sub I02170 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[002171] = 02156; $code[002171] = *I02171; sub I02171 { if (++$core[000156] == 010000) { $core[000156] = 0; $pc++; }$code[000156] = *emul8; goto &fetch; }
$core[002172] = 05367; $code[002172] = *I02172; sub I02172 { $pc = 002167; $inh = 0; goto &fetch; }
$core[002173] = 05311; $code[002173] = *D02173; sub D02173 { $pc = 002111; $inh = 0; goto &fetch; }
$core[002174] = 06457; $code[002174] = *I02174; sub I02174 { &emul8; goto &fetch; }
$core[002175] = 06453; $code[002175] = *I02175; sub I02175 { &emul8; goto &fetch; }
$core[002176] = 03237; $code[002176] = *I02176; sub I02176 { $core[002037] = $lac & 07777; $lac &= 010000; $code[002037] = *emul8; goto &fetch; }
$core[002177] = 03234; $code[002177] = *I02177; sub I02177 { $core[002034] = $lac & 07777; $lac &= 010000; $code[002034] = *emul8; goto &fetch; }
$core[002200] = 03303; $code[002200] = *I02200; sub I02200 { $core[002303] = $lac & 07777; $lac &= 010000; $code[002303] = *emul8; goto &fetch; }
$core[002201] = 03302; $code[002201] = *I02201; sub I02201 { $core[002302] = $lac & 07777; $lac &= 010000; $code[002302] = *emul8; goto &fetch; }
$core[002202] = 03244; $code[002202] = *I02202; sub I02202 { $core[002244] = $lac & 07777; $lac &= 010000; $code[002244] = *emul8; goto &fetch; }
$core[002203] = 03243; $code[002203] = *I02203; sub I02203 { $core[002243] = $lac & 07777; $lac &= 010000; $code[002243] = *emul8; goto &fetch; }
$core[002204] = 03252; $code[002204] = *I02204; sub I02204 { $core[002252] = $lac & 07777; $lac &= 010000; $code[002252] = *emul8; goto &fetch; }
$core[002205] = 03253; $code[002205] = *I02205; sub I02205 { $core[002253] = $lac & 07777; $lac &= 010000; $code[002253] = *emul8; goto &fetch; }
$core[002206] = 03256; $code[002206] = *I02206; sub I02206 { $core[002256] = $lac & 07777; $lac &= 010000; $code[002256] = *emul8; goto &fetch; }
$core[002207] = 03271; $code[002207] = *I02207; sub I02207 { $core[002271] = $lac & 07777; $lac &= 010000; $code[002271] = *emul8; goto &fetch; }
$core[002210] = 02533; $code[002210] = *I02210; sub I02210 { if (++$core[($df<<12)+$core[91]] == 010000) { $core[($df<<12)+$core[91]] = 0; $pc++; }$code[($df<<12)+$core[91]] = *emul8; goto &fetch; }
$core[002211] = 02650; $code[002211] = *I02211; sub I02211 { if (++$core[($df<<12)+$core[1192]] == 010000) { $core[($df<<12)+$core[1192]] = 0; $pc++; }$code[($df<<12)+$core[1192]] = *emul8; goto &fetch; }
$core[002212] = 02636; $code[002212] = *I02212; sub I02212 { if (++$core[($df<<12)+$core[1182]] == 010000) { $core[($df<<12)+$core[1182]] = 0; $pc++; }$code[($df<<12)+$core[1182]] = *emul8; goto &fetch; }
$core[002213] = 02565; $code[002213] = *I02213; sub I02213 { if (++$core[($df<<12)+$core[117]] == 010000) { $core[($df<<12)+$core[117]] = 0; $pc++; }$code[($df<<12)+$core[117]] = *emul8; goto &fetch; }
$core[002214] = 02630; $code[002214] = *I02214; sub I02214 { if (++$core[($df<<12)+$core[1176]] == 010000) { $core[($df<<12)+$core[1176]] = 0; $pc++; }$code[($df<<12)+$core[1176]] = *emul8; goto &fetch; }
$core[002215] = 02623; $code[002215] = *I02215; sub I02215 { if (++$core[($df<<12)+$core[1171]] == 010000) { $core[($df<<12)+$core[1171]] = 0; $pc++; }$code[($df<<12)+$core[1171]] = *emul8; goto &fetch; }
$core[002216] = 02517; $code[002216] = *P02216; sub P02216 { if (++$core[($df<<12)+$core[79]] == 010000) { $core[($df<<12)+$core[79]] = 0; $pc++; }$code[($df<<12)+$core[79]] = *emul8; goto &fetch; }
$core[002217] = 02572; $code[002217] = *I02217; sub I02217 { if (++$core[($df<<12)+$core[122]] == 010000) { $core[($df<<12)+$core[122]] = 0; $pc++; }$code[($df<<12)+$core[122]] = *emul8; goto &fetch; }
$core[002220] = 02624; $code[002220] = *I02220; sub I02220 { if (++$core[($df<<12)+$core[1172]] == 010000) { $core[($df<<12)+$core[1172]] = 0; $pc++; }$code[($df<<12)+$core[1172]] = *emul8; goto &fetch; }
$core[002221] = 02625; $code[002221] = *I02221; sub I02221 { if (++$core[($df<<12)+$core[1173]] == 010000) { $core[($df<<12)+$core[1173]] = 0; $pc++; }$code[($df<<12)+$core[1173]] = *emul8; goto &fetch; }
$core[002222] = 02654; $code[002222] = *I02222; sub I02222 { if (++$core[($df<<12)+$core[1196]] == 010000) { $core[($df<<12)+$core[1196]] = 0; $pc++; }$code[($df<<12)+$core[1196]] = *emul8; goto &fetch; }
$core[002223] = 02575; $code[002223] = *P02223; sub P02223 { if (++$core[($df<<12)+$core[125]] == 010000) { $core[($df<<12)+$core[125]] = 0; $pc++; }$code[($df<<12)+$core[125]] = *emul8; goto &fetch; }
$core[002224] = 02702; $code[002224] = *P02224; sub P02224 { if (++$core[($df<<12)+$core[1218]] == 010000) { $core[($df<<12)+$core[1218]] = 0; $pc++; }$code[($df<<12)+$core[1218]] = *emul8; goto &fetch; }
$core[002225] = 02631; $code[002225] = *P02225; sub P02225 { if (++$core[($df<<12)+$core[1177]] == 010000) { $core[($df<<12)+$core[1177]] = 0; $pc++; }$code[($df<<12)+$core[1177]] = *emul8; goto &fetch; }
$core[002226] = 01142; $code[002226] = *I02226; sub I02226 { $lac += $core[000142]; goto &fetch; }
$core[002227] = 01003; $code[002227] = *I02227; sub I02227 { $lac += $core[000003]; goto &fetch; }
$core[002230] = 07640; $code[002230] = *P02230; sub P02230 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002231] = 05240; $code[002231] = *P02231; sub P02231 { $pc = 002240; $inh = 0; goto &fetch; }
$core[002232] = 01077; $code[002232] = *L02232; sub L02232 { $lac += $core[000077]; goto &fetch; }
$core[002233] = 03134; $code[002233] = *I02233; sub I02233 { $core[000134] = $lac & 07777; $lac &= 010000; $code[000134] = *emul8; goto &fetch; }
$core[002234] = 03475; $code[002234] = *I02234; sub I02234 { $core[($df<<12)+$core[61]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[61]] = *emul8; goto &fetch; }
$core[002235] = 01134; $code[002235] = *L02235; sub L02235 { $lac += $core[000134]; goto &fetch; }
$core[002236] = 03155; $code[002236] = *P02236; sub P02236 { $core[000155] = $lac & 07777; $lac &= 010000; $code[000155] = *emul8; goto &fetch; }
$core[002237] = 05177; $code[002237] = *I02237; sub I02237 { $pc = 000177; $inh = 0; goto &fetch; }
$core[002240] = 04515; $code[002240] = *L02240; sub L02240 { $core[($ib<<12)+$core[77]] = 02241; $pc = ($ib<<12)+$core[77]+1; $code[($ib<<12)+$core[77]] = *emul8; $inh = 0; goto &fetch; }
$core[002241] = 01143; $code[002241] = *I02241; sub I02241 { $lac += $core[000143]; goto &fetch; }
$core[002242] = 07640; $code[002242] = *I02242; sub I02242 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002243] = 05250; $code[002243] = *D02243; sub D02243 { $pc = 002250; $inh = 0; goto &fetch; }
$core[002244] = 01134; $code[002244] = *D02244; sub D02244 { $lac += $core[000134]; goto &fetch; }
$core[002245] = 03155; $code[002245] = *I02245; sub I02245 { $core[000155] = $lac & 07777; $lac &= 010000; $code[000155] = *emul8; goto &fetch; }
$core[002246] = 05647; $code[002246] = *I02246; sub I02246 { $pc = ($ib<<12)+$core[1191]; $inh = 0; goto &fetch; }
$core[002247] = 00616; $code[002247] = *P02247; sub P02247 { $lac &= (010000|$core[($df<<12)+$core[1166]]); goto &fetch; }
$core[002250] = 01134; $code[002250] = *P02250; sub P02250 { $lac += $core[000134]; goto &fetch; }
$core[002251] = 03010; $code[002251] = *I02251; sub I02251 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[002252] = 04501; $code[002252] = *L02252; sub L02252 { $core[($ib<<12)+$core[65]] = 02253; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[002253] = 02111; $code[002253] = *D02253; sub D02253 { if (++$core[000111] == 010000) { $core[000111] = 0; $pc++; }$code[000111] = *emul8; goto &fetch; }
$core[002254] = 02146; $code[002254] = *P02254; sub P02254 { if (++$core[000146] == 010000) { $core[000146] = 0; $pc++; }$code[000146] = *emul8; goto &fetch; }
$core[002255] = 01141; $code[002255] = *I02255; sub I02255 { $lac += $core[000141]; goto &fetch; }
$core[002256] = 07700; $code[002256] = *D02256; sub D02256 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002257] = 01546; $code[002257] = *I02257; sub I02257 { $lac += $core[($df<<12)+$core[102]]; goto &fetch; }
$core[002260] = 04524; $code[002260] = *I02260; sub I02260 { $core[($ib<<12)+$core[84]] = 02261; $pc = ($ib<<12)+$core[84]+1; $code[($ib<<12)+$core[84]] = *emul8; $inh = 0; goto &fetch; }
$core[002261] = 05235; $code[002261] = *I02261; sub I02261 { $pc = 002235; $inh = 0; goto &fetch; }
$core[002262] = 01546; $code[002262] = *I02262; sub I02262 { $lac += $core[($df<<12)+$core[102]]; goto &fetch; }
$core[002263] = 03143; $code[002263] = *I02263; sub I02263 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[002264] = 05252; $code[002264] = *I02264; sub I02264 { $pc = 002252; $inh = 0; goto &fetch; }
$core[002265] = 00000; $code[002265] = *S02265; sub S02265 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002266] = 01075; $code[002266] = *I02266; sub I02266 { $lac += $core[000075]; goto &fetch; }
$core[002267] = 03150; $code[002267] = *I02267; sub I02267 { $core[000150] = $lac & 07777; $lac &= 010000; $code[000150] = *emul8; goto &fetch; }
$core[002270] = 01075; $code[002270] = *I02270; sub I02270 { $lac += $core[000075]; goto &fetch; }
$core[002271] = 03146; $code[002271] = *L02271; sub L02271 { $core[000146] = $lac & 07777; $lac &= 010000; $code[000146] = *emul8; goto &fetch; }
$core[002272] = 01146; $code[002272] = *I02272; sub I02272 { $lac += $core[000146]; goto &fetch; }
$core[002273] = 03012; $code[002273] = *I02273; sub I02273 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[002274] = 01143; $code[002274] = *I02274; sub I02274 { $lac += $core[000143]; goto &fetch; }
$core[002275] = 07041; $code[002275] = *I02275; sub I02275 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002276] = 01412; $code[002276] = *I02276; sub I02276 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac += $core[($df<<12)+$core[000012]]; goto &fetch; }
$core[002277] = 07450; $code[002277] = *I02277; sub I02277 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002300] = 02265; $code[002300] = *I02300; sub I02300 { if (++$core[002265] == 010000) { $core[002265] = 0; $pc++; }$code[002265] = *emul8; goto &fetch; }
$core[002301] = 07700; $code[002301] = *I02301; sub I02301 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002302] = 05310; $code[002302] = *P02302; sub P02302 { $pc = 002310; $inh = 0; goto &fetch; }
$core[002303] = 01146; $code[002303] = *D02303; sub D02303 { $lac += $core[000146]; goto &fetch; }
$core[002304] = 03150; $code[002304] = *I02304; sub I02304 { $core[000150] = $lac & 07777; $lac &= 010000; $code[000150] = *emul8; goto &fetch; }
$core[002305] = 01546; $code[002305] = *I02305; sub I02305 { $lac += $core[($df<<12)+$core[102]]; goto &fetch; }
$core[002306] = 07440; $code[002306] = *I02306; sub I02306 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002307] = 05271; $code[002307] = *I02307; sub I02307 { $pc = 002271; $inh = 0; goto &fetch; }
$core[002310] = 01146; $code[002310] = *L02310; sub L02310 { $lac += $core[000146]; goto &fetch; }
$core[002311] = 07001; $code[002311] = *I02311; sub I02311 { $lac++; goto &fetch; }
$core[002312] = 03017; $code[002312] = *I02312; sub I02312 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[002313] = 03020; $code[002313] = *I02313; sub I02313 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[002314] = 05665; $code[002314] = *I02314; sub I02314 { $pc = ($ib<<12)+$core[1205]; $inh = 0; goto &fetch; }
$core[002315] = 00000; $code[002315] = *S02315; sub S02315 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002316] = 04351; $code[002316] = *L02316; sub L02316 { $core[002351] = 02317; $pc = 002351+1; $code[002351] = *emul8; $inh = 0; goto &fetch; }
$core[002317] = 07710; $code[002317] = *L02317; sub L02317 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002320] = 01006; $code[002320] = *I02320; sub I02320 { $lac += $core[000006]; goto &fetch; }
$core[002321] = 01377; $code[002321] = *I02321; sub I02321 { $lac += $core[002377]; goto &fetch; }
$core[002322] = 01142; $code[002322] = *I02322; sub I02322 { $lac += $core[000142]; goto &fetch; }
$core[002323] = 07450; $code[002323] = *I02323; sub I02323 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002324] = 05337; $code[002324] = *I02324; sub I02324 { $pc = 002337; $inh = 0; goto &fetch; }
$core[002325] = 01054; $code[002325] = *I02325; sub I02325 { $lac += $core[000054]; goto &fetch; }
$core[002326] = 03142; $code[002326] = *L02326; sub L02326 { $core[000142] = $lac & 07777; $lac &= 010000; $code[000142] = *emul8; goto &fetch; }
$core[002327] = 01151; $code[002327] = *I02327; sub I02327 { $lac += $core[000151]; goto &fetch; }
$core[002330] = 01152; $code[002330] = *I02330; sub I02330 { $lac += $core[000152]; goto &fetch; }
$core[002331] = 07650; $code[002331] = *I02331; sub I02331 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002332] = 04512; $code[002332] = *I02332; sub I02332 { $core[($ib<<12)+$core[74]] = 02333; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[002333] = 05715; $code[002333] = *I02333; sub I02333 { $pc = ($ib<<12)+$core[1229]; $inh = 0; goto &fetch; }
$core[002334] = 04351; $code[002334] = *L02334; sub L02334 { $core[002351] = 02335; $pc = 002351+1; $code[002351] = *emul8; $inh = 0; goto &fetch; }
$core[002335] = 07040; $code[002335] = *I02335; sub I02335 { $lac ^= 07777; goto &fetch; }
$core[002336] = 05317; $code[002336] = *I02336; sub I02336 { $pc = 002317; $inh = 0; goto &fetch; }
$core[002337] = 01151; $code[002337] = *L02337; sub L02337 { $lac += $core[000151]; goto &fetch; }
$core[002340] = 07640; $code[002340] = *I02340; sub I02340 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002341] = 05347; $code[002341] = *I02341; sub I02341 { $pc = 002347; $inh = 0; goto &fetch; }
$core[002342] = 01152; $code[002342] = *I02342; sub I02342 { $lac += $core[000152]; goto &fetch; }
$core[002343] = 07650; $code[002343] = *I02343; sub I02343 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002344] = 07001; $code[002344] = *I02344; sub I02344 { $lac++; goto &fetch; }
$core[002345] = 03152; $code[002345] = *I02345; sub I02345 { $core[000152] = $lac & 07777; $lac &= 010000; $code[000152] = *emul8; goto &fetch; }
$core[002346] = 05316; $code[002346] = *I02346; sub I02346 { $pc = 002316; $inh = 0; goto &fetch; }
$core[002347] = 01032; $code[002347] = *L02347; sub L02347 { $lac += $core[000032]; goto &fetch; }
$core[002350] = 05326; $code[002350] = *I02350; sub I02350 { $pc = 002326; $inh = 0; goto &fetch; }
$core[002351] = 00000; $code[002351] = *S02351; sub S02351 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002352] = 02020; $code[002352] = *I02352; sub I02352 { if (++$core[000020] == 010000) { $core[000020] = 0; $pc++; }$code[000020] = *emul8; goto &fetch; }
$core[002353] = 05366; $code[002353] = *I02353; sub I02353 { $pc = 002366; $inh = 0; goto &fetch; }
$core[002354] = 01021; $code[002354] = *I02354; sub I02354 { $lac += $core[000021]; goto &fetch; }
$core[002355] = 00071; $code[002355] = *L02355; sub L02355 { $lac &= (010000|$core[000071]); goto &fetch; }
$core[002356] = 03142; $code[002356] = *I02356; sub I02356 { $core[000142] = $lac & 07777; $lac &= 010000; $code[000142] = *emul8; goto &fetch; }
$core[002357] = 01142; $code[002357] = *I02357; sub I02357 { $lac += $core[000142]; goto &fetch; }
$core[002360] = 01023; $code[002360] = *I02360; sub I02360 { $lac += $core[000023]; goto &fetch; }
$core[002361] = 07650; $code[002361] = *I02361; sub I02361 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002362] = 05334; $code[002362] = *I02362; sub I02362 { $pc = 002334; $inh = 0; goto &fetch; }
$core[002363] = 01142; $code[002363] = *I02363; sub I02363 { $lac += $core[000142]; goto &fetch; }
$core[002364] = 01376; $code[002364] = *I02364; sub I02364 { $lac += $core[002376]; goto &fetch; }
$core[002365] = 05751; $code[002365] = *I02365; sub I02365 { $pc = ($ib<<12)+$core[1257]; $inh = 0; goto &fetch; }
$core[002366] = 01417; $code[002366] = *L02366; sub L02366 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac += $core[($df<<12)+$core[000017]]; goto &fetch; }
$core[002367] = 03021; $code[002367] = *I02367; sub I02367 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[002370] = 07040; $code[002370] = *I02370; sub I02370 { $lac ^= 07777; goto &fetch; }
$core[002371] = 03020; $code[002371] = *I02371; sub I02371 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[002372] = 01021; $code[002372] = *I02372; sub I02372 { $lac += $core[000021]; goto &fetch; }
$core[002373] = 04520; $code[002373] = *I02373; sub I02373 { $core[($ib<<12)+$core[80]] = 02374; $pc = ($ib<<12)+$core[80]+1; $code[($ib<<12)+$core[80]] = *emul8; $inh = 0; goto &fetch; }
$core[002374] = 07004; $code[002374] = *I02374; sub I02374 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002375] = 05355; $code[002375] = *I02375; sub I02375 { $pc = 002355; $inh = 0; goto &fetch; }
$core[002376] = 07740; $code[002376] = *D02376; sub D02376 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002377] = 07641; $code[002377] = *D02377; sub D02377 { &emul8; goto &fetch; }
$core[002400] = 00313; $code[002400] = *I02400; sub I02400 { $lac &= (010000|$core[002513]); goto &fetch; }
$core[002401] = 00322; $code[002401] = *I02401; sub I02401 { $lac &= (010000|$core[002522]); goto &fetch; }
$core[002402] = 00324; $code[002402] = *I02402; sub I02402 { $lac &= (010000|$core[002524]); goto &fetch; }
$core[002403] = 00320; $code[002403] = *I02403; sub I02403 { $lac &= (010000|$core[002520]); goto &fetch; }
$core[002404] = 00311; $code[002404] = *I02404; sub I02404 { $lac &= (010000|$core[002511]); goto &fetch; }
$core[002405] = 00303; $code[002405] = *I02405; sub I02405 { $lac &= (010000|$core[002503]); goto &fetch; }
$core[002406] = 00272; $code[002406] = *I02406; sub I02406 { $lac &= (010000|$core[002472]); goto &fetch; }
$core[002407] = 00330; $code[002407] = *I02407; sub I02407 { $lac &= (010000|$core[002530]); goto &fetch; }
$core[002410] = 00305; $code[002410] = *I02410; sub I02410 { $lac &= (010000|$core[002505]); goto &fetch; }
$core[002411] = 00316; $code[002411] = *P02411; sub P02411 { $lac &= (010000|$core[002516]); goto &fetch; }
$core[002412] = 00323; $code[002412] = *I02412; sub I02412 { $lac &= (010000|$core[002523]); goto &fetch; }
$core[002413] = 00315; $code[002413] = *I02413; sub I02413 { $lac &= (010000|$core[002515]); goto &fetch; }
$core[002414] = 06004; $code[002414] = *I02414; sub I02414 { &emul8; goto &fetch; }
$core[002415] = 03045; $code[002415] = *I02415; sub I02415 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[002416] = 05500; $code[002416] = *I02416; sub I02416 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[002417] = 00000; $code[002417] = *S02417; sub S02417 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002420] = 01550; $code[002420] = *I02420; sub I02420 { $lac += $core[($df<<12)+$core[104]]; goto &fetch; }
$core[002421] = 03534; $code[002421] = *I02421; sub I02421 { $core[($df<<12)+$core[92]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[92]] = *emul8; goto &fetch; }
$core[002422] = 01134; $code[002422] = *I02422; sub I02422 { $lac += $core[000134]; goto &fetch; }
$core[002423] = 03550; $code[002423] = *I02423; sub I02423 { $core[($df<<12)+$core[104]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[104]] = *emul8; goto &fetch; }
$core[002424] = 01135; $code[002424] = *I02424; sub I02424 { $lac += $core[000135]; goto &fetch; }
$core[002425] = 07440; $code[002425] = *I02425; sub I02425 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002426] = 03410; $code[002426] = *I02426; sub I02426 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[002427] = 01010; $code[002427] = *I02427; sub I02427 { $lac += $core[000010]; goto &fetch; }
$core[002430] = 07001; $code[002430] = *I02430; sub I02430 { $lac++; goto &fetch; }
$core[002431] = 03134; $code[002431] = *I02431; sub I02431 { $core[000134] = $lac & 07777; $lac &= 010000; $code[000134] = *emul8; goto &fetch; }
$core[002432] = 01134; $code[002432] = *I02432; sub I02432 { $lac += $core[000134]; goto &fetch; }
$core[002433] = 03155; $code[002433] = *I02433; sub I02433 { $core[000155] = $lac & 07777; $lac &= 010000; $code[000155] = *emul8; goto &fetch; }
$core[002434] = 05617; $code[002434] = *I02434; sub I02434 { $pc = ($ib<<12)+$core[1295]; $inh = 0; goto &fetch; }
$core[002435] = 00000; $code[002435] = *S02435; sub S02435 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002436] = 04504; $code[002436] = *I02436; sub I02436 { $core[($ib<<12)+$core[68]] = 02437; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[002437] = 00017; $code[002437] = *I02437; sub I02437 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[002440] = 01142; $code[002440] = *I02440; sub I02440 { $lac += $core[000142]; goto &fetch; }
$core[002441] = 04503; $code[002441] = *I02441; sub I02441 { $core[($ib<<12)+$core[67]] = 02442; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[002442] = 05635; $code[002442] = *I02442; sub I02442 { $pc = ($ib<<12)+$core[1309]; $inh = 0; goto &fetch; }
$core[002443] = 00000; $code[002443] = *S02443; sub S02443 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002444] = 01413; $code[002444] = *I02444; sub I02444 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[002445] = 03142; $code[002445] = *I02445; sub I02445 { $core[000142] = $lac & 07777; $lac &= 010000; $code[000142] = *emul8; goto &fetch; }
$core[002446] = 04505; $code[002446] = *I02446; sub I02446 { $core[($ib<<12)+$core[69]] = 02447; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[002447] = 00017; $code[002447] = *I02447; sub I02447 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[002450] = 05643; $code[002450] = *I02450; sub I02450 { $pc = ($ib<<12)+$core[1315]; $inh = 0; goto &fetch; }
$core[002451] = 00000; $code[002451] = *S02451; sub S02451 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002452] = 00024; $code[002452] = *I02452; sub I02452 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[002453] = 07041; $code[002453] = *I02453; sub I02453 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002454] = 03157; $code[002454] = *I02454; sub I02454 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[002455] = 01143; $code[002455] = *I02455; sub I02455 { $lac += $core[000143]; goto &fetch; }
$core[002456] = 00024; $code[002456] = *I02456; sub I02456 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[002457] = 01157; $code[002457] = *I02457; sub I02457 { $lac += $core[000157]; goto &fetch; }
$core[002460] = 07650; $code[002460] = *I02460; sub I02460 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002461] = 02251; $code[002461] = *I02461; sub I02461 { if (++$core[002451] == 010000) { $core[002451] = 0; $pc++; }$code[002451] = *emul8; goto &fetch; }
$core[002462] = 05651; $code[002462] = *I02462; sub I02462 { $pc = ($ib<<12)+$core[1321]; $inh = 0; goto &fetch; }
$core[002463] = 00000; $code[002463] = *S02463; sub S02463 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002464] = 04540; $code[002464] = *L02464; sub L02464 { $core[($ib<<12)+$core[96]] = 02465; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[002465] = 03142; $code[002465] = *I02465; sub I02465 { $core[000142] = $lac & 07777; $lac &= 010000; $code[000142] = *emul8; goto &fetch; }
$core[002466] = 04511; $code[002466] = *I02466; sub I02466 { $core[($ib<<12)+$core[73]] = 02467; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[002467] = 01611; $code[002467] = *I02467; sub I02467 { $lac += $core[($df<<12)+$core[1289]]; goto &fetch; }
$core[002470] = 05663; $code[002470] = *I02470; sub I02470 { $pc = ($ib<<12)+$core[1331]; $inh = 0; goto &fetch; }
$core[002471] = 04512; $code[002471] = *D02471; sub D02471 { $core[($ib<<12)+$core[74]] = 02472; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[002472] = 01142; $code[002472] = *D02472; sub D02472 { $lac += $core[000142]; goto &fetch; }
$core[002473] = 01024; $code[002473] = *I02473; sub I02473 { $lac += $core[000024]; goto &fetch; }
$core[002474] = 07640; $code[002474] = *I02474; sub I02474 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002475] = 05663; $code[002475] = *I02475; sub I02475 { $pc = ($ib<<12)+$core[1331]; $inh = 0; goto &fetch; }
$core[002476] = 05264; $code[002476] = *I02476; sub I02476 { $pc = 002464; $inh = 0; goto &fetch; }
$core[002477] = 00000; $code[002477] = *S02477; sub S02477 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002500] = 07450; $code[002500] = *I02500; sub I02500 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002501] = 01142; $code[002501] = *I02501; sub I02501 { $lac += $core[000142]; goto &fetch; }
$core[002502] = 01065; $code[002502] = *I02502; sub I02502 { $lac += $core[000065]; goto &fetch; }
$core[002503] = 07450; $code[002503] = *D02503; sub D02503 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002504] = 05310; $code[002504] = *I02504; sub I02504 { $pc = 002510; $inh = 0; goto &fetch; }
$core[002505] = 01060; $code[002505] = *D02505; sub D02505 { $lac += $core[000060]; goto &fetch; }
$core[002506] = 04537; $code[002506] = *L02506; sub L02506 { $core[($ib<<12)+$core[95]] = 02507; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[002507] = 05677; $code[002507] = *I02507; sub I02507 { $pc = ($ib<<12)+$core[1343]; $inh = 0; goto &fetch; }
$core[002510] = 01060; $code[002510] = *L02510; sub L02510 { $lac += $core[000060]; goto &fetch; }
$core[002511] = 04537; $code[002511] = *D02511; sub D02511 { $core[($ib<<12)+$core[95]] = 02512; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[002512] = 01057; $code[002512] = *I02512; sub I02512 { $lac += $core[000057]; goto &fetch; }
$core[002513] = 05306; $code[002513] = *D02513; sub D02513 { $pc = 002506; $inh = 0; goto &fetch; }
$core[002514] = 00000; $code[002514] = *S02514; sub S02514 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002515] = 04511; $code[002515] = *D02515; sub D02515 { $core[($ib<<12)+$core[73]] = 02516; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[002516] = 01141; $code[002516] = *D02516; sub D02516 { $lac += $core[000141]; goto &fetch; }
$core[002517] = 07410; $code[002517] = *D02517; sub D02517 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002520] = 05326; $code[002520] = *D02520; sub D02520 { $pc = 002526; $inh = 0; goto &fetch; }
$core[002521] = 01127; $code[002521] = *I02521; sub I02521 { $lac += $core[000127]; goto &fetch; }
$core[002522] = 02314; $code[002522] = *D02522; sub D02522 { if (++$core[002514] == 010000) { $core[002514] = 0; $pc++; }$code[002514] = *emul8; goto &fetch; }
$core[002523] = 07640; $code[002523] = *D02523; sub D02523 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002524] = 05714; $code[002524] = *D02524; sub D02524 { $pc = ($ib<<12)+$core[1356]; $inh = 0; goto &fetch; }
$core[002525] = 02314; $code[002525] = *I02525; sub I02525 { if (++$core[002514] == 010000) { $core[002514] = 0; $pc++; }$code[002514] = *emul8; goto &fetch; }
$core[002526] = 04506; $code[002526] = *L02526; sub L02526 { $core[($ib<<12)+$core[70]] = 02527; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[002527] = 05714; $code[002527] = *I02527; sub I02527 { $pc = ($ib<<12)+$core[1356]; $inh = 0; goto &fetch; }
$core[002600] = 00000; $code[002600] = *D02600; sub D02600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002601] = 00000; $code[002601] = *D02601; sub D02601 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002602] = 07575; $code[002602] = *D02602; sub D02602 { &emul8; goto &fetch; }
$core[002603] = 03200; $code[002603] = *L02603; sub L02603 { $core[002600] = $lac & 07777; $lac &= 010000; $code[002600] = *emul8; goto &fetch; }
$core[002604] = 07010; $code[002604] = *I02604; sub I02604 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002605] = 03201; $code[002605] = *I02605; sub I02605 { $core[002601] = $lac & 07777; $lac &= 010000; $code[002601] = *emul8; goto &fetch; }
$core[002606] = 06031; $code[002606] = *I02606; sub I02606 { &emul8; goto &fetch; }
$core[002607] = 05225; $code[002607] = *I02607; sub I02607 { $pc = 002625; $inh = 0; goto &fetch; }
$core[002610] = 06036; $code[002610] = *I02610; sub I02610 { &emul8; goto &fetch; }
$core[002611] = 00026; $code[002611] = *I02611; sub I02611 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[002612] = 01015; $code[002612] = *I02612; sub I02612 { $lac += $core[000015]; goto &fetch; }
$core[002613] = 03306; $code[002613] = *I02613; sub I02613 { $core[002706] = $lac & 07777; $lac &= 010000; $code[002706] = *emul8; goto &fetch; }
$core[002614] = 01306; $code[002614] = *I02614; sub I02614 { $lac += $core[002706]; goto &fetch; }
$core[002615] = 01202; $code[002615] = *I02615; sub I02615 { $lac += $core[002602]; goto &fetch; }
$core[002616] = 07650; $code[002616] = *I02616; sub I02616 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002617] = 05345; $code[002617] = *I02617; sub I02617 { $pc = 002745; $inh = 0; goto &fetch; }
$core[002620] = 01264; $code[002620] = *I02620; sub I02620 { $lac += $core[002664]; goto &fetch; }
$core[002621] = 07640; $code[002621] = *I02621; sub I02621 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002622] = 04526; $code[002622] = *I02622; sub I02622 { $core[($ib<<12)+$core[86]] = 02623; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[002623] = 01306; $code[002623] = *I02623; sub I02623 { $lac += $core[002706]; goto &fetch; }
$core[002624] = 03264; $code[002624] = *I02624; sub I02624 { $core[002664] = $lac & 07777; $lac &= 010000; $code[002664] = *emul8; goto &fetch; }
$core[002625] = 06041; $code[002625] = *L02625; sub L02625 { &emul8; goto &fetch; }
$core[002626] = 05244; $code[002626] = *I02626; sub I02626 { $pc = 002644; $inh = 0; goto &fetch; }
$core[002627] = 06042; $code[002627] = *D02627; sub D02627 { &emul8; goto &fetch; }
$core[002630] = 03260; $code[002630] = *I02630; sub I02630 { $core[002660] = $lac & 07777; $lac &= 010000; $code[002660] = *emul8; goto &fetch; }
$core[002631] = 01663; $code[002631] = *D02631; sub D02631 { $lac += $core[($df<<12)+$core[1459]]; goto &fetch; }
$core[002632] = 07450; $code[002632] = *I02632; sub I02632 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002633] = 05244; $code[002633] = *I02633; sub I02633 { $pc = 002644; $inh = 0; goto &fetch; }
$core[002634] = 06044; $code[002634] = *D02634; sub D02634 { &emul8; goto &fetch; }
$core[002635] = 03260; $code[002635] = *I02635; sub I02635 { $core[002660] = $lac & 07777; $lac &= 010000; $code[002660] = *emul8; goto &fetch; }
$core[002636] = 03663; $code[002636] = *I02636; sub I02636 { $core[($df<<12)+$core[1459]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1459]] = *emul8; goto &fetch; }
$core[002637] = 01263; $code[002637] = *I02637; sub I02637 { $lac += $core[002663]; goto &fetch; }
$core[002640] = 07001; $code[002640] = *I02640; sub I02640 { $lac++; goto &fetch; }
$core[002641] = 00031; $code[002641] = *I02641; sub I02641 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[002642] = 01261; $code[002642] = *I02642; sub I02642 { $lac += $core[002661]; goto &fetch; }
$core[002643] = 03263; $code[002643] = *I02643; sub I02643 { $core[002663] = $lac & 07777; $lac &= 010000; $code[002663] = *emul8; goto &fetch; }
$core[002644] = 06244; $code[002644] = *L02644; sub L02644 { &emul8; goto &fetch; }
$core[002645] = 06101; $code[002645] = *I02645; sub I02645 { &emul8; goto &fetch; }
$core[002646] = 07000; $code[002646] = *I02646; sub I02646 { goto &fetch; }
$core[002647] = 06011; $code[002647] = *I02647; sub I02647 { &emul8; goto &fetch; }
$core[002650] = 05253; $code[002650] = *I02650; sub I02650 { $pc = 002653; $inh = 0; goto &fetch; }
$core[002651] = 06012; $code[002651] = *I02651; sub I02651 { &emul8; goto &fetch; }
$core[002652] = 03037; $code[002652] = *I02652; sub I02652 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[002653] = 01201; $code[002653] = *L02653; sub L02653 { $lac += $core[002601]; goto &fetch; }
$core[002654] = 07104; $code[002654] = *I02654; sub I02654 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002655] = 01200; $code[002655] = *I02655; sub I02655 { $lac += $core[002600]; goto &fetch; }
$core[002656] = 06001; $code[002656] = *I02656; sub I02656 { &emul8; goto &fetch; }
$core[002657] = 05400; $code[002657] = *I02657; sub I02657 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[002660] = 00001; $code[002660] = *D02660; sub D02660 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[002661] = 03400; $code[002661] = *D02661; sub D02661 { $core[($df<<12)+$core[0]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[002662] = 03400; $code[002662] = *P02662; sub P02662 { $core[($df<<12)+$core[0]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[002663] = 03400; $code[002663] = *P02663; sub P02663 { $core[($df<<12)+$core[0]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[002664] = 00000; $code[002664] = *D02664; sub D02664 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002665] = 00000; $code[002665] = *S02665; sub S02665 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002666] = 01264; $code[002666] = *L02666; sub L02666 { $lac += $core[002664]; goto &fetch; }
$core[002667] = 07550; $code[002667] = *I02667; sub I02667 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002670] = 05266; $code[002670] = *I02670; sub I02670 { $pc = 002666; $inh = 0; goto &fetch; }
$core[002671] = 03275; $code[002671] = *I02671; sub I02671 { $core[002675] = $lac & 07777; $lac &= 010000; $code[002675] = *emul8; goto &fetch; }
$core[002672] = 03264; $code[002672] = *I02672; sub I02672 { $core[002664] = $lac & 07777; $lac &= 010000; $code[002664] = *emul8; goto &fetch; }
$core[002673] = 01275; $code[002673] = *I02673; sub I02673 { $lac += $core[002675]; goto &fetch; }
$core[002674] = 05665; $code[002674] = *I02674; sub I02674 { $pc = ($ib<<12)+$core[1461]; $inh = 0; goto &fetch; }
$core[002675] = 00000; $code[002675] = *S02675; sub S02675 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002676] = 03265; $code[002676] = *I02676; sub I02676 { $core[002665] = $lac & 07777; $lac &= 010000; $code[002665] = *emul8; goto &fetch; }
$core[002677] = 01265; $code[002677] = *I02677; sub I02677 { $lac += $core[002665]; goto &fetch; }
$core[002700] = 01065; $code[002700] = *I02700; sub I02700 { $lac += $core[000065]; goto &fetch; }
$core[002701] = 07650; $code[002701] = *I02701; sub I02701 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002702] = 03053; $code[002702] = *D02702; sub D02702 { $core[000053] = $lac & 07777; $lac &= 010000; $code[000053] = *emul8; goto &fetch; }
$core[002703] = 01265; $code[002703] = *I02703; sub I02703 { $lac += $core[002665]; goto &fetch; }
$core[002704] = 04732; $code[002704] = *I02704; sub I02704 { $core[($ib<<12)+$core[1498]] = 02705; $pc = ($ib<<12)+$core[1498]+1; $code[($ib<<12)+$core[1498]] = *emul8; $inh = 0; goto &fetch; }
$core[002705] = 02053; $code[002705] = *I02705; sub I02705 { if (++$core[000053] == 010000) { $core[000053] = 0; $pc++; }$code[000053] = *emul8; goto &fetch; }
$core[002706] = 00000; $code[002706] = *D02706; sub D02706 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002707] = 06001; $code[002707] = *I02707; sub I02707 { &emul8; goto &fetch; }
$core[002710] = 01662; $code[002710] = *L02710; sub L02710 { $lac += $core[($df<<12)+$core[1458]]; goto &fetch; }
$core[002711] = 07640; $code[002711] = *I02711; sub I02711 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002712] = 05310; $code[002712] = *I02712; sub I02712 { $pc = 002710; $inh = 0; goto &fetch; }
$core[002713] = 01260; $code[002713] = *I02713; sub I02713 { $lac += $core[002660]; goto &fetch; }
$core[002714] = 07640; $code[002714] = *I02714; sub I02714 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002715] = 05322; $code[002715] = *I02715; sub I02715 { $pc = 002722; $inh = 0; goto &fetch; }
$core[002716] = 01265; $code[002716] = *I02716; sub I02716 { $lac += $core[002665]; goto &fetch; }
$core[002717] = 06046; $code[002717] = *D02717; sub D02717 { &emul8; goto &fetch; }
$core[002720] = 03260; $code[002720] = *I02720; sub I02720 { $core[002660] = $lac & 07777; $lac &= 010000; $code[002660] = *emul8; goto &fetch; }
$core[002721] = 05675; $code[002721] = *I02721; sub I02721 { $pc = ($ib<<12)+$core[1469]; $inh = 0; goto &fetch; }
$core[002722] = 01265; $code[002722] = *L02722; sub L02722 { $lac += $core[002665]; goto &fetch; }
$core[002723] = 03662; $code[002723] = *I02723; sub I02723 { $core[($df<<12)+$core[1458]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1458]] = *emul8; goto &fetch; }
$core[002724] = 01262; $code[002724] = *I02724; sub I02724 { $lac += $core[002662]; goto &fetch; }
$core[002725] = 07001; $code[002725] = *I02725; sub I02725 { $lac++; goto &fetch; }
$core[002726] = 00031; $code[002726] = *I02726; sub I02726 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[002727] = 01261; $code[002727] = *I02727; sub I02727 { $lac += $core[002661]; goto &fetch; }
$core[002730] = 03262; $code[002730] = *I02730; sub I02730 { $core[002662] = $lac & 07777; $lac &= 010000; $code[002662] = *emul8; goto &fetch; }
$core[002731] = 05675; $code[002731] = *I02731; sub I02731 { $pc = ($ib<<12)+$core[1469]; $inh = 0; goto &fetch; }
$core[002732] = 03014; $code[002732] = *P02732; sub P02732 { $core[000014] = $lac & 07777; $lac &= 010000; $code[000014] = *emul8; goto &fetch; }
$core[002733] = 03225; $code[002733] = *P02733; sub P02733 { $core[002625] = $lac & 07777; $lac &= 010000; $code[002625] = *emul8; goto &fetch; }
$core[002734] = 03203; $code[002734] = *P02734; sub P02734 { $core[002603] = $lac & 07777; $lac &= 010000; $code[002603] = *emul8; goto &fetch; }
$core[002735] = 03336; $code[002735] = *I02735; sub I02735 { $core[002736] = $lac & 07777; $lac &= 010000; $code[002736] = *emul8; goto &fetch; }
$core[002736] = 00000; $code[002736] = *D02736; sub D02736 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002737] = 07240; $code[002737] = *I02737; sub I02737 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002740] = 01336; $code[002740] = *I02740; sub I02740 { $lac += $core[002736]; goto &fetch; }
$core[002741] = 03143; $code[002741] = *I02741; sub I02741 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[002742] = 04733; $code[002742] = *I02742; sub I02742 { $core[($ib<<12)+$core[1499]] = 02743; $pc = ($ib<<12)+$core[1499]+1; $code[($ib<<12)+$core[1499]] = *emul8; $inh = 0; goto &fetch; }
$core[002743] = 06002; $code[002743] = *I02743; sub I02743 { &emul8; goto &fetch; }
$core[002744] = 05347; $code[002744] = *I02744; sub I02744 { $pc = 002747; $inh = 0; goto &fetch; }
$core[002745] = 01015; $code[002745] = *L02745; sub L02745 { $lac += $core[000015]; goto &fetch; }
$core[002746] = 03143; $code[002746] = *I02746; sub I02746 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[002747] = 02260; $code[002747] = *L02747; sub L02747 { if (++$core[002660] == 010000) { $core[002660] = 0; $pc++; }$code[002660] = *emul8; goto &fetch; }
$core[002750] = 01025; $code[002750] = *I02750; sub I02750 { $lac += $core[000025]; goto &fetch; }
$core[002751] = 03132; $code[002751] = *I02751; sub I02751 { $core[000132] = $lac & 07777; $lac &= 010000; $code[000132] = *emul8; goto &fetch; }
$core[002752] = 07040; $code[002752] = *I02752; sub I02752 { $lac ^= 07777; goto &fetch; }
$core[002753] = 01261; $code[002753] = *I02753; sub I02753 { $lac += $core[002661]; goto &fetch; }
$core[002754] = 03011; $code[002754] = *I02754; sub I02754 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[002755] = 03411; $code[002755] = *L02755; sub L02755 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[002756] = 02132; $code[002756] = *I02756; sub I02756 { if (++$core[000132] == 010000) { $core[000132] = 0; $pc++; }$code[000132] = *emul8; goto &fetch; }
$core[002757] = 05355; $code[002757] = *I02757; sub I02757 { $pc = 002755; $inh = 0; goto &fetch; }
$core[002760] = 03264; $code[002760] = *I02760; sub I02760 { $core[002664] = $lac & 07777; $lac &= 010000; $code[002664] = *emul8; goto &fetch; }
$core[002761] = 01261; $code[002761] = *I02761; sub I02761 { $lac += $core[002661]; goto &fetch; }
$core[002762] = 03263; $code[002762] = *I02762; sub I02762 { $core[002663] = $lac & 07777; $lac &= 010000; $code[002663] = *emul8; goto &fetch; }
$core[002763] = 01261; $code[002763] = *I02763; sub I02763 { $lac += $core[002661]; goto &fetch; }
$core[002764] = 03262; $code[002764] = *I02764; sub I02764 { $core[002662] = $lac & 07777; $lac &= 010000; $code[002662] = *emul8; goto &fetch; }
$core[002765] = 04734; $code[002765] = *I02765; sub I02765 { $core[($ib<<12)+$core[1500]] = 02766; $pc = ($ib<<12)+$core[1500]+1; $code[($ib<<12)+$core[1500]] = *emul8; $inh = 0; goto &fetch; }
$core[002766] = 01161; $code[002766] = *I02766; sub I02766 { $lac += $core[000161]; goto &fetch; }
$core[002767] = 03113; $code[002767] = *I02767; sub I02767 { $core[000113] = $lac & 07777; $lac &= 010000; $code[000113] = *emul8; goto &fetch; }
$core[002770] = 07040; $code[002770] = *I02770; sub I02770 { $lac ^= 07777; goto &fetch; }
$core[002771] = 06046; $code[002771] = *I02771; sub I02771 { &emul8; goto &fetch; }
$core[002772] = 07200; $code[002772] = *I02772; sub I02772 { $lac &= 010000; goto &fetch; }
$core[002773] = 01060; $code[002773] = *I02773; sub I02773 { $lac += $core[000060]; goto &fetch; }
$core[002774] = 04512; $code[002774] = *I02774; sub I02774 { $core[($ib<<12)+$core[74]] = 02775; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[002775] = 01032; $code[002775] = *I02775; sub I02775 { $lac += $core[000032]; goto &fetch; }
$core[002776] = 04512; $code[002776] = *I02776; sub I02776 { $core[($ib<<12)+$core[74]] = 02777; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[002777] = 04514; $code[002777] = *I02777; sub I02777 { $core[($ib<<12)+$core[76]] = 03000; $pc = ($ib<<12)+$core[76]+1; $code[($ib<<12)+$core[76]] = *emul8; $inh = 0; goto &fetch; }
$core[003000] = 02145; $code[003000] = *I03000; sub I03000 { if (++$core[000145] == 010000) { $core[000145] = 0; $pc++; }$code[000145] = *emul8; goto &fetch; }
$core[003001] = 01545; $code[003001] = *I03001; sub I03001 { $lac += $core[($df<<12)+$core[101]]; goto &fetch; }
$core[003002] = 07450; $code[003002] = *I03002; sub I03002 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003003] = 05211; $code[003003] = *I03003; sub I03003 { $pc = 003011; $inh = 0; goto &fetch; }
$core[003004] = 03143; $code[003004] = *I03004; sub I03004 { $core[000143] = $lac & 07777; $lac &= 010000; $code[000143] = *emul8; goto &fetch; }
$core[003005] = 01062; $code[003005] = *I03005; sub I03005 { $lac += $core[000062]; goto &fetch; }
$core[003006] = 04512; $code[003006] = *I03006; sub I03006 { $core[($ib<<12)+$core[74]] = 03007; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[003007] = 04512; $code[003007] = *I03007; sub I03007 { $core[($ib<<12)+$core[74]] = 03010; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[003010] = 04514; $code[003010] = *I03010; sub I03010 { $core[($ib<<12)+$core[76]] = 03011; $pc = ($ib<<12)+$core[76]+1; $code[($ib<<12)+$core[76]] = *emul8; $inh = 0; goto &fetch; }
$core[003011] = 01060; $code[003011] = *L03011; sub L03011 { $lac += $core[000060]; goto &fetch; }
$core[003012] = 04512; $code[003012] = *D03012; sub D03012 { $core[($ib<<12)+$core[74]] = 03013; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[003013] = 05177; $code[003013] = *I03013; sub I03013 { $pc = 000177; $inh = 0; goto &fetch; }
$core[003014] = 00000; $code[003014] = *S03014; sub S03014 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003015] = 04520; $code[003015] = *I03015; sub I03015 { $core[($ib<<12)+$core[80]] = 03016; $pc = ($ib<<12)+$core[80]+1; $code[($ib<<12)+$core[80]] = *emul8; $inh = 0; goto &fetch; }
$core[003016] = 07710; $code[003016] = *I03016; sub I03016 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003017] = 07020; $code[003017] = *I03017; sub I03017 { $lac ^= 010000; goto &fetch; }
$core[003020] = 07420; $code[003020] = *I03020; sub I03020 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003021] = 02214; $code[003021] = *I03021; sub I03021 { if (++$core[003014] == 010000) { $core[003014] = 0; $pc++; }$code[003014] = *emul8; goto &fetch; }
$core[003022] = 05614; $code[003022] = *I03022; sub I03022 { $pc = ($ib<<12)+$core[1548]; $inh = 0; goto &fetch; }
$core[003023] = 00000; $code[003023] = *S03023; sub S03023 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003024] = 04510; $code[003024] = *I03024; sub I03024 { $core[($ib<<12)+$core[72]] = 03025; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[003025] = 03055; $code[003025] = *I03025; sub I03025 { $core[000055] = $lac & 07777; $lac &= 010000; $code[000055] = *emul8; goto &fetch; }
$core[003026] = 06126; $code[003026] = *I03026; sub I03026 { &emul8; goto &fetch; }
$core[003027] = 01142; $code[003027] = *I03027; sub I03027 { $lac += $core[000142]; goto &fetch; }
$core[003030] = 04214; $code[003030] = *I03030; sub I03030 { $core[003014] = 03031; $pc = 003014+1; $code[003014] = *emul8; $inh = 0; goto &fetch; }
$core[003031] = 05234; $code[003031] = *I03031; sub I03031 { $pc = 003034; $inh = 0; goto &fetch; }
$core[003032] = 01071; $code[003032] = *I03032; sub I03032 { $lac += $core[000071]; goto &fetch; }
$core[003033] = 04242; $code[003033] = *I03033; sub I03033 { $core[003042] = 03034; $pc = 003042+1; $code[003042] = *emul8; $inh = 0; goto &fetch; }
$core[003034] = 01142; $code[003034] = *L03034; sub L03034 { $lac += $core[000142]; goto &fetch; }
$core[003035] = 00071; $code[003035] = *L03035; sub L03035 { $lac &= (010000|$core[000071]); goto &fetch; }
$core[003036] = 04242; $code[003036] = *I03036; sub I03036 { $core[003042] = 03037; $pc = 003042+1; $code[003042] = *emul8; $inh = 0; goto &fetch; }
$core[003037] = 05623; $code[003037] = *I03037; sub I03037 { $pc = ($ib<<12)+$core[1555]; $inh = 0; goto &fetch; }
$core[003040] = 01054; $code[003040] = *I03040; sub I03040 { $lac += $core[000054]; goto &fetch; }
$core[003041] = 05235; $code[003041] = *D03041; sub D03041 { $pc = 003035; $inh = 0; goto &fetch; }
$core[003042] = 00000; $code[003042] = *S03042; sub S03042 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003043] = 02136; $code[003043] = *I03043; sub I03043 { if (++$core[000136] == 010000) { $core[000136] = 0; $pc++; }$code[000136] = *emul8; goto &fetch; }
$core[003044] = 05260; $code[003044] = *I03044; sub I03044 { $pc = 003060; $inh = 0; goto &fetch; }
$core[003045] = 01135; $code[003045] = *I03045; sub I03045 { $lac += $core[000135]; goto &fetch; }
$core[003046] = 03410; $code[003046] = *I03046; sub I03046 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[003047] = 01013; $code[003047] = *I03047; sub I03047 { $lac += $core[000013]; goto &fetch; }
$core[003050] = 07141; $code[003050] = *I03050; sub I03050 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[003051] = 01005; $code[003051] = *I03051; sub I03051 { $lac += $core[000005]; goto &fetch; }
$core[003052] = 01010; $code[003052] = *D03052; sub D03052 { $lac += $core[000010]; goto &fetch; }
$core[003053] = 07630; $code[003053] = *I03053; sub I03053 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003054] = 04526; $code[003054] = *I03054; sub I03054 { $core[($ib<<12)+$core[86]] = 03055; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[003055] = 05642; $code[003055] = *I03055; sub I03055 { $pc = ($ib<<12)+$core[1570]; $inh = 0; goto &fetch; }
$core[003056] = 00277; $code[003056] = *I03056; sub I03056 { $lac &= (010000|$core[003077]); goto &fetch; }
$core[003057] = 00377; $code[003057] = *I03057; sub I03057 { $lac &= (010000|$core[003177]); goto &fetch; }
$core[003060] = 04520; $code[003060] = *L03060; sub L03060 { $core[($ib<<12)+$core[80]] = 03061; $pc = ($ib<<12)+$core[80]+1; $code[($ib<<12)+$core[80]] = *emul8; $inh = 0; goto &fetch; }
$core[003061] = 03135; $code[003061] = *I03061; sub I03061 { $core[000135] = $lac & 07777; $lac &= 010000; $code[000135] = *emul8; goto &fetch; }
$core[003062] = 07040; $code[003062] = *I03062; sub I03062 { $lac ^= 07777; goto &fetch; }
$core[003063] = 03136; $code[003063] = *I03063; sub I03063 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003064] = 05642; $code[003064] = *I03064; sub I03064 { $pc = ($ib<<12)+$core[1570]; $inh = 0; goto &fetch; }
$core[003065] = 01010; $code[003065] = *I03065; sub I03065 { $lac += $core[000010]; goto &fetch; }
$core[003066] = 03242; $code[003066] = *I03066; sub I03066 { $core[003042] = $lac & 07777; $lac &= 010000; $code[003042] = *emul8; goto &fetch; }
$core[003067] = 01136; $code[003067] = *I03067; sub I03067 { $lac += $core[000136]; goto &fetch; }
$core[003070] = 07640; $code[003070] = *I03070; sub I03070 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003071] = 05277; $code[003071] = *I03071; sub I03071 { $pc = 003077; $inh = 0; goto &fetch; }
$core[003072] = 01010; $code[003072] = *I03072; sub I03072 { $lac += $core[000010]; goto &fetch; }
$core[003073] = 07041; $code[003073] = *I03073; sub I03073 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003074] = 01153; $code[003074] = *I03074; sub I03074 { $lac += $core[000153]; goto &fetch; }
$core[003075] = 07700; $code[003075] = *I03075; sub I03075 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003076] = 05322; $code[003076] = *I03076; sub I03076 { $pc = 003122; $inh = 0; goto &fetch; }
$core[003077] = 01324; $code[003077] = *L03077; sub L03077 { $lac += $core[003124]; goto &fetch; }
$core[003100] = 04512; $code[003100] = *I03100; sub I03100 { $core[($ib<<12)+$core[74]] = 03101; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[003101] = 02136; $code[003101] = *I03101; sub I03101 { if (++$core[000136] == 010000) { $core[000136] = 0; $pc++; }$code[000136] = *emul8; goto &fetch; }
$core[003102] = 05310; $code[003102] = *I03102; sub I03102 { $pc = 003110; $inh = 0; goto &fetch; }
$core[003103] = 01642; $code[003103] = *I03103; sub I03103 { $lac += $core[($df<<12)+$core[1570]]; goto &fetch; }
$core[003104] = 00071; $code[003104] = *I03104; sub I03104 { $lac &= (010000|$core[000071]); goto &fetch; }
$core[003105] = 01023; $code[003105] = *I03105; sub I03105 { $lac += $core[000023]; goto &fetch; }
$core[003106] = 07640; $code[003106] = *I03106; sub I03106 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003107] = 05322; $code[003107] = *I03107; sub I03107 { $pc = 003122; $inh = 0; goto &fetch; }
$core[003110] = 01642; $code[003110] = *L03110; sub L03110 { $lac += $core[($df<<12)+$core[1570]]; goto &fetch; }
$core[003111] = 00062; $code[003111] = *I03111; sub I03111 { $lac &= (010000|$core[000062]); goto &fetch; }
$core[003112] = 03135; $code[003112] = *I03112; sub I03112 { $core[000135] = $lac & 07777; $lac &= 010000; $code[000135] = *emul8; goto &fetch; }
$core[003113] = 07040; $code[003113] = *I03113; sub I03113 { $lac ^= 07777; goto &fetch; }
$core[003114] = 01010; $code[003114] = *I03114; sub I03114 { $lac += $core[000010]; goto &fetch; }
$core[003115] = 03010; $code[003115] = *I03115; sub I03115 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[003116] = 01135; $code[003116] = *I03116; sub I03116 { $lac += $core[000135]; goto &fetch; }
$core[003117] = 01006; $code[003117] = *I03117; sub I03117 { $lac += $core[000006]; goto &fetch; }
$core[003120] = 07640; $code[003120] = *I03120; sub I03120 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003121] = 07040; $code[003121] = *I03121; sub I03121 { $lac ^= 07777; goto &fetch; }
$core[003122] = 03136; $code[003122] = *L03122; sub L03122 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003123] = 05623; $code[003123] = *I03123; sub I03123 { $pc = ($ib<<12)+$core[1555]; $inh = 0; goto &fetch; }
$core[003124] = 00334; $code[003124] = *D03124; sub D03124 { $lac &= (010000|$core[003134]); goto &fetch; }
$core[003125] = 04504; $code[003125] = *I03125; sub I03125 { $core[($ib<<12)+$core[68]] = 03126; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[003126] = 00017; $code[003126] = *I03126; sub I03126 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003127] = 07040; $code[003127] = *I03127; sub I03127 { $lac ^= 07777; goto &fetch; }
$core[003130] = 01134; $code[003130] = *I03130; sub I03130 { $lac += $core[000134]; goto &fetch; }
$core[003131] = 03014; $code[003131] = *L03131; sub L03131 { $core[000014] = $lac & 07777; $lac &= 010000; $code[000014] = *emul8; goto &fetch; }
$core[003132] = 01014; $code[003132] = *I03132; sub I03132 { $lac += $core[000014]; goto &fetch; }
$core[003133] = 07040; $code[003133] = *I03133; sub I03133 { $lac ^= 07777; goto &fetch; }
$core[003134] = 01155; $code[003134] = *D03134; sub D03134 { $lac += $core[000155]; goto &fetch; }
$core[003135] = 07650; $code[003135] = *I03135; sub I03135 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003136] = 05370; $code[003136] = *I03136; sub I03136 { $pc = 003170; $inh = 0; goto &fetch; }
$core[003137] = 01375; $code[003137] = *I03137; sub I03137 { $lac += $core[003175]; goto &fetch; }
$core[003140] = 03017; $code[003140] = *I03140; sub I03140 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[003141] = 03020; $code[003141] = *I03141; sub I03141 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[003142] = 01414; $code[003142] = *I03142; sub I03142 { $core[000014] = 0000 if ++$core[000014] == 010000; $lac += $core[($df<<12)+$core[000014]]; goto &fetch; }
$core[003143] = 03376; $code[003143] = *I03143; sub I03143 { $core[003176] = $lac & 07777; $lac &= 010000; $code[003176] = *emul8; goto &fetch; }
$core[003144] = 04501; $code[003144] = *I03144; sub I03144 { $core[($ib<<12)+$core[65]] = 03145; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[003145] = 01241; $code[003145] = *I03145; sub I03145 { $lac += $core[003041]; goto &fetch; }
$core[003146] = 01414; $code[003146] = *I03146; sub I03146 { $core[000014] = 0000 if ++$core[000014] == 010000; $lac += $core[($df<<12)+$core[000014]]; goto &fetch; }
$core[003147] = 04774; $code[003147] = *I03147; sub I03147 { $core[($ib<<12)+$core[1660]] = 03150; $pc = ($ib<<12)+$core[1660]+1; $code[($ib<<12)+$core[1660]] = *emul8; $inh = 0; goto &fetch; }
$core[003150] = 04501; $code[003150] = *I03150; sub I03150 { $core[($ib<<12)+$core[65]] = 03151; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[003151] = 01241; $code[003151] = *I03151; sub I03151 { $lac += $core[003041]; goto &fetch; }
$core[003152] = 01005; $code[003152] = *I03152; sub I03152 { $lac += $core[000005]; goto &fetch; }
$core[003153] = 03046; $code[003153] = *D03153; sub D03153 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[003154] = 04501; $code[003154] = *I03154; sub I03154 { $core[($ib<<12)+$core[65]] = 03155; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[003155] = 01374; $code[003155] = *D03155; sub D03155 { $lac += $core[003174]; goto &fetch; }
$core[003156] = 02014; $code[003156] = *I03156; sub I03156 { if (++$core[000014] == 010000) { $core[000014] = 0; $pc++; }$code[000014] = *emul8; goto &fetch; }
$core[003157] = 04407; $code[003157] = *I03157; sub I03157 { $core[($ib<<12)+$core[7]] = 03160; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[003160] = 05414; $code[003160] = *I03160; sub I03160 { &emul8; goto &fetch; }
$core[003161] = 00000; $code[003161] = *I03161; sub I03161 { &emul8; goto &fetch; }
$core[003162] = 04472; $code[003162] = *I03162; sub I03162 { $core[($ib<<12)+$core[58]] = 03163; $pc = ($ib<<12)+$core[58]+1; $code[($ib<<12)+$core[58]] = *emul8; $inh = 0; goto &fetch; }
$core[003163] = 01060; $code[003163] = *I03163; sub I03163 { $lac += $core[000060]; goto &fetch; }
$core[003164] = 04512; $code[003164] = *L03164; sub L03164 { $core[($ib<<12)+$core[74]] = 03165; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[003165] = 01014; $code[003165] = *I03165; sub I03165 { $lac += $core[000014]; goto &fetch; }
$core[003166] = 01035; $code[003166] = *I03166; sub I03166 { $lac += $core[000035]; goto &fetch; }
$core[003167] = 05331; $code[003167] = *I03167; sub I03167 { $pc = 003131; $inh = 0; goto &fetch; }
$core[003170] = 04505; $code[003170] = *L03170; sub L03170 { $core[($ib<<12)+$core[69]] = 03171; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[003171] = 00017; $code[003171] = *I03171; sub I03171 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[003172] = 05773; $code[003172] = *I03172; sub I03172 { $pc = ($ib<<12)+$core[1659]; $inh = 0; goto &fetch; }
$core[003173] = 01252; $code[003173] = *P03173; sub P03173 { $lac += $core[003052]; goto &fetch; }
$core[003174] = 06100; $code[003174] = *P03174; sub P03174 { &emul8; goto &fetch; }
$core[003175] = 03175; $code[003175] = *D03175; sub D03175 { $core[000175] = $lac & 07777; $lac &= 010000; $code[000175] = *emul8; goto &fetch; }
$core[003176] = 00000; $code[003176] = *D03176; sub D03176 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003177] = 05077; $code[003177] = *D03177; sub D03177 { $pc = 000077; $inh = 0; goto &fetch; }
$core[003200] = 01551; $code[003200] = *P03200; sub P03200 { $lac += $core[($df<<12)+$core[105]]; goto &fetch; }
$core[003201] = 07577; $code[003201] = *P03201; sub P03201 { &emul8; goto &fetch; }
$core[003202] = 01500; $code[003202] = *I03202; sub I03202 { $lac += $core[($df<<12)+$core[64]]; goto &fetch; }
$core[003203] = 00000; $code[003203] = *S03203; sub S03203 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003204] = 01220; $code[003204] = *I03204; sub I03204 { $lac += $core[003220]; goto &fetch; }
$core[003205] = 03621; $code[003205] = *I03205; sub I03205 { $core[($df<<12)+$core[1681]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1681]] = *emul8; goto &fetch; }
$core[003206] = 01621; $code[003206] = *I03206; sub I03206 { $lac += $core[($df<<12)+$core[1681]]; goto &fetch; }
$core[003207] = 07001; $code[003207] = *I03207; sub I03207 { $lac++; goto &fetch; }
$core[003210] = 03622; $code[003210] = *I03210; sub I03210 { $core[($df<<12)+$core[1682]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1682]] = *emul8; goto &fetch; }
$core[003211] = 01622; $code[003211] = *I03211; sub I03211 { $lac += $core[($df<<12)+$core[1682]]; goto &fetch; }
$core[003212] = 01035; $code[003212] = *I03212; sub I03212 { $lac += $core[000035]; goto &fetch; }
$core[003213] = 03623; $code[003213] = *I03213; sub I03213 { $core[($df<<12)+$core[1683]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1683]] = *emul8; goto &fetch; }
$core[003214] = 01623; $code[003214] = *I03214; sub I03214 { $lac += $core[($df<<12)+$core[1683]]; goto &fetch; }
$core[003215] = 01035; $code[003215] = *I03215; sub I03215 { $lac += $core[000035]; goto &fetch; }
$core[003216] = 03624; $code[003216] = *I03216; sub I03216 { $core[($df<<12)+$core[1684]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1684]] = *emul8; goto &fetch; }
$core[003217] = 05603; $code[003217] = *I03217; sub I03217 { $pc = ($ib<<12)+$core[1667]; $inh = 0; goto &fetch; }
$core[003220] = 06041; $code[003220] = *D03220; sub D03220 { &emul8; goto &fetch; }
$core[003221] = 02625; $code[003221] = *P03221; sub P03221 { if (++$core[($df<<12)+$core[1685]] == 010000) { $core[($df<<12)+$core[1685]] = 0; $pc++; }$code[($df<<12)+$core[1685]] = *emul8; goto &fetch; }
$core[003222] = 02627; $code[003222] = *P03222; sub P03222 { if (++$core[($df<<12)+$core[1687]] == 010000) { $core[($df<<12)+$core[1687]] = 0; $pc++; }$code[($df<<12)+$core[1687]] = *emul8; goto &fetch; }
$core[003223] = 02634; $code[003223] = *P03223; sub P03223 { if (++$core[($df<<12)+$core[1692]] == 010000) { $core[($df<<12)+$core[1692]] = 0; $pc++; }$code[($df<<12)+$core[1692]] = *emul8; goto &fetch; }
$core[003224] = 02717; $code[003224] = *P03224; sub P03224 { if (++$core[($df<<12)+$core[1743]] == 010000) { $core[($df<<12)+$core[1743]] = 0; $pc++; }$code[($df<<12)+$core[1743]] = *emul8; goto &fetch; }
$core[003225] = 00000; $code[003225] = *S03225; sub S03225 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003226] = 06001; $code[003226] = *L03226; sub L03226 { &emul8; goto &fetch; }
$core[003227] = 01633; $code[003227] = *P03227; sub P03227 { $lac += $core[($df<<12)+$core[1691]]; goto &fetch; }
$core[003230] = 07640; $code[003230] = *I03230; sub I03230 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003231] = 05226; $code[003231] = *I03231; sub I03231 { $pc = 003226; $inh = 0; goto &fetch; }
$core[003232] = 05625; $code[003232] = *I03232; sub I03232 { $pc = ($ib<<12)+$core[1685]; $inh = 0; goto &fetch; }
$core[003233] = 02660; $code[003233] = *P03233; sub P03233 { if (++$core[($df<<12)+$core[1712]] == 010000) { $core[($df<<12)+$core[1712]] = 0; $pc++; }$code[($df<<12)+$core[1712]] = *emul8; goto &fetch; }
$core[003234] = 04225; $code[003234] = *P03234; sub P03234 { $core[003225] = 03235; $pc = 003225+1; $code[003225] = *emul8; $inh = 0; goto &fetch; }
$core[003235] = 01025; $code[003235] = *I03235; sub I03235 { $lac += $core[000025]; goto &fetch; }
$core[003236] = 07410; $code[003236] = *I03236; sub I03236 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003237] = 04225; $code[003237] = *I03237; sub I03237 { $core[003225] = 03240; $pc = 003225+1; $code[003225] = *emul8; $inh = 0; goto &fetch; }
$core[003240] = 04203; $code[003240] = *I03240; sub I03240 { $core[003203] = 03241; $pc = 003203+1; $code[003203] = *emul8; $inh = 0; goto &fetch; }
$core[003241] = 05642; $code[003241] = *L03241; sub L03241 { $pc = ($ib<<12)+$core[1698]; $inh = 0; goto &fetch; }
$core[003242] = 06461; $code[003242] = *P03242; sub P03242 { &emul8; goto &fetch; }
$core[003243] = 01250; $code[003243] = *I03243; sub I03243 { $lac += $core[003250]; goto &fetch; }
$core[003244] = 01247; $code[003244] = *I03244; sub I03244 { $lac += $core[003247]; goto &fetch; }
$core[003245] = 03651; $code[003245] = *I03245; sub I03245 { $core[($df<<12)+$core[1705]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1705]] = *emul8; goto &fetch; }
$core[003246] = 05241; $code[003246] = *I03246; sub I03246 { $pc = 003241; $inh = 0; goto &fetch; }
$core[003247] = 04512; $code[003247] = *D03247; sub D03247 { $core[($ib<<12)+$core[74]] = 03250; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[003250] = 02466; $code[003250] = *D03250; sub D03250 { if (++$core[($df<<12)+$core[54]] == 010000) { $core[($df<<12)+$core[54]] = 0; $pc++; }$code[($df<<12)+$core[54]] = *emul8; goto &fetch; }
$core[003251] = 01222; $code[003251] = *P03251; sub P03251 { $lac += $core[003222]; goto &fetch; }
$core[003252] = 01247; $code[003252] = *I03252; sub I03252 { $lac += $core[003247]; goto &fetch; }
$core[003253] = 03655; $code[003253] = *I03253; sub I03253 { $core[($df<<12)+$core[1709]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1709]] = *emul8; goto &fetch; }
$core[003254] = 05241; $code[003254] = *I03254; sub I03254 { $pc = 003241; $inh = 0; goto &fetch; }
$core[003255] = 02471; $code[003255] = *P03255; sub P03255 { if (++$core[($df<<12)+$core[57]] == 010000) { $core[($df<<12)+$core[57]] = 0; $pc++; }$code[($df<<12)+$core[57]] = *emul8; goto &fetch; }
$core[003256] = 04506; $code[003256] = *L03256; sub L03256 { $core[($ib<<12)+$core[70]] = 03257; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[003257] = 04511; $code[003257] = *I03257; sub I03257 { $core[($ib<<12)+$core[73]] = 03260; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[003260] = 02003; $code[003260] = *P03260; sub P03260 { if (++$core[000003] == 010000) { $core[000003] = 0; $pc++; }$code[000003] = *emul8; goto &fetch; }
$core[003261] = 07410; $code[003261] = *I03261; sub I03261 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003262] = 05256; $code[003262] = *I03262; sub I03262 { $pc = 003256; $inh = 0; goto &fetch; }
$core[003263] = 04501; $code[003263] = *I03263; sub I03263 { $core[($ib<<12)+$core[65]] = 03264; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[003264] = 01601; $code[003264] = *I03264; sub I03264 { $lac += $core[($df<<12)+$core[1665]]; goto &fetch; }
$core[003265] = 04452; $code[003265] = *I03265; sub I03265 { $core[($ib<<12)+$core[42]] = 03266; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[003266] = 03670; $code[003266] = *I03266; sub I03266 { $core[($df<<12)+$core[1720]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1720]] = *emul8; goto &fetch; }
$core[003267] = 05241; $code[003267] = *I03267; sub I03267 { $pc = 003241; $inh = 0; goto &fetch; }
$core[003270] = 06002; $code[003270] = *P03270; sub P03270 { &emul8; goto &fetch; }
$core[003271] = 04225; $code[003271] = *I03271; sub I03271 { $core[003225] = 03272; $pc = 003225+1; $code[003225] = *emul8; $inh = 0; goto &fetch; }
$core[003272] = 06002; $code[003272] = *I03272; sub I03272 { &emul8; goto &fetch; }
$core[003273] = 05424; $code[003273] = *I03273; sub I03273 { $pc = ($ib<<12)+$core[20]; $inh = 0; goto &fetch; }
$core[003274] = 01301; $code[003274] = *I03274; sub I03274 { $lac += $core[003301]; goto &fetch; }
$core[003275] = 03017; $code[003275] = *I03275; sub I03275 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[003276] = 03020; $code[003276] = *I03276; sub I03276 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[003277] = 04501; $code[003277] = *I03277; sub I03277 { $core[($ib<<12)+$core[65]] = 03300; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[003300] = 01260; $code[003300] = *I03300; sub I03300 { $lac += $core[003260]; goto &fetch; }
$core[003301] = 02036; $code[003301] = *D03301; sub D03301 { if (++$core[000036] == 010000) { $core[000036] = 0; $pc++; }$code[000036] = *emul8; goto &fetch; }
$core[003302] = 07240; $code[003302] = *I03302; sub I03302 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003303] = 03305; $code[003303] = *I03303; sub I03303 { $core[003305] = $lac & 07777; $lac &= 010000; $code[003305] = *emul8; goto &fetch; }
$core[003304] = 05241; $code[003304] = *I03304; sub I03304 { $pc = 003241; $inh = 0; goto &fetch; }
$core[003305] = 00000; $code[003305] = *D03305; sub D03305 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003306] = 00000; $code[003306] = *S03306; sub S03306 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003307] = 01154; $code[003307] = *I03307; sub I03307 { $lac += $core[000154]; goto &fetch; }
$core[003310] = 03225; $code[003310] = *I03310; sub I03310 { $core[003225] = $lac & 07777; $lac &= 010000; $code[003225] = *emul8; goto &fetch; }
$core[003311] = 01305; $code[003311] = *I03311; sub I03311 { $lac += $core[003305]; goto &fetch; }
$core[003312] = 07650; $code[003312] = *I03312; sub I03312 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003313] = 05323; $code[003313] = *I03313; sub I03313 { $pc = 003323; $inh = 0; goto &fetch; }
$core[003314] = 04513; $code[003314] = *I03314; sub I03314 { $core[($ib<<12)+$core[75]] = 03315; $pc = ($ib<<12)+$core[75]+1; $code[($ib<<12)+$core[75]] = *emul8; $inh = 0; goto &fetch; }
$core[003315] = 01142; $code[003315] = *I03315; sub I03315 { $lac += $core[000142]; goto &fetch; }
$core[003316] = 04430; $code[003316] = *I03316; sub I03316 { $core[($ib<<12)+$core[24]] = 03317; $pc = ($ib<<12)+$core[24]+1; $code[($ib<<12)+$core[24]] = *emul8; $inh = 0; goto &fetch; }
$core[003317] = 04407; $code[003317] = *P03317; sub P03317 { $core[($ib<<12)+$core[7]] = 03320; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[003320] = 06625; $code[003320] = *I03320; sub I03320 { &emul8; goto &fetch; }
$core[003321] = 00000; $code[003321] = *I03321; sub I03321 { &emul8; goto &fetch; }
$core[003322] = 05706; $code[003322] = *I03322; sub I03322 { $pc = ($ib<<12)+$core[1734]; $inh = 0; goto &fetch; }
$core[003323] = 01013; $code[003323] = *L03323; sub L03323 { $lac += $core[000013]; goto &fetch; }
$core[003324] = 03203; $code[003324] = *I03324; sub I03324 { $core[003203] = $lac & 07777; $lac &= 010000; $code[003203] = *emul8; goto &fetch; }
$core[003325] = 01364; $code[003325] = *I03325; sub I03325 { $lac += $core[003364]; goto &fetch; }
$core[003326] = 03013; $code[003326] = *I03326; sub I03326 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[003327] = 02151; $code[003327] = *I03327; sub I03327 { if (++$core[000151] == 010000) { $core[000151] = 0; $pc++; }$code[000151] = *emul8; goto &fetch; }
$core[003330] = 01363; $code[003330] = *I03330; sub I03330 { $lac += $core[003363]; goto &fetch; }
$core[003331] = 03010; $code[003331] = *I03331; sub I03331 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[003332] = 03136; $code[003332] = *I03332; sub I03332 { $core[000136] = $lac & 07777; $lac &= 010000; $code[000136] = *emul8; goto &fetch; }
$core[003333] = 01363; $code[003333] = *I03333; sub I03333 { $lac += $core[003363]; goto &fetch; }
$core[003334] = 03153; $code[003334] = *I03334; sub I03334 { $core[000153] = $lac & 07777; $lac &= 010000; $code[000153] = *emul8; goto &fetch; }
$core[003335] = 04513; $code[003335] = *L03335; sub L03335 { $core[($ib<<12)+$core[75]] = 03336; $pc = ($ib<<12)+$core[75]+1; $code[($ib<<12)+$core[75]] = *emul8; $inh = 0; goto &fetch; }
$core[003336] = 04511; $code[003336] = *I03336; sub I03336 { $core[($ib<<12)+$core[73]] = 03337; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[003337] = 00032; $code[003337] = *I03337; sub I03337 { $lac &= (010000|$core[000032]); goto &fetch; }
$core[003340] = 05335; $code[003340] = *I03340; sub I03340 { $pc = 003335; $inh = 0; goto &fetch; }
$core[003341] = 04510; $code[003341] = *L03341; sub L03341 { $core[($ib<<12)+$core[72]] = 03342; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[003342] = 05775; $code[003342] = *I03342; sub I03342 { $pc = ($ib<<12)+$core[1789]; $inh = 0; goto &fetch; }
$core[003343] = 00774; $code[003343] = *I03343; sub I03343 { $lac &= (010000|$core[($df<<12)+$core[1788]]); goto &fetch; }
$core[003344] = 04507; $code[003344] = *I03344; sub I03344 { $core[($ib<<12)+$core[71]] = 03345; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[003345] = 04513; $code[003345] = *I03345; sub I03345 { $core[($ib<<12)+$core[75]] = 03346; $pc = ($ib<<12)+$core[75]+1; $code[($ib<<12)+$core[75]] = *emul8; $inh = 0; goto &fetch; }
$core[003346] = 05341; $code[003346] = *I03346; sub I03346 { $pc = 003341; $inh = 0; goto &fetch; }
$core[003347] = 01060; $code[003347] = *I03347; sub I03347 { $lac += $core[000060]; goto &fetch; }
$core[003350] = 03142; $code[003350] = *I03350; sub I03350 { $core[000142] = $lac & 07777; $lac &= 010000; $code[000142] = *emul8; goto &fetch; }
$core[003351] = 04507; $code[003351] = *I03351; sub I03351 { $core[($ib<<12)+$core[71]] = 03352; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[003352] = 04507; $code[003352] = *I03352; sub I03352 { $core[($ib<<12)+$core[71]] = 03353; $pc = ($ib<<12)+$core[71]+1; $code[($ib<<12)+$core[71]] = *emul8; $inh = 0; goto &fetch; }
$core[003353] = 01203; $code[003353] = *I03353; sub I03353 { $lac += $core[003203]; goto &fetch; }
$core[003354] = 03013; $code[003354] = *I03354; sub I03354 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[003355] = 01363; $code[003355] = *I03355; sub I03355 { $lac += $core[003363]; goto &fetch; }
$core[003356] = 03017; $code[003356] = *I03356; sub I03356 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[003357] = 03020; $code[003357] = *I03357; sub I03357 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[003360] = 04501; $code[003360] = *I03360; sub I03360 { $core[($ib<<12)+$core[65]] = 03361; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[003361] = 01600; $code[003361] = *I03361; sub I03361 { $lac += $core[($df<<12)+$core[1664]]; goto &fetch; }
$core[003362] = 05317; $code[003362] = *I03362; sub I03362 { $pc = 003317; $inh = 0; goto &fetch; }
$core[003363] = 07550; $code[003363] = *D03363; sub D03363 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003364] = 07612; $code[003364] = *D03364; sub D03364 { $skp = 0; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[003365] = 00000; $code[003365] = *S03365; sub S03365 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003366] = 01305; $code[003366] = *I03366; sub I03366 { $lac += $core[003305]; goto &fetch; }
$core[003367] = 07640; $code[003367] = *I03367; sub I03367 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003370] = 05373; $code[003370] = *I03370; sub I03370 { $pc = 003373; $inh = 0; goto &fetch; }
$core[003371] = 04472; $code[003371] = *I03371; sub I03371 { $core[($ib<<12)+$core[58]] = 03372; $pc = ($ib<<12)+$core[58]+1; $code[($ib<<12)+$core[58]] = *emul8; $inh = 0; goto &fetch; }
$core[003372] = 05765; $code[003372] = *I03372; sub I03372 { $pc = ($ib<<12)+$core[1781]; $inh = 0; goto &fetch; }
$core[003373] = 04452; $code[003373] = *L03373; sub L03373 { $core[($ib<<12)+$core[42]] = 03374; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[003374] = 07450; $code[003374] = *P03374; sub P03374 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003375] = 07130; $code[003375] = *P03375; sub P03375 { $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003376] = 04537; $code[003376] = *I03376; sub I03376 { $core[($ib<<12)+$core[95]] = 03377; $pc = ($ib<<12)+$core[95]+1; $code[($ib<<12)+$core[95]] = *emul8; $inh = 0; goto &fetch; }
$core[003377] = 05765; $code[003377] = *D03377; sub D03377 { $pc = ($ib<<12)+$core[1781]; $inh = 0; goto &fetch; }
$core[003420] = 00000; $code[003420] = *D03420; sub D03420 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003421] = 00000; $code[003421] = *I03421; sub I03421 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003422] = 00355; $code[003422] = *I03422; sub I03422 { $lac &= (010000|$core[003555]); goto &fetch; }
$core[003423] = 00617; $code[003423] = *I03423; sub I03423 { $lac &= (010000|$core[($df<<12)+$core[1807]]); goto &fetch; }
$core[003424] = 00301; $code[003424] = *I03424; sub I03424 { $lac &= (010000|$core[003501]); goto &fetch; }
$core[003425] = 01454; $code[003425] = *I03425; sub I03425 { $lac += $core[($df<<12)+$core[44]]; goto &fetch; }
$core[003426] = 04040; $code[003426] = *I03426; sub I03426 { $core[000040] = 03427; $pc = 000040+1; $code[000040] = *emul8; $inh = 0; goto &fetch; }
$core[003427] = 06557; $code[003427] = *I03427; sub I03427 { &emul8; goto &fetch; }
$core[003430] = 06671; $code[003430] = *D03430; sub D03430 { &emul8; goto &fetch; }
$core[003431] = 07715; $code[003431] = *I03431; sub I03431 { &emul8; goto &fetch; }
$core[003432] = 07300; $code[003432] = *L03432; sub L03432 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003433] = 01377; $code[003433] = *I03433; sub I03433 { $lac += $core[003577]; goto &fetch; }
$core[003434] = 03176; $code[003434] = *I03434; sub I03434 { $core[000176] = $lac & 07777; $lac &= 010000; $code[000176] = *emul8; goto &fetch; }
$core[003435] = 06002; $code[003435] = *I03435; sub I03435 { &emul8; goto &fetch; }
$core[003436] = 06022; $code[003436] = *I03436; sub I03436 { &emul8; goto &fetch; }
$core[003437] = 06032; $code[003437] = *I03437; sub I03437 { &emul8; goto &fetch; }
$core[003440] = 06203; $code[003440] = *I03440; sub I03440 { &emul8; goto &fetch; }
$core[003441] = 06402; $code[003441] = *P03441; sub P03441 { &emul8; goto &fetch; }
$core[003442] = 06412; $code[003442] = *I03442; sub I03442 { &emul8; goto &fetch; }
$core[003443] = 06422; $code[003443] = *I03443; sub I03443 { &emul8; goto &fetch; }
$core[003444] = 06432; $code[003444] = *I03444; sub I03444 { &emul8; goto &fetch; }
$core[003445] = 06442; $code[003445] = *I03445; sub I03445 { &emul8; goto &fetch; }
$core[003446] = 06452; $code[003446] = *I03446; sub I03446 { &emul8; goto &fetch; }
$core[003447] = 06462; $code[003447] = *I03447; sub I03447 { &emul8; goto &fetch; }
$core[003450] = 06472; $code[003450] = *I03450; sub I03450 { &emul8; goto &fetch; }
$core[003451] = 06764; $code[003451] = *I03451; sub I03451 { &emul8; goto &fetch; }
$core[003452] = 06772; $code[003452] = *I03452; sub I03452 { &emul8; goto &fetch; }
$core[003453] = 07200; $code[003453] = *I03453; sub I03453 { $lac &= 010000; goto &fetch; }
$core[003454] = 06046; $code[003454] = *I03454; sub I03454 { &emul8; goto &fetch; }
$core[003455] = 03414; $code[003455] = *L03455; sub L03455 { $core[000014] = 0000 if ++$core[000014] == 010000; $core[($df<<12)+$core[000014]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000014]] = *emul8; goto &fetch; }
$core[003456] = 02376; $code[003456] = *I03456; sub I03456 { if (++$core[003576] == 010000) { $core[003576] = 0; $pc++; }$code[003576] = *emul8; goto &fetch; }
$core[003457] = 05255; $code[003457] = *I03457; sub I03457 { $pc = 003455; $inh = 0; goto &fetch; }
$core[003460] = 01027; $code[003460] = *I03460; sub I03460 { $lac += $core[000027]; goto &fetch; }
$core[003461] = 03013; $code[003461] = *I03461; sub I03461 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[003462] = 06001; $code[003462] = *I03462; sub I03462 { &emul8; goto &fetch; }
$core[003463] = 04512; $code[003463] = *I03463; sub I03463 { $core[($ib<<12)+$core[74]] = 03464; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[003464] = 04512; $code[003464] = *I03464; sub I03464 { $core[($ib<<12)+$core[74]] = 03465; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[003465] = 04512; $code[003465] = *I03465; sub I03465 { $core[($ib<<12)+$core[74]] = 03466; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[003466] = 04501; $code[003466] = *I03466; sub I03466 { $core[($ib<<12)+$core[65]] = 03467; $pc = ($ib<<12)+$core[65]+1; $code[($ib<<12)+$core[65]] = *emul8; $inh = 0; goto &fetch; }
$core[003467] = 00641; $code[003467] = *I03467; sub I03467 { $lac &= (010000|$core[($df<<12)+$core[1825]]); goto &fetch; }
$core[003470] = 05671; $code[003470] = *I03470; sub I03470 { $pc = ($ib<<12)+$core[1849]; $inh = 0; goto &fetch; }
$core[003471] = 02232; $code[003471] = *P03471; sub P03471 { if (++$core[003432] == 010000) { $core[003432] = 0; $pc++; }$code[003432] = *emul8; goto &fetch; }
$core[003576] = 07760; $code[003576] = *D03576; sub D03576 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003577] = 02746; $code[003577] = *D03577; sub D03577 { if (++$core[($df<<12)+$core[1894]] == 010000) { $core[($df<<12)+$core[1894]] = 0; $pc++; }$code[($df<<12)+$core[1894]] = *emul8; goto &fetch; }
$core[005600] = 00000; $code[005600] = *S05600; sub S05600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005601] = 04430; $code[005601] = *I05601; sub I05601 { $core[($ib<<12)+$core[24]] = 05602; $pc = ($ib<<12)+$core[24]+1; $code[($ib<<12)+$core[24]] = *emul8; $inh = 0; goto &fetch; }
$core[005602] = 03364; $code[005602] = *I05602; sub I05602 { $core[005764] = $lac & 07777; $lac &= 010000; $code[005764] = *emul8; goto &fetch; }
$core[005603] = 07040; $code[005603] = *I05603; sub I05603 { $lac ^= 07777; goto &fetch; }
$core[005604] = 03260; $code[005604] = *I05604; sub I05604 { $core[005660] = $lac & 07777; $lac &= 010000; $code[005660] = *emul8; goto &fetch; }
$core[005605] = 01363; $code[005605] = *I05605; sub I05605 { $lac += $core[005763]; goto &fetch; }
$core[005606] = 03044; $code[005606] = *I05606; sub I05606 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[005607] = 04755; $code[005607] = *I05607; sub I05607 { $core[($ib<<12)+$core[3053]] = 05610; $pc = ($ib<<12)+$core[3053]+1; $code[($ib<<12)+$core[3053]] = *emul8; $inh = 0; goto &fetch; }
$core[005610] = 03365; $code[005610] = *I05610; sub I05610 { $core[005765] = $lac & 07777; $lac &= 010000; $code[005765] = *emul8; goto &fetch; }
$core[005611] = 05215; $code[005611] = *I05611; sub I05611 { $pc = 005615; $inh = 0; goto &fetch; }
$core[005612] = 02260; $code[005612] = *L05612; sub L05612 { if (++$core[005660] == 010000) { $core[005660] = 0; $pc++; }$code[005660] = *emul8; goto &fetch; }
$core[005613] = 04526; $code[005613] = *I05613; sub I05613 { $core[($ib<<12)+$core[86]] = 05614; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[005614] = 04506; $code[005614] = *L05614; sub L05614 { $core[($ib<<12)+$core[70]] = 05615; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[005615] = 04522; $code[005615] = *L05615; sub L05615 { $core[($ib<<12)+$core[82]] = 05616; $pc = ($ib<<12)+$core[82]+1; $code[($ib<<12)+$core[82]] = *emul8; $inh = 0; goto &fetch; }
$core[005616] = 05212; $code[005616] = *I05616; sub I05616 { $pc = 005612; $inh = 0; goto &fetch; }
$core[005617] = 05250; $code[005617] = *I05617; sub I05617 { $pc = 005650; $inh = 0; goto &fetch; }
$core[005620] = 01260; $code[005620] = *I05620; sub I05620 { $lac += $core[005660]; goto &fetch; }
$core[005621] = 07700; $code[005621] = *I05621; sub I05621 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005622] = 07040; $code[005622] = *I05622; sub I05622 { $lac ^= 07777; goto &fetch; }
$core[005623] = 01364; $code[005623] = *I05623; sub I05623 { $lac += $core[005764]; goto &fetch; }
$core[005624] = 03364; $code[005624] = *I05624; sub I05624 { $core[005764] = $lac & 07777; $lac &= 010000; $code[005764] = *emul8; goto &fetch; }
$core[005625] = 04342; $code[005625] = *I05625; sub I05625 { $core[005742] = 05626; $pc = 005742+1; $code[005742] = *emul8; $inh = 0; goto &fetch; }
$core[005626] = 01127; $code[005626] = *I05626; sub I05626 { $lac += $core[000127]; goto &fetch; }
$core[005627] = 03043; $code[005627] = *I05627; sub I05627 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[005630] = 03042; $code[005630] = *I05630; sub I05630 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[005631] = 03041; $code[005631] = *I05631; sub I05631 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[005632] = 04313; $code[005632] = *I05632; sub I05632 { $core[005713] = 05633; $pc = 005713+1; $code[005713] = *emul8; $inh = 0; goto &fetch; }
$core[005633] = 01162; $code[005633] = *P05633; sub P05633 { $lac += $core[000162]; goto &fetch; }
$core[005634] = 07640; $code[005634] = *I05634; sub I05634 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005635] = 05241; $code[005635] = *I05635; sub I05635 { $pc = 005641; $inh = 0; goto &fetch; }
$core[005636] = 01045; $code[005636] = *I05636; sub I05636 { $lac += $core[000045]; goto &fetch; }
$core[005637] = 07700; $code[005637] = *I05637; sub I05637 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005640] = 05214; $code[005640] = *I05640; sub I05640 { $pc = 005614; $inh = 0; goto &fetch; }
$core[005641] = 01361; $code[005641] = *L05641; sub L05641 { $lac += $core[005761]; goto &fetch; }
$core[005642] = 03760; $code[005642] = *I05642; sub I05642 { $core[($df<<12)+$core[3056]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3056]] = *emul8; goto &fetch; }
$core[005643] = 01162; $code[005643] = *I05643; sub I05643 { $lac += $core[000162]; goto &fetch; }
$core[005644] = 07110; $code[005644] = *I05644; sub I05644 { $lac &= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005645] = 03162; $code[005645] = *I05645; sub I05645 { $core[000162] = $lac & 07777; $lac &= 010000; $code[000162] = *emul8; goto &fetch; }
$core[005646] = 01045; $code[005646] = *I05646; sub I05646 { $lac += $core[000045]; goto &fetch; }
$core[005647] = 05762; $code[005647] = *I05647; sub I05647 { $pc = ($ib<<12)+$core[3058]; $inh = 0; goto &fetch; }
$core[005650] = 04511; $code[005650] = *L05650; sub L05650 { $core[($ib<<12)+$core[73]] = 05651; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[005651] = 06145; $code[005651] = *I05651; sub I05651 { &emul8; goto &fetch; }
$core[005652] = 05301; $code[005652] = *I05652; sub I05652 { $pc = 005701; $inh = 0; goto &fetch; }
$core[005653] = 02365; $code[005653] = *L05653; sub L05653 { if (++$core[005765] == 010000) { $core[005765] = 0; $pc++; }$code[005765] = *emul8; goto &fetch; }
$core[005654] = 04450; $code[005654] = *I05654; sub I05654 { $core[($ib<<12)+$core[40]] = 05655; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[005655] = 01366; $code[005655] = *I05655; sub I05655 { $lac += $core[005766]; goto &fetch; }
$core[005656] = 03260; $code[005656] = *L05656; sub L05656 { $core[005660] = $lac & 07777; $lac &= 010000; $code[005660] = *emul8; goto &fetch; }
$core[005657] = 04407; $code[005657] = *I05657; sub I05657 { $core[($ib<<12)+$core[7]] = 05660; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005660] = 07000; $code[005660] = *D05660; sub D05660 { &emul8; goto &fetch; }
$core[005661] = 06554; $code[005661] = *I05661; sub I05661 { &emul8; goto &fetch; }
$core[005662] = 00000; $code[005662] = *I05662; sub I05662 { &emul8; goto &fetch; }
$core[005663] = 01364; $code[005663] = *I05663; sub I05663 { $lac += $core[005764]; goto &fetch; }
$core[005664] = 07450; $code[005664] = *I05664; sub I05664 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005665] = 05600; $code[005665] = *I05665; sub I05665 { $pc = ($ib<<12)+$core[2944]; $inh = 0; goto &fetch; }
$core[005666] = 07500; $code[005666] = *I05666; sub I05666 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[005667] = 05273; $code[005667] = *I05667; sub I05667 { $pc = 005673; $inh = 0; goto &fetch; }
$core[005670] = 07001; $code[005670] = *I05670; sub I05670 { $lac++; goto &fetch; }
$core[005671] = 03364; $code[005671] = *I05671; sub I05671 { $core[005764] = $lac & 07777; $lac &= 010000; $code[005764] = *emul8; goto &fetch; }
$core[005672] = 05277; $code[005672] = *I05672; sub I05672 { $pc = 005677; $inh = 0; goto &fetch; }
$core[005673] = 07240; $code[005673] = *L05673; sub L05673 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005674] = 01364; $code[005674] = *I05674; sub I05674 { $lac += $core[005764]; goto &fetch; }
$core[005675] = 03364; $code[005675] = *I05675; sub I05675 { $core[005764] = $lac & 07777; $lac &= 010000; $code[005764] = *emul8; goto &fetch; }
$core[005676] = 01066; $code[005676] = *I05676; sub I05676 { $lac += $core[000066]; goto &fetch; }
$core[005677] = 01367; $code[005677] = *L05677; sub L05677 { $lac += $core[005767]; goto &fetch; }
$core[005700] = 05256; $code[005700] = *I05700; sub I05700 { $pc = 005656; $inh = 0; goto &fetch; }
$core[005701] = 04506; $code[005701] = *L05701; sub L05701 { $core[($ib<<12)+$core[70]] = 05702; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[005702] = 04755; $code[005702] = *I05702; sub I05702 { $core[($ib<<12)+$core[3053]] = 05703; $pc = ($ib<<12)+$core[3053]+1; $code[($ib<<12)+$core[3053]] = *emul8; $inh = 0; goto &fetch; }
$core[005703] = 03040; $code[005703] = *D05703; sub D05703 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[005704] = 04757; $code[005704] = *I05704; sub I05704 { $core[($ib<<12)+$core[3055]] = 05705; $pc = ($ib<<12)+$core[3055]+1; $code[($ib<<12)+$core[3055]] = *emul8; $inh = 0; goto &fetch; }
$core[005705] = 01164; $code[005705] = *I05705; sub I05705 { $lac += $core[000164]; goto &fetch; }
$core[005706] = 02040; $code[005706] = *I05706; sub I05706 { if (++$core[000040] == 010000) { $core[000040] = 0; $pc++; }$code[000040] = *emul8; goto &fetch; }
$core[005707] = 07041; $code[005707] = *I05707; sub I05707 { $lac ^= 07777; $lac++; goto &fetch; }
$core[005710] = 01364; $code[005710] = *I05710; sub I05710 { $lac += $core[005764]; goto &fetch; }
$core[005711] = 03364; $code[005711] = *I05711; sub I05711 { $core[005764] = $lac & 07777; $lac &= 010000; $code[005764] = *emul8; goto &fetch; }
$core[005712] = 05253; $code[005712] = *I05712; sub I05712 { $pc = 005653; $inh = 0; goto &fetch; }
$core[005713] = 00000; $code[005713] = *S05713; sub S05713 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005714] = 07300; $code[005714] = *I05714; sub I05714 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005715] = 01043; $code[005715] = *I05715; sub I05715 { $lac += $core[000043]; goto &fetch; }
$core[005716] = 01047; $code[005716] = *I05716; sub I05716 { $lac += $core[000047]; goto &fetch; }
$core[005717] = 03047; $code[005717] = *I05717; sub I05717 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[005720] = 07004; $code[005720] = *I05720; sub I05720 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005721] = 01042; $code[005721] = *I05721; sub I05721 { $lac += $core[000042]; goto &fetch; }
$core[005722] = 01046; $code[005722] = *I05722; sub I05722 { $lac += $core[000046]; goto &fetch; }
$core[005723] = 03046; $code[005723] = *I05723; sub I05723 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[005724] = 07004; $code[005724] = *I05724; sub I05724 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005725] = 01041; $code[005725] = *I05725; sub I05725 { $lac += $core[000041]; goto &fetch; }
$core[005726] = 01045; $code[005726] = *I05726; sub I05726 { $lac += $core[000045]; goto &fetch; }
$core[005727] = 03045; $code[005727] = *I05727; sub I05727 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[005730] = 07004; $code[005730] = *I05730; sub I05730 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005731] = 01162; $code[005731] = *I05731; sub I05731 { $lac += $core[000162]; goto &fetch; }
$core[005732] = 03162; $code[005732] = *I05732; sub I05732 { $core[000162] = $lac & 07777; $lac &= 010000; $code[000162] = *emul8; goto &fetch; }
$core[005733] = 05713; $code[005733] = *D05733; sub D05733 { $pc = ($ib<<12)+$core[3019]; $inh = 0; goto &fetch; }
$core[005734] = 00000; $code[005734] = *S05734; sub S05734 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005735] = 04756; $code[005735] = *I05735; sub I05735 { $core[($ib<<12)+$core[3054]] = 05736; $pc = ($ib<<12)+$core[3054]+1; $code[($ib<<12)+$core[3054]] = *emul8; $inh = 0; goto &fetch; }
$core[005736] = 01162; $code[005736] = *I05736; sub I05736 { $lac += $core[000162]; goto &fetch; }
$core[005737] = 07004; $code[005737] = *I05737; sub I05737 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005740] = 03162; $code[005740] = *I05740; sub I05740 { $core[000162] = $lac & 07777; $lac &= 010000; $code[000162] = *emul8; goto &fetch; }
$core[005741] = 05734; $code[005741] = *I05741; sub I05741 { $pc = ($ib<<12)+$core[3036]; $inh = 0; goto &fetch; }
$core[005742] = 00000; $code[005742] = *S05742; sub S05742 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005743] = 04504; $code[005743] = *I05743; sub I05743 { $core[($ib<<12)+$core[68]] = 05744; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[005744] = 00045; $code[005744] = *I05744; sub I05744 { $lac &= (010000|$core[000045]); goto &fetch; }
$core[005745] = 04505; $code[005745] = *I05745; sub I05745 { $core[($ib<<12)+$core[69]] = 05746; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[005746] = 00041; $code[005746] = *I05746; sub I05746 { $lac &= (010000|$core[000041]); goto &fetch; }
$core[005747] = 03162; $code[005747] = *I05747; sub I05747 { $core[000162] = $lac & 07777; $lac &= 010000; $code[000162] = *emul8; goto &fetch; }
$core[005750] = 04334; $code[005750] = *I05750; sub I05750 { $core[005734] = 05751; $pc = 005734+1; $code[005734] = *emul8; $inh = 0; goto &fetch; }
$core[005751] = 04334; $code[005751] = *I05751; sub I05751 { $core[005734] = 05752; $pc = 005734+1; $code[005734] = *emul8; $inh = 0; goto &fetch; }
$core[005752] = 04313; $code[005752] = *I05752; sub I05752 { $core[005713] = 05753; $pc = 005713+1; $code[005713] = *emul8; $inh = 0; goto &fetch; }
$core[005753] = 04334; $code[005753] = *I05753; sub I05753 { $core[005734] = 05754; $pc = 005734+1; $code[005734] = *emul8; $inh = 0; goto &fetch; }
$core[005754] = 05742; $code[005754] = *I05754; sub I05754 { $pc = ($ib<<12)+$core[3042]; $inh = 0; goto &fetch; }
$core[005755] = 06030; $code[005755] = *P05755; sub P05755 { &emul8; goto &fetch; }
$core[005756] = 07037; $code[005756] = *P05756; sub P05756 { $lac ^= 010000; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[005757] = 06010; $code[005757] = *P05757; sub P05757 { &emul8; goto &fetch; }
$core[005760] = 07251; $code[005760] = *P05760; sub P05760 { $lac &= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005761] = 05633; $code[005761] = *D05761; sub D05761 { $pc = ($ib<<12)+$core[2971]; $inh = 0; goto &fetch; }
$core[005762] = 07256; $code[005762] = *P05762; sub P05762 { $lac &= 010000; $lac ^= 07777; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[005763] = 00043; $code[005763] = *D05763; sub D05763 { $lac &= (010000|$core[000043]); goto &fetch; }
$core[005764] = 00000; $code[005764] = *D05764; sub D05764 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005765] = 00000; $code[005765] = *D05765; sub D05765 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005766] = 07000; $code[005766] = *D05766; sub D05766 { goto &fetch; }
$core[005767] = 03373; $code[005767] = *D05767; sub D05767 { $core[005773] = $lac & 07777; $lac &= 010000; $code[005773] = *emul8; goto &fetch; }
$core[005770] = 00004; $code[005770] = *D05770; sub D05770 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[005771] = 02400; $code[005771] = *I05771; sub I05771 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[005772] = 00000; $code[005772] = *I05772; sub I05772 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005773] = 07775; $code[005773] = *D05773; sub D05773 { &emul8; goto &fetch; }
$core[005774] = 03146; $code[005774] = *I05774; sub I05774 { $core[000146] = $lac & 07777; $lac &= 010000; $code[000146] = *emul8; goto &fetch; }
$core[005775] = 03147; $code[005775] = *I05775; sub I05775 { $core[000147] = $lac & 07777; $lac &= 010000; $code[000147] = *emul8; goto &fetch; }
$core[005776] = 00215; $code[005776] = *I05776; sub I05776 { $lac &= (010000|$core[005615]); goto &fetch; }
$core[005777] = 00214; $code[005777] = *I05777; sub I05777 { $lac &= (010000|$core[005614]); goto &fetch; }
$core[006000] = 00337; $code[006000] = *I06000; sub I06000 { $lac &= (010000|$core[006137]); goto &fetch; }
$core[006001] = 00254; $code[006001] = *I06001; sub I06001 { $lac &= (010000|$core[006054]); goto &fetch; }
$core[006002] = 00000; $code[006002] = *D06002; sub D06002 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006003] = 00212; $code[006003] = *I06003; sub I06003 { $lac &= (010000|$core[006012]); goto &fetch; }
$core[006004] = 06030; $code[006004] = *D06004; sub D06004 { &emul8; goto &fetch; }
$core[006005] = 07634; $code[006005] = *I06005; sub I06005 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006006] = 07766; $code[006006] = *I06006; sub I06006 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[006007] = 07777; $code[006007] = *I06007; sub I06007 { &emul8; goto &fetch; }
$core[006010] = 00000; $code[006010] = *S06010; sub S06010 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006011] = 03164; $code[006011] = *L06011; sub L06011 { $core[000164] = $lac & 07777; $lac &= 010000; $code[000164] = *emul8; goto &fetch; }
$core[006012] = 04522; $code[006012] = *D06012; sub D06012 { $core[($ib<<12)+$core[82]] = 06013; $pc = ($ib<<12)+$core[82]+1; $code[($ib<<12)+$core[82]] = *emul8; $inh = 0; goto &fetch; }
$core[006013] = 07000; $code[006013] = *I06013; sub I06013 { goto &fetch; }
$core[006014] = 05610; $code[006014] = *I06014; sub I06014 { $pc = ($ib<<12)+$core[3080]; $inh = 0; goto &fetch; }
$core[006015] = 04506; $code[006015] = *I06015; sub I06015 { $core[($ib<<12)+$core[70]] = 06016; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[006016] = 01164; $code[006016] = *I06016; sub I06016 { $lac += $core[000164]; goto &fetch; }
$core[006017] = 07106; $code[006017] = *I06017; sub I06017 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[006020] = 07530; $code[006020] = *I06020; sub I06020 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006021] = 05226; $code[006021] = *I06021; sub I06021 { $pc = 006026; $inh = 0; goto &fetch; }
$core[006022] = 01164; $code[006022] = *I06022; sub I06022 { $lac += $core[000164]; goto &fetch; }
$core[006023] = 07004; $code[006023] = *I06023; sub I06023 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006024] = 01127; $code[006024] = *I06024; sub I06024 { $lac += $core[000127]; goto &fetch; }
$core[006025] = 07530; $code[006025] = *I06025; sub I06025 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006026] = 04526; $code[006026] = *L06026; sub L06026 { $core[($ib<<12)+$core[86]] = 06027; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[006027] = 05211; $code[006027] = *I06027; sub I06027 { $pc = 006011; $inh = 0; goto &fetch; }
$core[006030] = 00000; $code[006030] = *S06030; sub S06030 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006031] = 04521; $code[006031] = *I06031; sub I06031 { $core[($ib<<12)+$core[81]] = 06032; $pc = ($ib<<12)+$core[81]+1; $code[($ib<<12)+$core[81]] = *emul8; $inh = 0; goto &fetch; }
$core[006032] = 03127; $code[006032] = *I06032; sub I06032 { $core[000127] = $lac & 07777; $lac &= 010000; $code[000127] = *emul8; goto &fetch; }
$core[006033] = 04511; $code[006033] = *I06033; sub I06033 { $core[($ib<<12)+$core[73]] = 06034; $pc = ($ib<<12)+$core[73]+1; $code[($ib<<12)+$core[73]] = *emul8; $inh = 0; goto &fetch; }
$core[006034] = 06114; $code[006034] = *I06034; sub I06034 { &emul8; goto &fetch; }
$core[006035] = 04506; $code[006035] = *I06035; sub I06035 { $core[($ib<<12)+$core[70]] = 06036; $pc = ($ib<<12)+$core[70]+1; $code[($ib<<12)+$core[70]] = *emul8; $inh = 0; goto &fetch; }
$core[006036] = 04521; $code[006036] = *I06036; sub I06036 { $core[($ib<<12)+$core[81]] = 06037; $pc = ($ib<<12)+$core[81]+1; $code[($ib<<12)+$core[81]] = *emul8; $inh = 0; goto &fetch; }
$core[006037] = 07240; $code[006037] = *I06037; sub I06037 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[006040] = 01127; $code[006040] = *I06040; sub I06040 { $lac += $core[000127]; goto &fetch; }
$core[006041] = 05630; $code[006041] = *I06041; sub I06041 { $pc = ($ib<<12)+$core[3096]; $inh = 0; goto &fetch; }
$core[006042] = 00000; $code[006042] = *S06042; sub S06042 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006043] = 03164; $code[006043] = *I06043; sub I06043 { $core[000164] = $lac & 07777; $lac &= 010000; $code[000164] = *emul8; goto &fetch; }
$core[006044] = 01314; $code[006044] = *I06044; sub I06044 { $lac += $core[006114]; goto &fetch; }
$core[006045] = 03260; $code[006045] = *I06045; sub I06045 { $core[006060] = $lac & 07777; $lac &= 010000; $code[006060] = *emul8; goto &fetch; }
$core[006046] = 03210; $code[006046] = *I06046; sub I06046 { $core[006010] = $lac & 07777; $lac &= 010000; $code[006010] = *emul8; goto &fetch; }
$core[006047] = 04255; $code[006047] = *I06047; sub I06047 { $core[006055] = 06050; $pc = 006055+1; $code[006055] = *emul8; $inh = 0; goto &fetch; }
$core[006050] = 04255; $code[006050] = *I06050; sub I06050 { $core[006055] = 06051; $pc = 006055+1; $code[006055] = *emul8; $inh = 0; goto &fetch; }
$core[006051] = 02210; $code[006051] = *I06051; sub I06051 { if (++$core[006010] == 010000) { $core[006010] = 0; $pc++; }$code[006010] = *emul8; goto &fetch; }
$core[006052] = 04255; $code[006052] = *I06052; sub I06052 { $core[006055] = 06053; $pc = 006055+1; $code[006055] = *emul8; $inh = 0; goto &fetch; }
$core[006053] = 04255; $code[006053] = *D06053; sub D06053 { $core[006055] = 06054; $pc = 006055+1; $code[006055] = *emul8; $inh = 0; goto &fetch; }
$core[006054] = 05642; $code[006054] = *D06054; sub D06054 { $pc = ($ib<<12)+$core[3106]; $inh = 0; goto &fetch; }
$core[006055] = 00000; $code[006055] = *S06055; sub S06055 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006056] = 03163; $code[006056] = *I06056; sub I06056 { $core[000163] = $lac & 07777; $lac &= 010000; $code[000163] = *emul8; goto &fetch; }
$core[006057] = 01164; $code[006057] = *L06057; sub L06057 { $lac += $core[000164]; goto &fetch; }
$core[006060] = 01204; $code[006060] = *D06060; sub D06060 { $lac += $core[006004]; goto &fetch; }
$core[006061] = 07510; $code[006061] = *I06061; sub I06061 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006062] = 05267; $code[006062] = *I06062; sub I06062 { $pc = 006067; $inh = 0; goto &fetch; }
$core[006063] = 03164; $code[006063] = *I06063; sub I06063 { $core[000164] = $lac & 07777; $lac &= 010000; $code[000164] = *emul8; goto &fetch; }
$core[006064] = 02163; $code[006064] = *I06064; sub I06064 { if (++$core[000163] == 010000) { $core[000163] = 0; $pc++; }$code[000163] = *emul8; goto &fetch; }
$core[006065] = 02210; $code[006065] = *I06065; sub I06065 { if (++$core[006010] == 010000) { $core[006010] = 0; $pc++; }$code[006010] = *emul8; goto &fetch; }
$core[006066] = 05257; $code[006066] = *I06066; sub I06066 { $pc = 006057; $inh = 0; goto &fetch; }
$core[006067] = 07300; $code[006067] = *L06067; sub L06067 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006070] = 02260; $code[006070] = *I06070; sub I06070 { if (++$core[006060] == 010000) { $core[006060] = 0; $pc++; }$code[006060] = *emul8; goto &fetch; }
$core[006071] = 01210; $code[006071] = *I06071; sub I06071 { $lac += $core[006010]; goto &fetch; }
$core[006072] = 07650; $code[006072] = *I06072; sub I06072 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006073] = 05655; $code[006073] = *I06073; sub I06073 { $pc = ($ib<<12)+$core[3117]; $inh = 0; goto &fetch; }
$core[006074] = 01163; $code[006074] = *I06074; sub I06074 { $lac += $core[000163]; goto &fetch; }
$core[006075] = 01036; $code[006075] = *I06075; sub I06075 { $lac += $core[000036]; goto &fetch; }
$core[006076] = 04512; $code[006076] = *I06076; sub I06076 { $core[($ib<<12)+$core[74]] = 06077; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[006077] = 05655; $code[006077] = *I06077; sub I06077 { $pc = ($ib<<12)+$core[3117]; $inh = 0; goto &fetch; }
$core[006100] = 00000; $code[006100] = *S06100; sub S06100 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006101] = 03164; $code[006101] = *I06101; sub I06101 { $core[000164] = $lac & 07777; $lac &= 010000; $code[000164] = *emul8; goto &fetch; }
$core[006102] = 01164; $code[006102] = *I06102; sub I06102 { $lac += $core[000164]; goto &fetch; }
$core[006103] = 07710; $code[006103] = *I06103; sub I06103 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006104] = 01035; $code[006104] = *I06104; sub I06104 { $lac += $core[000035]; goto &fetch; }
$core[006105] = 01315; $code[006105] = *D06105; sub D06105 { $lac += $core[006115]; goto &fetch; }
$core[006106] = 04512; $code[006106] = *I06106; sub I06106 { $core[($ib<<12)+$core[74]] = 06107; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[006107] = 01164; $code[006107] = *I06107; sub I06107 { $lac += $core[000164]; goto &fetch; }
$core[006110] = 07510; $code[006110] = *I06110; sub I06110 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006111] = 07041; $code[006111] = *I06111; sub I06111 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006112] = 04242; $code[006112] = *I06112; sub I06112 { $core[006042] = 06113; $pc = 006042+1; $code[006042] = *emul8; $inh = 0; goto &fetch; }
$core[006113] = 05700; $code[006113] = *I06113; sub I06113 { $pc = ($ib<<12)+$core[3136]; $inh = 0; goto &fetch; }
$core[006114] = 01204; $code[006114] = *D06114; sub D06114 { $lac += $core[006004]; goto &fetch; }
$core[006115] = 00253; $code[006115] = *D06115; sub D06115 { $lac &= (010000|$core[006053]); goto &fetch; }
$core[006116] = 00255; $code[006116] = *I06116; sub I06116 { $lac &= (010000|$core[006055]); goto &fetch; }
$core[006117] = 07200; $code[006117] = *L06117; sub L06117 { $lac &= 010000; goto &fetch; }
$core[006120] = 01051; $code[006120] = *I06120; sub I06120 { $lac += $core[000051]; goto &fetch; }
$core[006121] = 07410; $code[006121] = *I06121; sub I06121 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006122] = 01133; $code[006122] = *L06122; sub L06122 { $lac += $core[000133]; goto &fetch; }
$core[006123] = 07041; $code[006123] = *I06123; sub I06123 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006124] = 07450; $code[006124] = *I06124; sub I06124 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006125] = 01347; $code[006125] = *I06125; sub I06125 { $lac += $core[006147]; goto &fetch; }
$core[006126] = 03164; $code[006126] = *I06126; sub I06126 { $core[000164] = $lac & 07777; $lac &= 010000; $code[000164] = *emul8; goto &fetch; }
$core[006127] = 01022; $code[006127] = *I06127; sub I06127 { $lac += $core[000022]; goto &fetch; }
$core[006130] = 04512; $code[006130] = *I06130; sub I06130 { $core[($ib<<12)+$core[74]] = 06131; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[006131] = 01412; $code[006131] = *L06131; sub L06131 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac += $core[($df<<12)+$core[000012]]; goto &fetch; }
$core[006132] = 02157; $code[006132] = *I06132; sub I06132 { if (++$core[000157] == 010000) { $core[000157] = 0; $pc++; }$code[000157] = *emul8; goto &fetch; }
$core[006133] = 05336; $code[006133] = *I06133; sub I06133 { $pc = 006136; $inh = 0; goto &fetch; }
$core[006134] = 07240; $code[006134] = *I06134; sub I06134 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[006135] = 03157; $code[006135] = *I06135; sub I06135 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[006136] = 04750; $code[006136] = *L06136; sub L06136 { $core[($ib<<12)+$core[3176]] = 06137; $pc = ($ib<<12)+$core[3176]+1; $code[($ib<<12)+$core[3176]] = *emul8; $inh = 0; goto &fetch; }
$core[006137] = 07410; $code[006137] = *D06137; sub D06137 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006140] = 05331; $code[006140] = *I06140; sub I06140 { $pc = 006131; $inh = 0; goto &fetch; }
$core[006141] = 01346; $code[006141] = *I06141; sub I06141 { $lac += $core[006146]; goto &fetch; }
$core[006142] = 04512; $code[006142] = *I06142; sub I06142 { $core[($ib<<12)+$core[74]] = 06143; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[006143] = 01156; $code[006143] = *I06143; sub I06143 { $lac += $core[000156]; goto &fetch; }
$core[006144] = 04300; $code[006144] = *I06144; sub I06144 { $core[006100] = 06145; $pc = 006100+1; $code[006100] = *emul8; $inh = 0; goto &fetch; }
$core[006145] = 05770; $code[006145] = *L06145; sub L06145 { $pc = ($ib<<12)+$core[3192]; $inh = 0; goto &fetch; }
$core[006146] = 00305; $code[006146] = *D06146; sub D06146 { $lac &= (010000|$core[006105]); goto &fetch; }
$core[006147] = 07772; $code[006147] = *D06147; sub D06147 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[006150] = 06437; $code[006150] = *P06150; sub P06150 { &emul8; goto &fetch; }
$core[006151] = 00000; $code[006151] = *S06151; sub S06151 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006152] = 01143; $code[006152] = *I06152; sub I06152 { $lac += $core[000143]; goto &fetch; }
$core[006153] = 04520; $code[006153] = *I06153; sub I06153 { $core[($ib<<12)+$core[80]] = 06154; $pc = ($ib<<12)+$core[80]+1; $code[($ib<<12)+$core[80]] = *emul8; $inh = 0; goto &fetch; }
$core[006154] = 00071; $code[006154] = *I06154; sub I06154 { $lac &= (010000|$core[000071]); goto &fetch; }
$core[006155] = 04242; $code[006155] = *I06155; sub I06155 { $core[006042] = 06156; $pc = 006042+1; $code[006042] = *emul8; $inh = 0; goto &fetch; }
$core[006156] = 01022; $code[006156] = *I06156; sub I06156 { $lac += $core[000022]; goto &fetch; }
$core[006157] = 04512; $code[006157] = *I06157; sub I06157 { $core[($ib<<12)+$core[74]] = 06160; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[006160] = 01143; $code[006160] = *I06160; sub I06160 { $lac += $core[000143]; goto &fetch; }
$core[006161] = 00026; $code[006161] = *I06161; sub I06161 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[006162] = 04242; $code[006162] = *I06162; sub I06162 { $core[006042] = 06163; $pc = 006042+1; $code[006042] = *emul8; $inh = 0; goto &fetch; }
$core[006163] = 01033; $code[006163] = *I06163; sub I06163 { $lac += $core[000033]; goto &fetch; }
$core[006164] = 03142; $code[006164] = *I06164; sub I06164 { $core[000142] = $lac & 07777; $lac &= 010000; $code[000142] = *emul8; goto &fetch; }
$core[006165] = 04512; $code[006165] = *I06165; sub I06165 { $core[($ib<<12)+$core[74]] = 06166; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[006166] = 05751; $code[006166] = *I06166; sub I06166 { $pc = ($ib<<12)+$core[3177]; $inh = 0; goto &fetch; }
$core[006167] = 00015; $code[006167] = *D06167; sub D06167 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[006170] = 00000; $code[006170] = *S06170; sub S06170 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006171] = 01045; $code[006171] = *I06171; sub I06171 { $lac += $core[000045]; goto &fetch; }
$core[006172] = 07700; $code[006172] = *I06172; sub I06172 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006173] = 05376; $code[006173] = *I06173; sub I06173 { $pc = 006176; $inh = 0; goto &fetch; }
$core[006174] = 04450; $code[006174] = *I06174; sub I06174 { $core[($ib<<12)+$core[40]] = 06175; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[006175] = 01367; $code[006175] = *I06175; sub I06175 { $lac += $core[006167]; goto &fetch; }
$core[006176] = 01033; $code[006176] = *L06176; sub L06176 { $lac += $core[000033]; goto &fetch; }
$core[006177] = 04512; $code[006177] = *I06177; sub I06177 { $core[($ib<<12)+$core[74]] = 06200; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[006200] = 07240; $code[006200] = *I06200; sub I06200 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[006201] = 01044; $code[006201] = *I06201; sub I06201 { $lac += $core[000044]; goto &fetch; }
$core[006202] = 03044; $code[006202] = *I06202; sub I06202 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006203] = 03156; $code[006203] = *L06203; sub L06203 { $core[000156] = $lac & 07777; $lac &= 010000; $code[000156] = *emul8; goto &fetch; }
$core[006204] = 01044; $code[006204] = *I06204; sub I06204 { $lac += $core[000044]; goto &fetch; }
$core[006205] = 07500; $code[006205] = *I06205; sub I06205 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006206] = 05220; $code[006206] = *I06206; sub I06206 { $pc = 006220; $inh = 0; goto &fetch; }
$core[006207] = 01631; $code[006207] = *I06207; sub I06207 { $lac += $core[($df<<12)+$core[3225]]; goto &fetch; }
$core[006210] = 07700; $code[006210] = *I06210; sub I06210 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006211] = 05244; $code[006211] = *I06211; sub I06211 { $pc = 006244; $inh = 0; goto &fetch; }
$core[006212] = 04407; $code[006212] = *I06212; sub I06212 { $core[($ib<<12)+$core[7]] = 06213; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[006213] = 03631; $code[006213] = *I06213; sub I06213 { &emul8; goto &fetch; }
$core[006214] = 00000; $code[006214] = *I06214; sub I06214 { &emul8; goto &fetch; }
$core[006215] = 07240; $code[006215] = *I06215; sub I06215 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[006216] = 01156; $code[006216] = *L06216; sub L06216 { $lac += $core[000156]; goto &fetch; }
$core[006217] = 05203; $code[006217] = *I06217; sub I06217 { $pc = 006203; $inh = 0; goto &fetch; }
$core[006220] = 04407; $code[006220] = *L06220; sub L06220 { $core[($ib<<12)+$core[7]] = 06221; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[006221] = 03632; $code[006221] = *I06221; sub I06221 { &emul8; goto &fetch; }
$core[006222] = 00000; $code[006222] = *I06222; sub I06222 { &emul8; goto &fetch; }
$core[006223] = 07001; $code[006223] = *I06223; sub I06223 { $lac++; goto &fetch; }
$core[006224] = 05216; $code[006224] = *I06224; sub I06224 { $pc = 006216; $inh = 0; goto &fetch; }
$core[006225] = 07771; $code[006225] = *D06225; sub D06225 { &emul8; goto &fetch; }
$core[006226] = 07772; $code[006226] = *D06226; sub D06226 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[006227] = 00007; $code[006227] = *D06227; sub D06227 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[006230] = 07766; $code[006230] = *D06230; sub D06230 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[006231] = 05770; $code[006231] = *P06231; sub P06231 { $pc = ($ib<<12)+$core[3320]; $inh = 0; goto &fetch; }
$core[006232] = 05773; $code[006232] = *P06232; sub P06232 { $pc = ($ib<<12)+$core[3323]; $inh = 0; goto &fetch; }
$core[006233] = 05734; $code[006233] = *P06233; sub P06233 { $pc = ($ib<<12)+$core[3292]; $inh = 0; goto &fetch; }
$core[006234] = 05742; $code[006234] = *P06234; sub P06234 { $pc = ($ib<<12)+$core[3298]; $inh = 0; goto &fetch; }
$core[006235] = 07544; $code[006235] = *D06235; sub D06235 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[006236] = 06122; $code[006236] = *P06236; sub P06236 { &emul8; goto &fetch; }
$core[006237] = 06117; $code[006237] = *P06237; sub P06237 { &emul8; goto &fetch; }
$core[006240] = 07040; $code[006240] = *L06240; sub L06240 { $lac ^= 07777; goto &fetch; }
$core[006241] = 01040; $code[006241] = *I06241; sub I06241 { $lac += $core[000040]; goto &fetch; }
$core[006242] = 03040; $code[006242] = *I06242; sub I06242 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[006243] = 05351; $code[006243] = *I06243; sub I06243 { $pc = 006351; $inh = 0; goto &fetch; }
$core[006244] = 04633; $code[006244] = *L06244; sub L06244 { $core[($ib<<12)+$core[3227]] = 06245; $pc = ($ib<<12)+$core[3227]+1; $code[($ib<<12)+$core[3227]] = *emul8; $inh = 0; goto &fetch; }
$core[006245] = 01235; $code[006245] = *I06245; sub I06245 { $lac += $core[006235]; goto &fetch; }
$core[006246] = 03012; $code[006246] = *I06246; sub I06246 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[006247] = 04634; $code[006247] = *I06247; sub I06247 { $core[($ib<<12)+$core[3228]] = 06250; $pc = ($ib<<12)+$core[3228]+1; $code[($ib<<12)+$core[3228]] = *emul8; $inh = 0; goto &fetch; }
$core[006250] = 01162; $code[006250] = *I06250; sub I06250 { $lac += $core[000162]; goto &fetch; }
$core[006251] = 05266; $code[006251] = *I06251; sub I06251 { $pc = 006266; $inh = 0; goto &fetch; }
$core[006252] = 07110; $code[006252] = *L06252; sub L06252 { $lac &= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006253] = 03004; $code[006253] = *I06253; sub I06253 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[006254] = 01045; $code[006254] = *I06254; sub I06254 { $lac += $core[000045]; goto &fetch; }
$core[006255] = 07010; $code[006255] = *I06255; sub I06255 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006256] = 03045; $code[006256] = *I06256; sub I06256 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006257] = 01046; $code[006257] = *I06257; sub I06257 { $lac += $core[000046]; goto &fetch; }
$core[006260] = 07010; $code[006260] = *I06260; sub I06260 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006261] = 03046; $code[006261] = *I06261; sub I06261 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006262] = 01047; $code[006262] = *I06262; sub I06262 { $lac += $core[000047]; goto &fetch; }
$core[006263] = 07010; $code[006263] = *I06263; sub I06263 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006264] = 03047; $code[006264] = *I06264; sub I06264 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[006265] = 01004; $code[006265] = *I06265; sub I06265 { $lac += $core[000004]; goto &fetch; }
$core[006266] = 02044; $code[006266] = *L06266; sub L06266 { if (++$core[000044] == 010000) { $core[000044] = 0; $pc++; }$code[000044] = *emul8; goto &fetch; }
$core[006267] = 05252; $code[006267] = *I06267; sub I06267 { $pc = 006252; $inh = 0; goto &fetch; }
$core[006270] = 07440; $code[006270] = *I06270; sub I06270 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[006271] = 05301; $code[006271] = *I06271; sub I06271 { $pc = 006301; $inh = 0; goto &fetch; }
$core[006272] = 07240; $code[006272] = *I06272; sub I06272 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[006273] = 01156; $code[006273] = *I06273; sub I06273 { $lac += $core[000156]; goto &fetch; }
$core[006274] = 03156; $code[006274] = *I06274; sub I06274 { $core[000156] = $lac & 07777; $lac &= 010000; $code[000156] = *emul8; goto &fetch; }
$core[006275] = 01045; $code[006275] = *I06275; sub I06275 { $lac += $core[000045]; goto &fetch; }
$core[006276] = 07650; $code[006276] = *I06276; sub I06276 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006277] = 03156; $code[006277] = *I06277; sub I06277 { $core[000156] = $lac & 07777; $lac &= 010000; $code[000156] = *emul8; goto &fetch; }
$core[006300] = 07410; $code[006300] = *I06300; sub I06300 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006301] = 03412; $code[006301] = *L06301; sub L06301 { $core[000012] = 0000 if ++$core[000012] == 010000; $core[($df<<12)+$core[000012]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000012]] = *emul8; goto &fetch; }
$core[006302] = 01225; $code[006302] = *I06302; sub I06302 { $lac += $core[006225]; goto &fetch; }
$core[006303] = 03044; $code[006303] = *I06303; sub I06303 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006304] = 04634; $code[006304] = *L06304; sub L06304 { $core[($ib<<12)+$core[3228]] = 06305; $pc = ($ib<<12)+$core[3228]+1; $code[($ib<<12)+$core[3228]] = *emul8; $inh = 0; goto &fetch; }
$core[006305] = 01162; $code[006305] = *I06305; sub I06305 { $lac += $core[000162]; goto &fetch; }
$core[006306] = 03412; $code[006306] = *I06306; sub I06306 { $core[000012] = 0000 if ++$core[000012] == 010000; $core[($df<<12)+$core[000012]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000012]] = *emul8; goto &fetch; }
$core[006307] = 02044; $code[006307] = *I06307; sub I06307 { if (++$core[000044] == 010000) { $core[000044] = 0; $pc++; }$code[000044] = *emul8; goto &fetch; }
$core[006310] = 05304; $code[006310] = *I06310; sub I06310 { $pc = 006304; $inh = 0; goto &fetch; }
$core[006311] = 01235; $code[006311] = *I06311; sub I06311 { $lac += $core[006235]; goto &fetch; }
$core[006312] = 03012; $code[006312] = *I06312; sub I06312 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[006313] = 01225; $code[006313] = *I06313; sub I06313 { $lac += $core[006225]; goto &fetch; }
$core[006314] = 03157; $code[006314] = *I06314; sub I06314 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[006315] = 01051; $code[006315] = *I06315; sub I06315 { $lac += $core[000051]; goto &fetch; }
$core[006316] = 07450; $code[006316] = *I06316; sub I06316 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006317] = 05340; $code[006317] = *I06317; sub I06317 { $pc = 006340; $inh = 0; goto &fetch; }
$core[006320] = 07041; $code[006320] = *I06320; sub I06320 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006321] = 01133; $code[006321] = *I06321; sub I06321 { $lac += $core[000133]; goto &fetch; }
$core[006322] = 07550; $code[006322] = *I06322; sub I06322 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006323] = 05327; $code[006323] = *I06323; sub I06323 { $pc = 006327; $inh = 0; goto &fetch; }
$core[006324] = 07200; $code[006324] = *I06324; sub I06324 { $lac &= 010000; goto &fetch; }
$core[006325] = 01051; $code[006325] = *I06325; sub I06325 { $lac += $core[000051]; goto &fetch; }
$core[006326] = 03133; $code[006326] = *I06326; sub I06326 { $core[000133] = $lac & 07777; $lac &= 010000; $code[000133] = *emul8; goto &fetch; }
$core[006327] = 01156; $code[006327] = *L06327; sub L06327 { $lac += $core[000156]; goto &fetch; }
$core[006330] = 07500; $code[006330] = *I06330; sub I06330 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006331] = 07200; $code[006331] = *I06331; sub I06331 { $lac &= 010000; goto &fetch; }
$core[006332] = 01051; $code[006332] = *I06332; sub I06332 { $lac += $core[000051]; goto &fetch; }
$core[006333] = 07510; $code[006333] = *I06333; sub I06333 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006334] = 05362; $code[006334] = *P06334; sub P06334 { $pc = 006362; $inh = 0; goto &fetch; }
$core[006335] = 01226; $code[006335] = *I06335; sub I06335 { $lac += $core[006226]; goto &fetch; }
$core[006336] = 07500; $code[006336] = *I06336; sub I06336 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006337] = 07200; $code[006337] = *I06337; sub I06337 { $lac &= 010000; goto &fetch; }
$core[006340] = 01227; $code[006340] = *L06340; sub L06340 { $lac += $core[006227]; goto &fetch; }
$core[006341] = 03004; $code[006341] = *I06341; sub I06341 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[006342] = 01235; $code[006342] = *P06342; sub P06342 { $lac += $core[006235]; goto &fetch; }
$core[006343] = 01004; $code[006343] = *I06343; sub I06343 { $lac += $core[000004]; goto &fetch; }
$core[006344] = 03040; $code[006344] = *I06344; sub I06344 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[006345] = 01004; $code[006345] = *I06345; sub I06345 { $lac += $core[000004]; goto &fetch; }
$core[006346] = 07041; $code[006346] = *I06346; sub I06346 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006347] = 03004; $code[006347] = *I06347; sub I06347 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[006350] = 01631; $code[006350] = *I06350; sub I06350 { $lac += $core[($df<<12)+$core[3225]]; goto &fetch; }
$core[006351] = 02440; $code[006351] = *L06351; sub L06351 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[006352] = 01440; $code[006352] = *I06352; sub I06352 { $lac += $core[($df<<12)+$core[32]]; goto &fetch; }
$core[006353] = 01230; $code[006353] = *I06353; sub I06353 { $lac += $core[006230]; goto &fetch; }
$core[006354] = 07710; $code[006354] = *I06354; sub I06354 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006355] = 05364; $code[006355] = *I06355; sub I06355 { $pc = 006364; $inh = 0; goto &fetch; }
$core[006356] = 03440; $code[006356] = *I06356; sub I06356 { $core[($df<<12)+$core[32]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[006357] = 02004; $code[006357] = *I06357; sub I06357 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[006360] = 05240; $code[006360] = *I06360; sub I06360 { $pc = 006240; $inh = 0; goto &fetch; }
$core[006361] = 02440; $code[006361] = *I06361; sub I06361 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[006362] = 02156; $code[006362] = *L06362; sub L06362 { if (++$core[000156] == 010000) { $core[000156] = 0; $pc++; }$code[000156] = *emul8; goto &fetch; }
$core[006363] = 07200; $code[006363] = *I06363; sub I06363 { $lac &= 010000; goto &fetch; }
$core[006364] = 01051; $code[006364] = *L06364; sub L06364 { $lac += $core[000051]; goto &fetch; }
$core[006365] = 07450; $code[006365] = *I06365; sub I06365 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006366] = 05636; $code[006366] = *I06366; sub I06366 { $pc = ($ib<<12)+$core[3230]; $inh = 0; goto &fetch; }
$core[006367] = 07041; $code[006367] = *I06367; sub I06367 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006370] = 03164; $code[006370] = *P06370; sub P06370 { $core[000164] = $lac & 07777; $lac &= 010000; $code[000164] = *emul8; goto &fetch; }
$core[006371] = 01164; $code[006371] = *I06371; sub I06371 { $lac += $core[000164]; goto &fetch; }
$core[006372] = 01156; $code[006372] = *I06372; sub I06372 { $lac += $core[000156]; goto &fetch; }
$core[006373] = 07540; $code[006373] = *P06373; sub P06373 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006374] = 05637; $code[006374] = *I06374; sub I06374 { $pc = ($ib<<12)+$core[3231]; $inh = 0; goto &fetch; }
$core[006375] = 01133; $code[006375] = *I06375; sub I06375 { $lac += $core[000133]; goto &fetch; }
$core[006376] = 07500; $code[006376] = *I06376; sub I06376 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006377] = 07200; $code[006377] = *I06377; sub I06377 { $lac &= 010000; goto &fetch; }
$core[006400] = 07041; $code[006400] = *I06400; sub I06400 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006401] = 01156; $code[006401] = *I06401; sub I06401 { $lac += $core[000156]; goto &fetch; }
$core[006402] = 07141; $code[006402] = *D06402; sub D06402 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[006403] = 03004; $code[006403] = *I06403; sub I06403 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[006404] = 07430; $code[006404] = *I06404; sub I06404 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006405] = 05222; $code[006405] = *I06405; sub I06405 { $pc = 006422; $inh = 0; goto &fetch; }
$core[006406] = 01156; $code[006406] = *L06406; sub L06406 { $lac += $core[000156]; goto &fetch; }
$core[006407] = 01004; $code[006407] = *I06407; sub I06407 { $lac += $core[000004]; goto &fetch; }
$core[006410] = 07650; $code[006410] = *I06410; sub I06410 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006411] = 05225; $code[006411] = *I06411; sub I06411 { $pc = 006425; $inh = 0; goto &fetch; }
$core[006412] = 01004; $code[006412] = *I06412; sub I06412 { $lac += $core[000004]; goto &fetch; }
$core[006413] = 07001; $code[006413] = *I06413; sub I06413 { $lac++; goto &fetch; }
$core[006414] = 07710; $code[006414] = *I06414; sub I06414 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006415] = 01025; $code[006415] = *I06415; sub I06415 { $lac += $core[000025]; goto &fetch; }
$core[006416] = 04237; $code[006416] = *P06416; sub P06416 { $core[006437] = 06417; $pc = 006437+1; $code[006437] = *emul8; $inh = 0; goto &fetch; }
$core[006417] = 05645; $code[006417] = *I06417; sub I06417 { $pc = ($ib<<12)+$core[3365]; $inh = 0; goto &fetch; }
$core[006420] = 02004; $code[006420] = *I06420; sub I06420 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[006421] = 05206; $code[006421] = *I06421; sub I06421 { $pc = 006406; $inh = 0; goto &fetch; }
$core[006422] = 01022; $code[006422] = *L06422; sub L06422 { $lac += $core[000022]; goto &fetch; }
$core[006423] = 04512; $code[006423] = *I06423; sub I06423 { $core[($ib<<12)+$core[74]] = 06424; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[006424] = 05206; $code[006424] = *I06424; sub I06424 { $pc = 006406; $inh = 0; goto &fetch; }
$core[006425] = 07040; $code[006425] = *L06425; sub L06425 { $lac ^= 07777; goto &fetch; }
$core[006426] = 01156; $code[006426] = *I06426; sub I06426 { $lac += $core[000156]; goto &fetch; }
$core[006427] = 03156; $code[006427] = *I06427; sub I06427 { $core[000156] = $lac & 07777; $lac &= 010000; $code[000156] = *emul8; goto &fetch; }
$core[006430] = 02157; $code[006430] = *I06430; sub I06430 { if (++$core[000157] == 010000) { $core[000157] = 0; $pc++; }$code[000157] = *emul8; goto &fetch; }
$core[006431] = 05235; $code[006431] = *I06431; sub I06431 { $pc = 006435; $inh = 0; goto &fetch; }
$core[006432] = 07040; $code[006432] = *I06432; sub I06432 { $lac ^= 07777; goto &fetch; }
$core[006433] = 03157; $code[006433] = *I06433; sub I06433 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[006434] = 05216; $code[006434] = *I06434; sub I06434 { $pc = 006416; $inh = 0; goto &fetch; }
$core[006435] = 01412; $code[006435] = *L06435; sub L06435 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac += $core[($df<<12)+$core[000012]]; goto &fetch; }
$core[006436] = 05216; $code[006436] = *I06436; sub I06436 { $pc = 006416; $inh = 0; goto &fetch; }
$core[006437] = 00000; $code[006437] = *S06437; sub S06437 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006440] = 01036; $code[006440] = *I06440; sub I06440 { $lac += $core[000036]; goto &fetch; }
$core[006441] = 04512; $code[006441] = *I06441; sub I06441 { $core[($ib<<12)+$core[74]] = 06442; $pc = ($ib<<12)+$core[74]+1; $code[($ib<<12)+$core[74]] = *emul8; $inh = 0; goto &fetch; }
$core[006442] = 02164; $code[006442] = *I06442; sub I06442 { if (++$core[000164] == 010000) { $core[000164] = 0; $pc++; }$code[000164] = *emul8; goto &fetch; }
$core[006443] = 02237; $code[006443] = *I06443; sub I06443 { if (++$core[006437] == 010000) { $core[006437] = 0; $pc++; }$code[006437] = *emul8; goto &fetch; }
$core[006444] = 05637; $code[006444] = *I06444; sub I06444 { $pc = ($ib<<12)+$core[3359]; $inh = 0; goto &fetch; }
$core[006445] = 06145; $code[006445] = *P06445; sub P06445 { &emul8; goto &fetch; }
$core[006446] = 04521; $code[006446] = *L06446; sub L06446 { $core[($ib<<12)+$core[81]] = 06447; $pc = ($ib<<12)+$core[81]+1; $code[($ib<<12)+$core[81]] = *emul8; $inh = 0; goto &fetch; }
$core[006447] = 04510; $code[006447] = *I06447; sub I06447 { $core[($ib<<12)+$core[72]] = 06450; $pc = ($ib<<12)+$core[72]+1; $code[($ib<<12)+$core[72]] = *emul8; $inh = 0; goto &fetch; }
$core[006450] = 02377; $code[006450] = *I06450; sub I06450 { if (++$core[006577] == 010000) { $core[006577] = 0; $pc++; }$code[006577] = *emul8; goto &fetch; }
$core[006451] = 07574; $code[006451] = *I06451; sub I06451 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[006452] = 04526; $code[006452] = *I06452; sub I06452 { $core[($ib<<12)+$core[86]] = 06453; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[006453] = 07240; $code[006453] = *I06453; sub I06453 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[006454] = 03037; $code[006454] = *I06454; sub I06454 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[006455] = 06014; $code[006455] = *I06455; sub I06455 { &emul8; goto &fetch; }
$core[006456] = 01317; $code[006456] = *I06456; sub I06456 { $lac += $core[006517]; goto &fetch; }
$core[006457] = 01161; $code[006457] = *I06457; sub I06457 { $lac += $core[000161]; goto &fetch; }
$core[006460] = 03113; $code[006460] = *I06460; sub I06460 { $core[000113] = $lac & 07777; $lac &= 010000; $code[000113] = *emul8; goto &fetch; }
$core[006461] = 04565; $code[006461] = *L06461; sub L06461 { $core[($ib<<12)+$core[117]] = 06462; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[006462] = 05261; $code[006462] = *I06462; sub I06462 { $pc = 006461; $inh = 0; goto &fetch; }
$core[006463] = 05665; $code[006463] = *I06463; sub I06463 { $pc = ($ib<<12)+$core[3381]; $inh = 0; goto &fetch; }
$core[006464] = 05246; $code[006464] = *I06464; sub I06464 { $pc = 006446; $inh = 0; goto &fetch; }
$core[006465] = 00616; $code[006465] = *P06465; sub P06465 { $lac &= (010000|$core[($df<<12)+$core[3342]]); goto &fetch; }
$core[006466] = 00000; $code[006466] = *P06466; sub P06466 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006467] = 01067; $code[006467] = *L06467; sub L06467 { $lac += $core[000067]; goto &fetch; }
$core[006470] = 03156; $code[006470] = *I06470; sub I06470 { $core[000156] = $lac & 07777; $lac &= 010000; $code[000156] = *emul8; goto &fetch; }
$core[006471] = 03157; $code[006471] = *I06471; sub I06471 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[006472] = 06001; $code[006472] = *L06472; sub L06472 { &emul8; goto &fetch; }
$core[006473] = 01037; $code[006473] = *I06473; sub I06473 { $lac += $core[000037]; goto &fetch; }
$core[006474] = 07700; $code[006474] = *I06474; sub I06474 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006475] = 05306; $code[006475] = *I06475; sub I06475 { $pc = 006506; $inh = 0; goto &fetch; }
$core[006476] = 02157; $code[006476] = *I06476; sub I06476 { if (++$core[000157] == 010000) { $core[000157] = 0; $pc++; }$code[000157] = *emul8; goto &fetch; }
$core[006477] = 05272; $code[006477] = *I06477; sub I06477 { $pc = 006472; $inh = 0; goto &fetch; }
$core[006500] = 02156; $code[006500] = *I06500; sub I06500 { if (++$core[000156] == 010000) { $core[000156] = 0; $pc++; }$code[000156] = *emul8; goto &fetch; }
$core[006501] = 05272; $code[006501] = *I06501; sub I06501 { $pc = 006472; $inh = 0; goto &fetch; }
$core[006502] = 01161; $code[006502] = *I06502; sub I06502 { $lac += $core[000161]; goto &fetch; }
$core[006503] = 03113; $code[006503] = *I06503; sub I06503 { $core[000113] = $lac & 07777; $lac &= 010000; $code[000113] = *emul8; goto &fetch; }
$core[006504] = 01054; $code[006504] = *I06504; sub I06504 { $lac += $core[000054]; goto &fetch; }
$core[006505] = 05315; $code[006505] = *I06505; sub I06505 { $pc = 006515; $inh = 0; goto &fetch; }
$core[006506] = 07040; $code[006506] = *L06506; sub L06506 { $lac ^= 07777; goto &fetch; }
$core[006507] = 03037; $code[006507] = *I06507; sub I06507 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[006510] = 06016; $code[006510] = *I06510; sub I06510 { &emul8; goto &fetch; }
$core[006511] = 00026; $code[006511] = *I06511; sub I06511 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[006512] = 07450; $code[006512] = *I06512; sub I06512 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006513] = 05267; $code[006513] = *I06513; sub I06513 { $pc = 006467; $inh = 0; goto &fetch; }
$core[006514] = 01015; $code[006514] = *I06514; sub I06514 { $lac += $core[000015]; goto &fetch; }
$core[006515] = 03142; $code[006515] = *L06515; sub L06515 { $core[000142] = $lac & 07777; $lac &= 010000; $code[000142] = *emul8; goto &fetch; }
$core[006516] = 05666; $code[006516] = *I06516; sub I06516 { $pc = ($ib<<12)+$core[3382]; $inh = 0; goto &fetch; }
$core[006517] = 04003; $code[006517] = *D06517; sub D06517 { $core[000003] = 06520; $pc = 000003+1; $code[000003] = *emul8; $inh = 0; goto &fetch; }
$core[006600] = 00000; $code[006600] = *S06600; sub S06600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006601] = 07300; $code[006601] = *L06601; sub L06601 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006602] = 01600; $code[006602] = *I06602; sub I06602 { $lac += $core[($df<<12)+$core[3456]]; goto &fetch; }
$core[006603] = 07450; $code[006603] = *I06603; sub I06603 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006604] = 05600; $code[006604] = *I06604; sub I06604 { $pc = ($ib<<12)+$core[3456]; $inh = 0; goto &fetch; }
$core[006605] = 00015; $code[006605] = *I06605; sub I06605 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[006606] = 07640; $code[006606] = *I06606; sub I06606 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006607] = 01200; $code[006607] = *I06607; sub I06607 { $lac += $core[006600]; goto &fetch; }
$core[006610] = 00024; $code[006610] = *I06610; sub I06610 { $lac &= (010000|$core[000024]); goto &fetch; }
$core[006611] = 03231; $code[006611] = *I06611; sub I06611 { $core[006631] = $lac & 07777; $lac &= 010000; $code[006631] = *emul8; goto &fetch; }
$core[006612] = 01600; $code[006612] = *I06612; sub I06612 { $lac += $core[($df<<12)+$core[3456]]; goto &fetch; }
$core[006613] = 00026; $code[006613] = *I06613; sub I06613 { $lac &= (010000|$core[000026]); goto &fetch; }
$core[006614] = 01231; $code[006614] = *I06614; sub I06614 { $lac += $core[006631]; goto &fetch; }
$core[006615] = 03231; $code[006615] = *I06615; sub I06615 { $core[006631] = $lac & 07777; $lac &= 010000; $code[006631] = *emul8; goto &fetch; }
$core[006616] = 01600; $code[006616] = *I06616; sub I06616 { $lac += $core[($df<<12)+$core[3456]]; goto &fetch; }
$core[006617] = 02200; $code[006617] = *I06617; sub I06617 { if (++$core[006600] == 010000) { $core[006600] = 0; $pc++; }$code[006600] = *emul8; goto &fetch; }
$core[006620] = 07106; $code[006620] = *I06620; sub I06620 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[006621] = 07006; $code[006621] = *I06621; sub I06621 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[006622] = 00031; $code[006622] = *I06622; sub I06622 { $lac &= (010000|$core[000031]); goto &fetch; }
$core[006623] = 01236; $code[006623] = *I06623; sub I06623 { $lac += $core[006636]; goto &fetch; }
$core[006624] = 03235; $code[006624] = *I06624; sub I06624 { $core[006635] = $lac & 07777; $lac &= 010000; $code[006635] = *emul8; goto &fetch; }
$core[006625] = 01631; $code[006625] = *I06625; sub I06625 { $lac += $core[($df<<12)+$core[3481]]; goto &fetch; }
$core[006626] = 07430; $code[006626] = *I06626; sub I06626 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006627] = 03231; $code[006627] = *I06627; sub I06627 { $core[006631] = $lac & 07777; $lac &= 010000; $code[006631] = *emul8; goto &fetch; }
$core[006630] = 04504; $code[006630] = *I06630; sub I06630 { $core[($ib<<12)+$core[68]] = 06631; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[006631] = 00000; $code[006631] = *P06631; sub P06631 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006632] = 04505; $code[006632] = *I06632; sub I06632 { $core[($ib<<12)+$core[69]] = 06633; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[006633] = 00040; $code[006633] = *I06633; sub I06633 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[006634] = 03043; $code[006634] = *I06634; sub I06634 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006635] = 05637; $code[006635] = *D06635; sub D06635 { $pc = ($ib<<12)+$core[3487]; $inh = 0; goto &fetch; }
$core[006636] = 05637; $code[006636] = *D06636; sub D06636 { $pc = ($ib<<12)+$core[3487]; $inh = 0; goto &fetch; }
$core[006637] = 07406; $code[006637] = *P06637; sub P06637 { $lac |= $swr; $hlt = 1; goto &fetch; }
$core[006640] = 06720; $code[006640] = *I06640; sub I06640 { &emul8; goto &fetch; }
$core[006641] = 06717; $code[006641] = *I06641; sub I06641 { &emul8; goto &fetch; }
$core[006642] = 07077; $code[006642] = *I06642; sub I06642 { $lac ^= 010000; $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006643] = 07171; $code[006643] = *I06643; sub I06643 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006644] = 06647; $code[006644] = *I06644; sub I06644 { &emul8; goto &fetch; }
$core[006645] = 06653; $code[006645] = *I06645; sub I06645 { &emul8; goto &fetch; }
$core[006646] = 06762; $code[006646] = *I06646; sub I06646 { &emul8; goto &fetch; }
$core[006647] = 04504; $code[006647] = *L06647; sub L06647 { $core[($ib<<12)+$core[68]] = 06650; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[006650] = 00040; $code[006650] = *I06650; sub I06650 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[006651] = 01254; $code[006651] = *I06651; sub I06651 { $lac += $core[006654]; goto &fetch; }
$core[006652] = 05256; $code[006652] = *I06652; sub I06652 { $pc = 006656; $inh = 0; goto &fetch; }
$core[006653] = 04504; $code[006653] = *I06653; sub I06653 { $core[($ib<<12)+$core[68]] = 06654; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[006654] = 00044; $code[006654] = *D06654; sub D06654 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[006655] = 01231; $code[006655] = *I06655; sub I06655 { $lac += $core[006631]; goto &fetch; }
$core[006656] = 03260; $code[006656] = *L06656; sub L06656 { $core[006660] = $lac & 07777; $lac &= 010000; $code[006660] = *emul8; goto &fetch; }
$core[006657] = 04505; $code[006657] = *I06657; sub I06657 { $core[($ib<<12)+$core[69]] = 06660; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[006660] = 00000; $code[006660] = *D06660; sub D06660 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006661] = 05201; $code[006661] = *I06661; sub I06661 { $pc = 006601; $inh = 0; goto &fetch; }
$core[006662] = 00000; $code[006662] = *S06662; sub S06662 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006663] = 01042; $code[006663] = *I06663; sub I06663 { $lac += $core[000042]; goto &fetch; }
$core[006664] = 07141; $code[006664] = *I06664; sub I06664 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[006665] = 03042; $code[006665] = *I06665; sub I06665 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[006666] = 07024; $code[006666] = *I06666; sub I06666 { $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006667] = 01041; $code[006667] = *I06667; sub I06667 { $lac += $core[000041]; goto &fetch; }
$core[006670] = 07041; $code[006670] = *I06670; sub I06670 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006671] = 03041; $code[006671] = *I06671; sub I06671 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[006672] = 01004; $code[006672] = *I06672; sub I06672 { $lac += $core[000004]; goto &fetch; }
$core[006673] = 07140; $code[006673] = *I06673; sub I06673 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006674] = 03004; $code[006674] = *I06674; sub I06674 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[006675] = 05662; $code[006675] = *I06675; sub I06675 { $pc = ($ib<<12)+$core[3506]; $inh = 0; goto &fetch; }
$core[006676] = 00000; $code[006676] = *S06676; sub S06676 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006677] = 07300; $code[006677] = *I06677; sub I06677 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006700] = 01047; $code[006700] = *I06700; sub I06700 { $lac += $core[000047]; goto &fetch; }
$core[006701] = 07041; $code[006701] = *I06701; sub I06701 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006702] = 03047; $code[006702] = *I06702; sub I06702 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[006703] = 07024; $code[006703] = *I06703; sub I06703 { $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006704] = 01046; $code[006704] = *I06704; sub I06704 { $lac += $core[000046]; goto &fetch; }
$core[006705] = 07041; $code[006705] = *I06705; sub I06705 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006706] = 03046; $code[006706] = *I06706; sub I06706 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006707] = 07024; $code[006707] = *I06707; sub I06707 { $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006710] = 01045; $code[006710] = *I06710; sub I06710 { $lac += $core[000045]; goto &fetch; }
$core[006711] = 07041; $code[006711] = *I06711; sub I06711 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006712] = 03045; $code[006712] = *I06712; sub I06712 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006713] = 01004; $code[006713] = *P06713; sub P06713 { $lac += $core[000004]; goto &fetch; }
$core[006714] = 07140; $code[006714] = *I06714; sub I06714 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006715] = 03004; $code[006715] = *I06715; sub I06715 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[006716] = 05676; $code[006716] = *I06716; sub I06716 { $pc = ($ib<<12)+$core[3518]; $inh = 0; goto &fetch; }
$core[006717] = 04262; $code[006717] = *I06717; sub I06717 { $core[006662] = 06720; $pc = 006662+1; $code[006662] = *emul8; $inh = 0; goto &fetch; }
$core[006720] = 01045; $code[006720] = *I06720; sub I06720 { $lac += $core[000045]; goto &fetch; }
$core[006721] = 07650; $code[006721] = *I06721; sub I06721 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006722] = 05247; $code[006722] = *I06722; sub I06722 { $pc = 006647; $inh = 0; goto &fetch; }
$core[006723] = 01041; $code[006723] = *I06723; sub I06723 { $lac += $core[000041]; goto &fetch; }
$core[006724] = 07650; $code[006724] = *I06724; sub I06724 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006725] = 05201; $code[006725] = *I06725; sub I06725 { $pc = 006601; $inh = 0; goto &fetch; }
$core[006726] = 01040; $code[006726] = *I06726; sub I06726 { $lac += $core[000040]; goto &fetch; }
$core[006727] = 07041; $code[006727] = *I06727; sub I06727 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006730] = 01044; $code[006730] = *D06730; sub D06730 { $lac += $core[000044]; goto &fetch; }
$core[006731] = 07450; $code[006731] = *I06731; sub I06731 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006732] = 05357; $code[006732] = *I06732; sub I06732 { $pc = 006757; $inh = 0; goto &fetch; }
$core[006733] = 07500; $code[006733] = *I06733; sub I06733 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006734] = 05346; $code[006734] = *I06734; sub I06734 { $pc = 006746; $inh = 0; goto &fetch; }
$core[006735] = 01365; $code[006735] = *I06735; sub I06735 { $lac += $core[006765]; goto &fetch; }
$core[006736] = 07510; $code[006736] = *I06736; sub I06736 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006737] = 05247; $code[006737] = *I06737; sub I06737 { $pc = 006647; $inh = 0; goto &fetch; }
$core[006740] = 01364; $code[006740] = *I06740; sub I06740 { $lac += $core[006764]; goto &fetch; }
$core[006741] = 03235; $code[006741] = *I06741; sub I06741 { $core[006635] = $lac & 07777; $lac &= 010000; $code[006635] = *emul8; goto &fetch; }
$core[006742] = 04767; $code[006742] = *L06742; sub L06742 { $core[($ib<<12)+$core[3575]] = 06743; $pc = ($ib<<12)+$core[3575]+1; $code[($ib<<12)+$core[3575]] = *emul8; $inh = 0; goto &fetch; }
$core[006743] = 02235; $code[006743] = *I06743; sub I06743 { if (++$core[006635] == 010000) { $core[006635] = 0; $pc++; }$code[006635] = *emul8; goto &fetch; }
$core[006744] = 05342; $code[006744] = *I06744; sub I06744 { $pc = 006742; $inh = 0; goto &fetch; }
$core[006745] = 05357; $code[006745] = *D06745; sub D06745 { $pc = 006757; $inh = 0; goto &fetch; }
$core[006746] = 07041; $code[006746] = *L06746; sub L06746 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006747] = 01365; $code[006747] = *D06747; sub D06747 { $lac += $core[006765]; goto &fetch; }
$core[006750] = 07510; $code[006750] = *I06750; sub I06750 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006751] = 05201; $code[006751] = *I06751; sub I06751 { $pc = 006601; $inh = 0; goto &fetch; }
$core[006752] = 01364; $code[006752] = *I06752; sub I06752 { $lac += $core[006764]; goto &fetch; }
$core[006753] = 03235; $code[006753] = *I06753; sub I06753 { $core[006635] = $lac & 07777; $lac &= 010000; $code[006635] = *emul8; goto &fetch; }
$core[006754] = 04766; $code[006754] = *L06754; sub L06754 { $core[($ib<<12)+$core[3574]] = 06755; $pc = ($ib<<12)+$core[3574]+1; $code[($ib<<12)+$core[3574]] = *emul8; $inh = 0; goto &fetch; }
$core[006755] = 02235; $code[006755] = *I06755; sub I06755 { if (++$core[006635] == 010000) { $core[006635] = 0; $pc++; }$code[006635] = *emul8; goto &fetch; }
$core[006756] = 05354; $code[006756] = *I06756; sub I06756 { $pc = 006754; $inh = 0; goto &fetch; }
$core[006757] = 04767; $code[006757] = *L06757; sub L06757 { $core[($ib<<12)+$core[3575]] = 06760; $pc = ($ib<<12)+$core[3575]+1; $code[($ib<<12)+$core[3575]] = *emul8; $inh = 0; goto &fetch; }
$core[006760] = 04766; $code[006760] = *I06760; sub I06760 { $core[($ib<<12)+$core[3574]] = 06761; $pc = ($ib<<12)+$core[3574]+1; $code[($ib<<12)+$core[3574]] = *emul8; $inh = 0; goto &fetch; }
$core[006761] = 04770; $code[006761] = *I06761; sub I06761 { $core[($ib<<12)+$core[3576]] = 06762; $pc = ($ib<<12)+$core[3576]+1; $code[($ib<<12)+$core[3576]] = *emul8; $inh = 0; goto &fetch; }
$core[006762] = 04771; $code[006762] = *I06762; sub I06762 { $core[($ib<<12)+$core[3577]] = 06763; $pc = ($ib<<12)+$core[3577]+1; $code[($ib<<12)+$core[3577]] = *emul8; $inh = 0; goto &fetch; }
$core[006763] = 05201; $code[006763] = *I06763; sub I06763 { $pc = 006601; $inh = 0; goto &fetch; }
$core[006764] = 07751; $code[006764] = *D06764; sub D06764 { &emul8; goto &fetch; }
$core[006765] = 00027; $code[006765] = *D06765; sub D06765 { $lac &= (010000|$core[000027]); goto &fetch; }
$core[006766] = 07271; $code[006766] = *P06766; sub P06766 { $lac &= 010000; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006767] = 07251; $code[006767] = *P06767; sub P06767 { $lac &= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006770] = 05713; $code[006770] = *P06770; sub P06770 { $pc = ($ib<<12)+$core[3531]; $inh = 0; goto &fetch; }
$core[006771] = 07000; $code[006771] = *P06771; sub P06771 { goto &fetch; }
$core[006772] = 03347; $code[006772] = *I06772; sub I06772 { $core[006747] = $lac & 07777; $lac &= 010000; $code[006747] = *emul8; goto &fetch; }
$core[006773] = 03347; $code[006773] = *I06773; sub I06773 { $core[006747] = $lac & 07777; $lac &= 010000; $code[006747] = *emul8; goto &fetch; }
$core[006774] = 03330; $code[006774] = *I06774; sub I06774 { $core[006730] = $lac & 07777; $lac &= 010000; $code[006730] = *emul8; goto &fetch; }
$core[006775] = 03347; $code[006775] = *I06775; sub I06775 { $core[006747] = $lac & 07777; $lac &= 010000; $code[006747] = *emul8; goto &fetch; }
$core[006776] = 03347; $code[006776] = *I06776; sub I06776 { $core[006747] = $lac & 07777; $lac &= 010000; $code[006747] = *emul8; goto &fetch; }
$core[006777] = 03345; $code[006777] = *I06777; sub I06777 { $core[006745] = $lac & 07777; $lac &= 010000; $code[006745] = *emul8; goto &fetch; }
$core[007000] = 00000; $code[007000] = *S07000; sub S07000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007001] = 07340; $code[007001] = *I07001; sub I07001 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[007002] = 03004; $code[007002] = *I07002; sub I07002 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[007003] = 01045; $code[007003] = *I07003; sub I07003 { $lac += $core[000045]; goto &fetch; }
$core[007004] = 07450; $code[007004] = *I07004; sub I07004 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007005] = 01046; $code[007005] = *I07005; sub I07005 { $lac += $core[000046]; goto &fetch; }
$core[007006] = 07450; $code[007006] = *I07006; sub I07006 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007007] = 01047; $code[007007] = *I07007; sub I07007 { $lac += $core[000047]; goto &fetch; }
$core[007010] = 07650; $code[007010] = *I07010; sub I07010 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007011] = 05232; $code[007011] = *I07011; sub I07011 { $pc = 007032; $inh = 0; goto &fetch; }
$core[007012] = 01045; $code[007012] = *I07012; sub I07012 { $lac += $core[000045]; goto &fetch; }
$core[007013] = 07710; $code[007013] = *I07013; sub I07013 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007014] = 04450; $code[007014] = *I07014; sub I07014 { $core[($ib<<12)+$core[40]] = 07015; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007015] = 03255; $code[007015] = *I07015; sub I07015 { $core[007055] = $lac & 07777; $lac &= 010000; $code[007055] = *emul8; goto &fetch; }
$core[007016] = 01045; $code[007016] = *L07016; sub L07016 { $lac += $core[000045]; goto &fetch; }
$core[007017] = 07104; $code[007017] = *I07017; sub I07017 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007020] = 07710; $code[007020] = *I07020; sub I07020 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007021] = 05225; $code[007021] = *I07021; sub I07021 { $pc = 007025; $inh = 0; goto &fetch; }
$core[007022] = 04237; $code[007022] = *I07022; sub I07022 { $core[007037] = 07023; $pc = 007037+1; $code[007037] = *emul8; $inh = 0; goto &fetch; }
$core[007023] = 02255; $code[007023] = *I07023; sub I07023 { if (++$core[007055] == 010000) { $core[007055] = 0; $pc++; }$code[007055] = *emul8; goto &fetch; }
$core[007024] = 05216; $code[007024] = *I07024; sub I07024 { $pc = 007016; $inh = 0; goto &fetch; }
$core[007025] = 02004; $code[007025] = *L07025; sub L07025 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[007026] = 04450; $code[007026] = *I07026; sub I07026 { $core[($ib<<12)+$core[40]] = 07027; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007027] = 01255; $code[007027] = *I07027; sub I07027 { $lac += $core[007055]; goto &fetch; }
$core[007030] = 07041; $code[007030] = *I07030; sub I07030 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007031] = 01044; $code[007031] = *I07031; sub I07031 { $lac += $core[000044]; goto &fetch; }
$core[007032] = 03044; $code[007032] = *L07032; sub L07032 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007033] = 03047; $code[007033] = *I07033; sub I07033 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007034] = 05600; $code[007034] = *I07034; sub I07034 { $pc = ($ib<<12)+$core[3584]; $inh = 0; goto &fetch; }
$core[007035] = 06601; $code[007035] = *P07035; sub P07035 { &emul8; goto &fetch; }
$core[007036] = 06662; $code[007036] = *P07036; sub P07036 { &emul8; goto &fetch; }
$core[007037] = 00000; $code[007037] = *S07037; sub S07037 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007040] = 01047; $code[007040] = *I07040; sub I07040 { $lac += $core[000047]; goto &fetch; }
$core[007041] = 07104; $code[007041] = *I07041; sub I07041 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007042] = 03047; $code[007042] = *I07042; sub I07042 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007043] = 04245; $code[007043] = *I07043; sub I07043 { $core[007045] = 07044; $pc = 007045+1; $code[007045] = *emul8; $inh = 0; goto &fetch; }
$core[007044] = 05637; $code[007044] = *I07044; sub I07044 { $pc = ($ib<<12)+$core[3615]; $inh = 0; goto &fetch; }
$core[007045] = 00000; $code[007045] = *S07045; sub S07045 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007046] = 01046; $code[007046] = *I07046; sub I07046 { $lac += $core[000046]; goto &fetch; }
$core[007047] = 07004; $code[007047] = *I07047; sub I07047 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007050] = 03046; $code[007050] = *I07050; sub I07050 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007051] = 01045; $code[007051] = *I07051; sub I07051 { $lac += $core[000045]; goto &fetch; }
$core[007052] = 07004; $code[007052] = *I07052; sub I07052 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007053] = 03045; $code[007053] = *I07053; sub I07053 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007054] = 05645; $code[007054] = *I07054; sub I07054 { $pc = ($ib<<12)+$core[3621]; $inh = 0; goto &fetch; }
$core[007055] = 00000; $code[007055] = *S07055; sub S07055 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007056] = 07340; $code[007056] = *I07056; sub I07056 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[007057] = 03004; $code[007057] = *I07057; sub I07057 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[007060] = 01045; $code[007060] = *I07060; sub I07060 { $lac += $core[000045]; goto &fetch; }
$core[007061] = 07450; $code[007061] = *I07061; sub I07061 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007062] = 05635; $code[007062] = *I07062; sub I07062 { $pc = ($ib<<12)+$core[3613]; $inh = 0; goto &fetch; }
$core[007063] = 07710; $code[007063] = *D07063; sub D07063 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007064] = 04450; $code[007064] = *I07064; sub I07064 { $core[($ib<<12)+$core[40]] = 07065; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007065] = 01045; $code[007065] = *I07065; sub I07065 { $lac += $core[000045]; goto &fetch; }
$core[007066] = 03162; $code[007066] = *I07066; sub I07066 { $core[000162] = $lac & 07777; $lac &= 010000; $code[000162] = *emul8; goto &fetch; }
$core[007067] = 01046; $code[007067] = *I07067; sub I07067 { $lac += $core[000046]; goto &fetch; }
$core[007070] = 03163; $code[007070] = *I07070; sub I07070 { $core[000163] = $lac & 07777; $lac &= 010000; $code[000163] = *emul8; goto &fetch; }
$core[007071] = 01041; $code[007071] = *I07071; sub I07071 { $lac += $core[000041]; goto &fetch; }
$core[007072] = 07710; $code[007072] = *D07072; sub D07072 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007073] = 04636; $code[007073] = *I07073; sub I07073 { $core[($ib<<12)+$core[3614]] = 07074; $pc = ($ib<<12)+$core[3614]+1; $code[($ib<<12)+$core[3614]] = *emul8; $inh = 0; goto &fetch; }
$core[007074] = 01004; $code[007074] = *I07074; sub I07074 { $lac += $core[000004]; goto &fetch; }
$core[007075] = 03157; $code[007075] = *I07075; sub I07075 { $core[000157] = $lac & 07777; $lac &= 010000; $code[000157] = *emul8; goto &fetch; }
$core[007076] = 05655; $code[007076] = *I07076; sub I07076 { $pc = ($ib<<12)+$core[3629]; $inh = 0; goto &fetch; }
$core[007077] = 01263; $code[007077] = *I07077; sub I07077 { $lac += $core[007063]; goto &fetch; }
$core[007100] = 03272; $code[007100] = *I07100; sub I07100 { $core[007072] = $lac & 07777; $lac &= 010000; $code[007072] = *emul8; goto &fetch; }
$core[007101] = 04255; $code[007101] = *I07101; sub I07101 { $core[007055] = 07102; $pc = 007055+1; $code[007055] = *emul8; $inh = 0; goto &fetch; }
$core[007102] = 01042; $code[007102] = *I07102; sub I07102 { $lac += $core[000042]; goto &fetch; }
$core[007103] = 04333; $code[007103] = *I07103; sub I07103 { $core[007133] = 07104; $pc = 007133+1; $code[007133] = *emul8; $inh = 0; goto &fetch; }
$core[007104] = 07301; $code[007104] = *I07104; sub I07104 { $lac &= 010000; $lac &= 07777; $lac++; goto &fetch; }
$core[007105] = 01044; $code[007105] = *I07105; sub I07105 { $lac += $core[000044]; goto &fetch; }
$core[007106] = 01040; $code[007106] = *I07106; sub I07106 { $lac += $core[000040]; goto &fetch; }
$core[007107] = 03044; $code[007107] = *I07107; sub I07107 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007110] = 01272; $code[007110] = *I07110; sub I07110 { $lac += $core[007072]; goto &fetch; }
$core[007111] = 03047; $code[007111] = *I07111; sub I07111 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007112] = 01237; $code[007112] = *I07112; sub I07112 { $lac += $core[007037]; goto &fetch; }
$core[007113] = 03046; $code[007113] = *I07113; sub I07113 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007114] = 01041; $code[007114] = *I07114; sub I07114 { $lac += $core[000041]; goto &fetch; }
$core[007115] = 04333; $code[007115] = *I07115; sub I07115 { $core[007133] = 07116; $pc = 007133+1; $code[007133] = *emul8; $inh = 0; goto &fetch; }
$core[007116] = 01047; $code[007116] = *I07116; sub I07116 { $lac += $core[000047]; goto &fetch; }
$core[007117] = 03047; $code[007117] = *I07117; sub I07117 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007120] = 07004; $code[007120] = *I07120; sub I07120 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007121] = 01272; $code[007121] = *I07121; sub I07121 { $lac += $core[007072]; goto &fetch; }
$core[007122] = 01046; $code[007122] = *I07122; sub I07122 { $lac += $core[000046]; goto &fetch; }
$core[007123] = 03046; $code[007123] = *I07123; sub I07123 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007124] = 07004; $code[007124] = *I07124; sub I07124 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007125] = 01237; $code[007125] = *I07125; sub I07125 { $lac += $core[007037]; goto &fetch; }
$core[007126] = 03045; $code[007126] = *I07126; sub I07126 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007127] = 04200; $code[007127] = *I07127; sub I07127 { $core[007000] = 07130; $pc = 007000+1; $code[007000] = *emul8; $inh = 0; goto &fetch; }
$core[007130] = 02157; $code[007130] = *L07130; sub L07130 { if (++$core[000157] == 010000) { $core[000157] = 0; $pc++; }$code[000157] = *emul8; goto &fetch; }
$core[007131] = 04450; $code[007131] = *I07131; sub I07131 { $core[($ib<<12)+$core[40]] = 07132; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007132] = 05635; $code[007132] = *I07132; sub I07132 { $pc = ($ib<<12)+$core[3613]; $inh = 0; goto &fetch; }
$core[007133] = 00000; $code[007133] = *S07133; sub S07133 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007134] = 03200; $code[007134] = *I07134; sub I07134 { $core[007000] = $lac & 07777; $lac &= 010000; $code[007000] = *emul8; goto &fetch; }
$core[007135] = 03237; $code[007135] = *I07135; sub I07135 { $core[007037] = $lac & 07777; $lac &= 010000; $code[007037] = *emul8; goto &fetch; }
$core[007136] = 03272; $code[007136] = *I07136; sub I07136 { $core[007072] = $lac & 07777; $lac &= 010000; $code[007072] = *emul8; goto &fetch; }
$core[007137] = 01370; $code[007137] = *I07137; sub I07137 { $lac += $core[007170]; goto &fetch; }
$core[007140] = 03255; $code[007140] = *I07140; sub I07140 { $core[007055] = $lac & 07777; $lac &= 010000; $code[007055] = *emul8; goto &fetch; }
$core[007141] = 07100; $code[007141] = *I07141; sub I07141 { $lac &= 07777; goto &fetch; }
$core[007142] = 01200; $code[007142] = *L07142; sub L07142 { $lac += $core[007000]; goto &fetch; }
$core[007143] = 07010; $code[007143] = *I07143; sub I07143 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007144] = 03200; $code[007144] = *I07144; sub I07144 { $core[007000] = $lac & 07777; $lac &= 010000; $code[007000] = *emul8; goto &fetch; }
$core[007145] = 07420; $code[007145] = *I07145; sub I07145 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[007146] = 05355; $code[007146] = *I07146; sub I07146 { $pc = 007155; $inh = 0; goto &fetch; }
$core[007147] = 07100; $code[007147] = *I07147; sub I07147 { $lac &= 07777; goto &fetch; }
$core[007150] = 01163; $code[007150] = *I07150; sub I07150 { $lac += $core[000163]; goto &fetch; }
$core[007151] = 01272; $code[007151] = *I07151; sub I07151 { $lac += $core[007072]; goto &fetch; }
$core[007152] = 03272; $code[007152] = *I07152; sub I07152 { $core[007072] = $lac & 07777; $lac &= 010000; $code[007072] = *emul8; goto &fetch; }
$core[007153] = 07004; $code[007153] = *I07153; sub I07153 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007154] = 01162; $code[007154] = *I07154; sub I07154 { $lac += $core[000162]; goto &fetch; }
$core[007155] = 01237; $code[007155] = *L07155; sub L07155 { $lac += $core[007037]; goto &fetch; }
$core[007156] = 07010; $code[007156] = *I07156; sub I07156 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007157] = 03237; $code[007157] = *I07157; sub I07157 { $core[007037] = $lac & 07777; $lac &= 010000; $code[007037] = *emul8; goto &fetch; }
$core[007160] = 01272; $code[007160] = *I07160; sub I07160 { $lac += $core[007072]; goto &fetch; }
$core[007161] = 07010; $code[007161] = *I07161; sub I07161 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007162] = 03272; $code[007162] = *I07162; sub I07162 { $core[007072] = $lac & 07777; $lac &= 010000; $code[007072] = *emul8; goto &fetch; }
$core[007163] = 02255; $code[007163] = *I07163; sub I07163 { if (++$core[007055] == 010000) { $core[007055] = 0; $pc++; }$code[007055] = *emul8; goto &fetch; }
$core[007164] = 05342; $code[007164] = *I07164; sub I07164 { $pc = 007142; $inh = 0; goto &fetch; }
$core[007165] = 01200; $code[007165] = *I07165; sub I07165 { $lac += $core[007000]; goto &fetch; }
$core[007166] = 07010; $code[007166] = *I07166; sub I07166 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007167] = 05733; $code[007167] = *I07167; sub I07167 { $pc = ($ib<<12)+$core[3675]; $inh = 0; goto &fetch; }
$core[007170] = 07764; $code[007170] = *D07170; sub D07170 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007171] = 01041; $code[007171] = *I07171; sub I07171 { $lac += $core[000041]; goto &fetch; }
$core[007172] = 07650; $code[007172] = *I07172; sub I07172 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007173] = 04526; $code[007173] = *I07173; sub I07173 { $core[($ib<<12)+$core[86]] = 07174; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[007174] = 01062; $code[007174] = *I07174; sub I07174 { $lac += $core[000062]; goto &fetch; }
$core[007175] = 03272; $code[007175] = *I07175; sub I07175 { $core[007072] = $lac & 07777; $lac &= 010000; $code[007072] = *emul8; goto &fetch; }
$core[007176] = 04255; $code[007176] = *I07176; sub I07176 { $core[007055] = 07177; $pc = 007055+1; $code[007055] = *emul8; $inh = 0; goto &fetch; }
$core[007177] = 01040; $code[007177] = *I07177; sub I07177 { $lac += $core[000040]; goto &fetch; }
$core[007200] = 07041; $code[007200] = *I07200; sub I07200 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007201] = 01044; $code[007201] = *I07201; sub I07201 { $lac += $core[000044]; goto &fetch; }
$core[007202] = 07001; $code[007202] = *I07202; sub I07202 { $lac++; goto &fetch; }
$core[007203] = 03044; $code[007203] = *I07203; sub I07203 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007204] = 03045; $code[007204] = *I07204; sub I07204 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007205] = 03046; $code[007205] = *I07205; sub I07205 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007206] = 01314; $code[007206] = *I07206; sub I07206 { $lac += $core[007314]; goto &fetch; }
$core[007207] = 03271; $code[007207] = *I07207; sub I07207 { $core[007271] = $lac & 07777; $lac &= 010000; $code[007271] = *emul8; goto &fetch; }
$core[007210] = 05226; $code[007210] = *I07210; sub I07210 { $pc = 007226; $inh = 0; goto &fetch; }
$core[007211] = 07420; $code[007211] = *L07211; sub L07211 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[007212] = 05216; $code[007212] = *I07212; sub I07212 { $pc = 007216; $inh = 0; goto &fetch; }
$core[007213] = 03162; $code[007213] = *I07213; sub I07213 { $core[000162] = $lac & 07777; $lac &= 010000; $code[000162] = *emul8; goto &fetch; }
$core[007214] = 01164; $code[007214] = *I07214; sub I07214 { $lac += $core[000164]; goto &fetch; }
$core[007215] = 03163; $code[007215] = *I07215; sub I07215 { $core[000163] = $lac & 07777; $lac &= 010000; $code[000163] = *emul8; goto &fetch; }
$core[007216] = 07200; $code[007216] = *L07216; sub L07216 { $lac &= 010000; goto &fetch; }
$core[007217] = 04647; $code[007217] = *I07217; sub I07217 { $core[($ib<<12)+$core[3751]] = 07220; $pc = ($ib<<12)+$core[3751]+1; $code[($ib<<12)+$core[3751]] = *emul8; $inh = 0; goto &fetch; }
$core[007220] = 01163; $code[007220] = *I07220; sub I07220 { $lac += $core[000163]; goto &fetch; }
$core[007221] = 07004; $code[007221] = *I07221; sub I07221 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007222] = 03163; $code[007222] = *I07222; sub I07222 { $core[000163] = $lac & 07777; $lac &= 010000; $code[000163] = *emul8; goto &fetch; }
$core[007223] = 01162; $code[007223] = *I07223; sub I07223 { $lac += $core[000162]; goto &fetch; }
$core[007224] = 07004; $code[007224] = *I07224; sub I07224 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007225] = 03162; $code[007225] = *I07225; sub I07225 { $core[000162] = $lac & 07777; $lac &= 010000; $code[000162] = *emul8; goto &fetch; }
$core[007226] = 07100; $code[007226] = *L07226; sub L07226 { $lac &= 07777; goto &fetch; }
$core[007227] = 01042; $code[007227] = *I07227; sub I07227 { $lac += $core[000042]; goto &fetch; }
$core[007230] = 01163; $code[007230] = *I07230; sub I07230 { $lac += $core[000163]; goto &fetch; }
$core[007231] = 03164; $code[007231] = *I07231; sub I07231 { $core[000164] = $lac & 07777; $lac &= 010000; $code[000164] = *emul8; goto &fetch; }
$core[007232] = 07004; $code[007232] = *I07232; sub I07232 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007233] = 01041; $code[007233] = *I07233; sub I07233 { $lac += $core[000041]; goto &fetch; }
$core[007234] = 01162; $code[007234] = *I07234; sub I07234 { $lac += $core[000162]; goto &fetch; }
$core[007235] = 02271; $code[007235] = *I07235; sub I07235 { if (++$core[007271] == 010000) { $core[007271] = 0; $pc++; }$code[007271] = *emul8; goto &fetch; }
$core[007236] = 05211; $code[007236] = *I07236; sub I07236 { $pc = 007211; $inh = 0; goto &fetch; }
$core[007237] = 07210; $code[007237] = *I07237; sub I07237 { $lac &= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007240] = 03047; $code[007240] = *I07240; sub I07240 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007241] = 04650; $code[007241] = *I07241; sub I07241 { $core[($ib<<12)+$core[3752]] = 07242; $pc = ($ib<<12)+$core[3752]+1; $code[($ib<<12)+$core[3752]] = *emul8; $inh = 0; goto &fetch; }
$core[007242] = 02157; $code[007242] = *I07242; sub I07242 { if (++$core[000157] == 010000) { $core[000157] = 0; $pc++; }$code[000157] = *emul8; goto &fetch; }
$core[007243] = 05646; $code[007243] = *I07243; sub I07243 { $pc = ($ib<<12)+$core[3750]; $inh = 0; goto &fetch; }
$core[007244] = 04450; $code[007244] = *I07244; sub I07244 { $core[($ib<<12)+$core[40]] = 07245; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007245] = 05646; $code[007245] = *I07245; sub I07245 { $pc = ($ib<<12)+$core[3750]; $inh = 0; goto &fetch; }
$core[007246] = 06601; $code[007246] = *P07246; sub P07246 { &emul8; goto &fetch; }
$core[007247] = 07045; $code[007247] = *P07247; sub P07247 { $lac ^= 07777; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007250] = 07000; $code[007250] = *P07250; sub P07250 { goto &fetch; }
$core[007251] = 00000; $code[007251] = *S07251; sub S07251 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007252] = 07300; $code[007252] = *I07252; sub I07252 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[007253] = 01045; $code[007253] = *I07253; sub I07253 { $lac += $core[000045]; goto &fetch; }
$core[007254] = 07510; $code[007254] = *I07254; sub I07254 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007255] = 07020; $code[007255] = *I07255; sub I07255 { $lac ^= 010000; goto &fetch; }
$core[007256] = 07010; $code[007256] = *L07256; sub L07256 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007257] = 03045; $code[007257] = *I07257; sub I07257 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007260] = 01046; $code[007260] = *I07260; sub I07260 { $lac += $core[000046]; goto &fetch; }
$core[007261] = 07010; $code[007261] = *I07261; sub I07261 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007262] = 03046; $code[007262] = *I07262; sub I07262 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007263] = 01047; $code[007263] = *I07263; sub I07263 { $lac += $core[000047]; goto &fetch; }
$core[007264] = 07010; $code[007264] = *I07264; sub I07264 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007265] = 03047; $code[007265] = *I07265; sub I07265 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007266] = 02044; $code[007266] = *I07266; sub I07266 { if (++$core[000044] == 010000) { $core[000044] = 0; $pc++; }$code[000044] = *emul8; goto &fetch; }
$core[007267] = 05651; $code[007267] = *I07267; sub I07267 { $pc = ($ib<<12)+$core[3753]; $inh = 0; goto &fetch; }
$core[007270] = 05651; $code[007270] = *I07270; sub I07270 { $pc = ($ib<<12)+$core[3753]; $inh = 0; goto &fetch; }
$core[007271] = 00000; $code[007271] = *S07271; sub S07271 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007272] = 07300; $code[007272] = *I07272; sub I07272 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[007273] = 01041; $code[007273] = *I07273; sub I07273 { $lac += $core[000041]; goto &fetch; }
$core[007274] = 07510; $code[007274] = *I07274; sub I07274 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007275] = 07020; $code[007275] = *I07275; sub I07275 { $lac ^= 010000; goto &fetch; }
$core[007276] = 07010; $code[007276] = *I07276; sub I07276 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007277] = 03041; $code[007277] = *I07277; sub I07277 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[007300] = 01042; $code[007300] = *I07300; sub I07300 { $lac += $core[000042]; goto &fetch; }
$core[007301] = 07010; $code[007301] = *I07301; sub I07301 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007302] = 03042; $code[007302] = *I07302; sub I07302 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[007303] = 01043; $code[007303] = *I07303; sub I07303 { $lac += $core[000043]; goto &fetch; }
$core[007304] = 07010; $code[007304] = *I07304; sub I07304 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007305] = 03043; $code[007305] = *I07305; sub I07305 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[007306] = 02040; $code[007306] = *I07306; sub I07306 { if (++$core[000040] == 010000) { $core[000040] = 0; $pc++; }$code[000040] = *emul8; goto &fetch; }
$core[007307] = 05671; $code[007307] = *I07307; sub I07307 { $pc = ($ib<<12)+$core[3769]; $inh = 0; goto &fetch; }
$core[007310] = 05671; $code[007310] = *I07310; sub I07310 { $pc = ($ib<<12)+$core[3769]; $inh = 0; goto &fetch; }
$core[007311] = 00000; $code[007311] = *S07311; sub S07311 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007312] = 07300; $code[007312] = *I07312; sub I07312 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[007313] = 01044; $code[007313] = *P07313; sub P07313 { $lac += $core[000044]; goto &fetch; }
$core[007314] = 07750; $code[007314] = *D07314; sub D07314 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007315] = 03044; $code[007315] = *I07315; sub I07315 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007316] = 01044; $code[007316] = *I07316; sub I07316 { $lac += $core[000044]; goto &fetch; }
$core[007317] = 01331; $code[007317] = *I07317; sub I07317 { $lac += $core[007331]; goto &fetch; }
$core[007320] = 03271; $code[007320] = *I07320; sub I07320 { $core[007271] = $lac & 07777; $lac &= 010000; $code[007271] = *emul8; goto &fetch; }
$core[007321] = 07430; $code[007321] = *I07321; sub I07321 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007322] = 05711; $code[007322] = *I07322; sub I07322 { $pc = ($ib<<12)+$core[3785]; $inh = 0; goto &fetch; }
$core[007323] = 04251; $code[007323] = *L07323; sub L07323 { $core[007251] = 07324; $pc = 007251+1; $code[007251] = *emul8; $inh = 0; goto &fetch; }
$core[007324] = 02271; $code[007324] = *I07324; sub I07324 { if (++$core[007271] == 010000) { $core[007271] = 0; $pc++; }$code[007271] = *emul8; goto &fetch; }
$core[007325] = 05323; $code[007325] = *I07325; sub I07325 { $pc = 007323; $inh = 0; goto &fetch; }
$core[007326] = 03047; $code[007326] = *I07326; sub I07326 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007327] = 01046; $code[007327] = *I07327; sub I07327 { $lac += $core[000046]; goto &fetch; }
$core[007330] = 05711; $code[007330] = *I07330; sub I07330 { $pc = ($ib<<12)+$core[3785]; $inh = 0; goto &fetch; }
$core[007331] = 07751; $code[007331] = *D07331; sub D07331 { &emul8; goto &fetch; }
$core[007332] = 00000; $code[007332] = *S07332; sub S07332 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007333] = 03045; $code[007333] = *I07333; sub I07333 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007334] = 03046; $code[007334] = *I07334; sub I07334 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007335] = 03047; $code[007335] = *I07335; sub I07335 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007336] = 01005; $code[007336] = *I07336; sub I07336 { $lac += $core[000005]; goto &fetch; }
$core[007337] = 03044; $code[007337] = *I07337; sub I07337 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007340] = 04251; $code[007340] = *I07340; sub I07340 { $core[007251] = 07341; $pc = 007251+1; $code[007251] = *emul8; $inh = 0; goto &fetch; }
$core[007341] = 04650; $code[007341] = *I07341; sub I07341 { $core[($ib<<12)+$core[3752]] = 07342; $pc = ($ib<<12)+$core[3752]+1; $code[($ib<<12)+$core[3752]] = *emul8; $inh = 0; goto &fetch; }
$core[007342] = 05732; $code[007342] = *I07342; sub I07342 { $pc = ($ib<<12)+$core[3802]; $inh = 0; goto &fetch; }
$core[007343] = 07037; $code[007343] = *P07343; sub P07343 { $lac ^= 010000; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[007344] = 05713; $code[007344] = *P07344; sub P07344 { $pc = ($ib<<12)+$core[3787]; $inh = 0; goto &fetch; }
$core[007345] = 07774; $code[007345] = *D07345; sub D07345 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007346] = 04421; $code[007346] = *D07346; sub D07346 { $core[($ib<<12)+$core[17]] = 07347; $pc = ($ib<<12)+$core[17]+1; $code[($ib<<12)+$core[17]] = *emul8; $inh = 0; goto &fetch; }
$core[007347] = 03040; $code[007347] = *I07347; sub I07347 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[007350] = 00001; $code[007350] = *I07350; sub I07350 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007351] = 04407; $code[007351] = *I07351; sub I07351 { $core[($ib<<12)+$core[7]] = 07352; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[007352] = 05346; $code[007352] = *I07352; sub I07352 { &emul8; goto &fetch; }
$core[007353] = 00000; $code[007353] = *I07353; sub I07353 { &emul8; goto &fetch; }
$core[007354] = 04504; $code[007354] = *I07354; sub I07354 { $core[($ib<<12)+$core[68]] = 07355; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[007355] = 07346; $code[007355] = *I07355; sub I07355 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007356] = 04505; $code[007356] = *I07356; sub I07356 { $core[($ib<<12)+$core[69]] = 07357; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[007357] = 00041; $code[007357] = *I07357; sub I07357 { $lac &= (010000|$core[000041]); goto &fetch; }
$core[007360] = 01345; $code[007360] = *I07360; sub I07360 { $lac += $core[007345]; goto &fetch; }
$core[007361] = 03156; $code[007361] = *I07361; sub I07361 { $core[000156] = $lac & 07777; $lac &= 010000; $code[000156] = *emul8; goto &fetch; }
$core[007362] = 04743; $code[007362] = *L07362; sub L07362 { $core[($ib<<12)+$core[3811]] = 07363; $pc = ($ib<<12)+$core[3811]+1; $code[($ib<<12)+$core[3811]] = *emul8; $inh = 0; goto &fetch; }
$core[007363] = 02156; $code[007363] = *I07363; sub I07363 { if (++$core[000156] == 010000) { $core[000156] = 0; $pc++; }$code[000156] = *emul8; goto &fetch; }
$core[007364] = 05362; $code[007364] = *I07364; sub I07364 { $pc = 007362; $inh = 0; goto &fetch; }
$core[007365] = 04744; $code[007365] = *I07365; sub I07365 { $core[($ib<<12)+$core[3812]] = 07366; $pc = ($ib<<12)+$core[3812]+1; $code[($ib<<12)+$core[3812]] = *emul8; $inh = 0; goto &fetch; }
$core[007366] = 04743; $code[007366] = *I07366; sub I07366 { $core[($ib<<12)+$core[3811]] = 07367; $pc = ($ib<<12)+$core[3811]+1; $code[($ib<<12)+$core[3811]] = *emul8; $inh = 0; goto &fetch; }
$core[007367] = 04744; $code[007367] = *I07367; sub I07367 { $core[($ib<<12)+$core[3812]] = 07370; $pc = ($ib<<12)+$core[3812]+1; $code[($ib<<12)+$core[3812]] = *emul8; $inh = 0; goto &fetch; }
$core[007370] = 04504; $code[007370] = *I07370; sub I07370 { $core[($ib<<12)+$core[68]] = 07371; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[007371] = 00045; $code[007371] = *I07371; sub I07371 { $lac &= (010000|$core[000045]); goto &fetch; }
$core[007372] = 04505; $code[007372] = *I07372; sub I07372 { $core[($ib<<12)+$core[69]] = 07373; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[007373] = 07346; $code[007373] = *I07373; sub I07373 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007374] = 03047; $code[007374] = *I07374; sub I07374 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007375] = 03044; $code[007375] = *I07375; sub I07375 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007376] = 01045; $code[007376] = *I07376; sub I07376 { $lac += $core[000045]; goto &fetch; }
$core[007377] = 07700; $code[007377] = *I07377; sub I07377 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007400] = 05500; $code[007400] = *I07400; sub I07400 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[007401] = 02046; $code[007401] = *I07401; sub I07401 { if (++$core[000046] == 010000) { $core[000046] = 0; $pc++; }$code[000046] = *emul8; goto &fetch; }
$core[007402] = 07410; $code[007402] = *I07402; sub I07402 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007403] = 02045; $code[007403] = *I07403; sub I07403 { if (++$core[000045] == 010000) { $core[000045] = 0; $pc++; }$code[000045] = *emul8; goto &fetch; }
$core[007404] = 04450; $code[007404] = *I07404; sub I07404 { $core[($ib<<12)+$core[40]] = 07405; $pc = ($ib<<12)+$core[40]+1; $code[($ib<<12)+$core[40]] = *emul8; $inh = 0; goto &fetch; }
$core[007405] = 05500; $code[007405] = *I07405; sub I07405 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[007406] = 01407; $code[007406] = *L07406; sub L07406 { $lac += $core[($df<<12)+$core[7]]; goto &fetch; }
$core[007407] = 04503; $code[007407] = *I07407; sub I07407 { $core[($ib<<12)+$core[67]] = 07410; $pc = ($ib<<12)+$core[67]+1; $code[($ib<<12)+$core[67]] = *emul8; $inh = 0; goto &fetch; }
$core[007410] = 04504; $code[007410] = *D07410; sub D07410 { $core[($ib<<12)+$core[68]] = 07411; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[007411] = 00044; $code[007411] = *I07411; sub I07411 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[007412] = 04505; $code[007412] = *I07412; sub I07412 { $core[($ib<<12)+$core[69]] = 07413; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[007413] = 07545; $code[007413] = *I07413; sub I07413 { &emul8; goto &fetch; }
$core[007414] = 04504; $code[007414] = *I07414; sub I07414 { $core[($ib<<12)+$core[68]] = 07415; $pc = ($ib<<12)+$core[68]+1; $code[($ib<<12)+$core[68]] = *emul8; $inh = 0; goto &fetch; }
$core[007415] = 00040; $code[007415] = *I07415; sub I07415 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[007416] = 04505; $code[007416] = *I07416; sub I07416 { $core[($ib<<12)+$core[69]] = 07417; $pc = ($ib<<12)+$core[69]+1; $code[($ib<<12)+$core[69]] = *emul8; $inh = 0; goto &fetch; }
$core[007417] = 00044; $code[007417] = *I07417; sub I07417 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[007420] = 04452; $code[007420] = *I07420; sub I07420 { $core[($ib<<12)+$core[42]] = 07421; $pc = ($ib<<12)+$core[42]+1; $code[($ib<<12)+$core[42]] = *emul8; $inh = 0; goto &fetch; }
$core[007421] = 07710; $code[007421] = *I07421; sub I07421 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007422] = 07001; $code[007422] = *I07422; sub I07422 { $lac++; goto &fetch; }
$core[007423] = 01045; $code[007423] = *I07423; sub I07423 { $lac += $core[000045]; goto &fetch; }
$core[007424] = 07640; $code[007424] = *I07424; sub I07424 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007425] = 04526; $code[007425] = *I07425; sub I07425 { $core[($ib<<12)+$core[86]] = 07426; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[007426] = 01046; $code[007426] = *I07426; sub I07426 { $lac += $core[000046]; goto &fetch; }
$core[007427] = 03350; $code[007427] = *I07427; sub I07427 { $core[007550] = $lac & 07777; $lac &= 010000; $code[007550] = *emul8; goto &fetch; }
$core[007430] = 04407; $code[007430] = *I07430; sub I07430 { $core[($ib<<12)+$core[7]] = 07431; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[007431] = 05661; $code[007431] = *I07431; sub I07431 { &emul8; goto &fetch; }
$core[007432] = 00000; $code[007432] = *I07432; sub I07432 { &emul8; goto &fetch; }
$core[007433] = 01350; $code[007433] = *I07433; sub I07433 { $lac += $core[007550]; goto &fetch; }
$core[007434] = 07450; $code[007434] = *I07434; sub I07434 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007435] = 05255; $code[007435] = *I07435; sub I07435 { $pc = 007455; $inh = 0; goto &fetch; }
$core[007436] = 07500; $code[007436] = *I07436; sub I07436 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[007437] = 05246; $code[007437] = *I07437; sub I07437 { $pc = 007446; $inh = 0; goto &fetch; }
$core[007440] = 04407; $code[007440] = *I07440; sub I07440 { $core[($ib<<12)+$core[7]] = 07441; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[007441] = 04345; $code[007441] = *I07441; sub I07441 { &emul8; goto &fetch; }
$core[007442] = 06345; $code[007442] = *I07442; sub I07442 { &emul8; goto &fetch; }
$core[007443] = 05661; $code[007443] = *I07443; sub I07443 { &emul8; goto &fetch; }
$core[007444] = 00000; $code[007444] = *I07444; sub I07444 { &emul8; goto &fetch; }
$core[007445] = 05250; $code[007445] = *I07445; sub I07445 { $pc = 007450; $inh = 0; goto &fetch; }
$core[007446] = 07041; $code[007446] = *L07446; sub L07446 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007447] = 03350; $code[007447] = *I07447; sub I07447 { $core[007550] = $lac & 07777; $lac &= 010000; $code[007550] = *emul8; goto &fetch; }
$core[007450] = 04407; $code[007450] = *L07450; sub L07450 { $core[($ib<<12)+$core[7]] = 07451; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[007451] = 03345; $code[007451] = *I07451; sub I07451 { &emul8; goto &fetch; }
$core[007452] = 00000; $code[007452] = *I07452; sub I07452 { &emul8; goto &fetch; }
$core[007453] = 02350; $code[007453] = *I07453; sub I07453 { if (++$core[007550] == 010000) { $core[007550] = 0; $pc++; }$code[007550] = *emul8; goto &fetch; }
$core[007454] = 05250; $code[007454] = *I07454; sub I07454 { $pc = 007450; $inh = 0; goto &fetch; }
$core[007455] = 01413; $code[007455] = *L07455; sub L07455 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[007456] = 03407; $code[007456] = *I07456; sub I07456 { $core[($df<<12)+$core[7]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[7]] = *emul8; goto &fetch; }
$core[007457] = 05660; $code[007457] = *I07457; sub I07457 { $pc = ($ib<<12)+$core[3888]; $inh = 0; goto &fetch; }
$core[007460] = 06601; $code[007460] = *P07460; sub P07460 { &emul8; goto &fetch; }
$core[007461] = 01573; $code[007461] = *P07461; sub P07461 { $lac += $core[($df<<12)+$core[123]]; goto &fetch; }
$core[007462] = 01045; $code[007462] = *I07462; sub I07462 { $lac += $core[000045]; goto &fetch; }
$core[007463] = 07510; $code[007463] = *I07463; sub I07463 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007464] = 04526; $code[007464] = *I07464; sub I07464 { $core[($ib<<12)+$core[86]] = 07465; $pc = ($ib<<12)+$core[86]+1; $code[($ib<<12)+$core[86]] = *emul8; $inh = 0; goto &fetch; }
$core[007465] = 07650; $code[007465] = *I07465; sub I07465 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007466] = 05500; $code[007466] = *I07466; sub I07466 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[007467] = 01044; $code[007467] = *I07467; sub I07467 { $lac += $core[000044]; goto &fetch; }
$core[007470] = 07510; $code[007470] = *I07470; sub I07470 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007471] = 07020; $code[007471] = *I07471; sub I07471 { $lac ^= 010000; goto &fetch; }
$core[007472] = 07010; $code[007472] = *I07472; sub I07472 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007473] = 03044; $code[007473] = *I07473; sub I07473 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007474] = 01334; $code[007474] = *I07474; sub I07474 { $lac += $core[007534]; goto &fetch; }
$core[007475] = 03045; $code[007475] = *I07475; sub I07475 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007476] = 04407; $code[007476] = *L07476; sub L07476 { $core[($ib<<12)+$core[7]] = 07477; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[007477] = 06345; $code[007477] = *D07477; sub D07477 { &emul8; goto &fetch; }
$core[007500] = 05560; $code[007500] = *I07500; sub I07500 { &emul8; goto &fetch; }
$core[007501] = 04345; $code[007501] = *I07501; sub I07501 { &emul8; goto &fetch; }
$core[007502] = 01345; $code[007502] = *I07502; sub I07502 { &emul8; goto &fetch; }
$core[007503] = 00000; $code[007503] = *I07503; sub I07503 { &emul8; goto &fetch; }
$core[007504] = 07040; $code[007504] = *I07504; sub I07504 { $lac ^= 07777; goto &fetch; }
$core[007505] = 01044; $code[007505] = *I07505; sub I07505 { $lac += $core[000044]; goto &fetch; }
$core[007506] = 03044; $code[007506] = *I07506; sub I07506 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007507] = 01044; $code[007507] = *I07507; sub I07507 { $lac += $core[000044]; goto &fetch; }
$core[007510] = 07041; $code[007510] = *I07510; sub I07510 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007511] = 01345; $code[007511] = *I07511; sub I07511 { $lac += $core[007545]; goto &fetch; }
$core[007512] = 07640; $code[007512] = *I07512; sub I07512 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007513] = 05276; $code[007513] = *I07513; sub I07513 { $pc = 007476; $inh = 0; goto &fetch; }
$core[007514] = 01045; $code[007514] = *I07514; sub I07514 { $lac += $core[000045]; goto &fetch; }
$core[007515] = 07041; $code[007515] = *I07515; sub I07515 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007516] = 01346; $code[007516] = *I07516; sub I07516 { $lac += $core[007546]; goto &fetch; }
$core[007517] = 07640; $code[007517] = *I07517; sub I07517 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007520] = 05276; $code[007520] = *I07520; sub I07520 { $pc = 007476; $inh = 0; goto &fetch; }
$core[007521] = 01046; $code[007521] = *I07521; sub I07521 { $lac += $core[000046]; goto &fetch; }
$core[007522] = 07041; $code[007522] = *I07522; sub I07522 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007523] = 01347; $code[007523] = *I07523; sub I07523 { $lac += $core[007547]; goto &fetch; }
$core[007524] = 07450; $code[007524] = *I07524; sub I07524 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007525] = 05500; $code[007525] = *I07525; sub I07525 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[007526] = 07500; $code[007526] = *I07526; sub I07526 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[007527] = 07041; $code[007527] = *I07527; sub I07527 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007530] = 07001; $code[007530] = *I07530; sub I07530 { $lac++; goto &fetch; }
$core[007531] = 07650; $code[007531] = *I07531; sub I07531 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007532] = 05500; $code[007532] = *I07532; sub I07532 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[007533] = 05276; $code[007533] = *I07533; sub I07533 { $pc = 007476; $inh = 0; goto &fetch; }
$core[007534] = 03015; $code[007534] = *D07534; sub D07534 { $core[000015] = $lac & 07777; $lac &= 010000; $code[000015] = *emul8; goto &fetch; }
$core[007535] = 01045; $code[007535] = *I07535; sub I07535 { $lac += $core[000045]; goto &fetch; }
$core[007536] = 07450; $code[007536] = *I07536; sub I07536 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007537] = 05343; $code[007537] = *I07537; sub I07537 { $pc = 007543; $inh = 0; goto &fetch; }
$core[007540] = 07710; $code[007540] = *L07540; sub L07540 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007541] = 01034; $code[007541] = *I07541; sub I07541 { $lac += $core[000034]; goto &fetch; }
$core[007542] = 07001; $code[007542] = *I07542; sub I07542 { $lac++; goto &fetch; }
$core[007543] = 04430; $code[007543] = *L07543; sub L07543 { $core[($ib<<12)+$core[24]] = 07544; $pc = ($ib<<12)+$core[24]+1; $code[($ib<<12)+$core[24]] = *emul8; $inh = 0; goto &fetch; }
$core[007544] = 05500; $code[007544] = *I07544; sub I07544 { $pc = ($ib<<12)+$core[64]; $inh = 0; goto &fetch; }
$core[007545] = 00000; $code[007545] = *D07545; sub D07545 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007546] = 00000; $code[007546] = *D07546; sub D07546 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007547] = 00000; $code[007547] = *D07547; sub D07547 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007550] = 00000; $code[007550] = *D07550; sub D07550 { $lac &= (010000|$core[000000]); goto &fetch; }
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

