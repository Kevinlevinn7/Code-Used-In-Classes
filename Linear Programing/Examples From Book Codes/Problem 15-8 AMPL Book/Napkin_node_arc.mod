# Define T as a numeric range
set T;

param t_slow > 0, integer;  
param t_fast > 0, integer; 
param clean_slow > 0; 
param clean_fast > 0; 
param price_new >= 0; 
param price_trash >= 0; 
param demand {T} >= 0; 
param initial_stock >= 0; 

# Decision variables (traditional approach)
var Bought {T} >= 0;                    # Napkins bought new each day
var Carried {t in T: t < card(T)} >= 0; # Napkins carried to next day
var Sent_to_clean_slow {T} >= 0;        # Sent to slow laundry
var Sent_to_clean_fast {T} >= 0;        # Sent to fast laundry  
var sent_to_trash {T} >= 0;             # Discarded napkins
var Cleaned_slow {t in T: t + t_slow <= card(T)} >= 0; # Returned from slow laundry
var Cleaned_fast {t in T: t + t_fast <= card(T)} >= 0; # Returned from fast laundry
var Stock {T} >= 0;                     # Inventory at start of each day

# Objective function
minimize Total_Cost:
    sum {t in T} price_new * Bought[t] 
    + sum {t in T} clean_slow * Sent_to_clean_slow[t] 
    + sum {t in T} clean_fast * Sent_to_clean_fast[t] 
    + sum {t in T} price_trash * sent_to_trash[t];

# Inventory balance constraints
subject to Inventory_Balance {t in T}:
    Stock[t] + Bought[t] 
    + (if t - t_slow >= 1 then Cleaned_slow[t - t_slow] else 0)
    + (if t - t_fast >= 1 then Cleaned_fast[t - t_fast] else 0)
    - (if t < card(T) then Carried[t] else 0)
    - Sent_to_clean_slow[t]
    - Sent_to_clean_fast[t]
    - sent_to_trash[t]
    = demand[t];

subject to Carry_Definition {t in T: t < card(T)}:
    Carried[t] = Stock[t+1];

# Initial stock
subject to Initial_Stock:
    Stock[1] = initial_stock;

# Laundry balance constraints
subject to Dirty_Slow_Balance:
    sum {t in T} Sent_to_clean_slow[t] = sum {t in T: t + t_slow <= card(T)} Cleaned_slow[t];

subject to Dirty_Fast_Balance:
    sum {t in T} Sent_to_clean_fast[t] = sum {t in T: t + t_fast <= card(T)} Cleaned_fast[t];