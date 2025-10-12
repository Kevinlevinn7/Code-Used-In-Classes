set Day;

param T > 0, integer; # MUST BE INTEGER for indexing
param t_slow > 0, integer;  # MUST BE INTEGER for indexing
param t_fast > 0, integer; # MUST BE INTEGER for indexing
param clean_slow > 0; # Price for slow cycle 
param clean_fast > 0; # Price for fast cycle 
param price_new >= 0; # price of new napkins 
param price_trash >= 0; # price to trash napkins 
param demand {1..T} >= 0; # demand for napkins in each period



# Node declarations - simplified
node Dirty_slow{t in 1..T};
node Dirty_fast{t in 1..T};
node Start_Day{t in 1..T};
node End_Day{t in 1..T};
node Used{t in 1..T};
node SUPPLIER;
node TRASH;

# Arc definitions
minimize Total_Cost
;

arc Bought {t in 1..T} >= 0, from SUPPLIER, to Start_Day[t], obj Total_Cost price_new;

arc Carried {t in 1..T-1} >= 0, from End_Day[t], to Start_Day[t+1]; 

arc Demand {t in 1..T} >= demand[t], from Start_Day[t], to Used[t];

arc Sent_to_clean_slow {t in 1..T-t_slow} >= 0, from Used[t], to Start_Day[t+t_fast], obj Total_Cost clean_slow;

arc Sent_to_clean_fast {t in 1..T-t_fast} >= 0, from Used[t], to Start_Day[t+t_fast], obj Total_Cost clean_fast;

arc sent_to_trash {t in 1..T} >= 0, from Used[t], to TRASH, obj Total_Cost price_trash;


