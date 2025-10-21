set OBJECTS; 
param weight {OBJECTS} > 0;
param value {OBJECTS} > 0;
param capacity > 0;
param knapsacks > 0 integer;
param MaxAmmount > 0 integer;

var x {i in OBJECTS} integer >= 0, <= MaxAmmount;

maximize Total_Value:
    sum{i in OBJECTS} value[i] * x[i]
;
subject to Weight:
    sum{i in OBJECTS} weight[i] *x[i] <= capacity
;

