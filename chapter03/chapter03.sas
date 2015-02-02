%let home_dir = /folders/myfolders/midoribon/chapter03/;

data d;
    infile "&home_dir.data3a.csv" dsd missover firstobs = 2;
    attrib y length = 8  label = "種子数"
           x length = 8  label = "体サイズ"
           f length = $1 label = "施肥処理"
    ;
    input y x f;
run;

* P42 ;
proc print data = d;
run;

* P42 ;
proc print data = d;
    var x;
run;

* P43 ;
proc print data = d;
    var y;
run;

* P43 ;
proc print data = d;
    var f;
run;

* P44 データセットの概要 ;
proc means data = d min q1 median mean q3 max;
run;

proc freq data = d;
    tables f / missing nocol norow nopercent;
run;

* P46 図3.2 例題の架空データの図示 ;
proc sgplot data = d;
    scatter x = x y = y / group = f markerattrs = (symbol=circlefilled);
run;

* P46 図3.3 植物の種子数の分布を、施肥処理でグループわけした箱ひげ図 ;
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

* P48 図3.4 個体iの平均種子数λ_iと体サイズx_iの関係 ;
proc sgplot data = data3_4;
    series x = x y = lambda1 / lineattrs = (pattern=dash);
    series x = x y = lambda2;
    refline 0 / axis = x lineattrs = (pattern=dot);
    xaxis label = "個体iの体のサイズx_i";
    yaxis label = "個体iのλ_i";
run;

* P50 ポアソン回帰 ;
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

* P54 図3.7 平均種子数λの予測 ;
proc sgplot data = d3_7;
    scatter x = x y = y / group = f markerattrs = (symbol=circlefilled);
    series x = x1 y = y1 / lineattrs=(color=orange);
run;

* P56 説明変数が因子型の統計モデル ;
proc genmod data = d;
    class f(ref="C");
    model y = f / dist = poisson
                  link = log;
run;

* P58 説明変数が数量型＋因子型の統計モデル ;
proc genmod data = d;
    class f(ref="C");
    model y = x f / dist = poisson
                    link = log;
run;


* 図3.9用の架空データ読み込み ;
data d0;
    infile "&home_dir.d0.csv" dsd missover firstobs = 2;
    attrib x length = 8  label = ""
           y length = 8  label = ""
    ;
    input x y;
run;

proc genmod data = d0;
    model y = x / dist = normal
                  link = id;
    ods output parameterestimates = paramest1;
run;

data _null_;
    set paramest1;
    if parameter eq "Intercept" then call symputx("beta3", estimate);
    if parameter eq "x"         then call symputx("beta4", estimate);
run;

data line3_9a;
    do x1 = 0 to 2 by 0.1;
        y1 = &beta3. + &beta4. * x1;
        output;
    end;
run;

data d0_3_9a;
    set d0 line3_9a;
run;

* P61 図3.9(A) 正規分布・恒等リンク関数の統計モデル ;
proc sgplot data = d0_3_9a;
    scatter x = x y = y;
    series x = x1 y = y1 / lineattrs = (pattern=dash);
    refline 0 / axis = y;
    yaxis min = -2;
run;


proc genmod data = d0;
    model y = x / dist = poisson
                  link = log;
    ods output parameterestimates = paramest2;
run;

data _null_;
    set paramest2;
    if parameter eq "Intercept" then call symputx("beta5", estimate);
    if parameter eq "x"         then call symputx("beta6", estimate);
run;

data line3_9b;
    do x1 = 0 to 2 by 0.1;
        y1 = exp(&beta5. + &beta6. * x1);
        output;
    end;
run;

data d0_3_9b;
    set d0 line3_9b;
run;

* P61 図3.9(B) ポアソン分布・対数リンク関数の統計モデル ;
proc sgplot data = d0_3_9b;
    scatter x = x y = y;
    series x = x1 y = y1 / lineattrs = (pattern=dash);
    refline 0 / axis = y;
    yaxis min = -2;
run;
