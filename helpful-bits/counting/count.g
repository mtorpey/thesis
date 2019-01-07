LoadPackage("semigroups", false);
LoadPackage("smallsemi", false);

rounded_str := function(f, dp)
  local s, places, i;
  f := Float(f);
  if f = 0.0 then
    return "0";
  fi;
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
  if f = 0.0 then
    return "0";
  fi;
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

produce := function(size, nr_threads)
  local start_time, nr_semigroups, nr_isoms, isoms_so_far, total_nr_congs, 
        sum_props_princ, sum_props_rees, just_princ, just_rees, children, ind, 
        i, child, filename, r, ss, S, congs, cong, avg_nr_congs, avg_prop_princ, 
        avg_prop_rees, prop_just_princ, prop_just_rees, nr_isom, nr_equiv,
        time_so_far, time_per_smgp, time_left;
  
  # Trigger loading data
  IsSelfDualSemigroup(SmallSemigroup(7,4));

  start_time := IO_gettimeofday().tv_sec;

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

  children := [];
  
  ind := 0;
  while ind < nr_semigroups or Length(children) > 0 do
    if ind mod Maximum(10, nr_threads) = 0 and ind > nr_threads then
      Print("Size ", size,
            ", done at least ", ind - nr_threads,
            " out of ", nr_semigroups,
            " semigroups, ");
      time_so_far := IO_gettimeofday().tv_sec - start_time;
      time_per_smgp := time_so_far / (ind - nr_threads);
      time_left := time_per_smgp * (nr_semigroups - ind + nr_threads/2);
      time_left := Maximum(0, time_left);
      time_left := sig_figs(time_left / 3600, 2);
      Print(time_left, " hours left.\n");
    fi;

    while ind >= nr_semigroups or Length(children) >= nr_threads do
      # Wait for a thread to finish
      for i in [1..Length(children)] do
        if IO_WaitPid(children[i], false) <> false then
          child := Remove(children, i);
          filename := Concatenation("output", String(child), ".g");
          r := EvalString(StringFile(filename));
          RemoveFile(filename);
          total_nr_congs := total_nr_congs + r.nr_congs * r.weight;
          sum_props_princ := sum_props_princ + r.nr_princ_congs / r.nr_congs * r.weight;
          sum_props_rees := sum_props_rees + r.nr_rees_congs / r.nr_congs * r.weight;
          if r.nr_princ_congs = r.nr_congs then
            just_princ := just_princ + r.weight;
          fi;
          if r.nr_rees_congs = r.nr_congs then
            just_rees := just_rees + r.weight;
          fi;
          isoms_so_far := isoms_so_far + r.weight;
          break;
        fi;
      od;
      if ind >= nr_semigroups and Length(children) = 0 then
        break;
      fi;
    od;

    if ind >= nr_semigroups then
      continue;
    fi;
    
    ind := ind + 1;
    child := IO_fork();
    if child <> 0 then
      Add(children, child);
      continue;
    fi;

    r := rec();

    ss := SmallSemigroup(size, ind);
    if IsSelfDualSemigroup(ss) then
      r.weight := 1;  # represents one isomorphism class
    else
      r.weight := 2;  # represents two isomorphism classes
    fi;
    
    S := AsSemigroup(IsTransformationSemigroup, ss);
    congs := CongruencesOfSemigroup(S);
    
    r.nr_congs := 0;
    r.nr_princ_congs := 0;
    r.nr_rees_congs := 0;

    for cong in congs do
      r.nr_congs := r.nr_congs + 1;
      if Length(GeneratingPairsOfSemigroupCongruence(cong)) <= 1 then
        r.nr_princ_congs := r.nr_princ_congs + 1;
      fi;
      if IsReesCongruence(cong) then
        r.nr_rees_congs := r.nr_rees_congs + 1;
      fi;
    od;

    filename := Concatenation("output", String(IO_getpid()), ".g");
    FileString(filename, String(r));
    QUIT_GAP(0);
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

do_all := function(nr_threads)
  local L, n;
  L := [];
  for n in [2..7] do
    Print("\nStarting ", n, "...\n");
    Add(L, produce(n, nr_threads));
    Print("Done ", n, "\n");
    render_list(L);
  od;
  Print(L, "\n");
end;
