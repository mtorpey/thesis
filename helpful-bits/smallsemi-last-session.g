[13:59:51] ~ $ gap
 ┌───────┐   GAP 4.10dev-1591-g09cc673 of today
 │  GAP  │   https://www.gap-system.org
 └───────┘   Architecture: x86_64-pc-linux-gnu-default64-kv6
 Configuration:  gmp 6.1.2, GASMAN, readline
 Loading the library and packages ...
 Packages:   crypting 0.8, curlInterface 2.1.1, GAPDoc 1.6.1, IO 4.5.2, 
             json 2.0.0, Memoisation 0.1, PackageManager 0.2.1, PrimGrp 3.3.1, 
             profiling 2.0.1, SmallGrp 1.3, TransGrp 2.0.4
 Try '??help' for help. See also '?copyright', '?cite' and '?authors'
gap> LoadPackage("smallsemi");
-----------------------------------------------------------------------------
Smallsemi -   A library of small semigroups
by Andreas Distler & James Mitchell
For contents, type: ?Smallsemi:
Loading Smallsemi 0.6.11 ...
-----------------------------------------------------------------------------
true
gap> x := rec( avg_nr_congs := 554923/7395, 
>   avg_prop_princ := 36944695689379971759169404360858610270921475531946318474343008788081/
>     110194302626839757980816952749265533358315242669272945882022792368000, 
>   avg_prop_rees := 4025287510952494399218649215667292139736629323121379050603902334361/
>     12243811402982195331201883638807281484257249185474771764669199152000, just_princ := 144,
>   just_rees := 200, nr_equiv := 44370, nr_isom := 44370, prop_just_princ := 8/2465, 
>   prop_just_rees := 20/4437, size := 7 );
rec( avg_nr_congs := 554923/7395, 
  avg_prop_princ := 3694469568937997175916940436085861027092147553194631847434\
3008788081/
    110194302626839757980816952749265533358315242669272945882022792368000, 
  avg_prop_rees := 40252875109524943992186492156672921397366293231213790506039\
02334361/12243811402982195331201883638807281484257249185474771764669199152000,
  just_princ := 144, just_rees := 200, nr_equiv := 44370, nr_isom := 44370, 
  prop_just_princ := 8/2465, prop_just_rees := 20/4437, size := 7 )
gap> 
gap> 
gap> x.nr_isom := NrSmallSemigroups(7, IsSelfDualSemigroup, true);
#I  Smallsemi: loading data for semigroup properties. Please be patient.
44370
gap> Float(x.avg_prop_princ);
0.335269
gap> Float(x.avg_prop_rees);
0.328761
gap> 
gap> 
gap> sd := x;
rec( avg_nr_congs := 554923/7395, avg_prop_princ := 36944695689379971759169404360858610270921475531946318474343008788081/
    110194302626839757980816952749265533358315242669272945882022792368000, avg_prop_rees := 4025287510952494399218649215667292139736629323121379050603902334361/
    12243811402982195331201883638807281484257249185474771764669199152000, just_princ := 144, just_rees := 200, nr_equiv := 44370, nr_isom := 44370, prop_just_princ := 8/2465, 
  prop_just_rees := 20/4437, size := 7 )
gap> 
gap> old := rec(avg_nr_congs := 7842/100, avg_prop_princ := 29/100, avg_prop_rees := 31/100, just_princ := 320, just_rees := 623, nr_equiv := 836021, nr_isom := 836021, size := 7);
rec( avg_nr_congs := 3921/50, avg_prop_princ := 29/100, avg_prop_rees := 31/100, just_princ := 320, just_rees := 623, nr_equiv := 836021, nr_isom := 836021, size := 7 )
gap> old2 := rec(avg_nr_congs := 7842/100, avg_prop_princ := 29/100, avg_prop_rees := 31/100, just_princ := 320*2, just_rees := 623*2, nr_equiv := 836021*2, nr_isom := 836021*2, size := 7);
rec( avg_nr_congs := 3921/50, avg_prop_princ := 29/100, avg_prop_rees := 31/100, just_princ := 640, just_rees := 1246, nr_equiv := 1672042, nr_isom := 1672042, size := 7 )
gap> 
gap> 
gap> 
gap> final := rec(avg_nr_congs := (old2.avg_nr_congs*old2.nr_isom - sd.avg_nr_congs*sd.nr_isom) / (old2.nr_isom - sd.nr_isom),
>                 avg_prop_princ := (old2.avg_prop_princ*old2.nr_isom - sd.avg_prop_princ*sd.nr_isom) / (old2.nr_isom - sd.nr_isom),
>                 avg_prop_rees := (old2.avg_prop_rees*old2.nr_isom - sd.avg_prop_rees*sd.nr_isom) / (old2.nr_isom - sd.nr_isom),
>                 just_princ := old2.just_princ - sd.just_princ,
>                 just_rees := old2.just_rees - sd.just_rees,
>                 nr_equiv := old2.nr_equiv - sd.nr_equiv,
>                 nr_isom := old2.nr_isom - sd.nr_isom,
>                 size := 7);
rec( avg_nr_congs := 3194799891/40691800, avg_prop_princ := 1167300416420335078003975297003765186640870256384501230404540349359471/
    4042375049475625930857613051956333766337518315663304808872747408140800, avg_prop_rees := 139007656839243545994105050946414461516453193241667410279838182349831/
    449152783275069547873068116884037085148613146184811645430305267571200, just_princ := 496, just_rees := 1046, nr_equiv := 1627672, nr_isom := 1627672, size := 7 )
gap> final.prop_just_princ := final.just_princ / final.nr_isom;
62/203459
gap> final.prop_just_rees := final.just_rees / final.nr_isom;
523/813836
gap> 
gap> 
gap> 
gap> 
gap> render_list([final]);
7 & 78.51 \\

7 & 1627672 & 496 & (0.030\%) & 29\% \\

7 & 1627672 & 1046 & (0.064\%) & 31\% \\
