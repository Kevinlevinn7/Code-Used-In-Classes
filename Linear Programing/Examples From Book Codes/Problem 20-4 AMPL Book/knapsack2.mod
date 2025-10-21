set OBJECTS; 
param weight {OBJECTS} > 0;
param value {OBJECTS} > 0;
param capacity > 0;
param knapsacks > 0 integer;

var x {i in OBJECTS, k in 1..knapsacks} binary;

subject to Capacity {k in 1..knapsacks}:
    sum {i in OBJECTS} weight[i] * x[i,k] <= capacity;

maximize Total_Value:
    sum {i in OBJECTS, k in 1..knapsacks} value[i] * x[i,k];

subject to OnePlacement {i in OBJECTS}:
    sum {k in 1..knapsacks} x[i,k] <= 1;
