#===============================
# Sets
#===============================
set PROD;      # Products
set S;         # Scenarios

#===============================
# Parameters
#===============================
param T > 0;                        # Number of periods

param rate {PROD} > 0;   
           # Production rate per product
param inv0 {PROD} >= 0;  
           # Initial inventory
param avail {1..T} >= 0; 
           # Available production time per period
param market {PROD,1..T} >= 0;   
   # Market demand per product per period

param prodcost {PROD} >= 0; 
        # Production cost per unit
param invcost {PROD} >= 0;  
        # Inventory holding cost per unit

param revenue {PROD,1..T,S} >= 0; 
  # Revenue per product per period per scenario
param prob {S} >= 0, <= 1;          # Probability of each scenario

param tol := 1e-5;   
               # Tolerance for probability sum
assert sum {s in S} prob[s] >= 1 - tol;

assert sum {s in S} prob[s] <= 1 + tol;

#===============================
# Decision Variables
#===============================
var Make {p in PROD, t in 1..T, s in S} >= 0;
          # Units produced
var Inv {p in PROD, 0..T, s in S} >= 0;  
             # Inventory
var Sell {p in PROD, t in 1..T, s in S} >= 0, <= market[p,t];  # Units sold

#===============================
# Objective Function
#===============================
maximize Expected_Profit:
   sum {s in S} prob[s] *
     sum {p in PROD, t in 1..T}
        (revenue[p,t,s]*Sell[p,t,s] - prodcost[p]*Make[p,t,s] - invcost[p]*Inv[p,t,s]);


#===============================
# Constraints
#===============================
# Production time limit
subject to Time {t in 1..T, s in S}:
   sum {p in PROD} (1/rate[p]) * Make[p,t,s] <= avail[t];

# Initial inventory
subject to Init_Inv {p in PROD, s in S}:
   Inv[p,0,s] = inv0[p];

# Inventory balance
subject to Balance {p in PROD, t in 1..T, s in S}:
   Make[p,t,s] + Inv[p,t-1,s] = Sell[p,t,s] + Inv[p,t,s];
