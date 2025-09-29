set PROD;     # products 

param T > 0;  # number of weeks
param S > 0;

param rate {PROD} > 0;          # tons per hour produced
param inv0 {PROD} >= 0;         # initial inventory
param avail {1..T} >= 0;        # hours available in week
param market {PROD,1..T} >= 0;  # limit on tons sold in week

param prodcost {PROD} >= 0;     # cost per ton produced
param invcost {PROD} >= 0;      # carrying cost/ton of inventory
param revenue {PROD,1..T,s in 1..S} >= 0;

param prob {1..S} >= 0, <= 1;
check: 0.99999 < sum {s in 1..S} prob[s] < 1.00001;


var Make {PROD,1..T,s in 1..S} >= 0;      # tons produced
var Inv {PROD,0..T,s in 1..S} >= 0;       # tons inventoried
var Sell {p in PROD, t in 1..T, s in 1..S} >= 0, <= market[p,t]; # tons sold

maximize Total_Profit:
   sum {s in 1..S} prob[s] *
      sum {p in PROD, t in 1..T} (
         revenue[p,t,s] * Sell[p,t,s] 
         -prodcost[p] * Make[p,t,s] 
         - invcost[p] * Inv[p,t,s]);

subject to Make_na{p in PROD, s in 1..S-1}: 
   Make[p,1,s] = Make[p,1,s+1];

subject to Inv_na{p in PROD, s in 1..S-1}: 
   Inv[p,1,s] = Inv[p,1,s+1];

subject to Sell_na{p in PROD, s in 1..S-1}: 
   Sell[p,1,s] = Sell[p,1,s+1];

subject to Time {t in 1..T,s in 1..S}:
   sum {p in PROD} (1/rate[p]) * Make[p,t,s] <= avail[t];

               # Total of hours used by all products
               # may not exceed hours available, in each week

subject to Init_Inv {p in PROD,s in 1..S}:  Inv[p,0,s] = inv0[p];

               # Initial inventory must equal given value

subject to Balance {p in PROD, t in 1..T,s in 1..S}:
   Make[p,t,s] + Inv[p,t-1, s] = Sell[p,t,s] + Inv[p,t,s];
               # Tons produced and taken from inventory
               # must equal tons sold and put into inventory

