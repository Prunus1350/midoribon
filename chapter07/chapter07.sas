%let home_dir = /folders/myfolders/midoribon/chapter07/;

data d;
    infile "&home_dir.data.csv" dsd missover firstobs = 2;
    attrib n  length = 8 label = "調査種子数"
           y  length = 8 label = "生存種子数"
           x  length = 8 label = "植物個体の葉数"
           id length = 8 label = "id"
    ;
    input n y x id;
run;

* P146 図7.2(B) ;
proc sgplot data = d;
    scatter x = x y = y / jitter;
run;


* P147 二項分布を使った一般化線形モデル ;
proc genmod data = d;
    model y / n = x / dist = binomial
                      link = logit;
    ods output parameterestimates = param_est;
run;

data _null_;
    set param_est;
    if      parameter eq "Intercept" then call symputx("beta1", estimate);
    else if parameter eq "x"         then call symputx("beta2", estimate);
run;

data _null_;
    lambda1 = logistic(&beta1. + &beta2. * 4);
    call symputx("lambda1", lambda1);
run;

proc freq data = d(where=(x eq 4));
    tables y / missing noprint out = d3;
run;

data binomial;
    do y = 0 to 8;
        predict = pdf("binomial", y, &lambda1., 8) * 20;
        output;
    end;
run;

data d3;
    merge d3
          binomial
    ;
    by y;
run;

* P147 図7.3(B) ;
proc sgplot data = d3;
    scatter x = y y = count;
    series  x = y y = predict / markers markerattrs = (symbol=circlefilled);
run;


* P148 葉数が4のサブセットd4を作成 ;
data d4;
    set d;
    if x eq 4;
run;

* P148 生存数別の個体数をカウント ;
proc freq data = d4;
    tables y / missing nocol norow nopercent;
run;

* P149 平均と分散 ;
proc means data = d4 mean var;
    var y;
run;

* P159 一般化線形混合モデルのパラメータを推定 ;
proc glimmix data = d method = quad;
    class id;
    model y / n = x / solution dist = binomial;
    random intercept / subject = id;
run;

