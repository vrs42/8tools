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
$core[000004] = 00003; $code[000004] = *I00004; sub I00004 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000005] = 00000; $code[000005] = *D00005; sub D00005 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000006] = 00000; $code[000006] = *D00006; sub D00006 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000007] = 00000; $code[000007] = *D00007; sub D00007 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000010] = 00000; $code[000010] = *P00010; sub P00010 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000020] = 00000; $code[000020] = *D00020; sub D00020 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000200] = 06007; $code[000200] = *L00200; sub L00200 { &emul8; goto &fetch; }
$core[000201] = 01204; $code[000201] = *D00201; sub D00201 { $lac += $core[000204]; goto &fetch; }
$core[000202] = 03201; $code[000202] = *P00202; sub P00202 { $core[000201] = $lac & 07777; $lac &= 010000; $code[000201] = *emul8; goto &fetch; }
$core[000203] = 04205; $code[000203] = *P00203; sub P00203 { $core[000205] = 00204; $pc = 000205+1; $code[000205] = *emul8; $inh = 0; goto &fetch; }
$core[000204] = 05274; $code[000204] = *D00204; sub D00204 { $pc = 000274; $inh = 0; goto &fetch; }
$core[000205] = 00000; $code[000205] = *S00205; sub S00205 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000206] = 01374; $code[000206] = *I00206; sub I00206 { $lac += $core[000374]; goto &fetch; }
$core[000207] = 03266; $code[000207] = *I00207; sub I00207 { $core[000266] = $lac & 07777; $lac &= 010000; $code[000266] = *emul8; goto &fetch; }
$core[000210] = 01374; $code[000210] = *I00210; sub I00210 { $lac += $core[000374]; goto &fetch; }
$core[000211] = 03202; $code[000211] = *I00211; sub I00211 { $core[000202] = $lac & 07777; $lac &= 010000; $code[000202] = *emul8; goto &fetch; }
$core[000212] = 03203; $code[000212] = *D00212; sub D00212 { $core[000203] = $lac & 07777; $lac &= 010000; $code[000203] = *emul8; goto &fetch; }
$core[000213] = 04225; $code[000213] = *I00213; sub I00213 { $core[000225] = 00214; $pc = 000225+1; $code[000225] = *emul8; $inh = 0; goto &fetch; }
$core[000214] = 05605; $code[000214] = *I00214; sub I00214 { $pc = ($ib<<12)+$core[133]; $inh = 0; goto &fetch; }
$core[000215] = 00000; $code[000215] = *S00215; sub S00215 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000216] = 01374; $code[000216] = *I00216; sub I00216 { $lac += $core[000374]; goto &fetch; }
$core[000217] = 03266; $code[000217] = *I00217; sub I00217 { $core[000266] = $lac & 07777; $lac &= 010000; $code[000266] = *emul8; goto &fetch; }
$core[000220] = 03202; $code[000220] = *I00220; sub I00220 { $core[000202] = $lac & 07777; $lac &= 010000; $code[000202] = *emul8; goto &fetch; }
$core[000221] = 01374; $code[000221] = *I00221; sub I00221 { $lac += $core[000374]; goto &fetch; }
$core[000222] = 03203; $code[000222] = *I00222; sub I00222 { $core[000203] = $lac & 07777; $lac &= 010000; $code[000203] = *emul8; goto &fetch; }
$core[000223] = 04225; $code[000223] = *I00223; sub I00223 { $core[000225] = 00224; $pc = 000225+1; $code[000225] = *emul8; $inh = 0; goto &fetch; }
$core[000224] = 05615; $code[000224] = *I00224; sub I00224 { $pc = ($ib<<12)+$core[141]; $inh = 0; goto &fetch; }
$core[000225] = 00000; $code[000225] = *S00225; sub S00225 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000226] = 01602; $code[000226] = *L00226; sub L00226 { $lac += $core[($df<<12)+$core[130]]; goto &fetch; }
$core[000227] = 03603; $code[000227] = *I00227; sub I00227 { $core[($df<<12)+$core[131]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[131]] = *emul8; goto &fetch; }
$core[000230] = 01602; $code[000230] = *I00230; sub I00230 { $lac += $core[($df<<12)+$core[130]]; goto &fetch; }
$core[000231] = 07041; $code[000231] = *I00231; sub I00231 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000232] = 01603; $code[000232] = *I00232; sub I00232 { $lac += $core[($df<<12)+$core[131]]; goto &fetch; }
$core[000233] = 07640; $code[000233] = *I00233; sub I00233 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000234] = 07402; $code[000234] = *I00234; sub I00234 { $hlt = 1; goto &fetch; }
$core[000235] = 02202; $code[000235] = *I00235; sub I00235 { if (++$core[000202] == 010000) { $core[000202] = 0; $pc++; }$code[000202] = *emul8; goto &fetch; }
$core[000236] = 07000; $code[000236] = *I00236; sub I00236 { goto &fetch; }
$core[000237] = 02203; $code[000237] = *I00237; sub I00237 { if (++$core[000203] == 010000) { $core[000203] = 0; $pc++; }$code[000203] = *emul8; goto &fetch; }
$core[000240] = 07000; $code[000240] = *I00240; sub I00240 { goto &fetch; }
$core[000241] = 02266; $code[000241] = *I00241; sub I00241 { if (++$core[000266] == 010000) { $core[000266] = 0; $pc++; }$code[000266] = *emul8; goto &fetch; }
$core[000242] = 05226; $code[000242] = *I00242; sub I00242 { $pc = 000226; $inh = 0; goto &fetch; }
$core[000243] = 05625; $code[000243] = *I00243; sub I00243 { $pc = ($ib<<12)+$core[149]; $inh = 0; goto &fetch; }
$core[000244] = 04215; $code[000244] = *L00244; sub L00244 { $core[000215] = 00245; $pc = 000215+1; $code[000215] = *emul8; $inh = 0; goto &fetch; }
$core[000245] = 01373; $code[000245] = *I00245; sub I00245 { $lac += $core[000373]; goto &fetch; }
$core[000246] = 03266; $code[000246] = *I00246; sub I00246 { $core[000266] = $lac & 07777; $lac &= 010000; $code[000266] = *emul8; goto &fetch; }
$core[000247] = 01365; $code[000247] = *I00247; sub I00247 { $lac += $core[000365]; goto &fetch; }
$core[000250] = 03202; $code[000250] = *I00250; sub I00250 { $core[000202] = $lac & 07777; $lac &= 010000; $code[000202] = *emul8; goto &fetch; }
$core[000251] = 01372; $code[000251] = *I00251; sub I00251 { $lac += $core[000372]; goto &fetch; }
$core[000252] = 03203; $code[000252] = *I00252; sub I00252 { $core[000203] = $lac & 07777; $lac &= 010000; $code[000203] = *emul8; goto &fetch; }
$core[000253] = 04225; $code[000253] = *I00253; sub I00253 { $core[000225] = 00254; $pc = 000225+1; $code[000225] = *emul8; $inh = 0; goto &fetch; }
$core[000254] = 05772; $code[000254] = *I00254; sub I00254 { $pc = ($ib<<12)+$core[250]; $inh = 0; goto &fetch; }
$core[000255] = 04205; $code[000255] = *L00255; sub L00255 { $core[000205] = 00256; $pc = 000205+1; $code[000205] = *emul8; $inh = 0; goto &fetch; }
$core[000256] = 01373; $code[000256] = *I00256; sub I00256 { $lac += $core[000373]; goto &fetch; }
$core[000257] = 03266; $code[000257] = *I00257; sub I00257 { $core[000266] = $lac & 07777; $lac &= 010000; $code[000266] = *emul8; goto &fetch; }
$core[000260] = 01372; $code[000260] = *I00260; sub I00260 { $lac += $core[000372]; goto &fetch; }
$core[000261] = 03202; $code[000261] = *I00261; sub I00261 { $core[000202] = $lac & 07777; $lac &= 010000; $code[000202] = *emul8; goto &fetch; }
$core[000262] = 01365; $code[000262] = *I00262; sub I00262 { $lac += $core[000365]; goto &fetch; }
$core[000263] = 03203; $code[000263] = *I00263; sub I00263 { $core[000203] = $lac & 07777; $lac &= 010000; $code[000203] = *emul8; goto &fetch; }
$core[000264] = 04225; $code[000264] = *I00264; sub I00264 { $core[000225] = 00265; $pc = 000225+1; $code[000225] = *emul8; $inh = 0; goto &fetch; }
$core[000265] = 05765; $code[000265] = *I00265; sub I00265 { $pc = ($ib<<12)+$core[245]; $inh = 0; goto &fetch; }
$core[000266] = 00000; $code[000266] = *S00266; sub S00266 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000267] = 07330; $code[000267] = *I00267; sub I00267 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000270] = 01266; $code[000270] = *I00270; sub I00270 { $lac += $core[000266]; goto &fetch; }
$core[000271] = 07630; $code[000271] = *I00271; sub I00271 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000272] = 01371; $code[000272] = *I00272; sub I00272 { $lac += $core[000371]; goto &fetch; }
$core[000273] = 05666; $code[000273] = *I00273; sub I00273 { $pc = ($ib<<12)+$core[182]; $inh = 0; goto &fetch; }
$core[000274] = 07300; $code[000274] = *L00274; sub L00274 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000275] = 03202; $code[000275] = *I00275; sub I00275 { $core[000202] = $lac & 07777; $lac &= 010000; $code[000202] = *emul8; goto &fetch; }
$core[000276] = 04266; $code[000276] = *I00276; sub I00276 { $core[000266] = 00277; $pc = 000266+1; $code[000266] = *emul8; $inh = 0; goto &fetch; }
$core[000277] = 05377; $code[000277] = *I00277; sub I00277 { $pc = 000377; $inh = 0; goto &fetch; }
$core[000300] = 00000; $code[000300] = *S00300; sub S00300 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000301] = 07040; $code[000301] = *D00301; sub D00301 { $lac ^= 07777; goto &fetch; }
$core[000302] = 03204; $code[000302] = *I00302; sub I00302 { $core[000204] = $lac & 07777; $lac &= 010000; $code[000204] = *emul8; goto &fetch; }
$core[000303] = 07501; $code[000303] = *I00303; sub I00303 { &emul8; goto &fetch; }
$core[000304] = 07040; $code[000304] = *I00304; sub I00304 { $lac ^= 07777; goto &fetch; }
$core[000305] = 07421; $code[000305] = *I00305; sub I00305 { &emul8; goto &fetch; }
$core[000306] = 01204; $code[000306] = *I00306; sub I00306 { $lac += $core[000204]; goto &fetch; }
$core[000307] = 07501; $code[000307] = *I00307; sub I00307 { &emul8; goto &fetch; }
$core[000310] = 07040; $code[000310] = *I00310; sub I00310 { $lac ^= 07777; goto &fetch; }
$core[000311] = 05700; $code[000311] = *I00311; sub I00311 { $pc = ($ib<<12)+$core[192]; $inh = 0; goto &fetch; }
$core[000312] = 00000; $code[000312] = *S00312; sub S00312 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000313] = 07421; $code[000313] = *I00313; sub I00313 { &emul8; goto &fetch; }
$core[000314] = 07604; $code[000314] = *I00314; sub I00314 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[000315] = 04300; $code[000315] = *I00315; sub I00315 { $core[000300] = 00316; $pc = 000300+1; $code[000300] = *emul8; $inh = 0; goto &fetch; }
$core[000316] = 07650; $code[000316] = *I00316; sub I00316 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000317] = 02312; $code[000317] = *I00317; sub I00317 { if (++$core[000312] == 010000) { $core[000312] = 0; $pc++; }$code[000312] = *emul8; goto &fetch; }
$core[000320] = 05712; $code[000320] = *I00320; sub I00320 { $pc = ($ib<<12)+$core[202]; $inh = 0; goto &fetch; }
$core[000321] = 00000; $code[000321] = *P00321; sub P00321 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000322] = 02202; $code[000322] = *I00322; sub I00322 { if (++$core[000202] == 010000) { $core[000202] = 0; $pc++; }$code[000202] = *emul8; goto &fetch; }
$core[000323] = 05721; $code[000323] = *I00323; sub I00323 { $pc = ($ib<<12)+$core[209]; $inh = 0; goto &fetch; }
$core[000324] = 07332; $code[000324] = *I00324; sub I00324 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000325] = 07012; $code[000325] = *I00325; sub I00325 { $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000326] = 04312; $code[000326] = *I00326; sub I00326 { $core[000312] = 00327; $pc = 000312+1; $code[000312] = *emul8; $inh = 0; goto &fetch; }
$core[000327] = 05336; $code[000327] = *I00327; sub I00327 { $pc = 000336; $inh = 0; goto &fetch; }
$core[000330] = 01366; $code[000330] = *I00330; sub I00330 { $lac += $core[000366]; goto &fetch; }
$core[000331] = 04337; $code[000331] = *I00331; sub I00331 { $core[000337] = 00332; $pc = 000337+1; $code[000337] = *emul8; $inh = 0; goto &fetch; }
$core[000332] = 01367; $code[000332] = *I00332; sub I00332 { $lac += $core[000367]; goto &fetch; }
$core[000333] = 04337; $code[000333] = *I00333; sub I00333 { $core[000337] = 00334; $pc = 000337+1; $code[000337] = *emul8; $inh = 0; goto &fetch; }
$core[000334] = 01370; $code[000334] = *I00334; sub I00334 { $lac += $core[000370]; goto &fetch; }
$core[000335] = 04337; $code[000335] = *I00335; sub I00335 { $core[000337] = 00336; $pc = 000337+1; $code[000337] = *emul8; $inh = 0; goto &fetch; }
$core[000336] = 05345; $code[000336] = *L00336; sub L00336 { $pc = 000345; $inh = 0; goto &fetch; }
$core[000337] = 00000; $code[000337] = *S00337; sub S00337 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000340] = 06046; $code[000340] = *I00340; sub I00340 { &emul8; goto &fetch; }
$core[000341] = 06041; $code[000341] = *L00341; sub L00341 { &emul8; goto &fetch; }
$core[000342] = 05341; $code[000342] = *I00342; sub I00342 { $pc = 000341; $inh = 0; goto &fetch; }
$core[000343] = 07200; $code[000343] = *I00343; sub I00343 { $lac &= 010000; goto &fetch; }
$core[000344] = 05737; $code[000344] = *I00344; sub I00344 { $pc = ($ib<<12)+$core[223]; $inh = 0; goto &fetch; }
$core[000345] = 07332; $code[000345] = *L00345; sub L00345 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000346] = 04312; $code[000346] = *I00346; sub I00346 { $core[000312] = 00347; $pc = 000312+1; $code[000312] = *emul8; $inh = 0; goto &fetch; }
$core[000347] = 07410; $code[000347] = *I00347; sub I00347 { $skp = 0; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000350] = 05355; $code[000350] = *I00350; sub I00350 { $pc = 000355; $inh = 0; goto &fetch; }
$core[000351] = 04266; $code[000351] = *I00351; sub I00351 { $core[000266] = 00352; $pc = 000266+1; $code[000266] = *emul8; $inh = 0; goto &fetch; }
$core[000352] = 07650; $code[000352] = *I00352; sub I00352 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000353] = 04215; $code[000353] = *I00353; sub I00353 { $core[000215] = 00354; $pc = 000215+1; $code[000215] = *emul8; $inh = 0; goto &fetch; }
$core[000354] = 07402; $code[000354] = *I00354; sub I00354 { $hlt = 1; goto &fetch; }
$core[000355] = 07332; $code[000355] = *L00355; sub L00355 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[000356] = 07010; $code[000356] = *I00356; sub I00356 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000357] = 04312; $code[000357] = *I00357; sub I00357 { $core[000312] = 00360; $pc = 000312+1; $code[000312] = *emul8; $inh = 0; goto &fetch; }
$core[000360] = 05721; $code[000360] = *I00360; sub I00360 { $pc = ($ib<<12)+$core[209]; $inh = 0; goto &fetch; }
$core[000361] = 04266; $code[000361] = *I00361; sub I00361 { $core[000266] = 00362; $pc = 000266+1; $code[000266] = *emul8; $inh = 0; goto &fetch; }
$core[000362] = 07650; $code[000362] = *I00362; sub I00362 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000363] = 05244; $code[000363] = *I00363; sub I00363 { $pc = 000244; $inh = 0; goto &fetch; }
$core[000364] = 05255; $code[000364] = *I00364; sub I00364 { $pc = 000255; $inh = 0; goto &fetch; }
$core[000365] = 00200; $code[000365] = *P00365; sub P00365 { $lac &= (010000|$core[000200]); goto &fetch; }
$core[000366] = 00215; $code[000366] = *D00366; sub D00366 { $lac &= (010000|$core[000215]); goto &fetch; }
$core[000367] = 00212; $code[000367] = *D00367; sub D00367 { $lac &= (010000|$core[000212]); goto &fetch; }
$core[000370] = 00301; $code[000370] = *D00370; sub D00370 { $lac &= (010000|$core[000301]); goto &fetch; }
$core[000371] = 06400; $code[000371] = *D00371; sub D00371 { &emul8; goto &fetch; }
$core[000372] = 06600; $code[000372] = *P00372; sub P00372 { &emul8; goto &fetch; }
$core[000373] = 07000; $code[000373] = *D00373; sub D00373 { goto &fetch; }
$core[000374] = 07600; $code[000374] = *D00374; sub D00374 { $lac &= 010000; goto &fetch; }
$core[000377] = 07000; $code[000377] = *L00377; sub L00377 { goto &fetch; }
$core[000400] = 03237; $code[000400] = *D00400; sub D00400 { $core[000437] = $lac & 07777; $lac &= 010000; $code[000437] = *emul8; goto &fetch; }
$core[000401] = 01242; $code[000401] = *D00401; sub D00401 { $lac += $core[000442]; goto &fetch; }
$core[000402] = 01237; $code[000402] = *I00402; sub I00402 { $lac += $core[000437]; goto &fetch; }
$core[000403] = 03010; $code[000403] = *I00403; sub I00403 { $core[000010] = $lac & 07777; $lac &= 010000; $code[000010] = *emul8; goto &fetch; }
$core[000404] = 01243; $code[000404] = *I00404; sub I00404 { $lac += $core[000443]; goto &fetch; }
$core[000405] = 01237; $code[000405] = *I00405; sub I00405 { $lac += $core[000437]; goto &fetch; }
$core[000406] = 03410; $code[000406] = *I00406; sub I00406 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000407] = 01245; $code[000407] = *I00407; sub I00407 { $lac += $core[000445]; goto &fetch; }
$core[000410] = 01237; $code[000410] = *I00410; sub I00410 { $lac += $core[000437]; goto &fetch; }
$core[000411] = 03410; $code[000411] = *I00411; sub I00411 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000412] = 01246; $code[000412] = *I00412; sub I00412 { $lac += $core[000446]; goto &fetch; }
$core[000413] = 01237; $code[000413] = *I00413; sub I00413 { $lac += $core[000437]; goto &fetch; }
$core[000414] = 03410; $code[000414] = *I00414; sub I00414 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000415] = 01247; $code[000415] = *I00415; sub I00415 { $lac += $core[000447]; goto &fetch; }
$core[000416] = 01237; $code[000416] = *I00416; sub I00416 { $lac += $core[000437]; goto &fetch; }
$core[000417] = 03410; $code[000417] = *I00417; sub I00417 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000420] = 01244; $code[000420] = *I00420; sub I00420 { $lac += $core[000444]; goto &fetch; }
$core[000421] = 01237; $code[000421] = *I00421; sub I00421 { $lac += $core[000437]; goto &fetch; }
$core[000422] = 03410; $code[000422] = *I00422; sub I00422 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000423] = 01237; $code[000423] = *I00423; sub I00423 { $lac += $core[000437]; goto &fetch; }
$core[000424] = 07640; $code[000424] = *I00424; sub I00424 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000425] = 05233; $code[000425] = *I00425; sub I00425 { $pc = 000433; $inh = 0; goto &fetch; }
$core[000426] = 01240; $code[000426] = *I00426; sub I00426 { $lac += $core[000440]; goto &fetch; }
$core[000427] = 03410; $code[000427] = *I00427; sub I00427 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000430] = 01250; $code[000430] = *I00430; sub I00430 { $lac += $core[000450]; goto &fetch; }
$core[000431] = 03410; $code[000431] = *I00431; sub I00431 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000432] = 05377; $code[000432] = *I00432; sub I00432 { $pc = 000577; $inh = 0; goto &fetch; }
$core[000433] = 03410; $code[000433] = *L00433; sub L00433 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000434] = 01251; $code[000434] = *I00434; sub I00434 { $lac += $core[000451]; goto &fetch; }
$core[000435] = 03410; $code[000435] = *I00435; sub I00435 { $core[000010] = 0000 if ++$core[000010] == 010000; $core[($df<<12)+$core[000010]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[000010]] = *emul8; goto &fetch; }
$core[000436] = 05377; $code[000436] = *I00436; sub I00436 { $pc = 000577; $inh = 0; goto &fetch; }
$core[000437] = 00000; $code[000437] = *D00437; sub D00437 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000440] = 00200; $code[000440] = *D00440; sub D00440 { $lac &= (010000|$core[000400]); goto &fetch; }
$core[000441] = 07000; $code[000441] = *I00441; sub I00441 { goto &fetch; }
$core[000442] = 00753; $code[000442] = *D00442; sub D00442 { $lac &= (010000|$core[($df<<12)+$core[363]]); goto &fetch; }
$core[000443] = 01000; $code[000443] = *D00443; sub D00443 { $lac += $core[000000]; goto &fetch; }
$core[000444] = 00321; $code[000444] = *D00444; sub D00444 { $lac &= (010000|$core[000521]); goto &fetch; }
$core[000445] = 00300; $code[000445] = *D00445; sub D00445 { $lac &= (010000|$core[000500]); goto &fetch; }
$core[000446] = 00712; $code[000446] = *D00446; sub D00446 { $lac &= (010000|$core[($df<<12)+$core[330]]); goto &fetch; }
$core[000447] = 00312; $code[000447] = *D00447; sub D00447 { $lac &= (010000|$core[000512]); goto &fetch; }
$core[000450] = 06600; $code[000450] = *D00450; sub D00450 { &emul8; goto &fetch; }
$core[000451] = 01201; $code[000451] = *D00451; sub D00451 { $lac += $core[000401]; goto &fetch; }
$core[000577] = 07000; $code[000577] = *L00577; sub L00577 { goto &fetch; }
$core[000600] = 07300; $code[000600] = *L00600; sub L00600 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000601] = 01355; $code[000601] = *I00601; sub I00601 { $lac += $core[000755]; goto &fetch; }
$core[000602] = 03000; $code[000602] = *I00602; sub I00602 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000603] = 07001; $code[000603] = *I00603; sub I00603 { $lac++; goto &fetch; }
$core[000604] = 04757; $code[000604] = *I00604; sub I00604 { $core[($ib<<12)+$core[495]] = 00605; $pc = ($ib<<12)+$core[495]+1; $code[($ib<<12)+$core[495]] = *emul8; $inh = 0; goto &fetch; }
$core[000605] = 05224; $code[000605] = *I00605; sub I00605 { $pc = 000624; $inh = 0; goto &fetch; }
$core[000606] = 01362; $code[000606] = *I00606; sub I00606 { $lac += $core[000762]; goto &fetch; }
$core[000607] = 03006; $code[000607] = *I00607; sub I00607 { $core[000006] = $lac & 07777; $lac &= 010000; $code[000006] = *emul8; goto &fetch; }
$core[000610] = 01361; $code[000610] = *I00610; sub I00610 { $lac += $core[000761]; goto &fetch; }
$core[000611] = 03007; $code[000611] = *I00611; sub I00611 { $core[000007] = $lac & 07777; $lac &= 010000; $code[000007] = *emul8; goto &fetch; }
$core[000612] = 04754; $code[000612] = *I00612; sub I00612 { $core[($ib<<12)+$core[492]] = 00613; $pc = ($ib<<12)+$core[492]+1; $code[($ib<<12)+$core[492]] = *emul8; $inh = 0; goto &fetch; }
$core[000613] = 03365; $code[000613] = *I00613; sub I00613 { $core[000765] = $lac & 07777; $lac &= 010000; $code[000765] = *emul8; goto &fetch; }
$core[000614] = 01001; $code[000614] = *I00614; sub I00614 { $lac += $core[000001]; goto &fetch; }
$core[000615] = 03363; $code[000615] = *I00615; sub I00615 { $core[000763] = $lac & 07777; $lac &= 010000; $code[000763] = *emul8; goto &fetch; }
$core[000616] = 01002; $code[000616] = *I00616; sub I00616 { $lac += $core[000002]; goto &fetch; }
$core[000617] = 03364; $code[000617] = *I00617; sub I00617 { $core[000764] = $lac & 07777; $lac &= 010000; $code[000764] = *emul8; goto &fetch; }
$core[000620] = 01003; $code[000620] = *I00620; sub I00620 { $lac += $core[000003]; goto &fetch; }
$core[000621] = 03366; $code[000621] = *I00621; sub I00621 { $core[000766] = $lac & 07777; $lac &= 010000; $code[000766] = *emul8; goto &fetch; }
$core[000622] = 01005; $code[000622] = *I00622; sub I00622 { $lac += $core[000005]; goto &fetch; }
$core[000623] = 03367; $code[000623] = *I00623; sub I00623 { $core[000767] = $lac & 07777; $lac &= 010000; $code[000767] = *emul8; goto &fetch; }
$core[000624] = 07105; $code[000624] = *L00624; sub L00624 { $lac &= 07777; $lac++; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000625] = 04757; $code[000625] = *I00625; sub I00625 { $core[($ib<<12)+$core[495]] = 00626; $pc = ($ib<<12)+$core[495]+1; $code[($ib<<12)+$core[495]] = *emul8; $inh = 0; goto &fetch; }
$core[000626] = 05234; $code[000626] = *I00626; sub I00626 { $pc = 000634; $inh = 0; goto &fetch; }
$core[000627] = 01370; $code[000627] = *I00627; sub I00627 { $lac += $core[000770]; goto &fetch; }
$core[000630] = 07104; $code[000630] = *I00630; sub I00630 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000631] = 07430; $code[000631] = *I00631; sub I00631 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000632] = 01374; $code[000632] = *I00632; sub I00632 { $lac += $core[000774]; goto &fetch; }
$core[000633] = 03370; $code[000633] = *I00633; sub I00633 { $core[000770] = $lac & 07777; $lac &= 010000; $code[000770] = *emul8; goto &fetch; }
$core[000634] = 07307; $code[000634] = *L00634; sub L00634 { $lac &= 010000; $lac &= 07777; $lac++; $lac = ($lac<<2) + (($lac>>11)&3); goto &fetch; }
$core[000635] = 04757; $code[000635] = *I00635; sub I00635 { $core[($ib<<12)+$core[495]] = 00636; $pc = ($ib<<12)+$core[495]+1; $code[($ib<<12)+$core[495]] = *emul8; $inh = 0; goto &fetch; }
$core[000636] = 05244; $code[000636] = *I00636; sub I00636 { $pc = 000644; $inh = 0; goto &fetch; }
$core[000637] = 01371; $code[000637] = *I00637; sub I00637 { $lac += $core[000771]; goto &fetch; }
$core[000640] = 07104; $code[000640] = *I00640; sub I00640 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[000641] = 07430; $code[000641] = *I00641; sub I00641 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000642] = 01374; $code[000642] = *I00642; sub I00642 { $lac += $core[000774]; goto &fetch; }
$core[000643] = 03371; $code[000643] = *I00643; sub I00643 { $core[000771] = $lac & 07777; $lac &= 010000; $code[000771] = *emul8; goto &fetch; }
$core[000644] = 07300; $code[000644] = *L00644; sub L00644 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000645] = 01363; $code[000645] = *I00645; sub I00645 { $lac += $core[000763]; goto &fetch; }
$core[000646] = 03764; $code[000646] = *I00646; sub I00646 { $core[($df<<12)+$core[500]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[500]] = *emul8; goto &fetch; }
$core[000647] = 01365; $code[000647] = *I00647; sub I00647 { $lac += $core[000765]; goto &fetch; }
$core[000650] = 07650; $code[000650] = *I00650; sub I00650 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000651] = 05267; $code[000651] = *I00651; sub I00651 { $pc = 000667; $inh = 0; goto &fetch; }
$core[000652] = 01366; $code[000652] = *I00652; sub I00652 { $lac += $core[000766]; goto &fetch; }
$core[000653] = 01375; $code[000653] = *I00653; sub I00653 { $lac += $core[000775]; goto &fetch; }
$core[000654] = 07630; $code[000654] = *I00654; sub I00654 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000655] = 05262; $code[000655] = *I00655; sub I00655 { $pc = 000662; $inh = 0; goto &fetch; }
$core[000656] = 01366; $code[000656] = *I00656; sub I00656 { $lac += $core[000766]; goto &fetch; }
$core[000657] = 01376; $code[000657] = *I00657; sub I00657 { $lac += $core[000776]; goto &fetch; }
$core[000660] = 07630; $code[000660] = *I00660; sub I00660 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000661] = 07040; $code[000661] = *I00661; sub I00661 { $lac ^= 07777; goto &fetch; }
$core[000662] = 01367; $code[000662] = *L00662; sub L00662 { $lac += $core[000767]; goto &fetch; }
$core[000663] = 03766; $code[000663] = *I00663; sub I00663 { $core[($df<<12)+$core[502]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[502]] = *emul8; goto &fetch; }
$core[000664] = 01370; $code[000664] = *I00664; sub I00664 { $lac += $core[000770]; goto &fetch; }
$core[000665] = 03767; $code[000665] = *I00665; sub I00665 { $core[($df<<12)+$core[503]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[503]] = *emul8; goto &fetch; }
$core[000666] = 05271; $code[000666] = *I00666; sub I00666 { $pc = 000671; $inh = 0; goto &fetch; }
$core[000667] = 01370; $code[000667] = *L00667; sub L00667 { $lac += $core[000770]; goto &fetch; }
$core[000670] = 03766; $code[000670] = *I00670; sub I00670 { $core[($df<<12)+$core[502]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[502]] = *emul8; goto &fetch; }
$core[000671] = 07300; $code[000671] = *L00671; sub L00671 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000672] = 01370; $code[000672] = *I00672; sub I00672 { $lac += $core[000770]; goto &fetch; }
$core[000673] = 07421; $code[000673] = *I00673; sub I00673 { &emul8; goto &fetch; }
$core[000674] = 01371; $code[000674] = *I00674; sub I00674 { $lac += $core[000771]; goto &fetch; }
$core[000675] = 04755; $code[000675] = *I00675; sub I00675 { $core[($ib<<12)+$core[493]] = 00676; $pc = ($ib<<12)+$core[493]+1; $code[($ib<<12)+$core[493]] = *emul8; $inh = 0; goto &fetch; }
$core[000676] = 03372; $code[000676] = *I00676; sub I00676 { $core[000772] = $lac & 07777; $lac &= 010000; $code[000772] = *emul8; goto &fetch; }
$core[000677] = 01356; $code[000677] = *I00677; sub I00677 { $lac += $core[000756]; goto &fetch; }
$core[000700] = 03000; $code[000700] = *I00700; sub I00700 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[000701] = 01364; $code[000701] = *I00701; sub I00701 { $lac += $core[000764]; goto &fetch; }
$core[000702] = 07001; $code[000702] = *I00702; sub I00702 { $lac++; goto &fetch; }
$core[000703] = 07450; $code[000703] = *I00703; sub I00703 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000704] = 05200; $code[000704] = *I00704; sub I00704 { $pc = 000600; $inh = 0; goto &fetch; }
$core[000705] = 03353; $code[000705] = *I00705; sub I00705 { $core[000753] = $lac & 07777; $lac &= 010000; $code[000753] = *emul8; goto &fetch; }
$core[000706] = 01373; $code[000706] = *I00706; sub I00706 { $lac += $core[000773]; goto &fetch; }
$core[000707] = 03753; $code[000707] = *I00707; sub I00707 { $core[($df<<12)+$core[491]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[491]] = *emul8; goto &fetch; }
$core[000710] = 01371; $code[000710] = *I00710; sub I00710 { $lac += $core[000771]; goto &fetch; }
$core[000711] = 05764; $code[000711] = *I00711; sub I00711 { $pc = ($ib<<12)+$core[500]; $inh = 0; goto &fetch; }
$core[000712] = 03377; $code[000712] = *I00712; sub I00712 { $core[000777] = $lac & 07777; $lac &= 010000; $code[000777] = *emul8; goto &fetch; }
$core[000713] = 07430; $code[000713] = *I00713; sub I00713 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[000714] = 04324; $code[000714] = *I00714; sub I00714 { $core[000724] = 00715; $pc = 000724+1; $code[000724] = *emul8; $inh = 0; goto &fetch; }
$core[000715] = 01372; $code[000715] = *I00715; sub I00715 { $lac += $core[000772]; goto &fetch; }
$core[000716] = 07041; $code[000716] = *I00716; sub I00716 { $lac ^= 07777; $lac++; goto &fetch; }
$core[000717] = 01377; $code[000717] = *I00717; sub I00717 { $lac += $core[000777]; goto &fetch; }
$core[000720] = 07640; $code[000720] = *I00720; sub I00720 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000721] = 04324; $code[000721] = *I00721; sub I00721 { $core[000724] = 00722; $pc = 000724+1; $code[000724] = *emul8; $inh = 0; goto &fetch; }
$core[000722] = 04760; $code[000722] = *I00722; sub I00722 { $core[($ib<<12)+$core[496]] = 00723; $pc = ($ib<<12)+$core[496]+1; $code[($ib<<12)+$core[496]] = *emul8; $inh = 0; goto &fetch; }
$core[000723] = 05200; $code[000723] = *I00723; sub I00723 { $pc = 000600; $inh = 0; goto &fetch; }
$core[000724] = 00000; $code[000724] = *S00724; sub S00724 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000725] = 07330; $code[000725] = *I00725; sub I00725 { $lac &= 010000; $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[000726] = 04757; $code[000726] = *I00726; sub I00726 { $core[($ib<<12)+$core[495]] = 00727; $pc = ($ib<<12)+$core[495]+1; $code[($ib<<12)+$core[495]] = *emul8; $inh = 0; goto &fetch; }
$core[000727] = 05351; $code[000727] = *I00727; sub I00727 { $pc = 000751; $inh = 0; goto &fetch; }
$core[000730] = 01370; $code[000730] = *I00730; sub I00730 { $lac += $core[000770]; goto &fetch; }
$core[000731] = 07402; $code[000731] = *I00731; sub I00731 { $hlt = 1; goto &fetch; }
$core[000732] = 07200; $code[000732] = *I00732; sub I00732 { $lac &= 010000; goto &fetch; }
$core[000733] = 01371; $code[000733] = *I00733; sub I00733 { $lac += $core[000771]; goto &fetch; }
$core[000734] = 07402; $code[000734] = *I00734; sub I00734 { $hlt = 1; goto &fetch; }
$core[000735] = 07200; $code[000735] = *I00735; sub I00735 { $lac &= 010000; goto &fetch; }
$core[000736] = 01001; $code[000736] = *I00736; sub I00736 { $lac += $core[000001]; goto &fetch; }
$core[000737] = 07402; $code[000737] = *I00737; sub I00737 { $hlt = 1; goto &fetch; }
$core[000740] = 07200; $code[000740] = *I00740; sub I00740 { $lac &= 010000; goto &fetch; }
$core[000741] = 01364; $code[000741] = *I00741; sub I00741 { $lac += $core[000764]; goto &fetch; }
$core[000742] = 07402; $code[000742] = *I00742; sub I00742 { $hlt = 1; goto &fetch; }
$core[000743] = 07200; $code[000743] = *I00743; sub I00743 { $lac &= 010000; goto &fetch; }
$core[000744] = 01366; $code[000744] = *I00744; sub I00744 { $lac += $core[000766]; goto &fetch; }
$core[000745] = 07402; $code[000745] = *I00745; sub I00745 { $hlt = 1; goto &fetch; }
$core[000746] = 07200; $code[000746] = *I00746; sub I00746 { $lac &= 010000; goto &fetch; }
$core[000747] = 01367; $code[000747] = *I00747; sub I00747 { $lac += $core[000767]; goto &fetch; }
$core[000750] = 07402; $code[000750] = *I00750; sub I00750 { $hlt = 1; goto &fetch; }
$core[000751] = 07300; $code[000751] = *L00751; sub L00751 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[000752] = 05724; $code[000752] = *I00752; sub I00752 { $pc = ($ib<<12)+$core[468]; $inh = 0; goto &fetch; }
$core[000753] = 00000; $code[000753] = *P00753; sub P00753 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000754] = 00000; $code[000754] = *P00754; sub P00754 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000755] = 00000; $code[000755] = *P00755; sub P00755 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000756] = 00000; $code[000756] = *D00756; sub D00756 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000757] = 00000; $code[000757] = *P00757; sub P00757 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000760] = 00000; $code[000760] = *P00760; sub P00760 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000761] = 00000; $code[000761] = *D00761; sub D00761 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000762] = 00000; $code[000762] = *D00762; sub D00762 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000763] = 00000; $code[000763] = *D00763; sub D00763 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000764] = 00000; $code[000764] = *P00764; sub P00764 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000765] = 00000; $code[000765] = *D00765; sub D00765 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000766] = 00000; $code[000766] = *P00766; sub P00766 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000767] = 00000; $code[000767] = *P00767; sub P00767 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000770] = 00021; $code[000770] = *D00770; sub D00770 { $lac &= (010000|$core[000021]); goto &fetch; }
$core[000771] = 00037; $code[000771] = *D00771; sub D00771 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[000772] = 00000; $code[000772] = *D00772; sub D00772 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000773] = 05400; $code[000773] = *D00773; sub D00773 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[000774] = 00003; $code[000774] = *D00774; sub D00774 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[000775] = 07760; $code[000775] = *D00775; sub D00775 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000776] = 07770; $code[000776] = *D00776; sub D00776 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[000777] = 00000; $code[000777] = *D00777; sub D00777 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001000] = 00000; $code[001000] = *P01000; sub P01000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001001] = 01367; $code[001001] = *L01001; sub L01001 { $lac += $core[001167]; goto &fetch; }
$core[001002] = 04340; $code[001002] = *I01002; sub I01002 { $core[001140] = 01003; $pc = 001140+1; $code[001140] = *emul8; $inh = 0; goto &fetch; }
$core[001003] = 03367; $code[001003] = *I01003; sub I01003 { $core[001167] = $lac & 07777; $lac &= 010000; $code[001167] = *emul8; goto &fetch; }
$core[001004] = 01367; $code[001004] = *I01004; sub I01004 { $lac += $core[001167]; goto &fetch; }
$core[001005] = 07421; $code[001005] = *I01005; sub I01005 { &emul8; goto &fetch; }
$core[001006] = 01007; $code[001006] = *I01006; sub I01006 { $lac += $core[000007]; goto &fetch; }
$core[001007] = 07501; $code[001007] = *I01007; sub I01007 { &emul8; goto &fetch; }
$core[001010] = 07421; $code[001010] = *I01010; sub I01010 { &emul8; goto &fetch; }
$core[001011] = 01371; $code[001011] = *I01011; sub I01011 { $lac += $core[001171]; goto &fetch; }
$core[001012] = 04400; $code[001012] = *I01012; sub I01012 { $core[($ib<<12)+$core[0]] = 01013; $pc = ($ib<<12)+$core[0]+1; $code[($ib<<12)+$core[0]] = *emul8; $inh = 0; goto &fetch; }
$core[001013] = 03001; $code[001013] = *I01013; sub I01013 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[001014] = 01001; $code[001014] = *I01014; sub I01014 { $lac += $core[000001]; goto &fetch; }
$core[001015] = 04354; $code[001015] = *I01015; sub I01015 { $core[001154] = 01016; $pc = 001154+1; $code[001154] = *emul8; $inh = 0; goto &fetch; }
$core[001016] = 03020; $code[001016] = *I01016; sub I01016 { $core[000020] = $lac & 07777; $lac &= 010000; $code[000020] = *emul8; goto &fetch; }
$core[001017] = 01372; $code[001017] = *L01017; sub L01017 { $lac += $core[001172]; goto &fetch; }
$core[001020] = 04340; $code[001020] = *I01020; sub I01020 { $core[001140] = 01021; $pc = 001140+1; $code[001140] = *emul8; $inh = 0; goto &fetch; }
$core[001021] = 03372; $code[001021] = *I01021; sub I01021 { $core[001172] = $lac & 07777; $lac &= 010000; $code[001172] = *emul8; goto &fetch; }
$core[001022] = 04345; $code[001022] = *I01022; sub I01022 { $core[001145] = 01023; $pc = 001145+1; $code[001145] = *emul8; $inh = 0; goto &fetch; }
$core[001023] = 01372; $code[001023] = *I01023; sub I01023 { $lac += $core[001172]; goto &fetch; }
$core[001024] = 07620; $code[001024] = *I01024; sub I01024 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001025] = 05217; $code[001025] = *I01025; sub I01025 { $pc = 001017; $inh = 0; goto &fetch; }
$core[001026] = 01372; $code[001026] = *I01026; sub I01026 { $lac += $core[001172]; goto &fetch; }
$core[001027] = 01373; $code[001027] = *I01027; sub I01027 { $lac += $core[001173]; goto &fetch; }
$core[001030] = 07620; $code[001030] = *I01030; sub I01030 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001031] = 05246; $code[001031] = *I01031; sub I01031 { $pc = 001046; $inh = 0; goto &fetch; }
$core[001032] = 01020; $code[001032] = *I01032; sub I01032 { $lac += $core[000020]; goto &fetch; }
$core[001033] = 07041; $code[001033] = *I01033; sub I01033 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001034] = 01372; $code[001034] = *I01034; sub I01034 { $lac += $core[001172]; goto &fetch; }
$core[001035] = 04361; $code[001035] = *L01035; sub L01035 { $core[001161] = 01036; $pc = 001161+1; $code[001161] = *emul8; $inh = 0; goto &fetch; }
$core[001036] = 07700; $code[001036] = *I01036; sub I01036 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001037] = 05217; $code[001037] = *I01037; sub I01037 { $pc = 001017; $inh = 0; goto &fetch; }
$core[001040] = 01020; $code[001040] = *L01040; sub L01040 { $lac += $core[000020]; goto &fetch; }
$core[001041] = 07650; $code[001041] = *I01041; sub I01041 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001042] = 05201; $code[001042] = *I01042; sub I01042 { $pc = 001001; $inh = 0; goto &fetch; }
$core[001043] = 01372; $code[001043] = *I01043; sub I01043 { $lac += $core[001172]; goto &fetch; }
$core[001044] = 03002; $code[001044] = *I01044; sub I01044 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[001045] = 05261; $code[001045] = *I01045; sub I01045 { $pc = 001061; $inh = 0; goto &fetch; }
$core[001046] = 01001; $code[001046] = *L01046; sub L01046 { $lac += $core[000001]; goto &fetch; }
$core[001047] = 07421; $code[001047] = *I01047; sub I01047 { &emul8; goto &fetch; }
$core[001050] = 01376; $code[001050] = *I01050; sub I01050 { $lac += $core[001176]; goto &fetch; }
$core[001051] = 04400; $code[001051] = *I01051; sub I01051 { $core[($ib<<12)+$core[0]] = 01052; $pc = ($ib<<12)+$core[0]+1; $code[($ib<<12)+$core[0]] = *emul8; $inh = 0; goto &fetch; }
$core[001052] = 07650; $code[001052] = *I01052; sub I01052 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001053] = 05240; $code[001053] = *I01053; sub I01053 { $pc = 001040; $inh = 0; goto &fetch; }
$core[001054] = 01372; $code[001054] = *I01054; sub I01054 { $lac += $core[001172]; goto &fetch; }
$core[001055] = 04354; $code[001055] = *I01055; sub I01055 { $core[001154] = 01056; $pc = 001154+1; $code[001154] = *emul8; $inh = 0; goto &fetch; }
$core[001056] = 07041; $code[001056] = *I01056; sub I01056 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001057] = 01020; $code[001057] = *I01057; sub I01057 { $lac += $core[000020]; goto &fetch; }
$core[001060] = 05235; $code[001060] = *I01060; sub I01060 { $pc = 001035; $inh = 0; goto &fetch; }
$core[001061] = 01001; $code[001061] = *L01061; sub L01061 { $lac += $core[000001]; goto &fetch; }
$core[001062] = 07421; $code[001062] = *I01062; sub I01062 { &emul8; goto &fetch; }
$core[001063] = 01376; $code[001063] = *I01063; sub I01063 { $lac += $core[001176]; goto &fetch; }
$core[001064] = 04400; $code[001064] = *I01064; sub I01064 { $core[($ib<<12)+$core[0]] = 01065; $pc = ($ib<<12)+$core[0]+1; $code[($ib<<12)+$core[0]] = *emul8; $inh = 0; goto &fetch; }
$core[001065] = 07650; $code[001065] = *I01065; sub I01065 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001066] = 05306; $code[001066] = *I01066; sub I01066 { $pc = 001106; $inh = 0; goto &fetch; }
$core[001067] = 01002; $code[001067] = *I01067; sub I01067 { $lac += $core[000002]; goto &fetch; }
$core[001070] = 07421; $code[001070] = *I01070; sub I01070 { &emul8; goto &fetch; }
$core[001071] = 01373; $code[001071] = *I01071; sub I01071 { $lac += $core[001173]; goto &fetch; }
$core[001072] = 04400; $code[001072] = *I01072; sub I01072 { $core[($ib<<12)+$core[0]] = 01073; $pc = ($ib<<12)+$core[0]+1; $code[($ib<<12)+$core[0]] = *emul8; $inh = 0; goto &fetch; }
$core[001073] = 07421; $code[001073] = *I01073; sub I01073 { &emul8; goto &fetch; }
$core[001074] = 01020; $code[001074] = *I01074; sub I01074 { $lac += $core[000020]; goto &fetch; }
$core[001075] = 07501; $code[001075] = *I01075; sub I01075 { &emul8; goto &fetch; }
$core[001076] = 03003; $code[001076] = *I01076; sub I01076 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[001077] = 01001; $code[001077] = *L01077; sub L01077 { $lac += $core[000001]; goto &fetch; }
$core[001100] = 07421; $code[001100] = *I01100; sub I01100 { &emul8; goto &fetch; }
$core[001101] = 01375; $code[001101] = *I01101; sub I01101 { $lac += $core[001175]; goto &fetch; }
$core[001102] = 04400; $code[001102] = *I01102; sub I01102 { $core[($ib<<12)+$core[0]] = 01103; $pc = ($ib<<12)+$core[0]+1; $code[($ib<<12)+$core[0]] = *emul8; $inh = 0; goto &fetch; }
$core[001103] = 07640; $code[001103] = *I01103; sub I01103 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001104] = 05311; $code[001104] = *I01104; sub I01104 { $pc = 001111; $inh = 0; goto &fetch; }
$core[001105] = 05600; $code[001105] = *I01105; sub I01105 { $pc = ($ib<<12)+$core[512]; $inh = 0; goto &fetch; }
$core[001106] = 01020; $code[001106] = *L01106; sub L01106 { $lac += $core[000020]; goto &fetch; }
$core[001107] = 03003; $code[001107] = *I01107; sub I01107 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[001110] = 05277; $code[001110] = *I01110; sub I01110 { $pc = 001077; $inh = 0; goto &fetch; }
$core[001111] = 01377; $code[001111] = *L01111; sub L01111 { $lac += $core[001177]; goto &fetch; }
$core[001112] = 04340; $code[001112] = *I01112; sub I01112 { $core[001140] = 01113; $pc = 001140+1; $code[001140] = *emul8; $inh = 0; goto &fetch; }
$core[001113] = 03377; $code[001113] = *I01113; sub I01113 { $core[001177] = $lac & 07777; $lac &= 010000; $code[001177] = *emul8; goto &fetch; }
$core[001114] = 04345; $code[001114] = *I01114; sub I01114 { $core[001145] = 01115; $pc = 001145+1; $code[001145] = *emul8; $inh = 0; goto &fetch; }
$core[001115] = 01377; $code[001115] = *I01115; sub I01115 { $lac += $core[001177]; goto &fetch; }
$core[001116] = 07620; $code[001116] = *I01116; sub I01116 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001117] = 05311; $code[001117] = *I01117; sub I01117 { $pc = 001111; $inh = 0; goto &fetch; }
$core[001120] = 01002; $code[001120] = *I01120; sub I01120 { $lac += $core[000002]; goto &fetch; }
$core[001121] = 07041; $code[001121] = *I01121; sub I01121 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001122] = 01377; $code[001122] = *I01122; sub I01122 { $lac += $core[001177]; goto &fetch; }
$core[001123] = 04361; $code[001123] = *I01123; sub I01123 { $core[001161] = 01124; $pc = 001161+1; $code[001161] = *emul8; $inh = 0; goto &fetch; }
$core[001124] = 07700; $code[001124] = *I01124; sub I01124 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001125] = 05311; $code[001125] = *I01125; sub I01125 { $pc = 001111; $inh = 0; goto &fetch; }
$core[001126] = 01003; $code[001126] = *I01126; sub I01126 { $lac += $core[000003]; goto &fetch; }
$core[001127] = 07041; $code[001127] = *I01127; sub I01127 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001130] = 01377; $code[001130] = *I01130; sub I01130 { $lac += $core[001177]; goto &fetch; }
$core[001131] = 04361; $code[001131] = *I01131; sub I01131 { $core[001161] = 01132; $pc = 001161+1; $code[001161] = *emul8; $inh = 0; goto &fetch; }
$core[001132] = 07700; $code[001132] = *I01132; sub I01132 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001133] = 05311; $code[001133] = *I01133; sub I01133 { $pc = 001111; $inh = 0; goto &fetch; }
$core[001134] = 01377; $code[001134] = *I01134; sub I01134 { $lac += $core[001177]; goto &fetch; }
$core[001135] = 03005; $code[001135] = *I01135; sub I01135 { $core[000005] = $lac & 07777; $lac &= 010000; $code[000005] = *emul8; goto &fetch; }
$core[001136] = 07040; $code[001136] = *I01136; sub I01136 { $lac ^= 07777; goto &fetch; }
$core[001137] = 05600; $code[001137] = *I01137; sub I01137 { $pc = ($ib<<12)+$core[512]; $inh = 0; goto &fetch; }
$core[001140] = 00000; $code[001140] = *S01140; sub S01140 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001141] = 07104; $code[001141] = *I01141; sub I01141 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[001142] = 07430; $code[001142] = *I01142; sub I01142 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[001143] = 01370; $code[001143] = *I01143; sub I01143 { $lac += $core[001170]; goto &fetch; }
$core[001144] = 05740; $code[001144] = *I01144; sub I01144 { $pc = ($ib<<12)+$core[608]; $inh = 0; goto &fetch; }
$core[001145] = 00000; $code[001145] = *S01145; sub S01145 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001146] = 01007; $code[001146] = *I01146; sub I01146 { $lac += $core[000007]; goto &fetch; }
$core[001147] = 07100; $code[001147] = *I01147; sub I01147 { $lac &= 07777; goto &fetch; }
$core[001150] = 07650; $code[001150] = *I01150; sub I01150 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[001151] = 07020; $code[001151] = *I01151; sub I01151 { $lac ^= 010000; goto &fetch; }
$core[001152] = 01006; $code[001152] = *I01152; sub I01152 { $lac += $core[000006]; goto &fetch; }
$core[001153] = 05745; $code[001153] = *I01153; sub I01153 { $pc = ($ib<<12)+$core[613]; $inh = 0; goto &fetch; }
$core[001154] = 00000; $code[001154] = *S01154; sub S01154 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001155] = 07421; $code[001155] = *I01155; sub I01155 { &emul8; goto &fetch; }
$core[001156] = 01374; $code[001156] = *I01156; sub I01156 { $lac += $core[001174]; goto &fetch; }
$core[001157] = 04400; $code[001157] = *I01157; sub I01157 { $core[($ib<<12)+$core[0]] = 01160; $pc = ($ib<<12)+$core[0]+1; $code[($ib<<12)+$core[0]] = *emul8; $inh = 0; goto &fetch; }
$core[001160] = 05754; $code[001160] = *I01160; sub I01160 { $pc = ($ib<<12)+$core[620]; $inh = 0; goto &fetch; }
$core[001161] = 00000; $code[001161] = *S01161; sub S01161 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[001162] = 07500; $code[001162] = *I01162; sub I01162 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[001163] = 07041; $code[001163] = *I01163; sub I01163 { $lac ^= 07777; $lac++; goto &fetch; }
$core[001164] = 07001; $code[001164] = *I01164; sub I01164 { $lac++; goto &fetch; }
$core[001165] = 07001; $code[001165] = *I01165; sub I01165 { $lac++; goto &fetch; }
$core[001166] = 05761; $code[001166] = *I01166; sub I01166 { $pc = ($ib<<12)+$core[625]; $inh = 0; goto &fetch; }
$core[001167] = 00001; $code[001167] = *D01167; sub D01167 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[001170] = 00003; $code[001170] = *D01170; sub D01170 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[001171] = 00777; $code[001171] = *D01171; sub D01171 { $lac &= (010000|$core[($df<<12)+$core[639]]); goto &fetch; }
$core[001172] = 00005; $code[001172] = *D01172; sub D01172 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[001173] = 07600; $code[001173] = *D01173; sub D01173 { $lac &= 010000; goto &fetch; }
$core[001174] = 00177; $code[001174] = *D01174; sub D01174 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[001175] = 00400; $code[001175] = *D01175; sub D01175 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[001176] = 00200; $code[001176] = *D01176; sub D01176 { $lac &= (010000|$core[001000]); goto &fetch; }
$core[001177] = 00015; $code[001177] = *P01177; sub P01177 { $lac &= (010000|$core[000015]); goto &fetch; }
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

