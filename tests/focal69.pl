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
$core[000001] = 05403; $code[000001] = *P00001; sub P00001 { $pc = ($ib<<12)+$core[3]; $inh = 0; goto &fetch; }
$core[000002] = 05403; $code[000002] = *P00002; sub P00002 { $pc = ($ib<<12)+$core[3]; $inh = 0; goto &fetch; }
$core[000003] = 02603; $code[000003] = *P00003; sub P00003 { if (++$core[($df<<12)+$core[3]] == 010000) { $core[($df<<12)+$core[3]] = 0; $pc++; }$code[($df<<12)+$core[3]] = *emul8; goto &fetch; }
$core[000004] = 00004; $code[000004] = *D00004; sub D00004 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[000005] = 00013; $code[000005] = *P00005; sub P00005 { $lac &= (010000|$core[000013]); goto &fetch; }
$core[000006] = 00100; $code[000006] = *D00006; sub D00006 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000007] = 06400; $code[000007] = *P00007; sub P00007 { &emul8; goto &fetch; }
$core[000010] = 00000; $code[000010] = *P00010; sub P00010 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000011] = 00000; $code[000011] = *P00011; sub P00011 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000012] = 00000; $code[000012] = *P00012; sub P00012 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000013] = 04370; $code[000013] = *P00013; sub P00013 { $core[000170] = 00014; $pc = 000170+1; $code[000170] = *emul8; $inh = 0; goto &fetch; }
$core[000014] = 03117; $code[000014] = *P00014; sub P00014 { $core[000117] = $lac & 07777; $lac &= 010000; $code[000117] = *emul8; goto &fetch; }
$core[000015] = 00000; $code[000015] = *P00015; sub P00015 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000016] = 07402; $code[000016] = *P00016; sub P00016 { $hlt = 1; goto &fetch; }
$core[000017] = 03215; $code[000017] = *P00017; sub P00017 { $core[000015] = $lac & 07777; $lac &= 010000; $code[000015] = *emul8; goto &fetch; }
$core[000020] = 00000; $code[000020] = *P00020; sub P00020 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000021] = 00000; $code[000021] = *P00021; sub P00021 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000022] = 02407; $code[000022] = *P00022; sub P00022 { if (++$core[($df<<12)+$core[7]] == 010000) { $core[($df<<12)+$core[7]] = 0; $pc++; }$code[($df<<12)+$core[7]] = *emul8; goto &fetch; }
$core[000023] = 00000; $code[000023] = *P00023; sub P00023 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000024] = 00000; $code[000024] = *P00024; sub P00024 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000025] = 00000; $code[000025] = *P00025; sub P00025 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000026] = 00001; $code[000026] = *D00026; sub D00026 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000027] = 00000; $code[000027] = *P00027; sub P00027 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000030] = 00000; $code[000030] = *P00030; sub P00030 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000031] = 03760; $code[000031] = *P00031; sub P00031 { $core[($df<<12)+$core[112]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[112]] = *emul8; goto &fetch; }
$core[000032] = 00000; $code[000032] = *D00032; sub D00032 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000033] = 00000; $code[000033] = *D00033; sub D00033 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000034] = 00000; $code[000034] = *P00034; sub P00034 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000035] = 04370; $code[000035] = *P00035; sub P00035 { $core[000170] = 00036; $pc = 000170+1; $code[000170] = *emul8; $inh = 0; goto &fetch; }
$core[000036] = 00000; $code[000036] = *P00036; sub P00036 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000037] = 00000; $code[000037] = *P00037; sub P00037 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000040] = 00000; $code[000040] = *P00040; sub P00040 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000041] = 00000; $code[000041] = *D00041; sub D00041 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000042] = 00000; $code[000042] = *P00042; sub P00042 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000043] = 00000; $code[000043] = *P00043; sub P00043 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000044] = 00000; $code[000044] = *D00044; sub D00044 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000045] = 00000; $code[000045] = *D00045; sub D00045 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000046] = 00000; $code[000046] = *D00046; sub D00046 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000047] = 00000; $code[000047] = *D00047; sub D00047 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000050] = 00000; $code[000050] = *P00050; sub P00050 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000051] = 06603; $code[000051] = *P00051; sub P00051 { &emul8; goto &fetch; }
$core[000052] = 02004; $code[000052] = *D00052; sub D00052 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[000053] = 06724; $code[000053] = *P00053; sub P00053 { &emul8; goto &fetch; }
$core[000054] = 00000; $code[000054] = *P00054; sub P00054 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000055] = 00000; $code[000055] = *P00055; sub P00055 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000056] = 00000; $code[000056] = *D00056; sub D00056 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000057] = 07760; $code[000057] = *P00057; sub P00057 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000060] = 03760; $code[000060] = *P00060; sub P00060 { $core[($df<<12)+$core[112]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[112]] = *emul8; goto &fetch; }
$core[000061] = 01354; $code[000061] = *P00061; sub P00061 { $lac += $core[000154]; goto &fetch; }
$core[000062] = 02414; $code[000062] = *P00062; sub P00062 { $core[000014] = 0000 if ++$core[000014] == 010000; if (++$core[($df<<12)+$core[000014]] == 010000) { $core[($df<<12)+$core[000014]] = 0; $pc++; }$code[($df<<12)+$core[000014]] = *emul8; goto &fetch; }
$core[000063] = 02676; $code[000063] = *P00063; sub P00063 { if (++$core[($df<<12)+$core[62]] == 010000) { $core[($df<<12)+$core[62]] = 0; $pc++; }$code[($df<<12)+$core[62]] = *emul8; goto &fetch; }
$core[000064] = 02666; $code[000064] = *P00064; sub P00064 { if (++$core[($df<<12)+$core[54]] == 010000) { $core[($df<<12)+$core[54]] = 0; $pc++; }$code[($df<<12)+$core[54]] = *emul8; goto &fetch; }
$core[000065] = 00001; $code[000065] = *P00065; sub P00065 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000066] = 00215; $code[000066] = *P00066; sub P00066 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000067] = 00000; $code[000067] = *D00067; sub D00067 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000070] = 00005; $code[000070] = *D00070; sub D00070 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[000071] = 00000; $code[000071] = *P00071; sub P00071 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000072] = 00214; $code[000072] = *I00072; sub I00072 { $lac &= (010000|$core[000014]); goto &fetch; }
$core[000073] = 00207; $code[000073] = *D00073; sub D00073 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000074] = 00203; $code[000074] = *P00074; sub P00074 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000075] = 00337; $code[000075] = *D00075; sub D00075 { $lac &= (010000|$core[000137]); goto &fetch; }
$core[000076] = 00212; $code[000076] = *P00076; sub P00076 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[000077] = 00215; $code[000077] = *P00077; sub P00077 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[000100] = 07402; $code[000100] = *P00100; sub P00100 { $hlt = 1; goto &fetch; }
$core[000101] = 07700; $code[000101] = *P00101; sub P00101 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000102] = 00256; $code[000102] = *P00102; sub P00102 { $lac &= (010000|$core[000056]); goto &fetch; }
$core[000103] = 07701; $code[000103] = *D00103; sub D00103 { &emul8; goto &fetch; }
$core[000104] = 07600; $code[000104] = *P00104; sub P00104 { $lac &= 010000; goto &fetch; }
$core[000105] = 07760; $code[000105] = *D00105; sub D00105 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000106] = 00177; $code[000106] = *D00106; sub D00106 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[000107] = 00017; $code[000107] = *P00107; sub P00107 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[000110] = 00277; $code[000110] = *D00110; sub D00110 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[000111] = 07776; $code[000111] = *D00111; sub D00111 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000112] = 07477; $code[000112] = *D00112; sub D00112 { &emul8; goto &fetch; }
$core[000113] = 00260; $code[000113] = *D00113; sub D00113 { $lac &= (010000|$core[000060]); goto &fetch; }
$core[000114] = 07540; $code[000114] = *P00114; sub P00114 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000115] = 07522; $code[000115] = *P00115; sub P00115 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $hlt = 1; goto &fetch; }
$core[000116] = 07563; $code[000116] = *D00116; sub D00116 { &emul8; goto &fetch; }
$core[000117] = 07775; $code[000117] = *P00117; sub P00117 { &emul8; goto &fetch; }
$core[000120] = 07773; $code[000120] = *P00120; sub P00120 { &emul8; goto &fetch; }
$core[000121] = 07767; $code[000121] = *P00121; sub P00121 { &emul8; goto &fetch; }
$core[000122] = 00077; $code[000122] = *P00122; sub P00122 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[000123] = 00200; $code[000123] = *P00123; sub P00123 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000124] = 04000; $code[000124] = *P00124; sub P00124 { $core[000000] = 00125; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000125] = 02030; $code[000125] = *P00125; sub P00125 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[000126] = 02155; $code[000126] = *P00126; sub P00126 { if (++$core[000155] == 010000) { $core[000155] = 0; $pc++; }$code[000155] = *emul8; goto &fetch; }
$core[000127] = 05715; $code[000127] = *P00127; sub P00127 { $pc = ($ib<<12)+$core[77]; $inh = 0; goto &fetch; }
$core[000130] = 06000; $code[000130] = *P00130; sub P00130 { &emul8; goto &fetch; }
$core[000131] = 06200; $code[000131] = *P00131; sub P00131 { &emul8; goto &fetch; }
$core[000132] = 03140; $code[000132] = *P00132; sub P00132 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[000133] = 03206; $code[000133] = *P00133; sub P00133 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[000134] = 03140; $code[000134] = *P00134; sub P00134 { $core[000140] = $lac & 07777; $lac &= 010000; $code[000140] = *emul8; goto &fetch; }
$core[000135] = 03217; $code[000135] = *P00135; sub P00135 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[000136] = 02017; $code[000136] = *P00136; sub P00136 { if (++$core[000017] == 010000) { $core[000017] = 0; $pc++; }$code[000017] = *emul8; goto &fetch; }
$core[000137] = 02407; $code[000137] = *D00137; sub D00137 { if (++$core[($df<<12)+$core[7]] == 010000) { $core[($df<<12)+$core[7]] = 0; $pc++; }$code[($df<<12)+$core[7]] = *emul8; goto &fetch; }
$core[000140] = 00521; $code[000140] = *P00140; sub P00140 { $lac &= (010000|$core[($df<<12)+$core[81]]); goto &fetch; }
$core[000141] = 01565; $code[000141] = *P00141; sub P00141 { $lac += $core[($df<<12)+$core[117]]; goto &fetch; }
$core[000142] = 00477; $code[000142] = *P00142; sub P00142 { $lac &= (010000|$core[($df<<12)+$core[63]]); goto &fetch; }
$core[000143] = 00534; $code[000143] = *P00143; sub P00143 { $lac &= (010000|$core[($df<<12)+$core[92]]); goto &fetch; }
$core[000144] = 00554; $code[000144] = *P00144; sub P00144 { $lac &= (010000|$core[($df<<12)+$core[108]]); goto &fetch; }
$core[000145] = 02274; $code[000145] = *P00145; sub P00145 { if (++$core[000074] == 010000) { $core[000074] = 0; $pc++; }$code[000074] = *emul8; goto &fetch; }
$core[000146] = 02502; $code[000146] = *P00146; sub P00146 { if (++$core[($df<<12)+$core[66]] == 010000) { $core[($df<<12)+$core[66]] = 0; $pc++; }$code[($df<<12)+$core[66]] = *emul8; goto &fetch; }
$core[000147] = 01314; $code[000147] = *P00147; sub P00147 { $lac += $core[000114]; goto &fetch; }
$core[000150] = 00721; $code[000150] = *P00150; sub P00150 { $lac &= (010000|$core[($df<<12)+$core[81]]); goto &fetch; }
$core[000151] = 02465; $code[000151] = *P00151; sub P00151 { if (++$core[($df<<12)+$core[53]] == 010000) { $core[($df<<12)+$core[53]] = 0; $pc++; }$code[($df<<12)+$core[53]] = *emul8; goto &fetch; }
$core[000152] = 02155; $code[000152] = *P00152; sub P00152 { if (++$core[000155] == 010000) { $core[000155] = 0; $pc++; }$code[000155] = *emul8; goto &fetch; }
$core[000153] = 02425; $code[000153] = *P00153; sub P00153 { if (++$core[($df<<12)+$core[21]] == 010000) { $core[($df<<12)+$core[21]] = 0; $pc++; }$code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[000154] = 00302; $code[000154] = *P00154; sub P00154 { $lac &= (010000|$core[000102]); goto &fetch; }
$core[000155] = 02242; $code[000155] = *P00155; sub P00155 { if (++$core[000042] == 010000) { $core[000042] = 0; $pc++; }$code[000042] = *emul8; goto &fetch; }
$core[000156] = 02360; $code[000156] = *P00156; sub P00156 { if (++$core[000160] == 010000) { $core[000160] = 0; $pc++; }$code[000160] = *emul8; goto &fetch; }
$core[000157] = 00413; $code[000157] = *P00157; sub P00157 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac &= (010000|$core[($df<<12)+$core[000013]]); goto &fetch; }
$core[000160] = 01517; $code[000160] = *P00160; sub P00160 { $lac += $core[($df<<12)+$core[79]]; goto &fetch; }
$core[000161] = 01533; $code[000161] = *P00161; sub P00161 { $lac += $core[($df<<12)+$core[91]]; goto &fetch; }
$core[000162] = 02035; $code[000162] = *P00162; sub P00162 { if (++$core[000035] == 010000) { $core[000035] = 0; $pc++; }$code[000035] = *emul8; goto &fetch; }
$core[000163] = 00744; $code[000163] = *P00163; sub P00163 { $lac &= (010000|$core[($df<<12)+$core[100]]); goto &fetch; }
$core[000164] = 00700; $code[000164] = *P00164; sub P00164 { $lac &= (010000|$core[($df<<12)+$core[64]]); goto &fetch; }
$core[000165] = 02062; $code[000165] = *P00165; sub P00165 { if (++$core[000062] == 010000) { $core[000062] = 0; $pc++; }$code[000062] = *emul8; goto &fetch; }
$core[000166] = 02726; $code[000166] = *P00166; sub P00166 { if (++$core[($df<<12)+$core[86]] == 010000) { $core[($df<<12)+$core[86]] = 0; $pc++; }$code[($df<<12)+$core[86]] = *emul8; goto &fetch; }
$core[000176] = 04371; $code[000176] = *P00176; sub P00176 { $core[000171] = 00177; $pc = 000171+1; $code[000171] = *emul8; $inh = 0; goto &fetch; }
$core[000177] = 07610; $code[000177] = *L00177; sub L00177 { $skp = 0; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000200] = 05576; $code[000200] = *P00200; sub P00200 { $pc = ($ib<<12)+$core[126]; $inh = 0; goto &fetch; }
$core[000201] = 01137; $code[000201] = *I00201; sub I00201 { $lac += $core[000137]; goto &fetch; }
$core[000202] = 03022; $code[000202] = *I00202; sub I00202 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[000203] = 07001; $code[000203] = *D00203; sub D00203 { $lac++; goto &fetch; }
$core[000204] = 03100; $code[000204] = *I00204; sub I00204 { $core[000100] = $lac & 07777; $lac &= 010000; $code[000100] = *emul8; goto &fetch; }
$core[000205] = 03026; $code[000205] = *I00205; sub I00205 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[000206] = 01226; $code[000206] = *I00206; sub I00206 { $lac += $core[000226]; goto &fetch; }
$core[000207] = 03013; $code[000207] = *I00207; sub I00207 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[000210] = 01225; $code[000210] = *I00210; sub I00210 { $lac += $core[000225]; goto &fetch; }
$core[000211] = 04551; $code[000211] = *P00211; sub P00211 { $core[($ib<<12)+$core[105]] = 00212; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[000212] = 01132; $code[000212] = *L00212; sub L00212 { $lac += $core[000132]; goto &fetch; }
$core[000213] = 03010; $code[000213] = *I00213; sub I00213 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000214] = 03062; $code[000214] = *I00214; sub I00214 { $core[000062] = $lac & 07777; $lac &= 010000; $code[000062] = *emul8; goto &fetch; }
$core[000215] = 01132; $code[000215] = *D00215; sub D00215 { $lac += $core[000132]; goto &fetch; }
$core[000216] = 03027; $code[000216] = *I00216; sub I00216 { $core[000027] = $lac & 07777; $lac &= 010000; $code[000027] = *emul8; goto &fetch; }
$core[000217] = 04552; $code[000217] = *L00217; sub L00217 { $core[($ib<<12)+$core[106]] = 00220; $pc = ($ib<<12)+$core[106]+1; $code[($ib<<12)+$core[106]] = *emul8; $inh = 0; goto &fetch; }
$core[000220] = 04547; $code[000220] = *D00220; sub D00220 { $core[($ib<<12)+$core[103]] = 00221; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[000221] = 00073; $code[000221] = *I00221; sub I00221 { $lac &= (010000|$core[000073]); goto &fetch; }
$core[000222] = 00474; $code[000222] = *I00222; sub I00222 { $lac &= (010000|$core[($df<<12)+$core[60]]); goto &fetch; }
$core[000223] = 04546; $code[000223] = *I00223; sub I00223 { $core[($ib<<12)+$core[102]] = 00224; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[000224] = 05217; $code[000224] = *I00224; sub I00224 { $pc = 000217; $inh = 0; goto &fetch; }
$core[000225] = 00252; $code[000225] = *D00225; sub D00225 { $lac &= (010000|$core[000252]); goto &fetch; }
$core[000226] = 03220; $code[000226] = *D00226; sub D00226 { $core[000220] = $lac & 07777; $lac &= 010000; $code[000220] = *emul8; goto &fetch; }
$core[000227] = 04546; $code[000227] = *I00227; sub I00227 { $core[($ib<<12)+$core[102]] = 00230; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[000230] = 04546; $code[000230] = *I00230; sub I00230 { $core[($ib<<12)+$core[102]] = 00231; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[000231] = 01132; $code[000231] = *I00231; sub I00231 { $lac += $core[000132]; goto &fetch; }
$core[000232] = 03017; $code[000232] = *L00232; sub L00232 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[000233] = 03020; $code[000233] = *I00233; sub I00233 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[000234] = 04545; $code[000234] = *I00234; sub I00234 { $core[($ib<<12)+$core[101]] = 00235; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000235] = 01035; $code[000235] = *I00235; sub I00235 { $lac += $core[000035]; goto &fetch; }
$core[000236] = 03013; $code[000236] = *I00236; sub I00236 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[000237] = 04560; $code[000237] = *I00237; sub I00237 { $core[($ib<<12)+$core[112]] = 00240; $pc = ($ib<<12)+$core[112]+1; $code[($ib<<12)+$core[112]] = *emul8; $inh = 0; goto &fetch; }
$core[000240] = 04561; $code[000240] = *I00240; sub I00240 { $core[($ib<<12)+$core[113]] = 00241; $pc = ($ib<<12)+$core[113]+1; $code[($ib<<12)+$core[113]] = *emul8; $inh = 0; goto &fetch; }
$core[000241] = 05362; $code[000241] = *I00241; sub I00241 { $pc = 000362; $inh = 0; goto &fetch; }
$core[000242] = 05271; $code[000242] = *D00242; sub D00242 { $pc = 000271; $inh = 0; goto &fetch; }
$core[000243] = 02026; $code[000243] = *I00243; sub I00243 { if (++$core[000026] == 010000) { $core[000026] = 0; $pc++; }$code[000026] = *emul8; goto &fetch; }
$core[000244] = 04554; $code[000244] = *I00244; sub I00244 { $core[($ib<<12)+$core[108]] = 00245; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[000245] = 01124; $code[000245] = *I00245; sub I00245 { $lac += $core[000124]; goto &fetch; }
$core[000246] = 01065; $code[000246] = *I00246; sub I00246 { $lac += $core[000065]; goto &fetch; }
$core[000247] = 07640; $code[000247] = *I00247; sub I00247 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000250] = 04566; $code[000250] = *I00250; sub I00250 { $core[($ib<<12)+$core[118]] = 00251; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000251] = 01060; $code[000251] = *I00251; sub I00251 { $lac += $core[000060]; goto &fetch; }
$core[000252] = 03010; $code[000252] = *D00252; sub D00252 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000253] = 03062; $code[000253] = *I00253; sub I00253 { $core[000062] = $lac & 07777; $lac &= 010000; $code[000062] = *emul8; goto &fetch; }
$core[000254] = 01067; $code[000254] = *I00254; sub I00254 { $lac += $core[000067]; goto &fetch; }
$core[000255] = 03410; $code[000255] = *I00255; sub I00255 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000256] = 04560; $code[000256] = *D00256; sub D00256 { $core[($ib<<12)+$core[112]] = 00257; $pc = ($ib<<12)+$core[112]+1; $code[($ib<<12)+$core[112]] = *emul8; $inh = 0; goto &fetch; }
$core[000257] = 07410; $code[000257] = *I00257; sub I00257 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000260] = 04545; $code[000260] = *L00260; sub L00260 { $core[($ib<<12)+$core[101]] = 00261; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000261] = 04546; $code[000261] = *I00261; sub I00261 { $core[($ib<<12)+$core[102]] = 00262; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[000262] = 01066; $code[000262] = *I00262; sub I00262 { $lac += $core[000066]; goto &fetch; }
$core[000263] = 01116; $code[000263] = *I00263; sub I00263 { $lac += $core[000116]; goto &fetch; }
$core[000264] = 07640; $code[000264] = *I00264; sub I00264 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000265] = 05260; $code[000265] = *I00265; sub I00265 { $pc = 000260; $inh = 0; goto &fetch; }
$core[000266] = 04565; $code[000266] = *I00266; sub I00266 { $core[($ib<<12)+$core[117]] = 00267; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[000267] = 04556; $code[000267] = *I00267; sub I00267 { $core[($ib<<12)+$core[110]] = 00270; $pc = ($ib<<12)+$core[110]+1; $code[($ib<<12)+$core[110]] = *emul8; $inh = 0; goto &fetch; }
$core[000270] = 05177; $code[000270] = *I00270; sub I00270 { $pc = 000177; $inh = 0; goto &fetch; }
$core[000271] = 04540; $code[000271] = *L00271; sub L00271 { $core[($ib<<12)+$core[96]] = 00272; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[000272] = 00611; $code[000272] = *I00272; sub I00272 { $lac &= (010000|$core[($df<<12)+$core[137]]); goto &fetch; }
$core[000273] = 01422; $code[000273] = *D00273; sub D00273 { $lac += $core[($df<<12)+$core[18]]; goto &fetch; }
$core[000274] = 07450; $code[000274] = *I00274; sub I00274 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000275] = 05177; $code[000275] = *I00275; sub I00275 { $pc = 000177; $inh = 0; goto &fetch; }
$core[000276] = 03022; $code[000276] = *I00276; sub I00276 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[000277] = 01022; $code[000277] = *I00277; sub I00277 { $lac += $core[000022]; goto &fetch; }
$core[000300] = 07001; $code[000300] = *I00300; sub I00300 { $lac++; goto &fetch; }
$core[000301] = 05232; $code[000301] = *I00301; sub I00301 { $pc = 000232; $inh = 0; goto &fetch; }
$core[000302] = 00000; $code[000302] = *S00302; sub S00302 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000303] = 04560; $code[000303] = *D00303; sub D00303 { $core[($ib<<12)+$core[112]] = 00304; $pc = ($ib<<12)+$core[112]+1; $code[($ib<<12)+$core[112]] = *emul8; $inh = 0; goto &fetch; }
$core[000304] = 01066; $code[000304] = *I00304; sub I00304 { $lac += $core[000066]; goto &fetch; }
$core[000305] = 01112; $code[000305] = *I00305; sub I00305 { $lac += $core[000112]; goto &fetch; }
$core[000306] = 07650; $code[000306] = *I00306; sub I00306 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000307] = 05322; $code[000307] = *I00307; sub I00307 { $pc = 000322; $inh = 0; goto &fetch; }
$core[000310] = 03036; $code[000310] = *I00310; sub I00310 { $core[000036] = $lac & 07777; $lac &= 010000; $code[000036] = *emul8; goto &fetch; }
$core[000311] = 04771; $code[000311] = *I00311; sub I00311 { $core[($ib<<12)+$core[249]] = 00312; $pc = ($ib<<12)+$core[249]+1; $code[($ib<<12)+$core[249]] = *emul8; $inh = 0; goto &fetch; }
$core[000312] = 01047; $code[000312] = *I00312; sub I00312 { $lac += $core[000047]; goto &fetch; }
$core[000313] = 00372; $code[000313] = *I00313; sub I00313 { $lac &= (010000|$core[000372]); goto &fetch; }
$core[000314] = 01046; $code[000314] = *I00314; sub I00314 { $lac += $core[000046]; goto &fetch; }
$core[000315] = 07640; $code[000315] = *I00315; sub I00315 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000316] = 04566; $code[000316] = *I00316; sub I00316 { $core[($ib<<12)+$core[118]] = 00317; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000317] = 01047; $code[000317] = *I00317; sub I00317 { $lac += $core[000047]; goto &fetch; }
$core[000320] = 04557; $code[000320] = *I00320; sub I00320 { $core[($ib<<12)+$core[111]] = 00321; $pc = ($ib<<12)+$core[111]+1; $code[($ib<<12)+$core[111]] = *emul8; $inh = 0; goto &fetch; }
$core[000321] = 07004; $code[000321] = *D00321; sub D00321 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000322] = 03067; $code[000322] = *L00322; sub L00322 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000323] = 04561; $code[000323] = *I00323; sub I00323 { $core[($ib<<12)+$core[113]] = 00324; $pc = ($ib<<12)+$core[113]+1; $code[($ib<<12)+$core[113]] = *emul8; $inh = 0; goto &fetch; }
$core[000324] = 04545; $code[000324] = *D00324; sub D00324 { $core[($ib<<12)+$core[101]] = 00325; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000325] = 04561; $code[000325] = *I00325; sub I00325 { $core[($ib<<12)+$core[113]] = 00326; $pc = ($ib<<12)+$core[113]+1; $code[($ib<<12)+$core[113]] = *emul8; $inh = 0; goto &fetch; }
$core[000326] = 05340; $code[000326] = *I00326; sub I00326 { $pc = 000340; $inh = 0; goto &fetch; }
$core[000327] = 05352; $code[000327] = *I00327; sub I00327 { $pc = 000352; $inh = 0; goto &fetch; }
$core[000330] = 01054; $code[000330] = *I00330; sub I00330 { $lac += $core[000054]; goto &fetch; }
$core[000331] = 07106; $code[000331] = *I00331; sub I00331 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000332] = 01054; $code[000332] = *I00332; sub I00332 { $lac += $core[000054]; goto &fetch; }
$core[000333] = 07004; $code[000333] = *I00333; sub I00333 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000334] = 01067; $code[000334] = *I00334; sub I00334 { $lac += $core[000067]; goto &fetch; }
$core[000335] = 03067; $code[000335] = *I00335; sub I00335 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000336] = 04545; $code[000336] = *I00336; sub I00336 { $core[($ib<<12)+$core[101]] = 00337; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000337] = 04561; $code[000337] = *I00337; sub I00337 { $core[($ib<<12)+$core[113]] = 00340; $pc = ($ib<<12)+$core[113]+1; $code[($ib<<12)+$core[113]] = *emul8; $inh = 0; goto &fetch; }
$core[000340] = 04566; $code[000340] = *L00340; sub L00340 { $core[($ib<<12)+$core[118]] = 00341; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000341] = 05352; $code[000341] = *I00341; sub I00341 { $pc = 000352; $inh = 0; goto &fetch; }
$core[000342] = 01054; $code[000342] = *I00342; sub I00342 { $lac += $core[000054]; goto &fetch; }
$core[000343] = 01067; $code[000343] = *I00343; sub I00343 { $lac += $core[000067]; goto &fetch; }
$core[000344] = 03067; $code[000344] = *I00344; sub I00344 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000345] = 04545; $code[000345] = *I00345; sub I00345 { $core[($ib<<12)+$core[101]] = 00346; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000346] = 04561; $code[000346] = *I00346; sub I00346 { $core[($ib<<12)+$core[113]] = 00347; $pc = ($ib<<12)+$core[113]+1; $code[($ib<<12)+$core[113]] = *emul8; $inh = 0; goto &fetch; }
$core[000347] = 05340; $code[000347] = *I00347; sub I00347 { $pc = 000340; $inh = 0; goto &fetch; }
$core[000350] = 07410; $code[000350] = *I00350; sub I00350 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000351] = 04566; $code[000351] = *I00351; sub I00351 { $core[($ib<<12)+$core[118]] = 00352; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000352] = 07100; $code[000352] = *L00352; sub L00352 { $lac &= 07777; goto &fetch; }
$core[000353] = 01067; $code[000353] = *I00353; sub I00353 { $lac += $core[000067]; goto &fetch; }
$core[000354] = 00104; $code[000354] = *I00354; sub I00354 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[000355] = 07640; $code[000355] = *I00355; sub I00355 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000356] = 07020; $code[000356] = *I00356; sub I00356 { $lac ^= 010000; goto &fetch; }
$core[000357] = 01067; $code[000357] = *I00357; sub I00357 { $lac += $core[000067]; goto &fetch; }
$core[000360] = 00106; $code[000360] = *I00360; sub I00360 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[000361] = 07460; $code[000361] = *I00361; sub I00361 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000362] = 04566; $code[000362] = *L00362; sub L00362 { $core[($ib<<12)+$core[118]] = 00363; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000363] = 07640; $code[000363] = *I00363; sub I00363 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000364] = 01373; $code[000364] = *I00364; sub I00364 { $lac += $core[000373]; goto &fetch; }
$core[000365] = 07020; $code[000365] = *I00365; sub I00365 { $lac ^= 010000; goto &fetch; }
$core[000366] = 07004; $code[000366] = *I00366; sub I00366 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000367] = 03065; $code[000367] = *I00367; sub I00367 { $core[000065] = $lac & 07777; $lac &= 010000; $code[000065] = *emul8; goto &fetch; }
$core[000370] = 05702; $code[000370] = *I00370; sub I00370 { $pc = ($ib<<12)+$core[194]; $inh = 0; goto &fetch; }
$core[000371] = 05600; $code[000371] = *P00371; sub P00371 { $pc = ($ib<<12)+$core[128]; $inh = 0; goto &fetch; }
$core[000372] = 07740; $code[000372] = *D00372; sub D00372 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000373] = 02000; $code[000373] = *D00373; sub D00373 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[000374] = 02014; $code[000374] = *I00374; sub I00374 { if (++$core[000014] == 010000) { $core[000014] = 0; $pc++; }$code[000014] = *emul8; goto &fetch; }
$core[000375] = 02010; $code[000375] = *I00375; sub I00375 { if (++$core[000010] == 010000) { $core[000010] = 0; $pc++; }$code[000010] = *emul8; goto &fetch; }
$core[000376] = 01160; $code[000376] = *I00376; sub I00376 { $lac += $core[000160]; goto &fetch; }
$core[000377] = 01142; $code[000377] = *I00377; sub I00377 { $lac += $core[000142]; goto &fetch; }
$core[000400] = 01553; $code[000400] = *L00400; sub L00400 { $lac += $core[($df<<12)+$core[107]]; goto &fetch; }
$core[000401] = 01343; $code[000401] = *I00401; sub I00401 { $lac += $core[000543]; goto &fetch; }
$core[000402] = 05000; $code[000402] = *I00402; sub I00402 { $pc = 000000; $inh = 0; goto &fetch; }
$core[000403] = 04620; $code[000403] = *I00403; sub I00403 { $core[($ib<<12)+$core[272]] = 00404; $pc = ($ib<<12)+$core[272]+1; $code[($ib<<12)+$core[272]] = *emul8; $inh = 0; goto &fetch; }
$core[000404] = 05040; $code[000404] = *I00404; sub I00404 { $pc = 000040; $inh = 0; goto &fetch; }
$core[000405] = 05205; $code[000405] = *L00405; sub L00405 { $pc = 000405; $inh = 0; goto &fetch; }
$core[000406] = 05200; $code[000406] = *P00406; sub P00406 { $pc = 000400; $inh = 0; goto &fetch; }
$core[000407] = 07400; $code[000407] = *I00407; sub I00407 { goto &fetch; }
$core[000410] = 02725; $code[000410] = *P00410; sub P00410 { if (++$core[($df<<12)+$core[341]] == 010000) { $core[($df<<12)+$core[341]] = 0; $pc++; }$code[($df<<12)+$core[341]] = *emul8; goto &fetch; }
$core[000411] = 02725; $code[000411] = *P00411; sub P00411 { if (++$core[($df<<12)+$core[341]] == 010000) { $core[($df<<12)+$core[341]] = 0; $pc++; }$code[($df<<12)+$core[341]] = *emul8; goto &fetch; }
$core[000412] = 02725; $code[000412] = *D00412; sub D00412 { if (++$core[($df<<12)+$core[341]] == 010000) { $core[($df<<12)+$core[341]] = 0; $pc++; }$code[($df<<12)+$core[341]] = *emul8; goto &fetch; }
$core[000413] = 00000; $code[000413] = *S00413; sub S00413 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000414] = 07106; $code[000414] = *I00414; sub I00414 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000415] = 07006; $code[000415] = *I00415; sub I00415 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000416] = 07006; $code[000416] = *I00416; sub I00416 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000417] = 05613; $code[000417] = *L00417; sub L00417 { $pc = ($ib<<12)+$core[267]; $inh = 0; goto &fetch; }
$core[000420] = 04554; $code[000420] = *P00420; sub P00420 { $core[($ib<<12)+$core[108]] = 00421; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[000421] = 01022; $code[000421] = *I00421; sub I00421 { $lac += $core[000022]; goto &fetch; }
$core[000422] = 04542; $code[000422] = *I00422; sub I00422 { $core[($ib<<12)+$core[98]] = 00423; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[000423] = 04543; $code[000423] = *I00423; sub I00423 { $core[($ib<<12)+$core[99]] = 00424; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[000424] = 00017; $code[000424] = *I00424; sub I00424 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[000425] = 04543; $code[000425] = *L00425; sub L00425 { $core[($ib<<12)+$core[99]] = 00426; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[000426] = 00065; $code[000426] = *I00426; sub I00426 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[000427] = 01065; $code[000427] = *D00427; sub D00427 { $lac += $core[000065]; goto &fetch; }
$core[000430] = 07710; $code[000430] = *I00430; sub I00430 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000431] = 05263; $code[000431] = *I00431; sub I00431 { $pc = 000463; $inh = 0; goto &fetch; }
$core[000432] = 04555; $code[000432] = *I00432; sub I00432 { $core[($ib<<12)+$core[109]] = 00433; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[000433] = 07000; $code[000433] = *I00433; sub I00433 { goto &fetch; }
$core[000434] = 01023; $code[000434] = *I00434; sub I00434 { $lac += $core[000023]; goto &fetch; }
$core[000435] = 03011; $code[000435] = *I00435; sub I00435 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000436] = 01411; $code[000436] = *I00436; sub I00436 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[000437] = 04563; $code[000437] = *I00437; sub I00437 { $core[($ib<<12)+$core[115]] = 00440; $pc = ($ib<<12)+$core[115]+1; $code[($ib<<12)+$core[115]] = *emul8; $inh = 0; goto &fetch; }
$core[000440] = 04566; $code[000440] = *I00440; sub I00440 { $core[($ib<<12)+$core[118]] = 00441; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000441] = 04540; $code[000441] = *I00441; sub I00441 { $core[($ib<<12)+$core[96]] = 00442; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[000442] = 00606; $code[000442] = *I00442; sub I00442 { $lac &= (010000|$core[($df<<12)+$core[262]]); goto &fetch; }
$core[000443] = 04544; $code[000443] = *I00443; sub I00443 { $core[($ib<<12)+$core[100]] = 00444; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[000444] = 00065; $code[000444] = *I00444; sub I00444 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[000445] = 01422; $code[000445] = *I00445; sub I00445 { $lac += $core[($df<<12)+$core[18]]; goto &fetch; }
$core[000446] = 07450; $code[000446] = *I00446; sub I00446 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000447] = 05271; $code[000447] = *I00447; sub I00447 { $pc = 000471; $inh = 0; goto &fetch; }
$core[000450] = 07001; $code[000450] = *I00450; sub I00450 { $lac++; goto &fetch; }
$core[000451] = 03030; $code[000451] = *I00451; sub I00451 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[000452] = 01065; $code[000452] = *I00452; sub I00452 { $lac += $core[000065]; goto &fetch; }
$core[000453] = 07740; $code[000453] = *I00453; sub I00453 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000454] = 05260; $code[000454] = *I00454; sub I00454 { $pc = 000460; $inh = 0; goto &fetch; }
$core[000455] = 01430; $code[000455] = *I00455; sub I00455 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[000456] = 04563; $code[000456] = *I00456; sub I00456 { $core[($ib<<12)+$core[115]] = 00457; $pc = ($ib<<12)+$core[115]+1; $code[($ib<<12)+$core[115]] = *emul8; $inh = 0; goto &fetch; }
$core[000457] = 05271; $code[000457] = *I00457; sub I00457 { $pc = 000471; $inh = 0; goto &fetch; }
$core[000460] = 01430; $code[000460] = *L00460; sub L00460 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[000461] = 03067; $code[000461] = *I00461; sub I00461 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000462] = 05225; $code[000462] = *I00462; sub I00462 { $pc = 000425; $inh = 0; goto &fetch; }
$core[000463] = 04555; $code[000463] = *L00463; sub L00463 { $core[($ib<<12)+$core[109]] = 00464; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[000464] = 04566; $code[000464] = *I00464; sub I00464 { $core[($ib<<12)+$core[118]] = 00465; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000465] = 04540; $code[000465] = *I00465; sub I00465 { $core[($ib<<12)+$core[96]] = 00466; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[000466] = 00610; $code[000466] = *I00466; sub I00466 { $lac &= (010000|$core[($df<<12)+$core[264]]); goto &fetch; }
$core[000467] = 04544; $code[000467] = *I00467; sub I00467 { $core[($ib<<12)+$core[100]] = 00470; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[000470] = 00065; $code[000470] = *I00470; sub I00470 { $lac &= (010000|$core[000065]); goto &fetch; }
$core[000471] = 04544; $code[000471] = *L00471; sub L00471 { $core[($ib<<12)+$core[100]] = 00472; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[000472] = 00017; $code[000472] = *I00472; sub I00472 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[000473] = 01413; $code[000473] = *I00473; sub I00473 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[000474] = 03022; $code[000474] = *I00474; sub I00474 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[000475] = 05676; $code[000475] = *I00475; sub I00475 { $pc = ($ib<<12)+$core[318]; $inh = 0; goto &fetch; }
$core[000476] = 00611; $code[000476] = *P00476; sub P00476 { $lac &= (010000|$core[($df<<12)+$core[265]]); goto &fetch; }
$core[000477] = 00000; $code[000477] = *S00477; sub S00477 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000500] = 03071; $code[000500] = *I00500; sub I00500 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[000501] = 07040; $code[000501] = *I00501; sub I00501 { $lac ^= 07777; goto &fetch; }
$core[000502] = 04310; $code[000502] = *I00502; sub I00502 { $core[000510] = 00503; $pc = 000510+1; $code[000510] = *emul8; $inh = 0; goto &fetch; }
$core[000503] = 01071; $code[000503] = *I00503; sub I00503 { $lac += $core[000071]; goto &fetch; }
$core[000504] = 03413; $code[000504] = *I00504; sub I00504 { $core[000013] = 0000 if ++$core[000013] == 010000; $core[($df<<12)+$core[000013]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000013]] = *emul8; goto &fetch; }
$core[000505] = 07040; $code[000505] = *I00505; sub I00505 { $lac ^= 07777; goto &fetch; }
$core[000506] = 04310; $code[000506] = *I00506; sub I00506 { $core[000510] = 00507; $pc = 000510+1; $code[000510] = *emul8; $inh = 0; goto &fetch; }
$core[000507] = 05677; $code[000507] = *I00507; sub I00507 { $pc = ($ib<<12)+$core[319]; $inh = 0; goto &fetch; }
$core[000510] = 00000; $code[000510] = *S00510; sub S00510 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000511] = 01013; $code[000511] = *I00511; sub I00511 { $lac += $core[000013]; goto &fetch; }
$core[000512] = 03013; $code[000512] = *I00512; sub I00512 { $core[000013] = $lac & 07777; $lac &= 010000; $code[000013] = *emul8; goto &fetch; }
$core[000513] = 01013; $code[000513] = *I00513; sub I00513 { $lac += $core[000013]; goto &fetch; }
$core[000514] = 07141; $code[000514] = *I00514; sub I00514 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[000515] = 01031; $code[000515] = *I00515; sub I00515 { $lac += $core[000031]; goto &fetch; }
$core[000516] = 07630; $code[000516] = *I00516; sub I00516 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000517] = 04566; $code[000517] = *I00517; sub I00517 { $core[($ib<<12)+$core[118]] = 00520; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000520] = 05710; $code[000520] = *I00520; sub I00520 { $pc = ($ib<<12)+$core[328]; $inh = 0; goto &fetch; }
$core[000521] = 00000; $code[000521] = *P00521; sub P00521 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000522] = 01721; $code[000522] = *I00522; sub I00522 { $lac += $core[($df<<12)+$core[337]]; goto &fetch; }
$core[000523] = 03071; $code[000523] = *I00523; sub I00523 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[000524] = 07040; $code[000524] = *I00524; sub I00524 { $lac ^= 07777; goto &fetch; }
$core[000525] = 04310; $code[000525] = *P00525; sub P00525 { $core[000510] = 00526; $pc = 000510+1; $code[000510] = *emul8; $inh = 0; goto &fetch; }
$core[000526] = 01321; $code[000526] = *I00526; sub I00526 { $lac += $core[000521]; goto &fetch; }
$core[000527] = 07001; $code[000527] = *I00527; sub I00527 { $lac++; goto &fetch; }
$core[000530] = 03413; $code[000530] = *I00530; sub I00530 { $core[000013] = 0000 if ++$core[000013] == 010000; $core[($df<<12)+$core[000013]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000013]] = *emul8; goto &fetch; }
$core[000531] = 07040; $code[000531] = *I00531; sub I00531 { $lac ^= 07777; goto &fetch; }
$core[000532] = 04310; $code[000532] = *I00532; sub I00532 { $core[000510] = 00533; $pc = 000510+1; $code[000510] = *emul8; $inh = 0; goto &fetch; }
$core[000533] = 05471; $code[000533] = *I00533; sub I00533 { $pc = ($ib<<12)+$core[57]; $inh = 0; goto &fetch; }
$core[000534] = 00000; $code[000534] = *S00534; sub S00534 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000535] = 07240; $code[000535] = *I00535; sub I00535 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000536] = 01734; $code[000536] = *I00536; sub I00536 { $lac += $core[($df<<12)+$core[348]]; goto &fetch; }
$core[000537] = 03011; $code[000537] = *I00537; sub I00537 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000540] = 02334; $code[000540] = *P00540; sub P00540 { if (++$core[000534] == 010000) { $core[000534] = 0; $pc++; }$code[000534] = *emul8; goto &fetch; }
$core[000541] = 01117; $code[000541] = *I00541; sub I00541 { $lac += $core[000117]; goto &fetch; }
$core[000542] = 04310; $code[000542] = *I00542; sub I00542 { $core[000510] = 00543; $pc = 000510+1; $code[000510] = *emul8; $inh = 0; goto &fetch; }
$core[000543] = 01117; $code[000543] = *D00543; sub D00543 { $lac += $core[000117]; goto &fetch; }
$core[000544] = 03071; $code[000544] = *I00544; sub I00544 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[000545] = 01411; $code[000545] = *L00545; sub L00545 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[000546] = 03413; $code[000546] = *I00546; sub I00546 { $core[000013] = 0000 if ++$core[000013] == 010000; $core[($df<<12)+$core[000013]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000013]] = *emul8; goto &fetch; }
$core[000547] = 02071; $code[000547] = *I00547; sub I00547 { if (++$core[000071] == 010000) { $core[000071] = 0; $pc++; }$code[000071] = *emul8; goto &fetch; }
$core[000550] = 05345; $code[000550] = *I00550; sub I00550 { $pc = 000545; $inh = 0; goto &fetch; }
$core[000551] = 01117; $code[000551] = *I00551; sub I00551 { $lac += $core[000117]; goto &fetch; }
$core[000552] = 04310; $code[000552] = *I00552; sub I00552 { $core[000510] = 00553; $pc = 000510+1; $code[000510] = *emul8; $inh = 0; goto &fetch; }
$core[000553] = 05734; $code[000553] = *I00553; sub I00553 { $pc = ($ib<<12)+$core[348]; $inh = 0; goto &fetch; }
$core[000554] = 00000; $code[000554] = *S00554; sub S00554 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000555] = 07240; $code[000555] = *I00555; sub I00555 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[000556] = 01754; $code[000556] = *I00556; sub I00556 { $lac += $core[($df<<12)+$core[364]]; goto &fetch; }
$core[000557] = 02354; $code[000557] = *I00557; sub I00557 { if (++$core[000554] == 010000) { $core[000554] = 0; $pc++; }$code[000554] = *emul8; goto &fetch; }
$core[000560] = 03011; $code[000560] = *I00560; sub I00560 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[000561] = 01117; $code[000561] = *I00561; sub I00561 { $lac += $core[000117]; goto &fetch; }
$core[000562] = 03071; $code[000562] = *I00562; sub I00562 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[000563] = 01413; $code[000563] = *L00563; sub L00563 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[000564] = 03411; $code[000564] = *I00564; sub I00564 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[000565] = 02071; $code[000565] = *I00565; sub I00565 { if (++$core[000071] == 010000) { $core[000071] = 0; $pc++; }$code[000071] = *emul8; goto &fetch; }
$core[000566] = 05363; $code[000566] = *I00566; sub I00566 { $pc = 000563; $inh = 0; goto &fetch; }
$core[000567] = 05754; $code[000567] = *I00567; sub I00567 { $pc = ($ib<<12)+$core[364]; $inh = 0; goto &fetch; }
$core[000570] = 02740; $code[000570] = *I00570; sub I00570 { if (++$core[($df<<12)+$core[352]] == 010000) { $core[($df<<12)+$core[352]] = 0; $pc++; }$code[($df<<12)+$core[352]] = *emul8; goto &fetch; }
$core[000571] = 00212; $code[000571] = *I00571; sub I00571 { $lac &= (010000|$core[000412]); goto &fetch; }
$core[000572] = 00217; $code[000572] = *I00572; sub I00572 { $lac &= (010000|$core[000417]); goto &fetch; }
$core[000573] = 00227; $code[000573] = *I00573; sub I00573 { $lac &= (010000|$core[000427]); goto &fetch; }
$core[000574] = 01075; $code[000574] = *I00574; sub I00574 { $lac += $core[000075]; goto &fetch; }
$core[000575] = 01137; $code[000575] = *I00575; sub I00575 { $lac += $core[000137]; goto &fetch; }
$core[000576] = 02725; $code[000576] = *I00576; sub I00576 { if (++$core[($df<<12)+$core[341]] == 010000) { $core[($df<<12)+$core[341]] = 0; $pc++; }$code[($df<<12)+$core[341]] = *emul8; goto &fetch; }
$core[000577] = 01065; $code[000577] = *I00577; sub I00577 { $lac += $core[000065]; goto &fetch; }
$core[000600] = 00610; $code[000600] = *I00600; sub I00600 { $lac &= (010000|$core[($df<<12)+$core[392]]); goto &fetch; }
$core[000601] = 00614; $code[000601] = *I00601; sub I00601 { $lac &= (010000|$core[($df<<12)+$core[396]]); goto &fetch; }
$core[000602] = 07472; $code[000602] = *D00602; sub D00602 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $hlt = 1; goto &fetch; }
$core[000603] = 04554; $code[000603] = *L00603; sub L00603 { $core[($ib<<12)+$core[108]] = 00604; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[000604] = 04555; $code[000604] = *I00604; sub I00604 { $core[($ib<<12)+$core[109]] = 00605; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[000605] = 04566; $code[000605] = *I00605; sub I00605 { $core[($ib<<12)+$core[118]] = 00606; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000606] = 01023; $code[000606] = *I00606; sub I00606 { $lac += $core[000023]; goto &fetch; }
$core[000607] = 03022; $code[000607] = *I00607; sub I00607 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[000610] = 04545; $code[000610] = *P00610; sub P00610 { $core[($ib<<12)+$core[101]] = 00611; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000611] = 01066; $code[000611] = *L00611; sub L00611 { $lac += $core[000066]; goto &fetch; }
$core[000612] = 01116; $code[000612] = *I00612; sub I00612 { $lac += $core[000116]; goto &fetch; }
$core[000613] = 07650; $code[000613] = *I00613; sub I00613 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000614] = 05541; $code[000614] = *P00614; sub P00614 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[000615] = 04550; $code[000615] = *I00615; sub I00615 { $core[($ib<<12)+$core[104]] = 00616; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[000616] = 01376; $code[000616] = *I00616; sub I00616 { $lac += $core[000776]; goto &fetch; }
$core[000617] = 05210; $code[000617] = *I00617; sub I00617 { $pc = 000610; $inh = 0; goto &fetch; }
$core[000620] = 01066; $code[000620] = *I00620; sub I00620 { $lac += $core[000066]; goto &fetch; }
$core[000621] = 00075; $code[000621] = *I00621; sub I00621 { $lac &= (010000|$core[000075]); goto &fetch; }
$core[000622] = 04542; $code[000622] = *I00622; sub I00622 { $core[($ib<<12)+$core[98]] = 00623; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[000623] = 04545; $code[000623] = *L00623; sub L00623 { $core[($ib<<12)+$core[101]] = 00624; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000624] = 04550; $code[000624] = *I00624; sub I00624 { $core[($ib<<12)+$core[104]] = 00625; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[000625] = 01376; $code[000625] = *I00625; sub I00625 { $lac += $core[000776]; goto &fetch; }
$core[000626] = 07410; $code[000626] = *I00626; sub I00626 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000627] = 05223; $code[000627] = *I00627; sub I00627 { $pc = 000623; $inh = 0; goto &fetch; }
$core[000630] = 01413; $code[000630] = *I00630; sub I00630 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[000631] = 04547; $code[000631] = *I00631; sub I00631 { $core[($ib<<12)+$core[103]] = 00632; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[000632] = 00773; $code[000632] = *I00632; sub I00632 { $lac &= (010000|$core[($df<<12)+$core[507]]); goto &fetch; }
$core[000633] = 00167; $code[000633] = *I00633; sub I00633 { $lac &= (010000|$core[000167]); goto &fetch; }
$core[000634] = 04566; $code[000634] = *I00634; sub I00634 { $core[($ib<<12)+$core[118]] = 00635; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[000635] = 04554; $code[000635] = *I00635; sub I00635 { $core[($ib<<12)+$core[108]] = 00636; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[000636] = 02026; $code[000636] = *I00636; sub I00636 { if (++$core[000026] == 010000) { $core[000026] = 0; $pc++; }$code[000026] = *emul8; goto &fetch; }
$core[000637] = 04555; $code[000637] = *L00637; sub L00637 { $core[($ib<<12)+$core[109]] = 00640; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[000640] = 05267; $code[000640] = *I00640; sub I00640 { $pc = 000667; $inh = 0; goto &fetch; }
$core[000641] = 01067; $code[000641] = *I00641; sub I00641 { $lac += $core[000067]; goto &fetch; }
$core[000642] = 07640; $code[000642] = *I00642; sub I00642 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000643] = 04553; $code[000643] = *I00643; sub I00643 { $core[($ib<<12)+$core[107]] = 00644; $pc = ($ib<<12)+$core[107]+1; $code[($ib<<12)+$core[107]] = *emul8; $inh = 0; goto &fetch; }
$core[000644] = 04545; $code[000644] = *L00644; sub L00644 { $core[($ib<<12)+$core[101]] = 00645; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000645] = 04551; $code[000645] = *I00645; sub I00645 { $core[($ib<<12)+$core[105]] = 00646; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[000646] = 01066; $code[000646] = *I00646; sub I00646 { $lac += $core[000066]; goto &fetch; }
$core[000647] = 01116; $code[000647] = *I00647; sub I00647 { $lac += $core[000116]; goto &fetch; }
$core[000650] = 07640; $code[000650] = *I00650; sub I00650 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000651] = 05244; $code[000651] = *I00651; sub I00651 { $pc = 000644; $inh = 0; goto &fetch; }
$core[000652] = 01423; $code[000652] = *I00652; sub I00652 { $lac += $core[($df<<12)+$core[19]]; goto &fetch; }
$core[000653] = 07450; $code[000653] = *L00653; sub L00653 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000654] = 05271; $code[000654] = *I00654; sub I00654 { $pc = 000671; $inh = 0; goto &fetch; }
$core[000655] = 07001; $code[000655] = *I00655; sub I00655 { $lac++; goto &fetch; }
$core[000656] = 03030; $code[000656] = *I00656; sub I00656 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[000657] = 01065; $code[000657] = *I00657; sub I00657 { $lac += $core[000065]; goto &fetch; }
$core[000660] = 07700; $code[000660] = *I00660; sub I00660 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000661] = 01430; $code[000661] = *I00661; sub I00661 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[000662] = 04563; $code[000662] = *I00662; sub I00662 { $core[($ib<<12)+$core[115]] = 00663; $pc = ($ib<<12)+$core[115]+1; $code[($ib<<12)+$core[115]] = *emul8; $inh = 0; goto &fetch; }
$core[000663] = 05273; $code[000663] = *I00663; sub I00663 { $pc = 000673; $inh = 0; goto &fetch; }
$core[000664] = 01430; $code[000664] = *L00664; sub L00664 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[000665] = 03067; $code[000665] = *I00665; sub I00665 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[000666] = 05237; $code[000666] = *I00666; sub I00666 { $pc = 000637; $inh = 0; goto &fetch; }
$core[000667] = 01023; $code[000667] = *L00667; sub L00667 { $lac += $core[000023]; goto &fetch; }
$core[000670] = 05253; $code[000670] = *I00670; sub I00670 { $pc = 000653; $inh = 0; goto &fetch; }
$core[000671] = 03026; $code[000671] = *L00671; sub L00671 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[000672] = 05541; $code[000672] = *I00672; sub I00672 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[000673] = 01065; $code[000673] = *L00673; sub L00673 { $lac += $core[000065]; goto &fetch; }
$core[000674] = 07750; $code[000674] = *I00674; sub I00674 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000675] = 05271; $code[000675] = *I00675; sub I00675 { $pc = 000671; $inh = 0; goto &fetch; }
$core[000676] = 04551; $code[000676] = *I00676; sub I00676 { $core[($ib<<12)+$core[105]] = 00677; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[000677] = 05264; $code[000677] = *I00677; sub I00677 { $pc = 000664; $inh = 0; goto &fetch; }
$core[000700] = 00000; $code[000700] = *S00700; sub S00700 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000701] = 04560; $code[000701] = *I00701; sub I00701 { $core[($ib<<12)+$core[112]] = 00702; $pc = ($ib<<12)+$core[112]+1; $code[($ib<<12)+$core[112]] = *emul8; $inh = 0; goto &fetch; }
$core[000702] = 04550; $code[000702] = *I00702; sub I00702 { $core[($ib<<12)+$core[104]] = 00703; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[000703] = 01767; $code[000703] = *I00703; sub I00703 { $lac += $core[($df<<12)+$core[503]]; goto &fetch; }
$core[000704] = 05700; $code[000704] = *D00704; sub D00704 { $pc = ($ib<<12)+$core[448]; $inh = 0; goto &fetch; }
$core[000705] = 01066; $code[000705] = *I00705; sub I00705 { $lac += $core[000066]; goto &fetch; }
$core[000706] = 02300; $code[000706] = *D00706; sub D00706 { if (++$core[000700] == 010000) { $core[000700] = 0; $pc++; }$code[000700] = *emul8; goto &fetch; }
$core[000707] = 01202; $code[000707] = *I00707; sub I00707 { $lac += $core[000602]; goto &fetch; }
$core[000710] = 07650; $code[000710] = *I00710; sub I00710 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000711] = 05317; $code[000711] = *D00711; sub D00711 { $pc = 000717; $inh = 0; goto &fetch; }
$core[000712] = 04561; $code[000712] = *I00712; sub I00712 { $core[($ib<<12)+$core[113]] = 00713; $pc = ($ib<<12)+$core[113]+1; $code[($ib<<12)+$core[113]] = *emul8; $inh = 0; goto &fetch; }
$core[000713] = 05700; $code[000713] = *I00713; sub I00713 { $pc = ($ib<<12)+$core[448]; $inh = 0; goto &fetch; }
$core[000714] = 07410; $code[000714] = *I00714; sub I00714 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000715] = 05700; $code[000715] = *I00715; sub I00715 { $pc = ($ib<<12)+$core[448]; $inh = 0; goto &fetch; }
$core[000716] = 02300; $code[000716] = *I00716; sub I00716 { if (++$core[000700] == 010000) { $core[000700] = 0; $pc++; }$code[000700] = *emul8; goto &fetch; }
$core[000717] = 02300; $code[000717] = *L00717; sub L00717 { if (++$core[000700] == 010000) { $core[000700] = 0; $pc++; }$code[000700] = *emul8; goto &fetch; }
$core[000720] = 05700; $code[000720] = *I00720; sub I00720 { $pc = ($ib<<12)+$core[448]; $inh = 0; goto &fetch; }
$core[000721] = 00000; $code[000721] = *S00721; sub S00721 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000722] = 01721; $code[000722] = *I00722; sub I00722 { $lac += $core[($df<<12)+$core[465]]; goto &fetch; }
$core[000723] = 03012; $code[000723] = *D00723; sub D00723 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[000724] = 01412; $code[000724] = *L00724; sub L00724 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac += $core[($df<<12)+$core[000012]]; goto &fetch; }
$core[000725] = 07510; $code[000725] = *I00725; sub I00725 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000726] = 05340; $code[000726] = *I00726; sub I00726 { $pc = 000740; $inh = 0; goto &fetch; }
$core[000727] = 07041; $code[000727] = *I00727; sub I00727 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000730] = 01066; $code[000730] = *I00730; sub I00730 { $lac += $core[000066]; goto &fetch; }
$core[000731] = 07640; $code[000731] = *I00731; sub I00731 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000732] = 05324; $code[000732] = *I00732; sub I00732 { $pc = 000724; $inh = 0; goto &fetch; }
$core[000733] = 01721; $code[000733] = *I00733; sub I00733 { $lac += $core[($df<<12)+$core[465]]; goto &fetch; }
$core[000734] = 07040; $code[000734] = *I00734; sub I00734 { $lac ^= 07777; goto &fetch; }
$core[000735] = 01012; $code[000735] = *I00735; sub I00735 { $lac += $core[000012]; goto &fetch; }
$core[000736] = 03054; $code[000736] = *I00736; sub I00736 { $core[000054] = $lac & 07777; $lac &= 010000; $code[000054] = *emul8; goto &fetch; }
$core[000737] = 07410; $code[000737] = *I00737; sub I00737 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000740] = 02321; $code[000740] = *L00740; sub L00740 { if (++$core[000721] == 010000) { $core[000721] = 0; $pc++; }$code[000721] = *emul8; goto &fetch; }
$core[000741] = 02321; $code[000741] = *I00741; sub I00741 { if (++$core[000721] == 010000) { $core[000721] = 0; $pc++; }$code[000721] = *emul8; goto &fetch; }
$core[000742] = 07300; $code[000742] = *I00742; sub I00742 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000743] = 05721; $code[000743] = *I00743; sub I00743 { $pc = ($ib<<12)+$core[465]; $inh = 0; goto &fetch; }
$core[000744] = 00000; $code[000744] = *S00744; sub S00744 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000745] = 00104; $code[000745] = *I00745; sub I00745 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[000746] = 07041; $code[000746] = *I00746; sub I00746 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000747] = 03071; $code[000747] = *I00747; sub I00747 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[000750] = 01067; $code[000750] = *I00750; sub I00750 { $lac += $core[000067]; goto &fetch; }
$core[000751] = 00104; $code[000751] = *I00751; sub I00751 { $lac &= (010000|$core[000104]); goto &fetch; }
$core[000752] = 01071; $code[000752] = *I00752; sub I00752 { $lac += $core[000071]; goto &fetch; }
$core[000753] = 07650; $code[000753] = *I00753; sub I00753 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000754] = 02344; $code[000754] = *I00754; sub I00754 { if (++$core[000744] == 010000) { $core[000744] = 0; $pc++; }$code[000744] = *emul8; goto &fetch; }
$core[000755] = 05744; $code[000755] = *I00755; sub I00755 { $pc = ($ib<<12)+$core[484]; $inh = 0; goto &fetch; }
$core[000756] = 00000; $code[000756] = *S00756; sub S00756 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000757] = 01036; $code[000757] = *I00757; sub I00757 { $lac += $core[000036]; goto &fetch; }
$core[000760] = 07640; $code[000760] = *I00760; sub I00760 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000761] = 05364; $code[000761] = *I00761; sub I00761 { $pc = 000764; $inh = 0; goto &fetch; }
$core[000762] = 04545; $code[000762] = *I00762; sub I00762 { $core[($ib<<12)+$core[101]] = 00763; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[000763] = 05756; $code[000763] = *I00763; sub I00763 { $pc = ($ib<<12)+$core[494]; $inh = 0; goto &fetch; }
$core[000764] = 04552; $code[000764] = *L00764; sub L00764 { $core[($ib<<12)+$core[106]] = 00765; $pc = ($ib<<12)+$core[106]+1; $code[($ib<<12)+$core[106]] = *emul8; $inh = 0; goto &fetch; }
$core[000765] = 04547; $code[000765] = *I00765; sub I00765 { $core[($ib<<12)+$core[103]] = 00766; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[000766] = 06776; $code[000766] = *I00766; sub I00766 { &emul8; goto &fetch; }
$core[000767] = 03402; $code[000767] = *P00767; sub P00767 { $core[($df<<12)+$core[2]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2]] = *emul8; goto &fetch; }
$core[000770] = 05756; $code[000770] = *I00770; sub I00770 { $pc = ($ib<<12)+$core[494]; $inh = 0; goto &fetch; }
$core[000771] = 01035; $code[000771] = *I00771; sub I00771 { $lac += $core[000035]; goto &fetch; }
$core[000772] = 00610; $code[000772] = *I00772; sub I00772 { $lac &= (010000|$core[($df<<12)+$core[392]]); goto &fetch; }
$core[000773] = 00614; $code[000773] = *P00773; sub P00773 { $lac &= (010000|$core[($df<<12)+$core[396]]); goto &fetch; }
$core[000774] = 00323; $code[000774] = *I00774; sub I00774 { $lac &= (010000|$core[000723]); goto &fetch; }
$core[000775] = 00306; $code[000775] = *I00775; sub I00775 { $lac &= (010000|$core[000706]); goto &fetch; }
$core[000776] = 00311; $code[000776] = *D00776; sub D00776 { $lac &= (010000|$core[000711]); goto &fetch; }
$core[000777] = 00304; $code[000777] = *I00777; sub I00777 { $lac &= (010000|$core[000704]); goto &fetch; }
$core[001000] = 00307; $code[001000] = *I01000; sub I01000 { $lac &= (010000|$core[001107]); goto &fetch; }
$core[001001] = 00303; $code[001001] = *P01001; sub P01001 { $lac &= (010000|$core[001103]); goto &fetch; }
$core[001002] = 00301; $code[001002] = *D01002; sub D01002 { $lac &= (010000|$core[001101]); goto &fetch; }
$core[001003] = 00324; $code[001003] = *P01003; sub P01003 { $lac &= (010000|$core[001124]); goto &fetch; }
$core[001004] = 00314; $code[001004] = *D01004; sub D01004 { $lac &= (010000|$core[001114]); goto &fetch; }
$core[001005] = 00305; $code[001005] = *I01005; sub I01005 { $lac &= (010000|$core[001105]); goto &fetch; }
$core[001006] = 00327; $code[001006] = *I01006; sub I01006 { $lac &= (010000|$core[001127]); goto &fetch; }
$core[001007] = 00315; $code[001007] = *I01007; sub I01007 { $lac &= (010000|$core[001115]); goto &fetch; }
$core[001010] = 00321; $code[001010] = *P01010; sub P01010 { $lac &= (010000|$core[001121]); goto &fetch; }
$core[001011] = 00322; $code[001011] = *I01011; sub I01011 { $lac &= (010000|$core[001122]); goto &fetch; }
$core[001012] = 00212; $code[001012] = *P01012; sub P01012 { $lac &= (010000|$core[001012]); goto &fetch; }
$core[001013] = 04564; $code[001013] = *I01013; sub I01013 { $core[($ib<<12)+$core[116]] = 01014; $pc = ($ib<<12)+$core[116]+1; $code[($ib<<12)+$core[116]] = *emul8; $inh = 0; goto &fetch; }
$core[001014] = 04637; $code[001014] = *P01014; sub P01014 { $core[($ib<<12)+$core[543]] = 01015; $pc = ($ib<<12)+$core[543]+1; $code[($ib<<12)+$core[543]] = *emul8; $inh = 0; goto &fetch; }
$core[001015] = 02013; $code[001015] = *I01015; sub I01015 { if (++$core[000013] == 010000) { $core[000013] = 0; $pc++; }$code[000013] = *emul8; goto &fetch; }
$core[001016] = 04640; $code[001016] = *I01016; sub I01016 { $core[($ib<<12)+$core[544]] = 01017; $pc = ($ib<<12)+$core[544]+1; $code[($ib<<12)+$core[544]] = *emul8; $inh = 0; goto &fetch; }
$core[001017] = 01111; $code[001017] = *I01017; sub I01017 { $lac += $core[000111]; goto &fetch; }
$core[001020] = 03032; $code[001020] = *I01020; sub I01020 { $core[000032] = $lac & 07777; $lac &= 010000; $code[000032] = *emul8; goto &fetch; }
$core[001021] = 01045; $code[001021] = *I01021; sub I01021 { $lac += $core[000045]; goto &fetch; }
$core[001022] = 07510; $code[001022] = *I01022; sub I01022 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001023] = 02032; $code[001023] = *I01023; sub I01023 { if (++$core[000032] == 010000) { $core[000032] = 0; $pc++; }$code[000032] = *emul8; goto &fetch; }
$core[001024] = 07750; $code[001024] = *I01024; sub I01024 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001025] = 02032; $code[001025] = *L01025; sub L01025 { if (++$core[000032] == 010000) { $core[000032] = 0; $pc++; }$code[000032] = *emul8; goto &fetch; }
$core[001026] = 07410; $code[001026] = *I01026; sub I01026 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001027] = 05767; $code[001027] = *I01027; sub I01027 { $pc = ($ib<<12)+$core[631]; $inh = 0; goto &fetch; }
$core[001030] = 04547; $code[001030] = *L01030; sub L01030 { $core[($ib<<12)+$core[103]] = 01031; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001031] = 01377; $code[001031] = *I01031; sub I01031 { $lac += $core[001177]; goto &fetch; }
$core[001032] = 07371; $code[001032] = *I01032; sub I01032 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001033] = 04545; $code[001033] = *I01033; sub I01033 { $core[($ib<<12)+$core[101]] = 01034; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001034] = 05230; $code[001034] = *I01034; sub I01034 { $pc = 001030; $inh = 0; goto &fetch; }
$core[001035] = 04545; $code[001035] = *P01035; sub P01035 { $core[($ib<<12)+$core[101]] = 01036; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001036] = 05225; $code[001036] = *I01036; sub I01036 { $pc = 001025; $inh = 0; goto &fetch; }
$core[001037] = 01601; $code[001037] = *P01037; sub P01037 { $lac += $core[($df<<12)+$core[513]]; goto &fetch; }
$core[001040] = 02047; $code[001040] = *P01040; sub P01040 { if (++$core[000047] == 010000) { $core[000047] = 0; $pc++; }$code[000047] = *emul8; goto &fetch; }
$core[001041] = 04540; $code[001041] = *D01041; sub D01041 { $core[($ib<<12)+$core[96]] = 01042; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001042] = 01403; $code[001042] = *I01042; sub I01042 { $lac += $core[($df<<12)+$core[3]]; goto &fetch; }
$core[001043] = 04560; $code[001043] = *I01043; sub I01043 { $core[($ib<<12)+$core[112]] = 01044; $pc = ($ib<<12)+$core[112]+1; $code[($ib<<12)+$core[112]] = *emul8; $inh = 0; goto &fetch; }
$core[001044] = 01066; $code[001044] = *I01044; sub I01044 { $lac += $core[000066]; goto &fetch; }
$core[001045] = 01335; $code[001045] = *I01045; sub I01045 { $lac += $core[001135]; goto &fetch; }
$core[001046] = 07440; $code[001046] = *I01046; sub I01046 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001047] = 04566; $code[001047] = *I01047; sub I01047 { $core[($ib<<12)+$core[118]] = 01050; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001050] = 01030; $code[001050] = *I01050; sub I01050 { $lac += $core[000030]; goto &fetch; }
$core[001051] = 04542; $code[001051] = *I01051; sub I01051 { $core[($ib<<12)+$core[98]] = 01052; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001052] = 04540; $code[001052] = *I01052; sub I01052 { $core[($ib<<12)+$core[96]] = 01053; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001053] = 01612; $code[001053] = *I01053; sub I01053 { $lac += $core[($df<<12)+$core[522]]; goto &fetch; }
$core[001054] = 01413; $code[001054] = *D01054; sub D01054 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001055] = 03030; $code[001055] = *I01055; sub I01055 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[001056] = 04407; $code[001056] = *D01056; sub D01056 { $core[($ib<<12)+$core[7]] = 01057; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[001057] = 06430; $code[001057] = *I01057; sub I01057 { &emul8; goto &fetch; }
$core[001060] = 00000; $code[001060] = *I01060; sub I01060 { &emul8; goto &fetch; }
$core[001061] = 04547; $code[001061] = *I01061; sub I01061 { $core[($ib<<12)+$core[103]] = 01062; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001062] = 01377; $code[001062] = *I01062; sub I01062 { $lac += $core[001177]; goto &fetch; }
$core[001063] = 07177; $code[001063] = *I01063; sub I01063 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001064] = 04566; $code[001064] = *I01064; sub I01064 { $core[($ib<<12)+$core[118]] = 01065; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001065] = 01030; $code[001065] = *I01065; sub I01065 { $lac += $core[000030]; goto &fetch; }
$core[001066] = 04542; $code[001066] = *I01066; sub I01066 { $core[($ib<<12)+$core[98]] = 01067; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001067] = 04540; $code[001067] = *I01067; sub I01067 { $core[($ib<<12)+$core[96]] = 01070; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001070] = 01612; $code[001070] = *I01070; sub I01070 { $lac += $core[($df<<12)+$core[522]]; goto &fetch; }
$core[001071] = 04547; $code[001071] = *I01071; sub I01071 { $core[($ib<<12)+$core[103]] = 01072; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001072] = 01377; $code[001072] = *I01072; sub I01072 { $lac += $core[001177]; goto &fetch; }
$core[001073] = 07174; $code[001073] = *I01073; sub I01073 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001074] = 04566; $code[001074] = *I01074; sub I01074 { $core[($ib<<12)+$core[118]] = 01075; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001075] = 04543; $code[001075] = *I01075; sub I01075 { $core[($ib<<12)+$core[99]] = 01076; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001076] = 02030; $code[001076] = *I01076; sub I01076 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[001077] = 04540; $code[001077] = *I01077; sub I01077 { $core[($ib<<12)+$core[96]] = 01100; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001100] = 01612; $code[001100] = *I01100; sub I01100 { $lac += $core[($df<<12)+$core[522]]; goto &fetch; }
$core[001101] = 04543; $code[001101] = *L01101; sub L01101 { $core[($ib<<12)+$core[99]] = 01102; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001102] = 02030; $code[001102] = *I01102; sub I01102 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[001103] = 04543; $code[001103] = *D01103; sub D01103 { $core[($ib<<12)+$core[99]] = 01104; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001104] = 00017; $code[001104] = *I01104; sub I01104 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[001105] = 04540; $code[001105] = *D01105; sub D01105 { $core[($ib<<12)+$core[96]] = 01106; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001106] = 00610; $code[001106] = *D01106; sub D01106 { $lac &= (010000|$core[($df<<12)+$core[520]]); goto &fetch; }
$core[001107] = 04544; $code[001107] = *D01107; sub D01107 { $core[($ib<<12)+$core[100]] = 01110; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001110] = 00017; $code[001110] = *I01110; sub I01110 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[001111] = 04544; $code[001111] = *I01111; sub I01111 { $core[($ib<<12)+$core[100]] = 01112; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001112] = 02030; $code[001112] = *I01112; sub I01112 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[001113] = 04544; $code[001113] = *I01113; sub I01113 { $core[($ib<<12)+$core[100]] = 01114; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001114] = 07470; $code[001114] = *D01114; sub D01114 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001115] = 01413; $code[001115] = *D01115; sub D01115 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001116] = 03030; $code[001116] = *I01116; sub I01116 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[001117] = 04407; $code[001117] = *I01117; sub I01117 { $core[($ib<<12)+$core[7]] = 01120; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[001120] = 00430; $code[001120] = *I01120; sub I01120 { &emul8; goto &fetch; }
$core[001121] = 01733; $code[001121] = *D01121; sub D01121 { &emul8; goto &fetch; }
$core[001122] = 06430; $code[001122] = *D01122; sub D01122 { &emul8; goto &fetch; }
$core[001123] = 02525; $code[001123] = *I01123; sub I01123 { &emul8; goto &fetch; }
$core[001124] = 00000; $code[001124] = *D01124; sub D01124 { &emul8; goto &fetch; }
$core[001125] = 01045; $code[001125] = *D01125; sub D01125 { $lac += $core[000045]; goto &fetch; }
$core[001126] = 07740; $code[001126] = *D01126; sub D01126 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001127] = 05541; $code[001127] = *D01127; sub D01127 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[001130] = 01030; $code[001130] = *I01130; sub I01130 { $lac += $core[000030]; goto &fetch; }
$core[001131] = 04542; $code[001131] = *I01131; sub I01131 { $core[($ib<<12)+$core[98]] = 01132; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001132] = 04543; $code[001132] = *I01132; sub I01132 { $core[($ib<<12)+$core[99]] = 01133; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001133] = 07470; $code[001133] = *P01133; sub P01133 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001134] = 05301; $code[001134] = *I01134; sub I01134 { $pc = 001101; $inh = 0; goto &fetch; }
$core[001135] = 07503; $code[001135] = *D01135; sub D01135 { &emul8; goto &fetch; }
$core[001136] = 07524; $code[001136] = *D01136; sub D01136 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[001137] = 04543; $code[001137] = *I01137; sub I01137 { $core[($ib<<12)+$core[99]] = 01140; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001140] = 02405; $code[001140] = *I01140; sub I01140 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[001141] = 05301; $code[001141] = *I01141; sub I01141 { $pc = 001101; $inh = 0; goto &fetch; }
$core[001142] = 04453; $code[001142] = *I01142; sub I01142 { $core[($ib<<12)+$core[43]] = 01143; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[001143] = 04542; $code[001143] = *I01143; sub I01143 { $core[($ib<<12)+$core[98]] = 01144; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001144] = 01066; $code[001144] = *I01144; sub I01144 { $lac += $core[000066]; goto &fetch; }
$core[001145] = 01336; $code[001145] = *I01145; sub I01145 { $lac += $core[001136]; goto &fetch; }
$core[001146] = 07640; $code[001146] = *I01146; sub I01146 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001147] = 04566; $code[001147] = *I01147; sub I01147 { $core[($ib<<12)+$core[118]] = 01150; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001150] = 04540; $code[001150] = *I01150; sub I01150 { $core[($ib<<12)+$core[96]] = 01151; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001151] = 01612; $code[001151] = *I01151; sub I01151 { $lac += $core[($df<<12)+$core[522]]; goto &fetch; }
$core[001152] = 04453; $code[001152] = *I01152; sub I01152 { $core[($ib<<12)+$core[43]] = 01153; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[001153] = 06063; $code[001153] = *D01153; sub D01153 { &emul8; goto &fetch; }
$core[001154] = 07200; $code[001154] = *I01154; sub I01154 { $lac &= 010000; goto &fetch; }
$core[001155] = 01413; $code[001155] = *I01155; sub I01155 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001156] = 06057; $code[001156] = *D01156; sub D01156 { &emul8; goto &fetch; }
$core[001157] = 07410; $code[001157] = *I01157; sub I01157 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001160] = 04453; $code[001160] = *I01160; sub I01160 { $core[($ib<<12)+$core[43]] = 01161; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[001161] = 07200; $code[001161] = *I01161; sub I01161 { $lac &= 010000; goto &fetch; }
$core[001162] = 05536; $code[001162] = *I01162; sub I01162 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[001163] = 01041; $code[001163] = *I01163; sub I01163 { $lac += $core[000041]; goto &fetch; }
$core[001164] = 01041; $code[001164] = *I01164; sub I01164 { $lac += $core[000041]; goto &fetch; }
$core[001165] = 01013; $code[001165] = *I01165; sub I01165 { $lac += $core[000013]; goto &fetch; }
$core[001166] = 00420; $code[001166] = *I01166; sub I01166 { $lac &= (010000|$core[($df<<12)+$core[16]]); goto &fetch; }
$core[001167] = 00603; $code[001167] = *P01167; sub P01167 { $lac &= (010000|$core[($df<<12)+$core[515]]); goto &fetch; }
$core[001170] = 00614; $code[001170] = *I01170; sub I01170 { $lac &= (010000|$core[($df<<12)+$core[524]]); goto &fetch; }
$core[001171] = 01202; $code[001171] = *I01171; sub I01171 { $lac += $core[001002]; goto &fetch; }
$core[001172] = 01203; $code[001172] = *I01172; sub I01172 { $lac += $core[001003]; goto &fetch; }
$core[001173] = 07503; $code[001173] = *I01173; sub I01173 { &emul8; goto &fetch; }
$core[001174] = 02204; $code[001174] = *I01174; sub I01174 { if (++$core[001004] == 010000) { $core[001004] = 0; $pc++; }$code[001004] = *emul8; goto &fetch; }
$core[001175] = 00635; $code[001175] = *I01175; sub I01175 { $lac &= (010000|$core[($df<<12)+$core[541]]); goto &fetch; }
$core[001176] = 01256; $code[001176] = *I01176; sub I01176 { $lac += $core[001056]; goto &fetch; }
$core[001177] = 00177; $code[001177] = *D01177; sub D01177 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[001200] = 01563; $code[001200] = *I01200; sub I01200 { $lac += $core[($df<<12)+$core[115]]; goto &fetch; }
$core[001201] = 06361; $code[001201] = *I01201; sub I01201 { &emul8; goto &fetch; }
$core[001202] = 07240; $code[001202] = *L01202; sub L01202 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[001203] = 03056; $code[001203] = *L01203; sub L01203 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001204] = 03026; $code[001204] = *L01204; sub L01204 { $core[000026] = $lac & 07777; $lac &= 010000; $code[000026] = *emul8; goto &fetch; }
$core[001205] = 04547; $code[001205] = *I01205; sub I01205 { $core[($ib<<12)+$core[103]] = 01206; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001206] = 01371; $code[001206] = *I01206; sub I01206 { $lac += $core[001371]; goto &fetch; }
$core[001207] = 00176; $code[001207] = *I01207; sub I01207 { $lac &= (010000|$core[000176]); goto &fetch; }
$core[001210] = 02056; $code[001210] = *I01210; sub I01210 { if (++$core[000056] == 010000) { $core[000056] = 0; $pc++; }$code[000056] = *emul8; goto &fetch; }
$core[001211] = 05226; $code[001211] = *I01211; sub I01211 { $pc = 001226; $inh = 0; goto &fetch; }
$core[001212] = 04540; $code[001212] = *I01212; sub I01212 { $core[($ib<<12)+$core[96]] = 01213; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001213] = 01403; $code[001213] = *P01213; sub P01213 { $lac += $core[($df<<12)+$core[3]]; goto &fetch; }
$core[001214] = 01066; $code[001214] = *I01214; sub I01214 { $lac += $core[000066]; goto &fetch; }
$core[001215] = 04542; $code[001215] = *I01215; sub I01215 { $core[($ib<<12)+$core[98]] = 01216; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001216] = 01255; $code[001216] = *I01216; sub I01216 { $lac += $core[001255]; goto &fetch; }
$core[001217] = 04551; $code[001217] = *I01217; sub I01217 { $core[($ib<<12)+$core[105]] = 01220; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[001220] = 02036; $code[001220] = *I01220; sub I01220 { if (++$core[000036] == 010000) { $core[000036] = 0; $pc++; }$code[000036] = *emul8; goto &fetch; }
$core[001221] = 07001; $code[001221] = *I01221; sub I01221 { $lac++; goto &fetch; }
$core[001222] = 04531; $code[001222] = *I01222; sub I01222 { $core[($ib<<12)+$core[89]] = 01223; $pc = ($ib<<12)+$core[89]+1; $code[($ib<<12)+$core[89]] = *emul8; $inh = 0; goto &fetch; }
$core[001223] = 01413; $code[001223] = *I01223; sub I01223 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001224] = 03066; $code[001224] = *I01224; sub I01224 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[001225] = 05202; $code[001225] = *I01225; sub I01225 { $pc = 001202; $inh = 0; goto &fetch; }
$core[001226] = 04540; $code[001226] = *L01226; sub L01226 { $core[($ib<<12)+$core[96]] = 01227; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001227] = 01613; $code[001227] = *I01227; sub I01227 { $lac += $core[($df<<12)+$core[651]]; goto &fetch; }
$core[001230] = 04530; $code[001230] = *I01230; sub I01230 { $core[($ib<<12)+$core[88]] = 01231; $pc = ($ib<<12)+$core[88]+1; $code[($ib<<12)+$core[88]] = *emul8; $inh = 0; goto &fetch; }
$core[001231] = 05203; $code[001231] = *I01231; sub I01231 { $pc = 001203; $inh = 0; goto &fetch; }
$core[001232] = 02026; $code[001232] = *I01232; sub I01232 { if (++$core[000026] == 010000) { $core[000026] = 0; $pc++; }$code[000026] = *emul8; goto &fetch; }
$core[001233] = 04545; $code[001233] = *L01233; sub L01233 { $core[($ib<<12)+$core[101]] = 01234; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001234] = 04547; $code[001234] = *I01234; sub I01234 { $core[($ib<<12)+$core[103]] = 01235; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001235] = 01403; $code[001235] = *I01235; sub I01235 { $lac += $core[($df<<12)+$core[3]]; goto &fetch; }
$core[001236] = 00773; $code[001236] = *I01236; sub I01236 { $lac &= (010000|$core[($df<<12)+$core[763]]); goto &fetch; }
$core[001237] = 04551; $code[001237] = *I01237; sub I01237 { $core[($ib<<12)+$core[105]] = 01240; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[001240] = 05233; $code[001240] = *D01240; sub D01240 { $pc = 001233; $inh = 0; goto &fetch; }
$core[001241] = 04545; $code[001241] = *D01241; sub D01241 { $core[($ib<<12)+$core[101]] = 01242; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001242] = 04554; $code[001242] = *D01242; sub D01242 { $core[($ib<<12)+$core[108]] = 01243; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[001243] = 01067; $code[001243] = *D01243; sub D01243 { $lac += $core[000067]; goto &fetch; }
$core[001244] = 03052; $code[001244] = *D01244; sub D01244 { $core[000052] = $lac & 07777; $lac &= 010000; $code[000052] = *emul8; goto &fetch; }
$core[001245] = 05204; $code[001245] = *D01245; sub D01245 { $pc = 001204; $inh = 0; goto &fetch; }
$core[001246] = 01077; $code[001246] = *I01246; sub I01246 { $lac += $core[000077]; goto &fetch; }
$core[001247] = 04463; $code[001247] = *I01247; sub I01247 { $core[($ib<<12)+$core[51]] = 01250; $pc = ($ib<<12)+$core[51]+1; $code[($ib<<12)+$core[51]] = *emul8; $inh = 0; goto &fetch; }
$core[001250] = 07040; $code[001250] = *I01250; sub I01250 { $lac ^= 07777; goto &fetch; }
$core[001251] = 01077; $code[001251] = *I01251; sub I01251 { $lac += $core[000077]; goto &fetch; }
$core[001252] = 04551; $code[001252] = *I01252; sub I01252 { $core[($ib<<12)+$core[105]] = 01253; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[001253] = 04545; $code[001253] = *I01253; sub I01253 { $core[($ib<<12)+$core[101]] = 01254; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001254] = 05204; $code[001254] = *I01254; sub I01254 { $pc = 001204; $inh = 0; goto &fetch; }
$core[001255] = 00272; $code[001255] = *D01255; sub D01255 { $lac &= (010000|$core[001272]); goto &fetch; }
$core[001256] = 04554; $code[001256] = *I01256; sub I01256 { $core[($ib<<12)+$core[108]] = 01257; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[001257] = 04555; $code[001257] = *I01257; sub I01257 { $core[($ib<<12)+$core[109]] = 01260; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[001260] = 04566; $code[001260] = *I01260; sub I01260 { $core[($ib<<12)+$core[118]] = 01261; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001261] = 01060; $code[001261] = *D01261; sub D01261 { $lac += $core[000060]; goto &fetch; }
$core[001262] = 03010; $code[001262] = *I01262; sub I01262 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[001263] = 03062; $code[001263] = *I01263; sub I01263 { $core[000062] = $lac & 07777; $lac &= 010000; $code[000062] = *emul8; goto &fetch; }
$core[001264] = 01067; $code[001264] = *I01264; sub I01264 { $lac += $core[000067]; goto &fetch; }
$core[001265] = 03410; $code[001265] = *I01265; sub I01265 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[001266] = 01010; $code[001266] = *I01266; sub I01266 { $lac += $core[000010]; goto &fetch; }
$core[001267] = 03027; $code[001267] = *I01267; sub I01267 { $core[000027] = $lac & 07777; $lac &= 010000; $code[000027] = *emul8; goto &fetch; }
$core[001270] = 04464; $code[001270] = *D01270; sub D01270 { $core[($ib<<12)+$core[52]] = 01271; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[001271] = 03100; $code[001271] = *D01271; sub D01271 { $core[000100] = $lac & 07777; $lac &= 010000; $code[000100] = *emul8; goto &fetch; }
$core[001272] = 02026; $code[001272] = *D01272; sub D01272 { if (++$core[000026] == 010000) { $core[000026] = 0; $pc++; }$code[000026] = *emul8; goto &fetch; }
$core[001273] = 04545; $code[001273] = *L01273; sub L01273 { $core[($ib<<12)+$core[101]] = 01274; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001274] = 04551; $code[001274] = *I01274; sub I01274 { $core[($ib<<12)+$core[105]] = 01275; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[001275] = 04547; $code[001275] = *I01275; sub I01275 { $core[($ib<<12)+$core[103]] = 01276; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001276] = 00076; $code[001276] = *I01276; sub I01276 { $lac &= (010000|$core[000076]); goto &fetch; }
$core[001277] = 01271; $code[001277] = *I01277; sub I01277 { $lac += $core[001271]; goto &fetch; }
$core[001300] = 04546; $code[001300] = *I01300; sub I01300 { $core[($ib<<12)+$core[102]] = 01301; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[001301] = 05273; $code[001301] = *I01301; sub I01301 { $pc = 001273; $inh = 0; goto &fetch; }
$core[001302] = 01060; $code[001302] = *D01302; sub D01302 { $lac += $core[000060]; goto &fetch; }
$core[001303] = 07001; $code[001303] = *I01303; sub I01303 { $lac++; goto &fetch; }
$core[001304] = 03010; $code[001304] = *I01304; sub I01304 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[001305] = 03062; $code[001305] = *I01305; sub I01305 { $core[000062] = $lac & 07777; $lac &= 010000; $code[000062] = *emul8; goto &fetch; }
$core[001306] = 04552; $code[001306] = *L01306; sub L01306 { $core[($ib<<12)+$core[106]] = 01307; $pc = ($ib<<12)+$core[106]+1; $code[($ib<<12)+$core[106]] = *emul8; $inh = 0; goto &fetch; }
$core[001307] = 04547; $code[001307] = *I01307; sub I01307 { $core[($ib<<12)+$core[103]] = 01310; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001310] = 00071; $code[001310] = *I01310; sub I01310 { $lac &= (010000|$core[000071]); goto &fetch; }
$core[001311] = 01271; $code[001311] = *I01311; sub I01311 { $lac += $core[001271]; goto &fetch; }
$core[001312] = 04546; $code[001312] = *D01312; sub D01312 { $core[($ib<<12)+$core[102]] = 01313; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[001313] = 05306; $code[001313] = *I01313; sub I01313 { $pc = 001306; $inh = 0; goto &fetch; }
$core[001314] = 00000; $code[001314] = *S01314; sub S01314 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001315] = 07450; $code[001315] = *I01315; sub I01315 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001316] = 01066; $code[001316] = *I01316; sub I01316 { $lac += $core[000066]; goto &fetch; }
$core[001317] = 07041; $code[001317] = *I01317; sub I01317 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001320] = 03071; $code[001320] = *I01320; sub I01320 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[001321] = 01714; $code[001321] = *I01321; sub I01321 { $lac += $core[($df<<12)+$core[716]]; goto &fetch; }
$core[001322] = 02314; $code[001322] = *I01322; sub I01322 { if (++$core[001314] == 010000) { $core[001314] = 0; $pc++; }$code[001314] = *emul8; goto &fetch; }
$core[001323] = 03012; $code[001323] = *I01323; sub I01323 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[001324] = 01412; $code[001324] = *L01324; sub L01324 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac += $core[($df<<12)+$core[000012]]; goto &fetch; }
$core[001325] = 07510; $code[001325] = *I01325; sub I01325 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001326] = 05340; $code[001326] = *I01326; sub I01326 { $pc = 001340; $inh = 0; goto &fetch; }
$core[001327] = 01071; $code[001327] = *I01327; sub I01327 { $lac += $core[000071]; goto &fetch; }
$core[001330] = 07640; $code[001330] = *I01330; sub I01330 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001331] = 05324; $code[001331] = *I01331; sub I01331 { $pc = 001324; $inh = 0; goto &fetch; }
$core[001332] = 01012; $code[001332] = *I01332; sub I01332 { $lac += $core[000012]; goto &fetch; }
$core[001333] = 01714; $code[001333] = *I01333; sub I01333 { $lac += $core[($df<<12)+$core[716]]; goto &fetch; }
$core[001334] = 03071; $code[001334] = *I01334; sub I01334 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[001335] = 01471; $code[001335] = *I01335; sub I01335 { $lac += $core[($df<<12)+$core[57]]; goto &fetch; }
$core[001336] = 03071; $code[001336] = *L01336; sub L01336 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[001337] = 05471; $code[001337] = *I01337; sub I01337 { $pc = ($ib<<12)+$core[57]; $inh = 0; goto &fetch; }
$core[001340] = 02314; $code[001340] = *P01340; sub P01340 { if (++$core[001314] == 010000) { $core[001314] = 0; $pc++; }$code[001314] = *emul8; goto &fetch; }
$core[001341] = 07300; $code[001341] = *I01341; sub I01341 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001342] = 05714; $code[001342] = *I01342; sub I01342 { $pc = ($ib<<12)+$core[716]; $inh = 0; goto &fetch; }
$core[001343] = 04453; $code[001343] = *I01343; sub I01343 { $core[($ib<<12)+$core[43]] = 01344; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[001344] = 07000; $code[001344] = *I01344; sub I01344 { goto &fetch; }
$core[001345] = 06375; $code[001345] = *I01345; sub I01345 { &emul8; goto &fetch; }
$core[001346] = 06332; $code[001346] = *L01346; sub L01346 { &emul8; goto &fetch; }
$core[001347] = 05346; $code[001347] = *I01347; sub I01347 { $pc = 001346; $inh = 0; goto &fetch; }
$core[001350] = 06362; $code[001350] = *I01350; sub I01350 { &emul8; goto &fetch; }
$core[001351] = 03046; $code[001351] = *I01351; sub I01351 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[001352] = 06001; $code[001352] = *I01352; sub I01352 { &emul8; goto &fetch; }
$core[001353] = 05536; $code[001353] = *I01353; sub I01353 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[001354] = 00000; $code[001354] = *P01354; sub P01354 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001355] = 06046; $code[001355] = *I01355; sub I01355 { &emul8; goto &fetch; }
$core[001356] = 06026; $code[001356] = *I01356; sub I01356 { &emul8; goto &fetch; }
$core[001357] = 06041; $code[001357] = *L01357; sub L01357 { &emul8; goto &fetch; }
$core[001360] = 05357; $code[001360] = *I01360; sub I01360 { $pc = 001357; $inh = 0; goto &fetch; }
$core[001361] = 07200; $code[001361] = *I01361; sub I01361 { $lac &= 010000; goto &fetch; }
$core[001362] = 05754; $code[001362] = *I01362; sub I01362 { $pc = ($ib<<12)+$core[748]; $inh = 0; goto &fetch; }
$core[001363] = 01273; $code[001363] = *I01363; sub I01363 { $lac += $core[001273]; goto &fetch; }
$core[001364] = 01270; $code[001364] = *I01364; sub I01364 { $lac += $core[001270]; goto &fetch; }
$core[001365] = 02740; $code[001365] = *I01365; sub I01365 { if (++$core[($df<<12)+$core[736]] == 010000) { $core[($df<<12)+$core[736]] = 0; $pc++; }$code[($df<<12)+$core[736]] = *emul8; goto &fetch; }
$core[001366] = 01302; $code[001366] = *I01366; sub I01366 { $lac += $core[001302]; goto &fetch; }
$core[001367] = 01271; $code[001367] = *I01367; sub I01367 { $lac += $core[001271]; goto &fetch; }
$core[001370] = 00261; $code[001370] = *I01370; sub I01370 { $lac &= (010000|$core[001261]); goto &fetch; }
$core[001371] = 01312; $code[001371] = *D01371; sub D01371 { $lac += $core[001312]; goto &fetch; }
$core[001372] = 00245; $code[001372] = *I01372; sub I01372 { $lac &= (010000|$core[001245]); goto &fetch; }
$core[001373] = 00242; $code[001373] = *P01373; sub P01373 { $lac &= (010000|$core[001242]); goto &fetch; }
$core[001374] = 00241; $code[001374] = *I01374; sub I01374 { $lac &= (010000|$core[001241]); goto &fetch; }
$core[001375] = 00243; $code[001375] = *I01375; sub I01375 { $lac &= (010000|$core[001243]); goto &fetch; }
$core[001376] = 00244; $code[001376] = *I01376; sub I01376 { $lac &= (010000|$core[001244]); goto &fetch; }
$core[001377] = 00240; $code[001377] = *I01377; sub I01377 { $lac &= (010000|$core[001240]); goto &fetch; }
$core[001400] = 00254; $code[001400] = *I01400; sub I01400 { $lac &= (010000|$core[001454]); goto &fetch; }
$core[001401] = 00273; $code[001401] = *P01401; sub P01401 { $lac &= (010000|$core[001473]); goto &fetch; }
$core[001402] = 00215; $code[001402] = *I01402; sub I01402 { $lac &= (010000|$core[001415]); goto &fetch; }
$core[001403] = 04564; $code[001403] = *D01403; sub D01403 { $core[($ib<<12)+$core[116]] = 01404; $pc = ($ib<<12)+$core[116]+1; $code[($ib<<12)+$core[116]] = *emul8; $inh = 0; goto &fetch; }
$core[001404] = 00242; $code[001404] = *I01404; sub I01404 { $lac &= (010000|$core[001442]); goto &fetch; }
$core[001405] = 00215; $code[001405] = *I01405; sub I01405 { $lac &= (010000|$core[001415]); goto &fetch; }
$core[001406] = 04566; $code[001406] = *I01406; sub I01406 { $core[($ib<<12)+$core[118]] = 01407; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001407] = 03062; $code[001407] = *I01407; sub I01407 { $core[000062] = $lac & 07777; $lac &= 010000; $code[000062] = *emul8; goto &fetch; }
$core[001410] = 04546; $code[001410] = *P01410; sub P01410 { $core[($ib<<12)+$core[102]] = 01411; $pc = ($ib<<12)+$core[102]+1; $code[($ib<<12)+$core[102]] = *emul8; $inh = 0; goto &fetch; }
$core[001411] = 04545; $code[001411] = *I01411; sub I01411 { $core[($ib<<12)+$core[101]] = 01412; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001412] = 04550; $code[001412] = *I01412; sub I01412 { $core[($ib<<12)+$core[104]] = 01413; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[001413] = 01767; $code[001413] = *D01413; sub D01413 { $lac += $core[($df<<12)+$core[887]]; goto &fetch; }
$core[001414] = 05226; $code[001414] = *I01414; sub I01414 { $pc = 001426; $inh = 0; goto &fetch; }
$core[001415] = 01066; $code[001415] = *D01415; sub D01415 { $lac += $core[000066]; goto &fetch; }
$core[001416] = 00122; $code[001416] = *I01416; sub I01416 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[001417] = 01061; $code[001417] = *I01417; sub I01417 { $lac += $core[000061]; goto &fetch; }
$core[001420] = 03061; $code[001420] = *I01420; sub I01420 { $core[000061] = $lac & 07777; $lac &= 010000; $code[000061] = *emul8; goto &fetch; }
$core[001421] = 04545; $code[001421] = *L01421; sub L01421 { $core[($ib<<12)+$core[101]] = 01422; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001422] = 04550; $code[001422] = *I01422; sub I01422 { $core[($ib<<12)+$core[104]] = 01423; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[001423] = 01767; $code[001423] = *D01423; sub D01423 { $lac += $core[($df<<12)+$core[887]]; goto &fetch; }
$core[001424] = 05226; $code[001424] = *I01424; sub I01424 { $pc = 001426; $inh = 0; goto &fetch; }
$core[001425] = 05221; $code[001425] = *I01425; sub I01425 { $pc = 001421; $inh = 0; goto &fetch; }
$core[001426] = 04562; $code[001426] = *L01426; sub L01426 { $core[($ib<<12)+$core[114]] = 01427; $pc = ($ib<<12)+$core[114]+1; $code[($ib<<12)+$core[114]] = *emul8; $inh = 0; goto &fetch; }
$core[001427] = 05237; $code[001427] = *I01427; sub I01427 { $pc = 001437; $inh = 0; goto &fetch; }
$core[001430] = 01061; $code[001430] = *I01430; sub I01430 { $lac += $core[000061]; goto &fetch; }
$core[001431] = 03056; $code[001431] = *I01431; sub I01431 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001432] = 04660; $code[001432] = *D01432; sub D01432 { $core[($ib<<12)+$core[816]] = 01433; $pc = ($ib<<12)+$core[816]+1; $code[($ib<<12)+$core[816]] = *emul8; $inh = 0; goto &fetch; }
$core[001433] = 01413; $code[001433] = *I01433; sub I01433 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001434] = 03061; $code[001434] = *I01434; sub I01434 { $core[000061] = $lac & 07777; $lac &= 010000; $code[000061] = *emul8; goto &fetch; }
$core[001435] = 04657; $code[001435] = *I01435; sub I01435 { $core[($ib<<12)+$core[815]] = 01436; $pc = ($ib<<12)+$core[815]+1; $code[($ib<<12)+$core[815]] = *emul8; $inh = 0; goto &fetch; }
$core[001436] = 04453; $code[001436] = *I01436; sub I01436 { $core[($ib<<12)+$core[43]] = 01437; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[001437] = 03317; $code[001437] = *L01437; sub L01437 { $core[001517] = $lac & 07777; $lac &= 010000; $code[001517] = *emul8; goto &fetch; }
$core[001440] = 01060; $code[001440] = *I01440; sub I01440 { $lac += $core[000060]; goto &fetch; }
$core[001441] = 03030; $code[001441] = *L01441; sub L01441 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[001442] = 01030; $code[001442] = *D01442; sub D01442 { $lac += $core[000030]; goto &fetch; }
$core[001443] = 07041; $code[001443] = *I01443; sub I01443 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001444] = 01031; $code[001444] = *I01444; sub I01444 { $lac += $core[000031]; goto &fetch; }
$core[001445] = 07750; $code[001445] = *I01445; sub I01445 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001446] = 05261; $code[001446] = *D01446; sub D01446 { $pc = 001461; $inh = 0; goto &fetch; }
$core[001447] = 01430; $code[001447] = *I01447; sub I01447 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[001450] = 07041; $code[001450] = *I01450; sub I01450 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001451] = 01061; $code[001451] = *D01451; sub D01451 { $lac += $core[000061]; goto &fetch; }
$core[001452] = 07650; $code[001452] = *I01452; sub I01452 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001453] = 05305; $code[001453] = *D01453; sub D01453 { $pc = 001505; $inh = 0; goto &fetch; }
$core[001454] = 01030; $code[001454] = *L01454; sub L01454 { $lac += $core[000030]; goto &fetch; }
$core[001455] = 01070; $code[001455] = *I01455; sub I01455 { $lac += $core[000070]; goto &fetch; }
$core[001456] = 05241; $code[001456] = *I01456; sub I01456 { $pc = 001441; $inh = 0; goto &fetch; }
$core[001457] = 02047; $code[001457] = *P01457; sub P01457 { if (++$core[000047] == 010000) { $core[000047] = 0; $pc++; }$code[000047] = *emul8; goto &fetch; }
$core[001460] = 01601; $code[001460] = *P01460; sub P01460 { $lac += $core[($df<<12)+$core[769]]; goto &fetch; }
$core[001461] = 01031; $code[001461] = *L01461; sub L01461 { $lac += $core[000031]; goto &fetch; }
$core[001462] = 01005; $code[001462] = *I01462; sub I01462 { $lac += $core[000005]; goto &fetch; }
$core[001463] = 07141; $code[001463] = *I01463; sub I01463 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[001464] = 01013; $code[001464] = *I01464; sub I01464 { $lac += $core[000013]; goto &fetch; }
$core[001465] = 07620; $code[001465] = *I01465; sub I01465 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001466] = 04566; $code[001466] = *I01466; sub I01466 { $core[($ib<<12)+$core[118]] = 01467; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001467] = 01031; $code[001467] = *I01467; sub I01467 { $lac += $core[000031]; goto &fetch; }
$core[001470] = 01070; $code[001470] = *I01470; sub I01470 { $lac += $core[000070]; goto &fetch; }
$core[001471] = 03031; $code[001471] = *I01471; sub I01471 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[001472] = 01061; $code[001472] = *I01472; sub I01472 { $lac += $core[000061]; goto &fetch; }
$core[001473] = 03430; $code[001473] = *D01473; sub D01473 { $core[($df<<12)+$core[24]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[001474] = 02030; $code[001474] = *I01474; sub I01474 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[001475] = 01317; $code[001475] = *I01475; sub I01475 { $lac += $core[001517]; goto &fetch; }
$core[001476] = 03430; $code[001476] = *I01476; sub I01476 { $core[($df<<12)+$core[24]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[001477] = 02030; $code[001477] = *I01477; sub I01477 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[001500] = 04407; $code[001500] = *I01500; sub I01500 { $core[($ib<<12)+$core[7]] = 01501; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[001501] = 00537; $code[001501] = *I01501; sub I01501 { &emul8; goto &fetch; }
$core[001502] = 06430; $code[001502] = *I01502; sub I01502 { &emul8; goto &fetch; }
$core[001503] = 00000; $code[001503] = *I01503; sub I01503 { &emul8; goto &fetch; }
$core[001504] = 05541; $code[001504] = *I01504; sub I01504 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[001505] = 01030; $code[001505] = *L01505; sub L01505 { $lac += $core[000030]; goto &fetch; }
$core[001506] = 03011; $code[001506] = *I01506; sub I01506 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[001507] = 01411; $code[001507] = *I01507; sub I01507 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[001510] = 07041; $code[001510] = *I01510; sub I01510 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001511] = 01317; $code[001511] = *I01511; sub I01511 { $lac += $core[001517]; goto &fetch; }
$core[001512] = 07640; $code[001512] = *I01512; sub I01512 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001513] = 05254; $code[001513] = *I01513; sub I01513 { $pc = 001454; $inh = 0; goto &fetch; }
$core[001514] = 02030; $code[001514] = *I01514; sub I01514 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[001515] = 02030; $code[001515] = *I01515; sub I01515 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[001516] = 05541; $code[001516] = *I01516; sub I01516 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[001517] = 00000; $code[001517] = *S01517; sub S01517 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001520] = 01066; $code[001520] = *L01520; sub L01520 { $lac += $core[000066]; goto &fetch; }
$core[001521] = 01114; $code[001521] = *I01521; sub I01521 { $lac += $core[000114]; goto &fetch; }
$core[001522] = 07640; $code[001522] = *I01522; sub I01522 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001523] = 05717; $code[001523] = *I01523; sub I01523 { $pc = ($ib<<12)+$core[847]; $inh = 0; goto &fetch; }
$core[001524] = 04545; $code[001524] = *I01524; sub I01524 { $core[($ib<<12)+$core[101]] = 01525; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001525] = 05320; $code[001525] = *I01525; sub I01525 { $pc = 001520; $inh = 0; goto &fetch; }
$core[001526] = 07520; $code[001526] = *D01526; sub D01526 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001527] = 07507; $code[001527] = *D01527; sub D01527 { &emul8; goto &fetch; }
$core[001530] = 00000; $code[001530] = *D01530; sub D01530 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001531] = 02000; $code[001531] = *I01531; sub I01531 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[001532] = 00000; $code[001532] = *I01532; sub I01532 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001533] = 00000; $code[001533] = *S01533; sub S01533 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001534] = 01066; $code[001534] = *I01534; sub I01534 { $lac += $core[000066]; goto &fetch; }
$core[001535] = 01115; $code[001535] = *I01535; sub I01535 { $lac += $core[000115]; goto &fetch; }
$core[001536] = 07640; $code[001536] = *I01536; sub I01536 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001537] = 02333; $code[001537] = *I01537; sub I01537 { if (++$core[001533] == 010000) { $core[001533] = 0; $pc++; }$code[001533] = *emul8; goto &fetch; }
$core[001540] = 01066; $code[001540] = *I01540; sub I01540 { $lac += $core[000066]; goto &fetch; }
$core[001541] = 01326; $code[001541] = *I01541; sub I01541 { $lac += $core[001526]; goto &fetch; }
$core[001542] = 03054; $code[001542] = *I01542; sub I01542 { $core[000054] = $lac & 07777; $lac &= 010000; $code[000054] = *emul8; goto &fetch; }
$core[001543] = 01054; $code[001543] = *I01543; sub I01543 { $lac += $core[000054]; goto &fetch; }
$core[001544] = 07710; $code[001544] = *I01544; sub I01544 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001545] = 05733; $code[001545] = *I01545; sub I01545 { $pc = ($ib<<12)+$core[859]; $inh = 0; goto &fetch; }
$core[001546] = 01066; $code[001546] = *I01546; sub I01546 { $lac += $core[000066]; goto &fetch; }
$core[001547] = 01327; $code[001547] = *I01547; sub I01547 { $lac += $core[001527]; goto &fetch; }
$core[001550] = 07750; $code[001550] = *D01550; sub D01550 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001551] = 02333; $code[001551] = *I01551; sub I01551 { if (++$core[001533] == 010000) { $core[001533] = 0; $pc++; }$code[001533] = *emul8; goto &fetch; }
$core[001552] = 05733; $code[001552] = *I01552; sub I01552 { $pc = ($ib<<12)+$core[859]; $inh = 0; goto &fetch; }
$core[001553] = 04407; $code[001553] = *I01553; sub I01553 { $core[($ib<<12)+$core[7]] = 01554; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[001554] = 01330; $code[001554] = *I01554; sub I01554 { &emul8; goto &fetch; }
$core[001555] = 04350; $code[001555] = *I01555; sub I01555 { &emul8; goto &fetch; }
$core[001556] = 06330; $code[001556] = *I01556; sub I01556 { &emul8; goto &fetch; }
$core[001557] = 00000; $code[001557] = *I01557; sub I01557 { &emul8; goto &fetch; }
$core[001560] = 03330; $code[001560] = *I01560; sub I01560 { $core[001530] = $lac & 07777; $lac &= 010000; $code[001530] = *emul8; goto &fetch; }
$core[001561] = 03044; $code[001561] = *I01561; sub I01561 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[001562] = 05536; $code[001562] = *I01562; sub I01562 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[001563] = 01137; $code[001563] = *I01563; sub I01563 { $lac += $core[000137]; goto &fetch; }
$core[001564] = 03022; $code[001564] = *I01564; sub I01564 { $core[000022] = $lac & 07777; $lac &= 010000; $code[000022] = *emul8; goto &fetch; }
$core[001565] = 01413; $code[001565] = *L01565; sub L01565 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001566] = 03071; $code[001566] = *I01566; sub I01566 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[001567] = 05471; $code[001567] = *P01567; sub P01567 { $pc = ($ib<<12)+$core[57]; $inh = 0; goto &fetch; }
$core[001570] = 01241; $code[001570] = *I01570; sub I01570 { $lac += $core[001441]; goto &fetch; }
$core[001571] = 01232; $code[001571] = *I01571; sub I01571 { $lac += $core[001432]; goto &fetch; }
$core[001572] = 01251; $code[001572] = *I01572; sub I01572 { $lac += $core[001451]; goto &fetch; }
$core[001573] = 01246; $code[001573] = *I01573; sub I01573 { $lac += $core[001446]; goto &fetch; }
$core[001574] = 03052; $code[001574] = *I01574; sub I01574 { $core[000052] = $lac & 07777; $lac &= 010000; $code[000052] = *emul8; goto &fetch; }
$core[001575] = 01253; $code[001575] = *I01575; sub I01575 { $lac += $core[001453]; goto &fetch; }
$core[001576] = 01253; $code[001576] = *I01576; sub I01576 { $lac += $core[001453]; goto &fetch; }
$core[001577] = 00610; $code[001577] = *I01577; sub I01577 { $lac &= (010000|$core[($df<<12)+$core[776]]); goto &fetch; }
$core[001600] = 00614; $code[001600] = *I01600; sub I01600 { $lac &= (010000|$core[($df<<12)+$core[908]]); goto &fetch; }
$core[001601] = 00000; $code[001601] = *D01601; sub D01601 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001602] = 01054; $code[001602] = *I01602; sub I01602 { $lac += $core[000054]; goto &fetch; }
$core[001603] = 04542; $code[001603] = *I01603; sub I01603 { $core[($ib<<12)+$core[98]] = 01604; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001604] = 01055; $code[001604] = *I01604; sub I01604 { $lac += $core[000055]; goto &fetch; }
$core[001605] = 04542; $code[001605] = *I01605; sub I01605 { $core[($ib<<12)+$core[98]] = 01606; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001606] = 01056; $code[001606] = *I01606; sub I01606 { $lac += $core[000056]; goto &fetch; }
$core[001607] = 04542; $code[001607] = *I01607; sub I01607 { $core[($ib<<12)+$core[98]] = 01610; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001610] = 01201; $code[001610] = *I01610; sub I01610 { $lac += $core[001601]; goto &fetch; }
$core[001611] = 04542; $code[001611] = *I01611; sub I01611 { $core[($ib<<12)+$core[98]] = 01612; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001612] = 04545; $code[001612] = *D01612; sub D01612 { $core[($ib<<12)+$core[101]] = 01613; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001613] = 03055; $code[001613] = *I01613; sub I01613 { $core[000055] = $lac & 07777; $lac &= 010000; $code[000055] = *emul8; goto &fetch; }
$core[001614] = 04564; $code[001614] = *P01614; sub P01614 { $core[($ib<<12)+$core[116]] = 01615; $pc = ($ib<<12)+$core[116]+1; $code[($ib<<12)+$core[116]] = *emul8; $inh = 0; goto &fetch; }
$core[001615] = 05227; $code[001615] = *I01615; sub I01615 { $pc = 001627; $inh = 0; goto &fetch; }
$core[001616] = 05332; $code[001616] = *I01616; sub I01616 { $pc = 001732; $inh = 0; goto &fetch; }
$core[001617] = 05343; $code[001617] = *I01617; sub I01617 { $pc = 001743; $inh = 0; goto &fetch; }
$core[001620] = 04540; $code[001620] = *L01620; sub L01620 { $core[($ib<<12)+$core[96]] = 01621; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[001621] = 01407; $code[001621] = *I01621; sub I01621 { $lac += $core[($df<<12)+$core[7]]; goto &fetch; }
$core[001622] = 04564; $code[001622] = *L01622; sub L01622 { $core[($ib<<12)+$core[116]] = 01623; $pc = ($ib<<12)+$core[116]+1; $code[($ib<<12)+$core[116]] = *emul8; $inh = 0; goto &fetch; }
$core[001623] = 05244; $code[001623] = *I01623; sub I01623 { $pc = 001644; $inh = 0; goto &fetch; }
$core[001624] = 00212; $code[001624] = *I01624; sub I01624 { $lac &= (010000|$core[001612]); goto &fetch; }
$core[001625] = 00377; $code[001625] = *I01625; sub I01625 { $lac &= (010000|$core[001777]); goto &fetch; }
$core[001626] = 04566; $code[001626] = *I01626; sub I01626 { $core[($ib<<12)+$core[118]] = 01627; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001627] = 01137; $code[001627] = *L01627; sub L01627 { $lac += $core[000137]; goto &fetch; }
$core[001630] = 03030; $code[001630] = *I01630; sub I01630 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[001631] = 01111; $code[001631] = *I01631; sub I01631 { $lac += $core[000111]; goto &fetch; }
$core[001632] = 01054; $code[001632] = *I01632; sub I01632 { $lac += $core[000054]; goto &fetch; }
$core[001633] = 07450; $code[001633] = *I01633; sub I01633 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001634] = 05247; $code[001634] = *I01634; sub I01634 { $pc = 001647; $inh = 0; goto &fetch; }
$core[001635] = 07001; $code[001635] = *I01635; sub I01635 { $lac++; goto &fetch; }
$core[001636] = 07650; $code[001636] = *I01636; sub I01636 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001637] = 05323; $code[001637] = *I01637; sub I01637 { $pc = 001723; $inh = 0; goto &fetch; }
$core[001640] = 01054; $code[001640] = *D01640; sub D01640 { $lac += $core[000054]; goto &fetch; }
$core[001641] = 01121; $code[001641] = *I01641; sub I01641 { $lac += $core[000121]; goto &fetch; }
$core[001642] = 07710; $code[001642] = *I01642; sub I01642 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001643] = 05363; $code[001643] = *I01643; sub I01643 { $pc = 001763; $inh = 0; goto &fetch; }
$core[001644] = 04562; $code[001644] = *L01644; sub L01644 { $core[($ib<<12)+$core[114]] = 01645; $pc = ($ib<<12)+$core[114]+1; $code[($ib<<12)+$core[114]] = *emul8; $inh = 0; goto &fetch; }
$core[001645] = 07410; $code[001645] = *I01645; sub I01645 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001646] = 04566; $code[001646] = *I01646; sub I01646 { $core[($ib<<12)+$core[118]] = 01647; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001647] = 01054; $code[001647] = *L01647; sub L01647 { $lac += $core[000054]; goto &fetch; }
$core[001650] = 03024; $code[001650] = *D01650; sub D01650 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001651] = 01024; $code[001651] = *I01651; sub I01651 { $lac += $core[000024]; goto &fetch; }
$core[001652] = 01121; $code[001652] = *D01652; sub D01652 { $lac += $core[000121]; goto &fetch; }
$core[001653] = 07700; $code[001653] = *D01653; sub D01653 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001654] = 03024; $code[001654] = *I01654; sub I01654 { $core[000024] = $lac & 07777; $lac &= 010000; $code[000024] = *emul8; goto &fetch; }
$core[001655] = 01024; $code[001655] = *L01655; sub L01655 { $lac += $core[000024]; goto &fetch; }
$core[001656] = 07041; $code[001656] = *I01656; sub I01656 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001657] = 01055; $code[001657] = *D01657; sub D01657 { $lac += $core[000055]; goto &fetch; }
$core[001660] = 07710; $code[001660] = *I01660; sub I01660 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001661] = 05310; $code[001661] = *I01661; sub I01661 { $pc = 001710; $inh = 0; goto &fetch; }
$core[001662] = 01055; $code[001662] = *I01662; sub I01662 { $lac += $core[000055]; goto &fetch; }
$core[001663] = 07112; $code[001663] = *I01663; sub I01663 { $lac &= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001664] = 07012; $code[001664] = *I01664; sub I01664 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001665] = 01331; $code[001665] = *I01665; sub I01665 { $lac += $core[001731]; goto &fetch; }
$core[001666] = 03274; $code[001666] = *I01666; sub I01666 { $core[001674] = $lac & 07777; $lac &= 010000; $code[001674] = *emul8; goto &fetch; }
$core[001667] = 01055; $code[001667] = *I01667; sub I01667 { $lac += $core[000055]; goto &fetch; }
$core[001670] = 07640; $code[001670] = *I01670; sub I01670 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001671] = 04544; $code[001671] = *I01671; sub I01671 { $core[($ib<<12)+$core[100]] = 01672; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001672] = 00044; $code[001672] = *I01672; sub I01672 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[001673] = 04407; $code[001673] = *I01673; sub I01673 { $core[($ib<<12)+$core[7]] = 01674; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[001674] = 00000; $code[001674] = *D01674; sub D01674 { &emul8; goto &fetch; }
$core[001675] = 06525; $code[001675] = *I01675; sub I01675 { &emul8; goto &fetch; }
$core[001676] = 00000; $code[001676] = *I01676; sub I01676 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001677] = 01125; $code[001677] = *I01677; sub I01677 { $lac += $core[000125]; goto &fetch; }
$core[001700] = 03030; $code[001700] = *I01700; sub I01700 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[001701] = 01024; $code[001701] = *I01701; sub I01701 { $lac += $core[000024]; goto &fetch; }
$core[001702] = 01055; $code[001702] = *I01702; sub I01702 { $lac += $core[000055]; goto &fetch; }
$core[001703] = 07650; $code[001703] = *I01703; sub I01703 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001704] = 05541; $code[001704] = *I01704; sub I01704 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[001705] = 01413; $code[001705] = *I01705; sub I01705 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001706] = 03055; $code[001706] = *I01706; sub I01706 { $core[000055] = $lac & 07777; $lac &= 010000; $code[000055] = *emul8; goto &fetch; }
$core[001707] = 05255; $code[001707] = *I01707; sub I01707 { $pc = 001655; $inh = 0; goto &fetch; }
$core[001710] = 04562; $code[001710] = *L01710; sub L01710 { $core[($ib<<12)+$core[114]] = 01711; $pc = ($ib<<12)+$core[114]+1; $code[($ib<<12)+$core[114]] = *emul8; $inh = 0; goto &fetch; }
$core[001711] = 07410; $code[001711] = *I01711; sub I01711 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001712] = 05365; $code[001712] = *I01712; sub I01712 { $pc = 001765; $inh = 0; goto &fetch; }
$core[001713] = 01055; $code[001713] = *I01713; sub I01713 { $lac += $core[000055]; goto &fetch; }
$core[001714] = 04542; $code[001714] = *I01714; sub I01714 { $core[($ib<<12)+$core[98]] = 01715; $pc = ($ib<<12)+$core[98]+1; $code[($ib<<12)+$core[98]] = *emul8; $inh = 0; goto &fetch; }
$core[001715] = 01030; $code[001715] = *I01715; sub I01715 { $lac += $core[000030]; goto &fetch; }
$core[001716] = 03320; $code[001716] = *I01716; sub I01716 { $core[001720] = $lac & 07777; $lac &= 010000; $code[001720] = *emul8; goto &fetch; }
$core[001717] = 04543; $code[001717] = *I01717; sub I01717 { $core[($ib<<12)+$core[99]] = 01720; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001720] = 00000; $code[001720] = *D01720; sub D01720 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001721] = 01024; $code[001721] = *I01721; sub I01721 { $lac += $core[000024]; goto &fetch; }
$core[001722] = 03055; $code[001722] = *I01722; sub I01722 { $core[000055] = $lac & 07777; $lac &= 010000; $code[000055] = *emul8; goto &fetch; }
$core[001723] = 04545; $code[001723] = *L01723; sub L01723 { $core[($ib<<12)+$core[101]] = 01724; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001724] = 04564; $code[001724] = *I01724; sub I01724 { $core[($ib<<12)+$core[116]] = 01725; $pc = ($ib<<12)+$core[116]+1; $code[($ib<<12)+$core[116]] = *emul8; $inh = 0; goto &fetch; }
$core[001725] = 05363; $code[001725] = *L01725; sub L01725 { $pc = 001763; $inh = 0; goto &fetch; }
$core[001726] = 05332; $code[001726] = *I01726; sub I01726 { $pc = 001732; $inh = 0; goto &fetch; }
$core[001727] = 05343; $code[001727] = *I01727; sub I01727 { $pc = 001743; $inh = 0; goto &fetch; }
$core[001730] = 05220; $code[001730] = *I01730; sub I01730 { $pc = 001620; $inh = 0; goto &fetch; }
$core[001731] = 00430; $code[001731] = *D01731; sub D01731 { $lac &= (010000|$core[($df<<12)+$core[24]]); goto &fetch; }
$core[001732] = 04543; $code[001732] = *L01732; sub L01732 { $core[($ib<<12)+$core[99]] = 01733; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[001733] = 00044; $code[001733] = *D01733; sub D01733 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[001734] = 01125; $code[001734] = *I01734; sub I01734 { $lac += $core[000125]; goto &fetch; }
$core[001735] = 03030; $code[001735] = *I01735; sub I01735 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[001736] = 03036; $code[001736] = *D01736; sub D01736 { $core[000036] = $lac & 07777; $lac &= 010000; $code[000036] = *emul8; goto &fetch; }
$core[001737] = 04531; $code[001737] = *I01737; sub I01737 { $core[($ib<<12)+$core[89]] = 01740; $pc = ($ib<<12)+$core[89]+1; $code[($ib<<12)+$core[89]] = *emul8; $inh = 0; goto &fetch; }
$core[001740] = 04544; $code[001740] = *I01740; sub I01740 { $core[($ib<<12)+$core[100]] = 01741; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[001741] = 00044; $code[001741] = *I01741; sub I01741 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[001742] = 05222; $code[001742] = *I01742; sub I01742 { $pc = 001622; $inh = 0; goto &fetch; }
$core[001743] = 03056; $code[001743] = *L01743; sub L01743 { $core[000056] = $lac & 07777; $lac &= 010000; $code[000056] = *emul8; goto &fetch; }
$core[001744] = 04545; $code[001744] = *I01744; sub I01744 { $core[($ib<<12)+$core[101]] = 01745; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[001745] = 04550; $code[001745] = *I01745; sub I01745 { $core[($ib<<12)+$core[104]] = 01746; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[001746] = 01767; $code[001746] = *I01746; sub I01746 { $lac += $core[($df<<12)+$core[1015]]; goto &fetch; }
$core[001747] = 05354; $code[001747] = *I01747; sub I01747 { $pc = 001754; $inh = 0; goto &fetch; }
$core[001750] = 01056; $code[001750] = *I01750; sub I01750 { $lac += $core[000056]; goto &fetch; }
$core[001751] = 07104; $code[001751] = *I01751; sub I01751 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001752] = 01066; $code[001752] = *I01752; sub I01752 { $lac += $core[000066]; goto &fetch; }
$core[001753] = 05343; $code[001753] = *I01753; sub I01753 { $pc = 001743; $inh = 0; goto &fetch; }
$core[001754] = 04562; $code[001754] = *L01754; sub L01754 { $core[($ib<<12)+$core[114]] = 01755; $pc = ($ib<<12)+$core[114]+1; $code[($ib<<12)+$core[114]] = *emul8; $inh = 0; goto &fetch; }
$core[001755] = 04566; $code[001755] = *I01755; sub I01755 { $core[($ib<<12)+$core[118]] = 01756; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001756] = 04201; $code[001756] = *I01756; sub I01756 { $core[001601] = 01757; $pc = 001601+1; $code[001601] = *emul8; $inh = 0; goto &fetch; }
$core[001757] = 01413; $code[001757] = *I01757; sub I01757 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[001760] = 04547; $code[001760] = *I01760; sub I01760 { $core[($ib<<12)+$core[103]] = 01761; $pc = ($ib<<12)+$core[103]+1; $code[($ib<<12)+$core[103]] = *emul8; $inh = 0; goto &fetch; }
$core[001761] = 02164; $code[001761] = *I01761; sub I01761 { if (++$core[000164] == 010000) { $core[000164] = 0; $pc++; }$code[000164] = *emul8; goto &fetch; }
$core[001762] = 06207; $code[001762] = *I01762; sub I01762 { &emul8; goto &fetch; }
$core[001763] = 04562; $code[001763] = *L01763; sub L01763 { $core[($ib<<12)+$core[114]] = 01764; $pc = ($ib<<12)+$core[114]+1; $code[($ib<<12)+$core[114]] = *emul8; $inh = 0; goto &fetch; }
$core[001764] = 04566; $code[001764] = *I01764; sub I01764 { $core[($ib<<12)+$core[118]] = 01765; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[001765] = 04201; $code[001765] = *L01765; sub L01765 { $core[001601] = 01766; $pc = 001601+1; $code[001601] = *emul8; $inh = 0; goto &fetch; }
$core[001766] = 02013; $code[001766] = *I01766; sub I01766 { if (++$core[000013] == 010000) { $core[000013] = 0; $pc++; }$code[000013] = *emul8; goto &fetch; }
$core[001767] = 05536; $code[001767] = *P01767; sub P01767 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[001770] = 00240; $code[001770] = *I01770; sub I01770 { $lac &= (010000|$core[001640]); goto &fetch; }
$core[001771] = 00253; $code[001771] = *I01771; sub I01771 { $lac &= (010000|$core[001653]); goto &fetch; }
$core[001772] = 00255; $code[001772] = *I01772; sub I01772 { $lac &= (010000|$core[001655]); goto &fetch; }
$core[001773] = 00257; $code[001773] = *I01773; sub I01773 { $lac &= (010000|$core[001657]); goto &fetch; }
$core[001774] = 00252; $code[001774] = *I01774; sub I01774 { $lac &= (010000|$core[001652]); goto &fetch; }
$core[001775] = 00336; $code[001775] = *I01775; sub I01775 { $lac &= (010000|$core[001736]); goto &fetch; }
$core[001776] = 00250; $code[001776] = *I01776; sub I01776 { $lac &= (010000|$core[001650]); goto &fetch; }
$core[001777] = 00333; $code[001777] = *D01777; sub D01777 { $lac &= (010000|$core[001733]); goto &fetch; }
$core[002000] = 00274; $code[002000] = *I02000; sub I02000 { $lac &= (010000|$core[002074]); goto &fetch; }
$core[002001] = 00251; $code[002001] = *I02001; sub I02001 { $lac &= (010000|$core[002051]); goto &fetch; }
$core[002002] = 00335; $code[002002] = *I02002; sub I02002 { $lac &= (010000|$core[002135]); goto &fetch; }
$core[002003] = 00276; $code[002003] = *I02003; sub I02003 { $lac &= (010000|$core[002076]); goto &fetch; }
$core[002004] = 00254; $code[002004] = *I02004; sub I02004 { $lac &= (010000|$core[002054]); goto &fetch; }
$core[002005] = 00273; $code[002005] = *I02005; sub I02005 { $lac &= (010000|$core[002073]); goto &fetch; }
$core[002006] = 00215; $code[002006] = *I02006; sub I02006 { $lac &= (010000|$core[002015]); goto &fetch; }
$core[002007] = 00275; $code[002007] = *I02007; sub I02007 { $lac &= (010000|$core[002075]); goto &fetch; }
$core[002010] = 04543; $code[002010] = *I02010; sub I02010 { $core[($ib<<12)+$core[99]] = 02011; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[002011] = 02405; $code[002011] = *I02011; sub I02011 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[002012] = 04544; $code[002012] = *I02012; sub I02012 { $core[($ib<<12)+$core[100]] = 02013; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[002013] = 00044; $code[002013] = *I02013; sub I02013 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[002014] = 01231; $code[002014] = *I02014; sub I02014 { $lac += $core[002031]; goto &fetch; }
$core[002015] = 07710; $code[002015] = *D02015; sub D02015 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002016] = 04451; $code[002016] = *I02016; sub I02016 { $core[($ib<<12)+$core[41]] = 02017; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[002017] = 04407; $code[002017] = *L02017; sub L02017 { $core[($ib<<12)+$core[7]] = 02020; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[002020] = 07000; $code[002020] = *I02020; sub I02020 { &emul8; goto &fetch; }
$core[002021] = 06230; $code[002021] = *I02021; sub I02021 { &emul8; goto &fetch; }
$core[002022] = 00000; $code[002022] = *P02022; sub P02022 { &emul8; goto &fetch; }
$core[002023] = 01125; $code[002023] = *P02023; sub P02023 { $lac += $core[000125]; goto &fetch; }
$core[002024] = 03030; $code[002024] = *P02024; sub P02024 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[002025] = 04247; $code[002025] = *P02025; sub P02025 { $core[002047] = 02026; $pc = 002047+1; $code[002047] = *emul8; $inh = 0; goto &fetch; }
$core[002026] = 05627; $code[002026] = *I02026; sub I02026 { $pc = ($ib<<12)+$core[1047]; $inh = 0; goto &fetch; }
$core[002027] = 01622; $code[002027] = *P02027; sub P02027 { $lac += $core[($df<<12)+$core[1042]]; goto &fetch; }
$core[002030] = 00000; $code[002030] = *P02030; sub P02030 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002031] = 00000; $code[002031] = *D02031; sub D02031 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002032] = 00000; $code[002032] = *I02032; sub I02032 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002033] = 00000; $code[002033] = *I02033; sub I02033 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002034] = 00003; $code[002034] = *D02034; sub D02034 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[002035] = 00000; $code[002035] = *S02035; sub S02035 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002036] = 01054; $code[002036] = *P02036; sub P02036 { $lac += $core[000054]; goto &fetch; }
$core[002037] = 01121; $code[002037] = *I02037; sub I02037 { $lac += $core[000121]; goto &fetch; }
$core[002040] = 07700; $code[002040] = *I02040; sub I02040 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002041] = 05635; $code[002041] = *I02041; sub I02041 { $pc = ($ib<<12)+$core[1053]; $inh = 0; goto &fetch; }
$core[002042] = 01054; $code[002042] = *I02042; sub I02042 { $lac += $core[000054]; goto &fetch; }
$core[002043] = 01120; $code[002043] = *I02043; sub I02043 { $lac += $core[000120]; goto &fetch; }
$core[002044] = 07740; $code[002044] = *I02044; sub I02044 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002045] = 02235; $code[002045] = *I02045; sub I02045 { if (++$core[002035] == 010000) { $core[002035] = 0; $pc++; }$code[002035] = *emul8; goto &fetch; }
$core[002046] = 05635; $code[002046] = *I02046; sub I02046 { $pc = ($ib<<12)+$core[1053]; $inh = 0; goto &fetch; }
$core[002047] = 00000; $code[002047] = *S02047; sub S02047 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002050] = 01413; $code[002050] = *P02050; sub P02050 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[002051] = 03055; $code[002051] = *D02051; sub D02051 { $core[000055] = $lac & 07777; $lac &= 010000; $code[000055] = *emul8; goto &fetch; }
$core[002052] = 01234; $code[002052] = *D02052; sub D02052 { $lac += $core[002034]; goto &fetch; }
$core[002053] = 01413; $code[002053] = *I02053; sub I02053 { $core[000013] = 0000 if ++$core[000013] == 010000; $lac += $core[($df<<12)+$core[000013]]; goto &fetch; }
$core[002054] = 07041; $code[002054] = *P02054; sub P02054 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002055] = 01054; $code[002055] = *L02055; sub L02055 { $lac += $core[000054]; goto &fetch; }
$core[002056] = 07640; $code[002056] = *I02056; sub I02056 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002057] = 04566; $code[002057] = *I02057; sub I02057 { $core[($ib<<12)+$core[118]] = 02060; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[002060] = 04545; $code[002060] = *I02060; sub I02060 { $core[($ib<<12)+$core[101]] = 02061; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[002061] = 05647; $code[002061] = *I02061; sub I02061 { $pc = ($ib<<12)+$core[1063]; $inh = 0; goto &fetch; }
$core[002062] = 00000; $code[002062] = *S02062; sub S02062 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002063] = 06002; $code[002063] = *L02063; sub L02063 { &emul8; goto &fetch; }
$core[002064] = 04555; $code[002064] = *I02064; sub I02064 { $core[($ib<<12)+$core[109]] = 02065; $pc = ($ib<<12)+$core[109]+1; $code[($ib<<12)+$core[109]] = *emul8; $inh = 0; goto &fetch; }
$core[002065] = 05662; $code[002065] = *I02065; sub I02065 { $pc = ($ib<<12)+$core[1074]; $inh = 0; goto &fetch; }
$core[002066] = 02026; $code[002066] = *I02066; sub I02066 { if (++$core[000026] == 010000) { $core[000026] = 0; $pc++; }$code[000026] = *emul8; goto &fetch; }
$core[002067] = 04545; $code[002067] = *L02067; sub L02067 { $core[($ib<<12)+$core[101]] = 02070; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[002070] = 01066; $code[002070] = *I02070; sub I02070 { $lac += $core[000066]; goto &fetch; }
$core[002071] = 01116; $code[002071] = *I02071; sub I02071 { $lac += $core[000116]; goto &fetch; }
$core[002072] = 07640; $code[002072] = *I02072; sub I02072 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002073] = 05267; $code[002073] = *D02073; sub D02073 { $pc = 002067; $inh = 0; goto &fetch; }
$core[002074] = 01017; $code[002074] = *D02074; sub D02074 { $lac += $core[000017]; goto &fetch; }
$core[002075] = 07040; $code[002075] = *D02075; sub D02075 { $lac ^= 07777; goto &fetch; }
$core[002076] = 01023; $code[002076] = *D02076; sub D02076 { $lac += $core[000023]; goto &fetch; }
$core[002077] = 03057; $code[002077] = *I02077; sub I02077 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[002100] = 01133; $code[002100] = *I02100; sub I02100 { $lac += $core[000133]; goto &fetch; }
$core[002101] = 07041; $code[002101] = *I02101; sub I02101 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002102] = 01023; $code[002102] = *I02102; sub I02102 { $lac += $core[000023]; goto &fetch; }
$core[002103] = 07650; $code[002103] = *I02103; sub I02103 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002104] = 05177; $code[002104] = *I02104; sub I02104 { $pc = 000177; $inh = 0; goto &fetch; }
$core[002105] = 07000; $code[002105] = *I02105; sub I02105 { goto &fetch; }
$core[002106] = 01423; $code[002106] = *I02106; sub I02106 { $lac += $core[($df<<12)+$core[19]]; goto &fetch; }
$core[002107] = 03425; $code[002107] = *I02107; sub I02107 { $core[($df<<12)+$core[21]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[002110] = 01133; $code[002110] = *I02110; sub I02110 { $lac += $core[000133]; goto &fetch; }
$core[002111] = 03071; $code[002111] = *L02111; sub L02111 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[002112] = 01471; $code[002112] = *I02112; sub I02112 { $lac += $core[($df<<12)+$core[57]]; goto &fetch; }
$core[002113] = 07450; $code[002113] = *I02113; sub I02113 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002114] = 05327; $code[002114] = *I02114; sub I02114 { $pc = 002127; $inh = 0; goto &fetch; }
$core[002115] = 03032; $code[002115] = *I02115; sub I02115 { $core[000032] = $lac & 07777; $lac &= 010000; $code[000032] = *emul8; goto &fetch; }
$core[002116] = 01023; $code[002116] = *I02116; sub I02116 { $lac += $core[000023]; goto &fetch; }
$core[002117] = 07141; $code[002117] = *I02117; sub I02117 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[002120] = 01032; $code[002120] = *I02120; sub I02120 { $lac += $core[000032]; goto &fetch; }
$core[002121] = 07630; $code[002121] = *I02121; sub I02121 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002122] = 01057; $code[002122] = *I02122; sub I02122 { $lac += $core[000057]; goto &fetch; }
$core[002123] = 01032; $code[002123] = *I02123; sub I02123 { $lac += $core[000032]; goto &fetch; }
$core[002124] = 03471; $code[002124] = *I02124; sub I02124 { $core[($df<<12)+$core[57]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[57]] = *emul8; goto &fetch; }
$core[002125] = 01032; $code[002125] = *I02125; sub I02125 { $lac += $core[000032]; goto &fetch; }
$core[002126] = 05311; $code[002126] = *I02126; sub I02126 { $pc = 002111; $inh = 0; goto &fetch; }
$core[002127] = 07040; $code[002127] = *L02127; sub L02127 { $lac ^= 07777; goto &fetch; }
$core[002130] = 01023; $code[002130] = *I02130; sub I02130 { $lac += $core[000023]; goto &fetch; }
$core[002131] = 03011; $code[002131] = *I02131; sub I02131 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[002132] = 01057; $code[002132] = *I02132; sub I02132 { $lac += $core[000057]; goto &fetch; }
$core[002133] = 07040; $code[002133] = *I02133; sub I02133 { $lac ^= 07777; goto &fetch; }
$core[002134] = 01023; $code[002134] = *I02134; sub I02134 { $lac += $core[000023]; goto &fetch; }
$core[002135] = 03012; $code[002135] = *D02135; sub D02135 { $core[000012] = $lac & 07777; $lac &= 010000; $code[000012] = *emul8; goto &fetch; }
$core[002136] = 01057; $code[002136] = *I02136; sub I02136 { $lac += $core[000057]; goto &fetch; }
$core[002137] = 01060; $code[002137] = *I02137; sub I02137 { $lac += $core[000060]; goto &fetch; }
$core[002140] = 03060; $code[002140] = *I02140; sub I02140 { $core[000060] = $lac & 07777; $lac &= 010000; $code[000060] = *emul8; goto &fetch; }
$core[002141] = 01010; $code[002141] = *I02141; sub I02141 { $lac += $core[000010]; goto &fetch; }
$core[002142] = 07040; $code[002142] = *I02142; sub I02142 { $lac ^= 07777; goto &fetch; }
$core[002143] = 01012; $code[002143] = *I02143; sub I02143 { $lac += $core[000012]; goto &fetch; }
$core[002144] = 03032; $code[002144] = *I02144; sub I02144 { $core[000032] = $lac & 07777; $lac &= 010000; $code[000032] = *emul8; goto &fetch; }
$core[002145] = 01010; $code[002145] = *I02145; sub I02145 { $lac += $core[000010]; goto &fetch; }
$core[002146] = 01057; $code[002146] = *I02146; sub I02146 { $lac += $core[000057]; goto &fetch; }
$core[002147] = 03010; $code[002147] = *I02147; sub I02147 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[002150] = 01412; $code[002150] = *L02150; sub L02150 { $core[000012] = 0000 if ++$core[000012] == 010000; $lac += $core[($df<<12)+$core[000012]]; goto &fetch; }
$core[002151] = 03411; $code[002151] = *I02151; sub I02151 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[002152] = 02032; $code[002152] = *I02152; sub I02152 { if (++$core[000032] == 010000) { $core[000032] = 0; $pc++; }$code[000032] = *emul8; goto &fetch; }
$core[002153] = 05350; $code[002153] = *I02153; sub I02153 { $pc = 002150; $inh = 0; goto &fetch; }
$core[002154] = 05263; $code[002154] = *I02154; sub I02154 { $pc = 002063; $inh = 0; goto &fetch; }
$core[002155] = 00000; $code[002155] = *S02155; sub S02155 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002156] = 04464; $code[002156] = *I02156; sub I02156 { $core[($ib<<12)+$core[52]] = 02157; $pc = ($ib<<12)+$core[52]+1; $code[($ib<<12)+$core[52]] = *emul8; $inh = 0; goto &fetch; }
$core[002157] = 03066; $code[002157] = *I02157; sub I02157 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[002160] = 04550; $code[002160] = *I02160; sub I02160 { $core[($ib<<12)+$core[104]] = 02161; $pc = ($ib<<12)+$core[104]+1; $code[($ib<<12)+$core[104]] = *emul8; $inh = 0; goto &fetch; }
$core[002161] = 01623; $code[002161] = *I02161; sub I02161 { $lac += $core[($df<<12)+$core[1043]]; goto &fetch; }
$core[002162] = 05755; $code[002162] = *I02162; sub I02162 { $pc = ($ib<<12)+$core[1133]; $inh = 0; goto &fetch; }
$core[002163] = 04551; $code[002163] = *I02163; sub I02163 { $core[($ib<<12)+$core[105]] = 02164; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002164] = 05755; $code[002164] = *I02164; sub I02164 { $pc = ($ib<<12)+$core[1133]; $inh = 0; goto &fetch; }
$core[002165] = 02533; $code[002165] = *I02165; sub I02165 { if (++$core[($df<<12)+$core[91]] == 010000) { $core[($df<<12)+$core[91]] = 0; $pc++; }$code[($df<<12)+$core[91]] = *emul8; goto &fetch; }
$core[002166] = 02650; $code[002166] = *I02166; sub I02166 { if (++$core[($df<<12)+$core[1064]] == 010000) { $core[($df<<12)+$core[1064]] = 0; $pc++; }$code[($df<<12)+$core[1064]] = *emul8; goto &fetch; }
$core[002167] = 02636; $code[002167] = *I02167; sub I02167 { if (++$core[($df<<12)+$core[1054]] == 010000) { $core[($df<<12)+$core[1054]] = 0; $pc++; }$code[($df<<12)+$core[1054]] = *emul8; goto &fetch; }
$core[002170] = 02565; $code[002170] = *I02170; sub I02170 { if (++$core[($df<<12)+$core[117]] == 010000) { $core[($df<<12)+$core[117]] = 0; $pc++; }$code[($df<<12)+$core[117]] = *emul8; goto &fetch; }
$core[002171] = 02630; $code[002171] = *I02171; sub I02171 { if (++$core[($df<<12)+$core[1048]] == 010000) { $core[($df<<12)+$core[1048]] = 0; $pc++; }$code[($df<<12)+$core[1048]] = *emul8; goto &fetch; }
$core[002172] = 02517; $code[002172] = *I02172; sub I02172 { if (++$core[($df<<12)+$core[79]] == 010000) { $core[($df<<12)+$core[79]] = 0; $pc++; }$code[($df<<12)+$core[79]] = *emul8; goto &fetch; }
$core[002173] = 02572; $code[002173] = *I02173; sub I02173 { if (++$core[($df<<12)+$core[122]] == 010000) { $core[($df<<12)+$core[122]] = 0; $pc++; }$code[($df<<12)+$core[122]] = *emul8; goto &fetch; }
$core[002174] = 02624; $code[002174] = *I02174; sub I02174 { if (++$core[($df<<12)+$core[1044]] == 010000) { $core[($df<<12)+$core[1044]] = 0; $pc++; }$code[($df<<12)+$core[1044]] = *emul8; goto &fetch; }
$core[002175] = 02625; $code[002175] = *I02175; sub I02175 { if (++$core[($df<<12)+$core[1045]] == 010000) { $core[($df<<12)+$core[1045]] = 0; $pc++; }$code[($df<<12)+$core[1045]] = *emul8; goto &fetch; }
$core[002176] = 02654; $code[002176] = *I02176; sub I02176 { if (++$core[($df<<12)+$core[1068]] == 010000) { $core[($df<<12)+$core[1068]] = 0; $pc++; }$code[($df<<12)+$core[1068]] = *emul8; goto &fetch; }
$core[002177] = 02575; $code[002177] = *I02177; sub I02177 { if (++$core[($df<<12)+$core[125]] == 010000) { $core[($df<<12)+$core[125]] = 0; $pc++; }$code[($df<<12)+$core[125]] = *emul8; goto &fetch; }
$core[002200] = 02702; $code[002200] = *I02200; sub I02200 { if (++$core[($df<<12)+$core[1218]] == 010000) { $core[($df<<12)+$core[1218]] = 0; $pc++; }$code[($df<<12)+$core[1218]] = *emul8; goto &fetch; }
$core[002201] = 02631; $code[002201] = *I02201; sub I02201 { if (++$core[($df<<12)+$core[1177]] == 010000) { $core[($df<<12)+$core[1177]] = 0; $pc++; }$code[($df<<12)+$core[1177]] = *emul8; goto &fetch; }
$core[002202] = 02567; $code[002202] = *I02202; sub I02202 { if (++$core[($df<<12)+$core[119]] == 010000) { $core[($df<<12)+$core[119]] = 0; $pc++; }$code[($df<<12)+$core[119]] = *emul8; goto &fetch; }
$core[002203] = 00330; $code[002203] = *I02203; sub I02203 { $lac &= (010000|$core[002330]); goto &fetch; }
$core[002204] = 04564; $code[002204] = *I02204; sub I02204 { $core[($ib<<12)+$core[116]] = 02205; $pc = ($ib<<12)+$core[116]+1; $code[($ib<<12)+$core[116]] = *emul8; $inh = 0; goto &fetch; }
$core[002205] = 05237; $code[002205] = *I02205; sub I02205 { $pc = 002237; $inh = 0; goto &fetch; }
$core[002206] = 05222; $code[002206] = *I02206; sub I02206 { $pc = 002222; $inh = 0; goto &fetch; }
$core[002207] = 05213; $code[002207] = *I02207; sub I02207 { $pc = 002213; $inh = 0; goto &fetch; }
$core[002210] = 01066; $code[002210] = *I02210; sub I02210 { $lac += $core[000066]; goto &fetch; }
$core[002211] = 01112; $code[002211] = *I02211; sub I02211 { $lac += $core[000112]; goto &fetch; }
$core[002212] = 07440; $code[002212] = *I02212; sub I02212 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002213] = 04566; $code[002213] = *L02213; sub L02213 { $core[($ib<<12)+$core[118]] = 02214; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[002214] = 01135; $code[002214] = *L02214; sub L02214 { $lac += $core[000135]; goto &fetch; }
$core[002215] = 03060; $code[002215] = *I02215; sub I02215 { $core[000060] = $lac & 07777; $lac &= 010000; $code[000060] = *emul8; goto &fetch; }
$core[002216] = 03533; $code[002216] = *I02216; sub I02216 { $core[($df<<12)+$core[91]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[91]] = *emul8; goto &fetch; }
$core[002217] = 01060; $code[002217] = *L02217; sub L02217 { $lac += $core[000060]; goto &fetch; }
$core[002220] = 03031; $code[002220] = *I02220; sub I02220 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[002221] = 05177; $code[002221] = *I02221; sub I02221 { $pc = 000177; $inh = 0; goto &fetch; }
$core[002222] = 04554; $code[002222] = *L02222; sub L02222 { $core[($ib<<12)+$core[108]] = 02223; $pc = ($ib<<12)+$core[108]+1; $code[($ib<<12)+$core[108]] = *emul8; $inh = 0; goto &fetch; }
$core[002223] = 01060; $code[002223] = *I02223; sub I02223 { $lac += $core[000060]; goto &fetch; }
$core[002224] = 03010; $code[002224] = *I02224; sub I02224 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[002225] = 04565; $code[002225] = *L02225; sub L02225 { $core[($ib<<12)+$core[117]] = 02226; $pc = ($ib<<12)+$core[117]+1; $code[($ib<<12)+$core[117]] = *emul8; $inh = 0; goto &fetch; }
$core[002226] = 02023; $code[002226] = *I02226; sub I02226 { if (++$core[000023] == 010000) { $core[000023] = 0; $pc++; }$code[000023] = *emul8; goto &fetch; }
$core[002227] = 01065; $code[002227] = *I02227; sub I02227 { $lac += $core[000065]; goto &fetch; }
$core[002230] = 07700; $code[002230] = *I02230; sub I02230 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002231] = 01423; $code[002231] = *P02231; sub P02231 { $lac += $core[($df<<12)+$core[19]]; goto &fetch; }
$core[002232] = 04563; $code[002232] = *I02232; sub I02232 { $core[($ib<<12)+$core[115]] = 02233; $pc = ($ib<<12)+$core[115]+1; $code[($ib<<12)+$core[115]] = *emul8; $inh = 0; goto &fetch; }
$core[002233] = 05217; $code[002233] = *I02233; sub I02233 { $pc = 002217; $inh = 0; goto &fetch; }
$core[002234] = 01423; $code[002234] = *I02234; sub I02234 { $lac += $core[($df<<12)+$core[19]]; goto &fetch; }
$core[002235] = 03067; $code[002235] = *I02235; sub I02235 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[002236] = 05225; $code[002236] = *I02236; sub I02236 { $pc = 002225; $inh = 0; goto &fetch; }
$core[002237] = 01060; $code[002237] = *L02237; sub L02237 { $lac += $core[000060]; goto &fetch; }
$core[002240] = 03031; $code[002240] = *I02240; sub I02240 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[002241] = 05541; $code[002241] = *I02241; sub I02241 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[002242] = 00000; $code[002242] = *S02242; sub S02242 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002243] = 01133; $code[002243] = *I02243; sub I02243 { $lac += $core[000133]; goto &fetch; }
$core[002244] = 03025; $code[002244] = *I02244; sub I02244 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[002245] = 01133; $code[002245] = *I02245; sub I02245 { $lac += $core[000133]; goto &fetch; }
$core[002246] = 03023; $code[002246] = *L02246; sub L02246 { $core[000023] = $lac & 07777; $lac &= 010000; $code[000023] = *emul8; goto &fetch; }
$core[002247] = 01023; $code[002247] = *I02247; sub I02247 { $lac += $core[000023]; goto &fetch; }
$core[002250] = 03011; $code[002250] = *I02250; sub I02250 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[002251] = 01067; $code[002251] = *I02251; sub I02251 { $lac += $core[000067]; goto &fetch; }
$core[002252] = 07141; $code[002252] = *I02252; sub I02252 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[002253] = 01411; $code[002253] = *D02253; sub D02253 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[002254] = 07450; $code[002254] = *I02254; sub I02254 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002255] = 05266; $code[002255] = *I02255; sub I02255 { $pc = 002266; $inh = 0; goto &fetch; }
$core[002256] = 07630; $code[002256] = *I02256; sub I02256 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002257] = 05267; $code[002257] = *I02257; sub I02257 { $pc = 002267; $inh = 0; goto &fetch; }
$core[002260] = 01023; $code[002260] = *I02260; sub I02260 { $lac += $core[000023]; goto &fetch; }
$core[002261] = 03025; $code[002261] = *I02261; sub I02261 { $core[000025] = $lac & 07777; $lac &= 010000; $code[000025] = *emul8; goto &fetch; }
$core[002262] = 01423; $code[002262] = *I02262; sub I02262 { $lac += $core[($df<<12)+$core[19]]; goto &fetch; }
$core[002263] = 07440; $code[002263] = *I02263; sub I02263 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002264] = 05246; $code[002264] = *I02264; sub I02264 { $pc = 002246; $inh = 0; goto &fetch; }
$core[002265] = 07410; $code[002265] = *I02265; sub I02265 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002266] = 02242; $code[002266] = *L02266; sub L02266 { if (++$core[002242] == 010000) { $core[002242] = 0; $pc++; }$code[002242] = *emul8; goto &fetch; }
$core[002267] = 01023; $code[002267] = *L02267; sub L02267 { $lac += $core[000023]; goto &fetch; }
$core[002270] = 07001; $code[002270] = *I02270; sub I02270 { $lac++; goto &fetch; }
$core[002271] = 03017; $code[002271] = *I02271; sub I02271 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[002272] = 03020; $code[002272] = *I02272; sub I02272 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[002273] = 05642; $code[002273] = *I02273; sub I02273 { $pc = ($ib<<12)+$core[1186]; $inh = 0; goto &fetch; }
$core[002274] = 00000; $code[002274] = *S02274; sub S02274 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002275] = 04330; $code[002275] = *L02275; sub L02275 { $core[002330] = 02276; $pc = 002330+1; $code[002330] = *emul8; $inh = 0; goto &fetch; }
$core[002276] = 07710; $code[002276] = *L02276; sub L02276 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002277] = 01006; $code[002277] = *I02277; sub I02277 { $lac += $core[000006]; goto &fetch; }
$core[002300] = 01357; $code[002300] = *I02300; sub I02300 { $lac += $core[002357]; goto &fetch; }
$core[002301] = 01066; $code[002301] = *I02301; sub I02301 { $lac += $core[000066]; goto &fetch; }
$core[002302] = 07450; $code[002302] = *P02302; sub P02302 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002303] = 05316; $code[002303] = *I02303; sub I02303 { $pc = 002316; $inh = 0; goto &fetch; }
$core[002304] = 01075; $code[002304] = *I02304; sub I02304 { $lac += $core[000075]; goto &fetch; }
$core[002305] = 03066; $code[002305] = *L02305; sub L02305 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[002306] = 01026; $code[002306] = *I02306; sub I02306 { $lac += $core[000026]; goto &fetch; }
$core[002307] = 01100; $code[002307] = *I02307; sub I02307 { $lac += $core[000100]; goto &fetch; }
$core[002310] = 07650; $code[002310] = *I02310; sub I02310 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002311] = 04551; $code[002311] = *I02311; sub I02311 { $core[($ib<<12)+$core[105]] = 02312; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002312] = 05674; $code[002312] = *I02312; sub I02312 { $pc = ($ib<<12)+$core[1212]; $inh = 0; goto &fetch; }
$core[002313] = 04330; $code[002313] = *L02313; sub L02313 { $core[002330] = 02314; $pc = 002330+1; $code[002330] = *emul8; $inh = 0; goto &fetch; }
$core[002314] = 07040; $code[002314] = *D02314; sub D02314 { $lac ^= 07777; goto &fetch; }
$core[002315] = 05276; $code[002315] = *I02315; sub I02315 { $pc = 002276; $inh = 0; goto &fetch; }
$core[002316] = 01026; $code[002316] = *L02316; sub L02316 { $lac += $core[000026]; goto &fetch; }
$core[002317] = 07640; $code[002317] = *I02317; sub I02317 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002320] = 05326; $code[002320] = *I02320; sub I02320 { $pc = 002326; $inh = 0; goto &fetch; }
$core[002321] = 01100; $code[002321] = *I02321; sub I02321 { $lac += $core[000100]; goto &fetch; }
$core[002322] = 07650; $code[002322] = *I02322; sub I02322 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002323] = 07001; $code[002323] = *I02323; sub I02323 { $lac++; goto &fetch; }
$core[002324] = 03100; $code[002324] = *I02324; sub I02324 { $core[000100] = $lac & 07777; $lac &= 010000; $code[000100] = *emul8; goto &fetch; }
$core[002325] = 05275; $code[002325] = *I02325; sub I02325 { $pc = 002275; $inh = 0; goto &fetch; }
$core[002326] = 01110; $code[002326] = *L02326; sub L02326 { $lac += $core[000110]; goto &fetch; }
$core[002327] = 05305; $code[002327] = *I02327; sub I02327 { $pc = 002305; $inh = 0; goto &fetch; }
$core[002330] = 00000; $code[002330] = *S02330; sub S02330 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002331] = 02020; $code[002331] = *I02331; sub I02331 { if (++$core[000020] == 010000) { $core[000020] = 0; $pc++; }$code[000020] = *emul8; goto &fetch; }
$core[002332] = 05345; $code[002332] = *I02332; sub I02332 { $pc = 002345; $inh = 0; goto &fetch; }
$core[002333] = 01021; $code[002333] = *I02333; sub I02333 { $lac += $core[000021]; goto &fetch; }
$core[002334] = 00122; $code[002334] = *L02334; sub L02334 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[002335] = 03066; $code[002335] = *I02335; sub I02335 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[002336] = 01066; $code[002336] = *I02336; sub I02336 { $lac += $core[000066]; goto &fetch; }
$core[002337] = 01103; $code[002337] = *I02337; sub I02337 { $lac += $core[000103]; goto &fetch; }
$core[002340] = 07650; $code[002340] = *I02340; sub I02340 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002341] = 05313; $code[002341] = *I02341; sub I02341 { $pc = 002313; $inh = 0; goto &fetch; }
$core[002342] = 01066; $code[002342] = *I02342; sub I02342 { $lac += $core[000066]; goto &fetch; }
$core[002343] = 01356; $code[002343] = *I02343; sub I02343 { $lac += $core[002356]; goto &fetch; }
$core[002344] = 05730; $code[002344] = *L02344; sub L02344 { $pc = ($ib<<12)+$core[1240]; $inh = 0; goto &fetch; }
$core[002345] = 01417; $code[002345] = *L02345; sub L02345 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac += $core[($df<<12)+$core[000017]]; goto &fetch; }
$core[002346] = 03021; $code[002346] = *I02346; sub I02346 { $core[000021] = $lac & 07777; $lac &= 010000; $code[000021] = *emul8; goto &fetch; }
$core[002347] = 07040; $code[002347] = *I02347; sub I02347 { $lac ^= 07777; goto &fetch; }
$core[002350] = 03020; $code[002350] = *I02350; sub I02350 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[002351] = 01021; $code[002351] = *I02351; sub I02351 { $lac += $core[000021]; goto &fetch; }
$core[002352] = 07112; $code[002352] = *I02352; sub I02352 { $lac &= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[002353] = 07012; $code[002353] = *I02353; sub I02353 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[002354] = 07012; $code[002354] = *I02354; sub I02354 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[002355] = 05334; $code[002355] = *I02355; sub I02355 { $pc = 002334; $inh = 0; goto &fetch; }
$core[002356] = 07740; $code[002356] = *D02356; sub D02356 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002357] = 07641; $code[002357] = *D02357; sub D02357 { &emul8; goto &fetch; }
$core[002360] = 00000; $code[002360] = *S02360; sub S02360 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002361] = 07000; $code[002361] = *I02361; sub I02361 { goto &fetch; }
$core[002362] = 01425; $code[002362] = *I02362; sub I02362 { $lac += $core[($df<<12)+$core[21]]; goto &fetch; }
$core[002363] = 03460; $code[002363] = *I02363; sub I02363 { $core[($df<<12)+$core[48]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[48]] = *emul8; goto &fetch; }
$core[002364] = 01060; $code[002364] = *I02364; sub I02364 { $lac += $core[000060]; goto &fetch; }
$core[002365] = 03425; $code[002365] = *I02365; sub I02365 { $core[($df<<12)+$core[21]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[002366] = 01061; $code[002366] = *I02366; sub I02366 { $lac += $core[000061]; goto &fetch; }
$core[002367] = 07440; $code[002367] = *I02367; sub I02367 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002370] = 03410; $code[002370] = *I02370; sub I02370 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[002371] = 01010; $code[002371] = *I02371; sub I02371 { $lac += $core[000010]; goto &fetch; }
$core[002372] = 07001; $code[002372] = *I02372; sub I02372 { $lac++; goto &fetch; }
$core[002373] = 03060; $code[002373] = *I02373; sub I02373 { $core[000060] = $lac & 07777; $lac &= 010000; $code[000060] = *emul8; goto &fetch; }
$core[002374] = 01060; $code[002374] = *I02374; sub I02374 { $lac += $core[000060]; goto &fetch; }
$core[002375] = 03031; $code[002375] = *I02375; sub I02375 { $core[000031] = $lac & 07777; $lac &= 010000; $code[000031] = *emul8; goto &fetch; }
$core[002376] = 05760; $code[002376] = *I02376; sub I02376 { $pc = ($ib<<12)+$core[1264]; $inh = 0; goto &fetch; }
$core[002377] = 01253; $code[002377] = *I02377; sub I02377 { $lac += $core[002253]; goto &fetch; }
$core[002400] = 00614; $code[002400] = *I02400; sub I02400 { $lac &= (010000|$core[($df<<12)+$core[1292]]); goto &fetch; }
$core[002401] = 06202; $code[002401] = *I02401; sub I02401 { &emul8; goto &fetch; }
$core[002402] = 00757; $code[002402] = *I02402; sub I02402 { $lac &= (010000|$core[($df<<12)+$core[1391]]); goto &fetch; }
$core[002403] = 00757; $code[002403] = *I02403; sub I02403 { $lac &= (010000|$core[($df<<12)+$core[1391]]); goto &fetch; }
$core[002404] = 06250; $code[002404] = *I02404; sub I02404 { &emul8; goto &fetch; }
$core[002405] = 00001; $code[002405] = *I02405; sub I02405 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[002406] = 02000; $code[002406] = *I02406; sub I02406 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[002407] = 00000; $code[002407] = *D02407; sub D02407 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002410] = 00000; $code[002410] = *I02410; sub I02410 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002411] = 00000; $code[002411] = *I02411; sub I02411 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002412] = 00000; $code[002412] = *I02412; sub I02412 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002413] = 07766; $code[002413] = *D02413; sub D02413 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[002414] = 00000; $code[002414] = *S02414; sub S02414 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002415] = 06031; $code[002415] = *L02415; sub L02415 { &emul8; goto &fetch; }
$core[002416] = 05215; $code[002416] = *I02416; sub I02416 { $pc = 002415; $inh = 0; goto &fetch; }
$core[002417] = 06036; $code[002417] = *I02417; sub I02417 { &emul8; goto &fetch; }
$core[002420] = 00106; $code[002420] = *I02420; sub I02420 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[002421] = 07450; $code[002421] = *I02421; sub I02421 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002422] = 05215; $code[002422] = *I02422; sub I02422 { $pc = 002415; $inh = 0; goto &fetch; }
$core[002423] = 01123; $code[002423] = *I02423; sub I02423 { $lac += $core[000123]; goto &fetch; }
$core[002424] = 05614; $code[002424] = *I02424; sub I02424 { $pc = ($ib<<12)+$core[1292]; $inh = 0; goto &fetch; }
$core[002425] = 00000; $code[002425] = *S02425; sub S02425 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002426] = 01067; $code[002426] = *I02426; sub I02426 { $lac += $core[000067]; goto &fetch; }
$core[002427] = 04557; $code[002427] = *I02427; sub I02427 { $core[($ib<<12)+$core[111]] = 02430; $pc = ($ib<<12)+$core[111]+1; $code[($ib<<12)+$core[111]] = *emul8; $inh = 0; goto &fetch; }
$core[002430] = 00122; $code[002430] = *I02430; sub I02430 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[002431] = 04242; $code[002431] = *I02431; sub I02431 { $core[002442] = 02432; $pc = 002442+1; $code[002442] = *emul8; $inh = 0; goto &fetch; }
$core[002432] = 01102; $code[002432] = *I02432; sub I02432 { $lac += $core[000102]; goto &fetch; }
$core[002433] = 04551; $code[002433] = *I02433; sub I02433 { $core[($ib<<12)+$core[105]] = 02434; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002434] = 01067; $code[002434] = *I02434; sub I02434 { $lac += $core[000067]; goto &fetch; }
$core[002435] = 04242; $code[002435] = *I02435; sub I02435 { $core[002442] = 02436; $pc = 002442+1; $code[002442] = *emul8; $inh = 0; goto &fetch; }
$core[002436] = 01356; $code[002436] = *I02436; sub I02436 { $lac += $core[002556]; goto &fetch; }
$core[002437] = 03066; $code[002437] = *I02437; sub I02437 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[002440] = 04551; $code[002440] = *I02440; sub I02440 { $core[($ib<<12)+$core[105]] = 02441; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002441] = 05625; $code[002441] = *I02441; sub I02441 { $pc = ($ib<<12)+$core[1301]; $inh = 0; goto &fetch; }
$core[002442] = 00000; $code[002442] = *S02442; sub S02442 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002443] = 00106; $code[002443] = *I02443; sub I02443 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[002444] = 03032; $code[002444] = *I02444; sub I02444 { $core[000032] = $lac & 07777; $lac &= 010000; $code[000032] = *emul8; goto &fetch; }
$core[002445] = 01113; $code[002445] = *I02445; sub I02445 { $lac += $core[000113]; goto &fetch; }
$core[002446] = 03033; $code[002446] = *I02446; sub I02446 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[002447] = 05252; $code[002447] = *I02447; sub I02447 { $pc = 002452; $inh = 0; goto &fetch; }
$core[002450] = 02033; $code[002450] = *L02450; sub L02450 { if (++$core[000033] == 010000) { $core[000033] = 0; $pc++; }$code[000033] = *emul8; goto &fetch; }
$core[002451] = 03032; $code[002451] = *I02451; sub I02451 { $core[000032] = $lac & 07777; $lac &= 010000; $code[000032] = *emul8; goto &fetch; }
$core[002452] = 01032; $code[002452] = *L02452; sub L02452 { $lac += $core[000032]; goto &fetch; }
$core[002453] = 01213; $code[002453] = *I02453; sub I02453 { $lac += $core[002413]; goto &fetch; }
$core[002454] = 07500; $code[002454] = *I02454; sub I02454 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[002455] = 05250; $code[002455] = *I02455; sub I02455 { $pc = 002450; $inh = 0; goto &fetch; }
$core[002456] = 07200; $code[002456] = *I02456; sub I02456 { $lac &= 010000; goto &fetch; }
$core[002457] = 01033; $code[002457] = *I02457; sub I02457 { $lac += $core[000033]; goto &fetch; }
$core[002460] = 04551; $code[002460] = *I02460; sub I02460 { $core[($ib<<12)+$core[105]] = 02461; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002461] = 01032; $code[002461] = *I02461; sub I02461 { $lac += $core[000032]; goto &fetch; }
$core[002462] = 01113; $code[002462] = *D02462; sub D02462 { $lac += $core[000113]; goto &fetch; }
$core[002463] = 04551; $code[002463] = *I02463; sub I02463 { $core[($ib<<12)+$core[105]] = 02464; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002464] = 05642; $code[002464] = *I02464; sub I02464 { $pc = ($ib<<12)+$core[1314]; $inh = 0; goto &fetch; }
$core[002465] = 00000; $code[002465] = *S02465; sub S02465 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002466] = 07450; $code[002466] = *I02466; sub I02466 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002467] = 01066; $code[002467] = *I02467; sub I02467 { $lac += $core[000066]; goto &fetch; }
$core[002470] = 01116; $code[002470] = *I02470; sub I02470 { $lac += $core[000116]; goto &fetch; }
$core[002471] = 07450; $code[002471] = *I02471; sub I02471 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002472] = 05276; $code[002472] = *I02472; sub I02472 { $pc = 002476; $inh = 0; goto &fetch; }
$core[002473] = 01077; $code[002473] = *I02473; sub I02473 { $lac += $core[000077]; goto &fetch; }
$core[002474] = 04463; $code[002474] = *L02474; sub L02474 { $core[($ib<<12)+$core[51]] = 02475; $pc = ($ib<<12)+$core[51]+1; $code[($ib<<12)+$core[51]] = *emul8; $inh = 0; goto &fetch; }
$core[002475] = 05665; $code[002475] = *I02475; sub I02475 { $pc = ($ib<<12)+$core[1333]; $inh = 0; goto &fetch; }
$core[002476] = 01077; $code[002476] = *L02476; sub L02476 { $lac += $core[000077]; goto &fetch; }
$core[002477] = 04463; $code[002477] = *I02477; sub I02477 { $core[($ib<<12)+$core[51]] = 02500; $pc = ($ib<<12)+$core[51]+1; $code[($ib<<12)+$core[51]] = *emul8; $inh = 0; goto &fetch; }
$core[002500] = 01076; $code[002500] = *I02500; sub I02500 { $lac += $core[000076]; goto &fetch; }
$core[002501] = 05274; $code[002501] = *I02501; sub I02501 { $pc = 002474; $inh = 0; goto &fetch; }
$core[002502] = 00000; $code[002502] = *S02502; sub S02502 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002503] = 01110; $code[002503] = *I02503; sub I02503 { $lac += $core[000110]; goto &fetch; }
$core[002504] = 07041; $code[002504] = *I02504; sub I02504 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002505] = 01066; $code[002505] = *I02505; sub I02505 { $lac += $core[000066]; goto &fetch; }
$core[002506] = 07450; $code[002506] = *I02506; sub I02506 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002507] = 01352; $code[002507] = *I02507; sub I02507 { $lac += $core[002552]; goto &fetch; }
$core[002510] = 01101; $code[002510] = *I02510; sub I02510 { $lac += $core[000101]; goto &fetch; }
$core[002511] = 07450; $code[002511] = *I02511; sub I02511 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002512] = 05755; $code[002512] = *I02512; sub I02512 { $pc = ($ib<<12)+$core[1389]; $inh = 0; goto &fetch; }
$core[002513] = 01353; $code[002513] = *I02513; sub I02513 { $lac += $core[002553]; goto &fetch; }
$core[002514] = 03071; $code[002514] = *I02514; sub I02514 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[002515] = 01071; $code[002515] = *I02515; sub I02515 { $lac += $core[000071]; goto &fetch; }
$core[002516] = 00354; $code[002516] = *I02516; sub I02516 { $lac &= (010000|$core[002554]); goto &fetch; }
$core[002517] = 01356; $code[002517] = *D02517; sub D02517 { $lac += $core[002556]; goto &fetch; }
$core[002520] = 07440; $code[002520] = *I02520; sub I02520 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002521] = 01354; $code[002521] = *I02521; sub I02521 { $lac += $core[002554]; goto &fetch; }
$core[002522] = 07650; $code[002522] = *I02522; sub I02522 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002523] = 05332; $code[002523] = *I02523; sub I02523 { $pc = 002532; $inh = 0; goto &fetch; }
$core[002524] = 01071; $code[002524] = *L02524; sub L02524 { $lac += $core[000071]; goto &fetch; }
$core[002525] = 00122; $code[002525] = *I02525; sub I02525 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[002526] = 07440; $code[002526] = *I02526; sub I02526 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002527] = 04335; $code[002527] = *I02527; sub I02527 { $core[002535] = 02530; $pc = 002535+1; $code[002535] = *emul8; $inh = 0; goto &fetch; }
$core[002530] = 07000; $code[002530] = *L02530; sub L02530 { goto &fetch; }
$core[002531] = 05702; $code[002531] = *I02531; sub I02531 { $pc = ($ib<<12)+$core[1346]; $inh = 0; goto &fetch; }
$core[002532] = 01122; $code[002532] = *L02532; sub L02532 { $lac += $core[000122]; goto &fetch; }
$core[002533] = 04335; $code[002533] = *I02533; sub I02533 { $core[002535] = 02534; $pc = 002535+1; $code[002535] = *emul8; $inh = 0; goto &fetch; }
$core[002534] = 05324; $code[002534] = *I02534; sub I02534 { $pc = 002524; $inh = 0; goto &fetch; }
$core[002535] = 00000; $code[002535] = *S02535; sub S02535 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002536] = 02062; $code[002536] = *I02536; sub I02536 { if (++$core[000062] == 010000) { $core[000062] = 0; $pc++; }$code[000062] = *emul8; goto &fetch; }
$core[002537] = 05357; $code[002537] = *I02537; sub I02537 { $pc = 002557; $inh = 0; goto &fetch; }
$core[002540] = 01061; $code[002540] = *I02540; sub I02540 { $lac += $core[000061]; goto &fetch; }
$core[002541] = 03410; $code[002541] = *I02541; sub I02541 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[002542] = 03061; $code[002542] = *I02542; sub I02542 { $core[000061] = $lac & 07777; $lac &= 010000; $code[000061] = *emul8; goto &fetch; }
$core[002543] = 01013; $code[002543] = *I02543; sub I02543 { $lac += $core[000013]; goto &fetch; }
$core[002544] = 07141; $code[002544] = *I02544; sub I02544 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[002545] = 01005; $code[002545] = *I02545; sub I02545 { $lac += $core[000005]; goto &fetch; }
$core[002546] = 01010; $code[002546] = *I02546; sub I02546 { $lac += $core[000010]; goto &fetch; }
$core[002547] = 07620; $code[002547] = *I02547; sub I02547 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002550] = 05735; $code[002550] = *I02550; sub I02550 { $pc = ($ib<<12)+$core[1373]; $inh = 0; goto &fetch; }
$core[002551] = 04566; $code[002551] = *I02551; sub I02551 { $core[($ib<<12)+$core[118]] = 02552; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[002552] = 00040; $code[002552] = *D02552; sub D02552 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[002553] = 00377; $code[002553] = *D02553; sub D02553 { $lac &= (010000|$core[002577]); goto &fetch; }
$core[002554] = 00140; $code[002554] = *D02554; sub D02554 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[002555] = 03004; $code[002555] = *P02555; sub P02555 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[002556] = 07640; $code[002556] = *D02556; sub D02556 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002557] = 04557; $code[002557] = *P02557; sub P02557 { $core[($ib<<12)+$core[111]] = 02560; $pc = ($ib<<12)+$core[111]+1; $code[($ib<<12)+$core[111]] = *emul8; $inh = 0; goto &fetch; }
$core[002560] = 03061; $code[002560] = *I02560; sub I02560 { $core[000061] = $lac & 07777; $lac &= 010000; $code[000061] = *emul8; goto &fetch; }
$core[002561] = 07040; $code[002561] = *I02561; sub I02561 { $lac ^= 07777; goto &fetch; }
$core[002562] = 03062; $code[002562] = *I02562; sub I02562 { $core[000062] = $lac & 07777; $lac &= 010000; $code[000062] = *emul8; goto &fetch; }
$core[002563] = 05735; $code[002563] = *I02563; sub I02563 { $pc = ($ib<<12)+$core[1373]; $inh = 0; goto &fetch; }
$core[002600] = 00000; $code[002600] = *D02600; sub D02600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002601] = 00000; $code[002601] = *D02601; sub D02601 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002602] = 07575; $code[002602] = *D02602; sub D02602 { &emul8; goto &fetch; }
$core[002603] = 03200; $code[002603] = *L02603; sub L02603 { $core[002600] = $lac & 07777; $lac &= 010000; $code[002600] = *emul8; goto &fetch; }
$core[002604] = 07010; $code[002604] = *I02604; sub I02604 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002605] = 03201; $code[002605] = *I02605; sub I02605 { $core[002601] = $lac & 07777; $lac &= 010000; $code[002601] = *emul8; goto &fetch; }
$core[002606] = 06041; $code[002606] = *I02606; sub I02606 { &emul8; goto &fetch; }
$core[002607] = 05225; $code[002607] = *I02607; sub I02607 { $pc = 002625; $inh = 0; goto &fetch; }
$core[002610] = 06042; $code[002610] = *I02610; sub I02610 { &emul8; goto &fetch; }
$core[002611] = 03016; $code[002611] = *I02611; sub I02611 { $core[000016] = $lac & 07777; $lac &= 010000; $code[000016] = *emul8; goto &fetch; }
$core[002612] = 01665; $code[002612] = *I02612; sub I02612 { $lac += $core[($df<<12)+$core[1461]]; goto &fetch; }
$core[002613] = 07450; $code[002613] = *I02613; sub I02613 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002614] = 05225; $code[002614] = *I02614; sub I02614 { $pc = 002625; $inh = 0; goto &fetch; }
$core[002615] = 06044; $code[002615] = *I02615; sub I02615 { &emul8; goto &fetch; }
$core[002616] = 03016; $code[002616] = *I02616; sub I02616 { $core[000016] = $lac & 07777; $lac &= 010000; $code[000016] = *emul8; goto &fetch; }
$core[002617] = 03665; $code[002617] = *I02617; sub I02617 { $core[($df<<12)+$core[1461]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1461]] = *emul8; goto &fetch; }
$core[002620] = 01265; $code[002620] = *I02620; sub I02620 { $lac += $core[002665]; goto &fetch; }
$core[002621] = 07001; $code[002621] = *I02621; sub I02621 { $lac++; goto &fetch; }
$core[002622] = 00107; $code[002622] = *I02622; sub I02622 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[002623] = 01263; $code[002623] = *I02623; sub I02623 { $lac += $core[002663]; goto &fetch; }
$core[002624] = 03265; $code[002624] = *I02624; sub I02624 { $core[002665] = $lac & 07777; $lac &= 010000; $code[002665] = *emul8; goto &fetch; }
$core[002625] = 06031; $code[002625] = *L02625; sub L02625 { &emul8; goto &fetch; }
$core[002626] = 05246; $code[002626] = *I02626; sub I02626 { $pc = 002646; $inh = 0; goto &fetch; }
$core[002627] = 06036; $code[002627] = *I02627; sub I02627 { &emul8; goto &fetch; }
$core[002630] = 00106; $code[002630] = *I02630; sub I02630 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[002631] = 07450; $code[002631] = *I02631; sub I02631 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002632] = 05246; $code[002632] = *I02632; sub I02632 { $pc = 002646; $inh = 0; goto &fetch; }
$core[002633] = 01123; $code[002633] = *I02633; sub I02633 { $lac += $core[000123]; goto &fetch; }
$core[002634] = 03262; $code[002634] = *I02634; sub I02634 { $core[002662] = $lac & 07777; $lac &= 010000; $code[002662] = *emul8; goto &fetch; }
$core[002635] = 01262; $code[002635] = *I02635; sub I02635 { $lac += $core[002662]; goto &fetch; }
$core[002636] = 01202; $code[002636] = *I02636; sub I02636 { $lac += $core[002602]; goto &fetch; }
$core[002637] = 07650; $code[002637] = *I02637; sub I02637 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002640] = 05340; $code[002640] = *I02640; sub I02640 { $pc = 002740; $inh = 0; goto &fetch; }
$core[002641] = 01034; $code[002641] = *I02641; sub I02641 { $lac += $core[000034]; goto &fetch; }
$core[002642] = 07640; $code[002642] = *I02642; sub I02642 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002643] = 04566; $code[002643] = *I02643; sub I02643 { $core[($ib<<12)+$core[118]] = 02644; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[002644] = 01262; $code[002644] = *I02644; sub I02644 { $lac += $core[002662]; goto &fetch; }
$core[002645] = 03034; $code[002645] = *I02645; sub I02645 { $core[000034] = $lac & 07777; $lac &= 010000; $code[000034] = *emul8; goto &fetch; }
$core[002646] = 06011; $code[002646] = *L02646; sub L02646 { &emul8; goto &fetch; }
$core[002647] = 05252; $code[002647] = *I02647; sub I02647 { $pc = 002652; $inh = 0; goto &fetch; }
$core[002650] = 06012; $code[002650] = *I02650; sub I02650 { &emul8; goto &fetch; }
$core[002651] = 03037; $code[002651] = *I02651; sub I02651 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[002652] = 06244; $code[002652] = *L02652; sub L02652 { &emul8; goto &fetch; }
$core[002653] = 06101; $code[002653] = *I02653; sub I02653 { &emul8; goto &fetch; }
$core[002654] = 07000; $code[002654] = *D02654; sub D02654 { goto &fetch; }
$core[002655] = 01201; $code[002655] = *I02655; sub I02655 { $lac += $core[002601]; goto &fetch; }
$core[002656] = 07104; $code[002656] = *I02656; sub I02656 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002657] = 01200; $code[002657] = *I02657; sub I02657 { $lac += $core[002600]; goto &fetch; }
$core[002660] = 06001; $code[002660] = *I02660; sub I02660 { &emul8; goto &fetch; }
$core[002661] = 05400; $code[002661] = *D02661; sub D02661 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[002662] = 00000; $code[002662] = *D02662; sub D02662 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002663] = 03120; $code[002663] = *D02663; sub D02663 { $core[000120] = $lac & 07777; $lac &= 010000; $code[000120] = *emul8; goto &fetch; }
$core[002664] = 03120; $code[002664] = *P02664; sub P02664 { $core[000120] = $lac & 07777; $lac &= 010000; $code[000120] = *emul8; goto &fetch; }
$core[002665] = 03120; $code[002665] = *P02665; sub P02665 { $core[000120] = $lac & 07777; $lac &= 010000; $code[000120] = *emul8; goto &fetch; }
$core[002666] = 00000; $code[002666] = *S02666; sub S02666 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002667] = 01034; $code[002667] = *L02667; sub L02667 { $lac += $core[000034]; goto &fetch; }
$core[002670] = 07550; $code[002670] = *I02670; sub I02670 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002671] = 05267; $code[002671] = *I02671; sub I02671 { $pc = 002667; $inh = 0; goto &fetch; }
$core[002672] = 03276; $code[002672] = *I02672; sub I02672 { $core[002676] = $lac & 07777; $lac &= 010000; $code[002676] = *emul8; goto &fetch; }
$core[002673] = 03034; $code[002673] = *I02673; sub I02673 { $core[000034] = $lac & 07777; $lac &= 010000; $code[000034] = *emul8; goto &fetch; }
$core[002674] = 01276; $code[002674] = *I02674; sub I02674 { $lac += $core[002676]; goto &fetch; }
$core[002675] = 05666; $code[002675] = *D02675; sub D02675 { $pc = ($ib<<12)+$core[1462]; $inh = 0; goto &fetch; }
$core[002676] = 00000; $code[002676] = *S02676; sub S02676 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002677] = 03266; $code[002677] = *I02677; sub I02677 { $core[002666] = $lac & 07777; $lac &= 010000; $code[002666] = *emul8; goto &fetch; }
$core[002700] = 06001; $code[002700] = *I02700; sub I02700 { &emul8; goto &fetch; }
$core[002701] = 01664; $code[002701] = *L02701; sub L02701 { $lac += $core[($df<<12)+$core[1460]]; goto &fetch; }
$core[002702] = 07640; $code[002702] = *I02702; sub I02702 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002703] = 05301; $code[002703] = *I02703; sub I02703 { $pc = 002701; $inh = 0; goto &fetch; }
$core[002704] = 06002; $code[002704] = *I02704; sub I02704 { &emul8; goto &fetch; }
$core[002705] = 01016; $code[002705] = *I02705; sub I02705 { $lac += $core[000016]; goto &fetch; }
$core[002706] = 07640; $code[002706] = *I02706; sub I02706 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002707] = 05314; $code[002707] = *I02707; sub I02707 { $pc = 002714; $inh = 0; goto &fetch; }
$core[002710] = 01266; $code[002710] = *I02710; sub I02710 { $lac += $core[002666]; goto &fetch; }
$core[002711] = 06046; $code[002711] = *I02711; sub I02711 { &emul8; goto &fetch; }
$core[002712] = 03016; $code[002712] = *I02712; sub I02712 { $core[000016] = $lac & 07777; $lac &= 010000; $code[000016] = *emul8; goto &fetch; }
$core[002713] = 05323; $code[002713] = *I02713; sub I02713 { $pc = 002723; $inh = 0; goto &fetch; }
$core[002714] = 01266; $code[002714] = *L02714; sub L02714 { $lac += $core[002666]; goto &fetch; }
$core[002715] = 03664; $code[002715] = *I02715; sub I02715 { $core[($df<<12)+$core[1460]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1460]] = *emul8; goto &fetch; }
$core[002716] = 01264; $code[002716] = *I02716; sub I02716 { $lac += $core[002664]; goto &fetch; }
$core[002717] = 07001; $code[002717] = *I02717; sub I02717 { $lac++; goto &fetch; }
$core[002720] = 00107; $code[002720] = *I02720; sub I02720 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[002721] = 01263; $code[002721] = *I02721; sub I02721 { $lac += $core[002663]; goto &fetch; }
$core[002722] = 03264; $code[002722] = *I02722; sub I02722 { $core[002664] = $lac & 07777; $lac &= 010000; $code[002664] = *emul8; goto &fetch; }
$core[002723] = 06001; $code[002723] = *L02723; sub L02723 { &emul8; goto &fetch; }
$core[002724] = 05676; $code[002724] = *I02724; sub I02724 { $pc = ($ib<<12)+$core[1470]; $inh = 0; goto &fetch; }
$core[002725] = 03326; $code[002725] = *D02725; sub D02725 { $core[002726] = $lac & 07777; $lac &= 010000; $code[002726] = *emul8; goto &fetch; }
$core[002726] = 00000; $code[002726] = *D02726; sub D02726 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[002727] = 07240; $code[002727] = *I02727; sub I02727 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002730] = 01326; $code[002730] = *I02730; sub I02730 { $lac += $core[002726]; goto &fetch; }
$core[002731] = 03067; $code[002731] = *I02731; sub I02731 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[002732] = 06001; $code[002732] = *I02732; sub I02732 { &emul8; goto &fetch; }
$core[002733] = 01016; $code[002733] = *L02733; sub L02733 { $lac += $core[000016]; goto &fetch; }
$core[002734] = 07640; $code[002734] = *I02734; sub I02734 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[002735] = 05333; $code[002735] = *I02735; sub I02735 { $pc = 002733; $inh = 0; goto &fetch; }
$core[002736] = 06002; $code[002736] = *I02736; sub I02736 { &emul8; goto &fetch; }
$core[002737] = 05342; $code[002737] = *I02737; sub I02737 { $pc = 002742; $inh = 0; goto &fetch; }
$core[002740] = 01123; $code[002740] = *L02740; sub L02740 { $lac += $core[000123]; goto &fetch; }
$core[002741] = 03067; $code[002741] = *I02741; sub I02741 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[002742] = 02016; $code[002742] = *L02742; sub L02742 { if (++$core[000016] == 010000) { $core[000016] = 0; $pc++; }$code[000016] = *emul8; goto &fetch; }
$core[002743] = 01105; $code[002743] = *I02743; sub I02743 { $lac += $core[000105]; goto &fetch; }
$core[002744] = 03057; $code[002744] = *I02744; sub I02744 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[002745] = 07040; $code[002745] = *I02745; sub I02745 { $lac ^= 07777; goto &fetch; }
$core[002746] = 01263; $code[002746] = *I02746; sub I02746 { $lac += $core[002663]; goto &fetch; }
$core[002747] = 03010; $code[002747] = *I02747; sub I02747 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[002750] = 07000; $code[002750] = *I02750; sub I02750 { goto &fetch; }
$core[002751] = 03410; $code[002751] = *L02751; sub L02751 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[002752] = 02057; $code[002752] = *I02752; sub I02752 { if (++$core[000057] == 010000) { $core[000057] = 0; $pc++; }$code[000057] = *emul8; goto &fetch; }
$core[002753] = 05351; $code[002753] = *I02753; sub I02753 { $pc = 002751; $inh = 0; goto &fetch; }
$core[002754] = 03034; $code[002754] = *I02754; sub I02754 { $core[000034] = $lac & 07777; $lac &= 010000; $code[000034] = *emul8; goto &fetch; }
$core[002755] = 01263; $code[002755] = *I02755; sub I02755 { $lac += $core[002663]; goto &fetch; }
$core[002756] = 03265; $code[002756] = *I02756; sub I02756 { $core[002665] = $lac & 07777; $lac &= 010000; $code[002665] = *emul8; goto &fetch; }
$core[002757] = 01263; $code[002757] = *I02757; sub I02757 { $lac += $core[002663]; goto &fetch; }
$core[002760] = 03264; $code[002760] = *I02760; sub I02760 { $core[002664] = $lac & 07777; $lac &= 010000; $code[002664] = *emul8; goto &fetch; }
$core[002761] = 07040; $code[002761] = *I02761; sub I02761 { $lac ^= 07777; goto &fetch; }
$core[002762] = 06046; $code[002762] = *I02762; sub I02762 { &emul8; goto &fetch; }
$core[002763] = 01101; $code[002763] = *I02763; sub I02763 { $lac += $core[000101]; goto &fetch; }
$core[002764] = 04551; $code[002764] = *I02764; sub I02764 { $core[($ib<<12)+$core[105]] = 02765; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002765] = 04553; $code[002765] = *I02765; sub I02765 { $core[($ib<<12)+$core[107]] = 02766; $pc = ($ib<<12)+$core[107]+1; $code[($ib<<12)+$core[107]] = *emul8; $inh = 0; goto &fetch; }
$core[002766] = 02022; $code[002766] = *I02766; sub I02766 { if (++$core[000022] == 010000) { $core[000022] = 0; $pc++; }$code[000022] = *emul8; goto &fetch; }
$core[002767] = 01422; $code[002767] = *I02767; sub I02767 { $lac += $core[($df<<12)+$core[18]]; goto &fetch; }
$core[002770] = 07450; $code[002770] = *I02770; sub I02770 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002771] = 05377; $code[002771] = *I02771; sub I02771 { $pc = 002777; $inh = 0; goto &fetch; }
$core[002772] = 03067; $code[002772] = *I02772; sub I02772 { $core[000067] = $lac & 07777; $lac &= 010000; $code[000067] = *emul8; goto &fetch; }
$core[002773] = 01101; $code[002773] = *I02773; sub I02773 { $lac += $core[000101]; goto &fetch; }
$core[002774] = 04551; $code[002774] = *I02774; sub I02774 { $core[($ib<<12)+$core[105]] = 02775; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002775] = 04551; $code[002775] = *I02775; sub I02775 { $core[($ib<<12)+$core[105]] = 02776; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[002776] = 04553; $code[002776] = *I02776; sub I02776 { $core[($ib<<12)+$core[107]] = 02777; $pc = ($ib<<12)+$core[107]+1; $code[($ib<<12)+$core[107]] = *emul8; $inh = 0; goto &fetch; }
$core[002777] = 01077; $code[002777] = *L02777; sub L02777 { $lac += $core[000077]; goto &fetch; }
$core[003000] = 04551; $code[003000] = *I03000; sub I03000 { $core[($ib<<12)+$core[105]] = 03001; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[003001] = 01126; $code[003001] = *I03001; sub I03001 { $lac += $core[000126]; goto &fetch; }
$core[003002] = 03152; $code[003002] = *I03002; sub I03002 { $core[000152] = $lac & 07777; $lac &= 010000; $code[000152] = *emul8; goto &fetch; }
$core[003003] = 05177; $code[003003] = *I03003; sub I03003 { $pc = 000177; $inh = 0; goto &fetch; }
$core[003004] = 01062; $code[003004] = *L03004; sub L03004 { $lac += $core[000062]; goto &fetch; }
$core[003005] = 07640; $code[003005] = *I03005; sub I03005 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003006] = 05214; $code[003006] = *I03006; sub I03006 { $pc = 003014; $inh = 0; goto &fetch; }
$core[003007] = 01010; $code[003007] = *I03007; sub I03007 { $lac += $core[000010]; goto &fetch; }
$core[003010] = 07041; $code[003010] = *I03010; sub I03010 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003011] = 01027; $code[003011] = *I03011; sub I03011 { $lac += $core[000027]; goto &fetch; }
$core[003012] = 07700; $code[003012] = *I03012; sub I03012 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003013] = 05641; $code[003013] = *I03013; sub I03013 { $pc = ($ib<<12)+$core[1569]; $inh = 0; goto &fetch; }
$core[003014] = 01251; $code[003014] = *L03014; sub L03014 { $lac += $core[003051]; goto &fetch; }
$core[003015] = 04551; $code[003015] = *I03015; sub I03015 { $core[($ib<<12)+$core[105]] = 03016; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[003016] = 01010; $code[003016] = *I03016; sub I03016 { $lac += $core[000010]; goto &fetch; }
$core[003017] = 03071; $code[003017] = *I03017; sub I03017 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[003020] = 07000; $code[003020] = *I03020; sub I03020 { goto &fetch; }
$core[003021] = 02062; $code[003021] = *I03021; sub I03021 { if (++$core[000062] == 010000) { $core[000062] = 0; $pc++; }$code[000062] = *emul8; goto &fetch; }
$core[003022] = 05242; $code[003022] = *I03022; sub I03022 { $pc = 003042; $inh = 0; goto &fetch; }
$core[003023] = 01471; $code[003023] = *I03023; sub I03023 { $lac += $core[($df<<12)+$core[57]]; goto &fetch; }
$core[003024] = 00122; $code[003024] = *I03024; sub I03024 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[003025] = 01103; $code[003025] = *I03025; sub I03025 { $lac += $core[000103]; goto &fetch; }
$core[003026] = 07640; $code[003026] = *I03026; sub I03026 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003027] = 05237; $code[003027] = *I03027; sub I03027 { $pc = 003037; $inh = 0; goto &fetch; }
$core[003030] = 07040; $code[003030] = *L03030; sub L03030 { $lac ^= 07777; goto &fetch; }
$core[003031] = 03062; $code[003031] = *L03031; sub L03031 { $core[000062] = $lac & 07777; $lac &= 010000; $code[000062] = *emul8; goto &fetch; }
$core[003032] = 07040; $code[003032] = *I03032; sub I03032 { $lac ^= 07777; goto &fetch; }
$core[003033] = 01010; $code[003033] = *I03033; sub I03033 { $lac += $core[000010]; goto &fetch; }
$core[003034] = 03010; $code[003034] = *I03034; sub I03034 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[003035] = 01471; $code[003035] = *I03035; sub I03035 { $lac += $core[($df<<12)+$core[57]]; goto &fetch; }
$core[003036] = 00101; $code[003036] = *I03036; sub I03036 { $lac &= (010000|$core[000101]); goto &fetch; }
$core[003037] = 03061; $code[003037] = *L03037; sub L03037 { $core[000061] = $lac & 07777; $lac &= 010000; $code[000061] = *emul8; goto &fetch; }
$core[003040] = 05641; $code[003040] = *I03040; sub I03040 { $pc = ($ib<<12)+$core[1569]; $inh = 0; goto &fetch; }
$core[003041] = 02530; $code[003041] = *P03041; sub P03041 { if (++$core[($df<<12)+$core[88]] == 010000) { $core[($df<<12)+$core[88]] = 0; $pc++; }$code[($df<<12)+$core[88]] = *emul8; goto &fetch; }
$core[003042] = 01471; $code[003042] = *L03042; sub L03042 { $lac += $core[($df<<12)+$core[57]]; goto &fetch; }
$core[003043] = 00101; $code[003043] = *I03043; sub I03043 { $lac &= (010000|$core[000101]); goto &fetch; }
$core[003044] = 01006; $code[003044] = *I03044; sub I03044 { $lac += $core[000006]; goto &fetch; }
$core[003045] = 07640; $code[003045] = *L03045; sub L03045 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003046] = 05230; $code[003046] = *I03046; sub I03046 { $pc = 003030; $inh = 0; goto &fetch; }
$core[003047] = 03471; $code[003047] = *I03047; sub I03047 { $core[($df<<12)+$core[57]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[57]] = *emul8; goto &fetch; }
$core[003050] = 05231; $code[003050] = *I03050; sub I03050 { $pc = 003031; $inh = 0; goto &fetch; }
$core[003051] = 00334; $code[003051] = *D03051; sub D03051 { $lac &= (010000|$core[003134]); goto &fetch; }
$core[003052] = 01060; $code[003052] = *I03052; sub I03052 { $lac += $core[000060]; goto &fetch; }
$core[003053] = 03030; $code[003053] = *L03053; sub L03053 { $core[000030] = $lac & 07777; $lac &= 010000; $code[000030] = *emul8; goto &fetch; }
$core[003054] = 01031; $code[003054] = *I03054; sub I03054 { $lac += $core[000031]; goto &fetch; }
$core[003055] = 07041; $code[003055] = *I03055; sub I03055 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003056] = 01030; $code[003056] = *I03056; sub I03056 { $lac += $core[000030]; goto &fetch; }
$core[003057] = 07650; $code[003057] = *I03057; sub I03057 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003060] = 05541; $code[003060] = *I03060; sub I03060 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[003061] = 01430; $code[003061] = *I03061; sub I03061 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[003062] = 03316; $code[003062] = *I03062; sub I03062 { $core[003116] = $lac & 07777; $lac &= 010000; $code[003116] = *emul8; goto &fetch; }
$core[003063] = 01315; $code[003063] = *I03063; sub I03063 { $lac += $core[003115]; goto &fetch; }
$core[003064] = 03017; $code[003064] = *I03064; sub I03064 { $core[000017] = $lac & 07777; $lac &= 010000; $code[000017] = *emul8; goto &fetch; }
$core[003065] = 03020; $code[003065] = *I03065; sub I03065 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[003066] = 04545; $code[003066] = *I03066; sub I03066 { $core[($ib<<12)+$core[101]] = 03067; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003067] = 04551; $code[003067] = *I03067; sub I03067 { $core[($ib<<12)+$core[105]] = 03070; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[003070] = 04545; $code[003070] = *I03070; sub I03070 { $core[($ib<<12)+$core[101]] = 03071; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003071] = 04551; $code[003071] = *I03071; sub I03071 { $core[($ib<<12)+$core[105]] = 03072; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[003072] = 04545; $code[003072] = *I03072; sub I03072 { $core[($ib<<12)+$core[101]] = 03073; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003073] = 04551; $code[003073] = *I03073; sub I03073 { $core[($ib<<12)+$core[105]] = 03074; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[003074] = 02030; $code[003074] = *I03074; sub I03074 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[003075] = 01430; $code[003075] = *I03075; sub I03075 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[003076] = 04714; $code[003076] = *I03076; sub I03076 { $core[($ib<<12)+$core[1612]] = 03077; $pc = ($ib<<12)+$core[1612]+1; $code[($ib<<12)+$core[1612]] = *emul8; $inh = 0; goto &fetch; }
$core[003077] = 04545; $code[003077] = *I03077; sub I03077 { $core[($ib<<12)+$core[101]] = 03100; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[003100] = 04551; $code[003100] = *I03100; sub I03100 { $core[($ib<<12)+$core[105]] = 03101; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[003101] = 02030; $code[003101] = *I03101; sub I03101 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[003102] = 04407; $code[003102] = *I03102; sub I03102 { $core[($ib<<12)+$core[7]] = 03103; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[003103] = 00430; $code[003103] = *I03103; sub I03103 { &emul8; goto &fetch; }
$core[003104] = 00000; $code[003104] = *I03104; sub I03104 { &emul8; goto &fetch; }
$core[003105] = 04530; $code[003105] = *I03105; sub I03105 { $core[($ib<<12)+$core[88]] = 03106; $pc = ($ib<<12)+$core[88]+1; $code[($ib<<12)+$core[88]] = *emul8; $inh = 0; goto &fetch; }
$core[003106] = 01077; $code[003106] = *I03106; sub I03106 { $lac += $core[000077]; goto &fetch; }
$core[003107] = 04551; $code[003107] = *I03107; sub I03107 { $core[($ib<<12)+$core[105]] = 03110; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[003110] = 01070; $code[003110] = *I03110; sub I03110 { $lac += $core[000070]; goto &fetch; }
$core[003111] = 01111; $code[003111] = *I03111; sub I03111 { $lac += $core[000111]; goto &fetch; }
$core[003112] = 01030; $code[003112] = *I03112; sub I03112 { $lac += $core[000030]; goto &fetch; }
$core[003113] = 05253; $code[003113] = *I03113; sub I03113 { $pc = 003053; $inh = 0; goto &fetch; }
$core[003114] = 02442; $code[003114] = *P03114; sub P03114 { if (++$core[($df<<12)+$core[34]] == 010000) { $core[($df<<12)+$core[34]] = 0; $pc++; }$code[($df<<12)+$core[34]] = *emul8; goto &fetch; }
$core[003115] = 03115; $code[003115] = *D03115; sub D03115 { $core[000115] = $lac & 07777; $lac &= 010000; $code[000115] = *emul8; goto &fetch; }
$core[003116] = 00000; $code[003116] = *D03116; sub D03116 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003117] = 05051; $code[003117] = *D03117; sub D03117 { $pc = 000051; $inh = 0; goto &fetch; }
$core[003120] = 00000; $code[003120] = *D03120; sub D03120 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003206] = 03217; $code[003206] = *D03206; sub D03206 { $core[003217] = $lac & 07777; $lac &= 010000; $code[003217] = *emul8; goto &fetch; }
$core[003207] = 00000; $code[003207] = *P03207; sub P03207 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003210] = 00355; $code[003210] = *I03210; sub I03210 { $lac &= (010000|$core[003355]); goto &fetch; }
$core[003211] = 00617; $code[003211] = *I03211; sub I03211 { $lac &= (010000|$core[($df<<12)+$core[1679]]); goto &fetch; }
$core[003212] = 00301; $code[003212] = *D03212; sub D03212 { $lac &= (010000|$core[003301]); goto &fetch; }
$core[003213] = 01454; $code[003213] = *I03213; sub I03213 { $lac += $core[($df<<12)+$core[44]]; goto &fetch; }
$core[003214] = 06171; $code[003214] = *I03214; sub I03214 { &emul8; goto &fetch; }
$core[003215] = 06671; $code[003215] = *D03215; sub D03215 { &emul8; goto &fetch; }
$core[003216] = 07715; $code[003216] = *I03216; sub I03216 { &emul8; goto &fetch; }
$core[003217] = 03235; $code[003217] = *P03217; sub P03217 { $core[003235] = $lac & 07777; $lac &= 010000; $code[003235] = *emul8; goto &fetch; }
$core[003220] = 00212; $code[003220] = *I03220; sub I03220 { $lac &= (010000|$core[003212]); goto &fetch; }
$core[003221] = 02440; $code[003221] = *I03221; sub I03221 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003222] = 04142; $code[003222] = *I03222; sub I03222 { $core[000142] = 03223; $pc = 000142+1; $code[000142] = *emul8; $inh = 0; goto &fetch; }
$core[003223] = 00317; $code[003223] = *I03223; sub I03223 { $lac &= (010000|$core[003317]); goto &fetch; }
$core[003224] = 01607; $code[003224] = *D03224; sub D03224 { $lac += $core[($df<<12)+$core[1671]]; goto &fetch; }
$core[003225] = 02201; $code[003225] = *I03225; sub I03225 { if (++$core[003201] == 010000) { $core[003201] = 0; $pc++; }$code[003201] = *emul8; goto &fetch; }
$core[003226] = 02425; $code[003226] = *I03226; sub I03226 { if (++$core[($df<<12)+$core[21]] == 010000) { $core[($df<<12)+$core[21]] = 0; $pc++; }$code[($df<<12)+$core[21]] = *emul8; goto &fetch; }
$core[003227] = 01401; $code[003227] = *I03227; sub I03227 { $lac += $core[($df<<12)+$core[1]]; goto &fetch; }
$core[003230] = 02411; $code[003230] = *I03230; sub I03230 { $core[000011] = 0000 if ++$core[000011] == 010000; if (++$core[($df<<12)+$core[000011]] == 010000) { $core[($df<<12)+$core[000011]] = 0; $pc++; }$code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[003231] = 01716; $code[003231] = *D03231; sub D03231 { $lac += $core[($df<<12)+$core[1742]]; goto &fetch; }
$core[003232] = 02341; $code[003232] = *D03232; sub D03232 { if (++$core[003341] == 010000) { $core[003341] = 0; $pc++; }$code[003341] = *emul8; goto &fetch; }
$core[003233] = 04142; $code[003233] = *D03233; sub D03233 { $core[000142] = 03234; $pc = 000142+1; $code[000142] = *emul8; $inh = 0; goto &fetch; }
$core[003234] = 07715; $code[003234] = *I03234; sub I03234 { &emul8; goto &fetch; }
$core[003235] = 03272; $code[003235] = *D03235; sub D03235 { $core[003272] = $lac & 07777; $lac &= 010000; $code[003272] = *emul8; goto &fetch; }
$core[003236] = 00224; $code[003236] = *D03236; sub D03236 { $lac &= (010000|$core[003224]); goto &fetch; }
$core[003237] = 02440; $code[003237] = *I03237; sub I03237 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003240] = 04041; $code[003240] = *P03240; sub P03240 { $core[000041] = 03241; $pc = 000041+1; $code[000041] = *emul8; $inh = 0; goto &fetch; }
$core[003241] = 04231; $code[003241] = *I03241; sub I03241 { $core[003231] = 03242; $pc = 003231+1; $code[003231] = *emul8; $inh = 0; goto &fetch; }
$core[003242] = 01725; $code[003242] = *P03242; sub P03242 { $lac += $core[($df<<12)+$core[1749]]; goto &fetch; }
$core[003243] = 04010; $code[003243] = *I03243; sub I03243 { $core[000010] = 03244; $pc = 000010+1; $code[000010] = *emul8; $inh = 0; goto &fetch; }
$core[003244] = 00126; $code[003244] = *I03244; sub I03244 { $lac &= (010000|$core[000126]); goto &fetch; }
$core[003245] = 00540; $code[003245] = *I03245; sub I03245 { $lac &= (010000|$core[($df<<12)+$core[96]]); goto &fetch; }
$core[003246] = 02325; $code[003246] = *I03246; sub I03246 { if (++$core[003325] == 010000) { $core[003325] = 0; $pc++; }$code[003325] = *emul8; goto &fetch; }
$core[003247] = 00303; $code[003247] = *I03247; sub I03247 { $lac &= (010000|$core[003303]); goto &fetch; }
$core[003250] = 00523; $code[003250] = *I03250; sub I03250 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[003251] = 02306; $code[003251] = *I03251; sub I03251 { if (++$core[003306] == 010000) { $core[003306] = 0; $pc++; }$code[003306] = *emul8; goto &fetch; }
$core[003252] = 02514; $code[003252] = *I03252; sub I03252 { if (++$core[($df<<12)+$core[76]] == 010000) { $core[($df<<12)+$core[76]] = 0; $pc++; }$code[($df<<12)+$core[76]] = *emul8; goto &fetch; }
$core[003253] = 01431; $code[003253] = *I03253; sub I03253 { $lac += $core[($df<<12)+$core[25]]; goto &fetch; }
$core[003254] = 04014; $code[003254] = *I03254; sub I03254 { $core[000014] = 03255; $pc = 000014+1; $code[000014] = *emul8; $inh = 0; goto &fetch; }
$core[003255] = 01701; $code[003255] = *I03255; sub I03255 { $lac += $core[($df<<12)+$core[1729]]; goto &fetch; }
$core[003256] = 00405; $code[003256] = *I03256; sub I03256 { $lac &= (010000|$core[($df<<12)+$core[5]]); goto &fetch; }
$core[003257] = 00440; $code[003257] = *I03257; sub I03257 { $lac &= (010000|$core[($df<<12)+$core[32]]); goto &fetch; }
$core[003260] = 04706; $code[003260] = *I03260; sub I03260 { $core[($ib<<12)+$core[1734]] = 03261; $pc = ($ib<<12)+$core[1734]+1; $code[($ib<<12)+$core[1734]] = *emul8; $inh = 0; goto &fetch; }
$core[003261] = 01703; $code[003261] = *I03261; sub I03261 { $lac += $core[($df<<12)+$core[1731]]; goto &fetch; }
$core[003262] = 00114; $code[003262] = *P03262; sub P03262 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[003263] = 05461; $code[003263] = *P03263; sub P03263 { $pc = ($ib<<12)+$core[49]; $inh = 0; goto &fetch; }
$core[003264] = 07166; $code[003264] = *P03264; sub P03264 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003265] = 07147; $code[003265] = *I03265; sub I03265 { $lac &= 07777; $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003266] = 04017; $code[003266] = *I03266; sub I03266 { $core[000017] = 03267; $pc = 000017+1; $code[000017] = *emul8; $inh = 0; goto &fetch; }
$core[003267] = 01640; $code[003267] = *I03267; sub I03267 { $lac += $core[($df<<12)+$core[1696]]; goto &fetch; }
$core[003270] = 00140; $code[003270] = *I03270; sub I03270 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[003271] = 07715; $code[003271] = *P03271; sub P03271 { &emul8; goto &fetch; }
$core[003272] = 03330; $code[003272] = *D03272; sub D03272 { $core[003330] = $lac & 07777; $lac &= 010000; $code[003330] = *emul8; goto &fetch; }
$core[003273] = 00231; $code[003273] = *I03273; sub I03273 { $lac &= (010000|$core[003231]); goto &fetch; }
$core[003274] = 02305; $code[003274] = *I03274; sub I03274 { if (++$core[003305] == 010000) { $core[003305] = 0; $pc++; }$code[003305] = *emul8; goto &fetch; }
$core[003275] = 02440; $code[003275] = *I03275; sub I03275 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003276] = 02004; $code[003276] = *I03276; sub I03276 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[003277] = 02075; $code[003277] = *I03277; sub I03277 { if (++$core[000075] == 010000) { $core[000075] = 0; $pc++; }$code[000075] = *emul8; goto &fetch; }
$core[003300] = 02004; $code[003300] = *I03300; sub I03300 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[003301] = 02052; $code[003301] = *P03301; sub P03301 { if (++$core[000052] == 010000) { $core[000052] = 0; $pc++; }$code[000052] = *emul8; goto &fetch; }
$core[003302] = 06236; $code[003302] = *I03302; sub I03302 { &emul8; goto &fetch; }
$core[003303] = 06161; $code[003303] = *P03303; sub P03303 { &emul8; goto &fetch; }
$core[003304] = 07304; $code[003304] = *I03304; sub I03304 { $lac &= 010000; $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003305] = 04061; $code[003305] = *D03305; sub D03305 { $core[000061] = 03306; $pc = 000061+1; $code[000061] = *emul8; $inh = 0; goto &fetch; }
$core[003306] = 05662; $code[003306] = *P03306; sub P03306 { $pc = ($ib<<12)+$core[1714]; $inh = 0; goto &fetch; }
$core[003307] = 06673; $code[003307] = *I03307; sub I03307 { &emul8; goto &fetch; }
$core[003310] = 00417; $code[003310] = *I03310; sub I03310 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[003311] = 04061; $code[003311] = *I03311; sub I03311 { $core[000061] = 03312; $pc = 000061+1; $code[000061] = *emul8; $inh = 0; goto &fetch; }
$core[003312] = 05671; $code[003312] = *I03312; sub I03312 { $pc = ($ib<<12)+$core[1721]; $inh = 0; goto &fetch; }
$core[003313] = 07304; $code[003313] = *I03313; sub I03313 { $lac &= 010000; $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003314] = 01740; $code[003314] = *I03314; sub I03314 { $lac += $core[($df<<12)+$core[1760]]; goto &fetch; }
$core[003315] = 06273; $code[003315] = *I03315; sub I03315 { &emul8; goto &fetch; }
$core[003316] = 04024; $code[003316] = *P03316; sub P03316 { $core[000024] = 03317; $pc = 000024+1; $code[000024] = *emul8; $inh = 0; goto &fetch; }
$core[003317] = 04041; $code[003317] = *D03317; sub D03317 { $core[000041] = 03320; $pc = 000041+1; $code[000041] = *emul8; $inh = 0; goto &fetch; }
$core[003320] = 04220; $code[003320] = *I03320; sub I03320 { $core[003220] = 03321; $pc = 003220+1; $code[003220] = *emul8; $inh = 0; goto &fetch; }
$core[003321] = 02217; $code[003321] = *I03321; sub I03321 { if (++$core[003217] == 010000) { $core[003217] = 0; $pc++; }$code[003217] = *emul8; goto &fetch; }
$core[003322] = 00305; $code[003322] = *I03322; sub I03322 { $lac &= (010000|$core[003305]); goto &fetch; }
$core[003323] = 00504; $code[003323] = *I03323; sub I03323 { $lac &= (010000|$core[($df<<12)+$core[68]]); goto &fetch; }
$core[003324] = 05642; $code[003324] = *I03324; sub I03324 { $pc = ($ib<<12)+$core[1698]; $inh = 0; goto &fetch; }
$core[003325] = 04141; $code[003325] = *P03325; sub P03325 { $core[000141] = 03326; $pc = 000141+1; $code[000141] = *emul8; $inh = 0; goto &fetch; }
$core[003326] = 07322; $code[003326] = *I03326; sub I03326 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[003327] = 07715; $code[003327] = *I03327; sub I03327 { &emul8; goto &fetch; }
$core[003330] = 03354; $code[003330] = *D03330; sub D03330 { $core[003354] = $lac & 07777; $lac &= 010000; $code[003354] = *emul8; goto &fetch; }
$core[003331] = 00232; $code[003331] = *I03331; sub I03331 { $lac &= (010000|$core[003232]); goto &fetch; }
$core[003332] = 01106; $code[003332] = *I03332; sub I03332 { $lac += $core[000106]; goto &fetch; }
$core[003333] = 04050; $code[003333] = *I03333; sub I03333 { $core[000050] = 03334; $pc = 000050+1; $code[000050] = *emul8; $inh = 0; goto &fetch; }
$core[003334] = 02004; $code[003334] = *I03334; sub I03334 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[003335] = 02055; $code[003335] = *I03335; sub I03335 { if (++$core[000055] == 010000) { $core[000055] = 0; $pc++; }$code[000055] = *emul8; goto &fetch; }
$core[003336] = 06651; $code[003336] = *I03336; sub I03336 { &emul8; goto &fetch; }
$core[003337] = 04061; $code[003337] = *I03337; sub I03337 { $core[000061] = 03340; $pc = 000061+1; $code[000061] = *emul8; $inh = 0; goto &fetch; }
$core[003340] = 05663; $code[003340] = *P03340; sub P03340 { $pc = ($ib<<12)+$core[1715]; $inh = 0; goto &fetch; }
$core[003341] = 06054; $code[003341] = *D03341; sub D03341 { &emul8; goto &fetch; }
$core[003342] = 06156; $code[003342] = *I03342; sub I03342 { &emul8; goto &fetch; }
$core[003343] = 06267; $code[003343] = *I03343; sub I03343 { &emul8; goto &fetch; }
$core[003344] = 07324; $code[003344] = *I03344; sub I03344 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003345] = 04042; $code[003345] = *I03345; sub I03345 { $core[000042] = 03346; $pc = 000042+1; $code[000042] = *emul8; $inh = 0; goto &fetch; }
$core[003346] = 02004; $code[003346] = *I03346; sub I03346 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[003347] = 02055; $code[003347] = *I03347; sub I03347 { if (++$core[000055] == 010000) { $core[000055] = 0; $pc++; }$code[000055] = *emul8; goto &fetch; }
$core[003350] = 07057; $code[003350] = *I03350; sub I03350 { $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003351] = 01442; $code[003351] = *I03351; sub I03351 { $lac += $core[($df<<12)+$core[34]]; goto &fetch; }
$core[003352] = 07322; $code[003352] = *I03352; sub I03352 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[003353] = 07715; $code[003353] = *I03353; sub I03353 { &emul8; goto &fetch; }
$core[003354] = 03365; $code[003354] = *D03354; sub D03354 { $core[003365] = $lac & 07777; $lac &= 010000; $code[003365] = *emul8; goto &fetch; }
$core[003355] = 00233; $code[003355] = *D03355; sub D03355 { $lac &= (010000|$core[003233]); goto &fetch; }
$core[003356] = 02440; $code[003356] = *I03356; sub I03356 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003357] = 04220; $code[003357] = *I03357; sub I03357 { $core[003220] = 03360; $pc = 003220+1; $code[003220] = *emul8; $inh = 0; goto &fetch; }
$core[003360] = 00420; $code[003360] = *I03360; sub I03360 { $lac &= (010000|$core[($df<<12)+$core[16]]); goto &fetch; }
$core[003361] = 05561; $code[003361] = *I03361; sub I03361 { $pc = ($ib<<12)+$core[113]; $inh = 0; goto &fetch; }
$core[003362] = 06242; $code[003362] = *I03362; sub I03362 { &emul8; goto &fetch; }
$core[003363] = 07322; $code[003363] = *I03363; sub I03363 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[003364] = 07715; $code[003364] = *I03364; sub I03364 { &emul8; goto &fetch; }
$core[003365] = 03403; $code[003365] = *D03365; sub D03365 { $core[($df<<12)+$core[3]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3]] = *emul8; goto &fetch; }
$core[003366] = 00236; $code[003366] = *I03366; sub I03366 { $lac &= (010000|$core[003236]); goto &fetch; }
$core[003367] = 01140; $code[003367] = *I03367; sub I03367 { $lac += $core[000140]; goto &fetch; }
$core[003370] = 05020; $code[003370] = *I03370; sub I03370 { $pc = 000020; $inh = 0; goto &fetch; }
$core[003371] = 00420; $code[003371] = *I03371; sub I03371 { $lac &= (010000|$core[($df<<12)+$core[16]]); goto &fetch; }
$core[003372] = 05565; $code[003372] = *I03372; sub I03372 { $pc = ($ib<<12)+$core[117]; $inh = 0; goto &fetch; }
$core[003373] = 05161; $code[003373] = *I03373; sub I03373 { $pc = 000161; $inh = 0; goto &fetch; }
$core[003374] = 05664; $code[003374] = *I03374; sub I03374 { $pc = ($ib<<12)+$core[1716]; $inh = 0; goto &fetch; }
$core[003375] = 07324; $code[003375] = *I03375; sub I03375 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003376] = 04042; $code[003376] = *I03376; sub I03376 { $core[000042] = 03377; $pc = 000042+1; $code[000042] = *emul8; $inh = 0; goto &fetch; }
$core[003377] = 01401; $code[003377] = *I03377; sub I03377 { $lac += $core[($df<<12)+$core[1]]; goto &fetch; }
$core[003400] = 00255; $code[003400] = *I03400; sub I03400 { $lac &= (010000|$core[003455]); goto &fetch; }
$core[003401] = 07042; $code[003401] = *P03401; sub P03401 { $lac ^= 07777; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[003402] = 07715; $code[003402] = *D03402; sub D03402 { &emul8; goto &fetch; }
$core[003403] = 03421; $code[003403] = *P03403; sub P03403 { $core[($df<<12)+$core[17]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[17]] = *emul8; goto &fetch; }
$core[003404] = 00250; $code[003404] = *I03404; sub I03404 { $lac &= (010000|$core[003450]); goto &fetch; }
$core[003405] = 01140; $code[003405] = *D03405; sub D03405 { $lac += $core[000140]; goto &fetch; }
$core[003406] = 05020; $code[003406] = *I03406; sub I03406 { $pc = 000020; $inh = 0; goto &fetch; }
$core[003407] = 00420; $code[003407] = *I03407; sub I03407 { $lac &= (010000|$core[($df<<12)+$core[16]]); goto &fetch; }
$core[003410] = 05564; $code[003410] = *I03410; sub I03410 { $pc = ($ib<<12)+$core[116]; $inh = 0; goto &fetch; }
$core[003411] = 05161; $code[003411] = *I03411; sub I03411 { $pc = 000161; $inh = 0; goto &fetch; }
$core[003412] = 05665; $code[003412] = *I03412; sub I03412 { $pc = ($ib<<12)+$core[1845]; $inh = 0; goto &fetch; }
$core[003413] = 07324; $code[003413] = *I03413; sub I03413 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003414] = 04042; $code[003414] = *I03414; sub I03414 { $core[000042] = 03415; $pc = 000042+1; $code[000042] = *emul8; $inh = 0; goto &fetch; }
$core[003415] = 01411; $code[003415] = *I03415; sub I03415 { $core[000011] = 0000 if ++$core[000011] == 010000; $lac += $core[($df<<12)+$core[000011]]; goto &fetch; }
$core[003416] = 01603; $code[003416] = *I03416; sub I03416 { $lac += $core[($df<<12)+$core[1795]]; goto &fetch; }
$core[003417] = 05570; $code[003417] = *I03417; sub I03417 { $pc = ($ib<<12)+$core[120]; $inh = 0; goto &fetch; }
$core[003420] = 07715; $code[003420] = *I03420; sub I03420 { &emul8; goto &fetch; }
$core[003421] = 03443; $code[003421] = *D03421; sub D03421 { $core[($df<<12)+$core[35]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[35]] = *emul8; goto &fetch; }
$core[003422] = 00262; $code[003422] = *I03422; sub I03422 { $lac &= (010000|$core[003462]); goto &fetch; }
$core[003423] = 02440; $code[003423] = *I03423; sub I03423 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003424] = 04220; $code[003424] = *I03424; sub I03424 { $core[003420] = 03425; $pc = 003420+1; $code[003420] = *emul8; $inh = 0; goto &fetch; }
$core[003425] = 00420; $code[003425] = *I03425; sub I03425 { $lac &= (010000|$core[($df<<12)+$core[16]]); goto &fetch; }
$core[003426] = 05542; $code[003426] = *I03426; sub I03426 { $pc = ($ib<<12)+$core[98]; $inh = 0; goto &fetch; }
$core[003427] = 07311; $code[003427] = *I03427; sub I03427 { $lac &= 010000; $lac &= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003430] = 00640; $code[003430] = *I03430; sub I03430 { $lac &= (010000|$core[($df<<12)+$core[1824]]); goto &fetch; }
$core[003431] = 05020; $code[003431] = *I03431; sub I03431 { $pc = 000020; $inh = 0; goto &fetch; }
$core[003432] = 00420; $code[003432] = *I03432; sub I03432 { $lac &= (010000|$core[($df<<12)+$core[16]]); goto &fetch; }
$core[003433] = 05563; $code[003433] = *I03433; sub I03433 { $pc = ($ib<<12)+$core[115]; $inh = 0; goto &fetch; }
$core[003434] = 05161; $code[003434] = *I03434; sub I03434 { $pc = 000161; $inh = 0; goto &fetch; }
$core[003435] = 05666; $code[003435] = *I03435; sub I03435 { $pc = ($ib<<12)+$core[1846]; $inh = 0; goto &fetch; }
$core[003436] = 07324; $code[003436] = *I03436; sub I03436 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003437] = 04042; $code[003437] = *I03437; sub I03437 { $core[000042] = 03440; $pc = 000042+1; $code[000042] = *emul8; $inh = 0; goto &fetch; }
$core[003440] = 07057; $code[003440] = *P03440; sub P03440 { $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003441] = 01142; $code[003441] = *I03441; sub I03441 { $lac += $core[000142]; goto &fetch; }
$core[003442] = 07715; $code[003442] = *P03442; sub P03442 { &emul8; goto &fetch; }
$core[003443] = 03457; $code[003443] = *I03443; sub I03443 { $core[($df<<12)+$core[47]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[47]] = *emul8; goto &fetch; }
$core[003444] = 00274; $code[003444] = *I03444; sub I03444 { $lac &= (010000|$core[003474]); goto &fetch; }
$core[003445] = 01106; $code[003445] = *I03445; sub I03445 { $lac += $core[000106]; goto &fetch; }
$core[003446] = 04050; $code[003446] = *I03446; sub I03446 { $core[000050] = 03447; $pc = 000050+1; $code[000050] = *emul8; $inh = 0; goto &fetch; }
$core[003447] = 02004; $code[003447] = *I03447; sub I03447 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[003450] = 02055; $code[003450] = *D03450; sub D03450 { if (++$core[000055] == 010000) { $core[000055] = 0; $pc++; }$code[000055] = *emul8; goto &fetch; }
$core[003451] = 06251; $code[003451] = *I03451; sub I03451 { &emul8; goto &fetch; }
$core[003452] = 06156; $code[003452] = *I03452; sub I03452 { &emul8; goto &fetch; }
$core[003453] = 06773; $code[003453] = *I03453; sub I03453 { &emul8; goto &fetch; }
$core[003454] = 02440; $code[003454] = *I03454; sub I03454 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003455] = 04270; $code[003455] = *D03455; sub D03455 { $core[003470] = 03456; $pc = 003470+1; $code[003470] = *emul8; $inh = 0; goto &fetch; }
$core[003456] = 07715; $code[003456] = *I03456; sub I03456 { &emul8; goto &fetch; }
$core[003457] = 03474; $code[003457] = *I03457; sub I03457 { $core[($df<<12)+$core[60]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[60]] = *emul8; goto &fetch; }
$core[003460] = 00306; $code[003460] = *I03460; sub I03460 { $lac &= (010000|$core[003506]); goto &fetch; }
$core[003461] = 01106; $code[003461] = *I03461; sub I03461 { $lac += $core[000106]; goto &fetch; }
$core[003462] = 04050; $code[003462] = *D03462; sub D03462 { $core[000050] = 03463; $pc = 000050+1; $code[000050] = *emul8; $inh = 0; goto &fetch; }
$core[003463] = 02004; $code[003463] = *I03463; sub I03463 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[003464] = 02055; $code[003464] = *P03464; sub P03464 { if (++$core[000055] == 010000) { $core[000055] = 0; $pc++; }$code[000055] = *emul8; goto &fetch; }
$core[003465] = 06151; $code[003465] = *P03465; sub P03465 { &emul8; goto &fetch; }
$core[003466] = 06156; $code[003466] = *P03466; sub P03466 { &emul8; goto &fetch; }
$core[003467] = 07073; $code[003467] = *I03467; sub I03467 { $lac ^= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003470] = 02440; $code[003470] = *I03470; sub I03470 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003471] = 04270; $code[003471] = *P03471; sub P03471 { $core[003470] = 03472; $pc = 003470+1; $code[003470] = *emul8; $inh = 0; goto &fetch; }
$core[003472] = 05723; $code[003472] = *I03472; sub I03472 { $pc = ($ib<<12)+$core[1875]; $inh = 0; goto &fetch; }
$core[003473] = 07715; $code[003473] = *I03473; sub I03473 { &emul8; goto &fetch; }
$core[003474] = 03507; $code[003474] = *D03474; sub D03474 { $core[($df<<12)+$core[71]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[71]] = *emul8; goto &fetch; }
$core[003475] = 00320; $code[003475] = *I03475; sub I03475 { $lac &= (010000|$core[003520]); goto &fetch; }
$core[003476] = 01106; $code[003476] = *I03476; sub I03476 { $lac += $core[000106]; goto &fetch; }
$core[003477] = 04050; $code[003477] = *I03477; sub I03477 { $core[000050] = 03500; $pc = 000050+1; $code[000050] = *emul8; $inh = 0; goto &fetch; }
$core[003500] = 02004; $code[003500] = *I03500; sub I03500 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[003501] = 02051; $code[003501] = *I03501; sub I03501 { if (++$core[000051] == 010000) { $core[000051] = 0; $pc++; }$code[000051] = *emul8; goto &fetch; }
$core[003502] = 06156; $code[003502] = *I03502; sub I03502 { &emul8; goto &fetch; }
$core[003503] = 07173; $code[003503] = *I03503; sub I03503 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003504] = 02440; $code[003504] = *I03504; sub I03504 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003505] = 04265; $code[003505] = *D03505; sub D03505 { $core[003465] = 03506; $pc = 003465+1; $code[003465] = *emul8; $inh = 0; goto &fetch; }
$core[003506] = 07715; $code[003506] = *D03506; sub D03506 { &emul8; goto &fetch; }
$core[003507] = 03522; $code[003507] = *P03507; sub P03507 { $core[($df<<12)+$core[82]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[82]] = *emul8; goto &fetch; }
$core[003510] = 00332; $code[003510] = *D03510; sub D03510 { $lac &= (010000|$core[003532]); goto &fetch; }
$core[003511] = 02440; $code[003511] = *I03511; sub I03511 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003512] = 04240; $code[003512] = *I03512; sub I03512 { $core[003440] = 03513; $pc = 003440+1; $code[003440] = *emul8; $inh = 0; goto &fetch; }
$core[003513] = 00317; $code[003513] = *I03513; sub I03513 { $lac &= (010000|$core[003517]); goto &fetch; }
$core[003514] = 01520; $code[003514] = *I03514; sub I03514 { $lac += $core[($df<<12)+$core[80]]; goto &fetch; }
$core[003515] = 02524; $code[003515] = *I03515; sub I03515 { if (++$core[($df<<12)+$core[84]] == 010000) { $core[($df<<12)+$core[84]] = 0; $pc++; }$code[($df<<12)+$core[84]] = *emul8; goto &fetch; }
$core[003516] = 00522; $code[003516] = *I03516; sub I03516 { $lac &= (010000|$core[($df<<12)+$core[82]]); goto &fetch; }
$core[003517] = 05642; $code[003517] = *D03517; sub D03517 { $pc = ($ib<<12)+$core[1826]; $inh = 0; goto &fetch; }
$core[003520] = 04141; $code[003520] = *D03520; sub D03520 { $core[000141] = 03521; $pc = 000141+1; $code[000141] = *emul8; $inh = 0; goto &fetch; }
$core[003521] = 07715; $code[003521] = *I03521; sub I03521 { &emul8; goto &fetch; }
$core[003522] = 03531; $code[003522] = *D03522; sub D03522 { $core[($df<<12)+$core[89]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[89]] = *emul8; goto &fetch; }
$core[003523] = 00417; $code[003523] = *P03523; sub P03523 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[003524] = 02305; $code[003524] = *I03524; sub I03524 { if (++$core[003505] == 010000) { $core[003505] = 0; $pc++; }$code[003505] = *emul8; goto &fetch; }
$core[003525] = 02440; $code[003525] = *I03525; sub I03525 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003526] = 03006; $code[003526] = *I03526; sub I03526 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[003527] = 07561; $code[003527] = *I03527; sub I03527 { &emul8; goto &fetch; }
$core[003530] = 07715; $code[003530] = *I03530; sub I03530 { &emul8; goto &fetch; }
$core[003531] = 03546; $code[003531] = *I03531; sub I03531 { $core[($df<<12)+$core[102]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[102]] = *emul8; goto &fetch; }
$core[003532] = 00424; $code[003532] = *D03532; sub D03532 { $lac &= (010000|$core[($df<<12)+$core[20]]); goto &fetch; }
$core[003533] = 02440; $code[003533] = *I03533; sub I03533 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003534] = 04142; $code[003534] = *I03534; sub I03534 { $core[000142] = 03535; $pc = 000142+1; $code[000142] = *emul8; $inh = 0; goto &fetch; }
$core[003535] = 02310; $code[003535] = *I03535; sub I03535 { if (++$core[003510] == 010000) { $core[003510] = 0; $pc++; }$code[003510] = *emul8; goto &fetch; }
$core[003536] = 00114; $code[003536] = *I03536; sub I03536 { $lac &= (010000|$core[000114]); goto &fetch; }
$core[003537] = 01440; $code[003537] = *I03537; sub I03537 { $lac += $core[($df<<12)+$core[32]]; goto &fetch; }
$core[003540] = 01140; $code[003540] = *I03540; sub I03540 { $lac += $core[000140]; goto &fetch; }
$core[003541] = 02205; $code[003541] = *I03541; sub I03541 { if (++$core[003405] == 010000) { $core[003405] = 0; $pc++; }$code[003405] = *emul8; goto &fetch; }
$core[003542] = 02401; $code[003542] = *I03542; sub I03542 { if (++$core[($df<<12)+$core[1]] == 010000) { $core[($df<<12)+$core[1]] = 0; $pc++; }$code[($df<<12)+$core[1]] = *emul8; goto &fetch; }
$core[003543] = 01116; $code[003543] = *I03543; sub I03543 { $lac += $core[000116]; goto &fetch; }
$core[003544] = 04042; $code[003544] = *I03544; sub I03544 { $core[000042] = 03545; $pc = 000042+1; $code[000042] = *emul8; $inh = 0; goto &fetch; }
$core[003545] = 07715; $code[003545] = *I03545; sub I03545 { &emul8; goto &fetch; }
$core[003546] = 03562; $code[003546] = *I03546; sub I03546 { $core[($df<<12)+$core[114]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[114]] = *emul8; goto &fetch; }
$core[003547] = 00431; $code[003547] = *I03547; sub I03547 { $lac &= (010000|$core[($df<<12)+$core[25]]); goto &fetch; }
$core[003550] = 02440; $code[003550] = *I03550; sub I03550 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003551] = 04214; $code[003551] = *I03551; sub I03551 { $core[003414] = 03552; $pc = 003414+1; $code[003414] = *emul8; $inh = 0; goto &fetch; }
$core[003552] = 01707; $code[003552] = *I03552; sub I03552 { $lac += $core[($df<<12)+$core[1863]]; goto &fetch; }
$core[003553] = 05440; $code[003553] = *I03553; sub I03553 { $pc = ($ib<<12)+$core[32]; $inh = 0; goto &fetch; }
$core[003554] = 00530; $code[003554] = *I03554; sub I03554 { $lac &= (010000|$core[($df<<12)+$core[88]]); goto &fetch; }
$core[003555] = 02054; $code[003555] = *I03555; sub I03555 { if (++$core[000054] == 010000) { $core[000054] = 0; $pc++; }$code[000054] = *emul8; goto &fetch; }
$core[003556] = 04001; $code[003556] = *I03556; sub I03556 { $core[000001] = 03557; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[003557] = 02416; $code[003557] = *I03557; sub I03557 { $core[000016] = 0000 if ++$core[000016] == 010000; if (++$core[($df<<12)+$core[000016]] == 010000) { $core[($df<<12)+$core[000016]] = 0; $pc++; }$code[($df<<12)+$core[000016]] = *emul8; goto &fetch; }
$core[003560] = 04037; $code[003560] = *I03560; sub I03560 { $core[000037] = 03561; $pc = 000037+1; $code[000037] = *emul8; $inh = 0; goto &fetch; }
$core[003561] = 07715; $code[003561] = *I03561; sub I03561 { &emul8; goto &fetch; }
$core[003562] = 03601; $code[003562] = *I03562; sub I03562 { $core[($df<<12)+$core[1793]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1793]] = *emul8; goto &fetch; }
$core[003563] = 00436; $code[003563] = *I03563; sub I03563 { $lac &= (010000|$core[($df<<12)+$core[30]]); goto &fetch; }
$core[003564] = 00417; $code[003564] = *I03564; sub I03564 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[003565] = 04061; $code[003565] = *I03565; sub I03565 { $core[000061] = 03566; $pc = 000061+1; $code[000061] = *emul8; $inh = 0; goto &fetch; }
$core[003566] = 06073; $code[003566] = *I03566; sub I03566 { &emul8; goto &fetch; }
$core[003567] = 01106; $code[003567] = *I03567; sub I03567 { $lac += $core[000106]; goto &fetch; }
$core[003570] = 04050; $code[003570] = *I03570; sub I03570 { $core[000050] = 03571; $pc = 000050+1; $code[000050] = *emul8; $inh = 0; goto &fetch; }
$core[003571] = 02205; $code[003571] = *I03571; sub I03571 { if (++$core[003405] == 010000) { $core[003405] = 0; $pc++; }$code[003405] = *emul8; goto &fetch; }
$core[003572] = 05162; $code[003572] = *I03572; sub I03572 { $pc = 000162; $inh = 0; goto &fetch; }
$core[003573] = 05671; $code[003573] = *I03573; sub I03573 { $pc = ($ib<<12)+$core[1849]; $inh = 0; goto &fetch; }
$core[003574] = 05462; $code[003574] = *I03574; sub I03574 { $pc = ($ib<<12)+$core[50]; $inh = 0; goto &fetch; }
$core[003575] = 05664; $code[003575] = *I03575; sub I03575 { $pc = ($ib<<12)+$core[1844]; $inh = 0; goto &fetch; }
$core[003576] = 05462; $code[003576] = *I03576; sub I03576 { $pc = ($ib<<12)+$core[50]; $inh = 0; goto &fetch; }
$core[003577] = 05664; $code[003577] = *I03577; sub I03577 { $pc = ($ib<<12)+$core[1844]; $inh = 0; goto &fetch; }
$core[003600] = 07715; $code[003600] = *I03600; sub I03600 { &emul8; goto &fetch; }
$core[003601] = 03632; $code[003601] = *I03601; sub I03601 { $core[($df<<12)+$core[1946]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1946]] = *emul8; goto &fetch; }
$core[003602] = 00450; $code[003602] = *I03602; sub I03602 { $lac &= (010000|$core[($df<<12)+$core[40]]); goto &fetch; }
$core[003603] = 00417; $code[003603] = *I03603; sub I03603 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[003604] = 04062; $code[003604] = *I03604; sub I03604 { $core[000062] = 03605; $pc = 000062+1; $code[000062] = *emul8; $inh = 0; goto &fetch; }
$core[003605] = 05662; $code[003605] = *P03605; sub P03605 { $pc = ($ib<<12)+$core[1970]; $inh = 0; goto &fetch; }
$core[003606] = 07324; $code[003606] = *I03606; sub I03606 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003607] = 04042; $code[003607] = *I03607; sub I03607 { $core[000042] = 03610; $pc = 000042+1; $code[000042] = *emul8; $inh = 0; goto &fetch; }
$core[003610] = 02311; $code[003610] = *I03610; sub I03610 { if (++$core[003711] == 010000) { $core[003711] = 0; $pc++; }$code[003711] = *emul8; goto &fetch; }
$core[003611] = 01605; $code[003611] = *I03611; sub I03611 { $lac += $core[($df<<12)+$core[1925]]; goto &fetch; }
$core[003612] = 05440; $code[003612] = *I03612; sub I03612 { $pc = ($ib<<12)+$core[32]; $inh = 0; goto &fetch; }
$core[003613] = 00317; $code[003613] = *I03613; sub I03613 { $lac &= (010000|$core[003717]); goto &fetch; }
$core[003614] = 02311; $code[003614] = *I03614; sub I03614 { if (++$core[003711] == 010000) { $core[003711] = 0; $pc++; }$code[003711] = *emul8; goto &fetch; }
$core[003615] = 01605; $code[003615] = *I03615; sub I03615 { $lac += $core[($df<<12)+$core[1925]]; goto &fetch; }
$core[003616] = 04037; $code[003616] = *I03616; sub I03616 { $core[000037] = 03617; $pc = 000037+1; $code[000037] = *emul8; $inh = 0; goto &fetch; }
$core[003617] = 04273; $code[003617] = *P03617; sub P03617 { $core[003673] = 03620; $pc = 003673+1; $code[003673] = *emul8; $inh = 0; goto &fetch; }
$core[003620] = 00417; $code[003620] = *I03620; sub I03620 { $core[000017] = 0000 if ++$core[000017] == 010000; $lac &= (010000|$core[($df<<12)+$core[000017]]); goto &fetch; }
$core[003621] = 04061; $code[003621] = *I03621; sub I03621 { $core[000061] = 03622; $pc = 000061+1; $code[000061] = *emul8; $inh = 0; goto &fetch; }
$core[003622] = 06073; $code[003622] = *I03622; sub I03622 { &emul8; goto &fetch; }
$core[003623] = 01106; $code[003623] = *P03623; sub P03623 { $lac += $core[000106]; goto &fetch; }
$core[003624] = 04050; $code[003624] = *I03624; sub I03624 { $core[000050] = 03625; $pc = 000050+1; $code[000050] = *emul8; $inh = 0; goto &fetch; }
$core[003625] = 02205; $code[003625] = *I03625; sub I03625 { if (++$core[003605] == 010000) { $core[003605] = 0; $pc++; }$code[003605] = *emul8; goto &fetch; }
$core[003626] = 05162; $code[003626] = *I03626; sub I03626 { $pc = 000162; $inh = 0; goto &fetch; }
$core[003627] = 05665; $code[003627] = *I03627; sub I03627 { $pc = ($ib<<12)+$core[1973]; $inh = 0; goto &fetch; }
$core[003630] = 07322; $code[003630] = *I03630; sub I03630 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[003631] = 07715; $code[003631] = *I03631; sub I03631 { &emul8; goto &fetch; }
$core[003632] = 03642; $code[003632] = *P03632; sub P03632 { $core[($df<<12)+$core[1954]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1954]] = *emul8; goto &fetch; }
$core[003633] = 00462; $code[003633] = *I03633; sub I03633 { $lac &= (010000|$core[($df<<12)+$core[50]]); goto &fetch; }
$core[003634] = 02340; $code[003634] = *I03634; sub I03634 { if (++$core[003740] == 010000) { $core[003740] = 0; $pc++; }$code[003740] = *emul8; goto &fetch; }
$core[003635] = 03006; $code[003635] = *I03635; sub I03635 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[003636] = 07555; $code[003636] = *I03636; sub I03636 { &emul8; goto &fetch; }
$core[003637] = 06173; $code[003637] = *I03637; sub I03637 { &emul8; goto &fetch; }
$core[003640] = 04022; $code[003640] = *D03640; sub D03640 { $core[000022] = 03641; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[003641] = 07715; $code[003641] = *I03641; sub I03641 { &emul8; goto &fetch; }
$core[003642] = 03650; $code[003642] = *P03642; sub P03642 { $core[($df<<12)+$core[1960]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1960]] = *emul8; goto &fetch; }
$core[003643] = 00532; $code[003643] = *I03643; sub I03643 { $lac &= (010000|$core[($df<<12)+$core[90]]); goto &fetch; }
$core[003644] = 02340; $code[003644] = *I03644; sub I03644 { if (++$core[003740] == 010000) { $core[003740] = 0; $pc++; }$code[003740] = *emul8; goto &fetch; }
$core[003645] = 03006; $code[003645] = *I03645; sub I03645 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[003646] = 07560; $code[003646] = *I03646; sub I03646 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003647] = 07715; $code[003647] = *I03647; sub I03647 { &emul8; goto &fetch; }
$core[003650] = 03673; $code[003650] = *P03650; sub P03650 { $core[($df<<12)+$core[1979]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1979]] = *emul8; goto &fetch; }
$core[003651] = 02450; $code[003651] = *I03651; sub I03651 { if (++$core[($df<<12)+$core[40]] == 010000) { $core[($df<<12)+$core[40]] = 0; $pc++; }$code[($df<<12)+$core[40]] = *emul8; goto &fetch; }
$core[003652] = 00140; $code[003652] = *I03652; sub I03652 { $lac &= (010000|$core[000140]); goto &fetch; }
$core[003653] = 02205; $code[003653] = *I03653; sub I03653 { if (++$core[003605] == 010000) { $core[003605] = 0; $pc++; }$code[003605] = *emul8; goto &fetch; }
$core[003654] = 07311; $code[003654] = *I03654; sub I03654 { $lac &= 010000; $lac &= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003655] = 04050; $code[003655] = *I03655; sub I03655 { $core[000050] = 03656; $pc = 000050+1; $code[000050] = *emul8; $inh = 0; goto &fetch; }
$core[003656] = 02205; $code[003656] = *I03656; sub I03656 { if (++$core[003605] == 010000) { $core[003605] = 0; $pc++; }$code[003605] = *emul8; goto &fetch; }
$core[003657] = 05560; $code[003657] = *I03657; sub I03657 { $pc = ($ib<<12)+$core[112]; $inh = 0; goto &fetch; }
$core[003660] = 03105; $code[003660] = *I03660; sub I03660 { $core[000105] = $lac & 07777; $lac &= 010000; $code[000105] = *emul8; goto &fetch; }
$core[003661] = 02351; $code[003661] = *I03661; sub I03661 { if (++$core[003751] == 010000) { $core[003751] = 0; $pc++; }$code[003751] = *emul8; goto &fetch; }
$core[003662] = 04061; $code[003662] = *P03662; sub P03662 { $core[000061] = 03663; $pc = 000061+1; $code[000061] = *emul8; $inh = 0; goto &fetch; }
$core[003663] = 06056; $code[003663] = *I03663; sub I03663 { &emul8; goto &fetch; }
$core[003664] = 06554; $code[003664] = *P03664; sub P03664 { &emul8; goto &fetch; }
$core[003665] = 06160; $code[003665] = *P03665; sub P03665 { &emul8; goto &fetch; }
$core[003666] = 05664; $code[003666] = *I03666; sub I03666 { $pc = ($ib<<12)+$core[1972]; $inh = 0; goto &fetch; }
$core[003667] = 06554; $code[003667] = *I03667; sub I03667 { &emul8; goto &fetch; }
$core[003670] = 06160; $code[003670] = *P03670; sub P03670 { &emul8; goto &fetch; }
$core[003671] = 05665; $code[003671] = *I03671; sub I03671 { $pc = ($ib<<12)+$core[1973]; $inh = 0; goto &fetch; }
$core[003672] = 07715; $code[003672] = *I03672; sub I03672 { &emul8; goto &fetch; }
$core[003673] = 03704; $code[003673] = *P03673; sub P03673 { $core[($df<<12)+$core[1988]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[1988]] = *emul8; goto &fetch; }
$core[003674] = 02455; $code[003674] = *I03674; sub I03674 { if (++$core[($df<<12)+$core[45]] == 010000) { $core[($df<<12)+$core[45]] = 0; $pc++; }$code[($df<<12)+$core[45]] = *emul8; goto &fetch; }
$core[003675] = 04023; $code[003675] = *I03675; sub I03675 { $core[000023] = 03676; $pc = 000023+1; $code[000023] = *emul8; $inh = 0; goto &fetch; }
$core[003676] = 00524; $code[003676] = *I03676; sub I03676 { $lac &= (010000|$core[($df<<12)+$core[84]]); goto &fetch; }
$core[003677] = 04022; $code[003677] = *I03677; sub I03677 { $core[000022] = 03700; $pc = 000022+1; $code[000022] = *emul8; $inh = 0; goto &fetch; }
$core[003700] = 00575; $code[003700] = *I03700; sub I03700 { $lac &= (010000|$core[($df<<12)+$core[125]]); goto &fetch; }
$core[003701] = 05561; $code[003701] = *I03701; sub I03701 { $pc = ($ib<<12)+$core[113]; $inh = 0; goto &fetch; }
$core[003702] = 07322; $code[003702] = *I03702; sub I03702 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[003703] = 07715; $code[003703] = *I03703; sub I03703 { &emul8; goto &fetch; }
$core[003704] = 03721; $code[003704] = *P03704; sub P03704 { $core[($df<<12)+$core[2001]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2001]] = *emul8; goto &fetch; }
$core[003705] = 02462; $code[003705] = *P03705; sub P03705 { if (++$core[($df<<12)+$core[50]] == 010000) { $core[($df<<12)+$core[50]] = 0; $pc++; }$code[($df<<12)+$core[50]] = *emul8; goto &fetch; }
$core[003706] = 01106; $code[003706] = *I03706; sub I03706 { $lac += $core[000106]; goto &fetch; }
$core[003707] = 04050; $code[003707] = *I03707; sub I03707 { $core[000050] = 03710; $pc = 000050+1; $code[000050] = *emul8; $inh = 0; goto &fetch; }
$core[003710] = 02205; $code[003710] = *I03710; sub I03710 { if (++$core[003605] == 010000) { $core[003605] = 0; $pc++; }$code[003605] = *emul8; goto &fetch; }
$core[003711] = 05560; $code[003711] = *D03711; sub D03711 { $pc = ($ib<<12)+$core[112]; $inh = 0; goto &fetch; }
$core[003712] = 01617; $code[003712] = *I03712; sub I03712 { $lac += $core[($df<<12)+$core[1935]]; goto &fetch; }
$core[003713] = 05161; $code[003713] = *I03713; sub I03713 { $pc = 000161; $inh = 0; goto &fetch; }
$core[003714] = 06056; $code[003714] = *I03714; sub I03714 { &emul8; goto &fetch; }
$core[003715] = 06654; $code[003715] = *I03715; sub I03715 { &emul8; goto &fetch; }
$core[003716] = 06160; $code[003716] = *I03716; sub I03716 { &emul8; goto &fetch; }
$core[003717] = 05670; $code[003717] = *D03717; sub D03717 { $pc = ($ib<<12)+$core[1976]; $inh = 0; goto &fetch; }
$core[003720] = 07715; $code[003720] = *I03720; sub I03720 { &emul8; goto &fetch; }
$core[003721] = 03750; $code[003721] = *P03721; sub P03721 { $core[($df<<12)+$core[2024]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2024]] = *emul8; goto &fetch; }
$core[003722] = 02474; $code[003722] = *P03722; sub P03722 { if (++$core[($df<<12)+$core[60]] == 010000) { $core[($df<<12)+$core[60]] = 0; $pc++; }$code[($df<<12)+$core[60]] = *emul8; goto &fetch; }
$core[003723] = 02440; $code[003723] = *I03723; sub I03723 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003724] = 04142; $code[003724] = *I03724; sub I03724 { $core[000142] = 03725; $pc = 000142+1; $code[000142] = *emul8; $inh = 0; goto &fetch; }
$core[003725] = 02014; $code[003725] = *I03725; sub I03725 { if (++$core[000014] == 010000) { $core[000014] = 0; $pc++; }$code[000014] = *emul8; goto &fetch; }
$core[003726] = 00501; $code[003726] = *I03726; sub I03726 { $lac &= (010000|$core[($df<<12)+$core[65]]); goto &fetch; }
$core[003727] = 02305; $code[003727] = *I03727; sub I03727 { if (++$core[003705] == 010000) { $core[003705] = 0; $pc++; }$code[003705] = *emul8; goto &fetch; }
$core[003730] = 04001; $code[003730] = *I03730; sub I03730 { $core[000001] = 03731; $pc = 000001+1; $code[000001] = *emul8; $inh = 0; goto &fetch; }
$core[003731] = 01623; $code[003731] = *P03731; sub P03731 { $lac += $core[($df<<12)+$core[1939]]; goto &fetch; }
$core[003732] = 02705; $code[003732] = *I03732; sub I03732 { if (++$core[($df<<12)+$core[1989]] == 010000) { $core[($df<<12)+$core[1989]] = 0; $pc++; }$code[($df<<12)+$core[1989]] = *emul8; goto &fetch; }
$core[003733] = 02240; $code[003733] = *I03733; sub I03733 { if (++$core[003640] == 010000) { $core[003640] = 0; $pc++; }$code[003640] = *emul8; goto &fetch; }
$core[003734] = 04731; $code[003734] = *I03734; sub I03734 { $core[($ib<<12)+$core[2009]] = 03735; $pc = ($ib<<12)+$core[2009]+1; $code[($ib<<12)+$core[2009]] = *emul8; $inh = 0; goto &fetch; }
$core[003735] = 00523; $code[003735] = *I03735; sub I03735 { $lac &= (010000|$core[($df<<12)+$core[83]]); goto &fetch; }
$core[003736] = 04740; $code[003736] = *I03736; sub I03736 { $core[($ib<<12)+$core[2016]] = 03737; $pc = ($ib<<12)+$core[2016]+1; $code[($ib<<12)+$core[2016]] = *emul8; $inh = 0; goto &fetch; }
$core[003737] = 01722; $code[003737] = *I03737; sub I03737 { $lac += $core[($df<<12)+$core[2002]]; goto &fetch; }
$core[003740] = 04047; $code[003740] = *P03740; sub P03740 { $core[000047] = 03741; $pc = 000047+1; $code[000047] = *emul8; $inh = 0; goto &fetch; }
$core[003741] = 01617; $code[003741] = *I03741; sub I03741 { $lac += $core[($df<<12)+$core[1935]]; goto &fetch; }
$core[003742] = 04740; $code[003742] = *I03742; sub I03742 { $core[($ib<<12)+$core[2016]] = 03743; $pc = ($ib<<12)+$core[2016]+1; $code[($ib<<12)+$core[2016]] = *emul8; $inh = 0; goto &fetch; }
$core[003743] = 04273; $code[003743] = *I03743; sub I03743 { $core[003673] = 03744; $pc = 003673+1; $code[003673] = *emul8; $inh = 0; goto &fetch; }
$core[003744] = 00740; $code[003744] = *I03744; sub I03744 { $lac &= (010000|$core[($df<<12)+$core[2016]]); goto &fetch; }
$core[003745] = 06160; $code[003745] = *I03745; sub I03745 { &emul8; goto &fetch; }
$core[003746] = 05664; $code[003746] = *I03746; sub I03746 { $pc = ($ib<<12)+$core[1972]; $inh = 0; goto &fetch; }
$core[003747] = 07715; $code[003747] = *I03747; sub I03747 { &emul8; goto &fetch; }
$core[003750] = 00000; $code[003750] = *P03750; sub P03750 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[003751] = 02520; $code[003751] = *D03751; sub D03751 { if (++$core[($df<<12)+$core[80]] == 010000) { $core[($df<<12)+$core[80]] = 0; $pc++; }$code[($df<<12)+$core[80]] = *emul8; goto &fetch; }
$core[003752] = 02305; $code[003752] = *I03752; sub I03752 { if (++$core[003705] == 010000) { $core[003705] = 0; $pc++; }$code[003705] = *emul8; goto &fetch; }
$core[003753] = 02440; $code[003753] = *I03753; sub I03753 { if (++$core[($df<<12)+$core[32]] == 010000) { $core[($df<<12)+$core[32]] = 0; $pc++; }$code[($df<<12)+$core[32]] = *emul8; goto &fetch; }
$core[003754] = 02205; $code[003754] = *I03754; sub I03754 { if (++$core[003605] == 010000) { $core[003605] = 0; $pc++; }$code[003605] = *emul8; goto &fetch; }
$core[003755] = 07561; $code[003755] = *I03755; sub I03755 { &emul8; goto &fetch; }
$core[003756] = 07322; $code[003756] = *I03756; sub I03756 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[003757] = 07715; $code[003757] = *I03757; sub I03757 { &emul8; goto &fetch; }
$core[004370] = 02741; $code[004370] = *D04370; sub D04370 { if (++$core[($df<<12)+$core[2273]] == 010000) { $core[($df<<12)+$core[2273]] = 0; $pc++; }$code[($df<<12)+$core[2273]] = *emul8; goto &fetch; }
$core[004371] = 01370; $code[004371] = *L04371; sub L04371 { $lac += $core[004370]; goto &fetch; }
$core[004372] = 03176; $code[004372] = *I04372; sub I04372 { $core[000176] = $lac & 07777; $lac &= 010000; $code[000176] = *emul8; goto &fetch; }
$core[004373] = 06142; $code[004373] = *I04373; sub I04373 { &emul8; goto &fetch; }
$core[004374] = 06077; $code[004374] = *I04374; sub I04374 { &emul8; goto &fetch; }
$core[004375] = 06152; $code[004375] = *I04375; sub I04375 { &emul8; goto &fetch; }
$core[004376] = 06762; $code[004376] = *I04376; sub I04376 { &emul8; goto &fetch; }
$core[004377] = 06012; $code[004377] = *I04377; sub I04377 { &emul8; goto &fetch; }
$core[004400] = 06346; $code[004400] = *I04400; sub I04400 { &emul8; goto &fetch; }
$core[004401] = 06772; $code[004401] = *I04401; sub I04401 { &emul8; goto &fetch; }
$core[004402] = 07300; $code[004402] = *I04402; sub I04402 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004403] = 03414; $code[004403] = *L04403; sub L04403 { $core[000014] = 0000 if ++$core[000014] == 010000; $core[($df<<12)+$core[000014]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000014]] = *emul8; goto &fetch; }
$core[004404] = 02057; $code[004404] = *I04404; sub I04404 { if (++$core[000057] == 010000) { $core[000057] = 0; $pc++; }$code[000057] = *emul8; goto &fetch; }
$core[004405] = 05203; $code[004405] = *I04405; sub I04405 { $pc = 004403; $inh = 0; goto &fetch; }
$core[004406] = 01362; $code[004406] = *I04406; sub I04406 { $lac += $core[004562]; goto &fetch; }
$core[004407] = 04371; $code[004407] = *D04407; sub D04407 { $core[004571] = 04410; $pc = 004571+1; $code[004571] = *emul8; $inh = 0; goto &fetch; }
$core[004410] = 01370; $code[004410] = *I04410; sub I04410 { $lac += $core[004570]; goto &fetch; }
$core[004411] = 03000; $code[004411] = *I04411; sub I04411 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[004412] = 07040; $code[004412] = *D04412; sub D04412 { $lac ^= 07777; goto &fetch; }
$core[004413] = 06167; $code[004413] = *I04413; sub I04413 { &emul8; goto &fetch; }
$core[004414] = 07200; $code[004414] = *D04414; sub D04414 { $lac &= 010000; goto &fetch; }
$core[004415] = 06171; $code[004415] = *I04415; sub I04415 { &emul8; goto &fetch; }
$core[004416] = 07650; $code[004416] = *I04416; sub I04416 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004417] = 05226; $code[004417] = *P04417; sub P04417 { $pc = 004426; $inh = 0; goto &fetch; }
$core[004420] = 01365; $code[004420] = *I04420; sub I04420 { $lac += $core[004565]; goto &fetch; }
$core[004421] = 06141; $code[004421] = *I04421; sub I04421 { &emul8; goto &fetch; }
$core[004422] = 01366; $code[004422] = *I04422; sub I04422 { $lac += $core[004566]; goto &fetch; }
$core[004423] = 06141; $code[004423] = *I04423; sub I04423 { &emul8; goto &fetch; }
$core[004424] = 07200; $code[004424] = *I04424; sub I04424 { $lac &= 010000; goto &fetch; }
$core[004425] = 05310; $code[004425] = *I04425; sub I04425 { $pc = 004510; $inh = 0; goto &fetch; }
$core[004426] = 06141; $code[004426] = *L04426; sub L04426 { &emul8; goto &fetch; }
$core[004427] = 00017; $code[004427] = *I04427; sub I04427 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[004430] = 00002; $code[004430] = *I04430; sub I04430 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[004431] = 07001; $code[004431] = *I04431; sub I04431 { $lac++; goto &fetch; }
$core[004432] = 07650; $code[004432] = *I04432; sub I04432 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004433] = 05306; $code[004433] = *I04433; sub I04433 { $pc = 004506; $inh = 0; goto &fetch; }
$core[004434] = 07101; $code[004434] = *I04434; sub I04434 { $lac &= 07777; $lac++; goto &fetch; }
$core[004435] = 06344; $code[004435] = *I04435; sub I04435 { &emul8; goto &fetch; }
$core[004436] = 06331; $code[004436] = *I04436; sub I04436 { &emul8; goto &fetch; }
$core[004437] = 07700; $code[004437] = *I04437; sub I04437 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004440] = 05246; $code[004440] = *I04440; sub I04440 { $pc = 004446; $inh = 0; goto &fetch; }
$core[004441] = 01350; $code[004441] = *I04441; sub I04441 { $lac += $core[004550]; goto &fetch; }
$core[004442] = 03752; $code[004442] = *I04442; sub I04442 { $core[($df<<12)+$core[2410]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2410]] = *emul8; goto &fetch; }
$core[004443] = 01351; $code[004443] = *I04443; sub I04443 { $lac += $core[004551]; goto &fetch; }
$core[004444] = 03753; $code[004444] = *I04444; sub I04444 { $core[($df<<12)+$core[2411]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2411]] = *emul8; goto &fetch; }
$core[004445] = 05307; $code[004445] = *I04445; sub I04445 { $pc = 004507; $inh = 0; goto &fetch; }
$core[004446] = 07354; $code[004446] = *L04446; sub L04446 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[004447] = 01367; $code[004447] = *I04447; sub I04447 { $lac += $core[004567]; goto &fetch; }
$core[004450] = 07650; $code[004450] = *I04450; sub I04450 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004451] = 05265; $code[004451] = *I04451; sub I04451 { $pc = 004465; $inh = 0; goto &fetch; }
$core[004452] = 07344; $code[004452] = *I04452; sub I04452 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[004453] = 01366; $code[004453] = *L04453; sub L04453 { $lac += $core[004566]; goto &fetch; }
$core[004454] = 07650; $code[004454] = *P04454; sub P04454 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004455] = 05312; $code[004455] = *I04455; sub I04455 { $pc = 004512; $inh = 0; goto &fetch; }
$core[004456] = 01100; $code[004456] = *I04456; sub I04456 { $lac += $core[000100]; goto &fetch; }
$core[004457] = 03764; $code[004457] = *I04457; sub I04457 { $core[($df<<12)+$core[2420]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2420]] = *emul8; goto &fetch; }
$core[004460] = 01212; $code[004460] = *I04460; sub I04460 { $lac += $core[004412]; goto &fetch; }
$core[004461] = 03763; $code[004461] = *P04461; sub P04461 { $core[($df<<12)+$core[2419]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2419]] = *emul8; goto &fetch; }
$core[004462] = 05313; $code[004462] = *I04462; sub I04462 { $pc = 004513; $inh = 0; goto &fetch; }
$core[004463] = 02761; $code[004463] = *I04463; sub I04463 { if (++$core[($df<<12)+$core[2417]] == 010000) { $core[($df<<12)+$core[2417]] = 0; $pc++; }$code[($df<<12)+$core[2417]] = *emul8; goto &fetch; }
$core[004464] = 05314; $code[004464] = *I04464; sub I04464 { $pc = 004514; $inh = 0; goto &fetch; }
$core[004465] = 06046; $code[004465] = *L04465; sub L04465 { &emul8; goto &fetch; }
$core[004466] = 06000; $code[004466] = *L04466; sub L04466 { &emul8; goto &fetch; }
$core[004467] = 06000; $code[004467] = *I04467; sub I04467 { &emul8; goto &fetch; }
$core[004470] = 06000; $code[004470] = *I04470; sub I04470 { &emul8; goto &fetch; }
$core[004471] = 06000; $code[004471] = *I04471; sub I04471 { &emul8; goto &fetch; }
$core[004472] = 06000; $code[004472] = *I04472; sub I04472 { &emul8; goto &fetch; }
$core[004473] = 06000; $code[004473] = *I04473; sub I04473 { &emul8; goto &fetch; }
$core[004474] = 06000; $code[004474] = *I04474; sub I04474 { &emul8; goto &fetch; }
$core[004475] = 06000; $code[004475] = *I04475; sub I04475 { &emul8; goto &fetch; }
$core[004476] = 02057; $code[004476] = *I04476; sub I04476 { if (++$core[000057] == 010000) { $core[000057] = 0; $pc++; }$code[000057] = *emul8; goto &fetch; }
$core[004477] = 06041; $code[004477] = *I04477; sub I04477 { &emul8; goto &fetch; }
$core[004500] = 05266; $code[004500] = *I04500; sub I04500 { $pc = 004466; $inh = 0; goto &fetch; }
$core[004501] = 01057; $code[004501] = *I04501; sub I04501 { $lac += $core[000057]; goto &fetch; }
$core[004502] = 01130; $code[004502] = *I04502; sub I04502 { $lac += $core[000130]; goto &fetch; }
$core[004503] = 07710; $code[004503] = *I04503; sub I04503 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004504] = 05311; $code[004504] = *I04504; sub I04504 { $pc = 004511; $inh = 0; goto &fetch; }
$core[004505] = 02430; $code[004505] = *I04505; sub I04505 { if (++$core[($df<<12)+$core[24]] == 010000) { $core[($df<<12)+$core[24]] = 0; $pc++; }$code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[004506] = 02430; $code[004506] = *L04506; sub L04506 { if (++$core[($df<<12)+$core[24]] == 010000) { $core[($df<<12)+$core[24]] = 0; $pc++; }$code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[004507] = 02430; $code[004507] = *L04507; sub L04507 { if (++$core[($df<<12)+$core[24]] == 010000) { $core[($df<<12)+$core[24]] = 0; $pc++; }$code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[004510] = 02430; $code[004510] = *L04510; sub L04510 { if (++$core[($df<<12)+$core[24]] == 010000) { $core[($df<<12)+$core[24]] = 0; $pc++; }$code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[004511] = 02430; $code[004511] = *L04511; sub L04511 { if (++$core[($df<<12)+$core[24]] == 010000) { $core[($df<<12)+$core[24]] = 0; $pc++; }$code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[004512] = 02430; $code[004512] = *L04512; sub L04512 { if (++$core[($df<<12)+$core[24]] == 010000) { $core[($df<<12)+$core[24]] = 0; $pc++; }$code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[004513] = 02430; $code[004513] = *L04513; sub L04513 { if (++$core[($df<<12)+$core[24]] == 010000) { $core[($df<<12)+$core[24]] = 0; $pc++; }$code[($df<<12)+$core[24]] = *emul8; goto &fetch; }
$core[004514] = 06046; $code[004514] = *L04514; sub L04514 { &emul8; goto &fetch; }
$core[004515] = 06001; $code[004515] = *I04515; sub I04515 { &emul8; goto &fetch; }
$core[004516] = 04540; $code[004516] = *I04516; sub I04516 { $core[($ib<<12)+$core[96]] = 04517; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[004517] = 00421; $code[004517] = *I04517; sub I04517 { $lac &= (010000|$core[($df<<12)+$core[17]]); goto &fetch; }
$core[004520] = 06002; $code[004520] = *I04520; sub I04520 { &emul8; goto &fetch; }
$core[004521] = 01360; $code[004521] = *I04521; sub I04521 { $lac += $core[004560]; goto &fetch; }
$core[004522] = 04371; $code[004522] = *I04522; sub I04522 { $core[004571] = 04523; $pc = 004571+1; $code[004571] = *emul8; $inh = 0; goto &fetch; }
$core[004523] = 07450; $code[004523] = *I04523; sub I04523 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004524] = 05344; $code[004524] = *I04524; sub I04524 { $pc = 004544; $inh = 0; goto &fetch; }
$core[004525] = 07710; $code[004525] = *P04525; sub P04525 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004526] = 01366; $code[004526] = *I04526; sub I04526 { $lac += $core[004566]; goto &fetch; }
$core[004527] = 01120; $code[004527] = *I04527; sub I04527 { $lac += $core[000120]; goto &fetch; }
$core[004530] = 03057; $code[004530] = *I04530; sub I04530 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[004531] = 01354; $code[004531] = *I04531; sub I04531 { $lac += $core[004554]; goto &fetch; }
$core[004532] = 03011; $code[004532] = *I04532; sub I04532 { $core[000011] = $lac & 07777; $lac &= 010000; $code[000011] = *emul8; goto &fetch; }
$core[004533] = 01355; $code[004533] = *L04533; sub L04533 { $lac += $core[004555]; goto &fetch; }
$core[004534] = 03411; $code[004534] = *I04534; sub I04534 { $core[000011] = 0000 if ++$core[000011] == 010000; $core[($df<<12)+$core[000011]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000011]] = *emul8; goto &fetch; }
$core[004535] = 02057; $code[004535] = *I04535; sub I04535 { if (++$core[000057] == 010000) { $core[000057] = 0; $pc++; }$code[000057] = *emul8; goto &fetch; }
$core[004536] = 05333; $code[004536] = *I04536; sub I04536 { $pc = 004533; $inh = 0; goto &fetch; }
$core[004537] = 01360; $code[004537] = *I04537; sub I04537 { $lac += $core[004560]; goto &fetch; }
$core[004540] = 04371; $code[004540] = *I04540; sub I04540 { $core[004571] = 04541; $pc = 004571+1; $code[004571] = *emul8; $inh = 0; goto &fetch; }
$core[004541] = 07710; $code[004541] = *I04541; sub I04541 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004542] = 01104; $code[004542] = *I04542; sub I04542 { $lac += $core[000104]; goto &fetch; }
$core[004543] = 01356; $code[004543] = *I04543; sub I04543 { $lac += $core[004556]; goto &fetch; }
$core[004544] = 01357; $code[004544] = *L04544; sub L04544 { $lac += $core[004557]; goto &fetch; }
$core[004545] = 03035; $code[004545] = *D04545; sub D04545 { $core[000035] = $lac & 07777; $lac &= 010000; $code[000035] = *emul8; goto &fetch; }
$core[004546] = 05747; $code[004546] = *D04546; sub D04546 { $pc = ($ib<<12)+$core[2407]; $inh = 0; goto &fetch; }
$core[004547] = 02214; $code[004547] = *P04547; sub P04547 { if (++$core[004414] == 010000) { $core[004414] = 0; $pc++; }$code[004414] = *emul8; goto &fetch; }
$core[004550] = 06313; $code[004550] = *D04550; sub D04550 { &emul8; goto &fetch; }
$core[004551] = 06307; $code[004551] = *L04551; sub L04551 { &emul8; goto &fetch; }
$core[004552] = 01153; $code[004552] = *P04552; sub P04552 { $lac += $core[000153]; goto &fetch; }
$core[004553] = 01156; $code[004553] = *P04553; sub P04553 { $lac += $core[000156]; goto &fetch; }
$core[004554] = 00401; $code[004554] = *D04554; sub D04554 { $lac &= (010000|$core[($df<<12)+$core[1]]); goto &fetch; }
$core[004555] = 02725; $code[004555] = *D04555; sub D04555 { if (++$core[($df<<12)+$core[2389]] == 010000) { $core[($df<<12)+$core[2389]] = 0; $pc++; }$code[($df<<12)+$core[2389]] = *emul8; goto &fetch; }
$core[004556] = 00560; $code[004556] = *D04556; sub D04556 { $lac &= (010000|$core[($df<<12)+$core[112]]); goto &fetch; }
$core[004557] = 04617; $code[004557] = *D04557; sub D04557 { $core[($ib<<12)+$core[2319]] = 04560; $pc = ($ib<<12)+$core[2319]+1; $code[($ib<<12)+$core[2319]] = *emul8; $inh = 0; goto &fetch; }
$core[004560] = 03006; $code[004560] = *D04560; sub D04560 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[004561] = 02661; $code[004561] = *P04561; sub P04561 { if (++$core[($df<<12)+$core[2353]] == 010000) { $core[($df<<12)+$core[2353]] = 0; $pc++; }$code[($df<<12)+$core[2353]] = *emul8; goto &fetch; }
$core[004562] = 02004; $code[004562] = *D04562; sub D04562 { if (++$core[000004] == 010000) { $core[000004] = 0; $pc++; }$code[000004] = *emul8; goto &fetch; }
$core[004563] = 06322; $code[004563] = *P04563; sub P04563 { &emul8; goto &fetch; }
$core[004564] = 02654; $code[004564] = *P04564; sub P04564 { if (++$core[($df<<12)+$core[2348]] == 010000) { $core[($df<<12)+$core[2348]] = 0; $pc++; }$code[($df<<12)+$core[2348]] = *emul8; goto &fetch; }
$core[004565] = 00007; $code[004565] = *D04565; sub D04565 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[004566] = 00002; $code[004566] = *D04566; sub D04566 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[004567] = 04002; $code[004567] = *D04567; sub D04567 { $core[000002] = 04570; $pc = 000002+1; $code[000002] = *emul8; $inh = 0; goto &fetch; }
$core[004570] = 04462; $code[004570] = *D04570; sub D04570 { $core[($ib<<12)+$core[50]] = 04571; $pc = ($ib<<12)+$core[50]+1; $code[($ib<<12)+$core[50]] = *emul8; $inh = 0; goto &fetch; }
$core[004571] = 02344; $code[004571] = *P04571; sub P04571 { if (++$core[004544] == 010000) { $core[004544] = 0; $pc++; }$code[004544] = *emul8; goto &fetch; }
$core[004572] = 03061; $code[004572] = *I04572; sub I04572 { $core[000061] = $lac & 07777; $lac &= 010000; $code[000061] = *emul8; goto &fetch; }
$core[004573] = 04540; $code[004573] = *I04573; sub I04573 { $core[($ib<<12)+$core[96]] = 04574; $pc = ($ib<<12)+$core[96]+1; $code[($ib<<12)+$core[96]] = *emul8; $inh = 0; goto &fetch; }
$core[004574] = 01437; $code[004574] = *I04574; sub I04574 { $lac += $core[($df<<12)+$core[31]]; goto &fetch; }
$core[004575] = 02030; $code[004575] = *I04575; sub I04575 { if (++$core[000030] == 010000) { $core[000030] = 0; $pc++; }$code[000030] = *emul8; goto &fetch; }
$core[004576] = 01430; $code[004576] = *I04576; sub I04576 { $lac += $core[($df<<12)+$core[24]]; goto &fetch; }
$core[004577] = 05771; $code[004577] = *I04577; sub I04577 { $pc = ($ib<<12)+$core[2425]; $inh = 0; goto &fetch; }
$core[004620] = 01045; $code[004620] = *I04620; sub I04620 { $lac += $core[000045]; goto &fetch; }
$core[004621] = 07710; $code[004621] = *I04621; sub I04621 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004622] = 04724; $code[004622] = *I04622; sub I04622 { $core[($ib<<12)+$core[2516]] = 04623; $pc = ($ib<<12)+$core[2516]+1; $code[($ib<<12)+$core[2516]] = *emul8; $inh = 0; goto &fetch; }
$core[004623] = 03033; $code[004623] = *I04623; sub I04623 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[004624] = 04407; $code[004624] = *I04624; sub I04624 { $core[($ib<<12)+$core[7]] = 04625; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[004625] = 04313; $code[004625] = *I04625; sub I04625 { &emul8; goto &fetch; }
$core[004626] = 06675; $code[004626] = *I04626; sub I04626 { &emul8; goto &fetch; }
$core[004627] = 00000; $code[004627] = *I04627; sub I04627 { &emul8; goto &fetch; }
$core[004630] = 04453; $code[004630] = *I04630; sub I04630 { $core[($ib<<12)+$core[43]] = 04631; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[004631] = 03325; $code[004631] = *I04631; sub I04631 { $core[004725] = $lac & 07777; $lac &= 010000; $code[004725] = *emul8; goto &fetch; }
$core[004632] = 04407; $code[004632] = *I04632; sub I04632 { $core[($ib<<12)+$core[7]] = 04633; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[004633] = 07000; $code[004633] = *I04633; sub I04633 { &emul8; goto &fetch; }
$core[004634] = 06676; $code[004634] = *I04634; sub I04634 { &emul8; goto &fetch; }
$core[004635] = 00675; $code[004635] = *I04635; sub I04635 { &emul8; goto &fetch; }
$core[004636] = 02676; $code[004636] = *I04636; sub I04636 { &emul8; goto &fetch; }
$core[004637] = 06675; $code[004637] = *D04637; sub D04637 { &emul8; goto &fetch; }
$core[004640] = 04675; $code[004640] = *I04640; sub I04640 { &emul8; goto &fetch; }
$core[004641] = 06676; $code[004641] = *I04641; sub I04641 { &emul8; goto &fetch; }
$core[004642] = 01310; $code[004642] = *I04642; sub I04642 { &emul8; goto &fetch; }
$core[004643] = 06326; $code[004643] = *P04643; sub P04643 { &emul8; goto &fetch; }
$core[004644] = 00305; $code[004644] = *I04644; sub I04644 { &emul8; goto &fetch; }
$core[004645] = 03326; $code[004645] = *I04645; sub I04645 { &emul8; goto &fetch; }
$core[004646] = 02675; $code[004646] = *P04646; sub P04646 { &emul8; goto &fetch; }
$core[004647] = 01277; $code[004647] = *I04647; sub I04647 { &emul8; goto &fetch; }
$core[004650] = 06326; $code[004650] = *I04650; sub I04650 { &emul8; goto &fetch; }
$core[004651] = 00302; $code[004651] = *I04651; sub I04651 { &emul8; goto &fetch; }
$core[004652] = 04676; $code[004652] = *I04652; sub I04652 { &emul8; goto &fetch; }
$core[004653] = 01326; $code[004653] = *I04653; sub I04653 { &emul8; goto &fetch; }
$core[004654] = 06326; $code[004654] = *I04654; sub I04654 { &emul8; goto &fetch; }
$core[004655] = 00675; $code[004655] = *I04655; sub I04655 { &emul8; goto &fetch; }
$core[004656] = 03326; $code[004656] = *I04656; sub I04656 { &emul8; goto &fetch; }
$core[004657] = 04321; $code[004657] = *I04657; sub I04657 { &emul8; goto &fetch; }
$core[004660] = 01316; $code[004660] = *I04660; sub I04660 { &emul8; goto &fetch; }
$core[004661] = 00000; $code[004661] = *I04661; sub I04661 { &emul8; goto &fetch; }
$core[004662] = 01325; $code[004662] = *I04662; sub I04662 { $lac += $core[004725]; goto &fetch; }
$core[004663] = 01044; $code[004663] = *I04663; sub I04663 { $lac += $core[000044]; goto &fetch; }
$core[004664] = 03044; $code[004664] = *I04664; sub I04664 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[004665] = 02033; $code[004665] = *I04665; sub I04665 { if (++$core[000033] == 010000) { $core[000033] = 0; $pc++; }$code[000033] = *emul8; goto &fetch; }
$core[004666] = 05536; $code[004666] = *I04666; sub I04666 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[004667] = 04407; $code[004667] = *I04667; sub I04667 { $core[($ib<<12)+$core[7]] = 04670; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[004670] = 06675; $code[004670] = *I04670; sub I04670 { &emul8; goto &fetch; }
$core[004671] = 00316; $code[004671] = *I04671; sub I04671 { &emul8; goto &fetch; }
$core[004672] = 03675; $code[004672] = *I04672; sub I04672 { &emul8; goto &fetch; }
$core[004673] = 00000; $code[004673] = *I04673; sub I04673 { &emul8; goto &fetch; }
$core[004674] = 05536; $code[004674] = *I04674; sub I04674 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[004675] = 05322; $code[004675] = *P04675; sub P04675 { $pc = 004722; $inh = 0; goto &fetch; }
$core[004676] = 05326; $code[004676] = *P04676; sub P04676 { $pc = 004726; $inh = 0; goto &fetch; }
$core[004677] = 00004; $code[004677] = *D04677; sub D04677 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[004700] = 02372; $code[004700] = *I04700; sub I04700 { if (++$core[004772] == 010000) { $core[004772] = 0; $pc++; }$code[004772] = *emul8; goto &fetch; }
$core[004701] = 01402; $code[004701] = *I04701; sub I04701 { $lac += $core[($df<<12)+$core[2]]; goto &fetch; }
$core[004702] = 07774; $code[004702] = *I04702; sub I04702 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004703] = 02157; $code[004703] = *I04703; sub I04703 { if (++$core[000157] == 010000) { $core[000157] = 0; $pc++; }$code[000157] = *emul8; goto &fetch; }
$core[004704] = 05157; $code[004704] = *D04704; sub D04704 { $pc = 000157; $inh = 0; goto &fetch; }
$core[004705] = 00012; $code[004705] = *P04705; sub P04705 { $lac &= (010000|$core[000012]); goto &fetch; }
$core[004706] = 05454; $code[004706] = *D04706; sub D04706 { $pc = ($ib<<12)+$core[44]; $inh = 0; goto &fetch; }
$core[004707] = 00343; $code[004707] = *I04707; sub I04707 { $lac &= (010000|$core[004743]); goto &fetch; }
$core[004710] = 00007; $code[004710] = *D04710; sub D04710 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[004711] = 02566; $code[004711] = *I04711; sub I04711 { if (++$core[($df<<12)+$core[118]] == 010000) { $core[($df<<12)+$core[118]] = 0; $pc++; }$code[($df<<12)+$core[118]] = *emul8; goto &fetch; }
$core[004712] = 05341; $code[004712] = *I04712; sub I04712 { $pc = 004741; $inh = 0; goto &fetch; }
$core[004713] = 00001; $code[004713] = *D04713; sub D04713 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[004714] = 02705; $code[004714] = *I04714; sub I04714 { if (++$core[($df<<12)+$core[2501]] == 010000) { $core[($df<<12)+$core[2501]] = 0; $pc++; }$code[($df<<12)+$core[2501]] = *emul8; goto &fetch; }
$core[004715] = 02435; $code[004715] = *I04715; sub I04715 { if (++$core[($df<<12)+$core[29]] == 010000) { $core[($df<<12)+$core[29]] = 0; $pc++; }$code[($df<<12)+$core[29]] = *emul8; goto &fetch; }
$core[004716] = 00001; $code[004716] = *D04716; sub D04716 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[004717] = 02000; $code[004717] = *I04717; sub I04717 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[004720] = 00000; $code[004720] = *I04720; sub I04720 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004721] = 00002; $code[004721] = *D04721; sub D04721 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[004722] = 02000; $code[004722] = *L04722; sub L04722 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[004723] = 00000; $code[004723] = *D04723; sub D04723 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004724] = 05163; $code[004724] = *P04724; sub P04724 { $pc = 000163; $inh = 0; goto &fetch; }
$core[004725] = 00000; $code[004725] = *D04725; sub D04725 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004726] = 00000; $code[004726] = *L04726; sub L04726 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004727] = 00000; $code[004727] = *I04727; sub I04727 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004730] = 00000; $code[004730] = *I04730; sub I04730 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004731] = 00000; $code[004731] = *I04731; sub I04731 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004732] = 04407; $code[004732] = *L04732; sub L04732 { $core[($ib<<12)+$core[7]] = 04733; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[004733] = 00675; $code[004733] = *I04733; sub I04733 { &emul8; goto &fetch; }
$core[004734] = 04675; $code[004734] = *I04734; sub I04734 { &emul8; goto &fetch; }
$core[004735] = 06676; $code[004735] = *I04735; sub I04735 { &emul8; goto &fetch; }
$core[004736] = 04374; $code[004736] = *I04736; sub I04736 { &emul8; goto &fetch; }
$core[004737] = 01371; $code[004737] = *I04737; sub I04737 { &emul8; goto &fetch; }
$core[004740] = 04676; $code[004740] = *I04740; sub I04740 { &emul8; goto &fetch; }
$core[004741] = 01366; $code[004741] = *L04741; sub L04741 { &emul8; goto &fetch; }
$core[004742] = 06326; $code[004742] = *I04742; sub I04742 { &emul8; goto &fetch; }
$core[004743] = 00363; $code[004743] = *D04743; sub D04743 { &emul8; goto &fetch; }
$core[004744] = 04676; $code[004744] = *I04744; sub I04744 { &emul8; goto &fetch; }
$core[004745] = 01360; $code[004745] = *I04745; sub I04745 { &emul8; goto &fetch; }
$core[004746] = 04676; $code[004746] = *I04746; sub I04746 { &emul8; goto &fetch; }
$core[004747] = 01355; $code[004747] = *I04747; sub I04747 { &emul8; goto &fetch; }
$core[004750] = 04675; $code[004750] = *I04750; sub I04750 { &emul8; goto &fetch; }
$core[004751] = 03326; $code[004751] = *I04751; sub I04751 { &emul8; goto &fetch; }
$core[004752] = 00000; $code[004752] = *I04752; sub I04752 { &emul8; goto &fetch; }
$core[004753] = 05754; $code[004753] = *I04753; sub I04753 { $pc = ($ib<<12)+$core[2540]; $inh = 0; goto &fetch; }
$core[004754] = 05024; $code[004754] = *P04754; sub P04754 { $pc = 000024; $inh = 0; goto &fetch; }
$core[004755] = 00000; $code[004755] = *D04755; sub D04755 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004756] = 02437; $code[004756] = *I04756; sub I04756 { if (++$core[($df<<12)+$core[31]] == 010000) { $core[($df<<12)+$core[31]] = 0; $pc++; }$code[($df<<12)+$core[31]] = *emul8; goto &fetch; }
$core[004757] = 01643; $code[004757] = *I04757; sub I04757 { $lac += $core[($df<<12)+$core[2467]]; goto &fetch; }
$core[004760] = 07777; $code[004760] = *D04760; sub D04760 { &emul8; goto &fetch; }
$core[004761] = 03304; $code[004761] = *I04761; sub I04761 { $core[004704] = $lac & 07777; $lac &= 010000; $code[004704] = *emul8; goto &fetch; }
$core[004762] = 04434; $code[004762] = *I04762; sub I04762 { $core[($ib<<12)+$core[28]] = 04763; $pc = ($ib<<12)+$core[28]+1; $code[($ib<<12)+$core[28]] = *emul8; $inh = 0; goto &fetch; }
$core[004763] = 07773; $code[004763] = *I04763; sub I04763 { &emul8; goto &fetch; }
$core[004764] = 03306; $code[004764] = *I04764; sub I04764 { $core[004706] = $lac & 07777; $lac &= 010000; $code[004706] = *emul8; goto &fetch; }
$core[004765] = 05454; $code[004765] = *I04765; sub I04765 { $pc = ($ib<<12)+$core[44]; $inh = 0; goto &fetch; }
$core[004766] = 00000; $code[004766] = *D04766; sub D04766 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004767] = 02437; $code[004767] = *I04767; sub I04767 { if (++$core[($df<<12)+$core[31]] == 010000) { $core[($df<<12)+$core[31]] = 0; $pc++; }$code[($df<<12)+$core[31]] = *emul8; goto &fetch; }
$core[004770] = 01646; $code[004770] = *I04770; sub I04770 { $lac += $core[($df<<12)+$core[2470]]; goto &fetch; }
$core[004771] = 00000; $code[004771] = *D04771; sub D04771 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[004772] = 02427; $code[004772] = *D04772; sub D04772 { if (++$core[($df<<12)+$core[23]] == 010000) { $core[($df<<12)+$core[23]] = 0; $pc++; }$code[($df<<12)+$core[23]] = *emul8; goto &fetch; }
$core[004773] = 02323; $code[004773] = *I04773; sub I04773 { if (++$core[004723] == 010000) { $core[004723] = 0; $pc++; }$code[004723] = *emul8; goto &fetch; }
$core[004774] = 07775; $code[004774] = *D04774; sub D04774 { &emul8; goto &fetch; }
$core[004775] = 03427; $code[004775] = *I04775; sub I04775 { $core[($df<<12)+$core[23]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[23]] = *emul8; goto &fetch; }
$core[004776] = 07052; $code[004776] = *I04776; sub I04776 { $lac ^= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[005000] = 01045; $code[005000] = *I05000; sub I05000 { $lac += $core[000045]; goto &fetch; }
$core[005001] = 07710; $code[005001] = *I05001; sub I05001 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005002] = 04363; $code[005002] = *I05002; sub I05002 { $core[005163] = 05003; $pc = 005163+1; $code[005163] = *emul8; $inh = 0; goto &fetch; }
$core[005003] = 03033; $code[005003] = *I05003; sub I05003 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[005004] = 04407; $code[005004] = *I05004; sub I05004 { $core[($ib<<12)+$core[7]] = 05005; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005005] = 06635; $code[005005] = *I05005; sub I05005 { &emul8; goto &fetch; }
$core[005006] = 02637; $code[005006] = *I05006; sub I05006 { &emul8; goto &fetch; }
$core[005007] = 00000; $code[005007] = *I05007; sub I05007 { &emul8; goto &fetch; }
$core[005010] = 01045; $code[005010] = *I05010; sub I05010 { $lac += $core[000045]; goto &fetch; }
$core[005011] = 07710; $code[005011] = *I05011; sub I05011 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005012] = 05221; $code[005012] = *I05012; sub I05012 { $pc = 005021; $inh = 0; goto &fetch; }
$core[005013] = 04407; $code[005013] = *P05013; sub P05013 { $core[($ib<<12)+$core[7]] = 05014; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005014] = 00637; $code[005014] = *I05014; sub I05014 { &emul8; goto &fetch; }
$core[005015] = 03635; $code[005015] = *I05015; sub I05015 { &emul8; goto &fetch; }
$core[005016] = 06635; $code[005016] = *I05016; sub I05016 { &emul8; goto &fetch; }
$core[005017] = 00000; $code[005017] = *I05017; sub I05017 { &emul8; goto &fetch; }
$core[005020] = 07240; $code[005020] = *I05020; sub I05020 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005021] = 03362; $code[005021] = *L05021; sub L05021 { $core[005162] = $lac & 07777; $lac &= 010000; $code[005162] = *emul8; goto &fetch; }
$core[005022] = 05623; $code[005022] = *I05022; sub I05022 { $pc = ($ib<<12)+$core[2579]; $inh = 0; goto &fetch; }
$core[005023] = 04732; $code[005023] = *P05023; sub P05023 { $core[($ib<<12)+$core[2650]] = 05024; $pc = ($ib<<12)+$core[2650]+1; $code[($ib<<12)+$core[2650]] = *emul8; $inh = 0; goto &fetch; }
$core[005024] = 02362; $code[005024] = *L05024; sub L05024 { if (++$core[005162] == 010000) { $core[005162] = 0; $pc++; }$code[005162] = *emul8; goto &fetch; }
$core[005025] = 05634; $code[005025] = *I05025; sub I05025 { $pc = ($ib<<12)+$core[2588]; $inh = 0; goto &fetch; }
$core[005026] = 04407; $code[005026] = *I05026; sub I05026 { $core[($ib<<12)+$core[7]] = 05027; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005027] = 06635; $code[005027] = *I05027; sub I05027 { &emul8; goto &fetch; }
$core[005030] = 00636; $code[005030] = *I05030; sub I05030 { &emul8; goto &fetch; }
$core[005031] = 02635; $code[005031] = *I05031; sub I05031 { &emul8; goto &fetch; }
$core[005032] = 00000; $code[005032] = *I05032; sub I05032 { &emul8; goto &fetch; }
$core[005033] = 05634; $code[005033] = *I05033; sub I05033 { $pc = ($ib<<12)+$core[2588]; $inh = 0; goto &fetch; }
$core[005034] = 05302; $code[005034] = *P05034; sub P05034 { $pc = 005102; $inh = 0; goto &fetch; }
$core[005035] = 05322; $code[005035] = *P05035; sub P05035 { $pc = 005122; $inh = 0; goto &fetch; }
$core[005036] = 05316; $code[005036] = *D05036; sub D05036 { $pc = 005116; $inh = 0; goto &fetch; }
$core[005037] = 04716; $code[005037] = *P05037; sub P05037 { $core[($ib<<12)+$core[2638]] = 05040; $pc = ($ib<<12)+$core[2638]+1; $code[($ib<<12)+$core[2638]] = *emul8; $inh = 0; goto &fetch; }
$core[005040] = 01045; $code[005040] = *I05040; sub I05040 { $lac += $core[000045]; goto &fetch; }
$core[005041] = 07450; $code[005041] = *I05041; sub I05041 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005042] = 04566; $code[005042] = *I05042; sub I05042 { $core[($ib<<12)+$core[118]] = 05043; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[005043] = 07710; $code[005043] = *I05043; sub I05043 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005044] = 04451; $code[005044] = *I05044; sub I05044 { $core[($ib<<12)+$core[41]] = 05045; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[005045] = 04407; $code[005045] = *I05045; sub I05045 { $core[($ib<<12)+$core[7]] = 05046; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005046] = 06756; $code[005046] = *I05046; sub I05046 { &emul8; goto &fetch; }
$core[005047] = 02637; $code[005047] = *I05047; sub I05047 { &emul8; goto &fetch; }
$core[005050] = 00000; $code[005050] = *I05050; sub I05050 { &emul8; goto &fetch; }
$core[005051] = 01045; $code[005051] = *I05051; sub I05051 { $lac += $core[000045]; goto &fetch; }
$core[005052] = 07450; $code[005052] = *I05052; sub I05052 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005053] = 05536; $code[005053] = *I05053; sub I05053 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[005054] = 07700; $code[005054] = *I05054; sub I05054 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005055] = 05264; $code[005055] = *I05055; sub I05055 { $pc = 005064; $inh = 0; goto &fetch; }
$core[005056] = 04407; $code[005056] = *I05056; sub I05056 { $core[($ib<<12)+$core[7]] = 05057; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005057] = 00637; $code[005057] = *I05057; sub I05057 { &emul8; goto &fetch; }
$core[005060] = 03756; $code[005060] = *I05060; sub I05060 { &emul8; goto &fetch; }
$core[005061] = 06756; $code[005061] = *I05061; sub I05061 { &emul8; goto &fetch; }
$core[005062] = 00000; $code[005062] = *I05062; sub I05062 { &emul8; goto &fetch; }
$core[005063] = 07240; $code[005063] = *I05063; sub I05063 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005064] = 03033; $code[005064] = *L05064; sub L05064 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[005065] = 01005; $code[005065] = *I05065; sub I05065 { $lac += $core[000005]; goto &fetch; }
$core[005066] = 03044; $code[005066] = *I05066; sub I05066 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[005067] = 07040; $code[005067] = *I05067; sub I05067 { $lac ^= 07777; goto &fetch; }
$core[005070] = 01756; $code[005070] = *I05070; sub I05070 { $lac += $core[($df<<12)+$core[2670]]; goto &fetch; }
$core[005071] = 03045; $code[005071] = *I05071; sub I05071 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[005072] = 03046; $code[005072] = *I05072; sub I05072 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[005073] = 03047; $code[005073] = *I05073; sub I05073 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[005074] = 07001; $code[005074] = *I05074; sub I05074 { $lac++; goto &fetch; }
$core[005075] = 03756; $code[005075] = *I05075; sub I05075 { $core[($df<<12)+$core[2670]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2670]] = *emul8; goto &fetch; }
$core[005076] = 04407; $code[005076] = *I05076; sub I05076 { $core[($ib<<12)+$core[7]] = 05077; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005077] = 04357; $code[005077] = *I05077; sub I05077 { &emul8; goto &fetch; }
$core[005100] = 06635; $code[005100] = *I05100; sub I05100 { &emul8; goto &fetch; }
$core[005101] = 00756; $code[005101] = *D05101; sub D05101 { &emul8; goto &fetch; }
$core[005102] = 02637; $code[005102] = *L05102; sub L05102 { &emul8; goto &fetch; }
$core[005103] = 06756; $code[005103] = *I05103; sub I05103 { &emul8; goto &fetch; }
$core[005104] = 04353; $code[005104] = *I05104; sub I05104 { &emul8; goto &fetch; }
$core[005105] = 01350; $code[005105] = *I05105; sub I05105 { &emul8; goto &fetch; }
$core[005106] = 04756; $code[005106] = *I05106; sub I05106 { &emul8; goto &fetch; }
$core[005107] = 01345; $code[005107] = *D05107; sub D05107 { &emul8; goto &fetch; }
$core[005110] = 04756; $code[005110] = *I05110; sub I05110 { &emul8; goto &fetch; }
$core[005111] = 01342; $code[005111] = *I05111; sub I05111 { &emul8; goto &fetch; }
$core[005112] = 04756; $code[005112] = *I05112; sub I05112 { &emul8; goto &fetch; }
$core[005113] = 01337; $code[005113] = *I05113; sub I05113 { &emul8; goto &fetch; }
$core[005114] = 04756; $code[005114] = *I05114; sub I05114 { &emul8; goto &fetch; }
$core[005115] = 01334; $code[005115] = *I05115; sub I05115 { &emul8; goto &fetch; }
$core[005116] = 04756; $code[005116] = *P05116; sub P05116 { &emul8; goto &fetch; }
$core[005117] = 01331; $code[005117] = *I05117; sub I05117 { &emul8; goto &fetch; }
$core[005120] = 04756; $code[005120] = *I05120; sub I05120 { &emul8; goto &fetch; }
$core[005121] = 01326; $code[005121] = *I05121; sub I05121 { &emul8; goto &fetch; }
$core[005122] = 04756; $code[005122] = *L05122; sub L05122 { &emul8; goto &fetch; }
$core[005123] = 01635; $code[005123] = *I05123; sub I05123 { &emul8; goto &fetch; }
$core[005124] = 00000; $code[005124] = *I05124; sub I05124 { &emul8; goto &fetch; }
$core[005125] = 05634; $code[005125] = *I05125; sub I05125 { $pc = ($ib<<12)+$core[2588]; $inh = 0; goto &fetch; }
$core[005126] = 00000; $code[005126] = *P05126; sub P05126 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005127] = 03777; $code[005127] = *I05127; sub I05127 { $core[($df<<12)+$core[2687]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2687]] = *emul8; goto &fetch; }
$core[005130] = 07742; $code[005130] = *I05130; sub I05130 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[005131] = 07777; $code[005131] = *D05131; sub D05131 { &emul8; goto &fetch; }
$core[005132] = 04000; $code[005132] = *P05132; sub P05132 { $core[000000] = 05133; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[005133] = 04100; $code[005133] = *I05133; sub I05133 { $core[000100] = 05134; $pc = 000100+1; $code[000100] = *emul8; $inh = 0; goto &fetch; }
$core[005134] = 07777; $code[005134] = *D05134; sub D05134 { &emul8; goto &fetch; }
$core[005135] = 02517; $code[005135] = *P05135; sub P05135 { if (++$core[($df<<12)+$core[79]] == 010000) { $core[($df<<12)+$core[79]] = 0; $pc++; }$code[($df<<12)+$core[79]] = *emul8; goto &fetch; }
$core[005136] = 00307; $code[005136] = *I05136; sub I05136 { $lac &= (010000|$core[005107]); goto &fetch; }
$core[005137] = 07776; $code[005137] = *D05137; sub D05137 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[005140] = 04113; $code[005140] = *I05140; sub I05140 { $core[000113] = 05141; $pc = 000113+1; $code[000113] = *emul8; $inh = 0; goto &fetch; }
$core[005141] = 07211; $code[005141] = *I05141; sub I05141 { $lac &= 010000; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005142] = 07776; $code[005142] = *D05142; sub D05142 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[005143] = 02535; $code[005143] = *I05143; sub I05143 { if (++$core[($df<<12)+$core[93]] == 010000) { $core[($df<<12)+$core[93]] = 0; $pc++; }$code[($df<<12)+$core[93]] = *emul8; goto &fetch; }
$core[005144] = 03301; $code[005144] = *I05144; sub I05144 { $core[005101] = $lac & 07777; $lac &= 010000; $code[005101] = *emul8; goto &fetch; }
$core[005145] = 07775; $code[005145] = *D05145; sub D05145 { &emul8; goto &fetch; }
$core[005146] = 04746; $code[005146] = *P05146; sub P05146 { $core[($ib<<12)+$core[2662]] = 05147; $pc = ($ib<<12)+$core[2662]+1; $code[($ib<<12)+$core[2662]] = *emul8; $inh = 0; goto &fetch; }
$core[005147] = 00771; $code[005147] = *I05147; sub I05147 { $lac &= (010000|$core[($df<<12)+$core[2681]]); goto &fetch; }
$core[005150] = 07774; $code[005150] = *D05150; sub D05150 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005151] = 02236; $code[005151] = *I05151; sub I05151 { if (++$core[005036] == 010000) { $core[005036] = 0; $pc++; }$code[005036] = *emul8; goto &fetch; }
$core[005152] = 04304; $code[005152] = *I05152; sub I05152 { $core[005104] = 05153; $pc = 005104+1; $code[005104] = *emul8; $inh = 0; goto &fetch; }
$core[005153] = 07771; $code[005153] = *D05153; sub D05153 { &emul8; goto &fetch; }
$core[005154] = 04544; $code[005154] = *I05154; sub I05154 { $core[($ib<<12)+$core[100]] = 05155; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[005155] = 01735; $code[005155] = *I05155; sub I05155 { $lac += $core[($df<<12)+$core[2653]]; goto &fetch; }
$core[005156] = 04726; $code[005156] = *P05156; sub P05156 { $core[($ib<<12)+$core[2646]] = 05157; $pc = ($ib<<12)+$core[2646]+1; $code[($ib<<12)+$core[2646]] = *emul8; $inh = 0; goto &fetch; }
$core[005157] = 00000; $code[005157] = *D05157; sub D05157 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005160] = 02613; $code[005160] = *I05160; sub I05160 { if (++$core[($df<<12)+$core[2571]] == 010000) { $core[($df<<12)+$core[2571]] = 0; $pc++; }$code[($df<<12)+$core[2571]] = *emul8; goto &fetch; }
$core[005161] = 04414; $code[005161] = *I05161; sub I05161 { $core[000014] = 0000 if ++$core[000014] == 010000; $core[($ib<<12)+$core[000014]] = 05162; $pc = ($ib<<12)+$core[000014]+1; $code[($ib<<12)+$core[000014]] = *emul8; $inh = 0; goto &fetch; }
$core[005162] = 00000; $code[005162] = *D05162; sub D05162 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005163] = 00000; $code[005163] = *S05163; sub S05163 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005164] = 04451; $code[005164] = *I05164; sub I05164 { $core[($ib<<12)+$core[41]] = 05165; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[005165] = 07240; $code[005165] = *I05165; sub I05165 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005166] = 05763; $code[005166] = *I05166; sub I05166 { $pc = ($ib<<12)+$core[2675]; $inh = 0; goto &fetch; }
$core[005200] = 04407; $code[005200] = *D05200; sub D05200 { $core[($ib<<12)+$core[7]] = 05201; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005201] = 06322; $code[005201] = *I05201; sub I05201 { &emul8; goto &fetch; }
$core[005202] = 00316; $code[005202] = *I05202; sub I05202 { &emul8; goto &fetch; }
$core[005203] = 02322; $code[005203] = *I05203; sub I05203 { &emul8; goto &fetch; }
$core[005204] = 00000; $code[005204] = *I05204; sub I05204 { &emul8; goto &fetch; }
$core[005205] = 01045; $code[005205] = *I05205; sub I05205 { $lac += $core[000045]; goto &fetch; }
$core[005206] = 07740; $code[005206] = *I05206; sub I05206 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005207] = 05215; $code[005207] = *I05207; sub I05207 { $pc = 005215; $inh = 0; goto &fetch; }
$core[005210] = 01045; $code[005210] = *I05210; sub I05210 { $lac += $core[000045]; goto &fetch; }
$core[005211] = 07700; $code[005211] = *I05211; sub I05211 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005212] = 05536; $code[005212] = *I05212; sub I05212 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[005213] = 04451; $code[005213] = *I05213; sub I05213 { $core[($ib<<12)+$core[41]] = 05214; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[005214] = 07040; $code[005214] = *I05214; sub I05214 { $lac ^= 07777; goto &fetch; }
$core[005215] = 03033; $code[005215] = *L05215; sub L05215 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[005216] = 04407; $code[005216] = *I05216; sub I05216 { $core[($ib<<12)+$core[7]] = 05217; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005217] = 03306; $code[005217] = *I05217; sub I05217 { &emul8; goto &fetch; }
$core[005220] = 06326; $code[005220] = *I05220; sub I05220 { &emul8; goto &fetch; }
$core[005221] = 00000; $code[005221] = *I05221; sub I05221 { &emul8; goto &fetch; }
$core[005222] = 04453; $code[005222] = *I05222; sub I05222 { $core[($ib<<12)+$core[43]] = 05223; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[005223] = 04407; $code[005223] = *I05223; sub I05223 { $core[($ib<<12)+$core[7]] = 05224; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005224] = 07000; $code[005224] = *I05224; sub I05224 { &emul8; goto &fetch; }
$core[005225] = 06322; $code[005225] = *I05225; sub I05225 { &emul8; goto &fetch; }
$core[005226] = 00326; $code[005226] = *I05226; sub I05226 { &emul8; goto &fetch; }
$core[005227] = 02322; $code[005227] = *I05227; sub I05227 { &emul8; goto &fetch; }
$core[005230] = 04306; $code[005230] = *I05230; sub I05230 { &emul8; goto &fetch; }
$core[005231] = 06322; $code[005231] = *I05231; sub I05231 { &emul8; goto &fetch; }
$core[005232] = 02312; $code[005232] = *I05232; sub I05232 { &emul8; goto &fetch; }
$core[005233] = 00000; $code[005233] = *I05233; sub I05233 { &emul8; goto &fetch; }
$core[005234] = 01045; $code[005234] = *I05234; sub I05234 { $lac += $core[000045]; goto &fetch; }
$core[005235] = 07710; $code[005235] = *D05235; sub D05235 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005236] = 05245; $code[005236] = *I05236; sub I05236 { $pc = 005245; $inh = 0; goto &fetch; }
$core[005237] = 04407; $code[005237] = *I05237; sub I05237 { $core[($ib<<12)+$core[7]] = 05240; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005240] = 06322; $code[005240] = *I05240; sub I05240 { &emul8; goto &fetch; }
$core[005241] = 00000; $code[005241] = *I05241; sub I05241 { &emul8; goto &fetch; }
$core[005242] = 01033; $code[005242] = *I05242; sub I05242 { $lac += $core[000033]; goto &fetch; }
$core[005243] = 07040; $code[005243] = *I05243; sub I05243 { $lac ^= 07777; goto &fetch; }
$core[005244] = 03033; $code[005244] = *I05244; sub I05244 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[005245] = 04407; $code[005245] = *L05245; sub L05245 { $core[($ib<<12)+$core[7]] = 05246; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005246] = 00322; $code[005246] = *I05246; sub I05246 { &emul8; goto &fetch; }
$core[005247] = 02316; $code[005247] = *I05247; sub I05247 { &emul8; goto &fetch; }
$core[005250] = 00000; $code[005250] = *I05250; sub I05250 { &emul8; goto &fetch; }
$core[005251] = 01045; $code[005251] = *I05251; sub I05251 { $lac += $core[000045]; goto &fetch; }
$core[005252] = 07710; $code[005252] = *I05252; sub I05252 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005253] = 05261; $code[005253] = *I05253; sub I05253 { $pc = 005261; $inh = 0; goto &fetch; }
$core[005254] = 04407; $code[005254] = *I05254; sub I05254 { $core[($ib<<12)+$core[7]] = 05255; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005255] = 00312; $code[005255] = *I05255; sub I05255 { &emul8; goto &fetch; }
$core[005256] = 02322; $code[005256] = *I05256; sub I05256 { &emul8; goto &fetch; }
$core[005257] = 06322; $code[005257] = *I05257; sub I05257 { &emul8; goto &fetch; }
$core[005260] = 00000; $code[005260] = *I05260; sub I05260 { &emul8; goto &fetch; }
$core[005261] = 04407; $code[005261] = *L05261; sub L05261 { $core[($ib<<12)+$core[7]] = 05262; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[005262] = 00322; $code[005262] = *I05262; sub I05262 { &emul8; goto &fetch; }
$core[005263] = 03316; $code[005263] = *I05263; sub I05263 { &emul8; goto &fetch; }
$core[005264] = 06322; $code[005264] = *I05264; sub I05264 { &emul8; goto &fetch; }
$core[005265] = 04322; $code[005265] = *I05265; sub I05265 { &emul8; goto &fetch; }
$core[005266] = 06326; $code[005266] = *I05266; sub I05266 { &emul8; goto &fetch; }
$core[005267] = 00332; $code[005267] = *I05267; sub I05267 { &emul8; goto &fetch; }
$core[005270] = 04326; $code[005270] = *I05270; sub I05270 { &emul8; goto &fetch; }
$core[005271] = 01336; $code[005271] = *I05271; sub I05271 { &emul8; goto &fetch; }
$core[005272] = 04326; $code[005272] = *I05272; sub I05272 { &emul8; goto &fetch; }
$core[005273] = 01342; $code[005273] = *I05273; sub I05273 { &emul8; goto &fetch; }
$core[005274] = 04326; $code[005274] = *I05274; sub I05274 { &emul8; goto &fetch; }
$core[005275] = 01346; $code[005275] = *I05275; sub I05275 { &emul8; goto &fetch; }
$core[005276] = 04326; $code[005276] = *I05276; sub I05276 { &emul8; goto &fetch; }
$core[005277] = 01316; $code[005277] = *I05277; sub I05277 { &emul8; goto &fetch; }
$core[005300] = 04322; $code[005300] = *I05300; sub I05300 { &emul8; goto &fetch; }
$core[005301] = 00000; $code[005301] = *I05301; sub I05301 { &emul8; goto &fetch; }
$core[005302] = 02033; $code[005302] = *L05302; sub L05302 { if (++$core[000033] == 010000) { $core[000033] = 0; $pc++; }$code[000033] = *emul8; goto &fetch; }
$core[005303] = 05536; $code[005303] = *I05303; sub I05303 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[005304] = 04451; $code[005304] = *I05304; sub I05304 { $core[($ib<<12)+$core[41]] = 05305; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[005305] = 05536; $code[005305] = *I05305; sub I05305 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[005306] = 00003; $code[005306] = *D05306; sub D05306 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[005307] = 03110; $code[005307] = *I05307; sub I05307 { $core[000110] = $lac & 07777; $lac &= 010000; $code[000110] = *emul8; goto &fetch; }
$core[005310] = 03756; $code[005310] = *I05310; sub I05310 { $core[($df<<12)+$core[2798]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2798]] = *emul8; goto &fetch; }
$core[005311] = 03235; $code[005311] = *I05311; sub I05311 { $core[005235] = $lac & 07777; $lac &= 010000; $code[005235] = *emul8; goto &fetch; }
$core[005312] = 00002; $code[005312] = *D05312; sub D05312 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[005313] = 03110; $code[005313] = *I05313; sub I05313 { $core[000110] = $lac & 07777; $lac &= 010000; $code[000110] = *emul8; goto &fetch; }
$core[005314] = 03756; $code[005314] = *I05314; sub I05314 { $core[($df<<12)+$core[2798]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2798]] = *emul8; goto &fetch; }
$core[005315] = 03235; $code[005315] = *I05315; sub I05315 { $core[005235] = $lac & 07777; $lac &= 010000; $code[005235] = *emul8; goto &fetch; }
$core[005316] = 00001; $code[005316] = *D05316; sub D05316 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[005317] = 03110; $code[005317] = *I05317; sub I05317 { $core[000110] = $lac & 07777; $lac &= 010000; $code[000110] = *emul8; goto &fetch; }
$core[005320] = 03756; $code[005320] = *I05320; sub I05320 { $core[($df<<12)+$core[2798]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2798]] = *emul8; goto &fetch; }
$core[005321] = 03235; $code[005321] = *I05321; sub I05321 { $core[005235] = $lac & 07777; $lac &= 010000; $code[005235] = *emul8; goto &fetch; }
$core[005322] = 00000; $code[005322] = *D05322; sub D05322 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005323] = 00000; $code[005323] = *I05323; sub I05323 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005324] = 00000; $code[005324] = *I05324; sub I05324 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005325] = 00000; $code[005325] = *L05325; sub L05325 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005326] = 00000; $code[005326] = *D05326; sub D05326 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005327] = 00000; $code[005327] = *I05327; sub I05327 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005330] = 00000; $code[005330] = *I05330; sub I05330 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005331] = 00000; $code[005331] = *I05331; sub I05331 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005332] = 07764; $code[005332] = *I05332; sub I05332 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[005333] = 02401; $code[005333] = *I05333; sub I05333 { if (++$core[($df<<12)+$core[1]] == 010000) { $core[($df<<12)+$core[1]] = 0; $pc++; }$code[($df<<12)+$core[1]] = *emul8; goto &fetch; }
$core[005334] = 07015; $code[005334] = *I05334; sub I05334 { $lac++; $lac = ($lac<<1) + (($lac>>12)&1); $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005335] = 01042; $code[005335] = *I05335; sub I05335 { $lac += $core[000042]; goto &fetch; }
$core[005336] = 07771; $code[005336] = *P05336; sub P05336 { &emul8; goto &fetch; }
$core[005337] = 05464; $code[005337] = *I05337; sub I05337 { $pc = ($ib<<12)+$core[52]; $inh = 0; goto &fetch; }
$core[005340] = 05514; $code[005340] = *I05340; sub I05340 { $pc = ($ib<<12)+$core[76]; $inh = 0; goto &fetch; }
$core[005341] = 06150; $code[005341] = *I05341; sub I05341 { &emul8; goto &fetch; }
$core[005342] = 07775; $code[005342] = *D05342; sub D05342 { &emul8; goto &fetch; }
$core[005343] = 02431; $code[005343] = *I05343; sub I05343 { if (++$core[($df<<12)+$core[25]] == 010000) { $core[($df<<12)+$core[25]] = 0; $pc++; }$code[($df<<12)+$core[25]] = *emul8; goto &fetch; }
$core[005344] = 05361; $code[005344] = *I05344; sub I05344 { $pc = 005361; $inh = 0; goto &fetch; }
$core[005345] = 04736; $code[005345] = *I05345; sub I05345 { $core[($ib<<12)+$core[2782]] = 05346; $pc = ($ib<<12)+$core[2782]+1; $code[($ib<<12)+$core[2782]] = *emul8; $inh = 0; goto &fetch; }
$core[005346] = 00000; $code[005346] = *D05346; sub D05346 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005347] = 05325; $code[005347] = *I05347; sub I05347 { $pc = 005325; $inh = 0; goto &fetch; }
$core[005350] = 00414; $code[005350] = *I05350; sub I05350 { $core[000014] = 0000 if ++$core[000014] == 010000; $lac &= (010000|$core[($df<<12)+$core[000014]]); goto &fetch; }
$core[005351] = 03167; $code[005351] = *I05351; sub I05351 { $core[000167] = $lac & 07777; $lac &= 010000; $code[000167] = *emul8; goto &fetch; }
$core[005400] = 00000; $code[005400] = *S05400; sub S05400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005401] = 03334; $code[005401] = *I05401; sub I05401 { $core[005534] = $lac & 07777; $lac &= 010000; $code[005534] = *emul8; goto &fetch; }
$core[005402] = 01052; $code[005402] = *I05402; sub I05402 { $lac += $core[000052]; goto &fetch; }
$core[005403] = 04557; $code[005403] = *D05403; sub D05403 { $core[($ib<<12)+$core[111]] = 05404; $pc = ($ib<<12)+$core[111]+1; $code[($ib<<12)+$core[111]] = *emul8; $inh = 0; goto &fetch; }
$core[005404] = 00122; $code[005404] = *I05404; sub I05404 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[005405] = 03032; $code[005405] = *I05405; sub I05405 { $core[000032] = $lac & 07777; $lac &= 010000; $code[000032] = *emul8; goto &fetch; }
$core[005406] = 01032; $code[005406] = *I05406; sub I05406 { $lac += $core[000032]; goto &fetch; }
$core[005407] = 07041; $code[005407] = *I05407; sub I05407 { $lac ^= 07777; $lac++; goto &fetch; }
$core[005410] = 07450; $code[005410] = *I05410; sub I05410 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005411] = 01326; $code[005411] = *I05411; sub I05411 { $lac += $core[005526]; goto &fetch; }
$core[005412] = 03335; $code[005412] = *I05412; sub I05412 { $core[005535] = $lac & 07777; $lac &= 010000; $code[005535] = *emul8; goto &fetch; }
$core[005413] = 01052; $code[005413] = *I05413; sub I05413 { $lac += $core[000052]; goto &fetch; }
$core[005414] = 07450; $code[005414] = *I05414; sub I05414 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005415] = 05241; $code[005415] = *I05415; sub I05415 { $pc = 005441; $inh = 0; goto &fetch; }
$core[005416] = 00122; $code[005416] = *I05416; sub I05416 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[005417] = 03333; $code[005417] = *I05417; sub I05417 { $core[005533] = $lac & 07777; $lac &= 010000; $code[005533] = *emul8; goto &fetch; }
$core[005420] = 01335; $code[005420] = *I05420; sub I05420 { $lac += $core[005535]; goto &fetch; }
$core[005421] = 01333; $code[005421] = *I05421; sub I05421 { $lac += $core[005533]; goto &fetch; }
$core[005422] = 07510; $code[005422] = *I05422; sub I05422 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005423] = 05230; $code[005423] = *I05423; sub I05423 { $pc = 005430; $inh = 0; goto &fetch; }
$core[005424] = 07240; $code[005424] = *I05424; sub I05424 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[005425] = 01032; $code[005425] = *I05425; sub I05425 { $lac += $core[000032]; goto &fetch; }
$core[005426] = 03333; $code[005426] = *I05426; sub I05426 { $core[005533] = $lac & 07777; $lac &= 010000; $code[005533] = *emul8; goto &fetch; }
$core[005427] = 07040; $code[005427] = *I05427; sub I05427 { $lac ^= 07777; goto &fetch; }
$core[005430] = 01033; $code[005430] = *L05430; sub L05430 { $lac += $core[000033]; goto &fetch; }
$core[005431] = 07500; $code[005431] = *I05431; sub I05431 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[005432] = 07200; $code[005432] = *I05432; sub I05432 { $lac &= 010000; goto &fetch; }
$core[005433] = 01032; $code[005433] = *I05433; sub I05433 { $lac += $core[000032]; goto &fetch; }
$core[005434] = 07510; $code[005434] = *I05434; sub I05434 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005435] = 05263; $code[005435] = *I05435; sub I05435 { $pc = 005463; $inh = 0; goto &fetch; }
$core[005436] = 01326; $code[005436] = *I05436; sub I05436 { $lac += $core[005526]; goto &fetch; }
$core[005437] = 07500; $code[005437] = *I05437; sub I05437 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[005440] = 07200; $code[005440] = *I05440; sub I05440 { $lac &= 010000; goto &fetch; }
$core[005441] = 01327; $code[005441] = *L05441; sub L05441 { $lac += $core[005527]; goto &fetch; }
$core[005442] = 03071; $code[005442] = *I05442; sub I05442 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[005443] = 01731; $code[005443] = *I05443; sub I05443 { $lac += $core[($df<<12)+$core[2905]]; goto &fetch; }
$core[005444] = 01071; $code[005444] = *I05444; sub I05444 { $lac += $core[000071]; goto &fetch; }
$core[005445] = 03336; $code[005445] = *I05445; sub I05445 { $core[005536] = $lac & 07777; $lac &= 010000; $code[005536] = *emul8; goto &fetch; }
$core[005446] = 01071; $code[005446] = *I05446; sub I05446 { $lac += $core[000071]; goto &fetch; }
$core[005447] = 07041; $code[005447] = *I05447; sub I05447 { $lac ^= 07777; $lac++; goto &fetch; }
$core[005450] = 03071; $code[005450] = *I05450; sub I05450 { $core[000071] = $lac & 07777; $lac &= 010000; $code[000071] = *emul8; goto &fetch; }
$core[005451] = 01325; $code[005451] = *I05451; sub I05451 { $lac += $core[005525]; goto &fetch; }
$core[005452] = 02736; $code[005452] = *L05452; sub L05452 { if (++$core[($df<<12)+$core[2910]] == 010000) { $core[($df<<12)+$core[2910]] = 0; $pc++; }$code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005453] = 01736; $code[005453] = *I05453; sub I05453 { $lac += $core[($df<<12)+$core[2910]]; goto &fetch; }
$core[005454] = 01330; $code[005454] = *I05454; sub I05454 { $lac += $core[005530]; goto &fetch; }
$core[005455] = 07710; $code[005455] = *I05455; sub I05455 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005456] = 05265; $code[005456] = *I05456; sub I05456 { $pc = 005465; $inh = 0; goto &fetch; }
$core[005457] = 03736; $code[005457] = *I05457; sub I05457 { $core[($df<<12)+$core[2910]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005460] = 02071; $code[005460] = *I05460; sub I05460 { if (++$core[000071] == 010000) { $core[000071] = 0; $pc++; }$code[000071] = *emul8; goto &fetch; }
$core[005461] = 05321; $code[005461] = *L05461; sub L05461 { $pc = 005521; $inh = 0; goto &fetch; }
$core[005462] = 02736; $code[005462] = *I05462; sub I05462 { if (++$core[($df<<12)+$core[2910]] == 010000) { $core[($df<<12)+$core[2910]] = 0; $pc++; }$code[($df<<12)+$core[2910]] = *emul8; goto &fetch; }
$core[005463] = 02033; $code[005463] = *L05463; sub L05463 { if (++$core[000033] == 010000) { $core[000033] = 0; $pc++; }$code[000033] = *emul8; goto &fetch; }
$core[005464] = 07200; $code[005464] = *I05464; sub I05464 { $lac &= 010000; goto &fetch; }
$core[005465] = 01052; $code[005465] = *L05465; sub L05465 { $lac += $core[000052]; goto &fetch; }
$core[005466] = 07650; $code[005466] = *I05466; sub I05466 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005467] = 05356; $code[005467] = *I05467; sub I05467 { $pc = 005556; $inh = 0; goto &fetch; }
$core[005470] = 01335; $code[005470] = *I05470; sub I05470 { $lac += $core[005535]; goto &fetch; }
$core[005471] = 01033; $code[005471] = *D05471; sub D05471 { $lac += $core[000033]; goto &fetch; }
$core[005472] = 07540; $code[005472] = *I05472; sub I05472 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[005473] = 05355; $code[005473] = *I05473; sub I05473 { $pc = 005555; $inh = 0; goto &fetch; }
$core[005474] = 01333; $code[005474] = *I05474; sub I05474 { $lac += $core[005533]; goto &fetch; }
$core[005475] = 07500; $code[005475] = *I05475; sub I05475 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[005476] = 07200; $code[005476] = *I05476; sub I05476 { $lac &= 010000; goto &fetch; }
$core[005477] = 07041; $code[005477] = *I05477; sub I05477 { $lac ^= 07777; $lac++; goto &fetch; }
$core[005500] = 01033; $code[005500] = *I05500; sub I05500 { $lac += $core[000033]; goto &fetch; }
$core[005501] = 07041; $code[005501] = *I05501; sub I05501 { $lac ^= 07777; $lac++; goto &fetch; }
$core[005502] = 03032; $code[005502] = *I05502; sub I05502 { $core[000032] = $lac & 07777; $lac &= 010000; $code[000032] = *emul8; goto &fetch; }
$core[005503] = 01033; $code[005503] = *L05503; sub L05503 { $lac += $core[000033]; goto &fetch; }
$core[005504] = 01032; $code[005504] = *I05504; sub I05504 { $lac += $core[000032]; goto &fetch; }
$core[005505] = 07650; $code[005505] = *I05505; sub I05505 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005506] = 05343; $code[005506] = *I05506; sub I05506 { $pc = 005543; $inh = 0; goto &fetch; }
$core[005507] = 01032; $code[005507] = *I05507; sub I05507 { $lac += $core[000032]; goto &fetch; }
$core[005510] = 07001; $code[005510] = *I05510; sub I05510 { $lac++; goto &fetch; }
$core[005511] = 07710; $code[005511] = *I05511; sub I05511 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005512] = 01105; $code[005512] = *I05512; sub I05512 { $lac += $core[000105]; goto &fetch; }
$core[005513] = 04336; $code[005513] = *L05513; sub L05513 { $core[005536] = 05514; $pc = 005536+1; $code[005536] = *emul8; $inh = 0; goto &fetch; }
$core[005514] = 02032; $code[005514] = *I05514; sub I05514 { if (++$core[000032] == 010000) { $core[000032] = 0; $pc++; }$code[000032] = *emul8; goto &fetch; }
$core[005515] = 05303; $code[005515] = *I05515; sub I05515 { $pc = 005503; $inh = 0; goto &fetch; }
$core[005516] = 01102; $code[005516] = *I05516; sub I05516 { $lac += $core[000102]; goto &fetch; }
$core[005517] = 04551; $code[005517] = *I05517; sub I05517 { $core[($ib<<12)+$core[105]] = 05520; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[005520] = 05303; $code[005520] = *I05520; sub I05520 { $pc = 005503; $inh = 0; goto &fetch; }
$core[005521] = 07040; $code[005521] = *L05521; sub L05521 { $lac ^= 07777; goto &fetch; }
$core[005522] = 01336; $code[005522] = *I05522; sub I05522 { $lac += $core[005536]; goto &fetch; }
$core[005523] = 03336; $code[005523] = *I05523; sub I05523 { $core[005536] = $lac & 07777; $lac &= 010000; $code[005536] = *emul8; goto &fetch; }
$core[005524] = 05252; $code[005524] = *I05524; sub I05524 { $pc = 005452; $inh = 0; goto &fetch; }
$core[005525] = 00005; $code[005525] = *D05525; sub D05525 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[005526] = 07772; $code[005526] = *D05526; sub D05526 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $hlt = 1; goto &fetch; }
$core[005527] = 00007; $code[005527] = *D05527; sub D05527 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[005530] = 07766; $code[005530] = *D05530; sub D05530 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[005531] = 06150; $code[005531] = *P05531; sub P05531 { &emul8; goto &fetch; }
$core[005532] = 06154; $code[005532] = *P05532; sub P05532 { &emul8; goto &fetch; }
$core[005533] = 00000; $code[005533] = *D05533; sub D05533 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005534] = 00000; $code[005534] = *D05534; sub D05534 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005535] = 00000; $code[005535] = *D05535; sub D05535 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005536] = 00000; $code[005536] = *S05536; sub S05536 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005537] = 04732; $code[005537] = *I05537; sub I05537 { $core[($ib<<12)+$core[2906]] = 05540; $pc = ($ib<<12)+$core[2906]+1; $code[($ib<<12)+$core[2906]] = *emul8; $inh = 0; goto &fetch; }
$core[005540] = 02335; $code[005540] = *I05540; sub I05540 { if (++$core[005535] == 010000) { $core[005535] = 0; $pc++; }$code[005535] = *emul8; goto &fetch; }
$core[005541] = 05736; $code[005541] = *D05541; sub D05541 { $pc = ($ib<<12)+$core[2910]; $inh = 0; goto &fetch; }
$core[005542] = 05600; $code[005542] = *I05542; sub I05542 { $pc = ($ib<<12)+$core[2816]; $inh = 0; goto &fetch; }
$core[005543] = 07040; $code[005543] = *L05543; sub L05543 { $lac ^= 07777; goto &fetch; }
$core[005544] = 01033; $code[005544] = *I05544; sub I05544 { $lac += $core[000033]; goto &fetch; }
$core[005545] = 03033; $code[005545] = *I05545; sub I05545 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[005546] = 02334; $code[005546] = *I05546; sub I05546 { if (++$core[005534] == 010000) { $core[005534] = 0; $pc++; }$code[005534] = *emul8; goto &fetch; }
$core[005547] = 05353; $code[005547] = *I05547; sub I05547 { $pc = 005553; $inh = 0; goto &fetch; }
$core[005550] = 07040; $code[005550] = *I05550; sub I05550 { $lac ^= 07777; goto &fetch; }
$core[005551] = 03334; $code[005551] = *I05551; sub I05551 { $core[005534] = $lac & 07777; $lac &= 010000; $code[005534] = *emul8; goto &fetch; }
$core[005552] = 05313; $code[005552] = *I05552; sub I05552 { $pc = 005513; $inh = 0; goto &fetch; }
$core[005553] = 01414; $code[005553] = *L05553; sub L05553 { $core[000014] = 0000 if ++$core[000014] == 010000; $lac += $core[($df<<12)+$core[000014]]; goto &fetch; }
$core[005554] = 05313; $code[005554] = *I05554; sub I05554 { $pc = 005513; $inh = 0; goto &fetch; }
$core[005555] = 07200; $code[005555] = *L05555; sub L05555 { $lac &= 010000; goto &fetch; }
$core[005556] = 04732; $code[005556] = *L05556; sub L05556 { $core[($ib<<12)+$core[2906]] = 05557; $pc = ($ib<<12)+$core[2906]+1; $code[($ib<<12)+$core[2906]] = *emul8; $inh = 0; goto &fetch; }
$core[005557] = 01102; $code[005557] = *I05557; sub I05557 { $lac += $core[000102]; goto &fetch; }
$core[005560] = 04551; $code[005560] = *I05560; sub I05560 { $core[($ib<<12)+$core[105]] = 05561; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[005561] = 02200; $code[005561] = *I05561; sub I05561 { if (++$core[005400] == 010000) { $core[005400] = 0; $pc++; }$code[005400] = *emul8; goto &fetch; }
$core[005562] = 01414; $code[005562] = *L05562; sub L05562 { $core[000014] = 0000 if ++$core[000014] == 010000; $lac += $core[($df<<12)+$core[000014]]; goto &fetch; }
$core[005563] = 04336; $code[005563] = *L05563; sub L05563 { $core[005536] = 05564; $pc = 005536+1; $code[005536] = *emul8; $inh = 0; goto &fetch; }
$core[005564] = 02334; $code[005564] = *I05564; sub I05564 { if (++$core[005534] == 010000) { $core[005534] = 0; $pc++; }$code[005534] = *emul8; goto &fetch; }
$core[005565] = 05362; $code[005565] = *I05565; sub I05565 { $pc = 005562; $inh = 0; goto &fetch; }
$core[005566] = 07040; $code[005566] = *I05566; sub I05566 { $lac ^= 07777; goto &fetch; }
$core[005567] = 03334; $code[005567] = *I05567; sub I05567 { $core[005534] = $lac & 07777; $lac &= 010000; $code[005534] = *emul8; goto &fetch; }
$core[005570] = 05363; $code[005570] = *I05570; sub I05570 { $pc = 005563; $inh = 0; goto &fetch; }
$core[005571] = 00000; $code[005571] = *S05571; sub S05571 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005572] = 01045; $code[005572] = *I05572; sub I05572 { $lac += $core[000045]; goto &fetch; }
$core[005573] = 03050; $code[005573] = *I05573; sub I05573 { $core[000050] = $lac & 07777; $lac &= 010000; $code[000050] = *emul8; goto &fetch; }
$core[005574] = 01045; $code[005574] = *I05574; sub I05574 { $lac += $core[000045]; goto &fetch; }
$core[005575] = 07710; $code[005575] = *I05575; sub I05575 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005576] = 04451; $code[005576] = *L05576; sub L05576 { $core[($ib<<12)+$core[41]] = 05577; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[005577] = 05771; $code[005577] = *I05577; sub I05577 { $pc = ($ib<<12)+$core[2937]; $inh = 0; goto &fetch; }
$core[005600] = 00000; $code[005600] = *S05600; sub S05600 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005601] = 03046; $code[005601] = *I05601; sub I05601 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[005602] = 03044; $code[005602] = *I05602; sub I05602 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[005603] = 03045; $code[005603] = *I05603; sub I05603 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[005604] = 03047; $code[005604] = *I05604; sub I05604 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[005605] = 03314; $code[005605] = *I05605; sub I05605 { $core[005714] = $lac & 07777; $lac &= 010000; $code[005714] = *emul8; goto &fetch; }
$core[005606] = 03050; $code[005606] = *I05606; sub I05606 { $core[000050] = $lac & 07777; $lac &= 010000; $code[000050] = *emul8; goto &fetch; }
$core[005607] = 01066; $code[005607] = *I05607; sub I05607 { $lac += $core[000066]; goto &fetch; }
$core[005610] = 01264; $code[005610] = *I05610; sub I05610 { $lac += $core[005664]; goto &fetch; }
$core[005611] = 07450; $code[005611] = *I05611; sub I05611 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005612] = 05220; $code[005612] = *I05612; sub I05612 { $pc = 005620; $inh = 0; goto &fetch; }
$core[005613] = 01111; $code[005613] = *I05613; sub I05613 { $lac += $core[000111]; goto &fetch; }
$core[005614] = 07640; $code[005614] = *I05614; sub I05614 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005615] = 05221; $code[005615] = *I05615; sub I05615 { $pc = 005621; $inh = 0; goto &fetch; }
$core[005616] = 07040; $code[005616] = *I05616; sub I05616 { $lac ^= 07777; goto &fetch; }
$core[005617] = 03050; $code[005617] = *I05617; sub I05617 { $core[000050] = $lac & 07777; $lac &= 010000; $code[000050] = *emul8; goto &fetch; }
$core[005620] = 04666; $code[005620] = *L05620; sub L05620 { $core[($ib<<12)+$core[2998]] = 05621; $pc = ($ib<<12)+$core[2998]+1; $code[($ib<<12)+$core[2998]] = *emul8; $inh = 0; goto &fetch; }
$core[005621] = 01066; $code[005621] = *L05621; sub L05621 { $lac += $core[000066]; goto &fetch; }
$core[005622] = 01265; $code[005622] = *I05622; sub I05622 { $lac += $core[005665]; goto &fetch; }
$core[005623] = 07650; $code[005623] = *I05623; sub I05623 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005624] = 05220; $code[005624] = *I05624; sub I05624 { $pc = 005620; $inh = 0; goto &fetch; }
$core[005625] = 04227; $code[005625] = *I05625; sub I05625 { $core[005627] = 05626; $pc = 005627+1; $code[005627] = *emul8; $inh = 0; goto &fetch; }
$core[005626] = 05600; $code[005626] = *I05626; sub I05626 { $pc = ($ib<<12)+$core[2944]; $inh = 0; goto &fetch; }
$core[005627] = 00000; $code[005627] = *S05627; sub S05627 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005630] = 01066; $code[005630] = *L05630; sub L05630 { $lac += $core[000066]; goto &fetch; }
$core[005631] = 01262; $code[005631] = *I05631; sub I05631 { $lac += $core[005662]; goto &fetch; }
$core[005632] = 07650; $code[005632] = *I05632; sub I05632 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005633] = 05627; $code[005633] = *I05633; sub I05633 { $pc = ($ib<<12)+$core[2967]; $inh = 0; goto &fetch; }
$core[005634] = 04561; $code[005634] = *I05634; sub I05634 { $core[($ib<<12)+$core[113]] = 05635; $pc = ($ib<<12)+$core[113]+1; $code[($ib<<12)+$core[113]] = *emul8; $inh = 0; goto &fetch; }
$core[005635] = 05627; $code[005635] = *I05635; sub I05635 { $pc = ($ib<<12)+$core[2967]; $inh = 0; goto &fetch; }
$core[005636] = 05247; $code[005636] = *I05636; sub I05636 { $pc = 005647; $inh = 0; goto &fetch; }
$core[005637] = 01054; $code[005637] = *I05637; sub I05637 { $lac += $core[000054]; goto &fetch; }
$core[005640] = 03313; $code[005640] = *L05640; sub L05640 { $core[005713] = $lac & 07777; $lac &= 010000; $code[005713] = *emul8; goto &fetch; }
$core[005641] = 04267; $code[005641] = *I05641; sub I05641 { $core[005667] = 05642; $pc = 005667+1; $code[005667] = *emul8; $inh = 0; goto &fetch; }
$core[005642] = 02314; $code[005642] = *I05642; sub I05642 { if (++$core[005714] == 010000) { $core[005714] = 0; $pc++; }$code[005714] = *emul8; goto &fetch; }
$core[005643] = 07640; $code[005643] = *I05643; sub I05643 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005644] = 04566; $code[005644] = *I05644; sub I05644 { $core[($ib<<12)+$core[118]] = 05645; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[005645] = 04666; $code[005645] = *I05645; sub I05645 { $core[($ib<<12)+$core[2998]] = 05646; $pc = ($ib<<12)+$core[2998]+1; $code[($ib<<12)+$core[2998]] = *emul8; $inh = 0; goto &fetch; }
$core[005646] = 05230; $code[005646] = *I05646; sub I05646 { $pc = 005630; $inh = 0; goto &fetch; }
$core[005647] = 01066; $code[005647] = *L05647; sub L05647 { $lac += $core[000066]; goto &fetch; }
$core[005650] = 01112; $code[005650] = *I05650; sub I05650 { $lac += $core[000112]; goto &fetch; }
$core[005651] = 07710; $code[005651] = *I05651; sub I05651 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005652] = 05627; $code[005652] = *I05652; sub I05652 { $pc = ($ib<<12)+$core[2967]; $inh = 0; goto &fetch; }
$core[005653] = 01066; $code[005653] = *I05653; sub I05653 { $lac += $core[000066]; goto &fetch; }
$core[005654] = 01263; $code[005654] = *I05654; sub I05654 { $lac += $core[005663]; goto &fetch; }
$core[005655] = 07740; $code[005655] = *I05655; sub I05655 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[005656] = 05627; $code[005656] = *I05656; sub I05656 { $pc = ($ib<<12)+$core[2967]; $inh = 0; goto &fetch; }
$core[005657] = 01066; $code[005657] = *I05657; sub I05657 { $lac += $core[000066]; goto &fetch; }
$core[005660] = 00122; $code[005660] = *I05660; sub I05660 { $lac &= (010000|$core[000122]); goto &fetch; }
$core[005661] = 05240; $code[005661] = *I05661; sub I05661 { $pc = 005640; $inh = 0; goto &fetch; }
$core[005662] = 07473; $code[005662] = *D05662; sub D05662 { &emul8; goto &fetch; }
$core[005663] = 07446; $code[005663] = *D05663; sub D05663 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[005664] = 07525; $code[005664] = *D05664; sub D05664 { &emul8; goto &fetch; }
$core[005665] = 07540; $code[005665] = *D05665; sub D05665 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[005666] = 00756; $code[005666] = *P05666; sub P05666 { $lac &= (010000|$core[($df<<12)+$core[3054]]); goto &fetch; }
$core[005667] = 00000; $code[005667] = *S05667; sub S05667 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005670] = 01047; $code[005670] = *I05670; sub I05670 { $lac += $core[000047]; goto &fetch; }
$core[005671] = 03043; $code[005671] = *I05671; sub I05671 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[005672] = 01046; $code[005672] = *I05672; sub I05672 { $lac += $core[000046]; goto &fetch; }
$core[005673] = 03042; $code[005673] = *I05673; sub I05673 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[005674] = 01045; $code[005674] = *I05674; sub I05674 { $lac += $core[000045]; goto &fetch; }
$core[005675] = 03041; $code[005675] = *I05675; sub I05675 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[005676] = 03312; $code[005676] = *I05676; sub I05676 { $core[005712] = $lac & 07777; $lac &= 010000; $code[005712] = *emul8; goto &fetch; }
$core[005677] = 04315; $code[005677] = *I05677; sub I05677 { $core[005715] = 05700; $pc = 005715+1; $code[005715] = *emul8; $inh = 0; goto &fetch; }
$core[005700] = 04315; $code[005700] = *I05700; sub I05700 { $core[005715] = 05701; $pc = 005715+1; $code[005715] = *emul8; $inh = 0; goto &fetch; }
$core[005701] = 04333; $code[005701] = *I05701; sub I05701 { $core[005733] = 05702; $pc = 005733+1; $code[005733] = *emul8; $inh = 0; goto &fetch; }
$core[005702] = 04315; $code[005702] = *I05702; sub I05702 { $core[005715] = 05703; $pc = 005715+1; $code[005715] = *emul8; $inh = 0; goto &fetch; }
$core[005703] = 01313; $code[005703] = *I05703; sub I05703 { $lac += $core[005713]; goto &fetch; }
$core[005704] = 03043; $code[005704] = *I05704; sub I05704 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[005705] = 03042; $code[005705] = *I05705; sub I05705 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[005706] = 03041; $code[005706] = *I05706; sub I05706 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[005707] = 04333; $code[005707] = *I05707; sub I05707 { $core[005733] = 05710; $pc = 005733+1; $code[005733] = *emul8; $inh = 0; goto &fetch; }
$core[005710] = 01312; $code[005710] = *I05710; sub I05710 { $lac += $core[005712]; goto &fetch; }
$core[005711] = 05667; $code[005711] = *I05711; sub I05711 { $pc = ($ib<<12)+$core[2999]; $inh = 0; goto &fetch; }
$core[005712] = 00000; $code[005712] = *D05712; sub D05712 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005713] = 00000; $code[005713] = *D05713; sub D05713 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005714] = 00000; $code[005714] = *D05714; sub D05714 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005715] = 00000; $code[005715] = *S05715; sub S05715 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005716] = 01047; $code[005716] = *I05716; sub I05716 { $lac += $core[000047]; goto &fetch; }
$core[005717] = 07104; $code[005717] = *I05717; sub I05717 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005720] = 03047; $code[005720] = *I05720; sub I05720 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[005721] = 01046; $code[005721] = *I05721; sub I05721 { $lac += $core[000046]; goto &fetch; }
$core[005722] = 07004; $code[005722] = *I05722; sub I05722 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005723] = 03046; $code[005723] = *I05723; sub I05723 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[005724] = 01045; $code[005724] = *I05724; sub I05724 { $lac += $core[000045]; goto &fetch; }
$core[005725] = 07004; $code[005725] = *I05725; sub I05725 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005726] = 03045; $code[005726] = *I05726; sub I05726 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[005727] = 01312; $code[005727] = *I05727; sub I05727 { $lac += $core[005712]; goto &fetch; }
$core[005730] = 07004; $code[005730] = *I05730; sub I05730 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005731] = 03312; $code[005731] = *I05731; sub I05731 { $core[005712] = $lac & 07777; $lac &= 010000; $code[005712] = *emul8; goto &fetch; }
$core[005732] = 05715; $code[005732] = *I05732; sub I05732 { $pc = ($ib<<12)+$core[3021]; $inh = 0; goto &fetch; }
$core[005733] = 00000; $code[005733] = *S05733; sub S05733 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005734] = 07300; $code[005734] = *I05734; sub I05734 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005735] = 01047; $code[005735] = *I05735; sub I05735 { $lac += $core[000047]; goto &fetch; }
$core[005736] = 01043; $code[005736] = *I05736; sub I05736 { $lac += $core[000043]; goto &fetch; }
$core[005737] = 03047; $code[005737] = *I05737; sub I05737 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[005740] = 07004; $code[005740] = *I05740; sub I05740 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005741] = 01046; $code[005741] = *I05741; sub I05741 { $lac += $core[000046]; goto &fetch; }
$core[005742] = 01042; $code[005742] = *I05742; sub I05742 { $lac += $core[000042]; goto &fetch; }
$core[005743] = 03046; $code[005743] = *I05743; sub I05743 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[005744] = 07004; $code[005744] = *I05744; sub I05744 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005745] = 01045; $code[005745] = *I05745; sub I05745 { $lac += $core[000045]; goto &fetch; }
$core[005746] = 01041; $code[005746] = *I05746; sub I05746 { $lac += $core[000041]; goto &fetch; }
$core[005747] = 03045; $code[005747] = *I05747; sub I05747 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[005750] = 07004; $code[005750] = *I05750; sub I05750 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[005751] = 01312; $code[005751] = *I05751; sub I05751 { $lac += $core[005712]; goto &fetch; }
$core[005752] = 03312; $code[005752] = *I05752; sub I05752 { $core[005712] = $lac & 07777; $lac &= 010000; $code[005712] = *emul8; goto &fetch; }
$core[005753] = 05733; $code[005753] = *I05753; sub I05753 { $pc = ($ib<<12)+$core[3035]; $inh = 0; goto &fetch; }
$core[005754] = 00000; $code[005754] = *S05754; sub S05754 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[005755] = 07300; $code[005755] = *I05755; sub I05755 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[005756] = 01041; $code[005756] = *P05756; sub P05756 { $lac += $core[000041]; goto &fetch; }
$core[005757] = 07510; $code[005757] = *I05757; sub I05757 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[005760] = 07120; $code[005760] = *I05760; sub I05760 { $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[005761] = 07010; $code[005761] = *I05761; sub I05761 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005762] = 03041; $code[005762] = *I05762; sub I05762 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[005763] = 01042; $code[005763] = *I05763; sub I05763 { $lac += $core[000042]; goto &fetch; }
$core[005764] = 07010; $code[005764] = *I05764; sub I05764 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005765] = 03042; $code[005765] = *I05765; sub I05765 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[005766] = 01043; $code[005766] = *I05766; sub I05766 { $lac += $core[000043]; goto &fetch; }
$core[005767] = 07010; $code[005767] = *I05767; sub I05767 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[005770] = 03043; $code[005770] = *I05770; sub I05770 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[005771] = 02040; $code[005771] = *I05771; sub I05771 { if (++$core[000040] == 010000) { $core[000040] = 0; $pc++; }$code[000040] = *emul8; goto &fetch; }
$core[005772] = 05754; $code[005772] = *I05772; sub I05772 { $pc = ($ib<<12)+$core[3052]; $inh = 0; goto &fetch; }
$core[005773] = 05754; $code[005773] = *I05773; sub I05773 { $pc = ($ib<<12)+$core[3052]; $inh = 0; goto &fetch; }
$core[006000] = 00000; $code[006000] = *S06000; sub S06000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006001] = 01335; $code[006001] = *I06001; sub I06001 { $lac += $core[006135]; goto &fetch; }
$core[006002] = 04551; $code[006002] = *I06002; sub I06002 { $core[($ib<<12)+$core[105]] = 06003; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[006003] = 01045; $code[006003] = *I06003; sub I06003 { $lac += $core[000045]; goto &fetch; }
$core[006004] = 07700; $code[006004] = *I06004; sub I06004 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006005] = 01334; $code[006005] = *I06005; sub I06005 { $lac += $core[006134]; goto &fetch; }
$core[006006] = 01336; $code[006006] = *I06006; sub I06006 { $lac += $core[006136]; goto &fetch; }
$core[006007] = 04551; $code[006007] = *I06007; sub I06007 { $core[($ib<<12)+$core[105]] = 06010; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[006010] = 04753; $code[006010] = *I06010; sub I06010 { $core[($ib<<12)+$core[3179]] = 06011; $pc = ($ib<<12)+$core[3179]+1; $code[($ib<<12)+$core[3179]] = *emul8; $inh = 0; goto &fetch; }
$core[006011] = 03033; $code[006011] = *L06011; sub L06011 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[006012] = 01044; $code[006012] = *I06012; sub I06012 { $lac += $core[000044]; goto &fetch; }
$core[006013] = 07510; $code[006013] = *I06013; sub I06013 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006014] = 05227; $code[006014] = *I06014; sub I06014 { $pc = 006027; $inh = 0; goto &fetch; }
$core[006015] = 07440; $code[006015] = *I06015; sub I06015 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[006016] = 01341; $code[006016] = *I06016; sub I06016 { $lac += $core[006141]; goto &fetch; }
$core[006017] = 07750; $code[006017] = *I06017; sub I06017 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006020] = 05234; $code[006020] = *I06020; sub I06020 { $pc = 006034; $inh = 0; goto &fetch; }
$core[006021] = 04407; $code[006021] = *I06021; sub I06021 { $core[($ib<<12)+$core[7]] = 06022; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[006022] = 04744; $code[006022] = *I06022; sub I06022 { &emul8; goto &fetch; }
$core[006023] = 00000; $code[006023] = *I06023; sub I06023 { &emul8; goto &fetch; }
$core[006024] = 07001; $code[006024] = *I06024; sub I06024 { $lac++; goto &fetch; }
$core[006025] = 01033; $code[006025] = *L06025; sub L06025 { $lac += $core[000033]; goto &fetch; }
$core[006026] = 05211; $code[006026] = *I06026; sub I06026 { $pc = 006011; $inh = 0; goto &fetch; }
$core[006027] = 04407; $code[006027] = *L06027; sub L06027 { $core[($ib<<12)+$core[7]] = 06030; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[006030] = 04752; $code[006030] = *I06030; sub I06030 { &emul8; goto &fetch; }
$core[006031] = 00000; $code[006031] = *I06031; sub I06031 { &emul8; goto &fetch; }
$core[006032] = 07040; $code[006032] = *I06032; sub I06032 { $lac ^= 07777; goto &fetch; }
$core[006033] = 05225; $code[006033] = *I06033; sub I06033 { $pc = 006025; $inh = 0; goto &fetch; }
$core[006034] = 03745; $code[006034] = *L06034; sub L06034 { $core[($df<<12)+$core[3173]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3173]] = *emul8; goto &fetch; }
$core[006035] = 03746; $code[006035] = *I06035; sub I06035 { $core[($df<<12)+$core[3174]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3174]] = *emul8; goto &fetch; }
$core[006036] = 01350; $code[006036] = *I06036; sub I06036 { $lac += $core[006150]; goto &fetch; }
$core[006037] = 03014; $code[006037] = *I06037; sub I06037 { $core[000014] = $lac & 07777; $lac &= 010000; $code[000014] = *emul8; goto &fetch; }
$core[006040] = 01044; $code[006040] = *I06040; sub I06040 { $lac += $core[000044]; goto &fetch; }
$core[006041] = 07140; $code[006041] = *I06041; sub I06041 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006042] = 03354; $code[006042] = *I06042; sub I06042 { $core[006154] = $lac & 07777; $lac &= 010000; $code[006154] = *emul8; goto &fetch; }
$core[006043] = 01343; $code[006043] = *I06043; sub I06043 { $lac += $core[006143]; goto &fetch; }
$core[006044] = 03044; $code[006044] = *I06044; sub I06044 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006045] = 04527; $code[006045] = *L06045; sub L06045 { $core[($ib<<12)+$core[87]] = 06046; $pc = ($ib<<12)+$core[87]+1; $code[($ib<<12)+$core[87]] = *emul8; $inh = 0; goto &fetch; }
$core[006046] = 02354; $code[006046] = *I06046; sub I06046 { if (++$core[006154] == 010000) { $core[006154] = 0; $pc++; }$code[006154] = *emul8; goto &fetch; }
$core[006047] = 05245; $code[006047] = *I06047; sub I06047 { $pc = 006045; $inh = 0; goto &fetch; }
$core[006050] = 01746; $code[006050] = *I06050; sub I06050 { $lac += $core[($df<<12)+$core[3174]]; goto &fetch; }
$core[006051] = 07450; $code[006051] = *I06051; sub I06051 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006052] = 05270; $code[006052] = *I06052; sub I06052 { $pc = 006070; $inh = 0; goto &fetch; }
$core[006053] = 01342; $code[006053] = *I06053; sub I06053 { $lac += $core[006142]; goto &fetch; }
$core[006054] = 07710; $code[006054] = *I06054; sub I06054 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006055] = 05264; $code[006055] = *D06055; sub D06055 { $pc = 006064; $inh = 0; goto &fetch; }
$core[006056] = 07001; $code[006056] = *I06056; sub I06056 { $lac++; goto &fetch; }
$core[006057] = 03414; $code[006057] = *I06057; sub I06057 { $core[000014] = 0000 if ++$core[000014] == 010000; $core[($df<<12)+$core[000014]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000014]] = *emul8; goto &fetch; }
$core[006060] = 02044; $code[006060] = *I06060; sub I06060 { if (++$core[000044] == 010000) { $core[000044] = 0; $pc++; }$code[000044] = *emul8; goto &fetch; }
$core[006061] = 01342; $code[006061] = *I06061; sub I06061 { $lac += $core[006142]; goto &fetch; }
$core[006062] = 02033; $code[006062] = *I06062; sub I06062 { if (++$core[000033] == 010000) { $core[000033] = 0; $pc++; }$code[000033] = *emul8; goto &fetch; }
$core[006063] = 07000; $code[006063] = *I06063; sub I06063 { goto &fetch; }
$core[006064] = 01746; $code[006064] = *L06064; sub L06064 { $lac += $core[($df<<12)+$core[3174]]; goto &fetch; }
$core[006065] = 02033; $code[006065] = *I06065; sub I06065 { if (++$core[000033] == 010000) { $core[000033] = 0; $pc++; }$code[000033] = *emul8; goto &fetch; }
$core[006066] = 07000; $code[006066] = *I06066; sub I06066 { goto &fetch; }
$core[006067] = 07410; $code[006067] = *P06067; sub P06067 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006070] = 04747; $code[006070] = *L06070; sub L06070 { $core[($ib<<12)+$core[3175]] = 06071; $pc = ($ib<<12)+$core[3175]+1; $code[($ib<<12)+$core[3175]] = *emul8; $inh = 0; goto &fetch; }
$core[006071] = 03414; $code[006071] = *I06071; sub I06071 { $core[000014] = 0000 if ++$core[000014] == 010000; $core[($df<<12)+$core[000014]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000014]] = *emul8; goto &fetch; }
$core[006072] = 02044; $code[006072] = *I06072; sub I06072 { if (++$core[000044] == 010000) { $core[000044] = 0; $pc++; }$code[000044] = *emul8; goto &fetch; }
$core[006073] = 05270; $code[006073] = *I06073; sub I06073 { $pc = 006070; $inh = 0; goto &fetch; }
$core[006074] = 01350; $code[006074] = *I06074; sub I06074 { $lac += $core[006150]; goto &fetch; }
$core[006075] = 03014; $code[006075] = *D06075; sub D06075 { $core[000014] = $lac & 07777; $lac &= 010000; $code[000014] = *emul8; goto &fetch; }
$core[006076] = 01343; $code[006076] = *I06076; sub I06076 { $lac += $core[006143]; goto &fetch; }
$core[006077] = 04751; $code[006077] = *I06077; sub I06077 { $core[($ib<<12)+$core[3177]] = 06100; $pc = ($ib<<12)+$core[3177]+1; $code[($ib<<12)+$core[3177]] = *emul8; $inh = 0; goto &fetch; }
$core[006100] = 05600; $code[006100] = *I06100; sub I06100 { $pc = ($ib<<12)+$core[3072]; $inh = 0; goto &fetch; }
$core[006101] = 01333; $code[006101] = *I06101; sub I06101 { $lac += $core[006133]; goto &fetch; }
$core[006102] = 04551; $code[006102] = *I06102; sub I06102 { $core[($ib<<12)+$core[105]] = 06103; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[006103] = 01033; $code[006103] = *I06103; sub I06103 { $lac += $core[000033]; goto &fetch; }
$core[006104] = 07510; $code[006104] = *I06104; sub I06104 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006105] = 07041; $code[006105] = *D06105; sub D06105 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006106] = 03045; $code[006106] = *I06106; sub I06106 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006107] = 01033; $code[006107] = *I06107; sub I06107 { $lac += $core[000033]; goto &fetch; }
$core[006110] = 07700; $code[006110] = *I06110; sub I06110 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006111] = 01111; $code[006111] = *I06111; sub I06111 { $lac += $core[000111]; goto &fetch; }
$core[006112] = 01336; $code[006112] = *P06112; sub P06112 { $lac += $core[006136]; goto &fetch; }
$core[006113] = 04551; $code[006113] = *P06113; sub P06113 { $core[($ib<<12)+$core[105]] = 06114; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[006114] = 01045; $code[006114] = *I06114; sub I06114 { $lac += $core[000045]; goto &fetch; }
$core[006115] = 02044; $code[006115] = *L06115; sub L06115 { if (++$core[000044] == 010000) { $core[000044] = 0; $pc++; }$code[000044] = *emul8; goto &fetch; }
$core[006116] = 01337; $code[006116] = *I06116; sub I06116 { $lac += $core[006137]; goto &fetch; }
$core[006117] = 07500; $code[006117] = *I06117; sub I06117 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006120] = 05315; $code[006120] = *I06120; sub I06120 { $pc = 006115; $inh = 0; goto &fetch; }
$core[006121] = 01340; $code[006121] = *I06121; sub I06121 { $lac += $core[006140]; goto &fetch; }
$core[006122] = 03045; $code[006122] = *I06122; sub I06122 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006123] = 07040; $code[006123] = *I06123; sub I06123 { $lac ^= 07777; goto &fetch; }
$core[006124] = 01044; $code[006124] = *I06124; sub I06124 { $lac += $core[000044]; goto &fetch; }
$core[006125] = 07440; $code[006125] = *I06125; sub I06125 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[006126] = 04354; $code[006126] = *I06126; sub I06126 { $core[006154] = 06127; $pc = 006154+1; $code[006154] = *emul8; $inh = 0; goto &fetch; }
$core[006127] = 01045; $code[006127] = *I06127; sub I06127 { $lac += $core[000045]; goto &fetch; }
$core[006130] = 04732; $code[006130] = *I06130; sub I06130 { $core[($ib<<12)+$core[3162]] = 06131; $pc = ($ib<<12)+$core[3162]+1; $code[($ib<<12)+$core[3162]] = *emul8; $inh = 0; goto &fetch; }
$core[006131] = 05600; $code[006131] = *I06131; sub I06131 { $pc = ($ib<<12)+$core[3072]; $inh = 0; goto &fetch; }
$core[006132] = 02442; $code[006132] = *P06132; sub P06132 { if (++$core[($df<<12)+$core[34]] == 010000) { $core[($df<<12)+$core[34]] = 0; $pc++; }$code[($df<<12)+$core[34]] = *emul8; goto &fetch; }
$core[006133] = 00305; $code[006133] = *D06133; sub D06133 { $lac &= (010000|$core[006105]); goto &fetch; }
$core[006134] = 07763; $code[006134] = *D06134; sub D06134 { &emul8; goto &fetch; }
$core[006135] = 00275; $code[006135] = *D06135; sub D06135 { $lac &= (010000|$core[006075]); goto &fetch; }
$core[006136] = 00255; $code[006136] = *D06136; sub D06136 { $lac &= (010000|$core[006055]); goto &fetch; }
$core[006137] = 07634; $code[006137] = *D06137; sub D06137 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006140] = 00144; $code[006140] = *D06140; sub D06140 { $lac &= (010000|$core[000144]); goto &fetch; }
$core[006141] = 07774; $code[006141] = *D06141; sub D06141 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006142] = 07766; $code[006142] = *D06142; sub D06142 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[006143] = 07771; $code[006143] = *D06143; sub D06143 { &emul8; goto &fetch; }
$core[006144] = 06275; $code[006144] = *P06144; sub P06144 { &emul8; goto &fetch; }
$core[006145] = 05713; $code[006145] = *P06145; sub P06145 { $pc = ($ib<<12)+$core[3147]; $inh = 0; goto &fetch; }
$core[006146] = 05712; $code[006146] = *P06146; sub P06146 { $pc = ($ib<<12)+$core[3146]; $inh = 0; goto &fetch; }
$core[006147] = 05667; $code[006147] = *P06147; sub P06147 { $pc = ($ib<<12)+$core[3127]; $inh = 0; goto &fetch; }
$core[006150] = 07467; $code[006150] = *D06150; sub D06150 { &emul8; goto &fetch; }
$core[006151] = 05400; $code[006151] = *P06151; sub P06151 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[006152] = 06271; $code[006152] = *P06152; sub P06152 { &emul8; goto &fetch; }
$core[006153] = 05571; $code[006153] = *P06153; sub P06153 { $pc = ($ib<<12)+$core[121]; $inh = 0; goto &fetch; }
$core[006154] = 00000; $code[006154] = *S06154; sub S06154 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006155] = 01113; $code[006155] = *I06155; sub I06155 { $lac += $core[000113]; goto &fetch; }
$core[006156] = 04551; $code[006156] = *L06156; sub L06156 { $core[($ib<<12)+$core[105]] = 06157; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[006157] = 05754; $code[006157] = *I06157; sub I06157 { $pc = ($ib<<12)+$core[3180]; $inh = 0; goto &fetch; }
$core[006200] = 00000; $code[006200] = *S06200; sub S06200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006201] = 07640; $code[006201] = *I06201; sub I06201 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006202] = 04706; $code[006202] = *L06202; sub L06202 { $core[($ib<<12)+$core[3270]] = 06203; $pc = ($ib<<12)+$core[3270]+1; $code[($ib<<12)+$core[3270]] = *emul8; $inh = 0; goto &fetch; }
$core[006203] = 01066; $code[006203] = *I06203; sub I06203 { $lac += $core[000066]; goto &fetch; }
$core[006204] = 01114; $code[006204] = *I06204; sub I06204 { $lac += $core[000114]; goto &fetch; }
$core[006205] = 07650; $code[006205] = *I06205; sub I06205 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006206] = 05202; $code[006206] = *I06206; sub I06206 { $pc = 006202; $inh = 0; goto &fetch; }
$core[006207] = 04702; $code[006207] = *I06207; sub I06207 { $core[($ib<<12)+$core[3266]] = 06210; $pc = ($ib<<12)+$core[3266]+1; $code[($ib<<12)+$core[3266]] = *emul8; $inh = 0; goto &fetch; }
$core[006210] = 01066; $code[006210] = *I06210; sub I06210 { $lac += $core[000066]; goto &fetch; }
$core[006211] = 01115; $code[006211] = *P06211; sub P06211 { $lac += $core[000115]; goto &fetch; }
$core[006212] = 07640; $code[006212] = *D06212; sub D06212 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006213] = 05221; $code[006213] = *I06213; sub I06213 { $pc = 006221; $inh = 0; goto &fetch; }
$core[006214] = 04706; $code[006214] = *I06214; sub I06214 { $core[($ib<<12)+$core[3270]] = 06215; $pc = ($ib<<12)+$core[3270]+1; $code[($ib<<12)+$core[3270]] = *emul8; $inh = 0; goto &fetch; }
$core[006215] = 03705; $code[006215] = *I06215; sub I06215 { $core[($df<<12)+$core[3269]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3269]] = *emul8; goto &fetch; }
$core[006216] = 04703; $code[006216] = *I06216; sub I06216 { $core[($ib<<12)+$core[3267]] = 06217; $pc = ($ib<<12)+$core[3267]+1; $code[($ib<<12)+$core[3267]] = *emul8; $inh = 0; goto &fetch; }
$core[006217] = 01705; $code[006217] = *I06217; sub I06217 { $lac += $core[($df<<12)+$core[3269]]; goto &fetch; }
$core[006220] = 07041; $code[006220] = *I06220; sub I06220 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006221] = 03033; $code[006221] = *L06221; sub L06221 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[006222] = 01310; $code[006222] = *I06222; sub I06222 { $lac += $core[006310]; goto &fetch; }
$core[006223] = 03044; $code[006223] = *I06223; sub I06223 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006224] = 04704; $code[006224] = *I06224; sub I06224 { $core[($ib<<12)+$core[3268]] = 06225; $pc = ($ib<<12)+$core[3268]+1; $code[($ib<<12)+$core[3268]] = *emul8; $inh = 0; goto &fetch; }
$core[006225] = 04707; $code[006225] = *I06225; sub I06225 { $core[($ib<<12)+$core[3271]] = 06226; $pc = ($ib<<12)+$core[3271]+1; $code[($ib<<12)+$core[3271]] = *emul8; $inh = 0; goto &fetch; }
$core[006226] = 04407; $code[006226] = *I06226; sub I06226 { $core[($ib<<12)+$core[7]] = 06227; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[006227] = 06430; $code[006227] = *P06227; sub P06227 { &emul8; goto &fetch; }
$core[006230] = 00000; $code[006230] = *I06230; sub I06230 { &emul8; goto &fetch; }
$core[006231] = 01066; $code[006231] = *I06231; sub I06231 { $lac += $core[000066]; goto &fetch; }
$core[006232] = 01301; $code[006232] = *I06232; sub I06232 { $lac += $core[006301]; goto &fetch; }
$core[006233] = 07640; $code[006233] = *I06233; sub I06233 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006234] = 05246; $code[006234] = *I06234; sub I06234 { $pc = 006246; $inh = 0; goto &fetch; }
$core[006235] = 04706; $code[006235] = *I06235; sub I06235 { $core[($ib<<12)+$core[3270]] = 06236; $pc = ($ib<<12)+$core[3270]+1; $code[($ib<<12)+$core[3270]] = *emul8; $inh = 0; goto &fetch; }
$core[006236] = 04702; $code[006236] = *I06236; sub I06236 { $core[($ib<<12)+$core[3266]] = 06237; $pc = ($ib<<12)+$core[3266]+1; $code[($ib<<12)+$core[3266]] = *emul8; $inh = 0; goto &fetch; }
$core[006237] = 04704; $code[006237] = *I06237; sub I06237 { $core[($ib<<12)+$core[3268]] = 06240; $pc = ($ib<<12)+$core[3268]+1; $code[($ib<<12)+$core[3268]] = *emul8; $inh = 0; goto &fetch; }
$core[006240] = 01047; $code[006240] = *I06240; sub I06240 { $lac += $core[000047]; goto &fetch; }
$core[006241] = 01033; $code[006241] = *I06241; sub I06241 { $lac += $core[000033]; goto &fetch; }
$core[006242] = 03033; $code[006242] = *I06242; sub I06242 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[006243] = 04407; $code[006243] = *I06243; sub I06243 { $core[($ib<<12)+$core[7]] = 06244; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[006244] = 00430; $code[006244] = *I06244; sub I06244 { &emul8; goto &fetch; }
$core[006245] = 00000; $code[006245] = *I06245; sub I06245 { &emul8; goto &fetch; }
$core[006246] = 01033; $code[006246] = *L06246; sub L06246 { $lac += $core[000033]; goto &fetch; }
$core[006247] = 07450; $code[006247] = *I06247; sub I06247 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006250] = 05600; $code[006250] = *I06250; sub I06250 { $pc = ($ib<<12)+$core[3200]; $inh = 0; goto &fetch; }
$core[006251] = 07700; $code[006251] = *I06251; sub I06251 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006252] = 05261; $code[006252] = *I06252; sub I06252 { $pc = 006261; $inh = 0; goto &fetch; }
$core[006253] = 04407; $code[006253] = *I06253; sub I06253 { $core[($ib<<12)+$core[7]] = 06254; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[006254] = 04275; $code[006254] = *I06254; sub I06254 { &emul8; goto &fetch; }
$core[006255] = 06430; $code[006255] = *I06255; sub I06255 { &emul8; goto &fetch; }
$core[006256] = 00000; $code[006256] = *I06256; sub I06256 { &emul8; goto &fetch; }
$core[006257] = 07001; $code[006257] = *I06257; sub I06257 { $lac++; goto &fetch; }
$core[006260] = 05266; $code[006260] = *I06260; sub I06260 { $pc = 006266; $inh = 0; goto &fetch; }
$core[006261] = 04407; $code[006261] = *L06261; sub L06261 { $core[($ib<<12)+$core[7]] = 06262; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[006262] = 04271; $code[006262] = *I06262; sub I06262 { &emul8; goto &fetch; }
$core[006263] = 06430; $code[006263] = *I06263; sub I06263 { &emul8; goto &fetch; }
$core[006264] = 00000; $code[006264] = *I06264; sub I06264 { &emul8; goto &fetch; }
$core[006265] = 07040; $code[006265] = *I06265; sub I06265 { $lac ^= 07777; goto &fetch; }
$core[006266] = 01033; $code[006266] = *L06266; sub L06266 { $lac += $core[000033]; goto &fetch; }
$core[006267] = 03033; $code[006267] = *I06267; sub I06267 { $core[000033] = $lac & 07777; $lac &= 010000; $code[000033] = *emul8; goto &fetch; }
$core[006270] = 05246; $code[006270] = *I06270; sub I06270 { $pc = 006246; $inh = 0; goto &fetch; }
$core[006271] = 00004; $code[006271] = *D06271; sub D06271 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[006272] = 02400; $code[006272] = *I06272; sub I06272 { if (++$core[($df<<12)+$core[0]] == 010000) { $core[($df<<12)+$core[0]] = 0; $pc++; }$code[($df<<12)+$core[0]] = *emul8; goto &fetch; }
$core[006273] = 00000; $code[006273] = *I06273; sub I06273 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006274] = 00000; $code[006274] = *I06274; sub I06274 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006275] = 07775; $code[006275] = *D06275; sub D06275 { &emul8; goto &fetch; }
$core[006276] = 03146; $code[006276] = *I06276; sub I06276 { $core[000146] = $lac & 07777; $lac &= 010000; $code[000146] = *emul8; goto &fetch; }
$core[006277] = 03147; $code[006277] = *I06277; sub I06277 { $core[000147] = $lac & 07777; $lac &= 010000; $code[000147] = *emul8; goto &fetch; }
$core[006300] = 03150; $code[006300] = *I06300; sub I06300 { $core[000150] = $lac & 07777; $lac &= 010000; $code[000150] = *emul8; goto &fetch; }
$core[006301] = 07473; $code[006301] = *D06301; sub D06301 { &emul8; goto &fetch; }
$core[006302] = 05600; $code[006302] = *P06302; sub P06302 { $pc = ($ib<<12)+$core[3200]; $inh = 0; goto &fetch; }
$core[006303] = 05627; $code[006303] = *P06303; sub P06303 { $pc = ($ib<<12)+$core[3223]; $inh = 0; goto &fetch; }
$core[006304] = 07173; $code[006304] = *P06304; sub P06304 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006305] = 05714; $code[006305] = *P06305; sub P06305 { $pc = ($ib<<12)+$core[3276]; $inh = 0; goto &fetch; }
$core[006306] = 00756; $code[006306] = *P06306; sub P06306 { $lac &= (010000|$core[($df<<12)+$core[3310]]); goto &fetch; }
$core[006307] = 07335; $code[006307] = *P06307; sub P06307 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006310] = 00043; $code[006310] = *D06310; sub D06310 { $lac &= (010000|$core[000043]); goto &fetch; }
$core[006321] = 00000; $code[006321] = *P06321; sub P06321 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006322] = 01105; $code[006322] = *L06322; sub L06322 { $lac += $core[000105]; goto &fetch; }
$core[006323] = 03343; $code[006323] = *I06323; sub I06323 { $core[006343] = $lac & 07777; $lac &= 010000; $code[006343] = *emul8; goto &fetch; }
$core[006324] = 01037; $code[006324] = *L06324; sub L06324 { $lac += $core[000037]; goto &fetch; }
$core[006325] = 07700; $code[006325] = *I06325; sub I06325 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006326] = 05364; $code[006326] = *D06326; sub D06326 { $pc = 006364; $inh = 0; goto &fetch; }
$core[006327] = 02032; $code[006327] = *I06327; sub I06327 { if (++$core[000032] == 010000) { $core[000032] = 0; $pc++; }$code[000032] = *emul8; goto &fetch; }
$core[006330] = 05324; $code[006330] = *I06330; sub I06330 { $pc = 006324; $inh = 0; goto &fetch; }
$core[006331] = 02343; $code[006331] = *I06331; sub I06331 { if (++$core[006343] == 010000) { $core[006343] = 0; $pc++; }$code[006343] = *emul8; goto &fetch; }
$core[006332] = 05324; $code[006332] = *I06332; sub I06332 { $pc = 006324; $inh = 0; goto &fetch; }
$core[006333] = 04343; $code[006333] = *I06333; sub I06333 { $core[006343] = 06334; $pc = 006343+1; $code[006343] = *emul8; $inh = 0; goto &fetch; }
$core[006334] = 01013; $code[006334] = *I06334; sub I06334 { $lac += $core[000013]; goto &fetch; }
$core[006335] = 01376; $code[006335] = *I06335; sub I06335 { $lac += $core[006376]; goto &fetch; }
$core[006336] = 07620; $code[006336] = *I06336; sub I06336 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006337] = 05742; $code[006337] = *I06337; sub I06337 { $pc = ($ib<<12)+$core[3298]; $inh = 0; goto &fetch; }
$core[006340] = 02013; $code[006340] = *I06340; sub I06340 { if (++$core[000013] == 010000) { $core[000013] = 0; $pc++; }$code[000013] = *emul8; goto &fetch; }
$core[006341] = 05541; $code[006341] = *I06341; sub I06341 { $pc = ($ib<<12)+$core[97]; $inh = 0; goto &fetch; }
$core[006342] = 00212; $code[006342] = *P06342; sub P06342 { $lac &= (010000|$core[006212]); goto &fetch; }
$core[006343] = 00000; $code[006343] = *S06343; sub S06343 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006344] = 01375; $code[006344] = *I06344; sub I06344 { $lac += $core[006375]; goto &fetch; }
$core[006345] = 07040; $code[006345] = *I06345; sub I06345 { $lac ^= 07777; goto &fetch; }
$core[006346] = 03375; $code[006346] = *I06346; sub I06346 { $core[006375] = $lac & 07777; $lac &= 010000; $code[006375] = *emul8; goto &fetch; }
$core[006347] = 07140; $code[006347] = *I06347; sub I06347 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006350] = 03037; $code[006350] = *I06350; sub I06350 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[006351] = 01375; $code[006351] = *I06351; sub I06351 { $lac += $core[006375]; goto &fetch; }
$core[006352] = 07440; $code[006352] = *I06352; sub I06352 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[006353] = 06014; $code[006353] = *I06353; sub I06353 { &emul8; goto &fetch; }
$core[006354] = 07640; $code[006354] = *I06354; sub I06354 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006355] = 01377; $code[006355] = *I06355; sub I06355 { $lac += $core[006377]; goto &fetch; }
$core[006356] = 01126; $code[006356] = *P06356; sub P06356 { $lac += $core[000126]; goto &fetch; }
$core[006357] = 03152; $code[006357] = *I06357; sub I06357 { $core[000152] = $lac & 07777; $lac &= 010000; $code[000152] = *emul8; goto &fetch; }
$core[006360] = 05743; $code[006360] = *I06360; sub I06360 { $pc = ($ib<<12)+$core[3299]; $inh = 0; goto &fetch; }
$core[006361] = 04343; $code[006361] = *I06361; sub I06361 { $core[006343] = 06362; $pc = 006343+1; $code[006343] = *emul8; $inh = 0; goto &fetch; }
$core[006362] = 05763; $code[006362] = *I06362; sub I06362 { $pc = ($ib<<12)+$core[3315]; $inh = 0; goto &fetch; }
$core[006363] = 00611; $code[006363] = *P06363; sub P06363 { $lac &= (010000|$core[($df<<12)+$core[3209]]); goto &fetch; }
$core[006364] = 07040; $code[006364] = *L06364; sub L06364 { $lac ^= 07777; goto &fetch; }
$core[006365] = 03037; $code[006365] = *I06365; sub I06365 { $core[000037] = $lac & 07777; $lac &= 010000; $code[000037] = *emul8; goto &fetch; }
$core[006366] = 06016; $code[006366] = *I06366; sub I06366 { &emul8; goto &fetch; }
$core[006367] = 00106; $code[006367] = *I06367; sub I06367 { $lac &= (010000|$core[000106]); goto &fetch; }
$core[006370] = 07450; $code[006370] = *I06370; sub I06370 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006371] = 05322; $code[006371] = *I06371; sub I06371 { $pc = 006322; $inh = 0; goto &fetch; }
$core[006372] = 01123; $code[006372] = *I06372; sub I06372 { $lac += $core[000123]; goto &fetch; }
$core[006373] = 03066; $code[006373] = *I06373; sub I06373 { $core[000066] = $lac & 07777; $lac &= 010000; $code[000066] = *emul8; goto &fetch; }
$core[006374] = 05721; $code[006374] = *I06374; sub I06374 { $pc = ($ib<<12)+$core[3281]; $inh = 0; goto &fetch; }
$core[006375] = 00000; $code[006375] = *D06375; sub D06375 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006376] = 04557; $code[006376] = *D06376; sub D06376 { $core[($ib<<12)+$core[111]] = 06377; $pc = ($ib<<12)+$core[111]+1; $code[($ib<<12)+$core[111]] = *emul8; $inh = 0; goto &fetch; }
$core[006377] = 04144; $code[006377] = *D06377; sub D06377 { $core[000144] = 06400; $pc = 000144+1; $code[000144] = *emul8; $inh = 0; goto &fetch; }
$core[006400] = 00000; $code[006400] = *S06400; sub S06400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006401] = 07300; $code[006401] = *L06401; sub L06401 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006402] = 03047; $code[006402] = *I06402; sub I06402 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[006403] = 03043; $code[006403] = *I06403; sub I06403 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006404] = 01600; $code[006404] = *I06404; sub I06404 { $lac += $core[($df<<12)+$core[3328]]; goto &fetch; }
$core[006405] = 07450; $code[006405] = *I06405; sub I06405 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006406] = 05600; $code[006406] = *I06406; sub I06406 { $pc = ($ib<<12)+$core[3328]; $inh = 0; goto &fetch; }
$core[006407] = 03262; $code[006407] = *I06407; sub I06407 { $core[006462] = $lac & 07777; $lac &= 010000; $code[006462] = *emul8; goto &fetch; }
$core[006410] = 01262; $code[006410] = *I06410; sub I06410 { $lac += $core[006462]; goto &fetch; }
$core[006411] = 00123; $code[006411] = *I06411; sub I06411 { $lac &= (010000|$core[000123]); goto &fetch; }
$core[006412] = 07650; $code[006412] = *I06412; sub I06412 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006413] = 05216; $code[006413] = *I06413; sub I06413 { $pc = 006416; $inh = 0; goto &fetch; }
$core[006414] = 01104; $code[006414] = *I06414; sub I06414 { $lac += $core[000104]; goto &fetch; }
$core[006415] = 00200; $code[006415] = *I06415; sub I06415 { $lac &= (010000|$core[006400]); goto &fetch; }
$core[006416] = 03040; $code[006416] = *L06416; sub L06416 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[006417] = 01106; $code[006417] = *I06417; sub I06417 { $lac += $core[000106]; goto &fetch; }
$core[006420] = 00262; $code[006420] = *I06420; sub I06420 { $lac &= (010000|$core[006462]); goto &fetch; }
$core[006421] = 01040; $code[006421] = *I06421; sub I06421 { $lac += $core[000040]; goto &fetch; }
$core[006422] = 03040; $code[006422] = *I06422; sub I06422 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[006423] = 01263; $code[006423] = *I06423; sub I06423 { $lac += $core[006463]; goto &fetch; }
$core[006424] = 00262; $code[006424] = *I06424; sub I06424 { $lac &= (010000|$core[006462]); goto &fetch; }
$core[006425] = 07650; $code[006425] = *I06425; sub I06425 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006426] = 05231; $code[006426] = *I06426; sub I06426 { $pc = 006431; $inh = 0; goto &fetch; }
$core[006427] = 01440; $code[006427] = *I06427; sub I06427 { $lac += $core[($df<<12)+$core[32]]; goto &fetch; }
$core[006430] = 03040; $code[006430] = *L06430; sub L06430 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[006431] = 02200; $code[006431] = *L06431; sub L06431 { if (++$core[006400] == 010000) { $core[006400] = 0; $pc++; }$code[006400] = *emul8; goto &fetch; }
$core[006432] = 07040; $code[006432] = *I06432; sub I06432 { $lac ^= 07777; goto &fetch; }
$core[006433] = 01040; $code[006433] = *I06433; sub I06433 { $lac += $core[000040]; goto &fetch; }
$core[006434] = 03015; $code[006434] = *I06434; sub I06434 { $core[000015] = $lac & 07777; $lac &= 010000; $code[000015] = *emul8; goto &fetch; }
$core[006435] = 01262; $code[006435] = *I06435; sub I06435 { $lac += $core[006462]; goto &fetch; }
$core[006436] = 07106; $code[006436] = *I06436; sub I06436 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[006437] = 07006; $code[006437] = *I06437; sub I06437 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[006440] = 00107; $code[006440] = *I06440; sub I06440 { $lac &= (010000|$core[000107]); goto &fetch; }
$core[006441] = 07450; $code[006441] = *I06441; sub I06441 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006442] = 05267; $code[006442] = *I06442; sub I06442 { $pc = 006467; $inh = 0; goto &fetch; }
$core[006443] = 01264; $code[006443] = *I06443; sub I06443 { $lac += $core[006464]; goto &fetch; }
$core[006444] = 03262; $code[006444] = *I06444; sub I06444 { $core[006462] = $lac & 07777; $lac &= 010000; $code[006462] = *emul8; goto &fetch; }
$core[006445] = 01662; $code[006445] = *I06445; sub I06445 { $lac += $core[($df<<12)+$core[3378]]; goto &fetch; }
$core[006446] = 07450; $code[006446] = *I06446; sub I06446 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006447] = 05265; $code[006447] = *I06447; sub I06447 { $pc = 006465; $inh = 0; goto &fetch; }
$core[006450] = 03262; $code[006450] = *I06450; sub I06450 { $core[006462] = $lac & 07777; $lac &= 010000; $code[006462] = *emul8; goto &fetch; }
$core[006451] = 01304; $code[006451] = *I06451; sub I06451 { $lac += $core[006504]; goto &fetch; }
$core[006452] = 03014; $code[006452] = *I06452; sub I06452 { $core[000014] = $lac & 07777; $lac &= 010000; $code[000014] = *emul8; goto &fetch; }
$core[006453] = 01117; $code[006453] = *I06453; sub I06453 { $lac += $core[000117]; goto &fetch; }
$core[006454] = 03057; $code[006454] = *I06454; sub I06454 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[006455] = 01415; $code[006455] = *L06455; sub L06455 { $core[000015] = 0000 if ++$core[000015] == 010000; $lac += $core[($df<<12)+$core[000015]]; goto &fetch; }
$core[006456] = 03414; $code[006456] = *I06456; sub I06456 { $core[000014] = 0000 if ++$core[000014] == 010000; $core[($df<<12)+$core[000014]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000014]] = *emul8; goto &fetch; }
$core[006457] = 02057; $code[006457] = *I06457; sub I06457 { if (++$core[000057] == 010000) { $core[000057] = 0; $pc++; }$code[000057] = *emul8; goto &fetch; }
$core[006460] = 05255; $code[006460] = *I06460; sub I06460 { $pc = 006455; $inh = 0; goto &fetch; }
$core[006461] = 05662; $code[006461] = *I06461; sub I06461 { $pc = ($ib<<12)+$core[3378]; $inh = 0; goto &fetch; }
$core[006462] = 00000; $code[006462] = *P06462; sub P06462 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006463] = 00400; $code[006463] = *D06463; sub D06463 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[006464] = 06573; $code[006464] = *D06464; sub D06464 { &emul8; goto &fetch; }
$core[006465] = 01303; $code[006465] = *L06465; sub L06465 { $lac += $core[006503]; goto &fetch; }
$core[006466] = 05273; $code[006466] = *I06466; sub I06466 { $pc = 006473; $inh = 0; goto &fetch; }
$core[006467] = 01303; $code[006467] = *L06467; sub L06467 { $lac += $core[006503]; goto &fetch; }
$core[006470] = 03015; $code[006470] = *I06470; sub I06470 { $core[000015] = $lac & 07777; $lac &= 010000; $code[000015] = *emul8; goto &fetch; }
$core[006471] = 07040; $code[006471] = *I06471; sub I06471 { $lac ^= 07777; goto &fetch; }
$core[006472] = 01040; $code[006472] = *I06472; sub I06472 { $lac += $core[000040]; goto &fetch; }
$core[006473] = 03014; $code[006473] = *L06473; sub L06473 { $core[000014] = $lac & 07777; $lac &= 010000; $code[000014] = *emul8; goto &fetch; }
$core[006474] = 01117; $code[006474] = *I06474; sub I06474 { $lac += $core[000117]; goto &fetch; }
$core[006475] = 03057; $code[006475] = *I06475; sub I06475 { $core[000057] = $lac & 07777; $lac &= 010000; $code[000057] = *emul8; goto &fetch; }
$core[006476] = 01414; $code[006476] = *L06476; sub L06476 { $core[000014] = 0000 if ++$core[000014] == 010000; $lac += $core[($df<<12)+$core[000014]]; goto &fetch; }
$core[006477] = 03415; $code[006477] = *I06477; sub I06477 { $core[000015] = 0000 if ++$core[000015] == 010000; $core[($df<<12)+$core[000015]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000015]] = *emul8; goto &fetch; }
$core[006500] = 02057; $code[006500] = *I06500; sub I06500 { if (++$core[000057] == 010000) { $core[000057] = 0; $pc++; }$code[000057] = *emul8; goto &fetch; }
$core[006501] = 05276; $code[006501] = *I06501; sub I06501 { $pc = 006476; $inh = 0; goto &fetch; }
$core[006502] = 05201; $code[006502] = *I06502; sub I06502 { $pc = 006401; $inh = 0; goto &fetch; }
$core[006503] = 00043; $code[006503] = *D06503; sub D06503 { $lac &= (010000|$core[000043]); goto &fetch; }
$core[006504] = 00037; $code[006504] = *D06504; sub D06504 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[006505] = 04765; $code[006505] = *I06505; sub I06505 { $core[($ib<<12)+$core[3445]] = 06506; $pc = ($ib<<12)+$core[3445]+1; $code[($ib<<12)+$core[3445]] = *emul8; $inh = 0; goto &fetch; }
$core[006506] = 04770; $code[006506] = *I06506; sub I06506 { $core[($ib<<12)+$core[3448]] = 06507; $pc = ($ib<<12)+$core[3448]+1; $code[($ib<<12)+$core[3448]] = *emul8; $inh = 0; goto &fetch; }
$core[006507] = 05201; $code[006507] = *I06507; sub I06507 { $pc = 006401; $inh = 0; goto &fetch; }
$core[006510] = 04772; $code[006510] = *I06510; sub I06510 { $core[($ib<<12)+$core[3450]] = 06511; $pc = ($ib<<12)+$core[3450]+1; $code[($ib<<12)+$core[3450]] = *emul8; $inh = 0; goto &fetch; }
$core[006511] = 04771; $code[006511] = *I06511; sub I06511 { $core[($ib<<12)+$core[3449]] = 06512; $pc = ($ib<<12)+$core[3449]+1; $code[($ib<<12)+$core[3449]] = *emul8; $inh = 0; goto &fetch; }
$core[006512] = 04773; $code[006512] = *I06512; sub I06512 { $core[($ib<<12)+$core[3451]] = 06513; $pc = ($ib<<12)+$core[3451]+1; $code[($ib<<12)+$core[3451]] = *emul8; $inh = 0; goto &fetch; }
$core[006513] = 04767; $code[006513] = *I06513; sub I06513 { $core[($ib<<12)+$core[3447]] = 06514; $pc = ($ib<<12)+$core[3447]+1; $code[($ib<<12)+$core[3447]] = *emul8; $inh = 0; goto &fetch; }
$core[006514] = 05201; $code[006514] = *I06514; sub I06514 { $pc = 006401; $inh = 0; goto &fetch; }
$core[006515] = 01045; $code[006515] = *I06515; sub I06515 { $lac += $core[000045]; goto &fetch; }
$core[006516] = 07640; $code[006516] = *I06516; sub I06516 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006517] = 05325; $code[006517] = *I06517; sub I06517 { $pc = 006525; $inh = 0; goto &fetch; }
$core[006520] = 03044; $code[006520] = *L06520; sub L06520 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006521] = 03045; $code[006521] = *I06521; sub I06521 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006522] = 03046; $code[006522] = *I06522; sub I06522 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006523] = 03047; $code[006523] = *I06523; sub I06523 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[006524] = 05201; $code[006524] = *I06524; sub I06524 { $pc = 006401; $inh = 0; goto &fetch; }
$core[006525] = 04543; $code[006525] = *L06525; sub L06525 { $core[($ib<<12)+$core[99]] = 06526; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[006526] = 00044; $code[006526] = *I06526; sub I06526 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[006527] = 04543; $code[006527] = *I06527; sub I06527 { $core[($ib<<12)+$core[99]] = 06530; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[006530] = 00040; $code[006530] = *I06530; sub I06530 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[006531] = 04544; $code[006531] = *I06531; sub I06531 { $core[($ib<<12)+$core[100]] = 06532; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[006532] = 00044; $code[006532] = *I06532; sub I06532 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[006533] = 04453; $code[006533] = *P06533; sub P06533 { $core[($ib<<12)+$core[43]] = 06534; $pc = ($ib<<12)+$core[43]+1; $code[($ib<<12)+$core[43]] = *emul8; $inh = 0; goto &fetch; }
$core[006534] = 07510; $code[006534] = *I06534; sub I06534 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006535] = 05342; $code[006535] = *I06535; sub I06535 { $pc = 006542; $inh = 0; goto &fetch; }
$core[006536] = 07040; $code[006536] = *I06536; sub I06536 { $lac ^= 07777; goto &fetch; }
$core[006537] = 03262; $code[006537] = *I06537; sub I06537 { $core[006462] = $lac & 07777; $lac &= 010000; $code[006462] = *emul8; goto &fetch; }
$core[006540] = 03043; $code[006540] = *I06540; sub I06540 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006541] = 01045; $code[006541] = *I06541; sub I06541 { $lac += $core[000045]; goto &fetch; }
$core[006542] = 07640; $code[006542] = *L06542; sub L06542 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006543] = 04566; $code[006543] = *I06543; sub I06543 { $core[($ib<<12)+$core[118]] = 06544; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[006544] = 04543; $code[006544] = *I06544; sub I06544 { $core[($ib<<12)+$core[99]] = 06545; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[006545] = 02405; $code[006545] = *I06545; sub I06545 { if (++$core[($df<<12)+$core[5]] == 010000) { $core[($df<<12)+$core[5]] = 0; $pc++; }$code[($df<<12)+$core[5]] = *emul8; goto &fetch; }
$core[006546] = 04544; $code[006546] = *I06546; sub I06546 { $core[($ib<<12)+$core[100]] = 06547; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[006547] = 00044; $code[006547] = *I06547; sub I06547 { $lac &= (010000|$core[000044]); goto &fetch; }
$core[006550] = 04544; $code[006550] = *I06550; sub I06550 { $core[($ib<<12)+$core[100]] = 06551; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[006551] = 07470; $code[006551] = *I06551; sub I06551 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006552] = 05360; $code[006552] = *I06552; sub I06552 { $pc = 006560; $inh = 0; goto &fetch; }
$core[006553] = 04543; $code[006553] = *L06553; sub L06553 { $core[($ib<<12)+$core[99]] = 06554; $pc = ($ib<<12)+$core[99]+1; $code[($ib<<12)+$core[99]] = *emul8; $inh = 0; goto &fetch; }
$core[006554] = 07470; $code[006554] = *P06554; sub P06554 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006555] = 04544; $code[006555] = *I06555; sub I06555 { $core[($ib<<12)+$core[100]] = 06556; $pc = ($ib<<12)+$core[100]+1; $code[($ib<<12)+$core[100]] = *emul8; $inh = 0; goto &fetch; }
$core[006556] = 00040; $code[006556] = *I06556; sub I06556 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[006557] = 04766; $code[006557] = *I06557; sub I06557 { $core[($ib<<12)+$core[3446]] = 06560; $pc = ($ib<<12)+$core[3446]+1; $code[($ib<<12)+$core[3446]] = *emul8; $inh = 0; goto &fetch; }
$core[006560] = 02262; $code[006560] = *L06560; sub L06560 { if (++$core[006462] == 010000) { $core[006462] = 0; $pc++; }$code[006462] = *emul8; goto &fetch; }
$core[006561] = 05353; $code[006561] = *I06561; sub I06561 { $pc = 006553; $inh = 0; goto &fetch; }
$core[006562] = 05201; $code[006562] = *I06562; sub I06562 { $pc = 006401; $inh = 0; goto &fetch; }
$core[006563] = 04766; $code[006563] = *I06563; sub I06563 { $core[($ib<<12)+$core[3446]] = 06564; $pc = ($ib<<12)+$core[3446]+1; $code[($ib<<12)+$core[3446]] = *emul8; $inh = 0; goto &fetch; }
$core[006564] = 05201; $code[006564] = *I06564; sub I06564 { $pc = 006401; $inh = 0; goto &fetch; }
$core[006565] = 07153; $code[006565] = *P06565; sub P06565 { $lac &= 07777; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006566] = 07004; $code[006566] = *P06566; sub P06566 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[006567] = 07335; $code[006567] = *P06567; sub P06567 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006570] = 06623; $code[006570] = *P06570; sub P06570 { &emul8; goto &fetch; }
$core[006571] = 05754; $code[006571] = *P06571; sub P06571 { $pc = ($ib<<12)+$core[3436]; $inh = 0; goto &fetch; }
$core[006572] = 06757; $code[006572] = *P06572; sub P06572 { &emul8; goto &fetch; }
$core[006573] = 05733; $code[006573] = *P06573; sub P06573 { $pc = ($ib<<12)+$core[3419]; $inh = 0; goto &fetch; }
$core[006574] = 06506; $code[006574] = *I06574; sub I06574 { &emul8; goto &fetch; }
$core[006575] = 06505; $code[006575] = *I06575; sub I06575 { &emul8; goto &fetch; }
$core[006576] = 07107; $code[006576] = *I06576; sub I06576 { $lac &= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[006577] = 06563; $code[006577] = *I06577; sub I06577 { &emul8; goto &fetch; }
$core[006600] = 06515; $code[006600] = *I06600; sub I06600 { &emul8; goto &fetch; }
$core[006601] = 00000; $code[006601] = *I06601; sub I06601 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006602] = 06513; $code[006602] = *I06602; sub I06602 { &emul8; goto &fetch; }
$core[006603] = 00000; $code[006603] = *S06603; sub S06603 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006604] = 07300; $code[006604] = *I06604; sub I06604 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006605] = 01047; $code[006605] = *I06605; sub I06605 { $lac += $core[000047]; goto &fetch; }
$core[006606] = 07041; $code[006606] = *I06606; sub I06606 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006607] = 03047; $code[006607] = *I06607; sub I06607 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[006610] = 01046; $code[006610] = *I06610; sub I06610 { $lac += $core[000046]; goto &fetch; }
$core[006611] = 07040; $code[006611] = *I06611; sub I06611 { $lac ^= 07777; goto &fetch; }
$core[006612] = 07430; $code[006612] = *I06612; sub I06612 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006613] = 07101; $code[006613] = *I06613; sub I06613 { $lac &= 07777; $lac++; goto &fetch; }
$core[006614] = 03046; $code[006614] = *I06614; sub I06614 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006615] = 01045; $code[006615] = *I06615; sub I06615 { $lac += $core[000045]; goto &fetch; }
$core[006616] = 07040; $code[006616] = *I06616; sub I06616 { $lac ^= 07777; goto &fetch; }
$core[006617] = 07430; $code[006617] = *I06617; sub I06617 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006620] = 07101; $code[006620] = *I06620; sub I06620 { $lac &= 07777; $lac++; goto &fetch; }
$core[006621] = 03045; $code[006621] = *I06621; sub I06621 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006622] = 05603; $code[006622] = *I06622; sub I06622 { $pc = ($ib<<12)+$core[3459]; $inh = 0; goto &fetch; }
$core[006623] = 00000; $code[006623] = *S06623; sub S06623 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006624] = 01045; $code[006624] = *I06624; sub I06624 { $lac += $core[000045]; goto &fetch; }
$core[006625] = 07450; $code[006625] = *I06625; sub I06625 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006626] = 01046; $code[006626] = *I06626; sub I06626 { $lac += $core[000046]; goto &fetch; }
$core[006627] = 07650; $code[006627] = *I06627; sub I06627 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006630] = 05311; $code[006630] = *I06630; sub I06630 { $pc = 006711; $inh = 0; goto &fetch; }
$core[006631] = 01041; $code[006631] = *I06631; sub I06631 { $lac += $core[000041]; goto &fetch; }
$core[006632] = 07450; $code[006632] = *I06632; sub I06632 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006633] = 01042; $code[006633] = *I06633; sub I06633 { $lac += $core[000042]; goto &fetch; }
$core[006634] = 07450; $code[006634] = *I06634; sub I06634 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006635] = 01043; $code[006635] = *I06635; sub I06635 { $lac += $core[000043]; goto &fetch; }
$core[006636] = 07650; $code[006636] = *I06636; sub I06636 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006637] = 05623; $code[006637] = *I06637; sub I06637 { $pc = ($ib<<12)+$core[3475]; $inh = 0; goto &fetch; }
$core[006640] = 01040; $code[006640] = *I06640; sub I06640 { $lac += $core[000040]; goto &fetch; }
$core[006641] = 07041; $code[006641] = *I06641; sub I06641 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006642] = 01044; $code[006642] = *I06642; sub I06642 { $lac += $core[000044]; goto &fetch; }
$core[006643] = 07450; $code[006643] = *I06643; sub I06643 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006644] = 05273; $code[006644] = *I06644; sub I06644 { $pc = 006673; $inh = 0; goto &fetch; }
$core[006645] = 03203; $code[006645] = *I06645; sub I06645 { $core[006603] = $lac & 07777; $lac &= 010000; $code[006603] = *emul8; goto &fetch; }
$core[006646] = 01203; $code[006646] = *I06646; sub I06646 { $lac += $core[006603]; goto &fetch; }
$core[006647] = 07500; $code[006647] = *I06647; sub I06647 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[006650] = 07041; $code[006650] = *I06650; sub I06650 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006651] = 03322; $code[006651] = *I06651; sub I06651 { $core[006722] = $lac & 07777; $lac &= 010000; $code[006722] = *emul8; goto &fetch; }
$core[006652] = 01322; $code[006652] = *I06652; sub I06652 { $lac += $core[006722]; goto &fetch; }
$core[006653] = 01336; $code[006653] = *I06653; sub I06653 { $lac += $core[006736]; goto &fetch; }
$core[006654] = 07710; $code[006654] = *I06654; sub I06654 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006655] = 05275; $code[006655] = *I06655; sub I06655 { $pc = 006675; $inh = 0; goto &fetch; }
$core[006656] = 01203; $code[006656] = *I06656; sub I06656 { $lac += $core[006603]; goto &fetch; }
$core[006657] = 07700; $code[006657] = *I06657; sub I06657 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006660] = 05265; $code[006660] = *I06660; sub I06660 { $pc = 006665; $inh = 0; goto &fetch; }
$core[006661] = 04357; $code[006661] = *L06661; sub L06661 { $core[006757] = 06662; $pc = 006757+1; $code[006757] = *emul8; $inh = 0; goto &fetch; }
$core[006662] = 02322; $code[006662] = *I06662; sub I06662 { if (++$core[006722] == 010000) { $core[006722] = 0; $pc++; }$code[006722] = *emul8; goto &fetch; }
$core[006663] = 05261; $code[006663] = *I06663; sub I06663 { $pc = 006661; $inh = 0; goto &fetch; }
$core[006664] = 05273; $code[006664] = *I06664; sub I06664 { $pc = 006673; $inh = 0; goto &fetch; }
$core[006665] = 07040; $code[006665] = *L06665; sub L06665 { $lac ^= 07777; goto &fetch; }
$core[006666] = 01040; $code[006666] = *I06666; sub I06666 { $lac += $core[000040]; goto &fetch; }
$core[006667] = 03040; $code[006667] = *I06667; sub I06667 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[006670] = 04723; $code[006670] = *L06670; sub L06670 { $core[($ib<<12)+$core[3539]] = 06671; $pc = ($ib<<12)+$core[3539]+1; $code[($ib<<12)+$core[3539]] = *emul8; $inh = 0; goto &fetch; }
$core[006671] = 02322; $code[006671] = *I06671; sub I06671 { if (++$core[006722] == 010000) { $core[006722] = 0; $pc++; }$code[006722] = *emul8; goto &fetch; }
$core[006672] = 05270; $code[006672] = *I06672; sub I06672 { $pc = 006670; $inh = 0; goto &fetch; }
$core[006673] = 02223; $code[006673] = *L06673; sub L06673 { if (++$core[006623] == 010000) { $core[006623] = 0; $pc++; }$code[006623] = *emul8; goto &fetch; }
$core[006674] = 05623; $code[006674] = *I06674; sub I06674 { $pc = ($ib<<12)+$core[3475]; $inh = 0; goto &fetch; }
$core[006675] = 01040; $code[006675] = *L06675; sub L06675 { $lac += $core[000040]; goto &fetch; }
$core[006676] = 07700; $code[006676] = *I06676; sub I06676 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006677] = 05304; $code[006677] = *I06677; sub I06677 { $pc = 006704; $inh = 0; goto &fetch; }
$core[006700] = 01044; $code[006700] = *I06700; sub I06700 { $lac += $core[000044]; goto &fetch; }
$core[006701] = 07700; $code[006701] = *I06701; sub I06701 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006702] = 05623; $code[006702] = *I06702; sub I06702 { $pc = ($ib<<12)+$core[3475]; $inh = 0; goto &fetch; }
$core[006703] = 05306; $code[006703] = *I06703; sub I06703 { $pc = 006706; $inh = 0; goto &fetch; }
$core[006704] = 01044; $code[006704] = *L06704; sub L06704 { $lac += $core[000044]; goto &fetch; }
$core[006705] = 07700; $code[006705] = *I06705; sub I06705 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006706] = 01203; $code[006706] = *L06706; sub L06706 { $lac += $core[006603]; goto &fetch; }
$core[006707] = 07740; $code[006707] = *I06707; sub I06707 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006710] = 05623; $code[006710] = *I06710; sub I06710 { $pc = ($ib<<12)+$core[3475]; $inh = 0; goto &fetch; }
$core[006711] = 01040; $code[006711] = *L06711; sub L06711 { $lac += $core[000040]; goto &fetch; }
$core[006712] = 03044; $code[006712] = *I06712; sub I06712 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006713] = 01041; $code[006713] = *I06713; sub I06713 { $lac += $core[000041]; goto &fetch; }
$core[006714] = 03045; $code[006714] = *I06714; sub I06714 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006715] = 01042; $code[006715] = *I06715; sub I06715 { $lac += $core[000042]; goto &fetch; }
$core[006716] = 03046; $code[006716] = *I06716; sub I06716 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006717] = 01043; $code[006717] = *I06717; sub I06717 { $lac += $core[000043]; goto &fetch; }
$core[006720] = 03047; $code[006720] = *I06720; sub I06720 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[006721] = 05623; $code[006721] = *I06721; sub I06721 { $pc = ($ib<<12)+$core[3475]; $inh = 0; goto &fetch; }
$core[006722] = 00000; $code[006722] = *D06722; sub D06722 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006723] = 05754; $code[006723] = *P06723; sub P06723 { $pc = ($ib<<12)+$core[3564]; $inh = 0; goto &fetch; }
$core[006724] = 00000; $code[006724] = *S06724; sub S06724 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006725] = 04751; $code[006725] = *I06725; sub I06725 { $core[($ib<<12)+$core[3561]] = 06726; $pc = ($ib<<12)+$core[3561]+1; $code[($ib<<12)+$core[3561]] = *emul8; $inh = 0; goto &fetch; }
$core[006726] = 01044; $code[006726] = *I06726; sub I06726 { $lac += $core[000044]; goto &fetch; }
$core[006727] = 07750; $code[006727] = *I06727; sub I06727 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006730] = 05353; $code[006730] = *I06730; sub I06730 { $pc = 006753; $inh = 0; goto &fetch; }
$core[006731] = 07001; $code[006731] = *I06731; sub I06731 { $lac++; goto &fetch; }
$core[006732] = 03043; $code[006732] = *I06732; sub I06732 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[006733] = 01350; $code[006733] = *I06733; sub I06733 { $lac += $core[006750]; goto &fetch; }
$core[006734] = 03040; $code[006734] = *I06734; sub I06734 { $core[000040] = $lac & 07777; $lac &= 010000; $code[000040] = *emul8; goto &fetch; }
$core[006735] = 04223; $code[006735] = *I06735; sub I06735 { $core[006623] = 06736; $pc = 006623+1; $code[006623] = *emul8; $inh = 0; goto &fetch; }
$core[006736] = 00027; $code[006736] = *D06736; sub D06736 { $lac &= (010000|$core[000027]); goto &fetch; }
$core[006737] = 02047; $code[006737] = *D06737; sub D06737 { if (++$core[000047] == 010000) { $core[000047] = 0; $pc++; }$code[000047] = *emul8; goto &fetch; }
$core[006740] = 05344; $code[006740] = *I06740; sub I06740 { $pc = 006744; $inh = 0; goto &fetch; }
$core[006741] = 02046; $code[006741] = *I06741; sub I06741 { if (++$core[000046] == 010000) { $core[000046] = 0; $pc++; }$code[000046] = *emul8; goto &fetch; }
$core[006742] = 07410; $code[006742] = *I06742; sub I06742 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006743] = 02045; $code[006743] = *I06743; sub I06743 { if (++$core[000045] == 010000) { $core[000045] = 0; $pc++; }$code[000045] = *emul8; goto &fetch; }
$core[006744] = 03047; $code[006744] = *L06744; sub L06744 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[006745] = 04752; $code[006745] = *I06745; sub I06745 { $core[($ib<<12)+$core[3562]] = 06746; $pc = ($ib<<12)+$core[3562]+1; $code[($ib<<12)+$core[3562]] = *emul8; $inh = 0; goto &fetch; }
$core[006746] = 01046; $code[006746] = *I06746; sub I06746 { $lac += $core[000046]; goto &fetch; }
$core[006747] = 05724; $code[006747] = *I06747; sub I06747 { $pc = ($ib<<12)+$core[3540]; $inh = 0; goto &fetch; }
$core[006750] = 00027; $code[006750] = *D06750; sub D06750 { $lac &= (010000|$core[000027]); goto &fetch; }
$core[006751] = 05571; $code[006751] = *P06751; sub P06751 { $pc = ($ib<<12)+$core[121]; $inh = 0; goto &fetch; }
$core[006752] = 07173; $code[006752] = *P06752; sub P06752 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006753] = 03044; $code[006753] = *L06753; sub L06753 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[006754] = 03045; $code[006754] = *P06754; sub P06754 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006755] = 03046; $code[006755] = *I06755; sub I06755 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006756] = 05344; $code[006756] = *I06756; sub I06756 { $pc = 006744; $inh = 0; goto &fetch; }
$core[006757] = 00000; $code[006757] = *S06757; sub S06757 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006760] = 07300; $code[006760] = *I06760; sub I06760 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006761] = 01045; $code[006761] = *I06761; sub I06761 { $lac += $core[000045]; goto &fetch; }
$core[006762] = 07510; $code[006762] = *I06762; sub I06762 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006763] = 07020; $code[006763] = *I06763; sub I06763 { $lac ^= 010000; goto &fetch; }
$core[006764] = 07010; $code[006764] = *I06764; sub I06764 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006765] = 03045; $code[006765] = *I06765; sub I06765 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[006766] = 01046; $code[006766] = *I06766; sub I06766 { $lac += $core[000046]; goto &fetch; }
$core[006767] = 07010; $code[006767] = *I06767; sub I06767 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006770] = 03046; $code[006770] = *I06770; sub I06770 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[006771] = 01047; $code[006771] = *I06771; sub I06771 { $lac += $core[000047]; goto &fetch; }
$core[006772] = 07010; $code[006772] = *I06772; sub I06772 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006773] = 03047; $code[006773] = *I06773; sub I06773 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[006774] = 02044; $code[006774] = *I06774; sub I06774 { if (++$core[000044] == 010000) { $core[000044] = 0; $pc++; }$code[000044] = *emul8; goto &fetch; }
$core[006775] = 05757; $code[006775] = *I06775; sub I06775 { $pc = ($ib<<12)+$core[3567]; $inh = 0; goto &fetch; }
$core[006776] = 05757; $code[006776] = *I06776; sub I06776 { $pc = ($ib<<12)+$core[3567]; $inh = 0; goto &fetch; }
$core[006777] = 00337; $code[006777] = *I06777; sub I06777 { $lac &= (010000|$core[006737]); goto &fetch; }
$core[007000] = 00377; $code[007000] = *I07000; sub I07000 { $lac &= (010000|$core[007177]); goto &fetch; }
$core[007001] = 00212; $code[007001] = *I07001; sub I07001 { $lac &= (010000|$core[007012]); goto &fetch; }
$core[007002] = 00375; $code[007002] = *I07002; sub I07002 { $lac &= (010000|$core[007175]); goto &fetch; }
$core[007003] = 07777; $code[007003] = *I07003; sub I07003 { &emul8; goto &fetch; }
$core[007004] = 00000; $code[007004] = *S07004; sub S07004 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007005] = 07001; $code[007005] = *I07005; sub I07005 { $lac++; goto &fetch; }
$core[007006] = 01040; $code[007006] = *I07006; sub I07006 { $lac += $core[000040]; goto &fetch; }
$core[007007] = 04324; $code[007007] = *I07007; sub I07007 { $core[007124] = 07010; $pc = 007124+1; $code[007124] = *emul8; $inh = 0; goto &fetch; }
$core[007010] = 07710; $code[007010] = *I07010; sub I07010 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007011] = 04353; $code[007011] = *I07011; sub I07011 { $core[007153] = 07012; $pc = 007153+1; $code[007153] = *emul8; $inh = 0; goto &fetch; }
$core[007012] = 03301; $code[007012] = *D07012; sub D07012 { $core[007101] = $lac & 07777; $lac &= 010000; $code[007101] = *emul8; goto &fetch; }
$core[007013] = 03300; $code[007013] = *I07013; sub I07013 { $core[007100] = $lac & 07777; $lac &= 010000; $code[007100] = *emul8; goto &fetch; }
$core[007014] = 03277; $code[007014] = *I07014; sub I07014 { $core[007077] = $lac & 07777; $lac &= 010000; $code[007077] = *emul8; goto &fetch; }
$core[007015] = 03276; $code[007015] = *I07015; sub I07015 { $core[007076] = $lac & 07777; $lac &= 010000; $code[007076] = *emul8; goto &fetch; }
$core[007016] = 01045; $code[007016] = *I07016; sub I07016 { $lac += $core[000045]; goto &fetch; }
$core[007017] = 03751; $code[007017] = *I07017; sub I07017 { $core[($df<<12)+$core[3689]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3689]] = *emul8; goto &fetch; }
$core[007020] = 01041; $code[007020] = *I07020; sub I07020 { $lac += $core[000041]; goto &fetch; }
$core[007021] = 04752; $code[007021] = *I07021; sub I07021 { $core[($ib<<12)+$core[3690]] = 07022; $pc = ($ib<<12)+$core[3690]+1; $code[($ib<<12)+$core[3690]] = *emul8; $inh = 0; goto &fetch; }
$core[007022] = 00002; $code[007022] = *I07022; sub I07022 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[007023] = 01042; $code[007023] = *I07023; sub I07023 { $lac += $core[000042]; goto &fetch; }
$core[007024] = 04752; $code[007024] = *I07024; sub I07024 { $core[($ib<<12)+$core[3690]] = 07025; $pc = ($ib<<12)+$core[3690]+1; $code[($ib<<12)+$core[3690]] = *emul8; $inh = 0; goto &fetch; }
$core[007025] = 00003; $code[007025] = *I07025; sub I07025 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[007026] = 01046; $code[007026] = *I07026; sub I07026 { $lac += $core[000046]; goto &fetch; }
$core[007027] = 03751; $code[007027] = *I07027; sub I07027 { $core[($df<<12)+$core[3689]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3689]] = *emul8; goto &fetch; }
$core[007030] = 01041; $code[007030] = *I07030; sub I07030 { $lac += $core[000041]; goto &fetch; }
$core[007031] = 04752; $code[007031] = *I07031; sub I07031 { $core[($ib<<12)+$core[3690]] = 07032; $pc = ($ib<<12)+$core[3690]+1; $code[($ib<<12)+$core[3690]] = *emul8; $inh = 0; goto &fetch; }
$core[007032] = 00003; $code[007032] = *I07032; sub I07032 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[007033] = 01042; $code[007033] = *I07033; sub I07033 { $lac += $core[000042]; goto &fetch; }
$core[007034] = 04752; $code[007034] = *I07034; sub I07034 { $core[($ib<<12)+$core[3690]] = 07035; $pc = ($ib<<12)+$core[3690]+1; $code[($ib<<12)+$core[3690]] = *emul8; $inh = 0; goto &fetch; }
$core[007035] = 00004; $code[007035] = *I07035; sub I07035 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[007036] = 05263; $code[007036] = *I07036; sub I07036 { $pc = 007063; $inh = 0; goto &fetch; }
$core[007037] = 03274; $code[007037] = *I07037; sub I07037 { $core[007074] = $lac & 07777; $lac &= 010000; $code[007074] = *emul8; goto &fetch; }
$core[007040] = 01043; $code[007040] = *I07040; sub I07040 { $lac += $core[000043]; goto &fetch; }
$core[007041] = 03751; $code[007041] = *D07041; sub D07041 { $core[($df<<12)+$core[3689]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3689]] = *emul8; goto &fetch; }
$core[007042] = 01045; $code[007042] = *D07042; sub D07042 { $lac += $core[000045]; goto &fetch; }
$core[007043] = 04752; $code[007043] = *I07043; sub I07043 { $core[($ib<<12)+$core[3690]] = 07044; $pc = ($ib<<12)+$core[3690]+1; $code[($ib<<12)+$core[3690]] = *emul8; $inh = 0; goto &fetch; }
$core[007044] = 00004; $code[007044] = *I07044; sub I07044 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[007045] = 01046; $code[007045] = *I07045; sub I07045 { $lac += $core[000046]; goto &fetch; }
$core[007046] = 04752; $code[007046] = *I07046; sub I07046 { $core[($ib<<12)+$core[3690]] = 07047; $pc = ($ib<<12)+$core[3690]+1; $code[($ib<<12)+$core[3690]] = *emul8; $inh = 0; goto &fetch; }
$core[007047] = 00005; $code[007047] = *I07047; sub I07047 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[007050] = 01047; $code[007050] = *I07050; sub I07050 { $lac += $core[000047]; goto &fetch; }
$core[007051] = 03751; $code[007051] = *I07051; sub I07051 { $core[($df<<12)+$core[3689]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3689]] = *emul8; goto &fetch; }
$core[007052] = 01041; $code[007052] = *I07052; sub I07052 { $lac += $core[000041]; goto &fetch; }
$core[007053] = 04752; $code[007053] = *I07053; sub I07053 { $core[($ib<<12)+$core[3690]] = 07054; $pc = ($ib<<12)+$core[3690]+1; $code[($ib<<12)+$core[3690]] = *emul8; $inh = 0; goto &fetch; }
$core[007054] = 00004; $code[007054] = *I07054; sub I07054 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[007055] = 01042; $code[007055] = *I07055; sub I07055 { $lac += $core[000042]; goto &fetch; }
$core[007056] = 04752; $code[007056] = *I07056; sub I07056 { $core[($ib<<12)+$core[3690]] = 07057; $pc = ($ib<<12)+$core[3690]+1; $code[($ib<<12)+$core[3690]] = *emul8; $inh = 0; goto &fetch; }
$core[007057] = 00005; $code[007057] = *D07057; sub D07057 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[007060] = 01043; $code[007060] = *I07060; sub I07060 { $lac += $core[000043]; goto &fetch; }
$core[007061] = 04752; $code[007061] = *I07061; sub I07061 { $core[($ib<<12)+$core[3690]] = 07062; $pc = ($ib<<12)+$core[3690]+1; $code[($ib<<12)+$core[3690]] = *emul8; $inh = 0; goto &fetch; }
$core[007062] = 00006; $code[007062] = *I07062; sub I07062 { $lac &= (010000|$core[000006]); goto &fetch; }
$core[007063] = 01301; $code[007063] = *L07063; sub L07063 { $lac += $core[007101]; goto &fetch; }
$core[007064] = 03045; $code[007064] = *I07064; sub I07064 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007065] = 01300; $code[007065] = *I07065; sub I07065 { $lac += $core[007100]; goto &fetch; }
$core[007066] = 03046; $code[007066] = *I07066; sub I07066 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007067] = 01277; $code[007067] = *I07067; sub I07067 { $lac += $core[007077]; goto &fetch; }
$core[007070] = 03047; $code[007070] = *I07070; sub I07070 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007071] = 04301; $code[007071] = *I07071; sub I07071 { $core[007101] = 07072; $pc = 007101+1; $code[007101] = *emul8; $inh = 0; goto &fetch; }
$core[007072] = 03047; $code[007072] = *I07072; sub I07072 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007073] = 05604; $code[007073] = *I07073; sub I07073 { $pc = ($ib<<12)+$core[3588]; $inh = 0; goto &fetch; }
$core[007101] = 00000; $code[007101] = *S07101; sub S07101 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007102] = 02050; $code[007102] = *I07102; sub I07102 { if (++$core[000050] == 010000) { $core[000050] = 0; $pc++; }$code[000050] = *emul8; goto &fetch; }
$core[007103] = 04451; $code[007103] = *I07103; sub I07103 { $core[($ib<<12)+$core[41]] = 07104; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007104] = 04747; $code[007104] = *I07104; sub I07104 { $core[($ib<<12)+$core[3687]] = 07105; $pc = ($ib<<12)+$core[3687]+1; $code[($ib<<12)+$core[3687]] = *emul8; $inh = 0; goto &fetch; }
$core[007105] = 02047; $code[007105] = *I07105; sub I07105 { if (++$core[000047] == 010000) { $core[000047] = 0; $pc++; }$code[000047] = *emul8; goto &fetch; }
$core[007106] = 05701; $code[007106] = *I07106; sub I07106 { $pc = ($ib<<12)+$core[3649]; $inh = 0; goto &fetch; }
$core[007107] = 01041; $code[007107] = *I07107; sub I07107 { $lac += $core[000041]; goto &fetch; }
$core[007110] = 07650; $code[007110] = *I07110; sub I07110 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007111] = 04566; $code[007111] = *I07111; sub I07111 { $core[($ib<<12)+$core[118]] = 07112; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[007112] = 01040; $code[007112] = *I07112; sub I07112 { $lac += $core[000040]; goto &fetch; }
$core[007113] = 07041; $code[007113] = *I07113; sub I07113 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007114] = 07001; $code[007114] = *I07114; sub I07114 { $lac++; goto &fetch; }
$core[007115] = 04324; $code[007115] = *I07115; sub I07115 { $core[007124] = 07116; $pc = 007124+1; $code[007124] = *emul8; $inh = 0; goto &fetch; }
$core[007116] = 07700; $code[007116] = *I07116; sub I07116 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007117] = 04353; $code[007117] = *I07117; sub I07117 { $core[007153] = 07120; $pc = 007153+1; $code[007153] = *emul8; $inh = 0; goto &fetch; }
$core[007120] = 04750; $code[007120] = *I07120; sub I07120 { $core[($ib<<12)+$core[3688]] = 07121; $pc = ($ib<<12)+$core[3688]+1; $code[($ib<<12)+$core[3688]] = *emul8; $inh = 0; goto &fetch; }
$core[007121] = 04301; $code[007121] = *I07121; sub I07121 { $core[007101] = 07122; $pc = 007101+1; $code[007101] = *emul8; $inh = 0; goto &fetch; }
$core[007122] = 05723; $code[007122] = *I07122; sub I07122 { $pc = ($ib<<12)+$core[3667]; $inh = 0; goto &fetch; }
$core[007123] = 06401; $code[007123] = *P07123; sub P07123 { &emul8; goto &fetch; }
$core[007124] = 00000; $code[007124] = *S07124; sub S07124 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007125] = 01044; $code[007125] = *I07125; sub I07125 { $lac += $core[000044]; goto &fetch; }
$core[007126] = 03044; $code[007126] = *I07126; sub I07126 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007127] = 01124; $code[007127] = *I07127; sub I07127 { $lac += $core[000124]; goto &fetch; }
$core[007130] = 00045; $code[007130] = *I07130; sub I07130 { $lac &= (010000|$core[000045]); goto &fetch; }
$core[007131] = 01041; $code[007131] = *I07131; sub I07131 { $lac += $core[000041]; goto &fetch; }
$core[007132] = 07700; $code[007132] = *I07132; sub I07132 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007133] = 07040; $code[007133] = *I07133; sub I07133 { $lac ^= 07777; goto &fetch; }
$core[007134] = 03050; $code[007134] = *I07134; sub I07134 { $core[000050] = $lac & 07777; $lac &= 010000; $code[000050] = *emul8; goto &fetch; }
$core[007135] = 01045; $code[007135] = *I07135; sub I07135 { $lac += $core[000045]; goto &fetch; }
$core[007136] = 07450; $code[007136] = *I07136; sub I07136 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007137] = 05746; $code[007137] = *I07137; sub I07137 { $pc = ($ib<<12)+$core[3686]; $inh = 0; goto &fetch; }
$core[007140] = 07710; $code[007140] = *I07140; sub I07140 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007141] = 04451; $code[007141] = *I07141; sub I07141 { $core[($ib<<12)+$core[41]] = 07142; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007142] = 01041; $code[007142] = *I07142; sub I07142 { $lac += $core[000041]; goto &fetch; }
$core[007143] = 07450; $code[007143] = *I07143; sub I07143 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007144] = 05746; $code[007144] = *I07144; sub I07144 { $pc = ($ib<<12)+$core[3686]; $inh = 0; goto &fetch; }
$core[007145] = 05724; $code[007145] = *I07145; sub I07145 { $pc = ($ib<<12)+$core[3668]; $inh = 0; goto &fetch; }
$core[007146] = 06520; $code[007146] = *P07146; sub P07146 { &emul8; goto &fetch; }
$core[007147] = 07335; $code[007147] = *P07147; sub P07147 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007150] = 07261; $code[007150] = *P07150; sub P07150 { $lac &= 010000; $lac ^= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[007151] = 07256; $code[007151] = *P07151; sub P07151 { $lac &= 010000; $lac ^= 07777; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[007152] = 07200; $code[007152] = *P07152; sub P07152 { $lac &= 010000; goto &fetch; }
$core[007153] = 00000; $code[007153] = *S07153; sub S07153 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007154] = 07300; $code[007154] = *I07154; sub I07154 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[007155] = 01043; $code[007155] = *I07155; sub I07155 { $lac += $core[000043]; goto &fetch; }
$core[007156] = 07041; $code[007156] = *I07156; sub I07156 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007157] = 03043; $code[007157] = *I07157; sub I07157 { $core[000043] = $lac & 07777; $lac &= 010000; $code[000043] = *emul8; goto &fetch; }
$core[007160] = 01042; $code[007160] = *I07160; sub I07160 { $lac += $core[000042]; goto &fetch; }
$core[007161] = 07040; $code[007161] = *I07161; sub I07161 { $lac ^= 07777; goto &fetch; }
$core[007162] = 07430; $code[007162] = *I07162; sub I07162 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007163] = 07101; $code[007163] = *I07163; sub I07163 { $lac &= 07777; $lac++; goto &fetch; }
$core[007164] = 03042; $code[007164] = *I07164; sub I07164 { $core[000042] = $lac & 07777; $lac &= 010000; $code[000042] = *emul8; goto &fetch; }
$core[007165] = 01041; $code[007165] = *I07165; sub I07165 { $lac += $core[000041]; goto &fetch; }
$core[007166] = 07040; $code[007166] = *L07166; sub L07166 { $lac ^= 07777; goto &fetch; }
$core[007167] = 07430; $code[007167] = *I07167; sub I07167 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007170] = 07101; $code[007170] = *I07170; sub I07170 { $lac &= 07777; $lac++; goto &fetch; }
$core[007171] = 03041; $code[007171] = *I07171; sub I07171 { $core[000041] = $lac & 07777; $lac &= 010000; $code[000041] = *emul8; goto &fetch; }
$core[007172] = 05753; $code[007172] = *I07172; sub I07172 { $pc = ($ib<<12)+$core[3691]; $inh = 0; goto &fetch; }
$core[007173] = 00000; $code[007173] = *S07173; sub S07173 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007174] = 01050; $code[007174] = *I07174; sub I07174 { $lac += $core[000050]; goto &fetch; }
$core[007175] = 07710; $code[007175] = *D07175; sub D07175 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007176] = 04451; $code[007176] = *I07176; sub I07176 { $core[($ib<<12)+$core[41]] = 07177; $pc = ($ib<<12)+$core[41]+1; $code[($ib<<12)+$core[41]] = *emul8; $inh = 0; goto &fetch; }
$core[007177] = 05773; $code[007177] = *D07177; sub D07177 { $pc = ($ib<<12)+$core[3707]; $inh = 0; goto &fetch; }
$core[007200] = 00000; $code[007200] = *S07200; sub S07200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007201] = 07450; $code[007201] = *I07201; sub I07201 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007202] = 05600; $code[007202] = *I07202; sub I07202 { $pc = ($ib<<12)+$core[3712]; $inh = 0; goto &fetch; }
$core[007203] = 03254; $code[007203] = *I07203; sub I07203 { $core[007254] = $lac & 07777; $lac &= 010000; $code[007254] = *emul8; goto &fetch; }
$core[007204] = 03253; $code[007204] = *I07204; sub I07204 { $core[007253] = $lac & 07777; $lac &= 010000; $code[007253] = *emul8; goto &fetch; }
$core[007205] = 01257; $code[007205] = *I07205; sub I07205 { $lac += $core[007257]; goto &fetch; }
$core[007206] = 03255; $code[007206] = *I07206; sub I07206 { $core[007255] = $lac & 07777; $lac &= 010000; $code[007255] = *emul8; goto &fetch; }
$core[007207] = 07100; $code[007207] = *I07207; sub I07207 { $lac &= 07777; goto &fetch; }
$core[007210] = 01254; $code[007210] = *L07210; sub L07210 { $lac += $core[007254]; goto &fetch; }
$core[007211] = 07010; $code[007211] = *I07211; sub I07211 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007212] = 03254; $code[007212] = *I07212; sub I07212 { $core[007254] = $lac & 07777; $lac &= 010000; $code[007254] = *emul8; goto &fetch; }
$core[007213] = 01253; $code[007213] = *I07213; sub I07213 { $lac += $core[007253]; goto &fetch; }
$core[007214] = 07420; $code[007214] = *I07214; sub I07214 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[007215] = 05220; $code[007215] = *I07215; sub I07215 { $pc = 007220; $inh = 0; goto &fetch; }
$core[007216] = 07100; $code[007216] = *I07216; sub I07216 { $lac &= 07777; goto &fetch; }
$core[007217] = 01256; $code[007217] = *I07217; sub I07217 { $lac += $core[007256]; goto &fetch; }
$core[007220] = 07010; $code[007220] = *L07220; sub L07220 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007221] = 03253; $code[007221] = *I07221; sub I07221 { $core[007253] = $lac & 07777; $lac &= 010000; $code[007253] = *emul8; goto &fetch; }
$core[007222] = 02255; $code[007222] = *I07222; sub I07222 { if (++$core[007255] == 010000) { $core[007255] = 0; $pc++; }$code[007255] = *emul8; goto &fetch; }
$core[007223] = 05210; $code[007223] = *I07223; sub I07223 { $pc = 007210; $inh = 0; goto &fetch; }
$core[007224] = 01254; $code[007224] = *I07224; sub I07224 { $lac += $core[007254]; goto &fetch; }
$core[007225] = 07010; $code[007225] = *I07225; sub I07225 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007226] = 03255; $code[007226] = *I07226; sub I07226 { $core[007255] = $lac & 07777; $lac &= 010000; $code[007255] = *emul8; goto &fetch; }
$core[007227] = 01600; $code[007227] = *I07227; sub I07227 { $lac += $core[($df<<12)+$core[3712]]; goto &fetch; }
$core[007230] = 07041; $code[007230] = *I07230; sub I07230 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007231] = 01252; $code[007231] = *I07231; sub I07231 { $lac += $core[007252]; goto &fetch; }
$core[007232] = 03254; $code[007232] = *I07232; sub I07232 { $core[007254] = $lac & 07777; $lac &= 010000; $code[007254] = *emul8; goto &fetch; }
$core[007233] = 01255; $code[007233] = *I07233; sub I07233 { $lac += $core[007255]; goto &fetch; }
$core[007234] = 07100; $code[007234] = *I07234; sub I07234 { $lac &= 07777; goto &fetch; }
$core[007235] = 01654; $code[007235] = *I07235; sub I07235 { $lac += $core[($df<<12)+$core[3756]]; goto &fetch; }
$core[007236] = 03654; $code[007236] = *I07236; sub I07236 { $core[($df<<12)+$core[3756]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3756]] = *emul8; goto &fetch; }
$core[007237] = 02254; $code[007237] = *I07237; sub I07237 { if (++$core[007254] == 010000) { $core[007254] = 0; $pc++; }$code[007254] = *emul8; goto &fetch; }
$core[007240] = 07004; $code[007240] = *I07240; sub I07240 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007241] = 01253; $code[007241] = *I07241; sub I07241 { $lac += $core[007253]; goto &fetch; }
$core[007242] = 01654; $code[007242] = *I07242; sub I07242 { $lac += $core[($df<<12)+$core[3756]]; goto &fetch; }
$core[007243] = 03654; $code[007243] = *I07243; sub I07243 { $core[($df<<12)+$core[3756]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3756]] = *emul8; goto &fetch; }
$core[007244] = 07420; $code[007244] = *I07244; sub I07244 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[007245] = 05600; $code[007245] = *I07245; sub I07245 { $pc = ($ib<<12)+$core[3712]; $inh = 0; goto &fetch; }
$core[007246] = 02254; $code[007246] = *L07246; sub L07246 { if (++$core[007254] == 010000) { $core[007254] = 0; $pc++; }$code[007254] = *emul8; goto &fetch; }
$core[007247] = 02654; $code[007247] = *I07247; sub I07247 { if (++$core[($df<<12)+$core[3756]] == 010000) { $core[($df<<12)+$core[3756]] = 0; $pc++; }$code[($df<<12)+$core[3756]] = *emul8; goto &fetch; }
$core[007250] = 05600; $code[007250] = *I07250; sub I07250 { $pc = ($ib<<12)+$core[3712]; $inh = 0; goto &fetch; }
$core[007251] = 05246; $code[007251] = *I07251; sub I07251 { $pc = 007246; $inh = 0; goto &fetch; }
$core[007252] = 07102; $code[007252] = *D07252; sub D07252 { $lac &= 07777; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[007253] = 00000; $code[007253] = *D07253; sub D07253 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007254] = 00000; $code[007254] = *P07254; sub P07254 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007255] = 00000; $code[007255] = *D07255; sub D07255 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007256] = 00000; $code[007256] = *D07256; sub D07256 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007257] = 07764; $code[007257] = *D07257; sub D07257 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007260] = 07751; $code[007260] = *D07260; sub D07260 { &emul8; goto &fetch; }
$core[007261] = 00000; $code[007261] = *S07261; sub S07261 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007262] = 03200; $code[007262] = *I07262; sub I07262 { $core[007200] = $lac & 07777; $lac &= 010000; $code[007200] = *emul8; goto &fetch; }
$core[007263] = 03254; $code[007263] = *I07263; sub I07263 { $core[007254] = $lac & 07777; $lac &= 010000; $code[007254] = *emul8; goto &fetch; }
$core[007264] = 01260; $code[007264] = *I07264; sub I07264 { $lac += $core[007260]; goto &fetch; }
$core[007265] = 03255; $code[007265] = *I07265; sub I07265 { $core[007255] = $lac & 07777; $lac &= 010000; $code[007255] = *emul8; goto &fetch; }
$core[007266] = 07410; $code[007266] = *I07266; sub I07266 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007267] = 04527; $code[007267] = *L07267; sub L07267 { $core[($ib<<12)+$core[87]] = 07270; $pc = ($ib<<12)+$core[87]+1; $code[($ib<<12)+$core[87]] = *emul8; $inh = 0; goto &fetch; }
$core[007270] = 07100; $code[007270] = *I07270; sub I07270 { $lac &= 07777; goto &fetch; }
$core[007271] = 01042; $code[007271] = *I07271; sub I07271 { $lac += $core[000042]; goto &fetch; }
$core[007272] = 01046; $code[007272] = *I07272; sub I07272 { $lac += $core[000046]; goto &fetch; }
$core[007273] = 03256; $code[007273] = *I07273; sub I07273 { $core[007256] = $lac & 07777; $lac &= 010000; $code[007256] = *emul8; goto &fetch; }
$core[007274] = 07004; $code[007274] = *I07274; sub I07274 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007275] = 01045; $code[007275] = *I07275; sub I07275 { $lac += $core[000045]; goto &fetch; }
$core[007276] = 01041; $code[007276] = *I07276; sub I07276 { $lac += $core[000041]; goto &fetch; }
$core[007277] = 07420; $code[007277] = *I07277; sub I07277 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[007300] = 05304; $code[007300] = *I07300; sub I07300 { $pc = 007304; $inh = 0; goto &fetch; }
$core[007301] = 03045; $code[007301] = *I07301; sub I07301 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007302] = 01256; $code[007302] = *I07302; sub I07302 { $lac += $core[007256]; goto &fetch; }
$core[007303] = 03046; $code[007303] = *I07303; sub I07303 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007304] = 07200; $code[007304] = *L07304; sub L07304 { $lac &= 010000; goto &fetch; }
$core[007305] = 01254; $code[007305] = *I07305; sub I07305 { $lac += $core[007254]; goto &fetch; }
$core[007306] = 07004; $code[007306] = *I07306; sub I07306 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007307] = 03254; $code[007307] = *I07307; sub I07307 { $core[007254] = $lac & 07777; $lac &= 010000; $code[007254] = *emul8; goto &fetch; }
$core[007310] = 01200; $code[007310] = *I07310; sub I07310 { $lac += $core[007200]; goto &fetch; }
$core[007311] = 07004; $code[007311] = *I07311; sub I07311 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007312] = 03200; $code[007312] = *I07312; sub I07312 { $core[007200] = $lac & 07777; $lac &= 010000; $code[007200] = *emul8; goto &fetch; }
$core[007313] = 02255; $code[007313] = *I07313; sub I07313 { if (++$core[007255] == 010000) { $core[007255] = 0; $pc++; }$code[007255] = *emul8; goto &fetch; }
$core[007314] = 05267; $code[007314] = *I07314; sub I07314 { $pc = 007267; $inh = 0; goto &fetch; }
$core[007315] = 01254; $code[007315] = *I07315; sub I07315 { $lac += $core[007254]; goto &fetch; }
$core[007316] = 03046; $code[007316] = *I07316; sub I07316 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007317] = 01200; $code[007317] = *I07317; sub I07317 { $lac += $core[007200]; goto &fetch; }
$core[007320] = 03045; $code[007320] = *I07320; sub I07320 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007321] = 05661; $code[007321] = *I07321; sub I07321 { $pc = ($ib<<12)+$core[3761]; $inh = 0; goto &fetch; }
$core[007322] = 07004; $code[007322] = *I07322; sub I07322 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007323] = 03335; $code[007323] = *I07323; sub I07323 { $core[007335] = $lac & 07777; $lac &= 010000; $code[007335] = *emul8; goto &fetch; }
$core[007324] = 02255; $code[007324] = *I07324; sub I07324 { if (++$core[007255] == 010000) { $core[007255] = 0; $pc++; }$code[007255] = *emul8; goto &fetch; }
$core[007325] = 05267; $code[007325] = *I07325; sub I07325 { $pc = 007267; $inh = 0; goto &fetch; }
$core[007326] = 01335; $code[007326] = *I07326; sub I07326 { $lac += $core[007335]; goto &fetch; }
$core[007327] = 03045; $code[007327] = *I07327; sub I07327 { $core[000045] = $lac & 07777; $lac &= 010000; $code[000045] = *emul8; goto &fetch; }
$core[007330] = 01200; $code[007330] = *I07330; sub I07330 { $lac += $core[007200]; goto &fetch; }
$core[007331] = 03046; $code[007331] = *I07331; sub I07331 { $core[000046] = $lac & 07777; $lac &= 010000; $code[000046] = *emul8; goto &fetch; }
$core[007332] = 01254; $code[007332] = *I07332; sub I07332 { $lac += $core[007254]; goto &fetch; }
$core[007333] = 03047; $code[007333] = *I07333; sub I07333 { $core[000047] = $lac & 07777; $lac &= 010000; $code[000047] = *emul8; goto &fetch; }
$core[007334] = 05661; $code[007334] = *I07334; sub I07334 { $pc = ($ib<<12)+$core[3761]; $inh = 0; goto &fetch; }
$core[007335] = 00000; $code[007335] = *S07335; sub S07335 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007336] = 04775; $code[007336] = *I07336; sub I07336 { $core[($ib<<12)+$core[3837]] = 07337; $pc = ($ib<<12)+$core[3837]+1; $code[($ib<<12)+$core[3837]] = *emul8; $inh = 0; goto &fetch; }
$core[007337] = 04366; $code[007337] = *I07337; sub I07337 { $core[007366] = 07340; $pc = 007366+1; $code[007366] = *emul8; $inh = 0; goto &fetch; }
$core[007340] = 01045; $code[007340] = *I07340; sub I07340 { $lac += $core[000045]; goto &fetch; }
$core[007341] = 07450; $code[007341] = *I07341; sub I07341 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007342] = 01047; $code[007342] = *I07342; sub I07342 { $lac += $core[000047]; goto &fetch; }
$core[007343] = 07450; $code[007343] = *I07343; sub I07343 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007344] = 01046; $code[007344] = *I07344; sub I07344 { $lac += $core[000046]; goto &fetch; }
$core[007345] = 07650; $code[007345] = *I07345; sub I07345 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007346] = 05363; $code[007346] = *I07346; sub I07346 { $pc = 007363; $inh = 0; goto &fetch; }
$core[007347] = 01045; $code[007347] = *L07347; sub L07347 { $lac += $core[000045]; goto &fetch; }
$core[007350] = 07104; $code[007350] = *I07350; sub I07350 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007351] = 07710; $code[007351] = *I07351; sub I07351 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007352] = 05360; $code[007352] = *I07352; sub I07352 { $pc = 007360; $inh = 0; goto &fetch; }
$core[007353] = 04527; $code[007353] = *I07353; sub I07353 { $core[($ib<<12)+$core[87]] = 07354; $pc = ($ib<<12)+$core[87]+1; $code[($ib<<12)+$core[87]] = *emul8; $inh = 0; goto &fetch; }
$core[007354] = 07140; $code[007354] = *I07354; sub I07354 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[007355] = 01044; $code[007355] = *I07355; sub I07355 { $lac += $core[000044]; goto &fetch; }
$core[007356] = 03044; $code[007356] = *I07356; sub I07356 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007357] = 05347; $code[007357] = *I07357; sub I07357 { $pc = 007347; $inh = 0; goto &fetch; }
$core[007360] = 04776; $code[007360] = *L07360; sub L07360 { $core[($ib<<12)+$core[3838]] = 07361; $pc = ($ib<<12)+$core[3838]+1; $code[($ib<<12)+$core[3838]] = *emul8; $inh = 0; goto &fetch; }
$core[007361] = 04366; $code[007361] = *I07361; sub I07361 { $core[007366] = 07362; $pc = 007366+1; $code[007366] = *emul8; $inh = 0; goto &fetch; }
$core[007362] = 05735; $code[007362] = *I07362; sub I07362 { $pc = ($ib<<12)+$core[3805]; $inh = 0; goto &fetch; }
$core[007363] = 03044; $code[007363] = *L07363; sub L07363 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007364] = 05735; $code[007364] = *I07364; sub I07364 { $pc = ($ib<<12)+$core[3805]; $inh = 0; goto &fetch; }
$core[007365] = 06757; $code[007365] = *P07365; sub P07365 { &emul8; goto &fetch; }
$core[007366] = 00000; $code[007366] = *S07366; sub S07366 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007367] = 01045; $code[007367] = *I07367; sub I07367 { $lac += $core[000045]; goto &fetch; }
$core[007370] = 07510; $code[007370] = *I07370; sub I07370 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007371] = 07041; $code[007371] = *I07371; sub I07371 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007372] = 07710; $code[007372] = *I07372; sub I07372 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007373] = 04765; $code[007373] = *I07373; sub I07373 { $core[($ib<<12)+$core[3829]] = 07374; $pc = ($ib<<12)+$core[3829]+1; $code[($ib<<12)+$core[3829]] = *emul8; $inh = 0; goto &fetch; }
$core[007374] = 05766; $code[007374] = *I07374; sub I07374 { $pc = ($ib<<12)+$core[3830]; $inh = 0; goto &fetch; }
$core[007375] = 05571; $code[007375] = *P07375; sub P07375 { $pc = ($ib<<12)+$core[121]; $inh = 0; goto &fetch; }
$core[007376] = 07173; $code[007376] = *P07376; sub P07376 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[007400] = 04407; $code[007400] = *I07400; sub I07400 { $core[($ib<<12)+$core[7]] = 07401; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[007401] = 06274; $code[007401] = *I07401; sub I07401 { &emul8; goto &fetch; }
$core[007402] = 00000; $code[007402] = *D07402; sub D07402 { &emul8; goto &fetch; }
$core[007403] = 01045; $code[007403] = *I07403; sub I07403 { $lac += $core[000045]; goto &fetch; }
$core[007404] = 07710; $code[007404] = *I07404; sub I07404 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007405] = 04566; $code[007405] = *I07405; sub I07405 { $core[($ib<<12)+$core[118]] = 07406; $pc = ($ib<<12)+$core[118]+1; $code[($ib<<12)+$core[118]] = *emul8; $inh = 0; goto &fetch; }
$core[007406] = 01044; $code[007406] = *I07406; sub I07406 { $lac += $core[000044]; goto &fetch; }
$core[007407] = 07510; $code[007407] = *I07407; sub I07407 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007410] = 07020; $code[007410] = *L07410; sub L07410 { $lac ^= 010000; goto &fetch; }
$core[007411] = 07010; $code[007411] = *I07411; sub I07411 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007412] = 03270; $code[007412] = *I07412; sub I07412 { $core[007470] = $lac & 07777; $lac &= 010000; $code[007470] = *emul8; goto &fetch; }
$core[007413] = 07430; $code[007413] = *I07413; sub I07413 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007414] = 02270; $code[007414] = *I07414; sub I07414 { if (++$core[007470] == 010000) { $core[007470] = 0; $pc++; }$code[007470] = *emul8; goto &fetch; }
$core[007415] = 07000; $code[007415] = *I07415; sub I07415 { goto &fetch; }
$core[007416] = 01267; $code[007416] = *I07416; sub I07416 { $lac += $core[007467]; goto &fetch; }
$core[007417] = 03271; $code[007417] = *I07417; sub I07417 { $core[007471] = $lac & 07777; $lac &= 010000; $code[007471] = *emul8; goto &fetch; }
$core[007420] = 03272; $code[007420] = *I07420; sub I07420 { $core[007472] = $lac & 07777; $lac &= 010000; $code[007472] = *emul8; goto &fetch; }
$core[007421] = 03273; $code[007421] = *I07421; sub I07421 { $core[007473] = $lac & 07777; $lac &= 010000; $code[007473] = *emul8; goto &fetch; }
$core[007422] = 01275; $code[007422] = *I07422; sub I07422 { $lac += $core[007475]; goto &fetch; }
$core[007423] = 07450; $code[007423] = *I07423; sub I07423 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007424] = 01276; $code[007424] = *I07424; sub I07424 { $lac += $core[007476]; goto &fetch; }
$core[007425] = 07650; $code[007425] = *I07425; sub I07425 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007426] = 05265; $code[007426] = *I07426; sub I07426 { $pc = 007465; $inh = 0; goto &fetch; }
$core[007427] = 04407; $code[007427] = *L07427; sub L07427 { $core[($ib<<12)+$core[7]] = 07430; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[007430] = 00274; $code[007430] = *I07430; sub I07430 { &emul8; goto &fetch; }
$core[007431] = 03270; $code[007431] = *I07431; sub I07431 { &emul8; goto &fetch; }
$core[007432] = 01270; $code[007432] = *I07432; sub I07432 { &emul8; goto &fetch; }
$core[007433] = 00000; $code[007433] = *I07433; sub I07433 { &emul8; goto &fetch; }
$core[007434] = 07240; $code[007434] = *I07434; sub I07434 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[007435] = 01044; $code[007435] = *I07435; sub I07435 { $lac += $core[000044]; goto &fetch; }
$core[007436] = 03044; $code[007436] = *I07436; sub I07436 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007437] = 01044; $code[007437] = *I07437; sub I07437 { $lac += $core[000044]; goto &fetch; }
$core[007440] = 07041; $code[007440] = *I07440; sub I07440 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007441] = 01270; $code[007441] = *I07441; sub I07441 { $lac += $core[007470]; goto &fetch; }
$core[007442] = 07640; $code[007442] = *I07442; sub I07442 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007443] = 05261; $code[007443] = *I07443; sub I07443 { $pc = 007461; $inh = 0; goto &fetch; }
$core[007444] = 01045; $code[007444] = *I07444; sub I07444 { $lac += $core[000045]; goto &fetch; }
$core[007445] = 07041; $code[007445] = *I07445; sub I07445 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007446] = 01271; $code[007446] = *I07446; sub I07446 { $lac += $core[007471]; goto &fetch; }
$core[007447] = 07640; $code[007447] = *I07447; sub I07447 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007450] = 05261; $code[007450] = *D07450; sub D07450 { $pc = 007461; $inh = 0; goto &fetch; }
$core[007451] = 01046; $code[007451] = *I07451; sub I07451 { $lac += $core[000046]; goto &fetch; }
$core[007452] = 07041; $code[007452] = *I07452; sub I07452 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007453] = 01272; $code[007453] = *I07453; sub I07453 { $lac += $core[007472]; goto &fetch; }
$core[007454] = 07500; $code[007454] = *I07454; sub I07454 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[007455] = 07041; $code[007455] = *I07455; sub I07455 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007456] = 07001; $code[007456] = *I07456; sub I07456 { $lac++; goto &fetch; }
$core[007457] = 07700; $code[007457] = *I07457; sub I07457 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007460] = 05536; $code[007460] = *I07460; sub I07460 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[007461] = 04407; $code[007461] = *L07461; sub L07461 { $core[($ib<<12)+$core[7]] = 07462; $pc = ($ib<<12)+$core[7]+1; $code[($ib<<12)+$core[7]] = *emul8; $inh = 0; goto &fetch; }
$core[007462] = 06270; $code[007462] = *I07462; sub I07462 { &emul8; goto &fetch; }
$core[007463] = 00000; $code[007463] = *I07463; sub I07463 { &emul8; goto &fetch; }
$core[007464] = 05227; $code[007464] = *I07464; sub I07464 { $pc = 007427; $inh = 0; goto &fetch; }
$core[007465] = 03044; $code[007465] = *L07465; sub L07465 { $core[000044] = $lac & 07777; $lac &= 010000; $code[000044] = *emul8; goto &fetch; }
$core[007466] = 05536; $code[007466] = *I07466; sub I07466 { $pc = ($ib<<12)+$core[94]; $inh = 0; goto &fetch; }
$core[007467] = 03015; $code[007467] = *D07467; sub D07467 { $core[000015] = $lac & 07777; $lac &= 010000; $code[000015] = *emul8; goto &fetch; }
$core[007470] = 00000; $code[007470] = *L07470; sub L07470 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007471] = 00000; $code[007471] = *D07471; sub D07471 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007472] = 00000; $code[007472] = *D07472; sub D07472 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007473] = 00000; $code[007473] = *D07473; sub D07473 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007474] = 00000; $code[007474] = *D07474; sub D07474 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007475] = 00000; $code[007475] = *D07475; sub D07475 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007476] = 00000; $code[007476] = *D07476; sub D07476 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007477] = 07503; $code[007477] = *I07477; sub I07477 { &emul8; goto &fetch; }
$core[007503] = 01133; $code[007503] = *I07503; sub I07503 { $lac += $core[000133]; goto &fetch; }
$core[007504] = 04327; $code[007504] = *I07504; sub I07504 { $core[007527] = 07505; $pc = 007527+1; $code[007527] = *emul8; $inh = 0; goto &fetch; }
$core[007505] = 01060; $code[007505] = *I07505; sub I07505 { $lac += $core[000060]; goto &fetch; }
$core[007506] = 04327; $code[007506] = *I07506; sub I07506 { $core[007527] = 07507; $pc = 007527+1; $code[007527] = *emul8; $inh = 0; goto &fetch; }
$core[007507] = 01031; $code[007507] = *I07507; sub I07507 { $lac += $core[000031]; goto &fetch; }
$core[007510] = 04327; $code[007510] = *I07510; sub I07510 { $core[007527] = 07511; $pc = 007527+1; $code[007527] = *emul8; $inh = 0; goto &fetch; }
$core[007511] = 01035; $code[007511] = *I07511; sub I07511 { $lac += $core[000035]; goto &fetch; }
$core[007512] = 04327; $code[007512] = *I07512; sub I07512 { $core[007527] = 07513; $pc = 007527+1; $code[007527] = *emul8; $inh = 0; goto &fetch; }
$core[007513] = 05316; $code[007513] = *I07513; sub I07513 { $pc = 007516; $inh = 0; goto &fetch; }
$core[007514] = 04545; $code[007514] = *L07514; sub L07514 { $core[($ib<<12)+$core[101]] = 07515; $pc = ($ib<<12)+$core[101]+1; $code[($ib<<12)+$core[101]] = *emul8; $inh = 0; goto &fetch; }
$core[007515] = 04551; $code[007515] = *I07515; sub I07515 { $core[($ib<<12)+$core[105]] = 07516; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[007516] = 01066; $code[007516] = *L07516; sub L07516 { $lac += $core[000066]; goto &fetch; }
$core[007517] = 01116; $code[007517] = *I07517; sub I07517 { $lac += $core[000116]; goto &fetch; }
$core[007520] = 07640; $code[007520] = *I07520; sub I07520 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007521] = 05314; $code[007521] = *I07521; sub I07521 { $pc = 007514; $inh = 0; goto &fetch; }
$core[007522] = 01016; $code[007522] = *L07522; sub L07522 { $lac += $core[000016]; goto &fetch; }
$core[007523] = 07640; $code[007523] = *I07523; sub I07523 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007524] = 05322; $code[007524] = *I07524; sub I07524 { $pc = 007522; $inh = 0; goto &fetch; }
$core[007525] = 06002; $code[007525] = *I07525; sub I07525 { &emul8; goto &fetch; }
$core[007526] = 05504; $code[007526] = *I07526; sub I07526 { $pc = ($ib<<12)+$core[68]; $inh = 0; goto &fetch; }
$core[007527] = 00000; $code[007527] = *S07527; sub S07527 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007530] = 03032; $code[007530] = *I07530; sub I07530 { $core[000032] = $lac & 07777; $lac &= 010000; $code[000032] = *emul8; goto &fetch; }
$core[007531] = 01032; $code[007531] = *I07531; sub I07531 { $lac += $core[000032]; goto &fetch; }
$core[007532] = 07006; $code[007532] = *I07532; sub I07532 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007533] = 07006; $code[007533] = *I07533; sub I07533 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[007534] = 04350; $code[007534] = *I07534; sub I07534 { $core[007550] = 07535; $pc = 007550+1; $code[007550] = *emul8; $inh = 0; goto &fetch; }
$core[007535] = 04557; $code[007535] = *I07535; sub I07535 { $core[($ib<<12)+$core[111]] = 07536; $pc = ($ib<<12)+$core[111]+1; $code[($ib<<12)+$core[111]] = *emul8; $inh = 0; goto &fetch; }
$core[007536] = 07004; $code[007536] = *I07536; sub I07536 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007537] = 04350; $code[007537] = *I07537; sub I07537 { $core[007550] = 07540; $pc = 007550+1; $code[007550] = *emul8; $inh = 0; goto &fetch; }
$core[007540] = 07012; $code[007540] = *L07540; sub L07540 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[007541] = 07010; $code[007541] = *I07541; sub I07541 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007542] = 04350; $code[007542] = *I07542; sub I07542 { $core[007550] = 07543; $pc = 007550+1; $code[007550] = *emul8; $inh = 0; goto &fetch; }
$core[007543] = 04350; $code[007543] = *I07543; sub I07543 { $core[007550] = 07544; $pc = 007550+1; $code[007550] = *emul8; $inh = 0; goto &fetch; }
$core[007544] = 07200; $code[007544] = *I07544; sub I07544 { $lac &= 010000; goto &fetch; }
$core[007545] = 01077; $code[007545] = *I07545; sub I07545 { $lac += $core[000077]; goto &fetch; }
$core[007546] = 04551; $code[007546] = *I07546; sub I07546 { $core[($ib<<12)+$core[105]] = 07547; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[007547] = 05727; $code[007547] = *I07547; sub I07547 { $pc = ($ib<<12)+$core[3927]; $inh = 0; goto &fetch; }
$core[007550] = 00000; $code[007550] = *S07550; sub S07550 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007551] = 00356; $code[007551] = *I07551; sub I07551 { $lac &= (010000|$core[007556]); goto &fetch; }
$core[007552] = 01113; $code[007552] = *I07552; sub I07552 { $lac += $core[000113]; goto &fetch; }
$core[007553] = 04551; $code[007553] = *I07553; sub I07553 { $core[($ib<<12)+$core[105]] = 07554; $pc = ($ib<<12)+$core[105]+1; $code[($ib<<12)+$core[105]] = *emul8; $inh = 0; goto &fetch; }
$core[007554] = 01032; $code[007554] = *I07554; sub I07554 { $lac += $core[000032]; goto &fetch; }
$core[007555] = 05750; $code[007555] = *I07555; sub I07555 { $pc = ($ib<<12)+$core[3944]; $inh = 0; goto &fetch; }
$core[007556] = 00007; $code[007556] = *D07556; sub D07556 { $lac &= (010000|$core[000007]); goto &fetch; }
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

