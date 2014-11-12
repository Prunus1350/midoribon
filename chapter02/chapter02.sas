%let home_dir = /folders/myfolders/midoribon/chapter02/;

data data;
    infile "&home_dir.data.csv" dsd missover firstobs = 2;
    attrib y length = 8 label = "";
    input y;
run;

* P15 dataの内容を表示 ;
proc print data = data;
run;

* P15 データ数の確認 ;
data _null_;
    set data nobs = n;
    put n;
    stop;
run;

* P16 最小値・四分位点・標本平均・中央値・最大値 ;
proc means data = data min q1 median mean q3 max;
run;
/*
SASとRとではQuantileの計算方法が違うため、みどりぼんの値が再現できない
http://en.wikipedia.org/wiki/Quantile
*/

* 5通りのQuantile計算方法を試す ;
%macro quantile_test;

    %do i = 1 %to 5;
        proc univariate data = data pctldef = &i. noprint;
            output out = temp min = min q1 = q1 median = median mean = mean q3 = q3 max = max;
        run;
        
        proc print data = temp;
            var min q1 median mean q3 max;
        run;
    %end;

%mend quantile_test;

%quantile_test;

proc freq data = data;
    tables y / missing nocol norow nopercent;
run;

proc sgplot data = data;
    histogram y / scale = count binstart = -0.5 binwidth = 1;
run;

proc means data = data noprint;
    output out = sample_variance(drop=_type_ _freq_) var = var std = std;
run;

* P17 標本分散・標本標準偏差 ;
data _null_;
    set sample_variance;
    put var = ;
    put std = ;
    sqrt_var = sqrt(var);
    put sqrt_var = ;
run;    


data pois;
    do y = 0 to 9;
        prob = pdf("poisson", y, 3.56);
        output;
    end;
run;

* P20 図2.3 ;
proc print data = pois;
run;

* P20 図2.4 平均λ=3.56のポアソン分布 ;
proc sgplot data = pois;
    series x = y y = prob;
run;


