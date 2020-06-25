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
$df = $ib = 0; $pc = 00147;
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
$core[000005] = 00000; $code[000005] = *I00005; sub I00005 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000006] = 07402; $code[000006] = *I00006; sub I00006 { $hlt = 1; goto &fetch; }
$core[000007] = 07000; $code[000007] = *D00007; sub D00007 { goto &fetch; }
$core[000010] = 00000; $code[000010] = *D00010; sub D00010 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000020] = 00000; $code[000020] = *D00020; sub D00020 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000021] = 00001; $code[000021] = *D00021; sub D00021 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[000022] = 00002; $code[000022] = *D00022; sub D00022 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[000023] = 00004; $code[000023] = *D00023; sub D00023 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[000024] = 00010; $code[000024] = *D00024; sub D00024 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[000025] = 00020; $code[000025] = *D00025; sub D00025 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[000026] = 00040; $code[000026] = *D00026; sub D00026 { $lac &= (010000|$core[000040]); goto &fetch; }
$core[000027] = 00100; $code[000027] = *D00027; sub D00027 { $lac &= (010000|$core[000100]); goto &fetch; }
$core[000030] = 00200; $code[000030] = *D00030; sub D00030 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000031] = 00400; $code[000031] = *D00031; sub D00031 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[000032] = 01000; $code[000032] = *D00032; sub D00032 { $lac += $core[000000]; goto &fetch; }
$core[000033] = 02000; $code[000033] = *D00033; sub D00033 { if (++$core[000000] == 010000) { $core[000000] = 0; $pc++; }$code[000000] = *emul8; goto &fetch; }
$core[000034] = 04000; $code[000034] = *D00034; sub D00034 { $core[000000] = 00035; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[000035] = 07776; $code[000035] = *D00035; sub D00035 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; $hlt = 1; goto &fetch; }
$core[000036] = 07775; $code[000036] = *D00036; sub D00036 { &emul8; goto &fetch; }
$core[000037] = 07773; $code[000037] = *D00037; sub D00037 { &emul8; goto &fetch; }
$core[000040] = 07767; $code[000040] = *D00040; sub D00040 { &emul8; goto &fetch; }
$core[000041] = 07757; $code[000041] = *D00041; sub D00041 { &emul8; goto &fetch; }
$core[000042] = 07737; $code[000042] = *D00042; sub D00042 { &emul8; goto &fetch; }
$core[000043] = 07677; $code[000043] = *D00043; sub D00043 { &emul8; goto &fetch; }
$core[000044] = 07577; $code[000044] = *D00044; sub D00044 { &emul8; goto &fetch; }
$core[000045] = 07377; $code[000045] = *D00045; sub D00045 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000046] = 06777; $code[000046] = *D00046; sub D00046 { &emul8; goto &fetch; }
$core[000047] = 05777; $code[000047] = *D00047; sub D00047 { $pc = ($ib<<12)+$core[127]; $inh = 0; goto &fetch; }
$core[000050] = 03777; $code[000050] = *D00050; sub D00050 { $core[($df<<12)+$core[127]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[127]] = *emul8; goto &fetch; }
$core[000051] = 07777; $code[000051] = *D00051; sub D00051 { &emul8; goto &fetch; }
$core[000052] = 05252; $code[000052] = *L00052; sub L00052 { $pc = 000052; $inh = 0; goto &fetch; }
$core[000053] = 02525; $code[000053] = *D00053; sub D00053 { if (++$core[($df<<12)+$core[85]] == 010000) { $core[($df<<12)+$core[85]] = 0; $pc++; }$code[($df<<12)+$core[85]] = *emul8; goto &fetch; }
$core[000054] = 06000; $code[000054] = *D00054; sub D00054 { &emul8; goto &fetch; }
$core[000055] = 07000; $code[000055] = *D00055; sub D00055 { goto &fetch; }
$core[000056] = 07400; $code[000056] = *D00056; sub D00056 { goto &fetch; }
$core[000057] = 07600; $code[000057] = *D00057; sub D00057 { $lac &= 010000; goto &fetch; }
$core[000060] = 07740; $code[000060] = *D00060; sub D00060 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000061] = 07760; $code[000061] = *D00061; sub D00061 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000062] = 07770; $code[000062] = *D00062; sub D00062 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000063] = 07774; $code[000063] = *D00063; sub D00063 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000064] = 00003; $code[000064] = *I00064; sub I00064 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000065] = 00007; $code[000065] = *I00065; sub I00065 { $lac &= (010000|$core[000007]); goto &fetch; }
$core[000066] = 00067; $code[000066] = *I00066; sub I00066 { $lac &= (010000|$core[000067]); goto &fetch; }
$core[000067] = 00017; $code[000067] = *D00067; sub D00067 { $lac &= (010000|$core[000017]); goto &fetch; }
$core[000070] = 00037; $code[000070] = *I00070; sub I00070 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[000071] = 00077; $code[000071] = *I00071; sub I00071 { $lac &= (010000|$core[000077]); goto &fetch; }
$core[000072] = 00177; $code[000072] = *I00072; sub I00072 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[000073] = 00377; $code[000073] = *I00073; sub I00073 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[000074] = 00777; $code[000074] = *I00074; sub I00074 { $lac &= (010000|$core[($df<<12)+$core[127]]); goto &fetch; }
$core[000075] = 01777; $code[000075] = *I00075; sub I00075 { $lac += $core[($df<<12)+$core[127]]; goto &fetch; }
$core[000076] = 07700; $code[000076] = *D00076; sub D00076 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000144] = 01051; $code[000144] = *I00144; sub I00144 { $lac += $core[000051]; goto &fetch; }
$core[000145] = 07200; $code[000145] = *I00145; sub I00145 { $lac &= 010000; goto &fetch; }
$core[000146] = 07402; $code[000146] = *I00146; sub I00146 { $hlt = 1; goto &fetch; }
$core[000147] = 07410; $code[000147] = *L00147; sub L00147 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000150] = 07402; $code[000150] = *I00150; sub I00150 { $hlt = 1; goto &fetch; }
$core[000151] = 07200; $code[000151] = *I00151; sub I00151 { $lac &= 010000; goto &fetch; }
$core[000152] = 07440; $code[000152] = *I00152; sub I00152 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000153] = 07402; $code[000153] = *I00153; sub I00153 { $hlt = 1; goto &fetch; }
$core[000154] = 07450; $code[000154] = *I00154; sub I00154 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000155] = 07410; $code[000155] = *I00155; sub I00155 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000156] = 07402; $code[000156] = *I00156; sub I00156 { $hlt = 1; goto &fetch; }
$core[000157] = 07200; $code[000157] = *I00157; sub I00157 { $lac &= 010000; goto &fetch; }
$core[000160] = 01034; $code[000160] = *I00160; sub I00160 { $lac += $core[000034]; goto &fetch; }
$core[000161] = 07440; $code[000161] = *I00161; sub I00161 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000162] = 07410; $code[000162] = *I00162; sub I00162 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000163] = 07402; $code[000163] = *I00163; sub I00163 { $hlt = 1; goto &fetch; }
$core[000164] = 07450; $code[000164] = *I00164; sub I00164 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000165] = 07402; $code[000165] = *I00165; sub I00165 { $hlt = 1; goto &fetch; }
$core[000166] = 07200; $code[000166] = *I00166; sub I00166 { $lac &= 010000; goto &fetch; }
$core[000167] = 01033; $code[000167] = *I00167; sub I00167 { $lac += $core[000033]; goto &fetch; }
$core[000170] = 07440; $code[000170] = *I00170; sub I00170 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000171] = 07410; $code[000171] = *I00171; sub I00171 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000172] = 07402; $code[000172] = *I00172; sub I00172 { $hlt = 1; goto &fetch; }
$core[000173] = 07450; $code[000173] = *I00173; sub I00173 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000174] = 07402; $code[000174] = *I00174; sub I00174 { $hlt = 1; goto &fetch; }
$core[000175] = 07000; $code[000175] = *I00175; sub I00175 { goto &fetch; }
$core[000176] = 07000; $code[000176] = *I00176; sub I00176 { goto &fetch; }
$core[000177] = 07000; $code[000177] = *P00177; sub P00177 { goto &fetch; }
$core[000200] = 07200; $code[000200] = *I00200; sub I00200 { $lac &= 010000; goto &fetch; }
$core[000201] = 01032; $code[000201] = *I00201; sub I00201 { $lac += $core[000032]; goto &fetch; }
$core[000202] = 07440; $code[000202] = *I00202; sub I00202 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000203] = 07410; $code[000203] = *I00203; sub I00203 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000204] = 07402; $code[000204] = *I00204; sub I00204 { $hlt = 1; goto &fetch; }
$core[000205] = 07450; $code[000205] = *I00205; sub I00205 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000206] = 07402; $code[000206] = *I00206; sub I00206 { $hlt = 1; goto &fetch; }
$core[000207] = 07200; $code[000207] = *I00207; sub I00207 { $lac &= 010000; goto &fetch; }
$core[000210] = 01031; $code[000210] = *I00210; sub I00210 { $lac += $core[000031]; goto &fetch; }
$core[000211] = 07440; $code[000211] = *I00211; sub I00211 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000212] = 07410; $code[000212] = *I00212; sub I00212 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000213] = 07402; $code[000213] = *I00213; sub I00213 { $hlt = 1; goto &fetch; }
$core[000214] = 07450; $code[000214] = *I00214; sub I00214 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000215] = 07402; $code[000215] = *I00215; sub I00215 { $hlt = 1; goto &fetch; }
$core[000216] = 07200; $code[000216] = *I00216; sub I00216 { $lac &= 010000; goto &fetch; }
$core[000217] = 01030; $code[000217] = *I00217; sub I00217 { $lac += $core[000030]; goto &fetch; }
$core[000220] = 07440; $code[000220] = *I00220; sub I00220 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000221] = 07410; $code[000221] = *I00221; sub I00221 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000222] = 07402; $code[000222] = *I00222; sub I00222 { $hlt = 1; goto &fetch; }
$core[000223] = 07450; $code[000223] = *I00223; sub I00223 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000224] = 07402; $code[000224] = *I00224; sub I00224 { $hlt = 1; goto &fetch; }
$core[000225] = 07200; $code[000225] = *I00225; sub I00225 { $lac &= 010000; goto &fetch; }
$core[000226] = 01027; $code[000226] = *I00226; sub I00226 { $lac += $core[000027]; goto &fetch; }
$core[000227] = 07440; $code[000227] = *I00227; sub I00227 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000230] = 07410; $code[000230] = *I00230; sub I00230 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000231] = 07402; $code[000231] = *I00231; sub I00231 { $hlt = 1; goto &fetch; }
$core[000232] = 07450; $code[000232] = *I00232; sub I00232 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000233] = 07402; $code[000233] = *I00233; sub I00233 { $hlt = 1; goto &fetch; }
$core[000234] = 07200; $code[000234] = *I00234; sub I00234 { $lac &= 010000; goto &fetch; }
$core[000235] = 01026; $code[000235] = *I00235; sub I00235 { $lac += $core[000026]; goto &fetch; }
$core[000236] = 07440; $code[000236] = *I00236; sub I00236 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000237] = 07410; $code[000237] = *I00237; sub I00237 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000240] = 07402; $code[000240] = *I00240; sub I00240 { $hlt = 1; goto &fetch; }
$core[000241] = 07450; $code[000241] = *I00241; sub I00241 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000242] = 07402; $code[000242] = *I00242; sub I00242 { $hlt = 1; goto &fetch; }
$core[000243] = 07200; $code[000243] = *I00243; sub I00243 { $lac &= 010000; goto &fetch; }
$core[000244] = 01025; $code[000244] = *I00244; sub I00244 { $lac += $core[000025]; goto &fetch; }
$core[000245] = 07440; $code[000245] = *I00245; sub I00245 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000246] = 07410; $code[000246] = *I00246; sub I00246 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000247] = 07402; $code[000247] = *I00247; sub I00247 { $hlt = 1; goto &fetch; }
$core[000250] = 07450; $code[000250] = *I00250; sub I00250 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000251] = 07402; $code[000251] = *I00251; sub I00251 { $hlt = 1; goto &fetch; }
$core[000252] = 07200; $code[000252] = *I00252; sub I00252 { $lac &= 010000; goto &fetch; }
$core[000253] = 01024; $code[000253] = *I00253; sub I00253 { $lac += $core[000024]; goto &fetch; }
$core[000254] = 07440; $code[000254] = *I00254; sub I00254 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000255] = 07410; $code[000255] = *I00255; sub I00255 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000256] = 07402; $code[000256] = *I00256; sub I00256 { $hlt = 1; goto &fetch; }
$core[000257] = 07450; $code[000257] = *I00257; sub I00257 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000260] = 07402; $code[000260] = *I00260; sub I00260 { $hlt = 1; goto &fetch; }
$core[000261] = 07200; $code[000261] = *I00261; sub I00261 { $lac &= 010000; goto &fetch; }
$core[000262] = 01023; $code[000262] = *I00262; sub I00262 { $lac += $core[000023]; goto &fetch; }
$core[000263] = 07440; $code[000263] = *I00263; sub I00263 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000264] = 07410; $code[000264] = *I00264; sub I00264 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000265] = 07402; $code[000265] = *I00265; sub I00265 { $hlt = 1; goto &fetch; }
$core[000266] = 07450; $code[000266] = *I00266; sub I00266 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000267] = 07402; $code[000267] = *I00267; sub I00267 { $hlt = 1; goto &fetch; }
$core[000270] = 07200; $code[000270] = *I00270; sub I00270 { $lac &= 010000; goto &fetch; }
$core[000271] = 01022; $code[000271] = *I00271; sub I00271 { $lac += $core[000022]; goto &fetch; }
$core[000272] = 07440; $code[000272] = *I00272; sub I00272 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000273] = 07410; $code[000273] = *I00273; sub I00273 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000274] = 07402; $code[000274] = *I00274; sub I00274 { $hlt = 1; goto &fetch; }
$core[000275] = 07450; $code[000275] = *I00275; sub I00275 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000276] = 07402; $code[000276] = *I00276; sub I00276 { $hlt = 1; goto &fetch; }
$core[000277] = 07200; $code[000277] = *I00277; sub I00277 { $lac &= 010000; goto &fetch; }
$core[000300] = 01021; $code[000300] = *I00300; sub I00300 { $lac += $core[000021]; goto &fetch; }
$core[000301] = 07440; $code[000301] = *I00301; sub I00301 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000302] = 07410; $code[000302] = *I00302; sub I00302 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000303] = 07402; $code[000303] = *I00303; sub I00303 { $hlt = 1; goto &fetch; }
$core[000304] = 07450; $code[000304] = *I00304; sub I00304 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000305] = 07402; $code[000305] = *I00305; sub I00305 { $hlt = 1; goto &fetch; }
$core[000306] = 07200; $code[000306] = *I00306; sub I00306 { $lac &= 010000; goto &fetch; }
$core[000307] = 01050; $code[000307] = *I00307; sub I00307 { $lac += $core[000050]; goto &fetch; }
$core[000310] = 07510; $code[000310] = *I00310; sub I00310 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000311] = 07402; $code[000311] = *I00311; sub I00311 { $hlt = 1; goto &fetch; }
$core[000312] = 07200; $code[000312] = *I00312; sub I00312 { $lac &= 010000; goto &fetch; }
$core[000313] = 01034; $code[000313] = *I00313; sub I00313 { $lac += $core[000034]; goto &fetch; }
$core[000314] = 07510; $code[000314] = *I00314; sub I00314 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000315] = 07410; $code[000315] = *I00315; sub I00315 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000316] = 07402; $code[000316] = *I00316; sub I00316 { $hlt = 1; goto &fetch; }
$core[000317] = 07200; $code[000317] = *I00317; sub I00317 { $lac &= 010000; goto &fetch; }
$core[000320] = 01050; $code[000320] = *I00320; sub I00320 { $lac += $core[000050]; goto &fetch; }
$core[000321] = 07500; $code[000321] = *I00321; sub I00321 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000322] = 07410; $code[000322] = *I00322; sub I00322 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000323] = 07402; $code[000323] = *I00323; sub I00323 { $hlt = 1; goto &fetch; }
$core[000324] = 07200; $code[000324] = *I00324; sub I00324 { $lac &= 010000; goto &fetch; }
$core[000325] = 01034; $code[000325] = *I00325; sub I00325 { $lac += $core[000034]; goto &fetch; }
$core[000326] = 07500; $code[000326] = *I00326; sub I00326 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[000327] = 07402; $code[000327] = *I00327; sub I00327 { $hlt = 1; goto &fetch; }
$core[000330] = 07200; $code[000330] = *I00330; sub I00330 { $lac &= 010000; goto &fetch; }
$core[000331] = 01051; $code[000331] = *I00331; sub I00331 { $lac += $core[000051]; goto &fetch; }
$core[000332] = 07040; $code[000332] = *I00332; sub I00332 { $lac ^= 07777; goto &fetch; }
$core[000333] = 07440; $code[000333] = *I00333; sub I00333 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000334] = 07402; $code[000334] = *I00334; sub I00334 { $hlt = 1; goto &fetch; }
$core[000335] = 07200; $code[000335] = *I00335; sub I00335 { $lac &= 010000; goto &fetch; }
$core[000336] = 01053; $code[000336] = *I00336; sub I00336 { $lac += $core[000053]; goto &fetch; }
$core[000337] = 07040; $code[000337] = *I00337; sub I00337 { $lac ^= 07777; goto &fetch; }
$core[000340] = 07450; $code[000340] = *I00340; sub I00340 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000341] = 07402; $code[000341] = *I00341; sub I00341 { $hlt = 1; goto &fetch; }
$core[000342] = 01053; $code[000342] = *I00342; sub I00342 { $lac += $core[000053]; goto &fetch; }
$core[000343] = 07040; $code[000343] = *I00343; sub I00343 { $lac ^= 07777; goto &fetch; }
$core[000344] = 07440; $code[000344] = *I00344; sub I00344 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000345] = 07402; $code[000345] = *I00345; sub I00345 { $hlt = 1; goto &fetch; }
$core[000346] = 07200; $code[000346] = *I00346; sub I00346 { $lac &= 010000; goto &fetch; }
$core[000347] = 01052; $code[000347] = *I00347; sub I00347 { $lac += $core[000052]; goto &fetch; }
$core[000350] = 07040; $code[000350] = *I00350; sub I00350 { $lac ^= 07777; goto &fetch; }
$core[000351] = 07450; $code[000351] = *I00351; sub I00351 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000352] = 07402; $code[000352] = *I00352; sub I00352 { $hlt = 1; goto &fetch; }
$core[000353] = 01052; $code[000353] = *I00353; sub I00353 { $lac += $core[000052]; goto &fetch; }
$core[000354] = 07040; $code[000354] = *I00354; sub I00354 { $lac ^= 07777; goto &fetch; }
$core[000355] = 07440; $code[000355] = *I00355; sub I00355 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000356] = 07402; $code[000356] = *I00356; sub I00356 { $hlt = 1; goto &fetch; }
$core[000357] = 07200; $code[000357] = *I00357; sub I00357 { $lac &= 010000; goto &fetch; }
$core[000360] = 01051; $code[000360] = *I00360; sub I00360 { $lac += $core[000051]; goto &fetch; }
$core[000361] = 07040; $code[000361] = *I00361; sub I00361 { $lac ^= 07777; goto &fetch; }
$core[000362] = 07440; $code[000362] = *I00362; sub I00362 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000363] = 07402; $code[000363] = *I00363; sub I00363 { $hlt = 1; goto &fetch; }
$core[000364] = 07200; $code[000364] = *I00364; sub I00364 { $lac &= 010000; goto &fetch; }
$core[000365] = 07001; $code[000365] = *I00365; sub I00365 { $lac++; goto &fetch; }
$core[000366] = 07440; $code[000366] = *I00366; sub I00366 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000367] = 07410; $code[000367] = *I00367; sub I00367 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000370] = 07402; $code[000370] = *I00370; sub I00370 { $hlt = 1; goto &fetch; }
$core[000371] = 07200; $code[000371] = *I00371; sub I00371 { $lac &= 010000; goto &fetch; }
$core[000372] = 01051; $code[000372] = *I00372; sub I00372 { $lac += $core[000051]; goto &fetch; }
$core[000373] = 07001; $code[000373] = *I00373; sub I00373 { $lac++; goto &fetch; }
$core[000374] = 07440; $code[000374] = *I00374; sub I00374 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000375] = 07402; $code[000375] = *I00375; sub I00375 { $hlt = 1; goto &fetch; }
$core[000376] = 07000; $code[000376] = *I00376; sub I00376 { goto &fetch; }
$core[000377] = 07000; $code[000377] = *I00377; sub I00377 { goto &fetch; }
$core[000400] = 07200; $code[000400] = *I00400; sub I00400 { $lac &= 010000; goto &fetch; }
$core[000401] = 01063; $code[000401] = *I00401; sub I00401 { $lac += $core[000063]; goto &fetch; }
$core[000402] = 07001; $code[000402] = *I00402; sub I00402 { $lac++; goto &fetch; }
$core[000403] = 07001; $code[000403] = *I00403; sub I00403 { $lac++; goto &fetch; }
$core[000404] = 07001; $code[000404] = *I00404; sub I00404 { $lac++; goto &fetch; }
$core[000405] = 07001; $code[000405] = *I00405; sub I00405 { $lac++; goto &fetch; }
$core[000406] = 07440; $code[000406] = *I00406; sub I00406 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000407] = 07402; $code[000407] = *I00407; sub I00407 { $hlt = 1; goto &fetch; }
$core[000410] = 07200; $code[000410] = *I00410; sub I00410 { $lac &= 010000; goto &fetch; }
$core[000411] = 07100; $code[000411] = *I00411; sub I00411 { $lac &= 07777; goto &fetch; }
$core[000412] = 07004; $code[000412] = *I00412; sub I00412 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000413] = 07430; $code[000413] = *I00413; sub I00413 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000414] = 07402; $code[000414] = *I00414; sub I00414 { $hlt = 1; goto &fetch; }
$core[000415] = 07200; $code[000415] = *I00415; sub I00415 { $lac &= 010000; goto &fetch; }
$core[000416] = 07100; $code[000416] = *I00416; sub I00416 { $lac &= 07777; goto &fetch; }
$core[000417] = 07020; $code[000417] = *I00417; sub I00417 { $lac ^= 010000; goto &fetch; }
$core[000420] = 01034; $code[000420] = *I00420; sub I00420 { $lac += $core[000034]; goto &fetch; }
$core[000421] = 07004; $code[000421] = *I00421; sub I00421 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000422] = 07430; $code[000422] = *I00422; sub I00422 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000423] = 07410; $code[000423] = *I00423; sub I00423 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000424] = 07402; $code[000424] = *I00424; sub I00424 { $hlt = 1; goto &fetch; }
$core[000425] = 07200; $code[000425] = *I00425; sub I00425 { $lac &= 010000; goto &fetch; }
$core[000426] = 07100; $code[000426] = *I00426; sub I00426 { $lac &= 07777; goto &fetch; }
$core[000427] = 07004; $code[000427] = *I00427; sub I00427 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000430] = 07420; $code[000430] = *I00430; sub I00430 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000431] = 07410; $code[000431] = *I00431; sub I00431 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000432] = 07402; $code[000432] = *I00432; sub I00432 { $hlt = 1; goto &fetch; }
$core[000433] = 07200; $code[000433] = *I00433; sub I00433 { $lac &= 010000; goto &fetch; }
$core[000434] = 07100; $code[000434] = *I00434; sub I00434 { $lac &= 07777; goto &fetch; }
$core[000435] = 07020; $code[000435] = *I00435; sub I00435 { $lac ^= 010000; goto &fetch; }
$core[000436] = 01034; $code[000436] = *I00436; sub I00436 { $lac += $core[000034]; goto &fetch; }
$core[000437] = 07004; $code[000437] = *I00437; sub I00437 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000440] = 07420; $code[000440] = *I00440; sub I00440 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000441] = 07402; $code[000441] = *I00441; sub I00441 { $hlt = 1; goto &fetch; }
$core[000442] = 07200; $code[000442] = *I00442; sub I00442 { $lac &= 010000; goto &fetch; }
$core[000443] = 01034; $code[000443] = *I00443; sub I00443 { $lac += $core[000034]; goto &fetch; }
$core[000444] = 07004; $code[000444] = *I00444; sub I00444 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000445] = 07420; $code[000445] = *I00445; sub I00445 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000446] = 05253; $code[000446] = *I00446; sub I00446 { $pc = 000453; $inh = 0; goto &fetch; }
$core[000447] = 07100; $code[000447] = *L00447; sub L00447 { $lac &= 07777; goto &fetch; }
$core[000450] = 07430; $code[000450] = *I00450; sub I00450 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000451] = 07402; $code[000451] = *I00451; sub I00451 { $hlt = 1; goto &fetch; }
$core[000452] = 05257; $code[000452] = *I00452; sub I00452 { $pc = 000457; $inh = 0; goto &fetch; }
$core[000453] = 07020; $code[000453] = *L00453; sub L00453 { $lac ^= 010000; goto &fetch; }
$core[000454] = 07420; $code[000454] = *I00454; sub I00454 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000455] = 07402; $code[000455] = *I00455; sub I00455 { $hlt = 1; goto &fetch; }
$core[000456] = 05247; $code[000456] = *I00456; sub I00456 { $pc = 000447; $inh = 0; goto &fetch; }
$core[000457] = 07100; $code[000457] = *L00457; sub L00457 { $lac &= 07777; goto &fetch; }
$core[000460] = 07430; $code[000460] = *I00460; sub I00460 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000461] = 07402; $code[000461] = *I00461; sub I00461 { $hlt = 1; goto &fetch; }
$core[000462] = 07020; $code[000462] = *I00462; sub I00462 { $lac ^= 010000; goto &fetch; }
$core[000463] = 07420; $code[000463] = *I00463; sub I00463 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000464] = 07402; $code[000464] = *I00464; sub I00464 { $hlt = 1; goto &fetch; }
$core[000465] = 07020; $code[000465] = *I00465; sub I00465 { $lac ^= 010000; goto &fetch; }
$core[000466] = 07430; $code[000466] = *I00466; sub I00466 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000467] = 07402; $code[000467] = *I00467; sub I00467 { $hlt = 1; goto &fetch; }
$core[000470] = 07200; $code[000470] = *I00470; sub I00470 { $lac &= 010000; goto &fetch; }
$core[000471] = 01051; $code[000471] = *I00471; sub I00471 { $lac += $core[000051]; goto &fetch; }
$core[000472] = 07600; $code[000472] = *I00472; sub I00472 { $lac &= 010000; goto &fetch; }
$core[000473] = 07440; $code[000473] = *I00473; sub I00473 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000474] = 07402; $code[000474] = *I00474; sub I00474 { $hlt = 1; goto &fetch; }
$core[000475] = 07200; $code[000475] = *I00475; sub I00475 { $lac &= 010000; goto &fetch; }
$core[000476] = 07404; $code[000476] = *I00476; sub I00476 { $lac |= $swr; goto &fetch; }
$core[000477] = 07040; $code[000477] = *I00477; sub I00477 { $lac ^= 07777; goto &fetch; }
$core[000500] = 07440; $code[000500] = *I00500; sub I00500 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000501] = 07402; $code[000501] = *I00501; sub I00501 { $hlt = 1; goto &fetch; }
$core[000502] = 07200; $code[000502] = *I00502; sub I00502 { $lac &= 010000; goto &fetch; }
$core[000503] = 07100; $code[000503] = *I00503; sub I00503 { $lac &= 07777; goto &fetch; }
$core[000504] = 07000; $code[000504] = *I00504; sub I00504 { goto &fetch; }
$core[000505] = 07450; $code[000505] = *I00505; sub I00505 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000506] = 07430; $code[000506] = *I00506; sub I00506 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000507] = 07402; $code[000507] = *I00507; sub I00507 { $hlt = 1; goto &fetch; }
$core[000510] = 07200; $code[000510] = *I00510; sub I00510 { $lac &= 010000; goto &fetch; }
$core[000511] = 07100; $code[000511] = *I00511; sub I00511 { $lac &= 07777; goto &fetch; }
$core[000512] = 07400; $code[000512] = *I00512; sub I00512 { goto &fetch; }
$core[000513] = 07450; $code[000513] = *I00513; sub I00513 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000514] = 07430; $code[000514] = *I00514; sub I00514 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000515] = 07402; $code[000515] = *I00515; sub I00515 { $hlt = 1; goto &fetch; }
$core[000516] = 07200; $code[000516] = *I00516; sub I00516 { $lac &= 010000; goto &fetch; }
$core[000517] = 01050; $code[000517] = *I00517; sub I00517 { $lac += $core[000050]; goto &fetch; }
$core[000520] = 01034; $code[000520] = *I00520; sub I00520 { $lac += $core[000034]; goto &fetch; }
$core[000521] = 07040; $code[000521] = *I00521; sub I00521 { $lac ^= 07777; goto &fetch; }
$core[000522] = 07440; $code[000522] = *I00522; sub I00522 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000523] = 07402; $code[000523] = *I00523; sub I00523 { $hlt = 1; goto &fetch; }
$core[000524] = 07200; $code[000524] = *I00524; sub I00524 { $lac &= 010000; goto &fetch; }
$core[000525] = 01047; $code[000525] = *I00525; sub I00525 { $lac += $core[000047]; goto &fetch; }
$core[000526] = 01033; $code[000526] = *I00526; sub I00526 { $lac += $core[000033]; goto &fetch; }
$core[000527] = 07040; $code[000527] = *I00527; sub I00527 { $lac ^= 07777; goto &fetch; }
$core[000530] = 07440; $code[000530] = *I00530; sub I00530 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000531] = 07402; $code[000531] = *I00531; sub I00531 { $hlt = 1; goto &fetch; }
$core[000532] = 07200; $code[000532] = *I00532; sub I00532 { $lac &= 010000; goto &fetch; }
$core[000533] = 01046; $code[000533] = *I00533; sub I00533 { $lac += $core[000046]; goto &fetch; }
$core[000534] = 01032; $code[000534] = *I00534; sub I00534 { $lac += $core[000032]; goto &fetch; }
$core[000535] = 07040; $code[000535] = *I00535; sub I00535 { $lac ^= 07777; goto &fetch; }
$core[000536] = 07440; $code[000536] = *I00536; sub I00536 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000537] = 07402; $code[000537] = *I00537; sub I00537 { $hlt = 1; goto &fetch; }
$core[000540] = 07200; $code[000540] = *I00540; sub I00540 { $lac &= 010000; goto &fetch; }
$core[000541] = 01045; $code[000541] = *I00541; sub I00541 { $lac += $core[000045]; goto &fetch; }
$core[000542] = 01031; $code[000542] = *I00542; sub I00542 { $lac += $core[000031]; goto &fetch; }
$core[000543] = 07040; $code[000543] = *I00543; sub I00543 { $lac ^= 07777; goto &fetch; }
$core[000544] = 07440; $code[000544] = *I00544; sub I00544 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000545] = 07402; $code[000545] = *I00545; sub I00545 { $hlt = 1; goto &fetch; }
$core[000546] = 07200; $code[000546] = *I00546; sub I00546 { $lac &= 010000; goto &fetch; }
$core[000547] = 01044; $code[000547] = *I00547; sub I00547 { $lac += $core[000044]; goto &fetch; }
$core[000550] = 01030; $code[000550] = *I00550; sub I00550 { $lac += $core[000030]; goto &fetch; }
$core[000551] = 07040; $code[000551] = *I00551; sub I00551 { $lac ^= 07777; goto &fetch; }
$core[000552] = 07440; $code[000552] = *I00552; sub I00552 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000553] = 07402; $code[000553] = *I00553; sub I00553 { $hlt = 1; goto &fetch; }
$core[000554] = 07200; $code[000554] = *I00554; sub I00554 { $lac &= 010000; goto &fetch; }
$core[000555] = 01043; $code[000555] = *I00555; sub I00555 { $lac += $core[000043]; goto &fetch; }
$core[000556] = 01027; $code[000556] = *I00556; sub I00556 { $lac += $core[000027]; goto &fetch; }
$core[000557] = 07040; $code[000557] = *I00557; sub I00557 { $lac ^= 07777; goto &fetch; }
$core[000560] = 07440; $code[000560] = *I00560; sub I00560 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000561] = 07402; $code[000561] = *I00561; sub I00561 { $hlt = 1; goto &fetch; }
$core[000562] = 07200; $code[000562] = *I00562; sub I00562 { $lac &= 010000; goto &fetch; }
$core[000563] = 01042; $code[000563] = *I00563; sub I00563 { $lac += $core[000042]; goto &fetch; }
$core[000564] = 01026; $code[000564] = *I00564; sub I00564 { $lac += $core[000026]; goto &fetch; }
$core[000565] = 07040; $code[000565] = *I00565; sub I00565 { $lac ^= 07777; goto &fetch; }
$core[000566] = 07440; $code[000566] = *I00566; sub I00566 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000567] = 07402; $code[000567] = *I00567; sub I00567 { $hlt = 1; goto &fetch; }
$core[000570] = 07200; $code[000570] = *I00570; sub I00570 { $lac &= 010000; goto &fetch; }
$core[000571] = 01041; $code[000571] = *I00571; sub I00571 { $lac += $core[000041]; goto &fetch; }
$core[000572] = 01025; $code[000572] = *I00572; sub I00572 { $lac += $core[000025]; goto &fetch; }
$core[000573] = 07040; $code[000573] = *I00573; sub I00573 { $lac ^= 07777; goto &fetch; }
$core[000574] = 07440; $code[000574] = *I00574; sub I00574 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000575] = 07402; $code[000575] = *I00575; sub I00575 { $hlt = 1; goto &fetch; }
$core[000576] = 07000; $code[000576] = *I00576; sub I00576 { goto &fetch; }
$core[000577] = 07000; $code[000577] = *I00577; sub I00577 { goto &fetch; }
$core[000600] = 07200; $code[000600] = *I00600; sub I00600 { $lac &= 010000; goto &fetch; }
$core[000601] = 01040; $code[000601] = *I00601; sub I00601 { $lac += $core[000040]; goto &fetch; }
$core[000602] = 01024; $code[000602] = *I00602; sub I00602 { $lac += $core[000024]; goto &fetch; }
$core[000603] = 07040; $code[000603] = *I00603; sub I00603 { $lac ^= 07777; goto &fetch; }
$core[000604] = 07440; $code[000604] = *I00604; sub I00604 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000605] = 07402; $code[000605] = *I00605; sub I00605 { $hlt = 1; goto &fetch; }
$core[000606] = 07200; $code[000606] = *I00606; sub I00606 { $lac &= 010000; goto &fetch; }
$core[000607] = 01037; $code[000607] = *I00607; sub I00607 { $lac += $core[000037]; goto &fetch; }
$core[000610] = 01023; $code[000610] = *I00610; sub I00610 { $lac += $core[000023]; goto &fetch; }
$core[000611] = 07040; $code[000611] = *I00611; sub I00611 { $lac ^= 07777; goto &fetch; }
$core[000612] = 07440; $code[000612] = *I00612; sub I00612 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000613] = 07402; $code[000613] = *I00613; sub I00613 { $hlt = 1; goto &fetch; }
$core[000614] = 07200; $code[000614] = *I00614; sub I00614 { $lac &= 010000; goto &fetch; }
$core[000615] = 01036; $code[000615] = *I00615; sub I00615 { $lac += $core[000036]; goto &fetch; }
$core[000616] = 01022; $code[000616] = *I00616; sub I00616 { $lac += $core[000022]; goto &fetch; }
$core[000617] = 07040; $code[000617] = *I00617; sub I00617 { $lac ^= 07777; goto &fetch; }
$core[000620] = 07440; $code[000620] = *I00620; sub I00620 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000621] = 07402; $code[000621] = *I00621; sub I00621 { $hlt = 1; goto &fetch; }
$core[000622] = 07200; $code[000622] = *I00622; sub I00622 { $lac &= 010000; goto &fetch; }
$core[000623] = 01035; $code[000623] = *I00623; sub I00623 { $lac += $core[000035]; goto &fetch; }
$core[000624] = 01021; $code[000624] = *I00624; sub I00624 { $lac += $core[000021]; goto &fetch; }
$core[000625] = 07040; $code[000625] = *I00625; sub I00625 { $lac ^= 07777; goto &fetch; }
$core[000626] = 07440; $code[000626] = *I00626; sub I00626 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000627] = 07402; $code[000627] = *I00627; sub I00627 { $hlt = 1; goto &fetch; }
$core[000630] = 07200; $code[000630] = *I00630; sub I00630 { $lac &= 010000; goto &fetch; }
$core[000631] = 07100; $code[000631] = *I00631; sub I00631 { $lac &= 07777; goto &fetch; }
$core[000632] = 01034; $code[000632] = *I00632; sub I00632 { $lac += $core[000034]; goto &fetch; }
$core[000633] = 01034; $code[000633] = *I00633; sub I00633 { $lac += $core[000034]; goto &fetch; }
$core[000634] = 07430; $code[000634] = *I00634; sub I00634 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000635] = 07440; $code[000635] = *I00635; sub I00635 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000636] = 07402; $code[000636] = *I00636; sub I00636 { $hlt = 1; goto &fetch; }
$core[000637] = 07200; $code[000637] = *I00637; sub I00637 { $lac &= 010000; goto &fetch; }
$core[000640] = 07100; $code[000640] = *I00640; sub I00640 { $lac &= 07777; goto &fetch; }
$core[000641] = 01054; $code[000641] = *I00641; sub I00641 { $lac += $core[000054]; goto &fetch; }
$core[000642] = 01033; $code[000642] = *I00642; sub I00642 { $lac += $core[000033]; goto &fetch; }
$core[000643] = 07430; $code[000643] = *I00643; sub I00643 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000644] = 07440; $code[000644] = *I00644; sub I00644 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000645] = 07402; $code[000645] = *I00645; sub I00645 { $hlt = 1; goto &fetch; }
$core[000646] = 07200; $code[000646] = *I00646; sub I00646 { $lac &= 010000; goto &fetch; }
$core[000647] = 07100; $code[000647] = *I00647; sub I00647 { $lac &= 07777; goto &fetch; }
$core[000650] = 01055; $code[000650] = *I00650; sub I00650 { $lac += $core[000055]; goto &fetch; }
$core[000651] = 01032; $code[000651] = *I00651; sub I00651 { $lac += $core[000032]; goto &fetch; }
$core[000652] = 07430; $code[000652] = *I00652; sub I00652 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000653] = 07440; $code[000653] = *I00653; sub I00653 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000654] = 07402; $code[000654] = *I00654; sub I00654 { $hlt = 1; goto &fetch; }
$core[000655] = 07200; $code[000655] = *I00655; sub I00655 { $lac &= 010000; goto &fetch; }
$core[000656] = 07100; $code[000656] = *I00656; sub I00656 { $lac &= 07777; goto &fetch; }
$core[000657] = 01056; $code[000657] = *I00657; sub I00657 { $lac += $core[000056]; goto &fetch; }
$core[000660] = 01031; $code[000660] = *I00660; sub I00660 { $lac += $core[000031]; goto &fetch; }
$core[000661] = 07430; $code[000661] = *I00661; sub I00661 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000662] = 07440; $code[000662] = *I00662; sub I00662 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000663] = 07402; $code[000663] = *I00663; sub I00663 { $hlt = 1; goto &fetch; }
$core[000664] = 07200; $code[000664] = *I00664; sub I00664 { $lac &= 010000; goto &fetch; }
$core[000665] = 07100; $code[000665] = *I00665; sub I00665 { $lac &= 07777; goto &fetch; }
$core[000666] = 01057; $code[000666] = *I00666; sub I00666 { $lac += $core[000057]; goto &fetch; }
$core[000667] = 01030; $code[000667] = *I00667; sub I00667 { $lac += $core[000030]; goto &fetch; }
$core[000670] = 07430; $code[000670] = *I00670; sub I00670 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000671] = 07440; $code[000671] = *I00671; sub I00671 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000672] = 07402; $code[000672] = *I00672; sub I00672 { $hlt = 1; goto &fetch; }
$core[000673] = 07200; $code[000673] = *I00673; sub I00673 { $lac &= 010000; goto &fetch; }
$core[000674] = 07100; $code[000674] = *I00674; sub I00674 { $lac &= 07777; goto &fetch; }
$core[000675] = 01076; $code[000675] = *I00675; sub I00675 { $lac += $core[000076]; goto &fetch; }
$core[000676] = 01027; $code[000676] = *I00676; sub I00676 { $lac += $core[000027]; goto &fetch; }
$core[000677] = 07430; $code[000677] = *I00677; sub I00677 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000700] = 07440; $code[000700] = *I00700; sub I00700 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000701] = 07402; $code[000701] = *I00701; sub I00701 { $hlt = 1; goto &fetch; }
$core[000702] = 07200; $code[000702] = *I00702; sub I00702 { $lac &= 010000; goto &fetch; }
$core[000703] = 07100; $code[000703] = *I00703; sub I00703 { $lac &= 07777; goto &fetch; }
$core[000704] = 01060; $code[000704] = *I00704; sub I00704 { $lac += $core[000060]; goto &fetch; }
$core[000705] = 01026; $code[000705] = *I00705; sub I00705 { $lac += $core[000026]; goto &fetch; }
$core[000706] = 07430; $code[000706] = *I00706; sub I00706 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000707] = 07440; $code[000707] = *I00707; sub I00707 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000710] = 07402; $code[000710] = *I00710; sub I00710 { $hlt = 1; goto &fetch; }
$core[000711] = 07200; $code[000711] = *I00711; sub I00711 { $lac &= 010000; goto &fetch; }
$core[000712] = 07100; $code[000712] = *I00712; sub I00712 { $lac &= 07777; goto &fetch; }
$core[000713] = 01061; $code[000713] = *I00713; sub I00713 { $lac += $core[000061]; goto &fetch; }
$core[000714] = 01025; $code[000714] = *I00714; sub I00714 { $lac += $core[000025]; goto &fetch; }
$core[000715] = 07430; $code[000715] = *I00715; sub I00715 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000716] = 07440; $code[000716] = *I00716; sub I00716 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000717] = 07402; $code[000717] = *I00717; sub I00717 { $hlt = 1; goto &fetch; }
$core[000720] = 07200; $code[000720] = *I00720; sub I00720 { $lac &= 010000; goto &fetch; }
$core[000721] = 07100; $code[000721] = *I00721; sub I00721 { $lac &= 07777; goto &fetch; }
$core[000722] = 01062; $code[000722] = *I00722; sub I00722 { $lac += $core[000062]; goto &fetch; }
$core[000723] = 01024; $code[000723] = *I00723; sub I00723 { $lac += $core[000024]; goto &fetch; }
$core[000724] = 07430; $code[000724] = *I00724; sub I00724 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000725] = 07440; $code[000725] = *I00725; sub I00725 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000726] = 07402; $code[000726] = *I00726; sub I00726 { $hlt = 1; goto &fetch; }
$core[000727] = 07200; $code[000727] = *I00727; sub I00727 { $lac &= 010000; goto &fetch; }
$core[000730] = 07100; $code[000730] = *I00730; sub I00730 { $lac &= 07777; goto &fetch; }
$core[000731] = 01063; $code[000731] = *I00731; sub I00731 { $lac += $core[000063]; goto &fetch; }
$core[000732] = 01023; $code[000732] = *I00732; sub I00732 { $lac += $core[000023]; goto &fetch; }
$core[000733] = 07430; $code[000733] = *I00733; sub I00733 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000734] = 07440; $code[000734] = *I00734; sub I00734 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000735] = 07402; $code[000735] = *I00735; sub I00735 { $hlt = 1; goto &fetch; }
$core[000736] = 07200; $code[000736] = *I00736; sub I00736 { $lac &= 010000; goto &fetch; }
$core[000737] = 07100; $code[000737] = *I00737; sub I00737 { $lac &= 07777; goto &fetch; }
$core[000740] = 01035; $code[000740] = *I00740; sub I00740 { $lac += $core[000035]; goto &fetch; }
$core[000741] = 01022; $code[000741] = *I00741; sub I00741 { $lac += $core[000022]; goto &fetch; }
$core[000742] = 07430; $code[000742] = *I00742; sub I00742 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000743] = 07440; $code[000743] = *I00743; sub I00743 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000744] = 07402; $code[000744] = *I00744; sub I00744 { $hlt = 1; goto &fetch; }
$core[000745] = 07200; $code[000745] = *I00745; sub I00745 { $lac &= 010000; goto &fetch; }
$core[000746] = 07100; $code[000746] = *I00746; sub I00746 { $lac &= 07777; goto &fetch; }
$core[000747] = 01051; $code[000747] = *I00747; sub I00747 { $lac += $core[000051]; goto &fetch; }
$core[000750] = 01021; $code[000750] = *I00750; sub I00750 { $lac += $core[000021]; goto &fetch; }
$core[000751] = 07430; $code[000751] = *I00751; sub I00751 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000752] = 07440; $code[000752] = *I00752; sub I00752 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000753] = 07402; $code[000753] = *I00753; sub I00753 { $hlt = 1; goto &fetch; }
$core[000754] = 07200; $code[000754] = *I00754; sub I00754 { $lac &= 010000; goto &fetch; }
$core[000755] = 07100; $code[000755] = *I00755; sub I00755 { $lac &= 07777; goto &fetch; }
$core[000756] = 07020; $code[000756] = *I00756; sub I00756 { $lac ^= 010000; goto &fetch; }
$core[000757] = 01034; $code[000757] = *I00757; sub I00757 { $lac += $core[000034]; goto &fetch; }
$core[000760] = 01034; $code[000760] = *I00760; sub I00760 { $lac += $core[000034]; goto &fetch; }
$core[000761] = 07420; $code[000761] = *I00761; sub I00761 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000762] = 07440; $code[000762] = *I00762; sub I00762 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000763] = 07402; $code[000763] = *I00763; sub I00763 { $hlt = 1; goto &fetch; }
$core[000764] = 07200; $code[000764] = *I00764; sub I00764 { $lac &= 010000; goto &fetch; }
$core[000765] = 07100; $code[000765] = *I00765; sub I00765 { $lac &= 07777; goto &fetch; }
$core[000766] = 01050; $code[000766] = *I00766; sub I00766 { $lac += $core[000050]; goto &fetch; }
$core[000767] = 01033; $code[000767] = *I00767; sub I00767 { $lac += $core[000033]; goto &fetch; }
$core[000770] = 01033; $code[000770] = *I00770; sub I00770 { $lac += $core[000033]; goto &fetch; }
$core[000771] = 07040; $code[000771] = *I00771; sub I00771 { $lac ^= 07777; goto &fetch; }
$core[000772] = 07420; $code[000772] = *I00772; sub I00772 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[000773] = 07440; $code[000773] = *I00773; sub I00773 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[000774] = 07402; $code[000774] = *I00774; sub I00774 { $hlt = 1; goto &fetch; }
$core[000775] = 07000; $code[000775] = *I00775; sub I00775 { goto &fetch; }
$core[000776] = 07000; $code[000776] = *I00776; sub I00776 { goto &fetch; }
$core[000777] = 07000; $code[000777] = *I00777; sub I00777 { goto &fetch; }
$core[001000] = 07200; $code[001000] = *I01000; sub I01000 { $lac &= 010000; goto &fetch; }
$core[001001] = 07100; $code[001001] = *I01001; sub I01001 { $lac &= 07777; goto &fetch; }
$core[001002] = 01047; $code[001002] = *I01002; sub I01002 { $lac += $core[000047]; goto &fetch; }
$core[001003] = 01032; $code[001003] = *I01003; sub I01003 { $lac += $core[000032]; goto &fetch; }
$core[001004] = 01032; $code[001004] = *I01004; sub I01004 { $lac += $core[000032]; goto &fetch; }
$core[001005] = 07040; $code[001005] = *I01005; sub I01005 { $lac ^= 07777; goto &fetch; }
$core[001006] = 07420; $code[001006] = *I01006; sub I01006 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001007] = 07440; $code[001007] = *I01007; sub I01007 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001010] = 07402; $code[001010] = *I01010; sub I01010 { $hlt = 1; goto &fetch; }
$core[001011] = 07200; $code[001011] = *I01011; sub I01011 { $lac &= 010000; goto &fetch; }
$core[001012] = 07100; $code[001012] = *I01012; sub I01012 { $lac &= 07777; goto &fetch; }
$core[001013] = 01046; $code[001013] = *I01013; sub I01013 { $lac += $core[000046]; goto &fetch; }
$core[001014] = 01031; $code[001014] = *I01014; sub I01014 { $lac += $core[000031]; goto &fetch; }
$core[001015] = 01031; $code[001015] = *I01015; sub I01015 { $lac += $core[000031]; goto &fetch; }
$core[001016] = 07040; $code[001016] = *I01016; sub I01016 { $lac ^= 07777; goto &fetch; }
$core[001017] = 07420; $code[001017] = *I01017; sub I01017 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001020] = 07440; $code[001020] = *I01020; sub I01020 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001021] = 07402; $code[001021] = *I01021; sub I01021 { $hlt = 1; goto &fetch; }
$core[001022] = 07200; $code[001022] = *I01022; sub I01022 { $lac &= 010000; goto &fetch; }
$core[001023] = 07100; $code[001023] = *I01023; sub I01023 { $lac &= 07777; goto &fetch; }
$core[001024] = 01045; $code[001024] = *I01024; sub I01024 { $lac += $core[000045]; goto &fetch; }
$core[001025] = 01030; $code[001025] = *I01025; sub I01025 { $lac += $core[000030]; goto &fetch; }
$core[001026] = 01030; $code[001026] = *I01026; sub I01026 { $lac += $core[000030]; goto &fetch; }
$core[001027] = 07040; $code[001027] = *I01027; sub I01027 { $lac ^= 07777; goto &fetch; }
$core[001030] = 07420; $code[001030] = *I01030; sub I01030 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001031] = 07440; $code[001031] = *I01031; sub I01031 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001032] = 07402; $code[001032] = *I01032; sub I01032 { $hlt = 1; goto &fetch; }
$core[001033] = 07200; $code[001033] = *I01033; sub I01033 { $lac &= 010000; goto &fetch; }
$core[001034] = 07100; $code[001034] = *I01034; sub I01034 { $lac &= 07777; goto &fetch; }
$core[001035] = 01044; $code[001035] = *I01035; sub I01035 { $lac += $core[000044]; goto &fetch; }
$core[001036] = 01027; $code[001036] = *I01036; sub I01036 { $lac += $core[000027]; goto &fetch; }
$core[001037] = 01027; $code[001037] = *I01037; sub I01037 { $lac += $core[000027]; goto &fetch; }
$core[001040] = 07040; $code[001040] = *I01040; sub I01040 { $lac ^= 07777; goto &fetch; }
$core[001041] = 07420; $code[001041] = *I01041; sub I01041 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001042] = 07440; $code[001042] = *I01042; sub I01042 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001043] = 07402; $code[001043] = *I01043; sub I01043 { $hlt = 1; goto &fetch; }
$core[001044] = 07200; $code[001044] = *I01044; sub I01044 { $lac &= 010000; goto &fetch; }
$core[001045] = 07100; $code[001045] = *I01045; sub I01045 { $lac &= 07777; goto &fetch; }
$core[001046] = 01043; $code[001046] = *I01046; sub I01046 { $lac += $core[000043]; goto &fetch; }
$core[001047] = 01026; $code[001047] = *I01047; sub I01047 { $lac += $core[000026]; goto &fetch; }
$core[001050] = 01026; $code[001050] = *I01050; sub I01050 { $lac += $core[000026]; goto &fetch; }
$core[001051] = 07040; $code[001051] = *I01051; sub I01051 { $lac ^= 07777; goto &fetch; }
$core[001052] = 07420; $code[001052] = *I01052; sub I01052 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001053] = 07440; $code[001053] = *I01053; sub I01053 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001054] = 07402; $code[001054] = *I01054; sub I01054 { $hlt = 1; goto &fetch; }
$core[001055] = 07200; $code[001055] = *I01055; sub I01055 { $lac &= 010000; goto &fetch; }
$core[001056] = 07100; $code[001056] = *I01056; sub I01056 { $lac &= 07777; goto &fetch; }
$core[001057] = 01042; $code[001057] = *I01057; sub I01057 { $lac += $core[000042]; goto &fetch; }
$core[001060] = 01025; $code[001060] = *I01060; sub I01060 { $lac += $core[000025]; goto &fetch; }
$core[001061] = 01025; $code[001061] = *I01061; sub I01061 { $lac += $core[000025]; goto &fetch; }
$core[001062] = 07040; $code[001062] = *I01062; sub I01062 { $lac ^= 07777; goto &fetch; }
$core[001063] = 07420; $code[001063] = *I01063; sub I01063 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001064] = 07440; $code[001064] = *I01064; sub I01064 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001065] = 07402; $code[001065] = *I01065; sub I01065 { $hlt = 1; goto &fetch; }
$core[001066] = 07200; $code[001066] = *I01066; sub I01066 { $lac &= 010000; goto &fetch; }
$core[001067] = 07100; $code[001067] = *I01067; sub I01067 { $lac &= 07777; goto &fetch; }
$core[001070] = 01041; $code[001070] = *I01070; sub I01070 { $lac += $core[000041]; goto &fetch; }
$core[001071] = 01024; $code[001071] = *I01071; sub I01071 { $lac += $core[000024]; goto &fetch; }
$core[001072] = 01024; $code[001072] = *I01072; sub I01072 { $lac += $core[000024]; goto &fetch; }
$core[001073] = 07040; $code[001073] = *I01073; sub I01073 { $lac ^= 07777; goto &fetch; }
$core[001074] = 07420; $code[001074] = *I01074; sub I01074 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001075] = 07440; $code[001075] = *I01075; sub I01075 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001076] = 07402; $code[001076] = *I01076; sub I01076 { $hlt = 1; goto &fetch; }
$core[001077] = 07200; $code[001077] = *I01077; sub I01077 { $lac &= 010000; goto &fetch; }
$core[001100] = 07100; $code[001100] = *I01100; sub I01100 { $lac &= 07777; goto &fetch; }
$core[001101] = 01040; $code[001101] = *I01101; sub I01101 { $lac += $core[000040]; goto &fetch; }
$core[001102] = 01023; $code[001102] = *I01102; sub I01102 { $lac += $core[000023]; goto &fetch; }
$core[001103] = 01023; $code[001103] = *I01103; sub I01103 { $lac += $core[000023]; goto &fetch; }
$core[001104] = 07040; $code[001104] = *I01104; sub I01104 { $lac ^= 07777; goto &fetch; }
$core[001105] = 07420; $code[001105] = *I01105; sub I01105 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001106] = 07440; $code[001106] = *I01106; sub I01106 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001107] = 07402; $code[001107] = *I01107; sub I01107 { $hlt = 1; goto &fetch; }
$core[001110] = 07200; $code[001110] = *I01110; sub I01110 { $lac &= 010000; goto &fetch; }
$core[001111] = 07100; $code[001111] = *I01111; sub I01111 { $lac &= 07777; goto &fetch; }
$core[001112] = 01037; $code[001112] = *I01112; sub I01112 { $lac += $core[000037]; goto &fetch; }
$core[001113] = 01022; $code[001113] = *I01113; sub I01113 { $lac += $core[000022]; goto &fetch; }
$core[001114] = 01022; $code[001114] = *I01114; sub I01114 { $lac += $core[000022]; goto &fetch; }
$core[001115] = 07040; $code[001115] = *I01115; sub I01115 { $lac ^= 07777; goto &fetch; }
$core[001116] = 07420; $code[001116] = *I01116; sub I01116 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001117] = 07440; $code[001117] = *I01117; sub I01117 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001120] = 07402; $code[001120] = *I01120; sub I01120 { $hlt = 1; goto &fetch; }
$core[001121] = 07200; $code[001121] = *I01121; sub I01121 { $lac &= 010000; goto &fetch; }
$core[001122] = 07100; $code[001122] = *I01122; sub I01122 { $lac &= 07777; goto &fetch; }
$core[001123] = 01036; $code[001123] = *I01123; sub I01123 { $lac += $core[000036]; goto &fetch; }
$core[001124] = 01021; $code[001124] = *I01124; sub I01124 { $lac += $core[000021]; goto &fetch; }
$core[001125] = 01021; $code[001125] = *I01125; sub I01125 { $lac += $core[000021]; goto &fetch; }
$core[001126] = 07040; $code[001126] = *I01126; sub I01126 { $lac ^= 07777; goto &fetch; }
$core[001127] = 07420; $code[001127] = *I01127; sub I01127 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001130] = 07430; $code[001130] = *I01130; sub I01130 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001131] = 07402; $code[001131] = *I01131; sub I01131 { $hlt = 1; goto &fetch; }
$core[001132] = 07200; $code[001132] = *I01132; sub I01132 { $lac &= 010000; goto &fetch; }
$core[001133] = 07100; $code[001133] = *I01133; sub I01133 { $lac &= 07777; goto &fetch; }
$core[001134] = 01021; $code[001134] = *I01134; sub I01134 { $lac += $core[000021]; goto &fetch; }
$core[001135] = 07010; $code[001135] = *I01135; sub I01135 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001136] = 07420; $code[001136] = *I01136; sub I01136 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001137] = 07402; $code[001137] = *I01137; sub I01137 { $hlt = 1; goto &fetch; }
$core[001140] = 07200; $code[001140] = *I01140; sub I01140 { $lac &= 010000; goto &fetch; }
$core[001141] = 07100; $code[001141] = *I01141; sub I01141 { $lac &= 07777; goto &fetch; }
$core[001142] = 01020; $code[001142] = *I01142; sub I01142 { $lac += $core[000020]; goto &fetch; }
$core[001143] = 07010; $code[001143] = *I01143; sub I01143 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001144] = 07440; $code[001144] = *I01144; sub I01144 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001145] = 07402; $code[001145] = *I01145; sub I01145 { $hlt = 1; goto &fetch; }
$core[001146] = 07200; $code[001146] = *I01146; sub I01146 { $lac &= 010000; goto &fetch; }
$core[001147] = 07100; $code[001147] = *I01147; sub I01147 { $lac &= 07777; goto &fetch; }
$core[001150] = 01020; $code[001150] = *I01150; sub I01150 { $lac += $core[000020]; goto &fetch; }
$core[001151] = 07010; $code[001151] = *I01151; sub I01151 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001152] = 07430; $code[001152] = *I01152; sub I01152 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001153] = 07402; $code[001153] = *I01153; sub I01153 { $hlt = 1; goto &fetch; }
$core[001154] = 07200; $code[001154] = *I01154; sub I01154 { $lac &= 010000; goto &fetch; }
$core[001155] = 07100; $code[001155] = *I01155; sub I01155 { $lac &= 07777; goto &fetch; }
$core[001156] = 07020; $code[001156] = *I01156; sub I01156 { $lac ^= 010000; goto &fetch; }
$core[001157] = 01020; $code[001157] = *I01157; sub I01157 { $lac += $core[000020]; goto &fetch; }
$core[001160] = 07010; $code[001160] = *I01160; sub I01160 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001161] = 07430; $code[001161] = *I01161; sub I01161 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001162] = 07402; $code[001162] = *I01162; sub I01162 { $hlt = 1; goto &fetch; }
$core[001163] = 07200; $code[001163] = *I01163; sub I01163 { $lac &= 010000; goto &fetch; }
$core[001164] = 07100; $code[001164] = *I01164; sub I01164 { $lac &= 07777; goto &fetch; }
$core[001165] = 07020; $code[001165] = *I01165; sub I01165 { $lac ^= 010000; goto &fetch; }
$core[001166] = 01051; $code[001166] = *I01166; sub I01166 { $lac += $core[000051]; goto &fetch; }
$core[001167] = 07010; $code[001167] = *I01167; sub I01167 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001170] = 07040; $code[001170] = *I01170; sub I01170 { $lac ^= 07777; goto &fetch; }
$core[001171] = 07440; $code[001171] = *I01171; sub I01171 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001172] = 07402; $code[001172] = *I01172; sub I01172 { $hlt = 1; goto &fetch; }
$core[001173] = 07000; $code[001173] = *I01173; sub I01173 { goto &fetch; }
$core[001174] = 07000; $code[001174] = *I01174; sub I01174 { goto &fetch; }
$core[001175] = 07000; $code[001175] = *I01175; sub I01175 { goto &fetch; }
$core[001176] = 07000; $code[001176] = *I01176; sub I01176 { goto &fetch; }
$core[001177] = 07000; $code[001177] = *I01177; sub I01177 { goto &fetch; }
$core[001200] = 07200; $code[001200] = *I01200; sub I01200 { $lac &= 010000; goto &fetch; }
$core[001201] = 07100; $code[001201] = *I01201; sub I01201 { $lac &= 07777; goto &fetch; }
$core[001202] = 07020; $code[001202] = *I01202; sub I01202 { $lac ^= 010000; goto &fetch; }
$core[001203] = 01020; $code[001203] = *I01203; sub I01203 { $lac += $core[000020]; goto &fetch; }
$core[001204] = 07010; $code[001204] = *I01204; sub I01204 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001205] = 01050; $code[001205] = *I01205; sub I01205 { $lac += $core[000050]; goto &fetch; }
$core[001206] = 07040; $code[001206] = *I01206; sub I01206 { $lac ^= 07777; goto &fetch; }
$core[001207] = 07450; $code[001207] = *I01207; sub I01207 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001210] = 07430; $code[001210] = *I01210; sub I01210 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001211] = 07402; $code[001211] = *I01211; sub I01211 { $hlt = 1; goto &fetch; }
$core[001212] = 07200; $code[001212] = *I01212; sub I01212 { $lac &= 010000; goto &fetch; }
$core[001213] = 07100; $code[001213] = *I01213; sub I01213 { $lac &= 07777; goto &fetch; }
$core[001214] = 01034; $code[001214] = *I01214; sub I01214 { $lac += $core[000034]; goto &fetch; }
$core[001215] = 07010; $code[001215] = *I01215; sub I01215 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001216] = 01047; $code[001216] = *I01216; sub I01216 { $lac += $core[000047]; goto &fetch; }
$core[001217] = 07040; $code[001217] = *I01217; sub I01217 { $lac ^= 07777; goto &fetch; }
$core[001220] = 07450; $code[001220] = *I01220; sub I01220 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001221] = 07430; $code[001221] = *I01221; sub I01221 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001222] = 07402; $code[001222] = *I01222; sub I01222 { $hlt = 1; goto &fetch; }
$core[001223] = 07200; $code[001223] = *I01223; sub I01223 { $lac &= 010000; goto &fetch; }
$core[001224] = 07100; $code[001224] = *I01224; sub I01224 { $lac &= 07777; goto &fetch; }
$core[001225] = 01033; $code[001225] = *I01225; sub I01225 { $lac += $core[000033]; goto &fetch; }
$core[001226] = 07010; $code[001226] = *I01226; sub I01226 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001227] = 01046; $code[001227] = *I01227; sub I01227 { $lac += $core[000046]; goto &fetch; }
$core[001230] = 07040; $code[001230] = *I01230; sub I01230 { $lac ^= 07777; goto &fetch; }
$core[001231] = 07450; $code[001231] = *I01231; sub I01231 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001232] = 07430; $code[001232] = *I01232; sub I01232 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001233] = 07402; $code[001233] = *I01233; sub I01233 { $hlt = 1; goto &fetch; }
$core[001234] = 07200; $code[001234] = *I01234; sub I01234 { $lac &= 010000; goto &fetch; }
$core[001235] = 07100; $code[001235] = *I01235; sub I01235 { $lac &= 07777; goto &fetch; }
$core[001236] = 01032; $code[001236] = *I01236; sub I01236 { $lac += $core[000032]; goto &fetch; }
$core[001237] = 07010; $code[001237] = *I01237; sub I01237 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001240] = 01045; $code[001240] = *I01240; sub I01240 { $lac += $core[000045]; goto &fetch; }
$core[001241] = 07040; $code[001241] = *I01241; sub I01241 { $lac ^= 07777; goto &fetch; }
$core[001242] = 07450; $code[001242] = *I01242; sub I01242 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001243] = 07430; $code[001243] = *I01243; sub I01243 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001244] = 07402; $code[001244] = *I01244; sub I01244 { $hlt = 1; goto &fetch; }
$core[001245] = 07200; $code[001245] = *I01245; sub I01245 { $lac &= 010000; goto &fetch; }
$core[001246] = 07100; $code[001246] = *I01246; sub I01246 { $lac &= 07777; goto &fetch; }
$core[001247] = 01031; $code[001247] = *I01247; sub I01247 { $lac += $core[000031]; goto &fetch; }
$core[001250] = 07010; $code[001250] = *I01250; sub I01250 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001251] = 01044; $code[001251] = *I01251; sub I01251 { $lac += $core[000044]; goto &fetch; }
$core[001252] = 07040; $code[001252] = *I01252; sub I01252 { $lac ^= 07777; goto &fetch; }
$core[001253] = 07450; $code[001253] = *I01253; sub I01253 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001254] = 07430; $code[001254] = *I01254; sub I01254 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001255] = 07402; $code[001255] = *I01255; sub I01255 { $hlt = 1; goto &fetch; }
$core[001256] = 07200; $code[001256] = *I01256; sub I01256 { $lac &= 010000; goto &fetch; }
$core[001257] = 07100; $code[001257] = *I01257; sub I01257 { $lac &= 07777; goto &fetch; }
$core[001260] = 01030; $code[001260] = *I01260; sub I01260 { $lac += $core[000030]; goto &fetch; }
$core[001261] = 07010; $code[001261] = *I01261; sub I01261 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001262] = 01043; $code[001262] = *I01262; sub I01262 { $lac += $core[000043]; goto &fetch; }
$core[001263] = 07040; $code[001263] = *I01263; sub I01263 { $lac ^= 07777; goto &fetch; }
$core[001264] = 07450; $code[001264] = *I01264; sub I01264 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001265] = 07430; $code[001265] = *I01265; sub I01265 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001266] = 07402; $code[001266] = *I01266; sub I01266 { $hlt = 1; goto &fetch; }
$core[001267] = 07200; $code[001267] = *I01267; sub I01267 { $lac &= 010000; goto &fetch; }
$core[001270] = 07100; $code[001270] = *I01270; sub I01270 { $lac &= 07777; goto &fetch; }
$core[001271] = 01027; $code[001271] = *I01271; sub I01271 { $lac += $core[000027]; goto &fetch; }
$core[001272] = 07010; $code[001272] = *I01272; sub I01272 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001273] = 01042; $code[001273] = *I01273; sub I01273 { $lac += $core[000042]; goto &fetch; }
$core[001274] = 07040; $code[001274] = *I01274; sub I01274 { $lac ^= 07777; goto &fetch; }
$core[001275] = 07450; $code[001275] = *I01275; sub I01275 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001276] = 07430; $code[001276] = *I01276; sub I01276 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001277] = 07402; $code[001277] = *I01277; sub I01277 { $hlt = 1; goto &fetch; }
$core[001300] = 07200; $code[001300] = *I01300; sub I01300 { $lac &= 010000; goto &fetch; }
$core[001301] = 07100; $code[001301] = *I01301; sub I01301 { $lac &= 07777; goto &fetch; }
$core[001302] = 01026; $code[001302] = *I01302; sub I01302 { $lac += $core[000026]; goto &fetch; }
$core[001303] = 07010; $code[001303] = *I01303; sub I01303 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001304] = 01041; $code[001304] = *I01304; sub I01304 { $lac += $core[000041]; goto &fetch; }
$core[001305] = 07040; $code[001305] = *I01305; sub I01305 { $lac ^= 07777; goto &fetch; }
$core[001306] = 07450; $code[001306] = *I01306; sub I01306 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001307] = 07430; $code[001307] = *I01307; sub I01307 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001310] = 07402; $code[001310] = *I01310; sub I01310 { $hlt = 1; goto &fetch; }
$core[001311] = 07200; $code[001311] = *I01311; sub I01311 { $lac &= 010000; goto &fetch; }
$core[001312] = 07100; $code[001312] = *I01312; sub I01312 { $lac &= 07777; goto &fetch; }
$core[001313] = 01025; $code[001313] = *I01313; sub I01313 { $lac += $core[000025]; goto &fetch; }
$core[001314] = 07010; $code[001314] = *I01314; sub I01314 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001315] = 01040; $code[001315] = *I01315; sub I01315 { $lac += $core[000040]; goto &fetch; }
$core[001316] = 07040; $code[001316] = *I01316; sub I01316 { $lac ^= 07777; goto &fetch; }
$core[001317] = 07450; $code[001317] = *I01317; sub I01317 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001320] = 07430; $code[001320] = *I01320; sub I01320 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001321] = 07402; $code[001321] = *I01321; sub I01321 { $hlt = 1; goto &fetch; }
$core[001322] = 07200; $code[001322] = *I01322; sub I01322 { $lac &= 010000; goto &fetch; }
$core[001323] = 07100; $code[001323] = *I01323; sub I01323 { $lac &= 07777; goto &fetch; }
$core[001324] = 01024; $code[001324] = *I01324; sub I01324 { $lac += $core[000024]; goto &fetch; }
$core[001325] = 07010; $code[001325] = *I01325; sub I01325 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001326] = 01037; $code[001326] = *I01326; sub I01326 { $lac += $core[000037]; goto &fetch; }
$core[001327] = 07040; $code[001327] = *I01327; sub I01327 { $lac ^= 07777; goto &fetch; }
$core[001330] = 07450; $code[001330] = *I01330; sub I01330 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001331] = 07430; $code[001331] = *I01331; sub I01331 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001332] = 07402; $code[001332] = *I01332; sub I01332 { $hlt = 1; goto &fetch; }
$core[001333] = 07200; $code[001333] = *I01333; sub I01333 { $lac &= 010000; goto &fetch; }
$core[001334] = 07100; $code[001334] = *I01334; sub I01334 { $lac &= 07777; goto &fetch; }
$core[001335] = 01023; $code[001335] = *I01335; sub I01335 { $lac += $core[000023]; goto &fetch; }
$core[001336] = 07010; $code[001336] = *I01336; sub I01336 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001337] = 01036; $code[001337] = *I01337; sub I01337 { $lac += $core[000036]; goto &fetch; }
$core[001340] = 07040; $code[001340] = *I01340; sub I01340 { $lac ^= 07777; goto &fetch; }
$core[001341] = 07450; $code[001341] = *I01341; sub I01341 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001342] = 07430; $code[001342] = *I01342; sub I01342 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001343] = 07402; $code[001343] = *I01343; sub I01343 { $hlt = 1; goto &fetch; }
$core[001344] = 07200; $code[001344] = *I01344; sub I01344 { $lac &= 010000; goto &fetch; }
$core[001345] = 07100; $code[001345] = *I01345; sub I01345 { $lac &= 07777; goto &fetch; }
$core[001346] = 01022; $code[001346] = *I01346; sub I01346 { $lac += $core[000022]; goto &fetch; }
$core[001347] = 07010; $code[001347] = *I01347; sub I01347 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001350] = 01035; $code[001350] = *I01350; sub I01350 { $lac += $core[000035]; goto &fetch; }
$core[001351] = 07040; $code[001351] = *I01351; sub I01351 { $lac ^= 07777; goto &fetch; }
$core[001352] = 07450; $code[001352] = *I01352; sub I01352 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001353] = 07430; $code[001353] = *I01353; sub I01353 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001354] = 07402; $code[001354] = *I01354; sub I01354 { $hlt = 1; goto &fetch; }
$core[001355] = 07200; $code[001355] = *I01355; sub I01355 { $lac &= 010000; goto &fetch; }
$core[001356] = 07100; $code[001356] = *I01356; sub I01356 { $lac &= 07777; goto &fetch; }
$core[001357] = 01021; $code[001357] = *I01357; sub I01357 { $lac += $core[000021]; goto &fetch; }
$core[001360] = 07010; $code[001360] = *I01360; sub I01360 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[001361] = 01051; $code[001361] = *I01361; sub I01361 { $lac += $core[000051]; goto &fetch; }
$core[001362] = 07040; $code[001362] = *I01362; sub I01362 { $lac ^= 07777; goto &fetch; }
$core[001363] = 07450; $code[001363] = *I01363; sub I01363 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001364] = 07420; $code[001364] = *I01364; sub I01364 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001365] = 07402; $code[001365] = *I01365; sub I01365 { $hlt = 1; goto &fetch; }
$core[001366] = 07200; $code[001366] = *I01366; sub I01366 { $lac &= 010000; goto &fetch; }
$core[001367] = 07100; $code[001367] = *I01367; sub I01367 { $lac &= 07777; goto &fetch; }
$core[001370] = 01022; $code[001370] = *I01370; sub I01370 { $lac += $core[000022]; goto &fetch; }
$core[001371] = 07012; $code[001371] = *I01371; sub I01371 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001372] = 07420; $code[001372] = *I01372; sub I01372 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001373] = 07402; $code[001373] = *I01373; sub I01373 { $hlt = 1; goto &fetch; }
$core[001374] = 07000; $code[001374] = *I01374; sub I01374 { goto &fetch; }
$core[001375] = 07000; $code[001375] = *I01375; sub I01375 { goto &fetch; }
$core[001376] = 07000; $code[001376] = *I01376; sub I01376 { goto &fetch; }
$core[001377] = 07000; $code[001377] = *I01377; sub I01377 { goto &fetch; }
$core[001400] = 07200; $code[001400] = *I01400; sub I01400 { $lac &= 010000; goto &fetch; }
$core[001401] = 07100; $code[001401] = *I01401; sub I01401 { $lac &= 07777; goto &fetch; }
$core[001402] = 01020; $code[001402] = *I01402; sub I01402 { $lac += $core[000020]; goto &fetch; }
$core[001403] = 07012; $code[001403] = *I01403; sub I01403 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001404] = 07440; $code[001404] = *I01404; sub I01404 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001405] = 07402; $code[001405] = *I01405; sub I01405 { $hlt = 1; goto &fetch; }
$core[001406] = 07200; $code[001406] = *I01406; sub I01406 { $lac &= 010000; goto &fetch; }
$core[001407] = 07100; $code[001407] = *I01407; sub I01407 { $lac &= 07777; goto &fetch; }
$core[001410] = 01020; $code[001410] = *I01410; sub I01410 { $lac += $core[000020]; goto &fetch; }
$core[001411] = 07012; $code[001411] = *I01411; sub I01411 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001412] = 07430; $code[001412] = *I01412; sub I01412 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001413] = 07402; $code[001413] = *I01413; sub I01413 { $hlt = 1; goto &fetch; }
$core[001414] = 07200; $code[001414] = *I01414; sub I01414 { $lac &= 010000; goto &fetch; }
$core[001415] = 07100; $code[001415] = *I01415; sub I01415 { $lac &= 07777; goto &fetch; }
$core[001416] = 07020; $code[001416] = *I01416; sub I01416 { $lac ^= 010000; goto &fetch; }
$core[001417] = 01020; $code[001417] = *I01417; sub I01417 { $lac += $core[000020]; goto &fetch; }
$core[001420] = 07012; $code[001420] = *I01420; sub I01420 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001421] = 07430; $code[001421] = *I01421; sub I01421 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001422] = 07402; $code[001422] = *I01422; sub I01422 { $hlt = 1; goto &fetch; }
$core[001423] = 07200; $code[001423] = *I01423; sub I01423 { $lac &= 010000; goto &fetch; }
$core[001424] = 07100; $code[001424] = *I01424; sub I01424 { $lac &= 07777; goto &fetch; }
$core[001425] = 07020; $code[001425] = *I01425; sub I01425 { $lac ^= 010000; goto &fetch; }
$core[001426] = 01051; $code[001426] = *I01426; sub I01426 { $lac += $core[000051]; goto &fetch; }
$core[001427] = 07012; $code[001427] = *I01427; sub I01427 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001430] = 07040; $code[001430] = *I01430; sub I01430 { $lac ^= 07777; goto &fetch; }
$core[001431] = 07440; $code[001431] = *I01431; sub I01431 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001432] = 07402; $code[001432] = *I01432; sub I01432 { $hlt = 1; goto &fetch; }
$core[001433] = 07200; $code[001433] = *I01433; sub I01433 { $lac &= 010000; goto &fetch; }
$core[001434] = 07100; $code[001434] = *I01434; sub I01434 { $lac &= 07777; goto &fetch; }
$core[001435] = 07020; $code[001435] = *I01435; sub I01435 { $lac ^= 010000; goto &fetch; }
$core[001436] = 01020; $code[001436] = *I01436; sub I01436 { $lac += $core[000020]; goto &fetch; }
$core[001437] = 07012; $code[001437] = *I01437; sub I01437 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001440] = 01047; $code[001440] = *I01440; sub I01440 { $lac += $core[000047]; goto &fetch; }
$core[001441] = 07040; $code[001441] = *I01441; sub I01441 { $lac ^= 07777; goto &fetch; }
$core[001442] = 07450; $code[001442] = *I01442; sub I01442 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001443] = 07430; $code[001443] = *I01443; sub I01443 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001444] = 07402; $code[001444] = *I01444; sub I01444 { $hlt = 1; goto &fetch; }
$core[001445] = 07200; $code[001445] = *I01445; sub I01445 { $lac &= 010000; goto &fetch; }
$core[001446] = 07100; $code[001446] = *I01446; sub I01446 { $lac &= 07777; goto &fetch; }
$core[001447] = 01034; $code[001447] = *I01447; sub I01447 { $lac += $core[000034]; goto &fetch; }
$core[001450] = 07012; $code[001450] = *I01450; sub I01450 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001451] = 01046; $code[001451] = *I01451; sub I01451 { $lac += $core[000046]; goto &fetch; }
$core[001452] = 07040; $code[001452] = *I01452; sub I01452 { $lac ^= 07777; goto &fetch; }
$core[001453] = 07450; $code[001453] = *I01453; sub I01453 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001454] = 07430; $code[001454] = *I01454; sub I01454 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001455] = 07402; $code[001455] = *I01455; sub I01455 { $hlt = 1; goto &fetch; }
$core[001456] = 07200; $code[001456] = *I01456; sub I01456 { $lac &= 010000; goto &fetch; }
$core[001457] = 07100; $code[001457] = *I01457; sub I01457 { $lac &= 07777; goto &fetch; }
$core[001460] = 01033; $code[001460] = *I01460; sub I01460 { $lac += $core[000033]; goto &fetch; }
$core[001461] = 07012; $code[001461] = *I01461; sub I01461 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001462] = 01045; $code[001462] = *I01462; sub I01462 { $lac += $core[000045]; goto &fetch; }
$core[001463] = 07040; $code[001463] = *I01463; sub I01463 { $lac ^= 07777; goto &fetch; }
$core[001464] = 07450; $code[001464] = *I01464; sub I01464 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001465] = 07430; $code[001465] = *I01465; sub I01465 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001466] = 07402; $code[001466] = *I01466; sub I01466 { $hlt = 1; goto &fetch; }
$core[001467] = 07200; $code[001467] = *I01467; sub I01467 { $lac &= 010000; goto &fetch; }
$core[001470] = 07100; $code[001470] = *I01470; sub I01470 { $lac &= 07777; goto &fetch; }
$core[001471] = 01032; $code[001471] = *I01471; sub I01471 { $lac += $core[000032]; goto &fetch; }
$core[001472] = 07012; $code[001472] = *I01472; sub I01472 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001473] = 01044; $code[001473] = *I01473; sub I01473 { $lac += $core[000044]; goto &fetch; }
$core[001474] = 07040; $code[001474] = *I01474; sub I01474 { $lac ^= 07777; goto &fetch; }
$core[001475] = 07450; $code[001475] = *I01475; sub I01475 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001476] = 07430; $code[001476] = *I01476; sub I01476 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001477] = 07402; $code[001477] = *I01477; sub I01477 { $hlt = 1; goto &fetch; }
$core[001500] = 07200; $code[001500] = *I01500; sub I01500 { $lac &= 010000; goto &fetch; }
$core[001501] = 07100; $code[001501] = *I01501; sub I01501 { $lac &= 07777; goto &fetch; }
$core[001502] = 01031; $code[001502] = *I01502; sub I01502 { $lac += $core[000031]; goto &fetch; }
$core[001503] = 07012; $code[001503] = *I01503; sub I01503 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001504] = 01043; $code[001504] = *I01504; sub I01504 { $lac += $core[000043]; goto &fetch; }
$core[001505] = 07040; $code[001505] = *I01505; sub I01505 { $lac ^= 07777; goto &fetch; }
$core[001506] = 07450; $code[001506] = *I01506; sub I01506 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001507] = 07430; $code[001507] = *I01507; sub I01507 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001510] = 07402; $code[001510] = *I01510; sub I01510 { $hlt = 1; goto &fetch; }
$core[001511] = 07200; $code[001511] = *I01511; sub I01511 { $lac &= 010000; goto &fetch; }
$core[001512] = 07100; $code[001512] = *I01512; sub I01512 { $lac &= 07777; goto &fetch; }
$core[001513] = 01030; $code[001513] = *I01513; sub I01513 { $lac += $core[000030]; goto &fetch; }
$core[001514] = 07012; $code[001514] = *I01514; sub I01514 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001515] = 01042; $code[001515] = *I01515; sub I01515 { $lac += $core[000042]; goto &fetch; }
$core[001516] = 07040; $code[001516] = *I01516; sub I01516 { $lac ^= 07777; goto &fetch; }
$core[001517] = 07450; $code[001517] = *I01517; sub I01517 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001520] = 07430; $code[001520] = *I01520; sub I01520 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001521] = 07402; $code[001521] = *I01521; sub I01521 { $hlt = 1; goto &fetch; }
$core[001522] = 07200; $code[001522] = *I01522; sub I01522 { $lac &= 010000; goto &fetch; }
$core[001523] = 07100; $code[001523] = *I01523; sub I01523 { $lac &= 07777; goto &fetch; }
$core[001524] = 01027; $code[001524] = *I01524; sub I01524 { $lac += $core[000027]; goto &fetch; }
$core[001525] = 07012; $code[001525] = *I01525; sub I01525 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001526] = 01041; $code[001526] = *I01526; sub I01526 { $lac += $core[000041]; goto &fetch; }
$core[001527] = 07040; $code[001527] = *I01527; sub I01527 { $lac ^= 07777; goto &fetch; }
$core[001530] = 07450; $code[001530] = *I01530; sub I01530 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001531] = 07430; $code[001531] = *I01531; sub I01531 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001532] = 07402; $code[001532] = *I01532; sub I01532 { $hlt = 1; goto &fetch; }
$core[001533] = 07200; $code[001533] = *I01533; sub I01533 { $lac &= 010000; goto &fetch; }
$core[001534] = 07100; $code[001534] = *I01534; sub I01534 { $lac &= 07777; goto &fetch; }
$core[001535] = 01026; $code[001535] = *I01535; sub I01535 { $lac += $core[000026]; goto &fetch; }
$core[001536] = 07012; $code[001536] = *I01536; sub I01536 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001537] = 01040; $code[001537] = *I01537; sub I01537 { $lac += $core[000040]; goto &fetch; }
$core[001540] = 07040; $code[001540] = *I01540; sub I01540 { $lac ^= 07777; goto &fetch; }
$core[001541] = 07450; $code[001541] = *I01541; sub I01541 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001542] = 07430; $code[001542] = *I01542; sub I01542 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001543] = 07402; $code[001543] = *I01543; sub I01543 { $hlt = 1; goto &fetch; }
$core[001544] = 07200; $code[001544] = *I01544; sub I01544 { $lac &= 010000; goto &fetch; }
$core[001545] = 07100; $code[001545] = *I01545; sub I01545 { $lac &= 07777; goto &fetch; }
$core[001546] = 01025; $code[001546] = *I01546; sub I01546 { $lac += $core[000025]; goto &fetch; }
$core[001547] = 07012; $code[001547] = *I01547; sub I01547 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001550] = 01037; $code[001550] = *I01550; sub I01550 { $lac += $core[000037]; goto &fetch; }
$core[001551] = 07040; $code[001551] = *I01551; sub I01551 { $lac ^= 07777; goto &fetch; }
$core[001552] = 07450; $code[001552] = *I01552; sub I01552 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001553] = 07430; $code[001553] = *I01553; sub I01553 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001554] = 07402; $code[001554] = *I01554; sub I01554 { $hlt = 1; goto &fetch; }
$core[001555] = 07200; $code[001555] = *I01555; sub I01555 { $lac &= 010000; goto &fetch; }
$core[001556] = 07100; $code[001556] = *I01556; sub I01556 { $lac &= 07777; goto &fetch; }
$core[001557] = 01024; $code[001557] = *I01557; sub I01557 { $lac += $core[000024]; goto &fetch; }
$core[001560] = 07012; $code[001560] = *I01560; sub I01560 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001561] = 01036; $code[001561] = *I01561; sub I01561 { $lac += $core[000036]; goto &fetch; }
$core[001562] = 07040; $code[001562] = *I01562; sub I01562 { $lac ^= 07777; goto &fetch; }
$core[001563] = 07450; $code[001563] = *I01563; sub I01563 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001564] = 07430; $code[001564] = *I01564; sub I01564 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001565] = 07402; $code[001565] = *I01565; sub I01565 { $hlt = 1; goto &fetch; }
$core[001566] = 07300; $code[001566] = *I01566; sub I01566 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[001567] = 01023; $code[001567] = *I01567; sub I01567 { $lac += $core[000023]; goto &fetch; }
$core[001570] = 07012; $code[001570] = *I01570; sub I01570 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001571] = 01035; $code[001571] = *I01571; sub I01571 { $lac += $core[000035]; goto &fetch; }
$core[001572] = 07040; $code[001572] = *I01572; sub I01572 { $lac ^= 07777; goto &fetch; }
$core[001573] = 07450; $code[001573] = *I01573; sub I01573 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001574] = 07430; $code[001574] = *I01574; sub I01574 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001575] = 07402; $code[001575] = *I01575; sub I01575 { $hlt = 1; goto &fetch; }
$core[001576] = 07000; $code[001576] = *I01576; sub I01576 { goto &fetch; }
$core[001577] = 07000; $code[001577] = *I01577; sub I01577 { goto &fetch; }
$core[001600] = 07200; $code[001600] = *I01600; sub I01600 { $lac &= 010000; goto &fetch; }
$core[001601] = 07100; $code[001601] = *I01601; sub I01601 { $lac &= 07777; goto &fetch; }
$core[001602] = 01022; $code[001602] = *I01602; sub I01602 { $lac += $core[000022]; goto &fetch; }
$core[001603] = 07012; $code[001603] = *I01603; sub I01603 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001604] = 07450; $code[001604] = *I01604; sub I01604 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001605] = 07420; $code[001605] = *I01605; sub I01605 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001606] = 07402; $code[001606] = *I01606; sub I01606 { $hlt = 1; goto &fetch; }
$core[001607] = 07200; $code[001607] = *I01607; sub I01607 { $lac &= 010000; goto &fetch; }
$core[001610] = 07100; $code[001610] = *I01610; sub I01610 { $lac &= 07777; goto &fetch; }
$core[001611] = 01021; $code[001611] = *I01611; sub I01611 { $lac += $core[000021]; goto &fetch; }
$core[001612] = 07012; $code[001612] = *I01612; sub I01612 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[001613] = 01050; $code[001613] = *I01613; sub I01613 { $lac += $core[000050]; goto &fetch; }
$core[001614] = 07040; $code[001614] = *I01614; sub I01614 { $lac ^= 07777; goto &fetch; }
$core[001615] = 07450; $code[001615] = *I01615; sub I01615 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001616] = 07430; $code[001616] = *I01616; sub I01616 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001617] = 07402; $code[001617] = *I01617; sub I01617 { $hlt = 1; goto &fetch; }
$core[001620] = 07200; $code[001620] = *I01620; sub I01620 { $lac &= 010000; goto &fetch; }
$core[001621] = 07100; $code[001621] = *I01621; sub I01621 { $lac &= 07777; goto &fetch; }
$core[001622] = 01034; $code[001622] = *I01622; sub I01622 { $lac += $core[000034]; goto &fetch; }
$core[001623] = 07004; $code[001623] = *I01623; sub I01623 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001624] = 07430; $code[001624] = *I01624; sub I01624 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001625] = 07440; $code[001625] = *I01625; sub I01625 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001626] = 07402; $code[001626] = *I01626; sub I01626 { $hlt = 1; goto &fetch; }
$core[001627] = 07200; $code[001627] = *I01627; sub I01627 { $lac &= 010000; goto &fetch; }
$core[001630] = 07100; $code[001630] = *I01630; sub I01630 { $lac &= 07777; goto &fetch; }
$core[001631] = 01020; $code[001631] = *I01631; sub I01631 { $lac += $core[000020]; goto &fetch; }
$core[001632] = 07004; $code[001632] = *I01632; sub I01632 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001633] = 07420; $code[001633] = *I01633; sub I01633 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[001634] = 07440; $code[001634] = *I01634; sub I01634 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001635] = 07402; $code[001635] = *I01635; sub I01635 { $hlt = 1; goto &fetch; }
$core[001636] = 07200; $code[001636] = *I01636; sub I01636 { $lac &= 010000; goto &fetch; }
$core[001637] = 07100; $code[001637] = *I01637; sub I01637 { $lac &= 07777; goto &fetch; }
$core[001640] = 07020; $code[001640] = *I01640; sub I01640 { $lac ^= 010000; goto &fetch; }
$core[001641] = 01020; $code[001641] = *I01641; sub I01641 { $lac += $core[000020]; goto &fetch; }
$core[001642] = 07004; $code[001642] = *I01642; sub I01642 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001643] = 07430; $code[001643] = *I01643; sub I01643 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001644] = 07402; $code[001644] = *I01644; sub I01644 { $hlt = 1; goto &fetch; }
$core[001645] = 07200; $code[001645] = *I01645; sub I01645 { $lac &= 010000; goto &fetch; }
$core[001646] = 07100; $code[001646] = *I01646; sub I01646 { $lac &= 07777; goto &fetch; }
$core[001647] = 07020; $code[001647] = *I01647; sub I01647 { $lac ^= 010000; goto &fetch; }
$core[001650] = 01051; $code[001650] = *I01650; sub I01650 { $lac += $core[000051]; goto &fetch; }
$core[001651] = 07004; $code[001651] = *I01651; sub I01651 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001652] = 07040; $code[001652] = *I01652; sub I01652 { $lac ^= 07777; goto &fetch; }
$core[001653] = 07440; $code[001653] = *I01653; sub I01653 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001654] = 07402; $code[001654] = *I01654; sub I01654 { $hlt = 1; goto &fetch; }
$core[001655] = 07200; $code[001655] = *I01655; sub I01655 { $lac &= 010000; goto &fetch; }
$core[001656] = 07100; $code[001656] = *I01656; sub I01656 { $lac &= 07777; goto &fetch; }
$core[001657] = 01033; $code[001657] = *I01657; sub I01657 { $lac += $core[000033]; goto &fetch; }
$core[001660] = 07004; $code[001660] = *I01660; sub I01660 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001661] = 01050; $code[001661] = *I01661; sub I01661 { $lac += $core[000050]; goto &fetch; }
$core[001662] = 07040; $code[001662] = *I01662; sub I01662 { $lac ^= 07777; goto &fetch; }
$core[001663] = 07450; $code[001663] = *I01663; sub I01663 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001664] = 07430; $code[001664] = *I01664; sub I01664 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001665] = 07402; $code[001665] = *I01665; sub I01665 { $hlt = 1; goto &fetch; }
$core[001666] = 07200; $code[001666] = *I01666; sub I01666 { $lac &= 010000; goto &fetch; }
$core[001667] = 07100; $code[001667] = *I01667; sub I01667 { $lac &= 07777; goto &fetch; }
$core[001670] = 01032; $code[001670] = *I01670; sub I01670 { $lac += $core[000032]; goto &fetch; }
$core[001671] = 07004; $code[001671] = *I01671; sub I01671 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001672] = 01047; $code[001672] = *I01672; sub I01672 { $lac += $core[000047]; goto &fetch; }
$core[001673] = 07040; $code[001673] = *I01673; sub I01673 { $lac ^= 07777; goto &fetch; }
$core[001674] = 07440; $code[001674] = *I01674; sub I01674 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[001675] = 07402; $code[001675] = *I01675; sub I01675 { $hlt = 1; goto &fetch; }
$core[001676] = 07200; $code[001676] = *I01676; sub I01676 { $lac &= 010000; goto &fetch; }
$core[001677] = 07100; $code[001677] = *I01677; sub I01677 { $lac &= 07777; goto &fetch; }
$core[001700] = 01031; $code[001700] = *I01700; sub I01700 { $lac += $core[000031]; goto &fetch; }
$core[001701] = 07004; $code[001701] = *I01701; sub I01701 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001702] = 01046; $code[001702] = *I01702; sub I01702 { $lac += $core[000046]; goto &fetch; }
$core[001703] = 07040; $code[001703] = *I01703; sub I01703 { $lac ^= 07777; goto &fetch; }
$core[001704] = 07450; $code[001704] = *I01704; sub I01704 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001705] = 07430; $code[001705] = *I01705; sub I01705 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001706] = 07402; $code[001706] = *I01706; sub I01706 { $hlt = 1; goto &fetch; }
$core[001707] = 07200; $code[001707] = *I01707; sub I01707 { $lac &= 010000; goto &fetch; }
$core[001710] = 07100; $code[001710] = *I01710; sub I01710 { $lac &= 07777; goto &fetch; }
$core[001711] = 01030; $code[001711] = *I01711; sub I01711 { $lac += $core[000030]; goto &fetch; }
$core[001712] = 07004; $code[001712] = *I01712; sub I01712 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001713] = 01045; $code[001713] = *I01713; sub I01713 { $lac += $core[000045]; goto &fetch; }
$core[001714] = 07040; $code[001714] = *I01714; sub I01714 { $lac ^= 07777; goto &fetch; }
$core[001715] = 07450; $code[001715] = *I01715; sub I01715 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001716] = 07430; $code[001716] = *I01716; sub I01716 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001717] = 07402; $code[001717] = *I01717; sub I01717 { $hlt = 1; goto &fetch; }
$core[001720] = 07200; $code[001720] = *I01720; sub I01720 { $lac &= 010000; goto &fetch; }
$core[001721] = 07100; $code[001721] = *I01721; sub I01721 { $lac &= 07777; goto &fetch; }
$core[001722] = 01027; $code[001722] = *I01722; sub I01722 { $lac += $core[000027]; goto &fetch; }
$core[001723] = 07004; $code[001723] = *I01723; sub I01723 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001724] = 01044; $code[001724] = *I01724; sub I01724 { $lac += $core[000044]; goto &fetch; }
$core[001725] = 07040; $code[001725] = *I01725; sub I01725 { $lac ^= 07777; goto &fetch; }
$core[001726] = 07450; $code[001726] = *I01726; sub I01726 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001727] = 07430; $code[001727] = *I01727; sub I01727 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001730] = 07402; $code[001730] = *I01730; sub I01730 { $hlt = 1; goto &fetch; }
$core[001731] = 07200; $code[001731] = *I01731; sub I01731 { $lac &= 010000; goto &fetch; }
$core[001732] = 07100; $code[001732] = *I01732; sub I01732 { $lac &= 07777; goto &fetch; }
$core[001733] = 01026; $code[001733] = *I01733; sub I01733 { $lac += $core[000026]; goto &fetch; }
$core[001734] = 07004; $code[001734] = *I01734; sub I01734 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001735] = 01043; $code[001735] = *I01735; sub I01735 { $lac += $core[000043]; goto &fetch; }
$core[001736] = 07040; $code[001736] = *I01736; sub I01736 { $lac ^= 07777; goto &fetch; }
$core[001737] = 07450; $code[001737] = *I01737; sub I01737 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001740] = 07430; $code[001740] = *I01740; sub I01740 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001741] = 07402; $code[001741] = *I01741; sub I01741 { $hlt = 1; goto &fetch; }
$core[001742] = 07200; $code[001742] = *I01742; sub I01742 { $lac &= 010000; goto &fetch; }
$core[001743] = 07100; $code[001743] = *I01743; sub I01743 { $lac &= 07777; goto &fetch; }
$core[001744] = 01025; $code[001744] = *I01744; sub I01744 { $lac += $core[000025]; goto &fetch; }
$core[001745] = 07004; $code[001745] = *I01745; sub I01745 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001746] = 01042; $code[001746] = *I01746; sub I01746 { $lac += $core[000042]; goto &fetch; }
$core[001747] = 07040; $code[001747] = *I01747; sub I01747 { $lac ^= 07777; goto &fetch; }
$core[001750] = 07450; $code[001750] = *I01750; sub I01750 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001751] = 07430; $code[001751] = *I01751; sub I01751 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001752] = 07402; $code[001752] = *I01752; sub I01752 { $hlt = 1; goto &fetch; }
$core[001753] = 07200; $code[001753] = *I01753; sub I01753 { $lac &= 010000; goto &fetch; }
$core[001754] = 07100; $code[001754] = *I01754; sub I01754 { $lac &= 07777; goto &fetch; }
$core[001755] = 01024; $code[001755] = *I01755; sub I01755 { $lac += $core[000024]; goto &fetch; }
$core[001756] = 07004; $code[001756] = *I01756; sub I01756 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001757] = 01041; $code[001757] = *I01757; sub I01757 { $lac += $core[000041]; goto &fetch; }
$core[001760] = 07040; $code[001760] = *I01760; sub I01760 { $lac ^= 07777; goto &fetch; }
$core[001761] = 07450; $code[001761] = *I01761; sub I01761 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001762] = 07430; $code[001762] = *I01762; sub I01762 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001763] = 07402; $code[001763] = *I01763; sub I01763 { $hlt = 1; goto &fetch; }
$core[001764] = 07200; $code[001764] = *I01764; sub I01764 { $lac &= 010000; goto &fetch; }
$core[001765] = 07100; $code[001765] = *I01765; sub I01765 { $lac &= 07777; goto &fetch; }
$core[001766] = 01023; $code[001766] = *I01766; sub I01766 { $lac += $core[000023]; goto &fetch; }
$core[001767] = 07004; $code[001767] = *I01767; sub I01767 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001770] = 01040; $code[001770] = *I01770; sub I01770 { $lac += $core[000040]; goto &fetch; }
$core[001771] = 07040; $code[001771] = *I01771; sub I01771 { $lac ^= 07777; goto &fetch; }
$core[001772] = 07450; $code[001772] = *I01772; sub I01772 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001773] = 07430; $code[001773] = *I01773; sub I01773 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001774] = 07402; $code[001774] = *I01774; sub I01774 { $hlt = 1; goto &fetch; }
$core[001775] = 07000; $code[001775] = *I01775; sub I01775 { goto &fetch; }
$core[001776] = 07000; $code[001776] = *I01776; sub I01776 { goto &fetch; }
$core[001777] = 07000; $code[001777] = *I01777; sub I01777 { goto &fetch; }
$core[002000] = 07200; $code[002000] = *I02000; sub I02000 { $lac &= 010000; goto &fetch; }
$core[002001] = 07100; $code[002001] = *I02001; sub I02001 { $lac &= 07777; goto &fetch; }
$core[002002] = 01022; $code[002002] = *I02002; sub I02002 { $lac += $core[000022]; goto &fetch; }
$core[002003] = 07004; $code[002003] = *I02003; sub I02003 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002004] = 01037; $code[002004] = *I02004; sub I02004 { $lac += $core[000037]; goto &fetch; }
$core[002005] = 07040; $code[002005] = *I02005; sub I02005 { $lac ^= 07777; goto &fetch; }
$core[002006] = 07450; $code[002006] = *I02006; sub I02006 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002007] = 07430; $code[002007] = *I02007; sub I02007 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002010] = 07402; $code[002010] = *I02010; sub I02010 { $hlt = 1; goto &fetch; }
$core[002011] = 07200; $code[002011] = *I02011; sub I02011 { $lac &= 010000; goto &fetch; }
$core[002012] = 07100; $code[002012] = *I02012; sub I02012 { $lac &= 07777; goto &fetch; }
$core[002013] = 01021; $code[002013] = *I02013; sub I02013 { $lac += $core[000021]; goto &fetch; }
$core[002014] = 07004; $code[002014] = *I02014; sub I02014 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002015] = 01036; $code[002015] = *I02015; sub I02015 { $lac += $core[000036]; goto &fetch; }
$core[002016] = 07040; $code[002016] = *I02016; sub I02016 { $lac ^= 07777; goto &fetch; }
$core[002017] = 07450; $code[002017] = *I02017; sub I02017 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002020] = 07430; $code[002020] = *I02020; sub I02020 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002021] = 07402; $code[002021] = *I02021; sub I02021 { $hlt = 1; goto &fetch; }
$core[002022] = 07200; $code[002022] = *I02022; sub I02022 { $lac &= 010000; goto &fetch; }
$core[002023] = 07100; $code[002023] = *I02023; sub I02023 { $lac &= 07777; goto &fetch; }
$core[002024] = 07020; $code[002024] = *I02024; sub I02024 { $lac ^= 010000; goto &fetch; }
$core[002025] = 07004; $code[002025] = *I02025; sub I02025 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002026] = 01035; $code[002026] = *I02026; sub I02026 { $lac += $core[000035]; goto &fetch; }
$core[002027] = 07040; $code[002027] = *I02027; sub I02027 { $lac ^= 07777; goto &fetch; }
$core[002030] = 07450; $code[002030] = *I02030; sub I02030 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002031] = 07430; $code[002031] = *I02031; sub I02031 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002032] = 07402; $code[002032] = *I02032; sub I02032 { $hlt = 1; goto &fetch; }
$core[002033] = 07200; $code[002033] = *I02033; sub I02033 { $lac &= 010000; goto &fetch; }
$core[002034] = 07100; $code[002034] = *I02034; sub I02034 { $lac &= 07777; goto &fetch; }
$core[002035] = 01033; $code[002035] = *I02035; sub I02035 { $lac += $core[000033]; goto &fetch; }
$core[002036] = 07006; $code[002036] = *I02036; sub I02036 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002037] = 07420; $code[002037] = *I02037; sub I02037 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002040] = 07402; $code[002040] = *I02040; sub I02040 { $hlt = 1; goto &fetch; }
$core[002041] = 07200; $code[002041] = *I02041; sub I02041 { $lac &= 010000; goto &fetch; }
$core[002042] = 07100; $code[002042] = *I02042; sub I02042 { $lac &= 07777; goto &fetch; }
$core[002043] = 01020; $code[002043] = *I02043; sub I02043 { $lac += $core[000020]; goto &fetch; }
$core[002044] = 07006; $code[002044] = *I02044; sub I02044 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002045] = 07440; $code[002045] = *I02045; sub I02045 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002046] = 07402; $code[002046] = *I02046; sub I02046 { $hlt = 1; goto &fetch; }
$core[002047] = 07200; $code[002047] = *I02047; sub I02047 { $lac &= 010000; goto &fetch; }
$core[002050] = 07100; $code[002050] = *I02050; sub I02050 { $lac &= 07777; goto &fetch; }
$core[002051] = 01020; $code[002051] = *I02051; sub I02051 { $lac += $core[000020]; goto &fetch; }
$core[002052] = 07006; $code[002052] = *I02052; sub I02052 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002053] = 07430; $code[002053] = *I02053; sub I02053 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002054] = 07402; $code[002054] = *I02054; sub I02054 { $hlt = 1; goto &fetch; }
$core[002055] = 07200; $code[002055] = *I02055; sub I02055 { $lac &= 010000; goto &fetch; }
$core[002056] = 07100; $code[002056] = *I02056; sub I02056 { $lac &= 07777; goto &fetch; }
$core[002057] = 07020; $code[002057] = *I02057; sub I02057 { $lac ^= 010000; goto &fetch; }
$core[002060] = 01020; $code[002060] = *I02060; sub I02060 { $lac += $core[000020]; goto &fetch; }
$core[002061] = 07006; $code[002061] = *I02061; sub I02061 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002062] = 07430; $code[002062] = *I02062; sub I02062 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002063] = 07402; $code[002063] = *I02063; sub I02063 { $hlt = 1; goto &fetch; }
$core[002064] = 07200; $code[002064] = *I02064; sub I02064 { $lac &= 010000; goto &fetch; }
$core[002065] = 07100; $code[002065] = *I02065; sub I02065 { $lac &= 07777; goto &fetch; }
$core[002066] = 07020; $code[002066] = *I02066; sub I02066 { $lac ^= 010000; goto &fetch; }
$core[002067] = 01051; $code[002067] = *I02067; sub I02067 { $lac += $core[000051]; goto &fetch; }
$core[002070] = 07006; $code[002070] = *I02070; sub I02070 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002071] = 07040; $code[002071] = *I02071; sub I02071 { $lac ^= 07777; goto &fetch; }
$core[002072] = 07440; $code[002072] = *I02072; sub I02072 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002073] = 07402; $code[002073] = *I02073; sub I02073 { $hlt = 1; goto &fetch; }
$core[002074] = 07200; $code[002074] = *I02074; sub I02074 { $lac &= 010000; goto &fetch; }
$core[002075] = 07100; $code[002075] = *I02075; sub I02075 { $lac &= 07777; goto &fetch; }
$core[002076] = 01034; $code[002076] = *I02076; sub I02076 { $lac += $core[000034]; goto &fetch; }
$core[002077] = 07006; $code[002077] = *I02077; sub I02077 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002100] = 01035; $code[002100] = *I02100; sub I02100 { $lac += $core[000035]; goto &fetch; }
$core[002101] = 07040; $code[002101] = *I02101; sub I02101 { $lac ^= 07777; goto &fetch; }
$core[002102] = 07450; $code[002102] = *I02102; sub I02102 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002103] = 07430; $code[002103] = *I02103; sub I02103 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002104] = 07402; $code[002104] = *I02104; sub I02104 { $hlt = 1; goto &fetch; }
$core[002105] = 07200; $code[002105] = *I02105; sub I02105 { $lac &= 010000; goto &fetch; }
$core[002106] = 07100; $code[002106] = *I02106; sub I02106 { $lac &= 07777; goto &fetch; }
$core[002107] = 01033; $code[002107] = *I02107; sub I02107 { $lac += $core[000033]; goto &fetch; }
$core[002110] = 07006; $code[002110] = *I02110; sub I02110 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002111] = 07450; $code[002111] = *I02111; sub I02111 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002112] = 07420; $code[002112] = *I02112; sub I02112 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002113] = 07402; $code[002113] = *I02113; sub I02113 { $hlt = 1; goto &fetch; }
$core[002114] = 07200; $code[002114] = *I02114; sub I02114 { $lac &= 010000; goto &fetch; }
$core[002115] = 07100; $code[002115] = *I02115; sub I02115 { $lac &= 07777; goto &fetch; }
$core[002116] = 01032; $code[002116] = *I02116; sub I02116 { $lac += $core[000032]; goto &fetch; }
$core[002117] = 07006; $code[002117] = *I02117; sub I02117 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002120] = 01050; $code[002120] = *I02120; sub I02120 { $lac += $core[000050]; goto &fetch; }
$core[002121] = 07040; $code[002121] = *I02121; sub I02121 { $lac ^= 07777; goto &fetch; }
$core[002122] = 07450; $code[002122] = *I02122; sub I02122 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002123] = 07430; $code[002123] = *I02123; sub I02123 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002124] = 07402; $code[002124] = *I02124; sub I02124 { $hlt = 1; goto &fetch; }
$core[002125] = 07200; $code[002125] = *I02125; sub I02125 { $lac &= 010000; goto &fetch; }
$core[002126] = 07100; $code[002126] = *I02126; sub I02126 { $lac &= 07777; goto &fetch; }
$core[002127] = 01031; $code[002127] = *I02127; sub I02127 { $lac += $core[000031]; goto &fetch; }
$core[002130] = 07006; $code[002130] = *I02130; sub I02130 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002131] = 01047; $code[002131] = *I02131; sub I02131 { $lac += $core[000047]; goto &fetch; }
$core[002132] = 07040; $code[002132] = *I02132; sub I02132 { $lac ^= 07777; goto &fetch; }
$core[002133] = 07450; $code[002133] = *I02133; sub I02133 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002134] = 07430; $code[002134] = *I02134; sub I02134 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002135] = 07402; $code[002135] = *I02135; sub I02135 { $hlt = 1; goto &fetch; }
$core[002136] = 07200; $code[002136] = *I02136; sub I02136 { $lac &= 010000; goto &fetch; }
$core[002137] = 07100; $code[002137] = *I02137; sub I02137 { $lac &= 07777; goto &fetch; }
$core[002140] = 01030; $code[002140] = *I02140; sub I02140 { $lac += $core[000030]; goto &fetch; }
$core[002141] = 07006; $code[002141] = *I02141; sub I02141 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002142] = 01046; $code[002142] = *I02142; sub I02142 { $lac += $core[000046]; goto &fetch; }
$core[002143] = 07040; $code[002143] = *I02143; sub I02143 { $lac ^= 07777; goto &fetch; }
$core[002144] = 07450; $code[002144] = *I02144; sub I02144 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002145] = 07430; $code[002145] = *I02145; sub I02145 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002146] = 07402; $code[002146] = *I02146; sub I02146 { $hlt = 1; goto &fetch; }
$core[002147] = 07200; $code[002147] = *I02147; sub I02147 { $lac &= 010000; goto &fetch; }
$core[002150] = 07100; $code[002150] = *I02150; sub I02150 { $lac &= 07777; goto &fetch; }
$core[002151] = 01027; $code[002151] = *I02151; sub I02151 { $lac += $core[000027]; goto &fetch; }
$core[002152] = 07006; $code[002152] = *I02152; sub I02152 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002153] = 01045; $code[002153] = *I02153; sub I02153 { $lac += $core[000045]; goto &fetch; }
$core[002154] = 07040; $code[002154] = *I02154; sub I02154 { $lac ^= 07777; goto &fetch; }
$core[002155] = 07450; $code[002155] = *I02155; sub I02155 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002156] = 07430; $code[002156] = *I02156; sub I02156 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002157] = 07402; $code[002157] = *I02157; sub I02157 { $hlt = 1; goto &fetch; }
$core[002160] = 07200; $code[002160] = *I02160; sub I02160 { $lac &= 010000; goto &fetch; }
$core[002161] = 07100; $code[002161] = *I02161; sub I02161 { $lac &= 07777; goto &fetch; }
$core[002162] = 01026; $code[002162] = *I02162; sub I02162 { $lac += $core[000026]; goto &fetch; }
$core[002163] = 07006; $code[002163] = *I02163; sub I02163 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002164] = 01044; $code[002164] = *I02164; sub I02164 { $lac += $core[000044]; goto &fetch; }
$core[002165] = 07040; $code[002165] = *I02165; sub I02165 { $lac ^= 07777; goto &fetch; }
$core[002166] = 07450; $code[002166] = *I02166; sub I02166 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002167] = 07430; $code[002167] = *I02167; sub I02167 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002170] = 07402; $code[002170] = *I02170; sub I02170 { $hlt = 1; goto &fetch; }
$core[002171] = 07000; $code[002171] = *I02171; sub I02171 { goto &fetch; }
$core[002172] = 07000; $code[002172] = *I02172; sub I02172 { goto &fetch; }
$core[002173] = 07000; $code[002173] = *I02173; sub I02173 { goto &fetch; }
$core[002174] = 07000; $code[002174] = *I02174; sub I02174 { goto &fetch; }
$core[002175] = 07000; $code[002175] = *I02175; sub I02175 { goto &fetch; }
$core[002176] = 07000; $code[002176] = *I02176; sub I02176 { goto &fetch; }
$core[002177] = 07000; $code[002177] = *I02177; sub I02177 { goto &fetch; }
$core[002200] = 07200; $code[002200] = *I02200; sub I02200 { $lac &= 010000; goto &fetch; }
$core[002201] = 07100; $code[002201] = *I02201; sub I02201 { $lac &= 07777; goto &fetch; }
$core[002202] = 01025; $code[002202] = *I02202; sub I02202 { $lac += $core[000025]; goto &fetch; }
$core[002203] = 07006; $code[002203] = *I02203; sub I02203 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002204] = 01043; $code[002204] = *I02204; sub I02204 { $lac += $core[000043]; goto &fetch; }
$core[002205] = 07040; $code[002205] = *I02205; sub I02205 { $lac ^= 07777; goto &fetch; }
$core[002206] = 07450; $code[002206] = *I02206; sub I02206 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002207] = 07430; $code[002207] = *I02207; sub I02207 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002210] = 07402; $code[002210] = *I02210; sub I02210 { $hlt = 1; goto &fetch; }
$core[002211] = 07200; $code[002211] = *I02211; sub I02211 { $lac &= 010000; goto &fetch; }
$core[002212] = 07100; $code[002212] = *I02212; sub I02212 { $lac &= 07777; goto &fetch; }
$core[002213] = 01024; $code[002213] = *I02213; sub I02213 { $lac += $core[000024]; goto &fetch; }
$core[002214] = 07006; $code[002214] = *I02214; sub I02214 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002215] = 01042; $code[002215] = *I02215; sub I02215 { $lac += $core[000042]; goto &fetch; }
$core[002216] = 07040; $code[002216] = *I02216; sub I02216 { $lac ^= 07777; goto &fetch; }
$core[002217] = 07450; $code[002217] = *I02217; sub I02217 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002220] = 07430; $code[002220] = *I02220; sub I02220 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002221] = 07402; $code[002221] = *I02221; sub I02221 { $hlt = 1; goto &fetch; }
$core[002222] = 07200; $code[002222] = *I02222; sub I02222 { $lac &= 010000; goto &fetch; }
$core[002223] = 07100; $code[002223] = *I02223; sub I02223 { $lac &= 07777; goto &fetch; }
$core[002224] = 01023; $code[002224] = *I02224; sub I02224 { $lac += $core[000023]; goto &fetch; }
$core[002225] = 07006; $code[002225] = *I02225; sub I02225 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002226] = 01041; $code[002226] = *I02226; sub I02226 { $lac += $core[000041]; goto &fetch; }
$core[002227] = 07040; $code[002227] = *I02227; sub I02227 { $lac ^= 07777; goto &fetch; }
$core[002230] = 07450; $code[002230] = *I02230; sub I02230 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002231] = 07430; $code[002231] = *I02231; sub I02231 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002232] = 07402; $code[002232] = *I02232; sub I02232 { $hlt = 1; goto &fetch; }
$core[002233] = 07200; $code[002233] = *I02233; sub I02233 { $lac &= 010000; goto &fetch; }
$core[002234] = 07100; $code[002234] = *I02234; sub I02234 { $lac &= 07777; goto &fetch; }
$core[002235] = 01022; $code[002235] = *I02235; sub I02235 { $lac += $core[000022]; goto &fetch; }
$core[002236] = 07006; $code[002236] = *I02236; sub I02236 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002237] = 01040; $code[002237] = *I02237; sub I02237 { $lac += $core[000040]; goto &fetch; }
$core[002240] = 07040; $code[002240] = *I02240; sub I02240 { $lac ^= 07777; goto &fetch; }
$core[002241] = 07450; $code[002241] = *I02241; sub I02241 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002242] = 07430; $code[002242] = *I02242; sub I02242 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002243] = 07402; $code[002243] = *I02243; sub I02243 { $hlt = 1; goto &fetch; }
$core[002244] = 07200; $code[002244] = *I02244; sub I02244 { $lac &= 010000; goto &fetch; }
$core[002245] = 07100; $code[002245] = *I02245; sub I02245 { $lac &= 07777; goto &fetch; }
$core[002246] = 01021; $code[002246] = *I02246; sub I02246 { $lac += $core[000021]; goto &fetch; }
$core[002247] = 07006; $code[002247] = *I02247; sub I02247 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002250] = 01037; $code[002250] = *I02250; sub I02250 { $lac += $core[000037]; goto &fetch; }
$core[002251] = 07040; $code[002251] = *I02251; sub I02251 { $lac ^= 07777; goto &fetch; }
$core[002252] = 07450; $code[002252] = *I02252; sub I02252 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002253] = 07430; $code[002253] = *I02253; sub I02253 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002254] = 07402; $code[002254] = *I02254; sub I02254 { $hlt = 1; goto &fetch; }
$core[002255] = 07200; $code[002255] = *I02255; sub I02255 { $lac &= 010000; goto &fetch; }
$core[002256] = 07100; $code[002256] = *I02256; sub I02256 { $lac &= 07777; goto &fetch; }
$core[002257] = 07020; $code[002257] = *I02257; sub I02257 { $lac ^= 010000; goto &fetch; }
$core[002260] = 07006; $code[002260] = *I02260; sub I02260 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002261] = 01036; $code[002261] = *I02261; sub I02261 { $lac += $core[000036]; goto &fetch; }
$core[002262] = 07040; $code[002262] = *I02262; sub I02262 { $lac ^= 07777; goto &fetch; }
$core[002263] = 07450; $code[002263] = *I02263; sub I02263 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002264] = 07430; $code[002264] = *I02264; sub I02264 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002265] = 07402; $code[002265] = *I02265; sub I02265 { $hlt = 1; goto &fetch; }
$core[002266] = 07200; $code[002266] = *I02266; sub I02266 { $lac &= 010000; goto &fetch; }
$core[002267] = 07100; $code[002267] = *I02267; sub I02267 { $lac &= 07777; goto &fetch; }
$core[002270] = 07040; $code[002270] = *I02270; sub I02270 { $lac ^= 07777; goto &fetch; }
$core[002271] = 07020; $code[002271] = *I02271; sub I02271 { $lac ^= 010000; goto &fetch; }
$core[002272] = 07300; $code[002272] = *I02272; sub I02272 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002273] = 07420; $code[002273] = *I02273; sub I02273 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002274] = 07440; $code[002274] = *I02274; sub I02274 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002275] = 07402; $code[002275] = *I02275; sub I02275 { $hlt = 1; goto &fetch; }
$core[002276] = 07200; $code[002276] = *I02276; sub I02276 { $lac &= 010000; goto &fetch; }
$core[002277] = 01053; $code[002277] = *I02277; sub I02277 { $lac += $core[000053]; goto &fetch; }
$core[002300] = 07240; $code[002300] = *I02300; sub I02300 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002301] = 07040; $code[002301] = *I02301; sub I02301 { $lac ^= 07777; goto &fetch; }
$core[002302] = 07440; $code[002302] = *I02302; sub I02302 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002303] = 07402; $code[002303] = *I02303; sub I02303 { $hlt = 1; goto &fetch; }
$core[002304] = 07200; $code[002304] = *I02304; sub I02304 { $lac &= 010000; goto &fetch; }
$core[002305] = 07100; $code[002305] = *I02305; sub I02305 { $lac &= 07777; goto &fetch; }
$core[002306] = 07040; $code[002306] = *I02306; sub I02306 { $lac ^= 07777; goto &fetch; }
$core[002307] = 07140; $code[002307] = *I02307; sub I02307 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002310] = 07420; $code[002310] = *I02310; sub I02310 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002311] = 07440; $code[002311] = *I02311; sub I02311 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002312] = 07402; $code[002312] = *I02312; sub I02312 { $hlt = 1; goto &fetch; }
$core[002313] = 07100; $code[002313] = *I02313; sub I02313 { $lac &= 07777; goto &fetch; }
$core[002314] = 07020; $code[002314] = *I02314; sub I02314 { $lac ^= 010000; goto &fetch; }
$core[002315] = 07200; $code[002315] = *I02315; sub I02315 { $lac &= 010000; goto &fetch; }
$core[002316] = 07040; $code[002316] = *I02316; sub I02316 { $lac ^= 07777; goto &fetch; }
$core[002317] = 07340; $code[002317] = *I02317; sub I02317 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002320] = 07040; $code[002320] = *I02320; sub I02320 { $lac ^= 07777; goto &fetch; }
$core[002321] = 07420; $code[002321] = *I02321; sub I02321 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002322] = 07440; $code[002322] = *I02322; sub I02322 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002323] = 07402; $code[002323] = *I02323; sub I02323 { $hlt = 1; goto &fetch; }
$core[002324] = 07200; $code[002324] = *I02324; sub I02324 { $lac &= 010000; goto &fetch; }
$core[002325] = 07100; $code[002325] = *I02325; sub I02325 { $lac &= 07777; goto &fetch; }
$core[002326] = 07040; $code[002326] = *I02326; sub I02326 { $lac ^= 07777; goto &fetch; }
$core[002327] = 07220; $code[002327] = *I02327; sub I02327 { $lac &= 010000; $lac ^= 010000; goto &fetch; }
$core[002330] = 07430; $code[002330] = *I02330; sub I02330 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002331] = 07440; $code[002331] = *I02331; sub I02331 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002332] = 07402; $code[002332] = *I02332; sub I02332 { $hlt = 1; goto &fetch; }
$core[002333] = 07100; $code[002333] = *I02333; sub I02333 { $lac &= 07777; goto &fetch; }
$core[002334] = 07020; $code[002334] = *I02334; sub I02334 { $lac ^= 010000; goto &fetch; }
$core[002335] = 07120; $code[002335] = *I02335; sub I02335 { $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002336] = 07420; $code[002336] = *I02336; sub I02336 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002337] = 07402; $code[002337] = *I02337; sub I02337 { $hlt = 1; goto &fetch; }
$core[002340] = 07100; $code[002340] = *I02340; sub I02340 { $lac &= 07777; goto &fetch; }
$core[002341] = 07120; $code[002341] = *I02341; sub I02341 { $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002342] = 07420; $code[002342] = *I02342; sub I02342 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002343] = 07402; $code[002343] = *I02343; sub I02343 { $hlt = 1; goto &fetch; }
$core[002344] = 07120; $code[002344] = *I02344; sub I02344 { $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002345] = 07240; $code[002345] = *I02345; sub I02345 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[002346] = 07320; $code[002346] = *I02346; sub I02346 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002347] = 07430; $code[002347] = *I02347; sub I02347 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002350] = 07440; $code[002350] = *I02350; sub I02350 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002351] = 07402; $code[002351] = *I02351; sub I02351 { $hlt = 1; goto &fetch; }
$core[002352] = 07340; $code[002352] = *I02352; sub I02352 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002353] = 07320; $code[002353] = *I02353; sub I02353 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002354] = 07430; $code[002354] = *I02354; sub I02354 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002355] = 07440; $code[002355] = *I02355; sub I02355 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002356] = 07402; $code[002356] = *I02356; sub I02356 { $hlt = 1; goto &fetch; }
$core[002357] = 07340; $code[002357] = *I02357; sub I02357 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002360] = 07060; $code[002360] = *I02360; sub I02360 { $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002361] = 07430; $code[002361] = *I02361; sub I02361 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002362] = 07440; $code[002362] = *I02362; sub I02362 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002363] = 07402; $code[002363] = *I02363; sub I02363 { $hlt = 1; goto &fetch; }
$core[002364] = 07300; $code[002364] = *I02364; sub I02364 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002365] = 01053; $code[002365] = *I02365; sub I02365 { $lac += $core[000053]; goto &fetch; }
$core[002366] = 07340; $code[002366] = *I02366; sub I02366 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[002367] = 07040; $code[002367] = *I02367; sub I02367 { $lac ^= 07777; goto &fetch; }
$core[002370] = 07420; $code[002370] = *I02370; sub I02370 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002371] = 07440; $code[002371] = *I02371; sub I02371 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002372] = 07402; $code[002372] = *I02372; sub I02372 { $hlt = 1; goto &fetch; }
$core[002373] = 07000; $code[002373] = *I02373; sub I02373 { goto &fetch; }
$core[002374] = 07000; $code[002374] = *I02374; sub I02374 { goto &fetch; }
$core[002375] = 07000; $code[002375] = *I02375; sub I02375 { goto &fetch; }
$core[002376] = 07000; $code[002376] = *I02376; sub I02376 { goto &fetch; }
$core[002377] = 07000; $code[002377] = *I02377; sub I02377 { goto &fetch; }
$core[002400] = 07300; $code[002400] = *I02400; sub I02400 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002401] = 01053; $code[002401] = *I02401; sub I02401 { $lac += $core[000053]; goto &fetch; }
$core[002402] = 07160; $code[002402] = *I02402; sub I02402 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002403] = 01053; $code[002403] = *I02403; sub I02403 { $lac += $core[000053]; goto &fetch; }
$core[002404] = 07040; $code[002404] = *I02404; sub I02404 { $lac ^= 07777; goto &fetch; }
$core[002405] = 07430; $code[002405] = *I02405; sub I02405 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002406] = 07440; $code[002406] = *I02406; sub I02406 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002407] = 07402; $code[002407] = *I02407; sub I02407 { $hlt = 1; goto &fetch; }
$core[002410] = 07300; $code[002410] = *I02410; sub I02410 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002411] = 07020; $code[002411] = *I02411; sub I02411 { $lac ^= 010000; goto &fetch; }
$core[002412] = 07160; $code[002412] = *I02412; sub I02412 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002413] = 07040; $code[002413] = *I02413; sub I02413 { $lac ^= 07777; goto &fetch; }
$core[002414] = 07430; $code[002414] = *I02414; sub I02414 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002415] = 07440; $code[002415] = *I02415; sub I02415 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002416] = 07402; $code[002416] = *I02416; sub I02416 { $hlt = 1; goto &fetch; }
$core[002417] = 07300; $code[002417] = *I02417; sub I02417 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002420] = 01053; $code[002420] = *I02420; sub I02420 { $lac += $core[000053]; goto &fetch; }
$core[002421] = 07360; $code[002421] = *I02421; sub I02421 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002422] = 07040; $code[002422] = *I02422; sub I02422 { $lac ^= 07777; goto &fetch; }
$core[002423] = 07430; $code[002423] = *I02423; sub I02423 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002424] = 07440; $code[002424] = *I02424; sub I02424 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002425] = 07402; $code[002425] = *I02425; sub I02425 { $hlt = 1; goto &fetch; }
$core[002426] = 07320; $code[002426] = *I02426; sub I02426 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002427] = 01052; $code[002427] = *I02427; sub I02427 { $lac += $core[000052]; goto &fetch; }
$core[002430] = 07360; $code[002430] = *I02430; sub I02430 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002431] = 07040; $code[002431] = *I02431; sub I02431 { $lac ^= 07777; goto &fetch; }
$core[002432] = 07430; $code[002432] = *I02432; sub I02432 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002433] = 07440; $code[002433] = *I02433; sub I02433 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002434] = 07402; $code[002434] = *I02434; sub I02434 { $hlt = 1; goto &fetch; }
$core[002435] = 07200; $code[002435] = *I02435; sub I02435 { $lac &= 010000; goto &fetch; }
$core[002436] = 01053; $code[002436] = *I02436; sub I02436 { $lac += $core[000053]; goto &fetch; }
$core[002437] = 07201; $code[002437] = *I02437; sub I02437 { $lac &= 010000; $lac++; goto &fetch; }
$core[002440] = 01035; $code[002440] = *I02440; sub I02440 { $lac += $core[000035]; goto &fetch; }
$core[002441] = 07040; $code[002441] = *I02441; sub I02441 { $lac ^= 07777; goto &fetch; }
$core[002442] = 07440; $code[002442] = *I02442; sub I02442 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002443] = 07402; $code[002443] = *I02443; sub I02443 { $hlt = 1; goto &fetch; }
$core[002444] = 07320; $code[002444] = *I02444; sub I02444 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002445] = 01035; $code[002445] = *I02445; sub I02445 { $lac += $core[000035]; goto &fetch; }
$core[002446] = 07101; $code[002446] = *I02446; sub I02446 { $lac &= 07777; $lac++; goto &fetch; }
$core[002447] = 07040; $code[002447] = *I02447; sub I02447 { $lac ^= 07777; goto &fetch; }
$core[002450] = 07420; $code[002450] = *I02450; sub I02450 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002451] = 07440; $code[002451] = *I02451; sub I02451 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002452] = 07402; $code[002452] = *I02452; sub I02452 { $hlt = 1; goto &fetch; }
$core[002453] = 07320; $code[002453] = *I02453; sub I02453 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002454] = 01053; $code[002454] = *I02454; sub I02454 { $lac += $core[000053]; goto &fetch; }
$core[002455] = 07301; $code[002455] = *I02455; sub I02455 { $lac &= 010000; $lac &= 07777; $lac++; goto &fetch; }
$core[002456] = 01035; $code[002456] = *I02456; sub I02456 { $lac += $core[000035]; goto &fetch; }
$core[002457] = 07040; $code[002457] = *I02457; sub I02457 { $lac ^= 07777; goto &fetch; }
$core[002460] = 07420; $code[002460] = *I02460; sub I02460 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002461] = 07440; $code[002461] = *I02461; sub I02461 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002462] = 07402; $code[002462] = *I02462; sub I02462 { $hlt = 1; goto &fetch; }
$core[002463] = 07300; $code[002463] = *I02463; sub I02463 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002464] = 07041; $code[002464] = *I02464; sub I02464 { $lac ^= 07777; $lac++; goto &fetch; }
$core[002465] = 07430; $code[002465] = *I02465; sub I02465 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002466] = 07440; $code[002466] = *I02466; sub I02466 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002467] = 07402; $code[002467] = *I02467; sub I02467 { $hlt = 1; goto &fetch; }
$core[002470] = 07300; $code[002470] = *I02470; sub I02470 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002471] = 01053; $code[002471] = *I02471; sub I02471 { $lac += $core[000053]; goto &fetch; }
$core[002472] = 07241; $code[002472] = *I02472; sub I02472 { $lac &= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[002473] = 07430; $code[002473] = *I02473; sub I02473 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002474] = 07440; $code[002474] = *I02474; sub I02474 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002475] = 07402; $code[002475] = *I02475; sub I02475 { $hlt = 1; goto &fetch; }
$core[002476] = 07320; $code[002476] = *I02476; sub I02476 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002477] = 01021; $code[002477] = *I02477; sub I02477 { $lac += $core[000021]; goto &fetch; }
$core[002500] = 07141; $code[002500] = *I02500; sub I02500 { $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[002501] = 07040; $code[002501] = *I02501; sub I02501 { $lac ^= 07777; goto &fetch; }
$core[002502] = 07420; $code[002502] = *I02502; sub I02502 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002503] = 07440; $code[002503] = *I02503; sub I02503 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002504] = 07402; $code[002504] = *I02504; sub I02504 { $hlt = 1; goto &fetch; }
$core[002505] = 07320; $code[002505] = *I02505; sub I02505 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002506] = 01053; $code[002506] = *I02506; sub I02506 { $lac += $core[000053]; goto &fetch; }
$core[002507] = 07341; $code[002507] = *I02507; sub I02507 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[002510] = 07430; $code[002510] = *I02510; sub I02510 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002511] = 07440; $code[002511] = *I02511; sub I02511 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002512] = 07402; $code[002512] = *I02512; sub I02512 { $hlt = 1; goto &fetch; }
$core[002513] = 07300; $code[002513] = *I02513; sub I02513 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002514] = 01052; $code[002514] = *I02514; sub I02514 { $lac += $core[000052]; goto &fetch; }
$core[002515] = 07341; $code[002515] = *I02515; sub I02515 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac++; goto &fetch; }
$core[002516] = 07430; $code[002516] = *I02516; sub I02516 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002517] = 07440; $code[002517] = *I02517; sub I02517 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002520] = 07402; $code[002520] = *I02520; sub I02520 { $hlt = 1; goto &fetch; }
$core[002521] = 07300; $code[002521] = *I02521; sub I02521 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002522] = 01035; $code[002522] = *I02522; sub I02522 { $lac += $core[000035]; goto &fetch; }
$core[002523] = 07021; $code[002523] = *I02523; sub I02523 { $lac ^= 010000; $lac++; goto &fetch; }
$core[002524] = 07040; $code[002524] = *I02524; sub I02524 { $lac ^= 07777; goto &fetch; }
$core[002525] = 07430; $code[002525] = *I02525; sub I02525 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002526] = 07440; $code[002526] = *I02526; sub I02526 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002527] = 07402; $code[002527] = *I02527; sub I02527 { $hlt = 1; goto &fetch; }
$core[002530] = 07320; $code[002530] = *I02530; sub I02530 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002531] = 01035; $code[002531] = *I02531; sub I02531 { $lac += $core[000035]; goto &fetch; }
$core[002532] = 07021; $code[002532] = *I02532; sub I02532 { $lac ^= 010000; $lac++; goto &fetch; }
$core[002533] = 07040; $code[002533] = *I02533; sub I02533 { $lac ^= 07777; goto &fetch; }
$core[002534] = 07420; $code[002534] = *I02534; sub I02534 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002535] = 07440; $code[002535] = *I02535; sub I02535 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002536] = 07402; $code[002536] = *I02536; sub I02536 { $hlt = 1; goto &fetch; }
$core[002537] = 07300; $code[002537] = *I02537; sub I02537 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002540] = 01053; $code[002540] = *I02540; sub I02540 { $lac += $core[000053]; goto &fetch; }
$core[002541] = 07221; $code[002541] = *I02541; sub I02541 { $lac &= 010000; $lac ^= 010000; $lac++; goto &fetch; }
$core[002542] = 01035; $code[002542] = *I02542; sub I02542 { $lac += $core[000035]; goto &fetch; }
$core[002543] = 07040; $code[002543] = *I02543; sub I02543 { $lac ^= 07777; goto &fetch; }
$core[002544] = 07430; $code[002544] = *I02544; sub I02544 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002545] = 07440; $code[002545] = *I02545; sub I02545 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002546] = 07402; $code[002546] = *I02546; sub I02546 { $hlt = 1; goto &fetch; }
$core[002547] = 07320; $code[002547] = *I02547; sub I02547 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002550] = 01035; $code[002550] = *I02550; sub I02550 { $lac += $core[000035]; goto &fetch; }
$core[002551] = 07121; $code[002551] = *I02551; sub I02551 { $lac &= 07777; $lac ^= 010000; $lac++; goto &fetch; }
$core[002552] = 07040; $code[002552] = *I02552; sub I02552 { $lac ^= 07777; goto &fetch; }
$core[002553] = 07430; $code[002553] = *I02553; sub I02553 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002554] = 07440; $code[002554] = *I02554; sub I02554 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002555] = 07402; $code[002555] = *I02555; sub I02555 { $hlt = 1; goto &fetch; }
$core[002556] = 07300; $code[002556] = *I02556; sub I02556 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002557] = 01035; $code[002557] = *I02557; sub I02557 { $lac += $core[000035]; goto &fetch; }
$core[002560] = 07121; $code[002560] = *I02560; sub I02560 { $lac &= 07777; $lac ^= 010000; $lac++; goto &fetch; }
$core[002561] = 07040; $code[002561] = *I02561; sub I02561 { $lac ^= 07777; goto &fetch; }
$core[002562] = 07430; $code[002562] = *I02562; sub I02562 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002563] = 07440; $code[002563] = *I02563; sub I02563 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002564] = 07402; $code[002564] = *I02564; sub I02564 { $hlt = 1; goto &fetch; }
$core[002565] = 07300; $code[002565] = *I02565; sub I02565 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002566] = 01053; $code[002566] = *I02566; sub I02566 { $lac += $core[000053]; goto &fetch; }
$core[002567] = 07321; $code[002567] = *I02567; sub I02567 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; goto &fetch; }
$core[002570] = 01035; $code[002570] = *I02570; sub I02570 { $lac += $core[000035]; goto &fetch; }
$core[002571] = 07040; $code[002571] = *I02571; sub I02571 { $lac ^= 07777; goto &fetch; }
$core[002572] = 07430; $code[002572] = *I02572; sub I02572 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002573] = 07440; $code[002573] = *I02573; sub I02573 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002574] = 07402; $code[002574] = *I02574; sub I02574 { $hlt = 1; goto &fetch; }
$core[002575] = 07000; $code[002575] = *I02575; sub I02575 { goto &fetch; }
$core[002576] = 07000; $code[002576] = *I02576; sub I02576 { goto &fetch; }
$core[002577] = 07000; $code[002577] = *I02577; sub I02577 { goto &fetch; }
$core[002600] = 07320; $code[002600] = *I02600; sub I02600 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002601] = 01053; $code[002601] = *I02601; sub I02601 { $lac += $core[000053]; goto &fetch; }
$core[002602] = 07321; $code[002602] = *I02602; sub I02602 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; goto &fetch; }
$core[002603] = 01035; $code[002603] = *I02603; sub I02603 { $lac += $core[000035]; goto &fetch; }
$core[002604] = 07040; $code[002604] = *I02604; sub I02604 { $lac ^= 07777; goto &fetch; }
$core[002605] = 07430; $code[002605] = *I02605; sub I02605 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002606] = 07440; $code[002606] = *I02606; sub I02606 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002607] = 07402; $code[002607] = *I02607; sub I02607 { $hlt = 1; goto &fetch; }
$core[002610] = 07300; $code[002610] = *I02610; sub I02610 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002611] = 01021; $code[002611] = *I02611; sub I02611 { $lac += $core[000021]; goto &fetch; }
$core[002612] = 07061; $code[002612] = *I02612; sub I02612 { $lac ^= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[002613] = 07040; $code[002613] = *I02613; sub I02613 { $lac ^= 07777; goto &fetch; }
$core[002614] = 07430; $code[002614] = *I02614; sub I02614 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002615] = 07440; $code[002615] = *I02615; sub I02615 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002616] = 07402; $code[002616] = *I02616; sub I02616 { $hlt = 1; goto &fetch; }
$core[002617] = 07320; $code[002617] = *I02617; sub I02617 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002620] = 01021; $code[002620] = *I02620; sub I02620 { $lac += $core[000021]; goto &fetch; }
$core[002621] = 07061; $code[002621] = *I02621; sub I02621 { $lac ^= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[002622] = 07040; $code[002622] = *I02622; sub I02622 { $lac ^= 07777; goto &fetch; }
$core[002623] = 07420; $code[002623] = *I02623; sub I02623 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002624] = 07440; $code[002624] = *I02624; sub I02624 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002625] = 07402; $code[002625] = *I02625; sub I02625 { $hlt = 1; goto &fetch; }
$core[002626] = 07300; $code[002626] = *I02626; sub I02626 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002627] = 01053; $code[002627] = *I02627; sub I02627 { $lac += $core[000053]; goto &fetch; }
$core[002630] = 07261; $code[002630] = *I02630; sub I02630 { $lac &= 010000; $lac ^= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[002631] = 07420; $code[002631] = *I02631; sub I02631 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002632] = 07430; $code[002632] = *I02632; sub I02632 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002633] = 07402; $code[002633] = *I02633; sub I02633 { $hlt = 1; goto &fetch; }
$core[002634] = 07320; $code[002634] = *I02634; sub I02634 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002635] = 01053; $code[002635] = *I02635; sub I02635 { $lac += $core[000053]; goto &fetch; }
$core[002636] = 07261; $code[002636] = *I02636; sub I02636 { $lac &= 010000; $lac ^= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[002637] = 07430; $code[002637] = *I02637; sub I02637 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002640] = 07440; $code[002640] = *I02640; sub I02640 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002641] = 07402; $code[002641] = *I02641; sub I02641 { $hlt = 1; goto &fetch; }
$core[002642] = 07300; $code[002642] = *I02642; sub I02642 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002643] = 01021; $code[002643] = *I02643; sub I02643 { $lac += $core[000021]; goto &fetch; }
$core[002644] = 07161; $code[002644] = *I02644; sub I02644 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[002645] = 07040; $code[002645] = *I02645; sub I02645 { $lac ^= 07777; goto &fetch; }
$core[002646] = 07430; $code[002646] = *I02646; sub I02646 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002647] = 07440; $code[002647] = *I02647; sub I02647 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002650] = 07402; $code[002650] = *I02650; sub I02650 { $hlt = 1; goto &fetch; }
$core[002651] = 07320; $code[002651] = *I02651; sub I02651 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002652] = 01021; $code[002652] = *I02652; sub I02652 { $lac += $core[000021]; goto &fetch; }
$core[002653] = 07161; $code[002653] = *I02653; sub I02653 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[002654] = 07040; $code[002654] = *I02654; sub I02654 { $lac ^= 07777; goto &fetch; }
$core[002655] = 07430; $code[002655] = *I02655; sub I02655 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002656] = 07440; $code[002656] = *I02656; sub I02656 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002657] = 07402; $code[002657] = *I02657; sub I02657 { $hlt = 1; goto &fetch; }
$core[002660] = 07300; $code[002660] = *I02660; sub I02660 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[002661] = 01053; $code[002661] = *I02661; sub I02661 { $lac += $core[000053]; goto &fetch; }
$core[002662] = 07361; $code[002662] = *I02662; sub I02662 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[002663] = 07420; $code[002663] = *I02663; sub I02663 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002664] = 07440; $code[002664] = *I02664; sub I02664 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002665] = 07402; $code[002665] = *I02665; sub I02665 { $hlt = 1; goto &fetch; }
$core[002666] = 07360; $code[002666] = *I02666; sub I02666 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002667] = 07210; $code[002667] = *I02667; sub I02667 { $lac &= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002670] = 01050; $code[002670] = *I02670; sub I02670 { $lac += $core[000050]; goto &fetch; }
$core[002671] = 07040; $code[002671] = *I02671; sub I02671 { $lac ^= 07777; goto &fetch; }
$core[002672] = 07420; $code[002672] = *I02672; sub I02672 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002673] = 07440; $code[002673] = *I02673; sub I02673 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002674] = 07402; $code[002674] = *I02674; sub I02674 { $hlt = 1; goto &fetch; }
$core[002675] = 07360; $code[002675] = *I02675; sub I02675 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002676] = 07204; $code[002676] = *I02676; sub I02676 { $lac &= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002677] = 01035; $code[002677] = *I02677; sub I02677 { $lac += $core[000035]; goto &fetch; }
$core[002700] = 07040; $code[002700] = *I02700; sub I02700 { $lac ^= 07777; goto &fetch; }
$core[002701] = 07420; $code[002701] = *I02701; sub I02701 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002702] = 07440; $code[002702] = *I02702; sub I02702 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002703] = 07402; $code[002703] = *I02703; sub I02703 { $hlt = 1; goto &fetch; }
$core[002704] = 07360; $code[002704] = *I02704; sub I02704 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002705] = 07212; $code[002705] = *I02705; sub I02705 { $lac &= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[002706] = 01047; $code[002706] = *I02706; sub I02706 { $lac += $core[000047]; goto &fetch; }
$core[002707] = 07040; $code[002707] = *I02707; sub I02707 { $lac ^= 07777; goto &fetch; }
$core[002710] = 07420; $code[002710] = *I02710; sub I02710 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002711] = 07440; $code[002711] = *I02711; sub I02711 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002712] = 07402; $code[002712] = *I02712; sub I02712 { $hlt = 1; goto &fetch; }
$core[002713] = 07360; $code[002713] = *I02713; sub I02713 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002714] = 07206; $code[002714] = *I02714; sub I02714 { $lac &= 010000; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002715] = 01036; $code[002715] = *I02715; sub I02715 { $lac += $core[000036]; goto &fetch; }
$core[002716] = 07040; $code[002716] = *I02716; sub I02716 { $lac ^= 07777; goto &fetch; }
$core[002717] = 07420; $code[002717] = *I02717; sub I02717 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002720] = 07440; $code[002720] = *I02720; sub I02720 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002721] = 07402; $code[002721] = *I02721; sub I02721 { $hlt = 1; goto &fetch; }
$core[002722] = 07320; $code[002722] = *I02722; sub I02722 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002723] = 01026; $code[002723] = *I02723; sub I02723 { $lac += $core[000026]; goto &fetch; }
$core[002724] = 07110; $code[002724] = *I02724; sub I02724 { $lac &= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002725] = 01041; $code[002725] = *I02725; sub I02725 { $lac += $core[000041]; goto &fetch; }
$core[002726] = 07040; $code[002726] = *I02726; sub I02726 { $lac ^= 07777; goto &fetch; }
$core[002727] = 07420; $code[002727] = *I02727; sub I02727 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002730] = 07440; $code[002730] = *I02730; sub I02730 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002731] = 07402; $code[002731] = *I02731; sub I02731 { $hlt = 1; goto &fetch; }
$core[002732] = 07320; $code[002732] = *I02732; sub I02732 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002733] = 01026; $code[002733] = *I02733; sub I02733 { $lac += $core[000026]; goto &fetch; }
$core[002734] = 07104; $code[002734] = *I02734; sub I02734 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002735] = 01043; $code[002735] = *I02735; sub I02735 { $lac += $core[000043]; goto &fetch; }
$core[002736] = 07040; $code[002736] = *I02736; sub I02736 { $lac ^= 07777; goto &fetch; }
$core[002737] = 07420; $code[002737] = *I02737; sub I02737 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002740] = 07440; $code[002740] = *I02740; sub I02740 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002741] = 07402; $code[002741] = *I02741; sub I02741 { $hlt = 1; goto &fetch; }
$core[002742] = 07320; $code[002742] = *I02742; sub I02742 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002743] = 01026; $code[002743] = *I02743; sub I02743 { $lac += $core[000026]; goto &fetch; }
$core[002744] = 07112; $code[002744] = *I02744; sub I02744 { $lac &= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[002745] = 01040; $code[002745] = *I02745; sub I02745 { $lac += $core[000040]; goto &fetch; }
$core[002746] = 07040; $code[002746] = *I02746; sub I02746 { $lac ^= 07777; goto &fetch; }
$core[002747] = 07420; $code[002747] = *I02747; sub I02747 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002750] = 07440; $code[002750] = *I02750; sub I02750 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002751] = 07402; $code[002751] = *I02751; sub I02751 { $hlt = 1; goto &fetch; }
$core[002752] = 07320; $code[002752] = *I02752; sub I02752 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[002753] = 01026; $code[002753] = *I02753; sub I02753 { $lac += $core[000026]; goto &fetch; }
$core[002754] = 07106; $code[002754] = *I02754; sub I02754 { $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[002755] = 01044; $code[002755] = *I02755; sub I02755 { $lac += $core[000044]; goto &fetch; }
$core[002756] = 07040; $code[002756] = *I02756; sub I02756 { $lac ^= 07777; goto &fetch; }
$core[002757] = 07420; $code[002757] = *I02757; sub I02757 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002760] = 07440; $code[002760] = *I02760; sub I02760 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002761] = 07402; $code[002761] = *I02761; sub I02761 { $hlt = 1; goto &fetch; }
$core[002762] = 07360; $code[002762] = *I02762; sub I02762 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002763] = 07310; $code[002763] = *I02763; sub I02763 { $lac &= 010000; $lac &= 07777; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[002764] = 07420; $code[002764] = *I02764; sub I02764 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002765] = 07440; $code[002765] = *I02765; sub I02765 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[002766] = 07402; $code[002766] = *I02766; sub I02766 { $hlt = 1; goto &fetch; }
$core[002767] = 07360; $code[002767] = *I02767; sub I02767 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[002770] = 07304; $code[002770] = *I02770; sub I02770 { $lac &= 010000; $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[002771] = 07420; $code[002771] = *I02771; sub I02771 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[002772] = 07430; $code[002772] = *I02772; sub I02772 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[002773] = 07402; $code[002773] = *I02773; sub I02773 { $hlt = 1; goto &fetch; }
$core[002774] = 07000; $code[002774] = *I02774; sub I02774 { goto &fetch; }
$core[002775] = 07000; $code[002775] = *I02775; sub I02775 { goto &fetch; }
$core[002776] = 07000; $code[002776] = *I02776; sub I02776 { goto &fetch; }
$core[002777] = 07000; $code[002777] = *I02777; sub I02777 { goto &fetch; }
$core[003000] = 07360; $code[003000] = *I03000; sub I03000 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[003001] = 07312; $code[003001] = *I03001; sub I03001 { $lac &= 010000; $lac &= 07777; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003002] = 07420; $code[003002] = *I03002; sub I03002 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003003] = 07440; $code[003003] = *I03003; sub I03003 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003004] = 07402; $code[003004] = *I03004; sub I03004 { $hlt = 1; goto &fetch; }
$core[003005] = 07360; $code[003005] = *I03005; sub I03005 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[003006] = 07306; $code[003006] = *I03006; sub I03006 { $lac &= 010000; $lac &= 07777; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003007] = 07420; $code[003007] = *I03007; sub I03007 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003010] = 07440; $code[003010] = *I03010; sub I03010 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003011] = 07402; $code[003011] = *I03011; sub I03011 { $hlt = 1; goto &fetch; }
$core[003012] = 07300; $code[003012] = *I03012; sub I03012 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003013] = 07030; $code[003013] = *I03013; sub I03013 { $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003014] = 01050; $code[003014] = *I03014; sub I03014 { $lac += $core[000050]; goto &fetch; }
$core[003015] = 07040; $code[003015] = *I03015; sub I03015 { $lac ^= 07777; goto &fetch; }
$core[003016] = 07420; $code[003016] = *I03016; sub I03016 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003017] = 07440; $code[003017] = *I03017; sub I03017 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003020] = 07402; $code[003020] = *I03020; sub I03020 { $hlt = 1; goto &fetch; }
$core[003021] = 07300; $code[003021] = *I03021; sub I03021 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003022] = 07024; $code[003022] = *I03022; sub I03022 { $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003023] = 01035; $code[003023] = *I03023; sub I03023 { $lac += $core[000035]; goto &fetch; }
$core[003024] = 07040; $code[003024] = *I03024; sub I03024 { $lac ^= 07777; goto &fetch; }
$core[003025] = 07420; $code[003025] = *I03025; sub I03025 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003026] = 07440; $code[003026] = *I03026; sub I03026 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003027] = 07402; $code[003027] = *I03027; sub I03027 { $hlt = 1; goto &fetch; }
$core[003030] = 07300; $code[003030] = *I03030; sub I03030 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003031] = 07032; $code[003031] = *I03031; sub I03031 { $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003032] = 01047; $code[003032] = *I03032; sub I03032 { $lac += $core[000047]; goto &fetch; }
$core[003033] = 07040; $code[003033] = *I03033; sub I03033 { $lac ^= 07777; goto &fetch; }
$core[003034] = 07420; $code[003034] = *I03034; sub I03034 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003035] = 07440; $code[003035] = *I03035; sub I03035 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003036] = 07402; $code[003036] = *I03036; sub I03036 { $hlt = 1; goto &fetch; }
$core[003037] = 07300; $code[003037] = *I03037; sub I03037 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003040] = 07026; $code[003040] = *I03040; sub I03040 { $lac ^= 010000; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003041] = 01036; $code[003041] = *I03041; sub I03041 { $lac += $core[000036]; goto &fetch; }
$core[003042] = 07040; $code[003042] = *I03042; sub I03042 { $lac ^= 07777; goto &fetch; }
$core[003043] = 07420; $code[003043] = *I03043; sub I03043 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003044] = 07440; $code[003044] = *I03044; sub I03044 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003045] = 07402; $code[003045] = *I03045; sub I03045 { $hlt = 1; goto &fetch; }
$core[003046] = 07300; $code[003046] = *I03046; sub I03046 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003047] = 01052; $code[003047] = *I03047; sub I03047 { $lac += $core[000052]; goto &fetch; }
$core[003050] = 07230; $code[003050] = *I03050; sub I03050 { $lac &= 010000; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003051] = 01050; $code[003051] = *I03051; sub I03051 { $lac += $core[000050]; goto &fetch; }
$core[003052] = 07040; $code[003052] = *I03052; sub I03052 { $lac ^= 07777; goto &fetch; }
$core[003053] = 07420; $code[003053] = *I03053; sub I03053 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003054] = 07440; $code[003054] = *I03054; sub I03054 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003055] = 07402; $code[003055] = *I03055; sub I03055 { $hlt = 1; goto &fetch; }
$core[003056] = 07300; $code[003056] = *I03056; sub I03056 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003057] = 01052; $code[003057] = *I03057; sub I03057 { $lac += $core[000052]; goto &fetch; }
$core[003060] = 07224; $code[003060] = *I03060; sub I03060 { $lac &= 010000; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003061] = 01035; $code[003061] = *I03061; sub I03061 { $lac += $core[000035]; goto &fetch; }
$core[003062] = 07040; $code[003062] = *I03062; sub I03062 { $lac ^= 07777; goto &fetch; }
$core[003063] = 07420; $code[003063] = *I03063; sub I03063 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003064] = 07440; $code[003064] = *I03064; sub I03064 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003065] = 07402; $code[003065] = *I03065; sub I03065 { $hlt = 1; goto &fetch; }
$core[003066] = 07300; $code[003066] = *I03066; sub I03066 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003067] = 01052; $code[003067] = *I03067; sub I03067 { $lac += $core[000052]; goto &fetch; }
$core[003070] = 07232; $code[003070] = *I03070; sub I03070 { $lac &= 010000; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003071] = 01047; $code[003071] = *I03071; sub I03071 { $lac += $core[000047]; goto &fetch; }
$core[003072] = 07040; $code[003072] = *I03072; sub I03072 { $lac ^= 07777; goto &fetch; }
$core[003073] = 07420; $code[003073] = *I03073; sub I03073 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003074] = 07440; $code[003074] = *I03074; sub I03074 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003075] = 07402; $code[003075] = *I03075; sub I03075 { $hlt = 1; goto &fetch; }
$core[003076] = 07300; $code[003076] = *I03076; sub I03076 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003077] = 01052; $code[003077] = *I03077; sub I03077 { $lac += $core[000052]; goto &fetch; }
$core[003100] = 07226; $code[003100] = *I03100; sub I03100 { $lac &= 010000; $lac ^= 010000; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003101] = 01036; $code[003101] = *I03101; sub I03101 { $lac += $core[000036]; goto &fetch; }
$core[003102] = 07040; $code[003102] = *I03102; sub I03102 { $lac ^= 07777; goto &fetch; }
$core[003103] = 07420; $code[003103] = *I03103; sub I03103 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003104] = 07440; $code[003104] = *I03104; sub I03104 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003105] = 07402; $code[003105] = *I03105; sub I03105 { $hlt = 1; goto &fetch; }
$core[003106] = 07300; $code[003106] = *I03106; sub I03106 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003107] = 07130; $code[003107] = *I03107; sub I03107 { $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003110] = 07004; $code[003110] = *I03110; sub I03110 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003111] = 07430; $code[003111] = *I03111; sub I03111 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003112] = 07440; $code[003112] = *I03112; sub I03112 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003113] = 07402; $code[003113] = *I03113; sub I03113 { $hlt = 1; goto &fetch; }
$core[003114] = 07320; $code[003114] = *I03114; sub I03114 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003115] = 07130; $code[003115] = *I03115; sub I03115 { $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003116] = 07004; $code[003116] = *I03116; sub I03116 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003117] = 07430; $code[003117] = *I03117; sub I03117 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003120] = 07440; $code[003120] = *I03120; sub I03120 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003121] = 07402; $code[003121] = *I03121; sub I03121 { $hlt = 1; goto &fetch; }
$core[003122] = 07300; $code[003122] = *I03122; sub I03122 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003123] = 07124; $code[003123] = *I03123; sub I03123 { $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003124] = 07010; $code[003124] = *I03124; sub I03124 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003125] = 07430; $code[003125] = *I03125; sub I03125 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003126] = 07440; $code[003126] = *I03126; sub I03126 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003127] = 07402; $code[003127] = *I03127; sub I03127 { $hlt = 1; goto &fetch; }
$core[003130] = 07320; $code[003130] = *I03130; sub I03130 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003131] = 07124; $code[003131] = *I03131; sub I03131 { $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003132] = 07010; $code[003132] = *I03132; sub I03132 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003133] = 07430; $code[003133] = *I03133; sub I03133 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003134] = 07440; $code[003134] = *I03134; sub I03134 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003135] = 07402; $code[003135] = *I03135; sub I03135 { $hlt = 1; goto &fetch; }
$core[003136] = 07300; $code[003136] = *I03136; sub I03136 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003137] = 07132; $code[003137] = *I03137; sub I03137 { $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003140] = 07006; $code[003140] = *I03140; sub I03140 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003141] = 07430; $code[003141] = *I03141; sub I03141 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003142] = 07440; $code[003142] = *I03142; sub I03142 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003143] = 07402; $code[003143] = *I03143; sub I03143 { $hlt = 1; goto &fetch; }
$core[003144] = 07320; $code[003144] = *I03144; sub I03144 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003145] = 07132; $code[003145] = *I03145; sub I03145 { $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003146] = 07006; $code[003146] = *I03146; sub I03146 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003147] = 07430; $code[003147] = *I03147; sub I03147 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003150] = 07440; $code[003150] = *I03150; sub I03150 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003151] = 07402; $code[003151] = *I03151; sub I03151 { $hlt = 1; goto &fetch; }
$core[003152] = 07300; $code[003152] = *I03152; sub I03152 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003153] = 07126; $code[003153] = *I03153; sub I03153 { $lac &= 07777; $lac ^= 010000; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003154] = 07012; $code[003154] = *I03154; sub I03154 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003155] = 07430; $code[003155] = *I03155; sub I03155 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003156] = 07440; $code[003156] = *I03156; sub I03156 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003157] = 07402; $code[003157] = *I03157; sub I03157 { $hlt = 1; goto &fetch; }
$core[003160] = 07320; $code[003160] = *I03160; sub I03160 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003161] = 07126; $code[003161] = *I03161; sub I03161 { $lac &= 07777; $lac ^= 010000; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003162] = 07012; $code[003162] = *I03162; sub I03162 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003163] = 07430; $code[003163] = *I03163; sub I03163 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003164] = 07440; $code[003164] = *I03164; sub I03164 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003165] = 07402; $code[003165] = *I03165; sub I03165 { $hlt = 1; goto &fetch; }
$core[003166] = 07300; $code[003166] = *I03166; sub I03166 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003167] = 01052; $code[003167] = *I03167; sub I03167 { $lac += $core[000052]; goto &fetch; }
$core[003170] = 07330; $code[003170] = *I03170; sub I03170 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003171] = 07004; $code[003171] = *I03171; sub I03171 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003172] = 07430; $code[003172] = *I03172; sub I03172 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003173] = 07440; $code[003173] = *I03173; sub I03173 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003174] = 07402; $code[003174] = *I03174; sub I03174 { $hlt = 1; goto &fetch; }
$core[003175] = 07000; $code[003175] = *I03175; sub I03175 { goto &fetch; }
$core[003176] = 07000; $code[003176] = *I03176; sub I03176 { goto &fetch; }
$core[003177] = 07000; $code[003177] = *I03177; sub I03177 { goto &fetch; }
$core[003200] = 07320; $code[003200] = *I03200; sub I03200 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003201] = 01053; $code[003201] = *I03201; sub I03201 { $lac += $core[000053]; goto &fetch; }
$core[003202] = 07330; $code[003202] = *I03202; sub I03202 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003203] = 07004; $code[003203] = *I03203; sub I03203 { $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003204] = 07430; $code[003204] = *I03204; sub I03204 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003205] = 07440; $code[003205] = *I03205; sub I03205 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003206] = 07402; $code[003206] = *I03206; sub I03206 { $hlt = 1; goto &fetch; }
$core[003207] = 07300; $code[003207] = *I03207; sub I03207 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003210] = 01053; $code[003210] = *I03210; sub I03210 { $lac += $core[000053]; goto &fetch; }
$core[003211] = 07324; $code[003211] = *I03211; sub I03211 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003212] = 07010; $code[003212] = *I03212; sub I03212 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003213] = 07430; $code[003213] = *I03213; sub I03213 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003214] = 07440; $code[003214] = *I03214; sub I03214 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003215] = 07402; $code[003215] = *I03215; sub I03215 { $hlt = 1; goto &fetch; }
$core[003216] = 07320; $code[003216] = *I03216; sub I03216 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003217] = 01052; $code[003217] = *I03217; sub I03217 { $lac += $core[000052]; goto &fetch; }
$core[003220] = 07324; $code[003220] = *I03220; sub I03220 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003221] = 07010; $code[003221] = *I03221; sub I03221 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003222] = 07430; $code[003222] = *I03222; sub I03222 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003223] = 07440; $code[003223] = *I03223; sub I03223 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003224] = 07402; $code[003224] = *I03224; sub I03224 { $hlt = 1; goto &fetch; }
$core[003225] = 07300; $code[003225] = *I03225; sub I03225 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003226] = 01053; $code[003226] = *I03226; sub I03226 { $lac += $core[000053]; goto &fetch; }
$core[003227] = 07332; $code[003227] = *I03227; sub I03227 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003230] = 07006; $code[003230] = *I03230; sub I03230 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003231] = 07430; $code[003231] = *I03231; sub I03231 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003232] = 07440; $code[003232] = *I03232; sub I03232 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003233] = 07402; $code[003233] = *I03233; sub I03233 { $hlt = 1; goto &fetch; }
$core[003234] = 07320; $code[003234] = *I03234; sub I03234 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003235] = 01052; $code[003235] = *I03235; sub I03235 { $lac += $core[000052]; goto &fetch; }
$core[003236] = 07332; $code[003236] = *I03236; sub I03236 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003237] = 07006; $code[003237] = *I03237; sub I03237 { $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003240] = 07430; $code[003240] = *I03240; sub I03240 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003241] = 07440; $code[003241] = *I03241; sub I03241 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003242] = 07402; $code[003242] = *I03242; sub I03242 { $hlt = 1; goto &fetch; }
$core[003243] = 07300; $code[003243] = *I03243; sub I03243 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003244] = 01053; $code[003244] = *I03244; sub I03244 { $lac += $core[000053]; goto &fetch; }
$core[003245] = 07326; $code[003245] = *I03245; sub I03245 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003246] = 07012; $code[003246] = *I03246; sub I03246 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003247] = 07430; $code[003247] = *I03247; sub I03247 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003250] = 07440; $code[003250] = *I03250; sub I03250 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003251] = 07402; $code[003251] = *I03251; sub I03251 { $hlt = 1; goto &fetch; }
$core[003252] = 07320; $code[003252] = *I03252; sub I03252 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003253] = 01052; $code[003253] = *I03253; sub I03253 { $lac += $core[000052]; goto &fetch; }
$core[003254] = 07326; $code[003254] = *I03254; sub I03254 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003255] = 07012; $code[003255] = *I03255; sub I03255 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003256] = 07430; $code[003256] = *I03256; sub I03256 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003257] = 07440; $code[003257] = *I03257; sub I03257 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003260] = 07402; $code[003260] = *I03260; sub I03260 { $hlt = 1; goto &fetch; }
$core[003261] = 07300; $code[003261] = *I03261; sub I03261 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003262] = 01051; $code[003262] = *I03262; sub I03262 { $lac += $core[000051]; goto &fetch; }
$core[003263] = 07041; $code[003263] = *I03263; sub I03263 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003264] = 01035; $code[003264] = *I03264; sub I03264 { $lac += $core[000035]; goto &fetch; }
$core[003265] = 07040; $code[003265] = *I03265; sub I03265 { $lac ^= 07777; goto &fetch; }
$core[003266] = 07420; $code[003266] = *I03266; sub I03266 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003267] = 07440; $code[003267] = *I03267; sub I03267 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003270] = 07402; $code[003270] = *I03270; sub I03270 { $hlt = 1; goto &fetch; }
$core[003271] = 07300; $code[003271] = *I03271; sub I03271 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003272] = 01035; $code[003272] = *I03272; sub I03272 { $lac += $core[000035]; goto &fetch; }
$core[003273] = 07041; $code[003273] = *I03273; sub I03273 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003274] = 01036; $code[003274] = *I03274; sub I03274 { $lac += $core[000036]; goto &fetch; }
$core[003275] = 07040; $code[003275] = *I03275; sub I03275 { $lac ^= 07777; goto &fetch; }
$core[003276] = 07420; $code[003276] = *I03276; sub I03276 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003277] = 07440; $code[003277] = *I03277; sub I03277 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003300] = 07402; $code[003300] = *I03300; sub I03300 { $hlt = 1; goto &fetch; }
$core[003301] = 07300; $code[003301] = *I03301; sub I03301 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003302] = 01063; $code[003302] = *I03302; sub I03302 { $lac += $core[000063]; goto &fetch; }
$core[003303] = 07041; $code[003303] = *I03303; sub I03303 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003304] = 01037; $code[003304] = *I03304; sub I03304 { $lac += $core[000037]; goto &fetch; }
$core[003305] = 07040; $code[003305] = *I03305; sub I03305 { $lac ^= 07777; goto &fetch; }
$core[003306] = 07420; $code[003306] = *I03306; sub I03306 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003307] = 07440; $code[003307] = *I03307; sub I03307 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003310] = 07402; $code[003310] = *I03310; sub I03310 { $hlt = 1; goto &fetch; }
$core[003311] = 07300; $code[003311] = *I03311; sub I03311 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003312] = 01062; $code[003312] = *I03312; sub I03312 { $lac += $core[000062]; goto &fetch; }
$core[003313] = 07041; $code[003313] = *I03313; sub I03313 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003314] = 01040; $code[003314] = *I03314; sub I03314 { $lac += $core[000040]; goto &fetch; }
$core[003315] = 07040; $code[003315] = *I03315; sub I03315 { $lac ^= 07777; goto &fetch; }
$core[003316] = 07420; $code[003316] = *I03316; sub I03316 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003317] = 07440; $code[003317] = *I03317; sub I03317 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003320] = 07402; $code[003320] = *I03320; sub I03320 { $hlt = 1; goto &fetch; }
$core[003321] = 07300; $code[003321] = *I03321; sub I03321 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003322] = 01061; $code[003322] = *I03322; sub I03322 { $lac += $core[000061]; goto &fetch; }
$core[003323] = 07041; $code[003323] = *I03323; sub I03323 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003324] = 01041; $code[003324] = *I03324; sub I03324 { $lac += $core[000041]; goto &fetch; }
$core[003325] = 07040; $code[003325] = *I03325; sub I03325 { $lac ^= 07777; goto &fetch; }
$core[003326] = 07420; $code[003326] = *I03326; sub I03326 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003327] = 07440; $code[003327] = *I03327; sub I03327 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003330] = 07402; $code[003330] = *I03330; sub I03330 { $hlt = 1; goto &fetch; }
$core[003331] = 07300; $code[003331] = *I03331; sub I03331 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003332] = 01060; $code[003332] = *I03332; sub I03332 { $lac += $core[000060]; goto &fetch; }
$core[003333] = 07041; $code[003333] = *I03333; sub I03333 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003334] = 01042; $code[003334] = *I03334; sub I03334 { $lac += $core[000042]; goto &fetch; }
$core[003335] = 07040; $code[003335] = *I03335; sub I03335 { $lac ^= 07777; goto &fetch; }
$core[003336] = 07420; $code[003336] = *I03336; sub I03336 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003337] = 07440; $code[003337] = *I03337; sub I03337 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003340] = 07402; $code[003340] = *I03340; sub I03340 { $hlt = 1; goto &fetch; }
$core[003341] = 07300; $code[003341] = *I03341; sub I03341 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003342] = 01076; $code[003342] = *I03342; sub I03342 { $lac += $core[000076]; goto &fetch; }
$core[003343] = 07041; $code[003343] = *I03343; sub I03343 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003344] = 01043; $code[003344] = *I03344; sub I03344 { $lac += $core[000043]; goto &fetch; }
$core[003345] = 07040; $code[003345] = *I03345; sub I03345 { $lac ^= 07777; goto &fetch; }
$core[003346] = 07420; $code[003346] = *I03346; sub I03346 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003347] = 07440; $code[003347] = *I03347; sub I03347 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003350] = 07402; $code[003350] = *I03350; sub I03350 { $hlt = 1; goto &fetch; }
$core[003351] = 07300; $code[003351] = *I03351; sub I03351 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003352] = 01057; $code[003352] = *I03352; sub I03352 { $lac += $core[000057]; goto &fetch; }
$core[003353] = 07041; $code[003353] = *I03353; sub I03353 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003354] = 01044; $code[003354] = *I03354; sub I03354 { $lac += $core[000044]; goto &fetch; }
$core[003355] = 07040; $code[003355] = *I03355; sub I03355 { $lac ^= 07777; goto &fetch; }
$core[003356] = 07420; $code[003356] = *I03356; sub I03356 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003357] = 07440; $code[003357] = *I03357; sub I03357 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003360] = 07402; $code[003360] = *I03360; sub I03360 { $hlt = 1; goto &fetch; }
$core[003361] = 07300; $code[003361] = *I03361; sub I03361 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003362] = 01056; $code[003362] = *I03362; sub I03362 { $lac += $core[000056]; goto &fetch; }
$core[003363] = 07041; $code[003363] = *I03363; sub I03363 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003364] = 01045; $code[003364] = *I03364; sub I03364 { $lac += $core[000045]; goto &fetch; }
$core[003365] = 07040; $code[003365] = *I03365; sub I03365 { $lac ^= 07777; goto &fetch; }
$core[003366] = 07420; $code[003366] = *I03366; sub I03366 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003367] = 07440; $code[003367] = *I03367; sub I03367 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003370] = 07402; $code[003370] = *I03370; sub I03370 { $hlt = 1; goto &fetch; }
$core[003371] = 07000; $code[003371] = *I03371; sub I03371 { goto &fetch; }
$core[003372] = 07000; $code[003372] = *I03372; sub I03372 { goto &fetch; }
$core[003373] = 07000; $code[003373] = *I03373; sub I03373 { goto &fetch; }
$core[003374] = 07000; $code[003374] = *I03374; sub I03374 { goto &fetch; }
$core[003375] = 07000; $code[003375] = *I03375; sub I03375 { goto &fetch; }
$core[003376] = 07000; $code[003376] = *I03376; sub I03376 { goto &fetch; }
$core[003377] = 07000; $code[003377] = *I03377; sub I03377 { goto &fetch; }
$core[003400] = 07300; $code[003400] = *I03400; sub I03400 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003401] = 01055; $code[003401] = *I03401; sub I03401 { $lac += $core[000055]; goto &fetch; }
$core[003402] = 07041; $code[003402] = *I03402; sub I03402 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003403] = 01046; $code[003403] = *I03403; sub I03403 { $lac += $core[000046]; goto &fetch; }
$core[003404] = 07040; $code[003404] = *I03404; sub I03404 { $lac ^= 07777; goto &fetch; }
$core[003405] = 07420; $code[003405] = *I03405; sub I03405 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003406] = 07440; $code[003406] = *I03406; sub I03406 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003407] = 07402; $code[003407] = *I03407; sub I03407 { $hlt = 1; goto &fetch; }
$core[003410] = 07300; $code[003410] = *I03410; sub I03410 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003411] = 01054; $code[003411] = *I03411; sub I03411 { $lac += $core[000054]; goto &fetch; }
$core[003412] = 07041; $code[003412] = *I03412; sub I03412 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003413] = 01047; $code[003413] = *I03413; sub I03413 { $lac += $core[000047]; goto &fetch; }
$core[003414] = 07040; $code[003414] = *I03414; sub I03414 { $lac ^= 07777; goto &fetch; }
$core[003415] = 07420; $code[003415] = *I03415; sub I03415 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003416] = 07440; $code[003416] = *I03416; sub I03416 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003417] = 07402; $code[003417] = *I03417; sub I03417 { $hlt = 1; goto &fetch; }
$core[003420] = 07300; $code[003420] = *I03420; sub I03420 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003421] = 01034; $code[003421] = *I03421; sub I03421 { $lac += $core[000034]; goto &fetch; }
$core[003422] = 07041; $code[003422] = *I03422; sub I03422 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003423] = 01050; $code[003423] = *I03423; sub I03423 { $lac += $core[000050]; goto &fetch; }
$core[003424] = 07040; $code[003424] = *I03424; sub I03424 { $lac ^= 07777; goto &fetch; }
$core[003425] = 07420; $code[003425] = *I03425; sub I03425 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003426] = 07440; $code[003426] = *I03426; sub I03426 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003427] = 07402; $code[003427] = *I03427; sub I03427 { $hlt = 1; goto &fetch; }
$core[003430] = 07300; $code[003430] = *I03430; sub I03430 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003431] = 01020; $code[003431] = *I03431; sub I03431 { $lac += $core[000020]; goto &fetch; }
$core[003432] = 07041; $code[003432] = *I03432; sub I03432 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003433] = 07450; $code[003433] = *I03433; sub I03433 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003434] = 07420; $code[003434] = *I03434; sub I03434 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003435] = 07402; $code[003435] = *I03435; sub I03435 { $hlt = 1; goto &fetch; }
$core[003436] = 07340; $code[003436] = *I03436; sub I03436 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[003437] = 07311; $code[003437] = *I03437; sub I03437 { $lac &= 010000; $lac &= 07777; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003440] = 07430; $code[003440] = *I03440; sub I03440 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003441] = 07440; $code[003441] = *I03441; sub I03441 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003442] = 07402; $code[003442] = *I03442; sub I03442 { $hlt = 1; goto &fetch; }
$core[003443] = 07360; $code[003443] = *I03443; sub I03443 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[003444] = 07305; $code[003444] = *I03444; sub I03444 { $lac &= 010000; $lac &= 07777; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003445] = 07430; $code[003445] = *I03445; sub I03445 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003446] = 07402; $code[003446] = *I03446; sub I03446 { $hlt = 1; goto &fetch; }
$core[003447] = 07041; $code[003447] = *I03447; sub I03447 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003450] = 01022; $code[003450] = *I03450; sub I03450 { $lac += $core[000022]; goto &fetch; }
$core[003451] = 07440; $code[003451] = *I03451; sub I03451 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003452] = 07402; $code[003452] = *I03452; sub I03452 { $hlt = 1; goto &fetch; }
$core[003453] = 07320; $code[003453] = *I03453; sub I03453 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003454] = 07313; $code[003454] = *I03454; sub I03454 { $lac &= 010000; $lac &= 07777; $lac++; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003455] = 07430; $code[003455] = *I03455; sub I03455 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003456] = 07402; $code[003456] = *I03456; sub I03456 { $hlt = 1; goto &fetch; }
$core[003457] = 07500; $code[003457] = *I03457; sub I03457 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[003460] = 07402; $code[003460] = *I03460; sub I03460 { $hlt = 1; goto &fetch; }
$core[003461] = 07360; $code[003461] = *I03461; sub I03461 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[003462] = 07307; $code[003462] = *I03462; sub I03462 { $lac &= 010000; $lac &= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[003463] = 07430; $code[003463] = *I03463; sub I03463 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003464] = 07402; $code[003464] = *I03464; sub I03464 { $hlt = 1; goto &fetch; }
$core[003465] = 07041; $code[003465] = *I03465; sub I03465 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003466] = 01023; $code[003466] = *I03466; sub I03466 { $lac += $core[000023]; goto &fetch; }
$core[003467] = 07440; $code[003467] = *I03467; sub I03467 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003470] = 07402; $code[003470] = *I03470; sub I03470 { $hlt = 1; goto &fetch; }
$core[003471] = 07300; $code[003471] = *I03471; sub I03471 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003472] = 07331; $code[003472] = *I03472; sub I03472 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac++; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[003473] = 07520; $code[003473] = *I03473; sub I03473 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003474] = 07402; $code[003474] = *I03474; sub I03474 { $hlt = 1; goto &fetch; }
$core[003475] = 07300; $code[003475] = *I03475; sub I03475 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003476] = 07345; $code[003476] = *I03476; sub I03476 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[003477] = 07430; $code[003477] = *I03477; sub I03477 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003500] = 07402; $code[003500] = *I03500; sub I03500 { $hlt = 1; goto &fetch; }
$core[003501] = 07041; $code[003501] = *I03501; sub I03501 { $lac ^= 07777; $lac++; goto &fetch; }
$core[003502] = 01021; $code[003502] = *I03502; sub I03502 { $lac += $core[000021]; goto &fetch; }
$core[003503] = 07440; $code[003503] = *I03503; sub I03503 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003504] = 07402; $code[003504] = *I03504; sub I03504 { $hlt = 1; goto &fetch; }
$core[003505] = 07360; $code[003505] = *I03505; sub I03505 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[003506] = 07373; $code[003506] = *I03506; sub I03506 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[003507] = 07440; $code[003507] = *I03507; sub I03507 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003510] = 07402; $code[003510] = *I03510; sub I03510 { $hlt = 1; goto &fetch; }
$core[003511] = 07430; $code[003511] = *I03511; sub I03511 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003512] = 07402; $code[003512] = *I03512; sub I03512 { $hlt = 1; goto &fetch; }
$core[003513] = 07240; $code[003513] = *I03513; sub I03513 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003514] = 07700; $code[003514] = *I03514; sub I03514 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003515] = 07402; $code[003515] = *I03515; sub I03515 { $hlt = 1; goto &fetch; }
$core[003516] = 07440; $code[003516] = *I03516; sub I03516 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003517] = 07402; $code[003517] = *I03517; sub I03517 { $hlt = 1; goto &fetch; }
$core[003520] = 07240; $code[003520] = *I03520; sub I03520 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003521] = 07640; $code[003521] = *I03521; sub I03521 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003522] = 07440; $code[003522] = *I03522; sub I03522 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003523] = 07402; $code[003523] = *I03523; sub I03523 { $hlt = 1; goto &fetch; }
$core[003524] = 07240; $code[003524] = *I03524; sub I03524 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003525] = 07540; $code[003525] = *I03525; sub I03525 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[003526] = 07402; $code[003526] = *I03526; sub I03526 { $hlt = 1; goto &fetch; }
$core[003527] = 07200; $code[003527] = *I03527; sub I03527 { $lac &= 010000; goto &fetch; }
$core[003530] = 07540; $code[003530] = *I03530; sub I03530 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[003531] = 07402; $code[003531] = *I03531; sub I03531 { $hlt = 1; goto &fetch; }
$core[003532] = 07200; $code[003532] = *I03532; sub I03532 { $lac &= 010000; goto &fetch; }
$core[003533] = 01050; $code[003533] = *I03533; sub I03533 { $lac += $core[000050]; goto &fetch; }
$core[003534] = 07540; $code[003534] = *I03534; sub I03534 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[003535] = 07450; $code[003535] = *I03535; sub I03535 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003536] = 07402; $code[003536] = *I03536; sub I03536 { $hlt = 1; goto &fetch; }
$core[003537] = 07240; $code[003537] = *I03537; sub I03537 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[003540] = 07740; $code[003540] = *I03540; sub I03540 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003541] = 07402; $code[003541] = *I03541; sub I03541 { $hlt = 1; goto &fetch; }
$core[003542] = 07440; $code[003542] = *I03542; sub I03542 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003543] = 07402; $code[003543] = *I03543; sub I03543 { $hlt = 1; goto &fetch; }
$core[003544] = 07200; $code[003544] = *I03544; sub I03544 { $lac &= 010000; goto &fetch; }
$core[003545] = 07740; $code[003545] = *I03545; sub I03545 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003546] = 07402; $code[003546] = *I03546; sub I03546 { $hlt = 1; goto &fetch; }
$core[003547] = 07440; $code[003547] = *I03547; sub I03547 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003550] = 07402; $code[003550] = *I03550; sub I03550 { $hlt = 1; goto &fetch; }
$core[003551] = 07200; $code[003551] = *I03551; sub I03551 { $lac &= 010000; goto &fetch; }
$core[003552] = 01050; $code[003552] = *I03552; sub I03552 { $lac += $core[000050]; goto &fetch; }
$core[003553] = 07740; $code[003553] = *I03553; sub I03553 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003554] = 07440; $code[003554] = *I03554; sub I03554 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003555] = 07402; $code[003555] = *I03555; sub I03555 { $hlt = 1; goto &fetch; }
$core[003556] = 07300; $code[003556] = *I03556; sub I03556 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003557] = 01052; $code[003557] = *I03557; sub I03557 { $lac += $core[000052]; goto &fetch; }
$core[003560] = 07620; $code[003560] = *I03560; sub I03560 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003561] = 07440; $code[003561] = *I03561; sub I03561 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003562] = 07402; $code[003562] = *I03562; sub I03562 { $hlt = 1; goto &fetch; }
$core[003563] = 07320; $code[003563] = *I03563; sub I03563 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003564] = 01053; $code[003564] = *I03564; sub I03564 { $lac += $core[000053]; goto &fetch; }
$core[003565] = 07620; $code[003565] = *I03565; sub I03565 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003566] = 07402; $code[003566] = *I03566; sub I03566 { $hlt = 1; goto &fetch; }
$core[003567] = 07440; $code[003567] = *I03567; sub I03567 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003570] = 07402; $code[003570] = *I03570; sub I03570 { $hlt = 1; goto &fetch; }
$core[003571] = 07300; $code[003571] = *I03571; sub I03571 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003572] = 07520; $code[003572] = *I03572; sub I03572 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003573] = 07440; $code[003573] = *I03573; sub I03573 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003574] = 07402; $code[003574] = *I03574; sub I03574 { $hlt = 1; goto &fetch; }
$core[003575] = 07320; $code[003575] = *I03575; sub I03575 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003576] = 07520; $code[003576] = *I03576; sub I03576 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003577] = 07402; $code[003577] = *I03577; sub I03577 { $hlt = 1; goto &fetch; }
$core[003600] = 07300; $code[003600] = *I03600; sub I03600 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003601] = 01034; $code[003601] = *I03601; sub I03601 { $lac += $core[000034]; goto &fetch; }
$core[003602] = 07520; $code[003602] = *I03602; sub I03602 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003603] = 07402; $code[003603] = *I03603; sub I03603 { $hlt = 1; goto &fetch; }
$core[003604] = 07320; $code[003604] = *I03604; sub I03604 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003605] = 01034; $code[003605] = *I03605; sub I03605 { $lac += $core[000034]; goto &fetch; }
$core[003606] = 07520; $code[003606] = *I03606; sub I03606 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003607] = 07402; $code[003607] = *I03607; sub I03607 { $hlt = 1; goto &fetch; }
$core[003610] = 07300; $code[003610] = *I03610; sub I03610 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003611] = 07720; $code[003611] = *I03611; sub I03611 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003612] = 07440; $code[003612] = *I03612; sub I03612 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003613] = 07402; $code[003613] = *I03613; sub I03613 { $hlt = 1; goto &fetch; }
$core[003614] = 07320; $code[003614] = *I03614; sub I03614 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003615] = 07720; $code[003615] = *I03615; sub I03615 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003616] = 07402; $code[003616] = *I03616; sub I03616 { $hlt = 1; goto &fetch; }
$core[003617] = 07440; $code[003617] = *I03617; sub I03617 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003620] = 07402; $code[003620] = *I03620; sub I03620 { $hlt = 1; goto &fetch; }
$core[003621] = 07300; $code[003621] = *I03621; sub I03621 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003622] = 01034; $code[003622] = *I03622; sub I03622 { $lac += $core[000034]; goto &fetch; }
$core[003623] = 07720; $code[003623] = *I03623; sub I03623 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003624] = 07402; $code[003624] = *I03624; sub I03624 { $hlt = 1; goto &fetch; }
$core[003625] = 07440; $code[003625] = *I03625; sub I03625 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003626] = 07402; $code[003626] = *I03626; sub I03626 { $hlt = 1; goto &fetch; }
$core[003627] = 07320; $code[003627] = *I03627; sub I03627 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003630] = 01034; $code[003630] = *I03630; sub I03630 { $lac += $core[000034]; goto &fetch; }
$core[003631] = 07720; $code[003631] = *I03631; sub I03631 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003632] = 07402; $code[003632] = *I03632; sub I03632 { $hlt = 1; goto &fetch; }
$core[003633] = 07440; $code[003633] = *I03633; sub I03633 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003634] = 07402; $code[003634] = *I03634; sub I03634 { $hlt = 1; goto &fetch; }
$core[003635] = 07300; $code[003635] = *I03635; sub I03635 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003636] = 07460; $code[003636] = *I03636; sub I03636 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003637] = 07402; $code[003637] = *I03637; sub I03637 { $hlt = 1; goto &fetch; }
$core[003640] = 07320; $code[003640] = *I03640; sub I03640 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003641] = 07460; $code[003641] = *I03641; sub I03641 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003642] = 07402; $code[003642] = *I03642; sub I03642 { $hlt = 1; goto &fetch; }
$core[003643] = 07300; $code[003643] = *I03643; sub I03643 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003644] = 01031; $code[003644] = *I03644; sub I03644 { $lac += $core[000031]; goto &fetch; }
$core[003645] = 07460; $code[003645] = *I03645; sub I03645 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003646] = 07450; $code[003646] = *I03646; sub I03646 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003647] = 07402; $code[003647] = *I03647; sub I03647 { $hlt = 1; goto &fetch; }
$core[003650] = 07320; $code[003650] = *I03650; sub I03650 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003651] = 01026; $code[003651] = *I03651; sub I03651 { $lac += $core[000026]; goto &fetch; }
$core[003652] = 07460; $code[003652] = *I03652; sub I03652 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003653] = 07402; $code[003653] = *I03653; sub I03653 { $hlt = 1; goto &fetch; }
$core[003654] = 07300; $code[003654] = *I03654; sub I03654 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003655] = 07660; $code[003655] = *I03655; sub I03655 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003656] = 07402; $code[003656] = *I03656; sub I03656 { $hlt = 1; goto &fetch; }
$core[003657] = 07440; $code[003657] = *I03657; sub I03657 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003660] = 07402; $code[003660] = *I03660; sub I03660 { $hlt = 1; goto &fetch; }
$core[003661] = 07320; $code[003661] = *I03661; sub I03661 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003662] = 07660; $code[003662] = *I03662; sub I03662 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003663] = 07402; $code[003663] = *I03663; sub I03663 { $hlt = 1; goto &fetch; }
$core[003664] = 07440; $code[003664] = *I03664; sub I03664 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003665] = 07402; $code[003665] = *I03665; sub I03665 { $hlt = 1; goto &fetch; }
$core[003666] = 07320; $code[003666] = *I03666; sub I03666 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003667] = 01030; $code[003667] = *I03667; sub I03667 { $lac += $core[000030]; goto &fetch; }
$core[003670] = 07660; $code[003670] = *I03670; sub I03670 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003671] = 07402; $code[003671] = *I03671; sub I03671 { $hlt = 1; goto &fetch; }
$core[003672] = 07440; $code[003672] = *I03672; sub I03672 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003673] = 07402; $code[003673] = *I03673; sub I03673 { $hlt = 1; goto &fetch; }
$core[003674] = 07300; $code[003674] = *I03674; sub I03674 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003675] = 01033; $code[003675] = *I03675; sub I03675 { $lac += $core[000033]; goto &fetch; }
$core[003676] = 07660; $code[003676] = *I03676; sub I03676 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003677] = 07440; $code[003677] = *I03677; sub I03677 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003700] = 07402; $code[003700] = *I03700; sub I03700 { $hlt = 1; goto &fetch; }
$core[003701] = 07300; $code[003701] = *I03701; sub I03701 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003702] = 07560; $code[003702] = *I03702; sub I03702 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003703] = 07402; $code[003703] = *I03703; sub I03703 { $hlt = 1; goto &fetch; }
$core[003704] = 07320; $code[003704] = *I03704; sub I03704 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003705] = 01050; $code[003705] = *I03705; sub I03705 { $lac += $core[000050]; goto &fetch; }
$core[003706] = 07560; $code[003706] = *I03706; sub I03706 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003707] = 07402; $code[003707] = *I03707; sub I03707 { $hlt = 1; goto &fetch; }
$core[003710] = 07300; $code[003710] = *I03710; sub I03710 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003711] = 01034; $code[003711] = *I03711; sub I03711 { $lac += $core[000034]; goto &fetch; }
$core[003712] = 07560; $code[003712] = *I03712; sub I03712 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003713] = 07402; $code[003713] = *I03713; sub I03713 { $hlt = 1; goto &fetch; }
$core[003714] = 07300; $code[003714] = *I03714; sub I03714 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003715] = 01050; $code[003715] = *I03715; sub I03715 { $lac += $core[000050]; goto &fetch; }
$core[003716] = 07560; $code[003716] = *I03716; sub I03716 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[003717] = 07450; $code[003717] = *I03717; sub I03717 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003720] = 07402; $code[003720] = *I03720; sub I03720 { $hlt = 1; goto &fetch; }
$core[003721] = 07300; $code[003721] = *I03721; sub I03721 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003722] = 07760; $code[003722] = *I03722; sub I03722 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003723] = 07402; $code[003723] = *I03723; sub I03723 { $hlt = 1; goto &fetch; }
$core[003724] = 07440; $code[003724] = *I03724; sub I03724 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003725] = 07402; $code[003725] = *I03725; sub I03725 { $hlt = 1; goto &fetch; }
$core[003726] = 07320; $code[003726] = *I03726; sub I03726 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003727] = 01050; $code[003727] = *I03727; sub I03727 { $lac += $core[000050]; goto &fetch; }
$core[003730] = 07760; $code[003730] = *I03730; sub I03730 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003731] = 07402; $code[003731] = *I03731; sub I03731 { $hlt = 1; goto &fetch; }
$core[003732] = 07440; $code[003732] = *I03732; sub I03732 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003733] = 07402; $code[003733] = *I03733; sub I03733 { $hlt = 1; goto &fetch; }
$core[003734] = 07300; $code[003734] = *I03734; sub I03734 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003735] = 01034; $code[003735] = *I03735; sub I03735 { $lac += $core[000034]; goto &fetch; }
$core[003736] = 07760; $code[003736] = *I03736; sub I03736 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003737] = 07402; $code[003737] = *I03737; sub I03737 { $hlt = 1; goto &fetch; }
$core[003740] = 07440; $code[003740] = *I03740; sub I03740 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003741] = 07402; $code[003741] = *I03741; sub I03741 { $hlt = 1; goto &fetch; }
$core[003742] = 07300; $code[003742] = *I03742; sub I03742 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003743] = 01050; $code[003743] = *I03743; sub I03743 { $lac += $core[000050]; goto &fetch; }
$core[003744] = 07760; $code[003744] = *I03744; sub I03744 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003745] = 07440; $code[003745] = *I03745; sub I03745 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003746] = 07402; $code[003746] = *I03746; sub I03746 { $hlt = 1; goto &fetch; }
$core[003747] = 07300; $code[003747] = *I03747; sub I03747 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003750] = 07410; $code[003750] = *I03750; sub I03750 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003751] = 07402; $code[003751] = *I03751; sub I03751 { $hlt = 1; goto &fetch; }
$core[003752] = 07320; $code[003752] = *I03752; sub I03752 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003753] = 07410; $code[003753] = *I03753; sub I03753 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003754] = 07402; $code[003754] = *I03754; sub I03754 { $hlt = 1; goto &fetch; }
$core[003755] = 07320; $code[003755] = *I03755; sub I03755 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[003756] = 01050; $code[003756] = *I03756; sub I03756 { $lac += $core[000050]; goto &fetch; }
$core[003757] = 07410; $code[003757] = *I03757; sub I03757 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003760] = 07402; $code[003760] = *I03760; sub I03760 { $hlt = 1; goto &fetch; }
$core[003761] = 07300; $code[003761] = *I03761; sub I03761 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[003762] = 01050; $code[003762] = *I03762; sub I03762 { $lac += $core[000050]; goto &fetch; }
$core[003763] = 07410; $code[003763] = *I03763; sub I03763 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[003764] = 07402; $code[003764] = *I03764; sub I03764 { $hlt = 1; goto &fetch; }
$core[003765] = 07200; $code[003765] = *I03765; sub I03765 { $lac &= 010000; goto &fetch; }
$core[003766] = 01050; $code[003766] = *I03766; sub I03766 { $lac += $core[000050]; goto &fetch; }
$core[003767] = 07710; $code[003767] = *I03767; sub I03767 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003770] = 07402; $code[003770] = *I03770; sub I03770 { $hlt = 1; goto &fetch; }
$core[003771] = 07440; $code[003771] = *I03771; sub I03771 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003772] = 07402; $code[003772] = *I03772; sub I03772 { $hlt = 1; goto &fetch; }
$core[003773] = 07200; $code[003773] = *I03773; sub I03773 { $lac &= 010000; goto &fetch; }
$core[003774] = 01034; $code[003774] = *I03774; sub I03774 { $lac += $core[000034]; goto &fetch; }
$core[003775] = 07710; $code[003775] = *I03775; sub I03775 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[003776] = 07440; $code[003776] = *I03776; sub I03776 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[003777] = 07402; $code[003777] = *I03777; sub I03777 { $hlt = 1; goto &fetch; }
$core[004000] = 07240; $code[004000] = *I04000; sub I04000 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004001] = 07650; $code[004001] = *I04001; sub I04001 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004002] = 07402; $code[004002] = *I04002; sub I04002 { $hlt = 1; goto &fetch; }
$core[004003] = 07200; $code[004003] = *I04003; sub I04003 { $lac &= 010000; goto &fetch; }
$core[004004] = 07650; $code[004004] = *I04004; sub I04004 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004005] = 07440; $code[004005] = *I04005; sub I04005 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004006] = 07402; $code[004006] = *I04006; sub I04006 { $hlt = 1; goto &fetch; }
$core[004007] = 07200; $code[004007] = *I04007; sub I04007 { $lac &= 010000; goto &fetch; }
$core[004010] = 07550; $code[004010] = *I04010; sub I04010 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004011] = 07440; $code[004011] = *I04011; sub I04011 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004012] = 07402; $code[004012] = *I04012; sub I04012 { $hlt = 1; goto &fetch; }
$core[004013] = 07200; $code[004013] = *I04013; sub I04013 { $lac &= 010000; goto &fetch; }
$core[004014] = 01050; $code[004014] = *I04014; sub I04014 { $lac += $core[000050]; goto &fetch; }
$core[004015] = 07550; $code[004015] = *I04015; sub I04015 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004016] = 07402; $code[004016] = *I04016; sub I04016 { $hlt = 1; goto &fetch; }
$core[004017] = 07200; $code[004017] = *I04017; sub I04017 { $lac &= 010000; goto &fetch; }
$core[004020] = 01034; $code[004020] = *I04020; sub I04020 { $lac += $core[000034]; goto &fetch; }
$core[004021] = 07550; $code[004021] = *I04021; sub I04021 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004022] = 07450; $code[004022] = *I04022; sub I04022 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004023] = 07402; $code[004023] = *I04023; sub I04023 { $hlt = 1; goto &fetch; }
$core[004024] = 07200; $code[004024] = *I04024; sub I04024 { $lac &= 010000; goto &fetch; }
$core[004025] = 07750; $code[004025] = *I04025; sub I04025 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004026] = 07440; $code[004026] = *I04026; sub I04026 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004027] = 07402; $code[004027] = *I04027; sub I04027 { $hlt = 1; goto &fetch; }
$core[004030] = 07200; $code[004030] = *I04030; sub I04030 { $lac &= 010000; goto &fetch; }
$core[004031] = 01050; $code[004031] = *I04031; sub I04031 { $lac += $core[000050]; goto &fetch; }
$core[004032] = 07750; $code[004032] = *I04032; sub I04032 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004033] = 07402; $code[004033] = *I04033; sub I04033 { $hlt = 1; goto &fetch; }
$core[004034] = 07440; $code[004034] = *I04034; sub I04034 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004035] = 07402; $code[004035] = *I04035; sub I04035 { $hlt = 1; goto &fetch; }
$core[004036] = 07200; $code[004036] = *I04036; sub I04036 { $lac &= 010000; goto &fetch; }
$core[004037] = 01034; $code[004037] = *I04037; sub I04037 { $lac += $core[000034]; goto &fetch; }
$core[004040] = 07750; $code[004040] = *I04040; sub I04040 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004041] = 07440; $code[004041] = *I04041; sub I04041 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004042] = 07402; $code[004042] = *I04042; sub I04042 { $hlt = 1; goto &fetch; }
$core[004043] = 07300; $code[004043] = *I04043; sub I04043 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004044] = 01052; $code[004044] = *I04044; sub I04044 { $lac += $core[000052]; goto &fetch; }
$core[004045] = 07630; $code[004045] = *I04045; sub I04045 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004046] = 07402; $code[004046] = *I04046; sub I04046 { $hlt = 1; goto &fetch; }
$core[004047] = 07440; $code[004047] = *I04047; sub I04047 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004050] = 07402; $code[004050] = *I04050; sub I04050 { $hlt = 1; goto &fetch; }
$core[004051] = 07360; $code[004051] = *I04051; sub I04051 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[004052] = 07630; $code[004052] = *I04052; sub I04052 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004053] = 07440; $code[004053] = *I04053; sub I04053 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004054] = 07402; $code[004054] = *I04054; sub I04054 { $hlt = 1; goto &fetch; }
$core[004055] = 07300; $code[004055] = *I04055; sub I04055 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004056] = 01050; $code[004056] = *I04056; sub I04056 { $lac += $core[000050]; goto &fetch; }
$core[004057] = 07530; $code[004057] = *I04057; sub I04057 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004060] = 07402; $code[004060] = *I04060; sub I04060 { $hlt = 1; goto &fetch; }
$core[004061] = 07320; $code[004061] = *I04061; sub I04061 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[004062] = 01050; $code[004062] = *I04062; sub I04062 { $lac += $core[000050]; goto &fetch; }
$core[004063] = 07530; $code[004063] = *I04063; sub I04063 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004064] = 07450; $code[004064] = *I04064; sub I04064 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004065] = 07402; $code[004065] = *I04065; sub I04065 { $hlt = 1; goto &fetch; }
$core[004066] = 07300; $code[004066] = *I04066; sub I04066 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004067] = 01034; $code[004067] = *I04067; sub I04067 { $lac += $core[000034]; goto &fetch; }
$core[004070] = 07530; $code[004070] = *I04070; sub I04070 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004071] = 07500; $code[004071] = *I04071; sub I04071 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[004072] = 07402; $code[004072] = *I04072; sub I04072 { $hlt = 1; goto &fetch; }
$core[004073] = 07300; $code[004073] = *I04073; sub I04073 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004074] = 01050; $code[004074] = *I04074; sub I04074 { $lac += $core[000050]; goto &fetch; }
$core[004075] = 07730; $code[004075] = *I04075; sub I04075 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004076] = 07402; $code[004076] = *I04076; sub I04076 { $hlt = 1; goto &fetch; }
$core[004077] = 07440; $code[004077] = *I04077; sub I04077 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004100] = 07402; $code[004100] = *I04100; sub I04100 { $hlt = 1; goto &fetch; }
$core[004101] = 07320; $code[004101] = *I04101; sub I04101 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[004102] = 01050; $code[004102] = *I04102; sub I04102 { $lac += $core[000050]; goto &fetch; }
$core[004103] = 07730; $code[004103] = *I04103; sub I04103 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004104] = 07440; $code[004104] = *I04104; sub I04104 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004105] = 07402; $code[004105] = *I04105; sub I04105 { $hlt = 1; goto &fetch; }
$core[004106] = 07300; $code[004106] = *I04106; sub I04106 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004107] = 01034; $code[004107] = *I04107; sub I04107 { $lac += $core[000034]; goto &fetch; }
$core[004110] = 07730; $code[004110] = *I04110; sub I04110 { $skp = 0; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004111] = 07440; $code[004111] = *I04111; sub I04111 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004112] = 07402; $code[004112] = *I04112; sub I04112 { $hlt = 1; goto &fetch; }
$core[004113] = 07300; $code[004113] = *I04113; sub I04113 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004114] = 01034; $code[004114] = *I04114; sub I04114 { $lac += $core[000034]; goto &fetch; }
$core[004115] = 07470; $code[004115] = *I04115; sub I04115 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004116] = 07402; $code[004116] = *I04116; sub I04116 { $hlt = 1; goto &fetch; }
$core[004117] = 07320; $code[004117] = *I04117; sub I04117 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[004120] = 01034; $code[004120] = *I04120; sub I04120 { $lac += $core[000034]; goto &fetch; }
$core[004121] = 07470; $code[004121] = *I04121; sub I04121 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004122] = 07420; $code[004122] = *I04122; sub I04122 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[004123] = 07402; $code[004123] = *I04123; sub I04123 { $hlt = 1; goto &fetch; }
$core[004124] = 07300; $code[004124] = *I04124; sub I04124 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004125] = 07470; $code[004125] = *I04125; sub I04125 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004126] = 07430; $code[004126] = *I04126; sub I04126 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004127] = 07402; $code[004127] = *I04127; sub I04127 { $hlt = 1; goto &fetch; }
$core[004130] = 07320; $code[004130] = *I04130; sub I04130 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[004131] = 01034; $code[004131] = *I04131; sub I04131 { $lac += $core[000034]; goto &fetch; }
$core[004132] = 07670; $code[004132] = *I04132; sub I04132 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004133] = 07440; $code[004133] = *I04133; sub I04133 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004134] = 07402; $code[004134] = *I04134; sub I04134 { $hlt = 1; goto &fetch; }
$core[004135] = 07300; $code[004135] = *I04135; sub I04135 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004136] = 01034; $code[004136] = *I04136; sub I04136 { $lac += $core[000034]; goto &fetch; }
$core[004137] = 07670; $code[004137] = *I04137; sub I04137 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004140] = 07402; $code[004140] = *I04140; sub I04140 { $hlt = 1; goto &fetch; }
$core[004141] = 07440; $code[004141] = *I04141; sub I04141 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004142] = 07402; $code[004142] = *I04142; sub I04142 { $hlt = 1; goto &fetch; }
$core[004143] = 07300; $code[004143] = *I04143; sub I04143 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004144] = 07670; $code[004144] = *I04144; sub I04144 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004145] = 07440; $code[004145] = *I04145; sub I04145 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004146] = 07402; $code[004146] = *I04146; sub I04146 { $hlt = 1; goto &fetch; }
$core[004147] = 07300; $code[004147] = *I04147; sub I04147 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004150] = 01050; $code[004150] = *I04150; sub I04150 { $lac += $core[000050]; goto &fetch; }
$core[004151] = 07570; $code[004151] = *I04151; sub I04151 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004152] = 07402; $code[004152] = *I04152; sub I04152 { $hlt = 1; goto &fetch; }
$core[004153] = 07320; $code[004153] = *I04153; sub I04153 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[004154] = 01050; $code[004154] = *I04154; sub I04154 { $lac += $core[000050]; goto &fetch; }
$core[004155] = 07570; $code[004155] = *I04155; sub I04155 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004156] = 07420; $code[004156] = *I04156; sub I04156 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[004157] = 07402; $code[004157] = *I04157; sub I04157 { $hlt = 1; goto &fetch; }
$core[004160] = 07300; $code[004160] = *I04160; sub I04160 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004161] = 07570; $code[004161] = *I04161; sub I04161 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004162] = 07430; $code[004162] = *I04162; sub I04162 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004163] = 07402; $code[004163] = *I04163; sub I04163 { $hlt = 1; goto &fetch; }
$core[004164] = 07300; $code[004164] = *I04164; sub I04164 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004165] = 01034; $code[004165] = *I04165; sub I04165 { $lac += $core[000034]; goto &fetch; }
$core[004166] = 07570; $code[004166] = *I04166; sub I04166 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004167] = 07430; $code[004167] = *I04167; sub I04167 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004170] = 07402; $code[004170] = *I04170; sub I04170 { $hlt = 1; goto &fetch; }
$core[004171] = 07300; $code[004171] = *I04171; sub I04171 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004172] = 01050; $code[004172] = *I04172; sub I04172 { $lac += $core[000050]; goto &fetch; }
$core[004173] = 07770; $code[004173] = *I04173; sub I04173 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004174] = 07402; $code[004174] = *I04174; sub I04174 { $hlt = 1; goto &fetch; }
$core[004175] = 07440; $code[004175] = *I04175; sub I04175 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004176] = 07402; $code[004176] = *I04176; sub I04176 { $hlt = 1; goto &fetch; }
$core[004177] = 07000; $code[004177] = *I04177; sub I04177 { goto &fetch; }
$core[004200] = 07320; $code[004200] = *I04200; sub I04200 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[004201] = 01050; $code[004201] = *I04201; sub I04201 { $lac += $core[000050]; goto &fetch; }
$core[004202] = 07770; $code[004202] = *I04202; sub I04202 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004203] = 07440; $code[004203] = *I04203; sub I04203 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004204] = 07402; $code[004204] = *I04204; sub I04204 { $hlt = 1; goto &fetch; }
$core[004205] = 07300; $code[004205] = *I04205; sub I04205 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004206] = 01034; $code[004206] = *I04206; sub I04206 { $lac += $core[000034]; goto &fetch; }
$core[004207] = 07770; $code[004207] = *I04207; sub I04207 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004210] = 07440; $code[004210] = *I04210; sub I04210 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004211] = 07402; $code[004211] = *I04211; sub I04211 { $hlt = 1; goto &fetch; }
$core[004212] = 07300; $code[004212] = *I04212; sub I04212 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004213] = 07770; $code[004213] = *I04213; sub I04213 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004214] = 07440; $code[004214] = *I04214; sub I04214 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004215] = 07402; $code[004215] = *I04215; sub I04215 { $hlt = 1; goto &fetch; }
$core[004216] = 07200; $code[004216] = *I04216; sub I04216 { $lac &= 010000; goto &fetch; }
$core[004217] = 01052; $code[004217] = *I04217; sub I04217 { $lac += $core[000052]; goto &fetch; }
$core[004220] = 07604; $code[004220] = *I04220; sub I04220 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004221] = 07040; $code[004221] = *I04221; sub I04221 { $lac ^= 07777; goto &fetch; }
$core[004222] = 07440; $code[004222] = *I04222; sub I04222 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004223] = 07402; $code[004223] = *I04223; sub I04223 { $hlt = 1; goto &fetch; }
$core[004224] = 07200; $code[004224] = *I04224; sub I04224 { $lac &= 010000; goto &fetch; }
$core[004225] = 01034; $code[004225] = *I04225; sub I04225 { $lac += $core[000034]; goto &fetch; }
$core[004226] = 07504; $code[004226] = *I04226; sub I04226 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[004227] = 07402; $code[004227] = *I04227; sub I04227 { $hlt = 1; goto &fetch; }
$core[004230] = 07040; $code[004230] = *I04230; sub I04230 { $lac ^= 07777; goto &fetch; }
$core[004231] = 07440; $code[004231] = *I04231; sub I04231 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004232] = 07402; $code[004232] = *I04232; sub I04232 { $hlt = 1; goto &fetch; }
$core[004233] = 07200; $code[004233] = *I04233; sub I04233 { $lac &= 010000; goto &fetch; }
$core[004234] = 07444; $code[004234] = *I04234; sub I04234 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[004235] = 07402; $code[004235] = *I04235; sub I04235 { $hlt = 1; goto &fetch; }
$core[004236] = 07040; $code[004236] = *I04236; sub I04236 { $lac ^= 07777; goto &fetch; }
$core[004237] = 07440; $code[004237] = *I04237; sub I04237 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004240] = 07402; $code[004240] = *I04240; sub I04240 { $hlt = 1; goto &fetch; }
$core[004241] = 07320; $code[004241] = *I04241; sub I04241 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[004242] = 07424; $code[004242] = *I04242; sub I04242 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[004243] = 07402; $code[004243] = *I04243; sub I04243 { $hlt = 1; goto &fetch; }
$core[004244] = 07040; $code[004244] = *I04244; sub I04244 { $lac ^= 07777; goto &fetch; }
$core[004245] = 07440; $code[004245] = *I04245; sub I04245 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004246] = 07402; $code[004246] = *I04246; sub I04246 { $hlt = 1; goto &fetch; }
$core[004247] = 07300; $code[004247] = *I04247; sub I04247 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004250] = 01050; $code[004250] = *I04250; sub I04250 { $lac += $core[000050]; goto &fetch; }
$core[004251] = 07764; $code[004251] = *I04251; sub I04251 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004252] = 07450; $code[004252] = *I04252; sub I04252 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004253] = 07402; $code[004253] = *I04253; sub I04253 { $hlt = 1; goto &fetch; }
$core[004254] = 07040; $code[004254] = *I04254; sub I04254 { $lac ^= 07777; goto &fetch; }
$core[004255] = 07440; $code[004255] = *I04255; sub I04255 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004256] = 07402; $code[004256] = *I04256; sub I04256 { $hlt = 1; goto &fetch; }
$core[004257] = 07200; $code[004257] = *I04257; sub I04257 { $lac &= 010000; goto &fetch; }
$core[004260] = 07414; $code[004260] = *I04260; sub I04260 { $skp = 0; $skp = !$skp; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[004261] = 07402; $code[004261] = *I04261; sub I04261 { $hlt = 1; goto &fetch; }
$core[004262] = 07040; $code[004262] = *I04262; sub I04262 { $lac ^= 07777; goto &fetch; }
$core[004263] = 07440; $code[004263] = *I04263; sub I04263 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004264] = 07402; $code[004264] = *I04264; sub I04264 { $hlt = 1; goto &fetch; }
$core[004265] = 07200; $code[004265] = *I04265; sub I04265 { $lac &= 010000; goto &fetch; }
$core[004266] = 07514; $code[004266] = *I04266; sub I04266 { $skp = 0; $skp = 1 if $lac&04000; $skp = !$skp; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[004267] = 07402; $code[004267] = *I04267; sub I04267 { $hlt = 1; goto &fetch; }
$core[004270] = 07040; $code[004270] = *I04270; sub I04270 { $lac ^= 07777; goto &fetch; }
$core[004271] = 07440; $code[004271] = *I04271; sub I04271 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004272] = 07402; $code[004272] = *I04272; sub I04272 { $hlt = 1; goto &fetch; }
$core[004273] = 07200; $code[004273] = *I04273; sub I04273 { $lac &= 010000; goto &fetch; }
$core[004274] = 01031; $code[004274] = *I04274; sub I04274 { $lac += $core[000031]; goto &fetch; }
$core[004275] = 07454; $code[004275] = *I04275; sub I04275 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[004276] = 07402; $code[004276] = *I04276; sub I04276 { $hlt = 1; goto &fetch; }
$core[004277] = 07040; $code[004277] = *I04277; sub I04277 { $lac ^= 07777; goto &fetch; }
$core[004300] = 07440; $code[004300] = *I04300; sub I04300 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004301] = 07402; $code[004301] = *I04301; sub I04301 { $hlt = 1; goto &fetch; }
$core[004302] = 07300; $code[004302] = *I04302; sub I04302 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004303] = 07434; $code[004303] = *I04303; sub I04303 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[004304] = 07402; $code[004304] = *I04304; sub I04304 { $hlt = 1; goto &fetch; }
$core[004305] = 07040; $code[004305] = *I04305; sub I04305 { $lac ^= 07777; goto &fetch; }
$core[004306] = 07440; $code[004306] = *I04306; sub I04306 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004307] = 07402; $code[004307] = *I04307; sub I04307 { $hlt = 1; goto &fetch; }
$core[004310] = 07300; $code[004310] = *I04310; sub I04310 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004311] = 01050; $code[004311] = *I04311; sub I04311 { $lac += $core[000050]; goto &fetch; }
$core[004312] = 07774; $code[004312] = *I04312; sub I04312 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[004313] = 07402; $code[004313] = *I04313; sub I04313 { $hlt = 1; goto &fetch; }
$core[004314] = 07040; $code[004314] = *I04314; sub I04314 { $lac ^= 07777; goto &fetch; }
$core[004315] = 07440; $code[004315] = *I04315; sub I04315 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004316] = 07402; $code[004316] = *I04316; sub I04316 { $hlt = 1; goto &fetch; }
$core[004317] = 07200; $code[004317] = *I04317; sub I04317 { $lac &= 010000; goto &fetch; }
$core[004320] = 00051; $code[004320] = *I04320; sub I04320 { $lac &= (010000|$core[000051]); goto &fetch; }
$core[004321] = 07440; $code[004321] = *I04321; sub I04321 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004322] = 07402; $code[004322] = *I04322; sub I04322 { $hlt = 1; goto &fetch; }
$core[004323] = 07240; $code[004323] = *I04323; sub I04323 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[004324] = 00020; $code[004324] = *I04324; sub I04324 { $lac &= (010000|$core[000020]); goto &fetch; }
$core[004325] = 07440; $code[004325] = *I04325; sub I04325 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004326] = 07402; $code[004326] = *I04326; sub I04326 { $hlt = 1; goto &fetch; }
$core[004327] = 07320; $code[004327] = *I04327; sub I04327 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; goto &fetch; }
$core[004330] = 01051; $code[004330] = *I04330; sub I04330 { $lac += $core[000051]; goto &fetch; }
$core[004331] = 00051; $code[004331] = *I04331; sub I04331 { $lac &= (010000|$core[000051]); goto &fetch; }
$core[004332] = 07040; $code[004332] = *I04332; sub I04332 { $lac ^= 07777; goto &fetch; }
$core[004333] = 07430; $code[004333] = *I04333; sub I04333 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004334] = 07440; $code[004334] = *I04334; sub I04334 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004335] = 07402; $code[004335] = *I04335; sub I04335 { $hlt = 1; goto &fetch; }
$core[004336] = 07300; $code[004336] = *I04336; sub I04336 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004337] = 01053; $code[004337] = *I04337; sub I04337 { $lac += $core[000053]; goto &fetch; }
$core[004340] = 00052; $code[004340] = *I04340; sub I04340 { $lac &= (010000|$core[000052]); goto &fetch; }
$core[004341] = 07420; $code[004341] = *I04341; sub I04341 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[004342] = 07440; $code[004342] = *I04342; sub I04342 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004343] = 07402; $code[004343] = *I04343; sub I04343 { $hlt = 1; goto &fetch; }
$core[004344] = 07300; $code[004344] = *I04344; sub I04344 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004345] = 01052; $code[004345] = *I04345; sub I04345 { $lac += $core[000052]; goto &fetch; }
$core[004346] = 00053; $code[004346] = *I04346; sub I04346 { $lac &= (010000|$core[000053]); goto &fetch; }
$core[004347] = 07420; $code[004347] = *I04347; sub I04347 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[004350] = 07440; $code[004350] = *I04350; sub I04350 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004351] = 07402; $code[004351] = *I04351; sub I04351 { $hlt = 1; goto &fetch; }
$core[004352] = 07300; $code[004352] = *I04352; sub I04352 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004353] = 01035; $code[004353] = *I04353; sub I04353 { $lac += $core[000035]; goto &fetch; }
$core[004354] = 00052; $code[004354] = *I04354; sub I04354 { $lac &= (010000|$core[000052]); goto &fetch; }
$core[004355] = 07041; $code[004355] = *I04355; sub I04355 { $lac ^= 07777; $lac++; goto &fetch; }
$core[004356] = 01052; $code[004356] = *I04356; sub I04356 { $lac += $core[000052]; goto &fetch; }
$core[004357] = 07430; $code[004357] = *I04357; sub I04357 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004360] = 07440; $code[004360] = *I04360; sub I04360 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004361] = 07402; $code[004361] = *I04361; sub I04361 { $hlt = 1; goto &fetch; }
$core[004362] = 07300; $code[004362] = *I04362; sub I04362 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[004363] = 01053; $code[004363] = *I04363; sub I04363 { $lac += $core[000053]; goto &fetch; }
$core[004364] = 00053; $code[004364] = *I04364; sub I04364 { $lac &= (010000|$core[000053]); goto &fetch; }
$core[004365] = 07041; $code[004365] = *I04365; sub I04365 { $lac ^= 07777; $lac++; goto &fetch; }
$core[004366] = 01053; $code[004366] = *I04366; sub I04366 { $lac += $core[000053]; goto &fetch; }
$core[004367] = 07430; $code[004367] = *I04367; sub I04367 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[004370] = 07440; $code[004370] = *I04370; sub I04370 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[004371] = 07402; $code[004371] = *I04371; sub I04371 { $hlt = 1; goto &fetch; }
$core[004372] = 07000; $code[004372] = *I04372; sub I04372 { goto &fetch; }
$core[004373] = 07000; $code[004373] = *I04373; sub I04373 { goto &fetch; }
$core[004374] = 07000; $code[004374] = *I04374; sub I04374 { goto &fetch; }
$core[004375] = 07000; $code[004375] = *I04375; sub I04375 { goto &fetch; }
$core[004376] = 07000; $code[004376] = *I04376; sub I04376 { goto &fetch; }
$core[004377] = 07000; $code[004377] = *I04377; sub I04377 { goto &fetch; }
$core[004400] = 07200; $code[004400] = *I04400; sub I04400 { $lac &= 010000; goto &fetch; }
$core[004401] = 01220; $code[004401] = *I04401; sub I04401 { $lac += $core[004420]; goto &fetch; }
$core[004402] = 07001; $code[004402] = *I04402; sub I04402 { $lac++; goto &fetch; }
$core[004403] = 03220; $code[004403] = *I04403; sub I04403 { $core[004420] = $lac & 07777; $lac &= 010000; $code[004420] = *emul8; goto &fetch; }
$core[004404] = 01220; $code[004404] = *I04404; sub I04404 { $lac += $core[004420]; goto &fetch; }
$core[004405] = 07640; $code[004405] = *I04405; sub I04405 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[004406] = 05147; $code[004406] = *I04406; sub I04406 { $pc = 000147; $inh = 0; goto &fetch; }
$core[004407] = 01221; $code[004407] = *D04407; sub D04407 { $lac += $core[004421]; goto &fetch; }
$core[004410] = 03220; $code[004410] = *I04410; sub I04410 { $core[004420] = $lac & 07777; $lac &= 010000; $code[004420] = *emul8; goto &fetch; }
$core[004411] = 01217; $code[004411] = *I04411; sub I04411 { $lac += $core[004417]; goto &fetch; }
$core[004412] = 06046; $code[004412] = *I04412; sub I04412 { &emul8; goto &fetch; }
$core[004413] = 06041; $code[004413] = *L04413; sub L04413 { &emul8; goto &fetch; }
$core[004414] = 05213; $code[004414] = *I04414; sub I04414 { $pc = 004413; $inh = 0; goto &fetch; }
$core[004415] = 06042; $code[004415] = *I04415; sub I04415 { &emul8; goto &fetch; }
$core[004416] = 05147; $code[004416] = *I04416; sub I04416 { $pc = 000147; $inh = 0; goto &fetch; }
$core[004417] = 00207; $code[004417] = *D04417; sub D04417 { $lac &= (010000|$core[004407]); goto &fetch; }
$core[004420] = 07600; $code[004420] = *D04420; sub D04420 { $lac &= 010000; goto &fetch; }
$core[004421] = 07600; $code[004421] = *D04421; sub D04421 { $lac &= 010000; goto &fetch; }
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

