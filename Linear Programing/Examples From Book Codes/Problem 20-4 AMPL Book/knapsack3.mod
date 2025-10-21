set OBJECTS; 
param weight {OBJECTS} > 0;
param value {OBJECTS} > 0;
param weight_capacity > 0;
param volume_capacity >0;
param knapsacks > 0 integer;
param volume{OBJECTS }>0; 

var x {i in OBJECTS, k in 1..knapsacks} binary;


maximize Total_Value:
    sum {i in OBJECTS, k in 1..knapsacks} value[i] * x[i,k];

subject to Capacity {k in 1..knapsacks}:
    sum {i in OBJECTS} weight[i] * x[i,k] <= weight_capacity;

subject to OnePlacement {i in OBJECTS}:
    sum {k in 1..knapsacks} x[i,k] <= 1;

subject to Volume {k in 1..knapsacks}:
    sum{i in OBJECTS} volume[i] * x[i,k] <= volume_capacity;
