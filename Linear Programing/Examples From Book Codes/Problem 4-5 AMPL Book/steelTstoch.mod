set PROD;     # products
set S; #Scenario
param T > 0;  # number of weeks

param rate {PROD} > 0;          # tons per hour produced
param inv0 {PROD} >= 0;         # initial inventory
param avail {1..T} >= 0;        # hours available in week
param market {PROD,1..T} >= 0;  # limit on tons sold in week

param prodcost {PROD} >= 0;     # cost per ton produced
param invcost {PROD} >= 0;      # carrying cost/ton of inventory
param revenue {PROD,1..T} >= 0; # revenue per ton sold


#My addition 
###############

param S > 0;
param revenue {PROD,1..T,1..S} >= 0;

param prob {1..S} >= 0, <= 1;
       check: 0.99999 < sum {s in 1..S} prob[s] < 1.00001;

################

var Make {PROD,1..T} >= 0;      # tons produced
var Inv {PROD,0..T} >= 0;       # tons inventoried
var Sell {p in PROD, t in 1..T} >= 0, <= market[p,t]; # tons sold



maximize Expected_Profit:
   sum {s in 1..S} prob[s] *
    sum {p in PROD, t in 1..T} (revenue[p,t,s]*Sell[p,t,s] -
      prodcost[p]*Make[p,t,s] - invcost[p]*Inv[p,t,s]);  



maximize Total_Profit:
   sum {p in PROD, t in 1..T} (revenue[p,t]*Sell[p,t] -
      prodcost[p]*Make[p,t] - invcost[p]*Inv[p,t]);

               # Total revenue less costs in all weeks




subject to Time {t in 1..T}:
   sum {s in 1..S} prob[s] * 
    sum {p in PROD} (1/rate[p]) * Make[p,t] <= avail[t];

               # Total of hours used by all products
               # may not exceed hours available, in each week

subject to Init_Inv {p in PROD}:  Inv[p,0] = inv0[p];

               # Initial inventory must equal given value

subject to Balance {p in PROD, t in 1..T}:
   Make[p,t] + Inv[p,t-1] = Sell[p,t] + Inv[p,t];

               # Tons produced and taken from inventory
               # must equal tons sold and put into inventory
