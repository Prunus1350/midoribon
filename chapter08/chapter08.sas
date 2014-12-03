%let home_dir = /folders/myfolders/midoribon/chapter08/;

data data;
    infile "&home_dir.data.csv" dsd missover firstobs = 2;
    attrib y  length = 8 label = "生存種子数";
    input y;
run;

proc freq data = data;
    tables y / missing noprint out = data2(drop=percent);
run;

data xaxis;
    do y = 0 to 8;
        output;
    end;
run;

data data3;
    merge data2
          xaxis;
    by y;
    prob = pdf("binomial", y, 0.45, 8) * 20;
run;

* P172 図8.1(B) 例題の架空データのヒストグラム ;
proc sgplot data = data3;
    vbar y / response = count;
    vline y /
        response = prob
        markers
        lineattrs = (pattern=dash);
run;

%macro m8_2;

    proc datasets library = work nolist;
        delete __param;
    run;
    quit;

    %do i = 25 %to 65;
        %let q = %sysevalf(&i. / 100);
        
        data __m1;
            set data2;
            log_l = (log(comb(8, y)) + y * log(&q.) + (8 - y) * log(1 - &q.)) * count;
        run;
        
        proc sql noprint;
            select sum(log_l) into :log_l from __m1;
        quit;
        
        data __m2;
            q = &q.;
            log_l = &log_l.;
        run;
        
        proc append base = __param data = __m2;
        run;

    %end;

%mend m8_2;

%m8_2;

* 調査種子数を追加 ;
data data4;
    set data2;
    attrib n length = 8 label = "調査種子数";
    n = 8;
run;

proc genmod data = data4;
    model y / n = / dist = binomial
                    link = id;
    weight count;
    ods output parameterestimates = parameterestimates;
run;

data _null_;
    set parameterestimates;
    if parameter eq "Intercept" then call symputx("est_param", estimate);
run;

proc sql noprint;
    select max(log_l), min(log_l) into :maxy, :miny from __param;
quit;

data sganno8_2;
    function = "line";
    drawspace = "datavalue";
    linepattern = "dash";
    x1 = &est_param.;
    x2 = &est_param.;
    y1 = &miny.;
    y2 = &maxy.;
run;

* P172 図8.2 生存確率qと対数尤度logL(q) ;
proc sgplot data = __param sganno = sganno8_2;
    series x = q y = log_l;
    xaxis label = "生存確率q";
    yaxis label = "対数尤度";
run;

* P174 図8.3 生存確率qを離散化しプロット ;
proc sgplot data = __param;
    scatter x = q y = log_l;
    xaxis label = "生存確率q";
    yaxis label = "対数尤度";
run;


%macro m8_5(q=, out1=);

    data __m1;
        set data;
        log_l = log(comb(8, y)) + y * log(&q.) + (8 - y) * log(1 - &q.);
    run;
    
    proc sql noprint;
        select sum(log_l) into :log_l from __m1;
    quit;
    
    data &out1.;
        i = 0;
        q = &q.;
    run;

    %do i = 1 %to 100;
    
        data __m2;
            retain q_new;
            set data;
            if _n_ eq 1 then do;
                if rand("uniform") <= 0.5 then q_new = &q. - 0.01;
                else                           q_new = &q. + 0.01;
                call symputx("q_new", q_new);
            end;
            log_l_new = log(comb(8, y)) + y * log(q_new) + (8 - y) * log(1 - q_new);
        run;

        proc sql noprint;
            select sum(log_l_new) into :log_l_new from __m2;
        quit;

        * 対数尤度が大きくなっていれば値を更新 ;
        data _null_;
            if &log_l. < &log_l_new. then do;
                call symputx("q", &q_new.);
                call symputx("log_l", &log_l_new.);
            end;
        run;

        data __m3;
            i = &i.;
            q = &q.;
        run;
        
        proc append base = &out1. data = __m3;
        run;

    %end;

%mend m8_5;

%m8_5(q=0.60, out1=result1);
%m8_5(q=0.30, out1=result2);

data result_all;
    merge result1(rename=(q=q1))
          result2(rename=(q=q2));
    by i;
run;

* P175 図8.5 試行錯誤による対数尤度最大化にともなうqの変化 ;
proc sgplot data = result_all;
    series x = i y = q1 / lineattrs = (pattern=dash);
    series x = i y = q2;
    xaxis label = "試行錯誤のステップ数";
    yaxis label = "生存確率q" max = 0.7 min = 0.2;
run;


%macro m8_8(q=, rep=, out1=);

    data __m1;
        set data;
        log_l = log(comb(8, y)) + y * log(&q.) + (8 - y) * log(1 - &q.);
    run;
    
    proc sql noprint;
        select sum(log_l) into :log_l from __m1;
    quit;
    
    data &out1.;
        i = 0;
        q = &q.;
    run;

    %do i = 1 %to &rep.;
    
        data __m2;
            retain q_new;
            set data;
            if _n_ eq 1 then do;
                if rand("uniform") <= 0.5 then q_new = &q. - 0.01;
                else                           q_new = &q. + 0.01;
                call symputx("q_new", q_new);
            end;
            log_l_new = log(comb(8, y)) + y * log(q_new) + (8 - y) * log(1 - q_new);
        run;

        proc sql noprint;
            select sum(log_l_new) into :log_l_new from __m2;
        quit;

        * 対数尤度が大きくなっていれば値を更新 ;
        data _null_;
            if (&log_l. < &log_l_new.) or (exp(&log_l_new. - &log_l.) > rand("uniform")) then do;
                call symputx("q", &q_new.);
                call symputx("log_l", &log_l_new.);
            end;
        run;

        data __m3;
            i = &i.;
            q = &q.;
        run;
        
        proc append base = &out1. data = __m3;
        run;

    %end;

    proc sgplot data = &out1.;
        series x = i y = q;
        xaxis label = "MCMC step数";
        yaxis max = 0.7 min = 0.2;
    run;

%mend m8_8;

%m8_8(q=0.30, rep=100, out1=result3);
%m8_8(q=0.30, rep=1000, out1=result4);
%m8_8(q=0.30, rep=100000, out1=result5);




