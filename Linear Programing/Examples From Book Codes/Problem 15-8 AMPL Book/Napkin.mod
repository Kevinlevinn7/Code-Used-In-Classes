set T;
    # time periods 1...T


param t_slow > 0; 
param t_fast > 0; 

param clean_slow > 0;  # Price for slow cycle
param clean_fast > 0;  # Price for fast cycle
param price_new >= 0;  # price of new napkins
param price_trash >= 0; # price to trash napkins

param demand {T} >= 0;  # demand for napkins in each period
param inital_stock >= 0; # initial inventory of napkins


var Buy[t] >= 0;   # napkins bought in period t
var Carry[t] >= 0; # napkins carried from period t to t+1
var Wash2[t] >= 0; # napkins washed in fast cycle in period t
var Wash4[t] >= 0; # napkins washed in slow cycle in period t
var Trash[t] >= 0; # napkins trashed in period t

minimize Total_Cost:
   sum {t in T} (price_new * Buy[t] +
                  clean_fast * Wash2[t] +
                  clean_slow * Wash4[t] +
                  price_trash * Trash[t]);

               # Objective: minimize total cost of buying
               # new napkins and cleaning used napkins

subject to Availability {t in T}:
    (if t > t_fast then Wash2[t - t_fast] else 0)
  + (if t > t_slow then Wash4[t - t_slow] else 0)
  + Buy[t]
  + (if t = first(T) then inital_stock else Carry[t-1])
  >= demand[t] + Carry[t];

subject to DirtyFlow {t in T}:
    demand[t] = Wash2[t] + Wash4[t] + Trash[t];

subject to NoCarryAtEnd:
    Carry[last(T)] = 0;