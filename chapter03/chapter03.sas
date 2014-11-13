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

proc sgplot data = d;
    scatter x = x y = y / group = f;
run;

proc sgplot data = d;
    vbox y / category = f;
run;

proc genmod data = d;
    model y = x / dist = poisson
                  link = log;
run;


