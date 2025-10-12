set T ordered ; #time periods 

param t_slow > 0, integer;  # MUST BE INTEGER for indexing
param t_fast > 0, integer; # MUST BE INTEGER for indexing
param clean_slow > 0; # Price for slow cycle 
param clean_fast > 0; # Price for fast cycle 
param price_new >= 0; # price of new napkins 
param price_trash >= 0; # price to trash napkins 
param demand {T} >= 0; # demand for napkins in each period 
param inital_stock >= 0; # initial inventory of napkins 

# Node declarations - simplified
node Dirty_slow;
node Dirty_fast;
node SUPPLIER;
node TRASH;
node Day_T {t in T};

# Arc definitions
arc Bought {t in T} >= 0, <= demand[t], from SUPPLIER, to Day_T[t];

arc Carried {t in T: t < last(T)} >= 0, from Day_T[t], to Day_T[t+1];

arc Sent_to_clean_slow {t in T} >= 0, from Day_T[t], to Dirty_slow;

arc Sent_to_clean_fast {t in T} >= 0, from Day_T[t], to Dirty_fast;

arc sent_to_trash {t in T} >= 0, from Day_T[t], to TRASH;

arc Cleaned_slow {t in T: t + t_slow in T} >= 0, from Dirty_slow, to Day_T[t + t_slow];

arc Cleaned_fast {t in T: t + t_fast in T} >= 0, from Dirty_fast, to Day_T[t + t_fast];

# Objective function
minimize Total_Cost:
    sum {t in T} price_new * Bought[t] 
    + sum {t in T} clean_slow * Sent_to_clean_slow[t] 
    + sum {t in T} clean_fast * Sent_to_clean_fast[t] 
    + sum {t in T} price_trash * sent_to_trash[t];

# Node balance constraints
subject to Daily_Demand_Balance {t in T}:
    (if t in T then 0 else 0)  # just placeholder start
    Bought[t]
    + (if t > first(T) and t-1 in T then Carried[t-1] else inital_stock)
    + (if t - t_slow in T then Cleaned_slow[t - t_slow] else 0)
    + (if t - t_fast in T then Cleaned_fast[t - t_fast] else 0)
    - (if t < last(T) then Carried[t] else 0)
    - Sent_to_clean_slow[t]
    - Sent_to_clean_fast[t]
    - sent_to_trash[t]
    = demand[t];


# Dirty node balance constraints
subject to Dirty_Slow_Balance:
    sum {t in T} Sent_to_clean_slow[t] = sum {t in T: t + t_slow in T} Cleaned_slow[t];

subject to Dirty_Fast_Balance:
    sum {t in T} Sent_to_clean_fast[t] = sum {t in T: t + t_fast in T} Cleaned_fast[t];|