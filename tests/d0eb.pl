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
$core[000004] = 00000; $code[000004] = *D00004; sub D00004 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000005] = 00000; $code[000005] = *D00005; sub D00005 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[000200] = 06007; $code[000200] = *I00200; sub I00200 { &emul8; goto &fetch; }
$core[000201] = 05602; $code[000201] = *I00201; sub I00201 { $pc = ($ib<<12)+$core[130]; $inh = 0; goto &fetch; }
$core[000202] = 06600; $code[000202] = *P00202; sub P00202 { &emul8; goto &fetch; }
$core[006600] = 07300; $code[006600] = *L06600; sub L06600 { $lac &= 010000; $lac &= 07777; goto &fetch; }
$core[006601] = 03376; $code[006601] = *I06601; sub I06601 { $core[006776] = $lac & 07777; $lac &= 010000; $code[006776] = *emul8; goto &fetch; }
$core[006602] = 07604; $code[006602] = *L06602; sub L06602 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006603] = 00371; $code[006603] = *I06603; sub I06603 { $lac &= (010000|$core[006771]); goto &fetch; }
$core[006604] = 07640; $code[006604] = *I06604; sub I06604 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006605] = 05224; $code[006605] = *I06605; sub I06605 { $pc = 006624; $inh = 0; goto &fetch; }
$core[006606] = 04746; $code[006606] = *I06606; sub I06606 { $core[($ib<<12)+$core[3558]] = 06607; $pc = ($ib<<12)+$core[3558]+1; $code[($ib<<12)+$core[3558]] = *emul8; $inh = 0; goto &fetch; }
$core[006607] = 03355; $code[006607] = *I06607; sub I06607 { $core[006755] = $lac & 07777; $lac &= 010000; $code[006755] = *emul8; goto &fetch; }
$core[006610] = 07040; $code[006610] = *I06610; sub I06610 { $lac ^= 07777; goto &fetch; }
$core[006611] = 00001; $code[006611] = *I06611; sub I06611 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[006612] = 03353; $code[006612] = *I06612; sub I06612 { $core[006753] = $lac & 07777; $lac &= 010000; $code[006753] = *emul8; goto &fetch; }
$core[006613] = 07040; $code[006613] = *I06613; sub I06613 { $lac ^= 07777; goto &fetch; }
$core[006614] = 00002; $code[006614] = *I06614; sub I06614 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[006615] = 03354; $code[006615] = *I06615; sub I06615 { $core[006754] = $lac & 07777; $lac &= 010000; $code[006754] = *emul8; goto &fetch; }
$core[006616] = 07040; $code[006616] = *I06616; sub I06616 { $lac ^= 07777; goto &fetch; }
$core[006617] = 00003; $code[006617] = *I06617; sub I06617 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[006620] = 03356; $code[006620] = *I06620; sub I06620 { $core[006756] = $lac & 07777; $lac &= 010000; $code[006756] = *emul8; goto &fetch; }
$core[006621] = 07040; $code[006621] = *I06621; sub I06621 { $lac ^= 07777; goto &fetch; }
$core[006622] = 00004; $code[006622] = *I06622; sub I06622 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[006623] = 03357; $code[006623] = *I06623; sub I06623 { $core[006757] = $lac & 07777; $lac &= 010000; $code[006757] = *emul8; goto &fetch; }
$core[006624] = 07604; $code[006624] = *L06624; sub L06624 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006625] = 00372; $code[006625] = *I06625; sub I06625 { $lac &= (010000|$core[006772]); goto &fetch; }
$core[006626] = 07640; $code[006626] = *I06626; sub I06626 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006627] = 05234; $code[006627] = *I06627; sub I06627 { $pc = 006634; $inh = 0; goto &fetch; }
$core[006630] = 07040; $code[006630] = *I06630; sub I06630 { $lac ^= 07777; goto &fetch; }
$core[006631] = 00360; $code[006631] = *I06631; sub I06631 { $lac &= (010000|$core[006760]); goto &fetch; }
$core[006632] = 04752; $code[006632] = *I06632; sub I06632 { $core[($ib<<12)+$core[3562]] = 06633; $pc = ($ib<<12)+$core[3562]+1; $code[($ib<<12)+$core[3562]] = *emul8; $inh = 0; goto &fetch; }
$core[006633] = 03360; $code[006633] = *I06633; sub I06633 { $core[006760] = $lac & 07777; $lac &= 010000; $code[006760] = *emul8; goto &fetch; }
$core[006634] = 07604; $code[006634] = *L06634; sub L06634 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[006635] = 00373; $code[006635] = *I06635; sub I06635 { $lac &= (010000|$core[006773]); goto &fetch; }
$core[006636] = 07640; $code[006636] = *I06636; sub I06636 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006637] = 05244; $code[006637] = *I06637; sub I06637 { $pc = 006644; $inh = 0; goto &fetch; }
$core[006640] = 07040; $code[006640] = *I06640; sub I06640 { $lac ^= 07777; goto &fetch; }
$core[006641] = 00361; $code[006641] = *I06641; sub I06641 { $lac &= (010000|$core[006761]); goto &fetch; }
$core[006642] = 04752; $code[006642] = *I06642; sub I06642 { $core[($ib<<12)+$core[3562]] = 06643; $pc = ($ib<<12)+$core[3562]+1; $code[($ib<<12)+$core[3562]] = *emul8; $inh = 0; goto &fetch; }
$core[006643] = 03361; $code[006643] = *I06643; sub I06643 { $core[006761] = $lac & 07777; $lac &= 010000; $code[006761] = *emul8; goto &fetch; }
$core[006644] = 07340; $code[006644] = *L06644; sub L06644 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006645] = 00353; $code[006645] = *I06645; sub I06645 { $lac &= (010000|$core[006753]); goto &fetch; }
$core[006646] = 03754; $code[006646] = *I06646; sub I06646 { $core[($df<<12)+$core[3564]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3564]] = *emul8; goto &fetch; }
$core[006647] = 07040; $code[006647] = *I06647; sub I06647 { $lac ^= 07777; goto &fetch; }
$core[006650] = 00355; $code[006650] = *I06650; sub I06650 { $lac &= (010000|$core[006755]); goto &fetch; }
$core[006651] = 07650; $code[006651] = *I06651; sub I06651 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006652] = 05302; $code[006652] = *I06652; sub I06652 { $pc = 006702; $inh = 0; goto &fetch; }
$core[006653] = 07040; $code[006653] = *I06653; sub I06653 { $lac ^= 07777; goto &fetch; }
$core[006654] = 00356; $code[006654] = *I06654; sub I06654 { $lac &= (010000|$core[006756]); goto &fetch; }
$core[006655] = 00367; $code[006655] = *I06655; sub I06655 { $lac &= (010000|$core[006767]); goto &fetch; }
$core[006656] = 07640; $code[006656] = *I06656; sub I06656 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006657] = 05276; $code[006657] = *I06657; sub I06657 { $pc = 006676; $inh = 0; goto &fetch; }
$core[006660] = 07040; $code[006660] = *I06660; sub I06660 { $lac ^= 07777; goto &fetch; }
$core[006661] = 00356; $code[006661] = *I06661; sub I06661 { $lac &= (010000|$core[006756]); goto &fetch; }
$core[006662] = 00375; $code[006662] = *I06662; sub I06662 { $lac &= (010000|$core[006775]); goto &fetch; }
$core[006663] = 07650; $code[006663] = *I06663; sub I06663 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006664] = 05276; $code[006664] = *I06664; sub I06664 { $pc = 006676; $inh = 0; goto &fetch; }
$core[006665] = 07040; $code[006665] = *I06665; sub I06665 { $lac ^= 07777; goto &fetch; }
$core[006666] = 00357; $code[006666] = *I06666; sub I06666 { $lac &= (010000|$core[006757]); goto &fetch; }
$core[006667] = 07041; $code[006667] = *I06667; sub I06667 { $lac ^= 07777; $lac++; goto &fetch; }
$core[006670] = 07040; $code[006670] = *I06670; sub I06670 { $lac ^= 07777; goto &fetch; }
$core[006671] = 03756; $code[006671] = *I06671; sub I06671 { $core[($df<<12)+$core[3566]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3566]] = *emul8; goto &fetch; }
$core[006672] = 07040; $code[006672] = *L06672; sub L06672 { $lac ^= 07777; goto &fetch; }
$core[006673] = 00360; $code[006673] = *I06673; sub I06673 { $lac &= (010000|$core[006760]); goto &fetch; }
$core[006674] = 03757; $code[006674] = *I06674; sub I06674 { $core[($df<<12)+$core[3567]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3567]] = *emul8; goto &fetch; }
$core[006675] = 05305; $code[006675] = *I06675; sub I06675 { $pc = 006705; $inh = 0; goto &fetch; }
$core[006676] = 07040; $code[006676] = *L06676; sub L06676 { $lac ^= 07777; goto &fetch; }
$core[006677] = 00357; $code[006677] = *I06677; sub I06677 { $lac &= (010000|$core[006757]); goto &fetch; }
$core[006700] = 03756; $code[006700] = *I06700; sub I06700 { $core[($df<<12)+$core[3566]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3566]] = *emul8; goto &fetch; }
$core[006701] = 05272; $code[006701] = *I06701; sub I06701 { $pc = 006672; $inh = 0; goto &fetch; }
$core[006702] = 07040; $code[006702] = *L06702; sub L06702 { $lac ^= 07777; goto &fetch; }
$core[006703] = 00360; $code[006703] = *I06703; sub I06703 { $lac &= (010000|$core[006760]); goto &fetch; }
$core[006704] = 03756; $code[006704] = *I06704; sub I06704 { $core[($df<<12)+$core[3566]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3566]] = *emul8; goto &fetch; }
$core[006705] = 07340; $code[006705] = *L06705; sub L06705 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006706] = 00360; $code[006706] = *I06706; sub I06706 { $lac &= (010000|$core[006760]); goto &fetch; }
$core[006707] = 07421; $code[006707] = *I06707; sub I06707 { &emul8; goto &fetch; }
$core[006710] = 07040; $code[006710] = *I06710; sub I06710 { $lac ^= 07777; goto &fetch; }
$core[006711] = 00361; $code[006711] = *I06711; sub I06711 { $lac &= (010000|$core[006761]); goto &fetch; }
$core[006712] = 04751; $code[006712] = *I06712; sub I06712 { $core[($ib<<12)+$core[3561]] = 06713; $pc = ($ib<<12)+$core[3561]+1; $code[($ib<<12)+$core[3561]] = *emul8; $inh = 0; goto &fetch; }
$core[006713] = 03363; $code[006713] = *I06713; sub I06713 { $core[006763] = $lac & 07777; $lac &= 010000; $code[006763] = *emul8; goto &fetch; }
$core[006714] = 07010; $code[006714] = *I06714; sub I06714 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006715] = 03362; $code[006715] = *I06715; sub I06715 { $core[006762] = $lac & 07777; $lac &= 010000; $code[006762] = *emul8; goto &fetch; }
$core[006716] = 07040; $code[006716] = *I06716; sub I06716 { $lac ^= 07777; goto &fetch; }
$core[006717] = 00347; $code[006717] = *I06717; sub I06717 { $lac &= (010000|$core[006747]); goto &fetch; }
$core[006720] = 03000; $code[006720] = *I06720; sub I06720 { $core[000000] = $lac & 07777; $lac &= 010000; $code[000000] = *emul8; goto &fetch; }
$core[006721] = 07040; $code[006721] = *I06721; sub I06721 { $lac ^= 07777; goto &fetch; }
$core[006722] = 00354; $code[006722] = *I06722; sub I06722 { $lac &= (010000|$core[006754]); goto &fetch; }
$core[006723] = 07001; $code[006723] = *I06723; sub I06723 { $lac++; goto &fetch; }
$core[006724] = 07450; $code[006724] = *I06724; sub I06724 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006725] = 05202; $code[006725] = *I06725; sub I06725 { $pc = 006602; $inh = 0; goto &fetch; }
$core[006726] = 03345; $code[006726] = *I06726; sub I06726 { $core[006745] = $lac & 07777; $lac &= 010000; $code[006745] = *emul8; goto &fetch; }
$core[006727] = 07040; $code[006727] = *I06727; sub I06727 { $lac ^= 07777; goto &fetch; }
$core[006730] = 00366; $code[006730] = *I06730; sub I06730 { $lac &= (010000|$core[006766]); goto &fetch; }
$core[006731] = 03745; $code[006731] = *I06731; sub I06731 { $core[($df<<12)+$core[3557]] = $lac & 07777; $lac &= 010000; $code[($df<<12)+$core[3557]] = *emul8; goto &fetch; }
$core[006732] = 07140; $code[006732] = *I06732; sub I06732 { $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[006733] = 00361; $code[006733] = *I06733; sub I06733 { $lac &= (010000|$core[006761]); goto &fetch; }
$core[006734] = 05754; $code[006734] = *I06734; sub I06734 { $pc = ($ib<<12)+$core[3564]; $inh = 0; goto &fetch; }
$core[006735] = 03364; $code[006735] = *I06735; sub I06735 { $core[006764] = $lac & 07777; $lac &= 010000; $code[006764] = *emul8; goto &fetch; }
$core[006736] = 07010; $code[006736] = *I06736; sub I06736 { $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[006737] = 03365; $code[006737] = *I06737; sub I06737 { $core[006765] = $lac & 07777; $lac &= 010000; $code[006765] = *emul8; goto &fetch; }
$core[006740] = 04774; $code[006740] = *I06740; sub I06740 { $core[($ib<<12)+$core[3580]] = 06741; $pc = ($ib<<12)+$core[3580]+1; $code[($ib<<12)+$core[3580]] = *emul8; $inh = 0; goto &fetch; }
$core[006741] = 02376; $code[006741] = *I06741; sub I06741 { if (++$core[006776] == 010000) { $core[006776] = 0; $pc++; }$code[006776] = *emul8; goto &fetch; }
$core[006742] = 05202; $code[006742] = *I06742; sub I06742 { $pc = 006602; $inh = 0; goto &fetch; }
$core[006743] = 04750; $code[006743] = *I06743; sub I06743 { $core[($ib<<12)+$core[3560]] = 06744; $pc = ($ib<<12)+$core[3560]+1; $code[($ib<<12)+$core[3560]] = *emul8; $inh = 0; goto &fetch; }
$core[006744] = 05202; $code[006744] = *I06744; sub I06744 { $pc = 006602; $inh = 0; goto &fetch; }
$core[006745] = 00000; $code[006745] = *P06745; sub P06745 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006746] = 07000; $code[006746] = *P06746; sub P06746 { goto &fetch; }
$core[006747] = 06735; $code[006747] = *D06747; sub D06747 { &emul8; goto &fetch; }
$core[006750] = 07442; $code[006750] = *P06750; sub P06750 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $hlt = 1; goto &fetch; }
$core[006751] = 07200; $code[006751] = *P06751; sub P06751 { $lac &= 010000; goto &fetch; }
$core[006752] = 07430; $code[006752] = *P06752; sub P06752 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[006753] = 00000; $code[006753] = *D06753; sub D06753 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006754] = 00000; $code[006754] = *P06754; sub P06754 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006755] = 00000; $code[006755] = *D06755; sub D06755 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006756] = 00000; $code[006756] = *P06756; sub P06756 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006757] = 00000; $code[006757] = *P06757; sub P06757 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006760] = 00021; $code[006760] = *D06760; sub D06760 { $lac &= (010000|$core[000021]); goto &fetch; }
$core[006761] = 00037; $code[006761] = *D06761; sub D06761 { $lac &= (010000|$core[000037]); goto &fetch; }
$core[006762] = 00000; $code[006762] = *D06762; sub D06762 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006763] = 00000; $code[006763] = *D06763; sub D06763 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006764] = 00000; $code[006764] = *D06764; sub D06764 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006765] = 00000; $code[006765] = *D06765; sub D06765 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[006766] = 05400; $code[006766] = *D06766; sub D06766 { $pc = ($ib<<12)+$core[0]; $inh = 0; goto &fetch; }
$core[006767] = 07760; $code[006767] = *D06767; sub D06767 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006770] = 07770; $code[006770] = *I06770; sub I06770 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&04000; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[006771] = 00001; $code[006771] = *D06771; sub D06771 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[006772] = 00002; $code[006772] = *D06772; sub D06772 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[006773] = 00004; $code[006773] = *D06773; sub D06773 { $lac &= (010000|$core[000004]); goto &fetch; }
$core[006774] = 07313; $code[006774] = *P06774; sub P06774 { $lac &= 010000; $lac &= 07777; $lac++; $lac = (($lac&017777)>>2) + (($lac&3)<<11); goto &fetch; }
$core[006775] = 00010; $code[006775] = *D06775; sub D06775 { $lac &= (010000|$core[000010]); goto &fetch; }
$core[006776] = 00000; $code[006776] = *D06776; sub D06776 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007000] = 00000; $code[007000] = *S07000; sub S07000 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007001] = 07040; $code[007001] = *L07001; sub L07001 { $lac ^= 07777; goto &fetch; }
$core[007002] = 00350; $code[007002] = *I07002; sub I07002 { $lac &= (010000|$core[007150]); goto &fetch; }
$core[007003] = 04762; $code[007003] = *I07003; sub I07003 { $core[($ib<<12)+$core[3698]] = 07004; $pc = ($ib<<12)+$core[3698]+1; $code[($ib<<12)+$core[3698]] = *emul8; $inh = 0; goto &fetch; }
$core[007004] = 03350; $code[007004] = *I07004; sub I07004 { $core[007150] = $lac & 07777; $lac &= 010000; $code[007150] = *emul8; goto &fetch; }
$core[007005] = 07040; $code[007005] = *I07005; sub I07005 { $lac ^= 07777; goto &fetch; }
$core[007006] = 00350; $code[007006] = *I07006; sub I07006 { $lac &= (010000|$core[007150]); goto &fetch; }
$core[007007] = 07421; $code[007007] = *I07007; sub I07007 { &emul8; goto &fetch; }
$core[007010] = 07040; $code[007010] = *I07010; sub I07010 { $lac ^= 07777; goto &fetch; }
$core[007011] = 00365; $code[007011] = *I07011; sub I07011 { $lac &= (010000|$core[007165]); goto &fetch; }
$core[007012] = 07501; $code[007012] = *I07012; sub I07012 { &emul8; goto &fetch; }
$core[007013] = 00352; $code[007013] = *I07013; sub I07013 { $lac &= (010000|$core[007152]); goto &fetch; }
$core[007014] = 03001; $code[007014] = *I07014; sub I07014 { $core[000001] = $lac & 07777; $lac &= 010000; $code[000001] = *emul8; goto &fetch; }
$core[007015] = 07040; $code[007015] = *I07015; sub I07015 { $lac ^= 07777; goto &fetch; }
$core[007016] = 00001; $code[007016] = *I07016; sub I07016 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007017] = 00355; $code[007017] = *I07017; sub I07017 { $lac &= (010000|$core[007155]); goto &fetch; }
$core[007020] = 03361; $code[007020] = *I07020; sub I07020 { $core[007161] = $lac & 07777; $lac &= 010000; $code[007161] = *emul8; goto &fetch; }
$core[007021] = 07040; $code[007021] = *L07021; sub L07021 { $lac ^= 07777; goto &fetch; }
$core[007022] = 00353; $code[007022] = *I07022; sub I07022 { $lac &= (010000|$core[007153]); goto &fetch; }
$core[007023] = 04762; $code[007023] = *I07023; sub I07023 { $core[($ib<<12)+$core[3698]] = 07024; $pc = ($ib<<12)+$core[3698]+1; $code[($ib<<12)+$core[3698]] = *emul8; $inh = 0; goto &fetch; }
$core[007024] = 03353; $code[007024] = *I07024; sub I07024 { $core[007153] = $lac & 07777; $lac &= 010000; $code[007153] = *emul8; goto &fetch; }
$core[007025] = 07040; $code[007025] = *I07025; sub I07025 { $lac ^= 07777; goto &fetch; }
$core[007026] = 00353; $code[007026] = *I07026; sub I07026 { $lac &= (010000|$core[007153]); goto &fetch; }
$core[007027] = 04777; $code[007027] = *I07027; sub I07027 { $core[($ib<<12)+$core[3711]] = 07030; $pc = ($ib<<12)+$core[3711]+1; $code[($ib<<12)+$core[3711]] = *emul8; $inh = 0; goto &fetch; }
$core[007030] = 05221; $code[007030] = *I07030; sub I07030 { $pc = 007021; $inh = 0; goto &fetch; }
$core[007031] = 07040; $code[007031] = *I07031; sub I07031 { $lac ^= 07777; goto &fetch; }
$core[007032] = 00353; $code[007032] = *I07032; sub I07032 { $lac &= (010000|$core[007153]); goto &fetch; }
$core[007033] = 00354; $code[007033] = *I07033; sub I07033 { $lac &= (010000|$core[007154]); goto &fetch; }
$core[007034] = 07640; $code[007034] = *I07034; sub I07034 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007035] = 05244; $code[007035] = *I07035; sub I07035 { $pc = 007044; $inh = 0; goto &fetch; }
$core[007036] = 07040; $code[007036] = *I07036; sub I07036 { $lac ^= 07777; goto &fetch; }
$core[007037] = 00353; $code[007037] = *I07037; sub I07037 { $lac &= (010000|$core[007153]); goto &fetch; }
$core[007040] = 04776; $code[007040] = *L07040; sub L07040 { $core[($ib<<12)+$core[3710]] = 07041; $pc = ($ib<<12)+$core[3710]+1; $code[($ib<<12)+$core[3710]] = *emul8; $inh = 0; goto &fetch; }
$core[007041] = 07700; $code[007041] = *I07041; sub I07041 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007042] = 05221; $code[007042] = *I07042; sub I07042 { $pc = 007021; $inh = 0; goto &fetch; }
$core[007043] = 05255; $code[007043] = *I07043; sub I07043 { $pc = 007055; $inh = 0; goto &fetch; }
$core[007044] = 07040; $code[007044] = *L07044; sub L07044 { $lac ^= 07777; goto &fetch; }
$core[007045] = 00001; $code[007045] = *I07045; sub I07045 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007046] = 00357; $code[007046] = *I07046; sub I07046 { $lac &= (010000|$core[007157]); goto &fetch; }
$core[007047] = 07650; $code[007047] = *I07047; sub I07047 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007050] = 05255; $code[007050] = *I07050; sub I07050 { $pc = 007055; $inh = 0; goto &fetch; }
$core[007051] = 07040; $code[007051] = *I07051; sub I07051 { $lac ^= 07777; goto &fetch; }
$core[007052] = 00353; $code[007052] = *I07052; sub I07052 { $lac &= (010000|$core[007153]); goto &fetch; }
$core[007053] = 00355; $code[007053] = *I07053; sub I07053 { $lac &= (010000|$core[007155]); goto &fetch; }
$core[007054] = 05240; $code[007054] = *I07054; sub I07054 { $pc = 007040; $inh = 0; goto &fetch; }
$core[007055] = 07040; $code[007055] = *L07055; sub L07055 { $lac ^= 07777; goto &fetch; }
$core[007056] = 00361; $code[007056] = *I07056; sub I07056 { $lac &= (010000|$core[007161]); goto &fetch; }
$core[007057] = 07650; $code[007057] = *I07057; sub I07057 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007060] = 05201; $code[007060] = *I07060; sub I07060 { $pc = 007001; $inh = 0; goto &fetch; }
$core[007061] = 07040; $code[007061] = *I07061; sub I07061 { $lac ^= 07777; goto &fetch; }
$core[007062] = 00353; $code[007062] = *I07062; sub I07062 { $lac &= (010000|$core[007153]); goto &fetch; }
$core[007063] = 03002; $code[007063] = *I07063; sub I07063 { $core[000002] = $lac & 07777; $lac &= 010000; $code[000002] = *emul8; goto &fetch; }
$core[007064] = 07040; $code[007064] = *I07064; sub I07064 { $lac ^= 07777; goto &fetch; }
$core[007065] = 00001; $code[007065] = *I07065; sub I07065 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007066] = 00357; $code[007066] = *I07066; sub I07066 { $lac &= (010000|$core[007157]); goto &fetch; }
$core[007067] = 07650; $code[007067] = *I07067; sub I07067 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007070] = 05307; $code[007070] = *I07070; sub I07070 { $pc = 007107; $inh = 0; goto &fetch; }
$core[007071] = 07040; $code[007071] = *I07071; sub I07071 { $lac ^= 07777; goto &fetch; }
$core[007072] = 00002; $code[007072] = *I07072; sub I07072 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[007073] = 00354; $code[007073] = *I07073; sub I07073 { $lac &= (010000|$core[007154]); goto &fetch; }
$core[007074] = 07421; $code[007074] = *I07074; sub I07074 { &emul8; goto &fetch; }
$core[007075] = 07040; $code[007075] = *I07075; sub I07075 { $lac ^= 07777; goto &fetch; }
$core[007076] = 00361; $code[007076] = *I07076; sub I07076 { $lac &= (010000|$core[007161]); goto &fetch; }
$core[007077] = 07501; $code[007077] = *I07077; sub I07077 { &emul8; goto &fetch; }
$core[007100] = 03003; $code[007100] = *I07100; sub I07100 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[007101] = 07040; $code[007101] = *L07101; sub L07101 { $lac ^= 07777; goto &fetch; }
$core[007102] = 00001; $code[007102] = *I07102; sub I07102 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007103] = 00356; $code[007103] = *I07103; sub I07103 { $lac &= (010000|$core[007156]); goto &fetch; }
$core[007104] = 07640; $code[007104] = *I07104; sub I07104 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007105] = 05313; $code[007105] = *I07105; sub I07105 { $pc = 007113; $inh = 0; goto &fetch; }
$core[007106] = 05600; $code[007106] = *I07106; sub I07106 { $pc = ($ib<<12)+$core[3584]; $inh = 0; goto &fetch; }
$core[007107] = 07040; $code[007107] = *L07107; sub L07107 { $lac ^= 07777; goto &fetch; }
$core[007110] = 00361; $code[007110] = *I07110; sub I07110 { $lac &= (010000|$core[007161]); goto &fetch; }
$core[007111] = 03003; $code[007111] = *I07111; sub I07111 { $core[000003] = $lac & 07777; $lac &= 010000; $code[000003] = *emul8; goto &fetch; }
$core[007112] = 05301; $code[007112] = *I07112; sub I07112 { $pc = 007101; $inh = 0; goto &fetch; }
$core[007113] = 07040; $code[007113] = *L07113; sub L07113 { $lac ^= 07777; goto &fetch; }
$core[007114] = 00360; $code[007114] = *I07114; sub I07114 { $lac &= (010000|$core[007160]); goto &fetch; }
$core[007115] = 04762; $code[007115] = *I07115; sub I07115 { $core[($ib<<12)+$core[3698]] = 07116; $pc = ($ib<<12)+$core[3698]+1; $code[($ib<<12)+$core[3698]] = *emul8; $inh = 0; goto &fetch; }
$core[007116] = 03360; $code[007116] = *I07116; sub I07116 { $core[007160] = $lac & 07777; $lac &= 010000; $code[007160] = *emul8; goto &fetch; }
$core[007117] = 07040; $code[007117] = *I07117; sub I07117 { $lac ^= 07777; goto &fetch; }
$core[007120] = 00360; $code[007120] = *I07120; sub I07120 { $lac &= (010000|$core[007160]); goto &fetch; }
$core[007121] = 04777; $code[007121] = *I07121; sub I07121 { $core[($ib<<12)+$core[3711]] = 07122; $pc = ($ib<<12)+$core[3711]+1; $code[($ib<<12)+$core[3711]] = *emul8; $inh = 0; goto &fetch; }
$core[007122] = 05313; $code[007122] = *I07122; sub I07122 { $pc = 007113; $inh = 0; goto &fetch; }
$core[007123] = 07040; $code[007123] = *I07123; sub I07123 { $lac ^= 07777; goto &fetch; }
$core[007124] = 00002; $code[007124] = *I07124; sub I07124 { $lac &= (010000|$core[000002]); goto &fetch; }
$core[007125] = 04775; $code[007125] = *I07125; sub I07125 { $core[($ib<<12)+$core[3709]] = 07126; $pc = ($ib<<12)+$core[3709]+1; $code[($ib<<12)+$core[3709]] = *emul8; $inh = 0; goto &fetch; }
$core[007126] = 07700; $code[007126] = *I07126; sub I07126 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007127] = 05313; $code[007127] = *I07127; sub I07127 { $pc = 007113; $inh = 0; goto &fetch; }
$core[007130] = 07040; $code[007130] = *I07130; sub I07130 { $lac ^= 07777; goto &fetch; }
$core[007131] = 00003; $code[007131] = *I07131; sub I07131 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[007132] = 04775; $code[007132] = *I07132; sub I07132 { $core[($ib<<12)+$core[3709]] = 07133; $pc = ($ib<<12)+$core[3709]+1; $code[($ib<<12)+$core[3709]] = *emul8; $inh = 0; goto &fetch; }
$core[007133] = 07700; $code[007133] = *I07133; sub I07133 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007134] = 05313; $code[007134] = *I07134; sub I07134 { $pc = 007113; $inh = 0; goto &fetch; }
$core[007135] = 07040; $code[007135] = *I07135; sub I07135 { $lac ^= 07777; goto &fetch; }
$core[007136] = 00360; $code[007136] = *I07136; sub I07136 { $lac &= (010000|$core[007160]); goto &fetch; }
$core[007137] = 07041; $code[007137] = *I07137; sub I07137 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007140] = 07040; $code[007140] = *I07140; sub I07140 { $lac ^= 07777; goto &fetch; }
$core[007141] = 07650; $code[007141] = *I07141; sub I07141 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007142] = 05313; $code[007142] = *I07142; sub I07142 { $pc = 007113; $inh = 0; goto &fetch; }
$core[007143] = 07040; $code[007143] = *I07143; sub I07143 { $lac ^= 07777; goto &fetch; }
$core[007144] = 00360; $code[007144] = *I07144; sub I07144 { $lac &= (010000|$core[007160]); goto &fetch; }
$core[007145] = 03004; $code[007145] = *I07145; sub I07145 { $core[000004] = $lac & 07777; $lac &= 010000; $code[000004] = *emul8; goto &fetch; }
$core[007146] = 07040; $code[007146] = *I07146; sub I07146 { $lac ^= 07777; goto &fetch; }
$core[007147] = 05600; $code[007147] = *I07147; sub I07147 { $pc = ($ib<<12)+$core[3584]; $inh = 0; goto &fetch; }
$core[007150] = 00001; $code[007150] = *D07150; sub D07150 { $lac &= (010000|$core[000001]); goto &fetch; }
$core[007151] = 00003; $code[007151] = *I07151; sub I07151 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[007152] = 01777; $code[007152] = *D07152; sub D07152 { $lac += $core[($df<<12)+$core[3711]]; goto &fetch; }
$core[007153] = 00005; $code[007153] = *D07153; sub D07153 { $lac &= (010000|$core[000005]); goto &fetch; }
$core[007154] = 07600; $code[007154] = *D07154; sub D07154 { $lac &= 010000; goto &fetch; }
$core[007155] = 00177; $code[007155] = *D07155; sub D07155 { $lac &= (010000|$core[000177]); goto &fetch; }
$core[007156] = 00400; $code[007156] = *D07156; sub D07156 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[007157] = 00200; $code[007157] = *D07157; sub D07157 { $lac &= (010000|$core[007000]); goto &fetch; }
$core[007160] = 00015; $code[007160] = *D07160; sub D07160 { $lac &= (010000|$core[000015]); goto &fetch; }
$core[007161] = 00000; $code[007161] = *D07161; sub D07161 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007162] = 07430; $code[007162] = *P07162; sub P07162 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007163] = 07200; $code[007163] = *I07163; sub I07163 { $lac &= 010000; goto &fetch; }
$core[007164] = 01201; $code[007164] = *D07164; sub D07164 { $lac += $core[007001]; goto &fetch; }
$core[007165] = 01000; $code[007165] = *D07165; sub D07165 { $lac += $core[000000]; goto &fetch; }
$core[007175] = 07507; $code[007175] = *P07175; sub P07175 { &emul8; goto &fetch; }
$core[007176] = 07474; $code[007176] = *P07176; sub P07176 { $skp = 0; $skp = 1 unless $lac&07777; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; $lac |= $swr; goto &fetch; }
$core[007177] = 07303; $code[007177] = *P07177; sub P07177 { $lac &= 010000; $lac &= 07777; $lac++; $lac = ($lac&010000) + (($lac&077)<<6) + (($lac>>6)&077); goto &fetch; }
$core[007200] = 00000; $code[007200] = *S07200; sub S07200 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007201] = 03344; $code[007201] = *I07201; sub I07201 { $core[007344] = $lac & 07777; $lac &= 010000; $code[007344] = *emul8; goto &fetch; }
$core[007202] = 07501; $code[007202] = *I07202; sub I07202 { &emul8; goto &fetch; }
$core[007203] = 03343; $code[007203] = *I07203; sub I07203 { $core[007343] = $lac & 07777; $lac &= 010000; $code[007343] = *emul8; goto &fetch; }
$core[007204] = 07340; $code[007204] = *I07204; sub I07204 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[007205] = 00343; $code[007205] = *I07205; sub I07205 { $lac &= (010000|$core[007343]); goto &fetch; }
$core[007206] = 07421; $code[007206] = *I07206; sub I07206 { &emul8; goto &fetch; }
$core[007207] = 07040; $code[007207] = *I07207; sub I07207 { $lac ^= 07777; goto &fetch; }
$core[007210] = 00344; $code[007210] = *I07210; sub I07210 { $lac &= (010000|$core[007344]); goto &fetch; }
$core[007211] = 07501; $code[007211] = *I07211; sub I07211 { &emul8; goto &fetch; }
$core[007212] = 03345; $code[007212] = *I07212; sub I07212 { $core[007345] = $lac & 07777; $lac &= 010000; $code[007345] = *emul8; goto &fetch; }
$core[007213] = 07501; $code[007213] = *I07213; sub I07213 { &emul8; goto &fetch; }
$core[007214] = 07040; $code[007214] = *I07214; sub I07214 { $lac ^= 07777; goto &fetch; }
$core[007215] = 00344; $code[007215] = *I07215; sub I07215 { $lac &= (010000|$core[007344]); goto &fetch; }
$core[007216] = 07421; $code[007216] = *I07216; sub I07216 { &emul8; goto &fetch; }
$core[007217] = 07040; $code[007217] = *I07217; sub I07217 { $lac ^= 07777; goto &fetch; }
$core[007220] = 00344; $code[007220] = *I07220; sub I07220 { $lac &= (010000|$core[007344]); goto &fetch; }
$core[007221] = 07040; $code[007221] = *I07221; sub I07221 { $lac ^= 07777; goto &fetch; }
$core[007222] = 00343; $code[007222] = *I07222; sub I07222 { $lac &= (010000|$core[007343]); goto &fetch; }
$core[007223] = 07501; $code[007223] = *I07223; sub I07223 { &emul8; goto &fetch; }
$core[007224] = 03346; $code[007224] = *I07224; sub I07224 { $core[007346] = $lac & 07777; $lac &= 010000; $code[007346] = *emul8; goto &fetch; }
$core[007225] = 03347; $code[007225] = *I07225; sub I07225 { $core[007347] = $lac & 07777; $lac &= 010000; $code[007347] = *emul8; goto &fetch; }
$core[007226] = 07040; $code[007226] = *I07226; sub I07226 { $lac ^= 07777; goto &fetch; }
$core[007227] = 00343; $code[007227] = *I07227; sub I07227 { $lac &= (010000|$core[007343]); goto &fetch; }
$core[007230] = 00344; $code[007230] = *I07230; sub I07230 { $lac &= (010000|$core[007344]); goto &fetch; }
$core[007231] = 07450; $code[007231] = *I07231; sub I07231 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007232] = 05274; $code[007232] = *I07232; sub I07232 { $pc = 007274; $inh = 0; goto &fetch; }
$core[007233] = 07421; $code[007233] = *I07233; sub I07233 { &emul8; goto &fetch; }
$core[007234] = 07521; $code[007234] = *L07234; sub L07234 { &emul8; goto &fetch; }
$core[007235] = 00345; $code[007235] = *I07235; sub I07235 { $lac &= (010000|$core[007345]); goto &fetch; }
$core[007236] = 07450; $code[007236] = *I07236; sub I07236 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007237] = 05244; $code[007237] = *I07237; sub I07237 { $pc = 007244; $inh = 0; goto &fetch; }
$core[007240] = 07104; $code[007240] = *I07240; sub I07240 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007241] = 07521; $code[007241] = *I07241; sub I07241 { &emul8; goto &fetch; }
$core[007242] = 07501; $code[007242] = *I07242; sub I07242 { &emul8; goto &fetch; }
$core[007243] = 05234; $code[007243] = *I07243; sub I07243 { $pc = 007234; $inh = 0; goto &fetch; }
$core[007244] = 07501; $code[007244] = *L07244; sub L07244 { &emul8; goto &fetch; }
$core[007245] = 00345; $code[007245] = *I07245; sub I07245 { $lac &= (010000|$core[007345]); goto &fetch; }
$core[007246] = 00350; $code[007246] = *I07246; sub I07246 { $lac &= (010000|$core[007350]); goto &fetch; }
$core[007247] = 07450; $code[007247] = *I07247; sub I07247 { $skp = 0; $skp = 1 unless $lac&07777; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007250] = 05253; $code[007250] = *I07250; sub I07250 { $pc = 007253; $inh = 0; goto &fetch; }
$core[007251] = 03347; $code[007251] = *I07251; sub I07251 { $core[007347] = $lac & 07777; $lac &= 010000; $code[007347] = *emul8; goto &fetch; }
$core[007252] = 05260; $code[007252] = *I07252; sub I07252 { $pc = 007260; $inh = 0; goto &fetch; }
$core[007253] = 07130; $code[007253] = *L07253; sub L07253 { $lac &= 07777; $lac ^= 010000; $lac = (($lac&017777)>>1) + (($lac&1)<<12); goto &fetch; }
$core[007254] = 00343; $code[007254] = *I07254; sub I07254 { $lac &= (010000|$core[007343]); goto &fetch; }
$core[007255] = 00344; $code[007255] = *I07255; sub I07255 { $lac &= (010000|$core[007344]); goto &fetch; }
$core[007256] = 07440; $code[007256] = *I07256; sub I07256 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[007257] = 03347; $code[007257] = *I07257; sub I07257 { $core[007347] = $lac & 07777; $lac &= 010000; $code[007347] = *emul8; goto &fetch; }
$core[007260] = 07501; $code[007260] = *L07260; sub L07260 { &emul8; goto &fetch; }
$core[007261] = 03351; $code[007261] = *I07261; sub I07261 { $core[007351] = $lac & 07777; $lac &= 010000; $code[007351] = *emul8; goto &fetch; }
$core[007262] = 07501; $code[007262] = *I07262; sub I07262 { &emul8; goto &fetch; }
$core[007263] = 07040; $code[007263] = *I07263; sub I07263 { $lac ^= 07777; goto &fetch; }
$core[007264] = 00346; $code[007264] = *I07264; sub I07264 { $lac &= (010000|$core[007346]); goto &fetch; }
$core[007265] = 07421; $code[007265] = *I07265; sub I07265 { &emul8; goto &fetch; }
$core[007266] = 07040; $code[007266] = *I07266; sub I07266 { $lac ^= 07777; goto &fetch; }
$core[007267] = 00346; $code[007267] = *I07267; sub I07267 { $lac &= (010000|$core[007346]); goto &fetch; }
$core[007270] = 07040; $code[007270] = *I07270; sub I07270 { $lac ^= 07777; goto &fetch; }
$core[007271] = 00351; $code[007271] = *I07271; sub I07271 { $lac &= (010000|$core[007351]); goto &fetch; }
$core[007272] = 07501; $code[007272] = *I07272; sub I07272 { &emul8; goto &fetch; }
$core[007273] = 03346; $code[007273] = *I07273; sub I07273 { $core[007346] = $lac & 07777; $lac &= 010000; $code[007346] = *emul8; goto &fetch; }
$core[007274] = 07340; $code[007274] = *L07274; sub L07274 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[007275] = 00347; $code[007275] = *I07275; sub I07275 { $lac &= (010000|$core[007347]); goto &fetch; }
$core[007276] = 07640; $code[007276] = *I07276; sub I07276 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007277] = 07020; $code[007277] = *I07277; sub I07277 { $lac ^= 010000; goto &fetch; }
$core[007300] = 07040; $code[007300] = *I07300; sub I07300 { $lac ^= 07777; goto &fetch; }
$core[007301] = 00346; $code[007301] = *I07301; sub I07301 { $lac &= (010000|$core[007346]); goto &fetch; }
$core[007302] = 05600; $code[007302] = *I07302; sub I07302 { $pc = ($ib<<12)+$core[3712]; $inh = 0; goto &fetch; }
$core[007303] = 00000; $code[007303] = *S07303; sub S07303 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007304] = 07421; $code[007304] = *I07304; sub I07304 { &emul8; goto &fetch; }
$core[007305] = 07040; $code[007305] = *I07305; sub I07305 { $lac ^= 07777; goto &fetch; }
$core[007306] = 00777; $code[007306] = *I07306; sub I07306 { $lac &= (010000|$core[($df<<12)+$core[3839]]); goto &fetch; }
$core[007307] = 04200; $code[007307] = *I07307; sub I07307 { $core[007200] = 07310; $pc = 007200+1; $code[007200] = *emul8; $inh = 0; goto &fetch; }
$core[007310] = 07620; $code[007310] = *I07310; sub I07310 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007311] = 02303; $code[007311] = *I07311; sub I07311 { if (++$core[007303] == 010000) { $core[007303] = 0; $pc++; }$code[007303] = *emul8; goto &fetch; }
$core[007312] = 05703; $code[007312] = *I07312; sub I07312 { $pc = ($ib<<12)+$core[3779]; $inh = 0; goto &fetch; }
$core[007313] = 00000; $code[007313] = *S07313; sub S07313 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007314] = 07340; $code[007314] = *I07314; sub I07314 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[007315] = 00776; $code[007315] = *I07315; sub I07315 { $lac &= (010000|$core[($df<<12)+$core[3838]]); goto &fetch; }
$core[007316] = 07640; $code[007316] = *I07316; sub I07316 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007317] = 07020; $code[007317] = *I07317; sub I07317 { $lac ^= 010000; goto &fetch; }
$core[007320] = 07040; $code[007320] = *I07320; sub I07320 { $lac ^= 07777; goto &fetch; }
$core[007321] = 00775; $code[007321] = *I07321; sub I07321 { $lac &= (010000|$core[($df<<12)+$core[3837]]); goto &fetch; }
$core[007322] = 07640; $code[007322] = *I07322; sub I07322 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007323] = 07020; $code[007323] = *I07323; sub I07323 { $lac ^= 010000; goto &fetch; }
$core[007324] = 07430; $code[007324] = *I07324; sub I07324 { $skp = 0; $skp = 1 if $lac&010000; $skp = !$skp; $pc += $skp; goto &fetch; }
$core[007325] = 05341; $code[007325] = *I07325; sub I07325 { $pc = 007341; $inh = 0; goto &fetch; }
$core[007326] = 07340; $code[007326] = *I07326; sub I07326 { $lac &= 010000; $lac &= 07777; $lac ^= 07777; goto &fetch; }
$core[007327] = 00774; $code[007327] = *I07327; sub I07327 { $lac &= (010000|$core[($df<<12)+$core[3836]]); goto &fetch; }
$core[007330] = 07040; $code[007330] = *I07330; sub I07330 { $lac ^= 07777; goto &fetch; }
$core[007331] = 00773; $code[007331] = *I07331; sub I07331 { $lac &= (010000|$core[($df<<12)+$core[3835]]); goto &fetch; }
$core[007332] = 07440; $code[007332] = *I07332; sub I07332 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; goto &fetch; }
$core[007333] = 05341; $code[007333] = *I07333; sub I07333 { $pc = 007341; $inh = 0; goto &fetch; }
$core[007334] = 07040; $code[007334] = *I07334; sub I07334 { $lac ^= 07777; goto &fetch; }
$core[007335] = 00773; $code[007335] = *I07335; sub I07335 { $lac &= (010000|$core[($df<<12)+$core[3835]]); goto &fetch; }
$core[007336] = 07040; $code[007336] = *I07336; sub I07336 { $lac ^= 07777; goto &fetch; }
$core[007337] = 00774; $code[007337] = *I07337; sub I07337 { $lac &= (010000|$core[($df<<12)+$core[3836]]); goto &fetch; }
$core[007340] = 07640; $code[007340] = *I07340; sub I07340 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007341] = 04752; $code[007341] = *L07341; sub L07341 { $core[($ib<<12)+$core[3818]] = 07342; $pc = ($ib<<12)+$core[3818]+1; $code[($ib<<12)+$core[3818]] = *emul8; $inh = 0; goto &fetch; }
$core[007342] = 05713; $code[007342] = *I07342; sub I07342 { $pc = ($ib<<12)+$core[3787]; $inh = 0; goto &fetch; }
$core[007343] = 00000; $code[007343] = *D07343; sub D07343 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007344] = 00000; $code[007344] = *D07344; sub D07344 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007345] = 00000; $code[007345] = *D07345; sub D07345 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007346] = 00000; $code[007346] = *D07346; sub D07346 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007347] = 00000; $code[007347] = *D07347; sub D07347 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007350] = 04000; $code[007350] = *D07350; sub D07350 { $core[000000] = 07351; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007351] = 00000; $code[007351] = *D07351; sub D07351 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007352] = 07400; $code[007352] = *P07352; sub P07352 { goto &fetch; }
$core[007373] = 06763; $code[007373] = *P07373; sub P07373 { &emul8; goto &fetch; }
$core[007374] = 06764; $code[007374] = *P07374; sub P07374 { &emul8; goto &fetch; }
$core[007375] = 06765; $code[007375] = *P07375; sub P07375 { &emul8; goto &fetch; }
$core[007376] = 06762; $code[007376] = *P07376; sub P07376 { &emul8; goto &fetch; }
$core[007377] = 07164; $code[007377] = *P07377; sub P07377 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007400] = 00000; $code[007400] = *S07400; sub S07400 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007401] = 07604; $code[007401] = *I07401; sub I07401 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007402] = 00267; $code[007402] = *I07402; sub I07402 { $lac &= (010000|$core[007467]); goto &fetch; }
$core[007403] = 07640; $code[007403] = *I07403; sub I07403 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007404] = 05600; $code[007404] = *I07404; sub I07404 { $pc = ($ib<<12)+$core[3840]; $inh = 0; goto &fetch; }
$core[007405] = 07240; $code[007405] = *I07405; sub I07405 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[007406] = 00777; $code[007406] = *I07406; sub I07406 { $lac &= (010000|$core[($df<<12)+$core[3967]]); goto &fetch; }
$core[007407] = 07402; $code[007407] = *I07407; sub I07407 { $hlt = 1; goto &fetch; }
$core[007410] = 07240; $code[007410] = *I07410; sub I07410 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[007411] = 00776; $code[007411] = *I07411; sub I07411 { $lac &= (010000|$core[($df<<12)+$core[3966]]); goto &fetch; }
$core[007412] = 07402; $code[007412] = *D07412; sub D07412 { $hlt = 1; goto &fetch; }
$core[007413] = 07240; $code[007413] = *I07413; sub I07413 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[007414] = 00775; $code[007414] = *I07414; sub I07414 { $lac &= (010000|$core[($df<<12)+$core[3965]]); goto &fetch; }
$core[007415] = 07402; $code[007415] = *D07415; sub D07415 { $hlt = 1; goto &fetch; }
$core[007416] = 07240; $code[007416] = *I07416; sub I07416 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[007417] = 00774; $code[007417] = *I07417; sub I07417 { $lac &= (010000|$core[($df<<12)+$core[3964]]); goto &fetch; }
$core[007420] = 07402; $code[007420] = *I07420; sub I07420 { $hlt = 1; goto &fetch; }
$core[007421] = 07240; $code[007421] = *I07421; sub I07421 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[007422] = 00773; $code[007422] = *I07422; sub I07422 { $lac &= (010000|$core[($df<<12)+$core[3963]]); goto &fetch; }
$core[007423] = 07402; $code[007423] = *I07423; sub I07423 { $hlt = 1; goto &fetch; }
$core[007424] = 07240; $code[007424] = *I07424; sub I07424 { $lac &= 010000; $lac ^= 07777; goto &fetch; }
$core[007425] = 00772; $code[007425] = *I07425; sub I07425 { $lac &= (010000|$core[($df<<12)+$core[3962]]); goto &fetch; }
$core[007426] = 07402; $code[007426] = *I07426; sub I07426 { $hlt = 1; goto &fetch; }
$core[007427] = 05600; $code[007427] = *I07427; sub I07427 { $pc = ($ib<<12)+$core[3840]; $inh = 0; goto &fetch; }
$core[007430] = 00000; $code[007430] = *S07430; sub S07430 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007431] = 07104; $code[007431] = *I07431; sub I07431 { $lac &= 07777; $lac = ($lac<<1) + (($lac>>12)&1); goto &fetch; }
$core[007432] = 07420; $code[007432] = *I07432; sub I07432 { $skp = 0; $skp = 1 if $lac&010000; $pc += $skp; goto &fetch; }
$core[007433] = 05240; $code[007433] = *I07433; sub I07433 { $pc = 007440; $inh = 0; goto &fetch; }
$core[007434] = 07421; $code[007434] = *I07434; sub I07434 { &emul8; goto &fetch; }
$core[007435] = 07040; $code[007435] = *I07435; sub I07435 { $lac ^= 07777; goto &fetch; }
$core[007436] = 00241; $code[007436] = *I07436; sub I07436 { $lac &= (010000|$core[007441]); goto &fetch; }
$core[007437] = 04771; $code[007437] = *I07437; sub I07437 { $core[($ib<<12)+$core[3961]] = 07440; $pc = ($ib<<12)+$core[3961]+1; $code[($ib<<12)+$core[3961]] = *emul8; $inh = 0; goto &fetch; }
$core[007440] = 05630; $code[007440] = *L07440; sub L07440 { $pc = ($ib<<12)+$core[3864]; $inh = 0; goto &fetch; }
$core[007441] = 00003; $code[007441] = *D07441; sub D07441 { $lac &= (010000|$core[000003]); goto &fetch; }
$core[007442] = 00000; $code[007442] = *S07442; sub S07442 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007443] = 07604; $code[007443] = *I07443; sub I07443 { $lac &= 010000; $lac |= $swr; goto &fetch; }
$core[007444] = 00270; $code[007444] = *I07444; sub I07444 { $lac &= (010000|$core[007470]); goto &fetch; }
$core[007445] = 07640; $code[007445] = *I07445; sub I07445 { $skp = 0; $skp = 1 unless $lac&07777; $pc += $skp; $lac &= 010000; goto &fetch; }
$core[007446] = 05642; $code[007446] = *I07446; sub I07446 { $pc = ($ib<<12)+$core[3874]; $inh = 0; goto &fetch; }
$core[007447] = 07040; $code[007447] = *I07447; sub I07447 { $lac ^= 07777; goto &fetch; }
$core[007450] = 00271; $code[007450] = *I07450; sub I07450 { $lac &= (010000|$core[007471]); goto &fetch; }
$core[007451] = 04261; $code[007451] = *I07451; sub I07451 { $core[007461] = 07452; $pc = 007461+1; $code[007461] = *emul8; $inh = 0; goto &fetch; }
$core[007452] = 07040; $code[007452] = *I07452; sub I07452 { $lac ^= 07777; goto &fetch; }
$core[007453] = 00272; $code[007453] = *I07453; sub I07453 { $lac &= (010000|$core[007472]); goto &fetch; }
$core[007454] = 04261; $code[007454] = *I07454; sub I07454 { $core[007461] = 07455; $pc = 007461+1; $code[007461] = *emul8; $inh = 0; goto &fetch; }
$core[007455] = 07040; $code[007455] = *I07455; sub I07455 { $lac ^= 07777; goto &fetch; }
$core[007456] = 00273; $code[007456] = *I07456; sub I07456 { $lac &= (010000|$core[007473]); goto &fetch; }
$core[007457] = 04261; $code[007457] = *I07457; sub I07457 { $core[007461] = 07460; $pc = 007461+1; $code[007461] = *emul8; $inh = 0; goto &fetch; }
$core[007460] = 05642; $code[007460] = *I07460; sub I07460 { $pc = ($ib<<12)+$core[3874]; $inh = 0; goto &fetch; }
$core[007461] = 00000; $code[007461] = *S07461; sub S07461 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007462] = 06046; $code[007462] = *I07462; sub I07462 { &emul8; goto &fetch; }
$core[007463] = 06041; $code[007463] = *L07463; sub L07463 { &emul8; goto &fetch; }
$core[007464] = 05263; $code[007464] = *I07464; sub I07464 { $pc = 007463; $inh = 0; goto &fetch; }
$core[007465] = 07200; $code[007465] = *I07465; sub I07465 { $lac &= 010000; goto &fetch; }
$core[007466] = 05661; $code[007466] = *I07466; sub I07466 { $pc = ($ib<<12)+$core[3889]; $inh = 0; goto &fetch; }
$core[007467] = 04000; $code[007467] = *D07467; sub D07467 { $core[000000] = 07470; $pc = 000000+1; $code[000000] = *emul8; $inh = 0; goto &fetch; }
$core[007470] = 00400; $code[007470] = *D07470; sub D07470 { $lac &= (010000|$core[($df<<12)+$core[0]]); goto &fetch; }
$core[007471] = 00215; $code[007471] = *D07471; sub D07471 { $lac &= (010000|$core[007415]); goto &fetch; }
$core[007472] = 00212; $code[007472] = *D07472; sub D07472 { $lac &= (010000|$core[007412]); goto &fetch; }
$core[007473] = 00324; $code[007473] = *D07473; sub D07473 { $lac &= (010000|$core[007524]); goto &fetch; }
$core[007474] = 00000; $code[007474] = *S07474; sub S07474 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007475] = 07041; $code[007475] = *I07475; sub I07475 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007476] = 07421; $code[007476] = *I07476; sub I07476 { &emul8; goto &fetch; }
$core[007477] = 07040; $code[007477] = *I07477; sub I07477 { $lac ^= 07777; goto &fetch; }
$core[007500] = 00770; $code[007500] = *I07500; sub I07500 { $lac &= (010000|$core[($df<<12)+$core[3960]]); goto &fetch; }
$core[007501] = 04771; $code[007501] = *I07501; sub I07501 { $core[($ib<<12)+$core[3961]] = 07502; $pc = ($ib<<12)+$core[3961]+1; $code[($ib<<12)+$core[3961]] = *emul8; $inh = 0; goto &fetch; }
$core[007502] = 07500; $code[007502] = *I07502; sub I07502 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[007503] = 07041; $code[007503] = *I07503; sub I07503 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007504] = 07001; $code[007504] = *I07504; sub I07504 { $lac++; goto &fetch; }
$core[007505] = 07001; $code[007505] = *I07505; sub I07505 { $lac++; goto &fetch; }
$core[007506] = 05674; $code[007506] = *I07506; sub I07506 { $pc = ($ib<<12)+$core[3900]; $inh = 0; goto &fetch; }
$core[007507] = 00000; $code[007507] = *S07507; sub S07507 { $lac &= (010000|$core[000000]); goto &fetch; }
$core[007510] = 07041; $code[007510] = *I07510; sub I07510 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007511] = 07421; $code[007511] = *I07511; sub I07511 { &emul8; goto &fetch; }
$core[007512] = 07040; $code[007512] = *I07512; sub I07512 { $lac ^= 07777; goto &fetch; }
$core[007513] = 00767; $code[007513] = *I07513; sub I07513 { $lac &= (010000|$core[($df<<12)+$core[3959]]); goto &fetch; }
$core[007514] = 04771; $code[007514] = *I07514; sub I07514 { $core[($ib<<12)+$core[3961]] = 07515; $pc = ($ib<<12)+$core[3961]+1; $code[($ib<<12)+$core[3961]] = *emul8; $inh = 0; goto &fetch; }
$core[007515] = 07500; $code[007515] = *I07515; sub I07515 { $skp = 0; $skp = 1 if $lac&04000; $pc += $skp; goto &fetch; }
$core[007516] = 07041; $code[007516] = *I07516; sub I07516 { $lac ^= 07777; $lac++; goto &fetch; }
$core[007517] = 07001; $code[007517] = *I07517; sub I07517 { $lac++; goto &fetch; }
$core[007520] = 07001; $code[007520] = *I07520; sub I07520 { $lac++; goto &fetch; }
$core[007521] = 05707; $code[007521] = *I07521; sub I07521 { $pc = ($ib<<12)+$core[3911]; $inh = 0; goto &fetch; }
$core[007567] = 07160; $code[007567] = *P07567; sub P07567 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; goto &fetch; }
$core[007570] = 07161; $code[007570] = *P07570; sub P07570 { $lac &= 07777; $lac ^= 010000; $lac ^= 07777; $lac++; goto &fetch; }
$core[007571] = 07200; $code[007571] = *P07571; sub P07571 { $lac &= 010000; goto &fetch; }
$core[007572] = 06757; $code[007572] = *P07572; sub P07572 { &emul8; goto &fetch; }
$core[007573] = 06756; $code[007573] = *P07573; sub P07573 { &emul8; goto &fetch; }
$core[007574] = 06754; $code[007574] = *P07574; sub P07574 { &emul8; goto &fetch; }
$core[007575] = 06753; $code[007575] = *P07575; sub P07575 { &emul8; goto &fetch; }
$core[007576] = 06761; $code[007576] = *P07576; sub P07576 { &emul8; goto &fetch; }
$core[007577] = 06760; $code[007577] = *P07577; sub P07577 { &emul8; goto &fetch; }
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

