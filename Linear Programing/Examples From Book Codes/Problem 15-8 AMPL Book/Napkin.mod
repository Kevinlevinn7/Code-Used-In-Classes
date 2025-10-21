param T > 0;
param demand  {1..T} >= 0;
param buy_cost  {1..T} >= 0;
param fast_cost >= 0; 
param slow_cost >= 0;
param init_clean >= 0;

var Buy   {t in 1..T} >= 0;
var Carry {t in 1..T} >= 0;
var Wash2 {t in 1..T} >= 0;
var Wash4 {t in 1..T} >= 0;
var Trash {t in 1..T} >= 0;

minimize Total_Cost:
  sum {t in 1..T} (
      buy_cost[t]*Buy[t]
    + fast_cost*Wash2[t]
    + slow_cost*Wash4[t]
  );

subject to CleanBalance {t in 1..T}:
    Buy[t]
  + (if t > 1 then Carry[t-1] else init_clean)
  + (if t > 2 then Wash2[t-2] else 0)
  + (if t > 4 then Wash4[t-4] else 0)
  =Carry[t] + Wash2[t] + Wash4[t] + Trash[t];

subject to UsedBalance {t in 1..T}:
    Wash2[t] + Wash4[t] + Trash[t] = demand[t];
