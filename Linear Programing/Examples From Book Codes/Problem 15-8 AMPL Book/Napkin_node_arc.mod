set T; #time periods 


param t_slow > 0;
param t_fast > 0; 
param clean_slow > 0; # Price for slow cycle 
param clean_fast > 0; # Price for fast cycle 
param price_new >= 0; # price of new napkins 
param price_trash >= 0; # price to trash napkins 
param demand {T} >= 0; # demand for napkins in each period 
param inital_stock >= 0; # initial inventory of napkins 

minimize Total_Cost:
    # 1. Cost of Buying New Napkins
    sum {t in T} price_new * Bought[t] 
    
    # 2. Cost of Slow Cleaning (flow through Sent_to_clean_slow or Cleaned_slow)
    #    It's standard to associate the washing cost with the act of washing/sending.
    + sum {t in T} clean_slow * Sent_to_clean_slow[t] 
    
    # 3. Cost of Fast Cleaning (flow through Sent_to_clean_fast or Cleaned_fast)
    + sum {t in T} clean_fast * Sent_to_clean_fast[t] 
    
    # 4. Cost of Trashing Napkins
    + sum {t in T} price_trash * sent_to_trash[t]
    
    # Note: Carrying napkins usually has zero cost, so Carried[t] is omitted.
;
    
node Day_T{t in T};
node CLEAN {t in T}; 
    net_in = net_out; 
node Dirty_slow {t in T}; 
    net_in = net_out; 
node Dirty_fast {t in T}; 
    net_in = net_out
node SUPPLIER; 
node TRASH; 

arc Bought {t in T} >= 0, <= demand[t], from SUPPLIER, to Day_T[t]; 

arc Carried {t in T excluding last(T)} >= 0, from Day_T[t], to Day_T[t+1]; 

arc Sent_to_clean_slow {t in T} >=0, from Day_T[t], to Dirty_slow[t]; 

arc Sent_to_clean_fast {t in T} >=0, from Day_T[t], to Dirty_fast[t]; 

arc sent_to_trash {t in T} >=0, from Day_T[t], to TRASH; 

arc Cleaned_slow {t in T: t + t_slow in T} >=0, from Dirty_slow[t], to Day_T[t + t_slow]; 

arc Cleaned_fast {t in T: t + t_fast in T} >=0, from Dirty_fast[t], to Day_T[t + t_fast]; 


subject to Daily_Demand_Balance {t in T}:
    net_in[Day_T[t]] - net_out[Day_T[t]] = 
        - demand[t] 
        + (if t == first(T) then inital_stock else 0);

