%let home_dir = /folders/myfolders/midoribon/chapter03/;

data d;
    infile "&home_dir.data3a.csv" dsd missover firstobs = 2;
    attrib y length = 8  label = "種子数"
           x length = 8  label = "体サイズ"
           f length = $1 label = "施肥処理"
    ;
    input y x f;
run;

proc print data = d;
    var x;
run;

proc print data = d;
    var y;
run;

proc print data = d;
    var f;
run;

proc means data = d min q1 median mean q3 max;
run;

proc freq data = d;
    tables f / missing nocol norow nopercent;
run;

* P46 図3.2 ;
proc sgplot data = d;
    scatter x = x y = y / group = f markerattrs = (symbol=circlefilled);
run;

* P46 図3.3 ;
proc sgplot data = d;
    vbox y / category = f;
run;

data data3_4;
    do x = -4 to 5 by 0.1;
        lambda1 = exp(-2 - 0.8 * x);    
        lambda2 = exp(-1 + 0.4 * x);    
        output;
    end;
run;

* P48 図3.4 ;
proc sgplot data = data3_4;
    series x = x y = lambda1 / lineattrs = (pattern=dash);
    series x = x y = lambda2;
run;

* P50 ;
proc genmod data = d;
    model y = x / dist = poisson
                  link = log;
    ods output parameterestimates = param_est;
run;

data _null_;
    set param_est;
    if parameter eq "Intercept" then call symput("beta1", compress(put(estimate, best.)));
    if parameter eq "x"         then call symput("beta2", compress(put(estimate, best.)));
run;

proc sql noprint;
    select min(x), max(x) into :minx, :maxx
        from d;
quit;

data sganno;
    retain function 'line' drawspace 'datavalue' linecolor 'orange';
    x1 = &minx.;
    x2 = &maxx.;
    y1 = exp(&beta1. + &beta2. * &minx.);
    y2 = exp(&beta1. + &beta2. * &maxx.);
    output;
run;

* P54 図3.7 ;
proc sgplot data = d sganno = sganno;
    scatter x = x y = y / group = f markerattrs = (symbol=circlefilled);
run;


* P56 ;
proc genmod data = d;
    class f(ref="C");
    model y = f / dist = poisson
                  link = log;
run;

* P58 ;
proc genmod data = d;
    class f(ref="C");
    model y = x f / dist = poisson
                    link = log;
run;
