LoadPackage("semigroups", false);
LoadPackage("smallsemi", false);

rounded_str := function(f, dp)
  local s, places, i;
  f := Float(f);
  f := f * 10^dp;
  f := Round(f);
  f := f / 10^dp;
  s := ViewString(f);
  if s[Length(s)] = '.' then
    Add(s, '0');
  fi;
  places := Length(SplitString(s, '.')[2]);
  for i in [1..dp-places] do
    Add(s, '0');
  od;
  return s;
end;

sig_figs := function(f, sf)
  local log, s;
  f := Float(f);
  log := Log10(f);
  if log < 0.0 then
    log := log - 1;
  fi;
  s := rounded_str(f, sf-Int(log)-1);
  if Length(s) > 3 and EndsWith(s, ".0") then
    Remove(s);
    Remove(s);
  fi;
  return s;
end;

produce := function(size)
  local nr_semigroups, nr_isoms, isoms_so_far, total_nr_congs, sum_props_princ, 
        sum_props_rees, just_princ, just_rees, ind, ss, weight, S, congs, 
        nr_congs, nr_princ_congs, nr_rees_congs, cong, avg_nr_congs, 
        avg_prop_princ, avg_prop_rees, prop_just_princ, prop_just_rees, nr_isom, 
        nr_equiv;
  
  if size = 1 then
    return "Ignoring 1";
  fi;

  nr_semigroups := NrSmallSemigroups(size);
  nr_isoms := nr_semigroups*2 - NrSmallSemigroups(size, 
                                                  IsSelfDualSemigroup,
                                                  true);
  isoms_so_far := 0;
  
  total_nr_congs := 0;
  sum_props_princ := 0;
  sum_props_rees := 0;
  
  just_princ := 0;
  just_rees := 0;

  for ind in [1 .. nr_semigroups] do
    ss := SmallSemigroup(size, ind);
    if IsSelfDualSemigroup(ss) then
      weight := 1;  # represents one isomorphism class
    else
      weight := 2;  # represents two isomorphism classes
    fi;
    
    S := AsSemigroup(IsTransformationSemigroup, ss);
    congs := CongruencesOfSemigroup(S);
    
    nr_congs := 0;
    nr_princ_congs := 0;
    nr_rees_congs := 0;

    for cong in congs do
      nr_congs := nr_congs + 1;
      if Length(GeneratingPairsOfSemigroupCongruence(cong)) <= 1 then
        nr_princ_congs := nr_princ_congs + 1;
      fi;
      if IsReesCongruence(cong) then
        nr_rees_congs := nr_rees_congs + 1;
      fi;
    od;

    isoms_so_far := isoms_so_far + weight;
    total_nr_congs := total_nr_congs + nr_congs * weight;
    
    sum_props_princ := sum_props_princ + nr_princ_congs/nr_congs * weight;
    sum_props_rees := sum_props_rees + nr_rees_congs/nr_congs * weight;
    
    if nr_princ_congs = nr_congs then
      just_princ := just_princ + weight;
    fi;
    if nr_rees_congs = nr_congs then
      just_rees := just_rees + weight;
    fi;
    
    if isoms_so_far mod 10000 = 0 then
      Print("Processed ", isoms_so_far,
            "out of ", nr_isoms,
            " semigroups\n");
    fi;
  od;
  
  avg_nr_congs := total_nr_congs / isoms_so_far;
  
  avg_prop_princ := sum_props_princ / isoms_so_far;
  avg_prop_rees := sum_props_rees / isoms_so_far;
  
  prop_just_princ := just_princ / isoms_so_far;
  prop_just_rees := just_rees / isoms_so_far;
  
  return rec(size := size,
             nr_isom := isoms_so_far,
             nr_equiv := nr_semigroups,
             avg_nr_congs := avg_nr_congs,
             just_princ := just_princ,
             prop_just_princ := prop_just_princ,
             avg_prop_princ := avg_prop_princ,
             just_rees := just_rees,
             prop_just_rees := prop_just_rees,
             avg_prop_rees := avg_prop_rees);
end;

