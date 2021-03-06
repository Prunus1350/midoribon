%let home_dir = /folders/myfolders/midoribon/chapter02/;

data data;
    infile "&home_dir.data.csv" dsd missover firstobs = 2;
    attrib y length = 8 label = "種子数";
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

* P16 度数集計 ;
proc freq data = data;
    tables y / missing nocol norow nopercent;
run;

* P17 図2.2 例題の種子数データのヒストグラム ;
proc sgplot data = data;
    histogram y / scale = count binwidth = 1;
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

* P19 種子数がyであると観察される確率を生成 ;
data pois;
    do y = 0 to 9;
        prob = pdf("poisson", y, 3.56);
        output;
    end;
run;

* P20 図2.3 平均3.56のポアソン分布の確率分布 ;
proc print data = pois;
run;

* P20 図2.4 平均λ=3.56のポアソン分布 ;
proc sgplot data = pois;
    series x = y y = prob / markers lineattrs = (pattern=dash);
run;


proc freq data = data;
    tables y / missing noprint out = data2(drop=percent);
run;

data data3;
    set data2;
    prob = pdf("poisson", y, 3.56) * 50;
run;

* P21 図2.5 観測データと確率分布の対応 ;
title "Histogram of data";
proc sgplot data = data3;
    vbar y / response = count;
    vline y /
        response = prob
        markers
        lineattrs = (pattern=dash);
run;
title;

data pois2;
    do y = 0 to 20;
        prob1 = pdf("poisson", y, 3.5);
        prob2 = pdf("poisson", y, 7.7);
        prob3 = pdf("poisson", y, 15.1);
        output;
    end;
run;

* P23 図2.6 さまざまな平均(λ)のポアソン分布 ;
proc sgplot data = pois2;
    series x = y y = prob1 /
        markers
        lineattrs = (pattern=dash);
    series x = y y = prob2 /
        markers
        markerattrs = (symbol=diamond)
        lineattrs = (pattern=dash);
    series x = y y = prob3 /
        markers
        markerattrs = (symbol=triangle)
        lineattrs = (pattern=dash);
    yaxis label = "prob";
run;

%macro m2_7;

    * ポアソン分布のパラメータ ;
    %let lambda1 = 2.0;
    %let lambda2 = 2.4;
    %let lambda3 = 2.8;
    %let lambda4 = 3.2;
    %let lambda5 = 3.6;
    %let lambda6 = 4.0;
    %let lambda7 = 4.4;
    %let lambda8 = 4.8;
    %let lambda9 = 5.2;

    data data4;
        set data2;
        %do i = 1 %to 9;
            prob&i. = pdf("poisson", y, &&lambda&i..) * 50;
        %end;
    run;
    
    * パラメータ毎に対数尤度を計算 ;
    data data5;
        set data4;
        %do i = 1 %to 9;
            log_l&i. = (y * log(&&lambda&i..) - &&lambda&i.. - log(fact(y))) * count;
        %end;
    run;

    * 対数尤度をマクロ変数に格納 ;
    proc sql noprint;
        select %do i = 1 %to 8;
                   sum(log_l&i.) format = 8.1,
               %end;
               sum(log_l9) format = 8.1
        into %do i = 1 %to 8;
                 :log_l&i.,
             %end;
             :log_l9
        from data5;
    quit;

    proc template;
        define statgraph poisson_graph;
            begingraph;
                layout lattice / rows = 3 columns = 3;
                    %do i = 1 %to 9;
                        layout overlay / xaxisopts = (display=(tickvalues))
                                         yaxisopts = (linearopts=(viewmin=0
                                                                  viewmax=15
                                                                  tickvaluelist=(0 5 10 15))
                                                      display=(tickvalues));
                            layout gridded / border = false halign = right valign = top;
                                entry halign = left "lambda=&&lambda&i..";
                                entry halign = left "log L=&&log_l&i..";
                            endlayout;
                            barchart x = y y = count;
                            seriesplot x = y y = prob&i. /
                                display = all
                                markerattrs = (symbol=circle)
                                lineattrs = (pattern=dash);
                        endlayout;
                    %end;
                endlayout;
            endgraph;
        end;
    run;
    
    * P26 図2.7 ;
    proc sgrender data = data4 template = poisson_graph;
    run;

%mend m2_7;

%m2_7;


%macro m2_8;

    proc datasets library = work nolist;
        delete log_likelihood;
    run;
    quit;

    %do i = 20 %to 50;
        %let lambda = %sysevalf(&i. / 10);
        data __m1;
            set data;
            log_l = y * log(&lambda.) - &lambda. - log(fact(y));
        run;
        
        proc summary data = __m1;
            var log_l;
            output out = __m2(drop=_type_ _freq_) sum = ;
        run;
        
        data __m2;
            set __m2;
            lambda = &lambda.;
        run;
        
        proc append base = log_likelihood data = __m2;
        run;
        
    %end;

    proc genmod data = data;
        model y = / dist = poisson
                    link = id;
        ods output parameterestimates = __m10;
    run;
    
    data _null_;
        set __m10;
        if parameter eq "Intercept" then call symput("est_param", compress(put(estimate, best.)));
    run;
    
    proc sql noprint;
        select max(log_l), min(log_l) into :maxy, :miny from log_likelihood;
    quit;
    
    data sganno;
        retain function "line" drawspace "datavalue" linepattern "dash";
        x1 = &est_param.;
        x2 = &est_param.;
        y1 = &miny.;
        y2 = &maxy.;
        output;
    run;

    * P28 図2.8 対数尤度　 ;
    proc sgplot data = log_likelihood sganno = sganno;
        series x = lambda y = log_l;
    run;

%mend m2_8;

%m2_8;


%macro mle_poisson(lambda=, rep=);

    proc datasets library = work nolist;
        delete __parameter;
    run;
    quit;
    
    ods listing close;
    ods html close;
    
    %do i = 1 %to &rep.;
        
        data __m1;
            do i = 1 to 50;
                y = rand("poisson", &lambda.);
                output;
            end;
        run;
        
        proc genmod data = __m1;
            model y = / dist = poisson
                        link = id;
            ods output parameterestimates = __m2;
        run;
        
        data __m3(keep=estimate);
            set __m2;
            where parameter eq "Intercept";
         run;
         
         proc append base = __parameter data = __m3;
         run;
         
    %end;
    
    ods html;
    ods listing;

%mend mle_poisson;

%mle_poisson(lambda=3.56, rep=3000);


* P30 図2.9 ;
proc sgplot data = __parameter;
    histogram estimate / binwidth = 0.1;
run;
* 上記マクロと一緒に実行するとエラーが発生する ;
* SAS University Edition特有の現象か？ ;

