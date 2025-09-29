set T;
    # time periods 1...T


param time_slow > 0; # hours per napkin in each cycle  
param time_fast > 0;  # hours per napkin in each cycle

param p_slow > 0;  # Price for slow cycle
param p_fast > 0;  # Price for fast cycle
param price_new >= 0;  # price of new napkins

param demand {T} >= 0;  # demand for napkins in each period
param inital_stock >= 0; # initial inventory of napkins

minimize Total_Cost:

node Balance {t in T}:
    net_in = demand[t] - supply[t]; #The supply and demand from each period are equal

arc Buy {t in T} >= 0;   # napkins bought in period t 

arc fast {t in T} >= 0;:
    from demand[t], to demand[t + time_fast], obj Total_Cost p_fast;

arc slow {t in T}


arc trash {t in T}


arc carry {t in T}
