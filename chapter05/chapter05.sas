%let home_dir = /folders/myfolders/midoribon/chapter05/;

data d;
    infile "&home_dir.data3a.csv" dsd missover firstobs = 2;
    attrib y length = 8  label = "種子数"
           x length = 8  label = "体サイズ"
           f length = $1 label = "施肥処理"
    ;
    input y x f;
run;

* P98 ;
* 一定モデル ;
proc genmod data = d;
    model y = / dist = poisson
                link = log;
    ods output modelfit = fit1;
run;

* xモデル ;
proc genmod data = d;
    model y = x / dist = poisson
                  link = log;
    ods output modelfit = fit2;
run;

data d2;
    set d;
    n = _n_;
run;

* フルモデル ;
proc genmod data = d2;
    class n;
    model y = n / dist = poisson
                  link = log;
run;

data _null_;
    set fit1;
    if criterion in ("Deviance", "デビアンス") then call symput("fit1_deviance", compress(put(value, best.)));
run;

data _null_;
    set fit2;
    if criterion in ("Deviance", "デビアンス") then call symput("fit2_deviance", compress(put(value, best.)));
run;

* P102 xモデルの逸脱度 ;
%put &fit2_deviance.;

* P102 一定モデルとxモデルの逸脱度の差 ;
data _null_;
    diff = &fit1_deviance. - &fit2_deviance.;
    put diff;
run;


* P103 PB法の1ステップ ;
proc sql noprint;
    select mean(y) into :meany from d;
quit;

data d3;
    set d;
    y_rnd = rand("poisson", &meany.);
run;

proc genmod data = d3;
    model y_rnd = / dist = poisson
                    link = log;
    ods output modelfit = fit3;
run;

proc genmod data = d3;
    model y_rnd = x / dist = poisson
                      link = log;
    ods output modelfit = fit4;
run;

data _null_;
    set fit3;
    if criterion in ("Deviance", "デビアンス") then call symput("fit3_deviance", compress(put(value, best.)));
run;

data _null_;
    set fit4;
    if criterion in ("Deviance", "デビアンス") then call symput("fit4_deviance", compress(put(value, best.)));
run;

data _null_;
    diff = &fit3_deviance. - &fit4_deviance.;
    put diff;
run;
* P103 PB法の1ステップ ここまで ;

* P104 PB法 ;
%macro pb(n=);

    proc datasets library = work nolist;
        delete dd12;
    run;
    quit;

    proc sql noprint;
        select mean(y) into :meany from d;
    quit;

    %do i = 1 %to &n.;

        data d3;
            set d;
            y_rnd = rand("poisson", &meany.);
        run;

        proc genmod data = d3;
            model y_rnd = / dist = poisson
                            link = log;
            ods output modelfit = fit3;
        run;

        proc genmod data = d3;
            model y_rnd = x / dist = poisson
                              link = log;
            ods output modelfit = fit4;
        run;

        data _null_;
            set fit3;
            if criterion in ("Deviance", "デビアンス") then call symput("fit3_deviance", compress(put(value, best.)));
        run;

        data _null_;
            set fit4;
            if criterion in ("Deviance", "デビアンス") then call symput("fit4_deviance", compress(put(value, best.)));
        run;

        data get_dd;
            diff = &fit3_deviance. - &fit4_deviance.;
        run;

        proc append base = dd12 data = get_dd;
        run;

    %end;

%mend pb;

%pb(n=1000);

data sganno;
    retain function "line" drawspace "datavalue" linepattern "dash";
    x1 = 4.5;
    x2 = 4.5;
    y1 = 0;
    y2 = 350;
    output;
run;

proc sgplot data = dd12 sganno = sganno;
    histogram diff / binwidth = 0.3 scale = count;
    xaxis label = "一定モデルとxモデルの逸脱度の差";
run;

