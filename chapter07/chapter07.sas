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

* 個体数を表すためにデータ点をずらす ;
data d2;
    set d;
    x = x + rand("normal", 0, 0.03);
run;

* P146 図7.2(B) ;
proc sgplot data = d2;
    scatter x = x y = y;
run;

* P147 二項分布を使った一般化線形モデル ;
proc genmod data = d;
    model y / n = x / dist = binomial
                      link = logit
    ;
run;

proc freq data = d(where=(x eq 4));
    tables y / missing noprint out = d3;
run;

data binomial;
    do y = 0 to 8;
        predict = pdf("binomial", y, 0.47, 8) * 20;
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
    series  x = y y = predict;
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


