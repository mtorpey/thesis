Read("count.g");

results := [ rec(
      avg_nr_congs := 2,
      avg_prop_princ := 1,
      avg_prop_rees := 7/10,
      just_princ := 5,
      just_rees := 2,
      nr_equiv := 4,
      nr_isom := 5,
      prop_just_princ := 1,
      prop_just_rees := 2/5,
      size := 2 ), rec(
      avg_nr_congs := 11/3,
      avg_prop_princ := 39/40,
      avg_prop_rees := 481/720,
      just_princ := 21,
      just_rees := 6,
      nr_equiv := 18,
      nr_isom := 24,
      prop_just_princ := 7/8,
      prop_just_rees := 1/4,
      size := 3 ), rec(
      avg_nr_congs := 1199/188,
      avg_prop_princ := 106171/118440,
      avg_prop_rees := 45239/78960,
      just_princ := 85,
      just_rees := 16,
      nr_equiv := 126,
      nr_isom := 188,
      prop_just_princ := 85/188,
      prop_just_rees := 4/47,
      size := 4 ), rec(
      avg_nr_congs := 21542/1915,
      avg_prop_princ := 90561238969/117315198000,
      avg_prop_rees := 28998266131/58657599000,
      just_princ := 194,
      just_rees := 64,
      nr_equiv := 1160,
      nr_isom := 1915,
      prop_just_princ := 194/1915,
      prop_just_rees := 64/1915,
      size := 5 ), rec(
      avg_nr_congs := 650253/28634,
      avg_prop_princ := 1596782880052663386825558307/2663818534318036420715440050,
      avg_prop_rees := 8755603397763992399904683207/21310548274544291365723520400,
      just_princ := 300,
      just_rees := 239,
      nr_equiv := 15973,
      nr_isom := 28634,
      prop_just_princ := 150/14317,
      prop_just_rees := 239/28634,
      size := 6 ), rec(
      avg_nr_congs := 31948829/406918,
      avg_prop_princ :=
       18066617983602569531048172656148296972911402852797185411703786740917011383/
        63112703341896397519384166443960471019657376236158808357639344672767168000,
      avg_prop_rees :=
       34973310532690260576924050013337677564914046025591125814458606690297021821/
        113602866015413515534891499599128847835383277225085855043750820410980902400,
      just_princ := 494,
      just_rees := 1046,
      nr_equiv := 836021,
      nr_isom := 1627672,
      prop_just_princ := 247/813836,
      prop_just_rees := 523/813836,
      size := 7 ) ];

render_list(results);
