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
    refline 0 / axis = x lineattrs = (pattern=dot);
    xaxis label = "個体iの体のサイズx_i";
    yaxis label = "個体iのλ_i";
run;

* P50 ;
proc genmod data = d;
    model y = x / dist = poisson
                  link = log;
    ods output parameterestimates = param_est;
run;

data _null_;
    set param_est;
    if parameter eq "Intercept" then do;
        call symputx("beta1", estimate);
        call symputx("std_err1", stderr);
    end;
    if parameter eq "x" then do;
        call symputx("beta2", estimate);
        call symputx("std_err2", stderr);
    end;
run;

data param3_6;
    do i = -0.1 to 1.6 by 0.005;
        beta1 = pdf("normal", i, &beta1., &std_err1.);
        beta2 = pdf("normal", i, &beta2., &std_err2.);
        output;
    end;
run;

* P52 図3.6 パラメーター推定値のばらつきの評価 ;
proc sgplot data = param3_6;
    series x = i y = beta1;
    series x = i y = beta2;
    refline 0 / axis = x;
run;

proc sql noprint;
    select min(x), max(x) into :minx, :maxx
        from d;
quit;

data line3_7;
    do x1 = &minx. to &maxx. by 0.1;
        y1 = exp(&beta1. + &beta2. * x1);
        output;
    end;
run;

data d3_7;
    set d line3_7;
run;

* P54 図3.7 ;
proc sgplot data = d3_7;
    scatter x = x y = y / group = f markerattrs = (symbol=circlefilled);
    series x = x1 y = y1 / lineattrs=(color=orange);
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