produce_self_dual := function(size)
  local start_time, nr_semigroups, nr_semigroups_self_dual, sems_so_far, 
        total_nr_congs, sum_props_princ, sum_props_rees, just_princ, just_rees, 
        ind, ss, S, congs, nr_congs, nr_princ_congs, nr_rees_congs, cong, 
        time_so_far, time_per_smgp, time_left, avg_nr_congs, avg_prop_princ, 
        avg_prop_rees, prop_just_princ, prop_just_rees, nr_isom, nr_equiv;
  
  start_time := IO_gettimeofday().tv_sec;

  if size = 1 then
    return "Ignoring 1";
  fi;

  nr_semigroups := NrSmallSemigroups(size);
  nr_semigroups_self_dual := NrSmallSemigroups(size, IsSelfDualSemigroup, true);
  sems_so_far := 0;
  
  total_nr_congs := 0;
  sum_props_princ := 0;
  sum_props_rees := 0;
  
  just_princ := 0;
  just_rees := 0;

  for ind in [1 .. nr_semigroups] do
    ss := SmallSemigroup(size, ind);
    if not IsSelfDualSemigroup(ss) then
      continue;
    fi;
    
    S := AsSemigroup(IsTransformationSemigroup, ss);
    congs := CongruencesOfSemigroup(S);
    
    nr_congs := 0;
    nr_princ_congs := 0;
    nr_rees_congs := 0;

    for cong in congs do
      nr_congs := nr_congs + 1;
      if Length(GeneratingPairsOfSemigroupCongruence(cong)) <= 1 then
        nr_princ_congs := nr_princ_congs + 1;
      fi;
      if IsReesCongruence(cong) then
        nr_rees_congs := nr_rees_congs + 1;
      fi;
    od;

    sems_so_far := sems_so_far + 1;
    total_nr_congs := total_nr_congs + nr_congs;
    
    sum_props_princ := sum_props_princ + nr_princ_congs/nr_congs;
    sum_props_rees := sum_props_rees + nr_rees_congs/nr_congs;
    
    if nr_princ_congs = nr_congs then
      just_princ := just_princ + 1;
    fi;
    if nr_rees_congs = nr_congs then
      just_rees := just_rees + 1;
    fi;
    
    if sems_so_far mod 10 = 0 then
      Print("Processed ", sems_so_far,
            " out of ", nr_semigroups_self_dual,
            " semigroups.  ");
      time_so_far := IO_gettimeofday().tv_sec - start_time;
      time_per_smgp := time_so_far / sems_so_far;
      time_left := time_per_smgp * (nr_semigroups_self_dual - sems_so_far);
      time_left := sig_figs(time_left / 3600, 3);
      Print(time_left, " hours left.\n");
    fi;
  od;
  
  avg_nr_congs := total_nr_congs / sems_so_far;
  
  avg_prop_princ := sum_props_princ / sems_so_far;
  avg_prop_rees := sum_props_rees / sems_so_far;
  
  prop_just_princ := just_princ / sems_so_far;
  prop_just_rees := just_rees / sems_so_far;
  
  return rec(size := size,
             nr_isom := sems_so_far,
             nr_equiv := nr_semigroups_self_dual,
             avg_nr_congs := avg_nr_congs,
             just_princ := just_princ,
             prop_just_princ := prop_just_princ,
             avg_prop_princ := avg_prop_princ,
             just_rees := just_rees,
             prop_just_rees := prop_just_rees,
             avg_prop_rees := avg_prop_rees);
end;

all := [
  rec( avg_nr_congs := 2, avg_prop_princ := 1, avg_prop_rees := 3/4, 
      just_princ := 4, just_rees := 2, nr_equiv := 4, nr_isom := 4, 
      prop_just_princ := 1, prop_just_rees := 1/2, size := 2 ), 
  rec( avg_nr_congs := 11/3, avg_prop_princ := 44/45, avg_prop_rees := 25/36,
      just_princ := 16, just_rees := 5, nr_equiv := 18, nr_isom := 18, 
      prop_just_princ := 8/9, prop_just_rees := 5/18, size := 3 ), 
  rec( avg_nr_congs := 811/126, avg_prop_princ := 47389/52920, 
      avg_prop_rees := 94081/158760, just_princ := 56, just_rees := 13, 
      nr_equiv := 126, nr_isom := 126, prop_just_princ := 4/9, 
      prop_just_rees := 13/126, size := 4 ), 
  rec( avg_nr_congs := 3317/290, avg_prop_princ := 3411211673/4441437000, 
      avg_prop_rees := 17956195273/35531496000, just_princ := 122, 
      just_rees := 46, nr_equiv := 1160, nr_isom := 1160, 
      prop_just_princ := 61/580, prop_just_rees := 23/580, size := 5 ), 
  rec( avg_nr_congs := 368182/15973, 
      avg_prop_princ := 11828969540507625732341023/19862547079748915138110800
        , avg_prop_rees := 4933474700112174836345888579/
        11887734427229725710159313800, just_princ := 197, just_rees := 157, 
      nr_equiv := 15973, nr_isom := 15973, prop_just_princ := 197/15973, 
      prop_just_rees := 157/15973, size := 6 ) ];
           
render_list := function(list)
  local r;
  
  # tab:nr-congs-smallsemi
  for r in list do
    Print(r.size);
    Print(" & ");
    Print(rounded_str(r.avg_nr_congs, 2));
    Print(" \\\\\n");
  od;
  Print("\n");
  
  # tab:nr-principal-congs
  for r in list do
    Print(r.size);
    Print(" & ");
    Print(r.nr_isom);
    Print(" & ");
    Print(r.just_princ);
    Print(" & (");
    Print(sig_figs(r.prop_just_princ*100, 2));
    Print("\\%) & ");
    Print(Int(RoundCyc(r.avg_prop_princ * 100)));
    Print("\\% \\\\\n");
  od;
  Print("\n");
  
  # tab:nr-rees-congs
  for r in list do
    Print(r.size);
    Print(" & ");
    Print(r.nr_isom);
    Print(" & ");
    Print(r.just_rees);
    Print(" & (");
    Print(sig_figs(r.prop_just_rees*100, 2));
    Print("\\%) & ");
    Print(Int(RoundCyc(r.avg_prop_rees * 100)));
    Print("\\% \\\\\n");
  od;
end;

do_all := function()
  local L, n;
  L := [];
  for n in [2..7] do
    Print("\nStarting ", n, "...\n");
    Add(L, produce(n));
    Print("Done ", n, "\n");
    render_list(L);
  od;
  Print(L, "\n");
end;
