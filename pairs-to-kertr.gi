SEMIGROUPS.KernelTraceClosure := function(S, kernel, traceBlocks, pairstoapply)
  local idsmgp, idslist, slist, kernelgenstoapply, gen, nrk, nr,
        traceUF, i, pos1, j, pos, hashlen, ht, right, genstoapply,
        NormalClosureInverseSemigroup, enumerate_trace, enforce_conditions,
        compute_kernel, oldLookup, oldKernel, trace_unchanged, kernel_unchanged;

  # This function takes an inverse semigroup S, a subsemigroup ker, an
  # equivalence traceBlocks on the idempotents, and a list of pairs in S.
  # It returns the minimal congruence containing "kernel" in its kernel and
  # "traceBlocks" in its trace, and containing all the given pairs
  # TODO Review this JDM for use of Elements, AsList etc. Could iterators work
  # better?

  idsmgp  := IdempotentGeneratedSubsemigroup(S);
  idslist := AsListCanonical(idsmgp);
  slist   := AsListCanonical(S);

  # Retrieve the initial information
  kernel := InverseSubsemigroup(S, kernel);
  kernelgenstoapply := Set(pairstoapply, x -> x[1] * x[2] ^ -1);
  # kernel might not be normal, so make sure to check its generators too
  for gen in GeneratorsOfInverseSemigroup(kernel) do
    AddSet(kernelgenstoapply, gen);
  od;
  nrk := Length(kernelgenstoapply);
  Enumerate(kernel);
  pairstoapply := List(pairstoapply,
                       x -> [PositionCanonical(idsmgp, RightOne(x[1])),
                             PositionCanonical(idsmgp, RightOne(x[2]))]);
  nr := Length(pairstoapply);

  # Calculate traceUF from traceBlocks
  traceUF := UF_NEW(Length(idslist));
  for i in [1 .. Length(traceBlocks)] do
    pos1 := PositionCanonical(idsmgp, traceBlocks[i][1]);
    for j in [2 .. Length(traceBlocks[i])] do
      UF_UNION(traceUF, [pos1, PositionCanonical(idsmgp, traceBlocks[i][j])]);
    od;
  od;
  UF_FLATTEN(traceUF);

  # Setup some useful information
  pos := 0;
  hashlen := SEMIGROUPS.OptionsRec(S).hashlen;
  ht := HTCreate([1, 1], rec(forflatplainlists := true,
                             treehashsize := hashlen));
  right := RightCayleyGraphSemigroup(idsmgp);
  genstoapply := [1 .. Length(right[1])];

  #
  # The functions that do the work:
  #
  NormalClosureInverseSemigroup := function(S, K, coll)
    local T, opts, x, list;
    # This takes an inv smgp S, an inv subsemigroup K, and some elms coll,
    # then creates the *normal closure* of K with coll inside S.
    # It assumes K is already normal.
    T := ClosureInverseSemigroup(K, coll);
    while K <> T do
      K := T;
      opts := rec();
      opts.gradingfunc := function(o, x)
        return x in K;
      end;
      opts.onlygrades := function(x, data)
        return x = false;
      end;
      opts.onlygradesdata := fail;
      for x in K do
        list := AsList(Enumerate(Orb(GeneratorsOfSemigroup(S), x, POW, opts)));
        T := ClosureInverseSemigroup(T, list);
      od;
    od;
    return K;
  end;

  enumerate_trace := function()
    local a, j, x, y, z;
    if pos = 0 then
      # Add the generating pairs themselves
      for x in pairstoapply do
        if x[1] <> x[2] and HTValue(ht, x) = fail then
          HTAdd(ht, x, true);
          UF_UNION(traceUF, x);
          # Add each pair's "conjugate" pairs
          for a in GeneratorsOfSemigroup(S) do
            z := [PositionCanonical(idsmgp, a ^ -1 * idslist[x[1]] * a),
                  PositionCanonical(idsmgp, a ^ -1 * idslist[x[2]] * a)];
            if z[1] <> z[2] and HTValue(ht, z) = fail then
              HTAdd(ht, z, true);
              nr := nr + 1;
              pairstoapply[nr] := z;
              UF_UNION(traceUF, z);
            fi;
          od;
        fi;
      od;
    fi;

    while pos < nr do
      pos := pos + 1;
      x := pairstoapply[pos];
      for j in genstoapply do
        # Add the pair's right-multiples (idsmgp is commutative)
        y := [right[x[1]][j], right[x[2]][j]];
        if y[1] <> y[2] and HTValue(ht, y) = fail then
          HTAdd(ht, y, true);
          nr := nr + 1;
          pairstoapply[nr] := y;
          UF_UNION(traceUF, y);
          # Add the pair's "conjugate" pairs
          for a in GeneratorsOfSemigroup(S) do
            z := [PositionCanonical(idsmgp, a ^ -1 * idslist[x[1]] * a),
                  PositionCanonical(idsmgp, a ^ -1 * idslist[x[2]] * a)];
            if z[1] <> z[2] and HTValue(ht, z) = fail then
              HTAdd(ht, z, true);
              nr := nr + 1;
              pairstoapply[nr] := z;
              UF_UNION(traceUF, z);
            fi;
          od;
        fi;
      od;
    od;
    UF_FLATTEN(traceUF);
  end;

  enforce_conditions := function()
    local traceTable, traceBlocks, a, e, f, classno;
    traceTable := UF_TABLE(traceUF);
    traceBlocks := UF_BLOCKS(traceUF);
    for a in slist do
      if a in kernel then
        e := PositionCanonical(idsmgp, LeftOne(a));
        f := PositionCanonical(idsmgp, RightOne(a));
        if traceTable[e] <> traceTable[f] then
          nr := nr + 1;
          pairstoapply[nr] := [e, f];
        fi;
      else
        classno := traceTable[PositionCanonical(idsmgp, RightOne(a))];
        for e in traceBlocks[classno] do
          if a * idslist[e] in kernel then
            nrk := nrk + 1;
            AddSet(kernelgenstoapply, a);
            break;
            # JDM is this correct? Why repeatedly add the same a to
            # kernelgenstoapply?
          fi;
        od;
      fi;
    od;
  end;

  compute_kernel := function()
    # Take the normal closure inverse semigroup containing the new elements
    if kernelgenstoapply <> [] then
      kernel := NormalClosureInverseSemigroup(S, kernel,
                                              kernelgenstoapply);
      Enumerate(kernel);
      kernelgenstoapply := [];
      nrk := 0;
    fi;
  end;

  # Keep applying the method until no new info is found
  repeat
    oldLookup := StructuralCopy(UF_TABLE(traceUF));
    oldKernel := kernel;
    compute_kernel();
    enforce_conditions();
    enumerate_trace();
    trace_unchanged := (oldLookup = UF_TABLE(traceUF));
    kernel_unchanged := (oldKernel = kernel);
    Info(InfoSemigroups, 2, "lookup: ", trace_unchanged);
    Info(InfoSemigroups, 2, "kernel: ", kernel_unchanged);
    Info(InfoSemigroups, 2, "nrk = 0: ", nrk = 0);
  until trace_unchanged and kernel_unchanged and (nrk = 0);

  # Convert traceLookup to traceBlocks
  traceBlocks := List(Compacted(UF_BLOCKS(traceUF)),
                      b -> List(b, i -> idslist[i]));

  return InverseSemigroupCongruenceByKernelTraceNC(S, kernel, traceBlocks);
end;
