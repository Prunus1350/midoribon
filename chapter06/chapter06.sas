%let home_dir = /folders/myfolders/midoribon/chapter06/;

data data4a;
    infile "&home_dir.data4a.csv" dsd missover firstobs = 2;
    attrib n length = 8  label = "観察種子数"
           y length = 8  label = "生存種子数"
           x length = 8  label = "植物の体サイズ"
           f length = $1 label = "施肥処理有無"
    ;
    input n y x f;
run;

proc sgplot data = data4a;
    scatter x = x y = y / group = f markerattrs = (symbol=circlefilled);
run;

* みどりぼんの結果に合わせて変数の順番を指定する ;
* ref を付けないと　Cを1、Tを0として計算してしまう ;
* P123 ;
proc genmod data = data4a;
    class f (ref="C");
    model y / n = x f / dist = binomial
                        link = logit
    ;
run;

* P127 一定モデル ;
proc genmod data = data4a;
    class f (ref="C");
    model y / n = / dist = binomial
                    link = logit
    ;
run;

* P127 fモデル ;
proc genmod data = data4a;
    class f (ref="C");
    model y / n = f / dist = binomial
                      link = logit
    ;
run;

* P127 xモデル ;
proc genmod data = data4a;
    class f (ref="C");
    model y / n = x / dist = binomial
                      link = logit
    ;
run;

* P127 x+fモデル ;
proc genmod data = data4a;
    class f (ref="C");
    model y / n = x f / dist = binomial
                        link = logit
    ;
run;

* P127 フルモデル ;
data data4a2;
    set data4a;
    id = put(_n_, best.);
run;

proc genmod data = data4a2;
    class id;
    model y / n = id / dist = binomial
                       link = logit
    ;
run;

* 128 交互作用の入った線形予測子 ;
proc genmod data = data4a;
    class f (ref="C");
    model y / n = x f x * f / dist = binomial
                              link = logit
    ;
run;

* P136 確率の計算 ;
data _null_;
    p = cdf("normal", 1.8, 0, 1) - cdf("normal", 1.2, 0, 1);
    put p;
run;

* P136 確率の近似 ;
data _null_;
    p = pdf("normal", 1.5, 0, 1) * 0.6;
    put p;
run;

