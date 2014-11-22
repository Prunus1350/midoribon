%let home_dir = /folders/myfolders/midoribon/chapter04/;

data d;
    infile "&home_dir.data3a.csv" dsd missover firstobs = 2;
    attrib y length = 8  label = "種子数"
           x length = 8  label = "体サイズ"
           f length = $1 label = "施肥処理"
    ;
    input y x f;
run;

* P72 ;
proc genmod data = d;
    model y = x / dist = poisson
                  link = log pred;
run;

data d2;
    set d;
    n = _n_;
run;

* P74 フルモデル ;
proc genmod data = d2;
    class n;
    model y = n / dist = poisson
                  link = log;
run;

* P74 フルモデル(これでも同じ結果になる) ;
proc genmod data = d2;
    class f(ref="C") n;
    model y = x f n / dist = poisson
                      link = log;
run;

* P75 一定モデル ;
proc genmod data = d;
    model y = / dist = poisson
                link = log;
run;

* P76, P77 ;
* 一定モデル ;
proc genmod data = d;
    model y = / dist = poisson
                link = log;
run;

* fモデル ;
proc genmod data = d;
    class f(ref="C");
    model y = f / dist = poisson
                  link = log;
run;

* xモデル ;
proc genmod data = d;
    model y = x / dist = poisson
                  link = log;
run;

* x+fモデル ;
proc genmod data = d;
    class f(ref="C");
    model y = x f / dist = poisson
                    link = log;
run;

* フルモデル ;
proc genmod data = d2;
    class n;
    model y = n / dist = poisson
                  link = log;
run;
